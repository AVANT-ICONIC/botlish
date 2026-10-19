# Idiomatic Botlish: the newcomer page of Compilerpedia

A documentation and discoverability milestone. It adds one Compilerpedia
topic, `principle.idiomatic-botlish`, and one line to the `-help` overview.
It changes no language semantics, diagnostic, warning, proof rule,
standard-library API or backend. COMPILERPEDIA.md is the architecture and
maintenance guide; this report records what the page is, how it is found and
what was measured.

## 1. The relationship between the layers

```
Idiomatic Botlish                  gives the defaults
specific warning/rule/proof pages  give the details, rationale, exceptions and examples
diagnostic "help:" lines           take the programmer to the relevant detail when needed
```

The page is a map. It is not the planned human-oriented tutorial: it does
not teach syntax and has no narrative or exercises. It is for an experienced
programmer or coding agent who can infer syntax quickly and needs to know
which assumptions to change before writing a substantial program.

## 2. The topic

| | |
|---|---|
| ID | `principle.idiomatic-botlish` |
| Title | Idiomatic Botlish |
| Indices | `principles`, `concepts` (no new index) |
| File | `compilerpedia/topics/principles.topic` (first topic of the file) |
| Aliases | `idiomatic`, `idiomatic Botlish`, `idioms`, `best practices`, `best practice`, `style`, `coding style`, `botlish style`, `how should I write Botlish`, `how to write Botlish` |
| Keywords | `idiomatic`, `best practices`, `style`, `newcomer` |
| Related | `principle.receiver-first`, `rule.application-modules`, `principle.errors-over-sentinels`, `principle.investigate-warnings`, `proof.overview`, `capability.overview` |

`best practices` was an alias of the principles index (`index.principles`).
It moved to the new page; that index keeps `recommended practices`, `coding
guidelines` and `style guide`, so `-help "style guide"` still shows the whole
principles index, and its introduction now points at the new page.

Each principle section starts with its kind: **language rule** (the compiler
enforces it), **idiomatic default** (code may depart from it for a reason) or
**declaration of intent** (written at a declaration, such as `nomethod fn`).
The page is 12 sections (an introduction and 11 principles), about 650 words
of prose and one checked example.

### The principles

| # | Heading | Kind | Detail pages |
|---|---|---|---|
| 1 | Receiver syntax for an operation about its first argument | default; `nomethod fn` is a declaration | `principle.receiver-first`, `concept.nomethod`, `warning.method-eligible` |
| 2 | Method syntax always uses the first parameter | language rule | `concept.method-sugar`, `rule.method-resolution` |
| 3 | Imports keep the full qualified name | language rule | `concept.imports`, `rule.application-modules`, `rule.imports-not-transitive` |
| 4 | Declared errors for distinct failures | default | `concept.errors`, `principle.errors-over-sentinels`, `warning.same-failure`, `warning.same-return-value` |
| 5 | Warnings ask about intent | default | `lint.policy`, `principle.investigate-warnings`, `principle.lint-precision` |
| 6 | Structs are named products; Lists are sequences | default | `principle.name-the-parts`, `concept.structs`, `concept.lists`, `warning.fixed-arity-list-return` |
| 7 | Control forms have placement rules | language rule | `rule.if-placement`, `rule.loop-placement`, `principle.bind-before-use`, `concept.if-expressions`, `concept.loops` |
| 8 | Let proofs remove failure handling | default | `proof.overview`, `proof.list-bounds`, `principle.restate-in-proven-form` |
| 9 | Mutation goes through places | language rule | `concept.mutable-vector`, `concept.mutable-array`, `principle.immutability` |
| 10 | Ordinary values until a boundary needs a representation | default | `concept.binary-layouts`, `concept.c-ffi`, `concept.values` |
| 11 | Query Compilerpedia before building a workaround | practice | `capability.overview`, `cli.output`, `lint.warnings-vs-errors` |

Every ID was taken from the current catalogue; the catalogue's
`cp-inline-references-resolve` test checks them, and so will any later rename.

### The example

One checked example, in principle 1: `wide?(board)` is about its board and is
called as `board.wide?()`; `titled(title, board)` starts with a label, so it
is declared `nomethod fn` and called functionally. It compiles with no
warning and prints `"game (wide)"` on every listed backend. No multi-file
example was added: the module rule (principle 3) is stated in words and
linked to `rule.application-modules`, which has the multi-file illustration.
The rule was also checked by hand with a two-file program: `import
engine::board` then `engine::board::goal()` runs; `board::goal()` is
`UNKNOWN-NAMESPACE`; `goal()` is `UNBOUND`.

## 3. The overview line

`-help` with no query now prints, under the introductory paragraph:

```
New to Botlish?  botlish -help "best practices"
```

(`tclsh9.0 main.tcl -help "best practices"` in a checkout: the line uses the
invocation name, as the other examples do.) The change is one line in
`compilerpedia::renderOverview`. The compiler's own no-argument usage
summary is unchanged. `cli-help-overview-newcomer-line` pins the line and
that its query reaches the page.

## 4. What this page deliberately does not teach

* Syntax, "hello world", installation: other pages and the usage summary.
* The reasons, full exception lists and examples of any rule or warning:
  METHOD-ELIGIBLE's exceptions, SAME-RETURN-VALUE's, the proof patterns and
  their limits all stay on their own pages.
* Which standard-library operations exist (`stdlib` index), how a diagnostic
  reads (`errors` index), how contexts, traits, affine values, coroutines or
  static compile work (their concept pages).
* Copy-on-write, contexts and ownership internals: principle 9 gives only the
  user-visible model.
* What Botlish lacks (`capability.overview`).
* Language-design history, compiler architecture, study identifiers and
  future design.

## 5. Search

The six required queries and close variants resolve directly to the page:

| query | result |
|---|---|
| `best practices`, `best practice` | the page |
| `idiomatic`, `idiomatic Botlish`, `idioms` | the page |
| `style`, `coding style`, `botlish style` | the page (an alias hit, ahead of `index.principles` and `principle.receiver-first`, which `style` listed before) |
| `how should I write Botlish`, `how to write Botlish` | the page (exact aliases; the word search found 15 unrelated pages before) |

No ranking change was made: the page uses ordinary aliases and four keywords.

### Regressions

A corpus of 3,306 queries (every topic ID, title, alias and keyword phrase,
plus 30 generic words) was looked up in a clean checkout of the parent
commit and in the changed tree. After two adjustments the only differences
are the intended ones:

* `best practices` and its new variants, `idioms`/`idiom`, `style`,
  `newcomer`, the page's own ID and title: the new page.
* `index.principles` keeps its other aliases.

Two adjustments came from this comparison. (1) Naming Python, JavaScript,
Rust, Java and C# in the summary made `-help rust` (one page,
`backend.native-executable`) a two-item list, and `python`/`java`/`javascript`
find the page; they now appear in the body only, where a page that merely
mentions a word is a near match and does not answer. (2) The keywords `mental
model` and `first draft` and the aliases `new to Botlish` and `coming from
other languages` made `model`, `draft` and `new vector` (which listed the
page third, ahead of a mutable-vector module page) match; they were removed.

Specific queries still resolve to their own pages (also checked on the packed
executable): `METHOD-ELIGIBLE` (`warning.method-eligible`), `nomethod`
(`concept.nomethod`), `import` (`concept.imports`), `bounds proof`
(`proof.list-bounds`), `method syntax` (`concept.method-sugar`), `receiver
first` (`principle.receiver-first`), `tuple` (`principle.name-the-parts`),
`loop placement` and `if placement` (lists led by `rule.loop-placement` and
`rule.if-placement`), `module import` (the same list as before), and the
indices `warnings`, `errors`, `lint`, `principles`, `proofs`, `concepts`.

Tests: `cp-idiomatic-queries`, `cp-idiomatic-does-not-steal`,
`cp-idiomatic-names-no-language` and `cp-idiomatic-shape` (8 to 12 numbered
principles, each ending in `See:` links, under 800 words, in the two
indices, one example, none of the words "always", "never", "hello",
"install", a study ID or the puzzle study). `cp-search-index-pages-and-plurals`
used `best practices` as its index-introduction example and now uses `style
guide`.

## 6. Validation and packaging

* `tclsh9.0 tools/compilerpedia.tcl check`: 668 topics, 514 examples run, 0
  problems (references, aliases, generated files, examples, line width).
* `tests/compilerpedia.test`: 38 of 38; `tests/main-cli.test`: 33 of 33.
* No validation was weakened.
* Packaging: `single/build.sh` built the single executable; run from a
  directory outside the repository, as `botlish`:
  * `botlish -help` prints the overview with the newcomer line;
  * `-help "best practices"`, `-help idiomatic` and `-help "how should I
    write Botlish"` show `principle.idiomatic-botlish`;
  * `-help METHOD-ELIGIBLE` shows `warning.method-eligible`;
  * exit status 0 for a found topic, 1 for an unknown one; no line of the page
    is wider than 80 columns.

  `single/smoke-test.sh` now includes `best practices` among the packed
  `-help` queries, so CI checks the page ships.

## 7. Newcomer audit

A fresh agent with only the packed `botlish` binary (no repository access, no
knowledge of the page) answered the nine questions through `-help` alone.
It started each question with the query it found most natural. Results, as
the agent reported them:

| # | Question | Queries | First useful result | Answered there? |
|---|---|---:|---|---|
| 1 | Where is the preferred coding style? | 2 (overview, `best practices`) | `principle.idiomatic-botlish` | yes |
| 2 | Should `f(x, y)` be `x.f(y)`? | 1 | `concept.method-sugar` | partly: it names receiver-first, but the test ("about the first value") is on the new page |
| 3 | No receiver? | 1 | `concept.nomethod` | yes |
| 4 | Does `import a::b` allow `b::f()`? | 2 | `concept.imports` (the first query listed 27 topics, `error.cycle` first) | partly: "injects no unqualified name", but not `b::f()`; the new page says it outright |
| 5 | Intentional warning finding? | 4 | `lint.policy` | partly: "no source suppression"; the advice is in `principle.investigate-warnings` |
| 6 | Lists as tuples? | 3 | `principle.name-the-parts` (a near match of the first query; `tuple` hits it directly) | yes |
| 7 | Why not a loop/`if` anywhere? | 5 | `concept.loops` (best page, `rule.loop-placement`, second) | partly: the answer is on the second entry |
| 8 | Indexed operation still fallible? | 3 | `proof.list-bounds` (fifth of 7 in the list) | yes |
| 9 | Does a helper share a mutable collection? | 4 | `stdlib.module.mutable_vector`, then `concept.values` | partly: no page says "a helper's mutation is invisible to the caller" |

24 invocations in total, 2.7 per question on average. Four of nine
questions (1, 3, 6, 8) were fully answered by their first useful result and
five (2, 4, 5, 7, 9) partly. The new page answered question 1 and states the
answers to 2 and 4 outright once seen.

### Misses, recorded and left alone

* Natural-language queries often found nothing and printed near matches
  (`intentional warning`, `returning several values`, `loop in expression
  position`, `indexing fallible`). Short alias-like words (`tuple`,
  `nomethod`, `imports`, `suppress warning`) worked best. Search was not
  changed.
* The agent did not reach the new page for questions 5 to 9 by its own
  queries, though its items 5, 7, 8 and 9 state the answers. That is the
  intended relation: the page orients before the program is written, and a
  specific question lands on its specific page. For question 7 the page led
  the near-match list of two queries that matched nothing, ahead of the
  better rule page; the near-match order was not changed.
* `stdlib.module.mutable_vector`'s note is cut at "independent" in the
  agent's view and never states the consequence for a helper call.

## 8. Questions still requiring a probe

These were not answered by one page, so they stay probes instead of growing
the page:

* What exactly does a helper that mutates its parameter's collection change
  for its caller, and what is the idiom for several helpers sharing one
  vector (return it, or a field of a context struct)? Principle 9 states the
  model; `error.mutable-place-receiver` has the advice.
* When a proof does not fire, which recognized form fits a computed index?
  `proof.list-bounds` lists forms; picking one is a case-by-case probe.
* Whether a particular multi-argument function is "about its first argument"
  is the author's judgment (METHOD-ELIGIBLE does not decide it for the
  author).
* Whether a warning is the rule's imprecision or the code's: left to the
  warning pages and the lint-precision principle, not to this page.
* Natural-language phrasings that return only near matches (above).

## 9. Not changed

METHOD-ELIGIBLE and every other warning, rule, diagnostic, proof, library
signature and backend are unchanged. The existence of the page is no evidence
that any warning should be broader or narrower.

## 10. Follow-up: String, UnicodeChar and List[UnicodeChar]

A documentation-only follow-up. `ONE-CHAR-STRING-LITERAL`, the String and
`UnicodeChar` representations, List semantics, lowering and the standard
library are unchanged.

**Where it landed.**

* `concept.strings` (the canonical String/character page) states the
  distinction once.
* `warning.one-char-string-literal` has a new section, TEXT OR CODE POINTS,
  with the semantic reason, the performance reason, one checked example
  (`"ULDR"` against `['U', 'L', 'D', 'R']`) and one sentence on the C
  precedent. It links `concept.strings` instead of repeating the definition.
* `principle.characters-not-strings` gained a three-line "Beyond one
  character" pointer to both.
* `principle.idiomatic-botlish` did not change.

**The distinction, as worded** (`concept.strings`):

```
str                text: an immutable sequence of Unicode scalar values
                   (the native backends store it as UTF-8)
UnicodeChar        one Unicode scalar value (a code point other than a
                   surrogate), a type of its own
List[UnicodeChar]  an addressable, iterable sequence of such values
```

A UnicodeChar is not a user-perceived character or a grapheme cluster, and
not a one-character String. It is "comparable to a Go rune, except that it is
a type of its own"; that sentence is in the body only, with no alias,
keyword or summary mention.

**Where the brief and the compiler differ, the page follows the compiler.**

* The type is `UnicodeChar`, not `Char`; the pages use that name.
* A UnicodeChar is not an integer. UNICODE-CHAR-LITERALS.md defines it as a
  scalar value of a type distinct from Int; the number is observed only
  through `char::scalar_value`. The pages say "scalar value / code point".
* UTF-8 is how the native backends store a String, not a promise of the
  language, which promises a sequence of scalar values. The page says so.

**Performance rationale.** Reading text as code points decodes the UTF-8
(for non-ASCII text, finding character i decodes forward; ASCII text indexes
directly, `native/src/runtime/ops.rs`), and building text from code points
encodes it. A `List[UnicodeChar]` already holds the scalar values, so a
decode, manipulate, encode round trip is avoidable work for data that was a
code-point sequence from the start. The page claims no figure.

**What the warning page says it asks.** The warning is a request to choose
between text and a code-point value, not a preference for `'x'` over `"x"`. A
separator given to an API that works on a code point is usually meant as the
UnicodeChar. A multi-character symbolic sequence is a List only when it is
not conceptually text.

**Search regression.** The 3,317-query corpus was looked up before and
after: identical except two list tails (`character code` and `index string`
each gain a string-related page in third place). Outside the corpus,
`string performance` (no match before) now finds the warning page, through
its new body text; `rune` still has no match, but its near matches now
include `concept.strings`; `c strings` lists one more topic. No alias or
keyword was added. `ONE-CHAR-STRING-LITERAL`, its phrase and its full code
still land on the warning page. `cp-string-char-search` pins this.

**Validation.** `tools/compilerpedia.tcl check`: 668 topics, 515 examples
run (one new), 0 problems. `compilerpedia.test` 39 of 39 on interp and
compile, `main-cli.test` and `one-char-string-literal.test` pass. A rebuilt
single executable, run outside the repository, shows the new sections, no
line over 80 columns, `-help ONE-CHAR-STRING-LITERAL` on the warning page,
and the earlier queries (`best practices`, `idiomatic`, `METHOD-ELIGIBLE`)
unchanged.
