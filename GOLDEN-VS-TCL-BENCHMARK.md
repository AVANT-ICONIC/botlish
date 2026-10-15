# Golden suites against their Tcl originals, with and without the front-end cache

A benchmark of the two end-to-end test layers as a developer runs them, on
all four backends, with and without the front-end cache (`BOTLISH_HIR_CACHE`,
HIR-INTERCHANGE.md), profiled phase by phase. The two layers are:

* **the Tcl tests that have golden counterparts**: the 3252 tests the
  manifest marks MIGRATED or SPLIT (LARGE-SCALE-GOLDEN-MIGRATION.md), in 138
  files;
* **the golden corpus**: the 88 suites of `tests/golden/`.

Measured at a9d81f9 (on main, 2026-10-15; plus the two benchmark tools),
on a 4-core cloud container.

## Outcome

* **Without the cache, the golden corpus costs 2.5 to 3.9 times the Tcl tests
  it duplicates**, backend by backend (CPU seconds; interp 3.73, compile 3.89,
  cranelift-generic 2.45, cranelift 2.77). The golden front end is the
  difference: 1,496 s of the 3,670 s it takes to run the corpus on all four
  backends.
* **With a warm cache it costs less than they do, on every backend**: interp
  0.79, compile 0.98, cranelift-generic 0.14, cranelift 0.56 times the Tcl
  tests' CPU time. The cache cuts the golden corpus's cost by 4.0 to 17 times
  per backend. 88 hits cost 4.6 s in all (median 40 ms a suite); the 88
  entries take 185 MB.
* **On all four backends**, one process per suite:

  | | wall s (4 at a time) | CPU s |
  |---|---:|---:|
  | Tcl tests, one CORE_BACKEND pass | 172 | 643 |
  | Tcl tests, the four passes | 681 | 2,581 |
  | golden, no cache | 933 | 3,670 |
  | golden, cold cache (the build stores the entry) | 964 | 3,786 |
  | golden, warm cache | 373 | 1,460 |

  With a warm cache, the golden corpus on all four backends costs 57% of the
  four Tcl passes and 2.3 times one pass. Most of the ported Tcl tests compare
  backends themselves (62% run natively even in the interp pass), so one pass
  is the fairer comparison.
* **The Tcl layer cannot use the cache**: the Tcl suite's harness unsets
  `BOTLISH_HIR_CACHE` on purpose. About half of its compilations (2,972 of
  5,741) are source strings compiled with `surface::compile`, which the cache
  does not cover anyway. A control run with the variable set left the cache
  directory empty and ran in the ordinary time.
* **Once the cache removes the front end, one procedure is half of what is
  left**: `hir::affine::temporaries`. It takes 852 of the warm all-backend
  run's 1,547 s: 547 of the `compile` backend's 584 s and 304 of interp's
  498 s. It recomputes a whole-program set for every construction it lowers
  (`hir::lower::Pending`), once per call site and again per block in the Tcl
  compiler: 162,105 calls over the corpus. **Memoizing it** per HIR (an
  experiment injected at load time, not a fix) **halves the warm run** (CPU
  1,460 s to 696 s; the `compile` backend's runs from 554 s to 29 s) and cuts
  the run without the cache by 44%. With both, the golden corpus on all four
  backends costs about one Tcl pass (696 against 643 CPU s).
* Two smaller effects:
  - **Process history.** The backends' Tcl work runs 1.4 to 1.7 times slower in
    the process that has just run the front end than in a fresh process that
    decoded the same HIR. A warm cache gets this for free. It is nearly all in
    the `temporaries` walk: with that walk memoized, it disappears.
  - **The cost of a cold cache.** Encoding the HIR to store it slows the
    specialized native lowering that runs after it in the same process by
    20-25%: +136 s of cranelift runs on the corpus. A cold cache's whole
    extra cost is 116 CPU s, 3.1%.

## How it was measured

* **The tool.** `bench/golden-vs-tcl.tcl` runs either layer.
  - **Tcl tests:** one tclsh per file, tcltest `-match` running exactly the
    ported tests, `CORE_BACKEND=B`, a private `-tmpdir`, and `-verbose u` for
    each test's body time.
  - **Golden suites:** one `tests/golden/run.tcl -backends LIST -quiet SUITE`
    process per suite.
  - **Each run:** 4 processes at a time, longest first, every process under
    bash's `time`. CPU counts the process and every child it waited for:
    native drivers, main.tcl children.
  - **Options:** `-hir-cache DIR` sets `BOTLISH_HIR_CACHE` in every child.
    `-profile 1` runs every process under `bench/phase-profile.tcl`.
  - **Output:** `report` prints every table here.
* **The profiler.** `bench/phase-profile.tcl` wraps about 60 procedures as
  they are defined: the front end's phases, the cache's path, and every
  backend's phases. Each is recorded with its self time.
  - A test file reloads the compiler, which is why procedures are wrapped as
    they are defined.
  - The golden runner's per-backend runs are profiled as roots (`run:BACKEND`).
  - It is the same instrument in both layers' processes.
  - Its overhead is under 2%: the profiled Tcl pass took 634 s of process time
    against 645 s for the unprofiled control taken half an hour later, and the
    profiled cold golden run 3,846 s against 3,855 s.
* **Metrics.**
  - CPU seconds summed over processes are the comparison: four processes on
    four cores barely change them.
  - Wall time at four jobs is what a developer waits.
  - "Process s" is each process's own wall time, summed.
* **Variance.**
  - The first batch's four Tcl passes (15:56-16:09) ran 7-16% slower than the
    same passes later. Their CPU summed to 663-748 s; a second batch at
    18:15-18:26 took 637-659 s, and the control at 18:14 took 614 s.
  - The golden corpus did not move: without the cache it took 2,384 and
    2,396 CPU s in the two batches; with a warm cache it moved within 7%.
  - So the tables use the second batch for the Tcl passes and the warm golden
    runs, which were taken together. The first batch is kept as `*-s1`
    in the raw data.
* **What failed.** Under `CORE_BACKEND=cranelift` and `cranelift-generic`, 29
  ported Tcl tests in 10 files fail. They are core-semantics and loop-effect
  tests written as core IR, which the native harness does not support in
  sequence mode (`tests/native-coverage.tcl` classifies them). Their time is
  counted. Every other run passed everything: 3252 Tcl tests, and 4567 / 4567
  / 4474 / 4576 golden tests on interp / compile / cranelift-generic /
  cranelift. The differences are the suites' recorded exclusions.

## The two layers, backend by backend

Wall s at four jobs / CPU s:

| backend | Tcl tests | golden, no cache | golden, warm cache | no cache / Tcl (CPU) | warm / Tcl (CPU) | the cache saves |
|---|---|---|---|---:|---:|---:|
| interp | 172 / 643 | 608 / 2,396 | 130 / 510 | 3.73 | 0.79 | 4.7x |
| compile | 169 / 644 | 636 / 2,505 | 161 / 632 | 3.89 | 0.98 | 4.0x |
| cranelift-generic | 167 / 636 | 397 / 1,559 | 24 / 91 | 2.45 | 0.14 | 17x |
| cranelift | 173 / 659 | 464 / 1,824 | 95 / 371 | 2.77 | 0.56 | 4.9x |

* **The front end.** Without the cache, the golden front end is about 1,500 s
  of every column (1,474-1,638 s summed over the suites). The backends'
  share is 90 s (cranelift-generic) to 1,008 s (compile).
* **The cache.** It removes the front end and leaves each backend's own cost,
  which a cache hit makes cheaper still (see Process history below).
* **Wall time without the cache** is held up by mutable-array.bot: its front
  end alone is 330-370 s of every single-backend run's 400-640 s.
* **The Tcl layer.** Its four passes cost the same (636-659 CPU s), because
  most of its tests do not depend on CORE_BACKEND.
  - Almost all of its time is in test bodies: 671 of 686 s, 0.11 s per file
    outside them.
  - In the interp pass, 2,027 of the 3,252 tests (62%) run natively,
    6,776 native runs in all (`NATIVE_COVERAGE`).

### What a developer's edit costs

The cache key holds the front end's fingerprint: `core/`, `hir/`, `surface/`
and lib's Tcl libraries.

* **An edit to `compiler/` or `native/`** keeps every entry valid. Rerunning the
  golden corpus on the backend edited costs:
  - `native/` on cranelift: 95 s against the Tcl tests' 173 s;
  - `native/` on cranelift-generic: 24 s against 167 s;
  - `compiler/` on `compile`: 161 s against 169 s.

  The golden layer is the cheaper one here.
* **An edit to the front end, the evaluator or a library module** (`core/`,
  `hir/`, `surface/`, `lib/`) invalidates every entry or the importers'. The
  golden corpus then costs its no-cache price, 3.7-3.9 times the Tcl tests on
  interp and compile.
  - The first golden run stores the entries at no visible cost when it runs one
    backend. The cold interp run took 2,245 CPU s against 2,384-2,396 s
    without the cache.
  - It also costs nothing visible on all four backends in one process, except
    for the specialized native lowering (below).
  - `hir/lower.tcl`, `hir/aot.tcl` and `hir/specialize.tcl` are backend-side
    code inside the fingerprint: editing them invalidates the cache needlessly
    (HIR-INTERCHANGE.md, "Validity").

## All four backends

| configuration | wall s | process s | CPU s |
|---|---:|---:|---:|
| Tcl tests, the four CORE_BACKEND passes | 681 | 2,721 | 2,581 |
| golden, a process per suite and backend, no cache | 2,105 | 8,407 | 8,283 |
| golden, a process per suite and backend, one cache (interp fills it, the other three hit) | 849 | 3,392 | 3,339 |
| golden, a process per suite (four backends), no cache | 933 | 3,726 | 3,670 |
| golden, a process per suite (four backends), cold cache | 964 | 3,855 | 3,786 |
| golden, a process per suite (four backends), warm cache | 373 | 1,489 | 1,460 |
| (experiment) the same, `temporaries` memoized, no cache | 519 | 2,073 | 2,037 |
| (experiment) the same, `temporaries` memoized, warm cache | 179 | 713 | 696 |

Seconds summed over the suites, golden runner's own timing:

| configuration | compile (front end or hit) | interp run | compile run | cranelift-generic run | cranelift run |
|---|---:|---:|---:|---:|---:|
| no cache | 1,496 | 750 | 1,004 | 92 | 376 |
| cold cache | 1,502 | 741 | 999 | 94 | 512 |
| warm cache | 4.6 | 483 | 554 | 81 | 359 |
| memoized, no cache | 1,404 | 191 | 28 | 90 | 353 |
| memoized, warm cache | 5.0 | 204 | 29 | 89 | 378 |

* **Running the backends in separate processes**, one `run.tcl -backends B`
  per backend, without the cache, pays the front end four times (8,283 CPU s).
  - Through one cache it pays once (3,339 s).
  - That is cheaper than all four backends in one process, without the cache
    (3,670 s) or through a cold one (3,786 s). The three backends that hit
    run in fresh processes (Process history, below).
  - It is 1,880 s above a warm all-in-one run, 1,511 s of it the cold
    interp run's front end.
* **Compared with the migration's measurements** (LARGE-SCALE-GOLDEN-MIGRATION.md,
  "Performance", an earlier tree, four at a time):
  - the golden corpus on all four backends: 1,188 s then, 933 s now. The
    `compile` backend no longer rebuilds HIR from Core IR (14a1143);
  - on interp: 517 s then, 605-608 s now;
  - on cranelift: 531 s then, 464 s now;
  - the Tcl subset: 180 s then, 167-173 s now.

## The front-end cache

* **A hit.**
  - It costs 0.02-0.19 s (median 0.04 s, traits.bot the most), 4.6 s over
    the corpus.
  - Of that, the profile puts 2.8 s in decoding, 0.6 s in the lookup's checks,
    0.6 s in reading files and 0.5 s in the fingerprint (5.7 ms once per
    process).
  - Entries: 88, 185 MB, median 1.6 MB, at most 6.3 MB. They keep
    `traitSource`.
* **A store.**
  - Its own cost is small: 5.6 s of encoding and 1.2 s of writing over the
    corpus.
* **The cost of a cold cache.** The store does slow what follows it in the
  same process.
  - With all four backends in one process, the specialized cranelift runs took
    512 s after a cold-cache build against 376 s after a plain one. A second
    profiled run gave 510 s; the other three backends did not move.
  - An A/B test in fresh processes (`experiments/store-effect.tcl`,
    struct-representation.bot, two alternating rounds) isolates it:
    `native::nir` took 13.4 and 15.5 s after a plain build, 16.8 and 18.5 s
    after encoding the HIR (no file written), and 17.9 and 19.0 s after a
    real store.
  - Encoding gives every nested value of the HIR a string representation. The
    specialization's copy-on-write copies of the HIR then carry those strings
    along. This is a likely mechanism, not a proven one.
  - A run that keeps one backend per process does not see it: the cold interp
    run was as fast as the run without the cache.
* **The Tcl layer.** The harness unsets the variable (tests/helpers.tcl), so
  that a developer's cache never decides what a test compiles.
  - The control run with it set ran in the ordinary time, and its cache
    directory stayed empty.
  - Even if it were allowed, the cache would reach only the programs compiled
    from files. The profile counts 2,769 such compilations, 83 s of the pass's
    634 s.
  - The source strings (`surface::compile`, 134 s) are not cached at all.
* **The key holds the path as given.** The same suite named by a relative path
  and by an absolute one makes two entries. The runner and the benchmark pass
  absolute paths.

## Where the time goes

Profiles: `prof-*` in the raw data. The "share" is of all process time.

### Golden, no cache

All four backends; the cold-cache run, so the build also stored its entry. It
took 3,846 s.

| top-level phase | s | share |
|---|---:|---:|
| front end (`golden::compile`: parse, lowering, static decisions, every build's analyses) | 1,485 | 38.6% |
| `compile` backend's runs | 1,002 | 26.1% |
| interp's runs (Core IR lowering, then the interpreter) | 749 | 19.5% |
| cranelift's runs (376 s without the store's effect: The cost of a cold cache) | 510 | 13.3% |
| cranelift-generic's runs | 92 | 2.4% |
| loading code, process start, the runner | 8 | 0.2% |

By self time:

* **`hir::affine::temporaries` is 1,519 s, 39.5% of everything.**
  - 964 s of the `compile` backend's 1,002 s;
  - 554 s of interp's 749 s.
* **Type inference** (`signatures`, which includes the typing walks and the
  semantic-instance walks it drives) is 572 s.
* **The rest of the front end:** semantic-instance verification 189 s,
  hygiene 168 s, the completion analysis 117 s, the static decisions 94 s,
  affine 60 s, static dependencies 45 s.
* **The native analyses:** specialization 228 s, block escape 154 s,
  range 94 s.
* **The interpreter's own run** is 190 s.
* **The native driver** (Cranelift code generation and execution, 169
  processes) is 14 s.

### Golden, warm cache

All four backends. The run took 1,547 s.

| top-level phase | s | share |
|---|---:|---:|
| `compile` backend's runs | 584 | 37.7% |
| interp's runs | 498 | 32.2% |
| cranelift's runs | 367 | 23.7% |
| cranelift-generic's runs | 85 | 5.5% |
| loading code | 5.3 | 0.3% |
| the cache hits | 4.7 | 0.3% |

By self time:

* **`temporaries`: 852 s, 55%.** 547 s of it under the `compile` backend and
  304 s under interp.
* **The interpreter's run:** 188 s.
* **The native analyses:** specialization 161 s, block escape 109 s,
  range 66 s.
* **Native code generation to NIR** (`native::lower::Function`): 49 s.
* **Everything else** is under 1% each.

The Tcl compiler's own work is small: code generation 8 s, block compilation
11 s, per-block lowering 12 s, its compiled runs 10 s. Its backend cost is
`temporaries`.

### The Tcl tests

The interp pass took 634 s profiled.

| top-level phase | s | share |
|---|---:|---:|
| front end from source strings (`surface::compile`) | 134 | 21.1% |
| native lowering (`native::lower::program`) | 122 | 19.3% |
| `core::evalProgram` (the interpreter, and every backend dispatched from it) | 113 | 17.8% |
| front end from files (`surface::readProgramFile`) | 83 | 13.0% |
| the native driver (6,776 runs, 11 ms each) | 66 | 10.5% |
| the Tcl compiler (code generation and runs) | 31 | 4.8% |
| golden runs inside golden-framework.test | 18 | 2.9% |
| Core IR lowering (`hir::lower`) | 14 | 2.2% |
| loading code | 11 | 1.7% |
| outside every phase (process start, tcltest, the tests' own Tcl) | 38 | 6.1% |

* **The front end is a third of the pass** (217 s): many small programs
  (6,186 analyzed builds), not a few large ones. Its biggest phases are `signatures`
  37 s, resolution 34 s, the completion analysis 25 s and parsing 23 s.
* **`temporaries` is only 37 s here**: the programs are small, so the
  quadratic walk stays cheap.
* **The `CORE_BACKEND=cranelift` pass has nearly the same profile**: 625 s;
  front end 212 s, native lowering 118 s, the interpreter 113 s, driver 66 s.
  The tests run their own backends.

### Process history

The backends' Tcl work is faster after a cache hit than after the front end.
The `compile` backend's runs took 999 s after a build and 554 s after a hit,
while the interpreter's run did not change (190 against 188 s self).

`experiments/hir-shape.tcl` runs the same lowering three ways:

1. over the HIR just built;
2. over the same HIR after an encode/decode round trip in the same process;
3. over the decoded HIR in a fresh process.

| suite | `hir::lower` (1) / (2) / (3) | `core::compiler::compileHir` (1) / (2) / (3) |
|---|---|---|
| struct-representation.bot | 24.8 / 22.3 / 16.1 s | 45.6 / 42.3 / 31.9 s |
| callables.bot | 11.6 / 10.4 / 7.9 s | 21.9 / 19.4 / 14.9 s |
| compiled-values.bot | 24.1 / 19.8 / 14.2 s | 47.7 / 40.7 / 28.3 s |

* **It is the process, not the value.** A round trip in the same process
  recovers 7-18%; a fresh process recovers 30-41%. Each pass's whole-program
  walk (`temporaries`) costs 7-9 ms in a fresh process and 13-16 ms after the
  front end.
* **It goes with the walk.** With `temporaries` memoized, the backends cost the
  same after a build as after a hit:
  - interp 191 against 204 s;
  - compile 28 against 29 s.

## What would remove the rest

* **Memoize `hir::affine::temporaries` per lowering.** This is the measured
  win, 44-52% of the golden corpus's CPU on all four backends.
  - The fix is a small change: compute it once per `hir::lower` and per
    `core::compiler::GenerateUnit`, which already computes it, and pass it
    to `hir::lower::Pending`.
  - The experiment (`experiments/memo-temporaries.tcl`) memoizes by the HIR
    value's identity. It ran the whole corpus on all four backends with the
    same 18,184 passing results and hit 719 of 720 calls on
    traits-path.bot.
  - It is an experiment, not a fix. A real fix changes `hir/lower.tcl` and
    `compiler/compiler.tcl`, and needs the affine and coroutine harnesses
    (AGENTS.md, "Affine values").
  - It could take up to 37 s (6%) off the Tcl layer, the whole of
    `temporaries` there.
* **Use the cache for backend work.** With `BOTLISH_HIR_CACHE` set, an edit to
  `compiler/` or `native/` reruns the golden corpus for 0.14-0.98 times the
  cost of the Tcl tests it duplicates.
  - With the memoization, all four backends cost about one Tcl pass (696
    against 643 CPU s).
  - Moving `hir/lower.tcl`, `hir/aot.tcl` and `hir/specialize.tcl` out of the
    fingerprint would extend this to edits of the HIR-to-Core-IR lowering and
    of the native specializer.
* **Keep the store from slowing the native lowering.** Two options:
  - return the HIR decoded from the entry it just wrote, which is what a
    later hit returns;
  - store after the backends have run.

  Either needs measuring. The cost today is 136 s of cranelift runs in a
  cold all-backend run; the cold run's whole extra cost is 116 CPU s, 3.1%.
* **The front end** is still the whole price of a cold run: 1,500 s, of which
  type inference is 572 s. Instance verification, hygiene and the completion
  analysis follow. The migration's compiler studies have the algorithmic fixes
  (LARGE-SCALE-GOLDEN-MIGRATION.md, "Compiler performance";
  COMPILER-BOTTLENECKS.md).
* **The specialized native lowering** (specialization 161 s and block escape
  109 s on a warm run) is the next backend cost once `temporaries` is fixed.

## Per suite

The golden suites against the Tcl tests they port, on interp. The comparison
reads:

* **Tcl cost:** a Tcl test's body time plus an equal share of its file's time
  outside test bodies. A test ported to several suites is divided among them,
  and counted in each.
* **"compile":** the suite's front end.

The 18 most expensive suites by golden cost; the full table, all 88 suites, is
in `audit/golden/out/golden-vs-tcl/report.md`.

| suite | golden tests | Tcl tests | Tcl cost s | golden s | of which compile | golden warm s | golden / Tcl | warm / Tcl |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| mutable-array.bot | 233 | 115 | 26.8 | 431.7 | 371.7 | 27.7 | 16.1 | 1.03 |
| destructuring.bot | 378 | 179 | 18.3 | 202.7 | 121.4 | 37.7 | 11.1 | 2.06 |
| compiled-values.bot | 118 | 95 | 50.2 | 121.6 | 62.0 | 44.0 | 2.4 | 0.88 |
| static-compile.bot | 81 | 58 | 9.1 | 93.3 | 78.3 | 10.4 | 10.2 | 1.14 |
| opaque.bot | 91 | 73 | 3.4 | 90.4 | 68.1 | 16.7 | 27.0 | 4.99 |
| methods.bot | 195 | 104 | 16.4 | 89.8 | 64.0 | 14.7 | 5.5 | 0.90 |
| structs-and-enums.bot | 111 | 77 | 5.5 | 81.4 | 69.5 | 7.5 | 14.7 | 1.35 |
| callable-contracts.bot | 92 | 79 | 18.2 | 78.3 | 61.4 | 8.2 | 4.3 | 0.45 |
| stdlib-namespaces.bot | 114 | 49 | 10.2 | 75.7 | 58.2 | 9.5 | 7.4 | 0.93 |
| range-and-contract-values.bot | 78 | 68 | 23.8 | 60.1 | 30.2 | 25.3 | 2.5 | 1.06 |
| refinements.bot | 66 | 52 | 5.0 | 58.8 | 49.3 | 7.2 | 11.7 | 1.43 |
| mutable-vector.bot | 74 | 41 | 15.4 | 56.4 | 44.5 | 8.2 | 3.7 | 0.53 |
| imports.bot | 59 | 36 | 3.4 | 55.8 | 49.4 | 2.5 | 16.4 | 0.73 |
| declared-errors.bot | 115 | 74 | 11.6 | 54.0 | 35.6 | 10.5 | 4.7 | 0.91 |
| traits.bot | 71 | 45 | 3.8 | 52.3 | 40.9 | 8.7 | 13.9 | 2.32 |
| callables.bot | 113 | 101 | 10.1 | 44.8 | 28.0 | 12.4 | 4.4 | 1.23 |
| coroutines.bot | 62 | 47 | 9.1 | 41.2 | 23.2 | 12.5 | 4.5 | 1.37 |
| contexts.bot | 88 | 49 | 10.1 | 40.9 | 26.6 | 8.7 | 4.0 | 0.86 |
| **all 88** | 4567 | 3289 | 686.3 | 2430.4 | 1637.6 | 518.9 | 3.54 | 0.76 |

* **How many suites are cheaper.** Of the 80 suites with Tcl originals, 8
  cost less than their Tcl tests without the cache, and 45 with a warm cache.
* **Where the front end dominates.** In the suites where golden costs most
  relative to Tcl, the front end is nearly everything: opaque.bot 27 times,
  mutable-array.bot 16 times, imports.bot 16 times. The cache brings them to
  5.0, 1.03 and 0.73 times.
* **Where golden is cheaper even without the cache.** Golden wins where the
  Tcl tests do heavy work per test, such as framework-semantics.bot against
  golden-framework.test (0.6 times, 0.06 warm), raw-int-abi.bot (0.7 times)
  and strings.bot (0.8 times).

## Reproducing

* **The matrix.** From the repository root, with the native backend built:
  `bash audit/golden/out/golden-vs-tcl/run-matrix.sh OUT SCRATCH`. It runs
  every run above in order, about four hours.
* **The report.** `tclsh9.0 bench/golden-vs-tcl.tcl report -out OUT` prints
  the tables. Over the raw data here, that is
  `-out audit/golden/out/golden-vs-tcl/runs`.
* **A single run**, for example the golden corpus on cranelift through a
  cache:
  `tclsh9.0 bench/golden-vs-tcl.tcl run -layer golden -backends cranelift -name NAME -out DIR -hir-cache CACHE`
* **Profiling any one process:**
  `tclsh9.0 bench/phase-profile.tcl OUT.prof tests/golden/run.tcl -quiet SUITE`
  (or a test file and its arguments).

## Files

* `bench/golden-vs-tcl.tcl`: the benchmark and its report.
* `bench/phase-profile.tcl`: the phase profiler.
* `audit/golden/out/golden-vs-tcl/`: the raw data.
  - `runs/*.runs`: one Tcl dict per process, with its profile for `prof-*`.
  - `runs/*.meta`: each run's settings and when it finished.
  - `report.md`: the full report over every run.
  - `hir-shape.txt` and `store-effect.txt`: the two experiments' output.
  - `native-coverage-ported.txt`: which ported Tcl tests run natively.
  - `run-matrix.sh`: the matrix.
  - `experiments/`: the experiments, which inject at load time and change no
    file.
