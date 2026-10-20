#!/usr/bin/env tclsh9.0
# fuzz.tcl -- generated `static compile:` programs against an independent
# model and against the ordinary compiler (STATIC-COMPILE.md).
#
#   tclsh9.0 audit/static-compile/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1?
#                                                ?-backends LIST? ?-gc-stress 0|1?
#                                                ?-sites MIN-MAX? ?-fault-rate PERCENT?
#
# Each program has 3..8 sites (-sites): a function `site_K(x)` whose body is
# one `static compile:` block -- its last statement, or the value of a binding
# it returns -- and a driver `run_K(x)` that calls it under
# handlers for std::compiler::CompilerError and the program's three application
# errors. A block is one fragment of the pool below, written so its value is
# an Int, or a fault:
#
#   valid   arithmetic and bindings, calls, a typed callable (apply), an
#           untyped one (call, a semantic instance), a struct, a handled
#           and a propagated payload error, a validator and its refinement,
#           a coroutine (affine) started and resumed, method sugar, a List
#           read past its end at run time (IndexNotFound), an opaque struct
#           of a private module through its own operations, an `if`/`elif`
#           chain, a collecting loop, a nested accepted block, and a
#           rejected block nested on a branch that never runs
#   fault   one deliberate semantic error and the diagnostic the model
#           predicts, with its location: UNBOUND, TYPE (an argument; a
#           nested function's result), USE-AFTER-MOVE, UNHANDLED-ERROR (a
#           direct call; through the erased-callable contract), KNOWN-ERROR,
#           OPAQUE-CONSTRUCTION, MISSING-IMPORT, UNKNOWN-FIELD, DUPLICATE --
#           and a nested block that is rejected inside an accepted one
#
# The model shares nothing with the compiler: a valid fragment's outcome is
# computed from x in Tcl (a value, or the application error it raises at run
# time); a fault's outcome is the CompilerError the block completes with,
# its code and primary location predicted from where the fragment put the
# offending token. The driver encodes every outcome as one Int:
#
#   VALUE                        the block's value
#   -(CODE*1000000+LINE*1000+COL)  std::compiler::CompilerError (CODE: code_number)
#   -500000000 + C               Oops {code: C}
#   -600000000                   IndexNotFound
#   -700000000                   NotSmall
#
# and the program's value is the List of every driver's outcome, plus (Tcl
# backends) the number of coroutines still alive at the end, which must be 0.
# For every program:
#
#   1. the static program compiles; on every backend of BACKENDS its value is
#      the model's (and natively every coroutine made was released, none
#      swept; with -gc-stress 1 the native run is repeated with a collection
#      at every allocation);
#   2. transparency (item 80): the *plain* program -- every accepted block
#      written as the ordinary block it stands for, `if true:` on the same
#      lines -- gives every valid site the same outcome, on every backend;
#   3. exact diagnostics (item 81): for every fault, the ordinary compiler
#      compiling that block as the ordinary block (-strict 0, every
#      diagnostic) reports first, inside the block, exactly the diagnostic
#      the static program reified: kind, primary location, related
#      locations, message -- and the model's predicted kind and location.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 30 -seed 1 -dump 0 -backends {interp compile cranelift-generic cranelift} \
    -gc-stress 0 -sites 3-8 -fault-rate 40]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "fuzz.tcl: unknown option $option"
    }
    dict set options $option $value
}
set argv {}
source [file join $root tests helpers.tcl]

# A private copy of the library for the opaque-struct module (never the real
# stdlib/), removed at exit.
set ::fuzzLib [file tempdir botlish-sc-fuzz-lib]
foreach entry [glob -directory $::core::libraryDir *] {
    file copy $entry $::fuzzLib
}
set ::core::libraryDir $::fuzzLib
set ch [open [file join $::fuzzLib fz_token.bot] w]
puts -nonewline $ch "opaque struct Token:\n    value: int\n\nfn make(v: int) -> Token:\n    Token {value: v}\n\nfn value(t: Token) -> int:\n    t.value\n"
close $ch

proc LiveCoroutines {} {
    return [core::value::int [llength [info commands {::core::coroutines::co[0-9]*}]]]
}
if {"test_sc_live" ni [core::native::names]} {
    core::registerNative test_sc_live -arity 0 -impl LiveCoroutines
}

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

# ---------------------------------------------------------------------------
# The program

set ::prelude {import std::compiler
import std::coroutine
import std::list
import std::fz_token

error Oops:
    code: int

error Other

error NotSmall

refined type Small = int

struct Point:
    x: int
    y: int

struct Message:
    value: int

struct Event:
    value: int

fn validate_small(v: int) -> unit proves v: Small errors NotSmall:
    if v > 1000:
        fail NotSmall

fn need(s: Small) -> int:
    s

fn inc(x: int) -> int:
    x + 1

fn needs_int(v: int) -> int:
    v

fn apply(f: Fn{args: [int], return: int}, v: int) -> int:
    f(v)

fn call(f, v):
    f(v)

fn may_fail(x: int) -> int errors Oops:
    if x < 0:
        fail Oops {code: x}
    x * 2

fn may_fail_other(x: int) -> int errors Other:
    if x < -100:
        fail Other
    x

fn always_fails() -> int errors Oops:
    fail Oops {code: 7}

fn worker(seed: int, resume Message) -> Event:
    message = yield Event {value: seed}
    return Event {value: message.value}

fn consume(s: Coroutine{args: [Message], return: Event}, n: int) -> int:
    e = s(Message {value: n})
    e.value

}

# The model's diagnostic numbers, and the program's code_number() mapping
# the std::compiler::DiagnosticCode cases the faults produce to them. The case of
# each kind is written here, as stdlib/compiler.bot spells it -- never asked of
# the static implementation's own table (hir::static::codes), so a wrong
# mapping there is a disagreement.
set ::codeCases {UNBOUND Unbound TYPE Type USE-AFTER-MOVE UseAfterMove
    UNHANDLED-ERROR UnhandledError KNOWN-ERROR KnownError
    OPAQUE-CONSTRUCTION OpaqueConstruction MISSING-IMPORT MissingImport
    UNKNOWN-FIELD UnknownField DUPLICATE Duplicate}
set ::codeNumbers {UNBOUND 1 TYPE 2 USE-AFTER-MOVE 3 UNHANDLED-ERROR 4 KNOWN-ERROR 5
    OPAQUE-CONSTRUCTION 6 MISSING-IMPORT 7 UNKNOWN-FIELD 8 DUPLICATE 9}

proc CodeNumberFunction {} {
    set text "fn code_number(c: std::compiler::DiagnosticCode) -> int:\n"
    set first 1
    foreach {kind n} $::codeNumbers {
        set case [dict get $::codeCases $kind]
        append text "    [expr {$first ? "if" : "elif"}] c == std::compiler::DiagnosticCode::$case:\n        $n\n"
        set first 0
    }
    append text "    else:\n        99\n\n"
    return $text
}

# A fragment: {lines LINES model {x -> outcome} fault ""} or, for a fault,
# {lines LINES fault {KIND LINE COLUMN}} (LINE 1-based within the block,
# COLUMN 1-based within the line as written, before the block's indentation).
# Outcomes: {value N} | {oops C} | {index} | {notsmall} | {compiler KIND LINE
# COLUMN} (a nested block's rejection, located within the block).
proc Fragment {k fault} {
    set c [expr {[Rand 9] + 1}]
    if {!$fault} {
        switch -- [Rand 16] {
            0 { return [dict create lines [list "a = x + $c" "a * [expr {$c + 1}]"] \
                    model [list {x c} {list value [expr {($x + $c) * ($c + 1)}]}] c $c] }
            1 { return [dict create lines [list "inc(x) + $c"] model [list {x c} {list value [expr {$x + 1 + $c}]}] c $c] }
            2 { return [dict create lines [list "apply(inc, x)"] model [list {x c} {list value [expr {$x + 1}]}] c $c] }
            3 { return [dict create lines [list "call(inc, x) + $c"] model [list {x c} {list value [expr {$x + 1 + $c}]}] c $c] }
            4 { return [dict create lines [list "p = Point \{x: x, y: $c\}" "p.x + p.y"] \
                    model [list {x c} {list value [expr {$x + $c}]}] c $c] }
            5 { return [dict create lines [list "r = may_fail(x):" "    on Oops \{code\}:" "        code * 10" "r"] \
                    model [list {x c} {expr {$x < 0 ? [list value [expr {$x * 10}]] : [list value [expr {$x * 2}]]}}] c $c] }
            6 { return [dict create lines [list "may_fail(x) + $c"] \
                    model [list {x c} {expr {$x < 0 ? [list oops $x] : [list value [expr {$x * 2 + $c}]]}}] c $c] }
            7 { return [dict create lines [list "validate_small(x)" "need(x) + $c"] \
                    model [list {x c} {expr {$x > 1000 ? {notsmall} : [list value [expr {$x + $c}]]}}] c $c] }
            8 { return [dict create lines [list "coroutine \{step, first\} = worker(x)" "first.value + consume(step, $c)"] \
                    model [list {x c} {list value [expr {$x + $c}]}] c $c affine 1] }
            9 { return [dict create lines [list "x.inc().inc()"] model [list {x c} {list value [expr {$x + 2}]}] c $c] }
            10 { return [dict create lines [list "xs = \[x, $c\]" "std::list::at(xs, x)"] \
                    model [list {x c} {expr {$x == 0 ? {value 0} : ($x == 1 ? [list value $c] : {index})}}] c $c] }
            11 { return [dict create lines [list "std::fz_token::value(std::fz_token::make(x)) + $c"] \
                    model [list {x c} {list value [expr {$x + $c}]}] c $c] }
            12 { return [dict create lines [list "if x > $c:" "    x - $c" "elif x < 0:" "    0 - x" "else:" "    $c"] \
                    model [list {x c} {expr {$x > $c ? [list value [expr {$x - $c}]] : ($x < 0 ? [list value [expr {-$x}]] : [list value $c])}}] c $c] }
            13 { return [dict create lines [list "ys = loop i from 0 to 3:" "    i * x" "std::list::length(ys) + x"] \
                    model [list {x c} {list value [expr {3 + $x}]}] c $c] }
            14 { return [dict create lines [list "static compile:" "    x + $c"] \
                    model [list {x c} {list value [expr {$x + $c}]}] c $c] }
            15 {
                # A rejected block on a branch that never runs, inside this
                # accepted one: the diagnostic is the inner block's (the
                # innermost site holding it), so the outer block runs.
                return [dict create lines [list "if x > 100000:" "    static compile:" "        x + missing_$k" "x + $c"] \
                    model [list {x c} {list value [expr {$x + $c}]}] c $c]
            }
        }
    }
    switch -- [Rand 13] {
        0 { return [dict create lines [list "x + missing_$k"] fault {UNBOUND 1 5}] }
        1 { return [dict create lines [list "needs_int(\"s$k\") + x"] fault {TYPE 1 11}] }
        2 { return [dict create lines [list "coroutine \{step\} = worker(x)" "consume(step, 1)" "consume(step, 2)"] \
                fault {USE-AFTER-MOVE 3 9} affine 1] }
        3 { return [dict create lines [list "may_fail_other(x) + 1"] fault {UNHANDLED-ERROR 1 1}] }
        4 { return [dict create lines [list "call(may_fail_other, x)"] fault {UNHANDLED-ERROR 1 1} erased 1] }
        5 { return [dict create lines [list "always_fails() + x"] fault {KNOWN-ERROR 1 1}] }
        6 { return [dict create lines [list "t = std::fz_token::Token \{value: x\}" "x"] fault {OPAQUE-CONSTRUCTION 1 5}] }
        7 { return [dict create lines [list "std::str::length(\"ab\") + x"] fault {MISSING-IMPORT 1 1}] }
        8 { return [dict create lines [list "p = Point \{x: x, y: 1\}" "p.z"] fault {UNKNOWN-FIELD 2 3}] }
        9 { return [dict create lines [list "a = x" "a = 2" "a"] fault {DUPLICATE 2 1}] }
        10 {
            # A function's result is reported at its literal (the "(" its
            # parameter list opens), as for every function.
            return [dict create lines [list "fn g() -> str:" "    1" "g()"] fault {TYPE 1 5}]
        }
        11 { return [dict create lines [list "y = x * 2" "y + missing_$k"] fault {UNBOUND 2 5}] }
        12 {
            # A rejected block nested in an accepted one: the outer block's
            # value is the inner one's CompilerError (located in the outer
            # block: line 2, column 5 there).
            return [dict create lines [list "static compile:" "    x + missing_$k"] \
                model [list {x c} {list compiler UNBOUND 2 9}] c 0]
        }
    }
}

# {TEXT SITES}: program NUMBER. SITES: per site {lines LINE0 fault x expected}
# (LINE0 the program line of the block's first line).
proc Program {number} {
    lassign [split [dict get $::options -sites] -] lo hi
    set count [expr {$lo + [Rand [expr {$hi - $lo + 1}]]}]
    set rate [dict get $::options -fault-rate]
    set text $::prelude
    append text [CodeNumberFunction]
    set sites {}
    for {set k 1} {$k <= $count} {incr k} {
        set fault [expr {[Rand 100] < $rate}]
        set fragment [Fragment $k $fault]
        set x [Pick {-3 -1 0 1 2 5 9 40 1500}]
        # The block as the function's last statement, or (one in three) as
        # the value of a binding the function then returns.
        set valued [expr {[Rand 3] == 0}]
        append text "fn site_$k\(x: int) errors std::compiler::CompilerError, Oops, IndexNotFound, NotSmall:\n    [expr {$valued ? "v = " : ""}]static compile:\n"
        set line0 [expr {[llength [split $text \n]]}]
        foreach line [dict get $fragment lines] {
            append text "        $line\n"
        }
        if {$valued} {
            append text "    v\n"
        }
        append text "\nfn run_$k\(x: int):\n    r = site_$k\(x):\n"
        append text "        on std::compiler::CompilerError \{code, primary\}:\n"
        append text "            0 - (code_number(code) * 1000000 + primary.line * 1000 + primary.column)\n"
        append text "        on Oops \{code\}:\n            -500000000 + code\n"
        append text "        on IndexNotFound:\n            -600000000\n"
        append text "        on NotSmall:\n            -700000000\n    r\n\n"
        if {[dict exists $fragment fault] && [dict get $fragment fault] ne ""} {
            lassign [dict get $fragment fault] kind l c
            set outcome [list compiler $kind $l [expr {$c + 8}]]
        } else {
            set outcome [apply [dict get $fragment model] $x [dict get $fragment c]]
            if {[lindex $outcome 0] eq "compiler"} {
                lassign $outcome _ kind l c
                set outcome [list compiler $kind $l [expr {$c + 8}]]
            }
        }
        lappend sites [dict create k $k lines [dict get $fragment lines] line0 $line0 x $x \
            fault [expr {[dict exists $fragment fault] ? [dict get $fragment fault] : ""}] \
            outcome $outcome affine [dict exists $fragment affine]]
    }
    append text "\[[join [lmap s $sites {string cat "run_[dict get $s k]([dict get $s x])"}] {, }], test_sc_live()\]\n"
    return [list $text $sites]
}

# The driver's Int for OUTCOME of the site whose block starts at LINE0.
proc Encode {outcome line0} {
    switch -- [lindex $outcome 0] {
        value    { return [lindex $outcome 1] }
        oops     { return [expr {-500000000 + [lindex $outcome 1]}] }
        index    { return -600000000 }
        notsmall { return -700000000 }
        compiler {
            lassign $outcome _ kind l c
            return [expr {-([dict get $::codeNumbers $kind] * 1000000 + ($line0 + $l - 1) * 1000 + $c)}]
        }
    }
    error "unknown outcome $outcome"
}

# The program TEXT with the static block of every site of SITES written as
# the ordinary block it stands for (`if true:`, the same lines).
proc Plain {text sites} {
    set lines [split $text \n]
    foreach s $sites {
        set i [expr {[dict get $s line0] - 2}]
        if {[lindex $lines $i] ni {"    static compile:" "    v = static compile:"}} {
            error "fuzz: site [dict get $s k] header not found"
        }
        lset lines $i [string map {"static compile:" "if true:"} [lindex $lines $i]]
    }
    return [join $lines \n]
}

# {KIND LINE COLUMN RELATED MESSAGE} of diagnostic D of HIR (its location
# its own `origin`, else its expression's: hir/hir.tcl's diagnostics).
proc Diagnostic {hir d} {
    set origin [expr {[dict exists $d origin] ? [dict get $d origin]
        : [dict get $hir exprs [dict get $d expr] origin]}]
    set related [expr {[dict exists $d related] ? [dict get $d related] : {}}]
    return [list [dict get $d kind] [dict get $origin line] [dict get $origin column] \
        [lmap r $related {list [dict get $r line] [dict get $r column]}] [dict get $d message]]
}

# The first diagnostic the ordinary compiler reports inside lines FROM..TO of
# TEXT (-strict 0, every diagnostic), or the loader's.
proc OrdinaryFirst {text from to} {
    try {
        set hir [surface::compile $text -strict 0 -warnings off]
    } trap {SURFACE MODULE} {message opts} {
        regexp {^[^:]*:([0-9]+):([0-9]+): (.*)$} $message -> line column rest
        return [list [lindex [dict get $opts -errorcode] 2] $line $column {} $rest]
    }
    foreach d [hir::diagnostics $hir] {
        set diagnostic [Diagnostic $hir $d]
        if {[lindex $diagnostic 1] >= $from && [lindex $diagnostic 1] <= $to} {
            return $diagnostic
        }
    }
    return ""
}

# ---------------------------------------------------------------------------

proc Run {} {
    global options
    set backends [dict get $options -backends]
    set nativeOk [expr {$::tcl_platform(os) eq "Linux" && $::tcl_platform(machine) in {x86_64 amd64 aarch64}}]
    set stats [dict create programs 0 sites 0 accepted 0 rejected 0 nested 0 differential 0 transparent 0 rounds 0]
    set kinds [dict create]
    set disagreements 0
    for {set p 0} {$p < [dict get $options -n]} {incr p} {
        set number [expr {[dict get $options -seed] + $p}]
        set ::seedState [expr {$number * 7919 + 17}]
        lassign [Program $number] text sites
        if {[dict get $options -dump]} {
            puts "--- program $number\n$text"
        }
        dict incr stats programs
        set problem ""
        set expected [lmap s $sites {Encode [dict get $s outcome] [dict get $s line0]}]
        if {[catch {surface::compile $text -warnings off} hir opts]} {
            set problem "the static program does not compile: [dict get $opts -errorcode] $hir"
        } else {
            dict incr stats rounds [dict get $hir staticRounds]
            # 1. the model, every backend.
            set native [surface::compile [string map {"test_sc_live()" 0} $text] -warnings off]
            foreach b $backends {
                set o [lrange [outcomeUnderHir $b [expr {$b in {interp compile} ? $hir : $native}]] 0 1]
                set want [list value "\[[join [concat $expected 0] {, }]\]"]
                if {$o ne $want} {
                    set problem "$b gives $o, model $want"
                    break
                }
            }
            if {$problem eq "" && $nativeOk && "cranelift" in $backends && [lsearch -exact [lmap s $sites {dict get $s affine}] 1] >= 0} {
                set report [native::allocationReport $native summary]
                if {[dict exists $report coroutines]} {
                    set c [dict get $report coroutines]
                    set made [expr {[dict get $c stacksMapped] + [dict get $c stacksReused]}]
                    if {[dict get $c sweptSuspended] != 0 || [dict get $c released] != $made} {
                        set problem "native coroutines: $c (every one released, none swept, expected)"
                    }
                }
            }
            if {$problem eq "" && [dict get $options -gc-stress] && $nativeOk} {
                set ::env(BOTLISH_NATIVE_GC_STRESS) 1
                try {
                    set o [lrange [outcomeUnderHir cranelift $native] 0 1]
                } finally {
                    unset ::env(BOTLISH_NATIVE_GC_STRESS)
                }
                if {$o ne [list value "\[[join [concat $expected 0] {, }]\]"]} {
                    set problem "cranelift under GC stress gives $o"
                }
            }
            # 2. transparency: the plain program, valid sites.
            set valid [lmap s $sites {expr {[dict get $s fault] eq "" ? $s : [continue]}}]
            if {$problem eq "" && $valid ne {}} {
                set plain [Plain $text $valid]
                if {[catch {surface::compile [string map {"test_sc_live()" 0} $plain] -warnings off} plainHir opts]} {
                    set problem "the plain program does not compile: $plainHir"
                } else {
                    foreach b $backends {
                        set o [lrange [outcomeUnderHir $b $plainHir] 0 1]
                        set got [string trim [lindex $o 1] {[]}]
                        set got [split [string map {", " ,} $got] ,]
                        foreach s $sites value [lrange $got 0 [llength $sites]-1] want $expected {
                            if {[dict get $s fault] eq "" && $value ne $want} {
                                set problem "plain program on $b: site [dict get $s k] gives $value, the static one $want"
                                break
                            }
                        }
                        if {$problem ne ""} break
                    }
                    if {$problem eq ""} {
                        dict incr stats transparent [llength $valid]
                    }
                }
            }
            # 3. exact diagnostics: every fault against the ordinary compiler.
            set reified [dict create]
            dict for {key site} [hir::static::sites $hir] {
                if {[dict get $site outcome] eq "rejected"} {
                    set d [dict get $site diagnostic]
                    dict set reified [dict get $site origin line] [list [dict get $d kind] \
                        [dict get $d origin line] [dict get $d origin column] \
                        [lmap r [dict get $d related] {list [dict get $r line] [dict get $r column]}] \
                        [dict get $d message]]
                }
            }
            foreach s $sites {
                dict incr stats sites
                if {$problem ne ""} break
                if {[dict get $s fault] eq ""} {
                    dict incr stats accepted
                    if {[lindex [dict get $s outcome] 0] eq "compiler"} {
                        dict incr stats nested
                    }
                    continue
                }
                dict incr stats rejected
                lassign [dict get $s fault] kind l c
                dict incr kinds $kind
                set header [expr {[dict get $s line0] - 1}]
                if {![dict exists $reified $header]} {
                    set problem "site [dict get $s k]: no rejection recorded"
                    break
                }
                set got [dict get $reified $header]
                set from [dict get $s line0]
                set to [expr {$from + [llength [dict get $s lines]] - 1}]
                set ordinary [OrdinaryFirst [Plain $text [list $s]] $from $to]
                set model [list $kind [expr {$from + $l - 1}] [expr {$c + 8}]]
                if {$got ne $ordinary} {
                    set problem "site [dict get $s k]: reified $got, ordinary compiler $ordinary"
                } elseif {[lrange $got 0 2] ne $model} {
                    set problem "site [dict get $s k]: reified [lrange $got 0 2], model $model"
                } else {
                    dict incr stats differential
                }
            }
        }
        if {$problem ne ""} {
            incr disagreements
            puts "DISAGREEMENT program $number:\n$problem\n--- program\n$text"
        }
    }
    puts "programs [dict get $stats programs] sites [dict get $stats sites]: accepted [dict get $stats accepted] (nested rejections [dict get $stats nested]) rejected [dict get $stats rejected]"
    puts "faults: [join [lmap {k n} [lsort -stride 2 $kinds] {string cat "$k $n"}] {, }]"
    puts "transparent valid sites [dict get $stats transparent], exact diagnostics [dict get $stats differential], decision builds [dict get $stats rounds]"
    puts "disagreements $disagreements"
    return $disagreements
}

try {
    set status [Run]
} finally {
    file delete -force $::fuzzLib
}
exit [expr {$status ? 1 : 0}]
