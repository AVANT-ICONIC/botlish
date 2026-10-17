# diff.tcl -- compare the IR of two profiles (C-HEADER-ARCHAEOLOGY.md,
# "Profile differences").
#
#   tclsh9.0 audit/c-header/tools/diff.tcl PROFILE-A PROFILE-B ?-results-a DIR? ?-results-b DIR? ?-limit N?
#
# Records are matched by kind and name (a struct by kind and tag, a pragma
# or a directive by its text); loc, origin and text are not compared (they
# move with unrelated edits), everything else is. Reports the declarations
# added and removed, and for the ones in both what changed: type, attrs,
# fields, enumerators, link, storage, definition. The macro definitions are
# compared the same way.

set here [file dirname [file normalize [info script]]]
source [file join $here common.tcl]
::chdr::use ir.tcl

proc keyed {records} {
    set d [dict create]
    foreach r $records {
        lassign $r kind name b
        switch -- $kind {
            pragma - directive - static_assert - asm - unsupported { set key [list $kind [dict get $b text]] }
            struct { set key [list [dict get $b kind] $name [dict get $b complete]] }
            enum { set key [list enum $name [dict get $b complete]] }
            default { set key [list $kind $name] }
        }
        if {![dict exists $d $key]} { dict set d $key $b }
    }
    return $d
}

proc compare {label a b limit} {
    set ka [keyed $a]
    set kb [keyed $b]
    set added {}
    set removed {}
    set changed [dict create]
    set examples [dict create]
    dict for {key body} $kb {
        if {![dict exists $ka $key]} { lappend added $key; continue }
        set old [dict get $ka $key]
        foreach facet {type attrs fields enumerators link storage definition inline body expansion form params} {
            set x [expr {[dict exists $old $facet] ? [dict get $old $facet] : ""}]
            set y [expr {[dict exists $body $facet] ? [dict get $body $facet] : ""}]
            if {$x ne $y} {
                dict incr changed $facet
                if {![dict exists $examples $facet] || [llength [dict get $examples $facet]] < $limit} {
                    dict lappend examples $facet [list $key $x $y]
                }
            }
        }
    }
    dict for {key body} $ka {
        if {![dict exists $kb $key]} { lappend removed $key }
    }
    set kinds [dict create]
    foreach k $added { dict incr kinds "added [lindex $k 0]" }
    foreach k $removed { dict incr kinds "removed [lindex $k 0]" }
    puts "== $label"
    puts "  records: [dict size $ka] -> [dict size $kb]"
    foreach {k v} [lsort -stride 2 $kinds] { puts "  $k: $v" }
    foreach {k v} [lsort -stride 2 $changed] { puts "  changed $k: $v" }
    foreach k [lrange $added 0 [expr {$limit - 1}]] { puts "    + [lrange $k 0 1]" }
    foreach k [lrange $removed 0 [expr {$limit - 1}]] { puts "    - [lrange $k 0 1]" }
    dict for {facet list} $examples {
        foreach e $list {
            lassign $e key x y
            puts "    ~ $facet [lrange $key 0 1]"
            puts "        [string range $x 0 300]"
            puts "     -> [string range $y 0 300]"
        }
    }
}

set a [lindex $argv 0]
set b [lindex $argv 1]
set options [dict create -results-a [file join $::chdr::root results $a] -results-b [file join $::chdr::root results $b] -limit 5]
foreach {k v} [lrange $argv 2 end] { dict set options $k $v }
set limit [dict get $options -limit]
puts "IR difference $a -> $b"
foreach f {ir.txt macros.txt system.txt} {
    compare $f [::cir::read [file join [dict get $options -results-a] $f]] \
        [::cir::read [file join [dict get $options -results-b] $f]] $limit
}
