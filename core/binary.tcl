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
        if {$kind eq "ptr"} {
            # Statically LAYOUT-NATIVE-ONLY (hir/layouts.tcl): arbitrary
            # bytes never become a pointer.
            core::semanticError TYPE "binary::parse: field \"$name\" of [lindex $descriptor 0] is a C pointer, which is never imprinted from bytes"
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
        if {$kind eq "ptr"} {
            core::semanticError TYPE "binary::emit: field \"$name\" of $structId is a C pointer, which is never written into bytes"
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

# The path of the first pointer field of DESCRIPTOR ("link.next"), or "":
# such a layout is native-only (NATIVE-LAYOUT-VIEWS.md), statically
# LAYOUT-NATIVE-ONLY for parse and emit -- refused here too, for a program
# compiled unchecked (-strict 0) or core IR written by hand.
proc core::binary::PointerPath {descriptor} {
    foreach field [lindex $descriptor 3] {
        lassign $field name offset kind
        if {$kind eq "ptr"} {
            return $name
        }
        if {$kind eq "layout"} {
            set inner [PointerPath [lindex $field 3]]
            if {$inner ne ""} {
                return $name.$inner
            }
        }
    }
    return ""
}

proc core::binary::RefuseNativeOnly {operation descriptor} {
    set path [PointerPath $descriptor]
    if {$path ne ""} {
        core::semanticError LAYOUT-NATIVE-ONLY \
            "$operation: field \"$path\" of [lindex $descriptor 0] is a C pointer, which bytes never become and are never written from (a layout with a pointer field is read through a native view only)"
    }
}

proc core::binary::parse {descriptor data} {
    set descriptor [core::value::strOf $descriptor]
    RefuseNativeOnly binary::parse $descriptor
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
    RefuseNativeOnly binary::emit $descriptor
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

# ---------------------------------------------------------------------------
# Read-only native views (NATIVE-LAYOUT-VIEWS.md)
#
#   binary::native::view(L, p)      NativeView[L]: the live native memory the
#                                   data pointer P (an ffi::c::Ptr[T])
#                                   addresses, read through layout L
#                                   (NativeViewNull for a null P). P is
#                                   observed; the view is P's address word.
#   v.field                         one field read at its offset: a scalar's
#                                   Int, a nested layout's NativeView[Inner]
#                                   (its address plus the offset, nothing
#                                   read), a pointer field's ffi::c::Ptr /
#                                   FnPtr (hir::layouts::Elaborate rewrites
#                                   the projection to the internal
#                                   binary#view_field(v, FIELD), FIELD the
#                                   field's descriptor entry)
#   binary::load(v)                 LayoutStruct[L]: every field read once,
#                                   L from the view's static type (elaborated
#                                   to binary#load(v, DESCRIPTOR))
#
# binary::native is an intrinsic namespace designated direct
# (DIRECT-MODULES.md): reading live process memory is raw authority, so a
# call of view is a direct edge of its module. Reading a view (a projection,
# binary::load) is not: the view is the authority, already granted.
#
# The Tcl backends have no native memory: a null pointer is NativeViewNull
# on every backend, and any other view is refused (NATIVE-ONLY) -- nothing
# imitates a memory read. The native backend lowers each operation to
# straight-line loads (native/lower.tcl's LayoutCall; runtime/nview.rs).

proc core::binary::NativeOnly {operation} {
    core::semanticError NATIVE-ONLY \
        "$operation reads live native process memory, which only the native backends (cranelift, cranelift-generic, a native executable) have; the Tcl backends (interp, compile) have no native address space and do not imitate one"
}

proc core::binary::nativeView {descriptor p} {
    set descriptor [core::value::strOf $descriptor]
    if {[core::cabi::addressOf $p] == 0} {
        core::native::failDeclared NativeViewNull \
            "binary::native::view: the pointer is null, so there is no [string range [lindex $descriptor 0] 13 end-1] to read"
    }
    NativeOnly binary::native::view
}

proc core::binary::viewField {view field} {
    NativeOnly "a native view's field read"
}

proc core::binary::load {view descriptor} {
    NativeOnly binary::load
}

core::native::declareError LayoutLengthMismatch
core::native::declareError NativeViewNull

core::native::register binary::parse -arity 2 -impl core::binary::parse \
    -param-types {str struct} -result-type struct -result-shape {layout-struct 0} \
    -errors {LayoutLengthMismatch} -layout {operand 0 input 1 op parse} -nomethod 1
core::native::register binary::emit -arity 1 -impl {core::binary::Unelaborated binary::emit} \
    -param-types {struct} -result-type struct -result-shape [list named-struct [core::bytestore::bytesType]] \
    -ownership {observe} -layout {typed {0 binary#emit}}
core::native::register binary#emit -arity 2 -impl core::binary::emit \
    -param-types {struct str} -result-type struct -result-shape [list named-struct [core::bytestore::bytesType]] \
    -runtime {bytestore-alloc} -ownership {observe observe} -layout {operand 1 op emit} -nomethod 1
core::native::register binary::layout_length -arity 1 -impl {core::binary::Unelaborated binary::layout_length} \
    -param-types {any} -result-type int -layout {operand 0 query length} -nomethod 1
core::native::register binary::layout_alignment -arity 1 -impl {core::binary::Unelaborated binary::layout_alignment} \
    -param-types {any} -result-type int -layout {operand 0 query alignment} -nomethod 1
core::native::register binary::native::view -arity 2 -impl core::binary::nativeView \
    -param-types {str any} -result-type any -result-shape {native-view 0} -ownership {observe observe} \
    -errors {NativeViewNull} -layout {operand 0 pointer 1 op view} -nomethod 1
core::native::register binary::load -arity 1 -impl {core::binary::Unelaborated binary::load} \
    -param-types {any} -result-type struct -result-shape {view-struct 0} -ownership {observe} \
    -layout {viewed {0 binary#load}}
core::native::register binary#load -arity 2 -impl core::binary::load \
    -param-types {any str} -result-type struct -result-shape {layout-struct 1} -ownership {observe observe} \
    -layout {operand 1 op load} -nomethod 1
core::native::register binary#view_field -arity 2 -impl core::binary::viewField \
    -param-types {any str} -result-type any -result-shape {view-field 0 1} -ownership {observe observe} \
    -layout {field 1 op field} -nomethod 1
# Reading live process memory is raw authority (DIRECT-MODULES.md): every
# call of binary::native::view is a direct edge of the module making it.
core::native::declareDirectNamespace binary::native
