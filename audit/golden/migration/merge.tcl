# merge.tcl -- builds tests/golden/manifest.tsv, the complete map between the
# Tcl tests and the golden tests (LARGE-SCALE-GOLDEN-MIGRATION.md, "The
# manifest"), from its inputs:
#
#   * manifest-before.tsv, the manifest as it was before the large-scale
#     migration (its rows are kept, with the new columns filled in);
#   * census/*.tsv -- one per Tcl test file: every test, its observational
#     classification (status), what it observes and what a golden test of it
#     would assert;
#   * fragments/*.tsv -- one per golden suite of the migration: its manifest
#     rows, in the manifest's columns (a Tcl test a migrator ported, split or
#     reclassified);
#   * a names file: every Tcl test that ran, "FILE NAME VERDICT" per line
#     (audit/golden/tools/check.tcl -full 1 -names-out, or the same from a
#     verbose run of the suite) -- the census's loop-generated names (with *)
#     are expanded against it, and a test without any row is reported.
#
#   tclsh9.0 audit/golden/migration/merge.tcl -names FILE ?-out PATH? ?-check 0|1?
#
# Precedence per Tcl test: fragment rows, else the old manifest's rows, else a
# not-ported row derived from the census. -check 1 writes nothing and exits 1
# on any problem (missing, stale, unexpanded pattern, unknown status).

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set options [dict create -names "" -out [file join $root tests golden manifest.tsv] -check 0 \
    -old [file join $here manifest-before.tsv]]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

proc readText {path} {
    set f [open $path]
    fconfigure $f -encoding utf-8
    set text [read $f]
    close $f
    return $text
}

# The rows of the TSV file PATH: {HEADER ROWS}, ROWS dicts.
proc readTsv {path} {
    set lines [split [string trimright [readText $path] \n] \n]
    set header [split [lindex $lines 0] \t]
    set rows {}
    set n 1
    foreach line [lrange $lines 1 end] {
        incr n
        if {[string trim $line] eq ""} continue
        set fields [split $line \t]
        if {[llength $fields] != [llength $header]} {
            lappend ::problems "$path:$n: [llength $fields] fields, the header has [llength $header]"
        }
        set row [dict create]
        foreach column $header value $fields {
            if {$column eq ""} continue
            dict set row $column [expr {$value eq "" ? "-" : $value}]
        }
        lappend rows $row
    }
    return [list $header $rows]
}

proc normalizeFile {file} {
    if {![string match tests/* $file]} { set file tests/$file }
    return $file
}

set problems {}
set oldColumns {old_file old_test suite new_test category outcome old_backends new_backends class also static handler api
    verbosity strength old_lines new_lines mutants notes}
set newColumns {subsystem status tcl_retained tcl_layer freeze tags}
set columns [concat $oldColumns $newColumns]

set statuses {MIGRATED SPLIT KEEP-INTERNAL KEEP-WARNING KEEP-PARSER KEEP-RUNTIME-ONLY KEEP-MULTI-PROGRAM
    KEEP-NOT-EXPRESSIBLE BLOCKED-GENERAL-COMPILER BLOCKED-TEST-LIBRARY}
set layerOf {MIGRATED DUPLICATED-E2E SPLIT ACTIVE-INTERNAL KEEP-INTERNAL ACTIVE-INTERNAL KEEP-WARNING ACTIVE-INTERNAL
    KEEP-PARSER ACTIVE-NOT-EXPRESSIBLE KEEP-RUNTIME-ONLY ACTIVE-NOT-EXPRESSIBLE KEEP-MULTI-PROGRAM ACTIVE-MULTI-PROGRAM
    KEEP-NOT-EXPRESSIBLE ACTIVE-NOT-EXPRESSIBLE BLOCKED-GENERAL-COMPILER ACTIVE-NOT-EXPRESSIBLE
    BLOCKED-TEST-LIBRARY ACTIVE-NOT-EXPRESSIBLE}

# ---------------------------------------------------------------------------
# The Tcl tests that ran.

if {[dict get $options -names] eq ""} {
    error "merge.tcl: -names FILE is required"
}
set discovered [dict create]
set discoveredByFile [dict create]
foreach line [split [string trim [readText [dict get $options -names]]] \n] {
    if {[llength $line] < 2} continue
    lassign $line file name verdict
    set file [normalizeFile $file]
    dict set discovered [list $file $name] $verdict
    dict lappend discoveredByFile $file $name
}

# ---------------------------------------------------------------------------
# The census: (file, test) -> census row; patterns expanded.

set census [dict create]
foreach path [lsort [glob -nocomplain -directory [file join $here census] *.tsv]] {
    lassign [readTsv $path] header rows
    foreach row $rows {
        set file [normalizeFile [dict get $row old_file]]
        set name [dict get $row old_test]
        dict set row old_file $file
        if {[string first * $name] >= 0 || ![dict exists $discovered [list $file $name]]} {
            # A pattern (or a name the run did not see): expand it against
            # the discovered names of its file.
            set matched 0
            if {[dict exists $discoveredByFile $file]} {
                foreach n [dict get $discoveredByFile $file] {
                    if {[string match $name $n] && ![dict exists $census [list $file $n]]} {
                        dict set row old_test $n
                        dict set census [list $file $n] $row
                        set matched 1
                    }
                }
            }
            if {!$matched} {
                if {[dict exists $discovered [list $file $name]]} {
                    dict set census [list $file $name] $row
                } else {
                    lappend problems "census row for a test that did not run: $file $name"
                }
            }
            continue
        }
        dict set census [list $file $name] $row
    }
}

# ---------------------------------------------------------------------------
# The fragments and the old manifest: (file, test) -> rows.

set fragmentRows [dict create]
foreach path [lsort [glob -nocomplain -directory [file join $here fragments] *.tsv]] {
    lassign [readTsv $path] header rows
    foreach column $columns {
        if {$column ni $header} { lappend problems "$path: no column $column" }
    }
    foreach row $rows {
        dict set row old_file [normalizeFile [dict get $row old_file]]
        dict lappend fragmentRows [list [dict get $row old_file] [dict get $row old_test]] $row
    }
}
set oldRows [dict create]
lassign [readTsv [dict get $options -old]] oldHeader rows
foreach row $rows {
    dict set row old_file [normalizeFile [dict get $row old_file]]
    dict lappend oldRows [list [dict get $row old_file] [dict get $row old_test]] $row
}

# ---------------------------------------------------------------------------
# One Tcl test's rows.

proc complete {row census} {
    global columns layerOf statuses problems
    foreach column $columns {
        if {![dict exists $row $column] || [dict get $row $column] eq ""} { dict set row $column - }
    }
    set key [list [dict get $row old_file] [dict get $row old_test]]
    if {[dict get $row subsystem] eq "-" && $census ne ""} {
        dict set row subsystem [dict get $census subsystem]
    }
    if {[dict get $row status] eq "-"} {
        # An old manifest row: ported rows are MIGRATED unless the census
        # says the Tcl test observes more; the not-ported ones take the
        # census's KEEP status.
        if {[dict get $row new_test] ne "-"} {
            set retained [expr {$census eq "" ? "-" : [dict get $census tcl_retained]}]
            dict set row status [expr {$retained ne "-" ? "SPLIT" : "MIGRATED"}]
            if {[dict get $row tcl_retained] eq "-"} { dict set row tcl_retained $retained }
        } elseif {$census ne "" && [string match KEEP-* [dict get $census status]]} {
            dict set row status [dict get $census status]
        } else {
            dict set row status KEEP-NOT-EXPRESSIBLE
        }
    }
    if {[dict get $row tags] eq "-" && $census ne ""} {
        dict set row tags [dict get $census tags]
    }
    set status [dict get $row status]
    if {$status ni $statuses} {
        lappend problems "unknown status $status: $key"
        return $row
    }
    if {[dict get $row tcl_layer] eq "-"} {
        set layer [dict get $layerOf $status]
        # A whole port that is weaker than its Tcl test leaves the Tcl test
        # observing more: it stays active.
        if {$status eq "MIGRATED" && [dict get $row strength] eq "weaker"} {
            set layer ACTIVE-NOT-EXPRESSIBLE
        }
        dict set row tcl_layer $layer
    }
    if {[dict get $row freeze] eq "-"} {
        dict set row freeze [expr {[dict get $row tcl_layer] eq "DUPLICATED-E2E" ? "FROZEN-DUPLICATE-ORACLE" : "ACTIVE-TCL-INTERNAL"}]
    }
    return $row
}

proc fromCensus {census} {
    set status [dict get $census status]
    switch -- $status {
        MIGRATE - SPLIT {
            # Classified source-observable and not ported: an unfinished
            # migration, reported by -check.
            lappend ::problems "census $status without a golden row: [dict get $census old_file] [dict get $census old_test]"
            set status BLOCKED-TEST-LIBRARY
        }
        BLOCKED { set status BLOCKED-GENERAL-COMPILER }
        PORTED {
            lappend ::problems "census PORTED without a manifest row: [dict get $census old_file] [dict get $census old_test]"
            set status KEEP-NOT-EXPRESSIBLE
        }
    }
    set notes [dict get $census observes]
    if {[dict get $census notes] ne "-"} { append notes " -- " [dict get $census notes] }
    return [dict create old_file [dict get $census old_file] old_test [dict get $census old_test] suite - new_test - \
        category [dict get $census subsystem] outcome not-ported class NOT-EXPRESSIBLE notes $notes \
        subsystem [dict get $census subsystem] status $status tcl_retained [dict get $census tcl_retained] \
        tags [dict get $census tags]]
}

set out {}
set keys [lsort -unique [concat [dict keys $discovered] [dict keys $fragmentRows] [dict keys $oldRows]]]
foreach key $keys {
    set c [expr {[dict exists $census $key] ? [dict get $census $key] : ""}]
    if {[dict exists $fragmentRows $key]} {
        set rows [dict get $fragmentRows $key]
    } elseif {[dict exists $oldRows $key]} {
        set rows [dict get $oldRows $key]
    } elseif {$c ne ""} {
        set rows [list [fromCensus $c]]
    } else {
        lappend problems "MISSING: no census, fragment or manifest row: $key"
        continue
    }
    if {![dict exists $discovered $key]} {
        lappend problems "STALE: the Tcl test did not run: $key"
    }
    foreach row $rows {
        lappend out [complete $row $c]
    }
}

foreach p $problems { puts "PROBLEM: $p" }
set counts [dict create]
foreach row $out { dict incr counts [dict get $row status] }
puts "[llength $out] rows; [join [lmap {k v} $counts {string cat $k " " $v}] {, }]"
if {[dict get $options -check]} {
    exit [expr {$problems eq {} ? 0 : 1}]
}
set f [open [dict get $options -out] w]
fconfigure $f -encoding utf-8 -translation lf
puts $f [join $columns \t]
foreach row $out {
    puts $f [join [lmap c $columns {string map {\t " " \n " "} [dict get $row $c]}] \t]
}
close $f
exit [expr {$problems eq {} ? 0 : 1}]
