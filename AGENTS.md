# Notes for agents working in this repository

## Git workflow

Push finished work directly to `main`. This project does not use a
feature-branch-plus-pull-request review cycle: don't open a PR unless
explicitly asked to.

## Documentation layout

The root `README.md` is the project overview. Everything else is in `docs/`:
`docs/README.md` is the language and implementation reference (the former
root README), and every design document, milestone report and audit this
file names (`DIRECT-HIR-NATIVE-PATH.md`, `COROUTINES.md`, ...) is
`docs/NAME.md`, listed in `docs/INDEX.md`. Code comments, tests and the
documents themselves cite them by bare name too. A comment citing "README
§N" or a README section by name means `docs/README.md`, unless it sits
beside a README of its own (`tests/golden/README.md`, an `audit/`
directory's). A new design document goes in `docs/`, with a line in
`docs/INDEX.md`, never in the repository root; a link in one to a file
outside `docs/` starts with `../`.

## Compiler architecture (three representations)

* **HIR** (`hir/`) is the authoritative semantic representation; every analysis
  fact lives in it or in its side tables.
* **Core IR** (`core/`) is the small executable representation of the Tcl
  reference interpreter. HIR lowers to it (`hir::lower`); neither compiler
  compiles from it.
* **The Tcl compiler** (`compiler/`) compiles HIR as a front end built it
  (`core::compiler::evalHir`, or `compileHir` once and `evalUnit` per run). Its
  core IR entry points (the registered `compile` backend through
  `core::evalProgram`; `generatedCode`, `programTypes`, `bindingTypes`,
  `unitHir`) are for core IR *text* someone wrote, which `hir::build` reads
  into HIR. Never hand them the output of `hir::lower` for a HIR you have:
  that rebuilds a weaker HIR (no declared types, module identity, `errors`
  clauses). Compile the HIR (`tests/direct-hir-native.test`'s
  `direct-hir-compile-*` tests guard this; DIRECT-HIR-NATIVE-PATH.md, "The
  Tcl compiler compiles HIR").
* **NIR** (`native/`) is the production executable representation. Native
  compilation starts from resolved, analyzed HIR (`native::lowered`,
  `native::evalHir`, `native::executable`, ...) and never goes through Core IR:
  do not add a native entry point that accepts Core IR, and do not lower HIR to
  Core IR and rebuild HIR from it (`tests/direct-hir-native.test` guards this).
  `DIRECT-HIR-NATIVE-PATH.md` has the details. Tests that run Core-IR-text
  programs on `cranelift` or `compile` do so through harness backends in
  `tests/helpers.tcl` that hand the compiler the HIR the program was lowered
  from (or read hand-written IR text into HIR); they are not production entry
  points.

## Compilation isolation

A compilation registers its declarations in process-wide registries that the
analyses and the backends read by bare name: the source-defined entries of
`core::type` (a domain or a refinement; a type registers no native),
`hir::structs`, `hir::enums`, `hir::errordecls`, `hir::traits`,
`hir::imports` and `hir::layouts`. Every HIR records the state its build left behind (its
`declarations` side table, `hir/declarations.tcl`), and every entry point that
reads the registries for a HIR it is given calls `hir::activate` first, so
compiling another program never changes an earlier HIR's lowering or run
(COMPILATION-ISOLATION.md). Two rules keep it so:

* A new registry -- process-wide state a build fills from the program's
  declarations and something reads later -- goes into
  `hir::declarations::capture` and `Install`.
* A new entry point that reads the registries for a HIR it is given (a
  backend, an analysis a tool calls, a printer) calls `hir::activate $hir`
  before reading anything. Code that writes the registries (a build, a read
  of HIR text) calls `hir::declarations::invalidate` first and stamps the
  HIR it returns.

If you change either, or what a build or `hir::read` registers, run
`tests/compilation-isolation.test`,
`audit/compilation-isolation/tools/interleave.tcl` (every golden suite's
artifacts and outcomes, right after its own compilation and after all the
others, must be identical) and `audit/compilation-isolation/tools/mutate.tcl`
(every mutant in its `mutants.txt` must still apply and be killed). Core IR
text has no declarations: core IR kept and run on a Tcl backend after another
compilation still reads the later one's (run a HIR, or lower it again).

## HIR interchange

`hir/interchange.tcl` (HIR-INTERCHANGE.md) writes an analyzed HIR as text --
`main.tcl -emit-hir-interchange` writes `FILE.hirx`, which `main.tcl` runs on
any backend -- and reads it back in any process with the same front end, as if
it had just been built. It holds the HIR dict itself (minus `traitSource`)
and relies on compilation isolation for the rest: everything a backend reads
must be in the HIR, its side tables or its `declarations`. So a new fact a
backend reads from process state, rather than from the HIR, breaks it the way
it breaks isolation. Text is valid for the front end that built it only (a
fingerprint of `core`, `hir`, `surface` and lib's Tcl libraries; the backends
are left out because they never shape a HIR -- keep it so: a backend must not
define or change a front-end procedure or register a type or native). Never
add a way to skip that check or to read another front end's text; a front end
written in Botlish needs a specified schema and a validating reader first (a
format version 2).

The front-end cache (`surface/cache.tcl`, opt-in through `BOTLISH_HIR_CACHE`
or `surface::readProgramFile -cache DIR`; the test harness unsets the
variable) keeps program files' HIRs in that format. A hit must equal the
build, so the key and the dependencies must hold everything a build reads: if
the front end starts reading another input -- an environment variable, a file
other than an imported module, an option of `compileProgramFile` -- add it to
`surface::cache::Key` or `Dependencies`, never leave it out.

If you change what a backend reads, the HIR's side tables, the format, the
cache or what the front end reads, run `tests/hir-interchange.test`,
`tests/hir-cache.test`, `audit/hir-interchange/tools/roundtrip.tcl` with
`-via interchange` and `-via cache` (every HIR, artifact and outcome of the
suites, written and then read by a fresh process that runs no build, must be
identical; `-suites all` for the whole corpus) and
`audit/hir-interchange/tools/mutate.tcl` (every mutant in its `mutants.txt`
must still apply and be killed: update a mutant's text when you change the
code it mutates, keeping it a mutant of the same rule).

## Installing Tcl 9

This project's reference evaluator requires Tcl 9.x (`core/core.tcl` checks
this at load time and refuses to run under older Tcl versions, since
Botlish's String semantics count Unicode scalar values, and older Tcl builds
cannot represent astral characters correctly). The canonical baseline for
this repo is `tclsh9.0`.

Do **not** build Tcl 9 from source (slow, and easy to get subtly wrong).
Instead, install it exactly the way `.github/workflows/tests.yml` and
`.github/workflows/bench.yml` do: three `.deb` packages pulled straight from
Ubuntu 25.04 (plucky)'s universe pool, installed with `dpkg -i`:

```sh
set -eu
cd /tmp
base=http://archive.ubuntu.com/ubuntu/pool/universe
curl -fsSLO "$base/libt/libtommath/libtommath1_1.3.0-1_amd64.deb"
curl -fsSLO "$base/t/tcl9.0/libtcl9.0_9.0.1+dfsg-1_amd64.deb"
curl -fsSLO "$base/t/tcl9.0/tcl9.0_9.0.1+dfsg-1_amd64.deb"
sudo dpkg -i libtommath1_1.3.0-1_amd64.deb libtcl9.0_9.0.1+dfsg-1_amd64.deb tcl9.0_9.0.1+dfsg-1_amd64.deb
echo 'puts "Tcl [info patchlevel], tcltest [package require tcltest 2.5]"' | tclsh9.0
```

On arm64 the same three packages, with `arm64` for `amd64`, come from
`http://ports.ubuntu.com/ubuntu-ports/pool/universe` (`.devcontainer/setup.sh`
picks by `dpkg --print-architecture`).

This installs the `tclsh9.0` binary and it is the canonical baseline for
this repo. Use `tclsh9.0` to run everything in this repo (`tests/all.tcl`,
`main.tcl`, `bench/*.tcl`, etc.), matching CI.

Also set `LANG=C.utf8 LC_ALL=C.utf8` (glibc ships `C.utf8` built in, no
`locale-gen` needed): Tcl 9's I/O encoding profile is strict by default,
and with no locale the system encoding falls back to `iso8859-1`, which
makes writing non-ASCII/astral output fail outright instead of being
silently mangled.

### Known Tcl core bug: compiled `incr` wraps instead of promoting at the i64 boundary

Confirmed directly (BYTE-NIBBLE-BIT-ARITHMETIC.md's own account has the full
trace) and **still present as of Tcl 9.0.4 and the 9.1a1 alpha** -- not
fixed upstream, so there is currently no newer version to pin instead.
A minimal standalone reproduction, for filing an upstream bug report, is
committed at `tcl-incr-i64-wrap-bug.tcl` (run with `tclsh9.0
tcl-incr-i64-wrap-bug.tcl`):

```tcl
proc p {} { set v 9223372036854775807; incr v; return $v }
puts [p]   ;# -9223372036854775808 -- WRONG (silently wraps)

set v 9223372036854775807
incr v
puts $v    ;# 9223372036854775808  -- correct (typed at tclsh's own top level, not compiled)
```

`incr` as it runs inside a compiled `proc` (`generic/tclExecute.c`'s
`INST_INCR_SCALAR1_IMM`/`INST_INCR_SCALAR_IMM` handler) computes the
overflow-detecting sum correctly, but on the *overflow* branch re-derives
the result via plain `Tcl_WideInt` addition (`TclNewIntObj`/`TclSetIntObj`
with `w + increment`) instead of promoting to a bignum -- the exact
computation that just overflowed, repeated, then stored as if it hadn't.
Verified via direct source diff across `core-9-0-1`, `core-9-0-2`,
`core-9-0-3`, `core-9-0-4` and `core-9-1-a1` (github.com/tcltk/tcl): the
relevant lines are byte-for-byte identical in every one of them; none of
their release notes mention it. `incr` typed directly at tclsh's
interactive top level (uncompiled) is unaffected -- only code inside a
`proc`, where bytecode compilation applies, hits this.

**Practical consequence for any code in this repo**: never use `incr` in a
loop whose counter could plausibly reach `i64::MAX`/`i64::MIN`
(9223372036854775807 / -9223372036854775808) -- use
`set v [expr {$v + 1}]` instead, which correctly uses Tcl 9's ordinary
arbitrary-precision `expr` arithmetic. Botlish's own `Int` is
arbitrary-precision (this project's whole point), so any Tcl-side loop that
iterates over or reconstructs a range of Botlish Int values is a candidate
for this -- `hir/range.tcl`'s `ExactOf` hit it exactly this way; see that
file's own comment.

**Do not "fix" this by pinning a newer Tcl 9**: no released or alpha
version fixes it (checked above), and the Ubuntu packages newer than
`9.0.1+dfsg-1` (`9.0.2`, `9.0.3`, `9.0.4`, all still in the same `universe`
pool path) require `glibc >= 2.42`, which this sandbox's (and, as of this
writing, GitHub Actions' `ubuntu-latest`) base image does not have --
installing one over `9.0.1` breaks `tclsh9.0` outright (`GLIBC_2.42' not
found`) until it's downgraded back. `9.0.1` remains the correct pin for
both this reason and because it is not actually behind on this specific
bug.

## Building the native (Cranelift) backend

`cargo build --release --manifest-path native/Cargo.toml` needs a rustc new
enough for the pinned `cranelift-*`/`wasmtime-internal-*` crates (rustc
1.95+; the sandbox's preinstalled toolchain can be older and will fail with
"is not supported by the following packages"). Fix with:

```sh
rustup toolchain install stable --profile minimal
rustup default stable
```

then build as usual. Without this, `cranelift`/`cranelift-generic` tests
and benchmarks report `{error {NATIVE NOT-BUILT}}` instead of running.

## The single-file compiler and the stub linker

`single/build.sh` builds `single/out/botlish` (SINGLE-EXECUTABLE.md): a Tcl 9
zipkit holding main.tcl, the compiler stack and both native executables,
needing only glibc. The workflow `.github/workflows/single-executable.yml`
builds it on every push to `main` and smoke-tests it in stock Ubuntu
containers (`single/smoke-test.sh`). Its base kit is a static tclsh that the
script builds once from the pinned Tcl 9.0.1 source release. That build is
the one exception to "do not build Tcl 9 from source" above: no package ships
a static zipfs tclsh. `--basekit PATH` uses a prebuilt zipkit instead. To run
the test suite, still install the `.deb`s.

* `single/package.tcl` packs exactly main.tcl, LICENSE, `core/`,
  `compiler/`, `hir/`, `surface/`, `native/*.tcl`, `lib/` and
  `examples/*.ir`. If the compiler starts reading another file at run time,
  add it there. Never make main.tcl or the compiler depend on the single
  executable: `single/main.tcl` only sets the environment and sources
  main.tcl unchanged.
* Standalone executables have two linkers, chosen by `BOTLISH_NATIVE_LINKER`:
  `rustc` (the default) and `stub` (no toolchain: `botlish-aot-stub` with the
  program image appended, `native/src/runtime/aotimage.rs`; the single
  executable uses it). A test that reads a rustc-linked executable's
  `botlish_fn_N` symbols (objdump, `strace -k`) or tests rustc's invocation
  carries the `rustcLinker` constraint (`tests/helpers.tcl`). CI's
  `stub-linker` job runs every executable test file with the stub linker.
* The two startups must build the Vm identically: the generated startup crate
  (`codegen/aot.rs`'s `startup`) and `aotimage::Loaded::instantiate`. If you
  change either, `runtime::aot::run`, `constants::install`, what
  `emit_object` emits (sections, relocation types: `codegen::aot::image`
  rejects any type it does not handle), the image format, or the ABI
  fingerprint's inputs, run `cargo test --release --manifest-path
  native/Cargo.toml --lib aotimage`, `tests/aot-stub-linker.test`, and the
  executable test files with the stub linker. The `stub-linker` job in
  `.github/workflows/tests.yml` has the command. Run them once more under
  `BOTLISH_NATIVE_GC_STRESS=1`.

## Running the tests locally

Run the tests locally with `tclsh9.0 tests/local.tcl`, not `tests/all.tcl`.
It runs, in parallel (`-jobs N`, default the processor count; one process
per test file or suite, each with a private `-tmpdir`):

* **every Tcl test file on interp and compile** (`-backends`; CORE_BACKEND
  when set), minus the Tcl tests a golden test duplicates: the ones the
  manifest classifies FROZEN-DUPLICATE-ORACLE (`tests/golden/manifest.tsv`'s
  `freeze` column; LARGE-SCALE-GOLDEN-MIGRATION.md, "Freeze
  classification"), whose whole theorem golden tests carry on every backend.
  They are reported skipped, by the constraint `goldenDuplicate`
  (`BOTLISH_SKIP_GOLDEN_DUPLICATES=1`, tests/helpers.tcl). Everything Botlish
  source cannot express keeps running in Tcl: compiler and runtime internals,
  the parser, warnings, several programs, `main.tcl`, executables and the
  process boundary, run-time-only failures, the internal half of every SPLIT
  test, and every Tcl test whose golden port is weaker;
* **every golden suite on all four backends**, in their place, **through the
  front-end cache** (`.hirx` entries; HIR-INTERCHANGE.md).

It prints a line per file and suite, then every failure with the command
that reruns it, and exits 1 on any.

What it costs, measured on a 4-core container (2026-10-15):

| run | wall | CPU |
|---|---:|---:|
| `tests/local.tcl`, warm cache | 26 min | 6,060 s |
| `tests/local.tcl`, empty cache | 33 min | 7,710 s |
| `tests/all.tcl` (every Tcl test, one file at a time) | 93 min | 5,590 s |
| every Tcl test at the same parallelism (`tests/local.tcl -all 1 -parts tcl`) | 26 min | 6,100 s |

* **The speed-up over `tests/all.tcl` (93 minutes to 26-33) is the
  parallelism.**
* **The golden layer is free once the cache is warm.** The 2,043 duplicated
  Tcl tests cost about 600 s of process time per run (both passes). The
  golden corpus on four backends costs 630 s with a warm cache and 2,160 s
  with an empty one.

* **Narrow it to what an edit touches.** `tclsh9.0 tests/local.tcl
  tests/affine.test tests/coroutines.test` runs those files minus their
  duplicated tests, plus the golden suites that hold those tests'
  replacements, so the run still covers what the files covered. A `X.bot`
  argument runs that suite; `-parts tcl` or `-parts golden` runs one layer.
  - With an empty cache the golden front ends are most of a narrow run's
    cost: those two files took 35 s this way, against 14 s run directly on
    interp.
  - So, while iterating on one area, `tclsh9.0 tests/X.test` (every test of
    the file) is the quickest check. Run `tests/local.tcl` (narrowed, or
    whole) before pushing.
  - The test files, fuzzers and mutation harnesses the sections below name
    for an area are run as named.
* **Run the golden suites with the front-end cache.** `tests/local.tcl`
  always does, unless told not to.
  - **Which directory:** `BOTLISH_HIR_CACHE` when set; otherwise this
    checkout's own directory under the user's cache directory
    (`~/.cache/botlish/hir/`, or `$XDG_CACHE_HOME`, or `%LOCALAPPDATA%`). The
    run then removes the entries another front end wrote, so the directory
    stays at one front end's worth (about 190 MB).
  - **Why it pays:** a suite whose text, imported modules and front end
    (`core/`, `hir/`, `surface/`, lib's Tcl libraries) are unchanged is read
    from its entry, not compiled again. The key leaves out `compiler/` and
    `native/`, so after an edit there the golden corpus costs only the
    backends' runs, a fraction of the Tcl tests it replaces
    (GOLDEN-VS-TCL-BENCHMARK.md). A hit equals the build exactly (the cache
    is audited for it).
  - **One suite:** run a single golden suite the same way with
    `tclsh9.0 tests/local.tcl SUITE.bot`, not a bare
    `tests/golden/run.tcl`, which uses no cache unless `BOTLISH_HIR_CACHE`
    is set.
  - **Opting out:** `-hir-cache ""` turns the cache off, for timing the
    front end.
  - **The Tcl tests never use it,** and neither does CI: every CI run
    compiles from scratch.
* **When a golden test fails,** its Tcl originals are its manifest rows
  (`old_file`, `old_test`). `tclsh9.0 tests/X.test` runs every test of a
  file, and `tests/local.tcl -all 1` runs every Tcl test, duplicates
  included, as CI does.
* **CI runs every test, every time:**
  - the whole Tcl suite, duplicates included, on interp and compile;
  - its coverage on cranelift and cranelift-generic;
  - every golden suite on every backend beside its Tcl originals
    (`audit/golden/tools/check.tcl`);
  - the native Rust unit tests;
  - the stub-linked executables;
  - the warning gate;
  - on pushes to main, the GC-stress run;
  - on Linux arm64 (`.github/workflows/tests-arm64.yml`, ubuntu-24.04-arm):
    the Tcl suite on interp and compile, its cranelift and cranelift-generic
    coverage, the golden suites, the native Rust unit tests (also under GC
    stress) and, except on pull requests, the GC-stress run. Run it on a
    branch with workflow_dispatch.

  Never set `BOTLISH_SKIP_GOLDEN_DUPLICATES` or run `tests/local.tcl` in a
  workflow: `tests/golden-duplicates.test` fails if one does.
* **The skipped set is the manifest's, never a list kept by hand.** A Tcl
  test leaves it when its port is reclassified, through the census and the
  fragments (Golden tests, below).

## Running Linux tests from Windows with WSL

The Windows development machine has an Ubuntu 24.04 WSL distribution with
the repository toolchain already installed. Run Linux-native validation from
PowerShell through that distribution, using the mounted Windows checkout:

```powershell
wsl.exe -d Ubuntu-24.04 -- bash -lc 'cd /mnt/c/Users/MarkusWagner/dev/botlish && export LANG=C.utf8 LC_ALL=C.utf8 && tclsh9.0 tests/local.tcl'
```

The WSL checkout is the same working tree as the Windows checkout, not a
separate clone. Check `git status` before running tests and do not stash or
discard changes merely to switch environments.

## Running tests concurrently

Two test runs that share a working directory or a checkout interfere unless
each has its own tcltest temporary directory, and the failures look like real
bugs (`couldn't open ".../contexts-scratch/p79.bot": no such file or
directory`). This covers an agent parallelizing its own runs, two sessions in
one checkout, and a Windows run beside a WSL run (same tree, above). What is
shared (TEST-SUITE-COST.md section 4 has the measurements):

* **tcltest's temporary directory is the current working directory** unless
  `-tmpdir` is given. Test files create fixed-name scratch directories in it
  (`abi-bytes-scratch`, `argv-aot`, `contexts-scratch`, ...) and delete or
  sweep them, so two runs of the *same* test file with one temporary directory
  delete each other's files. Pass a private absolute directory:
  `tclsh9.0 tests/all.tcl -tmpdir /tmp/run-A ...` (tcltest forwards it to
  every per-file child process). *Different* test files sharing one
  temporary directory, two or three at a time, ran the whole suite cleanly.
  `tests/native-coverage.tcl` gives the suite it runs a private `-tmpdir` (and
  keeps its log there) by itself.
* **`native/target/release`.** Every native test runs `botlish-native` from
  there, and the executable (AOT) tests link `libbotlish_native.rlib` at test
  time. A `cargo build` during a run swaps them under it. A copied tree needs
  all of `native/target` (a symlink to the original works); a copy with only
  the binary fails every AOT test with `runtime library missing`. A symlink
  is only for a tree nothing rebuilds: the mutation harnesses whose private
  tree rebuilds the native backend (`audit/*/tools/mutate.tcl` with a native
  mutant selected, `audit/golden/tools/tree.tcl`) copy the directory a linked
  `native/target` points to, never the link (a copied link builds every
  mutant into the original checkout's `native/target`), and a new one must
  too.

So for concurrent runs in one checkout: one `-tmpdir` per run, and no native
rebuild until they finish:

```sh
export LANG=C.utf8 LC_ALL=C.utf8
CORE_BACKEND=interp tclsh9.0 tests/all.tcl -tmpdir "$(mktemp -d)" &
CORE_BACKEND=compile tclsh9.0 tests/all.tcl -tmpdir "$(mktemp -d)" &
wait
```

A run started from the repository root without `-tmpdir` and interrupted
leaves its scratch directories in the working tree: check `git status` before
committing.

Outside its tcltest temporary directory, nothing a test does may use a fixed
name; new tests and tools must keep it that way:

* A test that needs a throwaway module next to the standard ones wraps its
  body in `withPrivateLibrary` (`tests/helpers.tcl`), which points
  `$::core::libraryDir` at a per-process copy of `lib/` in the tcltest
  temporary directory. Never write into the real `lib/`.
* A script or audit tool keeps its scratch files in a `file tempdir` directory
  (or under a name with `[pid]`) and removes it when it finishes, never under a
  fixed name in the working directory or the repository; one that runs a test
  file passes it a private `-tmpdir`.

## Native GC-stress validation

`BOTLISH_NATIVE_GC_STRESS=1` forces a GC attempt at every allocation site,
which is how native stack-walking/root-tracking bugs get caught. This used
to be a manual step agents were required to run locally on every relevant
change; it is no longer mandatory by hand. It now runs automatically in CI
on every push to `main`, as the `gc-stress` job in
`.github/workflows/tests.yml`.

Before touching anything in `native/` that affects stack walking, roots, or
allocation (GC, stack maps, escape analysis, block/root storage), check
whether the most recent `gc-stress` run on `main` passed. A prior failure
there is a standing signal worth reproducing and fixing, not something to
work around.

Agents are not restricted from running GC-stress locally as well, on top of
what CI covers — do so whenever it's diagnostically useful (e.g. to
reproduce a CI failure, or to validate a stack-walking change before
pushing). To run it locally on Linux, build the release backend and run the
suite with stress enabled:

```sh
export LANG=C.utf8 LC_ALL=C.utf8 BOTLISH_NATIVE_GC_STRESS=1
cargo build --release --manifest-path native/Cargo.toml
tclsh9.0 tests/all.tcl
```

From Windows, run the same thing inside WSL for Linux GC-stress results
when validating native stack walking (Windows-native execution exercises a
different stack/guard implementation):

```powershell
wsl.exe -d Ubuntu-24.04 -- bash -lc 'cd /mnt/c/Users/MarkusWagner/dev/botlish && export LANG=C.utf8 LC_ALL=C.utf8 BOTLISH_NATIVE_GC_STRESS=1 && cargo build --release --manifest-path native/Cargo.toml && tclsh9.0 tests/all.tcl'
```

## Compiler warnings

Warnings (`hir/warnings.tcl`, WARNINGS-SAME-RETURN.md) are on by default and
have exactly one global policy per compilation: `-warnings default|off|error`
(`surface::compile`/`readProgramFile`, `main.tcl`). There are deliberately no
`-Wfoo` switches, groups, levels or source suppression: don't add them, and
don't add a warning that is not backed by a compiler proof. The test harness
(`tests/helpers.tcl`) sets `BOTLISH_WARNINGS=off` as the process default,
because tcltest counts stderr output as a test-file error; `tests/warnings.test`
passes its policy explicitly on every compile. Benchmark and analysis scripts
that compile corpus sources pass `-warnings off` themselves.

`METHOD-ELIGIBLE` (WARNINGS-METHOD-ELIGIBLE.md) is backed by a checked proof,
the round-trip law: the sugared spelling of every call it reports must parse,
resolve to the same callee and compile to the same program. If you change
method sugar, the resolver's candidate gathering or what the frontend records
in a call's `written` marker, run `tests/method-eligible.test` and
`audit/method-eligible/tools/fuzz.tcl`. `nomethod fn` is a declaration by the
function's author that method syntax to it is an error; it is not a warning
suppression, and there is still no call-site suppression to add.

`FIXED-ARITY-LIST-RETURN` (WARNINGS-FIXED-ARITY-LIST-RETURN.md) reads the
frontend's `written {form list}` provenance, milestone 1's exit enumeration
(`Exits`/`Leaves`) and completion walk, `hir::exact::AliasRoot`,
`hir::resolve::CandidateIdentity` and the block's `declaredResult`. If you change
any of those, or how a list literal, an else-less `if` or a result annotation
lowers, run `tests/fixed-arity-list-return.test` and
`audit/fixed-arity-list-return/tools/fuzz.tcl`. A list-typed result annotation
(`-> list`, `-> List[T]`) is a real type the checker proves, not a suppression;
do not add another opt-out (MULTI-VALUE-RESULTS.md). Library
modules' own findings print for every program that loads them, so tests that
import `lib/*.bot` and assert on a complete warning set filter by code or file.
Since the warning-driven refactor (next section) only three modules carry any,
all `ONE-CHAR-STRING-LITERAL` and all listed in `audit/refactor/manifest.txt`:
`lib/web.bot` 23 (its hex-digit table, `"%"`, and the local-part and label
classes), `lib/io.bot` 2 (`"\n"`) and `lib/linux/path.bot` 2 (`"/"`). Every
other module is warning-clean.

`SAME-FAILURE` (WARNINGS-SAME-FAILURE.md) reads the `fail` sites of a function's
own body (milestone 1's `BodyExprs`, which never enters a nested function), each
`fail` node's `name` and `reachable` flag, the block's resolved `declaredErrors`,
the canonical module-qualified error identities (`hir/errordecls.tcl`) and the
completion walk (`hir::completions::reachedExprs`, which records `fail` sites
and never enters a nested function either). If you change any of those, or how
`fail`, `errors` or an on-handler body lowers or resolves, run
`tests/same-failure.test` and `audit/same-failure/tools/fuzz.tcl`.

`PROVES-NAMING` (WARNINGS-PROVES-NAMING.md) reads, per function declaration, the
block's resolved proof contract (`proofs`, `hir/resolve.tcl`'s
`ResolveProofs`), its `params` minus its `flags`, its `declaredResult`, and the
declaring binding's written name (hygiene's recorded `spelling`, else the name
without a `#N` suffix, then `hir::warnings::MemberName` for a module's
qualified spelling). It runs no walk and reads no reachability. If you change
the proof-clause grammar or validation, how a declared result or the flag
section is recorded, hygiene's renames (`hir/hygiene.tcl`: `spelling`,
`qualifyModules`), or the naming convention in REFINEMENT-VALUES.md ("Naming"),
run `tests/proves-naming.test` and `audit/proves-naming/tools/fuzz.tcl`. The
response to this warning is a rename; do not add an opt-out, a reverse rule
(`?` implies bool) or a check on functions without `proves`.

`ONE-CHAR-STRING-LITERAL` (WARNINGS-ONE-CHAR-STRING-LITERAL.md) reads, per
`const` node, its exact value (`hir::exact::Of`: exact String values) and
measures it with the reference `str::length` (`core::strings::length`); the one
String const the frontend synthesizes, a context parameter's
`context#load("ID")` key, is recognized by `hir::contexts::isLoad` and never
reported. If you change how a String or character literal lexes, lowers or reads
back from HIR text, the exact value of a constant, `str::length`, or build a
String const anywhere in the frontend (`tests/one-char-string-literal.test`'s
`oc-synthesized-string-consts-enumerated` lists every place that does), run
`tests/one-char-string-literal.test` and
`audit/one-char-string-literal/tools/fuzz.tcl`. The warning is context-blind and
not autofixable on purpose: do not add a context gate, an opt-out, the
character spelling to its message or data, or a fixit.

`MANY-BOOLEAN-ARGUMENTS` (WARNINGS-MANY-BOOLEAN-ARGUMENTS.md) reads, per call,
the frontend's `written` provenance (`function`/`method` only), the call's
`reachable` flag and `args`, the callee reference resolved through aliases by
`hir::resolve::CandidateIdentity` to a declaring `bind` of a block (or a root
native and its registry `paramTypes`), the block's `params` minus its `flags`,
and the parameter types the checker proves (`hir::signatures::entryTypes`:
declared, else the TRUSTED inferred contract -- never a CHECKED one). Its
evidence is an argument that is a reference to the root `true` or `false`,
which is how the frontend lowers those keywords; flag arguments are the
trailing `bool` constants hir/flags.tcl appends and are never read. If you
change call provenance, how `true`/`false` or a call's arguments lower, the
flag transport (`hir::flags::ResolveCall`), alias resolution, the trusted /
checked split of `hir/signatures.tcl`, or a native's parameter types, run
`tests/many-boolean-arguments.test` and
`audit/many-boolean-arguments/tools/fuzz.tcl`. The warning counts literals
only and is not autofixable on purpose: do not count flags, bindings or
computed bools, follow exact values, group per callee, warn on a declaration
without call evidence, print a flag spelling, or add a fixit or an opt-out
(FLAGS.md, "Boolean arguments", records the graduation criteria).

## The warning gate

The shipped stdlib, libraries, examples and benchmarks compile clean under
Botlish's own warnings, except exactly the findings `audit/refactor/manifest.txt`
lists, each with the obstruction that keeps it open (REFACTOR-WARNINGS-CLEAN.md).
`audit/refactor/tools/gate.tcl` checks it -- every corpus program and a one-line
loader per library module, the observed warnings equal to the manifest (code
and location), and every program and loader without an entry compiling under
`-warnings error` -- and the `warning-gate` job of `.github/workflows/tests.yml`
runs it on every push and pull request (`tests/warning-gate.test` pins that it
passes and that it fails on a planted warning).

If you add or change a program in `examples/`, `bench/` or `lib/`, run
`tclsh9.0 audit/refactor/tools/gate.tcl`:

* A new warning is answered in the code -- convert it, annotate the result
  type, merge the exits or guards, or mark the callee `nomethod` for a stated
  reason -- never by adding a manifest entry. The manifest grows only at a
  re-audit that names an obstruction no mechanism of the language closes, per
  finding.
* An entry leaves the manifest when its finding closes, with the closing
  verified: `audit/refactor/tools/probe.tcl` (behavior probes against the tree
  before the change, every backend) and `audit/refactor/tools/expect.tcl`
  (every `# expect:` value, every backend).
* A manifested literal that moves (a line added above it) is a location drift
  the gate reports: update its line and column in the manifest.
* A new corpus program must be listed (with its entries, if any).
* Do not edit `audit/refactor/kickoff-corpus/`: it is the frozen,
  warning-bearing fixture the backend-independence CLI tests (and one
  String-region test of the `peek()` idiom) read, not corpus.

## Refinement values

`refined type NAME = CARRIER` and `proves PARAM: NAME` (REFINEMENT-VALUES.md)
are generic: no compiler or runtime file may name a corpus refinement or its
predicate (`tests/refinement-values.test` greps for `Emailish`,
`UriQueryValue`, `emailish?`, `uri_query_value?`), and a refined value has
exactly its carrier's representation -- never add a runtime tag, wrapper or
check to recover one. If you change the proof contract resolution
(`hir/resolve.tcl`'s `ResolveProofs`), implications, call keys or a
validator's completion facts (`hir/refine.tcl`), the `if` join, the
decided-call rule or how a call's completion facts flow and a handled call
joins its handlers (`hir/types.tcl`'s `Call` and `Handle`), repeatability
(`hir/repeatable.tcl`), a native's `-context-free` classification, or how
`-> unit` and a proof clause parse, run `tests/refinement-values.test`,
`tests/refinement-validators.test`, `tests/emailish-predicate.test` and
`audit/refinement-values/tools/fuzz.tcl` (validators are on by default;
`-validators 0` reproduces the predicate-only generator's runs).

## No type is callable

No type declaration makes the type callable or gives it a predicate
(ELIMINATE-AUTOMATIC-TYPE-PREDICATES.md): `T`, `T(x)`, `T?`, `ns::T?` and
`x.T?()` are unknown names unless the program declares a function of that
name. An integer domain is entered through an ordinary converter (a function
whose declared result is the domain, checked like any result) or admitted
by comparisons, whose range facts both analyses derive through `and`, `or`
and `not` (`hir::range::Paths`/`OutcomeFacts`); a refinement through its
owner's `proves` predicates and validators. A Range proves a domain, never a
refinement (`hir::range::ProvesType`). Never register a native, a value or a
method candidate from a type declaration, never resolve a missing name by
its spelling (`NAME?`), and never lower a native by a type's name;
`-tests-type` is for explicitly registered type tests (the kind and Result
tag tests), never of a refinement. If you change type-declaration
registration (`hir/sourcetypes.tcl`), the resolver's or loader's handling of
an unknown name, `Paths`/`OutcomeFacts`/`ProvesType`, or the completion
analysis's `BranchOutcome`, run `tests/type-predicates.test`,
`audit/refinement-values/tools/fuzz.tcl -domains 1` (several seeds) and
`audit/type-predicates/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed: update a mutant's text when
you change the code it mutates, keeping it a mutant of the same rule).

## Branch-form Boolean conditions

An `if` condition is lowered as a branch, not as a Bool to branch on
(BRANCH-FORM-BOOLEAN-LOWERING.md). `hir/condition.tcl` states, once, which
expressions have a branch form -- the root Booleans and the `if`s `and`,
`or`, `not` and `!=` lower to (surface/lower.tcl) -- and the two compilers
emit it: the Tcl compiler's `CompileCondition` as one Tcl test built from
`&&`, `||`, `!` and `?:` (an operand's code inside its side, a command
substitution), native lowering's `Condition` as branches to the `if`'s two
arms (`StaticOutcome` applies M6's range-decided rule through the Boolean
structure; `BranchDemand` lets an inlined region consumer branch itself).
It changes representation only: every operand runs where, and only where,
its value form runs it, once, in order. HIR is unchanged (no branch node,
flag or side table), the interpreter evaluates conditions as values, and a
Bool used as a value is still built. Never add backend-specific Boolean
semantics, a Boolean node to HIR or Core IR, a peephole over materialized
Bools, or proof reasoning to the lowering (`hir::range::Paths` stays the
analyses', with its own budget; the lowering has none).

If you change `hir/condition.tcl`, the compilers' condition lowering
(compiler/compiler.tcl's `CompileIf`, `CompileCondition`, `ConditionIf`,
`ConditionBranch`, `BoolResult`; native/lower.tcl's `If`, `Condition`,
`ConditionIf`, `ConditionBody`, `BodyTarget`, `StaticOutcome`,
`BranchDemand`, `EmitRegionConsumerCondition`), how `and`/`or`/`not`/`!=`
lower, the releases after a branch's statements, or region-consumer
inlining, run `tests/branch-form-boolean.test`, its golden suite
(`tclsh9.0 tests/local.tcl tests/golden/branch-form-boolean.bot`) and
`audit/branch-form-boolean/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed: update a mutant's text when
you change the code it mutates, keeping it a mutant of the same rule).
`bench/branch-form-boolean.tcl` regenerates the performance report
(`-root DIR` measures another checkout; `-programs FILES` real programs).

## Traits

Traits (TRAITS.md) are eager, one-way, entirely static views: a trait-typed
value is its concrete witness's value, and every backend compiles a
monomorphized program with no trait type, no trait operation and no
trait-polymorphic function (`hir::traits::monomorphize`). Never add trait
knowledge below HIR: no runtime trait value, wrapper, tag, vtable,
dictionary, witness argument or indirect call for a trait operation, and no
trait code in `core/`, `compiler/`, `native/` (`tests/traits.test`'s
`trait-source-audit`, `-principal-nir`, `-machine-code-direct`,
`-allocation-free` and `-code-quality-identical` pin this). Conformance reads
only the witness's owner namespace's own declarations: never the call
site's imports or another namespace.

If you change conformance (`hir::traits::satisfies` and what it reads), trait
views in inference (`hir/types.tcl`'s subtype/lub/narrow of views,
`hir::traits::Accept`/`EntryView`/`ViewResult`/`TypeCall`), the semantic
instance key of a trait parameter (`hir/semantic.tcl`), the plan or build 2
(`hir::traits::Plan`, hir/resolve.tcl's clone/planned-call resolution), run
`tests/traits.test`, `audit/traits/tools/fuzz.tcl` and
`audit/traits/tools/mutate.tcl` (which needs every mutant in
`audit/traits/tools/mutants.txt` to still apply: update a mutant's text when
you change the code it mutates, and keep it a mutant of the same rule).
`audit/traits/tools/evidence.tcl` regenerates `audit/traits/principal/`.
`hir::BuildFull` runs the plan only on a program with no diagnostic, and its
diagnostics are a static site's: a program-wide channel of the static
decisions (`hir/staticdeps.tcl`'s `C:plan`, which lists the plan's
diagnostic kinds and the calls they are reported at). A change to that gate,
to those kinds or to where they are anchored also needs
`tests/static-economics.test` (`se-property-plan-gate`, `se-equal-plan-gate`)
and the static-decision harnesses (Static intrinsics, below).

## Context traits

Context traits (CONTEXT-TRAITS.md) are environment abstractions resolved
entirely before any backend runs: a `context trait` has no value, slot, tag,
table or runtime representation; the one installed context implementing it
is selected statically at each top-level call (exactly one, never ranked);
every function whose requirement includes a context trait is cloned for the
selection by the trait monomorphization (`hir::traits::Plan`), and every
operation becomes a direct call of the selected context's implementation.
Never add a runtime provider lookup, a context-trait slot in the native
context area, a hidden context or dictionary argument, or context-trait code
in `core/`, `compiler/` or `native/` (the one exception is the dead-code
placeholder `context#unreachable`, which never runs). Satisfaction reads only
the concrete context's owner namespace (`hir::contexts::satisfiesTrait`).

If you change satisfaction (`hir::contexts::satisfiesTrait`,
`TraitImplementation`), selection (`hir::contexts::Obligations`), the binding
check (`CheckTraitBindings`), context-trait typing (`hir::traits::TypeCall`,
`hir::types::ShapeResult`'s context-trait case), the plan's context-trait
actions or the planned-call resolution (`hir/resolve.tcl`'s
`ResolvePlannedCall`), or lib/io.bot, lib/linux/io.bot, lib/linux/path.bot,
run `tests/context-traits.test`, `tests/portable-io.test`,
`tests/linux-path.test`, `audit/context-traits/tools/fuzz.tcl` and
`audit/context-traits/tools/mutate.tcl` (every mutant in
`audit/context-traits/tools/mutants.txt` must still apply: update a mutant's
text when you change the code it mutates, keeping it a mutant of the same
rule). Changing `hir::traits::Plan` also means re-checking the trait mutants
(`audit/traits/tools/mutants.txt`).

## Coroutines

Coroutines (COROUTINES.md) are eagerly started, affine resumable
computations: `yield` is a statically tracked deep control effect, and every
coroutine operation is an internal root native (`coroutine#create`,
`#start`, `#resume`, `#yield`, `#release`, and `coroutine::done?`).
Ownership is entirely static: there is no runtime moved state, no copy, fork
or clone operation, no iterator protocol, no exhaustion error and no
resumable error -- don't add any (`tests/coroutines.test`'s `co-source-*` tests pin this). A handle is an
affine value (next section): where it may live is decided by
`hir::affine::Consumer` for every affine value alike, and a new place (a
closure capture, an erasing argument, a mutable container) is a deliberate
extension of that discipline, never a side effect.
Contexts and context traits stay static: a coroutine's providers are the
ones selected at its construction, and suspension adds no context or trait
machinery to either runtime.

A coroutine is released right after its handle's last use
(`hir::affine::Releases`, COROUTINES.md "Release at the last use"):
every backend emits the release after that statement (`hir/lower.tcl`'s
`Seq`, the Tcl compiler's `CompileSequence`, `native/lower.tcl`'s `Sequence`)
and keeps the statement's value. An exit that leaves the handle's scope
first -- a `return`, `fail`, `break` or `continue`, or a call propagating a
declared error -- releases it there (`hir::affine::ExitReleases`,
COROUTINES.md "Release on every early exit"): before the exit (after its
value, for a handle the value uses), and on a call's error edge through a
handler-shaped catch that releases and propagates the same error on
(`hir/lower.tcl`'s `ReleasingOnError`, the Tcl compiler's
`ReleasingOnError`/`CompileHandle`, `native/lower.tcl`'s `Call`/`Handle`
pads). An error edge uses the call's type-level `calleeErrors`, never the
completion proofs. A release must stay unobservable -- it never runs
Botlish code (a released suspended Tcl coroutine is unwound by an error no
handler catches) and never changes a value -- and must never release a
coroutine some live binding still owns. The affine-values milestone
extended it to every affine value, keeping both properties.

If you change the coroutine grammar (`yield`, the coroutine binding, the
resume clause), `hir/coroutines.tcl` (protocols, the yield effect),
`hir/affine.tcl` (the ownership analysis), how a construction lowers (`surface/lower.tcl`'s
`CoroutineBind`) or resolves (`hir/resolve.tcl`'s `CoroutineResume`), a
segment's error facts (`hir/completions.tcl`'s `NativeCallFacts`), where
releases go or how they lower, the Tcl runtime (`core/coroutines.tcl`) or the
native one
(`native/src/runtime/coroutine.rs`, the GC's walk of suspended and resumer
stacks in `heap.rs`/`vm.rs`), run `tests/coroutines.test`,
`audit/coroutines/tools/fuzz.tcl` (several seeds) and
`audit/coroutines/tools/mutate.tcl` (every mutant in
`audit/coroutines/tools/mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule; native mutants rebuild a private copy of `native/`, never this
checkout's). A change to native stack switching or its GC walk also needs a
`BOTLISH_NATIVE_GC_STRESS=1` run of `tests/coroutines.test` and
`cargo test --release --manifest-path native/Cargo.toml --lib coroutine`.
`bench/coroutines.tcl` regenerates the performance report.

Native coroutines switch stacks with hand-written x86-64 and AArch64
assembly and exist on Linux x86-64 and AArch64 only; elsewhere the native
backend reports them unsupported (the Tcl backends run them everywhere).

## Linux AArch64

The native backend runs on Linux AArch64 (the `tests-arm64.yml` CI jobs) with
the x86-64 feature set except what is tied to the x86-64 instruction set:
the JIT, native-frame stack maps (runtime/framewalk.rs; on AArch64 a stack
map entry is a root's distance below its own frame's FP, codegen::clif's
`define`), the pthread overflow guard (runtime/platform/linux.rs), coroutines
and rustc-linked executables. `linux::abi::syscall` (and so `linux::io`) and
the `stub` linker remain x86-64 only: the Tcl tests that need them carry
`linuxX86_64` or `stubLinker`, golden suites that make live syscalls
`# golden-host: linux-x86_64 -- REASON` (tests/golden/run.tcl). A Tcl test
that needs the native runtime on Linux (coroutines, stack maps, GC-stress
evidence) but no syscall carries `nativeLinux`; one that only needs a
standalone executable, `executableAot`. Never gate a test on
`linuxX86_64` for anything but the x86-64 instruction set or syscall ABI. A change to
the walker, the switch or root lowering needs a GC-stress run on both
architectures; CI's arm64 workflow has one.

## Affine values

Affinity (AFFINE-VALUES.md) is a compositional property of a value's type:
the coroutine handle is the one primitive affine root, and a struct,
anonymous struct or List that owns an affine value is affine too
(`hir::types::Affinity`/`IsAffine`, the one query every ownership decision
asks). An affine value has one usable owner and moves through bindings,
arguments, results, struct fields and List elements; it is released where
its owner dies, by its type's static drop descriptor (`coroutine#release`,
or `affine#drop`/`affinedrop` for an aggregate). `Fn{...}` and
`Coroutine{...}` share one callable contract (args, return, errors) and stay
distinct callable kinds: never add an implicit conversion between them, a
runtime callable-kind dispatch, or runtime ownership state (a moved flag, a
reference count, an ownership object): `tests/affine.test`'s
`af-native-runtime-source`, `af-generic-dual` and `af-native-evidence` pin
this. An exact function value stays unrestricted. A generic (untyped)
function given an affine argument is specialized for it by the trait
monomorphization (`hir::traits::NeedsAffinePlan`, `AffineWitnesses`), never
dispatched at run time; `hir/affine.tcl` must never ask whether a value is a
coroutine, only whether its type is affine. The terms are unrestricted,
affine, move, release/drop, callable contract and callable kind; an affine
value is not a reference, a borrow or a linear value, and may be dropped
unused.

If you change the affinity query (`hir/types.tcl`, `hir/structs.tcl`),
`hir/affine.tcl`, contract-based call typing of `Fn`/`Coroutine` callees
(`hir/types.tcl`'s `Call`, `hir/range.tcl`'s `VerifyStructuralCall`,
`hir/completions.tcl`), `hir::coroutines::ElaborateResumes`, the affine
specialization (`hir/traits.tcl`, `hir/semantic.tcl`'s affine instances,
`hir::signatures::CallableAdmits`), release or pending-temporary lowering in
any backend, or the drop runtimes (`core/affine.tcl`,
`native/src/runtime/affine.rs`), run `tests/affine.test`,
`tests/coroutines.test`, `audit/affine/tools/fuzz.tcl` (several seeds),
`audit/affine/tools/mutate.tcl` and `audit/coroutines/tools/mutate.tcl`
(every mutant in both `mutants.txt` files must still apply and be killed;
the coroutine mutants of ownership and release edit `hir/affine.tcl` too).
A change to `hir::traits::Plan` for affine witnesses also means re-checking
the trait and context-trait mutants. A change to native drop or release
lowering also needs a `BOTLISH_NATIVE_GC_STRESS=1` run of
`tests/affine.test` and `cargo test --release --manifest-path
native/Cargo.toml --lib affine`. `bench/affine.tcl` regenerates the
performance report. `hir::affine::verify` computes release scopes (and so
`AFFINE-PATH-RELEASE-UNSUPPORTED`) only for a program its whole-program
analysis accepts, a program-wide channel of the static decisions
(`hir/staticdeps.tcl`'s `C:verdict`, which lists that analysis's diagnostic
kinds): a change to that gate, to those kinds or to which joins can hold a
path-release diagnostic also needs `tests/static-economics.test` and the
static-decision harnesses (Static intrinsics, below).

## Enums

Enums (ENUMS.md) are named, closed, nominal sums of payload-free cases:
`enum Name:` declares one type `{enum ID}` (ID the declaration identity, a
module's `ns::Name`) and its cases; `Name::Case` resolves, as a *type*
qualifier (never a namespace), to a `const` node of the value `{enum ID
CASE}`. A case's identity is (enum identity, case name): never a spelling
alone, never a position. Never add an ordinal, integer or String conversion,
an ordering, a reflection operation (`cases`, `case_count`, `case_name`), an
anonymous enum, a case alias or value, or a global case namespace (a bare
case name must stay unbound); no semantic check may read a case's position
(`hir::enums::cases` keeps declaration order for diagnostics and future
exhaustiveness only). Native case words carry an enum number and a case
number that are representation only: printing and hashing read the names from
the program's enum table. Affinity is derived from the case descriptors'
payloads (`hir::enums::IsAffine`), never decided by being an enum.

If you change the enum grammar (`surface/parser.tcl`'s `EnumDecl`),
`hir/enums.tcl`, the `{enum ID}` cases of `hir/types.tcl`, case resolution
(`hir/resolve.tcl`'s `ResolveEnumCase`, `surface/modules.tcl`'s
`EnumQualifier`), the HIR text of enums (`hir/format.tcl`, `hir/read.tcl`), the
Tcl runtime's enum value, equality or hashing (`core/value.tcl`,
`core/hashing.tcl`), or the native word, enum table, `enumeq` or `rt_hash`
case (`native/lower.tcl`, `native/src/runtime/{value,ops,show}.rs`), run
`tests/enums.test`, `audit/enums/tools/fuzz.tcl` (several seeds, once with
`-gc-stress 1`), `audit/enums/tools/mutate.tcl` (every mutant in
`audit/enums/tools/mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of the
same rule) and `cargo test --release --manifest-path native/Cargo.toml --lib
enum`. `bench/enums.tcl` regenerates the performance report.

## Error payloads

An error is a nominal identity that may carry a statically known named-field
payload (ERROR-PAYLOADS.md): `error NAME:` and `field: Type` lines, `fail NAME
{field: value}`, `on NAME:` / `on NAME details:` / `on NAME {a, b: c}:`. `on`
discriminates the identity only: never add value patterns, guards, payload-
or shape-driven handler selection, a handler-specific destructuring rule, an
implicit `message`/`code` field, a key/value payload access or a
`Result`/`Error[E]` encoding. The payload is the anonymous struct of the
declared fields (`hir::errordecls::payloadType`), checked like a named
construction (`hir/resolve.tcl`'s `ResolveStruct` with `payloadOf`,
`hir::range::VerifyPayload`); handler destructuring is the ordinary
destructuring expansion over the handler's payload binding
(`surface/lower.tcl`'s `Handlers`). A payload-free error keeps its
one-word representation everywhere (Tcl `{errorId NAME}`, native
`faildeclared ID NAME` with no payload slots): never make every error carry a
payload object. Natively a payload travels field-wise in the Vm's payload
slots (`Vm::declared_payload`, a GC root) -- never box it to transport it.
A coroutine may not fail with an error whose payload is affine
(`hir::coroutines::AffineProtocol`): its cached failure is raised again.

If you change the error declaration or payload grammar, `hir/errordecls.tcl`,
the `fail`/`handle` resolution, typing, affine flow or lowering in any
backend, `errorId` (`core/value.tcl`), the native payload slots
(`native/src/runtime/{vm,ops,coroutine}.rs`, `Inst::Fail`/`DeclaredPayload`)
or `hir::warnings::FailSites`, run `tests/error-payloads.test`,
`tests/errors.test`, `tests/same-failure.test`, `tests/affine.test`,
`tests/coroutines.test`, `audit/error-payloads/tools/fuzz.tcl` (several
seeds, once with `-gc-stress 1`), `audit/error-payloads/tools/mutate.tcl`
(every mutant in `audit/error-payloads/tools/mutants.txt` must still apply
and be killed: update a mutant's text when you change the code it mutates,
keeping it a mutant of the same rule), `audit/same-failure/tools/mutate.tcl`
and `cargo test --release --manifest-path native/Cargo.toml --lib
error_payload`. `bench/error-payloads.tcl` regenerates the performance
report.


### Error identity

A source-defined error's identity is canonical and module-qualified
(ERROR-PAYLOADS.md, "Module-qualified error identity"): `NS::Name` for module
NS's `error Name`, the bare `Name` for the entry program's and for the
runtime's builtin errors. Every spelling (`fail`, `on`, `errors` clauses, a
function type's `errors` list) is resolved once, in the namespace of the code
that writes it (`hir::errordecls::resolve`), and everything downstream --
HIR, contracts, completion sets, Core IR, `errorId`, native ids, rendering,
`SAME-FAILURE` -- holds the canonical string. Never key, compare or dispatch
by a short name, never add an `import error` form, an alias or a
compatibility spelling, and never let a module see the entry program's
errors. If you change error-name resolution or authorization
(`hir/errordecls.tcl`, `surface/modules.tcl`'s error references,
`surface::parser::ErrorName`), run `tests/namespaced-errors.test`,
`tests/imports.test`, `tests/same-failure.test`,
`audit/error-payloads/tools/fuzz.tcl` (its namespaced programs; once with
`-fault wrong-namespace`), `audit/error-payloads/tools/mutate.tcl` (its
identity mutants) and `audit/same-failure/tools/mutate.tcl`
(`same-short-name-grouped`). A stdlib error moved into its module is spelled
qualified by every user outside it, the audit tools, probes and mutant texts
included.

### Completion precision through untyped callables

The completion analysis never turns lost precision into "no errors"
(STATIC-COMPLETION-PROOFS.md, "Precision and the erased-callable contract"):
an uncontracted call (callee `any` or a bare kind) is charged by its callee's
callable fact (`hir::completions::CallableFact`: exact, contract, clean or
unknown), an unknown one the erased-callable contract, and an incomplete
summary falls back to the callee's declared contract (`EffectiveFacts`,
`Fallback`). Fallbacks are may-sets only (never a KNOWN-ERROR).

Identity precision and contract precision are separate
(VERIFIED-CALLABLE-CONTRACT-BOUNDARY.md): a call through a structural `Fn` or
`Coroutine` type is bounded by its contract whatever callable it holds -- an
exact fact may narrow it, nothing widens it, and the erased-callable contract
never reaches it. That is sound only because every value acquiring a
structural type is checked against it (`hir::completions::Subsume`,
`SubsumeHandle`: what it raises through a callable it captured or receives,
with untyped inputs standing for every value their calls pass, `Possible`).
Never charge a structural call the erased-callable contract again, never
trust a contract a value acquired without that check, and never let an
unknown uncontracted call be charged less than the erased-callable contract
(which includes contravariant erasure: what a structural `Fn`'s argument types
carry into a callable's untyped parameters).

If you change the walker's call, handle or bind cases,
`EffectiveFacts`/`Fallback`/`IndirectFacts`, the callable facts, the
erased-callable contract (`erasedErrorsOf`, `staticsOf`,
`hir::callables::CarriedErrors`), the boundary check (`Subsume`,
`SubsumedRaises`, `SubsumeHandle`, `Possible`) or `hir/affine.tcl`'s error
edges, run `tests/structural-contract-completions.test`,
`tests/higher-order-completions.test`, `tests/error-payloads.test`,
`audit/structural-contracts/tools/fuzz.tcl` (several seeds; once with
`-fault carrier`, `-fault unknown`, `-fault drop`),
`audit/error-payloads/tools/fuzz.tcl -fault unhandled` (the unhandled error on
every path, the untyped `generic` one included),
`audit/structural-contracts/tools/mutate.tcl` and
`audit/error-payloads/tools/mutate.tcl` (its completion mutants: every mutant
in both `mutants.txt` files must still apply and be killed); a change to the
affine error edges also needs the affine and coroutine harnesses above, and
one to the golden suites' layout `tests/golden.test`
(`bench/callback-registry.tcl` measures a registry beside erased callables).

## MutableVector

`MutableVector[T]` (MUTABLE-VECTOR.md) is a growable mutable VALUE: a
runtime *header* (the identity of one logical value, mutated in place) over
a copy-on-write *backing*. A mutation never rebinds anything: its receiver
must be a *place* (a local, parameter or context parameter of the same
function, or a field path from one), checked by `hir::mutvec::verify`
(`MUTABLE-PLACE-RECEIVER`, `MUTABLE-PLACE-CAPTURE`). Value semantics come
from the logical copies `hir::mutvec::Elaborate` writes out
(`mutable_vector#share`: read-outs of a place, entries into one; a
function's own place returned moves its header out instead). Never add a
reference, an alias between places, a rebinding, an assignment, or runtime
ownership state (an owner, a moved bit, an affine flag: `mv-runtime-source`
pins this); the backing's `Rc` count is copy-on-write bookkeeping only.

Affinity is the element's (`hir::types::IsAffine`): an affine vector is
never shared, moves whole, and moves elements only through push/swap in and
pop/take/swap/consuming iteration out; `at` of an affine element is
`AFFINE-ELEMENT-COPY-OUT`; clear, a failed swap and a dying vector release
by the static descriptor (`v`D), first to last.

If you change the vector type, `hir/mutvec.tcl`, the vector cases of
`hir/affine.tcl` (consumers, consuming loops, `LoopDomain`, path releases),
consuming-loop lowering (`hir/lower.tcl`, `core/evaluator.tcl`,
`compiler/compiler.tcl`, `native/lower.tcl`) or either runtime
(`core/mutvec.tcl`, `native/src/runtime/mutvec.rs`), run
`tests/mutable-vector.test`, `audit/mutable-vector/tools/fuzz.tcl` (several
seeds, once with `-gc-stress 1`), `audit/mutable-vector/tools/mutate.tcl`
(every mutant in `audit/mutable-vector/tools/mutants.txt` must still apply
and be killed: update a mutant's text when you change the code it mutates,
keeping it a mutant of the same rule) and `cargo test --release
--manifest-path native/Cargo.toml --lib mutvec`, plus the affine and
coroutine harnesses for any change to `hir/affine.tcl` (above). A change to
native tracing, growth or drops also needs a `BOTLISH_NATIVE_GC_STRESS=1`
run of `tests/mutable-vector.test`. `bench/mutable-vector.tcl` regenerates
the performance report.

## MutableArray

`MutableArray[T]` (MUTABLE-ARRAY.md) is MutableVector's fixed-length
sibling and follows the same model: a VALUE, a header over a copy-on-write
backing (Tcl: a `{mutarray ID}` over the shared Tcl list in
`core::mutarray::store`; native: `MutArrayObj` over an `Rc<[Value]>`), its
mutations made through places (`MUTABLE-PLACE-RECEIVER`,
`MUTABLE-PLACE-CAPTURE`), its logical copies written out by
`hir::mutvec::Elaborate` (`mutable_vector#share`, descriptor `h`; `d`, a
copy of whatever the value is at run time, inside a generic body whose
static type is too imprecise to say). It used to have reference semantics: never
reintroduce an alias between two arrays, a reference, or runtime ownership
state. Like a vector it is covariant (MutableArray[S] <: MutableArray[T]
when S <: T; the raw kind `mutarray` is MutableArray[any]) while a typed
parameter admits exactly its contract (`hir::range::AggregateAdmits`); an
erased array holds a copy, so no erasure check guards it (only the
callable contracts of its elements, `hir::callables::Bearing`).

Affinity is the element's: an affine array moves whole, is never shared,
and moves elements only through swap/set in and swap/consuming iteration
out (there is no take, pop or clear: a fixed-size array has no empty slot);
`at`, `freeze` and a copy's source of an affine element are
`AFFINE-ELEMENT-COPY-OUT`; a failed swap, a displaced `set` element, a
failing factory's earlier results and a dying array release by the static
descriptor (`a`D), first to last. The specialization key keeps an affine
array's element (`hir::specialize::ElementKeyType`): erased, an instance
would see an unrestricted array and drop nothing.

Every collection operation's ownership behavior is registration metadata,
never a name: `-ownership` roles (core/native.tcl: `repeat` for create's
value -- an affine one is `AFFINE-DUPLICATION-UNSUPPORTED` --, `factory`
for generate's, `move`, `place`, `copy-out`, ...), `-drop-form` (the
dropping variant hir/mutvec.tcl retargets an affine operation to),
`-result-length` (hir/cardinality.tcl) and the receiver role
(`hir::mutvec::OpKind`). Do not add a check keyed on a native's name
(`mat-id-4` fences `hir/`, `compiler/` and `surface/`); register a role.
`mutable_array::generate(n, f)` calls F once per slot, in index order, under
the callable-contract model (`hir::containers::VerifyFactory`, `-errors-from`).

If you change the array runtime (`core/mutarray.tcl`, the array section of
`native/src/runtime/ops.rs`), its registrations or roles, the array cases of
`hir/types.tcl` (affinity, subtype, lub, narrow), `hir/range.tcl`'s
admission, `hir/containers.tcl`, `hir/mutvec.tcl`, `hir/affine.tcl`'s
`NativeConsumer`, consuming-loop lowering or `hir/specialize.tcl`'s key, run
`tests/mutable-array.test`, `tests/mutable-vector.test`,
`tests/mutable-array-type.test`, `audit/mutable-array/tools/fuzz.tcl`
(several seeds, once with `-gc-stress 1`), `audit/mutable-array/tools/mutate.tcl`
(every mutant in `audit/mutable-array/tools/mutants.txt` must still apply
and be killed) and `cargo test --release --manifest-path native/Cargo.toml
--lib mutarray`, plus the vector, affine and coroutine harnesses above for
any change they name. A change to native tracing or drops also needs a
`BOTLISH_NATIVE_GC_STRESS=1` run of `tests/mutable-array.test`.
`bench/mutable-array.tcl` regenerates the performance report.

## Fixed binary layouts

A `layout` (BINARY-LAYOUT.md) is a compile-time schema of a fixed number of
bytes -- explicit size, alignment and per-field offsets, scalar fields whose
integer domain is exactly one fixed-width encoding's, nested layouts by value
-- and `LayoutStruct[L]` the immutable struct its imprinting
(`binary::parse(L, data)`) produces and its emission (`binary::emit(v)`)
consumes. `hir/layouts.tcl`'s registry is the one representation of a
resolved layout: `LayoutStruct[L]` is the named struct `{nstruct
LayoutStruct[L]}`, whose schema `hir/structs.tcl` reads from it, never a
second registration. Never add a generic struct declaration (`struct
Foo[T]:`, `LayoutStruct Foo:`), a runtime layout object or value, a layout
read at run time by a compiled backend (the Tcl compiler and native lowering
read the descriptor constant statically: one `binary scan`/`binary format`,
one `binload`/`binstore` per scalar field), structural compatibility between
two layouts, a prefix parse, a cursor, a retained input buffer, an implied
overlay, an alignment rule a resolved layout must satisfy, or a check keyed
on a binary operation's name (register a `-layout` role). A layout knows no
C: a C layer emits resolved layouts.

If you change the layout grammar, `hir/layouts.tcl`, the `LayoutStruct`
cases of `hir/types.tcl` and `hir/resolve.tcl`, the registration order in
`hir/sourcetypes.tcl`, the layout cases of `hir/escape.tcl`, the HIR text of
layouts, the binary operations' registrations (`core/binary.tcl`,
`core/native.tcl`'s `-layout`), the Tcl compiler's `CompileLayoutOperation`,
native lowering's `LayoutCall`/`LayoutDecode`/`LayoutEncode` or the native
ops (`binload`, `binstore`, `byteszeroed`), run `tests/binary-layout.test`,
its golden suite (`tclsh9.0 tests/local.tcl tests/golden/binary-layout.bot`),
`audit/binary-layout/tools/fuzz.tcl` (several seeds, once with `-gc-stress
1`), `audit/binary-layout/tools/mutate.tcl` (every mutant in
`audit/binary-layout/tools/mutants.txt` must still apply and be killed:
update a mutant's text when you change the code it mutates, keeping it a
mutant of the same rule) and `cargo test --release --manifest-path
native/Cargo.toml --lib bin_`. The registry is a declaration registry
(compilation isolation and HIR interchange, above), and a new diagnostic
kind is classified in `tests/static-compile.test`'s census.
`bench/binary-layout.tcl` regenerates the performance report.

## C header archaeology (a research instrument)

`audit/c-header/` (C-HEADER-ARCHAEOLOGY.md) preprocesses BoringSSL's and
Tcl's public headers with the installed C toolchain, parses the output into
an exploratory FFI IR and counts what a first C FFI would need. It is
research tooling, not the FFI: nothing in `core/`, `hir/`, `surface/`,
`compiler/` or `native/` may load it, `tests/local.tcl` and CI do not run
it, and ordinary Botlish compilation must never depend on a C preprocessor
or compiler. Only `tools/toolchain.tcl` builds command lines (the
`BOTLISH_C_*` variables). Keep it that way: a new tool asks the adapter,
never `exec`s a compiler itself.

If you change `tools/cdecl.tcl`, `tools/ir.tcl`, `tools/run.tcl` or the
census, run `tclsh9.0 audit/c-header/tests/parser.test` and
`tests/corpus.test` (no toolchain needed), then `tools/fetch.tcl` once and
`tools/all.tcl`: the oracle must stay at 0 rejected with every planted
check caught, every thunk sample as predicted on gcc and clang. Commit the
regenerated `results/` and `unsupported/` (they are deterministic; only
`timing.txt` changes run to run).

## Static intrinsics

`static compile:` (STATIC-COMPILE.md) is a recoverable semantic-compilation
boundary: hir/static.tcl decides each block by ordinary whole-program builds
of the syntax with the block's body in place, reading the diagnostics as
data, and replaces it -- before resolution -- by its body (accepted) or by an
ordinary `fail compiler::CompilerError {...}` reifying the diagnostic
(rejected). No HIR expression kind, Core IR form, NIR instruction or runtime
operation knows static intrinsics: never add one, never invoke the compiler at
run time, never serialize the body to text and re-parse it, never catch a Tcl
error or an `internal` diagnostic as a rejection (a compiler failure fails the
compilation), and never give `CompilerError` a case per diagnostic or a default
`Unknown` code. `static` is the introducer of compiler-directed syntax only (no
storage/member meaning), its operations are compiler vocabulary (only
`compile`: no `static parse:`, `static assert_*:`, test framework, syntactic
functions or compile-time evaluation yet), and `compiler::*` is reached only
through `import compiler`.

Every error diagnostic kind the front end can report is classified in
`tests/static-compile.test`'s `sc-census-exhaustive`: a kind a block can
produce has exactly one `compiler::DiagnosticCode` case (`lib/compiler.bot`,
`hir::static::codes`, the Botlish enum spelling of the kind); every other kind
is listed with the reason it never is. Adding a diagnostic kind anywhere in
`hir/` or `surface/modules.tcl` therefore means classifying it there (and, if
recoverable, adding its case to both). A diagnostic with further locations
records them as `related` origins (`hir::Diagnose`'s last argument), never only
in its message text. The tests' and the fuzzer's expectations spell their
`DiagnosticCode` cases themselves (`scPayloadOf`, the fuzzer's `codeCases`):
never derive an expected code from `hir::static::codes` or `CodeOf`.

If you change the static grammar, `hir/static.tcl`, the loader's deferral of a
block's qualified references (`surface/modules.tcl`), how `fail` resolves or
lowers, the completion walk's `fail` case (`intended`), `hir::Diagnose`'s
fields, `hir::BuildFull`, or SAME-FAILURE's fail sites, run
`tests/static-compile.test`, `audit/static-compile/tools/fuzz.tcl` (several
seeds, once with `-gc-stress 1`) and `audit/static-compile/tools/mutate.tcl`
(every mutant in `audit/static-compile/tools/mutants.txt` must still apply and
be killed: update a mutant's text when you change the code it mutates, keeping
it a mutant of the same rule). `bench/static-compile.tcl` regenerates the
performance report.

How many builds deciding the blocks takes is the scheduler's business, never
the program's (STATIC-COMPILE.md, "Decision economics";
STATIC-DECISION-ECONOMICS.md): the *sequential* order (one typed rejection per
build) defines every outcome, and the default *batched* scheduler continues
that order on one build for every block whose dependencies
(`hir/staticdeps.tcl`) nothing rejected since has changed. Never make an
outcome depend on the scheduler, never add a source-layout rule or annotation
to make compilation cheaper, and never key a reused method-call decision by
name. A missed cross-function channel shows up as a `mispredicted` build or a
difference from `BOTLISH_STATIC_SCHEDULER=sequential`: add its edge to
`hir/staticdeps.tcl`, not a special case to the scheduler. The sequential
order's waiting rule (STATIC-COMPILE.md, "The waiting rule";
`hir::staticdeps::Waiting`) reads that analysis's waiting channels
(`C:erased`, `C:budget:B`; never the gates `C:verdict` and `C:plan`): a
failing block consuming one waits while a failing block contributes to it,
so a consumer's verdict does not depend on where its contributors are
written. An edge into a waiting channel's part of the graph, or a new link
label the rule must skip, can therefore change an outcome, not only a build
count: check the fuzzer's layout claim on several seeds (17 and 41 among
them). If you change the
schedulers, the dependency analysis, the method-call seeds or build reuse
(`hir/hir.tcl`), or add a fact an analysis reads across functions (a summary,
an inferred contract, the erased-callable contract, an instance budget, a
yield type, a diagnostic suppressed by reachability or by a whole-program
verdict such as the ownership analysis's, which withholds release scopes and
`AFFINE-PATH-RELEASE-UNSUPPORTED` from a program it rejects, or the trait
plan's gate, which reports its diagnostics only for a program with no other;
or a diagnostic that prints an internal id in a new form -- `hir::static::
InternalIds` knows `block(eN)` and `function eN` only -- or a binding's, a
reference's or a function's `name`, which hygiene may have renamed `NAME#N`
with a number counted over the whole program: never print `name`, print
`hir::semantic::SourceName` for a binding, `RefName` for a `ref` or `bind`
node and `CallableName` (or `hir::signatures::Name`) for a function, and pin
the message with an `se-equal-hygiene-*` reproducer; or move a check across
the completion walk in `hir::CheckOnce`, or make a diagnostic depend on
another's presence: a site's contract-boundary edges read
`beforeCompletions`, since a first diagnostic reported before that walk is no
contract-boundary report and stays first whatever the program erases), run
`tests/static-economics.test`, `tests/static-compile.test`, `tests/golden.test`
(`golden-static-economics`), `audit/static-decisions/tools/fuzz.tcl` (several
seeds), `audit/static-decisions/tools/compare.tcl tests/golden/*.bot` and
`audit/static-decisions/tools/mutate.tcl` (every mutant in its `mutants.txt`
must still apply and be killed, the economic ones -- a build too many -- as
much as the semantic ones). `bench/static-decisions.tcl` regenerates the
economics report.

## Golden tests (Botlish-native test framework)

`lib/test.bot` (GOLDEN-TEST-FRAMEWORK.md) is an ordinary Botlish library:
a test suite is an installed `context struct Suite` whose `MutableVector`
holds the registered cases, each a deferred `Fn{args: [], return:
test::Match}`; the runner is an ordinary coroutine. It has no syntax, no
compiler knowledge and no natives of its own: never add test syntax, a
`test` keyword, an assertion form, a catch-all error, a test-only native,
module-initializer registration or discovery, or compiler knowledge of
PASS/FAIL to support it; record the friction instead (the report's
"Recurring boilerplate" and "Findings"). The library may import `compiler`
to read `compiler::CompilerError`, and nothing knows static blocks.

`tests/golden/*.bot` are ported Tcl tests, each listed in
`tests/golden/manifest.tsv` with its Tcl original, which stays in the Tcl
suite, authoritative, unchanged. `tests/golden.test` runs the suites and
fails when a suite's reported tests differ from the manifest's; a new or
removed golden test is a manifest row added or removed. `rejects_at` pins
line and column in the suite file: adding lines above one moves it (update
the test). `tests/golden/README.md` is the porting guide.

The manifest maps *every* Tcl test that runs (LARGE-SCALE-GOLDEN-MIGRATION.md)
and is generated: never edit it by hand. A golden test's row lives in its
suite's fragment (`audit/golden/migration/fragments/SUITE.tsv`), a Tcl test's
classification in its file's census (`audit/golden/migration/census/FILE.tsv`);
a new Tcl test gets a census row (KEEP-INTERNAL for a test of compiler
internals). Regenerate with `tclsh9.0 audit/golden/migration/merge.tcl -names
audit/golden/migration/tcl-names.txt` (refresh the names with
`audit/golden/tools/check.tcl -full 1 -names-out FILE` when tests were added).
A new golden test must be able to fail: run `audit/golden/tools/perturb.tcl` on
its suite. By default `tests/golden.test` runs the eight validation-sample
suites (`BOTLISH_GOLDEN_SUITES=all` or a list of files runs others); CI's
`golden` shards run every suite on every backend beside its Tcl originals
(`check.tcl -shard I/4`). Locally, `tests/local.tcl` runs every suite on
every backend, through the front-end cache (Running the tests locally,
above). A suite that cannot run on a backend declares
`# golden-exclude: BACKEND -- REASON` in its leading comments; keep such tests
in a companion suite so the main suite keeps all four backends. A suite that
runs on one host only (live Linux x86-64 syscalls) declares
`# golden-host: linux-x86_64 -- REASON`: elsewhere it compiles but does not
run. On such a host check.tcl accepts a row whose Tcl original a host
constraint skipped (`host-skip`) with its golden test passing or
host-excluded; every other row must still be "old pass, new pass".

If you change `lib/test.bot`, run `tests/golden-framework.test`,
`tests/golden.test`, `tclsh9.0 tests/golden/run.tcl`,
`audit/golden/tools/fuzz.tcl` (several seeds, once with `-gc-stress 1`)
and `audit/golden/tools/mutate.tcl` (every mutant in
`audit/golden/tools/mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule), and the warning gate (`lib/test.bot` is in its manifest). If
you change a compiler diagnostic, `compiler::DiagnosticCode` or the
completion analysis, also run `tests/golden.test` and
`audit/golden/tools/check.tcl` (old and new tests side by side; with
`-mutants` it runs existing mutants against both). `bench/golden-framework.tcl`
regenerates the performance report.
