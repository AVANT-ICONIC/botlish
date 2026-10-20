# fuzz.tcl -- random layouts read through native views, against an
# independent byte model (NATIVE-LAYOUT-VIEWS.md, "Fuzzing").
#
#   tclsh9.0 audit/native-view/tools/fuzz.tcl ?-n N? ?-seed S? ?-backends LIST?
#                                             ?-verbose 0|1? ?-gc-stress 0|1?
#
# Each program declares a chain of random layouts -- one to six scalar fields
# of every width and signedness at random offsets with random gaps (padding)
# between and after them, a random power-of-two alignment, sometimes a layout
# nested by value (two or three levels), and in the outermost layout zero to
# three pointer fields (data pointers std::ffi::c::Ptr[NvTarget] and function
# pointers std::ffi::c::FnPtr[...]) at aligned or unaligned offsets. This script
# draws field values biased toward each encoding's extremes and zero, random
# padding bytes, and for each pointer field null or not; it assembles the
# record's bytes itself (little-endian, two's complement; a non-null data
# pointer the run-time address of a fixture NvTarget record, a function
# pointer a random address), and the program copies them into native memory
# (the test fixture's ffi_fixture::memory) and checks:
#
#   view      every scalar leaf read through std::binary::native::view of the
#             record (nested ones through the nested views) is the value
#             this script decodes from the same bytes itself
#   subview   a nested layout's view, passed to a function taking it, reads
#             its leaves the same
#   pointers  each pointer field read through the view is null exactly when
#             this script wrote zeros, and otherwise exactly the address it
#             wrote; a data pointer reads the NvTarget record through a
#             view of its own
#   bytes     the same bytes as byte storage: std::binary::parse of the layout
#             (pointer-free) -- or of its bits twin, every pointer an inert
#             U64 (native-only) -- gives the model's scalar leaves, and the
#             twin's pointer words equal the pointers' address bits
#   load      std::binary::load of the view: equal to the parse (pointer-free),
#             or, destructured, the same scalars, nested values and
#             pointers (native-only)
#
# The model is independent of the compiler: it never reads a descriptor, a
# registry or generated code, only the layouts it generated. Every program
# is compiled once and run on every backend of -backends (default
# cranelift-generic and cranelift, the backends with native memory; interp
# and compile, when listed, must refuse the view with NATIVE-ONLY). The last
# line is "programs N disagreements D" (audit/native-view/tools/mutate.tcl
# reads it). -gc-stress 1 runs the native backends with
# BOTLISH_NATIVE_GC_STRESS=1. Arbitrary machine addresses are never fuzzed:
# every address a program reads through is the fixture's.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 30 -seed 1 -backends {cranelift-generic cranelift} -verbose 0 -gc-stress 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "fuzz.tcl: unknown option $option" }
    dict set options $option $value
}
source [file join $root compiler compiler.tcl]
source [file join $root native native.tcl]
source [file join $root surface surface.tcl]
set ::core::libraryDir [file join $root stdlib]
core::cabi::installTestFixture
if {[dict get $options -gc-stress]} {
    set ::env(BOTLISH_NATIVE_GC_STRESS) 1
}

# A deterministic generator (a linear congruential sequence: the same seed
# is the same programs on every Tcl).
set ::state [dict get $options -seed]
proc rand {n} {
    set ::state [expr {($::state * 6364136223846793005 + 1442695040888963407) % 18446744073709551616}]
    return [expr {($::state >> 33) % $n}]
}
proc pick {list} {
    return [lindex $list [rand [llength $list]]]
}

# The domain type and range of a scalar of WIDTH bytes, SIGNED.
proc scalarType {width signed} {
    return std::binary::[expr {$signed ? "I" : "U"}][expr {8 * $width}]
}
proc scalarRange {width signed} {
    set bits [expr {8 * $width}]
    if {$signed} {
        return [list [expr {-(2 ** ($bits - 1))}] [expr {2 ** ($bits - 1) - 1}]]
    }
    return [list 0 [expr {2 ** $bits - 1}]]
}

# A random value of a scalar, biased toward its extremes and zero.
proc randomScalar {width signed} {
    lassign [scalarRange $width $signed] lo hi
    switch -- [rand 6] {
        0 { return $lo }
        1 { return $hi }
        2 { return [expr {$signed ? -1 : 0}] }
        3 { return 0 }
        default {
            set span [expr {$hi - $lo + 1}]
            set r 0
            for {set i 0} {$i < 8} {incr i} {
                set r [expr {$r * 256 + [rand 256]}]
            }
            return [expr {$lo + $r % $span}]
        }
    }
}

# The pointer width of every target this runs on (the layouts' pointer
# fields are 8 bytes: core/cabi.tcl's table has no other).
set ::pointerWidth 8
set ::fnType {std::ffi::c::FnPtr[Fn{args: [std::ffi::c::Int], return: std::ffi::c::Int}]}

# A random layout NAME: {name size align fields}, each field {name offset
# scalar width signed}, {name offset layout INNER} with INNER a layout of
# INNERS, or (POINTERS 1) {name offset pointer data|fn}; offsets increase in
# declared order, gaps are padding.
proc randomLayout {name inners pointers} {
    set fields {}
    set offset [rand 3]
    set count [expr {1 + [rand 6]}]
    set pointerCount 0
    for {set i 0} {$i < $count} {incr i} {
        if {$pointers && $pointerCount < 3 && [rand 3] == 0} {
            if {[rand 2]} {
                # Aligned the way a C compiler would place it, or anywhere.
                set offset [expr {($offset + 7) / 8 * 8}]
            }
            lappend fields [list f$i $offset pointer [pick {data data fn}]]
            incr offset $::pointerWidth
            incr pointerCount
        } elseif {$inners ne {} && [rand 3] == 0} {
            set inner [pick $inners]
            lappend fields [list f$i $offset layout $inner]
            incr offset [dict get $inner size]
        } else {
            set width [pick {1 2 4 8}]
            set signed [rand 2]
            lappend fields [list f$i $offset scalar $width $signed]
            incr offset $width
        }
        incr offset [rand 4]
    }
    set size [expr {max(1, $offset + [rand 5])}]
    return [dict create name $name size $size align [pick {1 2 4 8 16 64}] fields $fields]
}

# The declaration of LAYOUT; with BITS, its bits twin NAME: every pointer
# field an inert std::binary::U64.
proc layoutText {layout {bits 0}} {
    set name [dict get $layout name]
    if {$bits} {
        append name Bits
    }
    set lines [list "layout $name:" "    size [dict get $layout size]" "    align [dict get $layout align]"]
    foreach field [dict get $layout fields] {
        lassign $field fname offset kind a b
        switch -- $kind {
            layout { set type [dict get $a name] }
            pointer {
                if {$bits} {
                    set type std::binary::U64
                } elseif {$a eq "data"} {
                    set type {std::ffi::c::Ptr[NvTarget]}
                } else {
                    set type $::fnType
                }
            }
            default { set type [scalarType $a $b] }
        }
        lappend lines "    field $fname: $type at $offset"
    }
    return "[join $lines \n]\n\n"
}

proc hasPointers {layout} {
    foreach field [dict get $layout fields] {
        if {[lindex $field 2] eq "pointer"} {
            return 1
        }
    }
    return 0
}

# A random value of LAYOUT: field -> an Int, a nested value, or a pointer
# {null} | {target} (the NvTarget record's address) | {fn N}.
proc randomValue {layout} {
    set value [dict create]
    foreach field [dict get $layout fields] {
        lassign $field name offset kind a b
        switch -- $kind {
            layout { dict set value $name [randomValue $a] }
            pointer {
                if {[rand 3] == 0} {
                    dict set value $name null
                } elseif {$a eq "data"} {
                    dict set value $name target
                } else {
                    dict set value $name [list fn [expr {1 + [rand 2147483647] * 65536 + [rand 65536]}]]
                }
            }
            default { dict set value $name [randomScalar $a $b] }
        }
    }
    return $value
}

# The model: VALUE of LAYOUT written into BYTES (a list of byte texts: Ints,
# or Botlish expressions for the target address's bytes) at BASE.
proc modelEncode {layout value bytesVar base} {
    upvar 1 $bytesVar bytes
    foreach field [dict get $layout fields] {
        lassign $field name offset kind a b
        set at [expr {$base + $offset}]
        set v [dict get $value $name]
        switch -- $kind {
            layout {
                modelEncode $a $v bytes $at
            }
            pointer {
                for {set i 0} {$i < $::pointerWidth} {incr i} {
                    switch -- [lindex $v 0] {
                        null { set byte 0 }
                        target { set byte "byte_at(t, $i)" }
                        fn { set byte [expr {([lindex $v 1] >> (8 * $i)) & 255}] }
                    }
                    lset bytes [expr {$at + $i}] $byte
                }
            }
            default {
                set u [expr {$v < 0 ? $v + 2 ** (8 * $a) : $v}]
                for {set i 0} {$i < $a} {incr i} {
                    lset bytes [expr {$at + $i}] [expr {($u >> (8 * $i)) & 255}]
                }
            }
        }
    }
}

# The model: {PATH VALUE} of every scalar leaf of LAYOUT decoded from the
# record bytes (Ints: no pointer byte) at BASE, PATH the field path
# ("f2.f0").
proc modelLeaves {layout bytes base {prefix ""}} {
    set leaves {}
    foreach field [dict get $layout fields] {
        lassign $field name offset kind width signed
        set at [expr {$base + $offset}]
        switch -- $kind {
            layout {
                lappend leaves {*}[modelLeaves $width $bytes $at "$prefix$name."]
            }
            scalar {
                set u 0
                for {set i [expr {$width - 1}]} {$i >= 0} {incr i -1} {
                    set u [expr {$u * 256 + [lindex $bytes [expr {$at + $i}]]}]
                }
                if {$signed && $u >= 2 ** (8 * $width - 1)} {
                    set u [expr {$u - 2 ** (8 * $width)}]
                }
                lappend leaves $prefix$name $u
            }
        }
    }
    return $leaves
}

# The text core::value::show gives the LayoutStruct of LAYOUT whose leaves
# are LEAVES (path -> value), PREFIX its path.
proc structText {layout leaves {prefix ""}} {
    set items [lmap field [dict get $layout fields] {
        lassign $field name offset kind inner
        if {$kind eq "layout"} {
            format {%s: %s} $name [structText $inner $leaves "$prefix$name."]
        } else {
            format {%s: %s} $name [dict get $leaves $prefix$name]
        }
    }]
    return "LayoutStruct\[[dict get $layout name]\] \{[join $items {, }]\}"
}

set prelude {direct module

import std::abi
import std::abi::bytes
import std::binary
import std::binary::native
import std::byte
import std::ffi::c
import ffi_fixture

fn bytes_of(values: List[int]) -> std::abi::bytes::Bytes:
    bs = loop v in values:
        b = std::byte::from_int(v):
            on std::byte::BelowRange:
                0
            on std::byte::AboveRange:
                255
        b
    std::abi::bytes::from_list(bs)

fn byte_at(n: int, i: int) -> int:
    bit_and(shift_right(n, 8 * i), 255)

opaque struct NvTarget:
    tag: unit

layout NvTargetRecord:
    size 4
    align 2
    field x: std::binary::I16 at 0
    field y: std::binary::U16 at 2

}

# One program: {SOURCE EXPECTED}, EXPECTED the shown value every native
# backend must produce.
proc program {index} {
    set l0 [randomLayout P${index}a {} 0]
    set layouts [list $l0]
    if {[rand 2]} {
        lappend layouts [randomLayout P${index}b $layouts 0]
    }
    set top [randomLayout P${index}t $layouts [rand 4]]
    lappend layouts $top
    set name [dict get $top name]
    set size [dict get $top size]
    set native [hasPointers $top]
    set value [randomValue $top]
    # Padding and every byte no field covers: random.
    set record {}
    for {set i 0} {$i < $size} {incr i} {
        lappend record [rand 256]
    }
    modelEncode $top $value record 0
    # The model reads its own scalar leaves from the record with every
    # pointer byte zero (a scalar never covers one).
    set plain [lmap byte $record {expr {[string is integer -strict $byte] ? $byte : 0}}]
    set leaves [modelLeaves $top $plain 0]
    set tx [randomScalar 2 1]
    set ty [randomScalar 2 0]

    set text $::prelude
    foreach layout $layouts {
        append text [layoutText $layout]
    }
    if {$native} {
        append text [layoutText $top 1]
    }
    # Each nested layout field of the top: a function reading its leaves.
    set subs {}
    set subExpected {}
    foreach field [dict get $top fields] {
        lassign $field fname offset kind inner
        if {$kind ne "layout"} continue
        set sub [modelLeaves $inner $plain $offset]
        set paths [lmap {p v} [modelLeaves $inner $plain 0] {set p}]
        append text "fn sub_$fname\(w: NativeView\[[dict get $inner name]\]) -> List\[any\]:\n"
        append text "    \[[join [lmap p $paths {string cat w. $p}] {, }]\]\n\n"
        lappend subs "sub_$fname\(v.$fname)"
        lappend subExpected "\[[join [lmap {p v} $sub {set v}] {, }]\]"
    }
    append text "fn record(t: int) -> List\[int\]:\n    \[[join $record {, }]\]\n\n"
    append text "fn check() -> List\[any\] errors NativeViewNull, LayoutLengthMismatch:\n"
    append text "    target = ffi_fixture::memory\[std::ffi::c::Void\](bytes_of(\[[join [concat [list [expr {$tx & 255}] [expr {($tx >> 8) & 255}]] [list [expr {$ty & 255}] [expr {($ty >> 8) & 255}]]] {, }]\]))\n"
    append text "    t = ffi_fixture::address_of(target)\n"
    append text "    xs = record(t)\n"
    append text "    p = ffi_fixture::memory\[std::ffi::c::Void\](bytes_of(xs))\n"
    append text "    v = std::binary::native::view($name, p)\n"
    set checks {}
    set expected {}
    # view
    lappend checks "\[[join [lmap {path v} $leaves {string cat v. $path}] {, }]\]"
    lappend expected "\[[join [lmap {path v} $leaves {set v}] {, }]\]"
    # subview
    lappend checks "\[[join $subs {, }]\]"
    lappend expected "\[[join $subExpected {, }]\]"
    # pointers
    set pointerChecks {}
    set pointerExpected {}
    set k 0
    foreach field [dict get $top fields] {
        lassign $field fname offset kind which
        if {$kind ne "pointer"} continue
        set v [dict get $value $fname]
        append text "    q$k = v.$fname\n"
        switch -- [lindex $v 0] {
            null {
                lappend pointerChecks "\[q$k.null?(), ffi_fixture::address_of(q$k) == 0\]"
                lappend pointerExpected "\[true, true\]"
            }
            target {
                append text "    w$k = std::binary::native::view(NvTargetRecord, q$k)\n"
                lappend pointerChecks "\[q$k.null?(), ffi_fixture::address_of(q$k) == t, w$k.x, w$k.y\]"
                lappend pointerExpected "\[false, true, $tx, $ty\]"
            }
            fn {
                lappend pointerChecks "\[q$k.null?(), ffi_fixture::address_of(q$k) == [lindex $v 1]\]"
                lappend pointerExpected "\[false, true\]"
            }
        }
        incr k
    }
    lappend checks "\[[join $pointerChecks {, }]\]"
    lappend expected "\[[join $pointerExpected {, }]\]"
    # bytes
    if {$native} {
        append text "    s = std::binary::parse(${name}Bits, bytes_of(xs))\n"
        set bitChecks [lmap {path v} $leaves {string cat s. $path}]
        set bitExpected [lmap {path v} $leaves {set v}]
        set k 0
        foreach field [dict get $top fields] {
            lassign $field fname offset kind
            if {$kind ne "pointer"} continue
            lappend bitChecks "s.$fname == ffi_fixture::address_of(q$k)"
            lappend bitExpected true
            incr k
        }
        lappend checks "\[[join $bitChecks {, }]\]"
        lappend expected "\[[join $bitExpected {, }]\]"
    } else {
        append text "    s = std::binary::parse($name, bytes_of(xs))\n"
        lappend checks "\[[join [lmap {path v} $leaves {string cat s. $path}] {, }]\]"
        lappend expected "\[[join [lmap {path v} $leaves {set v}] {, }]\]"
    }
    # load
    if {$native} {
        set binds {}
        set loadChecks {}
        set loadExpected {}
        set k 0
        foreach field [dict get $top fields] {
            lassign $field fname offset kind inner
            lappend binds "$fname: l_$fname"
            switch -- $kind {
                scalar {
                    lappend loadChecks l_$fname
                    lappend loadExpected [dict get $leaves $fname]
                }
                layout {
                    lappend loadChecks l_$fname
                    lappend loadExpected [structText $inner $leaves "$fname."]
                }
                pointer {
                    lappend loadChecks "ffi_fixture::address_of(l_$fname) == ffi_fixture::address_of(q$k)"
                    lappend loadExpected true
                    incr k
                }
            }
        }
        append text "    \{[join $binds {, }]\} = std::binary::load(v)\n"
        lappend checks "\[[join $loadChecks {, }]\]"
        lappend expected "\[[join $loadExpected {, }]\]"
    } else {
        lappend checks "std::binary::load(v) == s"
        lappend expected true
    }
    append text "    \[[join $checks {, }]\]\n\n"
    append text "r = check():\n    on NativeViewNull:\n        \[\]\n    on LayoutLengthMismatch:\n        \[\]\nr\n"
    return [list $text "\[[join $expected {, }]\]"]
}

proc outcome {backend hir} {
    if {[catch {
        switch -- $backend {
            interp {
                core::useBackend interp
                core::evalProgram [hir::lower $hir]
            }
            compile { core::compiler::evalHir $hir }
            cranelift-generic { native::evalHir $hir -specialize 0 }
            cranelift { native::evalHir $hir }
        }
    } result options]} {
        return "error [lindex [dict get $options -errorcode] end]: [string range $result 0 200]"
    }
    return [core::value::show $result]
}

set disagreements 0
set n [dict get $options -n]
for {set i 0} {$i < $n} {incr i} {
    lassign [program $i] text expected
    if {[catch {surface::compile $text fuzz.bot -warnings off} hir compileOptions]} {
        incr disagreements
        puts "program $i: does not compile: $hir"
        if {[dict get $options -verbose]} { puts $text }
        continue
    }
    set bad {}
    foreach backend [dict get $options -backends] {
        set shown [outcome $backend $hir]
        if {$backend in {interp compile}} {
            # No native memory on the Tcl backends: the view is refused.
            if {![string match "error NATIVE-ONLY: *" $shown]} {
                lappend bad "$backend: $shown (expected the NATIVE-ONLY refusal)"
            }
        } elseif {$shown ne $expected} {
            lappend bad "$backend: $shown"
        }
    }
    if {$bad ne {}} {
        incr disagreements
        puts "program $i: expected $expected"
        foreach line $bad { puts "    $line" }
        if {[dict get $options -verbose]} { puts $text }
    } elseif {[dict get $options -verbose]} {
        puts "program $i: ok ([llength [dict get $options -backends]] backends agree: $expected)"
        puts $text
    }
}
puts "programs $n disagreements $disagreements"
exit [expr {$disagreements > 0}]
