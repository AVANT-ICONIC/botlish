#!/usr/bin/env tclsh9.0
# fuzz.tcl -- generated callback-registry programs against an independent
# model of the verified callable contract boundary
# (VERIFIED-CALLABLE-CONTRACT-BOUNDARY.md).
#
#   tclsh9.0 audit/structural-contracts/tools/fuzz.tcl ?-n N? ?-seed S?
#       ?-dump 1? ?-backends LIST? ?-gc-stress 0|1? ?-fault KIND?
#
# Each program declares four error identities -- E1..E4, E2 and E4 carrying a
# payload {code: int}; or, in every other program, two same-short-name
# module errors alpha::Failed and beta::Failed (written to a private copy of
# the library) beside E3 and E4 -- and one raiser per identity, an untyped
# function failing it for one selector value. Then:
#
#   erasure     some raisers are passed through the untyped helper `call` and
#               handled there (`recovered` observations), others captured by
#               closures that call them (`wrap_J`, `make`): the program's
#               erased-callable contract U is every identity so passed
#   slots       two to four structs S_J with a field run: Fn{args: [int],
#               return: any, errors: C_J} (C_J a random subset, often
#               empty), each stored with an implementation: an error-free
#               function, a raiser of an identity in C_J, or a closure
#               wrap_J(f) creates around an untyped captured f, given one or
#               two raisers at its call sites
#   calls       per slot, observe_J(s, k) calls (s.run)(k) with handlers H_J
#               and declares D_J; the driver calls it for k = 0..4 and
#               handles D_J. Also: a recovered exact call call(r_I, k), and
#               an unidentified uncontracted call h(k) of a closure make(r_I)
#               returned from another activation
#
# The model shares no code with the compiler. It decides legality from the
# three precisions alone:
#
#   exact / recovered       call(r_I, k) may raise exactly E_I
#   contracted, unknown     (s.run)(k) may raise exactly C_J -- never U
#   uncontracted, unknown   h(k) may raise exactly U
#
# a call is legal iff what it may raise is within its handlers and the
# enclosing declaration; and a closure wrap_J stores in S_J is legal iff
# every raiser its call sites pass it is in C_J (the boundary: its type shows
# none of them). Every diagnostic the model predicts is (KIND, IDENTITY):
# UNHANDLED-ERROR or TYPE naming the identity; the compiler's diagnostics,
# compiled with -strict 0 and reduced the same way, must be exactly that set.
# An accepted program runs on every backend of BACKENDS and must produce the
# model's value: which raiser each stored callable reaches, which handler
# runs, what payload it receives. No accepted program may record a
# structural call raising beyond its contract (contractExcess).
#
# Faults (a third of the programs, or every one with -fault KIND): `drop` a
# contract error from a slot's handlers and declaration (UNHANDLED-ERROR),
# `carrier` give a wrap_J a raiser outside C_J (TYPE), `unknown` drop an
# erased identity from the unidentified call's handlers (UNHANDLED-ERROR).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 40 -seed 1 -dump 0 -backends {interp compile cranelift-generic cranelift} -gc-stress 0 -fault ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "fuzz.tcl: unknown option $option"
    }
    dict set options $option $value
}
set argv {}
source [file join $root tests helpers.tcl]

# A private copy of the library for the namespaced programs' modules (never
# the real lib/), removed at exit.
set ::fuzzLib [file tempdir botlish-scc-fuzz-lib]
foreach entry [glob -directory $::core::libraryDir *] {
    file copy $entry $::fuzzLib
}
set ::core::libraryDir $::fuzzLib

# ---------------------------------------------------------------------------
# Deterministic choices

proc Rand {n} {
    global seedState
    set seedState [expr {($seedState * 1103515245 + 12345) % 2147483648}]
    return [expr {($seedState / 65536) % $n}]
}

proc Pick {list} {
    return [lindex $list [Rand [llength $list]]]
}

proc Subset {list} {
    return [lmap x $list {expr {[Rand 2] ? $x : [continue]}}]
}

proc Minus {a b} {
    return [lmap x $a {expr {$x in $b ? [continue] : $x}}]
}

proc Union {args} {
    return [lsort -unique [concat {*}$args]]
}

# ---------------------------------------------------------------------------
# Identities. Each: {NAME TAG SELECTOR PAYLOAD RAISER}: its spelling, the
# handler's tag, the k it fails for, whether it carries {code: int}, the
# raiser's spelling.

proc Identities {namespaced} {
    if {$namespaced} {
        return {
            {alpha::Failed A 1 0 alpha::raise}
            {beta::Failed B 2 0 beta::raise}
            {E3 E3 3 0 r3}
            {E4 E4 4 1 r4}
        }
    }
    return {
        {E1 E1 1 0 r1}
        {E2 E2 2 1 r2}
        {E3 E3 3 0 r3}
        {E4 E4 4 1 r4}
    }
}

proc Field {state name i} {
    foreach id [dict get $state ids] {
        if {[lindex $id 0] eq $name} {
            return [lindex $id $i]
        }
    }
    error "no identity $name"
}

proc ModuleText {name k} {
    return "error Failed\n\nfn raise(x) -> int errors Failed:\n    if x == $k:\n        fail Failed\n    $k * 100\n"
}

# The handler text of identity NAME, answering a List starting with its tag
# (and the payload's code), indented by INDENT.
proc Handler {state name indent} {
    set tag [Field $state $name 1]
    if {[Field $state $name 3]} {
        return "${indent}on $name {code}:\n${indent}    return \[\"$tag\", code\]\n"
    }
    return "${indent}on $name:\n${indent}    return \[\"$tag\"\]\n"
}

# The model's observation of a call raising NAME (or "" for a normal
# completion with VALUE) under handlers H, declared D (the driver handles D
# as "D:" TAG).
proc Observed {state name value h d} {
    if {$name eq ""} {
        return "\[$value\]"
    }
    set tag [Field $state $name 1]
    if {$name in $h} {
        if {[Field $state $name 3]} {
            return "\[\"$tag\", [expr {[Field $state $name 2] * 10}]\]"
        }
        return "\[\"$tag\"\]"
    }
    return "\[\"D:$tag\"\]"
}

# What calling raiser NAME with K does: {ERROR VALUE}.
proc Raise {state name k} {
    if {$k == [Field $state $name 2]} {
        return [list $name ""]
    }
    return [list "" [expr {[Field $state $name 2] * 100}]]
}

# A function OBSERVE that makes CALL (text) with handlers H and declares D,
# and its driver TOP over k = 0..4 handling D. {TEXT DRIVER-CALLS}.
proc Observation {state observe params call h d argsBefore {pre ""}} {
    set text "fn $observe\($params\)"
    if {$d ne {}} {
        append text " errors [join $d {, }]"
    }
    append text ":\n$pre"
    if {$h eq {}} {
        append text "    r = $call\n"
    } else {
        append text "    r = $call:\n"
    }
    foreach name $h {
        append text [Handler $state $name "        "]
    }
    append text "    \[r\]\n\n"
    append text "fn top_$observe\(k: int):\n    o = $observe\($argsBefore\k):\n"
    foreach name $d {
        append text "        on $name:\n            return \[\"D:[Field $state $name 1]\"\]\n"
    }
    if {$d eq {}} {
        set text [string map [list "    o = $observe\($argsBefore\k):\n" "    o = $observe\($argsBefore\k)\n"] $text]
    }
    append text "    o\n\n"
    return $text
}

# ---------------------------------------------------------------------------
# One program: {TEXT EXPECT FILES}, EXPECT {value V} or {diagnostics PAIRS}.

proc Program {number} {
    global options
    set namespaced [expr {$number % 2 == 1}]
    set ids [Identities $namespaced]
    set names [lmap id $ids {lindex $id 0}]
    set state [dict create ids $ids]
    set fault [dict get $options -fault]
    if {$fault eq "" && [Rand 3] == 0} {
        set fault [Pick {drop carrier unknown}]
    }
    set files [dict create]
    set text ""
    if {$namespaced} {
        dict set files alpha.bot [ModuleText alpha 1]
        dict set files beta.bot [ModuleText beta 2]
        append text "import alpha\nimport beta\n\n"
    }
    foreach id $ids {
        lassign $id name tag k payload raiser
        if {[string match *::* $name]} {
            continue
        }
        if {$payload} {
            append text "error $name:\n    code: int\n\n"
        } else {
            append text "error $name\n\n"
        }
    }
    foreach id $ids {
        lassign $id name tag k payload raiser
        if {[string match *::* $raiser]} {
            continue
        }
        set f [expr {$payload ? "fail $name {code: [expr {$k * 10}]}" : "fail $name"}]
        append text "fn $raiser\(x) -> int errors $name:\n    if x == $k:\n        $f\n    $k * 100\n\n"
    }
    append text "fn call(f, x):\n    f(x)\n\nfn quiet(x) -> int:\n    7\n\n"
    append text "fn make(f):\n    fn inner(x):\n        f(x)\n    inner\n\n"
    set erased {}
    set expectDiags {}
    set drivers {}
    set values {}
    set faultDone 0

    # Recovered exact calls.
    set recovered [lrange [Subset $names] 0 1]
    foreach name $recovered {
        set raiser [Field $state $name 4]
        lappend erased $name
        set h [list $name]
        set d {}
        set observe "rec_[Field $state $name 1]"
        append text [Observation $state $observe "k: int" "call($raiser, k)" $h $d ""]
        for {set k 0} {$k < 5} {incr k} {
            lassign [Raise $state $name $k] err v
            lappend drivers "top_$observe\($k)"
            lappend values [Observed $state $err $v $h $d]
        }
    }

    # Slots.
    set slots [expr {2 + [Rand 3]}]
    set slotPlans {}
    for {set j 0} {$j < $slots} {incr j} {
        set contract [Subset $names]
        set kind [Pick {quiet raiser carrier carrier}]
        if {$kind eq "raiser" && $contract eq {}} {
            set kind quiet
        }
        set plan [dict create contract $contract kind $kind]
        switch -- $kind {
            raiser {
                dict set plan target [Pick $contract]
            }
            carrier {
                set given [list [Pick $names]]
                if {[Rand 2]} {
                    lappend given [Pick $names]
                }
                set given [lsort -unique $given]
                if {[Minus $given $contract] ne {}} {
                    # Keep the plan legal unless this is the carrier fault.
                    if {$fault eq "carrier" && !$faultDone} {
                        set faultDone 1
                    } else {
                        set contract [Union $contract $given]
                        dict set plan contract $contract
                    }
                }
                dict set plan given $given
                dict set plan target [lindex $given 0]
                lappend erased {*}$given
            }
        }
        lappend slotPlans $plan
    }

    # The unidentified, uncontracted call.
    set unknown [expr {[Rand 3] > 0}]
    if {$unknown} {
        set unknownTarget [Pick $names]
        lappend erased $unknownTarget
    }
    set erased [lsort -unique $erased]

    for {set j 0} {$j < $slots} {incr j} {
        set plan [lindex $slotPlans $j]
        set contract [dict get $plan contract]
        set kind [dict get $plan kind]
        append text "struct S$j:\n    run: Fn{args: \[int\], return: any, errors: \[[join $contract {, }]\]}\n\n"
        switch -- $kind {
            quiet {
                append text "fn store$j\() -> S$j:\n    S$j {run: quiet}\n\n"
            }
            raiser {
                append text "fn store$j\() -> S$j:\n    S$j {run: [Field $state [dict get $plan target] 4]}\n\n"
            }
            carrier {
                append text "fn wrap$j\(f) -> S$j:\n    fn inner(x):\n        f(x)\n    S$j {run: inner}\n\n"
                append text "fn store$j\() -> S$j:\n    wrap$j\([Field $state [dict get $plan target] 4])\n\n"
                foreach other [lrange [dict get $plan given] 1 end] {
                    append text "fn other$j\() -> S$j:\n    wrap$j\([Field $state $other 4])\n\n"
                }
                set outside [Minus [dict get $plan given] $contract]
                foreach name $outside {
                    lappend expectDiags [list TYPE $name]
                }
            }
        }
        # Handlers and declaration: together exactly the contract, split at
        # random; the drop fault loses one contract error.
        set h {}
        set d {}
        foreach name $contract {
            if {[Rand 2]} { lappend h $name } else { lappend d $name }
        }
        if {$fault eq "drop" && !$faultDone && $contract ne {}} {
            set faultDone 1
            set lost [Pick $contract]
            set h [Minus $h [list $lost]]
            set d [Minus $d [list $lost]]
            lappend expectDiags [list UNHANDLED-ERROR $lost]
        }
        # An unrelated erased identity handled too, sometimes: harmless.
        if {[Rand 3] == 0 && [set extra [Minus $erased $contract]] ne {}} {
            lappend h [Pick $extra]
        }
        set h [lsort -unique $h]
        append text [Observation $state "obs$j" "s: S$j, k: int" "(s.run)(k)" $h $d "store$j\(), "]
        for {set k 0} {$k < 5} {incr k} {
            switch -- $kind {
                quiet { set outcome {"" 7} }
                default { set outcome [Raise $state [dict get $plan target] $k] }
            }
            lassign $outcome err v
            lappend drivers "top_obs$j\($k)"
            lappend values [Observed $state $err $v $h $d]
        }
    }

    if {$unknown} {
        set h $erased
        set d {}
        if {[llength $h] > 1 && [Rand 2]} {
            set moved [Pick $h]
            set h [Minus $h [list $moved]]
            set d [list $moved]
        }
        if {$fault eq "unknown" && !$faultDone} {
            set faultDone 1
            set lost [Pick $erased]
            set h [Minus $h [list $lost]]
            set d [Minus $d [list $lost]]
            lappend expectDiags [list UNHANDLED-ERROR $lost]
        }
        set raiser [Field $state $unknownTarget 4]
        append text "fn unknown_h():\n    make($raiser)\n\n"
        append text [Observation $state "obs_unknown" "k: int" "h(k)" $h $d "" "    h = unknown_h()\n"]
        for {set k 0} {$k < 5} {incr k} {
            lassign [Raise $state $unknownTarget $k] err v
            lappend drivers "top_obs_unknown($k)"
            lappend values [Observed $state $err $v $h $d]
        }
    }
    append text "\[[join $drivers {, }]\]\n"
    if {$expectDiags ne {}} {
        return [list $text [list diagnostics [lsort -unique $expectDiags]] $files]
    }
    return [list $text [list value "\[[join $values {, }]\]"] $files]
}

# The compiler's diagnostics of HIR as (KIND, IDENTITY) pairs.
proc Diagnostics {hir} {
    return [lsort -unique [lmap d [hir::diagnostics $hir] {
        set name ""
        regexp {declared error "([^"]+)"} [dict get $d message] -> name
        list [dict get $d kind] $name
    }]]
}

proc Excess {hir} {
    set result {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict exists $node contractExcess]} {
            lappend result $e [dict get $node contractExcess]
        }
    }
    return $result
}

proc Run {} {
    global options
    set backends [dict get $options -backends]
    set accepted 0
    set rejected 0
    set disagreements 0
    set kinds [dict create]
    set nativeOk [expr {$::tcl_platform(os) eq "Linux" && $::tcl_platform(machine) in {x86_64 amd64}}]
    for {set p 0} {$p < [dict get $options -n]} {incr p} {
        set number [expr {[dict get $options -seed] + $p}]
        set ::seedState [expr {$number * 7919 + 17}]
        lassign [Program $number] text expect files
        dict for {file content} $files {
            set ch [open [file join $::core::libraryDir $file] w]
            fconfigure $ch -encoding utf-8
            puts -nonewline $ch $content
            close $ch
        }
        if {[dict get $options -dump]} {
            puts "--- program $number\n$text--- expect $expect"
        }
        set problem ""
        if {[catch {surface::compile $text -strict 0 -warnings off} hir errOptions]} {
            set problem "rejected outside HIR: $hir"
        } elseif {[lindex $expect 0] eq "diagnostics"} {
            set got [Diagnostics $hir]
            if {$got ne [lindex $expect 1]} {
                set problem "diagnostics $got, model [lindex $expect 1]"
            } else {
                incr rejected
                foreach pair $got {
                    dict incr kinds [lindex $pair 0]
                }
            }
        } elseif {[set got [Diagnostics $hir]] ne {}} {
            set problem "diagnostics $got, model none"
        } elseif {[set excess [Excess $hir]] ne {}} {
            set problem "contractExcess $excess"
        } else {
            foreach b $backends {
                if {$b in {cranelift cranelift-generic} && !$nativeOk} {
                    continue
                }
                set o [lrange [outcomeUnderHir $b $hir] 0 1]
                if {$o ne $expect} {
                    set problem "$b gives $o, model $expect"
                    break
                }
            }
            if {$problem eq "" && [dict get $options -gc-stress] && $nativeOk} {
                set ::env(BOTLISH_NATIVE_GC_STRESS) 1
                try {
                    set o [lrange [outcomeUnderHir cranelift $hir] 0 1]
                } finally {
                    unset ::env(BOTLISH_NATIVE_GC_STRESS)
                }
                if {$o ne $expect} {
                    set problem "cranelift under GC stress gives $o, model $expect"
                }
            }
            if {$problem eq ""} {
                incr accepted
            }
        }
        if {$problem ne ""} {
            incr disagreements
            puts "DISAGREEMENT program $number:\n$problem\n--- program\n$text"
        }
    }
    puts "accepted $accepted rejected $rejected ([join [lmap {c n} [lsort -stride 2 $kinds] {string cat "$c $n"}] {, }])"
    puts "programs [dict get $options -n] disagreements $disagreements"
    return $disagreements
}

try {
    set status [Run]
} finally {
    file delete -force $::fuzzLib
}
exit [expr {$status > 0 ? 1 : 0}]
