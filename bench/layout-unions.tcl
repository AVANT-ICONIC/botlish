# layout-unions.tcl -- the performance report of union layouts
# (LAYOUT-UNIONS.md, "Performance").
#
#   tclsh9.0 bench/layout-unions.tcl ?-runs N? ?-n N? ?-backends LIST?
#
# A small benchmark meant to catch gross architectural mistakes -- an
# alternative read that loads the whole union, allocates, or costs in
# proportion to the number of alternatives; a narrow alternative's store
# that writes the whole union -- not to optimize memory access. Natively
# only (the Tcl backends have no native memory; their byte-side unions are
# the reference implementation's). Two tables:
#
#   * Per operation, on Cranelift with and without specialization: programs
#     that each repeat one operation N times inside a collecting loop,
#     reported as time per operation over the program's baseline, (program -
#     baseline) / N, the whole program per operation in parentheses
#     (bench/native-view.tcl's method). Each union operation sits beside the
#     same operation on an ordinary record whose field is at the same offset
#     and of the same width -- the claim being that selecting an
#     alternative is address arithmetic the lowering folds away: a scalar
#     alternative of a union held by a record, a record alternative's
#     field, an array alternative's element at a dynamic index, a pointer
#     alternative, three reads switching interpretations, a wide and a
#     narrow alternative's store, an element of an array of unions against
#     an element of an array of records; in byte storage, binary::read and
#     binary::write through an alternative against an ordinary field.
#   * The heap allocations of each program (Cranelift's counters) and per
#     operation over its baseline: no alternative read or store allocates.
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

# OUTER holds the union WORD at 8; PLAIN is the ordinary record with WORD's
# widest alternative at the same place. ARRU is an array of seven unions,
# ARRP the same array of ordinary 8-byte records.
set prelude {import abi
import abi::bytes
import binary
import binary::native
import ffi::c
import ffi_fixture
import list

layout PAIR16:
    size 4
    align 2
    field low: binary::U16 at 0
    field high: binary::U16 at 2

union layout WORD:
    size 8
    align 8
    alternative whole: binary::U64
    alternative parts: PAIR16
    alternative words: array 2 of binary::U32
    alternative p: ffi::c::Ptr[ffi::c::Void]

layout OUTER:
    size 24
    align 8
    field tag: binary::U32 at 0
    field u: WORD at 8
    field after: binary::U32 at 16

layout PLAIN:
    size 24
    align 8
    field tag: binary::U32 at 0
    field whole: binary::U64 at 8
    field after: binary::U32 at 16

layout CELL:
    size 8
    align 8
    field whole: binary::U64 at 0

layout ARRU:
    size 64
    align 8
    field n: binary::U32 at 0
    field us: array 7 of WORD at 8

layout ARRP:
    size 64
    align 8
    field n: binary::U32 at 0
    field ps: array 7 of CELL at 8

}

# A function `f(n: int, k: int) -> int` of BODY lines, called with N and
# the dynamic index 3 under handlers.
proc Fn {n body} {
    set text "fn f(n: int, k: int) -> int errors NativeViewNull, NativeEditNull, LayoutLengthMismatch, IndexNotFound:\n"
    foreach line $body {
        append text "    $line\n"
    }
    append text "r = f($n, 3):\n    on NativeViewNull:\n        -1\n    on NativeEditNull:\n        -1\n    on LayoutLengthMismatch:\n        -2\n    on IndexNotFound:\n        -3\nr\n"
    return $text
}

# SETUP lines, then BODY lines as a collecting loop `i from 0 to n`, then
# the List's length.
proc Each {setup lines} {
    return [concat $setup [list "xs = loop i from 0 to n:"] [lmap line $lines {string cat "    " $line}] [list "list::length(xs)"]]
}

set outerSetup {"p = ffi_fixture::memory\[ffi::c::Void\](abi::bytes::freeze(abi::bytes::zeroed(abi::usize(24))))" "v = binary::native::view(OUTER, p)" "e = binary::native::edit(OUTER, p)"}
set plainSetup {"p = ffi_fixture::memory\[ffi::c::Void\](abi::bytes::freeze(abi::bytes::zeroed(abi::usize(24))))" "v = binary::native::view(PLAIN, p)" "e = binary::native::edit(PLAIN, p)"}
set arruSetup {"p = ffi_fixture::memory\[ffi::c::Void\](abi::bytes::freeze(abi::bytes::zeroed(abi::usize(64))))" "v = binary::native::view(ARRU, p)"}
set arrpSetup {"p = ffi_fixture::memory\[ffi::c::Void\](abi::bytes::freeze(abi::bytes::zeroed(abi::usize(64))))" "v = binary::native::view(ARRP, p)"}
set bytesSetup {"d = abi::bytes::zeroed(abi::usize(24))" "b = abi::bytes::freeze(d)"}

proc programText {kind n} {
    # A program that makes a view or an edit is low-level (DIRECT-MODULES.md).
    set p [expr {[string match bytes-* $kind] ? "" : "direct module\n\n"}]$::prelude
    switch -- $kind {
        outer-base      { append p [Fn $n [Each $::outerSetup {i}]] }
        outer-whole     { append p [Fn $n [Each $::outerSetup {"v.u.whole"}]] }
        outer-high      { append p [Fn $n [Each $::outerSetup {"v.u.parts.high"}]] }
        outer-word      { append p [Fn $n [Each $::outerSetup {"binary::element(v.u.words, k - 2)"}]] }
        outer-pointer   { append p [Fn $n [Each $::outerSetup {"q = v.u.p" "ffi::c::null?(q)"}]] }
        outer-switch    { append p [Fn $n [Each $::outerSetup {"v.u.whole + v.u.parts.low + v.u.whole"}]] }
        outer-store     { append p [Fn $n [Each $::outerSetup {"binary::store(e, OUTER.u.whole, 7)" i}]] }
        outer-narrow    { append p [Fn $n [Each $::outerSetup {"binary::store(e, OUTER.u.parts.high, 7)" i}]] }
        plain-base      { append p [Fn $n [Each $::plainSetup {i}]] }
        plain-whole     { append p [Fn $n [Each $::plainSetup {"v.whole"}]] }
        plain-store     { append p [Fn $n [Each $::plainSetup {"binary::store(e, PLAIN.whole, 7)" i}]] }
        arru-base       { append p [Fn $n [Each $::arruSetup {i}]] }
        arru-element    { append p [Fn $n [Each $::arruSetup {"binary::element(v.us, k).whole"}]] }
        arrp-base       { append p [Fn $n [Each $::arrpSetup {i}]] }
        arrp-element    { append p [Fn $n [Each $::arrpSetup {"binary::element(v.ps, k).whole"}]] }
        bytes-base      { append p [Fn $n [Each $::bytesSetup {i}]] }
        bytes-read-alt  { append p [Fn $n [Each $::bytesSetup {"binary::read(b, OUTER.u.parts.high)"}]] }
        bytes-read-plain { append p [Fn $n [Each $::bytesSetup {"binary::read(b, PLAIN.after)"}]] }
        bytes-write-alt { append p [Fn $n [Each $::bytesSetup {"w = binary::write(d, OUTER.u.parts.high, 7)" "abi::bytes::mutable_length(w).value"}]] }
        bytes-write-plain { append p [Fn $n [Each $::bytesSetup {"w = binary::write(d, PLAIN.after, 7)" "abi::bytes::mutable_length(w).value"}]] }
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
    "view: a U64 alternative of a union held at 8 (v.u.whole)" outer-whole outer-base
    "view: the same U64 as an ordinary field at 8 (v.whole)" plain-whole plain-base
    "view: a record alternative's field (v.u.parts.high)" outer-high outer-base
    "view: an array alternative's element, dynamic index (binary::element(v.u.words, k - 2))" outer-word outer-base
    "view: a pointer alternative (q = v.u.p, ffi::c::null?(q))" outer-pointer outer-base
    "view: three reads switching interpretations (whole, parts.low, whole)" outer-switch outer-base
    "edit: a U64 alternative's store (OUTER.u.whole)" outer-store outer-base
    "edit: the same U64 as an ordinary field's store (PLAIN.whole)" plain-store plain-base
    "edit: a narrow alternative's store, 2 of the union's 8 bytes (OUTER.u.parts.high)" outer-narrow outer-base
    "view: an element of an array of unions, its alternative (binary::element(v.us, k).whole)" arru-element arru-base
    "view: an element of an array of records, the same field (binary::element(v.ps, k).whole)" arrp-element arrp-base
    "bytes: binary::read through a union (OUTER.u.parts.high)" bytes-read-alt bytes-base
    "bytes: binary::read of an ordinary field (PLAIN.after)" bytes-read-plain bytes-base
    "bytes: binary::write through a union (OUTER.u.parts.high), a 24-byte record" bytes-write-alt bytes-base
    "bytes: binary::write of an ordinary field (PLAIN.after), a 24-byte record" bytes-write-plain bytes-base
}

puts "Union layouts: performance (n = $n operations per program; best of $runs runs)\n"
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

# The compile cost: the front end's time (surface::compile, best of RUNS)
# of a program declaring one layout of K members and reading its last one
# through a view -- a union of K one-byte-to-eight-byte alternatives against
# a record of the same K fields laid end to end -- so that a union's
# registration, validation (no overlap check: there is no overlap rule to
# apply) and designator resolution are seen to cost what a record's do.
proc compileText {kind k} {
    set text "direct module\n\nimport abi\nimport abi::bytes\nimport binary\nimport binary::native\nimport ffi::c\nimport ffi_fixture\n\n"
    set widths {1 2 4 8}
    set types {binary::U8 binary::U16 binary::U32 binary::U64}
    if {$kind eq "union"} {
        append text "union layout BIG:\n    size 8\n    align 8\n"
        for {set i 0} {$i < $k} {incr i} { append text "    alternative a$i: [lindex $types [expr {$i % 4}]]\n" }
        set size 8
    } else {
        set at 0
        set fields ""
        for {set i 0} {$i < $k} {incr i} {
            set w [lindex $widths [expr {$i % 4}]]
            append fields "    field a$i: [lindex $types [expr {$i % 4}]] at $at\n"
            incr at $w
        }
        append text "layout BIG:\n    size $at\n    align 1\n$fields"
        set size $at
    }
    append text "\nfn f() -> int errors NativeViewNull:\n    p = ffi_fixture::memory\[ffi::c::Void\](abi::bytes::freeze(abi::bytes::zeroed(abi::usize($size))))\n    v = binary::native::view(BIG, p)\n    v.a[expr {$k - 1}]\n\nr = f():\n    on NativeViewNull:\n        -1\nr\n"
    return $text
}

puts "\n## Compile cost\n"
puts "The front end's time (surface::compile, best of $runs) of a program declaring one layout of K members and reading the last through a view.\n"
puts "| K | union of K alternatives | record of K fields |"
puts "|---:|---:|---:|"
foreach k {4 64 512} {
    set cells {}
    foreach kind {union record} {
        set text [compileText $kind $k]
        set best ""
        for {set r 0} {$r < $runs} {incr r} {
            set t [lindex [time {surface::compile $text -warnings off}] 0]
            if {$best eq "" || $t < $best} { set best $t }
        }
        lappend cells [format "%.1f ms" [expr {$best / 1000.0}]]
    }
    puts "| $k | [join $cells { | }] |"
}
