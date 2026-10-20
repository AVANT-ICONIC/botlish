# Compilerpedia: milestone report

The milestone gave the compiler a built-in, offline reference and help system
(`botlish -help`, in a checkout `tclsh9.0 main.tcl -help`), replaced the
argumentless demo run with a usage summary, connected every printed
diagnostic and warning to its documentation, and audited three warnings
against the 15-puzzle study's legitimate exceptions, refining two of them and
SAME-FAILURE. COMPILERPEDIA.md is the architecture and maintenance guide; this
report records what was done and what was measured.

## A. Executive summary

**What was built**

* **The engine**, `compilerpedia/compilerpedia.tcl` (about 1,100 lines of
  Tcl, no dependencies). It parses plain-text topic files, builds the lookup
  tables, searches, renders man-page-style pages and validates the catalogue.
* **660 topics** with stable IDs, viewed through nine indices: concepts,
  rules, proofs, errors, warnings, lint, principles, stdlib and backends.
  * 353 are written by hand.
  * 307 standard-library topics are generated from the native registry and
    the library sources, merged with 225 hand-written notes.
* **Validation and generation tool**, `tools/compilerpedia.tcl`:
  `generate`, `check`, `examples` and `inventory`. `check` fails on any
  problem:
  * a broken reference, an alias conflict, or a stale generated file;
  * a public native without a note;
  * a diagnostic the compiler's source can report but no topic documents;
  * a warning topic missing a required section or example;
  * a matcher no example exercises;
  * any of the 511 examples behaving other than its page says, or
    drawing a warning it does not state.

**What the user sees**

* `botlish` with no arguments prints a usage summary and exits 0. It no
  longer runs the bundled demo programs.
* `-help [QUERY...]` opens Compilerpedia. `-version` prints the build
  identity. Malformed invocations explain themselves on stderr and exit 2.
* Every diagnostic `main.tcl` prints is followed by one line naming its
  topic:

  ```
     error: t.bot:4:5: this call of "std::list::at" may produce the declared error "IndexNotFound", ... (CORE SEMANTIC UNHANDLED-ERROR)
     help: botlish -help proof.list-bounds
  ```

  The topic is the specific rule where one is known (here the bounds proof,
  not the broad UNHANDLED-ERROR page). Warnings get one such line per
  distinct code.

**Lint changes, each with tests and audit evidence (section E)**

* **SAME-RETURN-VALUE**
  * The handlers of one call count as one exit.
  * A Bool constant is reported only when it is the function's only answer.
* **SAME-FAILURE:** the handlers of one call count as one site.
* **METHOD-ELIGIBLE:** a call whose receiver would be an Int literal is not
  reported.
* **FIXED-ARITY-LIST-RETURN:** unchanged, and its intended response
  (`-> list`) is documented.

**Major decisions**

* **The unit is a topic, not a diagnostic.** Indices are views over topics,
  so nothing is written twice.
* **Help identity is separate from diagnostic identity.** A broad code such
  as `SURFACE SYNTAX` or `CORE SEMANTIC TYPE` points at specific rule topics
  through *matchers*, which read the printed message. The compiler's codes,
  messages, recovery and static decisions are untouched.
* **Derived where the compiler knows.** Signatures, errors and backends come
  from the registry. The diagnostic inventory is scanned from the source,
  and the warning list is the pass registry.
* **Help is presentation.** It never compiles, imports or starts a backend,
  and a compilation that prints no diagnostic or warning never loads it.

## B. CLI changes

**No arguments.**

* Before, `tclsh9.0 main.tcl` with no arguments ran every `examples/*.ir`
  program on the interpreter and exited 0:

  ```
  == 01-adder.ir (interp)
     value: 42
  == 02-loop-break.ir (interp)
     ...
  ```

* Now it prints the usage summary on stdout and exits 0. Nothing is
  compiled or run.

  ```
  usage: botlish [OPTION...] FILE...
         botlish -help [QUERY...]
         botlish -version

  Compiles and runs Botlish programs: FILE.bot (source), FILE.hir (HIR text),
  FILE.hirx (HIR interchange) or FILE.ir (core IR text; interp and compile only).
  Each program's output is printed, then its value.

  Running:
    -backend NAME       interp (default), compile, cranelift, cranelift-generic
    ...
  Reference:
    -help [QUERY...]    Compilerpedia, the built-in reference (offline)
    -version            the compiler's version and build identity
  Examples:
    botlish -backend cranelift game.bot
    botlish -help KNOWN-ERROR         a diagnostic or warning code
    ...
  ```

  The usage names every option of main.tcl's option table (one table now
  drives parsing and the usage, and a test checks that each of its options
  is documented in the `cli.options` topic and main.tcl's header). Lines fit
  80 columns. The program name is the invocation's own:
  `botlish` for the single executable, `tclsh9.0 main.tcl` in a checkout.

* Running the examples is explicit now: `tclsh9.0 main.tcl examples/*.ir`.
  docs/README.md's command list says so.

**`-help`.**

* Before, `-help` and `-version` printed `unknown option "-help"` and exited
  2.
* Now:

  | invocation | output | exit |
  |---|---|---:|
  | `botlish -help` | the overview: the indices with sizes and example queries | 0 |
  | `botlish -help warnings` (an index or its singular) | the index introduction and one line per topic | 0 |
  | `botlish -help all` | every topic ID, by index | 0 |
  | `botlish -help METHOD-ELIGIBLE` (an ID, code, symbol, alias, or a unique search result) | the page | 0 |
  | `botlish -help range` (several matches) | a ranked list with summaries | 0 |
  | `botlish -help metod-eligibel` (nothing) | near matches on stderr, nothing on stdout | 1 |

* Everything after `-help` is the query: `-help bounds proof` and
  `-help "bounds proof"` are one query.
* `-help` never compiles a file named before it.
* A reader that stops early (`botlish -help errors | head`) ends the output
  quietly, without a write error (so do the usage and `-version`).

**`-version`.** It prints the identity the build actually has, and exits 0.
There is no invented version number:

```
Botlish compiler (no release version; this is a development build)
source revision: 7188527 (modified)
front end: 2987e83ebe5477fe-3311716
Tcl: 9.0.1
native backend: /home/user/botlish/native/target/release/botlish-native
invocation: tclsh9.0 main.tcl
```

* **The front end line** is the HIR interchange fingerprint.
* **The source revision** comes from git in a checkout and from the packed
  `BUILD` file in the single executable.
* **The native backend line** reads "packaged" in the single executable, and
  "not built" when the backend is missing.

**Malformed invocations** print one line naming the problem, then a hint, on
stderr, and exit 2. These are tested one by one:

* an unknown option, an option missing its argument, an unknown backend,
  warnings mode or target;
* a bad `-argv-hex`;
* no input file after options.

```
botlish: unknown option "-nope"
run botlish with no arguments for the usage summary, or botlish -help cli.options
```

**Unchanged.**

* An explicitly named program runs exactly as before: `.bot`, `.hir`,
  `.hirx` and `.ir` files, every option, and the output format.
* The added `help:` lines appear on the channel of the diagnostic they
  follow: stdout for errors, stderr for warnings.
* Exit statuses for programs are as before (0, or 1 when any input failed).

## C. Compilerpedia architecture

**Storage.**

* **Topic files.** `compilerpedia/topics/*.topic` are hand-written and
  `compilerpedia/generated/stdlib.topic` is generated; all are plain text.
* **A topic** is `@topic ID`, then header lines:
  * `title`, `summary`;
  * `index`, `related`, `docs`, `symbol`;
  * `alias`, `keywords`;
  * `code` (one per diagnostic or warning code);
  * `match` (`CODE | GLOB`).
* **The body** follows: `== HEADING` sections, then examples. An example
  runs from `@example accept|reject` to `@end`, with these directives:
  * results: `@value`, `@output`;
  * warnings: `@warn`, `@nowarn`, `@quiet`;
  * rejections: `@error`, `@at`, `@message`;
  * also `@backends` and `@caption`.
* **IDs** are `category.name`: `error.known-error`, `rule.if-placement`,
  `proof.list-bounds`, `stdlib.std::list::at`, `warning.method-eligible`.
* **No database, no index file:** the catalogue is read on first use, about
  1.0 MB of text (700 KB hand-written, 340 KB generated).

**Lookup** (`compilerpedia::lookup`).

* **Three tables.** IDs, codes, symbols and aliases are keys in three
  tables: as written, case-folded, and loose (`-`, `_`, `.` and spaces
  alike).
* **Ranking.** An ID ranks first, then a code or symbol, then an alias. A
  key that names an index's introduction (`index.errors`, the alias
  "best practices") shows the whole index.
* **Code tails.** A code's last word is a key too. A hyphenated one such as
  `KNOWN-ERROR` is a key in any case; a plain word such as `TYPE`, `STRUCT`
  or `RANGE` only in capitals, so `-help struct` stays the concept and
  `-help STRUCT` the error.
* **Word search** runs when no key matches:
  * Each word must occur, after stop words are removed and words are folded
    to their singular. At least half of them must occur in the topic's
    title, aliases, keywords or summary, so a page that merely mentions the
    words is not an answer.
  * Each word scores by the best field it occurs in: ID, codes, symbols and
    title 30; aliases 25; keywords 20; summary 10; body 2.
  * Ties are broken by ID. Results are deterministic.
* **Nothing found:** the near matches are IDs within a small edit distance,
  then the pages whose text holds every word, then partial matches.

**Diagnostic integration.**

* `compilerpedia::topicForDiagnostic CODE MESSAGE` is the first matcher whose
  code equals the printed code and whose glob matches the message. Failing
  that, it is the topic documenting the code, and then the one documenting
  its longest documented prefix (`NATIVE UNSUPPORTED value` falls back to
  `NATIVE UNSUPPORTED`).
* `main.tcl` prints the line, once per topic per file. That is all of the
  integration. The compiler's diagnostics, their order, the
  `-diagnostics` list, `CompilerError` texts and the static scheduler's
  inputs are not touched: the lookup reads the printed text after the
  compiler has finished. `tests/main-cli.test`'s
  `cli-help-lines-do-not-change-diagnostics` checks that the printed error
  lines are exactly the compiler's `-diagnostics`.

**Rendering.**

* A page is plain text that fits 80 columns, with no ANSI and no paging.
  The engine wraps what it composes at 78 columns; hand-written prose is
  held to 76 by the check and shown four columns in; code lines are shown as
  written (`cp-render-fits-80-columns`).
* It has the ID and title, the indices, and these parts:
  * SUMMARY, then CODE or SYMBOL;
  * the topic's sections and examples (each with its expected outcome);
  * SPECIFIC RULES: for a broad code, the topics whose matchers point at it;
  * RELATED: the topic's own links, then the topics that link to it;
  * DESIGN DOCUMENTS: repository paths, marked optional, because every page
    is complete without them.

**Avoiding duplicated knowledge.**

* **Generated from the compiler:**
  * standard-library signatures, declared errors, `nomethod` and
    native-only status, from `core::native`'s registry;
  * library declarations and their comments, from `stdlib/*.bot` through the
    parser.
* **Not copied into the catalogue, only checked against it:**
  * the diagnostic inventory, scanned from the compiler's own reporting
    patterns;
  * the warning list (`hir::warnings::passes`).
* **Example outcomes** are produced by the compiler at check time, never
  written as expected text beyond the value, the code and the location.
* **Prose is hand-written** and validated by examples. The prose explains;
  lists the compiler owns are never restated.

**Isolation from compilation.**

* `main.tcl` sources the engine only for `-help`, or when it is about to
  print a diagnostic or warning. A clean compilation never loads it.
* The engine reads only its own directory.
* `tests/compilerpedia.test` checks two things:
  * `cp-help-loads-no-compiler`: a lookup leaves no compiler namespace
    loaded;
  * `cp-help-changes-no-compilation`: the HIR and warnings of a program
    compiled after help is loaded are unchanged.

## D. Coverage

Counts from the catalogue as committed (`tools/compilerpedia.tcl check` and a
count over `compilerpedia::topics`):

| measure | count |
|---|---:|
| topics | 660 (353 hand-written, 307 generated) |
| topics by index (a topic may be in several; 67 are), not counting each index's introduction | concepts 73, rules 35, proofs 14, errors 201, warnings 9, lint 11, principles 15, stdlib 321, backends 42 |
| topics by category | stdlib 307, error 185, concept 48, rule 32, capability 19, principle 14, backend 13, proof 13, index 9, task 7, warning 7, cli 4, lint 2 |
| diagnostic and warning codes documented (`code:` lines) | 209 distinct, on 192 topics |
| inventory entries (scanned from the source) | 223: 127 HIR/loader kinds, 67 exact codes, 22 code families (prefixes), 7 warnings -- all documented, 0 missing |
| warning codes | 7 of 7 (each with the five required sections, a warning example, a silent example and its `-warnings error` code) |
| matchers (specific rule behind a broad code) | 64, each exercised by a rejected example |
| standard-library topics | 307: 30 namespaces, 82 intrinsics (23 root primitives, 59 namespaced), 195 library declarations; 225 notes |
| aliases | 1,009 |
| keywords | 1,189 |
| cross-references (`related:`) | 2,670, all resolving |
| design-document references (`docs:`) | 592 |
| examples | 511 (267 accepted, 244 rejected), all run by `check` on interp and compile, native-only ones on cranelift and cranelift-generic; each draws exactly the warnings it states |

**Incomplete areas**

* **Kinds with no example.** These kinds' pages say why there is none:
  * They need a second file, so the page shows a code listing: CYCLE,
    MODULE-COLLISION, INVALID-TOPLEVEL, MODULE-IMMUTABLE.
  * They depend on the host: UNKNOWN-TARGET.
  * We could not produce them with the shipped library or with deep
    instance chains: DUPLICATE-NATIVE, AMBIGUOUS-MODULE,
    UNSUPPORTED-ARCHITECTURE, AFFINE-INSTANCE-BUDGET (which
    AFFINE-ERASURE-UNSUPPORTED pre-empts) and TRAIT-INSTANCE-BUDGET.
  * They are internal compiler errors: TRAIT-INTERNAL and
    CONTEXT-TRAIT-INTERNAL.
* **Run-time errors.** Their pages show the program and main.tcl's real
  output as text, not as checked `@example`s, because the example runner
  checks compile-time outcomes, values and printed output.
* **Generated library pages.** These quote the declaration's source comment,
  which is sometimes written for maintainers (design-document history).
  The note's summary is what lists and searches show, but the DESCRIPTION
  section is the comment as written.
* **Help lines.** Some codes print no help line: a code whose kind is
  computed (`NATIVE UNSUPPORTED value`) only gets one through the prefix
  fallback, and an exact printed code that is undocumented gets none. The
  inventory finds no undocumented code, but a code assembled at run time
  from variables can escape the scan.

## E. Lint audit

The 15-puzzle study met three warnings (S7, S19):

* METHOD-ELIGIBLE on helper functions whose first parameter is not a
  receiver;
* SAME-RETURN-VALUE on guard-style early returns (`return false` twice,
  `return []` twice);
* FIXED-ARITY-LIST-RETURN on `dump.bot`'s positional rows.

Its author reached zero warnings in three ways: `nomethod fn` on four
helpers, returns "restructured so they differ", and `-> list` on seven
functions. The author called these "annotations whose only purpose is to
satisfy the linter".

Each rule was audited against the milestone's principle: *a legitimate
exception to a lint rule is first evidence that the rule may be too broad*.
The question for each was whether a principled, reliably established
distinction separates the legitimate cases from those the rule exists for.
SAME-FAILURE was audited too, because it is SAME-RETURN-VALUE's theorem for
the other completion kind, and the handler finding applies to it.

**Corpus effect.** All 164 programs were compiled with the tree before and
after the change, and the HIR and warnings of each were compared. The
programs are every `examples/`, `bench/` and golden suite program, plus a
loader per library module.

* Every outcome and every HIR is identical.
* 475 METHOD-ELIGIBLE findings disappeared, each at a call whose first
  argument is an Int literal.
* 14 SAME-RETURN-VALUE findings disappeared, each a Bool constant returned
  from guard exits of a function that also returns the other value.
* No warning appeared, and no SAME-FAILURE finding changed (the corpus has
  no handler alternatives that fail alike).
* All 489 are in golden test suites. The shipped standard library, examples
  and benchmarks have exactly the warnings they had: the warning gate passes
  with its manifest unchanged.

A disappearing warning is not by itself an improvement. What justifies each
change below is the distinction it rests on; the counts only say how often
the old rule met the case.

### E.1 SAME-RETURN-VALUE

**Original rule and rationale.** The warning fires when several distinct,
reachable exits of a function are proven (exact values, alias roots) to
return one value. Each exit is a decision the reader follows, so two exits
with one value mean one of two things:

* the branching does not affect the result (redundant control flow);
* one in-band value stands for several situations (a sentinel the caller
  cannot tell apart).

**Exceptions investigated**

1. **Handler alternatives.**
   * The case: `moves = solve(b): on Unsolvable: return [] / on
     LimitExceeded: return []`.
   * Why the old rule was imprecise here: Botlish requires one handler per
     error (`on A, B:` is a syntax error), so N errors handled alike are N
     identical bodies the programmer cannot merge. The study's "restructure
     so returns differ" is exactly what happens: rewriting the handlers to
     yield `[]` as values moves the same repetition out of the rule's sight
     without changing the code's meaning. A rule that a meaning-preserving
     respelling silences is imprecise about that case.
   * Principled distinction: exits that are the final expression of sibling
     handlers of one `handle` node are one decision ("this call failed"),
     spelled once per error by the language. This is established
     structurally from the HIR (`handlerBodies`).
   * **Changed:** a group warns only when its sites span at least two such
     units (`hir::warnings::HandlerTails`, `Units`).
2. **Guard-style Bool predicates.**
   * The case: `fn valid?(xs) -> bool: if a: return false / if b: return
     false / true`.
   * Bool has two values, so any predicate with three or more value exits
     repeats one of them by pigeonhole. The warning's fact therefore says
     nothing about the particular function, only that it has more than two
     exits, which is the guard style itself.
   * Earlier evidence pointed the same way. The original milestone's corpus
     audit classified its first Bool finding (`web.bot`'s `domain?`, `false`
     from four exits) as a legitimate "intentional same sentinel". The
     warning-driven refactor later had to contort `domain?`, `emailish?` and
     `valid_from?` to silence it, adding a `break` so that "every rejection
     is the one false after the loop".
   * Principled distinction: the reasoning that already exempts `unit`
     (with one value, repetition collapses no information) applies to
     Bool's two values unless the repeated value is the function's *only*
     answer.
   * **Changed:** a Bool constant is reported only when every value exit
     returns it, as in `if x < 0: return false / false`, a predicate that
     cannot say yes.
3. **Guard-style non-Bool sentinels.**
   * The case: `if x < 0: return -1 / if x > 100: return -1 / x`, the
     warning's documented example.
   * Here the sentinel concern holds: two situations collapse into one
     in-band Int, while Botlish's declared errors exist to name situations.
     The compiler cannot tell a deliberate shared result from a collapsed
     failure, and "this is one result" is a valid answer the warning
     invites.
   * **Not changed.**
4. **Guards separated by statements** (the later guard needs a binding the
   earlier one does not have).
   * Merging the guards into one condition is impossible, but the sentinel
     concern is unaffected. For non-Bool values this is not a principled
     distinction.
   * **Not changed.**

**Tests.** The existing 81 tests otherwise pass unchanged, and the fuzzer
(500 seeds, Int exits) reports 0 failures. Compilerpedia's
`warning.same-return-value` carries one example that warns and three that
stay silent.

* **Positive** (`tests/warnings.test`):
  * `warn-bool-constant-result` and `warn-bool-constant-final-branches`;
  * `warn-bool-binding-still-reported`: a Bool *binding* is an identity, not
    a two-valued constant;
  * `warn-int-guards-still-reported`;
  * `warn-handler-alternatives-and-another-exit`: handler alternatives plus a
    third exit span two units, so the warning is reported with all three
    sites;
  * `warn-handlers-of-two-calls`;
  * `warn-handler-return-not-the-tail`: a return nested inside a handler is
    an ordinary exit.
* **Negative:**
  * `warn-bool-literal`, the guard-style predicate. Its expectation changed
    from one warning to none, with the reason in its title.
  * `warn-bool-unknown-exit-silent` and `warn-handler-alternatives-one-unit`.
* **Updated:** `tests/proves-naming.test`'s `pn-independent-of-other-codes`
  shows that PROVES-NAMING and SAME-RETURN-VALUE are reported independently.
  Its predicate now returns `false` from every exit, so it still trips
  SAME-RETURN-VALUE under the refined rule. The test's theorem and expected
  result are unchanged.

**Why it is precise enough now.** What still warns is either a non-Bool value
repeated across decisions the programmer made, or a Bool function with a
single possible answer.

**Remaining ambiguity**

* A non-Bool sentinel that guards return for genuinely one reason. The
  warning page says this is a legitimate case and how to recognize it.
* A redundant inner `if` whose arms are the same Bool constant, inside a
  predicate that also returns the other value. This is no longer reported,
  and is accepted as a missed case.

### E.2 SAME-FAILURE

**Rule.** Two or more `fail` statements of one function raise the same
declared error with identical payloads.

**Exception investigated: error translation.**

* The case: `on A: fail Bad / on B: fail Bad`. Translating a callee's errors
  into the function's own is recommended practice, but the language forces
  one handler per error.
* The same structural distinction as in E.1 applies: the sibling handler
  tails of one call are one unit.
* **Changed.**
* Tests:
  * `sf-two-handlers-same-failure`: its expectation changed from a warning
    to none;
  * positive: `sf-two-handlers-and-a-guard` and `sf-handlers-of-two-calls`;
  * the new mutant `handler-alternatives-counted-apart`, killed by the unit
    tests;
  * the fuzzer: 300 seeds, 0 failures;
  * the mutation harness: every mutant applies and is killed.

**Not changed: guard `fail`s of one error for different reasons** still warn.
Whether callers need to tell them apart is not decidable, and payloads
already let the author distinguish them.

### E.3 METHOD-ELIGIBLE

**Rule and rationale.** The warning fires on a functional call `f(x, y)` to a
named function of two or more parameters whose method spelling is proven to
resolve to the same function. Receiver syntax is Botlish's preferred form: it
puts the value the operation is about first and chains left to right.

**Exceptions investigated**

1. **Int literal receivers.**
   * The cases:
     * the study's `register_empty_position(0, ...)` (sixteen calls) and
       `register_tile_at(0, 0, ...)`;
     * the refactor milestone's finding 6, which recorded literal receivers
       that "read poorly for position- and count-first helpers"
       (`0.scan_while(p)`, `500.drive(0)`, `1.pair(2)`) and left "whether a
       numeric literal should be one" to this warning's design.
   * What the corpus shows: the shipped corpus's method-form Int-literal
     receivers include `5.between(1, 10)` and `5.outside(1, 10)`, which read
     naturally, and `0.scan_while`, `500.drive`, `400.check`,
     `400.refined_sum`, `0.repeat_uri` and `1.pair`, which are position,
     count or seed parameters.
   * Principled distinction: a receiver is the value an operation is about.
     A written number is almost always a constant parameter of an operation
     on something else, and whether it is the subject is a judgment the
     compiler cannot make. An Int-typed `const` in receiver position is
     detected reliably.
   * **Changed:** Int literal receivers are not reported. The sugared form
     stays legal.
2. **String literal receivers.**
   * The cases: `label("legal moves ...", n)`, `register_rows("three rows",
     ...)`.
   * Against a change: the same study's author wrote `"move:
     ".concat(case.name)` in method syntax. The corpus has 30 String-literal
     method receivers, 22 of them `concat` with a literal prefix, which read
     naturally. No structural feature separates a label from text being
     operated on.
   * **Not changed.**
3. **Non-receiver first parameters in general** (procedural or symmetric
   helpers, a name or an index first).
   * Candidate signals were examined and rejected:
     * a primitive first parameter (`pad(s: str, width)` is a natural
       receiver);
     * a unit result (`v.push(x)` is a natural receiver);
     * same-typed first two parameters (`a.concat(b)`);
     * the callee living in the entry program.

     None of them separates the cases.
   * This is the author's decision, which the language puts at the
     declaration with `nomethod fn`: a statement about the function's
     interface that makes method syntax an error, not a call-site
     suppression.
   * **Not changed; documented** in `warning.method-eligible` (LEGITIMATE
     EXCEPTIONS) and `concept.nomethod`.

**Tests**

* `me-form-int-literal`: its expectation changed. The receiver form is
  accepted and the two spellings are one program, but there is no warning.
* `me-int-literal-receivers-not-reported`:
  * `0`, `500` and a huge literal are silent;
  * String, character, Bool, list and struct literal receivers of the same
    call are still reported.
* `me-int-valued-receiver-still-reported`: a name, field or call of Int type
  is reported.
* Three tests used `5` as an incidental receiver:
  * two now use `"ab"` (`me-generic-callee-and-receiver-silent-where-unprovable`,
    `me-top-level-call`);
  * one drops it from the expected form list (`me-form-receiver-forms-recorded`).
* Harnesses:
  * The fuzzer moves Int literals to generated quiet statements: 300 seeds,
    0 failures, 1515 of 1515 round trips.
  * The new mutant `int-literal-receivers-reported` is killed by the fuzzer.
  * The MANY-BOOLEAN-ARGUMENTS fuzzer, which predicts METHOD-ELIGIBLE at its
    sites, now leaves out Int-literal first arguments: 200 seeds, 0 failures.

**Remaining ambiguity.** The corpus effect includes math-style calls whose
first argument would have been a natural receiver: `mod(7, 3)` (9 calls) and
`shift_left(1, 4)` or `shift_right` (8 calls), as `7.mod(3)` and
`1.shift_left(4)`. They are no
longer suggested. That is the cost of a rule the compiler can decide, and the
page says the sugar remains available.

### E.4 FIXED-ARITY-LIST-RETURN

**Rule.** Every value exit of a function is a written list literal of one
arity N >= 2, and no list result type is declared.

**Exception investigated: positional rows.**

* The case: `dump.bot`'s rows, positional on purpose for an external oracle.
* The warning's design already considered this ("heterogeneity is not
  required, and the honest gap"): a genuine fixed-length sequence and a
  multi-value result are indistinguishable by their shape. Only the
  author's intent separates them, stated once at the declaration with
  `-> list`. That annotation is a real type the checker proves and the
  reader sees, not a suppression.
* The alternative signal was examined and rejected: inspecting how a result
  is consumed (never indexed inside the program, only printed) would need
  whole-program use analysis, and would still miss the external consumer.
* **Not changed; documented.** `warning.fixed-arity-list-return` presents
  `-> list` as the intended response, not a workaround.

### E.5 Not audited in depth

* **Not met by the study:** PROVES-NAMING (scoped by `proves`, nothing to
  narrow), MANY-BOOLEAN-ARGUMENTS (literals only, gated by the signature)
  and ONE-CHAR-STRING-LITERAL.
* **ONE-CHAR-STRING-LITERAL** is deliberately context-blind. It fires even
  where the consumer requires a String (a `str` parameter), which makes it
  the warning most likely to fire on reasonable code. Its design treats
  those findings as a catalogue of String-taking APIs.
  * Compilerpedia says so: its LEGITIMATE EXCEPTIONS section reads "not
    recognized, by design".
  * Whether to narrow it is section J's first compiler item.

## F. 15-puzzle surprise-log assessment

The study's surprise log (botlish-15-puzzle, `surprise-log.md`) against the
current compiler and Compilerpedia. Every query was run against the packed
executable outside the repository. The "lands on" column is the page the
query shows, or the topic a diagnostic's help line names.

| # | Surprise | Assessment | Validating query -> lands on |
|---|---|---|---|
| S1 | No usage; `./botlish` silently runs demos; `-help`/`-version` unknown | **Resolved by this milestone** (CLI, section B) | `botlish` -> usage; `botlish -help` -> overview; `botlish -version` |
| S2 | Download blocked by the sandbox network | Outside scope (environment) | -- |
| S3 | KNOWN-ERROR on a statically failing call, even inside a handler | **Explained**: by design; the page says why a handler does not help and gives the two test techniques (a registration parameter; `static compile:` with `std::test::rejects`) | `-help KNOWN-ERROR` -> error.known-error; `-help "negative tests"` -> concept.negative-tests |
| S4 | One handler per error; only the first unhandled error reported | **Earlier work** resolved the second half: the compiler now names every unhandled error in one diagnostic, checked here (`"A", "B" and "C"`). **Explained**: the one-handler rule and the one-error-with-payload design. **Lint precision**: identical handlers no longer draw SAME-RETURN-VALUE/SAME-FAILURE | `-help "handle several errors"` -> task.handle-several-errors |
| S5 | Forward references not allowed | **Explained**. The study's note that "`mutual:` exists" is wrong: it is a design only (MUTUAL-RECURSION.md), and the pages say so with the workaround | `-help "forward reference"` -> rule.forward-references; `-help "mutual recursion"` -> concept.mutual-recursion |
| S6 | Bounds guard proves `std::list::at` for parameters, not for local bindings | **Explained**, still a **limitation**: proof.list-bounds lists the proven forms and the unproven ones (a computed local index), and the UNHANDLED-ERROR of an unproven `std::list::at` prints a help line to it | `-help "bounds proof"` -> proof.list-bounds; the diagnostic's `help: ... -help proof.list-bounds` |
| S7 | METHOD-ELIGIBLE steers towards method syntax | **Explained**: rationale, evidence, exceptions, `nomethod`. **Lint precision**: Int literal receivers | `-help METHOD-ELIGIBLE` -> warning.method-eligible |
| S8 | Large performance spread between backends | **Explained** (backend.performance, task.choose-backend); the speed itself is outside scope | `-help "fastest backend"` -> task.choose-backend |
| S9 | `std::io::print_line` is native-only; the message doesn't say all output is | **Explained**: what prints where, and the portable alternative (the program's value) | `-help "print output"` -> task.print-output; `-help NATIVE-ONLY` -> error.native-only |
| S10 | No way to set the process exit status | **Explained** as absent; **stdlib limitation** remains | `-help "exit status"` -> capability.process-exit-status |
| S11 | Validation order (the study's own design) | Outside scope | -- |
| S12 | `import type` rejects structs | **Explained**, a language rule: the page names the spelling to use instead | `-help "import type"` -> rule.import-type; `-help "import struct"` -> capability.struct-type-import |
| S13 | A method call without `import std::str` gives a misleading TYPE error | **Earlier work** (diagnostic recovery) resolved it, checked here: `namespace "std::str" is not imported; add import std::str ... (CORE SEMANTIC MISSING-IMPORT)`. **Explained**: why sugar needs the import | `-help MISSING-IMPORT` -> error.missing-import |
| S14 | A loop cannot be a call argument; terse diagnostic | **Explained**: a matcher sends `expected an expression, found "loop"` to the rule, which says to bind it first. Still a language rule | `-help "loop arguments"` -> rule.loop-placement |
| S15 | Slow compile of the test suite; one error per run | **Earlier work** resolved the second half (several diagnostics per run). Compile speed is outside scope | -- |
| S16 | Bounds-proof coverage for `std::list::at` is narrow | **Explained**, still a **limitation**: each reduced case of S16 was rechecked on the current compiler. Proven: a parameter container, ascending loops, guards on parameters, local-bound containers, literal lists. Not proven: field-path containers, descending loops, `i - 1`, lockstep-descending, computed local indices. The page records each, with the restatement that is proven | `-help "indexed access"` -> proof.list-bounds |
| S17 | `if` is never an operand; error cascade | **Earlier work** removed the cascade: one diagnostic now, checked here. **Explained**: a matcher sends the diagnostic to rule.if-placement | `-help "ternary operator"` -> rule.if-placement |
| S18 | No Int-to-String conversion; no integer division | **Explained** (`std::test::int_text`; `mod` exists, `/` and `%` do not), still a **stdlib limitation**. Matchers send `/` and `%` syntax errors to the page | `-help "integer to string"` -> capability.int-to-string; `-help division` -> capability.integer-division |
| S19 | Warning policy vs. test helpers (`nomethod`, restructured returns, `-> list`) | **Lint precision**: guard-style Bool returns and handler alternatives no longer warn; Int-literal receivers are not suggested. **Explained**: `-> list` and `nomethod` are declarations of intent, not suppressions | `-help SAME-RETURN-VALUE`, `-help FIXED-ARITY-LIST-RETURN`, `-help lint` |
| S20 | Executable and CLI output conventions | **Explained** | `-help cli.output`; `-help "exit code"` -> cli.exit-status |
| S21 | The test framework has no per-test timeout | **Explained** as absent, with the alternative; still a **limitation** | `-help "test timeout"` -> capability.test-timeout |
| S22 | Things that worked first time | -- | -- |

### Black-box acceptance audit

**How it was run.** An independent agent answered the milestone's twelve
questions.

* It used only the packed `botlish`, in a directory outside the
  repository, with no access to the source, the docs or any repository.
* It ran every query a newcomer would, dead ends included.
* Wherever an answer made a claim, it verified the claim by compiling a
  program of its own.
* A question counted as answered only if the page reached actually answered
  it; an index entry that was merely related did not count.

The audit ran on the catalogue as it stood before the fixes listed after the
table. The table records what the audit found at the time, and the fixes are
listed separately.

| # | Question | Decisive query (queries tried) | Verified by a program | Verdict |
|---|---|---|---|---|
| 1 | Invoke the compiler and select a backend | `botlish` with no arguments: the usage lists `-backend` and the four backends; then `-help "select backend"` -> task.choose-backend (5) | `1 + 2` gives 3 on all four backends; `-backend foo` exits 2 | answered |
| 2 | Find an operation for indexed list access | `-help "list element"` -> task.list-element, or `-help "list index"` -> proof.list-bounds (10) | `xs.at(1)` with a handler works; without `import std::list`, MISSING-IMPORT | answered |
| 3 | When indexed access is proven unable to fail | `-help "bounds proof"` / `"list index"` -> proof.list-bounds (6) | 6 proven forms accepted with no handler. A literal index past the end is KNOWN-ERROR. `i + 1`, a descending loop, a computed local index and an unguarded parameter are UNHANDLED-ERROR, and their help line names this page. The documented remedy works | answered |
| 4 | Why a method-style call needs an imported namespace | `-help "why method call needs import"` -> rule.method-requires-import (3), or the diagnostic's help line | MISSING-IMPORT at 2:3, UNBOUND for the bare name, the qualified-name variant and NOT-A-STRUCT all as documented | answered |
| 5 | Handle several declared errors | `-help "handle several errors"` -> task.handle-several-errors (4) | two handlers; `on A, B:` is a syntax error; the enum-payload design works; one diagnostic lists every unhandled error | answered |
| 6 | Test a call that is statically known to fail | `-help "test expected failure"` -> concept.negative-tests (6) | Both techniques pass, and both fail when the expectation is wrong. The literal call is KNOWN-ERROR at 12:9, as the page says | answered |
| 7 | Why an `if` or `loop` is rejected as an operand | the diagnostic's help line -> rule.if-placement / rule.loop-placement (3) | the messages, positions and allowed forms all match | answered |
| 8 | What METHOD-ELIGIBLE recommends, and why | `-help METHOD-ELIGIBLE` (1) | Warns or stays silent as documented, Int-literal receivers included. `nomethod` gives NOMETHOD-CALL. `-warnings error` rejects | answered |
| 9 | When an early return is reasonable despite SAME-RETURN-VALUE | `-help SAME-RETURN-VALUE`; `-help "early return"` -> principle.guard-clauses (4) | 8 cases, all as documented: the guard predicate is silent, an all-false predicate warns, handler alternatives are silent | answered |
| 10 | Which forms of I/O work on which backend | `-help "which io works on which backend"` -> backend.io (11) | Printing works natively and is NATIVE-ONLY on interp and compile, as documented. **Standard input can be read through `std::linux::io::read` natively, which the pages denied** | partial |
| 11 | Whether a conversion, an exit status or a test timeout exists | `"int to string"`, `"process exit"`, `"test timeout"` -> the capability pages (16) | `std::test::int_text` works; `std::str::of` and `std::test::timeout` do not exist; a hanging test hangs; an executable's run-time error exits 1 | answered |
| 12 | Where warnings, errors, rules and practices are indexed | `-help` (the overview names all nine indices) (10) | -- | answered |

Result: 11 answered and 1 partial. Every question was answered by the first
or second query, or by a diagnostic's help line.

**Problems the audit found, and what was done**

* **Fixed:**
  * **The input pages were wrong.** capability.input and backend.io now
    document `std::linux::io::read`. The example was verified: it reads stdin
    natively, and interp gives NATIVE-ONLY.
  * **A stale library comment.** It called MutableArray "a reference to a
    shared store" and appeared on stdlib.module.std::abi::bytes. It is corrected
    in `stdlib/abi/bytes.bot`, in place, with the same line count.
  * **Examples drew warnings they did not state.** Two examples did, and
    once the check required stating them, 16 more turned up. The check now
    fails on any warning an example does not declare, and all 18 examples
    were rewritten idiomatically: method syntax, or `nomethod` for a
    label-first helper.
  * **`xs[1]` produced a type-syntax error with no guidance.** A matcher now
    sends it to task.list-element, which says there is no subscript and to
    use `.at`; `-help "xs[i]"` lands there too.
  * **Index counts were off by one.** The overview counted each index's own
    introduction page; the counts now agree everywhere.
  * **Searches that missed:**
    * `-help capabilities` and `"missing features"` now reach a new
      capability.overview page.
    * `"best practices"` and `"list of errors"` reach their indices.
    * `toString` and `"catch multiple exceptions"` reach their pages.
    * Plurals in `-ies` and `-es` now fold to their singular.
    * A page that merely mentions a query's words is now a near match, not
      an answer.
  * **The `==` limitation of call decisions.** It is now documented in
    proof.completions: `if n == 7: fail C` decides neither `f(7)` nor
    `f(3)`, while `n >= 7 and n <= 7` decides both.
  * **References a reader of the packed compiler cannot use.** Internal
    study IDs (S3, S13) were removed from pages, and `main.tcl` in prose now
    reads `botlish` or "the compiler".
  * **The SAME-RETURN-VALUE page did not say a kept finding stays.** It now
    does: there is no way to silence one finding.
* **Recorded, not fixed** (section I):
  * A top-level call's UNHANDLED-ERROR is printed before the root cause it
    restates. This is the compiler's diagnostic order.
  * The NATIVE-ONLY message for `std::io::print_line` on interp names
    `std::abi::x86_64::from_bytes`. The help page explains it, but the message is
    cryptic.
  * `std::str::is_tcl_alnum` and `std::str::is_tcl_alpha` are public.

## G. Correctness and regression testing

All commands ran with `LANG=C.utf8 LC_ALL=C.utf8` and `tclsh9.0` 9.0.1.

**The whole local suite.** Command: `tclsh9.0 tests/local.tcl -jobs 4`, on
a 4-core container with the front-end cache empty (the front end changed).
It took 36.6 minutes.

| part | result |
|---|---|
| 192 Tcl test files on interp and compile | 11,865 passed, 2 failed, 4,231 skipped (the manifest's golden duplicates and host constraints) |
| 94 golden suites on interp, compile, cranelift-generic and cranelift | 18,822 of 18,822 test runs passed |

**The one failure, and its fix.** The two failures are one test,
`native-output-failure-keeps-output`, failing on both backends.

* It pins main.tcl's stdout byte for byte, and that output now ends with
  the help line after the error.
* The test's theorem (the output, then the error line, in that order,
  exit 1) is unchanged. Its expected bytes now include the help line, and
  so do its census row and manifest entry.
* The test then passed on both backends.
* No other test pinned main.tcl's output in a way the help lines changed.

After the last changes, `tests/local.tcl -parts tcl` was run again over the
38 test files that drive main.tcl or Compilerpedia, on interp and compile:
3,553 passed, 0 failed, 1,405 skipped (golden duplicates and host
constraints), in 8.4 minutes.

**Compilerpedia**

| command | result |
|---|---|
| `tclsh9.0 tools/compilerpedia.tcl check` | 660 topics, 511 examples run (interp and compile; native-only ones on cranelift and cranelift-generic), 0 problems, 30 s |
| `tclsh9.0 tests/compilerpedia.test` | 34 of 34 |
| `tclsh9.0 tests/main-cli.test` | 32 of 32 |
| `tools/compilerpedia.tcl inventory` | 223 entries, every one documented |

**The lint refinements**

| command | result |
|---|---|
| `tests/warnings.test`, `tests/same-failure.test`, `tests/method-eligible.test`, `tests/proves-naming.test`, `tests/many-boolean-arguments.test` (interp and compile, in the full run) | all pass |
| `audit/method-eligible/tools/fuzz.tcl 300` | 0 failures, 1,515 of 1,515 round trips |
| `audit/same-failure/tools/fuzz.tcl 300` | 0 failures |
| `audit/same-return-value/tools/fuzz.tcl 500` | 0 failures |
| `audit/many-boolean-arguments/tools/fuzz.tcl 200` (its METHOD-ELIGIBLE oracle updated), `audit/fixed-arity-list-return/tools/fuzz.tcl 200`, `audit/one-char-string-literal/tools/fuzz.tcl 200`, `audit/proves-naming/tools/fuzz.tcl 200` | 0 failures each |
| `audit/method-eligible/tools/mutate.tcl` | 9 of 9 mutants applied and killed, including the new `int-literal-receivers-reported` |
| `audit/same-failure/tools/mutate.tcl` | 16 of 16 applied and killed, including the new `handler-alternatives-counted-apart` |
| `audit/refactor/tools/gate.tcl` (the warning gate) | passed: observed warnings are exactly the manifest, which did not change |

**Other regression boundaries**

| command | result |
|---|---|
| `audit/diagnostic-recovery/tools/efficiency.tcl` | passed: 14 cases, every primary in the first compilation, no cascade. It parses main.tcl's error lines, and the help lines do not disturb it |
| `audit/golden/migration/merge.tcl -names audit/golden/migration/tcl-names.txt -check 1` | consistent: 9,490 manifest rows, 79 of them new (KEEP-WARNING, KEEP-INTERNAL, KEEP-MULTI-PROGRAM) |
| before and after comparison of 164 programs: every `examples/`, `bench/` and golden program plus a loader per library module, each compiled by the tree before and after | every outcome and HIR identical; warnings changed only as section E describes |

**Changed expectations**, each with its reason in the test's title or its
census row:

* `warn-bool-literal`, `sf-two-handlers-same-failure` and
  `me-form-int-literal` are the lint refinements (section E).
* `pn-independent-of-other-codes`: its predicate now returns `false` from
  every exit, keeping the test's theorem.
* `native-output-failure-keeps-output`: the help line, above.
* No golden suite and no golden expectation changed.

**Packaging**

* `single/build.sh` produced an 8,106,977-byte executable.
* `single/smoke-test.sh single/out/botlish` passed. It now also checks the
  usage, `-help`, four queries, an unknown query and `-version`, all
  without running a program.
* Outside the repository, with an empty environment and a fresh HOME, these
  all behaved as documented: `./botlish`, `-help`, `-help warnings`,
  `-help METHOD-ELIGIBLE`, `-help std::list::at`, `-help "bounds proof"` and
  `-version`.
  * None of them ran a program or created a cache directory.
  * An explicit `p.bot` ran on interp and cranelift.

**CI** (`workflow_dispatch` on the branch):

* `single-executable.yml` passed: the build and the smoke test in stock
  ubuntu containers.
* `tests.yml` on the first head:
  * passed: warning gate, native Rust unit tests, and golden shards 1 to 4
    (every suite beside its Tcl originals);
  * failed: the stub-linked job, on the same pinned-output test, fixed above.
* `tests.yml` on the next head failed only in the interp and compile jobs'
  examples step. That step, in `tests-arm64.yml` too, ran main.tcl with no
  file and relied on the old demo mode; main.tcl then rejected it (`no
  input file`). Both workflows now name `examples/*.ir`, and on that head
  `tests.yml` and `tests-arm64.yml` passed every job.
* Main gained the macOS port's CI in the meantime, and the branch merged
  it. Two more fixes followed:
  * its `tests/platform/tier.tcl` relied on the demo mode in the same way;
  * the Compilerpedia check ran native examples on a host whose native
    runtime does not yet make Linux syscalls or C calls.
* On the final head, after the merge and those two fixes:
  * `tests.yml` passed every job: interp, compile, cranelift and
    cranelift-generic coverage, stub-linked executables, golden shards 1
    to 4, warning gate and native Rust unit tests. The GC-stress job
    runs only on pushes to main.
  * `macos-arm64.yml` passed: Tier A smoke, Tier B acceptance (both
    shards) and the Linux control.
  * Since their green runs, nothing `single-executable.yml` packs has
    changed. For `tests-arm64.yml`, the only change is the examples
    check's host test, which still selects the native backends on Linux
    AArch64.

The static-decisions workflow was not dispatched. It compares the
schedulers' decisions, which are taken inside the build, from diagnostics.
Warnings run after the build, and nothing else this milestone changed is
read by a build. It runs automatically when the change reaches main.

## H. Performance and distribution

Medians of 7 runs, idle 4-core container. The interleaved comparisons
alternate the two trees run by run, over 21 to 25 runs.

| invocation | before | after |
|---|---:|---:|
| `tclsh9.0 main.tcl` (no arguments) | ran the 4 demo programs | 9 ms (usage) |
| an unknown option, until the error | 67 ms (the compiler was loaded first) | 9 ms |
| `-version` | -- | 90 ms (it loads the front end, for the fingerprint) |
| `-help` (overview); `-help METHOD-ELIGIBLE`; `-help std::list::at`; `-help "bounds proof"`; `-help errors` | -- | 143-166 ms |
| `-help "how do I print a number"` (word search) | -- | 370 ms |
| `-help xyzzyx` (nothing; near matches) | -- | 363 ms |
| a clean program, interp (`1 + 2`), interleaved, 25 runs | 98 ms | 100 ms |
| the same with `-warnings off` | 98 ms | 101 ms |
| `examples/surface/01-arithmetic.bot` on cranelift, 11 runs | 135 ms | 140 ms |
| a program with one warning (warning plus help line) | 120 ms | 175 ms |
| a syntax error (diagnostic plus help line) | 76 ms | 103 ms |
| single executable: usage / `-help METHOD-ELIGIBLE` / word search | -- | 13 / 143 / 392 ms |

**Overhead on normal compilation.**

* A clean compilation never loads Compilerpedia. Its measured difference
  (+2 to 5 ms) is within the run-to-run spread.
* A compilation that prints a diagnostic or warning pays for its help line.
  The cost is 27 ms for a rejected program, because the help line is looked
  up from the topics' header lines (`compilerpedia::DiagnosticTables`, which
  a test holds equal to the full load) rather than a load of the
  catalogue; the first version, which loaded it, cost about 130 ms.
* An exact lookup costs about 150 ms, mostly parsing the 1 MB catalogue.
* A word search costs about 370 ms, because it builds the word index on
  first use.
* Neither needs a cache, and both are fast enough to be interactive.

**Distribution.**

* The packed `compilerpedia/` (engine, topics and generated stdlib) and the
  `BUILD` file are 16 archive entries: 1,090,146 bytes, 305,061 compressed.
  That is 3.8% of the 8,106,977-byte executable.
* The demo programs (`examples/*.ir`, 1.6 KB) are no longer packed.
* Help, usage and `-version` install no native executables and create no
  cache directory.

## I. Remaining limitations

**What Compilerpedia does not document well yet**

* **Run-time errors.** Their pages describe the run but cannot check it as
  an example (section D).
* **Internal diagnostics.** HIR, NIR and core IR text errors are documented
  briefly. They concern people writing IR by hand, not Botlish programmers.
* **Library DESCRIPTION sections.** These quote source comments written for
  maintainers.
* **Proof pages.** They state the patterns as the compiler recognizes them
  today, and do not explain derivations. Interactive proof traces were out of
  scope.

**Broad diagnostic mappings**

* `CORE SEMANTIC TYPE` has 6 rule topics (argument, result, field,
  annotation, declaration, generic call). Messages outside their matchers
  land on `error.type`.
* `SURFACE SYNTAX` has matchers for the common rules: if and loop placement,
  indentation, names, handlers, `break`, `/`, `%`, floats, `null` and
  lambdas. Any other parser message lands on `error.surface-syntax`, which
  lists the specific rules.
* `NATIVE UNSUPPORTED` with a computed kind falls back to its family page.

**Behaviour the topic writers found contradicting a document or reasonable
expectation.** These are recorded here, not fixed: each is compiler work or
a document correction outside this milestone. Each is reproduced by a
program kept with the writer's notes.

* **Checked only at run time** (CORE SEMANTIC TYPE, ARITY, NOT-BOOLEAN,
  NOT-CALLABLE or EQUALITY, without a source location), although the
  mismatch is visible statically:
  * the argument kinds of intrinsics: `std::str::length(5)`, `"a" + "b"`;
  * `[1, 2].length()` when only `str` or `mutable_vector` is imported:
    the method sugar picks that namespace's `length`;
  * the argument count of an ordinary function: `add(1, 2, 3)`;
  * `if 3:`, `x(4)` for an Int `x`, `==` on functions;
  * `mod(7, 0)`;
  * ordering comparisons of Strings.
  * The pages state each of these honestly.
* **Misleading messages:**
  * Inside a typed function, a wrong-arity call reports "function result
    does not prove declared type int (facts: [-∞, +∞])" at the `fn` line,
    before the real cause. So does `return "pos"` in an `-> int` function,
    which never names `str`.
  * USE-AFTER-MOVE leaks a hygienic name ("moved here: destructure#195 =
    job").
  * EQUALITY and `hash` call MutableArray and MutableVector values
    "callables".
  * The import-placement message mentions a "namespace" declaration
    Botlish no longer has.
* **Inconsistent codes:**
  * Two `error Boom` declarations report UNDECLARED-ERROR.
  * A field declared twice in a `struct` declaration is TYPE, but
    DUPLICATE-FIELD in a construction.
  * An enum named like a trait is TYPE, not TRAIT-NAME-COLLISION.
* **Inconsistent or unreachable compiler paths:**
  * Resuming a temporary coroutine (`make()()`) compiles, while
    `std::coroutine::done?(make())` is AFFINE-TEMPORARY-UNSUPPORTED.
  * The parser's `on A | B:` branch is unreachable, because the lexer
    rejects `|` first.
* **Backends that disagree:**
  * `fn getx(p): p.x` called with two struct types runs on interp, compile
    and cranelift, but is NATIVE UNSUPPORTED struct-shape on
    cranelift-generic.
  * A context struct with a plain `int` or `str` field runs on the Tcl
    backends and fails natively (CONTEXT-NATIVE-LOWERING-UNSUPPORTED).
  * For invalid core IR `{struct {Point x y} x {const 1}}`, interp raises
    STRUCT and compile returns `{x: 1}`.
* **Found by the black-box audit:**
  * An UNHANDLED-ERROR at a top-level call is printed before the root cause
    it restates, which is in the function the call reaches.
  * On interp, the NATIVE-ONLY message for `std::io::print_line` names
    `std::abi::x86_64::from_bytes`.
  * `std::str::is_tcl_alnum` and `std::str::is_tcl_alpha` are public.
* **main.tcl file errors:** a plain run of a malformed `.hir` file shows HIR
  PARSE as a raw Tcl stack trace, and so does a `.ir` file that is not a Tcl
  list. This was not changed here: it is error-path work in main.tcl's run
  loop, not help.
* **Design documents out of date** (the compiler wins, and the pages follow
  it):
  * docs/README.md §17 said an `if` can be the value of `break`. It never
    takes a value, and this milestone corrected README.
  * IMPORTS.md says `import type` covers integer domains only and that
    errors are not namespaced.
  * MODULE-BINDINGS.md shows a `namespace web` header and says function
    bodies may refer to later module bindings.
  * STRICT-TYPED-PARAMETERS.md says there are no composite parameter types.
  * AFFINE-VALUES.md points 12 and 65 still say `MutableArray[affine]` is
    rejected.
  * COROUTINES.md point 59 says handles live in local bindings only.
  * MUTABLE-VECTOR.md §19 names AFFINE-VECTOR-COPY-OUT (the code is
    AFFINE-ELEMENT-COPY-OUT).
  * UNICODE-CHAR-LITERALS.md names `std::char::codepoint` (it is
    `std::char::scalar_value`).
  * README §7 describes RANGE as an index out of range (indexing now fails
    with IndexNotFound).
  * stdlib/ffi/c.bot and stdlib/abi.bot have stale header claims.

**Unavailable machine-readable metadata**

* **Natives have no description in the registry**, so each needs a
  hand-written note. The check enforces that a note exists, not that it is
  correct; its examples verify the behaviour they show.
* **A diagnostic's specific rule is not a field of the diagnostic.**
  Matchers read the message text, so rewording a message can silently move
  it to the broad page. The check catches that for every matcher with an
  example: each matcher has one, and the example's help line must name the
  matcher's topic.

## J. Recommendations

**Low-cost documentation work**

1. **Correct the out-of-date design documents in section I.** Each takes
   minutes, and several mislead agents that read them, as they misled the
   15-puzzle study about `mutual:`.
2. **Give the remaining broad `SURFACE SYNTAX` and `CORE SEMANTIC TYPE`
   messages specific rules** as they show up in user programs. Each is a
   topic, a matcher and a rejected example.
3. **Rewrite maintainer-oriented library header comments**, or let a note
   replace a DESCRIPTION section, so that generated pages read as user
   documentation.
4. **Add checked examples for run-time errors.** The example runner would
   need an `@runtime-error CODE` directive. This is small tool work.

**Compiler work (diagnostics, not language design)**

5. **Narrow or re-examine ONE-CHAR-STRING-LITERAL** where the consumer
   requires a String. It is the warning most likely to fire on reasonable
   code, so it deserves the same audit this milestone gave the other three.
6. **Report statically visible run-time-only failures at compile time**
   (section I): intrinsic argument kinds, the arity of ordinary functions,
   `if` on a non-Bool, calling a non-callable, `mod` by a literal zero.
   These are the cases most likely to surprise a programmer told that types
   are proven.
7. **Order the typed-function diagnostics** so that the arity or argument
   cause comes before "function result does not prove declared type", and
   name the actual type in that message.
8. **Fix the message defects:** the hygienic name in USE-AFTER-MOVE,
   "callables" for containers, the "namespace" declaration, the code for a
   duplicate `error`.
9. **Have main.tcl format `.hir` and `.ir` read errors** like every other
   diagnostic.

**Language or analysis work** (only with a design of its own; this milestone
documents the limits instead):

10. Bounds proofs for local indices, field-path containers and descending
    loops (S6, S16).
11. An Int-to-String conversion and integer division in the standard
    namespaces (S18), a process exit status (S10), and a test timeout (S21).
12. A structured "specific rule" field on diagnostics, so that help lines
    need no message matching.
