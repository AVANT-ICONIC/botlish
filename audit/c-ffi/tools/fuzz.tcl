# fuzz.tcl -- a C ABI fuzzer of `extern c fn` (C-FFI.md, "Fuzzing").
#
#   tclsh9.0 audit/c-ffi/tools/fuzz.tcl ?-n N? ?-seed S? ?-functions K?
#                                       ?-gc-stress 0|1? ?-keep 0|1?
#                                       ?-verbose 0|1?
#
# Each of N programs is a fresh application: a C library of K generated C
# functions, compiled with the host C compiler into a static archive, a
# Botlish binding module `fz` declaring them, and an entry program calling
# each once. A function draws, at random:
#
#   * 0 to 14 parameters -- past the six (x86-64 SysV) or eight (AAPCS64)
#     integer argument registers, so the later ones are on the stack -- each
#     a C integer scalar (all eleven, plain char at the target's signedness)
#     or a C _Bool (ffi::c::Bool: a Botlish bool),
#     a raw `unsigned char *` (null, or an address inside the library's own
#     cells), a read byte pointer (an abi::bytes::Bytes or a MutableBytes,
#     exposed) or a write byte pointer (a MutableBytes, C writing a private
#     copy), each pointer `noescape` or `proven noescape`;
#   * a result: a C integer scalar or _Bool computed from one argument (in
#     C's own unsigned arithmetic, converted to the result type: a _Bool is
#     1 for any nonzero value), void, an
#     independent pointer into the cells (or NULL), or a pointer declared an
#     alias of one of its raw or write pointer parameters (which it returns);
#   * with or without a `named` link symbol.
#
# Every argument value is drawn toward the type's bounds (min, min + 1, -1,
# 0, 1, max - 1, max) or uniformly inside its range; byte storage has a
# random length (0 to 40) and content.
#
# C records what it saw of every argument (fz_seen: a scalar as its value
# converted to unsigned long long; a raw pointer as its offset in the cells,
# plus 1, or 0 for NULL; a read pointer as the weighted sum of its bytes; a
# write pointer as the weighted sum of the bytes it found there, before
# writing its pattern), and the program reads it back after the call. An
# independent model in this file -- its own table of the C types' widths and
# signedness, never the registry's -- predicts every observation: the
# result, what C saw of each argument, the write-back bytes and that the
# caller's own byte values are unchanged. The program runs on both native
# backends (under BOTLISH_NATIVE_GC_STRESS=1 with -gc-stress 1) and must
# produce exactly the model's list; on the Tcl backends it must fail with
# NATIVE-ONLY.
#
# The last line is "programs N functions F disagreements D"; every
# disagreement is printed with its application directory, kept unless -keep
# is 0.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 10 -seed 1 -functions 12 -gc-stress 0 -keep 1 -verbose 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set ::argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }
proc chance {p} { return [expr {rand() < $p}] }
proc between {lo hi} { return [expr {$lo + int(rand() * ($hi - $lo + 1))}] }

# The model's C types on Linux's LP64 targets: Botlish name -> {C spelling
# bits signed}. Plain char is signed on x86-64 and unsigned on AArch64.
set machine $::tcl_platform(machine)
set charSigned [expr {$machine in {x86_64 amd64}}]
set scalars [dict create \
    SChar     {{signed char} 8 1} \
    UChar     {{unsigned char} 8 0} \
    Char      [list char 8 $charSigned] \
    Short     {short 16 1} \
    UShort    {{unsigned short} 16 0} \
    Int       {int 32 1} \
    UInt      {{unsigned int} 32 0} \
    Long      {long 64 1} \
    ULong     {{unsigned long} 64 0} \
    LongLong  {{long long} 64 1} \
    ULongLong {{unsigned long long} 64 0} \
    Bool      {_Bool 1 0}]
set cells 64

proc bounds {type} {
    lassign [dict get $::scalars $type] - bits signed
    if {$signed} {
        return [list [expr {-(2 ** ($bits - 1))}] [expr {2 ** ($bits - 1) - 1}]]
    }
    return [list 0 [expr {2 ** $bits - 1}]]
}

# A value of TYPE, biased toward the bounds.
proc scalarValue {type} {
    lassign [bounds $type] lo hi
    if {[chance 0.6]} {
        set v [pick [list $lo [expr {$lo + 1}] -1 0 1 [expr {$hi - 1}] $hi]]
        if {$v < $lo || $v > $hi} { set v 0 }
        return $v
    }
    return [expr {$lo + entier(rand() * ($hi - $lo + 1))}]
}

# The C value of the unsigned 64-bit N converted to TYPE (GCC's modular
# conversion for a signed type; C _Bool's: nonzero is 1).
proc convert {n type} {
    if {$type eq "Bool"} {
        return [expr {$n != 0 ? 1 : 0}]
    }
    lassign [dict get $::scalars $type] - bits signed
    set v [expr {$n % (2 ** $bits)}]
    if {$signed && $v >= 2 ** ($bits - 1)} {
        set v [expr {$v - 2 ** $bits}]
    }
    return $v
}

proc weighted {bytes} {
    set sum 0
    set j 0
    foreach b $bytes {
        set sum [expr {$sum + ($j + 1) * $b}]
        incr j
    }
    return $sum
}

proc randomBytes {} {
    set length [pick [list 0 1 [between 2 8] [between 9 40]]]
    set a [between 0 255]
    set b [between 0 255]
    return [lmap j [lrepeat $length 0] {expr {($a + $b * [incr ::k] + $::k * $::k) % 256}}]
}
set ::k 0

proc pattern {seed length} {
    set out {}
    for {set j 0} {$j < $length} {incr j} {
        lappend out [expr {($seed + 31 * $j) % 256}]
    }
    return $out
}

proc blist {values} { return "\[[join $values {, }]\]" }

# One function I of program P: a dict {params result named symbol}.
# A param is {kind scalar type T} | {kind raw escape E} | {kind in escape E
# owner bytes|mutable} | {kind out escape E}; a result {kind scalar type T
# from J add C} | {kind unit} | {kind independent} | {kind alias of J}.
proc drawFunction {p i} {
    set params {}
    set n [pick [list 0 1 2 3 [between 4 8] [between 9 14]]]
    for {set j 0} {$j < $n} {incr j} {
        set escape [expr {[chance 0.2] ? "proven noescape" : "noescape"}]
        set r [expr {rand()}]
        if {$r < 0.6} {
            lappend params [dict create kind scalar type [pick [dict keys $::scalars]]]
        } elseif {$r < 0.73} {
            lappend params [dict create kind raw escape $escape]
        } elseif {$r < 0.87} {
            lappend params [dict create kind in escape $escape owner [pick {bytes bytes mutable}]]
        } else {
            lappend params [dict create kind out escape $escape]
        }
    }
    set aliasable {}
    set hasOut 0
    set j 0
    foreach param $params {
        if {[dict get $param kind] in {raw out}} { lappend aliasable $j }
        if {[dict get $param kind] eq "out"} { set hasOut 1 }
        incr j
    }
    set r [expr {rand()}]
    if {$r < 0.55} {
        set result [dict create kind scalar type [pick [dict keys $::scalars]] \
            from [expr {$n > 0 && [chance 0.85] ? [between 0 [expr {$n - 1}]] : -1}] add [pick [list 0 1 7 [between 0 1000000]]]]
    } elseif {$r < 0.7} {
        set result [dict create kind unit]
    } elseif {$r < 0.85 && !$hasOut} {
        set result [dict create kind independent cell [expr {[chance 0.2] ? -1 : [between 0 [expr {$::cells - 1}]]}]]
    } elseif {[llength $aliasable] > 0} {
        set of [pick $aliasable]
        # A Ptr result beside a write-back is never drawn: only an alias of a
        # write pointer (unit in its place) has outs.
        if {$hasOut && [dict get [lindex $params $of] kind] ne "out"} {
            set result [dict create kind unit]
        } else {
            set result [dict create kind alias of $of]
        }
    } else {
        set result [dict create kind unit]
    }
    set named [chance 0.7]
    set symbol [expr {$named ? "fz_p${p}_f$i" : "f$i"}]
    return [dict create params $params result $result named $named symbol $symbol]
}

# The C source of FUNCTIONS.
proc cSource {functions} {
    set c "#include <stdbool.h>\n#include <stddef.h>\n#include <stdint.h>\n\n"
    append c "unsigned char fz_cells\[$::cells\];\nunsigned long long fz_seen\[16\];\n"
    append c "unsigned char *fz_cell(int k) { return fz_cells + k; }\n"
    append c "unsigned long long fz_offset(unsigned char *p) { return p ? (unsigned long long)(p - fz_cells) + 1 : 0; }\n"
    append c "unsigned long long fz_seen_at(int i) { return fz_seen\[i\]; }\n\n"
    foreach f $functions {
        set result [dict get $f result]
        set ctype [switch [dict get $result kind] {
            scalar { lindex [dict get $::scalars [dict get $result type]] 0 }
            unit { string cat void }
            default { string cat {unsigned char *} }
        }]
        set formals {}
        set body {}
        set j 0
        foreach param [dict get $f params] {
            switch [dict get $param kind] {
                scalar {
                    lappend formals "[lindex [dict get $::scalars [dict get $param type]] 0] a$j"
                    append body "    fz_seen\[$j\] = (unsigned long long)a$j;\n"
                }
                raw {
                    lappend formals "unsigned char *a$j"
                    append body "    fz_seen\[$j\] = fz_offset(a$j);\n"
                }
                in {
                    lappend formals "const unsigned char *a$j"
                    append body "    { unsigned long long s = 0; for (unsigned long k = 0; k < [dict get $param length]; k++) s += (k + 1) * a$j\[k\]; fz_seen\[$j\] = s; }\n"
                }
                out {
                    lappend formals "unsigned char *a$j"
                    append body "    { unsigned long long s = 0; for (unsigned long k = 0; k < [dict get $param length]; k++) { s += (k + 1) * a$j\[k\]; a$j\[k\] = (unsigned char)([dict get $param seed]u + 31u * k); } fz_seen\[$j\] = s; }\n"
                }
            }
            incr j
        }
        switch [dict get $result kind] {
            scalar {
                set from [dict get $result from]
                set base [expr {$from < 0 ? "0ull" : "fz_seen\[$from\]"}]
                append body "    return ($ctype)($base * 3ull + [dict get $result add]ull);\n"
            }
            independent {
                set cell [dict get $result cell]
                append body [expr {$cell < 0 ? "    return NULL;\n" : "    return fz_cells + $cell;\n"}]
            }
            alias {
                append body "    return a[dict get $result of];\n"
            }
        }
        if {$formals eq ""} { set formals void }
        append c "$ctype [dict get $f symbol]([join $formals {, }]) {\n$body}\n\n"
    }
    return $c
}

# The Botlish binding module of FUNCTIONS.
proc binding {functions} {
    set text "import ffi::c\n\nextern c library \"botlish_cffi_fuzz\"\n\n"
    append text "extern c fn cell named \"fz_cell\"(k: ffi::c::Int) -> ffi::c::Ptr\[ffi::c::UChar\] independent\n"
    append text "extern c fn offset named \"fz_offset\"(p: ffi::c::Ptr\[ffi::c::UChar\] noescape) -> ffi::c::ULongLong\n"
    append text "extern c fn seen named \"fz_seen_at\"(i: ffi::c::Int) -> ffi::c::ULongLong\n"
    set i 0
    foreach f $functions {
        set formals {}
        set j 0
        foreach param [dict get $f params] {
            switch [dict get $param kind] {
                scalar { lappend formals "p$j: ffi::c::[dict get $param type]" }
                raw { lappend formals "p$j: ffi::c::Ptr\[ffi::c::UChar\] [dict get $param escape]" }
                in { lappend formals "p$j: ffi::c::Ptr\[ffi::c::UChar\] read [dict get $param escape]" }
                out { lappend formals "p$j: ffi::c::Ptr\[ffi::c::UChar\] write [dict get $param escape]" }
            }
            incr j
        }
        set result [dict get $f result]
        set rtype [switch [dict get $result kind] {
            scalar { string cat "ffi::c::[dict get $result type]" }
            unit { string cat unit }
            independent { string cat "ffi::c::Ptr\[ffi::c::UChar\] independent" }
            alias { string cat "ffi::c::Ptr\[ffi::c::UChar\] alias p[dict get $result of]" }
        }]
        set name [expr {[dict get $f named] ? "f$i named \"[dict get $f symbol]\"" : "f$i"}]
        append text "extern c fn ${name}([join $formals {, }]) -> $rtype\n"
        incr i
    }
    return $text
}

# The entry program calling FUNCTIONS (with their drawn arguments), and the
# model's value of it.
proc program {functions} {
    set text "import abi\nimport abi::bytes\nimport byte\nimport ffi::c\nimport fz\n\n"
    append text "fn byte_of(n: int) -> byte::Byte:\n    if n >= 0 and n <= 255:\n        return n\n    0\n\n"
    append text "fn bytes_of(values: List\[int\]) -> abi::bytes::Bytes:\n    bytes = loop v in values:\n        byte_of(v)\n    abi::bytes::from_list(bytes)\n\n"
    append text "fn bit(b: bool) -> int:\n    if b:\n        return 1\n    0\n\n"
    set observations {}
    set expected {}
    set i 0
    foreach f $functions {
        set args {}
        set seen {}
        set checks {}
        set model {}
        set j 0
        foreach param [dict get $f params] {
            switch [dict get $param kind] {
                scalar {
                    set v [dict get $param value]
                    if {[dict get $param type] eq "Bool"} {
                        lappend args [expr {$v ? "true" : "false"}]
                    } else {
                        lappend args $v
                    }
                    lappend seen [expr {$v % (2 ** 64)}]
                }
                raw {
                    set cell [dict get $param cell]
                    # An affine pointer an observing parameter takes needs an
                    # owner: a binding.
                    append text "r${i}_$j = [expr {$cell < 0 ? "ffi::c::null\[ffi::c::UChar\]()" : "fz::cell($cell)"}]\n"
                    lappend args r${i}_$j
                    lappend seen [expr {$cell < 0 ? 0 : $cell + 1}]
                }
                in {
                    set bytes [dict get $param bytes]
                    if {[dict get $param owner] eq "bytes"} {
                        append text "in${i}_$j = bytes_of([blist $bytes])\n"
                        lappend checks "bit(in${i}_$j == bytes_of([blist $bytes]))"
                    } else {
                        append text "in${i}_$j = abi::bytes::from_bytes(bytes_of([blist $bytes]))\n"
                        lappend checks "bit(abi::bytes::freeze(in${i}_$j) == bytes_of([blist $bytes]))"
                    }
                    lappend args in${i}_$j
                    lappend seen [weighted $bytes]
                }
                out {
                    set bytes [dict get $param bytes]
                    append text "out${i}_$j = abi::bytes::from_bytes(bytes_of([blist $bytes]))\n"
                    lappend args out${i}_$j
                    lappend seen [weighted $bytes]
                    lappend checks "bit(abi::bytes::freeze(c$i.p$j) == bytes_of([blist [pattern [dict get $param seed] [llength $bytes]]]))"
                    lappend checks "bit(abi::bytes::freeze(out${i}_$j) == bytes_of([blist $bytes]))"
                }
            }
            incr j
        }
        set hasOut 0
        foreach param [dict get $f params] {
            if {[dict get $param kind] eq "out"} { set hasOut 1 }
        }
        append text "c$i = fz::f$i\([join $args {, }])\n"
        set elements [list $i]
        lappend model $i
        set result [dict get $f result]
        switch [dict get $result kind] {
            scalar {
                set value [expr {$hasOut ? "c$i.result" : "c$i"}]
                lappend elements [expr {[dict get $result type] eq "Bool" ? "bit($value)" : $value}]
                set from [dict get $result from]
                set base [expr {$from < 0 ? 0 : [lindex $seen $from]}]
                lappend model [convert [expr {($base * 3 + [dict get $result add]) % (2 ** 64)}] [dict get $result type]]
            }
            independent {
                lappend elements "fz::offset(c$i)"
                set cell [dict get $result cell]
                lappend model [expr {$cell < 0 ? 0 : $cell + 1}]
            }
            alias {
                set of [dict get $result of]
                if {[dict get [lindex [dict get $f params] $of] kind] eq "raw"} {
                    lappend elements "fz::offset(c$i)"
                    lappend model [lindex $seen $of]
                }
            }
        }
        set k 0
        foreach s $seen {
            lappend elements "fz::seen($k)"
            lappend model $s
            incr k
        }
        foreach check $checks {
            lappend elements $check
            lappend model 1
        }
        append text "o$i = [blist $elements]\n"
        lappend observations o$i
        lappend expected [blist $model]
        incr i
    }
    append text "[blist $observations]\n"
    return [list $text [blist $expected]]
}

# Draws the arguments of F's parameters (values, cells, bytes, lengths,
# seeds); the C source needs the lengths and seeds.
proc drawArguments {f} {
    set params {}
    foreach param [dict get $f params] {
        switch [dict get $param kind] {
            scalar { dict set param value [scalarValue [dict get $param type]] }
            raw { dict set param cell [expr {[chance 0.25] ? -1 : [between 0 [expr {$::cells - 1}]]}] }
            in - out {
                set bytes [randomBytes]
                dict set param bytes $bytes
                dict set param length [llength $bytes]
                dict set param seed [between 0 255]
            }
        }
        lappend params $param
    }
    dict set f params $params
    return $f
}

proc writeFile {path text} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
}

expr {srand([dict get $options -seed])}
set scratch [file tempdir botlish-cffi-fuzz-]
set programs 0
set functionCount 0
set disagreements 0
set kept {}
for {set p 0} {$p < [dict get $options -n]} {incr p} {
    set functions {}
    for {set i 0} {$i < [dict get $options -functions]} {incr i} {
        lappend functions [drawArguments [drawFunction $p $i]]
    }
    set dir [file join $scratch p$p]
    file mkdir $dir
    writeFile [file join $dir fz.c] [cSource $functions]
    writeFile [file join $dir fz.bot] [binding $functions]
    lassign [program $functions] main expected
    writeFile [file join $dir main.bot] $main
    set problem ""
    if {[catch {
        exec cc -c -O2 -fPIC [file join $dir fz.c] -o [file join $dir fz.o]
        exec ar rcs [file join $dir libbotlish_cffi_fuzz.a] [file join $dir fz.o]
    } message]} {
        set problem "the C library did not build: $message"
    } elseif {[catch {surface::readProgramFile [file join $dir main.bot] -warnings off -cache ""} hir]} {
        set problem "the program did not compile: $hir"
    } else {
        foreach backend {interp compile} {
            lassign [outcomeUnderHir $backend $hir] tag value
            if {$tag ne "error" || [lindex $value end] ne "NATIVE-ONLY"} {
                append problem "$backend: expected NATIVE-ONLY, got $tag $value\n"
            }
        }
        if {[dict get $options -gc-stress]} {
            set ::env(BOTLISH_NATIVE_GC_STRESS) 1
        }
        native::withLinkDirs [list $dir] {
            foreach backend {cranelift cranelift-generic} {
                lassign [outcomeUnderHir $backend $hir] tag value message
                if {$tag ne "value" || $value ne $expected} {
                    append problem "$backend: expected $expected\n  got $tag $value $message\n"
                }
            }
        }
        unset -nocomplain ::env(BOTLISH_NATIVE_GC_STRESS)
    }
    incr programs
    incr functionCount [llength $functions]
    if {$problem ne ""} {
        incr disagreements
        lappend kept $dir
        puts "DISAGREEMENT program $p ($dir):\n$problem"
    } elseif {[dict get $options -verbose]} {
        puts "program $p: $expected"
    }
}
if {$kept eq "" || ![dict get $options -keep]} {
    file delete -force $scratch
} else {
    puts "kept: $scratch"
}
puts "programs $programs functions $functionCount disagreements $disagreements"
exit [expr {$disagreements > 0}]
