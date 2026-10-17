#!/usr/bin/env tclsh9.0
# fuzz.tcl -- generated module graphs against an independent model of direct
# modules (DIRECT-MODULES.md).
#
#   tclsh9.0 audit/direct-modules/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1?
#
# Each program is an application of 1..4 source modules m1..mK beside an
# entry program (main.bot), each module importing earlier ones (the graph is
# acyclic, as module graphs are), with:
#
#   * the marker `direct module`, present or absent at random;
#   * 0..1 context structs of its own (non-opaque, so the entry program can
#     install them);
#   * 1..3 functions, each requiring none, its own context, an earlier
#     module's context, or both, whose bodies make calls of five kinds:
#       raw      the intrinsic direct module linux::abi::x86_64 (a getpid syscall)
#       call     a function of an earlier module, called directly
#       alias    the same through a local alias (`g = mJ::fN` then `g()`)
#       nested   the same from a nested function, which requires the
#                function's context itself or not
#       pure     ordinary arithmetic
#     and, at random, one escape: an earlier module's function used as a
#     value (returned inside a list);
#   * the entry program, also marked or not, installing every context and
#     calling every module's first function -- at its top level or from a
#     function requiring a context of its own.
#
# The model, written from the specification, not from hir/direct.tcl: a
# module is designated direct by its marker (linux::abi::x86_64 by the compiler); a
# call of a function of a designated module other than the caller's own is a
# direct edge; an edge is mediated when the function making it -- the nested
# function itself, for a nested call -- requires a context its own module
# declares; a module is inferred direct when it has an unmediated edge; the
# verdicts are DIRECT (inferred, not marked), STALE-DIRECT-MODULE (marked, not
# inferred) and DIRECT-CALLABLE-VALUE (an escape in a module not marked). The
# compiler's -strict 0 diagnostics (kind and file) and its per-module status
# (hir direct summary) must equal the model's, and a strict compilation must
# be rejected exactly when the model has a verdict.
#
# The last line is "programs N disagreements D"; the exit status is 1 if D >
# 0. Nothing runs a program (directness is compile time), so no native
# backend is needed.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

set n 60
set seed0 1
set dump 0
while {[lindex $args 0] in {-n -seed -dump}} {
    switch -- [lindex $args 0] {
        -n { set n [lindex $args 1] }
        -seed { set seed0 [lindex $args 1] }
        -dump { set dump [lindex $args 1] }
    }
    set args [lrange $args 2 end]
}

# A private directory (never the working directory: concurrent runs, AGENTS.md).
set scratch [file tempdir direct-modules-fuzz]

proc rnd {n} {
    set ::rng [expr {($::rng * 1103515245 + 12345) % 2147483648}]
    return [expr {($::rng / 65536) % $n}]
}
proc pick {list} {
    return [lindex $list [rnd [llength $list]]]
}
proc chance {percent} {
    return [expr {[rnd 100] < $percent}]
}

set rawCall {abi::x86_64::to_int(linux::abi::x86_64::syscall({rax: abi::x86_64::register64(39)}))}

# One program: {FILES MODEL} where FILES is {NAME TEXT ...} and MODEL is
# {verdicts {KIND UNIT ...} statuses {UNIT STATUS ...}}, UNIT "" for the entry
# program.
proc generate {seed} {
    set ::rng $seed
    set k [expr {1 + [rnd 4]}]
    # Per module: marker, context (name or ""), functions {NAME CONTEXTS BODY
    # EDGES ESCAPES}, imports.
    set modules {}
    set files {}
    set model [dict create]
    for {set i 1} {$i <= $k} {incr i} {
        set m m$i
        set ctx [expr {[chance 60] ? "C$i" : ""}]
        set earlier [lrange [dict keys $modules] 0 end]
        set imports [dict create]
        set fns {}
        set edges {}
        set escapes 0
        set escaped {}
        set nf [expr {1 + [rnd 3]}]
        set text ""
        set decls ""
        if {$ctx ne ""} {
            append decls "context struct $ctx:\n    ok: bool\n\n"
        }
        for {set j 1} {$j <= $nf} {incr j} {
            set fname f$j
            # Context section.
            set contexts {}
            set own [expr {$ctx ne "" && [chance 50]}]
            if {$own} {
                lappend contexts [list own $ctx]
            }
            set foreignOwners [lmap e $earlier {expr {[dict get $modules $e ctx] ne "" ? $e : [continue]}}]
            if {$foreignOwners ne {} && [chance 30]} {
                set fo [pick $foreignOwners]
                dict set imports $fo 1
                lappend contexts [list foreign ${fo}::[dict get $modules $fo ctx]]
            }
            set section ""
            if {$contexts ne {}} {
                set entries {}
                set c 0
                foreach entry $contexts {
                    lappend entries "x[incr c]: [lindex $entry 1]"
                }
                set section "context [join $entries {, }]"
            }
            # Body.
            set lines {}
            set terms {}
            set calls [expr {1 + [rnd 3]}]
            set nestedBlock {}
            for {set q 0} {$q < $calls} {incr q} {
                set kind [pick {raw call alias nested pure pure}]
                if {$kind in {call alias nested} && $earlier eq {}} {
                    set kind [pick {raw pure}]
                }
                switch -- $kind {
                    raw {
                        dict set imports abi::x86_64 1
                        dict set imports linux::abi::x86_64 1
                        lappend terms $::rawCall
                        lappend edges [list $fname linux::abi::x86_64 $own]
                    }
                    pure {
                        lappend terms [expr {1 + [rnd 9]}]
                    }
                    call - alias - nested {
                        set target [pick $earlier]
                        dict set imports $target 1
                        set tfn [lindex [dict get $modules $target fns] 0 0]
                        set callee ${target}::$tfn
                        if {$kind eq "call"} {
                            lappend terms "${callee}()"
                            if {[dict get $modules $target marker]} {
                                lappend edges [list $fname $target $own]
                            }
                        } elseif {$kind eq "alias"} {
                            lappend lines "    g$q = $callee"
                            lappend terms "g${q}()"
                            if {[dict get $modules $target marker]} {
                                lappend edges [list $fname $target $own]
                            }
                        } else {
                            # A nested function: its own requirement decides.
                            set nestedOwn [expr {$ctx ne "" && [chance 50]}]
                            set nsec [expr {$nestedOwn ? "context y$q: $ctx" : ""}]
                            lappend lines "    fn h${q}($nsec) -> int:" "        ${callee}()"
                            lappend terms "h${q}()"
                            if {[dict get $modules $target marker]} {
                                lappend edges [list "$fname/h$q" $target $nestedOwn]
                            }
                        }
                    }
                }
            }
            set body [concat $lines [list "    [join $terms { + }]"]]
            append text "fn ${fname}($section) -> int:\n[join $body \n]\n\n"
            lappend fns [list $fname $contexts]
            if {$earlier ne {} && [chance 15]} {
                # An escape: an earlier module's function as a value (its
                # context-free v, so no context rule is involved).
                set target [pick $earlier]
                dict set imports $target 1
                append text "fn e${j}():\n    \[${target}::v\]\n\n"
                lappend escaped $target
            }
        }
        append text "fn v() -> int:\n    0\n"
        # The marker: mostly the one the module needs (so most programs are
        # accepted), else the wrong one.
        set needs 0
        foreach edge $edges {
            if {![lindex $edge 2]} { set needs 1 }
        }
        set marker [expr {[chance 75] ? $needs : !$needs}]
        foreach target $escaped {
            if {[dict get $modules $target marker] && !$marker} {
                incr escapes
            }
        }
        dict set modules $m [dict create marker $marker ctx $ctx fns $fns edges $edges escapes $escapes]
        set header [expr {$marker ? "direct module\n\n" : ""}]
        foreach imp [lsort [dict keys $imports]] {
            append header "import $imp\n"
        }
        lappend files $m.bot "$header\n$decls$text"
    }
    # The entry program.
    set ctx [expr {[chance 50] ? "Main" : ""}]
    set wrapped [expr {$ctx ne "" && [chance 60]}]
    set needs 0
    foreach m [dict keys $modules] {
        if {[dict get $modules $m marker] && !$wrapped} { set needs 1 }
    }
    set marker [expr {[chance 75] ? $needs : !$needs}]
    set header [expr {$marker ? "direct module\n\n" : ""}]
    foreach m [dict keys $modules] {
        append header "import $m\n"
    }
    set text "$header\n"
    if {$ctx ne ""} {
        append text "context struct Main:\n    ok: bool\n\n"
    }
    set terms {}
    set edges {}
    foreach m [dict keys $modules] {
        set f [lindex [dict get $modules $m fns] 0 0]
        lappend terms "${m}::${f}()"
        if {[dict get $modules $m marker]} {
            lappend edges [list [expr {$wrapped ? "run" : "<top>"}] $m $wrapped]
        }
    }
    if {$wrapped} {
        append text "fn run(context c: Main) -> int:\n    [join $terms { + }]\n\n"
    }
    foreach m [dict keys $modules] {
        set c [dict get $modules $m ctx]
        if {$c ne ""} {
            append text "with context ${m}::$c {ok: true}\n"
        }
    }
    if {$ctx ne ""} {
        append text "with context Main {ok: true}\n"
    }
    append text "[expr {$wrapped ? "run()" : [join $terms { + }]}]\n"
    lappend files main.bot $text
    dict set modules "" [dict create marker $marker ctx $ctx fns {} edges $edges escapes 0]
    # The model.
    set verdicts {}
    set statuses {}
    dict for {m info} $modules {
        set undischarged 0
        foreach edge [dict get $info edges] {
            if {![lindex $edge 2]} {
                set undischarged 1
            }
        }
        set mk [dict get $info marker]
        if {$undischarged && !$mk} {
            lappend verdicts [list DIRECT $m]
            set status unacknowledged
        } elseif {$undischarged} {
            set status direct
        } elseif {$mk} {
            lappend verdicts [list STALE-DIRECT-MODULE $m]
            set status stale
        } elseif {[dict get $info edges] ne {}} {
            set status contextualized
        } else {
            set status ordinary
        }
        if {[dict get $info escapes] > 0} {
            lappend verdicts [list DIRECT-CALLABLE-VALUE $m]
        }
        lappend statuses $m $status
    }
    return [list $files [dict create verdicts [lsort -unique $verdicts] statuses $statuses]]
}

# What the compiler says of the application FILES (written into DIR):
# {verdicts {KIND UNIT ...} statuses {UNIT STATUS ...} strict accepted|rejected}.
proc observe {dir files} {
    foreach {name text} $files {
        set channel [open [file join $dir $name] w]
        fconfigure $channel -encoding utf-8 -translation lf
        puts -nonewline $channel $text
        close $channel
    }
    set main [file join $dir main.bot]
    set hir [surface::readProgramFile $main -strict 0 -warnings off -cache ""]
    set unitOf [dict create]
    dict for {f entry} [dict get $hir files] {
        set path [dict get $entry path]
        if {[file dirname $path] eq $dir} {
            set tail [file rootname [file tail $path]]
            dict set unitOf $f [expr {$tail eq "main" ? "" : $tail}]
        }
    }
    set verdicts {}
    foreach d [hir::diagnostics $hir] {
        if {[dict get $d kind] ni {DIRECT STALE-DIRECT-MODULE DIRECT-CALLABLE-VALUE}} {
            lappend verdicts [list OTHER [dict get $d kind] [dict get $d message]]
            continue
        }
        set origin [expr {[dict exists $d origin] ? [dict get $d origin] : [hir::get $hir [dict get $d expr] origin]}]
        set f [dict get $origin file]
        lappend verdicts [list [dict get $d kind] [expr {[dict exists $unitOf $f] ? [dict get $unitOf $f] : "?$f"}]]
    }
    set statuses {}
    dict for {unit u} [dict get $hir direct units] {
        if {$unit eq "" || [string match m* $unit]} {
            lappend statuses $unit [dict get $u status]
        }
    }
    set strict [expr {[catch {surface::readProgramFile $main -warnings off -cache ""}] ? "rejected" : "accepted"}]
    return [dict create verdicts [lsort -unique $verdicts] statuses $statuses strict $strict]
}

set disagreements 0
set counts [dict create accepted 0 rejected 0]
for {set i 0} {$i < $n} {incr i} {
    set seed [expr {$seed0 * 100003 + $i}]
    lassign [generate $seed] files model
    set dir [file join $scratch p$i]
    file mkdir $dir
    if {[catch {observe $dir $files} seen]} {
        set seen [dict create error $seen]
    }
    set expectedStrict [expr {[dict get $model verdicts] eq {} ? "accepted" : "rejected"}]
    set ok [expr {![dict exists $seen error]
        && [dict get $seen verdicts] eq [dict get $model verdicts]
        && [lsort -stride 2 [dict get $seen statuses]] eq [lsort -stride 2 [dict get $model statuses]]
        && [dict get $seen strict] eq $expectedStrict}]
    if {[dict exists $seen strict]} {
        dict incr counts [dict get $seen strict]
    }
    if {!$ok || $dump} {
        if {!$ok} {
            incr disagreements
            puts "DISAGREE seed $seed"
        }
        foreach {name text} $files {
            puts "--- $name\n$text"
        }
        puts "model:    $model"
        puts "compiler: $seen"
    }
    file delete -force $dir
}
file delete -force $scratch
puts "programs $n accepted [dict get $counts accepted] rejected [dict get $counts rejected] disagreements $disagreements"
exit [expr {$disagreements > 0}]
