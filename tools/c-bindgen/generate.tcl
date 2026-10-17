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
