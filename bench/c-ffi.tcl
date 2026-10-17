# c-ffi.tcl -- what a C call costs natively (C-FFI.md, "Performance").
#
#   tclsh9.0 bench/c-ffi.tcl ?-runs N? ?-n N? ?-sizes LIST? ?-sha-sizes LIST?
#
# 1. Per call, ns: programs that each make N calls of the C FFI test fixture
#    (tests/cffi/fixture.c, compiled here with the host C compiler into a
#    private static archive) in a loop, reported as (program - baseline) / N,
#    the baseline being the same loop without the call
#    (bench/c-pointer-borrowing.tcl's method):
#
#      count     bcf_count(): no argument, an unsigned long result (C
#                increments a static) -- the call itself
#      add       bcf_add(i, 1): two int arguments, an int result
#      big       bcf_echo_ulonglong(2^64 - 1): a 64-bit argument and result
#                beyond the small Int range (rt_ffi_int_word, rt_ffi_box_u64)
#      read S    bcf_sum(data, 0) of an S-byte Bytes: one read exposure
#                (bytesaddr, keepalive), C touching no byte -- expected flat
#                in S (the storage is never copied)
#      write S   bcf_fill(m, 0, 0) of an S-byte MutableBytes, the write-back
#                discarded: one write exposure, whose detach copies S bytes
#                -- expected linear in S
#
# 2. SHA-256 through the package-owned static BoringSSL
#    (tests/cffi/boringssl.tcl; skipped when it is not built): sha256::digest
#    (examples/ffi/sha256/) of an S-byte input for each S in SHA-SIZES, per
#    call and as MB/s -- one read exposure of the input (no copy) and one
#    32-byte write exposure per digest.
#
# 3. Compile and link, ms (best of RUNS): native::evalHir of a program that
#    calls no C and of the same program calling one C function (front end
#    excluded: lowering, Cranelift and, for the C program, the system link
#    of a temporary executable and its run), and native::executable of
#    both (rustc linking the standalone executable; the C program also
#    links its library).
#
# Every per-call number is best of RUNS executions (cranelift, specialized),
# compilation and linking excluded: a program that calls C runs as a linked
# executable, its symbols resolved once by the system linker, so the loop
# makes direct calls with no lookup.

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root tests cffi boringssl.tcl]

set runs 5
set n 100000
set sizes {64 65536 1048576}
set shaSizes {64 1024 65536 1048576}
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -n { set n $value }
        -sizes { set sizes $value }
        -sha-sizes { set shaSizes $value }
        default { error "unknown option $option" }
    }
}

set scratch [file tempdir botlish-bench-cffi-]
exec cc -c -O2 -fPIC [file join $root tests cffi fixture.c] -o [file join $scratch fixture.o]
exec ar rcs [file join $scratch libbotlish_cffi_fixture.a] [file join $scratch fixture.o]
set boringssl [cffi::boringsslDir]
set linkDirs [concat [list $scratch] [expr {$boringssl eq "" ? {} : [list $boringssl]}]]

proc writeFile {path text} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
}

# The fixture binding: what the benchmark calls of it.
writeFile [file join $scratch bcf.bot] {import ffi::c

extern c library "botlish_cffi_fixture"

extern c fn count named "bcf_count"() -> ffi::c::ULong
extern c fn add named "bcf_add"(a: ffi::c::Int, b: ffi::c::Int) -> ffi::c::Int
extern c fn echo_ulonglong named "bcf_echo_ulonglong"(x: ffi::c::ULongLong) -> ffi::c::ULongLong
extern c fn sum named "bcf_sum"(data: ffi::c::Ptr[ffi::c::UChar] read noescape, count: ffi::c::ULong) -> ffi::c::ULong
extern c fn fill named "bcf_fill"(out: ffi::c::Ptr[ffi::c::UChar] write noescape, count: ffi::c::ULong, seed: ffi::c::UChar) -> unit
}
foreach file {boringssl.bot sha256.bot} {
    file copy -force [file join $root examples ffi sha256 $file] [file join $scratch $file]
}

set prelude "import abi\nimport abi::bytes\nimport byte\nimport ffi::c\nimport list\nimport bcf\n
fn pattern(n: int):
    loop i from 0 to n:
        byte::from_int(mod(i, 256))

"

# The HIR of the entry program TEXT, an application of the scratch
# directory.
proc compileApp {text} {
    set path [file join $::scratch main-[incr ::programs].bot]
    writeFile $path $text
    return [surface::readProgramFile $path -warnings off -cache ""]
}
set programs 0

# The program of SETUP and a loop of N iterations whose body is BODY (or
# BODY then 0, when DISCARDED).
proc program {setup body discarded n} {
    set inner [expr {$discarded ? "$body\n        0" : $body}]
    return "$::prelude\nfn f() -> int:\n    $setup\n    xs = loop i from 0 to $n:\n        $inner\n    list::length(xs)\n\nf()\n"
}

# The best time (microseconds) of the program TEXT.
proc best {text} {
    set hir [compileApp $text]
    native::withLinkDirs $::linkDirs {
        lassign [native::measure $hir $::runs] lower compile best
    }
    return $best
}

proc perCall {setup call discarded} {
    set baseline [best [program $setup 0 0 $::n]]
    set t [best [program $setup $call $discarded $::n]]
    return [expr {1000.0 * ($t - $baseline) / $::n}]
}

try {
    puts "1. per call, ns (best of $runs runs of $n calls, minus the empty loop):"
    puts [format "  %-12s %10.1f" count [perCall {x = 0} {bcf::count()} 0]]
    puts [format "  %-12s %10.1f" add [perCall {x = 0} {bcf::add(i, 1)} 0]]
    puts [format "  %-12s %10.1f" big [perCall {x = 0} {bcf::echo_ulonglong(18446744073709551615)} 0]]
    foreach s $sizes {
        puts [format "  %-12s %10.1f" "read $s" [perCall "data = abi::bytes::from_list(pattern($s))" {bcf::sum(data, 0)} 0]]
    }
    foreach s $sizes {
        puts [format "  %-12s %10.1f" "write $s" [perCall "m = abi::bytes::from_bytes(abi::bytes::from_list(pattern($s)))" {bcf::fill(m, 0, 0)} 1]]
    }
    puts ""
    if {$boringssl eq ""} {
        puts "2. SHA-256: skipped (the package-owned BoringSSL is not built: tclsh9.0 tests/cffi/boringssl.tcl)"
    } else {
        puts "2. SHA-256 (BoringSSL, static), per digest (best of $runs runs):"
        foreach s $shaSizes {
            set count [expr {max(4, min($n, 67108864 / max($s, 1)))}]
            set setup "data = abi::bytes::from_list(pattern($s))"
            set baseline [best "import sha256\n[program $setup 0 0 $count]"]
            set t [best "import sha256\n[program $setup {sha256::digest(data)} 1 $count]"]
            set us [expr {($t - $baseline) / $count}]
            puts [format "  %-10s %10.2f us  %8.1f MB/s  (%d digests)" "$s B" $us [expr {$us > 0 ? $s / $us : 0}] $count]
        }
    }
    puts ""
    puts "3. compile and link, ms (best of $runs):"
    set plain [compileApp "x = 40\nx + 2\n"]
    set calling [compileApp "import ffi::c\nimport bcf\n\nbcf::add(40, 2)\n"]
    foreach {label hir} [list "no C" $plain "calls C" $calling] {
        set run {}
        set exe {}
        for {set r 0} {$r < $runs} {incr r} {
            native::withLinkDirs $linkDirs {
                lappend run [expr {[lindex [time {native::evalHir $hir}] 0] / 1000.0}]
                set path [file join $scratch exe-$r]
                lappend exe [expr {[lindex [time {native::executable $hir $path}] 0] / 1000.0}]
            }
        }
        puts [format "  %-8s native::evalHir %8.1f   native::executable %8.1f" $label \
            [tcl::mathfunc::min {*}$run] [tcl::mathfunc::min {*}$exe]]
    }
} finally {
    file delete -force $scratch
}
