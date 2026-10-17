# model.tcl -- the binding model: what the generator binds, how, and why not
# (C-BINDGEN.md, "Declaration mapping", "Classification").
#
#   ::cbind::model::build PROFILE TARGET RUN FACTS OPTIONS
#
# RUN is the C header library's pipeline result for the profile on the
# target (records and expanded macros, tools/cheader/pipeline.tcl); FACTS
# what the compiler said (probe.tcl): typedef and enum ABI types, constant
# values and types, link symbols. The model is plain data, written out by
# emit.tcl; it decides, for every public declaration and macro:
#
#   an API name     direct (an extern of its own link symbol), alias (an
#                   object-like or renaming macro: an extern of the symbol
#                   the compiler resolves it to, with that function's
#                   signature), thunk (static inline, a table-redirected
#                   name, a macro whose signature the profile states: a C
#                   wrapper in the shim), excluded (the profile's explicit
#                   policy) or unsupported (a precise blocker)
#   a type          a C integer scalar (an ABI alias, resolved through the
#                   target's typedef chain and confirmed by the compiler),
#                   ffi::c::Bool, an opaque pointee identity (one per C
#                   tag, owned by the binding's ctypes module), a function
#                   pointer type, or unsupported
#   a constant      an exact integer of the C type the compiler gives it, or
#                   not a constant (and why)
#
# Nothing here interprets C: types are the declaration parser's, meanings of
# macros the preprocessor's expansion classified by token shape (macrocat),
# values, types and symbols the compiler's. A favorable contract fact comes
# only from the profile or the compiler's evidence; everything else is
# unknown.

namespace eval ::cbind::model {
    # C integer spellings (the parser's canonical ones) -> ffi::c scalars.
    variable scalars {
        char Char {signed char} SChar {unsigned char} UChar short Short
        {unsigned short} UShort int Int {unsigned int} UInt long Long
        {unsigned long} ULong {long long} LongLong {unsigned long long} ULongLong
    }
    # Botlish keywords: a C name spelled like one is renamed (a parameter)
    # or bound under another name (`named` keeps its symbol).
    variable keywords {fn if elif else loop return break continue true false unit and or not type
        struct error errors fail on yield}
    # Explicit calling conventions (attribute names): the FFI calls with the
    # platform default only, so a declaration carrying one is not bound.
    # `cdecl` is the default on every 64-bit target this generator knows.
    variable conventions {stdcall fastcall thiscall vectorcall regcall ms_abi sysv_abi
        pcs aarch64_vector_pcs aarch64_sve_pcs preserve_most preserve_all swiftcall
        regparm __stdcall __fastcall __thiscall __vectorcall __regcall _stdcall _fastcall
        __pascal __clrcall}

    # The state of one build.
    variable ix {}
    variable facts {}
    variable profile {}
    variable target {}
    variable options {}
    variable identities {}
}

# ---------------------------------------------------------------------------
# Small helpers.

proc ::cbind::model::Unq {t} { ::cir::unq $t }

# The C spelling of TYPE for reports.
proc ::cbind::model::Spell {type} { ::cir::spell $type }

# A Botlish identifier for the C name NAME: itself unless it is a keyword
# or not an identifier Botlish spells (a "$"), then NAME_.
proc ::cbind::model::Ident {name} {
    variable keywords
    set id [regsub -all {[^A-Za-z0-9_]} $name _]
    if {$id in $keywords || ![regexp {^[A-Za-z_]} $id]} {
        append id _
    }
    return $id
}

# The module (relative Botlish namespace under the profile's) of HEADER, a
# source-relative path.
proc ::cbind::model::ModuleOf {header} {
    variable profile
    variable keywords
    set stem [file rootname [file tail $header]]
    set prefix [dict get $profile modules stripPrefix]
    if {$prefix ne "" && [string first $prefix $stem] == 0 && [string length $stem] > [string length $prefix]} {
        set stem [string range $stem [string length $prefix] end]
    }
    set m [string tolower [regsub -all {[^A-Za-z0-9_]} $stem _]]
    set m [string trim $m _]
    if {$m eq "" || ![regexp {^[a-z]} $m]} { set m h_$m }
    if {$m in $keywords || $m in {ctypes thunks}} { append m _h }
    return $m
}

# The {CHAIN FINAL} of TYPE (typedef references followed, qualifiers
# dropped at every level of the result).
proc ::cbind::model::Resolve {type} {
    variable ix
    lassign [::cir::resolve $ix $type] chain final
    return [list $chain [Unq $final]]
}

# The stripped identity of a function type for redeclaration checks:
# parameter names and attributes dropped.
proc ::cbind::model::TypeIdentity {type} {
    if {[lindex $type 0] ne "fn"} { return $type }
    lassign $type _ result params flags
    return [list fn $result [lmap p $params {lindex $p 1}] $flags]
}

# ---------------------------------------------------------------------------
# Opaque pointee identities.

# The identity (Botlish name) of the C tag KEY ("struct T", "union T"),
# registered on first use with its naming typedef.
proc ::cbind::model::Identity {key} {
    variable identities
    variable ix
    if {[dict exists $identities $key]} {
        return [dict get $identities $key name]
    }
    set name ""
    if {[dict exists $::cbind::model::tagNames $key]} {
        set name [dict get $::cbind::model::tagNames $key]
    } else {
        set tag [lindex $key 1]
        if {[string match anon@* $tag]} {
            set name anon_[llength [dict keys $identities]]
        } else {
            set name $tag
        }
    }
    set name [Ident $name]
    set taken [lmap {k v} $identities {dict get $v name}]
    while {$name in $taken} { append name _[lindex $key 0] }
    set complete [expr {[dict exists $ix tag $key] && [dict get $ix tag $key complete]}]
    set loc [expr {[dict exists $ix tag $key] ? [dict get $ix tag $key loc] : {}}]
    set origin [expr {[dict exists $ix tag $key] ? [dict get $ix tag $key origin] : "system"}]
    dict set identities $key [dict create name $name complete $complete loc $loc origin $origin \
        typedef [expr {[dict exists $::cbind::model::tagNames $key] ? [dict get $::cbind::model::tagNames $key] : ""}]]
    return $name
}

# The first typedef (TU order) naming each tag directly: tag key -> name.
proc ::cbind::model::TagNames {records} {
    set names [dict create]
    foreach r $records {
        lassign $r kind name body
        if {$kind ne "typedef"} continue
        set t [dict get $body type]
        if {[lindex $t 0] in {struct union} && ![dict exists $names "[lindex $t 0] [lindex $t 1]"]} {
            dict set names "[lindex $t 0] [lindex $t 1]" $name
        }
    }
    return $names
}

# ---------------------------------------------------------------------------
# Type mapping.
#
# Each mapping returns {ok TEXT FEATURES} or {no BLOCKERS}: TEXT the
# Botlish type, FEATURES what the use involves (pointer, callback, bytes,
# view, opaque, bool, enum), BLOCKERS a list of {REASON DETAIL}, every one
# found (not just the first), so the report can say which missing
# capability each API waits for.

proc ::cbind::model::Blocked {reason detail} {
    return [list no [list [list $reason $detail]]]
}

# The scalar of the C integer spelling SPELLING.
proc ::cbind::model::ScalarOf {spelling} {
    variable scalars
    if {[dict exists $scalars $spelling]} { return ffi::c::[dict get $scalars $spelling] }
    return ""
}

# Checks the typedef NAME against the compiler: the C type a _Generic
# selection gives it must be the one its declaration chain ends in. ""
# when it agrees, else a blocker detail.
proc ::cbind::model::TypedefAbiProblem {name finalSpelling} {
    variable facts
    set key td:$name
    if {![dict exists $facts values $key]} { return "" }
    lassign [dict get $facts values $key] status data
    if {$status ne "ok"} {
        return "the compiler could not probe typedef $name: $data"
    }
    lassign $data size code
    set ctype [::cbind::probe::typeOfCode $code]
    if {$ctype ne $finalSpelling} {
        return "typedef $name is $finalSpelling by its declaration, but the compiler gives it [expr {$ctype eq "" ? "no C integer type of the table" : $ctype}] ($size bytes): an attribute or extension changes it"
    }
    return ""
}

# The scalar of enum TYPE (resolved {enum TAG}, VIA a typedef naming it or
# ""), from the compiler's _Generic selection.
proc ::cbind::model::EnumScalar {tag via} {
    variable facts
    foreach key [list enum:$tag td:$via] {
        if {![dict exists $facts values $key]} continue
        lassign [dict get $facts values $key] status data
        if {$status ne "ok"} { continue }
        set ctype [::cbind::probe::typeOfCode [lindex $data 1]]
        set s [ScalarOf $ctype]
        if {$s ne ""} { return [list $s $ctype] }
    }
    return ""
}

# The Botlish value type of C TYPE in ROLE (param, result, fnparam,
# fnresult). Arrays and function types of parameters are adjusted to
# pointers, as C adjusts them.
proc ::cbind::model::Value {type role {via ""}} {
    variable options
    set t [Unq $type]
    switch -- [lindex $t 0] {
        void {
            if {$role in {result fnresult}} { return [list ok unit {}] }
            return [Blocked unsupported-type "void as a parameter"]
        }
        bool {
            if {![dict get $options bool]} {
                return [Blocked unsupported-bool "C _Bool (without ffi::c::Bool)"]
            }
            return [list ok ffi::c::Bool {bool}]
        }
        int {
            set s [ScalarOf [lindex $t 1]]
            if {$s eq ""} {
                return [Blocked unsupported-type "[lindex $t 1] (no C ABI scalar of that type)"]
            }
            return [list ok $s {}]
        }
        float {
            set sp [lindex $t 1]
            set reason [expr {$sp eq "float" ? "float" : ($sp eq "double" ? "double" : ($sp eq "long double" ? "long-double" : "float"))}]
            return [Blocked $reason $sp]
        }
        complex { return [Blocked complex "_Complex [lindex $t 1]"] }
        builtin {
            if {[string match *va_list [lindex $t 1]]} { return [Blocked va-list [lindex $t 1]] }
            return [Blocked unsupported-type [lindex $t 1]]
        }
        typedef {
            set name [lindex $t 1]
            if {![dict exists $::cbind::model::ix typedef $name]} {
                return [Blocked unresolved-typedef "$name (no declaration of it in the translation unit)"]
            }
            lassign [Resolve $t] chain final
            if {[lindex $final 0] eq "int"} {
                set problem [TypedefAbiProblem $name [lindex $final 1]]
                if {$problem ne ""} { return [Blocked typedef-abi-mismatch $problem] }
            }
            if {[lindex $final 0] eq "typedef"} {
                return [Blocked unresolved-typedef "$name -> [lindex $final 1] (no declaration of it)"]
            }
            return [Value $final $role $name]
        }
        struct - union {
            set what [expr {[lindex $t 0] eq "union" ? "union-by-value" : "by-value-aggregate"}]
            return [Blocked $what "[lindex $t 0] [lindex $t 1] by value"]
        }
        enum {
            set e [EnumScalar [lindex $t 1] $via]
            if {$e eq ""} {
                return [Blocked enum-unknown-abi "enum [lindex $t 1]: the compiler did not give its integer type"]
            }
            return [list ok [lindex $e 0] {enum}]
        }
        ptr { return [Pointer [lindex $t 1]] }
        array {
            if {$role in {param fnparam}} { return [Pointer [lindex $t 1]] }
            return [Blocked unsupported-type "an array result"]
        }
        fn {
            if {$role in {param fnparam}} { return [FnPtr $t] }
            return [Blocked unsupported-type "a function result"]
        }
        default {
            return [Blocked unsupported-type [Spell $t]]
        }
    }
}

# The Botlish type of a C pointer to POINTEE.
proc ::cbind::model::Pointer {pointee} {
    variable options
    set t [Unq $pointee]
    if {[lindex $t 0] eq "typedef"} {
        set name [lindex $t 1]
        if {![dict exists $::cbind::model::ix typedef $name]} {
            return [Blocked unresolved-typedef "$name (no declaration of it in the translation unit)"]
        }
        lassign [Resolve $t] chain final
        if {[lindex $final 0] eq "int"} {
            set problem [TypedefAbiProblem $name [lindex $final 1]]
            if {$problem ne ""} { return [Blocked typedef-abi-mismatch $problem] }
        }
        if {[lindex $final 0] eq "enum"} {
            set e [EnumScalar [lindex $final 1] $name]
            if {$e eq ""} { return [Blocked enum-unknown-abi "enum [lindex $final 1]"] }
            return [list ok "ffi::c::Ptr\[[lindex $e 0]\]" {pointer enum}]
        }
        if {[lindex $final 0] eq "typedef"} {
            return [Blocked unresolved-typedef "$name -> [lindex $final 1] (no declaration of it)"]
        }
        set t $final
    }
    switch -- [lindex $t 0] {
        void { return [list ok "ffi::c::Ptr\[ffi::c::Void\]" {pointer void}] }
        int {
            set s [ScalarOf [lindex $t 1]]
            if {$s eq ""} { return [Blocked unsupported-type "a pointer to [lindex $t 1]"] }
            set features {pointer}
            if {[lindex $t 1] in {char {signed char} {unsigned char}}} { lappend features bytes }
            return [list ok "ffi::c::Ptr\[$s\]" $features]
        }
        bool {
            if {![dict get $options bool]} {
                return [Blocked unsupported-bool "a pointer to C _Bool (without ffi::c::Bool)"]
            }
            return [list ok "ffi::c::Ptr\[ffi::c::Bool\]" {pointer bool}]
        }
        enum {
            set e [EnumScalar [lindex $t 1] ""]
            if {$e eq ""} { return [Blocked enum-unknown-abi "enum [lindex $t 1]"] }
            return [list ok "ffi::c::Ptr\[[lindex $e 0]\]" {pointer enum}]
        }
        struct - union {
            set key "[lindex $t 0] [lindex $t 1]"
            set name [Identity $key]
            set features {pointer opaque}
            if {[dict get $::cbind::model::identities $key complete]} { lappend features view }
            return [list ok "ffi::c::Ptr\[@$key@\]" $features]
        }
        ptr {
            set inner [Pointer [lindex $t 1]]
            if {[lindex $inner 0] ne "ok"} { return $inner }
            lassign $inner _ text features
            return [list ok "ffi::c::Ptr\[$text\]" [lsort -unique [concat pointer $features]]]
        }
        fn { return [FnPtr $t] }
        float {
            return [Blocked [expr {[lindex $t 1] eq "float" ? "float" : "double"}] "a pointer to [lindex $t 1]"]
        }
        array { return [Blocked unsupported-type "a pointer to an array ([Spell $t])"] }
        builtin { return [Blocked va-list "a pointer to [lindex $t 1]"] }
        complex { return [Blocked complex "a pointer to _Complex [lindex $t 1]"] }
        default { return [Blocked unsupported-type "a pointer to [Spell $t]"] }
    }
}

# The Botlish ffi::c::FnPtr of the C function type FN (a callback).
proc ::cbind::model::FnPtr {fn} {
    lassign $fn _ result params flags
    set blockers {}
    if {"variadic" in $flags} {
        lappend blockers [list unsupported-callback-signature "a variadic callback ([Spell $fn])"]
    }
    if {"noproto" in $flags} {
        lappend blockers [list unsupported-callback-signature "a callback without a prototype ([Spell $fn])"]
    }
    set args {}
    set features {pointer callback}
    set i 0
    foreach p $params {
        incr i
        set m [Value [lindex $p 1] fnparam]
        if {[lindex $m 0] ne "ok"} {
            foreach b [lindex $m 1] {
                lappend blockers [list unsupported-callback-signature "callback argument $i: [lindex $b 1] ([lindex $b 0])"]
            }
            continue
        }
        lappend args [lindex $m 1]
        lappend features {*}[lmap f [lindex $m 2] {expr {$f in {bool} ? $f : [continue]}}]
    }
    set r [Value $result fnresult]
    if {[lindex $r 0] ne "ok"} {
        foreach b [lindex $r 1] {
            lappend blockers [list unsupported-callback-signature "callback result: [lindex $b 1] ([lindex $b 0])"]
        }
    } elseif {"bool" in [lindex $r 2]} {
        lappend features bool
    }
    if {$blockers ne ""} { return [list no $blockers] }
    return [list ok "ffi::c::FnPtr\[Fn\{args: \[[join $args {, }]\], return: [lindex $r 1]\}\]" [lsort -unique $features]]
}

# The mapped signature of the function type TYPE: {ok PARAMS RESULT} with
# PARAMS {{cname NAME name BOTLISH type TEXT features F} ...} and RESULT
# {type TEXT features F}, or {no BLOCKERS} (every blocker, each located:
# "parameter 2 (x): double").
proc ::cbind::model::Signature {type attrs} {
    variable conventions
    lassign $type _ result params flags
    set blockers {}
    if {"variadic" in $flags} { lappend blockers [list variadic "a variadic function (...)"] }
    if {"noproto" in $flags} { lappend blockers [list no-prototype "declared without a prototype: ()"] }
    foreach a [concat $attrs [concat {*}[lmap p $params {lindex $p 2}]]] {
        set name [expr {[lindex $a 0] eq "cc" ? [lindex $a end] : [lindex $a 2]}]
        if {[lindex $a 0] in {cc gnu std declspec} && $name in $conventions} {
            lappend blockers [list unsupported-calling-convention "an explicit calling convention: $name"]
        }
    }
    set out {}
    set names {}
    set i 0
    foreach p $params {
        incr i
        lassign $p cname ptype
        set m [Value $ptype param]
        if {[lindex $m 0] ne "ok"} {
            foreach b [lindex $m 1] {
                lappend blockers [list [lindex $b 0] "parameter $i[expr {$cname eq "" ? "" : " ($cname)"}]: [lindex $b 1]"]
            }
            continue
        }
        set name [expr {$cname eq "" ? "arg$i" : [Ident $cname]}]
        while {$name in $names} { append name _ }
        lappend names $name
        lappend out [dict create cname $cname name $name type [lindex $m 1] features [lindex $m 2] \
            ctype $ptype index [expr {$i - 1}]]
    }
    set r [Value $result result]
    set res {}
    if {[lindex $r 0] ne "ok"} {
        foreach b [lindex $r 1] { lappend blockers [list [lindex $b 0] "result: [lindex $b 1]"] }
    } else {
        set res [dict create type [lindex $r 1] features [lindex $r 2] ctype $result]
    }
    if {$blockers ne ""} { return [list no $blockers] }
    return [list ok $out $res]
}

# ---------------------------------------------------------------------------
# Contracts.
#
# A pointer parameter's facts are {access A escape E}: A read, write or ""
# (unknown), E declared-noescape, proven-noescape, captures or ""
# (unknown); a pointer result's provenance independent, {alias P} or ""
# (unknown). Sources: the profile (manual) and the compiler (evidence).

# The facts dict of the profile words WORDS (read, write, noescape,
# captures; independent, alias P for the result) for WHAT.
proc ::cbind::model::FactWords {words what} {
    set out [dict create]
    set rest $words
    while {[llength $rest]} {
        set rest [lassign $rest w]
        switch -- $w {
            read - write { dict set out access $w }
            noescape { dict set out escape declared-noescape }
            captures { dict set out escape captures }
            independent { dict set out provenance independent }
            alias {
                set rest [lassign $rest p]
                dict set out provenance [list alias $p]
            }
            default { error "c-bindgen: unknown contract fact \"$w\" for $what (read, write, noescape, captures; independent, alias PARAM)" }
        }
    }
    return $out
}

# The manual contract facts of every function, expanded from the profile's
# per-function contracts and its explicit groups: FUNCTION -> {PARAM-or-
# result -> {facts F source S}}. A group or contract naming a function or a
# parameter that does not exist is a stale policy: an error.
proc ::cbind::model::ManualContracts {functions} {
    variable profile
    set out [dict create]
    set seen [dict create]
    set rules {}
    dict for {fn spec} [dict get $profile contracts] {
        lappend rules [list "contract $fn" [list $fn] $spec]
    }
    set g 0
    foreach group [dict get $profile groups] {
        incr g
        set label [expr {[dict exists $group name] ? "group [dict get $group name]" : "group $g"}]
        lappend rules [list $label [dict get $group functions] [dict get $group facts]]
    }
    set problems {}
    foreach rule $rules {
        lassign $rule label fns spec
        foreach fn $fns {
            if {![dict exists $functions $fn]} {
                lappend problems "$label names $fn, which this target's headers do not declare as a bindable function"
                continue
            }
            set params [dict get $functions $fn]
            dict for {param words} $spec {
                if {$param ne "result" && $param ni $params} {
                    lappend problems "$label: $fn has no parameter \"$param\" (its parameters: [join $params {, }])"
                    continue
                }
                if {[dict exists $seen $fn $param]} {
                    lappend problems "$label: $fn's \"$param\" is already stated by [dict get $seen $fn $param]"
                    continue
                }
                dict set seen $fn $param $label
                dict set out $fn $param [dict create facts [FactWords $words "$fn $param"] source $label]
            }
        }
    }
    return [list $out $problems]
}

# The compiler evidence of a thunk's parameter attribute list ATTRS (probe
# evidence): facts {access A escape E returned 0|1}.
proc ::cbind::model::EvidenceFacts {attrs} {
    set out [dict create]
    if {"nocapture" in $attrs} { dict set out escape proven-noescape }
    if {"readonly" in $attrs || "readnone" in $attrs} { dict set out access read }
    if {"writeonly" in $attrs} { dict set out access write }
    if {"returned" in $attrs} { dict set out returned 1 }
    return $out
}

# ---------------------------------------------------------------------------
# The model.

# Phase 1: the candidate APIs of RUN, classified (direct, alias, thunk,
# excluded, unsupported by macro shape), each with the declaration whose
# signature it has; and what the compiler must be asked (ProbeRequests).
proc ::cbind::model::candidates {theProfile theTarget run theOptions} {
    variable ix
    variable profile $theProfile
    variable target $theTarget
    variable options $theOptions
    variable identities [dict create]
    variable tagNames
    set records [dict get $run records]
    set ix [::cir::index $records]
    set tagNames [TagNames $records]
    set ::cmacro::ix $ix

    # Public records, first declaration of each name in translation-unit
    # order; incompatible redeclarations are generator errors.
    set seen [dict create]
    set order {}
    set problems {}
    foreach r $records {
        lassign $r kind name body
        if {[dict get $body origin] ne "public"} continue
        if {$kind eq "function"} {
            if {[dict exists $seen $name]} {
                set old [dict get $seen $name]
                if {[TypeIdentity [dict get $old type]] ne [TypeIdentity [dict get $body type]]} {
                    lappend problems "function $name is declared twice with different types: [Spell [dict get $old type]] ([lindex [dict get $old loc] 0]:[lindex [dict get $old loc] 1]) and [Spell [dict get $body type]] ([lindex [dict get $body loc] 0]:[lindex [dict get $body loc] 1])"
                }
                if {[dict get $body definition]} { dict set seen $name $body }
                continue
            }
            dict set seen $name $body
            lappend order $name
        }
    }
    if {$problems ne ""} {
        error "c-bindgen: incompatible redeclarations:\n  [join $problems "\n  "]"
    }
    set macros [dict create]
    set macroOrder {}
    foreach m [dict get $run macros] {
        lassign $m _ name b
        if {[dict get $b origin] ne "public" || [dict get $b undefined]} continue
        dict set macros $name $b
        lappend macroOrder $name
    }

    # Classify every API name.
    set apis {}
    foreach name $order {
        set body [dict get $seen $name]
        set entry [dict create name $name header [lindex [dict get $body loc] 0] \
            line [lindex [dict get $body loc] 1] decl $body]
        if {[::cbind::profile::excluded $profile $name]} {
            dict set entry kind excluded
        } elseif {[dict exists $macros $name] && [dict get $macros $name form] eq "object"} {
            set c [::cmacro::objectCategory $name [dict get $macros $name]]
            if {[string match "expression: a member of a global table*" $c]} {
                dict set entry kind [expr {[dict get $profile stubs] eq "thunk" ? "thunk" : "unsupported"}]
                dict set entry via stub
                dict set entry macro $c
                if {[dict get $entry kind] eq "unsupported"} {
                    dict set entry blockers [list [list stub-redirect "the name is a macro reading a global table ([dict get $macros $name expansion]): the profile binds no stub thunks"]]
                }
            } elseif {$c eq "alias: function" && [MacroTarget $macros $name] ne $name} {
                # Declared, and also an object-like alias of another
                # function: the API name means the alias.
                dict set entry kind alias
                dict set entry target [MacroTarget $macros $name]
                dict set entry shadowed 1
            } elseif {$c eq "alias: function"} {
                dict set entry kind [expr {[dict get $body definition] ? "thunk" : "direct"}]
                dict set entry via [expr {[dict get $body definition] ? "inline" : "self-alias"}]
            } else {
                dict set entry kind unsupported
                dict set entry blockers [list [list unsupported-macro "the declared name is also an object-like macro ($c: [dict get $macros $name expansion])"]]
            }
        } elseif {[dict get $body definition] || [dict get $body storage] eq "static"} {
            dict set entry kind thunk
            dict set entry via inline
        } else {
            dict set entry kind direct
            if {[dict exists $macros $name] && [dict get $macros $name form] eq "function"} {
                dict set entry shadowedBy [lindex [::cmacro::functionCategory $name [dict get $macros $name]] 0]
            }
        }
        lappend apis $entry
    }
    # Macro APIs without a declaration of their own name.
    foreach name $macroOrder {
        if {[dict exists $seen $name]} continue
        set b [dict get $macros $name]
        set entry [dict create name $name header [lindex [dict get $b loc] 0] line [lindex [dict get $b loc] 1] macro 1]
        if {[dict get $b form] eq "object"} {
            set c [::cmacro::objectCategory $name $b]
            if {$c eq "alias: function"} {
                dict set entry kind [expr {[::cbind::profile::excluded $profile $name] ? "excluded" : "alias"}]
                dict set entry target [MacroTarget $macros $name]
                lappend apis $entry
            } elseif {[dict exists $profile thunks $name]} {
                dict set entry kind [expr {[::cbind::profile::excluded $profile $name] ? "excluded" : "thunk"}]
                dict set entry via macro
                dict set entry macro $c
                lappend apis $entry
            }
            continue
        }
        lassign [::cmacro::functionCategory $name $b] c flags
        dict set entry macro $c
        dict set entry flags $flags
        if {[::cbind::profile::excluded $profile $name]} {
            dict set entry kind excluded
        } elseif {[dict exists $profile thunks $name]} {
            dict set entry kind thunk
            dict set entry via macro
        } elseif {$c eq "call wrapper: rename"} {
            dict set entry kind alias
            dict set entry target [MacroCallee $b]
            dict set entry rename 1
        } else {
            dict set entry kind unsupported
            dict set entry blockers [list [list [MacroReason $c $flags] "a function-like macro ($c[expr {$flags eq "" ? "" : "; [join $flags {, }]"}]): no signature of its own"]]
        }
        lappend apis $entry
    }

    # The profile's macro signatures must each name a macro API.
    foreach name [dict keys [dict get $profile thunks]] {
        if {![dict exists $macros $name]} {
            error "c-bindgen: the profile's thunk signature of \"$name\" names no public macro of this target's headers (a stale policy)"
        }
    }

    # Signatures: a direct or inline API's own declaration, an alias's
    # target's (followed through further aliases), a macro thunk's
    # profile prototype.
    set protoTypedefs [dict keys [dict get $ix typedef]]
    set out {}
    foreach entry $apis {
        set name [dict get $entry name]
        set kind [dict get $entry kind]
        if {$kind in {excluded unsupported}} { lappend out $entry; continue }
        if {$kind eq "alias"} {
            set resolved [ResolveAlias $entry $macros $seen]
            if {[lindex $resolved 0] ne "ok"} {
                dict set entry kind unsupported
                dict set entry blockers [list [lrange $resolved 1 2]]
                lappend out $entry
                continue
            }
            dict set entry decl [lindex $resolved 1]
            dict set entry targetName [lindex $resolved 2]
        } elseif {$kind eq "thunk" && [dict get $entry via] eq "macro"} {
            set proto [dict get $profile thunks $name]
            set recs [::cdecl::parse "$proto;\n" {} $protoTypedefs]
            set fn [lsearch -inline -index 0 $recs function]
            if {$fn eq "" || [lindex $fn 1] ne $name} {
                error "c-bindgen: the profile's thunk signature of \"$name\" is no prototype of $name: $proto"
            }
            dict set entry decl [lindex $fn 2]
            dict set entry prototype $proto
        }
        lappend out $entry
    }
    set apis $out
    set model [dict create apis $apis macros $macros macroOrder $macroOrder records $records]
    dict set model requests [ProbeRequests $model]
    return $model
}

# The function an object-like alias macro NAME names (its expansion, one
# identifier).
proc ::cbind::model::MacroTarget {macros name} {
    set toks [::cmacro::stripParens [::cmacro::tokens [::cmacro::meaning [dict get $macros $name]]]]
    return [lindex $toks 0]
}

# The callee of a renaming function-like macro (`#define X(a, b) Y(a, b)`).
proc ::cbind::model::MacroCallee {b} {
    set toks [::cmacro::stripParens [::cmacro::tokens [::cmacro::meaning $b]]]
    return [lindex $toks 0]
}

# The reason a function-like macro without a profile signature is not
# bound.
proc ::cbind::model::MacroReason {category flags} {
    switch -glob -- $category {
        statement - expression* - "call wrapper: computed arguments" - "call wrapper: undeclared callee" {
            return macro-needs-signature
        }
        default { return unsupported-macro }
    }
}

# Follows ENTRY's alias to the declaration it ends in: {ok DECL NAME} or
# {no REASON DETAIL}. A chain of aliases is followed; a cycle or a target
# without a declaration is a blocker.
proc ::cbind::model::ResolveAlias {entry macros seen} {
    set name [dict get $entry target]
    set visited [list [dict get $entry name]]
    while 1 {
        if {$name in $visited} {
            return [list no unsupported-macro "an alias cycle: [join $visited { -> }] -> $name"]
        }
        lappend visited $name
        if {[dict exists $macros $name] && [dict get $macros $name form] eq "object"
                && [::cmacro::objectCategory $name [dict get $macros $name]] eq "alias: function"
                && [MacroTarget $macros $name] ne $name} {
            set name [MacroTarget $macros $name]
            continue
        }
        if {[dict exists $seen $name]} {
            set decl [dict get $seen $name]
            if {[dict get $decl definition]} {
                return [list no unsupported-macro "an alias of $name, a static inline function (no link symbol to alias)"]
            }
            return [list ok $decl $name]
        }
        if {[dict exists $::cbind::model::ix function $name]} {
            return [list ok [dict get $::cbind::model::ix function $name] $name]
        }
        return [list no unsupported-macro "an alias of $name, which no header declares"]
    }
}

# ---------------------------------------------------------------------------
# Probe requests.

# Every typedef name and enum tag TYPE refers to, at any depth.
proc ::cbind::model::TypeNames {type} {
    set out {}
    switch -- [lindex $type 0] {
        typedef { lappend out [list typedef [lindex $type 1]] }
        enum { lappend out [list enum [lindex $type 1]] }
        q { lappend out {*}[TypeNames [lindex $type 2]] }
        ptr - array - atomic { lappend out {*}[TypeNames [lindex $type 1]] }
        fn {
            lappend out {*}[TypeNames [lindex $type 1]]
            foreach p [lindex $type 2] { lappend out {*}[TypeNames [lindex $p 1]] }
        }
    }
    return $out
}

# What the compiler must say before signatures and constants can be mapped
# (probe.tcl): {values ENTRIES symbols NAMES}.
proc ::cbind::model::ProbeRequests {model} {
    variable ix
    set values {}
    set seen [dict create]
    set typedefs {}
    foreach entry [dict get $model apis] {
        if {[dict get $entry kind] in {excluded unsupported} || ![dict exists $entry decl]} continue
        foreach ref [TypeNames [dict get $entry decl type]] {
            # A typedef's chain: every typedef on the way can carry an
            # attribute, so each one an API reaches is asked about.
            set queue [list $ref]
            while {[llength $queue]} {
                set queue [lassign $queue r]
                if {[dict exists $seen $r]} continue
                dict set seen $r 1
                lassign $r what name
                if {$what eq "typedef" && [dict exists $ix typedef $name]} {
                    lappend typedefs $name
                    lappend queue {*}[TypeNames [dict get $ix typedef $name type]]
                } elseif {$what eq "enum" && ![string match anon@* $name]} {
                    lappend values [list enum:$name [list "sizeof(enum $name)" [::cbind::probe::typeCodeOf "enum $name"]]]
                }
            }
        }
    }
    foreach name $typedefs {
        lassign [Resolve [list typedef $name]] chain final
        if {[lindex $final 0] in {int bool enum}} {
            lappend values [list td:$name [list "sizeof($name)" [::cbind::probe::typeCodeOf $name]]]
        }
    }
    # Every public enum's own type and enumerators, and every constant macro.
    foreach r [dict get $model records] {
        lassign $r kind tag body
        if {$kind ne "enum" || [dict get $body origin] ne "public" || ![dict get $body complete]} continue
        if {![string match anon@* $tag] && ![dict exists $seen [list enum $tag]]} {
            dict set seen [list enum $tag] 1
            lappend values [list enum:$tag [list "sizeof(enum $tag)" [::cbind::probe::typeCodeOf "enum $tag"]]]
        }
        foreach e [dict get $body enumerators] {
            set n [lindex $e 0]
            lappend values [list en:$n [list [::cbind::probe::exprCodeOf $n] $n]]
        }
    }
    foreach r [dict get $model records] {
        lassign $r kind name body
        if {$kind ne "typedef" || [dict get $body origin] ne "public"} continue
        set t [dict get $body type]
        if {[lindex $t 0] eq "enum" && ![dict exists $seen [list typedef $name]]} {
            dict set seen [list typedef $name] 1
            lappend values [list td:$name [list "sizeof($name)" [::cbind::probe::typeCodeOf $name]]]
        }
    }
    dict for {name b} [dict get $model macros] {
        if {[dict get $b form] ne "object"} continue
        set c [::cmacro::objectCategory $name $b]
        if {[string match constant:* $c] && $c ne "constant: string literal"} {
            lappend values [list const:$name [list [::cbind::probe::exprCodeOf $name] $name]]
        }
    }
    set symbols {}
    foreach entry [dict get $model apis] {
        switch -- [dict get $entry kind] {
            direct {
                lappend symbols [dict get $entry name]
            }
            alias {
                if {[dict exists $entry rename]} {
                    lappend symbols [dict get $entry target]
                } else {
                    lappend symbols [dict get $entry name]
                }
            }
        }
    }
    return [dict create values $values symbols [lsort -unique $symbols]]
}

# ---------------------------------------------------------------------------
# Phase 2: signatures, link symbols, contracts, constants.

# The resolved model: MODEL (candidates) with FACTS {values DICT symbols
# DICT prefix P} applied. Adds functions (the bound APIs), constants,
# identities, report (one row per public name) and problems.
proc ::cbind::model::resolve {model theFacts} {
    variable facts $theFacts
    variable profile
    variable target
    variable identities
    variable ix
    set functions {}
    set report {}
    set manualParams [dict create]
    set entries {}
    foreach entry [dict get $model apis] {
        set name [dict get $entry name]
        set kind [dict get $entry kind]
        set module [ModuleOf [dict get $entry header]]
        dict set entry module $module
        if {$kind in {excluded unsupported}} {
            lappend entries $entry
            continue
        }
        set decl [dict get $entry decl]
        set sig [Signature [dict get $decl type] [dict get $decl attrs]]
        set uses [UsesBool [dict get $decl type]]
        dict set entry usesBool $uses
        if {[lindex $sig 0] ne "ok"} {
            dict set entry kind unsupported
            dict set entry blockers [lindex $sig 1]
            lappend entries $entry
            continue
        }
        lassign $sig _ params result
        dict set entry params $params
        dict set entry result $result
        switch -- $kind {
            direct - alias {
                set probeName [expr {$kind eq "alias" && [dict exists $entry rename] ? [dict get $entry target] : $name}]
                if {![dict exists $facts symbols $probeName]} {
                    dict set entry kind unsupported
                    dict set entry blockers [list [list no-link-symbol "the symbol probe did not ask about $probeName"]]
                    lappend entries $entry
                    continue
                }
                lassign [dict get $facts symbols $probeName] status symbol
                if {$status ne "ok"} {
                    dict set entry kind unsupported
                    dict set entry blockers [list [list no-link-symbol "&($probeName) is no link-time constant of this target: $symbol"]]
                    lappend entries $entry
                    continue
                }
                dict set entry symbol $symbol
            }
            thunk {
                dict set entry symbol [ThunkSymbol $name]
            }
        }
        dict set entry botlish [Ident $name]
        dict set manualParams $name [lmap p $params {dict get $p cname}]
        lappend entries $entry
    }
    lassign [ManualContracts $manualParams] manual problems
    if {$problems ne ""} {
        error "c-bindgen: profile [dict get $profile name] (target $target): stale or invalid contract policy:\n  [join $problems "\n  "]"
    }
    set out {}
    foreach entry $entries {
        if {[dict get $entry kind] in {direct alias thunk}} {
            set entry [ApplyContracts $entry [expr {[dict exists $manual [dict get $entry name]] ? [dict get $manual [dict get $entry name]] : {}}] {}]
        }
        lappend out $entry
    }
    dict set model apis $out
    dict set model manual $manual
    dict set model constants [Constants $model]
    dict set model identities $identities
    return $model
}

# The thunk symbol of API NAME: profile-qualified, so one name in two
# libraries' bindings never collides.
proc ::cbind::model::ThunkSymbol {name} {
    variable profile
    return botlish_[dict get $profile name]_$name
}

# 1 if TYPE mentions C _Bool anywhere (resolved through typedefs).
proc ::cbind::model::UsesBool {type} {
    variable ix
    set t [Unq $type]
    switch -- [lindex $t 0] {
        bool { return 1 }
        typedef {
            if {![dict exists $ix typedef [lindex $t 1]]} { return 0 }
            return [UsesBool [dict get $ix typedef [lindex $t 1] type]]
        }
        ptr - array { return [UsesBool [lindex $t 1]] }
        fn {
            if {[UsesBool [lindex $t 1]]} { return 1 }
            foreach p [lindex $t 2] { if {[UsesBool [lindex $p 1]]} { return 1 } }
        }
    }
    return 0
}

# ENTRY's parameters and result with their contract facts: the profile's
# MANUAL facts (PARAM-or-result -> {facts F source S}) and the compiler's
# EVIDENCE (a list, per parameter, of attribute lists). A contradiction
# between two positive sources is a conflict (an error naming both); a
# fact a parameter cannot carry is an error of the profile.
proc ::cbind::model::ApplyContracts {entry manual evidence} {
    set name [dict get $entry name]
    set params {}
    set conflicts {}
    set evidenceLog {}
    set i 0
    set returned {}
    foreach p [dict get $entry params] {
        set cname [dict get $p cname]
        set pointer [expr {"pointer" in [dict get $p features]}]
        set callback [expr {"callback" in [dict get $p features] && [string match ffi::c::FnPtr* [dict get $p type]]}]
        set access ""
        set escape ""
        set sources {}
        if {[dict exists $manual $cname]} {
            set m [dict get $manual $cname]
            set f [dict get $m facts]
            if {!$pointer} {
                error "c-bindgen: [dict get $m source]: $name's parameter \"$cname\" is no pointer ([Spell [dict get $p ctype]]): it carries no contract"
            }
            if {[dict exists $f provenance]} {
                error "c-bindgen: [dict get $m source]: \"independent\"/\"alias\" are facts of $name's result, not of its parameter \"$cname\""
            }
            if {[dict exists $f access]} {
                if {$callback} {
                    error "c-bindgen: [dict get $m source]: $name's parameter \"$cname\" is a function pointer: it has no access"
                }
                set access [dict get $f access]
            }
            if {[dict exists $f escape]} { set escape [dict get $f escape] }
            lappend sources [list manual [dict get $m source] [dict remove $f provenance]]
        }
        set ev [lindex $evidence $i]
        if {$ev ne "" && $pointer} {
            set e [EvidenceFacts $ev]
            if {[dict exists $e access] && !$callback} {
                if {$access ne "" && $access ne [dict get $e access]} {
                    lappend conflicts "parameter $cname: the profile says $access, the compiler proves [dict get $e access] ([join $ev { }])"
                } else {
                    set access [dict get $e access]
                }
            }
            if {[dict exists $e escape]} {
                if {$escape eq "captures"} {
                    lappend conflicts "parameter $cname: the profile says captures, the compiler proves nocapture"
                } else {
                    set escape proven-noescape
                }
            }
            if {[dict exists $e returned]} { lappend returned $cname }
            if {[dict size $e]} {
                lappend sources [list compiler $ev [dict remove $e returned]]
            }
        }
        dict set p access $access
        dict set p escape $escape
        dict set p sources $sources
        lappend params $p
        incr i
    }
    set result [dict get $entry result]
    set provenance ""
    set rsources {}
    set resultPointer [expr {[string match ffi::c::Ptr* [dict get $result type]]}]
    if {[dict exists $manual result]} {
        set m [dict get $manual result]
        set f [dict get $m facts]
        if {![dict exists $f provenance] || [dict size $f] != 1} {
            error "c-bindgen: [dict get $m source]: $name's result takes \"independent\" or \"alias PARAM\" only"
        }
        if {!$resultPointer} {
            error "c-bindgen: [dict get $m source]: $name returns [Spell [dict get $result ctype]], not a data pointer: its result has no provenance"
        }
        set provenance [dict get $f provenance]
        if {[lindex $provenance 0] eq "alias"} {
            set target [lindex $provenance 1]
            if {[FindParam $params $target] eq ""} {
                error "c-bindgen: [dict get $m source]: $name's result is declared an alias of \"$target\", which is not one of its parameters"
            }
        }
        lappend rsources [list manual [dict get $m source] $provenance]
    }
    if {[llength $returned] && $resultPointer} {
        set ev [list alias [lindex $returned 0]]
        if {$provenance ne "" && $provenance ne $ev} {
            lappend conflicts "result: the profile says [join $provenance { }], the compiler proves returned [lindex $returned 0]"
        } else {
            # An alias needs the same Botlish type on both sides.
            set q [FindParam $params [lindex $returned 0]]
            if {[dict get $q type] eq [dict get $result type]} {
                set provenance $ev
                lappend rsources [list compiler returned $ev]
            } else {
                lappend rsources [list compiler-unused returned "the result and [lindex $returned 0] differ in type ([dict get $result type], [dict get $q type]): no exact alias"]
            }
        }
    }
    if {$conflicts ne ""} {
        error "c-bindgen: contract conflict for $name:\n  [join $conflicts "\n  "]"
    }
    dict set result provenance $provenance
    dict set result sources $rsources
    # The Botlish names of an alias target: the C parameter name of the
    # contract, the Botlish one of the declaration.
    if {[lindex $provenance 0] eq "alias"} {
        foreach q $params {
            if {[dict get $q cname] eq [lindex $provenance 1]} {
                dict set result provenance [list alias [dict get $q name]]
            }
        }
    }
    # A written parameter's bytes come back as a field of its name beside
    # `result`: a parameter named result is renamed.
    set renamed {}
    foreach q $params {
        if {[dict get $q access] eq "write" && [dict get $q name] eq "result"} {
            dict set q name result_
        }
        lappend renamed $q
    }
    dict set entry params $renamed
    dict set entry result $result
    return $entry
}

# The parameter of PARAMS whose C name is CNAME, or "".
proc ::cbind::model::FindParam {params cname} {
    foreach q $params {
        if {[dict get $q cname] eq $cname} { return $q }
    }
    return ""
}

# The constants: public object-like macros of an integer type, and the
# enumerators of public enums, each of the C type the compiler gives it (an
# enumerator: its enum's ABI type, the type its parameters take). A list of
# {name N module M type SCALAR value V kind macro|enumerator ctype C
# header H line L}; non-constants go to the report only (Report).
proc ::cbind::model::Constants {model} {
    variable facts
    variable ix
    variable options
    set out {}
    foreach r [dict get $model records] {
        lassign $r kind tag body
        if {$kind ne "enum" || [dict get $body origin] ne "public" || ![dict get $body complete]} continue
        set via [EnumTypedefOf [dict get $model records] $tag]
        set scalar ""
        set ctype int
        if {[string match anon@* $tag] && $via eq ""} {
            set scalar ffi::c::Int
        } else {
            set e [EnumScalar $tag $via]
            if {$e ne ""} { lassign $e scalar ctype }
        }
        foreach e [dict get $body enumerators] {
            lassign $e n form value
            set c [dict create name $n module [ModuleOf [lindex [dict get $body loc] 0]] kind enumerator \
                header [lindex [dict get $body loc] 0] line [lindex [dict get $body loc] 1] \
                enum [expr {[string match anon@* $tag] ? ($via eq "" ? "" : $via) : "enum $tag"}]]
            if {$scalar eq ""} {
                dict set c status unsupported
                dict set c reason enum-unknown-abi
                dict set c detail "the compiler gave enum $tag no integer type"
            } elseif {[dict exists $facts values en:$n] && [lindex [dict get $facts values en:$n] 0] eq "ok"} {
                set word [lindex [dict get $facts values en:$n] 1 1]
                set v [expr {$word >= 2**63 ? $word - 2**64 : $word}]
                if {$value ne "" && $value != $v} {
                    error "c-bindgen: enumerator $n: the parser computed $value, the compiler $v"
                }
                dict set c status constant
                dict set c type $scalar
                dict set c ctype $ctype
                dict set c value $v
            } else {
                dict set c status unsupported
                dict set c reason not-constant
                dict set c detail "the compiler did not evaluate it"
            }
            lappend out $c
        }
    }
    set apiNames [dict create]
    foreach a [dict get $model apis] { dict set apiNames [dict get $a name] 1 }
    foreach name [dict get $model macroOrder] {
        set b [dict get $model macros $name]
        if {[dict get $b form] ne "object"} continue
        set cat [::cmacro::objectCategory $name $b]
        if {$cat eq "alias: function" || [dict exists $apiNames $name]} {
            continue
        }
        set c [dict create name $name module [ModuleOf [lindex [dict get $b loc] 0]] kind macro \
            header [lindex [dict get $b loc] 0] line [lindex [dict get $b loc] 1] category $cat]
        if {[dict exists $facts values const:$name]} {
            lassign [dict get $facts values const:$name] status data
            if {$status ne "ok"} {
                dict set c status unsupported
                dict set c reason not-constant
                dict set c detail "the compiler rejected it as an integer constant: $data"
            } else {
                lassign $data code word
                set ctype [::cbind::probe::typeOfCode $code]
                set scalar [ScalarOf $ctype]
                if {$ctype eq "_Bool"} {
                    if {[dict get $options bool]} {
                        dict set c status constant
                        dict set c type ffi::c::Bool
                        dict set c ctype _Bool
                        dict set c value [expr {$word != 0}]
                    } else {
                        dict set c status unsupported
                        dict set c reason unsupported-bool
                        dict set c detail "a _Bool constant"
                    }
                } elseif {$scalar ne ""} {
                    set signed [expr {$ctype in {{signed char} short int long {long long}} || ($ctype eq "char" && [dict get [core::cabi::scalarInfo Char $::cbind::model::target] signed])}]
                    set width [dict get [core::cabi::scalarInfo [string range $scalar 8 end] $::cbind::model::target] bits]
                    set v $word
                    if {$signed && $word >= 2**($width - 1) && $word < 2**$width} {
                        set v [expr {$word - 2**$width}]
                    } elseif {$signed && $word >= 2**63} {
                        set v [expr {$word - 2**64}]
                    }
                    dict set c status constant
                    dict set c type $scalar
                    dict set c ctype $ctype
                    dict set c value $v
                } elseif {$ctype in {float double {long double}}} {
                    dict set c status unsupported
                    dict set c reason [expr {$ctype eq "float" ? "float" : "double"}]
                    dict set c detail "a $ctype constant"
                } else {
                    dict set c status unsupported
                    dict set c reason not-integer-constant
                    dict set c detail "its type is no C integer type (a pointer or another type)"
                }
            }
        } else {
            dict set c status not-constant
            dict set c reason [MacroKind $cat]
            dict set c detail $cat
        }
        lappend out $c
    }
    return $out
}

# The typedef naming the enum TAG directly, or "".
proc ::cbind::model::EnumTypedefOf {records tag} {
    foreach r $records {
        lassign $r kind name body
        if {$kind eq "typedef" && [dict get $body type] eq [list enum $tag]} { return $name }
    }
    return ""
}

# The report reason of an object-like macro that is no constant, by its
# category.
proc ::cbind::model::MacroKind {category} {
    switch -glob -- $category {
        empty { return empty }
        "constant: string literal" { return string-literal }
        "type spelling" { return type-spelling }
        decoration* { return decoration }
        "alias: undeclared identifier" - "expression: undeclared identifier" { return names-nothing }
        "alias: object" - "expression: refers to a function or object" - "expression: address of an object" { return object }
        "comma list*" - initializer* - "statement or declaration" { return fragment }
        expression* { return unsupported-macro }
        default { return unsupported-macro }
    }
}
