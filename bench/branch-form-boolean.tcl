# branch-form-boolean.tcl -- the benchmark of BRANCH-FORM-BOOLEAN-LOWERING.md:
# a domain admission written as nested ifs, as an `and` condition, an `or`
# condition, a `not` of one, a converter call, and (for comparison) an `and`
# used as a value, on every backend, with compile cost separated from run
# cost.
#
#   tclsh9.0 bench/branch-form-boolean.tcl ?-root DIR? ?-n N? ?-interp-n N?
#       ?-native-n N? ?-reps R? ?-forms LIST? ?-programs FILES?
#       ?-workload calls|tight? ?-backends LIST?
#
# -root runs the compiler of another checkout (its own compiler, native and
# lib; its native/target must be built): the same script measures a tree
# before and after a change. The workload is ELIMINATE-AUTOMATIC-TYPE-
# PREDICATES.md's: `ys = loop i from 0 to N: step(mod(i, 20) - 5)`, where
# step admits v into `Small = Int in 0..9` and returns use_small(v), or 0.
#
# Per form it prints the front end (surface::compile), then per backend:
#   interp              core IR lowering, and the best of R runs (-interp-n)
#   compile             core::compiler::compileHir, and the best of R runs of
#                       the unit (-n)
#   cranelift(-generic) NIR lowering (native::lower::program, Tcl), Cranelift
#                       codegen, and the best of R runs in one process
#                       (-native-n; native::measure)
# times in milliseconds, and the shape of step's NIR (lines, `br`, Bool
# constants, moves of one) and machine code size (native::codeSize).
#
# -workload tight measures the condition alone: a self-tail-recursive
# count(i, n, acc) (a loop in both compilers) testing v = mod(i, 20) - 5
# each way and counting the admitted values, so no call is made per
# iteration and the condition is most of its cost.
#
# -programs FILES measures whole program files instead (a real workload,
# bench/uri-steady.bot say): the front end, the Tcl compiler's compile and
# best run, and natively the NIR lowering, codegen and best run, with the
# shape of the whole program's NIR.

set options [dict create -root "" -n 20000 -interp-n 2000 -native-n 3000000 -reps 5 \
    -forms {nested and or not converter value} -programs "" -workload calls \
    -backends {interp compile cranelift-generic cranelift}]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set root [dict get $options -root]
if {$root eq ""} {
    set root [file dirname [file dirname [file normalize [info script]]]]
}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

set prelude {import list

type Small = Int in 0..9
error OutOfRange

fn small(x: int) -> Small errors OutOfRange:
    if x < 0 or x > 9:
        fail OutOfRange
    x

fn use_small(s: Small) -> int:
    s + 1
}

set steps [dict create \
    nested {fn step(v: int) -> int:
    if 0 <= v:
        if v <= 9:
            return use_small(v)
    0
} \
    and {fn step(v: int) -> int:
    if 0 <= v and v <= 9:
        use_small(v)
    else:
        0
} \
    or {fn step(v: int) -> int:
    if v < 0 or v > 9:
        0
    else:
        use_small(v)
} \
    not {fn step(v: int) -> int:
    if not (v < 0 or v > 9):
        use_small(v)
    else:
        0
} \
    converter {fn step(v: int) -> int:
    s = small(v):
        on OutOfRange:
            return 0
    use_small(s)
} \
    value {fn step(v: int) -> int:
    ok = 0 <= v and v <= 9
    if ok:
        v + 1
    else:
        0
}]

set counts [dict create \
    nested {    if 0 <= v:
        if v <= 9:
            return count(i + 1, n, acc + 1)
    count(i + 1, n, acc)} \
    and {    if 0 <= v and v <= 9:
        return count(i + 1, n, acc + 1)
    count(i + 1, n, acc)} \
    or {    if v < 0 or v > 9:
        return count(i + 1, n, acc)
    count(i + 1, n, acc + 1)} \
    not {    if not (v < 0 or v > 9):
        return count(i + 1, n, acc + 1)
    count(i + 1, n, acc)} \
    value {    ok = 0 <= v and v <= 9
    if ok:
        return count(i + 1, n, acc + 1)
    count(i + 1, n, acc)}]

proc program {step n} {
    global prelude options counts form
    if {[dict get $options -workload] eq "tight"} {
        return "$prelude\nfn count(i: int, n: int, acc: int) -> int:\n    if i >= n:\n        return acc\n    v = mod(i, 20) - 5\n[dict get $counts $form]\n\ncount(0, $n, 0)\n"
    }
    return "$prelude\n$step\nys = loop i from 0 to $n:\n    step(mod(i, 20) - 5)\nlist::length(ys)\n"
}

proc ms {us} {
    return [format %.1f [expr {$us / 1000.0}]]
}

# The best of REPS timings of SCRIPT (run in the caller), microseconds.
proc best {reps script} {
    set best ""
    for {set i 0} {$i < $reps} {incr i} {
        set t [lindex [uplevel 1 [list time $script]] 0]
        if {$best eq "" || $t < $best} {
            set best $t
        }
    }
    return $best
}

# {LINES BR BOOLS BOOLMOVES} of NIR function NAME in NIR text (* for every
# function).
proc nirShape {nir name} {
    set lines {}
    set inside 0
    foreach line [split $nir \n] {
        if {[string match "func *" $line]} {
            set inside [expr {$name eq "*" || [string match "func * \"$name\" *" $line]}]
            continue
        }
        if {$line eq "end"} {
            set inside 0
            continue
        }
        if {$inside} {
            lappend lines [regsub -all { ?@e[0-9]+} [string trim $line] ""]
        }
    }
    set bools {}
    foreach line $lines {
        if {[regexp {^(%[0-9]+) = bool } $line -> r]} {
            lappend bools $r
        }
    }
    set moves 0
    foreach line $lines {
        if {[regexp {^%[0-9]+ = move (%[0-9]+)$} $line -> r] && $r in $bools} {
            incr moves
        }
    }
    return [list [llength $lines] [llength [lsearch -all -regexp $lines {^br }]] [llength $bools] $moves]
}

set reps [dict get $options -reps]
if {[dict get $options -workload] eq "tight"} {
    # The interpreter runs count's self tail calls as nested calls.
    interp recursionlimit {} 1000000
}
if {[dict get $options -programs] ne ""} {
    puts "root $root; reps $reps"
    foreach path [dict get $options -programs] {
        set front [best $reps {set hir [surface::readProgramFile $path -warnings off]}]
        puts "\n[file tail $path]: front end [ms $front] ms"
        set compile [best $reps {set unit [core::compiler::compileHir $hir]}]
        set run [best $reps {set value [core::compiler::evalUnit $unit]}]
        puts [format "  %-18s compile %5s ms  run %9s ms" compile [ms $compile] [ms $run]]
        foreach {backend specialize} {cranelift-generic 0 cranelift 1} {
            if {[catch {native::measure $hir $reps -specialize $specialize} measured]} {
                puts [format "  %-18s %s" $backend [string range $measured 0 100]]
                continue
            }
            lassign $measured lowerUs codegenUs bestUs
            lassign [nirShape [native::nir $hir -specialize $specialize] *] lines brs bools moves
            lassign [native::codeSize $hir -specialize $specialize] codeBytes
            puts [format "  %-18s nir %6s ms  codegen %5s ms  run %8s ms; NIR %d lines, %d br, %d bool, %d bool moves; code %s bytes" \
                $backend [ms $lowerUs] [ms $codegenUs] [ms $bestUs] $lines $brs $bools $moves $codeBytes]
        }
    }
    exit
}
puts "root $root; reps $reps; n [dict get $options -n] compile, [dict get $options -interp-n] interp, [dict get $options -native-n] native"
foreach form [dict get $options -forms] {
    if {[dict get $options -workload] eq "tight" && ![dict exists $counts $form]} {
        continue
    }
    set step [dict get $steps $form]
    set source [program $step [dict get $options -n]]
    set front [best $reps {set hir [surface::compile $source -warnings off]}]
    puts "\n$form: front end [ms $front] ms"

    set backends [dict get $options -backends]
    if {"interp" in $backends} {
        set isource [program $step [dict get $options -interp-n]]
        set ihir [surface::compile $isource -warnings off]
        set lower [best $reps {set ir [hir::lower $ihir]}]
        set run [best [expr {min($reps, 3)}] {set value [core::evalProgram $ir]}]
        puts [format "  %-18s lower %7s ms  run %9s ms  value %s" interp [ms $lower] [ms $run] [core::value::show $value]]
    }

    if {"compile" in $backends} {
        set compile [best $reps {set unit [core::compiler::compileHir $hir]}]
        set run [best $reps {set value [core::compiler::evalUnit $unit]}]
        # The Tcl bytecode of the compiled function (its instruction count).
        set fname [expr {[dict get $options -workload] eq "tight" ? "count" : "step"}]
        set bytecode ""
        foreach {- temp proc defined use} [regexp -all -inline \
                {set (t[0-9]+) \[core::value::block [^\n]* ::core::compiler::code::(block[0-9]+)\]\n[ \t]*core::env::define \$base (\S+) \$(t[0-9]+)\n} [dict get $unit code]] {
            if {$defined eq $fname && $use eq $temp} {
                set text [tcl::unsupported::disassemble proc ::core::compiler::code::$proc]
                set bytecode "; $fname bytecode [regexp -all -line {^\s+\([0-9]+\) } $text] instructions"
            }
        }
        puts [format "  %-18s compile %5s ms  run %9s ms  value %s%s" compile [ms $compile] [ms $run] [core::value::show $value] $bytecode]
    }

    set nsource [program $step [dict get $options -native-n]]
    set nhir [surface::compile $nsource -warnings off]
    foreach {backend specialize} {cranelift-generic 0 cranelift 1} {
        if {$backend ni $backends} continue
        lassign [native::measure $nhir $reps -specialize $specialize] lowerUs codegenUs bestUs collections value
        set nir [native::nir $nhir -specialize $specialize]
        set shapes {}
        foreach name [expr {[dict get $options -workload] eq "tight" ? {count}
                : $form eq "converter" ? {step small} : {step}}] {
            lassign [nirShape $nir $name] lines brs bools moves
            lappend shapes "$name NIR $lines lines, $brs br, $bools bool, $moves bool moves"
        }
        lassign [native::codeSize $nhir -specialize $specialize] codeBytes
        puts [format "  %-18s nir %6s ms  codegen %5s ms  run %8s ms  value %s; %s; code %s bytes" \
            $backend [ms $lowerUs] [ms $codegenUs] [ms $bestUs] [lindex $value end] [join $shapes {; }] $codeBytes]
    }
}
