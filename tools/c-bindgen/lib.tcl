# lib.tcl -- loads the binding generator (C-BINDGEN.md): the C header
# library (tools/cheader/), the compiler's front end (for the target table,
# core/cabi.tcl) and the generator's own files. tools/c-bindgen.tcl and the
# generator's tests source it; the compiler never does.

namespace eval ::cbind {
    variable libDir [file dirname [file normalize [info script]]]
    variable toolsDir [file dirname $libDir]
    variable repo [file dirname $toolsDir]
}
foreach f {common.tcl toolchain.tcl cdecl.tcl ir.tcl macros.tcl macrocat.tcl pipeline.tcl} {
    source [file join $::cbind::toolsDir cheader $f]
}
if {[info commands ::core::cabi::targetNames] eq ""} {
    source [file join $::cbind::repo surface surface.tcl]
}
foreach f {profile.tcl probe.tcl model.tcl records.tcl pressure.tcl emit.tcl report.tcl verify.tcl generate.tcl} {
    source [file join $::cbind::libDir $f]
}
