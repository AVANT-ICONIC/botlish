# refinements.tcl -- scalar refinements: compiler-known integer facts on a
# type (DECIMAL-ROUNDED-MILESTONE-1.md, "Scalar refinements").
#
#   DecimalRounded{minDecimalsPreserved: 2}
#   DecimalRounded{minDecimalsPreserved: 2, maxDecimalsPreserved: 4}
#
# A scalar refinement is a *family* of types over one base type, each member
# naming the base plus a canonical set of integer-valued parameters -- facts
# the compiler knows about every value of the type. It is a type
# refinement with scalar parameters, not a generic: the parameters are
# numbers, never types, and a member is one type, never an instantiation.
# A family is declared here, by the compiler, never by a program; this
# milestone declares exactly one, DecimalRounded. Everything else about
# refinements is generic over the schema below:
#
#   * declaration   `families`: the base, the parameters (each required or
#                   optional, its range, the order its implication uses and
#                   what an absent one means) and the constraints between
#                   parameters;
#   * validation    Resolve, every problem a diagnostic
#                   (REFINEMENT-PARAMETER);
#   * canonical form  {srefined FAMILY FACTS}, FACTS the present parameters in
#                   schema order (Canonical), so equal types are equal values;
#   * implication   Implies: weakening is subtyping (hir::types::subtype);
#   * joins         Lub, Glb (hir::types::lub, FnGlb);
#   * formatting    Show / Parse: the source spelling, which HIR text writes
#                   and reads back (hir/format.tcl, hir/read.tcl);
#   * decay         the base: every member is a subtype of its family's base
#                   type, which states no fact (a bare DecimalRounded, of
#                   unknown precision), so forgetting every fact is ordinary
#                   subtyping too; minting a fact never is (a value acquires
#                   one only by a proof, hir/decimal.tcl).
#
# A parameter's *order* says which values are stronger facts: `atLeast` (the
# parameter bounds a property from below; a larger value is a stronger fact,
# so A implies B when A's value is at least B's). An absent optional
# parameter takes its `absent` value in comparisons (`inf`: no bound at all,
# the strongest). Both DecimalRounded parameters are atLeast:
#
#   minDecimalsPreserved  the precision every observation may rely on: a
#                         value correct to 4 places is one correct to 2;
#   maxDecimalsPreserved  the precision observations of the value are
#                         limited to (its observation ceiling): a value whose
#                         observations may be as fine as 6 places (or are
#                         unbounded, absent) may stand where observations are
#                         limited to 4, never the reverse -- dropping a
#                         ceiling would let a later observation see
#                         distinctions the value's type excluded.
#
# Further orders (`atMost` for a magnitude bound, `exactly` for a List
# length) are what later families need; the schema keeps that one word.

namespace eval hir::refinements {
    # FAMILY -> its schema:
    #   base         the core type (core/type.tcl) the facts refine: a value
    #                of every member is a value of it
    #   params       PARAM -> {required 0|1 min LO max HI order ORDER absent
    #                A}, in canonical order
    #   constraints  {atLeast A B ...}: parameter A, when present, is at
    #                least parameter B
    #   message      for each constraint, what a violation means
    variable families [dict create DecimalRounded [dict create \
        base DecimalRounded \
        params [dict create \
            minDecimalsPreserved [dict create required 1 min 0 max 1000 order atLeast absent ""] \
            maxDecimalsPreserved [dict create required 0 min 0 max 1000 order atLeast absent inf]] \
        constraints [list [list atLeast maxDecimalsPreserved minDecimalsPreserved \
            "an upper precision bound below the guaranteed precision describes no value: maxDecimalsPreserved must be at least minDecimalsPreserved"]]]]
}

# 1 if NAME is a scalar-refinement family.
proc hir::refinements::isFamily {name} {
    variable families
    return [dict exists $families $name]
}

# The schema of FAMILY.
proc hir::refinements::Schema {family} {
    variable families
    return [dict get $families $family]
}

# The base core type of FAMILY.
proc hir::refinements::base {family} {
    return [dict get [Schema $family] base]
}

# 1 if TYPEEXPR (a surface::parser::TypeExpr) is a scalar refinement
# {refine NAME FIELDS} (surface::parser::ScalarRefinement).
proc hir::refinements::IsRefinementExpr {typeExpr} {
    return [expr {[llength $typeExpr] == 3 && [lindex $typeExpr 0] eq "refine"}]
}

# 1 if TYPE is a scalar-refined static type {srefined FAMILY FACTS}.
proc hir::refinements::IsRefined {type} {
    return [expr {[llength $type] == 3 && [lindex $type 0] eq "srefined"}]
}

proc hir::refinements::Family {type} { return [lindex $type 1] }
proc hir::refinements::Facts {type} { return [lindex $type 2] }

# The value of parameter PARAM of the refined TYPE, its schema's `absent`
# value when TYPE does not state it.
proc hir::refinements::fact {type param} {
    set facts [Facts $type]
    if {[dict exists $facts $param]} {
        return [dict get $facts $param]
    }
    return [dict get [Schema [Family $type]] params $param absent]
}

# The canonical refined type of FAMILY with the parameter values FACTS (a
# dict, any order), assumed valid (Problems).
proc hir::refinements::Canonical {family facts} {
    set canonical [dict create]
    dict for {param spec} [dict get [Schema $family] params] {
        if {[dict exists $facts $param]} {
            dict set canonical $param [expr {[dict get $facts $param] + 0}]
        }
    }
    return [list srefined $family $canonical]
}

# The problems of FAMILY applied to the written parameters FIELDS (a list of
# {PARAM TEXT}, written order): a list of messages, empty for a valid type.
proc hir::refinements::Problems {family fields} {
    set schema [Schema $family]
    set params [dict get $schema params]
    set problems {}
    set given [dict create]
    foreach field $fields {
        lassign $field param text
        if {![dict exists $params $param]} {
            lappend problems [format {"%s" is not a parameter of %s (its parameters: %s)} \
                $param $family [join [dict keys $params] {, }]]
            continue
        }
        if {[dict exists $given $param]} {
            lappend problems "$family states \"$param\" twice"
            continue
        }
        if {![regexp {^-?[0-9]+$} $text]} {
            lappend problems "$family's \"$param\" is an integer, not \"$text\""
            continue
        }
        set spec [dict get $params $param]
        if {$text < [dict get $spec min] || $text > [dict get $spec max]} {
            lappend problems [format {%s's "%s" must be from %s to %s, not %s} \
                $family $param [dict get $spec min] [dict get $spec max] $text]
            continue
        }
        dict set given $param $text
    }
    dict for {param spec} $params {
        if {[dict get $spec required] && ![dict exists $given $param]} {
            lappend problems [format {%s requires "%s" (write %s)} $family $param [Example $family]]
        }
    }
    if {$problems ne {}} {
        return $problems
    }
    foreach constraint [dict get $schema constraints] {
        lassign $constraint relation a b message
        if {[dict exists $given $a] && [dict exists $given $b]
                && $relation eq "atLeast" && [dict get $given $a] < [dict get $given $b]} {
            lappend problems "$message ($family{[ShowFacts $given]})"
        }
    }
    return $problems
}

# A spelling of FAMILY with its required parameters, for a message.
proc hir::refinements::Example {family} {
    set fields {}
    dict for {param spec} [dict get [Schema $family] params] {
        if {[dict get $spec required]} {
            lappend fields "$param: N"
        }
    }
    return "$family{[join $fields {, }]}"
}

# The refined type the type expression FAMILY{FIELDS} denotes (FIELDS:
# {PARAM TEXT} pairs, surface::parser::TypeExpr's), or a Tcl error
# (REFINEMENT-PARAMETER) naming every problem.
proc hir::refinements::Resolve {family fields} {
    variable families
    if {![isFamily $family]} {
        return -code error -errorcode {BOTLISH REFINEMENT-PARAMETER} \
            "\"$family\" has no scalar refinements: NAME{...} refines one of [join [dict keys $families] {, }]"
    }
    set problems [Problems $family $fields]
    if {$problems ne {}} {
        return -code error -errorcode {BOTLISH REFINEMENT-PARAMETER} [join $problems {; }]
    }
    set facts [dict create]
    foreach field $fields {
        dict set facts [lindex $field 0] [lindex $field 1]
    }
    return [Canonical $family $facts]
}

# The error a bare annotation naming FAMILY is: its facts are part of the
# type, so there is no unrefined spelling.
proc hir::refinements::BareMessage {family} {
    return "$family is written with its refinement parameters, which are part of the type: [Example $family]"
}

# 1 if parameter value A is at least B (either may be `inf`).
proc hir::refinements::AtLeast {a b} {
    if {$b eq "inf"} {
        return [expr {$a eq "inf"}]
    }
    if {$a eq "inf"} {
        return 1
    }
    return [expr {$a >= $b}]
}

# 1 if every value of the refined type A is a value of the refined type B:
# the same family, every parameter of A implying B's (its order).
proc hir::refinements::Implies {a b} {
    if {[Family $a] ne [Family $b]} {
        return 0
    }
    dict for {param spec} [dict get [Schema [Family $a]] params] {
        set va [fact $a $param]
        set vb [fact $b $param]
        if {$vb eq ""} {
            continue
        }
        if {$va eq "" || ![AtLeast $va $vb]} {
            return 0
        }
    }
    return 1
}

# The parameter values FACTS (absent ones as the schema's `absent` value)
# made a canonical type of FAMILY, absent values left out again; "" when the
# result breaks a constraint.
proc hir::refinements::FromValues {family values} {
    set facts [dict create]
    dict for {param value} $values {
        if {$value ne "inf" && $value ne ""} {
            dict set facts $param $value
        }
    }
    set fields [lmap {param value} $facts {list $param $value}]
    if {[Problems $family $fields] ne {}} {
        return ""
    }
    return [Canonical $family $facts]
}

# The most precise type describing values of the refined types A or B (of
# one family): each parameter the weaker of the two.
proc hir::refinements::Lub {a b} {
    set family [Family $a]
    set values [dict create]
    dict for {param spec} [dict get [Schema $family] params] {
        set va [fact $a $param]
        set vb [fact $b $param]
        if {[AtLeast $va $vb]} {
            dict set values $param $vb
        } else {
            dict set values $param $va
        }
    }
    return [FromValues $family $values]
}

# The type of values of both refined types A and B (of one family): each
# parameter the stronger of the two; "" when none is representable.
proc hir::refinements::Glb {a b} {
    set family [Family $a]
    set values [dict create]
    dict for {param spec} [dict get [Schema $family] params] {
        set va [fact $a $param]
        set vb [fact $b $param]
        if {[AtLeast $va $vb]} {
            dict set values $param $va
        } else {
            dict set values $param $vb
        }
    }
    return [FromValues $family $values]
}

# FACTS (a dict) as the fields of a source spelling.
proc hir::refinements::ShowFacts {facts} {
    return [join [lmap {param value} $facts {format {%s: %s} $param $value}] {, }]
}

# The source spelling of the refined TYPE: FAMILY{PARAM: VALUE, ...} in
# canonical order. It is a Tcl-list-safe text (balanced braces), as Fn{...}
# is, so HIR text writes it and hir::read parses it back (Parse).
proc hir::refinements::Show {type} {
    return "[Family $type]{[ShowFacts [Facts $type]]}"
}

# The refined type TEXT spells (Show's output, or any spelling of one with
# commas between its fields), or "" when TEXT is none.
proc hir::refinements::Parse {text} {
    if {![regexp {^([A-Za-z_][A-Za-z0-9_]*)\{(.*)\}$} $text -> family body] || ![isFamily $family]} {
        return ""
    }
    set fields {}
    foreach part [split $body ,] {
        set part [string trim $part]
        if {$part eq ""} {
            continue
        }
        if {![regexp {^([A-Za-z_][A-Za-z0-9_]*):\s*(-?[0-9]+)$} $part -> param value]} {
            return ""
        }
        lappend fields [list $param $value]
    }
    if {[Problems $family $fields] ne {}} {
        return ""
    }
    set facts [dict create]
    foreach field $fields {
        dict set facts [lindex $field 0] [lindex $field 1]
    }
    return [Canonical $family $facts]
}
