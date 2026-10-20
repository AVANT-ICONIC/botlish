# fuzz.tcl -- a small borrow-contract fuzzer of temporary foreign byte
# exposure (C-POINTER-BORROWING.md).
#
#   tclsh9.0 audit/c-pointer-borrowing/tools/fuzz.tcl ?-n N? ?-seed S?
#                                    ?-cases K? ?-gc-stress 0|1? ?-verbose 0|1?
#
# Each program has K cases. A case draws, at random:
#
#   * an owner: a std::abi::bytes::Bytes or a std::abi::bytes::MutableBytes of random
#     bytes -- a closed form (A i^2 + B i + C) mod 256 over a random length
#     biased toward the shapes that matter (0, 1, around 8, 16 and 32, a few
#     hundred), with all-zero, all-0xff and zero-rich coefficient choices --
#     or, rarely, a null raw C pointer with a count of 0;
#   * a fixture operation, from the contract grid of access (read | write |
#     unknown) x escape (proven-noescape | declared-noescape | captures |
#     unknown) the fixture's natives cover;
#   * a pointee: the byte-sized Char, SChar, UChar or Void, or a wider or
#     non-byte one (Short, Int, Long, ULongLong, Ptr[UChar], an opaque
#     struct);
#   * a count (at most the owner's length) and, for a write, a seed.
#
# An independent model in this file (its own copy of the grid's contracts,
# never the registry's; its own admission rule; its own byte arithmetic)
# predicts whether the call is admitted and, if not, which reason the
# refusal names first (retention, an undeclared access, immutability, the
# pointee); and for an admitted one, what the operation reads (the owner's
# first COUNT bytes) or what the write-back value and the caller's own
# value hold afterwards (the fill pattern over the first COUNT bytes, the
# rest unchanged; the caller's value never changed). Every refused case is
# compiled on its own and must fail with FOREIGN-BORROW naming the model's
# reason; the admitted cases form one program that runs on every backend
# (natively also under GC stress with -gc-stress 1) and must print exactly
# the model's values (MutableBytes through the harness's internal reveal,
# never through the fixture).
#
# The last line is "programs N cases C refused R disagreements D"; every
# disagreement is printed with its program.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 20 -seed 1 -cases 8 -gc-stress 0 -verbose 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set ::argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
core::cabi::installBorrowFixture

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }
proc chance {p} { return [expr {rand() < $p}] }
proc between {lo hi} { return [expr {$lo + int(rand() * ($hi - $lo + 1))}] }

set backends {interp compile cranelift-generic cranelift}

# The model's contracts: operation -> {access escape behavior}, written
# independently of core/cabi.tcl's table.
set grid {
    read                {read    declared-noescape read}
    read_proven         {read    proven-noescape   read}
    read_retained       {read    captures          read}
    read_unknown        {read    unknown           read}
    read_unspecified    {unknown unknown           read}
    read_unknown_access {unknown declared-noescape read}
    fill                {write   declared-noescape fill}
    fill_proven         {write   proven-noescape   fill}
    fill_retained       {write   captures          fill}
    fill_unknown        {write   unknown           fill}
}
set bytePointees {std::ffi::c::Char std::ffi::c::SChar std::ffi::c::UChar std::ffi::c::Void}
set widePointees {std::ffi::c::Short std::ffi::c::Int std::ffi::c::Long std::ffi::c::ULongLong {std::ffi::c::Ptr[std::ffi::c::UChar]} Tag}

# The model's admission rule: "" (admitted) or the first reason it refuses
# OWNER (bytes | mutable | raw) at operation OP with pointee POINTEE.
proc modelRefusal {owner op pointee} {
    lassign [dict get $::grid $op] access escape
    if {$owner eq "raw"} {
        return ""
    }
    if {$escape ni {proven-noescape declared-noescape}} {
        return retain
    }
    if {$access eq "unknown"} {
        return access
    }
    if {$access eq "write" && $owner eq "bytes"} {
        return immutable
    }
    if {$pointee ni $::bytePointees} {
        return pointee
    }
    return ""
}

# The phrase of the diagnostic for REASON.
set reasonText {
    retain    {may retain it}
    access    {does not say whether C reads or modifies}
    immutable {lets C modify the bytes}
    pointee   {exposed only as a pointer to a byte-sized C type}
}

proc modelBytes {n a b c} {
    set bytes {}
    for {set i 0} {$i < $n} {incr i} {
        lappend bytes [expr {($a * $i * $i + $b * $i + $c) % 256}]
    }
    return $bytes
}

proc modelFill {bytes count seed} {
    for {set i 0} {$i < $count} {incr i} {
        lset bytes $i [expr {($seed + 37 * $i) % 256}]
    }
    return $bytes
}

proc revealed {bytes} {
    # (Not an expr ternary: it would read "0080..." as a number.)
    set hex ""
    if {$bytes ne {}} {
        set hex [binary encode hex [binary format cu* $bytes]]
    }
    return "std::abi::bytes::MutableBytes {storage: <mutbytes [llength $bytes]: $hex>}"
}

proc drawLength {} {
    switch -- [between 0 6] {
        0 { return [pick {0 1}] }
        1 { return [between 7 9] }
        2 { return [between 15 17] }
        3 { return [between 31 33] }
        4 { return [between 2 64] }
        default { return [between 100 600] }
    }
}

proc drawCoefficients {} {
    switch -- [between 0 5] {
        0 { return {0 0 0} }
        1 { return {0 0 255} }
        2 { return [list 0 [pick {128 64}] 0] }
        default { return [list [between 0 255] [between 0 255] [between 0 255]] }
    }
}

# One case: a dict {name FN-SOURCE CALL-SOURCE refusal REASON expected TEXT}.
proc drawCase {index} {
    # (Mostly a contract that admits exposure, so most cases run.)
    set op [expr {[chance 0.55] ? [pick {read read_proven fill fill_proven}] : [pick [dict keys $::grid]]}]
    lassign [dict get $::grid $op] access escape behavior
    set owner [expr {[chance 0.08] ? "raw" : [pick {bytes mutable}]}]
    set pointee [expr {[chance 0.85] ? [pick $::bytePointees] : [pick $::widePointees]}]
    set n [drawLength]
    lassign [drawCoefficients] a b c
    set bytes [modelBytes $n $a $b $c]
    set count [expr {$owner eq "raw" ? 0 : ($n == 0 ? 0 : [between 0 $n])}]
    set seed [between 0 255]
    set name case$index
    set lines [list "fn ${name}_bytes():" "    loop i from 0 to $n:" \
        "        std::byte::from_int(mod($a * i * i + $b * i + $c, 256))" "" "fn ${name}():"]
    if {$owner eq "raw"} {
        lappend lines "    p = std::ffi::c::null\[$pointee\]()"
        set arg p
    } else {
        lappend lines "    data = std::abi::bytes::from_list(${name}_bytes())"
        if {$owner eq "mutable"} {
            lappend lines "    m = std::abi::bytes::from_bytes(data)"
            set arg m
        } else {
            set arg data
        }
    }
    set imprint [expr {$owner eq "raw" ? "" : "\[$pointee\]"}]
    if {$behavior eq "read"} {
        lappend lines "    ffi_fixture::$op$imprint\($arg, $count)"
        set expected "\[[join [lrange $bytes 0 [expr {$count - 1}]] {, }]\]"
    } elseif {$owner eq "mutable"} {
        lappend lines "    r = ffi_fixture::$op$imprint\($arg, $count, $seed)"
        lappend lines "    \[r.out, m\]"
        set expected "\[[revealed [modelFill $bytes $count $seed]], [revealed $bytes]\]"
    } else {
        lappend lines "    ffi_fixture::$op$imprint\($arg, $count, $seed)"
        set expected unit
    }
    set refusal [modelRefusal $owner $op $pointee]
    if {$owner ne "raw" && $refusal eq "" && $behavior eq "fill" && $owner ne "mutable"} {
        error "model: a Bytes write was admitted"
    }
    return [dict create name $name source "[join $lines \n]\n" refusal $refusal expected $expected \
        summary "$owner $op $pointee n=$n count=$count"]
}

set prelude "import std::abi\nimport std::abi::bytes\nimport std::ffi::c\nimport std::byte\nimport ffi_fixture\n\nopaque struct Tag:\n    t: unit\n\n"

set programs 0
set cases 0
set refused 0
set disagreements 0
for {set p 0} {$p < [dict get $options -n]} {incr p} {
    set seed [expr {[dict get $options -seed] * 1000003 + $p}]
    expr {srand($seed)}
    incr programs
    set admitted {}
    for {set k 0} {$k < [dict get $options -cases]} {incr k} {
        set case [drawCase $k]
        incr cases
        if {[dict get $case refusal] eq ""} {
            lappend admitted $case
            continue
        }
        incr refused
        set source "$prelude[dict get $case source]\n[dict get $case name]()\n"
        if {![catch {surface::compile $source -warnings off} message copts]} {
            incr disagreements
            puts "DISAGREE (seed $seed, [dict get $case summary]): admitted, the model refuses it ([dict get $case refusal])\n$source"
            continue
        }
        set code [dict get $copts -errorcode]
        set phrase [dict get $::reasonText [dict get $case refusal]]
        if {[lindex $code 2] ne "FOREIGN-BORROW" || [string first $phrase $message] < 0} {
            incr disagreements
            puts "DISAGREE (seed $seed, [dict get $case summary]): refused with $code $message, the model expects FOREIGN-BORROW ($phrase)\n$source"
        }
    }
    if {$admitted eq {}} continue
    set source $prelude
    foreach case $admitted {
        append source [dict get $case source] \n
    }
    append source "\[[join [lmap case $admitted {format {%s()} [dict get $case name]}] {, }]\]\n"
    set expected "value {\[[join [lmap case $admitted {dict get $case expected}] {, }]\]}"
    if {[catch {surface::compile $source -warnings off} hir copts]} {
        incr disagreements
        puts "DISAGREE (seed $seed): the admitted cases do not compile: $hir\n$source"
        continue
    }
    set runs [list {*}[lmap b $backends {list $b 0}]]
    if {[dict get $options -gc-stress]} {
        lappend runs cranelift 1 cranelift-generic 1
    }
    foreach {backend stress} [concat {*}$runs] {
        if {$stress} {
            set ::env(BOTLISH_NATIVE_GC_STRESS) 1
        }
        set outcome [lrange [outcomeUnderHir $backend $hir] 0 end-1]
        if {$stress} {
            unset ::env(BOTLISH_NATIVE_GC_STRESS)
        }
        if {$outcome ne $expected} {
            incr disagreements
            puts "DISAGREE (seed $seed, $backend[expr {$stress ? " under GC stress" : ""}]):\n  got      $outcome\n  expected $expected\n$source"
        }
    }
    if {[dict get $options -verbose]} {
        puts "seed $seed: [llength $admitted] admitted case(s) agree"
    }
}
puts "programs $programs cases $cases refused $refused disagreements $disagreements"
exit [expr {$disagreements > 0}]
