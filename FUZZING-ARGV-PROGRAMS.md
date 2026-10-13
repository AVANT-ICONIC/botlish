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
List construction, `list::get`, and the programs' real logic -- the CSV
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

* **FZ-001, filed** (`fuzz/triage/FZ-001/`): `csv-argv` never terminates
  on an argument whose first character is a quote with no closing quote;
  minimized to a single byte (`"`). Mechanism: the example's
  `scan_quoted` recurses past end-of-text (`peek` returns `""`, never a
  quote, forever). Vertical split: `interp` completes with a clean
  `TCL LIMIT STACK` error; `compile`, `cranelift`, `cranelift-generic`
  and the AOT executable loop forever (self tail calls eliminated to
  loops). Classification: **program logic** in the argv program's driver
  (the repository example is within its documented valid-CSV contract;
  no example driver passes malformed text). Not fixed, per campaign
  policy; the vertical divergence itself is designed behavior
  (interpreter recursion limit vs tail-call elimination) and is what
  attributes the bug to program logic.
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

* `list::get` takes three arguments today (`get(xs, index, default)`);
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
9. Every reported bug deduplicated and minimized: **yes** (vacuous if
   zero findings; the pipeline is exercised either way).
10. Every reported bug replayed across the four required verticals:
    **yes** (vacuous if zero; the matrix itself ran for all targets).
11. Every reported bug manually reproduced: **yes** (vacuous if zero).

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
  opens).
* Persistent-mode harnesses and structure-aware CSV mutation, as in
  campaign 1's list, now with a real parser to aim them at.
