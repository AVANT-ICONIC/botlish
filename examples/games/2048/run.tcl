# run.tcl -- runs the 2048 workload's programs (2048-ENGINE-WORKLOAD.md).
#
#   tclsh9.0 examples/games/2048/run.tcl ?-backend B? ?-warnings W? FILE.bot ...
#   tclsh9.0 examples/games/2048/run.tcl -hirx OUT.hirx FILE.bot
#   tclsh9.0 examples/games/2048/run.tcl -suite ?-backends LIST?
#
# The engine, game2048.bot, is an ordinary module, and its programs (the
# demo, the golden suite, the benchmark) `import game2048`. Botlish resolves
# `import NAME` to exactly $::core::libraryDir/NAME.bot -- lib/, the
# standard library -- and has no other module root (docs/README.md section
# 17, "Modules"), so this script compiles them against a private library
# directory: a copy of lib/ with game2048.bot added, in a temporary
# directory removed on exit (the composition tests/helpers.tcl's
# withPrivateLibrary uses). The engine is not standard library and is not
# installed into lib/.
#
# FILE.bot is compiled once (warnings off unless -warnings says otherwise)
# and run on backend B (interp, compile, cranelift, cranelift-generic;
# default interp); its value is printed, one line per String when it is a
# List of Strings. -suite runs golden.bot on every backend of LIST (default
# all four) with tests/golden/run.tcl's runner and prints its report; the
# exit status is 1 if a test failed, the backends disagreed or a program did
# not compile or run.
#
# Other scripts source this file for game2048::library and game2048::run.

namespace eval game2048 {
    variable here [file dirname [file normalize [info script]]]
    variable root [file dirname [file dirname [file dirname $here]]]
    variable library ""
}
source [file join $::game2048::root tests golden run.tcl]

# The private library directory (made on first use): lib/ plus the engine.
proc game2048::library {} {
    variable library
    variable here
    variable root
    if {$library eq ""} {
        set library [file tempdir]
        foreach entry [glob -directory [file join $root lib] *] {
            file copy $entry $library
        }
        file copy [file join $here game2048.bot] $library
        set ::core::libraryDir $library
    }
    return $library
}

proc game2048::cleanup {} {
    variable library
    if {$library ne ""} {
        file delete -force $library
        set library ""
    }
}

# Compiles FILE against the private library: the HIR, or an error.
proc game2048::compile {file {warnings off}} {
    library
    return [surface::readProgramFile $file -warnings $warnings]
}

# Runs HIR on BACKEND and returns the program's value.
proc game2048::run {hir backend} {
    switch -- $backend {
        cranelift { return [native::evalHir $hir] }
        cranelift-generic { return [native::evalHir $hir -specialize 0] }
        compile { return [core::compiler::evalHir $hir] }
        interp {
            set saved [core::useBackend]
            core::useBackend interp
            try {
                return [core::evalProgram [hir::lower $hir]]
            } finally {
                core::useBackend $saved
            }
        }
        default { error "unknown backend $backend" }
    }
}

# The text of VALUE: one line per String of a List of Strings, else the
# value as Botlish shows it.
proc game2048::text {value} {
    if {[core::value::kind $value] eq "list"
            && ![catch {lmap item [core::value::items $value] {core::value::strOf $item}} lines]} {
        return [join $lines \n]
    }
    return [core::value::show $value 1]
}

proc game2048::main {argv} {
    variable here
    set backend interp
    set backends {interp compile cranelift-generic cranelift}
    set warnings off
    set suite 0
    set hirx ""
    set files {}
    for {set i 0} {$i < [llength $argv]} {incr i} {
        set arg [lindex $argv $i]
        switch -- $arg {
            -backend { set backend [lindex $argv [incr i]] }
            -backends { set backends [split [lindex $argv [incr i]] ,] }
            -warnings { set warnings [lindex $argv [incr i]] }
            -suite { set suite 1 }
            -hirx { set hirx [lindex $argv [incr i]] }
            default { lappend files $arg }
        }
    }
    try {
        library
        if {$suite} {
            return [golden::main [list -backends [join $backends ,] [file join $here golden.bot]]]
        }
        foreach file $files {
            if {[catch {compile $file $warnings} hir options]} {
                puts stderr "$file: $hir ([dict get $options -errorcode])"
                return 1
            }
            if {$hirx ne ""} {
                hir::interchange::writeFile $hirx $hir
                continue
            }
            if {[catch {run $hir $backend} value options]} {
                puts stderr "$file: $value ([dict get $options -errorcode])"
                return 1
            }
            puts [text $value]
        }
        return 0
    } finally {
        cleanup
    }
}

if {[info script] eq $::argv0} {
    exit [game2048::main $argv]
}
