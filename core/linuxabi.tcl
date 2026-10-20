# linuxabi.tcl -- the raw Linux kernel transitions, one per architecture
# (LINUX-X86-64-SYSCALL.md, LINUX-SYSCALL-TRANSPORTS.md).
#
#   std::linux::abi::x86_64::syscall({rax: R, rdi: R, rsi: R, rdx: R, r10: R, r8: R, r9: R})
#       -> std::abi::x86_64::Register64        R: std::abi::x86_64::Register64
#   std::linux::abi::aarch64::syscall({x8: R, x0: R, x1: R, x2: R, x3: R, x4: R, x5: R})
#       -> std::abi::aarch64::Register64       R: std::abi::aarch64::Register64
#
# Each is one root native, registered under its qualified name (no module
# file defines it: surface/modules.tcl and surface/lower.tcl resolve a
# qualified native name to a root reference), and each is a *transport*: the
# one genuinely machine/OS-specific operation Botlish exposes for its
# architecture. It executes that architecture's syscall instruction with the
# given register contents and returns the result register.
#
# The argument is a syscall-input description, not an inline assembly API:
# an anonymous struct whose fields are named after the architecture's Linux
# syscall register convention and are that architecture's Register64 values
# (stdlib/abi/x86_64.bot, stdlib/abi/aarch64.bot):
#
#   x86-64   rax the number, rdi rsi rdx r10 r8 r9 arguments 1-6,
#            `syscall`, the result in rax
#   AArch64  x8 the number,  x0 x1 x2 x3 x4 x5 arguments 1-6,
#            `svc #0`, the result in x0
#
# The number register is required; an omitted argument register is zero.
# Any other field is rejected (hir/syscall.tcl: UNKNOWN-FIELD), and so is a
# missing number register (MISSING-FIELD) or a field that is not the
# transport's own Register64 (TYPE: a std::abi::aarch64::Register64 is never an
# x86-64 register). The result is the raw result register after the
# transition, as a Register64: no errno, no -1 convention, no retry, no
# Result -- the kernel's own return value, nothing above it.
#
# A transport knows its architecture's Linux *transport* convention (which
# register carries what) and nothing about individual syscalls: no syscall
# number, argument meaning or signature is known to the compiler. getpid is
# `rax: std::abi::x86_64::register64(39)` on x86-64 and `x8:
# std::abi::aarch64::register64(172)` on AArch64, in ordinary Botlish
# (stdlib/linux/sys.x86_64.bot, stdlib/linux/sys.aarch64.bot: the architecture's
# syscall numbers are source data of the library the compilation target
# selects).
#
# Effects: maximally conservative, by the registry's own defaults and by
# being in no allowlist anywhere (CLOSED-CALL-EFFECTS.md, M6's "condition
# purity" and EXACT-VALUE-FACTS.md all name natives explicitly): never
# context-free (a module binding cannot be initialized with it: MODULE-
# CONTEXT), never exact-value-folded, never decided, never merged, never
# removed when its result is unused, never reordered; natively it is a
# helper *call* (native/src/runtime/syscall.rs), which Cranelift treats as
# reading and writing all memory.
#
# Backends: only the native backend performs it (cranelift, cranelift-
# generic, standalone executables), and only on its own architecture: every
# transport compiles on every target, and running one on another
# architecture fails with NATIVE UNSUPPORTED. The Tcl backends (interp,
# compile) cannot execute a machine instruction and do not imitate one with
# some other host facility (a Tcl `pid` would test the wrong abstraction): a
# call raises the semantic error NATIVE-ONLY when it runs. Only the call is
# refused -- a program that defines but never calls it, and every pure
# std::abi::x86_64 / std::abi::aarch64 conversion, runs on every backend.

namespace eval core::linuxabi {
    # ARCH -> the transport of the Linux syscall convention of architecture
    # ARCH (core/cabi.tcl's target `arch`):
    #   native        the root native's qualified name
    #   registers     the register fields its argument may name, in the
    #                 convention's own order: the number register first,
    #                 then arguments 1-6
    #   abi           the namespace of its register type, conversions and
    #                 address bridges (stdlib/abi/x86_64.bot, stdlib/abi/aarch64.bot)
    #   registerType  the struct declaration identity of one register word
    #   op            the NIR op it lowers to (native/src/nir.rs)
    #   instruction   the machine instruction its boundary executes
    #   label         the architecture, as messages name it
    variable transports [dict create \
        x86_64 {
            native std::linux::abi::x86_64::syscall
            registers {rax rdi rsi rdx r10 r8 r9}
            abi std::abi::x86_64
            registerType std::abi::x86_64::Register64
            op syscall_linux_x86_64
            instruction syscall
            label x86-64
        } \
        aarch64 {
            native std::linux::abi::aarch64::syscall
            registers {x8 x0 x1 x2 x3 x4 x5}
            abi std::abi::aarch64
            registerType std::abi::aarch64::Register64
            op syscall_linux_aarch64
            instruction {svc #0}
            label AArch64
        }]
}

# The architectures that have a transport, in table order.
proc core::linuxabi::architectures {} {
    variable transports
    return [dict keys $transports]
}

# The architecture whose transport native NAME is, or "" if NAME is none.
proc core::linuxabi::transportOf {name} {
    variable transports
    dict for {arch transport} $transports {
        if {[dict get $transport native] eq $name} {
            return $arch
        }
    }
    return ""
}

# 1 if NAME is the qualified name of a syscall transport native.
proc core::linuxabi::isSyscall {name} {
    return [expr {[transportOf $name] ne ""}]
}

# Field FIELD (native registers abi registerType op instruction label) of the
# transport of architecture ARCH.
proc core::linuxabi::transport {arch field} {
    variable transports
    return [dict get $transports $arch $field]
}

# The register fields the argument of transport native NAME may name, in
# its convention's order (the number register first).
proc core::linuxabi::registers {name} {
    return [transport [transportOf $name] registers]
}

# The Register64 declaration identity transport native NAME takes and
# returns.
proc core::linuxabi::registerType {name} {
    return [transport [transportOf $name] registerType]
}

# Every transport's Register64 declaration identity, in table order.
proc core::linuxabi::registerTypes {} {
    return [lmap arch [architectures] {transport $arch registerType}]
}

proc core::linuxabi::syscallImpl {arch registers} {
    set label [transport $arch label]
    set instruction [transport $arch instruction]
    core::semanticError NATIVE-ONLY \
        "[transport $arch native] executes the $label \"$instruction\" instruction (a raw Linux kernel transition) and is performed only by the native backend (cranelift, or a standalone executable) on Linux $label; the Tcl backends (interp, compile) do not execute machine instructions and do not imitate a syscall"
}

foreach arch [core::linuxabi::architectures] {
    core::native::register [core::linuxabi::transport $arch native] -arity 1 \
        -impl [list core::linuxabi::syscallImpl $arch] \
        -param-types {struct} -result-type struct -runtime {raw-syscall} \
        -result-shape [list named-struct [core::linuxabi::transport $arch registerType]]
    # Each transport's namespace (std::linux::abi::x86_64, std::linux::abi::aarch64) is
    # a direct module (DIRECT-MODULES.md): the raw kernel transition is
    # ambient process authority, not yet a capability. A call into it is a
    # direct edge of the calling module, which either mediates it through a
    # context it defines itself or is declared `direct module` (std::linux::sys
    # is). The namespace is the smallest module boundary of raw syscall
    # authority: std::abi::x86_64's and std::abi::aarch64's register and address
    # conversions take no authority by themselves.
    core::native::declareDirectNamespace \
        [core::native::namespaceOf [core::linuxabi::transport $arch native]]
}
unset arch
