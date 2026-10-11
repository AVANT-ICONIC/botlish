# GOLDEN-TEST-FRAMEWORK.md

A golden test framework for Botlish, written in Botlish: `lib/test.bot`, an
ordinary library, and a validation sample of the Tcl suite ported to it.

> Can an ordinary Botlish library, using the language's existing functions,
> contexts, mutable values, coroutines, payload errors, matchers and
> `static compile:`, express a practical golden-testing workflow for real
> Botlish tests without adding test-specific language syntax?

**Yes, with limits the language sets, not the library.** `lib/test.bot` is
an ordinary library -- a context struct holding a `MutableVector` of
deferred function values, a coroutine runner, structs for results, and
`static compile:` at each test -- with no test syntax, no test-only native,
no catch-all error and no hidden registry. 133 Tcl tests, chosen to be
representative and hard, became 221 golden tests that pass on the Tcl
interpreter, the Tcl compiler and Cranelift (generic and specialized). On
one checkout, every ported Tcl test and its golden tests pass side by side;
under 21 existing compiler and runtime mutants, the golden suites caught
every mutant the Tcl tests caught (18 per test, 3 only as a whole suite
that aborts or does not compile). The framework's own 20 mutants are all
killed, and its fuzzer agrees with an independent model on 466 generated
cases. Natively a case costs one to five microseconds; the cost of the approach is compile time, which the static decisions dominate (a layout rule keeps it to seconds a suite).

The limits: a library cannot observe an arbitrary run-time error it does not
name (handlers are nominal; there is no catch-all), and a run-time-only
failure (NOT-BOOLEAN, a native's TYPE, ARITHMETIC, ...) aborts the whole
suite; 41 of the 174 Tcl tests examined test what Botlish cannot observe or
express (IR text, allocation counts, warnings, parse errors, several
programs) and stay in Tcl; and one precision gap of the completion analysis
-- the erased-callable contract charged to a call through a checked
structural contract -- can stop a deferred registry from compiling.
Recommendation: the large-scale migration, after three general compiler
improvements (static-decision compile cost, block-relative diagnostic
locations, that precision gap), with the Tcl suite kept as an independent
oracle; no test syntax; and, if any language feature, a general anonymous
function expression with an inferred error contract, which would remove two
of the three lines every test repeats ([Recommendations](#recommendations)).

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

### The convention in numbers

Over the eight suites (`hir::static::decide`'s own record of each block,
`staticSites` and `staticRounds`):

| suite | blocks | accepted | rejected | decision rounds | whole builds (decisions and method-sugar trials) | compile (s, quiet machine) |
|---|---|---|---|---|---|---|
| collections.bot | 44 | 22 | 22 | 3 | 11 | 13.4 |
| diagnostics.bot | 28 | 0 | 28 | 5 | 12 | 13.0 |
| errors.bot | 25 | 14 | 11 | 4 | 7 | 7.8 |
| harness.bot | 14 | 12 | 2 | 2 | 3 | 2.3 |
| modules.bot | 33 | 7 | 26 | 3 | 6 | 13.1 |
| ownership.bot | 37 | 13 | 24 | 4 | 26 | 36.2 |
| representation.bot | 14 | 13 | 1 | 2 | 4 | 5.1 |
| values.bot | 26 | 26 | 0 | 1 | 2 | 6.0 |
| **total** | **221** | **107** | **114** | 1-5 | **71** | **97.1** |

The 114 rejected blocks span 40 diagnostic kinds (TYPE 13, UNBOUND 10,
CONTEXT-TRAIT-MISUSE 8, OPAQUE-REPRESENTATION 8, KNOWN-ERROR 7,
UNHANDLED-ERROR 7, USE-AFTER-MOVE 5, CONTEXT-INSTALLATION-UNSUPPORTED 5,
AFFINE-LIST-OPERATION-UNSUPPORTED 4, and 31 more with 1-3 each). Every one is
an expected outcome of its test: no golden test passes because a block it
expected to be accepted was rejected (`test::value` and `test::holds` report
an unexpected rejection as a FAIL with the diagnostic). A decision round is
one whole-program build with the blocks decided so far in place; after the
layout rule of `tests/golden/README.md` (bodies in separate top-level units;
in ownership.bot, the one rejected body whose code gives the program an
erased-callable contract placed first, so that the contract is gone after
the first round) no suite needs more than five.

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

### Framework mutants

`audit/golden/tools/mutants.txt` holds 20 deliberate bugs in `lib/test.bot`,
one per property the framework claims; `audit/golden/tools/mutate.tcl`
applies each to a private copy of the checkout and runs the framework's
tests, the model-based fuzzer (4 programs, seed 11, interp, compile and
Cranelift) and every golden suite there. **All 20 are killed.** Before the
run, each mutated library was compiled with a small suite and shown to
change its report -- one mutant (`suite-starts-with-stale-case`) did not
compile at first (its stale check called a function declared later in the
file, a forward reference), which would have "killed" it vacuously; it was
fixed and run again.

| mutant | the bug | framework tests failing | fuzz disagreements (0: the 4-program run did not notice it) |
|---|---|---|---|
| `registration-executes` | registering a case calls its check at once, before storing it | 11 | 0 |
| `registration-drops-one` | registering the second case of a suite stores nothing | 13 | 12 |
| `registration-reorders` | registering a case puts it first, moving the former first case to the end | 11 | 12 |
| `runner-skips-last` | the runner does not run the last registered case | 25 | 12 |
| `runner-runs-twice` | the runner calls every check twice, reporting the second result | 9 | 0 |
| `runner-stops-at-mismatch` | the runner stops after the first failing case (fail-fast) | 5 | 9 |
| `mismatch-marked-passed` | a result is recorded as passed whatever its check found | 9 | 12 |
| `value-compares-wrong-operand` | the value matcher compares the expected value with itself | 4 | 6 |
| `code-matcher-accepts-any` | the diagnostic-code matcher accepts any code | 3 | 0 |
| `location-matcher-ignores-column` | rejects_at compares the code and the line, not the column | 2 | 0 |
| `any-rejection-accepts-values` | rejects_any passes a body that completed normally | 2 | 9 |
| `rejection-passes-value` | value passes a body whose block was rejected | 6 | 3 |
| `suite-starts-with-stale-case` | a new suite already holds a case, as if one leaked from an earlier suite (the library cannot keep a mutable value outside the context: a module binding is immutable) | 25 | 12 |
| `summary-miscounts` | the summary counts every result as passed | 5 | 12 |
| `int-text-drops-sign` | a negative Int is shown without its sign | 3 | 9 |
| `escape-drops-quote` | a quotation mark inside a described String is not escaped | 2 | 0 |
| `code-name-shifted` | a diagnostic code is named by its neighbour's name (Type reads as Unbound) | 4 | 6 |
| `describe-drops-bool` | a Bool is described as a value with no text form | 1 | 0 |
| `count-declares-context` | count declares the Suite context itself, so an application context trait spelled like it is satisfied by the suite | 1 | 0 |
| `report-drops-detail` | a mismatch's detail line is left out of the report | 4 | 3 |

Every mutant is killed by at least one framework test; the weakest by one
(`describe-drops-bool` by `gf-describe`, `count-declares-context` by
`gf-context-trait-surface`). `any-rejection-accepts-values` was first
killed only by the fuzzer's bounded run (`gf-fuzz-bounded`): `gf-verdicts`
now also registers `rejects_at` and `rejects_any` with an accepted block,
and kills it too (re-run after the change; mutants run before it may show lower counts). The golden suites detect `runner-skips-last`
on their own (every suite reports "FAIL the run": the completeness check),
and a mutant that changes no verdict (`registration-executes`,
`runner-runs-twice`) is invisible to them by design -- those properties are
pinned by the framework tests' probes and allocation counts.

### Framework fuzzing

`audit/golden/tools/fuzz.tcl` generates suites of 0-12 cases registered
through two or three registration functions, each case a random helper over
a valid body (an Int sum, a List, a String) or a deliberate fault (an
unbound name, a TYPE argument, a KNOWN-ERROR call, a USE-AFTER-MOVE, an
unknown field), with an expectation that matches or deliberately does not.
An independent model -- sharing no code with `lib/test.bot` or the compiler
-- predicts the whole report: registration order, every verdict, the
expected and actual texts (values, codes, the fault's line and column, the
first line of the message for the faults whose message it knows) and the
summary. Every backend must produce exactly the predicted
report.

| run | programs | cases (passing / failing) | backends | disagreements |
|---|---|---|---|---|
| seed 101 | 20 | 136 (71 / 65) | interp, compile, cranelift, cranelift-generic | 0 |
| seed 202 | 20 | 117 (52 / 65) | interp, compile, cranelift, cranelift-generic | 0 |
| seed 303 | 20 | 98 (45 / 53) | interp, compile, cranelift, cranelift-generic | 0 |
| seed 404, `-gc-stress 1` | 20 | 115 (50 / 65) | cranelift, cranelift-generic | 0 |

466 generated cases, none in disagreement with the model; `gf-fuzz-bounded`
runs a bounded campaign inside the framework's tests, and the fuzzer killed
13 of the 20 framework mutants on its own (the table above).

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

## Side-by-side agreement and the mutation spot-check

### Agreement on the unmutated tree

`audit/golden/tools/check.tcl` runs every ported Tcl test (each test file in
its own `tclsh`, `-match` on the manifest's names, a private `-tmpdir`) and
every golden suite on the same checkout, and pairs them by manifest row. An
old test counts as passing only when tcltest reports it passed by name
(`-verbose p`): a misspelled or constraint-skipped name is `not-run`, a
disagreement. (The first version of the tool read "not reported failing" as
passing; the verdict below is the stricter tool's.)

| rows | old test files | golden suites | old pass, new pass | any other pair |
|---|---|---|---|---|
| 221 | 56 | 8 | 221 | 0 |

The golden suites ran on all four backends (interp, compile,
cranelift-generic, cranelift) in that run, and in `tests/golden.test` inside
both full regression runs.

### Mutation spot-check

21 existing mutants from nine mutation harnesses, chosen to span the
sample's subjects (static-compile reification, enums, error payloads,
MutableVector and MutableArray value semantics, coroutines, affinity,
context traits, traits), one native. For each, `check.tcl -mutants` builds
a private copy of the checkout with the mutant applied (and rebuilds the
native backend for the native one), runs the Tcl tests of the manifest rows
that name the mutant, and runs every golden suite on all four backends.
Verdicts: **BOTH** (an old and a related golden test fail), **BOTH-SUITE-LEVEL**
(an old test fails; the golden side detects the mutant only as a suite that
does not compile, aborts or disagrees, or in a test of another row),
**OLD-ONLY** (a weaker port), **NEW-ONLY**, **NEITHER**.

| harness, mutant | related rows | verdict | rows whose Tcl test fails | rows whose golden test fails | golden tests of other rows failing / suites not ok |
|---|---|---|---|---|---|
| static-compile `wrong-code` | 4 | **BOTH** | 4 | 4 | 94 / - |
| static-compile `loses-primary` | 4 | **BOTH** | 4 | 4 | 45 / - |
| static-compile `success-returns-unit` | 2 | **BOTH** | 2 | 2 | 108 / - |
| static-compile `runtime-errors-wrapped` | 1 | **BOTH** | 1 | 1 | 34 / - |
| static-compile `known-error-disabled` | 1 | **BOTH** | 1 | 1 | 3 / - |
| static-compile `keeps-runtime-wrapper` | 2 | **BOTH** | 2 | 2 | 0 / - |
| static-compile `loses-related` | 1 | **BOTH** | 1 | 1 | 1 / - |
| enums `equal-ignores-enum-tcl` | 3 | **BOTH** | 3 | 3 | 0 / collections=disagree, values=disagree |
| enums `equal-by-ordinal-tcl` | 3 | **BOTH** | 3 | 3 | 0 / collections=disagree, values=disagree |
| enums `bare-case-accepted` | 3 | **BOTH** | 3 | 1 | 0 / - |
| error-payloads `renaming-binds-original` | 2 | **BOTH** | 2 | 1 | 0 / - |
| error-payloads `missing-payload-accepted` | 1 | **BOTH** | 1 | 1 | 0 / - |
| mutable-vector `share-aliases-tcl` | 1 | **BOTH** | 1 | 1 | 1 / collections=disagree |
| mutable-array `struct-extraction-aliases` | 6 | **BOTH** | 6 | 4 | 0 / - |
| coroutines `two-protocols-accepted` | 2 | **BOTH** | 2 | 2 | 0 / - |
| coroutines `first-yield-discarded` | every | **BOTH** | 15 | 19 | 0 / collections=disagree, diagnostics=disagree, errors=disagree, harness=disagree, modules=disagree, ownership=disagree, representation=disagree, values=disagree |
| affine `struct-affine-unrestricted` | 3 | **BOTH-SUITE-LEVEL** | 3 | 0 | 0 / ownership=aborted |
| affine `any-erasure-hides` | 11 | **BOTH** | 11 | 2 | 1 / - |
| context-traits `witness-leaks-into-source` | 9 | **BOTH-SUITE-LEVEL** | 9 | 0 | 0 / modules=compile-error |
| traits `mix-witnesses-at-join` | 2 | **BOTH-SUITE-LEVEL** | 2 | 0 | 0 / modules=compile-error |
| error-payloads `whole-binding-loses-field-native` | 1 | **BOTH** | 1 | 1 | 0 / diagnostics=disagree, errors=disagree, harness=disagree, ownership=disagree |

**21 mutants: 18 BOTH, 3 BOTH-SUITE-LEVEL, no OLD-ONLY, no NEW-ONLY, no
NEITHER.** The golden suites detect every mutant the Tcl tests detect.
"Related rows" are the manifest rows whose `mutants` column names the
mutant (`first-yield-discarded` is named by none -- the Tcl tests that
kill it are not in the sample -- so every row is checked). A row counts as
failing on the golden side when its test FAILs on any backend; a suite that
does not compile gives its tests no verdict.

* **Suite-level (3).** `struct-affine-unrestricted`: blocks that must be
  rejected are accepted and then fail at run time with EQUALITY, a
  run-time-only failure, so `ownership.bot` aborts on every backend
  (framework limitation 2). `witness-leaks-into-source` and
  `mix-witnesses-at-join`: the block is accepted, and the misuse the
  removed check would have reported surfaces later, in the monomorphized
  program (an UNBOUND, a TYPE), which the static decision does not see --
  the suite does not compile. Each is a detection, without the per-test
  attribution the Tcl test has; the manifest rows say so.
* **Per row.** Where a Tcl test became several golden tests (one per
  program), a mutant that breaks one of the programs fails the Tcl test and
  only the golden test of that program: `any-erasure-hides` fails 11 rows'
  Tcl tests (two Tcl tests, `af-list-operations` and `af-restrictions`)
  and 2 golden tests (`/mixed` and `/any-parameter`, plus
  `co-storage-frontier/any` of another row). Counted per Tcl test
  (`check.tcl` lists every row whose Tcl test fails while its golden test
  does not), every Tcl test a BOTH mutant fails has a failing golden test of
  its own, with two exceptions. `ep-principal-ints` under
  `renaming-binds-original`: the Tcl test fails only through an uncalled
  `rename` function of its shared prelude, which the port leaves out
  (OLD-TEST-OVERSPECIFIED; golden `ep-principal` kills the mutant). And
  under `first-yield-discarded` (a Tcl-runtime mutant), the 8 coroutine,
  affine and vector Tcl tests of `ownership.bot`'s rows (`co-principal`,
  `co-principal-move`, `co-errors-segment`, `af-principal-callable`,
  `af-aggregate-field-read`, `af-generic-errors`, `mv-loop-consumes`,
  `mv-affine-swap-failure`) are matched only at suite level: on the Tcl
  backends a body's coroutine resumes with unit and projects `.value` of
  it, a run-time TYPE no handler catches, so `ownership.bot` aborts there
  and its only verdicts come from Cranelift, which the mutant does not
  touch. 19 golden tests of the other suites fail per test under the same
  mutant.
* **Collateral.** The golden suites fail many more tests than the related
  rows under the static-compile mutants (94 under `wrong-code`, 108 under
  `success-returns-unit`): every golden test goes through
  `static compile:`, so a bug in the boundary reaches all of them. The
  framework's own transport is ordinary Botlish too -- the runner is a
  coroutine, a rejection travels as the payload error
  `compiler::CompilerError` -- so coroutine and payload mutants also make
  suites disagree across backends (`first-yield-discarded`,
  `whole-binding-loses-field-native`): a broader net than the Tcl tests',
  with less precise attribution.

## Backends, GC stress, native coverage

**All backends.** Every golden suite runs on the Tcl interpreter, the Tcl
compiler, generic Cranelift and specialized Cranelift
(`tests/golden/run.tcl`'s default), and `tests/golden-framework.test` compiles
each of its programs once and runs it on interp, compile and Cranelift,
requiring identical reports. Exclusions, recorded: `representation.bot`
aborts on generic Cranelift at one struct-shape case the generic baseline
does not support, and its specialized run stands in for the whole suite
there, as in the Tcl harness ([The sample](#the-sample)); native coroutines
exist on x86-64 Linux only, so the coroutine suites and framework tests that
run natively carry the `linuxX86_64` constraint; `golden_probe` and the
release counters are Tcl-runtime observations, and their native
counterparts are allocation sites and the native coroutine census
(`-native` tests). The framework itself depends on no backend's error or
coroutine implementation beyond the language's: the same report, byte for
byte, on every backend is what every framework test and every suite checks.

**Full regression.** The whole Tcl suite, unchanged, with the library and
the suites in place: `CORE_BACKEND=interp` 7168 tests, 7168 passed;
`CORE_BACKEND=compile` 7168 tests, 7164 passed, 4 skipped (the
`coreScoping` constraint), 0 failed; both include `tests/golden.test` (8
tests: every suite, against the manifest) and
`tests/golden-framework.test` (40). `cargo test --release --manifest-path native/Cargo.toml`: 219 library and 31 binary tests passed (nothing native was changed). The warning gate passes
(`lib/test.bot` has one entry, as `lib/io.bot`: its last declaration needs
a context, so it cannot be a value).

**GC stress** (`BOTLISH_NATIVE_GC_STRESS=1`, a collection before every
allocation -- checked to be in effect: the same suite collects 340 times
under it and 0 times without):

| what | result |
|---|---|
| all eight golden suites, specialized and generic Cranelift | 221 passed on both, 0 failed |
| `gf-gc-stress`: many registered checks capturing Strings and structs, CompilerError payloads, coroutines constructed and driven inside checks, several failing results retained until the report | 48 cases (24 failing); the report equals the Tcl interpreter's; 13 coroutines released, none swept |
| `gf-coroutine-cleanup-native` under stress | four coroutines created (the runner, a completed, a failed and an abandoned case's), four released, none swept by the collector |
| the fuzzer, seed 404, 20 programs, 115 cases, `-gc-stress 1` | 0 disagreements with the model |

No coroutine, captured value or retained result was collected early: a
premature collection would change a report (a String, a struct field, a
diagnostic message) or crash the run.

**Native coverage** (`tests/native-coverage.tcl`, the whole suite under
`CORE_BACKEND=cranelift`): 7168 tests -- native 2921, independent 4118,
passed-partial 69, unsupported 60 (all pre-existing: Tcl test natives such
as `test-log`, sequence mode, ...), **failed 0**. The two new test files,
classified alone under the same hook: 48 tests, 33 native, 15 independent
(they run their programs through explicit backend calls -- the Tcl probe
and release-counter tests, the NIR comparison, the fuzzer -- which the
coverage hook does not count as runs), 0 unsupported, 0 failed.

## Performance

`bench/golden-framework.tcl`, on a quiet machine (4 cores, nothing else
running), best of 3.

### Run time per case

A suite registering N cases of one kind in a loop (one body closure per
case, created in the loop, so neither the program text nor its compile cost
grows with N), measured as (T(N) - T(empty suite)) / N; N = 200 on the Tcl
backends, 2000 natively. "baseline" is the same body closures called
directly and compared with `==`, without the framework.

| kind | Tcl interpreter | Tcl compiler | Cranelift |
|---|---|---|---|
| registration only (none run) | 385 us | 88 us | 0.45 us |
| passing value case, run (`test::results`) | 1.2 ms | 217 us | 0.57 us |
| passing value case, with the report | 1.9 ms | 338 us | 1.67 us |
| value mismatch, with the report | 11.0 ms | 524 us | 3.46 us |
| expected rejection (`test::rejects`), with the report | 1.9 ms | 241 us | 1.71 us |
| unexpected rejection (code, location, message in the report) | 28.8 ms | 1.0 ms | 5.29 us |
| custom run-time-error case (`on IndexNotFound` in the body) | 2.0 ms | 276 us | 1.66 us |
| baseline: no framework | 283 us | 23 us | 0.03 us |
| empty suite, whole run | 6.8 ms | 4.4 ms | 1.61 us |

Natively a case costs one to five microseconds -- registration, the
deferred call, the Match, the TestResult, the runner's segment and the
report lines: a passing case 0.57 us run and 1.67 us with its report line,
against 0.03 us for the bare call -- negligible beside compiling the suite. A passing case and an expected
rejection cost the same (a rejected block is an ordinary `fail` the check's
handler catches). What costs is text: a mismatch formats the expected and
actual values, and an unexpected rejection also names the code (a lookup
over two 87-element lists), the location and the message. On the Tcl
interpreter that formatting dominates (11 ms and 29 ms a case), because
Botlish has neither integer division nor an Int-to-String conversion:
`test::int_text` builds the decimal digits by repeated subtraction and
one-character `substring`s. Failing cases are few in a healthy suite, so
this costs only when a suite is red.

### Allocations (natively, `native::allocationReport`)

| | allocations | bytes | what |
|---|---|---|---|
| one-time, registration only | 8 | 208 | Struct 2, MutableVector 2, List 4: the Suite and its installed copy, their vector headers, empty Lists |
| one-time, with a run and its report | 26 | 783 | + Coroutine 1 (the runner: 1 stack, released when it completes, none swept), the result and line vectors, Lists and a plan, 3 Strings (the summary line) |
| one-time, program constants | 99 | 4225 | static data (String and List constants of the library and suite) |
| per case, registration | 3 | 176 | the TestCase struct (`case`), the check closure (`test::value`), the body closure (the registration function) |
| per case, run, no report | 6 | 360 | + the Match, the TestResult and its one-element batch List (`run`) |
| per case, passing, with report | 16 | 759 | + the report line, `result_lines`' vector, Lists and plan, the report's Lists |
| per case, value mismatch | 20 | 957 | + the mismatch Match and the digit and line Strings |
| per case, unexpected rejection | 39 | 3241 | + the reified diagnostic's payload, `code_name`'s two literal Lists (re-made on every call), `text_lines`, `diagnostic_text` |
| per case, custom run-time-error | 16 | 767 | as passing |

There is no per-case coroutine: one runner coroutine per run, its stack
mapped once and released at the end (`gf-coroutine-cleanup-native`: the
runner and every case's own coroutines, four created, four released, none
swept). The deferred representation costs two closures per case.

General improvements the census points at -- none of them test-specific:

* **Constant List literals re-materialized per call.** `test::code_name`'s
  two 87-element literal Lists are built again at every call (4 List
  allocations and a plan per unexpected rejection). Hoisting a literal
  List of constants to static data would help every Botlish lookup table.
* **Collecting loops and vector-to-List read-outs** allocate an
  intermediate List (and a plan) each: a passing case's report line costs
  seven List allocations (`run`'s batch, `result_lines`' vector, its
  Lists and the read-out, `report`'s Lists).
* **Int-to-String and integer division** in the standard library: the
  framework's slowest path on the Tcl backends is decimal formatting
  written by repeated subtraction.
* **Closure per registration** (two Blocks per case) is inherent in
  deferral by function values, and small.

### Compile time

Suites of K distinct cases, each its own body and static block (the
framework), beside the same bodies as plain functions without it; best of
3, warnings off. Mixed suites: every third case a rejected block -- an
unbound name (UNBOUND, which resolution decides for every block at once) or
a typed call with a String (TYPE, which the checker decides one block per
round within a top-level unit) -- with the bodies nested in the
registration function or each at the top level. Builds are whole-program
builds (`hir::BuildOnce`): the static decision rounds and the method-sugar
decisions.

| K cases | plain functions, no framework | all passing | builds | UNBOUND, nested | builds | UNBOUND, top level | builds | TYPE, nested | builds | TYPE, top level | builds |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 10 | 41 ms | 0.95 s | 2 | 1.07 s | 3 | 1.15 s | 3 | 3.9 s | 8 | 2.0 s | 4 |
| 50 | 211 ms | 1.68 s | 2 | 2.01 s | 3 | 2.01 s | 3 | 32.5 s | 34 | 3.9 s | 4 |
| 100 | 482 ms | 2.95 s | 2 | 3.28 s | 3 | 3.30 s | 3 | 97.8 s | 68 | 5.5 s | 4 |

The library alone (a suite of no case) compiles in 0.77 s. A passing suite
grows by about 20 ms a case -- a nested function, a static block and a
registration call, about five times a plain function's cost -- and needs
two builds whatever its size (the decision round and the final build). A
rejected block costs nothing extra when resolution rejects it, and one
whole-program build per block when the checker does and the blocks share a
top-level unit: 100 cases with 33 checker rejections take 68 builds and
98 s nested, 4 builds and 5.5 s with every body at the top level. That is
the layout rule of `tests/golden/README.md` and the first item of the
[Recommendations](#recommendations): the cost is in the compiler's
decision procedure, not in the library, and a compiler that decided
independent rejected blocks of one unit together (or reused a build's
analysis across rounds) would make the rule unnecessary.

### Tcl harness versus the framework, on the migrated slice

`audit/golden/tools/check.tcl` on the same quiet machine:

| | wall time | tests | per test |
|---|---|---|---|
| the 133 Tcl tests (56 files, one `tclsh` each, `-match` on the ported names, startup included) | 23.5 s | 133 | 0.18 s |
| the 8 golden suites (compile once, run on 4 backends, one process each) | 161.0 s | 221 | 0.73 s |

Measured per suite in its own process (`tests/golden/run.tcl -quiet`), the
golden side's time splits into compiling the 8 suites, 91 s (0.41 s a
test), and running them: Tcl interpreter 13.3 s, Tcl compiler 48.3 s,
generic Cranelift 6.1 s, Cranelift 12.5 s (each backend's own code
generation for the whole suite included -- natively that, not the tests,
is most of it).

The comparison is not apples to apples, and the difference is instructive.
A Tcl test checks one small program (often Core IR text run on the reference
interpreter, or a surface program of a few lines), on the backends the test
chooses; it pays no compilation of a framework and no static decisions. A
golden suite is one large program -- up to 44 tests, the library (0.8 s of
compile time on its own: [Compile time](#compile-time)) and every test's
code -- compiled once, with every `static compile:` block decided by
whole-program builds (71 builds over the 8 suites, about 1.3 s each), then
run on four backends. Compilation is about 55% of the framework's wall
time, the Tcl compiler backend's code generation most of the rest, and
most of that is the static decisions' rebuilds: the golden workload is
a stress test of `static compile:`'s cost model, which is the compiler
optimization the [Recommendations](#recommendations) put first. Running the
tests themselves is cheap natively and moderate on the Tcl backends.

One more observation, about the harness rather than the framework: running
all eight suites in one process is slower than one process per suite (197 s
against 171 s; `values.bot`, run last, takes 4.4 s on the interpreter and
15.7 s on the Tcl compiler instead of 1.8 s and 9.7 s), so state the Tcl
backends keep across programs makes later programs slower -- a cost the Tcl
suite, which runs each test file in its own process, does not see.

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

## Recommendations

### The giant migration: yes, with three prerequisites

The evidence the brief asks for holds on the sample: an ordinary library
expresses the workflow (no test syntax, no test-only native, no catch-all);
133 Tcl tests became 221 golden tests that pass on all four executable paths;
side by side, every ported Tcl test and its golden tests pass on the same
tree; and under 21 existing compiler and runtime mutants, no mutant was
caught by the Tcl tests and missed by the golden ones
([Side-by-side](#side-by-side-agreement-and-the-mutation-spot-check)). The
per-case run-time overhead is small ([Performance](#performance)). So the
next milestone can be the large-scale migration -- after three things that
the sample shows would otherwise be multiplied by thousands:

1. **The compile cost of `static compile:` decisions** (the dominant cost:
   2-43 s a suite, against well under a second of run time per backend for
   most suites). Rejected blocks are decided one whole-program build per
   round unless the compiler proves them independent (different top-level
   units that do not reach each other), a build whose program has an
   erased-callable contract decides one block per round (`GlobalChannels`),
   and each round repeats the method-sugar decision builds. As first
   written, two suites took 81 and 178 builds. Deciding independent rejected blocks together and reusing
   method-call decisions across rounds is a compiler optimization every
   program with `static compile:` benefits from; until then a migration must
   follow the layout rule of `tests/golden/README.md` by hand.
2. **Block-relative diagnostic locations.** `rejects_at` pins absolute
   coordinates of the suite file; 36 `rejects_at` and 8 custom locations
   were re-derived by script after edits. `compiler::CompilerError` carrying
   its primary location relative to the block's own origin (or the block's
   origin beside it) would make a location test as stable as the Tcl test's
   tiny program. A data change, not syntax.
3. **The erased-callable precision gap (C3).** Trusting a checked structural
   contract (`Fn{args: [], return: Match}`, `errors: []`) at an unidentified
   call -- the contract was verified at every store -- removes runner
   poisoning, the one thing that breaks a deferred registry, and benefits
   every program that stores callables.

And, cheaply, in the library before broad adoption: `rejects_message` (with
an elision form for HIR ids in messages), `rejects_related` (the "moved
here" location of USE-AFTER-MOVE), a String `contains` in `str`, and an
`observe(body)` that returns a rejection as data for custom checks -- the
four suite-local helpers the porters wrote.

### Migration policy (item 79): viable, with a permanent Tcl remainder

* **New tests default to the Botlish-native framework** where they are
  expressible: 82% of the ported Tcl tests used only the simple helpers, and
  the static boundary turns a test's mistake into one failing test.
* **Not every Tcl test can move.** 41 of the 174 Tcl tests examined (24%,
  in a sample deliberately rich in hard cases) test what Botlish cannot
  observe or express: IR and NIR text, allocation and release counts,
  warnings, display text, a run-time-only failure, a parse or loader-header
  error, several programs or installations. Those stay in Tcl for good --
  the Tcl suite is the external observer, not only a bootstrap.
* **Migrated Tcl tests stay in CI** for a period, and `audit/golden/tools/check.tcl`
  monitors cross-suite agreement, side by side and under mutants, as this
  milestone did. A Tcl test is retired only when its manifest row is
  `equal` or `stronger` and a mutant spot-check of its area shows no
  `OLD-ONLY` verdict; a `weaker` row (48 of 133 here, mostly a message not
  compared or a native option matrix the runner cannot select) keeps its
  Tcl test.
* **The manifest is the unit of audit.** It was cheap to keep (one row per
  test, filled by the porter) and it is what let every class, strength and
  mutant claim here be counted rather than estimated.

### Test syntax: none is justified by the sample

Nothing a `test` keyword, `expect`/`assert` syntax or attributes would do is
missing: registration, deferral, ordering, matching, reporting and
composition are ordinary calls, and the explicit library is easier to audit
(its mutants, its fuzzer and its 40 tests are ordinary tests of ordinary
code). The demonstrated friction is elsewhere, and most of it is not
syntax at all:

| demonstrated friction | per test | what removes it |
|---|---|---|
| a named body, its `errors compiler::CompilerError` clause and a registration line | 2 lines (+ the name twice) | a **general anonymous function expression whose error contract is inferred from its body**, as the intrinsic-contract inference already does for untyped parameters: `test::value("adds", 42, fn(): static compile: 20 + 22)`. Not test syntax: every higher-order Botlish program writes the same named-nested-function ceremony today (the errors clause is required: a nested body without it is UNHANDLED-ERROR at its block) |
| the `static compile:` line | 1 line, one indentation level | nothing yet. It is the honest cost of the boundary; an implicit wrapping, or a *syntactic parameter* that lets `test::value` wrap its argument, would hide where the boundary is and is the one place where a language feature would be test-motivated. Revisit only if the anonymous-function form is adopted and the line still dominates |
| absolute locations | re-derivation after edits | block-relative locations (above) |
| run-time error normalization (`on E: ...` in 29 Tcl tests' bodies) | 2-3 lines a handler | nothing: naming the error is the test's content; a catch-all would be the "second error system" the brief excludes |
| run-time-only failures abort the suite | -- | a language decision (should ARITHMETIC, NOT-BOOLEAN, a native TYPE be declared errors?) for its own milestone, not for testing |
| top-level-only declarations, renamed per suite | 74 declarations | nothing: a suite is one program |

So the recommendation on syntax (items 63 and 64) is: no test syntax; the
one language feature the sample demonstrates the need for is an anonymous
function expression with inferred errors, a general feature whose test
payoff is two lines per test; a syntactic parameter (implicit
`static compile:`) is the only test-motivated candidate, worth one line per
test, and should wait until the anonymous function exists and the remaining
line is measured again.

## Report

The brief's milestone report, point by point. Each answer is short and
points to the section that has the evidence.

1. **Final public API.** [The library](#the-library): `suite`, `case`,
   `value`, `holds`, `rejects`, `rejects_at`, `rejects_any`; `Match`,
   `passed`, `mismatch`, `equal`, `satisfies`, `diagnostic`; `run`,
   `results`, `report`, `TestResult`, `Summary`, `summarize`,
   `result_lines`, `summary_line`, `registered`, `count`; `describe`,
   `int_text`, `code_name`, `diagnostic_text`. Names that felt awkward
   across the ports: `test::value` reads as a noun (`expect_value` or
   `equals` would say what it checks); `holds` needs a description String
   only because a predicate has no text; `rejects_at` takes absolute suite
   coordinates (the name is fine, the arguments are the friction);
   `Match.matched` repeats its type's name; `results`/`report` are two
   drivers a reader must tell apart; `case` is the low-level form but reads
   like the primary one. The porters asked for `rejects_message`,
   `rejects_related`, a substring test and `observe(body)`
   ([Recommendations](#recommendations)).
2. **Suite-context type.** `context struct Suite: cases: MutableVector[TestCase]`.
3. **The context is immutable and shallow.** Yes: an ordinary context
   struct, installed once at the entry program's top level; nothing
   rebinds it; its one field is a MutableVector header
   ([How it works](#the-suite-is-an-ordinary-context-its-state-is-an-ordinary-vector)).
4. **Mutable values it contains.** One `MutableVector[TestCase]`; mutated
   through the context parameter as a place (`suite.cases.push`).
5. **Registration.** `case(name, run, context suite)` pushes
   `TestCase {name, run}`; every helper builds a nested `check()` and calls
   `case`. Only `case` and `registered` declare the context; everything else
   derives it ([Registration authority](#registration-authority-comes-from-the-context)).
6. **Deferred-test representation.** `TestCase {name: str, run: Fn{args: [], return: Match}}`.
7. **Why it fits eager coroutines.** A function value runs nothing until
   called; a coroutine runs to its first yield when constructed, so a
   registry of coroutines would run tests at registration
   ([The deferred test](#the-deferred-test-a-function-value-because-coroutines-start-eagerly)).
8. **Proof registration does not execute.** `gf-registration-does-not-run`
   (Tcl probe), `-native` (no allocation at the body's line),
   `gf-registration-would-abort`, `gf-coroutine-body-deferred`; the mutant
   `registration-executes` is killed by 11 tests.
9. **Runner representation.** `test::run()`, a coroutine over a snapshot of
   the cases, one case per segment.
10. **Is the runner a coroutine?** Yes; `results()` and `report()` are plain
    functions that drain it ([The runner is a coroutine](#the-runner-is-a-coroutine)).
11. **Test-coroutine protocol.** Each segment sends `[TestResult]`, the last
    `[]`; the empty suite completes at construction. No per-test coroutine
    ([Test coroutines](#test-coroutines)).
12. **Cleanup and affinity.** Bodies own their coroutines; each is released
    exactly once whether it completes, fails or is abandoned
    (`gf-coroutine-cleanup`, `-native`, also under GC stress); an abandoned
    runner releases (`gf-runner-abandoned`); a body cannot capture an affine
    value (AFFINE-CAPTURE-UNSUPPORTED, `gf-affine-capture-rejected`).
13. **Repeat-run semantics.** Every run runs every case once more; nothing is
    consumed (`gf-repeated-runs`, `-native`).
14. **Suite isolation.** One suite per program (DUPLICATE-CONTEXT); separate
    programs share nothing (`gf-isolation`, `gf-one-suite-per-program`).
15. **Registration ordering.** Run and report in registration order
    (`gf-registration-order`; mutant `registration-reorders` killed).
16. **Result model.** `TestResult {name, passed, expected, actual, detail}`,
    `Summary {total, passed, failed}` ([Results and matchers](#results-and-matchers)).
17. **Matcher model.** A matcher is a function returning
    `Match {matched, expected, actual, detail}`: data, never an error.
18. **Value matcher.** `test::value` / `test::equal`: `==` while the
    concrete type is known, `describe` for the texts.
19. **CompilerError matcher.** `rejects_any`; `value` and `holds` report an
    unexpected rejection's code, location and message.
20. **Exact DiagnosticCode matcher.** `rejects` (code), `rejects_at` (code,
    line, column), `test::diagnostic`.
21. **Custom escape hatch.** `test::case(name, check)` with any
    `Fn{args: [], return: Match}`; 24 Tcl tests' ports used it.
22. **Generic-completion census.** [Generic completion capture](#generic-completion-capture-what-ordinary-botlish-can-observe).
23. **Arbitrary nominal run-time error capture.** Not expressible: handlers
    are nominal, there is no catch-all; the compiler instead checks each
    body against the helper's inferred contract at the registration.
24. **Coroutine failure observation.** None without re-raising:
    `coroutine::done?` is true for completed and failed alike, a failed
    coroutine re-raises its cached error at every resume.
25. **Run-time-only failures.** Abort the whole program; `run.tcl` reports
    the suite ABORTED (`gf-runtime-only-failure-aborts`).
26. **Expected run-time errors.** An ordinary handler inside the body
    converting the outcome to a value (`on IndexNotFound: "IndexNotFound"`),
    inputs routed through registration parameters so KNOWN-ERROR cannot
    decide them (29 Tcl tests).
27. **Unexpected CompilerErrors.** A FAIL line with the expected outcome,
    `actual: compiler diagnostic CODE at line L, column C` and the message as
    `detail` (multi-line messages indented).
28. **Static-compile convention.** [The static-compile convention](#the-static-compile-convention):
    every body is a nested `fn NAME() errors compiler::CompilerError:` whose
    whole body is one `static compile:` block. The suites hold 221 static blocks: 107 accepted, 114 rejected, across 40 diagnostic kinds; 61 of the 133 ported Tcl tests need the boundary to express the test, 72 use it by convention.
29. **Why the wrapping stays explicit.** `static compile:` consumes syntax; a
    library receives values, already compiled with the program.
30. **Output format.** `PASS name` / `FAIL name` with `expected:`,
    `actual:`, `detail:` lines, then `P passed, F failed`; a short run is
    `FAIL the run` ([The library](#the-library)).
31. **Framework mutation results.** 20 framework mutants (`audit/golden/tools/mutants.txt`), all killed: each by at least one framework test, 13 also by the fuzzer ([Framework mutants](#framework-mutants)).
32. **Framework fuzz results.** 4 campaigns, 80 generated suites, 466 cases, on all four backends and once under GC stress: 0 disagreements with the independent model ([Framework fuzzing](#framework-fuzzing)).
33. **Migrated-test count.** 133 Tcl tests ported as 221 golden tests; 41
    more examined and not ported (174 examined).
34. **By category.** values 25/32, collections 23/44, diagnostics 22/27,
    errors 17/23, ownership 13/37, modules 11/31, representation 11/14,
    harness 11/13 (Tcl tests / golden tests; [The sample](#the-sample)).
35. **Manifest.** `tests/golden/manifest.tsv` ([The manifest](#the-manifest)).
36. **DIRECT:** 48 primary (51 named).
37. **STATIC-COMPILE-ADAPTATION:** 24 primary (42 named).
38. **EXPLICIT-ERROR-HANDLER:** 3 primary (5 named); 29 bodies handle a
    run-time error.
39. **CUSTOM-MATCHER:** 21 primary (24 named).
40. **HARNESS-DIFFERENCE:** 36 primary (67 named).
41. **NOT-EXPRESSIBLE:** 40 ([reasons](#classes)).
42. **OLD-TEST-OVERSPECIFIED:** 14 ([Old tests](#old-tests)).
43. **NEW-FRAMEWORK-LIMITATION:** 3 rows, all runner poisoning (one Tcl
    test not ported, two ported weaker); the suite context satisfying an
    application's context trait was found and fixed during porting; the ten
    [framework limitations](#framework-limitations-the-library-as-the-language-allows-it)
    list the rest.
44. **Compiler bugs found.** No ported test fails; six defects or precision
    gaps (C1-C6) and five smaller inconsistencies, with reproducers
    ([Compiler defects](#compiler-defects-and-precision-gaps)).
45. **Side-by-side agreement.** 221 of 221 ported rows: the Tcl test passes and the golden test passes, on one checkout (56 Tcl test files, every named Tcl test confirmed to have run; 8 suites on all four backends).
46. **Mutation spot-check.** 21 existing mutants from nine harnesses: 18 caught by both, per test; 3 caught by the golden suites only at suite level (an uncatchable run-time failure aborts a suite, or a misuse surfacing after the static decision fails its compilation); none caught by the Tcl tests only ([Mutation spot-check](#mutation-spot-check)).
47. **All backends.** Every golden test passes on the Tcl interpreter, the
    Tcl compiler, generic and specialized Cranelift (`representation.bot`'s
    generic run is the specialized one, as in the Tcl harness); the
    framework's tests require identical reports from interp, compile and
    Cranelift; the full Tcl suite passes on interp and compile.
48. **GC stress.** All 8 suites (221 tests) on both native backends, `gf-gc-stress`, `gf-coroutine-cleanup-native` and a fuzz campaign under `BOTLISH_NATIVE_GC_STRESS=1`: no failure, no premature collection ([Backends, GC stress, native coverage](#backends-gc-stress-native-coverage)).
49. **Native coverage.** The whole suite on Cranelift: 7168 tests, 0 failed (2921 native, 4118 independent, 69 partial, 60 unsupported, all pre-existing); the two new test files: 48 tests, 0 failed, 0 unsupported.
50. **Registration allocation cost.** Natively, one-time 8 allocations (208 bytes: the Suite, its installed copy, vector headers, empty Lists); per registered case 3 (176 bytes: the TestCase, the check closure, the body closure) ([Allocations](#allocations-natively-nativeallocationreport)).
51. **Per-test allocation cost.** Per case, run: 6 allocations (360 bytes); with its report line 16 (759 bytes); a value mismatch 20 (957 bytes); an unexpected rejection 39 (3241 bytes, mostly formatting: `code_name`'s literal Lists are re-made per call).
52. **Coroutine allocation and release.** One coroutine per run (the runner): one stack mapped, released when the run completes, none swept; no per-case coroutine. Bodies' own coroutines are released exactly once whether they complete, fail or are abandoned (`gf-coroutine-cleanup`, `-native`, under GC stress too).
53. **Passing-test performance.** Per passing case: Cranelift 0.57 us run, 1.67 us with its report line; Tcl compiler 217 / 338 us; Tcl interpreter 1.2 / 1.9 ms (a bare call: 0.03 us, 23 us, 283 us).
54. **Mismatch performance.** Per value mismatch with its report: Cranelift 3.46 us, Tcl compiler 524 us, Tcl interpreter 11.0 ms -- decimal formatting without division or Int-to-String in the standard library.
55. **Compiler-error-test performance.** An expected rejection costs what a passing case does (Cranelift 1.71 us, Tcl compiler 241 us, interpreter 1.9 ms); an unexpected one, reported with code, location and message, 5.29 us, 1.0 ms and 28.8 ms. Its compile time is the real cost (items 56-58).
56. **Compile time, ~10 tests.** 10 cases: 0.95 s all passing (plain functions: 41 ms; the library alone 0.77 s); 1.1 s with UNBOUND rejections; 2.0 s with TYPE rejections and top-level bodies, 3.9 s nested.
57. **Compile time, ~50 tests.** 50 cases: 1.7 s all passing; 2.0 s with UNBOUND rejections; TYPE rejections 3.9 s with top-level bodies, 32.5 s nested (34 builds).
58. **Compile time, ~100 tests.** 100 cases: 3.0 s all passing (2 builds); 3.3 s with UNBOUND rejections; TYPE rejections 5.5 s with top-level bodies (4 builds), 97.8 s nested (68 builds). The real suites (14-44 tests): 2-36 s each, 91 s in all ([Compile time](#compile-time)).
59. **Tcl harness versus framework wall time.** The 133 Tcl tests: 23.5 s (0.18 s a test). The 221 golden tests: 161 s on four backends (0.73 s a test) -- 91 s compiling (mostly static-decision rebuilds), then 13 s interpreter, 48 s Tcl compiler, 6 s generic Cranelift, 12.5 s Cranelift, backend code generation included ([Tcl harness versus the framework](#tcl-harness-versus-the-framework-on-the-migrated-slice)).
60. **Recurring boilerplate.** [Recurring boilerplate](#recurring-boilerplate):
    three lines per test (the body's `fn` line with its error clause, the
    `static compile:` line, the registration), declarations hoisted and
    renamed, handlers for run-time errors, absolute locations, suite-local
    matchers.
61. **Deliberately not implemented.** [Not implemented](#not-implemented).
62. **Giant migration.** For, after three prerequisites: static-decision
    compile cost, block-relative locations, the erased-callable precision
    gap; with the Tcl suite retained as an independent oracle and a
    permanent home for what Botlish cannot observe
    ([Recommendations](#recommendations)).
63. **Future test syntax.** Not justified: nothing in the sample needed a
    test keyword, assertion syntax or attributes.
64. **Syntax that would remove demonstrated friction.** A general anonymous
    function expression with an inferred error contract (two of the three
    per-test lines); a syntactic parameter (implicit `static compile:`) is
    the only test-motivated candidate, worth one line per test, and should
    wait for the first.

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
| `audit/golden/out/` | the logs behind every number in this report: regression, mutants, fuzz, side by side, spot-check, GC stress, native coverage, static decisions, benchmarks, suite timings |
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
