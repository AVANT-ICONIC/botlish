# common.tcl -- shared helpers of the header experiment's tools
# (C-HEADER-ARCHAEOLOGY.md).

namespace eval ::chdr {
    variable root [file dirname [file dirname [file normalize [info script]]]]
    variable repo [file dirname [file dirname $root]]
}

# The directory holding the library source checkouts.
proc ::chdr::sourcesDir {} {
    if {[info exists ::env(BOTLISH_C_HEADER_SOURCES)] && $::env(BOTLISH_C_HEADER_SOURCES) ne ""} {
        return [file normalize $::env(BOTLISH_C_HEADER_SOURCES)]
    }
    foreach {var sub} {BOTLISH_CACHE_DIR {} XDG_CACHE_HOME botlish} {
        if {[info exists ::env($var)] && $::env($var) ne ""} {
            return [file normalize [file join $::env($var) {*}$sub c-header-src]]
        }
    }
    return [file normalize [file join [file home] .cache botlish c-header-src]]
}

# The profiles of LIBRARY (profiles/LIBRARY.tcl): a dict NAME -> profile.
proc ::chdr::loadProfiles {library} {
    variable root
    set path [file join $root profiles $library.tcl]
    if {![file exists $path]} { error "no profile file $path" }
    return [apply [list {} [list source $path]]]
}

# The profile NAME (LIBRARY-VARIANT).
proc ::chdr::profile {name} {
    set library [lindex [split $name -] 0]
    set profiles [loadProfiles $library]
    if {![dict exists $profiles $name]} {
        error "no profile $name (known: [dict keys $profiles])"
    }
    return [dict get $profiles $name]
}

# The origin of a file named by a line marker, given the library source root:
# public, bundled, internal (in the library tree but not public), system,
# builtin (<built-in>, <command-line>) or entry (the generated TU).
proc ::chdr::origin {profile sourceRoot entryFile file} {
    if {$file in {<built-in> <command-line> <unknown>}} { return builtin }
    if {$file eq $entryFile || [file tail $file] eq [file tail $entryFile]} { return entry }
    set norm [file normalize $file]
    set rootPrefix "[file normalize $sourceRoot]/"
    if {[string first $rootPrefix $norm] == 0} {
        set rel [string range $norm [string length $rootPrefix] end]
        foreach g [dict get $profile public] { if {[string match $g $rel]} { return public } }
        if {[dict exists $profile bundled]} {
            foreach g [dict get $profile bundled] { if {[string match $g $rel]} { return bundled } }
        }
        return internal
    }
    return system
}

# A path for reports: relative to the library source root when inside it.
proc ::chdr::relPath {sourceRoot file} {
    set norm [file normalize $file]
    set rootPrefix "[file normalize $sourceRoot]/"
    if {[string first $rootPrefix $norm] == 0} {
        return [string range $norm [string length $rootPrefix] end]
    }
    return $file
}

proc ::chdr::writeFile {path text} {
    file mkdir [file dirname $path]
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

proc ::chdr::readFile {path} {
    set f [open $path]
    fconfigure $f -encoding utf-8
    set t [read $f]
    close $f
    return $t
}
