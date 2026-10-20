# Hash-table experiment: measured data

The tables of [HASH-TABLE-EXPERIMENT.md](../../../docs/HASH-TABLE-EXPERIMENT.md)
are made from these files with `tools/summarize.tcl`. The plans that
wrote them are `tools/plan.sh` .. `tools/plan5.sh`, and `logs/` keeps
their progress lines.

## Tags

A row's first column (or a file's suffix) names the compiler tree it was
measured on:

| tag | tree |
|---|---|
| `baseline`, `base` | commit `2aa20d6`, before the prototypes |
| `hash`, `inline`, `mod`, `bounds`, `vs` | the baseline plus one prototype (RO-1, CG-1, CG-2, CP-1..3, VS-1/VS-2) |
| `combo` | the branch with all five prototypes merged (the report's "merged tree"), before the review fixes (commit `340e966`) |
| `fixed` | the merged tree after the review fixes (merges `cd7ba76`, `a71467d`, `1198a1d`; `plan5.sh`): counts only, no timings |
| `probe`, `comboprobe` | the baseline, and the merged tree, plus the probe primitive (`../patches/probe-primitive.patch`) |
| `rust` | the Rust reference |

## Methods

* **Passes.** Lookups (hit, miss, member, replace) are timed as passes:
  four passes minus one, divided by three times the queries (`bench.tcl
  -passes 4`). Builds, bulk construction and removals are timed the same
  way with `-build-passes 3`.
* **The first method.** Files from the first sweeps timed against a
  separately timed key run. Their lookup and build columns are
  superseded, as marked below.
* **Counts.** Allocations, copies, memory and NIR are deterministic.
  Instruction counts and profiles do not depend on the machine's load,
  but repeat only within about 5 % per operation (20 % for chaining's
  String misses): `instructions-repeat.tsv` has repeated counts.

## Files

| file | what | method |
|---|---|---|
| `sizes-baseline.tsv` | every table, Int and String keys, 1..16,384 entries, every mode | first method: use `lookups/` and `builds/` instead |
| `sizes-combo.tsv` | the same on the merged tree | lookups as passes; builds first method (use `builds/`) |
| `lookups/sizes-baseline.tsv`, `lookups/keys-baseline.tsv`, `lookups/typed-baseline.tsv` | the baseline's lookups again, as passes | passes |
| `builds/sizes-baseline.tsv`, `builds/sizes-combo.tsv` | every table's builds, both trees alternating | build passes |
| `keys-baseline.tsv`, `keys-combo.tsv` | sparse, big, collide, medium-String and Point keys | baseline: first method (use `lookups/keys-baseline.tsv`); combo: lookups as passes |
| `typed-baseline.tsv`, `typed-combo.tsv` | `lpint`, `lpstr` against `lpa` | as for keys |
| `life-*.tsv` | short-lived tables: build N, then L lookups | whole lifetimes |
| `policy-baseline.tsv` | the load-policy matrix | first method: use `lookups/policy-*.tsv` |
| `lookups/policy-baseline.tsv`, `lookups/policy-combo.tsv` | the load-policy matrix | passes |
| `mixed-*.tsv` | BFS, word frequency, memo (natural and restructured) | whole workloads |
| `backends-baseline.tsv` | interp, compile, cranelift-generic at small sizes | first method |
| `membership-*.tsv` | constant membership: every strategy, domain and K | ns per query, code, data, compile times |
| `ladder-a.tsv`, `ladder-c.tsv` | the prototype ladders, first round | lookups as passes, builds first method (superseded) |
| `ladder-a2.tsv`, `ladder-c2.tsv` | the prototype ladders and the probe primitive, three alternating rounds | passes |
| `rust-*.tsv` | the Rust reference: sweep, mixed, probe statistics, hash cost, insert spikes | its own timings and counts |
| `instructions.tsv` | instructions per operation (callgrind) | counts |
| `instructions-repeat.tsv` | the operations whose `fixed` count differs from `combo` by more than 3 %, counted twice more on each tree | counts |
| `profiles.txt` | instructions per operation and per function | counts |
| `allocs.tsv` | managed-heap allocations per lookup | deterministic |
| `copies-*.txt`, `attribution.txt` | MutableArray copies (shares, detaches, elements copied); `combo` and `fixed` are identical | deterministic |
| `memory-*.tsv` | bytes allocated and peak live bytes per entry; `combo` and `fixed` are identical | deterministic |
| `nir-*.txt` | each table's specialized functions: machine-code size, operations, facts; all three trees with the same driver, `combo` and `fixed` identical | deterministic |
| `unrelated-*.txt`, `corpus-again.txt` | workloads unrelated to tables, both trees | timings |
| `fuzz-fixed.txt` | every table fuzzed after the review fixes: four backends, `ht0` three (CG-3) | correctness |
| `fuzz-large.txt`, `fuzz-policy.txt` | after the review fixes: the `large` profile on the native backends, and the 1/2 and 17/20 load-policy variants of `lpa` and `rh` | correctness |
