#!/usr/bin/env python3
# model.py -- the hash-table experiment's independent model
# (HASH-TABLE-EXPERIMENT.md; ../SPEC.md).
#
#   python3 -I audit/hash-table/tools/model.py hash KIND V...      Botlish's hash of values
#   python3 -I audit/hash-table/tools/model.py collide N RESIDUE   SPEC.md's int-collide keys
#   python3 -I audit/hash-table/tools/model.py trace SEED KIND PROFILE ?POLICY?
#                                    a random operation trace, then its expected results
#
# The oracle is a Python dict: it shares nothing with the Botlish tables but
# the interface's meaning (SPEC.md section 4), so a trace both agree on is
# evidence the table implements a map, not only that it computes what it
# computed. The hash reimplementation (bhash) is here only to make keys that
# collide on purpose and to check the tables' probe diagnostics; the oracle
# itself never hashes.
#
# A trace is one operation per line (each line becomes one argv argument of
# drivers/trace.bot):
#
#   p KEY VALUE    put            (no result)
#   g KEY          get, default -1 (result: the value or -1)
#   h KEY          has?            (result: 1 or 0)
#   d KEY          drop            (no result)
#   s              size            (result: the size)
#   c              slots           (result: the capacity SPEC.md section 2
#                                   predicts; only with a POLICY)
#
# A fifth argument "nodrop" makes a trace without "d" operations (for an
# implementation that does not remove keys).
#
# POLICY is the implementation's capacity policy, NUM/DEN (7/10 for lp and
# rh, 1/1 for chain), or "none" (no "c" operations: listmap, ht0, sorted).
#
# KEY is written as the driver's key kind reads it: an Int in decimal
# (int), the text itself (str: never empty of spaces, never starting with a
# space), "X,Y" (point). The expected results are printed after a line
# holding only "=", space-separated.

import random
import sys

FNV_OFFSET = 0xCBF29CE484222325
FNV_PRIME = 0x100000001B3
MASK64 = (1 << 64) - 1
MASK61 = (1 << 61) - 1

# The struct identity text of the key struct the drivers declare (a module's
# struct is MODULE::NAME): checked against compiled programs by
# tools/check-hash.tcl.
POINT_ID = "keys::Point"


def fnv(h, data):
    for b in data:
        h = ((h ^ b) * FNV_PRIME) & MASK64
    return h


def mix(v):
    """The unmasked FNV state of value V (core/hashing.tcl's Mix)."""
    if isinstance(v, bool):
        raise TypeError("no Bool keys in this experiment")
    if isinstance(v, int):
        return fnv(fnv(FNV_OFFSET, [0]), str(v).encode())
    if isinstance(v, str):
        return fnv(fnv(FNV_OFFSET, [1]), v.encode("utf-8"))
    if isinstance(v, tuple):  # a Point {x, y}
        x, y = v
        h = fnv(FNV_OFFSET, [8])
        h = fnv(h, POINT_ID.encode())
        h = fnv(h, (2).to_bytes(8, "little"))
        h = fnv(h, b"x")
        h = fnv(h, mix(x).to_bytes(8, "little"))
        h = fnv(h, b"y")
        h = fnv(h, mix(y).to_bytes(8, "little"))
        return h
    raise TypeError(f"unhashable {v!r}")


def bhash(v):
    return mix(v) & MASK61


def collide(n, residue, modulus=1024):
    out = []
    i = 0
    while len(out) < n:
        if bhash(i) % modulus == residue:
            out.append(i)
        i += 1
    return out


# ---------------------------------------------------------------------------
# Traces

def key_text(kind, k):
    if kind == "point":
        return f"{k[0]},{k[1]}"
    return str(k)


def universe(kind, profile, rng):
    """The keys a trace draws from, by PROFILE:

    small     a handful of keys (many replaces and drops of the same keys)
    grow      enough keys to cross several growth thresholds
    collide   keys whose hashes share their low bits (long probe runs and
              wraparound at every capacity up to the modulus)
    edge      boundary values: 0, negatives, BigInts, empty-ish and
              non-ASCII Strings, astral characters
    """
    size = {"small": 6, "grow": rng.choice([7, 12, 23, 47, 90, 200]), "collide": rng.choice([10, 30, 60]), "edge": 20}[profile]
    if kind == "int":
        if profile == "collide":
            modulus = rng.choice([8, 16, 64])
            residue = rng.randrange(modulus)
            # The keys with the same home in every table of up to MODULUS slots.
            return collide(size, residue, modulus)
        if profile == "edge":
            base = [0, -1, 1, 2**61, 2**63, -(2**63), 2**64 + 1, 10**30, -(10**30), 7, 8, 9]
            return base + [rng.randrange(-(10**20), 10**20) for _ in range(size - len(base))]
        return rng.sample(range(-50, 10 * size + 50), size)
    if kind == "str":
        if profile == "edge":
            base = ["a", "é", "𝔸", "x y", "key", "key0", "Key", "ключ", "ab", "ba", "a,b", "é́"]
            return base + [f"k{rng.randrange(10**6):x}" for _ in range(size - len(base))]
        if profile == "collide":
            modulus = rng.choice([8, 16, 64])
            residue = rng.randrange(modulus)
            out, i = [], 0
            while len(out) < size:
                s = f"c{i:x}"
                if bhash(s) % modulus == residue:
                    out.append(s)
                i += 1
            return out
        return [f"id_{i:x}" for i in rng.sample(range(10 * size + 50), size)]
    if kind == "point":
        if profile == "collide":
            modulus = rng.choice([8, 16, 64])
            residue = rng.randrange(modulus)
            out, x = [], 0
            while len(out) < size:
                p = (x % 37, x // 37)
                if bhash(p) % modulus == residue:
                    out.append(p)
                x += 1
            return out
        if profile == "edge":
            base = [(0, 0), (0, 1), (1, 0), (-1, -1), (2**62, 0), (0, -(2**62))]
            return base + [(rng.randrange(-5, 5), rng.randrange(-5, 5)) for _ in range(size - len(base))]
        return list({(rng.randrange(40), rng.randrange(40)) for _ in range(size)})
    raise ValueError(kind)


def slots_for(expected, num, den):
    cap = 8
    while expected * den > cap * num:
        cap *= 2
    return cap


def trace(seed, kind, profile, policy="none", drops_allowed=True):
    rng = random.Random(f"{seed}/{kind}/{profile}")
    if policy == "none":
        num = den = None
    else:
        num, den = (int(x) for x in policy.split("/"))
    keys = universe(kind, profile, rng)
    model = {}
    ops, expected = [], []
    # Sometimes a presized table ("f N": fresh(N), no result), so capacities
    # other than the growth sequence's are exercised too.
    expected_size = 0
    if rng.random() < 0.3:
        expected_size = rng.randrange(0, 60)
        ops.append(f"f {expected_size}")
    cap = slots_for(expected_size, num, den) if num else 0
    length = rng.choice([10, 40, 120, 400]) if profile != "grow" else 3 * len(keys) + 20
    drops = drops_allowed and rng.random() < 0.7
    for _ in range(length):
        k = rng.choice(keys)
        r = rng.random()
        if r < 0.40:
            v = rng.randrange(10**6)
            ops.append(f"p {key_text(kind, k)} {v}")
            if num and k not in model and (len(model) + 1) * den > cap * num:
                cap *= 2
            model[k] = v
        elif r < 0.60:
            ops.append(f"g {key_text(kind, k)}")
            expected.append(model.get(k, -1))
        elif r < 0.75:
            ops.append(f"h {key_text(kind, k)}")
            expected.append(1 if k in model else 0)
        elif r < 0.90 and drops:
            ops.append(f"d {key_text(kind, k)}")
            model.pop(k, None)
        elif num and r < 0.95:
            ops.append("c")
            expected.append(cap)
        else:
            ops.append("s")
            expected.append(len(model))
    # Every key of the universe once more, then the size: the final state.
    for k in keys:
        ops.append(f"g {key_text(kind, k)}")
        expected.append(model.get(k, -1))
    ops.append("s")
    expected.append(len(model))
    if num:
        ops.append("c")
        expected.append(cap)
    return ops, expected


def main(argv):
    if not argv:
        print(__doc__ if __doc__ else "see the file header", file=sys.stderr)
        return 2
    command = argv[0]
    if command == "hash":
        kind = argv[1]
        for text in argv[2:]:
            if kind == "int":
                v = int(text)
            elif kind == "point":
                x, y = text.split(",")
                v = (int(x), int(y))
            else:
                v = text
            print(bhash(v))
        return 0
    if command == "collide":
        n, residue = int(argv[1]), int(argv[2])
        print(" ".join(str(k) for k in collide(n, residue)))
        return 0
    if command == "trace":
        seed, kind, profile = argv[1], argv[2], argv[3]
        policy = argv[4] if len(argv) > 4 else "none"
        drops_allowed = not (len(argv) > 5 and argv[5] == "nodrop")
        ops, expected = trace(seed, kind, profile, policy, drops_allowed)
        sys.stdout.write("\n".join(ops) + "\n=\n" + " ".join(str(e) for e in expected) + "\n")
        return 0
    print(f"unknown command {command}", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
