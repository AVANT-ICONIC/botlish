# static-compile.tcl -- the performance report of `static compile:`
# (STATIC-COMPILE.md, "Performance").
#
#   tclsh9.0 bench/static-compile.tcl ?-runs N? ?-n N? ?-native-n N?
#                                     ?-blocks LIST? ?-backends LIST?
#
# Compile time (best of RUNS, surface::compile, warnings off):
#
#   1. an ordinary valid block (a function body);
#   2. the same block under `static compile:`;
#   3. an invalid block under `static compile:`;
#   4. a synthetic file of K independent static blocks, each in its own
#      function (K from -blocks), all valid, and with a third rejected in
#      resolution (UNBOUND) and a third rejected by a check (TYPE) -- beside
#      the same file with every block written plainly (the valid ones) --
#      with the number of builds the decisions took and the time per build.
#
# Run time (best of RUNS, compilation excluded): a loop calling a function
# whose body is an accepted static block, against the same body written
# plainly (they compile to the same code: the difference must be noise),
# and a loop calling a function whose static block was rejected and
# handling its CompilerError, against the same failure written by hand as
# `fail compiler::CompilerError {...}` (the same ordinary payload error);
# with natively the heap allocations of each.

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
interp recursionlimit {} 200000

set runs 5
set n 2000
set nativeN 200000
set blocks {10 25 50}
set backends {interp compile native}
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -n { set n $value }
        -native-n { set nativeN $value }
        -blocks { set blocks $value }
        -backends { set backends $value }
        default { error "unknown option $option" }
    }
}

# Best-of-RUNS milliseconds compiling TEXT; sets ::lastHir.
proc compileMs {text} {
    set best ""
    for {set i 0} {$i < $::runs} {incr i} {
        set us [lindex [time {set ::lastHir [surface::compile $text -warnings off]}] 0]
        if {$best eq "" || $us < $best} {
            set best $us
        }
    }
    return [expr {$best / 1000.0}]
}

proc ms {x} {
    return [format "%.1f ms" $x]
}

set prelude "import compiler\nimport list\n\nfn needs_int(v: int) -> int:\n    v\n\n"
set body "        a = x * 3\n        b = \[a, a + 1, a + 2\]\n        list::length(b) + a\n"

puts "## Compile time\n"
puts "| program | compile | builds |"
puts "|---|---|---|"
set plainText "${prelude}fn f(x: int) -> int:\n    if true:\n$body\nf(1)\n"
set staticText "${prelude}fn f(x: int) -> int:\n    static compile:\n$body\nf(1)\n"
set invalidText "${prelude}fn f(x: int) -> int errors compiler::CompilerError:\n    static compile:\n        missing + x\n\n0\n"
set t1 [compileMs $plainText]
puts "| 1. ordinary valid block (`if true:`) | [ms $t1] | 1 |"
set t2 [compileMs $staticText]
puts "| 2. the same block under `static compile:` | [ms $t2] | [dict get $::lastHir staticRounds] |"
set t3 [compileMs $invalidText]
puts "| 3. an invalid block under `static compile:` | [ms $t3] | [dict get $::lastHir staticRounds] |"

# A file of K blocks; MIX all-valid or mixed (a third UNBOUND, a third TYPE);
# PLAIN 1 writes every valid block plainly and leaves the invalid ones out.
proc manyBlocks {k mix plain} {
    set text $::prelude
    for {set i 0} {$i < $k} {incr i} {
        set kind [expr {$mix eq "mixed" ? $i % 3 : 0}]
        if {$plain && $kind != 0} continue
        append text "fn t$i\(x: int) errors compiler::CompilerError:\n    [expr {$plain ? "if true:" : "static compile:"}]\n"
        switch -- $kind {
            0 { append text "        a = x + $i\n        a * 2\n\n" }
            1 { append text "        missing_$i + x\n\n" }
            2 { append text "        needs_int(\"s$i\") + x\n\n" }
        }
    }
    append text "0\n"
    return $text
}

puts ""
puts "| K blocks | plain (valid only) | all valid, static | builds | mixed (1/3 UNBOUND, 1/3 TYPE), static | builds | per build |"
puts "|---|---|---|---|---|---|---|"
foreach k $blocks {
    set plain [compileMs [manyBlocks $k valid 1]]
    set valid [compileMs [manyBlocks $k valid 0]]
    set validBuilds [dict get $::lastHir staticRounds]
    set mixed [compileMs [manyBlocks $k mixed 0]]
    set mixedBuilds [dict get $::lastHir staticRounds]
    puts "| $k | [ms $plain] | [ms $valid] | $validBuilds | [ms $mixed] | $mixedBuilds | [ms [expr {$mixed / $mixedBuilds}]] |"
}

puts "\n## Run time\n"

# A loop of N iterations, each calling f(i) through BODY lines.
proc loopProgram {decls n call} {
    return "${::prelude}${decls}fn run(n: int, k: int) -> int:\n    xs = loop i from 0 to n:\n$call\n    list::length(xs)\n\nrun($n, 1)\n"
}

set acceptedDecls "fn f(x: int) -> int:\n    static compile:\n        x * 3 + 1\n\n"
set plainDecls "fn f(x: int) -> int:\n    x * 3 + 1\n\n"
set callOk "        f(i)"
set rejectedDecls "fn f(x: int) -> int errors compiler::CompilerError:\n    static compile:\n        missing + x\n\n"
set handWrittenDecls "fn f(x: int, k: int) -> int errors compiler::CompilerError:\n    if k > 0:\n        fail compiler::CompilerError \{\n            code: compiler::DiagnosticCode::Unbound,\n            primary: compiler::SourceLocation \{line: 8, column: 9\},\n            related: \[\],\n            message: \"unbound name \\\"missing\\\"\",\n        \}\n    x\n\n"
set callFail "        r = f(i):\n            on compiler::CompilerError \{code, primary\}:\n                primary.line\n        r"
set callFailK "        r = f(i, k):\n            on compiler::CompilerError \{code, primary\}:\n                primary.line\n        r"

proc timeOn {backend hir} {
    if {$backend eq "native"} {
        lassign [native::measure $hir $::runs] lower compile best collections value
        return $best
    }
    if {$backend eq "compile"} {
        # The Tcl compiler compiles the HIR itself, once.
        set run [list core::compiler::evalUnit [core::compiler::compileHir $hir]]
    } else {
        core::useBackend $backend
        set run [list core::evalProgram [hir::lower $hir]]
    }
    {*}$run
    set best ""
    for {set i 0} {$i < $::runs} {incr i} {
        set micros [lindex [time {{*}$run}] 0]
        if {$best eq "" || $micros < $best} {
            set best $micros
        }
    }
    return $best
}

puts "| operation (ns per call) | [join $backends { | }] |"
puts "|---|[string repeat ---| [llength $backends]]"
foreach {label decls call} [list \
        "accepted static block" $acceptedDecls $callOk \
        "the same body written plainly" $plainDecls $callOk \
        "rejected static block, CompilerError handled" $rejectedDecls $callFail \
        "the same CompilerError written by hand, handled" $handWrittenDecls $callFailK] {
    set cells {}
    foreach b $backends {
        set count [expr {$b eq "native" ? $nativeN : $n}]
        set hir [surface::compile [loopProgram $decls $count $call] -warnings off]
        lappend cells [format "%.1f" [expr {[timeOn $b $hir] * 1000.0 / $count}]]
    }
    puts "| $label | [join $cells { | }] |"
}

puts "\n## Native heap allocations (one call)\n"
puts "| program | allocations | bytes |"
puts "|---|---|---|"
foreach {label decls call} [list \
        "accepted static block" $acceptedDecls $callOk \
        "the same body written plainly" $plainDecls $callOk \
        "rejected static block, handler reads code and primary" $rejectedDecls $callFail \
        "the same CompilerError written by hand" $handWrittenDecls $callFailK] {
    set report [native::allocationReport [surface::compile [loopProgram $decls 1 $call] -warnings off] summary]
    set base [native::allocationReport [surface::compile [loopProgram "fn f(x: int) -> int:\n    x\n\n" 1 $callOk] -warnings off] summary]
    puts "| $label | [expr {[dict get $report total allocations] - [dict get $base total allocations]}] | [expr {[dict get $report total allocatedBytes] - [dict get $base total allocatedBytes]}] |"
}
