# golden-suites.tcl -- the economics of the golden suites as a compiler
# workload (LARGE-SCALE-GOLDEN-MIGRATION.md, "Performance"): what compiling
# and running each suite costs, phase by phase, on every backend.
#
#   tclsh9.0 bench/golden-suites.tcl ?-backends LIST? ?-warm N? ?-profile 0|1?
#                                    ?-jobs N? ?-cache DIR? ?FILE.bot ...?
#
# Cold (the default): each suite in a fresh tclsh (one at a time, or -jobs N
# at a time -- then the times include the contention), which reports:
#
#   tests, lines, static     the report's test count, the suite's source
#                            lines and its `static compile:` sites (accepted /
#                            rejected), static decision rounds and whole
#                            builds (hir/static.tcl's staticStats), HIR size
#                            (expressions)
#   front end                surface::readProgramFile (warnings off): parse,
#                            lowering, every build, analysis and decision
#   interp                   HIR -> Core IR lowering (hir::lower), then the
#                            reference interpreter's run
#   compile                  the Tcl compiler's code generation
#                            (core::compiler::compileUnit) and the rest of its
#                            run (execution)
#   cranelift, -generic      NIR lowering (Tcl), Cranelift code generation and
#                            one execution (native::measure, one run)
#   peak RSS                 the process's VmHWM after everything
#
# and, with -profile 1, the front end's self time per phase (a proc's time
# minus the profiled procs it called), summed over the suites.
#
# -warm N: every suite's front end N times in ONE process, in order, to show
# process-history effects (each pass's total, and each suite's first and last
# time).

set root [file dirname [file dirname [file normalize [info script]]]]

# The profiled front-end and back-end procedures, by phase name.
set phases {
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
    core-ir-lowering hir::lower
    tcl-codegen core::compiler::compileUnit
}

namespace eval prof {
    variable stack {}
    variable self [dict create]
    variable calls [dict create]
}

proc prof::wrap {phase name} {
    if {[info commands ::$name] eq "" || [info commands ::${name}__prof] ne ""} return
    rename ::$name ::${name}__prof
    proc ::$name args [string map [list @PHASE@ $phase @NAME@ $name] {
        set start [clock microseconds]
        lappend ::prof::stack 0
        set code [catch {uplevel 1 [list ::@NAME@__prof {*}$args]} result options]
        set elapsed [expr {[clock microseconds] - $start}]
        set children [lindex $::prof::stack end]
        set ::prof::stack [lrange $::prof::stack 0 end-1]
        dict incr ::prof::self @PHASE@ [expr {$elapsed - $children}]
        dict incr ::prof::calls @PHASE@
        if {[llength $::prof::stack]} {
            lset ::prof::stack end [expr {[lindex $::prof::stack end] + $elapsed}]
        }
        return -options $options $result
    }]
}

proc prof::reset {} {
    set ::prof::self [dict create]
    set ::prof::calls [dict create]
}

proc vmhwm {} {
    if {[catch {open /proc/self/status} f]} { return 0 }
    set text [read $f]
    close $f
    if {[regexp {VmHWM:\s+(\d+) kB} $text -> kb]} { return [expr {$kb / 1024}] }
    return 0
}

proc seconds {us} { return [expr {$us / 1e6}] }

# ---------------------------------------------------------------------------
# One suite, in this process.

proc measureOne {path backends profile} {
    source [file join $::root compiler compiler.tcl]
    source [file join $::root surface surface.tcl]
    source [file join $::root native native.tcl]
    source [file join $::root tests golden run.tcl]
    interp recursionlimit {} 100000
    if {$profile} {
        foreach {phase name} $::phases {
            prof::wrap $phase $name
        }
    } else {
        # The Tcl compiler's code generation is told apart from its run by
        # this wrapper alone: always installed.
        prof::wrap tcl-codegen core::compiler::compileUnit
    }
    set f [open $path]
    fconfigure $f -encoding utf-8
    set text [read $f]
    close $f
    set result [dict create suite [file tail $path] lines [llength [split [string trimright $text \n] \n]] \
        staticText [regexp -all -line {^\s*static compile:} $text]]
    prof::reset
    set us [lindex [time {set hir [surface::readProgramFile $path -warnings off]}] 0]
    dict set result frontend [seconds $us]
    dict set result frontendProfile $::prof::self
    dict set result hirExprs [dict size [dict get $hir exprs]]
    set accepted 0
    set rejected 0
    if {[dict exists $hir staticSites]} {
        dict for {key site} [dict get $hir staticSites] {
            if {[dict get $site outcome] eq "rejected"} { incr rejected } else { incr accepted }
        }
    }
    dict set result staticAccepted $accepted
    dict set result staticRejected $rejected
    foreach counter {rounds builds methodTrials} {
        dict set result $counter [expr {[dict exists $hir staticStats $counter] ? [dict get $hir staticStats $counter] : 0}]
    }
    set tests ""
    # The backends the suite excludes (its golden-exclude header lines,
    # tests/golden/run.tcl) are not run: they would report the construct
    # they refuse, not a cost.
    set excluded [golden::exclusions $path]
    foreach backend $backends {
        if {[dict exists $excluded $backend]} {
            dict set result $backend [dict create excluded [dict get $excluded $backend]]
            continue
        }
        switch -- $backend {
            interp - compile {
                prof::reset
                core::useBackend $backend
                set us [lindex [time {set ir [hir::lower $hir]}] 0]
                if {[catch {
                    set runUs [lindex [time {set value [core::evalProgram $ir]}] 0]
                } message opts]} {
                    dict set result $backend [dict create error [dict get $opts -errorcode]]
                    continue
                }
                set codegen [expr {[dict exists $::prof::self tcl-codegen] ? [dict get $::prof::self tcl-codegen] : 0}]
                dict set result $backend [dict create lowering [seconds $us] codegen [seconds $codegen] \
                    execution [seconds [expr {$runUs - $codegen}]]]
            }
            cranelift - cranelift-generic {
                set options [expr {$backend eq "cranelift-generic" ? {-specialize 0} : {}}]
                if {[catch {native::measure $hir 1 {*}$options} measured opts]} {
                    dict set result $backend [dict create error [dict get $opts -errorcode]]
                    continue
                }
                lassign $measured lower compile best collections value
                dict set result $backend [dict create lowering [seconds $lower] codegen [seconds $compile] \
                    execution [seconds $best]]
            }
        }
        if {$tests eq "" && [info exists value]} {
            catch {
                set lines [lmap item [core::value::items $value] {core::value::strOf $item}]
                set tests [llength [lsearch -all -regexp $lines {^(PASS|FAIL) }]]
                dict set result summary [lindex $lines end]
            }
        }
    }
    dict set result tests $tests
    dict set result rss [vmhwm]
    return $result
}

# ---------------------------------------------------------------------------
# The driver.

set options [dict create -backends {interp compile cranelift-generic cranelift} -warm 0 -profile 1 -jobs 1 -one "" -cache ""]
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {[string match -* $arg]} {
        if {![dict exists $options $arg]} { error "unknown option $arg" }
        dict set options $arg [lindex $argv [incr i]]
    } else {
        lappend files [file normalize $arg]
    }
}
set backends [split [string map {" " ,} [dict get $options -backends]] ,]
set backends [lsearch -all -inline -not -exact $backends ""]

if {[dict get $options -one] ne ""} {
    puts [list result [measureOne [dict get $options -one] $backends [dict get $options -profile]]]
    exit 0
}
if {$files eq {}} {
    set files [lsort [glob -directory [file join $root tests golden] *.bot]]
}

if {[dict get $options -warm] > 0} {
    source [file join $root compiler compiler.tcl]
    source [file join $root surface surface.tcl]
    interp recursionlimit {} 100000
    set times [dict create]
    for {set pass 1} {$pass <= [dict get $options -warm]} {incr pass} {
        set total 0
        foreach path $files {
            set us [lindex [time {surface::readProgramFile $path -warnings off}] 0]
            dict lappend times [file tail $path] [seconds $us]
            set total [expr {$total + $us}]
        }
        puts [format "warm pass %d: front end of %d suites %.1f s (peak RSS %d MB)" $pass [llength $files] [seconds $total] [vmhwm]]
        flush stdout
    }
    set passes {}
    for {set pass 1} {$pass <= [dict get $options -warm]} {incr pass} { lappend passes "pass $pass" }
    puts "\n| suite | [join $passes { | }] |"
    puts "|---|[string repeat ---| [llength $passes]]"
    dict for {suite list} $times {
        puts "| $suite | [join [lmap s $list {format %.1f $s}] { | }] |"
    }
    exit 0
}

# Cold: one process per suite. With -cache DIR, a suite whose result DIR
# already holds (NAME.result, written by an earlier run with the same DIR) is
# not measured again, so a long measurement can be run in pieces.
source [file join $root audit golden tools tree.tcl]
set cache [dict get $options -cache]
proc cached {path} {
    return [file join $::cache [file rootname [file tail $path]].result]
}
set commands [dict create]
foreach path $files {
    if {$cache ne "" && [file exists [cached $path]]} continue
    dict set commands $path [list [info nameofexecutable] [info script] -one $path \
        -backends [join $backends ,] -profile [dict get $options -profile]]
}
# The result dict of one suite's measurement OUTCOME ({STATUS OUTPUT
# SECONDS}), or "" (reported) when it produced none.
proc resultOf {path outcome} {
    lassign $outcome status output seconds
    set line [lsearch -inline [split $output \n] {result *}]
    if {$line eq ""} {
        puts stderr "[file tail $path]: no result ([goldentools::lastLine $output])"
        return ""
    }
    set r [lindex $line 1]
    dict set r process $seconds
    return $r
}

# With -cache, the suites run in batches of -jobs and each batch's results
# are written as soon as it ends, so an interrupted run loses at most one
# batch.
set start [clock milliseconds]
set measured [dict create]
set pending [dict keys $commands]
set batch [expr {$cache ne "" ? [dict get $options -jobs] : [llength $pending]}]
while {[llength $pending] > 0} {
    set now [lrange $pending 0 [expr {max($batch, 1) - 1}]]
    set pending [lrange $pending [llength $now] end]
    set outcomes [goldentools::runParallel [dict get $options -jobs] 7200 \
        [dict filter $commands script {key -} {expr {$key in $now}}]]
    dict for {path outcome} $outcomes {
        set r [resultOf $path $outcome]
        if {$r eq ""} continue
        dict set measured $path $r
        if {$cache ne ""} {
            file mkdir $cache
            set f [open [cached $path] w]
            fconfigure $f -encoding utf-8
            puts -nonewline $f $r
            close $f
        }
    }
}
set wall [expr {([clock milliseconds] - $start) / 1000.0}]
set results {}
foreach path $files {
    if {[dict exists $measured $path]} {
        lappend results [dict get $measured $path]
    } elseif {![dict exists $commands $path]} {
        lappend results [goldentools::readFile [cached $path]]
    }
}

proc cell {r backend key} {
    if {![dict exists $r $backend]} { return - }
    if {[dict exists $r $backend excluded]} { return excluded }
    if {[dict exists $r $backend error]} { return [dict get $r $backend error] }
    return [format %.2f [dict get $r $backend $key]]
}

set sum [dict create]
proc add {key value} { dict set ::sum $key [expr {([dict exists $::sum $key] ? [dict get $::sum $key] : 0) + $value}] }

puts "## Golden suites: size and front end (cold, one process per suite)\n"
puts "| suite | tests | lines | static sites (rejected) | rounds | builds | HIR exprs | front end s | process s | peak RSS MB |"
puts "|---|---|---|---|---|---|---|---|---|---|"
foreach r $results {
    puts "| [dict get $r suite] | [dict get $r tests] | [dict get $r lines] | [expr {[dict get $r staticAccepted] + [dict get $r staticRejected]}] ([dict get $r staticRejected]) | [dict get $r rounds] | [dict get $r builds] | [dict get $r hirExprs] | [format %.1f [dict get $r frontend]] | [format %.1f [dict get $r process]] | [dict get $r rss] |"
    foreach key {tests lines staticAccepted staticRejected rounds builds hirExprs frontend process} {
        if {[string is double -strict [dict get $r $key]]} { add $key [dict get $r $key] }
    }
}
puts "| total | [dict get $sum tests] | [dict get $sum lines] | [expr {[dict get $sum staticAccepted] + [dict get $sum staticRejected]}] ([dict get $sum staticRejected]) | [dict get $sum rounds] | [dict get $sum builds] | [dict get $sum hirExprs] | [format %.1f [dict get $sum frontend]] | [format %.1f [dict get $sum process]] | max [tcl::mathfunc::max {*}[lmap r $results {dict get $r rss}]] |"
puts "\nElapsed: [format %.1f $wall] s with [dict get $options -jobs] job(s), [dict size $measured] suite(s) measured by this run[expr {$cache ne "" ? ", [expr {[llength $results] - [dict size $measured]}] read from $cache" : ""}].\n"

puts "## Back ends (seconds): lowering / code generation / execution\n"
puts "| suite | Core IR lowering | interp run | Tcl codegen | Tcl compiled run | NIR lowering | Cranelift codegen | native run | generic NIR lowering | generic codegen | generic run |"
puts "|---|---|---|---|---|---|---|---|---|---|---|"
foreach r $results {
    puts "| [dict get $r suite] | [cell $r interp lowering] | [cell $r interp execution] | [cell $r compile codegen] | [cell $r compile execution] | [cell $r cranelift lowering] | [cell $r cranelift codegen] | [cell $r cranelift execution] | [cell $r cranelift-generic lowering] | [cell $r cranelift-generic codegen] | [cell $r cranelift-generic execution] |"
    foreach {backend key} {interp lowering interp execution compile codegen compile execution cranelift lowering cranelift codegen cranelift execution cranelift-generic lowering cranelift-generic codegen cranelift-generic execution} {
        if {[dict exists $r $backend $key]} { add $backend.$key [dict get $r $backend $key] }
    }
}
set totals {}
foreach {backend key} {interp lowering interp execution compile codegen compile execution cranelift lowering cranelift codegen cranelift execution cranelift-generic lowering cranelift-generic codegen cranelift-generic execution} {
    lappend totals [expr {[dict exists $sum $backend.$key] ? [format %.2f [dict get $sum $backend.$key]] : "-"}]
}
puts "| total | [join $totals { | }] |"

if {[dict get $options -profile]} {
    set profile [dict create]
    foreach r $results {
        dict for {phase us} [dict get $r frontendProfile] { dict incr profile $phase $us }
    }
    set total [tcl::mathop::+ 0 {*}[dict values $profile]]
    puts "\n## Front end: self time per phase, all suites\n"
    puts "| phase | self s | share |"
    puts "|---|---|---|"
    foreach {phase us} [lsort -stride 2 -index 1 -integer -decreasing $profile] {
        puts [format "| %s | %.1f | %.1f%% |" $phase [seconds $us] [expr {$total ? 100.0 * $us / $total : 0}]]
    }
    puts [format "| (unprofiled: front end minus phases) | %.1f | |" [expr {[dict get $sum frontend] - [seconds $total]}]]
}
