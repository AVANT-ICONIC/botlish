# timing.tcl -- the front end's cost before and after diagnostic recovery
# (DIAGNOSTIC-RECOVERY.md, "Performance").
#
#   tclsh9.0 audit/diagnostic-recovery/tools/timing.tcl ?-root DIR? ?-runs N?
#       ?-programs FILE,...?
#
# Compiles each program with the front end of the checkout DIR (this one by
# default; the strict surface::readProgramFile, warnings off, no front-end
# cache), N times (default 5) in one process after a warm-up compilation, and
# prints the median wall time per program: the valid programs (the 2048
# workload's engine suite and demo, a stdlib example, a golden suite) and the
# intentionally invalid diagnostic-efficiency corpus (its programs are
# rejected; the time is the time to the rejection). Run it once with -root
# on a checkout from before the change and once on this one.

set here [file dirname [file normalize [info script]]]
set self [file dirname [file dirname [file dirname $here]]]
set options [dict create -root $self -runs 5 -programs ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set ::env(LANG) C.utf8
set ::env(LC_ALL) C.utf8
unset -nocomplain ::env(BOTLISH_HIR_CACHE)
set root [file normalize [dict get $options -root]]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

set programs [dict get $options -programs]
if {$programs eq ""} {
    set programs [list \
        [file join $self examples games 2048 golden.bot] \
        [file join $self examples games 2048 demo.bot] \
        [file join $self examples stdlib csv.bot] \
        [file join $self tests golden values.bot]]
    foreach dir [lsort [glob -directory [file join $self audit diagnostic-recovery corpus] -type d *]] {
        lappend programs [file join $dir program.bot]
    }
} else {
    set programs [split $programs ,]
}

proc compileOnce {path} {
    set start [clock microseconds]
    set rejected [catch {surface::readProgramFile $path -warnings off -cache ""}]
    return [list [expr {[clock microseconds] - $start}] $rejected]
}

puts [format "%-60s %10s %s" program "median ms" outcome]
foreach path $programs {
    compileOnce $path
    set times {}
    for {set i 0} {$i < [dict get $options -runs]} {incr i} {
        lassign [compileOnce $path] us rejected
        lappend times $us
    }
    set times [lsort -integer $times]
    set median [lindex $times [expr {[llength $times] / 2}]]
    set name [string range $path [expr {[string length $self] + 1}] end]
    puts [format "%-60s %10.1f %s" $name [expr {$median / 1000.0}] [expr {$rejected ? "rejected" : "compiled"}]]
}
