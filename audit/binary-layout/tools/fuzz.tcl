# fuzz.tcl -- random fixed layouts against an independent byte model
# (BINARY-LAYOUT.md, report item 48).
#
#   tclsh9.0 audit/binary-layout/tools/fuzz.tcl ?-n N? ?-seed S? ?-backends LIST?
#                                               ?-verbose 0|1? ?-gc-stress 0|1?
#
# Each program declares a few random layouts of the supported subset -- one
# to six scalar fields of every width and signedness at random offsets with
# random gaps (padding) between and after them, a random power-of-two
# alignment, and sometimes a layout nesting another by value -- and checks,
# for random field values biased toward each encoding's extremes and for
# random input bytes (padding included):
#
#   emit      std::binary::emit(v) equals the bytes this script assembles itself
#             (little-endian, two's complement, zero padding: the model)
#   parse     std::binary::parse(L, bytes) equals the LayoutStruct whose fields
#             this script decodes from the same bytes itself
#   round     std::binary::parse(L, std::binary::emit(v)) == v
#   length    one byte more and one byte fewer are LayoutLengthMismatch
#
# The model is independent of the compiler: it never reads a descriptor,
# a registry or generated code, only the layout it generated. Every program
# is compiled once and run on every backend of -backends (default interp,
# compile, cranelift-generic, cranelift); a program disagrees when a backend's
# outcome is not the model's expectation (or the backends differ). The last
# line is "programs N disagreements D" (audit/binary-layout/tools/mutate.tcl
# reads it). -gc-stress 1 runs the native backends with
# BOTLISH_NATIVE_GC_STRESS=1.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 30 -seed 1 -backends {interp compile cranelift-generic cranelift} -verbose 0 -gc-stress 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "fuzz.tcl: unknown option $option" }
    dict set options $option $value
}
source [file join $root compiler compiler.tcl]
source [file join $root native native.tcl]
source [file join $root surface surface.tcl]
set ::core::libraryDir [file join $root stdlib]
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
        3 { return [expr {$lo < 0 ? 0 : 1}] }
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

# A random layout NAME: {name size align fields}, each field {name offset
# kind width signed} (kind scalar) or {name offset layout INNER} with INNER a
# layout of INNERS; offsets increase in declared order, gaps are padding.
proc randomLayout {name inners} {
    set fields {}
    set offset [rand 3]
    set count [expr {1 + [rand 6]}]
    for {set i 0} {$i < $count} {incr i} {
        if {$inners ne {} && [rand 4] == 0} {
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
    set size [expr {$offset + [rand 5]}]
    if {$size < 1} { set size 1 }
    return [dict create name $name size $size align [pick {1 2 4 8 16 64}] fields $fields]
}

proc layoutText {layout} {
    set lines [list "layout [dict get $layout name]:" "    size [dict get $layout size]" "    align [dict get $layout align]"]
    foreach field [dict get $layout fields] {
        lassign $field name offset kind width signed
        if {$kind eq "layout"} {
            lappend lines "    field $name: [dict get $width name] at $offset"
        } else {
            lappend lines "    field $name: [scalarType $width $signed] at $offset"
        }
    }
    return "[join $lines \n]\n\n"
}

# A random value of LAYOUT: a dict field -> Int, or -> a nested value.
proc randomValue {layout} {
    set value [dict create]
    foreach field [dict get $layout fields] {
        lassign $field name offset kind width signed
        if {$kind eq "layout"} {
            dict set value $name [randomValue $width]
        } else {
            dict set value $name [randomScalar $width $signed]
        }
    }
    return $value
}

# The model: the bytes of VALUE of LAYOUT written into BYTES (a list of Ints)
# at BASE.
proc modelEncode {layout value bytesVar base} {
    upvar 1 $bytesVar bytes
    foreach field [dict get $layout fields] {
        lassign $field name offset kind width signed
        set at [expr {$base + $offset}]
        if {$kind eq "layout"} {
            modelEncode $width [dict get $value $name] bytes $at
            continue
        }
        set n [dict get $value $name]
        set u [expr {$n < 0 ? $n + 2 ** (8 * $width) : $n}]
        for {set i 0} {$i < $width} {incr i} {
            lset bytes [expr {$at + $i}] [expr {($u >> (8 * $i)) & 255}]
        }
    }
}

# The model: the value of LAYOUT decoded from BYTES at BASE.
proc modelDecode {layout bytes base} {
    set value [dict create]
    foreach field [dict get $layout fields] {
        lassign $field name offset kind width signed
        set at [expr {$base + $offset}]
        if {$kind eq "layout"} {
            dict set value $name [modelDecode $width $bytes $at]
            continue
        }
        set u 0
        for {set i [expr {$width - 1}]} {$i >= 0} {incr i -1} {
            set u [expr {$u * 256 + [lindex $bytes [expr {$at + $i}]]}]
        }
        if {$signed && $u >= 2 ** (8 * $width - 1)} {
            set u [expr {$u - 2 ** (8 * $width)}]
        }
        dict set value $name $u
    }
    return $value
}

# The construction text of VALUE of LAYOUT.
proc valueText {layout value} {
    set inits [lmap field [dict get $layout fields] {
        set name [lindex $field 0]
        if {[lindex $field 2] eq "layout"} {
            format {%s: %s} $name [valueText [lindex $field 3] [dict get $value $name]]
        } else {
            format {%s: %s} $name [dict get $value $name]
        }
    }]
    return "LayoutStruct\[[dict get $layout name]\] \{[join $inits {, }]\}"
}

proc bytesText {bytes} {
    return "bytes_of(\[[join $bytes {, }]\])"
}

set prelude {import std::abi::bytes
import std::binary
import std::byte

fn bytes_of(values: List[int]) -> std::abi::bytes::Bytes:
    bs = loop v in values:
        b = std::byte::from_int(v):
            on std::byte::BelowRange:
                0
            on std::byte::AboveRange:
                255
        b
    std::abi::bytes::from_list(bs)

}

# One program: {SOURCE EXPECTED}, EXPECTED the shown value every backend
# must produce.
proc program {index} {
    set inner [randomLayout P${index}a {}]
    set layouts [list $inner]
    if {[rand 2]} {
        lappend layouts [randomLayout P${index}b [list $inner]]
    }
    set top [lindex $layouts end]
    set name [dict get $top name]
    set size [dict get $top size]
    set value [randomValue $top]
    set encoded [lrepeat $size 0]
    modelEncode $top $value encoded 0
    set input {}
    for {set i 0} {$i < $size} {incr i} {
        lappend input [rand 256]
    }
    set decoded [modelDecode $top $input 0]
    set longer [concat $input [list [rand 256]]]
    set shorter [lrange $input 0 end-1]
    set text $::prelude
    foreach layout $layouts {
        append text [layoutText $layout]
    }
    append text "fn check() -> List\[any\] errors LayoutLengthMismatch:\n"
    append text "    v = [valueText $top $value]\n"
    append text "    p = std::binary::parse($name, [bytesText $input])\n"
    append text "    \[std::binary::emit(v) == [bytesText $encoded], p == [valueText $top $decoded], std::binary::parse($name, std::binary::emit(v)) == v, std::binary::layout_length($name)\]\n"
    append text "fn length(data: std::abi::bytes::Bytes) -> str:\n"
    append text "    v = std::binary::parse($name, data):\n"
    append text "        on LayoutLengthMismatch:\n"
    append text "            return \"mismatch\"\n"
    append text "    \"parsed\"\n"
    append text "r = check():\n    on LayoutLengthMismatch:\n        \[\]\n"
    append text "\[r, length([bytesText $longer]), length([bytesText $shorter])\]\n"
    set expected "\[\[true, true, true, $size\], \"mismatch\", \"mismatch\"\]"
    return [list $text $expected]
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
        if {$shown ne $expected} {
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
