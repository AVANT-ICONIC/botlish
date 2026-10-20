#!/usr/bin/env tclsh9.0
# roundtrip.tcl -- the HIR interchange format and the front-end cache over
# the golden corpus (HIR-INTERCHANGE.md).
#
#   tclsh9.0 audit/hir-interchange/tools/roundtrip.tcl ?-suites FILES|all?
#            ?-backends LIST? ?-via interchange|cache? ?-trait-source 0|1?
#
# Compiles each golden suite of FILES (default: ten suites covering source
# types, structs, enums, error payloads, traits, context traits, coroutines
# and binary layouts; `all` for every tests/golden/*.bot) and takes the
# checksum of its HIR and of each of its backend artifacts -- the core IR, the
# Tcl compiler's code (unit, block and variable numbers normalized),
# specialized and generic NIR -- and of the outcome of each backend of LIST
# (default interp, compile, cranelift, cranelift-generic). With -via
# interchange (the default) it writes each HIR in the interchange format to a
# private temporary directory; with -via cache it compiles through a front-end
# cache there (surface/cache.tcl), which keeps each. A fresh tclsh9.0 process
# then reads every HIR back, in the same order -- the files, or the same
# suites through the cache -- and takes the same checksums, running no front
# end at all (it asserts that no build happened, and with -via cache that
# every suite was a hit). Every checksum must be the same: the HIR read back
# is the HIR built (without its traitSource through the interchange format,
# unless -trait-source 1). With -via cache, a fresh process per suite then
# builds it alone, with no cache: its HIR must equal the one the cache holds,
# which this process built after the suites before it (a hit is exact only
# because a build is a pure function of the cache's key and dependencies; the
# HIRs are compared without staticStats' depMs, a time), and every file a
# suite's HIR was built from must be its program or one of its cache entry's
# dependencies (surface::cache::Dependencies). Exits non-zero, naming each
# difference, otherwise.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create \
    -suites {traits-path.bot harness.bot contexts.bot affinity.bot coroutines.bot errors.bot
        representation.bot declared-errors.bot ownership.bot binary-layout.bot layout-arrays.bot layout-unions.bot} \
    -backends {interp compile cranelift cranelift-generic} -via interchange -trait-source 0 -child "" \
    -alone ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "roundtrip.tcl: unknown option $option" }
    dict set options $option $value
}

source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 200000

proc sum {text} {
    return [format %08x/%d [zlib crc32 [encoding convertto utf-8 $text]] [string length $text]]
}

# HIR with the one measurement a build records, the static decisions' time in
# their dependency analysis (staticStats depMs), set to 0: everything else is
# a function of the program, its modules and the options.
proc normalized {hir} {
    if {[dict exists $hir staticStats depMs]} {
        dict set hir staticStats depMs 0
    }
    return $hir
}

proc outcome {hir backend} {
    set failed [catch {
        switch -- $backend {
            interp {
                core::useBackend interp
                core::formatValue [core::evalProgram [hir::lower $hir]]
            }
            compile { core::formatValue [core::compiler::evalHir $hir] }
            cranelift { core::formatValue [native::evalHir $hir] }
            cranelift-generic { core::formatValue [native::evalHir $hir -specialize 0] }
            default { error "roundtrip.tcl: unknown backend $backend" }
        }
    } value options]
    return [expr {$failed ? "error [dict get $options -errorcode]: $value" : "ok $value"}]
}

proc artifacts {hir backends} {
    global options
    set kept [expr {[dict get $options -via] eq "cache" || [dict get $options -trait-source]}]
    set result [list hir [sum [normalized [expr {$kept ? $hir : [dict remove $hir traitSource]}]]]]
    foreach {name script} {
        coreir {hir::lower $hir}
        tclcode {dict get [core::compiler::compileHir $hir] code}
        nir {native::nir $hir}
        nir-generic {native::nir $hir -specialize 0}
    } {
        if {[catch $script value failure]} {
            set value "error [dict get $failure -errorcode]: $value"
        }
        if {$name eq "tclcode"} {
            regsub -all {(unit|block|v|t)[0-9]+} $value {\1N} value
        }
        lappend result $name [sum $value]
    }
    foreach backend $backends {
        lappend result $backend [sum [outcome $hir $backend]]
    }
    return $result
}

if {[dict get $options -via] ni {interchange cache}} {
    error "roundtrip.tcl: -via is interchange or cache"
}

# The HIR of the suite at PATH through the cache in DIR.
proc cached {path dir} {
    return [surface::readProgramFile $path -warnings off -cache $dir]
}

if {[dict get $options -alone] ne ""} {
    # A fresh process building one suite: its HIR's checksum.
    puts [sum [normalized [surface::readProgramFile [dict get $options -alone] -warnings off -cache ""]]]
    exit 0
}

if {[dict get $options -child] ne ""} {
    # The fresh process: every entry of the list in FILE (a .hirx file, or a
    # suite and the cache directory), read and checksummed.
    set f [open [dict get $options -child]]
    set entries [read $f]
    close $f
    set builds [dict get [hir::BuildStats] builds]
    foreach entry $entries {
        if {[dict get $options -via] eq "cache"} {
            lassign $entry path dir
            set hir [cached $path $dir]
        } else {
            set path $entry
            set hir [hir::interchange::readFile $path]
        }
        puts [list [file rootname [file tail $path]] [artifacts $hir [dict get $options -backends]]]
        flush stdout
    }
    puts [list builds [expr {[dict get [hir::BuildStats] builds] - $builds}]]
    if {[dict get $options -via] eq "cache"} {
        puts [list misses [dict get [surface::cache::stats] misses]]
    }
    exit 0
}

set suites [dict get $options -suites]
if {$suites eq "all"} {
    set suites [lmap path [lsort [glob -directory [file join $root tests golden] *.bot]] {file tail $path}]
}
set dir [file tempdir botlish-hir-interchange]
try {
    set expected [dict create]
    set files {}
    set undeclared 0
    foreach suite $suites {
        set source [file join $root tests golden $suite]
        if {[dict get $options -via] eq "cache"} {
            set hir [cached $source [file join $dir cache]]
            lappend files [list $source [file join $dir cache]]
            # The cache's dependencies are the imported modules' paths
            # (surface::cache::Dependencies): every other file the HIR was
            # built from must be one of them.
            set imported [lmap dependency [surface::cache::Dependencies $hir {}] {lindex $dependency 0}]
            dict for {id file} [dict get $hir files] {
                if {[dict get $file path] ne $source && [dict get $file path] ni $imported} {
                    incr undeclared
                    puts "DIFFERS [file rootname $suite]: built from [dict get $file path], which is no dependency of its cache entry"
                }
            }
        } else {
            set hir [surface::readProgramFile $source -warnings off -cache ""]
            set path [file join $dir [file rootname $suite].hirx]
            hir::interchange::writeFile $path $hir -trait-source [dict get $options -trait-source]
            lappend files $path
        }
        dict set expected [file rootname $suite] [artifacts $hir [dict get $options -backends]]
    }
    set list [file join $dir files.txt]
    set f [open $list w]
    puts $f $files
    close $f
    set output [exec tclsh9.0 [info script] -child $list -backends [dict get $options -backends] \
        -via [dict get $options -via] -trait-source [dict get $options -trait-source] 2>@1]
    set differences $undeclared
    set compared 0
    set seen 0
    foreach line [split [string trim $output] \n] {
        lassign $line name sums
        if {$name in {builds misses}} {
            if {$sums != 0} {
                incr differences
                puts "DIFFERS the fresh process had $sums $name: it ran the front end"
            }
            continue
        }
        incr seen
        foreach {artifact value} $sums {
            incr compared
            if {$value ne [dict get $expected $name $artifact]} {
                incr differences
                puts "DIFFERS $name $artifact: built [dict get $expected $name $artifact], read back $value"
            }
        }
    }
    if {[dict get $options -via] eq "cache"} {
        foreach suite $suites {
            set alone [exec tclsh9.0 [info script] -alone [file join $root tests golden $suite]]
            incr compared
            if {$alone ne [dict get $expected [file rootname $suite] hir]} {
                incr differences
                puts "DIFFERS [file rootname $suite] hir: built after the suites before it [dict get $expected [file rootname $suite] hir], alone $alone"
            }
        }
    }
    if {$seen != [llength $files]} {
        incr differences
        puts "DIFFERS the fresh process read $seen of [llength $files] files:\n$output"
    }
    puts "[llength $suites] suites, $compared artifacts and outcomes compared, $differences differ"
} finally {
    file delete -force $dir
}
exit [expr {$differences > 0}]
