#!/usr/bin/env tclsh9.0
# compare.tcl -- the static-decision schedulers against each other on
# program files (STATIC-COMPILE.md, "Decision economics").
#
#   tclsh9.0 audit/static-decisions/tools/compare.tcl ?-schedulers LIST? FILE...
#
# Compiles each FILE (-strict 0, warnings off) under every scheduler of
# LIST (default: batched sequential) and requires the first one to agree
# with each of the others exactly: every site's outcome and reified
# diagnostic (code, primary, related, message), the program's diagnostics,
# the decided program's HIR text, and no misprediction (a file that does not
# compile is a failure, not an agreement). Against `legacy`
# the labels of sites inside rejected sites are not compared (their bodies
# are gone either way). Prints one line per file with each scheduler's
# rounds/builds and front-end seconds; exits 1 on any disagreement.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set ::sdRoot $root
set schedulers {batched sequential}
set files {}
set args $argv
set argv {}
while {$args ne {}} {
    set args [lassign $args a]
    switch -- $a {
        -schedulers { set args [lassign $args schedulers] }
        default { lappend files $a }
    }
}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root audit static-decisions tools lib.tcl]
interp recursionlimit {} 200000

set failed 0
foreach path $files {
    set records {}
    foreach s $schedulers {
        lappend records [sdCompileFile $s $path]
    }
    set line "[file tail $path]:"
    foreach s $schedulers r $records {
        append line [format " %s %s %.1fs" $s [sdEconomics $r] [expr {[dict get $r us] / 1e6}]]
    }
    set first [lindex $records 0]
    if {[dict get $first error] ne ""} {
        # Failing alike under every scheduler would be no evidence.
        append line "\n    DOES NOT COMPILE: [string range [dict get $first error] 0 300]"
        set failed 1
    }
    foreach s [lrange $schedulers 1 end] r [lrange $records 1 end] {
        set diff [sdDiff $first $r [expr {$s eq "legacy" || [lindex $schedulers 0] eq "legacy"}]]
        if {$diff ne ""} {
            append line "\n    DISAGREE ([lindex $schedulers 0] vs $s): $diff"
            set failed 1
        }
    }
    puts $line
    flush stdout
}
exit $failed
