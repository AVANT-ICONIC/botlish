# golden-framework.tcl -- the performance report of the golden test
# framework, lib/test.bot (GOLDEN-TEST-FRAMEWORK.md, "Performance").
#
#   tclsh9.0 bench/golden-framework.tcl ?-runs N? ?-n N? ?-native-n N?
#                                       ?-sizes LIST? ?-backends LIST?
#                                       ?-parts {run alloc compile backend}?
#
# Run time (best of RUNS, compilation excluded): a suite registering N cases
# in a loop -- one body closure per case, created in the loop, so the program
# text and its compile cost do not grow with N -- of one kind:
#
#   registration  N value cases registered, none run (the value is the count)
#   pass          N passing value cases, run (test::results), no report text
#   pass+report   the same, with the report (test::report)
#   mismatch      N value cases whose value differs, with the report
#   rejects       N rejects cases whose block is rejected (the expected
#                 diagnostic), with the report
#   rejects-wrong-code
#                 N rejects cases whose block is rejected with another
#                 code than the expected one (a compiler-error mismatch)
#   rejected      N value cases whose block is rejected (an unexpected
#                 diagnostic: the mismatch names code, location, message)
#   runtime-error N value cases whose body handles a run-time IndexNotFound
#   baseline      no framework: the same N body closures created and called
#                 directly, their values compared by ==
#
# reported per case as (T(kind, N) - T(empty suite)) / N, on the Tcl
# interpreter, the Tcl compiler and natively (native::measure, in-process
# best of RUNS; N is -n on the Tcl backends, -native-n natively).
#
# Native heap allocations: one-time (the empty suite) and per case (the
# difference between 2 and 1 cases), by object kind and by the function that
# allocates (registration, the case's check closure, the runner coroutine,
# TestResult/Match, result collection, report text).
#
# Compile time (best of RUNS, surface::compile, warnings off): suites of K
# distinct cases (K from -sizes), each its own nested function and static
# block, all passing value cases and mixed (two thirds value cases, one
# third rejected blocks expected by test::rejects) -- the mixed suite twice,
# its bodies nested in the registration function and at the top level --
# beside the same bodies written as plain functions without the framework;
# with the number of whole builds the static decisions took.

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 200000

set runs 3
set n 200
set nativeN 2000
set sizes {10 50 100}
set backends {interp compile native}
set parts {run alloc compile backend}
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -n { set n $value }
        -native-n { set nativeN $value }
        -sizes { set sizes $value }
        -backends { set backends $value }
        -parts { set parts $value }
        default { error "unknown option $option" }
    }
}

# The body each kind's case runs and the registration it makes, in a loop
# over i (captured by the body, so nothing is decided statically).
set kinds {
    registration {test::value("t", i * 2, body)} {i + i} count
    pass {test::value("t", i * 2, body)} {i + i} results
    pass+report {test::value("t", i * 2, body)} {i + i} report
    mismatch {test::value("t", i * 2 + 1, body)} {i + i} report
    rejects {test::rejects("t", compiler::DiagnosticCode::Unbound, body)} {missing + i} report
    rejects-wrong-code {test::rejects("t", compiler::DiagnosticCode::Type, body)} {missing + i} report
    rejected {test::value("t", 0, body)} {missing + i} report
    runtime-error {test::value("t", -1, body)} {r = list::at(xs, i + 5):
    on IndexNotFound:
        -1
r} report
}

proc suiteProgram {registration body end count} {
    set final [dict get {count {test::count()} results {list::length(test::results())} report {list::length(test::report())}} $end]
    set body [string map [list \n "\n                "] $body]
    return [string map [list @REG@ $registration @BODY@ $body @FINAL@ $final @N@ $count] {import compiler
import list
import test

fn register_bench(xs: List[int], count: int):
    loop i from 0 to count:
        fn body() errors compiler::CompilerError:
            static compile:
                @BODY@
        @REG@

with context test::suite()
register_bench([1, 2], @N@)
@FINAL@
}]
}

proc baselineProgram {count} {
    return [string map [list @N@ $count] {import list

fn run_bench(count: int) -> int:
    passed = loop i from 0 to count:
        fn body() -> int:
            i + i
        if body() != i * 2:
            continue
        i
    list::length(passed)

run_bench(@N@)
}]
}

proc compileHir {text} {
    return [surface::compile $text bench.bot -warnings off]
}

# Best-of-RUNS microseconds running HIR on BACKEND.
proc runUs {hir backend} {
    if {$backend eq "native"} {
        return [lindex [native::measure $hir $::runs] 2]
    }
    set saved [core::useBackend]
    if {$backend eq "compile"} {
        # The Tcl compiler compiles the HIR itself, once.
        set run [list core::compiler::evalUnit [core::compiler::compileHir $hir]]
    } else {
        core::useBackend $backend
        set run [list core::evalProgram [hir::lower $hir]]
    }
    set best ""
    try {
        for {set i 0} {$i < $::runs} {incr i} {
            set us [lindex [time {{*}$run}] 0]
            if {$best eq "" || $us < $best} { set best $us }
        }
    } finally {
        core::useBackend $saved
    }
    return $best
}

proc fmt {us} {
    if {$us >= 1000} { return [format "%.1f ms" [expr {$us / 1000.0}]] }
    return [format "%.2f us" $us]
}

puts "# golden test framework performance\n"
puts "runs $runs (best of); Tcl backends N = $n cases, native N = $nativeN cases\n"

# ---------------------------------------------------------------------------
if {"run" in $parts} {
puts "## Run time per case\n"
puts "| kind | [join $backends { | }] |"
puts "|---|[string repeat ---| [llength $backends]]"
set empty [dict create]
foreach backend $backends {
    set count [expr {$backend eq "native" ? $nativeN : $n}]
    dict set empty $backend [runUs [compileHir [suiteProgram {test::value("t", i * 2, body)} {i + i} report 0]] $backend]
}
foreach {kind registration body end} $kinds {
    set cells {}
    foreach backend $backends {
        set count [expr {$backend eq "native" ? $nativeN : $n}]
        set hir [compileHir [suiteProgram $registration $body $end $count]]
        set us [runUs $hir $backend]
        lappend cells [fmt [expr {($us - [dict get $empty $backend]) / double($count)}]]
    }
    puts "| $kind | [join $cells { | }] |"
}
set cells {}
foreach backend $backends {
    set count [expr {$backend eq "native" ? $nativeN : $n}]
    set us [runUs [compileHir [baselineProgram $count]] $backend]
    set zero [runUs [compileHir [baselineProgram 0]] $backend]
    lappend cells [fmt [expr {($us - $zero) / double($count)}]]
}
puts "| baseline (no framework) | [join $cells { | }] |"
puts "| empty suite (whole run) | [join [lmap b $backends {fmt [dict get $empty $b]}] { | }] |"
}

# ---------------------------------------------------------------------------
if {"alloc" in $parts} {
puts "\n## Native heap allocations\n"
proc census {text} {
    set hir [compileHir $text]
    return [native::allocationReport $hir sites]
}
proc kindsOf {report} {
    set out {}
    dict for {kind stats} [dict get $report byKind] {
        if {[dict get $stats allocations] > 0} {
            lappend out "$kind [dict get $stats allocations]"
        }
    }
    return [join $out ", "]
}
proc byFunction {report} {
    set out [dict create]
    foreach site [dict get $report sites] {
        set f [dict get $site func]
        regsub {#\d+$} $f "" f
        dict incr out "$f [dict get $site objectKind]" [dict get $site allocations]
    }
    return $out
}
puts "| program | allocations | bytes | by kind |"
puts "|---|---|---|---|"
foreach {kind registration body end} $kinds {
    if {$kind ni {registration pass pass+report mismatch rejects rejects-wrong-code rejected runtime-error}} continue
    foreach count {0 1 2} {
        set report [census [suiteProgram $registration $body $end $count]]
        dict set allocs $kind $count $report
    }
    set r0 [dict get $allocs $kind 0]
    set r1 [dict get $allocs $kind 1]
    set r2 [dict get $allocs $kind 2]
    set one [dict get $r0 total allocations]
    set per [expr {[dict get $r2 total allocations] - [dict get $r1 total allocations]}]
    set perBytes [expr {[dict get $r2 total allocatedBytes] - [dict get $r1 total allocatedBytes]}]
    puts "| $kind: one-time (empty suite) | $one | [dict get $r0 total allocatedBytes] | [kindsOf $r0] |"
    puts "| $kind: per case | $per | $perBytes | |"
}
puts "\nPer-case allocation sites (2 cases minus 1 case), by function and object kind:\n"
foreach kind {registration pass+report mismatch rejected} {
    set f1 [byFunction [dict get $allocs $kind 1]]
    set f2 [byFunction [dict get $allocs $kind 2]]
    set lines {}
    dict for {key count} $f2 {
        set before [expr {[dict exists $f1 $key] ? [dict get $f1 $key] : 0}]
        if {$count - $before != 0} {
            lappend lines "$key: [expr {$count - $before}]"
        }
    }
    puts "* $kind: [join $lines {; }]"
}
set reportZero [dict get $allocs registration 0]
puts "\nStatic data (one-time, program constants): [dict get $reportZero static allocations] allocations, [dict get $reportZero static bytes] bytes"
if {[dict exists [dict get $allocs pass+report 2] coroutines]} {
    puts "Runner coroutine (pass+report, 2 cases): [dict get [dict get $allocs pass+report 2] coroutines]"
}
}

# ---------------------------------------------------------------------------

# The body lines (at INDENT spaces) and expected code of the I-th rejected
# block of kind REJECTION: unbound, a name the resolution rejects (every
# such block is decided in one round), or type, a typed call the checker
# rejects (decided one per round within a top-level unit).
proc rejectedBody {rejection i indent} {
    set pad [string repeat " " $indent]
    if {$rejection eq "unbound"} {
        return [list [list "${pad}missing_$i + 7"] Unbound]
    }
    return [list [list "${pad}fn want_${i}(x: int) -> int:" "${pad}    x" "${pad}want_${i}(\"s\")"] Type]
}

# A suite of K distinct cases; REJECTION (none, unbound or type): every
# third is a rejected block of that kind.
proc distinctSuite {k rejection} {
    set lines {"import compiler" "import test" "" "fn register_bench(n: int):"}
    if {$k == 0} {
        lappend lines "    return"
    }
    for {set i 0} {$i < $k} {incr i} {
        lappend lines "    fn body_${i}() errors compiler::CompilerError:" "        static compile:"
        if {$rejection ne "none" && $i % 3 == 2} {
            lassign [rejectedBody $rejection $i 12] body code
            lappend lines {*}$body "    test::rejects(\"t$i\", compiler::DiagnosticCode::$code, body_${i})"
        } else {
            lappend lines "            n * $i + $i" "    test::value(\"t$i\", 7 * $i + $i, body_${i})"
        }
    }
    lappend lines "" "with context test::suite()" "register_bench(7)" "test::report()" ""
    return [join $lines \n]
}
# The same suite with every body a top-level function (the layout
# tests/golden/README.md recommends: rejected blocks in separate top-level
# units are decided together); the registrations stay in one function.
proc hoistedSuite {k rejection} {
    set lines {"import compiler" "import test" ""}
    set registrations {}
    for {set i 0} {$i < $k} {incr i} {
        lappend lines "fn body_${i}() errors compiler::CompilerError:" "    static compile:"
        if {$rejection ne "none" && $i % 3 == 2} {
            lassign [rejectedBody $rejection $i 8] body code
            lappend lines {*}$body ""
            lappend registrations "    test::rejects(\"t$i\", compiler::DiagnosticCode::$code, body_${i})"
        } else {
            lappend lines "        7 * $i + $i" ""
            lappend registrations "    test::value(\"t$i\", 7 * $i + $i, body_${i})"
        }
    }
    if {$k == 0} {
        lappend registrations "    return"
    }
    lappend lines "fn register_bench():" {*}$registrations "" "with context test::suite()" "register_bench()" "test::report()" ""
    return [join $lines \n]
}
proc plainProgram {k} {
    set lines {"fn run_all(n: int):"}
    set names {}
    for {set i 0} {$i < $k} {incr i} {
        lappend lines "    fn body_${i}() -> int:" "        n * $i + $i"
        lappend names "body_${i}()"
    }
    lappend lines "    \[[join $names {, }]\]" "" "run_all(7)" ""
    return [join $lines \n]
}
proc compileStats {text} {
    set best ""
    set builds 0
    for {set i 0} {$i < $::runs} {incr i} {
        set ::buildCount 0
        set us [lindex [time {surface::compile $text bench.bot -warnings off}] 0]
        if {$best eq "" || $us < $best} { set best $us; set builds $::buildCount }
    }
    return [list [expr {$best / 1000.0}] $builds]
}
rename hir::BuildOnce hir::BuildOnce__bench
proc hir::BuildOnce {args} {
    incr ::buildCount
    tailcall hir::BuildOnce__bench {*}$args
}
if {"compile" in $parts} {
puts "\n## Compile time\n"
puts "Mixed suites: every third case a rejected block, an unbound name (UNBOUND, decided at resolution) or a typed call with a String (TYPE, decided by the checker); bodies nested in the registration function or each at the top level. Builds: whole-program builds (hir::BuildOnce), the static decision rounds' and the method-sugar decisions'.\n"
puts "| K cases | plain functions, no framework | all passing | builds | UNBOUND, nested | builds | UNBOUND, top level | builds | TYPE, nested | builds | TYPE, top level | builds |"
puts "|---|---|---|---|---|---|---|---|---|---|---|---|"
set libOnly [lindex [compileStats [distinctSuite 0 none]] 0]
foreach k $sizes {
    lassign [compileStats [plainProgram $k]] plain plainBuilds
    set cells [list [format "%.1f ms" $plain]]
    foreach {make rejection} {distinctSuite none distinctSuite unbound hoistedSuite unbound distinctSuite type hoistedSuite type} {
        lassign [compileStats [$make $k $rejection]] ms builds
        lappend cells [format "%.1f ms" $ms] $builds
    }
    puts "| $k | [join $cells { | }] |"
}
puts [format "\nThe library alone (a suite of no case): %.1f ms." $libOnly]
}

# ---------------------------------------------------------------------------
if {"backend" in $parts} {
puts "\n## Back ends: code generation and execution\n"
puts "The front end (surface::compile, once), then natively (native::measure, best of $runs runs): NIR lowering, Cranelift code generation and one execution of the whole program; on the Tcl backends one whole run, best of $runs (the Tcl compiler's code generation included: it is not separable from the run).\n"
puts "| program | front end | NIR lowering | Cranelift codegen | native execution | Tcl interpreter run | Tcl compiler run |"
puts "|---|---|---|---|---|---|---|"
proc backendRow {label hir frontUs} {
    lassign [native::measure $hir $::runs] lower compile best
    set interp [runUs $hir interp]
    set tclCompile [runUs $hir compile]
    puts "| $label | [fmt $frontUs] | [fmt $lower] | [fmt $compile] | [fmt $best] | [fmt $interp] | [fmt $tclCompile] |"
}
foreach k $sizes {
    set text [distinctSuite $k none]
    set us [lindex [time {set hir [compileHir $text]}] 0]
    backendRow "$k passing cases" $hir $us
}
foreach path [lsort [glob -directory [file join $root tests golden] *.bot]] {
    set us [lindex [time {set hir [surface::readProgramFile $path -warnings off]}] 0]
    backendRow [file tail $path] $hir $us
}
}
