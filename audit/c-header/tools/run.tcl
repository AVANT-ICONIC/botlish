# run.tcl -- run one import profile of the header experiment
# (C-HEADER-ARCHAEOLOGY.md, "Reproducing a run").
#
#   tclsh9.0 audit/c-header/tools/run.tcl PROFILE ?-out DIR? ?-allow-revision-mismatch 0|1?
#
# PROFILE is LIBRARY-VARIANT (profiles/LIBRARY.tcl). The library sources
# come from the sources directory (tools/fetch.tcl); the toolchain from the
# BOTLISH_C_* variables (tools/toolchain.tcl). The run
#
#   1. writes a translation unit including the profile's entry headers,
#   2. preprocesses it (and once more with -dD for the macro census),
#   3. parses the preprocessed C into IR records,
#   4. writes DIR (default audit/c-header/results/PROFILE):
#        profile.txt   the import profile: revision, toolchain, command, ...
#        ir.txt        the library's declarations (public, bundled, internal)
#        system.txt    the system declarations the library's refer to
#        macros.txt    the library's macro definitions
#        census.txt    the census (human-readable), census.tsv (key/value)
#        timing.txt    times and sizes (the only file that differs run to run)
#
# Everything but timing.txt is deterministic for a profile, a toolchain and
# a revision.

set here [file dirname [file normalize [info script]]]
source [file join $here common.tcl]
::chdr::use toolchain.tcl
::chdr::use cdecl.tcl
::chdr::use ir.tcl
::chdr::use macros.tcl macrocat.tcl pipeline.tcl
source [file join $here census.tcl]

proc main {argv} {
    set name [lindex $argv 0]
    if {$name eq ""} { puts stderr "usage: run.tcl PROFILE ?-out DIR?"; exit 2 }
    set options [dict create -out "" -allow-revision-mismatch 0]
    foreach {k v} [lrange $argv 1 end] {
        if {![dict exists $options $k]} { error "run.tcl: unknown option $k" }
        dict set options $k $v
    }
    set profile [::chdr::profile $name]
    set library [dict get $profile library]
    set out [dict get $options -out]
    if {$out eq ""} { set out [file join $::chdr::root results $name] }
    set sourceRoot [file join [::chdr::sourcesDir] $library]
    if {![file isdirectory $sourceRoot]} {
        error "run.tcl: no $library sources at $sourceRoot (run tools/fetch.tcl $library)"
    }
    # Symbolic links resolved, so that preprocessor paths match.
    set sourceRoot [file dirname [file normalize [file join $sourceRoot .x]]]
    set revision [exec git -C $sourceRoot rev-parse HEAD]
    set pinned [dict get $profile source commit]
    if {$revision ne $pinned && ![dict get $options -allow-revision-mismatch]} {
        error "run.tcl: $sourceRoot is at $revision, the profile pins $pinned"
    }
    set config [::chdr::toolchain::config]

    # 1.-3. The translation unit, preprocessed and parsed (the C header
    # library's pipeline, tools/cheader/pipeline.tcl).
    set run [::chdr::pipeline::run $profile $sourceRoot $config $name]
    set profileText [dict get $run profileText]
    file mkdir $out
    if {![dict get $run ok]} {
        ::chdr::writeFile [file join $out profile.txt] "$profileText\npreprocess PREPROCESS-FAILURE\n"
        ::chdr::writeFile [file join $out preprocess-failure.txt] [dict get $run stderr]
        puts "$name: PREPROCESS-FAILURE (see [file join $out preprocess-failure.txt])"
        return
    }
    set text [dict get $run text]
    set records [dict get $run records]
    set macros [dict get $run macros]
    set tokens [dict get $run tokens]
    dict with run timing {}
    set ppSeconds $preprocess
    set mSeconds $macroPreprocess
    set parseSeconds $parse
    set probeSeconds $probe

    # 4. Write.
    set t1 [clock microseconds]
    set library {}
    set system {}
    foreach r $records {
        set o [dict get [lindex $r 2] origin]
        if {$o in {public bundled internal}} { lappend library $r } else { lappend system $r }
    }
    set closure [::census::systemClosure $library $system]
    set header "C header experiment IR (C-HEADER-ARCHAEOLOGY.md): profile $name\nrevision $revision\ntoolchain [dict get [::chdr::toolchain::describe $config] version]"
    ::cir::write [file join $out ir.txt] $library $header
    ::cir::write [file join $out system.txt] $closure "$header\nthe system declarations the library's declarations refer to (transitively)"
    set libMacros {}
    foreach m $macros { if {[dict get [lindex $m 2] origin] in {public bundled internal}} { lappend libMacros $m } }
    ::cir::write [file join $out macros.txt] $libMacros "$header\nmacro definitions of the library's headers (-dD)"
    set irSeconds [expr {([clock microseconds] - $t1) / 1e6}]
    set t3 [clock microseconds]
    set census [::census::compute $name $library $system $libMacros]
    set censusSeconds [expr {([clock microseconds] - $t3) / 1e6}]
    ::chdr::writeFile [file join $out census.txt] [::census::text $census]
    ::chdr::writeFile [file join $out census.tsv] [::census::tsv $census]
    ::chdr::writeFile [file join $out profile.txt] $profileText
    set sizes {}
    foreach f {ir.txt system.txt macros.txt} { lappend sizes $f [file size [file join $out $f]] }
    ::chdr::writeFile [file join $out timing.txt] [join [list \
        "preprocess_seconds $ppSeconds" \
        "macro_preprocess_seconds $mSeconds" \
        "preprocessed_bytes [string length $text]" \
        "preprocessed_lines [llength [split $text \n]]" \
        "tokens $tokens" \
        "records [llength $records]" \
        "parse_seconds $parseSeconds" \
        "ir_write_seconds $irSeconds" \
        "macro_expansion_probe_seconds $probeSeconds" \
        "census_seconds $censusSeconds" \
        "ir_bytes $sizes"] \n]\n
    puts "$name: [llength $library] library records, [llength $system] system, [llength $libMacros] macros; parse [format %.2f $parseSeconds] s"
}

main $argv
