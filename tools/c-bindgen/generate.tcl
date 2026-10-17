# generate.tcl -- one profile on one target, from headers to files
# (C-BINDGEN.md, "Pipeline").
#
#   ::cbind::generate::run PROFILE TARGET OPTIONS
#
#   header profile + target  ->  the C toolchain for the target (clang --target)
#   -> preprocess, parse, macro probe   (tools/cheader/pipeline.tcl)
#   -> candidates                       (model.tcl: classify every API name)
#   -> ABI probe, symbol probe          (probe.tcl: the compiler's facts)
#   -> signatures, contracts, constants (model.tcl)
#   -> the shim, compiled once to check every thunk; its LLVM IR read for
#      evidence when the profile asks (probe.tcl)
#   -> files                            (emit.tcl, report.tcl)
#
# Each stage's result is plain data (the -dump option writes them all), and
# nothing here parses C or emits Botlish itself.

namespace eval ::cbind::generate {}

# The profile's header profile for TARGET with absolute include
# directories, as the toolchain adapter takes it.
proc ::cbind::generate::ToolProfile {hprofile sourceRoot} {
    set abs {}
    foreach d [dict get $hprofile includeDirs] { lappend abs [file join $sourceRoot $d] }
    return [dict replace $hprofile includeDirs $abs]
}

# The target's user label prefix (__USER_LABEL_PREFIX__) from the
# predefined macros TEXT.
proc ::cbind::generate::LabelPrefix {text} {
    if {[regexp -line {^#define __USER_LABEL_PREFIX__ ?(\S*)$} $text -> prefix]} {
        return $prefix
    }
    return ""
}

proc ::cbind::generate::Seconds {t0} {
    return [format %.3f [expr {([clock microseconds] - $t0) / 1e6}]]
}

# Generates PROFILE (a name or a loaded profile) for TARGET. OPTIONS:
# bool 0|1 (whether C _Bool maps to ffi::c::Bool), evidence (overrides the
# profile's), fetch 0|1. Returns {files FILES model MODEL timing TIMING}.
proc ::cbind::generate::run {profile target {options {}}} {
    set options [dict merge {bool 1 fetch 0 evidence ""} $options]
    if {[llength $profile] == 1} { set profile [::cbind::profile::load $profile] }
    if {$target ni [dict get $profile targets]} {
        error "c-bindgen: profile [dict get $profile name] is not generated for $target (its targets: [join [dict get $profile targets] {, }])"
    }
    if {[dict get $options evidence] ne ""} { dict set profile evidence [dict get $options evidence] }
    set timing [dict create]
    set hprofile [::cbind::profile::headersFor $profile $target]
    set sourceRoot [::cbind::profile::sourceRoot $profile [dict get $options fetch]]
    set config [::chdr::toolchain::configFor $target]
    set tool [ToolProfile $hprofile $sourceRoot]
    # A target's own system headers, or none: never the host's. Off a Mac,
    # clang for an Apple target would fall back to the host's /usr/include
    # and preprocess Linux's headers as if they were the SDK's.
    if {[string match macos-* $target] && $::tcl_platform(os) ne "Darwin"
            && [dict get $config sysroot] eq "" && "-nostdlibinc" ni [dict get $hprofile flags]} {
        error "c-bindgen: $target needs the macOS SDK's headers: generate on a Mac, or set BOTLISH_C_SYSROOT_[string map {- _} $target] (or BOTLISH_C_SYSROOT) to an SDK directory; the host's own headers are never a target's"
    }

    set t0 [clock microseconds]
    set run [::chdr::pipeline::run $hprofile $sourceRoot $config [dict get $profile name]]
    if {![dict get $run ok]} {
        error "c-bindgen: preprocessing [dict get $profile name] for $target failed:\n[string range [dict get $run stderr] 0 3000]"
    }
    dict set timing preprocess [dict get $run timing preprocess]
    dict set timing parse [dict get $run timing parse]
    dict set timing macros [expr {[dict get $run timing macroPreprocess] + [dict get $run timing probe]}]
    set prefix [LabelPrefix [dict get $run predefined]]

    set t0 [clock microseconds]
    set model [::cbind::model::candidates $profile $target $run $options]
    dict set timing model [Seconds $t0]

    set t0 [clock microseconds]
    set requests [dict get $model requests]
    set values [::cbind::probe::values $config $tool [dict get $requests values]]
    set symbols [::cbind::probe::symbols $config $tool [dict get $requests symbols] $prefix]
    dict set timing probes [Seconds $t0]

    set t0 [clock microseconds]
    set model [::cbind::model::resolve $model [dict create values $values symbols $symbols prefix $prefix]]
    dict set model profile $profile
    dict set model target $target
    dict set model run [dict create revision [dict get $run revision] command [dict get $run command] \
        tokens [dict get $run tokens] bytes [string length [dict get $run text]]]
    dict set model toolchain [::chdr::toolchain::describe $config]
    dict set model sourceRoot $sourceRoot
    dict set model labelPrefix $prefix
    dict set timing mapping [Seconds $t0]

    set t0 [clock microseconds]
    set model [Thunks $model $config $tool]
    dict set timing shim [Seconds $t0]

    set t0 [clock microseconds]
    set files [::cbind::emit::files $model]
    dict set model files $files
    dict set files report.tsv [::cbind::report::tsv $model]
    dict set files report.txt [::cbind::report::text $model]
    dict set files manifest.txt [::cbind::report::manifest $model $files]
    dict set timing emit [Seconds $t0]
    return [dict create files $files model $model timing $timing]
}

# The thunks of MODEL, checked: the shim is compiled once (one translation
# unit, every thunk); a thunk the compiler rejects becomes unsupported with
# its message and the rest is compiled again. With evidence llvm, the
# shim's -O2 LLVM IR gives each thunk's parameter attributes, which become
# proven contract facts (ApplyContracts again, beside the manual ones).
proc ::cbind::generate::Thunks {model config tool} {
    for {set round 0} {$round < 20} {incr round} {
        set thunks [ThunkEntries $model]
        if {![llength $thunks]} { return $model }
        set ::cbind::emit::model $model
        set ::cbind::emit::ns [dict get $model profile name]
        set shim [::cbind::emit::Shim $thunks]
        set dir [file tempdir]
        set path [file join $dir shim.c]
        ::chdr::writeFile $path $shim
        lassign [::chdr::toolchain::object $config $tool $path [file join $dir shim.o] \
            {-Werror=incompatible-pointer-types -Werror=int-conversion -Werror=implicit-function-declaration -Werror=return-type}] ok stderr command
        file delete -force $dir
        if {$ok} break
        set lines [dict create]
        set n 0
        set current ""
        foreach line [split $shim \n] {
            incr n
            foreach e $thunks {
                if {[string first "[dict get $e symbol](" $line] >= 0 && [string index [string trimright $line] end] eq "\{"} {
                    set current [dict get $e name]
                }
            }
            if {$current ne ""} { dict set lines $n $current }
        }
        set blame [::cbind::probe::Blame [string map [list $path probe.c] $stderr] $lines]
        if {![dict size $blame]} {
            error "c-bindgen: the shim does not compile, and no thunk is to blame:\n[string range $stderr 0 3000]"
        }
        set out {}
        foreach e [dict get $model apis] {
            if {[dict exists $blame [dict get $e name]] && [dict get $e kind] eq "thunk"} {
                dict set e kind unsupported
                dict set e blockers [list [list thunk-rejected "the C compiler rejects the thunk: [dict get $blame [dict get $e name]]"]]
            }
            lappend out $e
        }
        dict set model apis $out
    }
    set evidence [dict create]
    set producer ""
    if {[dict get $model profile evidence] eq "llvm"} {
        set syms [lmap e [ThunkEntries $model] {dict get $e symbol}]
        lassign [::cbind::probe::evidence $config $tool $shim $syms] ok message evidence producer
        if {!$ok} {
            error "c-bindgen: the shim's LLVM IR (evidence llvm) failed: [string range $message 0 2000]"
        }
    }
    dict set model evidenceProducer $producer
    set out {}
    foreach e [dict get $model apis] {
        if {[dict get $e kind] eq "thunk" && [dict exists $evidence [dict get $e symbol]]} {
            set manual [dict get $model manual]
            set m [expr {[dict exists $manual [dict get $e name]] ? [dict get $manual [dict get $e name]] : {}}]
            set e [::cbind::model::ApplyContracts $e $m [dict get $evidence [dict get $e symbol]]]
        }
        lappend out $e
    }
    dict set model apis $out
    return $model
}

proc ::cbind::generate::ThunkEntries {model} {
    set out {}
    foreach e [dict get $model apis] {
        if {[dict get $e kind] eq "thunk"} { lappend out $e }
    }
    return $out
}

# Writes FILES under DIR, removing the generated files of an earlier run
# that this one no longer produces (the binding modules, the shim and the
# records; nothing else in DIR is touched).
proc ::cbind::generate::write {files dir ns} {
    file mkdir $dir
    foreach old [Existing $dir $ns] {
        if {![dict exists $files $old]} { file delete [file join $dir $old] }
    }
    dict for {path text} $files {
        ::chdr::writeFile [file join $dir $path] $text
    }
}

# The generated files present under DIR (relative paths), sorted.
proc ::cbind::generate::Existing {dir ns} {
    set out {}
    foreach f {shim.c manifest.txt report.txt report.tsv} {
        if {[file exists [file join $dir $f]]} { lappend out $f }
    }
    set stack [list $ns]
    while {[llength $stack]} {
        set stack [lassign $stack rel]
        set abs [file join $dir $rel]
        if {![file isdirectory $abs]} continue
        foreach f [lsort [glob -nocomplain -directory $abs -tails *]] {
            if {[file isdirectory [file join $abs $f]]} {
                lappend stack $rel/$f
            } elseif {[string match *.bot $f]} {
                lappend out $rel/$f
            }
        }
    }
    return [lsort $out]
}

# The differences between FILES and what DIR holds: a list of
# {PATH STATUS DETAIL}, STATUS added, removed or changed (DETAIL the first
# differing lines).
proc ::cbind::generate::compare {files dir ns} {
    set out {}
    set existing [Existing $dir $ns]
    foreach path [lsort [dict keys $files]] {
        set abs [file join $dir $path]
        if {![file exists $abs]} {
            lappend out [list $path missing "not committed (generate writes it)"]
            continue
        }
        set old [::chdr::readFile $abs]
        set new [dict get $files $path]
        if {$old ne $new} {
            lappend out [list $path changed [FirstDifference $old $new]]
        }
    }
    foreach path $existing {
        if {![dict exists $files $path]} {
            lappend out [list $path stale "committed, but generation no longer produces it"]
        }
    }
    return $out
}

proc ::cbind::generate::FirstDifference {old new} {
    set a [split $old \n]
    set b [split $new \n]
    set n [expr {max([llength $a], [llength $b])}]
    set shown {}
    for {set i 0} {$i < $n && [llength $shown] < 6} {incr i} {
        set x [lindex $a $i]
        set y [lindex $b $i]
        if {$x ne $y} {
            lappend shown "line [expr {$i + 1}]:\n      committed: $x\n      generated: $y"
        }
    }
    return [join $shown "\n    "]
}

# The coverage change between the committed report.tsv in DIR and the
# generated RESULT's: one line per name whose status or reason changed
# (~), that appeared (+) or disappeared (-).
proc ::cbind::generate::coverageChange {dir result} {
    set path [file join $dir report.tsv]
    if {![file exists $path]} { return {} }
    set old [readTsv [::chdr::readFile $path]]
    set new [readTsv [dict get $result files report.tsv]]
    set lines {}
    dict for {key row} $new {
        if {![dict exists $old $key]} {
            lappend lines "+ $key: [lindex $row 2] [lindex $row 4]"
        } elseif {[lrange [dict get $old $key] 2 end] ne [lrange $row 2 end]} {
            lappend lines "~ $key: [lindex [dict get $old $key] 2] [lindex [dict get $old $key] 4] -> [lindex $row 2] [lindex $row 4]"
        }
    }
    dict for {key row} $old {
        if {![dict exists $new $key]} { lappend lines "- $key: was [lindex $row 2] [lindex $row 4]" }
    }
    return $lines
}

# The rows of a report.tsv TEXT: "KIND NAME" -> row.
proc ::cbind::generate::readTsv {text} {
    set out [dict create]
    foreach line [lrange [split [string trimright $text \n] \n] 1 end] {
        set row [split $line \t]
        dict set out "[lindex $row 0] [lindex $row 1]" $row
    }
    return $out
}

# Compiles the shim.c of the generated binding in DIR (PROFILE/TARGET's
# committed one by default) into its static library lib<shim_library>.a in
# OUT, with the target's toolchain; returns OUT, or "" when the binding has
# no shim.
proc ::cbind::generate::buildShim {profile target out {dir ""}} {
    if {$dir eq ""} { set dir [::cbind::profile::outputDir $profile $target] }
    set shimPath [file join $dir shim.c]
    if {![file exists $shimPath]} { return "" }
    if {$out eq ""} { error "c-bindgen build: -out DIR is required" }
    set manifest [::chdr::readFile [file join $dir manifest.txt]]
    if {![regexp -line {^shim_library (\S+)$} $manifest -> name]} {
        error "c-bindgen build: no shim_library in [file join $dir manifest.txt]"
    }
    set sourceRoot [::cbind::profile::sourceRoot $profile 0]
    set hprofile [::cbind::profile::headersFor $profile $target]
    set tool [ToolProfile $hprofile $sourceRoot]
    set config [::chdr::toolchain::configFor $target]
    file mkdir $out
    set obj [file join $out $name.o]
    lassign [::chdr::toolchain::object $config $tool $shimPath $obj {-O2 -fPIC -w}] ok stderr
    if {!$ok} { error "c-bindgen build: the shim does not compile:\n$stderr" }
    set archive [file join $out lib$name.a]
    lassign [::chdr::toolchain::archive $config [list $obj] $archive] ok stderr
    if {!$ok} { error "c-bindgen build: ar failed: $stderr" }
    file delete $obj
    return $out
}

# Copies the files of application APP (a directory, or a program file and
# the application modules beside it) and the generated binding in DIR
# (PROFILE/TARGET's committed one by default) into INTO: one application
# root, which the ordinary compiler compiles.
proc ::cbind::generate::stage {profile target app into {dir ""}} {
    if {$dir eq ""} { set dir [::cbind::profile::outputDir $profile $target] }
    if {![file isdirectory [file join $dir [dict get $profile name]]]} {
        error "c-bindgen stage: no generated binding in $dir (run generate)"
    }
    file mkdir $into
    if {$app ne ""} {
        set appDir [expr {[file isdirectory $app] ? $app : [file dirname $app]}]
        foreach f [glob -nocomplain -directory $appDir *] {
            file copy -force $f $into
        }
    }
    set ns [dict get $profile name]
    file delete -force [file join $into $ns]
    file copy -force [file join $dir $ns] [file join $into $ns]
}
