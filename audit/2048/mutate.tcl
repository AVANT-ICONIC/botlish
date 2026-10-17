# mutate.tcl -- mutation evidence for the 2048 engine's golden suite
# (2048-ENGINE-WORKLOAD.md, "Mutation evidence").
#
#   tclsh9.0 audit/2048/mutate.tcl ?-backends LIST? ?-jobs N? ?-timeout S? ?NAME ...?
#
# For every mutant of audit/2048/mutants.txt (or the NAMEs given): a
# private application directory -- a copy of examples/games/2048/golden.bot
# with the mutated game2048.bot beside it, its application module
# (IMPORTS.md) -- and one run of that golden.bot through tests/golden/run.tcl
# (default backend compile: the mutants are engine bugs, not backend ones).
# A mutant is killed when a test fails or the suite stops compiling. Every
# mutant must still apply (its text occurs exactly once) and be killed; the
# unmutated engine must pass, so a kill means the mutation.
#
# Prints one line per mutant: killed (the failing tests), SURVIVED or NOT
# APPLIED. Exit status 1 if any survived, did not apply, or the baseline
# failed. Scratch state lives in a `file tempdir` directory (AGENTS.md).

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname $here]]
source [file join $root audit golden tools tree.tcl]

set options [dict create -backends compile -jobs [exec nproc] -timeout 900]
set names {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {[string match -* $arg]} {
        if {![dict exists $options $arg]} { error "unknown option $arg" }
        dict set options $arg [lindex $argv [incr i]]
    } else {
        lappend names $arg
    }
}

set engine examples/games/2048/game2048.bot
set suite [file join $root examples games 2048 golden.bot]
set original [goldentools::readFile [file join $root $engine]]

# A private application under WORK/NAME: the suite, and the engine text
# TEXT beside it. Its suite's path.
proc application {work name text} {
    set dir [file join $work $name]
    file mkdir $dir
    file copy $::suite [file join $dir golden.bot]
    goldentools::writeFile [file join $dir game2048.bot] $text
    return [file join $dir golden.bot]
}

set work [file tempdir botlish-2048-mutate]
set exit 0
try {
    set commands [dict create]
    set problems {}
    dict set commands baseline [list [info nameofexecutable] [file join $root tests golden run.tcl] \
        -backends [dict get $options -backends] -names [application $work baseline $original]]
    foreach {name description edits} [goldentools::readMutants [file join $here mutants.txt]] {
        if {$names ne {} && $name ni $names} continue
        set text $original
        set applied 1
        foreach {file old new} $edits {
            if {$file ne $engine} { error "mutant $name edits $file, not $engine" }
            set first [string first $old $text]
            if {$first < 0 || [string first $old $text [expr {$first + 1}]] >= 0} {
                set applied 0
                break
            }
            set text [string replace $text $first [expr {$first + [string length $old] - 1}] $new]
        }
        if {!$applied} {
            lappend problems "$name: NOT APPLIED (its text does not occur exactly once)"
            continue
        }
        dict set commands $name [list [info nameofexecutable] [file join $root tests golden run.tcl] \
            -backends [dict get $options -backends] -names [application $work m-$name $text]]
    }
    set results [goldentools::runParallel [dict get $options -jobs] [dict get $options -timeout] $commands]
    lassign [goldentools::suiteVerdicts [lindex [dict get $results baseline] 1]] state verdicts
    if {$state ne "ok"} {
        puts "baseline: $state -- the unmutated engine must pass"
        set exit 1
    }
    set killed 0
    set total 0
    foreach name [dict keys $commands] {
        if {$name eq "baseline"} continue
        incr total
        lassign [dict get $results $name] status output seconds
        lassign [goldentools::suiteVerdicts $output] state verdicts
        set failing [lmap {n v} $verdicts {if {$v ne "FAIL"} continue; set n}]
        if {$state eq "ok"} {
            puts [format "%-28s SURVIVED" $name]
            set exit 1
        } else {
            incr killed
            set why [expr {$state eq "failed" ? "[llength $failing] failing: [join [lrange $failing 0 3] {, }][expr {[llength $failing] > 4 ? ", ..." : ""}]" : $state}]
            puts [format "%-28s killed (%s)" $name $why]
        }
    }
    foreach p $problems { puts $p; set exit 1 }
    puts "$killed of $total mutants killed"
} finally {
    file delete -force $work
}
exit $exit
