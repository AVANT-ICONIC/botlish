# c-bindgen.tcl -- the C binding generator (C-BINDGEN.md): ordinary Botlish
# source (`extern c library`, `extern c fn`, opaque pointee types, typed
# constants) and C thunks, generated from real C headers by the installed C
# compiler and the C header library (tools/cheader/). A development tool:
# ordinary Botlish compilation never runs it, needs no header, no
# preprocessor and no C compiler, and compiles a generated binding exactly
# like a hand-written one.
#
#   tclsh9.0 tools/c-bindgen.tcl profiles
#   tclsh9.0 tools/c-bindgen.tcl fetch PROFILE
#   tclsh9.0 tools/c-bindgen.tcl generate PROFILE ?-target T|all? ?-out DIR? ?-timing 1?
#   tclsh9.0 tools/c-bindgen.tcl check PROFILE ?-target T|all? ?-dir DIR?
#   tclsh9.0 tools/c-bindgen.tcl report PROFILE ?-target T? ?-why NAME? ?-status S? ?-reason R?
#   tclsh9.0 tools/c-bindgen.tcl build PROFILE ?-target T? -out DIR
#   tclsh9.0 tools/c-bindgen.tcl stage PROFILE ?-target T? -app DIR -into DIR
#   tclsh9.0 tools/c-bindgen.tcl run PROFILE ?-target T? PROGRAM.bot ?MAIN.TCL OPTIONS...?
#   tclsh9.0 tools/c-bindgen.tcl diff PROFILE ?-targets {A B}?
#
# generate writes OUTPUT/TARGET/ (the profile's output, generated/c/PROFILE
# by default): the binding modules, shim.c, manifest.txt, report.txt and
# report.tsv. check regenerates into memory and compares, byte for byte,
# with what is committed (exit 1 on any difference). report answers "why
# was NAME not generated?" from the committed report.tsv. build compiles
# the shim into its static library; stage copies an application's files
# and a binding into one application root; run stages a program with the
# binding, builds the shim and runs main.tcl on it -- the program is
# compiled by the ordinary compiler, from ordinary modules.

set here [file dirname [file normalize [info script]]]
set repo [file dirname $here]
foreach f {common.tcl toolchain.tcl cdecl.tcl ir.tcl macros.tcl macrocat.tcl pipeline.tcl} {
    source [file join $here cheader $f]
}
source [file join $repo surface surface.tcl]
foreach f {profile.tcl probe.tcl model.tcl emit.tcl report.tcl generate.tcl} {
    source [file join $here c-bindgen $f]
}

proc Usage {} {
    puts stderr "usage: tclsh9.0 tools/c-bindgen.tcl profiles|fetch|generate|check|report|build|stage|run|diff PROFILE ?options? (C-BINDGEN.md)"
    exit 2
}

proc Options {args defaults} {
    set options $defaults
    set rest {}
    while {[llength $args]} {
        set args [lassign $args k]
        if {[dict exists $defaults $k]} {
            if {![llength $args]} { error "c-bindgen: $k needs a value" }
            set args [lassign $args v]
            dict set options $k $v
        } else {
            lappend rest $k
        }
    }
    return [list $options $rest]
}

# The targets an option -target names for PROFILE: one, or all of the
# profile's. The default is the host's when the profile has it, else the
# profile's first.
proc Targets {profile value} {
    if {$value eq "all"} { return [dict get $profile targets] }
    if {$value ne ""} { return [list $value] }
    set host [core::cabi::hostTarget]
    if {$host in [dict get $profile targets]} { return [list $host] }
    return [list [lindex [dict get $profile targets] 0]]
}

proc Generate {name args} {
    lassign [Options $args {-target "" -out "" -bool 1 -evidence "" -timing 0 -fetch 0}] o rest
    if {$rest ne ""} { error "c-bindgen generate: unexpected [join $rest { }]" }
    set profile [::cbind::profile::load $name]
    set failed 0
    foreach target [Targets $profile [dict get $o -target]] {
        set t0 [clock milliseconds]
        if {[catch {::cbind::generate::run $profile $target [dict create bool [dict get $o -bool] \
                evidence [dict get $o -evidence] fetch [dict get $o -fetch]]} result options]} {
            # One target that cannot be generated here (no target sysroot)
            # does not stop the others.
            puts stderr "[dict get $profile name] $target: FAILED: [lindex [split $result \n] 0]"
            if {[llength [split $result \n]] > 1} { puts stderr [join [lrange [split $result \n] 1 12] \n] }
            set failed 1
            continue
        }
        set dir [expr {[dict get $o -out] ne "" ? [file join [dict get $o -out] $target] : [::cbind::profile::outputDir $profile $target]}]
        ::cbind::generate::write [dict get $result files] $dir [dict get $profile name]
        set c [::cbind::report::counts [dict get $result model]]
        puts "[dict get $profile name] $target: [dict get $c direct] direct, [dict get $c alias] alias, [dict get $c thunk] thunk, [dict get $c unsupported] unsupported, [dict get $c constants] constants -> $dir ([expr {[clock milliseconds] - $t0}] ms)"
        if {[dict get $o -timing]} {
            dict for {k v} [dict get $result timing] { puts "  $k $v s" }
        }
    }
    if {$failed} { exit 1 }
}

proc Check {name args} {
    lassign [Options $args {-target all -dir "" -bool 1}] o rest
    set profile [::cbind::profile::load $name]
    set failed 0
    foreach target [Targets $profile [dict get $o -target]] {
        set dir [expr {[dict get $o -dir] ne "" ? [file join [dict get $o -dir] $target] : [::cbind::profile::outputDir $profile $target]}]
        set result [::cbind::generate::run $profile $target [dict create bool [dict get $o -bool]]]
        set diffs [::cbind::generate::compare [dict get $result files] $dir [dict get $profile name]]
        if {![llength $diffs]} {
            puts "[dict get $profile name] $target: current ([dict size [dict get $result files]] files in $dir)"
            continue
        }
        set failed 1
        puts "[dict get $profile name] $target: STALE ([llength $diffs] file(s) differ from what generation produces; run generate)"
        foreach d $diffs {
            lassign $d path status detail
            puts "  $status $path"
            if {$detail ne ""} { puts "    $detail" }
        }
        CoverageChange $dir $result
    }
    exit $failed
}

# The coverage change between the committed report.tsv in DIR and RESULT's:
# names whose status changed, appeared or disappeared.
proc CoverageChange {dir result} {
    set path [file join $dir report.tsv]
    if {![file exists $path]} return
    set old [ReadTsv [::chdr::readFile $path]]
    set new [ReadTsv [dict get $result files report.tsv]]
    set lines {}
    dict for {key row} $new {
        if {![dict exists $old $key]} {
            lappend lines "  + $key: [lindex $row 2] [lindex $row 4]"
        } elseif {[lindex [dict get $old $key] 2] ne [lindex $row 2] || [lindex [dict get $old $key] 4] ne [lindex $row 4]} {
            lappend lines "  ~ $key: [lindex [dict get $old $key] 2] [lindex [dict get $old $key] 4] -> [lindex $row 2] [lindex $row 4]"
        }
    }
    dict for {key row} $old {
        if {![dict exists $new $key]} { lappend lines "  - $key: was [lindex $row 2] [lindex $row 4]" }
    }
    if {[llength $lines]} {
        puts "  coverage change ([llength $lines] name(s)):"
        puts [join [lrange $lines 0 60] \n]
        if {[llength $lines] > 61} { puts "  ... [expr {[llength $lines] - 61}] more" }
    }
}

proc ReadTsv {text} {
    set out [dict create]
    foreach line [lrange [split [string trimright $text \n] \n] 1 end] {
        set row [split $line \t]
        dict set out "[lindex $row 0] [lindex $row 1]" $row
    }
    return $out
}

proc Report {name args} {
    lassign [Options $args {-target "" -why "" -status "" -reason "" -dir ""}] o rest
    set profile [::cbind::profile::load $name]
    set target [lindex [Targets $profile [dict get $o -target]] 0]
    set dir [expr {[dict get $o -dir] ne "" ? [file join [dict get $o -dir] $target] : [::cbind::profile::outputDir $profile $target]}]
    set path [file join $dir report.tsv]
    if {![file exists $path]} { error "c-bindgen report: no $path (run generate)" }
    set rows [ReadTsv [::chdr::readFile $path]]
    if {[dict get $o -why] ne ""} {
        set found 0
        dict for {key row} $rows {
            lassign $row kind n status module reason detail
            if {$n ne [dict get $o -why]} continue
            set found 1
            switch -- $status {
                direct - alias - thunk - constant - scalar - opaque - callback - pointer {
                    puts "$kind $n: generated ($status[expr {$module ne "" ? " in $module" : ""}]): $reason; $detail"
                }
                default {
                    puts "$kind $n: not generated ($status): $reason"
                    foreach d [split $detail ";"] { puts "  [string trim $d]" }
                }
            }
        }
        if {!$found} { puts "[dict get $o -why]: not a public name of [dict get $profile name] on $target (no row in $path)" }
        return
    }
    if {[dict get $o -status] ne "" || [dict get $o -reason] ne ""} {
        dict for {key row} $rows {
            lassign $row kind n status module reason detail
            if {[dict get $o -status] ne "" && $status ne [dict get $o -status]} continue
            if {[dict get $o -reason] ne "" && [lsearch -exact [split $reason ,] [dict get $o -reason]] < 0} continue
            puts "$kind $n\t$status\t$reason\t$detail"
        }
        return
    }
    puts -nonewline [::chdr::readFile [file join $dir report.txt]]
}

# Compiles the committed shim.c of PROFILE/TARGET into its static library
# lib<shim_library>.a in DIR; prints DIR ("" when the binding has no shim).
proc Build {name args} {
    lassign [Options $args {-target "" -out "" -dir ""}] o rest
    set profile [::cbind::profile::load $name]
    set target [lindex [Targets $profile [dict get $o -target]] 0]
    set lib [BuildShim $profile $target [dict get $o -out] [dict get $o -dir]]
    puts $lib
}

proc BuildShim {profile target out {dir ""}} {
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
    set tool [::cbind::generate::ToolProfile $hprofile $sourceRoot]
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
# the application modules beside it) and the binding of PROFILE/TARGET into
# INTO: one application root, compiled by the ordinary compiler.
proc Stage {name args} {
    lassign [Options $args {-target "" -app "" -into "" -dir ""}] o rest
    set profile [::cbind::profile::load $name]
    set target [lindex [Targets $profile [dict get $o -target]] 0]
    StageInto $profile $target [dict get $o -app] [dict get $o -into] [dict get $o -dir]
    puts [dict get $o -into]
}

proc StageInto {profile target app into {dir ""}} {
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

# Runs PROGRAM against the generated binding of PROFILE/TARGET: stages
# PROGRAM's directory and the binding in a private application root, builds
# the shim there, and runs main.tcl with -L for it and any -L given.
proc Run {name args} {
    lassign [Options $args {-target "" -dir ""}] o rest
    set profile [::cbind::profile::load $name]
    set target [lindex [Targets $profile [dict get $o -target]] 0]
    set program [lindex $rest 0]
    set mainArgs [lrange $rest 1 end]
    if {$program eq ""} { error "c-bindgen run: no program" }
    set root [file tempdir]
    try {
        StageInto $profile $target $program $root [dict get $o -dir]
        set lib [BuildShim $profile $target [file join $root .shim] [dict get $o -dir]]
        set extra {}
        if {$lib ne ""} { lappend extra -L $lib }
        set status [catch {exec [info nameofexecutable] [file join $::repo main.tcl] {*}$extra {*}$mainArgs \
            [file join $root [file tail $program]] >@stdout 2>@stderr} message]
        if {$status} { puts stderr $message; exit 1 }
    } finally {
        file delete -force $root
    }
}

proc Fetch {name args} {
    set profile [::cbind::profile::load $name]
    puts [::cbind::profile::sourceRoot $profile 1]
}

# The differences between two targets' generated bindings of PROFILE:
# names whose status or meaning differ, and names only one target has.
proc Diff {name args} {
    lassign [Options $args {-targets "" -dir ""}] o rest
    set profile [::cbind::profile::load $name]
    set targets [split [string map {, " "} [dict get $o -targets]]]
    set targets [lsearch -all -inline -not -exact $targets ""]
    if {$targets eq ""} { set targets [dict get $profile targets] }
    set base [lindex $targets 0]
    set baseDir [expr {[dict get $o -dir] ne "" ? [file join [dict get $o -dir] $base] : [::cbind::profile::outputDir $profile $base]}]
    set baseRows [ReadTsv [::chdr::readFile [file join $baseDir report.tsv]]]
    foreach other [lrange $targets 1 end] {
        set dir [expr {[dict get $o -dir] ne "" ? [file join [dict get $o -dir] $other] : [::cbind::profile::outputDir $profile $other]}]
        set rows [ReadTsv [::chdr::readFile [file join $dir report.tsv]]]
        set lines {}
        dict for {key row} $baseRows {
            if {![dict exists $rows $key]} {
                lappend lines "only on $base: $key ([lindex $row 2] [lindex $row 4])"
            } elseif {[lrange [dict get $rows $key] 2 end] ne [lrange $row 2 end]} {
                set r [dict get $rows $key]
                lappend lines "differs: $key: $base [lindex $row 2] [lindex $row 4] [lindex $row 5] | $other [lindex $r 2] [lindex $r 4] [lindex $r 5]"
            }
        }
        dict for {key row} $rows {
            if {![dict exists $baseRows $key]} { lappend lines "only on $other: $key ([lindex $row 2] [lindex $row 4])" }
        }
        puts "[dict get $profile name]: $base vs $other: [llength $lines] difference(s)"
        foreach l $lines { puts "  $l" }
        # Files compared with each one's own target name spelled away (it is
        # in every banner).
        set fileDiff {}
        set files [lsort -unique [concat [::cbind::generate::Existing $baseDir [dict get $profile name]] \
            [::cbind::generate::Existing $dir [dict get $profile name]]]]
        foreach f $files {
            if {$f in {manifest.txt report.txt report.tsv}} continue
            set a [expr {[file exists [file join $baseDir $f]] ? [string map [list $base TARGET] [::chdr::readFile [file join $baseDir $f]]] : ""}]
            set b [expr {[file exists [file join $dir $f]] ? [string map [list $other TARGET] [::chdr::readFile [file join $dir $f]]] : ""}]
            if {$a ne $b} { lappend fileDiff $f }
        }
        puts "  generated files differing beyond their target name: [llength $fileDiff][expr {[llength $fileDiff] ? " ([join $fileDiff {, }])" : ""}]"
    }
}

set command [lindex $argv 0]
switch -- $command {
    profiles { puts [join [::cbind::profile::names] \n] }
    fetch { Fetch {*}[lrange $argv 1 end] }
    generate { Generate {*}[lrange $argv 1 end] }
    check { Check {*}[lrange $argv 1 end] }
    report { Report {*}[lrange $argv 1 end] }
    build { Build {*}[lrange $argv 1 end] }
    stage { Stage {*}[lrange $argv 1 end] }
    run { Run {*}[lrange $argv 1 end] }
    diff { Diff {*}[lrange $argv 1 end] }
    default { Usage }
}
