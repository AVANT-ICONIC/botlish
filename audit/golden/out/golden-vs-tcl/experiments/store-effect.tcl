# store-effect.tcl -- what keeping a cache entry costs the backends that run
# after it in the same process (GOLDEN-VS-TCL-BENCHMARK.md, "The cost of a
# cold cache"): the front end, then nothing (plain), encoding the HIR as the
# cache's store does (encode), or a real store through an empty cache
# (store); then native::nir, timed.
#
#   tclsh9.0 store-effect.tcl plain|encode|store SUITE.bot ?CACHE-DIR?
set root [file dirname [file dirname [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 100000
lassign $argv mode suite dir
switch -- $mode {
    plain { set hir [surface::readProgramFile $suite -warnings off -cache ""] }
    encode {
        set hir [surface::readProgramFile $suite -warnings off -cache ""]
        set text [hir::interchange::encode $hir -trait-source 1]
        unset text
    }
    store {
        file delete -force $dir
        set hir [surface::readProgramFile $suite -warnings off -cache $dir]
    }
}
set us [lindex [time {native::nir $hir}] 0]
puts [format "%-7s native::nir %.2f s" $mode [expr {$us / 1e6}]]
