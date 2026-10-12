# STATIC-DECISION-ECONOMICS.md

The decision economics of `static compile:` (STATIC-COMPILE.md): how many
whole-program builds deciding a program's static blocks takes, and why.

> A `static compile:` program is solved as a dependency graph of semantic
> questions. Independent questions are answered together; whole-program
> rebuilds occur only when resolving one layer changes facts required by
> another.

**What changed.** Not one outcome: every block's verdict, every reified
`CompilerError` (code, primary, related, message), every program's
diagnostics and its decided HIR, Core IR and NIR are what they were
(the sequential order of STATIC-COMPILE.md step 3 still defines them, and
is now kept as an executable reference). What changed is how many builds
deciding them takes. The legacy procedure decided one rejected block per
whole-program build unless two blocks lay in different top-level functions
that did not reach each other, and decided one block per build for the whole
program as soon as anything in it erased an error-bearing callable; and
every build ran its method-call decisions again, with a duplicate final
build. Now:

* a dependency analysis of one build (`hir/staticdeps.tcl`) says which
  blocks each block's diagnostics can depend on, and the batched scheduler
  (`hir::static::Simulate`) commits from one build every rejection the
  sequential order would make whose block depends on nothing rejected since;
* the program-wide channels are graph nodes with contributors and
  consumers: the erased-callable contract delays only the calls that have
  lost both identity and contract precision, never a call through a
  verified structural contract, never an unrelated block;
* method-call decisions no rejection can have changed are reused across
  rounds, and a decision build that would repeat the build it started from
  is not made again.

**The numbers** (whole-program builds; the times of the synthetic rows were
measured with the before and after trees side by side, those of the golden
suites on a quiet machine: [Measurements](#measurements)):

| workload | before | after |
|---|---|---|
| 100 golden cases, 33 TYPE rejections, bodies nested in the registration function | 34 rounds, 68 builds, 199 s | 2 rounds, 2 builds, 6.9 s |
| the same, 200 cases (66 rejections) | 67 rounds, 134 builds, 642 s | 2 rounds, 2 builds, 10.6 s |
| the same bodies at the top level (the old layout rule) | 2 rounds, 4 builds | 2 rounds, 2 builds |
| 200 blocks, half failing at every stage (resolution, checker, ownership, completions, traits, contexts), nested | 87 rounds, 173 builds, 393 s | 3 rounds, 3 builds, 8.0 s |
| the eight golden suites (front end, fresh process each, best of 3) | 28 rounds, 79 builds, 181 s | 24 rounds, 37 builds, 82 s |
| errors.bot (an accepted body that erases an error-bearing callable) | 8 rounds, 15 builds | 3 rounds, 3 builds |
| ownership.bot with `af-generic-errors`' admitted half in its natural place | 25 rounds, 194 builds, 283 s (C3 report) | 4 rounds, 11 builds |
| diagnostics.bot with `sc-negative-unhandled-erased` in its natural layout | 14 rounds, 34 builds, 46 s (C3 report) | 5 rounds, 7 builds |

Builds now grow with the depth of genuine dependency -- a chain of K nested
blocks each rejecting the one around it still takes K + 1 builds, as it
must -- and no longer with the number of rejected blocks or their layout.
The golden suites' layout rule (bodies hoisted to the top level, the erasing
body placed first) is gone: `tests/golden/README.md` now says layout is free,
and the two golden tests written around it are back in their natural form.

## Contents

* [The old procedure](#the-old-procedure)
* [The theorem](#the-theorem)
* [The dependency graph](#the-dependency-graph)
* [Method-call decisions](#method-call-decisions)
* [Instrumentation](#instrumentation)
* [Measurements](#measurements)
* [Validation](#validation)
* [Report](#report) -- the 72 points of the milestone brief, in order
* [Files](#files)
* [What to run when changing this](#what-to-run-when-changing-this)

## The old procedure

`hir::static::decide` before this milestone (kept as the *legacy*
scheduler: `Rejectable`, `Independent`, `Units`, `GlobalChannels`):

1. a block whose body holds a loader diagnostic (a qualified reference the
   file may not make) is rejected before any build;
2. each round expands the syntax with every decided block in its decided
   form and every undecided one as its body, and builds the whole program
   (`hir::BuildFull`);
3. a round that stopped after resolution rejects every block with a
   resolution diagnostic of its own, together (resolution is lexical);
4. a typed round rejects the first block in post-order with a diagnostic of
   its own and accepts the undecided blocks before it -- plus every other
   failing block that `Independent` proves no other failing block can have
   influenced: the two lie in different *units* (a top-level function with
   everything nested in it, or a section's top-level code) and neither unit
   reaches the other through the program's references; and no second block
   at all while `GlobalChannels` holds (a demoted trusted contract, or any
   erased-callable contract in the program);
5. a round in which no block has a diagnostic of its own is the final
   program.

Every `hir::BuildFull` ran `hir::DecideMethodCalls` from scratch: trial
builds pairing the candidates of the undecided method-style calls, then
always a final build with the decided choices -- even when there was no
call to decide, so every round cost two builds.

**Why independent TYPE failures in one function serialized.** The golden
framework nests each test's body in the suite's registration function. All
bodies are then one unit, `Independent` never holds between two of them, and
step 4 rejects one block per round: 100 cases with 33 checker rejections took
34 rounds and 68 builds (the method decisions' final build doubling every
round), 199 s; at the top level the same bodies took 4 builds. That is why
the golden suites hoisted 152 of their 218 bodies to the top level.

**Why one erasing body serialized everything.** `GlobalChannels` is a
Boolean over the whole build: one accepted body passing an error-bearing
callable through an untyped parameter -- errors.bot's
`hoc-original-payload-free-both-handled`, accepted since
VERIFIED-CALLABLE-CONTRACT-BOUNDARY.md -- made every typed round of the
program reject exactly one block (errors.bot: 4 rounds before C3, 8 after;
diagnostics.bot with its erasing prelude at the top level: 14; ownership.bot
with the admitted half of `af-generic-errors`: 25 rounds, 194 builds).

## The theorem

STATIC-COMPILE.md, "Decision economics", states it in full; in short:

* **Reference.** The sequential order defines every outcome: per typed build
  reject the first failing block in post-order and accept the ones before
  it; per resolution-halted build reject every block with a resolution
  diagnostic of its own; loader rejections first.
* **Dependency.** A build is a pure function of the blocks' forms; a block's
  own diagnostics are a function of the facts its analysis reads, and those
  of the forms of the blocks its analysis can see -- the blocks it *depends
  on*. After rejecting Z on one build, every block that does not depend on Z
  has the diagnostics it would have in the next build.
* **Stable decision.** A block's verdict is *stable* in a build when it is
  the first block of its component that is not ok, it fails, and nothing it
  depends on differs between this build and the sequential order's build of
  that step. A stable rejection is committed from the build; so is the
  acceptance of the component's undecided blocks before it.
* **Batching.** Components are blocks linked by dependency in either
  direction. No decision in one component can change a status in another,
  so the sequential order of the program is an interleaving of the
  components' orders, and each component takes its own sequential steps on
  the same build until its first *unknown* block -- one depending on a block
  rejected since. Only that question needs a new build.
* **Monotonicity.** Decisions only go from body to rejection (a rejected
  block is never re-admitted, an accepted one is rejected only if a later
  rejection removed something it relied on), so the rounds end; a batched
  run never commits a decision the sequential order would not make, so the
  batched rounds are at most the sequential ones.

Two refinements keep the diagnostics exact: a block depends on every block
nested in it (an inner rejection is part of the outer body), and a message
that names internal ids (`block(e12)`, numbered by the build) is committed
only from a build in which every block numbered before its ids has the form
the sequential order's build gives it. Each build checks the previous
batched run's predictions, ids blanked; a contradiction is recorded as
`mispredicted` and fails every audit -- it would mean the dependency analysis
missed a channel. None occurs in any suite, fuzz program or test.

## The dependency graph

`hir/staticdeps.tcl`'s header lists every edge and why. Its shape:

| node | depends on |
|---|---|
| `D:site` (the site's own diagnostics: what a site depends on is what this node reaches) | `Z:site`, and its own contract-boundary checks where one can report, while a report may be its first diagnostic ([what the checks read](#what-the-contract-boundary-checks-read)) |
| `Z:site` (the site as the code around it sees it) | its region (*position*: its rejection can make the code after it unreachable, where completion and ownership diagnostics are not reported), the sites nested in it |
| `R:region` (a function literal or a program's top-level code) | everything its own code mentions: bindings, the functions it defines and calls (their summaries), every method-call candidate and what the candidates' trial builds judge of the contract boundary, its parameters and captures, the control operands around its literal, the narrowings of each capture between its definition and the region -- *not* the rest of the enclosing function: a function is analyzed from its own entry |
| `B:binding` | its definition, every narrowing mention in its own region ([every mention](#every-mention)); an untyped parameter also every reachable use in its function and the functions nested in it (its inferred contract); an affine or mutable binding -- never one holding a callable -- every region mentioning it |
| `C:erased` (the erased-callable contract) | its contributors: the instance requests whose arguments at uncontracted parameters can carry errors (by those arguments and the call's place, up the chain of requests), the positions of contravariant erasure, the requests the budget declined |
| `C:budget:B` | every call requesting one of B's instances, only under pressure |
| `P:input` (what an uncontracted input may hold at the contract boundary) | what the calls of its function pass in its position, its value, or `C:erased` |
| `C:verdict` (the ownership analysis's verdict on the whole program; [below](#the-ownership-verdict)) | while the analysis reports something, one witness: the region of its diagnostic whose site is last in post-order, or of every one outside a site; while it accepts the program, every region passing an affine argument whose contract can widen |

A region is a *consumer* of `C:erased` when it calls through a value that has
lost both identity precision and contract precision: a callee typed `any` or a
bare kind, a native calling such an argument. A call through a verified
structural `Fn`/`Coroutine` contract is no consumer. A coroutine's erasure is
the same channel (its construction is a call of a root native with the
callable as argument); its yield type is a separate backward edge (a yielding
function's yields are typed by the struct-protocol constructions reaching
it).

Not channels, each pinned by a `se-property-*` test where the fact lives:
a demoted trusted contract (`hir::check` keeps the diagnostics of the check
before the demotion), the trait monomorphization's build (it runs only on a
program with no diagnostic), resolution (lexical). The gate of its *plan* is
a channel, not modelled yet ([every mention](#every-mention)).

### The ownership verdict

A later finding (the golden migration's `mutable-vector.bot`: 5 rounds, 30
builds, one misprediction). `hir::affine::verify` computes release scopes --
and so `AFFINE-PATH-RELEASE-UNSUPPORTED`, a binding moved on a loop's break
path or in a handler but still owned when the loop runs out or the call
completes -- only when its whole-program analysis found nothing
(`set scopes [expr {!$accepted || ...`). A site with such a join therefore
has that diagnostic only once every site with an ownership diagnostic
(`USE-AFTER-MOVE`, `AFFINE-LIST-OPERATION-UNSUPPORTED`, ...) anywhere in the
program is rejected. The graph had no such edge: the batched run predicted
the site ok beside the rejections that revealed it (a misprediction, the
decisions still the reference's), and with a diagnostic of a later pass in
the same site -- a `KNOWN-ERROR` after its loop -- it committed that one,
where the sequential order rejects the site with
`AFFINE-PATH-RELEASE-UNSUPPORTED`: another program, which no audit saw
(`se-equal-ownership-verdict`).

`C:verdict` models it (`hir/staticdeps.tcl`, `Ownership`):

* **consumers**: `Z:site -> C:verdict` for every site holding a counting,
  iterating or lockstep loop, or a handled call, whose body or handlers move
  an affine binding visible at it (the analysis's moving references) -- an
  infinite `loop:`'s normal path never completes and an `if`'s branches each
  end in a statement that can hold a release, so neither is one. While the
  analysis reports an erasure, also every reference there to a binding
  whose type is affine or mentions `any`: a rejection that narrows the
  erased type can make it a move;
* **while the analysis reports something**: the verdict cannot change while
  one of its diagnostics stays, so `C:verdict` depends on one witness -- the
  region of the diagnostic whose site is last in post-order (the sequential
  order removes it last), or of every one outside a site (no decision
  removes it). And every site holding one *after the first consumer* is
  linked to it (`Z:site -> C:verdict`): the sequential order judges a
  consumer while those are still present, so when a consumer's status
  becomes unknown its component must hold them back. Depending on every
  diagnostic instead would also be sound, but a consumer ahead of K of them
  would turn unknown at the first and take K + 1 builds; depending on the
  witness alone would not be sound (a consumer turned unknown by the
  witness's rejection while a later one is committed in another component);
* **while it accepts the program**: a rejection only kills paths and narrows
  types toward `never`, and an affine value never flows into a position that
  is not affine without an erasure diagnostic, so a new ownership diagnostic
  can appear only where an argument contract can widen -- an affine
  argument at an untyped parameter (its inferred contract, its instance's
  budget) or of a callable value (its type's contract): `C:verdict -> R` of
  each region passing one.

The analysis's diagnostics are recognized by kind
(`hir::staticdeps::ownershipKinds`, checked against `hir/affine.tcl` by
`se-property-ownership-verdict`), without the semantic instances' carried to
their calls ("call to F with ... is invalid: ..."), which keep an ownership
kind but are no verdict of the whole program.

| program | before | after | sequential |
|---|---|---|---|
| the reproducer (USE-AFTER-MOVE, the site, AFFINE-LIST-OPERATION-UNSUPPORTED) | 3 rounds, mispredicted | 3 rounds | 4 rounds |
| the same with a KNOWN-ERROR after the site's loop, the site last | 2 rounds, the site KNOWN-ERROR (wrong) | 3 rounds, AFFINE-PATH-RELEASE-UNSUPPORTED | 4 rounds |
| the site ahead of six ownership rejections | 3 rounds, mispredicted | 3 rounds | 8 rounds |
| the site beside four TYPE failures (accepted program) | 2 rounds | 2 rounds | 6 rounds |
| `tests/golden/mutable-vector.bot` (70 sites) | 5 rounds, 30 builds, mispredicted `{4 f1:44247}` | 5 rounds, 30 builds, the same 70 decisions | -- |

On `mutable-vector.bot` the channel costs no build: its one consumer is
accepted with the last ownership rejection, as before, but now as *unknown*
rather than predicted ok, and rejected in the next round. (Its 30 builds are
21 method trial builds, 7 in each checked round; the 15-build ceiling of
`golden-static-economics` is exceeded for that reason, not this one.)

`mutable-array.bot` (233 sites, 91 rejected) takes 6 rounds and 21 builds
before and after, the same decisions, no misprediction either way: 14 of its
builds are the first checked round's method trials, and rounds 3-5 a chain
of three TYPE rejections whose messages name exact callables (`block(eN)`),
each committed in the sequential order's own build. The channel is active
there (three consumers) and costs no build, but its linking moves five
rejections from round 2 to rounds 3 and 4: the ownership diagnostics after
the first consumer share a component with three consumers of the
erased-callable contract, which turn unknown when an erasing site that is
also an ownership contributor (`AFFINE-ELEMENT-COPY-OUT`) is rejected.
`structs-and-enums.bot` (6 rounds, 19 builds) has no ownership diagnostic:
the channel is closed and nothing changes.

Front end (`bench/golden-suites.tcl -backends interp -profile 0`, the tree
before and after run side by side on a loaded 4-CPU machine, so the times
compare within a row only): `mutable-vector.bot` 904.4 s / 897.7 s,
`mutable-array.bot` 1620.3 s / 1590.8 s, `structs-and-enums.bot` 673.3 s /
679.2 s -- the analysis's added walk is within the noise.

Three mutants of `audit/static-decisions/tools/mutants.txt` pin the rules:
`verdict-consumers-ignored` and `verdict-unlinked` (semantic: the first and
the second program of `se-equal-ownership-verdict` decide otherwise than the
sequential order) and `verdict-every-diagnostic` (economic: the site ahead
of six of `se-builds-ownership-verdict` takes a build per rejection).

### Every mention

A later finding (the review of the ownership verdict's change).
`hir::staticdeps::Prepare` collected four lists keyed by a site, a region or
a binding with `dict lappend state FIELD KEY VALUE` -- which appends KEY
*and* VALUE to one flat list under FIELD. Every lookup then read that list as
a dict, in which the last pair for a key wins: the analysis kept one entry
per key.

* **A binding's mentions** (`B:binding`'s narrowing mentions in its own
  region, a capture's narrowing mentions between its definition and the
  capturing function, the shared-binding edges): only the last mention of
  each binding was an edge. A nested function's capture of a vector is
  `MUTABLE-PLACE-CAPTURE` while its function mutates the vector anywhere
  (`hir::mutvec::verify`), and a block before it holding the mutation was no
  edge of the capture's: the batched run rejected the capture in the build
  that rejected the mutating block -- where the sequential order rejects that
  block and then *accepts* the capture, the mutation gone with its body.
  Another program, recorded nowhere: the final build had no body left whose
  prediction it could contradict. With a site between the two (holding the
  capture back), the run predicted the capture failing and the next build
  contradicted it (`mispredicted`). `se-equal-every-mention` pins both.
* **A site's expressions** (its own contract-boundary checks,
  `SubsumeSuccessors`; its first expression id, `firstIds`, which bounds the
  internal-id messages committed without the sequential order's build): one
  expression per site, the last walked -- so a callable acquiring a
  structural type anywhere but there was no edge to the erased-callable
  contract, and the id bound was the site's last id, not its first.
* **A region's calls** (the candidates of its method-style calls, which the
  trial builds try): only its last call's.
* **A region's function literals** (an untyped parameter's uses in the
  functions nested in its function, `Descendants`): masked -- a region
  reaches every literal it defines anyway (`defines`).

The four lists are now built in variables of their own and stored nested
(`mentions-last-only` reintroduces the first: semantic, killed by
`se-equal-every-mention`).

**A binding holding a function is not shared.** With every mention an edge,
the shared-binding rule (an affine or mutable binding: `B -> R` of every
region mentioning it) is whole -- and its test was too coarse:
`MentionsMutable` walked every part of a type, so a function whose contract
mentions a vector -- the ownership prelude's `empty_queue() ->
MutableVector[...]`, called by every site that needs a queue -- counted as a
shared mutable binding, and every region calling it depended on every other
(`se-builds-ownership-verdict`'s reproducer: 3 rounds became 4; the economic
mutant `callable-shared` restores the coarse test). A callable's type -- an
exact function or native, a structural `Fn`, a coroutine handle -- now holds
no mutable value, wherever it stands (a binding, a field, an element), and
the walk names the forms it descends (a struct's field types, a List's
element and shape) rather than every part, so that a field name is never
read as a type. It is sound because nothing one use of a function binding
does changes what another use sees:

* a function value has no place: a mutation's receiver is a local, a
  parameter or a context parameter, or a field path from one
  (`hir::mutvec::Path`), and a callable has no field; a call's result is a
  temporary (`MUTABLE-PLACE-RECEIVER`);
* the vector a call returns is a new value, owned by the binding receiving
  it -- which is a shared binding on its own account -- and the vector a
  parameter takes is the caller's argument, a logical copy
  (`mutable_vector#share`);
* what the function captures is a binding of its own, mentioned by the
  function's region (`capture`): a captured vector is a shared binding of its
  own, and the capture of a vector its function mutates is
  `MUTABLE-PLACE-CAPTURE`, which the narrowing mentions above reach;
* a function value is unrestricted (`hir::types::IsAffine`: an exact or
  structural function type never is, whatever its result), so no use moves
  it; a coroutine handle is affine on its own account, which
  `BindingSuccessors` asks first;
* what the uses of a function do share -- its summary, its untyped
  parameters' inferred contracts, its semantic instances and their budget,
  what its calls erase, its yield type -- each has its own edge (`calls`
  and `defines` to its literal's region, `untyped-parameter`, `C:budget`,
  `C:erased`, the yield edge), none of which is the shared-binding edge.

| program | before | after | sequential |
|---|---|---|---|
| a capture of a vector that an earlier, rejected block mutates (`se-equal-every-mention`) | 2 rounds, the capture rejected (`MUTABLE-PLACE-CAPTURE`): another program | 2 rounds, the capture accepted | 2 rounds |
| the same with a site between them | 2 rounds, mispredicted `{2 f1:311}` | 2 rounds | 2 rounds |
| `se-builds-ownership-verdict`'s reproducer | 3 rounds | 3 rounds (4 with every mention but functions still shared) | 4 rounds |

Every committed golden suite (61; each compiled once with the tree before
and after, `surface::readProgramFile`, batched): the same site outcomes in
every one, and the same rounds and builds in all but these:

| suite | before rounds/builds | after rounds/builds | why |
|---|---|---|---|
| `affinity.bot` | 8/9 | 9/10, mispredicted `{8 f1:40943}` | two COROUTINE-CONTRACT sites wait for the erasing sites before them (a coroutine handle leaving its construction: the contract-boundary check, one of the expressions the analysis used to drop); so they are rejected last, and the site whose AFFINE-GENERIC-NESTED-UNSUPPORTED only the plan reports (below) is predicted beside them |
| `framework-semantics.bot` | 3/7 | 5/9 | four sites holding coroutine handles at contract-boundary positions wait for the erasing site `f1:6473`; one message naming internal ids now waits for the sequential order's own build (`firstIds` is the site's first id) |
| `linux-io.bot` | 3/3 | 4/4 | `structural_without_error`'s `apply0(argv)` -- `argv` acquiring a structural `Fn` type, a contract-boundary check whose TYPE diagnostic reads what the program erases -- waits for the erasing sites before it |
| `mutable-array.bot` | 6/21 | 7/34 | contract-boundary sites wait for the erasing `f1:108837` and `f1:118817`, three id-bearing messages for the sequential order's builds; the method-style calls in the waiting sites are decided again in two more checked rounds (5 trials each) |
| `mutable-vector.bot` | 5/30 | 4/21 | fewer: no site is linked to another any more through a function returning a vector (whose last mention used to be a shared-binding edge), so round 2 commits all 23 failing sites. With every mention but functions still shared it took 13/110: every site capturing `empty_queue` depended on every other, one rejection per round |
| `ownership.bot` | 4/11 | 5/24 | 21 sites holding coroutine handles at contract-boundary positions wait for the erasing sites `f1:10166`, then `f1:18503`; the three method-style calls sit in sites with such positions, so their cones reach the erased contract and they are decided again in every checked round (5 trials each) |
| `traits.bot` | 5/10, mispredicted `{4 f1:33553} {4 f1:34023}` | the same | the plan (below) |
| **total** | **186/290** | **191/311** | |

The added builds are the contract-boundary edge doing its job: a site that
holds a callable or a handle acquiring a structural type has that check's
diagnostics only while the program erases something, and reads what it
erases (`SubsumeSuccessors`); the old analysis looked at one expression of
each site and so saw the edge only by chance. Whether the check can change
a site's *first* diagnostic is not decided here -- that would refine the
channel, not repair the walk. ([What the contract-boundary checks
read](#what-the-contract-boundary-checks-read) is that refinement: every
suite of this table is back at its count before this change, and
`affinity.bot` predicts right again.)

**Not modelled yet: the plan's gate.** `hir::traits::Plan` -- the trait
monomorphization's plan, which runs only on a program with no diagnostic at
all -- reports ordinary site diagnostics (TRAIT-IMPL-ORDER,
AFFINE-GENERIC-NESTED-UNSUPPORTED, TRAIT-INSTANCE-BUDGET, ...). A site
holding one fails only once every other diagnostic is gone, and no edge says
so: `traits.bot` mispredicted before this change and still does, and
`affinity.bot`'s new schedule exposed it (with the refined contract-boundary
channel below, its schedule is the old one again and predicts right; the
plan's channel is still missing). A three-site program (two TYPE
failures around an AFFINE-GENERIC-NESTED-UNSUPPORTED one) mispredicts on
the tree before this change. The decisions stay the sequential order's in
every case measured (a build reports plan diagnostics only when it reports
nothing else), but the channel is missing and is the next one to add, in the
manner of `C:verdict`.

Validation: `tests/static-economics.test` 35/35 and
`tests/static-compile.test` 83/83 (interp); `compare.tcl` on collections,
diagnostics, errors, harness, modules, ownership, representation, values,
loops, lists-and-sets, flags, coroutines and mutable-vector: every suite
batched = sequential exactly, no misprediction; the fuzzer, seeds 1 (10
programs), 2 and 3 (20 each, seed 3 with legacy): 50 programs, 1348 sites,
0 failures; `mutate.tcl` (in three `-only` runs): 22 mutants, 22 applied and killed.

### What the contract-boundary checks read

A refinement of the channel [every mention](#every-mention) made whole.
Counting every position of a site, every site holding a coroutine handle or
a callable at a contract-boundary position depended on the erased-callable
contract and waited for every erasing site's rejection -- and so did every
method-style call in a function holding such a site, whose cone went
`R -> holds Z -> subsume C:erased -> erasure Z`: decided again in every
checked round. Five golden suites took 30 builds more (the table above).
The edge mostly encoded the check's *gate* (whether anything is erased);
what it reads of the contract's content reaches a site through other edges
too.

**Who reads a report.** `hir::completions::ReportOutside` is called by
`Subsume` and `SubsumeHandle` alone, in the completion walk
(`hir::completions::checkBlock`, which `hir::errorsets::verify` alone
calls), and only while the program erases something. No analysis reads a
report: the semantic instances' check and the ownership analysis run before
that walk, the later passes read no diagnostic. Three things do:

1. the site's own diagnostics -- of which the scheduler reads whether the
   site fails and, if it does, its first diagnostic (`Simulate`'s status,
   the rejection it commits, the prediction the next build checks);
2. the trial builds of a method-style call (`hir::MethodCallProblems`: the
   diagnostics inside the call, minus those every candidate shares);
3. the "no diagnostic at all" gate of the trait monomorphization's plan --
   not modelled, as [before](#every-mention).

The channel now follows exactly these (`hir/staticdeps.tcl`'s header):

* **A site's checks are its own diagnostics'.** A site is two nodes:
  `Z:site`, its form as the code around it sees it (position, nesting, the
  ownership verdict's edges), and `D:site`, its own diagnostics, with
  `D:site -> Z:site` and the contract-boundary edges. What a site depends on
  is what `D:site` reaches; a region holding the site reaches `Z:site`
  only. A region's facts read a held site's form -- its body, or the
  reified failure that replaces it -- never its reports (1 and 3 above are
  not facts of a region; 2 is the next rule).
* **What a method-style call's trials judge** (`method-trial`).
  A candidate's parameter types are the structural types the call's own
  arguments acquire (`hir::callables::ArgContexts`), so the check of an
  argument may report in one candidate's trial and not in another's, and
  decide the call. `R:region -> C:erased` and `-> P:input` for every call
  with several candidates of which an argument has a callable part some
  parameter type could make structural (`CallableParts`: what
  `hir::completions::Align` finds for every target at once); for a handle
  argument only while a candidate is a coroutine operation, whose positions
  the check skips -- a handle's check reads no parameter type. Every other
  check inside the call reports alike in every trial, a problem every
  candidate shares, which decides nothing: the arguments are analyzed
  before the call from the same facts, and resolution numbers them alike for
  any candidate (the candidate is one callee `ref`). The graph before saw a
  call's trials only through a site's own positions, at the chosen
  candidate's parameter types, and not at all outside every site -- a gap
  `se-equal-method-trial` shows: `n.apply(mutable_array::generate)` with a
  lexical `apply` typing its callable `Fn{args: [int, any], ...}` (generate
  calls its second argument, uncontracted there, so it may raise whatever
  the program erases) and `pick::apply` leaving it untyped. While a
  contributor erases `raise_e` only `pick::apply` fits; once the contributor
  is rejected both fit, AMBIGUOUS-METHOD-CALL. The tree before this change
  reused the decision and accepted the block, where the sequential order
  rejects it.
* **Only where a check can report.** Not at a coroutine operation's own
  operand -- the handle a resume resumes, the thunk a construction runs:
  `SubsumeCall` skips their positions. (A resume written out from a call of
  a handle, `hir::coroutines::ElaborateResumes`, was checked as that call:
  the handle was its callee, its messages arguments -- so the operand alone
  is skipped.) At a handle only when its construction is in the body
  (`hir::coroutines::thunkOfHandle`; `SubsumeHandle` returns at once
  otherwise). What `thunkOfHandle` finds no other site's rejection changes:
  it follows the value's binding through the bindings defining it -- all
  visible at the handle, so declared in the site, in a site around it or
  outside every site (a site's own bindings are scoped to it) -- to a
  `coroutine#create` call, whose thunk is the block literal it is given.
* **Only while a report can be the first diagnostic.** `hir::CheckOnce`
  records the diagnostics reported before the completion walk
  (`beforeCompletions`: the range of their indices), and every report is
  appended after them. A site that fails in this build with its first
  diagnostic among them keeps that first diagnostic whatever the program
  erases -- what decides it is read through the site's other edges -- so
  `D:site` takes no contract-boundary edge. A site that is ok, or fails
  first with the completion walk's diagnostic or a later pass's, keeps the
  edges: a report may become (or stop being) its first diagnostic, also
  when the program begins to erase something. So does a site failing first
  with a method-style call's rejection: `DecideMethodCalls` prepends it and
  shifts the range past it, since its message names each candidate's first
  problem in its trial, which may be a report. (`hir::check`'s demotion
  rerun keeps the first check's range with its diagnostics.)

Why the scheduler stays exact: `Simulate` reads of a site its status and,
while it fails, its first diagnostic. A failing site without
contract-boundary edges keeps both as long as nothing its other edges reach
is rejected; an ok site keeps every edge; components and predictions are
computed from the same relation, and fewer edges only split components no
remaining edge links. The method decisions' reuse reads the cones from the
regions, which keep every edge their trials read.

Every golden suite (83), compiled once with the tree before and after
(`surface::readProgramFile`, batched): the same sites, diagnostics and decided
HIR in all of them, the same rounds and builds in all but these:

| suite | before | after | before [every mention](#every-mention) |
|---|---|---|---|
| `affinity.bot` | 9/10, mispredicted `{8 f1:40943}` | 8/9 | 8/9 |
| `callables.bot` | 16/16 | 14/14 | -- |
| `framework-semantics.bot` | 5/9 | 3/7 | 3/7 |
| `linux-io.bot` | 4/4 | 3/3 | 3/3 |
| `mutable-array.bot` | 7/34 (24 method trials) | 6/21 (14) | 6/21 |
| `ownership.bot` | 5/24 (15 method trials) | 4/11 (5) | 4/11 |
| `static-compile.bot` | 26/33 | 20/27 | -- |

(`traits.bot` keeps its two mispredictions: the plan's gate.)

In ownership.bot, the 21 sites holding handles at contract-boundary
positions fail first with USE-AFTER-MOVE, COROUTINE-RESUME-CONFLICT, ... --
the ownership and coroutine checks, before the completion walk -- and are
committed with the erasing `f1:10166`; the three method-style calls
(`q.swap(999, step)`, `q.length()`: a handle and vectors of handles as
arguments, no candidate a coroutine operation) are decided once, in the
first checked round, and reused after it. In linux-io.bot, `structural_without_error`'s TYPE is the
type checker's (argv's declared error does not fit `Fn{args: [], return:
list}`), not the contract-boundary report.

**What each rule buys** (each removed in turn): without the
`D:site`/`Z:site` split, ownership.bot takes 4/23 and mutable-array.bot 6/27
-- their method-style calls decided again in every checked round (15 and 18
trials); without the gate, ownership.bot 5/12, linux-io.bot 4/4 and
mutable-array.bot 7/22; framework-semantics.bot and affinity.bot recover with
either. The handle and operand rule changes no golden suite: it is the
check's own precision (`se-builds-subsume-checks`).

**A measurement trap.** `hir::static::InternalIds` (`\m[ebsyt][0-9]+\M`)
also matches a word of a file path a message quotes -- USE-AFTER-MOVE's
"moved here ... (PATH:LINE:COLUMN)" -- and the batched run then holds such a
rejection for the sequential order's own build. Checked out under a
directory named like `.../045414a6-a785-56f8-b501-.../` (`b501`),
ownership.bot takes 10/29 before this change and 9/16 after, affinity.bot
17/18 and 16/17: conservative, never another program, but the economics
depend on where the tree lies. Not changed here; every number of this
section was measured in checkouts whose paths have no such word.

Tests (`tests/static-economics.test`): `se-equal-subsume-gate` (a handle
leaving its construction, whose report vanishes with the contributor: judged
after it), `se-equal-method-trial` (above), `se-builds-subsume-gate` (three
USE-AFTER-MOVE handle sites rejected with the contributor: 2 rounds, 3
without the gate), `se-builds-subsume-checks` (a relayed parameter handle and
a locally resumed one: 2 rounds, 3 with either edge), `se-builds-held-site-checks`
(a failing site before an accepted one holding a handle check, one function:
2 rounds, 3 when the region follows the held site's checks),
`se-property-subsume-positions` (the facts above, where they live). Mutants
(`audit/static-decisions/tools/mutants.txt`): semantic
`subsume-gate-every-failing`, `subsume-constructed-handle-ignored`,
`method-trial-ignored`; economic `subsume-gate-ignored`,
`subsume-handle-from-elsewhere`, `subsume-coroutine-operand`,
`held-site-checks`.

Validation: `tests/static-economics.test` 41/41 and
`tests/static-compile.test` 83/83 (interp); `compare.tcl` on ownership,
affinity, framework-semantics, linux-io, mutable-array (batched 6/21,
sequential 69/1089 in 3.2 hours) and the other seven suites of the
validation sample: batched = sequential exactly, no misprediction (affinity
failed it before, on its misprediction); the fuzzer, seeds 1 (10 programs),
2 and 3 (20 each, seed 3 with legacy): 50 programs, 1348 sites, 0 failures;
`tests/golden.test` 9/9 (the validation sample and
`golden-static-economics`); `mutate.tcl`: 28 mutants, 28 applied and killed
(the six new ones each by the test named for it; a seventh,
`subsume-constructed-handle-ignored`, which drops a constructed handle's
edges, survives and is not kept: a handle's report carries what the program
erases only through a call of an uncontracted value its thunk reaches -- an
erased consumer's region, reached already).

## Method-call decisions

A round's method-style calls with several candidates are decided by trial
builds (METHOD-SUGAR.md). Now:

* **Reuse across rounds** (`hir::static::MethodSeeds`): the next round takes
  the previous round's decisions as made, except for the calls not decided
  there, those whose region reaches a block rejected since (`Deps` with
  METHODS: each call's *cone* of sites and calls), and every call such a
  call reaches (the trials pair a call's candidates with those of the calls
  it depends on). The certificate of a reused decision is that cone: no
  block in it changed form. A seed is keyed by the call's identity (file
  and syntax node, the same in every build of one compilation), never its
  name, and is applied only to a call still present with that candidate
  among its candidates.
* **No duplicate build** (`hir::SameChoices`): a trial or final build whose
  choices resolve every call to the candidate the initial build already
  chose *is* that build (deterministic, and the per-compilation registries
  are still its own) and is not made again. A round with nothing to decide
  costs one build, not two -- for every program, with or without static
  blocks.
* **Lifetime**: the seeds live in `decide`'s loop for one round; nothing
  persists across compilations. `hir::static::methodAudit 1` builds every
  seeded round again unseeded and fails unless the programs are identical;
  `hir::methodBuildReuse 0` rebuilds every repeated build
  (`se-method-reuse`, `se-method-invalidated`, `se-build-reuse-identical`).

## Instrumentation

* `hir::BuildStats`: process counters of whole-program builds
  (`hir::BuildOnce`), method trial builds, method final builds, and builds
  reused; read as differences.
* `staticStats` on every decided HIR: scheduler, rounds, builds, method
  trials/finals/reused, `committedWithoutBuild`, the dependency analysis's
  milliseconds (`depMs`), `mispredicted`, and with `hir::static::trace 1` (or
  `BOTLISH_STATIC_TRACE=1`, printed to stderr) the trace: per round its phase,
  bodies, undecided and failing blocks, builds and method trials, method
  seeds and retried calls, every rejection (key, kind, line:column), every
  acceptance, every deferred failing block with its reason (the dependency
  path to the rejected block it depends on, `hir::staticdeps::Explain`; an
  unknown block before it in its component; internal ids), and the
  program-wide channels open (erasure points, erased consumers, budget
  pressure, yielding functions, constructions).
* `hir::static::scheduler` / `BOTLISH_STATIC_SCHEDULER`: `batched`
  (default), `sequential` (the reference), `legacy`.

An excerpt (collections.bot):

```
static decisions (batched): 4 rounds, 7 builds (2 method trials, 1 method finals, 3 reused)
round 1 (resolution) bodies 44 undecided 44 builds 1 methodTrials 0
    reject f1:7564 UNKNOWN-FIELD 216:42
    ...
round 2 (checked) bodies 39 undecided 39 failing 17 builds 4 methodTrials 2 methodSeeds 10 methodRetried 0
    reject f1:6499 KNOWN-ERROR 190:9
    ... (15 rejections)
    defer f1:11374: its message names internal ids, numbered by the forms of the sites before it: decided in the sequential order's own build
    defer f1:26162: after a site of its component whose status is unknown
    accept 13: ...
    channels erasurePoints 9 erasedConsumers 7 budgetPressure 3 yieldingFunctions 6 constructions 6
round 3 (checked) bodies 24 undecided 11 failing 2 builds 1 methodTrials 0 methodSeeds 10 methodRetried 0
    reject f1:11374 AMBIGUOUS-METHOD-CALL 320:11
    reject f1:26162 TYPE 678:9
    accept 9: ...
round 4 (checked) bodies 22 undecided 0 failing 0 builds 1 methodTrials 0
```

## Measurements

`bench/static-decisions.tcl` generates each workload and counts whole-program
builds by wrapping `hir::BuildOnce`, so the same script measures the tree
before this milestone (commit b4d02ad, a scratch worktree) and the tree
after it. *Rounds* are the static decision rounds (`staticRounds`), *builds*
every `hir::BuildOnce` of the compilation -- the rounds', the method-call
decisions' trials and final builds, the trait monomorphization's. Build
counts are deterministic. Times are the front end (`surface::compile`,
warnings off) on a 4-CPU Linux x86-64 container, Tcl 9.0.1.

### Every workload, before and after

Measured once each, the before and after trees side by side (two benchmark
processes on the 4 CPUs, with other jobs running: the times compare within a
row, not absolutely; the quiet-machine times follow).

* **golden**: the golden framework's K-case suites (every third case
  rejected, the bodies nested in the registration function or each at the
  top level), as in GOLDEN-TEST-FRAMEWORK.md's compile-time table;
* **mixed**: independent blocks rejected at every stage (UNBOUND, TYPE,
  USE-AFTER-MOVE, KNOWN-ERROR, UNHANDLED-ERROR, a trait and a context
  diagnostic), every other block valid;
* **chains**: genuinely dependent blocks -- nested blocks each rejecting the
  one around it, and blocks in one function's statement sequence;
* **erased**: independent TYPE failures beside one or four accepted bodies
  that erase an error-bearing callable and two genuine consumers, and with
  the contributor rejected by resolution;
* **contracts**: callback registries through verified structural `Fn`
  contracts beside an erasing body (no consumer);
* **probes**: an ordinary application -- optional-feature probes and
  adapters, nested in one `detect()` function or at the top level;
* **methods**: method-style calls with two candidates in every block, and
  one call outside every block whose receiver a block's rejection changes.

#### Golden framework suites (every third case rejected)

| program | sites | rejected | before rounds/builds | before time | after rounds/builds | after time | speedup |
|---|---|---|---|---|---|---|---|
| 10 cases, all passing | 10 | 0 | 1/2 | 1.68 s | 1/1 | 1.10 s | 1.5x |
| 10 cases, UNBOUND, nested | 10 | 3 | 2/3 | 1.40 s | 2/2 | 0.87 s | 1.6x |
| 10 cases, UNBOUND, top level | 10 | 3 | 2/3 | 1.61 s | 2/2 | 1.06 s | 1.5x |
| 10 cases, TYPE, nested | 10 | 3 | 4/8 | 6.21 s | 2/2 | 2.15 s | 2.9x |
| 10 cases, TYPE, top level | 10 | 3 | 2/4 | 3.24 s | 2/2 | 1.47 s | 2.2x |
| 50 cases, all passing | 50 | 0 | 1/2 | 2.96 s | 1/1 | 1.88 s | 1.6x |
| 50 cases, UNBOUND, nested | 50 | 16 | 2/3 | 3.02 s | 2/2 | 2.45 s | 1.2x |
| 50 cases, UNBOUND, top level | 50 | 16 | 2/3 | 3.43 s | 2/2 | 2.14 s | 1.6x |
| 50 cases, TYPE, nested | 50 | 16 | 17/34 | 56.64 s | 2/2 | 4.43 s | 12.8x |
| 50 cases, TYPE, top level | 50 | 16 | 2/4 | 7.49 s | 2/2 | 4.01 s | 1.9x |
| 100 cases, all passing | 100 | 0 | 1/2 | 5.29 s | 1/1 | 4.06 s | 1.3x |
| 100 cases, UNBOUND, nested | 100 | 33 | 2/3 | 6.61 s | 2/2 | 4.13 s | 1.6x |
| 100 cases, UNBOUND, top level | 100 | 33 | 2/3 | 6.68 s | 2/2 | 3.73 s | 1.8x |
| 100 cases, TYPE, nested | 100 | 33 | 34/68 | 199.04 s | 2/2 | 6.89 s | 28.9x |
| 100 cases, TYPE, top level | 100 | 33 | 2/4 | 10.58 s | 2/2 | 6.93 s | 1.5x |
| 200 cases, all passing | 200 | 0 | 1/2 | 7.28 s | 1/1 | 5.10 s | 1.4x |
| 200 cases, UNBOUND, nested | 200 | 66 | 2/3 | 8.42 s | 2/2 | 5.85 s | 1.4x |
| 200 cases, UNBOUND, top level | 200 | 66 | 2/3 | 9.31 s | 2/2 | 6.76 s | 1.4x |
| 200 cases, TYPE, nested | 200 | 66 | 67/134 | 641.76 s | 2/2 | 10.57 s | 60.7x |
| 200 cases, TYPE, top level | 200 | 66 | 2/4 | 20.46 s | 2/2 | 10.69 s | 1.9x |

#### Mixed stages: independent sites rejected by resolution, the checker, ownership, completions, traits and contexts (every other site valid)

| program | sites | rejected | before rounds/builds | before time | after rounds/builds | after time | speedup |
|---|---|---|---|---|---|---|---|
| 10 sites, nested | 10 | 5 | 6/11 | 1.44 s | 3/3 | 0.38 s | 3.8x |
| 10 sites, top level | 10 | 5 | 3/5 | 0.44 s | 3/3 | 0.27 s | 1.6x |
| 50 sites, nested | 50 | 25 | 23/45 | 20.99 s | 3/3 | 1.78 s | 11.8x |
| 50 sites, top level | 50 | 25 | 3/5 | 1.84 s | 3/3 | 1.54 s | 1.2x |
| 100 sites, nested | 100 | 50 | 44/87 | 87.20 s | 3/3 | 3.59 s | 24.3x |
| 100 sites, top level | 100 | 50 | 3/5 | 3.69 s | 3/3 | 2.61 s | 1.4x |
| 200 sites, nested | 200 | 100 | 87/173 | 393.30 s | 3/3 | 7.99 s | 49.2x |
| 200 sites, top level | 200 | 100 | 3/5 | 8.55 s | 3/3 | 4.75 s | 1.8x |

#### Genuine dependency chains

| program | sites | rejected | before rounds/builds | before time | after rounds/builds | after time | speedup |
|---|---|---|---|---|---|---|---|
| 2 nested dependent blocks | 2 | 2 | 3/4 | 0.04 s | 3/3 | 0.05 s | 0.8x |
| 5 nested dependent blocks | 5 | 5 | 6/7 | 0.07 s | 6/6 | 0.07 s | 1.0x |
| 10 nested dependent blocks | 10 | 10 | 11/12 | 0.15 s | 11/11 | 0.18 s | 0.8x |
| 5 UNBOUND + 5 TYPE sites in one statement sequence | 10 | 10 | 7/13 | 0.32 s | 7/7 | 0.22 s | 1.5x |
| 10 UNBOUND + 10 TYPE sites in one statement sequence | 20 | 20 | 12/23 | 0.92 s | 12/12 | 0.55 s | 1.7x |

#### The erased-callable contract: one contributor, a few consumers, many independent sites

| program | sites | rejected | before rounds/builds | before time | after rounds/builds | after time | speedup |
|---|---|---|---|---|---|---|---|
| 10 sites, 1 contributor, 2 consumers | 10 | 4 | 3/6 | 0.51 s | 2/2 | 0.25 s | 2.0x |
| 10 sites, 4 contributors, 2 consumers | 10 | 6 | 6/12 | 1.26 s | 5/5 | 0.76 s | 1.7x |
| 10 sites, contributor rejected early, 2 consumers | 10 | 4 | 3/5 | 0.38 s | 3/3 | 0.34 s | 1.1x |
| 50 sites, 1 contributor, 2 consumers | 50 | 24 | 3/6 | 3.64 s | 2/2 | 1.66 s | 2.2x |
| 50 sites, 4 contributors, 2 consumers | 50 | 26 | 6/12 | 7.86 s | 5/5 | 3.40 s | 2.3x |
| 50 sites, contributor rejected early, 2 consumers | 50 | 24 | 3/5 | 1.89 s | 3/3 | 1.27 s | 1.5x |
| 100 sites, 1 contributor, 2 consumers | 100 | 49 | 3/6 | 7.62 s | 2/2 | 2.98 s | 2.6x |
| 100 sites, 4 contributors, 2 consumers | 100 | 51 | 6/12 | 16.36 s | 5/5 | 9.49 s | 1.7x |
| 100 sites, contributor rejected early, 2 consumers | 100 | 49 | 3/5 | 4.46 s | 3/3 | 2.78 s | 1.6x |
| 200 sites, 1 contributor, 2 consumers | 200 | 99 | 3/6 | 15.80 s | 2/2 | 7.71 s | 2.0x |
| 200 sites, 4 contributors, 2 consumers | 200 | 101 | 6/12 | 35.37 s | 5/5 | 17.65 s | 2.0x |
| 200 sites, contributor rejected early, 2 consumers | 200 | 99 | 3/5 | 8.48 s | 3/3 | 5.69 s | 1.5x |

#### Verified structural contracts (no erased-callable consumer)

| program | sites | rejected | before rounds/builds | before time | after rounds/builds | after time | speedup |
|---|---|---|---|---|---|---|---|
| 10 sites | 10 | 4 | 3/5 | 0.38 s | 3/3 | 0.25 s | 1.5x |
| 50 sites | 50 | 24 | 3/5 | 1.93 s | 3/3 | 1.31 s | 1.5x |
| 100 sites | 100 | 50 | 3/5 | 3.65 s | 3/3 | 2.53 s | 1.4x |
| 200 sites | 200 | 100 | 3/5 | 8.16 s | 3/3 | 5.74 s | 1.4x |

#### An application: optional-feature probes and adapters

| program | sites | rejected | before rounds/builds | before time | after rounds/builds | after time | speedup |
|---|---|---|---|---|---|---|---|
| 10 probes, nested in detect() | 10 | 6 | 6/11 | 1.08 s | 3/3 | 0.26 s | 4.2x |
| 10 probes, top level | 10 | 6 | 3/5 | 0.38 s | 3/3 | 0.35 s | 1.1x |
| 50 probes, nested in detect() | 50 | 30 | 22/43 | 19.50 s | 3/3 | 1.71 s | 11.4x |
| 50 probes, top level | 50 | 30 | 3/5 | 2.03 s | 3/3 | 1.62 s | 1.3x |
| 100 probes, nested in detect() | 100 | 60 | 42/83 | 80.14 s | 3/3 | 3.21 s | 25.0x |
| 100 probes, top level | 100 | 60 | 3/5 | 4.89 s | 3/3 | 3.33 s | 1.5x |
| 200 probes, nested in detect() | 200 | 120 | 82/163 | 321.22 s | 3/3 | 7.37 s | 43.6x |
| 200 probes, top level | 200 | 120 | 3/5 | 10.28 s | 3/3 | 7.48 s | 1.4x |

#### Method-style calls with several candidates in many blocks (every third rejected)

| program | sites | rejected | before rounds/builds | before time | after rounds/builds | after time | speedup |
|---|---|---|---|---|---|---|---|
| 10 sites | 11 | 4 | 3/13 | 1.01 s | 3/9 | 0.93 s | 1.1x |
| 50 sites | 51 | 17 | 3/13 | 5.21 s | 3/9 | 4.23 s | 1.2x |
| 100 sites | 101 | 34 | 3/13 | 10.45 s | 3/9 | 9.23 s | 1.1x |
| 200 sites | 201 | 67 | 3/13 | 25.33 s | 3/9 | 17.35 s | 1.5x |


Reading it:

* Nested and top-level layouts now cost the same at every size; before, the
  nested ones grew linearly (one round, two builds, per checker rejection)
  and the 200-case suite took 134 builds. The build counts after are
  constant in the number of blocks for every workload except the genuine
  chains, which keep their depth (K + 1 builds for a chain of K) -- they
  were not batchable and are not batched.
* Even where the rounds did not change (top-level layouts, chains), the
  builds dropped: the method-call decisions no longer rebuild the build
  they started from (2 builds per round became 1).
* The erased-callable contract no longer serializes anything but its
  consumers: one contributor costs no extra round (2 builds instead of 6),
  four contributors one round each (5 instead of 12 builds), and a verified
  structural contract nothing.
* The remaining speedup at constant builds (1.2-2x on the top-level rows) is
  the halved method-decision builds; at 200 cases nested it is 61x.

### Quiet machine

The same machine with nothing else running, one process at a time.

**The golden framework's suites** (best of 3 after; one run before, whose
nested TYPE rows take minutes):

| program | before rounds/builds | before | after rounds/builds | after | speedup |
|---|---|---|---|---|---|
| 10 cases, all passing | 1/2 | 1.62 s | 1/1 | 0.80 s | 2.0x |
| 10 cases, UNBOUND, nested | 2/3 | 1.46 s | 2/2 | 1.03 s | 1.4x |
| 10 cases, UNBOUND, top level | 2/3 | 1.53 s | 2/2 | 1.09 s | 1.4x |
| 10 cases, TYPE, nested | 4/8 | 6.22 s | 2/2 | 1.72 s | 3.6x |
| 10 cases, TYPE, top level | 2/4 | 3.45 s | 2/2 | 2.05 s | 1.7x |
| 50 cases, all passing | 1/2 | 3.21 s | 1/1 | 1.81 s | 1.8x |
| 50 cases, UNBOUND, nested | 2/3 | 3.15 s | 2/2 | 2.44 s | 1.3x |
| 50 cases, UNBOUND, top level | 2/3 | 3.15 s | 2/2 | 2.17 s | 1.5x |
| 50 cases, TYPE, nested | 17/34 | 54.32 s | 2/2 | 4.50 s | 12.1x |
| 50 cases, TYPE, top level | 2/4 | 5.61 s | 2/2 | 4.39 s | 1.3x |
| 100 cases, all passing | 1/2 | 5.01 s | 1/1 | 2.97 s | 1.7x |
| 100 cases, UNBOUND, nested | 2/3 | 5.35 s | 2/2 | 3.55 s | 1.5x |
| 100 cases, UNBOUND, top level | 2/3 | 5.95 s | 2/2 | 3.93 s | 1.5x |
| 100 cases, TYPE, nested | 34/68 | 192.09 s | 2/2 | 6.23 s | 30.8x |
| 100 cases, TYPE, top level | 2/4 | 11.57 s | 2/2 | 6.33 s | 1.8x |

**The eight golden suites** (the before tree's suites in their hoisted
layouts, the after tree's in their natural ones; each compiled in a fresh
process, front end only, best of 3, the trees alternated; the builds of the
before tree from `bench/static-decisions.tcl`):

| suite | blocks | before rounds/builds/method trials | before | after rounds/builds/method trials | after | speedup |
|---|---|---|---|---|---|---|
| collections.bot | 44 | 3/11/6 | 24.3 s | 4/7/2 | 15.9 s | 1.5x |
| diagnostics.bot | 28 | 5/12/4 | 22.7 s | 5/7/1 | 11.9 s | 1.9x |
| errors.bot | 26 | 8/15/0 | 32.0 s | 3/3/0 | 5.1 s | 6.3x |
| harness.bot | 14 | 2/3/0 | 2.5 s | 2/2/0 | 1.7 s | 1.4x |
| modules.bot | 33 | 3/6/0 | 21.8 s | 3/4/0 | 11.8 s | 1.8x |
| ownership.bot | 37 / 38 | 4/26/18 | 64.3 s | 4/11/5 | 27.5 s | 2.3x |
| representation.bot | 14 | 2/4/0 | 7.0 s | 2/2/0 | 3.6 s | 1.9x |
| values.bot | 26 | 1/2/0 | 6.9 s | 1/1/0 | 4.7 s | 1.5x |
| **total** | 222 / 223 | **28/79/28** | **181.4 s** | **24/37/8** | **82.2 s** | **2.2x** |

(ownership.bot holds one block more after: `af-generic-errors/admitted`.)
The suites' natural layouts on the tree before (one run each): diagnostics.bot
14 rounds, 34 builds, 93.1 s; ownership.bot 25 rounds, 194 builds (144 of them
method trials), 640.8 s -- against 5/7, 11.9 s and 4/11, 27.5 s after: the
layout workaround is no longer needed, and the natural layout costs less
than the workaround did. These times are slower than GOLDEN-TEST-FRAMEWORK.md's
and VERIFIED-CALLABLE-CONTRACT-BOUNDARY.md's (112 s for the eight suites
there, 181 s here for the same tree): another machine; the before and after
columns here are the same machine, alternated.

Splitting the gain: the build count fell from 79 to 37 (a factor 2.1) and the
front end from 181 to 82 s (2.2); the time per build stayed within a few
percent (the profile below), so the gain is the builds not made.


**Method-style call decisions** (the methods workload, best of 3): 13
builds with 8 method trial builds before, 9 builds with 4 trials after, at
10, 50 and 100 blocks (0.95 -> 0.73 s, 4.34 -> 3.24 s, 10.22 -> 7.68 s).
Of the 4 trials left, 3 are the first checked round's own (nothing to reuse
yet) and 1 the call outside every block whose receiver a rejection changed
-- decided again, as it must be (`se-method-invalidated` pins that case).
The golden suites: 28 method trial builds before, 8 after
(collections 6 -> 2, diagnostics 4 -> 1, ownership 18 -> 5).

**Where the time goes** (`profile.tcl`, scratch: inclusive time of the main
phases, outermost calls only, one fresh process each):

| program | tree | front end | builds | per build | the checks (`hir::check`) | method decisions (incl. their builds) | dependency analysis (`Deps`) | other static bookkeeping |
|---|---|---|---|---|---|---|---|---|
| errors.bot | before | 30.09 s | 15 | 2.0 s | 21.61 s (72%) | 13.00 s (43%) | -- | 0.24 s |
| errors.bot | after | 5.49 s | 3 | 1.8 s | 2.85 s (52%) | 0.00 s | 0.18 s (3.3%) | 0.04 s |
| ownership.bot, natural layout | before | 649.94 s | 194 | 3.4 s | 521.32 s (80%) | 555.56 s (85%) | -- | 1.34 s |
| ownership.bot, natural layout | after | 31.45 s | 11 | 2.9 s | 23.51 s (75%) | 17.63 s (56%) | 0.63 s (2.0%) | 0.05 s |
| 100 cases, TYPE, nested | before | 192.78 s | 68 | 2.8 s | 136.32 s (71%) | 86.47 s (45%) | -- | 2.38 s |
| 100 cases, TYPE, nested | after | 5.57 s | 2 | 2.8 s | 2.97 s (53%) | 0.00 s | 0.22 s (3.9%) | 0.06 s |

Inside the checks, the same phases dominate before and after (signature
inference about a third of the front end, then the semantic instances, the
completion analysis, hygiene, ownership): the speedup is the builds not
made, not cheaper builds. Per build, the after tree costs the same or less
(the dependency analysis, 2-4% of the front end at golden-suite sizes, is
paid back by the duplicate builds no longer made); the static bookkeeping
(expansion, attribution, simulation, seeds) is under 1%. At 500 blocks
the analysis grows to 2.0 s of a 20.9 s front end (9.7%): it is one walk of
a build plus a strongly-connected-components pass, so it grows with the
program, like a build, not with the rounds.

**Memory** (peak resident set of a fresh process compiling the program):

| program | before | after |
|---|---|---|
| 100 cases, all passing | 84 MB | 72 MB |
| 100 cases, TYPE, nested | 105 MB | 96 MB |
| 500 cases, all passing | 215 MB | 178 MB |
| 500 cases, TYPE, nested | not run (167 rounds) | 253 MB |
| errors.bot | 98 MB | 90 MB |
| ownership.bot, natural layout | 125 MB | 122 MB |

No build outlives its round: a round keeps the build it decides on until
the next one replaces it, plus its dependency graph and the method-call
seeds (key -> candidate), both dropped with it. The peak is one or two
builds, as before; the after tree's lower peaks are the duplicate builds no
longer made.

**Process history**: compiling the same program again in one process gives the same
decisions and the same builds every time (`se-deterministic`; here six
times, errors.bot and the 100-case suite), and the peak resident set stays
flat (94 MB after six compilations of errors.bot, 90 MB after one) -- no
cache of this milestone grows. The *time* does grow, in both trees alike:
errors.bot 5.3 s for the first compilation and 6.1-7.1 s for the next five
(before: 32.0 s, then 35-40 s), the 100-case suite 4.5 s then up to 7.6 s.
Neither a namespace variable, a namespace, a proc nor a command grows
between compilations (checked); it is a property of the interpreter's
state over a long process, present before this milestone, recorded here as
a finding for the benchmarks (which compile many programs in one process:
their later rows are inflated alike in both trees) and not addressed.


## Validation

### Semantics frozen: the schedulers against each other

* `tests/static-economics.test` (30 tests): batched equals sequential --
  and legacy, up to internal ids -- on independent failures at every stage
  nested and top level, statement sequences, nested chains (resolution and
  checker), internal-id messages, the erased-callable contract with
  contributors and genuine consumers, several contributors, captured untyped
  parameters, sibling blocks with coroutine moves, an independent
  USE-AFTER-MOVE and an error edge, and a corpus of contexts, opaque
  structs, traits, coroutines, method sugar and namespaced errors (every
  program must compile: two failures alike are refused as evidence); no
  misprediction on the golden framework's suites; the build-count bounds;
  method-call reuse (audited) and invalidation; build reuse identical with
  and without static blocks; the batched run on synthetic relations; the
  trace; determinism; and the compiler properties the analysis relies on.
* `audit/static-decisions/tools/compare.tcl tests/golden/*.bot` (batched,
  sequential, legacy; every site's outcome and reified diagnostic, the
  programs' diagnostics, the decided HIR, no misprediction): all eight
  suites agree exactly with the sequential reference, and with legacy up to
  internal ids (collections.bot's one id, [above](#before-against-after-the-trees)).
  Rounds/builds, with the new build reuse in all three (the legacy column
  is therefore cheaper than the tree before; the suites in their current,
  natural layouts):

  | suite | batched | sequential | legacy |
  |---|---|---|---|
  | collections.bot | 4/7 | 19/73 | 3/9 |
  | diagnostics.bot | 5/7 | 14/22 | 14/22 |
  | errors.bot | 3/3 | 8/8 | 8/8 |
  | harness.bot | 2/2 | 2/2 | 2/2 |
  | modules.bot | 3/4 | 23/24 | 3/4 |
  | ownership.bot | 4/11 | 25/170 | 25/170 |
  | representation.bot | 2/2 | 2/2 | 2/2 |
  | values.bot | 1/1 | 1/1 | 1/1 |
  | **total** | **24/37** | **94/302** | **58/218** |

  The legacy column is what the natural layouts would have cost the old
  procedure: diagnostics.bot and ownership.bot with their erasing code back
  at the top level take 14 and 25 rounds there.
* The fuzzer, seeds 1-3, 20 programs each in four layouts, under all three
  schedulers: 60 programs, 1608 blocks (944 rejected), every fragment kind
  of the pool drawn (each seed's summary lists them), 0 failures -- every
  program batched = sequential exactly and legacy up to ids, every layout
  the same verdicts, every program within the economic model. Six layout
  pairs took different rounds, all in programs with blocks the
  erased-callable contract links (the allowance is 0 without them).
  Before the allowance was corrected, seed 3's program 6 was flagged
  (5 rounds nested, 7 split; [point 70](#70-remaining-unavoidable-dependency-cases)).
* The existing suites under the reference
  (`BOTLISH_STATIC_SCHEDULER=sequential`): `tests/golden-framework.test`
  41/41, `tests/static-economics.test` 31/31, `tests/static-compile.test`
  82/83 -- the one failure is `sc-rounds`, which pins the batched economics
  (twelve blocks, eight rejected: 3 rounds; the reference takes 6). Every
  semantic expectation of the static-compile negative tests (code, primary,
  related, message) holds under both schedulers.
* `audit/static-compile/tools/fuzz.tcl` (its independent model and the
  ordinary compiler), seeds 1, 2 and 3 (the last with `-gc-stress 1`): 90
  programs, 532 sites, 0 disagreements; exact diagnostics for all 204
  rejected sites, every accepted site transparent.

### Before against after: the trees

`dump.tcl` (scratch; every site's outcome and reified diagnostic, the
program's diagnostics, the final HIR text, the Core IR and the NIR) on both
trees, the same files:

| corpus | files | identical | differing |
|---|---|---|---|
| `examples/**/*.bot`, `bench/*.bot` (no static blocks: the build reuse alone) | 41 | 41 (39 with NIR) | 0 |
| the eight golden suites (current layouts), the two old layouts of diagnostics.bot and ownership.bot, and 28 benchmark workloads (golden, mixed, erased, contract, probes, methods at 10 and 30 sites; a chain; a sequence) | 38 | 37 (32 with NIR) | 1 |

(The library directory's path, which an UNKNOWN-NAMESPACE message names, is
normalized.) The one difference is one internal id in one message:
collections.bot's `b_field_call_ambiguous` is rejected with
AMBIGUOUS-METHOD-CALL whose message names the receiver's exact callable type
`block(e2024)` before and `block(e2023)` after -- in the site record, the
reified `message` constant in HIR, Core IR and NIR alike, and nowhere else.
The sequential reference gives `e2023`; the legacy scheduler gives `e2024`
in the new tree too. The old procedure committed that rejection in the same
round as an earlier failing block that was still a body in that build, so
the expression ids before it were numbered over the earlier block's body
rather than its reified failure: a message that did not follow the old
procedure's own definition. The new scheduler holds such a rejection until
the sequential order's build (the trace's internal-ids deferral; one round
in collections.bot). The suites never compared it (`rejects_at` pins code
and location). Every other site outcome, code, primary, related location and
message, every program diagnostic, and every final HIR, Core IR and NIR is
byte-identical.

### Mutation

`audit/static-decisions/tools/mutate.tcl`: 17 mutants, 17 killed. Twelve
are semantic (the batched scheduler would decide another program), five
economic (the decisions stay right, the builds grow: the milestone's
contract is economic, so these are bugs too and the build-count tests kill
them). Detectors: `tests/static-economics.test`, and the fuzzer (6
programs, seed 5).

| mutant | kind | killed by tests | fuzzer |
|---|---|---|---|
| `decide-dependents-together` (every failing site committed in the build that found it) | semantic | se-equal-erased-consumer, -nested-checked, -ownership-siblings, -untyped-capture, se-simulate-*, ... | survived |
| `unknown-does-not-block` (an unknown site does not hold back its component) | semantic | se-simulate-component-waits | survived |
| `erased-contributors-ignored` (the erased contract depends on no contributor) | semantic | se-equal-erased-consumer | survived |
| `contribution-not-discarded` (an erasing call inside a block is no dependency on it) | semantic | se-equal-erased-consumer | survived |
| `nested-child-ignored` (a block does not depend on its nested blocks) | semantic | se-equal-nested-checked | survived |
| `position-ignored` (no dependency on the code around a block) | semantic | se-equal-erased-consumer, -nested-checked, -ownership-siblings, -untyped-capture, se-trace | survived |
| `precedence-changed` (a batched rejection carries its last diagnostic) | semantic | se-simulate-independent | killed |
| `internal-ids-ignored` (an id-bearing message committed from any build) | semantic | se-equal-internal-ids | survived |
| `untyped-parameter-ignored` (an untyped parameter's contract ignores nested uses) | semantic | se-equal-untyped-capture, se-trace | survived |
| `stale-method-reuse` (a decision reused though a rejected site reaches the call) | semantic | se-method-invalidated | survived |
| `method-key-alias` (a reused decision applied by name) | semantic | se-equal-corpus, se-method-reuse | killed |
| `same-choices-unchecked` (a decision build taken for the initial one whatever the choices) | semantic | se-build-reuse-identical, se-method-reuse | survived |
| `one-commit-per-build` (the sequential schedule) | economic | se-builds-* (6), se-equal-independent, ... | killed |
| `single-component` (an unknown site holds back every later one) | economic | se-simulate-component-waits, se-simulate-independent | survived |
| `every-region-consumes` (the legacy GlobalChannels) | economic | se-builds-contributor-checked | killed |
| `never-reuse-methods` | economic | se-method-reuse | survived |
| `nested-same-unit` (the legacy units) | economic | se-builds-legacy-pathology, se-builds-type-nested, se-equal-independent, se-trace | killed |

Two findings of the campaigns: `every-region-consumes` was at first killed
only by the fuzzer's economic bound, so `se-builds-contributor-checked` now
pins it deterministically; and hardening `seSame` (two compilations failing
alike are no evidence) showed that three of `se-equal-corpus`'s five
programs had never compiled -- Tcl's `\{` inside a braced list is two
characters, so their struct literals and coroutine bindings parsed as a
backslash -- and passed vacuously. They are rewritten, a namespaced-error
program added, and the corpus now kills `method-key-alias` as well.

The existing campaigns, on the final tree:

| harness | mutants | killed |
|---|---|---|
| `audit/static-compile/tools/mutate.tcl` (three retargeted from the legacy code path to the batched one, same rules: `leaks-affine-move`, `warning-becomes-error`, `internal-becomes-compiler-error`) | 21 | 21 |
| `audit/structural-contracts/tools/mutate.tcl` | 18 | 18 |
| `audit/error-payloads/tools/mutate.tcl` (completion mutants included) | 44 | 44 |
| `audit/affine/tools/mutate.tcl` | 29 | 29 |
| `audit/coroutines/tools/mutate.tcl` (native mutants rebuilt privately) | 52 | 52 |

The golden framework's cross-suite spot-check
(`audit/golden/tools/check.tcl -mutants`, the 21 compiler and runtime
mutants of GOLDEN-TEST-FRAMEWORK.md, "Mutation spot-check"): 18 BOTH, 3
BOTH-SUITE-LEVEL, no OLD-ONLY, no NEW-ONLY, no NEITHER -- the same verdict
for every mutant as before the milestone. The scheduler does not weaken
any golden test's detection.

### Regression

* `CORE_BACKEND=interp tclsh9.0 tests/all.tcl`: 7250 tests, 7250 passed,
  0 failed (169 files).
* `CORE_BACKEND=compile tclsh9.0 tests/all.tcl`: 7250 tests, 7246 passed,
  4 skipped (the existing `coreScoping` constraint), 0 failed.

* `cargo test --release --manifest-path native/Cargo.toml`: 219 + 31
  passed, 0 failed (no native change).
* `tests/native-coverage.tcl` (the suite on Cranelift): 7250 tests -- 2946
  native, 4175 independent, 69 passed-partial, 60 unsupported (the existing
  test-only natives, sequence mode and value tests), 0 failed.
* `audit/refactor/tools/gate.tcl`: passed (57 corpus programs, 16 library
  loaders, the observed warnings exactly the manifest's 42 entries).
* GC stress: `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/golden.test`: 9/9
  (the eight static-heavy suites on interp, compile, cranelift-generic and
  cranelift, and `golden-static-economics`).
* Scalar/codegen audit: `native/generate-scalar-audit.tcl -outdir` into a
  scratch directory against the committed `audit/native-scalar-asm/`:
  every `.asm`, `.vcode` and summary file byte-identical; only the README's
  provenance lines (commit, rustc version) differ.



## Report

The 72 points of the milestone brief's report (item 98), in order.

### 1. Exact old decision algorithm

[The old procedure](#the-old-procedure): loader rejections first; a
resolution-halted round rejects every block with a resolution diagnostic of
its own; a typed round rejects the first failing block in post-order, plus
each other failing block `Independent` proves uninfluenced (different
top-level units, neither reaching the other), none while `GlobalChannels`
holds; one more build per round for the method-call decisions' final
build. It survives verbatim as the `legacy` scheduler.

### 2. Why independent same-unit TYPE failures serialized

`Independent` compared *top-level units*: two blocks nested in one
function were never independent, whatever they referenced, so a
registration function holding every test's body decided one checker
rejection per round (100 cases: 34 rounds, 68 builds). The unit was a proxy
for "may see each other's effects"; the dependency graph replaces it by what
each block's analysis actually reads -- and a nested function is analyzed
from its own entry, seeing of the enclosing function only its captures
(`se-property-nested-entry`, `se-property-capture-narrowing`).

### 3. Old GlobalChannels behavior

A Boolean over a build: a demoted trusted contract, or a non-empty
erased-callable contract (`hir::completions::erasedErrorsOf`). True meant
one rejection per round for the whole program. It was true in every build of
errors.bot (8 rounds instead of 4), and would have been for diagnostics.bot
and ownership.bot in their natural layouts (14 and 25 rounds), which is why
those two suites kept their erasing code in a block placed first.

### 4. Old method-sugar trial behavior

Every round's `BuildFull` decided every method-style call with several
candidates from scratch -- one trial build per candidate index, repeated
while a receiver was unstable -- and always ended with a final build, even
with nothing to decide: two builds per round at least, more with ambiguous
calls (the methods workload: 3 rounds, 13 builds, 8 of them method trials,
at 10, 50 and 100 blocks alike; the golden suites: 28 method trial builds).

### 5. Instrumentation added

[Instrumentation](#instrumentation): `hir::BuildStats`, `staticStats`
(rounds, builds, method trials/finals/reused, blocks committed without a
build, dependency-analysis time, mispredictions), the trace with deferral
reasons and dependency paths (`BOTLISH_STATIC_TRACE=1`), and the scheduler
switch (`BOTLISH_STATIC_SCHEDULER`).

### 6. Dependency theorem

[The theorem](#the-theorem): a block's own diagnostics depend only on the
forms of the blocks its analysis reads; a block that does not depend on a
rejected block keeps its diagnostics in the next build.

### 7. Stable decision

The first block of its component that is not ok, failing, with nothing it
depends on rejected since the build (and, for a message naming internal
ids, no block numbered before them in a different form than in the
sequential order's build).

### 8. Rejection batching algorithm

`hir::static::Simulate`: statuses failing/ok/unknown per present block;
components by union-find over the dependency relation; repeatedly take the
earliest failing block in post-order that is the first non-ok block of its
component, commit it (accepting the component's undecided blocks before
it, and the blocks nested in it), make every block depending on it unknown;
a component whose first non-ok block is unknown waits. Within a run the
commits are made in post-order of the whole program, so the trace is
deterministic; across components they may interleave differently from the
sequential scheduler's (a later component's rejection committed while an
earlier component waits for a build), which no outcome can observe: no
decision in one component changes a status in another.

### 9. Acceptance batching

A block is accepted when its component's sequential step passes it (it is
ok and comes before the component's committed rejection), and every
undecided block is accepted by the build in which nothing fails. Accepted
blocks are the harder side: a block accepted in a component that later
rejects something it depends on would be rejected again (decisions go only
from body to rejection) -- the sequential order does the same. The
dependencies that still force rounds on the accepting side: the final build
itself (the final program must be built, item 23), and a component's blocks
after an unknown block, which wait for that block's build ([item
70](#70-remaining-unavoidable-dependency-cases)).

### 10. Nested-static dependency treatment

An outer block depends on every block nested in it (`Z:outer -> Z:inner`);
post-order puts the inner one first. An inner rejection makes the outer
unknown until the next build -- where its first diagnostic may now be the
inner block's unadmitted `CompilerError` (`se-equal-nested-checked`); a
chain of K nested blocks each rejecting the next takes K + 1 builds
(`se-equal-nested-chain`, the chain workload). A rejected outer block takes
its nested blocks with it.

### 11. Diagnostic precedence preservation

Every committed rejection carries its block's *first* own diagnostic in a
build whose relevant facts equal the sequential order's build of that step
(`precedence-changed` mutant: killed). Resolution diagnostics still come
first (resolution-halted builds), loader diagnostics before them, a
method-call decision's prepended diagnostic in its place.

### 12. Outer-diagnostic ownership

Unchanged: a diagnostic belongs to the innermost present block whose body
holds its primary location (`Attribute`, `Owner`), otherwise to the program;
the program's own diagnostics are never consulted while deciding, and the
final program's are raised as before. The batched run reads the same
attribution of the same builds.

### 13. GlobalChannels contributor model

`C:erased`'s contributors: each semantic-instance request whose arguments at
parameters with no declared or trusted contract can carry errors
(`CanCarry`: a callable or a value holding one), by those arguments and the
call's own place, up the chain of requests when the request is itself in an
instance; each position of contravariant erasure; each request the budget
declined. Rejecting a block that holds a contributor changes the contract:
the block is reached from every consumer (`contribution-not-discarded`,
`erased-contributors-ignored` mutants: killed).

### 14. GlobalChannels consumer model

A region consumes `C:erased` when it calls through a value with neither
identity nor contract precision: callee `any` or a bare kind, or a native
calling such an argument (`errorsFrom`). The contract-boundary checks
(`Subsume`) are a site-local consumer of the block whose positions they
run at. Everything else -- unrelated blocks, exact calls, calls through
verified contracts -- consumes nothing (`every-region-consumes` mutant, the
legacy behavior: killed by the build counts).

### 15. Erased-callable dependency treatment

The two models above make the erased-callable contract one node of the
graph: a consumer depends on every contributor; a contributor's rejection
makes its consumers unknown; independent blocks beside them are decided in
the first build (`se-builds-erased`: 20 failures beside one contributor and
one consumer, a constant number of builds; the erased workload: 2 builds for
1 contributor and 2 consumers at 10-200 sites).

### 16. Verified structural calls

Not consumers (VERIFIED-CALLABLE-CONTRACT-BOUNDARY.md: the contract bounds a
call through a structural type whatever it holds, and every value acquiring
the type was checked against it). `se-builds-contract`: callbacks through
`Fn` parameters, struct fields and vector elements beside an erasing body --
12 failures in one build; the contract workload: 3 builds at 10-200 sites.

### 17. Coroutine erased channel

A coroutine construction is a call of a root native with the callable as
argument, so a callable that erases errors through it is a contributor like
any other; a coroutine's yields are typed by the constructions reaching it,
a separate backward edge (`yield type`). The fuzzer's pool and the
corpus test include coroutines; ownership.bot's `af-generic-errors/admitted`
is the coroutine case of the natural layout (4 rounds, 11 builds).

### 18. Method decision reuse design

[Method-call decisions](#method-call-decisions): seeds from the previous
round minus the retry closure; build reuse when choices equal the initial
build's.

### 19. Method cache validity key / certificate

The key is the call's identity (`methodCalls` key: file and syntax node);
the certificate is its cone (`Deps` with METHODS: the sites and calls its
region reaches) containing no block rejected since; a seed applies only to
a call still present with that candidate among its candidates.

### 20. Method cache invalidation

A call is decided afresh when it was not decided, when a block rejected
since is in its cone (its receiver, arguments or candidate set may differ:
`se-method-invalidated` -- `mk()` becomes `never` and `xs.length()`
ambiguous), and when it reaches such a call. Mutants `stale-method-reuse`
and `method-key-alias` (a decision applied by name) are killed.

### 21. Cache lifetime

One round: the seeds are computed from one build for the next and dropped.
Nothing is stored in a namespace variable or on disk; the build counters are
process totals read as differences. `se-deterministic` compiles the same
program three times in one process: the same decisions, the same economics.

### 22. Transaction model after optimization

Unchanged ([STATIC-COMPILE.md](STATIC-COMPILE.md#the-transaction-model)):
every build is a fresh pure value; trial builds are discarded; the batched
run never continues through an invalid state -- it reuses a build's
diagnostics only for blocks whose inputs equal the sequential order's.

### 23. Final ordinary BuildFull

Remains: the final program is the `hir::BuildFull` of the round in which no
block fails, with its own diagnostics and warnings. The one build it no
longer repeats is the method decisions' duplicate of the initial build when
the choices are the same (`hir::SameChoices`), which is the same value
(`se-build-reuse-identical`; the before/after differential of 41 example
and benchmark programs without static blocks: identical HIR, Core IR and NIR).

### 24. Synthetic all-accepted results

One build at every size (10-200 cases), nested or top level -- before, two
(the method decisions' duplicate final build). [Every
workload](#every-workload-before-and-after), golden rows "all passing";
`se-builds-accepted`.

### 25. Synthetic UNBOUND results

Two builds at every size and layout (a resolution round, then the final
program) -- before, three. `se-builds-unbound` pins 10, 50 and 100 cases.

### 26. Synthetic TYPE nested results

Two builds at every size: 10 cases 8 -> 2, 50 cases 34 -> 2, 100 cases
68 -> 2, 200 cases 134 -> 2 (the brief's target was at most 6 for 100).
`se-builds-type-nested` pins 100 cases at at most 4 builds and equal to the
top-level layout.

### 27. Synthetic TYPE top-level results

Two builds at every size (before: four). Nested and top level are now the
same program for the scheduler.

### 28-31. 10 / 50 / 100 / 200-case build counts and times

The golden rows of [Every workload](#every-workload-before-and-after) (all
four sizes) and the [quiet-machine](#quiet-machine) table (10, 50, 100;
best of 3 after): 100 nested cases 192 s -> 6.2 s, the same bodies at the
top level 11.6 s -> 6.3 s, all passing 5.0 s -> 3.0 s.

### 32. Mixed-phase benchmark

Three builds at every size and layout (resolution, the checked round that
rejects every independent checker, ownership, completion, trait and context
failure at once, the final program): 200 nested blocks 173 -> 3 builds,
393 -> 8.0 s.

### 33. Genuine nested dependency chain

Unchanged rounds, as required: a chain of K nested blocks takes K + 1 rounds
before and after (2: 3, 5: 6, 10: 11), and so do blocks in one statement
sequence (10: 7 rounds, 20: 12). Only the builds drop, to one per round: the
chains' rounds are resolution-halted but the last (4 -> 3, 7 -> 6, 12 -> 11
builds), the sequences' are checked rounds that each built twice (13 -> 7,
23 -> 12).

### 34. Erased-channel benchmark

One accepted contributor and two consumers beside independent failures: 2
builds at every size (before: 6, three rounds of two). A contributor
rejected by resolution: 3 builds (before 5).

### 35. Multiple-contributor benchmark

Four contributors rejected by the checker before two consumers: 5 builds at
every size -- one round per contributor-to-consumer stratum -- against 12
before.

### 36. General non-test benchmark

The probes workload (optional-feature probes and adapters, an ordinary
application shape): 3 builds at every size and layout; nested in one
`detect()` function, 200 probes took 163 builds and 321 s before, 3 builds
and 7.4 s after.

### 37-39. errors.bot before / after: rounds, builds, time

8 rounds and 15 builds before (the accepted erasing body kept
`GlobalChannels` open in every build), 3 rounds and 3 builds after;
32.0 s -> 5.1 s front end (fresh process, best of 3). Its rounds are now
its semantic depth: a resolution round, a checked round, the final build.
Before C3 it took 4 rounds and 7 builds.

### 40. ownership.bot natural-layout result

With `af-generic-errors`' admitted half in its natural place (the generic HOF
at the suite's top level) and nothing placed first: 4 rounds, 11 builds, 5
method trials, 27.5 s -- against 25 rounds, 194 builds and 640.8 s for the
same file on the tree before, and 4 rounds, 26 builds, 64.3 s for the old,
hoisted file there.

### 41. af-generic-errors natural-layout result

Both halves ported: `af-generic-errors/unadmitted` (UnhandledError) and the
new `af-generic-errors/admitted` (`[run(9), run(3)]` is `[-1, 3]`, as in the
Tcl test), passing on all four backends; neither has to be the suite's first
block any more.

### 42-44. Total golden-suite rounds, builds, front-end time

28 rounds, 79 builds, 181.4 s before; 24 rounds, 37 builds, 82.2 s after
(fresh processes, best of 3, this machine). With all 223 golden verdicts
preserved (one more test than before: `af-generic-errors/admitted`).
`golden-static-economics` bounds the total at 50 builds and any suite at 15.

### 45. Method-sugar trial count before / after

The golden suites: 28 method trial builds before, 8 after. The methods
workload: 8 -> 4 at every size; the 4 left are the first checked round's
own and the one call a rejection genuinely changes. Build reuse saves the
duplicate final build of every round, method calls or not: 1 build per
round instead of 2.

### 46. Source-layout sensitivity before / after

Before: the same bodies nested or at the top level took 68 and 4 builds
(100 cases, 33 TYPE); diagnostics.bot and ownership.bot in their natural
layouts 34 and 194 builds against 12 and 26 hoisted. After: nested and top
level the same at every size (2 builds); the natural layouts cheaper than
the old workaround. What remains is the order of one-way dependencies --
consumers and contributors of the erased-callable contract -- which the
sequential definition itself depends on ([point
70](#70-remaining-unavoidable-dependency-cases)): six of 60 fuzz programs
took different rounds in different layouts, never beyond the allowance.

### 47. Memory / peak retention

[Memory](#quiet-machine): the peak is one or two builds, as before; every
case measured is at or below the tree before (500 passing cases: 215 ->
178 MB; 500 cases with 166 rejections: 253 MB after, not run before). No
build, graph or seed outlives its round; nothing outlives the compilation.

### 48. Static scheduling fuzzer design

`audit/static-decisions/tools/fuzz.tcl`: each case is a *semantic test
set* of 4-10 self-contained fragments drawn from a pool covering every stage
(resolution, checker, ownership, completions, opaque authority), nested
blocks (an accepted block around a rejected one, and genuine chains),
the erased-callable contract's contributors (accepted, rejected by the
checker, rejected by resolution) and consumers, verified structural
contracts (non-consumers), callers of a shared helper checked by
`Possible`, and method-style calls with several candidates. Each set is
written in four layouts (nested in one driver, top level, split over three
helpers, nested two drivers deep) and compiled under the batched,
sequential and legacy schedulers; it checks (1) batched equals sequential
exactly (sdDiff: every site's outcome and code/primary/related/message, the
program's diagnostics, the decided HIR, no misprediction), (2) legacy agrees
up to internal ids, (3) the four layouts give every fragment the same
verdict (outcome, code, line and column relative to the fragment) and the
same rounds -- up to one fewer than the blocks the erased-callable contract
links, where the order of contributors and consumers is the layout's -- and
(4) the economics: rounds within the generator's
own model of the set's dependency depth (resolution, checked, final, one
per genuine chain level, one per linked erased-contract member).

### 49. Semantic differential results

Batched against the sequential reference: equal on every test program of
`tests/static-economics.test`, all eight golden suites (`compare.tcl`), the
60 fuzz programs in four layouts each (240 compilations per scheduler), and
the existing suites run under the reference ([Validation](#validation)).
No misprediction anywhere.

### 50. Layout-fuzzer results

All 60 programs: every fragment the same verdict in all four layouts
(outcome, code, line and column relative to the fragment). Six layout pairs
took different rounds, all in programs whose blocks the erased-callable
contract links, within the allowance (one fewer than the linked blocks);
the largest, seed 3's program 6, 5 rounds nested and 7 split ([point
70](#70-remaining-unavoidable-dependency-cases)).

### 51. Nested-fuzzer results

The pool's nested fragments -- an accepted block around a rejected one
(`nestedok`, 76 drawn) and genuine chains whose inner rejection rejects the
outer block (`chain`, 80 drawn) -- agree with the reference in every
program and layout; `se-equal-nested-chain` and `se-equal-nested-checked`
pin a resolution chain and a checker chain, and `nested-child-ignored` (a
block not depending on its nested blocks) is killed.

### 52. Build-count / economics fuzz results

Every program of the three seeds within the generator's model (resolution,
checked, final, one per genuine chain level, one per linked erased-contract
block); the economic mutants `one-commit-per-build`, `every-region-consumes`
and `nested-same-unit` fail it.

### 53-55. Mutation catalog; semantic and performance-only mutants

[Mutation](#mutation): 17 mutants, 12 semantic and 5 economic, all killed by
`tests/static-economics.test` (the economic ones by its build-count tests),
5 of them also by the fuzzer.

### 56. Static-compile old mutants

21/21 killed, three retargeted from the legacy code path to the batched one
with the same rules (`leaks-affine-move`: every failing site rejected at
once; `warning-becomes-error`; `internal-becomes-compiler-error`) -- left
on the legacy path they would have mutated code no default compilation
runs. Wrong code, wrong primary, lost related, prefix execution, lost
result, wrapped run-time errors, KNOWN-ERROR, warnings, nested ownership,
transaction leakage: all covered, all killed.

### 57. Structural-contract / completion mutants

`audit/structural-contracts/tools/mutate.tcl` 18/18;
`audit/error-payloads/tools/mutate.tcl` 44/44 (its completion mutants
included). The scheduler reads the completion analysis's facts; it changes
none, and C3's boundary is unchanged.

### 58. Affine mutants

`audit/affine/tools/mutate.tcl` 29/29.

### 59. Coroutine mutants

`audit/coroutines/tools/mutate.tcl` 52/52 (its native mutants rebuilt in a
private copy).

### 60. Golden cross-suite mutant spot-check

21 mutants: 18 BOTH, 3 BOTH-SUITE-LEVEL -- every verdict as before.

### 61. Exact diagnostic differential

Every reified diagnostic (code, primary, related, message) of every block of
79 programs, before against after: equal, except one message's internal id
in collections.bot, where the old procedure did not follow its own
definition ([Before against after](#before-against-after-the-trees)).

### 62. Final-HIR differential

The same 79 programs: the decided HIR text byte-identical (the one id
inside that message's String constant aside); and batched against
sequential, identical everywhere (`sdDiff` compares `hir::format`).

### 63. NIR / codegen differential

The Core IR and NIR of every program of the 79 without diagnostics (71):
byte-identical, the same id aside. The scalar-assembly corpus regenerated:
byte-identical.

### 64. Full Tcl regression

Both backends, 7250 tests, 0 failures ([Regression](#regression)).

### 65. Native coverage

7250 tests on Cranelift: 0 failed (2946 native, 4175 independent, 69
passed-partial, 60 unsupported).

### 66. GC stress

`BOTLISH_NATIVE_GC_STRESS=1` over the golden suites (the static-heavy
programs, on all four backends): 9/9; the static-compile fuzzer's seed 3
under `-gc-stress 1`: no disagreement. The milestone changes no native code.

### 67. Scalar / codegen audit

`native/generate-scalar-audit.tcl` regenerated into a scratch directory:
every assembly, vcode and summary file byte-identical to the committed
corpus.



### 68. Documentation updates

STATIC-COMPILE.md (step 3 of "How it works", a new "Decision economics"
section: the schedulers, the theorem, the graph, method-call decisions, the
transaction model, complexity, the legacy procedure; the Performance text,
Files, What to run), this file, GOLDEN-TEST-FRAMEWORK.md (an update at the
top, the after numbers beside the historical ones, a note at every place
describing the layout rule or the old cost model), VERIFIED-CALLABLE-
CONTRACT-BOUNDARY.md (point 54's remaining limit marked fixed), AGENTS.md
("Static intrinsics": the scheduler contract and what to run), the headers
of `hir/static.tcl` (decision economics, the legacy scheduler,
`GlobalChannels` explained in C3's terms: identity precision, contract
precision, the uncontracted erased-callable channel) and
`hir/staticdeps.tcl`, `hir/hir.tcl`'s build counters and reuse, and the
golden suites' header comments.

### 69. Golden porting-guide changes

`tests/golden/README.md`: "Compile cost of rejected blocks" (put each
rejected body at the top level, put the erasing body first) is replaced by
"Layout is free": write a body where it reads best; a suite's builds grow
with how deeply its blocks really depend on each other, never with their
number or arrangement. A test author needs no knowledge of
`hir::static::GlobalChannels`. The manifest notes of
`sc-negative-unhandled-erased` and `af-generic-errors/*` record the history.

### 70. Remaining unavoidable dependency cases

What still costs a build, each because the next decision genuinely reads a
fact the previous one changes:

* **resolution, then the checks**: a resolution-halted build types
  nothing, so a program with resolution rejections takes one build for them
  before the checks can be read (UNBOUND workloads: 2 builds);
* **the final program**: after the last rejection the decided program must
  be built (unless the round that rejected nothing is already it);
* **nested blocks**: an outer block is judged again once an inner one is
  rejected (its body changed): one build per level of a genuine chain;
* **position**: a block whose rejection makes the code after it
  unreachable changes the diagnostics of the blocks after it in the same
  statement sequence (completion and ownership diagnostics are not
  reported in unreachable code): the sequence workload, one build per block;
* **shared state**: blocks using one affine or mutable binding, or one
  untyped parameter of their enclosing function (its contract is inferred
  from every use);
* **the erased-callable contract**: a consumer waits for its contributors'
  decisions; with several contributors rejected by the checker, one build
  per contributor that precedes a consumer (the erased workload with 4
  contributors: 5 builds at every size);
* **the instance budget under pressure**: every call of the function is
  both contributor and consumer;
* **internal ids**: a rejection whose message names internal ids waits for
  the sequential order's build when an earlier block's form differs
  (collections.bot's AMBIGUOUS-METHOD-CALL: one round);
* **order within a component**: a failing block after an unknown block of
  its component waits, even if it depends on nothing that changed (the
  sequential order judges the unknown block first; `se-simulate-component-
  waits`). This is the source of the layout sensitivity that remains: where
  a dependency runs one way, which block a layout writes first decides
  whether the second waits. Interleaving two contributors and two consumers
  differently (`contributor, consumer, contributor, consumer` against both
  contributors first) turns two strata into four: the sequential order
  itself judges each consumer after the contributors before it, and a
  consumer's diagnostic may change with each. Layouts of the same blocks
  differ by at most one round fewer than the blocks the contract links, and
  not at all without such blocks (the fuzzer checks both: seed 3's program 6
  takes 5 rounds nested and 7 split, with six linked blocks).

### 71. New expected complexity model

Builds = O(semantic stages + dependency depth + 1), not O(rejected blocks):

* independent blocks, nested or top level: a constant -- 1 build when all
  are accepted, 2 with resolution or checker rejections, 3 with both;
* nested or position-dependent blocks: one build per level (a chain of K:
  K + 1);
* program-wide channels: contributors and consumers form one component,
  decided in post-order, so the builds grow with the *strata* of that
  component -- consumers judged after a contributor's rejection -- not with
  the blocks beside it. A strongly connected group (blocks consuming and
  contributing to one erased contract) costs at most one build per member
  that the sequential order rejects in it.

Per build, the dependency analysis adds one walk of the build plus a
strongly-connected-components pass (`depMs`, [Measurements](#measurements)).

### 72. Next optimization opportunities

* **Per-build cost** is now the whole cost: a suite with two builds spends
  its time in the builds themselves (resolution, the checks, the trait
  monomorphization) and in back-end code generation (GOLDEN-TEST-
  FRAMEWORK.md, "Back ends"). Sharing the erased-callable static walk
  between the completion pass and the ownership pass (VERIFIED-CALLABLE-
  CONTRACT-BOUNDARY.md, point 37) is the next obvious saving.
* **The final build after the last rejection** could be avoided when every
  remaining block is predicted ok and the program's own diagnostics cannot
  change -- but the final program must be an ordinary build, so this would
  trade the transaction model's simplicity for one build; not done.
* **Finer components**: a failing block after an unknown block of its
  component could be committed when it depends on nothing that changed
  *and* nothing between them depends on it; the sequential order's own
  definition would have to be proven insensitive to that reordering, which
  internal-id messages make delicate. One round per such pair today.
* **Incremental builds** (reusing a build's analysis of unchanged
  functions) are out of scope (brief item 66): no persistent dependency
  database, no query system.



## Files

| file | what |
|---|---|
| `hir/static.tcl` | the schedulers (`decide`: batched, sequential, legacy), `Simulate`, `Components`, `MethodSeeds`, `Deferral`, the trace (`FormatTrace`), the legacy `Rejectable`/`Independent`/`Units`/`GlobalChannels` |
| `hir/staticdeps.tcl` | the dependency analysis (`Deps`, `Explain`, `Prepare`, the successors of every node kind) |
| `hir/hir.tcl` | `BuildStats`, `BuildFull`'s method-call seeds, `DecideMethodCalls`' seeds and build reuse, `SameChoices` |
| `surface/modules.tcl` | `RemapFile`: a module's context parameters, proof contracts and resume clauses keep their own file's origins (found by the analysis: they pointed at the entry file) |
| `tests/static-economics.test` | the schedulers' equality, the build-count bounds, method-call reuse and build reuse, the batched run on synthetic relations, the trace, determinism, the compiler properties the analysis relies on |
| `tests/golden.test` | `golden-static-economics`: the golden suites' builds bounded |
| `audit/static-decisions/tools/` | `lib.tcl` (records and differences), `compare.tcl` (files under every scheduler), `fuzz.tcl` (the model-based fuzzer), `mutate.tcl` and `mutants.txt` |
| `bench/static-decisions.tcl` | the measurements below |
| `tests/golden/diagnostics.bot`, `ownership.bot`, `errors.bot`, `modules.bot`, `README.md`, `manifest.tsv` | the natural layouts restored, the layout rule replaced |

## What to run when changing this

STATIC-COMPILE.md, "What to run when changing this", and AGENTS.md
("Static intrinsics"): `tests/static-economics.test`,
`tests/static-compile.test`, `tests/golden.test`,
`audit/static-decisions/tools/fuzz.tcl` (several seeds),
`audit/static-decisions/tools/compare.tcl tests/golden/*.bot` and
`audit/static-decisions/tools/mutate.tcl`; a new cross-function fact an
analysis reads is a new edge of `hir/staticdeps.tcl`, never a special case of
the scheduler.
