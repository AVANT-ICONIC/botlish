# perturb.tcl -- non-vacuity check of golden suites (LARGE-SCALE-GOLDEN-MIGRATION.md,
# "Non-vacuity"): every registered test must report FAIL when
# its verdict or its expectation is deliberately wrong.
#
#   tclsh9.0 audit/golden/tools/perturb.tcl ?-mode invert|alter|both?
#       ?-backends LIST? ?-timeout SECONDS? FILE.bot ...
#
# Two independent perturbations, each one compilation of each suite:
#
#   invert  the suite runs against a private copy of lib/ whose test.bot
#           builds every verdict inverted: `test::passed()` is a mismatch and
#           `test::mismatch(...)` a match. Every helper and every custom check
#           that reaches its verdict through those constructors (directly or
#           through test::equal / satisfies / diagnostic) then reports the
#           opposite. A test that still PASSES decided its verdict without the
#           library's constructors -- a custom check that builds a test::Match
#           itself, or none at all: a test that cannot fail through its
#           matcher. Every test must FAIL.
#   alter   the suite's text is copied and each registration's expectation is
#           altered: test::value's expected value (its first Int literal + 1,
#           else its first String literal + "~", else true/false swapped, else
#           its first enum case qualified Name::Case swapped with another case
#           written in the suite -- or not alterable), test::rejects' and
#           test::rejects_at's, test::rejects_message's and
#           test::rejects_containing's code (Type <-> Unbound, any other ->
#           Type), and test::rejects_at's column + 1. Every altered test must FAIL: the
#           comparison is sensitive to the expectation it was written with.
#           test::holds, test::rejects_any, test::case and suite-local
#           registration helpers have no textual expectation to alter here;
#           invert covers them.
#
# The real checkout is never modified: the private library and suite copies
# live in a `file tempdir` directory. The suite copy keeps its file name and
# line numbers (alterations never add or remove lines), so located
# expectations are still the suite's own. The default backend is interp: the
# perturbations test the suite's expectations, not a backend.
#
# Prints, per suite and mode: how many tests reported, how many failed as
# required, the names of the ones that passed (VACUOUS) and, for alter, the
# registrations it could not alter. Exit status 1 when a perturbed test passed
# or a perturbed suite did not compile or aborted.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $here tree.tcl]

set options [dict create -mode both -backends interp -timeout 3600]
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
if {$files eq {}} {
    set files [lsort [glob -directory [file join $root tests golden] *.bot]]
}

# ---------------------------------------------------------------------------
# Scanning Botlish source text: the end of a String or character literal, and
# the arguments of a call.

# The index just past the literal that starts with the quote at START of TEXT.
proc literalEnd {text start} {
    set quote [string index $text $start]
    set i [expr {$start + 1}]
    set n [string length $text]
    while {$i < $n} {
        set c [string index $text $i]
        if {$c eq "\\"} {
            incr i 2
            continue
        }
        if {$c eq $quote} {
            return [expr {$i + 1}]
        }
        incr i
    }
    return $n
}

# The top-level arguments of the call whose opening parenthesis is at OPEN in
# TEXT: {END {START STOP} ...}, END the index of the closing parenthesis,
# each argument's text range (inclusive), or "" when the call is unbalanced.
proc callArguments {text open} {
    set depth 0
    set n [string length $text]
    set ranges {}
    set argStart [expr {$open + 1}]
    for {set i $open} {$i < $n} {incr i} {
        set c [string index $text $i]
        switch -- $c {
            "\"" - "'" {
                set i [expr {[literalEnd $text $i] - 1}]
            }
            "#" {
                set eol [string first \n $text $i]
                set i [expr {$eol < 0 ? $n : $eol - 1}]
            }
            "(" - "\[" - "\{" {
                incr depth
            }
            ")" - "\]" - "\}" {
                incr depth -1
                if {$depth == 0} {
                    lappend ranges [list $argStart [expr {$i - 1}]]
                    return [list $i $ranges]
                }
            }
            "," {
                if {$depth == 1} {
                    lappend ranges [list $argStart [expr {$i - 1}]]
                    set argStart [expr {$i + 1}]
                }
            }
        }
    }
    return ""
}

# The enum cases written in TEXT, qualified (Name::Case or ns::Name::Case):
# a dict Name -> cases.
proc enumCases {text} {
    set cases [dict create]
    foreach {- qualifier case} [regexp -all -inline {\m((?:[a-z_][A-Za-z0-9_]*::)?[A-Z][A-Za-z0-9_]*)::([A-Z][A-Za-z0-9_]*)\M} $text] {
        if {$qualifier eq "compiler::DiagnosticCode"} continue
        if {![dict exists $cases $qualifier] || $case ni [dict get $cases $qualifier]} {
            dict lappend cases $qualifier $case
        }
    }
    return $cases
}

# EXPR (the text of an expected value) altered so that it no longer equals
# what it denotes, or "" when this tool cannot alter it.
proc alterExpected {expr enums} {
    # Scan outside String literals for the first Int literal.
    set n [string length $expr]
    set firstString -1
    for {set i 0} {$i < $n} {incr i} {
        set c [string index $expr $i]
        if {$c eq "\"" || $c eq "'"} {
            if {$c eq "\"" && $firstString < 0} { set firstString $i }
            set i [expr {[literalEnd $expr $i] - 1}]
            continue
        }
        if {[string is digit $c] && ($i == 0 || ![regexp {[A-Za-z0-9_]} [string index $expr [expr {$i - 1}]]])} {
            regexp -start $i {\d+} $expr digits
            set stop [expr {$i + [string length $digits] - 1}]
            return [string replace $expr $i $stop [expr {$digits + 1}]]
        }
    }
    if {$firstString >= 0} {
        set stop [expr {[literalEnd $expr $firstString] - 1}]
        return [string replace $expr $stop $stop "~\""]
    }
    if {[regexp -indices {\mtrue\M} $expr range]} {
        return [string replace $expr {*}$range false]
    }
    if {[regexp -indices {\mfalse\M} $expr range]} {
        return [string replace $expr {*}$range true]
    }
    if {[regexp -indices {\m((?:[a-z_][A-Za-z0-9_]*::)?[A-Z][A-Za-z0-9_]*)::([A-Z][A-Za-z0-9_]*)\M} $expr all qualifierRange caseRange]} {
        set qualifier [string range $expr {*}$qualifierRange]
        set case [string range $expr {*}$caseRange]
        if {[dict exists $enums $qualifier]} {
            foreach other [dict get $enums $qualifier] {
                if {$other ne $case} {
                    return [string replace $expr {*}$caseRange $other]
                }
            }
        }
    }
    return ""
}

proc alterCode {expr} {
    if {![regexp {^\s*compiler::DiagnosticCode::([A-Za-z]+)\s*$} $expr -> code]} {
        return ""
    }
    set other [expr {$code eq "Type" ? "Unbound" : "Type"}]
    return [string map [list "DiagnosticCode::$code" "DiagnosticCode::$other"] $expr]
}

# TEXT with every alterable registration's expectation altered: {TEXT ALTERED
# SKIPPED}, ALTERED the altered tests' names, SKIPPED {NAME REASON} pairs.
proc alterSuite {text} {
    set enums [enumCases $text]
    set edits {}
    set altered {}
    set skipped {}
    foreach {match -} [regexp -all -inline -indices {\mtest::(value|holds|rejects|rejects_at|rejects_any|rejects_message|rejects_containing|case)\(} $text] {
        lassign $match start stop
        set helper [string range $text [expr {$start + 6}] [expr {$stop - 1}]]
        set call [callArguments $text $stop]
        if {$call eq ""} continue
        lassign $call - ranges
        set nameText [string trim [string range $text {*}[lindex $ranges 0]]]
        if {![regexp {^"(.*)"$} $nameText -> name]} {
            set name "(computed name $nameText)"
        }
        switch -- $helper {
            value {
                set range [lindex $ranges 1]
                set new [alterExpected [string range $text {*}$range] $enums]
                if {$new eq ""} {
                    lappend skipped $name "expected value has no Int, String, Bool or known enum case to alter"
                    continue
                }
                lappend edits [list {*}$range $new]
                lappend altered $name
            }
            rejects - rejects_at - rejects_message - rejects_containing {
                set range [lindex $ranges 1]
                set new [alterCode [string range $text {*}$range]]
                if {$new eq ""} {
                    lappend skipped $name "code is not a literal compiler::DiagnosticCode case"
                    continue
                }
                lappend edits [list {*}$range $new]
                if {$helper eq "rejects_at"} {
                    set columnRange [lindex $ranges 3]
                    set column [string trim [string range $text {*}$columnRange]]
                    if {[string is integer -strict $column]} {
                        # The column moves too: the test must fail on its
                        # location alone as well (checked by a second run).
                        lappend ::columnEdits [list {*}$columnRange " [expr {$column + 1}]"]
                    }
                }
                lappend altered $name
            }
            default {
                lappend skipped $name "test::$helper has no textual expectation (invert covers it)"
            }
        }
    }
    # Apply from the end so earlier ranges stay valid.
    foreach edit [lsort -integer -decreasing -index 0 $edits] {
        lassign $edit from to new
        set text [string replace $text $from $to $new]
    }
    return [list $text $altered $skipped]
}

# TEXT with only the rejects_at columns moved (codes kept).
proc moveColumns {text} {
    set ::columnEdits {}
    alterSuite $text
    foreach edit [lsort -integer -decreasing -index 0 $::columnEdits] {
        lassign $edit from to new
        set text [string replace $text $from $to $new]
    }
    return $text
}

# ---------------------------------------------------------------------------
# Running a perturbed suite: {STATE VERDICTS} as goldentools::runSuites.

proc runPerturbed {libDir suitePath backends timeout} {
    lassign [goldentools::run $timeout tclsh9.0 [file join $::root tests golden run.tcl] \
        -backends [join $backends ,] -lib $libDir -names $suitePath] status output
    set verdicts [dict create]
    set state incomplete
    foreach line [split $output \n] {
        if {[regexp {^\S+ STATUS (\S+)$} $line -> s]} {
            set state $s
        } elseif {[regexp {^\S+ (PASS|FAIL) (.*)$} $line -> verdict name]} {
            dict set verdicts $name $verdict
        }
    }
    if {$state eq "incomplete" || $state eq "compile-error"} {
        return [list $state $verdicts [goldentools::lastLine $output]]
    }
    return [list $state $verdicts ""]
}

set work [file tempdir botlish-golden-perturb]
set exit 0
try {
    # The private library copies: the real one (for alter) and the inverted
    # one (for invert).
    set plainLib [file join $work lib]
    file copy [file join $root lib] $plainLib
    set invertedLib [file join $work lib-inverted]
    file copy [file join $root lib] $invertedLib
    set testBot [file join $invertedLib test.bot]
    set text [goldentools::readFile $testBot]
    set edits {
        "    Match {matched: true, expected: \"\", actual: \"\", detail: \"\"}"
        "    Match {matched: false, expected: \"verdict inverted\", actual: \"passed\", detail: \"\"}"
        "    Match {matched: false, expected: expected, actual: actual, detail: detail}"
        "    Match {matched: true, expected: \"\", actual: \"\", detail: \"\"}"
    }
    foreach {old new} $edits {
        set first [string first $old $text]
        if {$first < 0 || [string first $old $text [expr {$first + 1}]] >= 0} {
            error "perturb.tcl: lib/test.bot no longer has exactly one \"[string trim $old]\": update the invert edits"
        }
        set text [string map [list $old $new] $text]
    }
    goldentools::writeFile $testBot $text

    set backends [split [dict get $options -backends] ,]
    set timeout [dict get $options -timeout]
    set mode [dict get $options -mode]
    foreach path $files {
        set name [file tail $path]
        set source [goldentools::readFile $path]
        if {$mode in {invert both}} {
            set copyDir [file join $work invert-[file rootname $name]]
            file mkdir $copyDir
            set copy [file join $copyDir $name]
            goldentools::writeFile $copy $source
            lassign [runPerturbed $invertedLib $copy $backends $timeout] state verdicts problem
            set passing [lmap {n v} $verdicts {if {$v ne "PASS"} continue; set n}]
            puts [format "%-28s invert  %4d tests, %4d failed as required%s" $name [dict size $verdicts] \
                [expr {[dict size $verdicts] - [llength $passing]}] [expr {$state in {ok failed} ? "" : " (suite $state: $problem)"}]]
            foreach n $passing { puts "    VACUOUS (passes with inverted verdicts): $n" }
            if {$passing ne {} || $state ni {ok failed} || [dict size $verdicts] == 0} { set exit 1 }
        }
        if {$mode in {alter both}} {
            set ::columnEdits {}
            lassign [alterSuite $source] altered alteredNames skipped
            set copyDir [file join $work alter-[file rootname $name]]
            file mkdir $copyDir
            set copy [file join $copyDir $name]
            goldentools::writeFile $copy $altered
            lassign [runPerturbed $plainLib $copy $backends $timeout] state verdicts problem
            set passing [lmap n $alteredNames {
                if {![dict exists $verdicts $n] || [dict get $verdicts $n] ne "PASS"} continue
                set n
            }]
            set missing [lmap n $alteredNames {expr {[dict exists $verdicts $n] ? [continue] : $n}}]
            puts [format "%-28s alter   %4d altered, %4d failed as required, %4d not alterable%s" $name \
                [llength $alteredNames] [expr {[llength $alteredNames] - [llength $passing] - [llength $missing]}] \
                [expr {[llength $skipped] / 2}] [expr {$state in {ok failed} ? "" : " (suite $state: $problem)"}]]
            foreach n $passing { puts "    VACUOUS (passes with its expectation altered): $n" }
            foreach n $missing { puts "    NOT REPORTED under alteration: $n" }
            foreach {n reason} $skipped {
                if {[string match "test::*" $reason]} continue
                puts "    not altered: $n -- $reason"
            }
            if {$passing ne {} || $missing ne {} || $state ni {ok failed}} { set exit 1 }
            # rejects_at: the location alone must matter too.
            if {[regexp {\mtest::rejects_at\(} $source]} {
                set moved [moveColumns $source]
                set copyDir [file join $work column-[file rootname $name]]
                file mkdir $copyDir
                set copy [file join $copyDir $name]
                goldentools::writeFile $copy $moved
                lassign [runPerturbed $plainLib $copy $backends $timeout] state verdicts problem
                set located {}
                foreach match [regexp -all -inline -indices {\mtest::rejects_at\(} $source] {
                    set call [callArguments $source [lindex $match 1]]
                    if {$call eq ""} continue
                    if {[regexp {^\s*"(.*)"\s*$} [string range $source {*}[lindex [lindex $call 1] 0]] -> n]} {
                        lappend located $n
                    }
                }
                set passing [lmap n $located {
                    if {![dict exists $verdicts $n] || [dict get $verdicts $n] ne "PASS"} continue
                    set n
                }]
                puts [format "%-28s column  %4d located, %4d failed as required%s" $name [llength $located] \
                    [expr {[llength $located] - [llength $passing]}] [expr {$state in {ok failed} ? "" : " (suite $state: $problem)"}]]
                foreach n $passing { puts "    VACUOUS (passes with its column moved): $n" }
                if {$passing ne {} || $state ni {ok failed}} { set exit 1 }
            }
        }
        flush stdout
    }
} finally {
    file delete -force $work
}
exit $exit
