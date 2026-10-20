# callback-registry.tcl -- the compile-time report of a callback registry
# beside unrelated erased error-bearing callables
# (VERIFIED-CALLABLE-CONTRACT-BOUNDARY.md, "General callback-registry
# benchmark").
#
#   tclsh9.0 bench/callback-registry.tcl ?-root DIR? ?-runs N? ?-sizes LIST?
#
# A generated application registry: K handlers of one uniform type
# Fn{args: [], return: any, errors: []}, half top-level functions and half
# closures made by one factory around an untyped captured callable, stored in
# a struct each and in a MutableVector of them, and dispatched indirectly --
# by a field call, by a vector element's field call, and through a
# structural parameter. Elsewhere in the program, four error-bearing
# callables pass through untyped helpers (handled there), so the program's
# erased-callable contract is not empty. The dispatch functions declare no
# errors.
#
# For each K: whether the program compiles, how long the front end takes
# (best of RUNS, warnings off), the program's value on the Tcl interpreter,
# and the effective errors stamped on the dispatching calls. -root DIR
# measures another checkout's compiler (the tree before the milestone: the
# registry is rejected there, UNHANDLED-ERROR at the dispatch, for an
# error no handler stored in it can raise).

set here [file dirname [file dirname [file normalize [info script]]]]
set options [dict create -root $here -runs 3 -sizes {10 50 200}]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "callback-registry.tcl: unknown option $option"
    }
    dict set options $option $value
}
set root [dict get $options -root]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 200000

# The registry program of K handlers.
proc registry {k} {
    set text "import std::mutable_vector\n\n"
    foreach e {Disk Net Parse Auth} {
        append text "error $e\n\n"
    }
    append text "fn call(f, x):\n    f(x)\n\n"
    set i 0
    foreach e {Disk Net Parse Auth} {
        append text "fn raise_$e\(x) -> int errors $e:\n    if x == $i:\n        fail $e\n    x\n\n"
        append text "fn guarded_$e\(x: int) -> int:\n    call(raise_$e, x):\n        on $e:\n            -1\n\n"
        incr i
    }
    append text "struct Handler:\n    name: str\n    run: Fn{args: \[\], return: any}\n\n"
    append text "fn make(f, x) -> Handler:\n    fn bound():\n        f(x)\n    Handler {name: \"bound\", run: bound}\n\n"
    append text "fn offset(x) -> int:\n    x + 1000\n\n"
    for {set j 0} {$j < $k} {incr j} {
        if {$j % 2 == 0} {
            append text "fn handler_$j\() -> int:\n    $j\n\n"
        }
    }
    append text "fn no_handlers() -> MutableVector\[Handler\]:\n    std::mutable_vector::from_list(\[\])\n\n"
    append text "fn registered() -> MutableVector\[Handler\]:\n    v = no_handlers()\n"
    for {set j 0} {$j < $k} {incr j} {
        if {$j % 2 == 0} {
            append text "    v.push(Handler {name: \"h$j\", run: handler_$j})\n"
        } else {
            append text "    v.push(make(offset, $j))\n"
        }
    }
    append text "    v\n\n"
    append text "fn dispatch(h: Handler):\n    (h.run)()\n\n"
    append text "fn invoke(f: Fn{args: \[\], return: any}):\n    f()\n\n"
    append text "fn dispatch_all(v: MutableVector\[Handler\]):\n"
    append text "    loop i from 0 to v.length():\n        h = v.at(i):\n            on IndexNotFound:\n                return \[\]\n        (h.run)() + dispatch(h) + invoke(h.run)\n\n"
    append text "\[guarded_Disk(0), guarded_Net(5), guarded_Parse(2), guarded_Auth(9), dispatch_all(registered())\]\n"
    return $text
}

# The effective errors stamped on every call through a structural value in
# the dispatch functions of HIR.
proc dispatchErrors {hir} {
    set result {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call" || [dict get $node target] ne ""} continue
        if {![hir::types::IsFn [hir::typeOf $hir [dict get $node callee]]]} continue
        lappend result [expr {[dict exists $node effectiveErrors] ? [dict get $node effectiveErrors] : {}}]
    }
    return [lsort -unique $result]
}

puts "| K handlers | compiles | front end (best of [dict get $options -runs]) | value (interp) | effective errors at the dispatching calls |"
puts "|---|---|---|---|---|"
foreach k [dict get $options -sizes] {
    set text [registry $k]
    set best ""
    set outcome ""
    for {set r 0} {$r < [dict get $options -runs]} {incr r} {
        set start [clock microseconds]
        if {[catch {surface::compile $text registry.bot -warnings off} hir]} {
            set outcome [list rejected [regsub {^[^:]*:\d+:\d+: } $hir {}]]
            break
        }
        set us [expr {[clock microseconds] - $start}]
        if {$best eq "" || $us < $best} {
            set best $us
        }
    }
    if {$outcome ne ""} {
        puts "| $k | no: [string range [lindex $outcome 1] 0 140] | | | |"
        continue
    }
    set value [core::value::show [core::evalProgram [hir::lower $hir]]]
    set errors [dispatchErrors $hir]
    puts "| $k | yes | [format %.2f [expr {$best / 1e6}]] s | [string range $value 0 60] | [expr {$errors eq {{}} ? "none" : $errors}] |"
}
