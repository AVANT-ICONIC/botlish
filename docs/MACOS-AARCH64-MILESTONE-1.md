# MACOS-AARCH64-MILESTONE-1.md

Milestone 1 of the macOS Apple Silicon port: a Linux-hosted platform audit
and the GitHub Actions infrastructure that tests the port on real Apple
Silicon. No macOS backend code: the compiler, the runtime and the Linux
workflows are unchanged. The audit itself, and the reference for later
milestones, is MACOS-AARCH64-PORT-AUDIT.md.

## Result

- **An audit** (MACOS-AARCH64-PORT-AUDIT.md) of every Linux assumption in
  the target model, Cranelift configuration, object and executable
  generation, the runtime (stacks, guard, GC walk, coroutines), the
  syscall transports, the C FFI, the tests and the packaging: file and
  symbol, class, macOS adaptation, owner, risk, milestone, and whether
  Linux can check it.
- **A workflow on native Apple Silicon**, `.github/workflows/macos-arm64.yml`,
  triggered by any push (so it ran from this feature branch before being on
  main), with three tiers and a Linux control job.
- **Host-generic scripts** in `tests/platform/`: the toolchain smoke, the
  C ABI fact check, the macOS prerequisites, the native status check and
  the tier runner, each runnable locally exactly as CI runs it.
- **A census** of what the existing tests do on macOS arm64 today (173 of
  188 test files pass with the baseline Tcl; every golden suite passes on
  the Tcl backends), and
  an opt-in mechanism (`[ci-full]` plus `CI-Tests:` trailers) that ran
  from this branch.
- **A roadmap** of nine further milestones, each independently mergeable.

The headline fact: **the native backend already builds on macOS arm64,
its Rust unit tests pass and the JIT runs ordinary programs correctly.**
What does not work refuses explicitly -- coroutines, Linux syscalls,
executables and C calls -- except one thing: a native stack overflow
crashes the driver (Rust's own stack-overflow abort, or SIGSEGV), because
the overflow guard is Linux-only.

## Linux development host

An Ubuntu 24.04 cloud container: 4 vCPUs (Xeon, 2.1 GHz), 15 GiB, x86-64,
shared with nothing heavy during this work. Tcl 9.0.1 from the pinned
`.deb`s (AGENTS.md), rustc 1.97.0. Local work stayed cheap: builds with
`-j 3`, one full sweep of the test files with the native driver hidden
(three processes, `nice`), and seconds-long checks of the new scripts. No
macOS machine was used: the shared Apple Silicon development Mac was not
touched, and nothing depends on it.

## Repository test and build architecture

- **Build:** `cargo build --release --manifest-path native/Cargo.toml`
  (the Rust driver `botlish-native`, the stub, the rlib);
  `.github/actions/build-native` caches it per OS and architecture.
- **Tcl tests:** `tests/all.tcl` (tcltest, one file per child process,
  `CORE_BACKEND` interp or compile; exits 1 on a failure or stderr output),
  `tests/local.tcl` (the parallel local runner, which CI must never use:
  tests/golden-duplicates.test enforces it), tests/helpers.tcl's
  differential helpers, which run every program on all four backends.
- **Golden suites:** `tests/golden/run.tcl` (Botlish programs on four
  backends; `golden-exclude` and `golden-host`).
- **Linux CI:** tests.yml (interp/compile, native coverage, Rust, stub
  linker, warning gate, golden shards, GC stress), tests-arm64.yml,
  single-executable.yml, bench.yml, static-decisions.yml,
  scalar-asm-audit.yml, and, new on main during this milestone,
  c-bindgen.yml. None had macOS support.

## Files

| File | |
|---|---|
| `.github/workflows/macos-arm64.yml` | new: the macOS workflow |
| `tests/platform/toolchain-smoke.sh` | new: C (also a static archive with `-L -l`), rustc and Cargo executables built and run; the native format checked (Mach-O arm64 / ELF); facts printed |
| `tests/platform/cabi-facts.c`, `cabi-facts.tcl` | new: core::cabi's host row against the host C compiler |
| `tests/platform/setup-macos.sh` | new: Homebrew tcl-tk (Tcl 9), stable Rust |
| `tests/platform/native-status.tcl` | new: each native capability against its recorded outcome per host |
| `tests/platform/tier.tcl` | new: the tiers over tests/all.tcl, tests/golden/run.tcl and main.tcl |
| `docs/MACOS-AARCH64-PORT-AUDIT.md`, this file | new |
| `docs/INDEX.md`, `AGENTS.md` | a line each, and AGENTS.md's "macOS arm64 (the port in progress)" |

No other file changed: no compiler, runtime, library, test or Linux
workflow file. The scripts are not `.test` files, so the Tcl suite, the
golden manifest and its census do not see them.

## The macOS runner

- **Label** `macos-15` (image `macos-15-arm64`, version 20260907.0337.1).
- **Observed:** `uname -m` `arm64`, `sysctl.proc_translated` 0 (not
  Rosetta), "Apple M1 (Virtual)", 3 CPUs, 7 GiB, 16 KiB pages; macOS 15.7.9
  (24G830), Darwin 24.6.0.
- **Toolchain:** Xcode 16.4 (`/Applications/Xcode_16.4.app`), macOS SDK
  15.5, Apple clang 17.0.0 (clang-1700.0.13.5, target
  `arm64-apple-darwin24.6.0`), Apple ld `ld-1167.5`; rustc 1.98.1
  preinstalled, updated by setup-macos.sh to stable 1.99.1 (cargo 1.99.1);
  Homebrew 6.0.22; git 2.55.0; `/bin/bash` 3.2.57.

## Tcl

**The repository's baseline, Tcl 9.0.1** (AGENTS.md), built once from the
source release single/build.sh pins (the same version and sha256, from
SourceForge, `unix/configure --prefix`, `make install`) by
tests/platform/setup-macos.sh into `~/.cache/botlish/tcl-9.0.1`, which
`.github/actions/setup-macos` caches; the script requires exactly 9.0.1
and tcltest 2.5.

The first runs used Homebrew's `tcl-tk`, which is **Tcl 9.0.4** (tcltest
2.5.11; 15 seconds from bottles). That was a mistake the census caught:
Tcl 9.0.4 has Unicode 17 case tables, so on the Tcl backends
`str::lowercase` maps the Unicode 17 capitals (U+A7CE, U+A7D2, U+A7D4,
Beria Erfe U+16EA0..U+16EB8) that Botlish's Unicode 16 semantics -- which
the native runtime keeps on purpose (`rt_str_lower`) -- leave alone. The
interpreter and the Tcl compiler then disagreed with native code in
tests/native-tcl-unicode.test (5 tests), the golden `unicode-strings.bot`
(4 tests) and, through its uppercasing differential, tests/argv.test's
fuzz (1). Under Tcl 9.0.1, built from source, all three pass on macOS (run 5). The same would happen on Linux with any Tcl newer than
the pin. `tcl-tk@8` 8.6.18 is preinstalled on the image and never used.
Tcl's encodings are UTF-8 on macOS with any locale, so the workflow sets
no LANG.

## What passed in CI

Every run is of `.github/workflows/macos-arm64.yml` on the feature branch
`ccr-ea92b43b-fbi8ez`, triggered by an ordinary `git push`, before the
workflow existed on main.

| Run | Commit | What it ran | Result |
|---|---|---|---|
| [1](https://github.com/mwagner-webdev/botlish/actions/runs/39100974080) | 62e3064 | exploratory: host facts, the toolchain smoke, Homebrew Tcl, cabi-facts, examples, six test files, the native build and probes | green: Mach-O arm64 C and Rust executables; the native crate builds, 215 unit tests pass, the JIT runs the samples; executables refused |
| [2](https://github.com/mwagner-webdev/botlish/actions/runs/39101335542) | aac30aa | the census (three shards of every test file on interp), golden suites on four backends (two shards), runtime probes | the census of section 15; the second golden shard cancelled by run 3's push |
| [3](https://github.com/mwagner-webdev/botlish/actions/runs/39102407410) | 609d06d | the first tiered workflow, `[ci-full]` | cancelled: its ubuntu `plan` job sat in the queue (replaced in 542f054) |
| [4](https://github.com/mwagner-webdev/botlish/actions/runs/39102645922) | 542f054 | the tiered workflow; `[ci-full]` with `CI-Tests:` naming 12 census files | smoke and Linux control green; Tier C ran the 12 files in one shard (the other two stopped after 4 s) and reported their causes; acceptance shard 2 green, shard 1 failed only `unicode-strings.bot` (Tcl 9.0.4) |
| [5](https://github.com/mwagner-webdev/botlish/actions/runs/39104616134) | 073e331 (main merged) | Tcl 9.0.1 built from source; `[ci-full]` with `CI-Tests:` naming 8 items | the Tcl build and the Linux control green; Tier C: argv.test, native-tcl-unicode.test and unicode-strings.bot pass under 9.0.1, the five coroutine files fail as recorded; its smoke and acceptance were superseded by run 6 |
@RUN6@

## Botlish on macOS today

MACOS-AARCH64-PORT-AUDIT.md, sections 1 and 15. In short: the front end,
the interpreter and the Tcl compiler run everything; the native crate
builds and its unit tests pass; the JIT runs programs; the GC frame walk
works under stress; 173 of 188 Tcl test files (with Tcl 9.0.1) and every
golden suite on the Tcl backends pass; coroutines (and so the native golden runner),
Linux syscalls, executables and C calls refuse explicitly; a native stack
overflow crashes the driver.

## Linux regression

@LINUX@

## The tiers and their invocation

| Tier | When | Command (local = CI) |
|---|---|---|
| A, smoke | every push, macOS and the Linux control | `tests/platform/toolchain-smoke.sh`; `tclsh9.0 tests/platform/cabi-facts.tcl`; `cargo test --release --manifest-path native/Cargo.toml --lib`; `tclsh9.0 tests/platform/native-status.tcl`; `tclsh9.0 tests/platform/tier.tcl smoke` |
| B, acceptance | every push, two macOS shards | `tclsh9.0 tests/platform/tier.tcl -shard I/2 -backends interp acceptance` |
| C, full | `[ci-full]` in the head commit's message, or workflow_dispatch `tier: full` | default: `tier.tcl -shard I/3 -gc-stress 1 acceptance`; or the `CI-Tests:` items, with `CI-GC-Stress: 1` for stress |

Section 16 of the audit has the details: how to request, read and rerun,
how to tell a toolchain failure from a Botlish one, and what to update when
a milestone lands.

## Feature-branch remote testing, verified

1. **Feature branch:** every change is on `ccr-ea92b43b-fbi8ez`.
2. **Pushed:** runs 1-6 were started by ordinary pushes to it.
3. **Executed from the branch before merge:** the workflow is new; it ran
   from its very first commit on the branch.
4. **Native ARM64:** `uname -m` `arm64`, `sysctl.proc_translated` 0 -- the
   smoke job's Host step fails otherwise (runs 4-6).
5. **C:** compiled, linked (also against a static archive with `-L -l`),
   run, and `file` says `Mach-O 64-bit executable arm64`.
6. **Rust:** rustc and Cargo executables built and run, Mach-O arm64.
7. **Tcl:** 9.0.1 built from the pinned source and checked (patchlevel and
   tcltest 2.5) in every macOS job since run 5; Homebrew's 9.0.4 before.
8. **Botlish tests on macOS:** the smoke tier (runs 4-6), the acceptance
   tier (runs 4 and 6), the census (run 2).
9. **Linux:** below.
10. **The opt-in trigger:** `[ci-full]` with `CI-Tests:` in runs 4 and 5
    (one shard working, two stopping at once), and with a tier and
    `CI-GC-Stress: 1` in run 6 (three shards under GC stress) -- each a
    light payload, a few minutes of runner time.

## CI time and resources

- **Runner:** 3 vCPUs, 7 GiB, an "Apple M1 (Virtual)". The census's
  shards ran 62-63 test files in 7-10 minutes each, so the whole Tcl suite
  on one backend is about 27 minutes of macOS runner time.
- **Caches:** the native build (`native-cargo-macOS-ARM64-...`, about 107
  MB compressed) takes about 1 minute cold and 20 seconds warm; the Tcl
  9.0.1 build about 2 minutes once (run 5's setup step, rustup included,
  took 2 min 37 s cold).
- **Jobs:** with warm caches the smoke job takes 1 min 18 s, an
  acceptance shard 20-27 minutes (shard 1 holds the slowest golden suite,
  mutable-array.bot, 171 s to compile), the Linux control 1-4 minutes, a
  Tier C shard with nothing to do 4 seconds.
- **Queues:** the account runs at most 5 macOS jobs at once (run 2's sixth
  job waited), and all jobs share its total limit with main's Linux
  workflows: when main is busy, a macOS run waits minutes for a runner
  (run 3's ubuntu planner stalled; runs 4 and 5 queued 3-5 minutes).
- **Logs:** the GitHub MCP server returns at most the last 5000 lines of
  a job log; a long tier.tcl run's early output (run 5's affine.test
  failures) falls outside it, while its summary, at the end, never does.

## Remaining infrastructure blockers

- **Artifacts are unreachable from an agent sandbox whose network policy
  blocks Azure blob storage** (where GitHub serves artifact downloads):
  the job logs carry everything the tiers print, so nothing depends on
  artifacts.
- **workflow_dispatch of this workflow needs it on main first**
  (GitHub's rule). Until then, `[ci-full]` on a push is the only Tier C
  trigger; it was enough.
- **The shared job limit.** macOS jobs count against the account's total
  concurrent jobs, which main's Linux workflows can fill; a macOS run then
  waits in the queue (observed: several minutes).

## Next milestone

**Milestone 2, target representation and macOS C ABI facts** (audit,
section 17), because everything after it compiles programs for the
`macos-aarch64` target: make a `linux::*` import for a macOS target a
stated diagnostic instead of the silent `sys.aarch64.bot`, record the
target in `.hirx`, refuse a native run for a non-host target, and take the
tests' plain-char expectation from core::cabi. Its CI: smoke, acceptance,
and `CI-Tests: all` to confirm nothing else moved.

Milestone 5 (the stack guard) carries the one finding that is a crash
rather than a refusal; nothing in milestones 2-4 depends on it, but a
program that recurses deeply on macOS dies today instead of failing with
`NATIVE LIMIT STACK`.

## Surprise log

- **The native backend already works on macOS.** The crate compiles (all
  Linux-only code was already `cfg`-gated), 215 unit tests pass, and
  cranelift-jit's RW-then-RX `mprotect` code memory runs under the
  linker's ad-hoc signature without `MAP_JIT`.
- **Plain char is signed on Apple arm64** and unsigned on Linux AArch64;
  tests/c-ffi.test and the C FFI fuzzer infer unsigned from the machine
  name `arm64`.
- **Rust keeps frame records on aarch64-apple-darwin by default**, at the
  top of the callee-save area (Linux AArch64 puts them at the bottom), so
  `.cargo/config.toml`'s missing entry for that target has not mattered.
- **A native stack overflow is a Rust abort or a SIGSEGV**, not
  `NATIVE LIMIT STACK`: the depth token stops trivial recursion only.
- **The golden runner is a coroutine**, so no golden suite can run
  natively until native coroutines are ported.
- **A latent GC-stress test bug** (an unrooted Rust local in
  `bytes_from_list_copies_every_byte_exactly_including_nul_and_high_bytes`)
  shows on macOS only because Apple's allocator reuses the freed block.
- **`linux::sys` resolves on a macOS target** (to `sys.aarch64.bot`):
  module selection is by architecture only, by design.
- **A step's default shell on macOS is `/bin/bash -e`**, bash 3.2 and
  without pipefail, so `| tee` would hide a failure: the workflow sets
  `shell: bash` (`-eo pipefail`) and the scripts are bash-3.2-clean.
- **No `nproc` and no `timeout` on macOS**: tests/local.tcl falls back to 4
  jobs; the mutation harnesses' `exec timeout` would fail there.
- **Running `tclsh9.0 tests/X.test` directly exits 0 when tests fail**
  (tcltest); tests/all.tcl and tier.tcl exit 1.
- **tests/golden-duplicates.test fails if any workflow's text mentions the
  local runner or the golden-duplicate skip variable** -- even in a
  comment; the new workflow avoids both.
- **A planning job on ubuntu-latest stalled the macOS jobs** behind main's
  Linux workflows (the account's shared concurrency); removed.
- **A push cancels the branch's running run** (the concurrency rule, as
  designed): the census's second golden shard was lost that way.
- **Homebrew's Tcl is not the baseline Tcl.** 9.0.4's Unicode 17 case
  tables made the Tcl backends deviate from Botlish's Unicode 16 strings
  (three files); the CI now builds 9.0.1 from the pinned source.
- **Artifacts cannot be downloaded from this sandbox** (GitHub serves them
  from Azure blob storage, which its network policy refuses); job logs
  through the GitHub MCP server can, up to their last 5000 lines.
- **Main moved by 440 files during the milestone** (C-BINDGEN); merging it
  touched none of this milestone's files but shifted line numbers the
  audit cites, which were rechecked.
