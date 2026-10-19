# native-stack-guard.tcl -- what the native stack guard costs ordinary code
# (MACOS-AARCH64-MILESTONE-4.md, "Performance observations").
#
#   tclsh9.0 bench/native-stack-guard.tcl -baseline BINARY ?-runs N? ?-rounds R?
#
# Runs four workloads -- a recursion that stays within the stack, a loop, an
# allocating loop and a coroutine resumed in a loop -- on this checkout's
# botlish-native and on BINARY, a driver built from another revision (the
# one before the change being measured), and prints, per workload, the
# median of R rounds' median per-run time on each and their ratio. The two
# drivers alternate within each round, and run the same NIR: this
# checkout's front end lowers each program once, so only the driver -- the
# runtime and the code generator -- differs. A coarse check, made to show a
# catastrophic regression (a per-call syscall, a per-call stack query), not
# a few percent.

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]

set runs 20
set rounds 5
set baseline ""
foreach {option value} $args {
    switch -- $option {
        -baseline { set baseline $value }
        -runs { set runs $value }
        -rounds { set rounds $value }
        default { error "unknown option $option" }
    }
}
if {$baseline eq "" || ![file executable $baseline]} {
    puts stderr "usage: tclsh9.0 bench/native-stack-guard.tcl -baseline BINARY ?-runs N? ?-rounds R?"
    exit 2
}
set current [native::binary]

set workloads [dict create \
    recursion {fn fib(n: int) -> int:
    if n < 2:
        return n
    fib(n - 1) + fib(n - 2)

fib(25)
} \
    loop {fn count(i: int, acc: int) -> int:
    if i == 0:
        return acc
    count(i - 1, acc + i % 7)

count(2000000, 0)
} \
    allocation {import str
fn churn(i: int, total: int) -> int:
    if i == 0:
        return total
    s = str::concat("ab", "cd")
    churn(i - 1, total + str::length(s))

churn(200000, 0)
} \
    coroutine {struct V:
    n: int

fn counter(m: int) -> V:
    loop i from 0 to m:
        yield V {n: i}
    return V {n: m}

coroutine {step, first} = counter(100000)
loop i from 0 to 100000:
    step().n
100000
}]

proc median {values} {
    set sorted [lsort -real $values]
    return [lindex $sorted [expr {[llength $sorted] / 2}]]
}

# The median per-run nanoseconds of RUNS runs of NIR text TEXT on BINARY.
proc timeRuns {binary text runs} {
    set ::env(BOTLISH_NATIVE_BIN) $binary
    try {
        set lines [native::Driver bench $text $runs]
    } finally {
        unset ::env(BOTLISH_NATIVE_BIN)
    }
    native::Outcome $lines
    set times [lrange [lsearch -inline $lines {times *}] 1 end]
    return [median $times]
}

puts "native stack guard overhead on [core::cabi::hostTarget]: $runs runs x $rounds rounds"
puts "  current:  $current"
puts "  baseline: $baseline"
puts [format "%-12s %14s %14s %8s" workload "baseline us" "current us" ratio]
dict for {name source} $workloads {
    set text [native::nir [surface::compile $source -warnings off]]
    set samples [dict create baseline {} current {}]
    for {set round 0} {$round < $rounds} {incr round} {
        set order [expr {$round % 2 ? {current baseline} : {baseline current}}]
        foreach which $order {
            dict lappend samples $which [timeRuns [set $which] $text $runs]
        }
    }
    set before [expr {[median [dict get $samples baseline]] / 1000.0}]
    set after [expr {[median [dict get $samples current]] / 1000.0}]
    puts [format "%-12s %14.1f %14.1f %8.3f" $name $before $after [expr {$after / $before}]]
}
