# Native result bounds and raw bitwise lowering

`bench/refined-checks.bot`'s `high_nibble<int>` (stdlib/web.bot's
`std::byte::nibble(std::byte::high_nibble(b))` inside `uri_escape_text`) compiled to a
tag test on `b` and an `rt_int_and` call, with a stack frame for the call's
spills, although every byte it is ever given is at most 244:

```
mov    QWORD PTR [rsp],rsi
mov    QWORD PTR [rsp+0x8],0x1e1
test   rsi,0x1
jne    fast
mov    edx,0x1e1
call   rt_int_and
jmp    done
fast:  and rsi,0x1e1
...
```

Two independent losses produced it, one in the front end and one in native
lowering. This change fixes both.

## 1. The front end: a native's bound is one fact

`b`'s entry range is the join of the arguments of `pct`'s call sites. All
but one were bounded; the 4-byte UTF-8 lead byte `bit_or(240,
v.shift_right(18))` was not, because `std::char::scalar_value` was registered
`-result-range nonneg` and `hir/range.tcl` therefore knew `v` only as
`[65536, +inf]`. `hir/completions.tcl` meanwhile knew `[0, 0x10FFFF]`, by a
rule of its own keyed on the native's name, and a second such rule for
`mod` (a divisor of bounded magnitude bounds the result). STATIC-COMPLETION-
PROOFS.md kept both out of `hir/range.tcl` to avoid changing generated code
in that milestone; nothing about them was unsound for code generation.

Now:

* `-result-range` takes `{interval LO HI}` (core/native.tcl; stored in
  decimal). `std::char::scalar_value` is registered `{interval 0 0x10FFFF}` and
  `hash` `{interval 0 2^61-1}` (its result is masked to 61 bits; it was
  `nonneg`).
* `hir::range::RegisteredRange` is the one reader of the metadata. The range
  analysis (its seeds and its native calls) and the completion analysis both
  call it, so they cannot disagree about a native's bound.
* `hir::range::Mod` is `mod`'s transfer function, beside `BitOp`, called by
  both analyses.
* The completion analysis keeps only what needs its own call-specific facts
  (ctx.exact): the exact length of a known String or List and the exact
  codepoint of a known UnicodeChar.

With it, `pct`, `hex_pair` and `high_nibble` enter with `[0, 244]` (0xF4,
UTF-8's largest lead byte) and `esc_scalar` with `[128, 1114111]`.

## 2. Native lowering: bitwise ops of small operands are raw

The raw tier of native/lower.tcl covered `+ - *`, the comparisons and the
shifts, not `bit_and`/`bit_or`/`bit_xor`: their tagged form
(clif.rs's `int_bitop`) works on the tagged words, which was taken to be
enough. It still tests both operands for a BigInt and keeps the
`rt_int_and`/`or`/`xor` call, with its spills, on the slow path. So the
range fact of section 1 alone changed no machine code.

Now `riand`, `rior` and `rixor` (native/src/nir.rs) are raw ops, emitted by
`RawEligibleCall`/`RawIntOp` when both operands' ranges fit the small-Int
representation. The result needs no check: two small Ints agree in bits 62
and 63, and AND, OR and XOR keep that agreement. Codegen is the host
`and`/`or`/`xor`. `FoldPureBitwise` (a constant result, an identity
returning an operand) keeps the operand's representation when the operands
are raw, and native/rawabi.tcl counts the three ops as raw consumers.

`high_nibble<int>` is now (its parameter is also raw by the raw-Int ABI):

```
and    rsi,0xf0
sar    rsi,0x4
shl    rsi,1
mov    rax,rsi
or     rax,0x1
```

## 3. Effect

Over the 17 corpus programs (`bench/*.bot`, `examples/stdlib/*.bot`),
counting reachable Int expressions and Int parameters of every used
instance whose range does not fit the small-Int representation:

| | unproven expressions (of 1479) | unproven parameters (of 171) |
|---|---:|---:|
| before | 620 | 108 |
| after | 520 | 88 |

`std::char::scalar_value`'s bound accounts for 50 expressions and 14 parameters,
`mod`'s for 46 and 6, `hash`'s for 4 and 0.

The committed disassembly corpus (audit/native-scalar-asm/, regenerated)
changes in three programs: `refined-checks` loses all four bitwise helper
calls and 149 of its 2496 instructions (10,319 to 9,640 bytes of machine
code); `hashtable` and `csv_records` grow by 9 and 10 instructions (22
bytes each). The growth is section 1's `mod` bound, not section 2:
`ht_probe_next`'s result is now provably small, so the probing loops keep
`index` in a raw self-tail slot (native/lower.tcl's RawParams) and box it
again for `std::mutable_array::at`, which takes a tagged index;
`ht_probe_next` itself shrinks (228 to 178 bytes, one safepoint fewer).

Executed instructions (callgrind, deterministic; native driver, the same
binary for both NIRs):

| workload | before | after | |
|---|---:|---:|---:|
| `refined-checks`, per run | 6,425,362 | 6,416,700 | -0.13% |
| `uri-steady`, per run | 26,111,035 | 26,009,730 | -0.39% |
| `csv_records`, per run | 102,733 | 102,544 | -0.18% |
| `hashtable`, 20,000 inserts + 200,000 hits | 212,793,176 | 213,691,916 | +0.42% |
| `hashtable`, ... + 200,000 misses | 282,052,551 | 281,719,748 | -0.12% |
| `hashtable`, ... + 200,000 replaces | 233,972,618 | 235,914,748 | +0.83% |

The hashtable cost is the extra boxing above; a raw index for
`std::mutable_array::at`, or a raw `imod`, would remove it.

## 4. What still has no bound

The remaining 520 expressions and 88 parameters are not native results:
self-recursive loop indices whose bound is relational (`i < std::str::length(s)`),
indices that step a few past the small-Int maximum because the collection
length cap equals it, accumulators (bounded only by a trip count, or truly
unbounded), values read from struct fields and mutable-array elements (no
element or field ranges are tracked), growth arithmetic (`capacity * 2`),
and inputs that are simply unbounded.

## 5. Tests

* `tests/native-result-bounds.test` (new): the interval metadata and its
  validation, `RegisteredRange`, `Mod`, the refined-checks entry facts, the
  raw ops in high_nibble's NIR and no helper in its Cranelift IR, raw and
  tagged selection (small, BigInt and unbounded operands), value agreement on
  every backend at the small-Int boundaries, and the fold with raw operands.
* `tests/range-completions-crosscheck.test`'s
  `xcheck-intentional-completions-rules` now pins the shared bounds as equal
  (mod, std::char::scalar_value, hash) and the exact-codepoint rule as narrower.
* Two tests used `mod(...)` as their unbounded value
  (`closed-call-weaker-caller-widens`, `rec-neg-unbounded-entry`); they use a
  recursive accumulator instead, with the same expected results.
* `native/src/nir.rs`'s `raw_bitwise_ops_take_and_produce_raw_registers`.
