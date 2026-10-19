# instructions.tcl -- instructions executed per table operation, from
# callgrind (HASH-TABLE-EXPERIMENT.md, "Compiler experiments"): the same
# runs and formulas as tools/bench.tcl (SPEC.md section 6), each a native
# run of drivers/bench.bot under valgrind's callgrind, counting the
# process's instructions. Counts are deterministic and independent of the
# machine's load, so they compare compiler trees exactly where timings
# need an idle machine; they do not see cache misses or branch costs. One
# run per (implementation, keys, size, mode) and its baseline: compilation
# and start-up are the same in both and cancel.
#
#   BOTLISH_HT_ROOT=TREE tclsh9.0 audit/hash-table/tools/instructions.tcl
#       ?-impls LIST? ?-keys LIST? ?-sizes LIST? ?-modes LIST? ?-ops M?
#       ?-tag NAME? ?-out FILE? ?-reference 1?
#
# With -reference 1, IMPLS are the Rust reference's (lp, rh, chain, std,
# stdb, listmap): its sweep timed once and twice (-runs 1 and 2) under
# callgrind, the difference divided by the timed phase's operations -- the
# same phase the Botlish formulas isolate.
#
# TSV: tag impl keys n mode instructions-per-op

source [file join [file dirname [file normalize [info script]]] lib.tcl]

set options [dict create -impls {lpa} -keys {int-dense} -sizes {1024} -modes {build hit miss replace} \
    -ops 20000 -tag "" -out "" -reference 0]
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {![dict exists $options $arg]} { error "unknown option $arg" }
    dict set options $arg [lindex $argv [incr i]]
}
set kinds {int-dense {int 0} int-sparse {int 1} str-short {str 4} str-medium {str 5} point {point 6}}
set ops [dict get $options -ops]
set channel [expr {[dict get $options -out] ne "" ? [open [dict get $options -out] a] : ""}]

# The instructions callgrind counts for one native run of NIR with argv ARGLIST.
proc instructions {nirPath argList} {
    set argvPath [file join [ht::workDir] run.argv]
    core::process::withArgv [ht::argvOf {*}$argList] {
        ht::writeFile $argvPath "[core::process::driverArgv]\n"
    }
    set out [exec valgrind --tool=callgrind --smc-check=all-non-file --callgrind-out-file=/dev/null \
        [native::binary] bench 1 --argv-file $argvPath $nirPath 2>@1]
    if {![regexp {Collected : (\d+)} $out -> n]} { error "no instruction count: $out" }
    return $n
}

# The instructions of one reference sweep of IMPL/KIND/MODE/N with RUNS runs.
proc referenceInstructions {impl kind mode n runs} {
    set out [exec valgrind --tool=callgrind --callgrind-out-file=/dev/null \
        [file join $ht::base reference target release hash-table-reference] sweep -impls $impl -keys $kind \
        -modes $mode -sizes $n -ops $::ops -runs $runs 2>@1]
    if {![regexp {Collected : (\d+)} $out -> c]} { error "no instruction count: $out" }
    return $c
}

if {[dict get $options -reference]} {
    try {
        foreach impl [dict get $options -impls] {
            foreach keyName [dict get $options -keys] {
                foreach n [dict get $options -sizes] {
                    set reps [expr {max(1, $ops / $n)}]
                    foreach mode [dict get $options -modes] {
                        set phase [expr {$mode in {build presized} ? $reps * $n : $ops}]
                        set c [expr {[referenceInstructions $impl $keyName $mode $n 2] - [referenceInstructions $impl $keyName $mode $n 1]}]
                        set row [list [dict get $options -tag] $impl $keyName $n $mode [format %.1f [expr {double($c) / $phase}]]]
                        puts [join $row \t]
                        if {$channel ne ""} { puts $channel [join $row \t]; flush $channel }
                    }
                }
            }
        }
    } finally {
        if {$channel ne ""} { close $channel }
    }
    exit 0
}

try {
    foreach impl [dict get $options -impls] {
        foreach keyName [dict get $options -keys] {
            lassign [dict get $kinds $keyName] module kind
            set hir [ht::compile [ht::app ir-$impl-$keyName bench.bot $impl $module]]
            set nirPath [file join [ht::workDir] $impl-$keyName.nir]
            ht::writeFile $nirPath [native::nir $hir]
            foreach n [dict get $options -sizes] {
                set reps [expr {max(1, $ops / $n)}]
                set count [dict create]
                dict set count keys [instructions $nirPath [list keys $kind $n $ops $reps]]
                dict set count build1 [instructions $nirPath [list build $kind $n $ops 1]]
                foreach mode [dict get $options -modes] {
                    switch -- $mode {
                        build - presized { set c [instructions $nirPath [list $mode $kind $n $ops $reps]]
                                           set per [expr {double($c - [dict get $count keys]) / ($reps * $n)}] }
                        hit - miss - replace { set c [instructions $nirPath [list $mode $kind $n $ops 1]]
                                               set per [expr {double($c - [dict get $count build1]) / $ops}] }
                        default { error "unknown mode $mode" }
                    }
                    set row [list [dict get $options -tag] $impl $keyName $n $mode [format %.1f $per]]
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
