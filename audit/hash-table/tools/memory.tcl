# memory.tcl -- the hash-table experiment's memory overhead
# (HASH-TABLE-EXPERIMENT.md, "Memory"; brief section 8), from the native
# allocation report of drivers/bench.bot (one table of N keys) minus its
# `keys` mode (the inputs alone), per entry:
#
#   allocated   bytes allocated building the table (`presized`: fresh(N)
#               then N inserts; `build`: fresh(0), with every growth's
#               tables and every replaced bucket List included)
#   peak        the exact peak of live bytes while building it, from a
#               collection before every allocation (BOTLISH_NATIVE_GC_STRESS:
#               slow, so only for N <= 4096); it includes a growth's moment
#               of two tables
#
# Counted: the Botlish managed heap (headers, MutableArray backings, List
# and struct payloads), not Rust-side allocations such as a MutableVector's
# backing growth (the vector counters' growthBytes, added to `allocated`
# here) or rt_hash's temporary text.
#
#   tclsh9.0 audit/hash-table/tools/memory.tcl ?-sizes LIST? ?-keys int|str|point? ?-out FILE? IMPL...
#
# TSV: impl keys n mode allocated-bytes-per-entry peak-bytes-per-entry objects-per-entry

source [file join [file dirname [file normalize [info script]]] lib.tcl]

set sizes {716 1024 4096 11468 16384}
set keys int
set out ""
set impls {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    switch -- [lindex $argv $i] {
        -sizes { set sizes [lindex $argv [incr i]] }
        -keys { set keys [lindex $argv [incr i]] }
        -out { set out [lindex $argv [incr i]] }
        default { lappend impls [lindex $argv $i] }
    }
}
set kind [dict get {int 0 str 4 point 6} $keys]
set channel [expr {$out ne "" ? [open $out a] : ""}]

# The report's {allocatedBytes peakLiveBytes allocations} for one run.
proc measured {hir argList stress} {
    if {$stress} { set ::env(BOTLISH_NATIVE_GC_STRESS) 1 }
    try {
        set r [ht::allocNative $hir $argList]
    } finally {
        unset -nocomplain ::env(BOTLISH_NATIVE_GC_STRESS)
    }
    set growth 0
    if {[dict exists $r mutableVector growthBytes]} { set growth [dict get $r mutableVector growthBytes] }
    return [list [expr {[dict get $r total allocatedBytes] + $growth}] [dict get $r total peakLiveBytes] [dict get $r total allocations]]
}

try {
    foreach impl $impls {
        set hir [ht::compile [ht::app memory-$impl bench.bot $impl $keys]]
        foreach n $sizes {
            set stress [expr {$n <= 4096}]
            lassign [measured $hir [list keys $kind $n 1 1] 0] baseBytes _ baseObjects
            lassign [measured $hir [list keys $kind $n 1 1] $stress] _ basePeak _
            foreach mode {presized build} {
                lassign [measured $hir [list $mode $kind $n 1 1] 0] bytes _ objects
                set peak ""
                if {$stress} {
                    lassign [measured $hir [list $mode $kind $n 1 1] 1] _ p _
                    set peak [format %.1f [expr {double($p - $basePeak) / $n}]]
                }
                set row [list $impl $keys $n $mode [format %.1f [expr {double($bytes - $baseBytes) / $n}]] $peak \
                    [format %.2f [expr {double($objects - $baseObjects) / $n}]]]
                puts [join $row \t]
                if {$channel ne ""} { puts $channel [join $row \t]; flush $channel }
            }
        }
    }
} finally {
    if {$channel ne ""} { close $channel }
    ht::cleanup
}
