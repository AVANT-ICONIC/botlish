# binary.tcl -- the binary operations of fixed layouts (BINARY-LAYOUT.md):
# imprinting bytes into a LayoutStruct[L] and emitting one back.
#
#   binary::parse(L, data)          LayoutStruct[L], imprinted from DATA, an
#                                   abi::bytes::Bytes of exactly L's size
#                                   (LayoutLengthMismatch otherwise)
#   binary::emit(value)             the abi::bytes::Bytes of L's size a
#                                   LayoutStruct[L] VALUE emits, L from the
#                                   value's static type
#   binary::layout_length(L)        L's size, a compile-time constant
#   binary::layout_alignment(L)     L's alignment, likewise
#
# L is static evidence, never a value: written as a layout name where these
# operations take it (hir/resolve.tcl resolves it to the layout's descriptor
# constant), or read from the value's static type (hir::layouts::Elaborate
# rewrites binary::emit(v) to the internal binary#emit(v, DESCRIPTOR)). The
# descriptor (hir::layouts::descriptor) is the whole of what these
# implementations know about a layout -- they read no registry -- so a core
# IR program runs them unchanged on any front end's registry state:
#
#   {STRUCTID SIZE ALIGN {FIELD ...}}
#   FIELD = {NAME OFFSET u|i WIDTH ENDIAN}  a scalar: WIDTH bytes, unsigned
#                                           or two's-complement, ENDIAN
#                                           little (the target's)
#         | {NAME OFFSET layout DESCRIPTOR} a nested layout, by value
#
# This file is the reference implementation the interpreter runs, reading the
# descriptor at run time. The Tcl compiler and native lowering read the same
# descriptor statically and emit straight-line code (compiler/compiler.tcl's
# CompileLayoutOperation, native/lower.tcl's LayoutParse / LayoutEmit); none
# of them is a schema walker for a layout it knows.
#
# Semantics, every backend:
#
#   * parse requires exactly L's size: fewer or more bytes is the declared
#     builtin error LayoutLengthMismatch (no prefix parse, no cursor). Every
#     bit pattern of a scalar field is a value of its type (hir/layouts.tcl's
#     "Scalar encodings"), so nothing else can fail. Padding bytes -- bytes no
#     field covers -- are read by no one: two inputs that differ only in
#     padding imprint equal values. The value holds the fields only, never
#     the input (no provenance, no borrowed buffer).
#   * emit writes every field at its offset, recursively for a nested layout,
#     into L's size zero bytes: padding is always zero, so equal values emit
#     equal bytes. A field's value is already in its domain (its type says
#     so), so nothing is truncated; the reference implementation checks it
#     anyway (RANGE: a value no checked program can build).
#   * parse(emit(v)) == v for every v: the fields are written and read at the
#     same offsets with the same encodings.

namespace eval core::binary {
    # Tcl `binary` format letters of the little-endian WIDTH-byte integer.
    variable letters {1 c 2 s 4 i 8 w}
}

# The bytes (a Tcl byte string) of the abi::bytes::Bytes DATA.
proc core::binary::BytesOf {data context} {
    core::value::expect struct $data $context
    set bytesType [core::bytestore::bytesType]
    if {[core::value::structId $data] ne $bytesType} {
        core::semanticError TYPE "$context: expected $bytesType, got [core::value::show $data]"
    }
    return [binary decode hex [core::value::bytestoreHex [core::value::structGet $data [core::bytestore::storageField]]]]
}

# The abi::bytes::Bytes holding the byte string BYTES.
proc core::binary::BytesValue {bytes} {
    return [core::value::structOf [list [core::bytestore::bytesType] [core::bytestore::storageField]] \
        [list [core::value::bytestore [binary encode hex $bytes]]]]
}

# The Tcl `binary scan` / `binary format` field of a scalar of WIDTH bytes,
# SIGN u|i, ENDIAN (SCAN 1 adds the unsigned flag a scan needs).
proc core::binary::Letter {width sign endian {scan 1}} {
    variable letters
    set letter [dict get $letters $width]
    if {$endian eq "big" && $width > 1} {
        set letter [string toupper $letter]
    }
    if {$scan && $sign eq "u"} {
        append letter u
    }
    return $letter
}

# The value DESCRIPTOR imprints from BYTES at byte BASE.
proc core::binary::Decode {descriptor bytes base} {
    lassign $descriptor structId size align fields
    set names {}
    set values {}
    foreach field $fields {
        lassign $field name offset kind
        lappend names $name
        if {$kind eq "layout"} {
            lappend values [Decode [lindex $field 3] $bytes [expr {$base + $offset}]]
            continue
        }
        lassign $field name offset sign width endian
        binary scan $bytes @[expr {$base + $offset}][Letter $width $sign $endian] n
        lappend values [core::value::intFromNumber $n]
    }
    return [core::value::structOf [linsert $names 0 $structId] $values]
}

# BYTES with VALUE (a LayoutStruct of DESCRIPTOR) written at byte BASE.
proc core::binary::Encode {descriptor value bytes base} {
    lassign $descriptor structId size align fields
    if {[core::value::kind $value] ne "struct" || [core::value::structId $value] ne $structId} {
        core::semanticError TYPE "binary::emit: expected a $structId, got [core::value::show $value]"
    }
    foreach field $fields {
        lassign $field name offset kind
        set fieldValue [core::value::structGet $value $name]
        set at [expr {$base + $offset}]
        if {$kind eq "layout"} {
            set bytes [Encode [lindex $field 3] $fieldValue $bytes $at]
            continue
        }
        lassign $field name offset sign width endian
        set n [core::value::intOf $fieldValue]
        set bits [expr {8 * $width}]
        if {$sign eq "u"} {
            set lo 0
            set hi [expr {2 ** $bits - 1}]
        } else {
            set lo [expr {-(2 ** ($bits - 1))}]
            set hi [expr {2 ** ($bits - 1) - 1}]
        }
        if {$n < $lo || $n > $hi} {
            core::semanticError RANGE "binary::emit: field \"$name\" of $structId holds $n, outside its $width-byte encoding $lo..$hi"
        }
        set piece [binary format [Letter $width $sign $endian 0] $n]
        set bytes [string replace $bytes $at [expr {$at + $width - 1}] $piece]
    }
    return $bytes
}

proc core::binary::parse {descriptor data} {
    set descriptor [core::value::strOf $descriptor]
    set bytes [BytesOf $data binary::parse]
    set size [lindex $descriptor 1]
    if {[string length $bytes] != $size} {
        core::native::failDeclared LayoutLengthMismatch \
            "binary::parse: [string length $bytes] bytes given, but the layout [string range [lindex $descriptor 0] 13 end-1] has size $size"
    }
    return [Decode $descriptor $bytes 0]
}

proc core::binary::emit {value descriptor} {
    set descriptor [core::value::strOf $descriptor]
    set size [lindex $descriptor 1]
    return [BytesValue [Encode $descriptor $value [binary format x$size] 0]]
}

# binary::emit before elaboration and the layout queries before resolution
# never run: hir/resolve.tcl replaces a query by its constant, and
# hir::layouts::Elaborate turns every emit whose value has a layout into
# binary#emit. A core IR program that calls one directly has no static
# layout to give it.
proc core::binary::Unelaborated {name args} {
    core::semanticError TYPE "$name: the layout is static (named at the call, or the static type of the emitted value), and this call has none"
}

core::native::declareError LayoutLengthMismatch

core::native::register binary::parse -arity 2 -impl core::binary::parse \
    -param-types {str struct} -result-type struct -result-shape {layout-struct 0} \
    -errors {LayoutLengthMismatch} -layout {operand 0 input 1 op parse} -nomethod 1
core::native::register binary::emit -arity 1 -impl {core::binary::Unelaborated binary::emit} \
    -param-types {struct} -result-type struct -result-shape [list named-struct [core::bytestore::bytesType]] \
    -layout {typed {0 binary#emit}}
core::native::register binary#emit -arity 2 -impl core::binary::emit \
    -param-types {struct str} -result-type struct -result-shape [list named-struct [core::bytestore::bytesType]] \
    -runtime {bytestore-alloc} -layout {operand 1 op emit} -nomethod 1
core::native::register binary::layout_length -arity 1 -impl {core::binary::Unelaborated binary::layout_length} \
    -param-types {any} -result-type int -layout {operand 0 query length} -nomethod 1
core::native::register binary::layout_alignment -arity 1 -impl {core::binary::Unelaborated binary::layout_alignment} \
    -param-types {any} -result-type int -layout {operand 0 query alignment} -nomethod 1
