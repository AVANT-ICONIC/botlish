# probe.tcl -- the Windows toolchain census's probe (WINDOWS-TOOLCHAIN-CENSUS.md)
#
#   tclsh probe.tcl -out DIR ?-lib LABEL=DIR?... ?-target NAME? ?-timeout SECONDS?
#
# Runs the census's checks on this host through main.tcl and the native
# driver, exactly as a user would, and prints one line per check:
#
#   PROBE NAME PASS|FAIL|TIMEOUT|SKIP DETAIL
#
# with each check's whole output in DIR/NAME.log and the objects and
# executables it made in DIR. The same script is the Linux control (run it
# with a Linux driver) and the Windows probe (.github/workflows/
# windows-probe.yml runs it with a driver built by MSVC's and by MinGW-w64's
# Rust toolchain, each patched by audit/windows-toolchain/probe.patch: the
# unpatched driver does not compile for Windows).
#
#   -lib LABEL=DIR   a directory holding the probe's C library bwp
#                    (programs/bwp.c) built some way: a static library or a
#                    DLL's import library; DIR is also put on PATH, where
#                    Windows finds a DLL. The FFI checks run once per -lib.
#   -target NAME     main.tcl's -target for the programs that call C (the
#                    default is the host's: windows-x86_64, MSVC's, on any
#                    Windows host).
#   -timeout S       per check (default 600): a check that hangs is killed
#                    and reported TIMEOUT.
#
# The checks: the host and the driver's view of the Windows triples; a pure
# program on interp, compile and cranelift; two allocation-heavy programs on
# cranelift, also under BOTLISH_NATIVE_GC_STRESS=1 (on Windows also with
# the probe patch's root plans: BOTLISH_PROBE_SHADOW=1, with
# BOTLISH_PROBE_NO_WALK=1, and BOTLISH_PROBE_ALL_SHADOW=1); a program object and a standalone executable
# of the pure program (on Windows also with the C runtime linked
# statically, BOTLISH_PROBE_CRT_STATIC=1); the C ABI program
# (programs/ffi-probe.bot) through every -lib, JIT-run and as an
# executable; the Win32 program (programs/win32.bot) on Windows.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set programs [file join [file dirname $here] programs]

set out ""
set libs {}
set target ""
set timeout 600
foreach {option value} $argv {
    switch -- $option {
        -out { set out [file normalize $value] }
        -lib { lappend libs {*}[split $value =] }
        -target { set target $value }
        -timeout { set timeout $value }
        default { puts stderr "probe.tcl: unknown option $option"; exit 2 }
    }
}
if {$out eq ""} {
    puts stderr "usage: tclsh probe.tcl -out DIR ?-lib LABEL=DIR?... ?-target NAME? ?-timeout SECONDS?"
    exit 2
}
file mkdir $out
set windows [expr {$::tcl_platform(platform) eq "windows"}]
set failures 0

source [file join $root compiler compiler.tcl]
source [file join $root native native.tcl]

# Runs CMD (a list) with the extra environment ENV (a dict), at most
# $::timeout seconds. Returns {STATUS OUTPUT}: STATUS is ok, exit N or
# timeout; OUTPUT is standard output and error together.
proc run {cmd {env {}}} {
    set saved {}
    foreach {name value} $env {
        lappend saved $name [expr {[info exists ::env($name)] ? [list $::env($name)] : {}}]
        set ::env($name) $value
    }
    try {
        set chan [open |[concat $cmd [list 2>@1]] r]
    } finally {
        foreach {name value} $saved {
            if {$value eq ""} { unset -nocomplain ::env($name) } else { set ::env($name) [lindex $value 0] }
        }
    }
    fconfigure $chan -blocking 0 -encoding utf-8 -profile replace
    set ::buffer($chan) ""
    set ::state($chan) running
    fileevent $chan readable [list apply {{chan} {
        append ::buffer($chan) [read $chan]
        if {[eof $chan]} { set ::state($chan) done }
    }} $chan]
    set timer [after [expr {$::timeout * 1000}] [list set ::state($chan) timeout]]
    vwait ::state($chan)
    after cancel $timer
    set output $::buffer($chan)
    set status ok
    if {$::state($chan) eq "timeout"} {
        foreach p [pid $chan] {
            if {$::windows} { catch {exec taskkill /F /T /PID $p} } else { catch {exec kill -9 $p} }
        }
        set status timeout
    }
    fconfigure $chan -blocking 1
    if {[catch {close $chan} message options] && $status eq "ok"} {
        set code [lindex [dict get $options -errorcode] 0]
        set status [expr {$code eq "CHILDSTATUS" ? "exit [lindex [dict get $options -errorcode] 2]" : "error $message"}]
    }
    unset ::buffer($chan) ::state($chan)
    return [list $status $output]
}

# Records check NAME: PASS when RESULT's output contains every one of
# EXPECTED (and RESULT's status is ok), otherwise FAIL (TIMEOUT for a hang).
proc report {name result expected} {
    lassign $result status output
    set f [open [file join $::out $name.log] w]
    puts $f "status: $status"
    puts -nonewline $f $output
    close $f
    set verdict PASS
    if {$status eq "timeout"} {
        set verdict TIMEOUT
    } else {
        foreach text $expected {
            if {[string first $text $output] < 0} { set verdict FAIL }
        }
        if {$status ne "ok"} { set verdict FAIL }
    }
    if {$verdict ne "PASS"} { incr ::failures }
    set lines [lmap line [split [string trim $output] \n] {string trim $line}]
    set detail [lsearch -inline -regexp $lines {value:|error|executable:|^\[|^value }]
    if {$detail eq ""} { set detail [lindex $lines end] }
    puts "PROBE $name $verdict \[$status\] [string range $detail 0 220]"
    flush stdout
}

proc skip {name why} {
    puts "PROBE $name SKIP $why"
}

proc main.tcl {args} {
    return [concat [list [info nameofexecutable] [file join $::root main.tcl]] $args]
}

# --- The host.
set host [core::cabi::hostTarget]
puts "PROBE host INFO os=$::tcl_platform(os) machine=$::tcl_platform(machine) encoding=[encoding system] tcl=[info patchlevel] hostTarget=$host"
if {[catch {native::binary} driver]} {
    puts "PROBE driver FAIL $driver"
    exit 1
}
puts "PROBE driver INFO $driver"
foreach triple {x86_64-pc-windows-msvc x86_64-pc-windows-gnu x86_64-unknown-linux-gnu} {
    if {[catch {native::targetFacts $triple} facts]} {
        puts "PROBE triple-$triple FAIL $facts"
    } else {
        puts "PROBE triple-$triple INFO $facts"
    }
}

# --- A pure program on every backend.
set fib [file join $programs fib.bot]
foreach backend {interp compile cranelift cranelift-generic} {
    report fib-$backend [run [main.tcl -backend $backend $fib]] {{value: [75025, "hello", 18446744073709551614]}}
}

# --- Allocation-heavy programs, also under GC stress.
set heavy [list uri [file join $root bench uri-steady.bot] {value: 29500} \
    2048 [file join $root examples games 2048 bench.bot] {value: 2002720} \
    fib $fib {value: [75025, "hello", 18446744073709551614]}]
foreach {name path expected} $heavy {
    if {$name ne "fib"} {
        report $name-cranelift [run [main.tcl -backend cranelift -warnings off $path]] [list $expected]
    }
    report $name-gcstress [run [main.tcl -backend cranelift -warnings off $path] {BOTLISH_NATIVE_GC_STRESS 1}] [list $expected]
    if {$windows} {
        # The probe patch's root plans (probe.patch, clif.rs, roots.rs): the
        # fallback plan, every root on the shadow stack with no frame walk,
        # and the fallback plan with no frame walk.
        report $name-gcstress-shadow [run [main.tcl -backend cranelift -warnings off $path] \
            {BOTLISH_NATIVE_GC_STRESS 1 BOTLISH_PROBE_SHADOW 1}] [list $expected]
        report $name-gcstress-allshadow [run [main.tcl -backend cranelift -warnings off $path] \
            {BOTLISH_NATIVE_GC_STRESS 1 BOTLISH_PROBE_ALL_SHADOW 1}] [list $expected]
        report $name-gcstress-shadow-nowalk [run [main.tcl -backend cranelift -warnings off $path] \
            {BOTLISH_NATIVE_GC_STRESS 1 BOTLISH_PROBE_SHADOW 1 BOTLISH_PROBE_NO_WALK 1}] [list $expected]
    }
}

# --- A program object and a standalone executable of the pure program.
set hir [surface::readProgramFile $fib -warnings off]
set object [file join $out fib[expr {$windows ? ".obj" : ".o"}]]
if {[catch {native::object $hir $object} message]} {
    report object [list "error $message" ""] {}
} else {
    set f [open $object rb]
    binary scan [read $f 4] cu4 magic
    close $f
    set format [expr {[lrange $magic 0 1] eq {100 134} ? "COFF x86-64 (0x8664)" :
        [lrange $magic 0 1] eq {127 69} ? "ELF" : "unknown ($magic)"}]
    report object [list ok "object $object: $format"] [list [expr {$windows ? "COFF x86-64" : "ELF"}]]
}
set exeDir [file join $out exe]
file delete -force $exeDir
file mkdir $exeDir
file copy $fib $exeDir
set result [run [main.tcl -warnings off -emit-native-executable [file join $exeDir fib.bot]]]
report fib-emit-executable $result {executable:}
puts "PROBE fib-emit-executable-files INFO [lsort [glob -nocomplain -tails -directory $exeDir *]]"
set made [file join $exeDir fib]
foreach candidate [list $made $made.exe] {
    if {[file exists $candidate]} {
        report fib-executable-run-[file tail $candidate] [run [list $candidate]] {{[75025, "hello", 18446744073709551614]}}
    }
}

# The same executable with the C runtime linked statically (the probe
# patch's BOTLISH_PROBE_CRT_STATIC=1).
if {$windows} {
    set exeDir [file join $out exe-static]
    file delete -force $exeDir
    file mkdir $exeDir
    file copy $fib $exeDir
    report fib-emit-executable-crt-static [run [main.tcl -warnings off -emit-native-executable [file join $exeDir fib.bot]] \
        {BOTLISH_PROBE_CRT_STATIC 1}] {executable:}
    foreach candidate [glob -nocomplain -directory $exeDir fib fib.exe] {
        report fib-executable-crt-static-run-[file tail $candidate] [run [list $candidate]] {{[75025, "hello", 18446744073709551614]}}
    }
}

# --- The C ABI program through each build of the probe's C library.
set ffi [file join $programs ffi-probe.bot]
set expectedAbi [expr {$windows ? {[42, 4, 8, 2, -5, 342.0, 385, -56, 10, 34]} : {[42, 8, 8, 4, -5, 342.0, 385, -56, 10, 34]}}]
set targetOption [expr {$target eq "" ? {} : [list -target $target]}]
set separator [expr {$windows ? ";" : ":"}]
foreach {label dir} $libs {
    set dir [file normalize $dir]
    set pathEnv [list PATH "[file nativename $dir]$separator$::env(PATH)"]
    report ffi-$label-jit [run [main.tcl -backend cranelift -warnings off {*}$targetOption -L $dir $ffi] $pathEnv] [list "value: $expectedAbi"]
    set exeDir [file join $out ffi-$label]
    file delete -force $exeDir
    file mkdir $exeDir
    file copy $ffi $exeDir
    report ffi-$label-emit [run [main.tcl -warnings off {*}$targetOption -L $dir -emit-native-executable [file join $exeDir ffi-probe.bot]] $pathEnv] {executable:}
    foreach candidate [list [file join $exeDir ffi-probe] [file join $exeDir ffi-probe.exe]] {
        if {[file exists $candidate]} {
            report ffi-$label-run-[file tail $candidate] [run [list $candidate] $pathEnv] [list $expectedAbi]
        }
    }
}

# --- Win32 straight from Botlish: kernel32's console output, no C runtime.
if {$windows} {
    set win32 [file join $programs win32.bot]
    report win32-jit [run [main.tcl -backend cranelift -warnings off {*}$targetOption $win32]] {{hello from kernel32} {value: [true, 1]}}
    set exeDir [file join $out win32]
    file delete -force $exeDir
    file mkdir $exeDir
    file copy $win32 $exeDir
    report win32-emit [run [main.tcl -warnings off {*}$targetOption -emit-native-executable [file join $exeDir win32.bot]]] {executable:}
    foreach candidate [list [file join $exeDir win32] [file join $exeDir win32.exe]] {
        if {[file exists $candidate]} {
            report win32-run-[file tail $candidate] [run [list $candidate]] {{hello from kernel32} {[true, 1]}}
        }
    }
} else {
    skip win32 "not a Windows host"
}

puts "PROBE done $failures failing"
exit [expr {$failures > 0}]
