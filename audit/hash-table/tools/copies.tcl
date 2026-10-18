# copies.tcl -- the hash-table experiment's copy audit (SPEC.md section 7):
# for each implementation, the native allocation report of the bench
# driver's build, replace, drop and hit modes, its mutableArray (and
# mutableVector) counters and its object allocations. Steady state must show
# 0 shares and 0 detaches.
#
#   tclsh9.0 audit/hash-table/tools/copies.tcl ?-n N? ?-m M? ?-keys KIND? IMPL...

source [file join [file dirname [file normalize [info script]]] lib.tcl]
source [file join [file dirname [file normalize [info script]]] fuzzlib.tcl]

set n 1024
set m 2000
set keys int
set impls {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    switch -- [lindex $argv $i] {
        -n { set n [lindex $argv [incr i]] }
        -m { set m [lindex $argv [incr i]] }
        -keys { set keys [lindex $argv [incr i]] }
        default { lappend impls [lindex $argv $i] }
    }
}
set kind [dict get {int 0 str 4 point 6} $keys]
set status 0
try {
    foreach impl $impls {
        set hir [ht::compile [ht::app copies-$impl bench.bot $impl $keys]]
        foreach mode {keys build replace drop hit} {
            if {$mode eq "drop" && [ht::dropsOf $impl] eq "nodrop"} continue
            set r [ht::allocNative $hir [list $mode $kind $n $m 1]]
            set ma [dict get $r mutableArray]
            set mv [expr {[dict exists $r mutableVector] ? [dict get $r mutableVector] : ""}]
            set objects [dict get $r total allocations]
            puts [format "%-10s %-8s objects %8d  mutableArray {%s}%s" $impl $mode $objects $ma \
                [expr {$mv ne "" ? "  mutableVector {$mv}" : ""}]]
            if {[dict get $ma shares] || [dict get $ma detaches]} { set status 1 }
        }
    }
} finally {
    ht::cleanup
}
exit $status
