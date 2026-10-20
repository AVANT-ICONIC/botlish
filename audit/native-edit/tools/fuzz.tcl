# fuzz.tcl -- random layout writes, through native edits and into byte
# storage, against an independent byte model (NATIVE-LAYOUT-WRITES.md,
# "Fuzzing").
#
#   tclsh9.0 audit/native-edit/tools/fuzz.tcl ?-n N? ?-seed S? ?-backends LIST?
#                                             ?-verbose 0|1? ?-gc-stress 0|1?
#
# Each program declares a chain of random layouts -- one to six scalar fields
# of every width and signedness at random offsets with random gaps (padding)
# between and after them, a random power-of-two alignment, sometimes a layout
# nested by value (two or three levels) -- and in the outermost layout zero
# to three pointer fields (data pointers std::ffi::c::Ptr[NeTarget] and function
# pointers std::ffi::c::FnPtr[...]), aligned or not. This script draws a random
# initial record (every byte random: padding, fields, pointer words) and one
# to eight writes, each to a random leaf -- a scalar or a pointer, the
# outermost layout's or a nested layout's -- some written through a nested
# edit (std::binary::store(e.f2, INNER.f0, v)), the others through a path from
# the root (std::binary::store(e, TOP.f2.f0, v)); fields may be written more than
# once. Scalar values are biased toward each encoding's extremes and zero; a
# pointer is null, the run-time address of a fixture NeTarget record, or a
# random function address. The script applies the writes to the initial
# bytes itself (little-endian, two's complement; a pointer's address bits),
# and the program
#
#   edit    copies the initial bytes into native memory (the test fixture's
#           ffi_fixture::memory), writes through std::binary::native::edit, and
#           returns the memory's bytes afterwards (ffi_fixture::memory_bytes:
#           a copy made with no layout and no view), every written field read
#           back through the edit (the last value written), and every
#           written pointer's address read back
#   bytes   writes the same values, in the same order, into a MutableBytes of
#           the initial bytes (std::binary::write; std::binary::write_foreign for the
#           pointer fields) and returns its bytes, and the operand's bytes
#           afterwards (unchanged: a write makes a new value)
#
# Both byte lists must equal the model's final bytes exactly -- every byte
# no write owns (padding, other fields, the parts of a record before the
# first write) keeps its initial value -- and the read-backs the last values
# written. The model is independent of the compiler: it never reads a
# descriptor, a registry or generated code, only the layouts it generated.
# Every program runs on every backend of -backends (default the native
# ones; interp and compile, when listed, run the byte half and must refuse
# the edit with NATIVE-ONLY). The last line is "programs N disagreements D"
# (audit/native-edit/tools/mutate.tcl reads it). -gc-stress 1 runs the
# native backends with BOTLISH_NATIVE_GC_STRESS=1. Arbitrary machine
# addresses are never written through: every address a program writes is
# the fixture's own memory.

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
    switch -- [rand 7] {
        0 { return $lo }
        1 { return $hi }
        2 { return [expr {$signed ? -1 : 1}] }
        3 { return 0 }
        4 { return [expr {$signed ? $lo + 1 : $hi - 1}] }
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

set ::pointerWidth 8
set ::fnSig {Fn{args: [std::ffi::c::Int], return: std::ffi::c::Int}}
set ::fnType "std::ffi::c::FnPtr\[$::fnSig\]"

# A random layout NAME: {name size align fields}, each field {name offset
# scalar width signed}, {name offset layout INNER} with INNER a layout of
# INNERS, or (POINTERS 1) {name offset pointer data|fn}.
proc randomLayout {name inners pointers} {
    set fields {}
    set offset [rand 3]
    set count [expr {1 + [rand 6]}]
    set pointerCount 0
    for {set i 0} {$i < $count} {incr i} {
        if {$pointers && $pointerCount < 3 && [rand 3] == 0} {
            if {[rand 2]} {
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

proc layoutText {layout} {
    set lines [list "layout [dict get $layout name]:" "    size [dict get $layout size]" "    align [dict get $layout align]"]
    foreach field [dict get $layout fields] {
        lassign $field fname offset kind a b
        switch -- $kind {
            layout { set type [dict get $a name] }
            pointer { set type [expr {$a eq "data" ? {std::ffi::c::Ptr[NeTarget]} : $::fnType}] }
            default { set type [scalarType $a $b] }
        }
        lappend lines "    field $fname: $type at $offset"
    }
    return "[join $lines \n]\n\n"
}

# Every leaf of LAYOUT: {PATH OFFSET FIELD OWNER OWNERPATH}, PATH the names
# from LAYOUT ("f2.f0"), OFFSET its absolute offset, FIELD its field entry,
# OWNER the layout declaring it and OWNERPATH the path of OWNER from LAYOUT
# ("" for LAYOUT itself, "f2").
proc leaves {layout {base 0} {prefix ""}} {
    set result {}
    foreach field [dict get $layout fields] {
        lassign $field name offset kind a
        set at [expr {$base + $offset}]
        if {$kind eq "layout"} {
            lappend result {*}[leaves $a $at "$prefix$name."]
        } else {
            lappend result [list $prefix$name $at $field $layout [string trimright $prefix .]]
        }
    }
    return $result
}

# A random value for leaf FIELD: an Int, or a pointer {null} | {target} |
# {fn N}.
proc randomValue {field} {
    lassign $field name offset kind a b
    if {$kind eq "pointer"} {
        if {[rand 3] == 0} {
            return null
        }
        if {$a eq "data"} {
            return target
        }
        return [list fn [expr {1 + [rand 2147483647] * 65536 + [rand 65536]}]]
    }
    return [randomScalar $a $b]
}

# The model: VALUE of leaf FIELD written into BYTES at AT (the target's
# address T for a data pointer's `target`).
proc modelWrite {bytesVar at field value t} {
    upvar 1 $bytesVar bytes
    lassign $field name offset kind a
    if {$kind eq "pointer"} {
        switch -- [lindex $value 0] {
            null { set u 0 }
            target { set u $t }
            fn { set u [lindex $value 1] }
        }
        set width $::pointerWidth
    } else {
        set width $a
        set u [expr {$value < 0 ? $value + 2 ** (8 * $a) : $value}]
    }
    for {set i 0} {$i < $width} {incr i} {
        lset bytes [expr {$at + $i}] [expr {($u >> (8 * $i)) & 255}]
    }
}

# The Botlish expression of a write's VALUE (a pointer's: a binding the
# program makes).
proc valueText {value field} {
    switch -- [lindex $value 0] {
        null { return [expr {[lindex $field 3] eq "data" ? "z" : "zf"}] }
        target { return target }
        fn { return fn[lindex $value 1] }
    }
    return $value
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

opaque struct NeTarget:
    tag: unit

}

# One program: {SOURCE BYTESONLY CASE}, BYTESONLY the program without its
# native edit (for the Tcl backends), CASE what the model needs to check an
# outcome: {initial size writes}.
proc program {index} {
    set l0 [randomLayout E${index}a {} 0]
    set layouts [list $l0]
    if {[rand 2]} {
        lappend layouts [randomLayout E${index}b $layouts 0]
    }
    set top [randomLayout E${index}t $layouts [rand 4]]
    lappend layouts $top
    set name [dict get $top name]
    set size [dict get $top size]
    set initial {}
    for {set i 0} {$i < $size} {incr i} {
        lappend initial [rand 256]
    }
    set all [leaves $top]
    set writes {}
    set count [expr {1 + [rand 8]}]
    for {set i 0} {$i < $count} {incr i} {
        lassign [pick $all] path at field owner ownerPath
        # Through a nested edit (when the leaf is a nested layout's) or by a
        # path from the root.
        set nested [expr {$ownerPath ne "" && [rand 2]}]
        lappend writes [list $path $at $field $owner $ownerPath $nested [randomValue $field]]
    }
    set fns {}
    foreach w $writes {
        set v [lindex $w 6]
        if {[lindex $v 0] eq "fn"} {
            dict set fns [lindex $v 1] 1
        }
    }

    set text $::prelude
    foreach layout $layouts {
        append text [layoutText $layout]
    }
    set stores {}
    set bytesWrites {}
    set last d0
    set k 0
    set reads {}
    set pointerReads {}
    set readNames [dict create]
    foreach w $writes {
        lassign $w path at field owner ownerPath nested value
        set v [valueText $value $field]
        if {$nested} {
            lappend stores "    std::binary::store(e.$ownerPath, [dict get $owner name].[lindex $field 0], $v)"
        } else {
            lappend stores "    std::binary::store(e, $name.$path, $v)"
        }
        set op [expr {[lindex $field 2] eq "pointer" ? "write_foreign" : "write"}]
        incr k
        lappend bytesWrites "    d$k = std::binary::$op\(d[expr {$k - 1}], $name.$path, $v)"
        dict set readNames $path [lindex $field 2]
    }
    set last d$k
    dict for {path kind} $readNames {
        if {$kind eq "pointer"} {
            lappend pointerReads $path
        } else {
            lappend reads "e.$path"
        }
    }
    set pointerBinds {}
    set pointerChecks {}
    set i 0
    foreach path $pointerReads {
        lappend pointerBinds "    r$i = e.$path"
        lappend pointerChecks "ffi_fixture::address_of(r$i)"
        incr i
    }
    set setup "    target = ffi_fixture::memory\[NeTarget\](bytes_of(\[1, 2, 3, 4\]))\n    t = ffi_fixture::address_of(target)\n    z = std::ffi::c::null\[NeTarget\]()\n    zf = ffi_fixture::function_address\[$::fnSig\](0)\n"
    foreach f [dict keys $fns] {
        append setup "    fn$f = ffi_fixture::function_address\[$::fnSig\]($f)\n"
    }
    set bytesFn "fn bytes() -> List\[any\] errors LayoutLengthMismatch:\n$setup    d0 = std::abi::bytes::from_bytes(bytes_of(\[[join $initial {, }]\]))\n[join $bytesWrites \n]\n    \[t, std::abi::bytes::freeze($last), std::abi::bytes::freeze(d0)\]\n\n"
    set editFn "fn edit() -> List\[any\] errors NativeEditNull:\n$setup    p = ffi_fixture::memory\[std::ffi::c::Void\](bytes_of(\[[join $initial {, }]\]))\n    e = std::binary::native::edit($name, p)\n[join $stores \n]\n[join $pointerBinds \n][expr {$pointerBinds eq {} ? "" : "\n"}]    \[t, ffi_fixture::memory_bytes(p, $size), \[[join $reads {, }]\], \[[join $pointerChecks {, }]\]\]\n\n"
    set tail "b = bytes():\n    on LayoutLengthMismatch:\n        \[\]\n"
    set both "${text}${bytesFn}${editFn}${tail}x = edit():\n    on NativeEditNull:\n        \[\]\n\[b, x\]\n"
    set bytesOnly "[string range $text [string length "direct module\n\n"] end]${bytesFn}${tail}\[b\]\n"
    return [list $both $bytesOnly [list $initial $size $writes $reads $pointerReads]]
}

# A core value as a Tcl value: a List element-wise, an Int its number, an
# std::abi::bytes::Bytes the list of its bytes, anything else as shown.
proc tclValue {v} {
    switch -- [core::value::kind $v] {
        list { return [lmap item [core::value::items $v] {tclValue $item}] }
        int { return [core::value::intOf $v] }
        struct {
            if {[core::value::structId $v] eq [core::bytestore::bytesType]} {
                set hex [core::value::bytestoreHex [lindex [core::value::structValues $v] 0]]
                return [lmap h [regexp -all -inline .. $hex] {scan $h %x}]
            }
        }
    }
    return [core::value::show $v]
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
        return [list error "[lindex [dict get $options -errorcode] end]: [string range $result 0 200]"]
    }
    return [list value [tclValue $result]]
}

# The model's final bytes of CASE, the target's address being T; and the
# last value written to each scalar path READS and pointer path POINTERS.
proc expectedBytes {case t} {
    lassign $case initial size writes
    set bytes $initial
    foreach w $writes {
        lassign $w path at field owner ownerPath nested value
        modelWrite bytes $at $field $value $t
    }
    return $bytes
}
proc lastValues {case paths t} {
    lassign $case initial size writes
    set last [dict create]
    foreach w $writes {
        lassign $w path at field owner ownerPath nested value
        switch -- [lindex $value 0] {
            null { set value 0 }
            target { set value $t }
            fn { set value [lindex $value 1] }
        }
        dict set last $path $value
    }
    return [lmap path $paths {dict get $last $path}]
}

# The problems of the byte half's outcome B against CASE ("" if none).
proc checkBytes {b case} {
    lassign $case initial size
    if {[llength $b] != 3} {
        return "bytes: [string range $b 0 200]"
    }
    lassign $b t final operand
    set want [expectedBytes $case $t]
    set problems {}
    if {$final ne $want} {
        lappend problems "bytes: got $final, model $want"
    }
    if {$operand ne $initial} {
        lappend problems "bytes: the operand changed to $operand"
    }
    return [join $problems {; }]
}

# The problems of the edit half's outcome X against CASE ("" if none).
proc checkEdit {x case} {
    lassign $case initial size writes reads pointerReads
    if {[llength $x] != 4} {
        return "edit: [string range $x 0 200]"
    }
    lassign $x t memory scalars pointers
    set problems {}
    set want [expectedBytes $case $t]
    if {$memory ne $want} {
        lappend problems "edit: memory $memory, model $want"
    }
    set wantScalars [lastValues $case [lmap r $reads {string range $r 2 end}] $t]
    if {$scalars ne $wantScalars} {
        lappend problems "edit: read back $scalars, written $wantScalars"
    }
    set wantPointers [lastValues $case $pointerReads $t]
    if {$pointers ne $wantPointers} {
        lappend problems "edit: pointers read back $pointers, written $wantPointers"
    }
    return [join $problems {; }]
}

set disagreements 0
set n [dict get $options -n]
for {set i 0} {$i < $n} {incr i} {
    lassign [program $i] text bytesOnly case
    set compiled [dict create]
    set failed 0
    foreach {key source} [list both $text bytes $bytesOnly] {
        if {[catch {surface::compile $source fuzz.bot -warnings off} hir]} {
            incr disagreements
            set failed 1
            puts "program $i ($key): does not compile: $hir"
            if {[dict get $options -verbose]} { puts $source }
            break
        }
        dict set compiled $key $hir
    }
    if {$failed} continue
    set bad {}
    foreach backend [dict get $options -backends] {
        if {$backend in {interp compile}} {
            # No native memory on the Tcl backends: the edit is refused, and
            # the byte half runs alone.
            lassign [outcome $backend [dict get $compiled both]] kind shown
            if {$kind ne "error" || ![string match "NATIVE-ONLY: *" $shown]} {
                lappend bad "$backend: $shown (expected the NATIVE-ONLY refusal)"
            }
            lassign [outcome $backend [dict get $compiled bytes]] kind shown
            set problem [expr {$kind eq "value" ? [checkBytes [lindex $shown 0] $case] : $shown}]
        } else {
            lassign [outcome $backend [dict get $compiled both]] kind shown
            if {$kind ne "value"} {
                set problem $shown
            } else {
                lassign $shown b x
                set problem [join [concat [checkBytes $b $case] [checkEdit $x $case]] {; }]
                set problem [string trim $problem {; }]
            }
        }
        if {$problem ne ""} {
            lappend bad "$backend: $problem"
        }
    }
    if {$bad ne {}} {
        incr disagreements
        puts "program $i: [llength [lindex $case 2]] writes"
        foreach line $bad { puts "    $line" }
        if {[dict get $options -verbose]} { puts $text }
    } elseif {[dict get $options -verbose]} {
        puts "program $i: ok ([llength [dict get $options -backends]] backends agree with the model)"
        puts $text
    }
}
puts "programs $n disagreements $disagreements"
exit [expr {$disagreements > 0}]
