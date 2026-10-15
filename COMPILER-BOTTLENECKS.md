# Compiler bottlenecks and algorithmic performance bugs: what to tackle next

A backlog, ranked, of what makes the Botlish compiler slow and of the
algorithmic defects behind it, with the evidence for each item and what a
fix needs. It collects the measurements scattered over TEST-SUITE-COST.md,
LARGE-SCALE-GOLDEN-MIGRATION.md ("Compiler performance"),
STATIC-DECISION-ECONOMICS.md, RANGE-FIXPOINT-SCALING.md and the studies in
`audit/golden/migration/out/`. It adds what was measured while narrowing the
trait plan's gate (STATIC-DECISION-ECONOMICS.md, "Trait-polymorphic calls
with their instances"), including three defects found on the way (section 4).

State: main at `92ec95ed`, which is `fdbf946c` plus the C:plan port. Golden-suite
figures marked *measured here* are from `fdbf946c` unless noted, and were taken for this
report: single Tcl 9.0.1 processes on a 4-core container, with up to four
other jobs running. They are indicative, not a benchmark. Every other figure
is quoted from the document named beside it.

## 1. Summary

The front end is the cost. Running the tests costs almost nothing, and code
generation in Cranelift is negligible. Within the front end, the cost is the
work repeated per build: every static-decision round, method-call trial and
trait monomorphization is a whole-program build. So every per-build
inefficiency is multiplied by the build count.

| # | Item | Kind | Evidence | Effort |
|---|---|---|---|---|
| 1 | Semantic instances copy the whole HIR per walk and per view | O(instances x program) | callables.bot front end 28.6 -> 14.5 s with the prototype; growth exponent 2.04 -> 1.08 | prototype exists (branch `ccr-7eabe55c-semantic-in-place-views`) |
| 2 | Trait-polymorphic calls get unbounded abstract-view instances | O(N^2) instances, about N^4 time | *measured here*: a chain of 160 functions has 12,880 instances and takes 42-54 s | small to medium |
| 3 | Named functions are walked 2-3 times, nested ones 2^depth | exponential in nesting | callables.bot: 160,030 -> 61,481 expression evaluations | small |
| 4 | `hir::lower` rescans the affine tables per call node; the Tcl compiler re-lowers every block body | quadratic | 583 s corpus-wide; 718 calls taking 0.67 of 0.80 s | trivial (first half) |
| 5 | Hygiene rescans every binding and expression per rename | quadratic | 11% of the front end | small |
| 6 | `hir::contexts::Walk` rebuilds the same maps about 10 times per build | repeated work | 9.4% of representation.bot | small |
| 7 | `Conjuncts` re-walks an `and` chain at every level | quadratic | a 900-conjunct chain costs 170-260 s | small |
| 8 | The signature fixpoint's second round re-types the program to confirm unchanged seeds | 2x typing | round 2 is 51-62% of typing | medium (needs incremental re-typing) |
| 9 | A demoted contract re-runs the whole `CheckOnce` | 2x check | about 21% of callables.bot | medium (static-decision coupling) |
| 10 | Library modules are re-analysed in every build | per-build | about 0.5 s x 329 builds, about 165 s | large (needs 4.1 first) |
| 11 | Method-call trial builds | whole builds | 81 of 328 corpus builds; mutable-array.bot 14 of 20 | medium |
| 12 | Native NIR lowering copies the program per instance view | O(instances x program) | 36% of suite time (TEST-SUITE-COST.md) | large |
| 13 | The erased-callable static walk runs two or three times per build | repeated work | about 3% of a front end | small |
| 14 | Static-decision bookkeeping scales super-linearly in sites | O(S^2)-O(S^3) per round | under 1% today; 9.7% at 500 blocks | small to medium |

Correctness defects found alongside (section 4):

- a struct declaration leaks from one compilation into the next in the same process (root cause and a minimal reproducer in 4.1);
- a dead call of a trait-polymorphic function fails compilation with TRAIT-INSTANCE-BUDGET;
- a deep semantic-instance request could be declined by rejecting another site; that one is fixed by the C:plan port.

## 2. Where the time goes

- **Suite time (TEST-SUITE-COST.md section 1, 4,811 s).**
  - Tcl native lowering (`native::lowered`): 36.2%.
  - Front end: 28.0%.
  - Reference execution: 16.4%.
  - The `botlish-native` process: 4.0%.
  - `hir::lower`: 0.2%.
- **Golden suites (LARGE-SCALE-GOLDEN-MIGRATION.md, "Where a suite's time goes", 88 suites, 4,790 s).**
  - Front end: 1,518 s.
  - `hir::lower`: 583 s.
  - Tcl compiler code generation: 1,099 s, measured before main's 14a1143.
  - Cranelift NIR lowering: 396 s.
  - Cranelift code generation: 6.6 s.
  - Native execution: 0.09 s.
- **Front end by phase** (same document; self time):

  | Phase | Share of the front end |
  |---|---|
  | signatures | 38.2% |
  | semantic-instances | 12.6% |
  | hygiene | 11.2% |
  | errorsets | 7.7% |
  | static-decisions | 6.4% |
  | affine | 4.2% |
  | static-deps | 3.1% |
  | parse | 3.1% |
  | resolve | 2.8% |

  `bench/golden-suites.tcl` does not profile `hir::types::infer` or the semantic layer's Walk/Call/Analyze. Their time is charged to "signatures". It does not profile `hir::BuildFull` either, so per-build elaboration lands under "static-decisions".
- **Per build.** Building is now the whole cost (STATIC-DECISION-ECONOMICS.md, point 72). `BuildOnce` plus `BuildFull` are about 76-83% of the front end (`study-frontend-coupling.json`).
- **Golden suites on main (*measured here*, batched, 88 files).**
  - 210 rounds and 321 builds, about 1,000 s of front end.
  - Largest suites:

    | Suite | Front end | Rounds / builds |
    |---|---|---|
    | mutable-array.bot | 181.5 s | 5 / 20 |
    | destructuring.bot | 59.3 s | 5 / 7 |
    | structs-and-enums.bot | 45.5 s | 4 / 17 |
    | static-compile.bot | 43.3 s | 7 / 14 |
    | opaque.bot | 41.4 s | 8 / 12 |
    | methods.bot | 40.9 s | 4 / 6 |
    | stdlib-namespaces.bot | 40.7 s | 3 / 9 |
    | traits.bot | 38.0 s | 8 / 13 (5 / 10 with the C:plan port) |

  - mutable-array.bot costs about 9 s per build. Its builds are mostly method-call trials (item 11), and each build pays items 1, 3 and 5.

## 3. The backlog, in detail

### 3.1 Semantic instances copy the whole HIR (O(instances x program))

- **Where.**
  - `hir::semantic::Walk` (`hir/semantic.tcl`): the scratch HIR is the base HIR, so the first write duplicates `exprs`.
  - `hir::semantic::View`: once per used instance, from verification and from the trait plan.
  - The code-generation specializer does the same (`hir/specialize.tcl`: Analyze, Reanalyze, View).
- **Evidence.**
  - LARGE-SCALE-GOLDEN-MIGRATION.md, item 1.
  - `study-semantic-instances.json`; `study-type-inference.json`: callables.bot's Analyze self time is 8.7 s, 3.41 s of it the `exprs` copy, for an average walked region of 21 expressions in a 5,271-expression program.
  - Synthetic K-unit programs (`study-frontend-coupling.json`):

    | K | 25 | 50 | 100 | 200 |
    |---|---|---|---|---|
    | instances on | 0.79 s | 1.91 s | 8.65 s | 38.29 s |
    | instances off | | 0.95 s | 2.13 s | 4.39 s |
- **Fix.** The branch `ccr-7eabe55c-semantic-in-place-views` walks and views in place with region save/restore.
  - Its final HIR is byte-identical on the whole corpus.
  - Its results: callables.bot 28.6 -> 14.5 s, traits.bot 48.7 -> 34.7 s, growth exponent 2.04 -> 1.08.
  - The staged plan is in `study-semantic-instances.json`, item 3: in-place walks, Apply/Unapply views, indexes, then the specializer.
- **Validation.**
  - The semantic-instances, traits, affine and static-economics harnesses.
  - The branch's check mode: byte-identical HIR.
- **Do first.** It has the largest measured effect, and a verified prototype exists.

### 3.2 Unbounded abstract-view instances for trait-polymorphic calls (new)

- **What happens.** Every function's generic walk requests an instance for each call of a trait-polymorphic function. Inside a trait-polymorphic function `f`, the argument is `f`'s own *abstract* view (`{trait T {param e i}}`). So the request is keyed by `f`'s parameter, not the callee's.
  - In a chain `f1 -> f2 -> ... -> fN` of trait-polymorphic functions, each `fk`'s generic walk instantiates the whole rest of the chain for its own view: N(N+1)/2 instances, all but N of them abstract.
  - The plan clones only concrete witnesses. The abstract instances are typing work that nothing downstream uses beyond the generic result.
- **No budget bounds this.** A trait-polymorphic request past `maxPerBlock` (16) or `maxInstances` (2000) is re-keyed by its views and granted (`hir::semantic::Call`). Abstract views of different callers stay different keys, so the re-key merges nothing. The same re-keyed path also skips the nesting check.
- **Measured here** (chain programs, main; generator in section 6):

  | N | instances | front end |
  |---|---|---|
  | 10 | 55 | 0.08 s |
  | 20 | 210 | 0.13 s |
  | 40 | 820 | 0.34-0.52 s |
  | 80 | 3,240 | 2.8-3.3 s |
  | 160 | 12,880 | 42-54 s |

  Doubling N multiplies the time by about 15 at the top. That is the quadratic instance count times item 3.1's per-instance copy.
- **Not reached by the golden suites.** Their deepest trait-polymorphic nesting is 1 (*measured here*). It is reached by any library of layered generic helpers.
- **Fix, either way.**
  - Key an abstract-view request by the *callee's* abstract view, so one instance per callee serves every abstract caller. All abstract views of one trait are interchangeable up to renaming, which needs care for multi-parameter witnesses.
  - Or do not request an instance for an all-abstract entry at all: the generic walk of the callee already is that analysis, as for a `trivial` request.
- **Validation.** Check the trait plan's clones are unchanged with `tests/traits.test`, `audit/traits/tools/{fuzz,mutate}.tcl` and the context-trait harnesses.

### 3.3 Named functions are walked two or three times, nested ones 2^depth

- **Where.** `hir/types.tcl`, `hir::types::Block`: `set attempts [expr {$self eq "" ? 1 : 3}]`. Every bound block with a non-`never` result is walked at least twice, so a body nested d bound functions deep is walked about 2^d times.
- **Evidence** (`study-type-inference.json`).
  - harness.bot: 164 redundant second attempts, all reproducing the first.
  - loops.bot: expression evaluations 30,364 -> 12,632.
  - callables.bot: 160,030 -> 61,481; its signatures phase 10.4 -> 7.5 s alone, and 4.1 -> 2.1 s on top of 3.1.
- **Fix.** One attempt unless `self` is among the region's captures or static references, with the exactness guard of the study's Stage 4. The study verified identical final HIR on 6 suites.

### 3.4 `hir::lower` and the Tcl compiler's per-block lowering

- **`hir::lower` (quadratic).** `hir::lower`'s Pending and list-loop cases call `hir::affine::temporaries` (`hir/affine.tcl`) per call or struct node. That procedure rebuilds the set of construction operands from the affine `releases`/`exits`/`errorExits` tables every time.
  - Evidence: 0.29 of 0.30 s of lowering on traits-path.bot; 583 s corpus-wide (LARGE-SCALE item 3).
  - `compiler/compiler.tcl` and `native/lower.tcl` already compute it once. The fix is to compute it once per lowering.
- **The Tcl compiler (O(size x depth)).** `core::compiler::CompileBlock` lowers every block body with `hir::lower::body`, the nested ones again inside each enclosing block. Each nested block's Core IR is embedded as a literal in every enclosing block's generated source.
  - Evidence: `compileHir` makes 396 `temporaries` calls on traits-path.bot after 14a1143; the study counted 718 calls taking 0.67 of 0.80 s.
  - Fix: the quadratic factor goes with the first fix. Then memoize lowered bodies by expression id, or emit nested blocks by reference.

### 3.5 Hygiene rescans per rename

- **Where** (`hir/hygiene.tcl`).
  - `Rename` rebuilds the used-name set from all bindings and expressions.
  - `RenameTo` scans every expression and copies `exprs`.
  - `qualifyModules` calls `RenameTo` for every module top-level binding, in every build.
- **Evidence.**
  - 11% of the front end corpus-wide.
  - errors.bot: 153 `RenameTo` calls, 524 ms (10.4%).
  - A minimal program does 42 renames.
- **Fix.** Build a binding -> references index and a used-name set once and update them incrementally. Do `qualifyModules` in one pass with a binding -> name map.
- **Caution.** Hygiene's `NAME#N` numbering is read by the static decisions (`se-equal-hygiene-*`). The numbering must stay what it is.

### 3.6 `hir::contexts::Walk` repeated about ten times per build

- **Where.** Called from `hir/mutvec.tcl` (5 sites), `hir/affine.tcl` (2), `hir/coroutines.tcl` (2) and `hir/contexts.tcl`, each rebuilding the same parent maps.
- **Evidence.** representation.bot: 20 calls in 2 builds, 298 ms (9.4%). harness.bot: 118 ms (7.4%).
- **Fix.** Memoize per build. Invalidate it at the structural rewrites (`mutvec::Elaborate`, view application).

### 3.7 `Conjuncts` is quadratic in an `and`/`or` chain

- **Where.** `hir::completions::Conjuncts`, reached four times per `if` level through `BranchOutcome` and `BranchRelations`. The parser builds `a and b and ...` left-deep, so every level re-walks the rest of the chain.
- **Evidence.** A ~900-conjunct chain (150 CSV reference rows) costs 170-260 s of front end (TEST-SUITE-COST.md 3.3). `tests/native-csv-records.test` still builds it.
- **Fix.** Memoize per (condition, outcome) within the pass, or compose the facts bottom-up.

### 3.8 The signature fixpoint's confirming round

- **Where.** `hir/signatures.tcl` runs a full `hir::types::infer`, every semantic instance included, per round.
- **Evidence.** Every observed call took exactly two rounds. Round 2 reproduced round 1's seeds and cost 51-62% of the typing time (`study-type-inference.json`).
- **Fix.** Re-type only the blocks whose seeds changed, and their dependents. That needs incremental re-typing, because a seeded block's exact type embeds its contract.

### 3.9 The demotion re-check

- **Where.** `hir::check` (`hir/hir.tcl`) runs `CheckOnce` a second time whenever a trusted contract is demoted.
- **Evidence.** About 21% of callables.bot once items 3.1 and 3.3 are fixed.
- **Fix.** Re-check only the blocks the demoted parameters reach.
- **Coupling.** `hir/staticdeps.tcl` reads the HIR this produces, so it needs the static-decision harnesses (tests/static-economics.test, `se-property-demotion-keeps-diagnostics`).

### 3.10 Per-build re-analysis: library modules, method trials, the trait rebuild

- **Library modules.**
  - Every build re-resolves and re-analyses every imported module (`hir::BuildOnce`).
  - Cost: about 0.5 s per build for about 1,450 library expressions, about 165 s over the corpus's 329 builds. `lib/test.bot` alone is about 75 s.
  - Reusing an unchanged module's analysis within one compilation needs compilation isolation first (4.1).
- **Method-call trials.**
  - 81 of the corpus's 328 builds are trials (`hir::DecideMethodCalls`). mutable-array.bot has 14 trial builds of its 20.
  - The remaining trials are ones the dependency analysis does not cheapen.
  - Deciding a candidate by re-typing only the enclosing function region, falling back to a whole build only when the choice changes a cross-function fact, would remove most of them.
- **Trait monomorphization.**
  - `hir::traits::monomorphize` is a second full `BuildOnce` per round, and the result keeps `traitSource` (half of a small suite's 1.4 MB HIR).
  - Skipping the rebuild when the plan clones nothing and redirects no call is a cheap first step. It has not been verified.

### 3.11 Native NIR lowering

- **Evidence.** 36% of suite time (TEST-SUITE-COST.md); 0.7 s even for ten trivial cases (GOLDEN-TEST-FRAMEWORK.md).
- **Status.** Per-instance views were memoized (4ca69cb), but each still copies the program (`hir/specialize.tcl`, `View`). The memo keeps every view alive: peak RSS reaches 1,567 MB on destructuring.bot.
- **Fix.** An overlay or apply/restore working HIR, which is Stage 7 of the plan in item 3.1, and sequentializing the analyses that hold all views at once.

### 3.12 The erased-callable static walk, computed repeatedly

- **Where.** `hir::completions::staticsOf` runs through the completion pass, again through `erasureFacts` (`hir/affine.tcl`), and a third time from the legacy scheduler's `GlobalChannels`.
- **Evidence.** 0.13-0.27 s per suite, about 3% of a front end (VERIFIED-CALLABLE-CONTRACT-BOUNDARY.md section 37).
- **Fix.** Compute it once in `CheckOnce` and keep it as a HIR side table.

### 3.13 Static decisions

Batched decisions cost a few percent of a front end today. What remains:

- **Bookkeeping that grows super-linearly in sites** (code reading; under 1% at golden sizes).
  - `hir::static::Waits` scans every status for each failing site, and `Simulate` repeats it per committed rejection: O(S^2) per step.
  - `Attribute`/`Owner` scan the sites per diagnostic: O(D x S). An interval index over the sorted spans gives O(D log S).
  - `hir/staticdeps.tcl` unions every successor SCC's site set, about O(E x S). At 500 blocks the analysis is 2.0 s of a 20.9 s front end, 9.7% (STATIC-DECISION-ECONOMICS.md).
  - Bitset site sets, or computing only what `Simulate` queries, fix this.
- **Rounds at the ceiling.** `tests/golden.test`'s `golden-static-economics` allows 8 rounds.
  - opaque.bot sits at 8 (8 / 12).
  - traits.bot sat at 8 / 13 until the C:plan port (5 / 10).
  - The remaining cost is the component rule: a site that turns unknown holds back the later failing sites of its component. "Finer components" (point 72) is the open optimization.
- **The audit's sequential reference.**
  - `compare.tcl` against `sequential` is one build per rejection. On an earlier tree (*measured here*, before main's latest merge, indicative): destructuring.bot took 69 rounds / 205 builds, 3,347 s. mutable-array.bot did not finish in 3 hours.
  - A full-corpus comparison is therefore impractical, and the audits sample it. Items 3.1 and 3.3 shorten every one of those builds.
- **An analysis worth tightening.** The semantic layer's `End` and verification steps scan all calls per used instance: O(used x calls), and O(rounds x calls x used) in verification. Cheap at today's sizes, but bounded only by the 2000-instance budget, which item 3.2 shows trait-polymorphic requests escape.

### 3.14 Smaller suspects (code reading, not measured)

| Where | Suspected cost | Fix |
|---|---|---|
| `hir/specialize.tcl` view memo: `$hir eq $memoHir` | O(1) only for the identical Tcl object; otherwise both whole HIRs are stringified | compare a generation token |
| `hir/specialize.tcl` Fixpoint | rescans the queue for the newest id on every pop, O(Q^2) | a priority structure |
| `hir/semantic.tcl` Requeue/Drain | `in`/`ni` on list queues | dict membership |
| `hir/affine.tcl` verifyInstance | a full `contexts::Walk` of the view per affine-argument instance | share the walk (3.6) |
| `hir/hir.tcl` MethodCallProblems | a subtree walk and a diagnostics scan per undecided call per trial | index diagnostics by expression |
| `hir/coroutines.tcl` RefsOf | a full expression scan per yield site | one pass |
| `hir/mutvec.tcl` Elaborate | `ni $roots` inside a loop over all bindings | a dict |
| `compiler/compiler.tcl` | the code cache is keyed by full Core IR text and never evicted; unit procs are never deleted | bound the cache, delete procs after a run |

## 4. Defects found on the way

### 4.1 A declaration leaks from one compilation into the next

*Measured here.* In one Tcl process, compile `tests/golden/affinity.bot`
(which declares `struct Query`), then `tests/golden/refinements.bot` (which
declares `refined type Query = str` and `refined type Encoded = Query`).
The second fails:

```
refinements.bot:61:24: invalid refinement carrier Query for "Encoded":
Query is a stable value type, but refinements of aggregate, struct or
callable values are not supported yet ...
```

Alone, or after errors.bot or coroutines.bot, refinements.bot compiles
(3 rounds / 10 builds); through `tests/golden/run.tcl` it passes, 66 of 66.
The `Query` that `Encoded` resolves to is affinity.bot's struct.

The minimal pair: compile `struct Query: v: str` first, then

```
refined type Query = str
refined type Encoded = Query
struct R:
    x: int
```

The second program fails the same way; without its `struct R` it compiles.

The cause is the order of two steps. `hir::sourcetypes::apply` resolves the
refinement carriers first. Only after that does `hir::structs::apply`
replace the struct registry with this program's structs. While the carriers
are resolved, the previous compilation's structs are still registered.
`hir::BuildOnce` calls `hir::structs::Reset` only for a program that
declares no structs, so a program declaring none is not affected.

The fix is to drop the previous registration at the top of
`hir::sourcetypes::apply`, where `Reset` already reclaims the
`core::type`/`core::native` entries, rather than in `hir::structs::apply`.
The fix also needs a regression test that compiles the pair in one process.

Why it matters beyond the failure:

- Any tool that compiles several programs in one process can mis-compile, not only slow down: the warm runs of `bench/golden-suites.tcl -warm N`, the audits' and fuzzers' loops, and `tests/golden.test`'s runner.
- It is a concrete instance of LARGE-SCALE-GOLDEN-MIGRATION.md's recommendation 2, compilation isolation, which is "plausibly the cause" of the unexplained process-history slowdown: pass 2 of the golden suites takes 2,440 s against 2,055 s for pass 1 and 1,518 s cold. SOURCE-DEFINED-INTEGER-DOMAINS.md, "Compilation isolation", documents the wider gap.
- Item 3.10's module reuse needs isolation first.

### 4.2 A dead call of a trait-polymorphic function fails compilation

```
fn mk() errors compiler::CompilerError:
    static compile:
        Square {side: want_int("s")}     # rejected: mk() is `never`

fn use() -> int errors compiler::CompilerError:
    measure(mk())                         # measure(s: Shape) -> int
```

- **What happens.**
  - Once the static block is rejected, `mk()` has type `never`, so `measure(mk())` is a dead call. The semantic layer does not request an instance for it.
  - The trait plan then reports TRAIT-INSTANCE-BUDGET: "the compiler's semantic-instance budget declined it". That is false; no budget was involved. The program does not compile, although the call can never run.
  - A `never` argument arises only from a rejected site's reified failure. Any other always-failing call is a KNOWN-ERROR first.
- **Why the obvious fix is wrong.** The plan's `unreachable` action is not a fix. It replaces the call by `context#unreachable()` and drops the arguments, but the arguments must still run, because the `never` one is what raises the error.
- **Correct fixes.**
  - A plan action that keeps the arguments' evaluation and replaces only the call itself, for example a sequence of the arguments followed by `context#unreachable()`.
  - Or request an instance even for a dead call when the callee is trait-polymorphic.
- **Coupling.** `tests/static-economics.test`'s `se-equal-plan-unplanned` currently pins the gate on exactly this diagnostic: a fix changes that test's last outcome to `accepted`, and the test then needs another call without an instance. Run the trait harnesses (`audit/traits/tools/{fuzz,mutate}.tcl`) too.

### 4.3 A rejection could make a cached deep request the first one, which the nesting limit then declines (fixed)

The semantic layer declines a request for nesting only when it is the first
for its instance; a cache hit is never declined. Rejecting the site that made
the shallow first request therefore made a deep request the first, which was
then declined. The dependency analysis saw no pressure on the budget, so the
batched scheduler predicted the deep site ok and the next build contradicted
it (`se-equal-deep-first-request`, mispredicted on main).

The fix is the C:plan port's `deep` record: every request at half the nesting
limits or deeper puts the instance budget under pressure. No golden suite
comes near that depth: the deepest request is at stack 7 and Tcl level 75,
against 12 and 350.

A related gap stays open. A trait-polymorphic or affine request past the
per-block or total budget is re-keyed and granted without the nesting check,
so nothing bounds those requests' count or depth. That is item 3.2. Chains of
160 functions still compile at Tcl's default recursion limit, but the limit is
not enforced.

### 4.4 Deep static call chains exceed Tcl's recursion limit

A known issue, still open. `hir::completions::EffectiveFacts` has a cycle
guard and an analysis budget but no depth bound, and no compiler entry point
raises `interp recursionlimit`. A 105-function chain compiles and a
120-function one does not (RANGE-FIXPOINT-SCALING.md section 6); item 3.7's
left-deep chains are another source of depth. Fix with a depth bound that
falls back to the declared contract, plus a raised limit or an iterative
walk. The completion verdicts feed NIR, so this needs its own audit.

## 5. Suggested order

1. **Exact, small fixes with large measured effects:** 3.4 (temporaries once), 3.3 (one walk), 3.5 (hygiene index), 3.6 (memoized contexts walk), 3.7 (memoized conjuncts), 3.12 (statics once). Each changes no output: validate by byte-identical final HIR on the corpus, plus the harnesses AGENTS.md names for the area.
2. **3.1**, from its prototype; then **3.2**, which multiplies with it.
3. **4.1 and 4.2**, before anything that compiles many programs per process or reuses analyses across builds.
4. **3.8 and 3.9**, with the static-decision harnesses: both change what a build's HIR holds.
5. **3.10** (method trials, then library reuse once 4.1 is fixed) and **3.13**'s bookkeeping.
6. **3.11**, the largest; and **4.4**, with its own audit.

CI has no compile-time gate, only build-count guards: `tests/static-economics.test`, `golden-static-economics`, `tests/range-fixpoint-scaling.test` and `tests/hir-specialize.test`. A wall-time job over a fixed corpus (`bench/golden-suites.tcl -backends interp`) would catch regressions in the items above.

## 6. How to measure

All under `LANG=C.utf8 LC_ALL=C.utf8`:

- `tclsh9.0 bench/golden-suites.tcl ?-backends interp? ?-warm N? ?-profile 1? FILE.bot ...` -- per-suite rounds and builds, front end by phase, lowering, code generation, peak RSS; `-warm N` shows the process-history effect.
- `tclsh9.0 bench/static-decisions.tcl ?-parts golden,chain,erased,...? ?-schedulers ...?` -- rounds, builds and method trials per scheduler.
- `tclsh9.0 audit/static-decisions/tools/compare.tcl FILE.bot` -- batched against sequential.
- `staticStats` on a decided HIR (rounds, builds, `mispredicted`); `BOTLISH_STATIC_TRACE=1` for the per-round trace (its `channels` line counts the gate's consumers and the budget's pressure).
- The `semantic` field of a HIR (for a trait program, of its `traitSource`): `instances`, `calls`, `declined`, `deep`, and the `requests`/`hits`/`walks` census.
- The trait-polymorphic chain of item 3.2:

  ```tcl
  set text "trait Shape:\n    fn area(s: Shape) -> int\n\nstruct Square:\n    side: int\n\nfn area(s: Square) -> int:\n    s.side\n\nfn f$n\(s: Shape) -> int:\n    s.area()\n\n"
  for {set i [expr {$n-1}]} {$i >= 1} {incr i -1} {
      append text "fn f$i\(s: Shape) -> int:\n    f[expr {$i+1}](s)\n\n"
  }
  append text "f1(Square {side: 1})\n"
  # surface::compile $text x -strict 0 -warnings off; then
  # [dict size [dict get $hir traitSource semantic instances]]
  ```

- Raw study data: `audit/golden/migration/out/study-{semantic-instances,type-inference,frontend-coupling}.json`, `bench-golden-suites-{cold,warm}.md`.
