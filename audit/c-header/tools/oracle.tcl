# oracle.tcl -- check the parser's reading of a profile against the C
# compiler (C-HEADER-ARCHAEOLOGY.md, "The compiler oracle").
#
#   tclsh9.0 audit/c-header/tools/oracle.tcl PROFILE ?-out FILE?
#
# Renders every IR record of results/PROFILE/ir.txt back to C and has the
# configured compiler check it after the profile's own headers, in one
# translation unit of standard C11:
#
#   function   a redeclaration     RESULT NAME(PARAMS);   (conflicting
#              types are an error)
#   typedef    a redefinition      typedef TYPE NAME;     (C11: must be the
#              same type)
#   variable   a redeclaration     extern TYPE NAME;
#   field      _Static_assert(_Generic(&((TAG *)0)->FIELD, TYPE *: 1,
#              default: 0)) -- the field's exact type, qualifiers and array
#              bounds included
#   enumerator _Static_assert(NAME == VALUE) for every value the parser
#              computed
#
# A check the compiler rejects is a parser error (or a rendering one). The
# script also plants one wrong check of each kind and requires the compiler
# to reject it, so a silently accepting oracle cannot pass. The last line is
# "checks N rejected R planted-caught P/K".

set here [file dirname [file normalize [info script]]]
source [file join $here common.tcl]
::chdr::use toolchain.tcl
::chdr::use cdecl.tcl
::chdr::use ir.tcl

proc main {argv} {
    set name [lindex $argv 0]
    set options [dict create -out "" -results ""]
    foreach {k v} [lrange $argv 1 end] { dict set options $k $v }
    set profile [::chdr::profile $name]
    set results [dict get $options -results]
    if {$results eq ""} { set results [file join $::chdr::root results $name] }
    set records [::cir::read [file join $results ir.txt]]
    set system [::cir::read [file join $results system.txt]]
    # Library macros named like a declaration: undefined before its check
    # (the check is of the declaration, not of the macro layer above it).
    set shadows [dict create]
    foreach m [::cir::read [file join $results macros.txt]] {
        if {![dict get [lindex $m 2] undefined]} { dict set shadows [lindex $m 1] [dict get [lindex $m 2] form] }
    }
    set undefs [dict create]
    set sourceRoot [file dirname [file normalize [file join [::chdr::sourcesDir] [dict get $profile library] .x]]]
    set abs {}
    foreach d [dict get $profile includeDirs] { lappend abs [file join $sourceRoot $d] }
    set tcProfile [dict replace $profile includeDirs $abs flags [concat [dict get $profile flags] -std=c11 -w]]
    set config [::chdr::toolchain::config]

    # Names for anonymous tags: the typedef that names one directly.
    set names [dict create]
    foreach r [concat $system $records] {
        lassign $r kind n body
        if {$kind eq "typedef"} {
            set t [dict get $body type]
            if {[lindex $t 0] in {struct union enum} && [string match anon@* [lindex $t 1]]} {
                set key "[lindex $t 0] [lindex $t 1]"
                if {![dict exists $names $key]} { dict set names $key $n }
            }
        }
    }
    set checks {}
    set skipped [dict create]
    foreach r $records {
        lassign $r kind n body
        if {[dict get $body origin] ni {public bundled}} continue
        switch -- $kind {
            function {
                # "(NAME)": a same-named function-like macro must not
                # rewrite the redeclaration.
                set c [Render [dict get $body type] "($n)" $names]
                if {$c eq ""} { dict incr skipped "function with an unnamed anonymous tag"; continue }
                set storage [expr {[dict get $body storage] eq "static" ? "static " : ""}]
                set pre ""
                if {[dict exists $shadows $n]} {
                    set pre "#undef $n\n"
                    dict incr undefs "function named like a [dict get $shadows $n]-like macro (#undef before the check)"
                }
                lappend checks [list function $n "$pre$storage$c;" [Known $body]]
            }
            typedef {
                set c [Render [dict get $body type] $n $names]
                if {$c eq ""} { dict incr skipped "typedef of an unnamed anonymous tag"; continue }
                # A typedef naming an anonymous tag is its own name: re-typedef
                # through the name is trivially the same; still a check.
                lappend checks [list typedef $n "typedef $c;" [Known $body]]
            }
            variable {
                if {[dict get $body storage] ne "extern"} { dict incr skipped "non-extern variable"; continue }
                set c [Render [dict get $body type] $n $names]
                if {$c eq ""} { dict incr skipped "variable with an unnamed anonymous tag"; continue }
                lappend checks [list variable $n "extern $c;" [Known $body]]
            }
            struct {
                if {![dict get $body complete]} continue
                set key "[dict get $body kind] $n"
                if {[string match anon@* $n]} {
                    if {![dict exists $names $key]} { dict incr skipped "fields of an unnamed anonymous struct"; continue }
                    set tagType [dict get $names $key]
                } else {
                    set tagType $key
                }
                foreach f [dict get $body fields] {
                    lassign $f fname ftype bits
                    if {$fname eq ""} { dict incr skipped "anonymous member"; continue }
                    if {$bits ne ""} {
                        # A bitfield has no address: check its declared type
                        # through a promotion-free _Generic on the member.
                        dict incr skipped "bitfield"
                        continue
                    }
                    set pt [Render [list ptr $ftype] "" $names]
                    if {$pt eq ""} { dict incr skipped "field with an unnamed anonymous tag"; continue }
                    lappend checks [list field "$n.$fname" \
                        "_Static_assert(_Generic(&((($tagType *)0)->$fname), $pt: 1, default: 0), \"$n.$fname\");" \
                        [Known [dict create attrs [lindex $f 3]]]]
                }
            }
            enum {
                if {![dict get $body complete]} continue
                foreach e [dict get $body enumerators] {
                    lassign $e ename form value
                    if {$value eq ""} { dict incr skipped "enumerator value not computed"; continue }
                    lappend checks [list enumerator $ename "_Static_assert(($ename) == ($value), \"$ename\");"]
                }
            }
        }
    }
    # Planted wrong checks: one per kind, each must be rejected.
    set planted {}
    foreach kind {function typedef variable field enumerator} {
        set c [lsearch -inline -index 0 $checks $kind]
        if {$c eq ""} continue
        lassign $c k n text
        switch -- $kind {
            function { set wrong "struct botlish_oracle_wrong *${n}(void);" }
            typedef { set wrong "typedef struct botlish_oracle_wrong *$n;" }
            variable { set wrong "extern struct botlish_oracle_wrong *$n;" }
            field { set wrong [regsub {, ([^:]*): 1, default} $text {, struct botlish_oracle_wrong *: 1, default}] }
            enumerator { set wrong [regsub {== \(([^)]*)\)} $text {== (\1 + 1)}] }
        }
        lappend planted [list $kind $n $wrong]
    }
    set prelude ""
    foreach h [dict get $profile entry] { append prelude "#include <$h>\n" }
    set prelude "#include <stddef.h>\n$prelude"
    # The real checks, in one translation unit; then each planted one alone.
    # One check per line (a #undef on its own line before it); a line ->
    # check map.
    set source $prelude
    set ln [llength [split $prelude \n]]
    set lineOf [dict create]
    set i 0
    foreach c $checks {
        foreach l [split [lindex $c 2] \n] {
            append source "$l\n"
            dict set lineOf $ln $i
            incr ln
        }
        incr i
    }
    lassign [::chdr::toolchain::compile $config $tcProfile $source] ok stderr command
    # An error is attributed to the check whose line it names, directly or
    # in a following "in expansion of macro" note.
    set rejected [dict create]
    set pending ""
    set unattributed 0
    foreach line [split $stderr \n] {
        if {[regexp {^([^:]+):([0-9]+):[0-9]+: (?:fatal )?error: (.*)$} $line -> file eln msg]} {
            if {$pending ne ""} { incr unattributed }
            set pending $msg
            if {[file tail $file] eq "probe.c" && [dict exists $lineOf $eln]} {
                dict lappend rejected [dict get $lineOf $eln] $msg
                set pending ""
            }
        } elseif {$pending ne "" && [regexp {probe\.c:([0-9]+):[0-9]+: note:} $line -> nln] && [dict exists $lineOf $nln]} {
            dict lappend rejected [dict get $lineOf $nln] $pending
            set pending ""
        }
    }
    if {$pending ne ""} { incr unattributed }
    if {!$ok && [dict size $rejected] == 0} { incr unattributed }
    set caught 0
    foreach p $planted {
        lassign [::chdr::toolchain::compile $config $tcProfile "$prelude[lindex $p 2]\n"] pok
        if {!$pok} { incr caught }
    }
    set out [dict get $options -out]
    if {$out eq ""} { set out [file join $results oracle.txt] }
    set lines {}
    lappend lines "profile $name"
    lappend lines "toolchain [list [dict get [::chdr::toolchain::describe $config] version]]"
    set byKind [dict create]
    foreach c $checks { dict incr byKind [lindex $c 0] }
    foreach {k v} $byKind { lappend lines "checks $k $v" }
    foreach {k v} [lsort -stride 2 $skipped] { lappend lines "skipped [list $k] $v" }
    foreach {k v} [lsort -stride 2 $undefs] { lappend lines "undefined [list $k] $v" }
    lappend lines "unattributed-errors $unattributed"
    set nrej 0
    set nknown 0
    foreach {i msgs} $rejected {
        if {$i eq "prelude"} {
            lappend lines "prelude-error [list $msgs]"
            continue
        }
        set known [lindex $checks $i 3]
        if {$known ne ""} {
            incr nknown
            lappend lines "explained [list [lrange [lindex $checks $i] 0 1]] [list $known] [list [lindex $checks $i 2]] [list [lindex $msgs 0]]"
        } else {
            incr nrej
            lappend lines "rejected [list [lrange [lindex $checks $i] 0 1]] [list [lindex $checks $i 2]] [list [lindex $msgs 0]]"
        }
    }
    # Known type-changing attributes the compiler accepted anyway.
    foreach c $checks {
        if {[lindex $c 3] ne ""} { lappend lines "flagged [list [lrange $c 0 1]] [list [lindex $c 3]]" }
    }
    lappend lines "checks [llength $checks] rejected $nrej explained $nknown unattributed $unattributed planted-caught $caught/[llength $planted]"
    ::chdr::writeFile $out [join $lines \n]\n
    puts [lindex $lines end]
}

# Why a check may legitimately fail: an attribute that is part of the C type
# but is not in the type IR (the IR keeps it beside the type, as written).
proc Known {body} {
    set why {}
    foreach a [dict get $body attrs] {
        set n [lindex $a 2]
        if {$n eq "mode"} { lappend why "mode([lindex $a 3]) changes the declared type" }
        if {$n eq "vector_size"} { lappend why "vector_size changes the declared type" }
        if {$n eq "noreturn" && [lindex $a 0] eq "gnu"} { lappend why "noreturn is part of a function (pointer) type" }
        if {$n eq "transparent_union"} { lappend why "transparent_union changes calling" }
    }
    return [join $why "; "]
}

proc Render {type name names} {
    set c [::cir::render $type $name $names]
    if {[regexp {(struct|union|enum) anon@} $c]} { return "" }
    return $c
}

main $argv
