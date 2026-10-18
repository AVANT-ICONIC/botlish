# summarize.tcl -- Markdown tables from the hash-table experiment's results
# (audit/hash-table/results/*.tsv, written by tools/run-all.tcl), for
# HASH-TABLE-EXPERIMENT.md.
#
#   tclsh9.0 audit/hash-table/tools/summarize.tcl sizes FILE.tsv KEYS MODE ?IMPLS?
#       ns per operation: one row per implementation, one column per size
#   tclsh9.0 audit/hash-table/tools/summarize.tcl rust FILE.tsv KEYS MODE ?IMPLS?
#       the same for the Rust reference's rows
#   tclsh9.0 audit/hash-table/tools/summarize.tcl ratio BOTLISH.tsv RUST.tsv KEYS MODE PAIRS
#       Botlish / Rust per size, PAIRS a list of {botlish-impl rust-impl}
#   tclsh9.0 audit/hash-table/tools/summarize.tcl mixed FILE.tsv RUST-MIXED.tsv
#       the mixed workloads, Botlish against the Rust reference
#
# A value is the median of the rows that match (several runs append rows).

proc readRows {path} {
    set rows {}
    set f [open $path r]
    while {[gets $f line] >= 0} {
        if {$line eq "" || [string match #* $line]} continue
        lappend rows [split $line \t]
    }
    close $f
    return $rows
}

proc median {values} {
    set values [lsort -real $values]
    set n [llength $values]
    if {$n == 0} { return "" }
    if {$n % 2} { return [lindex $values [expr {$n / 2}]] }
    return [expr {([lindex $values [expr {$n / 2 - 1}]] + [lindex $values [expr {$n / 2}]]) / 2.0}]
}

proc fmt {v} {
    if {$v eq ""} { return "" }
    if {$v >= 10000} { return [format %.0f $v] }
    if {$v >= 100} { return [format %.0f $v] }
    if {$v >= 10} { return [format %.1f $v] }
    return [format %.2f $v]
}

# {impl size} -> median ns per op, for Botlish TSV rows
#   tag impl keys backend n mode m reps best-us per-op-ns checksum
proc botlishTable {rows keys mode} {
    set cells [dict create]
    foreach r $rows {
        lassign $r tag impl k backend n m _ _ _ per
        if {$k ne $keys || $m ne $mode} continue
        dict lappend cells [list $impl $n] $per
    }
    return $cells
}

# The same for Rust rows:  impl kind mode n m reps load ns checksum
proc rustTable {rows keys mode} {
    set cells [dict create]
    foreach r $rows {
        lassign $r impl k m n _ _ _ ns
        if {$k ne $keys || $m ne $mode} continue
        dict lappend cells [list $impl $n] $ns
    }
    return $cells
}

proc render {cells impls} {
    set sizes {}
    set seen {}
    dict for {key _} $cells {
        lassign $key impl n
        if {$n ni $sizes} { lappend sizes $n }
        if {$impl ni $seen} { lappend seen $impl }
    }
    set sizes [lsort -integer $sizes]
    if {$impls eq ""} { set impls $seen }
    set out "| impl | [join $sizes { | }] |\n|---|[string repeat ---:| [llength $sizes]]\n"
    foreach impl $impls {
        set row "| $impl |"
        foreach n $sizes {
            set key [list $impl $n]
            append row " [expr {[dict exists $cells $key] ? [fmt [median [dict get $cells $key]]] : {}}] |"
        }
        append out $row\n
    }
    return $out
}

lassign $argv command
switch -- $command {
    sizes {
        lassign $argv _ path keys mode impls
        puts -nonewline [render [botlishTable [readRows $path] $keys $mode] $impls]
    }
    rust {
        lassign $argv _ path keys mode impls
        puts -nonewline [render [rustTable [readRows $path] $keys $mode] $impls]
    }
    ratio {
        lassign $argv _ bpath rpath keys mode pairs
        set b [botlishTable [readRows $bpath] $keys $mode]
        set r [rustTable [readRows $rpath] $keys $mode]
        set cells [dict create]
        foreach pair $pairs {
            lassign $pair bi ri
            dict for {key values} $b {
                lassign $key impl n
                if {$impl ne $bi || ![dict exists $r [list $ri $n]]} continue
                set rv [median [dict get $r [list $ri $n]]]
                if {$rv <= 0} continue
                dict lappend cells [list "$bi/$ri" $n] [expr {[median $values] / $rv}]
            }
        }
        puts -nonewline [render $cells {}]
    }
    mixed {
        lassign $argv _ bpath rpath
        set rust [dict create]
        foreach r [readRows $rpath] {
            lassign $r impl work size ns sum
            dict lappend rust [list $impl $work $size] [expr {$ns / 1000.0}]
        }
        set rows [dict create]
        foreach r [readRows $bpath] {
            lassign $r tag impl work size us sum
            dict lappend rows [list $impl $work $size] $us
        }
        puts "| workload | size | impl | Botlish us | Rust lp us | Rust std us | Botlish / Rust lp |"
        puts "|---|---:|---|---:|---:|---:|---:|"
        foreach key [lsort -index 1 [dict keys $rows]] {
            lassign $key impl work size
            set bus [median [dict get $rows $key]]
            set rk [list lp [string trimright $work 2] $size]
            set lp [expr {[dict exists $rust $rk] ? [median [dict get $rust $rk]] : ""}]
            set sk [list std [string trimright $work 2] $size]
            set std [expr {[dict exists $rust $sk] ? [median [dict get $rust $sk]] : ""}]
            set ratio [expr {$lp ne "" && $lp > 0 ? [format %.1f [expr {$bus / $lp}]] : ""}]
            puts "| $work | $size | $impl | [fmt $bus] | [fmt $lp] | [fmt $std] | $ratio |"
        }
    }
    default {
        puts stderr "usage: summarize.tcl sizes|rust|ratio|mixed ..."
        exit 2
    }
}
