#!/usr/bin/env tclsh9.0
# fuzz.tcl -- generated programs against the static decision schedulers
# (STATIC-COMPILE.md, "Decision economics").
#
#   tclsh9.0 audit/static-decisions/tools/fuzz.tcl ?-n N? ?-seed S? ?-sites MIN-MAX?
#                                                  ?-legacy 0|1? ?-dump DIR? ?-verbose 0|1?
#
# Each case is a *semantic test set*: MIN..MAX fragments, each the body of
# one `static compile:` block, drawn from the pool below -- valid blocks and
# blocks rejected at every stage (resolution, the checker, ownership,
# completions, opaque authority), nested blocks (an accepted one around a
# rejected one, and genuine chains: an inner rejection that rejects the
# block around it), the erased-callable contract's contributors (a block
# passing an error-bearing callable through an untyped parameter, accepted
# or rejected by the checker or by resolution) and its consumers (a call
# through an uncontracted parameter whose verdict depends on what the
# program erases), verified structural contracts (a callable through a Fn
# parameter, a struct field: never consumers), callers of one shared helper
# whose callable input is checked against what its calls pass (Possible),
# and method-style calls with several candidates. Every fragment is
# self-contained -- it captures nothing -- so its verdict is the same
# wherever its block stands.
#
# The set is written in four layouts:
#
#   nested    every block's function nested in one driver function
#   top       every block's function at the top level
#   split     the functions spread over three helper functions
#   deep      nested two levels deep (a driver inside a driver)
#
# and every program is compiled under the batched, sequential (and with
# -legacy 1, legacy) schedulers. For every program:
#
#   1. batched and sequential decide the same program exactly: every site's
#      outcome and reified diagnostic (code, primary, related, message), the
#      program's own diagnostics, the decided program's HIR text, and no
#      misprediction (sdDiff);
#   2. legacy agrees likewise, with internal ids in messages and the labels
#      of discarded sites blanked (its own schedule numbers them);
#   3. layout: the four layouts give every fragment the same verdict (its
#      outcome and diagnostic code, and the diagnostic's line and column
#      relative to the fragment) -- for a consumer of the erased-callable
#      contract too, because the sequential order judges it only once no
#      failing contributor remains, wherever the two are written (the
#      waiting rule, STATIC-COMPILE.md; the pool draws neither of its
#      residual cases, a cycle of failing blocks that each erase and consume
#      or an ok contributor a later rejection fails) -- and take the same number of
#      batched rounds -- except where a dependency runs one way (a consumer
#      on a contributor): the order a layout writes the two in decides
#      whether the second waits for a build, so layouts may differ by at
#      most one round fewer than the set has blocks the contract links (the
#      summary counts the programs where they differ);
#   4. economics: the batched rounds stay within the generator's own model of
#      the set's dependency depth -- a resolution round, one checked round,
#      one more per level of each genuine chain (a nested chain, the
#      erased-callable contract's rejected contributors and its consumers),
#      and the final build. It does not predict the optimum; it catches a
#      schedule that grows with the number of independent blocks.
#
# Prints one line per program and a summary; exits 1 on any failure. -dump
# writes every failing program (all layouts) into DIR.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set ::sdRoot $root
set n 20
set seed 1
set sitesRange {4 10}
set legacy 1
set dump ""
set verbose 0
set args $argv
set argv {}
foreach {option value} $args {
    switch -- $option {
        -n { set n $value }
        -seed { set seed $value }
        -sites { set sitesRange [split $value -] }
        -legacy { set legacy $value }
        -dump { set dump $value }
        -verbose { set verbose $value }
        default { error "unknown option $option" }
    }
}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root audit static-decisions tools lib.tcl]
interp recursionlimit {} 200000
expr {srand($seed)}

proc pick {list} {
    return [lindex $list [expr {int(rand() * [llength $list])}]]
}

# The declarations every program starts with.
set prelude {import std::compiler
import std::list
import std::str

error E1
error E2
error Boom

struct Box:
    v: int

struct Handler:
    run: Fn{args: [int], return: int, errors: []}

fn raise_e1() -> int errors E1:
    fail E1

fn raise_e2() -> int errors E2:
    fail E2

fn always() -> int errors Boom:
    fail Boom

fn generic(f):
    f()

fn apply(f: Fn{args: [int], return: int, errors: []}, x: int) -> int:
    f(x)

fn shared(cb, x: int) -> int:
    cb(x)

fn harmless() -> int:
    1

fn store(f) -> int:
    1

fn producer():
    yield 1
    2

}

# A fragment: {KIND LINES} -- LINES the block's body at indent 0, KIND the
# generator's class (valid, reject, chain, contributor, consumer, ...). The
# I is unique per fragment (names never collide).
proc fragment {kind i} {
    switch -- $kind {
        valid {
            return [pick [list \
                [list "$i * 3 + 1"] \
                [list "b = Box \{v: $i\}" "b.v"] \
                [list "xs = \[1, 2, $i\]" "std::list::length(xs)"]]]
        }
        unbound { return [list "missing_$i + 1"] }
        type { return [list "fn want_${i}(x: int) -> int:" "    x" "want_${i}(\"s\")"] }
        field { return [list "b = Box \{v: $i\}" "b.w"] }
        move { return [list "coroutine \{step\} = producer()" "other = step" "step()" "0"] }
        known { return [list "r = always():" "    on Boom:" "        0" "r"] }
        unhandled { return [list "raise_e1()"] }
        nestedok {
            # An accepted block around a rejected one on a branch that never
            # runs: only the innermost owner lets the outer one survive.
            return [list "fn inner_${i}(flag: bool) -> int errors std::compiler::CompilerError:" \
                "    if flag:" "        static compile:" "            missing_inner_$i" \
                "    else:" "        $i" \
                "r = inner_${i}(false):" "    on std::compiler::CompilerError:" "        -1" "r"]
        }
        chain {
            # An inner rejection whose CompilerError the function around it
            # cannot admit: the outer block is rejected once the inner is.
            return [list "fn level_${i}() -> int:" "    static compile:" "        missing_chain_$i" "level_${i}()"]
        }
        contributor {
            set e [pick {E1 E2}]
            set raiser [expr {$e eq "E1" ? "raise_e1" : "raise_e2"}]
            return [list "r = generic($raiser):" "    on $e:" "        0" "r"]
        }
        badcontributor {
            # Erases, but is rejected by the checker.
            return [list "r = generic(raise_e2):" "    on E2:" "        0" "fn want_${i}(x: int) -> int:" "    x" "want_${i}(\"s\")"]
        }
        earlycontributor {
            # Erases, but is rejected by resolution.
            return [list "r = generic(raise_e2):" "    on E2:" "        0" "missing_early_$i"]
        }
        consumer {
            # The erased-callable reproducer: E1 escapes `call_I` through its
            # untyped parameter; the handler admits E1 only, so the call is
            # charged whatever else the program erases.
            return [list "fn call_${i}(f):" "    f()" \
                "r = call_${i}(raise_e1):" "    on E1:" "        0" "r"]
        }
        contracted {
            return [pick [list \
                [list "fn add_${i}(x: int) -> int:" "    x + $i" "apply(add_$i, 2)"] \
                [list "fn add_${i}(x: int) -> int:" "    x + $i" "h = Handler \{run: add_$i\}" "(h.run)(1)"]]]
        }
        possible {
            set raiser [pick {plain raising}]
            if {$raiser eq "plain"} {
                return [list "fn cb_${i}(x: int) -> int:" "    x" "shared(cb_$i, $i)"]
            }
            return [list "fn cb_${i}(x: int) -> int errors Boom:" "    fail Boom" \
                "r = shared(cb_$i, $i):" "    on Boom:" "        0" "r"]
        }
        erasing {
            # Erases E2 (store's untyped parameter receives raise_e2), and
            # one time in two is rejected by the checker as well.
            if {rand() < 0.5} {
                return [list "r = store(raise_e2)" "r"]
            }
            return [list "r = store(raise_e2)" "fn want_${i}(x: int) -> int:" "    x" "want_${i}(\"s\")"]
        }
        anyconsumer {
            # A callable read from a List[any] has neither identity nor
            # contract: its call is charged whatever the program erases.
            return [list "fn run_${i}(fs: List\[any\]) errors IndexNotFound:" "    f = std::list::at(fs, 0)" "    f()" \
                "r = run_${i}(\[harmless\]):" "    on IndexNotFound:" "        -2" "1"]
        }
        method {
            return [pick [list \
                [list "xs = \[1, 2, $i\]" "s = \"abc\"" "xs.length() + s.length()"] \
                [list "xs = \[1, 2, $i\]" "fn want_${i}(x: int) -> int:" "    x" "want_${i}(xs.length() == 3)"]]]
        }
    }
}

# A semantic test set: {KIND LINES} fragments.
proc testSet {count} {
    set kinds {valid valid valid unbound type field move known unhandled nestedok chain
        contributor badcontributor earlycontributor consumer contracted possible method
        erasing erasing anyconsumer anyconsumer}
    set set {}
    for {set i 0} {$i < $count} {incr i} {
        set kind [pick $kinds]
        lappend set [list $kind [fragment $kind $i]]
    }
    return $set
}

# The program of SET in LAYOUT, and the first line of each fragment's body
# (the fragment's own line 1) and its column (indent + 1).
proc program {set layout} {
    set lines [split $::prelude \n]
    set starts {}
    set fns {}
    set count [llength $set]
    # The functions: site_I() -> int errors std::compiler::CompilerError, whose
    # whole body is the block; probe_I() calls it under a handler.
    set groups [dict create]
    for {set i 0} {$i < $count} {incr i} {
        switch -- $layout {
            nested - deep { set g driver }
            top { set g "" }
            split { set g "helper_[expr {$i % 3}]" }
        }
        dict lappend groups $g $i
    }
    set calls {}
    dict for {g members} $groups {
        set pad ""
        if {$g ne ""} {
            if {$layout eq "deep"} {
                lappend lines "fn outer_${g}() -> int:" "    fn ${g}() -> int:"
                set pad "        "
            } else {
                lappend lines "fn ${g}() -> int:"
                set pad "    "
            }
        }
        set sum {}
        foreach i $members {
            lassign [lindex $set $i] kind body
            lappend lines "${pad}fn site_${i}() -> int errors std::compiler::CompilerError:" "${pad}    static compile:"
            dict set starts $i [list [expr {[llength $lines] + 1}] [expr {[string length $pad] + 9}]]
            foreach l $body {
                lappend lines "${pad}        $l"
            }
            lappend lines "${pad}fn probe_${i}() -> int:" "${pad}    r = site_${i}():" \
                "${pad}        on std::compiler::CompilerError:" "${pad}            -1" "${pad}    r"
            lappend sum "probe_${i}()"
        }
        if {$g ne ""} {
            lappend lines "$pad[join $sum { + }]"
            if {$layout eq "deep"} {
                lappend lines "    ${g}()"
                lappend calls "outer_${g}()"
            } else {
                lappend calls "${g}()"
            }
        } else {
            lappend calls {*}$sum
        }
    }
    lappend lines [join $calls { + }] ""
    return [list [join $lines \n] $starts]
}

set stats [dict create programs 0 sites 0 rejected 0 failures 0 layoutRoundsDiffer 0]
set kindsSeen [dict create]
set failures {}
for {set p 0} {$p < $n} {incr p} {
    lassign $sitesRange lo hi
    set count [expr {$lo + int(rand() * ($hi - $lo + 1))}]
    set set [testSet $count]
    set layouts {nested top split deep}
    set results [dict create]
    set problem ""
    foreach layout $layouts {
        lassign [program $set $layout] source starts
        set b [sdCompile batched $source]
        set s [sdCompile sequential $source]
        if {[dict get $b error] ne ""} {
            set problem "$layout: compile error [string range [dict get $b error] 0 300]"
            break
        }
        set diff [sdDiff $b $s]
        if {$diff ne ""} {
            set problem "$layout: batched vs sequential: $diff"
            break
        }
        if {$legacy} {
            set diff [sdDiff $b [sdCompile legacy $source] 1]
            if {$diff ne ""} {
                set problem "$layout: batched vs legacy: $diff"
                break
            }
        }
        # Per fragment, in program order: the site keys sorted by offset are
        # the fragments' blocks in the order the program writes them, plus
        # the nested blocks some fragments hold (one each, after their own).
        set keys [lsort -command {apply {{a b} {
            expr {[lindex [split $a :] end] - [lindex [split $b :] end]}
        }}} [dict keys [dict get $b sites]]]
        lassign [program $set $layout] _ starts
        set written [lsort -integer -index 1 [lmap {i start} $starts {list $i [lindex $start 0]}]]
        set k 0
        set verdict [dict create]
        foreach entry $written {
            set i [lindex $entry 0]
            set key [lindex $keys $k]
            incr k
            set kind [lindex [lindex $set $i] 0]
            if {$kind in {nestedok chain}} {
                # The block it holds comes after its own `static` keyword.
                incr k
            }
            set outcome [dict get $b sites $key]
            if {[lindex $outcome 0] eq "rejected"} {
                lassign $outcome _ code line column
                lassign [dict get $starts $i] l0 c0
                set outcome [list rejected $code [expr {$line - $l0}] [expr {$column - $c0}]]
                dict incr stats rejected
            }
            dict set verdict $i $outcome
            dict incr stats sites
            dict incr kindsSeen $kind
        }
        dict set results $layout [dict create verdict [lsort -stride 2 -integer -index 0 $verdict] \
            rounds [dict get $b stats rounds] builds [dict get $b stats builds]]
    }
    set kinds [lmap f $set {lindex $f 0}]
    set chains [llength [lsearch -all $kinds chain]]
    # The blocks the erased-callable contract links (every one calling
    # generic, call or shared is a consumer as well as a contributor): in the
    # worst case one chain, as deep as it has members.
    set erased 0
    foreach k {badcontributor earlycontributor contributor consumer erasing anyconsumer possible} {
        incr erased [llength [lsearch -all $kinds $k]]
    }
    if {$problem eq ""} {
        set base [dict get $results nested]
        # The sequential order is post-order, a failing consumer after the
        # failing contributors to its channel: where a dependency runs one way
        # (a consumer of the erased-callable contract on a contributor),
        # which of the two a layout writes first decides whether the second
        # waits for a build. Each round of the linked blocks rejects at least
        # one of them, so two layouts differ by at most one round fewer than
        # they have members -- and not at all without them (every other
        # fragment is self-contained).
        set allowed [expr {$erased > 1 ? $erased - 1 : 0}]
        foreach layout [lrange $layouts 1 end] {
            set other [dict get $results $layout]
            if {[dict get $base verdict] ne [dict get $other verdict]} {
                set problem "layout $layout gives other verdicts than nested: [dict get $other verdict] / [dict get $base verdict]"
                break
            }
            set d [expr {abs([dict get $base rounds] - [dict get $other rounds])}]
            if {$d > 0} {
                dict incr stats layoutRoundsDiffer
            }
            if {$d > $allowed} {
                set problem "layout $layout takes [dict get $other rounds] rounds, nested [dict get $base rounds] ($erased blocks linked by the erased-callable contract)"
                break
            }
        }
    }
    if {$problem eq ""} {
        # The model's bound: resolution, checked, final, plus each genuine
        # chain's depth, plus the linked blocks'.
        set bound [expr {3 + ($chains > 0 ? 1 : 0) + ($erased > 1 ? $erased : 0)}]
        foreach layout $layouts {
            set rounds [dict get $results $layout rounds]
            if {$rounds > $bound} {
                set problem "$layout: $rounds rounds, more than the model's $bound"
                break
            }
        }
    }
    dict incr stats programs
    set line [format "program %d: %d sites, rounds %s" $p $count \
        [join [lmap layout $layouts {
            if {![dict exists $results $layout]} continue
            string cat $layout = [dict get $results $layout rounds] / [dict get $results $layout builds]
        }] " "]]
    if {$problem ne ""} {
        dict incr stats failures
        append line "\n    FAIL $problem"
        if {$dump ne ""} {
            file mkdir $dump
            foreach layout $layouts {
                set f [open [file join $dump "seed${seed}-p$p-$layout.bot"] w]
                puts -nonewline $f [lindex [program $set $layout] 0]
                close $f
            }
        }
    }
    if {$verbose || $problem ne ""} {
        puts $line
        flush stdout
    }
}
puts "layout pairs taking different rounds: [dict get $stats layoutRoundsDiffer]"
puts "seed $seed: [dict get $stats programs] programs, [dict get $stats sites] sites, [dict get $stats rejected] rejected, [dict get $stats failures] failures"
puts "fragments: [lsort -stride 2 $kindsSeen]"
exit [expr {[dict get $stats failures] > 0}]
