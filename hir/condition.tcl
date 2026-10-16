# condition.tcl -- the branch form of a Boolean condition.
#
#   hir::condition::form HIR E        => true | false | if | value
#   hir::condition::constant HIR BODY => 1 | 0 | ""
#   hir::condition::releasing HIR E   => 1 | 0
#
# BRANCH-FORM-BOOLEAN-LOWERING.md. An expression demanded as a value is
# lowered to a value; an expression demanded as a branch -- the condition of
# an `if` -- is lowered directly to control flow wherever its meaning allows.
# This file states, once, which expressions have a direct branch form; each
# backend that compiles conditions (the Tcl compiler's CompileCondition,
# native/lower.tcl's Condition) emits it in its own vocabulary, and HIR is
# unchanged: there is no branch-context node, flag or side table.
#
# `and`, `or`, `not` and `!=` have no HIR form of their own. The front end
# lowers them to `if` expressions whose branches are the root Booleans
# (surface/lower.tcl):
#
#   a and b    if a {if b {^true} {^false}} {^false}
#   a or b     if a {^true} {if b {^true} {^false}}
#   not a      if a {^false} {^true}
#   a != b     if (a == b) {^false} {^true}
#
# so one rule covers them all, and every Boolean-valued `if` a program writes
# (`if (if a: b else: c):`) as well. As a branch to TRUE/FALSE:
#
#   true                 jump TRUE
#   false                jump FALSE
#   if C {S... T} {S'... E}
#                        C as a branch to THEN/ELSE; at THEN the statements
#                        S... run as statements and T is a branch to
#                        TRUE/FALSE, at ELSE likewise S'... and E. A branch
#                        that is only a Boolean constant needs no label of
#                        its own: its side of C goes to TRUE or FALSE
#                        directly (constant), so `not a` is `a` to
#                        FALSE/TRUE, and `a and b` is `a` to MID/FALSE, then
#                        `b` to TRUE/FALSE at MID.
#   anything else        its value, then a branch on it
#
# This is exactly the meaning HIR gives these expressions -- the same
# operands, evaluated in the same order, each at most once, only where the
# value form would evaluate them -- so it changes representation, never
# semantics. Every operand is lowered once, at the one place it runs: the
# lowering is linear in the condition's size, with no copy of any operand.
# hir::range::Paths reads the same structure to decompose a condition into
# proof paths (bounded by its own budget); this is its control-flow
# counterpart, and neither depends on the other (the lowering has no budget:
# every condition is lowered exactly, however long).

namespace eval hir::condition {}

# The branch form of expression E (above):
#   true / false  E is a reference to the root Boolean true / false (what the
#                 keywords lower to) or a Boolean constant: its outcome is
#                 known and evaluating it does nothing
#   if            E is an `if` with two nonempty branches that can complete
#                 normally (its type is not never): its outcome is its
#                 condition's choosing a branch, then that branch's last
#                 expression's
#   value         anything else: the outcome of its Bool value
proc hir::condition::form {hir e} {
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        ref {
            set b [dict get $node binding]
            if {$b ne "" && [dict get $hir bindings $b kind] eq "root"} {
                set value [dict get $hir bindings $b value]
                if {[core::value::kind $value] eq "bool"} {
                    return [expr {[core::value::isTrue $value] ? "true" : "false"}]
                }
            }
        }
        const {
            set value [dict get $node value]
            if {[core::value::kind $value] eq "bool"} {
                return [expr {[core::value::isTrue $value] ? "true" : "false"}]
            }
        }
        if {
            if {[dict get $node thenBody] ne {} && [dict get $node elseBody] ne {}
                    && [hir::typeOf $hir $e] ne "never"} {
                return if
            }
        }
    }
    return value
}

# The outcome of branch BODY of an `if` lowered as a branch when BODY is one
# Boolean constant statement after which nothing is released (1 or 0): its
# side of the condition then goes straight to the outer TRUE or FALSE. ""
# otherwise.
proc hir::condition::constant {hir body} {
    if {[llength $body] != 1} {
        return ""
    }
    set e [lindex $body 0]
    if {[releasing $hir $e]} {
        return ""
    }
    switch -- [form $hir $e] {
        true  { return 1 }
        false { return 0 }
    }
    return ""
}

# 1 if affine values are released right after statement E (hir::affine::
# releasesAfter): a branch's last expression E is then lowered as its value,
# the releases follow, and only then the branch on that value -- the order
# the value form has.
proc hir::condition::releasing {hir e} {
    return [expr {[hir::affine::releasesAfter $hir $e] ne {}}]
}
