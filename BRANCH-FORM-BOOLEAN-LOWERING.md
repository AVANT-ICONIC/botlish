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

The win is structural on every backend: across the 13-program corpus, NIR
Bool constants fall 57%, moves 29%, NIR lines 12% and machine code 1.5%,
and no function grew. The run-time win is measurable natively. In a loop
where the condition is most of the work, `and` and `not` run 12-13%
faster (specialized; `and` 6% generic), and every direct condition costs
what nested `if`s cost. In the Tcl compiler the bytecode of such a loop is
22-28% smaller, but its run time moves only within the measurement noise,
which is up to 10% on this container (section 10).

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
(section 3).

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
interchange round trip and the compilation-isolation audit find every
artifact equal (section 9). Branch context is a
property of where an expression is consumed, which HIR already says (the
`condition` of an `if`), so nothing needed to be added.

## 4. Every control consumer (item 79)

| consumer | before | now |
|---|---|---|
| source `if`/`elif`, early-return guards (`if c: return`), `break` conditions | value, then branch | **branch form** (both compilers) |
| the condition of a Boolean-valued `if` (`and`/`or`/`not`/`!=`, nested) | a join | **branch form, compositional** |
| `if (if a: b else: c):` | a join | not writable in source: an `if` value must be the whole right side of `=` or `return`. HIR and core IR text can write it, and the rule lowers it: `a` to the two bodies, each body to the arms (`bf-boolean-valued-if`: Tcl `(A)?(B):(C)`, no Bool natively) |
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
  (`bf-nir-affine-rhs`); in the Tcl compiler the release is inside the
  other side of the test (`bf-tcl-affine-rhs`). The ownership analysis's release placement is
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
| `tests/branch-form-boolean.test` | 37/37, and 37/37 under `BOTLISH_NATIVE_GC_STRESS=1` |
| `tests/affine.test`, `tests/coroutines.test` under `BOTLISH_NATIVE_GC_STRESS=1` | 48/48, 79/79 |
| `audit/affine/tools/fuzz.tcl` (seeds 1-3, 30 programs each) | 0 disagreements |
| golden suite `branch-form-boolean.bot` | 18/18 on each backend; `perturb.tcl`: 18/18 fail inverted and altered; `check.tcl`: 19 old/new pairs pass |
| `audit/branch-form-boolean/tools/mutate.tcl` | 18 mutants, 18 killed (one, `shared-constant-ignores-releases`, survived the first run: only the Tcl compiler relies on that check, and no test looked at the Tcl release; `bf-tcl-affine-rhs` now does) |
| refinement fuzzer, static-decision fuzzer | 0 failures (above) |
| `audit/static-decisions/tools/compare.tcl` on branch-form-boolean.bot, type-predicates.bot, strings.bot | batched and sequential agree exactly: every site's outcome and reified diagnostic, the decided HIR text (batched 2, 3 and 2 rounds and builds; sequential 2, 24 and 18) |
| `audit/compilation-isolation/tools/interleave.tcl` | 9 suites, 72 artifacts and outcomes, 0 differ |
| `audit/hir-interchange/tools/roundtrip.tcl -via interchange` | 9 suites, 81 artifacts and outcomes, 0 differ |
| warning gate (`audit/refactor/tools/gate.tcl`) | passed: the observed warnings are exactly the manifest |
| corpus differential (examples/\*/\*.bot, bench/\*.bot: 41 programs × interp, compile, cranelift-generic, cranelift, plus `-hir`) | 205 outputs byte-identical before and after (the checkout path normalized), expected errors included |

## 10. Performance (items 25, 66-70, 83)

Measured with `bench/branch-form-boolean.tcl`, on the unmodified tree
("before", `-root`) and this one ("after"), on a 4-core container that is
shared and noisy. A form the change does not touch (`nested`, `value`)
moves by up to about 10% from run to run. Numbers are the best of 5 runs
in one process. The A/B rows alternate the two trees three times and take
the minimum of those.

**The domain benchmark** (ELIMINATE-AUTOMATIC-TYPE-PREDICATES.md's
workload: `ys = loop i from 0 to N: step(mod(i, 20) - 5)`, where `step`
admits `v` into `Small = Int in 0..9` and calls `use_small`). Run time, ms:

| step admits v by | interp (N = 2,000) | compile (N = 20,000) | cranelift-generic (N = 3,000,000) | cranelift |
|---|---|---|---|---|
| nested `if 0 <= v:` / `if v <= 9:` | 659 / 709 | 122 / 135 | 148 / 141 | 143 / 148 |
| `if 0 <= v and v <= 9:` | 723 / 746 | 130 / 126 | 139 / 163 | 143 / 143 |
| `if v < 0 or v > 9:` | 758 / 733 | 130 / 126 | 136 / 150 | 142 / 149 |
| `if not (v < 0 or v > 9):` | 770 / 808 | 135 / 134 | 157 / 146 | 144 / 144 |
| the converter `small(v)`, handled | 909 / 806 | 164 / 152 | 243 / 271 | 245 / 262 |
| `ok = 0 <= v and v <= 9` then `if ok:` (value) | 713 / 714 | 131 / 147 | 140 / 139 | 173 / 143 |

(before / after). Here every iteration makes two calls, a `mod` and a List
append. The conditions are a small share of that work, and every
difference is inside the noise. The earlier report's 135 ms (nested)
against 177 ms (`and`) in the Tcl compiler is no longer the baseline:
other compiler work merged since then had already brought `and` to within
about 6% of nested before this change. After it, `and`, `or` and `not`
cost what nested costs, on every backend.

**The condition alone** (`-workload tight`): a self-tail-recursive
`count(i, n, acc)`, a loop in both compilers, that tests
`v = mod(i, 20) - 5` each way and counts the admitted values. There is no
call per iteration. A/B minimum run time, ms:

| form | compile (N = 200,000) | cranelift-generic (N = 30,000,000) | cranelift |
|---|---|---|---|
| nested | 987 → 988 (+0.0%) | 205 → 207 (+0.9%) | 212 → 217 (+2.5%) |
| `and` | 1047 → 1018 (−2.8%) | 216 → 203 (**−6.1%**) | 236 → 207 (**−12.2%**) |
| `or` | 992 → 991 (−0.1%) | 200 → 198 (−1.0%) | 212 → 206 (−2.9%) |
| `not (… or …)` | 1003 → 1000 (−0.3%) | 230 → 224 (−2.6%) | 232 → 203 (**−12.8%**) |
| value `ok = … and …` | 1028 → 1004 (−2.3%) | 219 → 220 (+0.2%) | 239 → 238 (−0.6%) |

Natively, `and` and `not` lose their materialization cost, and every
direct condition now runs at the nested form's speed or better (203-207
against 217). In the Tcl compiler, the loop's own machinery dominates: argument
lists, boxed Ints, `mod`. The Tcl bytecode of `count` is 22-28% smaller
for the Boolean forms (below), but that shows as at most 3% of the run, as
much as the noise. The interpreter is unchanged by design.

**Real workloads** (`-programs`):

| program | compile run | native run (generic / specialized) | NIR lines (specialized) | NIR Bool constants |
|---|---|---|---|---|
| bench/uri-steady.bot (lib/web.bot's URI escaping) | 931-965 / 949-1006 ms | 3.1 / 2.2 → 2.8 / 2.1 ms | 419 → 409 | 20 → 18 |
| bench/refined-checks.bot (web::emailish?, uri_query_value?) | 537 → 511 ms | 0.6 / 0.5 → 0.6 / 0.9 ms | 1018 → 863 | 65 → 36 |
| examples/stdlib/ai_text_clean.bot | 5.0 → 4.8 ms | below 0.1 ms | 444 → 223 | 42 → 3 |
| examples/stdlib/csv_records.bot | 11.5 → 10.9 ms | (generic: struct-shape unsupported, unchanged) / below 0.1 ms | 978 → 890 | 24 → 8 |

Their run times are within noise, or too short to measure, and their code
is categorically simpler. The golden suites with the most Boolean
conditions (`type-predicates.bot`, `strings.bot`) take the same time on
every backend, within noise.

**Compile cost (item 67)**, ms, best of 5, alternating trees:

| program | front end | Core lowering (interp) | Tcl codegen (`compileHir`) | NIR lowering generic / specialized | Cranelift codegen |
|---|---|---|---|---|---|
| domain benchmark (any form) | 26-36, the same | 0.2-0.4, the same | 2.9-5.1 → 2.9-3.5 | 13-45, the same | 2-3, the same |
| bench/refined-checks.bot | 476 / 432 (unchanged code) | -- | 28-32 → 29-41 | 160 / 276-287 → 150-161 / 282-306 | 16 → 15-21 |
| examples/stdlib/ai_text_clean.bot | 141 / 127 (unchanged code) | -- | 7.3-15.7 → 6.3-7.1 | 50-51 / 79-81 → 48-51 / 69 | 4.6-8.5 → 3.9-6.0 |
| a 100 / 200-operand `and` | -- | -- | 52 / 124 → 37 / 120 | 1,798 / 4,119 → 1,770 / 4,151 (whole program) | -- |

Lowering a condition costs no more than lowering its value did. It does
less: no join register, no join block, no Bool. With less NIR, the
specialized lowering of ai_text_clean is about 13% faster. Everything else
is within noise.

**Value position (item 69).** `ok = 0 <= v and v <= 9`, then `if ok:`,
genuinely builds its Bool, before and after: 3 constants, 3 moves and a
join in the NIR. It is the one form whose cost did not move. It is now the
slowest of the forms natively (238 ms against 203-217), which is the
materialization the direct forms no longer pay.

**Item 68 (expected result).** Met: nested explicit control and the
direct `and`/`or`/`not` conditions have the same code shape: compare,
branch, compare, branch. Natively the direct forms are even shorter (42
NIR lines for `count`, against 49 for nested, whose else-less `if`s join a
`unit`). They run at the same speed on every backend, within noise.

## 11. Code size (item 84)

**NIR** of the 13 programs of the scalar-assembly corpus (bench/\*.bot,
examples/stdlib/\*.bot), totals:

| | lines | `bool` constants | `move` | `br` | `jump` | `label` |
|---|---|---|---|---|---|---|
| specialized, before | 5,824 | 227 | 543 | 328 | 546 | 1,014 |
| specialized, after | 5,121 (−12%) | 98 (−57%) | 385 (−29%) | 278 (−15%) | 388 (−29%) | 806 (−21%) |
| generic, before | 3,988 | 180 | 396 | 230 | 397 | 711 |
| generic, after | 3,471 (−13%) | 85 (−53%) | 280 (−29%) | 193 (−16%) | 281 (−29%) | 558 (−22%) |

The number of `br` falls too: the re-test of a joined Bool is gone. No
label or edge was added anywhere that a join did not lose more.

**Machine code** of the same corpus (`native/generate-scalar-audit.tcl`,
both trees, the same toolchain):

| program | bytes before → after | functions changed |
|---|---|---|
| bench/refined-checks | 10,655 → 10,319 (−3.2%) | 7 of 30 |
| examples/stdlib/ai_text_clean | 2,641 → 2,273 (−13.9%) | 2 of 6 |
| examples/stdlib/csv, csv_chunked, csv_geometric | −56 bytes each (about −1%) | 1 each |
| examples/stdlib/csv_records | 19,726 → 19,582 (−0.7%) | 3 of 51 |
| examples/stdlib/hashtable | 10,892 → 10,804 (−0.8%) | 2 of 24 |
| fib, loop-count, sum-refined, matmul, string_replace, string_reverse | unchanged (no Boolean conditions) | 0 |
| **total** | **72,369 → 71,265 (−1.5%)** | **17 smaller, none larger** |

The committed snapshot in audit/native-scalar-asm/ is regenerated by CI on
`main` (scalar-asm-audit.yml); it is not regenerated on this branch.

**Tcl bytecode** (`tcl::unsupported::disassemble`) of the tight
benchmark's compiled `count`, instructions: nested 147 → 132, `and`
162 → 127, `or` 162 → 127, `not` 177 → 128, value 162 → 147. Nested
shrinks too, because a comparison condition is now the `if`'s own test.

**Per function**, for the section 1 example: NIR `f` 17 → 12 registers,
3 → 2 `br`, 3 → 0 Bool constants, 3 join blocks → 0; CLIF 3 → 1 block
parameters; machine code 19 → 12 instructions, for `and` and `or` alike.

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

* **tests/branch-form-boolean.test** (37 tests): the shared rule; the
  generated Tcl (`&&`, `||`, `!`, nesting, operand code inside its side,
  value context, value positions, a Bool call); NIR of `and`, `or`, `not`,
  `not` of a conjunction, nesting, `!=`, generic, value context, value
  positions, a Bool call, a range-decided operand, an affine right
  operand (natively and in Tcl), an inlined region consumer, the converter,
  a Boolean-valued `if` from core IR text; Cranelift IR;
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

## 15. Tooling (item 54)

No CLI changed. No IR shape name was added or renamed. The NIR vocabulary
is `br`, `jump` and `label`, as before. `main.tcl -emit-nir`, `-emit-clif`
and `-code` show the new shapes as they are: the examples in sections 1
and 2 are their output.

## 16. Success criteria (items 90-95)

| criterion | evidence |
|---|---|
| semantic identity (90) | Corpus outputs, diagnostics and HIR are byte-identical. Order, counts, short circuits, errors, affine moves and yields are pinned on every backend (sections 7-9) |
| no Bool in condition context (91) | `if a and b:` / `if a or b:` have no Bool constant, move or join (`bf-tcl-and`, `bf-tcl-or`, `bf-nir-and`, `bf-nir-or`, `bf-clif-and`, the generic lowering) |
| value semantics (92) | `x = a and b` builds its Bool, through the old code (section 6) |
| structured nesting (93) | `a and (b or c)`, `not (a and b)`, 60-level trees, 400-operand chains, Boolean-valued `if`s, all lowered through the true/false targets |
| proof symmetry (94) | One structure, two readers: `hir::range::Paths` (path facts) and `hir::condition` with each compiler's emitter (control-flow edges). They share no code (`bf-source-audit`) |
| measurable or structural win (95) | Both. NIR Bool constants −57%, moves −29%, machine code −1.5% with no function larger, Tcl bytecode −22-28% per Boolean condition; `and`/`not` 12-13% faster natively where the condition dominates; no regression (sections 10, 11) |

