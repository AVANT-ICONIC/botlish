#!/bin/sh
# plan3.sh -- the measurements added after plan2.sh: the prototype ladders
# again with builds timed as passes too (bench.tcl -build-passes), and the
# constant-membership domains the baseline run could not reach (String
# tries, the enum domain). Arguments as plan.sh's.
#
#   sh audit/hash-table/tools/plan3.sh RESULTS-DIR BASE HASH INLINE MOD BOUNDS VS COMBO PROBE COMBOPROBE
set -u
out=$1; base=$2; hash=$3; inline=$4; mod=$5; bounds=$6; vs=$7; combo=$8; probe=$9; shift 9; comboprobe=$1
here=$(cd "$(dirname "$0")" && pwd)
tclsh=tclsh9.0
export LANG=C.utf8 LC_ALL=C.utf8
stamp() { echo "$(date +%H:%M:%S) $*"; }

stamp "baseline membership: String tries, the enum domain"
BOTLISH_HT_ROOT=$base $tclsh "$here/membership.tcl" -domains str -strategies trie -runs 5 \
    -out "$out/membership-baseline.tsv" > "$out/membership-rest2.log" 2>&1 || stamp "FAILED: membership str trie"
BOTLISH_HT_ROOT=$base $tclsh "$here/membership.tcl" -domains enum -runs 5 \
    -out "$out/membership-baseline.tsv" >> "$out/membership-rest2.log" 2>&1 || stamp "FAILED: membership enum"

stamp "ladder A2: every prototype, lpa and lpmask, builds as passes"
$tclsh "$here/ladder.tcl" -trees "base $base hash $hash inline $inline mod $mod bounds $bounds combo $combo" \
    -rounds 3 -out "$out/ladder-a2.tsv" -impls "lpa lpmask" -keys "int-dense str-short point" \
    -sizes "1024 16384" -modes "build presized hit miss replace drop" -runs 5 -passes 4 -build-passes 3 \
    || stamp "FAILED: ladder A2"
stamp "ladder C2: the probe primitive, builds as passes"
$tclsh "$here/ladder.tcl" -trees "probe $probe comboprobe $comboprobe" -rounds 3 -out "$out/ladder-c2.tsv" \
    -impls "lpa lpp lpmask" -keys "int-dense str-short point" -sizes "1024 16384" \
    -modes "build presized hit miss replace drop" -runs 5 -passes 4 -build-passes 3 || stamp "FAILED: ladder C2"
stamp "done"
