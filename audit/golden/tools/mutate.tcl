# mutate.tcl -- mutation testing of the golden test framework, lib/test.bot
# (GOLDEN-TEST-FRAMEWORK.md, "Framework mutation results").
#
#   tclsh9.0 audit/golden/tools/mutate.tcl ?-only NAME,...? ?-mutants FILE?
#       ?-tests FILES? ?-suites 0|1? ?-fuzz N? ?-fuzz-seed S? ?-timeout SECONDS?
#
# Each mutant of FILE (default mutants.txt beside this script) is a
# deliberate bug, written as exact source replacements. For each, a private
# copy of the checkout (tree.tcl) gets the replacements and the detectors run
# in it:
#
#   * the test files FILES (default tests/golden-framework.test): killed if
#     a test fails or the file does not complete;
#   * with -suites 1 (the default), every golden suite (tests/golden/*.bot,
#     every backend): killed if a suite's status is not ok -- a suite that
#     fails a test, aborts, does not compile or whose backends disagree;
#   * with -fuzz N > 0 (default 6), audit/golden/tools/fuzz.tcl -n N -seed S
#     (every backend, against its independent model): killed if it reports a
#     disagreement or does not complete.
#
# A mutant every detector misses SURVIVES. The report lists each mutant and
# what killed it. Exit status 1 if any mutant survived or did not apply.

source [file join [file dirname [file normalize [info script]]] tree.tcl]

set options [dict create -only "" -mutants [file join [file dirname [file normalize [info script]]] mutants.txt] \
    -tests {tests/golden-framework.test} -suites 1 -fuzz 6 -fuzz-seed 11 -timeout 3600]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

set only [split [dict get $options -only] ,]
set selected {}
set native 0
foreach {name description edits} [goldentools::readMutants [dict get $options -mutants]] {
    if {$only ne {} && $name ni $only} continue
    lappend selected $name $description $edits
    if {[goldentools::isNative $edits]} { set native 1 }
}

set tree [goldentools::makeTree $native]
set timeout [dict get $options -timeout]
set results {}
try {
    foreach {name description edits} $selected {
        lassign [goldentools::apply $tree $edits] applied touched
        if {!$applied} {
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $touched"
            lappend results [list $name NOT-APPLIED {}]
            continue
        }
        set killers {}
        if {[goldentools::isNative $edits]} {
            set problem [goldentools::build $tree $timeout]
            if {$problem ne ""} {
                puts "NOT-BUILT $name: $problem"
                lappend results [list $name NOT-BUILT {}]
                goldentools::restore $tree $touched
                continue
            }
        }
        foreach testFile [dict get $options -tests] {
            lassign [goldentools::runTestFile $tree $testFile $timeout] failed passed incomplete
            if {$failed ne {}} {
                lappend killers "[file tail $testFile]: [llength $failed] failed ([join [lrange $failed 0 5] {, }][expr {[llength $failed] > 6 ? ", ..." : ""}])"
            }
            if {$incomplete ne ""} {
                lappend killers "incomplete: $incomplete"
            }
        }
        if {[dict get $options -suites]} {
            set bad {}
            dict for {suite outcome} [goldentools::runSuites $tree {} $timeout] {
                lassign $outcome state verdicts
                if {$state ne "ok"} {
                    set failing [lmap {n v} $verdicts {if {$v ne "FAIL"} continue; set n}]
                    lappend bad "[file tail $suite] $state[expr {$failing eq {} ? "" : " ([llength $failing] failed)"}]"
                }
            }
            if {$bad ne {}} {
                lappend killers "suites: [join $bad {; }]"
            }
        }
        if {[dict get $options -fuzz] > 0} {
            lassign [goldentools::run $timeout tclsh9.0 [file join $tree audit golden tools fuzz.tcl] \
                -n [dict get $options -fuzz] -seed [dict get $options -fuzz-seed]] status output
            if {$status != 0} {
                lappend killers "fuzz: [goldentools::lastLine $output]"
            }
        }
        set verdict [expr {$killers eq {} ? "SURVIVED" : "KILLED"}]
        puts "$verdict $name -- $description"
        foreach k $killers { puts "    $k" }
        flush stdout
        lappend results [list $name $verdict $killers]
        goldentools::restore $tree $touched
        if {[goldentools::isNative $edits]} {
            goldentools::build $tree $timeout
        }
    }
} finally {
    file delete -force $tree
}

set counts [dict create KILLED 0 SURVIVED 0 NOT-APPLIED 0 NOT-BUILT 0]
foreach r $results { dict incr counts [lindex $r 1] }
puts "\n[llength $results] mutants: [dict get $counts KILLED] killed, [dict get $counts SURVIVED] survived, [dict get $counts NOT-APPLIED] not applied, [dict get $counts NOT-BUILT] not built"
exit [expr {[dict get $counts KILLED] == [llength $results] ? 0 : 1}]
