# mutate.tcl -- mutation testing of the bounds prover: hir/completions.tcl's
# IndexBounds and its theorems (ReducedIndex: an index reduced mod the
# container's size or masked by the size minus one; RelationKey: a guard on
# a computed local), hir/cardinality.tcl's field-path size keys (ValueKey)
# and the length of a loop over a MutableVector (IterationLength), the rules
# beside them and native lowering's use of the verdict.
#
#   tclsh9.0 audit/bounds-proofs/tools/mutate.tcl ?-only NAME,...? ?-timeout SECONDS?
#       ?-seeds N? ?-count N?
#
# Each mutant is a deliberate bug written in mutants.txt (beside this
# script) as exact source replacements, each replaced text occurring exactly
# once. For each, a private copy of the compiler (a temporary directory;
# native/target is a symlink to this checkout's, and no mutant edits the
# native crate, so nothing rebuilds it) gets the replacements, and
# tests/proven-bounds.test and tests/stdlib-namespaces.test run against it
# (each with a private -tmpdir) -- first once on the unmutated copy, which
# must pass -- and the mutant is killed if a test fails or a file does not
# complete. A mutant the tests miss is given to the bounds
# fuzzer (audit/bounds-proofs/tools/fuzz.tcl, SEEDS seeds of COUNT sound
# programs each, and its unsound and conservative catalogue); one that
# survives both SURVIVES. The real checkout is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -timeout 1800 -seeds 2 -count 12]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# The mutants of mutants.txt (its header has the format), as
# {NAME DESCRIPTION {FILE OLD NEW ...} ...}.
proc readMutants {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation lf
    set lines [split [read $f] \n]
    close $f
    set mutants {}
    set name ""
    set state outside
    foreach line $lines {
        switch -- $state {
            outside {
                if {[regexp {^@@ (\S+) (.*)$} $line -> n d]} {
                    if {$name ne ""} { lappend mutants $name $description $edits }
                    set name $n
                    set description $d
                    set edits {}
                } elseif {[regexp {^## (\S+)$} $line -> file]} {
                    set current $file
                } elseif {$line eq "<<<<"} {
                    set state old
                    set old {}
                }
            }
            old {
                if {$line eq "===="} {
                    set state new
                    set new {}
                } else {
                    lappend old $line
                }
            }
            new {
                if {$line eq ">>>>"} {
                    lappend edits $current [join $old \n] [join $new \n]
                    set state outside
                } else {
                    lappend new $line
                }
            }
        }
    }
    if {$name ne ""} { lappend mutants $name $description $edits }
    return $mutants
}
set mutants [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]]

proc readFile {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation lf
    set text [read $f]
    close $f
    return $text
}

proc writeFile {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

# A private copy of the compiler sources, the tests, the fuzzer and what the
# tests read besides (bench/refined-checks.bot, the stdlib-namespaces
# fuzzer's smoke run): a test that cannot find its input would fail under
# every mutant and kill none.
set tree [file tempdir botlish-bounds-mutants]
foreach dir {compiler core hir surface lib tests bench audit/bounds-proofs audit/stdlib-namespaces} {
    file mkdir [file dirname [file join $tree $dir]]
    file copy [file join $root $dir] [file join $tree $dir]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] eq "target"} {
        file link -symbolic [file join $tree native target] $entry
    } else {
        file copy $entry [file join $tree native]
    }
}
foreach entry [glob -directory $root -types f *.tcl] {
    file copy $entry $tree
}

proc run {timeout args} {
    set status 0
    if {[catch {exec timeout $timeout {*}$args 2>@1} output options]} {
        set status [lindex [dict get $options -errorcode] end]
        if {![string is integer -strict $status]} { set status 1 }
        regsub {\n?child process exited abnormally$} $output "" output
    }
    return [list $status $output]
}

set killTests {proven-bounds.test stdlib-namespaces.test}

# The failed tests of the kill tests on the tree as it is: {FAILED COMPLETE}.
proc runKillTests {tree timeout} {
    set failed {}
    foreach testFile $::killTests {
        set tmp [file tempdir botlish-bounds-mutant-run]
        lassign [run $timeout tclsh9.0 [file join $tree tests $testFile] -tmpdir $tmp] status output
        file delete -force $tmp
        lappend failed {*}[lmap {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {set n}]
        if {![regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+\d+} $output]} {
            return [list $failed "$testFile: [string range [lindex [split [string trim $output] \n] end] 0 120]"]
        }
    }
    return [list [lsort -unique $failed] ""]
}

set only [split [dict get $options -only] ,]
set results {}
try {
    # The unmutated copy must pass: a test failing for want of an input in
    # the private tree would "kill" every mutant.
    lassign [runKillTests $tree [dict get $options -timeout]] failed incomplete
    if {$failed ne {} || $incomplete ne ""} {
        error "BASELINE FAILS on the unmutated copy: [join $failed {, }] $incomplete"
    }
    foreach {name description edits} $mutants {
        if {$only ne {} && $name ni $only} continue
        set touched [dict create]
        set applied 1
        foreach {file old new} $edits {
            set path [file join $tree $file]
            if {![dict exists $touched $file]} {
                dict set touched $file [readFile $path]
            }
            set text [readFile $path]
            set first [string first $old $text]
            if {$first < 0 || [string first $old $text [expr {$first + 1}]] >= 0} {
                set applied 0
                break
            }
            writeFile $path [string replace $text $first [expr {$first + [string length $old] - 1}] $new]
        }
        if {!$applied} {
            # The code the mutant edits changed: update mutants.txt.
            lappend results [list $name $description NOT-APPLIED ""]
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $file"
            dict for {file text} $touched {
                writeFile [file join $tree $file] $text
            }
            continue
        }
        set tests survived
        lassign [runKillTests $tree [dict get $options -timeout]] failed incomplete
        if {$incomplete ne ""} {
            set tests "killed (did not complete: $incomplete)"
        } elseif {$failed ne {}} {
            set tests "killed ([llength $failed] failed: [join [lrange $failed 0 5] {, }][expr {[llength $failed] > 6 ? ", ..." : ""}])"
        }
        if {![string match killed* $tests]} {
            # The fuzzer: generated sound programs on interp and cranelift,
            # and the unsound shapes with their witnesses.
            for {set seed 1} {$seed <= [dict get $options -seeds]} {incr seed} {
                lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree audit bounds-proofs tools fuzz.tcl] \
                    -seed $seed -count [dict get $options -count]] status output
                if {$status != 0} {
                    set first [lindex [regexp -all -inline -line {^FAIL .*$} $output] 0]
                    if {$first eq ""} { set first [lindex [split [string trim $output] \n] end] }
                    set tests "killed by the fuzzer (seed $seed: [string range $first 0 140])"
                    break
                }
            }
        }
        set verdict [expr {[string match killed* $tests] ? "KILLED" : "SURVIVED"}]
        lappend results [list $name $description $verdict $tests]
        puts "$verdict $name\n    tests: $tests"
        flush stdout
        dict for {file text} $touched {
            writeFile [file join $tree $file] $text
        }
    }
} finally {
    file delete -force $tree
}

set survivors [lmap r $results {if {[lindex $r 2] ne "SURVIVED"} continue; lindex $r 0}]
set unapplied [lmap r $results {if {[lindex $r 2] ne "NOT-APPLIED"} continue; lindex $r 0}]
set killed [llength [lsearch -all -index 2 $results KILLED]]
puts "[llength $results] mutants, $killed killed, [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}][expr {$unapplied eq {} ? "" : ", [llength $unapplied] not applied: [join $unapplied {, }]"}]"
exit [expr {$survivors ne {} || $unapplied ne {}}]
