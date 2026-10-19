# common.tcl -- shared helpers of the C header library (tools/cheader/):
# where pinned library sources live, how a file named by a line marker is
# classified, deterministic file I/O. Used by the header archaeology
# (audit/c-header/, C-HEADER-ARCHAEOLOGY.md) and the binding generator
# (tools/c-bindgen.tcl, C-BINDGEN.md). Nothing in the compiler loads this
# directory.

namespace eval ::chdr {
    # This library's directory, and the repository's.
    variable libDir [file dirname [file normalize [info script]]]
    variable repoDir [file dirname [file dirname $libDir]]
}

# Botlish's cache directory: $BOTLISH_CACHE_DIR, $XDG_CACHE_HOME/botlish or
# ~/.cache/botlish.
proc ::chdr::cacheDir {} {
    foreach {var sub} {BOTLISH_CACHE_DIR {} XDG_CACHE_HOME botlish} {
        if {[info exists ::env($var)] && $::env($var) ne ""} {
            return [file normalize [file join $::env($var) {*}$sub]]
        }
    }
    return [file normalize [file join [file home] .cache botlish]]
}

# The directory holding the library source checkouts:
# $BOTLISH_C_HEADER_SOURCES, else c-header-src/ under the cache directory.
proc ::chdr::sourcesDir {} {
    if {[info exists ::env(BOTLISH_C_HEADER_SOURCES)] && $::env(BOTLISH_C_HEADER_SOURCES) ne ""} {
        return [file normalize $::env(BOTLISH_C_HEADER_SOURCES)]
    }
    return [file join [cacheDir] c-header-src]
}

# Shallow-clones SOURCE ({url URL tag TAG commit COMMIT}) into DIR/NAME
# unless it is there, and checks that it is at the pinned commit. Returns
# the checkout's directory; a different commit is an error (never a silent
# drift of the corpus).
proc ::chdr::fetch {name source {dir ""}} {
    if {$dir eq ""} { set dir [sourcesDir] }
    file mkdir $dir
    set target [file join $dir $name]
    if {![file isdirectory $target]} {
        puts "fetch: cloning [dict get $source url] [dict get $source tag] into $target"
        exec git clone --quiet --depth 1 --branch [dict get $source tag] [dict get $source url] $target 2>@1
    }
    set head [exec git -C $target rev-parse HEAD]
    if {$head ne [dict get $source commit]} {
        error "fetch: $name at $target is $head, not the pinned [dict get $source commit]"
    }
    return $target
}

# The origin of a file named by a line marker, given the library source root:
# public, bundled, internal (in the library tree but not public, or matching
# the profile's private globs), system,
# builtin (<built-in>, <command-line>) or entry (the generated TU).
proc ::chdr::origin {profile sourceRoot entryFile file} {
    if {$file in {<built-in> <command-line> <unknown>}} { return builtin }
    if {$file eq $entryFile || [file tail $file] eq [file tail $entryFile]} { return entry }
    set norm [file normalize $file]
    set rootPrefix "[file normalize $sourceRoot]/"
    if {[string first $rootPrefix $norm] == 0} {
        set rel [string range $norm [string length $rootPrefix] end]
        if {[dict exists $profile private]} {
            foreach g [dict get $profile private] { if {[string match $g $rel]} { return internal } }
        }
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

# The CRC-32 of TEXT's UTF-8 bytes as 8 hexadecimal digits: a file identity
# for manifests (not a security digest).
proc ::chdr::crc32 {text} {
    return [format %08x [zlib crc32 [encoding convertto utf-8 $text]]]
}

proc ::chdr::fileCrc32 {path} {
    set f [open $path rb]
    set bytes [read $f]
    close $f
    return [format %08x [zlib crc32 $bytes]]
}
