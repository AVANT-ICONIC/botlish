# check.tcl -- the migration check of the golden test framework
# (GOLDEN-TEST-FRAMEWORK.md, "Side-by-side agreement" and "Mutation
# spot-check"): every Tcl test tests/golden/manifest.tsv lists as ported is
# run beside the golden test it became, and their verdicts compared.
#
#   tclsh9.0 audit/golden/tools/check.tcl ?-mutants SPECS? ?-only-mutated 0|1?
#                                          ?-backends LIST? ?-timeout SECONDS?
#
# Without -mutants: on this checkout, as it is, each manifest row's old test
# (tcltest -match, a private -tmpdir, one tclsh per test file) and new test
# (tests/golden/run.tcl on every backend of -backends): the expected outcome
# is "old passes, new passes" for every row, and the report lists any other
# pair -- with the wall time of the old tests (per file, startup included)
# and of the golden suites (compile and run), the economics of the slice.
#
# With -mutants SPECS (a list of MUTANTSFILE:NAME, e.g.
# audit/static-compile/tools/mutants.txt:wrong-code): for each mutant, a
# private copy of the checkout (tree.tcl) gets the mutant's edits, and both
# representations run there. The rows the comparison is about are the rows
# whose `mutants` column names the mutant (or, if none does, every row).
# Old detects the mutant when one of those rows' old tests fails (or its
# file does not complete); new detects it when one of those rows' golden
# tests fails on some backend (BOTH), and at suite level when only another
# golden test fails or a suite does not compile, aborts on a backend or
# disagrees across backends (BOTH-SUITE-LEVEL). A mutant the old tests
# detect and the new ones do not is a weaker port: the report says so. -only-mutated 0 also runs every other row
# of the manifest under the mutant (every ported test as a detector).
#
# The checkout is never modified. Exit status 1 when a row disagrees on the
# unmutated tree, or a mutant is detected by the old tests only.

source [file join [file dirname [file normalize [info script]]] tree.tcl]
set root $::goldentools::root

set options [dict create -mutants {} -only-mutated 1 -backends {interp compile cranelift-generic cranelift} -timeout 3600]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set timeout [dict get $options -timeout]
set backends [dict get $options -backends]

# The manifest's ported rows: a list of dicts (the header's columns).
proc manifestRows {root} {
    set lines [split [string trimright [goldentools::readFile [file join $root tests golden manifest.tsv]] \n] \n]
    set header [split [lindex $lines 0] \t]
    set rows {}
    foreach line [lrange $lines 1 end] {
        set row [dict create]
        foreach column $header value [split $line \t] {
            dict set row $column $value
        }
        if {[dict get $row new_test] eq "-"} continue
        lappend rows $row
    }
    return $rows
}

# The old tests of ROWS: a dict test file -> names.
proc oldTestsOf {rows} {
    set byFile [dict create]
    foreach row $rows {
        set file [dict get $row old_file]
        if {![string match tests/* $file]} { set file tests/$file }
        if {[dict exists $byFile $file] && [dict get $row old_test] in [dict get $byFile $file]} continue
        dict lappend byFile $file [dict get $row old_test]
    }
    return $byFile
}

# Runs the old tests (dict file -> names) in TREE: a dict "file test" ->
# pass|fail|not-run (a name tcltest reported neither passing nor failing:
# misspelled, or skipped by a constraint), and the wall seconds of each
# file's run.
proc runOld {tree byFile timeout} {
    set verdicts [dict create]
    set seconds [dict create]
    dict for {file names} $byFile {
        # tcltest -match takes glob patterns: escape the glob characters
        # some test names contain.
        set patterns [lmap n $names {string map {* \\* ? \\? [ \\[ ] \\]} $n}]
        set start [clock milliseconds]
        lassign [goldentools::runTestFile $tree $file $timeout $patterns] failed passed incomplete passedNames
        dict set seconds $file [expr {([clock milliseconds] - $start) / 1000.0}]
        foreach n $names {
            dict set verdicts "$file $n" [expr {$incomplete ne "" || $n in $failed ? "fail"
                : $n in $passedNames ? "pass" : "not-run"}]
        }
    }
    return [list $verdicts $seconds]
}

# Runs the golden suites of ROWS in TREE: a dict "suite test" -> pass|fail,
# a dict suite -> state, and the wall seconds of each suite.
proc runNew {tree rows timeout backends} {
    set suites [lsort -unique [lmap row $rows {string cat tests/golden/ [dict get $row suite]}]]
    set verdicts [dict create]
    set states [dict create]
    set seconds [dict create]
    foreach suite $suites {
        set start [clock milliseconds]
        set outcome [dict get [goldentools::runSuites $tree [list $suite] $timeout $backends] $suite]
        dict set seconds [file tail $suite] [expr {([clock milliseconds] - $start) / 1000.0}]
        lassign $outcome state names
        dict set states [file tail $suite] $state
        dict for {name verdict} $names {
            dict set verdicts "[file tail $suite] $name" [expr {$verdict eq "PASS" ? "pass" : "fail"}]
        }
    }
    # A test with no verdict (its suite did not compile, or aborted on every
    # backend) is no-verdict: not a pass, and under a mutant a suite-level
    # detection, not a failure of that test. A test of a suite that aborted
    # on some backend or whose backends disagree keeps its own verdict; the
    # suite's state is reported beside it.
    foreach row $rows {
        set key "[dict get $row suite] [dict get $row new_test]"
        if {![dict exists $verdicts $key]} {
            dict set verdicts $key no-verdict
        }
    }
    return [list $verdicts $states $seconds]
}

proc oldKey {row} {
    set file [dict get $row old_file]
    if {![string match tests/* $file]} { set file tests/$file }
    return "$file [dict get $row old_test]"
}
proc newKey {row} { return "[dict get $row suite] [dict get $row new_test]" }

set rows [manifestRows $root]
set exit 0

if {[dict get $options -mutants] eq {}} {
    puts "# Side-by-side agreement on this checkout\n"
    puts "[llength $rows] ported rows, [dict size [oldTestsOf $rows]] old test files, [llength [lsort -unique [lmap r $rows {dict get $r suite}]]] golden suites\n"
    lassign [runOld $root [oldTestsOf $rows] $timeout] old oldSeconds
    lassign [runNew $root $rows $timeout $backends] new states newSeconds
    set pairs [dict create]
    foreach row $rows {
        set pair "old [dict get $old [oldKey $row]], new [dict get $new [newKey $row]]"
        dict incr pairs $pair
        if {$pair ne "old pass, new pass"} {
            puts "DISAGREE: [oldKey $row] -> [newKey $row]: $pair"
            set exit 1
        }
    }
    dict for {pair count} $pairs { puts "$pair: $count" }
    dict for {suite state} $states {
        if {$state ne "ok"} {
            puts "SUITE NOT OK: $suite $state"
            set exit 1
        }
    }
    puts "\nOld tests, wall seconds per file (one tclsh each, startup included):"
    set total 0
    dict for {file s} $oldSeconds { puts [format "    %-44s %7.1f" $file $s]; set total [expr {$total + $s}] }
    puts [format "    %-44s %7.1f" total $total]
    puts "Golden suites, wall seconds per suite (compile once, run on [join $backends {, }]):"
    set total 0
    dict for {suite s} $newSeconds { puts [format "    %-44s %7.1f   %s" $suite $s [dict get $states $suite]]; set total [expr {$total + $s}] }
    puts [format "    %-44s %7.1f" total $total]
    exit $exit
}

puts "# Mutation spot-check\n"
set results {}
foreach spec [dict get $options -mutants] {
    lassign [split $spec :] file name
    lassign [goldentools::mutant [file join $root $file] $name] description edits
    # The rows whose mutants column names the mutant (as a word: the column
    # is free text, "audit/X/tools/mutants.txt NAME, NAME2, ...").
    set related [lmap row $rows {
        if {![regexp "(^|\[\\s,;:/\])[string map {- \\-} $name](\$|\[\\s,;\])" [dict get $row mutants]]} continue
        set row
    }]
    set scope [expr {$related eq {} ? "every row" : "[llength $related] rows"}]
    set checked [expr {$related eq {} || ![dict get $options -only-mutated] ? $rows : $related}]
    set native [goldentools::isNative $edits]
    set tree [goldentools::makeTree $native]
    try {
        lassign [goldentools::apply $tree $edits] applied touched
        if {!$applied} {
            puts "NOT-APPLIED $spec"
            lappend results [list $spec NOT-APPLIED]
            continue
        }
        if {$native} {
            set problem [goldentools::build $tree $timeout]
            if {$problem ne ""} {
                puts "NOT-BUILT $spec: $problem"
                lappend results [list $spec NOT-BUILT]
                continue
            }
        }
        lassign [runOld $tree [oldTestsOf $checked] $timeout] old -
        # The new side runs every suite: a mutant may kill a golden test
        # outside the related rows, or a whole suite (it does not compile,
        # aborts, or the backends disagree) -- a detection without
        # per-test attribution.
        lassign [runNew $tree $rows $timeout $backends] new states -
        set oldFailed [lmap row $checked {if {[dict get $old [oldKey $row]] ne "fail"} continue; oldKey $row}]
        set oldNotRun [lmap row $checked {if {[dict get $old [oldKey $row]] ne "not-run"} continue; oldKey $row}]
        if {$oldNotRun ne {}} {
            puts "    old tests that did not run: [join [lsort -unique $oldNotRun] {, }]"
        }
        set newFailed [lmap row $checked {if {[dict get $new [newKey $row]] ne "fail"} continue; newKey $row}]
        set otherFailed [lmap row $rows {if {$row in $checked || [dict get $new [newKey $row]] ne "fail"} continue; newKey $row}]
        set broken [lmap {suite state} $states {if {$state in {ok failed}} continue; string cat $suite = $state}]
        set oldDetects [expr {[llength $oldFailed] > 0}]
        set newDetects [expr {[llength $newFailed] > 0}]
        set newAnywhere [expr {$newDetects || [llength $otherFailed] > 0 || [llength $broken] > 0}]
        set verdict [expr {$oldDetects && $newDetects ? "BOTH" : $oldDetects && $newAnywhere ? "BOTH-SUITE-LEVEL"
            : $oldDetects ? "OLD-ONLY" : $newAnywhere ? "NEW-ONLY" : "NEITHER"}]
        if {$verdict eq "OLD-ONLY"} { set exit 1 }
        puts "$verdict $spec ($scope) -- $description"
        puts "    old failed: [llength $oldFailed] ([join [lrange [lsort -unique $oldFailed] 0 5] {, }])"
        puts "    new failed (related): [llength $newFailed] ([join [lrange [lsort -unique $newFailed] 0 5] {, }])"
        puts "    new failed (other rows): [llength $otherFailed] ([join [lrange [lsort -unique $otherFailed] 0 3] {, }]); suites not ok: [join $broken {, }]"
        flush stdout
        lappend results [list $spec $verdict]
    } finally {
        file delete -force $tree
    }
}
set counts [dict create]
foreach r $results { dict incr counts [lindex $r 1] }
puts "\n[llength $results] mutants: [join [lmap {k v} $counts {string cat $k " " $v}] {, }]"
exit $exit
