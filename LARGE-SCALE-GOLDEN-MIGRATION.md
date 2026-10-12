# LARGE-SCALE-GOLDEN-MIGRATION.md

The large-scale migration of the source-language and end-to-end Botlish
behavior tests from the Tcl harness into the Botlish-native golden framework
(GOLDEN-TEST-FRAMEWORK.md), after VERIFIED-CALLABLE-CONTRACT-BOUNDARY.md,
STATIC-DECISION-ECONOMICS.md and the native `imod` GC-safepoint repair.

> Test a theorem at the highest layer that can express it naturally, while
> retaining lower-layer tests for properties only those layers can observe.

## Outcome

**Every one of the 7266 Tcl tests that run on this revision is examined and
classified; every source-observable one has a Botlish-native golden
specification or a recorded reason; the Tcl suite is unchanged, independent and
still authoritative.** `tests/golden/manifest.tsv` is now the complete map
(8713 rows): 3246 Tcl tests are source-observable, of which 2205 are ported
whole (MIGRATED), 1038 have their source theorem ported while their Tcl test
keeps an internal theorem (SPLIT), and 3 are blocked by a documented compiler or
framework limitation; 4020 observe what Botlish source cannot (2130 compiler or
runtime internals, 509 parser and header behavior, 470 warnings, 583 several
programs, a corpus file or the process environment, 119 run-time-only failures,
209 otherwise not expressible). The golden corpus grew from 8 suites and 223
tests to **85 suite files and 4557 golden tests** (62,742 lines), organized by
language concept, every suite an ordinary strict program that passes on the Tcl
interpreter, the Tcl compiler, generic Cranelift and specialized Cranelift with
one report (10 companions exclude a backend with a recorded reason).

On one checkout, **all 4687 ported (Tcl test, golden test) pairs agree: old
passes, new passes** (audit/golden/tools/check.tcl, every ported Tcl test proven
to have run by name, every golden suite on all four backends). Every golden test
is demonstrably capable of failing (audit/golden/tools/perturb.tcl: it fails
with inverted verdicts, and with its expectation, code or column altered). The
framework's 20 mutants are all killed; the cross-suite mutant sample's results
are in [Mutation](#mutation).

The ordinary framework -- a context holding a `MutableVector` of deferred
`Fn{args: [], return: test::Match}` checks, a coroutine runner, explicit
`static compile:` per test -- carried the whole practical corpus with **no test
syntax, no global registry, no catch-all error, no test-only native and no layout
trick**. The library grew by exactly two helpers (`test::rejects_message`,
`test::rejects_containing`) after four suites had reimplemented them
independently.

The migration found and fixed **five compiler defects** in their own layers
(two completion-analysis precision/soundness defects, two static-decision
dependency defects of which one could make the batched scheduler build a
different program than the sequential reference, and a front-end crash on
recursive struct types), each with Tcl and golden regressions; and it found
**static-decision economics regressions** the previous milestone's claims did
not cover (independent blocks still serialized through the erased-callable
contract and through nested sibling blocks). See [Compiler findings](#compiler-findings).

Performance, measured on the finished corpus (section [Performance](#performance)):
compiling the golden corpus is the cost -- the Tcl front end and the two Tcl
code generators (Core IR lowering plus the Tcl compiler, and NIR lowering)
dominate; Cranelift code generation is about a tenth of a percent and native
execution of every test is milliseconds. **(measured numbers below)**

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
| Botlish golden suites | 85 `tests/golden/*.bot` programs, 4557 tests: the source-level specification of user-visible Botlish semantics | `tests/golden/run.tcl` (every backend, one report), CI's four golden shards (`check.tcl -shard I/4`) |
| Tcl duplicate E2E corpus | the 2038 Tcl tests whose whole theorem a golden test now carries (`tcl_layer` DUPLICATED-E2E, future freeze class FROZEN-DUPLICATE-ORACLE) | unchanged: `tests/all.tcl`, both passes; side by side with their golden tests in CI's golden shards |
| Tcl internal / not-expressible / multi-program tests | 5228 Tcl tests (`tcl_layer` ACTIVE-INTERNAL 3638, ACTIVE-NOT-EXPRESSIBLE 1007, ACTIVE-MULTI-PROGRAM 583) | unchanged: `tests/all.tcl` |
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
   is 6107). `audit/golden/migration/tcl-names.txt` is the name authority (7266
   after the migration's own new tests).
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
   (31 of the 85 files).

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
| affine | 110 | 98 | 44 | 54 | 11 | 0 | 0 | 0 | 1 | 0 | 0 | 213 |
| collections | 581 | 319 | 261 | 58 | 131 | 0 | 0 | 23 | 106 | 2 | 0 | 443 |
| contexts | 75 | 41 | 22 | 19 | 14 | 0 | 0 | 2 | 8 | 10 | 0 | 89 |
| coroutines | 56 | 46 | 41 | 5 | 8 | 0 | 0 | 0 | 0 | 2 | 0 | 63 |
| diagnostics | 198 | 187 | 150 | 37 | 6 | 0 | 0 | 0 | 1 | 4 | 0 | 287 |
| errors | 267 | 220 | 183 | 37 | 20 | 0 | 0 | 6 | 17 | 4 | 0 | 418 |
| functions | 411 | 330 | 255 | 75 | 63 | 0 | 0 | 12 | 2 | 4 | 0 | 407 |
| gc | 167 | 75 | 4 | 71 | 63 | 0 | 0 | 0 | 29 | 0 | 0 | 80 |
| harness | 85 | 18 | 8 | 10 | 28 | 0 | 0 | 2 | 24 | 13 | 0 | 30 |
| hir-core-nir | 1258 | 118 | 1 | 117 | 1042 | 0 | 15 | 13 | 4 | 66 | 0 | 155 |
| modules | 216 | 106 | 72 | 34 | 16 | 0 | 20 | 1 | 71 | 2 | 0 | 205 |
| native | 919 | 344 | 91 | 252 | 479 | 0 | 0 | 17 | 67 | 12 | 1 | 382 |
| opaque | 107 | 80 | 77 | 3 | 10 | 0 | 0 | 2 | 9 | 6 | 0 | 115 |
| parser | 496 | 9 | 2 | 7 | 13 | 0 | 474 | 0 | 0 | 0 | 0 | 12 |
| refinements | 262 | 161 | 121 | 40 | 75 | 0 | 0 | 1 | 8 | 17 | 0 | 251 |
| static-compile | 59 | 33 | 23 | 10 | 26 | 0 | 0 | 0 | 0 | 0 | 0 | 44 |
| strings | 433 | 267 | 158 | 109 | 7 | 0 | 0 | 11 | 116 | 32 | 0 | 286 |
| surface | 685 | 645 | 574 | 70 | 9 | 0 | 0 | 22 | 0 | 9 | 1 | 951 |
| traits | 68 | 53 | 39 | 13 | 6 | 0 | 0 | 0 | 1 | 8 | 1 | 79 |
| warnings | 638 | 10 | 3 | 7 | 85 | 470 | 0 | 0 | 57 | 16 | 0 | 10 |
| **total** | **7266** | **3246** | **2205** | **1038** | **2130** | **470** | **509** | **119** | **583** | **209** | **3** | **4687** |

The subsystem is the census's reading of what a test is about, not its file
(warnings tests' program halves are counted under warnings; the parser's
lowering tests that observe values under parser). A golden row is one (Tcl test,
golden test) pair: 826 Tcl tests became several golden tests (a broad Tcl test
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

85 suite files: the validation sample's 8 (unchanged), 45 suites of the
migration's batches, `completion-regressions.bot` (the regressions of the
compiler defects the migration fixed), and 31 companions. A suite is named for
its concept, not its Tcl file (`destructuring.bot`, `callable-contracts.bot`,
`affinity.bot`, ...); the manifest keeps the mapping back. A companion exists for
one of three reasons, each stated in its header:

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
* **a program-wide fact** (5 files): the erased-callable contract is
  everything the *whole* program passes into untyped parameters, so a test of
  what an uncontracted call is charged needs a program that erases exactly its
  own callables (`callable-contracts-returned.bot`, `-fallback`, `-handle`,
  `-unerased`, `static-compile-erased-consumer.bot`);
* **a backend exclusion** (10 files, [below](#backends-and-exclusions)), so that
  the main suite keeps its full matrix.

Per suite (front-end and wall seconds from the full side-by-side run, three
suites at a time on a 4-core machine shared with other compilation jobs: compare
within the table only; the quiet-machine measurements are in
[Performance](#performance)):

| suite | golden tests | Tcl tests | from Tcl files | lines | static blocks | rounds | builds (method trials) | front end s* | 4-backend wall s* |
|---|---|---|---|---|---|---|---|---|---|
| abi-bytes-native.bot | 3 | 3 | abi-bytes | 87 | 3 | 1 | 1 (0) | 3.3 | 5.5 |
| abi-bytes.bot | 103 | 57 | abi-bytes, abi-mutable-bytes | 1098 | 103 | 3 | 3 (0) | 22.6 | 117.0 |
| abi-numeric-native.bot | 1 | 1 | abi-numeric | 40 | 1 | 1 | 1 (0) | 1.7 | 4.0 |
| abi-numeric.bot | 87 | 34 | abi-numeric, scalarbits | 865 | 76 | 2 | 2 (0) | 16.6 | 121.7 |
| affinity.bot | 67 | 32 | affine | 1110 | 67 | 9 | 10 (0) | 43.2 | 84.4 |
| bits-bytes-hashing.bot | 47 | 51 | native-bitshift, native-byte, native-csv-records, native-executable +1 | 525 | 35 | 1 | 1 (0) | 5.8 | 52.7 |
| callable-contracts-fallback.bot | 4 | 3 | higher-order-completions | 112 | 4 | 2 | 2 (0) | 5.7 | 15.8 |
| callable-contracts-handle.bot | 1 | 1 | structural-contract-completions | 61 | 1 | 1 | 1 (0) | 1.1 | 3.9 |
| callable-contracts-returned.bot | 4 | 6 | higher-order-completions | 150 | 4 | 4 | 4 (0) | 8.9 | 23.0 |
| callable-contracts-unerased.bot | 1 | 1 | structural-contract-completions | 44 | 1 | 1 | 1 (0) | 2.0 | 8.2 |
| callable-contracts.bot | 95 | 81 | exact-callable-executable, higher-order-completions, structural-contract-completions | 1801 | 81 | 27 | 31 (2) | 267.6 | 405.4 |
| callables.bot | 113 | 101 | closure-int-keys, exact-callable-key, structural-fn-types, typed-callable-escape | 1780 | 111 | 16 | 16 (0) | 421.7 | 504.3 |
| closure-escape-instances.bot | 1 | 1 | native-listloop | 48 | 1 | 1 | 1 (0) | 2.3 | 10.0 |
| closure-escape.bot | 49 | 47 | blockescape-called-generic, blockescape-nested-capturers, native-block-escape, native-escape +1 | 911 | 49 | 1 | 1 (0) | 6.3 | 56.7 |
| collections.bot | 44 | 23 | enums, flags, immutable-set, list-stdlib +9 | 718 | 44 | 4 | 7 (2) | 12.1 | 25.5 |
| compiled-values-struct-transport.bot | 17 | 16 | value-transport | 368 | 17 | 1 | 1 (0) | 8.4 | 52.3 |
| compiled-values.bot | 118 | 95 | blockescape-nested-capturers, compiler-opt, direct-hir-native, dormant-instances +6 | 1698 | 114 | 16 | 16 (0) | 583.7 | 972.3 |
| completion-regressions.bot | 23 | 11 | errors | 381 | 23 | 2 | 2 (0) | 3.4 | 8.2 |
| contexts.bot | 87 | 48 | context-traits, contexts, linux-path | 1258 | 80 | 3 | 4 (0) | 36.1 | 116.5 |
| core-semantics.bot | 141 | 119 | acceptance, backends, bindings, blocks +8 | 1810 | 126 | 3 | 3 (0) | 27.7 | 159.3 |
| coroutines.bot | 62 | 47 | coroutines | 1456 | 61 | 4 | 5 (0) | 23.9 | 94.9 |
| declared-errors-imports.bot | 10 | 2 | namespaced-errors | 133 | 10 | 2 | 3 (0) | 3.2 | 7.7 |
| declared-errors.bot | 113 | 72 | error-payloads, errors, namespaced-errors | 1942 | 106 | 5 | 9 (3) | 95.4 | 279.8 |
| destructuring-instances.bot | 55 | 22 | struct-destructuring | 686 | 55 | 1 | 1 (0) | 2.3 | 11.3 |
| destructuring.bot | 378 | 179 | struct-destructuring | 3680 | 356 | 5 | 7 (1) | 129.9 | 528.2 |
| diagnostics.bot | 27 | 24 | enums, flags, hir-resolution, imports +9 | 511 | 28 | 5 | 7 (1) | 19.9 | 43.9 |
| errors.bot | 24 | 20 | error-payloads, errors, higher-order-completions, mutable-array-type +3 | 607 | 26 | 3 | 3 (0) | 4.7 | 13.4 |
| flags.bot | 100 | 98 | flags | 1308 | 100 | 2 | 2 (0) | 6.6 | 185.4 |
| framework-semantics.bot | 29 | 17 | golden-framework | 611 | 26 | 5 | 9 (2) | 60.0 | 93.0 |
| gc-sensitive-values.bot | 22 | 24 | native-alloc, native-root-liveness, native-stack-map, string-allocation | 519 | 22 | 1 | 1 (0) | 2.0 | 17.4 |
| harness.bot | 13 | 13 | argv, calls, coroutines, hir-lowering +6 | 363 | 14 | 2 | 2 (0) | 5.4 | 37.7 |
| hir-values.bot | 14 | 12 | hir-aot, hir-lowering, hir-resolution, hir-samples | 277 | 14 | 2 | 2 (0) | 3.5 | 14.8 |
| imports-abi-child.bot | 17 | 10 | imports, surface-modules | 169 | 17 | 3 | 3 (0) | 4.0 | 9.8 |
| imports-abi-family.bot | 6 | 5 | imports, surface-modules | 89 | 6 | 1 | 1 (0) | 5.2 | 17.2 |
| imports-library-modules.bot | 12 | 11 | imports, surface-modules | 156 | 12 | 3 | 3 (0) | 9.1 | 38.7 |
| imports-unimported.bot | 16 | 6 | imports | 136 | 14 | 2 | 2 (0) | 2.1 | 6.7 |
| imports.bot | 59 | 36 | imports, surface-modules | 524 | 58 | 4 | 16 (11) | 108.3 | 167.6 |
| linux-io-native.bot | 5 | 4 | linux-syscall | 121 | 5 | 1 | 1 (0) | 3.1 | 5.5 |
| linux-io.bot | 55 | 26 | argv, linux-syscall | 501 | 47 | 4 | 4 (0) | 12.0 | 29.0 |
| lists-and-sets.bot | 86 | 89 | byte-set, immutable-set, list-stdlib, lists +2 | 778 | 72 | 3 | 3 (0) | 18.7 | 93.7 |
| loop-collecting-refined-checks.bot | 1 | 1 | raw-count-loops | 50 | 1 | 1 | 1 (0) | 3.2 | 43.3 |
| loop-collecting.bot | 110 | 110 | loop-collecting, raw-count-loops | 1366 | 106 | 3 | 3 (0) | 12.5 | 85.9 |
| loops.bot | 55 | 72 | loop-counted, loop-in, loops | 783 | 55 | 2 | 2 (0) | 8.7 | 64.0 |
| method-equivalence-imported.bot | 13 | 9 | method-eligible | 199 | 11 | 3 | 5 (1) | 15.5 | 41.1 |
| method-equivalence.bot | 45 | 36 | method-eligible | 584 | 42 | 3 | 3 (0) | 4.4 | 14.3 |
| methods-byte-without-list.bot | 3 | 2 | method-sugar | 54 | 3 | 2 | 2 (0) | 4.5 | 15.1 |
| methods-list-without-str.bot | 3 | 2 | method-sugar | 47 | 3 | 2 | 2 (0) | 4.5 | 13.8 |
| methods-struct-instances.bot | 8 | 5 | method-sugar | 109 | 8 | 1 | 1 (0) | 0.9 | 4.8 |
| methods-type-import-only.bot | 1 | 1 | method-sugar | 29 | 1 | 2 | 2 (0) | 3.8 | 11.3 |
| methods.bot | 195 | 104 | method-sugar | 1819 | 198 | 5 | 7 (1) | 134.6 | 347.9 |
| modules.bot | 31 | 12 | context-traits, contexts, imports, namespaced-errors +5 | 572 | 33 | 3 | 4 (0) | 21.0 | 70.2 |
| mutable-array.bot | 233 | 115 | mutable-array-type, mutable-array, mutarray-construction | 2930 | 233 | 7 | 34 (24) | 1031.2 | 1495.8 |
| mutable-vector-str.bot | 1 | 1 | mutable-vector | 44 | 1 | 1 | 1 (0) | 2.1 | 6.5 |
| mutable-vector.bot | 74 | 41 | mutable-vector | 1206 | 70 | 4 | 21 (14) | 178.9 | 338.2 |
| names-and-scoping.bot | 58 | 61 | hir-syntax, strict-references, surface-lowering | 861 | 58 | 2 | 2 (0) | 4.5 | 26.3 |
| native-aggregates.bot | 70 | 69 | native-mutarray, native-param-aggregate, native-refinement-propagation, native-tiny-leaf-inline | 1223 | 57 | 1 | 1 (0) | 9.6 | 90.3 |
| native-values.bot | 89 | 62 | backends, native-bitwise-fold, native | 1102 | 79 | 1 | 1 (0) | 11.7 | 119.1 |
| opaque-instances.bot | 1 | 1 | opaque-struct | 37 | 1 | 1 | 1 (0) | 2.5 | 6.7 |
| opaque.bot | 91 | 73 | opaque-struct | 1124 | 91 | 11 | 15 (2) | 117.4 | 207.4 |
| ownership.bot | 38 | 13 | affine, coroutines, mutable-array, mutable-vector | 700 | 38 | 5 | 24 (15) | 140.2 | 195.3 |
| range-and-contract-values.bot | 78 | 68 | checked-domain-proof-provenance, closed-closure-entry-facts, conjunctive-entry-facts, exact-value-facts +5 | 1149 | 76 | 13 | 13 (0) | 193.8 | 303.3 |
| raw-int-abi.bot | 52 | 50 | raw-int-abi, raw-internal-abi | 951 | 52 | 1 | 1 (0) | 5.0 | 60.4 |
| refinements.bot | 66 | 52 | refined-signatures, refined, refinement-values | 1036 | 66 | 3 | 10 (5) | 111.7 | 195.7 |
| representation.bot | 14 | 12 | abi-numeric, enums, loop-counted, native-bitshift +7 | 357 | 14 | 2 | 2 (0) | 4.7 | 20.8 |
| static-compile-erased-consumer.bot | 2 | 1 | static-economics | 59 | 2 | 2 | 2 (0) | 2.3 | 8.0 |
| static-compile.bot | 81 | 58 | static-compile, static-economics | 1452 | 153 | 26 | 33 (4) | 479.5 | 616.5 |
| stdlib-namespaces-entry-members.bot | 4 | 2 | stdlib-namespaces | 64 | 4 | 1 | 1 (0) | 1.8 | 5.5 |
| stdlib-namespaces-str-only.bot | 1 | 1 | stdlib-namespaces | 25 | 1 | 2 | 2 (0) | 3.4 | 7.4 |
| stdlib-namespaces-unimported.bot | 2 | 1 | stdlib-namespaces | 32 | 2 | 2 | 2 (0) | 3.3 | 7.8 |
| stdlib-namespaces.bot | 114 | 49 | module-static-values, stdlib-namespaces | 1065 | 110 | 3 | 9 (5) | 70.8 | 185.5 |
| string-natives.bot | 82 | 81 | native-string-region, native-string-traversal, native-string-view, native-uri-escape | 1077 | 45 | 1 | 1 (0) | 9.0 | 88.0 |
| string-representations.bot | 48 | 50 | packed-ascii, short-string | 900 | 48 | 1 | 1 (0) | 6.8 | 59.8 |
| strings.bot | 94 | 102 | ascii, emailish-predicate, native-tcl-unicode, str-char-at +2 | 932 | 67 | 2 | 2 (0) | 13.3 | 110.6 |
| struct-representation-instances.bot | 15 | 14 | struct-scalar-replacement | 240 | 15 | 1 | 1 (0) | 3.3 | 13.3 |
| struct-representation.bot | 110 | 98 | struct-scalar-replacement, virtual-construction | 1732 | 107 | 1 | 1 (0) | 17.2 | 259.9 |
| structs-and-enums-instances.bot | 4 | 4 | structs | 84 | 4 | 1 | 1 (0) | 1.6 | 7.2 |
| structs-and-enums-qualifiers.bot | 2 | 1 | enums | 49 | 2 | 1 | 1 (0) | 2.0 | 8.2 |
| structs-and-enums.bot | 111 | 77 | enums, structs | 1335 | 111 | 6 | 19 (11) | 139.9 | 230.0 |
| traits-path.bot | 2 | 2 | traits | 73 | 2 | 1 | 2 (0) | 3.2 | 7.9 |
| traits.bot | 67 | 43 | traits | 1024 | 79 | 5 | 10 (3) | 67.8 | 120.6 |
| types.bot | 96 | 93 | applied-types, empty-collection-admissibility, source-types, symbolic-type-identity +1 | 1269 | 94 | 3 | 3 (0) | 26.0 | 89.2 |
| unicode-strings.bot | 56 | 56 | native-tcl-unicode | 190 | 5 | 1 | 1 (0) | 3.4 | 17.0 |
| validators-and-proofs.bot | 153 | 54 | proof-loop-intervals, proven-bounds, refinement-validators | 1748 | 153 | 3 | 4 (0) | 23.5 | 125.0 |
| values.bot | 32 | 36 | blocks, calls, control, elif +8 | 1005 | 26 | 1 | 1 (0) | 7.2 | 51.8 |
| warning-programs.bot | 42 | 37 | fixed-arity-list-return, many-boolean-arguments, one-char-string-literal, proves-naming +1 | 623 | 42 | 3 | 4 (0) | 9.0 | 25.8 |
| total (85 suites) | 4557 | 3280 | | 62742 | 4359 | 303 | 451 (107) | 4921 | 10265 |

Every suite ends with `with context test::suite()`, its registration calls and
`test::report()`; every test body is a nested function `fn NAME() errors
compiler::CompilerError:` around a `static compile:` block; registration
functions group tests by concept and take run-time inputs as parameters; names
are semantic (the Tcl name when it already is, the manifest keeps the old one).

## What stays in Tcl, and why

4020 Tcl tests (55%) stay Tcl-only, each for an observational reason recorded in
its row; 1038 more keep an active internal half beside their golden test:

| reason | Tcl tests | what they observe |
|---|---|---|
| KEEP-INTERNAL | 2130 | HIR/Core IR/NIR text and facts, plans, ranges, instances, allocation and release counts, stack maps, safepoints, root maps, caches, build counts, scheduler internals, the Rust/Cranelift layers |
| KEEP-PARSER | 509 | lexer and parser output, syntax errors, header and import-placement failures, HIR text readers |
| KEEP-WARNING | 470 | every warning (kind, wording, count, location) -- warnings are not reified |
| KEEP-MULTI-PROGRAM | 583 | several programs or installations, `main.tcl` and executables, stdout, argv/environment, private generated modules, option matrices -- and 164 tests whose subject is a corpus file (CORPUS-SUBJECT, below) |
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

Per ported Tcl test (its golden rows together): **1240 equal, 799 stronger,
1013 split, 191 weaker**.

* **Stronger** (799): the golden test runs where the Tcl test did not (most Tcl
  tests ran one or two backends; every golden test runs four), pins a
  `DiagnosticCode` and location where the Tcl test matched a message glob,
  compares a value the Tcl test only computed, uses run-time inputs where the Tcl
  program's constants let the compiler fold the theorem away (506 rows
  DYNAMIC-INPUT), or replaces a vacuous Tcl assertion
  ([Old-test findings](#old-test-findings)).
* **Split** (1013): the source theorem is ported; the Tcl test stays active for
  what only it observes (`tcl_retained`): NIR or allocation shape, release
  counters, the full `-strict 0` diagnostic list, the program-boundary uncaught
  error, GC-stress equality, warning counts.
* **Weaker** (191 Tcl tests, 287 rows), each saying what was lost: the message
  wording is not compared while code and location are (156 rows; the README rule
  -- messages are reports, not properties -- and mostly OLD-TEST-OVERSPECIFIED);
  a rejected block reifies only its *first* diagnostic, so "exactly one
  diagnostic" or "the same diagnostic for both spellings" stays in Tcl (57); a
  location the Tcl test pinned is not (12); source cannot name `+` or `*` as a
  value, so a test of a native passed through a parameter uses `mod` (5); the
  program-boundary uncaught-error behavior (4); a value's display text or order
  (4); a `-strict 0` program whose strict form differs (3); other specific
  losses (46, each in its notes). A whole port that is weaker keeps its Tcl test
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
| 5 | **Crash.** `hir::mutvec::ShareDescriptor` recursed without bound (TCL LIMIT STACK) on a program declaring a recursive struct type and using `MutableVector` anywhere -- which every golden suite does, through `lib/test.bot`. | `hir/mutvec.tcl` | `structs.test` struct-named-recursive-declaration | RECURSIVE_TYPES_FIX |

Static-decision **economics** findings (not wrong results): the previous
milestone established that builds scale with dependency depth, not with the
number of independent rejected blocks; the migrated corpus found three shapes
where they still scale with the number of blocks:

* **the erased-callable contract**: a rejected block that passes a callable into
  an untyped parameter is both an erasure site and a consumer of the
  program-wide erased-callable contract, so such blocks were decided one per
  build even when none of the erased callables declares an error
  (callable-contracts.bot 27 rounds / 31 builds, compiled-values.bot 16/16,
  callables.bot 16/16, range-and-contract-values.bot 13/13, opaque.bot 11/15);
* **nested sibling blocks**: TYPE rejections in sibling functions inside one
  enclosing `static compile:` block were decided one per round (static-compile.bot
  26 rounds after #4);
* **internal ids**: a TYPE message that prints an exact callable as `block(eN)`
  is committed only in the sequential order's own build, by design; seven such
  blocks cost callables.bot seven rounds, and one USE-AFTER-MOVE message that
  names no internal id was classified as naming one;

plus an unmodelled channel that only mispredicts (decisions still equal
sequential): `hir::traits::Plan` runs only on a diagnostic-free program
(traits.bot, affinity.bot). ECONOMICS_FIX

## The framework at scale

The design of GOLDEN-TEST-FRAMEWORK.md held at 20 times the sample's size
without a change of shape: no test syntax, no global registry (every suite
registers explicitly through ordinary functions; 819 registration functions),
no catch-all error (1112 explicit `on E` handlers express which declared error
a test expects -- they are the theorem, not boilerplate), no test-only native,
no layout trick (bodies are where they read best; 154 of 4279 are at a suite's
top level). Counted over all 85 suites (`audit/golden/tools/census.tcl`):

| construct | count |
|---|---|
| `test::value` registrations | 2902 |
| `test::rejects` | 688 |
| `test::rejects_at` (an absolute location of the suite file) | 288 |
| `test::rejects_message` / `test::rejects_containing` | 338 |
| `test::holds` / `test::rejects_any` | 0 / 0 |
| custom `test::case` | 28 |
| calls of suite-local registration helpers (tables, message+location, same-diagnostic) | 292 |
| test bodies (`fn NAME() errors compiler::CompilerError:`) | 4279 |
| `static compile:` blocks | 4359 |
| explicit run-time error handlers | 1112 |
| top-level declarations (struct, enum, error, refined type, trait, context struct, ...) | 513 |
| lines per registered case, declarations and comments included | 14.8 |

Per manifest row: 4403 simple helper, 245 suite-local helper, 39 custom; 1456
rows need the static boundary semantically (a rejection or an escaping error),
3231 use it by convention; 669 handle a run-time error explicitly; 421 pin a
location, 836 a message, 23 related locations; 506 use run-time inputs to defeat
folding or KnownError; 1386 port a `-strict 0` Tcl program strictly. The
ceremony every test repeats -- a named body, `errors compiler::CompilerError`,
`static compile:`, a registration line -- appears 4279 times; it is the evidence
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
* **absolute locations**: 288 `rejects_at` tests name suite-file lines; agents
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
STAND-IN suites). STANDIN_RESULT

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

Every migration suite passed both before it was accepted (registrations with
computed names or `unit`/`[]` expectations cannot be altered textually; invert
covers them, and several migrators altered those by hand). PERTURB_RESULT

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
| error payloads (`audit/error-payloads/tools/mutate.tcl`) | 44 | MUTANTS_EP | `hir/completions.tcl` |
| static intrinsics (`audit/static-compile/tools/mutate.tcl`) | 21 | MUTANTS_SC | `hir/static.tcl` |
| affine values (`audit/affine/tools/mutate.tcl`) | 29 | MUTANTS_AF | `hir/affine.tcl`, `hir/structs.tcl` |
| coroutines (`audit/coroutines/tools/mutate.tcl`) | 52 | MUTANTS_CO | `hir/affine.tcl`; the runner is a coroutine |
| MutableVector (`audit/mutable-vector/tools/mutate.tcl`) | 45 | MUTANTS_MV | `hir/mutvec.tcl` |
| MutableArray (`audit/mutable-array/tools/mutate.tcl`) | 31 | MUTANTS_MA | `hir/mutvec.tcl` |

Every compiler fix of the migration also ran its layer's fuzzers (several
seeds, once under GC stress where the harness has the switch): FUZZ_RESULTS.

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
