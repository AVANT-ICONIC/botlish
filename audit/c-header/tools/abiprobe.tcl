# abiprobe.tcl -- ask the C compiler for the physical facts the declaration
# IR cannot know (C-HEADER-ARCHAEOLOGY.md, "The ABI probe").
#
#   tclsh9.0 audit/c-header/tools/abiprobe.tcl PROFILE ?-layouts 1?
#
# A throwaway native prototype of the ABI-probe wishlist: generates one C
# program that includes the profile's headers and prints, for the public
# declarations of results/PROFILE/ir.txt,
#
#   scalar NAME SIZE ALIGN SIGNED     the C scalar types and integer typedefs
#   struct TAG SIZE ALIGN             every complete struct and union
#   field TAG.NAME OFFSET SIZE        every named field that has an address
#   enum TAG SIZE SIGNED              every complete enum's storage
#   enumerator NAME VALUE             every enumerator, from the compiler
#   macro NAME VALUE                  integer-constant macros (the census's
#                                     constant categories), sizeof ones too
#
# compiles it with the configured toolchain, runs it on the host and writes
# results/PROFILE/abi.txt. It then compares what the parser computed on its
# own (enumerator values) with the compiler's, and with -layouts 1 writes
# results/PROFILE/layouts.bot: a Botlish `layout` declaration for every
# complete struct the census found REPRESENTABLE-NOW, from the probed
# offsets (BINARY-LAYOUT.md, "C FFI is one consumer").

set here [file dirname [file normalize [info script]]]
source [file join $here common.tcl]
::chdr::use toolchain.tcl
::chdr::use cdecl.tcl
::chdr::use ir.tcl
source [file join $here census.tcl]

proc main {argv} {
    set name [lindex $argv 0]
    set options [dict create -layouts 0]
    foreach {k v} [lrange $argv 1 end] { dict set options $k $v }
    set profile [::chdr::profile $name]
    set results [file join $::chdr::root results $name]
    set library [::cir::read [file join $results ir.txt]]
    set system [::cir::read [file join $results system.txt]]
    set macros [::cir::read [file join $results macros.txt]]
    set ::census::ix [::cir::index [concat $system $library]]
    set ::census::libIx [::cir::index $library]
    set api {}
    foreach r $library { if {[dict get [lindex $r 2] origin] in {public bundled}} { lappend api $r } }
    set names [dict create]
    foreach r [concat $system $library] {
        lassign $r kind n body
        if {$kind eq "typedef"} {
            set t [dict get $body type]
            if {[lindex $t 0] in {struct union enum} && ![dict exists $names "[lindex $t 0] [lindex $t 1]"]} {
                dict set names "[lindex $t 0] [lindex $t 1]" $n
            }
        }
    }
    set src "#include <stdio.h>\n#include <stddef.h>\n"
    foreach h [dict get $profile entry] { append src "#include <$h>\n" }
    append src "#define S(T, N) printf(\"scalar %s %zu %zu %d\\n\", N, sizeof(T), _Alignof(T), (int)((T)-1 < (T)0))\n"
    append src "int main(void) {\n"
    foreach {t n} {char char {signed char} {signed char} {unsigned char} {unsigned char} short short
        {unsigned short} {unsigned short} int int {unsigned int} {unsigned int} long long
        {unsigned long} {unsigned long} {long long} {long long} {unsigned long long} {unsigned long long}
        _Bool _Bool} {
        append src "  S($t, \"[list $n]\");\n"
    }
    append src "  printf(\"scalar pointer %zu %zu 0\\n\", sizeof(void *), _Alignof(void *));\n"
    append src "  printf(\"scalar float %zu %zu 1\\n\", sizeof(float), _Alignof(float));\n"
    append src "  printf(\"scalar double %zu %zu 1\\n\", sizeof(double), _Alignof(double));\n"
    append src "  printf(\"scalar {long double} %zu %zu 1\\n\", sizeof(long double), _Alignof(long double));\n"
    # Integer typedefs of the API.
    foreach r [::census::ofKind $api typedef] {
        if {[::census::cat [dict get [lindex $r 2] type]] in {int bool}} {
            set n [lindex $r 1]
            append src "  S($n, \"$n\");\n"
        }
    }
    # Structs, unions, fields.
    set probed {}
    foreach {key r} [::census::CompleteTags $api] {
        set tag [lindex $key 1]
        if {[string match anon@* $tag]} {
            if {![dict exists $names $key]} continue
            set ctype [dict get $names $key]
        } else {
            set ctype $key
        }
        lappend probed $key
        append src "  printf(\"struct %s %zu %zu\\n\", \"[list $key]\", sizeof($ctype), _Alignof($ctype));\n"
        foreach f [FieldPaths $key] {
            lassign $f path bits
            if {$bits ne ""} continue
            append src "  printf(\"field %s %zu %zu\\n\", \"[list $key].$path\", offsetof($ctype, $path), sizeof((($ctype *)0)->$path));\n"
        }
    }
    # Enums and enumerators.
    foreach r [::census::ofKind $api enum] {
        lassign $r kind tag body
        if {![dict get $body complete]} continue
        set key "enum $tag"
        if {[string match anon@* $tag]} {
            set ctype [expr {[dict exists $names $key] ? [dict get $names $key] : ""}]
        } else {
            set ctype $key
        }
        if {$ctype ne ""} {
            append src "  printf(\"enum %s %zu %d\\n\", \"[list $key]\", sizeof($ctype), (int)(($ctype)-1 < ($ctype)0));\n"
        }
        foreach e [dict get $body enumerators] {
            append src "  printf(\"enumerator [lindex $e 0] %lld\\n\", (long long)([lindex $e 0]));\n"
        }
    }
    # Integer-constant macros.
    foreach m $macros {
        lassign $m _ mname b
        if {[dict get $b form] ne "object" || [dict get $b undefined]} continue
        set c [::census::MacroObjectCategory $mname $b]
        if {$c in {{constant: integer literal} {constant: integer expression} {constant: expression with casts} {constant: expression with sizeof (needs ABI)} {constant: enumerator alias}}} {
            append src "  printf(\"macro $mname %lld\\n\", (long long)($mname));\n"
        }
    }
    append src "  return 0;\n}\n"
    set sourceRoot [file dirname [file normalize [file join [::chdr::sourcesDir] [dict get $profile library] .x]]]
    set abs {}
    foreach d [dict get $profile includeDirs] { lappend abs [file join $sourceRoot $d] }
    set tcProfile [dict replace $profile includeDirs $abs flags [concat [dict get $profile flags] -w]]
    set config [::chdr::toolchain::config]
    lassign [::chdr::toolchain::run $config $tcProfile $src] ok out stderr
    if {!$ok} {
        puts "abiprobe: the probe failed: [string range $stderr 0 2000]"
        exit 1
    }
    set head "# ABI probe (C-HEADER-ARCHAEOLOGY.md): profile $name, toolchain [dict get [::chdr::toolchain::describe $config] version], native [dict get [::chdr::toolchain::describe $config] host]\n"
    ::chdr::writeFile [file join $results abi.txt] "$head$out"
    # Compare with the parser's own enumerator values.
    set compiler [dict create]
    foreach line [split $out \n] {
        if {[regexp {^enumerator (\S+) (-?[0-9]+)$} $line -> n v]} { dict set compiler $n $v }
    }
    set agree 0
    set disagree {}
    set uncomputed 0
    foreach r [::census::ofKind $api enum] {
        foreach e [dict get [lindex $r 2] enumerators] {
            lassign $e n form value
            if {$value eq ""} { incr uncomputed; continue }
            if {[dict exists $compiler $n] && [dict get $compiler $n] == $value} { incr agree } else { lappend disagree $n }
        }
    }
    set summary "enumerators: parser agrees with the compiler on $agree, disagrees on [llength $disagree] ([join $disagree { }]), did not compute $uncomputed"
    puts "$name: [llength [split [string trim $out] \n]] facts; $summary"
    ::chdr::writeFile [file join $results abi-summary.txt] "$summary\n"
    if {[dict get $options -layouts]} {
        WriteLayouts $name $api $out [file join $results layouts.bot]
    }
}

# The address-bearing field paths of a struct: {PATH BITS}; an anonymous
# member's fields are reached through the parent (C11), so they are listed
# by their own names.
proc FieldPaths {key} {
    set out {}
    if {![dict exists $::census::ix tag $key]} { return {} }
    foreach f [dict get $::census::ix tag $key fields] {
        lassign $f name type bits
        if {$name eq ""} {
            set inner [::census::tagKey $type]
            if {$inner ne ""} { lappend out {*}[FieldPaths $inner] }
            continue
        }
        lappend out [list $name $bits]
    }
    return $out
}

# Botlish layouts for the REPRESENTABLE-NOW structs, from the probe's facts:
# each scalar field's domain from its probed size and signedness.
proc WriteLayouts {name api facts path} {
    set size [dict create]
    set offset [dict create]
    set scalar [dict create]
    foreach line [split $facts \n] {
        if {[regexp {^struct (\{[^\}]*\}|\S+ \S+) ([0-9]+) ([0-9]+)$} $line -> k s a]} {
            dict set size [string trim $k "{}"] [list $s $a]
        } elseif {[regexp {^field (.*)\.(\w+) ([0-9]+) ([0-9]+)$} $line -> k f o s]} {
            dict set offset [string trim $k "{}"].$f [list $o $s]
        } elseif {[regexp {^scalar (\{[^\}]*\}|\S+) ([0-9]+) ([0-9]+) ([01])$} $line -> n s a sg]} {
            dict set scalar [string trim $n "{}"] [list $s $sg]
        }
    }
    set text "# layouts.bot -- Botlish layouts generated from the ABI probe of profile $name\n"
    append text "# (C-HEADER-ARCHAEOLOGY.md, \"The ABI probe\"): the census's REPRESENTABLE-NOW\n"
    append text "# structs, sizes and offsets as the C compiler resolved them on this host.\n"
    set n 0
    set lengths {}
    set sizes {}
    foreach {key r} [::census::CompleteTags $api] {
        if {[::census::Requirements $key] ne "" && [lsearch -all -inline -glob [::census::Requirements $key] NEEDS-*] ne ""} continue
        if {![dict exists $size $key]} continue
        lassign [dict get $size $key] s a
        set lname [string map {" " _} [string toupper [lindex $key 1]]]
        set lines {}
        set ok 1
        foreach f [dict get [lindex $r 2] fields] {
            lassign $f fname ftype
            set c [::census::cat $ftype]
            if {$c eq "struct"} { set ok 0; break }
            set u [::cir::unq [::census::final $ftype]]
            set spelled [lindex $u 1]
            if {![dict exists $offset "$key.$fname"] || ![dict exists $scalar $spelled]} { set ok 0; break }
            lassign [dict get $offset "$key.$fname"] o fs
            lassign [dict get $scalar $spelled] ss sg
            set bitsN [expr {8 * $fs}]
            set dom [expr {$sg ? "binary::I$bitsN" : "binary::U$bitsN"}]
            lappend lines "    field $fname: $dom at $o"
        }
        if {!$ok} continue
        incr n
        lappend lengths "binary::layout_length($lname)"
        lappend sizes $s
        append text "# [dict get [lindex $r 2] text]\nlayout $lname:\n    size $s\n    align $a\n[join $lines \n]\n\n"
    }
    append text "\[[join $lengths {, }]\]\n"
    set text [string map [list "structs, sizes and offsets as the C compiler resolved them on this host.\n" "structs, sizes and offsets as the C compiler resolved them on this host.\n# expect: \[[join $sizes {, }]\]\nimport binary\n\n"] $text]
    ::chdr::writeFile $path $text
    puts "$name: $n layouts in $path"
}

main $argv
