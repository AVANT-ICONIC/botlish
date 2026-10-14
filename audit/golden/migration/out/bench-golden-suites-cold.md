## Golden suites: size and front end (cold, one process per suite)

| suite | tests | lines | static sites (rejected) | rounds | builds | HIR exprs | front end s | process s | peak RSS MB |
|---|---|---|---|---|---|---|---|---|---|
| abi-bytes-native.bot | 3 | 87 | 3 (0) | 1 | 1 | 2144 | 1.4 | 2.6 | 70 |
| abi-bytes.bot | 103 | 1098 | 103 (56) | 3 | 3 | 5882 | 16.3 | 102.6 | 302 |
| abi-numeric-native.bot | 1 | 40 | 1 (0) | 1 | 1 | 1810 | 1.7 | 2.9 | 61 |
| abi-numeric.bot | 87 | 865 | 76 (34) | 2 | 2 | 5021 | 9.6 | 62.3 | 273 |
| affinity.bot | 67 | 1110 | 67 (25) | 4 | 5 | 4122 | 15.4 | 64.0 | 278 |
| bits-bytes-hashing.bot | 47 | 525 | 35 (0) | 1 | 1 | 3630 | 3.2 | 30.7 | 175 |
| callable-contracts-contravariant-rejected.bot | 2 | 57 | 1 (1) | 2 | 2 | 1489 | 1.9 | 5.1 | 61 |
| callable-contracts-contravariant.bot | 4 | 99 | 3 (1) | 2 | 2 | 1565 | 2.0 | 5.5 | 68 |
| callable-contracts-fallback.bot | 4 | 112 | 4 (2) | 2 | 2 | 1600 | 2.0 | 5.0 | 72 |
| callable-contracts-handle.bot | 1 | 61 | 1 (0) | 1 | 1 | 1534 | 1.0 | 4.4 | 63 |
| callable-contracts-returned.bot | 4 | 150 | 4 (3) | 2 | 2 | 1688 | 2.4 | 5.7 | 74 |
| callable-contracts-unerased.bot | 1 | 44 | 1 (0) | 1 | 1 | 1489 | 1.0 | 3.6 | 59 |
| callable-contracts.bot | 92 | 1768 | 79 (40) | 4 | 8 | 5203 | 61.3 | 160.2 | 440 |
| callables.bot | 113 | 1780 | 111 (38) | 3 | 3 | 5271 | 26.7 | 105.5 | 503 |
| closure-escape-instances.bot | 1 | 48 | 1 (0) | 1 | 1 | 1506 | 1.0 | 3.0 | 58 |
| closure-escape.bot | 49 | 911 | 49 (0) | 1 | 1 | 3480 | 3.4 | 31.0 | 240 |
| collections.bot | 44 | 718 | 44 (22) | 4 | 7 | 3443 | 16.4 | 42.9 | 178 |
| compiled-values-struct-transport.bot | 18 | 392 | 18 (0) | 1 | 1 | 3277 | 2.8 | 22.6 | 151 |
| compiled-values.bot | 118 | 1698 | 114 (36) | 4 | 4 | 6991 | 43.5 | 223.7 | 630 |
| completion-regressions.bot | 23 | 381 | 23 (18) | 2 | 2 | 2062 | 3.7 | 8.8 | 101 |
| contexts.bot | 88 | 1291 | 81 (33) | 3 | 4 | 4888 | 19.5 | 69.0 | 333 |
| core-semantics.bot | 141 | 1810 | 126 (19) | 3 | 3 | 6126 | 14.2 | 86.1 | 421 |
| coroutines.bot | 62 | 1456 | 61 (21) | 4 | 5 | 5532 | 20.1 | 95.9 | 384 |
| declared-errors-imports.bot | 10 | 133 | 10 (10) | 2 | 3 | 1632 | 1.9 | 5.6 | 76 |
| declared-errors.bot | 115 | 1996 | 108 (46) | 3 | 7 | 6024 | 36.0 | 127.9 | 431 |
| destructuring-instances.bot | 55 | 686 | 55 (0) | 1 | 1 | 3476 | 2.5 | 16.0 | 177 |
| destructuring.bot | 378 | 3680 | 356 (88) | 5 | 7 | 13059 | 107.4 | 496.5 | 1567 |
| diagnostics.bot | 27 | 511 | 28 (28) | 4 | 6 | 2713 | 7.1 | 16.5 | 128 |
| errors.bot | 24 | 607 | 26 (11) | 3 | 3 | 2731 | 4.1 | 13.9 | 134 |
| flags.bot | 100 | 1308 | 100 (32) | 2 | 2 | 7035 | 7.3 | 93.2 | 450 |
| framework-semantics.bot | 29 | 611 | 26 (9) | 4 | 8 | 2661 | 20.0 | 32.8 | 139 |
| gc-sensitive-values.bot | 22 | 519 | 22 (0) | 1 | 1 | 2800 | 2.5 | 14.2 | 126 |
| harness.bot | 13 | 363 | 14 (2) | 2 | 2 | 2250 | 1.5 | 8.2 | 101 |
| hir-values.bot | 14 | 277 | 14 (6) | 2 | 2 | 1849 | 1.4 | 5.4 | 86 |
| imports-abi-child.bot | 17 | 169 | 17 (9) | 3 | 3 | 2014 | 3.2 | 8.0 | 89 |
| imports-abi-family.bot | 6 | 89 | 6 (0) | 1 | 1 | 1865 | 1.3 | 4.3 | 74 |
| imports-library-modules.bot | 12 | 156 | 12 (5) | 3 | 3 | 2859 | 5.1 | 16.2 | 121 |
| imports-unimported.bot | 16 | 136 | 14 (12) | 2 | 2 | 1763 | 1.9 | 5.8 | 79 |
| imports.bot | 59 | 524 | 58 (10) | 4 | 16 | 3463 | 42.5 | 67.5 | 181 |
| linux-io-native.bot | 5 | 121 | 5 (0) | 1 | 1 | 2055 | 1.6 | 2.8 | 68 |
| linux-io.bot | 55 | 501 | 47 (29) | 3 | 3 | 2786 | 8.5 | 27.1 | 137 |
| lists-and-sets.bot | 86 | 778 | 72 (11) | 3 | 3 | 3772 | 7.1 | 37.8 | 221 |
| loop-collecting-refined-checks.bot | 1 | 50 | 1 (0) | 1 | 1 | 2276 | 1.8 | 22.5 | 100 |
| loop-collecting.bot | 110 | 1366 | 106 (8) | 3 | 3 | 5679 | 11.8 | 75.7 | 393 |
| loops.bot | 55 | 783 | 55 (7) | 2 | 2 | 3353 | 3.5 | 25.1 | 184 |
| method-equivalence-imported.bot | 13 | 199 | 11 (4) | 3 | 5 | 2573 | 7.1 | 19.1 | 112 |
| method-equivalence.bot | 45 | 584 | 42 (6) | 3 | 3 | 2881 | 5.8 | 21.8 | 169 |
| methods-byte-without-list.bot | 3 | 54 | 3 (3) | 2 | 2 | 1599 | 1.9 | 5.5 | 68 |
| methods-list-without-str.bot | 3 | 47 | 3 (3) | 2 | 2 | 1516 | 1.6 | 5.0 | 65 |
| methods-struct-instances.bot | 8 | 109 | 8 (0) | 1 | 1 | 1701 | 1.2 | 3.9 | 69 |
| methods-type-import-only.bot | 1 | 29 | 1 (1) | 2 | 2 | 1561 | 1.5 | 4.7 | 62 |
| methods.bot | 195 | 1819 | 198 (22) | 4 | 6 | 6859 | 64.3 | 189.5 | 615 |
| modules.bot | 31 | 572 | 33 (26) | 3 | 4 | 3918 | 9.7 | 29.4 | 205 |
| mutable-array.bot | 233 | 2930 | 233 (91) | 5 | 20 | 9251 | 351.9 | 626.3 | 866 |
| mutable-vector-str.bot | 1 | 44 | 1 (0) | 1 | 1 | 1557 | 0.9 | 3.1 | 60 |
| mutable-vector.bot | 74 | 1206 | 70 (26) | 4 | 13 | 4628 | 41.6 | 103.3 | 287 |
| names-and-scoping.bot | 58 | 861 | 58 (35) | 2 | 2 | 2983 | 2.6 | 15.2 | 146 |
| native-aggregates.bot | 70 | 1223 | 57 (0) | 1 | 1 | 5300 | 5.6 | 62.8 | 323 |
| native-values.bot | 89 | 1102 | 79 (0) | 1 | 1 | 4380 | 4.4 | 45.4 | 267 |
| opaque-instances.bot | 1 | 37 | 1 (0) | 1 | 1 | 1657 | 1.1 | 3.2 | 61 |
| opaque.bot | 91 | 1124 | 91 (62) | 6 | 10 | 4617 | 49.3 | 110.2 | 305 |
| ownership.bot | 38 | 700 | 38 (24) | 3 | 10 | 3216 | 21.7 | 43.5 | 177 |
| range-and-contract-values.bot | 78 | 1149 | 76 (25) | 4 | 4 | 4655 | 24.8 | 95.1 | 328 |
| raw-int-abi.bot | 52 | 951 | 52 (0) | 1 | 1 | 3811 | 3.4 | 43.4 | 216 |
| recursive-types.bot | 9 | 261 | 9 (0) | 1 | 3 | 1963 | 2.4 | 6.5 | 80 |
| refinements.bot | 66 | 1036 | 66 (29) | 3 | 10 | 3687 | 46.1 | 79.0 | 240 |
| representation.bot | 13 | 332 | 13 (1) | 2 | 2 | 2656 | 3.0 | 10.1 | 106 |
| static-compile-erased-consumer.bot | 2 | 59 | 2 (1) | 2 | 2 | 1522 | 1.7 | 4.4 | 66 |
| static-compile.bot | 81 | 1452 | 158 (84) | 7 | 14 | 5193 | 70.9 | 145.0 | 384 |
| stdlib-namespaces-entry-members.bot | 4 | 64 | 4 (0) | 1 | 1 | 1546 | 0.9 | 3.7 | 62 |
| stdlib-namespaces-str-only.bot | 1 | 25 | 1 (1) | 2 | 2 | 1481 | 1.5 | 3.7 | 58 |
| stdlib-namespaces-unimported.bot | 2 | 32 | 2 (2) | 2 | 2 | 1497 | 1.6 | 4.0 | 61 |
| stdlib-namespaces.bot | 114 | 1065 | 110 (46) | 3 | 9 | 5698 | 54.9 | 133.4 | 360 |
| string-natives.bot | 82 | 1077 | 45 (0) | 1 | 1 | 4968 | 5.6 | 54.2 | 294 |
| string-representations.bot | 48 | 900 | 48 (0) | 1 | 1 | 3953 | 4.1 | 33.9 | 203 |
| strings.bot | 94 | 932 | 67 (17) | 2 | 2 | 4889 | 8.7 | 59.1 | 276 |
| struct-representation-instances.bot | 15 | 240 | 15 (0) | 1 | 1 | 2164 | 1.7 | 5.6 | 87 |
| struct-representation.bot | 110 | 1732 | 107 (0) | 1 | 1 | 7612 | 9.6 | 134.9 | 538 |
| structs-and-enums-instances.bot | 4 | 84 | 4 (0) | 1 | 1 | 1633 | 1.1 | 3.4 | 65 |
| structs-and-enums-qualifiers.bot | 2 | 49 | 2 (2) | 1 | 1 | 1576 | 1.0 | 3.7 | 61 |
| structs-and-enums.bot | 111 | 1335 | 111 (45) | 4 | 17 | 4580 | 60.6 | 107.7 | 298 |
| traits-path.bot | 2 | 73 | 2 (0) | 1 | 2 | 1679 | 1.5 | 4.3 | 74 |
| traits.bot | 67 | 1024 | 79 (38) | 8 | 13 | 3654 | 45.3 | 83.3 | 247 |
| types.bot | 96 | 1269 | 94 (34) | 3 | 3 | 4273 | 14.6 | 60.4 | 290 |
| unicode-strings.bot | 56 | 190 | 5 (0) | 1 | 1 | 2526 | 1.9 | 10.6 | 94 |
| validators-and-proofs.bot | 153 | 1748 | 153 (76) | 3 | 4 | 6064 | 18.3 | 94.6 | 440 |
| values.bot | 32 | 1005 | 26 (0) | 1 | 1 | 3961 | 4.3 | 33.1 | 280 |
| warning-programs.bot | 42 | 623 | 42 (14) | 3 | 4 | 2731 | 6.2 | 15.5 | 148 |
| total | 4572 | 63212 | 4378 (1390) | 211 | 329 | 308037 | 1518.4 | 4790.5 | max 1567 |

Elapsed: 4790.6 s with 1 job(s), 88 suite(s) measured by this run, 0 read from SCRATCH/quiet/cold-cache.

## Back ends (seconds): lowering / code generation / execution

| suite | Core IR lowering | interp run | Tcl codegen | Tcl compiled run | NIR lowering | Cranelift codegen | native run | generic NIR lowering | generic codegen | generic run |
|---|---|---|---|---|---|---|---|---|---|---|
| abi-bytes-native.bot | excluded | excluded | excluded | excluded | 0.64 | 0.05 | 0.00 | 0.37 | 0.03 | 0.00 |
| abi-bytes.bot | 16.83 | 5.05 | 32.42 | 5.09 | 6.21 | 0.14 | 0.00 | 1.76 | 0.12 | 0.00 |
| abi-numeric-native.bot | excluded | excluded | excluded | excluded | 0.60 | 0.03 | 0.00 | 0.45 | 0.03 | 0.00 |
| abi-numeric.bot | 10.62 | 3.31 | 17.08 | 4.36 | 5.16 | 0.09 | 0.00 | 1.45 | 0.10 | 0.00 |
| affinity.bot | 7.30 | 1.25 | 18.49 | 5.64 | 6.24 | 0.08 | 0.00 | 1.29 | 0.10 | 0.00 |
| bits-bytes-hashing.bot | 4.29 | 1.14 | 9.31 | 3.00 | 2.87 | 0.08 | 0.00 | 1.07 | 0.10 | 0.00 |
| callable-contracts-contravariant-rejected.bot | 0.22 | 0.09 | 0.82 | 0.81 | 0.44 | 0.03 | 0.00 | 0.42 | 0.03 | 0.00 |
| callable-contracts-contravariant.bot | 0.35 | 0.11 | 0.59 | 0.86 | 0.64 | 0.03 | 0.00 | 0.41 | 0.03 | 0.00 |
| callable-contracts-fallback.bot | 0.27 | 0.03 | 0.54 | 0.71 | 0.62 | 0.03 | 0.00 | 0.34 | 0.03 | 0.00 |
| callable-contracts-handle.bot | 0.51 | 0.03 | 0.57 | 0.78 | 0.62 | 0.04 | 0.00 | 0.38 | 0.03 | 0.00 |
| callable-contracts-returned.bot | 0.40 | 0.04 | 0.58 | 0.89 | 0.66 | 0.04 | 0.00 | 0.28 | 0.06 | 0.00 |
| callable-contracts-unerased.bot | 0.24 | 0.02 | 0.47 | 0.68 | 0.47 | 0.04 | 0.00 | 0.28 | 0.03 | 0.00 |
| callable-contracts.bot | 15.21 | 1.51 | 29.99 | 19.56 | 14.72 | 0.13 | 0.00 | 1.97 | 0.11 | 0.00 |
| callables.bot | 12.09 | 5.71 | 24.08 | 8.80 | 13.51 | 0.16 | 0.00 | 2.16 | 0.16 | 0.00 |
| closure-escape-instances.bot | 0.30 | 0.03 | 0.36 | 0.48 | 0.39 | 0.04 | 0.00 | excluded | excluded | excluded |
| closure-escape.bot | 4.26 | 1.04 | 9.64 | 3.14 | 3.88 | 0.09 | 0.00 | 1.01 | 0.12 | 0.00 |
| collections.bot | 6.30 | 0.66 | 7.01 | 3.01 | 2.92 | 0.08 | 0.00 | 1.05 | 0.08 | 0.00 |
| compiled-values-struct-transport.bot | 2.76 | 0.30 | 8.08 | 2.41 | 2.02 | 0.05 | 0.00 | excluded | excluded | excluded |
| compiled-values.bot | 27.78 | 35.09 | 53.50 | 14.57 | 19.03 | 0.16 | 0.00 | 2.61 | 0.14 | 0.00 |
| completion-regressions.bot | 0.49 | 0.35 | 0.81 | 1.40 | 0.78 | 0.07 | 0.00 | 0.43 | 0.07 | 0.00 |
| contexts.bot | 9.55 | 2.85 | 15.26 | 5.06 | 5.52 | 0.07 | 0.00 | 1.47 | 0.10 | 0.00 |
| core-semantics.bot | 13.84 | 1.07 | 25.50 | 6.00 | 8.89 | 0.15 | 0.00 | 1.96 | 0.11 | 0.00 |
| coroutines.bot | 12.93 | 3.20 | 31.35 | 5.85 | 6.38 | 0.15 | 0.01 | 1.90 | 0.10 | 0.00 |
| declared-errors-imports.bot | 0.36 | 0.70 | 0.62 | 0.74 | 0.51 | 0.05 | 0.00 | 0.29 | 0.03 | 0.00 |
| declared-errors.bot | 17.42 | 1.01 | 35.04 | 8.33 | 9.87 | 0.17 | 0.00 | 2.29 | 0.13 | 0.00 |
| destructuring-instances.bot | 1.93 | 0.14 | 4.71 | 1.93 | 2.05 | 0.07 | 0.00 | excluded | excluded | excluded |
| destructuring.bot | 79.21 | 2.22 | 135.31 | 18.19 | 68.59 | 0.21 | 0.00 | 7.23 | 0.19 | 0.00 |
| diagnostics.bot | 1.03 | 0.63 | 2.41 | 1.52 | 1.26 | 0.06 | 0.00 | 0.49 | 0.07 | 0.00 |
| errors.bot | 1.49 | 0.17 | 3.30 | 1.69 | 1.34 | 0.05 | 0.00 | 0.60 | 0.05 | 0.00 |
| flags.bot | 16.95 | 1.23 | 33.03 | 6.45 | 8.66 | 0.11 | 0.00 | 1.91 | 0.13 | 0.00 |
| framework-semantics.bot | 1.59 | 2.61 | 2.58 | 1.81 | 1.80 | 0.10 | 0.00 | 0.70 | 0.08 | 0.00 |
| gc-sensitive-values.bot | 1.21 | 2.24 | 2.70 | 1.62 | 1.65 | 0.06 | 0.01 | 0.58 | 0.06 | 0.01 |
| harness.bot | 0.77 | 0.56 | 1.79 | 1.17 | 1.19 | 0.05 | 0.00 | 0.44 | 0.05 | 0.00 |
| hir-values.bot | 0.36 | 0.36 | 0.61 | 0.82 | 0.95 | 0.04 | 0.00 | 0.39 | 0.04 | 0.00 |
| imports-abi-child.bot | 0.42 | 0.27 | 0.83 | 0.91 | 1.25 | 0.05 | 0.00 | 0.44 | 0.05 | 0.00 |
| imports-abi-family.bot | 0.35 | 0.03 | 0.60 | 0.71 | 0.48 | 0.03 | 0.00 | 0.31 | 0.03 | 0.00 |
| imports-library-modules.bot | 1.77 | 0.46 | 2.06 | 1.59 | 1.26 | 0.04 | 0.00 | 0.57 | 0.04 | 0.00 |
| imports-unimported.bot | 0.47 | 0.51 | 0.62 | 0.76 | 0.72 | 0.04 | 0.00 | 0.41 | 0.05 | 0.00 |
| imports.bot | 5.50 | 0.42 | 8.17 | 2.60 | 2.50 | 0.06 | 0.00 | 0.82 | 0.05 | 0.00 |
| linux-io-native.bot | excluded | excluded | excluded | excluded | 0.60 | 0.04 | 0.00 | 0.33 | 0.04 | 0.00 |
| linux-io.bot | 2.75 | 1.14 | 4.56 | 4.28 | 1.93 | 0.08 | 0.00 | 0.73 | 0.07 | 0.00 |
| lists-and-sets.bot | 6.42 | 0.49 | 10.65 | 3.29 | 2.85 | 0.07 | 0.00 | 1.09 | 0.08 | 0.00 |
| loop-collecting-refined-checks.bot | 0.95 | 14.06 | 1.28 | 2.19 | 0.99 | 0.04 | 0.00 | 0.55 | 0.05 | 0.00 |
| loop-collecting.bot | 12.07 | 0.53 | 21.81 | 5.11 | 9.87 | 0.17 | 0.00 | 1.67 | 0.17 | 0.00 |
| loops.bot | 3.55 | 0.37 | 6.96 | 2.75 | 3.13 | 0.10 | 0.00 | 0.87 | 0.08 | 0.00 |
| method-equivalence-imported.bot | 2.52 | 0.61 | 3.51 | 1.91 | 1.15 | 0.04 | 0.00 | 0.55 | 0.04 | 0.00 |
| method-equivalence.bot | 2.57 | 0.84 | 3.56 | 2.00 | 2.44 | 0.06 | 0.00 | 0.88 | 0.06 | 0.00 |
| methods-byte-without-list.bot | 0.25 | 0.71 | 0.58 | 0.66 | 0.57 | 0.03 | 0.00 | 0.37 | 0.03 | 0.00 |
| methods-list-without-str.bot | 0.26 | 0.76 | 0.49 | 0.71 | 0.49 | 0.03 | 0.00 | 0.28 | 0.04 | 0.00 |
| methods-struct-instances.bot | 0.29 | 0.03 | 0.56 | 0.83 | 0.62 | 0.03 | 0.00 | excluded | excluded | excluded |
| methods-type-import-only.bot | 0.32 | 0.25 | 0.54 | 0.75 | 0.54 | 0.02 | 0.00 | 0.30 | 0.07 | 0.00 |
| methods.bot | 25.45 | 1.98 | 43.38 | 9.63 | 16.05 | 0.18 | 0.00 | 2.93 | 0.16 | 0.00 |
| modules.bot | 3.82 | 0.26 | 7.31 | 2.64 | 1.97 | 0.07 | 0.00 | 0.60 | 0.05 | 0.00 |
| mutable-array.bot | 56.24 | 3.07 | 110.40 | 14.07 | 32.38 | 0.19 | 0.00 | 4.18 | 0.16 | 0.00 |
| mutable-vector-str.bot | 0.25 | 0.02 | 0.44 | 0.48 | 0.38 | 0.03 | 0.00 | 0.21 | 0.03 | 0.00 |
| mutable-vector.bot | 11.06 | 2.07 | 25.24 | 5.28 | 4.85 | 0.16 | 0.03 | 1.34 | 0.10 | 0.04 |
| names-and-scoping.bot | 1.40 | 0.95 | 3.18 | 2.47 | 1.94 | 0.06 | 0.00 | 0.63 | 0.05 | 0.00 |
| native-aggregates.bot | 10.32 | 3.03 | 20.88 | 4.98 | 4.99 | 0.11 | 0.00 | 1.60 | 0.10 | 0.00 |
| native-values.bot | 6.84 | 5.30 | 13.24 | 3.96 | 4.18 | 0.08 | 0.00 | 1.25 | 0.09 | 0.00 |
| opaque-instances.bot | 0.27 | 0.02 | 0.51 | 0.55 | 0.40 | 0.03 | 0.00 | excluded | excluded | excluded |
| opaque.bot | 9.98 | 11.23 | 16.58 | 5.39 | 5.38 | 0.09 | 0.01 | 1.39 | 0.09 | 0.00 |
| ownership.bot | 3.73 | 1.21 | 6.42 | 2.92 | 2.87 | 0.07 | 0.00 | 1.23 | 0.08 | 0.00 |
| range-and-contract-values.bot | 10.03 | 20.04 | 17.34 | 5.16 | 5.82 | 0.10 | 0.00 | 1.64 | 0.09 | 0.00 |
| raw-int-abi.bot | 3.21 | 14.54 | 10.64 | 2.54 | 3.82 | 0.07 | 0.00 | 1.19 | 0.09 | 0.00 |
| recursive-types.bot | 0.40 | 0.04 | 1.04 | 0.94 | 0.73 | 0.04 | 0.00 | 0.41 | 0.04 | 0.00 |
| refinements.bot | 6.67 | 3.43 | 9.24 | 3.71 | 3.16 | 0.08 | 0.00 | 1.04 | 0.06 | 0.00 |
| representation.bot | 0.86 | 0.09 | 2.17 | 1.25 | 1.10 | 0.04 | 0.00 | 0.55 | 0.04 | 0.00 |
| static-compile-erased-consumer.bot | 0.25 | 0.06 | 0.52 | 0.61 | 0.56 | 0.03 | 0.00 | 0.30 | 0.03 | 0.00 |
| static-compile.bot | 13.81 | 2.21 | 26.40 | 7.02 | 8.50 | 0.10 | 0.00 | 1.63 | 0.09 | 0.00 |
| stdlib-namespaces-entry-members.bot | 0.26 | 0.03 | 0.48 | 0.68 | 0.57 | 0.05 | 0.00 | 0.24 | 0.04 | 0.00 |
| stdlib-namespaces-str-only.bot | 0.20 | 0.02 | 0.43 | 0.51 | 0.32 | 0.02 | 0.00 | 0.26 | 0.03 | 0.00 |
| stdlib-namespaces-unimported.bot | 0.29 | 0.02 | 0.37 | 0.60 | 0.42 | 0.02 | 0.00 | 0.28 | 0.03 | 0.00 |
| stdlib-namespaces.bot | 16.44 | 0.94 | 27.36 | 7.51 | 7.57 | 0.12 | 0.00 | 1.67 | 0.14 | 0.00 |
| string-natives.bot | 8.62 | 1.31 | 17.46 | 5.48 | 5.36 | 0.12 | 0.00 | 1.44 | 0.10 | 0.00 |
| string-representations.bot | 5.34 | 0.46 | 10.85 | 2.80 | 2.69 | 0.07 | 0.00 | 0.92 | 0.08 | 0.00 |
| strings.bot | 8.21 | 5.77 | 15.59 | 5.85 | 4.83 | 0.08 | 0.00 | 1.35 | 0.10 | 0.00 |
| struct-representation-instances.bot | 0.59 | 0.06 | 1.03 | 0.83 | 0.72 | 0.04 | 0.00 | excluded | excluded | excluded |
| struct-representation.bot | 23.44 | 4.39 | 48.47 | 10.45 | 12.53 | 0.14 | 0.00 | 2.38 | 0.14 | 0.01 |
| structs-and-enums-instances.bot | 0.30 | 0.05 | 0.43 | 0.54 | 0.49 | 0.03 | 0.00 | excluded | excluded | excluded |
| structs-and-enums-qualifiers.bot | 0.27 | 0.02 | 0.63 | 0.71 | 0.40 | 0.03 | 0.00 | 0.27 | 0.03 | 0.00 |
| structs-and-enums.bot | 9.18 | 1.73 | 15.52 | 3.91 | 5.09 | 0.08 | 0.00 | 1.37 | 0.11 | 0.00 |
| traits-path.bot | 0.31 | 0.03 | 0.50 | 0.66 | 0.49 | 0.03 | 0.00 | 0.29 | 0.03 | 0.00 |
| traits.bot | 6.71 | 3.90 | 10.14 | 4.30 | 4.44 | 0.08 | 0.00 | 1.34 | 0.07 | 0.00 |
| types.bot | 7.46 | 2.81 | 14.13 | 5.38 | 6.16 | 0.08 | 0.00 | 1.43 | 0.08 | 0.00 |
| unicode-strings.bot | 1.02 | 0.37 | 2.86 | 1.49 | 0.95 | 0.04 | 0.00 | 0.49 | 0.04 | 0.00 |
| validators-and-proofs.bot | 14.87 | 2.77 | 28.51 | 5.84 | 6.88 | 0.12 | 0.00 | 1.84 | 0.12 | 0.00 |
| values.bot | 5.11 | 0.27 | 11.62 | 3.31 | 2.93 | 0.05 | 0.00 | 0.99 | 0.10 | 0.00 |
| warning-programs.bot | 0.97 | 0.11 | 2.65 | 1.89 | 1.66 | 0.07 | 0.00 | 0.67 | 0.05 | 0.00 |
| total | 583.48 | 190.8 | 1099.33 | 304.79 | 396.04 | 6.57 | 0.09 | 87.49 | 6.1 | 0.1 |

## Front end: self time per phase, all suites

| phase | self s | share |
|---|---|---|
| signatures | 575.7 | 38.2% |
| semantic-instances | 189.6 | 12.6% |
| hygiene | 168.7 | 11.2% |
| errorsets | 116.3 | 7.7% |
| static-decisions | 96.5 | 6.4% |
| affine | 62.7 | 4.2% |
| static-deps | 46.9 | 3.1% |
| parse | 46.1 | 3.1% |
| resolve | 41.8 | 2.8% |
| contexts | 29.1 | 1.9% |
| declared-params | 28.5 | 1.9% |
| coroutines | 19.1 | 1.3% |
| coroutines-verify | 18.0 | 1.2% |
| callables | 13.9 | 0.9% |
| declared-results | 10.9 | 0.7% |
| build | 7.8 | 0.5% |
| traits-verify | 7.3 | 0.5% |
| syscall | 6.2 | 0.4% |
| structs | 6.2 | 0.4% |
| mutvec | 6.1 | 0.4% |
| method-decisions | 3.5 | 0.2% |
| lockstep | 2.5 | 0.2% |
| traits-monomorphize | 1.6 | 0.1% |
| module-bindings | 0.3 | 0.0% |
| finish | 0.0 | 0.0% |
| (unprofiled: front end minus phases) | 13.0 | |
