# operators.tcl -- the arithmetic and comparison operators' meaning, chosen
# by their operands' static types (FLOAT64-MILESTONE-1.md).
#
# Botlish's numeric primitives are Int and the floating-point types
# (core/type.tcl's float family: Float64). An operator is written once --
# `a + b`, `a / b`, `a < b`, `-a` -- and its operands say which operation it
# is, statically, before any backend runs:
#
#   * an operand whose static type is a floating-point type T selects T's
#     operation: the root native T#OP (core/float.tcl; T#neg for unary
#     minus). The call is rewritten to call it -- its callee becomes a
#     reference to that root native, and unary minus's synthetic `0` goes --
#     so every later stage (the checks, the completion proofs, Core IR, every
#     backend) sees an ordinary call of an ordinary native. Its other operand
#     must then be a T as well: the native's parameter types say so, and an
#     Int operand is the ordinary argument type error. There is no implicit
#     conversion and no mixed-type arithmetic.
#   * otherwise `+ - * < <= > >=` are the Int operations they always were
#     (the root natives of their spelling), and `-a` is `0 - a`;
#   * `/` has no Int meaning (Botlish has no integer division): a `/` that no
#     floating-point operand selects is a TYPE diagnostic (verify, below).
#
# This is not overloading: nothing is declared, nothing is dispatched at run
# time, and the set of meanings is the language's -- one table,
# core::float::operators, for every float width. A call is resolved from the
# types of the program's own (generic) typing walk and then stays resolved:
# a semantic instance or a specialization's region inference, which retype a
# body under more precise argument types, see the rewritten call and never
# choose again, so no instance runs another operation than the program does.
#
# Resolution runs inside hir::types::infer, as a fixpoint: a walk types the
# program, every operator call it finds a floating-point operand of is
# rewritten, and the program is typed again while that changed anything. A
# rewrite only turns an Int-typed result into a floating-point one, so an
# operand that selected a float type keeps selecting it, and the fixpoint
# ends after at most one walk more than the program's chains of float
# operations are long (usually one: a walk's own types are complete before
# the rewrite reads them). A program with no floating-point operand pays one
# scan of its operator calls per walk.
#
# Only a call the source frontend wrote as an operator is resolved
# (hir/syntax.tcl's withOperator: the call node's `operator`): a call of
# `+` in Core IR text is the Int native it names, as the interpreter runs it.

namespace eval hir::operators {}

# Resolves the operator calls of HIR (header) whose operands the types of its
# latest walk select a floating-point operation for. Returns 1 if any call
# was rewritten (HIR must then be typed again), else 0.
proc hir::operators::resolve {hirVar} {
    upvar 1 $hirVar hir
    # A DecimalRounded operand selects its type's operation first, even
    # beside a Float64 decimal literal, which it makes a DecimalRounded one;
    # and a decimal constant expression where a DecimalRounded type is
    # expected becomes a DecimalRounded one (hir/decimal.tcl).
    set changed [hir::decimal::resolve hir]
    if {![dict exists $hir operatorCalls]} {
        return $changed
    }
    set remaining {}
    foreach e [dict get $hir operatorCalls] {
        set node [dict get $hir exprs $e]
        set op [dict get $node operator]
        if {$op eq "=="} {
            # The language's one equality for every other kind, a float's
            # included (core::value::equal).
            lappend remaining $e
            continue
        }
        set args [dict get $node args]
        set operands [if {$op eq "neg"} {lrange $args 1 end} else {set args}]
        set type [Selected $hir $operands]
        if {$type eq ""} {
            lappend remaining $e
            continue
        }
        Rewrite hir $e $op $type
        set changed 1
    }
    dict set hir operatorCalls $remaining
    return $changed
}

# The floating-point type the operand expressions OPERANDS select (the first
# one statically of a floating-point type), or "".
proc hir::operators::Selected {hir operands} {
    foreach a $operands {
        set kind [hir::types::kindOf [hir::typeOf $hir $a]]
        if {$kind ne "" && [core::type::isFloat $kind]} {
            return $kind
        }
    }
    return ""
}

# Rewrites operator call E (operator OP) into a call of the floating-point
# type TYPE's operation.
proc hir::operators::Rewrite {hirVar e op type} {
    upvar 1 $hirVar hir
    set native [core::float::operatorNative $type $op]
    set callee [dict get $hir exprs $e callee]
    set root [dict get $hir bindings [dict get $hir exprs $callee binding] scope]
    dict set hir exprs $callee binding [hir::resolve::RootBinding hir $root $native]
    dict set hir exprs $callee name $native
    if {$op eq "neg"} {
        # -X: the negation of X itself; the synthetic 0 of `0 - X` is no
        # operand of it and no expression of the program any more.
        set args [dict get $hir exprs $e args]
        dict unset hir exprs [lindex $args 0]
        dict set hir exprs $e args [lrange $args 1 end]
    }
    dict unset hir exprs $e operator
    dict set hir exprs $e resolvedOperator [list $op $type]
    dict lappend hir floatOperators $e
}

# 1 if one of the static types ARGTYPES of a call's operands is of another
# kind than the floating-point type TYPE its operator selected (an `any`
# operand is checked when the operation runs).
proc hir::operators::Mismatched {argTypes type} {
    foreach t $argTypes {
        set kind [hir::types::kindOf $t]
        if {$t ne "never" && $kind ni [list "" any $type]} {
            return 1
        }
    }
    return 0
}

# Diagnoses every `/` no floating-point operand selected (header): Botlish
# has no integer division; and every operator a floating-point type selected
# whose other operand is statically of another kind: there is no implicit
# conversion (a native's parameter types are otherwise checked when it runs,
# core/native.tcl; an operator's operands are checked here, where the program
# says what they are).
proc hir::operators::verify {hirVar} {
    upvar 1 $hirVar hir
    if {[dict exists $hir floatOperators]} {
        foreach e [dict get $hir floatOperators] {
            lassign [dict get $hir exprs $e resolvedOperator] op type
            set argTypes [lmap a [dict get $hir exprs $e args] {hir::typeOf $hir $a}]
            if {![dict get $hir exprs $e reachable] || ![Mismatched $argTypes $type]} {
                continue
            }
            hir::Diagnose hir TYPE [format \
                {the operands of "%s" are %s: a %s operation needs %s operands, and nothing converts one implicitly (%s::from_int makes an Int a %s)} \
                [if {$op eq "neg"} {string cat "-"} else {set op}] [join [lmap t $argTypes {hir::types::show $t}] " and "] \
                $type $type [dict get [core::type::floatInfo $type] namespace] $type] $e
        }
    }
    if {![dict exists $hir operatorCalls]} {
        return
    }
    foreach e [dict get $hir operatorCalls] {
        if {[dict get $hir exprs $e operator] ne "/" || ![dict get $hir exprs $e reachable]} {
            continue
        }
        set types [lmap a [dict get $hir exprs $e args] {hir::typeOf $hir $a}]
        if {"never" in $types} {
            # An operand that never completes (or is poison, whose own
            # diagnostic says why): nothing is divided.
            continue
        }
        set operands [lmap t $types {hir::types::show $t}]
        hir::Diagnose hir TYPE [format \
            {"/" divides floating-point numbers, and neither operand here is one (the operands are %s and %s): Botlish has no integer division} \
            {*}$operands] $e
    }
}
