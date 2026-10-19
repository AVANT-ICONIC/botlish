# Fixed arrays in binary layouts

A `layout` field may now be a fixed array:

    layout WIN32_FIND_DATAW:
        size 592
        align 4
        field dwFileAttributes: ffi::c::ULong at 0
        ...
        field cFileName: array 260 of ffi::c::UShort at 44
        field cAlternateFileName: array 14 of ffi::c::UShort at 564

This report records what was built, why it is shaped the way it is, and the
evidence. It extends BINARY-LAYOUT.md (the layout language),
NATIVE-LAYOUT-VIEWS.md (reading live native memory), NATIVE-LAYOUT-WRITES.md
(writing it, and writing byte storage) and C-BINDGEN-LAYOUTS.md (the layouts
the C binding generator emits); each of those says so where it used to say
"no arrays".

## 1. The laws

Two sentences decided every design question below.

* **The layout determines where the bits are. The backing decides what those
  bits are allowed to mean.** An array element's position is the layout's
  arithmetic (the field's offset plus the index times the element's width);
  whether those bits may become a pointer, may be written, or may be read at
  all is the backing's: byte storage never conjures a pointer, a view never
  writes, an edit writes exactly the element's bytes.
* **A fixed array in a layout is repetition in an external representation.
  It does not give ordinary Botlish values a native array representation.**
  There is no FixedArray type, no array object, no slice. The copied value
  of an array field is an ordinary List; the live array is a view or an edit
  of the same memory a record view already addresses.

From these follow the rest: an array of characters is integers, never text
(section 9); one element is addressable without materializing the array
(section 6); a whole-array write is one logical write, never N record copies
(section 7); pointer authority is recursive (section 8); the C compiler, not
the generator, supplies every extent and offset (section 12).

## 2. Syntax

    field NAME: array N of ELEMENT at OFFSET

ELEMENT is any representation a field may have -- a scalar domain
(`binary::U16`, your own `Int in 0..255`), a C scalar (`ffi::c::Char`), a C
pointer (`ffi::c::Ptr[T]`, `ffi::c::FnPtr[F]`), a nested layout -- or another
array: `array 2 of array 3 of binary::U16` is C's `uint16_t m[2][3]`, the
outermost dimension first, as C writes it. `array` and `of` are contextual
words: a binding or a function named `array` is unaffected
(`la-syntax`). There is no C declarator syntax (`char name[16]`): the form
reads like the rest of a layout, and the dimension order needs no rule.

N is a compile-time literal of any size. `array 0 of E` is LAYOUT-ARRAY-EXTENT
(a zero-length or flexible array is not a fixed array: its length is data,
not representation), and so is an array whose width -- computed exactly, with
Tcl's integers, never wrapped -- exceeds the largest layout size.

`array N of E` is a representation, not a type of values: as a parameter type
it is LAYOUT-NOT-A-TYPE ("a copied fixed array is a List"), as a LayoutStruct
argument LAYOUT-STRUCT-PARAMETER (`la-not-a-type`). It is the argument of
`NativeView` and `NativeEdit`, which name live arrays (section 6).

## 3. Representation, stride and validation

An array field's registry entry is its representation: `{kind array extent N
stride S width N*S element E}`, recursively. The stride is the element's own
width, from the representation alone:

| element | stride |
|---|---|
| a scalar | its encoding's width (1, 2, 4, 8) |
| a C pointer | the target's pointer width |
| a nested layout | its declared size, tail padding included (`TAILED`: 8, its fields end at 5) |
| an array | its whole width (`array 3 of U16`: 6) |

No C alignment rule is involved: a packed record (5 bytes) strides 5, an
over-aligned one (16 bytes) strides 16 (`la-stride-is-the-elements-width`,
`la-parse-packed-and-aligned`). The field's validation is the ordinary one
applied to its whole width: inside the layout's size (LAYOUT-FIELD-BOUNDS),
no overlap with a neighbour at either end (LAYOUT-FIELD-OVERLAP), every
element a representation (LAYOUT-FIELD-TYPE, saying how deep: "the elements
of the elements of field ..."), no cycle through an array of the layout
itself (LAYOUT-CYCLE) (`la-declaration-errors`,
`la-declaration-element-messages`).

The descriptor every backend reads carries the same words, `{array N STRIDE
ELEMENT}`, so no backend reads the registry.

## 4. The copied value

A LayoutStruct field of array type is a List of exactly N element values,
recursively: rows are a List of Lists, records a List of LayoutStructs. Its
type is `List[E']`, E' the element's copied type (`List[List[int[U16]]]`,
`List[LayoutStruct[TAILED]]`). The extent is not part of the List's type --
List types say nothing about length -- so it is a fact about the value:

* **binary::parse** imprints every element from its own bytes (element i at
  offset + i * stride), every encoding's extremes and zero, little-endian
  (`la-parse-every-scalar-width`, `la-parse-shapes`, `la-three-dimensions`).
* **binary::emit** writes every element at its offset and checks every List
  against its array's extent first: a short List, a long one, a ragged row,
  a record element's own array is the declared **LayoutExtentMismatch**, and
  nothing is emitted (`la-emit-extent`). `parse(L, emit(v)) == v`;
  `emit(parse(L, b)) == b` exactly when b's padding -- tail padding inside
  array elements included -- is zero (`la-round-trip`).

LayoutExtentMismatch is its own declared error (not LayoutLengthMismatch,
which is about a byte storage's size): it names what a program got wrong.

### Proofs remove the failure path

`binary::emit`, `binary::write` and `binary::store` carry a bounds
registration, `-bounds {extents V}`: the completion analysis decides, per
call, whether every List the value writes is proven of exactly its array's
extent (hir/completions.tcl's `ExtentsVerdict`, `ReprValueVerdict`).
Proven `in`, the call declares no error and native code has no failure path
(no length test at all: `la-native-nir`); proven `out`, it is KNOWN-ERROR;
unproven, LayoutExtentMismatch must be handled or declared. What proves an
extent (`la-proofs-extent`):

* a list literal (each row of a two-dimensional one too);
* a collecting loop over a count (`loop i from 0 to 4`), or to
  `binary::layout_length(L)`;
* a branch on `list::length(xs) == N`;
* an **exact copy**: a List or LayoutStruct `binary::load` or
  `binary::parse` made, or a field of one, followed through immutable
  bindings and handlers that never complete (`ExactCopy`). Every array of a
  copy has exactly its extent: the copy made it so, and values never change.
  `binary::store(e, L.first, binary::load(v.last))` needs no handler; a copy
  of an array of another extent is proven out (KNOWN-ERROR);
* a construction of a LayoutStruct each of whose array fields is proven.

`binary::load` of a live array also tells every analysis its result's length
(`-result-length {extent 0}`, hir/cardinality.tcl): `list::at(binary::load(
v.first), 3)` needs no handler, index 4 always fails.

**The proof gap.** A function's result is no proof: `u8s([1, 2, 3, 4])`
returns a `List[binary::U8]` whose length no contract states, so writing it
needs a handler (`la-proofs-extent`, "function-result"). Closing that needs
length facts in function contracts, a general feature this milestone does not
add. In practice the gap is small: values built by literals, counted loops,
copies and branches are proven; a handler is one line where they are not.

## 5. Byte storage: whole arrays and static designators

`binary::write(d, L.arr, xs)` writes a whole array into a fresh
MutableBytes (the operand unchanged, as every MutableBytes write): every
element at its offset, records field by field -- a record element's tail
padding keeps the operand's bytes (`la-write-whole-array`). The storage's
size is checked first (LayoutLengthMismatch), then every extent
(LayoutExtentMismatch), then the bytes are written (`la-write-extent`).
Natively that is one `mbytesclone` and one `binstorearray` per row of
scalars (`la-native-nir`): one logical write.

A designator names an element statically: `L.first[3]`, a row's element
`L.m[1][2]`, a record element's field `L.tails[1].b`, a whole row `L.m[0]`
(`la-write-static-designators`). It resolves to one constant offset; an index
outside the array is LAYOUT-ARRAY-INDEX at the index, an index of a scalar
LAYOUT-OPERAND, a field after an array without an index UNKNOWN-FIELD (saying
"an element of a fixed array is named by its index"), and an index outside a
designator LAYOUT-OPERAND: Botlish has no index expression
(`la-designator-diagnostics`). A designator ending at a record element is
LAYOUT-OPERAND, as one ending at a nested layout always was.

**Decision: no dynamic-index byte writes.** A byte write by a computed index
(`binary::write_element(d, L.arr, i, v)`) would duplicate what a static
designator or a whole-array write already express for byte storage, whose
records are built once, field by field; live memory, where elements change
one at a time, has `binary::store_element`. If a workload needs it, it is a
role on the existing machinery (the narray bounds, ReprWrite), not a new
mechanism.

The value of a write is held to the field's type by the ordinary admission
rule: a List[binary::U8] for an array of binary::U8 (a List literal of Ints
is a List[int], which List's invariance does not admit), a List of
LayoutStruct[TAILED] for an array of TAILED, a static element's value to its
domain (`la-write-value-types`).

## 6. Live arrays

An array field read through a view is a live array, `NativeView[array N of
E]` -- its address word, nothing read -- and through an edit
`NativeEdit[array N of E]`. The extent and the element are part of the type
(an array of 5, or of I8 elements, is another type), and a view and an edit
stay distinct: no upgrade, no implicit downgrade (`la-native-types`).

    binary::element(a, i)           element i: a scalar's Int, a pointer
                                    (fresh, observed), a record's or a row's
                                    own live view or edit at its address
    binary::store_element(e, i, v)  one scalar or pointer element written
                                    through an edit
    binary::load(a)                 the whole array copied into its List

Each is one access at the array's address plus i times the stride: the whole
array is never read to get one element (`la-native-element-reads`), and the
cost does not depend on the extent (a 4096-element array costs what a
16-element one does: section 10). An index is checked against the static
extent: -1, N and an index past i64 are the ordinary IndexNotFound, nothing
read or written (`la-native-element-bounds`); an index the compiler proves in
0..N-1 (a constant, a loop over the extent, `down from N-1 through 0`, a
branch on 0 <= k < N) has no check at all and needs no handler, a constant
outside is KNOWN-ERROR (`la-proofs-index`; the narray bounds family,
`-bounds {index narray 0 1}`).

`binary::store(e, L.arr, xs)` writes a whole live array from a List: every
extent checked before the first byte is written (a ragged second row changes
nothing), then each row of scalars one helper call (`nativestorearray`),
records field by field (their tail padding untouched)
(`la-native-whole-store`). Element stores through static designators work
through an edit as through byte storage (`binary::store(e, L.m[0][1], v)`).

Authority stays distinct inside arrays: store_element through a view's
array, or binary::store through a view's record element, is BINARY-OPERAND;
store_element of a record or row element is LAYOUT-OPERAND ("write its
fields through binary::element(a, i), the element's own live edit");
binary::element needs a live array (`la-native-authority`). Reading through
an edit's arrays is allowed, as reading through an edit always was.

Making a view or an edit is raw authority (`binary::native` is direct);
using the arrays of one someone else made is not: binary::element,
store_element, load and whole stores are `binary`'s (`la-direct`).

## 7. Whole-array writes are one logical write

Every whole-array write -- emit, binary::write, binary::store -- checks all
extents first and then writes: there is no state in which part of a List was
written and the rest refused. Byte storage is copied once (the fresh
MutableBytes), never per element or per record; live memory is written in
place. Natively a row of scalars is one runtime call that encodes every
element before copying any byte (a value outside its encoding is RANGE with
the memory untouched: `array_native_row_store_writes_only_the_row`, a Rust
test).

## 8. Pointer authority is recursive

A layout holding an array of pointers -- directly, or an array of records
with a pointer field -- is native-only: binary::parse of it is
LAYOUT-NATIVE-ONLY, naming the pointer by its path (`ps[]`, `rs[].p`), and
an ordinary byte write of the array is LAYOUT-NATIVE-ONLY too
(`la-pointer-arrays-from-bytes`). Native memory may reveal pointers; bytes
may not conjure them:

* through a view, an element of an array of pointers is the pointer memory
  holds; binary::load copies the array into a List of pointers, affine like
  each pointer (using the List twice, or a read element twice, is
  USE-AFTER-MOVE; two reads are two pointers) (`la-native-pointers`,
  `la-pointer-affinity`);
* `binary::write_foreign(d, L.ps, ps)` encodes a List of existing pointers
  of exactly the element's type into an array of pointers in byte storage:
  each one's address bits, null as zero bytes, the extent checked, the
  pointers observed (`la-write-foreign-array`). An array of scalars, or of
  records holding pointers, is LAYOUT-FOREIGN-WRITE: such a record is
  filled a field at a time (`L.rs[1].p`).

## 9. Arrays of characters are not text

`array 16 of ffi::c::Char` imprints sixteen Ints of the target's plain char
(signed on x86-64, unsigned on AArch64 Linux): a NUL in the middle and the
bytes after it included, nothing trimmed, terminated or decoded; an array of
`wchar_t` (or Win32's WCHAR) is Ints of its scalar. The field's type is a
List of the scalar, never `str` (`la-characters-are-not-text`). Turning one
into a String is a decoding with an encoding and a terminator convention --
an ordinary function over the List, outside the layout language.

## 10. Lowering, runtime and performance

* **HIR**: the descriptor constant of an array field is `{name offset array N
  STRIDE ELEMENT}`; element operations are elaborated to `binary#element`,
  `binary#store_element` and `binary#load_array` carrying the array's
  descriptor words, so no backend reads a layout at run time. HIR text
  prints array fields (`rows: array 2 of array 2 of U16 at 4`) and live
  array types (`la-hir-text-roundtrip`); interchange, the front-end cache and
  compilation isolation carry them (`la-interchange`,
  `la-interchange-fresh-process`, `la-cache`, `la-isolation`).
* **The Tcl backends** have no native memory: a view of a non-null pointer
  is refused before any array could exist (`la-tcl-backends`). Their byte
  side is the reference implementation (core/binary.tcl's `DecodeRepr`,
  `EncodeRepr`); the Tcl compiler reads a row of scalars with one counted
  `binary scan`.
* **Native lowering** computes an element's address with constant-folded
  arithmetic (a record element's field in an array inside a nested layout is
  one load at `base + offset + i * stride + field`), copies a row of scalars
  with one runtime call (`nativeloadarray` / `binloadarray`), unrolls a copy
  of up to eight records or rows into one `listnew` (so a copy allocates
  exactly the List it returns), and loops past that.
* **The runtime** gained five row helpers (native/src/runtime/nview.rs:
  `rt_native_load_array`, `rt_native_store_array`, `rt_bin_load_array`,
  `rt_bin_store_array`, `rt_bin_store_ptr`), each rooting what it allocates
  (`la-gc-stress` runs the arrays under BOTLISH_NATIVE_GC_STRESS=1) and
  covered by Rust tests (`array_*`, `cargo test --lib nview`).

`bench/layout-arrays.tcl` (n = 200,000, best of 5, Cranelift with and without
specialization; times per operation over the program's baseline -- noisy at
this scale, but the shape is the point):

| operation | -specialize 0 | Cranelift |
|---|---:|---:|
| element read, proven index (16 x U16) | 28.0 ns | 21.1 ns |
| element read, dynamic index (bounds check) | 24.9 ns | 26.9 ns |
| a record element's field | 6.6 ns | 22.8 ns |
| element store, dynamic index | 11.8 ns | 8.4 ns |
| element read, proven index, 4096-element array | 18.3 ns | 19.9 ns |
| element read, dynamic index, 4096-element array | 12.1 ns | 20.1 ns |
| element store, dynamic index, 4096-element array | 19.1 ns | 14.1 ns |
| binary::load of a 16-element row | 353.5 ns | 401.1 ns |
| binary::load of four records | 686.2 ns | 652.3 ns |
| binary::load of a 260-element array | 3315.6 ns | 3500.4 ns |
| binary::store of a 16-element row | 119.2 ns | 150.9 ns |
| binary::store of a 260-element array | 1970.8 ns | 1854.3 ns |
| binary::write of a 16-element row (64-byte record) | 505.5 ns | 207.7 ns |
| binary::parse of the 64-byte record | 1173.3 ns | 1037.5 ns |
| binary::emit of the 64-byte record | 478.6 ns | 451.1 ns |

Allocations per operation over the baseline (Cranelift's counters): element
reads and stores, at any extent, **0**; whole stores **0** beyond their
List; a load of a row **1** (its List), of four records **5** (the List and
four LayoutStructs); a byte write **1** (the fresh storage); a parse **6**;
an emit **2** (the Bytes value). An element access costs the element's,
never the array's; a copy is linear in the extent, about 13 ns per element
(decoding each element and building the List), a store about 7 ns.

## 11. What was proven and what is not

| property | how |
|---|---|
| element offsets, strides, every encoding | an independent byte model (the tests' `laBytes`, the fuzzer), all four backends |
| C agrees on extents, offsets, element types | the C oracle (section 13): C lays out the record, Botlish reads and writes it, C checks with typed reads |
| extents checked before any write | tests of ragged and short Lists against sentinel memory, Rust tests of the row helpers |
| no failure path when proven | NIR of proven writes and reads (`la-native-nir`) |
| element access O(1), allocation-free | allocation counts and the 4096-element benchmark rows |
| no pointer from bytes | LAYOUT-NATIVE-ONLY diagnostics, `pointer-array-from-bytes` mutant |

Not proven, recorded here: function results' List lengths (section 4); a
dynamic index of a byte write (not offered, section 5).

## 12. The C binding generator

The generator (C-BINDGEN-LAYOUTS.md) used to block every record with an
array field (`fixed-array`). Now a fixed array of representable elements is a
layout field:

* **Extents are the compiler's.** For an array member the layout probe asks,
  per dimension, `sizeof(p) / sizeof(p[0])`, `sizeof(p[0]) /
  sizeof(p[0][0])`, ..., and the innermost element's `sizeof`
  (records.tcl's `dims:KEY:I`). The declaration's bound expressions (often
  macros: `SHA256_CBLOCK`, `MAX_PATH`) are never evaluated. The element's
  probed size must equal its mapped width (a scalar's on the target, a
  pointer's, the nested record's sizeof) and the extents' product times it
  the member's sizeof; a disagreement would be a blocker, never a guess
  (none occurs).
* **Elements map as fields do**: a char array is `array N of ffi::c::Char`,
  `wchar_t text[8]` on Linux `array 8 of ffi::c::Int`, `void *slots[3]`
  `array 3 of ffi::c::Ptr[ffi::c::Void]`, `bgf_point pts[4]` `array 4 of
  bgf_point` (a by-value dependency: blocked if the element is), `int
  m[2][3]` `array 2 of array 3 of ffi::c::Int`.
* **What stays blocked**: a flexible array member or a zero-length array
  (`flexible-array`); an array whose element is blocked (an array of floats
  is `float`, of a union `union`, of a blocked record nested-layout-blocked)
  -- the element's own reason, so the pressure analysis sees it.
* **layouts-check.c** asserts, per array field, that the member is an array
  type at every dimension (never a pointer:
  `!__builtin_types_compatible_p(__typeof__(m), __typeof__(&m[0]))`), each
  dimension's extent, the first element's type and width at the field's
  offset (as a field), and the last element's offset -- which pins the
  stride. Every committed binding's check compiles with its target's clang,
  and the Win32 one with MinGW-w64's GCC too (`cb-win32-verified-gcc`).
* **The runtime oracle** (oracle.tcl) treats each array element as a leaf:
  C writes it, Botlish reads it through `binary::element`, stores it through
  a static designator, writes it into byte storage and parses it back
  (`list::at`). Arrays of more than four elements in a dimension are sampled
  (first two, middle, last); the elements left out are bytes no check covers,
  which C checks untouched -- so the oracle also proves nothing else was
  written. It ran over every emitted layout of the Tcl, BoringSSL and SDL3
  bindings on both native backends (`cb-tcl-layouts`, `cb-boringssl-layouts`,
  `cb-sdl3-layouts`): no disagreement.

### Results against the forecast

C-BINDGEN-LAYOUTS.md's pressure analysis forecast what fixed arrays would
recover. Regenerated with arrays, every profile and target emits exactly the
forecast:

| binding (target) | layouts before | after | gained | forecast (direct + transitive) |
|---|---:|---:|---:|---|
| Tcl (linux-x86_64, linux-aarch64) | 29 | 32 | +3 | 3 (3 + 0) |
| Tcl stubs (linux-x86_64) | 29 | 32 | +3 | 3 (3 + 0) |
| SDL3 (linux-x86_64, linux-aarch64) | 70 | 81 | +11 | 11 (7 + 4) |
| BoringSSL (linux-x86_64, linux-aarch64) | 52 | 71 | +19 | 19 (18 + 1) |
| Win32 (windows-x86_64-gnu) | 564 | 813 | +249 | 249 (186 + 63) |
| the fixture (all four targets) | 28 | 35 | +7 | 7 (5 + 2) |

The bound APIs pointing to the recovered records are the forecast's too
(Tcl 39, SDL3 6; BoringSSL's 18 recovered records were forecast to serve 155
distinct APIs and the 19 now emitted are pointed to 165 times; Win32's 61
directly recovered records 153 APIs, the 249 now emitted 157 pointer uses).
APIs pointing to a record with a layout: Tcl 82 → 119, Tcl stubs 82 → 118,
SDL3 183 → 185, BoringSSL 791 → 946, Win32 1582 → 1663.

### Sentinel records

| record | before | now |
|---|---|---|
| Win32 WIN32_FIND_DATAW (592 bytes) | blocked: WCHAR arrays | layout (`cFileName: array 260 of ffi::c::UShort at 44`) |
| Win32 OVERLAPPED | blocked: anonymous union | blocked: anonymous union (unchanged) |
| Win32 LARGE_INTEGER | blocked: union | blocked: union (unchanged) |
| Tcl_DString, Tcl_HashTable, Tcl_Parse | blocked: arrays | layouts |
| SDL_GUID | blocked: `Uint8 data[16]` | layout |
| BoringSSL SHA256_CTX, SHA512_CTX, MD5_CTX | blocked: arrays | layouts |
| BoringSSL SHA_CTX | blocked: arrays and an anonymous union | blocked: anonymous union only |

### The pressure rerun: unions after arrays

The layout pressure report no longer weighs fixed arrays (they are no missing
feature); its counterfactuals are now unions, Bool, floats, bitfields and
flexible arrays. Unions were forecast to compound with arrays, and they do --
the union counterfactual, rerun with arrays present:

| binding | unions alone, before arrays | unions, after arrays | arrays + unions forecast | arrays + unions now |
|---|---:|---:|---:|---:|
| Tcl | 0 | 2 (1 + 1) | 5 | 3 + 2 = 5 |
| SDL3 | 3 | 4 (3 + 1) | 15 | 11 + 4 = 15 |
| BoringSSL | 10 | 46 (24 + 22) | 65 | 19 + 46 = 65 |
| Win32 | 113 | 175 (125 + 50) | 424 | 249 + 175 = 424 |

Bound APIs a union feature would now give a layout of a record they point
to: Tcl 4, SDL3 4, BoringSSL 221 (24 records), Win32 109 (33 records). Unions
are the next feature by this measure, and the arrays here are designed to
coexist with them orthogonally: an array whose element is a union-bearing
record is blocked by its element alone, and recovered with it.

## 13. Tests and oracles

* **tests/layout-arrays.test** (53 tests): declarations, the copied value on
  all four backends, byte writes, designators, live arrays natively, proofs,
  NIR, allocations, HIR text, interchange, isolation, cache, specialization,
  authority, executables, GC stress -- and the **C oracle**,
  tests/cffi/narray-fixture.c: a C struct of `char[16]`, `uint16_t[5]`,
  `int32_t[2][3]`, `void *[2]`, records with and without tail padding and
  `long long[2]`, laid out by C (offsets, array sizes and element sizes
  pinned by static assertions). C fills it and Botlish reads it through a
  view, element by element and whole; Botlish stores elements and whole
  arrays through an edit and C reads every element with its own typed loads
  and checks every padding byte (tail padding inside the records included);
  Botlish builds the record in byte storage and C checks the image
  (`la-c-oracle-view`, `-edit`, `-whole`, `-built`).
* **tests/golden/layout-arrays.bot** (82 golden tests on all four backends,
  every one able to fail: `perturb.tcl` inverts 82/82, alters 82/82, moves
  44/44 columns) ports the byte side and the static checks; the manifest
  maps all 53 Tcl tests (fragments and census rows).
* **audit/layout-arrays/tools/fuzz.tcl**: random layouts of arrays of
  scalars, rows and records (up to three levels) against an independent
  byte model -- emit, parse, round trip, whole and designator writes, short
  and long Lists -- on all four backends, and live arrays (load, dynamic
  element reads through every array on the path, stores, whole stores, an
  index one past refused with nothing written) natively. Seeds 1..3, 30
  programs each: no disagreement (section 14 for GC stress).
* **audit/c-bindgen/tools/layout-fuzz.tcl** now draws arrays of C integers,
  stdint types, pointers, earlier records, struct lf_inner and two
  dimensions as layout fields, and arrays of floats, Bools and unions as
  blocked by their element; a second compiler (GCC) checks every array's
  sizeof and last element's offset; the runtime oracle reads and writes the
  elements. Results: section 14.
* Rust: `array_native_rows_load_every_encoding`,
  `array_native_row_store_writes_only_the_row`,
  `array_byte_rows_load_store_and_check_bounds`,
  `array_byte_pointer_elements_copy_address_bits` (also under GC stress).

## 14. Fuzzing and mutation results

Fuzzers (no disagreement in any run):

| fuzzer | runs | programs |
|---|---|---:|
| audit/layout-arrays/tools/fuzz.tcl, all four backends | seeds 1, 2, 3 | 30 each |
| the same under BOTLISH_NATIVE_GC_STRESS=1 | seed 4 | 12 |
| audit/binary-layout/tools/fuzz.tcl | seed 1 | 30 |
| audit/native-view/tools/fuzz.tcl | seed 1 | 30 |
| audit/native-edit/tools/fuzz.tcl, native backends; all four | seeds 1; 2 | 30; 30 |
| audit/c-bindgen/tools/fuzz.tcl | seeds 1, 2 | 10 each (158, 170 declarations) |
| audit/c-bindgen/tools/layout-fuzz.tcl, the host, linux-aarch64, windows-x86_64-gnu, macos-aarch64 | seeds 1, 2, 3 each | 8 each (80 records, 64-66 layouts) |

The C layout fuzzer's first seed-2 run on the host found one disagreement:
a fuzzed binding with no pointee identities has no `ctypes` module, which
the runtime oracle imported unconditionally. The oracle now imports it only
when it exists (a tool bug, not a layout one); the rerun agrees.
`audit/c-bindgen/tools/layout-scale.tcl` stays linear in the records (1000,
2000, 4000 records of each shape: about 1.4, 2.6 and 5.4 s for the mixed
shape, the layout pass about half of it).

Mutation: MUTATION-RESULTS

## 15. Exclusions

Deliberately not added, each a separate decision: unions and overlays;
bitfields; float, double and long double fields; `_Bool` (`ffi::c::Bool`)
fields; flexible array members and variable-length arrays; slices or views
of part of an array; a FixedArray value type or any array value distinct
from a List; String conversion of character arrays; native allocation of
records or arrays; pointer arithmetic; volatile, atomic or SIMD access;
arrays by value in the C call ABI (parameters and results); MSVC layouts.

## 16. Known issues found along the way

* A designator the checks reject, compiled with `-strict 0`, fails natively
  with an internal lowering error instead of replaying its diagnostic
  (the Tcl backends raise an unrelated declared error). This predates arrays
  -- an unknown field (`L.nope`) does the same on main -- and applies equally
  to LAYOUT-ARRAY-INDEX.
* A store of an out-of-range value under `-strict 0` reports RANGE naming
  `binary::store` also for `binary::store_element` (the runtime store helper
  is shared); a checked program never reaches it.

## 17. What to run when changing this

AGENTS.md, "Fixed layout arrays", lists the files and the commands:
tests/layout-arrays.test, its golden suite, tests/binary-layout.test,
tests/native-view.test, tests/native-edit.test, the array fuzzer (several
seeds, once with `-gc-stress 1`), audit/layout-arrays/tools/mutate.tcl and
the binary-layout, native-view and native-edit mutation tools, and `cargo
test --lib nview`; for the generator, C-BINDGEN-LAYOUTS.md's checks
(tests/c-bindgen.test, `c-bindgen.tcl check` of every profile, both fuzzers,
the generator's mutants) and a regeneration of every binding.
