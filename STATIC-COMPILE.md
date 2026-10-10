# STATIC-COMPILE.md

`static compile:` -- Botlish's first static intrinsic: a recoverable
semantic-compilation boundary around a parser-valid block.

> `static compile:` creates a recoverable semantic-compilation boundary
> around a parser-valid Botlish block. If the block compiles, it executes
> with its ordinary value and error semantics and the boundary has no
> runtime representation. If semantic compilation rejects the block, the
> diagnostic is reified as `compiler::CompilerError` and the block is not
> executed.
>
> Parser errors are not captured by `static compile:`. A future lower-level
> `static parse:` may provide that boundary.
>
> `static compile:` is not an assertion. Testing policy belongs to the test
> framework.

```botlish
import compiler

fn probe() -> int errors compiler::CompilerError:
    static compile:
        missing

r = probe():
    on compiler::CompilerError {code, primary}:
        if code == compiler::DiagnosticCode::Unbound:
            primary.line * 1000 + primary.column
        else:
            0
r            # 5009: `missing` is at line 5, column 9
```

The three programs of the brief's success criterion (item 102), on the Tcl
interpreter, the Tcl compiler and Cranelift with and without
specialization (`tests/static-compile.test`):

| block | the compiler | at run time |
|---|---|---|
| `missing` | rejects it: the enclosing program compiles | `compiler::CompilerError {code: compiler::DiagnosticCode::Unbound, primary: compiler::SourceLocation {line: 4, column: 9}, related: [], message: "unbound name \"missing\""}` (`sc-negative-unbound`) |
| `list::at(xs, i)` | accepts it | `IndexNotFound` when `i` is out of range, never CompilerError (`sc-success-runtime-error`) |
| `20 + 22` | accepts it | `42`, as without the boundary (`sc-success-value`) |

(`list::at([], 0)` itself, the brief's literal example, is a block the
compiler *rejects*: the completion proofs see the empty List and the
constant index, so the call is the ordinary KNOWN-ERROR, reified as code
`KnownError` -- `sc-list-at-empty-is-known-error`. A run-time failure needs an
index the compiler cannot decide.)

## Contents

* [The construct](#the-construct)
* [How it works](#how-it-works)
* [The compiler namespace](#the-compiler-namespace)
* [Diagnostic-code census](#diagnostic-code-census)
* [Report](#report) -- the 60 points of the milestone report, in order
* [Performance](#performance)
* [Files](#files)
* [What to run when changing this](#what-to-run-when-changing-this)

## The construct

```
staticIntrinsic = "static" IDENT ":" suite        -- surface/parser.tcl
valued          = IDENT "=" (if | loop | staticIntrinsic | handledExpr)
                | "return" (if | loop | staticIntrinsic | handledExpr)
simple          = ... | staticIntrinsic | expression
```

A static intrinsic is a statement, or the value of a binding, a `return` or a
struct destructuring -- the positions an `if` takes. Its body is an ordinary
suite. The operation name after `static` is one of the compiler's static
operations (only `compile`); it is compiler syntax, never looked up in a
scope. `static` and `compile` are contextual: the form is recognized only as
the word `static` directly followed by a name where a statement or a
statement's value starts -- two adjacent names, which no other construct
allows -- so `static = 3`, `static(x)`, `x.static`, `compile = f` and
`compile(x)` are ordinary code, and `static compile:` means the same whatever
the program binds.

A file that uses a static intrinsic imports `compiler` (`import compiler`):
a rejected block completes with `compiler::CompilerError`, an ordinary
namespaced declaration, and Botlish has no implicit imports. Without it the
loader reports `MISSING-IMPORT` at the `static` keyword.

## How it works

`static compile:` is processed after parsing and before resolution, by
`hir/static.tcl` (its header has the whole design):

1. The parser builds a `static` AST node (operation, captured suite).
   `surface/lower.tcl` lowers the suite to ordinary `hir/syntax.tcl` nodes --
   the same nodes, with the same origins, it would lower anywhere -- under a
   `static` syntax node. The loader (`surface/modules.tcl`) checks every
   qualified reference as always, except that a reference inside a static
   block that the file may not make (`MISSING-IMPORT`, `UNKNOWN-NAMESPACE`,
   `UNKNOWN-SYMBOL`, `NOT-AN-ENUM`, `NOT-A-STRUCT`, `AMBIGUOUS-QUALIFIER`) is
   recorded on that block's node (`deferred`) instead of failing the file.
2. `hir::buildSyntax` sees static nodes and calls `hir::static::decide`.
   Each round *expands* the syntax -- every static node replaced by its
   current form -- and builds the whole program with the ordinary pipeline
   (`hir::BuildFull`: resolution, hygiene, every check, method-call
   decisions, the trait monomorphization, the elaborations). Nothing raises
   during a build: diagnostics are data. Each diagnostic belongs to the
   innermost static block whose body holds its primary location, or to the
   enclosing program.
3. The rounds decide every site: a block with a loader diagnostic is
   rejected at once; a round that stopped after resolution rejects every
   block with a resolution diagnostic of its own (resolution is lexical);
   otherwise the first block in post-order with a diagnostic of its own is
   rejected -- together with every other failing block no other failing
   block can have influenced (different top-level units that do not reach
   each other, no program-wide contract in play) -- and the blocks before it
   are accepted. A round in which no block has a diagnostic of its own is the
   final program.
4. An *accepted* block is its body: spliced in place when it binds nothing
   in its own scope (and is one expression in a value position), else the
   then-branch of an `if` on the root `true` -- exactly the `if true:` block
   that scopes what it binds. A *rejected* block is
   `fail compiler::CompilerError {code, primary, related, message}`, built
   from the diagnostic, marked `static {operation compile kind KIND}`.
5. The final program's own diagnostics (none in an accepted body, by
   construction) are its diagnostics, raised by the frontend as for any
   program; warnings run on it as on any program.

Every build is a fresh, pure value: HIR is persistent dicts, and the
per-compilation registries (structs, enums, errors, traits, imports) are
rebuilt from the same top-level declarations by every build. A rejected
body's bindings, moves, refinements, semantic instances, summaries and
method candidates existed only in a build that is discarded: that is the
transaction and its rollback.

## The compiler namespace

`lib/compiler.bot`, ordinary Botlish:

```botlish
enum DiagnosticCode:
    AffineCaptureUnsupported,
    ...                       # 87 cases, one per recoverable diagnostic kind
    YieldOutsideFunction

struct SourceLocation:
    line: int
    column: int

error CompilerError:
    code: DiagnosticCode
    primary: SourceLocation
    related: List[SourceLocation]
    message: str
```

The compiler's one privilege is constructing these values from its own
diagnostic (`hir::static::Reified`): `code` is the case of the diagnostic's
kind (`hir::static::codes`, an explicit table: `UNBOUND` is `Unbound`,
`USE-AFTER-MOVE` is `UseAfterMove`, one case per kind and one kind per case,
the Botlish enum spelling of the kind); `primary` is the line and column a
strict compile reports it at, in the file the block is written in; `related`
the further locations the diagnostic names, in the order its message names
them (a used value's move, for `USE-AFTER-MOVE` and
`AFFINE-NOT-DEFINITELY-LIVE`; `[]` for every other kind today); `message` the
ordinary message, without its location prefix -- for reading, never the
identity to compare (compare `code`). Everything after that is ordinary:
the payload is an ordinary anonymous struct, transported field-wise in the
native payload slots, bound and destructured by ordinary handlers, rendered
by the ordinary renderer (`<error compiler::CompilerError {code: ...}>` when
uncaught under `-strict 0`).

There is one error, not one per diagnostic: what happened at the level of
control flow is that compilation rejected the block; which diagnostic did is
`code`.

## Diagnostic-code census

Every error diagnostic kind the front end can report, classified
(`tests/static-compile.test`'s `sc-census-exhaustive` holds the
classification and fails on any new, unclassified kind token in `hir/*.tcl`
or `surface/modules.tcl`; `sc-codes-one-to-one` holds the table against the
enum):

| class | kinds | a `CompilerError` code? |
|---|---|---|
| semantic / HIR (resolution, types, structs, flags, method calls, enums, refinements) | UNBOUND, DUPLICATE, TYPE, ARITY (flags, syscalls), BREAK-OUTSIDE-LOOP, CONTINUE-OUTSIDE-LOOP, RETURN-OUTSIDE-CALLABLE (a top-level block), DUPLICATE-FIELD, DUPLICATE-FLAG, DUPLICATE-FLAG-DECLARATION, DUPLICATE-LOOP-VARIABLE, FLAG-BINDING-COLLISION, FLAG-CALLEE-UNKNOWN, FLAG-FUNCTION-VALUE, UNKNOWN-FLAG, LOCKSTEP-UNEQUAL, LOCKSTEP-UNPROVEN, NOMETHOD-CALL, AMBIGUOUS-METHOD-CALL, NO-APPLICABLE-METHOD, NOT-A-STRUCT, UNKNOWN-FIELD, UNKNOWN-STRUCT, MISSING-FIELD, UNPROVEN-FIELD, UNKNOWN-ENUM-CASE, PROOF-CLAUSE, REFINEMENT-MINT-AUTHORITY, OPAQUE-CONSTRUCTION, OPAQUE-REPRESENTATION | yes |
| ownership (affine, coroutines, mutable places) | USE-AFTER-MOVE, AFFINE-NOT-DEFINITELY-LIVE, AFFINE-CAPTURE-UNSUPPORTED, AFFINE-CONTAINER-UNSUPPORTED, AFFINE-DUPLICATION-UNSUPPORTED, AFFINE-ELEMENT-COPY-OUT, AFFINE-EQUALITY-UNSUPPORTED, AFFINE-ERASURE-UNSUPPORTED, AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE, AFFINE-GENERIC-NESTED-UNSUPPORTED, AFFINE-INSTANCE-BUDGET, AFFINE-LIST-OPERATION-UNSUPPORTED, AFFINE-PATH-RELEASE-UNSUPPORTED, AFFINE-TEMPORARY-UNSUPPORTED, MUTABLE-PLACE-CAPTURE, MUTABLE-PLACE-RECEIVER, COROUTINE-CONTRACT, COROUTINE-NOT-FUNCTION, COROUTINE-RESULT-MISMATCH, COROUTINE-RESUME-ARITY, COROUTINE-RESUME-CONFLICT, COROUTINE-RESUME-TYPE, COROUTINE-RESUME-UNDERCONSTRAINED, COROUTINE-RHS-NOT-YIELDING, UNWRAPPED-YIELD, YIELD-OUTSIDE-FUNCTION (a top-level block) | yes |
| completion | UNHANDLED-ERROR, KNOWN-ERROR, UNDECLARED-ERROR, MISSING-ERROR-PAYLOAD, UNEXPECTED-ERROR-PAYLOAD | yes |
| module / context / trait | MISSING-CONTEXT, AMBIGUOUS-CONTEXT-IMPLEMENTATION, CONTEXT-BINDING-COLLISION, CONTEXT-FUNCTION-VALUE, CONTEXT-INSTALLATION-UNSUPPORTED, CONTEXT-TRAIT-MISUSE, CONTEXT-TRAIT-POSITION, DUPLICATE-CONTEXT-PARAMETER, NOT-A-CONTEXT, MODULE-CONTEXT, MODULE-IMMUTABLE, TRAIT-IMPL-ORDER, TRAIT-INSTANCE-BUDGET, TRAIT-NESTED-POLYMORPHIC, TRAIT-NOT-SATISFIED, TRAIT-POLYMORPHIC-FUNCTION-VALUE, TRAIT-POLYMORPHIC-RECURSION, TRAIT-STORAGE-UNSUPPORTED, TRAIT-UNKNOWN-OPERATION, TRAIT-VIEW-MISUSE, TRAIT-WITNESS-JOIN | yes |
| loader, a qualified reference in a block | MISSING-IMPORT, UNKNOWN-NAMESPACE, UNKNOWN-SYMBOL, NOT-AN-ENUM, NOT-A-STRUCT, AMBIGUOUS-QUALIFIER | yes (deferred, step 1) |
| loader, header only | CYCLE, DUPLICATE-IMPORT, DUPLICATE-NATIVE, INVALID-TOPLEVEL, NOT-A-TYPE, SELF-IMPORT, TYPE-IMPORT-COLLISION | no: a block has no header |
| declaration (top level only: a block cannot declare a type, struct, enum, error or trait) | CYCLIC-REFINEMENT, REFINEMENT-CARRIER, TRAIT-DUPLICATE-REQUIREMENT, TRAIT-NAME-COLLISION, TRAIT-OTHER-TRAIT, TRAIT-REQUIREMENT-RECEIVER, TRAIT-SELF-POSITION, ENUM-EMPTY | no |
| top-level installation only | CONTEXT-TYPE-NOT-EXACT, DUPLICATE-CONTEXT | no: an installation in a block is CONTEXT-INSTALLATION-UNSUPPORTED |
| not from source | LISTLOOP-BREAK-VALUE (core IR / HIR text only) | no |
| parser | SURFACE SYNTAX, with codes (STATIC-INTRINSIC-FORM, STATIC-UNKNOWN-OPERATION, LIST-DESTRUCTURING, ...) | no: the enclosing program's parse error |
| run time only | NOT-BOOLEAN, NOT-CALLABLE, a plain call's ARITY, a native's argument TYPE (`1 + "x"`) | no: the block is accepted and fails at run time |
| internal | CONTEXT-TRAIT-INTERNAL, TRAIT-INTERNAL, a monomorphized-program diagnostic (`internal 1`), CORE MALFORMED, Tcl errors | never: fails the compilation |
| warnings | SAME-RETURN-VALUE, METHOD-ELIGIBLE, FIXED-ARITY-LIST-RETURN, SAME-FAILURE, PROVES-NAMING, ONE-CHAR-STRING-LITERAL, MANY-BOOLEAN-ARGUMENTS | never |

A few kinds are *anchored outside* the block that causes them, by the
ordinary compiler's own convention, and are therefore the enclosing
program's diagnostics, not the block's: `MISSING-CONTEXT` (at the top-level
call of the function needing the context), a semantic instance's derived
"call to F with x : T is invalid" (at the call), a violated inferred
parameter contract (at the call), the call form of `UNWRAPPED-YIELD`, and a
function's declared result not proven (at the enclosing function's
literal). The block compiles; the program using it does not.

## Report

### 1. Exact grammar

`staticIntrinsic = "static" IDENT ":" suite`, in statement position and as
the value of a binding, `return` or destructuring (`surface/parser.tcl`'s
grammar header; `AtStatic`, `StaticIntrinsic`, `ValueOrHandled`). The suite
is the ordinary one: `static compile:`, a new line, an indented block.
Never an operand or an argument (`x = 1 + static compile:` and `f(static
compile: ...)` are syntax errors, `sc-grammar-not-an-expression`).

### 2. Contextual-keyword behavior

Neither word is a lexer keyword. `static NAME` -- two adjacent names, never a
valid expression -- at a statement start or a statement's value starts the
form; everything else is an ordinary name (`sc-grammar-contextual`: a
function named `compile`, a binding `static`, parameters and fields named
`static` and `compile`, and a `static compile:` among them). The operation
is compiler vocabulary: a program-bound `compile` does not change it, and
`static unknown:` is `STATIC-UNKNOWN-OPERATION` even when the program
defines `unknown` (`sc-grammar-unknown-operation`). Malformed forms are
`STATIC-INTRINSIC-FORM` (arguments, no colon, a body on the colon's line,
`static:`), a missing block is the ordinary suite error
(`sc-grammar-malformed`).

### 3. AST representation

`static` node: `operation`, `operationSpan`, `staticSpan`, `body` (a
suite) -- a static intrinsic, not an assertion node. A future `static parse:`
is one more word in `staticOperations` and one more meaning in
`hir/static.tcl`, never a new node kind. Its syntax node (`hir/syntax.tcl`'s
`staticNode`): `operation`, `operationOrigin`, `bodyOrigin`, `body` (syntax
nodes), `deferred` (loader diagnostics).

### 4. Phase

After parsing and loading, before resolution: `hir::buildSyntax` hands a
program with static nodes to `hir::static::decide`, whose rounds each expand
the syntax and run the whole ordinary build (`hir::BuildFull`). Before any
backend: the decided program is ordinary HIR.

### 5. How the outer traversal skips the body

No pass ever sees a static node: `hir::static::Expand` replaces each one by
its form before resolution, every round. An undecided block's body is
resolved in its trial build, but the diagnostics it gets there are recorded
data, attributed to it, never raised; a rejected block's body is not in the
next build at all. The loader, which runs before HIR exists, defers its
diagnostics for references in static blocks (step 1 above).

### 6. Lexical and module environment

The body is expanded where it is written, so it is resolved in its own
lexical scope chain, its file's namespace and imports, with no copy or
re-parse (`sc-positive-lexical`: a parameter, its declared type, an earlier
function, an imported namespace).

### 7. Facts that cross into the body

All of them: the body is compiled by the one compiler in the program it
stands in -- types, ranges, refinements (`sc-tx-refinement`: a validator's
fact), ownership state, contexts, method candidates, semantic instances,
callable contracts. Nothing is erased at the boundary.

### 8. Transaction / rollback mechanism

A build is a pure value; a decision keeps the build's verdict and discards
the build. Persistent state was audited: the registries a build fills
(`hir::structs`, `hir::enums`, `hir::errordecls`, `hir::traits`,
`hir::imports`, `hir::sourcetypes`) are reset and refilled from the same
top-level declarations by every build; the per-pass caches
(`hir::completions::cache`, `hir::contexts::traitCache`, `hir::semantic`'s
and `hir::affine`'s working state, `hir::mutvec`'s per-pass tables) are reset
by the pass that uses them; `surface::modules::parsed` is keyed by a file's
text (pure); the native lowering's caches live past the HIR. Nothing persists
from one round's body to the next round.

### 9. Bindings and declarations

A rejected body's bindings and functions do not exist after it: the outer
scope may bind the same names (`sc-tx-binding-no-export`), a function it
declared is neither a binding nor a method-call candidate (`sc-tx-callable`:
`twice(1)` is UNBOUND, `3.twice()` finds no candidate). An accepted body's
bindings are scoped to its block, as an `if true:` block's
(`sc-tx-scope`). A static block cannot declare a type, struct, enum, error or
trait (declarations are top-level only: a parse error, as in any block,
`sc-grammar-body-parse-error`), so no declaration registry is involved.

### 10. Affine rollback

A rejected block that moved an outer coroutine leaves it unmoved: the code
after it resumes it, at compile time and at run time (`sc-affine-rollback`:
`[5, -2]` -- 5 from the handle used after the skipped block, -2 from the
block's UseAfterMove); a later block that uses the value is judged after the
earlier block's rejection and accepted (`sc-affine-rollback-next-block`);
an accepted block's move is the ordinary block's (`sc-affine-accepted-moves`:
the outer use after it is USE-AFTER-MOVE).

### 11. Refinement and context rollback

A validator's refinement made inside a rejected block does not reach the
code after it (`need(n)` is TYPE), while an accepted block's does, exactly
as an `if true:` block's (`sc-tx-refinement`). A `with context` inside a block
is the nested-scope installation it is in any block
(CONTEXT-INSTALLATION-UNSUPPORTED, reified), and the rest of the program
does not see an installation (`sc-tx-context`: MISSING-CONTEXT). A semantic
instance created only by a rejected body is not in the program, one created
by an accepted body is (`sc-tx-instance`: `int` against `int str`). A nested
callable: item 9.

### 12. Caches and specialization

Item 8's audit: every cache that may hold an entry created during a trial
build is per build or per pass, or keyed by pure inputs; the specializer and
the native lowering run only on the final HIR. `sc-tx-deterministic`: a
block's decision is the same alone and after four rejected blocks that each
moved and failed.

### 13. Successful lowering

An accepted block is ordinary syntax with no static node or mark: the body
spliced in place (it binds nothing in its own scope), or `if ^true {BODY}
{}` (it does). HIR, Core IR and NIR equal the unwrapped body's, or the `if
true:` block's (`sc-hir-accepted-ordinary`, `sc-core-ir`,
`sc-nir-accepted-identical`). Natively the `if` on the root `true` emits no
branch and no constant (`native::lower::PureDecidedCondition` now counts a
root Boolean reference as a pure decided condition).

### 14. Failed lowering

`fail compiler::CompilerError {code: <enum const>, primary:
compiler::SourceLocation {...}, related: [...], message: "..."}`: an ordinary
`fail` of an ordinary payload error, the payload an ordinary anonymous struct
construction (`struct payload(compiler::CompilerError)` in HIR text), its
location values ordinary named constructions, its code an enum constant
(`sc-hir-rejected`). Core IR `(fail compiler::CompilerError (struct ...))`,
NIR `faildeclared ID "compiler::CompilerError" SHAPE fields...`
(`sc-nir-rejected-payload-slots`). None of the body survives
(`sc-hir-rejected`: no reference to the function the body called).

### 15. Result-value preservation

An accepted block's value is its body's, in every accepted position
(`sc-success-value`: `x = static compile: 20 + 22` is 42, a multi-statement
body, `return static compile:`, a destructuring).

### 16. Run-time error preservation

An accepted body's run-time errors are its own: IndexNotFound
(`sc-success-runtime-error`), a declared application error with its
payload (`sc-success-declared-error`), a native's run-time TYPE
(`sc-native-type-error-is-runtime`).

### 17. CompilerError contract

A rejected block's error is ordinary: the enclosing function handles or
declares it, or the program is rejected with UNHANDLED-ERROR at the block
(worded for the case: "this \"static compile:\" block's body was rejected
(UNBOUND), so the block completes with the error ..."), a top-level block
likewise (a program's top level admits no error) (`sc-contract-admitted`);
its callers handle it (`sc-contract-unhandled-call`). An accepted block
contributes no CompilerError (`sc-contract-accepted-none`). The staging makes
the three states of item 61 exact: a decided block is either its body (no
CompilerError) or the failure (CompilerError is its completion); the
undecided state exists only inside the rounds, where the enclosing program's
diagnostics are not consulted.

### 18. KNOWN-ERROR

The narrowest rule (`hir/completions.tcl`): a path ending in a reified
failure sets the walk's `intended` flag, and `analyzeBlock` counts such a
path as one that may complete normally -- so a call of a function whose
block was rejected is never KNOWN-ERROR. The error is charged like any other.
An ordinary `fail`, or a call proven to fail on its own, still makes its
callers KNOWN-ERROR, including when it comes before a rejected block
(`sc-known-error-exempt`); a KNOWN-ERROR inside a body is the body's
rejection with code KnownError (`sc-negative-known-error`).

### 19. Warnings

Warnings run on the final program only, as on any program: a warning in an
accepted body is reported at its own location and the body runs
(`sc-warnings-visible`); a warning never rejects a block, and under
`-warnings error` it fails the whole compilation -- the global policy -- with
its own code, never as CompilerError (`sc-warnings-not-rejection`). A
rejected body's warnings are gone with it. The warning gate is unaffected (no
corpus program uses `static compile:`).

### 20. Misuse diagnostics

`STATIC-UNKNOWN-OPERATION` (an operation outside the vocabulary, never an
UNBOUND), `STATIC-INTRINSIC-FORM` (arguments, no colon, a one-line body, no
operation), the ordinary suite error (no block), `MISSING-IMPORT` (no
`import compiler`, `sc-import-required`).

### 21. compiler::DiagnosticCode

87 cases, one per recoverable kind (the census below), in `lib/compiler.bot`.

### 22. Census

[Diagnostic-code census](#diagnostic-code-census).

### 23. Mapping / exhaustiveness

`hir::static::codes` is the explicit table; `sc-codes-one-to-one` holds it
one-to-one against the enum and to the spelling rule; `sc-census-exhaustive`
fails on any upper-case kind token in `hir/*.tcl` or `surface/modules.tcl`
that is neither a code nor classified as never recoverable (with a reason),
and on any code no compiler source names. A kind with no case reaching the
bridge is an internal compiler failure, never a default case
(`sc-unmapped-kind-internal`).

### 24-25. SourceLocation, CompilerError

As declared above, ordinary namespaced declarations named qualified after
`import compiler`; a bare `CompilerError` or `DiagnosticCode` is unknown
(`sc-names-qualified`).

### 26. Host-to-Botlish conversion

`hir::static::Reified`: kind -> enum constant (`CodeOf`), primary origin ->
`SourceLocation` construction (`Location`: the origin's line and column),
related origins -> a List literal of constructions, message -> a String
constant; the whole the payload construction of an ordinary `fail`. The
result enters the ordinary error machinery: no exception object, no
diagnostic object at run time.

### 27. Primary-diagnostic selection

The first of the block's own diagnostics in the build's diagnostic list --
the one a strict compile of the same code raises first: resolution
diagnostics (a strict build stops after them) before check diagnostics,
then the passes' order, with the frontend's own promotions (opacity, trait
diagnostics, method-call decisions prepended). `sc-primary-selection`: an
UNBOUND after a TYPE error is reified (resolution first); of two UNBOUNDs
the first in source order.

### 28. Source-span preservation

The body is never re-parsed or re-located: its nodes carry their original
spans, and `primary` is the diagnostic's own line and column in the file
(`sc-location-original-span`: line 11, column 14, after blank lines and a
statement inside the block).

### 29. Related locations

From the diagnostic's structured `related` origins (new: `hir::Diagnose`
takes them; `USE-AFTER-MOVE` and `AFFINE-NOT-DEFINITELY-LIVE` record the
moves their messages name, `hir::affine::MoveOrigin`), in message order;
`[]` otherwise -- never synthesized (`sc-affine-use-after-move`).

### 30. Message preservation

The diagnostic's own message, without the `FILE:LINE:COLUMN: ` prefix the
frontend adds when raising it; equal to the ordinary compilation's
(`sc-diag-exact-*`).

### 31. Internal-failure boundary

Never caught: a Tcl error during a round propagates and fails the
compilation (`sc-internal-failure-propagates`, with a simulated compiler bug
the body's code provokes); a diagnostic marked `internal` (a
monomorphized-program diagnostic) or of an `*-INTERNAL` kind is never a
block's (`sc-internal-diagnostic-not-reified`); an unmapped kind is an
internal error.

### 32. Backend-error boundary

Static decisions finish before any backend runs, on HIR; a backend error
(`NATIVE UNSUPPORTED`, `NATIVE BUG`, ...) happens later, on the decided
program, and is never reified. No backend diagnostic is part of Botlish's
source compilation contract.

### 33. Namespaced errors

`a::Failed` handled as `b::Failed` inside a block is UnhandledError whose
message names the canonical `a::Failed`, exactly as ordinary compilation
says it (`sc-namespaced-errors`).

### 34. Opaque structs

An outside construction of `token::Token` inside a block is code
OpaqueConstruction, an outside projection OpaqueRepresentation; the
module's own operations are accepted (`sc-opaque`).

### 35. Higher-order completion

The erased-callable reproducer (E1 escaping `generic` through an untyped
`call`, a handler for E2 only) inside a block is UnhandledError
(`sc-negative-unhandled-erased`, `sc-diag-exact-erased-unhandled`): the
block runs the real completion analysis, fallback included.

### 36. Affine diagnostic

`sc-affine-use-after-move`: UseAfterMove at the second use, the first use
its related location, on every backend.

### 37. Successful run-time error

Item 16.

### 38. Successful value

Item 15.

### 39. Independent failed blocks

`sc-independent-sites`: accepted, rejected (UNBOUND), accepted, rejected
(TYPE), accepted -- all in the program, each with its own outcome:
`[1, -11, 2, -19, 3]`. `sc-rounds`: a program whose blocks are all accepted
takes one build, twelve blocks of which eight are rejected take three.

### 40. Nested static compile

Each level is its own boundary: an inner rejection is an ordinary
CompilerError completion of the outer body, which the outer compiles
(`sc-nested`); an outer body that cannot admit it is rejected in turn,
UnhandledError at the inner block (`sc-nested-outer-rejects`).

### 41. HIR evidence

Before: the AST `static compile <static>` node and the `static` syntax
node (`sc-before-hir`, `sc-grammar-ast`). After, accepted: the unwrapped
body's HIR text (`sc-hir-accepted-ordinary`). After, rejected (a program
whose block calls `side_effect()` and then names `missing`; nothing of the
body is left):

```
e4 bind b2 f : block(e5)/0 -> never
    e5 block s5 () captures () errors compiler::CompilerError : block(e5)/0 -> never
        e6 fail compiler::CompilerError static=compile:UNBOUND : never
            e7 struct payload(compiler::CompilerError) (code, primary, related, message) : struct{code: compiler::DiagnosticCode, message: str, primary: compiler::SourceLocation, related: List[compiler::SourceLocation]}
                e8 const enum {compiler::DiagnosticCode Unbound} : compiler::DiagnosticCode
                e9 struct compiler::SourceLocation (line, column) : compiler::SourceLocation
                    e10 const 9 : int
                    e11 const 9 : int
                e12 call native(list) : List[never]
                    e13 ref b3 list : native list
                e14 const str {unbound name "missing"} : str
```

`hir::format` prints the mark as `static=OPERATION:KIND`; `hir::parse` reads
it back (`sc-hir-text-round-trip`).

### 42. Core IR evidence

Accepted: the unwrapped program's Core IR, element for element (`sc-core-ir`).
Rejected, the same program:

```
{bind f {block {} {fail compiler::CompilerError {struct {} code {const enum {compiler::DiagnosticCode Unbound}} primary {struct {compiler::SourceLocation line column} line {const 9} column {const 9}} related {call {ref list}} message {const str {unbound name "missing"}}}}}}
```

an ordinary `fail` of a payload construction; no static form, no compiler
call.

### 43-44. Tcl interpreter and Tcl compiler

They run that Core IR: the accepted body as written (the Tcl compiler folds
an `if` on the root `true` away: its procedure equals the unwrapped one's
but for temporary numbering), the rejected block as an ordinary payload
failure. Every executable test runs on both (`sourceAgree`).

### 45. Native NIR

Accepted: byte-identical to the unwrapped body's (or the `if true:`
block's), no branch, no `bool true` (`sc-nir-accepted-identical`).
Rejected: one `faildeclared ... "compiler::CompilerError"` with the payload's
fields in the payload slots (`sc-nir-rejected-payload-slots`); no new NIR
instruction exists for static compile.

### 46. Successful-path allocation / codegen

Zero allocations, the same report as the unwrapped body
(`sc-alloc-accepted-zero`); NIR byte-identical (item 45), so the machine
code is.

### 47. Failed-path allocation

Natively the failure itself allocates the `primary` SourceLocation struct
and the message String (2 allocations, 72 bytes, exactly what the same
`fail compiler::CompilerError {...}` written by hand allocates --
Performance below); the empty `related` List is static; the handler's
binding materializes the anonymous payload struct only when used whole
(`sc-alloc-rejected`: 3 allocations whole, 2 reading fields). The payload
travels field-wise in the payload slots, never boxed.

### 48. Differential valid-body tests

The fuzzer's plain-program check (item 50 below) on every program, and the
HIR/Core IR/NIR identity tests.

### 49. Differential invalid-body diagnostic tests

`sc-diag-exact-*` (15 kinds: unbound, unbound-later, type, result-type,
unknown-field, duplicate, break-outside, unhandled-fail, undeclared-error,
flag-unknown, use-after-move, erased-unhandled, missing-import,
unknown-namespace, not-an-enum): the reified diagnostic equals the ordinary
compiler's first diagnostic inside the block written as `if true:` (kind,
line, column, related, message); and the fuzzer for every fault.

### 50. Fuzz results

`audit/static-compile/tools/fuzz.tcl` (its header has the design):
FUZZRESULTS

### 51. Mutation results

`audit/static-compile/tools/mutate.tcl`, the 21 mutants of
`mutants.txt` -- every one of item 82's list:
MUTATIONRESULTS

### 52. Full regression

REGRESSIONRESULTS

### 53. GC stress

GCRESULTS

### 54. Native coverage

NATIVECOVERAGE

### 55. Scalar / codegen audit

Item 45's NIR identity is the scalar audit for accepted blocks (no branch,
allocation, check, wrapper or indirect call). The one native lowering change
(`PureDecidedCondition` accepting a root Boolean reference) removes a dead
`bool` constant from every `if true:`/`if false:` (and every accepted block
whose body binds a name); SCALARAUDIT

### 56. Compile-time performance

[Performance](#performance).

### 57. Run-time performance

[Performance](#performance).

### 58. State-leak / stress

`sc-tx-deterministic`, `sc-rounds`, the bench's many-block files and the
fuzzer's programs of up to eight blocks: no growth (every build starts from
the same declarations), no stale summaries, decisions independent of
preceding rejected blocks.

### 59. SAME-FAILURE

A reified failure is not a fail site the programmer wrote: `hir::warnings::
FailSites` skips `fail` nodes with the `static` mark, so blocks rejected for
the same diagnostic never group (`sc-same-failure`). Ordinary `fail` sites
are unchanged. The reified message is a String constant the frontend
synthesizes; it is enumerated by `oc-synthesized-string-consts-enumerated`
and never one character long, so ONE-CHAR-STRING-LITERAL needs no rule.

### 60. Not implemented

No test framework, `test` declaration, expectation syntax or golden files;
no `static parse:`, `static assert_compiles:` or `static assert_rejects:`; no
`compiler::compile(str)`, no `syntactic fn`, macros, AST reflection,
compile-time evaluation or IO, subprocess, temporary file or run-time
compiler invocation; no diagnostic subtyping, one-error-per-diagnostic,
handler guards or pattern matching on diagnostics.

### Findings along the way

* A handled call whose normal result is a function value crashed the
  completion pass when a handler's type was checked against it
  (`core::type: malformed type "block ..."` from
  `hir::range::ProvesValueAcceptedBy`): an exact callable type now takes the
  subtype rule, as a structural `Fn` type always did -- found because a
  trial body may well be a function value.
* `surface::modules::RemapFile` did not remap a module's `fail` payload
  origins, so a diagnostic in one pointed at the entry file; it does now
  (the location attribution reads origins).
* Locations: the ordinary compiler reports a function's unproven result at
  its literal (the `(`), a missing context and an instance's invalid call at
  the call -- outside the block that causes them; a static block follows the
  ordinary convention, so those are the enclosing program's diagnostics.

## Performance

PERFORMANCE

## Files

| file | what |
|---|---|
| `surface/parser.tcl` | `staticIntrinsic`, `AtStatic`, `StaticIntrinsic`, misuse diagnostics |
| `surface/ast.tcl` | the `static` node: ids, children, printing |
| `surface/lower.tcl` | the `static` syntax node |
| `surface/modules.tcl` | the `import compiler` rule, deferred loader diagnostics (`StaticSites`, `CheckRef`, `LowerStatements`), `RemapFile` |
| `hir/syntax.tcl` | `staticNode` |
| `hir/static.tcl` | sites, expansion, reification, decisions, the code table |
| `hir/hir.tcl` | `hir::buildSyntax` / `hir::BuildFull`, `hir::Diagnose`'s `related` |
| `hir/resolve.tcl` | the mark on a reified `fail`, its UNHANDLED-ERROR wording |
| `hir/completions.tcl` | KNOWN-ERROR's `intended` |
| `hir/warnings.tcl` | SAME-FAILURE skips reified failures |
| `hir/affine.tcl` | related locations of USE-AFTER-MOVE / AFFINE-NOT-DEFINITELY-LIVE |
| `hir/traits.tcl` | monomorphized-program diagnostics marked `internal` |
| `hir/range.tcl` | an exact callable type in `ProvesValueAcceptedBy` |
| `hir/format.tcl`, `hir/read.tcl` | `static=OP:KIND` |
| `native/lower.tcl` | `PureDecidedCondition`: a root Boolean reference |
| `lib/compiler.bot` | `DiagnosticCode`, `SourceLocation`, `CompilerError` |
| `tests/static-compile.test` | the tests named above |
| `audit/static-compile/tools/` | `fuzz.tcl`, `mutate.tcl`, `mutants.txt` |
| `bench/static-compile.tcl` | the performance report |

## What to run when changing this

If you change the static-intrinsic grammar, `hir/static.tcl`, the loader's
deferral, how `fail` resolves or lowers, the completion walk's `fail` case,
`hir::Diagnose`'s fields, or add a diagnostic kind anywhere in the front end:
run `tests/static-compile.test`, `audit/static-compile/tools/fuzz.tcl`
(several seeds, once with `-gc-stress 1`) and
`audit/static-compile/tools/mutate.tcl` (every mutant in `mutants.txt` must
still apply and be killed). A new diagnostic kind needs its classification
in `sc-census-exhaustive` and, if a block can produce it, a case in
`lib/compiler.bot` and `hir::static::codes`.
