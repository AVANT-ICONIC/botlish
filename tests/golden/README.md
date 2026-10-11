# Golden suites: Botlish-native tests

`tests/golden/*.bot` are test suites written in Botlish itself, with the
ordinary library `lib/test.bot` (namespace `test`). They are the validation
sample of GOLDEN-TEST-FRAMEWORK.md: about a hundred tests of the Tcl suite,
ported deliberately, each one recorded in `manifest.tsv` beside the Tcl test
it comes from. The Tcl tests stay authoritative: nothing here replaces,
skips or weakens one, and both run on the same compiler revision
(`tests/golden.test` runs these suites inside the ordinary Tcl suite;
`audit/golden/tools/check.tcl` compares the two side by side).

## Running

```sh
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 tests/golden/run.tcl                       # every suite, on the four default backends
tclsh9.0 tests/golden/run.tcl tests/golden/errors.bot
tclsh9.0 tests/golden/run.tcl -quiet                # one summary line per suite and backend
tclsh9.0 tests/golden/run.tcl -names                # "SUITE PASS|FAIL NAME" per test
tclsh9.0 tests/golden/run.tcl -backends interp,compile-hir tests/golden/values.bot
```

The default backends are the four the Tcl suite's differential tests use:
interp and compile (the core IR on the reference interpreter and on the Tcl
compiler), cranelift-generic and cranelift. `compile-hir` (the Tcl compiler
compiling the HIR itself, `main.tcl -backend compile`) is opt-in and takes
one suite per process: that path keeps a program's installed contexts after
it ends (GOLDEN-TEST-FRAMEWORK.md, C7), so a second suite in the process
fails with DUPLICATE-CONTEXT. Natively the suites run on x86-64 Linux only
(the runner is a coroutine).

The exit status is 1 when any test fails, a suite does not compile, a run
aborts (a failure no Botlish handler can catch: not a test result) or the
backends disagree. Botlish has no exit-status facility, so `run.tcl` reads
the report.

## A suite

A suite is an ordinary entry program:

```botlish
# values.bot -- ordinary successful value tests (manifest: category values).
import compiler
import test

# Declarations the tests need: struct, enum, error, refined type, trait and
# context struct declarations are top-level only (a `static compile:` block
# cannot hold one), so they live here, named after their test.

fn register_calls_tests():
    fn calls_basic() errors compiler::CompilerError:
        static compile:
            fn add(a, b):
                a + b
            add(20, 22)
    test::value("calls-basic", 42, calls_basic)

fn register_values_tests():
    register_calls_tests()

with context test::suite()
register_values_tests()
test::report()
```

* One registration function per Tcl test file a suite ports from
  (`register_calls_tests` for `tests/calls.test`), and one per suite that
  calls them in order. Registration functions are the only composition
  mechanism: nothing is discovered, nothing registers itself on import.
* A test's name is the Tcl test's name (`calls-basic`), with a suffix when
  one Tcl test becomes several golden tests (`calls-basic/negative`).
* A body is a nested function of no arguments declaring
  `errors compiler::CompilerError` whose whole body is a `static compile:`
  block around the code under test. If the compiler accepts the block, the
  body is the plain code (the boundary leaves nothing at run time); if it
  rejects it, the body completes with `compiler::CompilerError`, which the
  helper turns into a reported mismatch (or the expected outcome, for
  `test::rejects`). A mistake in one test's code is then that test's
  failure, not a suite that does not build.
* The suite ends with `test::report()`: the program's value is the report.
* **Layout is free.** Write a body where it reads best: nested in its
  registration function (it may capture the function's inputs), or at the
  top level. The compiler decides independent blocks together whatever their
  nesting (STATIC-COMPILE.md, "Decision economics"): a suite's builds grow
  with how deeply its blocks really depend on each other -- a block nested
  in another block, blocks in one function's statement sequence, a block
  consuming what another erases -- never with how many blocks it has or how
  they are arranged. (Before that milestone this guide asked for bodies at
  the top level and for an erasing body first: no longer needed.)

## Helpers

| helper | the test passes when |
|---|---|
| `test::value(name, expected, body)` | the body's value `== expected` |
| `test::holds(name, description, predicate, body)` | `predicate(value)` is true |
| `test::rejects(name, code, body)` | the block is rejected with that `compiler::DiagnosticCode` |
| `test::rejects_at(name, code, line, column, body)` | ... reported at that line and column of the suite file |
| `test::rejects_any(name, body)` | the block is rejected |
| `test::case(name, check)` | `check()`, a `Fn{args: [], return: test::Match}`, returns a match (`test::passed()`, or `test::mismatch(expected, actual, detail)`; `test::equal`, `test::satisfies` and `test::diagnostic` compute one) |

Compare a diagnostic's `code` (and `primary` location, when the Tcl test pins
it), never its message, unless the Tcl test is about the wording: then write
a `test::case` that compares `message` too.

## Writing the code under test

* **Top-level statements** of the Tcl test's program go inside the block,
  its last expression being the value. Functions it declares become nested
  functions in the block (Botlish has no forward references: callees first).
* **Declarations** (struct, enum, error, type, trait, context struct) go to
  the suite's top level, renamed when two tests would collide; that renaming
  is part of the port (note it).
* **Imports** are the suite file's header: a namespace the Tcl program
  imports is imported by the suite. A test *about* a missing import is
  expressible (`MissingImport`) only when the suite does not import that
  namespace.
* **Run-time errors.** A body may complete only normally or with
  `compiler::CompilerError`: every other error it may raise must be handled
  inside the block, converting the outcome to a value the test compares
  (`on IndexNotFound: "IndexNotFound"`, `on Failed {code}: code`). An error
  that escapes the block anyway is the block's own rejection
  (`UnhandledError`): one failing test. A handled call the compiler can
  *prove* fails is `KnownError` (a handler does not make a statically known
  failure legal): give such a test an input the compiler cannot decide --
  a parameter of the registration function, captured by the body
  (`fn register_errors_tests(n: int)`, called as `register_errors_tests(9)`).
* **Run-time-only failures** (NOT-BOOLEAN, ARITY of a plain call, a native's
  TYPE such as `1 + "x"`, ARITHMETIC, stack overflow) are not declared
  errors: no handler catches them, and one aborts the whole suite. They stay
  in the Tcl suite.
* **Contexts.** A body is a function value, so it cannot need a context
  (CONTEXT-FUNCTION-VALUE): context-dependent code runs in the registration
  function (which may declare `context x: T` or call code that needs one),
  and the body compares what it computed. `with context` is top-level only:
  a test of installation itself is a whole program, not a body.
* **Affine values.** A body cannot capture one (AFFINE-CAPTURE-UNSUPPORTED);
  it constructs its own coroutines and affine values.
* **Higher-order code** that passes a callable *declaring an error* through
  an *untyped* parameter makes the program's erased-callable contract carry
  that error; the completion analysis charges it only to calls whose callee
  has neither an identity nor a contract -- never to the runner's call of a
  stored check, which goes through its `Fn` contract
  (VERIFIED-CALLABLE-CONTRACT-BOUNDARY.md). Such code is portable as the
  Tcl test writes it, prelude at the suite's top level included; the blocks
  that consume the contract are decided after the blocks that change it,
  and every other block is decided independently of it.
* **What Botlish cannot observe** -- HIR, Core IR or NIR text, allocation or
  release counts, warnings, stdout -- stays in the Tcl suite. A semantic
  core of such a test (its program's value) may be ported, classified
  HARNESS-DIFFERENCE and noted as weaker.
* A suite's value is shown by the Tcl harness: never return a function
  value from a body to the report (the helpers never do).

## manifest.tsv

One row per Tcl test considered, tab-separated, with a header row:

| column | meaning |
|---|---|
| `old_file`, `old_test` | the Tcl test |
| `suite`, `new_test` | the golden suite file and test name (`-` when not ported) |
| `category` | values, collections, diagnostics, errors, ownership, modules, representation, harness |
| `outcome` | value, diagnostic, diagnostic-at, runtime-error, predicate, custom, not-ported |
| `old_backends`, `new_backends` | where each runs |
| `class` | primary class (below) |
| `also` | further classes, comma-separated, or `-` |
| `static` | yes if the body needs its `static compile:` boundary to express the test (a rejection, or an escaping error), else `convention` |
| `handler` | yes if the body handles a run-time error explicitly |
| `api` | simple (a value/holds/rejects helper) or custom (`test::case`) |
| `verbosity` | clearer, similar or more-verbose than the Tcl test |
| `strength` | equal, weaker (say why in notes) or stronger |
| `mutants` | existing mutants (`audit/X/tools/mutants.txt NAME`) the Tcl test kills, or `-` |
| `notes` | anything an auditor needs |

Classes: DIRECT (the Tcl program, as a body, with a simple helper),
STATIC-COMPILE-ADAPTATION (a separate rejected program became a rejected
block in the suite), EXPLICIT-ERROR-HANDLER (a run-time error expectation
written as a handler in the body), CUSTOM-MATCHER (`test::case`),
HARNESS-DIFFERENCE (the property is observed differently: a location in the
suite file, a value computed at registration, ...), NOT-EXPRESSIBLE,
OLD-TEST-OVERSPECIFIED (the Tcl test pins an incidental detail the port
deliberately drops), NEW-FRAMEWORK-LIMITATION, COMPILER-BUG-FOUND.
