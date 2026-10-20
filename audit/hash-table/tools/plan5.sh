#!/bin/sh
# plan5.sh -- the merged tree measured again after the review fixes (the
# merges of the value-semantics, bounds and induction fixes;
# HASH-TABLE-COMPILER-PRESSURE.md, "Found by the adversarial review"):
# deterministic counts only, so it may share the machine. The instruction
# counts of the tables are compared with the pre-fix merged tree's
# (tag combo in RESULTS-DIR/instructions.tsv): equal counts mean the timings
# taken before the fixes stand for the fixed tree. Then the allocation,
# copy, memory and NIR phases, and every table fuzzed on four backends.
#
#   sh audit/hash-table/tools/plan5.sh RESULTS-DIR TREE
set -u
out=$1; tree=$2
here=$(cd "$(dirname "$0")" && pwd)
tclsh=tclsh9.0
export LANG=C.utf8 LC_ALL=C.utf8
stamp() { echo "$(date +%H:%M:%S) $*"; }
counts="$out/instructions.tsv"
lookups="build hit miss replace"

count() {
    stamp "instructions fixed: $*"
    BOTLISH_HT_ROOT=$tree $tclsh "$here/instructions.tcl" -tag fixed -out "$counts" "$@" || stamp "FAILED: instructions $*"
}
count -impls "lpa lpmono lpfact lpmask rh cd chain" -keys "int-dense str-short point" -sizes 1024 -modes "$lookups"
count -impls "lpa lpmask lpmono rh" -keys int-dense -sizes "16 16384" -modes "build hit miss"
count -impls "ht0 lp lpc chain0 lpint" -keys int-dense -sizes 1024 -modes "$lookups"
count -impls lpstr -keys str-short -sizes 1024 -modes "$lookups"

stamp "allocations per lookup"
BOTLISH_HT_ROOT=$tree $tclsh "$here/allocs.tcl" -tag fixed -out "$out/allocs.tsv" \
    -impls "listmap chain0 ht0 chain lpa lpmono lpmask rh cd sorted" -keys "int-dense str-short point" \
    || stamp "FAILED: allocs"

stamp "copies, memory and NIR"
rm -f "$out/copies-fixed.txt" "$out/nir-fixed.txt" "$out/memory-fixed.tsv"
BOTLISH_HT_ROOT=$tree $tclsh "$here/run-all.tcl" -tag fixed -results "$out" -phases "copies memory nir" \
    > "$out/det-fixed.log" 2>&1 || stamp "FAILED: deterministic phases"

stamp "fuzz every table, four backends"
BOTLISH_HT_ROOT=$tree $tclsh "$here/fuzz.tcl" \
    -impls "listmap chain0 ht0 chain lp lpc lpa lpmono lpfact lpmask lpint lpstr rh cd sorted" -seeds 2 \
    > "$out/fuzz-fixed.txt" 2>&1 || stamp "FAILED: fuzz (see fuzz-fixed.txt)"
stamp "done"
