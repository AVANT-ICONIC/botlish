# cardinality.tcl -- collecting-loop output-length facts
# (RETURNING-ITERABLE-LOOPS.md items 15-19, 51-52; COLLECTING-LOOPS.md extends
# them to the numeric and lockstep loops, which build their result List
# exactly like a listloop) and iteration-domain cardinality (bottom of file).
#
#   hir::cardinality::analyze $hir     -> dict: listloop ExprId -> exact|max
#   hir::cardinality::of $hir $e       -> exact|max, for one listloop E
#
# The smallest representation compatible with the milestone's own explicit
# scoping ("if the current fact framework cannot yet express relational
# collection length without a disproportionate new system, STOP AND REPORT
# that limitation before inventing one... a narrowly scoped metadata
# representation is preferable to a general theorem engine"): this is not a
# relational fact system, and it is deliberately independent of hir/range.
# tcl's own per-specialization-instance argument-fact machinery (Range,
# narrowing rounds, call-site seeding) -- a listloop's cardinality needs
# none of that. It depends on exactly one already-resolved HIR fact:
# hir/resolve.tcl's own `target` field on every break/continue node (the
# ExprId of the loop it lexically targets, resolved once, purely
# syntactically, independent of reachability analysis or types).
#
#   exact   no break/continue anywhere in the loop's own body targets it:
#           every normal completion of the loop produces a List of exactly
#           the iterable's own length (item 15's ExactLengthOf(input)).
#   max     a break or continue targeting this loop is reachable in its own
#           body (a nested loop's own break/continue targets *that* inner
#           loop instead, via the same lexical resolution hir/resolve.tcl
#           already performs, and so does not count here): output length
#           <= input length on every normal completion (items 16/17/19's
#           MaxLengthOf(input)).
#
# return/Error are nonlocal completions (item 17): a listloop execution that
# ends in one of them does not "normally produce a List" at all, so neither
# ever weakens exact into max here -- only an actually reachable break/
# continue does, which is exactly what scanning for a matching `target`
# field (independent of return/error/reachability) already captures. This
# module does no path-sensitive counting (item 20 of the milestone this
# followed, "do not attempt path-sensitive counting in this milestone"): a
# break/continue on a provably-dead path still downgrades exact to max,
# exactly like hir/aot.tcl's own "discarded" fact is similarly a syntactic,
# not path-sensitive, approximation.
namespace eval hir::cardinality {}

proc hir::cardinality::analyze {hir} {
    set result [dict create]
    dict for {id node} [dict get $hir exprs] {
        if {[dict get $node kind] in {listloop countloop lockloop}} {
            dict set result $id exact
        }
    }
    dict for {id node} [dict get $hir exprs] {
        if {[dict get $node kind] in {break continue}} {
            set target [dict get $node target]
            if {$target ne "" && [dict exists $result $target]} {
                dict set result $target max
            }
        }
    }
    return $result
}

# exact | max for one collecting loop E (listloop, countloop or lockloop: all
# three build their result List the same way).
proc hir::cardinality::of {hir e} {
    if {[dict get $hir exprs $e kind] ni {listloop countloop lockloop}} {
        error "hir::cardinality::of: $e is not a collecting loop"
    }
    return [dict get [analyze $hir] $e]
}

proc hir::cardinality::of_loop {hir e} {
    return [of $hir $e]
}

# ---------------------------------------------------------------------------
# Iteration-domain cardinality (COLLECTING-LOOPS.md)
#
# An *iteration domain* is one clause of a collecting loop: the List a
# `loop x in xs:` walks, or the Int interval a `loop i from a to b:` /
# `through` / `down from` visits. Every domain has a cardinality -- how many
# times it advances -- and that cardinality is a compile-time proof concept
# only: no runtime object, no source-visible count.
#
# The exact cardinality of each domain, as mathematics (no machine-width
# arithmetic, no `end + 1`):
#
#   x in L                     length(L)
#   i from a to b              max(b - a,     0)
#   i from a through b         max(b - a + 1, 0)
#   i down from b to a         max(b - a,     0)
#   i down from b through a    max(b - a + 1, 0)
#
# (with `start` = the first-written operand: a for `from`, b for `down
# from`, so the formulas above read  max(end - start + 1, 0)  for `up` and
# max(start - end + 1, 0) for `down`, plus the exclusive variants.)
#
# Proof representation. A cardinality is kept as a *linear form* over
# symbolic atoms,
#
#     FORM = {CONST {ATOM COEFF ATOM COEFF ...}}       (atoms sorted)
#
# and `max(F, 0)` is folded into the form: a form that is provably >= 0
# stays itself, a constant clamps to a constant, anything else becomes the
# single nonnegative atom {max F}. Two cardinalities are then
#
#   equal      iff their normalized forms are identical;
#   unequal    iff they differ by a nonzero constant (both are >= 0, so a
#              constant gap is a real gap);
#   unknown    otherwise.
#
# Atoms name immutable values, never mutable state, so equal atoms really
# are the same value (the same single-assignment argument hir/exactvalue.tcl
# relies on):
#
#   {len KEY}   the length of one List value (KEY identifies the value,
#               ValueKey: {b B} for a parameter / loop binding B, {p KEY
#               FIELD} for a field path, {e E} for the defining expression E
#               an alias chain ends at), always >= 0; or the length a loop
#               domain over a collection whose length is not fixed (a
#               MutableVector) had when that one loop evaluated its
#               iterable expression E: KEY is then {o E}, the occurrence
#               itself, never its binding, path or definition
#               (IterationLength)
#   {cap KEY}   the capacity of one MutableArray value (KEY as for len),
#               always >= 0 and fixed at allocation (STDLIB-NAMESPACES.md's
#               indexed-access proof is its one consumer besides lockstep)
#   {slen KEY}  the length (Unicode scalar values) of one String value (KEY
#               as for len), always >= 0 (the slice proof of
#               STDLIB-NAMESPACES.md)
#   {max FORM}  max(FORM, 0), always >= 0
#   {v B}       the Int bound to binding B (a parameter, loop variable ...)
#   {e E}       the Int value of the single expression E that no rule above
#               folds; only ever equal to itself
#
# Facts reused rather than reinvented: hir/exactvalue.tcl (exact Ints and
# exact List literals, followed through immutable bindings), the `+ - *`,
# `list::length` and `mutable_array::capacity` natives (and
# `mutable_array::allocate`'s capacity operand), and this file's own exact/max output-length
# fact for collecting loops (a `ys = loop x in xs: ...` without
# break/continue has exactly length(xs) elements). No relational List-length
# inference is added.
#
#   hir::cardinality::domains HIR E        -> the domain dicts of loop E
#   hir::cardinality::of_domain HIR D      -> cardinality FORM of domain D
#   hir::cardinality::compare F1 F2        -> equal | unequal | unknown
#   hir::cardinality::show HIR F           -> source-like text of F

namespace eval hir::cardinality {
    variable maxSteps 96
}

# ---- linear forms ----------------------------------------------------------

proc hir::cardinality::FormConst {c} { return [list $c {}] }
proc hir::cardinality::FormAtom {atom} { return [list 0 [list $atom 1]] }

proc hir::cardinality::FormAdd {a b {sign 1}} {
    lassign $a ca ta
    lassign $b cb tb
    set terms [dict create {*}$ta]
    dict for {atom coeff} $tb {
        set n [expr {[dict exists $terms $atom] ? [dict get $terms $atom] : 0}]
        set n [expr {$n + $sign * $coeff}]
        if {$n == 0} {
            dict unset terms $atom
        } else {
            dict set terms $atom $n
        }
    }
    set sorted {}
    foreach atom [lsort [dict keys $terms]] {
        lappend sorted $atom [dict get $terms $atom]
    }
    return [list [expr {$ca + $sign * $cb}] $sorted]
}

proc hir::cardinality::FormScale {a k} {
    lassign $a c terms
    if {$k == 0} {
        return [FormConst 0]
    }
    set scaled {}
    foreach {atom coeff} $terms {
        lappend scaled $atom [expr {$coeff * $k}]
    }
    return [list [expr {$c * $k}] $scaled]
}

proc hir::cardinality::IsConst {a} { return [expr {[lindex $a 1] eq ""}] }

# True if FORM is provably >= 0: a nonnegative constant plus positive
# multiples of atoms that are themselves always nonnegative.
proc hir::cardinality::NonNeg {a} {
    lassign $a c terms
    if {$c < 0} {
        return 0
    }
    foreach {atom coeff} $terms {
        if {[lindex $atom 0] ni {len cap slen max} || $coeff < 0} {
            return 0
        }
    }
    return 1
}

# max(FORM, 0), folded back into a form (see above).
proc hir::cardinality::Clamp {a} {
    if {[IsConst $a]} {
        return [FormConst [expr {max([lindex $a 0], 0)}]]
    }
    if {[NonNeg $a]} {
        return $a
    }
    return [FormAtom [list max $a]]
}

# ---- symbolic evaluation of immutable values --------------------------------

# Follows aliases from expression E: a `ref` to a single-assignment local
# binding continues at that binding's one `bind` value. Returns {expr D} for
# the first non-alias expression reached, or {binding B} for a binding with
# no defining expression (a parameter, a loop variable, a root name).
proc hir::cardinality::Chase {hir e stepsVar} {
    variable maxSteps
    upvar 1 $stepsVar steps
    while 1 {
        incr steps
        set node [dict get $hir exprs $e]
        if {$steps > $maxSteps || [dict get $node kind] ne "ref"} {
            return [list expr $e]
        }
        set b [dict get $node binding]
        if {$b eq ""} {
            return [list expr $e]
        }
        set binding [dict get $hir bindings $b]
        if {[dict get $binding kind] ne "local"} {
            return [list binding $b]
        }
        set declaration [dict get $binding declaredBy]
        if {$declaration eq ""} {
            return [list binding $b]
        }
        set bind [dict get $hir exprs $declaration]
        if {[dict get $bind kind] ne "bind" || [dict get $bind duplicate]} {
            return [list binding $b]
        }
        set e [dict get $bind value]
    }
}

# The key of the value of expression E in a size atom ({len KEY}, {cap
# KEY}, {slen KEY}): {b B} when E's alias chain (Chase) ends at a binding B
# with no defining expression (a parameter, a loop variable, a root name);
# {p KEY FIELD} when it ends at a projection E'.FIELD, KEY the key of the
# projection's receiver; else {e D}, the expression D it ends at, which
# names only itself. A field path names one value however often it is
# written: its root is a single-assignment binding (or one expression
# evaluated once per binding of its alias), and a struct's fields are
# immutable, so `t.slots` written twice is one MutableArray -- whose
# capacity is fixed, even when it is mutated in place through that field
# place (MUTABLE-ARRAY.md) -- and `b.cells` written twice one List. That is
# what lets a guard or a reduction on `t.slots.capacity()` prove the read
# `t.slots.at(i)` and the write `t.slots.set(i, v)`: the write has no
# local-alias form, a local `s = t.slots` being a logical copy. A key names
# one value, not one length: a field (or binding) holding a MutableVector
# holds one vector whose length a push changes in place, so no size form
# measures a vector by its key (IterationLength).
proc hir::cardinality::ValueKey {hir e stepsVar} {
    upvar 1 $stepsVar steps
    lassign [Chase $hir $e steps] kind id
    if {$kind eq "binding"} {
        return [list b $id]
    }
    set node [dict get $hir exprs $id]
    if {[dict get $node kind] eq "project"} {
        return [list p [ValueKey $hir [dict get $node receiver] steps] [dict get $node name]]
    }
    return [list e $id]
}

proc hir::cardinality::NativeName {hir node} {
    if {[dict get $node kind] ne "call"} {
        return ""
    }
    lassign [dict get $node target] kind target
    if {$kind ne "native"} {
        return ""
    }
    return [dict get [hir::symbol $hir $target] name]
}

# The linear form of the Int expression E.
proc hir::cardinality::IntForm {hir e stepsVar} {
    upvar 1 $stepsVar steps
    set exact [hir::exact::IntOf $hir $e]
    if {$exact ne ""} {
        return [FormConst $exact]
    }
    lassign [Chase $hir $e steps] kind id
    if {$kind eq "binding"} {
        return [FormAtom [list v $id]]
    }
    set node [dict get $hir exprs $id]
    set name [NativeName $hir $node]
    set args [expr {$name eq "" ? {} : [dict get $node args]}]
    if {$name in {+ -} && [llength $args] == 2} {
        set x [IntForm $hir [lindex $args 0] steps]
        set y [IntForm $hir [lindex $args 1] steps]
        return [FormAdd $x $y [expr {$name eq "+" ? 1 : -1}]]
    }
    if {$name eq "*" && [llength $args] == 2} {
        set x [IntForm $hir [lindex $args 0] steps]
        set y [IntForm $hir [lindex $args 1] steps]
        if {[IsConst $x]} {
            return [FormScale $y [lindex $x 0]]
        }
        if {[IsConst $y]} {
            return [FormScale $x [lindex $y 0]]
        }
    }
    if {$name eq "list::length" && [llength $args] == 1} {
        return [ListLength $hir [lindex $args 0] steps]
    }
    if {$name eq "mutable_array::capacity" && [llength $args] == 1} {
        return [Capacity $hir [lindex $args 0] steps]
    }
    if {$name eq "str::length" && [llength $args] == 1} {
        return [StrLength $hir [lindex $args 0] steps]
    }
    return [FormAtom [list e $id]]
}

# The length, in Unicode scalar values, of the String value of expression
# E, as a (nonnegative) form: the exact length of an exactly known String
# (hir/exactvalue.tcl: a literal, followed through immutable bindings); the
# sum of the operands' lengths for `str::concat`; the operand's length for
# `str::lowercase` (a simple, one-to-one case mapping); END - START for a
# `str::substring(s, START, END)` that returned; else the atom {slen KEY},
# keyed like `len` (ValueKey) -- a String is immutable, so equal keys are
# equal lengths.
proc hir::cardinality::StrLength {hir e stepsVar} {
    upvar 1 $stepsVar steps
    set fact [hir::exact::Of $hir $e]
    if {[lindex $fact 0] eq "val" && [core::value::kind [lindex $fact 1]] eq "str"} {
        return [FormConst [string length [core::value::strOf [lindex $fact 1]]]]
    }
    lassign [Chase $hir $e steps] kind id
    if {$kind eq "binding"} {
        return [FormAtom [list slen [list b $id]]]
    }
    set node [dict get $hir exprs $id]
    set name [NativeName $hir $node]
    set args [expr {$name eq "" ? {} : [dict get $node args]}]
    switch -- $name/[llength $args] {
        str::concat/2 {
            return [FormAdd [StrLength $hir [lindex $args 0] steps] [StrLength $hir [lindex $args 1] steps]]
        }
        str::lowercase/1 {
            return [StrLength $hir [lindex $args 0] steps]
        }
        str::substring/3 {
            return [FormAdd [IntForm $hir [lindex $args 2] steps] [IntForm $hir [lindex $args 1] steps] -1]
        }
    }
    return [FormAtom [list slen [ValueKey $hir $id steps]]]
}

# The capacity of the MutableArray value of expression E, as a (nonnegative)
# form: the allocation's own capacity operand when E is (an alias of) a
# `mutable_array::allocate` call -- an allocation that returns has exactly
# that capacity -- or of one of the library's intrinsic container
# operations hir/containers.tcl registers (its `create` rule: the capacity
# operand; its `from-list` rule: the List's length), else the atom
# {cap KEY}, keyed like `len` (ValueKey: a field path too). A MutableArray's
# capacity is fixed at allocation and never changes (core/mutarray.tcl), and
# an immutable binding holds one array for its whole lifetime, so equal
# atoms are the same capacity even though the array's *contents* mutate.
proc hir::cardinality::Capacity {hir e stepsVar} {
    upvar 1 $stepsVar steps
    lassign [Chase $hir $e steps] kind id
    if {$kind eq "binding"} {
        return [FormAtom [list cap [list b $id]]]
    }
    set node [dict get $hir exprs $id]
    # An array constructor makes as many slots as its registration's
    # -result-length says (core/native.tcl): its Int capacity argument
    # (allocate, create, generate) or the length of its List argument
    # (from_list).
    set name [NativeName $hir $node]
    if {$name ne ""} {
        set length [dict get [core::native::metadata $name] resultLength]
        set args [dict get $node args]
        if {$length ne "" && [lindex $length 1] < [llength $args]} {
            lassign $length how index
            set arg [lindex $args $index]
            return [expr {$how eq "int" ? [IntForm $hir $arg steps] : [ListLength $hir $arg steps]}]
        }
    }
    return [FormAtom [list cap [ValueKey $hir $id steps]]]
}

# The length of the List value of expression E, as a (nonnegative) form.
# E's value is a List wherever its length is read -- an operand a List
# native (list::length, list::at, a slice, mutable_array::from_list) takes,
# which fails on anything else, or the iterable of a loop that requires one
# -- or a MutableArray a loop walks (IterationLength), whose length is fixed
# too, so the length of one is its key's (ValueKey).
proc hir::cardinality::ListLength {hir e stepsVar} {
    upvar 1 $stepsVar steps
    set fact [hir::exact::ListOf $hir $e]
    if {$fact ne ""} {
        return [FormConst [hir::exact::Length $fact]]
    }
    lassign [Chase $hir $e steps] kind id
    if {$kind eq "binding"} {
        return [FormAtom [list len [list b $id]]]
    }
    set node [dict get $hir exprs $id]
    switch -- [dict get $node kind] {
        listloop - countloop - lockloop {
            if {[of_loop $hir $id] eq "exact"} {
                set domains [domains $hir $id]
                return [of_domain $hir [lindex $domains 0] steps]
            }
        }
    }
    if {[NativeName $hir $node] eq "list"} {
        return [FormConst [llength [dict get $node args]]]
    }
    return [FormAtom [list len [ValueKey $hir $id steps]]]
}

# The number of elements the list domain over the iterable expression E
# visits: the length E's value has when its loop evaluates E, once. A loop
# walks a List -- an iterable of any static type but MutableVector and
# MutableArray must be one when the loop runs (its TYPE check) -- or the
# snapshot (or, affine, the consumption) of a MutableArray or MutableVector
# (MUTABLE-VECTOR.md, MUTABLE-ARRAY.md). A List's length never changes (it
# is immutable), nor does a MutableArray's (its capacity, fixed at
# allocation), so a binding, field path or definition that names one names
# one length: ListLength's, keyed by it. A MutableVector's does change, in
# place, through whatever place holds it -- push, pop, take and clear on
# the binding or the field path, a callee's on its own context parameter --
# while the binding, path or member stays the same. A domain over a vector
# has the length of this one evaluation only: the atom {len {o E}}, E the
# iterable itself, equal to no other occurrence's -- or SAME's, the earlier
# domain of its lockstep loop that evaluated the same place with no code
# run between them (domains). Two loops over one vector have unrelated
# lengths, as do a vector and a List an earlier loop collected over it,
# whatever runs between them.
proc hir::cardinality::IterationLength {hir e stepsVar {same ""}} {
    upvar 1 $stepsVar steps
    if {[hir::types::kindOf [hir::typeOf $hir $e]] eq "mutvec"} {
        return [FormAtom [list len [list o [expr {$same ne "" ? $same : $e}]]]]
    }
    return [ListLength $hir $e steps]
}

# ---- domains -----------------------------------------------------------------

# Loop E's iteration domains, in written order, as dicts
#   {kind list iterable EXPR ?same EXPR?}
#   {kind count start EXPR end EXPR direction D endKind K}
# (for lockloop, the node's own domains; for a single-domain loop, the one
# domain its own fields describe). A lockloop evaluates its domains once, in
# written order, before its first iteration (COLLECTING-LOOPS.md): a list
# domain whose iterable is the same place (a binding with the same field
# projections, hir::mutvec::Path) as an earlier domain's, with every domain
# expression up to it a place or a constant, is evaluated with no code run
# since that earlier one, so it walks the same collection. `same` names the
# earlier iterable (IterationLength).
proc hir::cardinality::domains {hir e} {
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        listloop {
            return [list [dict create kind list iterable [dict get $node iterable]]]
        }
        countloop {
            return [list [dict create kind count start [dict get $node start] \
                end [dict get $node end] direction [dict get $node direction] \
                endKind [dict get $node endKind]]]
        }
        lockloop {
            set out {}
            set quiet 1
            set first [dict create]
            foreach domain [dict get $node domains] {
                if {[dict get $domain kind] ne "list"} {
                    set quiet [expr {$quiet && [Quiet $hir [dict get $domain start]] && [Quiet $hir [dict get $domain end]]}]
                } else {
                    set iterable [dict get $domain iterable]
                    set quiet [expr {$quiet && [Quiet $hir $iterable]}]
                    set path [expr {$quiet ? [hir::mutvec::Path $hir $iterable] : ""}]
                    if {$path ne "" && [dict exists $first $path]} {
                        dict set domain same [dict get $first $path]
                    } elseif {$path ne ""} {
                        dict set first $path $iterable
                    }
                }
                lappend out $domain
            }
            return $out
        }
    }
    error "hir::cardinality::domains: $e is not a collecting loop"
}

# 1 if evaluating expression E runs no code: a constant, a reference, or a
# field projection of one.
proc hir::cardinality::Quiet {hir e} {
    while {[dict get $hir exprs $e kind] eq "project"} {
        set e [dict get $hir exprs $e receiver]
    }
    return [expr {[dict get $hir exprs $e kind] in {const ref}}]
}

# The cardinality FORM of DOMAIN.
proc hir::cardinality::of_domain {hir domain {stepsVar ""}} {
    if {$stepsVar eq ""} {
        set steps 0
    } else {
        upvar 1 $stepsVar steps
    }
    if {[dict get $domain kind] eq "list"} {
        set same [expr {[dict exists $domain same] ? [dict get $domain same] : ""}]
        return [IterationLength $hir [dict get $domain iterable] steps $same]
    }
    set start [IntForm $hir [dict get $domain start] steps]
    set end [IntForm $hir [dict get $domain end] steps]
    # The elements strictly beyond START toward END, plus one for END itself
    # when the end is inclusive: max(END - START, 0) for an ascending loop,
    # max(START - END, 0) for a descending one, +1 when inclusive.
    if {[dict get $domain direction] eq "up"} {
        set span [FormAdd $end $start -1]
    } else {
        set span [FormAdd $start $end -1]
    }
    if {[dict get $domain endKind] eq "inclusive"} {
        set span [FormAdd $span [FormConst 1]]
    }
    return [Clamp $span]
}

proc hir::cardinality::compare {a b} {
    if {$a eq $b} {
        return equal
    }
    set gap [FormAdd $a $b -1]
    if {[IsConst $gap]} {
        return unequal
    }
    return unknown
}

# ---- rendering (diagnostics) --------------------------------------------------

proc hir::cardinality::show {hir form} {
    lassign $form c terms
    set parts {}
    foreach {atom coeff} $terms {
        set text [ShowAtom $hir $atom]
        if {abs($coeff) != 1} {
            set text "[expr {abs($coeff)}] * $text"
        }
        lappend parts [list [expr {$coeff < 0}] $text]
    }
    if {$c != 0 || $parts eq ""} {
        lappend parts [list [expr {$c < 0}] [expr {abs($c)}]]
    }
    set out ""
    foreach part $parts {
        lassign $part negative text
        if {$out eq ""} {
            set out [expr {$negative ? "-$text" : $text}]
        } else {
            append out [expr {$negative ? " - " : " + "}] $text
        }
    }
    return $out
}

proc hir::cardinality::ShowAtom {hir atom} {
    lassign $atom kind what
    switch -- $kind {
        v { return [hir::semantic::SourceName $hir $what] }
        max { return "max([show $hir $what], 0)" }
        len { return "length([ShowKey $hir $what])" }
        cap { return "capacity([ShowKey $hir $what])" }
        slen { return "str::length([ShowKey $hir $what])" }
        e { return [ShowExpr $hir $what] }
    }
    return $atom
}

# Source-like text of a value key (ValueKey).
proc hir::cardinality::ShowKey {hir key} {
    lassign $key how what field
    switch -- $how {
        b { return [hir::semantic::SourceName $hir $what] }
        p { return "[ShowKey $hir $what].$field" }
        o {
            # One evaluation of an iterable: its path and where it is
            # written, so that two loops over one vector read apart.
            set origin [dict get $hir exprs $what origin]
            set text [ShowPath $hir $what]
            set at [lrange $origin 2 end]
            if {[lindex $origin 0] eq "file" && [dict exists $at line] && [dict exists $at column]} {
                append text " at [dict get $at line]:[dict get $at column]"
            }
            return $text
        }
    }
    return [ShowExpr $hir $what]
}

# Source-like text of E, a field path (`b.v`) written out.
proc hir::cardinality::ShowPath {hir e} {
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] eq "project"} {
        return "[ShowPath $hir [dict get $node receiver]].[dict get $node name]"
    }
    return [ShowExpr $hir $e]
}

proc hir::cardinality::ShowExpr {hir e} {
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        ref {
            set b [dict get $node binding]
            return [expr {$b eq "" ? [dict get $node name] : [hir::semantic::SourceName $hir $b]}]
        }
        call {
            set callee [dict get $node callee]
            set name [expr {[dict get $hir exprs $callee kind] eq "ref" ? [hir::semantic::RefName $hir $callee] : "<call>"}]
            return "${name}(...)"
        }
        const { return [lindex [dict get $node literal] end] }
        listloop - countloop - lockloop { return "(loop result)" }
    }
    return "(expression)"
}
