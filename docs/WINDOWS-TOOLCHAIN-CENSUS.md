# WINDOWS-TOOLCHAIN-CENSUS.md

Where Botlish's Windows ABI and toolchain boundary actually is, what in the
compiler, runtime, standard library, FFI, binding generator, tests and
tooling matters to running Botlish natively on Windows x86-64, and which
toolchain the port should carry forward: MinGW-w64 (GNU) or MSVC. A census
with small experiments, not an implementation milestone: nothing in
production changed. Written for the agents of the Windows port's later
milestones: start here.

> **Decision: switch the Windows native toolchain to MSVC now** --
> `x86_64-pc-windows-msvc` as the Rust host of the native driver and
> runtime, executables linked by `link.exe` through rustc, as the front end
> already assumes (`core::cabi::hostTarget` maps every Windows host to
> `windows-x86_64`, MSVC's row). Keep everything else exactly as it is:
> Cranelift's COFF object is the same byte for byte for both toolchains,
> `link.exe` takes it unchanged, MSVC-linked Botlish executables and C
> calls pass on a real Windows runner, and Botlish has no assembler,
> linker, CRT startup or SDK discovery of its own to replace. The hard
> Windows work (GC roots, stack probes, the guard, coroutines, argv,
> platform IO) is the same under either toolchain. MinGW stays only where
> it is evidence today -- the
> generated Win32 binding of `windows-x86_64-gnu` -- until the binding
> generator reads the Windows SDK; it does not become a second native
> backend. Section 9 gives the reasons and what would have changed them;
> section 10 the next slice.

Every finding says how it is known: **[V]** verified by an experiment of
section 6 (which one), **[C]** known from reading the code (file and line),
**[L]** likely, not verified.

## Contents

1. [The answer in brief](#1-the-answer-in-brief)
2. [The current Windows architecture](#2-the-current-windows-architecture)
3. [Census](#3-census)
4. [What MinGW buys today](#4-what-mingw-buys-today)
5. [What a minimal MSVC path requires](#5-what-a-minimal-msvc-path-requires)
6. [Experiments](#6-experiments)
7. [FFI and bindgen](#7-ffi-and-bindgen)
8. [Independent Windows blockers](#8-independent-windows-blockers)
9. [Decision](#9-decision)
10. [Recommended next vertical slice](#10-recommended-next-vertical-slice)
11. [Reproducing](#11-reproducing)
12. [Files](#12-files)

## 1. The answer in brief

1. **Nothing native runs on Windows today, with either toolchain.** The
   runtime library compiles for both Windows triples; the driver
   (`botlish-native`) does not, at seven sites in two places -- Unix-only
   argv and file-permission calls (`native/src/main.rs:440-446`,
   `native/src/codegen/aot.rs:455-456`) -- and the error lists for
   `x86_64-pc-windows-gnu` and `x86_64-pc-windows-msvc` are identical
   [V: E1]. No Windows code path, MinGW or MSVC, exists anywhere in
   `native/` [C].
2. **The toolchain boundary is the Rust host target of the driver, and
   nothing upstream of it.** The front end produces the same NIR for
   `windows-x86_64` and `windows-x86_64-gnu` except for the `target` line,
   and the driver emits a byte-identical COFF object for both [V: E6].
   Cranelift owns the machine ABI (Win64 for both), the `object` crate
   writes COFF, and rustc -- not Botlish -- drives the system linker and
   supplies the CRT entry. Choosing a toolchain therefore means choosing
   which Rust toolchain builds the driver and runtime and which linker
   rustc calls; it costs one link-plan spelling (section 5).
3. **The object is acceptable to the GNU and LLVM COFF linkers, and
   executables linked through MinGW run correctly** -- a pure program, a
   C ABI probe (positional Win64 registers, stack arguments, LLP64
   `long`, 16-bit `wchar_t`, narrow results, exposed byte storage) through
   MinGW-built and MSVC-ABI static libraries and DLLs, and Win32 console
   output straight from kernel32 [V: E7-E10, under Wine]. **On a real
   Windows host, `link.exe` takes the object as it is**, and the same
   programs pass through MSVC- and MinGW-built static libraries, DLLs and
   import libraries, linked by rustc with no Developer Command Prompt
   [V: E13].
4. **MinGW is not part of Botlish's Windows identity in the native path.**
   What looks MinGW-specific there is an accident: the link plan's GNU
   spelling (`-lNAME`, `-Wl,--start-group`) is chosen for every non-Apple
   host (`aot.rs:355`), which happens to suit MinGW's ld. MinGW *is* the
   whole Windows side of the C binding generator (headers, triple, version
   pin, import libraries) [C].
5. **The serious Windows work is toolchain-neutral.** The native GC finds
   roots by walking the RBP chain through Rust frames; LLVM's Win64
   prologue (both Rust Windows targets) puts RBP inside the frame, so GC
   stress gives wrong results and crashes on Windows -- on a real Windows
   host even an ordinary run of the 2048 benchmark fails, under either
   toolchain [V: E5, E13, E14]; with no frame walk the existing fallback
   root plan is correct [V: E13c, E14c]. Stack probes are off on Windows
   although Windows needs them (`codegen/mod.rs:158`) [C]. Cranelift code
   has no `.pdata`/`.xdata` unwind entries [V: E9].
   The overflow guard, coroutines, argv, `.exe` naming and platform IO are
   all Unix-shaped (section 8). None of this depends on MinGW versus MSVC.
6. **The front end already chose MSVC.** `core::cabi::hostTarget` maps a
   Windows host to `windows-x86_64` (`x86_64-pc-windows-msvc`), the test
   harness's capability constraints key on it, and `windows-aarch64` is an
   MSVC triple too [C, `core/cabi.tcl:86-88,167-184`]. The only consumer
   of `windows-x86_64-gnu` is the binding generator.

## 2. The current Windows architecture

### 2.1 From source to process

How a Botlish program gets from source to a Windows process, as far as it
gets today, and where the toolchain enters:

```text
 FILE.bot
   │  surface/ (parser, loader)         portable Tcl; reads the target only in
   │  hir/ (analyses)                   three places (core/cabi.tcl's table)
   ▼
 HIR  ── target recorded when it depends on one (hir::cabi::targetOf):
   │      windows-x86_64 (msvc triple) by default on a Windows host
   │  native/lower.tcl                   portable Tcl
   ▼
 NIR text ── `target "windows-x86_64" triple="x86_64-pc-windows-msvc"`
   │         identical for -gnu but for this line                 [V: E6]
   │  botlish-native (Rust)             DOES NOT COMPILE for Windows [V: E1]
   │    codegen::isa: cranelift_native  host ISA, Win64 default convention
   │    clif.rs: c_signature            CallConv::triple_default → WindowsFastcall
   │    cranelift-object + object 0.39  COFF; GOT loads → `.refptr.SYM` stubs
   ▼
 program.o (COFF x86-64)                byte-identical for both targets [V: E6]
   │  codegen/aot.rs link_rustc         `rustc` (no --target: the host's)
   │    startup.rs: fn main → aot::run  CRT entry supplied by rustc's target:
   │                                    mainCRTStartup (msvc) / crt2.o (gnu)
   │    -C link-arg=program.o + plan    the plan is GNU-spelled (aot.rs:397)
   ▼
 system linker (rustc's, per Rust host target)
   │    msvc: link.exe (found by rustc itself)   gnu: gcc → GNU ld (or lld)
   ▼
 FILE.exe ── runtime::aot::run: worker thread (1 GiB reserved), Vm, statics,
             no stack guard on Windows, then Botlish code
             ↔ runtime helpers: Rust `extern "C"` = Win64
             ↔ C: WindowsFastcall, import-library thunks
```

The Tcl backends (`interp`, `compile`) need nothing native and run
anywhere Tcl 9 runs; on Windows they are untested by CI (E13/E14 run them
for the first time). They cannot print: the only `std::io::IO` implementation
is `std::linux::io`, raw Linux syscalls (`main.tcl:58-62`, `stdlib/linux/io.bot`)
[C].

### 2.2 The seams

| seam | owner | what decides it on Windows | toolchain-dependent? |
|---|---|---|---|
| C data model, char signedness | `core/cabi.tcl` target table | the row (`windows-x86_64`, `-gnu` equal: LLP64, signed char) | no: rows equal [C] |
| host target | `core::cabi::hostTarget` | `tcl_platform(os)` → `windows-x86_64` (MSVC) always | names MSVC [C] |
| platform namespaces | `core/cabi.tcl` `platforms` | only `linux` is designated | no |
| target identity in HIR/NIR | `hir::cabi::targetOf`, NIR `target` line | the row's triple | the line only [V: E6] |
| ISA, register use, prologues | Cranelift (`cranelift_native`, host triple) | Win64 | no [V: E6] |
| foreign C convention | `codegen/target.rs:38` `triple_default` | WindowsFastcall for both triples | no [C] |
| object format, relocations | `cranelift-object`, `object` 0.39.1 | COFF; GOT → `.refptr` stubs | no [V: E6] |
| unwind info | `cranelift-object` | none written for COFF (`backend.rs:144-172`: "silent no-op") | no [V: E9] |
| executable link | `codegen/aot.rs` `link_rustc` → rustc | rustc's linker for its host target | **yes: the one seam** |
| link plan spelling | `aot.rs` `LinkerFlavor` | Gnu for every non-Apple host | GNU spelling [C] |
| CRT and process entry | rustc's target | msvcrt.dll + crt2.o (gnu) / vcruntime + UCRT (msvc) | yes [V: E7; E13] |
| driver ↔ host target check | `codegen/target.rs:103` `same_target` | architecture and OS family only | ignores gnu/msvc [V: E10] |
| C headers for bindings | `tools/cheader/toolchain.tcl`, profiles | `windows-x86_64-gnu` → clang `x86_64-w64-mingw32` + MinGW headers | MinGW only [C] |

The macOS port's separations carry over where they apply: a target is an
operating system *and* an architecture; the C convention and the object
format are Cranelift's reading of the triple; the platform linker is
reached through rustc with its own link plan (`LinkerFlavor`,
MACOS-AARCH64-MILESTONE-6.md); a capability constraint, not an OS, gates a
test. What does not carry over is the Unix runtime layer (signals,
pthread stack discovery, the frame-pointer chain through Rust frames), and
the ELF-only stub linker.

## 3. Census

Classifications: **neutral** (already platform-neutral), **Windows-ready**,
**MinGW** (MinGW-specific), **MSVC** (MSVC-specific), **POSIX** (Unix-
specific, needs work), **Windows** (Windows-specific but toolchain-neutral),
**probe** (unknown).

### 3.1 Front end and target model

| component | where | class | notes |
|---|---|---|---|
| target table: `windows-x86_64` (msvc), `windows-x86_64-gnu`, `windows-aarch64` (msvc) | `core/cabi.tcl:81-88` | Windows-ready | LLP64, signed char; the rows are equal and still two targets [C] |
| host detection | `core/cabi.tcl:167-184` | MSVC | `Windows NT`/`amd64` → `windows-x86_64`; never `-gnu` (`tm-host-default`) [C] |
| platform designation | `core/cabi.tcl:96` | neutral | only `linux`; a Windows platform namespace needs a row [C] |
| module paths, application root, cache | `surface/modules.tcl`, `surface/cache.tcl` | neutral | `file join`/`file normalize`; case-insensitive file systems not considered [C] |
| HIR interchange and cache key | `hir/interchange.tcl`, `surface/cache.tcl` | Windows-ready | full target in the key; `-gnu` HIR refused as `windows-x86_64` (`tm-windows-gnu-identity`) [C] |
| NIR | `native/lower.tcl` | neutral | only the `target` line differs [V: E6] |
| `main.tcl` options | `main.tcl:583-603` | POSIX | `-emit-native-executable` writes `FILE` without `.exe`; `-L` becomes `-LDIR` (GNU spelling) [C] |

### 3.2 Native code generation and objects

| component | where | class | notes |
|---|---|---|---|
| ISA settings | `codegen/mod.rs:148-166` | POSIX | probes only where the overflow guard exists; Windows needs them regardless (B3) [C] |
| Botlish and helper calls | `clif.rs` `signature_n`, `declare` | neutral | the ISA default convention = Win64 on Windows = Rust `extern "C"` [C] |
| foreign C calls | `clif.rs` `c_signature`, `target.rs:38` | Windows-ready | WindowsFastcall; narrow arguments extended (harmless: 8-byte slots) [C]; correct against MinGW and MSVC-ABI code [V: E8] |
| COFF object | `emit_object`, cranelift-object, object 0.39.1 | Windows-ready | `.text`, `.rdata$.refptr` (plain sections, static `.refptr.SYM` symbols, ADDR64), REL32 [V: E6] |
| context-area GOT relaxation | `codegen/mod.rs:373-451` | neutral | ELF-only, a no-op on COFF; its unit test fails on COFF [V: E4] |
| unwind info | cranelift-object | Windows | none for COFF; JIT registers none either (B4) [V: E9] |
| stack maps and root plan | `clif.rs:649`, `roots.rs:789-806` | POSIX | gated on architecture only, so active on Windows; depend on the frame walk (B2) [V: E5] |

### 3.3 Linking, executables, the driver

| component | where | class | notes |
|---|---|---|---|
| `EXECUTABLES`, `C_CALLS` | `aot.rs:204-218` | POSIX | Linux glibc, macOS AArch64 only [C] |
| startup crate | `aot.rs:74-194` | POSIX | `std::os::unix::ffi::OsStringExt` (`:90`) [C] |
| rustc invocation | `aot.rs:304-326` | neutral | no `--target`: assumes rustc's host is the driver's (B10) [C] |
| link plan | `aot.rs:347-419` | MinGW (by accident) | `-lNAME`, `-LDIR`, GNU group; link.exe needs `NAME.lib`, `/LIBPATH:` [C]; works with MinGW ld [V: E8] |
| linker diagnostics | `aot.rs:265-283` | POSIX/MinGW | GNU ld, lld, Apple text; no `LNKnnnn` [C] |
| stub linker | `aot.rs:423-758`, `runtime/aotimage.rs`, `bin/botlish-aot-stub.rs` | POSIX (Linux by design) | ELF x86-64 only; stays [C] |
| linked run of a C-calling program | `main.rs:393-473` | POSIX | `arg0`, `OsStr::from_bytes`; output name `program` [C] |
| result file and overflow report fd | `main.rs:159`, `runtime/aot.rs:104`, `platform/guard.rs` | POSIX | raw fds; Windows needs a HANDLE [C] |
| worker thread | `main.rs:114-119`, `runtime/aot.rs:40-46` | Windows-ready | `std::thread` with a 1 GiB reservation [C, V: E3] |
| JIT memory | cranelift-jit 0.135.2 | Windows-ready | `VirtualAlloc` via memmap2/region [V: E3] |
| `.cargo/config.toml` | repo root | POSIX | `force-frame-pointers` for four Unix triples only [C] |

### 3.4 Runtime

| component | where | class | notes |
|---|---|---|---|
| `runtime::platform` (stack bounds, guard) | `runtime/platform/*` | POSIX | sigaltstack, SIGSEGV/SIGBUS, pthread bounds; not compiled on Windows (B5) [C] |
| GC frame walk | `runtime/framewalk.rs:105-216` | POSIX | RBP chain through Rust frames (B2) [V: E5] |
| shadow-stack fallback | `vm.rs:248-252`, `roots.rs:789-806` | POSIX | leaf functions still use the walk; hangs under GC stress on Windows [V: E5] |
| coroutines | `runtime/coroutine.rs:293-337` | POSIX | SysV `global_asm!` with ELF directives, mmap stacks; refused cleanly on Windows (B6) [C] |
| Linux syscall transports | `runtime/syscall.rs` | Linux by design | unsupported elsewhere; stays [C] |
| FFI support, fixtures | `runtime/ffi.rs`, `ffifixture.rs`, `nview.rs` | neutral | no symbol lookup at run time [C] |
| argv snapshot | `runtime/vm.rs`, ARGV.md | POSIX | raw bytes; Windows' command line is UTF-16 (B7) [C] |
| unit tests | `native/src` | Windows-ready | 233/233 lib, 40/41 driver under Wine [V: E4] |
| `native/tests/native_stack.rs` | | POSIX | does not compile on Windows [V: E1] |

### 3.5 Standard library and platform IO

| component | where | class | notes |
|---|---|---|---|
| `std::io::IO` context trait | `stdlib/io.bot:48` | neutral | the seam a Windows IO context plugs into [C] |
| its one implementation | `stdlib/linux/io.bot` over `std::linux::sys` | Linux by design | no Windows implementation: programs cannot print on Windows (B9) [C] |
| `std::io::path::Path` | `stdlib/io/path.bot` | neutral | only `std::linux::path` implements it [C] |
| Win32 from Botlish | `audit/windows-toolchain/programs/win32.bot` | Windows | `GetStdHandle` + `WriteFile` with hand-written facts works [V: E10] |

### 3.6 FFI and the binding generator

Section 7 has the detail; the classification:

| component | class |
|---|---|
| `std::ffi::c` scalars, `Bool`, `Double`, `Ptr`, `FnPtr`; `extern c fn` contract | neutral |
| varargs, aggregates by value, `float`, `long double` | refused everywhere (neutral) |
| `tools/cheader/toolchain.tcl` triples (`windows-x86_64-gnu` → `x86_64-w64-mingw32`; no msvc entry) | MinGW |
| `profiles/win32.tcl` (MinGW 11.0.1 version pin, `_mingw*.h` privates, `libNAME.a` import libraries) | MinGW |
| `generate.tcl:70-78` (`*triple*` include directory) | MinGW (Debian layout) |
| probes (`_Generic`, `.quad`, `&NAME`, `__builtin_types_compatible_p`, `-fdump-record-layouts`) | neutral for clang |
| `generated/c/win32/windows-x86_64-gnu/` | MinGW evidence |
| `tests/c-ffi.test` ABI model, `tests/cffi/fixture.c` asm | POSIX (SysV, ELF) |

### 3.7 Tests, harness, packaging, CI

| component | where | class |
|---|---|---|
| capability constraints (`executableAot`, `nativeCoroutines`, `nativeStackGuard`, `nativeCCalls`) | `tests/helpers.tcl:116-151` | neutral design; tables lack Windows |
| OS constraints (`nativeLinux`, `linuxX86_64`, ...) | many test files | Linux by design |
| `x86_64Host` (`native.test:779`) | | POSIX (reads `readelf` output on any x86-64) |
| `c-bindgen.test:468` | | POSIX: a `dict get` in `-result` that aborts the file on Windows |
| `application-modules.test:281-284` | | POSIX: `sh -c` with only `nativeBuilt` |
| `tests/golden/run.tcl` | | POSIX: native backends kept on non-Linux, coroutine runner |
| `tests/binary-header.tcl` | | POSIX: ELF and Mach-O only, no PE |
| `tests/platform/aot-facts.tcl`, `native-status.tcl` | | POSIX: no Windows rows; `/bin/sh`, `ldd`, `nm`, `objdump` |
| `tests/platform/cabi-facts.tcl` | | MinGW: GCC-style `cc -dumpmachine` |
| `tests/local.tcl` | | Windows-ready (`LOCALAPPDATA`; `nproc` with a fallback) |
| `single/` | | Linux by design (static tclsh, stub linker, `chmod`) |
| `.github/workflows/` | | no Windows job before `windows-probe.yml` |
| `.gitattributes` | | absent: byte-exact checks under `core.autocrlf` (probe) |
| `AGENTS.md:486-492` | | stale: runs GC stress in WSL because "Windows-native execution exercises a different stack/guard implementation" -- there is none; native Windows has no guard and its GC walk is broken (B2, B5) |
| `C-BINDGEN-LAYOUTS.md` section 11 | | stale: lists `OVERLAPPED` and `WIN32_FIND_DATAW` as blocked; the fixed-array and union milestones made both layouts (`cb-win32-sentinels`) |

### 3.8 The rest of the checklist

| concern | what exists | class |
|---|---|---|
| process spawning | the driver starts rustc and a linked program with `std::process` (`aot.rs:304`, `main.rs:442`); main.tcl starts the driver with `open \|`/`exec` (`native/native.tcl:161,239-247`) | neutral (the argv bytes and `arg0`: POSIX, B7) |
| environment variables | `BOTLISH_NATIVE_*`, `RUSTC`, `BOTLISH_HIR_CACHE` through `std::env` and `::env`; `LANG`/`LC_ALL` matter on Linux only | neutral |
| dynamic library loading | none at run time: no `dlopen`/`dlsym`; C symbols resolved by the system linker; a DLL is found by the Windows loader (the executable's directory, `PATH`) | neutral [V: E8] |
| threads | one worker thread with a large reservation; no other threads | neutral [V: E3] |
| atomics | the guard's lock-free publication (`platform/guard.rs`), Unix-only today; plain `std` atomics a Windows guard can reuse | neutral |
| TLS | `thread_local!` only (`vm.rs:97`, `coroutine.rs:172`); generated code uses none | neutral |
| event loop | none exists | -- |
| file system, paths | Tcl `file` commands in the front end; `std::path` and rename-into-place in the driver; `std::io::path::Path` has only a Linux implementation | neutral; the platform path is B9 |
| native library discovery | `-L DIR` and the linker's own search; for MSVC rustc sets up `LIB`; no run-time search path | MinGW spelling today (section 5) |
| build scripts, self-hosting | Cargo builds `native/` (portable); the compiler is Tcl, not self-hosted; `single/build.sh` is bash and Linux-only | neutral / Linux by design |
| artifacts encoding ELF/Mach-O/POSIX | the stub linker's ELF reader and image (`aot.rs:463-758`); `relax_context_got`'s ELF rewrite; `tests/binary-header.tcl`; the scalar-assembly audit corpus (objdump of ELF); the Linux and macOS generated bindings | Linux/macOS by design; none blocks Windows |
| variadic C calls | refused at declaration (`surface/parser.tcl:1521`) | neutral, independent FFI work |

## 4. What MinGW buys today

Sorted into the four kinds this census was asked to separate:

1. **Intrinsic to the generated ABI or object format: nothing
   MinGW-specific.** PE/COFF x86-64 and the Microsoft x64 calling
   convention are Windows', shared by both toolchains; Cranelift's object
   is identical for both [V: E6]. The `.refptr.SYM` stubs that stand in
   for a GOT are the MinGW GCC convention by name, written by the `object`
   crate for every COFF target (`object-0.39.1/src/write/coff/object.rs:158-168`),
   but they are plain read-only data with an ADDR64 relocation, which any
   COFF linker takes [V: E8, E9; link.exe: E13].
2. **Conveniences supplied by the compiler driver** (gcc, through rustc's
   `x86_64-pc-windows-gnu` target): the CRT startup (`crt2.o`), the
   default libraries (`-lmsvcrt -lmingwex -lmingw32 -lgcc -lkernel32 ...`,
   which `-C default-linker-libraries=yes` keeps), the `-lNAME` search of
   `libNAME.dll.a`, `libNAME.a` *and* `NAME.lib`, the group semantics, and
   the C runtime itself -- the legacy `msvcrt.dll`, not the UCRT [V: E7:
   the executable imports `msvcrt.dll`]. The msvc target has an equivalent
   for each one (`mainCRTStartup`, rustc's own `/DEFAULTLIB`s, `NAME.lib`,
   no ordering problem, vcruntime + UCRT).
3. **Replaceable build-script assumptions:** the link plan's GNU spelling
   (`aot.rs:397-419`), chosen for every non-Apple host rather than for
   MinGW; `main.tcl`'s `-L`; the binding generator's MinGW header layout
   (`*triple*` include directory, a single include root, `lib$NAME.a`
   import libraries, `ar rcs` shims) and the Win32 profile's MinGW version
   pin; `cabi-facts.tcl`'s `cc -dumpmachine`.
4. **POSIX leakage to remove whatever the toolchain:** argv as bytes with
   a separate `argv[0]` (`main.rs:440-446`, `aot.rs:90`), executable
   permissions (`aot.rs:455`), names without `.exe`, raw file descriptors
   for result and overflow reports, signals and `sigaltstack`, pthread
   stack discovery, `mmap` coroutine stacks, SysV assembly, the frame
   walk's frame-pointer assumption, Linux syscalls as the only IO, and the
   test harness's `sh`, `env`, `objdump`, `ldd`, `readelf`.

So "MinGW support" means today: *the C binding generator produces
Windows bindings from MinGW-w64's headers and import libraries, on Linux*.
Botlish has accumulated no MinGW semantics or runtime dependency in the
compiler or the native backend -- there is no native Windows backend to
have accumulated them. The risk runs the other way: the first native
Windows milestone would make it so, if it adopted the GNU link plan and
the `-gnu` Rust host because they happen to work unchanged.

## 5. What a minimal MSVC path requires

The smallest real MSVC pipeline, from what E13 ran (the probe patch,
`audit/windows-toolchain/probe.patch`, is its prototype):

**Compiler (code generation) changes: none specific to MSVC.** The object
is the same; the Win64 convention is Cranelift's; foreign calls already
use `WindowsFastcall`. The toolchain-neutral Windows changes (section 8)
are needed for MinGW too.

**Driver and link changes:**

1. The seven build errors (shared with MinGW): `cfg(unix)` the argv code
   of the linked run and the stub linker's permissions; give the startup
   crate a Windows argv (`into_encoded_bytes` is the probe's stand-in).
2. `EXECUTABLES` and `C_CALLS` gain `all(target_os = "windows",
   target_env = "msvc", target_arch = "x86_64")` (with them, E13's
   executables and C calls pass).
3. A `LinkerFlavor::Msvc` plan: `link-arg=/LIBPATH:DIR` and
   `link-arg=NAME.lib`, no group (link.exe searches every library until
   nothing more resolves). The alternative, rustc's own `-L native=DIR -l
   NAME`, spells the plan per flavor by itself but loses GNU's group; the
   explicit flavor matches the macOS precedent.
4. `linker_diagnostics` learns the MSVC linker's messages (`error
   LNK2019: unresolved external symbol`, `LNK1181: cannot open input
   file`, `LNK1120`) and `lld-link: error:` (`cf-missing-library` fails on
   MSVC without them and passes on MinGW [V: E13, E14]).
5. rustc gets `--target` with the driver's own triple: a Windows machine
   commonly has both Rust host toolchains, and the startup crate must
   match the runtime rlib (`aot.rs:304` passes none) -- [L] for MSVC
   only, [V] for the class of bug (E10: the gnu driver accepted an MSVC
   program).
6. `.exe`: the driver and `main.tcl -emit-native-executable` name the
   output. `link.exe` keeps an extensionless `/OUT` name and Windows runs
   the file anyway (E13a); MinGW's gcc appends `.exe`, which broke every
   link of E14a. Executables should simply be `NAME.exe` on Windows (B8).
7. The C runtime: rustc links the dynamic CRT by default (`/MD`:
   `VCRUNTIME140.dll` and the UCRT API sets [V: E13a's dumpbin]).
   `VCRUNTIME140.dll` is the Visual C++ redistributable's, not Windows':
   the executable's promise in `aot.rs:1-6` ("only the system's own
   libraries") needs `-C target-feature=+crt-static` on the startup crate,
   and with it an executable imports only system DLLs [V: E13b]. MinGW's
   executables meet it today through `msvcrt.dll`, which every Windows has
   [V: E7, E14b].

**Tool discovery: nothing for Botlish to write.** rustc finds `link.exe`,
the MSVC libraries and the Windows SDK's import libraries itself (its
`cc`-based Visual Studio lookup), with no Developer Command Prompt: E13
builds the driver and links every executable in a plain shell whose only
`link.exe` on `PATH` is Git's coreutils one [V]. Botlish needs SDK
discovery only for the binding generator (section 7).

**What MSVC does not need:** no assembler (Cranelift writes machine code;
the only hand assembly, the coroutine switch, is `global_asm!` that rustc
assembles with LLVM's integrated assembler for either target), no
`.def`/export handling (executables export nothing), no subsystem or entry
option (rustc: console subsystem, `mainCRTStartup`), no symbol decoration
on x64, no `__imp_` references (functions only, called through import
thunks), no SEH or C++ EH interplay (Rust `extern "C"` helpers abort
rather than unwind; Botlish has no exceptions).

## 6. Experiments

Local experiments ran on Linux x86-64 (Ubuntu 24.04) with rustc 1.97.0,
`x86_64-pc-windows-gnu` and `-msvc` standard libraries, MinGW-w64 11.0.1
headers and import libraries, `x86_64-w64-mingw32-gcc` 13 (win32 threads),
GNU ld 2.41.90, clang and lld 18.1.3, and Wine 9.0 (64-bit). Wine runs the
real PE machine code, Windows' x64 ABI and the PE loader; it is a stand-in
for Windows' process and memory behaviour, and E13/E14 repeat the decisive
experiments on a real Windows Server 2025 runner. The probe patch
(`audit/windows-toolchain/probe.patch`) is applied to a scratch copy of
`native/` only; production code is unchanged.

| id | experiment | result | establishes |
|---|---|---|---|
| E1 | `cargo check --all-targets` of the unpatched crate for `x86_64-pc-windows-gnu` and `-msvc` | lib compiles (4 dead-code warnings); driver 7 errors (`main.rs:440-446`, `aot.rs:455-456`); `tests/native_stack.rs` 39 errors; the two error lists are identical (`diff`) | the build blockers, and that no MinGW- or MSVC-specific code exists |
| E2 | patched driver, built for `-gnu` with MinGW-w64 gcc; `botlish-native.exe target ...` under Wine | host `x86_64-pc-windows-gnu`; `x86_64-pc-windows-msvc`: os windows, coff, `windows_fastcall`, **runs 1** | the driver treats the msvc and gnu triples as one target |
| E3 | JIT `run` of fib, `bench/uri-steady.bot`, `examples/games/2048/bench.bot` under Wine | all three values equal Linux's | Cranelift's JIT, the runtime and the worker thread work on Windows |
| E4 | the native unit tests for `-gnu` under Wine | lib 233/233 (Linux: 258, the rest gated to hosts with the guard); driver 40/41: `the_object_addresses_the_area_with_relaxable_relocations_only` (ELF relocations, expected) | the runtime library is Windows-ready apart from what is gated off |
| E5 | `BOTLISH_NATIVE_GC_STRESS=1` under Wine: (a) as built; (b) `BOTLISH_PROBE_SHADOW=1` (fallback root plan); (c) control: (b)'s configuration built for Linux; (d) every root on the shadow stack and no frame walk; (e) the fallback plan with only the frame walk disabled | (a) uri-steady **wrong** (`IndexNotFound`), 2048 bench **crashes**, fib passes; (b) fib, 2048 pass, uri-steady **hangs** (19 CPU-minutes, killed); (c) all pass in 0.02-0.3 s; (d) and (e) **all pass** | the native GC's frame walk is broken on Windows; the fallback plan is complete without it but still runs it; the cause is Windows-specific; (e) is the minimal working configuration |
| E5' | disassembly of `rt_list_append` in the `-gnu` driver | `sub rsp,0x68; lea rbp,[rsp+0x60]` | LLVM's Win64 frame puts RBP inside the frame: `[rbp]` is not the caller's RBP |
| E6 | `botlish-native.exe object` of fib and of the C ABI program, the latter's NIR built for `windows-x86_64` and for `windows-x86_64-gnu` | AMD64 COFF; `.text`, ten `.rdata$.refptr` sections (no COMDAT; static `.refptr.bwp_*` symbols, ADDR64); REL32 calls; no `.pdata`; the two objects byte-identical (`cmp`); the two NIRs differ only in the `target` line | the toolchain does not reach code generation |
| E7 | the driver's link inputs (startup crate + object) linked by rustc `-gnu` through `x86_64-w64-mingw32-gcc`; run under Wine | fib.exe prints the right value; imports KERNEL32, ntdll, USERENV, WS2_32, bcryptprimitives, an API set and **msvcrt.dll**; CUI subsystem | a Botlish executable for Windows through the MinGW path; its CRT is the legacy msvcrt |
| E8 | the C ABI program (`ffi-probe.bot`) linked the same way against `bwp` built as: MinGW static, MinGW DLL, clang `--target=x86_64-pc-windows-msvc` + `llvm-lib` static, clang msvc + `lld-link /dll /noentry` DLL with its MSVC-format import library | all four: `[42, 4, 8, 2, -5, 342.0, 385, -56, 10, 34]` (Linux control: `[42, 8, 8, 4, ...]`) | Botlish's foreign calls are correct Win64 C calls (positional registers, stack arguments past the shadow space, LLP64 `long`, 16-bit `wchar_t`, narrow results, exposed bytes) against MinGW- and MSVC-ABI code, including an MSVC import library through GNU ld |
| E9 | E8's program linked by lld (`-fuse-ld=lld`, LLVM's COFF linker under its MinGW driver); `.pdata` of the result | same value; 2,935 `.pdata` entries, none for a `botlish_fn_N` or `botlish_entry_N` | the object suits LLVM's COFF linker; Botlish code has no unwind entries |
| E10 | `win32.bot` (`GetStdHandle`, `WriteFile`, `GetCurrentProcessId` from kernel32, hand-written facts) linked through MinGW; and its `windows-x86_64` (MSVC) NIR given to the gnu driver | prints `hello from kernel32`, value `[true, 1]`; the gnu driver accepted the MSVC program and went on to link it | Win32 straight from Botlish needs no C runtime; the driver does not tell the two Windows environments apart |
| E11 | `audit/windows-toolchain/tools/probe.tcl` on Linux (the control) with a Linux `libbwp.a` | every check passes | the probe itself |
| E12 | Linux test files: target-model, c-abi-types, c-ffi, c-bindgen (MinGW-w64 installed), native-executable; the patched crate's Linux unit tests | 25/25, 73/73, 82/85 (3 skipped: BoringSSL, Apple), 55/77 (22 skipped: BoringSSL, SDL3, Tcl sources; every Win32 test ran and passed, `cb-win32-current` included), 18/18; 258 + 41 | the baseline; the probe patch changes nothing on Linux |
| E13 | the `msvc` job of `.github/workflows/windows-probe.yml` (Windows Server 2025, MSVC, `x86_64-pc-windows-msvc`) | `link.exe` links the object; executables, C calls through four library builds and Win32 output pass; the static CRT leaves only system DLLs; GC fails as built, passes with no frame walk; see 6.1 | the MSVC path on real Windows |
| E14 | the `gnu` job (MSYS2 MinGW-w64 gcc 16.2, `x86_64-pc-windows-gnu`) | the same, once the link work files carry `.exe`; executables import `msvcrt.dll`; see 6.1 | the MinGW path on real Windows |

### 6.1 The real Windows runs (E13, E14)

`.github/workflows/windows-probe.yml` on GitHub's `windows-2025` image:
Windows Server 2025, Visual Studio 18 (MSVC `cl` 19.51.36260, its
`link.exe` and the Windows SDK), rustc 1.99.1 (LLVM 23.1.1) for
`x86_64-pc-windows-msvc` and for `x86_64-pc-windows-gnu`, MSYS2's MinGW-w64
gcc 16.2.0 (`mingw64`, the msvcrt runtime), and Tcl 9.0.1 built from its
pinned source with MSVC's `nmake` (`tclsh90.exe`). The driver, its links
and the probe run in a plain shell: the only `link.exe` on `PATH` is Git's
coreutils one, so every MSVC link below is rustc finding Microsoft's
linker and the SDK by itself. Three runs: 39453878297 (E13a, E14a),
39456406045 (E13b, E14b: the probe patch names its link work files
`.exe`, and adds the all-shadow root plan and the static CRT) and
39459243510 (E13c, E14c: the fallback plan without the frame walk); run
39461151550 repeated E13c and E14c with the patch as committed, with the
same results.

**Both jobs, identically:**

- The unpatched crate fails with the seven driver errors of E1.
- The patched driver builds; lib unit tests 233/233. Driver tests: the
  ELF relocation test fails as in E4; the msvc job also fails
  `ffi_link_plan_flavor_is_the_hosts`, which the probe patch's `Msvc`
  flavor contradicts by design.
- Tcl 9.0.1 runs the front end natively: `tcl_platform(os)` `Windows NT`,
  `machine` `amd64`, `encoding system` `utf-8`, `hostTarget`
  `windows-x86_64`. The pure program passes on `interp`, `compile`,
  `cranelift` and `cranelift-generic`.
- The driver reports both Windows triples `runs 1` on either host (B10).
- `dumpbin` reads the program object: `8664 machine (x64)`, REL32
  relocations, external `rt_*` symbols -- MSVC's own tool accepts it.
- The GC fails as built, with different symptoms per run and toolchain,
  in both (B2); every root on the shadow stack with no frame walk passes
  everything:

| check | msvc a | msvc b | msvc c | gnu a | gnu b | gnu c |
|---|---|---|---|---|---|---|
| uri-steady, cranelift | pass | pass | pass | pass | pass | pass |
| uri-steady, GC stress | crash | crash | crash | wrong (`IndexNotFound`) | wrong (`std::byte::AboveRange`) | wrong (`std::byte::AboveRange`) |
| uri-steady, GC stress, fallback plan | pass | pass | pass | segfault | segfault | segfault |
| uri-steady, GC stress, fallback plan, no walk | -- | -- | **pass** | -- | -- | **pass** |
| uri-steady, GC stress, all-shadow, no walk | -- | **pass** | **pass** | -- | **pass** | **pass** |
| 2048 bench, cranelift (no stress) | **wrong** (`IndexNotFound`) | **wrong** | **crash** | **crash** | **wrong** (`IndexNotFound`) | **crash** |
| 2048 bench, GC stress | crash | crash | crash | crash | crash | crash |
| 2048 bench, GC stress, fallback plan | segfault | pass | pass | pass | pass | pass |
| 2048 bench, GC stress, fallback plan, no walk | -- | -- | **pass** | -- | -- | **pass** |
| 2048 bench, GC stress, all-shadow, no walk | -- | **pass** | **pass** | -- | **pass** | **pass** |
| fib, GC stress (every plan) | pass | pass | pass | pass | pass | pass |

  On real Windows the walk does not only miss roots under stress: an
  ordinary run of the 2048 benchmark, whose heap grows past the first
  collection, fails every time. The fallback plan fails or passes from run
  to run -- it misses no root, but still runs the walk, which faults or
  not depending on the garbage it meets (B2). Wine (E5) was kinder: its
  stacks hold different garbage. The fallback plan with the walk
  disabled -- fix (a) of B2, exactly -- passes everything in both jobs
  (E13c, E14c), as does every root on the shadow stack with no walk.

**The msvc job (E13a): the whole MSVC path works.**

- `main.tcl -emit-native-executable` links through rustc and `link.exe`;
  the executable, named `fib` without an extension as the driver asked
  (`link.exe` keeps an `/OUT` name as given), runs from Tcl's `exec` and
  prints the right value.
- The C ABI program through all four builds of `bwp` -- `cl` static
  library, `cl` DLL with its import library, MinGW gcc static library
  (`libbwp.a`, offered as `bwp.lib`) and MinGW DLL (its GNU import
  library offered as `bwp.lib`) -- JIT-run (that is, linked and run by
  the driver) and as an executable: `[42, 4, 8, 2, -5, 342.0, 385, -56, 10,
  34]` every time. `link.exe` takes GNU-format archives and import
  libraries.
- `win32.bot`: `hello from kernel32` and `[true, 1]`, run by the driver and
  as an executable.
- Every executable imports `KERNEL32.dll`, `ntdll.dll`,
  `bcryptprimitives.dll`, an API set, **`VCRUNTIME140.dll`** and the UCRT
  API sets (`api-ms-win-crt-*`): rustc's dynamic CRT (`/MD`).
- Test files: target-model 24/25 (`tm-c-call-conv-of-each-target`, B10),
  c-abi-types 71/73 (`ca-affine-coroutines`: native coroutines;
  `ca-native-code`: counts calls in a function's CLIF, which without the
  stack guard include the shadow stack's depth check [L] -- both lack a
  capability constraint), main-cli 32/33 (1 skipped), argv: the GC-stress
  and large-vector tests fail (B2), c-ffi 12 passed, 72 skipped,
  **`cf-missing-library` fails** (`linker_diagnostics` does not recognize
  the MSVC linker's messages; it passes on MinGW), application-modules
  20/21 (1 skipped).

**The msvc job with the static CRT (E13b):** `-C
target-feature=+crt-static` on the startup crate gives an executable that
runs and imports only `KERNEL32.dll`, `ntdll.dll`, `bcryptprimitives.dll`
and an API set: no `VCRUNTIME140.dll`, no UCRT DLLs.

**The gnu job (E14a): MinGW's gcc names the output `executable.exe`.**
Every executable link "succeeded" and then failed at the rename
(`...\fib: The system cannot find the file specified`): gcc appends `.exe`
to an output name without an extension, `link.exe` does not. So every C
call, which runs as a linked executable, failed too in E14a.

**The gnu job with `.exe` work files (E14b): the whole MinGW path works
too.** The pure executable, the C ABI program through all four library
builds (the `cl` static library and DLL import library through GNU ld),
JIT-run and as executables, and `win32.bot`: all pass, with the same
values as E13. Its executables import `msvcrt.dll` (and `USERENV`,
`WS2_32`), never `VCRUNTIME140.dll`; `+crt-static` changes nothing there.
Test files: as the msvc job, except c-ffi 13 passed, 72 skipped, 0 failed
(`cf-missing-library` passes: GNU ld's words are known).

The probe's C library has no stack buffers, so `cl`'s default `/GS`
emits no security-cookie checks into it: E14b shows GNU ld taking a plain
`cl` object, not a library that needs the MSVC CRT (`__security_check_cookie`,
`__GSHandlerCheck`), which MinGW's runtime does not provide [L].

## 7. FFI and bindgen

**Does the FFI model describe the Windows C ABI independently of MinGW?**
Yes [C, V: E6, E8]. A foreign call's classes come from the target row's
scalar metadata (`hir/foreign.tcl:86-101`), its convention from the triple
(`target.rs:38`), and the two Windows x86-64 rows are equal. The same
object calls MinGW- and MSVC-ABI code correctly.

**Are C primitive types inferred from Unix or GCC assumptions?** Not in
the compiler [C]: width and signedness are the row's, never a name's.
Unix assumptions live in tests: `tests/c-ffi.test`'s ABI model (`::abi`,
SysV: six registers, separately counted double registers, 8-byte `long`;
`:100-118`, `cf-abi-doubles-before-integers`) and `tests/cffi/fixture.c`'s
ELF/SysV assembly selected for any non-Apple x86-64. A Windows port of
c-ffi.test needs a Win64 model (four positional registers, shadow space).

**Types, one by one:**

| C | Botlish on Windows x86-64 | status |
|---|---|---|
| `long` / `unsigned long` | `std::ffi::c::Long`/`ULong`, 32 bits (LLP64) | correct [V: E8, sizeof 4] |
| `wchar_t`, `WCHAR` | no primitive; the binding resolves `WCHAR` to `std::ffi::c::UShort` | correct width [V: E8, sizeof 2]; wide strings cannot be exposed (byte pointees only) |
| pointer-sized (`SIZE_T`, `ULONG_PTR`, `LPARAM`) | resolved through the typedef per target (`ULongLong`, `LongLong`) | correct [C]; no `size_t`/`intptr_t` primitive |
| pointers | `std::ffi::c::Ptr[T]`, 64-bit | correct [V: E8] |
| structs, unions | layouts probed from the toolchain (`layouts.bot`); by value refused | layouts are the probed toolchain's: MinGW's today |
| enums | probed per toolchain | MinGW's today |
| function pointers | `std::ffi::c::FnPtr[Fn{...}]`, no convention field, never called | adequate for x64 (one convention) |
| variadics | refused (`surface/parser.tcl:1521`) | independent FFI work: Win64 varargs pass doubles in both registers |
| `float`, `long double` | no type | `long double` differs (MinGW 80-bit, MSVC = double) -- unsupported either way |
| `_Bool`, `double` | `std::ffi::c::Bool`, `std::ffi::c::Double` | correct [V: E8 for double] |

**Calling conventions.** On x86-64 Windows there is one C convention: the
compilers ignore `__stdcall`, `__cdecl` and `__fastcall` there, and the
generator proves it per declaration (`__builtin_types_compatible_p`;
`convention_default stdcall 3176`, no `unsupported-calling-convention`
blocker in the Win32 binding). `__vectorcall` is the one distinct x64
convention and stays blocked. A 32-bit x86 or ARM64EC target would need an
explicit convention on `extern c fn` and `FnPtr`; nothing here needs one,
and that would be a language change of its own.

**Can Botlish consume the Windows SDK without MinGW headers as the
authority?** The compiler can today: a binding is ordinary Botlish, and
the hand-written kernel32 declarations of E10 work. The generator cannot:
its only Windows configuration is `windows-x86_64-gnu` →
`x86_64-w64-mingw32`, and `configFor windows-x86_64` is an error
(`tools/cheader/toolchain.tcl:79-85,147`; `cb-win32-identity` pins it).

**Can bindgen eventually consume SDK/MSVC headers directly?** Yes, with
clang, never `cl.exe` (the probes are clang/GCC builtins). What it takes
(from reading the generator, not tried):

1. a `windows-x86_64` → `x86_64-pc-windows-msvc` entry in the toolchain
   adapter, with clang's MSVC compatibility (`-fms-extensions
   -fms-compatibility`, a pinned `-fms-compatibility-version`);
2. SDK and CRT include discovery (`um`, `shared`, `ucrt`, the VC
   `include`), a multi-directory source root, in place of `--sysroot` and
   the `*triple*` check (`generate.tcl:70-78`);
3. a version pin by SDK macros (`WDK_NTDDI_VERSION`, `_MSC_VER`) instead
   of `__MINGW64_VERSION_*`;
4. private headers for the SDK (`vcruntime*.h`, `corecrt*.h`, `sal.h`,
   `specstrings*.h`, `concurrencysal.h`, `driverspecs.h`);
5. `cdecl.tcl` learning `__int8/16/32/64` and `__forceinline`, which the
   SDK uses and MinGW turns into macros;
6. the `va-list` blocker keyed on the typedef, not on
   `__builtin_va_list` (MSVC's `va_list` is `char *`: `FormatMessageW`
   would otherwise bind its `va_list *` as a pointer);
7. import libraries as `NAME.lib` in the SDK's `um\x64` (and attribution
   to umbrella libraries such as `onecore` decided by profile);
8. the thunk shim as `NAME.lib` (`llvm-lib`, no `-fPIC`, the CRT `/MD`
   or `/MT` matching the executable's).

SAL annotations would then be visible to the generator as attributes and
could later suggest access facts (`_In_reads_bytes_`), never escape
facts.

**Does choosing MinGW now create bindgen debt?** Some, bounded. The
generated binding is regenerable and the type mapping is shared; what
would grow is MinGW evidence that has to be redone: import-library
attribution (103 of the 3,754 API names, 2.7%, have no MinGW-w64 11.0.1
import library -- among them API-set-only functions such as
`VirtualAllocFromApp`; `report.txt`), MinGW-only spellings (`WINBOOL`), MinGW header
lag behind the SDK, and every test pinned to `windows-x86_64-gnu`. The
deeper debt is semantic: the project rule is that a generated layout is
its toolchain's and never taken for another's (AGENTS.md, C-BINDGEN-LAYOUTS.md
section 12), so an MSVC native path can never use the MinGW binding as
is, and a MinGW native path ties every Windows binding to MinGW's headers.

**Does choosing MSVC now cost complexity before bindgen can benefit?**
Only in timing. The next native milestones (section 10) need a handful of
kernel32 functions, which are hand-written declarations like `stdlib/linux.bot`'s
syscall wrappers (E10 is that). Generating from the SDK needs the SDK
headers, which are not redistributable: generation moves to a Windows host
or a Windows CI runner (the c-bindgen workflow runs on Linux today), or to
a downloaded SDK the user has licensed. That is the real cost of the MSVC
path, and it falls on the bindgen milestone, not on the native port.

**Toolchain blockers versus independent FFI work.** Toolchain blockers:
the link plan spelling and the bindgen configuration above. Independent
work, the same under either toolchain: varargs, aggregates by value,
`float`, wide-string exposure, callbacks into Botlish, a Win64 version of
c-ffi.test's ABI model and fixture.

## 8. Independent Windows blockers

Work the port needs under either toolchain, with the evidence:

- **B1. The driver does not build** (E1). Seven sites; trivial except for
  the argv decision (B7).
- **B2. GC roots on Windows** (E5, E5'; on real Windows E13, E14: an
  ordinary run of the 2048 benchmark fails under both toolchains). `runtime/framewalk.rs` climbs the
  RBP chain from inside `Vm::collect` through Rust helper frames to the
  first Botlish frame; `.cargo/config.toml`'s `force-frame-pointers` makes
  that chain exist on Linux and macOS. On Windows LLVM's prologue sets
  `rbp = rsp + k` (the Win64 `UWOP_SET_FPREG` form), so the walk reads
  garbage: missed roots (wrong values) and faults. The fallback root plan
  (`stack_maps` false: roots on the shadow stack, a leaf function's
  published through `vm.native_roots_ptr`, `clif.rs:845-875`) needs no
  walk, but `Vm::collect` still runs it, because `framewalk.rs` is gated on
  the architecture while `clif.rs:649` decides stack maps by ISA: the
  three gates the code says "must agree" (`clif.rs:641-648`) disagree in
  effect on Windows, and the walk faults on garbage (a segmentation
  violation on real Windows, a hang in Wine's crash handling). Two fixes:
  (a) the fallback plan with no walk on Windows -- the smallest change,
  verified under GC stress under Wine (E5(e)) and on real Windows with
  both toolchains (E13c, E14c); it costs the shadow stack's pushes and
  a depth reservation per call, the configuration every host without
  native stack maps has; (b) keep native-frame roots and find the first
  Botlish frame without walking Rust frames: either unwind Rust frames
  with `RtlLookupFunctionEntry`/`RtlVirtualUnwind` (their `.pdata` exists),
  or record the Botlish frame pointer at the transition into a helper that
  can collect. Cranelift's own frames always chain through RBP.
- **B3. Stack probes are off on Windows** (`codegen/mod.rs:158-161`) [C].
  Windows commits a thread's stack one guard page at a time; a Cranelift
  frame larger than a page that skips the guard page faults instead of
  growing the stack. Probes must be on for Windows whether or not the
  overflow guard exists (the probe patch does this).
- **B4. No unwind information for Botlish code** (E9). cranelift-object
  writes none for COFF and the JIT registers none. Debuggers, profilers,
  ETW and `RtlVirtualUnwind` treat Botlish frames as leaf functions. Rust
  panics cannot cross them (helpers are `extern "C"` and abort), so it is
  not a correctness problem today; Cranelift can produce
  `UnwindInfo::WindowsX64`, which Botlish would write as `.pdata`/`.xdata`
  into the object and pass to `RtlAddFunctionTable` for the JIT. Fix (b)
  of B2 through `RtlVirtualUnwind` would need it.
- **B5. The stack-overflow guard.** `runtime/platform/` is signals,
  `sigaltstack` and pthread bounds. The Windows guard is a vectored
  exception handler for `EXCEPTION_STACK_OVERFLOW` and access violations
  in the published stack's guard region, `SetThreadStackGuarantee` for
  the handler's room, `GetCurrentThreadStackLimits` for bounds, the report
  through a HANDLE. Until then a native stack exhaustion kills the process
  without the `NATIVE LIMIT STACK` line.
- **B6. Coroutines.** The switch (`coroutine.rs:293-337`) is SysV
  (`rdi`/`rsi`, no `rsi`/`rdi`/`xmm6-15` saves) with ELF directives; a
  Win64 switch must also swap the TIB's stack fields (`StackBase`,
  `StackLimit`, `DeallocationStack`), and the stacks come from
  `VirtualAlloc` with a guard page. Refused cleanly today.
- **B7. argv.** ARGV.md's snapshot is raw bytes with an `argv[0]`, and
  says so: "Linux only: no Windows UTF-16 argv" (ARGV.md:428). Windows has
  one UTF-16 command line. The port needs a stated policy
  (WTF-8 bytes of the parsed arguments is the natural one) and `raw_arg`
  for the driver's linked runs.
- **B8. `.exe` names** in `main.tcl -emit-native-executable`, the driver's
  outputs, the linked run, `single/` and the tests' `file rootname`s.
  MinGW's gcc appends `.exe` to the link output and the driver then cannot
  find it (E14a); `link.exe` does not (E13a).
- **B9. Platform IO.** There is no Windows `std::io::IO`: a program cannot
  print on Windows. A `win32` (or `windows`) platform namespace designated
  in `core/cabi.tcl`'s `platforms`, over kernel32 (`GetStdHandle`,
  `WriteFile`/`WriteConsoleW`), is the Windows counterpart of
  `std::linux::io` -- a direct module, like `linux`.
- **B10. One Windows target per driver.** `same_target` ignores the
  environment (E2, E10), and the driver calls whatever `rustc` is first on
  `PATH`. Whichever toolchain is chosen, the driver should refuse a
  program built for the other Windows row and pass its own triple to
  rustc. The test `tm-c-call-conv-of-each-target` would fail on a Windows
  host as it stands.
- **B11. The test harness.** Windows rows in the capability tables,
  `native-status.tcl` and `aot-facts.tcl`; PE in `binary-header.tcl`; the
  `c-bindgen.test:468`, `application-modules.test:281` and `x86_64Host`
  bugs; `tests/golden/run.tcl` keeping native backends where coroutines do
  not run. On Windows (E13, E14): `ca-affine-coroutines` and
  `ca-native-code` need capability constraints (`nativeCoroutines`,
  `nativeStackGuard`), `tm-c-call-conv-of-each-target` fails by B10, and
  `cf-missing-library` by the MSVC linker's unrecognized words.
- **B12. Line endings and encodings.** No `.gitattributes` (the CI
  checkout used no CRLF conversion; a developer's may). Tcl 9.0.1's
  `encoding system` on Windows is `utf-8` [V: E13, E14]; console output
  of a native program under `-output inherit` is untested (Windows' own
  console code page).

## 9. Decision

**Switch the Windows native toolchain to MSVC now.** Concretely: the
Windows port builds `botlish-native` and `libbotlish_native.rlib` for
`x86_64-pc-windows-msvc`, links executables through rustc with `link.exe`
(`LinkerFlavor::Msvc`), and treats `windows-x86_64` as the one native
Windows x86-64 target. MinGW is not maintained as a second native path.

The reasons, by the decision criterion (lowest expected architectural cost
over the next milestones):

1. **The transition is modest because the object model is already
   MSVC-ready.** The object is byte-identical for both toolchains (E6),
   the foreign calls are correct Win64 calls against MSVC-ABI code (E8,
   E13), `link.exe` links it unchanged, the MSVC-linked executables pass
   every probe check that does not depend on the GC (E13), and the MSVC
   difference is one link-plan flavor plus rustc's own discovery (section
   5). There is no Botlish assembler, linker or CRT code to port.
2. **Everything else costs the same either way.** B1-B12 are
   toolchain-neutral (both Rust Windows targets share LLVM's Win64 frame
   lowering, E5'), so MinGW buys no head start on the hard work.
3. **Staying on MinGW would create debt in the places that last.** The
   front end, the harness's capability constraints and `windows-aarch64`
   already say MSVC; a MinGW native path either changes the host default
   to `-gnu` (and later back) or needs `-target windows-x86_64-gnu`
   everywhere. MinGW's `x86_64-pc-windows-gnu` links the legacy
   `msvcrt.dll` (E7) while the MinGW ecosystem itself has moved to the
   UCRT (MSYS2's default environment), so C libraries from the MinGW world
   bring a CRT mismatch risk [L]. Plain C interoperates both ways -- DLLs,
   import libraries and static libraries of either toolchain link with
   either linker (E13a, E14b) -- but Windows libraries are mostly built
   with MSVC, and a static one that uses the MSVC CRT (security cookies,
   CRT functions) needs that CRT, which a MinGW link does not have [L].
   And every generated binding would stay MinGW's, when the stated goal
   is the Windows SDK as the authority.
4. **MSVC is Rust's and Windows' default.** rustup installs the MSVC host
   on Windows, GitHub's Windows images carry Visual Studio, and debugging
   (PDBs for the runtime, WinDbg/Visual Studio) is the platform's own. The
   runtime's Rust frames get PDBs; Cranelift frames have neither debug
   nor unwind information under either toolchain (B4).
5. **The cost of switching is real but confined to bindgen and setup.**
   Developers need the Visual Studio Build Tools and the Windows SDK
   (what rustup's MSVC host already asks for); generating SDK bindings
   needs SDK headers, so that generation moves to Windows CI (section 7).
   Neither touches the native milestones.
6. **ARM64 points the same way.** core/cabi.tcl's `windows-aarch64` is
   an MSVC triple already; Rust's Windows ARM64 hosts are MSVC's (and
   `gnullvm`'s), and GCC's own `aarch64-w64-mingw32` support is recent
   [L]. A MinGW native path would have to be replaced there anyway.

**What MinGW keeps: a development aid, not a backend.** The Windows work
ahead (section 8) is machine code and Win32 calls that are the same for
both Rust Windows targets (E5', E6). A `-gnu` cross build run under Wine
is therefore a faithful, fast loop for it on a Linux machine -- this
census's E2-E10 are that loop -- where an MSVC build needs a Windows
runner (or the user's acceptance of Microsoft's license terms for a
downloaded CRT and SDK, as `cargo xwin` asks). It costs nothing as long as
Windows runtime code is gated on `target_os = "windows"` and only the link
seam (`LinkerFlavor`, `EXECUTABLES`, `C_CALLS`) on `target_env`; it is not
a supported target, never shipped, and CI's authority is the MSVC job.

**Not a hybrid, but a precise split.** The architecture already separates
the concerns this census was asked about: code generation (Cranelift),
object writing (`object`, COFF), linking (rustc → the platform linker),
CRT and entry (rustc's target), C headers (clang, any target). MSVC is
chosen for the last three for the native path; clang remains the header
tool for every target, MSVC's included. `lld-link` stays an option behind
rustc (`-C linker=lld-link`) and needs no Botlish code (E9 shows LLVM's
COFF linker takes the object).

**What would have changed the recommendation:**

- `link.exe` rejecting Cranelift's COFF (the `.refptr` sections, a
  relocation) so that the MSVC path needed object-writer work. E13 settles
  it: `link.exe` takes the object unchanged.
- rustc needing a Developer Command Prompt or Botlish-side SDK discovery
  to link. E13 links in a plain shell.
- The native milestones needing GNU-only machinery: DWARF unwinding,
  libgcc helpers, GNU assembler syntax beyond `global_asm!`.
- The generator being unable to read SDK headers without a new C parser
  (the needs in section 7 are configuration and two keywords).
- MinGW-built static libraries being the C ecosystem Botlish must link
  first (then GNU ld's tolerance would matter more than link.exe's).
- Linux-hosted development being the port's only practical loop *and* the
  `-gnu`-under-Wine aid above not being faithful to MSVC builds (it is,
  for everything above the link: E6, E5').

## 10. Recommended next vertical slice

**WINDOWS-X86-64-MILESTONE-1: the native driver on Windows x86-64
(MSVC), GC-correct, with executables.** A Botlish program runs on
`-backend cranelift` and as a standalone `.exe` on a real Windows host,
under GC stress, with CI.

In scope:

- `native/src/main.rs`, `codegen/aot.rs`: the build blockers (B1); the
  Windows argv policy (B7, ARGV.md updated); `.exe` outputs (B8); the
  `Msvc` link flavor and its `LNKnnnn` diagnostics; `--target` to rustc
  and refusal of the other Windows row (B10); `EXECUTABLES` for
  windows-msvc x86-64; the static CRT for executables.
- `codegen/mod.rs`: probes on Windows (B3).
- `codegen/clif.rs`, `codegen/roots.rs`, `runtime/framewalk.rs`: GC roots
  by fix (a) of B2 -- no native stack maps on Windows, and the frame walk
  gated on the same capability as the stack maps rather than on the
  architecture (one predicate for `clif.rs:649`, `roots.rs:846` and
  `framewalk.rs`), the smallest correct change (E5(e), E13c, E14c); fix
  (b) is a later milestone with B4.
- `core/cabi.tcl`, `codegen/target.rs`: `windows-x86_64` as the native
  Windows target; `-gnu` stays a bindgen-only row.
- Tests: Windows rows in `tests/helpers.tcl`'s `executableAot` (not
  `nativeCoroutines`, `nativeStackGuard`, `nativeCCalls` yet),
  `native-status.tcl`, `binary-header.tcl` (PE); the three harness bugs of
  B11; a Windows CI workflow grown from `windows-probe.yml` into a smoke
  tier (Tcl 9.0.1 built from source, the driver, the native unit tests,
  `tier.tcl`-style items, GC stress).

Out of scope: C calls (`C_CALLS`) and platform IO, the overflow guard
(B5), coroutines (B6), unwind info (B4), bindgen for the SDK, the single
executable, ARM64. No `.cargo/config.toml` entry for Windows: fix (a) walks
no frame, and Win64 frame pointers would not make Rust frames walkable
anyway (E5').

Validation target: on `windows-2025`, `cargo test --lib --bins` passes
(the ELF relocation test gated), `probe.tcl`'s pure, allocation-heavy and
GC-stress checks pass on `cranelift` and `cranelift-generic`, an
executable of `examples/games/2048/bench.bot` runs and matches Linux,
and a native stack exhaustion fails as a process crash, recorded as the
known gap (B5). On Linux and macOS: no change (their tests and the GC
stress job).

The milestones after it, in the order the census suggests:

2. **C calls and Windows platform IO** -- `C_CALLS` for windows-msvc (E13
   already passes the probe), a Win64 model in `c-ffi.test` and a fixture
   without ELF assembly, and a Windows platform namespace designated in
   `core/cabi.tcl`'s `platforms` whose context implements `std::io::IO` over
   kernel32 (`GetStdHandle`, `WriteFile`/`WriteConsoleW`, hand-written
   declarations as in `win32.bot`): the first Botlish program that prints
   on Windows. IO needs C calls, so the two go together.
3. **The stack guard and native-frame roots** -- a vectored-exception
   guard reporting `NATIVE LIMIT STACK` (B5), and `.pdata`/`.xdata` for
   Cranelift code (B4) so that GC roots can live in native frames again,
   found by `RtlVirtualUnwind` (fix (b) of B2): Linux's performance and
   debuggability.
4. **Coroutines on Win64** (B6).
5. **Bindgen for the Windows SDK** (section 7) on a Windows runner, the
   Win32 binding regenerated for `windows-x86_64`; the `-gnu` binding
   retired or kept as evidence.

## 11. Reproducing

The probe patch's switches (all Windows-only, all opt-in):

| variable | effect |
|---|---|
| `BOTLISH_PROBE_SHADOW=1` | no native stack maps: the fallback root plan (E5(b)) |
| `BOTLISH_PROBE_NO_WALK=1` | no frame walk in `Vm::collect`; with the above, fix (a) of B2 (E5(e), E13c, E14c) |
| `BOTLISH_PROBE_ALL_SHADOW=1` | every root on the shadow stack, leaf functions' too, and no walk (E5(d), E13b-c, E14b-c) |
| `BOTLISH_PROBE_CRT_STATIC=1` | the startup crate links the C runtime statically (E13b) |
| `BOTLISH_PROBE_KEEP_LINK=DIR` | copy the link inputs (object, startup crate, link plan) to DIR and stop before rustc (E7-E10 under Wine) |

`audit/windows-toolchain/tools/make-patch.py COPY` makes the same edits
in a scratch copy, for regenerating the patch after the code it touches
changes.

On Linux x86-64, with the repository's toolchain plus
`gcc-mingw-w64-x86-64`, `mingw-w64-x86-64-dev`, `wine64`, clang and lld:

```sh
rustup target add x86_64-pc-windows-gnu x86_64-pc-windows-msvc
# E1: the unpatched crate (identical errors for both)
for t in x86_64-pc-windows-gnu x86_64-pc-windows-msvc; do
  CARGO_TARGET_DIR=/tmp/w cargo check --release --manifest-path native/Cargo.toml --target $t --all-targets
done
# E2-E10: a scratch copy (never this checkout) with the probe patch, built for -gnu
mkdir -p "$SCRATCH" && cp -r native "$SCRATCH"/ && rm -rf "$SCRATCH"/native/target
(cd "$SCRATCH" && patch -p1 < "$REPO"/audit/windows-toolchain/probe.patch)
CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER=x86_64-w64-mingw32-gcc \
CARGO_TARGET_X86_64_PC_WINDOWS_GNU_RUSTFLAGS="-C force-frame-pointers=yes" \
  cargo build --release --manifest-path "$SCRATCH"/native/Cargo.toml --target x86_64-pc-windows-gnu
R="$SCRATCH"/native/target/x86_64-pc-windows-gnu/release
wine "$R"/botlish-native.exe run FILE.nir                               # E3
BOTLISH_NATIVE_GC_STRESS=1 wine "$R"/botlish-native.exe run FILE.nir    # E5(a)
wine "$R"/botlish-native.exe object OUT.obj FILE.nir                     # E6
# E7-E10: the driver's link inputs, linked by this host's rustc
BOTLISH_PROBE_KEEP_LINK=DIR wine "$R"/botlish-native.exe executable DIR/x FILE.nir
(cd DIR && rustc --target x86_64-pc-windows-gnu -C linker=x86_64-w64-mingw32-gcc \
   --edition=2024 --crate-name=botlish_program -C opt-level=2 -C force-frame-pointers=yes \
   -C relocation-model=pic --extern botlish_native="$R"/libbotlish_native.rlib \
   -L dependency="$R"/deps -C link-arg=program.obj $(cat link-plan.txt) \
   [-C link-arg=-LLIBDIR] startup.rs -o prog.exe && wine prog.exe)
```

NIR for a program: `native::nir` (native/native.tcl) of its HIR, or
`main.tcl -emit-nir [-target T] FILE.bot`, which prints it before running
the program. The checks of section 6.1 are
`tclsh audit/windows-toolchain/tools/probe.tcl -out DIR -lib NAME=LIBDIR
...` on any host with the patched driver built (the Linux control needs no
patch). `.github/workflows/windows-probe.yml` runs them on real Windows on
every push that changes it or `audit/windows-toolchain/`; once it is on
the default branch, also on demand (`workflow_dispatch`) for any branch.

## 12. Files

```text
docs/WINDOWS-TOOLCHAIN-CENSUS.md            this report
audit/windows-toolchain/probe.patch         the probe's driver patch (never applied to production)
audit/windows-toolchain/tools/make-patch.py the edits behind it, for regenerating it
audit/windows-toolchain/tools/probe.tcl     the probe: main.tcl and the driver, on Linux or Windows
audit/windows-toolchain/programs/fib.bot        a pure program
audit/windows-toolchain/programs/ffi-probe.bot  the C ABI program
audit/windows-toolchain/programs/bwp.c          its C library
audit/windows-toolchain/programs/win32.bot      Win32 console output from kernel32
.github/workflows/windows-probe.yml         the real-Windows probe (msvc and gnu jobs)
```
