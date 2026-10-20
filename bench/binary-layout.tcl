# binary-layout.tcl -- the performance report of fixed binary layouts
# (BINARY-LAYOUT.md, "Performance").
#
#   tclsh9.0 bench/binary-layout.tcl ?-runs N? ?-n N? ?-native-n N?
#                                    ?-backends LIST? ?-layouts K?
#
# A small benchmark meant to catch gross architectural mistakes, not to
# optimize binary throughput. Three tables:
#
#   * Per record, on every backend (Tcl interp, Tcl compile, Cranelift with
#     -specialize 0, Cranelift): programs that each repeat one operation N
#     times inside a collecting loop, reported as time per record over the
#     program's baseline, (program - baseline) / N, the whole program per
#     record in parentheses (bench/enums.tcl's method). The operations: parse
#     many records (each kept), emit many records, parse then read two fields
#     (the value never kept), construct then emit, a round trip, a padded and
#     a nested layout, beside two references: building an ordinary struct of
#     the same four fields, and building the same 16 bytes from a List of
#     bytes (std::abi::bytes::from_list).
#   * Natively, the heap allocations of each program per record (Cranelift's
#     allocation counters): what a gross allocation path would show.
#   * The compilation cost of layouts: a generated program declaring K
#     layouts of eight scalar fields, parsing and emitting each once, beside
#     the same program with K ordinary structs of the same fields constructed
#     and read instead: front end (surface::compile: declaration checks,
#     resolution, analyses), the Tcl compiler (compileHir), native lowering
#     (NIR) and Cranelift's compilation, per layout.
#
# The layouts resemble C structs: Device is RAWINPUTDEVICE's shape on
# Windows x86-64 (16 bytes, naturally aligned, no padding), Sample a padded
# struct (12 bytes, 6 of them padding) and Segment two nested 8-byte points.
# Every timed number is best of RUNS in-process executions, compilation
# excluded.

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root bench backends.tcl]
interp recursionlimit {} 200000

set runs 5
set n 2000
set nativeN 200000
set backends {interp compile native-generic native}
set layoutCount 200
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -n { set n $value }
        -native-n { set nativeN $value }
        -backends { set backends $value }
        -layouts { set layoutCount $value }
        default { error "unknown option $option" }
    }
}

set prelude "import std::abi::bytes
import std::binary
import std::byte
import std::list

layout Device:
    size 16
    align 8
    field page: std::binary::U16 at 0
    field usage: std::binary::U16 at 2
    field flags: std::binary::U32 at 4
    field target: std::binary::U64 at 8

layout Sample:
    size 12
    align 4
    field tag: std::binary::U8 at 0
    field value: std::binary::I32 at 4
    field flag: std::binary::U8 at 8

layout Point:
    size 8
    align 4
    field x: std::binary::I32 at 0
    field y: std::binary::I32 at 4

layout Segment:
    size 16
    align 4
    field a: Point at 0
    field b: Point at 8

struct DeviceRecord:
    page: int
    usage: int
    flags: int
    target: int

fn byte_list(values: List\[int\]) -> List\[std::byte::Byte\]:
    loop v in values:
        b = std::byte::from_int(v):
            on std::byte::BelowRange:
                0
            on std::byte::AboveRange:
                255
        b

fn device_list() -> List\[std::byte::Byte\]:
    byte_list(\[1, 0, 6, 0, 0, 1, 0, 0, 52, 18, 0, 0, 0, 0, 0, 0\])

fn device_bytes() -> std::abi::bytes::Bytes:
    std::abi::bytes::from_list(device_list())

fn sample_bytes() -> std::abi::bytes::Bytes:
    std::abi::bytes::from_list(byte_list(\[7, 0, 0, 0, 255, 255, 255, 255, 1, 0, 0, 0\]))

fn segment_bytes() -> std::abi::bytes::Bytes:
    std::abi::bytes::from_list(byte_list(\[251, 255, 255, 255, 7, 0, 0, 0, 255, 255, 255, 127, 0, 0, 0, 128\]))

fn device() -> LayoutStruct\[Device\]:
    LayoutStruct\[Device\] {page: 1, usage: 6, flags: 256, target: 4660}

fn emit_flags(f: std::binary::U32) -> std::abi::bytes::Bytes:
    std::binary::emit(LayoutStruct\[Device\] {page: 1, usage: 6, flags: f, target: 4660})

fn record(f: int) -> DeviceRecord:
    DeviceRecord {page: 1, usage: 6, flags: f, target: 4660}

"

# A function `f(n: int) -> int` of BODY lines, called with N under a
# handler.
proc Fn {n body} {
    set text "fn f(n: int) -> int errors LayoutLengthMismatch:\n"
    foreach line $body {
        append text "    $line\n"
    }
    append text "r = f($n):\n    on LayoutLengthMismatch:\n        -1\nr\n"
    return $text
}

# SETUP lines, then BODY lines as a collecting loop `i from 0 to n`, then
# the List's length.
proc Each {setup lines} {
    return [concat $setup [list "xs = loop i from 0 to n:"] [lmap line $lines {string cat "    " $line}] [list "std::list::length(xs)"]]
}

proc programText {kind n} {
    set p $::prelude
    switch -- $kind {
        loop-base      { append p [Fn $n [Each {} {i}]] }
        device-base    { append p [Fn $n [Each {"d = device_bytes()"} {i}]] }
        parse          { append p [Fn $n [Each {"d = device_bytes()"} {"std::binary::parse(Device, d)"}]] }
        parse-read     { append p [Fn $n [Each {"d = device_bytes()"} {"p = std::binary::parse(Device, d)" "p.usage + p.flags"}]] }
        value-base     { append p [Fn $n [Each {"v = device()"} {i}]] }
        emit           { append p [Fn $n [Each {"v = device()"} {"std::binary::emit(v)"}]] }
        construct-emit { append p [Fn $n [Each {} {"emit_flags(256)"}]] }
        round-trip     { append p [Fn $n [Each {"v = device()"} {"std::binary::parse(Device, std::binary::emit(v)) == v"}]] }
        sample-base    { append p [Fn $n [Each {"d = sample_bytes()"} {i}]] }
        sample-parse   { append p [Fn $n [Each {"d = sample_bytes()"} {"std::binary::parse(Sample, d)"}]] }
        sample-emit-base { append p [Fn $n [Each {"v = LayoutStruct\[Sample\] {tag: 7, value: -1, flag: 1}"} {i}]] }
        sample-emit    { append p [Fn $n [Each {"v = LayoutStruct\[Sample\] {tag: 7, value: -1, flag: 1}"} {"std::binary::emit(v)"}]] }
        segment-base   { append p [Fn $n [Each {"d = segment_bytes()"} {i}]] }
        segment-parse  { append p [Fn $n [Each {"d = segment_bytes()"} {"std::binary::parse(Segment, d)"}]] }
        segment-round-trip { append p [Fn $n [Each {"d = segment_bytes()"} {"std::binary::emit(std::binary::parse(Segment, d)) == d"}]] }
        struct         { append p [Fn $n [Each {} {"record(i)"}]] }
        list-base      { append p [Fn $n [Each {"bs = device_list()"} {i}]] }
        from-list      { append p [Fn $n [Each {"bs = device_list()"} {"std::abi::bytes::from_list(bs)"}]] }
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

# Best-of-RUNS microseconds of HIR on BACKEND (interp, compile,
# native-generic, native).
proc timeOn {backend hir} {
    if {$backend in {native native-generic}} {
        set options [expr {$backend eq "native" ? {} : {-specialize 0}}]
        lassign [native::measure $hir $::runs {*}$options] lower compile best collections value
        return $best
    }
    if {$backend eq "compile"} {
        set unit [core::compiler::compileHir $hir]
        set run {core::compiler::evalUnit $unit}
    } else {
        set program [hir::lower $hir]
        core::useBackend $backend
        set run {core::evalProgram $program}
    }
    eval $run
    set best ""
    for {set i 0} {$i < $::runs} {incr i} {
        set micros [lindex [time $run] 0]
        if {$best eq "" || $micros < $best} {
            set best $micros
        }
    }
    return $best
}

proc nOf {backend} {
    return [expr {$backend in {native native-generic} ? $::nativeN : $::n}]
}

# {DELTA WHOLE} nanoseconds per record of KIND over BASE (or 0).
proc perRecord {kind base backend} {
    set n [nOf $backend]
    set t [timeOn $backend [program $kind $n]]
    set b [expr {$base eq "" ? 0 : [timeOn $backend [program $base $n]]}]
    return [list [expr {($t - $b) * 1000.0 / $n}] [expr {$t * 1000.0 / $n}]]
}

proc ns {x} {
    return [format "%.1f ns" $x]
}

set operations {
    "parse Device (16 bytes, 4 fields), each record kept" parse device-base
    "parse Device, read two fields (record not kept)" parse-read device-base
    "emit Device" emit value-base
    "construct Device, then emit" construct-emit loop-base
    "round trip: parse(emit(v)) == v" round-trip value-base
    "parse Sample (12 bytes, 3 fields, 6 padding)" sample-parse sample-base
    "emit Sample" sample-emit sample-emit-base
    "parse Segment (two nested Points)" segment-parse segment-base
    "round trip Segment: emit(parse(d)) == d" segment-round-trip segment-base
    "reference: an ordinary struct of the same 4 fields" struct loop-base
    "reference: the same 16 bytes from a List (std::abi::bytes::from_list)" from-list list-base
}

puts "Fixed binary layouts: performance (n = $n records per program on the Tcl backends, $nativeN natively; best of $runs runs)\n"
set manifestIds {}
foreach b $backends {
    set id [expr {$b eq "native-generic" ? "native" : $b}]
    if {$id ni $manifestIds} {
        lappend manifestIds $id
    }
}
puts [bench::backends::manifest $manifestIds]
if {"native-generic" in $backends} {
    puts "  (Cranelift (-specialize 0) is the same backend with specialization off: the cranelift-generic test backend)"
}
puts ""
puts "## Per record\n"
puts "Time per record over the baseline program, (program - baseline) / n; the whole program per record in parentheses.\n"
puts "| operation | baseline | [join [lmap b $backends {displayName $b}] { | }] |"
puts "|---|---|[string repeat ---:| [llength $backends]]"
foreach {label kind base} $operations {
    set cells {}
    foreach backend $backends {
        lassign [perRecord $kind $base $backend] delta whole
        lappend cells "[ns $delta] ([ns $whole])"
    }
    puts "| $label | $base | [join $cells { | }] |"
}

if {"native" in $backends} {
    puts "\n## Native allocations\n"
    puts "Heap allocations of each whole program (Cranelift's counters), n = $nativeN, and per record over its baseline.\n"
    puts "| program | allocations | Bytes | Structs | Lists | per record over baseline |"
    puts "|---|---:|---:|---:|---:|---:|"
    set seen [dict create]
    foreach {label kind base} $operations {
        foreach k [list $base $kind] {
            if {[dict exists $seen $k]} continue
            set report [native::allocationReport [program $k $nativeN] summary]
            dict set seen $k [dict get $report total allocations]
            set over [expr {$k eq $base ? "" : [format %.2f [expr {([dict get $seen $k] - [dict get $seen $base]) / double($nativeN)}]]}]
            puts "| $k | [dict get $report total allocations] | [dict get $report byKind Bytes allocations] | [dict get $report byKind Struct allocations] | [dict get $report byKind List allocations] | $over |"
        }
    }
}

# ---------------------------------------------------------------------------
# Compilation cost

# A program of K layouts L0..L{K-1} (eight scalar fields of every width at
# gapped offsets) parsed and emitted once each -- or, STRUCTS 1, K ordinary
# structs of the same fields constructed and read.
proc scaleText {k structs} {
    set widths {1 2 4 8 1 2 4 8}
    set types {std::binary::U8 std::binary::I16 std::binary::U32 std::binary::I64 std::binary::I8 std::binary::U16 std::binary::I32 std::binary::U64}
    set text "import std::abi::bytes\nimport std::binary\n\n"
    set calls {}
    for {set j 0} {$j < $k} {incr j} {
        set offset 0
        set fields {}
        set inits {}
        foreach w $widths t $types index {0 1 2 3 4 5 6 7} {
            set offset [expr {($offset + $w - 1) / $w * $w}]
            lappend fields [list f$index $t $offset]
            lappend inits "f$index: $index"
            incr offset $w
        }
        set size [expr {($offset + 7) / 8 * 8}]
        if {$structs} {
            append text "struct L$j:\n"
            foreach field $fields {
                lassign $field name type offset
                append text "    $name: $type\n"
            }
            append text "\nfn use${j}() -> int:\n    v = L$j {[join $inits {, }]}\n    v.f1 + v.f6\n\n"
        } else {
            append text "layout L$j:\n    size $size\n    align 8\n"
            foreach field $fields {
                lassign $field name type offset
                append text "    field $name: $type at $offset\n"
            }
            append text "\nfn use${j}() -> int errors LayoutLengthMismatch:\n    v = std::binary::parse(L$j, std::binary::emit(LayoutStruct\[L$j\] {[join $inits {, }]}))\n    v.f1 + v.f6\n\n"
        }
        lappend calls "use${j}()"
    }
    if {$structs} {
        append text "fn all() -> int:\n    [join $calls { + }]\nall()\n"
    } else {
        append text "fn all() -> int errors LayoutLengthMismatch:\n    [join $calls { + }]\nr = all():\n    on LayoutLengthMismatch:\n        -1\nr\n"
    }
    return $text
}

# {FRONT TCL NIR CRANELIFT} milliseconds of the scale program.
proc compileCost {structs} {
    set text [scaleText $::layoutCount $structs]
    set front [lindex [time {set hir [surface::compile $text scale.bot -warnings off]}] 0]
    set tcl [lindex [time {core::compiler::compileHir $hir}] 0]
    set nirTime ""
    set cranelift ""
    if {"native" in $::backends} {
        lassign [native::measure $hir 1] nirTime cranelift
    }
    return [list $front $tcl $nirTime $cranelift]
}

proc ms {micros} {
    return [expr {$micros eq "" ? "-" : [format "%.1f ms" [expr {$micros / 1000.0}]]}]
}

proc perDecl {micros} {
    return [expr {$micros eq "" ? "-" : [format "%.0f us" [expr {double($micros) / $::layoutCount}]]}]
}

puts "\n## Compilation cost\n"
puts "A generated program of $::layoutCount declarations of eight scalar fields each, every one used once; whole program, then per declaration.\n"
puts "| program | front end | Tcl compiler | native lowering (NIR) | Cranelift compile |"
puts "|---|---:|---:|---:|---:|"
foreach {label structs} [list "$::layoutCount layouts, each parsed from its own emission and read" 0 "$::layoutCount ordinary structs, each constructed and read" 1] {
    lassign [compileCost $structs] front tcl nirTime cranelift
    puts "| $label | [ms $front] ([perDecl $front]) | [ms $tcl] ([perDecl $tcl]) | [ms $nirTime] ([perDecl $nirTime]) | [ms $cranelift] ([perDecl $cranelift]) |"
}
