# Eliminate automatic type predicates

> **No type declaration makes the type callable. No user-defined or domain
> type automatically gets a `PascalCase?` predicate. Proof-producing
> predicates and validators are ordinary, explicitly annotated functions;
> conversion is an ordinary function returning the refined type.**

## Outcome

Done. A source `type D = Int in LO..HI` used to register a root native `D?`
(`m::D?` for a module's type): its membership predicate. It resolved bare,
qualified, through an alias and by method sugar, and native lowering could
not compile it unless HIR had already decided the call. That mechanism, its
resolver fallbacks, its loader allowance, its registry bookkeeping, and the
dead native constructor lowering that sat next to it are deleted. No other
automatic type predicate exists: not for refinements, structs or enums, and
not for built-in types (section 7).

A domain is entered through ordinary Botlish:

| route | shape | proves | annotation |
|---|---|---|---|
| converter | `fn small(x: int) -> Small errors OutOfRange` | its *result* is a `Small` | none: the declared result is checked |
| comparisons | `if 0 <= x and x <= 9:` / `if x < 0 or x > 9: return ...` | `x` is in the domain on that edge | none: range facts |
| refinement over the domain | `refined type Even = Small` with `even?` / `validate_even` | the argument is an `Even` | `proves x: Even` (unchanged) |

Doing this took three general repairs, and no new semantic category:

1. **Range facts through `and`/`or`/`not`.** The range analysis now
   decomposes a condition's Boolean structure into paths
   (`hir::range::Paths`, `OutcomeFacts`). The completion analysis shares
   the same code. Before, only the completion analysis decomposed
   conditions, and only conjunctions (PROOF-FACT-CENSUS.md's gap G11, now
   closed). So `if x < 0 or x > 9: fail OutOfRange` proves a converter's
   result, and `if 0 <= x and x <= 9:` admits `x`, with no nested `if`s.
   `small(3)` needs no handler and `small(12)` is a `KNOWN-ERROR`, through
   the `or` guard.
2. **An empty Range is vacuous.** A branch whose condition cannot hold
   under the facts so far is dead. Its bindings' empty Ranges now prove any
   domain. Before, that held only by accident of the bounds' order.
3. **A Range never proves a refinement (a soundness fix).** A refinement
   over an integer domain (`refined type Even = Small`) inherits the
   domain's integer facts. So any in-range `Small`, including the exact
   `4`, was admitted where an `Even` was required, with no proof. On the
   unmodified tree, `fn p(x: Small) -> int: half(x)` compiled and ran.
   `hir::range::ProvesType` now proves only the integer-domain part. A
   refinement must already be in the value's static type.

## 1. The original blocker, traced

`type Small = Int in 0..9` reached `hir::sourcetypes::RegisterOne`
(`hir/sourcetypes.tcl:521-523` at the base). That called
`core::type::declareIntConstructor`, which called `definePredicate`
(`core/type.tcl:358, 444-462`). That registered a root native `Small?` with
`-impl {core::type::PredicateImpl Small}` and `-tests-type {refined int
{Small}}`. Then `core::native::markSource` put it in `sourceNatives`, so the
loader and `isQualifiedNative` would not take it for an intrinsic. Each
backend handled it differently:

* **interp** called `PredicateImpl`, which ran the type's validator from the
  registry at run time.
* **compile** inlined `core::type::acceptsCanonical {refined int {Small}}`
  (`compiler/compiler.tcl:1505`, `InlineTypeTest`), the same registry
  lookup per call.
* **native**: `NativeCall` (`native/lower.tcl:7543-7575`) found no entry
  for `Small?` in its `natives` table. It tried `CheckedIntDomainConstruct`,
  which matches only `-impl {core::type::CheckedConstruct ...}`, an impl
  nothing had registered since EXPLICIT-ERROR-COMPLETIONS.md. It then raised
  `NATIVE UNSUPPORTED {native Small?}`. A second guard further down ("type
  tests of named types need evidence") would have rejected it anyway. Only
  when `hir/types.tcl`'s `Call` had already decided the call statically
  (`known`, `hir::refine::decideTypeTest`) did native lowering emit `bool
  true/false` without needing the native.

A predicate over a value the program could not decide statically, the only
case where a run-time test is worth anything, was exactly the unsupported
one. The milestone ruled out fixing this with a native `Small?` lowering.
Nothing was added to native lowering; the predicate is gone.

## 2. What was removed

| removed | where (base) | what it did |
|---|---|---|
| `core::type::declareIntConstructor` | core/type.tcl:358 | called `definePredicate` for every domain |
| `core::type::definePredicate`, `PredicateImpl` | core/type.tcl:444-462 | registered `NAME?` (the `$name?` default) as a `-tests-type` native |
| `core::type::CheckedConstruct` | core/type.tcl:344 | the old `Byte(x)` constructor's implementation; dead since EXPLICIT-ERROR-COMPLETIONS.md |
| the `RegisterOne` registration | hir/sourcetypes.tcl:521-523 | `declareIntConstructor`, `markSource $id?`, generation entries `{native $id} {native $id?}` |
| `Reset`'s native branch | hir/sourcetypes.tcl | unregistered those natives between compilations |
| `core::native::markSource`, `sourceNatives` | core/native.tcl:222-225, 648-697 | marked the predicates as non-intrinsic; `isQualifiedNative` and `qualifiedMembers` skipped them |
| the `natives` part of a HIR's declaration state | hir/declarations.tcl:50-67, 128-131 | captured and reinstalled the predicates per HIR (COMPILATION-ISOLATION.md) |
| `ResolveQualifiedRef`'s fallback | hir/resolve.tcl:1766-1773 | `ns::T?` resolved to the native when ns had no such binding |
| `ResolveRef`'s fallback | hir/resolve.tcl:1879-1886 | a bare `T?` inside module m resolved to the native `m::T?` |
| `hir::resolve::NativeNamed` | hir/resolve.tcl:1860 | the two fallbacks' helper |
| the loader's allowance | surface/modules.tcl:905-907 | accepted `ns::SYM` when SYM ended in `?` and its stem was a type of ns |
| `native::lower::CheckedIntDomainConstruct` | native/lower.tcl:7492-7541, 7564-7567 | lowered the dead constructor impl |
| the "named types need evidence" guard | native/lower.tcl:7572-7575 | rejected named-type `-tests-type` natives other than `ok?`/`error?`: none remain |

`core::native::unregister` stays, minus its `sourceNatives` half: tests use
it to remove the probe natives they register. The generic `-tests-type`
facility stays too: it is how `ok?`/`error?` and the kind tests are
registered (section 7). It now refuses a refinement type, since a
refinement's membership is a proof. That check used to live only in
`definePredicate`.

## 3. The final path of a representative converter

```
type Small = Int in 0..9
error OutOfRange

fn small(x: int) -> Small errors OutOfRange:
    if x < 0 or x > 9:
        fail OutOfRange
    x
```

* **HIR.** An ordinary `bind` of a `block` whose declared result is
  `int[Small]` and whose declared error is `OutOfRange`. The `or` lowers
  to `if x < 0: true else: (if x > 9: true else: false)`. Nothing in HIR
  names a predicate.
* **Proof at the return.** `hir::range::verifyDeclaredResults` analyzes the
  body with `x` unknown. The guard's false edge has one path, `{x < 0 → 0}
  {x > 9 → 0}`, so `OutcomeFacts` narrows `x` to `[0, 9]`. The `fail` edge
  never completes, so after the `if` only the false edge's bindings remain
  (`JoinBindings`). The result `x` has Range `[0, 9]`, and `ProvesType` admits
  it as `int[Small]`. This is the same check every function's declared
  result gets.
* **Completion.** `small(x)` may complete normally or fail `OutOfRange`. A
  caller handles it or declares it. An exact `small(3)` is decided: the
  guard's true edge has two paths, `x < 0` and `x >= 0 ∧ x > 9`, and both
  are infeasible for `[3, 3]`. So the call needs no handler. `small(12)`
  makes the false edge's only path infeasible: `KNOWN-ERROR`.
* **NIR** (cranelift, the generic `int` instance): ordinary comparisons and
  branches, a `faildeclared`, and a raw result. No call, no native, nothing
  named after the type:

  ```
  %3 = op ilt %0 %1          ; x < 0
  br %3 L0 L1
  ...
  %8 = op igt %0 %6          ; x > 9
  br %8 L3 L4
  ...
  br %4 L6 L7
  label L6
  faildeclared 2 "OutOfRange"
  label L7
  ...
  %14 = op runbox %0         ; x, proven [0, 9]: a raw result
  ret %14
  ```

  Called from a function specialized on the inputs of a literal list, the
  instance's `x < 0` is decided and only `rigt` (a raw compare) remains.
  `use_small`'s `s + 100` is inlined as a raw `riadd`.
* **Machine code.** In CLIF, each comparison is the ordinary tagged-Int
  compare any `<` gets: an inline `icmp` when both operands are small Ints,
  the runtime's comparison helper when one is a big Int (the argument is an
  unbounded `int`). Each is followed by `brif`. In the specialized raw
  instance (`rigt`), it is a single `icmp` (section 8 has timings).
* **Source equivalence.** The same converter declared in a module lowers to
  the same NIR function body, apart from the error's module-qualified
  identity (`tp-converter-source-equivalent`). Nothing below HIR knows where
  a converter comes from. The standard library's converters (`std::byte::from_int`,
  `std::abi::u8`, ...) are ordinary module functions in the same way
  (`tp-library-converter-is-ordinary`).

## 4. Converter, validator, predicate

A converter is a pattern, not a construct. No callable kind, intrinsic,
lowering, completion rule, ownership rule or method rule was added. The
documentation (REFINEMENT-VALUES.md, "Converters, and why a type is never
callable") states it next to the two proof forms:

| | predicate | validator | converter |
|---|---|---|---|
| shape | `T -> bool proves x: R` | `T -> unit proves x: R errors E` | `T -> R errors E` |
| refines | the argument, true edge only | the argument, after normal completion | the result only |
| argument afterwards | unchanged off the true edge | `R` | unchanged |
| annotation | yes | yes | no: the result check is the proof |

`proves` names a refinement, never an integer domain. `fn small?(x: int) ->
bool proves x: Small` is `PROOF-CLAUSE`, unchanged. A domain's membership is
the range analysis's job, so the comparisons themselves act as its
predicate. The existing forms are untouched: no change to `hir/refine.tcl`,
`ResolveProofs`, or the predicate/validator rules. The refinement fuzzer's
existing modes and every refinement, validator and predicate test pass
(section 10).

## 5. Standard library

No standard-library API changed. Nothing in `stdlib/`, `examples/` or `bench/`
called an automatic predicate. The census found real calls only in tests,
all migrated. The predicates that disappeared were registered as an
unused side effect:

| module | natives no longer registered | ordinary API that remains |
|---|---|---|
| `byte` | `std::byte::Byte?`, `std::byte::Nibble?`, `std::byte::LowNibble?`, `std::byte::HighNibble?` | `std::byte::from_int` (converter), the domain-typed operations |
| `abi` | `std::abi::I8Value?` ... `std::abi::UsizeValue?` (ten) | `std::abi::i8` ... `std::abi::usize` (converters to the nominal structs) |
| `std::abi::x86_64` | `std::abi::x86_64::Register64Word?` | `register64`, `to_int` |

The source compatibility impact is a clean break. Code that called `T?`
now gets the ordinary `UNBOUND` (or `UNKNOWN-SYMBOL` for `ns::T?`, or
`NOT-A-STRUCT` naming the missing function for `x.T?()`). No
`AUTOMATIC-TYPE-PREDICATE-REMOVED` diagnostic was added, and there is no
compatibility alias.

## 6. Generated range helpers

| helper | what it was | now |
|---|---|---|
| `NAME?` per domain | an automatic predicate native | removed |
| `NAME(x)` per domain | checked constructor native, removed by EXPLICIT-ERROR-COMPLETIONS.md | its leftover implementation (`CheckedConstruct`) and native lowering removed |
| a domain's integer facts | `core::type::integerFacts` | an internal compile-time proposition only (it was always that) |

Elaboration synthesizes no function. The milestone did not need one.

## 7. Census of predicate-like mechanisms

| mechanism | spelling / example | type/domain-generated? | compiler special case? | status | justification |
|---|---|---:|---:|---|---|
| domain membership predicate | `Small?`, `std::byte::Byte?`, `std::abi::U8Value?` | yes | yes (resolver, loader, registry, declarations, compile inline test; native unsupported) | **removed** | — |
| `definePredicate` API | `core::type::definePredicate T` → `T?` | yes (name derived from the type) | — | **removed** | test fixtures register their type tests explicitly (`non_empty?`, `lower_ascii?`) |
| checked domain constructor | `Byte(x)`, `CheckedConstruct`, `CheckedIntDomainConstruct` | yes | yes (dead) | **removed** (the dead remainder) | — |
| kind tests | `integer?`, `string?`, `list?`, `mutarray?` | no: four explicit registrations (core/predicates.tcl), names chosen, not derived | inline in the compiler (`InlineTypeTest`) and NIR ops `isint`/`isstr`/`islist`/`ismutarray` | **kept** | a core primitive: the one way to branch on the run-time kind of an `any` value (untyped parameters, heterogeneous lists). Its answer is the value's kind, a run-time fact; no proof stands in for it. |
| Result tag tests | `ok?`, `error?` | no: explicit registrations over the `Result.ok`/`Result.error` validator types | compiler intrinsics, NIR `isok`/`iserror` | **kept** | a core primitive of the Result value's tag |
| `std::coroutine::done?`, `std::mutable_vector::empty?` | `?`-named natives | no | no | **kept** | state queries of a value, not type membership |
| user predicates | `std::web::emailish?`, `std::web::uri_query_value?` | no: source functions with `proves` | no | **kept** | the established predicate form |
| user validators | `std::linux::path::validate`, `std::io::path::validate` | no | no | **kept** | the established validator form |
| user converters | `std::byte::from_int`, `std::abi::u8` ... | no | no | **kept** | ordinary functions returning the domain |
| `-tests-type` facility | `core::native::register NAME -tests-type T` | no: a registration names its type | `hir::refine::decideTypeTest`, `InlineTypeTest` | **kept**, now refusing a refinement `T` | the generic mechanism of the kind and tag tests; refinements never have a run-time test |
| nominal construction | `Point {x: 1}`, `Light::Red` | — | yes (construction syntax, case resolution) | **kept** | compiler-owned construction syntax, not a call; a type name is never a callee (`Point(1)`, `Point?` are unbound) |
| PROVES-NAMING | `?` / `validate_` convention | no | a warning reads the written name | **kept** | names of user proof functions; carries no semantics |

Searching by behavior, not spelling, found nothing else. No code calls a
type, decides domain membership from a callee's identity, has a
refined-type constructor returning Bool, or turns a type declaration into a
callable value. `tp-source-audit` keeps it so: it greps the compiler,
runtimes and backends for the removed mechanism's names, for a `NAME?` built
from a variable, and for any test of a name ending in `?` outside the
PROVES-NAMING warning.

**Built-in and core types.** No built-in type gets an automatic predicate.
`Int?`, `String?`, `Bool?`, `List?`, `UnicodeChar?` and the rest are unbound.
The kind tests are spelled `integer?`/`string?`/`list?`/`mutarray?` and
registered one by one. Nothing iterates over types to produce them, there is
none for `bool`, `unit`, `UnicodeChar`, `immutableSet`, `struct` or `enum`,
and none for any named type. They stay as genuine core primitives:
discriminating an `any` value's run-time kind is not something a proof or a
converter can do. Removing them would remove the language's only dynamic
kind test, which this milestone did not set out to do.

## 8. Code generation and performance

Before, a dynamic domain test could not run natively at all
(`NATIVE UNSUPPORTED {native Small?}`). After, it is the comparisons
themselves. The benchmark is `ys = loop i from 0 to N: step(mod(i, 20) -
5)`, with `step` admitting `v` into `Small = Int in 0..9` each way. It was
measured on the unmodified tree ("before") and this one ("after"),
back to back, on a 4-core container that was also running audit harnesses.
Differences of a few percent are noise. Tcl times are the mean of 3
(interp) or 5 (compile) runs. Native times include starting the process
and compiling the program (about 30 ms at N = 1).

| `step` admits `v` by | before | after |
|---|---|---|
| `if Small?(v):` (N = 20,000) | interp 5.7 s, compile 214 ms, native **unsupported** | — (no such name) |
| nested `if 0 <= v:` / `if v <= 9:` (N = 20,000) | interp 7.2 s, compile 138 ms, native 28 ms | interp 7.0 s, compile 135 ms, native 30 ms |
| `if 0 <= v and v <= 9:` (N = 20,000) | rejected: `and` did not narrow | interp 7.5 s, compile 177 ms, native 36 ms |
| the converter `small(v)`, handled (N = 20,000) | interp 8.6 s, compile 170 ms, native 38 ms | interp 8.7 s, compile 144 ms, native 37 ms |
| native, N = 3,000,000 | nested 204 ms, converter 398 ms, `Small?` unsupported | nested 214 ms, `and` 220 ms, converter 321 ms |

In the Tcl compiler, `Small?` was a registry lookup and a validator run per
test (214 ms). The comparisons cost 135 ms nested and 177 ms through `and`,
whose Boolean the lowering materializes. The interpreter is the reference
semantics, not a performance target: two evaluated comparisons cost it
more than one native predicate call. Natively, every form is compares and
branches; the converter adds a call with an error exit.

What remains unoptimized is not new. `and`/`or` still materialize their
Boolean (`%4 = move ...; br %4`) before the branch, as for any condition:
177 ms against 135 ms in the Tcl compiler, about 3% natively. That is an
existing lowering of `if` expressions used as conditions, and an
optimization opportunity, not a regression. A converter
called with a dynamic argument stays a call unless tiny-leaf inlining
applies (TINY-LEAF-DEFAULT-ON.md). Its body is the compare/branch shape
above.

## 9. Tooling and discovery

There is no CLI command that lists symbols, definitions or methods.
`-hir` prints a program's HIR, which never mentioned the predicates (they
were natives), and `-emit-nir` now shows the comparisons. The single
executable packs the same compiler. Built with `single/build.sh` and run
from a directory with no repository, it compiles and runs a converter and
a comparison-guarded program on all four backends and as an
`-emit-native-executable` standalone executable, with the same values.
It reports `Small?(3)` as `unbound name "Small?"`. Its diagnostics are
the ones above, so an agent that writes `Small?(x)` gets `unbound name
"Small?"`, and `x.Small?()` explains that no function of that name is
visible. Neither suggests the converter for a program's own domain. For a
module's type, the qualified spelling does better: `std::abi::U8Value?(3)`
reports `namespace "std::abi" has no definition "U8Value?" (it defines: i16,
i32, i64, i8, isize, u16, u32, u64, u8, usize)`, which lists the
converters. There is no agent harness for the single executable to record
more. The docs that taught `T?` (IMPORTS.md, ABI-NUMERIC-DOMAINS.md,
SOURCE-DEFINED-INTEGER-DOMAINS.md, STDLIB-NAMESPACES.md,
COMPILATION-ISOLATION.md, the README's type-test section, AGENTS.md) now
teach converters and comparisons.

## 10. Tests, fuzzing, mutation

* **tests/type-predicates.test** (26 tests): no native registered for any
  domain of the program or the standard library; every spelling of a type
  as a value unbound, for a domain, refinement, struct and enum; modules
  (`ns::T?` UNKNOWN-SYMBOL, `import type` binding no `T?`, a bare `T?`
  inside the module unbound); method candidates; `proves` of a domain
  rejected; `-tests-type` of a refinement rejected; converters (result type,
  argument unchanged, errors, exact arguments, seven guard shapes accepted,
  six broken ones rejected, a module's converter); comparisons (`and`,
  `or`, `not`, early return, five accepted and four rejected shapes, all
  backends); a refinement over the domain with predicate, validator and
  converter, and the soundness fix; the shapes and node budget of
  `hir::range::Paths`; NIR of converters and comparisons; the source audit.
* **tests/golden/type-predicates.bot** (49 golden tests, every backend):
  the source-observable part of the above through `static compile:` and
  `std::compiler::DiagnosticCode` (`Unbound`, `NotAStruct`, `UnknownSymbol`,
  `ProofClause`, `Type`, `KnownError`, `UnhandledError`). Census and
  fragment rows map it to the Tcl tests.
* **Fuzzing.** `audit/refinement-values/tools/fuzz.tcl -domains 1`
  (domains.tcl) adds a program family to the existing refinement fuzzer:
  random small domains; converters with random guard shapes, a quarter of
  them broken; uses of `x` under random `and`/`or`/`not` comparison guards;
  a refinement over the domain with predicate, validator and converter, each
  also drawn as a misuse; an exact top-level converter call. An independent
  oracle checks acceptance, the rejection's kind and the value on all four
  backends. Seeds 1-5 with 100 programs each: 370 accepted, 130 rejected
  (48 with a broken converter), 0 failures. Seed 7 also passes under
  `BOTLISH_NATIVE_GC_STRESS=1`. Before the empty-Range repair the fuzzer
  failed on dead branches (3 of 60 programs on seed 1). That is how that
  repair was found.
* **Mutation.** `audit/type-predicates/tools/mutate.tcl` with 14 mutants:
  type names resolving as predicates again, the loader admitting `ns::T?`,
  a converter's result unchecked, a converter refining its argument, the
  predicate and validator annotations ignored, a Range proving a
  refinement, conditions not decomposed, disjunct facts intersected,
  infeasible paths kept, path order ignored, the node budget spent up
  front, the completion analysis seeing one path, native lowering
  recognizing `NAME?`. All 14 are killed, 13 by the unit tests and one
  (`completion-disjunction-unseen`) by the fuzzer.

Migrated tests:

* `ci-domain-*`, `ci-unit-reuse`, `ci-coretext-cache-declarations` and
  `ci-activation-switches`/`-declarations-recorded`
  (compilation-isolation.test) now isolate a domain read through a
  converter's facts on every backend. They also pin that no native is
  registered.
* `hx-roundtrip-in-process`'s other program, `imports-type-no-predicate`
  (was `imports-type-predicate`), and `abi-numeric-no-compiler-knowledge`
  (zero `abi::*Value?` natives, was ten).
* The `NonEmpty?`/`LowerAscii?` fixtures of refined.test, hir-refinement,
  hir-types, hir-lowering and types.test became explicitly registered type
  tests `non_empty?`/`lower_ascii?`. They keep exercising `-tests-type` for
  a validator type. `type-12` now pins the registry's refusal of a
  refinement.
* `xcheck-and-or-conjunct-narrowing` (range-completions-crosscheck.test)
  documented gap G11. The two analyses now agree.
* `dormant-refined-checks-char-at-nir`: `char_at`'s `i + 1` is a raw add
  even with dormant instances off. The `or` guard narrows `i`.

Regression runs, all on this branch:

| run | result |
|---|---|
| `tests/all.tcl` (interp and compile, all 174 test files, 4 at a time, on the final tree) | 14,814 passed, 4 skipped, 0 failed |
| `tests/golden.test`, `BOTLISH_GOLDEN_SUITES=all` (every suite, four backends) | 90 / 90 |
| `audit/golden/tools/perturb.tcl tests/golden/type-predicates.bot` | invert 49/49 and alter 49/49 failed as required |
| `audit/golden/migration/merge.tcl -check 1` | 8,810 manifest rows, no problem |
| `tests/native-coverage.tcl` | native 2,990, independent 4,290, passed-partial 69, unsupported 60 (harness-only natives, as before), failed 0 |
| `BOTLISH_NATIVE_GC_STRESS=1` on type-predicates, refinement-values, refinement-validators, abi-numeric, native-byte, dormant-instances | 236 / 236 |
| `audit/refactor/tools/gate.tcl` (the warning gate) | passed: the observed warnings are exactly the manifest |
| `audit/refinement-values/tools/fuzz.tcl` (seeds 1, 11; seed 3 `-validators 0`) | 0 failures |
| `audit/structural-contracts/tools/fuzz.tcl` (seeds 1-3; `-fault carrier/unknown/drop`) | 0 disagreements |
| `audit/error-payloads/tools/fuzz.tcl` (seeds 1-2; `-fault unhandled`) | 0 disagreements |
| `audit/static-decisions/tools/fuzz.tcl` (seeds 1, 17, 41) | 0 failures |
| `audit/static-decisions/tools/compare.tcl tests/golden/*.bot` (batched against sequential) | 88 of 89 suites agree, no misprediction; `mutable-array.bot` did not finish under the sequential scheduler: not within the 2-hour run limit, and, after merging main's front-end reuses (method-call decisions, the demotion re-check), not in 2 h 37 min either (233 static blocks; the sequential order is one build per typed rejection, and the reuses make a build cheaper, not fewer) |
| `audit/compilation-isolation/tools/interleave.tcl` | 72 artifacts and outcomes, 0 differ |
| `audit/hir-interchange/tools/roundtrip.tcl -via interchange` / `-via cache` | 81 / 90 compared, 0 differ |
| mutation: type-predicates / compilation-isolation / hir-interchange / structural-contracts / error-payloads / static-decisions | 14/14, 14/14, 24/24, 18/18, 44/44, 66/66 killed |
| `single/build.sh`, then the executable run outside the repository | all four backends and a standalone executable agree |

The compilation-isolation harness had one survivor, `activate-rununit`.
That mutant became equivalent: compiled Tcl code no longer reads a
declaration as it runs (the predicate was the one thing it read by name).
So `runUnit`'s activation was removed with the mutant, and the harness
kills the remaining 14.

## 11. Documentation

* REFINEMENT-VALUES.md: the doctrine and the converter pattern ("Converters,
  and why a type is never callable").
* Current-behavior docs updated: AGENTS.md (compilation isolation),
  COMPILATION-ISOLATION.md, IMPORTS.md, ABI-NUMERIC-DOMAINS.md,
  SOURCE-DEFINED-INTEGER-DOMAINS.md, STDLIB-NAMESPACES.md, README.md
  (type tests), PROOF-FACT-CENSUS.md (G11 closed).
* Historical reports keep their history, with a note where a claim became
  wrong: STRICT-TYPED-PARAMETERS.md, M5-CHECKED-DOMAIN-FACT-PROVENANCE.md,
  MINIMAL-APPLIED-LIST-TYPES.md, LINUX-X86-64-SYSCALL.md,
  EXPLICIT-ERROR-COMPLETIONS.md.
* Left as history: the remaining `Emailish?`/`UriQueryValue?`/`NonEmpty?`
  mentions in milestone reports (NATIVE-EMAILISH.md,
  R2-ORDINARY-EMAILISH-PREDICATE.md, NATIVE-OPAQUE-REFINEMENT.md,
  OPAQUE-TYPE-PREDICATE-FINDINGS.md, R2A*.md, ...) and in archived audit
  artifacts (`audit/*/out`, probe `.ir` files). They describe natives
  removed earlier, by REFINEMENT-VALUES.md.

## 12. Limitations and follow-ups

* An integer domain has no proof clause, so a function can never mint a
  domain fact for its caller's binding. The comparisons (or a converter's
  result) are the only way in. Wrapping the comparisons in a Bool function
  `small?(x)` proves nothing, by design (no postcondition inference).
* `Paths` decomposes a condition into at most 16 paths and visits at most
  64 of its nodes. Past either limit a subcondition proves nothing (sound).
  The node budget matters: without it, a long `and`-reduced value (the
  generated checks of tests/native-csv-records.test, one `and` of hundreds
  of operands) cost cubic time, because every operand's `if` re-derives the
  whole chain below it. Without the budget, its first property case took
  22 s instead of 9 s, and the file did not finish in 25 minutes. With the
  budget, its four property cases take 124 s, against 140 s on the
  unmodified tree.
* Conditions over `==`/`!=` narrow only through exact value sets, as
  before.
* Native lowering still materializes an `and`/`or` Boolean before
  branching on it (section 8).
