# fuzz.tcl -- a model-based fuzzer of the golden test framework's mechanics
# (GOLDEN-TEST-FRAMEWORK.md, "Framework fuzzing").
#
#   tclsh9.0 audit/golden/tools/fuzz.tcl ?-n N? ?-seed S? ?-backends LIST?
#                                         ?-gc-stress 0|1? ?-verbose 0|1?
#
# Each program is a generated suite: 0..12 cases, registered by two or three
# registration functions (one calling another), each case a random helper
# (value, holds, rejects, rejects_at, rejects_any) over a random body -- a
# valid expression (an Int sum, a List, a String) or a deliberate fault
# (an unbound name, a TYPE argument, a KNOWN-ERROR call, a USE-AFTER-MOVE, an
# unknown field) -- with an expectation that matches or deliberately does
# not. An independent model, sharing nothing with lib/test.bot or the
# compiler, predicts the whole report: registration order, every verdict, the
# expected/actual texts (values, codes, line and column of the fault) and the
# summary; the first line of a diagnostic's detail is predicted for the
# faults whose message the model knows (unbound names, unknown fields).
# Every backend must produce exactly the predicted report; the generic
# backend and GC stress (-gc-stress 1, native) too when asked.
#
# Exit status 1 on any disagreement.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $root tests golden run.tcl]

set options [dict create -n 20 -seed 1 -backends {interp compile cranelift} -gc-stress 0 -verbose 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

expr {srand([dict get $options -seed])}
proc pick {list} { lindex $list [expr {int(rand() * [llength $list])}] }
proc chance {p} { expr {rand() < $p} }
proc randint {lo hi} { expr {$lo + int(rand() * ($hi - $lo + 1))} }

# The model's text of an Int (Tcl's own arithmetic is the oracle).
proc modelInt {n} { return $n }
proc modelList {items} { return "\[[join $items {, }]\]" }

# ---------------------------------------------------------------------------
# Bodies: {kind valid|fault, lines, value (valid), code/line/column (fault)}
#
# A body's lines are written at indentation 12 (inside `static compile:`
# inside a nested fn of a registration function); the fault's column is
# relative to that indentation (column 13 is the first character).

proc validBody {} {
    switch -- [pick {sum list text negative}] {
        sum {
            set a [randint 0 99]; set b [randint 0 99]
            return [dict create kind valid lines [list "$a + $b"] value [expr {$a + $b}] shown [expr {$a + $b}]]
        }
        negative {
            set a [randint 1 99]; set b [randint 100 500]
            return [dict create kind valid lines [list "$a - $b"] value [expr {$a - $b}] shown [expr {$a - $b}]]
        }
        list {
            set n [randint 0 3]
            set items {}
            for {set i 0} {$i < $n} {incr i} { lappend items [randint 0 9] }
            set literal [modelList $items]
            return [dict create kind valid lines [list $literal] value $literal shown $literal]
        }
        text {
            set word [pick {alpha beta gamma delta}]
            return [dict create kind valid lines [list "\"$word\""] value "\"$word\"" shown "\"$word\""]
        }
    }
}

proc faultBody {k} {
    switch -- [pick {unbound type known moved field}] {
        unbound {
            return [dict create kind fault lines [list "missing_$k + 1"] code Unbound offset 0 col 13 \
                detail "unbound name \"missing_$k\""]
        }
        type {
            return [dict create kind fault lines [list "need_int(\"s$k\")"] code Type offset 0 col 22 detail ""]
        }
        known {
            return [dict create kind fault lines [list "list::at(\[1, 2\], [randint 2 9])"] code KnownError offset 0 col 13 detail ""]
        }
        moved {
            return [dict create kind fault lines [list "coroutine {step} = finite($k)" "other = step" "step().n + other().n"] \
                code UseAfterMove offset 2 col 13 detail "`step` was used after its coroutine value was moved"]
        }
        field {
            return [dict create kind fault lines [list "{a: $k}.b"] code UnknownField offset 0 col [expr {13 + 6 + [string length $k]}] \
                detail "struct type struct{a: int} has no field \"b\" (known fields: a)"]
        }
    }
}

set codes {Unbound Type KnownError UseAfterMove UnknownField UnhandledError Duplicate}

# One case: {name helper args body} plus the model's predicted lines,
# computed once the body's line is known (predict).
proc genCase {k} {
    set body [expr {[chance 0.5] ? [validBody] : [faultBody $k]}]
    set name "case $k"
    if {[dict get $body kind] eq "valid"} {
        switch -- [pick {value value value-wrong holds rejects rejects_any}] {
            value { return [dict create name $name helper value body $body expected [dict get $body value] match 1] }
            value-wrong {
                set v [dict get $body value]
                set wrong [expr {[string is integer -strict $v] ? $v + 1 : "\[$k, $k\]"}]
                return [dict create name $name helper value body $body expected $wrong match [expr {$wrong eq $v}]]
            }
            holds {
                # A predicate: an Int body is "a number above 50"; others never hold.
                return [dict create name $name helper holds body $body]
            }
            rejects { return [dict create name $name helper rejects body $body code [pick $::codes]] }
            rejects_any { return [dict create name $name helper rejects_any body $body] }
        }
    }
    switch -- [pick {rejects rejects-wrong rejects_at rejects_at-wrong rejects_any value}] {
        rejects { return [dict create name $name helper rejects body $body code [dict get $body code]] }
        rejects-wrong {
            set other [pick [lsearch -all -inline -not -exact $::codes [dict get $body code]]]
            return [dict create name $name helper rejects body $body code $other]
        }
        rejects_at { return [dict create name $name helper rejects_at body $body code [dict get $body code] dcol 0] }
        rejects_at-wrong { return [dict create name $name helper rejects_at body $body code [dict get $body code] dcol [pick {-1 1 2}]] }
        rejects_any { return [dict create name $name helper rejects_any body $body] }
        value { return [dict create name $name helper value body $body expected [randint 0 9]] }
    }
}

# The model: the report lines CASE produces, its body's first line at LINE.
proc predict {case line} {
    set body [dict get $case body]
    set name [dict get $case name]
    set valid [expr {[dict get $body kind] eq "valid"}]
    if {!$valid} {
        set at "line [expr {$line + [dict get $body offset]}], column [dict get $body col]"
        set rejection "compiler diagnostic [dict get $body code] at $at"
        set detail [dict get $body detail]
    }
    set pass [list "PASS $name"]
    switch -- [dict get $case helper] {
        value {
            if {$valid} {
                if {[dict get $case expected] eq [dict get $body value]} { return $pass }
                return [list "FAIL $name" "  expected: [dict get $case expected]" "  actual: [dict get $body shown]"]
            }
            return [concat [list "FAIL $name" "  expected: [dict get $case expected]" "  actual: $rejection"] [list "  detail: $detail"]]
        }
        holds {
            set v [dict get $body value]
            if {$valid && [string is integer -strict $v] && $v > 50} { return $pass }
            if {$valid} {
                return [list "FAIL $name" "  expected: a number above 50" "  actual: [dict get $body shown]"]
            }
            return [list "FAIL $name" "  expected: a number above 50" "  actual: $rejection" "  detail: $detail"]
        }
        rejects {
            if {$valid} {
                return [list "FAIL $name" "  expected: compiler diagnostic [dict get $case code]" "  actual: value [dict get $body shown]"]
            }
            if {[dict get $case code] eq [dict get $body code]} { return $pass }
            return [list "FAIL $name" "  expected: compiler diagnostic [dict get $case code]" "  actual: $rejection" "  detail: $detail"]
        }
        rejects_at {
            set column [expr {[dict get $body col] + [dict get $case dcol]}]
            set wanted "compiler diagnostic [dict get $case code] at line [expr {$line + [dict get $body offset]}], column $column"
            if {[dict get $case dcol] == 0} { return $pass }
            return [list "FAIL $name" "  expected: $wanted" "  actual: $rejection" "  detail: $detail"]
        }
        rejects_any {
            if {!$valid} { return $pass }
            return [list "FAIL $name" "  expected: a compiler diagnostic" "  actual: value [dict get $body shown]"]
        }
    }
}

proc codeRef {code} { return "compiler::DiagnosticCode::$code" }

# A generated suite: {SOURCE PREDICTED-LINES COUNT}.
proc genProgram {} {
    set lines {
        "import compiler"
        "import list"
        "import test"
        ""
        "struct Event:"
        "    n: int"
        ""
        "fn finite(k: int) -> Event:"
        "    yield Event {n: k}"
        "    Event {n: k + 1}"
        ""
        "fn need_int(n: int) -> int:"
        "    n + 1"
        ""
        "fn above_50?(v) -> bool:"
        "    if integer?(v):"
        "        v > 50"
        "    else:"
        "        false"
        ""
    }
    set total [randint 0 12]
    set groups [randint 1 3]
    set k 0
    set registered {}
    set predicted {}
    set calls {}
    for {set g 0} {$g < $groups} {incr g} {
        set n [expr {$g == $groups - 1 ? $total - $k : [randint 0 [expr {$total - $k}]]}]
        lappend lines "fn register_group_${g}():"
        if {$n == 0} {
            lappend lines "    return"
        }
        for {set i 0} {$i < $n} {incr i} {
            set case [genCase $k]
            set body [dict get $case body]
            lappend lines "    fn body_${k}() errors compiler::CompilerError:" "        static compile:"
            set first [expr {[llength $lines] + 1}]
            foreach l [dict get $body lines] { lappend lines "            $l" }
            set name [dict get $case name]
            switch -- [dict get $case helper] {
                value { lappend lines "    test::value(\"$name\", [dict get $case expected], body_$k)" }
                holds { lappend lines "    test::holds(\"$name\", \"a number above 50\", above_50?, body_$k)" }
                rejects { lappend lines "    test::rejects(\"$name\", [codeRef [dict get $case code]], body_$k)" }
                rejects_at {
                    set column [expr {[dict get $body col] + [dict get $case dcol]}]
                    lappend lines "    test::rejects_at(\"$name\", [codeRef [dict get $case code]], [expr {$first + [dict get $body offset]}], $column, body_$k)"
                }
                rejects_any { lappend lines "    test::rejects_any(\"$name\", body_$k)" }
            }
            lappend registered [list $case $first]
            incr k
        }
        lappend lines ""
        lappend calls "register_group_${g}()"
    }
    # A composing registration function: groups in order.
    lappend lines "fn register_all():"
    foreach c $calls { lappend lines "    $c" }
    lappend lines "" "with context test::suite()" "register_all()" "test::report()" ""
    set passed 0
    foreach entry $registered {
        lassign $entry case first
        set p [predict $case $first]
        if {[string match "PASS *" [lindex $p 0]]} { incr passed }
        lappend predicted {*}$p
    }
    lappend predicted "$passed passed, [expr {[llength $registered] - $passed}] failed"
    return [list [join $lines \n] $predicted [llength $registered]]
}

# The observed report, made comparable with the model: a detail's first line
# is compared only when the model predicts one; its continuation lines are
# dropped.
proc normalize {lines predicted} {
    set out {}
    foreach line $lines {
        if {[string match "    *" $line]} continue
        lappend out $line
    }
    set result {}
    foreach line $out p $predicted {
        if {[string match "  detail: *" $line] && $p eq "  detail: "} {
            lappend result "  detail: "
        } else {
            lappend result $line
        }
    }
    return $result
}

set disagreements 0
set totals [dict create programs 0 cases 0 passing 0 failing 0]
set backends [dict get $options -backends]
for {set p 0} {$p < [dict get $options -n]} {incr p} {
    lassign [genProgram] source predicted count
    dict incr totals programs
    dict incr totals cases $count
    dict incr totals passing [llength [lsearch -all $predicted {PASS *}]]
    dict incr totals failing [llength [lsearch -all $predicted {FAIL *}]]
    lassign [golden::compileSource $source fuzz.bot] status hir
    if {$status ne "ok"} {
        incr disagreements
        puts "program $p: COMPILE ERROR $hir\n$source"
        continue
    }
    set runs $backends
    foreach backend $runs {
        if {[dict get $options -gc-stress] && $backend in {cranelift cranelift-generic}} {
            set ::env(BOTLISH_NATIVE_GC_STRESS) 1
        }
        set outcome [golden::run $hir $backend]
        unset -nocomplain ::env(BOTLISH_NATIVE_GC_STRESS)
        if {[lindex $outcome 0] ne "lines"} {
            incr disagreements
            puts "program $p on $backend: ABORTED [lindex $outcome 1]"
            continue
        }
        set observed [normalize [lindex $outcome 1] $predicted]
        if {$observed ne $predicted} {
            incr disagreements
            puts "program $p on $backend: DISAGREES"
            foreach o $observed m $predicted {
                if {$o ne $m} { puts "    observed: $o\n    model:    $m" }
            }
            if {[dict get $options -verbose]} { puts $source }
        }
    }
    if {[dict get $options -verbose]} {
        puts "program $p: $count cases ok"
    }
}
puts "[dict get $totals programs] programs, [dict get $totals cases] cases ([dict get $totals passing] passing, [dict get $totals failing] failing) on [join $backends {, }]: $disagreements disagreements"
exit [expr {$disagreements > 0}]
