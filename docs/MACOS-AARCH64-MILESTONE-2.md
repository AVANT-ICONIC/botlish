# MACOS-AARCH64-MILESTONE-2.md

Milestone 2 of the macOS Apple Silicon port: the compilation target as an
identity. Target identity and host defaults, macOS C ABI facts, the Apple
AArch64 C calling convention of foreign calls, platform module resolution,
HIR interchange compatibility, cache isolation and native host/target
validation. Developed on Linux; every macOS fact below was observed on
GitHub's `macos-15` arm64 runners through `.github/workflows/macos-arm64.yml`
(the shared Apple Silicon development machine was not used). The audit it
updates is MACOS-AARCH64-PORT-AUDIT.md; milestone 1 is
MACOS-AARCH64-MILESTONE-1.md.

> Make the target boundary exact before extending the platform boundary.
> Linux AArch64 and macOS AArch64 share an instruction set, not an operating
> system or an identical C ABI.

## Result

- **A target is an operating system and an architecture, everywhere.** The
  target table names each target's triple (`macos-aarch64` is
  `aarch64-apple-darwin`). A build records the target it depended on in the
  HIR. Interchange, the cache and the native driver refuse to take one
  target's HIR or NIR for another's, however much the two share.
- **Linux platform modules no longer resolve for macOS.** `import linux::sys`
  for `macos-aarch64` is `UNSUPPORTED-PLATFORM` at the import, where it used
  to load `lib/linux/sys.aarch64.bot`. Portable architecture-specific
  namespaces still work on macOS.
- **Foreign C signatures select the target triple's C convention
  explicitly:** `apple_aarch64` on the macOS runner, observed in CLIF.
- **Apple clang agrees with the compiler's `macos-aarch64` facts,** scalar
  by scalar, signed plain `char` and 64-bit `size_t` included. Its own
  target (`arm64-apple-darwin24.6.0`) is the host default's operating
  system and architecture.
- **The macOS JIT still runs ordinary programs.** Every capability milestone
  1 recorded is unchanged except the Linux import, which is now refused at
  compile time.
- **Linux behaves as before.** Every Linux target resolves, compiles and
  runs as it did. The tests that compiled Linux programs now say so
  (`linuxTarget`: the host's own target on Linux).
- **Tests and mutants.** A focused test file of 24 tests, and a mutation
  harness of 17 mutants: all killed.

## 1. Initial target-model findings

What the code did at a97b070, the branch's base:

- **The table** (core/cabi.tcl) already keyed targets by OS and
  architecture and had a correct `macos-aarch64` row, but no row named its
  triple. No row's `os` was read by any code but `hostTarget`, which mapped
  Darwin/arm64 to `macos-aarch64` correctly.
- **Module selection.** surface/modules.tcl chose an architecture-specific
  module by the target's architecture only, "never by operating system".
  So `linux::sys` resolved for `macos-aarch64` (and `windows-x86_64`) to
  Linux's file.
- **The HIR recorded no target.** The C scalars carried their target in
  their declarations, but a program importing `linux::sys` carried no trace
  of the architecture that chose it.
- **Interchange.** A `.hirx` decoded under any target. main.tcl ignored
  `-target` for a `.hirx`.
- **The cache key held the full target name already;** a hit was not
  checked against it.
- **Native execution.** Nothing compared a HIR's target with the host. A
  `-target windows-x86_64` program ran natively on Linux with a 32-bit
  `long`, and a `macos-x86_64` one on Linux x86-64. The driver built its ISA
  from the host triple, so foreign calls used the host's convention
  implicitly (`module.make_signature()`).
- **A host outside the table** importing `ffi::c` got a raw `core::cabi:
  unknown C ABI target ""` error: the declarations were made before the
  UNKNOWN-TARGET check.
- **Tests inferred plain char's signedness from the architecture alone:**
  tests/c-ffi.test's `cf-scalar-transport` and the C FFI fuzzer's model
  (unsigned on any `arm64`, which is wrong on macOS).

Before and after, on Linux x86-64 with the same probes (the base worktree
sharing this checkout's driver):

| Probe | a97b070 | this milestone |
|---|---|---|
| `import linux::sys` compiled for macos-aarch64 | compiles, loads `sys.aarch64.bot` | `UNSUPPORTED-PLATFORM`: `namespace "linux::sys" belongs to the Linux platform ..., which is unavailable for target macos-aarch64 (macOS on aarch64) ...` |
| a linux-aarch64 `.hirx` with plain char, decoded as a macos-aarch64 compilation | accepted: `ffi::c::Char` is `interval 0 255` under "macOS" | `HIR INTERCHANGE TARGET`: `it was built for target linux-aarch64, not macos-aarch64 ...` |
| a macos-x86_64 program run natively on Linux x86-64 | runs (value 1) | `NATIVE TARGET`: `... this host is x86_64-unknown-linux-gnu. Both are x86_64, but a matching architecture is not a matching target ...` |
| a windows-x86_64 program (32-bit `long`) run natively on Linux | runs (2147483647) | `NATIVE TARGET` |
| `import ffi::c` on a riscv64 host | raw `core::cabi: unknown C ABI target ""` (error code NONE) | `UNKNOWN-TARGET`: `namespace "ffi::c" needs a C ABI target ... compile with -target` |

On the macOS runner, milestone 1's probe of examples/io/hello.bot compiled
and failed at run time with `linux::abi::aarch64::syscall needs a Linux
AArch64 target (NATIVE UNSUPPORTED value)`. Now the same program
(native-status's `linux-syscall` probe) is refused at compile time:
`<input>:4:8: namespace "linux" belongs to the Linux platform ...
(SURFACE MODULE UNSUPPORTED-PLATFORM)`.

## 2. Changes by file and subsystem

| Subsystem | Files | Change |
|---|---|---|
| Target table | core/cabi.tcl | `triple` in every row; `systems` (OS display names); `platforms` (the designated platform namespace trees: `linux`); `operatingSystems`, `systemName`, `platformOf`, `hostArchitecture` (factored out of `hostTarget`), `systemTarget` |
| Module resolution | surface/modules.tcl | `PlatformOf`, `PlatformCheck` in `ResolveModule`; `PlatformTarget` (for tools that run programs of every platform) (after the application-collision check); the loader's `targetRead` (set by an architecture-specific file, a platform namespace, ffi::c); `BuildProgram` stamps the HIR's `target`; UNKNOWN-TARGET for ffi::c checked before its declarations |
| HIR target | hir/cabi.tcl, hir/read.tcl | `HasNamespaceTypes`, `targetOf`, `TargetMismatch`; HIR text's target from its C scalars |
| Interchange | hir/interchange.tcl, main.tcl | `decode`/`readFile -target`; `{HIR INTERCHANGE TARGET}`; main.tcl passes its `-target` (or the host's) for `.hirx` inputs and documents the target rules |
| Cache | surface/cache.tcl | a hit is decoded with `-target`; the header states the target rules |
| Static census | tests/static-compile.test | `UNSUPPORTED-PLATFORM` classified as a header kind (never a static block's rejection) |
| NIR | native/lower.tcl | `target "NAME" triple="TRIPLE"` after the declarations, for a HIR with a target |
| Driver | native/src/nir.rs, main.rs, codegen/target.rs (new), codegen/clif.rs, codegen/mod.rs, Cargo.toml/lock | `Program::target`; `NATIVE TARGET` for `run`, `bench`, `batch`, `object`, `executable`; `c_call_conv` in `c_signature`; `botlish-native target TRIPLE`; `target-lexicon` 0.13 as a direct dependency (the version Cranelift already resolved: one lock line) |
| Native Tcl | native/native.tcl | `native::targetFacts TRIPLE` |
| Tests and tools | tests/target-model.test (new), tests/helpers.tcl, 15 test files, tests/golden/run.tcl, audit/refactor/tools/sweep.tcl (the warning gate), audit/static-decisions/tools/lib.tcl | see section 13 |
| Platform scripts | tests/platform/cabi-facts.{c,tcl}, native-status.tcl | per-scalar facts, `size_t`, the compiler's own target; three target-boundary probes; the macOS `linux-syscall` expectation |
| C FFI oracles | tests/c-ffi.test, audit/c-ffi/tools/fuzz.tcl | plain char unsigned on Linux AArch64 only (OS and architecture) |
| Mutation | audit/target-model/tools/mutate.tcl, mutants.txt (new); audit/hir-interchange/tools/mutants.txt, audit/diagnostic-recovery/tools/mutants.txt | 17 mutants; two existing mutants' texts follow the code they mutate |
| Golden manifest | audit/golden/migration/census/target-model.tsv (new), census/{c-abi-types,linux-syscall-transports}.tsv, tcl-names.txt, tests/golden/manifest.tsv | 24 KEEP-INTERNAL rows; four descriptions refreshed; regenerated with merge.tcl |
| Docs | AGENTS.md ("Compilation targets"), C-ABI-TYPES.md, C-FFI.md, HIR-INTERCHANGE.md, IMPORTS.md, LINUX-SYSCALL-TRANSPORTS.md, tests/golden/README.md, MACOS-AARCH64-PORT-AUDIT.md, INDEX.md, this file | |

## 3. The canonical macOS target

`macos-aarch64` in core/cabi.tcl:

```
macos-aarch64 {os macos arch aarch64 model LP64 charSigned 1 triple aarch64-apple-darwin}
```

That is macOS/Darwin on AArch64, LP64 (`char` 8, `short` 16, `int` 32,
`long` 64, `long long` 64, pointer 64), signed plain `char`, and the
Cranelift triple `aarch64-apple-darwin`. The object format (Mach-O) and the
C ABI (Apple AArch64) are what that triple means to target-lexicon and
Cranelift. The driver reports them (`botlish-native target
aarch64-apple-darwin`: `arch aarch64 os darwin pointer 64 format macho
c-call-conv apple_aarch64`) rather than holding a second, separately
editable copy in the table. No other representation of a target was added:
the triple is the one name the native side receives.

`linux-aarch64` shares `arch`, `model` and `pointer` and differs in `os`,
`charSigned` and `triple` (`tm-macos-aarch64-identity`). The other five rows
are unchanged apart from their triples (`tm-target-table` pins all six,
scalar by scalar).

## 4. Host target detection

`core::cabi::hostTarget` reads the operating system and the architecture
separately (`tm-host-default`):

| tcl_platform os, machine | hostTarget | systemTarget linux |
|---|---|---|
| Darwin, arm64 | macos-aarch64 | linux-aarch64 |
| Linux, aarch64 | linux-aarch64 | linux-aarch64 |
| Linux, x86_64 | linux-x86_64 | linux-x86_64 |
| Darwin, x86_64 | macos-x86_64 | linux-x86_64 |
| Windows NT, amd64 | windows-x86_64 | linux-x86_64 |
| Linux, riscv64 | (none) | (none) |
| FreeBSD, amd64 | (none) | linux-x86_64 |

On the macOS runner (run 39126315234, smoke) three independent sources
agree:

- **Tcl:** `host target: macos-aarch64 (Darwin arm64), triple
  aarch64-apple-darwin`.
- **Apple clang:** `C compiler: cc, target arm64-apple-darwin24.6.0`.
- **The driver:** `format macho c-call-conv apple_aarch64 runs 1` for the
  host row's triple, so target-lexicon's host is `aarch64-apple-darwin`.

An explicit `-target` overrides the host default for every front-end
operation (`tm-default-and-explicit-target`).

## 5. C ABI target facts, before and after

The `macos-aarch64` facts did not change: the row was already right
(milestone 1). What changed is what checks them, and that they now stay with
their target:

| C type | width | signedness | compiler (core::cabi) | Apple clang (macos-15) |
|---|---:|---|---|---|
| char | 8 | signed | `{8 1}` | `{8 1}` |
| signed char | 8 | signed | `{8 1}` | `{8 1}` |
| unsigned char | 8 | unsigned | `{8 0}` | `{8 0}` |
| short / unsigned short | 16 | s / u | `{16 1}` / `{16 0}` | the same |
| int / unsigned int | 32 | s / u | `{32 1}` / `{32 0}` | the same |
| long / unsigned long | 64 | s / u | `{64 1}` / `{64 0}` | the same |
| long long / unsigned long long | 64 | s / u | `{64 1}` / `{64 0}` | the same |
| pointer | 64 | -- | `pointer 64` | 64 |
| size_t | 64 | unsigned | (no ffi::c scalar; the pointer width) | `sizeT 64 sizeTSigned 0` |

The compiler's columns are compiler-owned (the table; `tm-macos-aarch64-scalars`
pins them on any host). Apple clang's are tests/platform/cabi-facts.c,
compiled and run by Apple clang 17.0.0 on the runner: a test oracle, never a
compiler input. On Linux the macOS row is checked by the pinned tests only.
The oracle runs on and checks its own host's row, never another target's,
so the Linux host compiler is never taken for macOS's.

The regression case is plain `char`: `[0, 255]` for linux-aarch64 and
`[-128, 127]` for macos-aarch64. `f(200)` with `f(x: ffi::c::Char)`
compiles for one and is a `TYPE` error for the other, and `f(0 - 1)` the
reverse (`tm-default-and-explicit-target`). `size_t` is deliberately not an
ffi::c scalar (C-ABI-TYPES.md, "What is not here"); the oracle checks that
it is the pointer's width and unsigned.

## 6. Cranelift calling-convention selection

Three kinds of call, three conventions (native/src/codegen/target.rs's
header):

- **Botlish-to-Botlish calls** (`clif::signature_n`): the ISA's default,
  `module.make_signature()`. Internal to one compilation; unchanged.
- **Runtime helper calls** (`rt_*`): the ISA's default, which is the host's
  C convention -- the helpers are Rust `extern "C"` functions for this
  host. Unchanged.
- **Foreign C calls** (`clif::c_signature`): `sig.call_conv =
  c_call_conv(module.isa().triple())`, the triple's platform C convention
  (`CallConv::triple_default`). Before, it was the same value, implicitly,
  through `make_signature()`. Selecting it where the signature is built
  means a future change of the internal default cannot move foreign calls
  with it.

| target triple | `c_call_conv` (Cranelift) |
|---|---|
| aarch64-apple-darwin | **apple_aarch64** |
| aarch64-unknown-linux-gnu | system_v |
| x86_64-unknown-linux-gnu | system_v |
| x86_64-apple-darwin | system_v |
| x86_64-pc-windows-msvc, aarch64-pc-windows-msvc | windows_fastcall |

Checked three ways:

- **The Rust unit tests** (`codegen::target::tests`, every triple of the
  table, and `apple_aarch64_is_not_the_linux_aarch64_convention`).
- **`tm-c-call-conv-of-each-target`**, on any host, through the driver's
  `target` report for each table row.
- **On the macOS runner,** native-status's `c-convention` probe compiles
  `extern c fn labs(x: ffi::c::Long)` and `extern c fn abs(x:
  ffi::c::Char)` to CLIF and reads `labs apple_aarch64 abs apple_aarch64`;
  `tm-foreign-signature-convention` also checks the `(i8 sext) -> i32`
  signature there.

Cranelift owns everything the convention implies: registers, stack
placement, the extension of narrow arguments. Nothing in Botlish spells
them, and no mutant touches them.

No real macOS C call ran: the C FFI's execution on macOS is still refused
(executables are Linux-only, so `run_linked` refuses: native-status's
`c-call` probe, unchanged). The convention is shown correct for the
signatures Cranelift is given, not by a call into Apple's libraries. That is
milestone 7's acceptance.

## 7. Linux module resolution

The rule (surface/modules.tcl, "Platform namespaces"): the target table
designates the standard namespace trees that are an operating system's
platform interface (core/cabi.tcl's `platforms`, read by
`core::cabi::platformOf`): today `linux`, so the `linux` namespace and
everything under it (`linux::sys`, `linux::io`, `linux::path`,
`linux::abi::x86_64`, `linux::abi::aarch64`) are Linux's. It follows the
module layout, which already said "the module's own namespace says which
OS it is for"; nothing was renamed and no module file changed. It is a
designation, not a spelling rule: the first version reserved every
namespace named like an OS of the table, and the macOS acceptance tier
caught a private test library's `windows` module (tests/traits.test's
`trait-future-path-shape`, a Windows-path *example*, failing on Linux
too) -- a stdlib module may be called `windows` for any reason
(`tm-os-named-module-is-no-platform`). A macOS platform module tree
(milestone 9) is designated the same way.

- **A target of another operating system** gets `UNSUPPORTED-PLATFORM` at
  the import -- before any file is chosen, so `linux::sys` never becomes
  `sys.aarch64.bot` for macOS -- naming the platform, the target and the
  remedy (`compile for a Linux target (-target linux-aarch64) or import no
  Linux namespace`). The same holds for `macos-x86_64`, `windows-x86_64`
  and `windows-aarch64` (`tm-linux-platform-refused`, seven import forms,
  `import type` included).
- **A host that is no known target** gets `UNKNOWN-TARGET` at the import
  (`tm-unknown-host`).
- **Linux targets** resolve exactly as before: `sys.aarch64.bot` for
  linux-aarch64, `sys.x86_64.bot` for linux-x86_64
  (`tm-linux-platform-on-linux`, `lst-linux-sys-selected-by-target`).
- **Portable architecture-specific namespaces** are every operating
  system's. `abi::aarch64` and `abi::x86_64` compile and run for
  macos-aarch64 and windows-x86_64, and a private `demo::arch` gives
  macos-aarch64 its AArch64 file and macos-x86_64 its x86-64 file
  (`tm-portable-architecture-namespaces`,
  `tm-architecture-specific-module-on-macos`,
  `lst-arch-module-value-by-target`).
- **Application modules** are the application's whatever their name: an
  application `linux/tool.bot` compiles for macOS
  (`tm-application-module-named-linux`). An application file shadowing a
  standard `linux::*` namespace is still MODULE-COLLISION first, on every
  target.

Nothing maps a Linux import to Darwin libc, and no Darwin syscall transport
or macOS module was added.

## 8. HIRX compatibility

A HIR records its target when its build read one (`hir::cabi::targetOf`).
The loader is the only reader, in exactly three places:

- an architecture-specific module's file (ModuleFile);
- a platform namespace's check (PlatformCheck);
- ffi::c's scalars (NamespaceTypeDecls).

A HIR that read none is every target's: it records "" and is identical for
every target (`tm-hir-records-its-target`). HIR text records the target its
C scalars name (`tm-hir-text-target`).

The interchange format carries the field inside the HIR dict, so no format
version change was needed. The policy is centralized in
`hir::cabi::TargetMismatch`, which `decode -target` applies:

- **Same target:** accepted, keeping its own C facts whatever was compiled
  in between.
- **Another target:** refused, `{HIR INTERCHANGE TARGET}`, in both
  directions -- linux-aarch64 text as macos-aarch64 and the reverse
  (`tm-interchange-cross-os`). A matching architecture or pointer width
  never counts.
- **A HIR that is every target's:** accepted for any target.
- **An unknown host (`-target ""`):** only such a HIR.
- **Without `-target`:** unchecked, as before. The HIR stays its own
  target's, and the native driver still refuses to run it on another
  target's host.

main.tcl reads a `.hirx` as a compilation for its `-target`, or the host's
(`tm-interchange-main`). Nothing is reinterpreted: before, a decoded
linux-aarch64 HIR kept its unsigned char under "macOS"; now that reading is
refused.

## 9. Cache isolation

`surface::cache::Key` already held the resolved full target name (never the
architecture), so each target has its own entry. Two things were added:

- **The defence in depth:** a hit is decoded with `-target`. An entry
  holding another target's HIR, even filed under this compilation's key, is
  an invalid entry (a miss), and the build runs.
- **The tests**, with one shared cache directory and the plain-char program
  (`tm-cache-target-isolation`). The per-compilation
  `{target char-domain hits misses stores invalid}` records are:
  - linux-aarch64, then macos-aarch64, then linux-aarch64 again: `{0 255}`
    miss and store, `{-128 127}` miss and store, then `{0 255}` hit;
  - the reverse order: the mirror image;
  - two entries per directory.

  `tm-cache-entry-of-another-target` plants a linux-aarch64 entry under the
  macOS key and gets the macOS facts with `invalid 1`.

An entry stays per target even for a HIR that is every target's: the key is
computed before the build that would tell, and splitting the key by
target-dependence would be the cache redesign the milestone rules out. Such
entries are equal, so the duplication costs space only. A Linux module's
build for macOS fails and is never stored. The dependencies are unchanged.

Other caches: the loader's AST cache is keyed by path and text (parsing
reads no target). The native build cache (`.github/actions/build-native`)
is keyed by runner OS and architecture and holds no compiled program. The
driver keeps nothing between runs.

## 10. Non-host execution rejection

- **NIR names a target-dependent program's target:** `target
  "macos-aarch64" triple="aarch64-apple-darwin"` (`tm-nir-target-line`). A
  program that is every target's names none and runs anywhere.
- **The driver enforces it itself,** whatever produced the NIR
  (`tm-native-driver-boundary`, hand-written NIR). `run`, `bench`,
  `batch`, `object` and `executable` refuse another target's program with
  `{NATIVE TARGET}` before any code is made, when the architecture or the
  operating system family differs (`codegen::target::same_target`). When
  the architectures match, the message says so: `Both are aarch64, but a
  matching architecture is not a matching target`.
- **Diagnostic commands still work.** `clif`, `vcode`, `size`, `roots`,
  `calls` and `check` show this host's view of any program; existing tests
  read the x86-64 transport's CLIF on arm64 hosts.

Where it applies (`tm-native-refuses-another-target`, `tm-main-native-target`):

- **On Linux:** `native::evalHir`, `-specialize 0`, `native::executable` and
  `native::object` of a macos program are all NATIVE TARGET, and no
  executable or object file is written. The Tcl backends run the same HIR,
  a portable program compiled with `-target macos-*` runs natively, and the
  host's own target runs. main.tcl's `-backend cranelift` and
  `-emit-native-executable` print the refusal.
- **On the macOS runner:** native-status's `other-target` probe refuses a
  linux-aarch64 program (`this program was built for target linux-aarch64
  (aarch64-unknown-linux-gnu) ... Both are aarch64 ...`), while the JIT
  probe and the smoke tier's sample programs run.

The Tcl backends run a program built for any target, as before:
interpreting a program for another target executes no target machine code,
and they refuse C calls and syscalls anyway. That keeps cross-target front
end work possible (and is how the tests run Linux programs on macOS,
section 13).

## 11. macOS GitHub Actions results

| Run | Commit | Jobs | Result |
|---|---|---|---|
| [39126315234](https://github.com/mwagner-webdev/botlish/actions/runs/39126315234) (run 9) | 17e7e94 | smoke, acceptance 1/2 and 2/2, linux control | smoke: success (C ABI facts, native build, 215 Rust unit tests, native status, smoke tier); linux control: success; acceptance: **failure**, 4 tests in 4 files (below), every golden suite passing |

Run 9's acceptance tier failed four tests, each a test of this milestone's
own making that the Linux runs and the simulated macOS host had not shown:

| Test | Shard | Cause | Fix |
|---|---|---|---|
| traits.test `trait-future-path-shape` | 2 | the platform rule then reserved every namespace named like an OS of the table, and the test's private library module is called `windows`: refused on every host, Linux included (traits.test had not been run locally) | the rule became a designation (core/cabi.tcl's `platforms`: `linux`); `tm-os-named-module-is-no-platform` and a mutant pin it (section 7) |
| c-pointer-borrowing.test `cb-namespace-separation` | 2 | compiles examples/linux/write.bot for the host's target; the simulation's 28 other failures of this file hid it among NATIVE TARGET artefacts | compiles it for `linuxTarget` |
| warning-gate.test `warning-gate-passes` | 2 | the warning gate (audit/refactor/tools/gate.tcl, sweep.tcl) compiles the shipped Linux programs and `linux::*` loaders for the host's target | the sweep compiles a program of another OS's platform for that platform's target (`surface::modules::PlatformTarget`): identical findings on Linux and simulated macOS |
| direct-modules.test `dm-tooling-explains` | 1 | runs main.tcl on a Linux program in a child process, which the simulation (an in-process `tcl_platform` override) does not reach | passes `-target [linuxTarget]` |

Shard 1 ran 3740 tests (3600 passed, 139 skipped, 1 failed) and shard 2
3495 (3356, 136, 3), and all 47 golden suites of shard 2 passed on interp
and compile, the 16 Linux-importing ones compiled for linux-aarch64 by
`golden::target`.

The smoke job's evidence (Darwin 24.6.0, `RELEASE_ARM64_VMAP`, `uname -m`
`arm64`):

```
host target:   macos-aarch64 (Darwin arm64), triple aarch64-apple-darwin
C compiler:    cc, target arm64-apple-darwin24.6.0
C toolchain:   char 8 short 16 int 32 long 64 longlong 64 pointer 64 charSigned 1 sizeT 64 sizeTSigned 0 scalars {Char {8 1} SChar {8 1} UChar {8 0} Short {16 1} UShort {16 0} Int {32 1} UInt {32 0} Long {64 1} ULong {64 0} LongLong {64 1} ULongLong {64 0}}
ok: core::cabi's macos-aarch64 row agrees with the C toolchain
native status on macos-aarch64 (Darwin arm64)
ok   jit             value 6765
ok   gc-frame-walk   value str xyxy...
ok   stack-overflow  error NATIVE BUG native backend failed: child killed: SIGABRT  (unchanged: milestone 5)
ok   coroutine       error NATIVE UNSUPPORTED value native coroutines need stack switching ...  (unchanged: milestone 4)
ok   linux-syscall   error SURFACE MODULE UNSUPPORTED-PLATFORM <input>:4:8: namespace "linux" belongs to the Linux platform ...
ok   c-call          error NATIVE LINK executable emission requires Linux glibc on x86_64 or aarch64  (unchanged: milestone 6/7)
ok   executable      error NATIVE AOT executable emission requires Linux glibc on x86_64 or aarch64  (unchanged: milestone 6)
ok   target          value format macho c-call-conv apple_aarch64 runs 1
ok   c-convention    value labs apple_aarch64 abs apple_aarch64
ok   other-target    error NATIVE TARGET this program was built for target linux-aarch64 (aarch64-unknown-linux-gnu), ...
ok: every native capability behaves as recorded for macos-aarch64
```

## 12. Linux regression results

Locally (Linux x86-64, Tcl 9.0.1, rustc 1.97.0), every file this milestone
touches or that compiles Linux programs, on interp: abi-bytes,
abi-mutable-bytes, abi-numeric, application-modules, contexts,
direct-modules, imports, linux-path, linux-syscall-transports,
linux-syscall, native-program-output, portable-io, static-economics,
c-pointer-borrowing, workload-2048, context-traits, c-ffi, c-abi-types,
hir-cache, hir-interchange, static-compile, surface-modules and
target-model. All 23 files pass; c-ffi skips its 2 BoringSSL tests, as
without the library before. Also green: golden.test (9 of 9); the
traits-path, linux-io and contexts suites on all four backends;
`cargo test --release --lib` (237) and `--bin botlish-native` (38, the 4
new included); tests/platform/native-status.tcl and cabi-facts.tcl;
audit/target-model/tools/mutate.tcl (16 of 16 killed, then 17 of 17 with the
platform-designation mutant); audit/hir-interchange/tools/roundtrip.tcl
`-via interchange` (10 suites, 90 artifacts and outcomes, 0 differ) and
`-via cache` (100, 0 differ); audit/hir-interchange/tools/mutate.tcl (27 of
27 killed, one mutant's text updated for the reordered `decode`);
audit/diagnostic-recovery/tools/mutate.tcl's `module-abort` (its text
updated for BuildProgram, killed); every other mutation harness's mutants
still apply to the files this milestone changed; the warning gate;
c-bindgen.test (22 run, 18 skipped without pinned sources); a seed of the
C FFI fuzzer (4 programs, 48 functions, 0 disagreements). The full suite was
left to CI, which the milestone asks to use for the broad regression.

GitHub Actions: PENDING.

## 13. Test and oracle discrepancies

- **Tests that ran a cross-target program natively** now expect the
  refusal, which is the point of the milestone:
  - `ca-target-interchange` runs its windows-aarch64 HIR on the Tcl
    backends and expects NATIVE TARGET from the native ones;
  - `lst-portable-write-other-target` expects NATIVE TARGET where it
    expected the run-time NATIVE UNSUPPORTED;
  - `lst-arch-module-value-by-target` runs each target's program on the
    backends that run it here, and adds macos-aarch64 and windows-x86_64;
  - `lst-linux-sys-selected-by-target` expects UNSUPPORTED-PLATFORM for
    macos-aarch64 and windows-x86_64 where it pinned
    `linux/sys.aarch64.bot` and `linux/sys.x86_64.bot`.

  On Linux each still asserts everything it did, and more.
- **Tests that compile Linux programs.** On a host whose default target is
  not Linux, about 95 tests in 11 acceptance files and 16 golden suites
  would have been refused, found by running them under a simulated macOS
  host (`tcl_platform`) on Linux before pushing. They compile Linux programs
  for `linuxTarget` (tests/helpers.tcl, `core::cabi::systemTarget linux`):
  the host's own target on Linux, so Linux runs are unchanged, and
  linux-aarch64 on macOS. They run them on `backendsFor` the HIR's target
  (the Tcl backends on macOS). The golden runner does the same for a suite
  whose header imports a Linux namespace (`golden::target`), excluding its
  native backends with the reason. The test that checks a Linux program's
  native replay of a -strict 0 contract now carries `nativeLinux`. No test
  was weakened, skipped by OS or added to `notYet`.
- **The plain-char oracles** of c-ffi.test and the C FFI fuzzer now read the
  OS and the architecture (unsigned on Linux AArch64 only). The fuzzer keeps
  its own model, independent of the registry, as its header requires; both
  run on macOS only once C calls do.
- **The simulation's limit.** A simulated macOS host on Linux still runs the
  Linux driver, so it cannot show a macOS program running natively; four
  target-model tests and 28 c-pointer-borrowing tests "fail" there for
  that reason alone (NATIVE TARGET, with the Tcl backends agreeing). A child
  process does not inherit the override either. Run 9 showed what it hid
  (section 11); only the macOS runner is evidence.
- **One equivalent mutant left out.** Removing the explicit `sig.call_conv =
  c_call_conv(...)` line changes no behaviour on any host Cranelift
  supports, because the ISA default equals the triple's C convention. The
  line exists so that it stays so if the internal convention ever changes.
  No test can observe it today, so no mutant claims to.

## 14. Remaining target-related limitations

- **No real macOS C call has run.** C FFI execution, linking with Apple ld,
  Mach-O symbol prefixes at link time and stack-passed or narrow arguments
  against Apple clang callees are milestones 6 and 7.
- **Diagnostic commands use the host ISA.** `native::clif`, `vcode`, `size`
  and `roots` of a program built for another target show the host's code
  (by design: tests read the x86-64 transport's CLIF on arm64). They are not
  a cross-compiler.
- **Per-target cache entries** for programs every target shares (section 9).
- **The Tcl backends run any target's program** (section 10).
- **Platforms are read from namespaces** of the operating systems of the
  table. A future macOS standard namespace (`macos::*`, milestone 9) is
  macOS's by the same rule, with no code change.
- **Unchanged and still explicit:** native coroutines (milestone 4), the
  native stack overflow crash (5), executables (6), C calls (7), Darwin
  system APIs (9).

## 15. Next milestone prerequisites

Milestone 3 (pure Cranelift codegen and native JIT, MACOS-AARCH64-PORT-AUDIT.md
section 17) can rely on:

- **Linux programs are refused for macOS,** and every macOS native test
  harness sees either a macOS program or an explicit refusal.
  `tests/helpers.tcl`'s `linuxTarget`/`backendsFor` and run.tcl's
  `golden::target` are the way to run Linux programs' front-end tests
  there.
- **Native code is made only for the host's target.** A JIT or codegen
  change on macOS never runs Linux-built NIR.
- **Foreign signatures are already in Apple's convention on macOS**
  (milestone 7 then tests real calls).
- **native-status.tcl's `target`, `c-convention` and `other-target` probes**
  will catch a regression of the boundary on both hosts.

Before merging: the macOS acceptance tier, a Tier C census and the Linux
workflows on the branch (section 11, 12).
