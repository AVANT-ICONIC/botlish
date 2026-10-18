# NATIVE-LAYOUT-VIEWS.md

Read-only native layout views: an ordinary `layout` read from authorized
live native memory, through `binary::native::view(L, p)` and
`NativeView[L]`; and pointer fields in layouts.

> The layout determines where the bits are. The backing decides what those
> bits are allowed to mean. A native view observes authorized native memory
> through an ordinary layout; it does not create a native object model for
> Botlish.

```botlish
direct module                              # making a view is raw authority

import binary
import binary::native
import ffi::c

opaque struct Node:                        # a pointee identity
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
    field next: ffi::c::Ptr[Node] at 8                                    # a pointer field
    field callback: ffi::c::FnPtr[Fn{args: [ffi::c::Int], return: ffi::c::Int}] at 16

fn origin_x(p: ffi::c::Ptr[Node]) -> int errors NativeViewNull:
    v = binary::native::view(RECORD, p)    # NativeView[RECORD]: p is observed, nothing is read
    o = v.origin                           # NativeView[POINT]: an address, nothing is read
    n = v.next                             # ffi::c::Ptr[Node]: the pointer that memory holds
    s = binary::load(v)                    # LayoutStruct[RECORD]: every field read once
    v.count + o.x                          # one load each, at the layout's offsets
```

## Contents

1. [The model](#1-the-model)
2. [Source surface](#2-source-surface)
3. [Byte backing and native backing](#3-byte-backing-and-native-backing)
4. [Pointer fields](#4-pointer-fields)
5. [What native views support](#5-what-native-views-support)
6. [Diagnostics and failures](#6-diagnostics-and-failures)
7. [Bounds and lifetime](#7-bounds-and-lifetime)
8. [Authority: direct modules](#8-authority-direct-modules)
9. [Representation](#9-representation)
10. [HIR, interchange, cache, isolation](#10-hir-interchange-cache-isolation)
11. [Targets](#11-targets)
12. [Performance](#12-performance)
13. [Tests, the fixtures, fuzzing, mutants](#13-tests-the-fixtures-fuzzing-mutants)
14. [Regression](#14-regression)
15. [What the existing layout architecture showed](#15-what-the-existing-layout-architecture-showed)
16. [Pressure on the write milestone](#16-pressure-on-the-write-milestone)
17. [Not here](#17-not-here)
18. [What to run when changing this](#18-what-to-run-when-changing-this)
19. [Files](#19-files)

## 1. The model

```
external ABI / file format / device / (later) a generated description
                         |
                         v
                       layout                  explicit size, alignment,
                         |                     offsets, encodings (one
                         |                     registry entry, one descriptor)
              +----------+-----------+
              |                      |
       byte backing             native backing
 binary::parse(L, bytes)    binary::native::view(L, ptr)
   LayoutStruct[L]               NativeView[L]
 (a copy: every field      (an address: each field read
  imprinted once)           when it is projected)
```

There is one description language, `layout` (BINARY-LAYOUT.md), and no
second one: no `extern c struct`, no `repr(C)`, no C layout rule. A
handwritten layout is already concrete; a later binding generator will ask
the target's C compiler for each struct's offsets and print ordinary
layouts. Ordinary Botlish values gain nothing: a Botlish `struct` has no
address, no stable field offset, no pinning, no physical field order, and
`LayoutStruct[L]` is still an ordinary immutable struct value that retains
nothing.

The two backings differ only where authority differs:

* **byte storage** (`abi::bytes::Bytes`) is data: any bit pattern can arrive
  there, so imprinting it may decode Ints, and never pointers;
* **native memory** behind an `ffi::c::Ptr[T]` is live process memory some
  foreign code handed the program an address of: a pointer stored there is
  the one that code put there, so a view may read it back.

## 2. Source surface

| form | what | notes |
|---|---|---|
| `field NAME: ffi::c::Ptr[T] at O`, `field NAME: ffi::c::FnPtr[F] at O` | a pointer field of a layout | the target's pointer width; the pointee or signature validated like any `Ptr`/`FnPtr` (C-ABI-TYPES.md) |
| `NativeView[L]` | the type of a native view of layout L | a built-in applied type like `LayoutStruct[L]`; its argument names a layout |
| `binary::native::view(L, p)` | NativeView[L] of the memory data pointer `p` addresses | L is static evidence (a layout name); `p` statically an `ffi::c::Ptr[T]`, observed; `errors NativeViewNull` |
| `v.field` | one field read | a scalar's integer domain; a nested layout's `NativeView[Inner]`; a pointer field's declared `Ptr`/`FnPtr` |
| `{a: x, b: y} = v` | destructuring | the ordinary expansion: one read per named field |
| `binary::load(v)`, `v.load()` | the whole record, `LayoutStruct[L]` | every field read once; L from v's static type |
| `binary::layout_length(L)`, `binary::layout_alignment(L)` | unchanged | compile-time constants of the layout, whatever backs it |

`binary::native` is an intrinsic namespace (core/binary.tcl, like
`linux::abi::x86_64`): `import binary::native` reaches it, and its only
member is `view`. `NativeViewNull` is a builtin declared error, like
`LayoutLengthMismatch`. Nothing else was added: no new statement, keyword,
operator or field-access vocabulary. A view's field is read with the same
projection a `LayoutStruct`'s is.

Naming. `NativeView` beside `LayoutStruct` (the two backings' types, both
global applied types whose argument is a layout), the constructor in a
namespace of its own (it is the authority-bearing operation, section 8),
`binary::load` in `binary` beside `binary::parse` (reading a view someone
made is not authority).

## 3. Byte backing and native backing

| | `LayoutStruct[L]` (bytes) | `NativeView[L]` (native memory) |
|---|---|---|
| made by | `binary::parse(L, bytes)`, or constructed `LayoutStruct[L] {...}` | `binary::native::view(L, p)` only (never constructed: `UNKNOWN-STRUCT`) |
| holds | the field values (a copy) | the address (the pointer's word) |
| a field read | a struct field | one load from memory at the field's offset |
| a nested layout | a `LayoutStruct[Inner]` value | a `NativeView[Inner]` (the address plus the offset: no load) |
| a pointer field | rejected from bytes (`LAYOUT-NATIVE-ONLY`) | the pointer memory holds |
| equality, hash | by fields | none (the run-time EQUALITY error, as for a callable) |
| affinity | its fields' (affine iff it holds a pointer) | unrestricted (a non-owning window) |
| lifetime | its own | none: the memory's owner's (section 7) |
| backends | all four | the native ones; the Tcl backends refuse (`NATIVE-ONLY`) |

The two types are categorically distinct: nominal, never subtypes of each
other in either direction, never of another layout's view with the same
fields, and a view is never a pointer (no pointer operation takes one:
`null?`, `clone`, `erase`, a C function's pointer parameter are `TYPE` /
`IMPRINT`), never an Int, and there is no way back from a view to a pointer.

`binary::load(v)` is the native imprint: for a pointer-free layout it equals
`binary::parse(L, b)` of the same bytes field for field (`nv-scalar-reads`,
every fuzz program); for a native-only layout it is an affine
`LayoutStruct[L]` owning the pointers it read (section 4).

## 4. Pointer fields

A layout field may be a data pointer `ffi::c::Ptr[T]` or a function pointer
`ffi::c::FnPtr[F]`. Its **representation** is a field like any other -- its
width is the compilation's C target's pointer width (8 on every target of
core/cabi.tcl's table), it lies inside the size, it never overlaps another
field, at any offset (aligned or not) -- and its **meaning** is authority: an
address foreign code handed out. A layout holding a pointer field, directly
or in a nested layout, is **native-only**:

* **through a native view** a pointer field reads the exact pointer the
  memory holds: the same address bits, the declared pointee identity or
  signature, null as null. It is a fresh affine value -- its binding's, like
  a C call's pointer result -- governed by the ordinary affine rules: an
  observed temporary has no owner (`AFFINE-TEMPORARY-UNSUPPORTED`), no
  equality, and two reads are two values (no implicit clone of one). An
  address the C address word cannot hold (a top-byte-tagged AArch64 pointer)
  is the `NATIVE ADDRESS` failure a C call's pointer result has, never a
  truncated pointer;
* **from bytes** it is never materialized: `binary::parse(L, bytes)` of a
  native-only layout is `LAYOUT-NATIVE-ONLY` at the operand ("its field
  "next" is a C pointer, and imprinting arbitrary bytes into it would make a
  pointer no foreign code handed out"); a nested pointer is named by its
  path (`link.next`);
* **into bytes** it is never written: `binary::emit(v)` of one is
  `LAYOUT-NATIVE-ONLY` too (writing pointers is the next milestone's,
  section 16).

How forging is prevented: the only operations that produce a value of a
pointer field's type are the view's projection and `binary::load` -- both
reading native memory through a view that itself came from an existing
pointer -- and `LayoutStruct[L] {...}` construction, which only moves in a
pointer the program already owns. Byte storage reaches a pointer type
nowhere: parse rejects the layout statically, and the Tcl reference
implementation refuses a `ptr` descriptor entry even if handed one (a core
IR program written by hand). A program that wants the raw bits of a pointer
word from bytes declares the word as what it is there -- an integer
(`field next: binary::U64 at 8`, the "bits twin" the tests and the fuzzer
use): an inert Int, with no pointer operation.

`LayoutStruct[L]` of a native-only layout is an ordinary struct holding
pointers, affine by the ordinary rule (AFFINE-VALUES.md): its pointers move
out only by destructuring, it has no equality. Making
`hir::structs::IsAffine` answer for a `LayoutStruct` (it used to report 0
for every one: the identity is not in the struct registry) was the one fix
this needed.

Pointer fields resolve in two steps, because a pointee is usually an opaque
struct and layouts register before structs (a struct field may name
`LayoutStruct[L]`): the width (the target's) and every placement check at
the layout's registration, the pointer type itself after the structs
(`hir::layouts::ResolvePointers`, from `hir::sourcetypes::apply` and, for
HIR text, `hir/read.tcl`).

## 5. What native views support

Parity with every read of the byte backing whose meaning does not depend on
the address space:

| layout feature | through a native view |
|---|---|
| scalar fields, the eight encodings | yes: one load per read, the same value `binary::parse` gives |
| explicit offsets, padding | yes: the layout's offsets; padding never read (`nv-padding-never-read`) |
| unaligned fields and packed layouts | yes: loads are unaligned (`Packed`: a nested layout at offset 1, a u32 at 5) |
| nested layouts | yes: a `NativeView[Inner]` subview at the outer offset plus its own, any depth; chained reads fold to one load at the absolute offset |
| projection, destructuring | yes, the same vocabulary |
| whole-record imprint | `binary::load(v)` (`== binary::parse` for pointer-free layouts) |
| layout queries | unchanged (static) |
| C scalars (`ffi::c::Long`, ...) | yes: they are integer domains of the target's widths |
| pointer fields | **native only** (section 4) |

Not in this milestone because the existing layout system has none of them
(BINARY-LAYOUT.md, "The fixed-layout limitation"): fixed arrays and
repetition, unions or overlapping fields, bitfields, dynamic or trailing
extents, explicit byte order, floating point, `ffi::c::Bool` fields. Each is
still rejected at the declaration exactly as before (`LAYOUT-FIELD-OVERLAP`,
`LAYOUT-FIELD-TYPE`). The restriction for dynamic extents is therefore
vacuous: every layout has a static size, and a view's extent is its
layout's size. Each of them is pressure on later milestones (section 16).

## 6. Diagnostics and failures

| situation | kind |
|---|---|
| a pointer field outside the size, overlapping, of an invalid pointee or signature | `LAYOUT-FIELD-BOUNDS`, `LAYOUT-FIELD-OVERLAP`, `LAYOUT-FIELD-TYPE` (as for any field) |
| a pointer field in a compilation that imports no `ffi::c` | `LAYOUT-FIELD-TYPE` (no target, no width) |
| `binary::parse` / `binary::emit` of a native-only layout | `LAYOUT-NATIVE-ONLY` (new; `compiler::DiagnosticCode::LayoutNativeOnly`) |
| `NativeView[int]`, `[S]`, `[List[int]]`; `NativeView[Nope]`; bare `NativeView` | `LAYOUT-STRUCT-PARAMETER`, `UNKNOWN-LAYOUT`, the arity `TYPE` (LayoutStruct's) |
| the view's layout operand not a layout | `UNKNOWN-LAYOUT`, `LAYOUT-OPERAND` |
| the view's pointer an Int, a function pointer, byte storage, a view | `BINARY-OPERAND` |
| `binary::load` of anything but a static `NativeView[L]` | `BINARY-OPERAND` (its result is poison: nothing else is reported) |
| `view` / `load` as values | `BINARY-OPERAND` |
| an absent field | `UNKNOWN-FIELD`, listing the layout's fields |
| a view where a pointer or another type is required | `TYPE` / `IMPRINT` |
| constructing `NativeView[L] {...}` | `UNKNOWN-STRUCT` |
| a field read through a view whose type is not static (an untyped function's instance) | `BINARY-OPERAND` in the instance, reported at the call (`TYPE`: "call to g ... is invalid") |
| a view of the null pointer | the declared error `NativeViewNull` (`UNHANDLED-ERROR` unless handled) |
| a view of a non-null pointer on interp / compile | the run-time `NATIVE-ONLY` |
| a pointer field the C address word cannot hold | the run-time `NATIVE ADDRESS` failure |
| `==` of two views | the run-time `EQUALITY` error |
| an unmediated view in an ordinary module | `DIRECT` (section 8) |

Why a field read needs a static view type: it lowers to its field's
constant offset and encoding (section 9), and `-specialize 0` compiles an
untyped function once, for any argument; so, as `binary::emit` needs a
statically typed value, a view's projection needs a statically typed
receiver, and an instance that would read one through an untyped parameter
is rejected (`hir::layouts::verifyInstance`).

A `-strict 0` program's rejected view or load replays its diagnostic at run
time natively (`BINARY-OPERAND` and `LAYOUT-NATIVE-ONLY` joined the
runtime's known kinds; the binary operations' replays had been reported as
NATIVE BUG before).

## 7. Bounds and lifetime

What Botlish knows, it enforces, statically:

* every field lies inside the layout's size and no two overlap -- pointer
  fields at the target's width -- so a read at a field's offset never leaves
  the layout's extent;
* a nested view is at its field's offset, its own layout's size inside the
  outer one (the same validation), so a chain of nested views stays inside
  the outermost layout's extent;
* a view is never null (its constructor fails with `NativeViewNull` first),
  so no field read checks again;
* fixed arrays do not exist, so there is no index to check.

What only the foreign interface knows -- that the address is a live
allocation of at least the layout's size, that it stays alive while the view
is read, that no other thread frees or writes it -- Botlish does not pretend
to check: there is no allocation registry, no foreign-memory ownership
tracking, no hidden reference. A view is non-owning: it keeps nothing alive,
retains no resource and extends no pointer's lifetime; reading through a
dangling address faults like the C code the binding stands for. Alignment
is a placement fact, not a bound: loads are unaligned, and a nested layout
inside a packed one may legitimately sit at an offset its own alignment does
not divide, so no alignment is required of a view's address.

The pointer a view is made from is only observed (as a C call observes a
pointer argument): it stays its owner's, and every affine rule still applies
to it.

## 8. Authority: direct modules

Reading live process memory is raw authority (DIRECT-MODULES.md, "What
direct means": "a machine address"). `binary::native` is an intrinsic
namespace **designated direct** (`core::native::declareDirectNamespace
binary::native`, beside the syscall transports): a call of
`binary::native::view` in module U is a direct edge of U, mediated only by a
context U declares itself, or acknowledged by `direct module`
(`nv-direct`). The authority source is the operation, never the layout:

* declaring a layout with pointer fields, naming `NativeView[L]` or
  `LayoutStruct[L]`, `binary::parse` and the layout queries are ordinary;
* reading a view someone else made -- its fields, `binary::load` -- is
  ordinary: the view is the authority, already granted, like a callable a
  direct module hands out (`nv-direct-modules`: a direct module makes views,
  an ordinary module that takes one as an argument and reads it stays
  ordinary, and the program calling the direct module mediates that call
  with its own context);
* a module that only reads views and is marked `direct module` is
  `STALE-DIRECT-MODULE`.

No `unsafe`, no per-operation marker, no new designation mechanism.

## 9. Representation

**Canonical layout.** One registry entry per layout (hir/layouts.tcl) and
one descriptor text per layout serve both backings. A pointer field is a
third field kind:

```
registry   {name F offset O kind pointer width W endian little type T}   T {cptr P} | {cfnptr F}
descriptor {NAME OFFSET ptr WIDTH ENDIAN}
HIR text   F: ffi::c::Ptr[Node] at 8          (the canonical pointer type)
```

**HIR.** `NativeView[L]` is the type `{nview L}`: nominal, unrestricted,
runtime kind `cptr`, printed `NativeView[L]` and read back by
hir::read::ParseType. `binary::native::view(L, p)` is a call of the root
native whose layout operand resolution turns into L's descriptor constant
(as for `binary::parse`); its result shape `{native-view 0}` types it. After
the checks, `hir::layouts::Elaborate` writes every view operation out with
constant operands, so no backend reads a layout or knows the view type:

```
v.f              ->  binary#view_field(v, FIELD)     FIELD f's descriptor entry; the projection's type
binary::load(v)  ->  binary#load(v, DESCRIPTOR)      as binary::emit -> binary#emit
```

(`binary#view_field`'s result shape `{view-field 0 1}` recovers the field's
type when specialization re-infers a function.) The native `-layout` roles
gained `pointer K`, `viewed {AT FORM}`, `field K` and the ops `view`,
`load`, `field` (core/native.tcl, read by every layer, never a name).

**Native.** A view is its pointer's C address word, `(address << 4) | 0b1110`
(C-ABI-TYPES.md): an immediate, never a GC root, never allocated. NIR has
three new ops (native/src/nir.rs, runtime/nview.rs) and lowering emits one
per field read (native/lower.tcl's `NativeField`):

```
binary::native::view(L, p)   %n = op cptrisnull %p ; br %n L1 L0 ; L1: faildeclared NativeViewNull ; L0: (the view is %p)
v.f (scalar)                 op nativeload %v %OFFSET %ENCODING          (binload's encoding word)
v.f (pointer)                op nativeloadptr %v %OFFSET %WIDTH
v.f (nested layout)          op cptroffset %v %OFFSET                    (no memory read)
v.a.b.c (a chain)            one nativeload at the absolute offset       (ViewBase folds the nested offsets)
binary::load(v)              a nativeload / nativeloadptr per leaf, a structnew per LayoutStruct
```

Each op is a runtime helper call, as `binload` is: one unaligned load of the
field's width at address + offset, decoded by the encoding `binload` uses
(the shared `ops::bin_decode`), boxed (a BigInt only for a u64 above
i64::MAX); a pointer load materialized exactly like a C call's pointer
result. Nothing reads the record as a whole, copies it into a Bytes or walks
the layout at run time.

**Tcl backends.** No native memory: `binary::native::view` is
`NativeViewNull` for a null pointer and the run-time refusal `NATIVE-ONLY`
for any other (core/binary.tcl); a view can therefore never exist there, and
`binary#view_field` / `binary#load` refuse too. The Tcl compiler compiles
them as generic calls.

**The test fixture.** `core::cabi::installTestFixture` registers
`ffi_fixture::memory[T](data)`: natively the address of a fresh, never-freed,
64-byte aligned native copy of the bytes (`op cptrfixturememory`), on the Tcl
backends a fresh unreadable address. Only a test process can name it.

## 10. HIR, interchange, cache, isolation

No new registry: pointer fields live in the layout registry, which the HIR's
`declarations` already capture and `hir::activate` reinstalls, and every
field read carries its offset and encoding in the HIR (its descriptor entry
constant). HIR text prints a pointer field with its canonical type and reads
it back after the structs its pointee may name (`nv-hir-text-roundtrip`:
format, read, format is identical and the read HIR runs);
`hir/interchange.tcl` carries the HIR dict, so `.hirx` text read in a fresh
process after another compilation declaring a same-named layout reads its
own fields (`nv-interchange`); two compilations of a same-named layout with
swapped offsets keep their own reads (`nv-isolation`); the front-end cache
stores and reads back a native-view program (`nv-cache`). The pointer width
comes from the target the program's `ffi::c` scalars were declared for,
which is already in the cache key and the HIR's declarations.

## 11. Targets

The pointer width is read from core/cabi.tcl's target table through the
compilation's target (`hir::cabi::CompilationTarget`), never assumed: 8 bytes
on linux-x86_64, linux-aarch64, macos-*, windows-* (`nv-pointer-width-is-the-
targets`). A layout's offsets are its own (explicit), so nothing else is
target-dependent; byte order is the layout's (little-endian) and every
supported target's. The native ops are architecture-neutral Rust (unaligned
`copy_nonoverlapping`), so every host runs them alike. CI runs
native-view.test natively on Linux AArch64 (`tests-arm64.yml`) and on
macOS arm64 (Tier B), both green. On macOS its JIT tests run, while the
allocation counts, GC stress, the executable and the C oracle skip by
their capability constraints, exactly as every other file's do there.

## 12. Performance

`bench/native-view.tcl -runs 5 -n 200000` (4-core container, 2026-10-18,
idle; two runs, both shown where they differ): programs that repeat one
operation 200,000 times in a collecting loop, the time per operation over
the loop's baseline (about 40-50 ns an iteration: the collecting loop
itself), natively. The record is 32 bytes: a u8, a nested `Outer` (u32, a
nested `Inner`, u8), a u32 and a pointer.

| operation | Cranelift `-specialize 0` | Cranelift |
|---|---:|---:|
| view: one scalar field (`v.word`) | 12-17 ns | 13-16 ns |
| view: eight scalar fields summed (8 loads) | 95-98 ns | 86-91 ns |
| view: a field two layouts deep (`v.outer.inner.x`, one load) | 4-34 ns | 20-27 ns |
| view: a pointer field and its null test | 4-7 ns | 7-9 ns |
| view: make a view (`binary::native::view`: a null test) | about 0 | about 0-7 ns |
| view: `binary::load` of the whole record (4 fields, 2 nested layouts: 3 structs) | 335-375 ns | 343-391 ns |
| bytes: `binary::parse` of the same record, then one scalar | 263-282 ns | 254-268 ns |
| bytes: one scalar of a `LayoutStruct` already imprinted | about 0 | about 0 |
| bytes: eight scalars of a `LayoutStruct` already imprinted | about 0 | about 0-3 ns |

Heap allocations per operation (Cranelift's counters): every field read,
nested read, pointer read and view construction **0**; `binary::load` 3 (its
`LayoutStruct` and the two nested ones); `binary::parse`-then-read 2 (the
nested structs: a parse result read at once is held as fields, its nested
`LayoutStruct`s are not). No byte storage is ever made by a view.

* **A field read is about 11 ns** (eight summed: 86-98 ns): one runtime
  helper call -- the unaligned load, the decode, the boxing -- exactly the
  cost `binload` has per field (BINARY-LAYOUT.md item 51). It is a fixed
  cost per read, never per record: no copy, no allocation, no layout walk.
  The single-read rows are within the loop's noise; the eight-read row is
  the measurement.
* **Reads of an imprinted struct cost nothing here**: its fields are values
  in registers, hoisted out of the loop, while every view read is a load of
  memory that may change (it is a call, never hoisted or merged). A program
  that reads a record many times and does not need its live contents can
  `binary::load` it once (one record's cost, 335-391 ns) and read the
  struct.
* **Making a view is free** beyond its null test; a nested view is an
  address computation, and a chain of nested views folds to one load at the
  absolute offset (no `cptroffset` at all).
* **Surprising fixed overhead**: none beyond the helper call. The deferred
  optimization is the one BINARY-LAYOUT.md item 56 already names for
  `binload`: an inline load (address word shifted, plus the constant
  offset, a load of the field's width with its extension, the small-Int tag
  or the BigInt helper for a u64 above i64::MAX) -- which needs the offset
  and encoding as NIR immediates rather than registers.

## 13. Tests, the fixtures, fuzzing, mutants

**`tests/native-view.test`** (39 tests, the authoritative suite; about 20 s): the
pointer field declaration and rules, the target width, native-only layouts
and their affine struct view; the NativeView type rules, distinctness, not a
pointer, the operands, the untyped receiver, the declared null error,
pointer ownership; reads from fixture memory -- every encoding's extremes
and zero (u64 BigInts), nested and packed layouts, padding, pointer fields
(exact data pointers, read through a view of their own; function pointers;
null), the byte-backed asymmetry, `binary::load` of a native-only layout;
the Tcl backends, views as values, no equality; NIR shape, allocations; HIR
text, interchange, isolation, cache; directness; the read-only surface; no
new dependency; a standalone executable; GC stress; the unchecked (`-strict 0`) replays; and the C oracle.

**The synthetic fixtures.**

* `ffi_fixture::memory[T](bytes)`: native memory with contents the test
  states byte by byte. The expected values are written out by hand from the
  records' byte specifications (`nvRecord`: the test's own little-endian
  model), never computed by Botlish. A record whose pointer field holds the
  address of another fixture record is assembled at run time from the
  fixture's `address_of` (`nvLinkedProgram`).
* `tests/cffi/nview-fixture.c`, the **C oracle**: a C struct whose every
  offset, size and alignment the C compiler pins with static assertions
  (padding and tail padding included), two records C initializes with each
  width's extremes, a C `long`, a nested struct, a null pointer, a pointer to
  a static point record and a function pointer, padding filled with 0xA5.
  The test views the address C returns (`nv-c-oracle-*`): every field is
  what C stored; the bytes C copies into a `MutableBytes` imprint the same
  fields through the record's bits twin; the pointer and function pointer
  read through the view are exactly C's (C compares them); the point record
  reads through a view of the recovered pointer.

**Fuzzing** (`audit/native-view/tools/fuzz.tcl`). Each program is a chain of random layouts (one to six scalars of
every width and signedness at random gapped offsets, random alignment, a
layout nested by value two or three levels deep, and in the outermost zero
to three pointer fields -- data and function pointers, aligned or not),
values biased to each encoding's extremes and zero, random padding bytes,
each pointer field null or not, a non-null data pointer the run-time address
of a fixture record. The fuzzer assembles the record's bytes itself and
checks every scalar leaf read through the view, the nested views passed to
a function, every pointer field (null exactly when it wrote zeros, else the
exact address; a data pointer read through a view of its own), the byte
backing of the same bytes (the layout's parse, or its bits twin's, whose
pointer words equal the pointers' address bits) and `binary::load`. Seeds 1,
17, 41 and 99 at 40 programs each, seed 5 at 20 under
`BOTLISH_NATIVE_GC_STRESS=1`, seed 7 at 20 with the Tcl backends too (each
must refuse with NATIVE-ONLY): **no disagreement**. Running it first found
nothing in the view code; it did find an unrelated pre-existing front-end
limitation (section 15).

**Mutants** (`audit/native-view/tools/mutate.tcl`). `mutants.txt` holds 29 deliberate
bugs, each applied alone to a private copy of the tree (the 7 native ones
rebuilding its native backend), with three detectors: the Tcl suite
(`tests/native-view.test`, the C oracle included), the fuzzer (20 programs,
seed 7) and, for native mutants, the Rust unit tests (`--lib nview`). **All
29 are killed** (2026-10-18):

| defect (the brief's list first) | mutants | killed by |
|---|---|---|
| field offset ignored / read from offset zero | `offset-ignored-lowering`, `offset-zero-runtime` | tests, fuzzer (20/20), Rust |
| signed load treated as unsigned | `signed-as-unsigned-lowering`, `-runtime` | tests, fuzzer (14/20), Rust |
| width widened / narrowed | `width-widened-lowering`, `width-narrowed-runtime`, `pointer-width-hardcoded` | tests, fuzzer, Rust |
| nested base address wrong | `nested-base-dropped-fold`, `-load`, `-runtime` | tests, fuzzer (9/20), Rust |
| layout size ignored | `pointer-bounds-ignored` | tests (the declaration rules) |
| byte-backed pointer field materialized | `bytes-make-pointers`, `nested-pointer-not-native-only` | tests |
| native pointer field rejected or retagged | `pointer-retagged`, `pointer-rejected`, `pointer-as-int`, `pointer-type-unresolved` | tests, fuzzer, Rust |
| null pointer mishandled | `null-check-inverted-native`, `null-check-missing-tcl`, `null-pointer-field-mishandled` | tests, fuzzer, Rust |
| a view copies through Bytes | `copy-per-read` (a byte storage per read) | tests (NIR, allocations) |
| directness bypassed | `view-not-direct` | tests, fuzzer (its programs' marker turns stale) |
| the type: views structural, a view taken as a pointer, an untyped receiver accepted, the field type lost to specialization, pointer reads exempt from ownership | `views-structural`, `view-is-a-pointer`, `untyped-receiver-accepted`, `view-field-shape-lost`, `pointer-field-read-unowned` | tests (and the fuzzer for the shape) |
| elaboration and HIR text | `projections-not-elaborated`, `hir-text-pointer-field-unread` | tests (and the fuzzer) |

Per detector: the Tcl suite kills all 29, the fuzzer 19 (it generates valid
programs only, so the static-check mutants are invisible to it), the Rust
tests all 7 native mutants. None survived the first run.

## 14. Regression

Run in a 4-core container on 2026-10-18 (Linux x86-64), after the change:

* **`tclsh9.0 tests/local.tcl`** (every Tcl test file on interp and compile,
  every golden suite on all four backends through the front-end cache): 477
  entries, 1,513 s. All 94 golden suites passed on every backend. Eight
  entries failed, six tests in four files, and each failure was an
  inventory pinning the registry's contents, which this milestone grows:
  `ns-root-inventory` (the internal `binary#load`, `binary#view_field`),
  `ns-error-signatures` (the builtin `NativeViewNull`),
  `linux-syscall-native-registered` (`binary::native::view`,
  `binary::load`), `me-nomethod-native-default-off` (the three new
  `-nomethod` natives), `gf-code-name-complete` (98 diagnostic codes) and
  `ns-no-nested-stdlib`. The last one is a design rule, not a count:
  `binary::native` is two levels deep because directness is designated per
  namespace (DIRECT-MODULES.md), and the view constructor needs a direct
  namespace while `binary` itself must stay non-direct. The test now
  exempts it alongside the platform and C ABI namespaces, and
  STDLIB-NAMESPACES.md's table lists it. After the update
  stdlib-namespaces.test (74/74) and linux-syscall.test (37/37) pass whole
  locally, the two updated tests of method-eligible.test and
  golden-framework.test pass, and CI runs all four files green (below).
* **`cargo test --release --lib`**: 242 passed, the five `nview_` tests
  included.
* **Stub linker** (`BOTLISH_NATIVE_LINKER=stub`): `tests/aot-stub-linker.test`
  6/6, `tests/binary-layout.test` 51/51, `tests/native-view.test` 36 passed,
  3 skipped. The skipped three are the C-oracle tests (`nvCFixture`): a
  program that calls C links with the system linker, which the stub linker
  refuses (C-FFI.md).
* **GC stress** (`BOTLISH_NATIVE_GC_STRESS=1`): `tests/native-view.test`
  39/39; the fuzzer, seed 5 × 20 programs, 0 disagreements.
* **The neighbouring fuzzers**: binary-layout seeds 1, 17, 41 (× 40) and 5
  (× 20, GC stress), c-abi-types seeds 1, 17, 41, direct-modules seeds 1, 17,
  41: 0 disagreements.
* **Isolation, interchange, cache** (their default suites):
  `audit/compilation-isolation/tools/interleave.tcl`, 80 artifacts and
  outcomes, 0 differ; `audit/hir-interchange/tools/roundtrip.tcl -via
  interchange`, 90 compared, 0 differ; `-via cache`, 100, 0 differ.
  native-view.test's own `nv-isolation`, `nv-interchange`, `nv-cache` and
  `nv-hir-text-roundtrip` cover programs that make views.
* **The neighbouring mutation harnesses**, every mutant killed:
  compilation isolation 14/14, HIR interchange 27/27, direct modules 18/18,
  binary layout 39/39, C ABI types 26/26, affine values 29/29, coroutines
  52/52; native views 29/29 on the final tree (the
  Tcl suite kills all 29, the fuzzer 19, the Rust tests the 7 native ones).
  The affine fuzzer, seeds 1, 17, 41: 0 disagreements.
* **Mutants this milestone moved.** Five mutants of other areas no longer
  applied, because the code they mutate had moved:
  - binary-layout `width-rust`: binload's decoding is now `bin_decode`,
    shared with nativeload;
  - binary-layout `arbitrary-layout-struct-argument`: ResolveNativeView
    repeats the argument check;
  - c-abi-types `implicit-ptr-conversion` and enums `cross-enum-parameter`:
    the identity-only admission list gained `IsNativeView`;
  - traits `witness-leaks-into-applicability`: subtype's native-view case.

  Each text was updated to keep the same rule, and each mutant is killed
  again, by its harness's tests and its fuzzer. A static check of every
  audit's `mutants.txt` now applies all 715 mutants to the tree.
* **CI, first push** (`4f73faf`, before the inventory update): every failure
  was one of the six tests above. The Linux `tests (compile)` job (8,010
  tests, 6 failed), the stub-linked executables (1 failed), golden shard 3
  (its Tcl original `gf-code-name-complete`) and macOS Tier B (both shards)
  all failed only on them. The native Rust unit tests, the warning gate,
  golden shards 2 and 4, macOS Tier A and the ubuntu control passed.
* **CI after the update**, every workflow on the branch:
  - `tests` (`4563003`), every job green: interp, compile, cranelift and
    cranelift-generic coverage, the four golden shards beside their Tcl
    originals, the native Rust unit tests, the stub-linked executables and
    the warning gate.
  - `tests (linux arm64)` (`4563003`) on ubuntu-24.04-arm, green: interp,
    compile, cranelift and cranelift-generic coverage, the four golden
    shards, the native Rust unit tests (also under GC stress), and the
    whole Tcl suite under GC stress (`BOTLISH_NATIVE_GC_STRESS=1`, 72
    minutes).
  - `tests (macos arm64)` (`0802cc9`, after native-view.test's JIT tests
    moved from `nativeLinux` to `nativeBuilt`), green: Tier A and both
    Tier B shards. native-view.test runs in shard 1, on interp and compile,
    with the native backend built.
  - `static-decisions` (`4f73faf`; the later commits change no front-end
    file), every suite's batched decisions agree with the sequential
    reference.

## 15. What the existing layout architecture showed

* **It was ready.** One registry entry and one descriptor per layout, read by
  every backend only through a constant operand, took a third field kind and
  three operations without a second description of anything: the native
  lowering is LayoutDecode's shape over an address instead of a storage.
* **`hir::structs::IsAffine` ignored LayoutStruct identities.** Its registry
  lookup answered 0 for every `LayoutStruct[L]`, harmless while no layout
  field could be affine; a pointer field made it wrong, and it now asks the
  shared field accessor.
* **Layouts register before structs.** Necessary (a struct field may be a
  `LayoutStruct`), but a pointee is a struct: pointer types resolve in a
  second step, the width first.
* **HIR text's layout fields were one token.** A function pointer's type has
  spaces; the reader now accepts a pointer field's canonical type text.
* **Elaborated calls are re-inferred by specialization.** The internal calls
  `hir::layouts::Elaborate` writes are typed once, but specialization's
  region inference types them again from the native's registration: a view's
  field read needs a result shape (`{view-field 0 1}`), or a specialized
  function sees `any` and its next view refuses it -- found by the first
  `cranelift` run, invisible on `cranelift-generic`.
* **The strict-0 replays of the binary operations** (`BINARY-OPERAND`) were
  unknown to the native runtime's kind table and surfaced as NATIVE BUG.
* **Unrelated, found by the fuzzer:** `fn f(a: I16) -> List[int]: [a]` is
  rejected ("function result does not prove declared type List[int]") on
  the commit before this work too; a List of one integer domain does not
  prove `List[int]`. The tests and the fuzzer declare `List[any]` there.

## 16. Pressure on the write milestone

What the read-only implementation exposed that native writes, native
records and `MutableBytes` foreign writes will have to decide:

1. **Pointer encoding into bytes.** `binary::emit` of a native-only layout is
   rejected today. Writing a pointer's bits into a `MutableBytes` is not
   forging (the pointer exists), but it creates bytes that *look* like a
   pointer no one may read back as one (`parse` stays rejected): decide
   whether such bytes are ever re-materializable (only through native memory
   they are copied into?) and whether emission should exist at all, or only
   native stores.
2. **Write authority.** Reading is a direct edge at the view's construction;
   a writable view is more authority. One namespace (`binary::native`) with
   a read and a write constructor, or a separate direct namespace for
   writes; does a read-only view upgrade, or is a writable one made from a
   pointer separately?
3. **Affinity of a writable view.** A read-only view is unrestricted (copies
   confer nothing). A writable one aliases mutable memory: copies would be
   aliasing writers. Probably affine, with an explicit `clone` -- which a
   read-only view does not need and should not gain.
4. **Subviews of writable views** split one record into writable pieces;
   aliasing between a parent and its subviews needs a rule (borrow-like, or
   accepted as raw aliasing of a direct module).
5. **Storing pointers.** A pointer stored into native memory escapes (C may
   keep it): the store is a retaining operation in the C-FFI sense, a direct
   edge, and the stored pointer's ownership (moved? observed?) is the
   store's contract.
6. **Native records.** Allocating a layout's worth of native memory (for a
   Win32 struct a caller fills) needs an owner, a lifetime and a free: the
   first native object with Botlish-managed lifetime, the thing this
   milestone avoided. Alignment then becomes a requirement (`align` finally
   consumed), and initialization (zeroed? every field?) a rule.
7. **`MutableBytes` foreign writes through a layout** (fill a record in byte
   storage, expose it for one call) are the borrow machinery plus emission:
   they need item 1's answer for pointer fields.
8. **Bitfields and unions** will be written too: a bit-slice store is a
   read-modify-write of its storage unit, and an overlay store changes every
   alternative's reading -- both need the representation milestone before
   the write one can say what a store means.
9. **`ffi::c::Bool` fields** (SDL3 has them): a native read of a byte that is
   neither 0 nor 1 must be the `NATIVE BOOL` failure a C result has; a write
   is a byte.
10. **Volatile / concurrent memory.** A view reads once per projection, in
    program order, with no fences; device memory and shared memory need a
    stated model before writes exist.
11. **The Tcl backends** refuse views; writes there would be refused the same
    way, but a write that must be observable through a later byte copy (a
    `MutableBytes` written by C) is already modelled by the borrow fixture --
    the write milestone should keep using real native memory for evidence.

## 17. Not here

No native-memory write, setter, assignment through a field, writable or
mutable view, `NativeEdit`, native allocation or native record
construction; no `extern c struct`, C layout rule, bitfield, union, array,
dynamic extent, floating point or `Bool` field; no aggregate C ABI (passing
or returning a record by value), callback or pointer arithmetic (no `ptr +
n`, `Ptr <-> Int`, dereference: offsets are the layout's, inside lowering);
no change to C bindgen, C header probing or the generated bindings; no
representation guarantee for any ordinary Botlish value; no new runtime or
link dependency for a program that does not use views (`nv-no-new-dependency`:
a view program links nothing, a layout program lowers to the same ops).

## 18. What to run when changing this

If you change pointer fields or native-only layouts (hir/layouts.tcl,
`ResolvePointers`, hir/sourcetypes.tcl's call, hir/read.tcl's layout line),
the NativeView type (the `nview` cases of hir/types.tcl, hir/resolve.tcl,
hir/structs.tcl's `ProjectionProblem`, hir/affine.tcl's `AffineProjection`,
hir/cabi.tcl's view check, hir/range.tcl's admission), the view operations'
registrations or roles (core/binary.tcl, core/native.tcl), the elaboration
or `verifyInstance`, native lowering (`LayoutCall`'s view/load/field,
`NativeField`, `NativeDecode`, `ViewBase`) or the runtime
(native/src/runtime/nview.rs, the ops in nir.rs, ops.rs, clif.rs), run
`tests/native-view.test` (its C oracle needs `cc`), `tests/binary-layout.test`,
`tests/c-abi-types.test`, `tests/direct-modules.test`,
`audit/native-view/tools/fuzz.tcl` (several seeds, once with `-gc-stress 1`),
`audit/native-view/tools/mutate.tcl` (every mutant in its `mutants.txt` must
still apply and be killed: update a mutant's text when you change the code
it mutates, keeping it a mutant of the same rule) and `cargo test --release
--manifest-path native/Cargo.toml --lib nview`; a change to what a layout
registers also needs the isolation and interchange audits (AGENTS.md) and
`tests/static-compile.test`. `bench/native-view.tcl` regenerates the
performance report.

## 19. Files

| file | what |
|---|---|
| `hir/layouts.tcl` | pointer fields, `ResolvePointers`, `NativeOnly`/`PointerField`, `ViewFieldType`, `ResolveNativeView`, the operand checks, `Elaborate`'s view reads, `verifyInstance` |
| `hir/types.tcl` | `{nview L}`: resolution, subtyping, joins, projection, result shapes, poison |
| `hir/resolve.tcl`, `hir/structs.tcl`, `hir/affine.tcl`, `hir/cabi.tcl`, `hir/range.tcl`, `hir/semantic.tcl`, `hir/read.tcl`, `hir/sourcetypes.tcl` | the type's resolution, projection check, ownership, not-a-pointer, admission, instance check, HIR text |
| `hir/static.tcl`, `lib/compiler.bot`, `lib/test.bot` | `LAYOUT-NATIVE-ONLY` |
| `core/binary.tcl`, `core/native.tcl`, `core/cabi.tcl` | the operations, the roles and shapes, the memory fixture |
| `compiler/compiler.tcl` | the Tcl compiler's generic call of the view operations |
| `native/lower.tcl` | `LayoutCall` (view, load, field), `NativeField`, `NativeDecode`, `ViewBase` |
| `native/src/runtime/nview.rs`, `nir.rs`, `ops.rs`, `codegen/clif.rs`, `runtime/error.rs` | `nativeload`, `nativeloadptr`, `cptroffset`, `cptrfixturememory`; the replay kinds |
| `tests/native-view.test`, `tests/cffi/nview-fixture.c` | the suite and the C oracle |
| `audit/native-view/tools/` | the fuzzer and the mutants |
| `bench/native-view.tcl` | the performance report |
