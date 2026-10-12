# golden-workflows.tcl -- the economics of the two end-to-end layers as a
# developer runs them (LARGE-SCALE-GOLDEN-MIGRATION.md, "Performance"): fresh
# processes, one at a time, wall seconds, on this checkout.
#
#   tclsh9.0 bench/golden-workflows.tcl ?-parts LIST? ?-backend B? ?-out FILE?
#
# Parts:
#
#   tcl-e2e        the Tcl tests that have a golden counterpart (manifest rows
#                  with status MIGRATED or SPLIT), file by file with tcltest
#                  -match (so only those tests run), CORE_BACKEND=interp: what
#                  the Tcl suite spends on the source-level layer
#   tcl-e2e-files  the same Tcl files run whole (what a developer who runs a
#                  file pays)
#   golden         every golden suite on backend B (default interp; one
#                  process per suite: compile once, run once)
#   scenarios      targeted edit loops: for an edit to one compiler or runtime
#                  area, the golden suites and the Tcl files that cover it
#
# Prints one line per run and a summary table; -out FILE also writes the raw
# measurements ("PART NAME SECONDS STATUS").

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root audit golden tools tree.tcl]

set options [dict create -parts {tcl-e2e tcl-e2e-files golden scenarios} -backend interp -out ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set parts [dict get $options -parts]
set backend [dict get $options -backend]
set ::env(LANG) C.utf8
set ::env(LC_ALL) C.utf8
set measurements {}

proc wall {script} {
    set start [clock milliseconds]
    uplevel 1 $script
    return [expr {([clock milliseconds] - $start) / 1000.0}]
}

# Runs ARGS in a fresh process: {SECONDS STATUS OUTPUT}.
proc timed {args} {
    set seconds [wall {lassign [goldentools::run 7200 {*}$args] status output}]
    return [list $seconds $status $output]
}

proc record {part name seconds status} {
    lappend ::measurements [list $part $name $seconds $status]
    puts [format "%-14s %-48s %8.1f s  %s" $part $name $seconds $status]
    flush stdout
}

# The manifest's ported Tcl tests by file.
proc portedByFile {} {
    set lines [split [string trimright [goldentools::readFile [file join $::root tests golden manifest.tsv]] \n] \n]
    set header [split [lindex $lines 0] \t]
    set byFile [dict create]
    foreach line [lrange $lines 1 end] {
        set row [dict create]
        foreach c $header v [split $line \t] { dict set row $c $v }
        if {[dict get $row status] ni {MIGRATED SPLIT}} continue
        set file [dict get $row old_file]
        if {[dict exists $byFile $file] && [dict get $row old_test] in [dict get $byFile $file]} continue
        dict lappend byFile $file [dict get $row old_test]
    }
    return $byFile
}

proc runTclFile {file match} {
    set tmp [file tempdir botlish-bench-tcl]
    set ::env(CORE_BACKEND) interp
    try {
        set command [list tclsh9.0 [file join $::root $file] -tmpdir $tmp]
        if {$match ne ""} {
            lappend command -match [lmap n $match {string map {* \\* ? \\? [ \\[ ] \\]} $n}]
        }
        lassign [timed {*}$command] seconds status output
    } finally {
        file delete -force $tmp
        unset ::env(CORE_BACKEND)
    }
    set ok [regexp {Total\s+(\d+)\s+Passed\s+(\d+)\s+Skipped\s+\d+\s+Failed\s+0} $output -> total passed]
    return [list $seconds [expr {$ok ? "ok $passed/$total" : "FAILED"}]]
}

proc runGolden {suite backend} {
    lassign [timed tclsh9.0 [file join $::root tests golden run.tcl] -backends $backend -quiet [file join $::root tests golden $suite]] seconds status output
    return [list $seconds [expr {$status == 0 ? "ok" : "FAILED"}]]
}

if {"tcl-e2e" in $parts || "tcl-e2e-files" in $parts} {
    set byFile [portedByFile]
    set total 0
    set totalFiles 0
    dict for {file names} $byFile {
        if {"tcl-e2e" in $parts} {
            lassign [runTclFile $file $names] s st
            record tcl-e2e "[file tail $file] ([llength $names])" $s $st
            set total [expr {$total + $s}]
        }
        if {"tcl-e2e-files" in $parts} {
            lassign [runTclFile $file ""] s st
            record tcl-e2e-files [file tail $file] $s $st
            set totalFiles [expr {$totalFiles + $s}]
        }
    }
    puts [format "Tcl E2E subset: %d files, %d tests, %.1f s with -match; %.1f s as whole files" \
        [dict size $byFile] [tcl::mathop::+ 0 {*}[lmap {f n} $byFile {llength $n}]] $total $totalFiles]
}

if {"golden" in $parts} {
    set total 0
    foreach path [lsort [glob -directory [file join $root tests golden] *.bot]] {
        lassign [runGolden [file tail $path] $backend] s st
        record golden-$backend [file tail $path] $s $st
        set total [expr {$total + $s}]
    }
    puts [format "Golden corpus on %s: %.1f s, one process per suite" $backend $total]
}

if {"scenarios" in $parts} {
    # An edit to one area, and what covers it in each layer: golden suites
    # (on interp, or cranelift for a native edit) and Tcl files (whole, interp).
    set scenarios {
        affine-ownership {hir/affine.tcl} interp
            {affinity.bot ownership.bot coroutines.bot mutable-vector.bot}
            {tests/affine.test tests/coroutines.test tests/mutable-vector.test}
        error-completions {hir/completions.tcl} interp
            {declared-errors.bot errors.bot callable-contracts.bot completion-regressions.bot}
            {tests/errors.test tests/error-payloads.test tests/higher-order-completions.test tests/structural-contract-completions.test}
        core-evaluator {core/evaluator.tcl} interp
            {core-semantics.bot values.bot loops.bot loop-collecting.bot}
            {tests/calls.test tests/control.test tests/loops.test tests/loop-counted.test tests/loop-in.test tests/loop-collecting.test tests/elif.test tests/bindings.test tests/blocks.test}
        native-lowering {native/lower.tcl} cranelift
            {native-values.bot string-natives.bot native-aggregates.bot representation.bot}
            {tests/native.test tests/native-mutarray.test tests/native-string-region.test tests/native-uri-escape.test tests/native-param-aggregate.test}
    }
    foreach {name area scenarioBackend suites files} $scenarios {
        set g 0
        foreach suite $suites {
            lassign [runGolden $suite $scenarioBackend] s st
            record scenario-$name "golden $suite ($scenarioBackend)" $s $st
            set g [expr {$g + $s}]
        }
        set t 0
        foreach file $files {
            lassign [runTclFile $file ""] s st
            record scenario-$name "tcl [file tail $file]" $s $st
            set t [expr {$t + $s}]
        }
        puts [format "scenario %-18s (%s): golden %.1f s (%d suites), Tcl %.1f s (%d files)" $name $area $g [llength $suites] $t [llength $files]]
    }
}

if {[dict get $options -out] ne ""} {
    set f [open [dict get $options -out] w]
    foreach m $measurements { puts $f $m }
    close $f
}
