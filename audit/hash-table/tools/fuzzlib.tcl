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
    set path [ht::implPath $impl]
    if {[regexp -line {^# policy: (\S+)$} [ht::readFile $path] -> policy]} {
        return $policy
    }
    return none
}

# "nodrop" when implementation IMPL's header says "# drop: no" (it does not
# remove keys), else "drop".
proc ht::dropsOf {impl} {
    set path [ht::implPath $impl]
    if {[regexp -line {^# drop: no$} [ht::readFile $path]]} {
        return nodrop
    }
    return drop
}

# The path of a copy of implementation IMPL whose load policy is POLICY
# (NUM/DEN): its "# policy:" header and its load_num/load_den functions
# rewritten, the rest unchanged. An implementation without both has no
# policy to vary.
proc ht::policyVariant {impl policy} {
    lassign [split $policy /] num den
    set path [ht::implPath $impl]
    set text [ht::readFile $path]
    foreach {pattern replacement} [list {(?n)^# policy: \S+$} "# policy: $num/$den" \
            {fn load_num\(\) -> int:\n    \d+} "fn load_num() -> int:\n    $num" \
            {fn load_den\(\) -> int:\n    \d+} "fn load_den() -> int:\n    $den"] {
        if {[regsub $pattern $text $replacement text] != 1} {
            error "$impl has no load policy to vary ($pattern)"
        }
    }
    set dir [file join [ht::workDir] policy-$num-$den]
    file mkdir $dir
    set variant [file join $dir [file rootname [file tail $path]].bot]
    ht::writeFile $variant $text
    return $variant
}

# Runs the fuzzer: OPTIONS is a dict of -impls -keys -profiles -seeds -seed
# -backends -quiet -edits -policy (fuzz.tcl's options; -policy NUM/DEN
# fuzzes each implementation's variant with that load policy instead,
# ht::policyVariant). Prints every failure (with the command that
# reproduces it) and returns {CHECKS FAILURES}. With -stop 1 it returns at
# the first failure.
proc ht::fuzz {options} {
    set failures 0
    set checks 0
    set stop [expr {[dict exists $options -stop] && [dict get $options -stop]}]
    set policy [expr {[dict exists $options -policy] ? [dict get $options -policy] : ""}]
    set rerunPolicy [expr {$policy eq "" ? "" : " -policy $policy"}]
    foreach name [dict get $options -impls] {
        set impl [expr {$policy eq "" ? $name : [ht::policyVariant $name $policy]}]
        foreach kind [dict get $options -keys] {
            # A typed implementation (header line "# key-type: T") takes one
            # key kind only.
            set implPath [ht::implPath $impl]
            if {[regexp -line {^# key-type: (\S+)$} [ht::readFile $implPath] -> keyType]
                && [dict get {int int str str point keys::Point} $kind] ne $keyType} continue
            set path [ht::app [file rootname [file tail $implPath]]-$kind trace.bot $impl $kind [dict get $options -edits]]
            if {[catch {ht::compile $path} hir copts]} {
                incr failures
                puts "FAIL $name$rerunPolicy $kind: does not compile: [string range $hir 0 400]"
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
                        puts "FAIL $name$rerunPolicy $kind $backend seed $s $profile ([llength $ops] ops)"
                        puts "  expected $expected"
                        puts "  got      [string range $got 0 600]"
                        puts "  rerun: tclsh9.0 audit/hash-table/tools/fuzz.tcl -impls $name$rerunPolicy -keys $kind -profiles $profile -seed $s -seeds 1 -backends $backend"
                        if {$stop} { return [list $checks $failures] }
                    }
                }
            }
            if {![dict get $options -quiet]} {
                puts "$name$rerunPolicy $kind: [llength $cases] traces x [llength [dict get $options -backends]] backends"
            }
        }
    }
    return [list $checks $failures]
}
