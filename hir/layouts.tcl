# layouts.tcl -- fixed binary layouts and LayoutStruct[L] (BINARY-LAYOUT.md).
#
#   hir::layouts::apply DECLS        => HIR `sourceTypes` entries of the layouts
#   hir::layouts::lookup NAME NS     => declaration identity, or ""
#   hir::layouts::declared ID        => 1 if ID is a registered layout
#   hir::layouts::entry ID           => the resolved layout (below)
#   hir::layouts::structId ID        => "LayoutStruct[ID]", the identity of
#                                       the struct view of layout ID
#   hir::layouts::structType ID      => {nstruct LayoutStruct[ID]}
#   hir::layouts::descriptor ID      => the static descriptor (below)
#
# Vocabulary
# ----------
#   layout          a compile-time schema of a fixed number of physical
#                   bytes, declared `layout Name:`. Not a struct, a type, a
#                   type alias, a function or a value: a declaration with
#                   nominal identity, named only in a type (LayoutStruct[L],
#                   a layout field) or as the layout operand of a binary
#                   operation (binary::parse(L, data), binary::layout_length(L))
#   LayoutStruct[L] the immutable structural value imprinting with layout L
#                   produces: one field per layout field, nothing else (no
#                   padding, no offsets)
#   imprinting      bytes + the static evidence L -> LayoutStruct[L]; its
#                   inverse, emission, LayoutStruct[L] -> bytes, reads L from
#                   the value's static type
#   descriptor      the self-contained static text of one resolved layout
#                   that the binary operations carry as a constant argument
#                   (so no backend reads this registry)
#
# A layout's identity is its declaration identity, exactly a named struct's
# or an enum's: the declared name for the entry program and
# "namespace::Name" for a module's. Two layouts with identical fields,
# offsets, size and alignment are distinct layouts, and LayoutStruct[A] and
# LayoutStruct[B] distinct types. Layouts share the one type namespace of
# structs, enums, traits and source types: a layout field names an integer
# domain or a nested layout by one spelling, which must never be ambiguous.
#
# The resolved layout (the registry entry; the one authoritative
# representation -- nothing else records an offset, a width or a size):
#
#   {id ID name NAME namespace NS size N align A span SPAN fields FIELDS}
#
# FIELDS in declared order, each
#
#   {name F offset O kind scalar width W signed 0|1 endian little type T}
#   {name F offset O kind layout layout INNER width W type T}
#   {name F offset O kind pointer width W endian little type T}
#
# where T is the field's consumer type -- the declared integer domain
# (`{refined int {binary::U16}}`), `{nstruct LayoutStruct[INNER]}`, or the
# declared C pointer type (`{cptr P}`, ffi::c::Ptr[P]; `{cfnptr F}`,
# ffi::c::FnPtr[F]) -- and W its byte width (a nested layout's width is its
# size, a pointer's the compilation's C target's pointer width). `endian` is
# the byte order: the target's, little-endian on every supported target; it
# is recorded per field so an explicit big-endian encoding is one more value
# here, never a new representation.
#
# Pointer fields (NATIVE-LAYOUT-VIEWS.md). A field may hold a C data or
# function pointer: its width and placement are representation facts like a
# scalar's, but its meaning is authority -- an address some foreign code
# handed out. So a layout with a pointer field (directly or in a nested
# layout) is *native-only*: it is read through a native view of live native
# memory (NativeView[L], binary::load), where the pointer is the one that
# memory holds, and never imprinted from bytes (binary::parse would make a
# pointer out of arbitrary bytes) or emitted into them (writing pointers is a
# later milestone's): both are LAYOUT-NATIVE-ONLY. A pointer field's
# pointee may name an opaque struct, which is registered after the layouts:
# the width (the target's) is known at once, so the declaration checks run
# as for any field, and the pointer type itself is resolved after the
# structs (ResolvePointers).
#
# Native views (NATIVE-LAYOUT-VIEWS.md). NativeView[L] is {nview L}: a
# window onto live native memory read through layout L, whose run-time value
# is the address word of the pointer it was made from. Its fields are L's,
# each read when projected: a scalar's integer domain, a nested layout's
# NativeView[INNER] (no load: the inner layout's address), a pointer's
# declared C pointer type (ViewFieldType). The same registry entry and the
# same descriptor serve both backings -- bytes (LayoutStruct[L]) and native
# memory (NativeView[L]); nothing here describes a layout twice.
#
# Scalar encodings. A scalar field's type is an integer domain whose value
# set is exactly the value set of one fixed-width two's-complement or
# unsigned encoding: 0..2^(8k)-1 (unsigned) or -2^(8k-1)..2^(8k-1)-1
# (signed), k in 1, 2, 4, 8. The encoding is the domain's: every one of the
# eight value sets is distinct, so the width and signedness follow from the
# declared type alone, with no table of names (`binary::U16`, `abi::U16Value`,
# `byte::Byte` -- 0..255, an unsigned byte -- all qualify). Because the
# domain is exactly the encoding's value set, every bit pattern decodes to a
# value of the field's type (parse cannot fail on a field) and every value of
# the type encodes (emit cannot truncate). `int` (no finite width), a domain
# of another interval, an exact-set domain and a refinement (whose values
# carry a proof imprinting cannot make) are not scalar field types.
#
# The struct view. LayoutStruct[L] is the named-struct type {nstruct
# LayoutStruct[L]}: every consumer -- projection, destructuring, equality,
# hashing, printing, the struct analyses, scalar replacement, every
# backend's struct representation -- sees an ordinary immutable named struct
# whose declaration identity is the string "LayoutStruct[L]" (which no
# source declaration can spell). Its schema is never registered as a struct:
# hir/structs.tcl's accessors answer for such an identity from this
# registry (StructNames, StructFieldTypes), so the field set is mechanically
# L's and is recorded once. There is no `LayoutStruct Foo:`, no `struct
# Foo[T]:` and no generic struct declaration of any kind.
#
# Compilation isolation: the registry is captured and installed with the
# other declaration registries (hir/declarations.tcl); it is reset with the
# source types (hir::sourcetypes::Reset) and filled by hir::sourcetypes::
# apply from the `kind layout` entries of -type-decls, after the integer
# domains a field may name and before the structs whose fields may name
# LayoutStruct[L].

namespace eval hir::layouts {
    # ID -> the resolved layout (the file header).
    variable registry [dict create]
    # The eight scalar encodings: {WIDTH SIGNED} -> {MIN MAX}.
    variable encodings [dict create \
        {1 0} {0 255} {2 0} {0 65535} {4 0} {0 4294967295} {8 0} {0 18446744073709551615} \
        {1 1} {-128 127} {2 1} {-32768 32767} {4 1} {-2147483648 2147483647} \
        {8 1} {-9223372036854775808 9223372036854775807}]
    # The largest alignment a layout may state (2^28): far beyond any target's
    # page size, small enough that no arithmetic on it is ever large.
    variable maxAlign 268435456
    # The largest size a layout may state: a fixed layout is a record, not a
    # buffer (2^31 - 1 bytes).
    variable maxSize 2147483647
}

proc hir::layouts::Reset {} {
    variable registry
    set registry [dict create]
}

proc hir::layouts::Fail {span message {kind TYPE}} {
    if {$span eq ""} {
        core::semanticError $kind $message
    }
    core::semanticError $kind "[dict get $span file]:[dict get $span line]:[dict get $span column]: $message"
}

# The declaration identity of a layout NAME declared in module NAMESPACE (""
# for the entry program).
proc hir::layouts::identity {name namespace} {
    return [expr {$namespace eq "" ? $name : "${namespace}::${name}"}]
}

# 1 if ID is a registered layout declaration identity.
proc hir::layouts::declared {id} {
    variable registry
    return [dict exists $registry $id]
}

# The resolved layout ID (the file header's form).
proc hir::layouts::entry {id} {
    variable registry
    return [dict get $registry $id]
}

# The identity the layout spelling NAME (as written: "Pair", "geo::Pair")
# denotes in code of module namespace NS ("" for the entry program), or "":
# a qualified spelling is exactly that declaration, a bare one the code's own
# namespace's -- a named struct's visibility (no `import type`: a layout is
# not a type).
proc hir::layouts::lookup {name {ns ""}} {
    variable registry
    if {[dict size $registry] == 0} {
        return ""
    }
    if {[string first :: $name] >= 0} {
        return [expr {[dict exists $registry $name] ? $name : ""}]
    }
    set id [identity $name $ns]
    return [expr {[dict exists $registry $id] ? $id : ""}]
}

# The identity of the struct view of layout ID.
proc hir::layouts::structId {id} {
    return "LayoutStruct\[$id\]"
}

proc hir::layouts::structType {id} {
    return [list nstruct [structId $id]]
}

# The layout whose struct view has the declaration identity STRUCTID
# ("LayoutStruct[ID]"), or "" if STRUCTID is no registered layout's view.
proc hir::layouts::OfStructId {structId} {
    variable registry
    if {![string match {LayoutStruct\[*\]} $structId]} {
        return ""
    }
    set id [string range $structId 13 end-1]
    return [expr {[dict exists $registry $id] ? $id : ""}]
}

# The layout of TYPE when TYPE is a LayoutStruct type, else "".
proc hir::layouts::OfType {type} {
    if {![hir::types::IsNamedStruct $type]} {
        return ""
    }
    return [OfStructId [lindex $type 1]]
}

# The field names of layout ID, in declared order: the slot order of its
# struct view.
proc hir::layouts::StructNames {id} {
    return [lmap field [dict get [entry $id] fields] {dict get $field name}]
}

# {FIELD TYPE ...} of the struct view of layout ID, in declared order.
proc hir::layouts::StructFieldTypes {id} {
    set result {}
    foreach field [dict get [entry $id] fields] {
        lappend result [dict get $field name] [dict get $field type]
    }
    return $result
}

proc hir::layouts::size {id} {
    return [dict get [entry $id] size]
}

proc hir::layouts::align {id} {
    return [dict get [entry $id] align]
}

# The static descriptor of layout ID: a Tcl list
#
#   {STRUCTID SIZE ALIGN {FIELD ...}}
#
# STRUCTID the struct view's identity (the Tcl struct head is STRUCTID
# followed by the field names), each FIELD {NAME OFFSET u|i WIDTH ENDIAN} for
# a scalar, {NAME OFFSET layout DESCRIPTOR} for a nested layout or {NAME
# OFFSET ptr WIDTH ENDIAN} for a pointer (read only through a native view),
# in declared order. It is the whole of what imprinting and emission need, so it is the
# constant argument the binary operations carry (core/binary.tcl reads it at
# run time on the interpreter; the Tcl compiler and native lowering read it
# statically). One layout has exactly one descriptor text.
proc hir::layouts::descriptor {id} {
    set entry [entry $id]
    set fields {}
    foreach field [dict get $entry fields] {
        if {[dict get $field kind] eq "layout"} {
            lappend fields [list [dict get $field name] [dict get $field offset] layout \
                [descriptor [dict get $field layout]]]
        } elseif {[dict get $field kind] eq "pointer"} {
            lappend fields [list [dict get $field name] [dict get $field offset] ptr \
                [dict get $field width] [dict get $field endian]]
        } else {
            lappend fields [list [dict get $field name] [dict get $field offset] \
                [expr {[dict get $field signed] ? "i" : "u"}] [dict get $field width] [dict get $field endian]]
        }
    }
    return [list [structId $id] [dict get $entry size] [dict get $entry align] $fields]
}

# The layout identity a descriptor text DESCRIPTOR describes (the inner ID of
# its STRUCTID), or "" if it is not a descriptor.
proc hir::layouts::DescriptorLayout {descriptor} {
    if {[catch {lindex $descriptor 0} structId] || ![string match {LayoutStruct\[*\]} $structId]} {
        return ""
    }
    return [string range $structId 13 end-1]
}

# The descriptor entry of field NAME of layout ID (the FIELD of its
# descriptor), or "" when ID has no such field.
proc hir::layouts::FieldDescriptor {id name} {
    foreach field [lindex [descriptor $id] 3] {
        if {[lindex $field 0] eq $name} {
            return $field
        }
    }
    return ""
}

# 1 if layout ID holds a pointer field, directly or in a nested layout: it is
# native-only (the file header's "Pointer fields").
proc hir::layouts::NativeOnly {id} {
    return [expr {[PointerField $id] ne ""}]
}

# The path ("next", "inner.handle") of the first pointer field of layout ID in
# declared order, nested layouts included, or "".
proc hir::layouts::PointerField {id} {
    foreach field [dict get [entry $id] fields] {
        switch -- [dict get $field kind] {
            pointer {
                return [dict get $field name]
            }
            layout {
                set inner [PointerField [dict get $field layout]]
                if {$inner ne ""} {
                    return "[dict get $field name].$inner"
                }
            }
        }
    }
    return ""
}

# The native view type NativeView[ID].
proc hir::layouts::viewType {id} {
    return [list nview $id]
}

# The native edit type NativeEdit[ID] (NATIVE-LAYOUT-WRITES.md).
proc hir::layouts::editType {id} {
    return [list nedit $id]
}

# The layout of TYPE when TYPE is a NativeView type, else "".
proc hir::layouts::OfViewType {type} {
    if {![hir::types::IsNativeView $type]} {
        return ""
    }
    set id [lindex $type 1]
    return [expr {[declared $id] ? $id : ""}]
}

# The layout of TYPE when TYPE is a NativeEdit type, else ""
# (NATIVE-LAYOUT-WRITES.md): the only type a store writes through.
proc hir::layouts::OfEditType {type} {
    if {![hir::types::IsNativeEdit $type]} {
        return ""
    }
    set id [lindex $type 1]
    return [expr {[declared $id] ? $id : ""}]
}

# The layout of TYPE when TYPE reads native memory -- a NativeView[L] or a
# NativeEdit[L], whose reads are the same (NATIVE-LAYOUT-WRITES.md) -- else
# "".
proc hir::layouts::OfNativeType {type} {
    if {![hir::types::IsNativeMemory $type]} {
        return ""
    }
    set id [lindex $type 1]
    return [expr {[declared $id] ? $id : ""}]
}

# The static type of field NAME read through a NativeView[ID] (the file
# header's "Native views"), or "" when ID has no such field. Read through a
# NativeEdit[ID] (EDIT 1), a nested layout is a NativeEdit[INNER]: the
# subrecord of memory the edit may write (NATIVE-LAYOUT-WRITES.md); every
# other field reads exactly as through a view.
proc hir::layouts::ViewFieldType {id name {edit 0}} {
    foreach field [dict get [entry $id] fields] {
        if {[dict get $field name] ne $name} continue
        if {[dict get $field kind] eq "layout"} {
            if {$edit} {
                return [editType [dict get $field layout]]
            }
            return [viewType [dict get $field layout]]
        }
        return [dict get $field type]
    }
    return ""
}

# The static type of field NAME read through the native memory type TYPE
# (a NativeView or a NativeEdit), or "".
proc hir::layouts::NativeFieldType {type name} {
    set id [OfNativeType $type]
    if {$id eq ""} {
        return ""
    }
    return [ViewFieldType $id $name [hir::types::IsNativeEdit $type]]
}

# ---------------------------------------------------------------------------
# Field designators (NATIVE-LAYOUT-WRITES.md)
#
# A write names one field statically, as LAYOUT.FIELD or a path through
# nested layouts, LAYOUT.FIELD.FIELD...: the operand of binary::store,
# binary::write and binary::write_foreign (role `path K`). Resolution
# (hir/resolve.tcl's FieldPathOperand) turns it into the constant
#
#   {STRUCTID SIZE PATH FIELD}
#
# STRUCTID the root layout's struct identity (as a descriptor's), SIZE its
# size, PATH the dotted field path ("origin.x"), and FIELD the leaf's
# descriptor entry with its offset made absolute -- {NAME OFFSET u|i WIDTH
# ENDIAN} for a scalar, {NAME OFFSET ptr WIDTH ENDIAN} for a pointer. It is
# the whole of what a backend needs for the write (one store of WIDTH bytes
# at OFFSET from the record's start); the field's semantic type, which the
# value is held to, is the registry's (PathField). A designator names a
# leaf: a nested layout is written through its fields.

# {ok CONSTANT} for the path NAMES (field names, outermost first) of layout
# ID, or {problem KIND MESSAGE INDEX}, INDEX the position of the name the
# problem is located at.
proc hir::layouts::FieldPath {id names} {
    set layout $id
    set base 0
    set path {}
    set index 0
    set count [llength $names]
    foreach name $names {
        set field ""
        foreach f [dict get [entry $layout] fields] {
            if {[dict get $f name] eq $name} {
                set field $f
                break
            }
        }
        set written [join [concat [list $id] $path] .]
        if {$field eq ""} {
            return [list problem UNKNOWN-FIELD [format {%s has no field "%s" (layout %s has fields: %s)}                 $written $name $layout [join [StructNames $layout] {, }]] $index]
        }
        lappend path $name
        set offset [expr {$base + [dict get $field offset]}]
        set last [expr {$index == $count - 1}]
        if {[dict get $field kind] eq "layout"} {
            if {$last} {
                return [list problem LAYOUT-OPERAND [format {%s.%s is the nested layout %s, not a field a write can name: a write names one scalar or pointer field (%s.%s.%s)}                     $written $name [dict get $field layout] $written $name [lindex [StructNames [dict get $field layout]] 0]] $index]
            }
            set layout [dict get $field layout]
            set base $offset
            incr index
            continue
        }
        if {!$last} {
            set what [expr {[dict get $field kind] eq "pointer" ? "a C pointer" : "a scalar"}]
            return [list problem UNKNOWN-FIELD [format {%s.%s is %s, which has no field "%s"}                 $written $name $what [lindex $names [expr {$index + 1}]]] [expr {$index + 1}]]
        }
        set entry [FieldDescriptor $layout $name]
        lset entry 1 $offset
        return [list ok [list [structId $id] [size $id] [join $path .] $entry]]
    }
    error "internal compiler error: an empty field path of layout $id"
}

# The root layout of the field designator constant PATH, or "" if it is
# not one.
proc hir::layouts::PathLayout {path} {
    if {[catch {llength $path} n] || $n != 4} {
        return ""
    }
    return [DescriptorLayout $path]
}

# The registry entry (the file header's FIELD) of the leaf the field
# designator constant PATH names, or "".
proc hir::layouts::PathField {path} {
    set layout [PathLayout $path]
    if {$layout eq "" || ![declared $layout]} {
        return ""
    }
    set names [split [lindex $path 2] .]
    set field ""
    foreach name $names {
        set field ""
        foreach f [dict get [entry $layout] fields] {
            if {[dict get $f name] eq $name} {
                set field $f
                break
            }
        }
        if {$field eq ""} {
            return ""
        }
        if {[dict get $field kind] eq "layout"} {
            set layout [dict get $field layout]
        }
    }
    return $field
}

# "RECORD.origin.x": the designator constant PATH as written.
proc hir::layouts::PathText {path} {
    return "[PathLayout $path].[lindex $path 2]"
}

# The pointer width in bytes on the compilation's C target: the target the
# ffi::c scalars of this compilation were declared for (hir/cabi.tcl's
# NamespaceTypeDecls; a pointer type can only be written where ffi::c is
# imported), or "" when no file of the compilation imports ffi::c.
proc hir::layouts::PointerWidth {} {
    set target [hir::cabi::CompilationTarget]
    if {$target eq ""} {
        return ""
    }
    return [expr {[dict get [core::cabi::target $target] pointer] / 8}]
}

# 1 if the field type expression TYPEEXPR is written as a C pointer type
# (ffi::c::Ptr[...] or ffi::c::FnPtr[...]).
proc hir::layouts::PointerTypeExpr {typeExpr} {
    return [expr {[llength $typeExpr] == 2 && [lindex $typeExpr 0] in [list [hir::cabi::PtrName] [hir::cabi::FnPtrName]]}]
}

# ---------------------------------------------------------------------------
# Declaration

# 1 if N is a power of two (N >= 1).
proc hir::layouts::PowerOfTwo {n} {
    return [expr {$n >= 1 && ($n & ($n - 1)) == 0}]
}

# The {WIDTH SIGNED} encoding of the resolved field type TYPE, or "" if TYPE
# is not a scalar field type (the file header's "Scalar encodings").
proc hir::layouts::Encoding {type} {
    variable encodings
    if {[lindex $type 0] ne "refined" || [lindex $type 1] ne "int"} {
        return ""
    }
    foreach name [core::type::evidenceClosure $type] {
        if {[core::type::isRefinement $name]} {
            return ""
        }
    }
    set facts [core::type::integerFacts $type]
    if {$facts eq "" || [dict exists $facts exact]} {
        return ""
    }
    dict for {encoding range} $encodings {
        if {[dict get $facts min] == [lindex $range 0] && [dict get $facts max] == [lindex $range 1]} {
            return $encoding
        }
    }
    return ""
}

# Why the resolved type TYPE, written SPELLED, is not a scalar field type.
proc hir::layouts::NotScalarReason {type spelled} {
    if {$type eq "int"} {
        return "int has no fixed width: a scalar field is an integer domain whose values are exactly one fixed-width encoding's (e.g. binary::U32, Int in 0..4294967295)"
    }
    if {[lindex $type 0] eq "refined" && [lindex $type 1] eq "int"} {
        foreach name [core::type::evidenceClosure $type] {
            if {[core::type::isRefinement $name]} {
                return "$spelled is a refinement: its values carry a proof that imprinting bytes cannot make (use its carrier's integer domain and refine the value afterwards)"
            }
        }
        set facts [core::type::integerFacts $type]
        if {[dict exists $facts exact]} {
            return "$spelled is a set of exact values, not one fixed-width encoding's whole range (not every bit pattern would be a value of it)"
        }
        return "$spelled is Int in [dict get $facts min]..[dict get $facts max], which is not the range of a fixed-width encoding (8, 16, 32 or 64 bits, unsigned 0..2^n-1 or two's-complement -2^(n-1)..2^(n-1)-1), so its width is unknown or not every bit pattern would be a value of it"
    }
    if {[hir::types::IsNamedStruct $type]} {
        return "[hir::types::show $type] is a struct type, not an integer domain or a layout (a nested layout field names the layout itself)"
    }
    if {[hir::types::IsCAddress $type]} {
        # A pointer field is written ffi::c::Ptr[T] or ffi::c::FnPtr[F]
        # (NATIVE-LAYOUT-VIEWS.md): its pointee identity is part of its type.
        return "[hir::types::show $type] is a C pointer of no single pointee identity: a pointer field is written ffi::c::Ptr\[T\] or ffi::c::FnPtr\[F\]"
    }
    return "[hir::types::show $type] has no fixed binary width (a layout field is an integer domain of exact fixed width, or a nested layout)"
}

# The kind of declaration (for a message) the identity ID already is, or "".
proc hir::layouts::OtherDeclaration {id name} {
    if {$name in {Int any never Fn Coroutine enum unit} || [core::type::isBuiltinName $name]
            || [dict exists $::hir::types::constructors $name]} {
        return "a built-in type"
    }
    if {[core::type::valid $id]} {
        return "a type"
    }
    if {[hir::enums::declared $id]} {
        return "an enum"
    }
    if {[hir::traits::declared $id]} {
        return "a trait"
    }
    return ""
}

# Validates and registers DECLS (surface/lower.tcl's LayoutDeclOf dicts, or
# hir/read.tcl's resolved lines), resetting the previous compilation's
# registry, after the integer domains of the same compilation are registered.
# Returns HIR's own `sourceTypes` entries for them: {kind layout id ID name
# NAME namespace NS size N align A fields {{name F offset O type T} ...}}, in
# declaration order. Every malformed declaration is a located error:
#
#   LAYOUT-SIZE            size is 0 or beyond the limit
#   LAYOUT-ALIGNMENT       align is not a power of two (or beyond the limit)
#   DUPLICATE-FIELD        two fields of one name
#   LAYOUT-FIELD-TYPE      a field's type is unknown, or neither a scalar
#                          domain (the header) nor a layout
#   LAYOUT-FIELD-BOUNDS    a field does not lie inside 0..size
#   LAYOUT-FIELD-OVERLAP   two fields share a byte (an overlay is a future
#                          explicit union construct, never implied)
#   LAYOUT-CYCLE           a layout contains itself by value
#
# No alignment of a field's offset is required: the declared, resolved layout
# is authoritative (a packed or vendor-aligned C layout is legal as stated),
# and `align` is the layout's own requirement for placement and storage.
proc hir::layouts::apply {decls {structDecls {}}} {
    variable registry
    variable maxAlign
    variable maxSize
    variable batchStructs
    variable pendingPointers
    Reset
    set pendingPointers {}
    # The structs of the same batch, registered after the layouts: a field
    # type naming one is reported as a struct, not as an unknown type.
    set batchStructs [dict create]
    foreach struct $structDecls {
        dict set batchStructs [identity [dict get $struct name] [dict get $struct namespace]] 1
    }
    set byId [dict create]
    foreach decl $decls {
        set name [dict get $decl name]
        set ns [dict get $decl namespace]
        set id [identity $name $ns]
        if {[dict exists $decl resolved] && [dict get $decl resolved]} {
            set id $name
            set name [lindex [split [string map {:: \x01} $id] \x01] end]
            dict set decl name $name
        }
        set other [OtherDeclaration $id $name]
        if {$other ne ""} {
            Fail [dict get $decl nameSpan] "\"$name\" cannot be declared as a layout: the name is already $other (layouts share the type namespace)"
        }
        if {[dict exists $byId $id]} {
            Fail [dict get $decl nameSpan] "layout \"$name\" is already declared"
        }
        dict set decl id $id
        dict set byId $id $decl
        # The skeleton: a field may name any layout of the batch.
        dict set registry $id [dict create id $id name $name namespace $ns size "" align "" \
            span [dict get $decl nameSpan] fields {}]
    }
    set done [dict create]
    foreach id [dict keys $byId] {
        Resolve $id $byId done {}
    }
    set entries {}
    foreach id [dict keys $byId] {
        set entry [dict get $registry $id]
        lappend entries [dict create kind layout id $id name [dict get $entry name] \
            namespace [dict get $entry namespace] size [dict get $entry size] align [dict get $entry align] \
            fields [lmap f [dict get $entry fields] {
                dict create name [dict get $f name] offset [dict get $f offset] type [dict get $f type]
            }]]
    }
    return $entries
}

# Resolves and validates layout ID of BYID (DONE: the identities already
# resolved; STACK: the layouts whose resolution is under way, for LAYOUT-CYCLE),
# first resolving every layout of the batch a field of it names.
proc hir::layouts::Resolve {id byId doneVar stack} {
    upvar 1 $doneVar done
    variable registry
    variable maxAlign
    variable maxSize
    if {[dict exists $done $id]} {
        return
    }
    set decl [dict get $byId $id]
    set name [dict get $decl name]
    set ns [dict get $decl namespace]
    set size [dict get $decl size]
    set align [dict get $decl align]
    set sizeSpan [expr {[dict exists $decl sizeSpan] ? [dict get $decl sizeSpan] : [dict get $decl nameSpan]}]
    set alignSpan [expr {[dict exists $decl alignSpan] ? [dict get $decl alignSpan] : [dict get $decl nameSpan]}]
    if {![string is entier -strict $size] || $size < 1 || $size > $maxSize} {
        Fail $sizeSpan "layout \"$name\" has size $size: a layout's size is a byte count from 1 to $maxSize" LAYOUT-SIZE
    }
    if {![string is entier -strict $align] || ![PowerOfTwo $align] || $align > $maxAlign} {
        Fail $alignSpan "layout \"$name\" has alignment $align: an alignment is a power of two from 1 to $maxAlign" LAYOUT-ALIGNMENT
    }
    set fields {}
    set names [dict create]
    foreach field [dict get $decl fields] {
        set fieldName [dict get $field name]
        set nameSpan [expr {[dict exists $field nameSpan] ? [dict get $field nameSpan] : [dict get $decl nameSpan]}]
        set typeSpan [expr {[dict exists $field typeSpan] ? [dict get $field typeSpan] : $nameSpan}]
        set offsetSpan [expr {[dict exists $field offsetSpan] ? [dict get $field offsetSpan] : $nameSpan}]
        if {[dict exists $names $fieldName]} {
            Fail $nameSpan "duplicate field \"$fieldName\" in layout \"$name\" (first declared at [Where [dict get $names $fieldName]]): a layout's fields have distinct names" DUPLICATE-FIELD
        }
        dict set names $fieldName $nameSpan
        set offset [dict get $field offset]
        if {![string is entier -strict $offset] || $offset < 0} {
            Fail $offsetSpan "field \"$fieldName\" of layout \"$name\" has offset $offset: an offset is a byte count from 0" LAYOUT-FIELD-BOUNDS
        }
        set typeExpr [dict get $field type]
        set nested [NestedLayout $typeExpr $ns $byId]
        if {$nested ne ""} {
            if {$nested in [concat $stack [list $id]]} {
                set chain [concat [lrange $stack [lsearch -exact $stack $nested] end] [list $id $nested]]
                if {$nested eq $id} {
                    set chain [list $id $id]
                }
                Fail $typeSpan "layout \"$name\" contains itself by value through [join $chain { -> }]: a fixed layout has a finite size, so it can never contain itself (a reference to one is a pointer field, not a nested layout)" LAYOUT-CYCLE
            }
            if {[dict exists $byId $nested]} {
                Resolve $nested $byId done [concat $stack [list $id]]
            }
            set width [dict get $registry $nested size]
            lappend fields [dict create name $fieldName offset $offset kind layout layout $nested \
                width $width type [structType $nested] span $nameSpan typeSpan $typeSpan offsetSpan $offsetSpan]
        } elseif {[dict exists $field pointerText] || [PointerTypeExpr $typeExpr]} {
            # A C pointer (the file header's "Pointer fields"): the target's
            # width now, the type itself once the structs a pointee may name
            # are registered (ResolvePointers).
            set width [PointerWidth]
            if {$width eq ""} {
                Fail $typeSpan "field \"$fieldName\" of layout \"$name\" is a C pointer, whose width is the compilation's C target's: no file of this compilation imports ffi::c, so there is none" LAYOUT-FIELD-TYPE
            }
            variable pendingPointers
            lappend pendingPointers [dict create id $id field $fieldName name $name ns $ns typeExpr $typeExpr \
                typeSpan $typeSpan typeText [expr {[dict exists $field pointerText] ? $typeExpr : ""}]]
            # The bare pointer kind until then: affine, like every pointer.
            lappend fields [dict create name $fieldName offset $offset kind pointer width $width \
                endian little type cptr span $nameSpan typeSpan $typeSpan offsetSpan $offsetSpan]
        } else {
            set spelled [ShowTypeExpr $typeExpr]
            if {[catch {hir::resolve::ResolveTypeExpr $typeExpr $ns} resolved]} {
                Fail $typeSpan [UnresolvedFieldType $typeExpr $ns $spelled $fieldName $name $resolved] LAYOUT-FIELD-TYPE
            }
            set encoding [Encoding $resolved]
            if {$encoding eq ""} {
                Fail $typeSpan "field \"$fieldName\" of layout \"$name\" cannot have type $spelled: [NotScalarReason $resolved $spelled]" LAYOUT-FIELD-TYPE
            }
            lassign $encoding width signed
            lappend fields [dict create name $fieldName offset $offset kind scalar width $width \
                signed $signed endian little type $resolved span $nameSpan typeSpan $typeSpan offsetSpan $offsetSpan]
        }
    }
    foreach field $fields {
        set end [expr {[dict get $field offset] + [dict get $field width]}]
        if {$end > $size} {
            Fail [dict get $field offsetSpan] [format {field "%s" of layout "%s" occupies bytes %s..%s (offset %s, width %s), outside the layout's size %s} \
                [dict get $field name] $name [dict get $field offset] [expr {$end - 1}] [dict get $field offset] \
                [dict get $field width] $size] LAYOUT-FIELD-BOUNDS
        }
    }
    # Overlap: any two fields sharing a byte; the later-declared field of the
    # first such pair (in declared order) is the one located.
    set index 0
    foreach field $fields {
        set lo [dict get $field offset]
        set hi [expr {$lo + [dict get $field width]}]
        foreach earlier [lrange $fields 0 [expr {$index - 1}]] {
            set elo [dict get $earlier offset]
            set ehi [expr {$elo + [dict get $earlier width]}]
            if {$lo < $ehi && $elo < $hi} {
                Fail [dict get $field offsetSpan] [format {field "%s" of layout "%s" (bytes %s..%s) overlaps field "%s" (bytes %s..%s): the fields of a layout never share a byte (an overlay would be an explicit union construct, which layouts do not have)} \
                    [dict get $field name] $name $lo [expr {$hi - 1}] [dict get $earlier name] $elo [expr {$ehi - 1}]] LAYOUT-FIELD-OVERLAP
            }
        }
        incr index
    }
    dict set registry $id size $size
    dict set registry $id align $align
    dict set registry $id fields [lmap f $fields {
        dict remove $f span typeSpan offsetSpan
    }]
    dict set done $id 1
}

# Resolves the type of every pointer field apply registered (the file
# header's "Pointer fields"), once the structs a pointee may name are
# registered (hir::sourcetypes::apply, after hir::structs::apply), and
# writes it into the registry and into the layouts' `sourceTypes` entries
# of ORDERVAR. A pointee or signature the C ABI types reject is
# LAYOUT-FIELD-TYPE at the field's type.
proc hir::layouts::ResolvePointers {orderVar} {
    upvar 1 $orderVar order
    variable registry
    variable pendingPointers
    if {![info exists pendingPointers] || $pendingPointers eq {}} {
        return
    }
    set resolvedTypes [dict create]
    foreach pending $pendingPointers {
        dict with pending {}
        set spelled [ShowTypeExpr $typeExpr]
        if {$typeText ne ""} {
            # HIR text (hir/read.tcl): the canonical type text, read now that
            # the structs a pointee names are registered, and validated again.
            if {[catch {hir::read::ParseType $typeText 0} type]} {
                Fail $typeSpan "invalid type $typeText for field \"$field\" of layout \"$name\": $type" LAYOUT-FIELD-TYPE
            }
            set spelled $typeText
            if {[hir::types::IsCPtr $type]} {
                set problem [expr {[lindex $type 1] eq "void" ? "" : [hir::cabi::PointeeProblem [lindex $type 1]]}]
            } elseif {[hir::types::IsCFnPtr $type]} {
                set problem [hir::cabi::SignatureProblem [lindex $type 1]]
            } else {
                set problem "[hir::types::show $type] is not a C pointer type"
            }
            if {$problem ne ""} {
                Fail $typeSpan "field \"$field\" of layout \"$name\" cannot have type $spelled: $problem" LAYOUT-FIELD-TYPE
            }
        } elseif {[catch {hir::resolve::ResolveTypeExpr $typeExpr $ns} type]} {
            Fail $typeSpan "invalid type $spelled for field \"$field\" of layout \"$name\": $type" LAYOUT-FIELD-TYPE
        }
        dict set resolvedTypes [list $id $field] $type
        set fields [lmap f [dict get $registry $id fields] {
            if {[dict get $f name] eq $field} {
                dict set f type $type
            }
            set f
        }]
        dict set registry $id fields $fields
    }
    set pendingPointers {}
    set order [lmap entry $order {
        if {[dict exists $entry kind] && [dict get $entry kind] eq "layout"} {
            set id [dict get $entry id]
            dict set entry fields [lmap f [dict get $entry fields] {
                if {[dict exists $resolvedTypes [list $id [dict get $f name]]]} {
                    dict set f type [dict get $resolvedTypes [list $id [dict get $f name]]]
                }
                set f
            }]
        }
        set entry
    }]
}

# The message of a field type TYPEEXPR (written SPELLED in namespace NS)
# that does not resolve, DETAIL the resolver's reason: a struct of the same
# compilation (registered after the layouts) is named as one, a single
# unknown name as unknown.
proc hir::layouts::UnresolvedFieldType {typeExpr ns spelled fieldName layoutName detail} {
    variable batchStructs
    if {[llength $typeExpr] == 1} {
        if {$typeExpr eq [hir::cabi::VoidName]} {
            # C-ABI-TYPES.md: no field holds a value of C's void.
            return "field \"$fieldName\" of layout \"$layoutName\" cannot have type $spelled: [hir::cabi::VoidMessage]"
        }
        set id [expr {[string first :: $typeExpr] >= 0 ? $typeExpr : [identity $typeExpr $ns]}]
        if {[info exists batchStructs] && [dict exists $batchStructs $id]} {
            return "field \"$fieldName\" of layout \"$layoutName\" cannot have type $spelled: $spelled is a struct type, not an integer domain or a layout (a struct holds domain meaning, not bytes; a nested layout field names a layout)"
        }
        return "unknown type $spelled for field \"$fieldName\" of layout \"$layoutName\": no layout, integer domain or other type of that name is visible here (a field names a fixed-width integer domain or a nested layout)"
    }
    return "unknown or invalid type $spelled for field \"$fieldName\" of layout \"$layoutName\": $detail"
}

# "FILE:LINE:COLUMN" of SPAN.
proc hir::layouts::Where {span} {
    if {$span eq "" || ![dict exists $span file]} {
        return "?"
    }
    return "[dict get $span file]:[dict get $span line]:[dict get $span column]"
}

# The layout identity a field type expression TYPEEXPR (written in module NS)
# names, or "" if it does not name a layout: a bare or qualified name that is
# a layout of BYID (this batch) or of the registry.
proc hir::layouts::NestedLayout {typeExpr ns byId} {
    if {[llength $typeExpr] != 1} {
        return ""
    }
    if {[string first :: $typeExpr] >= 0} {
        set id $typeExpr
    } else {
        set id [identity $typeExpr $ns]
    }
    if {[dict exists $byId $id] || [declared $id]} {
        return $id
    }
    return ""
}

proc hir::layouts::ShowTypeExpr {typeExpr} {
    if {[catch {hir::resolve::ShowTypeExpr $typeExpr} text]} {
        return $typeExpr
    }
    return $text
}

# The canonical text of a layout field's consumer type T for HIR text
# (hir/format.tcl): its nested layout's identity, or its integer domain's.
proc hir::layouts::FieldTypeText {type} {
    set id [OfType $type]
    if {$id ne ""} {
        return $id
    }
    if {[hir::types::IsNamedStruct $type] && [string match {LayoutStruct\[*\]} [lindex $type 1]]} {
        return [string range [lindex $type 1] 13 end-1]
    }
    if {[lindex $type 0] eq "refined" && [llength [lindex $type 2]] == 1} {
        return [lindex $type 2 0]
    }
    return [hir::types::show $type]
}

# ---------------------------------------------------------------------------
# LayoutStruct[L] in a type annotation

# The type LayoutStruct[ARG] denotes in code of namespace NS, ARG the
# argument's surface type expression; raises a located-by-caller error
# ({BOTLISH UNKNOWN-LAYOUT} or {BOTLISH LAYOUT-STRUCT-PARAMETER}) when ARG does
# not designate a layout.
proc hir::layouts::ResolveLayoutStruct {arg ns} {
    if {[llength $arg] == 1} {
        set id [lookup $arg $ns]
        if {$id ne ""} {
            return [structType $id]
        }
    }
    set spelled [ShowTypeExpr $arg]
    set what [ArgumentKind $arg $ns]
    if {$what eq ""} {
        return -code error -errorcode {BOTLISH UNKNOWN-LAYOUT} \
            "unknown layout \"$spelled\" in LayoutStruct\[$spelled\]: no \"layout [lindex [split [string map {:: \x01} $spelled] \x01] end]:\" declaration is visible (the argument of LayoutStruct must name a layout)"
    }
    return -code error -errorcode {BOTLISH LAYOUT-STRUCT-PARAMETER} \
        "LayoutStruct\[$spelled\]: $spelled is $what, not a layout; the argument of LayoutStruct must name a layout declaration (`layout Name:`), whose fields LayoutStruct\[Name\] has"
}

# The type NativeView[ARG] denotes in code of namespace NS
# (NATIVE-LAYOUT-VIEWS.md): the same argument rules, and the same
# diagnostics, as LayoutStruct[ARG]'s.
proc hir::layouts::ResolveNativeView {arg ns} {
    if {[llength $arg] == 1} {
        set id [lookup $arg $ns]
        if {$id ne ""} {
            return [viewType $id]
        }
    }
    set spelled [ShowTypeExpr $arg]
    set what [ArgumentKind $arg $ns]
    if {$what eq ""} {
        return -code error -errorcode {BOTLISH UNKNOWN-LAYOUT} \
            "unknown layout \"$spelled\" in NativeView\[$spelled\]: no \"layout [lindex [split [string map {:: \x01} $spelled] \x01] end]:\" declaration is visible (the argument of NativeView must name a layout)"
    }
    return -code error -errorcode {BOTLISH LAYOUT-STRUCT-PARAMETER} \
        "NativeView\[$spelled\]: $spelled is $what, not a layout; the argument of NativeView must name a layout declaration (`layout Name:`), the layout through which the view reads native memory"
}

# The type NativeEdit[ARG] denotes in code of namespace NS
# (NATIVE-LAYOUT-WRITES.md): the same argument rules, and the same
# diagnostics, as NativeView[ARG]'s.
proc hir::layouts::ResolveNativeEdit {arg ns} {
    if {[llength $arg] == 1} {
        set id [lookup $arg $ns]
        if {$id ne ""} {
            return [editType $id]
        }
    }
    set spelled [ShowTypeExpr $arg]
    set what [ArgumentKind $arg $ns]
    if {$what eq ""} {
        return -code error -errorcode {BOTLISH UNKNOWN-LAYOUT} \
            "unknown layout \"$spelled\" in NativeEdit\[$spelled\]: no \"layout [lindex [split [string map {:: \x01} $spelled] \x01] end]:\" declaration is visible (the argument of NativeEdit must name a layout)"
    }
    return -code error -errorcode {BOTLISH LAYOUT-STRUCT-PARAMETER} \
        "NativeEdit\[$spelled\]: $spelled is $what, not a layout; the argument of NativeEdit must name a layout declaration (`layout Name:`), the layout through which the edit reads and writes native memory"
}

# What the type expression ARG (written in NS) is when it is not a layout:
# "a type", "a struct", "an enum", "a refinement", "a trait", "a built-in
# type", "an applied type", or "" when it names nothing.
proc hir::layouts::ArgumentKind {arg ns} {
    if {[llength $arg] != 1} {
        return "an applied or structural type"
    }
    if {$arg in {int str bool unit any never list block native result struct mutarray}
            || [core::type::isBuiltinName $arg] || [dict exists $::hir::types::constructors $arg]} {
        return "a built-in type"
    }
    if {[hir::structs::lookup $arg $ns] ne ""} {
        return "a struct"
    }
    if {[hir::enums::lookup $arg $ns] ne ""} {
        return "an enum"
    }
    if {[hir::traits::lookup $arg $ns] ne ""} {
        return "a trait"
    }
    set canonical [hir::types::CanonicalTypeName $arg $ns]
    if {[core::type::isSource $canonical] || [core::type::valid $canonical]} {
        if {[core::type::isRefinement $canonical]} {
            return "a refinement type"
        }
        return "a type"
    }
    return ""
}

# ---------------------------------------------------------------------------
# The binary operations (core/binary.tcl)
#
# Each is a root native whose registration carries its layout role
# (core/native.tcl's -layout), read here and by every backend, never a name:
#
#   operand K       argument K is the static layout operand: written as a
#                   layout name, resolved (hir/resolve.tcl's LayoutOperand)
#                   to the layout's descriptor constant
#   query WHAT      (with operand 0) the call is a compile-time fact of the
#                   layout, replaced by its constant at resolution: WHAT is
#                   length (the size) or alignment
#   typed AT FORM   argument AT's static type is LayoutStruct[L]; once types
#                   are known the call becomes a call of FORM with L's
#                   descriptor appended (Elaborate)
#   input K         argument K is the bytes being imprinted: statically an
#                   abi::bytes::Bytes (verify)
#   pointer K       argument K is the data pointer a native view reads
#                   through: statically an ffi::c::Ptr[T] (verify)
#   viewed AT FORM  argument AT's static type is NativeView[L]; once types
#                   are known the call becomes a call of FORM with L's
#                   descriptor appended (Elaborate)
#   field K         argument K is one field's descriptor entry (the
#                   internal read a native view's projection becomes)
#   edited K        argument K is the native edit a store writes through:
#                   statically a NativeEdit[L] -- never a NativeView[L],
#                   which is read-only (verify)
#   output K        argument K is the byte storage a layout write writes
#                   into: statically an abi::bytes::MutableBytes (verify)
#   path K          argument K is the static field designator, written
#                   LAYOUT.FIELD[.FIELD...] and resolved (hir/resolve.tcl's
#                   FieldPathOperand) to the field designator constant (the
#                   "Field designators" section above)
#   value K         argument K is the value written: proven admissible for
#                   the designated field's type (VerifyWriteValue)
#
# and `op` the operation a backend performs (parse, emit; view, load,
# field: NATIVE-LAYOUT-VIEWS.md; edit, store, write, write_foreign:
# NATIVE-LAYOUT-WRITES.md).

# The -layout role of native NAME, or "".
proc hir::layouts::Role {name} {
    if {![core::native::exists $name]} {
        return ""
    }
    set meta [core::native::metadata $name]
    return [expr {[dict exists $meta layout] ? [dict get $meta layout] : ""}]
}

# The value of role WORD ("operand", "typed", "input", "query") in ROLE, or
# "" when ROLE has none.
proc hir::layouts::RoleOf {role word} {
    foreach {key value} $role {
        if {$key eq $word} {
            return $value
        }
    }
    return ""
}

# The root native call E of HIR is a call of (or "" when it is not a call of
# a native).
proc hir::layouts::CalledNative {hir e} {
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] ne "call"} {
        return ""
    }
    lassign [dict get $node target] targetKind target
    if {$targetKind ne "native"} {
        return ""
    }
    return [dict get [hir::symbol $hir $target] name]
}

# Diagnostics of the binary operations' static operands (part of
# hir::CheckOnce):
#
#   BINARY-OPERAND      emit's value is not statically a LayoutStruct[L];
#                       the bytes given to parse are not statically an
#                       abi::bytes::Bytes; the pointer given to
#                       binary::native::view is not statically a data
#                       pointer ffi::c::Ptr[T]; load's value is not
#                       statically a NativeView[L]; an operation used as a
#                       value (it takes static operands, so it has no
#                       function value)
#   LAYOUT-NATIVE-ONLY  parse or emit of a layout with a pointer field (the
#                       file header's "Pointer fields"); an ordinary
#                       binary::write of a pointer field
#
# and for the writes (NATIVE-LAYOUT-WRITES.md):
#
#   BINARY-OPERAND      a store's edit is not statically a NativeEdit[L] (a
#                       NativeView[L] is read-only); a write's storage is
#                       not statically an abi::bytes::MutableBytes
#   LAYOUT-OPERAND      a store's field designator names a field of
#                       another layout than its edit's
#   LAYOUT-FOREIGN-WRITE  binary::write_foreign of a field that is not a C
#                       pointer (an ordinary scalar is written by
#                       binary::write)
#
# The written value is held to the field's type by hir/range.tcl
# (VerifyWriteValue).
proc hir::layouts::verify {hirVar} {
    upvar 1 $hirVar hir
    set callees [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call"} continue
        dict set callees [dict get $node callee] 1
        set name [CalledNative $hir $e]
        if {$name eq ""} continue
        set role [Role $name]
        if {$role eq "" || ![dict get $node reachable]} continue
        foreach problem [Problems $hir $e $name $role] {
            lassign $problem kind message expr
            hir::Diagnose hir $kind $message $expr
        }
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref" || [dict exists $callees $e]} continue
        set b [dict get $node binding]
        if {$b eq ""} continue
        set binding [hir::binding $hir $b]
        if {[dict get $binding kind] ne "root" || [Role [dict get $binding name]] eq ""} continue
        hir::Diagnose hir BINARY-OPERAND \
            "[dict get $binding name] can only be called directly: its layout is a static operand (named at the call, or the static type of the value it emits), so it has no function value" $e
    }
}

# The problems of call E of the binary operation NAME (ROLE its -layout
# role) in HIR: a list of {KIND MESSAGE EXPR}. Native lowering asks again of
# the HIR it lowers.
proc hir::layouts::Problems {hir e name role} {
    set args [dict get $hir exprs $e args]
    set problems {}
    set at [RoleOf $role typed]
    if {$at ne ""} {
        set at [lindex $at 0]
        set arg [lindex $args $at]
        set type [hir::typeOf $hir $arg]
        if {$type ne "never" && [OfType $type] eq ""} {
            lappend problems [list BINARY-OPERAND \
                "$name needs a value whose static type is LayoutStruct\[L\] for a layout L (the layout it emits with); this value's type here is [hir::types::show $type]" $arg]
        }
    }
    set at [RoleOf $role viewed]
    if {$at ne ""} {
        set arg [lindex $args [lindex $at 0]]
        set type [hir::typeOf $hir $arg]
        if {$type ne "never" && [OfNativeType $type] eq ""} {
            lappend problems [list BINARY-OPERAND \
                "$name needs a value whose static type is NativeView\[L\] or NativeEdit\[L\] for a layout L (a native view or edit, binary::native::view or binary::native::edit, whose layout it reads every field of); this value's type here is [hir::types::show $type]" $arg]
        }
    }
    set at [RoleOf $role edited]
    if {$at ne ""} {
        set arg [lindex $args $at]
        set type [hir::typeOf $hir $arg]
        if {$type ne "never" && [OfEditType $type] eq ""} {
            if {[hir::types::IsNativeView $type]} {
                set why "[hir::types::show $type], a native view, which is read-only: write authority over native memory is a NativeEdit\[L\], made from a pointer by binary::native::edit (a view never becomes one)"
            } else {
                set why [hir::types::show $type]
            }
            lappend problems [list BINARY-OPERAND \
                "$name writes live native memory through a native edit (a NativeEdit\[L\], binary::native::edit); this value's type here is $why" $arg]
        }
    }
    set at [RoleOf $role output]
    if {$at ne ""} {
        set arg [lindex $args $at]
        set type [hir::typeOf $hir $arg]
        set mutable [core::bytestore::mutableBytesType]
        if {$type ne "never" && $type ne [list nstruct $mutable]} {
            lappend problems [list BINARY-OPERAND \
                "$name writes a field into the bytes of an $mutable (a record built in byte storage the program owns: abi::bytes::zeroed); this argument's type here is [hir::types::show $type]" $arg]
        }
    }
    set at [RoleOf $role path]
    if {$at ne ""} {
        set where [lindex $args $at]
        set path [ConstText $hir $where]
        set field [PathField $path]
        if {$field ne ""} {
            set text [PathText $path]
            set root [PathLayout $path]
            set edited [RoleOf $role edited]
            if {$edited ne ""} {
                set id [OfEditType [hir::typeOf $hir [lindex $args $edited]]]
                if {$id ne "" && $id ne $root} {
                    lappend problems [list LAYOUT-OPERAND \
                        "the field $text belongs to layout $root, but this edit is NativeEdit\[$id\]: a store names a field of its edit's own layout ($id.[lindex [StructNames $id] 0])" $where]
                }
            }
            set pointer [expr {[dict get $field kind] eq "pointer"}]
            switch -- [RoleOf $role op] {
                write {
                    if {$pointer} {
                        lappend problems [list LAYOUT-NATIVE-ONLY \
                            "$name cannot write the field $text: it is a C pointer, and an ordinary byte write never encodes one; encoding a pointer the program already has into a pointer field is the explicit foreign write binary::write_foreign(data, $text, p)" $where]
                    }
                }
                write_foreign {
                    if {!$pointer} {
                        lappend problems [list LAYOUT-FOREIGN-WRITE \
                            "$name encodes an existing foreign value (an ffi::c::Ptr or ffi::c::FnPtr) into a C pointer field; $text is an ordinary field of type [hir::types::show [dict get $field type]], written by binary::write" $where]
                    }
                }
            }
        }
    }
    set pointer [RoleOf $role pointer]
    if {$pointer ne ""} {
        set arg [lindex $args $pointer]
        set type [hir::typeOf $hir $arg]
        if {$type ne "never" && ![hir::types::IsCPtr $type]} {
            if {[hir::types::IsCFnPtr $type]} {
                set why "a C function pointer, which addresses code, not data"
            } else {
                set why [hir::types::show $type]
            }
            set access [expr {[RoleOf $role op] eq "edit" ? "reads and writes" : "reads"}]
            lappend problems [list BINARY-OPERAND \
                "$name $access the live native memory a C data pointer addresses (an ffi::c::Ptr\[T\], which only foreign code hands out); this argument's type here is $why" $arg]
        }
    }
    # A native-only layout (a pointer field) imprinted from or emitted into
    # bytes: its pointer is authority, which arbitrary bytes are not.
    set op [RoleOf $role op]
    if {[RoleOf $role typed] ne ""} {
        # binary::emit before elaboration.
        set op emit
    }
    if {$op in {parse emit}} {
        set id ""
        set at [RoleOf $role typed]
        if {$at ne ""} {
            set id [OfType [hir::typeOf $hir [lindex $args [lindex $at 0]]]]
            set where [lindex $args [lindex $at 0]]
        }
        set operand [RoleOf $role operand]
        if {$id eq "" && $operand ne ""} {
            set where [lindex $args $operand]
            if {$where ne "" && [hir::kind $hir $where] eq "const"} {
                set id [DescriptorLayout [lindex [hir::get $hir $where literal] end]]
            }
        }
        if {$id ne "" && [declared $id] && [NativeOnly $id]} {
            set path [PointerField $id]
            if {$op eq "parse"} {
                set message "$name cannot imprint layout \"$id\" from bytes: its field \"$path\" is a C pointer, and imprinting arbitrary bytes into it would make a pointer no foreign code handed out; a layout with a pointer field is read through a native view of live native memory (binary::native::view, binary::load)"
            } else {
                set message "$name cannot emit layout \"$id\" into bytes: its field \"$path\" is a C pointer, and writing a pointer into bytes is not supported (a layout with a pointer field is read through a native view only)"
            }
            lappend problems [list LAYOUT-NATIVE-ONLY $message $where]
        }
    }
    set input [RoleOf $role input]
    if {$input ne ""} {
        set arg [lindex $args $input]
        set type [hir::typeOf $hir $arg]
        set bytes [core::bytestore::bytesType]
        if {$type ne "never" && $type ne [list nstruct $bytes]} {
            lappend problems [list BINARY-OPERAND \
                "$name imprints the bytes of an $bytes (an owned, immutable byte value: abi::bytes::from_list, binary::emit); this argument's type here is [hir::types::show $type]" $arg]
        }
    }
    return $problems
}

# The constant text expression E of HIR holds (a resolved operand's
# descriptor or field designator), or "" when E is no constant.
proc hir::layouts::ConstText {hir e} {
    if {$e eq "" || [hir::kind $hir $e] ne "const"} {
        return ""
    }
    return [lindex [hir::get $hir $e literal] end]
}

# Holds the value a write (binary::store, binary::write,
# binary::write_foreign: role `value K`) puts into its designated field to
# the field's type, in call E (NODE) of native NAME (NATIVE-LAYOUT-WRITES.md):
# the one admissibility proof a construction's field values are held to
# (hir::range::ProvesValueAcceptedBy) -- a scalar's integer domain, proven
# by the value's type or its Range (no conversion, truncation or run-time
# guard); a pointer field's exact pointer type (no implicit erasure or
# retyping, no Int). Called by hir/range.tcl's VerifyCall with the call's
# RANGES.
proc hir::layouts::VerifyWriteValue {hirVar ranges e node name} {
    upvar 1 $hirVar hir
    set role [Role $name]
    set at [RoleOf $role value]
    if {$at eq "" || ![dict get $node reachable]} {
        return
    }
    set args [dict get $node args]
    set path [ConstText $hir [lindex $args [RoleOf $role path]]]
    set field [PathField $path]
    if {$field eq ""} {
        return
    }
    set pointer [expr {[dict get $field kind] eq "pointer"}]
    set op [RoleOf $role op]
    if {($op eq "write" && $pointer) || ($op eq "write_foreign" && !$pointer)} {
        # The operation does not write this kind of field (verify).
        return
    }
    set declared [dict get $field type]
    set arg [lindex $args $at]
    set valueType [hir::typeOf $hir $arg]
    if {$valueType eq "never" || ![hir::get $hir $arg reachable]} {
        return
    }
    set range [expr {[dict exists $ranges $arg] ? [dict get $ranges $arg] : [hir::range::unknown]}]
    if {[hir::range::ProvesValueAcceptedBy $valueType $range $declared]} {
        return
    }
    set hint ""
    if {[hir::types::IsCPtr $declared] && [hir::types::IsCPtr $valueType]} {
        set hint ": a pointer's pointee identity is never converted implicitly (ffi::c::erase makes a Ptr\[ffi::c::Void\], ffi::c::retype\[T\] one back)"
    } elseif {[hir::types::IsCAddress $declared] && ![hir::types::IsCAddress $valueType]} {
        set hint ": a pointer field holds only a pointer the program already has, never an Int or any other value"
    } elseif {[hir::types::IsCPtr $declared] != [hir::types::IsCPtr $valueType]} {
        set hint ": data and function pointers are distinct, and nothing converts one into the other"
    }
    hir::Diagnose hir TYPE [format {the value written to field %s by %s cannot be proven to satisfy the field's type %s (value type: %s%s)%s} \
        [PathText $path] $name [hir::types::show $declared] [hir::semantic::ShowType $hir $valueType] \
        [hir::range::FactsClause $valueType $declared $range] $hint] $arg
}

# Writes out the layout every `typed` binary operation reads from its value's
# static type (BINARY-LAYOUT.md, "Emission"): the call becomes a call of its
# role's FORM with the layout's descriptor appended, so every backend reads
# the layout from the call alone. Part of hir::BuildFull, after the checks;
# a call whose value is not a LayoutStruct (a BINARY-OPERAND diagnostic) is
# left alone.
#
# Native views (NATIVE-LAYOUT-VIEWS.md) likewise: binary::load(v) becomes
# binary#load(v, DESCRIPTOR) from v's static NativeView[L], and every
# projection `v.f` of a receiver statically a NativeView[L] becomes the
# internal read binary#view_field(v, FIELD), FIELD f's descriptor entry --
# its static type the projection's -- so no backend reads a layout or
# knows the view type: a field read is an explicit operation with constant
# operands.
proc hir::layouts::Elaborate {hirVar} {
    upvar 1 $hirVar hir
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "project"} {
            # (A NativeEdit[L]'s reads are a view's: NATIVE-LAYOUT-WRITES.md.)
            set id [OfNativeType [hir::typeOf $hir [dict get $node receiver]]]
            if {$id eq ""} continue
            set field [FieldDescriptor $id [dict get $node name]]
            if {$field eq ""} continue
            ViewRead hir $e $field
            continue
        }
        if {[dict get $node kind] ne "call"} continue
        set name [CalledNative $hir $e]
        if {$name eq ""} continue
        set role [Role $name]
        set typed [RoleOf $role typed]
        if {$typed ne ""} {
            lassign $typed at form
            set id [OfType [hir::typeOf $hir [lindex [dict get $node args] $at]]]
        } else {
            set typed [RoleOf $role viewed]
            if {$typed eq ""} continue
            lassign $typed at form
            set id [OfNativeType [hir::typeOf $hir [lindex [dict get $node args] $at]]]
        }
        if {$id eq ""} continue
        hir::mutvec::Retarget hir $e $form
        dict set hir exprs $e args [concat [dict get $hir exprs $e args] \
            [list [hir::mutvec::NewConst hir [descriptor $id] $e]]]
    }
}

# The native that reads one field through a native view (core/binary.tcl).
proc hir::layouts::ViewReadNative {} {
    return binary#view_field
}

# Rewrites projection E of a native view, in place, into the call
# binary#view_field(RECEIVER, FIELD) of the same static type: E keeps its
# identity, so its parent, its type and every side table naming it are
# unchanged.
proc hir::layouts::ViewRead {hirVar e field} {
    upvar 1 $hirVar hir
    set node [dict get $hir exprs $e]
    set native [ViewReadNative]
    set b [hir::mutvec::NativeBinding $hir $native]
    set y [dict get $hir bindings $b symbol]
    set r [hir::NewId hir expr]
    dict set hir exprs $r [dict create id $r kind ref origin [dict get $node origin] \
        scope [dict get $node scope] type [hir::types::intern hir [list native $native]] \
        reachable [dict get $node reachable] name $native binding $b init yes]
    set c [hir::mutvec::NewConst hir $field $e]
    dict set hir exprs $e [dict create id $e kind call origin [dict get $node origin] \
        scope [dict get $node scope] type [dict get $node type] reachable [dict get $node reachable] \
        callee $r args [list [dict get $node receiver] $c] target [list native $y] known ""]
}

# Diagnoses, in the view of semantic instance HIR (hir/semantic.tcl's View)
# whose generic program is GENERIC, every projection in EXPRS whose receiver
# is a native view in the instance but not statically one in the generic
# program: a field read through a view lowers to the field's constant offset
# and encoding (Elaborate), which an untyped receiver does not have -- so the
# receiver must be statically NativeView[L] (BINARY-OPERAND), as emit's value
# must be statically a LayoutStruct.
proc hir::layouts::verifyInstance {hirVar generic exprs} {
    upvar 1 $hirVar hir
    foreach e $exprs {
        set node [dict get $hir exprs $e]
        if {[dict get $node kind] ne "project" || ![dict get $node reachable]} continue
        set receiver [dict get $node receiver]
        set type [hir::typeOf $hir $receiver]
        set id [OfNativeType $type]
        if {$id eq "" || [OfNativeType [hir::typeOf $generic $receiver]] ne ""} continue
        set shown [hir::types::show $type]
        hir::Diagnose hir BINARY-OPERAND \
            "the field \"[dict get $node name]\" is read through a native view ($shown) whose type is not static here: a native view's field is read at its layout's constant offset, so the receiver must be statically a NativeView\[L\] or NativeEdit\[L\] (declare the parameter or result that carries it $shown)" $e
    }
}
