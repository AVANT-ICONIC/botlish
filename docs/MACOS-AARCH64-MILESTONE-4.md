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

13 of the 18 tests of native-stack-overflow.test failed; the five that
passed were the ones that do not overflow (finite recursions, GC stress on
400 frames, fib). So: a thread-stack overflow was Rust's abort when the
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

@@MAINRESULTS@@

## 12. Coroutine-stack overflow results

@@CORESULTS@@

## 13. Nested coroutine behavior

@@NESTED@@

## 14. GC roots and the frame walk

@@GC@@

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
`fault:*`; the macOS column is run 39293822194's for the seven it had, the
three added after it are in the later runs of section 19):

| Fault | With the guard (macOS / Linux) | Without |
|---|---|---|
| a read near address 0 | SIGSEGV / SIGSEGV | the same |
| a read of an inaccessible page that is no stack's | SIGBUS / SIGSEGV | the same |
| a write to a read-only page | SIGBUS / SIGSEGV | the same |
| a page *inside* the running thread stack's usable range, made inaccessible | (section 19) / SIGSEGV | the same |
| the same inside a running coroutine's stack | (section 19) / SIGSEGV | the same |
| a read of a *suspended* coroutine's guard from the thread's stack | SIGBUS / SIGSEGV | the same |
| a read of a suspended sibling's guard from a *running* coroutine | (section 19) / SIGSEGV | the same |
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

@@MUTATION@@

## 19. macOS GitHub Actions runs

@@RUNS@@

## 20. Linux x86-64 regression results

@@LINUXX86@@

## 21. Linux AArch64 regression results

@@LINUXARM@@

## 22. Performance observations

@@PERF@@

## 23. Remaining limitations

@@LIMITS@@

## 24. Prerequisites for the next milestone

@@NEXT@@
