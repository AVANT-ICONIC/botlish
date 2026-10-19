#!/bin/sh
# plan2.sh -- the second half of the hash-table experiment's measurement
# plan (after tools/plan.sh's baseline phases): the lookups timed again as
# passes (bench.tcl -passes, which the first baseline run did not have),
# the mixed workloads at their final sizes, the prototype ladders, the
# merged tree's phases and the unrelated workloads. Arguments as plan.sh's:
#
#   sh audit/hash-table/tools/plan2.sh RESULTS-DIR BASE HASH INLINE MOD BOUNDS VS COMBO PROBE COMBOPROBE
set -u
out=$1; base=$2; hash=$3; inline=$4; mod=$5; bounds=$6; vs=$7; combo=$8; probe=$9; shift 9; comboprobe=$1
here=$(cd "$(dirname "$0")" && pwd)
tclsh=tclsh9.0
reference=$(dirname "$here")/reference/target/release/hash-table-reference
export LANG=C.utf8 LC_ALL=C.utf8
mkdir -p "$out/lookups"
stamp() { echo "$(date +%H:%M:%S) $*"; }
lookups="hit miss member replace"

stamp "baseline membership, the domains the first run did not reach"
BOTLISH_HT_ROOT=$base $tclsh "$here/membership.tcl" -domains int-sparse -strategies phash -runs 5 \
    -out "$out/membership-baseline.tsv" > "$out/membership-rest.log" 2>&1 || stamp "FAILED: membership int-sparse phash"
BOTLISH_HT_ROOT=$base $tclsh "$here/membership.tcl" -domains "str enum" -runs 5 \
    -out "$out/membership-baseline.tsv" >> "$out/membership-rest.log" 2>&1 || stamp "FAILED: membership str enum"

stamp "baseline lookups as passes"
BOTLISH_HT_ROOT=$base $tclsh "$here/run-all.tcl" -tag baseline -results "$out/lookups" -passes 4 -only "$lookups" \
    -phases "sizes keys typed" || stamp "FAILED: baseline lookups"
stamp "baseline mixed"
BOTLISH_HT_ROOT=$base $tclsh "$here/run-all.tcl" -tag baseline -results "$out" -phases mixed || stamp "FAILED: baseline mixed"
stamp "rust mixed, memo 1000"
"$reference" mixed -impls listmap,chain,lp,rh,std,stdb -bfs 64 -memo 1000 -freq 16384 -runs 5 >> "$out/rust-mixed-baseline.tsv" \
    || stamp "FAILED: rust mixed"

stamp "ladder A: every prototype, lpa and lpmask"
$tclsh "$here/ladder.tcl" -trees "base $base hash $hash inline $inline mod $mod bounds $bounds combo $combo" \
    -rounds 3 -out "$out/ladder-a.tsv" -impls "lpa lpmask" -keys "int-dense str-short point" \
    -sizes "1024 16384" -modes "build presized hit miss replace" -runs 5 -passes 4 || stamp "FAILED: ladder A"
stamp "ladder C: the probe primitive before and after the compiler work"
$tclsh "$here/ladder.tcl" -trees "probe $probe comboprobe $comboprobe" -rounds 3 -out "$out/ladder-c.tsv" \
    -impls "lpa lpp lpmask" -keys "int-dense str-short point" -sizes "1024 16384" -modes "build presized hit miss replace" \
    -runs 5 -passes 4 || stamp "FAILED: ladder C"

stamp "run-all combo"
BOTLISH_HT_ROOT=$combo $tclsh "$here/run-all.tcl" -tag combo -results "$out" -passes 4 \
    -phases "sizes keys typed life mixed membership" || stamp "FAILED: run-all combo"

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
    } > "$out/unrelated-$tree.txt" 2>&1 || stamp "  (a benchmark failed: see unrelated-$tree.txt)"
done
stamp "done"
