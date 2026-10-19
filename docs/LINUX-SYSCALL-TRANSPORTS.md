# Linux syscall transports: x86-64 and AArch64

## Outcome

Botlish makes raw Linux syscalls on both architectures the native backend
runs on, and the portable layers above them are one source on both:

```
io::print_line ... linux::io::write_text ... linux::write          (one source)
    --> linux::sys::write    lib/linux/sys.x86_64.bot | lib/linux/sys.aarch64.bot
    --> linux::abi::x86_64::syscall({rax: ...})   |  linux::abi::aarch64::syscall({x8: ...})
    --> `syscall`                                  |  `svc #0`
```

* **Two transports, one table.** The x86-64 transport of
  LINUX-X86-64-SYSCALL.md is renamed `linux::abi::x86_64::syscall`, and its
  AArch64 sibling `linux::abi::aarch64::syscall` takes the AArch64 Linux
  convention's registers: the number in `x8`, arguments 1-6 in `x0`..`x5`,
  the result in `x0`. Both are rows of one table, `core::linuxabi`'s
  `transports` (native, registers, abi namespace, register type, NIR op,
  instruction): the static contract (hir/syscall.tcl), escape analysis
  (hir/escape.tcl) and native lowering (native/lower.tcl) read the row of
  the transport a call names, and nothing names a transport but the table.
* **`abi::aarch64`** (lib/abi/aarch64.bot) is lib/abi/x86_64.bot for
  AArch64: its own nominal `Register64`, `register64`, `to_int`, the
  `from_i8` ... `from_usize` encoders and, as root natives, the address
  bridges `abi::aarch64::from_bytes` and `from_mutable_bytes`. The two
  architectures are never mixed: an `abi::x86_64::Register64` in the AArch64
  transport, an AArch64 word in the x86-64 one, or the other architecture's
  address bridge is `TYPE`, statically.
* **`linux::sys` is an architecture-specific module**: it has no
  `lib/linux/sys.bot` but `lib/linux/sys.x86_64.bot` and
  `lib/linux/sys.aarch64.bot`, and the compilation target's architecture
  picks the one that defines it. The target is the one ffi::c's widths
  already follow (`-target`, the host's by default, core/cabi.tcl). What
  differs by architecture -- the syscall numbers (write is 1 and 64, read 0
  and 63), which register carries which argument, the register type and its
  bridges -- is ordinary Botlish data in those two files; `lib/linux.bot`
  (`linux::write`, `linux::read`, `linux::ReadResult`), `lib/linux/io.bot`
  and `lib/io.bot` name no register, number or transport.
* **Evidence**: the AArch64 boundary's Rust unit tests (getpid 172 equal to
  `std::process::id()`, write(2) to a pipe byte for byte, `-9` for a bad
  descriptor) pass under qemu-user, and so does
  `tests/linux-syscall-transports.test` on an emulated AArch64 host (the
  driver built for `aarch64-unknown-linux-gnu`, run through qemu, the Tcl
  host's `tcl_platform(machine)` reporting `aarch64`): the AArch64 getpid
  equals the driver's pid, `linux::write` and `linux::read` reach the kernel
  through `sys.aarch64.bot`, and the x86-64 transport is `NATIVE
  UNSUPPORTED` there. CI's arm64 workflow (tests-arm64.yml) runs every test
  natively, the machine-code one included.

## Source surface

### The transports (core/linuxabi.tcl)

```
linux::abi::x86_64::syscall({rax: R, rdi: R, rsi: R, rdx: R, r10: R, r8: R, r9: R})
    -> abi::x86_64::Register64              R: abi::x86_64::Register64
linux::abi::aarch64::syscall({x8: R, x0: R, x1: R, x2: R, x3: R, x4: R, x5: R})
    -> abi::aarch64::Register64             R: abi::aarch64::Register64
```

| | x86-64 | AArch64 |
|---|---|---|
| number | `rax` | `x8` |
| arguments 1-6 | `rdi rsi rdx r10 r8 r9` | `x0 x1 x2 x3 x4 x5` |
| instruction | `syscall` | `svc #0` |
| result | `rax` | `x0` |
| clobbered by the kernel | `rcx`, `r11` | none (all but `x0` restored) |
| NIR op | `syscall_linux_x86_64` | `syscall_linux_aarch64` |

Everything LINUX-X86-64-SYSCALL.md says about the x86-64 transport holds for
both, read through the row: the argument is an anonymous struct literal (or
a value of such a type); a field outside the row's registers is
`UNKNOWN-FIELD` at the field (`rax` is no AArch64 register); the number
register is required (`MISSING-FIELD`); every field is statically the row's
`Register64` (`TYPE`); an omitted argument register is zero; the result is
the raw result register, never an errno; a transport is only ever called
(`TYPE` as a value); the Tcl backends refuse it with `NATIVE-ONLY`; the
effects are maximally conservative at every layer.

**Why rename the x86-64 one.** Botlish has no overloading, and the
transport's argument names its architecture's registers, so one
`linux::abi::syscall` cannot take both conventions. The symmetric spelling
`linux::abi::ARCH::syscall` beside `abi::ARCH` says which architecture's
transport a call is, everywhere it is written. `linux::abi` itself is no
namespace any more: `import linux::abi::x86_64` authorizes the x86-64
transport (imports stay exact).

**Why one table.** Every place that knew "the" transport -- the contract
checker, the escape analysis that keeps the register struct and both
Register64s virtual, the lowering, the address-provenance pass, the Tcl
backends' refusal -- now asks `core::linuxabi` for the row of the native a
call names (`transportOf`, `transport ARCH FIELD`, `registerTypes`), and the
address bridges are registered from the same table
(`core::bytestore::bridges`: a readable and a writable bridge per
architecture, `bridgeArch`, `bridgeRegisterType`). A third architecture is a
row, a Rust boundary and its `abi::ARCH` module.

### `abi::aarch64` (lib/abi/aarch64.bot)

The same source as `abi::x86_64` with the architecture's names: a 64-bit
general-purpose register's contents under the signed reading, checked in
(`register64`, `Register64BelowRange` / `Register64AboveRange`), read back
signed (`to_int`), and the ABI numeric encoders (signed values sign-extended,
unsigned zero-extended, U64's upper half as the negative word). Its errors
are `abi::aarch64::Register64BelowRange` and `...AboveRange` (an error's
identity is its module and its name). Isize/Usize are 64 bits on AArch64,
as on x86-64.

### The architecture-specific module `linux::sys`

```
lib/linux.bot              namespace linux        (portable: the API and its semantics)
lib/linux/sys.x86_64.bot   namespace linux::sys   on an x86-64 target
lib/linux/sys.aarch64.bot  namespace linux::sys   on an AArch64 target
```

`linux::sys::write(fd: abi::I32, data: abi::bytes::Bytes) -> int` is one
write(2) through the architecture's transport, and `linux::sys::read(fd,
data)` one read(2) into a freshly detached copy of DATA, returning `{result,
data}` (an anonymous struct: scalar replacement passes it back as its two
fields, so `linux::read`'s NIR is a `callmulti` and a `retmulti`, with no
allocation the old single-file read did not make). `linux::write` and
`linux::read` keep their signatures, semantics and documentation and call
them: the policy (one syscall, the raw signed result, the logical copy, no
`count` parameter) is stated once, in lib/linux.bot, and the two
architecture files only perform it.
`tests/linux-syscall-transports.test` pins that the two files declare the
same functions with the same parameters and results and differ in their
imports only by the architecture's own two (`lst-linux-sys-same-surface`),
and that no other library file spells a transport (`lst-linux-is-one-source`).

The cost of the extra layer is one direct call (linux::write -> linux::sys::
write); the transport's own NIR is exactly what linux::write's was
(`cb-syscall-nir-unchanged` reads it in linux::sys::write and
linux::sys::read now, compiled for `-target linux-x86_64` so that it pins the
same text on any host).

## The loader rule: architecture-specific modules

surface/modules.tcl's `ModuleFile`: namespace `P` (path `lib/P.bot`) is
architecture-specific when it has no `lib/P.bot` but files `lib/P.ARCH.bot`,
ARCH one of the targets' architectures (`core::cabi::architectures`:
`aarch64`, `x86_64`); the compilation target's architecture picks the file.

* **Still one file per namespace per compilation, still no search.** Each
  candidate is one fixed path per known architecture, and a namespace
  segment cannot contain a dot, so `P.ARCH.bot` is never another namespace's
  file. The qualified spelling stays the only one: `linux::sys::write` is
  defined by exactly the target's file.
* **By architecture, never by operating system.** The module's own namespace
  says which OS it is for, and is checked first: the `linux` namespace and
  everything under it are the Linux platform's, so for a target of another
  operating system (`macos-aarch64`, `windows-x86_64`) the import is
  `UNSUPPORTED-PLATFORM` before any file is chosen (surface/modules.tcl's
  `PlatformCheck`; MACOS-AARCH64-MILESTONE-2.md) -- `sys.aarch64.bot` is
  Linux AArch64's, never macOS AArch64's. Before milestone 2 of the macOS
  port, `windows-x86_64` loaded `sys.x86_64.bot` and refused only at run
  time. An architecture-specific namespace that is no platform's (a
  `demo::arch`) still goes by architecture alone, on every operating
  system.
* **Diagnostics, at the import:** both `P.bot` and `P.ARCH.bot` is
  `AMBIGUOUS-MODULE`; files for other architectures only is
  `UNSUPPORTED-ARCHITECTURE` (naming the files it has and the one it lacks);
  a host that is no known target is `UNKNOWN-TARGET` ("compile with
  -target"), as for ffi::c; no file at all is `UNKNOWN-NAMESPACE`. The two
  new kinds are header kinds, never a static block's rejection
  (`tests/static-compile.test`'s census).
* **The front-end cache** keys on the resolved target already
  (C-ABI-TYPES.md); `surface::cache::Dependencies` now records both
  candidate paths of every imported namespace -- `lib/P.bot` and the target
  architecture's `lib/P.ARCH.bot`, with whether each exists and the text the
  build read -- so a file appearing at either one invalidates the entry.
* **HIR interchange**: a HIR holds the code of the file its build read, and
  records its target. A `.hirx` built for one target is refused as a
  compilation for another (`HIR INTERCHANGE TARGET`), and the native driver
  refuses to run a HIR built for another target (`NATIVE TARGET`), so the
  other architecture's transport is never reached natively; the Tcl
  backends still run it, and refuse the syscall (NATIVE-ONLY).
* **Compilation isolation** is unchanged: no registry is added; the
  transport table and the bridges are bootstrap natives, the same in every
  compilation.

The warning gate (audit/refactor/tools/gate.tcl) loads an
architecture-specific module once per architecture, as `import NS` under
`-target linux-ARCH` (its unit `NS@linux-ARCH`), so both of linux::sys's
files are held to `-warnings error`.

## Native implementation

### The boundary (native/src/runtime/syscall.rs)

```rust
#[cfg(all(target_arch = "aarch64", target_os = "linux"))]
#[unsafe(no_mangle)]
#[inline(never)]
pub unsafe extern "C" fn botlish_linux_aarch64_syscall(
    x8: i64, x0: i64, x1: i64, x2: i64, x3: i64, x4: i64, x5: i64,
) -> i64 {
    let result: i64;
    unsafe {
        core::arch::asm!(
            "svc #0",
            in("x8") x8, inlateout("x0") x0 => result,
            in("x1") x1, in("x2") x2, in("x3") x3, in("x4") x4, in("x5") x5,
            options(nostack),
        );
    }
    result
}
```

Built for aarch64-unknown-linux-gnu (with the frame pointers
.cargo/config.toml forces), it disassembles to the frame record, `mov x8,
x0; mov x0, x1; ...; mov x5, x6`, `svc #0x0`, `ldp`, `ret`: every word moves
one register over from the AAPCS64 parameter registers, exactly as the
x86-64 boundary moves its words out of the System V ones.
`lst-aarch64-machine-code-routes-registers` simulates that disassembly from
the entry in a standalone executable (any other instruction shape fails the
test loudly) and counts one `svc` in the whole program.

The kernel restores every register but x0 on return, so nothing else is
declared clobbered; the flags are not declared preserved; no `pure`, `nomem`
or `readonly`. `rt_linux_aarch64_syscall` reads the seven operand Ints as
i64 words (TYPE, before any transition, for an operand that is none -- a
`-strict 0` program's unproven Register64), calls the boundary and returns
x0 read signed. Each helper exists on every target; off its own Linux
architecture it is `NATIVE UNSUPPORTED` ("linux::abi::aarch64::syscall needs
a Linux AArch64 target"), never another architecture's convention.

### NIR, Cranelift, the runtime tables

`syscall_linux_aarch64` is the x86-64 op's sibling in every table: seven
operands, `op_may_allocate` (a BigInt result), `op_may_error`, never a
Native value's dispatch, the helper table (`rt_linux_aarch64_syscall`, 8
parameters; the AOT image's ABI fingerprint includes it), and a real
Cranelift `call` of the helper. The address bridges' runtime is
architecture-neutral (`rt_bytes_addr`, `rt_mbytes_addr`: a 48-bit AArch64
user address is far inside the small-Int range), and so is the `keepalive`
discipline: both architectures' bridges and transports go through
`ExposeStorage` and `KeepExposedAlive`.

## Tests

* **tests/linux-syscall-transports.test** (22 tests): the table; the
  AArch64 native's registration and bridges; the conversions on every
  backend; the AArch64 contract (UNKNOWN-FIELD for rax, x6, x30, sp with the
  register list; MISSING-FIELD for x8; never mixed; not a value); the Tcl
  backends' refusal naming `svc #0`; NIR (register order x8 x0 .. x5 from any
  written order); natively, the other architecture's transport is NATIVE
  UNSUPPORTED; on Linux AArch64 (`linuxAarch64`) the live getpid is the
  driver's pid and the machine code routes x8, x0..x5 into the one `svc`;
  linux::sys selected by the target (four targets, from any host), lowered to
  that target's op with its own write number, the same surface in both
  files, no transport outside them; the portable wrappers natively (`-9`);
  a program compiled for the other architecture's target; the loader rule
  in a private library (a demo module's value per target; AMBIGUOUS-MODULE,
  UNSUPPORTED-ARCHITECTURE, UNKNOWN-TARGET, UNKNOWN-NAMESPACE); the cache's
  dependencies; an application module named like linux::sys
  (MODULE-COLLISION naming both architecture files) and one importing linux
  (the target's linux::sys from the standard library). Its source-observable tests are ported to
  tests/golden/linux-transports.bot (13 golden tests, all four backends;
  perturb.tcl: every test fails inverted and altered) and one to
  abi-bytes-native.bot.
* **The x86-64 suites** (linux-syscall, abi-bytes, abi-mutable-bytes,
  abi-numeric, c-pointer-borrowing, contexts, portable-io, ...) spell the
  renamed transport; their NIR, CLIF and machine-code tests read
  linux::sys::write / linux::sys::read, where the transport now is.
* **Constraints.** A test that makes syscalls only through the portable
  wrappers (`linux::write`, `linux::read`, `linux::io`, the examples) now
  carries `nativeLinux` and runs on both architectures (53 tests moved: the live writes and reads of abi-bytes and abi-mutable-bytes, the
  standalone hello worlds of contexts, portable-io and linux-path, the 2048
  demo, ...); `linuxX86_64` stays on tests that run the x86-64 transport
  or read x86-64 machine code (objdump, strace's stack frames, R_X86_64
  relocations), and `linuxAarch64` is new for the AArch64 transport's live
  and machine-code tests. A test that only compiles a transport (NIR, CLIF,
  a contract diagnostic) carries no host constraint and names its target
  (`-target linux-x86_64`) when it compiles through linux::sys; so do the
  native tests of no syscall at all that once carried `linuxX86_64` (NIR of
  error identities and static blocks, ABI-value allocations), and native
  code that needs Linux but no x86-64 (the golden runner's coroutines, the
  fuzzers' native and GC-stress checks, printing programs under main.tcl)
  carries `nativeLinux`. tests/golden/run.tcl knows `linux-aarch64` as a
  `golden-host`, and abi-bytes-native.bot, whose writes go through
  linux::write, declares no host any more.
* **Rust unit tests** (native/src/runtime/syscall.rs): the
  architecture-neutral ones on every target (register words, the signed
  reading, ABI encodings, TYPE before any transition for both helpers, the
  other architecture's helper is NATIVE UNSUPPORTED) and the live ones
  (getpid, write to a pipe, EBADF, a collection between taking the address
  and the call) against the host's own boundary, with its own numbers.

## Single-file compiler on AArch64: what it needs

The single executable (SINGLE-EXECUTABLE.md) is x86-64 only today. Its
parts, checked one by one for AArch64:

| part | on AArch64 |
|---|---|
| static Tcl 9.0.1 base kit (single/build.sh: `configure --disable-shared --enable-zipfs`, bundled zlib and libtommath) | architecture-neutral source build; nothing to change |
| single/package.tcl, single/main.tcl | architecture-neutral (paths, zipfs, the per-build cache directory); nothing to change |
| `botlish-native` (interp, compile, cranelift, cranelift-generic) | runs on AArch64 since the native port, JIT included |
| programs that print (`linux::io`, the smoke test's hello worlds) | needed this milestone's AArch64 transport; work now |
| `-emit-native-executable` | **blocked: the `stub` linker is x86-64 only**, and the single executable has no rustc to fall back on |
| CI (.github/workflows/single-executable.yml) | needs an `ubuntu-24.04-arm` build job and arm64 smoke containers, a `botlish-linux-aarch64` artifact, and `runner.arch` in the base-kit cache key (today `runner.os` only, which x86-64 and arm64 runners share) |

So the stub linker is the one real piece of work, and it is smaller on
AArch64 than it was on x86-64. Every relocation in the Cranelift objects
native/src/codegen/aot.rs's `emit_object` writes for AArch64 is one of three
kinds (14,592 relocations counted over twelve programs -- examples/io/hello.bot,
examples/linux/getpid.bot, examples/stdlib/csv.bot,
examples/surface/02-recursion.bot and the golden suites contexts,
coroutines, closure-escape, loops, binary-layout, values, ownership and
errors -- compiled by the AArch64 driver under qemu):

* `R_AARCH64_CALL26` -- a `bl` between two Botlish functions of the object:
  resolved when the image is laid out, like x86-64's local `PC32`/`PLT32`;
* `R_AARCH64_ADR_GOT_PAGE` + `R_AARCH64_LD64_GOT_LO12_NC` -- an `adrp`/`ldr`
  pair loading an address from the GOT: a runtime helper's (the generated
  code calls helpers indirectly on AArch64; codegen::clif's direct_helpers
  is x86-64 only), the context area's or a function entry's. The image
  builder gives each target a GOT slot in the image's data, patches the
  pair's page and low-12 fields at layout (the image base is page-aligned,
  so page differences are known), and leaves the slot an `Abs64` fixup.

The objects' only allocated sections are `.text` and `.bss`. So an AArch64
`image` needs those three relocation types (`R_AARCH64_ABS64` for a data
word too, should a later object carry one; every other type rejected, as
today);
the stub's loader needs no `Call32` trampolines and no `map_near` -- it
patches only GOT data words -- but must make the instruction cache coherent
after writing the code (clean to the point of unification, invalidate,
`isb`), which x86-64 never needed; `codegen::aot::link_stub`'s x86-64 guard
and aotimage's `cfg`s widen to AArch64; tests/aot-stub-linker.test's
`stubLinker` constraint and CI's `stub-linker` job extend to arm64. With
that, the arm64 single executable is a matrix entry of the existing
workflow.
