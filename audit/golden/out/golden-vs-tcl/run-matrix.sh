#!/bin/bash
# run-matrix.sh -- reproduces GOLDEN-VS-TCL-BENCHMARK.md's measurements: the
# Tcl tests the golden manifest ports against the golden suites, on every
# backend, without the front-end cache, through a cold one and a warm one,
# then profiled, then the experiments. About four hours on a 4-core machine.
#
#   bash audit/golden/out/golden-vs-tcl/run-matrix.sh OUT-DIR SCRATCH-DIR
#
# Run it from the repository root, on an otherwise idle machine, with the
# native backend built. OUT-DIR receives one NAME.runs/NAME.meta pair per run
# (bench/golden-vs-tcl.tcl), SCRATCH-DIR the caches. Then:
#
#   tclsh9.0 bench/golden-vs-tcl.tcl report -out OUT-DIR
#
# The benchmark's own runs were taken in three batches (runs/*.meta record
# when each finished); the first batch's Tcl passes ran slower than the same
# passes later (GOLDEN-VS-TCL-BENCHMARK.md, "How it was measured"), so the
# Tcl passes and the warm golden runs were taken again, together, and those
# are the ones the report compares (the first batch's are kept as NAME-s1).
set -u
OUT=$1
SCRATCH=$2
HERE=$(cd "$(dirname "$0")" && pwd)
export LANG=C.utf8 LC_ALL=C.utf8
mkdir -p "$OUT" "$SCRATCH"
B="tclsh9.0 bench/golden-vs-tcl.tcl run -out $OUT -jobs 4"
ALL=interp,compile,cranelift-generic,cranelift
step() { echo "=== $(date +%T) $1"; shift; "$@" | tail -1; }
rm -rf "$SCRATCH"/cache-sep "$SCRATCH"/cache-all "$SCRATCH"/cache-prof "$SCRATCH"/cache-ctl
mkdir -p "$SCRATCH"/cache-ctl

# The Tcl tests the manifest ports (MIGRATED, SPLIT), CORE_BACKEND=B.
for b in interp compile cranelift-generic cranelift; do
  step tcl-$b $B -layer tcl -backends $b -name tcl-$b
done
# The golden suites, one backend per process, no cache.
for b in interp compile cranelift-generic cranelift; do
  step golden-$b $B -layer golden -backends $b -name golden-$b
done
# The golden suites, the four backends in one process per suite, no cache.
step golden-all $B -layer golden -backends $ALL -name golden-all -order "$OUT"/golden-interp.runs
# One backend per process through one cache: interp fills it, the rest hit.
step golden-interp-cold $B -layer golden -backends interp -name golden-interp-cold \
  -hir-cache "$SCRATCH"/cache-sep -order "$OUT"/golden-interp.runs
for b in compile cranelift-generic cranelift interp; do
  step golden-$b-warm $B -layer golden -backends $b -name golden-$b-warm \
    -hir-cache "$SCRATCH"/cache-sep -order "$OUT"/golden-$b.runs
done
# The four backends in one process through a fresh cache, then warm.
step golden-all-cold $B -layer golden -backends $ALL -name golden-all-cold \
  -hir-cache "$SCRATCH"/cache-all -order "$OUT"/golden-all.runs
step golden-all-warm $B -layer golden -backends $ALL -name golden-all-warm \
  -hir-cache "$SCRATCH"/cache-all -order "$OUT"/golden-all.runs
# Profiled (bench/phase-profile.tcl).
for b in interp compile cranelift-generic cranelift; do
  step prof-tcl-$b $B -layer tcl -backends $b -name prof-tcl-$b -profile 1 -order "$OUT"/tcl-$b.runs
done
step prof-golden-all-cold $B -layer golden -backends $ALL -name prof-golden-all-cold -profile 1 \
  -hir-cache "$SCRATCH"/cache-prof -order "$OUT"/golden-all.runs
step prof-golden-all-warm $B -layer golden -backends $ALL -name prof-golden-all-warm -profile 1 \
  -hir-cache "$SCRATCH"/cache-prof -order "$OUT"/golden-all.runs
# Control: BOTLISH_HIR_CACHE set for the Tcl tests (the harness unsets it;
# the directory must stay empty).
step tcl-interp-cachectl $B -layer tcl -backends interp -name tcl-interp-cachectl \
  -hir-cache "$SCRATCH"/cache-ctl -order "$OUT"/tcl-interp.runs
# Which ported Tcl tests run natively in the interp pass.
step coverage $B -layer tcl -backends interp -name coverage \
  -env NATIVE_COVERAGE="$OUT"/native-coverage.txt -order "$OUT"/tcl-interp.runs

# Experiments (no front-end file changes; the cache stays valid).
for suite in struct-representation callables compiled-values; do
  echo "--- $suite"
  tclsh9.0 "$HERE"/experiments/hir-shape.tcl tests/golden/$suite.bot "$SCRATCH"/$suite.hirx
  tclsh9.0 "$HERE"/experiments/hir-shape.tcl -decoded "$SCRATCH"/$suite.hirx
done > "$OUT"/hir-shape.txt 2>&1
for i in 1 2; do
  for m in plain encode store; do
    tclsh9.0 "$HERE"/experiments/store-effect.tcl $m tests/golden/struct-representation.bot "$SCRATCH"/store-cache
  done
done > "$OUT"/store-effect.txt 2>&1
step golden-all-warm-memo $B -layer golden -backends $ALL -name golden-all-warm-memo \
  -hir-cache "$SCRATCH"/cache-all -wrap "$HERE"/experiments/memo-temporaries.tcl -order "$OUT"/golden-all-warm.runs
step golden-all-memo $B -layer golden -backends $ALL -name golden-all-memo \
  -wrap "$HERE"/experiments/memo-temporaries.tcl -order "$OUT"/golden-all.runs
echo "=== $(date +%T) done"
