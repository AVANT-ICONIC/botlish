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
#   tclsh9.0 audit/hash-table/tools/summarize.tcl stats RUST-STATS.tsv LOAD
#       the reference's probe lengths (mean, p99, max) per key kind and size at
#       maximum load LOAD, and Botlish's hash against the splitmix64 control
#       (chi-squared over the slots, and empty slots)
#   tclsh9.0 audit/hash-table/tools/summarize.tcl instructions FILE.tsv TAGS ?RUST-IMPL?
#       tools/instructions.tcl's rows, one row per implementation, keys,
#       size and mode, one column per tag, with the reference's RUST-IMPL
#       (tag "rust") and the first tag's ratio to it
#   tclsh9.0 audit/hash-table/tools/summarize.tcl membership FILE.tsv DOMAIN MODE ?COLUMN?
#       tools/membership.tcl's rows for one domain and mode (hit/miss): one
#       row per strategy, one column per set size K; COLUMN is ns (default:
#       ns per query), code (machine-code bytes), data (data elements) or
#       generate (compile-time milliseconds the generator spent)
#   tclsh9.0 audit/hash-table/tools/summarize.tcl ladder FILE.tsv TAGS ?RUST.tsv RUST-IMPL?
#       tools/ladder.tcl's rows: one row per implementation, keys, size and
#       mode, one column per tag (tree), optionally the Rust reference's
#       RUST-IMPL beside them
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
    stats {
        lassign $argv _ path load
        set probes [dict create]
        set dist [dict create]
        foreach r [readRows $path] {
            switch -- [lindex $r 0] {
                probes {
                    lassign $r _ kind n l impl slots lf _ hmean _ _ hp99 hmax _ mmean _ _ mp99 mmax
                    if {$l eq $load} { dict set probes [list $kind $n $impl] [list $slots $lf $hmean $hp99 $hmax $mmean $mp99 $mmax] }
                }
                distribution {
                    lassign $r _ kind n slots lf _ chi _ empty _ mchi _ mempty _ khit _ kmiss
                    dict set dist [list $kind $n $slots] [list $chi $empty $mchi $mempty $khit $kmiss]
                }
            }
        }
        puts "| keys | n | slots | load | lp hit mean / p99 / max | lp miss mean / p99 / max | rh miss mean / p99 / max | chain hit / miss mean | chi2 (control) | empty (control) | Knuth lp hit / miss |"
        puts "|---|---:|---:|---:|---|---|---|---|---|---|---|"
        foreach key [lsort -index 1 -integer [lsort -index 0 [lsort -unique [lmap k [dict keys $probes] {lrange $k 0 1}]]]] {
            lassign $key kind n
            if {![dict exists $probes [list $kind $n lp]]} continue
            lassign [dict get $probes [list $kind $n lp]] slots lf hmean hp99 hmax mmean mp99 mmax
            set row "| $kind | $n | $slots | $lf | [fmt $hmean] / $hp99 / $hmax | [fmt $mmean] / $mp99 / $mmax |"
            if {[dict exists $probes [list $kind $n rh]]} {
                lassign [dict get $probes [list $kind $n rh]] _ _ _ _ _ rmean rp99 rmax
                append row " [fmt $rmean] / $rp99 / $rmax |"
            } else { append row " |" }
            if {[dict exists $probes [list $kind $n chain]]} {
                lassign [dict get $probes [list $kind $n chain]] _ _ chit _ _ cmiss
                append row " [fmt $chit] / [fmt $cmiss] |"
            } else { append row " |" }
            if {[dict exists $dist [list $kind $n $slots]]} {
                lassign [dict get $dist [list $kind $n $slots]] chi empty mchi mempty khit kmiss
                append row " [format %.0f $chi] ([format %.0f $mchi]) | $empty ($mempty) | [fmt $khit] / [fmt $kmiss] |"
            } else { append row " | | |" }
            puts $row
        }
    }
    membership {
        lassign $argv _ path domain mode column
        if {$column eq ""} { set column ns }
        set index [dict get {ns 6 code 7 data 8 generate 9} $column]
        set cells [dict create]
        set strategies {}
        foreach r [readRows $path] {
            lassign $r d strategy k m
            if {$d ne $domain || $m ne $mode} continue
            if {$strategy ni $strategies} { lappend strategies $strategy }
            dict lappend cells [list $strategy $k] [lindex $r $index]
        }
        puts -nonewline [render $cells $strategies]
    }
    instructions {
        lassign $argv _ path tags rimpl
        set cells [dict create]
        set configs {}
        foreach r [readRows $path] {
            lassign $r tag impl k n m per
            if {$tag eq "rust"} { dict set cells [list rust $impl $k $n $m] $per; continue }
            set config [list $impl $k $n $m]
            if {$config ni $configs} { lappend configs $config }
            dict set cells [list $tag {*}$config] $per
        }
        set head "| impl | keys | n | mode | [join $tags { | }] |"
        set rule "|---|---|---:|---|[string repeat ---:| [llength $tags]]"
        if {$rimpl ne ""} {
            append head " Rust $rimpl | [lindex $tags 0] / Rust | [lindex $tags end] / Rust |"
            append rule ---:|---:|---:|
        }
        puts $head
        puts $rule
        foreach config [lsort -index 2 -integer [lsort -index 1 [lsort -index 0 $configs]]] {
            lassign $config impl k n m
            set row "| $impl | $k | $n | $m |"
            foreach tag $tags {
                set key [list $tag {*}$config]
                append row " [expr {[dict exists $cells $key] ? [format %.0f [dict get $cells $key]] : {}}] |"
            }
            if {$rimpl ne ""} {
                set rkey [list rust $rimpl $k $n $m]
                if {[dict exists $cells $rkey]} {
                    set rv [dict get $cells $rkey]
                    append row " [format %.0f $rv] |"
                    foreach tag [list [lindex $tags 0] [lindex $tags end]] {
                        set key [list $tag {*}$config]
                        append row " [expr {[dict exists $cells $key] && $rv > 0 ? [format %.1f [expr {[dict get $cells $key] / $rv}]] : {}}] |"
                    }
                } else { append row " | | |" }
            }
            puts $row
        }
    }
    ladder {
        lassign $argv _ path tags rpath rimpl
        set cells [dict create]
        set configs {}
        foreach r [readRows $path] {
            lassign $r tag impl k backend n m _ _ _ per
            set config [list $impl $k $n $m]
            if {$config ni $configs} { lappend configs $config }
            dict lappend cells [list $tag {*}$config] $per
        }
        set rust [dict create]
        if {$rpath ne ""} {
            foreach r [readRows $rpath] {
                lassign $r impl k m n _ _ _ ns
                if {$impl eq $rimpl} { dict lappend rust [list $k $n $m] $ns }
            }
        }
        set head "| impl | keys | n | mode | [join $tags { | }] |"
        set rule "|---|---|---:|---|[string repeat ---:| [llength $tags]]"
        if {$rpath ne ""} { append head " Rust $rimpl |"; append rule ---:| }
        puts $head
        puts $rule
        foreach config [lsort -index 2 -integer [lsort -index 1 [lsort -index 0 $configs]]] {
            lassign $config impl k n m
            set row "| $impl | $k | $n | $m |"
            foreach tag $tags {
                set key [list $tag {*}$config]
                append row " [expr {[dict exists $cells $key] ? [fmt [median [dict get $cells $key]]] : {}}] |"
            }
            if {$rpath ne ""} {
                set key [list $k $n $m]
                append row " [expr {[dict exists $rust $key] ? [fmt [median [dict get $rust $key]]] : {}}] |"
            }
            puts $row
        }
    }
    default {
        puts stderr "usage: summarize.tcl sizes|rust|ratio|mixed|ladder ..."
        exit 2
    }
}
