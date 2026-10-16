# 2048 workload: running surprise and research log

Written as the work happens (2026-10-16, starting 19:14 UTC), not
reconstructed afterwards. Each entry: context, expectation, actual,
hypothesis, research (commands/files), failed attempts, explanation,
fix/workaround, classification, what would have shortened discovery.

The research ledger (R-entries) records every investigation step that a
user of the public product surface should arguably not have needed:
doc reads, source searches, probes, HIR/NIR/CLIF dumps.

## Environment setup

* R1. Tcl 9 was not installed in the container. AGENTS.md's install
  recipe worked verbatim (3 .debs). rustc 1.97 preinstalled, new enough.
  Classification: none (environment), AGENTS.md answered immediately.

## Log

### S1 (19:20) No Int-to-String conversion in the stdlib

* Context: planning the demo's board printer (`   2    .    4`).
* Expected: some `str::of_int`/`int::text` or a `show` for Ints.
* Actual: none. `core/native.tcl`'s registrations (grepped) have no
  formatter; `lib/test.bot` carries a private `int_text` built from
  `digit_value` by repeated subtraction, with the comment "Botlish has
  no Int-to-String conversion ... (LANGUAGE-LIBRARY-DEFICIENCIES.md 3
  and 11)".
* Research: docs/README.md section 8 (native table), grep of
  `core::native::register` names, read lib/test.bot. 1 doc read,
  1 source grep, 1 stdlib read.
* Explanation: known, documented gap (LANGUAGE-LIBRARY-DEFICIENCIES.md
  item 11). It is documented only in a deficiency report, not in the
  reference's string section.
* Workaround: the engine needs no text; the demo writes its own
  decimal formatter (a duplicate of test.bot's private one).
* Classification: STDLIB (missing essential general primitive),
  DOCUMENTATION (absence discoverable only through a deficiency report
  or a private helper's comment).
* Shortening: a stdlib `int` (or `str`) module with a decimal
  formatter; a "what is NOT in the stdlib" list in the reference.

### S2 (19:21) There is no integer division

* Context: same read of lib/test.bot (`digit_value`: "by subtraction:
  Botlish has no division").
* Expected: `/` or `div` for Ints (needed by an index layout
  `row = i div 4`).
* Actual: the operator table (docs/README.md section 8, section 17
  "Operators") lists `+ - *`, comparisons, `mod`; no division.
* Consequence for 2048: an index-arithmetic layout (`i div 4`,
  `i mod 4`) is unnatural; a row/column-structured representation is
  favoured by the language, not only by taste. Recorded as a decision
  input (D1).
* Classification: LANGUAGE (missing primitive), DOCUMENTATION (the
  absence is stated nowhere as a deliberate choice; found in a helper's
  comment).

### S3 (19:24) Golden-suite infrastructure assumes every golden test is a port of a Tcl test

* Context: deciding where the 2048 golden suite goes.
* Expected: `tests/golden/2048.bot` picked up like any suite.
* Actual: `tests/golden.test` (with BOTLISH_GOLDEN_SUITES=all) fails a
  suite whose reported tests are not manifest rows;
  `audit/golden/migration/merge.tcl` keys every row on
  `(old_file, old_test)` and reports a row whose Tcl test did not run as
  STALE; `audit/golden/tools/check.tcl` (CI's golden shards) compares
  each golden test with its Tcl original. A workload suite with no Tcl
  original has no row shape.
* Research: read tests/golden/README.md, tests/golden.test (lines
  1-140), audit/golden/migration/merge.tcl (90-272), grep of
  tests/local.tcl and check.tcl. 4 file reads, 2 greps.
* Classification: TEST-FRAMEWORK (tooling, not lib/test.bot),
  DOCUMENTATION (README says "tests/golden/*.bot are ported Tcl tests"
  but not what a new, original suite should do).
* Resolution: see D5 (placement decision).

### S4 (19:27) An application cannot have its own importable module

* Context: the brief wants the engine importable by a demo, a golden
  suite and a benchmark, in "an ordinary non-stdlib library location".
* Expected: a module next to the program (`import twenty48` finding
  `./twenty48.bot`), or a `-lib`/search-path option on main.tcl.
* Actual: `import NAME` maps to exactly `$::core::libraryDir/NAME.bot`
  (surface/modules.tcl `ModulePath`; docs/README.md section 17
  "Modules": "no search path"). main.tcl has no library option;
  tests/golden/run.tcl's `-lib DIR` *replaces* lib/ (for mutated
  copies), it does not add to it. So every importable module is, by
  location, part of the standard library: packed into the single
  executable (single/package.tcl packs lib/), and subject to the
  warning gate's per-module loader.
* Research: docs/README.md section 17, surface/modules.tcl lines 1-60
  and 150-170, main.tcl header, tests/golden/run.tcl. 2 doc reads,
  3 source reads, 2 greps.
* Classification: LANGUAGE (module system: no application root), CLI.
  MAJOR for any multi-file application workload.
* Resolution: see D5.

### S5 (19:33) A descending loop does not prove its own index in range

* Context: `reversed(xs)` for the "right = reverse, left, reverse" plan.
* Expected: `loop i down from n - 1 through 0: list::at(xs, i)` with
  `n = list::length(xs)` needs no handler (the ascending
  `loop i from 0 to list::length(xs)` form is documented as proven).
* Actual: UNHANDLED-ERROR IndexNotFound at the `at`. So are
  `loop i from 0 to n: at(xs, n - 1 - i)`, `down from n to 0: at(xs,
  i - 1)` and the lockstep `x in xs and i from 0 to n` with the
  mirrored index. Only an explicit guard inside the loop
  (`if i < n: at(xs, i) else: 0`) compiles -- a dead else branch.
* Research: 1 probe file, 5 variants (`p2a`..`p2e`), docs/README.md
  section 8 ("STDLIB-NAMESPACES.md lists the rules"),
  LANGUAGE-LIBRARY-DEFICIENCIES.md item 12 ("relates names, not linear
  forms").
* Explanation: the index proof knows the ascending counted form and
  name-level guards only; a descending loop's `i <= n - 1` is a
  linear form.
* Classification: COMPILER-PRECISION (proof hole), STDLIB (no
  `list::reverse`). The diagnostic was accurate and well located but
  says nothing about which shapes *are* provable.
* Workaround: decided later (D2/D3).
  (19:40 addendum) The single executable is the same: single/main.tcl
  runs main.tcl with lib/ inside the zipfs archive, so a single-exe
  user cannot import any module of their own at all. For iteration I
  had to copy lib/ to a scratch directory, link the engine into it and
  run a copy of main.tcl patched to set `::core::libraryDir` (main.tcl
  re-sources core.tcl, which resets the variable, so a wrapper cannot
  set it first). 1 more source read (core/core.tcl, single/main.tcl).

### S6 (19:47) An empty MutableVector literal has no element type; the fix is a typed helper function

* Context: collecting the empty positions of a board (nested collecting
  loops give a List of Lists and there is no concat/flatten, so the
  probe pushes into a MutableVector and reads it out).
* Expected: `found = mutable_vector::from_list([])` then
  `found.push(Position {...})` infers `MutableVector[Position]`.
* Actual: `function result does not prove declared type
  List[probe4::Position] (CORE SEMANTIC TYPE)`, located at the `fn`
  line, without saying what type was inferred instead.
* Hypothesis: element type of `[]` stays unknown/any; pushes do not
  refine it. Remembered lib/test.bot's `fn no_texts() ->
  MutableVector[str]: mutable_vector::from_list([])`: a function whose
  only purpose is the annotation. Copying that idiom fixed it (1 retry).
* Research: 1 probe, recall of lib/test.bot.
* Classification: LANGUAGE (no local type annotation on a binding:
  `found: MutableVector[Position] = ...` does not exist, so a typed
  helper is the only spelling), DIAGNOSTIC (does not show the inferred
  type, unlike the struct-field diagnostic in S7). MODERATE.
* Shortening: either binding annotations, or the diagnostic naming the
  inferred type (`... inferred List[any] because the vector's element
  type is unknown`).

### S7 (19:49) A loop bounded by `list::length(rows)` cannot prove a Coordinate; a 4x4 size the types cannot carry

* Context: same probe, `loop row in b.rows and r from 0 to
  list::length(b.rows): ... Position {row: r, ...}`.
* Actual: `field "row" of struct probe4::Position cannot be proven to
  satisfy its declared type int[probe4::Coordinate] (value type: int,
  facts: [0, 4611686018427387902])`. Excellent diagnostic: the facts
  say exactly what was known.
* Explanation: a List's length is not part of its type; inside the
  opaque Board the invariant "4 rows of 4" is kept by construction, but
  no static fact carries it. Lockstep with `r from 0 to 4` would be
  LOCKSTEP-UNPROVEN for the same reason.
* Workaround: iterate `r from 0 to 4` and read `rows.get(r, [])`:
  every read of a fixed-size aggregate either handles IndexNotFound or
  names a default that by construction never happens.
* Classification: LANGUAGE (no fixed-length List type),
  COMPILER-PRECISION (no length fact through a struct field).
  MODERATE; recurring for any grid workload.

### P1 (19:50) Pleasant: domain-typed struct fields from comparisons and counted loops

`type Coordinate = Int in 0..3` on `Position`'s fields is proven from
`loop r from 0 to 4` directly, and from `if r >= 0 and r <= 3 and c >=
0 and c <= 3:` through `and` (contrary to LANGUAGE-LIBRARY-DEFICIENCIES.md
item 8 and docs/README.md section 17's "Known limitations", which both
say `and` adds no refinements: those passages look stale). An
out-of-range Position is then unrepresentable without a check.
Opaque struct + module function + method sugar (`b.rows()`) worked first
try on all four backends.

## Decision points (recorded when made)

### D1 (19:52) Board = opaque struct over four rows (List[List[int]])

* Alternatives: List[int] of 16 (index 4r+c); struct of four row
  structs; List[List[int]] rows; MutableArray.
* Chosen: `opaque struct Board: rows: List[List[int]]`.
* Why: (a) no integer division (S2), so a flat 16-cell layout cannot
  recover row/column from an index, and flattening rows back needs a
  builder (no concat); (b) rows make "a line" a first-class List, which
  is what the central algorithm consumes; (c) `opaque` gives the module
  sole construction authority, so the 4x4/valid-tile invariant is
  validated once at the API boundary (`board(rows)`) and kept by
  construction afterwards; (d) `test::equal` can print Lists of Ints
  but not structs ("a value with no text form"), so tests compare
  `rows(board)`.
* Botlish influence: strong (division, concat, describe).

### D2 (19:53) Empty cell = 0

* Alternatives: an enum `Cell` (Empty / Tile) -- impossible, enums are
  payload-free; a struct {occupied, value}; 0.
* Chosen: 0, named `empty` at module level. `list::get(xs, i, empty)`
  then reads "the cell at i, or empty past the end", which makes
  padding a line one loop (`loop i from 0 to size: tiles.get(i,
  empty)`).
* Botlish influence: payload-free enums rule out the sum type; `get`'s
  default makes 0 pleasant.

### D3 (19:54) Line algorithm: filter loop, recursive merge, padding loop

* compact = a filtering collecting loop (`continue` on empty).
* merge = a self-recursive nested function carrying the position and the
  result so far (no loop can carry state; S8 below).
* pad = a counted loop over `get` with the `empty` default.

### D4 (19:55) Directions: view the board from the direction

* `lines_toward(rows, d)`: left = rows, right = each row reversed, up =
  transpose, down = transpose then reverse; `rows_from(lines, d)` is
  the inverse. A move is "view, slide every line, view back". Two
  involutions (reverse, transpose) instead of four algorithms or an
  index formula.

### D6 (19:56) Spawn: Position of Coordinates, SpawnTile enum, one runtime error

* Out-of-range position and invalid tile value are made
  unrepresentable statically (Coordinate domain; `enum SpawnTile: Two,
  Four`); only "occupied" is a run-time condition: `error
  CellOccupied`. Not enforced: "only after a changed move" (a caller
  rule; the engine has no history).

### S8 (20:02) A named program-level Int constant is not a fact inside the functions that read it

* Context: engine v1, `size = 4` at module level, `empty_positions`:
  `loop r from 0 to size: ... Position {row: r, ...}`.
* Expected: `size` is an immutable binding of the literal 4, so the
  loop domain is 0..3, exactly as with a literal `4` (which probe 4
  proved).
* Actual: `field "row" ... cannot be proven to satisfy its declared
  type int[game2048::Coordinate] (value type: int, facts: [0, +∞])`.
  Same in an entry program (not module specific): `size = 4` then
  `fn coords() -> List[Coordinate]: loop r from 0 to size: r` is
  rejected.
* Hypothesis 1 (wrong): module bindings are opaque to the analyses.
  Disproved by the entry-program variant.
* Hypothesis 2 (right): the range analysis has no fact for a binding
  outside the analysed function's own context. A Tcl probe
  (scratch q1.tcl) showed the binding is an ordinary `local` binding
  and `hir::exact::IntOf` *does* answer 4 for the ref; hir/range.tcl's
  `Expr` `ref` case only reads `ctx bindings` (and capture Ranges
  transported from creation sites, M9), never the exact-value fact.
* Research: 2 probes, 1 Tcl probe against the HIR, read
  hir/exactvalue.tcl (header, `Eval`), hir/range.tcl `Expr` (lines
  906-1000), grep of docs for capture facts (CLOSED-CALL-FACTS.md,
  COMPREHENSIVE-GENERATED-CODE-AUDIT.md). 3 wrong turns: none fatal;
  ~15 minutes.
* Classification: COMPILER-PRECISION. MODERATE: it forces a choice
  between a named constant and a proof. Compiler source was needed to
  understand it; the diagnostic's "facts: [0, +∞]" was the clue that
  the name had lost its value.
* Workaround: the engine spells the size as the literal 4 in the loops
  (and documents the board as 4x4 once). Candidate for a small general
  fix (range `ref` case consulting `hir::exact::IntOf`), evaluated
  later (F1).
* CLI wish: "what Range does the compiler know for `size` at line N,
  and why?"

### S9 (20:05) Lockstep over a field projection is unproven; the message says "(expression)"

* Context: `spawn`: `loop row in game.board.rows and r from 0 to
  list::length(game.board.rows):`.
* Expected: the same lockstep idiom as `loop x in xs and i from 0 to
  list::length(xs)`.
* Actual: `lockstep loop requires equal iteration counts; could not
  prove length((expression)) == length((expression)) (clause 1 vs
  clause 2) (CORE SEMANTIC LOCKSTEP-UNPROVEN)`.
* Explanation (guessed from COLLECTING-LOOPS.md's "calls are never
  assumed equal", confirmed by the fix): two projections of the same
  immutable path are two atoms; only a *name* is one. Binding `rows =
  game.board.rows` first fixed it (1 retry, 0 searches).
* Classification: COMPILER-PRECISION (an immutable field path could be
  an atom), DIAGNOSTIC ("(expression)" hides which expressions; the
  fix -- "bind it to a name" -- is not suggested). MINOR.

### S10 (20:14) Two warnings on engine v1, both answered in the code

* `METHOD-ELIGIBLE` on `from(0, Slide {cells: [], score: 0})`, the
  first call of the recursive merge helper (the sugared spelling would
  be `0.from(Slide {...})`). Its other calls (`from(i + 2, ...)`) are
  silent because `i + 2` is not a receiver as written. Answer: `nomethod
  fn from` with a one-line reason (the first argument is a position).
  Read WARNINGS-METHOD-ELIGIBLE.md (1 doc) to confirm the eligibility
  rule and that `nomethod` is the declared response.
* `SAME-RETURN-VALUE` on the board validator's three `return false`
  exits. Answer: the validator became three one-line predicates over
  `list::all?` (`cell?`, `board_row?`, `board_rows?`) -- clearer than
  the loop it replaced. Read WARNINGS-SAME-RETURN.md's outcome (1 doc).
* Classification: DIAGNOSTIC (both accurate, well located, with notes
  at the other exits). The SAME-RETURN-VALUE rewrite improved the code;
  the METHOD-ELIGIBLE one added a modifier to a local helper (MINOR
  ceremony: a recursive helper whose first argument is a counter is a
  common shape).

### P2 (20:15) Pleasant: the first full engine was correct on the first run

Seven merge-once cases, all four directions, a double move, a spawn,
game over on a full checkerboard, empty positions: every value equal to
a hand calculation, identical on interp, compile, cranelift and
cranelift-generic. Value equality made `changed` one expression
(`moved != rows`), and `list::get`'s default made padding and reversal
total without a single handler.

### D5 (20:22) Placement: everything under examples/games/2048/, run through a private library directory

Forced by S3 and S4. The engine module, the demo, the golden suite and
the benchmark program live together in examples/games/2048/; a small
driver there (`run.tcl`) builds a private library directory (a
`file tempdir` copy of lib/ plus game2048.bot, the same composition
tests/helpers.tcl's `withPrivateLibrary` uses), points
`::core::libraryDir` at it and compiles/runs with the golden runner's
procs. tests/workload-2048.test runs the suite, the demo and a small
benchmark through it in the ordinary Tcl suite (so CI and
tests/local.tcl see it). Rejected: lib/game2048.bot (it would become
stdlib by location, ship inside the single executable and be visible to
the paired run's agent); tests/golden/2048.bot (needs Tcl originals for
the manifest); one file with the engine copied into each consumer.

### S11 (20:24) The warning gate cannot cover a program that imports a non-lib module

* audit/refactor/tools/sweep.tcl enumerates a fixed list of directories
  (examples/{stdlib,surface,...}, bench, lib) and compiles each program
  against lib/. A bench/2048.bot importing game2048 would fail the gate
  with a missing module; examples/games/ is not enumerated at all.
* Consequence: the 2048 programs are outside the gate; the workload
  test compiles each of them with `-warnings error` itself.
* Classification: TEST-FRAMEWORK/CLI (tooling follows from S4). MINOR.

### S12 (20:52) A local List named `rows` makes `board.rows()` ambiguous

* Context: first compile of the golden suite. Property tests loop
  `loop rows in samples():` and call `m.game.board.rows()`
  (game2048::rows through method sugar).
* Expected: `rows` the loop variable is a List; it cannot be the
  callee of `x.rows()`, so the module function is the one candidate.
* Actual: `method-style call "rows" is ambiguous: more than one visible
  function accepts the receiver (game2048::rows, rows); there is no
  precedence between them: call the one you mean explicitly, e.g.
  game2048::rows(receiver, ...) (CORE SEMANTIC AMBIGUOUS-METHOD-CALL)`.
  Hypothesis "a *declared* List parameter `rows` is not a candidate"
  (the helper `fn moved(rows: List[List[int]], ...)` was not reported)
  was WRONG: after renaming the loop variables, the next compile
  reported the parameter too. The first error reported is not the
  first in source order (line 490 came before line 37), so the absence
  of an error earlier in the file meant nothing.
* Research: read METHOD-SUGAR.md lines 120-200 (1 doc): candidates are
  visible names, and any binding of the name -- whatever its type,
  even a declared `List[List[int]]` -- is a candidate.
* Fix: rename the locals and the parameter (`sample`, `before`,
  `cells`). 2 retries.
* Classification: LANGUAGE (method sugar is name-based, so a local that
  shares an imported function's short name poisons sugar to it; Botlish
  programs naturally name a value after the accessor that produced it:
  `rows = board.rows()`), DIAGNOSTIC (good: names both candidates and
  the explicit spelling; does not say that a non-function binding
  counts, which is the surprising part). Also DIAGNOSTIC: only one
  semantic error per compile, and not the earliest. MODERATE, likely
  recurring.

### S13 (20:50) A bare `List` result type is rejected; the raw kind is `list`

`fn moved(...) -> List:` (a heterogeneous [rows, score, changed]) is
`unknown or invalid result type List: type constructor "List" requires
1 type argument(s) (e.g. List[...])`. The heterogeneous List's type is
the lowercase raw kind `list`, known from AGENTS.md's
FIXED-ARITY-LIST-RETURN paragraph ("`-> list`, `-> List[T]`"), not from
the diagnostic, which suggests only `List[...]`. DIAGNOSTIC (could
mention `list`), DOCUMENTATION. MINOR. 1 retry.

### S14 (21:20) Mutation found a weak test of mine

* `game-over-ignores-horizontal` survived every game-over test and was
  killed only by the long scenario: the board of
  `2048-not-over-with-horizontal-merge` had a vertical pair too (column
  2 read 2, 4, 4, 8). Fixed the board (row 2 = 2, 8, 8, 4: one
  horizontal pair, no vertical one).
* Also: the mutant `changed-always-true` did not apply (its text was
  indented in mutants.txt); the harness reported NOT APPLIED rather
  than a false kill.
* Classification: USER-ERROR (test design), found by the cheap
  mutation harness (20 mutants, 26 s wall on 4 cores, compile backend).
* Spec note: the brief's suggested property "moving left twice: second
  move does not change the result" is false in 2048 ([2,2,2,2] -> left
  [4,4,0,0] -> left [8,0,0,0]). The suite pins the counterexample
  (`2048-move-again-merges-produced-tiles`) and tests the true
  property instead: a move that scored nothing is idempotent.

### S15 (21:42) A program's output is discarded under `-backend cranelift`; the Tcl backends cannot print at all

* Context: first run of the demo (io::print_line under `with context
  linux::io::create()`).
* Expected: the board printed, then the value.
* Actual: only `unit`. The repository's own examples/io/hello.bot does
  the same under `main.tcl -backend cranelift` (`value: unit`, no
  "Hello, world!"); on interp it is `CORE SEMANTIC NATIVE-ONLY`
  (abi::x86_64::from_bytes).
* Research: tried hello.bot on two backends (2 runs); read
  native/native.tcl `native::Driver`/`Outcome` (lines 150-240): the JIT
  driver runs botlish-native with stdout+stderr in one pipe, reads it,
  keeps the last `value`/`error` protocol line and drops every other
  line. 1 source read.
* Explanation: by design of the driver protocol; the README only shows
  hello as an executable. The only io::IO implementation is LinuxIO
  (raw syscalls), so no Tcl backend can print.
* Workaround: `run.tcl -hirx demo.hirx demo.bot`, then `main.tcl
  -emit-native-executable demo.hirx` and run the executable (works:
  316 moves in 10 ms).
* Classification: CLI (MAJOR: silent loss of output), STDLIB (no
  portable output on the reference backends), DOCUMENTATION.
  Must-fix candidate before the paired run: a black-box agent will run
  a printing program with `-backend cranelift` and see nothing.

### S16 (21:43) Every program that imports io gets two warnings about the stdlib's own source

`/tmp/tcl_nbTpQP/io.bot:59:31: warning: the String literal "\n" is one
character long ... (ONE-CHAR-STRING-LITERAL)` (twice) on every compile of
the demo with warnings on. They are manifested in the warning gate
(AGENTS.md: "Library modules' own findings print for every program that
loads them"), but a user cannot act on them and they appear in their
build output (here with a temporary path, because of D5).
DIAGNOSTIC/STDLIB. MODERATE (noise that trains users to ignore warnings).

### S17 (21:44) METHOD-ELIGIBLE fires 12 times on the demo's ordinary calls

`fits(n, p)`, `digits(n, next)`, `show(title, board)`, `play(start, 3)`,
`spawned(game, seed, moves)`, ... Each is accurate. The engine (written
with method syntax by imitation of lib/) got one; the demo, written in
functional style first, got twelve. Converting is mechanical except where
the first parameter is not a natural receiver (`show(title, board)`:
swapped the parameters to `board.show(title)`). DIAGNOSTIC (accurate,
but no fixit and one line per call). MINOR; the language's preference is
documented (METHOD-SUGAR.md) but a newcomer learns it from the warnings.

### P3 (22:05) Pleasant: three independent agreements

The golden suite's long scenario equals audit/2048/oracle.py (a flat,
index-mapped, imperative Python implementation): board, score 796, 91
moves, game over. The benchmark's 100,000-move checksum (1238344689)
equals an imperative Python transcription of bench.bot driving the same
oracle. All four backends agree on every suite report and checksum.

### S18 (22:10) The obvious immutable engine allocates ~168 objects (7.7 KB) per move natively, and is ~3x slower than CPython

* Measured: bench/2048.tcl, 100,000 moves: cranelift 13.29 us/move,
  cranelift-generic 13.17 us/move (specialization buys nothing here),
  168.9 allocations and 7.7 KB per move, 742 GC cycles. The same
  workload in CPython (flat list, imperative, same rules and
  generator): 4.55 us/move. compile backend 2.16 ms/move, interp 28.4
  ms/move.
* Allocation sites (native::allocationReport ... sites, scratch
  alloc.tcl; 1000 moves):
  1. game2048.bot:213 `Position {row: r, column: c}` in
     empty_positions: one heap struct per *cell* (15/move), built
     before the emptiness test and materialized because one branch
     pushes it.
  2. game2048.bot:203 `board.rows.get(at.row, [])`: the `[]` default is
     a fresh `listnew` on every call of `cell` (16/move) -- the constant
     List literal rebuilt per call (LANGUAGE-LIBRARY-DEFICIENCIES.md
     item 6), here for a default that is never used.
  3. game2048.bot:101/102 the merge helper's `Slide` accumulator: a
     `structnew` plus a `listappend` copy per merge step (22/move); the
     struct is not scalarized across the self tail call.
  4. every collecting loop: one result List (`construct`), 2 objects.
* NIR (main.tcl -emit-nir of a .hirx, both modes):
  * `empty` (module constant 0) is a `staticget` and a boxed `ieq`
    against it, never a raw compare with 0 (S8's lost fact, now as code
    quality).
  * `list::get` is an out-of-line call with a pushed error exit per
    read (`pusherrorexit`/`declarederroreq`), never inlined.
  * empty_positions' inner `loop c from 0 to 4:` is the body value of a
    loop in statement position, so its List is never read, yet it is
    built (`construct list plan` / `construct list flat`, 4 per call):
    only the outermost discarded loop is recognized as discarded.
  * `loop at in found: at` (MutableVector to List) is an `mvtolist`
    copy followed by a second element-by-element List build.
  * the merge helper's instance key is `int, any`: its declared
    `done: Slide` is not part of the key.
* Classification: COMPILER-PERFORMANCE (MAJOR: not a pathology in
  complexity, but the natural program pays ~3x CPython; the
  allocation-free board the brief hoped for does not happen),
  COMPILER-PRECISION (the discarded nested loop; the never-used
  default). Research: 1 allocation report, 2 NIR dumps, ~10 minutes.
* CLI wish: "why does this expression allocate?" and "is this loop's
  List discarded?" -- the site report gives a line, not a reason.

### S19 (22:31) COMPILER-CORRECTNESS: the demo crashes under GC stress on specialized native

* Context: pinning the demo executable's output for the workload test;
  ran it once more under `BOTLISH_NATIVE_GC_STRESS=1`, as
  tests/native-executable.test's aotParity does.
* Expected: identical output.
* Actual: `Segmentation fault` (exit 139) after the third move's
  board. Same with the stub linker, same under the JIT (`-backend
  cranelift`: `(NATIVE BUG)`); cranelift-generic runs to the end; the
  non-printing benchmark executable is fine; without GC stress all are
  fine.
* Classification: COMPILER-CORRECTNESS (GC root liveness or a stale
  pointer in specialized native code). BLOCKER: fix before proceeding.
