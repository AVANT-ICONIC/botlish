# hir-shape.tcl -- why the backends run faster after a cache hit than after
# the front end (GOLDEN-VS-TCL-BENCHMARK.md, "Process history"): the same
# backend work over (a) the HIR the front end just built, (b) the same HIR
# after an encode/decode round trip in the same process, and (c) the decoded
# HIR in a fresh process.
#
#   tclsh9.0 hir-shape.tcl SUITE.bot OUT.hirx     (a) and (b); writes OUT.hirx
#   tclsh9.0 hir-shape.tcl -decoded OUT.hirx      (c)
set root [file dirname [file dirname [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 100000
proc ms {script} { return [format %.0f [expr {[lindex [uplevel 1 [list time $script]] 0] / 1000.0}]] }
proc work {label hir} {
    set t [ms {hir::affine::temporaries $hir}]
    set t5 [ms {for {set i 0} {$i < 5} {incr i} {hir::affine::temporaries $hir}}]
    set lower [ms {hir::lower $hir}]
    set codegen [ms {core::compiler::compileHir $hir}]
    set nir [ms {native::nir $hir}]
    puts [format "%-26s temporaries %5s ms (5x %6s)  hir::lower %6s ms  compileHir %6s ms  native::nir %6s ms" $label $t $t5 $lower $codegen $nir]
}
if {[lindex $argv 0] eq "-decoded"} {
    set hir [hir::interchange::readFile [lindex $argv 1]]
    work "(c) decoded, fresh" $hir
    exit
}
lassign $argv suite out
set hir [surface::readProgramFile $suite -warnings off -cache ""]
work "(a) built" $hir
set copy [hir::interchange::decode [hir::interchange::encode $hir]]
puts "    same value: [expr {$copy eq [dict remove $hir traitSource]}]"
work "(b) decoded, same process" $copy
work "(a) built, again" $hir
hir::interchange::writeFile $out $hir
