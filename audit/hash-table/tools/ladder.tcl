# ladder.tcl -- one timing plan run against several compiler trees
# (HASH-TABLE-EXPERIMENT.md, "Compiler experiments", "Runtime
# experiments"): the baseline checkout and each prototype's, alone and
# combined. Every round runs tools/bench.tcl once per tree, in order, so a
# change in the machine's load during the run affects every tree alike;
# summarize.tcl's `ladder` mode takes the median of the rounds.
#
#   tclsh9.0 audit/hash-table/tools/ladder.tcl -trees {NAME PATH ...}
#       ?-rounds R? -out FILE ?BENCH-OPTION VALUE ...?
#
# The drivers, implementations and tools are this checkout's; only the
# compiler and the native backend are each tree's (lib.tcl's
# BOTLISH_HT_ROOT). Each tree's native backend must be built. Rows are
# bench.tcl's, tagged with the tree's NAME.

set here [file dirname [file normalize [info script]]]
set trees {}
set rounds 3
set out ""
set benchArgs {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    switch -- $arg {
        -trees { set trees [lindex $argv [incr i]] }
        -rounds { set rounds [lindex $argv [incr i]] }
        -out { set out [lindex $argv [incr i]] }
        default { lappend benchArgs $arg [lindex $argv [incr i]] }
    }
}
if {$out eq "" || [llength $trees] == 0} {
    error "usage: ladder.tcl -trees {NAME PATH ...} ?-rounds R? -out FILE ?BENCH-OPTION VALUE ...?"
}
foreach {name path} $trees {
    if {![file executable [file join $path native target release botlish-native]]} {
        error "$name: no native backend built in $path"
    }
}

set tclsh [info nameofexecutable]
for {set r 1} {$r <= $rounds} {incr r} {
    foreach {name path} $trees {
        puts "[clock format [clock seconds] -format %H:%M:%S] round $r/$rounds $name"
        flush stdout
        set ::env(BOTLISH_HT_ROOT) [file normalize $path]
        exec $tclsh [file join $here bench.tcl] {*}$benchArgs -tag $name -out $out >@stdout 2>@stderr
    }
}
unset -nocomplain ::env(BOTLISH_HT_ROOT)
