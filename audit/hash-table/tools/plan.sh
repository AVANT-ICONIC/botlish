#!/bin/sh
# plan.sh -- the hash-table experiment's complete measurement plan, as it
# was run for HASH-TABLE-EXPERIMENT.md (on an otherwise idle machine: every
# step is a timing). Each tree argument is a checkout with its native
# backend built:
#
#   sh audit/hash-table/tools/plan.sh RESULTS-DIR BASE HASH INLINE MOD BOUNDS VS COMBO PROBE COMBOPROBE
#
#   BASE        the experiment's baseline compiler (this branch before the
#               prototypes)
#   HASH INLINE MOD BOUNDS VS
#               one prototype each (RO-1, CG-1, CG-2, CP-1..3, VS-1/VS-2/BUG-1)
#   COMBO       all of them merged
#   PROBE       BASE plus the probe primitive (RT-1, branch exp-probe-primitive)
#   COMBOPROBE  COMBO plus the probe primitive
#
# Writes RESULTS-DIR/*.tsv and *.txt; tools/summarize.tcl makes the tables.
set -u
out=$1; base=$2; hash=$3; inline=$4; mod=$5; bounds=$6; vs=$7; combo=$8; probe=$9; shift 9; comboprobe=$1
here=$(cd "$(dirname "$0")" && pwd)
tclsh=tclsh9.0
export LANG=C.utf8 LC_ALL=C.utf8
mkdir -p "$out"
stamp() { echo "$(date +%H:%M:%S) $*"; }

# 1. Every timing phase of the baseline (the reference's sweeps included;
#    copies, memory and nir are deterministic and run separately).
stamp "run-all baseline"
BOTLISH_HT_ROOT=$base $tclsh "$here/run-all.tcl" -tag baseline -results "$out" \
    -phases "rust sizes keys typed life policy mixed backends membership" || stamp "FAILED: run-all baseline"

# 2. Each prototype alone and all of them, on the tables they touch
#    (interleaved per round; summarize.tcl ladder).
stamp "ladder A: every prototype, lpa and lpmask"
$tclsh "$here/ladder.tcl" -trees "base $base hash $hash inline $inline mod $mod bounds $bounds combo $combo" \
    -rounds 3 -out "$out/ladder-a.tsv" -impls "lpa lpmask" -keys "int-dense str-short point" \
    -sizes "1024 16384" -modes "build presized hit miss replace" -runs 5 || stamp "FAILED: ladder A"
stamp "ladder C: the probe primitive before and after the compiler work"
$tclsh "$here/ladder.tcl" -trees "probe $probe comboprobe $comboprobe" -rounds 3 -out "$out/ladder-c.tsv" \
    -impls "lpa lpp lpmask" -keys "int-dense str-short point" -sizes "1024 16384" -modes "build presized hit miss replace" -runs 5 \
    || stamp "FAILED: ladder C"

# 3. The prototypes' effect on everything else the baseline measured.
stamp "run-all combo"
BOTLISH_HT_ROOT=$combo $tclsh "$here/run-all.tcl" -tag combo -results "$out" \
    -phases "sizes keys typed life mixed membership" || stamp "FAILED: run-all combo"

# 4. Workloads unrelated to the experiment, baseline against all prototypes.
for tree in base combo; do
    eval root=\$$tree
    stamp "unrelated workloads: $tree"
    {
        echo "== $tree: bench/2048.tcl"
        $tclsh "$root/bench/2048.tcl" -runs 3 -interp 30 -compile 300
        echo "== $tree: bench/mutable-array.tcl"
        $tclsh "$root/bench/mutable-array.tcl" -runs 3 -backends cranelift
        echo "== $tree: bench/hashtable.tcl"
        $tclsh "$root/bench/hashtable.tcl" -runs 3
        echo "== $tree: bench/corpus.tcl"
        $tclsh "$root/bench/corpus.tcl" -runs 3 -backends cranelift
    } > "$out/unrelated-$tree.txt" 2>&1 || echo "  (a benchmark failed: see unrelated-$tree.txt)"
done
stamp "done"
