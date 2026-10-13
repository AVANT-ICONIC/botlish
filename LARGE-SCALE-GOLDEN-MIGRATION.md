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

Performance, measured on the finished corpus ([Performance](#performance)):
executing every golden test takes a tenth of a second natively; compiling the
corpus is the whole cost, and it is Tcl -- 1,518 s of front end (type
inference and semantic-instance verification half of it) and 2,165 s of the
Tcl backends' preparation, of which the quadratic Core IR lowering and the
`compile` backend's rebuild of the HIR are defects. On one backend the golden
corpus costs about three times the Tcl tests it duplicates (517 against 180 s,
four processes at a time). Studies of that cost found it algorithmic --
whole-program copies per semantic instance, quadratic lowering, redundant
walks -- and a verified prototype on a branch, not merged, halves the largest
suites' front end ([Compiler performance](#compiler-performance-what-dominates-and-what-would-remove-it)).

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

| suite | golden tests | Tcl tests | from Tcl files | lines | static sites (rejected) | rounds | builds (method trials) | front end s | interp s | compile s | cranelift-generic s | cranelift s | peak RSS MB |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| abi-bytes-native.bot | 3 | 3 | abi-bytes | 87 | 3 (0) | 1 | 1 (0) | 1.4 | excl. | excl. | 0.4 | 0.7 | 70 |
| abi-bytes.bot | 103 | 57 | abi-bytes, abi-mutable-bytes | 1098 | 103 (56) | 3 | 3 (0) | 16.3 | 21.9 | 37.5 | 1.9 | 6.4 | 302 |
| abi-numeric-native.bot | 1 | 1 | abi-numeric | 40 | 1 (0) | 1 | 1 (0) | 1.7 | excl. | excl. | 0.5 | 0.6 | 61 |
| abi-numeric.bot | 87 | 34 | abi-numeric, scalarbits | 865 | 76 (34) | 2 | 2 (0) | 9.6 | 13.9 | 21.4 | 1.5 | 5.3 | 273 |
| affinity.bot | 67 | 32 | affine | 1110 | 67 (25) | 4 | 5 (0) | 15.4 | 8.6 | 24.1 | 1.4 | 6.3 | 278 |
| bits-bytes-hashing.bot | 47 | 51 | native-bitshift, native-byte, native-csv-records, native-executable +1 | 525 | 35 (0) | 1 | 1 (0) | 3.2 | 5.4 | 12.3 | 1.2 | 3.0 | 175 |
| callable-contracts-contravariant-rejected.bot | 2 | 1 | structural-contract-completions | 57 | 1 (1) | 2 | 2 (0) | 1.9 | 0.3 | 1.6 | 0.4 | 0.5 | 61 |
| callable-contracts-contravariant.bot | 4 | 1 | structural-contract-completions | 99 | 3 (1) | 2 | 2 (0) | 2.0 | 0.5 | 1.5 | 0.4 | 0.7 | 68 |
| callable-contracts-fallback.bot | 4 | 3 | higher-order-completions | 112 | 4 (2) | 2 | 2 (0) | 2.0 | 0.3 | 1.2 | 0.4 | 0.7 | 72 |
| callable-contracts-handle.bot | 1 | 1 | structural-contract-completions | 61 | 1 (0) | 1 | 1 (0) | 1.0 | 0.5 | 1.4 | 0.4 | 0.7 | 63 |
| callable-contracts-returned.bot | 4 | 6 | higher-order-completions | 150 | 4 (3) | 2 | 2 (0) | 2.4 | 0.4 | 1.5 | 0.3 | 0.7 | 74 |
| callable-contracts-unerased.bot | 1 | 1 | structural-contract-completions | 44 | 1 (0) | 1 | 1 (0) | 1.0 | 0.3 | 1.2 | 0.3 | 0.5 | 59 |
| callable-contracts.bot | 92 | 79 | exact-callable-executable, higher-order-completions, structural-contract-completions | 1768 | 79 (40) | 4 | 8 (2) | 61.3 | 16.7 | 49.6 | 2.1 | 14.8 | 440 |
| callables.bot | 113 | 101 | closure-int-keys, exact-callable-key, structural-fn-types, typed-callable-escape | 1780 | 111 (38) | 3 | 3 (0) | 26.7 | 17.8 | 32.9 | 2.3 | 13.7 | 503 |
| closure-escape-instances.bot | 1 | 1 | native-listloop | 48 | 1 (0) | 1 | 1 (0) | 1.0 | 0.3 | 0.8 | excl. | 0.4 | 58 |
| closure-escape.bot | 49 | 47 | blockescape-called-generic, blockescape-nested-capturers, native-block-escape, native-escape +1 | 911 | 49 (0) | 1 | 1 (0) | 3.4 | 5.3 | 12.8 | 1.1 | 4.0 | 240 |
| collections.bot | 44 | 23 | enums, flags, immutable-set, list-stdlib +9 | 718 | 44 (22) | 4 | 7 (2) | 16.4 | 7.0 | 10.0 | 1.1 | 3.0 | 178 |
| compiled-values-struct-transport.bot | 18 | 17 | value-transport | 392 | 18 (0) | 1 | 1 (0) | 2.8 | 3.1 | 10.5 | excl. | 2.1 | 151 |
| compiled-values.bot | 118 | 95 | blockescape-nested-capturers, compiler-opt, direct-hir-native, dormant-instances +6 | 1698 | 114 (36) | 4 | 4 (0) | 43.5 | 62.9 | 68.1 | 2.8 | 19.2 | 630 |
| completion-regressions.bot | 23 | 11 | errors | 381 | 23 (18) | 2 | 2 (0) | 3.7 | 0.8 | 2.2 | 0.5 | 0.9 | 101 |
| contexts.bot | 88 | 49 | context-traits, contexts, linux-path | 1291 | 81 (33) | 3 | 4 (0) | 19.5 | 12.4 | 20.3 | 1.6 | 5.6 | 333 |
| core-semantics.bot | 141 | 119 | acceptance, backends, bindings, blocks +8 | 1810 | 126 (19) | 3 | 3 (0) | 14.2 | 14.9 | 31.5 | 2.1 | 9.0 | 421 |
| coroutines.bot | 62 | 47 | coroutines | 1456 | 61 (21) | 4 | 5 (0) | 20.1 | 16.1 | 37.2 | 2.0 | 6.5 | 384 |
| declared-errors-imports.bot | 10 | 2 | namespaced-errors | 133 | 10 (10) | 2 | 3 (0) | 1.9 | 1.1 | 1.4 | 0.3 | 0.6 | 76 |
| declared-errors.bot | 115 | 74 | error-payloads, errors, namespaced-errors | 1996 | 108 (46) | 3 | 7 (3) | 36.0 | 18.4 | 43.4 | 2.4 | 10.0 | 431 |
| destructuring-instances.bot | 55 | 22 | struct-destructuring | 686 | 55 (0) | 1 | 1 (0) | 2.5 | 2.1 | 6.6 | excl. | 2.1 | 177 |
| destructuring.bot | 378 | 179 | struct-destructuring | 3680 | 356 (88) | 5 | 7 (1) | 107.4 | 81.4 | 153.5 | 7.4 | 68.8 | 1567 |
| diagnostics.bot | 27 | 24 | enums, flags, hir-resolution, imports +9 | 511 | 28 (28) | 4 | 6 (1) | 7.1 | 1.7 | 3.9 | 0.6 | 1.3 | 128 |
| errors.bot | 24 | 20 | error-payloads, errors, higher-order-completions, mutable-array-type +3 | 607 | 26 (11) | 3 | 3 (0) | 4.1 | 1.7 | 5.0 | 0.7 | 1.4 | 134 |
| flags.bot | 100 | 98 | flags | 1308 | 100 (32) | 2 | 2 (0) | 7.3 | 18.2 | 39.5 | 2.0 | 8.8 | 450 |
| framework-semantics.bot | 29 | 17 | golden-framework | 611 | 26 (9) | 4 | 8 (2) | 20.0 | 4.2 | 4.4 | 0.8 | 1.9 | 139 |
| gc-sensitive-values.bot | 22 | 24 | native-alloc, native-root-liveness, native-stack-map, string-allocation | 519 | 22 (0) | 1 | 1 (0) | 2.5 | 3.4 | 4.3 | 0.6 | 1.7 | 126 |
| harness.bot | 13 | 13 | argv, calls, coroutines, hir-lowering +6 | 363 | 14 (2) | 2 | 2 (0) | 1.5 | 1.3 | 3.0 | 0.5 | 1.2 | 101 |
| hir-values.bot | 14 | 12 | hir-aot, hir-lowering, hir-resolution, hir-samples | 277 | 14 (6) | 2 | 2 (0) | 1.4 | 0.7 | 1.4 | 0.4 | 1.0 | 86 |
| imports-abi-child.bot | 17 | 10 | imports, surface-modules | 169 | 17 (9) | 3 | 3 (0) | 3.2 | 0.7 | 1.7 | 0.5 | 1.3 | 89 |
| imports-abi-family.bot | 6 | 5 | imports, surface-modules | 89 | 6 (0) | 1 | 1 (0) | 1.3 | 0.4 | 1.3 | 0.3 | 0.5 | 74 |
| imports-library-modules.bot | 12 | 11 | imports, surface-modules | 156 | 12 (5) | 3 | 3 (0) | 5.1 | 2.2 | 3.6 | 0.6 | 1.3 | 121 |
| imports-unimported.bot | 16 | 6 | imports | 136 | 14 (12) | 2 | 2 (0) | 1.9 | 1.0 | 1.4 | 0.5 | 0.8 | 79 |
| imports.bot | 59 | 36 | imports, surface-modules | 524 | 58 (10) | 4 | 16 (11) | 42.5 | 5.9 | 10.8 | 0.9 | 2.6 | 181 |
| linux-io-native.bot | 5 | 4 | linux-syscall | 121 | 5 (0) | 1 | 1 (0) | 1.6 | excl. | excl. | 0.4 | 0.6 | 68 |
| linux-io.bot | 55 | 26 | argv, linux-syscall | 501 | 47 (29) | 3 | 3 (0) | 8.5 | 3.9 | 8.8 | 0.8 | 2.0 | 137 |
| lists-and-sets.bot | 86 | 89 | byte-set, immutable-set, list-stdlib, lists +2 | 778 | 72 (11) | 3 | 3 (0) | 7.1 | 6.9 | 13.9 | 1.2 | 2.9 | 221 |
| loop-collecting-refined-checks.bot | 1 | 1 | raw-count-loops | 50 | 1 (0) | 1 | 1 (0) | 1.8 | 15.0 | 3.5 | 0.6 | 1.0 | 100 |
| loop-collecting.bot | 110 | 110 | loop-collecting, raw-count-loops | 1366 | 106 (8) | 3 | 3 (0) | 11.8 | 12.6 | 26.9 | 1.8 | 10.0 | 393 |
| loops.bot | 55 | 72 | loop-counted, loop-in, loops | 783 | 55 (7) | 2 | 2 (0) | 3.5 | 3.9 | 9.7 | 0.9 | 3.2 | 184 |
| method-equivalence-imported.bot | 13 | 9 | method-eligible | 199 | 11 (4) | 3 | 5 (1) | 7.1 | 3.1 | 5.4 | 0.6 | 1.2 | 112 |
| method-equivalence.bot | 45 | 36 | method-eligible | 584 | 42 (6) | 3 | 3 (0) | 5.8 | 3.4 | 5.6 | 0.9 | 2.5 | 169 |
| methods-byte-without-list.bot | 3 | 2 | method-sugar | 54 | 3 (3) | 2 | 2 (0) | 1.9 | 1.0 | 1.2 | 0.4 | 0.6 | 68 |
| methods-list-without-str.bot | 3 | 2 | method-sugar | 47 | 3 (3) | 2 | 2 (0) | 1.6 | 1.0 | 1.2 | 0.3 | 0.5 | 65 |
| methods-struct-instances.bot | 8 | 5 | method-sugar | 109 | 8 (0) | 1 | 1 (0) | 1.2 | 0.3 | 1.4 | excl. | 0.7 | 69 |
| methods-type-import-only.bot | 1 | 1 | method-sugar | 29 | 1 (1) | 2 | 2 (0) | 1.5 | 0.6 | 1.3 | 0.4 | 0.6 | 62 |
| methods.bot | 195 | 104 | method-sugar | 1819 | 198 (22) | 4 | 6 (1) | 64.3 | 27.4 | 53.0 | 3.1 | 16.2 | 615 |
| modules.bot | 31 | 12 | context-traits, contexts, imports, namespaced-errors +5 | 572 | 33 (26) | 3 | 4 (0) | 9.7 | 4.1 | 10.0 | 0.7 | 2.0 | 205 |
| mutable-array.bot | 233 | 115 | mutable-array, mutable-array-type, mutarray-construction | 2930 | 233 (91) | 5 | 20 (14) | 351.9 | 59.3 | 124.5 | 4.3 | 32.6 | 866 |
| mutable-vector-str.bot | 1 | 1 | mutable-vector | 44 | 1 (0) | 1 | 1 (0) | 0.9 | 0.3 | 0.9 | 0.2 | 0.4 | 60 |
| mutable-vector.bot | 74 | 41 | mutable-vector | 1206 | 70 (26) | 4 | 13 (7) | 41.6 | 13.1 | 30.5 | 1.5 | 5.0 | 287 |
| names-and-scoping.bot | 58 | 61 | hir-syntax, strict-references, surface-lowering | 861 | 58 (35) | 2 | 2 (0) | 2.6 | 2.3 | 5.6 | 0.7 | 2.0 | 146 |
| native-aggregates.bot | 70 | 69 | native-mutarray, native-param-aggregate, native-refinement-propagation, native-tiny-leaf-inline | 1223 | 57 (0) | 1 | 1 (0) | 5.6 | 13.4 | 25.9 | 1.7 | 5.1 | 323 |
| native-values.bot | 89 | 62 | backends, native, native-bitwise-fold | 1102 | 79 (0) | 1 | 1 (0) | 4.4 | 12.1 | 17.2 | 1.3 | 4.3 | 267 |
| opaque-instances.bot | 1 | 1 | opaque-struct | 37 | 1 (0) | 1 | 1 (0) | 1.1 | 0.3 | 1.1 | excl. | 0.4 | 61 |
| opaque.bot | 91 | 73 | opaque-struct | 1124 | 91 (62) | 6 | 10 (2) | 49.3 | 21.2 | 22.0 | 1.5 | 5.5 | 305 |
| ownership.bot | 38 | 13 | affine, coroutines, mutable-array, mutable-vector | 700 | 38 (24) | 3 | 10 (5) | 21.7 | 4.9 | 9.3 | 1.3 | 2.9 | 177 |
| range-and-contract-values.bot | 78 | 68 | checked-domain-proof-provenance, closed-closure-entry-facts, conjunctive-entry-facts, exact-value-facts +5 | 1149 | 76 (25) | 4 | 4 (0) | 24.8 | 30.1 | 22.5 | 1.7 | 5.9 | 328 |
| raw-int-abi.bot | 52 | 50 | raw-int-abi, raw-internal-abi | 951 | 52 (0) | 1 | 1 (0) | 3.4 | 17.7 | 13.2 | 1.3 | 3.9 | 216 |
| recursive-types.bot | 9 | 4 | affine, mutable-vector, structs | 261 | 9 (0) | 1 | 3 (1) | 2.4 | 0.4 | 2.0 | 0.5 | 0.8 | 80 |
| refinements.bot | 66 | 52 | refined, refined-signatures, refinement-values | 1036 | 66 (29) | 3 | 10 (5) | 46.1 | 10.1 | 13.0 | 1.1 | 3.2 | 240 |
| representation.bot | 13 | 11 | abi-numeric, enums, loop-counted, native +6 | 332 | 13 (1) | 2 | 2 (0) | 3.0 | 0.9 | 3.4 | 0.6 | 1.1 | 106 |
| static-compile-erased-consumer.bot | 2 | 1 | static-economics | 59 | 2 (1) | 2 | 2 (0) | 1.7 | 0.3 | 1.1 | 0.3 | 0.6 | 66 |
| static-compile.bot | 81 | 58 | static-compile, static-economics | 1452 | 158 (84) | 7 | 14 (4) | 70.9 | 16.0 | 33.4 | 1.7 | 8.6 | 384 |
| stdlib-namespaces-entry-members.bot | 4 | 2 | stdlib-namespaces | 64 | 4 (0) | 1 | 1 (0) | 0.9 | 0.3 | 1.2 | 0.3 | 0.6 | 62 |
| stdlib-namespaces-str-only.bot | 1 | 1 | stdlib-namespaces | 25 | 1 (1) | 2 | 2 (0) | 1.5 | 0.2 | 0.9 | 0.3 | 0.3 | 58 |
| stdlib-namespaces-unimported.bot | 2 | 1 | stdlib-namespaces | 32 | 2 (2) | 2 | 2 (0) | 1.6 | 0.3 | 1.0 | 0.3 | 0.4 | 61 |
| stdlib-namespaces.bot | 114 | 49 | module-static-values, stdlib-namespaces | 1065 | 110 (46) | 3 | 9 (5) | 54.9 | 17.4 | 34.9 | 1.8 | 7.7 | 360 |
| string-natives.bot | 82 | 81 | native-string-region, native-string-traversal, native-string-view, native-uri-escape | 1077 | 45 (0) | 1 | 1 (0) | 5.6 | 9.9 | 22.9 | 1.5 | 5.5 | 294 |
| string-representations.bot | 48 | 50 | packed-ascii, short-string | 900 | 48 (0) | 1 | 1 (0) | 4.1 | 5.8 | 13.7 | 1.0 | 2.8 | 203 |
| strings.bot | 94 | 102 | ascii, emailish-predicate, native-tcl-unicode, str-char-at +2 | 932 | 67 (17) | 2 | 2 (0) | 8.7 | 14.0 | 21.4 | 1.5 | 4.9 | 276 |
| struct-representation-instances.bot | 15 | 14 | struct-scalar-replacement | 240 | 15 (0) | 1 | 1 (0) | 1.7 | 0.7 | 1.9 | excl. | 0.8 | 87 |
| struct-representation.bot | 110 | 98 | struct-scalar-replacement, virtual-construction | 1732 | 107 (0) | 1 | 1 (0) | 9.6 | 27.8 | 58.9 | 2.5 | 12.7 | 538 |
| structs-and-enums-instances.bot | 4 | 4 | structs | 84 | 4 (0) | 1 | 1 (0) | 1.1 | 0.3 | 1.0 | excl. | 0.5 | 65 |
| structs-and-enums-qualifiers.bot | 2 | 1 | enums | 49 | 2 (2) | 1 | 1 (0) | 1.0 | 0.3 | 1.3 | 0.3 | 0.4 | 61 |
| structs-and-enums.bot | 111 | 77 | enums, structs | 1335 | 111 (45) | 4 | 17 (11) | 60.6 | 10.9 | 19.4 | 1.5 | 5.2 | 298 |
| traits-path.bot | 2 | 2 | traits | 73 | 2 (0) | 1 | 2 (0) | 1.5 | 0.3 | 1.2 | 0.3 | 0.5 | 74 |
| traits.bot | 67 | 43 | traits | 1024 | 79 (38) | 8 | 13 (3) | 45.3 | 10.6 | 14.4 | 1.4 | 4.5 | 247 |
| types.bot | 96 | 93 | applied-types, empty-collection-admissibility, source-types, symbolic-type-identity +1 | 1269 | 94 (34) | 3 | 3 (0) | 14.6 | 10.3 | 19.5 | 1.5 | 6.2 | 290 |
| unicode-strings.bot | 56 | 56 | native-tcl-unicode | 190 | 5 (0) | 1 | 1 (0) | 1.9 | 1.4 | 4.3 | 0.5 | 1.0 | 94 |
| validators-and-proofs.bot | 153 | 54 | proof-loop-intervals, proven-bounds, refinement-validators | 1748 | 153 (76) | 3 | 4 (0) | 18.3 | 17.6 | 34.4 | 2.0 | 7.0 | 440 |
| values.bot | 32 | 36 | blocks, calls, control, elif +8 | 1005 | 26 (0) | 1 | 1 (0) | 4.3 | 5.4 | 14.9 | 1.1 | 3.0 | 280 |
| warning-programs.bot | 42 | 37 | fixed-arity-list-return, many-boolean-arguments, one-char-string-literal, proves-naming +1 | 623 | 42 (14) | 3 | 4 (0) | 6.2 | 1.1 | 4.5 | 0.7 | 1.7 | 148 |
| total (88 suites) | 4572 | 3287 | | 63212 | 4378 (1390) | 211 | 329 (81) | 1518.4 | 774.0 | 1404.0 | 93.5 | 402.6 | |

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
(`audit/static-decisions/tools/compare.tcl tests/golden/*.bot` on the final
tree: all 88 suites agree -- every site's outcome and reified diagnostic, the
program's diagnostics and the decided HIR -- with no misprediction). The
reference order is what batching saves: sequentially the corpus takes 1082
rounds and 3850 builds, 35,857 s of front end (mutable-array.bot alone 1089
builds, 17,777 s), against 211 rounds, 329 builds and 1,347 s batched -- about
27 times the time (both measured under the same, contended load).

**Found, not fixed: compilation isolation** (the compile-once study below,
verified by experiment). `hir::BuildOnce` fills about eleven process-wide
registries -- structs, enums, error payloads, traits, imports, and
`core::type`/`core::native` for source types -- that the backends read instead
of the HIR's own declarations. Compiling another program before running an
earlier HIR changes or breaks that run: the Tcl backends used the later
program's `type Small` domain, and specialized native lowering emitted
`unreachable` in place of the result (a run-time trap, no lowering error).
Declarations also leak forward: `hir::errordecls::apply` keeps the previous
program's errors when a program declares none, so a program using an
undeclared error compiles after another program declared it. The golden
runner runs each suite right after compiling it, and every suite also passes
alone in its own process (`check.tcl`), so no golden result depends on the
leak; Tcl tests that compile several programs per process could pass for the
wrong reason. It is not a migration blocker and is not fixed here
([Recommendations](#recommendations), 2).

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
was investigated as a possible migration gap; three were (ce34e1d):

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

## Performance

Measured on the session's 4-core machine, otherwise idle, in fresh processes
(`audit/golden/migration/out/`: `bench-golden-suites-cold.md`,
`bench-golden-workflows-*.txt`, `bench-golden-suites-warm.md`,
`bench-golden-framework-compile.md`, `quiet-pipeline.log`). Earlier runs made
while other work shared the machine (the side-by-side shards) are quoted only
for ratios.

### Where a suite's time goes

`bench/golden-suites.tcl`, each suite in a fresh process, one at a time,
compiled once and run on all four backends; totals over the 88 suites:

| step | seconds | share |
|---|---|---|
| front end (`surface::readProgramFile`: parsing, lowering, the static decisions, every build's analyses) | 1,518 | 32% |
| interp: HIR to Core IR lowering (`hir::lower`) | 583 | 12% |
| interp: the reference interpreter's run of every test | 191 | 4% |
| compile: the Tcl compiler's code generation (including its rebuild of HIR from the Core IR, below) | 1,099 | 23% |
| compile: the compiled run | 305 | 6% |
| cranelift: NIR lowering (Tcl, including the specialization analyses) | 396 | 8% |
| cranelift: Cranelift code generation | 6.6 | 0.1% |
| cranelift: native execution of every test | 0.09 | 0.002% |
| cranelift-generic: NIR lowering / code generation / execution | 87 / 6.1 / 0.1 | 2% |
| other (process start-up, freeing, the profiler, measurement) | about 600 | 13% |
| **total**, one process per suite, sequentially | **4,790** | |

* **Executing the tests costs nothing; compiling them is everything, and it
  is Tcl.** All 4572 tests run natively in a tenth of a second and Cranelift
  generates their code in 13 s; the front end, the Core IR lowering, the Tcl
  compiler and the NIR lowering -- all Tcl -- are 3,683 of the 4,790 s.
* **The backends' Tcl preparation costs more than the front end** (2,165 s
  against 1,518 s), and two of its largest items are algorithmic defects the
  milestone's compiler studies found ([Compiler performance](#compiler-performance-what-dominates-and-what-would-remove-it)):
  `hir::lower` is quadratic, and the `compile` backend as the golden runner
  and the Tcl harness use it rebuilds the HIR from the Core IR and re-lowers it
  per block.
* Per suite the front end takes 0.9 to 352 s (median 4.1 s; 0.33 s per golden
  test); the five largest suites hold 43% of it (mutable-array.bot 352 s,
  destructuring.bot 107, static-compile.bot 71, methods.bot 64,
  callable-contracts.bot 61). Peak memory per suite: median 149 MB, at most
  1,567 MB (destructuring.bot).

The front end by phase (self time; a phase's self time includes the
unprofiled helpers it calls -- `signatures` includes the whole-program typing
walk and the semantic-instance walks it drives):

| phase | seconds | share |
|---|---|---|
| signatures (type inference) | 575.7 | 38.2% |
| semantic-instances (instance verification) | 189.6 | 12.6% |
| hygiene | 168.7 | 11.2% |
| errorsets (completion analysis) | 116.3 | 7.7% |
| static-decisions (decision logic and per-build elaboration) | 96.5 | 6.4% |
| affine | 62.7 | 4.2% |
| static-deps | 46.9 | 3.1% |
| parse | 46.1 | 3.1% |
| resolve | 41.8 | 2.8% |
| every other phase | under 2% each | |

### The two layers as a developer runs them

`bench/golden-workflows.tcl`: the Tcl tests the manifest ports (138 files,
3250 tests -- `-match` runs exactly those; "whole" runs every test of those
files) on the interp pass, and the golden corpus (one process per suite:
compile once, run), one process at a time and four at a time:

| run | sequential | 4 at a time | longest item |
|---|---|---|---|
| Tcl E2E subset (`-match`) | **653 s** | **180 s** | golden-framework.test, 57 s |
| the same 138 Tcl files, whole | 2,054 s | 558 s | native-csv-records.test, 213 s |
| golden corpus on interp | 2,041 s | 517 s | mutable-array.bot, 358 s |
| golden corpus on cranelift | -- | 531 s | mutable-array.bot, 351 s |
| golden corpus on all four backends | 4,790 s (above) | 1,188 s | mutable-array.bot, 562 s |

* Golden on one backend costs about three times the Tcl subset it duplicates
  (2,041 / 653 s sequentially, 517 / 180 s in parallel; 0.45 against 0.20 s
  per test); on all four backends 6.6 times in parallel -- the validation
  sample's ratio (161 against 23.5 s) held at scale.
* Parallelism helps both layers almost linearly, but the golden corpus has a
  floor: mutable-array.bot alone is 60-70% of a parallel one-backend run.
  Splitting the largest suites would lower it; the compiler fixes below
  would lower everything.
* Of the backends, specialized cranelift is the cheapest single one after the
  front end (NIR lowering 396 s against Core IR lowering plus interpretation,
  774 s); interp is the reference semantics.

### Targeted edits

The golden suites and the Tcl files that cover one edited area, run whole,
one at a time (`bench-golden-workflows-wf-scen.txt`):

| edited area | golden (backend) | seconds | Tcl files | seconds |
|---|---|---|---|---|
| `hir/affine.tcl` | affinity, ownership, coroutines, mutable-vector (interp) | 137 | affine, coroutines, mutable-vector | 50 |
| `hir/completions.tcl` | declared-errors, errors, callable-contracts, completion-regressions (interp) | 134 | errors, error-payloads, higher-order-completions, structural-contract-completions | 38 |
| `core/evaluator.tcl` | core-semantics, values, loops, loop-collecting (interp) | 68 | 9 files (calls, control, loops, ...) | 45 |
| `native/lower.tcl` | native-values, string-natives, native-aggregates, representation (cranelift) | 33 | native, native-mutarray, native-string-region, native-uri-escape, native-param-aggregate | 85 |

For an edit of a front-end analysis the Tcl files are 1.5-3.5 times faster;
for an edit of the native lowering the golden suites are 2.6 times faster
(one whole-program NIR lowering per suite against many small compilations).

### Warm runs

`bench/golden-suites.tcl -warm 2`, the front ends of all 88 suites twice in
one process: **pass 1 2,055 s, pass 2 2,440 s** (peak 640 MB), against 1,518 s
cold. A long-lived compiler process gets slower, not faster: 35% on the first
pass, 19% more on the second, the abi suites most (abi-bytes.bot 13.7 then
25.3 s). The per-process library parse cache saves little (parsing is 3%),
and compilations leave state behind in process-wide registries (the
isolation defect in [Compiler findings](#compiler-findings) -- consistent
with, not proven to be, the slowdown's cause). Today one fresh process per
suite is fastest. The Tcl suite has no warm mode (one tclsh per file).

### Suite size

`bench/golden-framework.tcl -parts compile`, synthetic suites of K distinct
cases, each its own body and static block:

| K | plain functions, no framework | all passing (builds) | a third rejected with TYPE (builds) |
|---|---|---|---|
| 50 | 0.18 s | 1.45 s (1) | 3.11 s (2) |
| 100 | 0.39 s | 2.30 s (1) | 4.43 s (2) |
| 250 | 1.11 s | 5.36 s (1) | 9.51 s (2) |
| 500 | 2.49 s | 10.38 s (1) | 21.30 s (2) |
| 1000 | 6.69 s | 22.88 s (1) | 47.43 s (2) |

The library alone compiles in 0.85 s. A case costs about 23 ms in an
all-passing suite and about 47 ms in one where a third of the cases are
rejected (two builds); the growth per doubling at the top (x2.2, plain
functions x2.7) is the per-build analyses' slightly super-linear scaling, not
the framework's. Top-level bodies cost what nested ones do, and the batched
decisions stay at two builds whatever K is. The real suites cost more per
test (median about 0.1 s) because their bodies are real programs: semantic
instances, rejected blocks over several rounds, method-call trials
(mutable-array.bot, 1.5 s per test).

### Harness overheads

* **Tcl harness.** One tclsh per file costs about 0.05 s to start and load
  the compiler: about 7 s of the subset's 653 s. Running whole files instead
  of the ported tests triples the time (2,054 s): the duplicated tests sit in
  files with many internal ones.
* **Golden harness.** Every suite compiles `lib/test.bot` with it (0.85 s
  alone, about 75 s over the corpus) and re-analyzes its 1,450 HIR
  expressions in every build (83% of a small suite's HIR, 0.5 s a build);
  the framework's execution -- registration, the coroutine runner, the report
  -- is microseconds natively (GOLDEN-TEST-FRAMEWORK.md).
* **The differential tool** (`check.tcl`) adds nothing measurable beyond the
  runs it starts; its three shards took 1,147 to 2,163 s each one job at a
  time (with other work on the machine).

### Ahead-of-time executables (indicative)

An AOT-compiled suite runs in milliseconds but does not help: its build
(object emission and linking against the runtime) took 3-4 times the JIT
path's lowering, code generation and run on four suites (representation.bot
4.6 against 1.1 s, string-natives.bot 19.4 against 6.1 s), the front end is
unchanged, and 5 of 9 suites tried are not AOT-ready -- untyped test programs
need runtime-guarded instances, from which AOT never falls back.

### Compiler performance: what dominates and what would remove it

Three studies of the compiler's cost on this workload (independent
investigations, each checked by an adversarial verifier; prototypes on
branches, not merged -- the milestone does not optimize the compiler, point
121):

1. **The semantic-instance layer copies the whole HIR per instance walk and
   per instance view** (O(instances x program)). Branch
   `ccr-7eabe55c-semantic-in-place-views` walks and views in place with
   region save/restore: the final HIR is byte-identical on the whole corpus
   (88 suites, the examples, bench and lib, under a check mode), the golden
   reports are identical on all four backends; callables.bot's front end
   28.6 -> 14.5 s, traits.bot 48.7 -> 34.7 s, collections.bot 16.1 -> 13.3 s;
   on synthetic programs with four instances per function the growth
   exponent fell from 2.04 to 1.08. (`ccr-7eabe55c-semantic-in-place` is the
   walk alone: signatures -57% over the 12 largest suites, front end -19%.)
   Its staged plan (OPPORTUNISTIC-SEMANTIC-INSTANCES.md on that branch) names
   the rest: indexes for the O(used x calls) scans, the native specializer's
   own per-instance copies.
2. **Every named function body is walked at least twice**, nested ones 2^depth
   times. A guarded one-walk fix (measured in memory): callables.bot
   signatures 10.4 -> 7.5 s alone, 4.1 -> 2.1 s on top of 1.
3. **`hir::lower` is quadratic**: it walks every expression
   (`hir::affine::temporaries`) per call node -- 0.29 of 0.30 s of lowering on
   traits-path.bot, 583 s corpus-wide.
4. **The `compile` backend rebuilds HIR from Core IR** (a whole BuildOnce and
   `hir::check`, 31-61% of a small suite's own front end) and re-enters the
   quadratic lowering per block; the opt-in `compile-hir` path skips the
   rebuild.
5. **Hygiene rescans every binding and expression per rename**: 11% of the
   front end corpus-wide.
6. Smaller: `hir::contexts::Walk` rebuilds the same parent maps about ten
   times per build; the second signature round re-types the whole program to
   confirm unchanged seeds; a whole second `hir::check` after a demoted
   trusted contract (about 21% of callables.bot after fixes 1-2); the
   library modules are re-analyzed in every one of the 329 builds; 81 builds
   are method-call trials.

Each is algorithmic: it would make a reimplementation in any language as
slow; most of them are days of work in Tcl, not weeks (the plans give the
effort).
Tcl's own constant factor (about 0.65 us per field read, 40 us per
expression per walk) is what a compiled implementation would remove on top.

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

## Report

The milestone's 75 report points, in order (section links hold the detail).

1. **Starting Tcl test count.** 7250 tests ran and passed on the starting tree
   (one verbose run per file; a static count of `test` invocations is 6107).
2. **Starting golden test count.** 223 golden tests in 8 suites (the validation
   sample, 134 Tcl tests ported).
3. **Tcl tests examined.** All 7280 that run on the final tree (the 7250 and the
   30 regression tests of the migration's compiler fixes): one census row each,
   no "not examined" remainder ([The census](#the-census)).
4. **Source-observable.** 3252.
5. **Migrated.** 3250: 2209 whole (MIGRATED) and 1041 whose source theorem is
   ported while the Tcl test keeps an internal one (SPLIT).
6. **Golden tests produced.** 4349 new, 4572 in all, 4702 (Tcl test, golden
   test) pairs.
7. **Split into multiple golden cases.** 830 Tcl tests became several golden
   tests; 120 golden tests stand for several Tcl tests.
8. **Tcl-only internal.** 2139 KEEP-INTERNAL (and 470 KEEP-WARNING); 3650 Tcl
   tests are ACTIVE-INTERNAL counting the internal halves of SPLIT tests.
9. **Not expressible.** 209 KEEP-NOT-EXPRESSIBLE (unchecked Core IR or `-strict
   0` semantics without a strict equivalent, Tcl API behavior, display text, 45
   outer-anchored diagnostics among them -- [Static-boundary ownership
   gaps](#static-boundary-ownership-gaps)).
10. **Runtime-only.** 119 ([Run-time-only failures](#run-time-only-failures):
    TYPE 48, RANGE 14, ARITY 14, EQUALITY 11, UNCAUGHT-ERROR 9, NOT-BOOLEAN 8,
    NOT-CALLABLE 5, ARITHMETIC 5, NATIVE-ONLY 4, native stack limits 4).
11. **Parser/header-only.** 509.
12. **Multi-program.** 582 (164 of them CORPUS-SUBJECT: a corpus file is the
    subject).
13. **Temporarily blocked.** 2 (BLOCKED-GENERAL-COMPILER), none blocked by the
    test library.
14. **Blockers with reproducers.** `native.test` native-call-3: a tail-recursive
    `count(100000)` exceeds the Tcl interpreter's evaluation depth (TCL LIMIT
    STACK on interp), and the theorem *is* the depth, so no smaller port keeps
    it. `traits.test` trait-polymorphic-recursion-rejected: TRAIT-POLYMORPHIC-
    RECURSION has a `compiler::DiagnosticCode` case (the static-compile census
    calls it recoverable) but is reported at the trait-polymorphic function's
    top-level declaration, so no `static compile:` block can produce it (the
    manifest row holds the reproducer).
15. **Equal in strength.** 1244 Tcl tests.
16. **Botlish stronger.** 799 ([Strength](#strength)).
17. **Botlish weaker.** 192 Tcl tests (289 rows), each naming its loss, each loss
    still checked by its active Tcl test.
18. **Split-observation cases.** 1015 Tcl tests (1298 rows).
19. **Old-test overspecification.** 103 rows (85 Tcl tests) OLD-TEST-
    OVERSPECIFIED, mostly message wording pinned where the property is the
    rejection.
20. **Old-test underspecification.** 23 Tcl tests recorded in their notes:
    vacuous (`destructure-function-result-unit-fields`,
    `destructure-reject-unproven-shape-message`, `destructure-syntax-unclosed`,
    `mat-atk-21`, the two `loop-collecting-bounds-once-*`), different from their
    names or titles (`loop-collecting-reject-equal-lengths-still-rejected`,
    `set-result-rejected-broad`, `destructure-error-capable-unhandled-same-
    diagnostic`, `mutarray-type-8`, `struct-immutable-set-of-structs`, ...),
    hidden by `-strict 0` (`setcontains-equality-total`, `mutarray-sem-2`)
    ([Old-test findings](#old-test-findings)). None was edited.
21. **Compiler bugs found.** Six, all fixed with Tcl and golden regressions
    ([Compiler findings](#compiler-findings)): two completion-analysis
    (precision; soundness: a loop's iterable was never charged), three static
    decisions (a wrong batched decision; dropped dependency edges that could
    build a different program; batched/sequential messages differing through
    hygiene renames), one front-end crash (recursive structs). Plus the
    static-decision economics regressions, fixed.
22. **Runtime bugs found.** None: every suite passes on both native backends
    under GC stress, and no golden/Tcl disagreement traced to a runtime.
23. **Framework bugs found.** None in `lib/test.bot`. In the harness: the
    runner's whole-suite generic stand-in silently removed cranelift-generic
    coverage (now reported, and the last suite relying on it repaired;
    [Backends and exclusions](#backends-and-exclusions)). The mutant
    `done-consumes` shows the runner depends on `coroutine::done?` (by design).
24. **Simple-helper usage.** `test::value` 2915, `test::rejects` 688,
    `test::rejects_at` 289, `test::rejects_message`/`_containing` 339,
    `test::holds` 0, `test::rejects_any` 0 registrations; 4418 manifest rows use
    a library helper.
25. **Custom matcher usage.** 28 `test::case` registrations (39 rows).
26. **Suite-local matcher usage.** 292 calls of suite-local registration helpers
    (245 rows).
27. **Explicit runtime-handler count.** 1118 `on E` handlers in test bodies; 671
    rows handle a run-time declared error explicitly.
28. **Static-boundary count.** 4373 `static compile:` blocks (4293 test bodies);
    1458 rows need the boundary semantically, 3244 use it by convention.
29. **Exact-location count.** 289 `rejects_at` registrations; 421 rows pin a
    location.
30. **Message-matching count.** 339 message registrations; 837 rows compare a
    message or a fragment of one.
31. **Related-location matching.** 23 rows.
32. **Dynamic inputs to defeat folding.** 509 rows.
33. **Strict/non-strict differences.** 1386 rows port a `-strict 0` Tcl program
    strictly (2083 Tcl tests are tagged STRICT0); 3 weaker rows lose a
    non-strict-only behavior; two old tests are hidden by `-strict 0`.
34. **Suite count.** 88 (8 sample, 45 migration, 2 regression, 33 companions).
35. **Tests per suite.** 1 to 378, median 40, mean 52; 26 suites under 10 tests
    (mostly companions), 24 with 10-49, 24 with 50-99, 12 with 100-199, 2 over 200
    (`destructuring.bot` 378, `mutable-array.bot` 233).
36. **LOC per suite.** 25 to 3680, median 578; 63,300 lines in all, 14.9 per
    registered case.
37. **Static sites per suite.** 1 to 356 (`destructuring.bot`), 4373 in all
    ([the suite table](#the-golden-corpus)).
38. **Compile time per suite.** Front end 0.9 to 352 s per suite, median 4.1 s (the suite table, [Performance](#performance)).
39. **Peak memory per suite.** Median 149 MB, at most 1,567 MB (destructuring.bot); 640 MB for all 88 front ends in one process.
40. **Static rounds/builds per suite.** In the suite table; the outliers are
    method-call trials (`mutable-array.bot` 5/20, `structs-and-enums.bot` 4/17,
    `imports.bot` 4/16) and the trait plan (`traits.bot` 8/13).
41. **Total golden static rounds/builds.** 211 rounds, 329 builds (81 method-call
    trials), no misprediction (206/322 over the 85 suites measured before the
    economics fixes, which took 303/451).
42. **Total golden compile time.** 1,518 s of front end over the 88 suites (cold, one at a time); with every backend's preparation, 3,683 s of compilation.
43. **Backend execution times.** Executing every test: interp 191 s, the Tcl compiler's code 305 s, cranelift 0.09 s, cranelift-generic 0.1 s.
44. **Tcl compiler codegen time.** 1,099 s, including the `compile` backend's rebuild of HIR from Core IR.
45. **NIR lowering time.** 396 s specialized, 87 s generic (Tcl).
46. **Cranelift codegen time.** 6.6 s specialized, 6.1 s generic.
47. **Native execution time.** 0.09 s and 0.1 s for all 4572 tests.
48. **Tcl interpreter execution time.** 191 s (after 583 s of Core IR lowering).
49. **Cold full golden wall time.** One process per suite: 2,041 s on interp, 4,790 s on all four backends, sequentially; 517 s (interp), 531 s (cranelift) and 1,188 s (all four) four at a time.
50. **Warm full golden wall time.** All 88 front ends in one process: 2,055 s, then 2,440 s on a second pass -- slower than cold (1,518 s); no warm advantage today.
51. **Cold relevant Tcl E2E wall time.** The 3250 ported Tcl tests (`-match`): 653 s sequentially, 180 s four at a time; their 138 files whole: 2,054 s and 558 s.
52. **Warm/relevant Tcl results.** The Tcl suite has no warm mode (one tclsh per file); the full suite took 3,070 s (interp pass) and 3,315 s (compile pass) of per-file time, two files at a time on a shared machine.
53. **Targeted-subsystem workflows.** Four scenarios: for edits of `hir/affine.tcl`, `hir/completions.tcl`, `core/evaluator.tcl` the covering Tcl files are 1.5-3.5 times faster (50/38/45 s against 137/134/68 s); for `native/lower.tcl` the golden suites are 2.6 times faster (33 against 85 s).
54. **Backend exclusions.** 10 companions: 7 exclude cranelift-generic (NATIVE
    UNSUPPORTED struct-shape), 3 exclude interp and compile (machine addresses
    and the syscall instruction); no suite relies on a generic stand-in.
55. **Native coverage.** `tests/native-coverage.tcl`: 7280 tests -- 2955 native,
    4196 independent, 69 passed-partial, 60 unsupported, 0 failed (before: 7250 --
    2946, 4175, 69, 60, 0): nothing moved to an unsupported path. Every golden
    suite runs natively in CI's golden shards (two native backends each).
56. **GC stress.** All 88 suites on cranelift-generic and cranelift under
    `BOTLISH_NATIVE_GC_STRESS=1`, every test passing (86 at the migration's
    checkpoint, the four suites changed since on the final tree); the
    MutableVector, MutableArray, static-intrinsic and golden fuzzers each had a
    GC-stressed seed.
57. **Framework mutants.** 20 of 20 apply and are killed.
58. **Static-decision mutants.** 34 of 34 (17 new) killed.
59. **Structural-contract mutants.** 18 of 18 killed.
60. **Coroutine mutants.** 52 of 52 (42 Tcl, 10 native) apply and are killed; the affine (29), MutableVector (45), MutableArray (31), static-intrinsic (21) and error-payload (44) harnesses, owed by the compiler fixes, likewise.
61. **Broad old/new mutant spot-check.** 48 mutants of ten harnesses: 29 BOTH,
    16 BOTH-SUITE-LEVEL, 2 OLD-ONLY, 0 NEW-ONLY, 1 NEITHER ([Mutation](#mutation)).
62. **OLD-ONLY source-semantic verdicts.** None unexplained: the two OLD-ONLY
    mutants (`missing-provider-silent`, `failed-swap-keeps-replacement`) are an
    outer-anchored diagnostic and a release counter; three first-run gaps were
    migration gaps and are closed.
63. **Differential agreement.** 4702 of 4702 pairs: old passes, new passes, on the
    final tree (three shards, every ported Tcl test proven to have run by name,
    every suite on all four backends).
64. **Stale/missing manifest detection.** `check.tcl -full 1` reports STALE and
    MISSING rows and failed Tcl tests by name; `merge.tcl -check 1` reports
    missing, stale, unexpanded-pattern and unknown-status rows. On the final tree
    both report none (the nine Tcl tests added by the last fixes were found
    missing this way and classified).
65. **FROZEN-DUPLICATE-ORACLE candidates.** 2042 Tcl tests.
66. **ACTIVE-TCL-INTERNAL.** 5238.
67. **ACTIVE-NOT-EXPRESSIBLE.** 1006.
68. **Active Tcl tests that should keep receiving coverage.** The internal layers
    ([Freeze classification](#freeze-classification)): warnings, analysis facts,
    representation and code shape, the parser, the static scheduler, release and
    drop behavior, the process boundary.
69. **Layers represented only in Tcl.** HIR/Core IR/NIR shape and analysis facts
    (100% active), the parser, warnings, native memory behavior (gc 98%, native
    90% active), release order, scheduler economics, the process boundary.
70. **Compiler bottlenecks.** Type inference (38% of the front end) and instance verification (13%) -- the semantic-instance layer's whole-program copies, quadratic --, hygiene's rescans (11%), the completion analysis (8%); outside the front end, the quadratic Core IR lowering (583 s) and the `compile` backend's HIR rebuild. All algorithmic; prototypes and plans in [Compiler performance](#compiler-performance-what-dominates-and-what-would-remove-it).
71. **Tcl-harness overhead.** About 0.05 s per Tcl file (start-up and loading), 1% of the subset; the cost of running whole files instead of the ported tests is 3x.
72. **Golden-harness overhead.** `lib/test.bot` compiled with every suite (0.85 s, about 75 s in all) and re-analyzed in every build; framework execution microseconds; the parallel floor of the largest suite (mutable-array.bot, 351-562 s).
73. **Estimated local feedback-loop winner.** Today the Tcl E2E subset in parallel (180 s) is the fastest full source-level loop, about three times faster than the golden corpus on one backend (517-531 s, bounded by mutable-array.bot); for targeted edits Tcl files win for analyses and golden suites win for native lowering. The golden layer's gap is compiler cost: the measured in-place branch alone halves the largest suites' front end, and the quadratic Core IR lowering and the compile backend's rebuild are the next items. No policy is chosen here.
74. **Evidence for front-end self-hosting.** (a) Where the time is: per-build whole-program analyses, 76-83% of a small suite's front end, with super-linear algorithms that would stay super-linear in Botlish; Tcl's constant factor is real but second. (b) Coupling: the HIR is not self-contained (about 11 process-wide registries the backends read), and there is no complete interchange format (`hir::format` drops modules, the `semantic` and `coroutines` tables, bounds verdicts, spans); native lowering reuses `hir/` analyses including type inference. (c) The natural cut is the whole build loop (`hir::buildSyntax`'s inputs in, analyzed HIR out); parsing alone is 3% of the corpus's front end (13-27% of a small suite's cold, mostly re-parsing `lib/test.bot`), lowering and module loading a few percent more. (d) Tcl can orchestrate across a process boundary (an AOT executable: 2-4 ms start-up, argv in, one String out). (e) Prerequisites: maps, enum payloads and `match`, String ordering and conversions, file I/O and exit status, fast character access on non-ASCII text. (f) The Tcl backends' preparation costs more than the front end, so a Botlish front end alone would not make the golden corpus fast.
75. **Recommended next milestone.** [Recommendations](#recommendations).

## Recommendations

The next milestone decides the workflow (point 133); these are the measurements'
implications, not decisions.

1. **Make the compiler cheaper before choosing defaults or self-hosting.** The
   golden layer costs about three times the Tcl layer it duplicates, and the
   difference is compiler time, nearly all of it algorithmic: the
   semantic-instance layer's whole-program copies (a verified branch,
   `ccr-7eabe55c-semantic-in-place-views`, ready for the full validation its
   commit lists), the guarded one-walk fix, the quadratic `hir::lower`, the
   `compile` backend's HIR rebuild, hygiene's rescans, then the staged plan's
   indexes and the native specializer's copies. Re-measure the corpus with
   `bench/golden-suites.tcl` and `bench/golden-workflows.tcl` after each; the
   local-default question should be decided on those numbers, not today's.
2. **Fix compilation isolation.** A compilation's declarations live in
   process-wide registries the next compilation overwrites (backends of an
   earlier HIR then miscompile or fail) or keeps (error declarations, source
   types: a program using an undeclared error compiles after another program
   declared it). It is a correctness defect of the Tcl tests that compile
   several programs per process, a precondition for caching the front end's
   output, and plausibly the cause of the warm-run slowdown.
3. **Then build a complete interchange format** (analyzed HIR plus the
   declarations, versioned; `traitSource` can stay out) with a byte-identical
   NIR check. It enables compile-once across processes (a reloaded HIR plus a
   declaration replay already ran every backend in a fresh process on two
   suites) and is the precondition of a Botlish front end: the hot code is
   the whole per-build analysis loop, which must move as a unit behind that
   format, and native lowering keeps reusing `hir/` analyses unless their
   inputs move into the format too.
4. **Local default (data):** fastest today is the Tcl E2E subset in parallel
   (180 s). The golden corpus on one backend takes 517-531 s in parallel,
   two-thirds of it the largest suite -- splitting mutable-array.bot and
   destructuring.bot lowers that floor independently of the compiler work.
   For targeted work the covering Tcl files are faster for analysis edits and
   the golden suites for native-lowering edits. Specialized cranelift is the
   cheapest single golden backend; the full four-backend matrix belongs in CI
   (four shards today).
5. **Freezing (data):** 2042 Tcl tests are FROZEN-DUPLICATE-ORACLE candidates,
   but no Tcl file is entirely duplicated: a freeze would be per test (the
   manifest's `freeze` column), or needs a file reorganization first.
6. **Language and compiler gaps the corpus recorded** (separate decisions):
   119 run-time-only failures (evidence for making them declared errors); 45
   outer-anchored diagnostics `static compile:` cannot reify (with the
   TRAIT-POLYMORPHIC-RECURSION contradiction); the framework's friction
   (absolute `rejects_at` locations -- block-relative provenance would remove
   them --, the coroutine trace driver, no code-point escape, no vector
   equality); and, for a Botlish front end, maps, enum payloads and `match`,
   String ordering and conversions, file I/O.
7. **A decision for you:** the recursive-struct fix (e4107e3) rejects, at its
   declaration, an affine struct that holds its own type in a container
   element (AFFINE-CONTAINER-UNSUPPORTED). Before, such a declaration compiled
   while unused and crashed the compiler once a release was needed; a finite
   static drop descriptor cannot express it. If such structs should be
   supported, they need a recursive drop (a runtime walk), which the affine
   design (static descriptors only) currently excludes.

## Files

The specification and its map:

* `tests/golden/*.bot` -- 88 suite files (the validation sample's 8, 45
  migration suites, `completion-regressions.bot` and `recursive-types.bot`, 33
  companions).
* `tests/golden/manifest.tsv` -- the complete map (generated).
* `tests/golden/README.md` -- the porting guide, now with the manifest's
  workflow, exclusions and companions.
* `lib/test.bot` -- `test::rejects_message`, `test::rejects_containing`.

The evidence the manifest is derived from (`audit/golden/migration/`):

* `census/*.tsv` -- one classification row per Tcl test, per Tcl file (169).
* `batches/*.tsv` -- the 45 migration batches (the work plan).
* `fragments/*.tsv` -- each suite's manifest rows.
* `manifest-before.tsv` -- the validation sample's manifest.
* `tcl-names.txt` -- every Tcl test that ran, with its verdict.
* `merge.tcl` -- generates the manifest from the above.
* `mutant-sample.txt`, `sample.tcl` -- the cross-suite mutant sample.

Tools (`audit/golden/tools/`, `bench/`):

* `check.tcl` -- the full differential: every ported Tcl test proven to have
  run by name, every suite on every backend, verdicts per (Tcl test, golden
  test) pair; `-shard I/N`, `-jobs`, `-full` (stale and missing rows),
  `-names-out`, `-mutants`; reports generic stand-ins and static economics.
* `perturb.tcl` -- non-vacuity (invert, alter).
* `ledger.tcl` -- the ledger per subsystem, layer and freeze class.
* `tree.tcl` -- shared process-pool and verdict helpers.
* `census.tcl` -- the construct census (now counting the message helpers).
* `bench/golden-suites.tcl` -- per-suite compile and run economics, cold
  (`-cache DIR` keeps each suite's result, so a long measurement can run in
  pieces) or warm (`-warm N`), with a front-end phase profile; it honors a
  suite's backend exclusions.
* `bench/golden-workflows.tcl` -- the Tcl E2E subset and the golden corpus as
  a developer runs them (`-jobs N` for N processes at a time), and targeted
  edit scenarios.

The measurements and runs behind every number here:
`audit/golden/migration/out/` (the benchmarks' outputs and the measurement
log, the three side-by-side shards, the batched-against-sequential
comparison, the perturbation run, the mutation and fuzz harnesses, native
coverage, the regression summaries of both passes, cargo, GC stress, the
mutant sample, the suite table).

Harness: `tests/golden/run.tcl` (`golden-exclude` headers, generic stand-ins
reported, STATIC lines), `tests/golden.test` (sample by default,
`BOTLISH_GOLDEN_SUITES`, duplicate names, economics ceilings),
`.github/workflows/tests.yml` (four golden shards).

Not on this branch: `ccr-7eabe55c-semantic-in-place-views` (and its
predecessor `ccr-7eabe55c-semantic-in-place`), the semantic-instance
prototype of [Compiler performance](#compiler-performance-what-dominates-and-what-would-remove-it),
for a later merge.

Compiler (each with Tcl and golden regressions): `hir/completions.tcl`,
`hir/staticdeps.tcl`, `hir/static.tcl`, `hir/mutvec.tcl`, `hir/affine.tcl`,
`hir/structs.tcl`, `hir/semantic.tcl`, `hir/range.tcl`, `hir/callables.tcl`;
`audit/static-decisions/tools/mutants.txt` (17 new mutants);
STATIC-COMPLETION-PROOFS.md, STATIC-DECISION-ECONOMICS.md, STATIC-COMPILE.md,
STRUCTS.md, AFFINE-VALUES.md, MUTABLE-VECTOR.md and AGENTS.md record the rules.

## What to run when changing this

* **A golden suite or test**: `tclsh9.0 tests/golden/run.tcl SUITE.bot` (all
  four backends), `audit/golden/tools/perturb.tcl SUITE.bot` (every test can
  fail), `audit/golden/tools/check.tcl -suites SUITE.bot` (side by side with
  its Tcl originals), and the fragment row and `merge.tcl`. Suites are test
  programs, compiled with warnings off like the Tcl suite's programs; the
  warning gate covers `lib/test.bot`.
* **A Tcl test**: its census row; `merge.tcl -check 1` reports a test without a
  row once the names are refreshed.
* **`lib/test.bot`**: as AGENTS.md says (golden-framework.test, golden.test,
  run.tcl, the golden fuzzer and mutants, the warning gate), and
  `perturb.tcl` over every suite (`-mode invert` exercises every verdict path).
* **A compiler diagnostic, `compiler::DiagnosticCode`, the completion analysis
  or the static decisions**: `audit/golden/tools/check.tcl` (all shards: a
  diagnostic's code, position or message is pinned by thousands of golden
  tests) and `audit/static-decisions/tools/compare.tcl tests/golden/*.bot`.
* **The whole corpus**: `tclsh9.0 audit/golden/tools/check.tcl -shard I/4` for
  I = 1..4 (what CI runs), or `-jobs N` on one machine; `-full 1 -names-out
  FILE` also proves every Tcl test ran and refreshes the names.
