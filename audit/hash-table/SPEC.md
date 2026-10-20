# Hash-table experiment: the shared specification

This file fixes, once, the algorithms, the table interface and the workloads
that every artifact of the hash-table experiment (HASH-TABLE-EXPERIMENT.md)
implements: the Botlish implementations (`impl/`), the driver programs
(`drivers/`), the Rust reference (`reference/`), the Python oracle and
statistics model (`tools/model.py`). Two artifacts that follow it compute
the same table states (the same slots, the same probe sequences), so a
probe count, a timing or an allocation count of one can be compared with
another's.

Nothing here is a standard-library API. The names are experiment-internal
and deliberately not the spellings a future Set/Map would use.

## 1. The hash

Every table indexes by Botlish's root `hash(key)` (core/hashing.tcl,
native/src/runtime/ops.rs's `rt_hash`): FNV-1a over a kind tag and the
value's payload bytes, masked to 61 bits (`0 <= hash(k) < 2^61`). The
payload of an Int is its canonical decimal text; of a String its UTF-8
bytes. `tools/model.py`'s `bhash` reproduces it for Int, String and the
struct `Point` (checked against the compiled program by `tools/check-hash`).

No table adds a secondary hash or mixes the hash further: the experiment
measures the hash as it is (section 20 of the brief), and
`tools/model.py stats` reports its distribution separately.

## 2. Capacity, load and growth

* A capacity is a power of two, at least `MIN = 8`.
* `home(h, cap) = h mod cap` (Euclidean `mod`; for a power of two the same
  value as `bit_and(h, cap - 1)`).
* The maximum load is the fraction `NUM / DEN` (default `7 / 10`; the
  resize-policy matrix also uses `1 / 2` and `17 / 20`). An insert of a key
  that is not present first grows the table when
  `(count + 1) * DEN > cap * NUM`, then places the key.
* Growth doubles the capacity and reinserts every entry, in slot order
  0..cap-1 of the old table, with the algorithm's own insert-into-fresh
  routine (no tombstones, no duplicate checks).
* `fresh(expected)`: the smallest capacity `cap >= MIN` with
  `expected * DEN <= cap * NUM` (so inserting `expected` keys never grows).
  `fresh(0)` is capacity `MIN`.
* Separate chaining uses the same capacities with `NUM / DEN = 1 / 1`
  (one entry per bucket on average) unless a variant says otherwise.

## 3. Algorithms

`h = hash(key)`; `i0 = home(h, cap)`.

### `listmap` -- linear List of entries

Entries in insertion order. Lookup scans from the front. Insert of a
present key replaces its value in place (a new List with that element
replaced); of an absent key appends. Remove drops the element.

### `chain` -- separate chaining

`cap` buckets, each a List of entries `{hash, key, value}`. Lookup scans
bucket `i0` comparing the stored hash, then the key. Insert of an absent key
appends to the bucket; growth (load 1/1) rebuilds every bucket in old slot
order, each bucket's entries in order.

### `lp` -- linear probing, stored hashes, backward-shift deletion

Three parallel slot arrays: `hashes` (-1 for an empty slot, else the
entry's hash), `keys`, `vals`. Probe sequence `i0, i0+1, ...` mod cap.
Lookup stops at the first empty slot (absent) or at a slot whose stored hash
equals `h` and whose key equals `key` (present). Insert of an absent key
places it at the first empty slot of its sequence. Remove of the key at
slot `i`: backward-shift -- repeatedly look at the next slot `j`; stop at an
empty slot; if the entry at `j` may move to `i` (its home `k` is not
cyclically in `(i, j]`), move it to `i` and continue from `i = j`; finally
empty slot `i`.

`lp` exists in three source organizations of the same algorithm (section 9
of the brief): `lp` (modular: one small helper per concept), `lpmono` (each
operation one function, helpers inlined by hand), `lpfact` (only the
helpers that keep the generated code's quality).

### `rh` -- Robin Hood

`lp`'s arrays and probe sequence. `dist(i) = (i - home(hashes[i], cap))
mod cap`. Insert carries an entry and its distance `d` from `i0`; at an
occupied slot whose resident has `dist < d`, the two swap and insertion
continues with the evicted entry; a present key (same hash, equal key) is
replaced. Lookup stops when the slot is empty or its resident's
`dist < d` (absent). Remove: backward-shift while the next resident has
`dist > 0`.

### `cd` -- compact dict (insertion-ordered entries, an index of entry numbers)

The entries are dense, in insertion order, in three MutableVectors
(`ehash`, `ekey`, `eval`); the index is a `MutableArray[int]` of `cap`
slots, -1 for an empty slot, else an entry number. Lookup probes the index
linearly from `i0`, comparing the entry's stored hash, then its key. Insert of
an absent key appends an entry and stores its number at the first empty index
slot of its sequence. Growth (the same `NUM / DEN` on the index capacity)
rebuilds only the index, from the entries in entry order; the entries never
move. It does not remove keys (`# drop: no`).

### `ht0` -- the existing prototype

`examples/stdlib/hashtable.bot` unchanged in algorithm (linear probing with
tombstones, controls/keys/values arrays and a counts array, 2/3 load,
untyped), behind this interface (`impl/ht0.bot`).

### `sorted` -- immutable, sorted by hash, binary search

Built once from a List of entries: deduplicated (last value wins), sorted by
`(hash, insertion order)`; lookup binary-searches the hash, then compares
keys among the equal-hash run. No insertion after construction.

### `direct` / `bits` -- bounded non-negative Int domains

`direct`: a `MutableArray[bool]` (set) or of values (map) of `U` slots
indexed by the key itself, keys in `0 <= k < U`. `bits`: the same set packed
32 bits per Int word in a `MutableArray[int]`.

## 4. The table interface

An implementation's header carries two machine-read lines: `# policy:
NUM/DEN` (or `none` when SPEC.md's capacity model does not apply), which the
fuzzer uses to predict `slots(t)`, and `# drop: no` when it does not remove
keys.

Every implementation module exports (types where the implementation is
typed; the generic implementations leave keys and values untyped):

| function | meaning |
|---|---|
| `fresh(expected: int) -> T` | an empty table sized for `expected` entries (section 2) |
| `put(t, key, value) -> T` | `t` with `key` mapped to `value` (insert or replace) |
| `get(t, key, default)` | the value of `key`, or `default` |
| `has?(t, key) -> bool` | whether `key` is present |
| `size(t) -> int` | the number of entries |
| `drop(t, key) -> T` | `t` without `key` (where the algorithm deletes naturally) |
| `slots(t) -> int` | the capacity (diagnostic; 0 where meaningless) |
| `probes(t, key) -> int` | slots or entries a lookup of `key` examines (diagnostic, for cross-checking the model) |

A table is a value: an update returns the updated table, and the caller
binds it (`t2 = put(t1, k, v)`). The implementation may declare
`errors IndexNotFound` on any function: whether it has to is one of the
experiment's measurements, recorded per function.

## 5. Keys

| kind | key(i) | miss_key(i) |
|---|---|---|
| `int-dense` | `i` | `i + 2^40` |
| `int-sparse` | `mod(i * 2654435761, 2^32)` | `mod(i * 2654435761, 2^32) + 2^32` |
| `int-big` | `i + 2^80` (a BigInt) | `i + 2^81` |
| `int-collide` | the i-th of a precomputed list of Ints whose `hash` is `0 mod 1024` (found by black-box search, `tools/model.py collide`) | the same search, residue 512 |
| `str-short` | `"id_"` + hex(i) | `"no_"` + hex(i) |
| `str-medium` | `"/usr/share/doc/package-"` + hex(i) + `"/index.html"` | `"/usr/share/doc/missing-"` + hex(i) + `"/index.html"` |
| `point` | `Point {x: bit_and(i, 1023), y: shift_right(i, 10)}` | `Point {x: bit_and(i, 1023), y: shift_right(i, 10) + 2^20}` |

hex(i) is the lowercase hexadecimal text of `i` (no leading zeros, "0" for
0). The query order of `M` lookups over `n` entries is
`q(j) = mod(j * 40503 + 7, n)` for `j = 0..M-1`.

## 6. Workloads (modes)

A driver program reads `argv`: `MODE N M REPS`, and returns a checksum (an
Int) that depends on every result, so nothing is dead.

| mode | what the timed program does beyond `keys` |
|---|---|
| `keys` | builds the List of N keys and the List of M query keys (hits) and M miss keys: the baseline every other mode subtracts |
| `build` | REPS times: a fresh table `fresh(0)`, N inserts of new keys (growing) |
| `presized` | REPS times: `fresh(N)`, N inserts |
| `hit` | one build, then M lookups of present keys `key(q(j))` |
| `miss` | one build, then M lookups of absent keys `miss_key(j)` |
| `replace` | one build, then M `put`s of present keys |
| `life L` | REPS times: build N, then L lookups (L = 1, 10, 1000) |
| `drop` | one build, then N removes in insertion order |

The mixed workloads (`drivers/bfs.bot`, `memo.bot`, `freq.bot`) are their own
programs: a breadth-first search over a W x W grid with a visited set of
`Point`s, Collatz step counts memoized in an Int-keyed table, and a word
frequency count over generated text with String keys.

## 7. Implementation rules (value semantics)

A MutableArray or MutableVector is a value over a copy-on-write backing: a
logical copy shares the backing, and the next write through either copy
copies every element -- even when the other copy is already dead, since a
dead header holds the backing until the collector frees it. Every
implementation follows these rules (HASH-TABLE-EXPERIMENT.md, "Value
semantics", has the evidence for each) and is checked for them: the native
allocation report's `mutableArray` section must show 0 shares and 0
detaches in steady state (`tools/copies.tcl`).

1. Thread a table linearly: `t2 = put(t1, ...)`, never reading `t1` again.
2. Mutate through field places (`t.keys.set(i, k)`) and return the
   parameter; a mutating helper takes the table as its argument's last use.
3. Call table functions only directly (never as values).
4. Readers only read: never return, store or capture the table.
5. Keep scalar state (the count) in a `MutableArray[int]`, so no update
   rebuilds the table struct. (If a rebuild cannot be avoided: one
   collection-bearing sub-struct field, every scalar bound first, that field
   read last.)
6. Never destructure a table.
7. Build tables with their constructor calls inline in the struct literal.
8. Return several results in a named struct, binding the scalars first.
9. No `if`-expression or handled-call bindings on a table's path; declare
   `errors IndexNotFound` and handle it once at the top.
10. Flat storage: no MutableArray or MutableVector inside slots (Lists and
    structs in slots are fine; they are immutable).
11. Typed struct parameters (`t: Table`), so cranelift-generic compiles the
    projections.
