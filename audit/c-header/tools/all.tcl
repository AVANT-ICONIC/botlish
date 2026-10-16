# all.tcl -- regenerate every result of the header experiment
# (C-HEADER-ARCHAEOLOGY.md, "Reproducing a run").
#
#   tclsh9.0 audit/c-header/tools/fetch.tcl     # once: the pinned sources
#   tclsh9.0 audit/c-header/tools/all.tcl
#
# Runs, in order: every profile (run.tcl), the compiler oracle and the ABI
# probe of every profile, the unsupported corpus of both libraries, the
# thunk prototype, the configuration variants and the parser measurements,
# then the parser and corpus tests. The default toolchain is the
# configured one (BOTLISH_C_CC, else cc); thunks.tcl and variants.tcl also
# use clang.

set here [file dirname [file normalize [info script]]]
source [file join $here common.tcl]
set tclsh [info nameofexecutable]
proc step {args} {
    global tclsh here
    set t0 [clock milliseconds]
    set out [exec $tclsh [file join $here [lindex $args 0]] {*}[lrange $args 1 end] 2>@1]
    puts "[format %6.1f [expr {([clock milliseconds] - $t0) / 1000.0}]] s  [join $args { }]: [lindex [split $out \n] end]"
}
set profiles {}
foreach library {boringssl tcl} {
    lappend profiles {*}[dict keys [::chdr::loadProfiles $library]]
}
foreach p $profiles { step run.tcl $p }
foreach p $profiles { step oracle.tcl $p }
foreach p $profiles { step abiprobe.tcl $p -layouts 1 }
foreach library {boringssl tcl} { step corpus.tcl $library }
step thunks.tcl
step variants.tcl
step complexity.tcl
foreach t {parser.test corpus.test} {
    set out [exec $tclsh [file join $::chdr::root tests $t] 2>@1]
    puts [lindex [split [string trim $out] \n] end]
}
