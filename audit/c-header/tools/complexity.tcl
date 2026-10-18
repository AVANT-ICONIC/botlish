# complexity.tcl -- how small is the declaration parser? (C-HEADER-ARCHAEOLOGY.md,
# "Parser complexity")
#
#   tclsh9.0 audit/c-header/tools/complexity.tcl
#
# Measures tools/cdecl.tcl (the tokenizer and parser) and, for contrast,
# the rest of the instrument: lines (code, comment, blank), procedures by
# role, the C words the parser recognizes, and the places it reports a
# failure or recovers. Writes results/parser-complexity.txt.

set here [file dirname [file normalize [info script]]]
source [file join $here common.tcl]

proc lines {path} {
    set code 0
    set comment 0
    set blank 0
    foreach l [split [::chdr::readFile $path] \n] {
        set t [string trim $l]
        if {$t eq ""} { incr blank } elseif {[string index $t 0] eq "#"} { incr comment } else { incr code }
    }
    return [list $code $comment $blank]
}

set out {}
set parser [file join $::chdr::lib cdecl.tcl]
lassign [lines $parser] code comment blank
lappend out "cdecl.tcl lines: code $code, comment $comment, blank $blank"
set text [::chdr::readFile $parser]
set procs [regexp -all -inline -line {^proc ::cdecl::(\w+)} $text]
set names {}
foreach {_ n} $procs { lappend names $n }
lappend out "cdecl.tcl procedures: [llength $names]"
set roles {
    tokenizer {Lex FileIndex}
    token-access {Peek Kind Next Expect Fail TextOf IsKeyword Loc}
    records {Origin Emit Tagged Storage Inline Unqualified DirectiveRecord parse}
    grammar {ParseAll External AfterDeclarator SkipBraces Balanced Specifiers TypeName BaseType
        Attribute Items StructSpecifier MemberDeclaration EnumSpecifier EnumValue Declarator
        Parameters Apply}
    grammar-predicates {IsAttributeStart IsTypeStart IsKeywordish NestedStart}
    recovery {Recover}
    literals {IntLiteral CharLiteral Parenthesized Bound lambda AnonTag}
}
set seen {}
foreach {role list} $roles {
    set present {}
    foreach n $list { if {$n in $names} { lappend present $n; lappend seen $n } }
    lappend out "  $role ([llength $present]): [join $present { }]"
}
set other {}
foreach n $names { if {$n ni $seen} { lappend other $n } }
if {$other ne ""} { lappend out "  unclassified ([llength $other]): [join $other { }]" }
# Recognized C words: the keyword tables.
source $parser
foreach v {storageWords fnspecWords typeWords ccWords attrWords typeofWords builtinTypes} {
    lappend out "recognized $v: [llength [set ::cdecl::$v]] ([join [set ::cdecl::$v] { }])"
}
lappend out "recognized qualWords: [llength [lsort -unique [dict values $::cdecl::qualWords]]] qualifiers in [dict size $::cdecl::qualWords] spellings"
lappend out "recognized softTypes: [dict size $::cdecl::softTypes] ([join [dict keys $::cdecl::softTypes] { }])"
# Failure and recovery sites.
set fails [regexp -all -inline {Fail ([A-Z-]+) "((?:[^"\\]|\\.)*)"} $text]
set byCat [dict create]
foreach {_ cat msg} $fails { dict lappend byCat $cat $msg }
lappend out "Fail sites: [expr {[llength $fails] / 3}]"
foreach {cat msgs} $byCat { lappend out "  $cat ([llength $msgs]): [join $msgs { | }]" }
lappend out "recovery: Recover (skip to ';' at depth 0 or a function body's '}'), the unknown-type-name heuristic, the soft-type rule"
# The rest of the instrument, for contrast.
foreach f [lsort [concat [glob -directory $here *.tcl] [glob -directory $::chdr::lib *.tcl]]] {
    lassign [lines $f] c m b
    lappend out "tool [file tail $f]: code $c, comment $m, blank $b"
}
::chdr::writeFile [file join $::chdr::root results parser-complexity.txt] [join $out \n]\n
puts [join $out \n]
