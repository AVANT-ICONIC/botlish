# variants.tcl -- which configuration changes the IR? (C-HEADER-ARCHAEOLOGY.md,
# "Profile differences")
#
#   tclsh9.0 audit/c-header/tools/variants.tcl
#
# Runs the variations that are not profiles of their own into a private
# temporary directory -- the other compiler family, strict -std=c11, and a
# BORINGSSL_PREFIX consumer whose compiler lacks #pragma redefine_extname
# (simulated with -U__PRAGMA_REDEFINE_EXTNAME, the branch MSVC takes) --
# and diffs every pair the report discusses against the committed results.
# Writes results/variants.txt.

set here [file dirname [file normalize [info script]]]
source [file join $here common.tcl]

set tmp [file tempdir]
set results [file join $::chdr::root results]
set tclsh [info nameofexecutable]
set out {}

proc runVariant {label profile env} {
    global tmp tclsh here
    set dir [file join $tmp $label $profile]
    set saved {}
    foreach {k v} $env {
        lappend saved $k [expr {[info exists ::env($k)] ? [list 1 $::env($k)] : {0 {}}}]
        set ::env($k) $v
    }
    exec $tclsh [file join $here run.tcl] $profile -out $dir 2>@1
    foreach {k old} $saved {
        lassign $old had value
        if {$had} { set ::env($k) $value } else { unset ::env($k) }
    }
    return $dir
}

proc diffOf {a b dirA dirB} {
    global tclsh here
    exec $tclsh [file join $here diff.tcl] $a $b -results-a $dirA -results-b $dirB -limit 3
}

set pairs {}
foreach {a b} {boringssl-static boringssl-shared boringssl-static boringssl-prefix
               tcl-embed tcl-stubs tcl-embed tcl-notommath} {
    lappend pairs [list "$a -> $b (gcc)" $a $b [file join $results $a] [file join $results $b]]
}
foreach p {boringssl-static boringssl-prefix tcl-embed tcl-stubs} {
    set d [runVariant clang $p {BOTLISH_C_CC clang}]
    lappend pairs [list "$p: gcc -> clang" $p $p [file join $results $p] $d]
}
foreach p {boringssl-static tcl-embed} {
    set d [runVariant c11 $p {BOTLISH_C_FLAGS -std=c11}]
    lappend pairs [list "$p: default standard -> -std=c11" $p $p [file join $results $p] $d]
}
set d [runVariant nopragma boringssl-prefix {BOTLISH_C_UNDEFINES __PRAGMA_REDEFINE_EXTNAME}]
lappend pairs [list "boringssl-static -> boringssl-prefix without #pragma redefine_extname (simulated)" \
    boringssl-static boringssl-prefix [file join $results boringssl-static] $d]

foreach p $pairs {
    lassign $p label a b dirA dirB
    lappend out "######## $label"
    lappend out [diffOf $a $b $dirA $dirB]
    lappend out ""
}
::chdr::writeFile [file join $results variants.txt] [join $out \n]
file delete -force $tmp
puts "variants: [llength $pairs] comparisons in [file join $results variants.txt]"
