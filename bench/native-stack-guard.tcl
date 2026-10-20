# native-stack-guard.tcl -- what the native stack guard costs ordinary code
# (MACOS-AARCH64-MILESTONE-4.md, "Performance observations").
#
#   tclsh9.0 bench/native-stack-guard.tcl -baseline BINARY ?-runs N? ?-rounds R?
#   tclsh9.0 bench/native-stack-guard.tcl -baseline-rev REV ?-runs N? ?-rounds R?
#
# Runs four workloads -- a recursion that stays within the stack, a loop, an
# allocating loop and a coroutine resumed in a loop -- on this checkout's
# botlish-native and on BINARY, a driver built from another revision (the
# one before the change being measured) -- or, with -baseline-rev, the
# driver of revision REV (a commit or a branch of origin, fetched if this
# clone lacks it, built in a temporary worktree removed afterwards: how CI
# compares on a macOS runner, tests/platform/tier.tcl's native-stack-bench)
# -- and prints, per workload, the
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
set baselineRev ""
foreach {option value} $args {
    switch -- $option {
        -baseline { set baseline $value }
        -baseline-rev { set baselineRev $value }
        -runs { set runs $value }
        -rounds { set rounds $value }
        default { error "unknown option $option" }
    }
}
set worktree ""
if {$baselineRev ne ""} {
    # REV's driver, built from a worktree of it (cargo finds the worktree's
    # .cargo/config.toml from its working directory).
    if {[catch {exec git -C $root rev-parse --verify --quiet "$baselineRev^{commit}"} commit]} {
        exec git -C $root fetch --quiet --depth 1 origin $baselineRev
        set commit [exec git -C $root rev-parse FETCH_HEAD]
    }
    set worktree [file join [file tempdir botlish-stack-bench] tree]
    exec git -C $root worktree add --quiet --detach $worktree $commit
    set here [pwd]
    cd $worktree
    exec cargo build --release --quiet --manifest-path [file join $worktree native Cargo.toml] 2>@stderr
    cd $here
    set baseline [file join $worktree native target release botlish-native]
    puts "baseline: revision $baselineRev ($commit), built in $worktree"
}
if {$baseline eq "" || ![file executable $baseline]} {
    puts stderr "usage: tclsh9.0 bench/native-stack-guard.tcl (-baseline BINARY | -baseline-rev REV) ?-runs N? ?-rounds R?"
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
    count(i - 1, acc + 3)

count(2000000, 0)
} \
    allocation {import std::str
fn churn(i: int, total: int) -> int:
    if i == 0:
        return total
    s = std::str::concat("ab", "cd")
    churn(i - 1, total + std::str::length(s))

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
if {$worktree ne ""} {
    exec git -C $root worktree remove --force $worktree
    file delete -force [file dirname $worktree]
}
