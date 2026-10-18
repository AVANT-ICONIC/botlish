# NATIVE-LAYOUT-WRITES.md

Native layout writes: the write half of the native-layout model. Live native
memory is written through a writable native capability, `NativeEdit[L]`
(`binary::native::edit`, `binary::store`); byte storage the program owns is
written a field at a time through the same layouts (`binary::write`), and an
existing C pointer is encoded into a pointer field of it only by an explicit
foreign write (`binary::write_foreign`).

> The layout determines where the bits are. The backing decides what those
> bits are allowed to mean. A `NativeEdit` grants live write authority; it
> does not grant ownership. `MutableBytes` is storage, not a native Botlish
> object. Foreign authority may be encoded from an authority the program
> already has; arbitrary bytes may not conjure authority by decoding.

```botlish
direct module                                  # making an edit is raw authority

import abi
import abi::bytes
import binary
import binary::native
import ffi::c

opaque struct Node:
    tag: unit

layout POINT:
    size 4
    align 2
    field x: binary::I16 at 0
    field y: binary::U16 at 2

layout RECORD:
    size 24
    align 8
    field count: ffi::c::UInt at 0
    field origin: POINT at 4
    field next: ffi::c::Ptr[Node] at 8
    field callback: ffi::c::FnPtr[Fn{args: [ffi::c::Int], return: ffi::c::Int}] at 16

# Live memory foreign code handed out: read and written in place.
fn reset(p: ffi::c::Ptr[Node], q: ffi::c::Ptr[Node]) -> int errors NativeEditNull:
    e = binary::native::edit(RECORD, p)        # NativeEdit[RECORD]: p observed, nothing touched
    binary::store(e, RECORD.count, 0)          # one 4-byte store at offset 0
    binary::store(e, RECORD.origin.x, -1)      # a path: one store at offset 4
    o = e.origin                               # NativeEdit[POINT]: the subrecord, no read
    binary::store(o, POINT.y, 7)               # one store at offset 6
    binary::store(e, RECORD.next, q)           # q's address bits; q observed, still q's
    e.count + o.y                              # reads, exactly a view's

# A record built in byte storage the program owns, for a C call.
fn build(q: ffi::c::Ptr[Node]) -> abi::bytes::MutableBytes errors LayoutLengthMismatch:
    d0 = abi::bytes::zeroed(abi::usize(binary::layout_length(RECORD)))
    d1 = binary::write(d0, RECORD.count, 3)    # a new MutableBytes: d0 unchanged
    d2 = binary::write(d1, RECORD.origin.y, 9)
    binary::write_foreign(d2, RECORD.next, q)  # the explicit foreign encoding
```

The record `build` returns is handed to C by the existing borrowing contract
(C-POINTER-BORROWING.md): `extern c fn use_record(r: ffi::c::Ptr[ffi::c::UChar]
read noescape) -> ...` exposes its storage for the one call.

## Contents

1. [The model](#1-the-model)
2. [Source surface](#2-source-surface)
3. [Field designators](#3-field-designators)
4. [NativeEdit: the type, its reads, its subrecords](#4-nativeedit-the-type-its-reads-its-subrecords)
5. [Authority: direct modules](#5-authority-direct-modules)
6. [Unrestricted, and what that does and does not prove](#6-unrestricted-and-what-that-does-and-does-not-prove)
7. [Scalar stores](#7-scalar-stores)
8. [Pointer and FnPtr stores; source-pointer ownership](#8-pointer-and-fnptr-stores-source-pointer-ownership)
9. [MutableBytes: ordinary layout writes](#9-mutablebytes-ordinary-layout-writes)
10. [The explicit foreign write](#10-the-explicit-foreign-write)
11. [Padding and adjacent bytes](#11-padding-and-adjacent-bytes)
12. [Diagnostics and failures](#12-diagnostics-and-failures)
13. [Bounds and validity](#13-bounds-and-validity)
14. [Representation and lowering](#14-representation-and-lowering)
15. [The Tcl backends](#15-the-tcl-backends)
16. [HIR, interchange, cache, isolation](#16-hir-interchange-cache-isolation)
17. [Targets](#17-targets)
18. [Performance](#18-performance)
19. [Tests, the oracles, fuzzing, mutants](#19-tests-the-oracles-fuzzing-mutants)
20. [Regression and CI](#20-regression-and-ci)
21. [The read milestone's questions, answered](#21-the-read-milestones-questions-answered)
22. [Pressure on generated native layouts](#22-pressure-on-generated-native-layouts)
23. [Not here](#23-not-here)
24. [What to run when changing this](#24-what-to-run-when-changing-this)
25. [Files](#25-files)

## 1. The model

```
                             layout                 one description: size,
                               |                    alignment, offsets,
                               |                    encodings, pointer fields
        +---------------+------+-------+------------------+
        |               |              |                  |
   byte storage     byte storage   native memory     native memory
     (read)          (write)          (read)            (write)
 binary::parse    binary::write   binary::native::  binary::native::edit
 LayoutStruct[L]  write_foreign      view(L, p)      (L, p): NativeEdit[L]
  (a copy)        (a new value)   NativeView[L]      binary::store
```

The two write mechanisms are deliberately asymmetric, because their backings
are:

| | `LayoutStruct[L]` | `abi::bytes::MutableBytes` | `NativeView[L]` | `NativeEdit[L]` |
|---|---|---|---|---|
| what it is | an immutable value: a copy of the fields | byte storage the program owns: a value | a window onto live native memory | write authority over live native memory |
| made by | `binary::parse`, construction | `abi::bytes::zeroed`, `from_bytes`, a write | `binary::native::view(L, p)` | `binary::native::edit(L, p)` |
| holds | the field values | the bytes | the address | the address |
| read | a field | `binary::parse` of a frozen copy | `v.f`, `binary::load` | `e.f`, `binary::load` (a view's reads) |
| written | never (build a new one) | `binary::write`, `binary::write_foreign`: a **new** value | never | `binary::store`: **in place** |
| a pointer field | read from native memory only | written only by `write_foreign`, never parsed | read | read and stored |
| authority | none | none | direct to make, ordinary to read | direct to make, ordinary to use |
| ownership | its own | its own | none | none |
| affinity | its fields' | unrestricted | unrestricted | unrestricted |
| backends | all four | all four | native | native |

A `NativeEdit[L]` is not a `NativeView[L]` with a flag, not a `MutableBytes`,
not a pointer, not a Botlish struct, not an owner of the memory and not proof
of exclusive access to it. `MutableBytes` gains no reference semantics and no
persistent editor wrapper: a layout write is an operation on a value. No
ordinary Botlish value gains a representation: a `struct` still has no
address, no stable offset and no pinning; a caller-constructed native record
is bytes the program owns, filled through a layout and exposed for a call.

## 2. Source surface

| form | what |
|---|---|
| `NativeEdit[L]` | the type of a native edit of layout L: a built-in applied type like `NativeView[L]`; its argument names a layout |
| `binary::native::edit(L, p)` | `NativeEdit[L]` of the memory the data pointer `p` addresses: L a layout name (static), `p` statically an `ffi::c::Ptr[T]`, observed; `errors NativeEditNull` |
| `e.f`, `{a: x} = e`, `binary::load(e)` | reads, exactly a view's; a nested layout's field is a `NativeEdit[Inner]` |
| `binary::store(e, L.f, v)` | `v` written into field f of the memory `e` addresses; `e` statically `NativeEdit[L]`; returns unit; declares nothing |
| `binary::write(d, L.f, v)` | the `abi::bytes::MutableBytes` d with ordinary field f written: a new value; `errors LayoutLengthMismatch` unless `d` has exactly L's size |
| `binary::write_foreign(d, L.p, q)` | the same for a C pointer field p and an existing pointer `q` of exactly its type, observed |
| `NativeEditNull` | the builtin declared error of an edit of the null pointer (beside `NativeViewNull`, `LayoutLengthMismatch`) |
| `LAYOUT-FOREIGN-WRITE` | the diagnostic of a foreign write of a field that is no pointer field (`compiler::DiagnosticCode::LayoutForeignWrite`) |

`binary::native` keeps being the one namespace of native-memory authority and
now has two members, `view` and `edit`; `binary::store`, `binary::write` and
`binary::write_foreign` are `binary`'s. All five new natives are `nomethod`
(their second argument is a static operand, never a value); none is
context-free (a write is an effect: never folded, merged or dropped). No
statement, keyword, operator or assignment form was added: Botlish has no
general assignment, and a write is an operation with operands, as everything
else in `binary` is.

Naming. `store` beside `load` (native memory), `write` beside `parse`/`emit`
(bytes): the pairs say which backing a name touches. `write` returns a new
value -- MutableBytes' `replace` convention in effect -- and `store` returns
unit, mutating memory in place: the two directions differ exactly where their
backings do. `write_foreign` says in the source that a pointer is being
encoded; it is never what ordinary serialization does.

## 3. Field designators

A write names its field statically: `LAYOUT.FIELD`, or a path through nested
layouts, `LAYOUT.FIELD.FIELD...` (`RECORD.origin.x`), qualified for another
module's layout (`geo::Box.width`). The designator is a static operand, like
a layout operand: the root is a layout name, never a value, and the
projections never run. Resolution (`hir/resolve.tcl`'s `FieldPathOperand`)
turns it into one constant,

```
{STRUCTID SIZE PATH FIELD}       e.g. {{LayoutStruct[RECORD]} 24 origin.x {x 4 i 2 little}}
```

the root layout's struct identity and size, the path as written and the
leaf's descriptor entry with its offset made **absolute** (`{NAME OFFSET u|i
WIDTH ENDIAN}`, or `{NAME OFFSET ptr WIDTH ENDIAN}` for a pointer). That is
everything a backend needs: one store of WIDTH bytes at OFFSET from the
record's start. The field's semantic type, which the value is held to, is
read from the registry along the path (`hir::layouts::PathField`).

A designator names a leaf: a scalar or a pointer field. A nested layout is
written through its fields (`RECORD.origin` alone is `LAYOUT-OPERAND`), and a
whole-record write is `binary::emit` (pointer-free layouts). No runtime string
names a field; a String-literal spelling was rejected because it would look
like one (and one-letter field names would warn, ONE-CHAR-STRING-LITERAL).

A store's designator must be rooted at its edit's own layout
(`LAYOUT-OPERAND` otherwise): `binary::store(e, RECORD.origin.x, v)` and
`binary::store(e.origin, POINT.x, v)` write the same bytes.

## 4. NativeEdit: the type, its reads, its subrecords

**The type** is `{nedit L}` (hir/types.tcl): nominal, unrestricted, runtime
kind `cptr` (the word is its pointer's address word), printed
`NativeEdit[L]` and read back by `hir::read::ParseType`. `NativeEdit[int]`,
`[S]`, `[List[int]]` are `LAYOUT-STRUCT-PARAMETER`, `NativeEdit[Nope]`
`UNKNOWN-LAYOUT`, a bare `NativeEdit` the arity error -- `NativeView`'s
diagnostics.

**Distinctness.** `NativeEdit[L]` and `NativeView[L]` are not subtypes of each
other in either direction (`ne-type-distinct`): read authority never becomes
write authority implicitly, and an edit is not silently narrowed into a view
either. Their join is `any`, which can do neither (a store needs a static
`NativeEdit`). No explicit reduction from edit to view was added: nothing
needed one, and the architecture offers no trivial one that is not a
subtyping rule. An edit is never a pointer: `null?`, `clone`, `erase`, a C
pointer parameter, a view's or an edit's construction refuse it (`TYPE`,
`IMPRINT`, `BINARY-OPERAND`), so no route leads from an edit back to a pointer
or from a view to an edit.

**Reads.** Every read a view supports reads the same through an edit of the
same memory (`ne-read-parity`): scalar fields, a u64 BigInt, nested fields at
any depth, destructuring, `binary::load` of the record and of a subrecord,
pointer fields (a fresh affine pointer, exactly as through a view). A read
never returns a writable reference to a field: field values are ordinary
values.

**Subrecords.** A nested layout read through `NativeEdit[Outer]` is
`NativeEdit[Inner]` (through `NativeView[Outer]` it stays `NativeView[Inner]`):
the outer address plus the field's offset, nothing read or copied. Chains
fold: `binary::store(e.outer.inner, Inner.y, v)` is one store at the absolute
offset (no intermediate address computation, native lowering's `ViewBase`),
exactly as a chained read is one load. There is no parent/subview borrow
rule: both are raw windows onto one piece of foreign memory.

## 5. Authority: direct modules

Writing live process memory is raw authority, at least as much as reading it.
`binary::native::edit` is a member of `binary::native`, which is designated
direct (`core::native::declareDirectNamespace binary::native`), so making an
edit is a direct edge of the calling module: `DIRECT` unless the module is
`direct module` or mediates the call through a context it declares itself
(`ne-direct`). Using an edit someone else made -- storing through it,
reading it -- is ordinary: the edit is the authority, already granted, like
a view handed out (`ne-direct-modules`: a direct module makes edits and hands
them out, an ordinary module writes through them and stays ordinary, the
program calling the direct module mediates that call). A module that only
stores through received edits and is marked `direct module` is
`STALE-DIRECT-MODULE`. Byte writes, foreign ones included, are ordinary:
encoding a pointer the program has into bytes reads and writes no foreign
memory; exposing the bytes to C is governed by the call's contract. A layout
declaration stays ordinary. No `unsafe`, no per-store marker, no new
designation mechanism.

## 6. Unrestricted, and what that does and does not prove

`NativeEdit[L]`, like `NativeView[L]`, is **unrestricted**: it can be copied,
passed, stored in a List or a struct, captured. That is the honest stance for
non-owning authority over an address: foreign code may hold aliases to the
same memory, another thread may know the address, another API may write it.
An affine edit would prove only that the program holds one *Botlish* handle,
not that the memory has no other writer, and it would have been presented as
more. So nothing about an edit claims exclusive access, and two edits of one
pointer, a copy of an edit and a view of the same address all alias it: a
store through one is what the others read next (`ne-edits-alias`). There is
no borrow checker, pinning, lifetime region, uniqueness proof or ownership
graph. The pointer an edit is made from is only observed and stays its
owner's; an edit keeps nothing alive.

## 7. Scalar stores

`binary::store(e, L.f, v)` for every scalar encoding a view reads (the eight
fixed-width encodings, the target's C scalars `ffi::c::UInt`, `Long`, `ULong`,
...): the value is written at the base address plus the constant absolute
offset, in exactly the field's width and encoding, little-endian, aligned or
not (packed layouts: `ne-packed-stores`), as one unaligned store. Never a
truncation, a wrap, a widened store, a write of the enclosing record, its
padding or a neighbouring field (`ne-scalar-stores`, `ne-store-touches-only-
its-bytes`).

The value is held to the field's type by the proof a construction's field
values are held to (`hir::range::ProvesValueAcceptedBy`, from
`hir::layouts::VerifyWriteValue`): a literal or a value of the domain, or an
Int a comparison bounded; -1 and 65536 for a U16 field are `TYPE`, and so is
an unbounded Int (`ne-store-value-types`). C scalar fields keep Botlish's
exact-domain semantics for the compilation's target: `4294967296` is no
`ffi::c::UInt`, `18446744073709551615` is an `ffi::c::ULong` on LP64. No C
conversion rule exists. The runtime encoder still range-checks (a value no
checked program can produce: a `-strict 0` program's), and fails *before
anything is written* (`nedit_store_refuses_out_of_range_values_before_writing`,
`ne-unchecked-replay`'s RANGE).

## 8. Pointer and FnPtr stores; source-pointer ownership

A pointer field (`ffi::c::Ptr[T]`, `ffi::c::FnPtr[F]`) is stored from an
existing pointer of exactly its declared type: the same pointee identity or
signature (no `Ptr[Other]`, no implicit erasure to `Ptr[Void]`, no function
pointer for a data pointer, no Int: `TYPE`, with the reason). The store writes
the pointer's address bits in the target's pointer width; null writes the
target's null representation, all zero bytes (`ne-pointer-stores`). Read back
through the edit, or a view, it is the same pointer.

The stored pointer is **observed** (`-ownership {observe observe observe}`),
as a C call's pointer argument is: the store copies its address
representation, like C pointer assignment, and moves nothing. The binding
stays usable -- tested, compared, stored again, moved on to a function that
owns it -- and is never implicitly cloned; a pointer read back is a fresh
affine value of its own (two reads, two owners); an observed temporary needs
an owner first (`AFFINE-TEMPORARY-UNSUPPORTED`, the ordinary rule), and a
moved pointer cannot be stored (`USE-AFTER-MOVE`; `ne-pointer-store-observes`).

What a store does **not** mean: that the memory owns the pointee, keeps it
alive, knows when foreign code stops using it, or makes the pointer
"retained" in the C-FFI sense. Botlish cannot infer any of that from a
representation, so the store records none of it -- no hidden dependency, no
lifetime edge. If a foreign API keeps a pointer it found in a record, a
wrapper that knows that protocol owns the pointee (and, for a callback, its
userdata and registration) together. The low-level facility preserves the
facts Botlish knows; protocol facts are the wrapper's.

## 9. MutableBytes: ordinary layout writes

`binary::write(d, L.f, v)` encodes `v` into field f's bytes of the
`abi::bytes::MutableBytes` d according to L and returns the result as a new
value; every byte the field does not own is d's (`ne-write-value-semantics`:
d, a copy held in a List and a struct field, and a second write from d all
keep their own bytes). This is MUTABLE-BYTES.md's rule unchanged -- published
storage is never written -- so each write allocates one fresh storage and
copies the record into it (32 bytes: about 190 ns; section 18). Incremental
building is a chain of writes, each binding a new value
(`ne-write-builds-a-record`); inside a function the `MutableBytes` wrapper of
an intermediate value is never built (hir/escape.tcl recognizes a write's
result as a construction of the one-field struct; the storage register is
the value). Copy-on-write or a deadness analysis could make a dead operand's
storage the result; neither exists, and the semantics do not need one.

The storage must be exactly L's size: fewer or more bytes is the declared
`LayoutLengthMismatch`, before anything is written (`ne-write-length`) -- the
exact-length rule of `binary::parse`, no prefix write, no cursor. Botlish
knows a `MutableBytes`' length, so this is checked at run time; the front end
does not track the length statically, so every call handles or admits the
error (a builder function with one `errors LayoutLengthMismatch` clause covers
all its writes). The value is held to its field's type exactly as a store's.
Byte writes run on every backend.

## 10. The explicit foreign write

`binary::write_foreign(d, L.p, q)` is the one operation that puts a pointer's
representation into bytes, and it is legal only when

1. L statically has the field the designator names;
2. that field is a C pointer field (`LAYOUT-FOREIGN-WRITE` otherwise: an
   ordinary field is written by `binary::write`);
3. `q` is statically a pointer of exactly the field's type (`TYPE`: an Int
   is never encoded into a pointer field);
4. the field lies inside the layout and `d` has exactly the layout's size
   (`LayoutLengthMismatch`);
5. `d` is an `abi::bytes::MutableBytes` (`BINARY-OPERAND` otherwise).

It encodes `q`'s address bits, little-endian, in the target's pointer width;
null as zero bytes (`ne-write-foreign`). `q` is observed: the bytes do not own
it, keep it alive or carry any dependency on it (`ne-write-foreign-observes`).
An ordinary `binary::write` of a pointer field stays `LAYOUT-NATIVE-ONLY`
(ordinary byte serialization never encodes a pointer), and so does
`binary::emit` of a pointer-bearing `LayoutStruct` (`ne-ordinary-serialization-
unchanged`). No whole-record foreign emission was added: the field write is
the smaller surface.

**Why it permits no forging.** The law is one-way: foreign authority may be
encoded from an authority the program already has; arbitrary bytes may not
conjure authority by decoding. After a foreign write the bytes hold a
pointer's bits, and

```
existing Ptr[T]  -> binary::write_foreign into MutableBytes      YES
those bytes      -> C observes the pointer (noescape exposure)    YES   ne-c-oracle-built
those bytes      -> binary::parse as Ptr[T]                       NO    LAYOUT-NATIVE-ONLY
native memory holding those bits -> NativeView / NativeEdit read  YES   ne-foreign-encoding-asymmetry
```

`binary::parse` of a pointer layout is rejected whatever the bytes came from;
a layout declaring the word as an integer (a bits twin) reads it as an inert
Int, as it always could read native memory's bits, with no pointer operation;
and the only way back to a pointer is native memory, through a view or an
edit -- memory a test or foreign code put there, never a value Botlish
decoded. `Ptr -> Int` and `Ptr -> Bytes` remain absent as conversions: the
encoding is layout-directed into a statically compatible pointer field only.

**The caller-constructed record** -- the Win32 shape
(`x.cbSize = sizeof x; x.handle = h; x.callback = cb; SomeApi(&x)`) -- is
`abi::bytes::zeroed(abi::usize(binary::layout_length(L)))`, `binary::write`
for the ordinary fields, `binary::write_foreign` for the pointer, handle and
callback fields, and the existing exposure of the storage to the call. The
borrowing semantics are unchanged: the outer storage is exposed only to a
`noescape` parameter of known access, and nothing inspects the pointer fields
inside the record (C-POINTER-BORROWING.md section 15's retained-pointer
problem is the wrapper's). `ne-c-oracle-built` is this milestone's stand-in
for that workload.

## 11. Padding and adjacent bytes

A write modifies exactly the bytes of its field, on both backings: in
native memory every other byte -- padding between fields, tail padding,
neighbouring fields, the bytes of nested layouts -- keeps whatever it held
(sentinel bytes in every test: `ne-store-touches-only-its-bytes`,
`ne-nested-stores`, the C oracle's padding check, every fuzz program's model);
in byte storage every other byte keeps the operand's (`ne-write-value-
semantics`, `ne-write-every-encoding`). Nothing zeroes or normalizes padding
on a write (emission's zero padding is emission's). This matters for
generated layouts, whose padding is a compiler fact, not Botlish storage.

## 12. Diagnostics and failures

| situation | kind |
|---|---|
| `NativeEdit[int]`, `[S]`, `[List[int]]`; `NativeEdit[Nope]`; bare `NativeEdit` | `LAYOUT-STRUCT-PARAMETER`, `UNKNOWN-LAYOUT`, the arity `TYPE` |
| the edit's layout operand not a layout; its pointer an Int, a function pointer, byte storage, a view, an edit | `UNKNOWN-LAYOUT`, `LAYOUT-OPERAND`; `BINARY-OPERAND` |
| a store through a `NativeView` (or anything not statically a `NativeEdit`) | `BINARY-OPERAND` ("a native view, which is read-only") |
| a byte write into anything not statically a `MutableBytes` | `BINARY-OPERAND` |
| a designator that is no `LAYOUT.FIELD` chain, or rooted at a value | `LAYOUT-OPERAND` |
| a designator's unknown root layout | `UNKNOWN-LAYOUT` |
| an absent field; a name after a scalar or pointer field | `UNKNOWN-FIELD` (listing the layout's fields) |
| a designator ending at a nested layout | `LAYOUT-OPERAND` |
| a store's field of another layout than its edit's | `LAYOUT-OPERAND` |
| a value not proven in its field's type (an out-of-range Int, another pointee, an Int for a pointer) | `TYPE` (at the value, naming the field and the facts) |
| an ordinary `binary::write` of a pointer field | `LAYOUT-NATIVE-ONLY` |
| a `binary::write_foreign` of an ordinary field | `LAYOUT-FOREIGN-WRITE` (new) |
| a byte write into storage of another size | the declared `LayoutLengthMismatch` |
| an edit of the null pointer | the declared `NativeEditNull` (not `NativeViewNull`: the access named is write) |
| an edit of a non-null pointer on interp / compile | the run-time `NATIVE-ONLY` |
| a write operation used as a value | `BINARY-OPERAND` |
| a store through an edit whose type is not static (an untyped parameter) | `BINARY-OPERAND`; a read of one in an instance, `TYPE` at the call |
| a `-strict 0` program's rejected write | its diagnostic replayed when the call runs, before anything is written (`BINARY-OPERAND`, `LAYOUT-NATIVE-ONLY`, `LAYOUT-FOREIGN-WRITE`, `LAYOUT-OPERAND` joined the native runtime's kinds); an unproven scalar the encoder's `RANGE` |

`LAYOUT-FOREIGN-WRITE` is classified in `tests/static-compile.test`'s census
(a `static compile:` block can produce it: its case is
`compiler::DiagnosticCode::LayoutForeignWrite`) and documented in
Compilerpedia (`error.layout-foreign-write`). An edit of the null pointer has
its own error rather than `NativeViewNull` because the diagnostic names the
operation that failed, and a view's name would say read access.

## 13. Bounds and validity

What Botlish knows, it enforces statically: the field lies inside the
declared layout, at a valid offset and width (the layout's validation); a
nested subrecord lies inside its outer layout; the edit's constructor
rejected null, so no store checks again. A `MutableBytes`' length is checked
against the layout's size at run time (exactly equal).

What only the foreign interface knows -- that the address is a live,
writable allocation of at least the layout's size, that no other thread frees
or revokes it while the edit is used, that the operating system will not
unmap it -- Botlish does not pretend to check: no allocation registry, no
memory validation. A bad address faults natively like the C it stands for.

A store is an ordinary native store: not volatile, not atomic, no memory
ordering, no fence, no device-register semantics. `NativeEdit` is for
ordinary memory whose synchronization protocol is handled externally. Every
store and every read is a runtime helper call that the code generator treats
as reading and writing all memory, so none is merged, cached, forwarded or
reordered (`ne-no-caching`: two stores of one value are two stores, a read
after a store is a load). A device or shared-memory workload would need
distinct operations; none exists.

## 14. Representation and lowering

**HIR.** `NativeEdit[L]` is `{nedit L}`. `binary::native::edit(L, p)` is a
call of its root native whose layout operand resolution turns into L's
descriptor constant; its result shape `{native-edit 0}` types it. Reads
elaborate exactly as a view's (`hir::layouts::Elaborate`: `e.f` becomes
`binary#view_field(e, FIELD)`, `binary::load(e)` becomes `binary#load(e,
DESCRIPTOR)`); `binary#view_field`'s result shape `{view-field 0 1}` gives a
nested layout read through an edit the type `NativeEdit[Inner]` when
specialization re-infers a function (`ne-specialization`). The writes need no
elaboration: their designator is already the constant a backend reads. The
`-layout` roles gained `edited K`, `output K`, `path K`, `value K` and the ops
`edit`, `store`, `write`, `write_foreign` (core/native.tcl; read by every
layer, never a name).

**Native.** An edit is its pointer's C address word, like a view: an
immediate, never a GC root, never allocated. NIR gained four ops (and the
fixture's fifth; native/src/nir.rs, runtime/nview.rs), and lowering emits one
per write (native/lower.tcl's `LayoutWrite`):

```
binary::native::edit(L, p)       %n = op cptrisnull %p ; br %n L1 L0 ; L1: faildeclared NativeEditNull ; L0: (the edit is %p)
binary::store(e, L.f, v)         op nativestore %e %OFFSET %ENCODING %v       (binstore's encoding word)
binary::store(e, L.p, q)         op nativestoreptr %e %OFFSET %WIDTH %q
binary::store(e.a.b, B.f, v)     one nativestore at the absolute offset       (ViewBase folds the subrecords)
binary::write(d, L.f, v)         op mbyteslen / ieq / br / faildeclared LayoutLengthMismatch ;
                                 %s = op mbyteswrite %storage %OFFSET %ENCODING %v   (a fresh storage)
binary::write_foreign(d, L.p, q) ... ; %s = op mbyteswriteptr %storage %OFFSET %WIDTH %q
```

Each op is a runtime helper call: `nativestore` encodes the value with the
encoder `binstore` uses (ops.rs's `bin_encode`, factored out of `rt_bin_store`
for both backings: one width/signedness/range rule), then copies exactly
WIDTH bytes to the address with one unaligned `copy_nonoverlapping` (no
Rust reference to a possibly unaligned foreign field is ever formed);
`nativestoreptr` copies the pointer's address bits (a narrower width must
hold the address: `RANGE`, never a truncation). `mbyteswrite` and
`mbyteswriteptr` encode first, then allocate the fresh storage, copy the
operand into it and write the field: the operand is never written. Nothing
reads the record, copies it through bytes, builds a `LayoutStruct` or walks
the layout at run time (`ne-nir`; the mutant `copy-per-store` is killed by
the NIR and allocation tests).

```
func "put" (e: NativeEdit[Deep])        binary::store(e, Deep.head, 7)
    %1 = int 7                          binary::store(e.outer.inner, Inner.y, 513)
    %3 = int 0                          binary::store(e, Deep.outer.inner.x, -2)
    %4 = int 1
    %5 = op nativestore %0 %3 %4 %1     ; head: offset 0, u8
    %8 = int 10
    %9 = int 2
    %10 = op nativestore %0 %8 %9 %6    ; outer.inner.y: 4 + 4 + 2, u16 -- no cptroffset
    %17 = int 8
    %18 = int 18
    %19 = op nativestore %0 %17 %18 %16 ; outer.inner.x: 4 + 4 + 0, i16 (2 + 16)
```

**The fixture.** `core::cabi::installTestFixture` also registers
`ffi_fixture::memory_bytes(p, n)`: natively the N bytes at the C address P
as a List of Ints (`op cptrfixturebytes`), copied with no layout and no
view -- the oracle of a native write. Only a test process can name it; the
Tcl backends refuse it (`NATIVE-ONLY`).

## 15. The Tcl backends

They have no native memory, so they keep the honest capability boundary of
the read milestone: `binary::native::edit` is `NativeEditNull` for a null
pointer and the run-time refusal `NATIVE-ONLY` ("reads and writes live
native process memory ...") for any other; an edit can therefore never exist
there, and `binary::store` refuses too (core/binary.tcl). Byte storage is
theirs: `binary::write` and `binary::write_foreign` run on interp and
compile exactly as natively (core/binary.tcl's reference implementation,
sharing `ScalarPiece`, the scalar encoder `binary::emit` now uses too); a C
pointer value has its address there as well (the fixture's addresses, null),
so the foreign write encodes it -- nothing is fabricated (`ne-tcl-backends`,
`ne-write-foreign` on all four backends). The Tcl compiler compiles every
write as a generic call of the reference implementation. Static checking and
diagnostics are the same on every backend: they are the front end's.

## 16. HIR, interchange, cache, isolation

No new registry: everything a backend reads about a write is in the HIR --
the designator constant carries the absolute offset and the encoding, the
descriptor constant an edit's layout. `NativeEdit[L]` prints and reads back as
HIR text (`ne-hir-text-roundtrip`: format, read, format is identical and the
read HIR runs; HIR text of a program importing a library module does not
round trip in general -- `binary::store` needs `import binary` -- so the
writes are carried by interchange). `hir/interchange.tcl` carries the HIR
dict: a program written as `.hirx` and read back after another compilation
declaring a same-named layout with other offsets writes through its own
layout, natively and on the Tcl backends (`ne-interchange`); `main.tcl
-emit-hir-interchange` and a fresh process running the `.hirx` on every
backend write the bytes the source does (`ne-interchange-fresh-process`); two
compilations of a same-named layout with swapped offsets keep their own
writes (`ne-isolation`); the front-end cache stores and reads back a program
of stores and writes (`ne-cache`). The pointer width comes from the target
the program's `ffi::c` scalars were declared for, already in the cache key.

## 17. Targets

Nothing is x86-64-specific. A pointer field's width is the compilation's C
target's (core/cabi.tcl's table, through `hir::cabi::CompilationTarget`: 8 on
every target there); a C scalar's domain is the target's
(`ne-store-value-types`: `UInt`, `Long`, `ULong` on the host's linux-x86_64);
a layout's offsets are explicit and never recomputed. The runtime helpers
are architecture-neutral Rust (unaligned `copy_nonoverlapping`), the stores
little-endian like every layout field. CI runs `tests/native-edit.test` on
Linux x86-64, on Linux AArch64 (`tests-arm64.yml`) and on macOS arm64
(Tier B), where its allocation counts, GC stress, executable and C oracle
skip by their capability constraints, as every other file's do there.

## 18. Performance

`bench/native-edit.tcl -runs 5 -n 200000`: see the tables below (measured
after the change; section 20 has the date and the machine). Programs repeat
one operation 200,000 times in a collecting loop, reported as the time per
operation over the loop's baseline, natively.

MEASUREMENTS-TABLE

## 19. Tests, the oracles, fuzzing, mutants

TESTS-SECTION

## 20. Regression and CI

REGRESSION-SECTION

## 21. The read milestone's questions, answered

NATIVE-LAYOUT-VIEWS.md section 16 listed what writes would have to decide:

1. **Pointer encoding into bytes.** Yes, by the explicit
   `binary::write_foreign` only; ordinary `binary::emit` and `binary::write`
   never encode one; bytes are never re-materialized as a pointer except by
   copying them into native memory and reading that memory through a view or
   an edit (section 10).
2. **Write authority.** One namespace, `binary::native`, with a read and a
   write constructor; a view never upgrades, and an edit is made from a
   pointer separately (sections 4, 5).
3. **Affinity of a writable view.** Unrestricted, not affine: affinity would
   prove one Botlish handle, not exclusive access to foreign memory, and
   would be presented as more (section 6). A view does not gain `clone`.
4. **Subviews of writable views.** `NativeEdit[Inner]` at the outer offset;
   raw aliasing between a parent and its subrecords is accepted, no
   borrow-like rule (section 4).
5. **Storing pointers.** Observed, not moved; a store records no
   dependency and is not a "retaining" C call -- it writes Botlish-reachable
   memory a program already had authority over, and what foreign code later
   does with that memory is a protocol fact (section 8).
6. **Native records.** Not here: a caller-constructed record is
   `MutableBytes` plus the borrowing machinery (section 10); a Botlish-owned
   native allocation waits for a workload that retains one (section 22).
7. **`MutableBytes` foreign writes through a layout.** Exactly that,
   field-wise (sections 9, 10).
8. **Bitfields and unions.** Still absent; their writes wait for the
   representation (section 22).
9. **`ffi::c::Bool` fields.** Still not a layout field: no generic write
   encoder needed one (section 22).
10. **Volatile / concurrent memory.** Plain stores, in program order, never
    cached; no volatile, atomic or fenced operation (section 13).
11. **The Tcl backends.** Edits refused (`NATIVE-ONLY`); byte writes run;
    native evidence comes from real native memory (section 15).

## 22. Pressure on generated native layouts

What the completed read/write machinery now requires from a future layout
producer (the C binding generator, C-BINDGEN.md, which this milestone did not
touch), as input to the C-bindgen layout milestone:

* **Explicit size, alignment and offsets, every one.** Reads and writes use
  the declared offsets and nothing else; Botlish computes no layout, so the
  producer must emit the C compiler's resolved values (from `offsetof`,
  `sizeof`, `_Alignof` probes, as the fixtures' static assertions do), and
  the size must include tail padding: a byte write requires storage of
  exactly the size, so a record built in bytes is exactly `sizeof(T)`.
* **Padding is the gaps.** A write never touches padding, so a generated
  layout need not (and cannot) declare it; but a caller-constructed record's
  padding is whatever its storage held (zero from `abi::bytes::zeroed`):
  APIs that compare whole structs (`memcmp`) or hash them see that.
* **Pointer and function pointer fields** with their exact pointee identity
  (an opaque struct per C struct type, `ffi::c::Void` for `void *`) and
  signature: stores and foreign writes admit only the exact type, so a
  generator that erases pointees to `Void` forces every caller through
  `ffi::c::erase`/`retype`. Handles typed as pointers (`HWND`, `HANDLE`) need
  the same.
* **Fixed arrays** (`char name[16]`, `POINT pts[4]`, `WCHAR szDevice[32]`):
  not representable. A designator names a leaf; an array would need an
  element designator with a static index (`L.pts[2].x`) or a repetition
  descriptor -- and their writes (store one element, a whole array from a
  List). Until then a generator can only emit arrays of bytes as runs of U8
  fields or skip the struct.
* **Bitfields** (`unsigned flags : 3`): not representable. A write of one is
  a read-modify-write of its storage unit, which a store is not; the
  generator must at least emit the storage unit as a scalar field (the
  wrapper extracts bits) and the bit allocation the compiler chose, which is
  ABI-specific.
* **Unions and overlapping alternatives** (`union { ... }`, anonymous unions
  in Win32 structs): overlap is rejected; writing one alternative changes
  every other's reading, so the representation needs an explicit overlay
  first. A generator could emit one layout per alternative over the same
  bytes, each written separately.
* **`ffi::c::Bool` fields** (SDL3): not a layout field yet. A write would be
  one byte, 0 or 1; a read of any other byte must be the `NATIVE BOOL`
  failure a C result has. Today a generator must use `binary::U8`.
* **Compiler-specific packing and alignment** (`#pragma pack`,
  `__declspec(align)`, `__attribute__((packed, aligned))`): already
  representable as explicit offsets and an explicit alignment; nothing
  consumes `align` yet (no native allocation places a layout), so a
  generator should still emit it truthfully for the allocation milestone.
* **`cbSize`-style self-describing fields** need `binary::layout_length(L)`,
  a compile-time constant that fits any U32/U16 field.
* **Facts no layout states.** Endianness (big-endian network structs:
  recorded per field in the registry, but no syntax), floating-point fields
  (Botlish has no float), flexible array members and variable-length tails,
  `const` fields (C's `const` is no fact a layout keeps), volatile fields,
  and per-field ownership of a stored pointer (whether an API takes it, keeps
  it or borrows it) -- the last is a wrapper's protocol, never the layout's.

## 23. Not here

No native record allocation (`binary::native::allocate`, `NativeRecord[L]`,
malloc-backed layouts, Botlish-owned stable addresses, free or destructor
semantics); no C bindgen change, C header struct probing or `extern c
struct`; no layout guarantee, `repr(C)` or pinning for an ordinary Botlish
value; no ownership or lifetime tracking of foreign memory, no hidden pointer
dependency, no borrow checking; no aggregate C ABI (records by value),
callbacks into Botlish, floating point, arrays, unions, bitfields, dynamic or
trailing extents, `ffi::c::Bool` fields, volatile or atomic memory; no pointer
arithmetic, `Ptr <-> Int` or `Ptr -> Bytes` conversion, and no decoding of a
pointer from bytes. No edit-to-view reduction, no whole-record foreign
emission, no method syntax for the writes.

## 24. What to run when changing this

If you change field designators (`hir/layouts.tcl`'s `FieldPath`,
`PathField`, `hir/resolve.tcl`'s `FieldPathOperand`), the NativeEdit type (the
`nedit` cases of hir/types.tcl, hir/read.tcl, hir/resolve.tcl, hir/structs.tcl,
hir/affine.tcl, hir/cabi.tcl, hir/range.tcl), the write checks
(`hir::layouts::Problems`, `VerifyWriteValue`), the write operations'
registrations or roles (core/binary.tcl, core/native.tcl), the reference
implementation (core/binary.tcl's `write`, `writeForeign`, `ScalarPiece`),
escape's recognition of a write's result (hir/escape.tcl), native lowering
(`LayoutWrite`, the `edit` case of `LayoutCall`, `ViewBase`) or the runtime
(runtime/nview.rs's store and write helpers, ops.rs's `bin_encode`, the ops in
nir.rs and codegen/clif.rs), run `tests/native-edit.test` (its C oracle needs
`cc`), `tests/native-view.test`, `tests/binary-layout.test`,
`tests/c-abi-types.test`, `tests/c-pointer-borrowing.test`,
`tests/direct-modules.test`, `audit/native-edit/tools/fuzz.tcl` (several
seeds, once with `-gc-stress 1`, once with `-backends "interp compile
cranelift-generic cranelift"`), `audit/native-edit/tools/mutate.tcl` (every
mutant in its `mutants.txt` must still apply and be killed: update a mutant's
text when you change the code it mutates, keeping it a mutant of the same
rule) and `cargo test --release --manifest-path native/Cargo.toml --lib
nview`; plus the native-view and binary-layout harnesses (their mutants
share this code: `bin_encode`, `ViewBase`, the subtype rule).
`bench/native-edit.tcl` regenerates the performance report.

## 25. Files

| file | what |
|---|---|
| `hir/layouts.tcl` | `editType`, `OfEditType`, `OfNativeType`, `NativeFieldType`, field designators (`FieldPath`, `PathLayout`, `PathField`), `ResolveNativeEdit`, the roles, the write checks in `Problems`, `VerifyWriteValue`, the edit cases of `Elaborate` and `verifyInstance` |
| `hir/types.tcl` | `{nedit L}`: `IsNativeEdit`, `IsNativeMemory`, resolution, subtyping, joins, projection, the `native-edit` and `view-field` result shapes |
| `hir/resolve.tcl` | `FieldPathOperand`; `NativeEdit[L]` |
| `hir/range.tcl`, `hir/structs.tcl`, `hir/affine.tcl`, `hir/cabi.tcl`, `hir/read.tcl`, `hir/escape.tcl` | admission, projection check, ownership of reads, not-a-pointer, HIR text, a write's result held as its storage |
| `hir/static.tcl`, `lib/compiler.bot`, `lib/test.bot` | `LAYOUT-FOREIGN-WRITE` |
| `core/binary.tcl`, `core/native.tcl`, `core/cabi.tcl` | the operations and their reference implementation, the roles and shapes, `NativeEditNull`, the byte fixture |
| `native/lower.tcl` | `LayoutWrite`, `LayoutCall`'s `edit` |
| `native/src/runtime/nview.rs`, `ops.rs`, `nir.rs`, `codegen/clif.rs`, `runtime/error.rs` | `nativestore`, `nativestoreptr`, `mbyteswrite`, `mbyteswriteptr`, `cptrfixturebytes`; `bin_encode`; the replay kinds |
| `tests/native-edit.test`, `tests/cffi/nedit-fixture.c` | the suite and the C oracle |
| `audit/native-edit/tools/` | the fuzzer and the mutants |
| `bench/native-edit.tcl` | the performance report |
| `compilerpedia/` | `stdlib.binary::native::edit`, `::store`, `::write`, `::write_foreign`, `error.layout-foreign-write` |
