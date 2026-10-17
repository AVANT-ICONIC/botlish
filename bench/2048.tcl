# 2048.tcl -- the performance report of the 2048 engine
# (examples/games/2048/, 2048-ENGINE-WORKLOAD.md, "Performance").
#
#   tclsh9.0 bench/2048.tcl ?-runs N? ?-interp N? ?-compile N? ?-native N?
#
# Runs examples/games/2048/bench.bot's `benchmark(MOVES, seed)` -- exactly
# MOVES engine moves with spawns, directions and spawn positions from a
# generator seeded at run time, a game that is over replaced by a new one --
# on every backend, with a move count per backend (defaults: interp 300,
# compile 3000, both native backends 100000). The program is compiled once
# per move count, with the engine beside it as its application module (the
# engine is not in lib/).
#
# Reported per backend: the best of RUNS in-process executions (compilation
# excluded: the Tcl backends run in this process; native::measure times the
# run after Cranelift has compiled), microseconds per move, the checksum
# (which every backend must agree on for the same move count), and natively
# the NIR lowering time, the Cranelift compile time and the managed-heap
# allocation counters (native::allocationReport) per move. The front end's
# own time is reported once.

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root examples games 2048 run.tcl]
source [file join $root bench backends.tcl]
interp recursionlimit {} 1000000

set runs 3
set sizes [dict create interp 300 compile 3000 native 100000]
foreach {option value} $argv {
    switch -- $option {
        -runs { set runs $value }
        -interp { dict set sizes interp $value }
        -compile { dict set sizes compile $value }
        -native { dict set sizes native $value }
        default { error "unknown option $option" }
    }
}

set path [file join $root examples games 2048 bench.bot]
set template [core::ReadFile $path]
if {![regexp -line {^benchmark\(\d+, (.*)\)$} $template -> seedExpr]} {
    error "bench.bot no longer ends with benchmark(N, SEED)"
}

# The HIR of bench.bot playing MOVES moves, and the front end's seconds.
proc program {moves} {
    global template path
    regsub -line {^benchmark\(\d+, (.*)\)$} $template "benchmark($moves, \\1)" text
    set start [clock microseconds]
    set hir [surface::compile $text $path -warnings off -root [file dirname $path]]
    return [list $hir [expr {([clock microseconds] - $start) / 1e6}]]
}

proc best {script runs} {
    set best ""
    for {set i 0} {$i < $runs} {incr i} {
        set us [lindex [time {uplevel 1 $script}] 0]
        if {$best eq "" || $us < $best} { set best $us }
    }
    return $best
}

set rows {}
foreach backend {interp compile cranelift-generic cranelift} {
    set moves [dict get $sizes [expr {[string match cranelift* $backend] ? "native" : $backend}]]
    lassign [program $moves] hir frontSeconds
    if {[string match cranelift* $backend]} {
        set options [expr {$backend eq "cranelift-generic" ? {-specialize 0} : {}}]
        lassign [native::measure $hir $runs {*}$options] lowerUs compileUs bestUs collections value
        set alloc [native::allocationReport $hir summary 1 {*}$options]
        set total [dict get $alloc total]
        set extra [format "lower %6.0f ms, cranelift %5.0f ms, %6.2f allocs/move, %7.0f B/move, %d GC cycles" \
            [expr {$lowerUs / 1000.0}] [expr {$compileUs / 1000.0}] \
            [expr {double([dict get $total allocations]) / $moves}] \
            [expr {double([dict get $total allocatedBytes]) / $moves}] [dict get $alloc gc cycles]]
        set shown [core::value::show $value]
    } else {
        set bestUs [best {set value [game2048::run $hir $backend]} $runs]
        set extra ""
        set shown [core::value::show $value]
    }
    lappend rows [list $backend $moves $bestUs $shown $frontSeconds $extra]
}
puts [bench::backends::manifest {interp compile native}]
puts "  (cranelift-generic: Cranelift without call-site specialization)"
puts ""
puts [format "%-18s %8s %12s %10s %12s  %s" backend moves "best ms" "us/move" checksum "front end"]
foreach row $rows {
    lassign $row backend moves bestUs shown frontSeconds extra
    puts [format "%-18s %8d %12.1f %10.2f %12s  %5.2f s" $backend $moves [expr {$bestUs / 1000.0}] \
        [expr {double($bestUs) / $moves}] $shown $frontSeconds]
    if {$extra ne ""} { puts [format "%-18s %s" "" $extra] }
}
