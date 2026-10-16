# memo-temporaries.tcl -- an experiment, not a fix (GOLDEN-VS-TCL-BENCHMARK.md,
# "What would remove the rest"): runs SCRIPT ARGS with
# hir::affine::temporaries memoized per HIR value (the Tcl_Obj the caller
# passes, identified by its address while it is alive, and its expression
# count), injected when the procedure is defined, so no front-end file
# changes (the front-end fingerprint, and so the HIR cache, stay valid).
#
#   tclsh9.0 memo-temporaries.tcl SCRIPT ?ARG ...?
namespace eval ::memoTemps {
    variable script [file normalize [lindex $::argv 0]]
    variable hits 0
    variable misses 0
}
set argv [lrange $argv 1 end]
set argc [llength $argv]
set argv0 $::memoTemps::script
rename ::proc ::memoTemps::proc
::memoTemps::proc ::proc {name arguments body} {
    uplevel 1 [list ::memoTemps::proc $name $arguments $body]
    if {[uplevel 1 [list namespace which -command $name]] eq "::hir::affine::temporaries"} {
        rename ::hir::affine::temporaries ::hir::affine::temporaries__orig
        ::memoTemps::proc ::hir::affine::temporaries {hir} {
            regexp {object pointer at (\S+)} [tcl::unsupported::representation $hir] -> pointer
            set key [list $pointer [dict size [dict get $hir exprs]]]
            if {[info exists ::memoTemps::key] && $::memoTemps::key eq $key} {
                incr ::memoTemps::hits
                return $::memoTemps::value
            }
            incr ::memoTemps::misses
            set ::memoTemps::value [::hir::affine::temporaries__orig $hir]
            set ::memoTemps::key $key
            return $::memoTemps::value
        }
    }
}
rename ::exit ::memoTemps::exit
::memoTemps::proc ::exit {{status 0}} {
    puts stderr "memo-temporaries: hits $::memoTemps::hits misses $::memoTemps::misses"
    ::memoTemps::exit $status
}
set code [catch {uplevel #0 [list source $::memoTemps::script]} message options]
if {$code == 1} { puts stderr [dict get $options -errorinfo]; exit 1 }
exit 0
