#!/usr/bin/env tclsh9.0
# fuzz.tcl -- randomized differential check of every native form of the
# root `mod` (native/lower.tcl's "Euclidean mod" section lists them, and
# which facts select each; codegen::clif's `euclid_mod`), in ordinary
# functions, self-tail loops and inlined tiny leaves.
#
# Each program holds a few functions that apply `mod` to their parameters --
# constant divisors (powers of two of both signs, others, 1, -1, near and
# beyond +-2^62, BigInts), variable divisors, divisors narrowed by a branch
# guard, a self-tail loop, a hash reduced by an array capacity, a leaf
# called with a constant divisor -- each called with dividends drawn either
# only from small Ints (so hir/range.tcl proves them small and the raw forms
# apply) or also from BigInts and values near +-2^62 (the tagged form). A
# program's value is the List of every result; with some probability one
# more call passes a zero divisor, so the outcome is the ARITHMETIC error.
# Every program runs on interp (the reference, core::primitives::modulo),
# compile, cranelift, cranelift-generic and native with representation
# optimization, tiny-leaf inlining and the raw Int ABI each turned off; all
# outcomes (value, or error code and message) must agree.
#
# The raw and mask forms trust the divisor's Range with no runtime check, so
# two forms aim at the facts behind those Ranges, hir/induction.tcl's
# equality-termination proof among them:
#   * nontail: an `==`-terminated recursion with a second, non-tail self
#     call that jumps i by another step (or the same: the sound shape, whose
#     fact must still select the raw and mask forms), its divisor derived
#     from i so that a Range read from the tail calls alone would be one
#     power of two or would exclude 0 where the jumped chain meets other
#     values, 0 among them. A fuel parameter bounds every chain.
#   * a deep program (about one seed in two), its own: an `==` bound that is
#     a native call with a registered Range, char::scalar_value(c), with c
#     recomputed every step (varying: the bound is no single value, and i may
#     step past it) or passed unchanged (invariant: the fact fires), read
#     directly, through a local, a struct field or a function returning it,
#     a struct or an `if` value the invocation builds from it, or a context
#     parameter (invariant only: a context is installed once);
#     or c captured by a closure whose non-tail self call goes through a
#     parameter holding another closure of the same function, with another
#     c. The proof needs i to start at the bound's largest value, 1114111,
#     so the recursion is 1114112 calls deep: too deep for interp's
#     recursion limit and slow on compile, so its reference is a Tcl model
#     of the program (DeepModel), and only the native outcomes are compared
#     with it.
#
#   tclsh9.0 audit/mod-lowering/tools/fuzz.tcl ?-n N? ?-seed S? ?-gc-stress 0|1?
#
# -gc-stress 1 runs the native outcomes again under BOTLISH_NATIVE_GC_STRESS=1.
# Prints the NIR op census (how often each lowering was exercised) and exits 1
# on any disagreement, printing the program.
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 60 -seed 1 -gc-stress 0]
foreach {k v} $argv {
    if {![dict exists $options $k]} { error "unknown option $k" }
    dict set options $k $v
}
set argv {}
source [file join $root core core.tcl]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 100000
core::useProgramRecursionLimit

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }

# Botlish source for the Int V (a negative value is `0 - N`).
proc lit {v} { return [expr {$v < 0 ? "(0 - [expr {-$v}])" : $v}] }

set smallMax [expr {(1 << 62) - 1}]
set smallMin [expr {-(1 << 62)}]
# Dividends: small ones (every value fits the small-Int range) and wide ones.
set smallPool [list 0 1 -1 2 -2 3 -3 7 -7 8 -8 100 -100 1023 1024 -1024 1025 -1025 \
    999999 -999999 $smallMax $smallMin [expr {$smallMax - 1}] [expr {$smallMin + 1}] \
    [expr {1 << 61}] [expr {-(1 << 61)}] 1000000007]
set widePool [concat $smallPool [list [expr {1 << 62}] [expr {$smallMin - 1}] \
    9223372036854775807 -9223372036854775808 9223372036854775808 \
    100000000000000000000 -100000000000000000000 [expr {1 << 64}] [expr {-(1 << 64) - 3}]]]
# Divisors (never 0 here; the zero divisor is its own call). No divisor is
# negative with |d| >= 2^63: Tcl 9.0.1 aborts (heap corruption) evaluating
# `max(abs(v), abs(v))` for such a v, which hir::range::Mod does for a
# divisor Range's bounds -- a front-end crash outside this fuzzer's subject.
set smallDivisors [list 1 -1 2 -2 3 -3 7 8 -8 10 16 -16 1000 1024 -1024 4096 \
    [expr {1 << 61}] [expr {-(1 << 61)}] $smallMax $smallMin [expr {$smallMax - 1}]]
set wideDivisors [concat $smallDivisors [list [expr {1 << 62}] [expr {-(1 << 62) - 1}] \
    [expr {1 << 63}] 100000000000000000000 [expr {1 << 70}]]]
# Constant divisors of a `x.mod(K)` function: the powers of two (masks),
# others, and BigInts.
set constDivisors [concat $wideDivisors [list 32 -32 65536 [expr {1 << 62}] [expr {-(1 << 62)}]]]

proc sample {pool n} {
    set out {}
    for {set i 0} {$i < $n} {incr i} { lappend out [pick $pool] }
    return $out
}

proc program {} {
    global smallPool widePool smallDivisors wideDivisors constDivisors
    set fns {}
    set items {}
    set errorCall ""
    set nfun [expr {2 + int(rand() * 4)}]
    for {set i 1} {$i <= $nfun} {incr i} {
        set wide [expr {rand() < 0.4}]
        set pool [expr {$wide ? $widePool : $smallPool}]
        set dpool [expr {$wide ? $wideDivisors : $smallDivisors}]
        set typed [expr {rand() < 0.7}]
        set p [expr {$typed ? "x: int" : "x"}]
        set q [expr {$typed ? "d: int" : "d"}]
        switch [pick {const const var var narrow loop hash leaf nontail nontail}] {
            const {
                set k [pick $constDivisors]
                set form [pick [list "x.mod([lit $k])" "mod(x, [lit $k])"]]
                lappend fns "fn f$i\($p\):\n    $form\n"
                foreach x [sample $pool 4] { lappend items "f$i\([lit $x])" }
            }
            var {
                lappend fns "fn f$i\($p, $q\):\n    mod(x, d)\n"
                foreach x [sample $pool 4] d [sample $dpool 4] { lappend items "f$i\([lit $x], [lit $d])" }
                if {$errorCall eq "" && rand() < 0.3} {
                    set errorCall "f$i\([lit [pick $pool]], 0)"
                }
            }
            narrow {
                # The divisor's Range inside the guard excludes 0 or not.
                set lo [pick {1 2 -5 -1000 0}]
                set hi [expr {$lo + [pick {0 3 10 1000}]}]
                set xlo [pick {-1000 0 -4611686018427387904}]
                lappend fns "fn f$i\($p, $q\):\n    if x >= [lit $xlo] and x <= 1000000 and d >= [lit $lo] and d <= [lit $hi]:\n        mod(x, d)\n    else:\n        0 - 1\n"
                foreach x [sample $pool 4] d [sample [concat $dpool [list $lo $hi]] 4] {
                    if {$d == 0} { set d 1 }
                    lappend items "f$i\([lit $x], [lit $d])"
                }
            }
            loop {
                set start [pick {0 -50 1000 -4611686018427387000 4611686018427387800}]
                set count [pick {5 17 40}]
                set k [pick [concat $smallDivisors {32 1024 7 -7}]]
                set step [pick {1 3 -2}]
                lappend fns "fn f$i\(i: int, n: int, acc: int) -> int:\n    if i >= n:\n        acc\n    else:\n        f$i\(i + 1, n, acc + (i * [lit $step]).mod([lit $k]))\n"
                lappend items "f$i\([lit $start], [lit [expr {$start + $count}]], 0)"
            }
            hash {
                set cap [pick {1 2 7 8 13 1024}]
                lappend fns "fn f$i\(t: MutableArray\[int\], k) -> int:\n    hash(k).mod(mutable_array::capacity(t))\n"
                foreach x [sample $pool 3] { lappend items "f$i\(mutable_array::create($cap, 0), [lit $x])" }
                if {$errorCall eq "" && rand() < 0.3} {
                    set errorCall "f$i\(mutable_array::create(0, 0), 5)"
                }
            }
            leaf {
                set k [pick $smallDivisors]
                lappend fns "fn f${i}leaf(h, c):\n    h.mod(c)\n"
                lappend fns "fn f$i\($p\):\n    f${i}leaf(x, [lit $k]) + f${i}leaf(x + 1, [lit $k])\n"
                foreach x [sample $pool 3] { lappend items "f$i\([lit $x])" }
            }
            nontail {
                # i steps by DIR toward END on the tail call; the non-tail
                # call jumps it by JUMP (none: i unchanged, the same step,
                # another, backwards or past END, where only fuel stops the
                # chain). Nested, it is made by the first invocation only
                # (fuel == FUEL); as a statement, by every one.
                set dir [pick {1 -1}]
                set end [pick {0 10 -7 100}]
                set dist [pick {1 1 2 3}]
                set start [expr {$end - $dir * $dist}]
                set jump [expr {$dir * [pick [list 0 1 1 2 3 -1 [expr {$dist + 1}]]]}]
                set fuel [pick {4 6 9}]
                set x [pick {100 1000 -1000 7 1023 999999}]
                # The divisor: a power of two at i = START (a mask, were i
                # pinned there), or 0 at a K in the jumped chain, or 0 at a
                # K just before START.
                switch [pick {mask zero zero shift}] {
                    mask { set div "i + [lit [expr {[pick {2 4 8 16}] - $start}]]" }
                    zero { set div "[lit [expr {$start + $jump + $dir * [pick {0 1 2}]}]] - i" }
                    shift { set div "i - [lit [expr {$start - $dir * [pick {1 2 5}]}]]" }
                }
                set stepText [expr {$dir > 0 ? "i + 1" : "i - 1"}]
                set jumpText [expr {$jump == 0 ? "i" : ($jump > 0 ? "i + $jump" : "i - [expr {-$jump}]")}]
                if {rand() < 0.75} {
                    set rest "        x = if fuel == $fuel:\n            f$i\($jumpText, fuel - 1, 0)\n        else:\n            0\n        f$i\($stepText, fuel - 1, acc + x + mod([lit $x], $div))\n"
                } else {
                    set rest "        f$i\($jumpText, fuel - 1, 0)\n        f$i\($stepText, fuel - 1, acc + mod([lit $x], $div))\n"
                }
                lappend fns "fn f$i\(i: int, fuel: int, acc: int) -> int:\n    if i == [lit $end]:\n        acc\n    else:\n        if fuel == 0:\n            return acc\n$rest"
                lappend items "f$i\([lit $start], $fuel, 0)"
            }
        }
    }
    set result "\[[join $items {, }]\]"
    if {$errorCall ne "" && rand() < 0.5} {
        # The zero divisor last, inside the List, so the whole run fails.
        set result "\[[join [concat $items [list $errorCall]] {, }]\]"
    }
    return "[join $fns \n]\n$result\n"
}

# The deep program (the header): an `==` bound char::scalar_value(c) with
# the next c chosen by NEXT -- `parity`, never the next i's value (an 'a',
# 97, before an even i, a 'b', 98, before an odd one: i steps past every
# bound and the run ends at the zero divisor), `threshold`, 'z' (122) where
# i - 1 is T and 'a' elsewhere (it may stop at 97 or 122, or never), or
# `same`, c passed unchanged (the invariant bound) -- the bound reading c as
# FORM says: `direct`, through a local (`d = c`), a struct field (`q.c`, the
# struct rebuilt when c changes), a top-level function returning it
# (`same(c)`), a nested one capturing it (`pick(0)`), a field of a struct
# the invocation builds (`Box{c: c}.c`), an `if` value whose condition reads
# c (`d = if char::scalar_value(c) > 100: c else: c`), or -- with NEXT
# `same` only, since a context is installed once -- a context parameter's
# field (`cfg.c`) -- and a mod of i + OFF, direct or through an inlined
# leaf. NEXT `closure` is the other
# shape: c captured by the closure mk(C0) returns, which at i == HOP makes a
# non-tail self call through its parameter k, holding mk(C1), from i - 1:
# HOP just above C1 (that chain meets C1) or at or below it (it runs past
# C1 to the zero divisor, which OFF then puts below HOP). Returns {TEXT
# {DeepModel arguments}}.
proc deepProgram {} {
    set next [pick {parity parity threshold same same closure closure}]
    set form [pick {direct local field call nested built choice context}]
    set c0 [pick {97 98 122}]
    set c1 [pick {97 98 122}]
    set t [pick {97 122 5000}]
    set x [pick {1000 7 -1000 123456789}]
    set off [pick {0 1 -50 -200}]
    if {$next eq "closure"} {
        set c0 [pick {97 98}]
        set c1 [pick {98 122}]
        if {rand() < 0.6} {
            set hop [expr {$c1 - [pick {0 3 20}]}]
            if {$hop - 1 < -$off} {
                set off [pick {0 1}]
            }
        } else {
            set hop [expr {$c1 + [pick {1 3 100}]}]
        }
    } else {
        set hop 0
    }
    set divText [expr {$off == 0 ? "i" : ($off > 0 ? "i + $off" : "i - [expr {-$off}]")}]
    set text ""
    if {rand() < 0.4} {
        append text "fn bleaf(h, d):\n    h.mod(d)\n\n"
        set term "bleaf([lit $x], $divText)"
    } else {
        set term "mod([lit $x], $divText)"
    }
    set char0 '[format %c $c0]'
    if {$next eq "closure"} {
        append text "fn mk(c: UnicodeChar):\n    fn b(i, acc, k):\n        if i == char::scalar_value(c):\n            acc\n        else:\n            x = if i == $hop:\n                k(i - 1, acc, k)\n            else:\n                0\n            b(i - 1, acc + x + $term, k)\n    b\n\n"
        append text "first = mk($char0)\nother = mk('[format %c $c1]')\nfirst(1114111, 0, other)\n"
        return [list $text [list $next $c0 $t $x $off $c1 $hop]]
    }
    if {$form eq "context" && $next ne "same"} {
        set form direct
    }
    switch $next {
        parity { set nextText "if (i - 1).mod(2) == 0:\n            'a'\n        else:\n            'b'" }
        threshold { set nextText "if i - 1 == $t:\n            'z'\n        else:\n            'a'" }
        same { set nextText "" }
    }
    set param "c: UnicodeChar"
    set start $char0
    set arg [expr {$next eq "same" ? "c" : "n"}]
    set prelude ""
    switch $form {
        direct { set bound c }
        local {
            set prelude "    d = c\n"
            set bound d
        }
        call {
            append text "fn same(u: UnicodeChar) -> UnicodeChar:\n    u\n\n"
            set bound "same(c)"
        }
        nested {
            set prelude "    fn pick(z: int) -> UnicodeChar:\n        c\n"
            set bound "pick(0)"
        }
        field {
            append text "struct Box:\n    c: UnicodeChar\n\n"
            set param "q: Box"
            set start "Box{c: $char0}"
            set bound q.c
            set arg [expr {$next eq "same" ? "q" : "Box{c: n}"}]
        }
        built {
            append text "struct Box:\n    c: UnicodeChar\n\n"
            set bound "Box{c: c}.c"
        }
        choice {
            set prelude "    d = if char::scalar_value(c) > 100:\n        c\n    else:\n        c\n"
            set bound d
        }
        context {
            append text "context struct Cfg:\n    c: UnicodeChar\n\n"
            set param "context cfg: Cfg"
            set bound cfg.c
        }
    }
    set step [expr {$nextText eq "" ? "" : "        n = $nextText\n"}]
    if {$form eq "context"} {
        # The context parameter follows the ordinary ones; the call passes
        # none, and the program installs the one value first.
        append text "fn b(i: int, acc: int, $param) -> int:\n${prelude}    if i == char::scalar_value($bound):\n        acc\n    else:\n        b(i - 1, acc + $term)\n\n"
        append text "with context Cfg {c: $start}\nb(1114111, 0)\n"
    } else {
        append text "fn b(i: int, $param, acc: int) -> int:\n${prelude}    if i == char::scalar_value($bound):\n        acc\n    else:\n${step}        b(i - 1, $arg, acc + $term)\n\n"
        append text "b(1114111, $start, 0)\n"
    }
    return [list $text [list $next $c0 $t $x $off $c1 $hop]]
}

# The outcome of deepProgram's program, computed the way it runs: from
# i = 1114111 down, stop when i is c's scalar value, else add
# mod(X, i + OFF) (core::primitives::modulo: X % |d| in Tcl, whose result
# takes the divisor's sign) or fail with ARITHMETIC when i + OFF is 0. For
# NEXT `closure`, at i == HOP first the nested chain of C1 from i - 1 (its
# value added, its error the program's).
proc DeepModel {next c0 t x off c1 hop} {
    if {$next eq "closure"} {
        return [DeepChain $c0 1114111 0 $x $off $c1 $hop]
    }
    set i 1114111
    set c $c0
    set acc 0
    while 1 {
        if {$i == $c} {
            return [list value $acc]
        }
        switch $next {
            parity { set n [expr {($i - 1) % 2 == 0 ? 97 : 98}] }
            threshold { set n [expr {$i - 1 == $t ? 122 : 97}] }
            same { set n $c }
        }
        set d [expr {$i + $off}]
        if {$d == 0} {
            return [list error {CORE SEMANTIC ARITHMETIC} {mod: division by zero}]
        }
        set acc [expr {$acc + $x % abs($d)}]
        set i [expr {$i - 1}]
        set c $n
        if {$i < -1000} {
            error "DeepModel: no outcome by i = $i"
        }
    }
}

# One closure's chain of DeepModel's `closure` shape: bound C, from I with
# ACC; at i == HOP the other closure's chain (bound C1, which never reaches
# HOP again) from i - 1.
proc DeepChain {c i acc x off c1 hop} {
    while 1 {
        if {$i == $c} {
            return [list value $acc]
        }
        set extra 0
        if {$i == $hop} {
            set nested [DeepChain $c1 [expr {$i - 1}] $acc $x $off $c1 $hop]
            if {[lindex $nested 0] ne "value"} {
                return $nested
            }
            set extra [lindex $nested 1]
        }
        set d [expr {$i + $off}]
        if {$d == 0} {
            return [list error {CORE SEMANTIC ARITHMETIC} {mod: division by zero}]
        }
        set acc [expr {$acc + $extra + $x % abs($d)}]
        set i [expr {$i - 1}]
        if {$i < -1000} {
            error "DeepModel: no outcome by i = $i"
        }
    }
}

proc outcome {kind hir args} {
    if {[catch {
        switch $kind {
            interp  { core::useBackend interp; set r [core::evalProgram [hir::lower $hir]] }
            compile { set r [core::compiler::evalHir $hir] }
            native  { set r [native::evalHir $hir {*}$args] }
        }
    } msg opts]} {
        return [list error [dict get $opts -errorcode] $msg]
    }
    return [list value [core::value::show $r 1]]
}

# Native lowerings compared against the Tcl backends.
set nativeConfigs {
    {}
    {-specialize 0}
    {-repr-opt 0}
    {-tiny-leaf-inline-opt 0}
    {-raw-int-abi-opt 0}
}

set bad 0
set census [dict create]
set kinds [dict create]
set deep 0
set scratch [file tempdir mod-lowering-fuzz]
set seed0 [dict get $options -seed]
set n [dict get $options -n]

# Checks program TEXT (NAME in a report, FILE its file name): against
# interp, with compile and every native configuration, when EXPECTED is "",
# else every native configuration against the outcome EXPECTED. Counts a
# disagreement or a compile failure in ::bad, the reference's outcome kind
# in ::kinds and the mod-family NIR ops in ::census.
proc Check {name file text expected} {
    global scratch nativeConfigs options bad census kinds
    set path [file join $scratch $file.bot]
    set ch [open $path w]
    puts $ch [surface::modules::ImportHeader $text]$text
    close $ch
    if {[catch {set hir [surface::readProgramFile $path -warnings off]} err]} {
        incr bad
        puts "DOES NOT COMPILE $name: $err\n$text"
        file delete $path
        return
    }
    file delete $path
    if {$expected eq ""} {
        set reference [outcome interp $hir]
        set outcomes [list [list interp $reference] [list compile [outcome compile $hir]]]
    } else {
        set reference $expected
        set outcomes [list [list model $reference]]
    }
    set prepared [native::prepareHir $hir]
    foreach config $nativeConfigs {
        lappend outcomes [list "native $config" [outcome native $prepared {*}$config]]
    }
    if {[dict get $options -gc-stress]} {
        set saved [array get ::env BOTLISH_NATIVE_GC_STRESS]
        set ::env(BOTLISH_NATIVE_GC_STRESS) 1
        try {
            foreach config {{} {-specialize 0}} {
                lappend outcomes [list "gc-stress $config" [outcome native $prepared {*}$config]]
            }
        } finally {
            unset ::env(BOTLISH_NATIVE_GC_STRESS)
            array set ::env $saved
        }
    }
    dict incr kinds [lindex $reference 0]
    foreach op [regexp -all -inline {op (?:rimodtotal|rimod|imod|riand|iand)\M} [native::nir $prepared]] {
        dict incr census [lindex $op 1]
    }
    set distinct [lsort -unique [lmap o $outcomes {lindex $o 1}]]
    if {[llength $distinct] != 1} {
        incr bad
        puts "DISAGREEMENT $name:\n$text"
        foreach o $outcomes { puts "  [lindex $o 0]: [lindex $o 1]" }
    }
}

for {set s $seed0} {$s < $seed0 + $n} {incr s} {
    expr {srand($s)}
    Check "seed $s" p$s [program] ""
    if {rand() < 0.5} {
        lassign [deepProgram] text model
        incr deep
        Check "seed $s (deep)" d$s $text [DeepModel {*}$model]
    }
}
file delete -force $scratch
puts "programs $n (seeds $seed0..[expr {$seed0 + $n - 1}]; deep programs $deep; outcomes: $kinds; NIR ops: $census); disagreements $bad"
exit [expr {$bad ? 1 : 0}]
