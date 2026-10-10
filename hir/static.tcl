# static.tcl -- static intrinsics: `static compile:` (STATIC-COMPILE.md).
#
#   hir::static::present NODES MODULES        1 if the program has a static node
#   hir::static::decide NODES OPTIONS GIVEN HALT   => HIR (hir::buildSyntax)
#   hir::static::sites HIR                    the decided sites of a built program
#   hir::static::codes                        internal kind -> DiagnosticCode case
#
# A static intrinsic is a compiler-directed syntactic operation on a captured,
# parser-valid block: `static OPERATION:` followed by an indented block
# (surface/parser.tcl's staticIntrinsic, hir/syntax.tcl's `static` node). The
# one operation is `compile`: a recoverable semantic-compilation boundary.
#
#   static compile:
#       BODY
#
# has two compilation outcomes. If the compiler accepts BODY where it stands,
# the boundary disappears: the site becomes BODY, ordinary syntax, compiled
# by the ordinary pipeline with its ordinary value and errors. If the
# compiler rejects BODY, the site becomes the reification of the compiler's
# primary diagnostic for it -- an ordinary
#
#   fail compiler::CompilerError {code: compiler::DiagnosticCode::CASE,
#       primary: compiler::SourceLocation {line: L, column: C},
#       related: [...], message: "..."}
#
# -- and none of BODY survives. Either way the static node is gone before
# hir::resolve sees the program: no HIR expression, analysis, core IR form,
# NIR instruction or runtime operation knows static intrinsics exist.
#
# Phase placement
# ---------------
# After parsing (the body is parsed syntax, carried as hir/syntax.tcl nodes
# with their source origins) and before resolution (Expand writes each site's
# decided form into the syntax the ordinary build consumes). A site is
# decided by building the whole program with the ordinary pipeline -- the one
# compiler: resolution, types, ranges and refinements, completions, affine
# ownership, contexts, traits, opaque authority, semantic instances,
# callable contracts -- with the site's body in place, and reading the
# diagnostics that build records as data (hir::Diagnose: nothing raises
# during a build). That build *is* the transaction: it is a pure value (HIR is
# persistent dicts), so a rejected body is rolled back by not keeping it --
# its bindings, moves, facts, instances and summaries existed only in a HIR
# that is discarded -- and the next build starts from the decided syntax
# alone. The per-compilation registries a build fills (structs, enums,
# errors, traits, imports) are rebuilt from the same declarations by every
# build, and a static block cannot declare into them (declarations are
# top-level only), so nothing a rejected body did can leak.
#
# Which diagnostic belongs to which site
# --------------------------------------
# A diagnostic belongs to the innermost site whose body contains its primary
# location (the location a strict compile reports: its `origin`, else its
# expression's), among the sites present as bodies in that build. Every
# other diagnostic is the enclosing program's own. The site's diagnostic is
# the first of its own in the build's diagnostic list: the one ordinary
# compilation of the same code would raise first (surface::lower::Finish
# raises the first of the list; resolution diagnostics stop a strict build
# before typing, so they come first; a method-call decision prepends its
# own).
#
# Deciding (decide)
# -----------------
# Sites are taken in post-order: a nested site before the site containing it
# (its outcome is part of the outer body), and otherwise in source order
# (modules' sections before the entry program, as they are resolved). Each
# round builds the program with every decided site in its decided form and
# every undecided site's body in place:
#
#   1. a loader diagnostic (surface/modules.tcl: a qualified reference the
#      file may not make) found in a body rejects that site before any build
#      -- the loader runs before HIR exists, so its diagnostic precedes every
#      HIR diagnostic of the same code;
#   2. a round that stopped after resolution (strict compilation does not
#      type a program with unresolved names): every site with a resolution
#      diagnostic of its own is rejected, all together -- resolution is
#      lexical, and a site's own bindings are scoped to its block, so no
#      other site's form can change what a site's names resolve to. A
#      resolution diagnostic of the enclosing program ends the decisions:
#      the program is rejected whatever they would be;
#   3. otherwise (a typed round) the first site in post-order with a
#      diagnostic of its own is rejected, and every undecided site before it
#      is accepted -- every site before it compiled in a program whose
#      earlier sites have their final forms. A rejected body's effects (a
#      move, a refinement, an instance, a function's summary) are gone only
#      from the next round on, so a later site is judged again without them:
#      one rejection per round -- except that a further failing site is
#      rejected in the same round when no other failing site can have caused
#      its diagnostic (Rejectable, Independent): the two lie in different
#      units of the program (a top-level function with everything nested in
#      it, or a section's top-level code), neither unit reaches the other
#      through the program's references, and nothing in the build acts
#      program-wide (a demoted inferred contract, an erased-callable
#      contract: GlobalChannels). Independent blocks -- a test framework's
#      tests, each its own function -- are so decided together. A site
#      accepted earlier that now has a diagnostic of its own is rejected (a
#      later decision removed something it relied on): decisions only ever
#      go from body to rejection, so the rounds end. A round in which no
#      site has a diagnostic of its own accepts every undecided site and is
#      the final program.
#
# Decisions follow source order. A site is judged with the sites after it
# present as written: a later site's body can reach an earlier one only
# backwards -- through a loop's next iteration, a recursive call or a
# program-wide contract -- and only there can a later block that is itself
# rejected afterwards have caused an earlier block's diagnostic (a later
# *accepted* block's effect on an earlier one is ordinary: the final program
# has it).
#
# The enclosing program's own diagnostics are not consulted while deciding
# (a trial body may cause them: a move the site's rejection undoes); those
# of the final program are its diagnostics, raised by the caller as for any
# program. The final program therefore satisfies: no diagnostic lies in the
# body of an accepted site, and every rejected site carries the primary
# diagnostic its body had in the program whose earlier sites have their
# final forms. A diagnostic the compiler marks as its own failure (an
# *-INTERNAL kind, a problem found in the monomorphized program) is never a
# site's (Internal), and a Tcl error raised while building is never caught:
# a failure of the compiler fails the compilation, never becomes a
# CompilerError.
#
# What a site sees
# ----------------
# Its body is compiled where it stands: the lexical environment (bindings,
# imports, the module's namespace), and every fact the ordinary compiler has
# there (types, ranges, refinements, ownership, contexts). Its own bindings
# are scoped to the block, exactly an `if true:` block's: an accepted body
# that binds nothing in its own scope is spliced in place (the same syntax
# nodes, so the same HIR, code and machine code as writing it there), any
# other is the then-branch of an `if` on the root `true` (Accepted).
#
# Completions
# -----------
# The reified failure is an ordinary `fail` of an ordinary payload error,
# marked `static {operation compile kind KIND}` (provenance only). Two rules
# read the mark: KNOWN-ERROR does not count a reified failure as proof that a
# function never completes normally (hir/completions.tcl's `intended`), and
# SAME-FAILURE does not count it as a fail site written by the programmer
# (hir/warnings.tcl). Everything else -- the enclosing function's `errors`,
# handlers, propagation, payload transport on every backend -- is the
# ordinary error machinery; the one other use of the mark is the wording of
# the UNHANDLED-ERROR a rejected site's error raises where it is not admitted
# (hir/resolve.tcl).

namespace eval hir::static {
    # The public diagnostic identities (lib/compiler.bot's `enum
    # DiagnosticCode`): every error diagnostic kind a parser-valid block can
    # make the compiler report, and the one case each becomes. Explicit and
    # one-to-one (tests/static-compile.test pins it against the enum and
    # against the census of the compiler's diagnostic kinds,
    # STATIC-COMPILE.md "Diagnostic-code census"): a kind missing here is an
    # internal compiler failure when it is reified, never a default case.
    variable codes {
        AFFINE-CAPTURE-UNSUPPORTED               AffineCaptureUnsupported
        AFFINE-CONTAINER-UNSUPPORTED             AffineContainerUnsupported
        AFFINE-DUPLICATION-UNSUPPORTED           AffineDuplicationUnsupported
        AFFINE-ELEMENT-COPY-OUT                  AffineElementCopyOut
        AFFINE-EQUALITY-UNSUPPORTED              AffineEqualityUnsupported
        AFFINE-ERASURE-UNSUPPORTED               AffineErasureUnsupported
        AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE   AffineFieldMoveRequiresDestructure
        AFFINE-GENERIC-NESTED-UNSUPPORTED        AffineGenericNestedUnsupported
        AFFINE-INSTANCE-BUDGET                   AffineInstanceBudget
        AFFINE-LIST-OPERATION-UNSUPPORTED        AffineListOperationUnsupported
        AFFINE-NOT-DEFINITELY-LIVE               AffineNotDefinitelyLive
        AFFINE-PATH-RELEASE-UNSUPPORTED          AffinePathReleaseUnsupported
        AFFINE-TEMPORARY-UNSUPPORTED             AffineTemporaryUnsupported
        AMBIGUOUS-CONTEXT-IMPLEMENTATION         AmbiguousContextImplementation
        AMBIGUOUS-METHOD-CALL                    AmbiguousMethodCall
        AMBIGUOUS-QUALIFIER                      AmbiguousQualifier
        ARITY                                    Arity
        BREAK-OUTSIDE-LOOP                       BreakOutsideLoop
        CONTEXT-BINDING-COLLISION                ContextBindingCollision
        CONTEXT-FUNCTION-VALUE                   ContextFunctionValue
        CONTEXT-INSTALLATION-UNSUPPORTED         ContextInstallationUnsupported
        CONTEXT-TRAIT-MISUSE                     ContextTraitMisuse
        CONTEXT-TRAIT-POSITION                   ContextTraitPosition
        CONTINUE-OUTSIDE-LOOP                    ContinueOutsideLoop
        COROUTINE-CONTRACT                       CoroutineContract
        COROUTINE-NOT-FUNCTION                   CoroutineNotFunction
        COROUTINE-RESULT-MISMATCH                CoroutineResultMismatch
        COROUTINE-RESUME-ARITY                   CoroutineResumeArity
        COROUTINE-RESUME-CONFLICT                CoroutineResumeConflict
        COROUTINE-RESUME-TYPE                    CoroutineResumeType
        COROUTINE-RESUME-UNDERCONSTRAINED        CoroutineResumeUnderconstrained
        COROUTINE-RHS-NOT-YIELDING               CoroutineRhsNotYielding
        DUPLICATE                                Duplicate
        DUPLICATE-CONTEXT-PARAMETER              DuplicateContextParameter
        DUPLICATE-FIELD                          DuplicateField
        DUPLICATE-FLAG                           DuplicateFlag
        DUPLICATE-FLAG-DECLARATION               DuplicateFlagDeclaration
        DUPLICATE-LOOP-VARIABLE                  DuplicateLoopVariable
        FLAG-BINDING-COLLISION                   FlagBindingCollision
        FLAG-CALLEE-UNKNOWN                      FlagCalleeUnknown
        FLAG-FUNCTION-VALUE                      FlagFunctionValue
        KNOWN-ERROR                              KnownError
        LOCKSTEP-UNEQUAL                         LockstepUnequal
        LOCKSTEP-UNPROVEN                        LockstepUnproven
        MISSING-CONTEXT                          MissingContext
        MISSING-ERROR-PAYLOAD                    MissingErrorPayload
        MISSING-FIELD                            MissingField
        MISSING-IMPORT                           MissingImport
        MODULE-CONTEXT                           ModuleContext
        MODULE-IMMUTABLE                         ModuleImmutable
        MUTABLE-PLACE-CAPTURE                    MutablePlaceCapture
        MUTABLE-PLACE-RECEIVER                   MutablePlaceReceiver
        NO-APPLICABLE-METHOD                     NoApplicableMethod
        NOMETHOD-CALL                            NomethodCall
        NOT-A-CONTEXT                            NotAContext
        NOT-A-STRUCT                             NotAStruct
        NOT-AN-ENUM                              NotAnEnum
        OPAQUE-CONSTRUCTION                      OpaqueConstruction
        OPAQUE-REPRESENTATION                    OpaqueRepresentation
        PROOF-CLAUSE                             ProofClause
        REFINEMENT-MINT-AUTHORITY                RefinementMintAuthority
        RETURN-OUTSIDE-CALLABLE                  ReturnOutsideCallable
        TRAIT-IMPL-ORDER                         TraitImplOrder
        TRAIT-INSTANCE-BUDGET                    TraitInstanceBudget
        TRAIT-NESTED-POLYMORPHIC                 TraitNestedPolymorphic
        TRAIT-NOT-SATISFIED                      TraitNotSatisfied
        TRAIT-POLYMORPHIC-FUNCTION-VALUE         TraitPolymorphicFunctionValue
        TRAIT-POLYMORPHIC-RECURSION              TraitPolymorphicRecursion
        TRAIT-STORAGE-UNSUPPORTED                TraitStorageUnsupported
        TRAIT-UNKNOWN-OPERATION                  TraitUnknownOperation
        TRAIT-VIEW-MISUSE                        TraitViewMisuse
        TRAIT-WITNESS-JOIN                       TraitWitnessJoin
        TYPE                                     Type
        UNBOUND                                  Unbound
        UNDECLARED-ERROR                         UndeclaredError
        UNEXPECTED-ERROR-PAYLOAD                 UnexpectedErrorPayload
        UNHANDLED-ERROR                          UnhandledError
        UNKNOWN-ENUM-CASE                        UnknownEnumCase
        UNKNOWN-FIELD                            UnknownField
        UNKNOWN-FLAG                             UnknownFlag
        UNKNOWN-NAMESPACE                        UnknownNamespace
        UNKNOWN-STRUCT                           UnknownStruct
        UNKNOWN-SYMBOL                           UnknownSymbol
        UNPROVEN-FIELD                           UnprovenField
        UNWRAPPED-YIELD                          UnwrappedYield
        USE-AFTER-MOVE                           UseAfterMove
        YIELD-OUTSIDE-FUNCTION                   YieldOutsideFunction
    }
    # The canonical identities the reification constructs (lib/compiler.bot).
    variable errorName compiler::CompilerError
    variable codeEnum compiler::DiagnosticCode
    variable locationStruct compiler::SourceLocation
}

# The static operations (surface/parser.tcl's staticOperations): the compiler's
# static-intrinsic vocabulary.
proc hir::static::operations {} {
    return {compile}
}

# The internal-kind -> DiagnosticCode-case table (see `codes` above).
proc hir::static::codes {} {
    variable codes
    return $codes
}

# The compiler::DiagnosticCode case of diagnostic KIND. A kind with no case is
# an internal compiler failure, never a default: the table is the public
# contract (tests/static-compile.test's census keeps it complete).
proc hir::static::CodeOf {kind} {
    variable codes
    if {![dict exists $codes $kind]} {
        error "internal compiler error: diagnostic kind \"$kind\" has no compiler::DiagnosticCode case (hir/static.tcl's codes, lib/compiler.bot)"
    }
    return [dict get $codes $kind]
}

# ---------------------------------------------------------------------------
# Sites

# 1 if the syntax NODES or any module section of MODULES holds a static node.
proc hir::static::present {nodes modules} {
    if {[HasStatic $nodes]} {
        return 1
    }
    foreach section $modules {
        if {[HasStatic [dict get $section nodes]]} {
            return 1
        }
    }
    return 0
}

proc hir::static::HasStatic {nodes} {
    foreach node $nodes {
        if {[dict get $node kind] eq "static"} {
            return 1
        }
        foreach child [Children $node] {
            if {[HasStatic [list $child]]} {
                return 1
            }
        }
    }
    return 0
}

# The direct child syntax nodes of NODE, in evaluation order.
proc hir::static::Children {node} {
    switch -- [dict get $node kind] {
        bind - ok - error {
            return [list [dict get $node value]]
        }
        return - break - fail {
            set value [dict get $node value]
            return [expr {$value eq "" ? {} : [list $value]}]
        }
        block - loop - static {
            return [dict get $node body]
        }
        call {
            return [concat [list [dict get $node callee]] [dict get $node args]]
        }
        if {
            return [concat [list [dict get $node condition]] [dict get $node thenBody] [dict get $node elseBody]]
        }
        listloop {
            return [concat [list [dict get $node iterable]] [dict get $node body]]
        }
        countloop {
            return [concat [list [dict get $node start] [dict get $node end]] [dict get $node body]]
        }
        lockloop {
            set children {}
            foreach domain [dict get $node domains] {
                foreach operand {iterable start end} {
                    if {[dict exists $domain $operand]} {
                        lappend children [dict get $domain $operand]
                    }
                }
            }
            return [concat $children [dict get $node body]]
        }
        handle {
            set children [list [dict get $node call]]
            foreach handler [dict get $node handlers] {
                lappend children {*}[dict get $handler body]
            }
            return $children
        }
        struct {
            return [lmap field [dict get $node fields] {dict get $field value}]
        }
        project {
            return [list [dict get $node receiver]]
        }
    }
    return {}
}

# The key of the static node NODE: FILE:START of its origin, unique per site.
proc hir::static::Key {node} {
    set origin [dict get $node origin]
    return "[dict get $origin file]:[dict get $origin start]"
}

# The static sites of the program (its module SECTIONS, then its own NODES), in
# post-order: a nested site before the site containing it, otherwise in
# source order. Each a dict {key origin bodyOrigin operation parent deferred}
# (PARENT the key of the site whose body holds it, "" for none).
proc hir::static::Sites {nodes modules} {
    set sites {}
    foreach section $modules {
        CollectSites [dict get $section nodes] "" sites
    }
    CollectSites $nodes "" sites
    return $sites
}

proc hir::static::CollectSites {nodes parent sitesVar} {
    upvar 1 $sitesVar sites
    foreach node $nodes {
        if {[dict get $node kind] eq "static"} {
            set key [Key $node]
            CollectSites [dict get $node body] $key sites
            lappend sites [dict create key $key origin [dict get $node origin] \
                bodyOrigin [dict get $node bodyOrigin] operation [dict get $node operation] \
                parent $parent deferred [dict get $node deferred]]
            continue
        }
        CollectSites [Children $node] $parent sites
    }
}

# ---------------------------------------------------------------------------
# Expansion: the syntax a round builds

# {NODES MODULES} with every static node replaced by its form under DECISIONS
# (key -> {accepted} or {rejected DIAGNOSTIC}; an undecided site is its body, as
# an accepted one is).
proc hir::static::Expand {nodes modules decisions} {
    set sections [lmap section $modules {
        dict set section nodes [Sequence [dict get $section nodes] $decisions]
        set section
    }]
    return [list [Sequence $nodes $decisions] $sections]
}

# The statement list NODES expanded: a static statement may become several
# statements (an accepted body spliced in place).
proc hir::static::Sequence {nodes decisions} {
    set result {}
    foreach node $nodes {
        if {[dict get $node kind] eq "static"} {
            lappend result {*}[Form $node $decisions statement]
            continue
        }
        lappend result [Node $node $decisions]
    }
    return $result
}

# The value node NODE expanded (a static node in a value position becomes one
# node).
proc hir::static::Value {node decisions} {
    if {$node eq ""} {
        return ""
    }
    if {[dict get $node kind] eq "static"} {
        return [lindex [Form $node $decisions value] 0]
    }
    return [Node $node $decisions]
}

# NODE (not itself static) with every static node below it expanded.
proc hir::static::Node {node decisions} {
    switch -- [dict get $node kind] {
        bind - ok - error {
            dict set node value [Value [dict get $node value] $decisions]
        }
        return - break - fail {
            dict set node value [Value [dict get $node value] $decisions]
        }
        block - loop {
            dict set node body [Sequence [dict get $node body] $decisions]
        }
        call {
            dict set node callee [Value [dict get $node callee] $decisions]
            dict set node args [lmap arg [dict get $node args] {Value $arg $decisions}]
        }
        if {
            dict set node condition [Value [dict get $node condition] $decisions]
            dict set node thenBody [Sequence [dict get $node thenBody] $decisions]
            dict set node elseBody [Sequence [dict get $node elseBody] $decisions]
        }
        listloop {
            dict set node iterable [Value [dict get $node iterable] $decisions]
            dict set node body [Sequence [dict get $node body] $decisions]
        }
        countloop {
            dict set node start [Value [dict get $node start] $decisions]
            dict set node end [Value [dict get $node end] $decisions]
            dict set node body [Sequence [dict get $node body] $decisions]
        }
        lockloop {
            dict set node domains [lmap domain [dict get $node domains] {
                foreach operand {iterable start end} {
                    if {[dict exists $domain $operand]} {
                        dict set domain $operand [Value [dict get $domain $operand] $decisions]
                    }
                }
                set domain
            }]
            dict set node body [Sequence [dict get $node body] $decisions]
        }
        handle {
            dict set node call [Value [dict get $node call] $decisions]
            dict set node handlers [lmap handler [dict get $node handlers] {
                dict set handler body [Sequence [dict get $handler body] $decisions]
                set handler
            }]
        }
        struct {
            dict set node fields [lmap field [dict get $node fields] {
                dict set field value [Value [dict get $field value] $decisions]
                set field
            }]
        }
        project {
            dict set node receiver [Value [dict get $node receiver] $decisions]
        }
    }
    return $node
}

# The nodes the static node NODE becomes under DECISIONS, in a statement
# position (POSITION statement: any number of statements) or a value
# position (value: exactly one node).
proc hir::static::Form {node decisions position} {
    set key [Key $node]
    if {[dict exists $decisions $key] && [lindex [dict get $decisions $key] 0] eq "rejected"} {
        return [list [Reified $node [lindex [dict get $decisions $key] 1]]]
    }
    return [Accepted $node [Sequence [dict get $node body] $decisions] $position]
}

# An accepted (or undecided) site NODE whose expanded body is BODY: the body
# itself where that is exactly the ordinary block -- it binds nothing in its
# own scope, so there is nothing for a block to scope, and in a value
# position it is one expression -- else the body as the then-branch of an
# `if` on the root `true`, the ordinary block (`if true:`) that scopes what it
# binds. Neither form is marked: an accepted site is ordinary syntax.
proc hir::static::Accepted {node body position} {
    if {[hir::syntax::scopeBindNames $body] eq {}} {
        if {$position eq "statement"} {
            return $body
        }
        if {[llength $body] == 1
                && [dict get [lindex $body 0] kind] in {const ref call struct project if handle loop listloop countloop lockloop ok error}} {
            return $body
        }
    }
    set origin [dict get $node origin]
    set bodyOrigin [dict get $node bodyOrigin]
    return [list [hir::syntax::ifNode $origin [hir::syntax::rootRef [Role $origin block] true] \
        $bodyOrigin $body [Role $origin else] {}]]
}

# ORIGIN with the node id role ROLE appended (surface/lower.tcl's convention
# for nodes a rule adds).
proc hir::static::Role {origin role} {
    if {[dict exists $origin node]} {
        dict set origin node "[dict get $origin node]/$role"
    }
    return $origin
}

# ---------------------------------------------------------------------------
# Reification: a rejected site's ordinary failure

# The `fail compiler::CompilerError {...}` node a rejected site NODE becomes,
# reifying DIAGNOSTIC ({kind message origin related}: ORIGIN the primary
# location, RELATED a list of origins). Every constructed value is an
# ordinary literal or construction of lib/compiler.bot's declarations, by
# their canonical identities (the file imports `compiler`: surface/
# modules.tcl requires it of every file using a static intrinsic). The node
# carries `static {operation OPERATION kind KIND}`: provenance, read by
# KNOWN-ERROR, SAME-FAILURE, the UNHANDLED-ERROR wording and HIR text only.
proc hir::static::Reified {node diagnostic} {
    variable errorName
    variable codeEnum
    set origin [Role [dict get $node origin] reified]
    set kind [dict get $diagnostic kind]
    set code [hir::syntax::constNode $origin enum [list $codeEnum [CodeOf $kind]]]
    set primary [Location $origin [dict get $diagnostic origin]]
    set related [hir::syntax::withWritten [hir::syntax::callNode $origin \
        [hir::syntax::rootRef $origin list] \
        {*}[lmap r [dict get $diagnostic related] {Location $origin $r}]] list]
    set message [hir::syntax::constNode $origin str [dict get $diagnostic message]]
    set fields {}
    foreach {name value} [list code $code primary $primary related $related message $message] {
        lappend fields [dict create name $name nameOrigin $origin origin $origin value $value]
    }
    set payload [hir::syntax::structNode $origin "" $fields]
    dict set payload payloadOf $errorName
    set fail [hir::syntax::failNode $origin $errorName $payload]
    dict set fail static [dict create operation [dict get $node operation] kind $kind]
    return $fail
}

# A compiler::SourceLocation construction (at ORIGIN) of the source location
# AT: its line and column in its own file.
proc hir::static::Location {origin at} {
    variable locationStruct
    set fields {}
    foreach name {line column} {
        lappend fields [dict create name $name nameOrigin $origin origin $origin \
            value [hir::syntax::constNode $origin [dict get $at $name]]]
    }
    return [hir::syntax::structNode $origin [dict create id $locationStruct] $fields]
}

# ---------------------------------------------------------------------------
# Deciding

# hir::buildSyntax for a program with static sites (NODES, the options
# OPTIONS/GIVEN as there, HALT whether the caller stops after resolution
# errors): the rounds of this file's header, then the final program -- built
# with the caller's HALT -- with its decisions in `staticSites` (key -> {key
# origin operation outcome accepted|rejected diagnostic D}, D the reified
# diagnostic) and the number of builds they took in `staticRounds`.
proc hir::static::decide {nodes options given halt} {
    set modules [dict get $options -modules]
    set sites [Sites $nodes $modules]
    set decisions [dict create]
    foreach site $sites {
        set deferred [dict get $site deferred]
        if {$deferred ne {}} {
            # The loader's diagnostic precedes every HIR diagnostic of the
            # same code: the site is rejected before any build.
            set first [lindex $deferred 0]
            dict set decisions [dict get $site key] [list rejected \
                [dict create kind [dict get $first kind] message [dict get $first message] \
                    origin [dict get $first origin] related {}]]
        }
    }
    set rounds 0
    while 1 {
        incr rounds
        set hir [Round $nodes $options $given $decisions 1 checked]
        set own [Attribute $hir $sites $decisions]
        set outer [dict get $own ""]
        dict unset own ""
        if {!$checked} {
            # Stopped after resolution: every site with a resolution
            # diagnostic of its own is rejected (resolution is lexical).
            if {[dict size $own] == 0} {
                # Only the enclosing program's own: it is rejected whatever
                # the sites would be.
                break
            }
            dict for {key diagnostics} $own {
                dict set decisions $key [list rejected [lindex $diagnostics 0]]
            }
            continue
        }
        set failing {}
        foreach site $sites {
            if {[dict exists $own [dict get $site key]]} {
                lappend failing $site
            }
        }
        foreach site $sites {
            set key [dict get $site key]
            if {$failing ne {} && $key eq [dict get [lindex $failing 0] key]} break
            if {![dict exists $decisions $key]} {
                dict set decisions $key accepted
            }
        }
        if {$failing eq {}} {
            break
        }
        foreach key [Rejectable $hir $failing] {
            dict set decisions $key [list rejected [lindex [dict get $own $key] 0]]
        }
    }
    if {!$halt && !$checked} {
        # The caller keeps the diagnostics of a program that does not
        # resolve and analyzes it anyway: build the decided program its way.
        set hir [Round $nodes $options $given $decisions 0 checked]
        incr rounds
    }
    set summary [dict create]
    foreach site $sites {
        set key [dict get $site key]
        set decision [expr {[dict exists $decisions $key] ? [dict get $decisions $key] : "undecided"}]
        set entry [dict create key $key origin [dict get $site origin] \
            operation [dict get $site operation] outcome [lindex $decision 0]]
        if {[lindex $decision 0] eq "rejected"} {
            dict set entry diagnostic [lindex $decision 1]
        }
        dict set summary $key $entry
    }
    dict set hir staticSites $summary
    dict set hir staticRounds $rounds
    return $hir
}

# The keys of the sites of FAILING (the sites with a diagnostic of their own
# in HIR, a typed build, in post-order) this round rejects: the first, whose
# earlier sites all have their final forms -- and every other one that no
# other site of FAILING can have caused its diagnostic (Independent): its
# diagnostic stays when the others are rejected, so it is decided now rather
# than one build later. Without that proof, sites are decided one per round.
proc hir::static::Rejectable {hir failing} {
    set keys [list [dict get [lindex $failing 0] key]]
    if {[llength $failing] < 2 || [GlobalChannels $hir]} {
        return $keys
    }
    set units [Units $hir]
    foreach y [lrange $failing 1 end] {
        set alone 1
        foreach z $failing {
            if {$z eq $y} continue
            if {![Independent $hir $units $y $z]} {
                set alone 0
                break
            }
        }
        if {$alone} {
            lappend keys [dict get $y key]
        }
    }
    return $keys
}

# 1 if a site's body in HIR can change what the compiler concludes about code
# anywhere, whatever calls what: a call that violates a trusted inferred
# contract (the contract is demoted for every call, hir::check), or a
# callable with declared errors passed into an untyped parameter (the
# erased-callable contract charges every unidentified call,
# hir/completions.tcl). In such a build no site is proven independent.
proc hir::static::GlobalChannels {hir} {
    if {[dict exists $hir demotedContracts] && [dict get $hir demotedContracts] ne {}} {
        return 1
    }
    return [expr {[hir::completions::erasedErrorsOf $hir] ne {}}]
}

# 1 if the body of site Z cannot have caused a diagnostic in the body of site
# Y in HIR, by the program's units (Units): Y and Z lie in different units,
# and neither unit reaches the other through the references of the program
# -- Y's unit uses nothing whose analysis Z's body takes part in, and Z's unit
# calls into nothing of Y's. A unit is a top-level function definition (with
# everything nested in it: its body runs in sequence, so its sites see each
# other's effects), or the top-level code of one module section or of the
# entry program (all of it: it runs in sequence too). Neither site may hold
# the other.
proc hir::static::Independent {hir units y z} {
    set uy [UnitOf $units $y]
    set uz [UnitOf $units $z]
    if {$uy eq "" || $uz eq "" || $uy eq $uz} {
        return 0
    }
    set reach [dict get $units reach]
    return [expr {$uz ni [dict get $reach $uy] && $uy ni [dict get $reach $uz]}]
}

# The units of HIR (Independent): {roots {UNIT {FILE START END} ...} reach
# {UNIT {UNIT ...} ...}}, UNIT a root ExprId (a top-level function
# definition) or code:SCOPE (the rest of the top level of that section's
# scope), REACH the units each unit's code transitively refers to.
proc hir::static::Units {hir} {
    set unitOfBinding [dict create]
    set rootsOf [dict create]
    set spans {}
    foreach r [dict get $hir roots] {
        set node [dict get $hir exprs $r]
        set unit "code:[dict get $node scope]"
        if {[dict get $node kind] eq "bind" && [dict get $hir exprs [dict get $node value] kind] eq "block"} {
            set unit $r
        }
        if {[dict get $node kind] eq "bind" && [dict get $node binding] ne ""} {
            dict set unitOfBinding [dict get $node binding] $unit
        }
        dict lappend rootsOf $unit $r
        set origin [dict get $node origin]
        if {[lindex $origin 0] eq "file"} {
            lappend spans [list $unit [dict get $origin file] [dict get $origin start] [dict get $origin end]]
        }
    }
    set uses [dict create]
    dict for {unit roots} $rootsOf {
        set used [dict create]
        set stack $roots
        while {$stack ne {}} {
            set e [lindex $stack end]
            set stack [lrange $stack 0 end-1]
            set node [dict get $hir exprs $e]
            if {[dict get $node kind] eq "ref" && [dict get $node binding] ne ""
                    && [dict exists $unitOfBinding [dict get $node binding]]} {
                dict set used [dict get $unitOfBinding [dict get $node binding]] 1
            }
            lappend stack {*}[hir::children $hir $e]
        }
        dict set uses $unit [dict keys $used]
    }
    set reach [dict create]
    dict for {unit _} $rootsOf {
        set seen [dict create]
        set stack [dict get $uses $unit]
        while {$stack ne {}} {
            set u [lindex $stack end]
            set stack [lrange $stack 0 end-1]
            if {[dict exists $seen $u]} continue
            dict set seen $u 1
            if {[dict exists $uses $u]} {
                lappend stack {*}[dict get $uses $u]
            }
        }
        dict set reach $unit [dict keys $seen]
    }
    return [dict create spans $spans reach $reach]
}

# The unit (Units) site SITE belongs to: the top-level definition or code
# whose source span holds the site, else the one its body's code lies in;
# "" if none is found (never independent).
proc hir::static::UnitOf {units site} {
    set origin [dict get $site origin]
    set file [dict get $origin file]
    set start [dict get $origin start]
    set end [dict get $origin end]
    foreach span [dict get $units spans] {
        lassign $span unit f from to
        if {$f eq $file && $start >= $from && $start <= $to} {
            return $unit
        }
    }
    foreach span [dict get $units spans] {
        lassign $span unit f from to
        if {$f eq $file && $from >= $start && $from <= $end} {
            return $unit
        }
    }
    return ""
}

# One build of the program under DECISIONS: hir::BuildFull of the expanded
# syntax, stopping after resolution errors when HALT. Sets CHECKEDVAR to
# whether the static checks ran.
proc hir::static::Round {nodes options given decisions halt checkedVar} {
    upvar 1 $checkedVar checked
    lassign [Expand $nodes [dict get $options -modules] $decisions] nodes modules
    dict set options -modules $modules
    if {[dict exists $given -modules]} {
        dict set given -modules $modules
    }
    return [hir::BuildFull $nodes $options $given $halt checked]
}

# The diagnostics of HIR (one build) by owner: a dict key -> its diagnostics
# in list order, each {kind message origin related}, for every site whose
# body (present in this build: not rejected under DECISIONS) holds the
# diagnostic's primary location innermost; key "" holds the enclosing
# program's own.
proc hir::static::Attribute {hir sites decisions} {
    set present {}
    foreach site $sites {
        set key [dict get $site key]
        if {[dict exists $decisions $key] && [lindex [dict get $decisions $key] 0] eq "rejected"} continue
        lappend present $site
    }
    set owners [dict create "" {}]
    foreach diagnostic [dict get $hir diagnostics] {
        set origin [PrimaryOrigin $hir $diagnostic]
        set owner [Owner $present $origin]
        if {[Internal $diagnostic]} {
            # A failure of the compiler is never a block's rejection: it
            # stays the program's, and fails the compilation loudly.
            set owner ""
        }
        set related [expr {[dict exists $diagnostic related] ? [dict get $diagnostic related] : {}}]
        dict lappend owners $owner [dict create kind [dict get $diagnostic kind] \
            message [dict get $diagnostic message] origin $origin related $related]
    }
    return $owners
}

# 1 if DIAGNOSTIC reports a failure of the compiler rather than of the code:
# an internal invariant (the *-INTERNAL kinds) or a problem found in the
# monomorphized program, which is the checked program with every trait
# resolved (hir/traits.tcl marks those `internal`).
proc hir::static::Internal {diagnostic} {
    return [expr {[dict exists $diagnostic internal]
        || [string match *-INTERNAL [dict get $diagnostic kind]]}]
}

# The primary location of DIAGNOSTIC in HIR: the origin a strict compile
# reports it at (surface::lower::Finish).
proc hir::static::PrimaryOrigin {hir diagnostic} {
    if {[dict exists $diagnostic origin]} {
        return [dict get $diagnostic origin]
    }
    set e [dict get $diagnostic expr]
    if {$e eq "" || ![dict exists $hir exprs $e]} {
        return ""
    }
    return [hir::get $hir $e origin]
}

# The key of the innermost site of SITES whose body holds the source location
# ORIGIN, or "" (the enclosing program's).
proc hir::static::Owner {sites origin} {
    if {[lindex $origin 0] ne "file"} {
        return ""
    }
    set file [lindex $origin 1]
    set at [dict get [lrange $origin 2 end] start]
    set owner ""
    set best -1
    foreach site $sites {
        set body [dict get $site bodyOrigin]
        if {[lindex $body 1] ne $file} continue
        set span [lrange $body 2 end]
        set start [dict get $span start]
        if {$at >= $start && $at <= [dict get $span end] && $start > $best} {
            set owner [dict get $site key]
            set best $start
        }
    }
    return $owner
}

# ---------------------------------------------------------------------------
# Queries

# The static sites of the built HIR and their decisions (hir::static::decide's
# `staticSites`), {} for a program without any.
proc hir::static::sites {hir} {
    return [expr {[dict exists $hir staticSites] ? [dict get $hir staticSites] : {}}]
}
