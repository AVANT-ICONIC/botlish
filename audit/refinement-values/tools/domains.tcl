# domains.tcl -- fuzz.tcl's `-domains 1` mode: random small integer domains
# entered through ordinary Botlish (ELIMINATE-AUTOMATIC-TYPE-PREDICATES.md).
#
#   tclsh9.0 audit/refinement-values/tools/fuzz.tcl -domains 1 ?-seed N? ?-count N? ?-backends LIST? ?-v 1? ?-show 1?
#
# No type has a membership predicate: a program admits an Int into a domain
# `type D = Int in LO..HI` through a converter (an ordinary function whose
# declared result is D, no proof clause), or through comparisons whose range
# facts prove the value in D; a refinement over the domain (`refined type R
# = D`) is proven by an annotated predicate or validator. Each program draws
# a random domain and:
#
#   * a converter `to_d(x: int) -> D errors Out` whose guard has a random
#     shape (two guards, an `or` guard, an elif chain, `not` of a
#     conjunction, nested accepting ifs, comparisons spelled either way
#     round) -- a quarter of them broken (a bound off by one, a bound
#     missing, `and` for `or`): a converter is no cast, so those must fail
#     their return proof;
#   * R = D, its predicate `r?(x: D) -> bool proves x: R` (a random member
#     set), validator `validate_r` and converter `to_r(x: int) -> R`, built
#     on to_d and r?;
#   * a body for f(x: int) of statements: guards with early returns, uses of
#     x guarded by random and/or/not comparisons (`if COND: need_d(x)`),
#     converter calls with a handler, predicate branches, validator calls,
#     to_r calls -- each also drawn as a misuse (a value the program did not
#     prove: the converter's argument, the predicate's false edge, before
#     the validator);
#   * one unhandled converter call of an exact constant at the top level.
#
# The oracle shares no code with the compiler. It models x's proven
# interval, starting unbounded: a guard keeps the hull of the values its
# condition lets through, a branch proves D when the hull of the values its
# condition selects is inside the domain (vacuously when none can), a
# converter's argument stays an int, a predicate proves R on its true edge
# only, a validator after it completes. A converter call is KNOWN-ERROR when
# no value x may have passes its guard, and an exact one when the constant
# fails it. Conditions are compared over a finite universe that also stands
# for the two infinite tails, so the hulls are exact. Each program is
# compiled once; a predicted rejection must be one of the predicted kinds, a
# predicted acceptance must compile and run to the oracle's value on every
# backend.

proc dPick {list} { lindex $list [expr {int(rand() * [llength $list])}] }
proc dChance {p} { expr {rand() < $p} }
proc dRand {lo hi} { expr {$lo + int(rand() * ($hi - $lo + 1))} }

# The universe the conditions are evaluated over: every constant drawn is in
# [LO - 6, HI + 6], so U-1 and U+1 stand for the tails.
proc dUniverse {} {
    global D
    set out {}
    for {set v [expr {[dict get $D lo] - 8}]} {$v <= [dict get $D hi] + 8} {incr v} {
        lappend out $v
    }
    return $out
}
proc dBelow {} { global D; expr {[dict get $D lo] - 8} }
proc dAbove {} { global D; expr {[dict get $D hi] + 8} }

# The hull {LO HI} (each an integer, -inf or +inf) of the values of SET (a
# subset of the universe), or "" when SET is empty.
proc dHull {set} {
    if {$set eq {}} { return "" }
    set lo [lindex $set 0]
    set hi [lindex $set end]
    if {$lo == [dBelow]} { set lo -inf }
    if {$hi == [dAbove]} { set hi +inf }
    return [list $lo $hi]
}

# The members of SET inside the interval I ({LO HI} with infinities).
proc dWithin {set I} {
    lassign $I lo hi
    return [lmap v $set {
        if {($lo ne "-inf" && $v < $lo) || ($hi ne "+inf" && $v > $hi)} continue
        set v
    }]
}

# 1 if interval I lies inside [A, B] (integers).
proc dInside {I a b} {
    if {$I eq ""} { return 1 }
    lassign $I lo hi
    return [expr {$lo ne "-inf" && $hi ne "+inf" && $lo >= $a && $hi <= $b}]
}

# ---------------------------------------------------------------------------
# Conditions over x: {cmp OP K FLIP} (FLIP: written `K OP' x`), {and A B},
# {or A B}, {not A}.

proc dGenCond {depth} {
    global D
    set r [expr {rand()}]
    if {$depth > 0 && $r < 0.15} {
        return [list not [dGenCond [expr {$depth - 1}]]]
    }
    if {$depth > 0 && $r < 0.5} {
        return [list [dPick {and or}] [dGenCond [expr {$depth - 1}]] [dGenCond [expr {$depth - 1}]]]
    }
    return [list cmp [dPick {< <= > >=}] [dRand [expr {[dict get $D lo] - 4}] [expr {[dict get $D hi] + 4}]] [dChance 0.3]]
}

proc dTruth {c v} {
    switch -- [lindex $c 0] {
        cmp {
            lassign $c _ op k
            return [expr "\$v $op \$k"]
        }
        and { return [expr {[dTruth [lindex $c 1] $v] && [dTruth [lindex $c 2] $v]}] }
        or  { return [expr {[dTruth [lindex $c 1] $v] || [dTruth [lindex $c 2] $v]}] }
        not { return [expr {![dTruth [lindex $c 1] $v]}] }
    }
}

proc dCondText {c} {
    switch -- [lindex $c 0] {
        cmp {
            lassign $c _ op k flip
            if {$flip} {
                return "$k [dict get {< > <= >= > < >= <=} $op] x"
            }
            return "x $op $k"
        }
        and { return "([dCondText [lindex $c 1]] and [dCondText [lindex $c 2]])" }
        or  { return "([dCondText [lindex $c 1]] or [dCondText [lindex $c 2]])" }
        not { return "not [dCondText [lindex $c 1]]" }
    }
}

# The values of SET (within the current interval) for which C is OUTCOME.
proc dSelect {set c outcome} {
    return [lmap v $set {if {[dTruth $c $v] == $outcome} {set v} else continue}]
}

# ---------------------------------------------------------------------------
# The converter: its guard's admitted interval {L U} (an infinity for a
# missing bound) and its text.

proc dGenConverter {} {
    global D
    set lo [dict get $D lo]
    set hi [dict get $D hi]
    set L $lo
    set U $hi
    set shape [dPick {two or elif notand nested}]
    set broken ""
    if {[dChance 0.25]} {
        set broken [dPick {lowoff highoff nolow nohigh andbug}]
        switch -- $broken {
            lowoff  { set L [expr {$lo - 1}] }
            highoff { set U [expr {$hi + 1}] }
            nolow   { set L -inf }
            nohigh  { set U +inf }
            andbug  { set shape or }
        }
    }
    # The rejecting tests (x below L, x above U) and the accepting ones.
    set below [dPick [list "x < $L" "$L > x" "x <= [expr {$L eq "-inf" ? 0 : $L - 1}]"]]
    set above [dPick [list "x > $U" "$U < x" "x >= [expr {$U eq "+inf" ? 0 : $U + 1}]"]]
    set atLeast [dPick [list "x >= $L" "$L <= x"]]
    set atMost [dPick [list "x <= $U" "$U >= x"]]
    set rejects {}
    if {$L ne "-inf"} { lappend rejects $below }
    if {$U ne "+inf"} { lappend rejects $above }
    set accepts {}
    if {$L ne "-inf"} { lappend accepts $atLeast }
    if {$U ne "+inf"} { lappend accepts $atMost }
    if {$broken eq "andbug"} {
        set text "    if $below and $above:\n        fail Out\n    x"
        return [list [list -inf +inf] $text]
    }
    if {[llength $rejects] == 1} {
        set shape two
    }
    switch -- $shape {
        two {
            set text ""
            foreach t $rejects { append text "    if $t:\n        fail Out\n" }
            append text "    x"
        }
        or {
            set text "    if [join $rejects { or }]:\n        fail Out\n    x"
        }
        elif {
            set text "    if [lindex $rejects 0]:\n        fail Out\n    elif [lindex $rejects 1]:\n        fail Out\n    else:\n        x"
        }
        notand {
            set text "    if not ([join $accepts { and }]):\n        fail Out\n    x"
        }
        nested {
            set text "    if [lindex $accepts 0]:\n        if [lindex $accepts 1]:\n            return x\n    fail Out"
        }
    }
    return [list [list $L $U] $text]
}

# ---------------------------------------------------------------------------
# f's statements, generated against the oracle's state (so that most uses
# are sensible): {I INTERVAL xR 0|1 vars {dN {r 0|1} ...}}.

proc dGenBody {} {
    global D A
    set lo [dict get $D lo]
    set hi [dict get $D hi]
    set universe [dUniverse]
    set state [dict create I {-inf +inf} xR 0 vars {}]
    set stmts {}
    set n [dRand 2 4]
    set counter 0
    for {set i 0} {$i < $n} {incr i} {
        set I [dict get $state I]
        set within [dWithin $universe $I]
        set kind [dPick {guard guard branch branch conv pred validate tor}]
        switch -- $kind {
            guard {
                # Keep some values on both edges, so the rest is not dead.
                for {set try 0} {$try < 50} {incr try} {
                    set c [dGenCond 2]
                    set pass [dSelect $within $c 0]
                    if {$pass ne {} && [llength $pass] < [llength $within]} break
                }
                if {$pass eq {} || [llength $pass] == [llength $within]} continue
                lappend stmts [list guard $c [expr {-2 - $i}]]
                dict set state I [dHull $pass]
            }
            branch {
                set c [dGenCond 2]
                lappend stmts [list branch u[incr counter] $c [dPick {then then else}]]
            }
            conv {
                lappend stmts [list conv d[incr counter] [dChance 0.2]]
                dict set state vars d$counter [dict create r 0]
            }
            pred {
                set vars [dict keys [dict get $state vars]]
                set v [expr {$vars ne {} && [dChance 0.7] ? [dPick $vars] : "x"}]
                lappend stmts [list pred u[incr counter] $v [dPick {ok ok swapped not}]]
            }
            validate {
                set vars [dict keys [dict get $state vars]]
                set v [expr {$vars ne {} && [dChance 0.7] ? [dPick $vars] : "x"}]
                lappend stmts [list validate u[incr counter] $v [dChance 0.2]]
                if {$v eq "x"} {
                    dict set state xR 1
                } else {
                    dict set state vars $v r 1
                }
            }
            tor {
                lappend stmts [list tor e[incr counter] [dChance 0.2]]
            }
        }
    }
    return $stmts
}

# The source of f's body.
proc dBodyText {stmts} {
    set lines {}
    set uses {}
    foreach s $stmts {
        switch -- [lindex $s 0] {
            guard {
                lassign $s _ c k
                lappend lines "    if [dCondText $c]:" "        return $k"
            }
            branch {
                lassign $s _ u c side
                if {$side eq "then"} {
                    lappend lines "    $u = if [dCondText $c]:" "        need_d(x)" "    else:" "        0"
                } else {
                    lappend lines "    $u = if [dCondText $c]:" "        0" "    else:" "        need_d(x)"
                }
                lappend uses $u
            }
            conv {
                lassign $s _ d misuse
                lappend lines "    $d = to_d(x):" "        on Out:" "            return -1"
                lappend lines "    ${d}u = need_d([expr {$misuse ? "x" : $d}])"
                lappend uses ${d}u
            }
            pred {
                lassign $s _ u v form
                switch -- $form {
                    ok      { lappend lines "    $u = if r?($v):" "        need_r($v)" "    else:" "        need_d($v)" }
                    swapped { lappend lines "    $u = if r?($v):" "        need_d($v)" "    else:" "        need_r($v)" }
                    not     { lappend lines "    $u = if not r?($v):" "        need_d($v)" "    else:" "        need_r($v)" }
                }
                lappend uses $u
            }
            validate {
                lassign $s _ u v early
                if {$early} {
                    lappend lines "    ${u}e = need_r($v)"
                    lappend uses ${u}e
                }
                lappend lines "    $u = validate_r($v):" "        on Bad:" "            return -3"
                lappend lines "    ${u}r = need_r($v)"
                lappend uses ${u}r
            }
            tor {
                lassign $s _ e misuse
                lappend lines "    $e = to_r(x):" "        on Out:" "            return -1" "        on Bad:" "            return -3"
                lappend lines "    ${e}u = need_r([expr {$misuse ? "x" : $e}])"
                lappend uses ${e}u
            }
        }
    }
    lappend lines "    [expr {$uses eq {} ? 0 : [join $uses { + }]}]"
    return [join $lines \n]
}

proc dProgramText {converter members stmts inputs exact} {
    global D
    set lo [dict get $D lo]
    set hi [dict get $D hi]
    set test [join [lmap m $members {set _ "x == $m"}] { or }]
    return "import std::list

type D = Int in $lo..$hi
refined type R = D
error Out
error Bad

fn to_d(x: int) -> D errors Out:
[lindex $converter 1]

fn r?(x: D) -> bool proves x: R:
    $test

fn validate_r(x: D) -> unit proves x: R errors Bad:
    if not r?(x):
        fail Bad
    unit

fn to_r(x: int) -> R errors Out, Bad:
    d = to_d(x)
    if r?(d):
        return d
    fail Bad

fn need_d(d: D) -> int:
    d + 100

fn need_r(r: R) -> int:
    r + 1000

fn f(x: int) -> int:
[dBodyText $stmts]

xs = \[[join $inputs {, }]\]
ys = loop x in xs:
    f(x)
\[ys, \[to_d($exact)\]\]
"
}

# ---------------------------------------------------------------------------
# The oracle: the rejections it predicts (kinds), and the value.

proc dOracle {converter stmts exact} {
    global D
    set lo [dict get $D lo]
    set hi [dict get $D hi]
    lassign [lindex $converter 0] L U
    set kinds {}
    if {![dInside [list $L $U] $lo $hi]} {
        lappend kinds TYPE
    }
    set universe [dUniverse]
    set I {-inf +inf}
    set xR 0
    set vars [dict create]
    foreach s $stmts {
        set within [dWithin $universe $I]
        switch -- [lindex $s 0] {
            guard {
                lassign $s _ c
                set I [dHull [dSelect $within $c 0]]
            }
            branch {
                lassign $s _ u c side
                set hull [dHull [dSelect $within $c [expr {$side eq "then"}]]]
                if {![dInside $hull $lo $hi]} { lappend kinds TYPE }
            }
            conv {
                lassign $s _ d misuse
                # The guard lets through [L, U]: a call no x may pass always fails.
                if {[dWithin $within [list $L $U]] eq {}} { lappend kinds KNOWN-ERROR }
                if {$misuse && ![dInside $I $lo $hi]} { lappend kinds TYPE }
                dict set vars $d 0
            }
            pred {
                lassign $s _ u v form
                if {$v eq "x" && ![dInside $I $lo $hi]} { lappend kinds TYPE }
                set proven [expr {$v eq "x" ? $xR : [dict get $vars $v]}]
                # The edge that uses need_r without the proof: ok's else uses
                # need_d; swapped's else and not's else use need_r -- not's
                # else is r?'s true edge (proven), swapped's is the false one.
                if {$form eq "swapped" && !$proven} { lappend kinds TYPE }
            }
            validate {
                lassign $s _ u v early
                if {$v eq "x" && ![dInside $I $lo $hi]} { lappend kinds TYPE }
                set proven [expr {$v eq "x" ? $xR : [dict get $vars $v]}]
                if {$early && !$proven} { lappend kinds TYPE }
                if {$v eq "x"} { set xR 1 } else { dict set vars $v 1 }
            }
            tor {
                lassign $s _ e misuse
                if {[dWithin $within [list $L $U]] eq {}} { lappend kinds KNOWN-ERROR }
                if {$misuse && !$xR} { lappend kinds TYPE }
            }
        }
    }
    if {!(($L eq "-inf" || $exact >= $L) && ($U eq "+inf" || $exact <= $U))} {
        lappend kinds KNOWN-ERROR
    }
    return [lsort -unique $kinds]
}

# f(X) concretely (f handles every error itself).
proc dRun {converter members stmts x} {
    lassign [lindex $converter 0] L U
    set inA [expr {($L eq "-inf" || $x >= $L) && ($U eq "+inf" || $x <= $U)}]
    set sum 0
    set vals [dict create x $x]
    foreach s $stmts {
        switch -- [lindex $s 0] {
            guard {
                lassign $s _ c k
                if {[dTruth $c $x]} { return $k }
            }
            branch {
                lassign $s _ u c side
                set t [dTruth $c $x]
                incr sum [expr {($side eq "then") == $t ? $x + 100 : 0}]
            }
            conv {
                lassign $s _ d
                if {!$inA} { return -1 }
                dict set vals $d $x
                incr sum [expr {$x + 100}]
            }
            pred {
                lassign $s _ u v form
                set val [dict get $vals $v]
                set member [expr {$val in $members}]
                if {$form eq "swapped"} { set member [expr {!$member}] }
                incr sum [expr {$member ? $val + 1000 : $val + 100}]
            }
            validate {
                lassign $s _ u v early
                set val [dict get $vals $v]
                if {$early} { incr sum [expr {$val + 1000}] }
                if {$val ni $members} { return -3 }
                incr sum [expr {$val + 1000}]
            }
            tor {
                if {!$inA} { return -1 }
                if {$x ni $members} { return -3 }
                incr sum [expr {$x + 1000}]
            }
        }
    }
    return $sum
}

# ---------------------------------------------------------------------------
# Driver

set stats [dict create programs 0 accepted 0 rejected 0 broken 0 failures 0]
set failures {}
for {set i 0} {$i < [dict get $options -count]} {incr i} {
    # With probability -accept, draw until the oracle accepts (most random
    # bodies hold a misuse); the rest are taken as drawn.
    set wantAccept [dChance [dict get $options -accept]]
    for {set try 0} {$try < 300} {incr try} {
        set lo [dRand -4 4]
        set D [dict create lo $lo hi [expr {$lo + [dRand 1 6]}]]
        set hi [dict get $D hi]
        set converter [dGenConverter]
        set members [lsort -integer -unique [lmap _ {1 2 3} {dRand $lo $hi}]]
        set stmts [dGenBody]
        set inputs [lmap _ {1 2 3 4 5 6} {dRand [expr {$lo - 3}] [expr {$hi + 3}]}]
        set exact [expr {[dChance 0.8] ? [dRand $lo $hi] : [dRand [expr {$lo - 3}] [expr {$hi + 3}]]}]
        set kinds [dOracle $converter $stmts $exact]
        if {!$wantAccept || $kinds eq {}} break
    }
    set text [dProgramText $converter $members $stmts $inputs $exact]
    dict incr stats programs
    if {![dInside [lindex $converter 0] $lo $hi]} { dict incr stats broken }
    if {[dict get $options -show] && $kinds eq {}} {
        puts "---- program $i\n$text"
    }
    set problem ""
    if {[catch {surface::compile $text fuzz.bot -warnings off} hir compileOptions]} {
        set code [lindex [dict get $compileOptions -errorcode] end]
        if {$kinds eq {}} {
            set problem "rejected ($code): $hir"
        } elseif {$code ni $kinds} {
            set problem "rejected with $code (expected one of: $kinds): $hir"
        } else {
            dict incr stats rejected
        }
    } elseif {$kinds ne {}} {
        set problem "accepted, but the oracle rejects: $kinds"
    } else {
        dict incr stats accepted
        set ys [lmap x $inputs {dRun $converter $members $stmts $x}]
        set expected [list value "\[\[[join $ys {, }]\], \[$exact\]\]"]
        foreach backend [dict get $options -backends] {
            set result [outcome $backend $hir]
            if {$result ne $expected} {
                set problem "$backend: $result, expected $expected"
                break
            }
        }
    }
    if {$problem ne ""} {
        dict incr stats failures
        lappend failures [list $i $problem $text]
    }
}

foreach failure $failures {
    lassign $failure i problem text
    puts "FAIL program $i: $problem"
    if {[dict get $options -v]} {
        puts $text
    }
}
puts "seed [dict get $options -seed] (domains): [dict get $stats programs] programs, [dict get $stats accepted] accepted, [dict get $stats rejected] rejected ([dict get $stats broken] broken converters), [dict get $stats failures] failures"
exit [expr {[dict get $stats failures] > 0}]
