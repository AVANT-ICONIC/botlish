# layout-arrays.tcl -- the performance report of fixed arrays in binary
# layouts (FIXED-LAYOUT-ARRAYS.md, "Lowering, runtime and performance").
#
#   tclsh9.0 bench/layout-arrays.tcl ?-runs N? ?-n N? ?-backends LIST?
#
# A small benchmark meant to catch gross architectural mistakes -- an element
# access that copies the array, allocates, or costs in proportion to the
# array's extent; a whole store that copies the record -- not to optimize
# memory access. Natively only (the Tcl backends have no native memory; their
# byte-side arrays are the reference implementation's). Two tables:
#
#   * Per operation, on Cranelift with and without specialization: programs
#     that each repeat one operation N times inside a collecting loop,
#     reported as time per operation over the program's baseline, (program -
#     baseline) / N, the whole program per operation in parentheses
#     (bench/native-view.tcl's method). The operations: through a native view
#     or edit, an element read at a proven index and at a dynamic one (the
#     bounds check), the same in an array of 4096 elements (the theorem: an
#     element access costs the element's, never the array's), a record
#     element's field, an element store, a whole load of a 16-element row,
#     of a 260-element array (Win32's MAX_PATH name) and of four records, a
#     whole store of a 16-element row and of 260 elements; into byte
#     storage, a whole-row std::binary::write, std::binary::parse and std::binary::emit of
#     a record with arrays.
#   * The heap allocations of each program (Cranelift's counters) and per
#     operation over its baseline: an element access allocates nothing, a
#     load exactly the List it returns (and its records).
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
import std::ffi::c
import ffi_fixture
import std::list

layout PT:
    size 4
    align 2
    field x: std::binary::I16 at 0
    field y: std::binary::U16 at 2

layout ROW:
    size 64
    align 4
    field n: std::binary::U32 at 0
    field row: array 16 of std::binary::U16 at 4
    field recs: array 4 of PT at 36
    field tail: std::binary::U32 at 52

layout HUGE:
    size 8192
    align 2
    field xs: array 4096 of std::binary::U16 at 0

layout NAME:
    size 520
    align 2
    field name: array 260 of std::binary::U16 at 0

}

# A function `f(n: int, k: int) -> int` of BODY lines, called with N and
# the dynamic index 3 under handlers.
proc Fn {n body} {
    set text "fn f(n: int, k: int) -> int errors NativeViewNull, NativeEditNull, LayoutLengthMismatch, LayoutExtentMismatch, IndexNotFound:\n"
    foreach line $body {
        append text "    $line\n"
    }
    append text "r = f($n, 3):\n    on NativeViewNull:\n        -1\n    on NativeEditNull:\n        -1\n    on LayoutLengthMismatch:\n        -2\n    on LayoutExtentMismatch:\n        -4\n    on IndexNotFound:\n        -3\nr\n"
    return $text
}

# SETUP lines, then BODY lines as a collecting loop `i from 0 to n`, then
# the List's length.
proc Each {setup lines} {
    return [concat $setup [list "xs = loop i from 0 to n:"] [lmap line $lines {string cat "    " $line}] [list "std::list::length(xs)"]]
}

set rowSetup {"p = ffi_fixture::memory\[std::ffi::c::Void\](std::abi::bytes::freeze(std::abi::bytes::zeroed(std::abi::usize(64))))" "v = std::binary::native::view(ROW, p)" "e = std::binary::native::edit(ROW, p)" "row = std::binary::load(v.row)"}
set hugeSetup {"p = ffi_fixture::memory\[std::ffi::c::Void\](std::abi::bytes::freeze(std::abi::bytes::zeroed(std::abi::usize(8192))))" "v = std::binary::native::view(HUGE, p)" "e = std::binary::native::edit(HUGE, p)"}
set nameSetup {"p = ffi_fixture::memory\[std::ffi::c::Void\](std::abi::bytes::freeze(std::abi::bytes::zeroed(std::abi::usize(520))))" "v = std::binary::native::view(NAME, p)" "e = std::binary::native::edit(NAME, p)" "name = std::binary::load(v.name)"}
set bytesSetup {"d = std::abi::bytes::zeroed(std::abi::usize(64))" "b = std::abi::bytes::freeze(d)" "row = std::binary::parse(ROW, b).row" "s = std::binary::parse(ROW, b)"}

proc programText {kind n} {
    # A program that makes a view or an edit is low-level (DIRECT-MODULES.md).
    set p [expr {[string match bytes-* $kind] ? "" : "direct module\n\n"}]$::prelude
    switch -- $kind {
        row-base        { append p [Fn $n [Each $::rowSetup {i}]] }
        row-proven      { append p [Fn $n [Each $::rowSetup {"std::binary::element(v.row, 3)"}]] }
        row-dynamic     { append p [Fn $n [Each $::rowSetup {"std::binary::element(v.row, k)"}]] }
        row-record      { append p [Fn $n [Each $::rowSetup {"std::binary::element(v.recs, k).y"}]] }
        row-store       { append p [Fn $n [Each $::rowSetup {"std::binary::store_element(e.row, k, 7)" i}]] }
        row-load        { append p [Fn $n [Each $::rowSetup {"std::list::length(std::binary::load(v.row))"}]] }
        row-load-recs   { append p [Fn $n [Each $::rowSetup {"std::list::length(std::binary::load(v.recs))"}]] }
        row-store-whole { append p [Fn $n [Each $::rowSetup {"std::binary::store(e, ROW.row, row)" i}]] }
        huge-base       { append p [Fn $n [Each $::hugeSetup {i}]] }
        huge-proven     { append p [Fn $n [Each $::hugeSetup {"std::binary::element(v.xs, 4000)"}]] }
        huge-dynamic    { append p [Fn $n [Each $::hugeSetup {"std::binary::element(v.xs, k)"}]] }
        huge-store      { append p [Fn $n [Each $::hugeSetup {"std::binary::store_element(e.xs, k, 7)" i}]] }
        name-base       { append p [Fn $n [Each $::nameSetup {i}]] }
        name-load       { append p [Fn $n [Each $::nameSetup {"std::list::length(std::binary::load(v.name))"}]] }
        name-store      { append p [Fn $n [Each $::nameSetup {"std::binary::store(e, NAME.name, name)" i}]] }
        bytes-base      { append p [Fn $n [Each $::bytesSetup {i}]] }
        bytes-write     { append p [Fn $n [Each $::bytesSetup {"w = std::binary::write(d, ROW.row, row)" "std::abi::bytes::mutable_length(w).value"}]] }
        bytes-parse     { append p [Fn $n [Each $::bytesSetup {"std::binary::parse(ROW, b).n"}]] }
        bytes-emit      { append p [Fn $n [Each $::bytesSetup {"std::binary::emit(s) == b"}]] }
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
    "view: an element read, proven index (ROW.row[3], 16 x U16)" row-proven row-base
    "view: an element read, dynamic index (bounds check)" row-dynamic row-base
    "view: a record element's field (std::binary::element(v.recs, k).y)" row-record row-base
    "edit: an element store, dynamic index" row-store row-base
    "view: an element read, proven index, 4096-element array" huge-proven huge-base
    "view: an element read, dynamic index, 4096-element array" huge-dynamic huge-base
    "edit: an element store, dynamic index, 4096-element array" huge-store huge-base
    "view: std::binary::load of a 16-element row" row-load row-base
    "view: std::binary::load of four records" row-load-recs row-base
    "view: std::binary::load of a 260-element array" name-load name-base
    "edit: std::binary::store of a 16-element row (a loaded List)" row-store-whole row-base
    "edit: std::binary::store of a 260-element array (a loaded List)" name-store name-base
    "bytes: std::binary::write of a 16-element row (a 64-byte record)" bytes-write bytes-base
    "bytes: std::binary::parse of the 64-byte record (a row, four records)" bytes-parse bytes-base
    "bytes: std::binary::emit of the 64-byte record" bytes-emit bytes-base
}

puts "Fixed layout arrays: performance (n = $n operations per program; best of $runs runs)\n"
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
