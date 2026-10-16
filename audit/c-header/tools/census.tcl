# census.tcl -- counts over the exploratory FFI IR (C-HEADER-ARCHAEOLOGY.md,
# "The census").
#
# Every count is computed from IR records; nothing here reads C text again.
# Heuristic sections (string-like conventions, out parameters, consumer-
# facing structs) are reporting only and are labeled so: they never feed
# back into the IR.
#
# A census is a dict SECTION -> list of rows, each row {KEY VALUE ?NOTE?};
# `text` renders it for people, `tsv` as SECTION<TAB>KEY<TAB>VALUE lines.

namespace eval ::census {
    variable ix {}
    variable libIx {}
    # Attribute names by what they do (C-HEADER-ARCHAEOLOGY.md, "Attributes").
    variable attrClass {
        aligned abi packed abi mode abi vector_size abi transparent_union abi
        regparm abi stdcall abi cdecl abi fastcall abi ms_abi abi sysv_abi abi
        vectorcall abi thiscall abi may_alias abi
        visibility link dllimport link dllexport link asm link section link
        weak link alias link
        deprecated diagnostic format diagnostic warn_unused_result diagnostic
        unused diagnostic unavailable diagnostic access diagnostic
        format_arg diagnostic sentinel diagnostic warning diagnostic error diagnostic
        malloc optimization pure optimization const optimization nothrow optimization
        leaf optimization cold optimization hot optimization noreturn optimization
        alloc_size optimization alloc_align optimization always_inline optimization
        noinline optimization gnu_inline optimization artificial optimization
        returns_twice optimization fd_arg diagnostic
        nonnull nullability returns_nonnull nullability
        extension none
    }
}

# ---------------------------------------------------------------------------
# Small helpers.

proc ::census::row {k v {note ""}} {
    if {$note eq ""} { return [list $k $v] }
    return [list $k $v $note]
}

proc ::census::inc {dictVar key {n 1}} {
    upvar 1 $dictVar d
    dict incr d $key $n
}

proc ::census::sortedRows {d {prefix ""}} {
    set rows {}
    foreach {k v} [lsort -stride 2 -index 1 -integer -decreasing [dict get [dict create {*}[lsort -stride 2 $d]]]] {
        lappend rows [list "$prefix$k" $v]
    }
    return $rows
}

proc ::census::body {r} { lindex $r 2 }

# Every type node of TYPE, pre-order, with parameter types of function
# nodes included.
proc ::census::nodes {type} {
    set out [list $type]
    switch -- [lindex $type 0] {
        q { lappend out {*}[nodes [lindex $type 2]] }
        ptr - block { lappend out {*}[nodes [lindex $type 1]] }
        array { lappend out {*}[nodes [lindex $type 1]] }
        atomic { lappend out {*}[nodes [lindex $type 1]] }
        fn {
            lappend out {*}[nodes [lindex $type 1]]
            foreach p [lindex $type 2] { lappend out {*}[nodes [lindex $p 1]] }
        }
    }
    return $out
}

# The nodes of the declared object's own type: like `nodes`, but not
# entering a function type (its parameters and result belong to it).
proc ::census::ownNodes {type} {
    set out [list $type]
    switch -- [lindex $type 0] {
        q { lappend out {*}[ownNodes [lindex $type 2]] }
        ptr - block { lappend out {*}[ownNodes [lindex $type 1]] }
        array { lappend out {*}[ownNodes [lindex $type 1]] }
        atomic { lappend out {*}[ownNodes [lindex $type 1]] }
    }
    return $out
}

proc ::census::unq {t} { ::cir::unq $t }
proc ::census::final {t} { variable ix; ::cir::final $ix $t }

# The category of a type after typedef resolution: void bool int float
# complex ptr fn array struct union enum builtin typeof bitint unknown.
proc ::census::cat {t} {
    set f [unq [final $t]]
    set h [lindex $f 0]
    if {$h eq "typedef"} { return unknown }
    if {$h eq "atomic"} { return [cat [lindex $f 1]] }
    return $h
}

proc ::census::isFnPtr {t} {
    set f [unq [final $t]]
    expr {[lindex $f 0] eq "ptr" && [cat [lindex $f 1]] eq "fn"}
}

# Is the tag (struct T / union T / enum T) defined anywhere in the TU?
proc ::census::complete {key} {
    variable ix
    expr {[dict exists $ix tag $key] && [dict get $ix tag $key complete]}
}

proc ::census::tagKey {t} {
    set f [unq [final $t]]
    if {[lindex $f 0] in {struct union enum}} { return "[lindex $f 0] [lindex $f 1]" }
    return ""
}

# Pointer depth of a type: the number of pointer levels before a
# non-pointer, syntactically (typedefs not followed) and resolved.
proc ::census::depth {t {resolve 0}} {
    set n 0
    while 1 {
        set t [unq [expr {$resolve ? [final $t] : $t}]]
        if {[lindex $t 0] ne "ptr"} { return $n }
        incr n
        set t [lindex $t 1]
    }
}

# The category of what a pointer finally points to (after all pointer
# levels): opaque-struct complete-struct union enum scalar char void fn
# float bool builtin other.
proc ::census::pointee {t} {
    set t [unq [final $t]]
    while {[lindex $t 0] eq "ptr"} { set t [unq [final [lindex $t 1]]] }
    switch -- [lindex $t 0] {
        struct {
            return [expr {[complete "struct [lindex $t 1]"] ? "complete-struct" : "opaque-struct"}]
        }
        union { return [expr {[complete "union [lindex $t 1]"] ? "union" : "opaque-union"}] }
        enum { return enum }
        int { return [expr {[lindex $t 1] in {char {signed char} {unsigned char}} ? "char" : "scalar"}] }
        void { return void }
        fn { return fn }
        float - complex { return float }
        bool { return bool }
        builtin { return builtin }
        array { return array }
        default { return other }
    }
}

# The library's functions, typedefs, ... (records of origin public or
# bundled; internal only when the profile reaches internal headers).
proc ::census::ofKind {records kind} {
    set out {}
    foreach r $records { if {[lindex $r 0] eq $kind} { lappend out $r } }
    return $out
}

# The parameter list and result of a function record.
proc ::census::sig {r} {
    set t [dict get [body $r] type]
    return [list [lindex $t 1] [lindex $t 2] [lindex $t 3]]
}

# ---------------------------------------------------------------------------
# The system declarations library declarations refer to, transitively.

proc ::census::systemClosure {library system} {
    set sysIx [::cir::index $system]
    set want [dict create]
    set queue {}
    foreach r $library { lappend queue {*}[Refs $r] }
    while {[llength $queue]} {
        set ref [lindex $queue 0]
        set queue [lrange $queue 1 end]
        if {[dict exists $want $ref]} continue
        dict set want $ref 1
        lassign $ref kind name
        if {$kind eq "typedef" && [dict exists $sysIx typedef $name]} {
            lappend queue {*}[TypeRefs [dict get $sysIx typedef $name type]]
        } elseif {$kind eq "tag" && [dict exists $sysIx tag $name]} {
            foreach f [dict get $sysIx tag $name fields] { lappend queue {*}[TypeRefs [lindex $f 1]] }
        }
    }
    set out {}
    foreach r $system {
        lassign $r kind name body
        switch -- $kind {
            typedef { set key [list typedef $name] }
            struct { set key [list tag "[dict get $body kind] $name"] }
            enum { set key [list tag "enum $name"] }
            default { continue }
        }
        if {[dict exists $want $key]} { lappend out $r }
    }
    return $out
}

proc ::census::Refs {r} {
    lassign $r kind name body
    set refs {}
    if {[dict exists $body type]} { lappend refs {*}[TypeRefs [dict get $body type]] }
    if {[dict exists $body fields]} {
        foreach f [dict get $body fields] { lappend refs {*}[TypeRefs [lindex $f 1]] }
    }
    return $refs
}

proc ::census::TypeRefs {t} {
    set refs {}
    foreach n [nodes $t] {
        switch -- [lindex $n 0] {
            typedef { lappend refs [list typedef [lindex $n 1]] }
            struct - union - enum { lappend refs [list tag "[lindex $n 0] [lindex $n 1]"] }
        }
    }
    return $refs
}

# ---------------------------------------------------------------------------
# The census.

proc ::census::compute {profile library system macros} {
    variable ix
    variable libIx
    set ix [::cir::index [concat $system $library]]
    set libIx [::cir::index $library]
    set c [dict create]
    # The census covers public and bundled declarations; internal ones are
    # counted in the top-level table only.
    set api {}
    foreach r $library {
        if {[dict get [body $r] origin] in {public bundled}} { lappend api $r }
    }
    dict set c toplevel [TopLevel $library]
    dict set c functions [Functions $api]
    dict set c types [Types $api]
    dict set c pointers [Pointers $api]
    dict set c qualifiers [Qualifiers $api]
    dict set c typedefs [Typedefs $api]
    dict set c structs [Structs $api]
    dict set c fields [Fields $api]
    dict set c layout [Layout $api]
    dict set c arrays [Arrays $api]
    dict set c unions [Unions $api]
    dict set c bitfields [Bitfields $api]
    dict set c enums [Enums $api]
    dict set c constants [Constants $api $macros]
    dict set c callbacks [Callbacks $api]
    dict set c opaque [Opaque $api]
    dict set c strings [Strings $api]
    dict set c outparams [OutParams $api]
    dict set c attributes [Attributes $api $system]
    dict set c variadic [Variadic $api]
    dict set c byvalue [ByValue $api]
    dict set c inline [Inlines $api]
    dict set c links [Links $library]
    dict set c subset [Subset $api]
    set public {}
    foreach r $api { if {[dict get [body $r] origin] eq "public"} { lappend public $r } }
    if {[llength $public] != [llength $api]} {
        dict set c subset-public-only [Subset $public]
    }
    dict set c unsupported [Unsupported $library $system]
    dict set c macros [Macros $macros $api]
    dict set c declmacros [DeclarationMacros $macros $api]
    dict set c systemrefs [SystemRefs $api $system]
    return $c
}

proc ::census::TopLevel {records} {
    set by [dict create]
    foreach r $records {
        lassign $r kind name body
        set o [dict get $body origin]
        switch -- $kind {
            function {
                inc by "$o functions"
                if {[dict get $body definition]} { inc by "$o functions-inline-definitions" } else { inc by "$o functions-declared" }
            }
            typedef { inc by "$o typedefs" }
            variable { inc by "$o extern-objects-and-variables" }
            struct {
                set k [dict get $body kind]
                inc by "$o $k-declarations"
                if {[dict get $body complete]} { inc by "$o $k-definitions" }
            }
            enum {
                inc by "$o enum-declarations"
                if {[dict get $body complete]} { inc by "$o enum-definitions" }
            }
            unsupported { inc by "$o unsupported" }
            pragma { inc by "$o pragmas" }
            static_assert { inc by "$o static-asserts" }
            default { inc by "$o $kind" }
        }
    }
    # Tags: distinct tags referenced or declared by the API, complete or not.
    set tags [dict create]
    foreach r $records {
        if {[dict get [body $r] origin] ni {public bundled}} continue
        foreach ref [Refs $r] {
            if {[lindex $ref 0] eq "tag"} { dict set tags [lindex $ref 1] 1 }
        }
        if {[lindex $r 0] eq "struct"} { dict set tags "[dict get [body $r] kind] [lindex $r 1]" 1 }
        if {[lindex $r 0] eq "enum"} { dict set tags "enum [lindex $r 1]" 1 }
    }
    variable ix
    set t [dict create]
    foreach key [dict keys $tags] {
        lassign $key kw
        set where none
        if {[dict exists $ix tag $key] && [dict get $ix tag $key complete]} {
            set where [dict get $ix tag $key origin]
        }
        inc t "$kw tags, defined in: $where"
    }
    set rows [sortedRows $by]
    lappend rows {*}[sortedRows $t "api "]
    return $rows
}

# --- functions -------------------------------------------------------------

proc ::census::Functions {api} {
    set d [dict create]
    set fns [ofKind $api function]
    foreach r $fns {
        set b [body $r]
        set kind [expr {[dict get $b definition] ? "inline" : "extern"}]
        inc d "$kind total"
        lassign [sig $r] result params flags
        set types [list $result]
        foreach p $params { lappend types [lindex $p 1] }
        set f [Features $result $params $flags]
        foreach feature $f { inc d "$kind $feature" }
        inc d "$kind params=[expr {[llength $params] > 6 ? ">6" : [llength $params]}]"
    }
    return [sortedRows $d]
}

# The signature features of a function: a list of words.
proc ::census::Features {result params flags} {
    set f {}
    set any 0
    set ptrs 0
    set types [list $result]
    foreach p $params { lappend types [lindex $p 1] }
    foreach t $types {
        foreach n [nodes $t] { if {[lindex $n 0] eq "ptr"} { set any 1 } }
        if {[cat $t] eq "ptr"} { set ptrs 1 }
        if {[depth $t 1] >= 2} { lappend f pointer-to-pointer }
        if {[cat $t] in {struct}} { lappend f struct-by-value }
        if {[cat $t] in {union}} { lappend f union-by-value }
        if {[cat $t] eq "enum"} { lappend f enum }
        if {[cat $t] in {float complex}} { lappend f floating }
        if {[cat $t] eq "bool"} { lappend f bool }
        if {[cat $t] eq "builtin"} { lappend f builtin-[lindex [unq [final $t]] 1] }
        if {[cat $t] eq "int" && [lindex [unq [final $t]] 1] in {__int128 {unsigned __int128}}} { lappend f int128 }
    }
    if {!$any && !$ptrs} { lappend f no-pointers } else { lappend f pointers }
    if {[cat $result] eq "ptr"} { lappend f pointer-result }
    if {[isFnPtr $result]} { lappend f function-pointer-result }
    foreach p $params {
        set t [lindex $p 1]
        if {[isFnPtr $t] || [cat $t] eq "fn"} { lappend f function-pointer-param }
        if {[lindex [unq $t] 0] eq "array"} { lappend f array-param-spelling }
        if {[cat $t] eq "ptr" && ![isFnPtr $t]} { lappend f pointer-param }
    }
    if {"variadic" in $flags} { lappend f variadic }
    if {"noproto" in $flags} { lappend f no-prototype }
    if {[cat $result] eq "void"} { lappend f void-result }
    return [lsort -unique $f]
}

# --- types -----------------------------------------------------------------

# Every type a library declaration spells: function types, typedef targets,
# fields, variables.
proc ::census::AllTypes {api} {
    set out {}
    foreach r $api {
        lassign $r kind name body
        switch -- $kind {
            function - typedef - variable { lappend out [list $kind $name [dict get $body type]] }
            struct {
                foreach f [dict get $body fields] { lappend out [list field "$name.[lindex $f 0]" [lindex $f 1]] }
            }
        }
    }
    return $out
}

proc ::census::Types {api} {
    variable libIx
    set d [dict create]
    set maxDepth 0
    set maxResolved 0
    foreach item [AllTypes $api] {
        set t [lindex $item 2]
        foreach n [nodes $t] {
            set h [lindex $n 0]
            switch -- $h {
                int { inc d "integer [lindex $n 1]" }
                float { inc d "floating [lindex $n 1]" }
                complex { inc d "complex [lindex $n 1]" }
                bool { inc d "_Bool" }
                void { inc d "void" }
                typedef {
                    set which [expr {[dict exists $libIx typedef [lindex $n 1]] ? "library" : "system"}]
                    inc d "typedef-reference ($which)"
                }
                struct - union - enum { inc d "$h-reference" }
                ptr { inc d "pointer" }
                block { inc d "block-pointer" }
                array { inc d "array" }
                fn { inc d "function" }
                q { inc d "qualified" }
                builtin { inc d "builtin [lindex $n 1]" }
                typeof { inc d "typeof" }
                atomic { inc d "_Atomic(T)" }
                bitint { inc d "_BitInt" }
            }
        }
        set dd [depth $t]
        if {$dd > $maxDepth} { set maxDepth $dd }
        # Depth through parameters too.
        foreach n [nodes $t] {
            set dd [depth $n]
            if {$dd > $maxDepth} { set maxDepth $dd }
            set dr [depth $n 1]
            if {$dr > $maxResolved} { set maxResolved $dr }
        }
    }
    set rows [sortedRows $d]
    lappend rows [row "max pointer depth (as spelled)" $maxDepth]
    lappend rows [row "max pointer depth (typedefs resolved)" $maxResolved]
    return $rows
}

# Pointer depth and pointee category of every parameter, result, field and
# typedef target that is a pointer.
proc ::census::Pointers {api} {
    set d [dict create]
    foreach item [PositionTypes $api] {
        lassign $item position name t
        set dr [depth $t 1]
        if {$dr == 0} continue
        set ds [depth $t]
        set p [pointee $t]
        if {$p eq "fn" && $dr == 1} { set p "function" }
        inc d "$position depth=$dr"
        inc d "$position depth=$dr pointee=$p"
        if {$ds != $dr} { inc d "$position depth hidden by a typedef ($ds as spelled, $dr resolved)" }
        set first [unq [lindex [unq $t] 1]]
        if {[lindex [unq $t] 0] eq "ptr" && [lindex $first 0] eq "typedef"} {
            inc d "$position pointee spelled through a typedef"
        }
    }
    return [sortedRows $d]
}

# {POSITION NAME TYPE}: param, result, field, typedef, variable.
proc ::census::PositionTypes {api} {
    set out {}
    foreach r $api {
        lassign $r kind name body
        switch -- $kind {
            function {
                lassign [sig $r] result params
                lappend out [list result $name $result]
                foreach p $params { lappend out [list param "${name}([lindex $p 0])" [lindex $p 1]] }
            }
            typedef { lappend out [list typedef $name [dict get $body type]] }
            variable { lappend out [list variable $name [dict get $body type]] }
            struct {
                foreach f [dict get $body fields] { lappend out [list field "$name.[lindex $f 0]" [lindex $f 1]] }
            }
        }
    }
    return $out
}

proc ::census::Qualifiers {api} {
    set d [dict create]
    foreach item [PositionTypes $api] {
        lassign $item position name t
        # Top-level qualifiers of the declared object itself.
        foreach q [::cir::quals $t] { inc d "$position top-level $q" }
        set u [unq $t]
        # Qualifiers of pointees (const T *, T *const *, ...).
        set level 0
        while {[lindex $u 0] eq "ptr"} {
            incr level
            set inner [lindex $u 1]
            foreach q [::cir::quals $inner] { inc d "$position pointee(level $level) $q" }
            set u [unq $inner]
        }
        foreach n [nodes $t] {
            if {[lindex $n 0] eq "q"} {
                foreach q [lindex $n 1] { inc d "any $q" }
            }
        }
    }
    return [sortedRows $d]
}

# --- typedefs --------------------------------------------------------------

proc ::census::TypedefCategory {t} {
    variable ix
    set u [unq $t]
    if {[lindex $u 0] eq "typedef"} {
        set res [final $t]
        return "alias-of-typedef -> [TypedefCategory $res]"
    }
    switch -- [lindex $u 0] {
        struct - union {
            set key "[lindex $u 0] [lindex $u 1]"
            if {[complete $key]} { return "[lindex $u 0] (complete)" }
            return "[lindex $u 0] (opaque)"
        }
        enum { return enum }
        int { return integer }
        float - complex { return floating }
        bool { return bool }
        void { return void }
        builtin { return "builtin [lindex $u 1]" }
        fn { return "function type" }
        array { return array }
        ptr {
            set inner [unq [final [lindex $u 1]]]
            switch -- [lindex $inner 0] {
                fn { return "function pointer" }
                struct - union {
                    set key "[lindex $inner 0] [lindex $inner 1]"
                    return [expr {[complete $key] ? "pointer to complete [lindex $inner 0]" : "pointer to opaque [lindex $inner 0]"}]
                }
                void { return "pointer to void" }
                int { return "pointer to [expr {[lindex $inner 1] in {char {signed char} {unsigned char}} ? {char} : {integer}}]" }
                ptr { return "pointer to pointer" }
                default { return "pointer to [lindex $inner 0]" }
            }
        }
    }
    return [lindex $u 0]
}

proc ::census::Typedefs {api} {
    variable ix
    set d [dict create]
    set chains [dict create]
    set intNames [dict create]
    foreach r [ofKind $api typedef] {
        lassign $r kind name body
        set t [dict get $body type]
        set cat [TypedefCategory $t]
        inc d "category $cat"
        lassign [::cir::resolve $ix [list typedef $name]] chain final
        set n [llength $chain]
        inc chains "chain length $n"
        if {[cat $t] eq "int"} {
            dict lappend intNames [lindex [unq $final] 1] $name
        }
    }
    # The typedefs functions actually use, by where they are defined.
    set used [dict create]
    foreach r [ofKind $api function] {
        lassign [sig $r] result params
        set ts [list $result]
        foreach p $params { lappend ts [lindex $p 1] }
        foreach t $ts {
            foreach n [nodes $t] {
                if {[lindex $n 0] eq "typedef"} { dict set used [lindex $n 1] 1 }
            }
        }
    }
    variable libIx
    set usedLib 0
    set usedSys 0
    set sysNames {}
    foreach u [dict keys $used] {
        if {[dict exists $libIx typedef $u]} { incr usedLib } else { incr usedSys; lappend sysNames $u }
    }
    set rows [sortedRows $d]
    lappend rows {*}[lsort -index 0 [sortedRows $chains]]
    lappend rows [row "distinct typedef names used in function signatures (library)" $usedLib]
    lappend rows [row "distinct typedef names used in function signatures (system)" $usedSys [lsort $sysNames]]
    foreach {repr names} [lsort -stride 2 $intNames] {
        lappend rows [row "integer typedefs over $repr" [llength $names] [lsort $names]]
    }
    return $rows
}

# --- structs ---------------------------------------------------------------

# Complete structs and unions defined by the API, one per tag.
proc ::census::CompleteTags {api} {
    set out [dict create]
    foreach r $api {
        lassign $r kind name body
        if {$kind eq "struct" && [dict get $body complete]} {
            dict set out "[dict get $body kind] $name" $r
        }
    }
    return $out
}

proc ::census::Structs {api} {
    variable ix
    set d [dict create]
    set complete [CompleteTags $api]
    # Declared tags (forward declarations and references) never completed.
    set opaque [dict create]
    foreach r $api {
        foreach ref [Refs $r] {
            if {[lindex $ref 0] eq "tag" && [lindex [lindex $ref 1] 0] in {struct union} && ![complete [lindex $ref 1]]} {
                dict set opaque [lindex $ref 1] 1
            }
        }
        if {[lindex $r 0] eq "struct" && ![complete "[dict get [body $r] kind] [lindex $r 1]"]} {
            dict set opaque "[dict get [body $r] kind] [lindex $r 1]" 1
        }
    }
    set structs 0
    set unions 0
    set anon 0
    set nested 0
    foreach {key r} $complete {
        set b [body $r]
        if {[lindex $key 0] eq "struct"} { incr structs } else { incr unions }
        if {[dict get $b anonymous]} { incr anon }
        if {[dict exists $b parent]} { incr nested }
    }
    set rows {}
    lappend rows [row "complete structs" $structs]
    lappend rows [row "complete unions" $unions]
    lappend rows [row "complete, anonymous (no tag)" $anon]
    lappend rows [row "complete, defined inside another struct" $nested]
    set os 0
    set ou 0
    foreach key [dict keys $opaque] { if {[lindex $key 0] eq "struct"} { incr os } else { incr ou } }
    lappend rows [row "opaque structs (declared or referenced, defined nowhere in the TU)" $os]
    lappend rows [row "opaque unions" $ou]
    # How complete structs are used: by value anywhere (function, field of
    # another struct, variable) or only behind pointers.
    set byValue [dict create]
    set behind [dict create]
    foreach item [PositionTypes $api] {
        lassign $item position name t
        foreach n [nodes $t] {
            set key [tagKey $n]
            if {$key eq "" || ![dict exists $complete $key]} continue
        }
        set key [tagKey $t]
        if {$key ne "" && [dict exists $complete $key] && $position ne "typedef"} {
            dict set byValue $key $position
        }
        if {[cat $t] eq "ptr"} {
            set p [unq [final $t]]
            while {[lindex $p 0] eq "ptr"} { set p [unq [final [lindex $p 1]]] }
            set k [tagKey $p]
            if {$k ne "" && [dict exists $complete $k]} { dict set behind $k 1 }
        }
    }
    set onlyPtr 0
    set neither 0
    foreach key [dict keys $complete] {
        if {[dict exists $byValue $key]} continue
        if {[dict exists $behind $key]} { incr onlyPtr } else { incr neither }
    }
    # Documentation hints (heuristic, reporting only).
    set hinted [dict create]
    foreach {key r} $complete {
        set b [body $r]
        if {[dict get $b anonymous] && [dict exists $b parent]} continue
        set h [expr {[dict exists $b dochints] ? [dict get $b dochints] : {}}]
        set keepout [expr {[llength [lsearch -all -inline -regexp $h {^(private|opaque|internal|do-not)$}]] > 0}]
        dict incr hinted [expr {$keepout ? "complete, its comments say keep out (private/opaque/internal/do not): heuristic" : "complete, no keep-out comment: heuristic"}]
    }
    foreach {k v} $hinted { lappend rows [row $k $v] }
    lappend rows [row "complete, used by value somewhere (param/result/field/variable)" [dict size $byValue]]
    lappend rows [row "complete, used only behind pointers" $onlyPtr]
    lappend rows [row "complete, not used by any declaration (or only via typedef)" $neither]
    return $rows
}

# The category of a field type for the field census.
proc ::census::FieldCategory {f} {
    lassign $f name t bits
    if {$bits ne ""} { return bitfield }
    set u [unq $t]
    set via [expr {[lindex $u 0] eq "typedef"}]
    switch -- [cat $t] {
        int { return [expr {$via ? "typedef scalar" : "integer scalar"}] }
        enum { return enum }
        bool { return bool }
        float - complex { return float }
        ptr { return [expr {[isFnPtr $t] ? "function pointer" : "pointer"}] }
        struct { return [expr {$name eq "" ? "anonymous struct member" : "nested struct by value"}] }
        union { return [expr {$name eq "" ? "anonymous union member" : "union by value"}] }
        array {
            set a [unq [final $t]]
            if {[lindex $a 2] eq ""} { return "flexible or unknown-length array" }
            return "fixed array"
        }
        builtin { return "builtin [lindex [unq [final $t]] 1]" }
        default { return other }
    }
}

proc ::census::Fields {api} {
    set d [dict create]
    foreach {key r} [CompleteTags $api] {
        foreach f [dict get [body $r] fields] {
            inc d "[lindex $key 0] field: [FieldCategory $f]"
        }
    }
    return [sortedRows $d]
}

# The layout requirements of a complete struct (C-HEADER-ARCHAEOLOGY.md,
# "Layout mapping"): a set of NEEDS-* words, recursive through by-value
# nested structs and anonymous members; enum fields add ABI-ENUM-WIDTH (an
# ABI fact, not a layout feature).
proc ::census::Requirements {key {seen {}}} {
    variable ix
    if {$key in $seen} { return {NEEDS-OTHER} }
    lappend seen $key
    set needs {}
    if {[lindex $key 0] eq "union"} { lappend needs NEEDS-UNION }
    if {![dict exists $ix tag $key]} { return [list NEEDS-OTHER] }
    foreach f [dict get $ix tag $key fields] {
        lassign $f name t bits
        if {$bits ne ""} { lappend needs NEEDS-BITFIELD; continue }
        lappend needs {*}[TypeNeeds $t $seen]
    }
    return [lsort -unique $needs]
}

proc ::census::TypeNeeds {t seen} {
    switch -- [cat $t] {
        int {
            set s [lindex [unq [final $t]] 1]
            if {$s in {__int128 {unsigned __int128}}} { return NEEDS-OTHER }
            if {$s eq "char"} { return ABI-CHAR-SIGNEDNESS }
            return {}
        }
        enum { return ABI-ENUM-WIDTH }
        bool { return NEEDS-OTHER }
        float - complex { return NEEDS-FLOAT }
        ptr { return NEEDS-POINTER-SCALAR }
        struct - union {
            set key [tagKey $t]
            if {![complete $key]} { return NEEDS-OTHER }
            return [Requirements $key $seen]
        }
        array {
            set a [unq [final $t]]
            if {[lindex $a 2] eq ""} { return [concat NEEDS-OTHER [TypeNeeds [lindex $a 1] $seen]] }
            return [concat NEEDS-FIXED-ARRAY [TypeNeeds [lindex $a 1] $seen]]
        }
        default { return NEEDS-OTHER }
    }
}

# An opaque-storage union: a byte array beside one scalar whose only job is
# alignment (BoringSSL's `union { uint8_t bytes[N]; uint32_t alignment; }`).
proc ::census::IsStorageUnion {key} {
    variable ix
    if {[lindex $key 0] ne "union" || ![dict exists $ix tag $key]} { return 0 }
    set fields [dict get $ix tag $key fields]
    if {[llength $fields] != 2} { return 0 }
    set bytes 0
    set align 0
    foreach f $fields {
        lassign $f name t
        set u [unq [final $t]]
        if {[lindex $u 0] eq "array" && [lindex [unq [final [lindex $u 1]]] 1] in {{unsigned char} char}} { incr bytes }
        if {[lindex $u 0] eq "int" && [regexp -nocase {align} $name]} { incr align }
    }
    expr {$bytes == 1 && $align == 1}
}

# A struct whose every field is opaque storage: such a struct is complete
# only so that consumers can allocate it (sizeof, alignof), never to be
# read field by field.
proc ::census::IsStorageOnly {key} {
    variable ix
    if {[IsStorageUnion $key]} { return 1 }
    if {![dict exists $ix tag $key]} { return 0 }
    set fields [dict get $ix tag $key fields]
    if {$fields eq ""} { return 0 }
    foreach f $fields {
        set k [tagKey [lindex $f 1]]
        if {$k eq "" || ![IsStorageUnion $k]} { return 0 }
    }
    return 1
}

proc ::census::Layout {api} {
    set d [dict create]
    set combos [dict create]
    set rows {}
    set total 0
    set examples [dict create]
    foreach {key r} [CompleteTags $api] {
        if {[dict get [body $r] anonymous] && [dict exists [body $r] parent]} continue
        incr total
        set needs [Requirements $key]
        set layoutNeeds [lsearch -all -inline -glob $needs NEEDS-*]
        if {$layoutNeeds eq ""} {
            inc d REPRESENTABLE-NOW
            dict lappend examples REPRESENTABLE-NOW $key
        }
        foreach n $layoutNeeds { inc d $n; dict lappend examples $n $key }
        foreach n [lsearch -all -inline -glob $needs ABI-*] { inc d "(abi fact) $n" }
        inc combos [expr {$layoutNeeds eq "" ? "REPRESENTABLE-NOW" : [join $layoutNeeds +]}]
    }
    lappend rows [row "complete structs and unions (top-level or named)" $total]
    foreach k {REPRESENTABLE-NOW NEEDS-POINTER-SCALAR NEEDS-FIXED-ARRAY NEEDS-FLOAT NEEDS-UNION NEEDS-BITFIELD NEEDS-OTHER} {
        set n [expr {[dict exists $d $k] ? [dict get $d $k] : 0}]
        set ex [expr {[dict exists $examples $k] ? [lrange [lsort [dict get $examples $k]] 0 5] : {}}]
        lappend rows [row $k $n $ex]
    }
    foreach k [lsort [dict keys $d "(abi fact)*"]] { lappend rows [row $k [dict get $d $k]] }
    foreach r [sortedRows $combos "combination "] { lappend rows $r }
    # Single-feature unlocks: structs whose only blocker is one feature, or
    # a pair.
    set unlock [dict create]
    foreach {combo n} $combos {
        set parts [split $combo +]
        if {$combo eq "REPRESENTABLE-NOW"} continue
        foreach a {NEEDS-POINTER-SCALAR NEEDS-FIXED-ARRAY NEEDS-FLOAT NEEDS-UNION NEEDS-BITFIELD} {
            if {[lsort $parts] eq [list $a]} { inc unlock "unlocked by $a alone" $n }
        }
        if {[lsort $parts] eq [lsort {NEEDS-POINTER-SCALAR NEEDS-FIXED-ARRAY}]} {
            inc unlock "unlocked by pointer scalar + fixed array together" $n
        }
        if {[llength [lsearch -all -inline -not -regexp $parts {NEEDS-(POINTER-SCALAR|FIXED-ARRAY|UNION)}]] == 0} {
            inc unlock "unlocked by pointer scalar + fixed array + union" $n
        }
    }
    foreach r [sortedRows $unlock] { lappend rows $r }
    # Storage-only structs: their requirements as written, and what they
    # need if imported as size + alignment alone.
    set storage 0
    set storageCombos [dict create]
    set storageEx {}
    foreach {key r} [CompleteTags $api] {
        if {[dict get [body $r] anonymous] && [dict exists [body $r] parent]} continue
        if {[lindex $key 0] ne "struct" || ![IsStorageOnly $key]} continue
        incr storage
        lappend storageEx [lindex $key 1]
        dict incr storageCombos [join [lsearch -all -inline -glob [Requirements $key] NEEDS-*] +]
    }
    lappend rows [row "storage-only structs (every field an opaque-storage union: size + alignment suffice)" $storage [lrange $storageEx 0 7]]
    foreach {k v} $storageCombos { lappend rows [row "storage-only structs whose fields as written need $k" $v] }
    return $rows
}

proc ::census::Arrays {api} {
    set d [dict create]
    foreach item [PositionTypes $api] {
        lassign $item where name t
        set own [ownNodes $t]
        foreach n [nodes $t] {
            if {[lindex $n 0] ne "array"} continue
            set position $where
            if {[lsearch -exact $own $n] < 0} { set position "$where (inside a function type)" }
            set bound [lindex $n 2]
            set elem [lindex $n 1]
            set form [lindex $bound 0]
            if {$form eq ""} { set form unknown-length }
            if {$form eq "expr"} {
                set form "expr:[ExprShape [lindex $bound 1]]"
            }
            inc d "$position bound $form"
            set e [unq [final $elem]]
            switch -- [lindex $e 0] {
                int {
                    set ek [expr {[lindex $e 1] in {char {signed char}} ? "char" : ([lindex $e 1] eq "unsigned char" ? "byte" : "scalar")}]
                }
                array { set ek multidimensional }
                ptr { set ek pointer }
                struct - union { set ek [lindex $e 0] }
                default { set ek [lindex $e 0] }
            }
            inc d "$position element $ek"
        }
    }
    # Flexible array members: an unknown-length array as a struct's last field.
    foreach {key r} [CompleteTags $api] {
        set fields [dict get [body $r] fields]
        set last [lindex $fields end]
        set u [unq [final [lindex $last 1]]]
        if {[lindex $u 0] eq "array" && [lindex $u 2] eq ""} { inc d "flexible array member" }
    }
    return [sortedRows $d]
}

# The shape of a constant expression: the operators and operand kinds it
# uses, coarse (no evaluation).
proc ::census::ExprShape {text} {
    set s {}
    if {[regexp {\msizeof\M} $text]} { lappend s sizeof }
    if {[regexp {_Alignof|__alignof__} $text]} { lappend s alignof }
    if {[regexp {<<|>>} $text]} { lappend s shift }
    if {[regexp {\|} $text]} { lappend s or }
    if {[regexp {&} $text]} { lappend s and }
    if {[regexp {[*/]} $text]} { lappend s muldiv }
    if {[regexp {\+|(\w|\))\s*-} $text]} { lappend s addsub }
    if {[regexp {~} $text]} { lappend s complement }
    if {[regexp {^\s*-} $text]} { lappend s negate }
    if {[regexp {\(\s*(unsigned|signed|int|long|short|char|uint\w*|int\w*|size_t)[\w\s]*\)} $text]} { lappend s cast }
    if {[regexp {[A-Za-z_]\w*} [regsub -all {\m(sizeof|unsigned|signed|int|long|short|char|0x[0-9a-fA-F]+[uUlL]*|[0-9]+[uUlL]*)\M} $text {}]]} {
        lappend s identifier
    }
    if {$s eq ""} { return literal-like }
    return [join $s +]
}

proc ::census::Unions {api} {
    set d [dict create]
    set complete [CompleteTags $api]
    foreach {key r} $complete {
        if {[lindex $key 0] ne "union"} continue
        set b [body $r]
        if {[IsStorageUnion $key]} { inc d "union definitions: opaque storage (a byte array and an alignment scalar)" }
        if {[dict get $b anonymous]} { inc d "union definitions, anonymous" } else { inc d "union definitions, tagged" }
        if {[dict exists $b parent]} { inc d "union definitions inside a struct" }
    }
    foreach item [PositionTypes $api] {
        lassign $item position name t
        if {[cat $t] eq "union"} { inc d "$position union by value" }
        if {[cat $t] eq "ptr" && [pointee $t] in {union opaque-union}} { inc d "$position pointer to union" }
    }
    return [sortedRows $d]
}

proc ::census::Bitfields {api} {
    set rows {}
    set n 0
    foreach {key r} [CompleteTags $api] {
        foreach f [dict get [body $r] fields] {
            lassign $f name t bits
            if {$bits eq ""} continue
            incr n
            lappend rows [row "$key.[expr {$name eq {} ? {(unnamed)} : $name}]" "[::cir::spell $t] : [lrange $bits 1 end]"]
        }
    }
    return [linsert $rows 0 [row "bitfields" $n]]
}

proc ::census::Enums {api} {
    variable ix
    set d [dict create]
    set used [dict create]
    foreach r [ofKind $api function] {
        lassign [sig $r] result params
        set ts [list $result]
        foreach p $params { lappend ts [lindex $p 1] }
        foreach t $ts {
            set k [tagKey $t]
            if {[string match "enum *" $k]} { dict set used $k 1 }
            if {[cat $t] eq "ptr" && [pointee $t] eq "enum"} { inc d "enum pointer params/results" }
        }
    }
    foreach item [PositionTypes $api] {
        lassign $item position name t
        if {[cat $t] eq "enum"} { inc d "enum-typed $position" }
    }
    set typedefd [dict create]
    foreach r [ofKind $api typedef] {
        set u [unq [dict get [body $r] type]]
        if {[lindex $u 0] eq "enum"} { dict set typedefd "enum [lindex $u 1]" 1 }
    }
    set allLiteral 0
    set enums 0
    foreach r [ofKind $api enum] {
        lassign $r kind tag body
        if {![dict get $body complete]} { inc d "enum forward declarations"; continue }
        incr enums
        set key "enum $tag"
        if {[dict get $body anonymous]} { inc d "enum definitions, anonymous (constants only)" } else { inc d "enum definitions, tagged" }
        if {[dict exists $typedefd $key]} { inc d "enum definitions with a typedef" }
        if {[dict exists $used $key]} { inc d "enum types used in function signatures" }
        set computable 1
        foreach e [dict get $body enumerators] {
            lassign $e ename form value text
            inc d "enumerators"
            inc d "enumerator value form: $form"
            if {$form eq "expr"} {
                inc d "enumerator expression shape: [ExprShape $text]"
            }
            if {$value eq ""} { set computable 0 }
            if {$value ne "" && ($value < -2147483648 || $value > 2147483647)} { inc d "enumerator values outside int" }
            if {$value ne "" && $value > 2147483647} { inc d "enumerator values above INT_MAX" }
        }
        if {$computable} { incr allLiteral }
    }
    set rows [sortedRows $d]
    lappend rows [row "enums whose every value the parser computes (literal, negated literal, char, previous enumerator, implicit)" "$allLiteral of $enums"]
    return $rows
}

proc ::census::Constants {api macros} {
    set d [dict create]
    foreach r [ofKind $api enum] {
        if {[dict get [body $r] complete]} {
            inc d "enum member" [llength [dict get [body $r] enumerators]]
        }
    }
    foreach r [ofKind $api variable] {
        set b [body $r]
        set const [expr {"const" in [::cir::quals [dict get $b type]]}]
        if {[dict get $b storage] eq "static" && [dict exists $b init]} {
            inc d "static object with initializer in a header"
        } elseif {[dict get $b storage] eq "extern"} {
            inc d [expr {$const ? "extern const object" : "extern object (not const)"}]
        } else {
            inc d "other object ([dict get $b storage])"
        }
    }
    foreach m $macros {
        set b [body $m]
        if {[dict get $b form] ne "object"} continue
        if {[dict get $b undefined]} continue
        set c [MacroObjectCategory [lindex $m 1] $b]
        if {[string match constant* $c]} { inc d "macro $c" }
    }
    return [sortedRows $d]
}

# --- callbacks -------------------------------------------------------------

proc ::census::Callbacks {api} {
    variable ix
    set d [dict create]
    set signatures [dict create]
    # Callback typedefs: a typedef naming a function type or a function
    # pointer.
    foreach r [ofKind $api typedef] {
        set t [dict get [body $r] type]
        set u [unq $t]
        if {[lindex $u 0] eq "fn"} { inc d "callback typedefs naming a function type" }
        if {[lindex $u 0] eq "ptr" && [lindex [unq [lindex $u 1]] 0] eq "fn"} { inc d "callback typedefs naming a function pointer" }
    }
    set accepting 0
    set returning 0
    set userdata 0
    set withoutUserdata 0
    foreach r [ofKind $api function] {
        lassign [sig $r] result params flags
        set cbs {}
        foreach p $params {
            set t [lindex $p 1]
            if {[isFnPtr $t] || [cat $t] eq "fn"} { lappend cbs $t }
        }
        if {[isFnPtr $result]} { incr returning }
        if {$cbs eq ""} continue
        incr accepting
        if {[dict get [body $r] definition]} { inc d "functions accepting callbacks: inline definitions" }
        # The userdata convention: a void * beside the callback in the
        # registering function, and a void * among the callback's own
        # parameters.
        set fnVoid 0
        foreach p $params { if {[IsVoidPtr [lindex $p 1]]} { set fnVoid 1 } }
        foreach cb $cbs {
            set f [CallbackFn $cb]
            set cbVoid 0
            foreach p [lindex $f 2] { if {[IsVoidPtr [lindex $p 1]]} { set cbVoid 1 } }
            set conv [expr {$fnVoid && $cbVoid ? "void* userdata beside and inside" :
                            ($cbVoid ? "void* inside the callback only" :
                            ($fnVoid ? "void* beside the callback only" : "no void* userdata"))}]
            set where [expr {[dict get [body $r] definition] ? "inline" : "extern"}]
            inc d "callback params ($where functions): $conv"
            if {"variadic" in [lindex $f 3]} { inc d "variadic callback params" }
            dict incr signatures [SigShape $f]
        }
    }
    foreach {key r} [CompleteTags $api] {
        foreach f [dict get [body $r] fields] {
            if {[isFnPtr [lindex $f 1]]} {
                inc d "callback fields (function pointers in structs)"
                if {[regexp {Stubs$} [lindex $key 1]]} {
                    inc d "callback fields in stub tables (struct *Stubs: one per exported function)"
                } else {
                    inc d "callback fields outside stub tables"
                }
                dict incr signatures [SigShape [CallbackFn [lindex $f 1]]]
            }
        }
    }
    set rows [sortedRows $d]
    lappend rows [row "API functions accepting callbacks" $accepting]
    lappend rows [row "API functions returning a function pointer" $returning]
    lappend rows [row "distinct callback signature shapes (params and fields)" [dict size $signatures]]
    foreach r [lrange [sortedRows $signatures "shape "] 0 14] { lappend rows $r }
    return $rows
}

proc ::census::IsVoidPtr {t} {
    set u [unq [final $t]]
    expr {[lindex $u 0] eq "ptr" && [lindex [unq [final [lindex $u 1]]] 0] eq "void"}
}

# The function type behind a callback parameter or field type.
proc ::census::CallbackFn {t} {
    set u [unq [final $t]]
    if {[lindex $u 0] eq "ptr"} { set u [unq [final [lindex $u 1]]] }
    return $u
}

# A coarse signature shape: result and parameter categories.
proc ::census::SigShape {f} {
    set ps {}
    foreach p [lindex $f 2] { lappend ps [ShapeOf [lindex $p 1]] }
    if {"variadic" in [lindex $f 3]} { lappend ps ... }
    return "([join $ps {, }]) -> [ShapeOf [lindex $f 1]]"
}

proc ::census::ShapeOf {t} {
    switch -- [cat $t] {
        ptr {
            if {[isFnPtr $t]} { return fnptr }
            return "[string repeat * [depth $t 1]][pointee $t]"
        }
        int { return int }
        default { return [cat $t] }
    }
}

# --- opaque handles ----------------------------------------------------------

proc ::census::Opaque {api} {
    set d [dict create]
    set fns [ofKind $api function]
    set handleFns 0
    set onlyHandles 0
    foreach r $fns {
        if {[dict get [body $r] definition]} continue
        lassign [sig $r] result params flags
        set ts [list $result]
        foreach p $params { lappend ts [lindex $p 1] }
        set any 0
        set ok 1
        foreach t $ts {
            set c [cat $t]
            if {$c eq "ptr" && [pointee $t] in {opaque-struct opaque-union} && [depth $t 1] == 1} {
                set any 1
            } elseif {$c in {int void enum}} {
            } elseif {$c eq "ptr" && [pointee $t] in {char void scalar} && ![isFnPtr $t]} {
            } else {
                set ok 0
            }
        }
        if {$any} { incr handleFns }
        if {$any && $ok && "variadic" ni $flags} { incr onlyHandles }
    }
    # typedef struct X X; and typedef struct X_ *X;
    foreach r [ofKind $api typedef] {
        set u [unq [dict get [body $r] type]]
        if {[lindex $u 0] in {struct union} && ![complete "[lindex $u 0] [lindex $u 1]"]} {
            inc d "typedef names an opaque tag (typedef struct X X)"
        }
        if {[lindex $u 0] eq "ptr"} {
            set i [unq [lindex $u 1]]
            if {[lindex $i 0] in {struct union} && ![complete "[lindex $i 0] [lindex $i 1]"]} {
                inc d "typedef names a pointer to an opaque tag (typedef struct X_ *X)"
            }
        }
    }
    set rows [sortedRows $d]
    set declared [llength [lsearch -all -inline -exact [lmap r $fns {dict get [body $r] definition}] 0]]
    lappend rows [row "declared functions with an opaque handle (T * to an incomplete tag) in their signature" "$handleFns of $declared"]
    lappend rows [row "declared functions whose every type is an opaque handle, an integer, an enum, void, or a char/void/integer pointer" "$onlyHandles of $declared"]
    return $rows
}

# --- heuristic conventions (reporting only) --------------------------------

proc ::census::IsCharPtr {t {constness any}} {
    set u [unq [final $t]]
    if {[lindex $u 0] ne "ptr"} { return 0 }
    set p [lindex $u 1]
    set pu [unq [final $p]]
    if {[lindex $pu 0] ne "int" || [lindex $pu 1] ni {char {signed char} {unsigned char}}} { return 0 }
    set c [expr {"const" in [::cir::quals [final $p]] || "const" in [::cir::quals $p]}]
    if {$constness eq "const"} { return $c }
    if {$constness eq "mutable"} { return [expr {!$c}] }
    return 1
}

proc ::census::IsLengthParam {p} {
    lassign $p name t
    set c [cat $t]
    if {$c ne "int"} { return 0 }
    return 1
}

proc ::census::Strings {api} {
    set d [dict create]
    foreach r [ofKind $api function] {
        if {[dict get [body $r] definition]} continue
        lassign [sig $r] result params
        set n [llength $params]
        if {[IsCharPtr $result]} { inc d "results: [::cir::spell [unq [final $result]]]" }
        for {set i 0} {$i < $n} {incr i} {
            set p [lindex $params $i]
            set t [lindex $p 1]
            if {![IsCharPtr $t]} continue
            set spelled [::cir::spell [final $t]]
            inc d "params: $spelled"
            set next [lindex $params [expr {$i + 1}]]
            if {$next ne "" && [IsLengthParam $next]} {
                inc d "params: char-like pointer followed by an integer (pointer + length)"
            }
            if {$next ne "" && [cat [lindex $next 1]] eq "ptr" && [pointee [lindex $next 1]] eq "scalar" && [depth [lindex $next 1] 1] == 1} {
                inc d "params: char-like pointer followed by an integer pointer (pointer + output length)"
            }
        }
    }
    return [sortedRows $d]
}

proc ::census::OutParams {api} {
    set d [dict create]
    foreach r [ofKind $api function] {
        if {[dict get [body $r] definition]} continue
        lassign [sig $r] result params
        foreach p $params {
            lassign $p name t
            if {[cat $t] ne "ptr" || [isFnPtr $t]} continue
            set dr [depth $t 1]
            set u [unq [final $t]]
            set constPointee [expr {"const" in [::cir::quals [lindex $u 1]] || "const" in [::cir::quals [final [lindex $u 1]]]}]
            if {$dr >= 2} {
                inc d "T** params (non-const outer pointee: possible out-pointer)" [expr {!$constPointee}]
                inc d "T** params (const outer pointee)" $constPointee
            } elseif {[pointee $t] in {scalar enum} && !$constPointee} {
                inc d "pointer to non-const integer (possible out-scalar)"
            }
            if {[regexp -nocase {^out|out$|Ptr$|^p?out_|_out$|result} $name]} { inc d "params named like an output (out*, *Ptr, *result)" }
        }
    }
    return [sortedRows $d]
}

# --- attributes ------------------------------------------------------------

proc ::census::Attributes {api system} {
    variable attrClass
    set d [dict create]
    set rows {}
    foreach scope {api system} {
        set records [expr {$scope eq "api" ? $api : $system}]
        foreach r $records {
            foreach a [AllAttrs $r] {
                lassign $a form position name args
                if {$form in {asm cc}} { set name $form; set args [lindex $a 2] }
                set cls [expr {[dict exists $attrClass $name] ? [dict get $attrClass $name] : "unclassified"}]
                inc d "$scope $form $name ($cls) at $position"
            }
            # Qualifier-like extensions.
            if {[dict exists [body $r] type]} {
                foreach n [nodes [dict get [body $r] type]] {
                    if {[lindex $n 0] eq "q"} {
                        foreach q [lindex $n 1] {
                            if {$q ni {const volatile restrict}} { inc d "$scope qualifier $q" }
                        }
                    }
                    if {[lindex $n 0] in {typeof atomic bitint block}} { inc d "$scope type extension [lindex $n 0]" }
                }
            }
        }
    }
    return [sortedRows $d]
}

# Every attribute of a record: {FORM POSITION NAME ARGS}, its own and its
# parameters' and fields'.
proc ::census::AllAttrs {r} {
    set b [body $r]
    set out {}
    if {[dict exists $b attrs]} {
        foreach a [dict get $b attrs] { lappend out [NormAttr $a] }
    }
    if {[dict exists $b type]} {
        foreach n [nodes [dict get $b type]] {
            if {[lindex $n 0] eq "fn"} {
                foreach p [lindex $n 2] { foreach a [lindex $p 2] { lappend out [NormAttr $a] } }
            }
        }
    }
    if {[dict exists $b fields]} {
        foreach f [dict get $b fields] { foreach a [lindex $f 3] { lappend out [NormAttr $a] } }
    }
    return $out
}

proc ::census::NormAttr {a} {
    # {FORM POSITION NAME ARGS} or {asm POSITION LABEL} / {cc POSITION NAME}.
    if {[lindex $a 0] in {asm cc}} {
        return [list [lindex $a 0] [lindex $a 1] [lindex $a 2] ""]
    }
    if {[lindex $a 0] eq "extension"} { return [list extension [lindex $a 1] extension ""] }
    return $a
}

# --- variadics, by-value aggregates, inline definitions, links -------------

proc ::census::Variadic {api} {
    set rows {}
    set vaList 0
    foreach r [ofKind $api function] {
        lassign [sig $r] result params flags
        if {"variadic" in $flags} {
            lappend rows [row [lindex $r 1] [dict get [body $r] text]]
        }
        foreach p $params {
            if {[cat [lindex $p 1]] eq "builtin" || ([cat [lindex $p 1]] eq "ptr" && [pointee [lindex $p 1]] eq "builtin")} { incr vaList }
        }
    }
    set n [llength $rows]
    return [linsert $rows 0 [row "variadic functions" $n] [row "va_list (builtin) parameters" $vaList]]
}

proc ::census::ByValue {api} {
    set d [dict create]
    set rows {}
    foreach r [ofKind $api function] {
        lassign [sig $r] result params
        set def [expr {[dict get [body $r] definition] ? "inline" : "extern"}]
        if {[cat $result] in {struct union}} {
            inc d "$def returns [cat $result] by value"
            lappend rows [row "[lindex $r 1] (result)" [::cir::spell $result]]
        }
        foreach p $params {
            if {[cat [lindex $p 1]] in {struct union}} {
                inc d "$def takes [cat [lindex $p 1]] by value"
                lappend rows [row "[lindex $r 1]\([lindex $p 0]\)" [::cir::spell [lindex $p 1]]]
            }
        }
    }
    return [concat [sortedRows $d] $rows]
}

proc ::census::Inlines {api} {
    set d [dict create]
    foreach r [ofKind $api function] {
        set b [body $r]
        if {![dict get $b definition]} continue
        inc d "inline definitions (no link symbol)"
        inc d "storage [dict get $b storage], fnspec [join [dict get $b fnspec]]"
        set gen "written directly"
        if {[dict exists $b srcmacros]} {
            foreach m [dict get $b srcmacros] {
                if {[regexp {^(DEFINE_|DECLARE_|BORINGSSL_DEFINE|.*_DEFINE_)} $m]} { set gen "generated by $m" }
            }
        }
        inc d $gen
    }
    return [sortedRows $d]
}

proc ::census::Links {records} {
    set d [dict create]
    set rows {}
    foreach r $records {
        lassign $r kind name body
        if {$kind eq "function" && [dict exists $body link]} {
            inc d "functions with an asm label"
            lappend rows [row "asm label $name" [dict get $body link]]
        }
        if {$kind eq "pragma" && [regexp {^redefine_extname\s+(\S+)\s+(\S+)} [dict get $body text] -> old new]} {
            inc d "#pragma redefine_extname"
            if {[dict size $d] < 0} {}
        }
        if {$kind eq "pragma"} { inc d "pragma [lindex [dict get $body text] 0]" }
    }
    return [concat [sortedRows $d] [lrange $rows 0 20]]
}

# --- the simple-callable subset --------------------------------------------

# Why a function is outside the simple subset: a list of reasons, empty
# when it is inside (C-HEADER-ARCHAEOLOGY.md, "The simple-callable subset").
# LEVEL: simple, callbacks (top-level non-capturing callbacks whose own
# signatures are simple), floats (simple plus float/double).
proc ::census::Outside {r level} {
    set b [body $r]
    lassign [sig $r] result params flags
    set why {}
    if {[dict get $b definition]} { lappend why "inline definition (no symbol)" }
    if {"variadic" in $flags} { lappend why variadic }
    if {"noproto" in $flags} { lappend why "no prototype" }
    set ts [list result $result]
    foreach p $params { lappend ts param [lindex $p 1] }
    foreach {role t} $ts {
        lappend why {*}[TypeOutside $t $role $level]
    }
    return [lsort -unique $why]
}

proc ::census::TypeOutside {t role level} {
    set c [cat $t]
    switch -- $c {
        void { return [expr {$role eq "result" ? {} : [list "void param"]}] }
        int {
            set s [lindex [unq [final $t]] 1]
            if {$s in {__int128 {unsigned __int128}}} { return [list int128] }
            return {}
        }
        enum - bool - array { return {} }
        float - complex { return [expr {$level eq "floats" && $c eq "float" ? {} : [list floating]}] }
        struct - union { return [list "$c by value"] }
        builtin { return [list "builtin [lindex [unq [final $t]] 1]"] }
        fn - ptr {
            if {$c eq "fn" || [isFnPtr $t]} {
                if {$level ni {callbacks floats}} { return [list callback] }
                set f [CallbackFn $t]
                set inner {}
                if {"variadic" in [lindex $f 3]} { lappend inner "variadic callback" }
                foreach p [lindex $f 2] {
                    foreach w [TypeOutside [lindex $p 1] param simple] {
                        lappend inner [expr {$w eq "callback" ? "callback taking a callback" : "callback with a $w param"}]
                    }
                }
                foreach w [TypeOutside [lindex $f 1] result simple] {
                    lappend inner [expr {$w eq "callback" ? "callback returning a callback" : "callback with a $w result"}]
                }
                return $inner
            }
            return {}
        }
        default { return [list "type $c"] }
    }
}

proc ::census::Subset {api} {
    set rows {}
    set fns {}
    foreach r [ofKind $api function] { lappend fns $r }
    set declared 0
    foreach r $fns { if {![dict get [body $r] definition]} { incr declared } }
    lappend rows [row "functions (declared + inline definitions)" [llength $fns]]
    lappend rows [row "declared (have a link symbol)" $declared]
    foreach level {simple callbacks floats} {
        set in 0
        set enum 0
        set reasons [dict create]
        foreach r $fns {
            set why [Outside $r $level]
            if {$why eq ""} {
                incr in
                lassign [sig $r] result params
                set usesEnum 0
                foreach t [concat [list $result] [lmap p $params {lindex $p 1}]] { if {[cat $t] eq "enum"} { set usesEnum 1 } }
                if {$usesEnum} { incr enum }
            } else {
                foreach w $why { dict incr reasons $w }
            }
        }
        lappend rows [row "$level subset: callable" $in]
        lappend rows [row "$level subset: of which use an enum type (needs its ABI width)" $enum]
        foreach r [sortedRows $reasons "$level subset: excluded by "] { lappend rows $r }
    }
    return $rows
}

# --- unsupported -------------------------------------------------------------

proc ::census::Unsupported {library system} {
    set d [dict create]
    foreach scope {library system} {
        foreach r [expr {$scope eq "library" ? $library : $system}] {
            if {[lindex $r 0] ne "unsupported"} continue
            inc d "$scope [dict get [body $r] category]: [dict get [body $r] reason]"
        }
    }
    set rows [sortedRows $d]
    set n 0
    foreach r $library { if {[lindex $r 0] eq "unsupported"} { incr n } }
    set s 0
    foreach r $system { if {[lindex $r 0] eq "unsupported"} { incr s } }
    set parsed 0
    foreach r $library { if {[lindex $r 0] ni {unsupported pragma directive}} { incr parsed } }
    set sparsed 0
    foreach r $system { if {[lindex $r 0] ni {unsupported pragma directive}} { incr sparsed } }
    return [linsert $rows 0 [row "library records parsed" $parsed] [row "library unsupported" $n] \
        [row "system records parsed" $sparsed] [row "system unsupported" $s]]
}

# --- macros ----------------------------------------------------------------

# Tokens of a macro text (for classification only; the same token shapes as
# the tokenizer).
proc ::census::MacroTokens {text} {
    regexp -all -inline {(?:L|u8|u|U)?"(?:[^"\\]|\\.)*"|(?:L|u8|u|U)?'(?:[^'\\]|\\.)*'|[A-Za-z_$][A-Za-z0-9_$]*|\.?[0-9](?:[eEpP][-+]|[A-Za-z0-9_.])*|\.\.\.|->|<<|>>|<=|>=|==|!=|&&|\|\||##|[^\sA-Za-z0-9_]} $text
}

proc ::census::StripParens {toks} {
    while {[lindex $toks 0] eq "(" && [lindex $toks end] eq ")" && [::cdecl::Parenthesized $toks]} {
        set toks [lrange $toks 1 end-1]
    }
    return $toks
}

proc ::census::IsTypeWord {t} {
    variable ix
    expr {$t in {void char short int long float double signed unsigned _Bool struct union enum const volatile * __int128}
          || [dict exists $ix typedef $t]}
}

# The text a macro means in this profile: the preprocessor's expansion
# (macros.tcl's probe) when there is one, else the replacement as written.
proc ::census::Meaning {b} {
    if {[dict exists $b expansion]} { return [dict get $b expansion] }
    return [dict get $b body]
}

# The category of an object-like macro (C-HEADER-ARCHAEOLOGY.md, "Macro
# categories"), from its expansion.
proc ::census::MacroObjectCategory {name b} {
    variable ix
    set e [Meaning $b]
    if {$e eq ""} { return empty }
    set toks [StripParens [MacroTokens $e]]
    if {[llength $toks] == 1} {
        set t [lindex $toks 0]
        if {[::cdecl::IntLiteral $t] ne ""} { return "constant: integer literal" }
        if {[regexp {^\.?[0-9]} $t]} { return "constant: floating literal" }
        if {[regexp {^(L|u8|u|U)?"} $t]} { return "constant: string literal" }
        if {[regexp {^(L|u8|u|U)?'} $t]} { return "constant: char literal" }
        if {[dict exists $ix function $t]} { return "alias: function" }
        if {[dict exists $ix variable $t]} { return "alias: object" }
        if {[IsTypeWord $t]} { return "type spelling" }
        if {[dict exists $::cdecl::enumerators $t]} { return "constant: enumerator alias" }
        if {$t in {extern static inline __inline const volatile}} { return "decoration: storage or qualifier" }
        return "alias: undeclared identifier"
    }
    if {[llength $toks] == 2 && [lindex $toks 0] in {- +} && [::cdecl::IntLiteral [lindex $toks 1]] ne ""} {
        return "constant: integer literal"
    }
    if {[regexp {__attribute__|__declspec|__pragma|^#pragma} $e]} { return "decoration: attribute" }
    set storage 1
    foreach t $toks { if {$t ni {extern static inline __inline __inline__ const volatile}} { set storage 0 } }
    if {$storage} { return "decoration: storage or qualifier" }
    set alltype 1
    foreach t $toks { if {![IsTypeWord $t] && ![regexp {^[A-Za-z_]\w*$} $t]} { set alltype 0 } }
    if {$alltype && [IsTypeWord [lindex $toks 0]]} { return "type spelling" }
    if {[lindex $toks 0] eq "\{"} { return "initializer (braced)" }
    if {[TopLevelComma $toks]} { return "comma list (an initializer or argument fragment)" }
    if {"\{" in $toks || ";" in $toks} { return "statement or declaration" }
    for {set i 0} {$i < [llength $toks] - 1} {incr i} {
        if {[lindex $toks [expr {$i + 1}]] eq "(" && [dict exists $ix function [lindex $toks $i]]} {
            return "expression: calls a function"
        }
    }
    if {[llength $toks] == 3 && [lindex $toks 1] eq "->" && [dict exists $ix variable [lindex $toks 0]]} {
        return "expression: a member of a global table (a stub-table entry)"
    }
    set refs 0
    foreach t $toks { if {[dict exists $ix function $t] || [dict exists $ix variable $t]} { set refs 1 } }
    if {$refs && "?" in $toks} { return "expression: selects a function or object at compile time" }
    if {$refs} { return "expression: refers to a function or object" }
    if {"sizeof" in $toks || "_Alignof" in $toks || "__alignof__" in $toks} { return "constant: expression with sizeof (needs ABI)" }
    if {"->" in $toks || "." in $toks} { return "expression: member access" }
    if {"&" in $toks && [lindex $toks 0] eq "&"} { return "expression: address of an object" }
    set ids 0
    set casts 0
    for {set i 0} {$i < [llength $toks]} {incr i} {
        set t [lindex $toks $i]
        if {[regexp {^[A-Za-z_]\w*$} $t]} {
            if {[IsTypeWord $t]} { set casts 1 } elseif {[dict exists $::cdecl::enumerators $t]} { set ids 1 } else { return "expression: undeclared identifier" }
        } elseif {[::cdecl::IntLiteral $t] eq "" && [string index $t 0] ni {\" '} && $t ni {( ) | & << >> + - ~ * / % ^ ? : == != < > <= >= && || !}} {
            return other
        }
    }
    if {$casts} { return "constant: expression with casts" }
    if {$ids} { return "constant: expression over enumerators" }
    return "constant: integer expression"
}

# The category of a function-like macro, and its flags: {CATEGORY FLAGS}.
# The category comes from the preprocessor's expansion of the macro applied
# to marker arguments (run.tcl's probe), the argument flags from where the
# markers went (arguses: standalone uses, uses inside string literals,
# uses pasted into longer identifiers).
proc ::census::MacroFunctionCategory {name b} {
    variable ix
    set body [dict get $b body]
    set e [Meaning $b]
    set params [dict get $b params]
    if {[dict get $b variadic]} { lappend params __VA_ARGS__ }
    set flags {}
    if {[dict exists $b arguses]} {
        foreach u [dict get $b arguses] {
            lassign $u p standalone strings pasted
            set plain [expr {$standalone - $strings}]
            if {$strings} { lappend flags stringify }
            if {$pasted} { lappend flags paste }
            if {$plain > 1} { lappend flags multiple-evaluation }
            if {$plain + $strings + $pasted == 0} { lappend flags unused-argument }
        }
    } else {
        if {[regexp {(^|[^#])#\s*[A-Za-z_]} $body]} { lappend flags stringify }
        if {[regexp {##} $body]} { lappend flags paste }
    }
    if {[regexp {\m(__FILE__|__LINE__|__func__|__FUNCTION__)\M} $body] || [string first "\"botlish-macro-probe\"" $e] >= 0} {
        lappend flags location-sensitive
    }
    foreach p $params {
        if {[regexp "\\(\\s*(const\\s+)?$p\\s*\\*+\\s*\\)|sizeof\\s*\\(\\s*\\*?\\s*\\(?\\s*$p\\s*\\)?\\s*\\)|\\(\\s*$p\\s*\\)\\s*\[A-Za-z_(\]|\\mtypedef\\s+$p\\M" $e]} {
            lappend flags type-generic
            break
        }
    }
    set toks [StripParens [MacroTokens $e]]
    if {"->" in $toks || "." in $toks} { lappend flags member-access }
    if {[regexp {[^=!<>+\-*/%&|^]=[^=]|\+\+|--|[-+*/%&|^]=} $e]} { lappend flags assignment }
    if {[regexp {\(\s*\*\s*\(|\)\s*->\s*\w+\s*\)\s*\(|\(\s*\*\s*\w+\s*\)\s*\(} $e]} { lappend flags calls-through-pointer }
    if {[regexp {_Static_assert} $e]} { lappend flags compile-time-assertion }
    if {[regexp {\(\s*\{} $e]} { lappend flags gnu-statement-expression }
    set flags [lsort -unique $flags]
    if {[dict exists $b probe]} { return [list "syntax-sensitive: rejected with identifier arguments" $flags] }
    if {$e eq ""} { return [list empty $flags] }
    if {[regexp {^\s*do\s*\{.*\}\s*while\s*\(\s*0\s*\)\s*;?\s*$} $e]} { return [list statement $flags] }
    if {[TopLevelSemicolon $toks]} {
        if {[IsTypeWord [lindex $toks 0]] || [lindex $toks 0] in {typedef static extern inline struct union enum}} {
            return [list declaration-generating $flags]
        }
        return [list statement $flags]
    }
    if {[lindex $toks 0] eq "\{"} { return [list "initializer fragment" $flags] }
    if {[TopLevelBrace $toks]} { return [list declaration-generating $flags] }
    if {[regexp {__attribute__|__declspec|__pragma} $e]} { return [list "decoration: attribute" $flags] }
    set alltype 1
    foreach t $toks { if {![IsTypeWord $t] && ![regexp {^[A-Za-z_]\w*$} $t]} { set alltype 0 } }
    if {$alltype && $toks ne "" && [IsTypeWord [lindex $toks 0]]} { return [list "type-producing" $flags] }
    if {[TopLevelComma $toks]} { return [list "comma list (an argument or initializer fragment)" $flags] }
    set f [lindex $toks 0]
    if {[lindex $toks 1] eq "(" && [lindex $toks end] eq ")" && [::cdecl::Parenthesized [lrange $toks 1 end]]} {
        if {[dict exists $ix function $f]} {
            set inner [StripArgParens [lrange $toks 2 end-1]]
            set same [expr {$inner eq [join [dict get $b params] " , "]}]
            return [list [expr {$same ? "call wrapper: rename" : "call wrapper: computed arguments"}] $flags]
        }
        if {[regexp {^[A-Za-z_]\w*$} $f] && ![IsTypeWord $f] && $f ne "sizeof"} {
            return [list "call wrapper: undeclared callee" $flags]
        }
    }
    if {"member-access" in $flags && "assignment" ni $flags} {
        return [list "expression: member access" $flags]
    }
    foreach t $toks {
        if {[dict exists $ix function $t]} { return [list "expression: calls a function" $flags] }
    }
    return [list expression $flags]
}

# The arguments of a call as text, each argument's own outer parentheses
# removed: "( a ) , ( b )" -> "a , b".
proc ::census::StripArgParens {toks} {
    set args {}
    set cur {}
    set depth 0
    foreach t $toks {
        if {$t eq "," && $depth == 0} { lappend args [join [StripParens $cur] " "]; set cur {}; continue }
        if {$t in {( [ \{}} { incr depth } elseif {$t in {) ] \}}} { incr depth -1 }
        lappend cur $t
    }
    if {$cur ne ""} { lappend args [join [StripParens $cur] " "] }
    return [join $args " , "]
}

proc ::census::TopLevelBrace {toks} {
    set depth 0
    foreach t $toks {
        switch -- $t {
            ( - \[ { incr depth }
            ) - \] { incr depth -1 }
            \{ { if {$depth == 0} { return 1 } }
        }
    }
    return 0
}

proc ::census::TopLevelComma {toks} {
    set depth 0
    foreach t $toks {
        switch -- $t {
            ( - \[ - \{ { incr depth }
            ) - \] - \} { incr depth -1 }
            , { if {$depth == 0} { return 1 } }
        }
    }
    return 0
}

proc ::census::TopLevelSemicolon {toks} {
    set depth 0
    foreach t $toks {
        switch -- $t {
            ( - \[ - \{ { incr depth }
            ) - \] - \} { incr depth -1 }
            ; { if {$depth == 0} { return 1 } }
        }
    }
    return 0
}

# Could a generated wrapper with a declared signature stand in for the
# macro (C-HEADER-ARCHAEOLOGY.md, "Thunks")? yes, per-signature
# (type-generic: one wrapper per instantiation), no (syntax-sensitive or a
# declaration/type), or n/a (decorations, constants).
proc ::census::Thunkable {form category flags} {
    if {$form eq "object"} {
        switch -glob -- $category {
            constant:* { return "constant (value import, or a thunk returning it)" }
            "alias: function" { return "n/a (import the function under the alias)" }
            "alias: object" { return "n/a (import the object under the alias)" }
            "type spelling" { return "n/a (a type)" }
            "expression: a member of a global table*" { return "yes (the same-named declaration supplies the signature)" }
            "expression: refers to a function or object" - "expression: selects a function or object at compile time" { return "yes (with a declared signature)" }
            "alias: undeclared identifier" - "expression: undeclared identifier" { return "n/a (names nothing declared in this profile)" }
            "comma list*" - "initializer*" - "statement or declaration" { return "no (a fragment, not an expression)" }
            decoration* - empty* { return "n/a (erased by preprocessing)" }
            "expression: member access" - "expression: calls a function" - "expression: address of an object" { return yes }
            default { return "unclear" }
        }
    }
    switch -glob -- $category {
        syntax-sensitive* { return "no (syntax-sensitive: needs literal or identifier arguments)" }
        empty - decoration* { return "n/a (erased by preprocessing)" }
        declaration-generating { return "no (import the declarations it generates)" }
        "initializer fragment" - "comma list*" { return "no (a fragment of an initializer or argument list, not an expression)" }
        type-producing { return "n/a (a type, resolved at each use)" }
        "call wrapper: rename" { return "n/a (import the callee)" }
    }
    if {"stringify" in $flags || "paste" in $flags} { return "per identifier argument (an argument pasted or stringified is a name, not a value)" }
    if {"type-generic" in $flags} { return "per signature (type-generic)" }
    if {"location-sensitive" in $flags} { return "yes, but __FILE__/__LINE__ become the wrapper's" }
    if {$category eq "statement"} { return "yes (a void wrapper)" }
    if {$category eq "expression: member access"} { return "yes (a read; the expansion is an lvalue too: writing needs a second wrapper)" }
    if {"assignment" in $flags} { return "yes (side effects on its arguments)" }
    return yes
}

proc ::census::Macros {macros api} {
    variable ix
    set d [dict create]
    set examples [dict create]
    set thunk [dict create]
    set thunkEx [dict create]
    set flagCount [dict create]
    set useCount [dict create]
    foreach r $api {
        set b [body $r]
        if {![dict exists $b srcmacros]} continue
        foreach m [dict get $b srcmacros] { dict incr useCount $m }
    }
    set shadow 0
    set shadowEx {}
    foreach m $macros {
        lassign $m _ name b
        if {[dict get $b undefined]} { inc d "(#undef'd by the end of the TU)"; continue }
        set form [dict get $b form]
        set flags {}
        if {$form eq "object"} {
            set c [MacroObjectCategory $name $b]
            if {$c eq "empty"} {
                if {[regexp {_H_?$|_H_INCLUDED$|_H__$|HEADER_} $name]} {
                    set c "empty: include guard"
                } elseif {[dict exists $useCount $name]} {
                    set c "empty: used on declaration lines"
                } else {
                    set c "empty: flag (tested by #if, or unused)"
                }
            }
        } else {
            lassign [MacroFunctionCategory $name $b] c flags
            if {[dict exists $ix function $name]} {
                incr shadow
                if {[llength $shadowEx] < 6} { lappend shadowEx $name }
            }
        }
        inc d "$form: $c"
        foreach f $flags { inc flagCount "$form flag: $f" }
        if {![dict exists $examples "$form: $c"] || [llength [dict get $examples "$form: $c"]] < 4} {
            dict lappend examples "$form: $c" $name
        }
        set t [Thunkable $form $c $flags]
        inc thunk "$form thunk: $t"
        if {![dict exists $thunkEx "$form thunk: $t"] || [llength [dict get $thunkEx "$form thunk: $t"]] < 4} {
            dict lappend thunkEx "$form thunk: $t" $name
        }
    }
    set rows [list [row "library macros (final definitions)" [llength $macros]]]
    foreach {k v} [lsort -stride 2 $d] {
        lappend rows [row $k $v [expr {[dict exists $examples $k] ? [dict get $examples $k] : ""}]]
    }
    foreach {k v} [lsort -stride 2 $flagCount] { lappend rows [row $k $v] }
    foreach {k v} [lsort -stride 2 $thunk] {
        lappend rows [row $k $v [dict get $thunkEx $k]]
    }
    lappend rows [row "function-like macros with the name of a declared function (shadowing it)" $shadow $shadowEx]
    return $rows
}

# Declaration macros: the macros written on the source lines declarations
# came from, by what preprocessing made of them.
proc ::census::DeclarationMacros {macros api} {
    set byName [dict create]
    foreach m $macros { dict set byName [lindex $m 1] [lindex $m 2] }
    set uses [dict create]
    set conds [dict create]
    foreach r $api {
        set b [body $r]
        if {[dict exists $b srcmacros]} {
            foreach m [dict get $b srcmacros] { dict incr uses $m }
        }
        if {[dict exists $b srcconditionals]} {
            foreach m [dict get $b srcconditionals] { dict incr conds "[lindex $r 0] [lindex $r 1]" }
        }
    }
    set cat [dict create]
    set ex [dict create]
    foreach {m n} $uses {
        if {![dict exists $byName $m]} continue
        set b [dict get $byName $m]
        if {[dict get $b form] eq "object"} {
            set c [MacroObjectCategory $m $b]
        } else {
            set c [lindex [MacroFunctionCategory $m $b] 0]
        }
        set key "[dict get $b form]: $c"
        dict incr cat "$key (macros)"
        dict incr cat "$key (declaration uses)" $n
        dict lappend ex $key [list $m $n]
    }
    set rows {}
    foreach {k v} [lsort -stride 2 $cat] {
        set base [regsub { \((macros|declaration uses)\)$} $k {}]
        set note ""
        if {[string match "*(macros)" $k]} {
            set note [lrange [lsort -index 1 -integer -decreasing [dict get $ex $base]] 0 5]
        }
        lappend rows [row $k $v $note]
    }
    lappend rows [row "declarations whose source span contains a preprocessor conditional" [dict size $conds] \
        [lrange [dict keys $conds] 0 9]]
    return $rows
}

proc ::census::SystemRefs {api system} {
    variable libIx
    # The tags system headers declare or mention.
    set sysTags [dict create]
    foreach r $system {
        foreach ref [Refs $r] { if {[lindex $ref 0] eq "tag"} { dict set sysTags [lindex $ref 1] 1 } }
        if {[lindex $r 0] eq "struct"} { dict set sysTags "[dict get [body $r] kind] [lindex $r 1]" 1 }
    }
    set d [dict create]
    foreach item [PositionTypes $api] {
        lassign $item position name t
        foreach n [nodes $t] {
            if {[lindex $n 0] eq "typedef" && ![dict exists $libIx typedef [lindex $n 1]]} {
                inc d "typedef [lindex $n 1]"
            }
            if {[lindex $n 0] in {struct union} && [dict exists $sysTags "[lindex $n 0] [lindex $n 1]"]} {
                inc d "[lindex $n 0] [lindex $n 1]"
            }
        }
    }
    return [sortedRows $d "system "]
}

# ---------------------------------------------------------------------------
# Output.

proc ::census::text {c} {
    set out ""
    foreach {section rows} $c {
        append out "== $section\n"
        foreach r $rows {
            lassign $r k v note
            append out [format "  %-80s %s" $k $v]
            if {$note ne ""} { append out "   [list $note]" }
            append out "\n"
        }
        append out "\n"
    }
    return $out
}

proc ::census::tsv {c} {
    set out ""
    foreach {section rows} $c {
        foreach r $rows {
            lassign $r k v
            append out "$section\t$k\t$v\n"
        }
    }
    return $out
}

