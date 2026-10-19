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
        switch [pick {const const var var narrow loop hash leaf}] {
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
        }
    }
    set result "\[[join $items {, }]\]"
    if {$errorCall ne "" && rand() < 0.5} {
        # The zero divisor last, inside the List, so the whole run fails.
        set result "\[[join [concat $items [list $errorCall]] {, }]\]"
    }
    return "[join $fns \n]\n$result\n"
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
set scratch [file tempdir mod-lowering-fuzz]
set seed0 [dict get $options -seed]
set n [dict get $options -n]
for {set s $seed0} {$s < $seed0 + $n} {incr s} {
    expr {srand($s)}
    set text [program]
    set path [file join $scratch p$s.bot]
    set ch [open $path w]
    puts $ch [surface::modules::ImportHeader $text]$text
    close $ch
    if {[catch {set hir [surface::readProgramFile $path -warnings off]} err]} {
        incr bad
        puts "DOES NOT COMPILE seed $s: $err\n$text"
        file delete $path
        continue
    }
    file delete $path
    set reference [outcome interp $hir]
    set outcomes [list [list interp $reference] [list compile [outcome compile $hir]]]
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
        puts "DISAGREEMENT seed $s:\n$text"
        foreach o $outcomes { puts "  [lindex $o 0]: [lindex $o 1]" }
    }
}
file delete -force $scratch
puts "programs $n (seeds $seed0..[expr {$seed0 + $n - 1}]; outcomes: $kinds; NIR ops: $census); disagreements $bad"
exit [expr {$bad ? 1 : 0}]
