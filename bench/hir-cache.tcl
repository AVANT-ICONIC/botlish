# hir-cache.tcl -- what the HIR interchange format and the front-end cache
# cost and save (HIR-INTERCHANGE.md, "Cost").
#
#   tclsh9.0 bench/hir-cache.tcl ?-suites FILES|all? ?-repeat N?
#
# For each golden suite of FILES (default: the nine of
# audit/hir-interchange/tools/roundtrip.tcl), in one process: the front end
# (surface::readProgramFile, no cache), encoding its HIR without and with
# traitSource, decoding it (activation included), a compilation through an
# empty cache (the build, then keeping the entry) and one that hits (reading
# and checking the entry, decoding it). Each time is the best of N (default
# 3) runs, the build's included; the sizes are the interchange text's and the
# cache entry's. Prints a Markdown table.

set root [file dirname [file dirname [file normalize [info script]]]]
set options [dict create -suites {traits-path.bot harness.bot contexts.bot affinity.bot coroutines.bot
    errors.bot representation.bot declared-errors.bot ownership.bot} -repeat 3]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "hir-cache.tcl: unknown option $option" }
    dict set options $option $value
}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 200000

proc best {script} {
    global options
    set best ""
    for {set i 0} {$i < [dict get $options -repeat]} {incr i} {
        set us [lindex [uplevel 1 [list time $script]] 0]
        if {$best eq "" || $us < $best} {
            set best $us
        }
    }
    return $best
}

proc ms {us} {
    return [format %.0f [expr {$us / 1000.0}]]
}

set suites [dict get $options -suites]
if {$suites eq "all"} {
    set suites [lmap path [lsort [glob -directory [file join $root tests golden] *.bot]] {file tail $path}]
}
set dir [file tempdir botlish-hir-cache-bench]
try {
    set fingerprint [lindex [time {hir::interchange::Fingerprint $root}] 0]
    puts "fingerprint: [ms $fingerprint] ms (once per process)\n"
    puts "| suite | front end ms | encode ms | encode with traitSource ms | decode ms | through an empty cache ms | cache hit ms | text KB | entry KB |"
    puts "|---|---:|---:|---:|---:|---:|---:|---:|---:|"
    set totals [dict create build 0 hit 0]
    foreach suite $suites {
        set path [file join $root tests golden $suite]
        set build [best {set hir [surface::readProgramFile $path -warnings off -cache ""]}]
        set encode [best {set text [hir::interchange::encode $hir]}]
        set encodeFull [best {hir::interchange::encode $hir -trait-source 1}]
        set decode [best {hir::interchange::decode $text}]
        set cache [file join $dir [file rootname $suite]]
        set miss [best {
            file delete -force $cache
            surface::readProgramFile $path -warnings off -cache $cache
        }]
        set hit [best {surface::readProgramFile $path -warnings off -cache $cache}]
        set entry [lindex [glob -directory $cache *.hirc] 0]
        puts "| $suite | [ms $build] | [ms $encode] | [ms $encodeFull] | [ms $decode] | [ms $miss] | [ms $hit] | [expr {[string length $text] / 1000}] | [expr {[file size $entry] / 1000}] |"
        dict incr totals build $build
        dict incr totals hit $hit
    }
    puts "\nfront end total [ms [dict get $totals build]] ms, cache hits total [ms [dict get $totals hit]] ms"
} finally {
    file delete -force $dir
}
