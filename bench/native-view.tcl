# native-view.tcl -- the performance report of read-only native layout views
# (NATIVE-LAYOUT-VIEWS.md, "Performance").
#
#   tclsh9.0 bench/native-view.tcl ?-runs N? ?-n N? ?-backends LIST?
#
# A small benchmark meant to catch gross architectural mistakes -- a field
# read that copies the record, allocates in proportion to it, or walks the
# layout at run time -- not to optimize memory reads. Natively only (the Tcl
# backends have no native memory). Two tables:
#
#   * Per read, on Cranelift with and without specialization: programs that
#     each repeat one operation N times inside a collecting loop, reported as
#     time per operation over the program's baseline, (program - baseline) /
#     N, the whole program per operation in parentheses (bench/enums.tcl's
#     method). The operations: a scalar field read through a view (and eight
#     of them summed, the clearer per-read cost over the loop), a field
#     two nested layouts deep, a pointer field (and its null test), making a
#     view, std::binary::load of a whole record; beside the byte-backed
#     equivalents: std::binary::parse of the same record then the same field
#     read, and the field read of a LayoutStruct already imprinted.
#   * The heap allocations of each program (Cranelift's counters) and per
#     operation over its baseline.
#
# The record is the test suite's Deep-like layout with a pointer field (32
# bytes). Native memory is the test fixture's (core::cabi::installTestFixture,
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

layout RecBytes:
    size 32
    align 8
    field head: std::binary::U8 at 0
    field outer: Outer at 4
    field word: std::binary::U32 at 16
    field next: std::binary::U64 at 24

fn record() -> List[int]:
    [200, 0, 0, 0, 1, 0, 0, 0, 57, 48, 49, 212, 7, 0, 0, 0, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

}

# A function `f(n: int) -> int` of BODY lines, called with N under a
# handler.
proc Fn {n body} {
    set text "fn f(n: int) -> int errors NativeViewNull, LayoutLengthMismatch:\n"
    foreach line $body {
        append text "    $line\n"
    }
    append text "r = f($n):\n    on NativeViewNull:\n        -1\n    on LayoutLengthMismatch:\n        -2\nr\n"
    return $text
}

# SETUP lines, then BODY lines as a collecting loop `i from 0 to n`, then
# the List's length.
proc Each {setup lines} {
    return [concat $setup [list "xs = loop i from 0 to n:"] [lmap line $lines {string cat "    " $line}] [list "std::list::length(xs)"]]
}

set viewSetup {"p = ffi_fixture::memory[std::ffi::c::Void](bytes_of(record()))" "v = std::binary::native::view(Rec, p)"}
set bytesSetup {"d = bytes_of(record())"}

proc programText {kind n} {
    # A program that makes a view is low-level (DIRECT-MODULES.md).
    set p [expr {[string match view-* $kind] ? "direct module\n\n" : ""}]$::prelude
    switch -- $kind {
        view-base     { append p [Fn $n [Each $::viewSetup {i}]] }
        view-scalar   { append p [Fn $n [Each $::viewSetup {v.word}]] }
        view-nested   { append p [Fn $n [Each $::viewSetup {v.outer.inner.x}]] }
        view-pointer  { append p [Fn $n [Each $::viewSetup {"q = v.next" "q.null?()"}]] }
        view-make     { append p [Fn $n [Each $::viewSetup {"w = std::binary::native::view(Rec, p)" "i"}]] }
        view-scalar8  { append p [Fn $n [Each $::viewSetup {"v.word + v.head + v.outer.count + v.outer.last + v.word + v.head + v.outer.count + v.outer.last"}]] }
        view-load     { append p [Fn $n [Each $::viewSetup {"{word: w, next: q} = std::binary::load(v)" "w"}]] }
        bytes-base    { append p [Fn $n [Each $::bytesSetup {i}]] }
        bytes-parse-scalar { append p [Fn $n [Each $::bytesSetup {"s = std::binary::parse(RecBytes, d)" "s.word"}]] }
        bytes-parse-nested { append p [Fn $n [Each $::bytesSetup {"s = std::binary::parse(RecBytes, d)" "s.outer.inner.x"}]] }
        held-base     { append p [Fn $n [Each [concat $::bytesSetup {"s = std::binary::parse(RecBytes, d)"}] {i}]] }
        held-scalar   { append p [Fn $n [Each [concat $::bytesSetup {"s = std::binary::parse(RecBytes, d)"}] {s.word}]] }
        held-scalar8  { append p [Fn $n [Each [concat $::bytesSetup {"s = std::binary::parse(RecBytes, d)"}] {"s.word + s.head + s.outer.count + s.outer.last + s.word + s.head + s.outer.count + s.outer.last"}]] }
        held-nested   { append p [Fn $n [Each [concat $::bytesSetup {"s = std::binary::parse(RecBytes, d)"}] {s.outer.inner.x}]] }
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
    "view: a scalar field (v.word, one load)" view-scalar view-base
    "view: eight scalar reads summed (8 loads)" view-scalar8 view-base
    "view: a field two layouts deep (v.outer.inner.x, one load)" view-nested view-base
    "view: a pointer field and its null test" view-pointer view-base
    "view: make a view (std::binary::native::view, a null test)" view-make view-base
    "view: std::binary::load of the whole record (4 leaves, 2 nested)" view-load view-base
    "bytes: std::binary::parse of the same record, then the scalar" bytes-parse-scalar bytes-base
    "bytes: std::binary::parse of the same record, then the nested field" bytes-parse-nested bytes-base
    "bytes: the scalar of a LayoutStruct already imprinted" held-scalar held-base
    "bytes: the nested field of a LayoutStruct already imprinted" held-nested held-base
    "bytes: eight scalar reads of a LayoutStruct already imprinted, summed" held-scalar8 held-base
}

puts "Read-only native layout views: performance (n = $n operations per program; best of $runs runs)\n"
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
puts "| program | allocations | Bytes | Structs | Lists | per operation over baseline |"
puts "|---|---:|---:|---:|---:|---:|"
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
        puts "| $k | [dict get $report total allocations] | [kindCount $report Bytes] | [kindCount $report Struct] | [kindCount $report List] | $over |"
    }
}
