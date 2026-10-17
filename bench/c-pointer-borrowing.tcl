# c-pointer-borrowing.tcl -- what temporary foreign byte exposure costs
# natively (C-POINTER-BORROWING.md, "Performance").
#
#   tclsh9.0 bench/c-pointer-borrowing.tcl ?-runs N? ?-n N? ?-sizes LIST?
#
# Programs that each make N foreign calls of the borrow test fixture in a
# loop, reported as time per call, (program - baseline) / N, the baseline
# being the same loop without the call (bench/mutable-vector.tcl's method),
# for owners of each size S in SIZES:
#
#   raw       read(p, 0) with a null raw C pointer: the operation alone
#   read      read[UChar](data, 0) of an S-byte Bytes: + one read exposure
#             (bytesaddr, keepalive) -- expected flat in S
#   read m    the same of an S-byte MutableBytes
#   write     fill[UChar](m, 0, 0) of an S-byte MutableBytes, the result
#             discarded: + one write exposure (the detach: a fresh S-byte
#             storage and an S-byte copy, mbytesaddr, keepalive) --
#             expected linear in S
#   write+r   the same with the write-back result used (its struct and the
#             copy's wrapper)
#   linux     linux::read(-1, m) of an S-byte MutableBytes (EBADF: the
#             kernel returns at once): the syscall path's own detach and
#             exposure, for comparison (Linux x86-64 and AArch64)
#
# and the allocation counts of one call (Bytes, MutableBytes, Struct,
# List). Every number is best of RUNS in-process executions (cranelift,
# specialized), compilation excluded. The operation does no per-byte work
# (a count of 0): the bytes C would touch are its own cost, not the
# exposure's.

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
core::cabi::installBorrowFixture

set runs 5
set n 20000
set sizes {0 64 4096 65536}
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -n { set n $value }
        -sizes { set sizes $value }
        default { error "unknown option $option" }
    }
}
# linux::read's syscall: Linux x86-64 and AArch64 (each architecture's own
# transport, LINUX-SYSCALL-TRANSPORTS.md).
set linux [expr {$::tcl_platform(os) eq "Linux" && $::tcl_platform(machine) in {x86_64 amd64 aarch64}}]

set prelude "import abi\nimport abi::bytes\nimport ffi::c\nimport byte\nimport list\nimport ffi_fixture\n[expr {$linux ? "import linux\n" : ""}]
fn pattern(n: int):
    loop i from 0 to n:
        byte::from_int(mod(i, 256))

"

# The best time (microseconds) of the program BODY.
proc best {body} {
    set hir [surface::compile "$::prelude$body\n" -warnings off]
    lassign [native::measure $hir $::runs] lower compile best
    return $best
}

proc allocations {body} {
    set report [native::allocationReport [surface::compile "$::prelude$body\n" -warnings off] summary]
    lmap kind {Bytes MutableBytes Struct List} {
        expr {[dict exists $report byKind $kind] ? [dict get $report byKind $kind allocations] : 0}
    }
}

# NAME -> {SETUP CALL [DISCARDED]}: SETUP binds the owner (S its size), CALL
# is the foreign call; DISCARDED 1 makes it a statement.
set shapes [dict create \
    raw     {{p = ffi::c::null[ffi::c::UChar]()} {ffi_fixture::read(p, 0)} 0} \
    read    {{data = abi::bytes::from_list(pattern(S))} {ffi_fixture::read[ffi::c::UChar](data, 0)} 0} \
    {read m} {{m = abi::bytes::from_bytes(abi::bytes::from_list(pattern(S)))} {ffi_fixture::read[ffi::c::UChar](m, 0)} 0} \
    write   {{m = abi::bytes::from_bytes(abi::bytes::from_list(pattern(S)))} {ffi_fixture::fill[ffi::c::UChar](m, 0, 0)} 1} \
    write+r {{m = abi::bytes::from_bytes(abi::bytes::from_list(pattern(S)))} {abi::bytes::mutable_length(ffi_fixture::fill[ffi::c::UChar](m, 0, 0).out).value} 0}]
if {$linux} {
    dict set shapes linux {{m = abi::bytes::from_bytes(abi::bytes::from_list(pattern(S)))} {linux::read(abi::i32(-1), m).result} 0}
}

# The program of SETUP and a loop of N iterations whose body is BODY (or
# BODY then 0, when DISCARDED).
proc program {setup body discarded n} {
    set inner [expr {$discarded ? "$body\n        0" : $body}]
    return "fn f() -> int:\n    $setup\n    xs = loop i from 0 to $n:\n        $inner\n    list::length(xs)\n\nf()"
}

puts "per call, ns (best of $runs runs of $n calls, minus the empty loop):"
puts [format "%-9s %s" size [join [lmap s $sizes {format %10s $s}] ""]]
foreach {name shape} $shapes {
    lassign $shape setup call discarded
    set row {}
    foreach s $sizes {
        set setupS [string map [list S $s] $setup]
        set baseline [best [program $setupS 0 0 $n]]
        set t [best [program $setupS $call $discarded $n]]
        lappend row [format %10.1f [expr {1000.0 * ($t - $baseline) / $n}]]
    }
    puts [format "%-9s %s" $name [join $row ""]]
}
puts ""
puts "allocations of one call {Bytes MutableBytes Struct List}, S = 64, beside the program without it:"
foreach {name shape} $shapes {
    lassign $shape setup call discarded
    set setup64 [string map {S 64} $setup]
    set without [allocations [program $setup64 0 0 1]]
    set with [allocations [program $setup64 $call $discarded 1]]
    puts [format "%-9s %s" $name [lmap a $without b $with {expr {$b - $a}}]]
}
