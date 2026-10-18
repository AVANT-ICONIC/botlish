# MACOS-AARCH64-MILESTONE-3.md

Milestone 3 of the macOS Apple Silicon port: native coroutines on
`macos-aarch64`, through both native backends, and with them the native
golden runner. Developed on Linux; every macOS fact below was observed on
GitHub's `macos-15` arm64 runners through `.github/workflows/macos-arm64.yml`
(the shared Apple Silicon development machine was not used). The audit it
updates is MACOS-AARCH64-PORT-AUDIT.md (section 8); the milestones before it
are MACOS-AARCH64-MILESTONE-1.md and MACOS-AARCH64-MILESTONE-2.md.

> Port the stack-switching boundary, not the coroutine model.

## Result

- **Ordinary native Botlish coroutines run on macOS arm64** through
  `cranelift` and `cranelift-generic`: creation, suspension, resumption,
  completion, errors, nested coroutines, ownership and release. The
  program native-status runs (`worker(10)`, a coroutine that yields twice)
  returned `[10, 7]` on the macOS runner instead of `NATIVE UNSUPPORTED`.
- **The native golden runner runs on macOS, unmodified.** The runner is
  `lib/test.bot`, a coroutine; the 94 golden suites passed on interp,
  compile, cranelift-generic and cranelift wherever the suite is a portable
  program. Milestone 2 had 78 cranelift and 71 cranelift-generic suite runs
  blocked by the refusal.
- **The change is one platform boundary.** The coroutine model, state
  machine, pool, GC walk and error handling are the code Linux runs. What
  changed is the Mach-O spelling of the AArch64 switch text, the stack
  mapping flags, and page-size rounding (changed files, below).
- **Linux is unchanged:** `tests.yml` (x86-64) and `tests-arm64.yml`
  (AArch64) passed on the branch.
- **Not done, deliberately:** stack-overflow handling, Mach-O executables and
  C calls remain the later milestones' (remaining limitations, below).

## 1. Initial coroutine implementation findings

The implementation is `native/src/runtime/coroutine.rs` and its GC
integration in `heap.rs` (marking a suspended coroutine walks its stack) and
`vm.rs` (`collect_with` walks the running chain). In the order the task asked
about:

| Stage | Where | Platform-specific? |
|---|---|---|
| create | `rt_co_create`: a `CoroutineObj` (GC object) holding the thunk | no |
| stack | `CoStack::new`: a per-thread pool of at most 32 stacks, else `mmap` of usable bytes (8 MiB default, `BOTLISH_NATIVE_COROUTINE_STACK_BYTES`) plus a 64 KiB `PROT_NONE` guard | **yes**: `MAP_STACK`, 4 KiB rounding |
| initial context | `prepare`: writes the context `bl_co_switch` restores, on the new stack | per architecture |
| switch | `bl_co_switch(save, load, transfer)` in `global_asm!` | **yes**: ELF directives and labels |
| start/resume/yield | `rt_co_start`, `rt_co_resume`, `rt_co_yield`, `segment` | no |
| completion | `co_body` stores the terminal state, switches back for good | no |
| release | `rt_co_release`; a swept coroutine drops its `CoStack` (back to the pool) | no |
| GC roots | a suspended stack is walked from `saved_sp + SWITCH_FRAME_OFFSET` (the record `bl_co_switch` opened) with `framewalk::walk_from`, bounded by that stack's `NativeStack`; the running chain is walked from each resumer's saved sp | no, once frames carry records |
| driver protocol | nothing coroutine-specific crosses it | no |

Linux x86-64 and Linux AArch64 differ only in the switch text and the saved
state:

- x86-64 saves rbx, rbp, r12-r15 and the MXCSR/x87 control words; the frame
  record is `saved_sp + 48`.
- AArch64 saves x19-x28, d8-d15 and FPCR; the frame record is
  `saved_sp + 160`.

The compiler assumes nothing about the switch: a call that may suspend is a
GC safepoint (every coroutine operation is classified as possibly
allocating), and that is all. The runtime keeps no state the compiler
reads.

## 2. Why native coroutines were unsupported on macOS

A combination of three of the task's classes, none of them a missing piece
of the model:

1. *Platform assembly excluded by configuration* (class 2): the AArch64 text
   existed and works on Linux, but its `global_asm!` was gated on
   `target_os = "linux"` and spelled ELF (`.type X,%function`, `.size`,
   unprefixed labels), which the Mach-O assembler rejects.
2. *A runtime dependency not yet adapted* (class 3): `mmap` with `MAP_STACK`
   (absent for Darwin in the `libc` crate) and a 4 KiB rounding that is not
   the 16 KiB Apple Silicon page.
3. *A conservative feature guard* (class 4): `CoStack::new` returned
   `RtError::Unsupported` unless the host was Linux, with text that was
   already stale ("x86-64 Linux only": AArch64 Linux worked).

The machinery under them (frame-record GC walking, stack bounds, the pool,
affine release) was already portable, and milestone 1 had shown the frame
walk working under GC stress on macOS. The Linux AArch64 switch was not
enabled on Darwin by flipping a `cfg`: each Apple-specific rule of the task
was checked against it (sections 4-7).

## 3. Changed files and subsystems

- `native/src/runtime/coroutine.rs`: the switch text as two macros
  (`aarch64_switch!`, `aarch64_trampoline!`) under an ELF header and a
  Mach-O header; `MAP_FLAGS`, `round_to_page`, the guard sized to the page;
  every `cfg` that said "Linux" now names the three supported hosts; the
  unsupported text names them; new unit tests (section 11).
- `native/src/runtime/affine.rs`, `mutvec.rs`: their coroutine-using unit
  tests run on macOS too.
- `.cargo/config.toml`: `force-frame-pointers` for `aarch64-apple-darwin`.
- `tests/helpers.tcl`: the capability constraint `nativeCoroutines`
  (`hostTarget` in linux-x86_64, linux-aarch64, macos-aarch64).
- Tests: 39 test tags and the golden-framework backend list moved from
  `nativeLinux` (an operating-system name) to `nativeCoroutines`;
  `nativeLinux` stays on the stack-guard test, the Linux-io executable test
  and the 2048 demo executable. A new test
  (`co-gc-nested-suspended-roots`), and a fix to `ci-golden-pair`
  (section 12).
- `tests/platform/native-status.tcl`: the macOS coroutine expectation is the
  program's value. `tests/platform/tier.tcl`: `notYet` is down to
  `c-bindgen.test` and `c-ffi.test` (milestone 7), and the acceptance tier
  runs the golden suites on all four backends.
- `AGENTS.md`, `README.md`, `tests/golden/README.md`,
  `compilerpedia/topics/backends.topic` (`tools/compilerpedia.tcl check`
  passes), the workflow's comments, the audit.

Not touched: the compiler, HIR, NIR, the runtime's GC and error code, the
JIT and its memory handling.

## 4. Apple AArch64 context-switch strategy

The switch is the Linux AArch64 switch, kept as one text so the two can never
drift: `aarch64_switch!` and `aarch64_trampoline!` expand to the same
instructions inside two `global_asm!` blocks that differ only in their
directives:

```
ELF:     .globl bl_co_switch / .type bl_co_switch,%function / bl_co_switch: ... .size
Mach-O:  .globl _bl_co_switch / _bl_co_switch: ...
```

(`sym co_body` makes the assembler emit the mangled Rust symbol for either
format, and Rust adds Mach-O's underscore to the `extern "C"` declarations.)
The Mach-O object was assembled on Linux for `aarch64-apple-darwin` and
inspected with `llvm-objdump`/`llvm-nm`: `_bl_co_switch` at offset 0 and
`_bl_co_trampoline` at 0x80 are global symbols, the `bl` in the trampoline is
relocated to `co_body`.

The switch opens a frame record, saves the callee-saved state on the
outgoing stack, stores the stack pointer through `x0`, loads the incoming
stack pointer from `x1`, restores and `ret`s into the incoming context, with
`x2` returned as the transferred value. A fresh stack is prepared so its
first restore "returns" into `bl_co_trampoline`.

## 5. Register preservation and ABI considerations

| Apple rule | What the code does | Evidence |
|---|---|---|
| `x18` is reserved | neither the switch, the trampoline nor `prepare` mentions it | read off the text; no `x18` anywhere in either `global_asm!` |
| callee-saved x19-x28 | saved and restored | `callee_saved_registers_survive_every_switch` (macOS: passed) |
| callee-saved low halves of v8-v15 | `d8`-`d15` saved and restored (AAPCS64 preserves only the low 64 bits) | the same test, on d8-d15 |
| FPCR | saved in the context, restored on switch; a new context starts at 0 | `fpcr_is_part_of_the_context`, and `a_new_context_starts_with_the_threads_fpcr`, which asserts a new thread's FPCR is 0 on Darwin as on Linux (macOS: passed) |
| frame pointer / frame records | the record is the switch's first store; see section 7 | `a_suspended_stacks_frame_chain_ends_in_the_trampolines_zero_record` |
| return state (`x30`) | restored from the record, `ret` | every switch; a wrong value does not return |
| 16-byte sp alignment | section 6 | `the_stack_pointer_is_aligned_and_on_the_coroutines_stack` |
| 128-byte red zone | no store below sp: every push is pre-indexed (`stp ..., [sp, #-16]!` moves sp first) and the fresh context lies wholly above its initial sp | read off the text |
| pointer authentication | not used: no stripping, no forging | `ret` is the plain instruction; no arm64e |

Register preservation is tested through running code, not read off the
assembly: `pattern_call` (a `#[naked]` function) loads every callee-saved
register with a pattern derived from a per-context seed, calls a runtime
operation that switches, and counts the registers that differ afterwards. It
runs on both sides of a switch with different seeds: an identical pattern in
both contexts would hide a missing restore, which a first version of the test
did (the mutant below survived it).

## 6. Initial stack setup and alignment

`prepare` puts 22 words at the top of the new stack, in the order
`bl_co_switch` restores them (FPCR and its pad, d14/d15 down to d8/d9,
x27/x28 down to x19/x20 with `x19 = Vm`, `x20 = the coroutine`, then the
frame record `x29 = 0`, `x30 = bl_co_trampoline`). The top is rounded down to
16 bytes; 22 words are 176 bytes, a multiple of 16, so after the restore
`sp = top`, aligned. The trampoline's first act is `stp x29, x30, [sp,
#-16]!` of a zero record (`x30` is cleared first), so the chain of every
coroutine stack ends there, and `bl co_body` is made with an aligned sp.

Not assumed: the pthread APIs for the stack (the coroutine stack is a
mapping the runtime owns, not the thread's), a 4 KiB page, or an allocator
different from Linux's. The stack comes from the same pool and `mmap`, with:

- flags `MAP_PRIVATE | MAP_ANONYMOUS` on Darwin (`MAP_STACK` does not exist
  there; `MAP_NORESERVE` is a no-op, so it is left out) and the Linux flags
  unchanged;
- guard and usable size rounded up to `sysconf(_SC_PAGESIZE)` (16 KiB on the
  Apple Silicon runners, as milestone 1 observed; the guard constant, 64 KiB,
  is already a multiple of it).

No Mach VM API, `MAP_JIT` or `mprotect` machinery was added, and the JIT's
memory handling is untouched.

## 7. Frame-pointer handling

Apple requires a frame-pointer chain; Cranelift's Apple AArch64 frames and
rustc's calling functions keep it, and the walker (`framewalk`) climbs it
through Botlish frames and the Rust helper frames between them. The switch
opens its record first, so a suspended stack's chain starts at `saved_sp +
160` with the saved `x29`/`x30` of its caller (`rt_co_yield`) and climbs
through the body and `co_body` to the trampoline's zero record. Linux
x86-64's trampoline record is only 8-aligned (its call is aligned by its own
`sub`), so the chain test requires 16 only on AArch64. `.cargo/config.toml`
now states the dependence for `aarch64-apple-darwin`
(`-C force-frame-pointers=yes`), as for the three other hosts.

## 8. Active versus suspended stack representation

There are three kinds of stack, and the code keeps them apart:

1. *The OS-managed thread stack.* On macOS `Vm::native_stack` is `None` (no
   discovered bounds: milestone 5), so the walk of the main stack has no
   address bound and ends where the chain does (a null or non-ascending
   frame pointer), as it already did for ordinary programs.
2. *A Botlish-managed coroutine stack.* `CoStack` owns the mapping;
   `CoStack::bounds()` is a `NativeStack` with `low_bound` above the guard,
   `high_bound` the top, and `guard_low` the guard's start, used to bound
   every walk of that stack.
3. *The active stack at a point.* `Vm::co_current` is the running
   coroutine (null: the main stack); each running coroutine records its
   resumer's saved sp. `publish_active_stack` tells the overflow handler
   which stack is running; it is a no-op on macOS, where there is no handler
   yet.

The milestone-5 work can use these as they are: a coroutine's bounds and
guard are representable, distinct from the thread's, and not Linux-specific.

## 9. GC-root integration

Unchanged and shared. A suspended coroutine is an ordinary heap object whose
marking walks its stack; the running chain is walked by `collect_with`; the
transport slot, thunk and cached failure are traced as fields. Two
macOS-only points were audited:

- *The shadow-stack depth token.* Without a native overflow guard, every
  calling function bumps the Vm's `ss_top` by one (zeroed) slot on entry and
  restores the saved absolute value on exit
  (`codegen/clif.rs prologue_depth_token`). Linux has no token. Coroutine
  segments interleave these non-LIFO, but the slots only ever hold zeros
  (roots are `NativeFrame` for every function on AArch64) and `ss_top` takes
  only values some frame once saw, so no collection can read stale data from
  it, and none can exceed the limit that a plain nest would.
- *What the token does not do:* bound a recursion by a coroutine's 8 MiB
  stack. See the limitations.

## 10. Error and cleanup behavior

All of it is the shared code, exercised on macOS by the existing coroutine
corpus (errors at startup and in segments, handled and propagated across
resumes, a failed handle raising its cached error again, completed handles
returning their cached value, affine payloads, release on every exit, 2000
abandoned constructions mapping one stack): `coroutines.test`,
`error-payloads.test`, `affine.test` and the golden suites passed on macOS.
The bounded lifecycle test of the Rust suite
(`repeated_lifecycles_map_one_stack_and_reuse_it`: 300 create/start and then
complete, release or abandon) maps at most 52 stacks and reuses the rest;
the pool never exceeds its limit. Resumption after completion, a resume of a
running or released coroutine, and a `yield` outside a coroutine are the
existing `COROUTINE-*` and `YIELD-OUTSIDE-COROUTINE` errors, tested.

## 11. Focused coroutine tests

Rust (`native/src/runtime/coroutine.rs`, run on all three hosts):

| Test | Pins |
|---|---|
| `callee_saved_registers_survive_every_switch` | x19-x28 / rbx, r12-r15 and d8-d15 across a resume and a yield, per-context patterns |
| `fpcr_is_part_of_the_context` (AArch64) | a rounding mode set in a coroutine does not leak to its resumer and is kept across a yield |
| `a_new_context_starts_with_the_threads_fpcr` (AArch64) | the constant 0 `prepare` writes is the thread default (true on Darwin) |
| `the_stack_pointer_is_aligned_and_on_the_coroutines_stack` (AArch64) | sp at the body, after each yield, 16-aligned and inside the mapping |
| `a_suspended_stacks_frame_chain_ends_in_the_trampolines_zero_record` | the chain from `saved_sp + offset` ascends, stays in bounds, ends in `(0, 0)` |
| `repeated_lifecycles_map_one_stack_and_reuse_it` | resource stability of repeated lifecycles |

Existing Rust tests (yield/resume, failures and payloads, nested, GC-forced
collections inside and between segments, abandonment) now run on macOS too.

Tcl: `co-gc-nested-suspended-roots` (and its `-stress` twin): two outer
coroutines, each driving a failing inner coroutine, with lists, structs and
strings held only by suspended frames of both while every party allocates;
every backend, and both native backends with a collection before every
allocation. Beside the earlier `co-gc-suspended-stacks` (deep yields, several
suspended coroutines, strings and lists) and `co-gc-many-coroutines`.

## 12. Native golden runner results and 13. census before and after

Census: `CI-Tests: all` on macOS arm64 (run 39161417599; every Tcl test file
on interp and compile, every golden suite on all four backends, the Rust
tests, cabi and the examples; three shards).

| | Milestone 2 | Milestone 3 |
|---|---|---|
| native coroutine program | `NATIVE UNSUPPORTED value` | returns `[10, 7]` |
| golden suites, native runs | 78 cranelift + 71 cranelift-generic runs blocked by the refusal | every native run passes (94 suites in shards of 32 + 31 + 31); the suites that do not run natively are exactly the Linux programs below and the ones that already carry a `golden-exclude` with its reason |
| Tcl test files failing | 119 tests in 16 files (`notYet`) | `c-bindgen.test` (1: the fixture's manifest records Ubuntu's clang) and `c-ffi.test` (1: `cf-missing-library`, wording of the Linux linker), both milestone 7's |
| Rust tests | 215 library + driver's 37 | the same plus the six above; all pass |
| smoke, acceptance, linux control | success | success |

Eligible suites: the Linux programs (the 16 suites that import a Linux
namespace, as in milestone 2) compile for `linux-aarch64` and run on the Tcl
backends, their native runs excluded with the reason (`NATIVE TARGET`: a
matching architecture is not a matching target); two of them declare
`golden-host: linux-x86_64` and compile only. That is the
platform-target selection of milestone 2, unchanged.

The 14 files `notYet` held for native coroutines and `golden-framework`,
`higher-order-completions` and `virtual-construction` (the files that gate on
`nativeCoroutines`) first ran as named items (run 39157740967): 815 tests, 809
passed, 5 skipped by their constraints (`executableAot`, `nativeLinux` x2,
`stubLinker` x2) and 1 failed. The failure was not a coroutine defect:
`ci-golden-pair` compiled `traits-path.bot`, which imports a Linux namespace,
for the host target. It was unreachable behind `notYet`; it now builds for
`linuxTarget` and runs on `backendsFor` that target, like every test of a
Linux program (milestone 2's rule), and passed in the census.

No suite was skipped to improve a count, and no exclusion was added.

## 14. GC-stress results

Run 39166998920 (head 3fec593): `CI-Tests: acceptance rust`, `CI-GC-Stress:
1`: the acceptance tier (every Tcl test file but the two above on interp and
compile, every golden suite on all four backends) and the Rust tests under
`BOTLISH_NATIVE_GC_STRESS=1`, three shards.

Result: shards 2 and 3 **passed**. In shard 1, every Tcl test file on
interp and compile (64 files) and all 32 golden suites on all four backends
passed under stress (the suites in 273 s); the one failure was the native
Rust tests, **one test of 241**:
`runtime::ops::tests::bytes_from_list_copies_every_byte_exactly_including_nul_and_high_bytes`
(`assertion left != right failed`, ops.rs:3920: the same address twice). It
is the unrooted Rust local milestone 1 reported, in a test that has nothing to
do with coroutines: under stress a collection frees an object that only a
Rust local holds and the allocator hands its address out again, which Linux's
allocator happens not to do. A rerun of just the Rust tests under stress
(run [39171832146](https://github.com/mwagner-webdev/botlish/actions/runs/39171832146))
reproduced it identically: 240 passed, 1 failed, with every coroutine,
framewalk, affine and mutvec test among the passing. It does not block
coroutine validation, so, as the task said, it is **not fixed here** and is
left for the stack/GC robustness milestone; it should be fixed by rooting the
list in that test, not by touching the collector. Because `cargo test` stops
at the failing library target, the driver's own 37 tests did not run under
stress on macOS in that step (they run, and passed, in the census without
stress).

What the stress run covers for suspended roots: `co-gc-stress`,
`co-gc-nested-suspended-roots-stress`, `ep-gc-stress-coroutine`,
`mv-affine-gc-stress`, `sc-gc-stress`, `gf-gc-stress` and `vc-gc-collect-1`
(a plan suspended on a coroutine stack while the body allocates) run
natively with a collection before every allocation, and the golden runner
itself is a coroutine holding every registered case across the collections of
each test.

Linux: the local run of the Rust coroutine tests under GC stress passed;
`tests.yml` and `tests-arm64.yml` run their GC-stress jobs on `main`.

## 15. Linux x86-64 regression results

Locally: `cargo test --release --lib coroutine` (11 tests, also under
`BOTLISH_NATIVE_GC_STRESS=1`), `tests/coroutines.test` (79 of 79, before the
new tests), `tests/golden-framework.test` (42 of 42), `tests/affine.test`
(48 of 48), `audit/coroutines/tools/fuzz.tcl` on three seeds (36 programs,
0 disagreements). In CI: `tests.yml` run
[39157572693](https://github.com/mwagner-webdev/botlish/actions/runs/39157572693):
success (dispatched on 4dafa4e, the last commit that changed runtime code or
test gating), and again on the final head f2e2059, run
[39173139465](https://github.com/mwagner-webdev/botlish/actions/runs/39173139465):
success.

## 16. Linux AArch64 regression results

The AArch64 text is shared with Linux, so it was run before CI: the Rust
coroutine tests built for `aarch64-unknown-linux-gnu` and run under
qemu-user (14 tests, including the register, FPCR, alignment and chain tests)
all pass. In CI: `tests-arm64.yml` run
[39157574996](https://github.com/mwagner-webdev/botlish/actions/runs/39157574996):
success (native AArch64 runner, same commit as above).

## 17. macOS GitHub Actions runs

| Run | Commit | What | Result |
|---|---|---|---|
| [39156946975](https://github.com/mwagner-webdev/botlish/actions/runs/39156946975) | 6b1d98d | first push: smoke, Tier C `coroutines.test` | smoke and the Tier C job: success (the run was then cancelled by the next push) |
| [39157740967](https://github.com/mwagner-webdev/botlish/actions/runs/39157740967) | ddb77a2 | Tier C: 14 `notYet` files + 3 gated files + Rust | 809/815; the one failure is `ci-golden-pair` (above) |
| [39161417599](https://github.com/mwagner-webdev/botlish/actions/runs/39161417599) | d1bca21 | the census, `CI-Tests: all` | smoke, acceptance 1/2 and 2/2, linux control, shard 3: success; shards 1 and 2: failed only on `c-bindgen.test` and `c-ffi.test` |
| [39166998920](https://github.com/mwagner-webdev/botlish/actions/runs/39166998920) | 3fec593 | acceptance (native golden) + Rust tests, `CI-GC-Stress: 1` | shards 2, 3, smoke, acceptance, linux control: success; shard 1: everything passed except one unrelated Rust test (section 14) |
| [39171832146](https://github.com/mwagner-webdev/botlish/actions/runs/39171832146) | a179572 | `workflow_dispatch`: `tests=rust`, `gc_stress=true` | the same one Rust test fails; 240 others pass |

The `CI-Tests:` trailers were verified with `git interpret-trailers --parse`
before each push (milestone 2's mistake: a trailer outside the last
paragraph); every run took the items asked for.

## 18. Mutation and negative testing

AArch64 switch and `prepare`, on Linux AArch64 under qemu-user (these are
the instructions macOS runs, but the mutants were not run on a macOS runner,
so what is unverified is a Mach-O-only defect; a Mach-O text defect would
fail the macOS suite instead):

| Mutant | Result |
|---|---|
| `ldp d8, d9` restore skipped | killed: `callee_saved_registers_survive_every_switch` |
| `ldp x27, x28` restore skipped | killed: the same |
| `msr fpcr` restore skipped | killed: `fpcr_is_part_of_the_context` |
| initial sp misaligned by 8 | killed: the sp and the chain tests |
| trampoline's `mov x30, xzr` removed | killed: the chain test |
| initial `x29` nonzero | killed: the chain test |
| `mov x29, sp` removed from the switch | **equivalent**: nothing in the switch reads `x29`, and the saved record is identical; not claimed as killed |

Before the per-context patterns, the first mutant survived (the same pattern
in both contexts looked restored): the test was strengthened, not the claim
weakened.

The repository's own coroutine mutants (`audit/coroutines/tools/mutate.tcl`,
the 11 native ones, which edit `coroutine.rs` and rebuild a private copy):

**all 11 killed** (7 in one pass, 4 in a second after the harness process
was lost with its shell; each by the Tcl tests, the fuzzer and the Rust
tests): `native-construction-lazy`, `native-first-yield-discarded`,
`native-completed-raises-exhaustion`, `native-completed-reruns-body`,
`native-failed-loses-error`, `native-message-wrong-yield`,
`native-deep-stack-not-preserved`, `native-release-not-emitted`,
`native-release-keeps-stack`, `native-exit-release-missing`,
`native-error-release-missing`. For the last four the Rust tests did not
detect the mutant (they test the runtime, not the lowering); the Tcl tests
and the fuzzer did. They ran on Linux x86-64, against the shared logic; none
was run on macOS. The fuzzer ran three more seeds on the final code: 36
programs, 0 disagreements.

Not exercised: stack alignment of the Mach-O build by mutation (the
alignment test passes on macOS; no mutant ran there), unregistered suspended
roots (an unrooted suspended frame is `co-gc-nested-suspended-roots-stress`
and the existing native-mutant `native-deep-stack-not-preserved` territory,
run on Linux). No mutant of Cranelift's frames was attempted, as asked.

## 19. Surprises

- *Nothing in the switch needed to change for Apple,* once the directives
  did. FPCR on a fresh Darwin thread is 0; Apple's frame records, the 16 KiB
  page and the reserved `x18` needed no code beyond rounding and the flags.
- *A mutation survived the first register test* because both contexts loaded
  the same pattern; the fix was a seed per context.
- *x86-64's trampoline record is 8-aligned,* so a general "records are
  16-aligned" assertion would be wrong there.
- *The depth token is the macOS-only mechanism coroutines had never met:*
  non-LIFO use of `ss_top` is benign (audited, section 9), but it also means
  that the token bounds neither a coroutine's stack nor, on macOS today,
  anything else natively.
- *`ci-golden-pair`* was a milestone 2 gap hidden by `notYet`, found the first
  time the file ran.
- Cranelift prologues, return-address handling and SIMD preserved registers
  needed no special handling beyond the above; the frame-pointer chain
  through Rust helper frames held under GC stress.

## 20. Remaining limitations and prerequisites for the stack-overflow milestone

- *Overflow of a coroutine's stack on macOS is a crash,* not
  `NATIVE LIMIT STACK`: the guard page faults and nothing handles it, as for
  the main thread (native-status still records the Rust abort for the main
  stack). A test of a recursion deeper than a coroutine's 8 MiB stack is
  constrained to Linux (`co-errors-uncaught-native-limit`, `nativeLinux`) and
  no expected-crash probe runs in the CI test process.
- *Prerequisites for milestone 5, in place:* `CoStack::bounds()` gives each
  coroutine stack a `NativeStack` with its guard; the active stack is
  published through `Vm::publish_active_stack` (a no-op on macOS now); the
  guard and size follow the host page size. Missing: the thread's own bounds
  and guard on macOS (`Vm::native_stack` is `None`), a handler, and the
  question of whether the depth token stays once a guard exists.
- *Unchanged and explicit:* Mach-O executables (`NATIVE AOT`), C calls
  (`NATIVE LINK`), `linux::*` imports (`UNSUPPORTED-PLATFORM`), macOS x86-64
  and Windows (the unsupported refusal now names the three supported hosts).
