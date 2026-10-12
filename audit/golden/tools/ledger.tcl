# ledger.tcl -- the migration ledger of the golden suites
# (LARGE-SCALE-GOLDEN-MIGRATION.md, "The ledger"), generated from
# tests/golden/manifest.tsv, the one map between the Tcl tests and the golden
# tests.
#
#   tclsh9.0 audit/golden/tools/ledger.tcl ?-manifest PATH? ?-by subsystem|file?
#
# A Tcl test is one (old_file, old_test) pair; it has one manifest row per
# golden test it became, or one row with new_test "-" when it was not ported.
# Per subsystem (or per Tcl file), the ledger counts:
#
#   examined     Tcl tests with a row
#   observable   source-observable: migrated, split or temporarily blocked
#   migrated     whole theorem ported (status MIGRATED)
#   split        source half ported, Tcl keeps an internal half (SPLIT)
#   internal     KEEP-INTERNAL
#   warning      KEEP-WARNING
#   parser       KEEP-PARSER
#   runtime      KEEP-RUNTIME-ONLY
#   multi        KEEP-MULTI-PROGRAM
#   notexpr      KEEP-NOT-EXPRESSIBLE
#   blocked      BLOCKED-GENERAL-COMPILER or BLOCKED-TEST-LIBRARY
#   golden       golden tests (rows with a new_test)
#   equal/stronger/weaker/splitobs  the golden rows' strength column
#
# then the Tcl suite's layer classification (tcl_layer: DUPLICATED-E2E,
# ACTIVE-INTERNAL, ACTIVE-NOT-EXPRESSIBLE, ACTIVE-MULTI-PROGRAM) and the
# future freeze classification (freeze: FROZEN-DUPLICATE-ORACLE,
# ACTIVE-TCL-INTERNAL), per Tcl test. A Tcl test whose rows disagree on its
# status, layer or freeze class is reported (exit status 1), as is a row with
# an unknown status, layer, freeze class or strength.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -manifest [file join $root tests golden manifest.tsv] -by subsystem]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

proc readRows {path} {
    set f [open $path]
    fconfigure $f -encoding utf-8
    set lines [split [string trimright [read $f] \n] \n]
    close $f
    set header [split [lindex $lines 0] \t]
    set rows {}
    foreach line [lrange $lines 1 end] {
        set row [dict create]
        foreach column $header value [split $line \t] {
            dict set row $column $value
        }
        lappend rows $row
    }
    return [list $header $rows]
}

lassign [readRows [dict get $options -manifest]] header rows
foreach column {old_file old_test suite new_test status subsystem strength tcl_layer freeze} {
    if {$column ni $header} {
        puts stderr "ledger.tcl: the manifest has no column $column"
        exit 1
    }
}

set statuses {MIGRATED SPLIT KEEP-INTERNAL KEEP-WARNING KEEP-PARSER KEEP-RUNTIME-ONLY KEEP-MULTI-PROGRAM
    KEEP-NOT-EXPRESSIBLE BLOCKED-GENERAL-COMPILER BLOCKED-TEST-LIBRARY}
set layers {DUPLICATED-E2E ACTIVE-INTERNAL ACTIVE-NOT-EXPRESSIBLE ACTIVE-MULTI-PROGRAM}
set freezes {FROZEN-DUPLICATE-ORACLE ACTIVE-TCL-INTERNAL}
set strengths {equal stronger weaker split}

set problems {}
# Tcl test key -> {group status layer freeze}; and per key its golden rows.
set tests [dict create]
set goldenRows [dict create]
foreach row $rows {
    set key [list [dict get $row old_file] [dict get $row old_test]]
    set group [expr {[dict get $options -by] eq "file" ? [file tail [dict get $row old_file]] : [dict get $row subsystem]}]
    set status [dict get $row status]
    set layer [dict get $row tcl_layer]
    set freeze [dict get $row freeze]
    if {$status ni $statuses} { lappend problems "unknown status \"$status\": $key" }
    if {$layer ni $layers} { lappend problems "unknown tcl_layer \"$layer\": $key" }
    if {$freeze ni $freezes} { lappend problems "unknown freeze \"$freeze\": $key" }
    set ported [expr {[dict get $row new_test] ne "-"}]
    if {$ported && $status ni {MIGRATED SPLIT}} { lappend problems "ported row with status $status: $key" }
    if {!$ported && $status in {MIGRATED SPLIT}} { lappend problems "status $status without a golden test: $key" }
    if {$ported && [dict get $row strength] ni $strengths} {
        lappend problems "unknown strength \"[dict get $row strength]\": $key -> [dict get $row new_test]"
    }
    if {[dict exists $tests $key]} {
        lassign [dict get $tests $key] g s l z
        if {$s ne $status || $l ne $layer || $z ne $freeze} {
            lappend problems "rows disagree ($s/$l/$z vs $status/$layer/$freeze): $key"
        }
    } else {
        dict set tests $key [list $group $status $layer $freeze]
    }
    if {$ported} {
        dict lappend goldenRows $key $row
    }
}

set columns {examined observable migrated split internal warning parser runtime multi notexpr blocked golden equal stronger weaker splitobs}
set statusColumn {MIGRATED migrated SPLIT split KEEP-INTERNAL internal KEEP-WARNING warning KEEP-PARSER parser
    KEEP-RUNTIME-ONLY runtime KEEP-MULTI-PROGRAM multi KEEP-NOT-EXPRESSIBLE notexpr
    BLOCKED-GENERAL-COMPILER blocked BLOCKED-TEST-LIBRARY blocked}
set strengthColumn {equal equal stronger stronger weaker weaker split splitobs}
set ledger [dict create]
set totals [dict create]
foreach c $columns { dict set totals $c 0 }
set layerCounts [dict create]
set freezeCounts [dict create]
dict for {key info} $tests {
    lassign $info group status layer freeze
    if {![dict exists $ledger $group]} {
        foreach c $columns { dict set ledger $group $c 0 }
    }
    set counted [list examined [dict get $statusColumn $status]]
    if {$status in {MIGRATED SPLIT BLOCKED-GENERAL-COMPILER BLOCKED-TEST-LIBRARY}} {
        lappend counted observable
    }
    if {[dict exists $goldenRows $key]} {
        foreach row [dict get $goldenRows $key] {
            lappend counted golden
            if {[dict exists $strengthColumn [dict get $row strength]]} {
                lappend counted [dict get $strengthColumn [dict get $row strength]]
            }
        }
    }
    foreach c $counted {
        dict set ledger $group $c [expr {[dict get $ledger $group $c] + 1}]
        dict incr totals $c
    }
    dict incr layerCounts $layer
    dict incr freezeCounts $freeze
}

set width [expr {max(14, [tcl::mathfunc::max {*}[lmap g [dict keys $ledger] {string length $g}]])}]
puts [format "%-${width}s%s" [dict get $options -by] [join [lmap c $columns {format %10s $c}] ""]]
foreach group [lsort [dict keys $ledger]] {
    puts [format "%-${width}s%s" $group [join [lmap c $columns {format %10d [dict get $ledger $group $c]}] ""]]
}
puts [format "%-${width}s%s" total [join [lmap c $columns {format %10d [dict get $totals $c]}] ""]]
puts ""
puts "Tcl tests by layer:"
foreach l $layers { puts [format "    %-26s %6d" $l [expr {[dict exists $layerCounts $l] ? [dict get $layerCounts $l] : 0}]] }
puts "Tcl tests by future freeze class:"
foreach z $freezes { puts [format "    %-26s %6d" $z [expr {[dict exists $freezeCounts $z] ? [dict get $freezeCounts $z] : 0}]] }
puts "\n[dict size $tests] Tcl tests, [llength $rows] manifest rows, [dict get $totals golden] golden tests"
foreach p $problems { puts "PROBLEM: $p" }
exit [expr {$problems eq {} ? 0 : 1}]
