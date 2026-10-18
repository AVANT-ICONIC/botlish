# MACOS-AARCH64-PORT-AUDIT.md

The Linux assumptions a native macOS Apple Silicon port of Botlish has to
deal with, where they live, and the CI that tests the port on real Apple
Silicon. Written for the agents of the port's later milestones: start
here, then read the section of the subsystem you are changing. The
milestone that produced it is MACOS-AARCH64-MILESTONE-1.md.

> Let Cranelift own the Apple AArch64 machine ABI, let Mach-O and the
> system linker own executable format and native symbol resolution, and add
> only the Botlish runtime/platform adaptation macOS actually requires. Do
> not build a Darwin toolchain inside Botlish.

The target: macOS (Darwin) on Apple AArch64 (arm64), 64-bit pointers, the
LP64 C data model, the Apple AArch64 C ABI, Mach-O objects, executables
linked by the normal Apple toolchain (through the existing rustc linker
driver). core/cabi.tcl already names it `macos-aarch64`.

## Contents

1. [What is verified on a real macOS arm64 host](#1-what-is-verified-on-a-real-macos-arm64-host)
2. [How to read the findings](#2-how-to-read-the-findings)
3. [Compiler target model (Tcl)](#3-compiler-target-model-tcl)
4. [Cranelift, JIT and object generation](#4-cranelift-jit-and-object-generation)
5. [Executables, the driver, the stub linker and the single executable](#5-executables-the-driver-the-stub-linker-and-the-single-executable)
6. [Runtime: threads, stack bounds and overflow](#6-runtime-threads-stack-bounds-and-overflow)
7. [GC roots and the frame walk](#7-gc-roots-and-the-frame-walk)
8. [Coroutines](#8-coroutines)
9. [Syscall transports, direct modules and contextual IO](#9-syscall-transports-direct-modules-and-contextual-io)
10. [C FFI](#10-c-ffi)
11. [Tests and the test harness](#11-tests-and-the-test-harness)
12. [Packaging, audit tools and benchmarks](#12-packaging-audit-tools-and-benchmarks)
13. [Already portable: reuse unchanged](#13-already-portable-reuse-unchanged)
14. [Boundaries where a broad change would regress Linux](#14-boundaries-where-a-broad-change-would-regress-linux)
15. [The macOS census](#15-the-macos-census)
16. [CI and test tiers](#16-ci-and-test-tiers)
17. [Roadmap](#17-roadmap)

## 1. What is verified on a real macOS arm64 host

Every fact in this section was observed on GitHub's `macos-15` runner by
`.github/workflows/macos-arm64.yml` (runs listed in
MACOS-AARCH64-MILESTONE-1.md). Everything else in this document comes from
reading the code and the pinned crates (cranelift-* 0.135.2, object 0.39.1,
libc 0.2.189 in `native/Cargo.lock`), and says so where it matters.

**The host.** macOS 15.7 (Darwin 24.6.0), `uname -m` = `arm64`, "Apple M1
(Virtual)", 3 CPUs, 7 GiB, **16 KiB pages** (`hw.pagesize` = `getconf
PAGESIZE` = 16384). Xcode 16.4, macOS SDK 15.5, Apple clang 17.0.0
(`arm64-apple-darwin24.6.0`), Apple ld (ld-prime, `ld-1167.5`). `/bin/bash`
is 3.2.57 and is what a workflow's `shell: bash` runs. No `nproc` and no
`timeout` (GNU coreutils) on the image; `objdump` is Xcode's
(`/usr/bin/objdump`), and there is no `readelf` (the census skips
native.test's `readelf` test).

**The toolchains work** (tests/platform/toolchain-smoke.sh): cc compiles,
links and runs a C program, also against a static archive with `-L DIR
-lNAME`; rustc and Cargo build and run Rust programs; each is a `Mach-O
64-bit executable arm64`. That proves the host builds native code. It says
nothing about Botlish.

**C ABI facts** (tests/platform/cabi-facts.tcl): Apple clang's `char` 8
bits and **signed**, `short` 16, `int` 32, `long` 64, `long long` 64,
pointers 64 -- exactly core/cabi.tcl's `macos-aarch64` row, which no
compiler had checked before (the C header archaeology's probe checked the
Linux x86-64 row, and the arm64 CI's C FFI tests exercise Linux
AArch64's). Plain char is signed on Apple arm64 and unsigned on Linux
AArch64: the one scalar fact that differs between the two aarch64
targets.

**Rust keeps frame records.** rustc 1.98/1.99 for `aarch64-apple-darwin`,
at `-O`, gives a function that calls `stp x20, x19, [sp, #-32]!; stp x29,
x30, [sp, #16]; add x29, sp, #16` with no flag: the frame record is kept
by default, and it sits at the *top* of the callee-save area, where Linux
AArch64 puts it at the bottom (`runtime/framewalk.rs`'s header). On Linux
x86-64 the same probe shows no frame pointer, which is why
`.cargo/config.toml` forces one there.

**Tcl.** Homebrew's `tcl-tk` is Tcl **9.0.4** (`tclsh9.0`, tcltest 2.5.11;
`tcl-tk@8` 8.6.18 is preinstalled and irrelevant), not the Linux pin 9.0.1.
`tcl_platform(os)` is `Darwin`, `machine` `arm64`, so
`core::cabi::hostTarget` is `macos-aarch64`. Tcl's system encoding and
stdout encoding are `utf-8` whatever LANG/LC_ALL say (unset, `C`,
`C.UTF-8`, `en_US.UTF-8`): the Linux `C.utf8` precaution is unnecessary
there, and harmless.

**What Botlish does there today** (with the native backend built by the
ordinary `cargo build --release --manifest-path native/Cargo.toml`):

- The front end, the interpreter and the Tcl compiler run the sample
  programs and the front-end test files unchanged.
- **The native crate compiles** (about 1 minute, cold, on the runner),
  with five dead-code warnings: coroutine.rs's stack constants and
  functions that only the Linux build uses.
- **Its 215 library unit tests pass** (`cargo test --release --lib`),
  including the frame-walk tests, which walk real test-thread stacks with
  no stack bound.
- **The JIT works**: `main.tcl -backend cranelift` runs the surface
  samples to the right values. cranelift-jit's code memory (read-write
  pages flipped to read-execute with `mprotect`, no `MAP_JIT`) is accepted
  for the unsigned (linker-ad-hoc-signed) `botlish-native` on this runner.
- **Executable emission is refused**, explicitly: `executable emission
  requires Linux glibc on x86_64 or aarch64 (NATIVE AOT)`.

The census (section 15) has the rest: every test file and golden suite on
this host.

## 2. How to read the findings

Each table row is one assumption: where it is, what it assumes, its class,
what macOS needs, the risk, the milestone that owns it (section 17), and
whether it can be checked statically on Linux (**L**) or needs macOS
execution (**M**).

Classes:

| Class | Meaning |
|---|---|
| **arch** | architecture-specific (x86-64 vs AArch64), not OS-specific |
| **elf** | ELF/object-format-specific |
| **linux** | Linux-runtime-specific (kernel, glibc, `/proc`, GNU tools) |
| **posix** | portable POSIX behavior, expected to hold on macOS |
| **owned** | already owned by Cranelift, Rust or the system toolchain |
| **test** | a test-only assumption |

Risk: **low** (local, mechanical), **medium** (a subsystem's platform
layer), **high** (correctness of generated code or the GC, or wide test
fallout).

## 3. Compiler target model (Tcl)

The front end already has a target dimension: a compilation's C ABI
target, `-target NAME` or the host's. It is keyed by OS *and*
architecture, and the macOS rows exist. What is keyed by architecture
alone is the Linux syscall layer and the choice of an
architecture-specific module.

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| core/cabi.tcl `targets`, `models` (:51-60) | none: `macos-aarch64 {os macos arch aarch64 model LP64 charSigned 1}` exists | -- | none: verified against Apple clang (section 1). The row's `os` field is read by no code | low | 2 | M (done) |
| core/cabi.tcl `hostTarget` (:110-126) | none: Darwin -> macos, arm64 -> aarch64 | -- | none: verified, `macos-aarch64` | low | 2 | M (done) |
| core/linuxabi.tcl `transports` (:75-93), `transportOf`, `syscallImpl` (:142-147, "on Linux") | the syscall transport table is keyed by architecture only | arch + linux | keep it Linux's: an OS dimension (or a Linux-only table that macOS never consults); never a Darwin row in it -- macOS needs no raw syscall transport (section 9) | medium | 2, 9 | L |
| core/linuxabi.tcl :149-164 | both transports registered and their namespaces declared direct whatever the target | linux | on a macOS target they type-check and compile, and refuse at run time; decide whether a macOS compilation should reject them statically | low | 2, 9 | L |
| core/bytestore.tcl `bridges` (:91-101, :133-146) | `abi::ARCH::from_bytes`/`from_mutable_bytes` come from the Linux transport table | arch | OS-neutral in substance (an address to a register word); keep them, decouple their generation from the Linux table if a second table appears | low | 2 | L |
| surface/modules.tcl `ModuleFile`, `ArchModuleFiles`, `ArchModulePath` (:281-347); header :39-54 | an architecture-specific module is chosen by architecture only, "never by operating system" | arch | on `macos-aarch64` `linux::sys` resolves to `lib/linux/sys.aarch64.bot` today (pinned by tests/linux-syscall-transports.test:280-285). A Linux module on macOS should be an explicit refusal, not a silent pick: an OS check for `linux::*` or an OS-keyed module rule | medium | 2 | L |
| surface/cache.tcl `Key` (:81-95), `Dependencies` (:121-151) | none for the key: it holds the full target name | -- | none (Dependencies follows ModuleFile's arch rule; change both together) | low | 2 | L |
| hir/interchange.tcl `Fingerprint` (:63-78), `encode`/`decode` (:90-118); main.tcl `runFile` (:148-152), `emitExecutable` (:290) | a `.hirx` records no target; reading one built for another target is not detected, and `-target` is ignored for `.hirx`/`.hir` inputs | posix | record the target and refuse a mismatch with the host for native runs (a format change: HIR-INTERCHANGE.md's rules apply) | medium | 2 | L |
| main.tcl :17-25, hir/cabi.tcl `ResolveTarget` (:62-70), hir/foreign.tcl `AbiClass` (:85-95) | `-target` changes the front end only; nothing compares the target with the host before a native run or link | posix | refuse a native run or link whose target is not the host (today `-target windows-x86_64` on Linux silently types `Long` as 32 bits for a C call) | medium | 2 | L |
| surface/modules.tcl :801-805 | `NamespaceTypeDecls` runs before the UNKNOWN-TARGET check, so an unknown host gets a raw `core::cabi: unknown C ABI target ""` | posix | a bug for hosts outside the table (not macOS); move the check first | low | 2 | L |
| main.tcl :61-64, native/native.tcl :46-47, :316 | doc text: executables are "Linux x86_64/glibc" (main.tcl is stale: aarch64 works too) | -- | update with the milestone that adds Mach-O executables | low | 6 | L |
| native/rawabi.tcl :8-9, :31-34 | a 64-bit two's complement word, tagged small Ints in [-2^62, 2^62-1] | arch | none: holds on arm64 | low | -- | L |
| core/process.tcl :9, :55-65 | the argument vector is NUL-terminated (Linux wording) | posix | none | low | -- | L |

## 4. Cranelift, JIT and object generation

The code generator already lets Cranelift own the machine ABI: no calling
convention is hard-coded, the ISA comes from the host triple, and the
object format from the ISA. The macOS run confirms the JIT half.

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| codegen/mod.rs `isa` (:147-165) | none: `cranelift_native::builder_with_options` = the host triple (AppleAarch64 call conv, Mach-O on macOS); no `--target`, no cross-compilation | owned | none. Host CPU features only for the JIT (`!pic`) | low | 3 | M (JIT done) |
| codegen/mod.rs :155-160 | stack probes (`enable_probestack`, inline) only when `native_stack_overflow_supported()`, i.e. Linux | linux | enable them with the macOS guard (milestone 5); until then a large frame can jump past the guard page -- observed: large_frame_overflow.nir ends in Rust's stack-overflow abort, not `NATIVE LIMIT STACK` (section 15). With 16 KiB pages Cranelift's probe spacing of one 4 KiB page is still conservative | high | 5 | M |
| codegen/clif.rs `signature_n` (:182-196), helpers (:265-269), `c_signature` (:215-229) | none: every signature is `module.make_signature()` = the ISA's default convention | owned | none. Botlish-to-Botlish and helper calls use AppleAarch64 on macOS | low | 3 | M |
| codegen/clif.rs `c_signature` (:199-229), `foreign_call` (:1019-1104) | narrow C arguments carry `sext`/`uext`; narrow results are re-extended by the caller | owned | Cranelift honours the extension attributes only for AppleAarch64 (`isa/aarch64/abi.rs` `get_ext_mode`), so they start to matter on macOS; its comment says sub-32-bit extension is "not implemented yet" -- test i8/i16 arguments against clang callees (tests/cffi/fixture.c `bcf_widen_*`) | high | 7 | M |
| codegen/clif.rs :171 | comment: "x86-64 SysV here has only two integer return registers"; the result-buffer rule is portable | arch | comment only | low | 3 | L |
| codegen/clif.rs :237, :92-123 | direct helper calls (R_X86_64_PLT32) only when the ISA is `x64` | arch | none: aarch64 objects call helpers through the GOT; Mach-O the same | low | 6 | M |
| codegen/clif.rs :947-963, :256-262; mod.rs :353 | the context area is a Local data symbol addressed PC-relatively / through the GOT | owned | verify ld64/ld-prime accepts a GOT relocation against a non-external `_botlish_context_area` | medium | 6 | M |
| codegen/mod.rs `compile_actual` (:170-246) | JIT symbols: every runtime helper registered by address (`builder.symbol`); foreign C symbols bound to `rt_ffi_unlinked` (abort); fallback `dlsym` for libcalls | posix | none for the JIT; works on macOS (section 1) | low | 3 | M (done) |
| cranelift-jit `SystemMemoryProvider` (memmap2 + region) | RW pages flipped to RX with `mprotect`, no `MAP_JIT`, no `pthread_jit_write_protect_np` | owned | works for the runner's ad-hoc-signed driver (section 1). A hardened-runtime or notarized driver would need the JIT entitlement or `MAP_JIT`: out of scope until packaging (milestone 10) | medium | 3, 10 | M |
| codegen/mod.rs `emit_object` (:334-350) | none: cranelift-object picks Mach-O from the triple, symbols get the Mach-O `_` prefix from the object crate, `LC_BUILD_VERSION` with platform macOS | owned | verify the object with `otool`/`nm` and link it (milestone 6). No unwind tables are written on either OS (`unwind_info` false; cranelift-object has no Mach-O `.eh_frame`) | medium | 6 | M |
| codegen/mod.rs `relax_context_got` (:372-392), `context_relocations` (:397-450); test :483-496 | an ELF64 parser rewriting R_X86_64_GOTPCREL to REX_GOTPCRELX for the context area | elf + arch | none: it returns early for non-ELF objects (a no-op on Mach-O); the test is x86-64-only | low | 6 | L |
| codegen/clif.rs :631 `stack_maps`, `define` (:327-403, :378 `below_fp`), roots.rs :845 | native-frame stack maps on x64 and aarch64 (by architecture, so on macOS too); aarch64 roots are FP-relative, a rationale observed on Linux prologues (:375-377) | arch | the FP-relative scheme does not depend on where a Rust helper's frame record sits, and macOS puts it elsewhere (section 1). Verified for 400 recursive allocating frames under GC stress (build400.nir, section 15); Tier C's GC-stress acceptance is the wide check | high | 4 | M (partly done) |
| codegen/roots.rs `plan` (:782-827, :788 `depth_reservation`) | the shadow-stack depth token is dropped only when native frames *and* the Linux guard are supported | linux | on macOS every calling function keeps a one-slot depth token, the bound on recursion until milestone 5 | medium | 5 | M |
| codegen/roots.rs :75, :94, :164, :775-777; clif.rs :559-566; framemap.rs :3 | comments: the stack-map path is "x86-64 only" | arch | stale comments (aarch64 is in the code) | low | 4 | L |

## 5. Executables, the driver, the stub linker and the single executable

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| codegen/aot.rs `emit_executable` (:188-203) | `cfg!(all(target_os = "linux", target_env = "gnu", ...))`, else "executable emission requires Linux glibc on x86_64 or aarch64" | linux | the gate milestone 6 opens for `macos` + `aarch64`, for the rustc linker only | medium | 6 | M (refusal verified) |
| codegen/aot.rs `link_rustc` (:241-296), startup crate (:63-180) | rustc links the program object with `-C link-arg=OBJ`, `-C force-frame-pointers=yes`, `-C relocation-model=pic`, no `--target`; the rlib beside the driver | owned | the same driver on macOS (rustc drives Apple ld): verify; the startup crate's `extern "C"` names match the object's `_`-prefixed symbols | medium | 6 | M |
| codegen/aot.rs `link_plan_args` (:312-330), rationale :303-311, test :690-708 | `-Wl,--start-group`/`--end-group` and `-C default-linker-libraries=yes`, justified by GNU ld and glibc | linux | Apple ld resolves archives without groups and may reject the flags: a per-OS link plan, Linux's unchanged | medium | 7 | M |
| codegen/aot.rs `linker_diagnostics` (:224-239) | filters GNU ld/lld/collect2 wording ("undefined reference", "cannot find") | linux | add Apple ld's ("Undefined symbols for architecture arm64", "library not found for -l") | low | 7 | M |
| main.rs `run_linked` (:352-432) | a program that calls C runs as a linked executable in a temp directory | posix | none beyond `emit_executable` | low | 7 | M |
| codegen/aot.rs `link_stub` (:333-370), runtime/aotimage.rs `Image::load`/`map_near`/`main` (:477-612), codegen/aot.rs `image`/`read_object` (:372-667), bin/botlish-aot-stub.rs | the toolchain-free stub linker: an ELF64 x86-64 reader, x86 trampolines, 4 KiB pages, `MAP_FIXED_NOREPLACE`, `/proc/self/exe` | elf + arch + linux | none planned: macOS executables use the rustc linker. A Mach-O arm64 stub would need a Mach-O reader, arm64 branch relocations and veneers, an icache flush, 16 KiB pages and code signing -- a Darwin toolchain inside Botlish, which the doctrine rules out | -- | -- | -- |
| single/build.sh, single/main.tcl :101-103, single/package.tcl | one Linux x86-64 glibc executable; forces the stub linker; static zipfs tclsh from source | linux + elf | out of scope (no macOS single executable in this port); package.tcl itself is portable Tcl | -- | 10 | -- |
| main.rs :99-103, runtime/aot.rs :38-45 | Botlish runs on a spawned thread with a 1 GiB stack (`BOTLISH_NATIVE_STACK_BYTES`, at least 1 MiB) | posix | accepted on macOS (the JIT runs); its guard and bounds are milestone 5's | low | 5 | M (done) |
| main.rs :136-153 (`--result`), :143-144 `#[cfg(target_os = "linux")] set_result_fd` | the overflow report goes to the `--result` file through a Linux-only call; the gate is looser than the platform module's (Linux riscv64 would not compile) | linux | macOS needs its own `set_result_fd` with its guard (milestone 5); align the cfg | low | 5 | L |
| main.rs exit statuses, `emit` (:104-131), runtime/aot.rs `driver_protocol` (:93-152) | none: driver protocol, result lines, exit status 0/1/2/3 | posix | none | low | -- | M (done) |
| runtime/aot.rs :5-9, main.rs :26-27 | doc text: "the real Linux argument vector", "128 KiB per-argument cap" | -- | wording; the code is `std::env::args_os` | low | 6 | L |

## 6. Runtime: threads, stack bounds and overflow

The only file named for Linux, `runtime/platform/linux.rs`, and everything
that calls it, sits behind `cfg(all(target_os = "linux", any(target_arch =
"x86_64", target_arch = "aarch64")))`; macOS compiles without it and
silently runs without a guard.

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| runtime/mod.rs :20-21, native_stack.rs :26-35 (`current`, `native_stack_overflow_supported`) | the platform layer exists for Linux only | linux | a `platform/macos.rs` (or `darwin.rs`) beside linux.rs, the cfgs extended per OS; nothing else changes | medium | 5 | M |
| platform/linux.rs `current_stack` (:8-27) | `pthread_getattr_np` + `pthread_attr_getstack` + `pthread_attr_getguardsize`; glibc's guard directly below the reported stack | linux | libc 0.2.189 declares none of the three for Apple; it has `pthread_get_stackaddr_np` (the *high* end) and `pthread_get_stacksize_np`. The guard below a secondary thread's stack must be found or made: verify Darwin's pthread guard for a `stack_size`-built thread | high | 5 | M |
| platform/linux.rs `fault_handler` (:46-67), `OverflowGuard` (:81-143) | thread identity by `syscall(SYS_gettid)` in an `AtomicI32`; `sigaltstack` (64 KiB heap Vec), `sigaction` SIGSEGV+SIGBUS `SA_SIGINFO|SA_ONSTACK`, `si_addr`, `write` + `_exit`; unrelated faults re-raised with `SIG_DFL` | linux (tid) + posix (the rest) | no `SYS_gettid` on Apple: a per-thread identity that is async-signal-safe to read (a thread-local flag, or `pthread_threadid_np`'s u64 stored before the guard is armed); keep SIGSEGV and SIGBUS (which one a guard hit raises on macOS: verify); 64 KiB lies between Apple's MINSIGSTKSZ (32 KiB) and SIGSTKSZ (128 KiB) | high | 5 | M |
| vm.rs :242-248, :278-301 (non-Linux branches) | without the platform layer: `native_stack: None`, a 32 MiB shadow stack (4M slots) as the depth bound, `publish_active_stack` a no-op | linux | correct fallback until milestone 5; the census records what it does to a deep recursion (section 15) | high | 5 | M |
| main.rs :563-567, runtime/aot.rs :52-56, :101-106 | the guard is installed for JIT runs and executables on Linux only | linux | install the macOS guard at the same three points | medium | 5 | M |

## 7. GC roots and the frame walk

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| runtime/framewalk.rs `current_fp`, `root_address`, `walk_from` (:105-216) | the AAPCS64 frame-record chain (x29); aarch64 roots at `caller_fp - entry`; the walk bounded by `NativeStack` | arch | compiled, unit-tested and run under GC stress on macOS (sections 1 and 15). With `native_stack = None` the walk has no address bound: it relies on the thread's outermost frame ending the chain (null or non-ascending fp), backstopped by `MAX_FRAMES`, which held in every macOS run so far. Milestone 5's stack bounds give it one | high | 4 | M (partly done) |
| .cargo/config.toml | `-C force-frame-pointers=yes` for `x86_64-unknown-linux-gnu`, `x86_64-apple-darwin`, `aarch64-unknown-linux-gnu`; no `aarch64-apple-darwin` entry | owned | rustc keeps frame records in calling functions on this target by default (section 1); an explicit entry would also cover leaf functions and state the dependence: add it in milestone 4, with the GC-stress evidence | medium | 4 | M |
| framewalk.rs :205 | return addresses compared raw with code ranges | arch | correct for arm64 (no pointer authentication of return addresses); an arm64e build would need stripping | low | 4 | M |
| heap.rs `collect` (:118-249), vm.rs `collect_with` (:401-468), bytesobj.rs | a non-moving mark-sweep over Rust's global allocator; no mmap, no page size | posix | none | low | 4 | M |

## 8. Coroutines

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| runtime/coroutine.rs `CoStack::new` (:195-228), Drop (:238-258) | `mmap(MAP_PRIVATE|MAP_ANONYMOUS|MAP_NORESERVE|MAP_STACK)` + a 64 KiB `PROT_NONE` guard | linux | no `MAP_STACK` for Apple in libc; `MAP_NORESERVE`'s meaning there to verify; the guard size is a multiple of 16 KiB already | medium | 4 | M |
| coroutine.rs `stack_bytes` (:169-176) | rounds `BOTLISH_NATIVE_COROUTINE_STACK_BYTES` to 4 KiB | arch + linux | round to the runtime page size (16 KiB on Apple Silicon) | low | 4 | M |
| coroutine.rs switch assembly (:268-365), `extern "C"` (:367-374) | `global_asm!` with ELF directives (`.type X,@function`/`%function`, `.size`) and bare labels | elf | the AArch64 switch is reusable on Apple arm64 (callee-saved x19-x28, d8-d15, x29/x30, FPCR; never x18) once the directives are Mach-O's and the labels `_bl_co_switch`/`_bl_co_trampoline` (or per-format `#[cfg]` text) | medium | 4 | M |
| coroutine.rs `prepare` (:498-516) | the initial FPCR is 0, "the Linux default" | arch | verify Darwin's default FPCR | low | 4 | M |
| coroutine.rs :230-235 (non-Linux `new`) | refuses: "native coroutines need stack switching, implemented for x86-64 Linux only" (stale: AArch64 Linux works too) | linux | the explicit refusal macOS gets today (section 15); remove it with the port | low | 4 | M (refusal verified) |

## 9. Syscall transports, direct modules and contextual IO

Linux's raw syscall transport does not imply that macOS needs one. Darwin's
kernel interface is private and unstable; its stable interface is
libSystem. The macOS port's IO goes through C calls of libSystem (the C
FFI), behind the same portable `io::IO` context trait.

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| runtime/syscall.rs transports (:66-139), stubs (:242-270) | `syscall` (x86-64) and `svc #0` with x8 (AArch64) for Linux only; elsewhere `NATIVE UNSUPPORTED "linux::abi::aarch64::syscall needs a Linux AArch64 target"` | linux | none: never port raw Darwin syscalls (x16, `svc #0x80`). The refusal is the right macOS behavior (verified, section 15) | low | 9 | M (refusal verified) |
| lib/linux.bot, lib/linux/sys.{x86_64,aarch64}.bot, lib/linux/io.bot, lib/linux/path.bot | the `linux` namespace and `linux::io::LinuxIO`, the only `io::IO` implementation | linux | a macOS IO context (a `darwin::io`-style module of `extern c fn` calls to libSystem `write`/`read`) implementing `io::IO`; `lib/io.bot` is already portable | medium | 9 | M |
| hir/direct.tcl, core/native.tcl `declareDirectNamespace` (:319-332) | the transport namespaces are the designated direct intrinsics | posix | none: a libSystem module is direct because its retaining C calls are (C-FFI.md, section 9) | low | 9 | L |
| ops.rs `rt_bytes_addr` (:846-856), `rt_mbytes_addr` (:1155-1166); comment :843 | payload addresses as small Ints; "47-bit Linux x86-64 user space" | posix | none (the check is portable); comment wording | low | 8 | M |

## 10. C FFI

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| core/cabi.tcl `macos-aarch64` row; hir/cabi.tcl `NamespaceTypeDecls` | plain char signed, LP64 | -- | none: verified (section 1) | low | 2 | M (done) |
| native/lower.tcl :1608-1619 (NIR `foreign N "symbol"`), clif.rs `foreign_call` | a bare C symbol name | owned | none: the object crate adds Mach-O's `_` (C-HEADER-ARCHAEOLOGY.md's "user label prefix"); verify a link | low | 7 | M |
| value.rs :32-43, :430-452 (`cptr`), ffi.rs `rt_ffi_bad_address` | a C address is a sign-extended 60-bit word; a top-byte-tagged pointer fails `NATIVE ADDRESS` | arch | holds for arm64 user space (no TBI/PAC tags on data pointers expected): verify with real libSystem pointers | medium | 7 | M |
| codegen/clif.rs `c_signature`; nir.rs `ForeignDecl` (no parameter-count limit) | stack-passed C arguments follow the platform ABI | owned | Cranelift implements Apple's natural-size packing of stack arguments: verify `bcf_many`/`bcf_tenth` (tests/cffi/fixture.c :45-55) | high | 7 | M |
| native/lower.tcl `BorrowCall` (:4885-4960), `ExposeStorage`/`KeepExposedAlive` | byte exposure, private write copies, keepalive | posix | none | low | 8 | M |
| tests/cffi/fixture.c :124-154, :180-202 (`bcf_dirty_*` and the other assembly) | inline assembly with ELF directives and bare labels | elf + test | a Mach-O variant of the AArch64 functions (`_` labels, no `.type`) | low | 7 | M |
| tests/c-ffi.test :25-26 `linuxNative`, :36-50 (fixture build: `cc -c -O2 -fPIC`, `ar rcs`) | the fixture is built on Linux only | test | build it on macOS too (static archives work, section 1) | low | 7 | M |
| tests/c-ffi.test `cf-scalar-transport` (:427-430); audit/c-ffi/tools/fuzz.tcl :65-66 | plain char unsigned when `tcl_platform(machine)` is `aarch64` *or* `arm64` | test | **wrong on macOS** (signed, section 1): take signedness from `core::cabi::target [core::cabi::hostTarget]` | low | 7 | L |
| tests/c-ffi.test `tclLinkable` (:55), examples/ffi/tcl/tcl.bot :17 | `-ltcl9.0` (Debian's library name) | test | Homebrew's is `libtcl9.0.dylib` under `$(brew --prefix tcl-tk)/lib`: verify, with `-L` | low | 10 | M |
| examples/ffi/sha256/boringssl.bot :23 | `extern c library "stdc++"` (GNU libstdc++) | linux | macOS links `c++` (libc++): a per-OS library list is a language question (C-FFI.md has no conditional `extern c library`) | medium | 10 | M |
| tests/c-ffi.test `cf-missing-library` (:529), `cf-sha256-executable` (:732-739, `ldd`) | GNU ld wording; `ldd` | test | Apple ld wording; `otool -L` | low | 7 | M |

## 11. Tests and the test harness

The harness assumes the native backend is built and native code runs:
there is no skip for an unbuilt or unsupported native backend, and most
native tests carry no host constraint at all.

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| per-file constraints `nativeLinux`, `executableAot`, `nativeStackGuard` (`os eq "Linux" && machine in {x86_64 amd64 aarch64}`; 22, 36 and 1 files) | false on macOS (os, and machine `arm64` is not in the list): 117 + 131 + 4 tests skip there (the census) | test | as each capability lands, widen its constraint by capability, not by OS name; keep the definitions in step (they are copied per file) | medium | 3-9 | L |
| `linuxX86_64` (7 files), `linuxAarch64`, `stubLinker` (3 files), `x86_64Host` (native.test :779, no OS check) | instruction-set/syscall-ABI and ELF tests | test | none: correct to skip on macOS; `x86_64Host` should also require Linux (it reads ELF with `readelf`) | low | 3 | L |
| tests/helpers.tcl `outcomeUnder`/`outcomeUnderHir` (:234-278), `sourceAgree` (:293-302); 97 files with four-backend lists | a differential test runs every backend, cranelift included, unconditionally | test | on macOS these tests run natively and pass or fail on real behavior (section 15): the right signal | -- | 3 | M |
| tests/native-stack-overflow.test :8 | `native::binary` at top level: the file errors without a driver | test | none on macOS (the driver builds) | low | 5 | L |
| tests/native-stack-map.test :126, :132, native-root-storage.test :180, native.test :798 | expect "no depth helper" on Linux x86-64/aarch64 and the depth helper elsewhere | test | run unconstrained on macOS, checking the "elsewhere" branch (section 15); flip with milestone 5 | low | 5 | M |
| tests/golden/run.tcl `hosts`, `onHost` (:196-207) | golden hosts are `linux-x86_64`, `linux-aarch64`; `onHost` requires Linux | test | add `macos-aarch64` when a suite needs it; `abi-bytes-native.bot` makes live Linux syscalls with no `golden-host` (a gap on any non-Linux host) | low | 9 | L |
| tests/golden.test :32-39, tests/workload-2048.test :32-36 | drop the native backends off Linux | test | widen with milestone 3/4 | low | 3 | M |
| tests/local.tcl `processors` (:50-53), :127-129 | `exec nproc` (falls back to 4: macOS has no `nproc`); `LANG=C.utf8` forced | test | `sysctl -n hw.ncpu` on Darwin; the locale is harmless | low | 10 | M |
| objdump `-M intel`, `readelf`, `strace`, `ldd`, `/proc/$pid/maps`, `\x7fELF` (abi-bytes, linux-syscall, contexts, native.test :792, aot-stub-linker :240, native-executable :33, portable-io) | GNU/Linux tools and ELF | test | none: those tests are Linux-constrained or tool-constrained already, or read executables macOS does not build yet | low | 6 | L |
| tests/argv.test :821-828 | argc == 0 (Linux >= 5.18 behaviour) | test | constrained by `pythonLauncher`; recheck with executables | low | 6 | M |

## 12. Packaging, audit tools and benchmarks

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| .devcontainer/setup.sh | apt, `dpkg --print-architecture`, the Tcl 9.0.1 `.deb`s | linux | tests/platform/setup-macos.sh is macOS's (Homebrew tcl-tk) | -- | 1 (done) | -- |
| .github/actions/build-native | cache keyed by `runner.os` and `runner.arch` | -- | none: reused unchanged on macOS | -- | 1 (done) | M (done) |
| audit/*/tools/mutate.tcl, audit/golden/tools/tree.tcl :151, :244 | `exec timeout` (GNU coreutils; tree.tcl :244 is used by check.tcl) | linux | macOS has no `timeout`: guard or replace before running the mutation harnesses or check.tcl there | low | 10 | M |
| audit/2048/mutate.tcl :23 | `exec nproc` without a fallback | linux | as tests/local.tcl | low | 10 | M |
| audit tools (`raw-int-abi/tools/asm.tcl`, `traits/tools/evidence.tcl`, ...), native/generate-scalar-audit.tcl | `objdump -dr -M intel`, `R_X86_64_*` | arch + elf | x86-64 Linux evidence tools; leave them | -- | -- | -- |
| bench/golden-suites.tcl :98-101, bench/phase-profile.tcl :198-199, bench/coroutines.tcl :270-273, :296 | `/proc/self/status` VmHWM (coroutines.tcl without a fallback); `ru_maxrss` (bytes on macOS, KiB on Linux) | linux | per-OS memory measurement when benchmarks run on macOS | low | 10 | M |
| fuzz/scripts/*.sh | AFL, qemu, `/proc/sys/kernel/core_pattern` | linux | out of scope | -- | -- | -- |

## 13. Already portable: reuse unchanged

- **Cranelift owns the machine ABI.** No calling convention is spelled in
  native/: the host triple gives AppleAarch64, the object format Mach-O,
  the symbol prefix `_`. Do not add a `CallConv` or a symbol-mangling rule.
- **The C ABI target model** (core/cabi.tcl, hir/cabi.tcl): the
  `macos-aarch64` row is right, and the cache key already holds the full
  target. Do not invent a second target representation.
- **The NIR and native lowering** (native/lower.tcl, nir.rs) know no OS:
  only the syscall ops name Linux, and they compile everywhere.
- **The runtime's value model, heap and collector** (value.rs, heap.rs,
  vm.rs, bytesobj.rs, strobj.rs, ops.rs): 215 unit tests pass on macOS.
- **The frame walker** is per architecture, not per OS, and runs on macOS.
- **The driver protocol** (main.rs, native/native.tcl's `RunDriver`,
  `--result`, output inheritance) is std-only.
- **The rustc linker path** (codegen/aot.rs `link_rustc`): rustc drives
  the platform linker, so Mach-O executables need no Botlish linker.
- **Byte borrowing** (hir/borrow.tcl, `BorrowCall`) is OS-neutral.
- **`lib/io.bot`'s `io::IO` context trait** is the portable IO surface;
  macOS adds an implementation, not a new abstraction.
- **CI plumbing**: `.github/actions/build-native` works on macOS as is.

## 14. Boundaries where a broad change would regress Linux

- **`cfg(target_os = "linux")` gates.** Widening one to `unix` would pull
  glibc-only calls (`pthread_getattr_np`, `SYS_gettid`, `MAP_STACK`,
  `MAP_FIXED_NOREPLACE`) into macOS builds, which then fail to compile --
  or, worse, an `#[cfg(not(...))]` fallback silently becomes Linux's. Add
  a macOS branch beside each Linux one; leave the Linux branch's text
  alone.
- **The syscall transport table and `linux::sys` selection.** Giving the
  `aarch64` row an OS-dependent meaning would change Linux AArch64's
  module and transport. An OS dimension must leave every Linux lookup's
  result unchanged (tests/linux-syscall-transports.test pins them).
- **The link plan.** GNU ld needs `--start-group` and the default linker
  libraries (the BoringSSL AArch64 fix of C-FFI.md, section 11). Apple ld
  needs neither: split by OS, never "simplify" Linux's.
- **Stack probes and the depth token.** They are tied to
  `native_stack_overflow_supported()`. Turning that on for macOS before
  the macOS guard and bounds exist drops the depth token (roots.rs :788)
  and leaves recursion unbounded. Change the predicate only with the
  guard.
- **The AArch64 frame layout.** The walker's FP-relative roots
  (clif.rs `define`, framewalk.rs `root_address`) serve Linux AArch64 too.
  A macOS-motivated change to them must keep the arm64 CI's GC-stress run
  green.
- **Test constraints.** Most native tests have no host constraint. A
  macOS-motivated skip must name a capability, never `os ne "Darwin"`,
  so Linux keeps every test.
- **The golden manifest.** A new `tests/*.test` file needs a census row
  and a regenerated manifest (AGENTS.md, "Golden tests"); the macOS
  scripts in tests/platform/ are deliberately not `.test` files.

## 15. The macOS census

What the repository's own tests do on a `macos-15` runner with the native
backend built: run 2 of the workflow (at aac30aa, before main's merge),
every `tests/*.test` file on interp in three shards (`tests/all.tcl
-file`), every golden suite on all four backends, and probes of the native
runtime; then the files that failed, rerun alone (run @DIAGRUN@,
`CI-Tests:`) to read their causes. `tclsh9.0 tests/platform/tier.tcl all`
(`[ci-full]` with `CI-Tests: all`) reproduces it.

**Tcl test files** (interp; the test files run every program on the
native backends too, whatever CORE_BACKEND says):

| Shard | Files | Passed | Failed | Skipped | Wall |
|---|---:|---:|---:|---:|---:|
| 1/3 | 62 | 2459 | 9 | 138 | 601 s |
| 2/3 | 63 | 2565 | 25 | 120 | 568 s |
| 3/3 | 63 | 2375 | 89 | 94 | 426 s |
| **all** | **188** | **7399** | **123** | **352** | |

171 of the 188 files pass. The skips are the Linux host constraints of
section 11 (`executableAot` 131, `nativeLinux` 117, `linuxX86_64` 45,
`cfFixture` 40, `stubLinker` 7, `nativeStackGuard` 4, `linuxAarch64` 2,
`boringssl` 2, and single ones: `readelf`, `rustcAvailable`,
`singleExecutable`, `tclLibrary`). The 17 files with failures, their
causes and owners -- tests/platform/tier.tcl's `notYet` holds the same
list, which the acceptance tier leaves out:

@CENSUS-TABLE@

**Golden suites.** Every suite passes on interp and compile. On both
native backends every suite aborts with `native coroutines need stack
switching, implemented for x86-64 Linux only (COROUTINES.md) (NATIVE
UNSUPPORTED value)`: the golden runner, `lib/test.bot`, is itself a
coroutine, so no native golden run is possible before milestone 4. The
two `golden-host: linux-x86_64` suites are compiled and not run, as
designed. (The second golden shard was cancelled by a later push before
it finished; its suites passed on interp and compile in the acceptance
tier, run @ACCRUN@.)

**Native runtime probes** (botlish-native and main.tcl, run 2):

| Probe | Outcome on macOS arm64 | Meaning |
|---|---|---|
| fib.nir, loop-count.nir (driver) | values | the JIT runs NIR |
| build400.nir under `BOTLISH_NATIVE_GC_STRESS=1` | value (400 live recursive allocating frames) | the frame walk finds every root under stress |
| stack_overflow.ir, 4 MiB stack | `thread '<unknown>' has overflowed its stack` / `fatal runtime error: stack overflow, aborting`, SIGABRT | **no Botlish guard**: Rust's own guard-page handler aborts the process |
| large_frame_overflow.nir, 4 MiB stack | the same Rust abort | no stack probes either |
| stack_overflow.ir, default 1 GiB stack | `NATIVE LIMIT STACK` | the shadow depth token (4M frames) is reached before the native stack ends -- for these tiny frames |
| deep recursion (`depth(n - 1)`, 10^8 deep) on cranelift, 1 GiB | **`child killed: segmentation violation` (NATIVE BUG)** | the native stack ran out before the depth token, and the fault escaped Rust's handler too |
| the same with a 64 MiB stack | Rust's stack-overflow abort (NATIVE BUG) | |
| a coroutine program on cranelift | `native coroutines need stack switching, implemented for x86-64 Linux only (COROUTINES.md) (NATIVE UNSUPPORTED value)` | an explicit refusal (stale text: AArch64 Linux works too) |
| examples/io/hello.bot, examples/linux/write.bot on cranelift | `linux::abi::aarch64::syscall needs a Linux AArch64 target (NATIVE UNSUPPORTED value)` | an explicit refusal; note the program compiled, with `lib/linux/sys.aarch64.bot` chosen for the macOS target (section 3) |
| examples/ffi/tcl/tcl.bot on cranelift | `executable emission requires Linux glibc on x86_64 or aarch64 (NATIVE LINK)` | an explicit refusal |
| `-emit-native-executable` | the same text, `(NATIVE AOT)` | an explicit refusal |
| the stdlib examples on cranelift | values | |
| `native::object` | `Mach-O 64-bit object arm64`; `_botlish_fn_N`, `_botlish_entry_N` defined, `_rt_*` undefined; `LC_BUILD_VERSION` platform 1 (macOS), minos 0.0 | Cranelift writes a Mach-O object; minos 0.0 is to check against Apple ld at link time (milestone 6) |
| `cargo test --release` (every target) | passes | |
| `cargo test --release` under GC stress | **one failure**: `runtime::ops::tests::bytes_from_list_copies_every_byte_exactly_including_nul_and_high_bytes` | a test bug (below) |
| `codesign -dv botlish-native` | `flags=0x20002(adhoc,linker-signed)` | the linker's ad-hoc signature, under which the JIT's mprotect works |
| botlish-aot-stub | `botlish-aot-stub runs on x86-64 Linux only (NATIVE STARTUP)`, exit 1 | as designed |
| `ulimit -s` | 8176 (KiB) | the main thread's; Botlish runs on its own 1 GiB thread |

**The GC-stress unit-test failure is a test bug every platform has.**
`rt_bytes_from_list` copies the list's bytes, then allocates the storage
(native/src/runtime/ops.rs): correct. The unit test holds the list `l`
only in a Rust local, unrooted; under GC stress the allocation collects
it, and macOS's allocator hands the freed block straight back, so
`assert_ne!(b, l)` fails. glibc's allocator does not reuse that block, so
Linux passes by luck. The fix (root `l` in the test, `Vm::temp_roots`)
belongs to milestone 4 with the rest of macOS GC-stress validation.

**What the native status check records** (tests/platform/native-status.tcl,
every smoke run): on `macos-aarch64` the JIT and the GC frame walk under
stress give their values; the stack overflow is the Rust abort (the one
recorded crash, kept so milestone 5 must change it); coroutines, the Linux
syscall and executables are their refusals above; a C call is
`NATIVE LINK` with the executable-emission refusal. On Linux every one
gives its value.

**Nothing silently wrong was found.** Every capability either works,
refuses with a stated error, or -- the native stack overflow -- crashes the
driver, which main.tcl reports as `NATIVE BUG`. No probe or test produced a
wrong value on macOS.

## 16. CI and test tiers

How an agent that develops on Linux (or on a Mac of its own) gets real
Apple Silicon results. Nothing here needs a shared development Mac, a
secret or a self-hosted runner.

### The workflow

`.github/workflows/macos-arm64.yml`, "tests (macos arm64)":

| Job | Tier | Runner | What | Typical time |
|---|---|---|---|---|
| `smoke` | A | `macos-15` | host facts (fails unless `Darwin`/`arm64`, not Rosetta); `tests/platform/toolchain-smoke.sh`; `tests/platform/setup-macos.sh`; `tests/platform/cabi-facts.tcl`; the native build (`.github/actions/build-native`, cached); `cargo test --lib`; `tests/platform/native-status.tcl`; `tier.tcl smoke` | @SMOKE@ |
| `acceptance` (2 shards) | B | `macos-15` | `tier.tcl -shard I/2 -backends interp acceptance` | @ACCEPTANCE@ |
| `linux-control` | A | `ubuntu-latest` | the smoke commands on Linux x86-64 at the same commit | @LINUX@ |
| `full` (3 shards) | C | `macos-15` | opt-in (below) | @FULL@ |

- **Triggers:** `push` to any branch (so a feature branch is tested before
  the workflow is on main), `pull_request` (a same-repository pull request
  skips every job: its push already ran; a fork's runs), and
  `workflow_dispatch` (only once the file is on main). Pushes and pull
  requests that change only `*.md` files do not run it.
- **Concurrency:** one run per branch; a newer push cancels the running one
  (not on main). So do not push to a branch while you wait for a long run
  on it: the push cancels it.
- **No macOS job waits for a Linux runner.** (An earlier version planned
  the tiers in an ubuntu job; it sat in the queue behind main's Linux
  workflows, which share the account's concurrent-job limit with this
  one.) The macOS jobs share GitHub's limit of 5 concurrent macOS jobs:
  smoke and acceptance are 3, a full run 3 more, so a sixth queues.
- **The runner label** is `macos-15`, written in the smoke, acceptance and
  full jobs. It is an Apple Silicon image (`macos-15-arm64`); the smoke
  job's host step fails on anything else, so a wrong label cannot pass
  silently.

### The tiers and their commands

The same commands run locally wherever their host requirements hold; the
workflow only adds the macOS host.

**Tier A, development smoke** (seconds, locally and in CI):

```sh
tests/platform/toolchain-smoke.sh            # the host's C and Rust toolchains, not Botlish
tclsh9.0 tests/platform/cabi-facts.tcl       # core::cabi's host row against the C compiler
tclsh9.0 tests/platform/native-status.tcl    # each native capability as recorded for this host
tclsh9.0 tests/platform/tier.tcl smoke       # the sample programs and a dozen front-end test files
tclsh9.0 tests/platform/tier.tcl X.test Y.bot   # any test file or golden suite, as CI runs it
CORE_BACKEND=interp tclsh9.0 tests/X.test    # one file directly (exits 0 even on failures: read it)
cargo test --release --manifest-path native/Cargo.toml --lib NAME   # one Rust test
```

**Tier B, CI acceptance** (every push): `tier.tcl acceptance` -- every
Tcl test file except `notYet`'s, and every golden suite on interp and
compile. Locally it is about half an hour of one core; CI runs it in two
shards on interp (`-backends interp`).

**Tier C, exhaustive, opt-in.** The default payload is the acceptance tier
on both Tcl backends under `BOTLISH_NATIVE_GC_STRESS=1`, in three shards.
Named items replace it; `all` is the census (every file, every suite on
every backend, the Rust tests), which fails on macOS as section 15 says
until the port is done.

### Requesting Tier C from a feature branch

Put `[ci-full]` in the message of the **head** commit of a push (only the
head commit of the push counts). Narrow it with git trailers in the last
paragraph of the same message:

```
Fix the AArch64 frame record offset [ci-full]

CI-Tests: coroutines.test affine.test mutable-vector.test
CI-GC-Stress: 1
Co-Authored-By: ...
```

- `CI-Tests:` names tier.tcl items, space-separated: test files, golden
  suites, `smoke`, `acceptance`, `all`, `rust`, `examples`, `cabi`. Named
  files and suites run in shard 1 (shards 2 and 3 stop after one step); a
  tier is split in three.
- `CI-GC-Stress: 1` runs the named items under GC stress (the default
  payload always is).
- Without either trailer, `[ci-full]` runs the default payload.
- Once the workflow is on main, a manual run does the same on any branch:
  `workflow_dispatch` of `macos-arm64.yml` with the branch as the ref and
  the inputs `tier: full`, `tests`, `gc_stress` (the GitHub MCP server's
  `actions_run_trigger`, method `run_workflow`; or `gh workflow run
  macos-arm64.yml --ref BRANCH -f tier=full -f tests="X.test"`).
- To run the same payload again on the same commit, re-run the run
  (`actions_run_trigger`'s `rerun_workflow_run` or `rerun_failed_jobs`):
  it reads the same message. To change the payload, push a new commit (or
  amend and force-push your own branch) with new trailers.
- An ordinary push without `[ci-full]` never runs Tier C, and a docs-only
  commit never runs anything: put the marker on a commit that changes a
  non-`.md` file, or use workflow_dispatch.

### Reading results

- **Runs and jobs:** the GitHub MCP server's `actions_list`
  (`list_workflow_runs` with `workflow_runs_filter.branch`, then
  `list_workflow_jobs`). Without it, the public REST API answers
  unauthenticated (`curl -s
  https://api.github.com/repos/OWNER/REPO/actions/runs/RUN/jobs`, 60
  requests an hour).
- **Logs:** `get_job_logs` with the job id (`tail_lines` to bound it). Every
  tier.tcl run ends with its summary: one `######## LABEL: ok|FAILED`
  line per command, then `FAILED:` lines, each with the command that reruns
  the failing file or suite alone. The job's step summary shows the same
  lines.
- **Artifacts:** Tier C uploads each shard's `tier.log`
  (`full-shard-N`). Downloading one goes through Azure blob storage, which
  an agent's network policy may block; the job log holds the same text.

### Toolchain failure or Botlish failure?

| Step that fails | Meaning |
|---|---|
| `Host` | not an arm64 macOS runner (the label changed meaning) |
| `Toolchain smoke` | the runner's C or Rust toolchain: an image problem, not Botlish |
| `Install prerequisites` | Homebrew's tcl-tk or rustup (network, a formula rename, Tcl 10) |
| `C ABI facts` | core::cabi's `macos-aarch64` row disagrees with Apple clang: a Botlish target-table bug |
| `Build native` / `Native Rust unit tests` | the native crate on macOS: a Botlish change that compiles only on Linux, or a runtime unit test |
| `Native status` | a native capability changed behavior (section 15): intended, then record it; otherwise a regression |
| a tier | Botlish tests; compare with `linux control` at the same commit and with Linux CI |

### Reproducing one failure

1. Run the failing file locally on Linux (`CORE_BACKEND=interp tclsh9.0
   tests/X.test`, the command the summary printed). If it fails there too
   it is not macOS's; if it passes, it is.
2. Rerun only it on macOS: a push with `[ci-full]` and `CI-Tests: X.test`
   (one job, a few minutes).
3. Read the test's own output in that job's log (tcltest prints each
   failing test with its body and result).

Do not rerun a whole tier to look at one file, and do not start Tier C to
check a change Tier B already covers.

### Keeping Linux covered

The Linux workflows are unchanged (tests.yml, tests-arm64.yml,
single-executable.yml, bench.yml, static-decisions.yml). They run on
pushes to main and on pull requests; on a branch without a pull request,
dispatch them (they all have `workflow_dispatch` on main):
`actions_run_trigger` with `workflow_id` `tests.yml` (and
`tests-arm64.yml`; `static-decisions.yml` for a front-end change) and the
branch as `ref`. A port milestone runs them before it merges.

### Updating CI when a milestone lands

- **A capability starts working on macOS:** update its expectation in
  `tests/platform/native-status.tcl` (the smoke job fails until you do),
  remove the files that now pass from tier.tcl's `notYet` (run them with
  `CI-Tests:` first), and update section 15.
- **Native golden runs** (after coroutines work): drop the interp/compile
  restriction from the acceptance tier's golden suites in tier.tcl.
- **More backends in Tier B:** the acceptance job's `-backends`.
- **A new macOS-only check:** a step in `smoke` (cheap) or an item of
  tier.tcl (anything a test file or suite cannot express); never a
  `.test` file that only macOS runs.
- **The runner image:** when `macos-15` is retired, change the three
  `runs-on` lines together.

## 17. Roadmap

Each milestone is independently mergeable: it makes one capability work
on macOS, flips that capability's `tests/platform/native-status.tcl`
expectation from its refusal to its value, moves the test files and
golden suites that now pass into `tests/platform/tier.tcl`'s acceptance
lists, and leaves everything not yet ported refusing exactly as before.
Every milestone runs the Linux suites (tests.yml, tests-arm64.yml) on its
branch before it merges; one that changes the front end also runs
static-decisions.yml (AGENTS.md).

### 1. CI infrastructure and platform audit (this milestone)

The workflow, the tiers, the scripts in tests/platform/, this document and
the census. Report: MACOS-AARCH64-MILESTONE-1.md.

### 2. Target representation and macOS C ABI facts

- **Files:** core/linuxabi.tcl, surface/modules.tcl (`ModuleFile`),
  surface/cache.tcl (`Dependencies`), hir/interchange.tcl, main.tcl,
  hir/cabi.tcl; tests/c-ffi.test :413-415, audit/c-ffi/tools/fuzz.tcl
  :60-64.
- **Prerequisites:** milestone 1.
- **Acceptance:** importing a `linux` namespace for a `macos-aarch64`
  compilation is a stated diagnostic (not `lib/linux/sys.aarch64.bot`); a
  `.hirx` records its target and a native run refuses another host's; a
  native run or link refuses a `-target` that is not the host; the tests'
  plain-char expectations come from `core::cabi`. The `macos-aarch64` row
  itself is already verified (cabi-facts.tcl, smoke).
- **macOS CI:** smoke and acceptance; the census (`CI-Tests: all`) to show
  nothing else moved.
- **Linux risks:** `linux::sys` selection and its cache dependencies
  (tests/linux-syscall-transports.test, tests/hir-cache.test), the
  interchange format (HIR-INTERCHANGE.md's audits), static decisions.

### 3. Pure Cranelift codegen and native JIT

- **Files:** native/src/codegen/{mod.rs,clif.rs,roots.rs}; the stale
  "x86-64 only" comments; tests/golden.test and tests/workload-2048.test's
  drop-native-off-Linux rules; the constraints of section 11 that guard
  JIT-only tests.
- **Prerequisites:** 2 (for the module refusal the JIT tests see).
- **Acceptance:** every census failure whose cause is JIT code generation
  is fixed; `tests/native-coverage.tcl -backend cranelift` (and
  cranelift-generic) classifies only the capabilities of later milestones
  as failures on macOS; the census shows no other native-value mismatch.
- **macOS CI:** acceptance; `CI-Tests: all`; a coverage run.
- **Linux risks:** low if no codegen change is OS-conditional; any change
  to `isa()` or signatures runs the arm64 workflow.

### 4. Native allocation, GC and coroutine validation

- **Files:** .cargo/config.toml (an `aarch64-apple-darwin` entry),
  runtime/framewalk.rs, codegen/clif.rs `define`, runtime/coroutine.rs
  (stack mapping without `MAP_STACK`, page-size rounding, Mach-O
  directives and `_` labels in the switch assembly, the initial FPCR).
- **Prerequisites:** 3.
- **Acceptance:** coroutines.test, affine.test, mutable-vector.test and the
  coroutine-using tests of the census pass on macOS, also under
  `BOTLISH_NATIVE_GC_STRESS=1` (Tier C's default payload);
  native-status's `coroutine` expectation is its value; the frame walk's
  termination without stack bounds is either proven (GC stress) or bounded
  by milestone 5 first.
- **macOS CI:** full (GC stress), `CI-Tests: coroutines.test affine.test`.
- **Linux risks:** high: the AArch64 switch and frame layout are shared
  with Linux AArch64 -- the arm64 workflow's GC-stress run is required.

### 5. Runtime stack bounds and overflow handling

- **Files:** runtime/platform/ (a macOS module beside linux.rs),
  runtime/native_stack.rs, runtime/vm.rs, main.rs (:143, :563),
  runtime/aot.rs (:52, :101), codegen/mod.rs (stack probes),
  codegen/roots.rs (`depth_reservation`).
- **Prerequisites:** 4 (coroutine stacks have guards too).
- **Acceptance:** the macOS worker thread's bounds and guard are
  discovered; a native overflow is `NATIVE LIMIT STACK` (from the guard,
  not the depth token) for the JIT and, after milestone 6, executables;
  stack probes are on; tests/native-stack-overflow.test, the depth-helper
  expectations of native-stack-map.test, native-root-storage.test and
  native.test run on macOS with the Linux branch's results.
- **macOS CI:** smoke (native-status `stack-overflow`), full.
- **Linux risks:** `native_stack_overflow_supported()` and the depth token
  decide Linux's code too: the predicate may only grow.

### 6. Mach-O AOT, native driver and standalone executable

- **Files:** codegen/aot.rs (`emit_executable`'s gate, `link_rustc`),
  codegen/mod.rs (`emit_object`), runtime/aot.rs; the `executableAot`
  constraints; main.tcl/native.tcl's text.
- **Prerequisites:** 5 (an executable installs the guard).
- **Acceptance:** `-emit-native-executable` produces a Mach-O arm64
  executable through the rustc linker that runs and prints its value;
  native-status's `executable` expectation is its value; the
  executable tests that are not about ELF, Linux syscalls or the stub
  linker run on macOS. The stub linker stays Linux x86-64.
- **macOS CI:** acceptance (the executable test files join it), full.
- **Linux risks:** `link_rustc`'s Linux arguments stay byte-identical; the
  stub-linker job.

### 7. C scalar/pointer ABI, symbol resolution and linking

- **Files:** codegen/aot.rs (`link_plan_args`, `linker_diagnostics`),
  codegen/clif.rs (`c_signature`, `foreign_call`), tests/cffi/fixture.c
  (Mach-O assembly), tests/c-ffi.test (fixture build, char, `ldd`, linker
  wording).
- **Prerequisites:** 6.
- **Acceptance:** c-ffi.test's fixture tests pass on macOS: narrow
  arguments and results, stack-passed arguments, pointer results and wild
  addresses, `named` symbols, `extern c library` with `-L`;
  native-status's `c-call` expectation is its value.
- **macOS CI:** acceptance, `CI-Tests: c-ffi.test`.
- **Linux risks:** GNU ld's group and default-library flags (C-FFI.md,
  section 11) must stay.

### 8. Bytes borrowing, FFI fuzzers and GC stress

- **Files:** native/lower.tcl's exposure code (unchanged, expected),
  audit/c-ffi/tools, audit/c-pointer-borrowing/tools (and `exec timeout`,
  which macOS lacks).
- **Prerequisites:** 7.
- **Acceptance:** c-pointer-borrowing.test and the non-syscall parts of
  abi-bytes/abi-mutable-bytes pass on macOS; the C FFI and borrowing
  fuzzers run there with GC stress.
- **macOS CI:** full, with the fuzzers as named items or a Tier C step.
- **Linux risks:** the exposure mechanism is shared with the syscall
  bridges: abi-bytes and mutable-bytes mutation tools.

### 9. Darwin system APIs and contextual IO

- **Files:** a macOS IO module implementing `io::IO` over libSystem C
  calls (lib/), tests/portable-io.test, tests/golden/run.tcl's hosts.
- **Prerequisites:** 7 (C calls), 2 (the Linux-module refusal).
- **Acceptance:** examples/io/hello.bot's macOS twin prints through
  libSystem `write`; portable-io's tests run on macOS; no raw Darwin
  syscall anywhere.
- **macOS CI:** acceptance, full.
- **Linux risks:** `io::IO` selection must keep choosing LinuxIO on Linux
  (context-traits tests).

### 10. Applications, regression breadth, optional libraries, documentation

- **Files:** examples/games/2048, tests/application-modules.test,
  examples/ffi/{tcl,sha256}, tests/cffi/boringssl.tcl, tests/local.tcl
  (`nproc`), bench/ memory measurement, packaging (hardened runtime and
  the JIT, if a signed driver is ever shipped).
- **Prerequisites:** 9.
- **Acceptance:** the census is all green (`CI-Tests: all`), the 2048
  workload runs natively and as an executable, the Tcl and BoringSSL
  acceptance link on macOS (Homebrew's Tcl, libc++); this document's
  findings are closed or recorded as non-goals.
- **macOS CI:** the full matrix; Tier B grows to the whole suite.
- **Linux risks:** none specific.
