# native-status.tcl -- what the native backend does on this host, against
# what it is recorded to do (MACOS-AARCH64-PORT-AUDIT.md, "Native status").
#
#   tclsh9.0 tests/platform/native-status.tcl ?-verbose 0|1?
#
# Runs one small probe per native capability -- the JIT, the GC's frame walk
# under stress, a native stack overflow (of the thread's stack and of a
# coroutine's), coroutines, a Linux syscall, a C call, a program object and
# a standalone executable -- and of the target boundary (the
# driver's reading of the host target's triple, the C calling convention of
# a foreign signature, a program built for the other operating system of the
# host's architecture) and compares each outcome with the expectation
# recorded below for the host target (core::cabi::hostTarget).
# On Linux every capability is supported. On macOS arm64 some are not yet,
# and the expectation is the explicit refusal they fail with today: a
# capability that starts working (or fails differently) after a port
# milestone fails this check until its expectation is updated here, in the
# same change. A probe that kills the driver is recorded as such, never
# hidden. Prints a table of probe, expected and observed; exits 1 on any
# difference or on a host with no recorded expectations. Needs the native
# backend built (cargo build --release --manifest-path native/Cargo.toml).

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname $here]]
source [file join $root native native.tcl]
source [file join $root tests binary-header.tcl]

set verbose 0
foreach {option value} $argv {
    switch -- $option {
        -verbose { set verbose $value }
        default {
            puts stderr "usage: tclsh9.0 tests/platform/native-status.tcl ?-verbose 0|1?"
            exit 2
        }
    }
}

# The probes: NAME {KIND ARGUMENT ENVIRONMENT}. KIND driver runs
# botlish-native on a NIR fixture of native/tests/fixtures; program runs a
# Botlish program with native::evalHir; object writes its program object
# (native::object) and reports the object's header {FORMAT ARCHITECTURE
# KIND} (tests/binary-header.tcl); executable links it with
# native::executable, runs the executable and reports its header and the
# value it prints; target asks the driver how it
# reads the host target's triple (botlish-native target TRIPLE: its object
# format, C calling convention and whether code for it runs here);
# convention compiles the program to CLIF (native::clif: no C call runs) and
# reports the calling convention of each foreign C signature; other-target
# runs the program built for the other operating system's target of this
# host's architecture (macos-aarch64 on linux-aarch64, linux-aarch64 on
# macos-aarch64).
set fixtures [file join $root native tests fixtures]
set probes [dict create \
    jit [list program {fn fib(n):
    if n <= 1:
        return n

    fib(n - 1) + fib(n - 2)

fib(20)
} {}] \
    gc-frame-walk [list driver build400.nir {BOTLISH_NATIVE_GC_STRESS 1}] \
    stack-overflow [list driver stack_overflow.ir {BOTLISH_NATIVE_STACK_BYTES 4194304}] \
    coroutine-stack-overflow [list program {struct Event:
    value: int

fn down(n: int) -> int:
    if n == 0:
        return 0

    1 + down(n - 1)

fn worker(depth: int) -> Event:
    yield Event {value: 0}
    return Event {value: down(depth)}

coroutine {step, first} = worker(100000000)
step().value
} {}] \
    coroutine [list program {struct Message:
    value: int

struct Event:
    value: int

fn worker(base: int, resume Message) -> Event:
    message = yield Event {value: base}
    return Event {value: message.value}

coroutine {step, first} = worker(10)
second = step(Message {value: 7})
[first.value, second.value]
} {}] \
    linux-syscall [list program {direct module
import abi
import abi::bytes
import linux

# A zero-byte write(2) to standard output through linux::sys, the host
# architecture's transport: 0 bytes written.
linux::write(abi::i32(1), abi::bytes::from_list([]))
} {}] \
    c-call [list program {import ffi::c

extern c fn labs(x: ffi::c::Long) -> ffi::c::Long

labs(-5)
} {}] \
    object [list object {fn fib(n):
    if n <= 1:
        return n

    fib(n - 1) + fib(n - 2)

fib(20)
} {}] \
    executable [list executable {fn fib(n):
    if n <= 1:
        return n

    fib(n - 1) + fib(n - 2)

fib(20)
} {}] \
    target [list target {} {}] \
    c-convention [list convention {import ffi::c

extern c fn labs(x: ffi::c::Long) -> ffi::c::Long
extern c fn abs(x: ffi::c::SChar) -> ffi::c::Int

labs(-5) + abs(-3)
} {}] \
    other-target [list other-target {import ffi::c

fn f(x: ffi::c::Char) -> int:
    x

f(1)
} {}]]

# The recorded outcomes: HOST-TARGET -> NAME -> {value TEXT} (exactly) or
# {error CODE MESSAGE-GLOB}. A program object is the host's object format
# and architecture everywhere, and so is a standalone executable, which
# prints its value: on macos-aarch64 a Mach-O executable since milestone 5
# (MACOS-AARCH64-MILESTONE-5.md), where until then emission was refused
# (`executable emission requires Linux glibc on x86_64 or aarch64 (NATIVE
# AOT)`). A C call is linked on Linux only: on macos-aarch64 it is still
# refused before the linker runs (NATIVE LINK), now with its own reason
# rather than the executable refusal. A native stack overflow is NATIVE LIMIT STACK on
# every host, the thread's stack and a coroutine's alike: on macos-aarch64
# since milestone 4 (MACOS-AARCH64-MILESTONE-4.md), where until then the
# driver died in Rust's stack-overflow abort (the thread's stack) or of
# SIGBUS (a coroutine's).
#
# Since milestone 2 (MACOS-AARCH64-MILESTONE-2.md) a program importing a
# Linux namespace does not compile for macos-aarch64 at all
# (UNSUPPORTED-PLATFORM), where it used to compile with Linux's
# lib/linux/sys.aarch64.bot and fail at run time; the target, convention
# and other-target probes record the target boundary.
set linux [dict create \
    jit {value 6765} \
    gc-frame-walk [list value [list str [string repeat xy 400]]] \
    stack-overflow {error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}} \
    coroutine-stack-overflow {error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}} \
    coroutine {value {[10, 7]}} \
    linux-syscall {value 0} \
    c-call {value 5} \
    target {value {format elf c-call-conv system_v runs 1}} \
    c-convention {value {labs system_v abs system_v}} \
    other-target {error {NATIVE TARGET} {this program was built for target macos-* and native code runs only on its own target's host*matching architecture is not a matching target*}}]
set expected [dict create \
    linux-x86_64 [dict merge $linux {
        object {value {elf x86_64 relocatable}}
        executable {value {{elf x86_64 shared} 6765}}
    }] \
    linux-aarch64 [dict merge $linux {
        object {value {elf aarch64 relocatable}}
        executable {value {{elf aarch64 shared} 6765}}
    }] \
    macos-aarch64 [dict create \
        jit {value 6765} \
        gc-frame-walk [list value [list str [string repeat xy 400]]] \
        stack-overflow {error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}} \
        coroutine-stack-overflow {error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}} \
        coroutine {value {[10, 7]}} \
        linux-syscall {error {SURFACE MODULE UNSUPPORTED-PLATFORM} {*namespace "linux" belongs to the Linux platform*unavailable for target macos-aarch64 (macOS on aarch64)*}} \
        c-call {error {NATIVE LINK} {*this program calls C or declares a C library*C calls are linked on Linux glibc only*}} \
        object {value {macho arm64 object}} \
        executable {value {{macho arm64 execute} 6765}} \
        target {value {format macho c-call-conv apple_aarch64 runs 1}} \
        c-convention {value {labs apple_aarch64 abs apple_aarch64}} \
        other-target {error {NATIVE TARGET} {this program was built for target linux-aarch64 (aarch64-unknown-linux-gnu)*Both are aarch64, but a matching architecture is not a matching target*}}]]

# The outcome of running SCRIPT with ENVIRONMENT ({NAME VALUE ...}) set:
# {value TEXT} or {error CODE MESSAGE}.
proc outcome {environment script} {
    set saved {}
    foreach {name value} $environment {
        lappend saved $name [expr {[info exists ::env($name)] ? [list $::env($name)] : {}}]
        set ::env($name) $value
    }
    try {
        set code [catch {uplevel 1 $script} result options]
    } finally {
        foreach {name value} $saved {
            if {$value eq {}} { unset ::env($name) } else { set ::env($name) [lindex $value 0] }
        }
    }
    if {$code == 0} {
        return [list value $result]
    }
    set errorCode [dict get $options -errorcode]
    if {[lindex $errorCode 0] eq "NATIVE"} {
        return [list error [lrange $errorCode 0 2] $result]
    }
    return [list error $errorCode $result]
}

# The observed outcome of probe NAME.
proc observe {name} {
    global probes fixtures
    lassign [dict get $probes $name] kind argument environment
    switch -- $kind {
        driver {
            return [outcome $environment {
                lindex [native::Outcome [native::Driver run [core::ReadFile [file join $fixtures $argument]]]]
            }]
        }
        program {
            return [outcome $environment {
                core::formatValue [native::evalHir [surface::compile $argument -warnings off]]
            }]
        }
        target {
            return [outcome $environment {
                dict filter [native::targetFacts [dict get [core::cabi::target [core::cabi::hostTarget]] triple]] \
                    key format c-call-conv runs
            }]
        }
        convention {
            return [outcome $environment {
                foreignConventions [native::clif [surface::compile $argument -warnings off]]
            }]
        }
        other-target {
            set host [dict get [core::cabi::target [core::cabi::hostTarget]] os]
            set other [expr {$host eq "linux" ? "macos" : "linux"}]-[core::cabi::hostArchitecture]
            return [outcome $environment {
                core::formatValue [native::evalHir [surface::compile $argument -warnings off -target $other]]
            }]
        }
        object {
            set work [file tempdir botlish-native-status]
            try {
                return [outcome $environment {
                    set path [file join $work probe.o]
                    native::object [surface::compile $argument -warnings off] $path
                    binaryHeader $path
                }]
            } finally {
                file delete -force $work
            }
        }
        executable {
            set work [file tempdir botlish-native-status]
            try {
                return [outcome $environment {
                    set path [native::executable [surface::compile $argument -warnings off] [file join $work probe]]
                    list [binaryHeader $path] [string trim [exec $path]]
                }]
            } finally {
                file delete -force $work
            }
        }
    }
}

# {SYMBOL CONVENTION ...}: the calling convention of every foreign C
# function's signature in the CLIF text CLIF (`; u0:N = NAME (C SYMBOL)`,
# then a function's `fnK = u0:N sigM` and its `sigM = (...) -> ... CONV`).
proc foreignConventions {clif} {
    set symbols [dict create]
    foreach {- ref symbol} [regexp -all -inline -line {^; (u0:[0-9]+) = \S+ \(C (\S+)\)$} $clif] {
        dict set symbols $ref $symbol
    }
    set result [dict create]
    foreach function [split [string map [list "\n\}\n" \x00] $clif] \x00] {
        set sigs [dict create]
        foreach {- sig conv} [regexp -all -inline -line {^\s+(sig[0-9]+) = .* (\S+)$} $function] {
            dict set sigs $sig $conv
        }
        foreach {- ref sig} [regexp -all -inline -line {^\s+fn[0-9]+ = (?:colocated )?(u0:[0-9]+) (sig[0-9]+)$} $function] {
            if {[dict exists $symbols $ref] && [dict exists $sigs $sig]} {
                dict set result [dict get $symbols $ref] [dict get $sigs $sig]
            }
        }
    }
    return $result
}

proc matches {expectation observed} {
    if {[lindex $expectation 0] ne [lindex $observed 0]} {
        return 0
    }
    if {[lindex $expectation 0] eq "value"} {
        return [expr {[lindex $expectation 1] eq [lindex $observed 1]}]
    }
    return [expr {[lindex $expectation 1] eq [lindex $observed 1]
        && [string match [lindex $expectation 2] [lindex $observed 2]]}]
}

# A probe's outcome for the table: at most one line, and no more than 100
# characters of it.
proc brief {outcome} {
    set text [join $outcome " "]
    set text [lindex [split $text \n] 0]
    if {[string length $text] > 100} { set text "[string range $text 0 96]..." }
    return $text
}

set host [core::cabi::hostTarget]
if {![dict exists $expected $host]} {
    puts "FAIL: no native expectations recorded for host target \"$host\" ($::tcl_platform(os) $::tcl_platform(machine))"
    exit 1
}
puts "native status on $host ($::tcl_platform(os) $::tcl_platform(machine)), driver [native::binary]"
set differences 0
dict for {name expectation} [dict get $expected $host] {
    set observed [observe $name]
    set ok [matches $expectation $observed]
    if {!$ok} { incr differences }
    puts [format "%-4s %-15s expected: %s" [expr {$ok ? "ok" : "FAIL"}] $name [brief $expectation]]
    if {!$ok || $verbose} {
        puts [format "%-4s %-15s observed: %s" "" "" [brief $observed]]
        if {!$ok} {
            puts "     full observed outcome:\n[join [lmap line [split [join $observed { }] \n] {string cat {       } $line}] \n]"
        }
    }
}
if {$differences} {
    puts "FAIL: $differences native capabilities do not behave as recorded for $host: if a port milestone changed one on purpose, record its new outcome in tests/platform/native-status.tcl (and MACOS-AARCH64-PORT-AUDIT.md)"
    exit 1
}
puts "ok: every native capability behaves as recorded for $host"
