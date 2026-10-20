# fuzz.tcl -- random layouts with fixed arrays against an independent byte
# model (FIXED-LAYOUT-ARRAYS.md, "Fuzzing and mutation results").
#
#   tclsh9.0 audit/layout-arrays/tools/fuzz.tcl ?-n N? ?-seed S? ?-backends LIST?
#                                               ?-verbose 0|1? ?-gc-stress 0|1?
#                                               ?-dump DIR?
#
# Each program declares a chain of random layouts whose fields are random
# representations at random offsets with random gaps (padding): a scalar of
# every width and signedness, a layout nested by value, or a fixed array of
# one to seven elements whose element is any of these again -- an array of
# arrays (rows), an array of records (whose stride is the record's size, its
# tail padding included) -- up to three levels deep; the outermost layout's
# first field is always an array of scalars, and every other program has no
# array of records (so the Tcl compiler's own reading of rows runs). This script draws a random value
# (scalars biased toward each encoding's extremes and zero) and random input
# bytes (padding included), and computes everything the program must give
# itself, little-endian and two's complement, element i of an array at its
# offset plus i times its element's width:
#
#   emit      std::binary::emit(v) is the model's bytes of v (padding zero)
#   parse     std::binary::parse(L, input) is the model's value of the input
#   round     std::binary::parse(L, std::binary::emit(v)) == v
#   write     std::binary::write(input, L.F, xs) of a random array field F (a whole
#             List), and of one random scalar element named by a static
#             designator (L.F[i][j].g), are the model's bytes; the operand's
#             bytes are unchanged
#   extent    v with the first field's List one element short, and one long,
#             fails with LayoutExtentMismatch (nothing emitted)
#   live      (the native backends) the input copied into native memory (the
#             test fixture's) and viewed: std::binary::load(v) is the model's
#             value; a random scalar element, reached through every array
#             and record on its path at dynamic indices (std::binary::element),
#             is the model's; then through an edit std::binary::store_element
#             (or std::binary::store of a record element's field) writes a random
#             value there and std::binary::store writes the random array field
#             whole -- native memory afterwards is the model's bytes
#             exactly, and an index one past the element's array is
#             IndexNotFound with nothing written
#
# The model is independent of the compiler: it never reads a descriptor, a
# registry or generated code, only the layouts it generated. Every program is
# compiled once; the byte program runs on every backend of -backends (default
# interp, compile, cranelift-generic, cranelift) and the live one on the
# native backends among them. A program disagrees when an outcome is not the
# model's. The last line is "programs N disagreements D"
# (audit/layout-arrays/tools/mutate.tcl reads it). -gc-stress 1 runs the
# native backends with BOTLISH_NATIVE_GC_STRESS=1. -dump DIR writes each
# program's two sources (pI-bytes.bot, pI-live.bot) into DIR before running
# them.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 30 -seed 1 -backends {interp compile cranelift-generic cranelift} -verbose 0 -gc-stress 0 -dump ""]
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

# The domain type, range and helper suffix of a scalar of WIDTH bytes, SIGNED.
proc scalarType {width signed} {
    return std::binary::[scalarName $width $signed]
}
proc scalarName {width signed} {
    return [expr {$signed ? "I" : "U"}][expr {8 * $width}]
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

# ---------------------------------------------------------------------------
# Representations: {scalar WIDTH SIGNED}, {layout LAYOUT} (LAYOUT a dict
# {name size align fields}, each field {name offset REPR}), {array N REPR}.

proc width {repr} {
    switch -- [lindex $repr 0] {
        scalar { return [lindex $repr 1] }
        layout { return [dict get [lindex $repr 1] size] }
        array { return [expr {[lindex $repr 1] * [width [lindex $repr 2]]}] }
    }
}

proc randomScalarRepr {} {
    return [list scalar [pick {1 2 4 8}] [rand 2]]
}

# A random representation DEPTH levels of arrays deep at most, nesting one
# of INNERS (layouts declared before) sometimes -- never as an array's
# element while ::rowsOnly is set (the program's arrays are then all of
# scalars or rows, which the Tcl compiler reads with one counted `binary
# scan` instead of the reference implementation's loop).
proc randomRepr {depth inners {element 0}} {
    set r [rand 10]
    if {$depth > 0 && $r < 4} {
        return [list array [expr {1 + [rand 7]}] [randomRepr [expr {$depth - 1}] $inners 1]]
    }
    if {$inners ne {} && $r < 6 && !($element && $::rowsOnly)} {
        return [list layout [pick $inners]]
    }
    return [randomScalarRepr]
}

proc randomLayout {name inners {firstArray 0}} {
    set fields {}
    set offset [rand 3]
    set count [expr {1 + [rand 5]}]
    for {set i 0} {$i < $count} {incr i} {
        if {$firstArray && $i == 0} {
            set repr [list array [expr {1 + [rand 6]}] [randomScalarRepr]]
        } else {
            set repr [randomRepr 3 $inners]
            # (Kept small: every program writes its bytes out as literals.)
            if {[width $repr] > 160} {
                set repr [randomScalarRepr]
            }
        }
        lappend fields [list f$i $offset $repr]
        incr offset [width $repr]
        incr offset [rand 4]
    }
    set size [expr {$offset + [rand 5]}]
    if {$size < 1} { set size 1 }
    return [dict create name $name size $size align [pick {1 2 4 8 16}] fields $fields]
}

proc reprText {repr} {
    switch -- [lindex $repr 0] {
        scalar { return [scalarType [lindex $repr 1] [lindex $repr 2]] }
        layout { return [dict get [lindex $repr 1] name] }
        array { return "array [lindex $repr 1] of [reprText [lindex $repr 2]]" }
    }
}

proc layoutText {layout} {
    set lines [list "layout [dict get $layout name]:" "    size [dict get $layout size]" "    align [dict get $layout align]"]
    foreach field [dict get $layout fields] {
        lassign $field name offset repr
        lappend lines "    field $name: [reprText $repr] at $offset"
    }
    return "[join $lines \n]\n\n"
}

# ---------------------------------------------------------------------------
# The model: values (an Int, a dict field -> value, a list of values),
# their bytes, their text.

proc randomValue {repr} {
    switch -- [lindex $repr 0] {
        scalar { return [randomScalar [lindex $repr 1] [lindex $repr 2]] }
        layout {
            set value [dict create]
            foreach field [dict get [lindex $repr 1] fields] {
                dict set value [lindex $field 0] [randomValue [lindex $field 2]]
            }
            return $value
        }
        array {
            set items {}
            for {set i 0} {$i < [lindex $repr 1]} {incr i} {
                lappend items [randomValue [lindex $repr 2]]
            }
            return $items
        }
    }
}

proc modelEncode {repr value bytesVar at} {
    upvar 1 $bytesVar bytes
    switch -- [lindex $repr 0] {
        scalar {
            set width [lindex $repr 1]
            set u [expr {$value < 0 ? $value + 2 ** (8 * $width) : $value}]
            for {set i 0} {$i < $width} {incr i} {
                lset bytes [expr {$at + $i}] [expr {($u >> (8 * $i)) & 255}]
            }
        }
        layout {
            foreach field [dict get [lindex $repr 1] fields] {
                lassign $field name offset inner
                modelEncode $inner [dict get $value $name] bytes [expr {$at + $offset}]
            }
        }
        array {
            set stride [width [lindex $repr 2]]
            set i 0
            foreach item $value {
                modelEncode [lindex $repr 2] $item bytes [expr {$at + $i * $stride}]
                incr i
            }
        }
    }
}

proc modelDecode {repr bytes at} {
    switch -- [lindex $repr 0] {
        scalar {
            lassign $repr - width signed
            set u 0
            for {set i [expr {$width - 1}]} {$i >= 0} {incr i -1} {
                set u [expr {$u * 256 + [lindex $bytes [expr {$at + $i}]]}]
            }
            if {$signed && $u >= 2 ** (8 * $width - 1)} {
                set u [expr {$u - 2 ** (8 * $width)}]
            }
            return $u
        }
        layout {
            set value [dict create]
            foreach field [dict get [lindex $repr 1] fields] {
                lassign $field name offset inner
                dict set value $name [modelDecode $inner $bytes [expr {$at + $offset}]]
            }
            return $value
        }
        array {
            set stride [width [lindex $repr 2]]
            set items {}
            for {set i 0} {$i < [lindex $repr 1]} {incr i} {
                lappend items [modelDecode [lindex $repr 2] $bytes [expr {$at + $i * $stride}]]
            }
            return $items
        }
    }
}

# The Botlish expression of VALUE of REPR: a scalar's literal (inside a
# construction, proven in its domain), a record's construction, an array's
# List -- of scalars through the typed helper (a List literal is a
# List[int]: List element types are invariant), of anything else a literal.
proc valueText {repr value} {
    switch -- [lindex $repr 0] {
        scalar { return $value }
        layout {
            set layout [lindex $repr 1]
            set inits [lmap field [dict get $layout fields] {
                lassign $field name offset inner
                format {%s: %s} $name [valueText $inner [dict get $value $name]]
            }]
            return "LayoutStruct\[[dict get $layout name]\] \{[join $inits {, }]\}"
        }
        array {
            set element [lindex $repr 2]
            if {[lindex $element 0] eq "scalar"} {
                return "l[scalarName [lindex $element 1] [lindex $element 2]](\[[join $value {, }]\])"
            }
            return "\[[join [lmap item $value {valueText $element $item}] {, }]\]"
        }
    }
}

proc bytesText {bytes} {
    return "bytes_of(\[[join $bytes {, }]\])"
}

# A random leaf of the value of REPR: {STEPS REPR}, STEPS a list of
# {field NAME LAYOUT} and {index I N} steps from REPR down to a scalar.
proc randomLeaf {repr} {
    switch -- [lindex $repr 0] {
        scalar { return [list {} $repr] }
        layout {
            set layout [lindex $repr 1]
            set field [pick [dict get $layout fields]]
            lassign [randomLeaf [lindex $field 2]] steps leaf
            return [list [linsert $steps 0 [list field [lindex $field 0] [dict get $layout name]]] $leaf]
        }
        array {
            set i [rand [lindex $repr 1]]
            lassign [randomLeaf [lindex $repr 2]] steps leaf
            return [list [linsert $steps 0 [list index $i [lindex $repr 1]]] $leaf]
        }
    }
}

# The model value with the leaf at STEPS replaced by NEW.
proc replaceLeaf {value steps new} {
    if {$steps eq {}} {
        return $new
    }
    set step [lindex $steps 0]
    set rest [lrange $steps 1 end]
    if {[lindex $step 0] eq "field"} {
        dict set value [lindex $step 1] [replaceLeaf [dict get $value [lindex $step 1]] $rest $new]
        return $value
    }
    set i [lindex $step 1]
    lset value $i [replaceLeaf [lindex $value $i] $rest $new]
    return $value
}

proc leafOf {value steps} {
    foreach step $steps {
        if {[lindex $step 0] eq "field"} {
            set value [dict get $value [lindex $step 1]]
        } else {
            set value [lindex $value [lindex $step 1]]
        }
    }
    return $value
}

# The static designator of the leaf at STEPS of layout TOP: TOP.f0[2].f1.
proc designator {top steps} {
    set text $top
    foreach step $steps {
        if {[lindex $step 0] eq "field"} {
            append text .[lindex $step 1]
        } else {
            append text "\[[lindex $step 1]\]"
        }
    }
    return $text
}

# ---------------------------------------------------------------------------
# Programs

set prelude {import std::abi
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

}
foreach width {1 2 4 8} {
    foreach signed {0 1} {
        lassign [scalarRange $width $signed] lo hi
        set n [scalarName $width $signed]
        append prelude "fn c$n\(v: int) -> std::binary::$n:\n    if v < $lo or v > $hi:\n        0\n    else:\n        v\n\nfn l$n\(xs: List\[int\]) -> List\[std::binary::$n\]:\n    loop x in xs:\n        c$n\(x)\n\n"
    }
}

# One seed's programs: {BYTES-SOURCE BYTES-EXPECTED LIVE-SOURCE LIVE-EXPECTED}.
proc program {index} {
    # Every other program's arrays are of scalars and rows only.
    set ::rowsOnly [expr {$index % 2}]
    set inners {}
    set layouts {}
    foreach suffix {a b} {
        if {$suffix eq "b" && [rand 2]} break
        set layout [randomLayout P$index$suffix $inners]
        lappend layouts $layout
        lappend inners $layout
    }
    set top [randomLayout P${index}t $inners 1]
    lappend layouts $top
    set topRepr [list layout $top]
    set name [dict get $top name]
    set size [dict get $top size]
    set value [randomValue $topRepr]
    set encoded [lrepeat $size 0]
    modelEncode $topRepr $value encoded 0
    set input {}
    for {set i 0} {$i < $size} {incr i} {
        lappend input [rand 256]
    }
    set decoded [modelDecode $topRepr $input 0]

    # A whole array field (the first one, or another array field) and a
    # random scalar leaf.
    set arrays [lmap field [dict get $top fields] {expr {[lindex $field 2 0] eq "array" ? $field : [continue]}}]
    lassign [pick $arrays] arrayName arrayOffset arrayRepr
    set arrayValue [randomValue $arrayRepr]
    set written $input
    modelEncode $arrayRepr $arrayValue written $arrayOffset
    lassign [randomLeaf $topRepr] steps leaf
    set leafValue [randomValue $leaf]
    set leafWritten $input
    modelEncode $topRepr [replaceLeaf $decoded $steps $leafValue] leafWritten 0

    # The first field's List one short and one long.
    lassign [lindex [dict get $top fields] 0] firstName - firstRepr
    set firstItems [dict get $value $firstName]
    set short [dict replace $value $firstName [lrange $firstItems 0 end-1]]
    set long [dict replace $value $firstName [concat $firstItems [list [randomValue [lindex $firstRepr 2]]]]]

    set decls ""
    foreach layout $layouts {
        append decls [layoutText $layout]
    }
    set text "$::prelude$decls"
    append text "fn check() -> List\[any\] errors LayoutLengthMismatch, LayoutExtentMismatch:\n"
    append text "    v = [valueText $topRepr $value]\n"
    append text "    p = std::binary::parse($name, [bytesText $input])\n"
    append text "    d = std::abi::bytes::from_bytes([bytesText $input])\n"
    append text "    w = std::binary::write(d, $name.$arrayName, [valueText $arrayRepr $arrayValue])\n"
    append text "    x = std::binary::write(d, [designator $name $steps], [valueText $leaf $leafValue])\n"
    append text "    \[std::binary::emit(v) == [bytesText $encoded], p == [valueText $topRepr $decoded], std::binary::parse($name, std::binary::emit(v)) == v, std::abi::bytes::freeze(w) == [bytesText $written], std::abi::bytes::freeze(x) == [bytesText $leafWritten], std::abi::bytes::freeze(d) == [bytesText $input]\]\n"
    append text "fn extent(v: LayoutStruct\[$name\]) -> str:\n"
    append text "    b = std::binary::emit(v):\n"
    append text "        on LayoutExtentMismatch:\n"
    append text "            return \"extent\"\n"
    append text "    \"emitted\"\n"
    append text "r = check():\n    on LayoutLengthMismatch:\n        \[\]\n    on LayoutExtentMismatch:\n        \[\]\n"
    append text "\[r, extent([valueText $topRepr $short]), extent([valueText $topRepr $long]), extent([valueText $topRepr $value])\]\n"
    set expected "\[\[true, true, true, true, true, true\], \"extent\", \"extent\", \"emitted\"\]"

    # The live program: the leaf read through a view at dynamic indices, an
    # index past its array refused, the leaf stored and the array field
    # stored whole through an edit.
    set params {}
    set args {}
    set read "v"
    set edit "e"
    set lastIndex ""
    set k 0
    foreach step $steps {
        if {[lindex $step 0] eq "field"} {
            set read "$read.[lindex $step 1]"
            set edit "$edit.[lindex $step 1]"
        } else {
            lappend params "i$k: int"
            lappend args [lindex $step 1]
            set read "std::binary::element($read, i$k)"
            set edit "std::binary::element($edit, i$k)"
            set lastIndex [list $k [lindex $step 2]]
            incr k
        }
    }
    # The store: std::binary::store_element when the leaf is an array's element,
    # std::binary::store of the record's field otherwise (at the top level, by
    # its designator).
    set last [lindex $steps end]
    if {[lindex $last 0] eq "index"} {
        set prefix [string range $edit [string length "std::binary::element("] end-[string length ", i[expr {$k - 1}])"]]
        set store "std::binary::store_element($prefix, i[expr {$k - 1}], [valueText $leaf $leafValue])"
    } elseif {[llength $steps] == 1} {
        set store "std::binary::store(e, $name.[lindex $last 1], [valueText $leaf $leafValue])"
    } else {
        set prefix [string range $edit 0 end-[string length ".[lindex $last 1]"]]
        set store "std::binary::store($prefix, [lindex $last 2].[lindex $last 1], [valueText $leaf $leafValue])"
    }
    set storedAll $leafWritten
    modelEncode $arrayRepr $arrayValue storedAll $arrayOffset
    set names [lmap a $params {lindex [split $a :] 0}]
    set live "direct module\n\n$::prelude$decls"
    append live "fn read([join [concat [list "v: NativeView\[$name\]"] $params] {, }]) -> int errors IndexNotFound:\n    $read\n"
    append live "fn put([join [concat [list "e: NativeEdit\[$name\]"] $params] {, }]) -> unit errors IndexNotFound:\n    $store\n"
    set outside "\"none\""
    if {$lastIndex ne ""} {
        # The same store at an index one past its array, through an edit of
        # a copy of the input: IndexNotFound, nothing written.
        lassign $lastIndex at extent
        set past $args
        lset past $at $extent
        append live "fn attempt([join [concat [list "e: NativeEdit\[$name\]"] $params] {, }]) -> str:\n"
        append live "    put([join [concat e $names] {, }]):\n        on IndexNotFound:\n            return \"refused\"\n    \"stored\"\n"
        append live "fn past() -> str errors NativeEditNull:\n"
        append live "    m = ffi_fixture::memory\[std::ffi::c::Void\]([bytesText $input])\n"
        append live "    e = std::binary::native::edit($name, m)\n"
        append live "    outcome = attempt([join [concat e $past] {, }])\n"
        append live "    if ffi_fixture::memory_bytes(m, $size) == \[[join $input {, }]\]:\n        outcome\n    else:\n        \"written\"\n"
        set outside "\"refused\""
    }
    append live "fn live([join $params {, }]) -> List\[any\] errors NativeViewNull, NativeEditNull, IndexNotFound, LayoutExtentMismatch, LayoutLengthMismatch:\n"
    append live "    p = ffi_fixture::memory\[std::ffi::c::Void\]([bytesText $input])\n"
    append live "    v = std::binary::native::view($name, p)\n"
    append live "    e = std::binary::native::edit($name, p)\n"
    append live "    loaded = std::binary::load(v) == std::binary::parse($name, [bytesText $input])\n"
    append live "    leaf = read([join [concat v $names] {, }])\n"
    append live "    refused = [expr {$lastIndex ne "" ? "past()" : "\"none\""}]\n"
    append live "    q = std::ffi::c::clone(p)\n"
    append live "    before = ffi_fixture::memory_bytes(q, $size)\n"
    append live "    put([join [concat e $names] {, }])\n"
    append live "    std::binary::store(e, $name.$arrayName, [valueText $arrayRepr $arrayValue])\n"
    append live "    \[loaded, leaf, refused, before == \[[join $input {, }]\], ffi_fixture::memory_bytes(p, $size)\]\n"
    append live "r = live([join $args {, }]):\n    on NativeViewNull:\n        \[\]\n    on NativeEditNull:\n        \[\]\n    on IndexNotFound:\n        \[\]\n    on LayoutExtentMismatch:\n        \[\]\n    on LayoutLengthMismatch:\n        \[\]\nr\n"
    set liveExpected "\[true, [leafOf $decoded $steps], $outside, true, \[[join $storedAll {, }]\]\]"
    return [list $text $expected $live $liveExpected]
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
set native [lmap backend [dict get $options -backends] {expr {$backend in {cranelift-generic cranelift} ? $backend : [continue]}}]
for {set i 0} {$i < $n} {incr i} {
    lassign [program $i] text expected live liveExpected
    if {[dict get $options -verbose]} { puts stderr "program $i ..." }
    if {[dict get $options -dump] ne ""} {
        file mkdir [dict get $options -dump]
        foreach {kind source} [list bytes $text live $live] {
            set channel [open [file join [dict get $options -dump] p$i-$kind.bot] w]
            fconfigure $channel -encoding utf-8 -translation lf
            puts -nonewline $channel $source
            close $channel
        }
    }
    set bad {}
    foreach {source want backends kind} [list $text $expected [dict get $options -backends] bytes $live $liveExpected $native live] {
        if {$backends eq {}} continue
        if {[catch {surface::compile $source fuzz.bot -warnings off} hir]} {
            lappend bad "$kind: does not compile: $hir"
            if {[dict get $options -verbose]} { puts $source }
            continue
        }
        foreach backend $backends {
            if {[dict get $options -verbose]} { puts stderr "    $kind $backend" }
            set shown [outcome $backend $hir]
            if {$shown ne $want} {
                lappend bad "$kind $backend: $shown (expected $want)"
            }
        }
        if {$bad ne {} && [dict get $options -verbose]} { puts $source }
    }
    if {$bad ne {}} {
        incr disagreements
        puts "program $i:"
        foreach line $bad { puts "    $line" }
    } elseif {[dict get $options -verbose]} {
        puts "program $i: ok"
        puts $text
        puts $live
    }
}
puts "programs $n disagreements $disagreements"
exit [expr {$disagreements > 0}]
