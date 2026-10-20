# native-edit.tcl -- the performance report of native layout writes
# (NATIVE-LAYOUT-WRITES.md, "Performance").
#
#   tclsh9.0 bench/native-edit.tcl ?-runs N? ?-n N? ?-backends LIST?
#
# A small benchmark meant to catch gross architectural mistakes -- a store
# that copies the record, allocates, or costs in proportion to the record's
# size -- not to optimize memory writes. Natively only (the Tcl backends have
# no native memory; their byte writes are the reference implementation's).
# Two tables:
#
#   * Per operation, on Cranelift with and without specialization: programs
#     that each repeat one operation N times inside a collecting loop,
#     reported as time per operation over the program's baseline, (program -
#     baseline) / N, the whole program per operation in parentheses
#     (bench/native-view.tcl's method). The operations: through a native
#     edit, one scalar store (and eight of them), a store two nested layouts
#     deep (a path, and through a subrecord), a pointer store, making an
#     edit, a store then a read, and one store into a 4096-byte record (the
#     theorem: a store's cost is the field's, not the record's); into byte
#     storage, one std::binary::write, three in a chain, one std::binary::write_foreign
#     and one into a 4096-byte record, beside the existing per-byte update
#     std::abi::bytes::replace.
#   * The heap allocations of each program (Cranelift's counters) and per
#     operation over its baseline.
#
# Native memory is the test fixture's (core::cabi::installTestFixture,
# ffi_fixture::memory): this script is test infrastructure. Every timed
# number is best of RUNS in-process executions, compilation excluded.

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root bench backends.tcl]
interp recursionlimit {} 200000
core::cabi::installTestFixture

set runs 5
set n 200000
set backends {native-generic native}
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -n { set n $value }
        -backends { set backends $value }
        default { error "unknown option $option" }
    }
}

set prelude {import std::abi
import std::abi::bytes
import std::binary
import std::binary::native
import std::byte
import std::ffi::c
import ffi_fixture
import std::list

fn bytes_of(values: List[int]) -> std::abi::bytes::Bytes:
    bs = loop v in values:
        b = std::byte::from_int(v):
            on std::byte::BelowRange:
                0
            on std::byte::AboveRange:
                255
        b
    std::abi::bytes::from_list(bs)

layout Inner:
    size 4
    align 2
    field x: std::binary::I16 at 0
    field y: std::binary::U16 at 2

layout Outer:
    size 12
    align 4
    field count: std::binary::U32 at 0
    field inner: Inner at 4
    field last: std::binary::U8 at 8

layout Rec:
    size 32
    align 8
    field head: std::binary::U8 at 0
    field outer: Outer at 4
    field word: std::binary::U32 at 16
    field next: std::ffi::c::Ptr[std::ffi::c::Void] at 24

layout Big:
    size 4096
    align 8
    field first: std::binary::U32 at 0
    field last: std::binary::U32 at 4092

}

# A function `f(n: int) -> int` of BODY lines, called with N under a
# handler.
proc Fn {n body} {
    set text "fn f(n: int) -> int errors NativeEditNull, LayoutLengthMismatch, IndexNotFound:\n"
    foreach line $body {
        append text "    $line\n"
    }
    append text "r = f($n):\n    on NativeEditNull:\n        -1\n    on LayoutLengthMismatch:\n        -2\n    on IndexNotFound:\n        -3\nr\n"
    return $text
}

# SETUP lines, then BODY lines as a collecting loop `i from 0 to n`, then
# the List's length.
proc Each {setup lines} {
    return [concat $setup [list "xs = loop i from 0 to n:"] [lmap line $lines {string cat "    " $line}] [list "std::list::length(xs)"]]
}

set editSetup {"p = ffi_fixture::memory[std::ffi::c::Void](std::abi::bytes::freeze(std::abi::bytes::zeroed(std::abi::usize(32))))" "e = std::binary::native::edit(Rec, p)" "q = std::ffi::c::null[std::ffi::c::Void]()"}
set bigSetup {"p = ffi_fixture::memory[std::ffi::c::Void](std::abi::bytes::freeze(std::abi::bytes::zeroed(std::abi::usize(4096))))" "e = std::binary::native::edit(Big, p)"}
set bytesSetup {"d = std::abi::bytes::zeroed(std::abi::usize(32))" "q = std::ffi::c::null[std::ffi::c::Void]()"}
set bigBytesSetup {"d = std::abi::bytes::zeroed(std::abi::usize(4096))"}

proc programText {kind n} {
    # A program that makes an edit is low-level (DIRECT-MODULES.md).
    set p [expr {[string match *edit* $kind] || [string match big-* $kind] ? "direct module\n\n" : ""}]$::prelude
    switch -- $kind {
        edit-base     { append p [Fn $n [Each $::editSetup {i}]] }
        edit-scalar   { append p [Fn $n [Each $::editSetup {"std::binary::store(e, Rec.word, 7)" i}]] }
        edit-scalar8  { append p [Fn $n [Each $::editSetup {"std::binary::store(e, Rec.word, 7)" "std::binary::store(e, Rec.head, 1)" "std::binary::store(e, Rec.outer.count, 2)" "std::binary::store(e, Rec.outer.last, 3)" "std::binary::store(e, Rec.word, 8)" "std::binary::store(e, Rec.head, 4)" "std::binary::store(e, Rec.outer.count, 5)" "std::binary::store(e, Rec.outer.last, 6)" i}]] }
        edit-nested   { append p [Fn $n [Each $::editSetup {"std::binary::store(e, Rec.outer.inner.x, -5)" i}]] }
        edit-subrecord { append p [Fn $n [Each $::editSetup {"std::binary::store(e.outer.inner, Inner.x, -5)" i}]] }
        edit-pointer  { append p [Fn $n [Each $::editSetup {"std::binary::store(e, Rec.next, q)" i}]] }
        edit-make     { append p [Fn $n [Each $::editSetup {"g = std::binary::native::edit(Rec, p)" i}]] }
        edit-roundtrip { append p [Fn $n [Each $::editSetup {"std::binary::store(e, Rec.word, 7)" "e.word"}]] }
        big-base      { append p [Fn $n [Each $::bigSetup {i}]] }
        big-store     { append p [Fn $n [Each $::bigSetup {"std::binary::store(e, Big.last, 7)" i}]] }
        bytes-base    { append p [Fn $n [Each $::bytesSetup {i}]] }
        bytes-write   { append p [Fn $n [Each $::bytesSetup {"w = std::binary::write(d, Rec.word, 7)" "std::abi::bytes::mutable_length(w).value"}]] }
        bytes-write3  { append p [Fn $n [Each $::bytesSetup {"a = std::binary::write(d, Rec.word, 7)" "b = std::binary::write(a, Rec.head, 1)" "c = std::binary::write(b, Rec.outer.inner.x, -5)" "std::abi::bytes::mutable_length(c).value"}]] }
        bytes-foreign { append p [Fn $n [Each $::bytesSetup {"w = std::binary::write_foreign(d, Rec.next, q)" "std::abi::bytes::mutable_length(w).value"}]] }
        bytes-replace { append p [Fn $n [Each $::bytesSetup {"w = std::abi::bytes::replace(d, 16, 7)" "std::abi::bytes::mutable_length(w).value"}]] }
        bigbytes-base { append p [Fn $n [Each $::bigBytesSetup {i}]] }
        bigbytes-write { append p [Fn $n [Each $::bigBytesSetup {"w = std::binary::write(d, Big.last, 7)" "std::abi::bytes::mutable_length(w).value"}]] }
        default { error "unknown program $kind" }
    }
    return $p
}

proc program {kind n} {
    return [surface::compile [programText $kind $n] -warnings off]
}

proc displayName {backend} {
    if {$backend eq "native-generic"} {
        return "Cranelift (-specialize 0)"
    }
    return [bench::backends::displayName $backend]
}

# Best-of-RUNS microseconds of HIR on BACKEND (native-generic, native).
proc timeOn {backend hir} {
    set options [expr {$backend eq "native" ? {} : {-specialize 0}}]
    lassign [native::measure $hir $::runs {*}$options] lower compile best collections value
    return $best
}

# {DELTA WHOLE} nanoseconds per operation of KIND over BASE.
proc perOp {kind base backend} {
    set t [timeOn $backend [program $kind $::n]]
    set b [timeOn $backend [program $base $::n]]
    return [list [expr {($t - $b) * 1000.0 / $::n}] [expr {$t * 1000.0 / $::n}]]
}

proc ns {x} {
    return [format "%.1f ns" $x]
}

set operations {
    "edit: one scalar store (Rec.word)" edit-scalar edit-base
    "edit: eight scalar stores" edit-scalar8 edit-base
    "edit: a store two layouts deep, by path (Rec.outer.inner.x)" edit-nested edit-base
    "edit: a store two layouts deep, through the subrecord e.outer.inner" edit-subrecord edit-base
    "edit: a pointer store (Rec.next)" edit-pointer edit-base
    "edit: make an edit (std::binary::native::edit, a null test)" edit-make edit-base
    "edit: a store, then a read of the field" edit-roundtrip edit-base
    "edit: one scalar store into a 4096-byte record" big-store big-base
    "bytes: one std::binary::write (a 32-byte record)" bytes-write bytes-base
    "bytes: three std::binary::writes in a chain" bytes-write3 bytes-base
    "bytes: one std::binary::write_foreign (a pointer field)" bytes-foreign bytes-base
    "bytes: one std::binary::write into a 4096-byte record" bigbytes-write bigbytes-base
    "reference: std::abi::bytes::replace of one byte (32 bytes)" bytes-replace bytes-base
}

puts "Native layout writes: performance (n = $n operations per program; best of $runs runs)\n"
puts [bench::backends::manifest native]
if {"native-generic" in $backends} {
    puts "  (Cranelift (-specialize 0) is the same backend with specialization off: the cranelift-generic test backend)"
}
puts ""
puts "## Per operation\n"
puts "Time per operation over the baseline program, (program - baseline) / n; the whole program per operation in parentheses.\n"
puts "| operation | baseline | [join [lmap b $backends {displayName $b}] { | }] |"
puts "|---|---|[string repeat ---:| [llength $backends]]"
foreach {label kind base} $operations {
    set cells {}
    foreach backend $backends {
        lassign [perOp $kind $base $backend] delta whole
        lappend cells "[ns $delta] ([ns $whole])"
    }
    puts "| $label | $base | [join $cells { | }] |"
}

puts "\n## Native allocations\n"
puts "Heap allocations of each whole program (Cranelift's counters), n = $n, and per operation over its baseline.\n"
puts "| program | allocations | MutableBytes | Bytes | Structs | BigInts | Lists | per operation over baseline |"
puts "|---|---:|---:|---:|---:|---:|---:|---:|"
set seen [dict create]
proc kindCount {report kind} {
    return [expr {[dict exists $report byKind $kind] ? [dict get $report byKind $kind allocations] : 0}]
}
foreach {label kind base} $operations {
    foreach k [list $base $kind] {
        if {[dict exists $seen $k]} continue
        set report [native::allocationReport [program $k $n] summary]
        dict set seen $k [dict get $report total allocations]
        set over [expr {$k eq $base ? "" : [format %.2f [expr {([dict get $seen $k] - [dict get $seen $base]) / double($n)}]]}]
        puts "| $k | [dict get $report total allocations] | [kindCount $report MutableBytes] | [kindCount $report Bytes] | [kindCount $report Struct] | [kindCount $report BigInt] | [kindCount $report List] | $over |"
    }
}
