# Fuzzing argv-driven programs, AOT first (campaign 2)

The follow-up campaign to FUZZING-EXAMPLES-AOT.md, built on its central
finding: the example programs consume no input, so the deep input path
(`rt_argv`, String/List construction, the programs' own logic) was never
executed. This campaign closes that gap with **argv-driven programs** --
the example applications' own logic, re-driven from the process argument
vector -- and fuzzes those the same way.

```
fuzz/programs/*.bot  ->  AOT executables  ->  afl-fuzz campaigns (input now
                         reaches the programs)  ->  failure corpus
                                                        |
                                    replay every failure through every vertical
                                    (interp, compile, cranelift, cranelift-generic)
                                                        |
                                    deduplicated, minimized, classified findings
```

Campaign date: 2026-10-04. Platform and toolchain unchanged from campaign
1 (x86_64 WSL2, AFL++ 4.09c QEMU mode, same harness and scripts; see
FUZZING-EXAMPLES-AOT.md §2). Everything reproducible:
`bash fuzz/scripts/build-aot.sh && bash fuzz/scripts/make-seeds.sh &&
bash fuzz/scripts/minimize-seeds.sh && bash fuzz/scripts/campaign.sh`.

## 1. Inventory: which programs can consume argv at all

Botlish's one external input channel is `argv() -> List[str]` (ARGV.md).
A program can be argv-driven exactly when its entry point consumes
**strings** -- there is no string-to-Int conversion in the language, so
programs whose input is numeric cannot read argv meaningfully.

Feasible (built, all four AOT-emitting): the string-processing
applications, with definitions copied verbatim from their examples and
only the driver changed:

| program | source of logic | input consumed | value on empty argv |
|---|---|---|---|
| `csv-argv` | `examples/stdlib/csv.bot` | `argv[1]` -> `csv_parse` | `csv_parse("") = []` |
| `ai-text-clean-argv` | `examples/stdlib/ai_text_clean.bot` | `argv[1]` -> `clean_ai_text` | `""` |
| `string-reverse-argv` | `examples/stdlib/string_reverse.bot` | `argv[1]` -> `reverse_chars` | `""` |
| `string-replace-argv` | `examples/stdlib/string_replace.bot` | `argv[1..3]` -> `replace` (missing -> `""`) | `""` |

Each driver captures `argv()` once with the documented
`on InvalidArgumentEncoding: []` fallback (ARGV.md's own pattern), so an
invalid-UTF-8 vector behaves exactly like no arguments: the program is
**total** on every argv byte string -- the ideal fuzz shape, and what
makes the differential oracle sound. Expected failure exit code is 1 as
in campaign 1 (and with these drivers, unreachable in practice: every
error path is handled).

Not feasible, one line each:

* `matmul`, `numeric-domains`, `getpid`, and the arithmetic-flavored
  surface/hir examples: their inputs are Ints, and the language has no
  string->Int conversion; argv strings cannot reach their logic.
* `csv_chunked`/`csv_geometric`/`csv_records`/`hashtable` variants: their
  function bodies are the guarded workloads the AOT gate already refuses
  (`NATIVE AOT NOT-READY`); an argv driver does not change the bodies,
  so the variants would not emit.
* `getpid` already takes a syscall number as a Botlish Int literal;
  making it argv-driven needs the same missing conversion.

No example file was modified; the argv programs live under
`fuzz/programs/` and cite the example each was copied from.

## 2. Instrumentation decision and blind spots

Unchanged from campaign 1: AFL++ 4.09c **QEMU mode** over the plain
release binaries, argv-vector harness (`fuzz/harness/argv-file.c`), no
compiler or runtime changes. What changed is what the instrumentation
now sees: the input reaches `rt_argv`'s strict UTF-8 validation (or the
documented `InvalidArgumentEncoding` completion), canonical String and
List construction, `std::list::get`, and the programs' real logic -- the CSV
scan state machine (quoting, `""` escapes, embedded newlines), the
character classifier and cleaner, the reverse loop, and the replace
matcher.

Blind spots, stated plainly:

* Kernel-side work (the exec-time argv copy) remains invisible; QEMU
  emulates the getpid-style syscall path outside the coverage map.
* The Tcl `interp` vertical has a recursion limit the native verticals
  do not (they eliminate self tail calls); see §5's depth-limit class.
* Everything else as in campaign 1 §2.

## 3. Harness, seeds, dictionaries

* Harness: unchanged. One **contract requirement discovered this
  campaign and now pinned**: the in-process verticals' injected vector
  must include `argv[0]`, byte-identical to the harness's (`fuzz/scripts/
  replay.tcl` prepends the AOT binary's path). Without it every argument
  index shifts by one between verticals and input-consuming programs
  diverge for a harness reason (§5).
* Seeds (`fuzz/seeds/<target>/`): the example's own thematic corpus --
  the CSV subset with quoting/escapes/embedded newlines/CRLF/unicode,
  ai_text_clean's punctuation and emoji set, the replace triples as
  NUL-separated `haystack\0needle\0replacement` vectors -- plus the
  structural checklist from campaign 1 (empty vector, empty argument,
  multi-argument vectors, invalid UTF-8, ~100 KiB argument, 500 small
  arguments). `afl-cmin` minimized 11-17 per target to 8-9.
* Dictionaries: `csv.dict`, `text.dict` as in campaign 1 (attached to
  the csv/text targets); `numeric.dict` is not attached here (no numeric
  parsing exists to reach).

## 4. Campaign parameters per target

Identical policy to campaign 1 (recorded there §4): `-Q`, `-m none`,
`-G 100000`, `-t` from 10x slowest baseline seed floored at 200 ms
(argv baselines: 2-4 ms, so 200 ms everywhere), signals-only crash
oracle, `AFL_CRASH_EXITCODE` unset, WSL environment variables, budget
1200 s per target enforced by `-V`, snapshots every 300 s. The 27-target
run (23 examples + 4 argv programs) keeps the example targets on the
exact base this report ships against.

## 5. Differential matrix

`fuzz/scripts/differential.sh` over every target x seed x five
verticals, with `argv[0]` pinned as above: **1280 recorded runs, 1231
compared, 0 hard mismatches** (the difference is the four documented
exception classes below). The argv programs make this matrix
input-dependent for the first time: each vertical receives byte-identical
argv vectors and must agree on the value.

Documented exception classes recorded as data (now four):

1. `known-limitation` -- cranelift-generic's struct-shape stand-in gap
   (campaign 1 §5).
2. `native-only-refusal` -- `getpid`'s documented `NATIVE-ONLY` refusal
   on the Tcl backends.
3. `display-divergence` -- the Tcl runners' `#{Type}` evidence suffix.
4. `interp-depth-limit` -- **new this campaign**: on deep inputs (a
   ~100 KiB single argument), the Tcl reference interpreter completes
   with `TCL LIMIT STACK` where every native vertical returns the
   correct value, because the interpreter does not eliminate tail calls
   (Botlish recursion is Tcl recursion) -- exactly the behavior
   `examples/stdlib/corpus.tcl` documents and works around by raising
   the limit. A clean error in one vertical, depth-dependent; recorded,
   not filed.

## 6. Campaign statistics

Final-base run (every number from the archived
`fuzz/campaign-stats/2026-10-04/{release,asan}/`):

**Release pass** (QEMU mode, 1200 s/target, 27 targets: 23 example
executables + 4 argv programs): **11,788,253 executions, 0 crashes,
6 hangs**. The argv targets:

| target | execs | execs/s | corpus | crashes | hangs |
|---|---|---|---|---|---|
| csv-argv | 359802 | 299 | 20 | 0 | 4 |
| ai-text-clean-argv | 429393 | 357 | 18 | 0 | 0 |
| string-reverse-argv | 604750 | 504 | 19 | 0 | 2 |
| string-replace-argv | 405437 | 337 | 18 | 0 | 0 |

The 23 example targets re-ran on the same base with the same parameters
(400k-680k execs each, 0 crashes, 0 hangs; per-target tables in the
archived fuzzer_stats -- same shape as campaign 1 §6, with
`string-reverse`'s example twin also collecting 0 hangs).

**ASan pass** (600 s/target, 27 targets): **1,329,495 executions,
0 crashes, 4 hangs** (all four on `csv-argv`, deduplicating into
FZ-001):

| target | execs | execs/s | corpus | crashes | hangs |
|---|---|---|---|---|---|
| csv-argv | 18896 | 31 | 20 | 0 | 4 |
| ai-text-clean-argv | 55850 | 93 | 21 | 0 | 0 |
| string-reverse-argv | 57661 | 96 | 21 | 0 | 0 |
| string-replace-argv | 54695 | 91 | 18 | 0 | 0 |

Combined campaign-2 total: **13,117,748 executions** (11.79M release +
1.33M ASan), 0 crashes, 10 raw hang artifacts, 0 sanitizer reports. (Three release instances initially lost a CPU-affinity race
with concurrent verification jobs and were re-run standalone with
`AFL_NO_AFFINITY=1`, now exported by `campaign.sh`/`campaign-asan.sh` --
an infrastructure fix, not a finding.)

## 7. Findings

Raw artifacts: 10 hangs (6 release + 4 ASan; 8 on `csv-argv`, 2 on
`string-reverse-argv`), 0 crashes, 0 sanitizer reports. Deduplicated:
**2** signatures. Confirmed by hand: **1 bug**, 1 performance
observation.

* **FZ-001, filed and fixed on the branch** (`fuzz/triage/FZ-001/`):
  `csv-argv` never terminates on an argument whose first character is a
  quote with no closing quote; minimized to a single byte (`"`).
  Mechanism: the example's `scan_quoted` recurses past end-of-text
  (`peek` returns `""`, never a quote, forever). Vertical split:
  `interp` completes with a clean `TCL LIMIT STACK` error; `compile`,
  `cranelift`, `cranelift-generic` and the AOT executable loop forever
  (self tail calls eliminated to loops). Classification: **program
  logic** in the argv program's driver (the repository example is within
  its documented valid-CSV contract; no example driver passes malformed
  text). The fix (later, on branch `fuzz/argv-campaign`, after merging
  main): `scan_quoted` returns the accumulated field at end-of-text in
  `fuzz/programs/csv-argv.bot` -- verified not fixed on main first
  (main's rewritten csv.bot still loops, rc=124 on the 1-byte input),
  then fixed, all five verticals agreeing (`[[""]]`), valid inputs
  byte-identical to before.
* **FZ-002, not filed** (performance observation, §9): the two
  `string-reverse-argv` hang artifacts are ~100 KiB inputs finishing
  correctly in 3-4 s plain -- the example's documented O(n^2) reverse
  under the campaign's QEMU-inflated timeout.

Classification distribution (confirmed): program-logic 1; shared-layer
0; native-only 0; single-backend 0; interp-only 0; semantic-divergence
0. **No compiler or runtime bug was found**; the ASan pass added no
sanitizer finding, GC-stress and valgrind replays of FZ-001 behave like
their parent verticals (non-termination, no memory error before the
loop).

## 8. Pre-fuzzing findings

None that are product bugs. Two contract facts were learned while
building the targets, both recorded in-tree and neither a compiler
defect:

* `std::list::get` takes three arguments today (`get(xs, index, default)`);
  the two-argument form is a runtime arity error, not an optional-default
  form. The drivers use the 3-argument form explicitly.
* The argv[0]-pinning requirement of §3 (initially missed; it made the
  first differential run of these targets report argument-shift
  mismatches that were pure harness skew).

## 9. Performance observations

* argv baselines: 2-4 ms per run on the minimized seeds; deep inputs
  (~100 KiB) run in tens of ms natively and the AOT binaries return
  full values; the interp vertical's deep-input behavior is the §5
  depth-limit class, not slowness.
* **`string-reverse-argv` on ~100 KiB arguments**: correct output, 3-4 s
  plain per run, exceeding the campaign's 200 ms timeout under QEMU
  translation (2 AFL hang artifacts, triage candidate FZ-002,
  slow-terminating by direct verification: exit 0, correct value). The
  example's own header documents the cause: "reversing n characters
  copies O(n^2) characters". Not a bug; recorded here per #52.
* QEMU-mode throughput: 299-357 execs/s on the argv targets (release),
  31-96 execs/s under the ASan pass -- same envelope as campaign 1; the
  argv programs' own runtimes stay in the low milliseconds on seeds.

## 10. Verification

* Full regression (`tclsh9.0 tests/all.tcl`) on the exact base this
  report ships against: **5472 total, 5468 passed, 4 skipped
  (pre-existing `coreScoping`), 0 failed** with the whole fuzz tree
  present (the same run as campaign 1's final verification; this
  campaign adds no compiled-by-tests code, only `fuzz/programs/*.bot`
  data and regenerated stats).
* Every argv program still compiles AOT and matches its recorded
  baseline on seeds (`fuzz/baselines/*-argv.tsv`).
* Every campaign step is a committed script; the known-failure replay
  suite's selftest still passes.

## 11. Required questions (brief §62-§65)

Campaign setup:

1. 36 example programs + 4 argv-driven programs (inventory §1); the
   argv programs are the only ones whose behavior depends on input.
2. Fuzzable: the 4 argv programs (input reaches program logic) plus the
   23 example executables (runtime argv surface only, re-run on the
   final base); infeasible-with-reasons: §1.
3. AFL++ QEMU mode; blind spots §2.
4. Compiler changes required: **no**.
5. Budget 1200 s/target, `-t 200` everywhere, `-m none`; recorded §4.
6. Seeds minimized and dictionaries checked in: **yes**.

Oracle and triage:

7. A bug is: crash signals, panics, unexpected exits, differential
   mismatches beyond the four documented classes, nondeterminism.
8. Expected failure exit codes excluded: **yes** (signals-only oracle;
   these drivers make exit 1 effectively unreachable).
9. Every reported bug deduplicated and minimized: **yes** (FZ-001: 8 raw
   artifacts -> 1 signature -> 1 byte).
10. Every reported bug replayed across the four required verticals:
    **yes** (FZ-001's matrix is in its package and §7).
11. Every reported bug manually reproduced: **yes** (FZ-001 by hand on
    all five verticals, pre-fix and post-fix).

Findings:

12. Raw artifacts: 10 hangs, 0 crashes; deduplicated: 2 signatures;
    confirmed bugs: 1 (FZ-001, program-logic hang; §7) plus 1
    performance observation (FZ-002, not a bug).
13. Classification distribution: program-logic 1; shared / native-only /
    single-backend / interp-only / divergence: all 0.
14. Differential mismatches without crashes: none beyond the four
    documented classes (§5); FZ-001 itself surfaced as AFL hangs, not as
    a matrix mismatch (the minimized seeds are all in-contract).
15. Hangs: 10 raw artifacts, two root causes -- FZ-001 (non-terminating;
    verified: no exit within 240 s on inputs as small as 3 bytes;
    minimized to 1 byte; filed) and FZ-002 (slow-but-terminating ~100 KiB
    reversals, verified exit 0 with correct values in 3-4 s; performance
    observation, not filed). Neither is blocking-on-EOF.
16. GC-stress replay: no independent finding; FZ-001 under GC-stress is
    the same non-termination (no GC or memory event precedes the loop).

Verification:

17. Full regression passes: **yes** (§10).
18. All programs compile AOT and match recorded baselines: **yes**.
19. Every step reproducible from committed scripts: **yes**.
20. Known-failure replay suite covering every filed bug: **yes**.

## 12. Limitations

* Four programs, all string processors -- the no-string->Int conversion
  boundary is the hard edge of what argv-driven fuzzing can reach in
  the language today.
* The interp vertical's depth limit bounds how deep the matrix can
  compare on one side; native-vs-native comparison is unbounded.

## 13. Future work

* A string->Int conversion (or a `read int from argv` idiom) would make
  the numeric programs argv-drivable.
* An argv-driven variant of a NOT-READY program becomes interesting the
  moment its guarded workload closes (then it emits and its input path
  opens); csv_geometric already closed and is now a target.
* Persistent-mode harnesses and structure-aware CSV mutation, as in
  campaign 1's list, now with a real parser to aim them at.
* (from the continuation) `read-stdin` deserves a dedicated longer
  campaign: it is the only target still finding coverage at budget end,
  and a multi-chunk or parsing stdin program would go further still.

## 14. Continuation (2026-10-14): the merged-base targets

After merging main (which added `examples/linux/read-stdin.bot`,
`write.bot`, `context-hello.bot`, `examples/surface/15-enums.bot`, made
`csv_geometric` AOT-ready, and removed `06-refined-strings`), the
campaign extended to them on the same rules -- plus one genuinely new
channel:

* **`read-stdin` is the first stdin-consuming target**: a one-chunk
  (<= 4096 bytes) raw-syscall echo, native-only by contract. It runs in
  AFL's native stdin mode (no harness, no `@@`; `fuzz/stdin-targets`
  names the mode). Its differential needs a decomposing oracle: stdout
  is `<echoed input bytes><byte-count>` with the value possibly glued to
  the echo, so the aot vertical recovers the value by trying every
  bounded digit-suffix against the exact input prefix (exactly one
  candidate must fit; none is a violation, several are reported
  ambiguous). In-process verticals get their value from main.tcl's
  ordinary value line (the runner never shows the raw echo there -- a
  framing property, not a divergence).
* `write`, `context-hello`: fixed-output writers whose stdout text
  precedes the value (`fuzz/write-targets`; value = trailing integer).
* `15-enums`, `csv_geometric`: ordinary argv-surface targets.

Results (all archived under `fuzz/campaign-stats/2026-10-14/`):

* Release pass: **32 targets, 9,449,522 executions, 0 crashes,
  0 hangs** (archived `fuzz/campaign-stats/2026-10-14/release/`). The
  FZ-001 fix held under mutation: `csv-argv` collected zero hangs.
* `read-stdin` is by far the campaign's richest target: corpus 156 after
  its first 1200 s (2.91% of the coverage map, vs 0.09% for every other
  target), still finding at budget end -- so it took the campaign's
  growth-extension rule (+1800 s): corpus **360**, 3.00%, 26,695 execs,
  still unplateaued when the extension ended. The only target in either
  campaign that never stopped finding. Under ASan: 30,951 execs, clean.
* ASan pass: **31 targets, 1,249,868 executions, 0 crashes, 0 hangs**.
* Differential (re-run with the io normalizations and two new documented
  exception classes): **1253 runs, 0 hard mismatches** (native-only-
  refusal 44, known-limitation 17, in-process-io-glue 4,
  interp-depth-limit 1, display-divergence 0 -- that class's one program
  was deleted upstream).
* Findings: **zero new bugs**; every fuzzer artifact class of this
  continuation (the io-glue misparses) is an infrastructure observation,
  not a product defect. FZ-002 remains the only performance observation.

Two new documented exception classes join the four from §5 (now six):

5. `in-process-io-glue` -- an I/O program's own stdout bytes glued onto
   the driver's value line (no trailing newline, NUL bytes especially)
   make the in-process runner misreport a successful run as "native
   backend produced no result"; the aot vertical, which has no framing,
   verifies the real behavior.
6. (from the fix pass) `write-targets` value extraction -- the aot value
   is the trailing integer of stdout for the two fixed-output writers.

The FZ-001 fix from the merge pass is part of this continuation's
verification: 9.45M release + 1.25M ASan executions over the fixed
`csv-argv` produced zero hangs -- the fix holds under mutation, and the
known-failure suite (post-fix expectations) runs green.

## 15. Required questions (continuation)

1. 38 examples + 4 argv programs + the 5 merged-base targets (36
   AOT-able: 31 binaries + read-stdin in stdin mode); every one
   inventoried or fuzzed, none hidden.
2. Fuzzable: all 32 binary targets (31 argv-mode + 1 stdin-mode); the
   same 11 by-design emission failures as before.
3. QEMU mode unchanged; the stdin channel is now genuinely exercised
   (read syscall, freeze_prefix, write syscall all input-dependent).
4. Compiler changes: **no**.
5. 1200 s/target (read-stdin +1800 s growth extension), `-t 200`,
   `-m none`.
6. Seeds minimized and dictionaries checked in: **yes** (read-stdin:
   15 -> 3; write: 8 -> 6; csv_geometric rides the csv corpus).
7-11. Bug oracle unchanged (signals, panics, unexpected exits,
   mismatches beyond the six documented classes, nondeterminism);
   expected exit codes excluded; findings deduplicated/minimized/
   matrix-replayed/manually reproduced as before.
12-16. Raw: 0 crashes, 0 hangs (release and ASan); deduplicated: 0;
    confirmed bugs: 0 (FZ-001 remains fixed; FZ-002 remains a
    performance observation). Classification distribution: empty. No
    differential mismatches beyond the five documented classes (§14).
    No hangs. GC-stress replay: no findings to replay.
17-20. Regression: the full suite passed green on this exact compiler
   base at merge time (7256 total, 0 failed; the continuation adds only
   fuzz-tree data, harness scripts and the io-glue exception logic -- no
   code the test suite compiles); every step reproducible from committed
   scripts; the known-failure replay suite covers every filed finding
   and runs green.
