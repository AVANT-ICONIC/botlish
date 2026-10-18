# bench.tcl -- the hash-table experiment's timings (HASH-TABLE-EXPERIMENT.md,
# "Performance"; SPEC.md section 6).
#
#   tclsh9.0 audit/hash-table/tools/bench.tcl ?-impls LIST? ?-keys LIST?
#       ?-sizes LIST? ?-modes LIST? ?-ops M? ?-runs R? ?-backend B?
#       ?-out FILE? ?-edits {OLD NEW ...}? ?-tag NAME? ?-lower OPTIONS?
#
# For every implementation and key kind: drivers/bench.bot with the
# implementation beside it, compiled once and (natively) lowered once; then
# one run per size and mode, each with argv MODE KIND N M REPS. A mode's
# operations cost its time minus its baseline's (SPEC.md section 6):
#
#   build, presized,   (T - T[keys]) / (REPS * N)      per insert
#   bulk               (bulk: table::from_lists)
#   hit, miss, replace (T - T[build, REPS 1]) / M      per operation
#   member             (T - T[build, REPS 1]) / 2M     per membership test
#   drop               (T - T[build]) / (REPS * N)     per removal
#   life               (T - T[keys]) / REPS            per build-and-L-lookups
#
# REPS is max(1, OPS / N); M is OPS (listmap: OPS / N, at least 1000).
# Native runs are the driver's best of R in one process (Vm::reset between
# runs); the Tcl backends' (-backend interp|compile) the best of R of a
# whole run, with smaller sizes in mind. Writes TSV rows to -out (and
# stdout):
#
#   tag impl keys backend n mode m reps best-us per-op-ns checksum

source [file join [file dirname [file normalize [info script]]] lib.tcl]

set options [dict create -impls {lp} -keys {int-dense} -sizes {1 2 4 8 16 32 64 128 256 716 1024 4096 11468 16384} \
    -modes {build presized hit miss member replace drop} -ops 200000 -runs 5 -backend cranelift \
    -out "" -edits {} -tag "" -lower {} -life {1 10 1000}]
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {![dict exists $options $arg]} { error "unknown option $arg" }
    dict set options $arg [lindex $argv [incr i]]
}

# Key kind name -> {keys module, driver kind number}.
set kinds {
    int-dense {int 0} int-sparse {int 1} int-big {int 2} int-collide {int 9}
    str-short {str 4} str-medium {str 5} point {point 6}
}

set reference [file join $ht::base reference target release hash-table-reference]

# The argv pool of int-collide at N keys (SPEC.md section 5): N keys whose
# hash is 0 mod 1024, then N absent ones (residue 512).
proc collidePool {n} {
    global reference
    return [concat [split [string trim [exec $reference collide $n 0]] \n] \
                   [split [string trim [exec $reference collide $n 512]] \n]]
}

# Times of the argv lists ARGLISTS on the chosen backend: a list of
# {BEST-US CHECKSUM}.
proc timeAll {hir argLists} {
    set backend [dict get $::options -backend]
    set runs [dict get $::options -runs]
    if {$backend in {cranelift cranelift-generic}} {
        set lowering [dict get $::options -lower]
        if {$backend eq "cranelift-generic"} { lappend lowering -specialize 0 }
        return [ht::benchNative $hir $argLists $runs $lowering]
    }
    set out {}
    foreach argList $argLists {
        set best ""
        for {set r 0} {$r < $runs} {incr r} {
            set us [lindex [time {set value [ht::run $hir $backend $argList]}] 0]
            if {$best eq "" || $us < $best} { set best $us }
        }
        lappend out [list $best $value]
    }
    return $out
}

set outChannel ""
if {[dict get $options -out] ne ""} {
    set outChannel [open [dict get $options -out] a]
}
proc emit {row} {
    puts [join $row \t]
    if {$::outChannel ne ""} {
        puts $::outChannel [join $row \t]
        flush $::outChannel
    }
}

set ops [dict get $options -ops]
try {
    foreach impl [dict get $options -impls] {
        foreach keyName [dict get $options -keys] {
            lassign [dict get $kinds $keyName] module kind
            set hir [ht::compile [ht::app bench-$impl-$keyName bench.bot $impl $module [dict get $options -edits]]]
            foreach n [dict get $options -sizes] {
                set reps [expr {max(1, $ops / $n)}]
                set m [expr {[string match listmap* $impl] ? max(1000, $ops / $n) : $ops}]
                set pool [expr {$kind == 9 ? [collidePool $n] : {}}]
                # The runs: baselines first, then every mode.
                set runs [dict create]
                dict set runs keys [list keys $kind $n $m $reps]
                dict set runs build1 [list build $kind $n $m 1]
                foreach mode [dict get $options -modes] {
                    switch -- $mode {
                        build - presized - drop - bulk { dict set runs $mode [list $mode $kind $n $m $reps] }
                        hit - miss - member - replace { dict set runs $mode [list $mode $kind $n $m 1] }
                        life {
                            foreach l [dict get $options -life] {
                                dict set runs keys$l [list keys $kind $n $l $reps]
                                dict set runs life$l [list life $kind $n $l $reps]
                            }
                        }
                        default { error "unknown mode $mode" }
                    }
                }
                if {"drop" in [dict get $options -modes] && ![dict exists $runs build]} {
                    dict set runs build [list build $kind $n $m $reps]
                }
                set names [dict keys $runs]
                set times [timeAll $hir [lmap name $names {concat [dict get $runs $name] $pool}]]
                set t [dict create]
                foreach name $names result $times {
                    dict set t $name $result
                }
                foreach name $names {
                    lassign [dict get $t $name] us sum
                    lassign [dict get $runs $name] mode _ _ mm rr
                    switch -glob -- $name {
                        keys* - build1 { continue }
                        build - presized - bulk {
                            set per [expr {($us - [lindex [dict get $t keys] 0]) * 1000.0 / ($rr * $n)}]
                        }
                        hit - miss - replace {
                            set per [expr {($us - [lindex [dict get $t build1] 0]) * 1000.0 / $mm}]
                        }
                        member {
                            set per [expr {($us - [lindex [dict get $t build1] 0]) * 1000.0 / (2 * $mm)}]
                        }
                        drop {
                            set per [expr {($us - [lindex [dict get $t build] 0]) * 1000.0 / ($rr * $n)}]
                        }
                        life* {
                            set l [string range $name 4 end]
                            set per [expr {($us - [lindex [dict get $t keys$l] 0]) * 1000.0 / $rr}]
                            set mode life$l
                        }
                    }
                    emit [list [dict get $options -tag] $impl $keyName [dict get $options -backend] $n $mode $mm $rr \
                        [format %.1f $us] [format %.2f $per] $sum]
                }
            }
        }
    }
} finally {
    if {$outChannel ne ""} { close $outChannel }
    ht::cleanup
}
