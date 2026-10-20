# Unions in binary layouts

> Arrays repeat representation. Unions overlap representation.

A binary layout may now declare a union: several explicit interpretations
of the same bytes.

    union layout WORD:
        size 4
        align 4
        alternative whole: binary::U32
        alternative halves: HALVES
        alternative bytes: array 4 of binary::U8

    layout OVERLAPPED:
        size 32
        align 8
        field Internal: ffi::c::ULongLong at 0
        field InternalHigh: ffi::c::ULongLong at 8
        field member3: OVERLAPPED_member3 at 16
        field hEvent: ffi::c::Ptr[ffi::c::Void] at 24

A union is a named representation of an explicit size and alignment whose
alternatives all begin at its first byte. It nests in records, in arrays and
in other unions; a record holding one stays an ordinary layout, read and
written a field or an alternative at a time. It is not a sum type: there is
no tag, no case and no active alternative, and choosing an alternative is
interpretation, never conversion. Overlap anywhere else is still an error.

The C binding generator now emits C unions as union layouts and anonymous
members (an anonymous union, an anonymous struct inside a union) as
synthetic layouts of their own, placed by clang's record layouts and checked
by the compilers. Win32's `OVERLAPPED`, `LARGE_INTEGER` and `ULARGE_INTEGER`,
BoringSSL's hash, HMAC and AEAD contexts, `GENERAL_NAME` and `ASN1_TYPE`,
and SDL3's haptic effects and gamepad bindings are layouts now. `Tcl_Obj`
and `SDL_Event` are still blocked, by `double`, `float` and C `_Bool`
alternatives alone.

Contents:

1. Result
2. The laws
3. Syntax and validation
4. The representation model
5. Why not a sum type
6. The copied-value decision
7. Native access
8. Writes
9. Pointer authority
10. Arrays and unions
11. HIR, isolation, interchange and lowering
12. Performance
13. The C binding generator
14. Forecast against actual
15. Sentinel records
16. API impact
17. Verification
18. Fuzzing
19. Mutation testing
20. The remaining pressure
21. Regression and CI
22. What this does not solve
23. What to run when changing this

## 1. Result

* **Language.** `union layout U:` with `size`, `align` and `alternative
  NAME: TYPE` lines; an alternative is any representation (a scalar, a C
  scalar, a C pointer, a nested layout, a fixed array, another union) no
  wider than the union. A union is held by value by a record field, an
  array element (`array N of U`) or another union's alternative. Overlap is
  declared by a union and only by one: an ordinary layout's overlapping
  fields are still `LAYOUT-FIELD-OVERLAP`.
* **No copied value.** A union's alternatives are not independent fields,
  so there is no `LayoutStruct` of a union or of anything holding one by
  value. `binary::parse`, `binary::emit`, `binary::load` and whole-array
  writes of such a representation are `LAYOUT-UNION` (one new diagnostic
  kind, `compiler::DiagnosticCode::LayoutUnion`). Bytes are read one
  alternative at a time through a static designator,
  `binary::read(data, L.u.alt)` (one new operation), and written by
  `binary::write`/`binary::write_foreign` as before.
* **Live unions.** A field holding a union read through a native view or
  edit is the live union `NativeView[U]` / `NativeEdit[U]`; an alternative
  is read or stored at the union's address, by the code the same
  representation would have there directly: one load or store at a constant
  offset, nothing allocated, nothing read whole, nothing cached, the same
  for the first and the sixty-fourth alternative.
* **C binding generator.** No more `union` or `anonymous-overlay` blockers.
  Layouts emitted: Tcl 32 → 34, Tcl stubs 32 → 34, SDL3 81 → 85, BoringSSL
  71 → 118, Win32 813 → 996 (section 14 compares them with the forecast,
  which they meet exactly on its own counting).
* **Evidence.** A Tcl suite of 43 tests with a C oracle, a golden suite of
  53 tests on all four backends, a union fuzzer with its own byte model,
  24 language mutants and 16 generator mutants (every one killed by a test
  of behavior or a fuzzer), the bindgen fixture's unions on four targets, a
  runtime C oracle over every emitted layout of the real libraries, a
  second compiler for every target that has one, and a benchmark.

## 2. The laws

1. Arrays repeat representation. Unions overlap representation.
2. A union is several declared interpretations of the same bits, not several
   independent stored fields.
3. A binary union has no active member unless a higher-level protocol
   supplies one.
4. Selecting an alternative is interpretation, not conversion.
5. Ordinary field overlap remains an error; overlap must be explicit.
6. Native authority may reinterpret raw native memory. Arbitrary Botlish
   bytes still may not conjure foreign authority.
7. The C compiler supplies C union size, alignment and offsets. Botlish
   records them; it does not implement C union-layout rules.
8. The copied-value model does not lie to preserve API symmetry.
9. The backing controls authority: one declaration serves byte storage and
   native memory, and the backing -- never the declaration's syntax --
   decides what the bits may mean (byte storage never yields a pointer;
   native memory read through a view may).

The representation algebra is now five constructions, all one layout
machinery: a scalar, a pointer, a nested record, fixed repetition (an
array) and explicit overlap (a union).

## 3. Syntax and validation

    union layout NAME:
        size N
        align A
        alternative ALT: TYPE
        ...

`TYPE` is anything a layout field may be: a scalar encoding
(`binary::U32`), a C scalar (`ffi::c::Int`), a C pointer
(`ffi::c::Ptr[T]`, `ffi::c::FnPtr[...]`), a layout or union declared in the
program, a fixed array of any of them (`array 4 of WORD`). An alternative
has no `at`: every alternative is at offset 0, so the declaration states no
offset that could disagree. `size` and `align` are explicit, as for every
layout, and never computed; a union may be larger than every alternative
(tail padding: C makes a union of a 5-byte array and an `int` 8 bytes on
every target here, and Botlish only records the compiler's answer).

Errors, each a declaration diagnostic with its own location:

| declaration | diagnostic |
|---|---|
| a union with no alternative | `union layout "U" declares no alternative: a union layout needs at least one "alternative NAME: TYPE" line` |
| an alternative wider than the union | `alternative "x" of union layout "U" is W bytes wide (bytes 0..W-1), more than the union's size S: every alternative lies inside the union` |
| two alternatives of one name | the duplicate-field diagnostic, worded for an alternative |
| `alternative x: T at 4` | `a union alternative states no offset: every alternative of union layout "U" starts at the union's first byte` |
| a `field` line in a union | `a union layout has alternatives, not fields: "alternative NAME: TYPE" ...` |
| an `alternative` line in a layout | `a layout has fields, not alternatives: ... (alternatives, which share bytes, belong to a union layout ...; the fields of a layout never share a byte)` |
| a union holding itself by value, directly or through records, arrays or other unions | `LAYOUT-CYCLE` (a pointer to itself is fine) |
| an ordinary layout with overlapping fields | `LAYOUT-FIELD-OVERLAP`, whose message now names the union as the way to declare overlap |

A union is a declaration like a layout: no type, no value, not callable,
no namespace (`LAYOUT-NOT-A-VALUE`, `UNKNOWN-NAMESPACE`); `U.alt` is a
static designator.

Designators go through unions with no new syntax: `U.a`, `Outer.u.a`,
`Outer.u.record.x`, `Outer.arr[2].u.a`, `Outer.u.array[3]`,
`Outer.u.array[2].record.x`. Each resolves at compile time to a constant --
the absolute offset of the leaf and its representation -- and a designator
that ends at a union is `LAYOUT-OPERAND` ("a designator names one of its
alternatives, never the union itself"). A wrong alternative name is
`UNKNOWN-FIELD` listing the union's alternatives.

## 4. The representation model

A union is a registry entry of `hir/layouts.tcl` like a layout, marked
`union 1`, its alternatives its fields, every one at offset 0. Nothing else
in the registry changed shape:

* A field holding a union by value is the representation
  `{kind union layout U width SIZE}`; a term (an array's element) is
  `{union U}`. The width of a union is its declared size, so an array of
  unions strides the union's size -- tail padding included -- never an
  alternative's width.
* Its descriptor, the constant every backend reads instead of the registry,
  is `{LayoutUnion[U] SIZE ALIGN {ALTERNATIVE ...}}`, every alternative a
  field at offset 0, held in a field's entry as `{NAME OFFSET union
  DESCRIPTOR}`. `LayoutUnion[U]` names no type; there is no
  `LayoutStruct[U]` (asking for one is `LAYOUT-UNION`: "LayoutStruct[U]
  does not exist").
* The live types are `NativeView[U]` and `NativeEdit[U]`, the existing
  nominal types over a union's identity.
* A union's consumer type is `any`: the type of a copy no checked program
  makes.

## 5. Why not a sum type

A C union -- and binary data generally -- has no record of which
interpretation is meaningful: the bytes of `OVERLAPPED`'s union are
`Offset`/`OffsetHigh` for a file read and `Pointer` for some device
requests, decided by a protocol outside the record; an `SDL_Event`'s
alternative is decided by its `type` field, which is a member of every
alternative. Modelling a union as a sum would invent a tag the bytes do not
have, make every read a case analysis on that invented tag, and make the
representation lie about what writing an alternative does (it does not
change "the case": it changes bytes, some of which other alternatives
share). So a union here is representation only:

* no tag, discriminant, case, active member or "last written" state, in the
  type system or at run time;
* reading any alternative is always allowed (it reads bytes); reading one
  after writing another is interpretation of the same bytes, never an
  error;
* a protocol that chooses an alternative -- `SDL_Event.type`, a request
  code -- is the program's (or a future wrapper generator's), written as
  ordinary code: read the tag field, branch, read the alternative.

## 6. The copied-value decision

A union cannot honestly become an ordinary `LayoutStruct`: a union of a
`U32` and two `U16`s holds one 4-byte value, not three values. The families
considered:

* **A. An opaque copied union** -- a value preserving the union's bytes,
  with interpretation operations. It would be a new value kind (a byte
  blob typed by its union), a new type constructor, new operations to read
  an alternative out of it, and a nested-copy story (a record holding a
  union would copy as a struct whose one field is the blob). Every one of
  those already exists as byte storage plus a designator.
* **B. No whole copied value** -- `binary::parse`, `binary::emit`,
  `binary::load` and whole-array writes of anything holding a union are
  refused, while every alternative remains readable and writable one at a
  time. **This landed.**
* **C. A struct of every alternative** -- what `LayoutStruct` would give
  for free, and exactly the lie the laws forbid: three independent values
  that are one, and an emit that would have to choose which to write.

B is the smallest and the most truthful: it adds no value kind and no
type, keeps every existing copy honest (a `LayoutStruct` still means
"independent fields"), and leaves A open as a later addition if a program
needs to carry a union's bytes around as one value (it can today: as the
byte storage the record already is). The one addition B needed is
`binary::read(data, L.path)`, the byte-side twin of a native view's field
read: the representation one static designator names, imprinted from
exactly L's bytes. It is general -- it reads an ordinary field too
(`binary::read(b, PLAIN.after)`), and an alternative of a record
alternative is a `LayoutStruct` of that record -- and it refuses what has
no copy: a designator ending in a union (one cannot), one holding a union
by value (`LAYOUT-UNION`), and a pointer path (`LAYOUT-NATIVE-ONLY`).

What B refuses, each with one precise diagnostic and a poison result (no
cascade):

| operation | diagnostic |
|---|---|
| `LayoutStruct[U]` | LAYOUT-UNION: LayoutStruct[U] does not exist |
| `binary::parse(U, d)`, `binary::emit` of a union | LAYOUT-UNION: U is a union layout ... has no copied value |
| `binary::parse(R, d)` / `binary::emit` of a record holding a union | LAYOUT-UNION: R holds the union layout U by value at R.u ... |
| `binary::load(v)` of a live union, of a record holding one, of a live array of unions | LAYOUT-UNION: binary::load cannot copy ... |
| `binary::read(d, R.us)` of an array of unions | LAYOUT-UNION |
| `binary::write(d, R.us, list)` / `binary::store(e, R.us, list)` | LAYOUT-UNION: cannot write ... whole |
| `binary::store_element(e.us, k, v)` of a union element | LAYOUT-OPERAND (an element of an array of unions is written through its alternatives: `binary::element(e.us, k)`, then a store) |

A program compiled unchecked (`-strict 0`) replays the same diagnostic
when the call runs, before anything is read or written: natively, and on
the Tcl backends by the reference implementation, which refuses union words
in a descriptor.

## 7. Native access

A field holding a union read through `binary::native::view` is the live
union `NativeView[U]` -- the union's address, nothing read -- and its
alternative is read like any field: `v.u.whole` is one load,
`v.u.halves` is the live record `NativeView[HALVES]`, `v.u.bytes` the
live array `NativeView[array 4 of binary::U8]`, `v.u.p` the pointer the
memory holds. Natively (`lu-native-nir`):

* an alternative's field through a union inside a record is one
  `nativeload` at its absolute offset (20: the union at 16, the field at
  4) -- `ViewBase` folds the union's offset into the constant, so a union
  adds no instruction;
* reading the last of 64 alternatives is the same one load as reading the
  first: nothing is searched, allocated or read whole;
* an alternative of an element of a two-dimensional array of unions is the
  bounds check, the index times the union's size, one `cptroffset` and one
  load;
* switching interpretations -- read A, write B through another edit of
  the same memory, read A again -- reloads A: no value is cached across a
  store (`lu-native-interpretation-switching`), and what one alternative
  wrote is what every other reads next, by its own encoding; C's typed
  stores of one interpretation read through another are the C oracle's
  `lu-c-oracle-punning`.

Nothing allocates: 1,000 reads or stores of an alternative cost what a loop
doing nothing does (`lu-native-allocations`, and the benchmark's allocation
table, section 12). A record holding a union is accessed field by field; one
union field never turns its record into an opaque blob.

The Tcl backends have no native memory: a view of a non-null pointer is
`NATIVE-ONLY` there, for a union as for any layout (`lu-tcl-backends`).

## 8. Writes

`binary::store(e, L.u.alt, value)` through `NativeEdit[L]` writes exactly
the alternative's bytes: a 2-byte alternative of a 16-byte union changes 2
bytes, and the union's other 14 bytes and the bytes around it keep
whatever they held -- never zeroed or normalized
(`lu-native-stores-touch-only-the-alternative`, checked against sentinel
bytes and against the C oracle's own image). The byte side is the same:
`binary::write(d, L.u.alt, v)` returns new storage differing from `d` in
the alternative's bytes only, and writes chained through several
alternatives overlap exactly as the bytes do (`lu-write-touches-only-the-alternative`).
A record is built in `abi::bytes::MutableBytes` field by field and
alternative by alternative, its pointer alternatives by
`binary::write_foreign` (`lu-caller-constructed-record`, which C reads back
with typed member reads).

## 9. Pointer authority

Recursive through every alternative, as through every field and element:

* bytes never become a pointer through a union: `binary::read` of a
  pointer alternative and `binary::parse` of a layout holding a
  pointer-bearing union are `LAYOUT-NATIVE-ONLY` (the latter also
  `LAYOUT-UNION`: there is no copy to make at all);
* a scalar alternative of the same bytes reads a pointer's bits as an
  integer -- raw representation, which native read authority may observe;
* native write authority may store scalar bits that a pointer alternative
  then reads (raw native memory is raw: making a `NativeEdit` is a direct
  operation for this reason, NATIVE-LAYOUT-WRITES.md), and a pointer
  alternative's read fails `NATIVE ADDRESS` when the bits are no address
  the C pointer word can hold;
* a pointer stored through an alternative (`binary::store`,
  `binary::write_foreign`) is observed, never moved: the program's binding
  stays usable (`lu-native-pointer-alternatives`);
* an ordinary `binary::write` of a scalar alternative of a pointer-bearing
  union is allowed -- it encodes no pointer -- while one of the pointer
  alternative is `LAYOUT-NATIVE-ONLY` (`binary::write_foreign` is the way).

## 10. Arrays and unions

They compose with no rule of their own (`lu-native-arrays-of-unions`,
`lu-native-unions-of-arrays`, `lu-designators`):

* `array N of U` strides U's declared size (an array of 12-byte unions
  aligned to 16 strides 12: the declared size, not a C rule);
* a union's alternative may be an array (`array 16 of binary::U8`,
  `array 4 of binary::U32`): selecting it gives the live array;
* multidimensional arrays of unions, arrays of records holding unions, and
  records holding arrays of unions are ordinary;
* a whole-array read or write of an array of unions has no copy:
  `LAYOUT-UNION`. An element's alternative is read and stored one at a
  time (`binary::element(v.us, k).whole`, `binary::store(e, L.us[2].whole,
  v)`).

## 11. HIR, isolation, interchange and lowering

* **HIR text** prints a union as `union layout U ns NS size N align A
  alternatives A1: T1, ...` and reads it back as the same registry entry
  (`lu-hir-text-roundtrip`); a union's alternatives keep their full
  representation (an array or a union alternative is not printed by its
  consumer type).
* **Compilation isolation**: the registry is a declaration registry, so a
  later compilation declaring a record of a union's name (or a union of a
  record's) never changes an earlier HIR's lowering (`lu-isolation`, and
  `audit/compilation-isolation/tools/interleave.tcl` now includes the
  golden suite).
* **HIR interchange and the front-end cache** carry unions like layouts
  (`lu-interchange`, `lu-interchange-fresh-process`, `lu-cache`;
  `audit/hir-interchange/tools/roundtrip.tcl` includes the golden suite).
* **Native lowering** (`native/lower.tcl`): `ViewBase` folds a union's
  offset like a nested layout's; a union held by value is a `cptroffset`
  window; `binary::read` is `LayoutCall`'s `read` case -- the designator
  constant, the length check, one `ReprRead` of the leaf. No NIR
  instruction, runtime operation or value knows unions.
* **The Tcl compiler** compiles `binary::read` and writes through the
  reference implementation (`core/binary.tcl`), whose `DecodeRepr` and
  `EncodeRepr` refuse a union and whose `parse`/`emit` refuse a descriptor
  holding one.
* **Specialization and directness** are unchanged: a function over
  `NativeView[U]` is specialized like any (`lu-specialization`), and making
  a view of a union is the direct edge it always was (`lu-direct`).

## 12. Performance

`bench/layout-unions.tcl` (Cranelift, with and without specialization;
each operation beside the same operation on an ordinary record field at the
same offset and of the same width):

Time per operation over its baseline program, (program - baseline) / n,
n = 200,000, best of 5 in-process runs; the whole program per operation in
parentheses (Linux x86-64, 4-core container):

| operation | baseline | Cranelift (-specialize 0) | Cranelift |
|---|---|---:|---:|
| view: a U64 alternative of a union held at 8 (v.u.whole) | outer-base | 2.7 ns (40.8 ns) | 2.5 ns (47.6 ns) |
| view: the same U64 as an ordinary field at 8 (v.whole) | plain-base | 9.4 ns (46.8 ns) | 4.5 ns (51.7 ns) |
| view: a record alternative's field (v.u.parts.high) | outer-base | 22.0 ns (68.6 ns) | 20.1 ns (64.3 ns) |
| view: an array alternative's element, dynamic index (binary::element(v.u.words, k - 2)) | outer-base | 17.0 ns (54.5 ns) | 15.0 ns (54.7 ns) |
| view: a pointer alternative (q = v.u.p, ffi::c::null?(q)) | outer-base | -0.3 ns (39.4 ns) | 6.2 ns (45.2 ns) |
| view: three reads switching interpretations (whole, parts.low, whole) | outer-base | 26.0 ns (67.7 ns) | 33.4 ns (73.1 ns) |
| view: the first of 64 alternatives (v.a0, a U64) | many-base | 7.2 ns (48.0 ns) | 9.7 ns (45.9 ns) |
| view: the last of 64 alternatives (v.a63, a U64) | many-base | 5.1 ns (46.3 ns) | 5.3 ns (45.5 ns) |
| edit: a U64 alternative's store (OUTER.u.whole) | outer-base | 21.6 ns (62.5 ns) | 13.1 ns (47.2 ns) |
| edit: the same U64 as an ordinary field's store (PLAIN.whole) | plain-base | -10.8 ns (42.7 ns) | 6.1 ns (42.1 ns) |
| edit: a narrow alternative's store, 2 of the union's 8 bytes (OUTER.u.parts.high) | outer-base | 10.3 ns (49.4 ns) | -3.6 ns (48.7 ns) |
| view: an element of an array of unions, its alternative (binary::element(v.us, k).whole) | arru-base | 13.4 ns (49.9 ns) | 1.1 ns (40.8 ns) |
| view: an element of an array of records, the same field (binary::element(v.ps, k).whole) | arrp-base | 7.4 ns (47.6 ns) | -0.3 ns (40.2 ns) |
| bytes: binary::read through a union (OUTER.u.parts.high) | bytes-base | -0.3 ns (44.3 ns) | 17.2 ns (53.0 ns) |
| bytes: binary::read of an ordinary field (PLAIN.after) | bytes-base | 28.0 ns (63.6 ns) | 22.9 ns (62.8 ns) |
| bytes: binary::write through a union (OUTER.u.parts.high), a 24-byte record | bytes-base | 240.0 ns (279.1 ns) | 66.3 ns (105.3 ns) |
| bytes: binary::write of an ordinary field (PLAIN.after), a 24-byte record | bytes-base | 228.4 ns (271.4 ns) | 65.2 ns (102.8 ns) |

What it shows:

* **An alternative costs what the same field costs.** The U64 alternative
  of a union held at offset 8 and the same U64 as an ordinary field at 8
  are within the method's noise of each other (a few nanoseconds; the
  per-operation deltas vary by about ±15 ns between runs, which is why some
  are negative), on both backends; so are the stores, an element of an
  array of unions against an element of an array of records, and
  `binary::read`/`binary::write` through a union against an ordinary field.
* **Constant in the number of alternatives.** The first and the last of 64
  alternatives cost the same (both U64; the NIR is one load at the same
  offset, `lu-native-nir`). A first version of this row compared a U16
  first alternative with a U64 last one and showed a 30 ns difference; a
  direct measurement put it on the width, not the position: a U16
  alternative and a U16 ordinary field cost the same (10.8--11.3 ms and
  9.9--11.2 ms per 200,000 reads), as do a U64 alternative and a U64 field.
* **Switching interpretations** costs three reads (about three times one
  read), as it must: nothing is cached.
* **Nothing allocates.** Every view and edit program allocates exactly its
  baseline's 6 objects (the fixture's memory, the view, the loop's List);
  `binary::write` allocates its one new `MutableBytes` per write, through a
  union as for an ordinary field (1.0 per operation each).

The front end's compile time of one declaration of K members, read once
through a view (best of 5):

| K | union of K alternatives | record of K fields |
|---:|---:|---:|
| 4 | 100.9 ms | 87.9 ms |
| 64 | 111.9 ms | 120.4 ms |
| 512 | 310.1 ms | 398.4 ms |

A union's validation is linear in its alternatives and cheaper than a
record's (a union has no overlap check to make: overlap is what it
declares). The generator's scaling is in section 18.

## 13. The C binding generator

For every complete C union the generator now

1. probes `sizeof` and `_Alignof` (the layout probe's `rec:` entries, as
   for a struct);
2. probes every member's `offsetof` and `sizeof`;
3. confirms the overlap from the compiler: a member the compiler places
   anywhere but at the union's start blocks the union
   (`union-member-offset`, classified, never moved -- no real target does
   it, and `cb-layout-union-member-offset` shows the blocker with the
   probe's answer altered);
4. maps every member through the existing field mapping (scalars,
   pointers, arrays, nested records and unions);
5. emits one `union layout`, its members its alternatives in declaration
   order.

**Anonymous members.** C11 names an anonymous member's members as members
of the record that has it, and gives the anonymous member itself no name a
C expression could ask about. An anonymous struct inside a struct is still
promoted -- its members become the struct's own fields at their own
offsets, which is exact (they overlap nothing). Every other anonymous
member -- an anonymous union, an anonymous struct inside a union -- is a
*synthetic* record:

* named by its place: its container's layout name and its member's
  position, `OVERLAPPED_member3` (field `member3`), and down the nesting
  `bgf_deep_member3_member1_member3`; promoted anonymous structs prefix the
  slot (`bgf_deep.member2_member2`). The name depends on the source's
  structure only (stable under regeneration, independent of probe order),
  and collisions are resolved by the generator's existing rule (a C tag
  `struct bgf_overlapped_member3` keeps its name; the synthetic union
  becomes `bgf_overlapped_member3_union`);
* held by value by a generated field of its container, never flattened
  into overlapping fields of the container (the language has no aliases,
  and the brief forbade losing the structure);
* probed through its *owner* -- the first enclosing record with a C name --
  whose C members its members are: `offsetof(OVERLAPPED, OffsetHigh)`,
  `sizeof(((OVERLAPPED *)0)->OffsetHigh)`;
* sized and aligned by **clang's record layout** (`-fdump-record-layouts`,
  the toolchain adapter's new `recordLayouts`, one compilation for all the
  owners), the only compiler answer to "how large is this anonymous
  union": no C expression names its type. The record layout also gives its
  members' offsets within it, which must agree with `offsetof` through the
  owner less the anonymous member's own offset there (both are the
  compiler's; a disagreement is a blocker). A dump record is identified by
  its kind, file, line (the struct or union keyword, which may be a few
  lines above the brace the parser tags) and its members' names in order;
* not emitted when its owner is blocked (`layout-unheld`: representable,
  but no program reaches it and no C check could verify it).

Without clang (a gcc toolchain) an anonymous member would be blocked
(`anonymous-record`, with the reason), never guessed
(`cb-layout-anonymous-unprobed` shows it).

**The manifest** maps every promoted C name to its generated path:
`promoted` rows of `layouts.tsv`, e.g.

    promoted  struct _OVERLAPPED  -  member3.member1.Offset      -  16  4  -  Offset      ffi::c::ULong  via=union anon@minwinbase.h:22,struct anon@minwinbase.h:23
    promoted  struct _OVERLAPPED  -  member3.member1.OffsetHigh  -  20  4  -  OffsetHigh  ffi::c::ULong  ...
    promoted  struct _OVERLAPPED  -  member3.Pointer             -  16  8  -  Pointer     ffi::c::Ptr[ffi::c::Void]  ...

and a synthetic record's row carries its owner, its place
(`place=OVERLAPPED.member3`) and clang's location of it (`at=`).

**Blockers.** `union` and `anonymous-overlay` are gone. A union whose
alternative the layout language lacks is blocked by that alternative's
own reason -- `float`, `c-bool`, `bitfield`, `nested-layout-blocked` with
the chain -- and so is everything holding it (`cb-layout-union-blockers`:
a float alternative, a `_Bool` one, a bitfield record alternative, held by
a record, as an array element, as an anonymous member). An anonymous member
none of whose members has an `offsetof` (a union of bitfields only) is not
additionally `anonymous-record`: its bitfield is the root.

## 14. Forecast against actual

The previous milestone's pressure report (FIXED-LAYOUT-ARRAYS.md, section
12) forecast what unions would recover, counting records as it counted them
then: named and anonymous unions were records, anonymous structs inside
unions were promoted into them (no records of their own).

| binding | layouts before | forecast | actual, the forecast's counting | actual, all layouts |
|---|---:|---:|---:|---:|
| Tcl | 32 | 34 | 34 | 34 |
| Tcl stubs | 32 | 34 | 34 | 34 |
| SDL3 | 81 | 85 | 85 | 85 |
| BoringSSL | 71 | 117 | 117 | 118 |
| Win32 (windows-x86_64-gnu) | 813 | 988 | 985 emitted + 3 unheld = 988 | 996 |

The forecast holds exactly. The two differences from it are the model's,
both deliberate:

* **Synthetic structs are records now.** An anonymous struct inside a union
  was promoted (no record); it is a synthetic layout, so it counts. Win32
  has 51 of them: 11 emitted, 39 blocked (by bitfields: Win32's flag words
  are anonymous structs of bitfields inside unions with a `DWORD`), 1
  unheld; BoringSSL 1, emitted. Hence 996 and 118.
* **Unheld anonymous members are not emitted.** Three Win32 anonymous
  unions are representable but held by records a bitfield blocks: the
  forecast counted them (they lost their only blocker), the generator
  records them as `layout-unheld` instead of emitting layouts no program can
  reach.

The transition of every record of the previous manifests:

| binding | blocked → layout | blocked → blocked | blocked → unheld | layout → layout | new records |
|---|---:|---:|---:|---:|---|
| Tcl | 2 | 4 | 0 | 32 | 0 |
| SDL3 | 4 | 42 | 0 | 81 | 0 |
| BoringSSL | 46 | 5 | 0 | 71 | 1 (emitted) |
| Win32 | 172 | 132 | 3 | 813 | 51 (11 emitted, 39 blocked, 1 unheld) |

No layout of the previous bindings changed or disappeared: every `layout`
block of each previous `layouts.bot` is in the new one, field for field
(Tcl 32 of 34, SDL3 81 of 85, BoringSSL 71 of 118, Win32 813 of 996), and
`check PROFILE -target committed` regenerates every binding byte for
byte.

## 15. Sentinel records

**Win32** (MinGW-w64's GNU ABI, verified by clang and by
`x86_64-w64-mingw32-gcc`):

| record | status | size / align | notes |
|---|---|---|---|
| `LARGE_INTEGER` | union layout | 8 / 8 | alternatives `member1` (synthetic struct: `LowPart` at 0, `HighPart` at 4), `u` (the named struct), `QuadPart` |
| `ULARGE_INTEGER` | union layout | 8 / 8 | the same shape, unsigned |
| `OVERLAPPED` | layout | 32 / 8 | `member3: OVERLAPPED_member3 at 16`, a union of `member1` (synthetic struct `Offset` at 0, `OffsetHigh` at 4) and `Pointer`; `Offset` 16, `OffsetHigh` 20, `Pointer` 16 by MinGW's compiler |
| `WIN32_FIND_DATAW` | layout | 592 / 4 | unchanged (FIXED-LAYOUT-ARRAYS.md): no regression |
| `OVERLAPPED_ENTRY` | layout | 32 / 8 | unchanged |

**BoringSSL**: `SHA_CTX` (96 / 4, its anonymous union of the state words),
`SHA256_CTX`, `SHA512_CTX`, `MD5_CTX`, `GENERAL_NAME` (16 / 8, its union of
the name kinds), `ASN1_TYPE` (16 / 8), `EVP_MD_CTX` (232 / 8), `HMAC_CTX`
(704 / 8), `EVP_AEAD_CTX` (576 / 8, its state union), `EVP_CIPHER_CTX`,
`EVP_HPKE_CTX` -- all layouts. Five records stay blocked: `CBB`'s buffer
and child structures by their bitfields, the union holding them and `CBB`
itself through it (the bitfield their root, never the union), and
`RAND_METHOD` by a callback taking a `double`. A layout of
a crypto context is representation availability for interoperability and
inspection; it is no endorsement of manipulating crypto internals directly.

**Tcl**: `Tcl_ObjInternalRep` (16 / 8) and `Tcl_Obj` (48 / 8) are still
blocked -- by `double` alone now (`doubleValue`), as the previous pressure
analysis predicted; 204 bound functions point to `Tcl_Obj`. Double is not
added here.

**SDL3**: `SDL_HapticEffect` (72 / 8, a union of a type field and six
effect records) and `SDL_GamepadBinding` (32 / 4, its `input` and `output`
unions of records) are layouts. `SDL_Event` (128 / 8) stays blocked by
alternatives holding `float` fields (motion, wheel, touchpad, sensor
events, ...) and `bool` fields (keyboard, mouse button, joystick and
gamepad button events, ...) -- the blocker graph is evidence for the
numerical milestone, and neither is added here.

## 16. API impact

The raw APIs over these records were bound already (pointers); what changed
is that the records they point to have layouts:

| API | before | now |
|---|---|---|
| `ReadFile`, `WriteFile`, `GetOverlappedResult(Ex)`, `CancelIoEx`, `DeviceIoControl`, `PostQueuedCompletionStatus` | bound; `OVERLAPPED *` to a blocked record | bound; `OVERLAPPED` has a layout: a program can build, read and update one through a native edit |
| `QueryPerformanceCounter` | bound; `LARGE_INTEGER *` to a blocked record | bound; `LARGE_INTEGER` is a union layout |
| `SetFilePointerEx` | unsupported: `LARGE_INTEGER` by value | unchanged: a layout does not give the aggregate-by-value C ABI |

Across the bindings, bound APIs with a pointer to a record whose layout is
emitted: Tcl 119 → 121, SDL3 185 → 189, BoringSSL 946 → 1,152, Win32 1,663
→ 1,745 (of 1,820). APIs pointing to a complete record whose layout is
blocked: Tcl 208 → 204, SDL3 44 → 40, BoringSSL 298 → 83, Win32 180 → 71.

## 17. Verification

* **layouts-check.c** (both compilers) asserts, read back from the
  generated text: every union's `sizeof` and `_Alignof`; every alternative
  -- the last and the smallest as much as the first -- by `offsetof` (0),
  width, class (`__builtin_classify_type`: 13 for a union, 12 for a
  struct), signedness and extent; and every member of a synthetic layout
  through the record holding it, at the offset the generated text gives it
  there (the holding field's plus its own, through any nesting), with the
  anonymous member held inside its record. `cb-layout-union-verified`
  corrupts a union's size and alignment, its last alternative's width, an
  array alternative's extent, a synthetic struct's field offset and a
  synthetic union's place: each is caught, by name.
* **The synthetic sizes.** No C expression names an anonymous member's
  type, so neither compiler can assert its `sizeof`. After generation, the
  generator compiles layouts-check.c once more with clang's
  `-fdump-record-layouts` and compares every synthetic layout's size and
  alignment, read from the generated text, with the record clang locates at
  the manifest's `at=`; a disagreement stops generation (corrupting
  `bgf_anon_tail_member2`'s size or `bgf_deep_member3`'s alignment is
  caught there). GCC sees their members' offsets and widths, and that each
  lies inside its record, not their own sizes: that is the one fact here
  only clang verifies.
* **Second compilers**: host GCC (linux-x86_64), `aarch64-linux-gnu-gcc`
  (linux-aarch64) and `x86_64-w64-mingw32-gcc` (windows-x86_64-gnu, MinGW
  evidence, not MSVC) compile the fixture's and every real binding's
  layouts-check.c (`cb-layout-second-compiler`, `cb-layout-gcc-bindings`,
  `cb-win32-verified-gcc`: 932 Win32 records).
* **The runtime C oracle** (`tools/c-bindgen/oracle.tcl`) runs over every
  emitted layout of the fixture, Tcl, SDL3 and BoringSSL on both native
  backends. Each phase selects one alternative of every union (a different
  one in the next phase): C writes the selection with typed stores, Botlish
  reads every leaf -- the selection against C's values, every other
  interpretation against C's own reading of those bytes (memcpy from the
  member's address: the physical model, not C's union punning; a pointer
  over bits C stored as another alternative is not read); Botlish stores
  another selection through a native edit and C checks every byte against
  its own image (0xA5, then each written leaf's bytes copied in at its
  `offsetof`) and every written leaf with a typed read; Botlish builds a
  third selection in byte storage and C checks that image; a layout holding
  a union is read back with `binary::read` leaf by leaf (`binary::parse`
  refuses it). The language suite's own C oracle
  (`tests/cffi/nunion-fixture.c`) does the same for a record with every kind
  of alternative, the OVERLAPPED shape, an array of unions and sentinel
  bytes, with expected bytes built by memcpy, never by reading an inactive
  member.

## 18. Fuzzing

**The union fuzzer** (`audit/layout-unions/tools/fuzz.tcl`) draws chains
of random representations -- unions of one to five alternatives (scalars of
every width and signedness, C scalars, records, arrays, other unions, now
and then a pointer alternative declared but never read from bytes), each
union's size its widest alternative's plus random tail padding, its
alignment random; records holding unions at random offsets with gaps;
arrays of unions -- and checks every outcome against its own byte model
(little-endian, every alternative at its union's own offset, element i at
i times the union's declared size), which never reads a descriptor, a
registry or generated code: `binary::read` of random leaves; chains of
`binary::write` through overlapping alternatives (a later write changes
part of an earlier one's bytes; the operand never changes); and, natively,
every leaf read through a view and stores through an edit, each followed by
a read of another alternative (one written, another read: nothing cached).
Biased toward alternatives of different widths, never an invalid address.

| run | programs | disagreements |
|---|---:|---:|
| seed 1, four backends | 6 | 0 |
| seed 2, four backends | 30 | 0 |
| seed 3, four backends | 30 | 0 |
| seed 4, four backends, `-gc-stress 1` | 20 | 0 |

**The generator's layout fuzzer** (`audit/c-bindgen/tools/layout-fuzz.tcl`)
now draws unions too -- union records of integer, record-and-scalar and
array-and-scalar alternatives, unions held by value and as array elements
(`union lf_u`), anonymous unions with scalar, array, record and anonymous
struct alternatives, anonymous structs inside unions, and unions whose
alternative is a `float`, a `_Bool` or a bitfield -- and its own model says
which records are layouts (a union only by its alternatives' reasons), what
every synthetic layout is named (`CONTAINER_memberN`) and holds, and the
expected Botlish type of every field and alternative. It cross-checks the
model, the second compiler (GCC, through the promoted C names for every
anonymous member's members) and the runtime oracle on the host:

| run | programs | union layouts | synthetic layouts | blocked unions | disagreements |
|---|---:|---:|---:|---:|---:|
| host, seeds 1--5 | 38 | 108 (seeds 2--5) | 63 (seeds 2--5) | 78 (seeds 2--5) | 0 |
| host, seed 6, `-gc-stress 1` | 4 | 16 | 8 | 9 | 0 |
| linux-aarch64, seed 7 | 6 | 26 | 13 | 14 | 0 |
| windows-x86_64-gnu, seed 7 | 6 | 26 | 13 | 14 | 0 |
| macos-aarch64, seed 7 (no second compiler) | 6 | 26 | 13 | 14 | 0 |

The fuzzer found one real defect while it was being extended: an anonymous
union whose only member is a bitfield has no `offsetof` to anchor it, and
the generator reported `anonymous-record` beside the bitfield, which made
the pressure analysis think lifting bitfields would not recover the record.
The missing anchor is now reported only when nothing else blocks the
anonymous member (the bitfield is the root). Its scaling fixture
(`audit/c-bindgen/tools/layout-scale.tcl`) gained `unions` and `anonymous`
shapes; the first measurement of `anonymous` grew superlinearly (a scan of
every dump record per anonymous member), fixed by indexing clang's records
by line:

| shape | records | wall | layout pass | verification |
|---|---:|---:|---:|---:|
| unions (chained unions by value) | 1,000 / 2,000 / 4,000 | 2.1 / 3.9 / 8.7 s | 0.8 / 1.6 / 3.6 s | 0.5 / 0.8 / 2.1 s |
| anonymous (OVERLAPPED shape, 3 layouts per record) | 1,000 / 2,000 / 4,000 | 4.3 / 9.1 / 18.7 s | 1.3 / 3.1 / 6.4 s | 1.6 / 3.2 / 6.6 s |

The other fuzzers whose code this touches agree:
`audit/layout-arrays/tools/fuzz.tcl` (20 programs, seed 5, 0
disagreements).

## 19. Mutation testing

Every mutant is a deliberate bug, applied to a private copy of the tree;
a kill counts only when a test of behavior, a golden test or a fuzzer
fails (never a generated-file comparison alone).

**The language** (`audit/layout-unions/tools/mutants.txt`, 24 mutants;
`audit/layout-unions/tools/mutate.tcl` runs `tests/layout-unions.test` and
`tests/layout-arrays.test`, the golden suite on four backends and the union
fuzzer): **24 killed, 0 survived.**

| mutant | killed by |
|---|---|
| union-as-struct (a union taken for a record by every copy) | lu-copy-refusals, lu-not-a-type-not-a-struct, lu-pointer-authority-from-bytes, lu-registry, lu-unchecked-replay; golden |
| ordinary-overlap-accepted | lu-overlap-is-declared-only-by-a-union, la-declaration-errors |
| only-first-alternative | 35 tests (the C oracles, designators, native reads, ...); golden; fuzz |
| alternatives-sequential (laid end to end) | 41 tests; golden; fuzz |
| union-size-from-widest (union size recomputed) | lu-tail-padding; golden; fuzz |
| union-alignment-recomputed | lu-tail-padding; golden |
| union-nested-width-alternative (an array of unions strides an alternative's width) | lu-registry, lu-tail-padding; golden; fuzz |
| union-of-array-flattened | 25 tests; golden; fuzz |
| union-base-offset-lost (nested union base offset lost) | 14 tests (the C oracles, lu-designators, lu-caller-constructed-record, ...); golden; fuzz |
| alternative-offset-shifted (alternative offset ignored) | 18 tests; golden; fuzz |
| union-write-whole-width (a small alternative's write zeroes the union and past it) | 11 tests; golden; fuzz |
| designator-ends-at-union | lu-designators, lu-native-authority; golden |
| active-alternative-read (active-member state invented) | 18 tests (the C oracles, lu-executable, lu-gc-stress, ...); fuzz |
| pointer-alternative-from-bytes | lu-pointer-authority-from-bytes, lu-unchecked-replay; golden |
| pointer-union-parse-allowed | lu-pointer-authority-from-bytes, lu-unchecked-replay; golden |
| scalar-alternative-needs-foreign-write | lu-c-oracle-built, lu-caller-constructed-record, lu-pointer-authority-from-bytes, la-c-oracle-built, la-pointer-arrays-from-bytes; golden |
| pointer-alternative-ordinary-write (foreign pointer through an ordinary write) | lu-pointer-authority-from-bytes, la-pointer-arrays-from-bytes; golden |
| pointer-alternative-store-moves (pointer store moves its source) | lu-native-pointer-alternatives, lu-c-oracle-pointer, la-pointer-affinity, la-registrations |
| union-window-read-as-scalar | lu-c-oracle-punning, lu-c-oracle-view, lu-native-allocations, lu-native-arrays-of-unions, ... |
| union-read-cached (an alternative read cached after another write) | lu-native-interpretation-switching, lu-native-pointer-alternatives; fuzz |
| hir-text-drops-union-kind | lu-hir-text-roundtrip |
| hir-text-drops-alternative-representation | lu-hir-text-roundtrip |
| union-identity-process-wide (interchange or isolation merges same-named unions) | lu-isolation |
| union-copy-reference-unchecked | lu-unchecked-replay |

Two of them were weak in a first run, and the report would have hidden it:
`pointer-alternative-ordinary-write` disabled one of two branches that both
report LAYOUT-NATIVE-ONLY (it changed only a message), and
`pointer-alternative-store-moves` named an ownership role that does not
exist, so every program failed to load -- a kill by breakage, not behavior.
Both were rewritten to the rule they name (the whole check; the `move`
role) and are now killed by the tests above. In the same run a stale
expectation (a diagnostic's line, moved by a layout added later) failed in
the unmutated tree too: every kill was rechecked without it, and every
mutant above has another failing test or detector.

**The generator** (`audit/c-bindgen/tools/mutants.txt`; run with
`-match "cb-layout-* cb-fixture-*"`, the fuzzer and the layout fuzzer): the
16 new mutants and the 9 earlier layout mutants whose code moved, **25
killed, 0 survived, every one by a test of behavior or a fuzzer.**

| mutant | killed by |
|---|---|
| layout-union-blocker-kept (bindgen keeps the union blocker) | cb-layout-unions, -blockers, -anonymous-members, -pressure, ... (14); layout fuzz |
| layout-anonymous-overlay-kept | cb-layout-union-blockers, -anonymous-members, -blockers, ... (10); layout fuzz |
| layout-union-blocked-alternative-dropped (a blocked float alternative emitted away) | cb-layout-union-blockers, -pressure, -union-member-offset, ...; layout fuzz |
| layout-union-size-computed (union layout calculated instead of probed) | generation stops (layouts-check.c and the record-layout comparison): 40 fixture tests |
| layout-union-member-offset-assumed | cb-layout-union-member-offset |
| layout-union-only-first-alternative | cb-layout-unions, -union-program, -union-verified, -anonymous-members; layout fuzz |
| layout-verify-last-alternative-skipped (verifier misses the last/smaller alternative) | cb-layout-union-verified |
| layout-verify-anonymous-skipped | cb-layout-union-verified |
| layout-verify-anonymous-size-unchecked | cb-layout-union-verified |
| layout-anonymous-union-dropped | cb-layout-anonymous-members, -union-program, -union-blockers, ... (9) |
| layout-anonymous-union-flattened (anonymous union fields flattened) | cb-layout-oracle-fixture, cb-fixture-compiles, cb-layout-ordinary, ... (12) |
| layout-anonymous-offset-lost (anonymous nested struct offset lost) | generation stops: 38 fixture tests |
| layout-anonymous-struct-in-union-promoted | cb-layout-anonymous-members, -union-program, -union-verified, -records, ...; layout fuzz |
| layout-anonymous-keyword-line-only | cb-layout-anonymous-members, -union-program, -union-verified, ... |
| layout-anonymous-names-unchecked | cb-layout-union-blockers, -union-program, -union-verified, ...; layout fuzz |
| layout-anonymous-unheld-emitted | generation stops (the record-layout comparison): 38 fixture tests; layout fuzz |
| layout-offset-sequential, -offset-off-by-one, -packed-rounded-up, -nested-offset-ignored, -array-last-element-off-by-one | generation stops (layouts-check.c); layout fuzz for the first three |
| layout-long-width-from-host | cb-layout-llp64, -second-compiler, -verified, -conventions, ... |
| layout-array-flattened, layout-anonymous-member-dropped, layout-order-unstable | cb-layout-arrays / -anonymous-members / cb-fixture-deterministic, ...; layout fuzz for the first two |

**The neighbouring harnesses** mutate code this milestone changed
(`hir/layouts.tcl`, `core/binary.tcl`, `native/lower.tcl`,
`compiler/compiler.tcl`, `hir/completions.tcl`, `hir/types.tcl`). Seven of
their mutants no longer applied because the code they mutate moved (a
union case beside a layout case, `LayoutName` replacing a string range, a
union's refusal before the native-only one); each was rewritten to the
same rule, and every one of their Tcl mutants was run:

| harness | mutants run | killed | survived |
|---|---:|---:|---:|
| binary-layout (`audit/binary-layout/tools/mutate.tcl`) | 33 | 33 | 0 |
| native-view | 22 | 22 | 0 |
| native-edit | 32 | 32 | 0 |
| layout-arrays | 22 | 22 | 0 |

Their Rust mutants (6, 7, 8 and 2, in `ops.rs` and `nview.rs`, which this
milestone does not touch -- its only Rust change is the `LAYOUT-UNION`
entry of `SEMANTIC_KINDS`) were not rerun; each rebuilds a private copy of
the native backend, and nothing they mutate changed.

## 20. The remaining pressure

What still blocks layouts, each binding's records after unions (direct +
transitive; a record may wait for several):

| feature | Tcl | SDL3 | BoringSSL | Win32 |
|---|---:|---:|---:|---:|
| `ffi::c::Bool` fields | 0 | 14 (13 + 1) | 0 | 0 |
| `float` fields | 0 | 18 (17 + 1) | 0 | 19 (10 + 9) |
| `double` fields | 2 (1 + 1) | 0 | 0 | 0 |
| float and double | 2 | 18 | 0 | 19 |
| `long double` | 0 | 0 | 0 | 0 |
| bitfields | 0 | 0 | 4 (2 + 2) | 149 (55 + 94) |
| flexible array members | 0 | 0 | 0 | 3 |
| explicit calling conventions | 0 | 0 | 0 | 0 |
| float, double and Bool | 2 | 42 (38 + 4) | 0 | 19 |
| all of the above | 2 | 42 | 4 | 171 (68 + 103) |
| still blocked | 4 | 42 | 5 | 171 |

Records counted as section 14 counts them (synthetic records included).
Two remaining blockers are outside the features: Tcl's two records with a
pointer outside the ABI universe, BoringSSL's one. Bitfields dominate
Win32 (its flag words, mostly as anonymous structs inside unions, now
visible as records of their own); floats and Bools are SDL3's (all of
`SDL_Event` waits for both); double is Tcl's (`Tcl_Obj`). No feature is
chosen here: this is evidence for the next decision.

## 21. Regression and CI

* Existing layouts, arrays, views and edits are unchanged: the binary
  layout, native view, native edit and layout array suites, fuzzers and
  mutation tools pass (their mutants whose code moved were updated to the
  same rule; section 19).
* Every binding regenerates byte for byte (`tools/c-bindgen.tcl check
  PROFILE -target committed`, every profile); the fixture's four targets
  are generated on Linux.
* The golden suite `tests/golden/layout-unions.bot` runs on all four
  backends through CI's golden shards; its rows are in the manifest
  (census and fragment).
* The C binding generator's CI workflow regenerates and checks everything
  above with the cross toolchains it installs.

**Locally** (Linux x86-64, `tclsh9.0 tests/local.tcl -jobs 3`, after the
last change to the compiler):

| layer | result |
|---|---|
| Tcl tests on interp | 6,286 passed, 0 failed, 11 skipped (2,122 golden duplicates skipped) |
| Tcl tests on compile | 6,281 passed, 0 failed, 16 skipped (2,122 golden duplicates skipped) |
| golden suites (98, through the front-end cache) | 0 failed: interp 4,898/4,898, compile 4,898/4,898, cranelift-generic 4,806/4,806, cranelift 4,908/4,908 |

and, as AGENTS.md names them for this change: `tests/c-bindgen.test` (76:
70 passed, 6 skipped -- the BoringSSL and SDL3 library acceptance, whose
libraries are not built here -- 0 failed), `tools/c-bindgen.tcl check
PROFILE -target committed` for every profile (fixture, tcl, tclstubs,
sdl3, boringssl, win32: current), `audit/compilation-isolation/tools/interleave.tcl`
(12 suites, 96 artifacts and outcomes, 0 differ),
`audit/hir-interchange/tools/roundtrip.tcl -via interchange` (108, 0
differ) and `-via cache` (120, 0 differ), `audit/refactor/tools/gate.tcl`
(passed: the observed warnings are exactly the manifest),
`tools/compilerpedia.tcl check` (685 topics, 535 examples, 0 problems),
`cargo test --release --lib nview` (17 passed), and the header library's
`audit/c-header/tests/parser.test` (50) and `corpus.test` (22).

**In CI**, on the branch (`claude/nice-heisenberg-52pic7`, head 2e797e8,
the last code change before this report):

| workflow | result |
|---|---|
| tests (Linux x86-64: the whole Tcl suite, duplicates included, on interp and compile; native coverage; every golden suite on every backend beside its Tcl originals; Rust unit tests; stub-linked executables; warning gate) | success |
| tests (linux arm64) | success |
| tests (macos arm64), Tiers A and B | success |
| c-bindgen (generate, check, acceptance, with CI's cross toolchains) | success |
| static-decisions, batched against sequential, for layout-unions.bot, layout-arrays.bot, binary-layout.bot | success: they agree |

The first macOS run on the branch (an earlier head) failed two Tcl files
the local inventory pass had not reached -- `abi-mutable-bytes.test` (a
guard against address-reading natives matching `binary::read` by name)
and `numeric-looking-names.test` (an `expr` ternary selecting a
designator's text in `core/binary.tcl`) -- and a pinned line in
`layout-unions.test`; all three were fixed before the runs above.

## 22. What this does not solve

Deliberately not added, each a separate decision: tagged unions, sum types,
active-member tracking, discriminant association or protocol knowledge,
pattern matching over alternatives, C effective-type or strict-aliasing
rules, general arbitrary overlap, a copied union value (family A, section 6),
bitfields, `float`/`double`/`long double` and `ffi::c::Bool` layout fields,
flexible arrays and variable-length representations, native allocation,
volatile or atomic union access, aggregate-by-value C ABI (`SetFilePointerEx`
stays unsupported), MSVC layouts, a Windows runtime or backend, scalar
refinements and decimal guarantees. A wrapper that reads `SDL_Event.type`
and returns the matching alternative is ordinary code a program or a future
generator layer can write; the physical layout generator stays ignorant of
discriminants.

## 23. What to run when changing this

The language: `tests/layout-unions.test` (its C oracle needs `cc`), its
golden suite (`tclsh9.0 tests/local.tcl tests/golden/layout-unions.bot`),
`tests/layout-arrays.test`, `tests/binary-layout.test`,
`tests/native-view.test`, `tests/native-edit.test`,
`audit/layout-unions/tools/fuzz.tcl` (several seeds, once with
`-gc-stress 1`), `audit/layout-unions/tools/mutate.tcl`, the layout-arrays,
binary-layout, native-view and native-edit mutation tools, and `cargo test
--release --manifest-path native/Cargo.toml --lib nview`. The generator:
`tests/c-bindgen.test`, `tools/c-bindgen.tcl check PROFILE -target
committed` for every profile, `audit/c-bindgen/tools/layout-fuzz.tcl`
(several seeds), `audit/c-bindgen/tools/layout-scale.tcl` (the `unions` and
`anonymous` shapes) and `audit/c-bindgen/tools/mutate.tcl` (`-match
"cb-layout-* cb-fixture-*"` is enough for a mutant of the layout pass).
`bench/layout-unions.tcl` regenerates section 12.
