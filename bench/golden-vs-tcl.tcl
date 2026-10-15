# golden-vs-tcl.tcl -- the Tcl tests that have golden counterparts against
# the golden suites, on every backend, with and without the front-end cache
# (HIR-INTERCHANGE.md, "The front-end cache"), as a developer runs them: fresh
# processes, N at a time, wall and CPU seconds, optionally phase-profiled
# (bench/phase-profile.tcl) in the very processes that run.
#
#   tclsh9.0 bench/golden-vs-tcl.tcl run -layer tcl|golden -backends LIST
#            -name NAME -out DIR ?-jobs N? ?-profile 0|1? ?-hir-cache DIR?
#            ?-order FILE? ?-items LIST?
#   tclsh9.0 bench/golden-vs-tcl.tcl report -out DIR ?-runs LIST?
#
# run, -layer tcl: every Tcl file holding a test the manifest ports (rows
# MIGRATED or SPLIT), one process per file, tcltest -match running exactly
# those tests, CORE_BACKEND=B for the one backend B of -backends (interp,
# compile, cranelift-generic or cranelift; the Tcl suite's harness registers
# the native two) and a private -tmpdir. -verbose u gives each test's body
# time.
#
# run, -layer golden: every golden suite, one process per suite:
# tests/golden/run.tcl -backends LIST -quiet SUITE (one compilation, then a
# run on each backend of LIST the suite does not exclude).
#
# -hir-cache DIR sets BOTLISH_HIR_CACHE=DIR in every child (unset otherwise).
# The Tcl suite's harness unsets it (tests/helpers.tcl), so for -layer tcl it
# is a control: the run must equal one without it, and DIR must stay empty.
# -order FILE runs the items longest first by an earlier run's seconds (a
# NAME.runs file of DIR, or lines "ITEM SECONDS"); else by size. -items limits
# the run to those items (file or suite tails).
#
# Each item runs under bash's `time` (wall, user and system seconds of the
# process and every child it waited for: native drivers, main.tcl children).
# The records go to DIR/NAME.runs, one Tcl dict per item; with -profile 1 each
# carries the process's phase profile.
#
# report prints a Markdown report of the runs in DIR (all, or -runs LIST).

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root audit golden tools tree.tcl]
set ::env(LANG) C.utf8
set ::env(LC_ALL) C.utf8

proc readLines {path} {
    return [split [string trimright [goldentools::readFile $path] \n] \n]
}

# The manifest's ported Tcl tests by file (file -> names), and the golden
# suites each ported Tcl test maps to ({file name} -> suites).
proc ported {} {
    set lines [readLines [file join $::root tests golden manifest.tsv]]
    set header [split [lindex $lines 0] \t]
    set byFile [dict create]
    set suitesOf [dict create]
    foreach line [lrange $lines 1 end] {
        set row [dict create]
        foreach c $header v [split $line \t] { dict set row $c $v }
        if {[dict get $row status] ni {MIGRATED SPLIT}} continue
        set file [dict get $row old_file]
        set name [dict get $row old_test]
        if {![dict exists $suitesOf [list $file $name]]} {
            dict lappend byFile $file $name
            dict set suitesOf [list $file $name] {}
        }
        set suite [dict get $row suite]
        if {$suite ni [dict get $suitesOf [list $file $name]]} {
            dict lappend suitesOf [list $file $name] $suite
        }
    }
    return [list $byFile $suitesOf]
}

proc globEscape {name} {
    return [string map {\\ \\\\ * \\* ? \\? [ \\[ ] \\]} $name]
}

# ARGS run under bash's time; the last output line is "@@CPU REAL USER SYS".
proc timedCommand {env args} {
    return [list env {*}$env bash -c {TIMEFORMAT='@@CPU %R %U %S'; time "$@"} bash {*}$args]
}

proc environment {options extra} {
    set env {}
    set cache [dict get $options -hir-cache]
    if {$cache eq ""} {
        lappend env -u BOTLISH_HIR_CACHE
    } else {
        lappend env BOTLISH_HIR_CACHE=$cache
    }
    return [concat $env $extra]
}

# An earlier run's seconds by item, for -order.
proc orderHints {path} {
    set hints [dict create]
    if {$path eq ""} { return $hints }
    foreach line [readLines $path] {
        if {[llength $line] == 2 && [string is double -strict [lindex $line 1]]} {
            dict set hints [lindex $line 0] [lindex $line 1]
        } elseif {[dict exists $line item]} {
            dict set hints [dict get $line item] [dict get $line seconds]
        }
    }
    return $hints
}

proc parseTcl {output} {
    set r [dict create]
    if {[regexp {Total\s+(\d+)\s+Passed\s+(\d+)\s+Skipped\s+(\d+)\s+Failed\s+(\d+)} $output -> total passed skipped failed]} {
        dict set r passed $passed
        dict set r failed $failed
    } else {
        dict set r incomplete [goldentools::lastLine $output]
    }
    set times [dict create]
    foreach {- name us} [regexp -all -inline -line "^\\+\\+\\+\\+ (\\S+) took (\\d+) µs$" $output] {
        dict set times $name $us
    }
    dict set r testUs $times
    dict set r failedNames [lsort -unique [lmap {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {set n}]]
    return $r
}

proc parseGolden {output} {
    set r [dict create backends [dict create]]
    foreach line [split $output \n] {
        if {[regexp {^(\S+)\s+(\S+)\s+(\d+) passed, (\d+) failed \(compile ([\d.]+)s, run ([\d.]+)s\)$} $line -> suite backend passed failed compile run]} {
            dict set r backends $backend [dict create passed $passed failed $failed run $run]
            dict set r compile $compile
        } elseif {[regexp {^(\S+)\s+(\S+)\s+ABORTED (.*) \(compile ([\d.]+)s, run ([\d.]+)s\)$} $line -> suite backend message compile run]} {
            dict set r backends $backend [dict create aborted $message run $run]
            dict set r compile $compile
        } elseif {[regexp {^(\S+)\s+(\S+)\s+excluded -- (.*)$} $line -> suite backend reason]} {
            dict set r backends $backend [dict create excluded $reason]
        } elseif {[regexp {COMPILE ERROR (.*)$} $line -> message]} {
            dict set r compileError $message
        }
    }
    return $r
}

proc run {options} {
    set layer [dict get $options -layer]
    set backends [split [dict get $options -backends] ,]
    set name [dict get $options -name]
    set out [file normalize [dict get $options -out]]
    file mkdir $out
    set profileDir [file join $out $name.prof]
    if {[dict get $options -profile]} {
        file delete -force $profileDir
        file mkdir $profileDir
    }
    set hints [orderHints [dict get $options -order]]
    set only [dict get $options -items]
    set commands [dict create]
    set sizes [dict create]
    set tmps {}
    if {$layer eq "tcl"} {
        if {[llength $backends] != 1} { error "-layer tcl takes one backend" }
        lassign [ported] byFile
        dict for {file names} $byFile {
            set item [file tail $file]
            if {$only ne "" && $item ni $only} continue
            set tmp [file tempdir botlish-golden-vs-tcl]
            lappend tmps $tmp
            set script [list [file join $::root $file] -tmpdir $tmp -verbose bu \
                -match [lmap n $names {globEscape $n}]]
            set prefix tclsh9.0
            if {[dict get $options -profile]} {
                lappend prefix [file join $::root bench phase-profile.tcl] [file join $profileDir $item.prof]
            }
            dict set commands $item [timedCommand [environment $options [list CORE_BACKEND=[lindex $backends 0]]] {*}$prefix {*}$script]
            dict set sizes $item [llength $names]
        }
    } else {
        foreach path [lsort [glob -directory [file join $::root tests golden] *.bot]] {
            set item [file tail $path]
            if {$only ne "" && $item ni $only} continue
            set prefix tclsh9.0
            if {[dict get $options -profile]} {
                lappend prefix [file join $::root bench phase-profile.tcl] [file join $profileDir $item.prof]
            }
            dict set commands $item [timedCommand [environment $options {}] {*}$prefix \
                [file join $::root tests golden run.tcl] -backends [join $backends ,] -quiet $path]
            dict set sizes $item [file size $path]
        }
    }
    # Longest first: by the hints, then by size.
    set order [lsort -command [list apply {{hints sizes a b} {
        set ha [expr {[dict exists $hints $a] ? [dict get $hints $a] : 1e9}]
        set hb [expr {[dict exists $hints $b] ? [dict get $hints $b] : 1e9}]
        if {$ha != $hb} { return [expr {$ha < $hb ? 1 : -1}] }
        return [expr {[dict get $sizes $a] < [dict get $sizes $b] ? 1 : -1}]
    }} $hints $sizes] [dict keys $commands]]
    set ordered [dict create]
    foreach item $order { dict set ordered $item [dict get $commands $item] }

    set started [clock milliseconds]
    try {
        set outcomes [goldentools::runParallel [dict get $options -jobs] 7200 $ordered]
    } finally {
        foreach tmp $tmps { file delete -force $tmp }
    }
    set wall [expr {([clock milliseconds] - $started) / 1000.0}]

    set channel [open [file join $out $name.runs] w]
    fconfigure $channel -encoding utf-8
    set problems 0
    foreach item $order {
        lassign [dict get $outcomes $item] status output seconds
        set record [dict create item $item seconds $seconds status $status]
        if {[regexp -line {^@@CPU ([\d.]+) ([\d.]+) ([\d.]+)$} $output -> real user sys]} {
            dict set record cpu [list $user $sys]
        }
        dict set record result [expr {$layer eq "tcl" ? [parseTcl $output] : [parseGolden $output]}]
        set profile [file join $profileDir $item.prof]
        if {[dict get $options -profile] && [file exists $profile]} {
            dict set record profile [goldentools::readFile $profile]
        }
        set ok [expr {$status == 0}]
        if {$layer eq "tcl"} {
            set ok [expr {[dict exists $record result passed] && [dict get $record result failed] == 0}]
        }
        if {!$ok} {
            incr problems
            dict set record tail [lrange [split [string trim $output] \n] end-20 end]
        }
        puts $channel $record
        puts [format "%-44s %8.1f s  %s" $item $seconds [expr {$ok ? "ok" : "PROBLEM (status $status)"}]]
    }
    close $channel
    set meta [dict create name $name layer $layer backends $backends jobs [dict get $options -jobs] \
        profile [dict get $options -profile] hirCache [dict get $options -hir-cache] wall $wall \
        items [llength $order] problems $problems \
        cacheEntries [expr {[dict get $options -hir-cache] ne "" && [file isdirectory [dict get $options -hir-cache]]
            ? [llength [glob -nocomplain -directory [dict get $options -hir-cache] *.hirc]] : 0}] \
        date [clock format [clock seconds] -format {%Y-%m-%d %H:%M:%S}]]
    goldentools::writeFile [file join $out $name.meta] $meta
    puts [format "%s: %d items, wall %.1f s with %d job(s), %d with a problem" $name [llength $order] $wall [dict get $options -jobs] $problems]
}

# ---------------------------------------------------------------------------
# The report.

proc sum {list} { return [tcl::mathop::+ 0.0 {*}$list] }
proc f1 {x} { return [format %.1f $x] }
proc f2 {x} { return [format %.2f $x] }

proc loadRun {out name} {
    set meta [goldentools::readFile [file join $out $name.meta]]
    set records [lmap line [readLines [file join $out $name.runs]] {expr {$line eq "" ? [continue] : $line}}]
    return [list $meta $records]
}

proc cpuOf {r} {
    return [expr {[dict exists $r cpu] ? [sum [dict get $r cpu]] : 0}]
}

# The phase profile totals of RECORDS: {SELF CALLS ROOTS BYROOT WALL}.
proc profileTotals {records} {
    set self [dict create]
    set calls [dict create]
    set roots [dict create]
    set byRoot [dict create]
    set wall 0
    foreach r $records {
        if {![dict exists $r profile]} continue
        set p [dict get $r profile]
        set wall [expr {$wall + [dict get $p wall]}]
        dict for {k v} [dict get $p self] { dict incr self $k $v }
        dict for {k v} [dict get $p calls] { dict incr calls $k $v }
        dict for {k v} [dict get $p roots] { dict incr roots $k $v }
        dict for {root phases} [dict get $p byRoot] {
            dict for {k v} $phases {
                if {[dict exists $byRoot $root $k]} {
                    dict set byRoot $root $k [expr {[dict get $byRoot $root $k] + $v}]
                } else {
                    dict set byRoot $root $k $v
                }
            }
        }
    }
    return [list $self $calls $roots $byRoot $wall]
}

# {WALL PROCESS CPU} of run NAME in OUT, or "" when it was not run.
proc totals {out name names} {
    if {$name ni $names} { return "" }
    lassign [loadRun $out $name] meta records
    return [list [dict get $meta wall] [sum [lmap r $records {dict get $r seconds}]] \
        [sum [lmap r $records {cpuOf $r}]]]
}

proc cells {t} {
    if {$t eq ""} { return {- - -} }
    return [lmap x $t {f1 $x}]
}

# The two layers side by side, by the run names this tool's matrix uses
# (tcl-B, golden-B, golden-B-cold/-warm, golden-all, golden-all-cold/-warm),
# and the golden suites against the Tcl tests they port.
proc comparison {out names} {
    puts "\n## The two layers, backend by backend (wall s / process s summed / CPU s summed)\n"
    puts "| backend | Tcl subset | golden, no cache | golden, cache cold | golden, cache warm | golden no cache / Tcl (CPU) | golden warm / Tcl (CPU) |"
    puts "|---|---|---|---|---|---:|---:|"
    foreach b {interp compile cranelift-generic cranelift} {
        set tcl [totals $out tcl-$b $names]
        set none [totals $out golden-$b $names]
        set cold [totals $out golden-$b-cold $names]
        set warm [totals $out golden-$b-warm $names]
        set r1 [expr {$tcl ne "" && $none ne "" ? [f2 [expr {[lindex $none 2] / [lindex $tcl 2]}]] : "-"}]
        set r2 [expr {$tcl ne "" && $warm ne "" ? [f2 [expr {[lindex $warm 2] / [lindex $tcl 2]}]] : "-"}]
        puts "| $b | [join [cells $tcl] { / }] | [join [cells $none] { / }] | [join [cells $cold] { / }] | [join [cells $warm] { / }] | $r1 | $r2 |"
    }
    set tclAll {}
    foreach b {interp compile cranelift-generic cranelift} {
        set t [totals $out tcl-$b $names]
        if {$t eq ""} { set tclAll ""; break }
        set tclAll [expr {$tclAll eq "" ? $t : [lmap x $tclAll y $t {expr {$x + $y}}]}]
    }
    set sepNone {}
    set sepCache {}
    foreach b {interp compile cranelift-generic cranelift} {
        set t [totals $out golden-$b $names]
        set c [totals $out [expr {$b eq "interp" ? "golden-interp-cold" : "golden-$b-warm"}] $names]
        if {$t eq "" || $c eq ""} { set sepNone ""; set sepCache ""; break }
        set sepNone [expr {$sepNone eq "" ? $t : [lmap x $sepNone y $t {expr {$x + $y}}]}]
        set sepCache [expr {$sepCache eq "" ? $c : [lmap x $sepCache y $c {expr {$x + $y}}]}]
    }
    puts "\nAll four backends:\n"
    puts "| configuration | wall s | process s summed | CPU s summed |"
    puts "|---|---:|---:|---:|"
    puts "| Tcl subset, the four CORE_BACKEND passes | [join [cells $tclAll] { | }] |"
    puts "| golden, one process per suite and backend, no cache | [join [cells $sepNone] { | }] |"
    puts "| golden, one process per suite and backend, one cache (interp fills it, the rest hit) | [join [cells $sepCache] { | }] |"
    puts "| golden, one process per suite (four backends), no cache | [join [cells [totals $out golden-all $names]] { | }] |"
    puts "| golden, one process per suite (four backends), cache cold | [join [cells [totals $out golden-all-cold $names]] { | }] |"
    puts "| golden, one process per suite (four backends), cache warm | [join [cells [totals $out golden-all-warm $names]] { | }] |"

    # Per suite: the golden suite against the Tcl tests it ports, on interp.
    if {"tcl-interp" ni $names || "golden-interp" ni $names} return
    lassign [ported] byFile suitesOf
    set tclCost [dict create]
    set tclTests [dict create]
    lassign [loadRun $out tcl-interp] - records
    foreach r $records {
        set file tests/[dict get $r item]
        set times [dict get $r result testUs]
        if {![dict size $times]} continue
        set overhead [expr {[dict get $r seconds] - [sum [dict values $times]] / 1e6}]
        set share [expr {$overhead / [dict size $times]}]
        dict for {name us} $times {
            if {![dict exists $suitesOf [list $file $name]]} continue
            set suites [dict get $suitesOf [list $file $name]]
            foreach suite $suites {
                set cost [expr {($us / 1e6 + $share) / [llength $suites]}]
                dict set tclCost $suite [expr {([dict exists $tclCost $suite] ? [dict get $tclCost $suite] : 0) + $cost}]
                dict set tclTests $suite [expr {([dict exists $tclTests $suite] ? [dict get $tclTests $suite] : 0) + 1}]
            }
        }
    }
    set runs [dict create]
    foreach name {golden-interp golden-interp-warm golden-all golden-all-warm} {
        if {$name ni $names} continue
        lassign [loadRun $out $name] - records
        foreach r $records { dict set runs $name [dict get $r item] $r }
    }
    puts "\n## Golden suites against the Tcl tests they port (interp; seconds)\n"
    puts "A Tcl test's cost is its body time plus an equal share of its file's process time outside test bodies; a Tcl test ported to several suites is divided among them.\n"
    puts "| suite | golden tests | Tcl tests ported | Tcl cost | golden process | of which compile | golden warm process | golden/Tcl | warm/Tcl | all four, no cache | all four, warm |"
    puts "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|"
    set rows {}
    dict for {suite r} [dict get $runs golden-interp] {
        set g [dict get $r seconds]
        set compile [expr {[dict exists $r result compile] ? [dict get $r result compile] : 0}]
        set passed [expr {[dict exists $r result backends interp passed] ? [dict get $r result backends interp passed] : "-"}]
        set t [expr {[dict exists $tclCost $suite] ? [dict get $tclCost $suite] : 0}]
        set n [expr {[dict exists $tclTests $suite] ? [dict get $tclTests $suite] : 0}]
        set warm [expr {[dict exists $runs golden-interp-warm $suite] ? [dict get $runs golden-interp-warm $suite seconds] : ""}]
        set all [expr {[dict exists $runs golden-all $suite] ? [dict get $runs golden-all $suite seconds] : ""}]
        set allWarm [expr {[dict exists $runs golden-all-warm $suite] ? [dict get $runs golden-all-warm $suite seconds] : ""}]
        lappend rows [list $suite $passed $n $t $g $compile $warm $all $allWarm]
    }
    set sums {0 0 0 0 0 0 0 0}
    foreach row [lsort -real -decreasing -index 4 $rows] {
        lassign $row suite passed n t g compile warm all allWarm
        puts "| $suite | $passed | $n | [f1 $t] | [f1 $g] | [f1 $compile] | [expr {$warm eq "" ? "-" : [f1 $warm]}] | [expr {$t > 0 ? [f1 [expr {$g / $t}]] : "-"}] | [expr {$t > 0 && $warm ne "" ? [f2 [expr {$warm / $t}]] : "-"}] | [expr {$all eq "" ? "-" : [f1 $all]}] | [expr {$allWarm eq "" ? "-" : [f1 $allWarm]}] |"
        set sums [lmap s $sums v [list [expr {$passed eq "-" ? 0 : $passed}] $n $t $g $compile [expr {$warm eq "" ? 0 : $warm}] [expr {$all eq "" ? 0 : $all}] [expr {$allWarm eq "" ? 0 : $allWarm}]] {expr {$s + $v}}]
    }
    lassign $sums passed n t g compile warm all allWarm
    puts "| total | $passed | $n | [f1 $t] | [f1 $g] | [f1 $compile] | [f1 $warm] | [f2 [expr {$g / max($t, 1e-9)}]] | [f2 [expr {$warm / max($t, 1e-9)}]] | [f1 $all] | [f1 $allWarm] |"
}

proc report {options} {
    set out [file normalize [dict get $options -out]]
    set names [dict get $options -runs]
    if {$names eq ""} {
        set names [lmap p [lsort [glob -nocomplain -directory $out *.meta]] {file rootname [file tail $p]}]
    }
    puts "## Runs\n"
    puts "| run | layer | backends | HIR cache | jobs | items | wall s | process s summed | CPU s summed | tests passed / failed | problems |"
    puts "|---|---|---|---|---|---|---:|---:|---:|---|---|"
    foreach name $names {
        lassign [loadRun $out $name] meta records
        set processSum [sum [lmap r $records {dict get $r seconds}]]
        set cpuSum [sum [lmap r $records {cpuOf $r}]]
        if {[dict get $meta layer] eq "tcl"} {
            set passed [expr {int([sum [lmap r $records {expr {[dict exists $r result passed] ? [dict get $r result passed] : 0}}]])}]
            set failed [expr {int([sum [lmap r $records {expr {[dict exists $r result failed] ? [dict get $r result failed] : 0}}]])}]
        } else {
            set passed 0
            set failed 0
            foreach r $records {
                dict for {b o} [dict get $r result backends] {
                    if {[dict exists $o passed]} {
                        incr passed [dict get $o passed]
                        incr failed [dict get $o failed]
                    }
                }
            }
        }
        set cache [expr {[dict get $meta hirCache] eq "" ? "off" : "on ([dict get $meta cacheEntries] entries after)"}]
        puts "| $name | [dict get $meta layer] | [join [dict get $meta backends] {, }] | $cache | [dict get $meta jobs] | [dict get $meta items] | [f1 [dict get $meta wall]] | [f1 $processSum] | [f1 $cpuSum] | $passed / $failed | [dict get $meta problems] |"
    }

    # Golden: the compilation (front end or cache hit) and each backend's run.
    puts "\n## Golden runs: compilation and runs (seconds, summed over suites)\n"
    puts "| run | compile (front end or cache hit) | interp run | compile run | cranelift-generic run | cranelift run | longest suite |"
    puts "|---|---:|---:|---:|---:|---:|---|"
    foreach name $names {
        lassign [loadRun $out $name] meta records
        if {[dict get $meta layer] ne "golden"} continue
        set compile [sum [lmap r $records {expr {[dict exists $r result compile] ? [dict get $r result compile] : 0}}]]
        set cells {}
        foreach b {interp compile cranelift-generic cranelift} {
            if {$b ni [dict get $meta backends]} { lappend cells -; continue }
            lappend cells [f1 [sum [lmap r $records {expr {[dict exists $r result backends $b run] ? [dict get $r result backends $b run] : 0}}]]]
        }
        set longest [lindex [lsort -real -decreasing -index 1 [lmap r $records {list [dict get $r item] [dict get $r seconds]}]] 0]
        puts "| $name | [f1 $compile] | [join $cells { | }] | [lindex $longest 0] [f1 [lindex $longest 1]] s |"
    }

    # Tcl: test bodies against the process.
    puts "\n## Tcl runs: test bodies and process overhead (seconds, summed over files)\n"
    puts "| run | ported tests run | test bodies | process minus bodies | longest file |"
    puts "|---|---:|---:|---:|---|"
    foreach name $names {
        lassign [loadRun $out $name] meta records
        if {[dict get $meta layer] ne "tcl"} continue
        set bodies 0
        set count 0
        foreach r $records {
            set us [dict values [dict get $r result testUs]]
            set bodies [expr {$bodies + [sum $us] / 1e6}]
            incr count [llength $us]
        }
        set processSum [sum [lmap r $records {dict get $r seconds}]]
        set longest [lindex [lsort -real -decreasing -index 1 [lmap r $records {list [dict get $r item] [dict get $r seconds]}]] 0]
        puts "| $name | $count | [f1 $bodies] | [f1 [expr {$processSum - $bodies}]] | [lindex $longest 0] [f1 [lindex $longest 1]] s |"
    }

    comparison $out $names

    # Profiles.
    foreach name $names {
        lassign [loadRun $out $name] meta records
        if {![dict get $meta profile]} continue
        lassign [profileTotals $records] self calls roots byRoot wall
        set processSum [sum [lmap r $records {dict get $r seconds}]]
        set profiled [sum [dict values $roots]]
        puts "\n## Profile: $name\n"
        puts "Processes [f1 $processSum] s summed; inside the profiler [f1 [expr {$wall / 1e6}]] s; in profiled phases [f1 [expr {$profiled / 1e6}]] s.\n"
        puts "Top-level phases (inclusive):\n"
        puts "| phase | s | share of process time |"
        puts "|---|---:|---:|"
        foreach {k v} [lsort -stride 2 -index 1 -integer -decreasing $roots] {
            puts "| $k | [f1 [expr {$v / 1e6}]] | [format %.1f%% [expr {100.0 * $v / 1e6 / $processSum}]] |"
        }
        puts "| (outside every phase: process start, tcltest, test bodies' own Tcl, runner) | [f1 [expr {$processSum - $profiled / 1e6}]] | [format %.1f%% [expr {100.0 * ($processSum - $profiled / 1e6) / $processSum}]] |"
        puts "\nSelf time per phase (top 30):\n"
        puts "| phase | self s | calls | share of profiled |"
        puts "|---|---:|---:|---:|"
        foreach {k v} [lrange [lsort -stride 2 -index 1 -integer -decreasing $self] 0 59] {
            puts "| $k | [f1 [expr {$v / 1e6}]] | [dict get $calls $k] | [format %.1f%% [expr {100.0 * $v / $profiled}]] |"
        }
        if {[dict get $meta layer] eq "golden"} {
            puts "\nPer backend run (self time of its phases, top 8 each):\n"
            puts "| run root | s | top phases |"
            puts "|---|---:|---|"
            foreach {k v} [lsort -stride 2 -index 1 -integer -decreasing $roots] {
                if {![string match run:* $k] && $k ne "golden:compile"} continue
                set top [lrange [lsort -stride 2 -index 1 -integer -decreasing [dict get $byRoot $k]] 0 15]
                puts "| $k | [f1 [expr {$v / 1e6}]] | [join [lmap {p s} $top {format "%s %.1f" $p [expr {$s / 1e6}]}] {, }] |"
            }
        }
    }
}

# ---------------------------------------------------------------------------

set command [lindex $argv 0]
set options [dict create -layer golden -backends interp -name "" -out "" -jobs 4 -profile 0 \
    -hir-cache "" -order "" -items "" -runs ""]
foreach {option value} [lrange $argv 1 end] {
    if {![dict exists $options $option]} { error "golden-vs-tcl.tcl: unknown option $option" }
    dict set options $option $value
}
if {[dict get $options -out] eq ""} { error "golden-vs-tcl.tcl: -out DIR is required" }
switch -- $command {
    run {
        if {[dict get $options -name] eq ""} { error "golden-vs-tcl.tcl: -name is required" }
        if {[dict get $options -hir-cache] ne ""} {
            dict set options -hir-cache [file normalize [dict get $options -hir-cache]]
        }
        run $options
    }
    report { report $options }
    default { error "usage: golden-vs-tcl.tcl run|report ..." }
}
