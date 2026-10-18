# cabi-facts.tcl -- checks core/cabi.tcl's row for the host target against
# the host C compiler (C-ABI-TYPES.md; MACOS-AARCH64-PORT-AUDIT.md).
#
#   tclsh9.0 tests/platform/cabi-facts.tcl ?-cc COMPILER?
#
# Compiles and runs tests/platform/cabi-facts.c with COMPILER (default $CC,
# else cc) in a private temporary directory, and compares what it prints --
# the bit widths of char, short, int, long, long long and a pointer, and
# whether plain char is signed -- with core::cabi::target of
# core::cabi::hostTarget, the row a compilation for this host uses when it
# imports ffi::c. Prints both and exits 1 on any difference, or when the host
# is not one of the table's targets. It reads the table; it changes nothing.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname $here]]
source [file join $root core core.tcl]

set cc [expr {[info exists ::env(CC)] && $::env(CC) ne "" ? $::env(CC) : "cc"}]
foreach {option value} $argv {
    switch -- $option {
        -cc { set cc $value }
        default {
            puts stderr "usage: tclsh9.0 tests/platform/cabi-facts.tcl ?-cc COMPILER?"
            exit 2
        }
    }
}

set host [core::cabi::hostTarget]
if {$host eq ""} {
    puts "FAIL: this host ($::tcl_platform(os) $::tcl_platform(machine)) is none of core::cabi's targets: [join [core::cabi::targetNames] {, }]"
    exit 1
}
set table [core::cabi::target $host]

set work [file tempdir botlish-cabi-facts]
try {
    set program [file join $work cabi-facts]
    exec $cc -o $program [file join $here cabi-facts.c] 2>@ stderr
    set measured [exec $program]
} finally {
    file delete -force $work
}

puts "host target:   $host ($::tcl_platform(os) $::tcl_platform(machine))"
puts "C compiler:    $cc"
puts "core::cabi:    [dict filter $table key char short int long longlong pointer charSigned]"
puts "C toolchain:   $measured"
set differences {}
dict for {key value} $measured {
    if {![dict exists $table $key] || [dict get $table $key] ne $value} {
        lappend differences "$key: table [expr {[dict exists $table $key] ? [dict get $table $key] : {(none)}}], C $value"
    }
}
if {$differences ne ""} {
    puts "FAIL: core::cabi's $host row disagrees with the C toolchain: [join $differences {; }]"
    exit 1
}
puts "ok: core::cabi's $host row agrees with the C toolchain"
