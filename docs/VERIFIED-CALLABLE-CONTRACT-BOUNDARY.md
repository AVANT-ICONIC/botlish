# VERIFIED-CALLABLE-CONTRACT-BOUNDARY.md

Fixes the completion-analysis precision gap C3 of GOLDEN-TEST-FRAMEWORK.md:

> The erased-callable contract is charged to calls whose static type is a
> checked structural contract (`Fn{..., errors: [...]}`), and includes errors
> from unrelated callables passed through untyped parameters elsewhere in the
> program.

and establishes in its place:

> **Verified callable contract boundary.** When a callable value has been
> proven to satisfy a structural `Fn` or `Coroutine` contract, calls through
> that structural value are bounded by the contract's declared error set
> even when the callable's exact identity is unknown. The erased-callable
> contract is used only where no checked callable contract bounds the call.

All three statements of the success criterion hold at once:

* **A. Genuinely erased calls stay conservative.** A call through an
  uncontracted value (static type `any` or a bare kind) whose identity is
  unknown is still charged the erased-callable contract and makes its walk
  incomplete (`scc-untyped-still-conservative`, every `hoc-*` test).
* **B. Verified structural calls trust their contract.** A call through a
  value of type `Fn{..., errors: C}` may raise at most C, however the value
  was stored or passed (`scc-transports`, `scc-one-error-*`,
  `scc-multi-error`, `scc-namespaced`, the golden runner).
* **C. Exact identity may still narrow below C** (`hoc-precise-recovery`,
  `scc-exact-narrows-contract`).

The golden framework's deferred registry compiles for the same reason any
callback registry compiles now: `TestCase.run` was proven to be an
error-free callable, and losing which test function it holds does not erase
that proof.

The repair made the boundary real, not assumed: the type checker proved
only a callable's *declared* errors fit a structural type, and two
pre-existing soundness holes followed from that (both found while building
this milestone, both escaped at run time on the tree before, both now
compile-time TYPE errors): a function with an untyped parameter it calls,
given a `Fn` type whose argument type is an error-bearing contract
(contravariant erasure); and a coroutine handle leaving the body that
constructed it, whose root calls an untyped callable passed to its
construction.

## Contents

* [The model](#the-model)
* [Report](#report) -- the 54 points of the milestone report, in order
* [Files](#files)
* [What to run when changing this](#what-to-run-when-changing-this)

## The model

### Identity precision and contract precision

| | |
|---|---|
| identity precision | which callable a value is: `{block B}` / `{native N}` -- its body can be analyzed under the call's own facts |
| contract precision | which callable contract it is proven to satisfy: a structural `Fn` or `Coroutine` type |

They are orthogonal. A value of `Fn` type stored in a struct field has
contract precision and no identity; `make(raise)` returned from another
activation has identity (`{block inner}`) and no contract for what it
captured; `x` read from a `List[any]` has neither. The precision order of a
call:

1. **exact / recovered** -- the callee's effective errors under the call's
   facts (may narrow below its contract);
2. **verified structural contract** -- the contract's errors;
3. **uncontracted** -- the erased-callable contract, the walk incomplete.

### Callable facts

`hir::completions::CallableFact` gains one fact, `{contract ERRORS ARGS}`:
identity unknown, contract known (a value of `Fn` type, or one that had it
where it was passed into an untyped parameter). The static type is the one
source of truth: the fact is the static type's contract
(`TypeFact`/`ContractFact`), carried only across an erasure into an untyped
parameter, where the static type no longer says it.

| fact | an uncontracted call is charged | a call through a `Fn` is charged |
|---|---|---|
| `{block B}` | B's effective errors under the call's facts (recovery) | the same, *within* the contract (`Within`) |
| `{native N}` | N's errors, plus what an argument it may call carries | the contract |
| `{contract E A}` | E, plus what an argument carries where A types it with a contract no one checked (`ContractChannel`) | E within the contract |
| `clean` | nothing: charged where it was passed | the contract |
| `unknown` | the erased-callable contract; incomplete | the contract |

### The boundary check

Trusting a contract is sound only because every value acquiring one is
checked against it. `hir::types::subtype` proves what a callable's type
*declares* fits; `hir::completions::Subsume` proves what its type does not
show. At every position where a value of exact callable type (or of another
`Fn` type) acquires a structural `Fn` type -- call arguments
(`hir::callables::ArgContexts`), struct fields, `if` joins, collecting
loops, handler values, `return`, `break`, a body's trailing value, the value
a `yield` sends into its coroutine's outward type -- the callable's body is
analyzed (`SubsumedRaises`) with

* each **parameter** holding what the contract's argument type admits: a
  contract's errors (`{contract C_i A_i}`), or for an uncontracted argument
  type (`any`) whatever the program erases -- a callable that calls a
  parameter the contract leaves untyped must admit anything a value there
  may raise, because every call through the contract trusts it whatever it
  passes (`ArgumentFact`);
* each **capture** holding what it holds there: this walk's facts for a
  closure the same activation created; a clean or unknown capture standing
  for every value its function's calls can pass it (`Possible`).

An error outside the contract is a TYPE error at the value (one per error
name). The check runs in each body's own check (`checkBlock`), where an
untyped input is `Possible`, so it holds for every activation of the body
however that body is later reached -- an analysis under one caller's facts
has nothing to add.

`Possible(b)` is a least fixpoint over the program's uncontracted bindings:
a parameter of a function only ever called (every reference to its binding
is a callee) holds exactly what its calls pass; a local what it is bound to;
anything else whatever the program erases. It records, beside the errors,
whether every value the binding holds is *quiet* -- never calls an argument
it is given -- so that a call through it charges nothing for its arguments.

A coroutine handle is the same boundary for `Coroutine` types:
`SubsumeHandle` analyzes the thunk of a handle that leaves the body
constructing it (passed, stored, returned) and checks what its root raises
through what was passed to its construction against the handle's contract.

### Contravariant erasure

A callable with an untyped parameter given a `Fn` type whose argument type
is error-bearing receives, at every call through the type, values the type
admits, into a parameter that forgets them: an erasure as real as a
semantic instance's. `erasedErrorsOf` now adds those argument types'
`CarriedErrors` (`staticsOf`'s `contravariant`, from one static walk of the
same positions `Subsume` checks), so an unknown uncontracted call stays
bounded by the erased-callable contract.

## Report

"Before" is the tree this milestone starts from (`83c48dc`), "after" this
one; every reproducer was run on both with this checkout's native build.

### 1. Root cause of C3

`hir::completions::IndirectFacts`, for a callee of structural `Fn` type,
started from the contract's errors and then added what the callee's callable
fact said; for an `unknown` fact -- any value whose identity the walk lost:
a struct field, a vector element, a call result -- that was the whole
erased-callable contract, and the walk became incomplete. The runner's
`(c.run)()` reads `c.run` from a struct: unknown. So one accepted test that
passed an error-declaring callable through an untyped parameter anywhere in
a suite put its errors into the program's erased-callable contract, and the
runner was charged them: UNHANDLED-ERROR inside `stdlib/test.bot`, for an error
no stored check can raise. `hir/affine.tcl`'s error edges did the same
(`mayLetErasedThrough` was 1 for every `Fn` callee).

### 2. Why the previous repair overreached

ERROR-IDENTITY-AND-COMPLETION-SOUNDNESS.md made unknown precision
conservative everywhere a callable fact was lost, and it had a real reason
to include `Fn` callees: a transparent closure (one that calls an erased
callable it captured) has a type whose declared errors say nothing about
what it raises, and the type checker let it acquire a `Fn` type on its
declared errors alone (`hoc-*-structural`: `use(make(raise), k)` with
`use(kf: Fn{..., errors: []})`). Charging every unidentified `Fn` call the
erased-callable contract covered that hole at every call instead of closing
it where it opens -- the place a value acquires the type. It conflated
"identity lost" with "contract lost".

### 3. The theorem

Above. Its proof obligation is the boundary check: every value of `Fn` type
has, at the position it acquired the type, been shown to raise -- through
its declaration, its captures and any argument the type admits -- only the
contract's errors. Calls through the type then need nothing but the
contract; facts may only narrow (`IndirectFacts`'s `Within`). The
erased-callable contract keeps covering every value with neither identity
nor contract: everything an uncontracted call may reach got there through a
semantic instance or a contravariant erasure, both counted.

### 4. Identity precision and contract precision

[The model](#identity-precision-and-contract-precision). Standard
terminology from here on (STATIC-COMPLETION-PROOFS.md uses it).

### 5. Callable types covered

Structural `Fn` (`hir::types::IsFn`) and coroutine handles
(`hir::types::IsCoroutine`, `Coroutine{...}`). Exact callables carry their
identity; `any` and the bare kinds `block`/`native` are uncontracted. A
coroutine handle's resume was already bounded by its contract in
`IndirectFacts`; what was missing was the boundary (point 16).

### 6. Where callable contracts are verified

* declared errors and argument/return compatibility: `hir::types::subtype`
  (`FnMismatch`), unchanged;
* argument admissibility of calls through a contract:
  `hir::range::VerifyStructuralCall`, unchanged;
* what the type does not show: `hir::completions::Subsume` (positions of
  point 7), `SubsumedRaises`, `SubsumeHandle`, in `checkBlock`.

### 7. Every path that constructs or transports a structural callable value

| path | how the value acquires or keeps its type | checked by |
|---|---|---|
| function argument (declared, inferred-trusted or semantic-instance entry type) | `ArgContexts` | `SubsumeCall` |
| argument of a call through a `Fn` (its argument types) | `ArgContexts` | `SubsumeCall` |
| struct field (named or anonymous, context struct installations, error payloads) | `StructField` | `Eval`'s `struct` case |
| return value, a body's trailing value (declared result, else the inferred one) | `ResultFinal` | `return` case, `checkBlock` |
| `if` branch join (`FnLub` of two closures), collecting loops, handler values, `break` | the join's type | `EvalIf`, `SubsumeCollected`, `EvalHandle`, `break` case |
| List/vector/array elements (`list` literal, `std::mutable_vector::push`, natives with result shapes) | `ArgContexts` (element positions) | `SubsumeCall`; aggregates aligned element-wise (`Align`) |
| a `Fn` returned by a callable (`Fn{return: Fn{...}}`) | `Align` on the result type | as its enclosing position |
| `yield` into a coroutine's outward type | `YieldFinals` | `SubsumeCall` |
| a coroutine handle leaving its construction's body | its `Coroutine` type | `SubsumeHandle` |
| a local binding | keeps its value's type (no acquisition) | -- |
| `any` to `Fn` | rejected by the type checker ("not known to be callable") | -- |
| HIR read from text, Core IR fixtures | re-checked by `hir::check` like any program | the same |
| compiler-created callables (coroutine thunks, trait clones, semantic instances) | thunks are checked against their root's contract by `checkBlock` (their enclosing errors) and at each escape (`SubsumeHandle`); clones and instances are copies of checked bodies, rechecked by the monomorphized build | -- |

### 8. `EvalCall`

Calls `SubsumeCall` for its arguments; a non-exact callee goes to
`IndirectFacts` with `diagnose` and the call (for the inconsistency audit,
point 7 of the brief: `contractExcess`).

### 9. `EvalHandle`

The handled call's arguments are checked (`SubsumeCall`), its structural
callee is bounded by `IndirectFacts` exactly as a plain call's, and each
handler's value is a join position (`Subsume`). `scc-one-error-handled`,
`-wrong-handler`, `scc-multi-error`, `scc-namespaced` pin handled calls;
`scc-one-error-declared` and `scc-transports` plain ones.

### 10. `IndirectFacts`

For a `Fn` callee: the contract, narrowed by a `{block B}` fact (B's
effective errors under these arguments, `Within` the contract; never
incomplete: the contract is a proof boundary) or a `{contract}` fact; never
widened. A complete exact analysis raising outside the contract is recorded
as `contractExcess` on the call (diagnose mode), never charged: a
contradiction between the boundary and the walk (no accepted program of the
tests, the fuzzer or the corpus records one: `scc-no-excess`, the fuzzer's
check). For an uncontracted callee: as before (recovery, erased-callable
contract for unknown), plus `{contract}` and `{native}` facts with the
argument channel (`ArgChannel`).

### 11. `CallableFact`

No duplicated contract lattice: the fact of a `Fn`-typed value is its static
type's contract (`TypeFact`, `ArgumentFact`), recorded only when it crosses
into an untyped parameter (the static type there is `any`). `clean` keeps
its meaning: an input the body's own check takes as `clean` (`CleanInput`)
has its value's fact charged where the function is called. A binding whose
recorded type is a `Fn` (a local, a capture of one, a specialized
instance's parameter) is not clean: its contract is its fact. A declared
parameter records no binding type (its type is the block's signature), so a
`Fn`-declared parameter stays clean in its own body: a call through it is
still charged its contract (the callee expression's type decides, never the
fact), and what it carries when the body forwards it into an untyped callee
is charged at the function's call sites by the argument's fact there -- the
contract's, for a value only its `Fn` type bounds (point 29 of the brief).

### 12. Transparent closures

A closure's captured or received callables encapsulated by a contract no
longer widen the calls through that contract: the boundary checks them once,
where the closure acquires the type. `hoc-structural-boundary`: the
`structural` path of `tests/higher-order-completions.test` as first written
(`use(make(raise), k)` with `errors: []`) is now a TYPE error at the
argument for E1, E2, E3 -- the closure does not fit the contract it is
given; with the contract admitting them (the path as now written) it fits
and the call is charged them by the contract. A transparent closure invoked
through an uncontracted path is analyzed exactly as before.

### 13. Recursion, budget and arity fallback

`Fallback` adds what the target's clean inputs carry (`Carried`): for an
input whose value only a `Fn` type bounds the fact is `{contract ...}`, and
`Carried` charges its contract -- plus the erased-callable contract only
when an argument the contract leaves untyped can reach it
(`ContractChannel`) -- never the erased contract in its place. `Transparent`
counts only uncontracted calls (and natives calling an uncontracted
callable): a call through a `Fn` never makes a function transparent.
`scc-recursive-fallback`: a recursive function made transparent by a call
of the untyped `call`, forwarding a `Fn{errors: []}` parameter that is given
a struct field's callable, in a program that erases E2 -- its recursion
fallback charges nothing and the program is accepted; the mutant charging
such a value the erased contract (`fallback-widens-contract`) is killed by
it. The test's first version, an untyped parameter beside the `Fn` one,
never reached a transparent fallback (the untyped parameter's type is
inferred from its one call site, so the function was not transparent); the
mutation run exposed it (point 42).

### 14. Trait operations

`TraitCallErrors` is unchanged: a trait operation is an exact call of the
implementation (its errors under the call's facts), held to the
requirement's contract. It never adds the erased-callable contract to a
`Fn` contract. `scc-trait-operation`: an implementation calling a contracted
field, through a trait-polymorphic function, in a program that erases E2 --
rejected before (UNHANDLED-ERROR E2), accepted now.

### 15. Native `-errors-from`

`std::mutable_array::generate`'s factory: a factory of `Fn` type is bounded by
its contract, already in the call's type-level `calleeErrors`; its fact adds
nothing outside (`{contract}`, or a closure within it). An exact closure
factory is recovered as before; an uncontracted one is charged by its fact.
`CallOpacity` makes a call transparent only for an uncontracted factory (an
exact one is an edge to it). `scc-native-factory`.

### 16. Coroutines

A resume through a `Coroutine` type was already bounded by its contract; it
is now sound: `SubsumeHandle` checks a handle leaving its construction's
body. The pre-existing hole: `worker(f)` calling an untyped `f`,
`coroutine {step, first} = worker(f)` in `make(f)`, `drive(step)` with
`drive(c: Coroutine{args: [M], return: Ev})` -- `make(raise_e)` escaped at
run time with `<error E>` on the tree before; now TYPE at `drive(step)`
(`scc-coroutine-boundary-escape`); with the root declaring E and the
contract admitting it, accepted (`-declared`); resumed only where
constructed, analyzed there as before (`-local`). C3's coroutine half:
a coroutine given to `invoke(c, m): c(m)` no longer reaches an unrelated
`Fn{args: [], return: int}` call (`scc-coroutine-poison`, ownership's
`poison2.bot`). The erased-callable contract still counts a coroutine passed
to an untyped parameter during checking (the affine specialization happens
after); it only reaches uncontracted unknown calls. `scc-coroutine-param-resume`.

### 17. `hir/types.tcl`'s `calleeErrors`

Unchanged code; its comment now states it: for a structural `Fn` or
`Coroutine` callee, the callable contract's declared error set -- a semantic
upper bound because compatibility (declared and hidden) was checked; for an
uncontracted callee, none at the type level, which is not "empty": the
completion analysis and the affine edges charge the erased-callable
contract.

### 18. `hir/affine.tcl` error edges

Derived from `calleeErrors` plus, for a call `mayLetErasedThrough`, the
erased-callable contract. A call through a `Fn` is never such a call now
(`CallOpacity`), so its edges are its contract's: `scc-affine-edges` --
across a `Fn{errors: []}` call no edge (before: an E2 edge for the unrelated
erased E2), across `Fn{errors: [E1]}` an E1 edge (before: E1 and E2), across
an untyped call the erased E2 edge as before. `affine-edges-still-widen`
(the mutant) is killed by it. `hir/affine.tcl` reads both facts from one
static walk (`erasureFacts`).

### 19. The old untyped-callable soundness theorem still holds

Every `hoc-*` test passes unchanged except the `structural` path's fixture
(point 12); `scc-untyped-still-conservative` is the brief's reproducer
(UNHANDLED-ERROR E1); `scc-three-precisions` shows `call`'s summary under an
unknown callable: the erased contract, incomplete. The overcorrection mutant
`unidentified-calls-empty` (every unidentified call charged nothing) is
killed by the old tests.

### 20. Exact recovery still narrows

`hoc-precise-recovery`, `-wrong-handler`, `hoc-summary-exact-narrowed`
unchanged; `scc-three-precisions`' recovered summary is `{E1}`, complete;
`scc-exact-narrows-contract`: `invoke12(one1)` through
`Fn{errors: [E1, E2]}` is narrowed to E1 (a handler for E1 alone). The
mutant `exact-recovery-disabled` is killed.

### 21. Structural unidentified calls use the contract

`scc-transports-effective` (each call stamped exactly its contract's
errors), `scc-one-error-summary` (the function's summary E1, complete),
`scc-three-precisions` (`{contract E1 {int}}`: E1, complete).

### 22-29. Regressions by contract and transport

| point | test | what |
|---|---|---|
| 22 empty contract | `scc-transports`, `scc-golden-runner` | `errors: []` through every transport, E2 erased elsewhere: accepted, value agreed on four backends |
| 23 one error | `scc-one-error-handled`, `-wrong-handler`, `-declared`, `-summary` | E1 handler enough; E2-only handler UNHANDLED E1 (never E2); declaring E1 compiles, E2 only does not; summary E1 |
| 24 multi error | `scc-multi-error` | `[E1, E2]` with E3 erased: exactly E1, E2 |
| 25 struct field | `scc-transports` (`dispatch`), `scc-boundary-struct-field` | |
| 26 vector / List | `scc-transports` (`run_all` over `List[Job]`, `vector_first` over `MutableVector[Job]`) | |
| 27 parameter | `scc-transports` (`invoke`, `invoke1`) | |
| 28 returned callable | `scc-transports` (`factory()` bound then called), `scc-returned-bound` | |
| 29 nested storage | `scc-transports` (`nested`: `(o.inner.run)()`) | |

### 30. Same-short-name namespaced errors

`scc-namespaced` (contract `[a::Failed]`, `b::Failed` erased: `a::Failed`
only; a handler for `b::Failed` alone is UNHANDLED-ERROR `a::Failed`),
`scc-namespaced-boundary` (a closure carrying `b::Failed` given
`[a::Failed]`: TYPE naming `b::Failed`; carrying `a::Failed` it fits). The
mutant comparing short names at the boundary is killed.

### 31. Payload-bearing errors

`scc-payload-error` (`E3 {code: int}` through a contract, destructured), the
fuzzer's E2/E4 payloads. Payload transport is unchanged.

### 32. Affine payloads and error edges

`scc-affine-payload`, `-native`: a contract admitting `Carry {stream:
Coroutine{...}}`: an edge for Carry (a coroutine live across the call
released on it) and none for the erased E2; the payload's stream resumed in
the handler; every coroutine released, none swept, natively too.
`scc-affine-edges`, `-runs`, `-native` (point 18).

### 33. The golden runner, before and after

GOLDEN-TEST-FRAMEWORK.md's reproducer (`register_poison`):

* before: `stdlib/test.bot:605:14: this call through a callable value the
  completion analysis cannot identify may produce the declared error "E"
  ... (UNHANDLED-ERROR)`;
* after: `["PASS poison", "1 passed, 0 failed"]` on every backend
  (`scc-golden-runner`, with a second, plain test beside it); the runner's
  call is stamped no effective error (`scc-golden-runner-call-effective`).

### 34. The excluded golden test, ported

`hoc-original-payload-free-both-handled` (errors.bot): hocOriginal with
handlers for both errors inside one accepted block, value `[0, -2, -1]` on
interp, compile, generic and specialized Cranelift.

### 35. Manifest limitation counts

| | before | after |
|---|---|---|
| Tcl tests ported / not ported | 133 / 41 | 134 / 40 |
| golden tests | 221 | 222 |
| rows NOT PORTED for runner poisoning | 1 | 0 |
| ported rows weaker because of C3 | 2 | 0 (both keep their layout for compile cost alone, notes updated) |
| rows naming NEW-FRAMEWORK-LIMITATION | 3 | 3 (one primary class DIRECT with "NEW-FRAMEWORK-LIMITATION (fixed)", two with a note: historical) |

`sc-negative-unhandled-erased`: its prelude at the suite's top level, as in
the Tcl program, now compiles and passes, but keeps the erased-callable
contract in every build (`hir::static::GlobalChannels`): diagnostics.bot
measured 14 decision rounds, 34 builds and 46.4 s instead of 5, 12 and 12.2
s, so the layout stays. `af-generic-errors`' admitted half is expressible
(its generic HOF at the suite's top level -- nested in a body the block is
rejected: a generic function is specialized for an affine argument only at
the top level) and passes, but ownership.bot measured 25 rounds, 194 builds
and 283 s instead of 4, 26 and 32 s; it stays out for compile cost. Both
are the static-decision economics of the next milestone, not C3.

### 36. Golden framework, full results

All eight suites, every backend: collections 44, diagnostics 27, errors 24,
harness 13, modules 31, ownership 37, representation 14, values 32 -- 222
passed, 0 failed, the same report on interp, compile, cranelift-generic and
cranelift (`tests/golden/run.tcl`). `tests/golden.test` 8/8 and
`tests/golden-framework.test` 41/41 on both Tcl backends.

### 37. Golden suite compile-time effect

GOLDEN-TEST-FRAMEWORK.md, "The convention in numbers", now has the after
numbers. Measured on a quiet machine, one suite at a time, the trees before
and after alternated, three rounds (median, front end in seconds):

| suite | rounds / builds before | after | before (s) | after (s) |
|---|---|---|---|---|
| collections.bot | 3 / 11 | 3 / 11 | 14.9 | 15.5 |
| diagnostics.bot | 5 / 12 | 5 / 12 | 13.7 | 14.3 |
| errors.bot | 4 / 7 | **8 / 15** | 7.1 | **20.0** |
| harness.bot | 2 / 3 | 2 / 3 | 1.8 | 1.7 |
| modules.bot | 3 / 6 | 3 / 6 | 11.9 | 13.1 |
| ownership.bot | 4 / 26 | 4 / 26 | 38.5 | 38.1 |
| representation.bot | 2 / 4 | 2 / 4 | 4.4 | 4.7 |
| values.bot | 1 / 2 | 1 / 2 | 5.0 | 4.7 |
| total | 24 / 71 | 28 / 79 | 97.3 | 112.1 |

Seven suites keep their decision rounds and builds exactly; together they
go from 90.2 to 92.1 s (+2%), per suite between -6% and +10%, the ranges of
the three runs overlapping except for diagnostics (+4%) and representation
(+7%). That is the analysis's own cost. Profiled over all of a suite's
builds: the body checks (`checkBlock`, the boundary and the static walk
included) take 0.83 s instead of 0.72 s in modules.bot, 1.10 instead of
0.90 in diagnostics.bot, 0.39 instead of 0.37 in representation.bot; the
static walk (`staticsOf`: transparency, contravariant erasure, the
positions where a callable acquires a `Fn` type) is 0.13-0.27 s of a suite
-- about 3% of a front end dominated by whole-program builds. The walk runs
about twice per build (once for the completion pass, once for ownership's
error edges, `erasureFacts`, plus once for the static decisions'
`GlobalChannels`); sharing it would save roughly half of that, left for
later. errors.bot, holding the newly accepted erasing body (point 34), goes
from 4 rounds / 7 builds / 7.1 s to 8 / 15 / 20.0 s: its final program
keeps an erased-callable contract, so the global static-decision channel
(`hir::static::GlobalChannels`) stays open in every build -- the cost of
the newly accepted test, not of the analysis (the completion analysis is
about 3 s of its 19.3 s over all 15 builds).

### 38. General callback-registry benchmark

`bench/callback-registry.tcl`: K handlers of `Fn{args: [], return: any}` --
half top-level functions, half closures a factory makes around an untyped
captured callable -- in structs and a `MutableVector`, dispatched by a field
call, a vector element's field call and a structural parameter, beside four
error-bearing callables passed through untyped helpers.

| K handlers | after: compiles | front end (best of 3) | value (interp) | effective errors at the dispatching calls | before |
|---|---|---|---|---|---|
| 10 | yes | 0.13 s | `[-1, 5, -1, 9, [0, 3003, 6, 3009, ...]]` | none | rejected: UNHANDLED-ERROR "Auth" at the dispatch |
| 50 | yes | 0.27 s | the same pattern | none | rejected, the same |
| 200 | yes | 0.95 s | the same pattern | none | rejected, the same |

Before, every size is rejected at the dispatching call for an error no
handler stored in the registry can raise ("Auth", the last identity an
unrelated guarded helper erases); after, it compiles, the dispatching calls
are charged nothing (their contract declares nothing), and the front end
grows linearly with K. No handler type, field name or library is special:
the registry is an ordinary program.

### 39. The fuzzer's model

`audit/structural-contracts/tools/fuzz.tcl`. Four identities (E1..E4, two
payload-bearing; or every other program `alpha::Failed`, `beta::Failed`
from private modules beside E3, E4), an untyped raiser each, recovered calls
through `call`, two to four struct slots `Fn{args: [int], return: any,
errors: C_J}` stored with an error-free function, a raiser in C_J, or a
closure `wrap_J(f)` around an untyped captured `f`, observed with handlers
H_J and declaration D_J, and an unidentified uncontracted call of a closure
`make(r_I)` returned from another activation. The model's legality rule
uses the three precisions alone (exact: E_I; contracted: C_J, never U;
uncontracted: U) and the boundary (every raiser a `wrap_J`'s call sites pass
must be in C_J); it predicts the exact set of (kind, identity) diagnostics,
and for an accepted program the value on every backend (which raiser runs,
which handler, which payload). It shares no code with the compiler. Faults:
`drop` (a contract error unhandled), `carrier` (a raiser outside C_J),
`unknown` (an erased identity unhandled at the uncontracted call).

### 40. Fuzz results

Every run checks the exact diagnostic set against the model, and every
accepted program's value on interp, compile, cranelift-generic and
cranelift; half the programs use the namespaced identities. Two rounds,
the second on the final tree (after the last analysis change):

| run | programs | accepted / rejected (kinds) | disagreements |
|---|---|---|---|
| `-seed 1` | 60 | 45 / 15 (TYPE 8, UNHANDLED-ERROR 8) | 0 |
| `-seed 1001` | 60 | 44 / 16 (TYPE 8, UNHANDLED-ERROR 10) | 0 |
| `-seed 2001 -fault carrier` | 40 | 16 / 24 (TYPE 28) | 0 |
| `-seed 3001 -fault unknown` | 40 | 13 / 27 (UNHANDLED-ERROR 27) | 0 |
| `-seed 4001 -fault drop` | 40 | 0 / 40 (UNHANDLED-ERROR 40) | 0 |
| `-seed 5001 -gc-stress 1` | 30 | 25 / 5 (TYPE 1, UNHANDLED-ERROR 4) | 0 |
| final tree: `-seed 7001` | 60 | 47 / 13 (TYPE 6, UNHANDLED-ERROR 7) | 0 |
| final tree: `-seed 7101 -fault carrier` | 40 | 16 / 24 (TYPE 28) | 0 |
| final tree: `-seed 7201 -fault unknown` | 40 | 11 / 29 (UNHANDLED-ERROR 29) | 0 |
| final tree: `-seed 7301 -fault drop` | 40 | 0 / 40 (UNHANDLED-ERROR 40) | 0 |
| final tree: `-seed 7401 -gc-stress 1` | 30 | 20 / 10 (TYPE 3, UNHANDLED-ERROR 7) | 0 |

620 programs, 0 disagreements (diagnostics compared as (KIND, IDENTITY)
sets). A fault applies only where a program has a place for it -- `drop` a
slot with a contract error, `carrier` a `wrap_J` slot whose call sites pass
a raiser outside its contract, `unknown` the unidentified call (two
programs in three have one) -- so the accepted `carrier` and `unknown`
programs are the ones without, accepted as the model predicts. No accepted program records a
`contractExcess`. The earlier milestone's fuzzer,
`audit/error-payloads/tools/fuzz.tcl`, on the changed analysis: `-n 60 -seed
1` and `-n 60 -seed 3001 -fault unhandled` (the unhandled error on every
path, the untyped `generic` one included), 0 disagreements each.

### 41. Mutation catalog

`audit/structural-contracts/tools/mutants.txt` (detectors:
`tests/structural-contract-completions.test`,
`tests/higher-order-completions.test`, the fuzzer unaimed and aimed at each
fault):

| mutant | the brief's name |
|---|---|
| `structural-call-adds-erased` | structural Fn call still adds the erased-callable contract |
| `structural-empty-only` | `errors=[]` special-cased, nonempty contracts still widen |
| `structural-short-name` | structural Fn trusts short names, not canonical identity |
| `field-fixed-param-widens` | field call fixed, parameter call still widens |
| `param-fixed-field-widens` | parameter call fixed, field/vector call still widens |
| `handle-still-widens` | EvalCall fixed, EvalHandle still widens |
| `affine-edges-still-widen` | completion fixed, affine error edges still widen |
| `fact-widens-contract` | transparent callable fact widens past the contract |
| `fallback-widens-contract` | recursion fallback widens past the contract |
| `native-factory-widens` | native `-errors-from` widens past the contract |
| `coroutine-contract-widens` | coroutine structural call still widens |
| `boundary-unchecked` | structural contract trusted without compatibility checking |
| `boundary-trusts-clean-captures` | (the same, for a clean capture's deferral) |
| `possible-ignores-call-sites` | (the same, for an untyped input's possible errors) |
| `coroutine-boundary-unchecked` | (the same, for a coroutine handle) |
| `contravariant-erasure-dropped` | (the erased-callable contract misses contravariant erasure) |
| `unidentified-calls-empty` | untyped call trusts the empty contract -- the overcorrection |
| `exact-recovery-disabled` | exact recovery disabled by the fix |

### 42. Mutation results

`tclsh9.0 audit/structural-contracts/tools/mutate.tcl`: 18 mutants, 18
killed, every one applying. The tests kill all 18; the fuzzer (unaimed, then
aimed at `drop`, `carrier`, `unknown`; 25 programs each) independently kills
ten.

| mutant | result | tests failed | fuzz: disagreeing programs of 25 (unaimed / `-fault carrier` / `-fault unknown` / `-fault drop`) |
|---|---|---|---|
| `structural-call-adds-erased` | killed | 37 | 21 / 23 / 21 / 21 |
| `structural-empty-only` | killed | 33 | 19 / 22 / 20 / 21 |
| `structural-short-name` | killed | 1 | 1 / 1 / 0 / 0 |
| `field-fixed-param-widens` | killed | 28 | survived (its slots are all fields) |
| `param-fixed-field-widens` | killed | 36 | 21 / 23 / 21 / 21 |
| `handle-still-widens` | killed | 10 | 15 / 22 / 18 / 21 |
| `affine-edges-still-widen` | killed | 2 | survived (no affine values) |
| `fact-widens-contract` | killed | 2 | survived |
| `fallback-widens-contract` | killed | 1 | survived (no recursion) |
| `native-factory-widens` | killed | 1 | survived (no natives) |
| `coroutine-contract-widens` | killed | 5 | survived (no coroutines) |
| `boundary-unchecked` | killed | 8 | 2 / 20 / 0 / 0 |
| `boundary-trusts-clean-captures` | killed | 2 | 2 / 20 / 0 / 0 |
| `possible-ignores-call-sites` | killed | 6 | 2 / 20 / 0 / 0 |
| `coroutine-boundary-unchecked` | killed | 1 | survived (no coroutines) |
| `contravariant-erasure-dropped` | killed | 2 | survived (no Fn-typed arguments) |
| `unidentified-calls-empty` | killed | 57 | 6 / 20 / 19 / 25 |
| `exact-recovery-disabled` | killed | 7 | 21 / 25 / 24 / 25 |

The first full run killed 16 and left two, both defects of the catalog,
not of the analysis. `param-fixed-field-widens` (and, killed for other
reasons, three of its siblings) widened the errors *before* the
`{contract}`-fact branch of `IndirectFacts`, which then replaced them: the
four were rewritten to widen the final result. `fallback-widens-contract`
was an equivalent mutant: it changed `Fallback`'s treatment of a parameter
whose *recorded* binding type is a `Fn`, but a declared parameter records
none (point 11), so no program distinguishes it; and the test meant to kill
it, `scc-recursive-fallback`, never reached a transparent fallback (point
13). The mutant now widens what `Carried` charges a `{contract}` fact -- the
fallback's let-through for a value only its `Fn` type bounds -- and the
test was rewritten to reach it. `unidentified-calls-empty`, killed in the
first run by its uncontracted half alone, gained its contracted half (a
structural call charged nothing either). The six rewritten mutants, rerun
with `-only`: 6 killed.

### 43. The old completion-soundness mutants

`tclsh9.0 audit/error-payloads/tools/mutate.tcl` on the changed analysis:
44 mutants, 44 killed, every one applying (its Rust mutants by `cargo test`
of their private native copy as before). Its ten completion mutants -- the
original hole (`untyped-callable-reports-no-errors`, killed by 13 tests),
`precision-flag-dropped-on-return`, the incompleteness propagation through
calls and handles, the four declared-contract fallback mutants,
`recursion-fallback-ignores-carried`, `affine-error-edge-ignores-erased`
and `recovery-reports-no-errors` (28 tests) -- are all killed by the
untyped paths of `tests/higher-order-completions.test`, which this
milestone left untouched except for the one structural path (point 12).
Two of them had their text updated because the code they mutate moved
(`IndirectFacts`' unknown case now sits inside the uncontracted branch;
`Recover` returns the incompleteness beside the errors), each keeping its
rule: the unknown callee charged nothing, the recovered callee's errors
dropped.

### 44. Affine mutants

`tclsh9.0 audit/affine/tools/mutate.tcl`: 29 mutants, 29 killed, every one
applying (its three native mutants rebuilt in a private copy). None needed a
text change: the one line of `hir/affine.tcl` this milestone changed (the
error edges read `erasureFacts`) is not one they mutate. The new error-edge
behavior -- an edge for each contract error of a structural call, none for
the erased contract -- is pinned by `scc-affine-edges`/`-runs`/`-native`
and `scc-affine-payload`/`-native`, and mutated by
`affine-edges-still-widen` (point 42).

### 45. Coroutine mutants

`tclsh9.0 audit/coroutines/tools/mutate.tcl`: 52 mutants, 52 killed,
every one applying (its 14 native mutants rebuilt in a private copy, with
the coroutine module's Rust tests). None needed a text change. The
coroutine side of this milestone -- a handle leaving its construction
checked against its `Coroutine` type (`SubsumeHandle`), a resume through a
structural coroutine type charged its contract -- is mutated by
`coroutine-boundary-unchecked` and `coroutine-contract-widens` (point 42);
the release-on-exit rules these mutants guard (including
`exit-release-handled-error` and `core-ir-error-release-missing` on a
call's error edge) still hold with the narrower edges of a structural
call.

### 46. Full Tcl regression

`tclsh9.0 tests/all.tcl`, each backend with a private `-tmpdir`, 168 test
files: `CORE_BACKEND=interp` 7215 tests, 7215 passed, 0 failed;
`CORE_BACKEND=compile` 7215 tests, 7211 passed, 4 skipped (the
`coreScoping` constraint, as on the tree before), 0 failed. That run began
before the last change to the analysis (the indirect-call diagnostics'
structural case, point 51) and the rewritten `scc-recursive-fallback`, so
the 23 files touching completions, contracts, errors, ownership, traits,
contexts, static decisions and the golden framework ran again on the final
tree (structural-contract-completions, higher-order-completions, affine,
context-traits, contexts, coroutines, error-payloads, errors,
exact-callable-key, golden-framework, golden, hir-callable-target,
mutable-array-type, mutable-array, mutable-vector, namespaced-errors,
range-completions-crosscheck, same-failure, semantic-instances,
static-compile, structural-fn-types, traits, typed-callable-escape): 1274
tests, 0 failed. `tests/golden/run.tcl`: point 36.

### 47. Native coverage

`tclsh9.0 tests/native-coverage.tcl` (the whole suite on cranelift), the
tree before and after:

| | tests | native | independent | passed-partial | unsupported | failed |
|---|---|---|---|---|---|---|
| before | 7169 | 2922 | 4118 | 69 | 60 | 0 |
| after | 7215 | 2943 | 4143 | 69 | 60 | 0 |

The 46 new tests (45 in structural-contract-completions, one in
higher-order-completions): 21 run native code, 25 are analysis tests. The
60 unsupported are the same tests needing the same constructs (test-only
natives, `value`, sequence mode), none of them this milestone's.

### 48. GC stress

`BOTLISH_NATIVE_GC_STRESS=1` (a GC attempt at every allocation site), each
file with a private `-tmpdir`: `tests/structural-contract-completions.test`
45/45, `tests/higher-order-completions.test` 62/62,
`tests/error-payloads.test` 61/61, `tests/affine.test` 45/45,
`tests/coroutines.test` 79/79; and the fuzzer's `-gc-stress 1` run (point
40). No file in `native/` changed, so its stack walking, roots and
allocation are the tree's before; these runs check that the newly accepted
programs (structural calls beside erasures, coroutines released on a
contract's error edge, affine payloads) are released and traced correctly
by the unchanged runtime.

### 49. Scalar/codegen audit

`tclsh9.0 native/generate-scalar-audit.tcl` regenerated into a private
directory: all 13 programs (`bench/` fib, loop-count, sum-refined,
refined-checks; nine `examples/stdlib/` programs) "ok", and every one of the
39 listings byte-identical to `audit/native-scalar-asm/` -- only
the README's revision lines (commit, rustc) differ. Nothing to regenerate.

### 50. Run-time and code-generation differences

None. No file under `core/`, `compiler/`, `native/` or `hir/lower.tcl`
changed. The NIR of all 39 compiling example and benchmark programs
(`examples/**/*.bot`, `bench/*.bot`; the two others are the intentional
compile-error samples, rejected identically) is byte-identical to the tree
before. Newly accepted programs (the golden runner beside an erasure, the
registry) have no earlier output to compare; their behavior agrees on every
backend.

### 51. Diagnostics

* The poisoned runner's `UNHANDLED-ERROR in stdlib/test.bot` is gone.
* An uncontracted unidentified call keeps a precise message, now naming both
  losses: "this call through a callable value the completion analysis
  cannot identify, and that no callable contract bounds, may produce the
  declared error ..." (`scc-uncontracted-message`).
* The boundary (TYPE, at the value, one per error): "this callable may
  produce the declared error "E" when called (through a callable it captured
  or receives as an argument), but it is used here as a value of function
  type T, which does not declare it: a call through a value of that type is
  trusted to produce only the errors it declares" ("a callable this value
  holds ..." for an element or field of an aggregate; for a coroutine
  handle "this coroutine may produce ... when resumed (through a callable
  passed to its construction) ... and it leaves its construction here").
  A callable whose *declared* errors do not fit is the type checker's
  diagnostic alone, as before.
* A call through a structural callee is never charged an error outside its
  contract any more, so `CheckIndirectCallLegality` hands it to
  `CheckStructuralCallLegality` whole; the message that named an erased
  error at a structural call is gone with the case.

### 52. Documentation

STATIC-COMPLETION-PROOFS.md ("Precision and the erased-callable contract":
identity and contract precision, the theorem, the boundary, contravariant
erasure), AGENTS.md ("Completion precision through untyped callables"),
GOLDEN-TEST-FRAMEWORK.md (an update at the top, a note at every place
describing C3, the after numbers), the headers of `hir/completions.tcl`,
`hir/types.tcl`'s `calleeErrors`, `hir/callables.tcl`, `hir/affine.tcl`,
`hir/static.tcl`'s `GlobalChannels`, `tests/golden/*.bot` and the manifest
notes. Every place that said "cannot identify -> erased-callable contract"
now says "cannot identify *and* no verified contract bounds".

### 53. No run-time or test-framework special case

No file under `core/`, `compiler/`, `native/`, `stdlib/` (`stdlib/test.bot`
included) changed; nothing in `hir/` names the golden framework, a test, a
struct or a field: the rule reads static types (`IsFn`, `IsCoroutine`,
`Contract`) and callable facts only. The registry benchmark and the
fuzzer's registries are ordinary programs accepted for the same reason.

### 54. Remaining higher-order precision limits

* **The static-decision channel.** An accepted erasure keeps
  `hir::static::GlobalChannels` open in every build (errors.bot 8 rounds;
  the two layouts kept for cost) -- the next milestone. *Fixed by
  STATIC-DECISION-ECONOMICS.md*: the erased-callable contract is a node of
  the decisions' dependency graph, delaying only its consumers (the calls
  that have lost identity and contract precision); errors.bot takes 3
  rounds, and both layouts are back in their natural form.
* **Possible is per binding, not per call.** A closure's untyped capture
  stands for every value its function's calls pass: `wrap(raise2)` anywhere
  rejects `wrap`'s subsumption even for a call that passes an error-free
  callable (`scc-boundary-created-here-bad`). A function used as a value
  (not only called) has `Possible` = the whole erased contract for its
  untyped parameters.
* **An implementation that calls an `any`-typed parameter** must admit the
  erased contract to fit a `Fn{args: [any], ...}` in a program that erases
  anything (`scc-any-parameter-call`): the contract cannot know what a
  caller passes there.
* **Recovered closures from other activations** keep unknown captures:
  `h = make(raise); h(k)` is charged the erased contract (as before); the
  boundary uses `Possible` for them (more precise), the call does not.
* **Narrowing by a recovered fact applies only while the program erases an
  error-bearing callable** (callable facts are tracked only then): without
  erasure a structural call is charged its whole contract.
* **The erased-callable contract counts a coroutine passed to an untyped
  parameter** although it is always specialized afterwards; it reaches only
  uncontracted unknown calls now.
* **A coroutine root's own return value** joined into a wider outward type
  than its result is not a checked position (its yields are).

## Files

| file | what |
|---|---|
| `hir/completions.tcl` | contract facts (`TypeFact`, `ContractFact`, `ContractChannel`), `Uncontracted`, `CleanInput`/`SeedClean` for inputs of uncontracted recorded type, `IndirectFacts` (bounded by the contract, narrowed by facts, `Recover`, `Within`, `contractExcess`), `ArgChannel`/`ValueCarries`, the static walk (`staticsOf`: transparency by `CallOpacity`, contravariant erasure; `Positions`, `Align`, `Contravariant`, `YieldFinalsOf`), `erasedErrorsOf`/`erasureFacts`, the boundary (`Subsume`, `SubsumeCall`, `SubsumeCollected`, `SubsumedRaises`, `ArgumentFact`, `SubsumeHandle`, `ReportOutside`), `Possible`/`PossibleOf`, the indirect-call diagnostics |
| `hir/affine.tcl` | error edges from `erasureFacts`; comment |
| `hir/types.tcl`, `hir/callables.tcl`, `hir/static.tcl` | comments (the contract bound; the boundary; the channel) |
| `tests/structural-contract-completions.test` | this milestone's 45 tests |
| `tests/higher-order-completions.test` | the `structural` path's contract admits what it raises; `hoc-structural-boundary` |
| `tests/golden/errors.bot`, `diagnostics.bot`, `ownership.bot`, `manifest.tsv` | the ported test, notes, two pinned locations moved |
| `audit/structural-contracts/tools/{fuzz.tcl,mutate.tcl,mutants.txt}` | fuzzer, mutation harness and catalog |
| `audit/error-payloads/tools/mutants.txt` | two completion mutants' texts follow the code (same rules) |
| `bench/callback-registry.tcl` | the registry benchmark |
| STATIC-COMPLETION-PROOFS.md, AGENTS.md, GOLDEN-TEST-FRAMEWORK.md | documentation |

## What to run when changing this

AGENTS.md, "Completion precision through untyped callables".
