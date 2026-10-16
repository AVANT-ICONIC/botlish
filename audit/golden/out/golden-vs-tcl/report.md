## Runs

| run | finished | layer | backends | HIR cache | jobs | items | wall s | process s summed | CPU s summed | tests passed / failed | problems |
|---|---|---|---|---|---|---|---:|---:|---:|---|---|
| coverage | 2026-10-15 18:46:07 | tcl | interp | off | 4 | 138 | 158.4 | 633.6 | 602.6 | 3252 / 0 | 0 |
| golden-all-cold | 2026-10-15 17:32:18 | golden | interp, compile, cranelift-generic, cranelift | on (88 entries after) | 4 | 88 | 964.2 | 3855.2 | 3785.8 | 18184 / 0 | 0 |
| golden-all-memo | 2026-10-15 19:12:54 | golden | interp, compile, cranelift-generic, cranelift | off | 4 | 88 | 519.2 | 2073.0 | 2036.6 | 18184 / 0 | 0 |
| golden-all-warm-memo | 2026-10-15 19:04:14 | golden | interp, compile, cranelift-generic, cranelift | on (88 entries after) | 4 | 88 | 178.7 | 712.9 | 696.3 | 18184 / 0 | 0 |
| golden-all-warm | 2026-10-15 17:38:31 | golden | interp, compile, cranelift-generic, cranelift | on (88 entries after) | 4 | 88 | 372.8 | 1489.1 | 1459.6 | 18184 / 0 | 0 |
| golden-all | 2026-10-15 16:59:47 | golden | interp, compile, cranelift-generic, cranelift | off | 4 | 88 | 932.6 | 3725.6 | 3670.2 | 18184 / 0 | 0 |
| golden-compile-warm-s1 | 2026-10-15 17:11:57 | golden | compile | on (88 entries after) | 4 | 88 | 159.5 | 637.2 | 625.9 | 4567 / 0 | 0 |
| golden-compile-warm | 2026-10-15 18:41:30 | golden | compile | on (89 entries after) | 4 | 88 | 160.7 | 642.4 | 632.4 | 4567 / 0 | 0 |
| golden-compile | 2026-10-15 16:29:53 | golden | compile | off | 4 | 88 | 636.0 | 2540.6 | 2504.7 | 4567 / 0 | 0 |
| golden-cranelift-generic-warm-s1 | 2026-10-15 17:12:22 | golden | cranelift-generic | on (88 entries after) | 4 | 88 | 24.9 | 99.3 | 95.2 | 4474 / 0 | 0 |
| golden-cranelift-generic-warm | 2026-10-15 18:41:53 | golden | cranelift-generic | on (89 entries after) | 4 | 88 | 23.5 | 93.7 | 90.6 | 4474 / 0 | 0 |
| golden-cranelift-generic | 2026-10-15 16:36:30 | golden | cranelift-generic | off | 4 | 88 | 396.5 | 1582.5 | 1558.7 | 4474 / 0 | 0 |
| golden-cranelift-warm-s1 | 2026-10-15 17:13:55 | golden | cranelift | on (88 entries after) | 4 | 88 | 93.6 | 373.8 | 366.7 | 4576 / 0 | 0 |
| golden-cranelift-warm | 2026-10-15 18:43:28 | golden | cranelift | on (89 entries after) | 4 | 88 | 94.6 | 377.9 | 370.8 | 4576 / 0 | 0 |
| golden-cranelift | 2026-10-15 16:44:14 | golden | cranelift | off | 4 | 88 | 464.2 | 1854.0 | 1823.9 | 4576 / 0 | 0 |
| golden-interp-cold | 2026-10-15 17:09:17 | golden | interp | on (88 entries after) | 4 | 88 | 570.0 | 2277.8 | 2245.2 | 4567 / 0 | 0 |
| golden-interp-s1 | 2026-10-15 16:19:17 | golden | interp | off | 4 | 88 | 604.9 | 2416.7 | 2383.8 | 4567 / 0 | 0 |
| golden-interp-warm-s1 | 2026-10-15 17:16:14 | golden | interp | on (88 entries after) | 4 | 88 | 138.5 | 553.6 | 544.8 | 4567 / 0 | 0 |
| golden-interp-warm | 2026-10-15 18:38:49 | golden | interp | on (89 entries after) | 4 | 88 | 129.8 | 518.9 | 509.8 | 4567 / 0 | 0 |
| golden-interp | 2026-10-15 18:36:39 | golden | interp | off | 4 | 88 | 608.2 | 2430.4 | 2395.5 | 4567 / 0 | 0 |
| prof-golden-all-cold | 2026-10-15 18:05:02 | golden | interp, compile, cranelift-generic, cranelift | on (88 entries after) | 4 | 88 | 962.3 | 3846.2 | 3783.1 | 18184 / 0 | 0 |
| prof-golden-all-warm | 2026-10-15 18:11:29 | golden | interp, compile, cranelift-generic, cranelift | on (88 entries after) | 4 | 88 | 387.4 | 1547.5 | 1521.5 | 18184 / 0 | 0 |
| prof-tcl-compile | 2026-10-15 17:43:45 | tcl | compile | off | 4 | 138 | 155.5 | 621.6 | 588.2 | 3252 / 0 | 0 |
| prof-tcl-cranelift-generic | 2026-10-15 17:46:23 | tcl | cranelift-generic | off | 4 | 138 | 157.2 | 628.5 | 597.4 | 3223 / 29 | 10 |
| prof-tcl-cranelift | 2026-10-15 17:48:59 | tcl | cranelift | off | 4 | 138 | 156.3 | 625.0 | 592.1 | 3223 / 29 | 10 |
| prof-tcl-interp | 2026-10-15 17:41:10 | tcl | interp | off | 4 | 138 | 158.5 | 633.8 | 598.9 | 3252 / 0 | 0 |
| tcl-compile-s1 | 2026-10-15 16:03:10 | tcl | compile | off | 4 | 138 | 195.1 | 780.2 | 748.2 | 3252 / 0 | 0 |
| tcl-compile | 2026-10-15 18:20:51 | tcl | compile | off | 4 | 138 | 169.1 | 676.3 | 643.7 | 3252 / 0 | 0 |
| tcl-cranelift-generic-s1 | 2026-10-15 16:06:19 | tcl | cranelift-generic | off | 4 | 138 | 188.5 | 753.7 | 721.1 | 3223 / 29 | 10 |
| tcl-cranelift-generic | 2026-10-15 18:23:38 | tcl | cranelift-generic | off | 4 | 138 | 166.9 | 667.3 | 636.1 | 3223 / 29 | 10 |
| tcl-cranelift-s1 | 2026-10-15 16:09:13 | tcl | cranelift | off | 4 | 138 | 173.8 | 694.8 | 662.9 | 3223 / 29 | 10 |
| tcl-cranelift | 2026-10-15 18:26:31 | tcl | cranelift | off | 4 | 138 | 172.9 | 691.2 | 658.5 | 3223 / 29 | 10 |
| tcl-interp-cachectl | 2026-10-15 18:14:11 | tcl | interp | on (0 entries after) | 4 | 138 | 161.4 | 645.3 | 613.9 | 3252 / 0 | 0 |
| tcl-interp-s1 | 2026-10-15 15:59:54 | tcl | interp | off | 4 | 138 | 190.3 | 761.0 | 719.5 | 3252 / 0 | 0 |
| tcl-interp | 2026-10-15 18:18:01 | tcl | interp | off | 4 | 138 | 171.7 | 686.3 | 642.7 | 3252 / 0 | 0 |

## Golden runs: compilation and runs (seconds, summed over suites)

| run | compile (front end or cache hit) | interp run | compile run | cranelift-generic run | cranelift run | longest suite |
|---|---:|---:|---:|---:|---:|---|
| golden-all-cold | 1502.0 | 741.3 | 999.1 | 93.9 | 511.6 | mutable-array.bot 529.3 s |
| golden-all-memo | 1403.7 | 190.7 | 28.2 | 90.2 | 352.5 | mutable-array.bot 348.3 s |
| golden-all-warm-memo | 5.0 | 204.0 | 29.2 | 88.6 | 377.9 | destructuring.bot 61.8 s |
| golden-all-warm | 4.6 | 482.9 | 554.3 | 80.8 | 359.4 | destructuring.bot 155.8 s |
| golden-all | 1496.3 | 749.8 | 1004.4 | 91.8 | 375.8 | mutable-array.bot 509.0 s |
| golden-compile-warm-s1 | 4.5 | - | 626.5 | - | - | destructuring.bot 61.3 s |
| golden-compile-warm | 4.7 | - | 631.4 | - | - | destructuring.bot 65.5 s |
| golden-compile | 1521.2 | - | 1008.4 | - | - | mutable-array.bot 442.6 s |
| golden-cranelift-generic-warm-s1 | 4.5 | - | - | 87.8 | - | destructuring.bot 7.2 s |
| golden-cranelift-generic-warm | 4.5 | - | - | 82.6 | - | destructuring.bot 6.2 s |
| golden-cranelift-generic | 1474.3 | - | - | 90.1 | - | mutable-array.bot 337.2 s |
| golden-cranelift-warm-s1 | 4.8 | - | - | - | 361.6 | destructuring.bot 46.0 s |
| golden-cranelift-warm | 4.7 | - | - | - | 366.3 | destructuring.bot 49.9 s |
| golden-cranelift | 1482.8 | - | - | - | 363.8 | mutable-array.bot 362.6 s |
| golden-interp-cold | 1510.7 | 753.6 | - | - | - | mutable-array.bot 389.0 s |
| golden-interp-s1 | 1605.6 | 796.6 | - | - | - | mutable-array.bot 413.7 s |
| golden-interp-warm-s1 | 4.8 | 541.7 | - | - | - | compiled-values.bot 45.9 s |
| golden-interp-warm | 4.4 | 507.7 | - | - | - | compiled-values.bot 44.0 s |
| golden-interp | 1637.6 | 779.2 | - | - | - | mutable-array.bot 431.7 s |
| prof-golden-all-cold | 1484.6 | 749.4 | 1002.3 | 92.1 | 509.7 | mutable-array.bot 519.2 s |
| prof-golden-all-warm | 4.7 | 497.9 | 584.1 | 85.4 | 367.3 | destructuring.bot 165.6 s |

## Tcl runs: test bodies and process overhead (seconds, summed over files)

| run | ported tests run | test bodies | process minus bodies | longest file |
|---|---:|---:|---:|---|
| coverage | 3252 | 619.9 | 13.7 | golden-framework.test 52.4 s |
| prof-tcl-compile | 3252 | 606.8 | 14.9 | golden-framework.test 51.9 s |
| prof-tcl-cranelift-generic | 3252 | 612.2 | 16.4 | golden-framework.test 49.5 s |
| prof-tcl-cranelift | 3252 | 609.6 | 15.3 | golden-framework.test 54.4 s |
| prof-tcl-interp | 3252 | 618.9 | 14.8 | golden-framework.test 53.8 s |
| tcl-compile-s1 | 3252 | 763.4 | 16.8 | golden-framework.test 68.9 s |
| tcl-compile | 3252 | 662.2 | 14.0 | golden-framework.test 60.0 s |
| tcl-cranelift-generic-s1 | 3252 | 738.8 | 14.9 | golden-framework.test 65.5 s |
| tcl-cranelift-generic | 3252 | 652.7 | 14.7 | golden-framework.test 60.0 s |
| tcl-cranelift-s1 | 3252 | 680.1 | 14.7 | golden-framework.test 58.2 s |
| tcl-cranelift | 3252 | 676.0 | 15.1 | golden-framework.test 59.6 s |
| tcl-interp-cachectl | 3252 | 631.5 | 13.9 | golden-framework.test 53.9 s |
| tcl-interp-s1 | 3252 | 743.6 | 17.4 | golden-framework.test 59.3 s |
| tcl-interp | 3252 | 671.4 | 14.9 | golden-framework.test 50.6 s |

## The two layers, backend by backend (wall s / process s summed / CPU s summed)

| backend | Tcl subset | golden, no cache | golden, cache cold | golden, cache warm | golden no cache / Tcl (CPU) | golden warm / Tcl (CPU) |
|---|---|---|---|---|---:|---:|
| interp | 171.7 / 686.3 / 642.7 | 608.2 / 2430.4 / 2395.5 | 570.0 / 2277.8 / 2245.2 | 129.8 / 518.9 / 509.8 | 3.73 | 0.79 |
| compile | 169.1 / 676.3 / 643.7 | 636.0 / 2540.6 / 2504.7 | - / - / - | 160.7 / 642.4 / 632.4 | 3.89 | 0.98 |
| cranelift-generic | 166.9 / 667.3 / 636.1 | 396.5 / 1582.5 / 1558.7 | - / - / - | 23.5 / 93.7 / 90.6 | 2.45 | 0.14 |
| cranelift | 172.9 / 691.2 / 658.5 | 464.2 / 1854.0 / 1823.9 | - / - / - | 94.6 / 377.9 / 370.8 | 2.77 | 0.56 |

All four backends:

| configuration | wall s | process s summed | CPU s summed |
|---|---:|---:|---:|
| Tcl subset, the four CORE_BACKEND passes | 680.7 | 2721.1 | 2581.0 |
| golden, one process per suite and backend, no cache | 2104.9 | 8407.4 | 8282.8 |
| golden, one process per suite and backend, one cache (interp fills it, the rest hit) | 848.8 | 3391.7 | 3339.0 |
| golden, one process per suite (four backends), no cache | 932.6 | 3725.6 | 3670.2 |
| golden, one process per suite (four backends), cache cold | 964.2 | 3855.2 | 3785.8 |
| golden, one process per suite (four backends), cache warm | 372.8 | 1489.1 | 1459.6 |

## Golden suites against the Tcl tests they port (interp; seconds)

A Tcl test's cost is its body time plus an equal share of its file's process time outside test bodies; a Tcl test ported to several suites is divided among them.

| suite | golden tests | Tcl tests ported | Tcl cost | golden process | of which compile | golden warm process | golden/Tcl | warm/Tcl | all four, no cache | all four, warm |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| mutable-array.bot | 233 | 115 | 26.8 | 431.7 | 371.7 | 27.7 | 16.1 | 1.03 | 509.0 | 100.7 |
| destructuring.bot | 378 | 179 | 18.3 | 202.7 | 121.4 | 37.7 | 11.1 | 2.06 | 389.8 | 155.8 |
| compiled-values.bot | 118 | 95 | 50.2 | 121.6 | 62.0 | 44.0 | 2.4 | 0.88 | 170.1 | 88.4 |
| static-compile.bot | 81 | 58 | 9.1 | 93.3 | 78.3 | 10.4 | 10.2 | 1.14 | 115.2 | 32.0 |
| opaque.bot | 91 | 73 | 3.4 | 90.4 | 68.1 | 16.7 | 27.0 | 4.99 | 105.0 | 29.3 |
| methods.bot | 195 | 104 | 16.4 | 89.8 | 64.0 | 14.7 | 5.5 | 0.9 | 139.1 | 51.5 |
| structs-and-enums.bot | 111 | 77 | 5.5 | 81.4 | 69.5 | 7.5 | 14.7 | 1.35 | 103.3 | 22.0 |
| callable-contracts.bot | 92 | 79 | 18.2 | 78.3 | 61.4 | 8.2 | 4.3 | 0.45 | 105.7 | 30.2 |
| stdlib-namespaces.bot | 114 | 49 | 10.2 | 75.7 | 58.2 | 9.5 | 7.4 | 0.93 | 106.4 | 27.5 |
| range-and-contract-values.bot | 78 | 68 | 23.8 | 60.1 | 30.2 | 25.3 | 2.5 | 1.06 | 82.4 | 44.5 |
| refinements.bot | 66 | 52 | 5.0 | 58.8 | 49.3 | 7.2 | 11.7 | 1.43 | 66.7 | 19.0 |
| mutable-vector.bot | 74 | 41 | 15.4 | 56.4 | 44.5 | 8.2 | 3.7 | 0.53 | 85.2 | 27.8 |
| imports.bot | 59 | 36 | 3.4 | 55.8 | 49.4 | 2.5 | 16.4 | 0.73 | 55.2 | 9.0 |
| declared-errors.bot | 115 | 74 | 11.6 | 54.0 | 35.6 | 10.5 | 4.7 | 0.91 | 92.6 | 35.8 |
| traits.bot | 71 | 45 | 3.8 | 52.3 | 40.9 | 8.7 | 13.9 | 2.32 | 55.8 | 18.0 |
| callables.bot | 113 | 101 | 10.1 | 44.8 | 28.0 | 12.4 | 4.4 | 1.23 | 69.9 | 38.9 |
| coroutines.bot | 62 | 47 | 9.1 | 41.2 | 23.2 | 12.5 | 4.5 | 1.37 | 76.2 | 36.3 |
| contexts.bot | 88 | 49 | 10.1 | 40.9 | 26.6 | 8.7 | 4.0 | 0.86 | 53.9 | 26.6 |
| struct-representation.bot | 110 | 98 | 26.1 | 39.9 | 11.2 | 19.6 | 1.5 | 0.75 | 99.3 | 59.6 |
| abi-bytes.bot | 103 | 57 | 32.0 | 38.6 | 16.3 | 15.0 | 1.2 | 0.47 | 72.4 | 35.7 |
| validators-and-proofs.bot | 153 | 54 | 8.9 | 37.9 | 19.3 | 11.8 | 4.2 | 1.32 | 67.6 | 39.6 |
| framework-semantics.bot | 29 | 17 | 50.6 | 30.9 | 26.4 | 3.1 | 0.6 | 0.06 | 34.1 | 7.9 |
| ownership.bot | 38 | 13 | 3.0 | 28.7 | 23.1 | 3.3 | 9.5 | 1.11 | 37.2 | 6.8 |
| core-semantics.bot | 141 | 119 | 6.2 | 28.6 | 14.9 | 9.9 | 4.6 | 1.6 | 59.7 | 34.4 |
| flags.bot | 100 | 98 | 10.0 | 26.2 | 8.8 | 12.6 | 2.6 | 1.25 | 69.2 | 42.7 |
| strings.bot | 94 | 102 | 32.0 | 24.3 | 9.3 | 11.2 | 0.8 | 0.35 | 41.7 | 26.4 |
| raw-int-abi.bot | 52 | 50 | 31.6 | 23.5 | 3.8 | 18.2 | 0.7 | 0.58 | 41.2 | 26.2 |
| loop-collecting.bot | 110 | 110 | 8.5 | 23.2 | 11.0 | 8.6 | 2.7 | 1.01 | 54.6 | 31.9 |
| affinity.bot | 67 | 32 | 10.0 | 22.2 | 13.6 | 6.5 | 2.2 | 0.66 | 43.2 | 21.5 |
| abi-numeric.bot | 87 | 34 | 10.5 | 22.0 | 8.7 | 10.3 | 2.1 | 0.98 | 40.8 | 23.1 |
| types.bot | 96 | 93 | 2.7 | 22.0 | 12.7 | 7.6 | 8.1 | 2.79 | 39.7 | 20.1 |
| collections.bot | 44 | 23 | 3.0 | 20.3 | 14.5 | 3.2 | 6.9 | 1.08 | 33.7 | 8.2 |
| modules.bot | 31 | 12 | 3.1 | 18.3 | 12.4 | 4.6 | 5.8 | 1.45 | 28.4 | 10.8 |
| native-aggregates.bot | 70 | 69 | 13.0 | 18.3 | 5.5 | 10.1 | 1.4 | 0.78 | 49.1 | 36.8 |
| native-values.bot | 89 | 62 | 11.3 | 17.0 | 4.4 | 9.8 | 1.5 | 0.87 | 35.4 | 21.4 |
| loop-collecting-refined-checks.bot | 1 | 1 | 1.9 | 15.9 | 1.6 | 13.3 | 8.5 | 7.09 | 20.1 | 17.3 |
| string-natives.bot | 82 | 81 | 35.2 | 15.3 | 5.8 | 7.4 | 0.4 | 0.21 | 39.7 | 23.2 |
| lists-and-sets.bot | 86 | 89 | 5.3 | 13.3 | 7.2 | 5.0 | 2.5 | 0.94 | 28.8 | 14.1 |
| diagnostics.bot | 27 | 24 | 0.7 | 12.2 | 9.3 | 1.7 | 17.0 | 2.37 | 18.7 | 4.2 |
| string-representations.bot | 48 | 50 | 29.3 | 9.7 | 3.2 | 4.9 | 0.3 | 0.17 | 26.8 | 13.6 |
| values.bot | 32 | 36 | 5.6 | 9.6 | 4.2 | 4.2 | 1.7 | 0.75 | 23.4 | 11.8 |
| method-equivalence.bot | 45 | 36 | 2.7 | 9.4 | 5.7 | 1.6 | 3.5 | 0.61 | 17.7 | 6.9 |
| imports-library-modules.bot | 12 | 11 | 1.4 | 9.2 | 5.6 | 1.3 | 6.6 | 0.92 | 16.1 | 6.0 |
| method-equivalence-imported.bot | 13 | 9 | 0.8 | 8.9 | 7.2 | 1.2 | 11.8 | 1.52 | 17.3 | 4.1 |
| linux-io.bot | 55 | 26 | 5.1 | 8.8 | 5.5 | 2.0 | 1.7 | 0.38 | 13.8 | 5.3 |
| closure-escape.bot | 49 | 47 | 6.7 | 8.7 | 3.3 | 4.2 | 1.3 | 0.62 | 24.6 | 11.7 |
| bits-bytes-hashing.bot | 47 | 51 | 20.0 | 8.4 | 3.1 | 4.0 | 0.4 | 0.2 | 20.7 | 8.8 |
| warning-programs.bot | 42 | 37 | 2.7 | 8.3 | 5.7 | 1.0 | 3.1 | 0.35 | 15.0 | 5.7 |
| compiled-values-struct-transport.bot | 18 | 17 | 6.8 | 7.9 | 3.5 | 1.8 | 1.2 | 0.26 | 17.2 | 7.7 |
| loops.bot | 55 | 72 | 2.2 | 7.8 | 3.2 | 2.4 | 3.5 | 1.07 | 19.1 | 9.2 |
| gc-sensitive-values.bot | 22 | 24 | 7.0 | 7.3 | 2.5 | 2.6 | 1.0 | 0.37 | 12.1 | 6.7 |
| destructuring-instances.bot | 55 | 22 | 3.3 | 7.0 | 2.6 | 2.1 | 2.1 | 0.62 | 15.6 | 8.5 |
| representation.bot | 13 | 11 | 2.0 | 6.5 | 3.7 | 0.8 | 3.3 | 0.39 | 9.2 | 3.8 |
| errors.bot | 24 | 20 | 2.0 | 5.6 | 4.4 | 1.0 | 2.8 | 0.51 | 12.1 | 4.6 |
| names-and-scoping.bot | 58 | 61 | 1.0 | 5.0 | 2.6 | 1.9 | 5.0 | 1.9 | 10.0 | 6.8 |
| completion-regressions.bot | 23 | 11 | 2.0 | 4.5 | 3.4 | 0.9 | 2.2 | 0.42 | 6.4 | 3.0 |
| imports-abi-child.bot | 17 | 10 | 0.9 | 4.5 | 2.6 | 0.7 | 4.9 | 0.81 | 5.7 | 2.7 |
| unicode-strings.bot | 56 | 56 | 14.9 | 4.1 | 2.2 | 1.2 | 0.3 | 0.08 | 6.4 | 3.5 |
| recursive-types.bot | 9 | 4 | 1.4 | 3.2 | 2.6 | 0.7 | 2.3 | 0.51 | 5.0 | 2.2 |
| struct-representation-instances.bot | 15 | 14 | 1.7 | 3.1 | 1.9 | 0.6 | 1.9 | 0.38 | 4.8 | 2.3 |
| callable-contracts-returned.bot | 4 | 6 | 0.8 | 3.1 | 2.4 | 0.4 | 4.1 | 0.5 | 4.1 | 1.9 |
| imports-unimported.bot | 16 | 6 | 0.3 | 2.9 | 1.9 | 0.9 | 11.6 | 3.68 | 4.7 | 2.6 |
| harness.bot | 13 | 13 | 1.0 | 2.8 | 1.6 | 1.1 | 2.7 | 1.09 | 5.7 | 3.9 |
| declared-errors-imports.bot | 10 | 2 | 0.1 | 2.7 | 1.7 | 0.8 | 20.8 | 6.17 | 4.4 | 2.2 |
| hir-values.bot | 14 | 12 | 0.5 | 2.7 | 1.7 | 0.9 | 4.9 | 1.65 | 4.7 | 2.7 |
| methods-byte-without-list.bot | 3 | 2 | 0.0 | 2.7 | 1.7 | 1.0 | 56.4 | 21.69 | 4.4 | 2.5 |
| methods-list-without-str.bot | 3 | 2 | 0.0 | 2.6 | 1.6 | 0.8 | 76.7 | 24.01 | 3.7 | 2.1 |
| callable-contracts-contravariant.bot | 4 | 1 | 0.1 | 2.3 | 1.9 | 0.4 | 27.6 | 4.98 | 4.0 | 1.8 |
| static-compile-erased-consumer.bot | 2 | 1 | 0.4 | 2.2 | 1.9 | 0.3 | 5.7 | 0.88 | 3.2 | 1.6 |
| callable-contracts-fallback.bot | 4 | 3 | 0.3 | 2.2 | 1.8 | 0.3 | 8.9 | 1.3 | 3.7 | 1.9 |
| methods-type-import-only.bot | 1 | 1 | 0.0 | 2.2 | 1.6 | 0.5 | 127.5 | 30.4 | 3.3 | 1.6 |
| callable-contracts-contravariant-rejected.bot | 2 | 1 | 0.0 | 2.1 | 1.7 | 0.4 | 109.2 | 18.79 | 3.2 | 1.7 |
| traits-path.bot | 2 | 2 | 0.4 | 2.1 | 1.8 | 0.4 | 5.0 | 0.88 | 3.1 | 1.8 |
| stdlib-namespaces-unimported.bot | 2 | 1 | 0.0 | 1.9 | 1.6 | 0.3 | 75.2 | 12.73 | 2.6 | 1.4 |
| stdlib-namespaces-str-only.bot | 1 | 1 | 0.0 | 1.8 | 1.5 | 0.3 | 71.8 | 12.09 | 2.8 | 1.4 |
| imports-abi-family.bot | 6 | 5 | 0.5 | 1.8 | 1.2 | 0.4 | 3.8 | 0.91 | 3.3 | 1.8 |
| methods-struct-instances.bot | 8 | 5 | 0.6 | 1.7 | 1.2 | 0.4 | 2.9 | 0.69 | 2.6 | 1.4 |
| abi-bytes-native.bot | - | 3 | 3.0 | 1.7 | 0.0 | 0.1 | 0.5 | 0.03 | 2.5 | 1.2 |
| structs-and-enums-instances.bot | 4 | 4 | 0.2 | 1.5 | 1.1 | 0.3 | 7.7 | 1.63 | 2.6 | 1.3 |
| linux-io-native.bot | - | 4 | 1.1 | 1.5 | 0.0 | 0.1 | 1.3 | 0.08 | 2.5 | 1.2 |
| structs-and-enums-qualifiers.bot | 2 | 1 | 0.0 | 1.4 | 1.1 | 0.3 | 47.9 | 11.03 | 2.5 | 1.5 |
| callable-contracts-unerased.bot | 1 | 1 | 0.1 | 1.3 | 1.0 | 0.3 | 9.6 | 2.02 | 2.5 | 1.5 |
| mutable-vector-str.bot | 1 | 1 | 0.2 | 1.3 | 1.0 | 0.3 | 7.8 | 1.9 | 2.5 | 1.5 |
| callable-contracts-handle.bot | 1 | 1 | 0.1 | 1.3 | 1.0 | 0.3 | 20.5 | 4.72 | 2.4 | 1.4 |
| opaque-instances.bot | 1 | 1 | 0.0 | 1.3 | 0.9 | 0.4 | 26.0 | 8.07 | 2.5 | 1.3 |
| abi-numeric-native.bot | - | 1 | 0.5 | 1.2 | 0.0 | 0.1 | 2.3 | 0.15 | 2.2 | 1.0 |
| closure-escape-instances.bot | 1 | 1 | 0.2 | 1.2 | 0.9 | 0.3 | 5.8 | 1.41 | 2.4 | 1.2 |
| stdlib-namespaces-entry-members.bot | 4 | 2 | 0.2 | 1.2 | 0.9 | 0.3 | 5.9 | 1.64 | 2.3 | 1.4 |
| total | 4567 | 3289 | 686.3 | 2430.4 | 1637.6 | 518.9 | 3.54 | 0.76 | 3725.6 | 1489.1 |

## Profile: prof-golden-all-cold

Processes 3846.2 s summed; inside the profiler 3843.7 s; in profiled phases 3843.4 s.

Top-level phases (inclusive):

| phase | s | share of process time |
|---|---:|---:|
| golden:compile | 1484.6 | 38.6% |
| run:compile | 1002.3 | 26.1% |
| run:interp | 749.4 | 19.5% |
| run:cranelift | 509.7 | 13.3% |
| run:cranelift-generic | 92.1 | 2.4% |
| load | 5.3 | 0.1% |
| (outside every phase: process start, tcltest, test bodies' own Tcl, runner) | 2.8 | 0.1% |

Self time per phase (top 30):

| phase | self s | calls | share of profiled |
|---|---:|---:|---:|
| affine-temporaries | 1518.7 | 162105 | 39.5% |
| signatures | 571.9 | 321 | 14.9% |
| native:specialize | 228.3 | 169 | 5.9% |
| evalProgram | 190.2 | 85 | 4.9% |
| semantic-instances | 188.7 | 321 | 4.9% |
| hygiene | 168.2 | 328 | 4.4% |
| native:block-escape | 154.4 | 338 | 4.0% |
| errorsets | 116.5 | 321 | 3.0% |
| static-decisions | 93.9 | 88 | 2.4% |
| native:range | 93.6 | 169 | 2.4% |
| affine | 60.4 | 321 | 1.6% |
| native:lower-function | 53.2 | 24647 | 1.4% |
| static-deps | 44.8 | 67 | 1.2% |
| resolve | 40.7 | 328 | 1.1% |
| contexts | 28.9 | 321 | 0.8% |
| declared-params | 27.5 | 321 | 0.7% |
| parse | 22.8 | 516 | 0.6% |
| coroutines | 18.7 | 321 | 0.5% |
| coroutines-verify | 17.7 | 321 | 0.5% |
| native:escape | 16.8 | 169 | 0.4% |
| native:driver | 14.4 | 169 | 0.4% |
| compile:block-lowering | 13.6 | 42607 | 0.4% |
| native:lower | 13.4 | 169 | 0.3% |
| callables | 13.4 | 321 | 0.3% |
| frontend:readProgramFile | 12.6 | 88 | 0.3% |
| native:short-string | 11.7 | 169 | 0.3% |
| compile:block | 11.3 | 14800 | 0.3% |
| declared-results | 10.7 | 321 | 0.3% |
| compile:run-unit-in | 9.9 | 85 | 0.3% |
| compile:generate | 8.0 | 85 | 0.2% |

Per backend run (self time of its phases, top 8 each):

| run root | s | top phases |
|---|---:|---|
| golden:compile | 1484.6 | signatures 571.9, semantic-instances 188.7, hygiene 168.2, errorsets 116.5, static-decisions 93.9, affine 60.4, static-deps 44.8, resolve 40.7 |
| run:compile | 1002.3 | affine-temporaries 963.8, compile:block 11.3, compile:run-unit-in 9.9, compile:block-lowering 8.5, compile:generate 8.0, compile:run-unit 0.5, compile:define 0.2, run:compile 0.1 |
| run:interp | 749.4 | affine-temporaries 553.6, evalProgram 190.2, compile:block-lowering 5.1, interp:core-ir-lowering 0.3, run:interp 0.1, activate 0.0 |
| run:cranelift | 509.7 | native:specialize 216.9, native:block-escape 149.9, native:range 75.9, native:lower-function 27.1, native:escape 8.8, native:lower 7.9, native:driver 7.5, native:short-string 6.9 |
| run:cranelift-generic | 92.1 | native:lower-function 26.1, native:range 17.7, native:specialize 11.4, native:escape 8.0, native:driver 6.9, native:lower 5.5, native:short-string 4.8, native:block-escape 4.6 |

## Profile: prof-golden-all-warm

Processes 1547.5 s summed; inside the profiler 1545.1 s; in profiled phases 1544.9 s.

Top-level phases (inclusive):

| phase | s | share of process time |
|---|---:|---:|
| run:compile | 584.1 | 37.7% |
| run:interp | 497.9 | 32.2% |
| run:cranelift | 367.3 | 23.7% |
| run:cranelift-generic | 85.4 | 5.5% |
| load | 5.3 | 0.3% |
| golden:compile | 4.7 | 0.3% |
| (outside every phase: process start, tcltest, test bodies' own Tcl, runner) | 2.6 | 0.2% |

Self time per phase (top 30):

| phase | self s | calls | share of profiled |
|---|---:|---:|---:|
| affine-temporaries | 851.8 | 162105 | 55.1% |
| evalProgram | 188.4 | 85 | 12.2% |
| native:specialize | 161.3 | 169 | 10.4% |
| native:block-escape | 108.8 | 338 | 7.0% |
| native:range | 66.0 | 169 | 4.3% |
| native:lower-function | 48.7 | 24647 | 3.2% |
| native:escape | 15.5 | 169 | 1.0% |
| native:driver | 14.6 | 169 | 0.9% |
| native:lower | 12.7 | 169 | 0.8% |
| compile:block-lowering | 12.4 | 42607 | 0.8% |
| compile:block | 11.1 | 14800 | 0.7% |
| native:short-string | 10.9 | 169 | 0.7% |
| compile:run-unit-in | 10.2 | 85 | 0.7% |
| compile:generate | 7.6 | 85 | 0.5% |
| native:construction | 6.8 | 169 | 0.4% |
| load | 5.3 | 8272 | 0.3% |
| native:string-region | 4.2 | 169 | 0.3% |
| cache:decode | 2.8 | 88 | 0.2% |
| native:raw-abi | 2.1 | 169 | 0.1% |
| interp:core-ir-lowering | 0.7 | 85 | 0.0% |
| cache:lookup | 0.6 | 88 | 0.0% |
| read-file | 0.6 | 692 | 0.0% |
| cache:fingerprint | 0.5 | 88 | 0.0% |
| compile:run-unit | 0.3 | 85 | 0.0% |
| compile:define | 0.2 | 85 | 0.0% |
| native:traversal | 0.2 | 169 | 0.0% |
| run:cranelift-generic | 0.1 | 81 | 0.0% |
| run:cranelift | 0.1 | 88 | 0.0% |
| run:interp | 0.1 | 85 | 0.0% |
| frontend:readProgramFile | 0.1 | 88 | 0.0% |

Per backend run (self time of its phases, top 8 each):

| run root | s | top phases |
|---|---:|---|
| run:compile | 584.1 | affine-temporaries 547.0, compile:block 11.1, compile:run-unit-in 10.2, compile:block-lowering 7.7, compile:generate 7.6, compile:run-unit 0.3, compile:define 0.2, run:compile 0.1 |
| run:interp | 497.9 | affine-temporaries 304.1, evalProgram 188.4, compile:block-lowering 4.6, interp:core-ir-lowering 0.7, run:interp 0.1, activate 0.0 |
| run:cranelift | 367.3 | native:specialize 151.0, native:block-escape 104.7, native:range 49.6, native:lower-function 24.4, native:escape 8.3, native:driver 7.6, native:lower 7.4, native:short-string 6.5 |
| run:cranelift-generic | 85.4 | native:lower-function 24.3, native:range 16.4, native:specialize 10.3, native:escape 7.2, native:driver 7.0, native:lower 5.3, native:short-string 4.4, native:block-escape 4.0 |
| golden:compile | 4.7 | cache:decode 2.8, cache:lookup 0.6, read-file 0.6, cache:fingerprint 0.5, frontend:readProgramFile 0.1, activate 0.0, golden:compile 0.0 |

## Profile: prof-tcl-compile

Processes 621.6 s summed; inside the profiler 619.2 s; in profiled phases 583.9 s.

Top-level phases (inclusive):

| phase | s | share of process time |
|---|---:|---:|
| frontend:compile | 132.8 | 21.4% |
| native:lower | 120.2 | 19.3% |
| evalProgram | 108.3 | 17.4% |
| frontend:readProgramFile | 81.6 | 13.1% |
| native:driver | 65.4 | 10.5% |
| compile:generate | 23.2 | 3.7% |
| interp:core-ir-lowering | 13.5 | 2.2% |
| load | 11.0 | 1.8% |
| compile:run-unit | 6.5 | 1.1% |
| run:cranelift | 6.5 | 1.1% |
| run:compile | 5.6 | 0.9% |
| run:interp | 5.2 | 0.8% |
| build | 2.0 | 0.3% |
| native:specialize | 0.6 | 0.1% |
| parse | 0.6 | 0.1% |
| compile:define | 0.3 | 0.0% |
| native:prepare | 0.2 | 0.0% |
| frontend:hir-build | 0.1 | 0.0% |
| native:range | 0.1 | 0.0% |
| native:escape | 0.0 | 0.0% |
| activate | 0.0 | 0.0% |
| read-file | 0.0 | 0.0% |
| finish | 0.0 | 0.0% |
| method-decisions | 0.0 | 0.0% |
| (outside every phase: process start, tcltest, test bodies' own Tcl, runner) | 37.7 | 6.1% |

Self time per phase (top 30):

| phase | self s | calls | share of profiled |
|---|---:|---:|---:|
| evalProgram | 85.8 | 4162 | 14.7% |
| native:driver | 71.6 | 6776 | 12.3% |
| signatures | 37.0 | 6299 | 6.3% |
| affine-temporaries | 35.9 | 117332 | 6.1% |
| native:specialize | 35.8 | 7542 | 6.1% |
| native:range | 34.6 | 7466 | 5.9% |
| resolve | 33.1 | 6628 | 5.7% |
| errorsets | 24.9 | 6299 | 4.3% |
| parse | 22.7 | 6304 | 3.9% |
| native:lower-function | 20.6 | 21162 | 3.5% |
| lower-to-hir | 16.8 | 2960 | 2.9% |
| native:lower | 14.6 | 7422 | 2.5% |
| frontend:readProgramFile | 14.2 | 2769 | 2.4% |
| load | 11.0 | 14247 | 1.9% |
| native:short-string | 10.1 | 7422 | 1.7% |
| declared-params | 9.8 | 6299 | 1.7% |
| native:escape | 8.3 | 7446 | 1.4% |
| build | 7.4 | 6638 | 1.3% |
| contexts | 6.9 | 6299 | 1.2% |
| hygiene | 6.4 | 6628 | 1.1% |
| semantic-instances | 6.1 | 6299 | 1.0% |
| compile:block | 6.0 | 15604 | 1.0% |
| compile:generate | 5.9 | 2671 | 1.0% |
| compile:run-unit-in | 5.3 | 2474 | 0.9% |
| declared-results | 5.0 | 6299 | 0.8% |
| affine | 5.0 | 6299 | 0.8% |
| coroutines | 4.8 | 6299 | 0.8% |
| native:block-escape | 4.2 | 14899 | 0.7% |
| native:raw-abi | 3.8 | 7422 | 0.6% |
| static-decisions | 3.8 | 150 | 0.6% |

## Profile: prof-tcl-cranelift-generic

Processes 628.5 s summed; inside the profiler 625.8 s; in profiled phases 590.2 s.

Top-level phases (inclusive):

| phase | s | share of process time |
|---|---:|---:|
| frontend:compile | 134.0 | 21.3% |
| native:lower | 120.8 | 19.2% |
| evalProgram | 113.2 | 18.0% |
| frontend:readProgramFile | 81.2 | 12.9% |
| native:driver | 65.0 | 10.3% |
| compile:generate | 22.6 | 3.6% |
| interp:core-ir-lowering | 13.4 | 2.1% |
| load | 12.2 | 1.9% |
| run:cranelift | 6.9 | 1.1% |
| compile:run-unit | 6.5 | 1.0% |
| run:compile | 5.3 | 0.8% |
| run:interp | 4.6 | 0.7% |
| build | 2.3 | 0.4% |
| native:specialize | 0.6 | 0.1% |
| parse | 0.6 | 0.1% |
| compile:define | 0.3 | 0.0% |
| native:prepare | 0.2 | 0.0% |
| frontend:hir-build | 0.2 | 0.0% |
| native:range | 0.1 | 0.0% |
| native:escape | 0.0 | 0.0% |
| activate | 0.0 | 0.0% |
| read-file | 0.0 | 0.0% |
| finish | 0.0 | 0.0% |
| method-decisions | 0.0 | 0.0% |
| (outside every phase: process start, tcltest, test bodies' own Tcl, runner) | 38.4 | 6.1% |

Self time per phase (top 30):

| phase | self s | calls | share of profiled |
|---|---:|---:|---:|
| evalProgram | 86.1 | 4161 | 14.6% |
| native:driver | 73.0 | 6999 | 12.4% |
| signatures | 37.3 | 6302 | 6.3% |
| native:specialize | 37.0 | 7793 | 6.3% |
| native:range | 35.4 | 7717 | 6.0% |
| affine-temporaries | 34.2 | 116433 | 5.8% |
| resolve | 33.8 | 6631 | 5.7% |
| errorsets | 24.7 | 6302 | 4.2% |
| parse | 23.2 | 6304 | 3.9% |
| native:lower-function | 21.2 | 21594 | 3.6% |
| lower-to-hir | 17.1 | 2960 | 2.9% |
| native:lower | 15.2 | 7673 | 2.6% |
| frontend:readProgramFile | 14.3 | 2769 | 2.4% |
| load | 12.2 | 14247 | 2.1% |
| native:short-string | 10.3 | 7673 | 1.8% |
| declared-params | 9.9 | 6302 | 1.7% |
| native:escape | 8.5 | 7697 | 1.4% |
| build | 7.4 | 6641 | 1.3% |
| contexts | 6.8 | 6302 | 1.2% |
| hygiene | 6.2 | 6631 | 1.1% |
| semantic-instances | 6.1 | 6302 | 1.0% |
| compile:block | 5.9 | 15281 | 1.0% |
| compile:generate | 5.7 | 2423 | 1.0% |
| compile:run-unit-in | 5.1 | 2339 | 0.9% |
| declared-results | 4.9 | 6302 | 0.8% |
| coroutines | 4.9 | 6302 | 0.8% |
| affine | 4.8 | 6302 | 0.8% |
| native:block-escape | 4.4 | 15401 | 0.7% |
| static-decisions | 3.8 | 150 | 0.6% |
| native:raw-abi | 3.8 | 7673 | 0.6% |

## Profile: prof-tcl-cranelift

Processes 625.0 s summed; inside the profiler 622.4 s; in profiled phases 586.0 s.

Top-level phases (inclusive):

| phase | s | share of process time |
|---|---:|---:|
| frontend:compile | 131.8 | 21.1% |
| native:lower | 117.9 | 18.9% |
| evalProgram | 112.8 | 18.1% |
| frontend:readProgramFile | 80.4 | 12.9% |
| native:driver | 66.3 | 10.6% |
| compile:generate | 23.1 | 3.7% |
| interp:core-ir-lowering | 13.5 | 2.2% |
| load | 11.3 | 1.8% |
| run:cranelift | 7.0 | 1.1% |
| run:compile | 6.3 | 1.0% |
| compile:run-unit | 5.9 | 1.0% |
| run:interp | 5.6 | 0.9% |
| build | 1.9 | 0.3% |
| native:specialize | 0.7 | 0.1% |
| parse | 0.6 | 0.1% |
| compile:define | 0.3 | 0.0% |
| native:prepare | 0.2 | 0.0% |
| native:range | 0.1 | 0.0% |
| frontend:hir-build | 0.1 | 0.0% |
| native:escape | 0.0 | 0.0% |
| activate | 0.0 | 0.0% |
| read-file | 0.0 | 0.0% |
| finish | 0.0 | 0.0% |
| method-decisions | 0.0 | 0.0% |
| (outside every phase: process start, tcltest, test bodies' own Tcl, runner) | 38.9 | 6.2% |

Self time per phase (top 30):

| phase | self s | calls | share of profiled |
|---|---:|---:|---:|
| evalProgram | 85.2 | 4161 | 14.5% |
| native:driver | 74.5 | 6999 | 12.7% |
| affine-temporaries | 36.7 | 116433 | 6.3% |
| signatures | 36.5 | 6302 | 6.2% |
| native:specialize | 36.5 | 7793 | 6.2% |
| native:range | 34.6 | 7717 | 5.9% |
| resolve | 33.0 | 6631 | 5.6% |
| errorsets | 24.8 | 6302 | 4.2% |
| parse | 22.5 | 6304 | 3.8% |
| native:lower-function | 20.8 | 21587 | 3.6% |
| lower-to-hir | 16.5 | 2960 | 2.8% |
| native:lower | 14.8 | 7673 | 2.5% |
| frontend:readProgramFile | 14.1 | 2769 | 2.4% |
| load | 11.3 | 14247 | 1.9% |
| native:short-string | 10.2 | 7673 | 1.7% |
| declared-params | 9.6 | 6302 | 1.6% |
| native:escape | 8.4 | 7697 | 1.4% |
| build | 7.3 | 6641 | 1.2% |
| hygiene | 6.8 | 6631 | 1.2% |
| contexts | 6.7 | 6302 | 1.1% |
| semantic-instances | 6.0 | 6302 | 1.0% |
| compile:block | 6.0 | 15281 | 1.0% |
| compile:generate | 5.7 | 2423 | 1.0% |
| declared-results | 4.8 | 6302 | 0.8% |
| coroutines | 4.7 | 6302 | 0.8% |
| compile:run-unit-in | 4.7 | 2339 | 0.8% |
| affine | 4.7 | 6302 | 0.8% |
| native:block-escape | 4.4 | 15401 | 0.7% |
| static-decisions | 3.9 | 150 | 0.7% |
| native:raw-abi | 3.7 | 7673 | 0.6% |

## Profile: prof-tcl-interp

Processes 633.8 s summed; inside the profiler 631.3 s; in profiled phases 595.4 s.

Top-level phases (inclusive):

| phase | s | share of process time |
|---|---:|---:|
| frontend:compile | 133.8 | 21.1% |
| native:lower | 122.0 | 19.3% |
| evalProgram | 113.0 | 17.8% |
| frontend:readProgramFile | 82.6 | 13.0% |
| native:driver | 66.3 | 10.5% |
| compile:generate | 24.0 | 3.8% |
| interp:core-ir-lowering | 14.0 | 2.2% |
| load | 11.0 | 1.7% |
| run:cranelift | 7.1 | 1.1% |
| compile:run-unit | 6.3 | 1.0% |
| run:compile | 6.1 | 1.0% |
| run:interp | 4.9 | 0.8% |
| build | 2.2 | 0.3% |
| native:specialize | 0.7 | 0.1% |
| parse | 0.7 | 0.1% |
| compile:define | 0.3 | 0.0% |
| native:prepare | 0.2 | 0.0% |
| frontend:hir-build | 0.1 | 0.0% |
| native:range | 0.1 | 0.0% |
| native:escape | 0.0 | 0.0% |
| activate | 0.0 | 0.0% |
| read-file | 0.0 | 0.0% |
| finish | 0.0 | 0.0% |
| method-decisions | 0.0 | 0.0% |
| (outside every phase: process start, tcltest, test bodies' own Tcl, runner) | 38.4 | 6.1% |

Self time per phase (top 30):

| phase | self s | calls | share of profiled |
|---|---:|---:|---:|
| evalProgram | 91.1 | 4162 | 15.3% |
| native:driver | 72.5 | 6776 | 12.2% |
| signatures | 37.1 | 6186 | 6.2% |
| affine-temporaries | 37.0 | 116182 | 6.2% |
| native:specialize | 36.9 | 7542 | 6.2% |
| native:range | 35.4 | 7466 | 6.0% |
| resolve | 33.7 | 6515 | 5.7% |
| errorsets | 25.0 | 6186 | 4.2% |
| parse | 23.0 | 6304 | 3.9% |
| native:lower-function | 20.7 | 21162 | 3.5% |
| lower-to-hir | 17.0 | 2960 | 2.9% |
| native:lower | 14.7 | 7422 | 2.5% |
| frontend:readProgramFile | 14.5 | 2769 | 2.4% |
| load | 11.0 | 14247 | 1.8% |
| native:short-string | 10.1 | 7422 | 1.7% |
| declared-params | 9.8 | 6186 | 1.6% |
| native:escape | 8.4 | 7446 | 1.4% |
| build | 7.4 | 6525 | 1.2% |
| contexts | 6.9 | 6186 | 1.2% |
| hygiene | 6.5 | 6515 | 1.1% |
| compile:block | 6.1 | 15281 | 1.0% |
| semantic-instances | 5.9 | 6186 | 1.0% |
| compile:generate | 5.7 | 2423 | 1.0% |
| compile:run-unit-in | 5.2 | 2339 | 0.9% |
| affine | 4.9 | 6186 | 0.8% |
| declared-results | 4.9 | 6186 | 0.8% |
| coroutines | 4.8 | 6186 | 0.8% |
| native:block-escape | 4.3 | 14899 | 0.7% |
| static-decisions | 3.8 | 150 | 0.6% |
| callables | 3.7 | 6186 | 0.6% |
