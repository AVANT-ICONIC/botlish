# fuzz.tcl -- random layouts with unions against an independent byte model
# (LAYOUT-UNIONS.md, "Fuzzing").
#
#   tclsh9.0 audit/layout-unions/tools/fuzz.tcl ?-n N? ?-seed S? ?-backends LIST?
#                                               ?-verbose 0|1? ?-gc-stress 0|1?
#                                               ?-dump DIR?
#
# Each program declares a chain of random representations: unions of one to
# five alternatives (a scalar of every width and signedness, a C scalar, a
# record, an array of any of these, another union, and now and then a C
# pointer alternative that is declared but never read from bytes), each
# union's size its widest alternative's plus random tail padding, its
# alignment random; records holding unions at random offsets with gaps;
# arrays of unions. The outermost declaration is a record holding at least
# one union, or a union. This script draws random input bytes and random
# leaves -- a scalar reached by a path of fields, alternatives and array
# elements -- and computes what the program must give, little-endian and two's
# complement, every alternative at its union's own offset, element i of an
# array at its offset plus i times its element's width (a union's declared
# size):
#
#   read      binary::read(input, L.path) of each leaf is the model's value of
#             the input at the leaf's offset; of a random union-free record or
#             array alternative its copied value
#   write     a chain of binary::write(d, L.path, v) to random leaves --
#             different alternatives of one union overlap, so a later write
#             changes part of an earlier one's bytes -- is the model's bytes
#             after the same writes in order; the operand is unchanged
#   live      (the native backends) the input copied into native memory (the
#             test fixture's): every leaf read through a view (projections
#             through records and unions, binary::element at dynamic indices
#             through arrays); then stores through an edit to the chain's
#             leaves, each followed by a read of another random leaf (one
#             alternative written, another read: interpretation, never
#             conversion, nothing cached) -- the reads and the memory
#             afterwards are the model's
#
# The model is independent of the compiler: it never reads a descriptor, a
# registry or generated code, only the declarations it generated. Every
# program is compiled once; the byte program runs on every backend of
# -backends (default interp, compile, cranelift-generic, cranelift) and the
# live one on the native backends among them. A program disagrees when an
# outcome is not the model's. The last line is "programs N disagreements D"
# (audit/layout-unions/tools/mutate.tcl reads it). -gc-stress 1 runs the
# native backends with BOTLISH_NATIVE_GC_STRESS=1. -dump DIR writes each
# program's two sources into DIR before running them.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 30 -seed 1 -backends {interp compile cranelift-generic cranelift} -verbose 0 -gc-stress 0 -dump ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "fuzz.tcl: unknown option $option" }
    dict set options $option $value
}
source [file join $root compiler compiler.tcl]
source [file join $root native native.tcl]
source [file join $root surface surface.tcl]
set ::core::libraryDir [file join $root lib]
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

# The C scalars of the host's C target (linux-x86_64 and linux-aarch64 alike,
# LP64): name -> {WIDTH SIGNED}. Plain char is left out (its signedness is
# the target's).
set ::cScalars {Short {2 1} UShort {2 0} Int {4 1} UInt {4 0} Long {8 1} ULong {8 0} LongLong {8 1} ULongLong {8 0} SChar {1 1} UChar {1 0}}

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
# Representations: {scalar WIDTH SIGNED TYPE}, {pointer}, {layout L} (L a
# dict {name size align fields}, each field {name offset REPR}), {union U}
# (U a dict {name size align alternatives}, each {name REPR}), {array N REPR}.

proc width {repr} {
    switch -- [lindex $repr 0] {
        scalar { return [lindex $repr 1] }
        pointer { return 8 }
        layout - union { return [dict get [lindex $repr 1] size] }
        array { return [expr {[lindex $repr 1] * [width [lindex $repr 2]]}] }
    }
}

proc randomScalarRepr {} {
    if {[rand 4] == 0} {
        lassign [pick [dict keys $::cScalars]] name
        lassign [dict get $::cScalars $name] width signed
        return [list scalar $width $signed ffi::c::$name]
    }
    set width [pick {1 2 4 8}]
    set signed [rand 2]
    return [list scalar $width $signed binary::[scalarName $width $signed]]
}

# 1 if REPR holds a C pointer, or a union (it then has no copied value).
proc holds {repr what} {
    switch -- [lindex $repr 0] {
        pointer { return [expr {$what eq "pointer"}] }
        scalar { return 0 }
        array { return [holds [lindex $repr 2] $what] }
        layout {
            foreach field [dict get [lindex $repr 1] fields] {
                if {[holds [lindex $field 2] $what]} { return 1 }
            }
            return 0
        }
        union {
            if {$what eq "union"} { return 1 }
            foreach alt [dict get [lindex $repr 1] alternatives] {
                if {[holds [lindex $alt 1] $what]} { return 1 }
            }
            return 0
        }
    }
}

# A random representation, DEPTH levels of nesting at most, drawing on the
# records and unions declared before (DECLARED, {kind REPR} each).
proc randomRepr {depth declared} {
    set r [rand 12]
    if {$depth > 0 && $r < 3} {
        return [list array [expr {1 + [rand 4]}] [randomRepr [expr {$depth - 1}] $declared]]
    }
    if {$declared ne {} && $r < 7} {
        return [pick $declared]
    }
    return [randomScalarRepr]
}

proc randomUnion {name declared} {
    set alternatives {}
    set count [expr {1 + [rand 5]}]
    set widest 0
    for {set i 0} {$i < $count} {incr i} {
        if {[rand 10] == 0} {
            # (A C pointer alternative: declared, never read from bytes.)
            set repr [list pointer]
        } else {
            set repr [randomRepr 2 $declared]
            if {[width $repr] > 48} {
                set repr [randomScalarRepr]
            }
        }
        lappend alternatives [list a$i $repr]
        set widest [expr {max($widest, [width $repr])}]
    }
    set size [expr {$widest + [pick {0 0 0 1 3 4 8}]}]
    return [dict create name $name size $size align [pick {1 2 4 8 16}] alternatives $alternatives]
}

proc randomRecord {name declared} {
    set fields {}
    set offset [rand 3]
    set count [expr {1 + [rand 4]}]
    for {set i 0} {$i < $count} {incr i} {
        set repr [randomRepr 2 $declared]
        if {[width $repr] > 64} {
            set repr [randomScalarRepr]
        }
        lappend fields [list f$i $offset $repr]
        incr offset [width $repr]
        incr offset [rand 4]
    }
    set size [expr {max(1, $offset + [rand 5])}]
    return [dict create name $name size $size align [pick {1 2 4 8}] fields $fields]
}

proc reprText {repr} {
    switch -- [lindex $repr 0] {
        scalar { return [lindex $repr 3] }
        pointer { return "ffi::c::Ptr\[ffi::c::Void\]" }
        layout - union { return [dict get [lindex $repr 1] name] }
        array { return "array [lindex $repr 1] of [reprText [lindex $repr 2]]" }
    }
}

proc declText {repr} {
    set decl [lindex $repr 1]
    if {[lindex $repr 0] eq "union"} {
        set lines [list "union layout [dict get $decl name]:" "    size [dict get $decl size]" "    align [dict get $decl align]"]
        foreach alt [dict get $decl alternatives] {
            lappend lines "    alternative [lindex $alt 0]: [reprText [lindex $alt 1]]"
        }
    } else {
        set lines [list "layout [dict get $decl name]:" "    size [dict get $decl size]" "    align [dict get $decl align]"]
        foreach field [dict get $decl fields] {
            lassign $field name offset inner
            lappend lines "    field $name: [reprText $inner] at $offset"
        }
    }
    return "[join $lines \n]\n\n"
}

# ---------------------------------------------------------------------------
# The model: leaves, values, bytes.

# A random scalar leaf of REPR: {STEPS LEAF OFFSET}, STEPS a list of {field
# NAME}, {alt NAME} and {index I N} steps down to the scalar LEAF at byte
# OFFSET of REPR -- or "" when REPR has no scalar (a pointer alternative).
proc randomLeaf {repr} {
    switch -- [lindex $repr 0] {
        scalar { return [list {} $repr 0] }
        pointer { return "" }
        layout {
            foreach field [lshuffle [dict get [lindex $repr 1] fields]] {
                lassign $field name offset inner
                set leaf [randomLeaf $inner]
                if {$leaf ne ""} {
                    lassign $leaf steps scalar at
                    return [list [linsert $steps 0 [list field $name]] $scalar [expr {$offset + $at}]]
                }
            }
            return ""
        }
        union {
            foreach alt [lshuffle [dict get [lindex $repr 1] alternatives]] {
                lassign $alt name inner
                set leaf [randomLeaf $inner]
                if {$leaf ne ""} {
                    lassign $leaf steps scalar at
                    return [list [linsert $steps 0 [list alt $name]] $scalar $at]
                }
            }
            return ""
        }
        array {
            set i [rand [lindex $repr 1]]
            set leaf [randomLeaf [lindex $repr 2]]
            if {$leaf eq ""} {
                return ""
            }
            lassign $leaf steps scalar at
            return [list [linsert $steps 0 [list index $i [lindex $repr 1]]] $scalar [expr {$i * [width [lindex $repr 2]] + $at}]]
        }
    }
}

# A random subtree of REPR with a copied value (a record or an array holding
# neither a union nor a pointer), reached through fields, alternatives and
# indices: {STEPS REPR OFFSET}, or "".
proc randomCopy {repr} {
    if {[lindex $repr 0] in {layout array} && ![holds $repr union] && ![holds $repr pointer]} {
        return [list {} $repr 0]
    }
    switch -- [lindex $repr 0] {
        layout {
            foreach field [lshuffle [dict get [lindex $repr 1] fields]] {
                lassign $field name offset inner
                set copy [randomCopy $inner]
                if {$copy ne ""} {
                    lassign $copy steps sub at
                    return [list [linsert $steps 0 [list field $name]] $sub [expr {$offset + $at}]]
                }
            }
        }
        union {
            foreach alt [lshuffle [dict get [lindex $repr 1] alternatives]] {
                lassign $alt name inner
                set copy [randomCopy $inner]
                if {$copy ne ""} {
                    lassign $copy steps sub at
                    return [list [linsert $steps 0 [list alt $name]] $sub $at]
                }
            }
        }
        array {
            set i [rand [lindex $repr 1]]
            set copy [randomCopy [lindex $repr 2]]
            if {$copy ne ""} {
                lassign $copy steps sub at
                return [list [linsert $steps 0 [list index $i [lindex $repr 1]]] $sub [expr {$i * [width [lindex $repr 2]] + $at}]]
            }
        }
    }
    return ""
}

proc lshuffle {list} {
    set out {}
    while {$list ne {}} {
        set i [rand [llength $list]]
        lappend out [lindex $list $i]
        set list [lreplace $list $i $i]
    }
    return $out
}

# The scalar of WIDTH bytes at AT of BYTES, two's complement when SIGNED.
proc modelScalar {bytes at width signed} {
    set u 0
    for {set i [expr {$width - 1}]} {$i >= 0} {incr i -1} {
        set u [expr {$u * 256 + [lindex $bytes [expr {$at + $i}]]}]
    }
    if {$signed && $u >= 2 ** (8 * $width - 1)} {
        set u [expr {$u - 2 ** (8 * $width)}]
    }
    return $u
}

# BYTES with the scalar VALUE of WIDTH bytes written at AT.
proc modelStore {bytes at width value} {
    set u [expr {$value < 0 ? $value + 2 ** (8 * $width) : $value}]
    for {set i 0} {$i < $width} {incr i} {
        lset bytes [expr {$at + $i}] [expr {($u >> (8 * $i)) & 255}]
    }
    return $bytes
}

# The Botlish value text of the union-free, pointer-free REPR at AT of BYTES:
# a scalar's Int, a record's LayoutStruct construction, an array's List (of
# scalars through the typed helper: a List literal is a List[int]).
proc copyText {repr bytes at} {
    switch -- [lindex $repr 0] {
        scalar { return [modelScalar $bytes $at [lindex $repr 1] [lindex $repr 2]] }
        layout {
            set decl [lindex $repr 1]
            set inits [lmap field [dict get $decl fields] {
                lassign $field name offset inner
                format {%s: %s} $name [copyText $inner $bytes [expr {$at + $offset}]]
            }]
            return "LayoutStruct\[[dict get $decl name]\] \{[join $inits {, }]\}"
        }
        array {
            set element [lindex $repr 2]
            set stride [width $element]
            set items {}
            for {set i 0} {$i < [lindex $repr 1]} {incr i} {
                lappend items [copyText $element $bytes [expr {$at + $i * $stride}]]
            }
            if {[lindex $element 0] eq "scalar"} {
                return "l[scalarName [lindex $element 1] [lindex $element 2]](\[[join $items {, }]\])"
            }
            return "\[[join $items {, }]\]"
        }
    }
}

# The static designator of STEPS from the top declaration TOP: TOP.f0.a1[2].f3.
proc designator {top steps} {
    set text $top
    foreach step $steps {
        if {[lindex $step 0] eq "index"} {
            append text "\[[lindex $step 1]\]"
        } else {
            append text .[lindex $step 1]
        }
    }
    return $text
}

# The read of STEPS through the native window W (a view or an edit), an
# array's index the parameter i<K> (K counted from START): {EXPR ARGS}.
proc liveRead {w steps startVar} {
    upvar 1 $startVar k
    set expr $w
    set args {}
    foreach step $steps {
        if {[lindex $step 0] eq "index"} {
            set expr "binary::element($expr, i$k)"
            lappend args [list i$k [lindex $step 1]]
            incr k
        } else {
            append expr .[lindex $step 1]
        }
    }
    return [list $expr $args]
}

# The read of STEPS through the native window W at constant indices.
proc constantRead {w steps} {
    set expr $w
    foreach step $steps {
        if {[lindex $step 0] eq "index"} {
            set expr "binary::element($expr, [lindex $step 1])"
        } else {
            append expr .[lindex $step 1]
        }
    }
    return $expr
}

# ---------------------------------------------------------------------------
# Programs

set prelude {import abi
import abi::bytes
import binary
import binary::native
import byte
import ffi::c
import ffi_fixture

fn bytes_of(values: List[int]) -> abi::bytes::Bytes:
    bs = loop v in values:
        b = byte::from_int(v):
            on byte::BelowRange:
                0
            on byte::AboveRange:
                255
        b
    abi::bytes::from_list(bs)

}
foreach width {1 2 4 8} {
    foreach signed {0 1} {
        lassign [scalarRange $width $signed] lo hi
        set n [scalarName $width $signed]
        append prelude "fn c$n\(v: int) -> binary::$n:\n    if v < $lo or v > $hi:\n        0\n    else:\n        v\n\nfn l$n\(xs: List\[int\]) -> List\[binary::$n\]:\n    loop x in xs:\n        c$n\(x)\n\n"
    }
}

# One program: {BYTES-SOURCE BYTES-EXPECTED LIVE-SOURCE LIVE-EXPECTED}.
proc program {index} {
    set declared {}
    set decls ""
    # Two to four declarations before the top one: unions mostly, a record
    # now and then; each may hold the earlier ones.
    set count [expr {2 + [rand 3]}]
    for {set k 0} {$k < $count} {incr k} {
        if {[rand 3] == 0 && $declared ne {}} {
            set repr [list layout [randomRecord R$index$k $declared]]
        } else {
            set repr [list union [randomUnion U$index$k $declared]]
        }
        append decls [declText $repr]
        lappend declared $repr
    }
    # The top: a record holding at least one union, or a union.
    if {[rand 3] == 0} {
        set top [list union [randomUnion T$index $declared]]
    } else {
        set unions [lmap d $declared {expr {[lindex $d 0] eq "union" ? $d : [continue]}}]
        set top [list layout [randomRecord T$index $declared]]
        if {![holds $top union]} {
            # (Force one: the first field a union, alone.)
            set first [lindex [dict get [lindex $top 1] fields] 0]
            lset first 2 [pick $unions]
            set top [list layout [dict create name T$index size [expr {[lindex $first 1] + [width [lindex $first 2]] + [rand 4]}] \
                align [dict get [lindex $top 1] align] fields [list $first]]]
        }
    }
    append decls [declText $top]
    set name [dict get [lindex $top 1] name]
    set size [width $top]
    set input {}
    for {set i 0} {$i < $size} {incr i} {
        lappend input [rand 256]
    }

    # Byte reads: up to six leaves, and a copied subtree when there is one.
    set reads {}
    set readValues {}
    for {set k 0} {$k < 6} {incr k} {
        set leaf [randomLeaf $top]
        if {$leaf eq ""} break
        lassign $leaf steps scalar at
        lappend reads "binary::read(d, [designator $name $steps])"
        lappend readValues [modelScalar $input $at [lindex $scalar 1] [lindex $scalar 2]]
    }
    set copy [randomCopy $top]
    set copyCheck true
    if {$copy ne ""} {
        lassign $copy steps sub at
        set copyCheck "binary::read(d, [designator $name $steps]) == [copyText $sub $input $at]"
    }
    # A chain of writes to random leaves (overlapping alternatives among
    # them), the model applying them in order.
    set writes {}
    set chain {}
    set bytes $input
    for {set k 0} {$k < 1 + [rand 5]} {incr k} {
        set leaf [randomLeaf $top]
        if {$leaf eq ""} break
        lassign $leaf steps scalar at
        set value [randomScalar [lindex $scalar 1] [lindex $scalar 2]]
        set bytes [modelStore $bytes $at [lindex $scalar 1] $value]
        lappend chain [list $steps $scalar $at $value]
    }
    set written $bytes

    set text "$::prelude$decls"
    append text "fn check(d: abi::bytes::Bytes, m: abi::bytes::MutableBytes) -> List\[any\] errors LayoutLengthMismatch:\n"
    append text "    r = \[[join $reads {, }]\]\n"
    set current m
    set k 0
    foreach link $chain {
        lassign $link steps scalar at value
        append text "    w$k = binary::write($current, [designator $name $steps], $value)\n"
        set current w$k
        incr k
    }
    append text "    \[r, $copyCheck, abi::bytes::freeze($current) == bytes_of(\[[join $written {, }]\]), abi::bytes::freeze(m) == d\]\n"
    append text "c = check(bytes_of(\[[join $input {, }]\]), abi::bytes::from_bytes(bytes_of(\[[join $input {, }]\]))):\n    on LayoutLengthMismatch:\n        \[\]\nc\n"
    set expected "\[\[[join $readValues {, }]\], true, true, true\]"

    # The live program: every read leaf through a view at dynamic indices;
    # the chain's stores through an edit by designator, each followed by a
    # read of another random leaf through the edit; the memory afterwards.
    set k 0
    set params {}
    set args {}
    set liveReads {}
    set leaves {}
    for {set j 0} {$j < 4} {incr j} {
        set leaf [randomLeaf $top]
        if {$leaf eq ""} break
        lappend leaves $leaf
    }
    set liveValues {}
    foreach leaf $leaves {
        lassign $leaf steps scalar at
        lassign [liveRead v $steps k] expr exprArgs
        lappend liveReads $expr
        foreach a $exprArgs {
            lappend params "[lindex $a 0]: int"
            lappend args [lindex $a 1]
        }
        lappend liveValues [modelScalar $input $at [lindex $scalar 1] [lindex $scalar 2]]
    }
    set live "direct module\n\n$::prelude$decls"
    append live "fn live([join $params {, }]) -> List\[any\] errors NativeViewNull, NativeEditNull, IndexNotFound:\n"
    append live "    p = ffi_fixture::memory\[ffi::c::Void\](bytes_of(\[[join $input {, }]\]))\n"
    append live "    v = binary::native::view($name, p)\n"
    append live "    e = binary::native::edit($name, p)\n"
    append live "    r = \[[join $liveReads {, }]\]\n"
    set bytes $input
    set after {}
    set afterValues {}
    set k2 0
    foreach link $chain {
        lassign $link steps scalar at value
        append live "    binary::store(e, [designator $name $steps], $value)\n"
        set bytes [modelStore $bytes $at [lindex $scalar 1] $value]
        set other [randomLeaf $top]
        lassign $other osteps oscalar oat
        append live "    s$k2 = [constantRead e $osteps]\n"
        lappend after s$k2
        lappend afterValues [modelScalar $bytes $oat [lindex $oscalar 1] [lindex $oscalar 2]]
        incr k2
    }
    append live "    \[r, \[[join $after {, }]\], ffi_fixture::memory_bytes(p, $size)\]\n"
    append live "res = live([join $args {, }]):\n    on NativeViewNull:\n        \[\]\n    on NativeEditNull:\n        \[\]\n    on IndexNotFound:\n        \[\]\nres\n"
    set liveExpected "\[\[[join $liveValues {, }]\], \[[join $afterValues {, }]\], \[[join $bytes {, }]\]\]"
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
    }
}
puts "programs $n disagreements $disagreements"
