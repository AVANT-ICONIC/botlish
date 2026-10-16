# macros.tcl -- macro definitions from a `-dD` preprocessing run
# (C-HEADER-ARCHAEOLOGY.md, "Macros").
#
# The preprocessor keeps every #define and #undef in place when asked to
# (-dD for GCC and Clang), between the same line markers as the
# declarations, so each definition has a file and a line. Nothing here
# expands a macro or evaluates a conditional: a definition that some #if
# skipped never reaches the output and is not a macro of the profile.

namespace eval ::cmacro {}

# The macro records of the -dD output TEXT: {macro NAME BODY} with loc
# {FILE LINE LINE}, origin, form (object|function), params, variadic, body
# (the replacement text), redefined (how many earlier definitions it
# replaced) and undefined (1 if an #undef removed it at the end).
proc ::cmacro::parse {text originCommand} {
    ::cdecl::Lex $text
    set ::cdecl::originCommand $originCommand
    set ::cdecl::originCache [dict create]
    set defs [dict create]
    set order {}
    foreach d $::cdecl::directives {
        lassign $d index file line dtext
        set fname [lindex $::cdecl::fileNames $file]
        if {[regexp {^#\s*define\s+([A-Za-z_$][A-Za-z0-9_$]*)(\(([^)]*)\))?(?:\s+(.*))?$} $dtext -> name paren params body]} {
            set form [expr {$paren eq "" ? "object" : "function"}]
            set plist {}
            set variadic 0
            foreach p [split $params ,] {
                set p [string trim $p]
                if {$p eq ""} continue
                if {$p eq "..." || [string match *... $p]} { set variadic 1; set p [string range $p 0 end-3] }
                if {$p ne ""} { lappend plist $p }
            }
            set redefined 0
            if {[dict exists $defs $name]} {
                set redefined [expr {[dict get $defs $name redefined] + 1}]
            } else {
                lappend order $name
            }
            dict set defs $name [dict create loc [list $fname $line $line] \
                origin [::cdecl::Origin $fname] form $form params $plist variadic $variadic \
                body [string trim $body] redefined $redefined undefined 0]
        } elseif {[regexp {^#\s*undef\s+([A-Za-z_$][A-Za-z0-9_$]*)} $dtext -> name]} {
            if {[dict exists $defs $name]} { dict set defs $name undefined 1 }
        }
    }
    set records {}
    foreach name $order {
        lappend records [list macro $name [dict get $defs $name]]
    }
    return $records
}
