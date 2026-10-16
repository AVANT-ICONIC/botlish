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
source [file join $here toolchain.tcl]
source [file join $here cdecl.tcl]
source [file join $here ir.tcl]
source [file join $here macros.tcl]
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
    set abs {}
    foreach d [dict get $profile includeDirs] { lappend abs [file join $sourceRoot $d] }
    set tcProfile [dict replace $profile includeDirs $abs]

    # 1. The translation unit.
    set tmp [file tempdir]
    set entry [file join $tmp entry.c]
    set tu ""
    foreach h [dict get $profile entry] { append tu "#include <$h>\n" }
    ::chdr::writeFile $entry $tu

    # 2. Preprocess.
    lassign [::chdr::toolchain::preprocess $config $tcProfile $entry] ok text stderr ppSeconds command
    set describe [::chdr::toolchain::describe $config]
    set predefined [::chdr::toolchain::predefined $config $tcProfile]
    set profileText [ProfileText $name $profile $describe $revision $command $sourceRoot $entry $predefined]
    file mkdir $out
    if {!$ok} {
        ::chdr::writeFile [file join $out profile.txt] "$profileText\npreprocess PREPROCESS-FAILURE\n"
        ::chdr::writeFile [file join $out preprocess-failure.txt] [Sanitize $stderr $sourceRoot $entry]
        puts "$name: PREPROCESS-FAILURE (see [file join $out preprocess-failure.txt])"
        file delete -force $tmp
        return
    }
    lassign [::chdr::toolchain::macros $config $tcProfile $entry] mok mtext mstderr mSeconds

    # 3. Parse.
    set origin [list ::chdr::origin $profile $sourceRoot $entry]
    set t0 [clock microseconds]
    set records [::cdecl::parse $text $origin]
    set parseSeconds [expr {([clock microseconds] - $t0) / 1e6}]
    set tokens [llength $::cdecl::kinds]
    set records [Relocate $records $sourceRoot $entry]
    set records [SourceMacros $records $sourceRoot]
    set macros {}
    if {$mok} {
        set macros [Relocate [::cmacro::parse $mtext $origin] $sourceRoot $entry]
    }
    set records [AnnotateMacros $records $macros]
    set t2 [clock microseconds]
    set macros [ExpandMacros $config $tcProfile $profile $macros $tmp $sourceRoot $entry]
    set probeSeconds [expr {([clock microseconds] - $t2) / 1e6}]

    # 4. Write.
    set t1 [clock microseconds]
    set library {}
    set system {}
    foreach r $records {
        set o [dict get [lindex $r 2] origin]
        if {$o in {public bundled internal}} { lappend library $r } else { lappend system $r }
    }
    set closure [::census::systemClosure $library $system]
    set header "C header experiment IR (C-HEADER-ARCHAEOLOGY.md): profile $name\nrevision $revision\ntoolchain [dict get $describe version]"
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
    file delete -force $tmp
    puts "$name: [llength $library] library records, [llength $system] system, [llength $libMacros] macros; parse [format %.2f $parseSeconds] s"
}

# The import profile record (deterministic for profile/toolchain/revision).
proc ProfileText {name profile describe revision command sourceRoot entry predefined} {
    set lines {}
    lappend lines "profile $name"
    lappend lines "description [list [dict get $profile description]]"
    lappend lines "library [dict get $profile library]"
    lappend lines "source [list [dict get $profile source]]"
    lappend lines "revision $revision"
    lappend lines "entry [list [dict get $profile entry]]"
    lappend lines "include [list [dict get $profile includeDirs]]"
    lappend lines "defines [list [dict get $profile defines]]"
    lappend lines "undefines [list [dict get $profile undefines]]"
    lappend lines "flags [list [dict get $profile flags]]"
    foreach k {cc path family version style target host} {
        lappend lines "toolchain_$k [list [dict get $describe $k]]"
    }
    set env {}
    foreach v {BOTLISH_C_CC BOTLISH_C_CPP BOTLISH_C_TARGET BOTLISH_C_INCLUDE BOTLISH_C_DEFINES BOTLISH_C_UNDEFINES BOTLISH_C_FLAGS} {
        if {[info exists ::env($v)] && $::env($v) ne ""} { lappend env $v $::env($v) }
    }
    lappend lines "environment [list $env]"
    lappend lines "command [list [Sanitize $command $sourceRoot $entry]]"
    # The predefined macros that matter to the headers we analyze.
    lassign $predefined pok ptext
    set std ""
    set facts {}
    foreach l [split $ptext \n] {
        if {[regexp {^#define (__STDC_VERSION__|__SIZEOF_[A-Z_]+__|__CHAR_UNSIGNED__|__x86_64__|__aarch64__|__linux__|_WIN32|__APPLE__|__GNUC__|__clang_major__|__USER_LABEL_PREFIX__|__PRAGMA_REDEFINE_EXTNAME|__LP64__|_LP64|__ILP32__)\s*(.*)$} $l -> k v]} {
            lappend facts "$k=$v"
        }
    }
    lappend lines "predefined_count [llength [regexp -all -inline -line {^#define} $ptext]]"
    lappend lines "predefined [list [lsort $facts]]"
    return [join $lines \n]\n
}

proc Sanitize {text sourceRoot entry} {
    string map [list [file normalize $sourceRoot] {$SRC} [file dirname $entry] {$TU}] $text
}

# Make every loc relative to the library source root, the TU <entry>.
proc Relocate {records sourceRoot entry} {
    set cache [dict create]
    set out {}
    foreach r $records {
        lassign $r kind name body
        set loc [dict get $body loc]
        set f [lindex $loc 0]
        if {![dict exists $cache $f]} {
            dict set cache $f [expr {[file tail $f] eq [file tail $entry] ? "<entry>" : [::chdr::relPath $sourceRoot $f]}]
        }
        lset loc 0 [dict get $cache $f]
        dict set body loc $loc
        lappend out [list $kind $name $body]
    }
    return $out
}

# Cheap co-occurrence, not expansion provenance: the identifiers written on
# the original header lines a library declaration came from (its loc line
# span), kept as `srcwords` for the macro census to match against macro
# names.
proc SourceMacros {records sourceRoot} {
    set lines [dict create]
    set out {}
    foreach r $records {
        lassign $r kind name body
        if {[dict get $body origin] in {public bundled internal} && $kind ni {pragma directive}} {
            lassign [dict get $body loc] f a b
            if {![dict exists $lines $f]} {
                set path [file join $sourceRoot $f]
                dict set lines $f [expr {[file exists $path] ? [split [::chdr::readFile $path] \n] : {}}]
            }
            set words {}
            set conds {}
            foreach l [lrange [dict get $lines $f] [expr {$a - 1}] [expr {$b - 1}]] {
                regsub -all {/\*.*?\*/} $l {} l
                regsub {(//|/\*).*$} $l {} l
                if {[regexp {^\s*\*} $l]} continue
                if {[regexp {^\s*#\s*(if|ifdef|ifndef|elif|else|endif)} $l]} {
                    foreach w [regexp -all -inline {[A-Za-z_][A-Za-z0-9_]*} $l] {
                        if {$w ni {if ifdef ifndef elif else endif defined}} { lappend conds $w }
                    }
                    continue
                }
                if {[regexp {^\s*#} $l]} continue
                foreach w [regexp -all -inline {[A-Za-z_][A-Za-z0-9_]*} $l] {
                    if {$w ne $name} { lappend words $w }
                }
            }
            dict set body srcwords [lsort -unique $words]
            if {$conds ne ""} { dict set body srcconditionals [lsort -unique $conds] }
            # Documentation hints (reporting only): words of the comment
            # right above a struct definition and of the comments inside it
            # that say consumers should keep out.
            if {$kind eq "struct" && [dict get $body complete]} {
                set doc ""
                set all [dict get $lines $f]
                for {set k [expr {$a - 2}]} {$k >= 0 && $k >= $a - 16} {incr k -1} {
                    set l [lindex $all $k]
                    if {[regexp {^\s*(//|/\*|\*)} $l]} { append doc " $l" } elseif {[string trim $l] eq ""} { continue } else { break }
                }
                foreach l [lrange $all [expr {$a - 1}] [expr {$b - 1}]] {
                    if {[regexp {(//|/\*)(.*)$} $l -> _ c]} { append doc " $c" }
                }
                set hints {}
                foreach {w re} {private {\mprivate\M} opaque {\mopaque\M} internal {\minternal\M}
                        do-not {\m(do not|don't|should not|must not|shouldn't)\M} public {\mpublic\M}
                        deprecated {\mdeprecated\M}} {
                    if {[regexp -nocase $re $doc]} { lappend hints $w }
                }
                if {$hints ne ""} { dict set body dochints $hints }
            }
        }
        lappend out [list $kind $name $body]
    }
    return $out
}

# Let the preprocessor expand every library macro once, after the
# profile's headers: an object-like macro alone, a function-like one applied
# to its own parameter names (`MAX(a, b)` -> `((a) > (b) ? (a) : (b))`). Each
# probe is preceded by a marker identifier no header defines. The
# expansion is what the macro means in this profile; nothing here expands a
# macro itself.
proc ExpandMacros {config tcProfile profile macros tmp sourceRoot entry} {
    set lib {}
    set calls {}
    foreach m $macros {
        lassign $m _ name b
        if {[dict get $b origin] ni {public bundled internal} || [dict get $b undefined]} continue
        set call $name
        if {[dict get $b form] eq "function"} {
            set args {}
            set n [llength [dict get $b params]]
            if {[dict get $b variadic]} { incr n }
            for {set k 0} {$k < $n} {incr k} { lappend args "__botlish_a${k}__" }
            set call "$name\([join $args {, }]\)"
        }
        lappend lib $name
        lappend calls $call
    }
    # A probe the preprocessor rejects (a macro that needs a string or a
    # number for an argument: _Pragma(#s), #if) is left out and recorded;
    # the rest is preprocessed again.
    set rejected [dict create]
    for {set round 0} {$round < 20} {incr round} {
        set probe ""
        foreach h [dict get $profile entry] { append probe "#include <$h>\n" }
        append probe "#line 1 \"botlish-macro-probe\"\n"
        set i 0
        foreach name $lib call $calls {
            if {[dict exists $rejected $name]} {
                append probe "\n"
            } else {
                append probe "__botlish_probe_${i}__ $call\n"
            }
            incr i
        }
        set path [file join $tmp probe.c]
        ::chdr::writeFile $path $probe
        lassign [::chdr::toolchain::preprocess $config $tcProfile $path] ok text stderr
        if {$ok} break
        set more 0
        foreach line [split $stderr \n] {
            if {[regexp {botlish-macro-probe:([0-9]+):[0-9]+: (?:fatal )?error: (.*)$} $line -> ln msg]} {
                set name [lindex $lib [expr {$ln - 1}]]
                if {$name ne "" && ![dict exists $rejected $name]} {
                    dict set rejected $name $msg
                    set more 1
                }
            }
        }
        if {!$more} {
            puts stderr "macro expansion probe failed: [string range $stderr 0 300]"
            return $macros
        }
    }
    set at [string first "botlish-macro-probe" $text]
    set section [string range $text $at end]
    set nl [string first \n $section]
    set section [string range $section [expr {$nl + 1}] end]
    ::cdecl::Lex $section
    set expansions [dict create]
    set current ""
    set from 0
    set n [llength $::cdecl::texts]
    for {set k 0} {$k <= $n} {incr k} {
        set t [lindex $::cdecl::texts $k]
        if {$k == $n || [regexp {^__botlish_probe_([0-9]+)__$} $t -> idx]} {
            if {$current ne ""} {
                dict set expansions [lindex $lib $current] [::cdecl::TextOf $from $k]
            }
            if {$k < $n} { set current $idx; set from [expr {$k + 1}] }
        }
    }
    set out {}
    foreach m $macros {
        lassign $m kind name b
        if {[dict exists $expansions $name] && ![dict get $b undefined]} {
            set raw [dict get $expansions $name]
            if {[dict get $b form] eq "function"} {
                # Where each argument went: standalone uses, inside a string
                # (stringified), inside a longer identifier (pasted).
                set params [dict get $b params]
                if {[dict get $b variadic]} { lappend params __VA_ARGS__ }
                set map {}
                set uses {}
                set k 0
                foreach p $params {
                    set marker "__botlish_a${k}__"
                    lappend map $marker $p
                    set standalone [llength [regexp -all -inline "(?:^|\[^A-Za-z0-9_\])${marker}(?:\[^A-Za-z0-9_\]|\$)" $raw]]
                    set strings 0
                    foreach str [regexp -all -inline {"(?:[^"\\]|\\.)*"} $raw] {
                        if {[string first $marker $str] >= 0} { incr strings }
                    }
                    set pasted [llength [regexp -all -inline "\[A-Za-z0-9_\]${marker}|${marker}\[A-Za-z0-9_\]" $raw]]
                    lappend uses [list $p $standalone $strings $pasted]
                    incr k
                }
                dict set b expansion [string map $map $raw]
                dict set b arguses $uses
            } else {
                dict set b expansion $raw
            }
        }
        if {[dict exists $rejected $name]} {
            dict set b probe [list rejected [dict get $rejected $name]]
        }
        lappend out [list $kind $name $b]
    }
    return $out
}

# Replace srcwords by srcmacros: the words that are macros of the library.
proc AnnotateMacros {records macros} {
    set names [dict create]
    foreach m $macros {
        if {[dict get [lindex $m 2] origin] in {public bundled internal}} { dict set names [lindex $m 1] 1 }
    }
    set out {}
    foreach r $records {
        lassign $r kind name body
        if {[dict exists $body srcwords]} {
            set ms {}
            foreach w [dict get $body srcwords] { if {[dict exists $names $w]} { lappend ms $w } }
            set body [dict remove $body srcwords]
            if {$ms ne ""} { dict set body srcmacros $ms }
        }
        lappend out [list $kind $name $body]
    }
    return $out
}

main $argv
