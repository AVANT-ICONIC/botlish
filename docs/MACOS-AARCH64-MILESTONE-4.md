# MACOS-AARCH64-MILESTONE-4.md

Milestone 4 of the macOS Apple Silicon port: native stack bounds, overflow
detection and its recovery. Developed on Linux; every macOS fact below was
observed on GitHub's `macos-15` arm64 runners through
`.github/workflows/macos-arm64.yml` (the shared Apple Silicon development
machine was not used). The audit it updates is MACOS-AARCH64-PORT-AUDIT.md
(sections 4-8, 11, 15-17; its roadmap calls this milestone entry 5); the
milestones before it are MACOS-AARCH64-MILESTONE-1.md to -3.md.

> Stack exhaustion is a defined Botlish failure, not a platform crash.

## Result

@@RESULT@@

## 1. Initial failure evidence

Gate A: the milestone's tests, pushed first against the unchanged runtime
(commit a76d76f, run
[39286923808](https://github.com/mwagner-webdev/botlish/actions/runs/39286923808),
Tier C `CI-Tests: native-stack-overflow.test rust`). How a native stack
overflow ended on macOS before this milestone, by the driver's own exit:

| Program | Stack | Before (macOS arm64) |
|---|---|---|
| stack_overflow.ir (driver, tiny frames) | 4 MiB thread | `thread '<unknown>' has overflowed its stack` / `fatal runtime error: stack overflow, aborting`: **SIGABRT** (Rust's own guard handler) |
| large_frame_overflow.nir (600 live roots) | 4 MiB thread | the same SIGABRT |
| `down(10^8)`, `wide(10^8)` from source | 1 GiB thread | **SIGSEGV** (`child killed: segmentation violation`) on both native backends |
| `keep(10^8)` (a String held across the call) | 1 GiB thread | `NATIVE LIMIT STACK` -- from the shadow-stack depth token (4M frames), reached before the stack ended for these small frames |
| `rec(10^8)` through a Fn value | 1 GiB thread | SIGSEGV on cranelift, the token's `NATIVE LIMIT STACK` on cranelift-generic |
| `keep(10^8)` | 1 MiB thread | SIGABRT (Rust's handler) |
| any recursion on a coroutine's stack (fresh, after yields, nested, with the resumer holding references) | 8 MiB coroutine | **SIGBUS** (`child killed: bus error`) |
| the edge bisection of a coroutine stack | 8 MiB coroutine | the first probe already crashed |
| under GC stress: 1 MiB thread / 128 KiB coroutine | | SIGABRT / SIGBUS |

13 of the 18 tests of native-stack-overflow.test failed, on both Tcl
backends (Tier C job
[118176167315](https://github.com/mwagner-webdev/botlish/actions/runs/39286923808/job/118176167315)).
Four of the five that passed never overflow (`native-stack-shallow-1`'s
fib, `native-stack-gc-1`'s 400 frames under GC stress, `ns-main-finite`,
`ns-co-nested-finite`); the fifth, `native-stack-overflow-default-size`,
passed through the depth token: stack_overflow.ir's tiny frames reach its
4M frames before the 1 GiB stack ends. So: a thread-stack overflow was Rust's abort when the
fault hit the guard page Rust knows, a SIGSEGV when it did not, and the
depth token's in-band error only when frames were small enough for 4M of
them to fit; a coroutine-stack overflow was always a SIGBUS.

## 2. The Linux overflow architecture this milestone started from

Audited at 05a3389, the branch's base (NATIVE-STACK-OVERFLOW.md is its
design record). The path from a deep Botlish recursion to the user-visible
diagnostic, on Linux x86-64 and AArch64:

1. **Where Botlish runs.** Not on the process's main thread: the driver
   (main.rs `main`) and a standalone executable (runtime/aot.rs `run`) spawn
   a worker with `std::thread::Builder::stack_size` -- 1 GiB, or
   `BOTLISH_NATIVE_STACK_BYTES` (at least 1 MiB) -- and the JIT code, the
   Rust runtime helpers and C calls all run on it.
2. **Bounds.** `NativeStack::current()` (runtime/native_stack.rs) read the
   worker's own stack with `pthread_getattr_np`, `pthread_attr_getstack`
   and `pthread_attr_getguardsize` (platform/linux.rs): the usable range
   `[low_bound, high_bound)` and the guard `[guard_low, low_bound)` glibc
   reports directly below it. `Vm::new` stores it (`Vm::native_stack`); the
   collector's frame walk is bounded by it (runtime/framewalk.rs).
3. **Compiler side.** `native_stack_overflow_supported()` was true on Linux
   x86-64 and AArch64 only. It turns on Cranelift's inline stack probes for
   frames of 4 KiB and more (codegen/mod.rs `isa`), so no frame steps over
   the guard, and it removes the shadow-stack depth token
   (codegen/roots.rs `depth_reservation`) and the shadow array (vm.rs).
4. **Install.** Before running the entry function, the worker installs
   `OverflowGuard` (main.rs `execute`, aot.rs): a 64 KiB alternate signal
   stack (`sigaltstack`), `SA_SIGINFO | SA_ONSTACK` handlers for SIGSEGV
   and SIGBUS, the guarded thread's id (`syscall(SYS_gettid)`), and the
   running stack's guard and low bound in two relaxed atomics. The driver's
   `--result PATH` file descriptor is recorded first (`set_result_fd`), so
   the report goes where the other result lines go.
5. **Coroutines.** Each coroutine runs on its own mapped stack with a 64 KiB
   `PROT_NONE` guard (`CoStack::bounds()`); `segment` published the
   coroutine's bounds before switching to it and the resumer's after
   switching back (`Vm::publish_active_stack` -> `set_active_stack`).
6. **The fault.** The stack pointer descends into the guard; the first
   store (a probe, a frame record, a spill) faults; the kernel delivers
   SIGSEGV on the alternate stack. The handler compares the thread id and
   checks `guard_low <= si_addr < low_bound`.
7. **Report.** It writes the constant line `error {NATIVE LIMIT STACK}
   {native stack exhausted: too many nested calls}` with `write(2)` to the
   result descriptor (standard error for a standalone executable) and calls
   `_exit(0)` (`_exit(1)` for an executable). It is byte for byte the line
   the driver's `emit_error` writes for an in-band `RtError::StackOverflow`.
8. **Host side.** native/native.tcl's `RunDriver` reads the result line
   (from the pipe, or the `--result` file when the program's output is
   inherited); `native::Outcome` raises the error code `NATIVE LIMIT
   STACK`; main.tcl prints `error: native stack exhausted: too many nested
   calls (NATIVE LIMIT STACK)` and the `help:` line of the
   `error.native-limit-stack` topic. A standalone executable's line is on
   its standard error, its status 1.
9. **Any other fault** was re-raised with `SIG_DFL`: the process died with
   the signal, never with the line.

What this architecture is, and is not:

- *Detection is a guard fault, not a preventative check.* There is no
  stack-limit comparison in generated code (that was the depth token's
  role on fallback hosts); the probes only make sure the guard is touched.
- *Recovery is termination with the defined error.* Nothing resumes: no
  `siglongjmp`, no rewritten signal context, no unwinding. NATIVE LIMIT
  STACK is not a declared error -- no Botlish `on` handler can catch it on
  any backend (the Tcl backends' TCL LIMIT STACK is the same kind of
  resource limit) -- so ending the native invocation is its contract, not a
  shortcut. Nothing of the run needs restoring because the process ends;
  the OS reclaims every stack, mapping and heap block.
- *Portable vs. Linux-specific.* Of the pieces, only `pthread_getattr_np`
  (glibc), `SYS_gettid` and `MAP_STACK` were Linux's; `sigaltstack`,
  `sigaction`, `SA_ONSTACK`, `si_addr`, `write` and `_exit` are POSIX; the
  coroutine switch is per architecture (shared by Linux and macOS AArch64
  since milestone 3); the probes and the token are the compiler's.

Two gaps the audit found in it, both closed here (sections 8 and 9):

- **The switch window.** `segment` published the coroutine's stack *before*
  calling `bl_co_switch`, whose first instructions store 176 bytes
  (AArch64; 56 on x86-64, below the call's return address) on the stack it
  is *leaving*. A resume made close enough to the end of the resumer's stack
  therefore faulted in the resumer's guard while the coroutine's was
  published: unclassified, the process died of SIGSEGV (or Rust's abort)
  instead of reporting. Not hypothetical: with the old order put back (the
  mutant `publish-before-switch`, section 18), the new sweep test (section
  9) crashes at every resume made 48 to 176 bytes above a stack's end on
  Linux x86-64 -- nine offsets of 16 bytes each -- from the thread's stack
  and from a coroutine's alike.
- **Two stores for one fact.** The guard and the low bound were published
  as two relaxed stores; a fault between them would read one stack's guard
  with another's bound. No fault can occur between them today, but nothing
  ordered them for the handler either.

## 3. Changes by file and subsystem

Runtime (native/src):

- `runtime/platform/guard.rs` (new): the stack-overflow guard, moved out of
  linux.rs and shared by the three hosts -- the handler, the alternate
  signal stack, the published running stack, the result descriptor,
  `OverflowGuard` and `set_active_stack`. Changes against the Linux
  original: publication is a double buffer (section 8); an unrelated fault
  goes to the disposition the process had before the guard, not `SIG_DFL`
  (section 17); the alternate stack is `max(SIGSTKSZ, 64 KiB)` (64 KiB on
  Linux as before, 128 KiB on macOS); a second guard in one process is
  refused (`AlreadyExists`) instead of silently sharing the statics; the
  handler calls the host's `thread_token`.
- `runtime/platform/macos.rs` (new): `current_stack` (pthread bounds, the
  usable low bound, the confirmed guard: section 4), `thread_token`
  (`pthread_self`), `region` (`mach_vm_region`, declared locally: the libc
  crate has no Mach VM calls), with unit tests of the region reader against
  a mapping the test protects itself.
- `runtime/platform/linux.rs`: keeps `current_stack` unchanged and adds
  `thread_token` (`gettid`, as the handler used); the handler and guard
  left for guard.rs.
- `runtime/platform/mod.rs`: the facade (`current_stack`, `thread_token`,
  `OverflowGuard`, `set_active_stack`, `set_result_fd`,
  `published_stack`); `runtime/mod.rs` compiles it on the three hosts.
- `runtime/native_stack.rs`: `NativeStack::current()` and
  `native_stack_overflow_supported()` include macOS AArch64. That one
  predicate turns on the stack probes (codegen/mod.rs) and removes the
  depth token (codegen/roots.rs) and the shadow array (vm.rs) on macOS;
  no codegen file changed.
- `runtime/vm.rs`: `native_stack` and `publish_active_stack` (now
  `#[inline(always)]`) on the three hosts, through the facade.
- `runtime/coroutine.rs`: the arriving side of every switch publishes its
  stack -- `co_body` at a coroutine's first entry, `rt_co_yield` when
  resumed, `segment` when a segment returns -- and nothing publishes before
  switching away (section 8).
- `main.rs`, `runtime/aot.rs`: install the guard and record the result
  descriptor through the facade, under the platform module's cfg (main.rs
  had a looser `target_os = "linux"` for `set_result_fd`).

Tests:

- `native/tests/native_stack.rs` (new; `harness = false` in Cargo.toml, so
  its `main` runs on the process's main thread): the stack facts and every
  faulting check, each fault in a child process (sections 5-17).
- `tests/native-stack-overflow.test`: 14 new tests (thread stack, coroutine
  stacks, nesting, the edge, GC stress; sections 11-14), all on both native
  backends; the file's own Linux-only constraint replaced by the capability.
- `tests/helpers.tcl`: the capability `nativeStackGuard` (linux-x86_64,
  linux-aarch64, macos-aarch64), beside milestone 3's `nativeCoroutines`.
  `coroutines.test`'s `co-errors-uncaught-native-limit` carries it instead
  of `nativeLinux`; the depth-helper expectations of native-stack-map.test
  (`stack-map-fib-1`, `-2`) and native-root-storage.test
  (`storage-call-crossing-2`) follow it instead of an OS test.
- `tests/platform/native-status.tcl`: the macOS `stack-overflow` probe
  expects `NATIVE LIMIT STACK` (it expected Rust's abort); a new probe,
  `coroutine-stack-overflow`, expects it on every host.
- `tests/platform/tier.tcl`: the item `native-stack-mutants`.
- The golden migration census (`audit/golden/migration/census/
  native-stack-overflow.tsv`, `tcl-names.txt`) and the regenerated
  `tests/golden/manifest.tsv`: one KEEP-RUNTIME-ONLY row per new test.

Tools and CI: `audit/native-stack/tools/mutate.tcl` and `mutants.txt`
(section 18); `bench/native-stack-guard.tcl` (section 22);
`.github/workflows/macos-arm64.yml`: the smoke job runs
`cargo test --test native_stack`.

Documentation: this report; MACOS-AARCH64-PORT-AUDIT.md;
NATIVE-STACK-OVERFLOW.md (a note of what changed since Phase B);
COROUTINES.md (publication on arrival); AGENTS.md ("The native stack
guard"); Compilerpedia's `error.native-limit-stack` (coroutine stacks,
hosts, `BOTLISH_NATIVE_COROUTINE_STACK_BYTES`) and `backend.platforms`
(`tools/compilerpedia.tcl check`: 674 topics, 0 problems); docs/INDEX.md.

Not touched: the compiler front end, HIR, NIR, the code generator's
source, the collector, the coroutine switch's assembly, the error codes and
messages, the driver protocol.

## 4. macOS pthread stack discovery

`platform/macos.rs` `current_stack`, on the calling thread:

1. `pthread_get_stackaddr_np(pthread_self())` is the stack's **highest**
   address (the stack grows down from it) and
   `pthread_get_stacksize_np(pthread_self())` its size, so libpthread
   reports `[top - size, top)`. Both are public libpthread calls (the
   `_np` ones Rust's std itself uses on macOS); no VM scan finds the stack.
2. **The usable low bound** is the first accessible address at or above
   the reported bottom: `usable_low` steps over inaccessible mappings at
   the reported bottom (at most four). On a created thread it is the
   reported bottom; on the process's main thread it is one page above it
   (section 5).
3. **The guard** is the run of inaccessible mappings that ends exactly at
   the usable low bound (`confirmed_guard_low`, at most four mappings), read
   with `mach_vm_region` (Mach's public VM interface: the mapping containing
   an address, its bounds and current protection). Nothing inaccessible
   directly below the stack means no confirmed guard: `guard_low ==
   low_bound`, and `OverflowGuard::install` refuses the stack ("the
   thread's stack has no confirmed guard"), as Linux refuses a thread whose
   glibc guard size is 0.

Why the guard is confirmed, not assumed: the reported end of a stack is not
evidence of what lies beyond it. The runner showed both ways it can mislead
-- the main thread's reported bottom page is itself inaccessible, and below
a thread made with a zero guard size lies *another thread's live stack*
(section 6). What confirmation reads is protection, not ownership: a
thread created with libpthread's default attributes (Rust's
`thread::Builder` sets only the stack size) has its guard at the bottom of
its own allocation, so the inaccessible mapping directly below its stack is
its own (libpthread's `_pthread_allocate`, and the runner's evidence below).

The same three facts serve both kinds of thread; the main thread needs no
code path of its own. Botlish never runs a program on the main thread (the
driver and executables use the worker), so the main thread's facts matter
for the claim that discovery is correct there, not for a run.

## 5. Observed main-thread stack facts

Observed by native/tests/native_stack.rs on the process's own main thread
(Gate A, run 39286923808; the same layout in every later run, at other
addresses: ASLR):

| Fact | Value |
|---|---|
| page size (`sysconf(_SC_PAGESIZE)`) | 16384 (16 KiB) |
| `ulimit -s` | 8176 KiB (milestone 1's census) |
| reported stack `[top - size, top)` | `[0x16ce74000, 0x16d670000)`, 8176 KiB: the rlimit |
| stack pointer in `main` | 0x16d66d1f0, 11 KiB below the top: inside |
| 200 nested calls | every stack pointer inside, each below its caller's |
| the reported bottom page `[0x16ce74000, 0x16ce78000)` | **inaccessible** (`---`, 16 KiB); a read of it: SIGSEGV |
| below it, `[0x169670000, 0x16ce74000)` | inaccessible, 57360 KiB |
| accessible | `[0x16ce78000, 0x16d670000)`, 8160 KiB |

So the reported size includes one inaccessible page: 57360 + 16 + 8160 KiB
is 64 MiB, the kernel's reservation for the main thread's stack, of which
only the top 8160 KiB are accessible. The runtime's reading (section 4):
usable `[0x...78000, top)`, guard the two inaccessible mappings below it,
56 MiB in all; a hit of the main thread's guard raises **SIGSEGV**. Linux,
for comparison: glibc reports the main thread's stack from the rlimit with
a guard size of 0, so it has no confirmed guard there and the guard refuses
it (also checked: `guard main driver` is "refused" on Linux).

The runtime's reading on the runner (run 39293822194, smoke): `runtime
stack main: [0x16afe0000, 0x16b7d8000) (16 KiB above the reported bottom),
guard [0x1677d8000, 0x16afe0000) 57376 KiB`; the usable bottom is readable,
the reported bottom and both ends of the guard fault (SIGSEGV), and a
guard installed on the main thread turns an exhaustion of it into the
overflow line (`guard main driver`).

Main-thread differences that matter: the reported bottom is not usable,
the guard is a large reservation rather than one page, and its hit is a
SIGSEGV where a created thread's is a SIGBUS. None of it is special-cased:
the same two walks find it.

## 6. Observed created-thread stack facts

The same probe on created threads (Gate A, run 39286923808):

| Thread | Reported stack | Top in its page | Below the stack | A read below |
|---|---|---|---|---|
| std, default size | 2060 KiB | 12 KiB into a 16 KiB page | one inaccessible 16 KiB mapping | SIGBUS |
| std, `stack_size(1 MiB)` | 1036 KiB | the same | the same | SIGBUS |
| std, `stack_size(1 GiB)` (the driver's worker) | 1048588 KiB = 1 GiB + 12 KiB, at 0x300004000 | the same | the same, at 0x300000000 | SIGBUS |
| raw pthread, guard size 4 pages | 1036 KiB | the same | one inaccessible 64 KiB mapping | SIGBUS |
| raw pthread, guard size 0 | 1036 KiB | the same | **accessible: another thread's stack** (here the main thread's) | survives |

- Every reported bottom was accessible and page-aligned, and every stack
  pointer inside its stack; the top is not page-aligned (libpthread places
  the thread's own descriptor directly above the stack, in the same
  page-rounded allocation, so the stack gets the rounding's slack: 12 KiB).
- The 1 GiB worker's stack spans several VM map entries (the lowest is
  128 MiB), all accessible; `mach_vm_region` reports each, and the walks
  only look at the bottom and below it.
- The default guard is exactly one VM page (16 KiB), directly below the
  stack: libpthread's `vm_page_size` default. A thread made with a guard
  size gets that guard (64 KiB). A thread made with none has nothing
  between its stack and the next allocation -- the case the confirmation
  exists for.
- The runtime's reading (run 39293822194): the reported bounds and a
  confirmed 16 KiB guard on every std thread (64 KiB on the four-page
  pthread), both guard ends faulting with SIGBUS; no confirmed guard on the
  zero-guard pthread, which the guard refuses to install on.
- Botlish creates no threads besides its one worker, and a Botlish program
  cannot create any; the created-thread validation above is of
  libpthread's threads as the runtime finds them, not of a threading
  system.

## 7. Page size and guard handling

- **The page is 16 KiB** on the runner (`sysconf(_SC_PAGESIZE)`, printed by
  every native_stack run); nothing in the new code assumes a size: the
  guard's extent is read from the VM system, and the probes' 4 KiB spacing
  is Cranelift's (`probestack_size_log2` 12), below any page size. The
  tests read the page size; none hard-codes one (the mutant
  `page-size-4096`, section 18).
- **The thread guard** is 16 KiB (one page) on a created thread, 56 MiB of
  reservation on the main thread; a coroutine's guard is the runtime's own
  64 KiB `PROT_NONE` (milestone 3, rounded to the page). Every guard is
  larger than the probe spacing plus the 128-byte red zone, so the first
  access below a stack's end -- a probe, a frame record, a spill, a store in
  the red zone -- lands in the guard: a 64 KiB Rust frame (Rust's own
  inline probes) and the 600-root Cranelift frame of large_frame_overflow.nir
  (Cranelift's) both end in `NATIVE LIMIT STACK` on macOS (sections 11, 18).
- **Which signal.** A hit of a created thread's guard or of a coroutine's
  is SIGBUS on macOS (a protection fault on a mapped page), of the main
  thread's reservation SIGSEGV; Linux raises SIGSEGV for all. The handler
  takes both signals on every host and decides by address alone.

## 8. Active-stack publication

Which stack is running is a fact the runtime publishes, never one the
handler infers: one per thread at a time, and only the guarded thread runs
Botlish code.

- **Representation.** The one `NativeStack` type: the thread's own is
  `Vm::native_stack` (from `NativeStack::current()`, the same value the
  guard was installed with), a coroutine's is `CoStack::bounds()`. The
  guard keeps no stack metadata of its own beyond the published pair.
- **Publication** (`platform::set_active_stack`, called through
  `Vm::publish_active_stack`) stores the running stack's `(guard_low,
  low_bound)` into the one of two slots not in use, then selects it with a
  single release store; the handler reads the selector, then that slot.
  Whatever instruction a fault interrupts -- a publication's own included
  -- the handler reads one stack's pair, never one stack's guard with
  another's bound. Inlined, atomic stores only: publishing adds no frame.
- **Who publishes, and when: the side that arrives, after the switch.**
  `co_body` publishes a coroutine's stack when it first runs on it,
  `rt_co_yield` when the coroutine is resumed, `segment` the resumer's
  stack (the thread's, or an outer coroutine's) when a segment returns to
  it -- after a yield, a completion or a failure alike. Nothing publishes
  before switching away. So during `bl_co_switch`'s pushes, which land on
  the stack being *left*, that stack is still the published one; and the
  arriving code publishes before it can grow its stack past where it was
  (it resumes inside a frame that already exists, and publishing adds no
  frame).
- **Nesting.** In main -> a -> b -> c, while c runs its stack is the
  published one, not a suspended or running ancestor's; when c completes,
  b's `segment` publishes b's; when b yields, a's; and so on to the
  thread's. A released or swept coroutine's stack is never published: only
  a running coroutine's is, and a stack returns to the pool only once its
  coroutine is terminal or released, after the resumer has published its
  own.
- **Checked** by native_stack's `publication` (the published pair, read
  back with `platform::published_stack`, equals the running stack's at
  seven points of a nested lifecycle: the thread before and after, a
  started, a after starting b, b started, a resumed, b resumed, a after b
  completed) and by the sweep (section 9) across the switch itself.

## 9. The detection and recovery mechanism

**Chosen: B, guard-fault handling -- Linux's mechanism, made shared, with
its two gaps closed.** A considered A, preventative checking (a stack-limit
comparison in every prologue, Cranelift's `stack_limit`), and rejected it:

- It would be a second mechanism beside the guard, not a replacement: Rust
  runtime helpers, libc and the coroutine switch have no prologue check, so
  the guard is needed anyway, and two mechanisms would disagree about where
  the limit is.
- The existing contract is terminal, so an in-band error buys nothing: no
  Botlish code can catch NATIVE LIMIT STACK.
- It costs every call a load and a compare, where the guard costs nothing
  until the fault; and it would change Linux's code generation.

The guard's recovery, and why it is valid:

1. *Detection* happens while the faulting instruction has not completed:
   no frame was corrupted, because the store that would have gone below the
   stack did not happen. Nothing after it runs.
2. *Classification* (`is_overflow`): the faulting thread is the guarded one
   (`thread_token`), and `si_addr` lies in the guard of the stack published
   as running. A fault elsewhere -- another address, a guard of a stack not
   running, another thread -- is not an overflow (section 17).
3. *Report* (`report_overflow`): `write(2)` of a static line to a
   descriptor recorded before the run; `_exit` with the driver's status (0:
   the line is the result) or an executable's (1). The process ends: no
   frame -- Rust, C, assembly or Botlish -- is unwound or resumed, no
   destructor runs, no lock is taken, the heap, the collector and every
   coroutine are left as they are, and the OS reclaims all of it. There is
   no `siglongjmp` and no rewritten signal context.
4. *Unrelated faults* (`defer`): the disposition the process had before the
   guard is restored (an ignored one becomes the default: a fault cannot be
   ignored); a fault an instruction raised then happens again when the
   handler returns and the instruction re-executes, under that disposition;
   any other signal (sent by a process) is raised again so that it is not
   lost. The process ends exactly as it would have without the guard
   (checked against a run without one, section 17).

What this relies on beyond POSIX: that the kernel reports the faulting
data address in `si_addr` for SIGSEGV and SIGBUS (it does on Linux and
macOS, and Rust's std relies on the same), and that a guard hit is a fault
at all -- confirmed on macOS for every stack kind (sections 5-7).

## 10. Signal-safety analysis

The handler (platform/guard.rs `fault_handler`) runs on an alternate signal
stack (`sigaltstack` of `max(SIGSTKSZ, 64 KiB)`: 128 KiB on macOS, whose
MINSIGSTKSZ is 32 KiB), installed with `SA_SIGINFO | SA_ONSTACK` and an
empty mask (the signal itself stays blocked while it runs). The alternate
stack is the thread's, not a coroutine's: a fault on a coroutine stack is
handled on it too, never on the exhausted stack. It does, in order:

| Step | Operation | Async-signal-safe because |
|---|---|---|
| fault address, code | read `si_addr`, `si_code` of the kernel's `siginfo_t` | plain loads of the handler's argument |
| thread | `thread_token()`: `gettid` (Linux), `pthread_self` (macOS) | a raw syscall; `pthread_self` is on POSIX's list (and on Darwin a read of the thread's own TSD) |
| classification | atomic loads of `GUARDED`, `SLOT`, `SLOTS` | lock-free atomics stored by this same thread before the fault |
| report | `write(2)`, retried on `EINTR` (`errno` read, nothing allocated) | on POSIX's list |
| end | `_exit(2)` | on POSIX's list |
| or defer | `sigaction(2)` restoring the previous disposition, `raise(3)` | on POSIX's list |

It allocates nothing, takes no lock, formats nothing (the line is a
constant), touches no thread-local storage (macOS's lazily allocated TLV
is avoided on purpose), never collects, walks no heap object and never
unwinds. The statics it reads are written before the handler is installed
(the previous dispositions) or by the guarded thread itself (the published
pair, the descriptor). Installation stores the guarded thread's token last,
with release ordering, and removal clears it first, so a fault during
either is deferred.

## 11. Main-thread overflow results

The OS-managed thread stack a Botlish program runs on is the driver's worker
thread (section 2, item 1): a thread libpthread creates, of 1 GiB or
`BOTLISH_NATIVE_STACK_BYTES`. The tests below run programs the way a user
does -- Botlish source through the front end, `native::evalHir`, an `exec`
of botlish-native -- on `cranelift` and on `cranelift-generic`
(`-specialize 0`), and compare the outcome exactly: the error code `NATIVE
LIMIT STACK`, or `{value V}`. A driver killed by a signal is `NATIVE BUG
... child killed` and fails the test whatever its text says; the harness
has no recursion limit of its own; 10^8 levels exceed any stack and the
finite depths fit with a wide margin, so no expectation depends on an exact
depth.

| Test (tests/native-stack-overflow.test) | Program | Before (Gate A) | After (macOS) |
|---|---|---|---|
| `native-stack-overflow-1` | stack_overflow.ir, run twice, 4 MiB thread | SIGABRT (Rust: `has overflowed its stack`) | the line, both runs |
| `native-stack-overflow-wide-1` | large_frame_overflow.nir (600 live roots a frame), 4 MiB | SIGABRT | the line |
| `native-stack-overflow-default-size` | stack_overflow.ir, 1 GiB | the line, from the depth token | the line, from the guard |
| `ns-main-shapes` | `down`, `keep`, `wide` and `rec` through a `Fn` value, 10^8 levels | `down`, `wide`: SIGSEGV on both backends; `keep`: the token's error on both; `rec`: SIGSEGV on cranelift, the token's error on cranelift-generic | `NATIVE LIMIT STACK`, all eight |
| `ns-main-finite` | the same shapes at 10^6 (`down`, `wide`) and 10^5 levels | values | the same values |
| `ns-main-small-stack` | a 1 MiB thread: `keep` 1000 levels, 10^8 | value 3000; SIGABRT | value 3000; `NATIVE LIMIT STACK` |
| `ns-main-with-suspended-coroutines` | `down(10^8)` while two coroutines are suspended on their own stacks | SIGSEGV | `NATIVE LIMIT STACK` |

"After" is every run since the change (section 19): Tier C of run
39293822194 (e9bbb03), 18 of 18 tests on both Tcl backends, and the runs
after it. The shapes matter: `keep` holds a String across its recursive
call (its frames hold roots, and it allocates), `wide` six Ints, `rec`
recurses through an indirect call, `down` has the smallest frame; the Gate
A column shows they reached three different ends before.

What these establish, one by one:

- *The recursion reaches the product's mechanism.* On macOS no other one
  is left: the depth token is gone (section 15), so the only way to the
  line is the guard's handler. Rust frames reach it too: native_stack's
  `guard std-1MiB 64 KiB frames` recurses through 64 KiB Rust frames into
  the guard (Rust's own inline probes).
- *The runtime reports the Botlish error through the existing protocol*:
  the driver's result line, read by `native::Outcome` (section 16).
- *No SIGSEGV, SIGBUS or Rust abort*, and *no silent success*: either would
  be a different outcome than the one compared.
- *No hang*: each run ends when its stack does; the five Tcl files of the
  Tier C run, this one included, took 40 s per Tcl backend on the runner.
- *Finite recursion returns normally*, deep (10^6 levels of `down` and
  `wide`) and on a small stack.

The process's own main thread, where Botlish code never runs, is checked by
native_stack directly: `guard main driver` installs the guard there and
exhausts the main thread's stack in Rust, and the line is printed (macOS);
on Linux the main thread has no confirmed guard (glibc reports a guard
size of 0 for it), the guard refuses to install, and the test expects the
refusal.

## 12. Coroutine-stack overflow results

A coroutine runs on its own mapped stack (8 MiB by default,
`BOTLISH_NATIVE_COROUTINE_STACK_BYTES`), below which the runtime keeps a
64 KiB `PROT_NONE` guard; every test here overflows that stack while the
worker's 1 GiB stack has ample room, so the guard that faults is the
coroutine's, and only because the coroutine's stack is the published one is
the fault an overflow. Same harness and comparison as section 11, on both
native backends:

| Test | What overflows | Before (Gate A) | After (macOS) |
|---|---|---|---|
| `ns-co-fresh` | a coroutine at its eager start, before its first yield | SIGBUS | `NATIVE LIMIT STACK` |
| `ns-co-after-yields` | after two yields, in ordinary computation of its third segment | SIGBUS | `NATIVE LIMIT STACK` |
| `ns-co-resumer-holds-references` | the resumer holds a String, a List and a struct across the resume; the coroutine's recursion allocates (`keep`) | SIGBUS | `NATIVE LIMIT STACK` |
| `ns-co-edge` | a bisection of `down`'s depth inside a coroutine, from 10^3 to 10^8 levels, to within 64 | the first probe: SIGBUS | every probe a value or `NATIVE LIMIT STACK`; the edge between 10^3 and 10^7 levels, on each backend |
| `co-errors-uncaught-native-limit` (coroutines.test) | a recursion that yields at its deepest point | (milestone 3: `nativeLinux` only) | `NATIVE LIMIT STACK` |
| `ns-co-nested-*` | section 13 | SIGBUS | `NATIVE LIMIT STACK` |

In Rust, native_stack drives the runtime's coroutine entry points
directly: `coroutine fresh`, `coroutine after-yields` and `coroutine nested`
end in the line (macOS and Linux), and the four switch sweeps put a
coroutine's start, a resume and a yield at every 16 bytes of the last 1.5
KiB above a stack's end -- the thread's stack or a coroutine's -- where
every switch either completes or reports the line (on the macOS runner:
19, 55, 19 and 13 of the 97 offsets of each sweep overflowed, the rest
completed; none crashed). The sweep is what found the switch window
(section 2): with the old publication order put back it crashes.

Attribution. The handler reports only a fault in the guard of the stack
published as running, so a coroutine's overflow is reported because its
stack is published, never because "some stack" overflowed: with the
coroutine's stack not published at its start (mutant
`start-publishes-thread-stack`) or not on its resume
(`resume-not-published`), these tests fail on macOS with crashes (section
18). The other direction -- a fault in a guard that is not the running
stack's is no overflow -- is section 17's `suspended-guard`,
`sibling-guard-from-coroutine` and `thread-guard-from-coroutine`.

Error, ownership and cleanup semantics. `NATIVE LIMIT STACK` is a resource
limit of the native invocation, not a Botlish error: no `on` clause can
name it (an `on` discriminates declared error identities only;
ERROR-PAYLOADS.md), on any backend -- the Tcl backends' own limit, `TCL
LIMIT STACK`, is the same kind (main-recursion.test). So its defined
behavior is terminal, and the runtime enforces exactly that, inventing no
recoverability: the handler ends the process at the faulting instruction.
No coroutine becomes failed, no failure is cached, no resumer observes an
error, no release or drop runs, no stack returns to the pool, and no
Botlish or Rust code runs on the overflowed stack again; the OS reclaims
every mapping. Nothing can reuse the overflowed stack or meet a stale root
registration, because nothing of the process runs after the report. The
coroutine error model of milestone 3 (declared errors, cached failures,
release on the last use) is unchanged and is exercised by coroutines.test
on macOS in every run (section 19).

## 13. Nested coroutine behavior

The hierarchy `main -> a -> b -> c` in Botlish's own coroutine syntax
(native-stack-overflow.test's `nested`): `a` constructs `b`, `b` constructs
`c`; each yields twice and is resumed twice, so every level is suspended
and resumed at least once, and when the deepest resume runs, `a` and `b`
are running coroutines with live frames on their own stacks.

| Test | What happens | Before (Gate A) | After (macOS) |
|---|---|---|---|
| `ns-co-nested-deepest` | `c`'s third segment recurses 10^8 levels: `c`'s stack overflows while `a` and `b` are running beneath it | SIGBUS | `NATIVE LIMIT STACK`, both backends |
| `ns-co-nested-middle` | `c` completes and its stack is released; then `b`, running again, recurses 10^8 levels | SIGBUS | `NATIVE LIMIT STACK`, both backends |
| `ns-co-nested-finite` | the same hierarchy within its stacks (`c` and `b` 20 000 levels each) | `[1, 4, 40000]` | `[1, 4, 40000]` |

- *The correct active stack, through nesting and back.* `ns-co-nested-middle`
  is the one that needs restoration: after `c`'s segment returns, `b`'s
  `segment` publishes `b`'s stack (section 8), so `b`'s overflow is
  classified; with that publication removed (mutant `yield-not-restored`)
  `c`'s released stack stays published and `b`'s overflow crashes -- it
  fails on macOS and Linux alike (section 18). native_stack's
  `publication` reads the published pair back at seven points of a nested
  lifecycle (section 8), and its `coroutine nested` overflows the inner of
  two nested coroutines from Rust.
- *Identity, roots and error state on the way back up*, where execution
  continues -- after ordinary yields, returns and completions -- are
  `ns-co-nested-finite`'s value (each level's result is the one its own
  segment computed) and coroutines.test's nested tests, all on macOS in
  every run (`co-gc-nested-suspended-roots-stress` among them; under GC
  stress in section 14's run).
- *After an overflow, nothing goes back up* (section 12): the error is
  terminal for the native invocation, so no ancestor resumes, observes an
  error or releases a descendant, and there is no discarded stack anything
  could still refer to. The interpreter and the Tcl compiler, the semantic
  oracles, have no corresponding native limit (their recursion limit is
  Tcl's own, `TCL LIMIT STACK`, at another depth), so their agreement is
  checked on the finite programs, which coroutines.test runs on every
  backend.

## 14. GC roots and the frame walk

The collector walks native frames by their frame-pointer chain (on
AArch64 every function's roots are in its frame, `NativeFrame`): the
running stack from the current frame up to the bound of the stack it runs
on, then each resumer of the running chain, every suspended coroutine
from its saved frame record (runtime/framewalk.rs; the collection in
runtime/vm.rs bounds each walk by `stack_of`, the thread's `native_stack`
or a coroutine's `CoStack::bounds()`). Milestone 3 left the macOS thread
stack with no discovered bounds; it now has the thread's own, the ones the
guard uses, so the walk of the worker's stack is bounded by
`[low_bound, high_bound)` on macOS as on Linux. The tracing itself is
unchanged (no file of the collector changed). A walk bounded too tightly
omits frames: the mutant `gc-walk-half-stack` (the thread stack's bound at
its middle) is killed on both hosts by `native-stack-gc-1` and
`ns-gc-stress-coroutine`.

The brief's six cases:

| Case | Covered by | Result on macOS |
|---|---|---|
| 1. ordinary allocations and collections on the thread's stack | `native-stack-gc-1` (400 allocating frames, a collection at every allocation), `ns-gc-stress-main` (`keep`: 500 levels return 1500; 10^8 fill a 1 MiB stack) | pass (Gate A: the 10^8 run was SIGABRT) |
| 2. collections while several coroutines are suspended | `ns-gc-stress-coroutine` (a second coroutine suspended throughout), coroutines.test's `co-gc-stress` | pass |
| 3. collections inside nested coroutines | coroutines.test's `co-gc-nested-suspended-roots-stress`; under the stress run every nested test of both files | pass |
| 4. managed references retained before a deep call | `keep` holds a String across each recursive call; the values 1500 and 3000 are sums of those Strings' lengths, read after the collections | pass |
| 5. references a resumer holds while the resumed coroutine nears its limit | `ns-gc-stress-coroutine`: the resumer holds a String, a List and two coroutine results across a resume whose `keep` recursion fills a 128 KiB stack; 308 is computed from all of them | pass (Gate A: SIGBUS) |
| 6. cleanup after an overflow where continued execution is part of the contract | not part of the contract: the overflow is terminal (section 12) | -- |

Survival is checked by value -- each result is computed from the retained
objects' contents after the collections -- never by comparing addresses.
The stress tests use small stacks (1 MiB, 128 KiB) so that a collection's
walk of the whole stack, at every allocation, stays cheap; the bound they
reach is the same guard. The Rust test milestone 3 corrected
(`rt_bytes_from_list`'s rooting) runs in the `rust` item under stress.

The focused GC-stress run on the final code (section 19, run
@@GCRUN@@): native-stack-overflow.test, coroutines.test,
native-stack-map.test, native-root-storage.test and native.test on both
Tcl backends, and the Rust tests and native_stack, all under
`BOTLISH_NATIVE_GC_STRESS=1` -- every test of these files with a
collection at every allocation, not only the stress tests above.
@@GCRESULT@@ Locally on Linux x86-64 under the same variable:
native-stack-overflow.test 18 of 18 (5 min 24 s), the Rust tests and
native_stack pass.

## 15. The shadow-stack depth token

Audited before changing (codegen/clif.rs `prologue_depth_token`,
codegen/roots.rs `depth_reservation`, vm.rs `SHADOW_STACK_SLOTS`):

- **Why it existed.** On a host without the native guard, every calling
  function bumps the Vm's shadow-stack top `ss_top` by one zeroed 8-byte
  slot on entry, checks it against `ss_limit` (4M slots, 32 MiB) and calls
  `rt_stack_overflow` -- the in-band `RtError::StackOverflow` -- past it;
  it restores the saved value on exit. It is the fallback root path's
  recursion bound (CRANELIFT-WASM.md section 9.1), predating native frames.
- **What it guaranteed on macOS: nothing about the native stack.** It
  counts frames, not bytes: 4M frames fit in the 1 GiB worker only if the
  average frame is under 256 bytes, and in an 8 MiB coroutine stack never
  (2 bytes a frame). Gate A shows both sides: the small frames of `keep`
  reached the token (`NATIVE LIMIT STACK`), the slightly larger ones of
  `down` and `wide` and every coroutine overflowed the real stack first
  (SIGSEGV, SIGBUS). And it made recursion depth depend on frame count,
  not stack size, unlike Linux.
- **Does the collector need it? No.** On AArch64 every function's roots
  are `NativeFrame` (codegen/clif.rs `stack_maps` is true for aarch64), so
  the token's slots only ever held zeros and the shadow array held no root
  (milestone 3 audited the non-LIFO interleaving under coroutines: benign,
  and now moot).
- **Decision: retired on macOS, by the existing predicate.**
  `native_stack_overflow_supported()` now includes macOS AArch64, which
  removes the token (`depth_reservation` false), the shadow array
  (`Vm::shadow` empty, `ss_top == ss_limit == null`) and the
  `rt_stack_overflow` cold block from every function, exactly as on Linux,
  and turns the stack probes on. The guard subsumes it: one mechanism, the
  real stack's end, on every guarded host. The token and the fallback root
  path remain for hosts without a guard (their tests in codegen/roots.rs
  run the fallback plan explicitly), untouched.
- **Checked:** `stack-map-fib-1`/`-2` (fib has no depth reservation and no
  `rt_stack_overflow` call where the guard is) and `storage-call-crossing-2`
  now expect the guarded branch on macOS too; the Rust tests of
  codegen/roots.rs assert `depth_reservation == !native_stack_overflow_
  supported()`.

## 16. Native-driver diagnostic behavior

Unchanged, and checked on macOS for the first time:

| Mode | What a stack overflow produces | Checked by |
|---|---|---|
| `botlish-native run FILE` (no `--result`) | the line on standard output, exit status 0 | native_stack `guard * driver`, native-stack-overflow.test's driver tests |
| `botlish-native run --result PATH FILE` (main.tcl's `-output inherit`) | the line in PATH, nothing on standard output, exit 0 | `guard std-1MiB result-file` |
| a standalone executable's own run (`OverflowGuard::install_executable`) | the line on standard error, exit status 1 | `guard std-1MiB executable` (the guard itself: Mach-O executables are milestone 6's) |
| `native::evalHir`, main.tcl | error code `NATIVE LIMIT STACK`, message `native stack exhausted: too many nested calls`; main.tcl adds the `help:` line | native-stack-overflow.test, native-status |

The line is the one Linux writes, byte for byte, and the one the driver
writes for an in-band overflow; no macOS-specific text exists. A crash is
never relabeled: the Tcl host raises `NATIVE BUG` (`child killed: ...`) for
a driver killed by a signal, and every overflow test compares the exact
error code, so a crash whose text mentions a stack fails it (as Gate A's
SIGABRT runs did).

## 17. Fault-classification negative tests

Ten faults that are not the running stack's exhaustion, each in a child
process with the guard installed, and again without it (native_stack's
`fault:*`; macOS: the smoke job of run 39297872127, e0b04c5, which has all
ten; run 39293822194 had the same results for the seven it had):

| Fault | With the guard (macOS / Linux) | Without |
|---|---|---|
| a read near address 0 | SIGSEGV / SIGSEGV | the same |
| a read of an inaccessible page that is no stack's | SIGBUS / SIGSEGV | the same |
| a write to a read-only page | SIGBUS / SIGSEGV | the same |
| a page *inside* the running thread stack's usable range, made inaccessible | SIGBUS / SIGSEGV | the same |
| the same inside a running coroutine's stack | SIGBUS / SIGSEGV | the same |
| a read of a *suspended* coroutine's guard from the thread's stack | SIGBUS / SIGSEGV | the same |
| a read of a suspended sibling's guard from a *running* coroutine | SIGBUS / SIGSEGV | the same |
| a read of the thread stack's guard while a coroutine runs | SIGABRT (Rust's own guard report) / SIGABRT | the same |
| a read of the guarded stack's guard by *another thread* | SIGBUS / SIGSEGV | the same |
| a SIGSEGV sent with `raise` | survives (Rust's handler ignores a sent one) / survives | the same |

None prints the overflow line, and each ends exactly as it does without the
guard: the guard defers every unrelated fault to the disposition before it
(section 9). Rows four and five are faults *in* the running stack that are
not its guard (the classification's upper bound is the stack's low bound,
exactly); rows six to nine are guards, but not the running stack's guard
on this thread. Row eight shows the deferral is exact: Rust's std handler,
restored and given the re-executed fault, reports its own guard page as it
would have. The positive side is checked too: a read of the lowest byte of
a confirmed guard, with the guard installed, is reported as an overflow
(`guard * guard bottom`: 16 KiB below a created thread's stack on macOS, the
whole 56 MiB reservation of the main thread's).

The mutants `every-fault-overflows`, `any-thread-overflows`,
`guard-includes-stack` and `defer-exits-quietly` are killed by these
(section 18).

A limitation of the deferral, not of classification: a SIGSEGV *sent* to
the driver by another process reaches Rust's handler, which resets the
disposition to the default; for the rest of that run, a stack overflow is
then Rust's crash, not the line -- as it would be had the guard never been
installed. No Botlish process sends itself SIGSEGV or SIGBUS.

## 18. Mutation testing

`audit/native-stack/tools/mutate.tcl` with its 24 mutants
(`audit/native-stack/tools/mutants.txt`): each is an exact source
replacement; for each mutant that applies to the host, a private copy of
the tree gets it, its native backend is rebuilt (a mutant that does not
build is reported NOT-BUILT, never killed) and three detectors run against
it -- native_stack (every faulting check in a child process), the
runtime's Rust tests, and native-stack-overflow.test. A mutant of another
host's code is SKIPPED there. The harness is portable (its own timeout, no
GNU `timeout`, no /proc), so macOS runs it through Tier C
(`tests/platform/tier.tcl`'s item `native-stack-mutants`); nothing was run
on a shared Mac.

| Brief's mutation | Mutant(s) | Linux x86-64 | macOS arm64 | Killed by (macOS; Linux where macOS skips it) |
|---|---|---|---|---|
| thread stack top and bottom reversed | `linux-bounds-reversed`, `macos-bounds-reversed` | killed / skip | skip / killed | native_stack's `runtime stack *` (the runtime's bounds against the thread library's), the platform module's Rust test, `native-stack-gc-1` and `ns-gc-stress-coroutine` (the frame walk) |
| stack size misinterpreted | `linux-size-halved`, `macos-size-halved`, `macos-address-is-the-bottom` | killed / skip / skip | skip / killed / killed | `runtime stack *`, `touch * reported-low`; the macOS ones also every overflow test (18 of 18 fail) |
| main-thread bound an arbitrary constant | `linux-constant-bound`, `macos-constant-bound`, `macos-reported-bottom-trusted` | killed / skip / skip | skip / killed / killed | `runtime stack *`, every overflow test; `touch main usable-low`, `touch main reported-low` and `guard main driver` for the trusted bottom |
| page size hard-coded to 4096 | `page-size-4096` (the macOS guard taken as one 4 KiB page) | skip | killed | `runtime stack *` (the confirmed guard is 16 KiB or larger) |
| wrong coroutine stack published | `start-publishes-thread-stack`, `publish-before-switch` | killed | killed | `coroutine fresh`, `publication`, the sweeps, `ns-co-fresh`; the sweeps alone for publish-before-switch |
| active stack not updated on resume | `resume-not-published` | killed | killed | `coroutine after-yields`, `coroutine nested`, `publication`; five ns-co tests |
| active stack not restored after yield | `yield-not-restored` | killed | killed | `fault suspended-guard`, `fault sibling-guard-from-coroutine`, `publication`, a sweep; `ns-co-nested-middle`, `ns-main-with-suspended-coroutines` |
| guard address classified incorrectly | `guard-range-swapped`, `guard-includes-stack`, `macos-guard-assumed` | killed / killed / skip | killed / killed / killed | every `guard *` overflow and 14 Tcl tests; `fault inside-stack`, `fault inside-coroutine-stack`, `fault sibling-guard-from-coroutine`; `runtime stack pthread-*` and the zero-guard thread's probes |
| every SIGSEGV an overflow | `every-fault-overflows`, `any-thread-overflows` | killed | killed | every `fault *` row of section 17; `fault other-thread` |
| no alternate signal stack | `no-alternate-stack` | killed | killed | every `guard *` overflow, 14 Tcl tests |
| recovery omits necessary work | `report-without-line`, `report-ignores-result-fd`, `defer-exits-quietly`, `drop-leaves-guard-busy` | killed | killed | the overflow line's every mode; `guard std-1MiB result-file`; the `fault *` rows; `guard std-1MiB reinstalled` |
| GC frame walk with wrong bounds | `gc-walk-half-stack` | killed | killed | `native-stack-gc-1`, `ns-gc-stress-coroutine` |

Totals: **macOS**, run
[39297872127](https://github.com/mwagner-webdev/botlish/actions/runs/39297872127)
(e0b04c5, Tier C job 118215508236): 24 mutants, **21 killed, 0
survived**, 3 skipped (Linux's), in 400 s. **Linux x86-64**, locally on
the same mutants: @@LINUXMUTANTS@@

"Recovery omits necessary runtime cleanup" has a particular meaning here:
the recovery is termination, so what it must not omit is the report itself
(the line, to the right descriptor), deferring what is not an overflow,
and leaving the process's signal state as it found it when the guard is
dropped -- one mutant each. There is no heap, coroutine or pool cleanup to
omit (section 12).

What the first macOS run of the harness (run 39293822194, e9bbb03: 19
killed, 2 survived) taught, and what changed:

- `guard-includes-stack` (the classified range extended 64 MiB up into the
  usable stack) survived on macOS: on Linux it had been killed only by
  accident of address layout (`fault thread-guard-from-coroutine`). Nothing
  faulted *inside* a running stack. native_stack now does (`fault
  inside-stack`, `fault inside-coroutine-stack`: a page of the running
  thread's stack, or of the running coroutine's, made inaccessible, read
  by the guarded thread), and reads a suspended sibling's guard from a
  running coroutine; all three must end as without the guard. They kill
  the mutant on both hosts.
- `page-size-4096` first rounded coroutine stacks to 4 KiB pages. That is
  an equivalent mutant: the kernel rounds a mapping's length up to its
  page, so no program or check can observe the difference; it survived
  on both hosts (on Linux, whose page is 4 KiB, it changed nothing). It was
  replaced by the 4 KiB page where the page size matters -- the guard
  below a thread's stack taken as one 4 KiB page -- with a check it fails:
  a read of the lowest byte of the confirmed guard (`guard * guard
  bottom`) must be reported, which a 4 KiB guard misses by 12 KiB on a
  created thread and by 56 MiB on the main thread (and the runtime's
  guard no longer equals the one native_stack reads from the VM system).
  It is macOS code, so it runs on macOS only.

## 19. macOS GitHub Actions runs

Every macOS fact and result in this report comes from these runs of
`.github/workflows/macos-arm64.yml` on `macos-15` arm64 runners (macOS
15.7.9, Darwin 24.6.0, 3 CPUs, 16 KiB pages). A newer push to the branch cancels a
running one, which is why the earlier runs' acceptance jobs are
cancelled; each run's results below are from its completed jobs.

| Run | Head | Jobs that ran | Results |
|---|---|---|---|
| [39286923808](https://github.com/mwagner-webdev/botlish/actions/runs/39286923808) | a76d76f, Gate A: the tests, no runtime change | smoke; Tier C `native-stack-overflow.test rust` | smoke: success (native_stack's stack facts, sections 5-6). Tier C: failed as it had to -- 13 of 18 overflow tests, the "before" of sections 1 and 11-13 |
| [39289576003](https://github.com/mwagner-webdev/botlish/actions/runs/39289576003) | 3b3e664, the change | -- | cancelled by the next push before a macOS runner started (Linux control: success) |
| [39291788199](https://github.com/mwagner-webdev/botlish/actions/runs/39291788199) | 1ba91c7, the mutation harness | smoke | success: the first macOS run of the guard -- every native_stack check (stack facts, guard probes, overflows in every reporting mode, coroutine overflows, faults, publication, sweeps) and native-status's `stack-overflow` and `coroutine-stack-overflow` |
| [39293822194](https://github.com/mwagner-webdev/botlish/actions/runs/39293822194) | e9bbb03, the benchmark | smoke; Tier C `native-stack-overflow.test native-stack-map.test native-root-storage.test coroutines.test native.test rust native-stack-mutants native-stack-bench` | smoke: success. Tier C (job [118201686534](https://github.com/mwagner-webdev/botlish/actions/runs/39293822194/job/118201686534)): the five Tcl files 208 of 210 on interp and on compile (2 skipped by host constraints, `nativeLinux` and `readelf`), the Rust tests and native_stack pass, the benchmark (section 22); its one failure was the mutation harness's two survivors (section 18) |
| [39297872127](https://github.com/mwagner-webdev/botlish/actions/runs/39297872127) | e0b04c5, faults inside the running stack | smoke; Tier C (the same items but the benchmark); acceptance | smoke: success, all ten faults of section 17. Tier C (job [118215508236](https://github.com/mwagner-webdev/botlish/actions/runs/39297872127/job/118215508236)): success -- mutants 21 killed of 21, the five Tcl files as above, Rust tests and native_stack. Acceptance: @@ACC1@@ |
| @@FINALRUNROW@@ |

What the runs cover, against the brief's list: native smoke and the
stack-bound tests (native_stack, in every smoke job since 39291788199);
main-thread, coroutine and nested-coroutine overflow and recovery
(native-stack-overflow.test and coroutines.test on both native backends,
every Tier C run); native golden suites on both Cranelift backends and the
broader acceptance tier (Tier B, @@ACCRUN@@); focused GC stress (section
14); native-status (every smoke job: `stack-overflow` and
`coroutine-stack-overflow` are `NATIVE LIMIT STACK`, the other recorded
limitations -- Mach-O executables, C calls, Linux imports -- unchanged).

## 20. Linux x86-64 regression results

@@LINUXX86@@

## 21. Linux AArch64 regression results

@@LINUXARM@@

## 22. Performance observations

@@PERF@@

## 23. Remaining limitations

- **Recovery is termination.** `NATIVE LIMIT STACK` ends the native
  invocation, on every host, as it did on Linux: there is no in-process
  continuation after a stack overflow, and none was added (section 12).
  A Botlish program cannot observe or handle it.
- **One guarded thread per process.** The guard's state is
  process-wide (one handler, one published stack); a second guard in the
  same process is refused (`AlreadyExists`). Botlish runs every program on
  its one worker, so this is no restriction today; a host that ran
  Botlish on several threads at once would need the state per thread.
- **A stack without a confirmed guard is refused**, and the driver stops
  before running the program rather than run it unguarded (the install's
  `expect`). On the worker -- a std thread, whose guard libpthread and
  glibc always make -- it never happens; a raw pthread made with a zero
  guard size, or Linux's main thread, would be refused.
- **A sent SIGSEGV or SIGBUS can disable the guard for the rest of the
  run**: the guard defers it to Rust's handler, which resets the
  disposition (section 17). The process ends as it would have without the
  guard; nothing in Botlish sends these signals.
- **Observed, not specified.** On macOS the facts the guard relies on --
  that a stack's guard is an inaccessible mapping directly below its usable
  range, that a hit is SIGSEGV or SIGBUS with the address in `si_addr`, the
  16 KiB page -- were observed on GitHub's `macos-15` arm64 runners (Apple
  Silicon under virtualization), sections 5-7. The code checks the first
  (it confirms the guard and refuses a stack without one) and does not
  assume the page size; that a guard hit is a signal at all, and with the
  address, is the platform contract Rust's std relies on too. Other macOS
  versions and bare-metal Macs were not run.
- **Executables.** A standalone executable installs the guard through
  `OverflowGuard::install_executable` (runtime/aot.rs) on macOS too, but
  macOS cannot produce one yet (Mach-O emission is roadmap entry 6): its
  reporting mode is checked only by native_stack's `guard std-1MiB
  executable`, not by a Botlish executable.
- **C code on the stack.** A C function's overflow of the worker's stack
  faults in the same guard and is reported as `NATIVE LIMIT STACK` (the
  stack is exhausted, whoever exhausted it). On macOS no C call runs yet
  (roadmap entry 7), so that path is Linux's only.
- **The fallback.** The depth token and the shadow array remain for hosts
  without a guard (none of the three Botlish CI hosts); their code is
  unchanged.
- **The Linux main thread** has no confirmed guard (glibc reports none),
  unchanged from before; Botlish never runs code there.

## 24. Prerequisites for the next milestone

The next roadmap entry is 6, Mach-O AOT and the standalone executable
(MACOS-AARCH64-PORT-AUDIT.md, section 17), whose stated prerequisite was
this milestone ("an executable installs the guard"). What it can rely on,
and what it still has to show:

- **In place:** runtime/aot.rs installs the guard under the same cfg as
  the driver (Linux x86-64 and AArch64, macOS AArch64), with the
  executable's reporting (the line on standard error, exit status 1),
  which native_stack checks on macOS; the generated startup and
  `aotimage::Loaded::instantiate` need no stack-specific change.
- **To show:** a Mach-O executable's own overflow prints the line and
  exits 1 -- `native-executable-stack-overflow` (tests/
  native-executable.test), once `executableAot` holds on macOS -- through
  the rustc linker; the stub linker stays Linux x86-64.
- **Unchanged constraints it inherits:** the guard is the worker
  thread's; an executable's `main` must keep running the program on a
  thread with a confirmed guard (as runtime/aot.rs does now), and a change
  to that startup goes with a native_stack run on both hosts.
- **Not prerequisites:** C calls (entry 7) and Darwin IO (entry 9) do not
  depend on anything further here; a C callee's overflow is classified by
  address like any other frame's.
