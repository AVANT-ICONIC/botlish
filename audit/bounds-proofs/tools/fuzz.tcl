#!/usr/bin/env tclsh9.0
# fuzz.tcl -- soundness of the bounds prover's relational theorems
# (hir/completions.tcl's IndexBounds: ReducedIndex, RelationKey, and the
# field-path size keys of hir/cardinality.tcl's ValueKey), against the
# reference interpreter.
#
#   tclsh9.0 audit/bounds-proofs/tools/fuzz.tcl ?-seed S? ?-count N?
#       ?-backends LIST? ?-gc-stress 0|1? ?-dump DIR? ?-unsound 0|1?
#
# Every program declares one function
#
#   fn f(a, b: MutableArray[int], xs, ys: List[int], s, w: str,
#        t, u: T, o: O, h: int)
#
# (T {s, r: MutableArray[int]}, O {inner: T}, V {v: MutableVector[int]})
# with no `errors` clause, whose body makes one indexed access -- a read
# (mutable_array::at, list::at, str::char_at) or a write
# (mutable_array::set, then the array frozen and returned) -- of a
# container that is a parameter, a local array derived from one (`c =
# create(capacity(a) + K, 3)`), a field path (t.s) or a nested one
# (o.inner.s), or the List p a loop collects over a vector (a local or a
# local struct's field built from xs), pushed to before the loop and
# pushed, popped or cleared after it (a snapshot's size is its own loop's),
# at an index made sound by one theorem:
#
#   mod       mod(X, SIZE): inline, method syntax, a local of the size, a
#             local of the index, or the size spelled as an equal form
#             (`capacity(a) + K` for the derived array);
#   mask      bit_and(X, SIZE - 1), either operand order, after a guard
#             that the size is not 0 (== 0, <= 0 on a local, < 1) -- or with
#             none for a derived array whose size is >= 1 by its form;
#   local     a computed local j = X guarded on both sides (or form, and
#             form, two early returns, an alias of j, or the upper half
#             only for a local whose own Range is >= 0);
#   param     a guard on the parameter h itself (a control: the rule that
#             predates these theorems), and a counted loop over the size.
#
# X is h, h + K, h - K, h * K, K - h or hash(h). A SOUND program must
# compile strictly (the access needs no handler), its NIR must carry the
# access's *proven opcode and no checked one, and it runs on every backend
# of BACKENDS (default interp, cranelift) over a grid of capacities (1, 2,
# 3, 5, 7, 8, 16 -- powers of two and not -- and 0 where a guard admits
# it) and indices (small, negative, around 2^62, 2^63 and 2^70): every
# backend must agree with the interpreter, which checks every access, and
# no run may fail. A program whose index is reduced by an unguarded mod is
# run once more with an empty container: every backend must fail with
# ARITHMETIC (mod by 0), never IndexNotFound and never a native fault.
#
# Each seed also checks the fixed UNSOUND catalogue (-unsound 0 skips it):
# shapes one step from a theorem -- mod by another container's size, by the
# size plus or minus one, a mask without its guard or equal to the size, a
# mask of another container, another field or another struct's field, the
# fields of two call results, a one-sided guard on a local that may be
# negative, a guard against another size, a guard on one local and a read
# of another, a guard inside a loop that may run zero times with the read
# after it, a write guarded by another field, and a List collected over a
# vector read at an index proven against a later loop over the same vector
# (a counted loop, mod, a mask, a guard; a local or a field path) with a
# push, pop or clear between the two loops. Each must be rejected
# strictly (UNHANDLED-ERROR), and each names a witness input at which the
# same program, declaring the error and handling it, does fail with
# IndexNotFound on the interpreter: the rejection is necessary, not only
# conservative. A lockstep loop over a vector and a List collected over it
# before a push must be LOCKSTEP-UNPROVEN, its witness showing the two
# counts differ. Four CONSERVATIVE shapes (the index written twice inline,
# a guard in a loop that runs once with the read after it, the field of
# one call result written twice, two loops over one vector with nothing
# between them) are safe but outside every theorem: they must stay
# rejected, which pins the theorems' scope.
#
# The fuzzer reads the compiler of the checkout it is in (the mutation
# harness runs it from a private copy). Exit status 1 on any failure.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $root core core.tcl]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 100000

set options [dict create -seed 1 -count 24 -backends {interp cranelift} -gc-stress 0 -dump "" -unsound 1]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set backends [split [string map {" " ,} [dict get $options -backends]] ,]
set backends [lsearch -all -inline -not -exact $backends ""]
if {[lindex $backends 0] ne "interp"} { set backends [linsert [lsearch -all -inline -not -exact $backends interp] 0 interp] }
if {[dict get $options -gc-stress]} { set ::env(BOTLISH_NATIVE_GC_STRESS) 1 }
expr {srand([dict get $options -seed])}

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }
proc chance {p} { return [expr {rand() < $p}] }

set work [file tempdir botlish-bounds-fuzz]
set ::failures 0
proc fail {what} {
    incr ::failures
    puts "FAIL $what"
    flush stdout
}

# ---------------------------------------------------------------------------
# Containers. Each kind gives the container expression, another container
# of its family (array, list, str), the spellings of its size, whether the
# size is >= 1 by its form, and a prelude.

proc kindInfo {kind} {
    set K [pick {0 1 2}]
    switch -- $kind {
        array {
            return [dict create c a other b prelude "" family array nonzero 0 \
                sizes {"mutable_array::capacity(%s)" "%s.capacity()"}]
        }
        list {
            return [dict create c xs other ys prelude "" family list nonzero 0 \
                sizes {"list::length(%s)"}]
        }
        str {
            return [dict create c s other w prelude "" family str nonzero 0 \
                sizes {"str::length(%s)"}]
        }
        field {
            return [dict create c t.s other t.r prelude "" family array nonzero 0 \
                sizes {"mutable_array::capacity(%s)" "%s.capacity()"}]
        }
        nested {
            return [dict create c o.inner.s other o.inner.r prelude "" family array nonzero 0 \
                sizes {"mutable_array::capacity(%s)"}]
        }
        derived {
            # c's size has two spellings: its own capacity, and the equal
            # form it was allocated with.
            return [dict create c c other b prelude "c = mutable_array::create(mutable_array::capacity(a) + $K, 3)\n    " \
                family array nonzero [expr {$K > 0}] \
                sizes [list "mutable_array::capacity(%s)" "(mutable_array::capacity(a) + $K)"]]
        }
        snapshot {
            # p, the List a loop collects over a vector built from xs (a
            # local, or a local struct's field), the vector changed before
            # and after it: p's size is its own loop's, whatever happens to
            # the vector (hir::cardinality::IterationLength). A push before
            # the loop makes p nonempty at run time (no capacity-0 mod
            # failure), though no form says so (a mask still needs a guard).
            set v [pick {v bx.v}]
            # (vec: a MutableVector[int] even of the empty xs, which a
            # specialization types List[never].)
            set make [expr {$v eq "v" ? "v = vec(xs)" : "bx = V {v: vec(xs)}"}]
            set before [pick [list "" "$v.push(h)\n    " "$v.push(7)\n    $v.push(8)\n    "]]
            set after [pick [list "" "$v.push(h)\n    " "$v.pop():\n        on IndexNotFound:\n            0\n    " "$v.clear()\n    "]]
            return [dict create c p other ys family list nonzero 0 nonempty [expr {$before ne ""}] \
                prelude "$make\n    ${before}p = loop x in $v:\n        x + 1\n    $after" \
                sizes {"list::length(%s)"}]
        }
    }
}

proc sizeOf {info {e ""}} {
    if {$e eq ""} { set e [dict get $info c] }
    set spelling [pick [dict get $info sizes]]
    if {[string first %s $spelling] < 0} { return $spelling }
    return [format $spelling $e]
}

proc readOf {info i} {
    set c [dict get $info c]
    switch -- [dict get $info family] {
        array { return [pick [list "mutable_array::at($c, $i)" "$c.at($i)"]] }
        list { return "list::at($c, $i)" }
        str { return "str::char_at($c, $i)" }
    }
}

proc writeOf {info i} {
    set c [dict get $info c]
    set set [pick [list "mutable_array::set($c, $i, h)" "$c.set($i, h)"]]
    return "$set\n    mutable_array::freeze($c, mutable_array::capacity($c))"
}

proc opOf {info write} {
    if {$write} { return mutarrayset }
    return [dict get {array mutarrayget list listget str strcharat} [dict get $info family]]
}

proc indexSource {} {
    set k [pick {1 2 3 5 7}]
    return [pick [list h "h + $k" "h - $k" "h * $k" "$k - h" "hash(h)"]]
}

# One SOUND body: {body op zero}, zero `arith` when an empty container
# reaches an unguarded mod, else `value`.
proc soundBody {} {
    set kind [pick {array array list str field field nested derived snapshot}]
    set info [kindInfo $kind]
    set prelude [dict get $info prelude]
    set write [expr {[dict get $info family] eq "array" && [chance 0.35]}]
    set x [indexSource]
    set theorem [pick {mod mod mask mask local local param}]
    set access [expr {$write ? "writeOf" : "readOf"}]
    switch -- $theorem {
        mod {
            set zero [expr {[dict get $info nonzero] || ([dict exists $info nonempty] && [dict get $info nonempty]) ? "value" : "arith"}]
            switch -- [pick {inline method sizelocal indexlocal}] {
                inline { return [list "$prelude[$access $info "mod($x, [sizeOf $info])"]" [opOf $info $write] $zero $kind/$theorem] }
                method { return [list "$prelude[$access $info "($x).mod([sizeOf $info])"]" [opOf $info $write] $zero $kind/$theorem] }
                sizelocal { return [list "${prelude}n = [sizeOf $info]\n    [$access $info "mod($x, n)"]" [opOf $info $write] $zero $kind/$theorem] }
                indexlocal { return [list "${prelude}i = mod($x, [sizeOf $info])\n    [$access $info i]" [opOf $info $write] $zero $kind/$theorem] }
            }
        }
        mask {
            set guard [pick {eq le lt none}]
            if {$guard eq "none" && ![dict get $info nonzero]} { set guard eq }
            set m "[sizeOf $info] - 1"
            switch -- $guard {
                eq { set g "if [sizeOf $info] == 0:\n        return -1\n    " }
                lt { set g "if [sizeOf $info] < 1:\n        return -1\n    " }
                le { set g "n = [sizeOf $info]\n    if n <= 0:\n        return -1\n    "; set m "n - 1" }
                none { set g "" }
            }
            set index [expr {[chance 0.5] ? "bit_and($x, $m)" : "bit_and($m, $x)"}]
            return [list "$prelude$g[$access $info $index]" [opOf $info $write] value $kind/$theorem/$guard]
        }
        local {
            set size [sizeOf $info]
            switch -- [pick {or and two alias nonneg}] {
                or { set body "j = $x\n    if j < 0 or j >= $size:\n        return -1\n    [$access $info j]" }
                and {
                    set inner [$access $info j]
                    set body "j = $x\n    if j >= 0 and j < $size:\n        [string map [list "\n    " "\n        "] $inner]\n    else:\n        -1"
                }
                two { set body "j = $x\n    if j < 0:\n        return -1\n    if j >= $size:\n        return -1\n    [$access $info j]" }
                alias { set body "j = $x\n    if j < 0 or j >= $size:\n        return -1\n    k = j\n    [$access $info k]" }
                nonneg { set body "j = mod($x, 9)\n    if j >= $size:\n        return -1\n    [$access $info j]" }
            }
            return [list "$prelude$body" [opOf $info $write] value $kind/$theorem]
        }
        param {
            if {!$write && [chance 0.4]} {
                set read [readOf $info k]
                return [list "${prelude}loop k from 0 to [sizeOf $info]:\n        $read" [opOf $info 0] value $kind/loop]
            }
            return [list "${prelude}if h < 0 or h >= [sizeOf $info]:\n        return -1\n    [$access $info h]" [opOf $info $write] value $kind/$theorem]
        }
    }
}

# ---------------------------------------------------------------------------
# Programs

set header "import list\nimport mutable_array\nimport mutable_vector\nimport str\n\nstruct T:\n    s: MutableArray\[int\]\n    r: MutableArray\[int\]\n\nstruct O:\n    inner: T\n\nstruct V:\n    v: MutableVector\[int\]\n\nfn mk(t: T) -> T:\n    t\n\nfn vec(xs: List\[int\]) -> MutableVector\[int\]:\n    mutable_vector::from_list(xs)\n\n"
set signature "fn f(a: MutableArray\[int\], b: MutableArray\[int\], xs: List\[int\], ys: List\[int\], s: str, w: str, t: T, u: T, o: O, h: int)"
set alphabet [split "aé😀bcdefghijklmnopq" ""]

proc arrayOf {n} {
    if {$n == 0} { return "mutable_array::create(0, 0)" }
    set items {}
    for {set i 0} {$i < $n} {incr i} { lappend items [expr {10 * $i + 1}] }
    return "mutable_array::from_list(\[[join $items {, }]\])"
}
proc listOf {n} {
    set items {}
    for {set i 0} {$i < $n} {incr i} { lappend items [expr {100 + $i}] }
    return "\[[join $items {, }]\]"
}
proc strOf {n} { return "\"[join [lrange $::alphabet 0 [expr {$n - 1}]] {}]\"" }

proc callOf {name capa capb h} {
    set args [list [arrayOf $capa] [arrayOf $capb] [listOf $capa] [listOf $capb] [strOf $capa] [strOf $capb] \
        "T {s: [arrayOf $capa], r: [arrayOf $capb]}" "T {s: [arrayOf $capb], r: [arrayOf $capa]}" \
        "O {inner: T {s: [arrayOf $capa], r: [arrayOf $capb]}}" $h]
    return "${name}([join $args {, }])"
}

proc writeProgram {name text} {
    set path [file join $::work $name.bot]
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
    if {[dict get $::options -dump] ne ""} {
        file mkdir [dict get $::options -dump]
        file copy -force $path [dict get $::options -dump]
    }
    return $path
}

# The first diagnostic kind of a strict compilation of PATH, or "" and the
# HIR in HIRVAR.
proc strict {path hirVar} {
    upvar 1 $hirVar hir
    if {[catch {surface::readProgramFile $path -warnings off} result options]} {
        if {[dict exists $options -diagnostics]} {
            return [lindex [dict get [lindex [dict get $options -diagnostics] 0] errorcode] end]
        }
        return "ERROR [string range $result 0 200]"
    }
    set hir $result
    return ""
}

# The outcome of HIR on BACKEND: {value TEXT} or {error CODE}.
proc outcome {hir backend} {
    try {
        switch -- $backend {
            interp {
                core::useProgramRecursionLimit
                set v [core::evalProgram [hir::lower $hir]]
            }
            compile {
                core::useProgramRecursionLimit
                set v [core::compiler::evalUnit [core::compiler::compileHir $hir]]
            }
            cranelift { set v [native::evalHir $hir] }
            cranelift-generic { set v [native::evalHir $hir -specialize 0] }
            default { error "unknown backend $backend" }
        }
        return [list value [core::formatValue $v]]
    } on error {message options} {
        return [list error [dict get $options -errorcode] [string range $message 0 160]]
    }
}

proc opCount {text op} { return [llength [regexp -all -inline "op $op\[ \n\]" $text]] }

# The `op OP` lines of NIR TEXT a program's indexed access makes: every one
# but a collecting loop's own element read (a loop over a List reads its
# elements with listget, annotated with the loop's expression).
proc accessOpCount {hir text op} {
    set n 0
    foreach line [split $text \n] {
        if {![regexp "op $op\[ \n\]" "$line\n"]} {
            continue
        }
        if {[regexp {@(e\d+)\s*$} $line -> id] && [dict exists $hir exprs $id]
                && [hir::kind $hir $id] in {listloop lockloop}} {
            continue
        }
        incr n
    }
    return $n
}

set capsAll {1 2 3 5 7 8 16}
set hsAll {0 1 2 3 4 7 -1 -2 -8 15 16 12345 -99999 4611686018427387903 -4611686018427387904 9223372036854775808 1180591620717411303424 -1180591620717411303424}

set sound 0
set rejected 0
set witnessed 0
for {set n 1} {$n <= [dict get $options -count]} {incr n} {
    lassign [soundBody] body op zero label
    set caps [lsort -unique -integer [list [pick {3 5 7}] [pick $capsAll] [pick $capsAll]]]
    if {$zero eq "value"} { lappend caps 0 }
    set hs [lsort -unique [list 0 3 -1 [pick $hsAll] [pick $hsAll] [pick $hsAll] [pick $hsAll]]]
    set calls {}
    foreach ca $caps {
        foreach cb [list [pick $caps] [pick $capsAll]] {
            foreach h $hs { lappend calls [callOf f $ca $cb $h] }
        }
    }
    set text "$header$signature:\n    $body\n\n\[[join $calls ",\n "]\]\n"
    set name "s[dict get $options -seed]-$n"
    set path [writeProgram $name $text]
    set kind [strict $path hir]
    if {$kind ne ""} {
        fail "$name ($label): sound program rejected: $kind\n    $body"
        continue
    }
    incr sound
    set nir [native::nir $hir]
    if {[opCount $nir ${op}proven] < 1 || [accessOpCount $hir $nir $op] > 0} {
        fail "$name ($label): the access is not the proven opcode ($op [accessOpCount $hir $nir $op], ${op}proven [opCount $nir ${op}proven])\n    $body"
    }
    set reference ""
    foreach backend $backends {
        set got [outcome $hir $backend]
        if {[lindex $got 0] ne "value"} {
            fail "$name ($label) on $backend: [lrange $got 1 end]\n    $body"
            continue
        }
        if {$backend eq "interp"} {
            set reference $got
        } elseif {$got ne $reference} {
            fail "$name ($label): $backend disagrees with interp\n    $body\n    interp: [string range $reference 0 200]\n    $backend: [string range $got 0 200]"
        }
    }
    if {$zero eq "arith"} {
        # A literal List or String argument of length 0 is an exact fact of
        # the call-specific walk: the read is then KNOWN-ERROR (an empty
        # container's read is never in range), which the -strict 0 build
        # runs anyway.
        set zpath [writeProgram $name-zero "$header$signature:\n    $body\n\n[callOf f 0 [pick $capsAll] [pick $hsAll]]\n"]
        set zkind [strict $zpath zhir]
        if {$zkind ni {"" KNOWN-ERROR}} {
            fail "$name-zero ($label): rejected with $zkind"
        } else {
            set zhir [surface::readProgramFile $zpath -warnings off -strict 0]
            foreach backend $backends {
                set got [outcome $zhir $backend]
                if {[lindex $got 0] ne "error" || [lsearch [lindex $got 1] ARITHMETIC] < 0} {
                    fail "$name-zero ($label) on $backend: expected ARITHMETIC (mod by 0), got $got"
                }
            }
        }
    }
    puts "ok   $name ($label): [llength $calls] calls"
    flush stdout
}

# ---------------------------------------------------------------------------
# The UNSOUND catalogue: NAME BODY WITNESS(capa capb h), and the
# CONSERVATIVE shapes (no witness).

set unsound {
    mod-other        {mutable_array::at(a, mod(h, mutable_array::capacity(b)))} {2 5 4}
    mod-plus-one     {mutable_array::at(a, mod(h, mutable_array::capacity(a) + 1))} {3 3 3}
    mod-minus-one    {mutable_array::at(a, mod(h, mutable_array::capacity(a) - 1))} {0 3 5}
    list-mod-other   {list::at(xs, mod(h, list::length(ys)))} {2 5 4}
    str-mod-plus-one {str::char_at(s, mod(h, str::length(s) + 1))} {3 3 3}
    mask-unguarded   {mutable_array::at(a, bit_and(h, mutable_array::capacity(a) - 1))} {0 3 5}
    mask-size        {if mutable_array::capacity(a) == 0:
        return -1
    mutable_array::at(a, bit_and(h, mutable_array::capacity(a)))} {3 3 3}
    mask-other       {if mutable_array::capacity(b) == 0:
        return -1
    mutable_array::at(a, bit_and(h, mutable_array::capacity(b) - 1))} {2 8 7}
    derived-mod      {c = mutable_array::create(mutable_array::capacity(a) + 1, 3)
    mutable_array::at(c, mod(h, mutable_array::capacity(a) + 2))} {2 2 3}
    derived-mask     {c = mutable_array::create(mutable_array::capacity(a) + 1, 3)
    mutable_array::at(c, bit_and(h, mutable_array::capacity(a) + 1))} {2 2 3}
    field-other      {mutable_array::at(t.s, mod(h, mutable_array::capacity(t.r)))} {2 5 4}
    field-other-struct {mutable_array::at(t.s, mod(h, mutable_array::capacity(u.s)))} {2 5 4}
    nested-other     {mutable_array::at(o.inner.s, mod(h, mutable_array::capacity(o.inner.r)))} {2 5 4}
    field-write-other {if h < 0 or h >= mutable_array::capacity(t.r):
        return -1
    t.s.set(h, 7)
    mutable_array::freeze(t.s, mutable_array::capacity(t.s))} {2 5 3}
    local-one-sided  {j = h + 1
    if j >= mutable_array::capacity(a):
        return -1
    mutable_array::at(a, j)} {3 3 -5}
    local-other      {j = h + 1
    if j < 0 or j >= mutable_array::capacity(b):
        return -1
    mutable_array::at(a, j)} {2 5 3}
    param-one-sided  {if h >= mutable_array::capacity(a):
        return -1
    mutable_array::at(a, h)} {3 3 -1}
    local-another-local {j = h + 1
    k = mod(h + 50, 1000)
    if j < 0 or j >= mutable_array::capacity(a):
        return -1
    mutable_array::at(a, k)} {3 3 0}
    loop-scope       {j = mod(h, 1000)
    loop k from 0 to h - 500:
        if j >= mutable_array::capacity(a):
            return k
    mutable_array::at(a, j)} {3 3 500}
    call-receivers   {mutable_array::at(mk(t).s, mod(h, mutable_array::capacity(mk(u).s)))} {2 5 4}
    vector-counted   {v = mutable_vector::from_list(xs)
    p = loop x in v:
        x
    v.push(h)
    q = loop x in v:
        x
    r = loop k from 0 to list::length(q):
        list::at(p, k)
    list::length(r)} {2 3 1}
    vector-mod       {v = mutable_vector::from_list(xs)
    p = loop x in v:
        x
    v.push(h)
    v.push(h)
    q = loop x in v:
        x
    list::at(p, mod(h, list::length(q)))} {2 3 3}
    vector-mask      {v = mutable_vector::from_list(xs)
    p = loop x in v:
        x
    v.push(h)
    v.push(h)
    q = loop x in v:
        x
    if list::length(q) == 0:
        return -1
    list::at(p, bit_and(h, list::length(q) - 1))} {2 3 3}
    vector-guard     {v = mutable_vector::from_list(xs)
    p = loop x in v:
        x
    v.push(h)
    q = loop x in v:
        x
    if h < 0 or h >= list::length(q):
        return -1
    list::at(p, h)} {2 3 2}
    vector-pop       {v = mutable_vector::from_list(xs)
    p = loop x in v:
        x
    v.pop():
        on IndexNotFound:
            0
    q = loop x in v:
        x
    list::at(q, mod(h, list::length(p)))} {3 3 2}
    vector-clear     {v = mutable_vector::from_list(xs)
    p = loop x in v:
        x
    v.clear()
    q = loop x in v:
        x
    list::at(q, mod(h, list::length(p)))} {2 3 1}
    vector-field     {bx = V {v: mutable_vector::from_list(xs)}
    p = loop x in bx.v:
        x
    bx.v.push(h)
    q = loop x in bx.v:
        x
    list::at(p, mod(h, list::length(q)))} {2 3 2}
}
# Lockstep clauses over a vector and a List an earlier loop collected over
# it, the vector grown between them: LOCKSTEP-UNPROVEN, and the witness
# program (the two clauses' counts) shows they differ there.
set lockstepUnsound {
    vector-lockstep {v = mutable_vector::from_list(xs)
    p = loop x in v:
        x
    v.push(h)
    r = loop a in v and y in p:
        a + y
    list::length(r)} {v = mutable_vector::from_list(xs)
    p = loop x in v:
        x
    v.push(h)
    [mutable_vector::length(v), list::length(p)]} {2 3 1}
    field-lockstep {bx = V {v: mutable_vector::from_list(xs)}
    p = loop x in bx.v:
        x
    bx.v.push(h)
    r = loop a in bx.v and y in p:
        a + y
    list::length(r)} {bx = V {v: mutable_vector::from_list(xs)}
    p = loop x in bx.v:
        x
    bx.v.push(h)
    [mutable_vector::length(bx.v), list::length(p)]} {2 3 1}
}
set conservative {
    inline-twice     {if h + 1 < 0 or h + 1 >= mutable_array::capacity(a):
        return -1
    mutable_array::at(a, h + 1)}
    loop-once        {j = h + 1
    loop k from 0 to 1:
        if j < 0 or j >= mutable_array::capacity(a):
            return k
    mutable_array::at(a, j)}
    call-twice       {mutable_array::at(mk(t).s, mod(h, mutable_array::capacity(mk(t).s)))}
    vector-twice     {v = mutable_vector::from_list(xs)
    p = loop x in v:
        x
    q = loop x in v:
        x
    list::at(p, mod(h, list::length(q)))}
}

if {[dict get $options -unsound]} {
    foreach {name body witness} $unsound {
        set path [writeProgram u-$name "$header$signature:\n    $body\n\n[callOf f 2 3 1]\n"]
        set kind [strict $path hir]
        if {$kind ne "UNHANDLED-ERROR"} {
            fail "unsound $name: expected UNHANDLED-ERROR, got [expr {$kind eq "" ? "accepted" : $kind}]"
            continue
        }
        incr rejected
        # The witness: the same body, the error declared and handled.
        lassign $witness ca cb h
        set wtext "$header$signature errors IndexNotFound:\n    $body\n\n[callOf f $ca $cb $h]:\n    on IndexNotFound:\n        -424242\n"
        set wpath [writeProgram w-$name $wtext]
        if {[catch {surface::readProgramFile $wpath -warnings off -strict 0} whir]} {
            fail "unsound $name: the witness program does not compile: [string range $whir 0 200]"
            continue
        }
        set got [outcome $whir interp]
        if {$got ne {value -424242}} {
            fail "unsound $name: the witness ($ca $cb $h) does not fail with IndexNotFound: $got"
            continue
        }
        incr witnessed
        puts "ok   unsound $name: rejected; witness capacities $ca/$cb, h = $h fails"
    }
    foreach {name body} $conservative {
        set path [writeProgram c-$name "$header$signature:\n    $body\n\n[callOf f 2 3 1]\n"]
        set kind [strict $path hir]
        if {$kind ne "UNHANDLED-ERROR"} {
            fail "conservative $name: expected UNHANDLED-ERROR, got [expr {$kind eq "" ? "accepted" : $kind}]"
            continue
        }
        incr rejected
        puts "ok   conservative $name: rejected"
    }
    foreach {name body counts witness} $lockstepUnsound {
        set path [writeProgram l-$name "$header$signature:\n    $body\n\n[callOf f 2 3 1]\n"]
        set kind [strict $path hir]
        if {$kind ne "LOCKSTEP-UNPROVEN"} {
            fail "lockstep $name: expected LOCKSTEP-UNPROVEN, got [expr {$kind eq "" ? "accepted" : $kind}]"
            continue
        }
        incr rejected
        lassign $witness ca cb h
        set wpath [writeProgram lw-$name "$header$signature:\n    $counts\n\n[callOf f $ca $cb $h]\n"]
        if {[catch {surface::readProgramFile $wpath -warnings off} whir]} {
            fail "lockstep $name: the witness program does not compile: [string range $whir 0 200]"
            continue
        }
        set got [outcome $whir interp]
        set numbers [regexp -all -inline {\d+} [lindex $got 1]]
        if {[lindex $got 0] ne "value" || [llength $numbers] != 2 || [llength [lsort -unique -integer $numbers]] != 2} {
            fail "lockstep $name: the witness ($ca $cb $h) does not give two different counts: $got"
            continue
        }
        incr witnessed
        puts "ok   lockstep $name: rejected; witness capacities $ca/$cb, h = $h counts [lindex $got 1]"
    }
}

file delete -force $work
puts "seed [dict get $options -seed]: $sound sound programs on [join $backends {, }], $rejected rejected shapes ($witnessed with a failing witness), $::failures failures"
exit [expr {$::failures > 0}]
