# golden test framework performance

runs 1 (best of); Tcl backends N = 200 cases, native N = 2000 cases


## Compile time

Mixed suites: every third case a rejected block, an unbound name (UNBOUND, decided at resolution) or a typed call with a String (TYPE, decided by the checker); bodies nested in the registration function or each at the top level. Builds: whole-program builds (hir::BuildOnce), the static decision rounds' and the method-sugar decisions'.

| K cases | plain functions, no framework | all passing | builds | UNBOUND, nested | builds | UNBOUND, top level | builds | TYPE, nested | builds | TYPE, top level | builds |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 50 | 175.0 ms | 1453.7 ms | 1 | 1725.3 ms | 2 | 1685.8 ms | 2 | 3106.4 ms | 2 | 3337.8 ms | 2 |
| 100 | 385.7 ms | 2299.5 ms | 1 | 2544.8 ms | 2 | 2834.7 ms | 2 | 4432.8 ms | 2 | 4277.8 ms | 2 |
| 250 | 1105.4 ms | 5358.3 ms | 1 | 5283.2 ms | 2 | 6087.5 ms | 2 | 9506.1 ms | 2 | 10053.7 ms | 2 |
| 500 | 2488.9 ms | 10380.4 ms | 1 | 11387.2 ms | 2 | 12152.4 ms | 2 | 21300.4 ms | 2 | 22283.1 ms | 2 |
| 1000 | 6688.7 ms | 22884.8 ms | 1 | 25358.8 ms | 2 | 25980.7 ms | 2 | 47425.6 ms | 2 | 48470.0 ms | 2 |

The library alone (a suite of no case): 849.4 ms.
