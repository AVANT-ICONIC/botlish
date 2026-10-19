# mixed.tcl -- the hash-table experiment's mixed workloads (SPEC.md section
# 6; HASH-TABLE-EXPERIMENT.md, "Mixed workloads"): drivers/bfs.bot (a
# visited table of Points), memo.bot (Int keys; memo2.bot is the same
# workload restructured to avoid the copies memo.bot's natural recursion
# makes) and freq.bot (String keys)
# with each implementation, natively, best of R. freq's time is net of its
# baseline (the same tokens built, nothing counted), as the Rust reference
# times only the counting.
#
#   tclsh9.0 audit/hash-table/tools/mixed.tcl ?-impls LIST? ?-runs R? ?-tag T? ?-out FILE?
#
# TSV: tag impl workload size best-us checksum

source [file join [file dirname [file normalize [info script]]] lib.tcl]

set options [dict create -impls {listmap chain0 ht0 chain lpa lpmono rh cd} -runs 5 -tag "" -out "" \
    -bfs {64 256} -memo {1000 10000} -memo2 {10000 100000} -freq {16384 262144}]
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {![dict exists $options $arg]} { error "unknown option $arg" }
    dict set options $arg [lindex $argv [incr i]]
}
set channel [expr {[dict get $options -out] ne "" ? [open [dict get $options -out] a] : ""}]
try {
    foreach impl [dict get $options -impls] {
        foreach {work keys} {bfs point memo int memo2 int freq str} {
            # memo.bot copies its whole table per call on a compiler without
            # VS-2 (quadratic: N = 100000 runs for most of an hour), so its
            # sizes are smaller than memo2.bot's.
            set sizes [dict get $options -$work]
            # listmap is quadratic: only the smaller size.
            if {$impl eq "listmap"} { set sizes [lrange $sizes 0 0] }
            set hir [ht::compile [ht::app mixed-$impl-$work $work.bot $impl $keys]]
            set argLists {}
            foreach n $sizes {
                lappend argLists [list $n]
                if {$work eq "freq"} { lappend argLists [list $n none] }
            }
            set results [ht::benchNative $hir $argLists [dict get $options -runs]]
            set k 0
            foreach n $sizes {
                lassign [lindex $results $k] us sum
                incr k
                if {$work eq "freq"} {
                    lassign [lindex $results $k] base
                    incr k
                    set us [format %.1f [expr {$us - $base}]]
                }
                set row [list [dict get $options -tag] $impl $work $n $us $sum]
                puts [join $row \t]
                if {$channel ne ""} { puts $channel [join $row \t]; flush $channel }
            }
        }
    }
} finally {
    if {$channel ne ""} { close $channel }
    ht::cleanup
}
