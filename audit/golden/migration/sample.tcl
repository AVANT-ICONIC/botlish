# sample.tcl -- runs the cross-suite mutant sample (mutant-sample.txt beside
# this script; LARGE-SCALE-GOLDEN-MIGRATION.md, "Mutation sample"): for each
# mutant, audit/golden/tools/check.tcl -mutants against the Tcl files the
# mutant's harness targets (the old side) and the golden suites holding those
# files' ported rows (the new side), on the backends the mutant can affect:
# interp for a front-end or Core IR evaluator mutant, compile for one of the
# Tcl compiler (compiler/), cranelift for a native one (native/), every Tcl
# backend for core/.
#
#   tclsh9.0 audit/golden/migration/sample.tcl ?-only NAME,...? ?-jobs N?
#       ?-out FILE?
#
# Prints check.tcl's verdict per mutant (BOTH, BOTH-SUITE-LEVEL, OLD-ONLY,
# NEW-ONLY, NEITHER) and a summary; -out also writes "NAME VERDICT" lines.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $root audit golden tools tree.tcl]

set options [dict create -only "" -jobs 2 -out ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set only [split [dict get $options -only] ,]

set entries {}
foreach line [split [goldentools::readFile [file join $here mutant-sample.txt]] \n] {
    if {[string trim $line] eq "" || [string match #* $line]} continue
    lassign $line spec files
    lassign [split $spec :] mutantsFile name
    if {$only ne {} && $name ni $only} continue
    lappend entries [list $spec $mutantsFile $name $files]
}

proc backendsFor {mutantsFile name} {
    lassign [goldentools::mutant [file join $::root $mutantsFile] $name] description edits
    set backends {}
    foreach {file old new} $edits {
        if {[string match native/* $file]} {
            lappend backends cranelift
        } elseif {[string match compiler/* $file]} {
            lappend backends compile
        } elseif {[string match core/* $file]} {
            lappend backends interp compile
        } else {
            lappend backends interp
        }
    }
    return [lsort -unique $backends]
}

set results {}
foreach entry $entries {
    lassign $entry spec mutantsFile name files
    set backends [backendsFor $mutantsFile $name]
    set start [clock seconds]
    lassign [goldentools::run 7200 tclsh9.0 [file join $root audit golden tools check.tcl] \
        -mutants [list $spec] -files $files -backends [join $backends ,] -jobs [dict get $options -jobs]] status output
    set verdict NO-VERDICT
    foreach l [split $output \n] {
        if {[regexp {^(BOTH-SUITE-LEVEL|BOTH|OLD-ONLY|NEW-ONLY|NEITHER|NOT-APPLIED|NOT-BUILT) } $l -> verdict]} break
    }
    set seconds [expr {[clock seconds] - $start}]
    puts "== $name ($files; [join $backends ,]; ${seconds}s): $verdict"
    foreach l [split $output \n] {
        if {[string match "    *" $l] || [regexp {^(BOTH|OLD|NEW|NEITHER|NOT)} $l]} { puts $l }
    }
    flush stdout
    lappend results [list $name $verdict $seconds]
}
set counts [dict create]
foreach r $results { dict incr counts [lindex $r 1] }
puts "\n[llength $results] mutants: [join [lmap {k v} $counts {string cat $k " " $v}] {, }]"
if {[dict get $options -out] ne ""} {
    set f [open [dict get $options -out] w]
    foreach r $results { puts $f [join $r " "] }
    close $f
}
