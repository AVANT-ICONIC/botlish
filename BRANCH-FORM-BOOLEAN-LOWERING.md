# Branch-form Boolean lowering

> **Boolean expressions do not inherently require Boolean temporaries. They
> produce values in value context and control-flow edges in condition
> context. `and`, `or` and `not` keep their ordinary Bool semantics while
> lowering directly through short-circuit branches whenever their result is
> consumed only as control flow.**

## Outcome

Done, for the Tcl compiler and both native backends (specialized and
generic). An expression demanded as a value is lowered to a value; an `if`
condition is demanded as a branch and is lowered straight to control flow:

* `hir/condition.tcl` states the branch form once (`hir::condition::form`,
  `constant`, `releasing`). `and`, `or`, `not` and `!=` have no node of
  their own: the front end lowers them to `if` expressions over the root
  Booleans, so one rule covers them, every Boolean-valued `if`, and any
  nesting.
* The **Tcl compiler** (`CompileCondition`) builds one Tcl test from `&&`,
  `||`, `!` and `?:`. `if 0 <= x and x <= 9:` is now
  `if {(0 <= X)&&(X <= 9)} {`, where it used to build `{bool true}` /
  `{bool false}` in a join temporary and `string equal` it with `true`.
* **Native lowering** (`Condition`) branches to the `if`'s two arms.
  `if x >= 0 and x <= 9:` is `compare; br MID ELSE; MID: compare; br THEN
  ELSE`. There is no `bool` constant, no `move` and no join block. The
  machine code of the two-comparison function drops from 19 to 12
  instructions.
* HIR, the front end, Core IR and the interpreter are unchanged. A Bool
  that is used as a value (a binding, an argument, a return, a List
  element, a struct field) is built exactly as before.
* The corpus (41 programs × 4 backends, plus `-hir`) produces
  byte-identical output and HIR before and after. 89 golden suites pass on
  all four backends. The fuzzers, the compilation-isolation and interchange
  audits and 18 new mutants agree.

The win is structural on every backend. It is measurable in the Tcl
compiler, where the conditions of the domain benchmark now cost what the
nested `if`s cost (section 10).

## 1. Before: where the temporary Bool came from

The example is `fn f(x: int) -> int: if x >= 0 and x <= 9: 1 else: 2`, and
the same with `or` (`if x < 0 or x > 9:`), called over `i - 15` for
`i in 0..30`. The range is a small raw Int, and no instance Range decides a
comparison.

**Source → HIR.** surface/lower.tcl lowers `a and b` to `if a {if b
{^true} {^false}} {^false}`, and `a or b` to `if a {^true} {if b {^true}
{^false}}` (its rule table). The HIR of `f` is:

```
e3 if : int
    e4 if : bool                         <- the `and`
        e5 call native(>=) : bool        (x >= 0)
        then s4
            e9 if : bool                 <- the test of b
                e10 call native(<=) : bool  (x <= 9)
                then s5  e14 ref true
                else s6  e15 ref false
        else s7  e16 ref false
    then s8  e17 const 1
    else s9  e18 const 2
```

This is the right *semantic* form. Proof analysis decomposes exactly this
structure (`hir::range::Paths`). The temporary appeared below HIR, in each
backend's `if`. The `if` lowered its condition **as a value** and then
branched on that value. Its condition was the inner `if`, and lowering an
`if` as a value means joining its branches' values.

**Core IR / interpreter.** `hir::lower` gives `{if {if {call {ref >=} {ref
x} {const 0}} {block {} {if {call {ref <=} ...} {block {} {ref true}}
{block {} {ref false}}}} {block {} {ref false}}} {block {} {const 1}}
{block {} {const 2}}}`. `op-if` evaluates the inner `if` to `{bool true}`
or `{bool false}` (a root lookup) and then tests it. This is unchanged
(section 4).

**Tcl compiler (before).** `CompileIf` compiled its condition with
`CompileExpr`. The inner `if` became a Tcl `if` whose arms set a join
temporary to the boxed literals:

```tcl
set t5 [expr {[lindex $v2 1] >= 0}]
if {$t5} {
    set t8 [expr {[lindex $v2 1] <= 9}]
    if {$t8} {
        set t11 {bool true}
    } else {
        set t11 {bool false}
    }
    set t13 $t11
} else {
    set t13 {bool false}
}
if {[string equal [lindex $t13 1] true]} {
    set t14 1
} else {
    set t14 2
}
```

That is one comparison temporary per operand, a boxed Bool join (`t11`,
then `t13`), and a string comparison against `true`. `or` had the same
shape, with `{bool true}` on the first arm.

**Native (before).** `native::lower::If` lowered its condition with `Expr`,
which for an `if` is `If` again: a join register. The NIR of `f`:

```
    %3 = op rige %0 %2
    br %3 L0 L1
  label L0
    %7 = op rile %0 %6
    br %7 L3 L4
  label L3
    %9 = bool true
    %8 = move %9
    jump L5
  label L4
    %10 = bool false
    %8 = move %10
    jump L5
  label L5
    %4 = move %8              <- the conjunction's Bool
    jump L2
  label L1
    %11 = bool false
    %4 = move %11
    jump L2
  label L2
    br %4 L6 L7               <- branched on again
```

That is three Bool constants, four moves into two join registers, three
join blocks, and a third `br` that re-tests what the first two already
decided. `g` (`or`) had the same shape with `bool true` on the first arm.
The CLIF carried the join as block parameters (`block7(v23)`,
`block8(v25)`) followed by `icmp eq v25, 6`. In the machine code, the
conjunction was materialized in a register and compared:

```
 test   rsi,rsi
 jge    ...
 mov    esi,0x2                  ; false
 jmp    join
 cmp    rsi,0x9
 jle    ...
 mov    esi,0x2                  ; false
 jmp    join
 mov    esi,0x6                  ; true
join:
 cmp    rsi,0x6                  ; branch on the Bool
 je     then
```

The generic NIR (`-specialize 0`) was the same, with an `op runbox`.

## 2. After

**Tcl compiler.** The same functions:

```tcl
proc block1 {captured argv} {
    set v2 [lindex $argv 0]
    if {([lindex $v2 1] >= 0)&&([lindex $v2 1] <= 9)} {
        set t9 1
    } else {
        set t9 2
    }
    return [list int $t9]
}
proc block11 {captured argv} {
    set v12 [lindex $argv 0]
    if {([lindex $v12 1] < 0)||([lindex $v12 1] > 9)} {
        set t19 1
    } else {
        set t19 2
    }
    return [list int $t19]
}
```

Tcl compiles `&&` and `||` inside a braced `if` test to conditional jumps,
so the short circuit is the bytecode's own. A comparison used directly as a
condition is now the test itself (`if {[lindex $v2 1] < 2} {` in `fib`),
not a temporary that is set and then tested.

**Native.** `f` and `g`:

```
func 1 "f"                              func 2 "g"
    %3 = op rige %0 %2                      %4 = op rilt %0 %3
    br %3 L3 L1                             br %4 L0 L3
  label L3                                label L3
    %6 = op rile %0 %5                      %7 = op rigt %0 %6
    br %6 L0 L1                             br %7 L0 L1
  label L0          (then arm)            label L0          (then arm)
    ...                                     ...
  label L1          (else arm)            label L1          (else arm)
```

This is the target shape. `and`'s first comparison goes to the else arm
when false. `or`'s first comparison goes to the then arm when true. Each
function has 12 registers where it had 17, and two `br` where it had three.
The CLIF has one block parameter left: the `if`'s own value join, which
is genuine. The machine code is:

```
 test   rsi,rsi
 jl     else
 cmp    rsi,0x9
 jle    then
else: xor rax,rax ...
```

That is 12 instructions instead of 19, for both `f` and `g`. The generic
lowering has the same shape (with its `runbox`).

A NIR comparison still produces a tagged Bool that `br` tests: NIR's
comparisons are SSA Booleans, and this milestone did not contort that.
Cranelift folds the `select TRUE/FALSE; icmp eq TRUE` pair into the flags
of the comparison (`test; jl`) on its own. The materialization that the
lowering created, and that no later pass removed, was the join. That join
is gone.

## 3. The architecture

```
                         value demanded        branch demanded (an `if` condition)
  source Bool expr  ->   lower as value   |    lower as condition (hir::condition's form)
                         a Bool register  |      true/false  -> jump TRUE / FALSE
                         or Tcl operand   |      if C {..T} {..E} -> C to THEN/ELSE; each
                                          |        branch's statements, its last expr to TRUE/FALSE
                                          |      anything else -> its value, then a branch on it
```

**The shared rule (hir/condition.tcl).** It contains no emission and no
proofs. It states which expressions have a branch form:

* `true`/`false`: a reference to the root Boolean (what the keywords lower
  to), or a Boolean constant;
* `if`: an `if` with two non-empty branches whose type is not never;
* `value`: anything else.

`constant` is "a branch that is one Boolean constant statement with nothing
released after it". Such a branch needs no block: its side of the
condition goes straight to TRUE or FALSE. So `not a` is `a` to FALSE/TRUE,
and `a and b` is `a` to MID/FALSE and then `b` to TRUE/FALSE. `releasing`
asks whether affine values are released after a statement. Both compilers
read these three functions, and nothing else knows `and` or `or`. The
lowering of each operand is the backend's own.

**Tcl compiler (compiler/compiler.tcl).** `CompileIf` asks
`CompileCondition` for its condition's test. `CompileCondition` returns
`test` (the pieces of a Tcl expression appended to one list), `literal 1|0`
(decided: a constant, a type test HIR decided, `unit == unit`), or `never`.

`ConditionIf` composes an `if` by its constant branches:

| shape | Tcl |
|---|---|
| `if C {T} {false}` (`and`) | `(C)&&(T)` |
| `if C {true} {E}` (`or`) | `(C)\|\|(E)` |
| `if C {false} {true}` (`not`, `!=`) | `!(C)` |
| `if C {true} {false}` | `C` |
| `if C {T} {E}` | `(C)?(T):(E)` |

`ConditionBranch` compiles a branch. When the branch runs only on its
side, its statements, and any code its last operand needs, go *inside*
that side as a command substitution, `[CODE\nexpr {TEST}]`. Tcl compiles
the substitution inline, and a `break`, `continue`, `return` or error in
it completes the enclosing command as anywhere else. This was verified
for `break`/`continue` in a compiled `while`, `return -code 5`, and
`yield` in a coroutine. A branch a decided condition always runs is
emitted in place. Boolean intrinsics (`< <= > >= ==`, `ok?`/`error?`,
type tests) answer a branch demand with their test instead of setting a
temporary (`BoolResult`). In value context they emit the same
`set tN [expr {...}]` as before.

This is the direct-HIR path. `main.tcl -backend compile` and
`core::compiler::evalHir`/`compileHir` compile the front end's HIR, and so
does the core IR text path, which reads text into HIR first. The
per-block Core lowering, `hir::lower::body` for a Block value's printed
body, is not where the materialization came from, and it is unchanged.

**Native (native/lower.tcl).**

* `If` lowers a condition that has an `if` branch form with `Condition`,
  to the arms' labels.
* `Condition` jumps for a constant, calls `ConditionIf` for an `if`, and
  otherwise takes the value and emits a `br`.
* `ConditionIf` keeps every rule `If` has for its own condition: the
  instance's range-decided outcome (M6-RANGE-DECIDED-BRANCH-LOWERING.md:
  only the decided branch is lowered, and a pure condition is not
  evaluated at all), the Boolean guard hir::aot requires for a condition
  that is not statically a Bool (value path, `guardbool`), branches HIR
  left unreachable, the locals and raw-cache save and restore per branch,
  and the skipped-guard accounting.
* `ConditionBody` runs a branch's statements as `Sequence` does, then
  lowers its last expression as a branch. When affine values are released
  right after that expression, it emits the value, the releases and then
  the `br`. For a Boolean constant it emits the releases and then the
  `jump`.
* `BodyTarget` makes a branch whose outcome is known with no code
  (`StaticOutcome`) a target instead of a block.

`StaticOutcome` is M6's "decided and pure" rule, composed through the
`if` structure. A comparison the Ranges decide whose operands are pure
counts, and so does an `if` whose condition is such a comparison and whose
chosen branch is one too. So `x != K`, `not (x < K)` and conjunctions of
decided comparisons need no code. `If` uses it as well. It is remembered
per condition: `ConditionIf` asks level by level what `If` already asked,
and without the memo a 200-operand chain took 21,562 evaluations instead
of 1,423.

The same rule is used inside an inlined region-consumer predicate
(`EmitRegionConsumerCondition`). When such an inlined call is itself the
condition (`if is_local_char(peek(text, i)):`), `BranchDemand` lets the
inliner branch to the arms directly. `If` and `Condition` post the demand
on a call condition. The one lowering that can produce a call's Bool as
control flow, `InlineRegionConsumerCall`, takes it and returns no
register. Every other lowering ignores the demand. Before, that inlined
`or` chain built three nested Bool joins. Now it is four region tests and
five `br`, with no Bool (`bf-nir-region-consumer`).

Generic and specialized lowering share all of this. The generic NIR has
the same shapes (`bf-nir-generic`).

**Interpreter (item 24).** It is not changed. `op-if` evaluates a
condition to a value (`{bool true}` is a root binding lookup) and tests
it. Its tree walk has no branch form to give and no join to remove: a
condition-only evaluator would be a second evaluation model for a
backend that is the reference semantics, not a performance target.
**Core IR (item 47)** has one `if` form and is unchanged.

**HIR (item 64)** is unchanged. There is no branch-context node, flag or
side table. The `-hir` text of the corpus is identical, and the HIR
interchange and cache audits agree (section 9). Branch context is a
property of where an expression is consumed, which HIR already says (the
`condition` of an `if`), so nothing needed to be added.

## 4. Every control consumer (item 79)

| consumer | before | now |
|---|---|---|
| source `if`/`elif`, early-return guards (`if c: return`), `break` conditions | value, then branch | **branch form** (both compilers) |
| the condition of a Boolean-valued `if` (`and`/`or`/`not`/`!=`, nested) | a join | **branch form, compositional** |
| `if (if a: b else: c):` | n/a | not writable in source: an `if` value must be the whole right side of `=` or `return`. HIR text can write it, and the rule lowers it (`a` to the bodies, each body to TRUE/FALSE) |
| loop conditions | -- | Botlish has no `while`: loops exit through `if ...: break` (covered). Counted, list and lockstep loops test their own bounds with one compare and `br` (no Boolean expression) |
| a value-context `if` whose condition is Boolean structure (`x = if a and b: 1 else: 2`) | value, then branch | **branch form** (it is a condition) |
| an inlined region-consumer predicate's own nested conditions | joins | **branch form** (`EmitRegionConsumerCondition`) |
| an inlined region-consumer call used as a condition | value, then `br` | **branch form** (`BranchDemand`) |
| tiny-leaf inlining (TINY-LEAF-DEFAULT-ON.md) | -- | Straight-line bodies only (no `if`): an inlined Bool predicate is one comparison, branched on. Nothing to join |
| `handle`'s `on` dispatch, coroutine `done?`, `ok?`/`error?` | -- | Identity compares, natives returning Bool: values, branched on (the Tcl intrinsics answer a branch demand with their test) |
| the interpreter's `op-if` | value | value (above) |
| range-decided conditions (M6) | value or skipped | the same rule, also through the Boolean structure (`StaticOutcome`) |

## 5. What still lowers value → branch (item 80)

* **A call returning Bool** (`if p(x):`). The returned value is branched
  on. There is no predicate-call ABI. Inlining decides whether there is
  a call at all: a tiny leaf has no `if`, and the region consumer takes
  the demand (above).
* **A Bool binding** (`c = a and b` then `if c:`). `c` is a value. The
  `if` branches on it, and nothing is fused across the binding (item 75).
* **Every other Bool-valued expression** whose branch form is `value`: a
  reference, a projection, a List element, a call through a `Fn`, an `if`
  with an empty branch or of type never.
* **The Tcl compiler's refining conditions**: a call condition of an `if`
  whose branch scope is materialized (a closure is made in it). That `if`
  installs the refinements the runtime rule proves for the callee value
  actually called, so it needs the callee and the value.
* **A call whose error edge releases affine values** (Tcl: the call runs
  in a catch that keeps a value; native: `Call`'s pad expects one).
* **A natively guarded condition**: one hir::aot reports as not
  statically a Bool. It is `guardbool` on the value, then `br`.
* **A branch with affine values released after its last expression**: the
  value, the releases, then `br`. A Boolean constant there is the
  releases and a `jump`.

## 6. Value contexts are unchanged (item 81)

| position | test |
|---|---|
| binding (`x = a and b`) | `bf-tcl-value-context`, `bf-nir-value-context` (three Bool constants joined, then `br` on the join register) |
| argument, return, List element, struct field | `bf-tcl-value-positions` (11 + 3 `{bool ...}` literals), `bf-nir-value-positions` (11 + 3 `bool` constants), values on every backend |
| mixed: `x = a and b` then `if x:` | the same tests: the `if` tests `x` |

The generated code for a value position is the code it was before: value
lowering was not touched. Only conditions take the new path, and
`BoolResult` emits the old `set tN ...` when no branch is demanded.

## 7. Semantics preserved

These are pinned on all four backends, in Tcl (`tests/branch-form-boolean.test`)
and in the golden suite:

* **Short circuits and order (items 11, 41, 42).** `log(n, v)` yields `[n]`
  and returns `v`, and the coroutine's segments are the log.
  `false and _` and `true or _` never run the right operand, and
  `true and _` and `false or _` run it once. Operands run left to right,
  each at most once, through `not`, `!=`, nested `a and (b or c)`, a
  three-operand mix, and value-position `and`/`or` (`bf-order`, five golden
  tests).
* **Errors (items 12, 43).** A right operand that may fail runs only where
  the left one lets it. Its error is raised exactly there (`bf-errors`).
  When both may fail, the left operand's error comes first and the right
  one's only past it (`bf-errors-order`). `false and risky(9)` /
  `true or risky(9)`, where `risky(9)` is known to fail, are accepted and
  are no KNOWN-ERROR, because the completion analysis already reads the
  `if` structure. No completion rule was added.
* **Affine values (item 13).** In `flag and take(h)`, the handle is moved
  only where `take` runs. The other path releases it and then jumps
  (`bf-nir-affine-rhs`). The ownership analysis's release placement is
  unchanged, and the lowering emits it on the edge it belongs to.
* **Coroutines (item 14).** Yields inside operands keep their order: every
  log test yields from inside the operands, on all backends, natively
  too. No second evaluation model exists.
* **Methods (items 44, 45).** `x.ready?() and y.valid?()` behaves as the
  free calls do (`bf-methods`). Method-call decisions, and every static
  decision, are the front end's, which did not change, and nothing below
  HIR re-decides one: a branch is lowered from the HIR's resolved call,
  once. The static-decision fuzzer finds no divergence, and the new suite
  is decided in 2 rounds and 2 builds (`golden.test`'s economics).

## 8. Proofs are the analyses' (items 20-22, 34-37, 71, 82)

The lowering reads no range fact for itself. It uses M6's existing theorem
(`hir::range::ConditionOutcome` + `PureDecidedCondition`), composed
structurally. It reports nothing and decides no completion.
`hir::range::Paths` is untouched, budgets included. The lowering has no
budget at all: a 400-operand chain, far past `Paths`' 64 nodes, runs
exactly (`bf-large-chain`, `bf-beyond-proof-budget`). The two systems share
semantics, not code. `hir/condition.tcl` calls nothing in `hir::range`,
and `hir/range.tcl` and the evaluator call nothing in `hir::condition`
(`bf-source-audit`).

* `small(x)`'s `or` guard still proves its result. `0 <= x and x <= 9`
  still admits `x`. `small(3)` needs no handler and `small(12)` is
  KNOWN-ERROR (`bf-proofs`, four golden tests).
* The converter's guard lowers to two comparisons and their branches, into
  the failure or the value, with no Bool (`bf-converter-nir`).
* The refinement fuzzer (`-domains 1`, seeds 1-3, 40 programs each, and
  seeds 1-2 of the refinement mode) reports 0 failures. The
  static-decision fuzzer (seeds 17, 41, 3) reports 0 failures, with no
  batched/sequential divergence.
* Diagnostics and accepted/rejected static sites are identical: the
  corpus outputs are identical, and the golden suites, whose static blocks
  are compared by code, all pass. Internal ids did not change, because HIR
  did not (item 65).

## 9. Regression runs (items 59-63)

| run | result |
|---|---|
| `tests/local.tcl` (175 Tcl files on interp and compile, 89 golden suites on 4 backends) | TBD |
| native coverage (the Tcl suite on cranelift and cranelift-generic) | TBD |
| `tests/branch-form-boolean.test` | 35/35; 35/35 under `BOTLISH_NATIVE_GC_STRESS=1` |
| golden suite `branch-form-boolean.bot` | 18/18 on each backend; `perturb.tcl`: 18/18 fail inverted and altered; `check.tcl`: 19 old/new pairs pass |
| `audit/branch-form-boolean/tools/mutate.tcl` | TBD |
| refinement fuzzer, static-decision fuzzer | 0 failures (above) |
| `audit/compilation-isolation/tools/interleave.tcl` | 9 suites, 72 artifacts and outcomes, 0 differ |
| `audit/hir-interchange/tools/roundtrip.tcl -via interchange` | 9 suites, 81 artifacts and outcomes, 0 differ |
| warning gate (`audit/refactor/tools/gate.tcl`) | passed: the observed warnings are exactly the manifest |
| corpus differential (examples/\*/\*.bot, bench/\*.bot: 41 programs × interp, compile, cranelift-generic, cranelift, plus `-hir`) | 205 outputs byte-identical before and after (the checkout path normalized), expected errors included |

## 10. Performance (items 25, 66-70, 83)

TBD

## 11. Code size (item 84)

TBD

## 12. Size, depth and complexity (items 38-40, 85)

**Linear.** Each HIR node of a condition is visited once by the Tcl
compiler's `CompileCondition` and once by native `Condition`/`ConditionIf`.
No operand is lowered twice, because each branch body is lowered exactly
once, at its label (native) or in its side of the operator (Tcl).
`BodyTarget`/`StaticOutcome` and `hir::condition::constant` are queries
that emit nothing, and `StaticOutcome` is memoized per condition. The Tcl
test is built in one list of pieces, so no operand's text is copied into
another's. A placeholder is filled in place (`lset`), and dropping an
unfinished operand is the one `lreplace` of a `never` branch.
`bf-lowering-work-linear` pins it: equal second differences of the calls
for 60/120/180 operands, at most 8 `StaticOutcomeOf` evaluations per
operand (7 measured). Without the memo it is quadratic, and the mutant
`nir-static-outcome-unmemoized` is killed by that test. The output is
linear too: each further 100 operands add the same NIR (5 lines per
undecided operand; decided ones add none) and the same Tcl
(`bf-large-chain`).

**Depth (item 40).** Both compilers' compile-time walks now run under the
front end's recursion floor (`hir::Deep`, scoped: the compiled program
still runs under the caller's limit). The walks recurse as deep as the
program nests, and before this a left-deep `and` stopped the compilers
first:

| left-deep `and` operands | before | after |
|---|---|---|
| 200 | all backends | all backends |
| 400 | Tcl compiler: `TCL LIMIT STACK` (400 nested Tcl `if`s); native ok | all backends |
| 500 | every compiler: `TCL LIMIT STACK` (native in specialization's type inference, Tcl in `CompileSequence`) | all backends |
| 800 | the front end is killed (memory), before and after | the same: the front end's limit, not the lowering's |

Nested parentheses stop in the parser (unchanged, not under `hir::Deep`)
near 120 levels. A 60-level alternating and/or/not tree lowers
deterministically and computes what Tcl's own `expr` computes
(`bf-deep-nesting`).

## 13. Repairs (item 86)

* `tests/inference.test`'s `types-3` counted `expr {` in fib's generated
  code (4). The comparison `n < 2` is now the `if`'s own test
  (`if {[lindex $v2 1] < 2} {`). The test now counts the three arithmetic
  `expr`s and the inline comparison test separately (`0 3 1`). It was the
  only test in the suite that depended on the old shape.
* No optimizer depended on the materialized joins: there is no CFG
  simplifier, and none was added (item 76).

## 14. Tests, mutants, tools

* **tests/branch-form-boolean.test** (35 tests): the shared rule; the
  generated Tcl (`&&`, `||`, `!`, nesting, operand code inside its side,
  value context, value positions, a Bool call); NIR of `and`, `or`, `not`,
  `not` of a conjunction, nesting, `!=`, generic, value context, value
  positions, a Bool call, a range-decided operand, an affine right
  operand, an inlined region consumer, the converter; Cranelift IR;
  semantics on every backend; proofs; linear work and size; depth; a
  source audit.
* **tests/golden/branch-form-boolean.bot** (18 golden tests, every
  backend): and/or short circuits, `not`, nesting, value positions, errors
  skipped and ordered, a constant left operand, methods, the converter's
  `or` guard, range proof through `and`, exact inputs, KNOWN-ERROR, past
  the proof budget, deep nesting, an affine right operand, an inlined
  region consumer. Census and fragment rows map them to the Tcl tests.
* **audit/branch-form-boolean/tools/mutate.tcl** with 18 mutants:
  - `and`/`or` evaluating the right operand anyway (eager `&`/`|` in Tcl;
    a native false/true edge into the right operand's block);
  - `not` forgetting to negate or swap;
  - the right operand's code emitted unconditionally, or before the left
    operand;
  - the right operand lowered twice;
  - every condition lowered as a value (Tcl, native);
  - a value lowered as a condition (`BoolResult` answering every demand);
  - the region inliner ignoring the demand;
  - a release skipped by jumping first;
  - the shared rule ignoring releases, or giving a never `if` a form;
  - `StaticOutcome` unmemoized.
* **bench/branch-form-boolean.tcl**: the benchmark below, for any checkout
  (`-root`), on real programs too (`-programs`).
