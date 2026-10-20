# c-abi-types.tcl -- the compilation cost of the C ABI type universe
# (C-ABI-TYPES.md, "Compiler performance").
#
#   tclsh9.0 bench/c-abi-types.tcl ?-runs N? ?-k K?
#
# A check for gross mistakes (an instance per pointer type, a quadratic
# type walk, a registry rebuilt per annotation), not a tuning benchmark.
# Generated programs of K functions are compiled by the front end
# (surface::compile) and lowered to NIR (native::nir), best of RUNS:
#
#   ptr-distinct    each function takes four pointers to its own opaque
#                   struct (K distinct pointee identities, 4K Ptr[T]s) and
#                   null-tests them
#   ptr-nested      each takes four pointers nested 6 deep
#                   (Ptr[Ptr[Ptr[Ptr[Ptr[Ptr[Ctx]]]]]])
#   scalars         each takes four C scalars and adds them
#   fnptr           each takes four function pointers of four-argument C
#                   signatures
#   imprinted       each calls std::ffi::c::null[T]() of its own pointee and a
#                   user function with an imprint variable
#
# beside the same programs written with ordinary types: List[S] of K
# ordinary structs for the pointers (one applied type per identity), nested
# List[...] for the nesting, int for the scalars, Fn{...} for the function
# pointers, and plain calls for the imprinted ones. The ratio is the C
# program's time over its ordinary twin's.

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]

set runs 3
set k 100
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -k { set k $value }
        default { error "unknown option $option" }
    }
}

proc nest {t depth} {
    for {set i 0} {$i < $depth} {incr i} { set t "std::ffi::c::Ptr\[$t\]" }
    return $t
}
proc listNest {t depth} {
    for {set i 0} {$i < $depth} {incr i} { set t "List\[$t\]" }
    return $t
}

proc program {shape c k} {
    set text "import std::ffi::c\nimport std::list\n\n"
    for {set i 0} {$i < $k} {incr i} {
        switch -- $shape {
            ptr-distinct {
                if {$c} {
                    append text "opaque struct O$i:\n    t: unit\n\n"
                    append text "fn f${i}(a: std::ffi::c::Ptr\[O$i\], b: std::ffi::c::Ptr\[O$i\], c: std::ffi::c::Ptr\[O$i\], d: std::ffi::c::Ptr\[O$i\]) -> bool:\n    a.null?() and b.null?() and c.null?() and d.null?()\n\n"
                } else {
                    append text "struct O$i:\n    t: unit\n\n"
                    append text "fn f${i}(a: List\[O$i\], b: List\[O$i\], c: List\[O$i\], d: List\[O$i\]) -> bool:\n    std::list::length(a) == 0 and std::list::length(b) == 0 and std::list::length(c) == 0 and std::list::length(d) == 0\n\n"
                }
            }
            ptr-nested {
                if {$i == 0} {
                    append text [expr {$c ? "opaque struct Ctx:\n    t: unit\n\n" : "struct Ctx:\n    t: unit\n\n"}]
                }
                set t [expr {$c ? [nest Ctx 6] : [listNest Ctx 6]}]
                set test [expr {$c ? "%s.null?()" : "std::list::length(%s) == 0"}]
                append text "fn f${i}(a: $t, b: $t, c: $t, d: $t) -> bool:\n    [format $test a] and [format $test b] and [format $test c] and [format $test d]\n\n"
            }
            scalars {
                set ts [expr {$c ? {std::ffi::c::Int std::ffi::c::ULong std::ffi::c::Short std::ffi::c::UChar} : {int int int int}}]
                lassign $ts ta tb tc td
                append text "fn f${i}(a: $ta, b: $tb, c: $tc, d: $td) -> int:\n    a + b + c + d\n\n"
            }
            fnptr {
                set t [expr {$c ? "std::ffi::c::FnPtr\[Fn{args: \[std::ffi::c::Ptr\[std::ffi::c::Void\], std::ffi::c::Int, std::ffi::c::Long, std::ffi::c::Ptr\[std::ffi::c::Char\]\], return: std::ffi::c::Int}\]"
                    : "Fn{args: \[List\[int\], int, int, List\[str\]\], return: int}"}]
                append text "fn f${i}(a: $t, b: $t, c: $t, d: $t) -> int:\n    $i\n\n"
            }
            imprinted {
                if {$i == 0} {
                    append text "fn wrap(xs: List\[T\]) -> List\[T\]:\n    xs\n\nfn wrapi(xs: List\[int\]) -> List\[int\]:\n    xs\n\n"
                }
                if {$c} {
                    append text "opaque struct O$i:\n    t: unit\n\n"
                    append text "fn f${i}() -> int:\n    p = std::ffi::c::null\[O$i\]()\n    n = if p.null?():\n        1\n    else:\n        0\n    n + std::list::length(wrap(\[$i\]))\n\n"
                } else {
                    append text "fn f${i}() -> int:\n    n = 1\n    n + std::list::length(wrapi(\[$i\]))\n\n"
                }
            }
        }
    }
    append text "1\n"
    return $text
}

proc best {script} {
    set best ""
    for {set r 0} {$r < $::runs} {incr r} {
        set t [lindex [time {uplevel 1 $script}] 0]
        if {$best eq "" || $t < $best} { set best $t }
    }
    return $best
}

puts [format "%-14s %12s %12s %8s %12s %12s %8s" shape "C front" "plain front" ratio "C NIR" "plain NIR" ratio]
foreach shape {ptr-distinct ptr-nested scalars fnptr imprinted} {
    set row [list $shape]
    set times {}
    foreach c {1 0} {
        set text [program $shape $c $k]
        set front [best {set hir [surface::compile $text -warnings off]}]
        set nir [best {native::nir $hir}]
        lappend times $front $nir
    }
    lassign $times cf cn pf pn
    puts [format "%-14s %10.1fms %10.1fms %8.2f %10.1fms %10.1fms %8.2f" $shape \
        [expr {$cf / 1000.0}] [expr {$pf / 1000.0}] [expr {double($cf) / $pf}] \
        [expr {$cn / 1000.0}] [expr {$pn / 1000.0}] [expr {double($cn) / $pn}]]
}
puts "k = $k functions per program, best of $runs"
