# allocs.tcl -- managed-heap allocations per table operation
# (HASH-TABLE-EXPERIMENT.md, "Theorem and measurement"): drivers/bench.bot's
# lookup modes run as one pass and as P passes over M queries in one table
# (SPEC.md section 6, tools/bench.tcl -passes), and the native allocation
# report's difference divided by (P - 1) M. Everything else the program
# allocates -- the key lists, the build -- cancels exactly, so a lookup that
# allocates nothing reads 0 whatever the table. Counted: the Botlish
# managed heap (objects and bytes), not Rust-side allocations (valgrind
# shows those: RO-1).
#
#   BOTLISH_HT_ROOT=TREE tclsh9.0 audit/hash-table/tools/allocs.tcl
#       ?-impls LIST? ?-keys LIST? ?-sizes LIST? ?-modes LIST? ?-ops M?
#       ?-passes P? ?-tag NAME? ?-out FILE?
#
# TSV: tag impl keys n mode objects-per-op bytes-per-op

source [file join [file dirname [file normalize [info script]]] lib.tcl]

set options [dict create -impls {lpa} -keys {int-dense str-short point} -sizes {1024} \
    -modes {hit miss member replace} -ops 20000 -passes 3 -tag "" -out ""]
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {![dict exists $options $arg]} { error "unknown option $arg" }
    dict set options $arg [lindex $argv [incr i]]
}
set kinds {int-dense {int 0} int-sparse {int 1} str-short {str 4} str-medium {str 5} point {point 6}}
set ops [dict get $options -ops]
set passes [dict get $options -passes]
set channel [expr {[dict get $options -out] ne "" ? [open [dict get $options -out] a] : ""}]

# {objects bytes} the managed heap allocated in one run.
proc allocated {hir argList} {
    set r [ht::allocNative $hir $argList]
    return [list [dict get $r total allocations] [dict get $r total allocatedBytes]]
}

try {
    foreach impl [dict get $options -impls] {
        foreach keys [dict get $options -keys] {
            lassign [dict get $kinds $keys] module kind
            set hir [ht::compile [ht::app allocs-$impl bench.bot $impl $module]]
            foreach n [dict get $options -sizes] {
                foreach mode [dict get $options -modes] {
                    lassign [allocated $hir [list $mode $kind $n $ops 1]] objects1 bytes1
                    lassign [allocated $hir [list $mode $kind $n $ops $passes]] objectsP bytesP
                    set per [expr {double(($passes - 1) * $ops)}]
                    set row [list [dict get $options -tag] $impl $keys $n $mode \
                        [format %.3f [expr {($objectsP - $objects1) / $per}]] \
                        [format %.1f [expr {($bytesP - $bytes1) / $per}]]]
                    puts [join $row \t]
                    if {$channel ne ""} { puts $channel [join $row \t]; flush $channel }
                }
            }
        }
    }
} finally {
    if {$channel ne ""} { close $channel }
    ht::cleanup
}
