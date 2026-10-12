# run.tcl -- runs Botlish golden test suites (GOLDEN-TEST-FRAMEWORK.md).
#
#   tclsh9.0 tests/golden/run.tcl [-backends interp,compile,cranelift-generic,cranelift]
#                                 [-lib DIR] [-quiet] [-names] [FILE.bot ...]
#
# A golden suite is an ordinary Botlish program (tests/golden/*.bot by
# default) that installs a `test::suite()` context, registers its tests by
# calling ordinary registration functions, and ends with `test::report()`: its
# value is the deterministic report, a List of lines ("PASS name", "FAIL name"
# plus indented "expected:", "actual:", "detail:" lines, then "P passed, F
# failed"). Nothing here knows tests: this script compiles each program once
# (warnings off, as the Tcl suite's harness does), runs it on every backend,
# checks that every backend produced the same report, and prints it.
#
# Botlish has no exit-status facility, so the report is interpreted here: the
# exit status is 1 when any report has a failed test, when a program's
# compilation or run fails (the runner was aborted: an internal or run-time
# failure no handler can catch, which is not a test result), or when the
# backends disagree; else 0.
#
# The backends: interp (the core IR on the reference interpreter), compile
# (the core IR on the Tcl compiler, as the Tcl suite's harness runs it),
# cranelift-generic and cranelift (native, from HIR); and, on request only,
# compile-hir (the Tcl compiler compiling the HIR itself: main.tcl's
# -backend compile).
#
# A suite may exclude backends it cannot run, with the reason, in its leading
# comment block ("# golden-exclude: cranelift-generic -- REASON"): the runner
# skips them for that suite and prints the exclusion (golden::exclusions).
#
# -lib DIR compiles against the library directory DIR instead of lib/ (a
# private, mutated copy: audit/golden/tools/). -names prints only the test
# names with their verdicts ("PASS name"/"FAIL name"), one per line, for
# tools that compare suites, after a "SUITE STATUS STATUS" line (ok,
# failed, aborted, disagree or compile-error) and a "SUITE STATIC rounds R
# builds B trials T mispredicted M compile SECONDS" line (the static
# decisions' economics, when the suite has static sites). -quiet prints one summary line
# per program and backend.

namespace eval golden {
    # How many cranelift-generic runs the specialized outcome stood in for.
    variable genericStandIns 0
}
set ::golden::here [file dirname [file normalize [info script]]]
set ::golden::root [file dirname [file dirname $::golden::here]]
# (A script that sources this file to use its procs -- tests/golden.test --
# has loaded the front end already: loading it again would reset its state.)
if {[info commands ::core::evalProgram] eq ""} {
    source [file join $::golden::root compiler compiler.tcl]
}
if {[info commands ::surface::readProgramFile] eq ""} {
    source [file join $::golden::root surface surface.tcl]
}
if {[info commands ::native::evalHir] eq ""} {
    source [file join $::golden::root native native.tcl]
}
# The Tcl backends evaluate Botlish calls as nested Tcl evaluations: the
# test suite's own limit (tests/golden.test), not tclsh's default 1000.
interp recursionlimit {} 100000


# Compiles the Botlish program at PATH once: {ok HIR SECONDS} or {error
# MESSAGE SECONDS}.
proc golden::compile {path} {
    set start [clock microseconds]
    if {[catch {surface::readProgramFile $path -warnings off} hir options]} {
        return [list error "$hir ([dict get $options -errorcode])" \
            [expr {([clock microseconds] - $start) / 1e6}]]
    }
    return [list ok $hir [expr {([clock microseconds] - $start) / 1e6}]]
}

# Compiles the Botlish program text SOURCE (as file FILENAME) once, like
# golden::compile.
proc golden::compileSource {source {filename suite.bot}} {
    set start [clock microseconds]
    if {[catch {surface::compile $source $filename -warnings off} hir options]} {
        return [list error "$hir ([dict get $options -errorcode])" \
            [expr {([clock microseconds] - $start) / 1e6}]]
    }
    return [list ok $hir [expr {([clock microseconds] - $start) / 1e6}]]
}

# Runs HIR on BACKEND: {lines LINES SECONDS} (the report's lines, a Tcl list)
# or {abort MESSAGE SECONDS}.
proc golden::run {hir backend} {
    set start [clock microseconds]
    set failed [catch {
        if {$backend in {cranelift cranelift-generic}} {
            native::evalHir $hir {*}[expr {$backend eq "cranelift-generic" ? {-specialize 0} : {}}]
        } elseif {$backend eq "compile-hir"} {
            core::compiler::evalHir $hir
        } else {
            set saved [core::useBackend]
            core::useBackend $backend
            try {
                core::evalProgram [hir::lower $hir]
            } finally {
                core::useBackend $saved
            }
        }
    } value options]
    set seconds [expr {([clock microseconds] - $start) / 1e6}]
    if {$failed && $backend eq "cranelift-generic"
            && [dict get $options -errorcode] eq "NATIVE UNSUPPORTED struct-shape"} {
        # The unspecialized native baseline has no slot for a projection only
        # a semantic instance proves (tests/helpers.tcl's
        # GenericBaselineUndefined): undefined rather than wrong, and the
        # specialized outcome stands in for it, as in the Tcl suite.
        incr ::golden::genericStandIns
        return [run $hir cranelift]
    }
    if {$failed} {
        return [list abort "$value ([dict get $options -errorcode])" $seconds]
    }
    if {[catch {lmap item [core::value::items $value] {core::value::strOf $item}} lines]} {
        return [list abort "the program's value is not a report (a List of Strings): [core::value::show $value 1]" $seconds]
    }
    return [list lines $lines $seconds]
}

# The verdict lines ("PASS name" / "FAIL name") of report LINES.
proc golden::verdicts {lines} {
    return [lsearch -all -inline -regexp $lines {^(PASS|FAIL) }]
}

# {PASSED FAILED} from the report's last line, or "" if it has none.
proc golden::summary {lines} {
    if {[regexp {^(\d+) passed, (\d+) failed$} [lindex $lines end] -> passed failed]} {
        return [list $passed $failed]
    }
    return ""
}

# The backends the suite at PATH excludes, with why: a dict BACKEND ->
# REASON, from its header comment lines
#
#   # golden-exclude: BACKEND[,BACKEND...] -- REASON
#
# (LARGE-SCALE-GOLDEN-MIGRATION.md, "Backend exclusions"): a backend that
# cannot run some test of the suite for a recorded, legitimate reason (a
# construct it reports unsupported), never a backend that runs it wrongly. The
# lines are read from the suite's leading comment block only.
proc golden::exclusions {path} {
    set excluded [dict create]
    set f [open $path]
    fconfigure $f -encoding utf-8
    while {[gets $f line] >= 0} {
        if {![string match "#*" $line]} break
        if {[regexp {^#\s*golden-exclude:\s*([A-Za-z,\s-]+?)\s+--\s+(.+)$} $line -> list reason]} {
            foreach backend [split [string map {" " ""} $list] ,] {
                if {$backend ne ""} { dict set excluded $backend $reason }
            }
        }
    }
    close $f
    return $excluded
}

# Runs the suite at PATH on BACKENDS (minus those it excludes). Returns a
# dict: path, compile {ok|error ...}, outcomes {BACKEND {lines|abort ...}},
# excluded {BACKEND REASON ...}, status ok|failed|aborted|disagree|
# compile-error.
proc golden::suite {path backends} {
    set excluded [exclusions $path]
    set result [dict create path $path outcomes {} excluded {}]
    foreach backend $backends {
        if {[dict exists $excluded $backend]} {
            dict set result excluded $backend [dict get $excluded $backend]
        }
    }
    set backends [lmap backend $backends {expr {[dict exists $excluded $backend] ? [continue] : $backend}}]
    set compiled [compile $path]
    dict set result compile $compiled
    if {[lindex $compiled 0] ne "ok"} {
        dict set result status compile-error
        return $result
    }
    set hir [lindex $compiled 1]
    set before $::golden::genericStandIns
    foreach backend $backends {
        dict set result outcomes $backend [run $hir $backend]
    }
    dict set result standIns [expr {$::golden::genericStandIns - $before}]
    set status ok
    set reports [lsort -unique [lmap {b o} [dict get $result outcomes] {lrange $o 0 1}]]
    foreach {backend outcome} [dict get $result outcomes] {
        if {[lindex $outcome 0] eq "abort"} {
            set status aborted
        } elseif {[summary [lindex $outcome 1]] eq "" || [lindex [summary [lindex $outcome 1]] 1] != 0} {
            if {$status eq "ok"} { set status failed }
        }
    }
    if {[llength $reports] > 1} {
        set status disagree
    }
    dict set result status $status
    return $result
}

proc golden::main {argv} {
    set backends {interp compile cranelift-generic cranelift}
    set mode report
    set files {}
    for {set i 0} {$i < [llength $argv]} {incr i} {
        set arg [lindex $argv $i]
        switch -- $arg {
            -backends { set backends [split [lindex $argv [incr i]] ,] }
            -lib { set ::core::libraryDir [file normalize [lindex $argv [incr i]]] }
            -quiet { set mode quiet }
            -names { set mode names }
            default { lappend files $arg }
        }
    }
    if {$files eq ""} {
        set files [lsort [glob -directory $::golden::here *.bot]]
    }
    set exit 0
    foreach path $files {
        set result [suite $path $backends]
        set status [dict get $result status]
        if {$status ne "ok"} { set exit 1 }
        set name [file tail $path]
        if {$mode eq "names"} {
            puts "$name STATUS $status"
            if {[dict exists $result standIns] && [dict get $result standIns] > 0} {
                # The whole suite's cranelift-generic run was replaced by
                # cranelift's (golden::run): visible, so that a suite does not
                # lose its generic coverage silently.
                puts "$name STANDIN cranelift-generic"
            }
            # The static decisions' economics (hir/static.tcl's staticStats),
            # for the economics guard of audit/golden/tools/check.tcl.
            set compiled [dict get $result compile]
            if {[lindex $compiled 0] eq "ok" && [dict exists [lindex $compiled 1] staticStats]} {
                set stats [dict get [lindex $compiled 1] staticStats]
                puts "$name STATIC rounds [dict get $stats rounds] builds [dict get $stats builds] trials [dict get $stats methodTrials] mispredicted [llength [expr {[dict exists $stats mispredicted] ? [dict get $stats mispredicted] : {}}]] compile [format %.2f [lindex $compiled 2]]"
            }
        }
        if {$status eq "compile-error"} {
            puts "== $name: COMPILE ERROR [lindex [dict get $result compile] 1]"
            continue
        }
        set compileSeconds [lindex [dict get $result compile] 2]
        if {$mode eq "quiet"} {
            foreach {backend outcome} [dict get $result outcomes] {
                set text [expr {[lindex $outcome 0] eq "abort" ? "ABORTED [lindex $outcome 1]" : [lindex [lindex $outcome 1] end]}]
                puts [format "%-28s %-10s %s (compile %.2fs, run %.2fs)" $name $backend $text $compileSeconds [lindex $outcome 2]]
            }
            dict for {backend reason} [dict get $result excluded] {
                puts [format "%-28s %-10s excluded -- %s" $name $backend $reason]
            }
            if {$status eq "disagree"} { puts "$name: BACKENDS DISAGREE" }
            continue
        }
        set first [lindex [dict get $result outcomes] 1]
        if {$mode eq "names"} {
            # One verdict per test over every backend that produced a
            # report: FAIL if it failed on any of them, so a test that fails
            # on one backend only is told apart from the suite's own state.
            set order {}
            set verdictOf [dict create]
            foreach {backend outcome} [dict get $result outcomes] {
                if {[lindex $outcome 0] ne "lines"} continue
                foreach line [verdicts [lindex $outcome 1]] {
                    regexp {^(PASS|FAIL) (.*)$} $line -> verdict test
                    if {![dict exists $verdictOf $test]} {
                        lappend order $test
                        dict set verdictOf $test $verdict
                    } elseif {$verdict eq "FAIL"} {
                        dict set verdictOf $test FAIL
                    }
                }
            }
            if {$order eq {}} {
                puts "$name ABORTED"
            }
            foreach test $order { puts "$name [dict get $verdictOf $test] $test" }
            continue
        }
        set ran [dict keys [dict get $result outcomes]]
        puts "== $name ([join $ran {, }]; compile [format %.2f $compileSeconds]s)"
        dict for {backend reason} [dict get $result excluded] {
            puts "   excluded: $backend -- $reason"
        }
        if {[lindex $first 0] eq "lines"} {
            puts [join [lindex $first 1] \n]
        }
        foreach {backend outcome} [dict get $result outcomes] {
            if {[lindex $outcome 0] eq "abort"} {
                puts "ABORTED on $backend: [lindex $outcome 1]"
            }
        }
        if {$status eq "disagree"} {
            foreach {backend outcome} [dict get $result outcomes] {
                puts "-- $backend: [lrange $outcome 0 1]"
            }
            puts "BACKENDS DISAGREE"
        }
    }
    return $exit
}

if {[info script] eq $::argv0} {
    exit [golden::main $argv]
}
