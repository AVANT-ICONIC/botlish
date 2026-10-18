# mutate.tcl -- mutation evidence for the hash-table experiment's
# implementations (HASH-TABLE-EXPERIMENT.md, "Correctness").
#
#   tclsh9.0 audit/hash-table/tools/mutate.tcl ?-jobs N? ?-backends LIST?
#       ?-seeds N? ?-file MUTANTS? ?-timeout S? ?NAME ...?
#
# For every mutant of audit/hash-table/tools/mutants.txt (or the NAMEs
# given) -- one or more text edits of an implementation, impl/IMPL.bot --
# the differential fuzzer (tools/fuzzlib.tcl) runs the mutated
# implementation on every key kind and profile. A mutant is killed when a
# result differs from the Python oracle's or between backends, or the
# mutated program stops compiling. Every mutant must still apply (each
# edit's text occurs exactly once) and be killed; the unmutated
# implementations must pass, so a kill means the mutation.
#
# A mutant whose run does not finish within -timeout seconds (default 900;
# a baseline takes well under a minute) is killed too: it made the table
# loop forever. Prints one line per mutant: killed, SURVIVED or NOT APPLIED. Exit status
# 1 if any survived or did not apply, or a baseline failed. Each mutant runs
# in a child process (-jobs at a time), each with its own scratch directory.

set here [file dirname [file normalize [info script]]]
source [file join $here lib.tcl]
source [file join $here fuzzlib.tcl]

set options [dict create -jobs [exec nproc] -backends {compile cranelift} -seeds 2 -one "" -file [file join $here mutants.txt] \
    -timeout 900]
set names {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {[string match -* $arg]} {
        if {![dict exists $options $arg]} { error "unknown option $arg" }
        dict set options $arg [lindex $argv [incr i]]
    } else {
        lappend names $arg
    }
}

# The mutants of PATH: a list of {NAME DESCRIPTION EDITS}, EDITS a list of
# {FILE OLD NEW} (the format of every audit's mutants.txt).
proc readMutants {path} {
    set mutants {}
    set name ""
    set state outside
    foreach line [split [ht::readFile $path] \n] {
        switch -- $state {
            outside {
                if {[regexp {^@@ (\S+) (.*)$} $line -> n d]} {
                    if {$name ne ""} { lappend mutants [list $name $description $edits] }
                    set name $n
                    set description $d
                    set edits {}
                } elseif {[regexp {^## (\S+)$} $line -> file]} {
                    set current $file
                } elseif {$line eq "<<<<"} {
                    set state old
                    set old {}
                }
            }
            old {
                if {$line eq "===="} {
                    set state new
                    set new {}
                } else {
                    lappend old $line
                }
            }
            new {
                if {$line eq ">>>>"} {
                    lappend edits [list $current [join $old \n] [join $new \n]]
                    set state outside
                } else {
                    lappend new $line
                }
            }
        }
    }
    if {$name ne ""} { lappend mutants [list $name $description $edits] }
    return $mutants
}

# The implementation a mutant edits, and its {OLD NEW} edit list; throws
# when it edits anything but one impl/ file or an edit does not apply.
proc mutantImpl {edits} {
    set impl ""
    set pairs {}
    foreach edit $edits {
        lassign $edit file old new
        if {![regexp {^impl/([A-Za-z0-9_]+)\.bot$} $file -> name]} {
            throw {HT MUTANT} "a mutant edits impl/NAME.bot files only, not $file"
        }
        if {$impl ne "" && $impl ne $name} {
            throw {HT MUTANT} "a mutant edits one implementation"
        }
        set impl $name
        lappend pairs $old $new
    }
    ht::applyEdits [ht::readFile [file join $::ht::base impl $impl.bot]] $pairs $impl
    return [list $impl $pairs]
}

proc fuzzOptions {impl pairs} {
    return [dict create -impls $impl -keys {int str point} -profiles {small grow collide edge} \
        -seeds [dict get $::options -seeds] -seed 1 -backends [dict get $::options -backends] \
        -quiet 1 -edits $pairs -stop 1]
}

set mutants [readMutants [dict get $options -file]]

# A child: run one mutant (or "baseline IMPL") and print its verdict line.
if {[dict get $options -one] ne ""} {
    set one [dict get $options -one]
    try {
        if {[lindex $one 0] eq "baseline"} {
            lassign [ht::fuzz [fuzzOptions [lindex $one 1] {}]] checks failures
            puts "RESULT [expr {$failures ? "FAILED" : "passed"}]"
        } else {
            set m [lsearch -inline -index 0 $mutants $one]
            lassign [mutantImpl [lindex $m 2]] impl pairs
            lassign [ht::fuzz [fuzzOptions $impl $pairs]] checks failures
            puts "RESULT [expr {$failures ? "killed" : "SURVIVED"}]"
        }
    } on error {message} {
        puts "RESULT ERROR [string range $message 0 200]"
    } finally {
        ht::cleanup
    }
    exit 0
}

# The parent: the baselines and every selected mutant, -jobs at a time.
set jobs {}
set impls {}
foreach m $mutants {
    lassign $m name description edits
    if {$names ne {} && $name ni $names} continue
    if {[catch {mutantImpl $edits} result]} {
        lappend jobs [list $name "NOT APPLIED: $result"]
        continue
    }
    lappend jobs [list $name ""]
    set impl [lindex $result 0]
    if {$impl ni $impls} { lappend impls $impl }
}
set queue [concat [lmap i $impls {list "baseline $i" ""}] $jobs]
set running [dict create]
set exit 0
set killed 0
set total 0
proc report {name verdict} {
    global exit killed total
    if {[string match "baseline *" $name]} {
        puts [format "%-40s %s" $name $verdict]
        if {$verdict ne "passed"} { set exit 1 }
        return
    }
    incr total
    puts [format "%-40s %s" $name $verdict]
    if {$verdict eq "killed"} { incr killed } else { set exit 1 }
}
while {[llength $queue] || [dict size $running]} {
    while {[llength $queue] && [dict size $running] < [dict get $options -jobs]} {
        set queue [lassign $queue job]
        lassign $job name preset
        if {$preset ne ""} {
            report $name $preset
            continue
        }
        # GNU timeout signals the child's whole process group, its native
        # runs included.
        set pipe [open |[list timeout -k 10 [dict get $options -timeout] [info nameofexecutable] [info script] -one $name -file [dict get $options -file] \
            -backends [dict get $options -backends] -seeds [dict get $options -seeds] 2>@1] r]
        dict set running $pipe $name
    }
    # Wait for the oldest child (the others keep running meanwhile).
    if {[dict size $running]} {
        set pipe [lindex [dict keys $running] 0]
        set output [read $pipe]
        set status 0
        if {[catch {close $pipe} message closeOptions]} {
            set code [dict get $closeOptions -errorcode]
            if {[lindex $code 0] eq "CHILDSTATUS"} { set status [lindex $code 2] }
        }
        # timeout exits 124 (TERM) or 137 (KILL after the grace period).
        if {$status in {124 137}} {
            set verdict "killed (did not finish within [dict get $options -timeout] s)"
        } else {
            set verdict "ERROR (no verdict)"
        }
        regexp -line {^RESULT (.*)$} $output -> verdict
        report [dict get $running $pipe] $verdict
        dict unset running $pipe
    }
}
puts "mutants: $killed of $total killed"
exit $exit
