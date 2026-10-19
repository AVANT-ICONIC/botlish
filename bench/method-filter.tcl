#!/usr/bin/env tclsh9.0
# method-filter.tcl -- what the method-call kind filter saves
# (METHOD-DECISION-FILTER.md, "Performance").
#
#   tclsh9.0 bench/method-filter.tcl ?-jobs N? ?-audit 1? FILE.bot ...
#   tclsh9.0 bench/method-filter.tcl -suites       the golden suites that decide
#                                                  method calls by trial builds
#
# Each program is compiled in a process of its own with the filter off (the
# exact decision alone) and on, and the whole-program builds, the method trials
# among them, and the front end's time are compared. -audit 1 compiles it
# a third time with hir::methodFilterAudit, which fails on any difference
# between the filter's decisions and the exact decision's.
#
# The numbers in the document were measured with this tool on the sandbox's
# four cores; the build counts are exact, the times are not.

set root [file dirname [file dirname [file normalize [info script]]]]

set suites {callable-contracts collections declared-errors destructuring diagnostics
    framework-semantics imports method-equivalence-imported methods mutable-array
    mutable-vector opaque ownership recursive-types refinements static-compile
    stdlib-namespaces structs-and-enums traits}

proc one {file mode} {
    global root
    source [file join $root core core.tcl]
    source [file join $root surface surface.tcl]
    set hir::methodFilter [expr {$mode ne "off"}]
    set hir::methodFilterAudit [expr {$mode eq "audit"}]
    set before [hir::BuildStats]
    set start [clock milliseconds]
    if {[catch {surface::readProgramFile $file -warnings off -cache ""} message]} {
        puts "RESULT error [string map {\n { }} [string range $message 0 160]]"
        return
    }
    set ms [expr {[clock milliseconds] - $start}]
    set after [hir::BuildStats]
    set fields {}
    foreach counter {builds methodTrials methodFinals methodFiltered methodFilterAbandoned methodFilterEvicted} {
        lappend fields $counter [expr {[dict get $after $counter] - [dict get $before $counter]}]
    }
    puts "RESULT ok $fields ms $ms audits $hir::methodFilterAudits"
}

proc measure {file mode} {
    global root
    set output [exec [info nameofexecutable] [info script] -one $file $mode 2>@1]
    foreach line [split $output \n] {
        if {[string match "RESULT *" $line]} {
            return [lrange $line 1 end]
        }
    }
    return [list error $output]
}

set args $argv
if {[lindex $args 0] eq "-one"} {
    one [lindex $args 1] [lindex $args 2]
    exit
}
set jobs 1
set audit 0
set files {}
while {$args ne ""} {
    set arg [lindex $args 0]
    switch -- $arg {
        -jobs { set jobs [lindex $args 1]; set args [lrange $args 2 end] }
        -audit { set audit [lindex $args 1]; set args [lrange $args 2 end] }
        -suites {
            foreach s $suites { lappend files [file join $root tests golden $s.bot] }
            set args [lrange $args 1 end]
        }
        default { lappend files $arg; set args [lrange $args 1 end] }
    }
}
if {$files eq ""} {
    puts stderr "usage: method-filter.tcl ?-audit 1? (-suites | FILE.bot ...)"
    exit 2
}

puts [format "%-34s %13s %13s %9s %9s %s" program "builds off/on" "trials off/on" "ms off" "ms on" "filter"]
set totals [dict create off 0 on 0 trialsOff 0 trialsOn 0 msOff 0 msOn 0]
set problems 0
foreach file $files {
    set off [measure $file off]
    set on [measure $file on]
    if {[lindex $off 0] ne "ok" || [lindex $on 0] ne "ok"} {
        puts [format "%-34s %s / %s" [file tail $file] [lrange $off 0 3] [lrange $on 0 3]]
        incr problems
        continue
    }
    set o [dict create {*}[lrange $off 1 end]]
    set n [dict create {*}[lrange $on 1 end]]
    set note "filtered [dict get $n methodFiltered], abandoned [dict get $n methodFilterAbandoned], taken back [dict get $n methodFilterEvicted]"
    if {$audit} {
        set a [measure $file audit]
        if {[lindex $a 0] ne "ok"} {
            append note "; AUDIT FAILED: [lrange $a 1 end]"
            incr problems
        } else {
            append note "; audited [dict get [dict create {*}[lrange $a 1 end]] audits]"
        }
    }
    puts [format "%-34s %6d/%-6d %6d/%-6d %9d %9d %s" [file tail $file] \
        [dict get $o builds] [dict get $n builds] [dict get $o methodTrials] [dict get $n methodTrials] \
        [dict get $o ms] [dict get $n ms] $note]
    dict incr totals off [dict get $o builds]
    dict incr totals on [dict get $n builds]
    dict incr totals trialsOff [dict get $o methodTrials]
    dict incr totals trialsOn [dict get $n methodTrials]
    dict incr totals msOff [dict get $o ms]
    dict incr totals msOn [dict get $n ms]
}
puts [format "%-34s %6d/%-6d %6d/%-6d %9d %9d" total \
    [dict get $totals off] [dict get $totals on] [dict get $totals trialsOff] [dict get $totals trialsOn] \
    [dict get $totals msOff] [dict get $totals msOn]]
exit [expr {$problems > 0}]
