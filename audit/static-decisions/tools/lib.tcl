# lib.tcl -- shared procedures of the static-decision audit tools
# (STATIC-COMPILE.md, "Decision economics"): compile one program under a
# given scheduler and reduce the result to what the schedulers must agree on.
#
#   sdCompile SCHEDULER SOURCE ?NAME?   => record (sdRecord) of SOURCE (text)
#   sdCompileFile SCHEDULER PATH        => record of the program file PATH
#   sdDiff A B ?LEGACY?                 => "" or the first difference

if {![info exists ::sdRoot]} {
    set ::sdRoot [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
}

# The record of one compilation: the decided sites (key -> canonical
# outcome), the program's diagnostics, the decided program's HIR text, the
# static decision economics, the front end's time. A compilation that raises
# (a parse error, an internal failure) records its error instead.
proc sdRecord {hir us} {
    set sites [dict create]
    dict for {key site} [hir::static::sites $hir] {
        set outcome [list [dict get $site outcome]]
        if {[dict get $site outcome] eq "rejected"} {
            set d [dict get $site diagnostic]
            set origin [dict get $d origin]
            lappend outcome [dict get $d kind] [dict get $origin line] [dict get $origin column] \
                [lmap r [dict get $d related] {list [dict get $r line] [dict get $r column]}] \
                [dict get $d message]
        }
        dict set sites $key $outcome
    }
    set diagnostics [lmap d [dict get $hir diagnostics] {
        list [dict get $d kind] [dict get $d message]
    }]
    set stats [expr {[dict exists $hir staticStats] ? [dict get $hir staticStats] : {}}]
    return [dict create sites $sites parents [SdParents $hir] diagnostics $diagnostics \
        hir [hir::format $hir] stats $stats us $us error ""]
}

# Site key -> the key of the site whose body holds it ("" for none), from
# the decided program's sites (hir::static::sites has no parents: the
# origins' nesting is recomputed).
proc SdParents {hir} {
    set spans {}
    dict for {key site} [hir::static::sites $hir] {
        set o [dict get $site origin]
        lappend spans [list $key [dict get $o file] [dict get $o start] [dict get $o end]]
    }
    set parents [dict create]
    foreach s $spans {
        lassign $s key file start end
        set best ""
        set bestStart -1
        foreach t $spans {
            lassign $t k f s2 e2
            if {$k eq $key || $f ne $file} continue
            if {$s2 <= $start && $end <= $e2 && ($s2 < $start || $e2 > $end) && $s2 > $bestStart} {
                set best $k
                set bestStart $s2
            }
        }
        dict set parents $key $best
    }
    return $parents
}

proc sdCompile {scheduler source {name <input>}} {
    set saved $hir::static::scheduler
    set hir::static::scheduler $scheduler
    try {
        set t0 [clock microseconds]
        if {[catch {surface::compile $source $name -strict 0 -warnings off} hir options]} {
            return [dict create error [list [dict get $options -errorcode] $hir] us 0]
        }
        return [sdRecord $hir [expr {[clock microseconds] - $t0}]]
    } finally {
        set hir::static::scheduler $saved
    }
}

proc sdCompileFile {scheduler path} {
    set saved $hir::static::scheduler
    set hir::static::scheduler $scheduler
    try {
        set t0 [clock microseconds]
        if {[catch {surface::readProgramFile $path -strict 0 -warnings off} hir options]} {
            return [dict create error [list [dict get $options -errorcode] $hir] us 0]
        }
        return [sdRecord $hir [expr {[clock microseconds] - $t0}]]
    } finally {
        set hir::static::scheduler $saved
    }
}

# The sites of RECORD with every site inside a rejected site marked
# `discarded`: its body is gone with the rejected one, whatever label the
# scheduler left on it (the legacy scheduler may leave one undecided that
# the sequential order accepts before rejecting its outer site).
proc SdNormalized {record} {
    set sites [dict get $record sites]
    set parents [dict get $record parents]
    dict for {key outcome} $sites {
        set p [dict get $parents $key]
        while {$p ne ""} {
            if {[lindex [dict get $sites $p] 0] eq "rejected"} {
                dict set sites $key discarded
                break
            }
            set p [dict get $parents $p]
        }
    }
    return $sites
}

# The first difference between records A and B, or "". With LEGACY, the
# labels of discarded sites are not compared (SdNormalized).
proc sdDiff {a b {legacy 0}} {
    if {[dict get $a error] ne "" || [dict get $b error] ne ""} {
        if {[dict get $a error] ne [dict get $b error]} {
            return "errors differ: [string range [dict get $a error] 0 300] / [string range [dict get $b error] 0 300]"
        }
        return ""
    }
    set sa [expr {$legacy ? [SdNormalized $a] : [dict get $a sites]}]
    set sb [expr {$legacy ? [SdNormalized $b] : [dict get $b sites]}]
    if {$legacy} {
        # The legacy scheduler judges a site in whatever build its batching
        # reached, so a message naming internal ids (`block(e12)`) carries
        # that build's numbering (hir::static::InternalIds): compare
        # them with the ids blanked.
        set sa [dict map {key outcome} $sa {regsub -all {\m[ebsyt][0-9]+\M} $outcome #}]
        set sb [dict map {key outcome} $sb {regsub -all {\m[ebsyt][0-9]+\M} $outcome #}]
    }
    if {[lsort [dict keys $sa]] ne [lsort [dict keys $sb]]} {
        return "site sets differ"
    }
    dict for {key outcome} $sa {
        if {$outcome ne [dict get $sb $key]} {
            return "site $key: $outcome / [dict get $sb $key]"
        }
    }
    if {[dict get $a diagnostics] ne [dict get $b diagnostics]} {
        return "program diagnostics differ: [lindex [dict get $a diagnostics] 0] / [lindex [dict get $b diagnostics] 0]"
    }
    set ha [dict get $a hir]
    set hb [dict get $b hir]
    if {$legacy && $ha ne $hb} {
        # Likewise inside the decided program's String constants (a reified
        # message is one).
        set ha [SdBlankConstIds $ha]
        set hb [SdBlankConstIds $hb]
    }
    if {$ha ne $hb} {
        set la [split $ha \n]
        set lb [split $hb \n]
        set i 0
        foreach x $la y $lb {
            if {$x ne $y} {
                return "decided HIR differs at line [expr {$i + 1}]: $x / $y"
            }
            incr i
        }
        return "decided HIR differs"
    }
    foreach r [list $a $b] {
        if {[dict exists $r stats mispredicted] && [dict get $r stats mispredicted] ne {}} {
            return "mispredicted [dict get $r stats mispredicted]"
        }
    }
    return ""
}

# HIR text TEXT with internal ids blanked inside every String constant line.
proc SdBlankConstIds {text} {
    return [join [lmap line [split $text \n] {
        if {[string match "* const str *" $line]} {
            set head [string range $line 0 [expr {[string first " const str " $line] + 10}]]
            set tail [string range $line [expr {[string first " const str " $line] + 11}] end]
            string cat $head [regsub -all {\m[ebsyt][0-9]+\M} $tail #]
        } else {
            set line
        }
    }] \n]
}

# "ROUNDS/BUILDS" of RECORD's economics.
proc sdEconomics {record} {
    if {[dict get $record error] ne "" || [dict get $record stats] eq {}} {
        return "-"
    }
    set s [dict get $record stats]
    return "[dict get $s rounds]/[dict get $s builds]"
}
