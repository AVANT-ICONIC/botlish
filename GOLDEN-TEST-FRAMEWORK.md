# GOLDEN-TEST-FRAMEWORK.md

A golden test framework for Botlish, written in Botlish: `lib/test.bot`, an
ordinary library, and a validation sample of the Tcl suite ported to it.

> Can an ordinary Botlish library, using the language's existing functions,
> contexts, mutable values, coroutines, payload errors, matchers and
> `static compile:`, express a practical golden-testing workflow for real
> Botlish tests without adding test-specific language syntax?

@@ANSWER@@

## Contents

* [The library](#the-library)
* [How it works](#how-it-works)
* [Generic completion capture: what ordinary Botlish can observe](#generic-completion-capture-what-ordinary-botlish-can-observe)
* [The static-compile convention](#the-static-compile-convention)
* [Testing the framework](#testing-the-framework)
* [The migration](#the-migration)
* [Side-by-side agreement and the mutation spot-check](#side-by-side-agreement-and-the-mutation-spot-check)
* [Backends, GC stress, native coverage](#backends-gc-stress-native-coverage)
* [Performance](#performance)
* [Recurring boilerplate](#recurring-boilerplate)
* [Findings](#findings)
* [Not implemented](#not-implemented)
* [Recommendations](#recommendations)
* [Report](#report) -- the 64 points of the milestone report, in order
* [Files](#files)
* [What to run when changing this](#what-to-run-when-changing-this)

## The library

```botlish
import compiler
import test

fn register_arithmetic_tests():
    fn adds() errors compiler::CompilerError:
        static compile:
            20 + 22
    test::value("adds", 42, adds)
    fn unbound() errors compiler::CompilerError:
        static compile:
            missing + 1
    test::rejects("unbound", compiler::DiagnosticCode::Unbound, unbound)

with context test::suite()
register_arithmetic_tests()
test::report()          # ["PASS adds", "PASS unbound", "2 passed, 0 failed"]
```

The API (`lib/test.bot`; a module has no visibility control, so the
library's other top-level helpers -- `joined`, `quoted`, `text_lines`, ... --
are reachable too, but are not part of it):

| name | what |
|---|---|
| `test::Suite` | `context struct Suite: cases: MutableVector[TestCase]` -- the suite context |
| `test::suite()` | a new, empty Suite, for `with context test::suite()` |
| `test::TestCase` | `{name, run}`: one registered case, the element of `Suite.cases` and of `registered()` |
| `test::case(name, run)` | registers a case whose check is `run: Fn{args: [], return: test::Match}` (stored, not called): the low-level form and the escape hatch |
| `test::value(name, expected, body)` | registers: `body()`'s value must `== expected` |
| `test::holds(name, description, predicate, body)` | registers: `predicate(body())` must be true |
| `test::rejects(name, code, body)` | registers: the body's block must be rejected with `code` (a `compiler::DiagnosticCode`) |
| `test::rejects_at(name, code, line, column, body)` | registers: ... at that primary location |
| `test::rejects_any(name, body)` | registers: the body's block must be rejected |
| `test::Match` | `{matched, expected, actual, detail}`: one comparison's verdict, as data |
| `test::equal(expected, actual)`, `test::satisfies(actual, description, predicate)`, `test::diagnostic(expected, code, primary, message)` | matchers: a Match |
| `test::passed()`, `test::mismatch(expected, actual, detail)` | Match constructors for a custom check |
| `test::run()` | the runner coroutine: one case per segment, each sending `[TestResult]`, the last sending `[]` |
| `test::TestResult` | `{name, passed, expected, actual, detail}` |
| `test::results()` | runs the suite once: every case's result, in registration order |
| `test::Summary`, `test::summarize(results)` | `{total, passed, failed}` |
| `test::report()` | runs the suite once: its deterministic report, a `List[str]` |
| `test::result_lines(result)`, `test::summary_line(summary)` | the report's formatting, for a driver of its own |
| `test::registered()`, `test::count()` | the registered cases (a snapshot List), how many |
| `test::describe(v)`, `test::int_text(n)`, `test::code_name(code)`, `test::diagnostic_text(code, primary)` | the texts a report shows |

The registration helpers and `case`/`mismatch` are `nomethod`: their first
argument is a name, not a receiver (`"adds".value(42, adds)` would read
badly), which is also what keeps a suite free of `METHOD-ELIGIBLE` warnings.

The report of `gf-verdicts` (`tests/golden-framework.test`), whose suite
registers every helper, passing and failing:

```
PASS adds
FAIL off by one
  expected: 42
  actual: 41
PASS unbound
FAIL unbound, expecting Type
  expected: compiler diagnostic Type
  actual: compiler diagnostic Unbound at line 23, column 13
  detail: unbound name "missing"
PASS unbound at its column
FAIL unbound, wrong column
  expected: compiler diagnostic Unbound at line 23, column 14
  actual: compiler diagnostic Unbound at line 23, column 13
  detail: unbound name "missing"
PASS unbound, any diagnostic
FAIL value expected, block rejected
  expected: 1
  actual: compiler diagnostic Unbound at line 23, column 13
  detail: unbound name "missing"
FAIL rejection expected, block accepted
  expected: compiler diagnostic Unbound
  actual: value 42
FAIL located rejection expected, block accepted
  expected: compiler diagnostic Unbound at line 23, column 13
  actual: value 42
FAIL any rejection expected, block accepted
  expected: a compiler diagnostic
  actual: value 42
PASS lists
PASS positive
PASS positive, another value
FAIL negative, failing
  expected: a negative number
  actual: 42
7 passed, 8 failed
```

A detail that spans lines (USE-AFTER-MOVE's "moved here / used here") is
indented under its first line, so every line that starts a result starts
with PASS or FAIL.

## How it works

### The suite is an ordinary context; its state is an ordinary vector

```botlish
context struct Suite:
    cases: MutableVector[TestCase]
```

`with context test::suite()` installs one Suite (an ordinary immutable
struct value, installed once, at the entry program's top level: CONTEXTS.md).
Registration mutates the vector the context holds -- `suite.cases.push(...)`
through the registration function's context parameter, a *place* in
MUTABLE-VECTOR.md's sense -- never the context binding. The installed value
is a logical copy (`mv-context-installed-copy`), mutations through the
context parameter are visible to every later function that reads the
context (`mv-context-member`), and natively the vector's header is a
permanent GC root (`ctxroot`). Nothing else holds state: a module binding
is immutable (`MODULE-IMMUTABLE`), so the library has no place to keep a
registry outside the context even if it wanted one. A context struct's
fields must be fixed-slot eligible natively (CONTEXTS.md "Eligibility"):
a `MutableVector` is; a `str`, an unbounded `int`, a `List` or an `Fn`
field is not (`CONTEXT-NATIVE-LOWERING-UNSUPPORTED` on Cranelift only), which
is why the Suite has exactly one field and the names and checks live in its
elements.

### Registration authority comes from the context

```botlish
nomethod fn case(name: str, run: Fn{args: [], return: Match}, context suite: Suite) -> unit:
    suite.cases.push(TestCase {name: name, run: run})
```

Exactly two functions declare the Suite as their context parameter: `case`
(registration) and `registered` (the snapshot of the cases the runner reads).
Every other function's requirement -- every helper's, the runner's, a
suite's `register_*_tests()` -- is derived by the compiler from the call
graph. A call outside a suite is the ordinary MISSING-CONTEXT, with the call
chain that explains it, at the top-level call (`gf-context-required`):

```
suite.bot:7:1: test::Suite is required by this call but is not installed here (install it with "with context EXPR" before the call):
    test::value
     -> test::case
        directly requires test::Suite (CORE SEMANTIC MISSING-CONTEXT)
```

Why only two: a context implements, structurally, every context trait whose
operations its owner namespace's functions with that context parameter
spell (CONTEXT-TRAITS.md). The first library declared the context on every
helper, and a porter found an application trait `context trait Counted: fn
count() -> int` satisfied by the suite through `test::count` -- the suite
"interfered" through an ordinary rule, not a special one. With the context
declared by `case` and `registered` only, an application trait is satisfied
by the suite only if it is spelled exactly like one of those two
(`gf-context-trait-surface`: `count()` is not; `registered()` is).

Registration is explicit and deterministic: a test exists because ordinary
code called a registration function; registration functions compose as
functions (`gf-composition`); nothing is discovered, and importing a module
registers nothing (a module's top level has no executable statements, only
definitions and immutable bindings whose initializers must be context-free;
an initializer that registered would be MISSING-CONTEXT -- registration runs
only after the entry program installs the suite).

### The deferred test: a function value, because coroutines start eagerly

A registered case is `TestCase {name, run}`, `run` a function value of the
one uniform type `Fn{args: [], return: Match}` -- no parameters, no
declared errors. Registration stores it; only the runner calls it.

Botlish coroutines start eagerly: `coroutine {step, first} = f()` runs `f`
to its first yield before the statement completes (COROUTINES.md 15). A
registry of started coroutines would therefore run every test while
registering it -- `gf-eager-coroutine-start` pins the language fact the
design rests on (the probe fires at the construction). A function value
does nothing until called: it is the deferral. A body that wants a
coroutine constructs it when it runs (`gf-coroutine-body-deferred`: nothing
runs at registration, the coroutine's body runs once when the case runs).

Why `Fn{args: [], return: Match}` and nothing richer:

* **Uniform.** The vector holds one element type. A body's own result type
  varies (Int, List, String, struct), so the helpers wrap it: `test::value`
  defines a nested `check()` that calls the body, compares while the
  concrete type is still known, and returns a Match -- the one shape every
  case has. Nothing heterogeneous is stored, and no `any`-typed value
  crosses into the results.
* **No declared errors.** A function type with declared errors (or typed
  parameters) is *bearing* (`hir::callables::Bearing`), and a
  `MutableVector` of bearing elements is rejected at `length`, `at`,
  `empty?` and at the context installation itself ("has typed parameter
  requirements that cannot be preserved"). So the stored check completes
  normally, always -- which is exactly what a golden check should do: the
  one error a body may complete with, `compiler::CompilerError`, is turned
  into a mismatch inside `check()`.
* **No parameters, no context.** A function value cannot require a context
  (`CONTEXT-FUNCTION-VALUE`): a check cannot reach the suite while it runs
  (`gf-body-cannot-use-context`), so a test cannot register tests or
  observe the registry.

Alternatives rejected: storing started coroutines (eager: runs at
registration); storing `Fn{..., errors: [compiler::CompilerError]}` bodies
directly (bearing elements: the vector cannot be read); one vector per body
result type (no uniform registry, and no ordering across vectors);
`test(name, body, matcher)` with a matcher value (the matcher would need the
body's result type as a parameter type, and Botlish has no type variables:
an untyped matcher parameter is inferred `Fn{args: [any], ...}` and loses
nothing, but the pairing gives nothing over one helper per expectation
either, and three of the five expectations are not matchers of a value at
all); executing eagerly and storing results (violates deferral -- but see
"Runner poisoning" below: it is the one design the completion analysis
cannot poison).

### The runner is a coroutine

```botlish
fn run() -> List[TestResult]:
    loop c in registered():
        m = (c.run)()
        yield [TestResult {name: c.name, passed: m.matched, ...}]
    return []
```

(`registered()` is the List snapshot of `suite.cases`; the runner's own
requirement of the Suite is derived from that call.)

`coroutine {step, first} = test::run()` runs the first case (eager start)
and sends its result; each `step()` runs the next; the last segment sends
`[]` and completes. A coroutine's yields and its final return share one
outward type (`COROUTINE-RESULT-MISMATCH` otherwise) and Botlish has no sum
type with a payload, so "the next result" and "no more results" are a List
of one result and the empty List -- a batch, which also leaves room for a
future registered entry (a parameterized case) that produces several. The
alternatives each need a placeholder: a final `TestResult` that is not a
test, or a `{finished, result}` struct whose result is meaningless when
finished. The empty suite needs no special case: its construction completes
at once with `first == []` and `done?` true (`gf-empty-suite`).

The loop iterates a snapshot of the vector taken when it starts (a vector is
a value), so nothing a check does can change the run. `test::results()`
drains a run into a List; `test::report()` formats it. A driver may stop
early: the runner is an ordinary coroutine, released when its handle dies,
and the cases after the stop never run (`gf-runner-abandoned`).

The runner is a coroutine because the protocol is the natural one for
streaming, parameterized and generated cases later, not because a
coroutine does anything a loop could not do today: `test::results()` is a
plain function that drains it.

### Test coroutines

There is no per-test coroutine. It was considered and rejected: a coroutine
would give a test no isolation Botlish can observe -- a failed coroutine's
error is raised again at every resume, there is no way to observe "failed"
without re-raising, and the body's errors are already data by the time
`check()` returns (see the census). Tests that *use* coroutines construct
and drive their own, and ordinary ownership releases each one exactly once
whether it completes, fails (handled inside the body) or is abandoned
suspended (`gf-coroutine-cleanup`, the Tcl backends' release counters;
`gf-coroutine-cleanup-native`, released == created and none swept, also
under GC stress).

### Repeated runs, isolation, ordering

* **Repeated runs:** every start of the runner runs every registered case
  again, calling each check exactly once per run (`gf-repeated-runs`: two
  reports, two calls of the body). The stored checks are unrestricted
  function values; coroutines are never stored, so nothing is consumed.
* **Isolation:** a suite is a context, and a program installs a context
  type at most once (`DUPLICATE-CONTEXT`, `gf-one-suite-per-program`):
  suites are isolated by being separate programs. Two suite programs run
  one after the other in one process, each twice, never see each other's
  cases (`gf-isolation`, every backend) -- there is no state outside the
  context to leak through.
* **Order:** cases run, and report, in registration order
  (`gf-registration-order`).

### Results and matchers

A Match is `{matched, expected, actual, detail}`; a TestResult adds the
name. Texts are made while the concrete type is known (`describe`: Ints,
Strings as literals, Bools, Lists of those; anything else a placeholder --
there is no reflection), so a result never holds an arbitrary value and no
`any` result vector is needed. A mismatch is a value, never an error: the
run continues (`gf-failures-continue`: pass, value mismatch, pass,
diagnostic mismatch, pass are five results).

The compiler-error matchers compare `compiler::DiagnosticCode` -- never the
message, which a report shows as `detail` -- and, for `rejects_at`, the
primary line and column in the suite's own file. An enum has no String
form, so `test::code_name` spells all 87 cases; `gf-code-name-complete`
fails when `lib/compiler.bot` gains a case the table lacks.

### Framework errors versus test failures

A test failure is data (`passed: false`). The framework declares no error of
its own: none of its operations can fail with a declared error (the checks
complete normally by construction, the runner has nothing to fail with).
What can abort a run is outside every Botlish handler -- a run-time-only
failure in a body (`1 + "x"`, `mod(x, 0)`, a non-Boolean condition, a plain
call's arity, `==` of callables): the whole program fails, no report is
produced, and `tests/golden/run.tcl` reports the suite ABORTED, never as a
failed test (`gf-runtime-only-failure-aborts`).

### Exit status

Botlish has no exit-status facility (`linux::abi::syscall` can make
`exit_group` natively, in a standalone executable only; there is no library
function, and the Tcl backends cannot). A suite's value is its report, and
`tests/golden/run.tcl` interprets it: exit 1 when a test failed, a suite did
not compile, a run aborted or the backends disagree.

## Generic completion capture: what ordinary Botlish can observe

Before the matcher API was settled, the four things a deferred test may do
were tried out, on all three backends (the probes are summarized here;
`tests/golden-framework.test` pins the ones the framework depends on):

| a test body may... | ordinary Botlish can... |
|---|---|
| return a value | compare it generically: `==` in a generic helper, specialized per call site; a text of it for Ints, Strings, Bools and Lists (type tests); nothing else has a text without reflection |
| fail `compiler::CompilerError` | handle it generically: one nominal error with a structured payload (`code`, `primary`, `related`, `message`), handled by every helper |
| fail a declared application error | handle it only by name, inside the body (`on Boom {code}:`) -- or have the registration rejected at compile time |
| fail at run time without a declared error | nothing: the program aborts |

**1. Can ordinary library code generically observe an arbitrary thunk's
nominal error completion? No.** Handlers are nominal: `on _:` and `on any:`
are `UNDECLARED-ERROR` (unknown error), `on error:` and `on *:` syntax
errors; there are no guards, no multi-name handlers, no catch-all. A wrapper
must name an error to handle it, or declare it to propagate it. What the
compiler does instead is check: an untyped body parameter called as
`body()` gets an inferred, trusted contract (INTRINSIC-FUNCTION-CONTRACT-
INFERENCE.md) whose errors are the handlers around the call plus the
enclosing function's declared errors -- for `test::value`,
`Fn{args: [], return: any, errors: [compiler::CompilerError]}` -- and every
registration is checked against it (`gf-body-error-contract`):

```
suite.bot:14:30: argument for parameter "body" cannot be proven to satisfy Fn{args: [], return: any, errors: [compiler::CompilerError]}, the parameter type inferred from the function body (argument type: block(...)/0 -> int); error set incompatible: the callable may raise Boom, but the function type allows only [compiler::CompilerError]; ... (CORE SEMANTIC TYPE)
```

-- at the registration's argument, naming the error: a precise compile-time
answer, but a whole-suite one (the suite does not build).

**2. Can a coroutine runner inspect a failed child coroutine without naming
the error? No.** An unhandled error of a segment crosses the construction
or resume that ran it, as the ordinary error; the coroutine is then
terminally failed and every later resume raises the same cached error again
(COROUTINES.md 26-28). `coroutine::done?` is true for a completed and a
failed coroutine alike, and is the only query (`coroutine` has no other
member). There is no non-raising "completed or failed?" and no result
query; statically, every segment is charged with all of the root's declared
errors. A per-test coroutine would therefore isolate nothing; the runner
does not use one.

**3. Can callable specialization provide enough information for a reusable
matcher to handle the errors? It provides the check, not the handling.**
The inferred contract is verified per call site (above), and an
exact-callable argument of an *uncontracted* untyped parameter is even
"recovered" per call (STATIC-COMPLETION-PROOFS.md: the call analyzed as an
exact call of the argument). But there is no error polymorphism a library
could use to *handle* an error it does not name: the only generic
propagation is relational (the wrapper raises whatever its argument raises,
charged to its callers by name), which turns a stored registry back into a
named contract.

**4. Which run-time failures are not declared errors?** NOT-BOOLEAN (a
condition that is not a Bool), NOT-CALLABLE, a plain call's ARITY through an
untyped value, a native's argument TYPE (`1 + "x"`, even with constants),
ARITHMETIC (`mod(x, 0)`), EQUALITY (`==` of function values, MutableVectors,
MutableArrays -- run time, data-dependent, and misnamed "callables" in its
message), stack exhaustion (`TCL LIMIT STACK`, `NATIVE LIMIT STACK`), a
native's contract violation. None can be caught by a handler (declaring an
`error ARITHMETIC` and handling it intercepts nothing) and none carries a
source location; `static compile:` never turns one into a CompilerError (the
compiler accepts such a block; it fails when it runs). In a suite, one aborts
the whole run.

**5. What can be normalized without a second error system?**

* `compiler::CompilerError`, generically, by every helper: it is the one
  error a body may declare, and its payload is the structured diagnostic.
* Every declared error the test's author names, inside the body, with an
  ordinary handler that turns it into the value the test compares
  (`on IndexNotFound: "IndexNotFound"`, `on Failed {code}: code`): the
  EXPLICIT-ERROR-HANDLER pattern.
* An error that *escapes* a body's `static compile:` block: the body
  declares only CompilerError, so an escaping error is UNHANDLED-ERROR
  inside the block, which rejects the block -- the case fails with code
  UnhandledError, naming the error, and the suite builds
  (`gf-escaping-error-is-the-case-s`). A statically known failure is
  KNOWN-ERROR inside the block, likewise. This is the generic net
  `static compile:` gives a test, and it is why the convention puts the
  code under test inside one.
* Nothing else. A runner that did more would need a catch-all, a Result
  value reachable from source (`ok?`/`error?` exist as type tests, but no
  source construct produces a Result) or a test-only native: none was added.

### Runner poisoning: the one thing the census found that breaks a deferred registry

The completion analysis charges every call through a callable it cannot
identify -- a struct field, a vector element, a call result -- with the
program's *erased-callable contract*: the union of the declared errors of
every callable the program passes into an untyped parameter that has no
inferred contract (STATIC-COMPLETION-PROOFS.md, "Precision and the
erased-callable contract"). The contract is charged even when the call's
static type is `Fn{..., errors: []}`. The runner's `(c.run)()` is such a
call. So one test anywhere in a suite that exercises an untyped
higher-order function with an error-bearing callable makes the whole suite
fail to compile, inside the library:

```botlish
error E
fn raise_e(x: int) -> int errors E:
    if x > 0:
        fail E
    x
fn call(f, x):
    f(x)

fn register_poison(n: int):
    fn body() errors compiler::CompilerError:
        static compile:
            r = call(raise_e, n):
                on E:
                    7
            r
    test::value("poison", 7, body)
```

```
lib/test.bot:N:14: this call through a callable value the completion analysis cannot identify may produce the declared error "E" (this program passes a callable that declares it through an untyped parameter, and such a callable may reach this call), which is neither handled here nor admitted by the enclosing function's own "errors" declaration (CORE SEMANTIC UNHANDLED-ERROR)
```

The test's own block is accepted (its use of `call` is fully handled); the
diagnostic is the program's, at a location in the library that says nothing
about the cause. Every runner shape fails the same way -- a field call, a
call through a parameter (`run_fn(t.run)` is charged at the passing call),
a value yielded through a coroutine -- and only executing the bodies at
registration time (no stored callable) is immune. Wrapping the poisoning
code in `static compile:` does not help: an accepted block is part of the
program. This is a precision limit of the analysis, not a framework bug:
the stored checks' static type `Fn{args: [], return: Match}` is checked at
every store (`case`'s typed parameter, the struct field), but the analysis
does not trust a structural contract at an unidentified call. It is
recorded as NEW-FRAMEWORK-LIMITATION in the manifest wherever it kept a test
out, and as the first item of [Findings](#findings).

## The static-compile convention

A migrated test's body is a function of no arguments -- at the suite's top
level when it captures nothing, nested in its registration function when it
captures an input -- that declares `errors compiler::CompilerError` and
whose whole body is one `static compile:` block around the code under test
(`tests/golden/collections.bot`):

```botlish
fn b_unknown_field() errors compiler::CompilerError:
    static compile:
        p = Person {name: "Ada", age: 1, height: 3}
...
fn register_structs_tests():
    test::rejects_at("struct-error-unknown-field", compiler::DiagnosticCode::UnknownField, 216, 42, b_unknown_field)
```

Of the 218 body functions, 152 are top-level and 66 nested.

* **Accepted**, the block is its code (STATIC-COMPILE.md 13: the same HIR,
  NIR and machine code): `gf-nir-body-identical` compares the body's native
  code with the same closure written without the framework and without the
  block -- equal but for HIR ids.
* **Rejected**, the block is `fail compiler::CompilerError {...}`: the
  helper turns it into the expected outcome or into a mismatch naming code,
  location and message. A refactoring mistake in one test is one failing
  test, not a suite that does not build -- the TDD property.
* **Precision is the plain program's.** The body is compiled by the one
  compiler in the program it stands in (STATIC-COMPILE.md 7): the same range
  proofs, KNOWN-ERROR, error narrowing, affine analysis and method
  resolution as the same code called directly (`gf-precision-*`: identical
  verdicts in all five).

**Why the boundary stays explicit.** `static compile:` consumes syntax, not
values: by the time a library function receives a body it is a function
value whose code has been compiled with the program, so `test::value` cannot
put a boundary around it -- a rejected body would already have failed the
whole compilation. The only way to have the boundary is to write it where
the syntax is. The milestone records its cost rather than hiding it (the
boundary is two lines per test: the `errors compiler::CompilerError` clause
and the `static compile:` line; [Recurring boilerplate](#recurring-boilerplate)).

What it does not do: parse errors stay the program's (a malformed body
breaks the suite: `static parse:` does not exist), loader header errors and
top-level-only declarations cannot be inside a block, and some diagnostics
are anchored outside the block that causes them (MISSING-CONTEXT at the
top-level call, an instance's invalid call at the call, an unproven declared
result at the function): those are the suite's diagnostics, not the case's.

@@STATICSTATS@@

## Testing the framework

`tests/golden-framework.test` (40 tests) tests the library like any Botlish
program: each suite is compiled once and run on the Tcl interpreter, the Tcl
compiler and Cranelift, which must agree. What Botlish cannot observe is
observed from Tcl: how often a body ran, through a Tcl-side test native
`golden_probe(x)` on the Tcl backends and through the native allocation
sites at the body's line on Cranelift; coroutine releases through the Tcl
runtime's release counters and the native coroutine census.

| the brief's item 32 | tests |
|---|---|
| suite context required | `gf-context-required` (MISSING-CONTEXT, the ordinary diagnostic) |
| registration does not execute | `gf-registration-does-not-run` (probe: nothing), `-native` (no allocation at the body), `gf-registration-would-abort` (a body that would abort the program is registered and the program completes) |
| registration order | `gf-registration-order` |
| runner executes exactly once | `gf-run-executes-once` (probe: once) |
| pass result, mismatch result | `gf-verdicts` (every helper, both ways -- `rejects_any` and `rejects_at` given an accepted block too -- with the exact report text) |
| compiler error mismatch, exact code match | `gf-verdicts` (rejects, rejects_at, rejects_any, value with a rejected block, rejects with an accepted one) |
| context isolation between suites | `gf-one-suite-per-program`, `gf-isolation` |
| eager-coroutine deferral | `gf-eager-coroutine-start` (the language fact), `gf-coroutine-body-deferred` (the framework's answer) |
| coroutine cleanup | `gf-coroutine-cleanup`, `gf-coroutine-cleanup-native`, `gf-runner-abandoned` |
| affine captures | `gf-affine-capture-rejected` (negative), `gf-affine-capture-in-a-case` (the same inside a case: AffineCaptureUnsupported; a body owning its coroutine passes; UseAfterMove) |
| repeated-run policy | `gf-repeated-runs`, `-native` |
| empty suite | `gf-empty-suite` |
| several failures do not stop later tests | `gf-failures-continue` |
| also | `gf-runner-protocol`, `gf-composition`, `gf-application-context`, `gf-body-cannot-use-context`, `gf-body-error-contract`, `gf-escaping-error-is-the-case-s`, `gf-runtime-only-failure-aborts`, `gf-describe`, `gf-int-text`, `gf-code-name-complete`, `gf-gc-stress`, `gf-library-warning-clean`, `gf-precision-*` (5), `gf-nir-body-identical`, `gf-fuzz-bounded`, `gf-context-trait-surface` |

@@FRAMEWORKMUTATION@@

## The migration

### The sample

Eight suites, one per category, ported by reading each Tcl test's real
program and assertion (the helper procs resolved), choosing deliberately
across files and sub-features rather than the first tests in file order,
and including tests chosen because they were expected to be hard:

| category | Tcl tests ported | golden tests | Tcl tests examined, not portable |
|---|---|---|---|
| values | 25 | 32 | 4 |
| collections | 23 | 44 | 5 |
| diagnostics | 22 | 27 | 3 |
| errors | 17 | 23 | 4 |
| ownership | 13 | 37 | 5 |
| modules | 11 | 31 | 5 |
| representation | 11 | 14 | 4 |
| harness | 11 | 13 | 11 |
| **total** | **133** | **221** | **41** |

A Tcl test sampled by two categories is counted once, in the first (six
are: three ported, three not portable); counted in every category that
sampled it, modules, representation and harness ported 12 each, and
diagnostics found 4 and harness 13 not portable.

The sample overshot the brief's "about 100" (133 Tcl tests, 221 golden
tests): a Tcl test that checks several programs (a table of cases, a
program written two ways) became one golden test per program, and the
porters were asked for representative coverage of each category rather
than a count. It is still a sample -- about 2% of the Tcl suite's tests --
not a migration.

Every golden test passes on the Tcl interpreter, the Tcl compiler, generic
Cranelift and specialized Cranelift, the four executable paths the Tcl
suite's own differential tests use -- except that `representation.bot` (14
tests) aborts on generic Cranelift at one struct-shape case the generic
baseline does not support (NATIVE UNSUPPORTED struct-shape), and, as in the
Tcl harness, its specialized run stands in for the whole suite there. Every one of the 221
was also checked to be able to fail: each porter made a copy of its suite
with every expectation deliberately wrong (a value changed, another
DiagnosticCode, a column moved, a predicate flipped, a custom matcher's
text altered) and every test in every copy failed -- no golden test is
vacuous.

### The manifest

`tests/golden/manifest.tsv`, one row per golden test (a Tcl test that became
several has several rows) and one per Tcl test examined and not ported in
each category that examined it (44 rows for 41 Tcl tests): the
Tcl test, the golden test, category, outcome class, both tests' backends,
class and further classes, whether the static boundary is needed, whether
the body handles a run-time error, simple or custom API, verbosity,
strength against the Tcl test, line counts, the existing mutants the Tcl
test kills, and notes an auditor needs (what was renamed, what was adapted
and why, what is weaker). `tests/golden.test` fails when a suite reports a
test the manifest does not list, or the manifest lists one a suite does not
report.

### Classes

Per Tcl test (133 ported, 41 not), primary class and every class a row
names (a port is often an adaptation in two ways):

| class | primary, ported | primary, not ported | named at all |
|---|---|---|---|
| DIRECT | 48 | 0 | 52 |
| STATIC-COMPILE-ADAPTATION | 24 | 0 | 42 |
| EXPLICIT-ERROR-HANDLER | 3 | 0 | 5 |
| CUSTOM-MATCHER | 21 | 0 | 24 |
| HARNESS-DIFFERENCE | 36 | 0 | 68 |
| OLD-TEST-OVERSPECIFIED | 0 | 0 | 14 |
| NEW-FRAMEWORK-LIMITATION | 1 | 1 | 3 |
| COMPILER-BUG-FOUND | 0 | 0 | 0 (the compiler issues found are listed in [Findings](#findings): none made a ported test fail) |
| NOT-EXPRESSIBLE | 0 | 40 | 41 |

Further, per ported Tcl test:

| | |
|---|---|
| outcome | value 68, diagnostic 17, diagnostic with location 20, custom 20, run-time error 8 (golden tests: value 91, diagnostic 59, with location 37, custom 26, run-time error 8) |
| static boundary needed | 61 (a rejection, or an escaping error, is the subject); 72 use it by convention only (an accepted block) |
| explicit run-time-error handler in the body | 29 |
| API | simple helpers only 109, a custom check 24 |
| verbosity against the Tcl test | clearer 34, similar 67, more verbose 32 |
| strength against the Tcl test | equal 76, weaker 48, stronger 9 |
| lines | 1308 lines of Tcl tests became 2249 lines of golden tests (bodies and registrations; suite declarations and helpers not counted) |

**Weaker (48)**, by cause, from the manifest notes: the Tcl test also pinned
a message the port does not compare (the README rule: compare the code; the
message only when wording is the subject) or an embedded `FILE:LINE:COLUMN`
inside a message; a block reifies only its *first* diagnostic where the Tcl
test asserted a set (two UNDECLARED-ERRORs, both UNHANDLED-ERRORs of a
generic, an inner site's record); the Tcl test ran a native option matrix
(`-raw-int-abi-opt`, `-struct-opt`, ...) the golden runner cannot select; a
context test varied the installed value across programs (one installation
per type per program); a coroutine/affine test also asserted release counts
or an affine value as the program's result; a context-placement message
differs because a body is always a function; the Tcl test also pinned what
Botlish cannot observe (an allocation report, a NIR or ABI plan, HIR
completion facts); a sub-case or program of the Tcl test was not ported (an
operator passed as a value has no source spelling, a third program of a
table). **Stronger (9):** a Tcl test compiled with `-strict 0` and never
looked at diagnostics, or folded its operands at compile time, where the
golden test is a strict program with undecidable inputs (2); the golden
test checks a value the Tcl test only asserted compiles (1), pins a value
where the Tcl test only checked that the backends agree (2), or also pins a
diagnostic code or location the Tcl test left out (4).

**Not portable (41)**, by reason (each row's note has the verified
reproducer):

| reason | Tcl tests |
|---|---|
| the subject is a run-time-only failure (NOT-BOOLEAN, a plain call's ARITY, a native's TYPE, RANGE, stack exhaustion): it would abort the suite | 10 |
| what Botlish cannot observe: HIR or Core IR text, allocation counts, release order or live frames, display text, warnings, bytes on a descriptor | 9 |
| a parser, loader-header, declaration or top-level-only error (no block holds one) | 6 |
| several programs or installations (installation variants, argv injection, hash stability across two declarations), or a diagnostic anchored outside any block (MISSING-CONTEXT, DUPLICATE-CONTEXT) | 6 |
| a private module the test writes (a suite imports only `lib/`) | 3 |
| a Core IR program with no surface spelling (Result values, `break VALUE`, unchecked IR) | 3 |
| a body is a function value and a nested scope: it cannot yield, and a trait-polymorphic function inside it is TRAIT-NESTED-POLYMORPHIC | 2 |
| no source spelling for the datum (a String holding U+0000) | 1 |
| the erased-callable runner poisoning (NEW-FRAMEWORK-LIMITATION) | 1 |

### Answers

| question (item 75) | answer |
|---|---|
| used only the simple public API | 109 of 133 Tcl tests (82%) |
| needed a custom matcher | 24 (2 direct `test::case` checks, the rest through 9 suite-local helpers built on it, in 6 suites: message matchers in collections, diagnostics, errors, modules, ownership and representation, and related-location and call-chain matchers in ownership) |
| needed explicit run-time-error handling | 29 |
| needed explicit `static compile:` | all 133 use it (the convention); 61 need it to express the test |
| could not be expressed | 41 examined (40 NOT-EXPRESSIBLE, 1 NEW-FRAMEWORK-LIMITATION), beside the 133 ported |
| became clearer | 34 |
| became significantly more verbose | 32 |
| exposed a framework limitation | 3 rows, and 14 findings during porting ([Findings](#findings)), 5 of them fixed in the library during the milestone |
| exposed an existing compiler bug | no ported test fails; porting found 6 compiler defects or precision gaps and 6 smaller inconsistencies ([Findings](#findings)) |

@@SIDEBYSIDE@@

@@PERF@@

## Recurring boilerplate

Counted mechanically over the final suites (`audit/golden/tools/census.tcl`)
and from the porters' reports:

| pattern | occurrences | lines each | what it is |
|---|---|---|---|
| the static boundary: `static compile:` | 221 (every golden test) | 1, plus one indentation level for the code | the convention; necessary in 61 Tcl tests' ports, conventional in the rest |
| the body's error clause: `fn NAME() errors compiler::CompilerError:` | 218 bodies | 1 | a body must admit the one error a rejected block completes with |
| a named body per test, and its registration line | 218 bodies, 200 library registrations + 34 suite-helper registrations | 2 | Botlish has no anonymous function expression: every deferred body is a named function, named again in the registration |
| registration functions | 83 | 2+ | 74 one per Tcl file ported, 8 suite drivers, 1 per-test helper (the composition mechanism) |
| run-time error normalization: an `on E:` handler inside a body | 90 handlers | 2-3 each | a body may complete only normally or with CompilerError |
| inputs routed through registration parameters | in every run-time-error suite | 1-3 | so the completion proofs cannot decide the failure (KNOWN-ERROR) or fold the arithmetic |
| top-level declarations, renamed per suite (`Dg*`, `Md*`, ...) | 74 | 3-15 | declarations are top-level only; one suite holds many tests' declarations |
| suite-local helper functions | 56 (message matchers in 6 suites, String search, a coroutine log driver, shared code under test) | 5-40 | what the library does not provide |
| absolute suite-file locations in `rejects_at` and custom checks | 36 `rejects_at` + 14 custom | 0 (but re-derived after every edit above them) | a diagnostic's primary location is in the suite's coordinates |
| the suite context: `with context test::suite()` and the driver | 8 (one per suite) | 3 | entry program top level |
| hoisting bodies to the top level, ordering a "global" body first | every suite with more than one rejection (representation.bot's single rejected body stays nested) | 0 lines, but a layout rule | the static decision rounds' cost model ([Performance](#performance)) |
| a coroutine-log driver replacing `test-log` effects | 5 bodies (values), 2 (harness) | 7 | evaluation order observed through a yielding log |
| two spellings of one program (destructured/explicit, method/free, elif/nested) | 9 Tcl tests | a whole body each | the Tcl tests looped over spellings; a body is one program |

The fixed per-test cost of the convention is three lines -- the body's
`fn` line with its error clause, the `static compile:` line and the
registration call -- plus one indentation level. Everything else above is
either a missing library helper (message and related-location matchers,
String search) or a property of the language a test inherits (no anonymous
functions, top-level-only declarations, exact-value facts deciding constant
inputs, one installation per context type).

## Findings

Everything the milestone found, in three groups. Nothing in the compiler
was changed: each compiler finding is recorded with a reproducer for its
own milestone.

### Framework limitations (the library, as the language allows it)

1. **Runner poisoning by the erased-callable contract** ([above](#runner-poisoning-the-one-thing-the-census-found-that-breaks-a-deferred-registry)).
   A test that passes an error-declaring callable through an untyped
   parameter -- even a coroutine, which is always specialized and never
   actually erased (ownership's `af-generic-errors`) -- makes the whole
   suite fail to compile, at the runner's `(c.run)()` in lib/test.bot. One
   Tcl test is not ported for it; two ports moved the poisoning helpers
   inside their block. Every deferred registry shares it; only executing
   bodies at registration avoids it.
2. **A run-time-only failure aborts the suite.** A body (or a mutant) that
   reaches `1 + "x"`, `mod(x, 0)`, a non-Boolean condition, a plain call's
   arity, `==` of callables or a stack overflow ends the whole run with no
   report; `run.tcl` reports the suite ABORTED. Correct, honest, and without
   per-test attribution.
3. **`test::describe` is partial.** Botlish's `==` is partial (functions,
   MutableVectors and MutableArrays raise EQUALITY at run time) and there is
   no `bool?` or `callable?` kind test, so describing a function value
   aborts the run (describe recognizes a Bool by `v == true`). It happens
   only when a body unexpectedly evaluates to a function; structs, enums and
   chars are described as a placeholder, so a struct mismatch shows two
   identical placeholder lines.
4. **Locations are absolute suite coordinates.** `rejects_at` pins line and
   column of the suite file; every edit above a pinned test moves it (the
   porters re-derived 36 `rejects_at` and 14 custom locations with scripts).
   A Tcl test pins a location in a tiny program. A CompilerError location
   relative to its block's origin would remove the brittleness (a compiler
   change: [Recommendations](#recommendations)).
5. **Compile cost of static decisions** ([Performance](#performance)):
   rejected blocks in one top-level unit are decided one whole-program
   build per round; a build with an erased-callable contract decides one
   block per round for the whole program (`hir::static::GlobalChannels`);
   each round re-runs the method-sugar decision builds. As first written,
   the collections suite took 81 builds (~150 s) and ownership 178
   (~260 s); with bodies hoisted to the top level and the one "global" body
   placed first, 11 and 26 builds. The suites' layout follows the compiler's
   cost model -- a rule a test author must know.
6. **No message, related-location or substring matcher.** Six suites
   (collections, diagnostics, errors, modules, ownership, representation)
   wrote their own on `test::case` (24 Tcl tests needed one). Candidates
   for the library: `rejects_message`, `rejects_related`, and a String
   `contains`.
7. **Bodies are called through parameters, never directly**, so a property
   of a *direct* call of a function whose block was rejected is invisible to
   the helpers (the static-compile mutant `known-error-rejects-reified`
   makes such a direct call KNOWN-ERROR; a suite notices it only where a
   custom check calls its body directly).
8. **Contexts.** A body cannot need a context: context-dependent code runs
   in the registration function and the body compares what it computed
   (HARNESS-DIFFERENCE, eager evaluation of the code under test); a program
   installs one value per context type and one implementation per context
   trait, so a Tcl test that varies an installation across programs ports
   one variant.
9. **A body is a function value and a nested scope**: it cannot yield
   (UNWRAPPED-YIELD at the registration), an untyped helper given an affine
   argument inside it is AFFINE-GENERIC-NESTED-UNSUPPORTED (such helpers live
   at the suite's top level), and a body whose *value* is affine cannot be
   registered: `test::value` compares it with `==`
   (AFFINE-EQUALITY-UNSUPPORTED) and the helpers that describe it pass it
   through an `any` field (AFFINE-ERASURE-UNSUPPORTED), both at the
   registration.
10. **Suite-wide imports shape every body.** A body's method calls resolve
    against the suite's imports: `import str` (for a message matcher) adds
    `str::length` as a candidate of `queue.length()`, turning a block's
    USE-AFTER-MOVE into NO-APPLICABLE-METHOD; a MissingImport message
    mentions the suite's other imports.

Fixed in the library during the milestone (each found by porting): the
report silently dropped a test when a coroutine runtime bug lost the
runner's first segment (the report now fails a run whose result count
differs from the registered count); describing a long String overflowed
Tcl's stack on the interpreter (escaping and joining are now iterative, and
`run.tcl` raises the recursion limit as the Tcl suite does); a multi-line
compiler message broke the report's line structure (continuation lines are
indented); the suite context satisfied an application's context trait
spelled like `count()` (only `case` and `registered` declare the context
now, `gf-context-trait-surface`); the first library spent most of its
compile time in method-sugar trial builds (`.length()`, `.at()` with three
candidates) and in an 87-branch `elif` chain (4.4 s per build, now 0.9 s).

### Compiler defects and precision gaps

| # | finding | reproducer | effect here |
|---|---|---|---|
| C1 | A semantic instance's checks run on a branch a type test decides dead, with the binding un-narrowed: `hir::refine::branchFacts` gives the impossible outcome no facts, and `hir/range.tcl`'s call verification still checks calls there | `fn g(text: str) -> int: text.length()` / `fn f(v): if string?(v): g(v) else: 0` / `[f(3), f("abc")]` is TYPE ("call to f with v : int is invalid ... (in the body of f, at 6:11)"); with a native (`v.length()`) instead of `g` it runs | `test::describe` passes its argument through an `any` struct field first |
| C2 | Chained method sugar on Strings fails when a trait-polymorphic function of the same name is visible | `import io::path` / `import str` / `"x".concat("y").concat("z")` is NO-APPLICABLE-METHOD naming `str::concat: argument for parameter "path" does not satisfy trait io::path::Path` (str::concat has no such parameter); without `import io::path`, `"xyz"` | a suite helper wrote `str::concat(str::concat(a, b), c)` |
| C3 | The erased-callable contract is charged to calls whose static type is a checked structural contract (`Fn{..., errors: []}`), and includes the declared errors of coroutines, which are always specialized and never reach an erased call | [Runner poisoning](#runner-poisoning-the-one-thing-the-census-found-that-breaks-a-deferred-registry); ownership's `poison2.bot` (a coroutine given to `invoke(c, m): c(m)` poisons `(b.run)()` of an unrelated `Fn{args: [], return: int}` field) | framework limitation 1 |
| C4 | Untyped parameter contract inference is path-insensitive: a result requirement is charged to the parameter although every path returning it is guarded | `type Small = Int in 0..10` / `fn check(n) -> Small errors TooBig: if n > 10: fail TooBig elif n < 0: fail TooBig else: n` called with an `int` is TYPE (with `n: int` it is proven) | one port types the parameter |
| C5 | COROUTINE-RESUME-CONFLICT (and COROUTINE-RESUME-UNDERCONSTRAINED, the call form of UNWRAPPED-YIELD) name further locations only in their message text; their reified `related` is `[]` -- the convention AGENTS.md states for diagnostics with further locations | a block whose function reaches two yielding helpers declaring different `resume` types: `related` is `[]`, the two call locations are in `message` | a custom check parses the message |
| C6 | `mutable_vector::length` accepts a List statically (with only `import mutable_vector`, `[1, 2].length()` compiles) and fails at run time | `import mutable_vector` / `[1, 2].length()`: run-time TYPE `mutable_vector::length: expected mutvec` | porters import `list` everywhere |

Smaller inconsistencies: EQUALITY's run-time message says "callables" for
MutableVector and MutableArray values; a non-Int loop bound's run-time
message differs by backend ("loop start: expected int" on the Tcl backends,
"loop: expected int" natively); the strict compiler accepts a provable
NOT-BOOLEAN (`fn f(x: int): if x: ...`) and a direct call with the wrong
arity (`zero(1)`) while the indirect forms are static TYPE errors (both
documented as run-time-only, STATIC-COMPILE.md's census, but asymmetric); a
closure capturing a context parameter observes the context's later
mutations (a snapshot needs an explicit `snap = suite.cases`); the stale
mutant `stdout-stderr-swapped` of `audit/contexts/tools/mutate.tcl` no
longer applies (lib/linux/io.bot changed); `native::allocationText` omits
Struct, Coroutine and ListPlan from its "by kind" line.

### Old tests

Fourteen Tcl tests were found overspecified for their property (an uncalled
function in the program that alone kills a mutant, a message asserted where
the code is the property, a diagnostic set where the first diagnostic is the
subject), recorded OLD-TEST-OVERSPECIFIED. Some Tcl tests are weaker than
they look: `native-int-2`'s `9223372036854775807 + 1` is folded at compile
time by exact-value facts, so its four-backend agreement checks the folder,
not each backend's run-time i64 overflow (the golden test adds a
`/dynamic` variant whose operands come through a parameter); several
`errors.test` programs are KNOWN-ERROR under strict compilation and pass
only because their helper compiles with `-strict 0` and never reads the
diagnostics.

@@RECOMMEND@@

## Not implemented

Deliberately, as the brief's non-goals: test syntax of any kind (`test`,
`expect`, `assert`, `suite`, `setup`/`teardown`, attributes); macros,
syntactic functions or implicit `static compile:` wrapping; `static parse:`;
a catch-all error, error subtyping, an `AnyError`, a Result reachable from
source, a test-only completion-capture native; a global registry, discovery,
registration on import; parallel execution, worker pools, scheduling;
filtering, tags, skip/only/focus; snapshot or golden files; timeouts;
property testing, fuzzing as a framework feature, oracle or theorem modes;
JUnit/TAP/JSON reporters; a `botlish test` command; the mass migration;
removing, skipping or weakening any Tcl test. The architecture leaves room
for the later ones: a parameterized, fuzzed or oracle case is one more
producer of batches of results in the runner's protocol, and one more
matcher is one more function returning a Match.

## Files

| file | what |
|---|---|
| `lib/test.bot` | the library |
| `tests/golden-framework.test` | the framework's tests (40) |
| `tests/golden/*.bot` | the golden suites: the ported tests |
| `tests/golden/manifest.tsv` | the migration manifest |
| `tests/golden/README.md` | the porting guide |
| `tests/golden/run.tcl` | runs suites on every backend, interprets reports |
| `tests/golden.test` | the suites inside the Tcl suite, against the manifest |
| `audit/golden/tools/fuzz.tcl` | the framework's model-based fuzzer |
| `audit/golden/tools/mutate.tcl`, `mutants.txt` | the framework's mutants |
| `audit/golden/tools/check.tcl` | old and new tests side by side; existing mutants against both |
| `audit/golden/tools/census.tcl` | the boilerplate census of the suites |
| `audit/golden/tools/tree.tcl` | the private-tree machinery the tools share |
| `bench/golden-framework.tcl` | the performance report |
| `audit/refactor/manifest.txt` | `lib/test.bot`'s gate entry (as `lib/io.bot`'s: its last declaration needs a context) |
| `.github/workflows/tests.yml` | the `golden` job |

## What to run when changing this

If you change `lib/test.bot`: `tests/golden-framework.test`,
`tests/golden.test`, `tclsh9.0 tests/golden/run.tcl`,
`audit/golden/tools/fuzz.tcl` (several seeds, once with `-gc-stress 1`),
`audit/golden/tools/mutate.tcl` (every mutant must still apply and be
killed), and the warning gate. If you change a diagnostic, the
`compiler::DiagnosticCode` enum (`gf-code-name-complete` holds
`test::code_name` to it) or the completion analysis: `tests/golden.test`
and `audit/golden/tools/check.tcl`. A golden suite's `rejects_at` pins a
line of its own file: a line added above it moves the location.
