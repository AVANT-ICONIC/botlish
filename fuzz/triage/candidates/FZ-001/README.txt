id: FZ-001
kind: hang-nonterminating
target: csv-argv
signature: signal|TIMEOUT
nondeterminism-probe: stable
raw-input: /home/markus/botlish-fuzz/fuzz/out/csv-argv/default/hangs/id:000000,src:000004,time:1908,execs:359,op:havoc,rep:6
classification-guess: divergence-or-no-crash (machine-generated; confirm by hand)

vertical replay matrix (replay.tcl, cheapest first):
aot                  (no verdict within 120s -- non-terminating)interp               result|error|TCL LIMIT STACK exit|1compile              (no verdict within 120s -- non-terminating)cranelift            (no verdict within 120s -- non-terminating)cranelift-generic    (no verdict within 120s -- non-terminating)aot+gc-stress        (no verdict within 120s)aot+valgrind         (no verdict within 240s)aot-asan             (no verdict within 120s)
