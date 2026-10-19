# MACOS-AARCH64-MILESTONE-5.md

Milestone 5 of the macOS Apple Silicon port: Mach-O AOT executables, native
linking and standalone runtime acceptance on `macos-aarch64`. Developed on
Linux; every macOS fact below was observed on GitHub's `macos-15` arm64
runners through `.github/workflows/macos-arm64.yml` (the shared Apple
Silicon development machine was not used). The audit it updates is
MACOS-AARCH64-PORT-AUDIT.md (sections 1, 3-5, 11, 15-17; its roadmap calls
this milestone entry 6); the milestones before it are
MACOS-AARCH64-MILESTONE-1.md to -4.md.

> Port the executable boundary, not the toolchain.

## Result

An ordinary Botlish program becomes a standalone ARM64 Mach-O executable on
macOS through the path Linux already had:

```text
Botlish -> HIR -> NIR -> Cranelift -> Mach-O object -> rustc -> cc -> Apple ld -> Mach-O executable
```

**Before** (Gate A, run
[39321178300](https://github.com/mwagner-webdev/botlish/actions/runs/39321178300),
the branch's first push): `-emit-native-executable` was refused on macOS,
`executable emission requires Linux glibc on x86_64 or aarch64 (NATIVE
AOT)`, although the program object Cranelift wrote there was already a
valid Mach-O arm64 object (section 4).

**After** (every run from
[39322480804](https://github.com/mwagner-webdev/botlish/actions/runs/39322480804)
on): the same program links in 0.4 s into a `Mach-O 64-bit executable
arm64` -- PIE, signed ad hoc by the linker, loading only
`/usr/lib/libSystem.B.dylib` and `/usr/lib/libiconv.2.dylib` -- that prints
its value when moved out of its build directory, its source deleted and its
environment empty (section 9). Its stack overflow, of the thread's stack or
a coroutine's, is the established line on standard error and exit status 1
(section 13):

```text
$ ./overflow; echo "exit $?"
error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}
exit 1
```

What changed in the compiler is one gate (`codegen/aot.rs`'s `EXECUTABLES`)
and one explicit capability distinction (`C_CALLS`: a program that calls C
is still refused on macOS, NATIVE LINK, before the linker runs). Nothing
else in the link is Mach-O code of ours: Cranelift and the object crate
write the Mach-O object, rustc drives Apple clang and Apple's ld with the
arguments it already had, and the linker signs the executable. The rest of
the milestone is evidence: the executable tests of 38 test files now run on
macOS (one capability, `executableAot`, defined once), new tests of formats,
paths, linker diagnostics, coroutines and stack overflows in executables, a
multi-file application and the 2048 workload as moved executables, a
host-tools check of the object and the executable
(`tests/platform/aot-facts.tcl`), the native status, and a mutation
campaign.

Gates, all on GitHub Actions runners (no shared Mac):

| Gate | What | Evidence |
|---|---|---|
| A | baseline: the refusal, the JIT working | run 39321178300 (section 1) |
| B | a valid Mach-O arm64 object | the same run's `aot-facts.tcl` (section 4) |
| C | a minimal executable links and runs | run 39322480804's smoke (sections 7-10) |
| D | calls, branches, allocation, errors, coroutines, independence from the working directory | the executable test files in the acceptance tier (section 11) |
| E | GC, coroutine roots, deep recursion, NATIVE LIMIT STACK | sections 11-14 |
| F | CLI and driver: paths, targets, diagnostics, temporary files | sections 15-16 |
| G | applications and regressions | sections 17-19, 22-24 |

## 1. Initial AOT refusal and baseline evidence

Gate A: the branch's first push (45f6b47) added `tests/platform/aot-facts.tcl`
to the smoke and Linux control jobs, against the unchanged backend. On the
macOS runner (run 39321178300, smoke job
[118295331844](https://github.com/mwagner-webdev/botlish/actions/runs/39321178300/job/118295331844)):

- native-status: `jit` 6765, `coroutine` `[10, 7]`, both stack overflows
  `NATIVE LIMIT STACK` (the JIT works, as milestones 3 and 4 left it);
  `executable` `error {NATIVE AOT} {executable emission requires Linux
  glibc on x86_64 or aarch64}`; `c-call` `NATIVE LINK` with the same text.
- aot-facts: every object check passed (section 4); `executable-link`
  failed with the same refusal -- the one failing check, as it had to.
- The Linux control job (ubuntu x86-64) passed every check of the same
  script, executables included.

## 2. The Linux AOT architecture this milestone started from

Audited at 50db729, the branch's base. The path from `main.tcl
-emit-native-executable FILE.bot` to a running executable:

| # | Step | Where | Class |
|---|---|---|---|
| 1 | CLI: `-emit-native-executable` sets `showNative executable`; `emitExecutable` reads `.bot` (front end), `.hir` or `.hirx` (for `-target` or the host's) and calls `native::executable HIR ROOTNAME` | main.tcl | portable |
| 2 | Readiness (every used instance closed, `-specialize 1`), then native lowering to NIR text | native/native.tcl `native::executable`, native/lower.tcl | portable |
| 3 | The driver run: the NIR written to a `file tempfile`, `botlish-native executable OUT FILE.nir`; its result line `executable OUT` or `error CODE MESSAGE` | native.tcl `RunDriver`, native/src/main.rs `cli` | portable |
| 4 | Target selection: NIR's `target "NAME" triple=` checked against `Triple::host()` (NATIVE TARGET), before any code is made | codegen/target.rs `check_host` | portable (milestone 2) |
| 5 | The ISA: `cranelift_native::builder_with_options(!pic)` -- the host triple; for the object (`pic`) no host CPU features are inferred (the target's baseline); `is_pic`, `opt_level=speed`, inline stack probes where the guard exists | codegen/mod.rs `isa` | owned by Cranelift (arch from the triple) |
| 6 | `cranelift_object::ObjectBuilder` over that ISA: the object format from the triple (ELF, Mach-O), `MH_SUBSECTIONS_VIA_SYMBOLS`, `LC_BUILD_VERSION` for an Apple triple | codegen/mod.rs `emit_object`; cranelift-object | owned |
| 7 | Serialization: `module.finish().emit()` | the same | owned |
| 8 | Relocations: Cranelift's; then `relax_context_got`, which rewrites an x86-64 ELF `R_X86_64_GOTPCREL` of the context area to `REX_GOTPCRELX` and returns early for anything that is not ELF64 | codegen/mod.rs | ELF + x86-64 only |
| 9 | Runtime and helper symbols: every `rt_*` helper declared `Linkage::Import`; C functions `Import` with the C convention; the context area a `Local` data object; direct helper calls only on x64 | codegen/clif.rs `declare` | portable (the object crate decorates names) |
| 10 | Entry symbols: `botlish_fn_N` (direct entry) and `botlish_entry_N` (generic entry), `Linkage::Export` | the same | portable |
| 11 | Runtime library: `libbotlish_native.rlib` and `deps/` beside the driver | native/Cargo.toml, `link_rustc` | portable |
| 12 | Linker: rustc compiles the generated startup crate (`startup`: the program's function, native, shape and enum metadata, constants, stack maps) against the rlib, `-C link-arg=program.o`; rustc runs the platform's C compiler driver as linker | codegen/aot.rs `link_rustc` | system-linker responsibility |
| 13 | Linker arguments: `--edition=2024 -C opt-level=2 -C force-frame-pointers=yes -C relocation-model=pic --extern botlish_native=RLIB -L dependency=DEPS -C link-arg=OBJ`; for a program that calls C, `-C default-linker-libraries=yes`, `-L` dirs and `-Wl,--start-group ... --end-group` | `link_rustc`, `link_plan_args` | portable, but the C link plan is GNU ld's |
| 14 | Temporary files: a `WorkDir` beside the destination (`.botlish-aot-PID-NANOS`), removed on drop | `WorkDir::beside` | portable (same filesystem for the rename) |
| 15 | Permissions: the linker's own (0755 under the usual umask); the stub linker sets 0755 itself | `link_rustc`, `link_stub` | portable |
| 16 | Output path: made absolute; the linked file renamed into place only after a successful link, so a failure leaves an earlier file intact | `link_rustc` | portable |
| 17 | Startup: the generated `main` collects `std::env::args_os`, calls `aot::run`, which spawns the 1 GiB worker thread, builds the Vm, installs the argument snapshot, the stack guard (where it exists), and runs the entry | runtime/aot.rs `run` | runtime-platform-specific only in the guard (shared since milestone 4) |
| 18 | Argument forwarding: the real argument vector, bytes unchanged (ARGV.md) | the same | portable (`std::os::unix`) |
| 19 | Output: the value on standard output, an error on standard error with exit status 1, the guard's line on standard error with exit status 1; the driver protocol (`BOTLISH_NATIVE_RESULT`) for programs the driver runs as executables | the same | portable |
| 20 | Driver error propagation: `NATIVE LINK` for a program that calls C, `NATIVE AOT` otherwise; main.tcl prints it with its Compilerpedia help line | main.rs `cli`, native.tcl `Outcome` | portable |
| -- | The stub linker: an ELF64 x86-64 image builder, x86 trampolines, a Linux loader (`botlish-aot-stub`) | codegen/aot.rs `link_stub`/`image`, runtime/aotimage.rs | ELF + x86-64 + Linux |

So of the twenty steps only three were not already portable: the gate itself
(`emit_executable`'s Linux glibc `cfg!`), the GNU ld link plan of a program
that calls C, and the stub linker. The test assumptions were the per-file
`executableAot` constraints (Linux only) and one `\x7fELF` check.

## 3. Files and subsystems changed

Native backend:

- `native/src/codegen/aot.rs`: `EXECUTABLES` (Linux glibc x86-64 and
  AArch64, macOS AArch64) replaces the Linux-only gate; `C_CALLS` (Linux
  only) refuses a program that calls C on macOS before the linker runs, with
  its own message (section 16); the stub linker's refusal names Linux
  x86-64; the module documentation. No change to `link_rustc`'s arguments,
  the startup crate or the stub linker.
- `native/src/main.rs`, `native/src/runtime/aot.rs`: documentation only (the
  argument vector is glibc's or libSystem's).

Front end and command line: `main.tcl` and `native/native.tcl`, documentation
only.

Tests and tools:

- `tests/helpers.tcl`: `executableAot`, a capability defined once (Linux
  x86-64 and AArch64, macOS AArch64), and `tests/binary-header.tcl`
  (`binaryHeader`, `hostBinaryHeader`: an object's or an executable's
  format, architecture and kind, read from its header).
- 38 test files: their copied Linux-only `executableAot` definitions removed
  (native-view.test and native-edit.test keep theirs, now the capability and
  a built driver); comments that called the executable "an ELF" or the
  argument vector "Linux's".
- `tests/native-executable.test`: the host's format instead of `\x7fELF`;
  new tests `native-executable-format`, `-coroutines`, `-cli-paths`,
  `-linker-diagnostics`; `native-executable-stack-overflow` extended
  (section 13).
- `tests/workload-2048.test`: `workload-2048-bench-executable` (section 18).
- `tests/platform/aot-facts.tcl` (new): the object and the executable as the
  host's tools see them, the standalone runs, the link command, performance
  observations; a step of the smoke and Linux control jobs.
- `tests/platform/native-status.tcl`: the `executable` probe records the
  executable's header with its value, a new `object` probe, macOS's
  expectations flipped (sections 1, 9 and 16).
- `tests/platform/tier.tcl`: the `native-aot-mutants` item.
- `audit/native-aot/tools/` (new): the mutation harness and its mutants
  (section 20).
- `audit/golden/migration/`: census rows for the five new tests, the
  manifest regenerated.
- `.github/workflows/macos-arm64.yml`: the aot-facts step.

Documentation: this report, MACOS-AARCH64-PORT-AUDIT.md, docs/INDEX.md,
docs/README.md ("Standalone executables"), README.md (status), Compilerpedia
(`backend.native-executable`, `backend.platforms`, `error.native-link`).

## 4. Mach-O object emission strategy

None of our own: `emit_object` is unchanged. Cranelift's object backend
builds the object for the ISA's triple, `aarch64-apple-darwin` on the
runner, and the object crate writes it as Mach-O. What the host's tools
report of the probe program's object (`aot-facts.tcl`, every smoke job;
first in run 39321178300):

- `file`: `Mach-O 64-bit object arm64`; the header `MH_OBJECT`, CPU type
  `CPU_TYPE_ARM64` (`0x0100000c`), 6448 bytes, made in 93 ms.
- `otool -l`: one `LC_SEGMENT_64` with `__TEXT,__text` (0x2e0 bytes, flags
  `0x80000400`: pure instructions, some instructions) and `__DATA,__bss`
  (the 8-byte context area); `LC_BUILD_VERSION` platform 1 (macOS), minos
  0.0, sdk n/a, no tools; `LC_SYMTAB` with 154 symbols; `LC_DYSYMTAB`: 1
  local, 8 external defined, 145 undefined.
- `nm -P`: `_botlish_fn_0` ... `_botlish_fn_3` and `_botlish_entry_0` ...
  `_botlish_entry_3` external text (`T`), the 145 runtime helpers
  `_rt_affine_drop` ... `_rt_value_eq` undefined (`U`), `_botlish_context_area`
  local bss (`b`). Every Botlish and runtime symbol carries exactly Mach-O's
  `_` and nothing else (the check names any other spelling as misdecorated).
- No ELF magic, no x86-64 code: the header and `file` say so, and no ELF
  relocation name occurs (`objdump -r`).

minos 0.0 is cranelift-object's choice when the triple carries no
deployment target ("useful for diagnostics ... 0.0.0 should be fine"); Apple's
ld accepts it without a warning, and the executable takes rustc's
deployment target (section 7). The object has no unwind information
(`unwind_info` is false on every target), as on Linux: no Rust unwind ever
crosses Botlish frames.

## 5. ELF-only code paths identified

| Path | What it assumes | On Mach-O |
|---|---|---|
| codegen/mod.rs `relax_context_got`, `context_relocations` | an ELF64 x86-64 object: `R_X86_64_GOTPCREL` of the context area rewritten to `R_X86_64_REX_GOTPCRELX` so GNU ld and lld relax it to `lea` | returns at the ELF magic check: a no-op. Not generalized: ld64 has no `GOTPCRELX`, and its own optimization of a GOT load of a non-preemptible symbol is the linker's business. Without the magic check it would still change nothing in a Mach-O object (an equivalent mutant, section 20) |
| codegen/clif.rs `direct_helpers` | direct `R_X86_64_PLT32` helper calls on x64 objects | not taken (aarch64): helpers are reached through the GOT on Linux AArch64 and macOS alike |
| codegen/aot.rs `link_plan_args` | GNU ld's `--start-group`/`--end-group` and the C driver's default libraries | not reached: a program that calls C is refused on macOS before the link (section 16) |
| codegen/aot.rs `linker_diagnostics` | GNU ld, lld and collect2 wording | not reached on macOS (C calls only); an ordinary program's failed link shows rustc's whole output, the toolchain's own lines among it (section 14) |
| codegen/aot.rs `link_stub`, `image`, `read_object`; runtime/aotimage.rs | an ELF64 x86-64 object, a Linux loader | refused on macOS (`the stub linker supports x86_64 Linux only`), not extended |
| tests/native-executable.test `aotParity` | `\x7fELF` | the host's format (tests/binary-header.tcl) |

## 6. Native symbol and relocation handling

The object's relocations (`objdump -r`, run 39321178300), all 22 of the
probe program's in `__text`:

- `ARM64_RELOC_BRANCH26` against `_botlish_fn_N`: Botlish-to-Botlish direct
  calls (`bl`), resolved by the linker within the image.
- `ARM64_RELOC_GOT_LOAD_PAGE21` / `ARM64_RELOC_GOT_LOAD_PAGEOFF12` pairs
  against `_rt_list_new`, `_rt_construct`, `_rt_plan_materialize`, ...: a
  runtime helper's address loaded from the GOT (`adrp` + `ldr`), then
  `blr`. Cranelift's AArch64 backend always reaches a symbol through the
  GOT in PIC code (`load_ext_name` when `is_pic`), on Linux AArch64 the same
  (`R_AARCH64_ADR_GOT_PAGE` / `R_AARCH64_LD64_GOT_LO12_NC`).
- The same GOT pair against `_botlish_context_area`, a *non-external*
  symbol. The audit had marked this as the one relocation to verify against
  Apple's ld; it links, and the program that reads its context through it
  prints the context's value (42 = 41 + 1) as an executable.

Symbol names: Botlish declares `botlish_fn_0`, `rt_cell_new`, ... through
`cranelift_module`'s API; the object crate adds Mach-O's user label prefix
(`_botlish_fn_0`), and rustc's `extern "C" { fn botlish_fn_0(); }` in the
startup crate refers to the same `_botlish_fn_0`, as the Rust runtime's
`#[no_mangle] extern "C" fn rt_cell_new` is `_rt_cell_new` in the rlib. No
name is decorated by Botlish, and the coroutine switch's assembly
(`_bl_co_switch`, milestone 3) needed no change: it links into the
executable and runs (sections 11-12). In the executable, `_botlish_fn_0` is
a defined text symbol (`nm -P`): rustc does not strip, and Apple's
`-dead_strip` keeps every Botlish function, each referenced by the startup's
function table and stack maps.

## 7. rustc/system-linker command shape

Unchanged from Linux: `link_rustc` runs

```text
rustc --edition=2024 --crate-name=botlish_program -C opt-level=2
      -C force-frame-pointers=yes -C relocation-model=pic
      --extern botlish_native=RELEASE/libbotlish_native.rlib
      -L dependency=RELEASE/deps -C link-arg=WORK/program.o
      WORK/startup.rs -o WORK/executable
```

with no `--target` (the host's), no linker flavour, no SDK path, no
deployment target of ours: rustc picks the linker and its arguments for its
host. What rustc then runs on macOS, as `aot-facts.tcl`'s
`executable-link-command` records it (`rustc --print link-args` through a
`RUSTC` wrapper; run
[39328290265](https://github.com/mwagner-webdev/botlish/actions/runs/39328290265),
smoke job
[118319688374](https://github.com/mwagner-webdev/botlish/actions/runs/39328290265/job/118319688374);
`RELEASE` is native/target/release, `SYSROOT` the rustc toolchain's sysroot,
`LINKDIR` the link's private directory):

```text
env -u IPHONEOS_DEPLOYMENT_TARGET -u TVOS_DEPLOYMENT_TARGET -u XROS_DEPLOYMENT_TARGET
    LC_ALL="C" PATH="SYSROOT/lib/rustlib/aarch64-apple-darwin/bin:..."
    SDKROOT="/Applications/Xcode_16.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.5.sdk"
    VSLANG="1033" ZERO_AR_DATE="1"
  "cc" "LINKDIR/rustc.../symbols.o" "LINKDIR/executable.botlish_program.*-cgu.0.rcgu.o"
       "LINKDIR/executable.botlish_program.*-cgu.1.rcgu.o" "LINKDIR/executable.*.rcgu.o"
       "RELEASE/libbotlish_native.rlib"
       "RELEASE/deps/liblibc-*.rlib" "RELEASE/deps/libunicode_general_category-*.rlib"
       "RELEASE/deps/libnum_bigint-*.rlib" "RELEASE/deps/libnum_integer-*.rlib"
       "RELEASE/deps/libnum_traits-*.rlib"
       "SYSROOT/lib/rustlib/aarch64-apple-darwin/lib/libstd-*.rlib" ... "libcompiler_builtins-*.rlib"
       "-liconv" "-lSystem" "-lc" "-lm" "-arch" "arm64" "-mmacosx-version-min=11.0.0"
       "-o" "LINKDIR/executable" "-Wl,-dead_strip" "-nodefaultlibs" "LINKDIR/program.o"
```

54 arguments. On Linux x86-64 the same link is `cc -m64 ... -Wl,--as-needed
-Wl,-Bstatic RLIBS -Wl,-Bdynamic -lgcc_s -lutil -lrt -lpthread -lm -ldl -lc
... -fuse-ld=lld ... program.o` (rustc 1.97 links with its own lld there):
the same rustc arguments, each platform's own linker line.

- The generated object reaches the linker as `-C link-arg=program.o`, last,
  after `-nodefaultlibs` and every library: Apple's ld resolves archives
  whatever their order, and every runtime helper the object imports is in
  `libbotlish_native.rlib`, which the startup crate already makes the link
  load (on Linux the rlib's members are pulled the same way; the order has
  never mattered for an ordinary program).
- `-Wl,-dead_strip` (rustc's default for Apple executables) keeps every
  Botlish function: each is referenced by the startup's function table
  and stack maps (section 6).
- The deployment target is rustc's default for the triple,
  `-mmacosx-version-min=11.0.0`, and the SDK the one `xcrun` names
  (`SDKROOT`, macOS 15.5): Botlish sets neither. An object's `minos 0.0` is
  below it, so Apple's ld does not warn.
- The runtime is the rlib, statically; the system's libraries are what rustc
  links for its standard library.
- The entry point is the startup crate's `main` (rustc's), which calls
  `aot::run`.
- Inherited configuration: `RUSTC` (the rustc to run), rustc's own linker
  defaults, `MACOSX_DEPLOYMENT_TARGET` if set (rustc's default otherwise),
  the SDK `xcrun` finds. Nothing in Botlish names `/usr/bin/ld`, Xcode, an
  SDK directory or a rustc location.

## 8. Startup and runtime linkage

The generated startup and `runtime::aot::run` are the Linux code, unchanged.
On macOS they initialize the same components (`aot.rs`): the 1 GiB worker
thread (`BOTLISH_NATIVE_STACK_BYTES`), the Vm and its heap, the constant
table and module statics (`constants::install`), the stack-map table
(`set_framemap`), the argument snapshot (`set_argv`), the stack guard
(`OverflowGuard::install_executable`, under the cfg of the three guarded
hosts since milestone 4: the macOS branch had existed, unexercised), then
the entry function; the value goes to standard output and the process exits
0, an error to standard error and 1. No macOS VM, startup or entry symbol
exists: the only macOS-specific code an executable runs is milestone 4's
stack discovery (`platform/macos.rs`) and milestone 3's switch text.

## 9. Executable format and architecture checks

`aot-facts.tcl`, run 39322480804 (smoke job
[118300387067](https://github.com/mwagner-webdev/botlish/actions/runs/39322480804/job/118300387067)),
on the probe program (a context, a recursion, String building, a List):

| Check | Observed on macos-15 arm64 |
|---|---|
| link | 399 ms, 809 080 bytes, mode 0755 |
| header | `MH_EXECUTE`, `CPU_TYPE_ARM64`, `MH_PIE` |
| `file` | `Mach-O 64-bit executable arm64` |
| `lipo -archs` | `arm64` (thin: no universal binary) |
| `codesign -v` / `-dv` | valid; `flags=0x20002(adhoc,linker-signed)`, `Signature=adhoc`, `Format=Mach-O thin (arm64)` |
| `otool -L` | `/usr/lib/libiconv.2.dylib`, `/usr/lib/libSystem.B.dylib`: nothing of the checkout, `target/` or the Rust toolchain |
| `nm -P` | `_botlish_fn_0` defined |

It runs natively: the runner's host step fails on Rosetta
(`sysctl.proc_translated`), and the executable is arm64 only. On Linux x86-64
the same checks give an ELF PIE (`ET_DYN`, x86-64) of 8.9 MB, 8.1 MB of it
`.debug_*` sections (the rlib's debug information is linked in; Apple's ld
leaves it in the objects, behind a debug map), loading libgcc_s, libm, libc
and the dynamic loader.

## 10. Pure executable acceptance results

The probe program as a standalone executable, moved to another directory
after its source was deleted, run with an empty environment (`env -i
PATH=/nonexistent`) from a third directory: `[6765, 100, 42]`, exit 0,
nothing on standard error (30 ms, the first run of the file; about 3 ms
a process for a trivial program, section 21). The same under
`BOTLISH_NATIVE_GC_STRESS=1`. A runtime error (`mutable_array::allocate(0 -
1)`) exits 1 with nothing on standard output and `... (CORE SEMANTIC
RANGE)` on standard error. `down(100000)`, a deep finite recursion, prints
100000.

The test files (section 11) cover the rest of the brief's list: signed and
big-integer arithmetic, branches and loops (elif.test, loop-collecting.test,
raw-count-loops.test), direct and indirect calls through generic
trampolines (native-executable.test, exact-callable-executable.test),
closures, Strings, packed and short Strings, lists, structs, opaque
structs, enums, mutable arrays, layouts, module statics and refinements,
each as an executable against the in-process backends.

## 11. Coroutine and GC results

The acceptance tier (Tier B) of run 39322480804 ran every Tcl test file
but tier.tcl's `notYet` (c-bindgen.test, c-ffi.test) on interp, and every
golden suite on the four backends, on the macOS runner -- for the first time
with the executable tests in it:

| Shard | Tcl test files | Tests | Passed | Skipped | Failed | Golden suites | Wall |
|---|---:|---:|---:|---:|---:|---:|---:|
| 1/2 ([118300387101](https://github.com/mwagner-webdev/botlish/actions/runs/39322480804/job/118300387101)) | 97 | 4228 | 4143 | 85 | 0 | 47, 0 failed | 35 min (the tier) |
| 2/2 ([118300387224](https://github.com/mwagner-webdev/botlish/actions/runs/39322480804/job/118300387224)) | 97 | 3897 | 3834 | 63 | 0 | 47, 0 failed | 27 min (the tier) |

No test skips for `executableAot` any more (the census of milestone 1
skipped 131 for it). What is still skipped is another host's or another
capability's: `nativeLinux` 84 (Linux syscalls), `linuxX86_64` 45 and
`linuxAarch64` 2 (an instruction set's transport), `stubLinker` 7 and
`rustcAvailable` 1 (the stub linker), `nvCFixture`/`neCFixture` 7 (a C
fixture linked with C), `readelf` 1, `singleExecutable` 1. The jobs took 37
and 30 minutes, 7 and 3 more than milestone 4's final run (30 and 26,
run 39304487542): the executables now linked on the runner, about 0.4 s
each, and run.

What those files run as executables on macOS, against the in-process
backends (each, in its own harness, moved and with its source gone, and
again under `BOTLISH_NATIVE_GC_STRESS=1`):

- **Coroutines**: native-executable.test's `native-executable-coroutines` --
  a yield three calls deep resumed with a message, a String made before the
  first yield and used after the last, a coroutine whose body drives
  another (nested suspension), a declared error crossing the resume that
  ran the failing segment, and 300 short coroutines each holding a fresh
  String across its yield; aot-facts.tcl's `standalone-coroutine` (and
  `-gc`); the coroutine overflow (section 13).
- **Managed values and the collector**: `native-executable-roots` (100
  allocating ancestor frames kept alive by relocated stack maps under GC
  stress), `-closure`, `-modules` (module statics, sets, Strings,
  specialized companion entries), `-generic-entry`, `-output-kinds`
  (blocks, mutable arrays, Results), structs.test, opaque-struct.test,
  enums.test, value-display.test, value-transport.test, mutable-array-type
  and mutarray-construction, binary-layout.test, native-view.test (memory
  read through views in an executable), string-allocation, short-string,
  packed-ascii, struct-scalar-replacement, exact-callable-executable
  (capturing closures under GC stress), self-recursive-result-ranges,
  loop-collecting (big bounds, lockstep under GC stress).
- **The front end's executable paths**: direct-hir-native.test (an
  executable is built from HIR, never from core IR; parity with the
  interpreter), dormant-instances, elif, flags, method-sugar, the warning
  tests' CLI cases.

## 12. GC-stress results

Pending at this commit: the final macOS run's Tier C (section 22) runs
native-executable.test, workload-2048.test, application-modules.test,
argv.test, coroutines.test and native-stack-overflow.test under
`BOTLISH_NATIVE_GC_STRESS=1`, and this container runs the first four the
same way on Linux x86-64. What already ran under GC stress: aot-facts.tcl's
`standalone-gc-stress` and `standalone-coroutine-gc` in every smoke job
from run 39322480804 on, and the executable tests that set the variable
themselves (`native-executable-roots`, the 2048 executable, argv's
`argv-standalone-gc-stress-invalid`, ...) in every acceptance tier.

## 13. Standalone NATIVE LIMIT STACK results

`native-executable-stack-overflow` (extended, not duplicated) and
`aot-facts.tcl` run actual executables:

| Executable | Stack | macOS arm64 | Linux x86-64 |
|---|---|---|---|
| stack_overflow.ir (the NIR fixture, tiny frames) | 4 MiB (`BOTLISH_NATIVE_STACK_BYTES`) | exit 1, the line | exit 1, the line |
| `down(100000000)` from source | 16 MiB | exit 1, the line (445 ms with its link) | the same |
| the same executable | the default 1 GiB | exit 1, the line | the same |
| the same recursion inside a coroutine (`worker(100000000)`, resumed once) | the coroutine's 8 MiB | exit 1, the line | the same |
| `down(100000)` | 1 GiB | exit 0, `100000` | the same |

"The line" is exactly `error {NATIVE LIMIT STACK} {native stack exhausted:
too many nested calls}` and a newline on standard error, with nothing on
standard output, and the process ends with that status, never a signal:
the tests read the exit status from `CHILDSTATUS`, where a SIGSEGV, SIGBUS
or SIGABRT would be `CHILDKILLED` and fail them. No hang: each run finishes
in under half a second. The guard did not change: its executable mode
(`_exit(1)` after the line on fd 2) is milestone 4's, now reached through a
linked Mach-O. A mutant that removes the executable's guard installation is
killed by these checks (section 20).

## 14. Driver and CLI output behavior

`native-executable-cli-paths` runs `main.tcl -emit-native-executable` from a
directory other than the input's:

- `../app dir/relative.bot` (relative, with spaces): `executable: ../app
  dir/relative`, the executable at `app dir/relative`;
- an absolute input path; `-target` naming the host's own target (the
  program imports `ffi::c`, so its HIR records the target); `-backend
  cranelift-generic` (executables are always closed and specialized: one
  mode, section 19);
- each written beside its input, executable, the host's format, printing
  42;
- `-target` of the host architecture's other operating system
  (`linux-aarch64` on macOS, `macos-x86_64` on Linux x86-64): refused,
  `NATIVE TARGET`, exit status 1, nothing written.

The output is published only after a successful link, by a rename on the
destination's filesystem from a private `.botlish-aot-PID-NANOS` directory
beside it, which is removed whatever happens: `native-executable-link-failure`
(no rustc) and `native-executable-linker-diagnostics` (a link the
toolchain rejects, a missing object file, its own words in the message) keep an earlier file intact and leave no temporary directory, and
`native-executable-reject` (a program that is not AOT-ready) never writes
one. No `/tmp` path is ours: the driver's own temporary files are Rust's
`std::env::temp_dir` and Tcl's `file tempfile`.

## 15. Argument and output-path behavior

argv.test's standalone tests (13, all passing on macOS in the acceptance
tier) run one executable built once with many argument vectors through a
bash `exec -a` launcher: the run-time arguments of each run, argument zero
as the launcher supplied it (a custom name, a relative path, an absolute
one, the empty string), non-ASCII and invalid UTF-8 bytes (the declared
`InvalidArgumentEncoding`, handled), 600 arguments and many bytes (also
under GC stress), a program that never calls `argv()` running under
invalid arguments, the compiler's own arguments never captured in the
executable, the same text in-process and standalone, a random fuzz against
the in-process backends, and `argc == 0` (Python's `execv` with an empty
vector: the runtime reports `[]`, or `[""]` where the kernel substitutes an
empty argument zero as Linux 5.18+ does -- the test accepts either and
rejects a synthetic name; which of the two macOS gives it does not record).
Nothing changed in the runtime for this: `std::env::args_os` is
libSystem's `argc`/`argv` on macOS.

Output paths (section 14) and the executable's output: the value is one
line on standard output; a runtime error and NATIVE LIMIT STACK are on
standard error with exit status 1; nothing else is written. A program's own
printed output (io::print_line) needs `linux::io` and does not compile for
macOS (section 27).

## 16. Execution outside the source directory and unsupported C calls

Every executable test moves the executable or runs it from another
directory: `aotParity` (native-executable.test and the files that copy its
shape) renames it out of its build directory, deletes its source and runs
it with an empty `PATH`; aot-facts.tcl does the same with `env -i`;
application-modules.test's `app-interchange-without-sources` deletes the
application's source directory first. Nothing an executable does at run
time reads the checkout, the source, Tcl, rustc or a temporary build
directory (section 9's library list).

A program that calls C (`extern c fn`, `extern c library`) is not linked on
macOS: `emit_executable` refuses it before the linker runs, `NATIVE LINK`,

```text
native link failed: this program calls C or declares a C library (symbols labs),
and C calls are linked on Linux glibc only: on this host executables of programs
that call no C are supported, C calls not yet (MACOS-AARCH64-PORT-AUDIT.md, C FFI)
```

for `-emit-native-executable` and for the native backends' runs alike (they
link such a program to run it). native-status's `c-call` probe records it;
c-ffi.test stays in tier.tcl's `notYet`. Before this milestone the same
program was refused with the general executable refusal; the distinction is
now explicit because ordinary executables link.

## 17. Multi-file application acceptance

Two multi-file applications become executables that run without their
source directory:

- application-modules.test's `app-interchange-without-sources` (in the
  acceptance tier): an application of two files (`main.bot` and its
  application module `counter.bot`) written to HIR interchange, the
  `.hirx` moved to another directory and the application's directory
  deleted; the `.hirx` runs on all four backends, becomes NIR and, through
  `main.tcl -emit-native-executable`, an executable that prints `[250,
  42]`, the value of every backend.
- workload-2048.test's `workload-2048-bench-executable` (new): the 2048
  benchmark and its engine (section 18), copied out of the checkout and
  compiled by main.tcl from another directory; application modules are
  resolved at compile time from the entry file's directory (IMPORTS.md),
  the executable carries everything, and it runs after the copy is gone.

Neither imports a platform namespace, so neither needs a platform FFI
declaration or `-target`: the HIR records no target (it depends on none),
the host's is used, and the executable is macOS AArch64's (its header,
checked in every executable test).

## 18. 2048 workload results

`examples/games/2048/bench.bot` (the deterministic benchmark: 200 moves of
the engine `game2048.bot`, lists, structs, enums, mutable vectors, heap
allocation and a checksum the Python oracle confirms) as a standalone
executable on macOS: `2002720`, plain and under `BOTLISH_NATIVE_GC_STRESS=1`
-- the checksum `workload-2048-bench-checksum` computes on interp, compile,
cranelift-generic and cranelift. Its seed mixes in the length of the process
argument vector, which the executable reads from its real arguments (one,
as the in-process default). The engine and the benchmark are unchanged. The
interactive demo (`demo.bot`) prints through `linux::io` and stays Linux's
(`workload-2048-demo-executable` keeps `nativeLinux`): it awaits the Darwin
IO milestone.

## 19. Linux ELF and stub-linker regression

What a Linux executable is did not change: `EXECUTABLES` is true on Linux
glibc x86-64 and AArch64 exactly as the old gate was, `C_CALLS` is true on
Linux, `link_rustc`'s arguments and the link plan are byte-identical (the
link-plan unit tests pin them), and the startup is the same text. The test
changes on Linux are the capability's definition (true on both Linux
targets, as each file's copy was) and stricter tests.

Local evidence (this container, Linux x86-64, rustc 1.97.0):

- the 38 files whose `executableAot` definition moved, on interp: 2723
  tests, 2723 passed, 0 skipped;
- native-executable.test with the rustc linker 18 of 18, and with
  `BOTLISH_NATIVE_LINKER=stub` 16 of 16 (the two rustc-only tests skipped
  by `rustcLinker`), the new coroutine, format, path and overflow tests
  among them; `workload-2048-bench-executable` with both linkers;
- aot-facts.tcl and native-status.tcl: every check (ELF PIE, `ldd`, the
  link command, the standalone runs; `executable` `{elf x86_64 shared}
  6765`, `object` `{elf x86_64 relocatable}`, `c-call` 5);
- the mutation run (section 20).

The CI evidence is sections 23 and 24: tests.yml runs the whole Tcl suite
on interp and compile, cranelift and cranelift-generic coverage, the golden
shards beside their Tcl originals, the Rust unit tests, the warning gate and
the **stub-linked executables** (every executable test file with
`BOTLISH_NATIVE_LINKER=stub`, including the new ones); tests-arm64.yml the
same on Linux AArch64 (rustc linker) with GC stress. The Linux control job
of every macOS run ran aot-facts.tcl and native-status.tcl on ubuntu x86-64
(success in every run of this milestone).

## 20. Mutation results

`audit/native-aot/tools/mutate.tcl` (new; the native-stack harness's shape):
each mutant in `audit/native-aot/tools/mutants.txt` is applied to a private
copy of the tree, its native backend rebuilt (a mutant that does not build
is NOT-BUILT, never killed), and the detectors run against it: the link
plan's Rust tests, native-executable.test, argv.test's standalone tests,
workload-2048.test's `workload-2048-bench-executable`, aot-facts.tcl and
native-status.tcl. tier.tcl's `native-aot-mutants` item runs it on macOS
(Tier C).

| Mutant | What it breaks | Linux x86-64 | macOS arm64 |
|---|---|---|---|
| `macos-aot-rejected` | macOS left out of `EXECUTABLES` | skipped (not compiled differently) | killed: 16 native-executable tests, 13 argv, the 2048 executable, aot-facts `executable-link`, native-status `executable`, `c-call` |
| `linux-aot-rejected` | Linux left out of `EXECUTABLES` | killed: 16 native-executable tests, 13 argv, the 2048 executable, aot-facts `executable-link`, native-status `executable`, `c-call` | skipped |
| `c-calls-on-macos` | `C_CALLS` true on macOS: unvalidated C calls linked | skipped | killed: native-status `c-call` (its outcome is no longer the refusal; the log does not say whether the unvalidated link then succeeded) |
| `c-calls-refused-on-linux` | `C_CALLS` false on Linux | killed: native-status `c-call` | skipped |
| `object-linux-triple-on-macos` | the program object built for `aarch64-unknown-linux-gnu` (ELF) on macOS | skipped | killed: aot-facts `object-header`, `object-file`, `object-symbols`, `object-relocations`, `object-build-version`, `executable-link`; 15 native-executable, 13 argv, 2048; native-status `object`, `executable` |
| `helpers-misnamed` | the object's runtime imports not the runtime's symbols | killed: 12 native-executable, 12 argv, the 2048 executable, aot-facts, native-status | killed: 12 native-executable, 12 argv, the 2048 executable, aot-facts `executable-link` |
| `runtime-linked-dynamically` | `-C prefer-dynamic`: the executable needs the toolchain's libstd | killed: aot-facts `executable-libraries` and every standalone run, 14 native-executable, 13 argv, 2048, native-status | killed: aot-facts `executable-libraries` and the standalone runs, 14 native-executable, 13 argv, 2048, native-status `executable` |
| `linker-status-ignored` | a failed link not recognized | killed: `native-executable-linker-diagnostics` | killed: `native-executable-linker-diagnostics` |
| `output-wrong-path` | the executable published beside the requested path | killed: 15 native-executable, 13 argv, 2048, aot-facts, native-status | killed: 15 native-executable, 13 argv, 2048, aot-facts, native-status `executable` |
| `startup-no-stack-maps` | the startup installs no stack maps | killed: 8 native-executable (each run under GC stress), the 2048 executable under GC stress, aot-facts `standalone-gc-stress`, `standalone-coroutine-gc` | killed: 8 native-executable, the 2048 executable under GC stress, aot-facts `standalone-gc-stress`, `standalone-coroutine-gc` |
| `startup-no-guard` | an executable runs without the stack guard | killed: `native-executable-stack-overflow`, aot-facts' three overflows | killed: `native-executable-stack-overflow`, aot-facts' three overflows |
| `startup-no-argv` | process arguments never reach `argv()` | killed: 12 argv standalone tests | killed: 12 argv standalone tests |
| `result-not-printed` | an executable prints no value | killed: 13 native-executable, 13 argv, 2048, aot-facts, native-status | killed: 13 native-executable, 13 argv, 2048, aot-facts, native-status `executable` |
| `any-target-runs` | another target's program run and emitted here | killed: `native-executable-cli-paths`, native-status `other-target` | killed: `native-executable-cli-paths`, native-status `other-target` |

macOS arm64 (run 39328290265, Tier C job
[118319688943](https://github.com/mwagner-webdev/botlish/actions/runs/39328290265/job/118319688943),
at 5310075): **14 mutants, 12 killed, 0 survived, 2 skipped** (Linux's
code), in 6 minutes. Linux x86-64 (this container, every mutated file as committed: ee967c8
changes none): **14 mutants, 11 killed, 0 survived, 3 skipped** (macOS's
code), in 8 minutes. No mutant was NOT-BUILT or
NOT-APPLIED on either host. A mutant counts as killed only by a detector
that ran and failed; each one's killers are tests of behavior (a value, an
exit status, a header, a library list), never only an object's existence.

**One equivalent mutant, removed.** The brief's "an ELF-only relocation
optimization runs on Mach-O" was first written as `relax_context_got`'s
parser without its ELF magic check. It survived on Linux, where every object
is ELF, and it cannot change a Mach-O object either: read as ELF, a Mach-O
object has zeros where ELF keeps its section-header offset (0x28) and count
(0x3c) -- the first `LC_SEGMENT_64`'s empty segment name and its vmaddr --
so the parser finds no section and rewrites nothing. There is no
observable behavior to kill; mutants.txt records why it is not there.

**Not mutated, by the brief's own exclusions or because nothing observable
remains:** Cranelift and Apple's linker; the generic backend's "wrong
architecture" (the object's ISA is the same `isa(true)` for both native
command lines, and `object-linux-triple-on-macos` is that mutant); host CPU
features in the object (`builder_with_options(true)` for the AOT ISA would
change nothing observable on the machine that runs the executable it built).

## 21. Performance and link-time observations

Only enough to rule out a catastrophe, on one host at a time (no
comparison across hosts: the runner is a 3-CPU virtualized M1, this
container a 4-CPU x86-64):

| Measure | macOS arm64 (run 39328290265) | Linux x86-64 (this container) |
|---|---:|---:|
| program object, probe program | 93 ms | 81-83 ms |
| link (rustc + platform linker), probe program | 399 ms (run 39322480804) | 534-572 ms |
| executable size | 809 KB | 8.9 MB (debug info linked in) |
| first run of the moved executable | 30-37 ms | 4-5 ms |
| a trivial executable's whole process, median of five | 3.2 ms | 2.1-2.9 ms |
| `fib(25)` and 2000 String concatenations, best of 20: JIT | 409 us | 549-708 us |
| the same, inside its executable | 429 us (1.05) | 518-590 us (0.83-0.94) |

- **Compute is the same code.** The JIT and the executable run the same
  NIR through the same Cranelift backend; the executable's ISA has the
  target's baseline features where the JIT may use the host's
  (`builder_with_options(!pic)`), and its helpers are reached through the
  GOT. On both hosts the two are within the run-to-run noise of these
  machines (5% on macOS, the executable faster on Linux).
- **Linking is rustc compiling the startup crate and the platform linker
  linking the runtime**, about 0.4-0.6 s a program on either host; the
  executable tests' linking is what lengthened the acceptance jobs by 3-7
  minutes (section 11). Nothing is cached between links and nothing needs
  to be: the work directory is per link, and rustc compiles only the
  generated startup.
- **Startup** is dyld (or ld.so) and the worker thread: a few
  milliseconds. The first run of a freshly linked macOS executable took
  30-37 ms, about ten times a later process of a (smaller) executable; the
  cause was not measured (a new file's first exec includes its page-ins
  and the kernel's check of its signature).
- No compiler optimization was made in response to these numbers.

## 22. macOS GitHub Actions runs

Every macOS fact in this report is from these runs of
`.github/workflows/macos-arm64.yml` on `ccr-8cfaccb4-di88s4` (GitHub's
`macos-15` arm64 runners; the trailers of the two `[ci-full]` commits,
`CI-Tests:` and `CI-GC-Stress:`, parse as trailers under `git
interpret-trailers --parse`):

| Run | Commit | What it was for | Result |
|---|---|---|---|
| [39321178300](https://github.com/mwagner-webdev/botlish/actions/runs/39321178300) | 45f6b47 | Gate A/B: aot-facts.tcl against the unchanged backend | smoke **failed as intended** (2.7 min: every object check passed, `executable-link` the old refusal); linux control success; acceptance cancelled by the next push |
| [39322480804](https://github.com/mwagner-webdev/botlish/actions/runs/39322480804) | 8a0140c | Gates C-D: executables on macOS, the executable tests in the acceptance tier | success: smoke 2.3 min, acceptance 37.0 and 29.5 min, linux control 1.3 min |
| [39328290265](https://github.com/mwagner-webdev/botlish/actions/runs/39328290265) | 5310075 | the mutation harness and the link-command check, `[ci-full]` with `CI-Tests: native-aot-mutants native-executable.test workload-2048.test argv.test application-modules.test` | success: smoke 2.1 min, acceptance 35.9 and 29.4 min, Tier C 9.3 min (the mutants, section 20; the four files on interp and compile, 110 of 112 passed, 2 skipped by `nativeLinux`), linux control 1.2 min |
| [39333085905](https://github.com/mwagner-webdev/botlish/actions/runs/39333085905) | ee967c8 | the final code: aot-facts.tcl last in the smoke job, `[ci-full]` with `CI-Tests: native-executable.test workload-2048.test application-modules.test argv.test coroutines.test native-stack-overflow.test`, `CI-GC-Stress: 1` | pending at this commit (section 12) |

No run used the shared Apple Silicon development machine, and none was
re-run (every run's attempt is 1). These and the two Linux dispatches
(sections 23 and 24) are all six runs of the branch.

## 23. Linux x86-64 CI results

`tests.yml` dispatched on the branch at 5310075 (the last commit that
changes code; ee967c8 changes only aot-facts.tcl and the macOS workflow,
which no Linux job runs): run [39328971122](https://github.com/mwagner-webdev/botlish/actions/runs/39328971122), **success**.

| Job | Result | Time |
|---|---|---:|
| tests (interp) | success | 28.8 min |
| tests (compile) | success | 36.8 min |
| tests (cranelift coverage) | success | 34.2 min |
| tests (cranelift-generic coverage) | success | 27.4 min |
| tests (stub-linked executables) | success | 8.6 min |
| tests (native Rust unit tests) | success | 1.1 min |
| golden suites, shards 1-4 | success | 2.1-2.7 min each |
| method-call kind filter (audit) | success | 21.9 min |
| warning gate (manifest) | success | 0.6 min |
| tests (native GC-stress) | skipped: it runs on pushes to main only | -- |

The x86-64 GC-stress evidence for this milestone's tests is therefore the
local run of section 12, and CI's `gc-stress` job will run on the push to
main. The stub-linked job is the stub linker's regression run: every
executable test file with `BOTLISH_NATIVE_LINKER=stub`, the new tests
among them.

## 24. Linux AArch64 CI results

`tests-arm64.yml` dispatched on the branch at 5310075: run
[39328975035](https://github.com/mwagner-webdev/botlish/actions/runs/39328975035).
Pending at this commit: the golden shards 1-4 (2.8-4.2 min) and the native
Rust unit tests (0.9 min) passed; interp, compile, the cranelift and
cranelift-generic coverage and the native GC-stress job were running.

## 25. Single-executable packaging status

The single executable (single/, SINGLE-EXECUTABLE.md) is a different thing
from a standalone executable and is unchanged: one Linux x86-64 glibc file
holding a static zipfs tclsh, the compiler, the library and both native
binaries, which emits executables through the toolchain-free stub linker
(single/main.tcl sets `BOTLISH_NATIVE_LINKER=stub`). What of it applies to
macOS:

- **Portable as it is:** `single/package.tcl` (it packs files) and
  `single/main.tcl`'s installation of the native binaries into a cache
  directory are portable Tcl; a zipfs tclsh builds on macOS.
- **Not portable:** the emitting half. The stub linker is ELF x86-64 code
  and a Linux loader, and a Mach-O counterpart would be a Botlish linker
  and loader with arm64 relocations, veneers, an icache flush and code
  signing -- what this port's doctrine rules out (MACOS-AARCH64-PORT-AUDIT.md,
  section 5). A macOS single executable could only emit executables through
  the rustc linker, which needs a Rust toolchain and the Xcode command line
  tools on the user's machine: the packed compiler would then save nothing
  but the Tcl installation.
- **What standalone executables already give:** a program compiled on macOS
  is one Mach-O file that runs on any arm64 Mac with libSystem, without the
  compiler. Whether a packaged macOS *compiler* is needed is a product
  decision this milestone does not make; nothing here depends on one, and
  no universal binary, bundle, rpath policy, dylib deployment or signing
  beyond the linker's ad hoc signature was added. A hardened-runtime or
  notarized driver would need the JIT entitlement (`MAP_JIT`) for the
  in-process backends, the audit's milestone 10 note; executables need
  none (they write no code at run time).

## 26. Remaining blockers for macOS C FFI

What this milestone leaves for the macOS C FFI milestone (roadmap entry 7),
now that the link it needs exists:

- **The refusal to remove**: `codegen/aot.rs`'s `C_CALLS`. With it gone, a
  program that calls C reaches `link_rustc` and `link_plan_args`, whose
  plan is GNU ld's: `-Wl,--start-group`/`--end-group` (Apple's ld rejects
  unknown options; it resolves archives without groups, so macOS needs no
  group) and `-C default-linker-libraries=yes` (the glibc loader rationale
  of C-FFI.md, section 11, is Linux's). A per-OS link plan, Linux's
  byte-identical (its unit test pins it).
- **Diagnostics**: `linker_diagnostics` filters GNU ld, lld and collect2
  wording; Apple's ld says `Undefined symbols for architecture arm64:` and
  `ld: library 'NAME' not found`. c-ffi.test's `cf-missing-library` expects
  the Linux words.
- **The ABI facts to prove against real callees**: narrow argument and
  result extension under AppleAarch64 (Cranelift's `get_ext_mode`; i8/i16
  "not implemented yet" in its comment), Apple's natural-size packing of
  stack-passed arguments, pointer results and wild addresses
  (`NATIVE ADDRESS`), `named` symbols with Mach-O's `_`.
- **The fixture**: tests/cffi/fixture.c's inline assembly needs a Mach-O
  spelling; c-ffi.test builds the fixture on Linux only; c-bindgen.test's
  manifests record Ubuntu's clang.
- **Already in place**: the executable link itself (this milestone), the
  driver's run of a linked program in the driver protocol (`run_linked`,
  unchanged), the Apple C convention in foreign signatures (milestone 2).

## 27. Remaining platform IO limitations

- `linux::*` stays the Linux platform's: importing it for `macos-aarch64` is
  UNSUPPORTED-PLATFORM (milestone 2), so `examples/io/hello.bot` and the
  2048 demo (`linux::io`) still do not compile for macOS; they await the
  Darwin IO milestone (roadmap entry 9: an `io::IO` implementation over
  libSystem C calls, after the C FFI milestone). No Darwin syscall, libc
  binding or `macos::io` was added.
- What a macOS executable can write today is what every executable writes
  without IO: its final value on standard output, a runtime error or the
  NATIVE LIMIT STACK line on standard error, and its exit status. That is
  the output channel this milestone tests; it is not application IO, and
  section 18's workload is the 2048 benchmark (a checksum), not the demo.
- An executable's input is its argument vector (`argv()`), which works
  (section 15); there is no standard input, file or environment access
  for a Botlish program on macOS.

## 28. Prerequisites for the next milestone

The next roadmap entry is 7, C scalar/pointer ABI, symbol resolution and
linking (MACOS-AARCH64-PORT-AUDIT.md, section 17), whose prerequisite was
this milestone. It can rely on: the rustc/Apple-ld link of an ordinary
program, on both native backends' command lines; `run_linked` (a program
that calls C runs as a linked executable) unchanged; the executable's
startup, guard and output on macOS; aot-facts.tcl and native-status as the
place to record the first linked C call (native-status's `c-call` probe
flips from the `C_CALLS` refusal to its value, 5). It has to bring: the
per-OS link plan, Apple ld's diagnostics, the fixture's Mach-O assembly and
its build on macOS, and the ABI tests listed in section 26 -- and then
remove c-ffi.test (and, with its toolchain decision, c-bindgen.test) from
tier.tcl's `notYet`.
