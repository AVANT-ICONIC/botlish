# C-FFI.md

`extern c library` and `extern c fn`: Botlish's first real C calls. A
program declares the C functions it calls, by their C signatures and the
contract of each pointer parameter, and the libraries it links; the native
backends compile every call to a direct call of the linked symbol with the
platform C calling convention, and the system linker resolves the symbols.

> Keep C interop truthful and low-level. Reuse the platform ABI and linker
> where they already solve the machine problem; reuse Botlish's existing
> value, borrowing and capability mechanisms where they already solve the
> language problem. Do not create a second C ecosystem inside the Botlish
> compiler.

```botlish
# sha256.bot -- an application module (examples/ffi/sha256/)
import abi
import abi::bytes
import ffi::c

extern c library "crypto"
extern c library "stdc++"

extern c fn SHA256 named "botlish_bssl_SHA256"(
    data: ffi::c::Ptr[ffi::c::UChar] read noescape,
    len: ffi::c::ULong,
    out: ffi::c::Ptr[ffi::c::UChar] write noescape
) -> ffi::c::Ptr[ffi::c::UChar] alias out

fn digest(data: abi::bytes::Bytes) -> abi::bytes::Bytes:
    written = data.SHA256(abi::bytes::length(data).value, abi::bytes::zeroed(abi::usize(32)))
    abi::bytes::freeze(written.out)
```

`digest` hands BoringSSL the input Bytes' own storage for reading (no
copy), a private copy of a fresh 32-byte MutableBytes for writing, and gets
the bytes C wrote back as `written.out`; the pointer SHA256 returns is
exactly `out`, so the call yields unit in its place. Nothing in the module
is `direct`: both pointers are noescape.

This milestone builds the call, on the substrates three earlier milestones
built for it: the C ABI value types (C-ABI-TYPES.md), temporary byte
exposure under a per-parameter contract (C-POINTER-BORROWING.md, whose
section 14 is the hook this fills) and the module-level capability boundary
(DIRECT-MODULES.md). It adds no value, type, borrowing or capability
mechanism of its own: what is new is the declaration, its registration as a
foreign native, the ABI transport and the link.

## Contents

* [1. Syntax](#1-syntax)
* [2. Declarations](#2-declarations)
* [3. The ABI surface](#3-the-abi-surface)
* [4. Contracts](#4-contracts)
* [5. Calls](#5-calls)
* [6. Byte borrowing and write-back](#6-byte-borrowing-and-write-back)
* [7. Pointer results](#7-pointer-results)
* [8. Transport: nothing is truncated](#8-transport-nothing-is-truncated)
* [9. direct](#9-direct)
* [10. Representation](#10-representation)
* [11. Linking](#11-linking)
* [12. Backends](#12-backends)
* [13. Targets](#13-targets)
* [14. Static compile, interchange, cache, isolation](#14-static-compile-interchange-cache-isolation)
* [15. The single executable](#15-the-single-executable)
* [16. Examples](#16-examples)
* [17. The Tcl binding](#17-the-tcl-binding)
* [18. The BoringSSL binding](#18-the-boringssl-binding)
* [19. Standalone executables](#19-standalone-executables)
* [20. GC stress](#20-gc-stress)
* [21. Performance](#21-performance)
* [22. Tests, fuzzing, mutants](#22-tests-fuzzing-mutants)
* [23. Regression](#23-regression)
* [24. Architectural boundaries](#24-architectural-boundaries)
* [25. For a binding generator](#25-for-a-binding-generator)
* [26. Not here](#26-not-here)
* [27. What to run when changing this](#27-what-to-run-when-changing-this)
* [28. Files](#28-files)

## 1. Syntax

Two top-level declarations, in any module or the entry program:

```
externLibrary := "extern" "c" "library" STRING

externFn      := "extern" "c" "fn" NAME ["named" STRING]
                 "(" [param ("," param)* [","]] ")" "->" resultType [resultFact]
param         := NAME ":" type [access] [escape]
access        := "read" | "write"
escape        := "noescape" | "proven" "noescape" | "captures"
resultType    := type | "unit"
resultFact    := "independent" | "alias" NAME
```

```botlish
extern c library "botlish_cffi_fixture"

extern c fn add named "bcf_add"(a: ffi::c::Int, b: ffi::c::Int) -> ffi::c::Int
extern c fn nothing named "bcf_nothing"() -> unit
extern c fn sum named "bcf_sum"(data: ffi::c::Ptr[ffi::c::UChar] read noescape, count: ffi::c::ULong) -> ffi::c::ULong
extern c fn keep named "bcf_keep"(p: ffi::c::Ptr[ffi::c::Void] captures) -> unit
```

* **No body.** An extern c fn is a declaration of a C function, not a
  Botlish function with a magic call inside: a `:` after the signature is an
  error, and so is an `errors` clause (C reports no Botlish error).
* **`c` is the ABI**, the only one: `extern fn`, `extern rust fn` are
  errors naming it.
* **A library is its linker name**, the `NAME` of the platform linker's
  `-lNAME` (`"crypto"` for `libcrypto.a`/`libcrypto.so`): letters, digits
  and `_ + . -`, not starting with `-`. A path or a `-l` flag is an error
  naming the form, and so is an unquoted name. (A file name such as
  `"libcrypto.a"` is a name the linker will not find: `-llibcrypto.a`.)
* **`named "SYMBOL"`** overrides the link symbol (section 2): letters,
  digits, `_ . $`, not starting with a digit. One `named` per declaration.
* **The signature is the C signature**: every parameter typed, the result
  type required (`-> unit` for void), no varargs (`..`, `...`, a trailing
  `.` are errors: there is no variadic ABI here).
* **Facts** follow a parameter's type and the result type; each is stated
  at most once.
* **Declarations are top-level** (a module's or the entry program's own),
  never inside a function or a block.

Every word after `extern` (`c`, `library`, `named`, `read`, `write`,
`noescape`, `proven`, `captures`, `independent`, `alias`) is contextual: an
ordinary name everywhere else (`cf-parse-contextual`). Every malformed form
is a located `EXTERN-SYNTAX` error naming what is wrong and the remedy
(`cf-parse-errors`, `cf-parse-messages`), and a recovering parse reports
each one once (`cf-parse-recover`).

## 2. Declarations

**Identity.** An extern c fn's identity is its Botlish qualified name --
`boringssl::SHA256` for module `boringssl`'s `SHA256`, the bare name for
the entry program's -- exactly a function's. It is a member of its module
(`boringssl::SHA256(...)`, or method syntax through the module's import:
`data.SHA256(...)`, `cf-method-syntax`), visible in the whole declaring
unit like a type, and the entry program's are visible in the entry program
only (`cf-entry-program-declares`). Two declarations of one qualified name
are `DUPLICATE`, never merged, whatever their signatures; a function and an
extern of one name are the ordinary duplicate binding; two modules may
declare the same C symbol, each with its own Botlish name and contract
(`cf-decl-duplicate`). There is no registry of symbols: Botlish module
identity is independent of linker symbol identity, and two declarations of
one symbol with different signatures are each their author's ABI promise --
not diagnosed, since no check could cover every external linkage, and no
whole-program C symbol-type verification is attempted.

**The link symbol** is the declaration's name, or `named`'s string. `named`
changes exactly the symbol: the Botlish name stays the declaration's
(`cf-named-symbol`). It is how a binding gives a C function a Botlish name
(`plus` for `bcf_add`) and how it binds a symbol that is no Botlish name at
all (BoringSSL's prefixed `botlish_bssl_SHA256`).

**A library is a link-plan entry, never a function's.** `extern c library`
adds a name to the program's link plan; it associates with no extern c fn,
and an extern c fn names no library. The system linker resolves every
symbol against every library of the plan (section 11), so a library may be
declared in the module that binds its functions, in another module, or in
the entry program, and one library may serve functions declared in several
modules (`cf-direct-two-modules-one-library`). The plan holds each name
once, in first-declaration order -- the loader's order: a module's own
declarations after its imports', the entry program's last
(`cf-link-plan`).

**Validation** is the front end's and located: every type must be a C ABI
value type (`cf-decl-types`), every fact one its parameter or result can
have (`cf-decl-facts`, section 4).

## 3. The ABI surface

Exactly C-ABI-TYPES.md's value universe, nothing added:

| C | Botlish | ABI class |
|---|---|---|
| `signed char`, `unsigned char`, `char` | `ffi::c::SChar`, `ffi::c::UChar`, `ffi::c::Char` | `i8`, `u8`; `char` by the target (`i8` on x86-64, `u8` on Linux AArch64) |
| `short`, `unsigned short` | `ffi::c::Short`, `ffi::c::UShort` | `i16`, `u16` |
| `int`, `unsigned int` | `ffi::c::Int`, `ffi::c::UInt` | `i32`, `u32` |
| `long`, `unsigned long` | `ffi::c::Long`, `ffi::c::ULong` | `i64`, `u64` on LP64 (`i32`, `u32` on LLP64) |
| `long long`, `unsigned long long` | `ffi::c::LongLong`, `ffi::c::ULongLong` | `i64`, `u64` |
| `T *` | `ffi::c::Ptr[T]` (T a scalar, `ffi::c::Void`, an opaque struct, a pointer) | `ptr` |
| `R (*)(A...)` | `ffi::c::FnPtr[Fn{args: [...], return: R}]` | `ptr` |
| `void` (result) | `unit` | `void` |

A parameter's ABI class is its type's width and signedness on the
compilation's target, read from the type registry's `cabi` metadata
(`core::type::cabiScalar`), never from its name (`cf-abi-classes-follow-
the-target`: `long` is 64 bits for `-target linux-x86_64` and 32 for
`windows-x86_64`, plain `char` signed on x86-64 and unsigned on
`linux-aarch64`). size_t, uint8_t and the other typedefs are a binding
author's (or a future generator's) choice of the scalar the target's ABI
probe says they are (`size_t` is `ffi::c::ULong` on LP64): the compiler
knows no typedef.

Not here, each an error at the declaration: floating point, structs or
unions by value, arrays (a parameter `uint8_t out[32]` is the pointer it
decays to), varargs, `unit` as a parameter, an imprint variable in a
signature (one C function has one ABI), a Botlish value type that is no C
type (`int`, `str`, `Bytes`: byte storage reaches C only through a pointer
parameter's contract, section 6).

## 4. Contracts

Each declaration is registered with exactly the foreign call contract a
`-foreign` native has (core/cabi.tcl's `NormalizeForeign`,
C-POINTER-BORROWING.md section 3) -- one representation, which every
consumer reads:

```
params      {name type access escape} per parameter (access and escape
            only on pointers; access only on data pointers)
result      the C result type, or unit
provenance  unknown | independent | {alias PARAM}   (pointer results only)
```

| written | contract |
|---|---|
| `read` / `write` | access `read` / `write`; nothing written: `unknown` |
| `noescape` | escape `declared-noescape` (the binding author's statement) |
| `proven noescape` | escape `proven-noescape` (evidence: an analysis, a compiler attribute) |
| `captures` | escape `captures` (C may keep the pointer past the call) |
| nothing | escape `unknown` |
| `independent` | provenance `independent`: the result points into no argument |
| `alias P` | provenance `{alias P}`: the result is exactly parameter P's pointer |
| nothing (pointer result) | provenance `unknown` |

An absent fact is `unknown`, and `unknown` is never treated as the
favorable answer: an unknown escape retains (section 9) and admits no
exposure, an unknown access admits no exposure, an unknown provenance admits
no exposure on the same call (section 7). `const` in the C declaration is no
fact: SHA256's `const uint8_t *data` is `read` because its author says so,
and noescape only because they say that too. Proven and declared noescape
are equivalent for every decision here; the distinction is the record of
the evidence (C-POINTER-BORROWING.md, "evidence").

A fact is a pointer's: `read`/`write` on a scalar or a function pointer, a
provenance on a non-pointer result, and an `alias` naming a parameter that
is not one or is of another type, are located `TYPE` errors at the
declaration (`cf-decl-facts`). Where the facts come from -- a header, an
ABI probe, a compiler's `nocapture`/`returned` attribute, a person -- is
nothing the compiler knows (section 25).

## 5. Calls

A call of an extern c fn is an ordinary call node of a root native
`extern#KEY` (`KEY` the qualified name; `#` is no source spelling). It is
typed, admitted and checked by the machinery every call has:

* **Arguments** are held to the declared C types by the ordinary admission
  proof: a C scalar is an integer domain, so an `int` argument needs its
  range proven (a literal, a comparison, a declared `ffi::c::Int`
  parameter), never wrapped or truncated (`cf-call-typing`); a pointer
  parameter admits an `ffi::c::Ptr` of exactly its type, or byte storage
  under its contract (section 6).
* **Arity** is the C signature's: a call passing another number of
  arguments is a compile-time `ARITY` naming the declaration ("bcf::add is a
  C function of 2 parameter(s), its declaration's C signature, and this
  call passes 1 argument(s)").
* **The result** is the declared C type -- an integer domain value, an
  affine `ffi::c::Ptr`, an `ffi::c::FnPtr`, unit -- or, with a write
  exposure, the write-back struct (section 6).
* **Not a value.** An extern c fn is only called: bound, passed or returned
  as a value it is `TYPE` ("bcf::add can only be called directly: it is a C
  function (extern c fn), and a call through a function value would have no
  C signature, no contract and no link symbol", `cf-not-a-value`). A C
  function pointer value is `ffi::c::FnPtr`, which Botlish passes and
  receives but never calls (`cf-function-pointers`).
* **Ownership.** Every parameter observes: an affine `Ptr` argument stays
  its owner's (an observed temporary needs an owner first: bind it).

## 6. Byte borrowing and write-back

Exactly C-POINTER-BORROWING.md, through real C. A byte-pointee parameter
(`Char`, `SChar`, `UChar`, `Void`) whose contract says noescape and states
an access admits existing storage for the one call:

* **read noescape**: an `abi::bytes::Bytes` or `MutableBytes` is exposed as
  it is -- its own storage's address, no copy (`cf-borrow-read`);
* **write noescape**: a `MutableBytes` is detached into a private copy, C
  writes the copy, and the call's value is the write-back struct
  `{result: R, NAME: MutableBytes}` (NAME the parameter's), the caller's
  value and every copy of it unchanged (`cf-borrow-write`, against real C:
  the SHA-256 acceptance's original MutableBytes is still all zeros after
  BoringSSL wrote the digest).

Refused, `FOREIGN-BORROW`, as for every foreign call: storage where the
contract may keep the pointer (captures, unknown), an immutable Bytes at a
write parameter, a pointee that is not byte-sized (`cf-borrow-refusals`).
There is no pointer value of byte storage, ever: a Bytes is never an
`ffi::c::Ptr`. C strings are bytes: a `const char *` argument is a Bytes
holding the string and its NUL, which the binding (not the compiler) adds
(`examples/ffi/tcl/demo.bot`'s `script`).

The exposures are made after every argument is evaluated, and kept alive
by a `keepalive` of each exposed storage after the call (NIR in section 10);
an unchecked (`-strict 0`) program's refused exposure replays the refusal at
run time, the C call never made (`cf-strict0-replay`).

## 7. Pointer results

A pointer result is truthful: SHA256 returns `uint8_t *`, so its
declaration's result is `ffi::c::Ptr[ffi::c::UChar]`, never a void
pretending C's register is ignored (C-POINTER-BORROWING.md section 14 had to
declare it unit; the provenance fact is what lets it stay a pointer). What a
call yields depends on where the result points, which only the contract can
say:

| provenance | the call's result |
|---|---|
| `independent` | a fresh `ffi::c::Ptr` (`Tcl_CreateInterp`) |
| `alias P`, P a raw `Ptr` argument | a new `ffi::c::Ptr` of the same address (`bcf_echo_ptr`) |
| `alias P`, P exposed byte storage | unit in its place: a pointer into Botlish storage never outlives the call (SHA256's `out`) |
| `unknown`, nothing exposed | a fresh `ffi::c::Ptr` (C-ABI-TYPES.md's raw pointers) |
| `unknown`, storage exposed | `FOREIGN-BORROW`: the result may point into the exposure (memchr's shape, `cf-result-provenance`) |

**The contract is checked where the run sees it.** An `alias P` result that
is not exactly P's address is a `CONTRACT-VIOLATION` failure right after the
call -- for an exposure (the result discarded) and for a raw pointer alike
(`cf-contract-violation`, `bcf_reverse_off` returning `out + 1`). It is a
development assertion of the binding's contract: one compare and a
never-taken branch, always on. No other fact can be checked by observing a
call (an escape or an access is a property of C's code, not of its result),
so none is.

## 8. Transport: nothing is truncated

| Botlish word | to C | from C |
|---|---|---|
| small Int (`(n << 1) \| 1`), a narrow scalar | `n`, reduced to the class width; extended by the call's signature (`sext`/`uext`) | sign- or zero-extended from the class width by Botlish, whatever the callee left in the register's other bits, then tagged |
| Int, a 64-bit scalar | `n`: inline for a small Int, `rt_ffi_int_word` for a BigInt | tagged when it fits the small range, else a BigInt (`rt_ffi_box_i64`, `rt_ffi_box_u64`) |
| C address word (`(a << 4) \| 0b1110`) | `a` (an arithmetic shift: null, word 14, is 0) | `(a << 4) \| 0b1110` when `a` fits the word's sign-extended 60 bits, else a `NATIVE ADDRESS` failure |
| exposure address (a small Int, `bytesaddr`/`mbytesaddr`) | the address | -- |

The admission proof has already held every scalar argument inside its C
type's range, so converting one never wraps. Every canonical x86-64 address,
user or kernel, and every untagged AArch64 one fits a C address word; a
top-byte-tagged AArch64 pointer does not, and is a failure naming the
function and the address, never a masked or truncated pointer
(`cf-wild-address`, `bcf_wild` returning `0xf000000000000010`). Every C
integer scalar crosses both ways at both bounds (`cf-scalar-transport`,
2^64 - 1 as a BigInt both ways); a narrow result is correct whatever is in
the register beyond its width (`cf-scalar-extension`: the fixture's
hand-written `bcf_dirty_*` return 0x80 in a register of 0x5555...80);
arguments past the argument registers go on the stack
(`cf-stack-arguments`, ten mixed arguments).

## 9. direct

A foreign call is not direct by being foreign (`cf-direct-noescape-
ordinary`): a module whose C calls are all noescape -- which pass raw
pointers, receive them, expose bytes for one call -- is ordinary. Directness
comes from what a C function may do with authority after the call returns:

* a call of an extern c fn whose contract **may retain a pointer** -- a
  pointer parameter with escape `captures` or `unknown`
  (`core::cabi::RetainingParameters`, the borrowing milestone's direct hook)
  -- is an **authority source**, a direct edge of the calling unit like a
  call into a designated direct module, named by the declaration and the
  retaining parameter (`cf-direct-retaining`: "bcf::keep, a C function whose
  contract lets it retain pointer authority past the call (parameter "p":
  escape captures)");
* it is mediated exactly as any edge is: from a function requiring a context
  the calling unit declares itself (`cf-direct-contextualized`), or
  acknowledged by `direct module` (`cf-direct-declared`);
* **declaring** a retaining extern designates nothing: a module that only
  declares one is ordinary (stale if marked `direct module`), and the
  authority is its callers' -- a call of it from its own module is an edge
  too (`cf-direct-not-predesignated`);
* the capability boundary is the module: one C library can be bound by an
  ordinary module (its noescape functions) and a direct one (its retaining
  function) (`cf-direct-two-modules-one-library`); `main.tcl -direct` names
  a retaining C call among the edges (`cf-direct-summary`).

No syntax was added for it -- no `direct fn`, no `unsafe`, no per-call
marker -- and directness still lives in the HIR (`moduleDecls`, `direct`),
never in the registry (DIRECT-MODULES.md). The hook DIRECT-MODULES.md
section 9 anticipated as a third designation source turned out to be an
edge: a retaining call is authority where it is made, not a property of the
module that declares the function.

## 10. Representation

**AST** (surface/ast.tcl): `externlib {library librarySpan}` and `externfn
{name nameSpan symbol symbolSpan params paramsSpan resultType
resultTypeSpan provenance provenanceSpan}`, each parameter `{name nameSpan
type typeSpan access escape factsSpan}`. surface/lower.tcl collects them
(`ExternDeclOf`, `LinkDeclOf`, with the unit's namespace) and the loader
hands every unit's to the build (`-foreign-decls`, `-link-decls`).

**HIR** (hir/foreign.tcl). The build registers each declaration as the
compilation-local root native `extern#KEY`, with the contract as its
`-foreign` metadata and `{key namespace name symbol abi}` as its `extern`
metadata, and binds its spelling in its unit's scope (a root-kind binding;
hygiene names it `extern#KEY` once resolution is done, keeping the
spelling). The HIR keeps two side tables:

```
foreign   KEY -> {key namespace name symbol native origin contract abi}
          boringssl::SHA256 -> {... symbol botlish_bssl_SHA256
            contract {vars {} params {{name data type {cptr {refined int ffi::c::UChar}}
              access read escape declared-noescape} {name len ...}
              {name out ... access write escape declared-noescape}}
              result {cptr ...} provenance {alias out}}
            abi {params {ptr u64 ptr} result ptr}}
links     {{library crypto origins {...}} {library stdc++ origins {...}}}
```

and its `declarations` capture the registry (compilation isolation,
section 14). A call is an ordinary `call` node whose target is the native,
with the borrowing milestone's `borrows` transport on it: no new HIR node
kind, because nothing about a C call differs at HIR level from a foreign
call the borrow fixture has always had -- what differs is below.

**NIR** (native/lower.tcl, native/src/nir.rs) has a distinct instruction,
because a C call is neither a Botlish call, a runtime op nor a syscall
register call, and a string tag on one of those would hide the ABI:

```
link "crypto"
link "stdc++"
foreign 0 "botlish_bssl_SHA256" params="ptr u64 ptr" result=ptr alias=2 name="boringssl::SHA256"
...
func 5 "digest" params=1 ...
    %6 = structget 0 %5 @e356
    %7 = op mbytesclone %6 @e349                     # the write exposure's private copy
    %8 = op bytesaddr %0 @e349                       # the exposures, after every argument
    %9 = op mbytesaddr %7 @e349
    %10 = foreigncall 0 %8 %1 %9 exposed=0,2 discard @e349
    %11 = op keepalive %0 @e349
    %12 = op keepalive %7 @e349
    %13 = structnew 0 %7 @e349                       # the MutableBytes over the copy C wrote
    %14 = structnew 1 %13 %10 @e349                  # {out: ..., result: unit}
```

The header's `foreign N` entries are the program's foreign table, numbered
on first use: the link symbol, each parameter's ABI class, the result's,
the alias parameter, the Botlish name (for messages); `link` lines are the
link plan. `foreigncall F ARGS [exposed=I,...] [discard]` names its callee
declaration, the ABI signature (the table entry), the borrow plan
(`exposed=`, which operands are exposure addresses) and the result kind
(the entry's `result`; `discard` a result that aliases an exposure: checked,
then unit). The parser validates every operand count and index.

**Code** (native/src/codegen/clif.rs). Each table entry is a Cranelift
import (`Linkage::Import`) declared with the module's default calling
convention -- the platform C convention, `system_v` on Linux x86-64 and
AArch64 -- and its C signature: each integer parameter at its exact width,
the narrow ones `sext`/`uext` by their class, pointers 64-bit words, the
result at its width with no extension (the caller extends it, section 8).
A `foreigncall` is one direct `call` of the import, with the transport
inline around it (`cf-clif`). It is a safepoint of the native stack maps
(conservatively: no C function can reach the collector today).

## 11. Linking

A program whose NIR has a `foreign` or `link` entry is linked by the system
linker; every other program is linked exactly as before.

**The invocation.** The rustc linker (`BOTLISH_NATIVE_LINKER=rustc`, the
default, which links every standalone executable) builds the executable
from the program's object, the startup crate and the runtime library, and
passes the link plan to the system linker it drives (`cc`):

```
rustc ... --extern botlish_native=.../libbotlish_native.rlib
      -C link-arg=.../program.o
      -C link-arg=-L/DIR ...                          one per -L
      -C link-arg=-Wl,--start-group
      -C link-arg=-lcrypto -C link-arg=-lstdc++       the plan, in order
      -C link-arg=-Wl,--end-group
      startup.rs -o EXECUTABLE
```

The libraries are one linker group, so their order never decides a static
link: an archive declared before the archive that needs it still resolves
it (`cf-link-order`). Shared or static is the linker's choice by its own
search rules (`-lNAME` finds `libNAME.so` before `libNAME.a` in a
directory); Botlish adds no rpath, no `-Bstatic`, no pkg-config.

**Library search.** `main.tcl -L DIR` (repeatable) adds DIR to the linker's
search path for both native backends and `-emit-native-executable`
(`native::withLinkDirs DIRS SCRIPT` in Tcl, `--link-dir DIR` to
`botlish-native`). The system's default directories are searched as always.
A link directory is a link-time input only: it never shapes a HIR, so it is
in no cache key.

**Symbols are resolved once.** The linker resolves every symbol when the
program is linked; the running program makes direct calls. There is no
`dlopen`, no `dlsym`, no symbol-name processing at run time: the only
strings a C call can touch are the Botlish name in its two failure messages.

**Failures are the linker's.** A library the linker cannot find, or a symbol
no library defines, compiles through the whole front end and fails at the
native link as `{NATIVE LINK}`: "native link failed: the system linker could
not link this program with the C functions and libraries it declares
(symbols botlish_bssl_SHA256; libraries -lcrypto -lstdc++):" followed by
the linker's own lines (`cf-missing-library`, `cf-undefined-symbol`). Never a
front-end error: a missing library is not an `UNKNOWN-NAMESPACE`, an
undefined symbol not a `TYPE`. A declaration no call reaches needs no
definition: only the functions a program calls enter the table.

**The native backends' runs.** `-backend cranelift` and `cranelift-generic`
JIT a program into the `botlish-native` process; a C symbol, however, must
be resolved by the linker against the declared libraries. So a program that
calls C is linked as a standalone executable in a private temporary
directory (`botlish-run-PID-NONCE`, removed after) with the same link plan
as `-emit-native-executable`, and run as a child process with the run's
argument vector (`cf-argv`), the output inherited (main.tcl's
`-output inherit`: native program output stays main.tcl's own,
`cf-main-tcl`), and its result written to a result file
(`BOTLISH_NATIVE_RESULT`; `BOTLISH_NATIVE_RUNS` for a benchmark's runs) in
the driver's own protocol (runtime/aot.rs's `driver_protocol`). One
mechanism, two entry points: the run and the executable cannot disagree
about FFI. The JIT still compiles such a program when only its code is
inspected (`native::clif`, `native::nir`), its C symbols bound to
`rt_ffi_unlinked`, which aborts if it is ever called. Allocation reports and
batch timing measure in-process JIT runs only and report a program that
calls C `{NATIVE UNSUPPORTED foreign}`.

**The stub linker** (`BOTLISH_NATIVE_LINKER=stub`, the single executable's)
appends a program image to the prebuilt `botlish-aot-stub`; it links no
native library, so it refuses a program that calls C, naming what it calls
and the linker that can (`cf-stub-linker`).

## 12. Backends

| backend | declares C functions only | declares a library | calls C |
|---|---|---|---|
| interp | runs | runs | `NATIVE-ONLY` at the call, after its exposures were modeled |
| compile | runs | runs | `NATIVE-ONLY` at the call |
| cranelift, cranelift-generic | runs (JIT, as ever) | linked with the plan, run as a process | linked with the plan, run as a process |
| executable (rustc linker) | links | links the plan | links the plan; needs at run time only the libraries it linked dynamically |
| executable (stub linker) | links | `NATIVE LINK`: refused | `NATIVE LINK`: refused (section 11) |

A library is linked whether or not a function of it is called: the plan is
the program's (section 2), so a declared library that does not exist fails
the native link even of a program that calls nothing (`cf-missing-library`),
as it would for a C program linked with `-lNAME`; a declaration no call
reaches adds nothing to the link.

The Tcl backends have no machine to call C on, and there is no Tcl-side
FFI to keep the matrix symmetric: "bcf::add is a C function (extern c fn):
calling it runs only on the native backends (cranelift, cranelift-generic,
a native executable), which link and call the C library; the Tcl backends
have no machine to call it on" (`cf-tcl-backends`). Golden suites cannot
call C (they cannot link a library or say where one is), so the C FFI's
tests are Tcl tests (section 22).

## 13. Targets

**Linux x86-64**: implemented and tested end to end here (SysV: six integer
argument registers, the rest on the stack).

**Linux AArch64**: the same code path -- Cranelift's platform convention is
AAPCS64 there, plain `char` is unsigned by the target table, the fixture's
dirty-register functions have AArch64 versions, and rustc-linked
executables are supported -- run by `tests-arm64.yml`'s jobs (section 23).

Elsewhere the native backends already refuse executables (Linux glibc
only), so they refuse a program that calls C the same way. A `-target`
other than the host's chooses the ABI classes of a compilation (its HIR),
never a cross-link: linking is for the host.

## 14. Static compile, interchange, cache, isolation

**Static compile.** A `static compile:` block calling an extern c fn is
decided like any block: an arity mismatch, an unproven C scalar range, a
refused exposure, an unmediated retaining call are `compiler::
DiagnosticCode` values (`Arity`, `Type`, `ForeignBorrow`, `Direct`), an
accepted block is the ordinary call, and nothing is executed at compile
time -- the C function is never called by the compiler (`cf-static-compile`).

**HIR interchange** carries everything a C call needs past the front end:
the `foreign` and `links` side tables are the HIR's own, and the extern
natives' registrations are part of its `declarations`. A HIR written as
`.hirx` and read back in a fresh process lowers to the identical NIR and
runs (`cf-interchange`).

**The front-end cache** keeps a program that calls C as its build; a binding
module's text is a dependency like any imported module's, so a changed
library name, link symbol, signature or contract is a miss
(`cf-cache`). The front end reads no new input: no header, no library, no
link directory.

**Compilation isolation.** The extern natives and the link plan are a
declaration registry: `hir::foreign::capture`/`Install` are in
`hir::declarations`, every build drops the previous compilation's extern
natives first (`Reset`), and `hir::activate` re-installs a HIR's own. So
compiling another program -- with other externs of the same names, or none
-- never changes an earlier HIR's lowering, and no later compilation links
an earlier one's library (`cf-isolation`).

## 15. The single executable

The Botlish compiler executable is self-contained for ordinary Botlish
programs. Native FFI programs additionally depend on the host native linker
and the libraries they explicitly declare.

Concretely: the single executable (SINGLE-EXECUTABLE.md) links standalone
executables with the stub linker and carries no Rust runtime library. It
compiles a program that calls C and runs it on the Tcl backends (to its
first C call: `NATIVE-ONLY`), but the native link of one that calls C or
declares a library -- `-backend cranelift` as much as
`-emit-native-executable` -- is refused with the stub linker's message
(section 11; checked with `single/build.sh`'s executable: `NATIVE LINK`, the
program's symbols and libraries named). Linking one needs
the rustc linker of a Botlish checkout with its native backend built --
rustc, the runtime library and the system `cc`/`ld` -- and the declared
libraries. A system-linker mode for the single executable would need it to
ship the runtime as a linkable static archive (28 MB, measured: `cargo rustc
--crate-type staticlib`) and a second startup path; that is a packaging
decision for a later milestone, not part of the call. The compiler bundles
no Tcl, BoringSSL or system development library, and never will by this
design: a library is the program's declaration and the host's file.

## 16. Examples

**A scalar function.**

```botlish
import ffi::c

extern c library "m"

extern c fn labs(x: ffi::c::Long) -> ffi::c::Long

labs(-42)                               # 42 (labs is libc's; "m" shows a library)
```

**A pointer function.** Raw pointers cross as raw machine addresses; the
pointee is an opaque struct, the result's provenance states where it comes
from.

```botlish
import ffi::c

extern c library "tcl9.0"

opaque struct Interp:
    tag: unit

extern c fn Tcl_CreateInterp() -> ffi::c::Ptr[Interp] independent
extern c fn Tcl_DeleteInterp(interp: ffi::c::Ptr[Interp] noescape) -> unit

interp = Tcl_CreateInterp()
alive = not interp.null?()
Tcl_DeleteInterp(interp)
alive
```

**Bytes, read noescape.**

```botlish
import abi
import abi::bytes
import ffi::c
import str

extern c library "botlish_cffi_fixture"

extern c fn sum named "bcf_sum"(data: ffi::c::Ptr[ffi::c::UChar] read noescape, count: ffi::c::ULong) -> ffi::c::ULong

data = abi::bytes::from_list(str::encode_utf8("hello"))
sum(data, abi::bytes::length(data).value)        # 532: C read the Bytes' own storage
```

**MutableBytes, write noescape.** The call returns the bytes C wrote; the
caller's MutableBytes is unchanged (the imports and library as above).

```botlish
extern c fn fill named "bcf_fill"(out: ffi::c::Ptr[ffi::c::UChar] write noescape, count: ffi::c::ULong, seed: ffi::c::UChar) -> unit

m = abi::bytes::zeroed(abi::usize(5))
r = fill(m, 5, 7)
abi::bytes::freeze(r.out)                         # the bytes 7 44 81 118 155
# r.result is unit; m is still five zero bytes
```

**A direct retaining call.** A function that keeps its pointer is declared
`captures`; calling it is direct authority, acknowledged by the calling
module:

```botlish
direct module

import ffi::c

extern c library "botlish_cffi_fixture"

extern c fn keep named "bcf_keep"(p: ffi::c::Ptr[ffi::c::Void] captures) -> unit
extern c fn address named "bcf_address"() -> ffi::c::Ptr[ffi::c::Void] independent

p = address()
keep(p)
```

Without `direct module` the call is `DIRECT`: "the entry program uses
direct authority in its top-level code: it calls keep, a C function whose
contract lets it retain pointer authority past the call (parameter "p":
escape captures), and top-level code has no context, so the call is never
mediated; move it into a function that requires a context defined by the
entry program, or declare the module direct with `direct module` as its
first line".

**A renamed native symbol.**

```botlish
extern c fn plus named "bcf_add"(a: ffi::c::Int, b: ffi::c::Int) -> ffi::c::Int

plus(40, 2)                                       # 42; the link symbol is bcf_add
```

**A library dependency.** BoringSSL's static `libcrypto.a` needs the C++
runtime's `operator delete`: the binding declares that library too, as a
link-plan entry like any other.

```botlish
extern c library "crypto"
extern c library "stdc++"
```

## 17. The Tcl binding

`examples/ffi/tcl/tcl.bot` binds three functions of the installed Tcl 9 C
library (`libtcl9.0.so`), by their tcl.h signatures:

```botlish
extern c library "tcl9.0"

opaque struct Interp:
    tag: unit

extern c fn Tcl_CreateInterp() -> ffi::c::Ptr[Interp] independent

extern c fn Tcl_EvalEx(
    interp: ffi::c::Ptr[Interp] noescape,
    script: ffi::c::Ptr[ffi::c::Char] read noescape,
    numBytes: ffi::c::Long,
    flags: ffi::c::Int
) -> ffi::c::Int

extern c fn Tcl_DeleteInterp(interp: ffi::c::Ptr[Interp] noescape) -> unit
```

Tcl 9's `Tcl_Eval` is a macro, `Tcl_EvalEx(interp, script, TCL_INDEX_NONE,
0)`: the library exports `Tcl_EvalEx`, so that is what the binding declares,
and its `eval(interp, script)` is the macro's Botlish spelling. `Tcl_Size`
is `ptrdiff_t`, a C `long` on LP64. `examples/ffi/tcl/demo.bot` creates an
interpreter (non-null), evaluates `puts {hello from Tcl}; flush stdout`
(`TCL_OK`; Tcl prints the line), evaluates `error {deliberately}` (not
`TCL_OK`) and deletes the interpreter:

```
$ tclsh9.0 main.tcl -backend cranelift examples/ffi/tcl/demo.bot
hello from Tcl
[true, true, true]
```

on both native backends, from an application-module binding, with no
warning (`cf-tcl-acceptance`). The error text is not read: retrieving it
returns a `const char *`, and Botlish has no operation reading C memory
(no dereference, no C string: C-ABI-TYPES.md).

## 18. The BoringSSL binding

`examples/ffi/sha256/boringssl.bot` (the declaration at the top of this
document) binds `SHA256` of BoringSSL's pinned release, the header
archaeology's (`audit/c-header/profiles/boringssl.tcl`), whose
`include/openssl/sha2.h` declares `uint8_t *SHA256(const uint8_t *data,
size_t len, uint8_t out[SHA256_DIGEST_LENGTH])`.

**The library** is package-owned and static. `tclsh9.0
tests/cffi/boringssl.tcl` fetches the release into Botlish's cache
(audit/c-header/tools/fetch.tcl), builds `libcrypto.a` once with CMake and
Ninja under `BORINGSSL_PREFIX=botlish_bssl` (BoringSSL's own symbol-prefix
build), and prints its directory (`$BOTLISH_BORINGSSL_DIR`, else
`boringssl/COMMIT-botlish_bssl` in the cache; never the repository). Every
symbol it defines is prefixed, so the binding's `named
"botlish_bssl_SHA256"` can never be satisfied by an ambient system
OpenSSL: without this build the link fails. Botlish's compiler and runtime
never build, fetch or need it; a program reaches it only by `extern c
library "crypto"` and `-L`.

`examples/ffi/sha256/demo.bot` checks the digests of `""`, `"abc"` and
`"The quick brown fox jumps over the lazy dog"` byte for byte against their
published values, the write-back `MutableBytes` holding the digest C wrote,
the input Bytes and the original MutableBytes unchanged:

```
$ tclsh9.0 main.tcl -backend cranelift -L "$(tclsh9.0 tests/cffi/boringssl.tcl)" examples/ffi/sha256/demo.bot
[true, true, true, true, true, true]
```

on both native backends (`cf-sha256-acceptance`).

## 19. Standalone executables

`-emit-native-executable` (or `native::executable`) links a program that
calls C with its declared libraries into a standalone executable that runs
with no Tcl, no rustc and no source (`cf-executable`); the SHA-256 demo's
executable contains BoringSSL (its `botlish_bssl_SHA256` defined inside, no
libcrypto needed at run time: `cf-sha256-executable`).

## 20. GC stress

Under `BOTLISH_NATIVE_GC_STRESS=1` (a collection attempt at every allocation
site) the exposures survive real C calls: the fixture's read and write
borrows, the Tcl script bytes and the SHA-256 read and write borrows
(`cf-gc-stress`), and every fuzzer program (section 22). C cannot reach the
collector during a call (no callbacks), so a collection inside a foreign
call -- the borrowing milestone's `read_reentrant` -- is not reachable from
real C; that synthetic test (`cb-liveness-reentrant`) remains the guard of
an exposed storage's liveness across one, as it was designed to be.

## 21. Performance

`bench/c-ffi.tcl` (Linux x86-64, 4-core container, cranelift specialized,
best of 5; per-call numbers are a loop of N calls minus the same loop
without the call):

PERFORMANCE-TABLE

What this shows: a C call from a running native program is an ordinary
native call -- no process, no lookup, no copy of read-only bytes (the read
exposure's cost is flat in its size); a write exposure costs its detach
copy, linear in size, as C-POINTER-BORROWING.md measured; a 64-bit value
beyond the small Int range costs a BigInt conversion each way. SHA-256 runs
at BoringSSL's own speed. The link is the cost of an FFI program: linking a
temporary executable every run adds the system link (and a process start)
to `-backend cranelift`, which an executable pays once.

## 22. Tests, fuzzing, mutants

**`tests/c-ffi.test`** (CFFI-TEST-COUNT tests) covers the grammar and its
errors, declarations, the HIR table, ABI classes per target, the link plan,
call typing, borrowing through real C, pointer results and the contract
check, the transport, NIR and CLIF, the backend matrix, linking and its
failures, executables, the stub linker, main.tcl, direct, static compile,
interchange, the cache, isolation, the Tcl and BoringSSL acceptance and GC
stress. Its C side is `tests/cffi/fixture.c`, compiled with the host C
compiler into a static archive in a private directory (test infrastructure
only); the Tcl tests need a linkable `libtcl9.0`, the BoringSSL ones the
package-owned build (skipped when it is not built).

**The fuzzer** (`audit/c-ffi/tools/fuzz.tcl`) generates programs of random C
signatures -- 0 to 14 parameters of every scalar class, raw pointers (null
or an address), read and write byte pointers (`noescape` or `proven
noescape`); scalar, void, independent and alias pointer results; with and
without `named` -- writes them as real C, compiles them into a library,
binds and calls them with values drawn toward each type's bounds, and
compares what C saw of every argument, the result, the write-back bytes and
the caller's unchanged bytes with its own ABI model; on the Tcl backends
every program must be `NATIVE-ONLY`.

FUZZ-RESULTS

**Mutants** (`audit/c-ffi/tools/mutate.tcl`, `mutants.txt`): each a
deliberate bug, run against `tests/c-ffi.test` and the fuzzer in a private
copy of the tree.

MUTANT-RESULTS

## 23. Regression

REGRESSION-RESULTS

## 24. Architectural boundaries

| statement | |
|---|---|
| Botlish does not parse C headers during normal compilation. | **Confirmed.** The front end reads Botlish source; header archaeology (audit/c-header/) is research tooling nothing in the compiler loads. |
| Botlish does not analyze C implementations. | **Confirmed.** Every fact is the declaration's; the compiler never reads C code or object code (the link is the linker's). |
| `extern c library "foo"` means the platform linker's native library name. | **Confirmed.** It becomes `-lfoo`, searched by the linker's own rules (plus `-L`). |
| An extern function is not associated with one library. | **Confirmed.** The plan is the program's; every symbol is resolved against all of it (`cf-link-plan`, `cf-link-order`). |
| The system linker resolves symbols. | **Confirmed.** At link time, through rustc driving `cc`; nothing at run time. |
| A foreign call is not automatically direct. | **Confirmed.** Only a contract that may retain a pointer (captures, unknown) makes a call an authority source (`cf-direct-noescape-ordinary`). |
| Temporary byte borrowing still requires noescape. | **Confirmed.** The admission is the borrowing milestone's, unchanged (`cf-borrow-refusals`). |
| Raw foreign Ptr values can cross calls independently of borrowing. | **Confirmed.** A `Ptr` is a raw address word, passed and returned as one; a pointer result is borrowing's concern only when the same call exposes storage (section 7). |
| No callback/export mechanism exists yet. | **Confirmed.** Botlish never calls an `FnPtr`, and exports no C symbol. |
| No aggregate/varargs ABI exists yet. | **Confirmed.** Structs, unions and arrays by value, floating point and varargs are declaration errors. |

## 25. For a binding generator

The declaration is meant to be emitted mechanically from a declaration IR
such as the header archaeology's: one `extern c library` line per library,
one `extern c fn` per function, its parameters one per line, every fact a
word after its type:

```botlish
extern c library "foo"

extern c fn foo_frob named "foo_frob_v2"(
    handle: ffi::c::Ptr[Foo] noescape,
    data: ffi::c::Ptr[ffi::c::UChar] read proven noescape,
    len: ffi::c::ULong
) -> ffi::c::Int
```

Nothing in it needs a hand-written construct: no body, no wrapper, no
attribute syntax. A generator may choose a contract from headers, ABI
probes, compiler-produced `nocapture`/`returned` attributes (`proven
noescape`, `alias`) or manual metadata; compilation reads the contract and
never cares where it came from. The generator itself is future work.

## 26. Not here

* Header parsing or generation, bindings of whole APIs.
* Floating point, structs, unions and arrays by value, varargs, bitfields.
* Callbacks (Botlish code called from C), exported C symbols, calling an
  `FnPtr`.
* `dlopen`/`dlsym`, lazy binding, a runtime library path policy.
* C strings, a dereference, reading C memory, an ownership policy for
  `Ptr` (who frees what), retained stable storage (C-POINTER-BORROWING.md
  section 15).
* A Tcl-side FFI (libffi or otherwise) for the interp and compile backends.
* Linking from the single executable (section 15).

## 27. What to run when changing this

If you change the grammar (surface/parser.tcl's `ExternDecl`), hir/foreign.tcl,
the extern cases of hir/resolve.tcl, hir/hygiene.tcl, hir/borrow.tcl or
hir/direct.tcl, core/cabi.tcl's contract or `ExternImpl`, native/lower.tcl's
foreign table or `BorrowCall`, `Inst::ForeignCall` (native/src/nir.rs),
`foreign_call`/`c_signature` (codegen/clif.rs), runtime/ffi.rs, the link
step (codegen/aot.rs's `link_plan_args`, `emit_executable`) or the linked
run (main.rs's `run_linked`, runtime/aot.rs's `driver_protocol`), run
`tests/c-ffi.test` (also under `BOTLISH_NATIVE_GC_STRESS=1`),
`audit/c-ffi/tools/fuzz.tcl` (several seeds, once with `-gc-stress 1`) and
`audit/c-ffi/tools/mutate.tcl` (every mutant in its `mutants.txt` must
still apply and be killed: update a mutant's text when you change the code
it mutates, keeping it a mutant of the same rule), plus
`tests/c-pointer-borrowing.test` and its mutants for a change to the shared
exposure, `tests/direct-modules.test` and its mutants for a change to the
direct edge, and the isolation and interchange audits for a change to the
registry. Build BoringSSL once (`tclsh9.0 tests/cffi/boringssl.tcl`) so the
acceptance tests run. `bench/c-ffi.tcl` regenerates section 21.

## 28. Files

| file | |
|---|---|
| surface/parser.tcl | `AtExternDecl`, `ExternDecl`, `ExternParam`: the grammar and its `EXTERN-SYNTAX` errors |
| surface/ast.tcl, surface/lower.tcl, surface/modules.tcl | the AST nodes, their collection per unit, the loader passing them to the build |
| hir/foreign.tcl | registration, validation, the link plan, bindings, the side tables, capture/Install |
| hir/hir.tcl, hir/declarations.tcl, hir/resolve.tcl, hir/hygiene.tcl, hir/semantic.tcl, hir/warnings.tcl | the build's options and side tables, isolation, the root-kind bindings and their names |
| hir/borrow.tcl | the extern arity, the result provenance, not-a-value |
| hir/direct.tcl | the retaining call as an authority source |
| core/native.tcl, core/cabi.tcl | `-extern` metadata, `isExtern`, `displayName`; the provenance in the contract, `ExternImpl` (NATIVE-ONLY) |
| native/lower.tcl, native/native.tcl, main.tcl | the foreign table, `foreigncall`, link directories, `-L` |
| native/src/nir.rs, codegen/clif.rs, codegen/roots.rs, codegen/mod.rs | the NIR, the C call and its transport, the safepoint, the JIT's unlinked symbols |
| native/src/codegen/aot.rs, native/src/main.rs, native/src/runtime/aot.rs | the link plan's arguments, linker failures, the stub's refusal, the linked run and its driver protocol |
| native/src/runtime/ffi.rs, runtime/error.rs | the slow paths and the two failures |
| examples/ffi/ | the Tcl and BoringSSL bindings and demos |
| tests/c-ffi.test, tests/cffi/fixture.c, tests/cffi/boringssl.tcl | the tests, the C fixture, the package-owned BoringSSL |
| audit/c-ffi/tools/ | the fuzzer, the mutation tool and its mutants |
| bench/c-ffi.tcl | the performance report |
