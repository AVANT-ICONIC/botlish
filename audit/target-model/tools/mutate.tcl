# mutate.tcl -- mutation testing of the compilation target boundary
# (MACOS-AARCH64-MILESTONE-2.md): a target is an operating system and an
# architecture, and no part of the compiler may take one target's meaning
# for another's -- not the target table, platform module resolution, the
# HIR's recorded target, HIR interchange, the front-end cache, NIR or the
# native driver's host check and C calling convention.
#
#   tclsh9.0 audit/target-model/tools/mutate.tcl ?-only NAME,...? ?-timeout SECONDS?
#
# Each mutant is a deliberate bug written in mutants.txt (beside this
# script) as exact source replacements, each replaced text occurring exactly
# once. For each, a private copy of the compiler (a temporary directory)
# gets the replacements, and tests/target-model.test runs against it (with a
# private -tmpdir): the mutant is killed if a test fails or the file does
# not complete. A mutant of the Tcl sources shares this checkout's native
# driver (native/target is a symlink to it); a mutant of native/src
# rebuilds the driver in the private copy, whose native/target is a copy of
# this checkout's (made once, the first time one is needed: never a link,
# so no mutant builds into this checkout), and also runs the driver's own
# target unit tests (cargo test --bin botlish-native target::). The real
# checkout is never modified. Exits 1 when a mutant survives or no longer
# applies.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -timeout 900]
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

# 1 if the mutant's EDITS touch the native crate.
proc isNative {edits} {
    foreach {file old new} $edits {
        if {[string match native/src/* $file] || [string match native/Cargo* $file]} { return 1 }
    }
    return 0
}

# A private copy of the compiler sources and tests. The Tcl mutants run
# first, against this checkout's driver; the native ones after, against a
# private build (nativeTree).
set tree [file tempdir botlish-target-model-mutants]
foreach dir {compiler core hir surface lib tests examples} {
    file copy [file join $root $dir] [file join $tree $dir]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] eq "target"} {
        file link -symbolic [file join $tree native target] [file normalize $entry]
    } else {
        file copy $entry [file join $tree native]
    }
}
foreach entry [glob -directory $root -types f *.tcl] {
    file copy $entry $tree
}

# Replaces the private tree's native/target link by a copy of the directory
# it names (once), so a native mutant's build stays in the tree.
set privateNative 0
proc nativeTree {} {
    global tree root privateNative
    if {$privateNative} return
    set link [file join $tree native target]
    set source [file normalize [file join $root native target]]
    if {[file type $link] eq "link"} {
        set source [file normalize [file readlink $link]]
        file delete $link
    }
    exec cp -a $source $link
    set privateNative 1
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

# The verdict of tests/target-model.test in the tree: {killed|survived TEXT}.
proc testVerdict {timeout} {
    global tree
    set tmp [file tempdir botlish-target-model-mutant-run]
    lassign [run $timeout tclsh9.0 [file join $tree tests target-model.test] -tmpdir $tmp] status output
    file delete -force $tmp
    set failed [regexp -all -inline -line {^==== (tm-\S+) } $output]
    set failed [lsort -unique [lmap {- n} $failed {set n}]]
    if {[regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+(\d+)\s+Failed\s+(\d+)} $output -> skipped n]} {
        if {$skipped > 0 && $n == 0} {
            return [list survived "($skipped skipped: is the native backend built?)"]
        }
        return [expr {$n > 0 ? [list killed "$n failed: [join [lrange $failed 0 5] {, }][expr {[llength $failed] > 6 ? ", ..." : ""}]"] : [list survived ""]}]
    }
    return [list killed "did not complete: [string range [lindex [split [string trim $output] \n] end] 0 120]"]
}

set only [split [dict get $options -only] ,]
set ordered {}
foreach native {0 1} {
    foreach {name description edits} $mutants {
        if {[isNative $edits] == $native} { lappend ordered $name $description $edits }
    }
}
set results {}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
try {
    foreach {name description edits} $ordered {
        if {$only ne {} && $name ni $only} continue
        set native [isNative $edits]
        if {$native} { nativeTree }
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
        set verdict ""
        if {$native} {
            set manifest [file join $tree native Cargo.toml]
            lassign [run [dict get $options -timeout] cargo build --release --manifest-path $manifest] status output
            if {$status != 0} {
                set verdict [list killed "does not build: [string range [lindex [split [string trim $output] \n] end] 0 120]"]
            } else {
                lassign [run [dict get $options -timeout] cargo test --release --manifest-path $manifest --bin botlish-native target::] status output
                if {$status != 0} {
                    set verdict [list killed "the driver's target unit tests fail"]
                }
            }
        }
        if {$verdict eq ""} {
            set verdict [testVerdict [dict get $options -timeout]]
        } else {
            # Killed by the build or the unit tests; the test file's verdict too.
            set tests [testVerdict [dict get $options -timeout]]
            lset verdict 1 "[lindex $verdict 1]; target-model.test: [lindex $tests 0] [lindex $tests 1]"
        }
        lassign $verdict kind text
        set word [expr {$kind eq "killed" ? "KILLED" : "SURVIVED"}]
        lappend results [list $name $description $word $text]
        puts "$word $name\n    $text"
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
