# binary-header.tcl -- what a native program object or executable file is,
# read from its header: for the tests (tests/helpers.tcl) and the macOS
# port's platform checks (tests/platform/native-status.tcl, aot-facts.tcl).
# Needs core::cabi (core/core.tcl) for hostBinaryHeader.

# {FORMAT ARCHITECTURE KIND} of the object or executable file PATH, read from
# its first bytes: FORMAT elf (64-bit little-endian) or macho (64-bit, one
# architecture), ARCHITECTURE x86_64, aarch64 (ELF's name) or arm64
# (Mach-O's), KIND relocatable, executable or shared (ELF; a PIE is shared)
# or object or execute (Mach-O); {unknown HEX {}} for anything else.
proc binaryHeader {path} {
    set channel [open $path rb]
    set bytes [read $channel 32]
    close $channel
    if {[string range $bytes 0 3] eq "\x7fELF"} {
        binary scan $bytes @4cc@16susu class data type machine
        set arch [expr {$machine == 62 ? "x86_64" : $machine == 183 ? "aarch64" : "machine$machine"}]
        set kind [expr {$type == 1 ? "relocatable" : $type == 2 ? "executable" : $type == 3 ? "shared" : "type$type"}]
        return [list [expr {$class == 2 && $data == 1 ? "elf" : "elf$class-$data"}] $arch $kind]
    }
    if {[binary scan $bytes iuiuiuiu magic cpu - type] == 4 && $magic == 0xfeedfacf} {
        set arch [expr {$cpu == 0x0100000c ? "arm64" : $cpu == 0x01000007 ? "x86_64" : "cpu$cpu"}]
        set kind [expr {$type == 1 ? "object" : $type == 2 ? "execute" : "type$type"}]
        return [list macho $arch $kind]
    }
    return [list unknown [binary encode hex [string range $bytes 0 3]] {}]
}

# What binaryHeader reports for this host's native program objects (KIND
# object) or standalone executables (KIND executable): the host target's
# object format and architecture.
proc hostBinaryHeader {kind} {
    switch -- [core::cabi::hostTarget] {
        linux-x86_64 { return [list elf x86_64 [expr {$kind eq "object" ? "relocatable" : "shared"}]] }
        linux-aarch64 { return [list elf aarch64 [expr {$kind eq "object" ? "relocatable" : "shared"}]] }
        macos-aarch64 { return [list macho arm64 [expr {$kind eq "object" ? "object" : "execute"}]] }
        default { return {} }
    }
}
