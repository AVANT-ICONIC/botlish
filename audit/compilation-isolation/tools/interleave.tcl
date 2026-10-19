#!/usr/bin/env tclsh9.0
# interleave.tcl -- compilation isolation at corpus scale
# (COMPILATION-ISOLATION.md).
#
#   tclsh9.0 audit/compilation-isolation/tools/interleave.tcl ?-suites FILES?
#            ?-backends LIST? ?-print 1?
#
# In one process, compiles each golden suite of FILES (default: ten suites
# covering source types, structs, enums, error payloads, traits, context
# traits, coroutines and binary layouts) and takes the checksum of each of its
# backend artifacts right after its own compilation: the core IR, the Tcl
# compiler's code (unit, block and variable numbers normalized), specialized
# and generic NIR, and the outcome of each backend of LIST (default interp,
# compile, cranelift, cranelift-generic). Once every suite is compiled, it
# takes them again, in reverse order, from the HIRs it kept. Every checksum
# must be the same: a HIR's backends see its own declarations whatever was
# compiled since. Exits non-zero, naming each difference, otherwise.
#
# With -print 1 it also prints each suite's checksums, the tree's root path
# normalized, so that two trees (before and after a change) can be compared.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create \
    -suites {traits-path.bot harness.bot contexts.bot affinity.bot coroutines.bot errors.bot
        representation.bot declared-errors.bot ownership.bot binary-layout.bot layout-arrays.bot} \
    -backends {interp compile cranelift cranelift-generic} -print 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "interleave.tcl: unknown option $option" }
    dict set options $option $value
}

source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 200000

proc sum {text} {
    set text [string map [list $::root ROOT] $text]
    return [format %08x/%d [zlib crc32 [encoding convertto utf-8 $text]] [string length $text]]
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
            default { error "interleave.tcl: unknown backend $backend" }
        }
    } value options]
    return [expr {$failed ? "error [dict get $options -errorcode]: $value" : "ok $value"}]
}

proc artifacts {hir} {
    set result {}
    foreach {name script} {
        coreir {hir::lower $hir}
        tclcode {dict get [core::compiler::compileHir $hir] code}
        nir {native::nir $hir}
        nir-generic {native::nir $hir -specialize 0}
    } {
        if {[catch $script value options]} {
            set value "error [dict get $options -errorcode]: $value"
        }
        if {$name eq "tclcode"} {
            regsub -all {(unit|block|v|t)[0-9]+} $value {\1N} value
        }
        lappend result $name [sum $value]
    }
    foreach backend [dict get $::options -backends] {
        lappend result $backend [sum [outcome $hir $backend]]
    }
    return $result
}

set suites [dict get $options -suites]
set hirs [dict create]
set own [dict create]
foreach suite $suites {
    set hir [surface::readProgramFile [file join $root tests golden $suite] -warnings off]
    dict set hirs $suite $hir
    dict set own $suite [artifacts $hir]
    if {[dict get $options -print]} {
        puts "own $suite [dict get $own $suite]"
        flush stdout
    }
}
set differences 0
set compared 0
foreach suite [lreverse $suites] {
    set again [artifacts [dict get $hirs $suite]]
    if {[dict get $options -print]} {
        puts "interleaved $suite $again"
        flush stdout
    }
    foreach {name value} $again {
        incr compared
        if {$value ne [dict get $own $suite $name]} {
            incr differences
            puts "DIFFERS $suite $name: own [dict get $own $suite $name], after the other suites $value"
        }
    }
}
puts "[llength $suites] suites, $compared artifacts and outcomes compared, $differences differ"
exit [expr {$differences > 0}]
