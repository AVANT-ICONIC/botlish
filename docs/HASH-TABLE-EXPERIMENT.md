# Hash tables, set membership, and the compiler/runtime division of labor

This milestone is an experiment, not a library. It asks which parts of a
hash table, a set or a membership test ordinary Botlish expresses
efficiently, which missing compiler proofs or optimizations make otherwise
good Botlish slow, and which operations, if any, justify privileged runtime
support. It ships no Set, Map or membership API, freezes no spelling, and
graduates none of its tables into `stdlib/`.

The detailed catalogue of what the experiment found is
[HASH-TABLE-COMPILER-PRESSURE.md](HASH-TABLE-COMPILER-PRESSURE.md). Its IDs
(VS-, CP-, CG-, RO-, CO-, RT-, AR-, BUG-) are used throughout this report.
Everything else is under `audit/hash-table/`:

| path | what |
|---|---|
| `SPEC.md` | the shared specification: hash, capacities, algorithms, interface, keys, workloads, value-semantics rules |
| `impl/*.bot` | the Botlish tables (application modules behind one interface) |
| `drivers/*.bot` | the benchmark, trace, hash-check and mixed-workload programs |
| `reference/` | the Rust reference: the same algorithms, `std::HashMap`, probe statistics, hash costs, insert latency |
| `tools/model.py` | the independent oracle and trace generator |
| `tools/fuzz.tcl`, `tools/mutate.tcl`, `tools/mutants*.txt`, `tools/check-hash.tcl` | the fuzzer, the mutation harness, the hash cross-check |
| `tools/bench.tcl`, `tools/ladder.tcl`, `tools/mixed.tcl`, `tools/run-all.tcl`, `tools/plan*.sh`, `tools/summarize.tcl` | timings, the measurement plans, and the tables below |
| `tools/instructions.tcl`, `tools/profile.tcl` | instructions per operation and per function (callgrind) |
| `tools/copies.tcl`, `tools/attribution.tcl`, `tools/allocs.tcl`, `tools/memory.tcl`, `tools/nirstats.tcl` | copies, allocation, memory, generated code |
| `tools/membership.tcl` | the constant-membership generator and its measurements |
| `results/` | the measured data the tables below are made from (its README lists every file) |
| `patches/probe-primitive.patch` | the probe primitive (RT-1), measured and not proposed for main |

## Executive result

**The table belongs in Botlish. The compiler should make Botlish fast,
not the runtime. Constant membership is a separate problem from mutable
tables.** In the brief's terms, the evidence supports outcomes B and E,
not C or D.

* **The best mutable table Botlish can express is open addressing with
  linear probing, stored hashes and backward-shift deletion,** at load
  7/10 with doubling growth.
  * Written as ordinary modular Botlish (`lpa`, 116 lines), it runs at:
    * 2.4-5.3 times the same algorithm in Rust on the mixed workloads;
    * 4.2-4.4 times on hits, 1.7-2.4 times on misses;
    * 4.8-6.1 times on Int builds.

    With its helpers inlined by hand (`lpmono`) it runs at 2.1-4.3, 3.8-4.0,
    1.3-2.7 and 4.1-4.8 times. These ratios hold after five general
    compiler prototypes, which cut
    `lpa`'s hits by 27-43 %, its misses by 16-20 % and its builds by
    30-49 %.
  * The compact dict is the alternative when iteration order must be
    insertion order. Robin Hood is the alternative when the miss tail
    must be bounded.
* **The largest effect was value semantics, not speed.**
  * Written naturally, a memoized recursion copied its whole table on
    every call: 1,199 times the Rust reference.
  * Two general precision rules in the copy elaboration (per-path last
    use, literal demand) made the same source copy-free and 290 times
    faster.
  * Two more (VS-3, VS-7) are needed before the most natural first draft
    of a table copies nothing.
* **What remains is general compiler work.** None of it is the
  algorithm, and none of it is specific to tables:
  * inlining and CSE of small helpers;
  * typed slot equality and hashing;
  * field-wise struct hashing;
  * the runtime hash's generic dispatch.

  Bounds proofs, though now sound and general, change 2 % of a lookup.
* **No runtime primitive is justified.**
  * A probe primitive saved 2-41 % on the baseline compiler, but 0-10 %
    against proof-shaped Botlish after the compiler work.
  * It would fix one probe discipline into the runtime.
  * The one runtime gap left is semantic: a keyed hash, so that a table
    can resist chosen keys. That is a language decision.
* **Constant membership should be a compiler representation choice:**
  * a comparison tree for Ints (8-12 ns at any size);
  * a character trie for Strings (6-19 ns);
  * a bitset for dense domains and enums;
  * a hash-and-displace perfect hash only where a trie's code is too
    large.

  Against an equality chain or `std::immutable_set::contains` (1-5 µs at 512
  elements), that is 100 times faster. Two compile-cost limits (CO-7,
  CO-8) must be fixed first. Hashing is the wrong tool for constant Ints
  and enums.
* **The project is not ready for a public Set/Map API.** The missing
  pieces are mostly decisions:
  * VS-3 and VS-7 (no copies in natural code);
  * typed slots for generic containers (CO-3);
  * an iteration-order decision;
  * a decision on seeding the hash.
* **The experiment also found and fixed correctness bugs.**
  * Two older bugs: a miscompilation (BUG-1) and a front-end abort
    (BUG-2).
  * An adversarial review of the merged prototypes made fifteen
    findings, ten distinct soundness bugs:
    * five that the prototypes caused, or reached through an older defect;
    * five older ones: four in value semantics, one in the bounds proofs
      (AR-3: a vector's length keyed as if immutable).
  * Fixing them uncovered two more older ones.
  * All twelve are fixed, each with tests and mutants, and checked by
    independent verifiers ("Correctness").
  * One fix is a language change: a mutating collection operation can no
    longer be used as a function value.

## Contents

* [Executive result](#executive-result)
* [Algorithms tested](#algorithms-tested)
* [Correctness](#correctness)
* [Performance](#performance)
* [Algorithm comparison: what wins, and where](#algorithm-comparison-what-wins-and-where)
* [Abstraction-cost experiments](#abstraction-cost-experiments)
* [Compiler deficiencies](#compiler-deficiencies)
* [Compiler experiments](#compiler-experiments)
* [What remains: the merged tree against Rust](#what-remains-the-merged-tree-against-rust)
* [Runtime experiments](#runtime-experiments)
* [Constant membership](#constant-membership)
* [Code size and construction cost of constant membership](#code-size-and-construction-cost-of-constant-membership)
* [Theorem and measurement](#theorem-and-measurement)
* [Recommended division of labor](#recommended-division-of-labor)
* [Recommended future semantic APIs](#recommended-future-semantic-apis)
* [What this means for collections, one question at a time](#what-this-means-for-collections-one-question-at-a-time)
* [What not to implement yet](#what-not-to-implement-yet)
* [The twelve questions](#the-twelve-questions)
* [Outcome](#outcome)

## Algorithms tested

Every Botlish table is an application module in `audit/hash-table/impl/`
behind one interface (SPEC.md section 4: `fresh`, `put`, `get`, `has?`,
`size`, `drop`, `slots`, `probes`; every module also exports
`from_lists`), so one driver measures any of them. Keys and values are
untyped, so one source serves Int, String and struct keys, specialized
per call site. The exceptions are `lpint` and `lpstr`, which type them.
"Code" counts non-blank, non-comment lines.

| table | representation | code | role |
|---|---|---:|---|
| `listmap` | two Lists (keys, values), linear scan, append | 56 | the linear baseline |
| `chain0` | the 15-puzzle study's visited set: a fixed-capacity `MutableArray[List[Entry]]`, `hash(k).mod(capacity)`, a collecting-loop bucket scan, never grows | 68 | the existing bucketed prototype |
| `ht0` | examples/stdlib/hashtable.bot unchanged: linear probing with tombstones, controls/keys/values/counts arrays, 2/3 load | 157 | the existing open-addressed prototype |
| `chain` | separate chaining: `MutableArray[List[Entry]]` buckets of `{hash, key, value}`, load 1/1, doubling | 116 | chaining done the experiment's way |
| `lp` | linear probing, stored hashes (-1 empty), backward-shift deletion; modular; the count an Int field (the struct rebuilt per insert); local walks | 118 | organization A as one would first write it |
| `lpc` | `lp` with the arrays in a sub-struct and the count read first | 123 | the "correct rebuild" idiom |
| `lpa` | `lp`'s algorithm, the count in a one-slot `MutableArray[int]` (no rebuild), top-level walks | 116 | **the main modular open-addressed table** (organization A) |
| `lpmono` | `lpa` with every helper inlined by hand, the capacity hoisted, the lookup fused | 122 | organization B |
| `lpfact` | `lpa` keeping its helpers except the two that cost a call per probe step | 118 | organization C |
| `lpmask` | `lpa` with every index reduced by its array at the access (`bit_and(i, a.capacity() - 1)`) | 134 | the proof-shaped source (CP-1..CP-3) |
| `lpint`, `lpstr` | `lpa` with typed key and value arrays | 116 | typed against generic |
| `rh` | Robin Hood over `lpa`'s arrays, backward-shift deletion | 126 | the tail-latency algorithm |
| `cd` | compact dict: entries dense in three MutableVectors, an index `MutableArray[int]` of entry numbers; no removal | 89 | the insertion-ordered layout |
| `sorted` | entries sorted by hash, binary search; O(n log n) bulk construction, O(n) insert | 192 | the immutable sorted-sequence family |
| `lpp` | `lpa` with its probe walk delegated to `std::mutable_array::probe_linear` | 110 | the runtime-primitive experiment (compiles only with `patches/probe-primitive.patch` applied) |

Quadratic probing was not implemented. Linear probing and Robin Hood over
the same arrays already compare two probe disciplines, and the measured
costs below are dominated by per-step overheads that a different step
function would not change.

The Rust reference (`reference/src/main.rs`, 1,310 lines) implements
`listmap`, `chain`, `lp` and `rh` with the same algorithms, the same
capacities and the same hash (Botlish's FNV-1a over a tag and the decimal
text, reimplemented exactly). Its probe sequences are therefore the Botlish
tables' slot for slot. It also has `std` (`std::HashMap` with SipHash) and
`stdb` (`std::HashMap` with Botlish's hash passed through), its own
statistics, and the single-insert latency spike.

## Correctness

No performance number in this report comes from a table that has not
passed all of the checks below.

### The oracle

`tools/model.py` generates random operation traces: puts, gets, membership
tests, removals, and size and capacity queries. The expected results come
from a Python dict. The oracle shares nothing with the tables except the
interface's meaning (SPEC.md section 4); it never hashes. The trace
profiles stress the places where tables break:

| profile | what it exercises |
|---|---|
| `small` | a handful of keys: replacements, re-insertion after removal, the empty table |
| `grow` | growth across several thresholds |
| `collide` | keys forced onto one home slot at every capacity up to 64: long runs, wraparound, backward shift across the end |
| `edge` | 0, negatives, the 2^61..2^64 boundaries, 30-digit BigInts, non-ASCII and astral Strings, Strings that differ only in case or a combining mark |
| `large` | 1,000 or 3,000 keys and about 3 operations per key: long sequences, growth to thousands of slots, long removal histories |

30 % of traces start presized (`fresh(N)`). An implementation's `#
policy:` header line lets the oracle predict every `slots(t)` too, so a
capacity-policy bug is an observable wrong answer, not a slow table.

The first four profiles keep traces small: at most 200 keys and 620
operations. The `large` profile (up to about 9,000 operations) runs on
the native backends; on the Tcl interpreter one such trace takes minutes.
The 1/2 and 17/20 load-policy variants timed in "Resize policy" are
fuzzed as well (`fuzz.tcl -policy`: the policy header and the load
functions rewritten), on every profile and backend. At benchmark sizes
the evidence is the checksums: at 4,096 and 16,384 keys every table
timed there returns the same hit, miss, member and replace checksum
(`results/sizes-combo.tsv`), and every policy variant the same as the
default (`results/lookups/policy-combo.tsv`).

`tools/check-hash.tcl` checks the three implementations of Botlish's hash
the experiment relies on:
* the language's own, compiled on all four backends;
* the oracle's reimplementation, which makes the colliding keys;
* the Rust reference's, which drives its tables.

They agree for every key kind.

### The fuzzer and backend agreement

`tools/fuzz.tcl` runs every trace on interp, compile, cranelift and
cranelift-generic. Any disagreement with the oracle, or between backends,
is a failure. Per implementation and seed, each of three key kinds runs
each of the four small profiles on four backends, which is 48 checks.

| tree | implementations | checks | failures |
|---|---|---:|---:|
| baseline | every implementation, 3 seeds each (during development) | 144 per implementation | 0 |
| merged prototypes | `lpa lpmono lpint lpstr rh chain cd sorted listmap chain0 lpc lpfact lp`, 2 seeds | 1,116 | 0 |
| merged prototypes | `lpmask` (every access proven), 3 seeds | 144 | 0 |
| merged + probe primitive | `lpp`, 2 seeds | 96 | 0 |
| merged, after the review fixes | every implementation, 2 seeds (`ht0` on three backends) | 1,288 | 0 |
| merged, after the review fixes | `large` profile, every implementation, 2 seeds, cranelift and cranelift-generic (`ht0` on cranelift) | 158 | 0 |
| merged, after the review fixes | `lpa` and `rh` at load 1/2 and at 17/20, all five profiles, 2 seeds | 480 | 0 |

`ht0`, the unmodified examples/stdlib/hashtable.bot, cannot be lowered by
cranelift-generic at all (CG-3). That is a finding, not a skipped test: it
runs on the other three backends.

### Mutants

`tools/mutate.tcl` applies each mutant to a private copy of its
implementation and fuzzes it. A mutant is killed when any check fails.
A mutant that makes a table probe forever (one that never grows, or never
empties a slot) is killed by a timeout and reported as such. Every mutant
must apply exactly once, and the unmutated baseline must pass first.

| file | mutants | killed |
|---|---:|---:|
| `mutants.txt` (`lp` 12, `lpa` 5, `lpmono` 4, `lpmask` 4, `chain0` 4, `listmap` 3, `lpc` 2, `ht0` 2) | 36 | 36 (3 by the timeout) |
| `mutants-rh.txt` | 22 | 22 |
| `mutants-chain.txt` | 24 | 24 |
| `mutants-cd.txt` | 20 | 20 |
| `mutants-sorted.txt` | 16 | 16 |
| **all** | **118** | **118** |

The mutants are the brief's list made concrete:
* a wrong home or bucket index;
* a collision not checked (the hash compared, the key not);
* a duplicate insert creating a second entry;
* growth losing an entry, the count, or the last slot;
* broken wraparound;
* a probe that ends too early;
* a load threshold off by one;
* a presize that is ignored;
* backward-shift deletion with the wrong interval, or with no shift;
* Robin Hood's displacement comparison inverted;
* the compact dict's index not updated on growth;
* the sorted table's binary search off by one.

Two mutants that only hung were replaced by ones that answer wrongly, and
one equivalent mutant (`lp-grow-count-lost`: the rebuild recomputed the
count) was replaced.

### The compiler and runtime prototypes

Each prototype carries its own tests, fuzzer and mutants ("Compiler
experiments" below). The merged tree passes:
* the whole local suite (`tests/local.tcl`): every Tcl test file on interp
  and compile (6,023 and 6,018 passed, 0 failed) and all 94 golden suites
  on all four backends (4,739 tests on interp, 0 failed);
* the native Rust unit tests (246 library, 44 binary);
* CI's macOS arm64 tier.

* Linux CI, dispatched on the branch:
  * `tests` (x86-64) and `static-decisions` (the batched scheduler
    against the sequential one, every golden suite) at `19bd2ff`, both
    green;
  * `tests-arm64` at `93806f4`, green. Its first run, at `19bd2ff`, found
    a GC-rooting bug in one of CG-2's Rust unit tests. The test held a
    BigInt operand only in a Rust local while allocating the next one,
    and arm64's allocator reused the slot. `93806f4` roots the operands.
    The runtime code was right.

### The adversarial review, and what it found

After the merge, a review workflow tried to break each prototype.
* **Reviewers.** There was one reviewer per area (value semantics, bounds
  proofs, `mod` lowering, inline arrays, the hash) and one for their
  interactions in table-shaped code.
* **Method.** Each wrote at least 15 adversarial programs, derived their
  values by hand, and ran them on all four backends and on the baseline.
* **Verification.** An independent verifier reproduced every finding and
  decided whether it was real and whether the prototypes caused it. All
  15 findings were reproduced, and all were real.

| area | findings | caused by the prototypes | older than them |
|---|---:|---:|---:|
| bounds proofs | 5 | 4 | 1 (the counted-loop form; same root) |
| value semantics | 5 | 1 | 4 |
| interactions | 2 | 1 (the value-semantics one again) | 1 (`break`/`continue`) |
| `mod` lowering | 3 | 3 (the lowering trusts an older unsound fact) | -- |
| inline arrays | 0 | | |
| the hash | 0 | | |

**The bugs, by root cause:**

1. **A MutableVector's length was keyed as if it were immutable**
   (hir/cardinality.tcl's size forms).
   * Two snapshots of one vector taken around a push got one size atom,
     so an index proven against one was applied to the other. The read
     was lowered to an unchecked load: garbage natively, or a crash.
   * The root is older than the prototypes: a counted loop over two
     snapshots was already wrong on the baseline.
   * CP-1's reduced-index rule and CP-3's field-path keys gave it new
     ways in.
   * Fix: a loop over a vector has the length the vector has at that
     evaluation. Evaluations share one length only when nothing between
     them can resize the place: a resizing operation on it, on a copy it
     came through, or, for a context member, a call that may reach the
     context, or a yield.
   * Length-keeping operations (a swap, an array's `set`) are registered
     `-keeps-length`.
   * A mutating operation taken as a function value is rejected. Called
     through the value, it mutated whatever header its caller passed:
     AR-11 in the catalogue.
2. **VS-1's per-path moves assumed every struct slot owns its headers.**
   * A struct's share descriptor skipped its `any` slots, so two such
     slots could share one header. Moving one then wrote into the other.
   * Fix: an imprecise slot is copied by what it holds at run time. That
     also cures the older bug of the descriptor itself.
3. **Three older value-semantics miscompiles:**
   * a move before `break` or `continue` taken as a last use;
   * a context member passed by reference while a later argument yields
     (a gap in BUG-1's fix);
   * a mutated handler payload binding with no entry copy.

   Each is fixed by a rule in hir/mutvec.tcl.
4. **An older unsound induction fact that CG-2 started to trust.**
   * hir/induction.tcl ignored self calls in non-tail positions, and
     accepted a native call as a stable bound even when its argument
     changed every step.
   * Branch decisions had used those facts wrongly before (the baseline
     too). With CG-2, a `mod` lowered as a mask computed a wrong value,
     and a `rimodtotal` divided by zero and killed the process.
   * Fix: every self call counts as a step.
   * A bound is invariant only by what each invocation reads: literals,
     unchanged parameters, invariant locals and projections, and
     repeatable calls over them. A binding from outside the function
     counts only when every self call runs the same closure.
5. **The second older bug the fixes uncovered** (the first is AR-11,
   above).
   * The interpreter's `listloop` drained any vector that reached an
     unmarked loop through an `any` path, where the other backends raised
     the loop's TYPE error.
   * Fix: only a consume-marked loop drains one (`65d48d3`, AR-12, merged
     with the bounds fix).

**How the fixes were made.**
* Each fix was made in its own worktree, with regression tests for every
  reproducer, mutants for every rule, and the fuzzers taught the new
  shapes.
* It ran the harnesses AGENTS.md names for its area.
* Two independent verifiers then checked it: one tried to break it with
  new variants, the other looked for regressions, meaning sound programs
  newly rejected or copies, checks or proofs lost.
* A fix that either verifier faulted went back for repair.

| fix | commits | rounds | final verdict |
|---|---|---:|---|
| value semantics | `0935cb3` `3a9f010` `14a4819` `e687ef5` `9771996` | 1 | sound, no regression |
| bounds | 19 commits, `dfca4b5`..`81a4d02` (merge `a71467d`) | 3 | sound; it gives back some precision of the prototypes (below) |
| induction | `8d49781` `8d0d69c` `c75de7c` `a051f98` `4cb395e` `ab9fd11` (merge `1198a1d`) | 2 | sound; it no longer proves a bound over `hash(s)` or a relational bound |

**CI on the fixed tree.** Dispatched on the branch at `0693e1a`, after
the three merges, every workflow is green:
* `tests` (x86-64);
* `tests-arm64`, its GC-stress job included;
* `static-decisions`: every golden suite, batched against sequential.

**What the bounds fix gives back.** These are proofs that the old,
unsound keying made: some only on the merged tree, some for local
vectors on the baseline too. Soundness does not require losing them, but
keeping them needs a finer analysis than the fix's:
* two loops over a context's vector are unrelated around any call that
  may reach the context, even one that only reads it;
* a resize in a branch that cannot complete normally still separates the
  loops after it;
* a pop's shorter length is not known to bound the longer earlier one.

**Language change.** The value-semantics and bounds rules now reject a
mutating collection operation taken as a function value
(`MUTABLE-PLACE-RECEIVER`). Nothing in the corpus, the libraries, the
golden suites or the tests did that. A program that does calls the
operation on a place, or wraps it in a function of its own.

**What the fixes cost the tables: nothing measurable.** The fixed tree
was measured again (`tools/plan5.sh`, tag `fixed` in `results/`):
* every table's generated code (the NIR census) is byte-identical to the
  merged tree's before the fixes;
* every allocation count per lookup, every array copy count and the
  memory per entry are unchanged, and the natural memo workload is still
  copy-free;
* of the 106 instruction counts taken on both trees (the fixed tree has
  132), 100 agree with the pre-fix tree's within 3 %. The other six
  (three hits by 3.5-4.3 %, a 16-entry `lpmono`'s lookups by 5-6 %,
  chaining's String misses by 10 %) were counted twice more on each tree
  (`results/instructions-repeat.tsv`). Five vary as much between runs of
  one tree as between the trees. The sixth, the 16-entry `lpmono`'s miss,
  is about 3 % lower on the fixed tree.

So the timings taken before the fixes stand for the fixed tree.

## Performance

### How the numbers were taken

**The trees.** Every Botlish number names the compiler tree it was
measured on:
* **baseline**: commit `2aa20d6`, before the prototypes;
* **merged**: this branch, with all five prototypes merged. It was timed
  before the review fixes, which change nothing measurable in it ("The
  adversarial review, and what it found");
* each prototype alone on the baseline, for the ladders;
* the probe primitive (`patches/probe-primitive.patch`), on the baseline
  and on the merged tree.

Everything native runs on cranelift (specialized) unless a table says
otherwise. The machine is a 4-core x86-64 container that ran nothing
else during the timed phases (`tools/plan.sh`, `plan2.sh`, `plan3.sh`,
and the first step of `plan4.sh`).

**Timing.**
* **Lookups.** Hit, miss, member and replace run as passes: P = 4 passes
  of 200,000 queries over one table, minus one pass, divided by
  3 x 200,000 (`bench.tcl -passes 4`). Everything else in the program
  (the key lists, the build) cancels exactly.
* **Builds.** A build is REPS repetitions of N inserts into `fresh(0)`
  (growing) or `fresh(N)` (presized), with REPS = 200,000 / N. Builds,
  bulk construction and removals likewise run as passes: 3 x REPS
  repetitions minus REPS, in one program (`-build-passes 3`).
  * The first sweeps timed lookups and builds against a separately timed
    run of the program without them. Its noise landed in the difference
    and produced visibly wrong rows. Every table below uses the passes
    method, except where it says otherwise.
* **Repeats.** Each configuration is the best of 5 runs in one process
  (`Vm::reset` between runs).
* **Ladders.** The ladders and the build sweep run every tree in turn,
  three rounds, and report the median. A drift of the machine therefore
  affects every tree alike.
* **Noise.** Single sizes still show an occasional one-run outlier, about
  one cell in thirty. The tables use the median over a size regime
  (`summarize.tcl regimes`): tiny (1-8), small (16-256), medium
  (716-4,096) and large (11,468-16,384).

**Counting.**
* **Instructions.** `tools/instructions.tcl` and `tools/profile.tcl` run
  the same programs under callgrind, as the difference of the same
  passes. They do not depend on the machine's load, but they are not
  exactly repeatable: the native process's randomly seeded internal maps
  and its allocation addresses vary from run to run, and the two runs'
  start-up costs never cancel exactly. Repeated runs agree within about
  5 % per operation, and within 20 % for chaining's String misses
  (`results/instructions-repeat.tsv`). A smaller difference is not a
  difference.
* **Allocations and copies.** `tools/allocs.tcl`, `copies.tcl` and
  `memory.tcl` read the native allocation report. They are
  deterministic too.

**Rust.** The reference times its operation phase directly (best of 5)
and shares Botlish's hash, capacities and probe sequences exactly.

### Lookups by size

ns per operation on the merged tree, as regime medians: small is 16-256
keys, medium 716-4,096, large 11,468-16,384. The last column is the
baseline compiler's medium regime.

**Int keys (int-dense):**

| table | hit, small | hit, medium | hit, large | miss, small | miss, medium | miss, large | baseline, medium: hit / miss |
|---|---:|---:|---:|---:|---:|---:|---:|
| `listmap` | 49.0 | 570 | -- | 91.0 | 1,152 | -- | 611 / 743 |
| `chain0` | 446 | 595 | 1,779 | 210 | 267 | 1,707 | 621 / 305 |
| `ht0` | 56.0 | 63.0 | 76.5 | 64.0 | 60.4 | 60.7 | 121 / 89.7 |
| `chain` | 32.2 | 47.6 | 99.6 | 49.5 | 56.0 | 67.6 | 70.2 / 83.6 |
| `lpa` | 40.0 | 45.5 | 51.3 | 68.9 | 74.6 | 101 | 79.6 / 88.4 |
| `lpmono` | 31.2 | 41.1 | 45.8 | 58.6 | 58.4 | 90.2 | 67.3 / 84.0 |
| `lpfact` | 38.4 | 44.7 | 56.6 | 62.8 | 63.2 | 87.1 | 68.3 / 116 |
| `lpmask` | 32.3 | 39.8 | 52.1 | 53.4 | 57.7 | 74.0 | 86.4 / 92.8 |
| `rh` | 40.7 | 52.2 | 60.6 | 65.1 | 66.6 | 86.1 | 76.9 / 98.2 |
| `cd` | 44.7 | 52.8 | 66.1 | 64.9 | 69.3 | 90.3 | 81.5 / 96.4 |
| `sorted` | 76.9 | 155 | -- | 87.5 | 116 | -- | 183 / 136 |
| `lp` | 39.0 | 39.8 | -- | 68.4 | 67.6 | -- | 70.6 / 120 |
| `lpc` | 38.6 | 50.5 | 60.0 | 74.2 | 70.7 | 101 | 66.5 / 92.1 |
| Rust `lp` (same algorithm, same hash) | 8.8 | 10.7 | 21.8 | 41.6 | 43.5 | 47.4 | |
| Rust `std::HashMap` (SipHash) | 10.9 | 11.1 | 11.6 | 11.6 | 11.8 | 11.9 | |

**String keys (str-short):**

| table | hit, small | hit, medium | hit, large | miss, small | miss, medium | miss, large | baseline, medium: hit / miss |
|---|---:|---:|---:|---:|---:|---:|---:|
| `listmap` | 797 | 5,654 | -- | 495 | 16,453 | -- | 5,316 / 10,478 |
| `chain0` | 497 | 843 | 9,666 | 200 | 640 | 9,238 | 784 / 468 |
| `ht0` | 89.4 | 103 | 130 | 63.5 | 69.9 | 87.5 | 123 / 85.7 |
| `chain` | 51.6 | 64.6 | 140 | 36.4 | 43.2 | 58.5 | 69.5 / 41.7 |
| `lpa` | 50.0 | 59.2 | 88.6 | 50.4 | 55.7 | 100 | 80.6 / 69.6 |
| `lpmono` | 49.7 | 54.5 | 101 | 41.8 | 61.7 | 85.0 | 63.6 / 63.6 |
| `lpfact` | 54.0 | 62.2 | 99.7 | 47.0 | 56.8 | 82.4 | 74.2 / 62.7 |
| `lpmask` | 46.8 | 55.3 | 67.9 | 44.8 | 45.6 | 63.9 | 79.2 / 73.3 |
| `rh` | 55.1 | 61.6 | 104 | 49.3 | 51.3 | 74.5 | 82.2 / 73.7 |
| `cd` | 57.4 | 73.8 | 100 | 49.8 | 57.4 | 84.0 | 77.4 / 77.0 |
| `sorted` | 92.5 | 174 | -- | 84.7 | 104 | -- | 178 / 103 |
| `lp` | 52.0 | 58.4 | -- | 56.3 | 79.0 | -- | 61.2 / 67.1 |
| `lpc` | 52.8 | 62.2 | 94.5 | 58.3 | 55.5 | 100 | 73.3 / 65.7 |
| Rust `lp` | 9.6 | 13.5 | 30.3 | 14.7 | 22.9 | 24.9 | |
| Rust `std::HashMap` | 13.8 | 15.1 | 33.8 | 14.1 | 14.4 | 17.8 | |

The Rust rows are the reference's values at 128, 1,024 and 16,384 keys.
`listmap`'s rows are noisy: its quadratic build dominates every run,
and the lookups are the small difference between two such runs.

* **The compiler work cuts open-addressed Int hits by 24-54 %, Int
  misses by 16-46 % and String lookups by 3-38 %** (`lp`'s String misses
  got 18 % slower, 67.1 to 79.0 ns). `lpa` goes from 79.6 to 45.5 ns on
  medium Int hits. The proof-shaped `lpmask` gains the most (86.4 to
  39.8): its extra reductions become free, and its accesses proven.
* **The tables' order barely changes.**
  * The hand-inlined `lpmono` and the proof-shaped `lpmask` lead on hits.
  * Chaining has the cheapest misses: it compares 0.7 entries per miss,
    where linear probing at load 0.7 makes about 4 probes. Rust shows the
    same (36 against 44 ns).
  * `ht0`, the existing prototype, gains the most ns of any table (121 to
    63 ns on Int hits), because it pays for many array accesses per
    probe. Its controls array stops a miss early.
* **Int misses cost more than Int hits; String misses do not.** Int
  keys cost the same per probe, so the 4 probes of a miss outweigh the
  1.6 of a hit. For String keys, a hit ends in a full String comparison,
  while a miss's comparisons fail at the length or the first character.
* **The Botlish/Rust ratio of the same algorithm.** At medium sizes
  (`lpmono` and `lpa` against Rust `lp`), on the merged tree:

  | | Int | String |
  |---|---:|---:|
  | hits | 3.8-4.3 | 4.0-4.4 |
  | misses | 1.3-1.7 | 2.4-2.7 |

  "What remains" breaks it down.

**Membership and replace** (medium regime, merged tree, ns; `member` is
`has?` on half hits, half misses):

| table | Int: member | Int: replace | String: member | String: replace |
|---|---:|---:|---:|---:|
| `lpa` | 53.5 | 42.7 | 60.1 | 58.8 |
| `lpmono` | 56.1 | 36.6 | 50.0 | 68.4 |
| `lpmask` | 46.3 | 38.0 | 54.3 | 53.0 |
| `rh` | 61.0 | 48.2 | 58.4 | 69.2 |
| `cd` | 62.4 | 58.1 | 62.9 | 74.2 |
| `ht0` | 50.7 | 37.3 | 61.7 | 60.1 |
| `chain` | 60.3 | 522 | 48.6 | 618 |
| `lpc` | 57.4 | 179 | 61.3 | 210 |
| `lp` | 79.4 | 4,332 | 81.7 | 5,097 |

A replace allocates in chaining (a new Entry and bucket List), rebuilds
`lpc`'s struct, and copies `lp`'s arrays.

### Building

Per insert (and per removal for drop), ns, medium regime (716-4,096
keys). Every table was timed as passes, alternating the baseline and the
merged tree (`results/builds/`):

| table | Int, growing | Int, presized | Int, bulk | Int, drop | String, growing | String, presized |
|---|---|---|---|---|---|---|
| `lpa` | 240 → **149** | 124 → 71.3 | 130 → 71.9 | 142 → 72.4 | 221 → 150 | 102 → 71.8 |
| `lpmono` | 209 → **118** | 107 → 60.8 | 106 → 64.5 | 127 → 61.4 | 195 → 112 | 83.4 → 56.0 |
| `lpfact` | 233 → 146 | 123 → 69.5 | 122 → 67.7 | 123 → 70.7 | 226 → 137 | 103 → 66.4 |
| `lpmask` | 286 → 134 | 145 → 71.2 | 145 → 70.2 | 161 → 73.7 | 263 → 137 | 126 → 68.7 |
| `rh` | 312 → 201 | 163 → 98.6 | 162 → 105 | 156 → 69.5 | 315 → 215 | 149 → 99.2 |
| `cd` | 189 → 138 | 129 → 90.4 | 135 → 94.9 | -- | 174 → 119 | 108 → 97.1 |
| `chain` | 514 → 475 | 317 → 311 | 326 → 315 | 255 → 220 | 590 → 504 | 369 → 325 |
| `ht0` | 307 → 173 | 138 → 75.6 | 137 → 75.0 | 121 → 47.4 | 273 → 180 | 125 → 82.9 |
| Rust `lp` | 24.5 | 14.9 | | 15.7 | 77.8 | 52.1 |
| Rust `rh` | 39.0 | 23.2 | | 22.0 | 90.9 | 62.5 |
| Rust `chain` | 75.5 | 47.7 | | 17.9 | 128 | 85.2 |
| Rust `std` | 45.7 | 14.2 | | 14.0 | 105 | 64.2 |

(Each cell is baseline → merged. The Rust reference's drop includes its
build, which is subtracted here.)

* **The compiler work cuts open-addressed builds by 25-55 %,** except
  `cd`'s presized String build (10 %) and `ht0`'s removals (61 %). It cuts
  chaining's by 2-15 %: its cost is the Entry and the bucket List each
  insert allocates.
* **Building is where Botlish is furthest from Rust:**
  * a growing Int build in `lpmono` costs 4.8 times Rust `lp`, and a
    presized one 4.1 times;
  * a String build costs only 1.1-1.9 times (growing 1.4-1.9), because
    the Rust reference clones each String key into the table (`build`, a
    malloc and a copy per key) and a Botlish table shares it;
  * a removal costs 3.9-4.7 times.
* **Growing costs about twice a presized build** for every open-addressed
  table, in Rust as in Botlish: it is the reinsertion work, not overhead.
* **Robin Hood's displacement costs 30-45 % on every insert,** on both
  trees.
* **The compact dict was the cheapest growing build on the baseline**
  (growth rehashes only its index). On the merged tree `lpmono` and
  `lpmask` overtake it.
* **Tiny tables (1-8 entries) cost 350-700 ns per insert in every
  table.** That is the fixed cost of `fresh` (three or four arrays)
  spread over few inserts, and the compiler work did not change it
  ("Short-lived tables").

### Key types

Lookups in tables of 1,024 keys, hit / miss, ns per operation, timed as
passes.

**Merged tree:**

| table | int-sparse | int-big | str-medium | point | int-collide |
|---|---:|---:|---:|---:|---:|
| `lpa` | 57.9 / 81.3 | 107 / 97.3 | 93.1 / 103 | 141 / 124 | 3313 / 149 |
| `lpmono` | 51.0 / 72.8 | 103 / 93.1 | 125 / 69.9 | 111 / 142 | 2447 / 61.9 |
| `rh` | 59.5 / 99.2 | 119 / 91.5 | 88.2 / 93.4 | 120 / 113 | 4404 / 142 |
| `chain` | 72.7 / 56.1 | 150 / 92.0 | 96.5 / 70.4 | 131 / 82.5 | 954 / 32.0 |
| `cd` | 59.2 / 79.2 | 113 / 96.7 | 98.9 / 83.0 | 147 / 132 | 2716 / 71.0 |
| `ht0` | 86.8 / 70.3 | 261 / 205 | 167 / 104 | 233 / 147 | 4542 / 64.2 |
| `chain0` | 544 / 270 | 1619 / 1225 | 825 / 578 | 905 / 571 | 4903 / 4220 |
| `sorted` | 179 / 153 | -- / -- | 231 / 212 | 247 / 220 | -- / -- |

**Baseline compiler, with the Rust reference:**

| table | int-sparse | int-big | str-medium | point | int-collide |
|---|---:|---:|---:|---:|---:|
| `lpa` | 91.3 / 95.7 | 233 / 240 | 101 / 101 | 240 / 256 | 3,737 / 112 |
| `lpmono` | 73.8 / 86.5 | 237 / 227 | 89.1 / 88.9 | 228 / 211 | 2,802 / 89.3 |
| `rh` | 95.2 / 105 | 273 / 244 | 94.2 / 96.7 | 236 / 236 | 6,855 / 157 |
| `chain` | 82.0 / 82.2 | 244 / 225 | 99.8 / 72.2 | 228 / 217 | 1,054 / 47.6 |
| `cd` | 96.0 / 102 | 268 / 263 | 108 / 107 | 244 / 254 | 4,100 / 121 |
| `ht0` | 149 / 104 | 564 / 314 | 217 / 112 | 477 / 257 | 8,973 / 111 |
| `chain0` | 751 / 285 | 1,550 / 1,349 | 729 / 613 | 1,018 / 694 | 4,356 / 4,560 |
| `sorted` | 191 / 170 | -- | 216 / 164 | 395 / 327 | -- |
| Rust `lp` | 28.5 / 46.0 | 91.2 / 104 | 35.8 / 53.3 | 33.4 / 60.4 | 312 / 35.9 |
| Rust `chain` | 26.2 / 42.8 | 98.3 / 103 | 36.8 / 44.3 | 24.8 / 52.9 | 206 / 19.4 |
| Rust `std` | 11.1 / 11.6 | 13.2 / 13.6 | 24.3 / 23.1 | 13.3 / 13.6 | 10.9 / 11.5 |

* **Sparse Ints cost up to 30 % more than dense ones on the baseline,
  and up to 53 % more on the merged tree** (1,024 keys; merged hits
  24-53 %, except `sorted` 15 % and `chain0` -9 %; misses 0-49 %). The
  hash runs FNV over the decimal text, and a sparse key has ten digits
  where a dense one has three or four.
* **BigInt keys (2^80 + i).**
  * On the baseline they cost 225-275 ns in every table but `ht0` and
    `chain0`: the hash converted the BigInt to decimal text on the heap.
  * The merged tree's allocation-free hash (RO-1) halves that, to about
    100 ns.
  * Rust, running the same hash, pays 91 ns; `std` hashes the machine
    representation in 13 ns. What is left is the hash's definition
    (decimal text), not the table.
* **Struct keys (`Point`)** drop from 230-250 ns to 110-150. The
  baseline's native hash materialized the struct's shape and allocated
  (RO-1). The rest is hashing and comparing through a materialized
  object (CO-6): 3.3-4.2 times Rust `lp`.
* **Adversarial collisions (`int-collide`)** put every key on one home
  slot at every capacity up to 1,024:
  * An open-addressed hit then walks the whole cluster: 2.4-4.5 µs at
    1,024 keys on the merged tree, and builds become quadratic.
  * Robin Hood is the worst of the new tables (4,404 ns), because every
    insert shifts the cluster. `ht0` is slower still (4,542 ns).
  * Chaining degrades least (0.95 µs): it scans one bucket List.
  * Rust's ordering is the same (`chain` 206, `lp` 312, `rh` 1,271 ns).
    `std::HashMap` is immune (11 ns): SipHash with a per-process random
    key.
  * Botlish's `hash` is fixed and public, so no table written in Botlish
    can defend itself. That is runtime pressure: RT-3 in the catalogue.
* **Two kinds of rows are omitted.**
  * Builds: they were timed against a separate key run, and at these
    sizes that leaves too much noise to compare.
  * `sorted` at 16,384 keys: its lookup passes were noisier than the
    lookups themselves (negative differences in three cells on the
    merged tree, two on the baseline).

### Typed against generic

`lpint` and `lpstr` are `lpa` with typed key and value arrays. Typing
makes key equality `ieq`/`streq` instead of the generic `veq` (CO-3).
Hit / miss, ns per operation:

| keys | baseline: `lpa` | baseline: typed | merged: `lpa` | merged: typed |
|---|---|---|---|---|
| int-dense, 1,024 | 70.8 / 86.8 | 73.3 / 96.0 | 40.5 / 67.2 | 38.8 / 65.7 |
| int-sparse, 1,024 | 97.7 / (142) | 81.5 / 98.3 | 55.8 / 90.7 | 50.4 / 80.5 |
| str-short, 1,024 | 71.9 / 65.0 | 60.9 / 66.2 | 49.2 / 63.4 | 42.9 / (11.9) |
| str-short, 16,384 | 130 / 70.8 | 82.5 / 68.4 | 106 / 78.4 | 78.1 / 69.6 |
| str-medium, 1,024 | 105 / 103 | 87.2 / 98.2 | 109 / 91.0 | 94.2 / 92.0 |

The parenthesized cells are one-run outliers: "Key types" measures the
first at 95.7 ns.

* For String keys, typing saves 10-35 % on hits, which compare keys. It
  does not save on misses, which mostly stop at an empty slot without
  comparing a key.
* For Int keys it saves 2-11 % on the merged tree. On the baseline it
  costs 3-11 % on dense keys, saves 17 % on sparse hits and nothing on
  sparse misses. `veq` on two small Ints takes a fast path.
* For String keys the saving is the same on both trees. The compiler
  work did not touch equality, so typed slot storage (CO-3) is still
  worth having for String-keyed tables.

### Mixed workloads

The workloads (SPEC.md section 6):
* a BFS over a grid with a visited set of `Point` keys;
* a word-frequency count over String keys;
* a memoized Collatz step count. `memo.bot` is written naturally: each
  call returns `Steps {memo: memo, count: c}`. `memo2.bot` is the same
  algorithm restructured around the copies the natural version made on
  the baseline.

Times in ms, and the ratio to the Rust reference's same algorithm
(`lp`). The Rust reference runs `std::HashMap` too:

| workload | size | table | baseline | merged | Rust `lp` | Rust `std` | merged / Rust `lp` |
|---|---:|---|---:|---:|---:|---:|---:|
| BFS visited set | 256 x 256 | `lpa` | 162 | 139 | 26.2 | 9.4 | 5.3 |
| | | `lpmono` | 188 | 112 | | | 4.3 |
| | | `cd` | 153 | 100 | | | 3.8 |
| | | `chain` | 222 | 136 | | | 5.2 |
| word frequency | 262,144 words | `lpa` | 47.2 | 42.8 | 18.0 | 22.4 | 2.4 |
| | | `lpmono` | 40.1 | 44.0 | | | 2.4 |
| | | `rh` | 48.4 | 39.5 | | | 2.2 |
| | | `chain` | 230 | 301 | | | 16.7 |
| memo, written naturally | 10,000 | `lpa` | **2,724** | **9.46** | 2.27 | 1.61 | 4.2 |
| | | `lpmono` | 2,779 | 4.86 | | | 2.1 |
| | | `cd` | 2,812 | 5.34 | | | 2.3 |
| | | `chain0` | 104 | 77.4 | | | 34 |
| memo, restructured | 100,000 | `lpa` | 173 | 151 | 44.0 | 28.5 | 3.4 |
| | | `lpmono` | 176 | 144 | | | 3.3 |
| | | `cd` | 189 | 149 | | | 3.4 |

* **The naturally written memo is the experiment's largest single
  effect.**
  * On the baseline, every call copied the whole table (VS-2): 1,199
    times Rust.
  * With VS-2 merged, the same source copies nothing and runs 290 times
    faster. It now matches the restructured version (9.5 against 8.9 ms
    for `lpa` at 10,000).
  * `chain0` only looked better on the baseline: its bucket Lists are
    immutable, so the copies were cheap.
* **With no copies left, Botlish is 2-5 times the same algorithm in
  Rust** on every workload, and 2-15 times `std::HashMap`.
* **Chaining loses the String-heavy frequency count** (7 times `lpa`).
  Each new word allocates an Entry and a bucket List, and 262,144 words
  mean many inserts.
* **The best table depends on the workload:**
  * the compact dict on BFS, which does mostly inserts;
  * Robin Hood and `lpa` on frequency counting, which is mostly updates;
  * `lpmono` on memoization, which is mostly lookups.

  The best and the runner-up differ by 3-12 %. Apart from chaining, the
  slowest table trails the best by 4-39 %, except on the natural memo,
  where `lpa` takes twice `lpmono`'s time (9.46 against 4.86 ms).

### Short-lived tables (construction against lookups)

Time for one lifetime of a table -- build N entries into `fresh(0)`,
then L lookups -- in µs, Int keys, baseline compiler:

| table | L = 1: N = 1 | 4 | 16 | 64 | 256 | L = 1,000: N = 1 | 4 | 16 | 64 | 256 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `listmap` | 0.49 | 1.32 | 4.99 | 24.4 | 167 | 13.7 | 17.0 | 30.0 | 90.1 | 351 |
| `lpa` | 0.74 | 1.00 | 4.45 | 14.8 | 57.0 | 64.8 | 67.7 | 66.2 | 84.7 | 131 |
| `lpmono` | 0.72 | 0.99 | 4.01 | 13.0 | 47.7 | 54.9 | 59.1 | 60.9 | 79.0 | 111 |
| `cd` | 1.13 | 1.40 | 4.26 | 12.7 | 48.2 | 70.0 | 67.5 | 75.0 | 86.1 | 120 |
| `chain` | 0.76 | 1.43 | 6.24 | 25.7 | 104 | 54.8 | 60.2 | 60.2 | 86.6 | 189 |
| `sorted` | 1.37 | 3.99 | 24.3 | 223 | 2,878 | 71.8 | 88.3 | 121 | 340 | 2,992 |
| Rust `listmap` | 0.02 | 0.03 | 0.15 | 1.25 | 20.7 | 0.56 | 1.45 | 3.44 | 12.4 | 72.0 |
| Rust `lp` | 0.08 | 0.11 | 0.52 | 1.78 | 5.72 | 4.48 | 5.98 | 7.87 | 9.82 | 14.9 |
| Rust `std` | 0.05 | 0.17 | 0.90 | 3.03 | 11.7 | 10.7 | 10.2 | 10.8 | 13.5 | 21.9 |

* **A table's fixed cost.** Making a table, one insert and one lookup cost
  0.7 µs in `lpa`, against 0.08 µs for the same algorithm in Rust: about
  9 times, more than the lookup ratio. Most of it is `fresh(0)`, which
  allocates three or four arrays (a header and a backing each).
* **The list crossover.** A List of entries beats every table when there
  are few entries or few lookups:
  * with one lookup, up to 2 entries (at 4, `lpa`, `lpmono` and `rh`
    take 1.00, 0.99 and 1.23 µs against the list's 1.32);
  * with 10 lookups, up to 4 entries;
  * with 1,000 lookups, up to 32 entries (at 64 `lpmono` takes 79.0 µs
    against the list's 90.1).
* **Why Rust's crossover is later.** In Rust the list wins up to about 64
  entries with one lookup. Botlish's `listmap` appends to an immutable
  List, which copies, so its build is quadratic; a Rust `Vec` push is
  amortized constant. That is the data structure's choice (algorithm),
  not missing compiler work.

On the merged tree:

| table | L = 1: N = 1 | 4 | 16 | 64 | 256 | L = 1,000: N = 1 | 4 | 16 | 64 | 256 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `listmap` | 0.47 | 1.35 | 5.82 | 24.2 | 169 | 14.2 | 16.4 | 30.4 | 95.5 | 354 |
| `lpa` | 0.66 | 0.76 | 2.99 | 9.02 | 32.0 | 33.3 | 32.0 | 38.8 | 52.1 | 71.1 |
| `lpmono` | 0.60 | 0.70 | 2.59 | 7.19 | 23.5 | 25.3 | 25.4 | 31.5 | 41.4 | 56.5 |
| `cd` | 1.08 | 1.26 | 3.27 | 8.86 | 32.4 | 41.0 | 41.7 | 45.1 | 57.0 | 83.8 |
| `chain` | 0.63 | 1.27 | 5.21 | 22.2 | 95.0 | 32.1 | 31.3 | 38.4 | 51.7 | 132 |

* **Lookups halved, but the fixed cost of a table did not.**
  * A table with 1,000 lookups costs half as much on the merged tree.
  * Making a table with one entry and one lookup still costs 0.6-0.7 µs,
    8 times Rust's 0.08. `fresh(0)` allocates three or four arrays, and
    each is a header plus a backing.
  * Nothing in the compiler work touched allocation. Allocating the
    arrays of a small table together, or lazily, is the item that
    matters for tables that live briefly. It is a library choice (lazy
    allocation) as much as a runtime one.
* **The list crossover moves down.** A table now beats a list from 2
  entries with one lookup (`lpmono` 0.63 µs against the list's 0.76) and
  with 10 (`life10` in `results/life-*.tsv`: 0.92 against 1.04), and from
  32 entries with 1,000 lookups (at 16 the list still wins, 30.4 against
  31.5 µs). String keys cross earlier: with 1,000 lookups, from 4
  entries. The tables got faster; the list did not.

### Hash quality, collision strategies and load

These numbers are deterministic. They come from the Rust reference's
`stats` subcommand (`results/rust-stats-baseline.tsv`; `summarize.tcl
stats`), which builds the same tables with the same hash and counts probes.

**Distribution.** For each key kind and capacity, the table compares two
statistics of Botlish's hash with those of a splitmix64 control over the
same keys:
* the chi-squared statistic of the occupied-slot histogram;
* the number of empty slots.

At maximum load 7/10 (716 keys in 1,024 slots; 11,468 in 16,384) the
results are, Botlish's hash first, then the control's in parentheses:

| keys | chi-squared, 716 / 1,024 | 11,468 / 16,384 | empty slots, 716 / 1,024 | 11,468 / 16,384 |
|---|---|---|---|---|
| int-dense | 788 (1,029) | 16,060 (16,551) | 464 (506) | 8,110 (8,150) |
| int-sparse | 974 (1,026) | 16,508 (16,640) | 499 (513) | 8,160 (8,186) |
| int-big | 748 (1,046) | 15,780 (16,111) | 454 (519) | 8,032 (8,079) |
| str-short | 889 (972) | 16,025 (16,234) | 485 (501) | 8,064 (8,098) |
| str-medium | 628 (977) | 15,034 (16,302) | 416 (500) | 7,880 (8,145) |
| point | 1,029 (932) | 16,440 (16,231) | 512 (489) | 8,159 (8,118) |

FNV-1a over the decimal text is as uniform as the control, or more so, for
every key kind the experiment uses. Dense Ints in particular spread better
than random. The struct key is within 10 % of the control. Probe lengths
are of the order of Knuth's expectation for uniform hashing (0.7-1.5
times it). At load 0.7, linear
probing should average 2.17 probes for a hit and 6.05 for a miss; the
measured hit means are 1.5-2.7 and the miss means 4.0-8.8 (`int-big` at
11,468 keys the highest: 2.70 and 8.84). **The hash is not a problem the
experiment needs to solve.** The one adversarial case is `int-collide`:
keys whose hash is 0 mod 1,024, found by black-box search. It puts every
key on one home slot at every capacity up to 1,024. A fixed public hash
is open to that, and so is any unkeyed hash.

**Collision strategies at load 0.7, 11,468 Int keys (int-dense) in 16,384
slots:**

| table | hit: mean / p95 / p99 / max | miss: mean / p95 / p99 / max |
|---|---|---|
| linear probing (`lp`) | 2.29 / 7 / 18 / 55 | 6.47 / 25 / 41 / 67 |
| Robin Hood (`rh`) | 2.29 / 5 / 7 / 11 | 2.48 / 6 / 7 / 12 |
| chaining (`chain`), entries compared | 1.34 / 3 / 3 / 5 | 0.62 / 2 / 3 / 5 |

Robin Hood's early termination cuts the miss tail by a factor of 4 to 7.5
at p99 and max for every ordinary key kind at 11,468 keys (str-short:
55/89 -> 8/14). Chaining's lookups touch fewer entries, but each bucket is
a List object. A lookup therefore costs a pointer chase, and an insert
allocates.

**Chaining's buckets.** The table shows bucket lengths at load 1 (16,384
keys in 16,384 buckets: `chain` grows at load 1/1), against the Poisson
expectation of uniform hashing:

| keys | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | longest |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Poisson(1), expected | 6,027 | 6,027 | 3,014 | 1,005 | 251 | 50 | 8 | 1 | |
| int-dense | 6,102 | 5,960 | 2,926 | 1,064 | 284 | 44 | 4 | 0 | 6 |
| int-sparse | 6,053 | 5,980 | 3,018 | 1,037 | 234 | 51 | 11 | 0 | 6 |
| str-short | 5,820 | 6,269 | 3,100 | 922 | 227 | 36 | 9 | 1 | 7 |
| point | 6,051 | 6,034 | 2,937 | 1,035 | 267 | 57 | 3 | 0 | 6 |
| int-collide | 16,368 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 16 buckets of 1,024 |

Every ordinary key kind's buckets are Poisson to within sampling noise.
The longest chain is 6-7. Each entry costs one Entry struct, and each
insert a new bucket List (`chain`: 99 bytes allocated per entry
presized, "Memory"). So **bad table state is never the problem for the
ordinary key kinds**: the probe counts are the textbook's, and the time
goes to the work per probe ("What remains").

**Load policy.** At capacities that are powers of two, maximum loads of
7/10 and 17/20 coincide for most sizes: both grow 1,024 entries into
2,048 slots. The policy matrix therefore uses sizes that fill a capacity
to exactly 1/2, 7/10 and 17/20 (512, 716 and 870 entries in 1,024 slots;
8,192, 11,468 and 13,926 in 16,384). The timings are in "Resize policy"
below.

### Resize policy

Three maximum loads, each with doubling growth: 1/2, 7/10 (the default
of every table) and 17/20. The tables use power-of-two capacities, so
two of these loads often grow at the same entry count. The matrix
therefore measures sizes that fill a capacity to exactly each load:
* 512, 716 and 870 entries in 1,024 slots;
* 8,192, 11,468 and 13,926 entries in 16,384 slots.

Under a lower maximum load, the same entry counts grow the table once
more. Timings are on the merged tree, as passes (`lookups/policy-*.tsv`).
Each is the best of its rounds, not their median: one round for `lpa` at
1/2, two for the others. Medians are up to 13 % higher. Probe counts come
from the reference.

**At each policy's peak load**, `lpa`, Int keys, ns per operation at
about 1K and 16K entries:

| max load | bytes per entry at peak | growing build, per insert | hit | miss | hit probes, mean / max | miss probes, mean / max |
|---|---:|---|---|---|---|---|
| 1/2 | 48 | 144 / 139 | 38 / 48 | 68 / 72 | 1.34 / 8 | 2.28 / 10 |
| 7/10 | 34 | 123 / 138 | 48 / 61 | 98 / 132 | 1.63 / 17 | 4.21 / 28 |
| 17/20 | 28 | 131 / 195 | 55 / 91 | 181 / 360 | 2.32 / 39 | 10.8 / 45 |
| Robin Hood, 17/20 | 28 | 223 / 317 | 68 / 118 | 105 / 135 | 2.32 / 7 | 2.99 / 7 |

The bytes per entry count three words per slot. The probe counts are
the reference's at the ~1K peak.

**Averaged over all six sizes** (what a table of unknown size sees),
`lpa`, Int keys:

| max load | growing build | hit | miss |
|---|---:|---:|---:|
| 1/2 | 149 | 41.0 | 59.9 |
| 7/10 | 148 | 46.4 | 81.5 |
| 17/20 | 165 | 57.9 | 151 |

**Resize spikes.** The Rust reference times every single insert of a
growing build ("spike", `rust-spike-baseline.tsv`). The growth is the
spike, and its size is the number of entries it reinserts:
* for `lp`, the mean insert is 64-141 ns, and the p99 74-214 ns (`rh`
  and `chain`: means up to 170 ns, `rh`'s p99 up to 1,239 ns);
* `lp`'s largest single insert is the last growth: 75-190 µs when it
  reinserts 6,000-14,000 entries, 0.4-0.5 ms when it reinserts 8,192
  into 32,768 slots, and 1.0-2.3 ms at 65,536 entries.
* the policy only moves the point where the spike falls.

Botlish's growth is the same algorithm. Its growth work per insert,
amortized (growing build minus presized build), is 57-78 ns on the merged
tree, against Rust's 10. Its spikes should therefore be about 6-8 times
Rust's: of the order of 0.5-4 ms at 10-16K entries, and 6-18 ms at
64K. That is an estimate from the amortized costs: no Botlish insert was
timed alone. Nothing in any policy removes the spikes; only incremental
resizing, which no table here implements, would.

* **Linear probing at 17/20 is a mistake.** Misses cost 2.7-5 times
  their cost at 1/2 (181-360 ns against 68-72) for 40 % less memory.
* **Robin Hood is what makes 17/20 usable:** misses of 105-135 ns at 28
  bytes per entry, paid for with 1.6-1.7 times the insert cost.
* **Between 1/2 and 7/10 the trade is modest:** 30 % less memory at peak
  for 13-35 % slower lookups on average. 7/10, the default here, is a
  reasonable middle; nothing measured argues for changing it.
* **Policy matters less than the compiler work.**
  * The spread between sensible policies (1/2 and 7/10) is 10-35 % on
    lookups and nothing on builds.
  * The compiler work cut `lpa`'s operations by 16-49 %, chaining's builds
    by 2-15 %.
  * Value-semantics copies made `lp`'s builds 44 times `lpa`'s in
    instructions, about 100 times in time (1,024 keys, baseline).
  * The probe statistics also show that the table state is never the
    problem at loads up to 7/10. The time goes to the work per probe.

### Memory

Allocated bytes per entry, native, from the allocation counters
(`tools/memory.tcl`). The column "peak" is the exact peak of live bytes,
measured under GC stress.

| table | presized: allocated / peak | growing: allocated / peak |
|---|---|---|
| `lpa`, `rh`, `ht0` | 48.2 / 40.2 | 97.6 / 64.7 |
| `cd` | 40.3 / 8.1 | 56.8 / 40.4 |
| `chain` | 99.2 / 80.3 | 142.8 / 80.7 |
| `chain0` (fixed capacity) | 146 / 83 | -- |
| `listmap` | 8,296 / 24 | (quadratic: every append copies) |

The figures are at 1,024 Int entries.

* Open addressing at load 0.5-0.7 costs three words per slot: 48 bytes
  per entry.
* The compact dict needs only one index word per slot plus dense entries,
  about 40 bytes, and keeps insertion order.
* Chaining pays a List and an Entry struct per key: about 100 bytes.
* Growth allocates the next table while the old one is live; the old one
  becomes garbage at once, so the peak is about 1.5 times the presized
  size.

The merged prototypes change none of this: the array header grows from
32 to 48 bytes, which adds less than 0.6 bytes per entry.

### Generated code

`tools/nirstats.tcl` lists, per specialized function of each table,
three things:
* its machine-code size;
* its NIR operations of interest (array reads and writes, proven or
  checked; `imod`; `hash`; `veq`/`ieq`; calls);
* the facts native lowering derived: `may_error`, `may_gc`, safepoints.

`results/nir-*.txt` has every table on both trees. What it shows:

* **The modular `lpa` gets no proven access on either tree.**
  * Its index is computed by `home` and `next_slot` and read in
    `find_from`, and facts do not cross a call (CP-4).
  * Its NIR operations are the same on both trees. The merged tree
    changes how each one is lowered (inline `at`/`set`, the `imod` fast
    path, an allocation-free `hash`), not which ones there are.
* **The proof-shaped `lpmask` gets every access proven on the merged
  tree.**
  * Every array access is `mutarraygetproven` or `mutarraysetproven`.
  * Eight of its functions become `may_error=false` (`size`, `full?`,
    `store`, `counted`, `moved`, `shifted`, `empty_from`, `find_empty`),
    and its machine code shrinks by 2 % (30.8 to 30.2 KB) despite the
    inline paths.
* **No lookup is `may_error=false` on either tree.** `get`, `has?` and
  `find_from` keep their error edges because `hash` and generic equality
  (`veq`) can fail (on a function value, for instance), whatever the
  bounds proofs show (CO-4).
* **Almost everything stays `may_gc=true`.**
  * A write to a shared backing detaches, which allocates.
  * The tagged `mod`'s slow path allocates a BigInt.
  * So the probe loops keep their safepoints. That costs little in time
    here (the safepoint is a load and a branch), but it keeps
    `may_gc=false` loops, and what they would allow, out of reach.
* **Inline paths cost code.** On the merged tree the open-addressing
  programs other than `lpmask` (-2 %) and `cd` (+4 %) are 7-13 % larger in
  machine code (`lpa` 27.2 to 29.5 KB, `lpmono` 29.1 to 33.0 KB), the
  chaining and list ones 1-4 %. The inline `at`, `set` and `capacity` and
  the `imod` fast path each add a few dozen bytes per use. Each size is
  the whole program's, driver included.

**The review fixes changed none of this.** The census of the merged tree
before the fixes and after them (`results/nir-fixed.txt`) is identical,
byte for byte: every table function has the same operations, facts and
machine-code size. The fixes' precision losses ("The adversarial review")
are in shapes these tables do not have.

### Backends

Small sizes only on the Tcl backends. Per operation, Int keys, 256
entries, baseline compiler:

| table | op | interp | compile | cranelift-generic | cranelift |
|---|---|---:|---:|---:|---:|
| `lpa` | build, per insert | 5.25 ms | 474 µs | 248 ns | 261 ns |
| `lpa` | hit | 1.45 ms | 86.6 µs | 63 ns | 69 ns |
| `lpa` | miss | 2.03 ms | 100 µs | 122 ns | 101 ns |
| `cd` | build, per insert | 4.21 ms | 277 µs | 193 ns | 192 ns |
| `cd` | hit | 1.59 ms | 144 µs | 60 ns | 63 ns |
| `chain` | build, per insert | 3.49 ms | 264 µs | 472 ns | 482 ns |
| `chain` | hit | 1.53 ms | 78.4 µs | 63 ns | 61 ns |
| `listmap` | build, per insert | 20.2 ms | 1.16 ms | 675 ns | 656 ns |
| `listmap` | hit | 20.0 ms | 852 µs | 219 ns | 216 ns |

(`results/backends-baseline.tsv`, first method; the cranelift column is
the sizes phase's: builds first method, lookups as passes.)

* **cranelift-generic runs at cranelift's speed** (median ratio 1.0).
  * It was timed at 16 and 256 entries only: six tables, Int and String
    keys, the baseline tree, the first timing method.
  * 55 of its 71 cells are within 20 % of cranelift. Single cells range
    0.25-2.5, from that method's noise.
  * The tables are written over `any`-typed arrays, so specialization has
    little to specialize.
  * Where typing helps, it comes from typed arrays in the source (`lpint`,
    `lpstr`, CO-3), not from the specializer.
* **The Tcl backends are about 1,500 times (compile) and 22,000 times
  (interp) slower** per operation: the medians over every cell. The cells
  range 150-4,300 and 3,500-100,000 times, the table above 550-3,900 and
  7,200-93,000.
  * Their ranking of the tables is mostly cranelift's.
  * Chaining is relatively cheaper on them: its buckets are Tcl lists.
  * The array-based tables pay `core::mutarray`'s store indirection on
    every slot access.
  * They are correctness backends here: the fuzzer runs every trace on
    them.

## Algorithm comparison: what wins, and where

The numbers are medium-regime figures from the merged tree. The rankings
hold on the baseline too, except where a bullet says otherwise.

* **Open addressing with linear probing and stored hashes (`lpa`,
  `lpmono`, `lpmask`) is the best general mutable table Botlish can
  express.**
  * It has the cheapest builds: 118-149 ns per growing insert, 61-71
    presized.
  * Its hits are the fastest or within 10 % of the fastest at every size
    above a handful of entries: 40-46 ns.
  * It needs no allocation per entry.
  * Deletion by backward shift keeps it free of tombstones, so probe
    lengths stay those of the live entries.
  * Its weak spot is misses (58-75 ns): about 4 probes at load 0.7.
* **Robin Hood (`rh`) buys a bounded miss tail for 30-45 % more insert
  work.**
  * Mean lookups are within 15 % of `lpa`'s.
  * Its miss p99 is 7 probes against 41 at load 0.7, and 6-8 against
    40-41 at load 0.85.
  * Every insert that displaces pays for it: 201 ns per growing insert
    against 149.
  * Choose it where miss latency must be bounded, or to run at a high
    load factor ("Resize policy"). Not by default.
* **The compact dict (`cd`) is the choice when iteration order matters,
  and it is the most compact.**
  * Entries sit dense in insertion order, beside an index array of entry
    numbers.
  * Growth rehashes only that index: 138 ns per growing insert. It was
    the cheapest growing build on the baseline.
  * It needs the least memory: 40 bytes per entry presized, 57 grown,
    against 48 and 98 for `lpa`.
  * A lookup pays one more indirection (index, then entry): 15-25 % on
    hits.
  * It has no removal in this experiment. A real one needs either
    tombstones in the entry vectors or a compaction.
  * It won the BFS workload, which is insert-heavy.
* **Chaining (`chain`) wins misses and adversarial collisions, and loses
  construction and memory.**
  * Every insert allocates an Entry and a new bucket List. Builds cost
    three times open addressing's (475 ns against 149), memory about 100
    bytes per entry, and the String-heavy frequency count 7 times
    `lpa`'s time.
  * A miss usually finds an empty or one-entry bucket: 56 ns against 75
    for Int keys, 43 against 56 for String keys. Rust shows the same.
  * When every key collides, chaining degrades least.
* **A sorted array (`sorted`) is not competitive as a lookup structure.**
  * Binary search costs 1.5-3.5 times a hash lookup at medium sizes:
    about 10 generic comparisons with unpredictable branches.
  * Insertion is O(n), and bulk construction is a sort.
  * What it offers that a hash table does not is order: ordered
    iteration, range queries, a deterministic layout. The experiment did
    not measure those uses.
* **A list (`listmap`) wins for tiny maps.**
  * Up to about 8 entries its hits cost 14 ns.
  * For short-lived maps it wins only at one entry with one lookup, and
    up to 16 Int entries with 1,000 lookups (up to 2 and 32 on the
    baseline; "Short-lived tables").
  * Beyond that its cost is linear: 570 ns at medium sizes.
* **The two existing prototypes:**
  * `chain0`, the 15-puzzle visited set, never grows, so its buckets
    lengthen with the entry count: 0.6-1.8 µs per Int lookup at 4,096 to
    16,384 keys. Its shape is not one to build on.
  * `ht0` (`examples/stdlib/hashtable.bot`) gained the most ns on Int
    hits from the compiler work. Its hits went from 121 to 63 ns (1.4
    times `lpa`), and its controls array gives it cheap misses (60 ns).
    It cannot be lowered by cranelift-generic at all (CG-3).

The algorithmic differences among the good tables (`lpa`, `lpmono`,
`lpmask`, `rh`, `cd`) are 10-45 %, depending on the operation. The
difference between any of them and the same algorithm in Rust is 1.1-6
times on the merged tree, so the algorithm is not where the remaining
gap is ("What remains").

## Abstraction-cost experiments

Each experiment below holds the algorithm fixed and changes only how the
source is written. Any difference is therefore the price of a source
organization, which a compiler could in principle remove. Instruction
counts are exact (callgrind, `results/instructions.tsv`); the timings are
the merged-tree sweep's.

### Modular, inlined, selective (organizations A, B, C)

`lpa` (A) is the table as a library author writes it:
* small functions: `home`, `next_slot`, `find`/`find_from`,
  `find_empty`/`empty_from`, `store`, `grown`;
* every array access through `std::mutable_array::at`;
* every index reduced by `mod`.

`lpmono` (B) is the same algorithm with every helper inlined by hand:
* the capacity read once per operation;
* the lookup's two walks fused into one.

`lpfact` (C) keeps A's helpers except the two that cost a call per probe
step.

Instructions per operation, 1,024 keys:

| organization | Int hit: baseline / merged | Int build: baseline / merged | String hit: baseline / merged |
|---|---:|---:|---:|
| A, `lpa` | 881 / 498 | 2,564 / 1,345 | 825 / 664 |
| B, `lpmono` | 779 / 391 | 2,168 / 1,044 | 720 / 557 |
| C, `lpfact` | 876 / 488 | 2,522 / 1,281 | 814 / 647 |
| B against A | -12 % / **-21 %** | -15 % / **-22 %** | -13 % / -16 % |
| C against A | -1 % / -2 % | -2 % / -5 % | -1 % / -3 % |

In time, ns per operation, medium regime:

| organization | Int hit: baseline / merged | Int miss: baseline / merged | Int growing build: baseline / merged | String hit: baseline / merged |
|---|---:|---:|---:|---:|
| A, `lpa` | 79.6 / 45.5 | 88.4 / 74.6 | 240 / 149 | 80.6 / 59.2 |
| B, `lpmono` | 67.3 / 41.1 | 84.0 / 58.4 | 209 / 118 | 63.6 / 54.5 |
| C, `lpfact` | 68.3 / 44.7 | 116 / 63.2 | 233 / 146 | 74.2 / 62.2 |

* **On the baseline, hand-inlining saves 12-15 %.** Removing only the
  per-step calls (C) saves almost nothing. B's gain comes from what
  inlining *enables*: the capacity read once instead of in every helper,
  and one fused walk instead of a slot search followed by a read. That is
  common-subexpression elimination across calls (CO-1, CO-2), not call
  overhead.
* **After the compiler work, modularity costs relatively more**
  (21-22 %). The merged prototypes removed fixed costs, such as the
  hash's allocation, the array helper calls and `mod`'s helper, which
  every organization paid alike. They did not remove what B's hand work
  removes. The remaining A-B gap is CO-1 and CO-2: general inlining of
  small non-leaf functions and CSE of pure loads across them. It is the
  largest single item a compiler could still recover from the modular
  source.
* **Selective factoring (C) is not a useful middle.** Keeping the helpers
  but splitting out the per-step ones pays nearly all of A's cost.

### Proof-shaped source: `lpmask`

`lpmask` is `lpa` written so that every access is provable today:
* every index is reduced at the access by its own array,
  `a.at(bit_and(i, a.capacity() - 1))`;
* a guard `if a.capacity() < 1` precedes each walk.

On the merged tree all of its accesses are proven (no `IndexNotFound`
path, `*proven` opcodes in the NIR). On the baseline none are.

| | Int hit | Int build | String hit | Int hit, ns (ladder A2) |
|---|---:|---:|---:|---:|
| `lpa`, baseline | 881 | 2,564 | 825 | 69.3 |
| `lpmask`, baseline | 980 | 3,063 | 929 | 80.1 |
| `lpa`, merged | 498 | 1,345 | 664 | 41.6 |
| `lpmask`, merged | 489 | 1,340 | 656 | 41.5 |

* On the baseline the extra reductions and capacity reads cost 11-19 %.
* On the merged tree they are free: `lpmask` and `lpa` execute the same
  number of instructions on hits and builds, and `lpmask` 6-12 % fewer on
  misses.
* In time (ladder A2, 1,024 keys), `lpmask` ties `lpa` on Int hits, is
  7 % faster on String hits and 16-30 % faster on misses. Most of the miss
  gain is not the proofs': on the tree with inline array access alone,
  where none of `lpmask`'s accesses is proven, its misses are already
  11-15 % faster than `lpa`'s. It reduces each probe index with
  `bit_and`, where `lpa`'s `mod` is still a helper call on that tree.
* So the proofs pay for a proof-shaped source and nothing more. The bounds
  checks they remove were never the expensive part of a lookup. With the
  inline array access (CG-1), a checked read is a compare and a branch
  that is always predicted.
* **The bounds proofs (CP-1..CP-3) are a soundness and code-size
  improvement for tables, not a speed one.** Writing the proof shape in
  library code is not worth recommending. Facts that cross calls (CP-4)
  and a struct's invariants (CP-5) would let the modular source get the
  same proofs without changing shape.

### Typed against generic: `lpint`, `lpstr`

The typed variants differ from `lpa` only in their arrays' element types.
Instructions per hit at 1,024 keys, baseline:

| table | Int keys | String keys |
|---|---:|---:|
| `lpa` | 881 | 825 |
| `lpint` | 876 | -- |
| `lpstr` | -- | 668 |

* Typing Int keys saves nothing: `veq` on two small Ints takes a fast path.
* Typing String keys saves 19 %: `streq` replaces generic equality.
* A generic table instantiated at a String key type does not get this
  today. The specializer keys on the parameters' types, not on the
  element types of the arrays a struct field holds (CO-3).

### Value-semantics workarounds: `lp`, `lpc`, `lpa`

They are the same algorithm. "Value semantics", below, has the copy
counts. In instructions per insert at 1,024 keys on the baseline:

| table | Int build | Int replace |
|---|---:|---:|
| `lp` | 112,862 | 29,716 |
| `lpc` | 3,491 | 1,967 |
| `lpa` | 2,564 | 914 |

* `lp` is 44 times `lpa` on a build: every insert copies the arrays.
* `lpc`, the rebuild done "correctly", copies nothing but still pays
  36 % on a build and twice on a replace. Every update allocates a new
  `Table` struct, and each mutating helper hands its `Slots` back through
  its result. That is the price of keeping the count in an
  immutable field. `lpa` keeps it in a one-slot `MutableArray[int]`
  instead: an idiom, not an obvious way to write a count.
* The difference between natural and copy-free code is the experiment's
  largest effect. It is fixed by compiler precision (VS-1/VS-2 merged;
  VS-3 and VS-7 open), not by a different algorithm.

### Value semantics: the cost that dwarfs every other

A MutableArray or MutableVector is a value over a copy-on-write backing
(MUTABLE-ARRAY.md). The compiler writes out the logical copies that a
program's value semantics need (`hir::mutvec::Elaborate`,
`mutable_vector#share`). The next write through a header whose backing is
shared then copies the whole array (the runtime's detach). Two properties
make this the experiment's largest effect.

1. **A dead copy still forces the detach.** A copy's header keeps its `Rc`
   on the backing until the collector frees the header. So "copy, drop the
   copy, write the original" copies every slot (VS-4). Any copy of a table
   that is written later is a full copy of every array it shares.
2. **The elaboration is conservative in ways that ordinary table code
   triggers.**
   * Last use is decided per binding, not per field path (VS-1).
   * A struct literal that holds a parameter is not fresh (VS-2).
   * A consumed argument that a later argument reads is copied (VS-3).
   * A reader whose local walk captures the table's arrays is not
     observed-only (VS-7).

The counts below come from the native allocation counters
(`tools/copies.tcl`), so they are deterministic. The workload is 1,024 Int
keys followed by 2,000 replacements:

| table | build: shares / detaches / elements copied | replace: shares / detaches / elements copied |
|---|---:|---:|
| `lp`, as one would first write it | 13,488 / 7,344 / 9,223,752 | 25,488 / 9,344 / 13,319,752 |
| `lpc` (arrays in one sub-struct, count read first) | 0 / 0 / 0 | 0 / 0 / 0 |
| `lpa` (count in a one-slot MutableArray, no rebuild, top-level walks) | 0 / 0 / 0 | 0 / 0 / 0 |

`lp` is O(capacity) per insert, which makes every build quadratic:
2.8 us per insert at 16 entries and 23.3 us at 1,024 (baseline sweep),
against 0.2-0.3 us for `lpa`.

`tools/attribution.tcl` takes `lp` apart. It applies each trigger's
source workaround separately and together, on the baseline and on the tree
with the VS-1 and VS-2 prototypes. The table shows build shares / detaches;
HASH-TABLE-COMPILER-PRESSURE.md VS-7 has the full table:

| `lp` variant | baseline | VS-1 + VS-2 prototypes |
|---|---:|---:|
| as written | 13,488 / 7,344 | 7,368 / 7,344 |
| VS-3 worked around (the reading argument bound first) | 10,648 / 4,496 | 4,504 / 4,480 |
| VS-7 worked around (walks as top-level functions taking the table) | 10,416 / 7,344 | 4,296 / 4,296 |
| both worked around | 6,144 / 3,072 | **0 / 0** |

So the natural `lp` is copy-free only when all three of VS-1, VS-3 and VS-7
are addressed. The prototypes address VS-1 in the compiler. VS-3 and VS-7
remain source rules, and both are cheap to moderate candidates for the same
analysis.

The same effect dominates the mixed workloads. `drivers/memo.bot` is a
memoized Collatz recursion that returns `Steps {memo: memo, count: c}`.
At N = 1,000 it makes 8,908 shares and 8,872 detaches and copies
15,606,418 elements; at N = 10,000 it takes 2.7 s (`lpa`). `drivers/memo2.bot`
is the same algorithm written as a read-only walk followed by a threaded
insert loop: 0 copies and 12 ms. The Rust reference takes 2.3 ms. With VS-2
(commit `6c76947`), the natural memo makes 0 shares and 0 detaches, and its
time is in the "Mixed workloads" table above.

Nothing reports these copies: no diagnostic, no warning. Only the HIR
text (`mutable_vector#share`), the NIR (`mvshare`) and the allocation
counters show them (VS-6). Every table in the experiment except `lp` was
written to the rules of SPEC.md section 7 and audited at 0 copies.

The prototype that removes VS-1 and VS-2 also found and fixed **BUG-1**, a
miscompilation older than this experiment: an argument handed over by
reference saw a later argument's write. For example, `obs2(v, grow1(v,
5))` gave 33, not 23, on every backend.

## Compiler deficiencies

[HASH-TABLE-COMPILER-PRESSURE.md](HASH-TABLE-COMPILER-PRESSURE.md) is the
catalogue: 32 entries, each with its minimal source, the fact or
optimization it deserves, the HIR or NIR evidence, the consequence, how far
it reaches beyond tables, a candidate fix and, where prototyped, the
result.

| class | entries | prototyped and merged | the one that matters most |
|---|---|---|---|
| avoidable allocation (value semantics) | VS-1..VS-7, BUG-1 | VS-1, VS-2, BUG-1 | VS-1/VS-2. A table's natural update copied every array: O(n) per insert, 44 times the instructions of a copy-free build, and the naturally written memo was 1,199 times Rust. VS-3 and VS-7 still make the first-draft `lp` copy. |
| missing proof | CP-1..CP-8 | CP-1, CP-2, CP-3 | CP-4: facts do not cross a call. It is why the modular `lpa` has no proven access even on the merged tree. |
| codegen deficiency | CG-1..CG-3, BUG-2 | CG-1, CG-2, BUG-2 | CG-1. Every array access was a helper call. |
| runtime helper overhead | RO-1 | RO-1 | `hash` allocated for every Int and every struct |
| missing specialization or optimization | CO-1..CO-6 | CO-1 in part (a `mod` leaf) | CO-1/CO-2, inlining and CSE of small helpers: the remaining 21 % between modular and hand-inlined source |
| compile cost and limits | CO-7, CO-8 | none | CO-7. Lowering a large List literal is quadratic: constant tables of 15,000+ elements take minutes or run out of memory. |
| runtime pressure | RT-1..RT-3 | RT-1, as a patch only (`patches/probe-primitive.patch`) | RT-3, the keyed hash: semantic, not a speed problem |

Three deficiencies were bugs, not missed optimizations, and are fixed:
* **BUG-1**, a miscompilation older than the experiment: an argument
  handed over by reference saw a later argument's write. It gave a wrong
  value on every backend.
* **BUG-2**, a front-end abort: Tcl 9.0.1's `max()` crashes on a BigInt
  computed in the same expression, so any divisor beyond 64 bits aborted
  compilation.
* A GC-rooting bug in one of CG-2's own Rust unit tests. arm64 CI found
  it.

Two of the brief's candidate facts have no entry of their own. Loop-carried
facts are CP-4's case: every probe walk is a self-recursive function, so
`0 <= i < capacity` does not pass to the next step. The walks keep no step
count (the load bound ends them), so `probes <= capacity` was not examined.
Constant thresholds are preserved: `load_num`, `load_den` and `min_slots`
are inlined and leave no function in the NIR census (`results/nir-*.txt`).

Three more pre-existing problems, outside the compiler, are recorded at
the catalogue's end: two stale or crashing fuzzers, and the `lp` driver
that had stopped compiling.

## Compiler experiments

Five general prototypes were built, validated and merged into this branch.
Each one is a theorem or a lowering rule that names no table, module,
function or constant. Each has semantic tests, a fuzzer (new or extended),
mutants and a workload unrelated to hash tables.

| prototype | entries | commits | what it is | tests | fuzzing | mutants | unrelated workload |
|---|---|---|---|---|---|---|---|
| per-path last use, literal demand, by-reference arguments | VS-1, VS-2, BUG-1 | `9c79b28` `720c826` `6c76947` | `hir/mutvec.tcl`: a read-out moves at its *path's* last use; a struct literal in an exclusive position demands its fields; an argument handed over by reference is copied when a later argument writes it | mutable-vector 61/61 (new: by-reference, per-path, literal-demand semantics and copies), mutable-array 33/33, mutable-array-type, affine, coroutines, contexts, struct-destructuring | vector fuzzer: a new PATHS family; seeds 1-2 (60 programs each) and GC stress, array fuzzer seeds 1-3, 0 disagreements | 17 new (4 by-reference, 11 path, 2 literal), all 62 vector and 31 array mutants killed | a BFS whose state struct is rebuilt per visit: N = 100 313 ms -> 1.1 ms, N = 200 4.48 s -> 13.6 ms; 5 examples and 21 golden suites: identical copies |
| allocation-free hash | RO-1 | `4bc7c94` | `rt_hash` writes decimal text on the stack and borrows struct shapes; every hash value is unchanged | 19 hashing-related test files; `hash-parity-kinds-1` (87 values at the representation's edges, four backends) | hash-table fuzz 432 checks | a planted chunk-padding mutant fails the parity test | valgrind: 0 heap allocations per hash (Ints up to 128 bits, chars, structs) |
| inline MutableArray access | CG-1 | `0bd45ff` `11fe677` `243455f` | header words LEN, PTR, UNIQUE; inline `capacity`, `at`, `set` with cold helper paths | 10 MutableArray/vector/affine/hashtable test files, normally and under GC stress; stub linker; Rust unit tests under GC stress | array fuzzer seeds 1, 2, 3, 17, 41 and GC stress, 0 disagreements; hash-table fuzz 540 checks | 33/33 array mutants, 2 new (`share-keeps-unique-native`, `detach-keeps-stale-pointer-native`) | 1M-iteration loops: `at` 6.6 -> 1.6 ns, `set` 9.3 -> 1.3 ns, read-modify-write 17.4 -> 2.3 ns |
| raw, masked, inline `mod` | CG-2, CO-1 | `71e4be1` `3b9f42c` `3c2bfc4` `2b6a055` | `rimod`/`rimodtotal` for small operands, a mask for +-2^k, an inline tagged fast path, tiny-leaf inlining of a `mod` with a nonzero divisor | `native-mod-lowering.test` (new), 24 native test files through `tests/local.tcl`, GC stress | a new differential fuzzer `audit/mod-lowering/` (380 programs, four backends and three option variants, 0 disagreements) | planted mask and zero-check bugs caught; all 79 existing mutant edits of the touched files still apply | `bench/uri-steady.bot` -1.9 % instructions; stdlib/web.bot's `b.mod(16)` a mask; hashtable.bot's probes no longer safepoints |
| bounds theorems | CP-1, CP-2, CP-3 | `e0b7b9c` `a1e281d` `b1144fe` `a137676` `58d0212` | an index reduced by its container's size; a field path keyed by its path; a guard on a computed local; a known size below a proven minimum is a contradiction | proven-bounds 42/42 (18 new), 16 golden ports, stdlib-namespaces, crosscheck, proof-loop-intervals, cardinality, exact-value, static-compile, static-economics, compilerpedia | a new soundness fuzzer `audit/bounds-proofs/` (every rejected unsound shape has a failing witness), static-decisions fuzz seeds 1-2 | 22/22 new mutants | the 2048 workload's spawn read can be written as a proven `at`, and so can ring buffers; corpus verdicts unchanged |

Two integration fixups followed the merge:
* `b21cc74`: a test of CG-2's built a `CompileOptions` literal without
  CG-1's new field.
* `19bd2ff` (**BUG-2**): `hir::range::Mod` aborted the front end, through a
  Tcl 9.0.1 `max()` crash, for any divisor beyond 64 bits.

**Workloads unrelated to tables, baseline against merged** (`plan2.sh`,
`plan4.sh`; `results/unrelated-*.txt`, `results/corpus-again.txt`):

| workload | baseline | merged |
|---|---:|---:|
| the 2048 engine (`bench/2048.tcl`), cranelift | 21.41 µs per move, 168.91 allocations per move | 21.48 µs, 168.91 |
| the same, cranelift-generic | 23.04 µs | 22.35 µs |
| the algorithm corpus (`bench/corpus.tcl`, 19 cases, best of two alternating rounds) | | every case within ±7 % |
| `examples/stdlib/hashtable.bot` (`bench/hashtable.tcl`): hit at 10,000 entries | 0.31 µs | 0.17 µs |
| the same: presized construction of 10,000 entries | 1.27 ms | 0.70 ms |

The corpus's machine code is identical on both trees, except where the
inline MutableArray paths add code: `csv_geometric` 2.6 % larger,
`csv_chunked` 9 %. Single runs of the corpus differ by up to 2 times from
round to round on either tree, so only the alternating rounds are
reported.

The merged tree passed the full local suite, the Rust unit tests
(246 + 44) and every implementation's fuzzing on four backends. An
adversarial review then tried to break each prototype with targeted
programs, and found ten distinct soundness bugs, five of them older than
the prototypes ("The adversarial review, and what it found"). After their
fixes, the tree passes the local suite narrowed to the areas the fixes
touch (663 Tcl tests on interp, 662 on compile, and 18 golden suites with
1,305 tests on each of four backends), CI's full x86-64 suite, and the same
fuzzing again (1,288 checks, 0 failures).

### What each prototype changes

Each prototype is measured alone, on the baseline tree plus that
prototype, and the merged tree has all of them. The value-semantics
prototype is left out of these tables: `lpa` and `lpmask` copy nothing
on any tree, so it changes no count or time here. Its effect is the
memo workload's and the BFS rebuild's ("Value semantics", "Mixed
workloads").

**Instructions per operation, 1,024 keys** (callgrind; repeated runs
agree within about 5 %):

| table, keys, op | baseline | + RO-1 hash | + CG-1 inline arrays | + CG-2 mod | + CP-1..3 proofs | merged | Rust `lp` |
|---|---:|---:|---:|---:|---:|---:|---:|
| `lpa`, Int, hit | 881 | 654 | 747 | 855 | 878 | 498 | 144 |
| `lpa`, Int, miss | 1,087 | 825 | 968 | 1,041 | 1,080 | 668 | 351 |
| `lpa`, Int, build | 2,564 | 2,343 | 1,647 | 2,484 | 2,558 | 1,345 | 398 |
| `lpa`, String, hit | 825 | 830 | 691 | 795 | 821 | 664 | 130 |
| `lpa`, Point, hit | 2,903 | 1,551 | 2,763 | 2,865 | 2,907 | 1,375 | 326 |
| `lpmask`, Int, hit | 980 | 774 | 748 | 975 | 944 | 489 | |
| `lpmask`, Int, build | 3,063 | 2,847 | 1,685 | 3,066 | 2,818 | 1,340 | |

**ns per operation, 1,024 keys**, median of three rounds that alternate
the trees (ladder A2, builds and lookups both timed as passes):

| table, keys, op | baseline | + RO-1 | + CG-1 | + CG-2 | + CP-1..3 | merged | Rust `lp` |
|---|---:|---:|---:|---:|---:|---:|---:|
| `lpa`, Int, hit | 69.3 | 51.9 | 59.7 | 68.2 | 69.7 | 41.6 | 10.7 |
| `lpa`, Int, miss | 91.4 | 75.9 | 81.7 | 91.7 | 89.2 | 65.7 | 43.5 |
| `lpa`, Int, build | 252 | 225 | 176 | 234 | 258 | 146 | 24.5 |
| `lpa`, Int, presized | 122 | 106 | 86.9 | 123 | 126 | 71.9 | 14.9 |
| `lpa`, String, hit | 70.7 | 70.9 | 58.9 | 71.4 | 68.9 | 55.6 | 13.5 |
| `lpa`, String, build | 227 | 233 | 154 | 220 | 234 | 172 | 77.8 |
| `lpa`, Point, hit | 248 | 131 | 244 | 253 | 244 | 124 | 33.4 |
| `lpa`, Point, build | 419 | 299 | 341 | 403 | 428 | 234 | 42.5 |
| `lpmask`, Int, hit | 80.1 | 65.8 | 61.0 | 77.9 | 80.8 | 41.5 | 10.7 |
| `lpmask`, String, miss | 69.0 | 71.2 | 47.6 | 68.8 | 69.2 | 44.2 | 22.9 |

`results/ladder-a2.tsv` also has 16,384 keys, replace and drop.

* **The allocation-free hash (RO-1) is the largest single step for Int
  and struct keys.**
  * It cuts an Int hit by a quarter and halves a `Point` hit (248 to
    131 ns).
  * It does nothing for Strings, whose hash never allocated.
* **Inline array access (CG-1) is the largest for builds and for
  Strings,** where the array accesses are a bigger share: 252 to 176 ns
  per growing insert, 70.7 to 58.9 ns per String hit.
* **Raw `mod` (CG-2) alone gains 1-7 %.** Its `rimod` and mask forms
  apply only where the operands are proven small. In `lpa` the divisor
  is a capacity read from an array, so most of its `mod`s keep the
  tagged form with the new inline fast path.
* **The proofs (CP-1..3) alone change nothing measurable for `lpa`,**
  whose accesses they do not reach (CP-4). For `lpmask`, which they do
  reach, they save 8 % of the instructions on a build. On a hit they save
  4 %, within the counts' noise.
* **The steps add up.** The merged tree saves almost exactly the sum of
  the separate steps' savings:

  | | separate steps, summed | merged tree |
  |---|---:|---:|
  | Int hit, instructions | 390 | 383 |
  | Int build, instructions | 1,224 | 1,219 |
  | Point hit, instructions | 1,526 | 1,528 |
  | Int hit, ns | 27.7 | 27.7 |

  The prototypes remove independent costs, and none depends on another
  to pay off.

## What remains: the merged tree against Rust

Where a lookup's instructions go on the merged tree, 1,024 keys, against
the Rust reference running the same algorithm with the same hash
(callgrind self costs; `results/profiles.txt`, `results/instructions.tsv`):

| keys, op | table | total | generated code | runtime `hash` | runtime equality | allocation | Rust `lp` | Rust `std` |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| Int, hit | `lpa` | 501 | 325 | 164 | -- | 1 | 144 | 106 |
| | `lpmono` | 392 | 219 | 164 | -- | 0 | | |
| Int, miss | `lpa` | 674 | 369 | 289 | -- | 2 | 351 | 104 |
| | `lpmono` | 526 | 214 | 289 | -- | 0 | | |
| Int, build (per insert) | `lpa` | 1,338 | 1,007 | 164 | -- | 92 | 398 | 508 |
| | `lpmono` | 1,020 | 695 | 164 | -- | 95 | | |
| String, hit | `lpa` | 669 | 335 | 233 | 66 | 2 | 130 | 168 |
| | `lpmono` | 559 | 226 | 233 | 66 | 4 | | |
| String, miss | `lpmono` | 386 | 229 | 144 | -- | 0 | 103 | 161 |
| Point, hit | `lpa` | 1,371 | 360 | 810 | 181 | 13 | 326 | 127 |
| | `lpmono` | 1,248 | 236 | 810 | 181 | 13 | | |

(The remaining instructions are 7-33 per lookup and 66-75 per insert:
about 11 per operation are the driver's, and the rest are runtime
functions no column counts, such as `memcpy` and `memcmp`.)

The gap splits into three parts, none of them algorithmic.

1. **Generated code: two-thirds of an Int lookup, half of a String one.**
   * The table's own code is 214-369 instructions per lookup, where
     Rust's whole lookup, hash included, is 103-351.
   * What is left in it, by the abstraction-cost experiments:
     * calls between small functions and the loads they repeat (CO-1,
       CO-2): the 31-42 % that hand-inlining (`lpmono`) removes;
     * a call to generic equality per probe (CO-3);
     * the safepoint of every probe loop (`may_gc`);
     * tag checks on untyped slots.
   * Class: missing specialization and optimization. The fixes are
     general compiler work.
2. **The runtime `hash`: a third of an Int or String lookup, and
   two-thirds of a struct one.**
   * For a small Int, 164 instructions: about 60 to format the decimal
     text, about 25 for FNV over five bytes, and the rest the call and the
     dispatch on the value's kind (the unhashable check, the kind tag).
   * The Rust reference runs the same FNV over the same text, statically
     typed, in its whole 144-instruction lookup.
   * For a struct key, 810 instructions: the struct's shape, a kind
     dispatch per field, and each field's text.
   * Class: runtime primitive overhead (the generic dispatch, which a
     hash specialized by the key's static type would skip: CO-3, CO-6),
     and the hash's definition (decimal text: a language decision, RT-3's
     companion).
3. **Equality and allocation.**
   * Generic equality is 66 instructions on a String hit and 181 on a
     struct hit (CO-3, CO-6).
   * Allocation is near zero on lookups (RO-1). On builds it is 90
     instructions per insert: growth's new arrays.

**What is not left: the algorithm, and the proofs.**
* The Rust reference's probe sequences are Botlish's, slot for slot.
* Bounds proofs change 2 % of a lookup (`lpmask`).

**In time, what remains is 1.1-6 times Rust's same algorithm.**
* Lookups: 3.8-4.4 times on hits, 1.3-2.7 times on misses.
* Builds: 4-6 times for Int keys, 1.1-1.9 times for String keys.
* Mixed workloads: 2-5 times.

The instruction ratios are similar: 1.5-5.4 on lookups, lowest on Int
misses, where Rust's linear probing walks as far as Botlish's.

## Runtime experiments

The brief asks for runtime primitives to be tested only after the
compiler work. RT-1 was therefore measured twice:
* on the baseline compiler with the primitive added (`probe`,
  `patches/probe-primitive.patch`);
* on the merged tree with the primitive added (`comboprobe`).

Both rounds compare it with the same table written in Botlish.

**RT-1, the probe primitive.**
`std::mutable_array::probe_linear(hashes, keys, h, key) -> int` runs one
whole linear-probing walk in Rust and returns the slot. `lpp` is `lpa`
with its probe walks replaced by it. Everything else stays Botlish: the
layout, the policy, growth and deletion.

ns per operation, 1,024 keys, median of three rounds that alternate the
two trees (ladder C2; builds and lookups timed as passes):

| keys | op | `lpa`, baseline | `lpp`, baseline | `lpa`, merged | `lpmask`, merged | `lpp`, merged |
|---|---|---:|---:|---:|---:|---:|
| Int | hit | 65.9 | 57.1 | 38.6 | 39.9 | 37.5 |
| Int | miss | 87.5 | 72.6 | 66.3 | 54.0 | 52.1 |
| Int | build, per insert | 244 | 207 | 150 | 134 | 135 |
| Int | presized, per insert | 119 | 117 | 71.5 | 65.8 | 62.1 |
| String | hit | 70.1 | 54.0 | 55.3 | 51.5 | 46.5 |
| String | miss | 69.9 | 41.5 | 56.0 | 44.6 | 40.3 |
| String | build, per insert | 216 | 198 | 151 | 142 | 128 |
| Point | hit | 240 | 221 | 121 | 116 | 104 |
| Point | miss | 234 | 215 | 116 | 104 | 103 |

`results/ladder-c2.tsv` also has 16,384 keys, replace and drop.

Instructions per operation, 1,024 keys (callgrind):

| keys | op | `lpa`, baseline | `lpp`, baseline | `lpa`, merged | `lpmask`, merged | `lpp`, merged |
|---|---|---:|---:|---:|---:|---:|
| Int | hit | 881 | 768 | 504 | 496 | 492 |
| Int | miss | 1,082 | 823 | 671 | 620 | 543 |
| Int | build | 2,568 | 2,182 | 1,341 | 1,340 | 1,202 |
| String | hit | 823 | 616 | 664 | 653 | 568 |
| String | miss | 741 | 424 | 556 | 495 | 408 |
| Point | hit | 2,908 | 2,662 | 1,374 | 1,360 | 1,256 |

The profiles (`results/profiles.txt`) show where the difference lies.
`lpp`'s generated code is half `lpmask`'s (160 against 319 instructions
on an Int hit). It then spends 93 instructions in the primitive's own
walk and 45 in generic equality, which the inlined Botlish walk
compiles into the generated code.

* **On the baseline the primitive pays: 2-41 % off lookups and builds**
  (presized builds least, String misses most).
  It removes exactly what the baseline charges per probe step: two array
  helper calls, a `mod` helper call and the call to the step function.
* **After the compiler work it pays for little.** The merged tree removes
  the same per-step costs from ordinary Botlish.
  * Against the modular `lpa`, the primitive still saves 3-28 %: the
    remaining calls and generic equality per step (CO-1, CO-3). The most
    is on misses, which take the most steps.
  * Against the proof-shaped `lpmask`, it saves 0-10 %: nothing on Int
    builds, 4-6 % on Int lookups, about 10 % on String lookups and Point
    hits, 1 % on Point misses (104 against 103 ns).
* **What it costs** (HASH-TABLE-COMPILER-PRESSURE.md, RT-1):
  * it fixes one probe discipline, one layout (stored hashes, -1 for
    empty) and linear probing into the runtime;
  * Robin Hood, the compact dict and tombstones would each need their
    own primitive;
  * it has no user outside open addressing.
* **What it adds and removes** (`patches/probe-primitive.patch`):
  * `lpp` has 110 code lines against `lpa`'s 116: its two probe walks
    become calls;
  * the runtime gains 88 lines: 39 of Tcl (`probeLinear` and its
    registration, core/mutarray.tcl), 43 of Rust (`rt_mutarray_probe` and
    its dispatch, native/src/runtime/ops.rs) and 6 of NIR, CLIF and
    lowering (the `mutarrayprobe` op; one of them replaces a line);
  * it is plain Rust and Tcl with nothing target-specific;
  * it allocates nothing and is no safepoint (RT-1).
* **Verdict: not justified.** The general compiler items that remain
  (inlining and CSE of small helpers, CO-1/CO-2; typed slot equality,
  CO-3) would close the remaining distance for every table and every
  other program.

**RT-2, a runtime-owned table**, was not built: the brief rules out
comparing against "a complete Rust hash map". The Rust reference's `std`
column stands in for its ceiling. Against it, the remaining gap of the
best Botlish table on the merged tree is 3.6-3.7 times on hits, about 5 on
misses and 2.6 on Int builds (`lpmono` against `std`). Each part of that
gap is a general compiler or runtime item ("What remains"), not one a
table-owning runtime would remove for tables alone.

**RT-3, a keyed hash**, is runtime pressure recorded without a prototype,
because its cost is semantic: hash values and iteration order would vary
from run to run. The colliding keys measure what it would buy.

## Constant membership

`tools/membership.tcl` generates, for a constant set S of K values, one
Botlish function `member?(x) -> bool` per strategy. Each one is a
representation a compiler could choose while the semantics stay
"membership in S". The generator does what a compiler would do at compile
time (sort, pack bits, search for a perfect hash, build a decision tree)
and reports how long that took.

The domains:
* dense Ints: K values of 0..2K-1;
* sparse Ints: K values spread over 0..2^31;
* String identifiers: keywords first, then generated, with near misses;
* the cases of a 64-case enum.

`-check 1` runs every program on four backends with every member and
every non-member as a query: all 456 programs answer correctly
(`results/membership-check.txt`; the ten that compile-cost limits skip,
CO-7 and CO-8, are skipped there too). Times are ns per query on
cranelift: 1M queries, best of 5, on the merged tree unless a row says
otherwise. The 64-case enum at K = 64 has no non-member, so it has no
miss time.

One benchmark artifact to keep in mind: the hit queries cycle through
the first 64 members. For K > 64, the position-dependent strategies
(chain, list, iset) therefore show hit times that are too good. Their
miss times are the honest worst case, and the tables lead with misses.

### Ints: miss, ns per query

| strategy | 1 | 4 | 8 | 16 | 32 | 64 | 256 | 1,024 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| `chain` (`x == c1 or ...`) | 4.4 | 7.7 | 11.5 | 19.5 | 32.1 | 60.4 | 360 | (does not compile, CO-8) |
| `list` (module List, counted loop) | 8.5 | 13.5 | 17.3 | 27.6 | 57.9 | 107 | 355 | 1,421 |
| `iset` (`std::immutable_set::contains`) | 13.4 | 31.7 | 54.9 | 121 | 212 | 412 | 1,631 | 6,363 |
| `table` (the experiment's `lpa`) | 42.8 | 48.8 | 51.0 | 58.4 | 47.7 | 52.5 | 56.8 | 54.6 |
| `bsearch` (sorted List literal) | 11.7 | 14.5 | 15.7 | 19.1 | 20.0 | 22.7 | 29.9 | 35.2 |
| `tree` (generated comparison tree) | 4.5 | 7.7 | 8.3 | 8.3 | 8.8 | 10.3 | 10.5 | 11.5 |
| `bits` (32-bit words; dense domain) | 8.6 | 8.8 | 8.4 | 15.7* | 10.6 | 8.7 | 8.6 | 8.6 |
| `direct` (a List of Bools; dense domain) | 6.7 | 6.6 | 6.5 | 6.5 | 6.9 | 7.4 | 6.5 | 6.4 |
| `pmod` (`hash(x).mod(M)` into M slots) | 29.1 | 29.3 | 30.1 | 31.9 | 27.9 | 29.1 | 28.2 | (too large) |
| `phash` (hash and displace) | 27.4 | 29.9 | 29.8 | 31.0 | 28.8 | 29.0 | 28.8 | 29.0 |
| `phash`, dense domain | 16.7 | 18.1 | 19.3 | 18.9 | 18.5 | 19.6 | 20.1 | 20.4 |
| `phash`, baseline compiler | 44.6 | 45.7 | 48.0 | 47.8 | 50.5 | 47.1 | 48.3 | 52.0 |

Sparse domain unless a row says dense. A starred cell is an outlier of
one run.

### String identifiers: miss and hit, ns per query

| strategy | 1 | 4 | 8 | 16 | 32 | 64 | 256 | 1,024 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| `chain`, miss | 7.6 | 19.2 | 28.3 | 52.0 | 101 | 211 | 828 | (CO-8) |
| `list`, miss | 9.9 | 20.9 | 28.4 | 54.5 | 104 | 216 | 852 | 2,975 |
| `iset`, miss | 16.6 | 42.8 | 80.8 | 152 | 334 | 598 | 2,380 | 10,164 |
| `table`, miss / hit | 32.1 / 40.0 | 43.4 / 42.2 | 45.0 / 44.0 | 42.8 / 45.3 | 37.5 / 45.0 | 39.8 / 49.0 | 40.6 / 46.4 | 40.2 / 49.2 |
| `length` (dispatch on length, then chains), miss / hit | 5.3 / 10.7 | 6.2 / 12.3 | 7.9 / 15.6 | 9.9 / 17.9 | 18.0 / 22.5 | 34.5 / 38.9 | 35.0 / 38.8 | (CO-8) |
| `trie` (dispatch on length, then on characters), miss / hit | 6.2 / 10.1 | 6.0 / 12.8 | 7.6 / 16.3 | 7.6 / 17.0 | 9.7 / 18.0 | 9.8 / 19.3 | 11.0 / 19.0 | 10.2 / 19.1 |
| `phash`, miss / hit | 18.7 / 16.8 | 23.0 / 18.1 | 20.3 / 18.8 | (42.2) / 20.3 | 19.5 / 19.3 | 20.5 / 20.2 | 19.8 / 20.6 | 19.2 / 20.0 |
| `phash` on the baseline, miss / hit | 19.0 / 18.2 | 24.1 / 18.9 | 19.8 / 19.2 | 20.3 / 21.3 | 21.6 / 20.8 | 21.1 / 20.7 | 19.9 / 21.4 | 20.1 / 21.8 |

The parenthesized cell is a one-run outlier.

### Enum cases (64-case enum): miss and hit, ns per query

| strategy | 1 | 4 | 8 | 16 | 32 | 48 |
|---|---:|---:|---:|---:|---:|---:|
| `chain`, miss / hit | 5.0 / 4.6 | 6.3 / 5.6 | 5.8 / 6.0 | 7.1 / 6.1 | 9.6 / 7.3 | 12.6 / 8.4 |
| `list`, miss / hit | 8.5 / 8.1 | 10.4 / 10.2 | 16.4 / 11.3 | 22.8 / 15.3 | 41.3 / 23.0 | 52.9 / 29.3 |
| `iset`, miss / hit | 15.1 / 17.2 | 38.0 / 25.9 | 68.6 / 42.5 | 147 / 78.3 | 264 / 136 | 384 / 166 |
| `table`, miss / hit | 36.5 / 41.7 | 45.1 / 42.1 | 44.8 / 42.4 | 53.7 / 50.0 | 54.7 / 51.0 | 43.6 / 48.1 |

There is no bitset or direct table for enums. Botlish gives an enum no
ordinal (ENUMS.md), so source cannot index by case. Only the compiler,
which numbers cases internally, could choose such a representation. The
dense-Int `bits` row is the best estimate of what it would cost.

### What the numbers say

* **Linear strategies are only for tiny sets.**
  * An Int equality chain costs about 1 ns per term on a miss.
  * A String chain costs about 3 ns per term, since each `==` is a String
    comparison.
  * Up to about 4 Ints, 2-3 Strings or 16 enum cases, a chain is as fast
    as anything.
  * `std::immutable_set::contains`, the language's only set, is a linear
    `equal` scan through a runtime helper. It is the slowest strategy
    from 8 elements (below that the run-time `table` is slower): 1.6-7
    times a hand-written List scan, and 6-10 µs per miss at 1,024
    elements.
* **For Ints, a comparison tree wins from about 4 elements up to the
  largest size measured:** 7.7 ns at 4, 11.5 ns at 1,024, against 35 ns
  for a binary search over a List.
  * For a dense domain, `direct` (6.4 ns, one List read) and `bits`
    (8.6 ns, one word and a mask) are constant.
  * Their data is 2K and K/16 + 32 elements: the domain's bits, and a
    mask table.
* **Hashing is the wrong tool for constant Ints and for enums.**
  * The compiler work halved the perfect hash's cost on Ints (48 to 29 ns
    sparse, 34 to 19 dense), because RO-1 made the Int hash
    allocation-free. It still costs two to three times a tree.
  * A run-time table (`lpa`) adds calls and generic equality: 43-58 ns.
  * For enums, every hash-based strategy is 4-8 times the equality chain
    (36-55 ns against 5-13). That answers the brief's question for small
    finite domains: hashing is obviously inferior.
* **For Strings, a character trie wins from about 16 literals; below that
  it ties length dispatch alone.** The trie is length dispatch, then a
  comparison tree over the most discriminating positions:
  * 6-11 ns per miss and 10-19 ns per hit, from 1 to 1,024 literals.
  * The hash-and-displace perfect hash costs 19-21 ns whatever the size:
    one String hash, one table read, one String comparison.
  * Length dispatch alone, then chains, loses to the trie from about 16
    literals.
  * The trie pays in code, not time: 6 KB at 64 literals, 45 KB at 512
    and 116 KB at 1,024 ("Code size"). A perfect hash stays at 380 bytes
    of code plus 1.5 K elements.
* **Perfect hashing is cheap to build and stays small if done right.**
  * The hash-and-displace search for 1,024 Strings takes 75-90 ms in the
    generator (Tcl). Its table has M slots (the next power of two) plus
    one displacement per bucket: 1,536 elements for 1,024 keys.
  * The naive "smallest M with `hash(x) mod M` injective" (`pmod`) needs
    tables that grow quadratically: 5,875 slots for 256 Strings, 17,280
    for 1,024 dense Ints, 15,531 for 512 sparse Ints. Their compile cost
    explodes (CO-7: 154-180 s, and out of memory at 1,024 sparse Ints).
  * Perfect hashing's run time did not depend on K at any size measured.
    It never won on run time against a tree (Ints) or a trie (Strings).
    Where it wins is the code/data balance, from about 64 String
    literals up.

## Code size and construction cost of constant membership

A strategy chosen at compile time costs in three places:
* machine code, measured as `native::codeSize` of the strategy's own
  functions;
* constant data, as elements of the literals it holds;
* compile time, split into the generator (what a compiler would add to
  choose and build the representation), the front end on the generated
  program, and native lowering.

`results/membership-*.tsv` has every K. The tables show K = 512, the
largest size at which every strategy still compiles, on the merged tree:

**512 sparse Ints:**

| strategy | machine code | data elements | generator | front end | lowering | miss, ns |
|---|---:|---:|---:|---:|---:|---:|
| `chain` | 54,177 B | 0 | 0.8 ms | 29.0 s | 15.8 s | 1,013 |
| `tree` | 20,105 B | 0 | 1.2 ms | 3.9 s | 4.0 s | 11-18 |
| `bsearch` | 584 B | 512 | 0.1 ms | 0.6 s | 0.8 s | 29.6 |
| `phash` | 452 B | 768 | 35.1 ms | 0.5 s | 0.7 s | 29.6 |
| `pmod` | 325 B | 15,531 | 585 ms | 7.2 s | **153.5 s** | 30.4 |
| `list` | 301 B | 512 | 0.2 ms | 0.5 s | 0.5 s | 1,046 |
| `iset` | 52 B | 512 | 0.2 ms | 0.4 s | 0.5 s | 3,223 |
| `table` (`lpa` built at start) | 73 B + the module | 512 | -- | 1.5 s | 1.8 s | 50.2 |

**512 String identifiers:**

| strategy | machine code | data elements | generator | front end | lowering | miss / hit, ns |
|---|---:|---:|---:|---:|---:|---:|
| `chain` | 25,219 B | 0 | 1.2 ms | 29.3 s | 17.5 s | 2,398 / 114 |
| `length` | 25,737 B | 0 | 1.1 ms | 23.1 s | 14.3 s | 35.9 / 38.7 |
| `trie` | 44,764 B | 0 | 7.4 ms | 8.2 s | 8.4 s | 11.1 / 18.6 |
| `phash` | 380 B | 768 | 55.9 ms | 0.6 s | 0.7 s | 19.6 / 20.1 |
| `list` | 235 B | 512 | 0.8 ms | 0.4 s | 0.5 s | 1,621 / 125 |
| `iset` | 52 B | 512 | 1.5 ms | 0.4 s | 0.5 s | 4,752 / 345 |
| `table` | 73 B + the module | 512 | -- | 1.5 s | 1.6 s | 35.8 / 45.7 |

* **Code-only strategies cost tens of bytes per element:**
  * a comparison tree about 36-40 bytes per Int;
  * a trie about 90-110 bytes per String;
  * an equality chain about 100 bytes per Int and 50 per String.

  Up to about 64 elements (3 KB for a tree, 6 KB for a trie), that is
  less than many single functions.
* **Their compile time is the real limit.**
  * The front end's cost for a chain grows faster than linearly: 1.6 s
    at 64 terms, 9.2 s at 256 and 29 s at 512. At 1,024 terms it fails
    outright (CO-8).
  * A tree or a trie compiles in 2-5 s at 128 elements and 8-38 s at
    512-1,024.
* **Data strategies cost a few hundred bytes of code and compile in under
  2 s** at every size measured, when their table is O(K):
  * `phash` holds 1.5 K elements;
  * `bsearch`, `list` and `iset` hold K;
  * `bits` holds K/16 + 32 words over a dense domain of 2K values.
* **Perfect hashing must be hash-and-displace, not "smallest injective
  M".**
  * `pmod`'s table grows quadratically: 15,531 slots for 512 sparse Ints.
  * Native lowering of its List literal is quadratic in the literal's
    length (CO-7): 154 s at 15,531 elements, out of memory at 62,949.
  * `phash` finds a table of 1.5 K in 35-90 ms of Tcl at K = 512-1,024.
    It is the feasible construction.
* **Building at run time instead (`table`) moves the cost to every run.**
  `lpa` builds K entries at start, then answers in 36-58 ns per query.
  Compile-time construction is cheaper by both measures for every
  constant set measured.
* **The selection a compiler should make trades run time against code
  size:**
  * a tree or a trie, the fastest, while the set is small enough that
    its code and compile time are acceptable: up to a few hundred
    elements;
  * a perfect hash, or a bitset over a dense domain, beyond.

## Theorem and measurement

Every recommendation below rests on one of two kinds of evidence. They
are kept apart here so that no measured threshold reads as a language
law.

### Proven or static: true of every program, on every machine

| fact | where it holds | how it is established |
|---|---|---|
| `mod(x, capacity(a))` is an index of `a` when `a` is non-empty, and so is `bit_and(x, capacity(a) - 1)`: for m >= 0, `bit_and(x, m)` lies in [0, m], whatever m | the bounds prover, any container with a size (CP-1) | a theorem in `hir/completions.tcl`, with tests, a soundness fuzzer whose every rejected shape has a failing witness, and 22 mutants |
| a guard on a computed local bounds that local (CP-2); a field path names one container (CP-3) | any function | the same |
| a read-out at its path's last use moves rather than copies (VS-1); a struct literal in an exclusive position demands its fields (VS-2); an argument read by reference sees no later argument's write (BUG-1) | `hir/mutvec.tcl`, every MutableArray/MutableVector | value-semantics tests, the vector and array fuzzers (four backends, GC stress), 17 new mutants |
| natural `lpa`, `lpmono`, `rh`, `cd`, `chain` and `lpc` make no array copy on any operation | these sources, on both trees | copy counts from the allocation counters, deterministic (`tools/copies.tcl`) |
| a hit, a miss or a membership test allocates no managed object in `ht0`, `chain`, `lpa`, `lpmono`, `lpmask`, `rh`, `cd`, `sorted` or the list; a replace allocates only in the list and the chaining tables | these sources, on both trees | managed-heap counts per lookup (`tools/allocs.tcl`), deterministic |
| `hash` mallocs nothing for an Int of at most 128 bits, a character or a struct (RO-1) | the merged tree | valgrind |
| a divisor of ±2^k makes `mod` a mask, and a divisor whose range excludes 0 makes it total (CG-2) | native lowering, any `mod` | `native-mod-lowering.test`, a differential fuzzer over four backends |
| equal values hash equal on every backend and target; the language hash, the oracle's and the Rust reference's agree | core/hashing.tcl, rt_hash | parity tests on x86-64 and arm64 CI; `tools/check-hash.tcl` |
| a constant set's representation is valid: a perfect hash is injective on its set, a bitset has exactly the set's bits | each generated program | built by the generator, which checks a perfect hash's slots distinct at compile time; `membership.tcl -check 1` runs every program on four backends against every member and every non-member: 456 programs, all correct (`results/membership-check.txt`) |
| a 64-case enum set fits in two 32-bit words; a dense set in a domain of 2K values fits in ⌈2K/32⌉ words | the domain's size | arithmetic |
| linear probing at load α averages about (1 + 1/(1-α))/2 probes per hit and (1 + 1/(1-α)²)/2 per miss under uniform hashing | any table, any language | Knuth; the reference's means are 0.7-1.5 times it for every ordinary key kind |

### Measured: true of these workloads, on this machine and this compiler

* **Every time in nanoseconds, and every ratio to Rust.** They depend on
  the CPU, its caches and the current lowering. The instruction counts
  do not depend on the machine's load, but they repeat only within about
  5 %, and they too measure one compiler version.
* **Every crossover:**
  * a list beats a table only with one entry on the merged tree (up to 2
    on the baseline), and with 1,000 lookups up to 16 Int entries (32 on
    the baseline);
  * an equality chain is the fastest membership test up to about 4 Ints
    or 2-3 Strings;
  * a comparison tree beats binary search from about 4 Ints;
  * length dispatch beats a perfect hash up to about 16-32 String
    literals;
  * hand-inlining saves 21 % after the compiler work.
* **Every policy comparison:** Robin Hood's 30-50 % insert premium, and
  load 1/2 against 7/10 against 17/20 ("Resize policy").
* **The distributions.** The hash's chi-squared and the bucket lengths
  are facts about *these key sets*. Another key set can collide, as
  `int-collide` shows.

A compiler's representation selection may use the proven facts as rules.
It should use the measured crossovers only as tunable defaults, re-derived
when the lowering changes.

## Recommended division of labor

### Botlish library code

* **The table itself:**
  * its representation: parallel slot arrays with stored hashes, or the
    compact dict's index and entry vectors;
  * the probe discipline: linear, or Robin Hood;
  * the load policy and growth;
  * deletion by backward shift;
  * iteration order;
  * the Set and Map surface over all of it.
* **One generic source, specialized per key type.**
* **Evidence:**
  * `lpa` and `rh` are about 120 lines each.
  * On the merged tree they run within 1.4-6 times the same algorithm in
    Rust, depending on the operation, and within 2-5 times on the mixed
    workloads.
  * Nothing in the remaining gap is table-specific ("What remains").

### Compiler proofs

* **Merged:** general index facts:
  * an index reduced by its container's own size (CP-1);
  * a guard on a computed local (CP-2);
  * a field path as one container (CP-3).
* **Next:**
  * facts that cross a call (CP-4);
  * a struct's size invariants (CP-5: parallel capacities, "capacity >=
    8");
  * `std::mutable_vector::at` bounds (CP-6);
  * total siblings of `hash` and `==` (CO-4), without which no lookup can
    be error-free.
* **Evidence:**
  * The merged proofs are cheap and sound, and they reach table code
    only where the source reduces at every access (`lpmask`).
  * Their value is error-free signatures and smaller code more than
    speed: 2 % of a lookup's instructions.
  * CP-4 and CP-5 are what modular table code needs to get them without
    a proof-shaped source.

### Compiler optimization and specialization

This is where the large effects were, and where most of the remaining
work is.

* **Value-semantics precision.**
  * Merged: per-path last use and literal demand (VS-1, VS-2).
  * Next: the by-reference rule for consumed arguments (VS-3) and
    non-escaping closures (VS-7).
  * The copies they remove are the experiment's largest effect: O(n) per
    update, 290 times on the naturally written memo.
* **Lowering.**
  * Merged: inline MutableArray access (CG-1) and raw, masked `mod`
    (CG-2).
  * Next: inlining and CSE of small pure helpers (CO-1, CO-2), worth the
    21 % between modular and hand-inlined source.
* **Specialization.**
  * Field element types of generic containers (CO-3): typed String
    equality, 10-35 % of a String hit.
  * Field-wise struct `==` and `hash` (CO-6): a struct key costs 3-4
    times Rust.
  * Allocation-free collecting loops (CO-5).
* **Constant membership.**
  * Representation selection for membership in a constant set: a
    comparison tree, a trie, a bitset, a perfect hash.
  * The large literals and long conditions it generates must first
    compile in reasonable time (CO-7, CO-8).

None of these items is specific to tables.

### Native runtime

* **Existing operations, done well:**
  * an allocation-free `hash` (RO-1, merged);
  * the copy-on-write header the inline array paths read (CG-1, merged).
* **No new primitive for tables.**
  * The probe primitive (RT-1) saves 2-41 % on the baseline, but only
    0-10 % against proof-shaped Botlish on the merged tree.
  * It fixes one probe discipline in the runtime and has no other user.
* **One open question that is semantic, not a matter of speed:** a keyed
  hash (RT-3). It is for the hash specification and the Set/Map API to
  decide.
* **Not the runtime's job: the hash function's distribution.** The
  experiment found it good. A secondary mix in the table, or a faster
  Int hash, would change every hash value and every order that depends
  on one. That is a language decision, not a performance fix.

## Recommended future semantic APIs

The semantic recommendations, one collection at a time, are in "What
this means for collections" below. Three cut across all of them:

* **Iteration order is part of the semantics, so it must be chosen, not
  inherited.**
  * Open addressing iterates in slot order, which depends on the hash and
    the capacity history.
  * The compact dict iterates in insertion order. It costs 15-25 % on
    hits, and it is the smallest layout and among the fastest to build.
  * If Botlish wants deterministic, implementation-independent iteration,
    the compact layout is the candidate.
* **Value semantics are fine, as long as they cost nothing on the
  intended path.**
  * A table is a value. Updating one bound linearly must never copy.
  * With the merged precision work, natural code copies nothing in every
    table but `lp`, which is held back by VS-3 and VS-7.
  * Until those land, a public API would have to document SPEC.md section
    7's rules. That is an argument to land them first.
* **Equality and hash must agree, and be total where the type says so.**
  The keys a table admits are the ones `IsEqualityTotal` accepts. Total
  `hash` and `==` siblings (CO-4) are what would let a lookup be
  `may_error=false`.

## What this means for collections, one question at a time

The five questions get separate answers. The evidence does not support
one representation for all of them.

### Mutable Set

* **Representation.** Open addressing with linear probing, stored hashes
  and backward-shift deletion: `lpa`'s algorithm with keys only.
* **Division of labor.** Botlish library code, generic over the key, with
  the compiler doing the rest:
  * value-semantics precision, so that updating a set bound to a local
    never copies (VS-1/VS-2 merged; VS-3, VS-7 to do);
  * inline array access and raw `mod` (merged);
  * per-key-type specialization of equality (CO-3);
  * inlining and CSE of the small helpers (CO-1/CO-2).
* **Alternatives.**
  * Robin Hood, only if a bounded miss tail is worth 30-50 % on inserts.
  * The compact layout (`cd`), if iteration order must be insertion
    order ("Mutable Map").
* **No runtime table.** RT-1 and RT-2, "Runtime experiments".

### Mutable Map

* **Shared machinery.** It can share all of the Set's: the probe
  sequence, the slot arrays, growth and deletion. The experiment's tables
  answer `has?` and `get` with the same `find`.
* **Values.** A Map adds a value array. A Set should omit it, not fill it
  with unit: it is a third of every slot (8 of 24 bytes per slot).
* **Iteration order is the one decision that separates the candidates.**
  * Open addressing iterates in slot order, a function of the hash and
    the capacity history.
  * The compact dict iterates in insertion order whatever the hash. It
    costs 15-25 % on hits and needs a deletion design (tombstones in the
    entry vectors, or compaction). It is also the smallest, and among the
    fastest to grow.
  * If Botlish wants deterministic, hash-independent iteration (RT-3
    makes that more valuable, not less), the Map, and the Set with it,
    should be a compact dict.

### Immutable Set

* **Today.** `std::immutable_set::contains` is a linear scan of `equal`
  through a runtime helper: 7 µs per miss at 1,024 Ints, 10 µs at 1,024
  Strings. It is the slowest strategy measured from about 8 elements;
  below that a run-time hash table is slower.
* **Contents known only at run time** (built once, queried often): a
  frozen hash table.
  * It is the mutable engine, built by bulk construction (presized: about
    61-72 ns per entry on the merged tree), never grown.
  * A sorted array is 1.5-3.5 times slower on lookups. It is worth it only
    for ordered iteration or range queries, which the experiment did not
    measure.
  * Value semantics already make an unshared mutable table cheap to treat
    as immutable: a copy shares its backing until a write. A persistent
    structure (a HAMT) is not justified by anything measured.
* **Contents constant at compile time.** Compiler specialization (below).

### Membership in general

* **It should stay one semantic operation:** is `x` in this collection,
  under the collection's equality.
* **Its implementation should follow from what the compiler proves about
  the collection's representation:**
  * a dynamic set uses its table's lookup;
  * a List, a scan;
  * a constant, a representation chosen at compile time.
* **The selection belongs in the compiler,** as a specialization of the
  call site from facts the HIR already has (exact constant values,
  integer domains, enum identities). It does not belong in a runtime
  dispatch on the collection's kind, and no representation should
  appear in source.

### Literal and constant sets

* **They should be ordinary values,** with the compiler allowed to
  specialize membership in them aggressively, as long as the semantics
  stay identical (the same equality, the same errors):
  * an equality chain up to about 4 Ints or 2-3 Strings;
  * a comparison tree for Ints;
  * a bitset for a dense domain or an enum;
  * for Strings, a character trie while its code is acceptable (6 KB at
    64 literals), and a perfect hash (hash-and-displace) beyond.
* **The gains are large** (merged tree):
  * Ints: 1,013 ns (an equality chain of 512) or 3.2 µs
    (`std::immutable_set::contains`) against 18 ns (a tree; 10-12 at most
    sizes).
  * Strings: 2.4 µs against 11 ns (a trie) or 20 ns (a perfect hash), for
    512 literals.
* **Two compile-cost limits come first.** Large literals and long chains
  are too expensive to compile today (CO-7, CO-8), so they must be fixed
  before such selection is safe to apply to large sets.
* **The thresholds are measured defaults, not rules** ("Theorem and
  measurement").
* **A perfect hash should use a compiler-private hash function,** not the
  language's `hash`:
  * the language's `hash` may change (core/hashing.tcl does not promise
    stability across versions);
  * its Int encoding (decimal text) is the slow part of `phash` on Ints
    (19-30 ns on the merged tree, against 8-12 ns for a tree);
  * a function chosen per domain, such as a multiply-shift over a small
    Int or a few characters of a String, would serve the set equally well
    and cost less (not measured).
  * Generated tables are target-independent either way: the hash is
    defined on canonical bytes, and every backend and target computes
    the same value.

## What not to implement yet

* **A runtime-owned table (outcome D).** Nothing measured needs it. Each
  remaining gap item is a general compiler or runtime improvement that
  helps every program.
* **The probe primitive (RT-1).** On the merged tree it is within 0-10 %
  of the proof-shaped Botlish table. It fixes one probe discipline, one
  layout and one empty marker into the runtime.
* **A public Set/Map API, until:**
  * VS-3 and VS-7 land;
  * the CP-4/CP-5 facts and CO-3 (field element types) exist;
  * iteration order and the seeding of `hash` (RT-3) are decided.

  Otherwise the API would freeze today's workarounds.
* **Perfect hashing at run time, or as the default for constant sets.**
  * At compile time it is feasible and small: hash-and-displace, 1.5 K
    elements.
  * It never beat a comparison tree on Ints, or a trie on Strings, in run
    time.
  * Its place is large String sets, where a trie's code is too big.
* **A different hash, as a performance fix.**
  * The distribution is good: chi-squared at or below a splitmix64
    control for every key kind.
  * Implemented in Rust, Botlish's hash costs 10 ns for a small Int and
    4.5 ns for a short String, against SipHash's 8 and 12
    (`rust-hashcost-baseline.tsv`).
  * Only BigInt keys (76 ns: a decimal conversion) and chosen keys (RT-3)
    make it a problem. Both are inputs to the hash specification that
    core/hashing.tcl defers, not to the table.
* **Tombstones or quadratic probing.**
  * Backward-shift deletion keeps linear probing tombstone-free.
  * Robin Hood already gives the bounded miss tail (p99 7 against 41),
    and it is the policy for high load factors.
* **Incremental resizing.** Growth spikes scale with the table (an
  estimated 0.5-4 ms at 10-16K entries). Nothing measured needed
  bounded insert latency. It is a library choice to revisit when
  something does.

## The twelve questions

1. **What is the best currently expressible mutable hash-table strategy in
   ordinary Botlish?**
   * Open addressing with linear probing, stored hashes and
     backward-shift deletion, at a maximum load of 7/10, doubling. That is
     `lpa`, written modularly, and `lpmono`, the same with its helpers
     inlined by hand.
   * It needs no allocation per entry and no tombstones, and its hits
     equal or beat every other table above a handful of entries;
     chaining's misses are cheaper (56 against 58-75 ns, medium Int
     keys).
   * Two conditions apply. Its state must be held so that no update
     copies (the count in a one-slot array; SPEC.md section 7). Its
     source should reduce each index by the array it indexes, if every
     access is to be proven (`lpmask`).
   * Where iteration order matters, the compact dict is the alternative,
     and Robin Hood where the miss tail must be bounded.
2. **How close does it get to a comparable low-level implementation?**
   * On the merged tree, against the same algorithm in Rust:
     * 2-5 times on the mixed workloads;
     * 3.8-4.4 times on hits and 1.3-2.7 times on misses;
     * 4-6 times on Int builds, and 1.1-1.9 times on String builds,
       where Rust copies each key.
   * Against `std::HashMap`: 3.6-3.7 times on hits and about 5 times on
     misses.
   * On the baseline compiler it was 4.7-7.4 times on hits, 1.9-3.0
     times on misses, 7-10 times on Int builds, and 1,199 times on the
     naturally written memo.
3. **What portion of any remaining gap is algorithmic?** Almost none of the
   gap between Botlish and Rust.
   * The Rust reference runs the same algorithm, slot for slot, with the
     same hash, so the Botlish/Rust ratios above contain no algorithmic
     difference at all.
   * Against `std::HashMap` (SwissTable with SipHash), Rust's `lp` is even
     on hits (10.7 against 11.1 ns at 1,024 Int keys) and behind on misses
     (43.5 against 11.8).
   * Most of that miss difference goes with the hash, not the table.
     `stdb`, `std::HashMap` driven by Botlish's hash, misses in 37 ns.
     The cause was not isolated. One candidate: the hash's 61-bit range
     leaves SwissTable's 7-bit control tags 16 values instead of 128.
   * Among the good Botlish tables (`lpa`, `rh`, `cd`), the algorithm
     moves costs by 10-45 %, depending on the operation.
4. **What portion is caused by missing compiler proofs?** A small one, in
   time:
   * Proving every access of the proof-shaped table removes 2 % of a
     hit's instructions and 0-13 % of its time (`lpmask` against `lpa`,
     merged tree): a tie at 1,024 keys in ladder A2, 13 % over the
     sweep's medium sizes.
   * `lpmask` also makes 6-12 % fewer instructions than `lpa` on a miss,
     but not through the proofs: with inline array access alone, and no
     proofs, it already makes 4-17 % fewer.
   * A checked inline access is a compare and a branch that is always
     predicted.
   * The proofs matter more for what they unlock than for speed:
     error-free signatures (`store`, `shifted` and `moved` become
     `may_error=false`), smaller code, and fewer handlers in callers.
   * Lookups stay `may_error=true` whatever is proven, because `hash` and
     `==` have no total siblings (CO-4).
5. **What portion is caused by lowering or runtime overhead?** Most of it.
   * On the baseline, a lookup's instructions halve when array access is
     inlined (CG-1), `mod` lowered raw (CG-2) and `hash` made
     allocation-free (RO-1): 881 to 498 for an Int hit, 2,903 to 1,375 for
     a struct key.
   * Of what remains ("What remains"):
     * two-thirds of an Int lookup is generated code: calls, generic
       equality, safepoints;
     * the rest is the runtime hash's generic dispatch and decimal text;
     * for struct keys, the hash is two-thirds of the lookup.
   * Before those, value-semantics copies (VS) dominated any table not
     written to the copy rules. They are an avoidable-allocation cost of
     the elaboration, not of the algorithm: O(n) per update, 44 times the
     instructions of a copy-free build.
6. **Which compiler improvements are independently useful outside hash
   tables?** All five merged prototypes. Each names no table and was
   validated on an unrelated workload:
   * VS-1/VS-2/BUG-1: a BFS whose state struct is rebuilt per visit, 313
     ms to 1.1 ms. BUG-1 itself was a miscompilation found on the way.
   * CG-1: `at` 6.6 to 1.6 ns and `set` 9.3 to 1.3 ns, in any array loop.
   * CG-2: any `mod`. `stdlib/web.bot`'s hex digits become a mask.
   * RO-1: every hash.
   * CP-1..CP-3: the 2048 workload's spawn read can be written as a
     proven `empties.at(roll.mod(count))`, as can a ring buffer's index.
   * The merged tree changes nothing measurable on workloads unrelated
     to tables:
     * the 2048 engine runs at 21.4 µs per move on both trees, with
       identical allocations;
     * every case of the algorithm corpus agrees within the noise
       between rounds (±7 %).
   * Of the ones not prototyped:
     * VS-3 and VS-7 are about how values flow through calls, not tables;
     * CO-1/CO-2 (inlining, CSE of pure helpers) are general;
     * CO-7 and CO-8 are compile-cost problems of any large literal or
       long condition.
7. **Is any runtime primitive still justified after those improvements?**
   No.
   * The probe primitive (RT-1) saves 2-41 % on the baseline. On the
     merged tree it is 0-10 % ahead of the proof-shaped Botlish table:
     nothing on Int builds, about 10 % on String lookups and Point hits,
     1 % on Point misses. It would fix one probe discipline in the
     runtime.
   * A runtime-owned table (RT-2) has nothing measured to justify it.
   * The one runtime gap that remains is semantic, not a matter of speed:
     a keyed hash, so that a table can resist chosen keys (RT-3).
8. **Should mutable Set and Map share the same implementation
   machinery?** Yes, all of it. The Set should omit the value array
   rather than store unit.
9. **Should immutable or generalized membership use the same
   representation?** No.
   * Membership in a constant set is a compiler representation choice.
   * An immutable set built at run time is a frozen table: the same
     engine, never grown.
   * Neither should be `immutable_set`'s current linear scan.
10. **When do linear scan, bitset, binary search, hashing and perfect
    hashing each become attractive?** These thresholds are measured on
    this machine, not laws:
    * **Linear comparisons** win up to about 4 Ints or 2-3 Strings.
    * **A comparison tree** wins for Ints from about 4 elements to 1,024
      and beyond. Binary search over a List is 3 times slower. A tree's
      cost is compile time, not run time.
    * **Binary search** never beats a tree. As a data strategy it matches
      or beats a perfect hash on sparse Ints up to 512 (29.6 ns each at
      512) with two-thirds of its data and no hash function; at 1,024 the
      perfect hash is faster (29.0 against 35.2 ns).
    * **A bitset or direct table** is constant time for a dense domain,
      and the right choice for an enum if the compiler chooses it (source
      cannot: enums have no ordinal).
    * **For Strings, a character trie** (length dispatch, then
      character tests) wins from about 16 literals and ties length
      dispatch alone below that: 6-11 ns per miss, 10-19 per hit. Its
      code grows about 110 bytes per literal.
    * **A perfect hash** (hash-and-displace) runs in 19-21 ns at any size
      with a few hundred bytes of code. It is the choice for large String
      sets, where code size matters more than 10 ns. It never beats a
      tree on Ints.
    * **A run-time hash table** wins only for sets not known at compile
      time.
    * **For maps that live briefly,** a List beats a table only with one
      entry, or up to 16 Int entries (2 Strings) when they see 1,000
      lookups (merged tree).
11. **Can the compiler profitably select representation for constant
    membership?** Yes. The gains are 55-220 times at 512 elements:
    * 1,013 to 18 ns for 512 Ints (a tree);
    * 2,398 to 11 ns for 512 Strings (a trie), or 20 ns (a perfect
      hash);
    * against `immutable_set`, 3.2 µs to 18 ns.

    The selection needs only facts the HIR already has. It should live in
    a compiler specialization of the membership call, with the
    thresholds as tunable defaults. CO-7 (quadratic lowering of large
    literals) and CO-8 (long conditions) must be fixed first, and a
    perfect hash should use a compiler-private function, not the
    language's `hash`.
12. **Is the project ready to design a public Set/Map API, or is more
    evidence needed?** Not yet, and what is missing is mostly decisions:
    * VS-3 and VS-7, so that natural code never copies a table;
    * CO-3, so that a generic table gets typed equality;
    * whether iteration order is insertion order (compact dict) or
      unspecified;
    * whether `hash` is seeded (RT-3).

    The measurements that would still help are deletion-heavy and
    iteration-heavy workloads, which this experiment did not stress.

## Outcome

The brief kept five outcomes open. The evidence, outcome by outcome:

* **A. Ordinary Botlish is sufficient: no, not on the baseline
  compiler.**
  * On the baseline compiler, natural table code copied whole tables on
    updates (VS-1, VS-2).
  * Every lookup paid for helper calls, a malloc in `hash` and a
    fallible `mod` helper: 1.1-2.2 times today's merged tree for `lpa`
    (1.2-2.3 times its instructions).
* **B. Ordinary Botlish plus better proofs and compilation is
  sufficient: yes, and this is the main result.**
  * Five general prototypes, merged, take the best table to 1.1-6 times
    the same algorithm in Rust (2-5 on the mixed workloads).
  * The rest of the gap is a list of further general compiler items
    (CO-1..CO-6, VS-3, VS-7, CP-4, CP-5).
  * The proofs proper (CP-1..3) contributed soundness and code size more
    than speed. The lowering and value-semantics items carried the
    performance.
* **C. Narrow runtime primitives: not justified.**
  * The probe primitive's advantage shrinks to 0-10 % against
    proof-shaped Botlish after the compiler work, and it fixes one probe
    discipline in the runtime.
  * The keyed hash (RT-3) is a primitive the language may want, for
    robustness, not speed. That decision belongs with the hash
    specification.
* **D. A runtime-owned table: not justified.** Nothing measured requires
  it, and every remaining cost would also be paid by programs that are
  not tables.
* **E. Different uses need different representations: yes, for
  membership.**
  * Mutable maps and sets share one engine.
  * Immutable sets of run-time contents should be frozen tables.
  * Constant membership is a different optimization problem: a compiler
    choice among trees, tries, bitsets and perfect hashes, for which a
    run-time hash table is 3-5 times too slow and an equality chain or a
    linear set 100 times.
