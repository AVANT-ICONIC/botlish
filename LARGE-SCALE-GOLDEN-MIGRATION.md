# LARGE-SCALE-GOLDEN-MIGRATION.md

The large-scale migration of the source-language and end-to-end Botlish
behavior tests from the Tcl harness into the Botlish-native golden framework
(GOLDEN-TEST-FRAMEWORK.md), after VERIFIED-CALLABLE-CONTRACT-BOUNDARY.md,
STATIC-DECISION-ECONOMICS.md and the native `imod` GC-safepoint repair.

> Test a theorem at the highest layer that can express it naturally, while
> retaining lower-layer tests for properties only those layers can observe.

## Outcome

**Every one of the 7280 Tcl tests that run on this revision is examined and
classified; every source-observable one has a Botlish-native golden
specification or a recorded reason; the Tcl suite is unchanged, independent and
still authoritative.** `tests/golden/manifest.tsv` is now the complete map
(8735 rows): 3252 Tcl tests are source-observable, of which 2209 are ported
whole (MIGRATED), 1041 have their source theorem ported while their Tcl test
keeps an internal theorem (SPLIT), and 2 are blocked by a documented compiler
limitation; 4028 observe what Botlish source cannot (2139 compiler or runtime
internals, 509 parser and header behavior, 470 warnings, 582 several programs,
a corpus file or the process environment, 119 run-time-only failures, 209
otherwise not expressible). The golden corpus grew from 8 suites and 223 tests
to **88 suite files and 4572 golden tests** (63,300 lines), organized by
language concept, every suite an ordinary strict program that passes on the Tcl
interpreter, the Tcl compiler, generic Cranelift and specialized Cranelift with
one report (10 companions exclude a backend with a recorded reason).

On the final tree, **all 4702 ported (Tcl test, golden test) pairs agree: old
passes, new passes** (audit/golden/tools/check.tcl, every ported Tcl test proven
to have run by name, every golden suite on all four backends), and the full Tcl
suite passes in both passes (7280 tests on interp; on compile 7276, the 4
others interp-only by constraint; 0 failed). Every golden test is demonstrably
capable of failing (audit/golden/tools/perturb.tcl: every one of the 4572 fails
with inverted verdicts, every one of the 4047 with a textual expectation fails
with it altered). The
framework's 20 mutants are all killed; of a 48-mutant cross-suite sample, 45
are detected by both layers, 2 only by Tcl (both explained: not
source-observable) and 1 by neither ported side ([Mutation](#mutation)).

The ordinary framework -- a context holding a `MutableVector` of deferred
`Fn{args: [], return: test::Match}` checks, a coroutine runner, explicit
`static compile:` per test -- carried the whole practical corpus with **no test
syntax, no global registry, no catch-all error, no test-only native and no layout
trick**. The library grew by exactly two helpers (`test::rejects_message`,
`test::rejects_containing`) after four suites had reimplemented them
independently.

The migration found and fixed **six compiler defects** in their own layers (two
completion-analysis precision/soundness defects; three static-decision defects,
two of which could make the batched scheduler commit a different decision or
build a different program than the sequential reference; a front-end crash on
recursive struct types), each with Tcl and golden regressions; and it found and
fixed **static-decision economics regressions** the previous milestone's
claims did not cover (independent blocks still serialized through the
erased-callable contract, nested sibling blocks, the trait plan's gate and
internal-id messages): the 85 suites' static decisions went from 303 rounds /
451 builds to 206 / 322 (all 88 suites now: 211 / 329, of which 81 method-call
trials, and no misprediction). See [Compiler findings](#compiler-findings).

PERF_SUMMARY

## Contents

* [The layered architecture](#the-layered-architecture)
* [Method](#method)
* [The census](#the-census)
* [The manifest](#the-manifest)
* [The golden corpus](#the-golden-corpus)
* [What stays in Tcl, and why](#what-stays-in-tcl-and-why)
* [Strength](#strength)
* [Old-test findings](#old-test-findings)
* [Compiler findings](#compiler-findings)
* [The framework at scale](#the-framework-at-scale)
* [Backends and exclusions](#backends-and-exclusions)
* [Non-vacuity](#non-vacuity)
* [Mutation](#mutation)
* [Performance](#performance)
* [Freeze classification](#freeze-classification)
* [Report](#report) -- the 75 points of the milestone report, in order
* [Recommendations](#recommendations)
* [Files](#files)
* [What to run when changing this](#what-to-run-when-changing-this)

## The layered architecture

The milestone builds the testing stack it was asked for, without yet deciding
the developer workflow around it:

| layer | what it is now | how it is checked |
|---|---|---|
| Botlish golden suites | 88 `tests/golden/*.bot` programs, 4572 tests: the source-level specification of user-visible Botlish semantics | `tests/golden/run.tcl` (every backend, one report), CI's four golden shards (`check.tcl -shard I/4`) |
| Tcl duplicate E2E corpus | the 2042 Tcl tests whose whole theorem a golden test now carries (`tcl_layer` DUPLICATED-E2E, future freeze class FROZEN-DUPLICATE-ORACLE) | unchanged: `tests/all.tcl`, both passes; side by side with their golden tests in CI's golden shards |
| Tcl internal / not-expressible / multi-program tests | 5238 Tcl tests (`tcl_layer` ACTIVE-INTERNAL 3650, ACTIVE-NOT-EXPRESSIBLE 1006, ACTIVE-MULTI-PROGRAM 582) | unchanged: `tests/all.tcl` |
| fuzzers, mutants, audits | unchanged, plus the migration's tools | the harnesses' own runs; the cross-suite mutant sample |

The two layers stay independent: no Tcl test calls the golden library, no golden
test shares expected-value code with a Tcl test, and the Tcl originals are
neither deleted, skipped, weakened nor frozen. A source bug can make the layers
disagree; on this revision they do not.

## Method

The migration was run as an orchestrated campaign over the whole corpus, in
three passes, each checked by tools rather than by trust:

1. **Ground truth.** Every Tcl test file ran once, verbosely, on this revision
   (`-verbose ps`, a private `-tmpdir` each, three at a time): 7250 tests ran and
   passed, loop-generated names included (a static count of `test` invocations
   is 6107). `audit/golden/migration/tcl-names.txt` is the name authority: 7280
   on the final tree, from its full interp regression (the 30 new tests are the
   regressions of the migration's compiler fixes).
2. **Census.** One classification row per Tcl test, per test file
   (`audit/golden/migration/census/*.tsv`, 169 files): what it observes (its
   helpers resolved: `sourceAgree`, `outcomeUnderHir`, Core IR text, `-strict
   0`, test natives, `main.tcl`, private modules), its observational status, the
   source theorem a golden test would assert, what only Tcl observes, and tags.
   `merge.tcl` checks every row against the names that ran (no stale or missing
   row; loop-generated patterns expanded).
3. **Migration.** The MIGRATE and SPLIT rows were cut into 45 batches by
   concept (`audit/golden/migration/batches/*.tsv`); each batch became a suite,
   written against the Tcl source itself (the census is guidance, not truth),
   with a manifest fragment (`audit/golden/migration/fragments/*.tsv`) covering
   every row of its batch -- a test found not to be portable after all is
   reclassified there with the reason. Each suite was accepted only after: all
   four backends pass with one report; its reported names equal its fragment's;
   `perturb.tcl` shows every test can fail; its static economics are measured;
   its Tcl originals still pass. Companion suites were created where a test needs
   a different import set, its own program-wide facts or a backend exclusion
   (33 of the 88 files).

`audit/golden/migration/merge.tcl` builds `tests/golden/manifest.tsv` from the
pre-migration manifest, the census, the fragments and the names; the census and
fragments stay committed as the evidence each row was derived from.
`audit/golden/tools/check.tcl` (now parallel, sharded, and proving each Tcl
verdict by name) is the full differential tool; `ledger.tcl` prints the ledger.

## The census

Per subsystem (`tclsh9.0 audit/golden/tools/ledger.tcl`):

| subsystem | Tcl tests | source-observable | migrated | split | internal | warning | parser | runtime-only | multi-program | not expressible | blocked | golden rows |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| abi | 175 | 86 | 76 | 10 | 18 | 0 | 0 | 7 | 62 | 2 | 0 | 167 |
| affine | 112 | 99 | 44 | 55 | 11 | 0 | 0 | 0 | 1 | 1 | 0 | 215 |
| collections | 584 | 321 | 263 | 58 | 132 | 0 | 0 | 23 | 106 | 2 | 0 | 449 |
| contexts | 75 | 42 | 22 | 20 | 14 | 0 | 0 | 2 | 8 | 9 | 0 | 90 |
| coroutines | 56 | 46 | 41 | 5 | 8 | 0 | 0 | 0 | 0 | 2 | 0 | 63 |
| diagnostics | 198 | 187 | 150 | 37 | 6 | 0 | 0 | 0 | 1 | 4 | 0 | 287 |
| errors | 267 | 222 | 184 | 38 | 19 | 0 | 0 | 6 | 16 | 4 | 0 | 423 |
| functions | 411 | 330 | 255 | 75 | 63 | 0 | 0 | 12 | 2 | 4 | 0 | 407 |
| gc | 167 | 75 | 4 | 71 | 63 | 0 | 0 | 0 | 29 | 0 | 0 | 80 |
| harness | 85 | 18 | 8 | 10 | 28 | 0 | 0 | 2 | 24 | 13 | 0 | 30 |
| hir-core-nir | 1258 | 118 | 1 | 117 | 1042 | 0 | 15 | 13 | 4 | 66 | 0 | 155 |
| modules | 216 | 106 | 72 | 34 | 16 | 0 | 20 | 1 | 71 | 2 | 0 | 205 |
| native | 919 | 344 | 91 | 252 | 479 | 0 | 0 | 17 | 67 | 12 | 1 | 382 |
| opaque | 107 | 80 | 77 | 3 | 10 | 0 | 0 | 2 | 9 | 6 | 0 | 115 |
| parser | 496 | 9 | 2 | 7 | 13 | 0 | 474 | 0 | 0 | 0 | 0 | 12 |
| refinements | 262 | 161 | 121 | 40 | 75 | 0 | 0 | 1 | 8 | 17 | 0 | 251 |
| static-compile | 68 | 33 | 23 | 10 | 35 | 0 | 0 | 0 | 0 | 0 | 0 | 44 |
| strings | 433 | 267 | 158 | 109 | 7 | 0 | 0 | 11 | 116 | 32 | 0 | 286 |
| surface | 685 | 645 | 575 | 70 | 9 | 0 | 0 | 22 | 0 | 9 | 0 | 952 |
| traits | 68 | 53 | 39 | 13 | 6 | 0 | 0 | 0 | 1 | 8 | 1 | 79 |
| warnings | 638 | 10 | 3 | 7 | 85 | 470 | 0 | 0 | 57 | 16 | 0 | 10 |
| **total** | **7280** | **3252** | **2209** | **1041** | **2139** | **470** | **509** | **119** | **582** | **209** | **2** | **4702** |

The subsystem is the census's reading of what a test is about, not its file
(warnings tests' program halves are counted under warnings; the parser's
lowering tests that observe values under parser). A golden row is one (Tcl test,
golden test) pair: 830 Tcl tests became several golden tests (a broad Tcl test
split into one coherent outcome each), and 120 golden tests stand for several
Tcl tests (interp/compile/parity twins of one program).

## The manifest

`tests/golden/manifest.tsv` keeps the validation sample's 19 columns and adds
six; the tools read columns by name, so nothing that read the old manifest
changed:

| column | meaning |
|---|---|
| `old_file`, `old_test` | the Tcl test (every Tcl test that runs has at least one row) |
| `suite`, `new_test` | the golden test, or `-` when the Tcl test is not ported |
| `category`, `subsystem` | the subsystem (above) |
| `outcome` | value, predicate, diagnostic, diagnostic-at, runtime-error (a declared error handled in the body), protocol, custom, not-ported |
| `old_backends`, `new_backends` | where each runs |
| `class`, `also` | DIRECT, STATIC-COMPILE-ADAPTATION, EXPLICIT-ERROR-HANDLER, CUSTOM-MATCHER, HARNESS-DIFFERENCE, OLD-TEST-OVERSPECIFIED, COMPILER-BUG-FOUND, NEW-FRAMEWORK-LIMITATION, NOT-EXPRESSIBLE |
| `static` | yes: the `static compile:` boundary is semantically needed (a rejection, or an error escaping the code under test); convention: it only isolates the test |
| `handler` | yes: the body handles a run-time declared error explicitly |
| `api` | simple (a library helper), helper (a suite-local registration helper), custom (`test::case`) |
| `verbosity` | clearer, similar, more-verbose than the Tcl test |
| `strength` | equal, stronger, weaker (the notes say exactly what was lost), split (the Tcl test also observes what only Tcl can) |
| `old_lines`, `new_lines` | approximate sizes |
| `mutants` | existing mutants (`audit/X/tools/mutants.txt NAME`) the Tcl test is known to kill |
| `notes` | adaptations, renamed declarations, dynamic inputs, dropped messages, strictness differences, old-test findings |
| `status` | MIGRATED, SPLIT, KEEP-INTERNAL, KEEP-WARNING, KEEP-PARSER, KEEP-RUNTIME-ONLY, KEEP-MULTI-PROGRAM, KEEP-NOT-EXPRESSIBLE, BLOCKED-GENERAL-COMPILER, BLOCKED-TEST-LIBRARY |
| `tcl_retained` | what only the Tcl test observes |
| `tcl_layer` | DUPLICATED-E2E, ACTIVE-INTERNAL, ACTIVE-NOT-EXPRESSIBLE, ACTIVE-MULTI-PROGRAM (decided per Tcl test) |
| `freeze` | FROZEN-DUPLICATE-ORACLE or ACTIVE-TCL-INTERNAL (the future freeze candidates; not acted on) |
| `tags` | STRICT0, CORE-IR, TEST-LOG, MESSAGE, LOCATION, RELATED, MULTI-BACKEND, DYNAMIC-INPUT, RUNTIME-ONLY:CODE, OUTER-ANCHOR, TOPLEVEL-DECL, CONTEXT-INSTALL, NATIVE-ONLY, STDOUT, ARGV, MAIN-TCL, PRIVATE-MODULE, CORPUS-SUBJECT, MUTANT, ... |

`tests/golden.test` and `check.tcl` still require each suite to report exactly
its manifest rows' tests (a test reported twice is now a problem too; several
rows may name one golden test).

## The golden corpus

88 suite files: the validation sample's 8 (unchanged but for one test moved
out of `representation.bot`, [below](#backends-and-exclusions)), 45 suites of the
migration's batches, two regression suites of the compiler defects the migration
fixed (`completion-regressions.bot`, `recursive-types.bot`), and 33 companions.
A suite is named for its concept, not its Tcl file (`destructuring.bot`,
`callable-contracts.bot`, `affinity.bot`, ...); the manifest keeps the mapping
back. A companion exists for one of three reasons, each stated in its header:

* **its imports or top-level names** (16 files): imports decide
  method-candidate visibility and `MissingImport`, and an entry program's own
  top-level names can collide with a namespace's, so a test about a namespace
  *not* being imported, a method call a further import would make ambiguous, an
  `import type`, or an enum named like a namespace needs a program that declares
  and imports exactly that (`methods-list-without-str.bot`,
  `imports-unimported.bot`, `structs-and-enums-qualifiers.bot`,
  `mutable-vector-str.bot` -- adding `import str` to `mutable-vector.bot` turns
  three USE-AFTER-MOVE rejections into NO-APPLICABLE-METHOD, because
  `str::length` becomes a candidate -- ...);
* **a program-wide fact** (7 files): the erased-callable contract is
  everything the *whole* program passes into untyped parameters, so a test of
  what an uncontracted call is charged needs a program that erases exactly its
  own callables (`callable-contracts-returned.bot`, `-fallback`, `-handle`,
  `-unerased`, `-contravariant`, `-contravariant-rejected`,
  `static-compile-erased-consumer.bot`);
* **a backend exclusion** (10 files, [below](#backends-and-exclusions)), so that
  the main suite keeps its full matrix.

Per suite (cold, one process per suite, one at a time, on a quiet 4-core
machine: `bench/golden-suites.tcl`; the interp, compile and Cranelift columns are
each backend's preparation plus its run of the whole suite, after the shared
front end; `x` an excluded backend, which the benchmark runs anyway and which
reports its unsupported operation):

SUITE_TABLE

Every suite ends with `with context test::suite()`, its registration calls and
`test::report()`; every test body is a nested function `fn NAME() errors
compiler::CompilerError:` around a `static compile:` block; registration
functions group tests by concept and take run-time inputs as parameters; names
are semantic (the Tcl name when it already is, the manifest keeps the old one).

## What stays in Tcl, and why

4028 Tcl tests (55%) stay Tcl-only, each for an observational reason recorded in
its row; 1041 more keep an active internal half beside their golden test:

| reason | Tcl tests | what they observe |
|---|---|---|
| KEEP-INTERNAL | 2139 | HIR/Core IR/NIR text and facts, plans, ranges, instances, allocation and release counts, stack maps, safepoints, root maps, caches, build counts, scheduler internals, the Rust/Cranelift layers |
| KEEP-PARSER | 509 | lexer and parser output, syntax errors, header and import-placement failures, HIR text readers |
| KEEP-WARNING | 470 | every warning (kind, wording, count, location) -- warnings are not reified |
| KEEP-MULTI-PROGRAM | 582 | several programs or installations, `main.tcl` and executables, stdout, argv/environment, private generated modules, option matrices -- and 164 tests whose subject is a corpus file (CORPUS-SUBJECT, below) |
| KEEP-RUNTIME-ONLY | 119 | a failure no Botlish handler can observe ([below](#run-time-only-failures)) |
| KEEP-NOT-EXPRESSIBLE | 209 | unchecked Core IR or `-strict 0` semantics with no strict equivalent, Tcl API behavior, value display text, diagnostics anchored outside any block |

**Corpus subjects.** 164 Tcl tests exercise a program *file* of the corpus
(`examples/stdlib/*.bot`, `bench/*.bot`, the `examples/io` programs): 141
corpus-driven cases of `tests/stdlib.test` alone, plus csv/hashtable/
refined-checks programs. An entry program cannot be imported by a suite, and a
golden "port" would paste a copy of the definitions and test the copy, which
drifts from the example silently. They are KEEP-MULTI-PROGRAM, tagged
CORPUS-SUBJECT -- the census first proposed migrating them; the migration
reversed that (a tiny language-demonstration sample, such as
`examples/surface/03-closure.bot`, whose content *is* the language theorem, was
ported as before).

### Run-time-only failures

119 tests (point 81) cannot migrate solely because their theorem is a failure no
handler can observe; one in a suite would abort every test of it. By code
(RUNTIME-ONLY tags): TYPE 48, RANGE 14, ARITY 14, EQUALITY 11, UNCAUGHT-ERROR 9
(a declared error reaching the program boundary), NOT-BOOLEAN 7, NOT-CALLABLE 5,
ARITHMETIC 5, NATIVE-ONLY 4 (the Tcl backends refusing a native operation),
native stack limits 4. Where such a test also had a source-visible half it was
split (the golden half catches the declared error by name; the Tcl test keeps
the boundary behavior). This is the evidence for the later language decision
about making these failures ordinary declared errors; nothing was changed here.

### Static-boundary ownership gaps

45 tests (OUTER-ANCHOR, point 82) have a diagnostic that block code causes but
that is reported outside any block -- at a top-level declaration (a trait,
refined type, enum or struct declaration rejected as such), at the top-level
context installation, or at a module header -- so `static compile:` cannot
reify it. One is a contradiction worth fixing later: TRAIT-POLYMORPHIC-RECURSION
has a `compiler::DiagnosticCode` case (the static-compile census classifies it
recoverable), yet it is anchored at the trait-polymorphic function's top-level
declaration, so no block produces it (`traits.test`
trait-polymorphic-recursion-rejected is BLOCKED with that reproducer).

## Strength

Per ported Tcl test (its golden rows together; a test with any weaker row
counts as weaker, else any split row as split, else any stronger row as
stronger): **1244 equal, 799 stronger, 1015 split, 192 weaker**.

* **Stronger** (799): the golden test runs where the Tcl test did not (most Tcl
  tests ran one or two backends; every golden test runs four), pins a
  `DiagnosticCode` and location where the Tcl test matched a message glob,
  compares a value the Tcl test only computed, uses run-time inputs where the Tcl
  program's constants let the compiler fold the theorem away (509 rows
  DYNAMIC-INPUT), or replaces a vacuous Tcl assertion
  ([Old-test findings](#old-test-findings)).
* **Split** (1015): the source theorem is ported; the Tcl test stays active for
  what only it observes (`tcl_retained`): NIR or allocation shape, release
  counters, the full `-strict 0` diagnostic list, the program-boundary uncaught
  error, GC-stress equality, warning counts.
* **Weaker** (192 Tcl tests, 289 rows), each saying what was lost: the message
  wording is not compared while code and location are (156 rows; the README rule
  -- messages are reports, not properties -- and mostly OLD-TEST-OVERSPECIFIED);
  a rejected block reifies only its *first* diagnostic, so "exactly one
  diagnostic" or "the same diagnostic for both spellings" stays in Tcl (57); a
  location the Tcl test pinned is not (12); source cannot name `+` or `*` as a
  value, so a test of a native passed through a parameter uses `mod` (5); the
  program-boundary uncaught-error behavior (4); a value's display text or order
  (4); a `-strict 0` program whose strict form differs (3); other specific
  losses (48, each in its notes; the latest two, `af-recursive-struct`'s,
  lose its live-coroutine count, a release counter). A whole port that is weaker keeps its Tcl test
  active (`tcl_layer` ACTIVE-NOT-EXPRESSIBLE).

No source-semantic property was weakened silently: every weaker row names its
loss, and every lost property is still checked by its active Tcl test.

## Old-test findings

Porting the real theorem (helpers resolved, programs re-run strictly) turned up
Tcl tests weaker or different than they look (point 96: *old test
underspecified / overspecified / helper semantics misunderstood*). None was
changed -- the Tcl suite is not edited by this milestone -- and each is recorded
in its rows' notes:

* **Vacuous**: `struct-destructuring.test` destructure-function-result-unit-fields
  (its program spells `a / b`, which Botlish lacks: every backend reports a lexer
  error, and the `-match glob *` accepts it); destructure-reject-unproven-shape-
  message (`glob *` accepts any result, acceptance included);
  `mutable-array-type.test` mat-atk-21 (all 19 fixture programs use pre-namespace
  spellings and are rejected with NOT-AN-ENUM before the erasure they are about
  is analyzed; with current spellings 6 of them are *accepted*, correctly under
  value semantics, so the test's stated theorem no longer holds);
  `loop-collecting.test` loop-collecting-bounds-once-down-to/-through (the
  test-tick bounds make the loop run zero times, so "evaluated once, not per
  iteration" is vacuous).
* **Different from their names**: loop-collecting-reject-equal-lengths-still-
  rejected pins *accepted*; `immutable-set.test` set-result-rejected-broad is
  rejected for an undeclared type `Small`, not for the broad result its name
  claims (its loose message check hides it); destructure-error-capable-
  unhandled-same-diagnostic (both programs declare the error, so both are
  accepted); `mutable-array-type.test` mutarray-type-8 (rejected today only for
  an Int argument, not the spelling its title names).
* **Hidden by `-strict 0`**: `setcontains-equality-total.test`'s run-time tests
  declare a result type `Bool` that does not exist (strict compilation rejects
  it; the non-strict harness drops it); mutarray-sem-2 stores a String into a
  `MutableArray[int]`.
* **Overspecified**: 104 rows are OLD-TEST-OVERSPECIFIED -- mostly message
  wording pinned where the property is the rejection.

The golden ports assert the intended theorem (each marked stronger with the
reason) and the Tcl tests stay as they are.

## Compiler findings

Porting the corpus is a large, adversarial workload for the compiler: thousands
of small strict programs, each in its own `static compile:` block, each run on
four backends. Defects it exposed were fixed in their own layer, each with a Tcl
regression of the mechanism and a golden regression of the source behavior
(`tests/golden/completion-regressions.bot`, `tests/golden/recursive-types.bot`),
never by bending a port around them.

| # | defect | layer | found by | fix |
|---|---|---|---|---|
| 1 | **Precision.** A loop over an empty literal List was charged its body's errors: `each([])` and `byte::set([])` were UNHANDLED-ERROR while `each([1])` was correctly KNOWN-ERROR, contradicting STATIC-COMPLETION-PROOFS.md item 92. `LiteralListOf` answered `{}` both for "no fact" and for the empty literal. | `hir/completions.tcl` | `byte-set-empty` (lists-and-sets.bot) | a3c5a79: the literal-list fact is tagged (`{list V...}`, `{list}` the empty literal), threaded through exact calls and the size readers. Two Tcl tests that depended on the imprecision now see the correct KNOWN-ERROR (updated). |
| 2 | **Soundness.** `EvalListloop` never evaluated the loop's iterable: a call in `loop x in g(n):` that may fail was never charged, so a strict program compiled and its declared error escaped at run time uncaught (and counted/lockstep operands that never complete still let the body be charged). | `hir/completions.tcl` | the fix of #1 | be97243: `LoopDomain` walks every loop's domain (iterable, bounds, lockstep operands) in the enclosing scope first; a `never` operand makes the loop `never`. No existing program was newly rejected. |
| 3 | **Static decisions: wrong decision.** `hir::affine::verify` computes release scopes (and so AFFINE-PATH-RELEASE-UNSUPPORTED) only when the whole program has no affine diagnostic; `hir/staticdeps.tcl` did not model that channel, so the batched scheduler mispredicted -- and, when the site also had a later diagnostic, *committed a different decision than the sequential reference* (KNOWN-ERROR instead of AFFINE-PATH-RELEASE-UNSUPPORTED), recorded nowhere. | `hir/staticdeps.tcl` | mutable-vector.bot (mispredicted) | 984baec: the ownership verdict is a program-wide channel (`C:verdict`); 3 tests, 3 mutants. |
| 4 | **Static decisions: wrong program.** `Prepare` built its mentions, site expressions, region calls and function literals with `dict lappend` into flat lists read as dicts, so only the last entry per key survived: the analysis dropped edges, and a batched build could commit a capture the sequential order accepts (a different program, recorded nowhere) or mispredict. | `hir/staticdeps.tcl` | the fix of #3 | 6fe0859: every entry kept; a function value is not a shared mutable place (soundness argued in STATIC-DECISION-ECONOMICS.md, "Every mention"). Outcomes of all suites unchanged; some suites take more builds through the restored contract-boundary edges. |
| 5 | **Crash.** `hir::mutvec::ShareDescriptor` recursed without bound (TCL LIMIT STACK) on a program declaring a recursive struct type and using `MutableVector` anywhere -- which every golden suite does, through `lib/test.bot`. | `hir/mutvec.tcl` | `structs.test` struct-named-recursive-declaration | e4107e3: `ShareDescriptor` and the affine drop `Descriptor` keep the structs they are inside of (a struct met again inside itself contributes nothing; descriptors of every non-recursive type unchanged). An *affine* struct holding its own type in a container element has values nested to any depth that no finite static descriptor reaches: its declaration is now rejected (AFFINE-CONTAINER-UNSUPPORTED, naming the field path) -- before, it compiled while unused and crashed the compiler once a release was needed. **A new restriction, flagged for your decision** (STRUCTS.md, AFFINE-VALUES.md). 5 Tcl tests, `recursive-types.bot` (9). |
| 6 | **Static decisions: wrong message.** Hygiene renames a capturing binding `NAME#N`, N counted over the whole program, every static site's body included; a TYPE message printing that name differed between builds, so the batched scheduler committed `"list#2"` where the sequential reference reports `"list#1"` -- a different `CompilerError.message` value. | `hir/semantic.tcl`, `hir/range.tcl` | `se-equal-hygiene-names` (found while making TYPE messages name callables by source) | dc8bf3d: such messages print the binding's source spelling (`hir::semantic::SourceName`). Other producers that print a binding's name (USE-AFTER-MOVE, `hir::signatures::Name`) remain a documented gap (STATIC-DECISION-ECONOMICS.md); no golden suite's message names a hygiene rename. |

Static-decision **economics** findings (not wrong results): the previous
milestone established that builds scale with dependency depth, not with the
number of independent rejected blocks; the migrated corpus found four shapes
where they still scaled with the number of blocks, all fixed (17f0323, 6d22ef7;
STATIC-DECISION-ECONOMICS.md records the analysis, 17 new static-decision
mutants pin it):

| shape | example before | fix | after |
|---|---|---|---|
| **the erased-callable contract**: a rejected block that passes a callable into an untyped parameter is both an erasure site and a consumer of the program-wide contract, so such blocks were decided one per build even when the callables declare nothing | callable-contracts.bot 27 rounds / 31 builds, callables.bot 16/16, compiled-values.bot 16/16, range-and-contract-values.bot 13/13 | the contract (and what an uncontracted input may hold) is a set of errors: it depends per error on one witness contribution; a request erasing nothing is none; an argument naming a function is read by its place, not its body | 4/8, 3/3, 4/4, 4/4 |
| **nested sibling blocks**: a nested site depended on its enclosing site's form and through it on every sibling | static-compile.bot 26/33 | a site's form (`F:`) is apart from what its diagnostics read (`Z:`): an edge reading code goes to the form, which changes only by the site's own rejection | 7/14 |
| **internal ids**: a TYPE message printing an exact callable as `block(eN)` is committed only in the sequential order's own build; and a USE-AFTER-MOVE naming a binding `s1` was taken for one | callables.bot (7 rounds of such messages), affinity.bot, declared-errors.bot | those messages name the callable by source (`two/2 -> bool`); `InternalIds` recognizes only `block(eN)` and `function eN` | |
| **the trait plan's gate** (mispredictions only; decisions already equal): `hir::traits::Plan` runs only on a diagnostic-free program | traits.bot, affinity.bot (mispredicted) | a program-wide channel `C:plan` | no misprediction in any suite; traits.bot now takes 8 rounds / 13 builds (5/10 while mispredicting): its plan diagnostics are decided one per build, as the sequential order decides them (the plan is one computation over the whole program) |

Over the 85 suites the economics were first measured on: **303 rounds / 451
builds before, 206 / 322 after**; all 88 suites now take 211 rounds and 329 builds,
81 of them method-call trial builds, with no misprediction. The remaining
outliers are method-call trials (mutable-array.bot 5 rounds / 20 builds, 14 of
them trials of chained calls with several candidates; structs-and-enums.bot 4/17;
imports.bot 4/16), which a block's dependency analysis does not make cheaper.
Every suite's decisions are the sequential reference's
(`audit/static-decisions/tools/compare.tcl`: COMPARE_RESULT).

## The framework at scale

The design of GOLDEN-TEST-FRAMEWORK.md held at 20 times the sample's size
without a change of shape: no test syntax, no global registry (every suite
registers explicitly through ordinary functions; 825 registration functions),
no catch-all error (1118 explicit `on E` handlers express which declared error
a test expects -- they are the theorem, not boilerplate), no test-only native,
no layout trick (bodies are where they read best; 154 of 4293 are at a suite's
top level). Counted over all 88 suites (`audit/golden/tools/census.tcl`):

| construct | count |
|---|---|
| `test::value` registrations | 2915 |
| `test::rejects` | 688 |
| `test::rejects_at` (an absolute location of the suite file) | 289 |
| `test::rejects_message` / `test::rejects_containing` | 339 |
| `test::holds` / `test::rejects_any` | 0 / 0 |
| custom `test::case` | 28 |
| calls of suite-local registration helpers (tables, message+location, same-diagnostic) | 292 |
| test bodies (`fn NAME() errors compiler::CompilerError:`) | 4293 |
| `static compile:` blocks | 4373 |
| explicit run-time error handlers | 1118 |
| top-level declarations (struct, enum, error, refined type, trait, context struct, ...) | 527 |
| lines per registered case, declarations and comments included | 14.9 |

Per manifest row (4702): 4418 simple helper, 245 suite-local helper, 39 custom;
1458 rows need the static boundary semantically (a rejection or an escaping
error), 3244 use it by convention; 671 handle a run-time error explicitly; 421
pin a location, 837 a message, 23 related locations; 509 use run-time inputs to
defeat folding or KnownError; 1386 port a `-strict 0` Tcl program strictly. The
ceremony every test repeats -- a named body, `errors compiler::CompilerError`,
`static compile:`, a registration line -- appears 4293 times; it is the evidence
for a later general `syntactic fn` decision, and was not changed.

**Library additions.** Exactly two helpers, after evidence (point 24):
`test::rejects_message(name, code, message, body)` and
`test::rejects_containing(name, code, fragment, body)` (with `contains_text?`,
the substring scan they need) -- four suites (diagnostics, errors,
loop-collecting, mutable-vector) had written the same matcher independently.
`tests/golden-framework.test` pins every verdict of both on every backend
(gf-message-helpers), the library stays warning-clean, `perturb.tcl` alters
their codes, and all 20 framework mutants still apply and are killed.

**Recurring friction** (recorded, not solved -- point 23 asks to track it):

* **the coroutine trace driver** (39+ bodies): evaluation-order theorems the
  Tcl suite observes with its test-log/test-tick natives are ported as yielding
  probes driven by a five-to-eight-line loop. It cannot be a helper: passing the
  yielding program as a value is UNWRAPPED-YIELD, and a coroutine can only be
  constructed from a call on a binding's right-hand side;
* **message plus location** (suite-local `rejects_saying` in two suites) and
  **two outcomes compared** (`same_diagnostic`, 22 uses in destructuring.bot:
  "both spellings are rejected with the same diagnostic");
* **location-normalized messages**: three Tcl tests compare messages modulo the
  `block(eN)` ids and locations they embed (Tcl's `stripLocations`); a golden
  test cannot normalize them, so it compares codes only;
* **vectors have no `==` and no text form**: suites read a `MutableVector` out
  as a List to compare it (9 uses in mutable-vector.bot);
* **no code-point escape**: Botlish String literals hold characters literally,
  so a non-ASCII test character must be kept byte-exact; one agent's first draft
  had KELVIN SIGN (U+212A) silently NFC-normalized to ASCII `K` by the editing
  path, which would have made the test check ASCII (caught by dumping bytes);
  unicode-strings.bot's header warns about it;
* **absolute locations**: 289 `rejects_at` tests name suite-file lines; agents
  re-derived them mechanically after every edit (one wrote a token-locating
  script). Block-relative provenance would remove this.

**Oracle candidates** (point 87): the emailish-predicate tables (a reference
regex in Tcl), the elif-chain generator and the Unicode class tables compute
expectations by an independent algorithm in Tcl; they were ported as data
tables, the oracles staying in Tcl.

## Backends and exclusions

Every suite runs on interp, compile, cranelift-generic and cranelift with one
report. Ten companions exclude a backend, each with a `# golden-exclude:
BACKEND -- REASON` header line (a new, explicit mechanism of
`tests/golden/run.tcl`, printed with every run):

* **cranelift-generic** (7: `destructuring-instances`, `methods-struct-
  instances`, `opaque-instances`, `struct-representation-instances`,
  `structs-and-enums-instances`, `closure-escape-instances`,
  `compiled-values-struct-transport`): NATIVE UNSUPPORTED struct-shape -- the
  unspecialized native baseline has no slot for a projection only a semantic
  instance proves (STRUCTS.md); the specialized backend stays authoritative, as
  the Tcl harness's `GenericBaselineUndefined` does per program.
* **interp and compile** (3: `abi-bytes-native`, `abi-numeric-native`,
  `linux-io-native`): the Tcl backends refuse machine addresses and the syscall
  instruction at run time by design (pinned by their own Tcl tests); such a
  refusal would abort a suite.

The runner used to stand cranelift in for a *whole suite's* cranelift-generic
run whenever one of its programs hit the struct-shape limitation; several
migrators found that this silently removed generic coverage from entire suites
and isolated the affected tests into the companions above. The stand-in is now
reported (`run.tcl -names` prints `STANDIN`, `check.tcl` lists GENERIC
STAND-IN suites). On the final tree it
found one more, in the validation sample itself: `representation.bot`'s port of
`value-transport.test`'s vt-late-materialized-is-equal-to-eager reads fields of
untyped parameters, so none of that suite's Int, String and hashing boundary
tests had ever run on cranelift-generic. The test moved to
`compiled-values-struct-transport.bot`, beside value-transport's other
untyped-projection programs (203f017); `representation.bot` now passes on all
four backends and no suite relies on a stand-in.

## Non-vacuity

`audit/golden/tools/perturb.tcl` (new) proves every golden test can fail, two
independent ways, one compilation each:

* **invert**: the suite runs against a private copy of `lib/` whose
  `test::passed()` is a mismatch and `test::mismatch(...)` a match; every helper
  and every custom check reaching its verdict through them reports the opposite.
  Every test must FAIL; one that still passes decided its verdict without the
  library (none does).
* **alter**: each registration's expectation is altered textually -- the first
  Int literal + 1, else a String gets a `~`, else a Bool flips, else an enum
  case becomes another case of its enum; a rejection's code changes (Type <->
  Unbound); a `rejects_at` column moves. Every altered test must FAIL.

Every migration suite passed both before it was accepted, and the final tree
passes both over all 88 suites (interp; the three suites that exclude the Tcl
backends on cranelift): **invert -- 4572 of 4572 tests FAIL; alter -- 4047
tests altered, 4047 FAIL**. The 212 registrations alter cannot change
textually (computed names, `unit`/`[]` or computed expectations, suite-local
helpers, `test::case`) are covered by invert, and several migrators altered
those by hand. No test is vacuous.

## Mutation

### The cross-suite sample (points 61, 62)

`audit/golden/migration/mutant-sample.txt` lists 48 existing mutants of ten
harnesses -- every migrated subsystem that has a mutation harness: coroutines
(7), affine values (5), enums (6), error payloads (7), MutableArray (4),
MutableVector (5), static intrinsics (4), structural contracts (3), traits (4)
and context traits (3), the Tcl-runtime, front-end and native variants mixed.
`audit/golden/migration/sample.tcl` runs each through
`audit/golden/tools/check.tcl -mutants`: the Tcl files the mutant's harness
targets (old side) and the golden suites holding those files' ported rows (new
side), on the backends the mutated file can affect. A verdict is per mutant:

| verdict | meaning | mutants |
|---|---|---|
| BOTH | a ported Tcl test and its own golden test both fail | 29 |
| BOTH-SUITE-LEVEL | the Tcl side fails a ported test; the golden side fails the *suite* (compile error, abort, disagreement) rather than a named test | 16 |
| OLD-ONLY | only the Tcl side detects it | 2 |
| NEW-ONLY | only the golden side detects it | 0 |
| NEITHER | no ported test on either side detects it | 1 |

**BOTH-SUITE-LEVEL** is a detection with coarser localization, not a miss: a
mutant that breaks the runtime under a whole program (an uncatchable run-time
failure in one test aborts its suite's runner), or the compiler on a
construct every suite uses, fails the suite. Two of them say something about
the framework itself: `done-consumes` breaks `lib/test.bot`'s own runner (it
calls `coroutine::done?` and resumes), so every suite fails to compile, and
`fail-ignores-payload-tcl`/`whole-binding-loses-field-tcl` turn a missing
payload field into a run-time failure no handler can catch.

The first run of the sample found three OLD-ONLY and three NEITHER mutants. Each
was investigated as a possible migration gap; four were (ce34e1d):

* `contravariant-erasure-dropped` (OLD-ONLY): the port of
  `scc-contravariant-admitted`/`-rejected` carried only half the theorem;
  the missing half is ported, in two companions
  (`callable-contracts-contravariant.bot`, `-rejected.bot`), because what a
  structural `Fn`'s argument types erase is a program-wide fact. Now BOTH.
* `handler-dispatch-short-name-tcl` (NEITHER): the namespaced-errors tests that
  kill it (`nerr-both-handlers`, `nerr-completion-sets`/`-value`) had been
  classified multi-program; they are expressible with a stock module's error
  (`byte::AboveRange`) and are now ported. Now BOTH.
* `caller-imports-provide` (NEITHER): `ct-owner-only` was re-expressed with a
  stock context (`linux::io::LinuxIO`) instead of a private module. Now
  BOTH-SUITE-LEVEL.

The remaining three are explained, not gaps:

* `missing-provider-silent` (OLD-ONLY): the diagnostic it suppresses,
  MISSING-CONTEXT, is reported at the top-level call that needs the provider,
  outside any `static compile:` block -- a static-boundary ownership gap
  (OUTER-ANCHOR, [above](#static-boundary-ownership-gaps)).
* `failed-swap-keeps-replacement` (OLD-ONLY): a leaked replacement is visible
  only to the Tcl runtime's release counters; a release runs no Botlish code
  (COROUTINES.md, "Release at the last use"), so no program can observe it.
* `release-never` (NEITHER among ported tests): the same, for coroutines; the
  Tcl tests that kill it are KEEP-INTERNAL (release traces).

No source-semantic mutant is OLD-ONLY without that explanation (point 129).
The sample ran on the migration's tree before the static-decision economics
changes (17f0323 and later); those change how many builds a decision takes and
the wording of two TYPE messages, not any program's outcome
(`audit/static-decisions/tools/compare.tcl` and the side-by-side check agree on
the final tree).

### The harnesses (points 57 to 60)

| harness | mutants | result | why it ran |
|---|---|---|---|
| golden framework (`audit/golden/tools/mutate.tcl`) | 20 | all apply, all killed | `lib/test.bot` gained two helpers |
| static decisions (`audit/static-decisions/tools/mutate.tcl`) | 34 (17 before; 17 added with the fixes) | all apply, all killed | `hir/staticdeps.tcl`, `hir/static.tcl` |
| structural contracts (`audit/structural-contracts/tools/mutate.tcl`) | 18 | all apply, all killed | `hir/completions.tcl` |
| error payloads (`audit/error-payloads/tools/mutate.tcl`) | 44 | all apply, all killed (the 43 Tcl-backend ones, and the native `propagation-drops-payload-native` with its private rebuild) | `hir/completions.tcl` |
| static intrinsics (`audit/static-compile/tools/mutate.tcl`) | 21 | all apply, all killed | `hir/static.tcl` |
| affine values (`audit/affine/tools/mutate.tcl`) | 29 | all apply, all killed (27 Tcl, 2 native) | `hir/affine.tcl`, `hir/structs.tcl` |
| coroutines (`audit/coroutines/tools/mutate.tcl`) | 52 | all apply, all killed (42 Tcl, 10 native) | `hir/affine.tcl`; the runner is a coroutine |
| MutableVector (`audit/mutable-vector/tools/mutate.tcl`) | 45 | all apply, all killed (36 Tcl, 9 native) | `hir/mutvec.tcl` |
| MutableArray (`audit/mutable-array/tools/mutate.tcl`) | 31 | all apply, all killed (25 Tcl, 6 native) | `hir/mutvec.tcl` |
| traits (`audit/traits/tools/mutate.tcl`) | 18 | all apply, all killed | two of its mutants edit `hir/structs.tcl`/`hir/affine.tcl` text |

Each native mutant rebuilds a private copy of the native backend. Every
harness above ran on the final tree, and every mutant of every harness in
`audit/*/tools/mutants.txt` (twelve files) still applies to it.

Every compiler fix of the migration also ran its layer's fuzzers on the final
tree (several seeds, once under GC stress where the harness has the switch),
none with a disagreement: affine 3 x 30 programs, coroutines 2 x 50,
MutableVector 3 x 40 (one GC-stressed), MutableArray 3 x 40 (one GC-stressed),
static intrinsics 3 seeds (one GC-stressed), static decisions (with the
economics fixes), structural contracts and error payloads (with the completion
fixes), and the golden fuzzer 4 x 20 programs (one GC-stressed) after
`lib/test.bot` changed.

## Freeze classification

Points 65 to 69, as data for the next milestone (nothing is frozen):

| class | Tcl tests | what it would mean |
|---|---|---|
| FROZEN-DUPLICATE-ORACLE (`tcl_layer` DUPLICATED-E2E) | 2042 | the whole theorem is carried by golden tests that pass on all four backends; a candidate to run in CI only, frozen except when a disagreement reveals a bug |
| ACTIVE-TCL-INTERNAL | 5229 | stays actively maintained and keeps receiving new tests |
| of which ACTIVE-INTERNAL | 3641 | compiler/runtime internals, warnings, and the internal half of every SPLIT test |
| of which ACTIVE-NOT-EXPRESSIBLE | 1006 | parser and header behavior, run-time-only failures, outer-anchored diagnostics, unchecked/`-strict 0` semantics, and every *weaker* port's original |
| of which ACTIVE-MULTI-PROGRAM | 582 | several programs, `main.tcl`, executables, stdout/argv, private modules, corpus files |

Per subsystem (Tcl tests, share that would stay active):

| subsystem | Tcl tests | duplicated | active | active share |
|---|---|---|---|---|
| surface | 685 | 552 | 133 | 19% |
| coroutines | 56 | 40 | 16 | 29% |
| errors | 267 | 160 | 107 | 40% |
| functions | 411 | 244 | 167 | 41% |
| opaque | 107 | 61 | 46 | 43% |
| traits | 68 | 36 | 32 | 47% |
| diagnostics | 198 | 91 | 107 | 54% |
| refinements | 262 | 119 | 143 | 55% |
| abi | 175 | 76 | 99 | 57% |
| collections | 584 | 251 | 333 | 57% |
| affine | 112 | 42 | 70 | 62% |
| strings | 433 | 157 | 276 | 64% |
| static-compile | 59 | 19 | 40 | 68% |
| modules | 216 | 68 | 148 | 69% |
| contexts | 75 | 20 | 55 | 73% |
| native | 919 | 89 | 830 | 90% |
| harness | 85 | 8 | 77 | 91% |
| gc | 167 | 4 | 163 | 98% |
| hir-core-nir | 1258 | 1 | 1257 | 100% |
| parser | 496 | 2 | 494 | 100% |
| warnings | 638 | 2 | 636 | 100% |

* **Freezing would be per test, not per file**: no Tcl test file is entirely
  DUPLICATED-E2E (five are at least 80%: `ascii`, `empty-collection-
  admissibility`, `list-stdlib`, `native-uri-escape`, `typed-callable-escape`),
  and 59 files (1603 tests) have no duplicated test at all. A freeze policy needs
  a per-test mechanism (the manifest's `freeze` column is that list) or a file
  reorganization; the Tcl suite was not reorganized here.
* **Active Tcl tests that should keep receiving new coverage** (point 68): every
  ACTIVE-INTERNAL file -- the warning suites (`fixed-arity-list-return`,
  `method-eligible`, `same-failure`, `many-boolean-arguments`,
  `one-char-string-literal`, `proves-naming`, `warnings`: warnings are not
  reified), the representation and code-shape tests (`struct-scalar-replacement`,
  `value-transport`, `raw-int-abi`, `native`), the analysis-fact tests
  (`exact-value-facts`, `hir-range`, `surface-lowering`), the parser, and the
  static scheduler (`static-economics`); and the split halves of
  `mutable-array-type`, `affine`, `coroutines` and the error tests, whose release
  counters, `-strict 0` diagnostic lists and program-boundary failures only Tcl
  sees.
* **Layers represented only in Tcl** (point 69): HIR/Core IR/NIR shape and the
  analyses' facts (hir-core-nir, 100% active), the parser, every warning, the
  native runtime's memory behavior (allocation counts, stack maps, root
  liveness, GC: gc 98%, native 90%), release and drop order, the static
  scheduler's economics, and the process boundary (`main.tcl`, executables,
  argv, stdout).
