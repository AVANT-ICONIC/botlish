// hash-table-reference -- the independent low-level reference of the
// hash-table experiment (HASH-TABLE-EXPERIMENT.md; ../SPEC.md).
//
//   cargo run --release -- sweep [OPTIONS]      timings, one TSV line each
//   cargo run --release -- stats [OPTIONS]      probe and bucket statistics
//   cargo run --release -- hashcost             what one hash costs
//   cargo run --release -- check                hash values, for tools/check-hash
//
// The tables are SPEC.md's algorithms written plainly (listmap, chain, lp,
// rh), indexed by Botlish's own hash (FNV-1a over a kind tag and the
// payload, an Int as its decimal text, masked to 61 bits), with the same
// capacities, load policy and growth, so their table states -- and probe
// counts -- are the Botlish implementations'. Beside them: the standard
// library's HashMap twice, with its own SipHash ("std") and with Botlish's
// hash ("stdb"), which separates mature table engineering from the hash.
//
// It is a measuring instrument: the same algorithm in Rust estimates the
// language/runtime overhead of the Botlish version; std::HashMap shows what
// tuned engineering reaches. Neither is the intended architecture.

use std::collections::HashMap;
use std::hash::{BuildHasher, Hash, Hasher};
use std::hint::black_box;
use std::time::Instant;

// ---------------------------------------------------------------------------
// Botlish's hash (core/hashing.tcl, native/src/runtime/ops.rs's rt_hash)

const FNV_OFFSET: u64 = 0xcbf29ce484222325;
const FNV_PRIME: u64 = 0x100000001b3;
const MASK61: u64 = (1u64 << 61) - 1;

#[inline]
fn fnv(mut h: u64, bytes: &[u8]) -> u64 {
    for &b in bytes {
        h = (h ^ b as u64).wrapping_mul(FNV_PRIME);
    }
    h
}

/// The decimal text of N into BUF, returning the used suffix (no heap).
fn decimal(n: i128, buf: &mut [u8; 48]) -> &[u8] {
    let mut i = buf.len();
    let negative = n < 0;
    let mut m: u128 = n.unsigned_abs();
    if m == 0 {
        i -= 1;
        buf[i] = b'0';
    }
    // 128-bit division is a library call: digits of the part beyond 64
    // bits only, then 64-bit division (what an itoa does).
    while m > u64::MAX as u128 {
        i -= 1;
        buf[i] = b'0' + (m % 10) as u8;
        m /= 10;
    }
    let mut m = m as u64;
    while m > 0 {
        i -= 1;
        buf[i] = b'0' + (m % 10) as u8;
        m /= 10;
    }
    if negative {
        i -= 1;
        buf[i] = b'-';
    }
    &buf[i..]
}

/// The unmasked FNV state of an Int (a sub-hash inside a struct).
fn mix_int(n: i128) -> u64 {
    let mut buf = [0u8; 48];
    fnv(fnv(FNV_OFFSET, &[0]), decimal(n, &mut buf))
}

/// The struct identity text of the experiment's key struct (a module's
/// struct is `module::Name`): checked against the compiled programs by
/// tools/check-hash.
const POINT_ID: &str = "keys::Point";

trait BKey: Clone + Eq + Hash + std::fmt::Debug {
    /// Botlish's hash of the key, exactly.
    fn bhash(&self) -> u64;
    /// The same value computed the way the native runtime computes it
    /// today: an Int formatted into a fresh heap String first.
    fn bhash_alloc(&self) -> u64 {
        self.bhash()
    }
}

impl BKey for i64 {
    fn bhash(&self) -> u64 {
        mix_int(*self as i128) & MASK61
    }
    fn bhash_alloc(&self) -> u64 {
        let text = self.to_string();
        fnv(fnv(FNV_OFFSET, &[0]), text.as_bytes()) & MASK61
    }
}

/// A key beyond the 64-bit range (int-big: 2^80 + i).
#[derive(Clone, PartialEq, Eq, Hash, Debug)]
struct Big(i128);

impl BKey for Big {
    fn bhash(&self) -> u64 {
        mix_int(self.0) & MASK61
    }
    fn bhash_alloc(&self) -> u64 {
        let text = self.0.to_string();
        fnv(fnv(FNV_OFFSET, &[0]), text.as_bytes()) & MASK61
    }
}

impl BKey for String {
    fn bhash(&self) -> u64 {
        fnv(fnv(FNV_OFFSET, &[1]), self.as_bytes()) & MASK61
    }
}

#[derive(Clone, PartialEq, Eq, Hash, Debug)]
struct Point {
    x: i64,
    y: i64,
}

impl BKey for Point {
    fn bhash(&self) -> u64 {
        let mut h = fnv(FNV_OFFSET, &[8]);
        h = fnv(h, POINT_ID.as_bytes());
        h = fnv(h, &2u64.to_le_bytes());
        h = fnv(h, b"x");
        h = fnv(h, &mix_int(self.x as i128).to_le_bytes());
        h = fnv(h, b"y");
        h = fnv(h, &mix_int(self.y as i128).to_le_bytes());
        h & MASK61
    }
}

// ---------------------------------------------------------------------------
// Capacity policy (SPEC.md section 2)

const MIN_CAPACITY: usize = 8;

#[derive(Clone, Copy, Debug)]
struct Load {
    num: usize,
    den: usize,
}

fn capacity_for(expected: usize, load: Load) -> usize {
    let mut cap = MIN_CAPACITY;
    while expected * load.den > cap * load.num {
        cap *= 2;
    }
    cap
}

trait Table<K: BKey> {
    fn fresh(expected: usize, load: Load) -> Self;
    fn put(&mut self, key: K, value: i64);
    fn get(&self, key: &K, default: i64) -> i64;
    fn has(&self, key: &K) -> bool;
    fn size(&self) -> usize;
    fn remove(&mut self, key: &K);
    fn slots(&self) -> usize;
    fn probes(&self, key: &K) -> usize;
}

// ---------------------------------------------------------------------------
// listmap

struct ListMap<K> {
    entries: Vec<(K, i64)>,
}

impl<K: BKey> Table<K> for ListMap<K> {
    fn fresh(_: usize, _: Load) -> Self {
        ListMap { entries: Vec::new() }
    }
    fn put(&mut self, key: K, value: i64) {
        for e in self.entries.iter_mut() {
            if e.0 == key {
                e.1 = value;
                return;
            }
        }
        self.entries.push((key, value));
    }
    fn get(&self, key: &K, default: i64) -> i64 {
        for e in &self.entries {
            if e.0 == *key {
                return e.1;
            }
        }
        default
    }
    fn has(&self, key: &K) -> bool {
        self.entries.iter().any(|e| e.0 == *key)
    }
    fn size(&self) -> usize {
        self.entries.len()
    }
    fn remove(&mut self, key: &K) {
        if let Some(i) = self.entries.iter().position(|e| e.0 == *key) {
            self.entries.remove(i);
        }
    }
    fn slots(&self) -> usize {
        0
    }
    fn probes(&self, key: &K) -> usize {
        match self.entries.iter().position(|e| e.0 == *key) {
            Some(i) => i + 1,
            None => self.entries.len(),
        }
    }
}

// ---------------------------------------------------------------------------
// chain

struct Chain<K> {
    buckets: Vec<Vec<(u64, K, i64)>>,
    count: usize,
    load: Load,
}

impl<K: BKey> Chain<K> {
    fn grow(&mut self) {
        let cap = self.buckets.len() * 2;
        let mut buckets: Vec<Vec<(u64, K, i64)>> = (0..cap).map(|_| Vec::new()).collect();
        for bucket in self.buckets.drain(..) {
            for e in bucket {
                let i = (e.0 % cap as u64) as usize;
                buckets[i].push(e);
            }
        }
        self.buckets = buckets;
    }
}

impl<K: BKey> Table<K> for Chain<K> {
    fn fresh(expected: usize, _: Load) -> Self {
        let load = Load { num: 1, den: 1 };
        let cap = capacity_for(expected, load);
        Chain { buckets: (0..cap).map(|_| Vec::new()).collect(), count: 0, load }
    }
    fn put(&mut self, key: K, value: i64) {
        let h = key.bhash();
        let cap = self.buckets.len();
        let i = (h % cap as u64) as usize;
        for e in self.buckets[i].iter_mut() {
            if e.0 == h && e.1 == key {
                e.2 = value;
                return;
            }
        }
        if (self.count + 1) * self.load.den > cap * self.load.num {
            self.grow();
        }
        let cap = self.buckets.len();
        let i = (h % cap as u64) as usize;
        self.buckets[i].push((h, key, value));
        self.count += 1;
    }
    fn get(&self, key: &K, default: i64) -> i64 {
        let h = key.bhash();
        let i = (h % self.buckets.len() as u64) as usize;
        for e in &self.buckets[i] {
            if e.0 == h && e.1 == *key {
                return e.2;
            }
        }
        default
    }
    fn has(&self, key: &K) -> bool {
        let h = key.bhash();
        let i = (h % self.buckets.len() as u64) as usize;
        self.buckets[i].iter().any(|e| e.0 == h && e.1 == *key)
    }
    fn size(&self) -> usize {
        self.count
    }
    fn remove(&mut self, key: &K) {
        let h = key.bhash();
        let i = (h % self.buckets.len() as u64) as usize;
        if let Some(j) = self.buckets[i].iter().position(|e| e.0 == h && e.1 == *key) {
            self.buckets[i].remove(j);
            self.count -= 1;
        }
    }
    fn slots(&self) -> usize {
        self.buckets.len()
    }
    fn probes(&self, key: &K) -> usize {
        let h = key.bhash();
        let bucket = &self.buckets[(h % self.buckets.len() as u64) as usize];
        match bucket.iter().position(|e| e.0 == h && e.1 == *key) {
            Some(j) => j + 1,
            None => bucket.len(),
        }
    }
}

// ---------------------------------------------------------------------------
// lp: linear probing, stored hashes (-1 empty), backward-shift deletion

struct Lp<K> {
    hashes: Vec<i64>,
    keys: Vec<Option<K>>,
    vals: Vec<i64>,
    count: usize,
    load: Load,
}

impl<K: BKey> Lp<K> {
    fn with_capacity(cap: usize, load: Load) -> Self {
        Lp { hashes: vec![-1; cap], keys: vec![None; cap], vals: vec![0; cap], count: 0, load }
    }
    /// (slot, found): KEY's slot, or the empty slot that ends its sequence.
    #[inline]
    fn find(&self, h: u64, key: &K) -> (usize, bool) {
        let cap = self.hashes.len();
        let mut i = (h % cap as u64) as usize;
        loop {
            let s = self.hashes[i];
            if s < 0 {
                return (i, false);
            }
            if s as u64 == h && self.keys[i].as_ref() == Some(key) {
                return (i, true);
            }
            i = (i + 1) % cap;
        }
    }
    fn place_fresh(&mut self, h: u64, key: K, value: i64) {
        let cap = self.hashes.len();
        let mut i = (h % cap as u64) as usize;
        while self.hashes[i] >= 0 {
            i = (i + 1) % cap;
        }
        self.hashes[i] = h as i64;
        self.keys[i] = Some(key);
        self.vals[i] = value;
    }
    fn grow(&mut self) {
        let cap = self.hashes.len() * 2;
        let mut next = Lp::with_capacity(cap, self.load);
        for i in 0..self.hashes.len() {
            if self.hashes[i] >= 0 {
                let key = self.keys[i].take().unwrap();
                next.place_fresh(self.hashes[i] as u64, key, self.vals[i]);
            }
        }
        next.count = self.count;
        *self = next;
    }
}

impl<K: BKey> Table<K> for Lp<K> {
    fn fresh(expected: usize, load: Load) -> Self {
        Lp::with_capacity(capacity_for(expected, load), load)
    }
    fn put(&mut self, key: K, value: i64) {
        let h = key.bhash();
        let (i, found) = self.find(h, &key);
        if found {
            self.vals[i] = value;
            return;
        }
        if (self.count + 1) * self.load.den > self.hashes.len() * self.load.num {
            self.grow();
            self.place_fresh(h, key, value);
        } else {
            self.hashes[i] = h as i64;
            self.keys[i] = Some(key);
            self.vals[i] = value;
        }
        self.count += 1;
    }
    fn get(&self, key: &K, default: i64) -> i64 {
        let (i, found) = self.find(key.bhash(), key);
        if found {
            self.vals[i]
        } else {
            default
        }
    }
    fn has(&self, key: &K) -> bool {
        self.find(key.bhash(), key).1
    }
    fn size(&self) -> usize {
        self.count
    }
    fn remove(&mut self, key: &K) {
        let (mut i, found) = self.find(key.bhash(), key);
        if !found {
            return;
        }
        let cap = self.hashes.len();
        let mut j = i;
        loop {
            j = (j + 1) % cap;
            if self.hashes[j] < 0 {
                break;
            }
            let k = (self.hashes[j] as u64 % cap as u64) as usize;
            // The entry at j may move to i unless its home is cyclically in (i, j].
            let stays = if i <= j { i < k && k <= j } else { i < k || k <= j };
            if !stays {
                self.hashes[i] = self.hashes[j];
                self.keys[i] = self.keys[j].take();
                self.vals[i] = self.vals[j];
                i = j;
            }
        }
        self.hashes[i] = -1;
        self.keys[i] = None;
        self.count -= 1;
    }
    fn slots(&self) -> usize {
        self.hashes.len()
    }
    fn probes(&self, key: &K) -> usize {
        let h = key.bhash();
        let cap = self.hashes.len();
        let mut i = (h % cap as u64) as usize;
        let mut n = 1;
        loop {
            let s = self.hashes[i];
            if s < 0 || (s as u64 == h && self.keys[i].as_ref() == Some(key)) {
                return n;
            }
            i = (i + 1) % cap;
            n += 1;
        }
    }
}

// ---------------------------------------------------------------------------
// rh: Robin Hood over lp's arrays

struct Rh<K> {
    t: Lp<K>,
}

impl<K: BKey> Rh<K> {
    #[inline]
    fn dist(&self, i: usize) -> usize {
        let cap = self.t.hashes.len();
        let home = (self.t.hashes[i] as u64 % cap as u64) as usize;
        (i + cap - home) % cap
    }
    #[inline]
    fn find(&self, h: u64, key: &K) -> Option<usize> {
        let cap = self.t.hashes.len();
        let mut i = (h % cap as u64) as usize;
        let mut d = 0;
        loop {
            let s = self.t.hashes[i];
            if s < 0 || self.dist(i) < d {
                return None;
            }
            if s as u64 == h && self.t.keys[i].as_ref() == Some(key) {
                return Some(i);
            }
            i = (i + 1) % cap;
            d += 1;
        }
    }
    /// Inserts an entry known to be absent (Robin Hood displacement).
    fn place(&mut self, mut h: u64, mut key: K, mut value: i64) {
        let cap = self.t.hashes.len();
        let mut i = (h % cap as u64) as usize;
        let mut d = 0;
        loop {
            if self.t.hashes[i] < 0 {
                self.t.hashes[i] = h as i64;
                self.t.keys[i] = Some(key);
                self.t.vals[i] = value;
                return;
            }
            let e = self.dist(i);
            if e < d {
                let rh = self.t.hashes[i] as u64;
                self.t.hashes[i] = h as i64;
                h = rh;
                key = std::mem::replace(&mut self.t.keys[i], Some(key)).unwrap();
                value = std::mem::replace(&mut self.t.vals[i], value);
                d = e;
            }
            i = (i + 1) % cap;
            d += 1;
        }
    }
    fn grow(&mut self) {
        let cap = self.t.hashes.len() * 2;
        let mut next = Rh { t: Lp::with_capacity(cap, self.t.load) };
        for i in 0..self.t.hashes.len() {
            if self.t.hashes[i] >= 0 {
                let key = self.t.keys[i].take().unwrap();
                next.place(self.t.hashes[i] as u64, key, self.t.vals[i]);
            }
        }
        next.t.count = self.t.count;
        *self = next;
    }
}

impl<K: BKey> Table<K> for Rh<K> {
    fn fresh(expected: usize, load: Load) -> Self {
        Rh { t: Lp::with_capacity(capacity_for(expected, load), load) }
    }
    fn put(&mut self, key: K, value: i64) {
        let h = key.bhash();
        if let Some(i) = self.find(h, &key) {
            self.t.vals[i] = value;
            return;
        }
        if (self.t.count + 1) * self.t.load.den > self.t.hashes.len() * self.t.load.num {
            self.grow();
        }
        self.place(h, key, value);
        self.t.count += 1;
    }
    fn get(&self, key: &K, default: i64) -> i64 {
        match self.find(key.bhash(), key) {
            Some(i) => self.t.vals[i],
            None => default,
        }
    }
    fn has(&self, key: &K) -> bool {
        self.find(key.bhash(), key).is_some()
    }
    fn size(&self) -> usize {
        self.t.count
    }
    fn remove(&mut self, key: &K) {
        let Some(mut i) = self.find(key.bhash(), key) else { return };
        let cap = self.t.hashes.len();
        loop {
            let j = (i + 1) % cap;
            if self.t.hashes[j] < 0 || self.dist(j) == 0 {
                break;
            }
            self.t.hashes[i] = self.t.hashes[j];
            self.t.keys[i] = self.t.keys[j].take();
            self.t.vals[i] = self.t.vals[j];
            i = j;
        }
        self.t.hashes[i] = -1;
        self.t.keys[i] = None;
        self.t.count -= 1;
    }
    fn slots(&self) -> usize {
        self.t.hashes.len()
    }
    fn probes(&self, key: &K) -> usize {
        let h = key.bhash();
        let cap = self.t.hashes.len();
        let mut i = (h % cap as u64) as usize;
        let mut d = 0;
        loop {
            let s = self.t.hashes[i];
            if s < 0 || self.dist(i) < d || (s as u64 == h && self.t.keys[i].as_ref() == Some(key)) {
                return d + 1;
            }
            i = (i + 1) % cap;
            d += 1;
        }
    }
}

// ---------------------------------------------------------------------------
// std::collections::HashMap, with SipHash (std) and with Botlish's hash (stdb)

struct Std<K> {
    m: HashMap<K, i64>,
}

impl<K: BKey> Table<K> for Std<K> {
    fn fresh(expected: usize, _: Load) -> Self {
        Std { m: HashMap::with_capacity(expected) }
    }
    fn put(&mut self, key: K, value: i64) {
        self.m.insert(key, value);
    }
    fn get(&self, key: &K, default: i64) -> i64 {
        *self.m.get(key).unwrap_or(&default)
    }
    fn has(&self, key: &K) -> bool {
        self.m.contains_key(key)
    }
    fn size(&self) -> usize {
        self.m.len()
    }
    fn remove(&mut self, key: &K) {
        self.m.remove(key);
    }
    fn slots(&self) -> usize {
        self.m.capacity()
    }
    fn probes(&self, _: &K) -> usize {
        0
    }
}

/// A key hashed by Botlish's hash, through a pass-through hasher.
#[derive(Clone, PartialEq, Eq, Debug)]
struct ByB<K>(K);

impl<K: BKey> Hash for ByB<K> {
    fn hash<H: Hasher>(&self, state: &mut H) {
        state.write_u64(self.0.bhash());
    }
}

#[derive(Default)]
struct PassThrough(u64);

impl Hasher for PassThrough {
    fn finish(&self) -> u64 {
        self.0
    }
    fn write(&mut self, _: &[u8]) {
        unreachable!("ByB writes one u64")
    }
    fn write_u64(&mut self, n: u64) {
        self.0 = n;
    }
}

#[derive(Default, Clone)]
struct BuildPassThrough;

impl BuildHasher for BuildPassThrough {
    type Hasher = PassThrough;
    fn build_hasher(&self) -> PassThrough {
        PassThrough(0)
    }
}

struct StdB<K> {
    m: HashMap<ByB<K>, i64, BuildPassThrough>,
}

impl<K: BKey> Table<K> for StdB<K> {
    fn fresh(expected: usize, _: Load) -> Self {
        StdB { m: HashMap::with_capacity_and_hasher(expected, BuildPassThrough) }
    }
    fn put(&mut self, key: K, value: i64) {
        self.m.insert(ByB(key), value);
    }
    fn get(&self, key: &K, default: i64) -> i64 {
        // (A lookup by reference would need Borrow; the clone is a key copy,
        // cheap for Ints, a String copy for Strings: see get_ref below.)
        *self.m.get(&ByB(key.clone())).unwrap_or(&default)
    }
    fn has(&self, key: &K) -> bool {
        self.m.contains_key(&ByB(key.clone()))
    }
    fn size(&self) -> usize {
        self.m.len()
    }
    fn remove(&mut self, key: &K) {
        self.m.remove(&ByB(key.clone()));
    }
    fn slots(&self) -> usize {
        self.m.capacity()
    }
    fn probes(&self, _: &K) -> usize {
        0
    }
}

// ---------------------------------------------------------------------------
// Keys (SPEC.md section 5)

fn collide_keys(n: usize, residue: u64) -> Vec<i64> {
    let mut out = Vec::with_capacity(n);
    let mut i: i64 = 0;
    while out.len() < n {
        if i.bhash() % 1024 == residue {
            out.push(i);
        }
        i += 1;
    }
    out
}

trait KeyKind: BKey {
    fn keys(kind: &str, n: usize) -> Vec<Self>;
    fn misses(kind: &str, n: usize) -> Vec<Self>;
}

impl KeyKind for i64 {
    fn keys(kind: &str, n: usize) -> Vec<i64> {
        match kind {
            "int-dense" => (0..n as i64).collect(),
            "int-sparse" => (0..n as i64).map(|i| (i * 2654435761) % (1i64 << 32)).collect(),
            "int-collide" => collide_keys(n, 0),
            _ => panic!("unknown Int key kind {kind}"),
        }
    }
    fn misses(kind: &str, n: usize) -> Vec<i64> {
        match kind {
            "int-dense" => (0..n as i64).map(|i| i + (1i64 << 40)).collect(),
            "int-sparse" => (0..n as i64).map(|i| (i * 2654435761) % (1i64 << 32) + (1i64 << 32)).collect(),
            "int-collide" => collide_keys(n, 512),
            _ => panic!("unknown Int key kind {kind}"),
        }
    }
}

impl KeyKind for Big {
    fn keys(_: &str, n: usize) -> Vec<Big> {
        (0..n as i128).map(|i| Big(i + (1i128 << 80))).collect()
    }
    fn misses(_: &str, n: usize) -> Vec<Big> {
        (0..n as i128).map(|i| Big(i + (1i128 << 81))).collect()
    }
}

impl KeyKind for String {
    fn keys(kind: &str, n: usize) -> Vec<String> {
        match kind {
            "str-short" => (0..n).map(|i| format!("id_{i:x}")).collect(),
            "str-medium" => (0..n).map(|i| format!("/usr/share/doc/package-{i:x}/index.html")).collect(),
            _ => panic!("unknown String key kind {kind}"),
        }
    }
    fn misses(kind: &str, n: usize) -> Vec<String> {
        match kind {
            "str-short" => (0..n).map(|i| format!("no_{i:x}")).collect(),
            "str-medium" => (0..n).map(|i| format!("/usr/share/doc/missing-{i:x}/index.html")).collect(),
            _ => panic!("unknown String key kind {kind}"),
        }
    }
}

impl KeyKind for Point {
    fn keys(_: &str, n: usize) -> Vec<Point> {
        (0..n as i64).map(|i| Point { x: i & 1023, y: i >> 10 }).collect()
    }
    fn misses(_: &str, n: usize) -> Vec<Point> {
        (0..n as i64).map(|i| Point { x: i & 1023, y: (i >> 10) + (1 << 20) }).collect()
    }
}

fn query(j: usize, n: usize) -> usize {
    ((j as u64 * 40503 + 7) % n as u64) as usize
}

// ---------------------------------------------------------------------------
// Timing (SPEC.md section 6): each mode times its operation phase only

struct Params {
    n: usize,
    m: usize,
    reps: usize,
    runs: usize,
    load: Load,
}

/// The best of RUNS timings of F (nanoseconds) and its last checksum.
fn best<F: FnMut() -> i64>(runs: usize, mut f: F) -> (f64, i64) {
    let mut best = f64::INFINITY;
    let mut sum = 0;
    for _ in 0..runs {
        let start = Instant::now();
        sum = black_box(f());
        let ns = start.elapsed().as_nanos() as f64;
        if ns < best {
            best = ns;
        }
    }
    (best, sum)
}

fn build<K: KeyKind, T: Table<K>>(keys: &[K], expected: usize, load: Load) -> T {
    let mut t = T::fresh(expected, load);
    for (i, k) in keys.iter().enumerate() {
        t.put(k.clone(), i as i64);
    }
    t
}

/// (nanoseconds per operation, checksum) of MODE.
fn run_mode<K: KeyKind, T: Table<K>>(kind: &str, mode: &str, p: &Params) -> (f64, i64) {
    let keys = K::keys(kind, p.n);
    let n = p.n;
    match mode {
        "build" | "presized" => {
            let expected = if mode == "build" { 0 } else { n };
            let (ns, sum) = best(p.runs, || {
                let mut sum = 0i64;
                for _ in 0..p.reps {
                    let t: T = build(black_box(&keys), expected, p.load);
                    sum += t.size() as i64;
                }
                sum
            });
            (ns / (p.reps * n) as f64, sum)
        }
        "hit" => {
            let t: T = build(&keys, 0, p.load);
            let queries: Vec<K> = (0..p.m).map(|j| keys[query(j, n)].clone()).collect();
            let (ns, sum) = best(p.runs, || {
                let mut sum = 0i64;
                for q in &queries {
                    sum += t.get(black_box(q), -1);
                }
                sum
            });
            (ns / p.m as f64, sum)
        }
        "miss" => {
            let t: T = build(&keys, 0, p.load);
            let misses = K::misses(kind, p.m);
            let (ns, sum) = best(p.runs, || {
                let mut sum = 0i64;
                for q in &misses {
                    sum += t.get(black_box(q), 1);
                }
                sum
            });
            (ns / p.m as f64, sum)
        }
        "member" => {
            let t: T = build(&keys, 0, p.load);
            let misses = K::misses(kind, p.m);
            let queries: Vec<K> = (0..p.m).map(|j| keys[query(j, n)].clone()).collect();
            let (ns, sum) = best(p.runs, || {
                let mut sum = 0i64;
                for (q, r) in queries.iter().zip(misses.iter()) {
                    sum += t.has(black_box(q)) as i64 + t.has(black_box(r)) as i64;
                }
                sum
            });
            (ns / (2 * p.m) as f64, sum)
        }
        "replace" => {
            let mut t: T = build(&keys, 0, p.load);
            let queries: Vec<K> = (0..p.m).map(|j| keys[query(j, n)].clone()).collect();
            let (ns, sum) = best(p.runs, || {
                for (j, q) in queries.iter().enumerate() {
                    t.put(black_box(q.clone()), j as i64);
                }
                t.size() as i64
            });
            (ns / p.m as f64, sum)
        }
        "drop" => {
            let (ns, sum) = best(p.runs, || {
                let mut sum = 0i64;
                for _ in 0..p.reps {
                    let mut t: T = build(&keys, 0, p.load);
                    for k in &keys {
                        t.remove(black_box(k));
                    }
                    sum += t.size() as i64;
                }
                sum
            });
            // Includes the build: subtract a "build" row for drop alone.
            (ns / (p.reps * n) as f64, sum)
        }
        m if m.starts_with("life") => {
            let lookups: usize = m[4..].parse().expect("life L");
            let queries: Vec<K> = (0..lookups).map(|j| keys[query(j, n)].clone()).collect();
            let (ns, sum) = best(p.runs, || {
                let mut sum = 0i64;
                for _ in 0..p.reps {
                    let t: T = build(black_box(&keys), 0, p.load);
                    for q in &queries {
                        sum += t.get(q, -1);
                    }
                }
                sum
            });
            (ns / p.reps as f64, sum)
        }
        _ => panic!("unknown mode {mode}"),
    }
}

fn dispatch_impl<K: KeyKind>(imp: &str, kind: &str, mode: &str, p: &Params) -> (f64, i64) {
    match imp {
        "listmap" => run_mode::<K, ListMap<K>>(kind, mode, p),
        "chain" => run_mode::<K, Chain<K>>(kind, mode, p),
        "lp" => run_mode::<K, Lp<K>>(kind, mode, p),
        "rh" => run_mode::<K, Rh<K>>(kind, mode, p),
        "std" => run_mode::<K, Std<K>>(kind, mode, p),
        "stdb" => run_mode::<K, StdB<K>>(kind, mode, p),
        _ => panic!("unknown implementation {imp}"),
    }
}

fn dispatch(imp: &str, kind: &str, mode: &str, p: &Params) -> (f64, i64) {
    match kind {
        "int-dense" | "int-sparse" | "int-collide" => dispatch_impl::<i64>(imp, kind, mode, p),
        "int-big" => dispatch_impl::<Big>(imp, kind, mode, p),
        "str-short" | "str-medium" => dispatch_impl::<String>(imp, kind, mode, p),
        "point" => dispatch_impl::<Point>(imp, kind, mode, p),
        _ => panic!("unknown key kind {kind}"),
    }
}

// ---------------------------------------------------------------------------
// Mixed workloads (SPEC.md section 6; drivers/bfs.bot, memo.bot, freq.bot)

/// Breadth-first search over a W x W grid from (0, 0); a cell is a wall when
/// (7x + 13y) mod 11 == 0, except the start. Visited: Point -> distance.
/// The checksum is the sum of every reached cell's distance plus the count.
fn bfs<T: Table<Point>>(w: i64) -> i64 {
    let wall = |x: i64, y: i64| (x != 0 || y != 0) && (7 * x + 13 * y) % 11 == 0;
    let mut seen = T::fresh(0, Load { num: 7, den: 10 });
    let mut queue: Vec<Point> = vec![Point { x: 0, y: 0 }];
    seen.put(Point { x: 0, y: 0 }, 0);
    let mut head = 0;
    let mut sum = 0;
    while head < queue.len() {
        let p = queue[head].clone();
        head += 1;
        let d = seen.get(&p, -1);
        sum += d;
        for (dx, dy) in [(1, 0), (0, 1), (-1, 0), (0, -1)] {
            let (x, y) = (p.x + dx, p.y + dy);
            if x < 0 || y < 0 || x >= w || y >= w || wall(x, y) {
                continue;
            }
            let q = Point { x, y };
            if !seen.has(&q) {
                seen.put(q.clone(), d + 1);
                queue.push(q);
            }
        }
    }
    sum + seen.size() as i64
}

/// Collatz step counts of 1..=N, memoized (every value met is inserted).
fn memo<T: Table<i64>>(n: i64) -> i64 {
    fn steps<T: Table<i64>>(memo: &mut T, v: i64) -> i64 {
        if v == 1 {
            return 0;
        }
        let found = memo.get(&v, -1);
        if found >= 0 {
            return found;
        }
        let next = if v & 1 == 0 { v >> 1 } else { 3 * v + 1 };
        let s = steps(memo, next) + 1;
        memo.put(v, s);
        s
    }
    let mut table = T::fresh(0, Load { num: 7, den: 10 });
    let mut sum = 0;
    for i in 1..=n {
        sum += steps(&mut table, i);
    }
    sum
}

/// Word frequencies of T tokens over a vocabulary of V words: token t is
/// word mod(t * 40503 + 7, V), word w is "w" + hex(w * 2654435761 mod 2^32).
/// The checksum is the sum of every count read before its update.
fn freq<T: Table<String>>(tokens: &[String]) -> i64 {
    let mut table = T::fresh(0, Load { num: 7, den: 10 });
    let mut sum = 0;
    for w in tokens {
        let c = table.get(w, 0);
        sum += c;
        table.put(w.clone(), c + 1);
    }
    sum
}

fn freq_tokens(t: usize, v: usize) -> Vec<String> {
    (0..t)
        .map(|i| {
            let w = (i as u64 * 40503 + 7) % v as u64;
            format!("w{:x}", (w * 2654435761) % (1u64 << 32))
        })
        .collect()
}

fn mixed(imp: &str, work: &str, size: usize, runs: usize) -> (f64, i64) {
    macro_rules! with_table {
        ($K:ty, $f:expr) => {
            match imp {
                "listmap" => $f(std::marker::PhantomData::<ListMap<$K>>),
                "chain" => $f(std::marker::PhantomData::<Chain<$K>>),
                "lp" => $f(std::marker::PhantomData::<Lp<$K>>),
                "rh" => $f(std::marker::PhantomData::<Rh<$K>>),
                "std" => $f(std::marker::PhantomData::<Std<$K>>),
                "stdb" => $f(std::marker::PhantomData::<StdB<$K>>),
                _ => panic!("unknown implementation {imp}"),
            }
        };
    }
    match work {
        "bfs" => {
            fn go<T: Table<Point>>(_: std::marker::PhantomData<T>, w: i64, runs: usize) -> (f64, i64) {
                best(runs, || bfs::<T>(black_box(w)))
            }
            with_table!(Point, |t| go(t, size as i64, runs))
        }
        "memo" => {
            fn go<T: Table<i64>>(_: std::marker::PhantomData<T>, n: i64, runs: usize) -> (f64, i64) {
                best(runs, || memo::<T>(black_box(n)))
            }
            with_table!(i64, |t| go(t, size as i64, runs))
        }
        "freq" => {
            let tokens = freq_tokens(size, (size / 16).max(1));
            fn go<T: Table<String>>(_: std::marker::PhantomData<T>, tokens: &[String], runs: usize) -> (f64, i64) {
                best(runs, || freq::<T>(black_box(tokens)))
            }
            with_table!(String, |t| go(t, &tokens, runs))
        }
        _ => panic!("unknown workload {work}"),
    }
}

// ---------------------------------------------------------------------------
// Statistics (SPEC.md; brief sections 20 and 22)

fn percentile(sorted: &[usize], q: f64) -> usize {
    if sorted.is_empty() {
        return 0;
    }
    let i = ((sorted.len() as f64 - 1.0) * q).round() as usize;
    sorted[i]
}

fn summary(mut v: Vec<usize>) -> String {
    v.sort_unstable();
    let mean = v.iter().sum::<usize>() as f64 / v.len().max(1) as f64;
    format!(
        "{mean:.3}\t{}\t{}\t{}\t{}",
        percentile(&v, 0.5),
        percentile(&v, 0.95),
        percentile(&v, 0.99),
        v.last().copied().unwrap_or(0)
    )
}

/// splitmix64's finalizer: a strong mixer, the control for the hash's own
/// distribution (never used by a table).
fn mix64(mut z: u64) -> u64 {
    z = (z ^ (z >> 30)).wrapping_mul(0xbf58476d1ce4e5b9);
    z = (z ^ (z >> 27)).wrapping_mul(0x94d049bb133111eb);
    z ^ (z >> 31)
}

/// Chi-square of KEYS' homes over CAP buckets (expected n / cap each) under
/// hash H, and the number of empty buckets.
fn chi_square(hashes: &[u64], cap: usize) -> (f64, usize) {
    let mut counts = vec![0usize; cap];
    for &h in hashes {
        counts[(h % cap as u64) as usize] += 1;
    }
    let e = hashes.len() as f64 / cap as f64;
    let chi = counts.iter().map(|&c| (c as f64 - e) * (c as f64 - e) / e).sum();
    (chi, counts.iter().filter(|&&c| c == 0).count())
}

fn stats_for<K: KeyKind>(kind: &str, n: usize, load: Load) {
    let keys = K::keys(kind, n);
    let misses = K::misses(kind, n.max(1024));
    let lp: Lp<K> = build(&keys, 0, load);
    let rh: Rh<K> = build(&keys, 0, load);
    let ch: Chain<K> = build(&keys, 0, load);
    let cap = lp.slots();
    let alpha = n as f64 / cap as f64;
    for (name, hit, miss) in [
        ("lp", keys.iter().map(|k| lp.probes(k)).collect::<Vec<_>>(), misses.iter().map(|k| lp.probes(k)).collect::<Vec<_>>()),
        ("rh", keys.iter().map(|k| rh.probes(k)).collect(), misses.iter().map(|k| rh.probes(k)).collect()),
        ("chain", keys.iter().map(|k| ch.probes(k)).collect(), misses.iter().map(|k| ch.probes(k)).collect()),
    ] {
        let slots = if name == "chain" { ch.slots() } else { cap };
        println!(
            "probes\t{kind}\t{n}\t{}/{}\t{name}\t{slots}\t{:.3}\thit\t{}\tmiss\t{}",
            load.num,
            load.den,
            n as f64 / slots as f64,
            summary(hit),
            summary(miss)
        );
    }
    // Chain bucket lengths (a histogram up to 8+).
    let mut hist = [0usize; 9];
    for b in &ch.buckets {
        hist[b.len().min(8)] += 1;
    }
    println!(
        "buckets\t{kind}\t{n}\t{}\t{}",
        ch.slots(),
        hist.iter().map(|c| c.to_string()).collect::<Vec<_>>().join(",")
    );
    // Distribution: the hash's homes against a strong mixer's, at the lp capacity.
    let hashes: Vec<u64> = keys.iter().map(|k| k.bhash()).collect();
    let mixed: Vec<u64> = hashes.iter().map(|&h| mix64(h)).collect();
    let (chi, empty) = chi_square(&hashes, cap);
    let (mchi, mempty) = chi_square(&mixed, cap);
    // Linear probing's expected probe counts at load alpha (Knuth).
    let ehit = 0.5 * (1.0 + 1.0 / (1.0 - alpha));
    let emiss = 0.5 * (1.0 + 1.0 / ((1.0 - alpha) * (1.0 - alpha)));
    println!(
        "distribution\t{kind}\t{n}\t{cap}\t{alpha:.3}\tchi2\t{chi:.1}\tempty\t{empty}\tmixed-chi2\t{mchi:.1}\tmixed-empty\t{mempty}\tknuth-hit\t{ehit:.3}\tknuth-miss\t{emiss:.3}"
    );
}

fn stats(kind: &str, n: usize, load: Load) {
    match kind {
        "int-dense" | "int-sparse" | "int-collide" => stats_for::<i64>(kind, n, load),
        "int-big" => stats_for::<Big>(kind, n, load),
        "str-short" | "str-medium" => stats_for::<String>(kind, n, load),
        "point" => stats_for::<Point>(kind, n, load),
        _ => panic!("unknown key kind {kind}"),
    }
}

// ---------------------------------------------------------------------------
// The cost of one hash, computed without and with the runtime's String

fn hashcost_for<K: KeyKind>(kind: &str, n: usize, runs: usize) {
    let keys = K::keys(kind, n);
    let (stack, _) = best(runs, || keys.iter().map(|k| black_box(k).bhash() as i64 & 1).sum());
    let (alloc, _) = best(runs, || keys.iter().map(|k| black_box(k).bhash_alloc() as i64 & 1).sum());
    let (sip, _) = best(runs, || {
        let b = std::collections::hash_map::RandomState::new();
        keys.iter().map(|k| (b.hash_one(black_box(k)) & 1) as i64).sum()
    });
    println!(
        "hashcost\t{kind}\t{:.2}\t{:.2}\t{:.2}",
        stack / n as f64,
        alloc / n as f64,
        sip / n as f64
    );
}

// ---------------------------------------------------------------------------

fn arg<'a>(args: &'a [String], name: &str, default: &'a str) -> &'a str {
    args.iter().position(|a| a == name).map(|i| args[i + 1].as_str()).unwrap_or(default)
}

fn list(args: &[String], name: &str, default: &str) -> Vec<String> {
    arg(args, name, default).split(',').filter(|s| !s.is_empty()).map(|s| s.to_string()).collect()
}

fn parse_load(text: &str) -> Load {
    let (num, den) = text.split_once('/').expect("load NUM/DEN");
    Load { num: num.parse().unwrap(), den: den.parse().unwrap() }
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let command = args.get(1).map(String::as_str).unwrap_or("help");
    match command {
        "sweep" => {
            // TSV: impl kind mode n m reps load ns-per-op checksum
            let impls = list(&args, "-impls", "listmap,chain,lp,rh,std,stdb");
            let kinds = list(&args, "-keys", "int-dense,int-sparse,int-big,int-collide,str-short,str-medium,point");
            let modes = list(&args, "-modes", "build,presized,hit,miss,replace,drop");
            let sizes = list(&args, "-sizes", "1,2,4,8,16,32,64,128,256,1024,4096,16384");
            let ops: usize = arg(&args, "-ops", "200000").parse().unwrap();
            let runs: usize = arg(&args, "-runs", "5").parse().unwrap();
            let load = parse_load(arg(&args, "-load", "7/10"));
            let max_listmap: usize = arg(&args, "-max-listmap", "1024").parse().unwrap();
            for kind in &kinds {
                for imp in &impls {
                    for size in &sizes {
                        let n: usize = size.parse().unwrap();
                        if imp == "listmap" && n > max_listmap {
                            continue;
                        }
                        // Enough repetitions that a build inserts at least OPS keys.
                        let reps = (ops / n).max(1);
                        let m = if imp == "listmap" { (ops / n.max(1)).clamp(1000, ops) } else { ops };
                        for mode in &modes {
                            let p = Params { n, m, reps, runs, load };
                            let (ns, sum) = dispatch(imp, kind, mode, &p);
                            println!("{imp}\t{kind}\t{mode}\t{n}\t{m}\t{reps}\t{}/{}\t{ns:.2}\t{sum}", load.num, load.den);
                        }
                    }
                }
            }
        }
        "mixed" => {
            // TSV: impl workload size ns checksum
            let impls = list(&args, "-impls", "chain,lp,rh,std,stdb");
            let works = list(&args, "-work", "bfs,memo,freq");
            let runs: usize = arg(&args, "-runs", "5").parse().unwrap();
            for work in &works {
                let sizes = match work.as_str() {
                    "bfs" => list(&args, "-bfs", "64,256"),
                    "memo" => list(&args, "-memo", "10000,100000"),
                    _ => list(&args, "-freq", "16384,262144"),
                };
                for imp in &impls {
                    for size in &sizes {
                        let (ns, sum) = mixed(imp, work, size.parse().unwrap(), runs);
                        println!("{imp}\t{work}\t{size}\t{ns:.0}\t{sum}");
                    }
                }
            }
        }
        "stats" => {
            let kinds = list(&args, "-keys", "int-dense,int-sparse,int-big,int-collide,str-short,str-medium,point");
            let sizes = list(&args, "-sizes", "1024,16384");
            let loads = list(&args, "-loads", "1/2,7/10,17/20");
            for kind in &kinds {
                for size in &sizes {
                    for load in &loads {
                        stats(kind, size.parse().unwrap(), parse_load(load));
                    }
                }
            }
        }
        "hashcost" => {
            let runs: usize = arg(&args, "-runs", "5").parse().unwrap();
            for kind in ["int-dense", "int-sparse", "int-big", "str-short", "str-medium", "point"] {
                match kind {
                    "int-dense" | "int-sparse" => hashcost_for::<i64>(kind, 100000, runs),
                    "int-big" => hashcost_for::<Big>(kind, 100000, runs),
                    "point" => hashcost_for::<Point>(kind, 100000, runs),
                    _ => hashcost_for::<String>(kind, 100000, runs),
                }
            }
        }
        "spike" => {
            // TSV: impl load n mean-ns p99-ns max-ns growths: the latency of
            // single inserts while building N Int keys from fresh(0), best of
            // RUNS per insert position (a growth is the spike).
            let runs: usize = arg(&args, "-runs", "5").parse().unwrap();
            for load in list(&args, "-loads", "1/2,7/10,17/20") {
                let load = parse_load(&load);
                for size in list(&args, "-sizes", "11468,16384,65536") {
                    let n: usize = size.parse().unwrap();
                    let keys = i64::keys("int-dense", n);
                    fn spikes<T: Table<i64>>(keys: &[i64], load: Load, runs: usize) -> (Vec<f64>, usize) {
                        let mut best = vec![f64::INFINITY; keys.len()];
                        let mut growths = 0;
                        for _ in 0..runs {
                            let mut t = T::fresh(0, load);
                            let mut slots = t.slots();
                            growths = 0;
                            for (i, k) in keys.iter().enumerate() {
                                let start = Instant::now();
                                t.put(black_box(*k), i as i64);
                                let ns = start.elapsed().as_nanos() as f64;
                                if ns < best[i] {
                                    best[i] = ns;
                                }
                                if t.slots() != slots {
                                    slots = t.slots();
                                    growths += 1;
                                }
                            }
                            black_box(t.size());
                        }
                        (best, growths)
                    }
                    for imp in ["lp", "rh", "chain"] {
                        let (times, growths) = match imp {
                            "lp" => spikes::<Lp<i64>>(&keys, load, runs),
                            "rh" => spikes::<Rh<i64>>(&keys, load, runs),
                            _ => spikes::<Chain<i64>>(&keys, load, runs),
                        };
                        let mean = times.iter().sum::<f64>() / times.len() as f64;
                        let mut sorted = times.clone();
                        sorted.sort_by(|a, b| a.partial_cmp(b).unwrap());
                        let p99 = sorted[((sorted.len() as f64 - 1.0) * 0.99) as usize];
                        let max = sorted[sorted.len() - 1];
                        println!("{imp}\t{}/{}\t{n}\t{mean:.1}\t{p99:.0}\t{max:.0}\t{growths}", load.num, load.den);
                    }
                }
            }
        }
        "collide" => {
            // collide N RESIDUE: SPEC.md's int-collide keys, one per line.
            let n: usize = args[2].parse().unwrap();
            let residue: u64 = args[3].parse().unwrap();
            for k in collide_keys(n, residue) {
                println!("{k}");
            }
        }
        "check" => {
            // One line per key kind: the hashes of keys 0..4 (tools/check-hash).
            for kind in ["int-dense", "int-sparse", "int-big", "str-short", "str-medium", "point"] {
                let line: Vec<String> = match kind {
                    "int-dense" | "int-sparse" => i64::keys(kind, 5).iter().map(|k| k.bhash().to_string()).collect(),
                    "int-big" => Big::keys(kind, 5).iter().map(|k| k.bhash().to_string()).collect(),
                    "point" => Point::keys(kind, 5).iter().map(|k| k.bhash().to_string()).collect(),
                    _ => String::keys(kind, 5).iter().map(|k| k.bhash().to_string()).collect(),
                };
                println!("{kind}\t{}", line.join(" "));
            }
            println!("int-collide\t{}", collide_keys(5, 0).iter().map(|k| k.to_string()).collect::<Vec<_>>().join(" "));
        }
        _ => {
            eprintln!("usage: hash-table-reference sweep|mixed|stats|hashcost|check [options]");
            std::process::exit(2);
        }
    }
}
