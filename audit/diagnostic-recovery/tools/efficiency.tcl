# efficiency.tcl -- the diagnostic-efficiency corpus (DIAGNOSTIC-RECOVERY.md).
#
#   tclsh9.0 audit/diagnostic-recovery/tools/efficiency.tcl ?-root DIR?
#       ?-cases NAME,...? ?-format table|data? ?-verbose 0|1?
#
# Each case of audit/diagnostic-recovery/corpus/ is an intentionally invalid
# program (program.bot, and the application modules beside it) and its
# case.txt, which names what is known about it:
#
#   primary LOCATION ?"TEXT"?   a known independent primary error: a
#                               diagnostic at LOCATION (LINE:COLUMN in
#                               program.bot, or FILE:LINE:COLUMN) whose
#                               message contains TEXT, if given
#   fix ?FILE? LINE TEXT        (after a primary) what fixing it changes:
#                               line LINE of FILE (program.bot by default)
#                               becomes TEXT -- fixes never add or remove a
#                               line, so every location stays valid
#   cascade LOCATION            a known dependent diagnostic: one that exists
#                               only because of a primary's recovery
#
# The tool compiles each case as a programmer would, with the main.tcl of the
# checkout DIR (this one by default) -- black-box, its printed "error:"
# lines -- and simulates the edit-compile loop: every primary a compilation
# reports is fixed (its fix lines applied) before the next one; a
# compilation that reports no primary at all (only fallout) costs a round of
# investigation, after which the first primary still open is fixed. It
# reports, per case: the primaries; what the first compilation emits (all
# diagnostics, the primaries among them, the known cascades, and any other
# diagnostic); the compilations it takes until every primary has been
# reported (not counting the last, clean one); and the cascades seen on the
# way. -format data prints the same as a Tcl dict; -verbose 1 also prints
# every compilation's diagnostics.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set options [dict create -root $root -cases "" -format table -verbose 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set corpus [file join [file dirname $here] corpus]
# Every compilation from scratch: no front-end cache; and a UTF-8 locale, as
# AGENTS.md requires (a message may print a non-ASCII character).
unset -nocomplain ::env(BOTLISH_HIR_CACHE)
set ::env(LANG) C.utf8
set ::env(LC_ALL) C.utf8
set main [file join [file normalize [dict get $options -root]] main.tcl]

proc readFile {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation lf
    set text [read $f]
    close $f
    return $text
}

proc writeFile {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

# The case.txt of DIR as {primaries {{file F line L column C text T fixes
# {{FILE LINE TEXT} ...}} ...} cascades {{file F line L column C} ...}}.
proc readCase {dir} {
    set primaries {}
    set cascades {}
    foreach line [split [readFile [file join $dir case.txt]] \n] {
        if {[string trim $line] eq "" || [string match "#*" $line]} continue
        if {[regexp {^primary (\S+)(?: "(.*)")?$} $line -> location text]} {
            lappend primaries [dict merge [Location $location] [dict create text $text fixes {}]]
        } elseif {[regexp {^fix (?:(\S+\.bot) )?(\d+) (.*)$} $line -> file number text]} {
            if {$file eq ""} { set file program.bot }
            set last [lindex $primaries end]
            dict lappend last fixes [list $file $number $text]
            lset primaries end $last
        } elseif {[regexp {^cascade (\S+)$} $line -> location]} {
            lappend cascades [Location $location]
        } else {
            error "[file join $dir case.txt]: cannot read \"$line\""
        }
    }
    return [dict create primaries $primaries cascades $cascades]
}

proc Location {spec} {
    set parts [split $spec :]
    if {[llength $parts] == 2} {
        set parts [linsert $parts 0 program.bot]
    }
    lassign $parts file line column
    return [dict create file $file line $line column $column]
}

# The diagnostics main.tcl (MAIN) prints compiling DIR/program.bot, as
# {file F line L column C message M code C} dicts in printed order. Sets the
# caller's OKVAR, if named, to whether it compiled and ran.
proc compile {main dir {okVar ""}} {
    if {$okVar ne ""} {
        upvar 1 $okVar ok
    }
    set ok [expr {![catch {exec tclsh9.0 $main -backend interp -warnings off [file join $dir program.bot] 2>@1} output]}]
    set diagnostics {}
    foreach line [split $output \n] {
        if {[regexp {^\s+error: (.*?):(\d+):(\d+): (.*) \(((?:CORE|SURFACE)[^()]*)\)$} $line -> file l c message code]} {
            lappend diagnostics [dict create file [file tail $file] line $l column $c message $message code $code]
        }
    }
    return $diagnostics
}

proc At {diagnostic location} {
    foreach key {file line column} {
        if {[dict get $diagnostic $key] ne [dict get $location $key]} {
            return 0
        }
    }
    return 1
}

# The simulation of one case (above).
proc simulate {main dir} {
    set case [readCase $dir]
    set work [file tempdir botlish-diagnostic-efficiency]
    try {
        foreach path [glob -directory $dir *.bot] {
            file copy $path $work
        }
        set open [dict get $case primaries]
        set compilations 0
        set cascadesSeen 0
        set first ""
        while {$open ne {} && $compilations < 20} {
            set diagnostics [compile $main $work]
            incr compilations
            if {[dict get $::options -verbose]} {
                puts "[file tail $dir] compilation $compilations:"
                foreach d $diagnostics {
                    puts "    [dict get $d file]:[dict get $d line]:[dict get $d column] [dict get $d code]: [string range [dict get $d message] 0 100]"
                }
            }
            set revealed {}
            set cascades 0
            set unexpected {}
            foreach d $diagnostics {
                set matched 0
                set index 0
                foreach p $open {
                    if {[At $d $p] && ([dict get $p text] eq "" || [string first [dict get $p text] [dict get $d message]] >= 0)} {
                        lappend revealed $index
                        set matched 1
                    }
                    incr index
                }
                if {$matched} continue
                set known 0
                foreach c [dict get $case cascades] {
                    if {[At $d $c]} { set known 1 }
                }
                if {$known} {
                    incr cascades
                } else {
                    lappend unexpected "[dict get $d line]:[dict get $d column] [dict get $d code]"
                }
            }
            set revealed [lsort -integer -unique $revealed]
            incr cascadesSeen $cascades
            if {$first eq ""} {
                set first [dict create diagnostics [llength $diagnostics] primaries [llength $revealed] \
                    cascades $cascades unexpected $unexpected]
            }
            if {$diagnostics eq {}} {
                # A primary the compiler does not report at all.
                break
            }
            if {$revealed eq {}} {
                # Nothing but fallout: found by investigation.
                set revealed 0
            }
            foreach index $revealed {
                foreach fix [dict get [lindex $open $index] fixes] {
                    lassign $fix file number text
                    set lines [split [readFile [file join $work $file]] \n]
                    lset lines [expr {$number - 1}] $text
                    writeFile [file join $work $file] [join $lines \n]
                }
            }
            foreach index [lreverse $revealed] {
                set open [lreplace $open $index $index]
            }
        }
        set clean 0
        if {$open eq {}} {
            compile $main $work clean
        }
        return [dict create primaries [llength [dict get $case primaries]] first $first \
            compilations $compilations cascades $cascadesSeen clean $clean]
    } finally {
        file delete -force $work
    }
}

set cases [lsort [glob -directory $corpus -type d *]]
if {[dict get $options -cases] ne ""} {
    set wanted [split [dict get $options -cases] ,]
    set cases [lmap c $cases {expr {[file tail $c] in $wanted ? $c : [continue]}}]
}
set results [dict create]
foreach dir $cases {
    dict set results [file tail $dir] [simulate $main $dir]
}
if {[dict get $options -format] eq "data"} {
    puts $results
    exit 0
}
puts [format "%-24s %9s %6s %9s %8s %6s %13s %8s %s" case primaries first: visible cascades other compilations cascades clean]
set totals [dict create primaries 0 diagnostics 0 visible 0 cascades 0 other 0 compilations 0 seen 0]
dict for {name r} $results {
    set f [dict get $r first]
    puts [format "%-24s %9d %6d %9d %8d %6d %13d %8d %s" $name [dict get $r primaries] \
        [dict get $f diagnostics] [dict get $f primaries] [dict get $f cascades] \
        [llength [dict get $f unexpected]] [dict get $r compilations] [dict get $r cascades] \
        [expr {[dict get $r clean] ? "yes" : "NO"}]]
    if {[dict get $f unexpected] ne {}} {
        puts "    other diagnostics: [join [dict get $f unexpected] {; }]"
    }
    dict incr totals primaries [dict get $r primaries]
    dict incr totals diagnostics [dict get $f diagnostics]
    dict incr totals visible [dict get $f primaries]
    dict incr totals cascades [dict get $f cascades]
    dict incr totals other [llength [dict get $f unexpected]]
    dict incr totals compilations [dict get $r compilations]
    dict incr totals seen [dict get $r cascades]
}
puts [format "%-24s %9d %6d %9d %8d %6d %13d %8d" "total ([dict size $results] files)" [dict get $totals primaries] \
    [dict get $totals diagnostics] [dict get $totals visible] [dict get $totals cascades] \
    [dict get $totals other] [dict get $totals compilations] [dict get $totals seen]]
