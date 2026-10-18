# query.tcl -- small queries over a profile's IR (C-HEADER-ARCHAEOLOGY.md,
# "Queries").
#
#   tclsh9.0 audit/c-header/tools/query.tcl PROFILE QUERY ?ARG?
#
# QUERY is one of
#
#   callbacks      functions taking or returning a function pointer
#   variadic       variadic functions
#   ptrptr         parameters of pointer depth >= 2 (typedefs resolved)
#   struct-arrays  complete structs with array fields, and those fields
#   unions         union definitions and every use of a union type
#   thunks         function-like macros a generated wrapper could replace
#   attributes     surviving attributes (ARG: one attribute name)
#   byvalue        aggregates passed or returned by value
#   floats         every floating-point use
#   inline         inline definitions (no link symbol)
#   opaque         opaque tags and the typedefs naming them
#   layout         complete structs and their layout requirements
#   show NAME      every record named NAME, with its type rendered as C
#   chain NAME     the typedef chain of NAME
#   grep REGEX     records whose preprocessed text matches REGEX
#   unsupported    unsupported records
#   macro NAME     a macro's definition and expansion
#
# One result per line: NAME, a tab, what was found.

set here [file dirname [file normalize [info script]]]
source [file join $here common.tcl]
::chdr::use cdecl.tcl
::chdr::use ir.tcl
source [file join $here census.tcl]

proc load {profile} {
    set dir [file join $::chdr::root results $profile]
    set ::library [::cir::read [file join $dir ir.txt]]
    set ::system [::cir::read [file join $dir system.txt]]
    set ::macros [::cir::read [file join $dir macros.txt]]
    set ::census::ix [::cir::index [concat $::system $::library]]
    set ::census::libIx [::cir::index $::library]
    set ::api {}
    foreach r $::library {
        if {[dict get [lindex $r 2] origin] in {public bundled}} { lappend ::api $r }
    }
}

proc out {name text} { if {[catch {puts "$name\t$text"}]} { exit 0 } }
proc where {r} { join [lrange [dict get [lindex $r 2] loc] 0 1] : }
proc c {r} {
    lassign $r kind name b
    if {$kind eq "typedef"} { return "typedef [::cir::render [dict get $b type] $name]" }
    if {[dict exists $b type]} { return [::cir::render [dict get $b type] $name] }
    return [dict get $b text]
}

proc query {q arg} {
    switch -- $q {
        callbacks {
            foreach r [::census::ofKind $::api function] {
                lassign [::census::sig $r] result params
                set hit [::census::isFnPtr $result]
                foreach p $params { if {[::census::isFnPtr [lindex $p 1]] || [::census::cat [lindex $p 1]] eq "fn"} { set hit 1 } }
                if {$hit} { out [lindex $r 1] [c $r] }
            }
        }
        variadic {
            foreach r [::census::ofKind $::api function] {
                if {"variadic" in [lindex [::census::sig $r] 2]} { out [lindex $r 1] [c $r] }
            }
        }
        ptrptr {
            foreach r [::census::ofKind $::api function] {
                foreach p [lindex [::census::sig $r] 1] {
                    if {[::census::depth [lindex $p 1] 1] >= 2} {
                        out "[lindex $r 1]\([lindex $p 0]\)" [::cir::spell [lindex $p 1]]
                    }
                }
            }
        }
        struct-arrays {
            foreach {key r} [::census::CompleteTags $::api] {
                foreach f [dict get [lindex $r 2] fields] {
                    if {[lindex [::cir::unq [::census::final [lindex $f 1]]] 0] eq "array"} {
                        out "$key.[lindex $f 0]" [::cir::render [lindex $f 1] [lindex $f 0]]
                    }
                }
            }
        }
        unions {
            foreach {key r} [::census::CompleteTags $::api] {
                if {[lindex $key 0] eq "union"} { out $key "defined at [where $r]" }
            }
            foreach item [::census::PositionTypes $::api] {
                lassign $item position name t
                if {[::census::cat $t] eq "union" || ([::census::cat $t] eq "ptr" && [::census::pointee $t] in {union opaque-union})} {
                    out $name "$position [::cir::spell $t]"
                }
            }
        }
        thunks {
            foreach m $::macros {
                lassign $m _ name b
                if {[dict get $b form] ne "function" || [dict get $b undefined]} continue
                lassign [::census::MacroFunctionCategory $name $b] cat flags
                set t [::census::Thunkable function $cat $flags]
                if {[string match yes* $t] || [string match per* $t]} {
                    out $name "$t | $cat | [dict get $b body]"
                }
            }
        }
        attributes {
            foreach r [concat $::api] {
                foreach a [::census::AllAttrs $r] {
                    if {$arg ne "" && [lindex $a 2] ne $arg} continue
                    out [lindex $r 1] "[lindex $a 0] [lindex $a 2]([lindex $a 3]) at [lindex $a 1]"
                }
            }
        }
        byvalue {
            foreach r [::census::ofKind $::api function] {
                lassign [::census::sig $r] result params
                set hit [expr {[::census::cat $result] in {struct union}}]
                foreach p $params { if {[::census::cat [lindex $p 1]] in {struct union}} { set hit 1 } }
                if {$hit} { out [lindex $r 1] [c $r] }
            }
        }
        floats {
            foreach item [::census::PositionTypes $::api] {
                lassign $item position name t
                foreach n [::census::nodes $t] {
                    if {[lindex [::cir::unq [::census::final $n]] 0] in {float complex}} {
                        out $name "$position [::cir::spell $t]"
                        break
                    }
                }
            }
        }
        inline {
            foreach r [::census::ofKind $::api function] {
                if {[dict get [lindex $r 2] definition]} { out [lindex $r 1] "[where $r] [c $r]" }
            }
        }
        opaque {
            foreach r [::census::ofKind $::api typedef] {
                set t [dict get [lindex $r 2] type]
                set u [::cir::unq $t]
                if {[lindex $u 0] eq "ptr"} { set u [::cir::unq [lindex $u 1]] }
                if {[lindex $u 0] in {struct union} && ![::census::complete "[lindex $u 0] [lindex $u 1]"]} {
                    out [lindex $r 1] [c $r]
                }
            }
        }
        layout {
            foreach {key r} [::census::CompleteTags $::api] {
                out $key [::census::Requirements $key]
            }
        }
        show {
            foreach r [concat $::system $::library] {
                if {[lindex $r 1] eq $arg} {
                    out "[lindex $r 0] $arg" "[where $r] [c $r]"
                    puts [::cir::format1 $r]
                }
            }
        }
        chain {
            lassign [::cir::resolve $::census::ix [list typedef $arg]] chain final
            out $arg "[join $chain { -> }] -> [::cir::spell $final]"
        }
        grep {
            foreach r $::library {
                if {[regexp -- $arg [dict get [lindex $r 2] text]]} { out [lindex $r 1] "[where $r] [dict get [lindex $r 2] text]" }
            }
        }
        unsupported {
            foreach r [concat $::library $::system] {
                if {[lindex $r 0] eq "unsupported"} {
                    out [dict get [lindex $r 2] category] "[where $r] [dict get [lindex $r 2] reason]: [dict get [lindex $r 2] text]"
                }
            }
        }
        macro {
            foreach m $::macros {
                if {[lindex $m 1] eq $arg} { puts [::cir::format1 $m] }
            }
        }
        default { error "unknown query $q" }
    }
}

load [lindex $argv 0]
query [lindex $argv 1] [lindex $argv 2]
