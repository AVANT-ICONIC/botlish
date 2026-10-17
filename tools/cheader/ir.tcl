# ir.tcl -- the exploratory FFI IR as text, and queries over its types
# (C-HEADER-ARCHAEOLOGY.md, "The IR").
#
# An IR file is a Tcl list of records, three elements each (KIND NAME BODY),
# written one key per line so that two runs diff line by line:
#
#   function SSL_new {
#       loc {include/openssl/ssl.h 226 226}
#       origin public
#       type {fn {ptr {typedef SSL}} {{ctx {ptr {typedef SSL_CTX}} {}}} {}}
#       ...
#   }
#
# Records keep source order (a nested struct definition comes right before
# the declaration that contains it). Nothing is sorted except qualifier
# sets.

namespace eval ::cir {
    variable keyOrder {loc origin kind complete anonymous parent storage inline
        definition type underlying link fields enumerators attrs fnspec init
        bodytokens unknowntypes srcmacros srcconditionals dochints form params variadic body
        expansion arguses probe redefined undefined category reason state at expr text}
}

proc ::cir::write {path records header} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    foreach line [split $header \n] { puts $f "# $line" }
    foreach r $records {
        puts $f [format1 $r]
    }
    close $f
}

proc ::cir::format1 {r} {
    variable keyOrder
    lassign $r kind name body
    set body [dict remove $body pos]
    set out "[list $kind $name] \{\n"
    set keys {}
    foreach k $keyOrder { if {[dict exists $body $k]} { lappend keys $k } }
    foreach k [lsort [dict keys $body]] { if {$k ni $keys} { lappend keys $k } }
    foreach k $keys {
        set v [dict get $body $k]
        if {$k in {fields enumerators} && [llength $v]} {
            append out "    $k \{\n"
            foreach item $v { append out "        [list $item]\n" }
            append out "    \}\n"
        } else {
            append out "    $k [list $v]\n"
        }
    }
    append out "\}"
    return $out
}

proc ::cir::read {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set text [::read $f]
    close $f
    regsub -all -line {^#.*$} $text {} text
    set records {}
    foreach {kind name body} $text { lappend records [list $kind $name $body] }
    return $records
}

# ---------------------------------------------------------------------------
# Indexes over a record list.

# A dict: typedef NAME -> body, tag "struct T"/"union T"/"enum T" -> merged
# body (complete if any record defines it; its defining record's loc and
# origin), function NAME -> body, variable NAME -> body.
proc ::cir::index {records} {
    set ix [dict create typedef {} tag {} function {} variable {}]
    foreach r $records {
        lassign $r kind name body
        switch -- $kind {
            typedef - function - variable {
                if {![dict exists $ix $kind $name] || ($kind eq "function" && [dict get $body definition])} {
                    dict set ix $kind $name $body
                }
            }
            struct - enum {
                set key [expr {$kind eq "enum" ? "enum $name" : "[dict get $body kind] $name"}]
                if {![dict exists $ix tag $key]} {
                    dict set body declarations 1
                    dict set ix tag $key $body
                } else {
                    set old [dict get $ix tag $key]
                    set n [expr {[dict get $old declarations] + 1}]
                    if {[dict get $body complete] && ![dict get $old complete]} {
                        set old $body
                    }
                    dict set old declarations $n
                    dict set ix tag $key $old
                }
            }
        }
    }
    return $ix
}

# Strip qualifiers: {q QUALS T} -> T.
proc ::cir::unq {type} {
    while {[lindex $type 0] eq "q"} { set type [lindex $type 2] }
    return $type
}

proc ::cir::quals {type} {
    set q {}
    while {[lindex $type 0] eq "q"} {
        lappend q {*}[lindex $type 1]
        set type [lindex $type 2]
    }
    return $q
}

# Follow typedef references: {CHAIN FINAL}, CHAIN the typedef names in
# order, FINAL the first non-typedef type (its own qualifiers merged with
# those met on the way).
proc ::cir::resolve {ix type} {
    set chain {}
    set quals {}
    while 1 {
        lappend quals {*}[quals $type]
        set type [unq $type]
        if {[lindex $type 0] ne "typedef"} { break }
        set name [lindex $type 1]
        if {$name in $chain || ![dict exists $ix typedef $name]} {
            break
        }
        lappend chain $name
        set type [dict get $ix typedef $name type]
    }
    if {$quals ne ""} { set type [list q [lsort -unique $quals] $type] }
    return [list $chain $type]
}

proc ::cir::final {ix type} { lindex [resolve $ix $type] 1 }

# The tag key ("struct T", "enum E") of a type after typedef resolution, or "".
proc ::cir::tagOf {ix type} {
    set t [unq [final $ix $type]]
    if {[lindex $t 0] in {struct union enum}} { return "[lindex $t 0] [lindex $t 1]" }
    return ""
}

# ---------------------------------------------------------------------------
# Rendering types back to C (for people and for the compiler oracle).

# NAMES maps an anonymous tag ("struct anon@...") to a typedef that names
# it; a type with an anonymous tag and no such name renders as the tag
# (not valid C: the oracle skips those).
proc ::cir::render {type {declarator ""} {names {}}} {
    set h [lindex $type 0]
    switch -- $h {
        q {
            set qs [lindex $type 1]
            set inner [lindex $type 2]
            if {[lindex $inner 0] in {ptr block}} {
                return [Pointer [lindex $inner 1] $qs $declarator $names [lindex $inner 0]]
            }
            return [Join "[join [lsort $qs]] [render $inner {} $names]" $declarator]
        }
        ptr - block {
            return [Pointer [lindex $type 1] {} $declarator $names $h]
        }
        array {
            lassign $type _ elem bound aq
            set b [BoundText $bound]
            if {$aq ne ""} { set b "[join $aq] $b" }
            return [render $elem "$declarator\[[string trim $b]\]" $names]
        }
        fn {
            lassign $type _ result params flags
            set ps {}
            foreach p $params {
                lappend ps [render [lindex $p 1] [lindex $p 0] $names]
            }
            if {"variadic" in $flags} { lappend ps ... }
            if {$ps eq "" && "noproto" ni $flags} { set ps void }
            return [render $result "$declarator\([join $ps {, }]\)" $names]
        }
        default {
            return [Join [BaseText $type $names] $declarator]
        }
    }
}

proc ::cir::Pointer {pointee qs declarator names star} {
    set s [expr {$star eq "block" ? "^" : "*"}]
    if {$qs ne ""} { append s "[join [lsort $qs]] " }
    set d "$s$declarator"
    if {[lindex [unq $pointee] 0] in {array fn}} { set d "($d)" }
    return [render $pointee $d $names]
}

proc ::cir::Join {a b} {
    if {$b eq ""} { return $a }
    if {[string index $b 0] in {* ( ^}} { return "$a $b" }
    return "$a $b"
}

proc ::cir::BoundText {bound} {
    switch -- [lindex $bound 0] {
        "" { return "" }
        lit { return [lindex $bound 1] }
        vla { return "*" }
        expr { return [lindex $bound 1] }
    }
}

proc ::cir::BaseText {type names} {
    switch -- [lindex $type 0] {
        void { return void }
        bool { return _Bool }
        int - float - builtin - typedef { return [lindex $type 1] }
        complex { return "_Complex [lindex $type 1]" }
        struct - union - enum {
            set key "[lindex $type 0] [lindex $type 1]"
            if {[dict exists $names $key]} { return [dict get $names $key] }
            return $key
        }
        typeof { return "__typeof__([lindex $type 1])" }
        atomic { return "_Atomic([render [lindex $type 1] {} $names])" }
        bitint { return [lindex $type 1] }
    }
    return "<?$type?>"
}

# A compact one-line spelling of a type for reports: C-like but explicit
# about typedef references (`SSL_CTX` stays `SSL_CTX`).
proc ::cir::spell {type {names {}}} { render $type {} $names }
