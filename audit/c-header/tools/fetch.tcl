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
set dir [::chdr::sourcesDir]
file mkdir $dir
foreach library $libraries {
    set profiles [::chdr::loadProfiles $library]
    set source [dict get [lindex [dict values $profiles] 0] source]
    set target [file join $dir $library]
    if {![file isdirectory $target]} {
        puts "fetch: cloning [dict get $source url] [dict get $source tag] into $target"
        exec git clone --quiet --depth 1 --branch [dict get $source tag] [dict get $source url] $target 2>@1
    }
    set head [exec git -C $target rev-parse HEAD]
    if {$head ne [dict get $source commit]} {
        puts "fetch: $library at $target is $head, not the pinned [dict get $source commit]"
        exit 1
    }
    puts "fetch: $library $head ok"
}
