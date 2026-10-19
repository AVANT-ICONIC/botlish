#!/bin/sh
# plan4.sh -- the deterministic half of the hash-table experiment's
# measurement plan, after plan3.sh's timings: instructions per operation
# (callgrind) for the tables and trees the first instruction ladder did not
# reach, the Rust reference's counts, managed-heap allocations per lookup,
# per-function profiles, and the copy, memory and NIR phases of the merged
# tree. Counts do not depend on the machine's load, so this may share the
# machine. Arguments as plan.sh's; RESULTS-DIR receives instructions.tsv,
# allocs.tsv, profiles.txt and the run-all phases' files.
#
#   sh audit/hash-table/tools/plan4.sh RESULTS-DIR BASE HASH INLINE MOD BOUNDS VS COMBO PROBE COMBOPROBE
set -u
out=$1; base=$2; hash=$3; inline=$4; mod=$5; bounds=$6; vs=$7; combo=$8; probe=$9; shift 9; comboprobe=$1
here=$(cd "$(dirname "$0")" && pwd)
tclsh=tclsh9.0
export LANG=C.utf8 LC_ALL=C.utf8
stamp() { echo "$(date +%H:%M:%S) $*"; }
counts="$out/instructions.tsv"
lookups="build hit miss replace"

count() {
    root=$1; tag=$2; shift 2
    stamp "instructions $tag: $*"
    BOTLISH_HT_ROOT=$root $tclsh "$here/instructions.tcl" -tag $tag -out "$counts" "$@" || stamp "FAILED: instructions $tag $*"
}

count $combo combo -impls "ht0 lp lpc" -keys "int-dense str-short" -sizes 1024 -modes "$lookups"
count $combo combo -impls chain0 -keys str-short -sizes 1024 -modes "hit miss replace"
count $combo combo -impls lpint -keys int-dense -sizes 1024 -modes "$lookups"
count $combo combo -impls lpstr -keys str-short -sizes 1024 -modes "$lookups"
count $combo combo -impls "lpa lpmask lpmono rh" -keys int-dense -sizes "16 16384" -modes "build hit miss"
count $probe probe -impls "lpa lpp" -keys "int-dense str-short point" -sizes 1024 -modes "$lookups"
count $comboprobe comboprobe -impls "lpa lpp lpmask" -keys "int-dense str-short point" -sizes 1024 -modes "$lookups"
stamp "instructions: the Rust reference"
$tclsh "$here/instructions.tcl" -reference 1 -tag rust -out "$counts" -impls "lp rh chain std stdb" \
    -keys "int-dense str-short point" -sizes 1024 -modes "$lookups" || stamp "FAILED: reference counts"
$tclsh "$here/instructions.tcl" -reference 1 -tag rust -out "$counts" -impls "lp std" \
    -keys int-dense -sizes "16 16384" -modes "build hit miss" || stamp "FAILED: reference counts, sizes"

stamp "allocations per lookup"
for tree in base combo; do
    eval root=\$$tree
    BOTLISH_HT_ROOT=$root $tclsh "$here/allocs.tcl" -tag $tree -out "$out/allocs.tsv" \
        -impls "listmap chain0 ht0 chain lpa lpmono lpmask rh cd sorted" -keys "int-dense str-short point" \
        || stamp "FAILED: allocs $tree"
done
for tree in probe comboprobe; do
    eval root=\$$tree
    BOTLISH_HT_ROOT=$root $tclsh "$here/allocs.tcl" -tag $tree -out "$out/allocs.tsv" -impls lpp \
        -keys "int-dense str-short point" || stamp "FAILED: allocs $tree"
done

stamp "profiles"
for tree in base combo probe comboprobe; do
    eval root=\$$tree
    case $tree in
        base|combo) impls="lpa lpmono lpmask" ;;
        probe) impls="lpa lpp" ;;
        comboprobe) impls="lpp" ;;
    esac
    for impl in $impls; do
        for keys in int-dense str-short point; do
            for mode in hit miss build; do
                echo "== $tree $impl $keys 1024 $mode" >> "$out/profiles.txt"
                BOTLISH_HT_ROOT=$root $tclsh "$here/profile.tcl" -impl $impl -keys $keys -n 1024 -mode $mode \
                    >> "$out/profiles.txt" 2>&1 || stamp "FAILED: profile $tree $impl $keys $mode"
            done
        done
    done
done

stamp "copies, memory and NIR: the merged tree"
rm -f "$out/copies-combo.txt" "$out/nir-combo.txt" "$out/memory-combo.tsv"
BOTLISH_HT_ROOT=$combo $tclsh "$here/run-all.tcl" -tag combo -results "$out" -phases "copies memory nir" \
    > "$out/det-combo.log" 2>&1 || stamp "FAILED: deterministic phases"
stamp "done"
