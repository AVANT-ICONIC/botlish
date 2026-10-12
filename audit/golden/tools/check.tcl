# check.tcl -- the side-by-side check of the golden suites against the Tcl
# tests they were ported from (GOLDEN-TEST-FRAMEWORK.md, "Side-by-side
# agreement" and "Mutation spot-check"; LARGE-SCALE-GOLDEN-MIGRATION.md, "The
# differential tool"): every Tcl test tests/golden/manifest.tsv lists as
# ported is run beside the golden test(s) it became, and their verdicts are
# compared.
#
#   tclsh9.0 audit/golden/tools/check.tcl ?-full 0|1? ?-jobs N?
#       ?-subsystem NAME,...? ?-suites FILE.bot,...? ?-files FILE.test,...?
#       ?-shard I/N? ?-backends LIST? ?-timeout SECONDS? ?-names-out PATH?
#       ?-mutants SPECS? ?-only-mutated 0|1? ?-all-suites 0|1?
#
# Without -mutants: on this checkout, as it is. Old side: each Tcl test file
# holding a ported row runs once (tcltest -match with the ported names, a
# private -tmpdir, -verbose ps), at most -jobs files at a time. A test counts as
# run only when tcltest names it ("++++ NAME PASSED", "==== NAME FAILED",
# "++++ NAME SKIPPED"): absence of failure output is never a pass. New side:
# each golden suite holding a ported row (or the -suites given) compiles once
# and runs on every backend of -backends (tests/golden/run.tcl -names), at most
# -jobs suites at a time. Every ported row must be "old pass, new pass"; the
# report lists every other pair, and every suite whose state is not ok
# (compile-error, aborted, disagree) or that reports a test the manifest does
# not list, or does not report one it lists.
#
# With -full 1 the old side runs EVERY tests/*.test file entirely, so the
# check also proves the manifest complete: a Tcl test that ran (passed, failed
# or was skipped) but has no manifest row is MISSING; a manifest row whose Tcl
# test did not run at all is STALE. A Tcl test that fails is reported whatever
# its row. -names-out PATH writes every discovered "FILE NAME VERDICT".
#
# -subsystem / -files restrict the rows (by the manifest's subsystem column or
# old_file); -suites restricts the golden suites (and the rows to theirs);
# -shard I/N keeps the I-th of N slices of the golden suites (every N-th suite
# file in name order, from 1) and their rows -- CI runs the slices as parallel
# jobs.
#
# With -mutants SPECS (a list of MUTANTSFILE:NAME): for each mutant, a private
# copy of the checkout (tree.tcl) gets the mutant's edits and both sides run
# there. The rows the comparison is about are the rows whose `mutants` column
# names the mutant (or, if none does, every selected row). Old detects the
# mutant when one of those rows' old tests fails (or its file does not
# complete); new detects it when one of those rows' golden tests fails on some
# backend (BOTH), and at suite level when only another golden test fails or a
# suite does not compile, aborts or disagrees (BOTH-SUITE-LEVEL). The new side
# runs the suites of the related rows (-all-suites 1: every suite). OLD-ONLY,
# a mutant the old tests detect and the new ones do not, is a weaker port: the
# report says so. -only-mutated 0 also runs every other selected row's old test.
#
# The checkout is never modified. Exit status 1 when a ported row disagrees,
# a suite is not ok, the manifest is incomplete or stale (-full), or a mutant
# is OLD-ONLY.

source [file join [file dirname [file normalize [info script]]] tree.tcl]
set root $::goldentools::root

set options [dict create -mutants {} -only-mutated 1 -all-suites 0 -backends {interp compile cranelift-generic cranelift} \
    -timeout 3600 -jobs 3 -full 0 -subsystem {} -suites {} -files {} -shard {} -names-out {}]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set timeout [dict get $options -timeout]
set backends [split [string map {" " ,} [dict get $options -backends]] ,]
set backends [lsearch -all -inline -not -exact $backends ""]
set jobs [dict get $options -jobs]

proc normalizeFile {file} {
    if {![string match tests/* $file]} { set file tests/$file }
    return $file
}

# Every manifest row: a list of dicts (the header's columns).
proc manifestRows {root} {
    set lines [split [string trimright [goldentools::readFile [file join $root tests golden manifest.tsv]] \n] \n]
    set header [split [lindex $lines 0] \t]
    set rows {}
    foreach line [lrange $lines 1 end] {
        set row [dict create]
        foreach column $header value [split $line \t] {
            dict set row $column $value
        }
        dict set row old_file [normalizeFile [dict get $row old_file]]
        lappend rows $row
    }
    return $rows
}

# The old tests of ROWS: a dict test file -> names.
proc oldTestsOf {rows} {
    set byFile [dict create]
    foreach row $rows {
        set file [dict get $row old_file]
        if {[dict exists $byFile $file] && [dict get $row old_test] in [dict get $byFile $file]} continue
        dict lappend byFile $file [dict get $row old_test]
    }
    return $byFile
}

# Runs the old tests (dict file -> names; names "" for the whole file) in
# TREE, JOBS files at a time: {VERDICTS SECONDS DISCOVERED INCOMPLETE},
# VERDICTS a dict "file test" -> pass|fail|skip|not-run, SECONDS a dict file ->
# wall seconds, DISCOVERED a dict "file test" -> verdict of every test the
# runs named, INCOMPLETE a dict file -> why it did not complete.
proc runOld {tree byFile timeout jobs} {
    set commands [dict create]
    set tmps {}
    dict for {file names} $byFile {
        set tmp [file tempdir botlish-golden-run]
        lappend tmps $tmp
        set command [list tclsh9.0 [file join $tree $file] -tmpdir $tmp -verbose ps]
        if {$names ne ""} {
            # tcltest -match takes glob patterns: escape the glob characters
            # some test names contain.
            lappend command -match [lmap n $names {string map {* \\* ? \\? [ \\[ ] \\]} $n}]
        }
        dict set commands $file $command
    }
    try {
        set outcomes [goldentools::runParallel $jobs $timeout $commands]
    } finally {
        foreach tmp $tmps { file delete -force $tmp }
    }
    set verdicts [dict create]
    set seconds [dict create]
    set discovered [dict create]
    set incompleteFiles [dict create]
    dict for {file names} $byFile {
        lassign [dict get $outcomes $file] status output wall
        dict set seconds $file $wall
        lassign [goldentools::testVerdicts $output] failed passed skipped incomplete
        if {$incomplete ne ""} { dict set incompleteFiles $file $incomplete }
        foreach n $passed { dict set discovered "$file $n" pass }
        foreach n $skipped { dict set discovered "$file $n" skip }
        foreach n $failed { dict set discovered "$file $n" fail }
        foreach n $names {
            dict set verdicts "$file $n" [expr {$n in $failed || ($incomplete ne "" && $n ni $passed) ? "fail"
                : $n in $passed ? "pass" : $n in $skipped ? "skip" : "not-run"}]
        }
    }
    return [list $verdicts $seconds $discovered $incompleteFiles]
}

# Runs the golden SUITES (file names in tests/golden) in TREE, JOBS at a
# time: {VERDICTS STATES SECONDS REPORTED}, VERDICTS a dict "suite test" ->
# pass|fail, STATES a dict suite -> state, SECONDS a dict suite -> wall
# seconds, REPORTED a dict suite -> the names it reported.
proc runNew {tree suites timeout backends jobs} {
    set commands [dict create]
    foreach suite $suites {
        dict set commands $suite [list tclsh9.0 [file join $tree tests golden run.tcl] \
            -backends [join $backends ,] -names [file join $tree tests golden $suite]]
    }
    set outcomes [goldentools::runParallel $jobs $timeout $commands]
    set verdicts [dict create]
    set states [dict create]
    set seconds [dict create]
    set reported [dict create]
    foreach suite $suites {
        lassign [dict get $outcomes $suite] status output wall
        dict set seconds $suite $wall
        lassign [goldentools::suiteVerdicts $output] state names
        dict set states $suite $state
        dict set reported $suite [dict keys $names]
        dict for {name verdict} $names {
            dict set verdicts "$suite $name" [expr {$verdict eq "PASS" ? "pass" : "fail"}]
        }
    }
    return [list $verdicts $states $seconds $reported]
}

proc oldKey {row} { return "[dict get $row old_file] [dict get $row old_test]" }
proc newKey {row} { return "[dict get $row suite] [dict get $row new_test]" }
proc isPorted {row} { return [expr {[dict get $row new_test] ne "-" && [dict get $row suite] ne "-"}] }

# A golden test with no verdict (its suite did not compile, or aborted on
# every backend, or did not report it) is no-verdict: not a pass.
proc newVerdict {new row} {
    set key [newKey $row]
    return [expr {[dict exists $new $key] ? [dict get $new $key] : "no-verdict"}]
}

set allRows [manifestRows $root]
set rows $allRows
if {[dict get $options -subsystem] ne {}} {
    set wanted [split [dict get $options -subsystem] ,]
    set rows [lmap row $rows {expr {[dict exists $row subsystem] && [dict get $row subsystem] in $wanted ? $row : [continue]}}]
}
if {[dict get $options -files] ne {}} {
    set wanted [lmap f [split [dict get $options -files] ,] {normalizeFile $f}]
    set rows [lmap row $rows {expr {[dict get $row old_file] in $wanted ? $row : [continue]}}]
}
if {[dict get $options -suites] ne {}} {
    set wanted [split [dict get $options -suites] ,]
    set rows [lmap row $rows {expr {[dict get $row suite] in $wanted ? $row : [continue]}}]
}
if {[dict get $options -shard] ne {}} {
    if {![regexp {^(\d+)/(\d+)$} [dict get $options -shard] -> shardIndex shardCount]
            || $shardIndex < 1 || $shardIndex > $shardCount} {
        error "-shard wants I/N with 1 <= I <= N"
    }
    set allSuites [lmap p [lsort [glob -directory [file join $root tests golden] *.bot]] {file tail $p}]
    set wanted {}
    foreach suite $allSuites k [lsearch -all $allSuites *] {
        if {$k % $shardCount == $shardIndex - 1} { lappend wanted $suite }
    }
    dict set options -suites [join $wanted ,]
    set rows [lmap row $rows {expr {[dict get $row suite] in $wanted ? $row : [continue]}}]
}
set ported [lmap row $rows {expr {[isPorted $row] ? $row : [continue]}}]
set suites [expr {[dict get $options -suites] ne {} ? [split [dict get $options -suites] ,]
    : [lsort -unique [lmap row $ported {dict get $row suite}]]}]
set exit 0

if {[dict get $options -mutants] eq {}} {
    puts "# Side-by-side agreement on this checkout\n"
    set byFile [oldTestsOf $ported]
    if {[dict get $options -full]} {
        set byFile [dict create]
        foreach path [lsort [glob -directory [file join $root tests] *.test]] {
            dict set byFile tests/[file tail $path] {}
        }
    }
    puts "[llength $ported] ported rows of [llength $rows] selected, [dict size $byFile] old test files, [llength $suites] golden suites, backends [join $backends {, }], $jobs jobs\n"
    set start [clock milliseconds]
    lassign [runOld $root $byFile $timeout $jobs] old oldSeconds discovered incompleteFiles
    set oldWall [expr {([clock milliseconds] - $start) / 1000.0}]
    if {[dict get $options -full]} {
        # Whole files ran: the verdict of a ported row is its discovered one.
        foreach row $ported {
            set key [oldKey $row]
            dict set old $key [expr {[dict exists $discovered $key] ? [dict get $discovered $key] : "not-run"}]
        }
    }
    set start [clock milliseconds]
    lassign [runNew $root $suites $timeout $backends $jobs] new states newSeconds reported
    set newWall [expr {([clock milliseconds] - $start) / 1000.0}]
    set pairs [dict create]
    foreach row $ported {
        set pair "old [dict get $old [oldKey $row]], new [newVerdict $new $row]"
        dict incr pairs $pair
        if {$pair ne "old pass, new pass"} {
            puts "DISAGREE: [oldKey $row] -> [newKey $row]: $pair"
            set exit 1
        }
    }
    dict for {pair count} $pairs { puts "$pair: $count" }
    dict for {file why} $incompleteFiles {
        puts "OLD FILE INCOMPLETE: $file: $why"
        set exit 1
    }
    dict for {suite state} $states {
        if {$state ne "ok"} {
            puts "SUITE NOT OK: $suite $state"
            set exit 1
        }
    }
    # The suites' reports against the manifest (all of its rows for those
    # suites, whatever the selection): a test reported and not listed, or
    # listed and not reported.
    foreach suite $suites {
        if {[dict get $states $suite] in {compile-error incomplete}} continue
        set listed [lmap row $allRows {expr {[isPorted $row] && [dict get $row suite] eq $suite ? [dict get $row new_test] : [continue]}}]
        foreach n [dict get $reported $suite] {
            if {$n ni $listed} { puts "UNLISTED GOLDEN TEST: $suite $n"; set exit 1 }
        }
        foreach n [lsort -unique $listed] {
            if {$n ni [dict get $reported $suite]} { puts "UNREPORTED GOLDEN TEST: $suite $n"; set exit 1 }
        }
    }
    if {[dict get $options -full]} {
        set rowKeys [dict create]
        foreach row $allRows { dict set rowKeys [oldKey $row] 1 }
        set missing [lmap key [dict keys $discovered] {expr {[dict exists $rowKeys $key] ? [continue] : $key}}]
        set stale [lmap key [lsort -unique [lmap row $rows {oldKey $row}]] {expr {[dict exists $discovered $key] ? [continue] : $key}}]
        set failing [lmap {key verdict} $discovered {expr {$verdict eq "fail" ? $key : [continue]}}]
        puts "\n[dict size $discovered] Tcl tests ran ([llength [lmap {k v} $discovered {expr {$v eq "pass" ? $k : [continue]}}]] passed, [llength $failing] failed, [llength [lmap {k v} $discovered {expr {$v eq "skip" ? $k : [continue]}}]] skipped)"
        foreach key [lsort $missing] { puts "MISSING MANIFEST ROW: $key" }
        foreach key [lsort $stale] { puts "STALE MANIFEST ROW (the Tcl test did not run): $key" }
        foreach key [lsort $failing] { puts "TCL TEST FAILED: $key" }
        puts "[llength $missing] missing, [llength $stale] stale, [llength $failing] failing"
        if {$missing ne {} || $stale ne {} || $failing ne {}} { set exit 1 }
        if {[dict get $options -names-out] ne ""} {
            set f [open [dict get $options -names-out] w]
            fconfigure $f -encoding utf-8
            foreach key [lsort [dict keys $discovered]] { puts $f "$key [dict get $discovered $key]" }
            close $f
        }
    }
    puts "\nOld tests, wall seconds per file (one tclsh each, startup included):"
    set total 0
    dict for {file s} $oldSeconds { puts [format "    %-48s %7.1f" $file $s]; set total [expr {$total + $s}] }
    puts [format "    %-48s %7.1f (elapsed %.1f with %d jobs)" "total" $total $oldWall $jobs]
    puts "Golden suites, wall seconds per suite (compile once, run on [join $backends {, }]):"
    set total 0
    dict for {suite s} $newSeconds { puts [format "    %-48s %7.1f   %s" $suite $s [dict get $states $suite]]; set total [expr {$total + $s}] }
    puts [format "    %-48s %7.1f (elapsed %.1f with %d jobs)" "total" $total $newWall $jobs]
    exit $exit
}

puts "# Mutation spot-check\n"
set results {}
foreach spec [dict get $options -mutants] {
    lassign [split $spec :] file name
    lassign [goldentools::mutant [file join $root $file] $name] description edits
    # The rows whose mutants column names the mutant (as a word: the column
    # is free text, "audit/X/tools/mutants.txt NAME, NAME2, ...").
    set related [lmap row $ported {
        if {![regexp "(^|\[\\s,;:/\])[string map {- \\-} $name](\$|\[\\s,;\])" [dict get $row mutants]]} continue
        set row
    }]
    set scope [expr {$related eq {} ? "every selected row" : "[llength $related] rows"}]
    set checked [expr {$related eq {} || ![dict get $options -only-mutated] ? $ported : $related}]
    set mutantSuites [expr {[dict get $options -all-suites]
        ? [lmap p [lsort [glob -directory [file join $root tests golden] *.bot]] {file tail $p}]
        : [lsort -unique [lmap row $checked {dict get $row suite}]]}]
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
        lassign [runOld $tree [oldTestsOf $checked] $timeout $jobs] old - - incompleteFiles
        lassign [runNew $tree $mutantSuites $timeout $backends $jobs] new states - -
        set oldFailed [lmap row $checked {if {[dict get $old [oldKey $row]] ne "fail"} continue; oldKey $row}]
        set oldNotRun [lmap row $checked {if {[dict get $old [oldKey $row]] ne "not-run"} continue; oldKey $row}]
        if {$oldNotRun ne {}} {
            puts "    old tests that did not run: [join [lsort -unique $oldNotRun] {, }]"
        }
        set newFailed [lmap row $checked {if {[newVerdict $new $row] ne "fail"} continue; newKey $row}]
        set otherFailed [lmap row $ported {if {$row in $checked || [newVerdict $new $row] ne "fail"} continue; newKey $row}]
        set broken [lmap {suite state} $states {if {$state in {ok failed}} continue; string cat $suite = $state}]
        set oldDetects [expr {[llength $oldFailed] > 0}]
        set newDetects [expr {[llength $newFailed] > 0}]
        set newAnywhere [expr {$newDetects || [llength $otherFailed] > 0 || [llength $broken] > 0}]
        set verdict [expr {$oldDetects && $newDetects ? "BOTH" : $oldDetects && $newAnywhere ? "BOTH-SUITE-LEVEL"
            : $oldDetects ? "OLD-ONLY" : $newAnywhere ? "NEW-ONLY" : "NEITHER"}]
        if {$verdict eq "OLD-ONLY"} { set exit 1 }
        puts "$verdict $spec ($scope; suites [join $mutantSuites {, }]) -- $description"
        puts "    old failed: [llength $oldFailed] ([join [lrange [lsort -unique $oldFailed] 0 5] {, }])"
        puts "    new failed (related): [llength $newFailed] ([join [lrange [lsort -unique $newFailed] 0 5] {, }])"
        puts "    new failed (other rows): [llength $otherFailed] ([join [lrange [lsort -unique $otherFailed] 0 3] {, }]); suites not ok: [join $broken {, }]"
        # The rows whose old test fails while their golden test does not:
        # a port weaker for this mutant (the mutant may still be detected by
        # the row's siblings), each to be explained in the manifest.
        set weaker [lmap row $checked {
            if {[dict get $old [oldKey $row]] ne "fail" || [newVerdict $new $row] eq "fail"} continue
            string cat [newKey $row] " (" [oldKey $row] ")"
        }]
        if {$weaker ne {}} {
            puts "    rows weaker for this mutant: [join [lrange $weaker 0 9] {; }][expr {[llength $weaker] > 10 ? "; ..." : ""}]"
        }
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
