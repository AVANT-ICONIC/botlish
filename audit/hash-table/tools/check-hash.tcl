# check-hash.tcl -- the three implementations of Botlish's hash the
# experiment relies on agree (SPEC.md section 1): the language's own
# (`hash` in a compiled program, on every backend), the oracle's
# reimplementation (tools/model.py's bhash, which makes the colliding keys
# and checks probe diagnostics) and the Rust reference's (which drives the
# reference tables and `std::HashMap` in the stdb columns, so their probe
# sequences are the Botlish tables'). For keys 0..4 of every key kind
# (SPEC.md section 5); exit status 1 on any difference.
#
#   tclsh9.0 audit/hash-table/tools/check-hash.tcl ?-backends LIST?

source [file join [file dirname [file normalize [info script]]] lib.tcl]

set backends {interp compile cranelift cranelift-generic}
if {[lindex $argv 0] eq "-backends"} { set backends [lindex $argv 1] }
set reference [file join $ht::base reference target release hash-table-reference]
set rust [dict create]
foreach line [split [string trim [exec $reference check]] \n] {
    lassign [split $line \t] kind values
    dict set rust $kind $values
}

# The text tools/model.py reads for key I of KIND.
proc keyText {kind i} {
    switch -- $kind {
        int-dense { return $i }
        int-sparse { return [expr {($i * 2654435761) % 4294967296}] }
        int-big { return [expr {$i + 2**80}] }
        str-short { return "id_[format %x $i]" }
        str-medium { return "/usr/share/doc/package-[format %x $i]/index.html" }
        point { return "[expr {$i & 1023}],[expr {$i >> 10}]" }
    }
}

set status 0
try {
    foreach {kind module number model} {
        int-dense int 0 int  int-sparse int 1 int  int-big int 2 int
        str-short str 4 str  str-medium str 5 str  point point 6 point
    } {
        set texts [lmap i {0 1 2 3 4} {keyText $kind $i}]
        set python [split [string trim [ht::model hash $model {*}$texts]] \n]
        set hir [ht::compile [ht::app check-hash-$module hashes.bot listmap $module]]
        set results [list rust [dict get $rust $kind] model $python]
        foreach backend $backends {
            set value [ht::run $hir $backend [list $number]]
            lappend results $backend [string map {, ""} [string trim $value {[]}]]
        }
        set agree 1
        foreach {who values} $results {
            if {$values ne [dict get $rust $kind]} { set agree 0 }
        }
        puts [format "%-11s %s  %s" $kind [expr {$agree ? "agree" : "DIFFER"}] [dict get $rust $kind]]
        if {!$agree} {
            set status 1
            foreach {who values} $results { puts "    $who: $values" }
        }
    }
} finally {
    ht::cleanup
}
exit $status
