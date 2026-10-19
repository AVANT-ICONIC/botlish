# fuzzlib.tcl -- the hash-table experiment's differential fuzzer as a
# procedure (tools/fuzz.tcl is its command line; tools/mutate.tcl runs it
# once per mutant). Requires lib.tcl.

# The trace for SEED/KIND/PROFILE: {OPS EXPECTED}, the expected results as
# the backends render a List of them.
proc ht::traceOf {seed kind profile {policy none} {drops drop}} {
    set parts [split [ht::model trace $seed $kind $profile $policy $drops] =]
    set ops [split [string trim [lindex $parts 0]] \n]
    set expected "\[[join [string trim [lindex $parts 1]] {, }]\]"
    return [list $ops $expected]
}

# The capacity policy of implementation IMPL (SPEC.md section 2) as
# tools/model.py takes it: read from the implementation's own header line
# "# policy: NUM/DEN" (or "none").
proc ht::policyOf {impl} {
    variable base
    set path [expr {[file exists $impl] ? $impl : [file join $base impl $impl.bot]}]
    if {[regexp -line {^# policy: (\S+)$} [ht::readFile $path] -> policy]} {
        return $policy
    }
    return none
}

# "nodrop" when implementation IMPL's header says "# drop: no" (it does not
# remove keys), else "drop".
proc ht::dropsOf {impl} {
    variable base
    set path [expr {[file exists $impl] ? $impl : [file join $base impl $impl.bot]}]
    if {[regexp -line {^# drop: no$} [ht::readFile $path]]} {
        return nodrop
    }
    return drop
}

# Runs the fuzzer: OPTIONS is a dict of -impls -keys -profiles -seeds -seed
# -backends -quiet -edits (fuzz.tcl's options). Prints every failure (with
# the command that reproduces it) and returns {CHECKS FAILURES}. With
# -stop 1 it returns at the first failure.
proc ht::fuzz {options} {
    set failures 0
    set checks 0
    set stop [expr {[dict exists $options -stop] && [dict get $options -stop]}]
    foreach impl [dict get $options -impls] {
        foreach kind [dict get $options -keys] {
            # A typed implementation (header line "# key-type: T") takes one
            # key kind only.
            set implPath [expr {[file exists $impl] ? $impl : [file join $ht::base impl $impl.bot]}]
            if {[regexp -line {^# key-type: (\S+)$} [ht::readFile $implPath] -> keyType]
                && [dict get {int int str str point keys::Point} $kind] ne $keyType} continue
            set path [ht::app $impl-$kind trace.bot $impl $kind [dict get $options -edits]]
            if {[catch {ht::compile $path} hir copts]} {
                incr failures
                puts "FAIL $impl $kind: does not compile: [string range $hir 0 400]"
                if {$stop} { return [list $checks $failures] }
                continue
            }
            set cases {}
            set first [dict get $options -seed]
            for {set s $first} {$s < $first + [dict get $options -seeds]} {incr s} {
                foreach profile [dict get $options -profiles] {
                    lappend cases [list $s $profile {*}[ht::traceOf $s $kind $profile [ht::policyOf $impl] [ht::dropsOf $impl]]]
                }
            }
            foreach backend [dict get $options -backends] {
                if {$backend in {cranelift cranelift-generic}} {
                    set results [ht::runNativeMany $hir $backend [lmap c $cases {lindex $c 2}]]
                } else {
                    set results [lmap c $cases {ht::run $hir $backend [lindex $c 2]}]
                }
                foreach c $cases got $results {
                    lassign $c s profile ops expected
                    incr checks
                    if {$got ne $expected} {
                        incr failures
                        puts "FAIL $impl $kind $backend seed $s $profile ([llength $ops] ops)"
                        puts "  expected $expected"
                        puts "  got      [string range $got 0 600]"
                        puts "  rerun: tclsh9.0 audit/hash-table/tools/fuzz.tcl -impls $impl -keys $kind -profiles $profile -seed $s -seeds 1 -backends $backend"
                        if {$stop} { return [list $checks $failures] }
                    }
                }
            }
            if {![dict get $options -quiet]} {
                puts "$impl $kind: [llength $cases] traces x [llength [dict get $options -backends]] backends"
            }
        }
    }
    return [list $checks $failures]
}
