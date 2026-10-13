#!/usr/bin/env tclsh9.0
# static-decisions.tcl -- the decision economics of `static compile:`
# (STATIC-COMPILE.md, "Decision economics"): how many whole-program builds
# deciding a program's static sites takes, against the program's shape.
#
#   tclsh9.0 bench/static-decisions.tcl ?-runs N? ?-sizes LIST? ?-parts LIST?
#                                       ?-schedulers LIST? ?-check 0|1?
#                                       ?-files LIST?
#
# For each workload program, under each scheduler of SCHEDULERS (batched,
# the default; legacy, the procedure before the economics milestone;
# sequential, the reference): the static decision rounds, the whole-program
# builds (every hir::BuildOnce: the rounds' and the method-call decisions'
# trial and final builds), the method trial builds among them, and the
# front-end time (surface::compile, warnings off, best of RUNS). With
# -check 1 every scheduler's decided program must equal the first's
# (audit/static-decisions/tools/lib.tcl's sdDiff).
#
# Builds are counted by wrapping hir::BuildOnce, so the script also measures
# a tree that predates the schedulers (it then reports one column, "tree").
#
# Workloads (PARTS):
#
#   golden    the golden framework's K-case suites (bench/golden-framework.tcl's
#             generator): all passing; every third case rejected with UNBOUND or
#             with TYPE; the bodies nested in one registration function or each
#             at the top level
#   mixed     independent sites rejected at different stages (UNBOUND, TYPE,
#             USE-AFTER-MOVE, KNOWN-ERROR, UNHANDLED-ERROR, a trait and a context
#             diagnostic), nested and top level
#   chain     genuinely dependent sites: nested blocks whose rejection each
#             rejects the block around it; and sites in one function's
#             statement sequence
#   erased    independent TYPE failures beside one accepted body that erases an
#             error-bearing callable and a few genuine consumers; several
#             contributors; a contributor rejected before the checker
#   contract  callback registries through verified structural Fn contracts
#             (struct fields, vector elements, structural parameters): no
#             consumer of the erased-callable contract
#   probes    an ordinary application: optional-feature probes and adapters
#   methods   method-style calls with several candidates in many blocks
#   files     program files (FILES; default: the golden suites)

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
set runs 1
set sizes {10 50 100}
set parts {golden mixed chain erased contract probes methods}
set schedulers {}
set check 0
set files {}
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -sizes { set sizes $value }
        -parts { set parts $value }
        -schedulers { set schedulers $value }
        -check { set check $value }
        -files { set files $value }
        default { error "unknown option $option" }
    }
}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 200000
set scheduled [expr {[info exists hir::static::scheduler]}]
if {$schedulers eq ""} {
    set schedulers [expr {$scheduled ? {batched legacy} : {tree}}]
}
if {$check} {
    set ::sdRoot $root
    source [file join $root audit static-decisions tools lib.tcl]
}

# Build counting (works on any tree).
set ::count [dict create builds 0 trials 0]
rename hir::BuildOnce hir::BuildOnce__count
proc hir::BuildOnce {args} {
    dict incr ::count builds
    tailcall hir::BuildOnce__count {*}$args
}
# A method-call trial is a DecideMethodCalls build that is not its last (a
# tree that predates the schedulers always ends it with a final build; a
# later one reports its trials itself, in staticStats).
rename hir::DecideMethodCalls hir::DecideMethodCalls__count
proc hir::DecideMethodCalls {args} {
    set before [dict get $::count builds]
    set result [hir::DecideMethodCalls__count {*}$args]
    set inside [expr {[dict get $::count builds] - $before}]
    if {$inside > 1} {
        dict incr ::count trials [expr {$inside - 1}]
    }
    return $result
}

# {ms builds trials rounds sites accepted rejected} of compiling SOURCE under
# SCHEDULER (best time of RUNS; counts from the best run).
proc measure {scheduler source} {
    set best ""
    for {set i 0} {$i < $::runs} {incr i} {
        if {$::scheduled} {
            set hir::static::scheduler $scheduler
        }
        set ::count [dict create builds 0 trials 0]
        set us [lindex [time {set hir [surface::compile $source bench.bot -strict 0 -warnings off]}] 0]
        if {$best eq "" || $us < [lindex $best 0]} {
            set accepted 0
            set rejected 0
            dict for {key site} [hir::static::sites $hir] {
                if {[dict get $site outcome] eq "rejected"} { incr rejected } else { incr accepted }
            }
            set rounds [expr {[dict exists $hir staticRounds] ? [dict get $hir staticRounds] : 0}]
            set trials [dict get $::count trials]
            if {[dict exists $hir staticStats]} {
                set trials [dict get $hir staticStats methodTrials]
            }
            set best [list $us [dict get $::count builds] $trials $rounds \
                [dict size [hir::static::sites $hir]] $accepted $rejected]
        }
    }
    if {$::scheduled} {
        set hir::static::scheduler batched
    }
    return $best
}

proc row {label source} {
    set cells {}
    set first ""
    foreach s $::schedulers {
        lassign [measure $s $source] us builds trials rounds sites accepted rejected
        lappend cells "$rounds/$builds/$trials" [format "%.2f s" [expr {$us / 1e6}]]
    }
    set problem ""
    if {$::check && [llength $::schedulers] > 1} {
        set base [sdCompile [lindex $::schedulers 0] $source bench.bot]
        foreach s [lrange $::schedulers 1 end] {
            set diff [sdDiff $base [sdCompile $s $source bench.bot] [expr {$s eq "legacy"}]]
            if {$diff ne ""} {
                set problem " **DISAGREE ($s): $diff**"
                set ::failed 1
            }
        }
    }
    puts "| $label | $sites | $accepted | $rejected | [join $cells { | }] |$problem"
    flush stdout
}

proc header {title} {
    puts "\n## $title\n"
    set head "| program | sites | accepted | rejected |"
    set rule "|---|---|---|---|"
    foreach s $::schedulers {
        append head " $s rounds/builds/trials | $s time |"
        append rule "---|---|"
    }
    puts $head
    puts $rule
}

set ::failed 0

# ---------------------------------------------------------------------------
# golden: bench/golden-framework.tcl's suites

proc rejectedBody {rejection i indent} {
    set pad [string repeat " " $indent]
    if {$rejection eq "unbound"} {
        return [list [list "${pad}missing_$i + 7"] Unbound]
    }
    return [list [list "${pad}fn want_${i}(x: int) -> int:" "${pad}    x" "${pad}want_${i}(\"s\")"] Type]
}
proc nestedSuite {k rejection} {
    set lines {"import compiler" "import test" "" "fn register_bench(n: int):"}
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
proc topLevelSuite {k rejection} {
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
    lappend lines "fn register_bench():" {*}$registrations "" "with context test::suite()" "register_bench()" "test::report()" ""
    return [join $lines \n]
}

if {"golden" in $parts} {
    header "Golden framework suites (every third case rejected)"
    foreach k $sizes {
        row "$k cases, all passing" [nestedSuite $k none]
        row "$k cases, UNBOUND, nested" [nestedSuite $k unbound]
        row "$k cases, UNBOUND, top level" [topLevelSuite $k unbound]
        row "$k cases, TYPE, nested" [nestedSuite $k type]
        row "$k cases, TYPE, top level" [topLevelSuite $k type]
    }
}

# ---------------------------------------------------------------------------
# mixed: independent sites rejected at different stages

set mixedDecls {import compiler
import list

error Boom

trait Shape:
    fn area(shape: Shape) -> int

struct Square:
    side: int

fn area(s: Square) -> int:
    s.side * s.side

struct Thing:
    v: int

fn measure(s: Shape) -> int:
    area(s)

fn always() -> int errors Boom:
    fail Boom

fn producer():
    yield 1
    2

}
# The body (lines at INDENT) of the I-th site of a mixed program: one of the
# stages in turn, or (every other site) a valid block.
proc mixedBody {i pad} {
    if {$i % 2 == 0} {
        return [list "${pad}$i * 3"]
    }
    switch -- [expr {($i / 2) % 7}] {
        0 { return [list "${pad}missing_$i + 1"] }
        1 { return [list "${pad}fn want_${i}(x: int) -> int:" "${pad}    x" "${pad}want_${i}(\"s\")"] }
        2 { return [list "${pad}coroutine \{step\} = producer()" "${pad}other = step" "${pad}step()" "${pad}0"] }
        3 { return [list "${pad}r = always():" "${pad}    on Boom:" "${pad}        0" "${pad}r"] }
        4 { return [list "${pad}always()"] }
        5 { return [list "${pad}measure(Thing \{v: $i\})"] }
        6 { return [list "${pad}with context compiler::SourceLocation \{line: 1, column: 1\}" "${pad}0"] }
    }
}
proc mixedProgram {k nested} {
    set lines [split $::mixedDecls \n]
    set calls {}
    if {$nested} {
        lappend lines "fn run_all() -> int:"
        set pad "    "
    } else {
        set pad ""
    }
    for {set i 0} {$i < $k} {incr i} {
        lappend lines "${pad}fn probe_${i}() -> int errors compiler::CompilerError:" "${pad}    static compile:"
        lappend lines {*}[mixedBody $i "${pad}        "]
        lappend calls "r_$i = probe_${i}():" "    on compiler::CompilerError \{code\}:" "        -1"
    }
    if {$nested} {
        set body [lmap c $calls {string cat "    " $c}]
        lappend lines {*}$body "    [join [lmap i [lrepeat $k x] {string cat 0}] { + }]" "" "run_all()" ""
    } else {
        lappend lines {*}$calls "0" ""
    }
    return [join $lines \n]
}

if {"mixed" in $parts} {
    header "Mixed stages: independent sites rejected by resolution, the checker, ownership, completions, traits and contexts (every other site valid)"
    foreach k $sizes {
        row "$k sites, nested" [mixedProgram $k 1]
        row "$k sites, top level" [mixedProgram $k 0]
    }
}

# ---------------------------------------------------------------------------
# chain: genuine dependencies

# D blocks nested in each other: the innermost names an unbound name, and
# each block around it is a function that cannot admit the error its inner
# block completes with -- rejected (UNHANDLED-ERROR) only once the block
# inside it is.
proc nestedChain {d} {
    set lines {"import compiler" "" "fn outer() -> int errors compiler::CompilerError:"}
    set pad "    "
    for {set i 0} {$i < $d} {incr i} {
        lappend lines "${pad}static compile:" "${pad}    fn level_${i}() -> int:"
        set pad "$pad        "
    }
    lappend lines "${pad}missing"
    for {set i [expr {$d - 1}]} {$i >= 0} {incr i -1} {
        set pad [string range $pad 0 end-8]
        lappend lines "${pad}    level_${i}()"
    }
    lappend lines "" "r = outer():" "    on compiler::CompilerError:" "        0" "r" ""
    return [join $lines \n]
}
# K sites in one function's statement sequence, each rejected: each one's
# rejection makes the rest unreachable, so the next is judged without it.
proc sequenceChain {k} {
    set lines {"import compiler" "" "fn run() -> int errors compiler::CompilerError:"}
    for {set i 0} {$i < $k} {incr i} {
        lappend lines "    static compile:" "        missing_$i" "    static compile:" "        fn want_${i}(x: int) -> int:" "            x" "        want_${i}(\"s\")"
    }
    lappend lines "    0" "" "r = run():" "    on compiler::CompilerError:" "        0" "r" ""
    return [join $lines \n]
}

if {"chain" in $parts} {
    header "Genuine dependency chains"
    foreach d {2 5 10} {
        row "$d nested dependent blocks" [nestedChain $d]
    }
    foreach k {5 10} {
        row "$k UNBOUND + $k TYPE sites in one statement sequence" [sequenceChain $k]
    }
}

# ---------------------------------------------------------------------------
# erased: the erased-callable contract

set erasedDecls {import compiler

error E1
error E2

fn raise_e1() -> int errors E1:
    fail E1

fn raise_e2() -> int errors E2:
    fail E2

fn generic(f):
    f()

fn apply(f: Fn{args: [], return: int, errors: []}) -> int:
    f()

}
# K sites: CONTRIBUTORS accepted bodies that pass an error-bearing callable
# through an untyped parameter (handling the error), CONSUMERS bodies whose
# uncontracted call may raise what is erased, the rest independent TYPE
# failures and valid blocks. EARLY: the first contributor also names an
# unbound name (rejected before the checker: its erasure never counts).
proc erasedProgram {k contributors consumers early} {
    set lines [split $::erasedDecls \n]
    set calls {}
    for {set i 0} {$i < $k} {incr i} {
        lappend lines "fn site_${i}() -> int errors compiler::CompilerError:" "    static compile:"
        if {$i < $contributors} {
            set raiser [expr {$i % 2 == 0 ? "raise_e1" : "raise_e2"}]
            set err [expr {$i % 2 == 0 ? "E1" : "E2"}]
            if {$early && $i == 0} {
                lappend lines "        unbound_name"
            }
            lappend lines "        r = generic($raiser):" "            on $err:" "                0" "        r"
        } elseif {$i < $contributors + $consumers} {
            lappend lines "        fn call_${i}(f):" "            f()" "        fn one_${i}() -> int:" "            1" "        r = call_${i}(one_$i):" "            on E1:" "                0" "        r"
        } elseif {$i % 2 == 0} {
            lappend lines "        fn want_${i}(x: int) -> int:" "            x" "        want_${i}(\"s\")"
        } else {
            lappend lines "        fn give_${i}() -> int:" "            $i" "        apply(give_$i)"
        }
        lappend calls "r_$i = site_${i}():" "    on compiler::CompilerError:" "        -1"
    }
    lappend lines {*}$calls "0" ""
    return [join $lines \n]
}

if {"erased" in $parts} {
    header "The erased-callable contract: one contributor, a few consumers, many independent sites"
    foreach k $sizes {
        row "$k sites, 1 contributor, 2 consumers" [erasedProgram $k 1 2 0]
        row "$k sites, 4 contributors, 2 consumers" [erasedProgram $k 4 2 0]
        row "$k sites, contributor rejected early, 2 consumers" [erasedProgram $k 1 2 1]
    }
}

# ---------------------------------------------------------------------------
# contract: callback registries through verified structural contracts

set contractDecls {import compiler
import list

struct Handler:
    name: str
    run: Fn{args: [int], return: int, errors: []}

fn dispatch(h: Handler, x: int) -> int:
    (h.run)(x)

fn apply(f: Fn{args: [int], return: int, errors: []}, x: int) -> int:
    f(x)

}
proc contractProgram {k} {
    set lines [split $::contractDecls \n]
    set calls {}
    for {set i 0} {$i < $k} {incr i} {
        lappend lines "fn site_${i}() -> int errors compiler::CompilerError:" "    static compile:"
        switch -- [expr {$i % 4}] {
            0 { lappend lines "        fn add_${i}(x: int) -> int:" "            x + $i" "        dispatch(Handler \{name: \"h$i\", run: add_$i\}, 1)" }
            1 { lappend lines "        fn times_${i}(x: int) -> int:" "            x * $i" "        apply(times_$i, 2)" }
            2 { lappend lines "        fn want_${i}(x: int) -> int:" "            x" "        want_${i}(\"s\")" }
            3 { lappend lines "        missing_$i" }
        }
        lappend calls "r_$i = site_${i}():" "    on compiler::CompilerError:" "        -1"
    }
    lappend lines {*}$calls "0" ""
    return [join $lines \n]
}

if {"contract" in $parts} {
    header "Verified structural contracts (no erased-callable consumer)"
    foreach k $sizes {
        row "$k sites" [contractProgram $k]
    }
}

# ---------------------------------------------------------------------------
# probes: an ordinary application

proc probesProgram {k nested} {
    set lines {"import compiler" "import list" "" "struct Config:" "    level: int" ""}
    set pad [expr {$nested ? "    " : ""}]
    if {$nested} {
        lappend lines "fn detect() -> List\[bool\]:"
    }
    set names {}
    for {set i 0} {$i < $k} {incr i} {
        lappend lines "${pad}fn feature_${i}() -> int errors compiler::CompilerError:" "${pad}    static compile:"
        switch -- [expr {$i % 5}] {
            0 { lappend lines "${pad}        list::length(\[1, 2, $i\])" }
            1 { lappend lines "${pad}        optional_api_${i}(1)" }
            2 { lappend lines "${pad}        c = Config \{level: $i\}" "${pad}        c.level" }
            3 { lappend lines "${pad}        c = Config \{level: $i\}" "${pad}        c.verbosity" }
            4 { lappend lines "${pad}        fn adapt_${i}(x: str) -> int:" "${pad}            1" "${pad}        adapt_${i}($i)" }
        }
        lappend lines "${pad}fn has_${i}() -> bool:" "${pad}    r = feature_${i}():" "${pad}        on compiler::CompilerError:" "${pad}            -1" "${pad}    r >= 0"
        lappend names "has_${i}()"
    }
    if {$nested} {
        lappend lines "    \[[join $names {, }]\]" "" "detect()" ""
    } else {
        lappend lines "\[[join $names {, }]\]" ""
    }
    return [join $lines \n]
}

if {"probes" in $parts} {
    header "An application: optional-feature probes and adapters"
    foreach k $sizes {
        row "$k probes, nested in detect()" [probesProgram $k 1]
        row "$k probes, top level" [probesProgram $k 0]
    }
}

# ---------------------------------------------------------------------------
# methods: method-style calls with several candidates

proc methodsProgram {k} {
    set lines {"import compiler" "import list" "import str" ""}
    set calls {}
    for {set i 0} {$i < $k} {incr i} {
        lappend lines "fn site_${i}() -> int errors compiler::CompilerError:" "    static compile:"
        if {$i % 3 == 2} {
            lappend lines "        xs = \[1, 2, $i\]" "        fn want_${i}(x: int) -> int:" "            x" "        want_${i}(xs.length() == 3)"
        } else {
            lappend lines "        xs = \[1, 2, $i\]" "        s = \"abc\"" "        xs.length() + s.length()"
        }
        lappend calls "r_$i = site_${i}():" "    on compiler::CompilerError:" "        -1"
    }
    # A call outside every block whose receiver a block's decision changes.
    lappend lines "fn outside() -> int errors compiler::CompilerError:" "    xs = static compile:" "        \[1, missing_outside\]" "    xs.length()"
    lappend calls "r_out = outside():" "    on compiler::CompilerError:" "        -1"
    lappend lines {*}$calls "0" ""
    return [join $lines \n]
}

if {"methods" in $parts} {
    header "Method-style calls with several candidates in many blocks (every third rejected)"
    foreach k $sizes {
        row "$k sites" [methodsProgram $k]
    }
}

# ---------------------------------------------------------------------------
# files

if {"files" in $parts} {
    if {$files eq ""} {
        set files [lsort [glob -directory [file join $root tests golden] *.bot]]
    }
    header "Program files"
    foreach path $files {
        row [file tail $path] [core::ReadFile $path]
    }
}

exit $::failed
