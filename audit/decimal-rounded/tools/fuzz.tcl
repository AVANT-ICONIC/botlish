# fuzz.tcl -- differential and soundness fuzzer of DecimalRounded
# (DECIMAL-ROUNDED-MILESTONE-1.md).
#
#   tclsh9.0 audit/decimal-rounded/tools/fuzz.tcl ?-seed N? ?-count N?
#       ?-backends "interp compile cranelift-generic cranelift"? ?-verbose 0|1?
#
# Each case is a random decimal constant expression -- literals near the
# rounding boundaries of their places (ties, a hair either side of one),
# small and large magnitudes, + - * / and unary minus -- declared as the
# result of DecimalRounded{minDecimalsPreserved: N} for a random N, and a
# random comparison of two values at a random precision. The oracle is
# independent of the compiler's own decimal code (core/decimal.tcl): exact
# rationals of the literals' digits with Tcl's integers, a binary64's exact
# value decoded from its bits, and round half to even written out here. A
# case disagrees when:
#
#   * an accepted constant's run value -- its representation as every
#     backend computes it (they must agree bit for bit) -- does not round,
#     at some P <= N, to the exact value's decimal; or its display is not
#     that decimal;
#   * a precision rejection's claim is inconsistent: the program is not
#     accepted at the precision it is claimed to be proven to, or is
#     accepted one place further, or the representation it is accepted
#     with does round right one place further (the rejection was not
#     needed), or a claimed exactly-zero divisor is not exactly zero;
#   * a KNOWN-ERROR (NonFiniteFloat) whose binary64 computation, done here
#     with Tcl's doubles, is finite;
#   * a comparison's result is not the comparison of the two operands'
#     decimals at the smaller precision, on some backend.
#
# It prints one line per disagreement, how the constants ended (accepted,
# DECIMAL-PRECISION, KNOWN-ERROR) and a final "cases N disagreements D"
# line; the exit status is 1 when D > 0.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -seed 1 -count 40 -backends "interp compile cranelift-generic cranelift" -verbose 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set backends [dict get $options -backends]
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

expr {srand([dict get $options -seed])}
proc random {n} { return [expr {int(rand() * $n)}] }
proc pick {list} { return [lindex $list [random [llength $list]]] }

# ---------------------------------------------------------------------------
# The oracle: exact rationals {P Q}, Q > 0, in lowest terms.

proc gcd {a b} {
    set a [expr {abs($a)}]
    set b [expr {abs($b)}]
    while {$b != 0} {
        set t [expr {$a % $b}]
        set a $b
        set b $t
    }
    return $a
}
proc rat {p q} {
    if {$q < 0} {
        set p [expr {-$p}]
        set q [expr {-$q}]
    }
    set g [gcd $p $q]
    if {$g == 0} { return [list 0 1] }
    return [list [expr {$p / $g}] [expr {$q / $g}]]
}
proc radd {a b} { lassign $a p q; lassign $b r s; return [rat [expr {$p * $s + $r * $q}] [expr {$q * $s}]] }
proc rsub {a b} { lassign $a p q; lassign $b r s; return [rat [expr {$p * $s - $r * $q}] [expr {$q * $s}]] }
proc rmul {a b} { lassign $a p q; lassign $b r s; return [rat [expr {$p * $r}] [expr {$q * $s}]] }
proc rdiv {a b} { lassign $a p q; lassign $b r s; return [rat [expr {$p * $s}] [expr {$q * $r}]] }

# The exact value of decimal TEXT (digits, a point, digits, an optional
# exponent).
proc decimalRat {text} {
    regexp {^(-?)([0-9]+)\.([0-9]+)(?:e([-+]?[0-9]+))?$} $text -> sign whole fraction exponent
    if {$exponent eq ""} { set exponent 0 }
    set exponent [scan $exponent %d]
    set digits [string trimleft $whole$fraction 0]
    if {$digits eq ""} { set digits 0 }
    set power [expr {$exponent - [string length $fraction]}]
    if {$power >= 0} {
        set r [list [expr {$digits * 10 ** $power}] 1]
    } else {
        set r [rat $digits [expr {10 ** (-$power)}]]
    }
    if {$sign eq "-"} { set r [list [expr {-[lindex $r 0]}] [lindex $r 1]] }
    return $r
}

# The exact value of the binary64 X (a Tcl double), from its bits.
proc doubleRat {x} {
    binary scan [binary format d $x] w bits
    set sign [expr {($bits >> 63) & 1}]
    set e [expr {($bits >> 52) & 0x7ff}]
    set m [expr {$bits & 0xfffffffffffff}]
    if {$e == 0} {
        set e 1
    } else {
        set m [expr {$m | (1 << 52)}]
    }
    set e [expr {$e - 1075}]
    if {$e >= 0} {
        set r [list [expr {$m << $e}] 1]
    } else {
        set r [rat $m [expr {1 << (-$e)}]]
    }
    if {$sign} { set r [list [expr {-[lindex $r 0]}] [lindex $r 1]] }
    return $r
}

# round(R, P) * 10^P, half to even, as an integer.
proc roundAt {r p} {
    lassign $r num den
    set num [expr {$num * 10 ** $p}]
    set k [expr {$num / $den}]
    set rem [expr {$num - $k * $den}]
    if {2 * $rem > $den || (2 * $rem == $den && $k % 2 != 0)} {
        incr k
    }
    return $k
}

# The decimal text of round(R, P), as a DecimalRounded value displays it.
proc roundedText {r p} {
    set k [roundAt $r $p]
    set sign ""
    if {$k < 0} { set sign - }
    set digits [expr {abs($k)}]
    if {$p == 0} { return $sign$digits }
    set digits [format %0*s [expr {$p + 1}] $digits]
    return "$sign[string range $digits 0 end-$p].[string range $digits end-[expr {$p - 1}] end]"
}

# ---------------------------------------------------------------------------
# Generation

# A literal: a decimal of a few places, often a tie or a hair from one.
proc literal {} {
    set places [random 5]
    set whole [pick [list 0 0 1 2 7 12 99 123 1000 65536 [random 1000000]]]
    if {[random 12] == 0} {
        return [pick {1.0e15 1.0e16 9007199254740993.0 1.0e22 1.0e23 1.0e-300 5.0e-324 1.7976931348623157e308 123456789012345678.5}]
    }
    set fraction [format %0*d $places [random [expr {10 ** $places}]]]
    if {$places == 0} {
        set text $whole.0
    } else {
        set text $whole.$fraction
    }
    switch -- [random 4] {
        0 { append text 5 }
        1 { append text 49999999 }
        2 { append text 50000001 }
    }
    return $text
}

# An expression of depth at most DEPTH: {text EXACT-OR-undefined SPEC},
# SPEC the tree for the Tcl-double computation.
proc expression {depth} {
    if {$depth == 0 || [random 3] == 0} {
        set text [literal]
        return [list $text $text]
    }
    if {[random 6] == 0} {
        lassign [expression [expr {$depth - 1}]] a ta
        return [list "-($a)" [list neg $ta]]
    }
    set op [pick {+ - * /}]
    lassign [expression [expr {$depth - 1}]] a ta
    lassign [expression [expr {$depth - 1}]] b tb
    return [list "($a) $op ($b)" [list $op $ta $tb]]
}

# The exact value of tree T: a rational, or `undefined` (a division by an
# exactly zero value).
proc exact {t} {
    if {[llength $t] == 1} { return [decimalRat $t] }
    if {[lindex $t 0] eq "neg"} {
        set a [exact [lindex $t 1]]
        if {$a eq "undefined"} { return undefined }
        return [list [expr {-[lindex $a 0]}] [lindex $a 1]]
    }
    lassign $t op x y
    set a [exact $x]
    set b [exact $y]
    if {$a eq "undefined" || $b eq "undefined"} { return undefined }
    switch -- $op {
        + { return [radd $a $b] }
        - { return [rsub $a $b] }
        * { return [rmul $a $b] }
        / {
            if {[lindex $b 0] == 0} { return undefined }
            return [rdiv $a $b]
        }
    }
}

# Tree T computed with Tcl's binary64 doubles (literals their nearest
# doubles): a double, or `nonfinite`.
proc doubles {t} {
    if {[llength $t] == 1} { return [expr {double($t)}] }
    if {[lindex $t 0] eq "neg"} {
        set a [doubles [lindex $t 1]]
        if {$a eq "nonfinite"} { return nonfinite }
        return [expr {-$a}]
    }
    lassign $t op x y
    set a [doubles $x]
    set b [doubles $y]
    if {$a eq "nonfinite" || $b eq "nonfinite"} { return nonfinite }
    if {$op eq "/" && $b == 0.0} { return nonfinite }
    set r [expr "\$a $op \$b"]
    if {[string match -nocase *inf* $r] || [string match -nocase *nan* $r]} { return nonfinite }
    return $r
}

# ---------------------------------------------------------------------------
# Running

proc program {expr n} {
    return "fn a() -> DecimalRounded{minDecimalsPreserved: $n}:\n    $expr\na()\n"
}

# {accepted DISPLAY REPRESENTATION} (every backend agreeing), {rejected
# KIND MESSAGE}, or {mismatch TEXT}.
proc outcome {source} {
    global backends
    if {[catch {surface::compile $source t.bot -warnings off} hir options]} {
        if {[dict exists $options -diagnostics]} {
            set d [lindex [dict get $options -diagnostics] 0]
            return [list rejected [lindex [dict get $d errorcode] end] [dict get $d message]]
        }
        return [list rejected [lindex [dict get $options -errorcode] end] $hir]
    }
    set type [hir::typeOf $hir [lindex [hir::roots $hir] end]]
    set seen {}
    foreach b $backends {
        set saved [core::useBackend]
        if {[catch {
            switch -- $b {
                interp { core::useBackend interp; core::evalProgram [hir::lower $hir] }
                compile { core::compiler::evalHir $hir }
                cranelift-generic { native::evalHir $hir -specialize 0 }
                cranelift { native::evalHir $hir }
            }
        } v]} {
            core::useBackend $saved
            lappend seen [list error $v]
            continue
        }
        core::useBackend $saved
        lappend seen [list [hir::decimal::Display $v $type] [core::value::show $v 1 1]]
    }
    if {[llength [lsort -unique $seen]] != 1} {
        return [list mismatch $seen]
    }
    lassign [lindex $seen 0] display reveal
    if {$display eq "error"} {
        return [list mismatch $seen]
    }
    set text ""
    regexp {^<DecimalRounded (.*)>$} $reveal -> text
    return [list accepted $display $text]
}

set cases 0
set disagreements 0
set tally [dict create]
proc disagree {text} {
    global disagreements
    incr disagreements
    puts "DISAGREE $text"
}

for {set i 0} {$i < [dict get $options -count]} {incr i} {
    incr cases
    lassign [expression [expr {1 + [random 3]}]] text tree
    set n [random 19]
    set t [exact $tree]
    set result [outcome [program $text $n]]
    set kind [lindex $result 0]
    if {$kind eq "rejected"} { set kind [lindex $result 1] }
    dict incr tally $kind
    if {[dict get $options -verbose]} { puts "case $i: N=$n $text -> [lrange $result 0 1]" }
    switch -- [lindex $result 0] {
        mismatch {
            disagree "backends differ on {$text} at $n: [lindex $result 1]"
        }
        accepted {
            lassign $result - display rep
            if {$t eq "undefined"} {
                disagree "{$text} accepted at $n, but it divides by an exactly zero value"
                continue
            }
            set x [doubleRat [expr {double($rep)}]]
            for {set p 0} {$p <= $n} {incr p} {
                if {[roundAt $x $p] != [roundAt $t $p]} {
                    disagree "{$text} accepted at $n, but its representation $rep rounds wrong at $p places"
                    break
                }
            }
            if {$display ne [roundedText $t $n]} {
                disagree "{$text} at $n displays $display, not [roundedText $t $n]"
            }
        }
        rejected {
            lassign $result - kind message
            switch -- $kind {
                KNOWN-ERROR {
                    if {[doubles $tree] ne "nonfinite"} {
                        disagree "{$text} is KNOWN-ERROR, but its binary64 computation is finite ([doubles $tree])"
                    }
                }
                DECIMAL-PRECISION {
                    if {[string match "*divides by a value whose exact decimal value is zero*" $message]} {
                        if {$t ne "undefined"} {
                            disagree "{$text} claims an exactly zero divisor, but its exact value is defined"
                        }
                        continue
                    }
                    if {$t eq "undefined"} {
                        disagree "{$text} divides by an exactly zero value, but the rejection says: $message"
                        continue
                    }
                    if {[regexp {only proven correct to (\d+) decimal place} $message -> k]} {
                    } elseif {[string match "*no decimal place of*" $message]} {
                        set k -1
                    } else {
                        disagree "{$text} at $n: unexpected DECIMAL-PRECISION message: $message"
                        continue
                    }
                    if {$k >= $n} {
                        disagree "{$text} rejected at $n though proven to $k"
                        continue
                    }
                    if {$k >= 0} {
                        set lower [outcome [program $text $k]]
                        if {[lindex $lower 0] ne "accepted"} {
                            disagree "{$text} claimed proven to $k, but not accepted there: [lrange $lower 0 2]"
                            continue
                        }
                        set x [doubleRat [expr {double([lindex $lower 2])}]]
                        set next [expr {$k + 1}]
                        if {[roundAt $x $next] == [roundAt $t $next]} {
                            disagree "{$text} rejected at $next, but its representation [lindex $lower 2] rounds right there"
                        }
                    }
                }
                default {
                    disagree "{$text} at $n rejected with $kind: $message"
                }
            }
        }
    }
}

# Comparisons of values passed at run time: decided by the operands'
# decimals at the smaller guaranteed precision.
set comparisons [expr {[dict get $options -count] / 4 + 1}]
for {set i 0} {$i < $comparisons} {incr i} {
    incr cases
    set pa [random 6]
    set pb [random 6]
    set p [expr {min($pa, $pb)}]
    set a [literal]
    set b $a
    if {[random 2]} { set b [literal] }
    if {[random 3] == 0} {
        # A hair apart: one place beyond the comparison's precision.
        set b [expr {$a + 10.0 ** (-$p - 1)}]
        set b [format %.12f $b]
    }
    set op [pick {< <= > >= == !=}]
    set source [string cat \
        "fn f(a: DecimalRounded{minDecimalsPreserved: $pa}, b: DecimalRounded{minDecimalsPreserved: $pb}) -> bool:\n" \
        "    a $op b\n" \
        "fn ga() -> DecimalRounded{minDecimalsPreserved: $pa}:\n    $a\n" \
        "fn gb() -> DecimalRounded{minDecimalsPreserved: $pb}:\n    $b\n" \
        "f(ga(), gb())\n"]
    set result [outcome $source]
    if {[lindex $result 0] eq "rejected"} {
        # A literal no representation holds at its precision: no comparison.
        if {[lindex $result 1] ne "DECIMAL-PRECISION"} {
            disagree "comparison {$a $op $b} at $pa/$pb rejected with [lindex $result 1]: [lindex $result 2]"
        }
        continue
    }
    if {[lindex $result 0] eq "mismatch"} {
        disagree "backends differ on {$a $op $b} at $pa/$pb: [lindex $result 1]"
        continue
    }
    set ka [roundAt [decimalRat $a] $p]
    set kb [roundAt [decimalRat $b] $p]
    set expected false
    if {[expr "\$ka $op \$kb"]} { set expected true }
    if {[lindex $result 1] ne $expected} {
        disagree "{$a $op $b} at $pa/$pb is [lindex $result 1], not $expected (decimals $ka, $kb at $p)"
    }
}

puts "constants: [join [lmap {k v} $tally {string cat $k " " $v}] {, }]"
puts "cases $cases disagreements $disagreements"
exit [expr {$disagreements > 0}]
