# fuzz.tcl -- differential correctness evidence for the hash-table
# experiment's implementations (HASH-TABLE-EXPERIMENT.md, "Correctness").
#
#   tclsh9.0 audit/hash-table/tools/fuzz.tcl ?-impls LIST? ?-keys LIST?
#       ?-profiles LIST? ?-seeds N? ?-seed S? ?-backends LIST? ?-quiet 1?
#       ?-edits {OLD NEW ...}? ?-policy NUM/DEN?
#
# For every implementation (impl/NAME.bot) and key kind (int, str, point):
# one application of drivers/trace.bot with the implementation as
# table.bot, compiled once; then, per seed and profile, a random operation
# trace (tools/model.py trace: put, get, has?, drop and size over a key
# universe chosen to make small tables, growth, forced collisions and edge
# values), run on every backend, and every result compared with the Python
# dict's. Any difference -- from the oracle or between backends -- is a
# failure, printed with the command that reproduces it.
#
# -edits applies text edits to every implementation (tools/mutate.tcl's
# way of running a mutant). -policy NUM/DEN fuzzes each implementation with
# its load policy changed to NUM/DEN (the "Resize policy" variants: header
# and load_num/load_den rewritten). The large profile (thousands of keys)
# is not in the default list: name it. Exit status 1 on any failure.

source [file join [file dirname [file normalize [info script]]] lib.tcl]
source [file join [file dirname [file normalize [info script]]] fuzzlib.tcl]

set options [dict create -impls {lp} -keys {int str point} -profiles {small grow collide edge} \
    -seeds 3 -seed 1 -backends {interp compile cranelift cranelift-generic} -quiet 0 -edits {} -policy {}]
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {![dict exists $options $arg]} { error "unknown option $arg" }
    dict set options $arg [lindex $argv [incr i]]
}

try {
    lassign [ht::fuzz $options] checks failures
} finally {
    ht::cleanup
}
puts "fuzz: $checks checks, $failures failures"
exit [expr {$failures > 0}]
