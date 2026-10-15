#!/usr/bin/env tclsh9.0
# audit.tcl -- the demotion re-check's reuse at corpus scale
# (COMPILER-BOTTLENECKS.md 3.9; hir::check).
#
#   tclsh9.0 audit/demotion-recheck/tools/audit.tcl ?-programs FILES? ?-print 0|1?
#   tclsh9.0 audit/demotion-recheck/tools/audit.tcl -run SCRIPT ?ARG ...?
#
# When a check finds a call violating a trusted inferred contract, hir::check
# checks the program again with that contract demoted, reusing what the
# check before it computed and the demotion cannot change: the coroutine
# protocols, and every round of the signature fixpoint whose seeds the second
# check reaches again (hir::signatures::infer). With hir::recheckAudit 1 it
# also makes that second check from the start, sharing nothing, and fails
# unless both give the same HIR (hir::AuditRecheck).
#
# The first form compiles each program of FILES (default: every golden suite,
# example and benchmark program; -strict 0, warnings off, no front-end cache)
# with the audit on and prints, per program, its time and how many demoting
# checks it compared; with -print 1 also the checksum of its final HIR, the
# tree's root path and the decisions' timing normalized, so that two trees
# can be compared. The second runs SCRIPT (a fuzzer, a test file) in this
# process with the audit on -- the switch survives the script's own loading
# of the compiler -- and prints how many checks it compared on exit. Exits
# non-zero on any difference.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000
set hir::recheckAudit 1

if {[lindex $argv 0] eq "-run"} {
    set script [file normalize [lindex $argv 1]]
    set argv0 $script
    set argv [lrange $argv 2 end]
    set argc [llength $argv]
    rename exit ::AuditExit
    proc exit {{code 0}} {
        puts "demotion re-check audit: $::hir::recheckAudits checks compared"
        ::AuditExit $code
    }
    source $script
    exit 0
}

set options [dict create -programs "" -print 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "audit.tcl: unknown option $option" }
    dict set options $option $value
}
set programs [dict get $options -programs]
if {$programs eq ""} {
    set programs [concat \
        [lsort [glob -directory [file join $root tests golden] *.bot]] \
        [lsort [glob -directory [file join $root examples] */*.bot]] \
        [lsort [glob -directory [file join $root bench] *.bot]]]
}

set failures 0
set total 0
foreach path $programs {
    set path [file normalize $path]
    set before $hir::recheckAudits
    set t0 [clock microseconds]
    set failed [catch {surface::readProgramFile $path -strict 0 -warnings off -cache ""} hir]
    set seconds [expr {([clock microseconds] - $t0) / 1e6}]
    set compared [expr {$hir::recheckAudits - $before}]
    incr total $compared
    set name [string map [list $root/ ""] $path]
    if {$failed} {
        incr failures
        puts [format "FAIL %-50s %s" $name [lindex [split $hir \n] 0]]
        continue
    }
    set line [format "ok   %-50s %7.2f s  %2d compared" $name $seconds $compared]
    if {[dict get $options -print]} {
        set text [string map [list $root ROOT] $hir]
        regsub -all {depMs \d+} $text {depMs 0} text
        append line [format "  %08x/%d" [zlib crc32 [encoding convertto utf-8 $text]] [string length $text]]
    }
    puts $line
    flush stdout
}
puts "[llength $programs] programs, $total demoting checks compared, $failures failures"
exit [expr {$failures > 0}]
