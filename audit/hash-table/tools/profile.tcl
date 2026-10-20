# profile.tcl -- where one table operation's instructions go
# (HASH-TABLE-EXPERIMENT.md, "What remains"): a mode
# of drivers/bench.bot and its baseline (SPEC.md section 6) under callgrind,
# and per function the difference divided by the operations, so a runtime
# helper (rt_hash, rt_value_eq, rt_int_mod, ...) shows its own share and the
# generated code the rest (callgrind cannot name JIT'd functions: they are
# "???" here). Self instructions, so the shares add up to the total.
#
#   BOTLISH_HT_ROOT=TREE tclsh9.0 audit/hash-table/tools/profile.tcl
#       ?-impl I? ?-keys K? ?-n N? ?-mode M? ?-ops OPS? ?-top T?

source [file join [file dirname [file normalize [info script]]] lib.tcl]

set options [dict create -impl lpa -keys int-dense -n 1024 -mode hit -ops 20000 -top 12]
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {![dict exists $options $arg]} { error "unknown option $arg" }
    dict set options $arg [lindex $argv [incr i]]
}
set kinds {int-dense {int 0} int-sparse {int 1} str-short {str 4} str-medium {str 5} point {point 6}}
lassign [dict get $kinds [dict get $options -keys]] module kind
set ops [dict get $options -ops]
set n [dict get $options -n]
set mode [dict get $options -mode]

# {function -> self instructions} of one native run with argv ARGLIST.
proc profileOf {nirPath argList} {
    set dir [ht::workDir]
    set argvPath [file join $dir run.argv]
    set outPath [file join $dir callgrind.out]
    core::process::withArgv [ht::argvOf {*}$argList] {
        ht::writeFile $argvPath "[core::process::driverArgv]\n"
    }
    exec valgrind --tool=callgrind --smc-check=all-non-file --callgrind-out-file=$outPath \
        [native::binary] bench 1 --argv-file $argvPath $nirPath 2>@1
    set text [exec callgrind_annotate --threshold=100 --inclusive=no --auto=no $outPath 2>@1]
    set costs [dict create]
    set inTable 0
    foreach line [split $text \n] {
        if {[string match "Ir*file:function*" [string trim $line]]} { set inTable 1; continue }
        if {!$inTable} continue
        if {![regexp {^\s*([\d,]+)\s+\([^)]*\)\s+([^:]*):(.*)$} $line -> count file name]} continue
        set count [string map {, ""} $count]
        regsub { \[[^\]]*\]$} $name "" name
        regsub { \(\d+x\)$} $name "" name
        # Generated code has no symbols: callgrind names it by address.
        if {$file eq "???"} { set name "(generated code)" }
        dict incr costs $name $count
    }
    file delete $outPath
    return $costs
}

try {
    set hir [ht::compile [ht::app profile bench.bot [dict get $options -impl] $module]]
    set nirPath [file join [ht::workDir] profile.nir]
    ht::writeFile $nirPath [native::nir $hir]
    set reps [expr {max(1, $ops / $n)}]
    if {$mode in {build presized}} {
        set base [profileOf $nirPath [list keys $kind $n $ops $reps]]
        set run [profileOf $nirPath [list $mode $kind $n $ops $reps]]
        set per [expr {$reps * $n}]
    } else {
        set base [profileOf $nirPath [list build $kind $n $ops 1]]
        set run [profileOf $nirPath [list $mode $kind $n $ops 1]]
        set per $ops
    }
    set rows {}
    set total 0
    dict for {name count} $run {
        set d [expr {$count - ([dict exists $base $name] ? [dict get $base $name] : 0)}]
        set total [expr {$total + $d}]
        lappend rows [list $name [expr {double($d) / $per}]]
    }
    puts [format "%s %s n=%d %s: %.0f instructions per operation (tree %s)" [dict get $options -impl] \
        [dict get $options -keys] $n $mode [expr {double($total) / $per}] $ht::root]
    foreach row [lrange [lsort -real -decreasing -index 1 $rows] 0 [expr {[dict get $options -top] - 1}]] {
        lassign $row name v
        if {abs($v) < 0.5} continue
        puts [format "  %8.1f  %s" $v $name]
    }
} finally {
    ht::cleanup
}
