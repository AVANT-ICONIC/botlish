# fetch.tcl -- fetch the pinned library sources the header experiment
# analyzes (C-HEADER-ARCHAEOLOGY.md, "Reproducing a run").
#
#   tclsh9.0 audit/c-header/tools/fetch.tcl ?LIBRARY ...?
#
# Shallow-clones each library at the tag its profile pins (profiles/*.tcl)
# into the sources directory and checks that the tag still names the pinned
# commit. The sources directory is $BOTLISH_C_HEADER_SOURCES, else
# c-header-src/ under Botlish's cache directory ($BOTLISH_CACHE_DIR,
# $XDG_CACHE_HOME/botlish or ~/.cache/botlish); never the repository.

set here [file dirname [file normalize [info script]]]
source [file join $here common.tcl]

set libraries $argv
if {$libraries eq ""} {
    foreach p [lsort [glob -directory [file join $::chdr::root profiles] *.tcl]] {
        lappend libraries [file rootname [file tail $p]]
    }
}
foreach library $libraries {
    set profiles [::chdr::loadProfiles $library]
    set source [dict get [lindex [dict values $profiles] 0] source]
    if {[catch {::chdr::fetch $library $source} message]} {
        puts $message
        exit 1
    }
    puts "fetch: $library [dict get $source commit] ok"
}
