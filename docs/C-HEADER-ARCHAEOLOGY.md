# C-HEADER-ARCHAEOLOGY.md

Empirical C header archaeology: what is left of two real C APIs after a real
C preprocessor has done its job, and what an exploratory FFI IR needs to
represent it.

> After the system preprocessor has run, BoringSSL's and Tcl's public
> headers are written in a small, regular declaration language. A
> declaration parser of about a thousand lines of Tcl reads all of it, and
> all of the glibc 2.39 headers they pull in, without a single parse
> failure. The compiler accepts all 6,874 checks of the functions,
> typedefs, objects, fields and enumerators the IR renders back to C, apart
> from four whose type an attribute changes. The difficult part is not the
> declarations. It is the parts of the API that never become declarations:
> 817 `static inline` functions, nearly 8,000 macros, a stub table,
> prefixed link names, and the physical facts no declaration states.

This milestone builds an instrument, not the FFI. It runs the installed C
preprocessor, parses its output into an inspectable IR, counts what the two
subject libraries actually contain, and records the shapes a first FFI
cannot take as plain declarations. Every recommendation at the end is tied
to counted declarations. None of it is implemented: no FFI type, no plugin
protocol, no thunk system and no layout extension.

## Contents

* [Summary](#summary): the answers in one page
* [The experiment](#the-experiment): subjects, profiles, pipeline, files
* [The instrument](#the-instrument): toolchain adapter, parser, IR, oracle,
  macro probe, ABI probe, thunks
* [Specimens](#specimens): real IR for each category (item 110)
* [BoringSSL census](#boringssl-census-items-1-20) (item 111)
* [Tcl census](#tcl-census-items-1-20) (item 112)
* [Structural census](#structural-census-items-21-30) (item 113)
* [Macro report](#macro-report-items-31-40) (item 114)
* [Layout report](#layout-report-items-41-50) (item 115)
* [ABI report](#abi-report-items-51-60) (item 116)
* [FFI type-system report](#ffi-type-system-report-items-61-70) (item 117)
* [Toolchain report](#toolchain-report-items-71-80) (item 118)
* [Parser report](#parser-report-items-81-90) (item 119)
* [Deep dives](#deep-dives): BoringSSL, Tcl, comparison, workarounds
* [Architecture consequences](#architecture-consequences-items-91-100) (item 120)
* [Unexpected findings](#unexpected-findings) (item 121)
* [Reproducing a run](#reproducing-a-run)
* [Files](#files)

## Summary

| question | answer |
|---|---|
| Is "system preprocessing + a small Tcl declaration parser" realistic? | **Yes.** The parser has 46 procedures and 1,019 lines of Tcl code. It reads 100% of the declarations in both libraries' public headers and in their glibc dependencies: 4,480 + 1,171 library records and 485 + 284 system records, with 0 unsupported. A compiler oracle re-checks every function, typedef, variable, field and enumerator the IR describes against GCC 13.3 and Clang 18.1: 0 unexplained mismatches. |
| Which constructs make it hard? | Not the declarators. The hard parts are the typedef-name/identifier ambiguity, recovery, and attributes in seven positions. Preprocessing removes the problems people usually expect from C headers (export macros, `#if` mazes, type macros, declaration-generating macros). |
| What does the FFI need besides declarations? | Physical facts: sizes, alignments, offsets, enum storage, `char` signedness, the effect of `mode`/`aligned`. Link names: asm labels and `#pragma redefine_extname`, which Clang prints unexpanded. A strategy for API that is not a declaration: 817 BoringSSL `static inline` functions, Tcl's 761 stub-table macros, and value macros (about 4,700 constants). |
| Opaque pointers? | Dominant. 103 BoringSSL tags and 30 Tcl tags are never completed. 2,098 of BoringSSL's 3,109 declared functions and 405 of Tcl's 919 take or return a pointer to one. |
| Callbacks? | Central, with two dialects. BoringSSL: 145 function-pointer typedefs, 451 functions taking callbacks (300 of them `static inline` stack functions). Tcl: 112 function-*type* typedefs and 52 functions taking callbacks; 57 of Tcl's 66 callback parameters follow the `void *clientData` convention. No callback anywhere needs a closure beyond a `void *`. |
| Varargs, by-value aggregates, floats? | Postponable. 5 + 11 variadic functions, **zero** by-value struct or union parameters or results in either API, and 1 + 7 functions using `double`. |
| Struct layout? | 100 BoringSSL and 35 Tcl complete structs, most of them behind pointers. Only 3 are representable by today's `layout`. A pointer-width scalar unlocks 52 + 27 more. Fixed arrays unlock 15 more in BoringSSL, and 14 of BoringSSL's array-and-union structs are storage-only blobs that need only size and alignment. |
| Simple-callable subset? | Integer scalars, pointers, non-variadic, no aggregates by value, no callbacks: 2,929 of 3,109 declared BoringSSL functions (94%) and 675 of 753 public Tcl functions (90%). Adding static, non-capturing callbacks raises this to 3,092 (99.5%) and 737 (97.9%). |
| Is macro provenance needed? | **No** for declarations: the oracle passes without it. It is not needed to find macro APIs either: `-dD` plus a compiler-run expansion probe classifies every macro. Cheap source-line co-occurrence is enough to say which macros decorated which declarations. |
| Live import or pre-generated bindings? | Pre-generated. The IR depends on the compiler family, defines, include roots and system headers, and in places it is wrong in an ambient configuration (stubs, prefixing). A package author's one-time import, committed, is the model the evidence supports. |

## The experiment

### Subjects

| library | revision | public headers | lines | entry set |
|---|---|---:|---:|---|
| BoringSSL | tag `0.20260929.0`, commit `427ec40cc8edc545253289232e885708c409e5ea` (2026-09-29) | `include/openssl/*.h` (100 files) | 49,809 | the 93 crypto + 5 ssl `hdrs` of `gen/sources.json`, in order, in one translation unit (`pki/` is C++ only) |
| Tcl | tag `core-9-0-1`, commit `6230a12b3bf6f7d8128f6ef14b0a3650a9d479e0` (2024-12-19, the version this repository pins) | `TCL_PUBLIC_HEADERS` of `unix/Makefile.in` (7 files) | 8,368 | `tcl.h`, `tclOO.h`, `tclTomMath.h` (tcl.h includes tclDecls.h and tclPlatDecls.h) |

Tcl's `tclTomMath.h` includes `libtommath/tommath.h`, a third-party header
in the Tcl tree that Tcl does **not** install. Its declarations have origin
`bundled` and are counted separately where it matters. Internal headers
(`tclInt.h`, BoringSSL's `crypto/internal.h`) are never reached; a tag the
public headers only forward-declare is opaque to the census.

The host is Ubuntu 24.04 on x86-64, with glibc 2.39, GCC 13.3.0 (default
`gnu17`) and Clang 18.1.3. Both libraries were cloned at their tags
(`tools/fetch.tcl` checks the commits); nothing installed on the host was
analyzed in their place.

### Profiles

A profile is a library plus its defines and include directories
(`audit/c-header/profiles/*.tcl`):

| profile | configuration | why |
|---|---|---|
| `boringssl-static` | no defines | the default static-library consumer |
| `boringssl-shared` | `BORINGSSL_SHARED_LIBRARY` | the shared-library consumer |
| `boringssl-prefix` | `BORINGSSL_PREFIX=bssl` | a bundled, symbol-prefixed BoringSSL beside a system OpenSSL: the static-package case |
| `tcl-embed` | no defines | direct linkage (an embedding application) |
| `tcl-stubs` | `USE_TCL_STUBS` | the normal extension build, linked with `libtclstub` |
| `tcl-notommath` | `TCL_NO_TOMMATH_H`, no `libtommath` include directory | what `tclTomMath.h` needs without libtommath installed |

`tools/variants.tcl` adds four variations that are not profiles: Clang
instead of GCC, `-std=c11`, and the prefix build with
`-U__PRAGMA_REDEFINE_EXTNAME`. The last simulates a compiler without the
pragma (the branch MSVC takes) and is labeled as a simulation wherever it
is used.

### Pipeline

```
profile (entry headers, include directories, defines)
   |
   |  tools/toolchain.tcl       cc -E -x c -I.. -D..        (the only command-line knowledge)
   v
preprocessed C, line markers, #pragma lines     + a -dD run: every #define in place
   |
   |  tools/cdecl.tcl           tokenizer -> declaration parser -> IR records
   v
IR records: function typedef struct enum variable pragma unsupported (+ macro records)
   |
   +-- tools/run.tcl            ir.txt system.txt macros.txt census.txt profile.txt
   +-- tools/oracle.tcl         every record rendered back to C, checked by the compiler
   +-- tools/abiprobe.tcl       sizeof/alignof/offsetof/enum values from a native probe
   +-- tools/thunks.tcl         wrappers for real macros, compiled by gcc and clang
   +-- tools/corpus.tcl         one fixture per unsupported shape
   +-- tools/query.tcl diff.tcl variants.tcl complexity.tcl
```

Ordinary Botlish compilation never runs any of this. The instrument lives
in `audit/c-header/`, uses the C toolchain only because its subject is C,
and imports nothing from the compiler.

## The instrument

### The toolchain adapter

`tools/toolchain.tcl` is the one place that builds command lines. The rest
of the instrument asks it for five operations: preprocess a translation
unit, preprocess it keeping `#define`s (`-dD`), list the predefined macros,
compile a probe to an object, and compile, link and run a native probe.
Configuration is read from `BOTLISH_C_CC`, `BOTLISH_C_CPP`,
`BOTLISH_C_TARGET`, `BOTLISH_C_INCLUDE`, `BOTLISH_C_DEFINES`,
`BOTLISH_C_UNDEFINES` and `BOTLISH_C_FLAGS`, plus the profile's own include
directories and defines. Every flag the adapter spells sits in one style
table (`-E -x c -I -D -U -dD -dM -c -o --target=`), so a second command
shape would be one entry in that table plus a list of what it cannot do.
The [toolchain report](#toolchain-report-items-71-80) has the details.

### The tokenizer and the parser

`tools/cdecl.tcl` is a tokenizer, a recursive-descent declaration parser
and a recursive type representation; there is no AST framework:

* **Tokenizer.** One leftmost-longest regular expression per line splits
  identifiers, numbers, string and character literals, punctuators and a
  catch-all. Line markers (`# N "file" flags`, `#line`) set each token's
  file and line, and flag `3` marks a system header. Every other directive
  the preprocessor passed through (`#pragma`, and `#define` in `-dD` mode)
  is kept with the index of the token it precedes.
* **External declarations.** Declaration specifiers, then an
  init-declarator list, or a function definition whose body is skipped by
  brace matching and recorded as `definition 1` with its token count.
  `_Static_assert`, file-scope `asm`, and tag declarations (`struct x;`)
  are handled too.
* **Specifiers.** Storage classes, function specifiers, qualifiers (13 in
  19 spellings), type keywords canonicalized to one spelling (`long
  unsigned int` is `unsigned long`), `struct`/`union`/`enum` with or
  without a body, typedef names, `__builtin_va_list` and its kin,
  attributes, `__extension__`, calling-convention keywords, `typeof`,
  `_Atomic(T)` and `_BitInt(N)`. An identifier is a type name only if it
  is a known typedef and no type specifier has been seen yet. That is the
  standard rule, and the only place the parser needs a symbol table.
* **Declarators.** Pointers with their qualifiers and attributes, a name or
  a parenthesized inner declarator, then array and parameter suffixes. The
  derivations are applied to the base type as: pointers first, then the
  suffixes from the last to the first, then the inner declarator's own
  derivations. So `int (*a[4])(const char *)` is an array of 4 pointers to
  `fn(const char *) -> int`. At `(`, a parenthesized declarator starts if
  the next token is `*`, `^`, `(`, `[`, an attribute or a non-typedef
  identifier; otherwise a parameter list starts.
* **Recovery.** A failing declaration becomes an `unsupported` record (its
  category, reason, parser state, text and location), and the parser skips
  to the next `;` at bracket depth 0 or past the `}` of a function body. It
  never fired on either library; the tests exercise it.

### The IR

A record is `KIND NAME BODY`, the body a dict. The kinds are `function`,
`typedef`, `struct` (also unions: key `kind`), `enum`, `variable`,
`pragma`, `directive`, `static_assert`, `asm` and `unsupported`. Every
record has `loc {FILE LINE ENDLINE}` (from line markers, relative to the
library root), `origin` (public, bundled, internal, system, builtin or
entry), `attrs` (each attribute that survived, with its form and the
position it was written at: `spec`, `decl`, `inner`, `ptr`, `tag`, `body`)
and `text`, the preprocessed tokens with normalized spacing.

Two annotations are cheap source facts, not expansion provenance.
`srcmacros` lists the library macros written on the original header lines
the declaration came from. `srcconditionals` lists the macros tested by a
`#if` inside its span. For complete structs, `dochints` records keep-out
words from the comments around the definition; it is used only by the
heuristic sections of the census.

Types are recursive Tcl lists that keep every distinction:

```
{void} {bool} {int SPELLING} {float SPELLING} {complex SPELLING}
{builtin __builtin_va_list}
{typedef NAME}                 never flattened; ::cir::resolve follows the chain on request
{struct TAG} {union TAG} {enum TAG}     anonymous tags are anon@FILE:LINE
{ptr T}  {q QUALS T}  {array T BOUND ?QUALS?}   BOUND {} | {lit N} | {expr TEXT} | {vla}
{fn RESULT {{NAME TYPE ATTRS} ...} FLAGS}       FLAGS: variadic, noproto
{typeof TEXT} {atomic T} {bitint TEXT}
```

Parameter arrays are not adjusted to pointers, function types are not
adjusted to function pointers, typedef identity is not resolved, and
qualifiers stay where they were written. The text form (`tools/ir.tcl`)
writes one key per line and keeps source order, so two runs of a profile
are byte-identical. This was checked by running `boringssl-static` twice:
ir, macros, system, census and profile files compared equal. A nested
definition comes right before the declaration that contains it.

### The compiler oracle

`tools/oracle.tcl` checks the parser against the compiler in standard C11
without any vendor AST dump. After the profile's own headers, it renders
every record back to C:

* a function as `RESULT (NAME)(PARAMS);` (a conflicting redeclaration is an
  error; the parentheses keep a same-named function-like macro out);
* a typedef as `typedef TYPE NAME;` (C11 allows only an identical
  redefinition);
* an object as `extern TYPE NAME;`;
* a field as `_Static_assert(_Generic(&((TAG *)0)->F, TYPE *: 1,
  default: 0))`, which checks its exact type, qualifiers and array bounds
  included;
* every enumerator the parser computed as `_Static_assert(NAME == VALUE)`.

A library macro named like a declared function is `#undef`d before that
function's check. The script also plants one wrong check of each kind and
requires the compiler to reject it, so an accepting oracle cannot pass
silently. An error raised inside a macro expansion is attributed to its
check through the compiler's "in expansion of macro" note.

| profile | checks | rejected | explained | planted caught |
|---|---:|---:|---:|---:|
| boringssl-static, -shared, -prefix (gcc and clang) | 4,710 | 0 | 0 | 5/5 |
| tcl-embed, tcl-stubs (gcc) | 2,164 | 0 | 4 | 5/5 |
| tcl-embed, tcl-stubs (clang) | 2,164 | 0 | 1 | 5/5 |
| tcl-notommath (gcc / clang) | 1,989 | 0 | 3 / 0 | 5/5 |

"Explained" mismatches are attributes that are part of the C type, which
the IR keeps beside the type rather than in it:

* `typedef unsigned long private_mp_word __attribute__((mode(TI)));` is a
  128-bit type (both compilers);
* GCC treats `noreturn` on the function-pointer fields `TclStubs.tcl_Panic`,
  `tcl_Exit` and `tcl_ExitThread` as part of their type; Clang does not.

The checks skipped are 23 + 20 fields reachable only through an unnamed
anonymous tag, 3 bitfields (they have no address) and 2 anonymous members.

### The macro probe

Macros come from a second preprocessing run with `-dD`, which keeps every
`#define` and `#undef` between the same line markers, so each definition
has a file and a line (`tools/macros.tcl`). The instrument never expands a
macro itself. To learn what one means, `run.tcl` preprocesses one more
translation unit: the profile's headers, then one line per library macro,
`__botlish_probe_N__ NAME` or `__botlish_probe_N__ NAME(__botlish_a0__,
...)`. The compiler's expansion is stored as `expansion`, with the markers
mapped back to the parameter names. Where each marker went is stored as
`arguses` (standalone uses, uses inside a string literal, uses pasted into
a longer identifier). That gives exact stringify, paste, multiple-
evaluation and unused-argument flags, even through nested macros. A probe
the preprocessor rejects (`_Pragma(#s)` with an identifier) is left out,
recorded as `probe {rejected MESSAGE}`, and the rest is preprocessed again.

### The ABI probe

`tools/abiprobe.tcl` is a throwaway native prototype of the ABI-probe
wishlist ([item 53](#abi-report-items-51-60)). It generates one C program
that prints `sizeof`, `_Alignof` and signedness for the C scalars and
every integer typedef of the API, size and alignment for every complete
struct, offset and size for every addressable field, size and signedness
for every enum, the value of every enumerator, and the value of every
integer-constant macro. The program is compiled and run on the host
(`results/PROFILE/abi.txt`: 3,559 facts for BoringSSL, 1,361 for Tcl). The
compiler agrees with every enumerator value the parser computed (95 and
13; none uncomputed). From the probed offsets it writes a Botlish `layout`
for every struct the census calls REPRESENTABLE-NOW (`layouts.bot`). Both
files compile and run (`tclsh9.0 main.tcl
audit/c-header/results/tcl-embed/layouts.bot` gives `[16, 16]`), so the
destination BINARY-LAYOUT.md designed for this already works for them.

### The thunk prototype

`tools/thunks.tcl` compiles 30 hand-written wrappers, the way a generator
would write them, for real BoringSSL and Tcl macros and inline functions.
Each has a hand-supplied signature, because a macro has none:

```c
void *botlish_thunk(Tcl_HashEntry *h) { return Tcl_GetHashValue(h); }
```

Each sample states what the census predicts (compiles, is rejected, or
compiles to something else), and each is compiled with `-Wall -Wextra` by
GCC and by Clang. All 30 outcomes match the prediction on both compilers
(`results/thunks.txt`). The [macro report](#macro-report-items-31-40) uses
them.

## Specimens

Real IR, abbreviated only by dropping `attrs {}`, `fnspec {}` and `text`
where they add nothing (item 110; `tools/query.tcl PROFILE show NAME`
prints any record).

**Simple function** (BoringSSL `ssl.h`). The `OPENSSL_EXPORT` that preceded
it in the source is gone; `srcmacros` remembers only that it was there:

```
function SSL_new {
    loc {include/openssl/ssl.h 96 96}
    origin public
    storage none
    inline 0
    definition 0
    type {fn {ptr {typedef SSL}} {{ctx {ptr {typedef SSL_CTX}} {}}} {}}
    srcmacros OPENSSL_EXPORT
    text {SSL *SSL_new(SSL_CTX *ctx);}
}
```

**Opaque handle**: the tag is never completed in the translation unit.

```
typedef SSL {
    loc {include/openssl/base.h 347 347}
    origin public
    type {struct ssl_st}
    text {typedef struct ssl_st SSL;}
}
typedef Tcl_Channel {                                 # Tcl's dialect: the pointer is in the typedef
    type {ptr {struct Tcl_Channel_}}
    text {typedef struct Tcl_Channel_ *Tcl_Channel;}
}
```

**Typedef chain** (`::cir::resolve`, `query.tcl PROFILE chain NAME`):

```
CBS_ASN1_TAG -> uint32_t -> __uint32_t -> unsigned int        (BoringSSL bytestring.h)
Tcl_Size -> ptrdiff_t -> long                                  (tcl.h)
mp_digit -> uint64_t -> __uint64_t -> unsigned long            (tommath.h; size_t under TCL_NO_TOMMATH_H)
```

**Complete struct with a fixed array field**:

```
struct Tcl_DString {
    loc {generic/tcl.h 877 887}
    kind struct
    complete 1
    fields {
        {string {ptr {int char}} {} {}}
        {length {typedef Tcl_Size} {} {}}
        {spaceAvl {typedef Tcl_Size} {} {}}
        {staticSpace {array {int char} {lit 200}} {} {}}
    }
    srcmacros TCL_DSTRING_STATIC_SIZE
}
struct sha256_state_st {                              # BoringSSL sha2.h
    fields {
        {h {array {typedef uint32_t} {lit 8}} {} {}}
        {Nl {typedef uint32_t} {} {}}
        {Nh {typedef uint32_t} {} {}}
        {data {array {typedef uint8_t} {lit 64}} {} {}}
        {num {int {unsigned int}} {} {}}
        {md_len {int {unsigned int}} {} {}}
    }
    srcmacros SHA256_CBLOCK
}
```

The bound `200` was `TCL_DSTRING_STATIC_SIZE` in the source; the name is
gone and only `srcmacros` hints at it.

**Callback typedef**, in Tcl's function-*type* dialect (`Tcl_ObjCmdProc *`
is the pointer):

```
typedef Tcl_ObjCmdProc {
    loc {generic/tcl.h 584 585}
    type {fn {int int} {{clientData {ptr void} {}} {interp {ptr {typedef Tcl_Interp}} {}}
          {objc {int int} {}} {objv {ptr {q const {ptr {struct Tcl_Obj}}}} {}}} {}}
    text {typedef int (Tcl_ObjCmdProc) (void *clientData, Tcl_Interp *interp, int objc, struct Tcl_Obj *const *objv);}
}
```

**Function accepting a callback** (BoringSSL, an inline function-pointer
parameter):

```
function SSL_CTX_set_verify {
    type {fn void {{ctx {ptr {typedef SSL_CTX}} {}} {mode {int int} {}}
          {callback {ptr {fn {int int} {{ok {int int} {}} {store_ctx {ptr {typedef X509_STORE_CTX}} {}}} {}}} {}}} {}}
    text {void SSL_CTX_set_verify(SSL_CTX *ctx, int mode, int (*callback) (int ok, X509_STORE_CTX *store_ctx));}
}
```

**A function returning a function pointer**, the declarator shape usually
feared:

```
text {int (*BIO_meth_get_write(const BIO_METHOD *method)) (BIO *, const char *, int);}
type {fn {ptr {fn {int int} {{{} {ptr {typedef BIO}} {}} {{} {ptr {q const {int char}}} {}} {{} {int int} {}}} {}}}
      {{method {ptr {q const {typedef BIO_METHOD}}} {}}} {}}
```

**Problematic declarations.** Neither library has one the parser cannot
read, so the specimens are the corpus's ABI shapes
(`audit/c-header/unsupported/`):

```c
/* category:    ATTRIBUTE-UNSUPPORTED      shape: attribute mode           tcl, libtommath/tommath.h:80 */
typedef unsigned long private_mp_word __attribute__((mode(TI)));
/* category:    POSSIBLE-THUNK-REQUIRED    shape: inline definition, generated by DEFINE_STACK_OF
   occurrences: boringssl-static 729 */
static inline __attribute__((unused)) void sk_void_call_free_func(OPENSSL_sk_free_func free_func, void *ptr) { ... }
/* category:    ABI-INFORMATION-REQUIRED   shape: va_list param */
int BIO_vsnprintf(char *buf, size_t n, const char *format, va_list args) __attribute__((__format__(__printf__, 3, 0)));
```

## BoringSSL census (items 1-20)

`audit/c-header/results/boringssl-static/census.txt` has every count;
this section reads it.

1. **Revision.** Tag `0.20260929.0`, commit
   `427ec40cc8edc545253289232e885708c409e5ea` (2026-09-29).
2. **Entry headers.** 98: the 93 crypto and 5 ssl public headers of
   `gen/sources.json`, in one translation unit. All 100 headers of
   `include/openssl` also preprocess and compile alone as C.
3. **Preprocessing profile.** `cc -E -x c -I$SRC/include entry.c`, GCC
   13.3.0, gnu17, x86-64 Linux, no defines. The output is 18,300 lines and
   91,500 tokens, in 0.07 s.
4. **Functions.** 3,926: **3,109 declared** (with a link symbol) and **817
   `static inline` definitions**, which have none. 729 of the inline
   functions are generated by `DEFINE_STACK_OF`, 54 by
   `DEFINE_CONST_STACK_OF`, 27 by `DEFINE_NAMED_STACK_OF`, and 7 are
   written directly (`ERR_GET_LIB`, `CBS_init`, `CBS_data`, ...).
5. **Typedefs.** 344. 145 function pointers, 95 complete structs, 79 opaque
   structs, 7 function types, 5 `void` (`typedef void PKCS7_ENVELOPE;`,
   deprecated placeholders), 6 integer (3 of them through a system
   typedef), 3 aliases of other typedefs, and one each of array, enum,
   `char *` and `void *`.
6. **Complete structs.** 100 structs and 23 unions. 28 are anonymous and
   23 are defined inside another struct. 21 carry a keep-out comment
   (private, opaque, internal, do not), a heuristic that is not in the IR.
7. **Opaque structs.** 103 tags are declared or referenced and defined
   nowhere in the translation unit (`ssl_st`, `x509_st`, `evp_pkey_st`,
   ...). 79 typedefs name one directly.
8. **Unions.** 23. 22 are anonymous members of structs; 1 is tagged
   (`evp_aead_ctx_st_state`). 16 are opaque storage: a byte array beside
   one `alignment` scalar.
9. **Enums.** 14 (12 tagged, 2 anonymous) with 95 enumerators: 62
   implicit, 30 literal, 2 negated literals, 1 a reference to an earlier
   enumerator. The parser computes all 95 without an expression evaluator.
   8 enum types appear in function signatures (15 parameters, 6 results).
10. **Callbacks and function pointers.** 145 function-pointer typedefs and
    7 function-type typedefs. 451 functions take a callback (151 declared,
    300 inline); 52 return one (22 declared, 30 inline). 38 struct fields
    are function pointers. There are 89 distinct callback signature
    shapes; the most common is `(char *, int, int, void *) -> int`, the
    PEM password callback, 64 times.
11. **Variadic functions.** 5: `ERR_add_error_data`, `ERR_add_error_dataf`,
    `BIO_printf`, `BIO_snprintf` and `OPENSSL_asprintf`. Two more take a
    `va_list` (`BIO_vsnprintf`, `OPENSSL_vasprintf`).
12. **Pointer-to-pointer uses.** 367 declared functions; 478 parameter
    positions of depth 2 (char 236, opaque struct 155, complete struct 82).
    The maximum depth is 2.
13. **Fixed arrays.** 32 struct fields and 17 union fields; 142 array
    *parameter* spellings with literal bounds (`uint8_t out[32]`, kept in
    the IR, not adjusted to pointers). 17 field bounds and 4 parameter
    bounds are expressions (`(32 + 64 + 256 * 4 * 6) + ...`), 3 of them
    involving `sizeof`. One
    array is multidimensional (`DES_key_schedule`'s `uint32_t
    subkeys[16][2]`).
14. **Bitfields.** 3 one-bit fields in `cbb_buffer_st` and `cbb_child_st`.
15. **Float/double uses.** 1 function (`RAND_add(..., double entropy)`)
    and 1 callback field (`rand_meth_st.add`).
16. **By-value aggregate calls.** **None.** No declared or inline function
    takes or returns a struct or union by value.
17. **Unsupported declarations.** 0 parse failures, in the library and in
    the 485 glibc records it includes.
18. **Macro API categories.** 6,668 macros (181 function-like). Object-like:
    2,867 integer literals, 1,404 string literals (the `SN_`/`LN_` object
    names), 1,778 comma lists (`OBJ_rsadsi` is `1L, 2L, 840L, 113549L`),
    123 integer expressions, 33 aliases of enumerators, 78 aliases of
    functions, 58 aliases of nothing (52 of them deliberate poison:
    `#define SSL_CTRL_SET_TMP_DH doesnt_exist`), 80 include guards, 57 `OPENSSL_NO_*`
    flags and 2 constants needing `sizeof`. Function-like: 55 renames, 21
    call wrappers with computed arguments, 29 declaration and definition
    generators, 24 ASN.1 initializer fragments, 21 statements, 19
    expressions and 1 type producer (`STACK_OF`); 80 paste an argument and
    37 stringify one
    ([macro report](#macro-report-items-31-40)).
19. **Declaration and type macros.** `OPENSSL_EXPORT` was written on the
    lines of 3,102 declarations and is gone after preprocessing (empty for a
    consumer on every Linux profile). `STACK_OF(T)` was written in 110
    declarations and became `struct stack_st_T`. The stack macros wrote
    964 declarations: 27 `DEFINE_STACK_OF` instantiations of 32 records
    each, plus `DEFINE_CONST_STACK_OF`, `DEFINE_NAMED_STACK_OF` and
    `DECLARE_STACK_OF`. `DECLARE_ASN1_ITEM` wrote the 36 `extern const
    ASN1_ITEM X_it` objects.
    `OPENSSL_DEPRECATED` (10) and `OPENSSL_INLINE` (7) became attributes
    and `static inline`. 71 functions also have a self-named macro (`#define
    DTLSv1_get_timeout DTLSv1_get_timeout`) so that `#ifdef` feature tests
    from OpenSSL code keep working.
20. **Immediately representable simple-call subset.** 2,929 of 3,109
    declared functions (94.2%). The rest: 472 take a callback, 5 are
    variadic, 2 take a `va_list`, 1 takes a `double`. Of the 2,929, 21 use
    an enum type and need its width from the ABI probe.

## Tcl census (items 1-20)

From `results/tcl-embed/census.txt` unless a profile is named.

1. **Revision.** Tag `core-9-0-1`, commit
   `6230a12b3bf6f7d8128f6ef14b0a3650a9d479e0` (2024-12-19).
2. **Entry headers.** `tcl.h`, `tclOO.h`, `tclTomMath.h`; public means the
   7 installed headers; `libtommath/tommath.h` is bundled.
3. **Preprocessing profile.** `cc -E -x c -I$SRC/generic -I$SRC/unix
   -I$SRC/libtommath entry.c` with no defines (tcl-embed), or with
   `USE_TCL_STUBS` (tcl-stubs, the normal extension build). The output is
   5,773 lines and 38,103 tokens, in 0.03 s.
4. **Functions.** 920: 754 public (753 declared, 1 inline) and 166 bundled
   libtommath `mp_*` functions. The bundled functions are linked under
   other names (item 19).
5. **Typedefs.** 193 (182 public). The dominant category is the **function
   type** (112, `typedef int (Tcl_CmdProc)(...)`), then complete structs
   (34), pointers to opaque structs (26, `typedef struct Tcl_Channel_
   *Tcl_Channel`) and integers (10 + 2 through `ptrdiff_t`/`uint64_t`).
6. **Complete structs.** 37 structs (36 public plus `mp_int`) and 2 unions;
   9 are anonymous and 4 nested. 7 carry a keep-out comment (heuristic).
   The largest is `TclStubs`: 5,544 bytes, 693 fields, 691 of them
   function pointers.
7. **Opaque structs.** 30, including `struct stat`: `typedef struct stat
   Tcl_StatBuf;` names a system struct the translation unit never
   completes, because `tcl.h` does not include `sys/stat.h`.
8. **Unions.** 2: `Tcl_ObjInternalRep` (tagged, by value in `Tcl_Obj`, with
   a `double` member), and the anonymous key union of `Tcl_HashEntry`.
9. **Enums.** 5 with 13 enumerators (7 literal, 6 implicit, all computed).
   2 enum types are results (`Tcl_GetPathType`, `Tcl_FSGetPathType`).
10. **Callbacks and function pointers.** 112 function-type typedefs and 0
    function-pointer typedefs. 52 functions take a callback and 15 return
    one (the `Tcl_ChannelXxxProc` accessors). 895 struct fields are
    function pointers: 811 in the four stub tables and 84 in
    `Tcl_ChannelType`, `Tcl_ObjType`, `Tcl_Filesystem`, ...
11. **Variadic functions.** 11 (7 public: `Tcl_Panic`, `Tcl_AppendResult`,
    `Tcl_AppendStringsToObj`, `Tcl_SetErrorCode`, `Tcl_VarEval`,
    `Tcl_ObjPrintf`, `Tcl_AppendPrintfToObj`; 4 libtommath `*_multi`).
    There are no `va_list` parameters in the public headers. One callback
    type is variadic (`Tcl_PanicProc`).
12. **Pointer-to-pointer uses.** 68 declared functions; 72 parameters of
    depth 2 and 11 of depth 3 (`Tcl_Obj ***objvPtr`, `const char
    ***argvPtr`). The maximum depth is 3.
13. **Fixed arrays.** 5 fields with literal bounds: `Tcl_DString`
    `char[200]`, `Tcl_HashTable` `Tcl_HashEntry *[4]`, `Tcl_Parse`
    `Tcl_Token[20]`, and the hash key's `char[1]` and `int[1]` (the
    variable-length idiom of pre-C99 code). 17 parameters
    are spelled `const char *argv[]` (unknown length), 17 more inside
    callback types.
14. **Bitfields.** 0.
15. **Float/double uses.** 7 functions (`Tcl_NewDoubleObj`,
    `Tcl_GetDoubleFromObj`, ...) and 1 union field (`doubleValue`).
16. **By-value aggregate calls.** **None.**
17. **Unsupported declarations.** 0 (library and 284 glibc records).
18. **Macro API categories.** 508 macros under tcl-embed and 1,229 under
    tcl-stubs. The stubs build adds 761 `#define Tcl_X
    (tclStubsPtr->tcl_X)` entries. Object-like: 195 integer literals, 35
    integer expressions, 13 expressions with casts (`TCL_STATIC` is
    `((Tcl_FreeProc *) 0)`), 7 with `sizeof`, 7 strings, 81 function
    aliases (`Tcl_StaticPackage` is `Tcl_StaticLibrary`), 12 type
    spellings (`CONST86`, `TCL_HASH_TYPE`), 4 that select a function by
    `sizeof(wchar_t)` at compile time. Function-like (118): call wrappers
    (61 computed, 9 renames), member access (14: `Tcl_GetHashValue`,
    `Tcl_DStringValue`), statements (3: `Tcl_DecrRefCount`), the
    type-generic `Tcl_GetBooleanFromObj` family, and one declaration
    generator (`TCL_DECLARE_MUTEX`).
19. **Declaration and type macros.** `EXTERN` (698 declarations) and
    `TCLAPI` (35) became `extern`; so did `MODULE_SCOPE` (18) on this
    target; `MP_WUR` (196) became
    `__attribute__((warn_unused_result))`; `MP_DEPRECATED(x)` (44) became a
    deprecation attribute under GCC and **nothing under Clang**;
    `TCL_NORETURN` became `noreturn`. Type macros became their types:
    `TCL_HASH_TYPE` (15) is `size_t`, `TCL_WIDE_INT_TYPE` is `long long`,
    `Tcl_ExitProc` is `Tcl_FreeProc`. The bundled declarations are where
    macros matter most. tommath.h declares `mp_expt_d(const mp_int *,
    mp_digit, mp_int *)`, and tclTomMathDecls.h then defines `#define
    mp_expt_d TclBN_mp_expt_n`, so a call to `mp_expt_d` reaches a
    different function with a different parameter type. All 166 `mp_*`
    declarations are renamed this way, and libtcl exports only the
    `TclBN_*` names.
20. **Immediately representable simple-call subset.** 675 of 753 declared
    public functions (89.6%); 835 of 919 including the bundled ones. The
    rest of the public ones: 64 take a callback, 9 are variadic, 5 use a
    `double`. Under tcl-stubs the subset is the same set of signatures,
    but none of them is a link symbol an extension may use
    ([deep dive](#tcl)).

## Structural census (items 21-30)

21. **C type forms encountered.** In BoringSSL's API, by type-node count:
    pointers 8,936, library typedef references 5,443, function types 4,181,
    qualified types 3,394, system typedef references 2,501, `int` 2,461,
    `void` 1,356, struct references 1,122, `char` 361, arrays 197, `long`
    143, `unsigned int` 90, `unsigned long` 44, `unsigned char` 29, enum
    references 27, union references 23, `double` 2. Tcl: pointers 4,610,
    library typedef references 3,379, function types 1,846, `int` 1,158,
    qualified 1,105, `void` 847, `char` 671, system typedef references 125,
    struct references 101, arrays 46, `long long` 22, `double` 21, a few
    of every other integer type. Never encountered in either library: `_Bool`,
    `float`, `long double`, `_Complex`, `__int128`, `typeof`, `_Atomic`,
    `_BitInt`, block pointers, VLAs, K&R declarations (`()`), or a calling
    convention keyword. glibc adds `_Float*` names, `__builtin_va_list`
    and asm labels.
22. **Maximum pointer depth.** BoringSSL 2, Tcl 3 (as spelled and with
    typedefs resolved). A typedef hides a pointer level in 399 BoringSSL
    and 215 Tcl positions (`Tcl_Channel *` is a pointer to a pointer).
23. **Qualifier counts.** `const` only: BoringSSL 3,394 qualified nodes, of
    which 2,549 are pointee-`const` in parameters, 157 at level 2, 305 in
    results, 36 top-level on objects and 5 top-level on parameters. Tcl:
    1,105 nodes (538 pointee-`const` parameters). `volatile`, `restrict`,
    `_Atomic` and nullability qualifiers: **0** in both libraries (glibc
    uses `__restrict` 164 times).
24. **Typedef-chain depth.** For library typedefs: BoringSSL 338 of length
    1, 4 of length 2 and 2 of length 3 (`CBS_ASN1_TAG -> uint32_t ->
    __uint32_t`); Tcl 190, 2 and 1. A chain longer than one goes through
    glibc's `<stdint.h>`/`<stddef.h>` names, except `_STACK ->
    OPENSSL_STACK` and `bio_info_cb -> BIO_info_cb`.
25. **Struct-field categories.** BoringSSL: 123 pointers, 57 typedef
    scalars, 53 integer scalars, 38 function pointers, 32 fixed arrays, 21
    unions by value, 8 nested structs by value, 3 bitfields, 2 anonymous
    union members; union fields: 47 pointers, 17 fixed arrays, 17 scalars,
    2 structs. Tcl: 895 function pointers (811 stub-table entries), 75
    pointers, 30 typedef scalars, 24 integer scalars, 3 fixed arrays, 2
    unions by value; union fields: 3 pointers, 3 structs, 2 arrays, 1
    `double`, 2 scalars.
26. **Array categories.** Fixed-size field arrays (BoringSSL 32 + 17 in
    unions, Tcl 5); parameter array spellings (BoringSSL 142 literal
    `uint8_t[N]` plus 4 expressions; Tcl 17 unknown-length `argv[]`);
    unknown-length arrays only in Tcl's `argv[]` and one tommath object
    (`TclBN_mp_s_rmap_reverse[]`); no flexible array member in either
    library; one multidimensional array; 21 expression bounds (17 field,
    4 parameter; BoringSSL only). Element types: bytes and `char` (most), `uint32_t`, pointers,
    one struct (`Tcl_Token[20]`).
27. **Callback signature categories.** 89 shapes in BoringSSL and 328 in
    Tcl (counting the stub tables, which spell the whole API as function
    pointers). The common ones are destructors `(T *) -> void`,
    comparators `(T **, T **) -> int`, `(void *) -> void` and `(void *) ->
    void *`, and in Tcl `(void *clientData, Tcl_Interp *, ...) -> int`.
    Outside the stub tables, callback arguments are pointers and integers,
    except one `double` (`rand_meth_st.add`). None takes or returns an
    aggregate by value, and one (`Tcl_PanicProc`) is variadic.
28. **Enum-expression categories.** None in either library: every value is
    implicit, a literal, a negated literal or a reference to an earlier
    enumerator. Both libraries put their computed constants in macros
    instead (BoringSSL 123 integer expressions, Tcl 35 + 13 with casts + 11
    with `sizeof`).
29. **Attributes and extensions encountered.** In the libraries'
    declarations: `unused` (BoringSSL 817, on the inline functions),
    `warn_unused_result` (Tcl 242), `deprecated` (10 / 44), `format` (6 /
    6), `noreturn` (Tcl 7), `sentinel` (Tcl 2), `mode(TI)` (Tcl 1) and
    `__extension__`. In glibc: `nothrow`, `leaf`, `nonnull`, `malloc`,
    `pure`, `const`, `access`, `alloc_size`, `alloc_align`, `cold`,
    `aligned`, `mode`, asm labels (`fscanf` links as `__isoc99_fscanf`) and
    `__extension__`. Only `mode` and `aligned` affect the ABI, and only
    `mode` appears in a library header.
30. **Declaration forms the parser needed.** Function prototypes; function
    definitions (inline, body skipped); typedefs of every type form;
    struct, union and enum definitions, including nested, anonymous and
    anonymous-member ones; forward tag declarations; `extern` objects;
    multiple declarators per declaration (`extern int KARATSUBA_MUL_CUTOFF,
    KARATSUBA_SQR_CUTOFF, ...`); bitfields including `int : 0`; attributes
    in seven positions; asm labels; `__extension__`; pragmas. Not needed in
    either library: K&R definitions, `_Static_assert` at file scope (glibc
    only), file-scope `asm`, `typeof`, `_Atomic`.

## Macro report (items 31-40)

31. **Declaration macros erased by preprocessing.** All of them.
    `OPENSSL_EXPORT` (3,102 declarations: empty for a consumer on Linux,
    whether static or `BORINGSSL_SHARED_LIBRARY`; the header source shows
    it would be `__declspec(dllimport)` on Windows). `EXTERN`/`TCLAPI`
    (733: `extern`), `MODULE_SCOPE` (18), `MP_WUR` (196),
    `MP_DEPRECATED` (44), `TCL_NORETURN`/`TCL_NORETURN1` (6),
    `TCL_FORMAT_PRINTF`/`OPENSSL_PRINTF_FORMAT_FUNC` (11),
    `OPENSSL_DEPRECATED` (10), `OPENSSL_INLINE` (7). None of these has to
    be understood: what survives is a standard keyword or a GNU attribute
    whose effect is diagnostic, apart from `noreturn`.
32. **Type macros erased.** All of them, cleanly. `STACK_OF(T)` became
    `struct stack_st_T` in 110 declarations. `TCL_HASH_TYPE` became
    `size_t` (15), `TCL_WIDE_INT_TYPE` `long long`, `CONST86` `const`,
    `Tcl_ExitProc` `Tcl_FreeProc` (an alias of a typedef that is a macro,
    not a typedef). Normal declaration parsing sufficed for every one. API
    identity was lost in one way: a macro *name* that appears in the
    declaration (`STACK_OF(X509)` as a type, `TCL_DSTRING_STATIC_SIZE` as
    a bound) leaves only its expansion. The FFI would care for array
    bounds (a named constant documents a size) and not for the rest.
33. **Declaration-generating macros.** They behave as hoped. Each
    invocation's declarations are in the preprocessed output as ordinary
    declarations on the invocation line: `DEFINE_STACK_OF(X509)` gives 4
    function-pointer typedefs, a forward tag and 27 inline functions;
    `DECLARE_ASN1_ITEM(X)` gives an `extern const ASN1_ITEM X_it;`. The
    importer should import those declarations and never expose the macro.
    The thunk prototype confirms that the macro itself cannot be a wrapper
    body (GCC: "invalid storage class for function", Clang: "function
    definition is not allowed here"). One caveat: most of the
    declarations BoringSSL generates are `static inline` definitions, so they need a
    thunk or a reimplementation (item 37).
34. **Public value macros.** BoringSSL: 2,867 integer literals, 1,404
    string literals, 123 integer expressions, 33 enumerator aliases, 2 with
    `sizeof` (`DES_KEY_SZ` is `sizeof(DES_cblock)`) and 1,778 comma lists.
    Tcl: 195 literals, 35 integer expressions, 13 with casts, 7 with
    `sizeof` (`TCL_STUB_MAGIC` is `((int) 0xFCA3BACB + (int) sizeof (void
    *))`), 7 strings and 3 braced initializers (`TCL_ARGV_TABLE_END`). The
    ABI probe evaluated the integer-constant macros (2,992 and 250, all but
    the enumerator aliases) by compiling `(long long)(NAME)`. Literal-only
    handling covers 2,867 of 3,025 BoringSSL integer constants (95%) and
    195 of 250 Tcl ones (78%).
35. **Public function-like macros.** BoringSSL 181, Tcl 118 (embed) or 127
    (stubs). By category: renames (55 / 9), call wrappers with computed
    arguments (21 / 61: `BN_mod(rem, a, m, ctx)` is `BN_div(NULL, ...)`,
    `Tcl_Main` adds `Tcl_SetPanicProc`/`Tcl_CreateInterp`), expressions and
    member access (`ERR_PACK`, `Tcl_GetHashValue`, `Tcl_IsShared`),
    statements (`Tcl_DecrRefCount`, `BSSL_CHECK`), declaration and
    definition generators (29 / 1), initializer fragments (24 ASN.1
    template macros, BoringSSL only), and type producers (`STACK_OF`).
    Argument flags, measured through the probe: 80 BoringSSL macros paste
    an argument, 37 stringify, 31 evaluate one more than once and 29 use
    one as a type; Tcl: 3 stringify, 12 evaluate one more than once, 5 are
    type-generic and 3 contain a compile-time assertion.
36. **Tested thunk candidates.** 30 samples (`results/thunks.txt`), all as
    predicted on GCC and Clang. Compiled cleanly: `Tcl_IncrRefCount`,
    `Tcl_DecrRefCount` (a do-while with a local), `Tcl_IsShared`,
    `Tcl_GetHashValue`, `Tcl_SetHashValue`, `Tcl_FindHashEntry` (a call
    through a function pointer in the struct, its argument evaluated
    twice: a thunk evaluates it once), `Tcl_DStringValue`, `Tcl_Main`,
    `mp_iszero`, `Tcl_CreateObjCommand` and `Tcl_InitStubs` under stubs,
    `BIO_get_app_data`, `BN_mod`, `ERR_PACK`, `BSSL_CHECK`, `CHECKED_CAST`
    (one wrapper per type pair), `OPENSSL_PUT_ERROR(SSL, reason)` and
    `ASN1_ITEM_ref(ASN1_INTEGER)` (one wrapper per identifier argument),
    and the inline functions `sk_X509_num`, `sk_X509_pop_free` (with a
    callback) and `ERR_GET_LIB`. The type-generic `Tcl_GetBooleanFromObj`
    compiles for `int *` and for `char *`, which reach two *different*
    library functions, and is rejected for `long long *` by the macro's own
    static assertion.
37. **Thunkable categories.** Expressions over value arguments, member
    reads (an lvalue needs a second wrapper to write), side-effecting
    expressions, statements (as a void wrapper), call wrappers with
    computed arguments, stub-table entries (the same-named declaration
    supplies the signature), type-generic macros (one wrapper per
    signature), and `static inline` functions (the declaration *is* the
    signature). For macros whose arguments are pasted or stringified, there
    is one wrapper per identifier argument, and `__FILE__`/`__LINE__`
    become the wrapper's (4 BoringSSL macros: `OPENSSL_PUT_ERROR`,
    `OPENSSL_PUT_SYSTEM_ERROR`, `EVPerr`, `SSLerr`). A thunk needs from its declaration: the macro, the
    C parameter and result types, and for paste/stringify macros the fixed
    identifier arguments.
38. **Non-thunkable or problematic categories.** Declaration generators
    (import what they generate); type producers (a type, resolved at each
    use); initializer fragments and comma lists. `return OBJ_rsadsi;`
    **compiles without a warning** on both compilers and returns 113549,
    the last arc, through the comma operator: silently wrong, not
    rejected. Also: macros whose arguments must be literals
    (`OPENSSL_GNUC_CLANG_PRAGMA`: the probe itself was rejected with
    identifiers), poison macros that name nothing (52 BoringSSL `#define
    SSL_CTRL_X doesnt_exist`, among 58 aliases of undeclared names),
    lvalue macros as assignment targets, and
    location-sensitive macros where the caller's location matters.
39. **Is macro provenance necessary?** No. The oracle validates the
    declarations without it. `-dD` gives every macro's file and line. The
    expansion probe gives every macro's meaning in the profile, computed by
    the compiler. Source-line co-occurrence (`srcmacros`) tells which
    declarations a macro decorated (`OPENSSL_EXPORT` 3,102 times) without
    tracking any expansion. Two facts it cannot recover are a named array
    bound and a function name that a macro aliases at use sites. Both
    concern the macro layer, not the declaration, and both are visible in
    the macro records.
40. **Concrete examples.** `#define Tcl_IsShared(objPtr)
    ((objPtr)->refCount > 1)` (member access: thunk yes);
    `#define Tcl_DecrRefCount(objPtr) do { Tcl_Obj *_objPtr = (objPtr); if
    (_objPtr->refCount-- <= 1) { TclFreeObj(_objPtr); } } while(0)`
    (statement with a local: void thunk); `#define
    OPENSSL_PUT_ERROR(library, reason) ERR_put_error(ERR_LIB_##library, 0,
    reason, __FILE__, __LINE__)` (paste and location: per identifier);
    `#define STACK_OF(type) struct stack_st_##type` (a type);
    `#define Tcl_GetBooleanFromObj(interp, objPtr, boolPtr)
    ((sizeof(*(boolPtr)) == sizeof(int) && ...) ? Tcl_GetBooleanFromObj(...)
    : (... ? Tcl_GetBoolFromObj(...) : (TCLBOOLWARNING(boolPtr) ...)))` (a
    shadowing, type-generic macro dispatching on `sizeof`, with a compile-
    time assertion built from `sizeof(struct { _Static_assert(...); })`);
    `#define Tcl_WCharToUtfDString (sizeof(wchar_t) != sizeof(short) ?
    (char *(*)(...))Tcl_UniCharToUtfDString : (...)Tcl_Char16ToUtfDString)`
    (an object-like macro choosing a function by an ABI fact);
    `#define Tcl_CreateObjCommand (tclStubsPtr->tcl_CreateObjCommand)` (a
    stub-table entry).

## Layout report (items 41-50)

41. **Public complete structs.** BoringSSL 100 and Tcl 35 (top-level or
    named, anonymous nested members counted inside their parents). Only 32
    BoringSSL and 5 Tcl structs are used by value anywhere (as a field or
    an object); every other complete struct is used only behind pointers
    (87 / 33). Its layout matters only to a consumer that allocates it or
    reads its fields.
42. **REPRESENTABLE-NOW.** 3: `openssl_method_common_st`,
    `Tcl_RegExpIndices` and `Tcl_Time`. All three are generated by the ABI
    probe and accepted by Botlish's `layout` (`results/*/layouts.bot`).
43. **NEEDS-POINTER-SCALAR.** BoringSSL 68, Tcl 33.
44. **NEEDS-FIXED-ARRAY.** BoringSSL 39, Tcl 4.
45. **NEEDS-FLOAT.** BoringSSL 0, Tcl 2 (`Tcl_Obj` and its internal-rep
    union, through `double doubleValue`).
46. **NEEDS-UNION.** BoringSSL 26, Tcl 3.
47. **NEEDS-BITFIELD.** BoringSSL 3 (`cbb_st` and its two members), Tcl 0.
48. **NEEDS-OTHER.** 0 in both: no `_Bool`, flexible array, `__int128` or
    incomplete member in a public complete struct. Enum fields add an ABI
    fact (the enum's width), not a layout feature. A plain `char` field
    adds another (its signedness: 6 BoringSSL and 2 Tcl structs).
49. **Combinations.** BoringSSL: pointer only 52, array only 15, array +
    union 16, pointer + union 5, array + pointer 4, all three 4,
    bitfield + pointer 2, bitfield + pointer + union 1, representable 1.
    Tcl: pointer only 27, array + pointer 3, float + pointer + union 2, all
    three without float 1, representable 2. **14 of BoringSSL's 16 array +
    union structs are storage only.** `MLDSA65_private_key`,
    `MLKEM768_public_key`, `XWING_private_key` and the rest are `struct {
    union { uint8_t bytes[N]; uint32_t alignment; } opaque; }`: complete
    only so that a consumer can allocate them, never to be read. They need
    size and alignment, which today's layout can already state, not arrays
    or unions.
50. **Priority recommendation for binary-layout extensions**, by structs
    unlocked:
    1. **an opaque pointer-width scalar**: 52 + 27 structs on its own, and
       the precondition of most of the rest (68 of BoringSSL's 99 and all
       33 of Tcl's unrepresentable structs need it);
    2. **fixed repetition of a scalar or pointer** (`T[N]`, mostly bytes):
       15 more BoringSSL structs alone, 4 + 3 with pointers;
    3. **size-and-alignment-only storage** (a layout with no fields, or one
       byte-array field): covers the 14 storage-only structs without unions;
    4. **overlays (unions)**: 6 BoringSSL tagged-choice structs
       (`asn1_type_st`, `GENERAL_NAME_st`, `DIST_POINT_NAME_st`,
       `POLICYQUALINFO_st`, `PKCS7`, `cbb_st`), 5 private contexts that
       embed hash or storage state (`sha_state_st`, `env_md_ctx_st`,
       `hmac_ctx_st`, `evp_hpke_ctx_st`, `evp_aead_ctx_st`), and Tcl's
       `Tcl_Obj` and `Tcl_HashEntry`, all behind pointers in every
       function;
    5. **float/double fields**: Tcl's `Tcl_ObjInternalRep` only;
    6. **bitfields**: three one-bit flags in `CBB`, a struct BoringSSL
       documents as private and that consumers only allocate. A storage
       unit plus ordinary bit operations, or an accessor thunk, suffices;
       no early bitfield import is justified.

## ABI report (items 51-60)

51. **Facts available from declaration parsing.** Every type's structure:
    pointer depth and pointee, qualifiers, typedef identity and chain,
    array bounds when literal, function signatures, variadic flags,
    field order and names, bitfield widths, enumerator values (all of
    them, in both libraries), struct completeness (opaque or not),
    storage and inline-ness (whether there is a link symbol at all), asm
    labels, surviving attributes and pragmas.
52. **Facts that need the compiler.** Struct sizes, alignments and field
    offsets; scalar widths (`long` is 8 bytes here and 4 on Windows x86-64);
    `char` signedness; enum storage (GCC uses 4 bytes, unsigned unless an
    enumerator is negative: 12 of the 13 probed BoringSSL enums are
    unsigned); the
    value of an expression bound or a `sizeof` constant; the type a
    `mode(TI)` attribute produces; `wchar_t` width (Tcl selects functions
    by it); the link name under `#pragma redefine_extname` when the
    pragma's argument is a macro (item 59); the user label prefix
    (`__USER_LABEL_PREFIX__`, empty here, `_` on Apple targets).
53. **Minimum ABI-probe wishlist.** `sizeof`, `alignof` and signedness of
    a type; `offsetof` and `sizeof` of a field; the value of an integer
    constant expression (enumerators, macros, bounds); the link name of a
    declared function (after asm labels and pragmas); the storage of an
    enum. Calling-convention queries are not needed for either library on
    this target. All but the link name were answered by one generated,
    compiled and executed C program per profile, in under a second.
54. **Native-only prototype feasibility.** Proven for both libraries: 3,559
    and 1,361 facts, and Botlish layouts generated from them that compile.
    A probe that runs needs a host target. A cross probe would have to read
    the facts from an object file (`_Static_assert` bisection, or data
    emitted into a section) instead of running it.
55. **Cross-target issues observed.** Cross preprocessing failed for want
    of target system headers: Clang with
    `--target=aarch64-linux-gnu`/`i686-linux-gnu`/`x86_64-apple-darwin`
    stops at glibc's `bits/libc-header-start.h`, and with
    `x86_64-pc-windows-msvc`/`x86_64-w64-mingw32` at `stdlib.h`. GCC
    `-m32` lacks multilib headers. Both libraries' public headers include
    system headers unconditionally, so even preprocessing a header set for
    another target needs that target's libc headers.
56. **Calling-convention issues.** None observed: no calling-convention
    keyword or attribute survives in either library on x86-64 Linux. The
    headers' sources show none on Windows either: BoringSSL uses
    `__declspec(dllimport)` only for shared builds, and Tcl's `TCLAPI`
    defaults to `extern`.
57. **By-value aggregate ABI issues.** None, because neither API passes or
    returns an aggregate by value (items 16 above). The x86-64 SysV and
    Win64 classification rules can be deferred.
58. **Enum ABI issues.** Enum types appear in 21 BoringSSL and 2 Tcl
    function signatures and in struct fields. Their storage is
    implementation-defined (4 bytes and unsigned under GCC here), so an
    enum-typed parameter needs the probe. BoringSSL's C++ consumers see
    `enum ssl_encryption_level_t : int` (`BORINGSSL_ENUM_INT`) and its C
    consumers do not: the library itself guarantees equal sizes by a unit
    test.
59. **Symbol-decoration issues observed.** Three:
    * glibc asm labels (`fscanf` links as `__isoc99_fscanf`), visible in
      the IR as `link`;
    * `BORINGSSL_PREFIX` under GCC: 3,149 `#pragma redefine_extname X
      bssl_X` lines survive preprocessing with the target name expanded.
      Under **Clang** the same pragmas are printed **unexpanded**
      (`redefine_extname X BORINGSSL_ADD_USER_LABEL_AND_PREFIX(X)`), so
      the link name is not in Clang's preprocessed text at all;
    * without the pragma (the MSVC branch, simulated): every one of the
      3,109 functions and 36 objects is renamed `bssl_X` in the
      declaration itself, and the source name survives only as a macro.
60. **What can safely remain deferred.** By-value aggregates, calling
    conventions, varargs, `long double`/`_Complex`/`__int128`, bitfield
    allocation, cross-target probing, and C++ (BoringSSL's `pki/`,
    `bssl::UniquePtr`).

## FFI type-system report (items 61-70)

Proposals only, each tied to counted declarations.

61. **Proposed minimal low-level FFI types.**
    * C integer scalars by identity: `char`, `signed char`, `unsigned
      char`, `short`, `int`, `long`, `long long` and unsigned forms,
      resolved to a width and signedness per target by the probe.
    * `C pointer to T`, with `T` any of the categories here, plus `void`.
    * Opaque struct identity: a tag never completed in the profile.
    * Function pointer: a C signature built from these categories.
    * Array of T: field arrays only; parameter arrays are pointers to call.
    * Resolved `LayoutStruct[L]`: complete structs a consumer reads or
      allocates.
    * Enum identity, carried as an integer scalar of probed width.
    * Typedef identity, nominal for the categories item 63 names.
62. **Evidence for each.** Integer scalars: every function. Pointers: 3,012
    of 3,109 BoringSSL and 884 of 919 Tcl functions. Opaque identity: 2,098
    and 405 functions, and 103 + 30 tags. Function pointers: 451 + 52
    functions and 145 + 112 typedefs. Arrays: 49 + 5 fields. LayoutStruct:
    the 3 representable structs now and the 52 + 27 that a pointer scalar
    alone unlocks. Enums: 21 + 2 signatures. Floats (`double`) are kept out of v1
    on this evidence: 1 + 7 functions.
63. **Typedef recommendation.** Distinguish by category, never always
    nominal and never always an alias.
    * *Nominal*: typedefs naming an opaque tag (`SSL`, 79) or a pointer to
      one (`Tcl_Channel`, 26). These are the object model's identity, and
      `Tcl_Channel` vs `Tcl_Command` is exactly the distinction a binding
      wants.
    * *Nominal*: callback typedefs (145 + 112), which name a protocol
      (`Tcl_ObjCmdProc`).
    * *Alias, keeping the name for documentation*: integer typedefs
      (`Tcl_Size`, `Tcl_WideInt`, `CBS_ASN1_TAG`, `BN_ULONG`, and system
      `size_t`/`uint8_t`). Their representation is all that crosses the
      boundary. They are few (6 + 12 library typedefs), but they appear in
      1,062 `size_t` uses.
    * *Alias*: typedefs of complete structs (95 + 34), since the tag is
      the identity.
    Why categories: `mp_digit` is `uint64_t` or `size_t` depending on
    `TCL_NO_TOMMATH_H`. That is the same representation under different
    typedef chains, so nominal integer typedefs would make one header
    configuration's types incompatible with another's for no gain.
64. **Pointer recommendation.** A typed pointee (the opaque struct, the
    scalar, the function signature), pointee `const` kept (2,549 + 538
    parameters say whether the callee writes through it), `void *` as its
    own case (421 + 106 parameters, and every userdata), and pointers to
    pointers as ordinary nesting (367 + 68 functions; depth at most 3).
    `restrict`, `volatile` and nullability have no evidence (0 uses), and
    top-level `const` on parameters (5) has no meaning to a caller.
65. **Opaque-struct recommendation.** Make it the first-class default: an
    opaque nominal handle type per incomplete tag, created only by the
    library. Use it whether the tag is complete elsewhere or not; it is
    exactly what 87 of BoringSSL's complete structs are to consumers too
    (only pointers to them appear).
66. **Callback recommendation.** The proposed initial restriction (a C
    function pointer is a statically exposed top-level Botlish function, no
    capture) covers every callback in both libraries. 57 of Tcl's 66 and
    226 of BoringSSL's 504 callback parameters already pass a `void *`
    userdata beside the callback and receive it inside, which an exposed
    function can use to find its context. Without anything more, the
    callbacks level reaches 3,092 of 3,109 BoringSSL and 899 of 919 Tcl
    functions. Outside it: callbacks that take callbacks (9 BoringSSL, 1
    Tcl), Tcl's variadic `Tcl_PanicProc`, and the varargs and `va_list`
    functions themselves.
67. **Array recommendation.** Arrays matter in struct fields only (item
    50). In parameters, an array spelling is a pointer to the caller (142
    `uint8_t out[32]` in BoringSSL): keep the bound in the IR as
    documentation, call through a pointer.
68. **Enum recommendation.** Import C enums as integer domains of the
    probed width, with named constants. Both libraries use enums as small
    sets of named integers (95 + 13 enumerators), mixed freely with int
    parameters and with macro constants (2,867 + 195 integer literals
    outnumber enumerators thirty to one). Values are always computable.
    Mapping them to Botlish's closed nominal `enum` would reject the values
    C code passes. A wrapper library can add one where the set is closed.
69. **Qualifier recommendation.** Keep pointee `const` per level. Ignore
    top-level `const`. Drop `restrict`/`volatile` until a header uses them
    (0 here).
70. **Varargs recommendation.** Postpone. 5 + 11 functions, all printf-
    style or `NULL`-terminated lists, each with a non-variadic sibling or an
    obvious wrapper (`BIO_write` + formatting in Botlish,
    `Tcl_AppendObjToObj`), and 2 `va_list` functions. Reject them in v1
    with a precise diagnostic.

## Toolchain report (items 71-80)

71. **Environment and configuration variables used.** `BOTLISH_C_CC`,
    `BOTLISH_C_CPP`, `BOTLISH_C_TARGET`, `BOTLISH_C_INCLUDE`,
    `BOTLISH_C_DEFINES`, `BOTLISH_C_UNDEFINES` and `BOTLISH_C_FLAGS` (the
    repository's `BOTLISH_<AREA>_<NAME>` convention).
    `BOTLISH_C_HEADER_SOURCES` locates the library sources (default
    `c-header-src/` under Botlish's cache directory).
72. **Default lookup.** The compiler is `BOTLISH_C_CC`, else the first of
    `cc`, `gcc`, `clang` on `PATH`. The preprocessor is `CC -E` unless
    `BOTLISH_C_CPP` names one. The family (gcc, clang, msvc, unknown) is
    detected from `--version`. Every profile records the toolchain path,
    its version line, the target (`native` or the triple), the host, the
    environment it ran with, the exact command (`$SRC` and `$TU` for the
    machine-specific paths) and the predefined facts that shape headers
    (`__STDC_VERSION__`, `__SIZEOF_*__`, `__CHAR_UNSIGNED__`,
    `__USER_LABEL_PREFIX__`, `__PRAGMA_REDEFINE_EXTNAME`, ...).
73. **Compiler-family assumptions.** All in the adapter: the GCC/Clang
    command shape (`-E -x c -I -D -U -dD -dM -c -o --target=`),
    `--version` as the identification, `-dD` for macro capture, and
    GCC-style line markers. MSVC is refused by name. `--target=` is
    Clang-only, since a GCC cross compiler is its own `BOTLISH_C_CC`.
74. **Preprocessing command shapes.** `CC -E -x c FLAGS -I... -D... -U...
    entry.c` (declarations), the same plus `-dD` (macros), `CC -dM -E -x c
    ... empty.c` (predefined macros), the same translation unit plus probe
    lines (macro expansions), `CC -x c ... -c probe.c -o probe.o`
    (oracle and thunks), and `CC -x c ... probe.c -o probe && ./probe`
    (ABI facts).
75. **Portability problems encountered.** Cross-target preprocessing
    needs the target's libc headers (item 55). Clang prints `#pragma
    redefine_extname` with its macro arguments unexpanded, while GCC
    expands them. GCC and Clang differ in `-dD` spacing (`a ##b` vs
    `a##b`). GCC reports an error in a macro body at the macro's
    definition, and attributes it to the use only in a following note. The
    headers' own compiler tests change the IR: tommath's `MP_DEPRECATED`
    needs GCC 4.5 (`__GNUC__ * 100 + __GNUC_MINOR__ >= 405`) and Clang
    claims GCC 4.2; BoringSSL emits two Clang-only diagnostic pragmas. Tcl 9
    no longer expands `~` in file names, which mattered for the default
    sources path.
76. **Toolchain adapter requirements.** Preprocess with include
    directories, defines and undefines; capture macro definitions with
    locations (or report that the family cannot, as MSVC cannot); report
    the compiler identity and the predefined macros; compile a probe and
    return diagnostics with locations; run a native probe, or extract facts
    from an object for a cross one. That is about 160 lines of Tcl here.
    The parser needed nothing from the adapter except line markers in the
    GCC format, which Clang also emits.
77. **Source-marker behavior.** Both compilers emit `# LINE "FILE" FLAGS`
    with flags 1 (enter), 2 (return), 3 (system header) and 4 (extern C),
    and resynchronize with blank lines or markers. A declaration expanded
    from a macro is located at the invocation line (all 32 records of
    `DEFINE_STACK_OF(X509)` share `x509.h:71`). That is exactly what
    `srcmacros` needs. Directives the preprocessor passes through
    (`#pragma`, `_Pragma` as `#pragma`) arrive on their own lines.
78. **Differences across configurations.** From `results/variants.txt`:
    * `BORINGSSL_SHARED_LIBRARY`: no difference on Linux.
    * `BORINGSSL_PREFIX`: +3,149 link-name pragmas under GCC, the same
      3,149 unexpanded under Clang, or every name renamed without the
      pragma.
    * `USE_TCL_STUBS`: identical declarations, +722 macros (+761 stub
      entries, some replacing embed macros).
    * `TCL_NO_TOMMATH_H`: -166 functions, -4 typedefs, -5 objects;
      `mp_digit` changes from `uint64_t` to `size_t`; 48 attributes
      disappear.
    * GCC vs Clang: Tcl loses 44 deprecation attributes; BoringSSL gains 2
      diagnostic pragmas.
    * `-std=c11` vs the default `gnu17`: only glibc's `struct tm` field
      names change (`tm_gmtoff` vs `__tm_gmtoff`). That struct is in
      BoringSSL's API (`OPENSSL_posix_to_tm`).
79. **Dependence on installed headers.** Both libraries' declarations use
    system types. BoringSSL: `size_t` (1,062 uses), `uint8_t` (1,045),
    `uint32_t`, `uint16_t`, `uint64_t`, `int64_t`, `time_t`, `FILE` (94:
    the `BIO_new_fp`/`PEM_read_*` family), `va_list`, and the complete
    system structs `struct tm` and `struct timeval`. Tcl: `size_t` (94),
    the fixed-width integers, `FILE` (2), and `struct stat` behind
    `Tcl_StatBuf`, which the translation unit never completes. Tcl's
    `tclTomMath.h` cannot even be preprocessed without libtommath's header
    or `TCL_NO_TOMMATH_H`. `results/PROFILE/system.txt` is the closure of
    system declarations each profile depends on (30 for BoringSSL, 21 for
    Tcl).
80. **Reproducibility limitations.** Revisions, entry sets, defines and
    commands are recorded and checked (`fetch.tcl` refuses a different
    commit). The system headers and the compiler are whatever the host has:
    the profile records the compiler version, but not the glibc version or
    the header contents, and system paths appear absolute in
    `system.txt`. The sources are fetched over the network. Timing differs
    run to run and is isolated in `timing.txt`.

## Parser report (items 81-90)

81. **Architecture.** A line-oriented regular-expression tokenizer, then a
    recursive-descent declaration parser over a token array, then a
    recursive type representation built by applying declarator
    derivations. A typedef set is the only symbol table.
    `results/parser-complexity.txt` has the measurements.
82. **Tcl LOC.** `cdecl.tcl`: 1,019 lines of code, 121 comment, 56 blank,
    46 procedures. By role: tokenizer 2, token access 8, records 8,
    grammar 17, grammar predicates 4, recovery 1, literals and tags 6. The
    rest of the instrument is larger: census 1,694, run 332, corpus 220,
    oracle 200, abiprobe 189, ir 183, query 161, toolchain 160, thunks
    105, diff 69, variants 50, macros 39.
83. **Supported declaration grammar.** External declarations as listed in
    item 30. Also recognized: 9 storage-class words, 5 function
    specifiers, 13 qualifiers in 19 spellings, 17 type keywords, 15 soft
    type names (`_Float32`, ..., `bool`: a keyword for GCC, a typedef glibc
    writes for Clang), 4 builtin type names, 11 calling conventions, GNU,
    MSVC and C23 attributes, `_Alignas`, asm labels, `typeof` and
    `_BitInt`.
84. **Supported type grammar.** The full C declarator grammar: pointers
    with qualifiers and attributes, nested declarators, arrays (literal,
    expression, empty, `*`, `static`, qualified), function suffixes
    (prototype, `(void)`, `()`, `...`), abstract declarators, and
    parenthesized names.
85. **Unsupported grammar.** Not needed and not attempted: K&R definitions
    (identifier lists), C++, Objective-C blocks beyond the pointer token,
    initializer *meaning* (kept as text), expression evaluation beyond
    integer and character literals, statement parsing (bodies are
    skipped), `#pragma pack` semantics (recorded, never applied: neither
    library uses it).
86. **Recovery behavior.** An `unsupported` record with category, reason,
    state and the declaration's text; skip to the next `;` at depth 0 or
    past a function body's `}`. Unknown type names are accepted as typedefs
    and flagged (`unknowntypes`: 0 in the corpus). Both are tested
    (`cd-recovery`, `cd-recovery-body`, `cd-unknown-type-name`).
87. **Fixture count.** `tests/parser.test` has 50 tests: real declarator
    shapes of the corpus, typedef chains, structs, unions, anonymous
    members, flexible arrays, enum value forms, attributes, asm labels,
    inline definitions, soft type keywords, line markers, pragmas,
    recovery, four perturbation tests (function vs function pointer,
    pointer qualifiers, array vs pointer, nested parentheses), and a
    render round trip. `tests/corpus.test` adds 22: every corpus fixture
    parses alone as its `expect:` line says and equals the committed IR.
88. **Real unsupported corpus count.** 21 distinct shapes (15 BoringSSL, 6
    Tcl) in `audit/c-header/unsupported/`, none a parse failure:
    `POSSIBLE-THUNK-REQUIRED` 5 (inline definitions by generator),
    `ABI-INFORMATION-REQUIRED` 9 (enum parameters and results, unions by
    value in structs, bitfields, `va_list`, `sizeof` bounds,
    `redefine_extname`), `CONSTANT-EXPRESSION-UNSUPPORTED` 3,
    `TYPE-SHAPE-UNSUPPORTED` 3 (variadic functions in both libraries, a
    variadic callback), `ATTRIBUTE-UNSUPPORTED` 1 (`mode`).
    `PREPROCESS-FAILURE` happened only outside the profiles (tclTomMath.h
    without libtommath, every cross target), and `LEXER-FAILURE`,
    `DECLARATION-PARSE-FAILURE` and `UNKNOWN` never.
89. **Parse success and failure counts.** 4,570 BoringSSL and 1,171 Tcl
    library records, and 485 and 284 glibc records, parsed with 0 failures
    in every profile and with both compilers' output. The oracle confirms
    the reading (section [The compiler oracle](#the-compiler-oracle)).
90. **Constructs responsible for most complexity.** In order:
    * the typedef-name ambiguity (when an identifier is a type, inside
      parentheses especially, and soft keywords);
    * attributes in seven positions, kept positionally;
    * declarator derivation order;
    * recovery;
    * line-marker bookkeeping.
    The only performance problem was quadratic string handling in text
    capture: the 11,383-token `TclStubs` definition alone took 2.2 s. With
    that fixed, the parser takes 1.2 s on BoringSSL's 91,500 tokens and
    0.47 s on Tcl's 38,103.

## Deep dives

### BoringSSL

*What declaration macros disappear cleanly?* All: `OPENSSL_EXPORT` (empty
on every Linux configuration), `OPENSSL_DEPRECATED`, `OPENSSL_INLINE`,
`OPENSSL_PRINTF_FORMAT_FUNC`, `BORINGSSL_ENUM_INT` (empty in C).
*What type macros?* `STACK_OF` (110 uses, a plain tag). *What public macros
remain useful API?* About 4,400 constants (2,867 integer, 1,404 string),
the OID arc lists, the `ERR_PACK`/`ERR_GET_*` error-code helpers, 78
compatibility aliases, and the `OPENSSL_PUT_ERROR` family (per library
name). *How opaque is the object model?* Very: 103 opaque tags, and 2,098
of 3,109 functions take or return one. Its complete structs are either
private implementation state that consumers only allocate (`EVP_MD_CTX`,
`SHA256_CTX`, the 14 storage-only key structs: the comments of 21 say so)
or ASN.1 templates for library implementors. *How callback-heavy?*
Moderately: 151 declared functions take callbacks, and 106 of their 174
callback parameters have a userdata pointer beside and inside; the stack
API's 300 inline functions take comparators and destructors. *What struct/layout support is needed?*
Little for calling: none, because every struct crosses the boundary behind
a pointer. Allocation needs size and alignment. Reading the few public
data structs (`asn1_type_st`, `GENERAL_NAME_st`) needs pointers, unions and
arrays. *What compiler extensions survive?* `__attribute__((unused))`,
`deprecated`, `format`; with `BORINGSSL_PREFIX`, `#pragma
redefine_extname`; with Clang, two diagnostic pragmas. *What is immediately
callable?* 2,929 functions (94% of the declared ones), 3,092 with static
callbacks. The 817 inline functions, the whole stack API, are callable only
through generated thunks or a Botlish reimplementation over `OPENSSL_sk_*`,
which are exported and in the simple subset.

### Tcl

*Handle and pointer patterns.* Two dialects: `typedef struct Tcl_Interp
Tcl_Interp` (used as `Tcl_Interp *`) and `typedef struct Tcl_Channel_
*Tcl_Channel` (the pointer hidden in the typedef: 26 handles). `Tcl_Obj` is
complete and public, and reading its fields is part of the API's macro
layer (`Tcl_IsShared`, `Tcl_IncrRefCount`). *Callbacks.* Uniform: a
function-type typedef per protocol (112), passed as `Proc *` beside a `void
*clientData` that the callback receives first (57 of 66). Structs of
callbacks (`Tcl_ChannelType`, `Tcl_ObjType`, `Tcl_Filesystem`) are filled in
by the extension, so the extension provides these function pointers rather
than calls them. *Typedef vocabulary.* `Tcl_Size` (`ptrdiff_t`),
`Tcl_WideInt` (`long long`), `ClientData`, and the `*Proc` family.
*Public complete structs.* 36, from `Tcl_Obj` and `Tcl_HashTable`
(allocated by extensions, read through macros) to the stub tables.
*Variadics.* 7 public, all formatting or `NULL`-terminated string lists.
*Macro APIs.* Reference counting, hash-table access, `Tcl_DString` access
and `Tcl_InitStubs` are macros with no function behind them; the thunk
prototype compiles wrappers for all of them. *Platform portability
constructs.* `TCL_WIDE_INT_TYPE`, `TCL_HASH_TYPE`, `Tcl_StatBuf` (`struct
stat`), wchar_t-width function selection, and `TCL_UTF_MAX`-dependent
renames. *Out parameters.* By name and shape (heuristic): 84 non-const
integer pointers (`int *lengthPtr`), 72 `T **` (`Tcl_Obj ***objvPtr`).
*String conventions.* `const char *` in 231 parameters and 37 results,
121 pointer-plus-length pairs, `unsigned char *` for bytes (17).

**The stubs mechanism is the most consequential Tcl finding.** Under
`USE_TCL_STUBS`, the normal extension configuration, the preprocessed
declarations are *identical* to direct linkage: 753 `extern` functions.
Yet an extension must not call one of them by its symbol. 761 object-like
macros redirect every name to `(tclStubsPtr->tcl_X)`, a member of the
5,544-byte `TclStubs` table, and the symbol `libtclstub` provides is
`tclStubsPtr`. An FFI that imported the declarations would link against
symbols the extension cannot use. A correct importer has to read the macro
layer: it sees the declaration (the signature), the macro (the indirection)
and the table struct (its fields, in declaration order). Either a thunk per
function (the same-named declaration supplies the signature: compiled in
the prototype) or a direct read of the table through a layout with pointer
fields works; nothing in the declarations alone does. `Tcl_InitStubs` too
is a macro, with the version and `TCL_STUB_MAGIC` (a `sizeof` constant)
baked in.

### Cross-library comparison

| construct | BoringSSL | Tcl | weight |
|---|---|---|---|
| opaque handles behind pointers | 103 tags, 2,098 functions | 30 tags, 405 functions | both: core |
| integer scalars, `size_t`, fixed-width typedefs | everywhere | everywhere | both: core |
| `const char *` strings, pointer + length | 172 / 508 | 231 / 121 | both |
| callbacks with `void *` userdata beside and inside | 106 of 174 (declared functions) | 57 of 66 | both: core |
| function-pointer fields in public structs | 38 | 84 (+811 stub entries) | both |
| pointer-to-pointer (out pointers) | 367 functions | 68 | both |
| fixed arrays in public structs | 49 fields | 5 | both, BoringSSL more |
| unions in public structs | 23 (16 storage) | 2 | both, rare |
| enums in signatures | 21 | 2 | both, rare |
| variadic functions | 5 | 11 | both, rare |
| value macros (constants) | ~4,400 | ~260 | both: core |
| call-wrapper and member-access macros | 78 | 84 | both |
| type-generic `sizeof` macros | `CHECKED_CAST`, `DECIMAL_SIZE` | `Tcl_GetBooleanFromObj`, `Tcl_GetIndexFromObjStruct` | both, few |
| `static inline` API | 817 | 1 | BoringSSL only |
| initializer-fragment macros (ASN.1 templates) | 24 | 0 | BoringSSL only |
| symbol prefixing (`redefine_extname`) | 3,149 | 0 | BoringSSL only |
| stub-table indirection | 0 | 761 | Tcl only |
| function-*type* typedefs as the callback idiom | 7 | 112 | Tcl mostly |
| macros shadowing same-named functions | 0 | 31 (embed), 39 (stubs) | Tcl only |
| `double` | 1 | 7 | Tcl mostly |
| bitfields | 3 | 0 | BoringSSL only, private |
| by-value aggregates, `long double`, `_Bool`, `restrict`, `volatile`, nullability, calling conventions, K&R | 0 | 0 | neither |

### Frequency, importance, difficulty, workarounds

| shape | frequency | importance | difficulty | strategy |
|---|---|---|---|---|
| scalar and pointer functions | ~94% / 90% of functions | the API | low | direct first-class FFI support |
| opaque handles | most functions | the object model | low | direct (nominal opaque type) |
| static callbacks + `void *` | 451 / 52 functions | central | medium | requires callback support (static exposed functions) |
| `static inline` functions | 817 / 1 | the whole stack API | low per function | generated C thunk, or ordinary Botlish wrapper over `OPENSSL_sk_*` |
| constants (macros, enums) | ~4,500 / ~280 | high | low (the probe evaluates them) | generated constant import (requires compiler ABI probe for expressions) |
| expression/statement macros | ~60 / ~95 | high for Tcl | medium | generated C thunk with a declared signature |
| stub-table calls | 761 (Tcl) | the extension ABI | medium | generated C thunk, or a layout with pointer fields read directly |
| link prefixing | 3,149 (BoringSSL prefix) | required for bundling | low with GCC, high with Clang text | requires compiler ABI probe (object symbols) |
| complete structs for allocation | 14 storage-only + private ctx structs | medium | low | binary DSL extension: size/alignment-only layout |
| complete structs read by consumers | a few dozen | medium | high (pointers, arrays, unions) | binary DSL extension (pointer scalar, then arrays), generated C accessor meanwhile |
| enums | 21 / 2 signatures | low | low | integer domain + constants (requires ABI probe for width) |
| varargs, `va_list` | 7 / 11 | low | high | ignore/postpone (ordinary Botlish wrapper over a non-variadic sibling) |
| bitfields | 3 private | none | high | generated C accessor, or postpone |
| type-generic macros | 4 | low | medium | generated C thunk per signature |
| declaration-generating / initializer macros | 1,000 decls / 24 | none for callers | n/a | import their output; ignore the macro |
| unions | 7 real tagged choices | low | high | opaque treatment (behind pointers), generated C accessor |

## Architecture consequences (items 91-100)

91. **Likely eventual plugin responsibilities.** Given an import profile,
    produce binding declarations: the IR's functions, opaque types,
    callback signatures, layouts for the complete structs asked for,
    constants with values, link names, and the thunk declarations a binding
    author requests. Also refuse precisely what it cannot represent, by the
    corpus's categories. The plugin decides policy (typedef categories,
    which structs get layouts). The parser and the probe supply facts.
92. **Likely toolchain-adapter responsibilities.** Item 76: preprocess,
    capture macros, identify the compiler, compile probes, run or inspect
    them, and report the link name of a declaration (needed for Clang and
    prefixing). Keep it as one small replaceable unit with a capability
    list, as here.
93. **Likely generated-binding artifact.** A Botlish source module per
    import profile: opaque types, external C function declarations,
    callback types, `layout` declarations with probed offsets, constants,
    plus one generated C file of thunks (inline functions, macros, stub
    calls) and the import profile it came from (revision, defines,
    compiler, target, the probe's facts). The IR text of this experiment is
    a candidate intermediate. It is deterministic, diffable and
    self-checking (oracle), and the diff tool already reports what a header
    or configuration change did to it.
94. **Likely package-author workflow.** Pin the library revision. Write an
    import profile (entry headers, defines, include roots, wanted thunks
    and layouts). Run the importer once per supported target with that
    target's headers. Review the diff against the previous import. Commit
    the generated module and the C thunk file. A library update is a rerun
    and a reviewed diff.
95. **Likely end-user workflow.** Compile ordinary Botlish. The bindings are
    source; the thunk file is compiled once with the package's native code
    (or shipped compiled). No headers, preprocessor or probe on the user's
    machine.
96. **Live import versus pre-generated: recommendation.** Pre-generated,
    for five reasons:
    * The IR depends on configuration in ways a user cannot be asked to
      reproduce: compiler family (Clang loses the expanded link names and
      Tcl's attributes), defines (`USE_TCL_STUBS` changes the whole calling
      model while the declarations stay identical), include roots
      (`tclTomMath.h` without libtommath fails), and system headers
      (`struct tm` field names change with `-std`).
    * Every target needs its own system headers, which a cross build
      usually does not have (item 55).
    * The physical facts need a compiler run.
    * The thunks need a C compiler anyway, once.
    * The import is reviewable only if it is an artifact.
    Live import remains reasonable for a system library whose headers must
    match the installed binary (item 99).
97. **Implications for single-executable Botlish.** None for ordinary
    compilation: the single executable needs neither a C preprocessor nor a
    C compiler to consume pre-generated bindings. Thunks need C compilation
    or a shipped object per target. The `stub` linker path
    (SINGLE-EXECUTABLE.md) would have to link a prebuilt thunk object, or
    the package must ship one. The importer itself is a development tool
    beside the single executable, not inside it.
98. **Implications for static package dependencies.** BoringSSL is the
    proof: a package can ship one pinned BoringSSL build (static archive,
    built with `BORINGSSL_PREFIX` so it cannot collide with a system
    OpenSSL) together with bindings generated from *that build's* headers
    and defines. The generated bindings are sufficient: the declarations
    reference only fixed-width integers, `size_t`, `FILE` (opaque),
    `time_t`, `struct tm`/`struct timeval` (5 + 2 uses) and `va_list` (2)
    from the system, so the downstream user's system headers are needed
    for nothing but those few system types. The prefixed link names must be
    in the bindings, which means the probe must resolve them (GCC's text
    has them; Clang's does not).
99. **Implications for system libraries.** For a library the user's system
    provides, the bindings must agree with the installed headers and
    binary: `BN_ULONG` and `long` widths, `Tcl_Size`, the presence of
    `tommath.h`, the stubs table's layout. Either the package ships bindings
    per supported system configuration, or the importer runs at build time
    against the installed headers (live import, with the probe). Tcl's
    stub-table design is a stable ABI built exactly for this, so its
    bindings can be generated once per Tcl major version.
100. **Questions that remain genuinely unresolved.**
     * How a binding declares a thunk: the declared signature, a
       per-identifier instantiation, and lvalue setters all need a
       syntax.
     * Whether the importer should model the stub table as a layout with
       function-pointer fields (needs the pointer scalar and function-
       pointer types in layouts) or as thunks.
     * How the link name is obtained under Clang: a symbol probe that
       compiles a reference and reads the object, or a toolchain
       capability.
     * How a cross-target import gets its target headers (sysroot
       management is out of this experiment).
     * Whether complete-but-private structs should be importable at all,
       or only as sized storage.
     * What the higher-level wrapper libraries need: ownership,
       nullability and lengths, for which neither library has
       machine-readable annotations (item 38 of the brief: 0 nullability
       attributes in either library).

## Unexpected findings

* **Preprocessing eliminates more than expected, and the parser was never
  the problem.** Zero parse failures in two libraries and their glibc
  closure, with both compilers, at the first full run. Every declarator
  shape people fear (`int (*f(void))(int)`, `T *const *`, arrays of
  function pointers) appears in the corpus and parses with the textbook
  rule. The compiler oracle found no reading error at all. Its
  explained mismatches are all attributes that change a type.
* **API identity lives in macros more than in declarations.** Tcl's stubs
  build keeps identical declarations while every call goes elsewhere.
  tommath's `mp_*` declarations name symbols libtcl does not export.
  BoringSSL's prefix build changes link names through pragmas whose text
  depends on the compiler family. Macro *provenance* is still unnecessary.
  But an importer that reads only declarations is wrong for the normal Tcl
  extension, so the macro layer must be read (it can be, with `-dD` and the
  compiler's own expansion).
* **817 of BoringSSL's 3,926 functions have no symbol.** The entire
  `STACK_OF` API is `static inline` in C. In C++ the same functions are
  `inline` with external linkage (unless
  `BORINGSSL_ALWAYS_USE_STATIC_INLINE`), and `BORINGSSL_PREFIX` must rename
  them too. Whether a function is local to the translation unit depends on
  the consumer's language.
* **Zero by-value aggregates.** Neither API passes or returns a struct or
  union by value, which removes the most complicated part of C calling
  conventions from FFI v1.
* **Callbacks matter, closures do not.** 451 + 52 functions take callbacks,
  and none needs more than a `void *` and a static function.
* **"Complete" does not mean "readable".** 87 of BoringSSL's 100 complete
  structs are used only behind pointers. 14 are pure storage (a byte
  array and an alignment scalar in a union), complete only for stack
  allocation. Unions are therefore less important than the raw count (23)
  suggests: 16 of them are storage.
* **Typedef identity matters by category.** It is essential for handles
  and callback protocols, and actively harmful for integers (`mp_digit`
  changes typedef chain with a define while its representation stays).
* **Enums are trivial, and replaced by macros.** Every enumerator in both
  libraries is a literal or implicit. Both libraries keep their real
  constants (about 4,700) in macros, some of them expressions with casts or
  `sizeof`.
* **Clang's preprocessed text is not GCC's.** `#pragma redefine_extname`
  arguments stay unexpanded, `-dD` spacing differs, and headers test
  `__GNUC__` and so behave differently under Clang. "Run the preprocessor"
  is not enough to make the text compiler-independent.
* **A comma-list macro compiles silently to the wrong value.** `return
  OBJ_rsadsi;` gives 113549 with no warning from either compiler. Thunk
  generation for object-like macros needs the macro's category, not just
  a successful compile.
* **Attributes are part of types in a compiler-specific way.** GCC treats
  `noreturn` on a function-pointer field as part of its type, and Clang
  does not. `mode(TI)` turns `unsigned long` into a 128-bit type. A
  faithful IR keeps attributes, and the FFI must reject the type-changing
  ones until the probe resolves them.
* **Nullability metadata: none.** Neither library carries `nonnull`,
  `_Nullable` or `returns_nonnull` on its own declarations (glibc does).
  Ownership and nullability will have to come from wrapper libraries.

## Reproducing a run

```sh
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 audit/c-header/tools/fetch.tcl        # the pinned sources, into ~/.cache/botlish/c-header-src
tclsh9.0 audit/c-header/tools/all.tcl          # every result below, about 90 s
tclsh9.0 audit/c-header/tests/parser.test      # 50 tests, no toolchain needed
tclsh9.0 audit/c-header/tests/corpus.test      # 22 tests, no toolchain needed
```

`all.tcl` runs every profile (`run.tcl PROFILE`), then the oracle and the
ABI probe of each, the corpus of both libraries, the thunk prototype, the
variants and the complexity measurement, then the two test files. The
toolchain is GCC by default (`cc`). `BOTLISH_C_CC=clang tclsh9.0
audit/c-header/tools/run.tcl PROFILE -out DIR` runs a profile with Clang.
Single questions go through `tools/query.tcl PROFILE QUERY` (`callbacks`,
`variadic`, `ptrptr`, `struct-arrays`, `unions`, `thunks`, `attributes`,
`byvalue`, `floats`, `inline`, `opaque`, `layout`, `show NAME`, `chain
NAME`, `grep REGEX`, `unsupported`, `macro NAME`), and profile comparisons
through `tools/diff.tcl A B`.

Performance (item 108), per profile on this container (`timing.txt`):

| profile | preprocess | parse | macro probe | census | IR |
|---|---:|---:|---:|---:|---:|
| boringssl-static | 0.07 s (646 KB, 91,500 tokens) | 1.24 s | 0.58 s | 4.6 s | 1.8 MB + 1.6 MB macros |
| boringssl-prefix | 0.15 s (870 KB) | 1.37 s | 0.64 s | 4.5 s | 2.3 MB |
| tcl-embed | 0.03 s (208 KB, 38,103 tokens) | 0.47 s | 0.12 s | 1.5 s | 0.7 MB |
| tcl-stubs | 0.03 s | 0.47 s | 0.19 s | 1.6 s | 0.7 MB + 0.3 MB macros |

Nothing is pathological. The census is the slowest part, and it is
reporting code.

## Files

```
audit/c-header/
  README.md                 what this directory is, in one screen
  profiles/boringssl.tcl    the three BoringSSL profiles (revision, entry set, defines)
  profiles/tcl.tcl          the three Tcl profiles
  tools/toolchain.tcl       the toolchain adapter (BOTLISH_C_*; the only command-line knowledge)
  tools/cdecl.tcl           tokenizer and declaration parser (the instrument's core)
  tools/ir.tcl              IR text, indexes, typedef resolution, rendering back to C
  tools/macros.tcl          macro records from -dD output
  tools/run.tcl             run a profile: preprocess, parse, probe macros, write results
  tools/census.tcl          every count of this report
  tools/oracle.tcl          the compiler oracle
  tools/abiprobe.tcl        the native ABI probe and generated layouts
  tools/thunks.tcl          the thunk feasibility prototype
  tools/corpus.tcl          the unsupported-shape corpus
  tools/query.tcl diff.tcl  queries over one profile, differences between two
  tools/variants.tcl        the configuration variants (clang, -std=c11, no redefine_extname)
  tools/complexity.tcl      parser measurements
  tools/fetch.tcl all.tcl   fetch the pinned sources; regenerate everything
  tests/parser.test         50 parser tests
  tests/corpus.test         the corpus fixtures reproduce
  unsupported/boringssl/ unsupported/tcl/   21 fixtures and INDEX.tsv
  results/PROFILE/          ir.txt system.txt macros.txt census.txt census.tsv profile.txt
                            timing.txt oracle.txt abi.txt abi-summary.txt layouts.bot
  results/thunks.txt variants.txt parser-complexity.txt
```

The parser and its tests are research tooling. They are not in
`tests/` and do not join the compiler's suite or its golden census: the
instrument's implementation language is not part of any FFI decision.
