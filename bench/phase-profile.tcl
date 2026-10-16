# phase-profile.tcl -- runs a Tcl script (a tcltest file, the golden runner,
# main.tcl) under a phase profiler: the compiler's front-end, front-end cache
# and backend procedures, timed in the very process the workflow runs.
#
#   tclsh9.0 bench/phase-profile.tcl OUT SCRIPT ?ARG ...?
#
# SCRIPT runs with ::argv0 SCRIPT and ::argv the ARGs, as `tclsh9.0 SCRIPT
# ARG ...` would run it. When it ends (or calls exit) the profile is written
# to OUT as one Tcl dict:
#
#   wall      microseconds from this script's start to the end
#   rss       the process's peak resident set (VmHWM), MB
#   self      PHASE -> microseconds in PHASE minus the profiled phases it
#             called (a phase's self time includes every unprofiled helper)
#   calls     PHASE -> calls
#   roots     PHASE -> inclusive microseconds of the calls made while no
#             other phase was active: a partition of the profiled time
#   byRoot    ROOT -> PHASE -> self microseconds of PHASE under root ROOT
#
# `evalProgram` is core::evalProgram: the reference interpreter's run on the
# interp backend; in the Tcl suite's harness every other backend is
# dispatched from it too (its own phases are below it).
#
# The golden runner's per-backend runs are the phase "run:BACKEND" (the
# runner's golden::run, by its backend argument), so a backend's own phases
# are attributed to it through byRoot.
#
# The script loads the compiler itself, possibly several times (a test file
# sources tests/helpers.tcl, which sources compiler/compiler.tcl), and each
# load redefines the procedures. So `proc` is wrapped: a phase procedure is
# wrapped as soon as it is defined. Time spent in `source` is the phase
# "load" (loading code, including the compiler; it includes the `proc`
# hook's own small cost).

namespace eval ::phaseProfile {
    variable start [clock microseconds]
    variable out [lindex $::argv 0]
    variable script [file normalize [lindex $::argv 1]]
    variable stack {}
    variable byName [dict create]
    variable self [dict create]
    variable calls [dict create]
    variable roots [dict create]
    variable byRoot [dict create]
    variable root ""
    variable dumped 0

    # Phase name -> procedure. Front end (bench/golden-suites.tcl's phases),
    # its entry points, the front-end cache and the backends.
    variable phases {
        frontend:readProgramFile surface::readProgramFile
        frontend:compile surface::compile
        frontend:hir-build hir::build
        parse surface::parse
        lower-to-hir surface::lowerToHir
        static-decisions hir::static::decide
        static-deps hir::staticdeps::Deps
        method-decisions hir::DecideMethodCalls
        build hir::BuildOnce
        resolve hir::resolve::program
        hygiene hir::hygiene::apply
        coroutines hir::coroutines::analyze
        signatures hir::signatures::infer
        declared-results hir::range::verifyDeclaredResults
        declared-params hir::range::verifyDeclaredParams
        callables hir::callables::verify
        lockstep hir::lockstep::verify
        structs hir::structs::verify
        contexts hir::contexts::verify
        coroutines-verify hir::coroutines::verify
        affine hir::affine::verify
        mutvec hir::mutvec::verify
        syscall hir::syscall::verify
        semantic-instances hir::semantic::verify
        errorsets hir::errorsets::verify
        module-bindings hir::modulebinding::validate
        traits-verify hir::traits::verify
        traits-monomorphize hir::traits::monomorphize
        finish surface::lower::Finish
        cache:lookup surface::cache::lookup
        cache:store surface::cache::store
        read-file core::ReadFile
        cache:decode hir::interchange::decode
        cache:encode hir::interchange::encode
        cache:fingerprint hir::interchange::Fingerprint
        activate hir::activate
        interp:core-ir-lowering hir::lower
        affine-temporaries hir::affine::temporaries
        evalProgram core::evalProgram
        compile:generate core::compiler::GenerateUnit
        compile:block core::compiler::CompileBlock
        compile:block-lowering hir::lower::body
        compile:define core::compiler::Define
        compile:run-unit core::compiler::evalUnit
        compile:run-unit-in core::compiler::runUnit
        compile:core-ir-program core::compiler::runProgram
        native:prepare native::prepareHir
        native:lower native::lower::program
        native:specialize hir::specialize::analyze
        native:range hir::range::analyze
        native:escape hir::escape::analyze
        native:block-escape hir::blockescape::analyze
        native:string-region hir::stringregion::analyze
        native:traversal hir::traversal::analyze
        native:construction hir::construction::analyze
        native:raw-abi native::rawabi::plan
        native:short-string native::shortstr::plan
        native:lower-function native::lower::Function
        native:driver native::Driver
        golden:compile golden::compile
    }
}

# Phase procedure (fully qualified, no leading ::) -> phase name.
foreach {phase name} $::phaseProfile::phases {
    dict set ::phaseProfile::byName $name $phase
}

# Wraps procedure NAME (fully qualified, no leading ::), just defined, as its
# phase; the golden runner's golden::run as "run:BACKEND".
proc ::phaseProfile::Wrap {name} {
    variable byName
    if {[info commands ::${name}__prof] ne ""} {
        rename ::${name}__prof {}
    }
    rename ::$name ::${name}__prof
    if {$name eq "golden::run"} {
        ::phaseProfile::proc ::$name {hir backend} {
            set __prof [::phaseProfile::Enter run:$backend]
            set __code [catch {uplevel 1 [list ::golden::run__prof $hir $backend]} __result __options]
            ::phaseProfile::Leave run:$backend $__prof
            return -options $__options $__result
        }
        return
    }
    ::phaseProfile::proc ::$name args [string map [list @PHASE@ [list [dict get $byName $name]] @NAME@ $name] {
        set __prof [::phaseProfile::Enter @PHASE@]
        set __code [catch {uplevel 1 [list ::@NAME@__prof {*}$args]} __result __options]
        ::phaseProfile::Leave @PHASE@ $__prof
        return -options $__options $__result
    }]
}

# `proc`: a phase procedure is wrapped as soon as it is defined (again: a
# test file reloads the compiler).
dict set ::phaseProfile::byName golden::run run
rename ::proc ::phaseProfile::proc
::phaseProfile::proc ::proc {name arguments body} {
    uplevel 1 [list ::phaseProfile::proc $name $arguments $body]
    set qualified [string range [uplevel 1 [list namespace which -command $name]] 2 end]
    if {[dict exists $::phaseProfile::byName $qualified]} {
        ::phaseProfile::Wrap $qualified
    }
}

proc ::phaseProfile::Enter {phase} {
    variable stack
    variable root
    if {![llength $stack]} {
        set root $phase
    }
    lappend stack 0
    return [clock microseconds]
}

proc ::phaseProfile::Leave {phase start} {
    variable stack
    variable self
    variable calls
    variable roots
    variable byRoot
    variable root
    set elapsed [expr {[clock microseconds] - $start}]
    set children [lindex $stack end]
    set stack [lrange $stack 0 end-1]
    set own [expr {$elapsed - $children}]
    dict incr self $phase $own
    dict incr calls $phase
    if {[dict exists $byRoot $root $phase]} {
        dict set byRoot $root $phase [expr {[dict get $byRoot $root $phase] + $own}]
    } else {
        dict set byRoot $root $phase $own
    }
    if {[llength $stack]} {
        lset stack end [expr {[lindex $stack end] + $elapsed}]
    } else {
        dict incr roots $phase $elapsed
    }
}

proc ::phaseProfile::Dump {} {
    variable dumped
    variable out
    variable start
    if {$dumped} return
    set dumped 1
    set rss 0
    if {![catch {open /proc/self/status} f]} {
        if {[regexp {VmHWM:\s+(\d+) kB} [read $f] -> kb]} { set rss [expr {$kb / 1024}] }
        close $f
    }
    set result [dict create wall [expr {[clock microseconds] - $start}] rss $rss \
        self $::phaseProfile::self calls $::phaseProfile::calls \
        roots $::phaseProfile::roots byRoot $::phaseProfile::byRoot]
    set f [open $out w]
    fconfigure $f -encoding utf-8
    puts -nonewline $f $result
    close $f
}

# `source`: timed as "load".
rename ::source ::phaseProfile::source
proc ::source args {
    set __prof [::phaseProfile::Enter load]
    set __code [catch {uplevel 1 [list ::phaseProfile::source {*}$args]} __result __options]
    ::phaseProfile::Leave load $__prof
    return -options $__options $__result
}

set argv [lrange $argv 2 end]
set argc [llength $argv]
set argv0 $::phaseProfile::script

rename ::exit ::phaseProfile::exit
proc ::exit {{status 0}} {
    ::phaseProfile::Dump
    ::phaseProfile::exit $status
}

# The script itself is not "load": only what it sources.
set ::phaseProfile::code [catch {uplevel #0 [list ::phaseProfile::source $::phaseProfile::script]} ::phaseProfile::message ::phaseProfile::options]
::phaseProfile::Dump
if {$::phaseProfile::code == 1} {
    puts stderr [dict get $::phaseProfile::options -errorinfo]
    ::phaseProfile::exit 1
}
::phaseProfile::exit 0
