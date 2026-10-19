# run-all.tcl -- the hash-table experiment's measurement plan, one phase at
# a time, each writing audit/hash-table/results/PHASE.tsv (or .txt)
# (HASH-TABLE-EXPERIMENT.md, "How the numbers were taken"). Run it on an
# otherwise idle machine: every phase is a timing.
#
#   tclsh9.0 audit/hash-table/tools/run-all.tcl ?-phases LIST? ?-runs R? ?-tag TAG? ?-results DIR?
#
# Phases: rust copies memory nir sizes keys typed life policy mixed backends
# membership (default all). -tag labels every row (the compiler/runtime
# variant under test, e.g. "baseline" or a prototype's name) and goes into
# the file names (PHASE-TAG.tsv).

set here [file dirname [file normalize [info script]]]
set base [file dirname $here]
set options [dict create -phases {rust copies memory nir sizes keys typed life policy mixed backends membership} \
    -runs 5 -tag baseline -results [file join $base results]]
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {![dict exists $options $arg]} { error "unknown option $arg" }
    dict set options $arg [lindex $argv [incr i]]
}
set results [dict get $options -results]
set tag [dict get $options -tag]
set runs [dict get $options -runs]
file mkdir $results
set tclsh [info nameofexecutable]
set reference [file join $base reference target release hash-table-reference]

proc out {phase {ext tsv}} {
    global results tag
    return [file join $results $phase-$tag.$ext]
}

# Runs a tool of this directory (or a command), appending its output to FILE
# when the tool does not write it itself; echoes a line per invocation.
proc step {what args} {
    puts "[clock format [clock seconds] -format %H:%M:%S] $what"
    flush stdout
    # A failed step is reported and the plan goes on (its rows are missing).
    if {[catch {exec {*}$args >@stdout 2>@stderr} message]} {
        puts "[clock format [clock seconds] -format %H:%M:%S] FAILED: $what: [string range $message 0 300]"
        flush stdout
    }
}

proc bench {phase args} {
    global tclsh here runs tag
    step "bench $phase: $args" $tclsh [file join $here bench.tcl] -runs $runs -tag $tag -out [out $phase] {*}$args
}

set sizes {1 2 4 8 16 32 64 128 256 716 1024 4096 11468 16384}
# Each load policy's peak load, at two scales: 512 and 8192 entries fill
# capacity 1024 and 16384 to 1/2; 716 and 11468 to 7/10; 870 and 13926 to
# 17/20 (under a lower maximum load the same counts grow the table once more).
set policySizes {512 716 870 8192 11468 13926}
set allModes {build presized hit miss member replace drop bulk}

foreach phase [dict get $options -phases] {
    switch -- $phase {
        rust {
            file delete [out rust] [out rust-mixed] [out rust-stats] [out rust-hashcost] [out rust-spike]
            set f [out rust]
            step "rust sweep" sh -c "$reference sweep -impls listmap,chain,lp,rh,std,stdb -keys int-dense,int-sparse,int-big,int-collide,str-short,str-medium,point -modes build,presized,hit,miss,member,replace,drop -sizes [join $sizes ,] -runs $runs > $f"
            step "rust life" sh -c "$reference sweep -impls listmap,chain,lp,rh,std -keys int-dense,str-short -modes life1,life10,life1000 -sizes 1,2,4,8,16,32,64,128,256 -runs $runs >> $f"
            foreach load {1/2 7/10 17/20} {
                step "rust policy $load" sh -c "$reference sweep -impls lp,rh -keys int-dense,str-short -modes build,hit,miss -sizes [join $policySizes ,] -load $load -runs $runs >> $f"
            }
            step "rust mixed" sh -c "$reference mixed -impls listmap,chain,lp,rh,std,stdb -bfs 64,256 -memo 10000,100000 -freq 16384,262144 -runs $runs > [out rust-mixed]"
            step "rust stats" sh -c "$reference stats -sizes [join $policySizes ,],1024,16384 -loads 1/2,7/10,17/20 > [out rust-stats]"
            step "rust hashcost" sh -c "$reference hashcost -runs $runs > [out rust-hashcost]"
            step "rust spike" sh -c "$reference spike -sizes 11468,16384,65536 -loads 1/2,7/10,17/20 -runs $runs > [out rust-spike]"
        }
        copies {
            set impls {listmap chain0 ht0 chain lp lpc lpa lpmono lpfact lpmask rh cd sorted}
            foreach keys {int str point} {
                step "copies $keys" sh -c "$tclsh [file join $here copies.tcl] -keys $keys $impls >> [out copies txt] 2>&1; true"
            }
        }
        memory {
            file delete [out memory]
            foreach keys {int str} {
                step "memory $keys" $tclsh [file join $here memory.tcl] -keys $keys -out [out memory] \
                    listmap chain0 ht0 chain lpa rh cd sorted
            }
        }
        nir {
            set impls {listmap chain0 ht0 chain lp lpa lpmono lpfact lpmask lpint rh cd sorted}
            step "nir int" sh -c "$tclsh [file join $here nirstats.tcl] -keys int $impls > [out nir txt] 2>&1; true"
            step "nir str" sh -c "$tclsh [file join $here nirstats.tcl] -keys str lpa lpstr chain cd rh >> [out nir txt] 2>&1; true"
        }
        sizes {
            file delete [out sizes]
            foreach impl {lpa lpmono lpfact lpmask rh chain cd ht0 lp lpc} {
                set modes [expr {$impl eq "cd" ? [lsearch -all -inline -not $allModes drop] : $allModes}]
                bench sizes -impls $impl -keys {int-dense str-short} -sizes $sizes -modes $modes
            }
            bench sizes -impls listmap -keys {int-dense str-short} -sizes [lrange $sizes 0 10] -modes $allModes
            bench sizes -impls chain0 -keys {int-dense str-short} -sizes $sizes -modes {presized hit miss member replace drop}
            bench sizes -impls sorted -keys {int-dense str-short} -sizes [lrange $sizes 0 11] -modes $allModes
        }
        keys {
            file delete [out keys]
            foreach impl {lpa lpmono rh chain cd ht0 chain0} {
                bench keys -impls $impl -keys {int-sparse int-big str-medium point} -sizes {16 1024 16384} -modes {build hit miss replace}
                bench keys -impls $impl -keys {int-collide} -sizes {16 256 1024 4096} -modes {build hit miss replace}
            }
            bench keys -impls sorted -keys {int-sparse str-medium point} -sizes {16 1024 16384} -modes {bulk hit miss}
        }
        typed {
            file delete [out typed]
            bench typed -impls lpint -keys {int-dense int-sparse} -sizes {16 1024 16384} -modes {build hit miss replace}
            bench typed -impls lpstr -keys {str-short str-medium} -sizes {16 1024 16384} -modes {build hit miss replace}
            bench typed -impls lpa -keys {int-dense int-sparse str-short str-medium} -sizes {16 1024 16384} -modes {build hit miss replace}
        }
        life {
            file delete [out life]
            foreach impl {listmap lpa lpmono rh chain cd sorted chain0} {
                bench life -impls $impl -keys {int-dense str-short} -sizes {1 2 4 8 16 32 64 128 256} -modes {life}
            }
        }
        policy {
            file delete [out policy]
            foreach impl {lpa rh} {
                foreach {num den} {1 2 7 10 17 20} {
                    set edits [list "fn load_num() -> int:\n    7\n\nfn load_den() -> int:\n    10" \
                                    "fn load_num() -> int:\n    $num\n\nfn load_den() -> int:\n    $den"]
                    bench policy -impls $impl -keys {int-dense str-short} -sizes $policySizes \
                        -modes {build hit miss} -edits $edits -tag $tag-$num/$den
                }
            }
        }
        mixed {
            file delete [out mixed]
            step "mixed" $tclsh [file join $here mixed.tcl] -runs $runs -tag $tag -out [out mixed]
        }
        backends {
            file delete [out backends]
            foreach backend {interp compile cranelift-generic} {
                set ops [expr {$backend eq "cranelift-generic" ? 200000 : 2000}]
                set r [expr {$backend eq "cranelift-generic" ? $runs : 3}]
                foreach impl {listmap lpa lpmono rh chain cd} {
                    step "backends $backend $impl" $tclsh [file join $here bench.tcl] -backend $backend -runs $r -ops $ops \
                        -tag $tag -out [out backends] -impls $impl -keys {int-dense str-short} -sizes {16 256} -modes {build hit miss}
                }
            }
        }
        membership {
            file delete [out membership]
            step "membership" $tclsh [file join $here membership.tcl] -runs $runs -out [out membership]
        }
        default { error "unknown phase $phase" }
    }
}
puts "done: [clock format [clock seconds] -format %H:%M:%S]"
