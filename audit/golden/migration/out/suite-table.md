| suite | golden tests | Tcl tests | from Tcl files | lines | static sites (rejected) | rounds | builds (method trials) | front end s | interp s | compile s | cranelift-generic s | cranelift s | peak RSS MB |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| abi-bytes-native.bot | 3 | 3 | abi-bytes | 87 | 3 (0) | 1 | 1 (0) | 1.4 | excl. | excl. | 0.4 | 0.7 | 70 |
| abi-bytes.bot | 103 | 57 | abi-bytes, abi-mutable-bytes | 1098 | 103 (56) | 3 | 3 (0) | 16.3 | 21.9 | 37.5 | 1.9 | 6.4 | 302 |
| abi-numeric-native.bot | 1 | 1 | abi-numeric | 40 | 1 (0) | 1 | 1 (0) | 1.7 | excl. | excl. | 0.5 | 0.6 | 61 |
| abi-numeric.bot | 87 | 34 | abi-numeric, scalarbits | 865 | 76 (34) | 2 | 2 (0) | 9.6 | 13.9 | 21.4 | 1.5 | 5.3 | 273 |
| affinity.bot | 67 | 32 | affine | 1110 | 67 (25) | 4 | 5 (0) | 15.4 | 8.6 | 24.1 | 1.4 | 6.3 | 278 |
| bits-bytes-hashing.bot | 47 | 51 | native-bitshift, native-byte, native-csv-records, native-executable +1 | 525 | 35 (0) | 1 | 1 (0) | 3.2 | 5.4 | 12.3 | 1.2 | 3.0 | 175 |
| callable-contracts-contravariant-rejected.bot | 2 | 1 | structural-contract-completions | 57 | 1 (1) | 2 | 2 (0) | 1.9 | 0.3 | 1.6 | 0.4 | 0.5 | 61 |
| callable-contracts-contravariant.bot | 4 | 1 | structural-contract-completions | 99 | 3 (1) | 2 | 2 (0) | 2.0 | 0.5 | 1.5 | 0.4 | 0.7 | 68 |
| callable-contracts-fallback.bot | 4 | 3 | higher-order-completions | 112 | 4 (2) | 2 | 2 (0) | 2.0 | 0.3 | 1.2 | 0.4 | 0.7 | 72 |
| callable-contracts-handle.bot | 1 | 1 | structural-contract-completions | 61 | 1 (0) | 1 | 1 (0) | 1.0 | 0.5 | 1.4 | 0.4 | 0.7 | 63 |
| callable-contracts-returned.bot | 4 | 6 | higher-order-completions | 150 | 4 (3) | 2 | 2 (0) | 2.4 | 0.4 | 1.5 | 0.3 | 0.7 | 74 |
| callable-contracts-unerased.bot | 1 | 1 | structural-contract-completions | 44 | 1 (0) | 1 | 1 (0) | 1.0 | 0.3 | 1.2 | 0.3 | 0.5 | 59 |
| callable-contracts.bot | 92 | 79 | exact-callable-executable, higher-order-completions, structural-contract-completions | 1768 | 79 (40) | 4 | 8 (2) | 61.3 | 16.7 | 49.6 | 2.1 | 14.8 | 440 |
| callables.bot | 113 | 101 | closure-int-keys, exact-callable-key, structural-fn-types, typed-callable-escape | 1780 | 111 (38) | 3 | 3 (0) | 26.7 | 17.8 | 32.9 | 2.3 | 13.7 | 503 |
| closure-escape-instances.bot | 1 | 1 | native-listloop | 48 | 1 (0) | 1 | 1 (0) | 1.0 | 0.3 | 0.8 | excl. | 0.4 | 58 |
| closure-escape.bot | 49 | 47 | blockescape-called-generic, blockescape-nested-capturers, native-block-escape, native-escape +1 | 911 | 49 (0) | 1 | 1 (0) | 3.4 | 5.3 | 12.8 | 1.1 | 4.0 | 240 |
| collections.bot | 44 | 23 | enums, flags, immutable-set, list-stdlib +9 | 718 | 44 (22) | 4 | 7 (2) | 16.4 | 7.0 | 10.0 | 1.1 | 3.0 | 178 |
| compiled-values-struct-transport.bot | 18 | 17 | value-transport | 392 | 18 (0) | 1 | 1 (0) | 2.8 | 3.1 | 10.5 | excl. | 2.1 | 151 |
| compiled-values.bot | 118 | 95 | blockescape-nested-capturers, compiler-opt, direct-hir-native, dormant-instances +6 | 1698 | 114 (36) | 4 | 4 (0) | 43.5 | 62.9 | 68.1 | 2.8 | 19.2 | 630 |
| completion-regressions.bot | 23 | 11 | errors | 381 | 23 (18) | 2 | 2 (0) | 3.7 | 0.8 | 2.2 | 0.5 | 0.9 | 101 |
| contexts.bot | 88 | 49 | context-traits, contexts, linux-path | 1291 | 81 (33) | 3 | 4 (0) | 19.5 | 12.4 | 20.3 | 1.6 | 5.6 | 333 |
| core-semantics.bot | 141 | 119 | acceptance, backends, bindings, blocks +8 | 1810 | 126 (19) | 3 | 3 (0) | 14.2 | 14.9 | 31.5 | 2.1 | 9.0 | 421 |
| coroutines.bot | 62 | 47 | coroutines | 1456 | 61 (21) | 4 | 5 (0) | 20.1 | 16.1 | 37.2 | 2.0 | 6.5 | 384 |
| declared-errors-imports.bot | 10 | 2 | namespaced-errors | 133 | 10 (10) | 2 | 3 (0) | 1.9 | 1.1 | 1.4 | 0.3 | 0.6 | 76 |
| declared-errors.bot | 115 | 74 | error-payloads, errors, namespaced-errors | 1996 | 108 (46) | 3 | 7 (3) | 36.0 | 18.4 | 43.4 | 2.4 | 10.0 | 431 |
| destructuring-instances.bot | 55 | 22 | struct-destructuring | 686 | 55 (0) | 1 | 1 (0) | 2.5 | 2.1 | 6.6 | excl. | 2.1 | 177 |
| destructuring.bot | 378 | 179 | struct-destructuring | 3680 | 356 (88) | 5 | 7 (1) | 107.4 | 81.4 | 153.5 | 7.4 | 68.8 | 1567 |
| diagnostics.bot | 27 | 24 | enums, flags, hir-resolution, imports +9 | 511 | 28 (28) | 4 | 6 (1) | 7.1 | 1.7 | 3.9 | 0.6 | 1.3 | 128 |
| errors.bot | 24 | 20 | error-payloads, errors, higher-order-completions, mutable-array-type +3 | 607 | 26 (11) | 3 | 3 (0) | 4.1 | 1.7 | 5.0 | 0.7 | 1.4 | 134 |
| flags.bot | 100 | 98 | flags | 1308 | 100 (32) | 2 | 2 (0) | 7.3 | 18.2 | 39.5 | 2.0 | 8.8 | 450 |
| framework-semantics.bot | 29 | 17 | golden-framework | 611 | 26 (9) | 4 | 8 (2) | 20.0 | 4.2 | 4.4 | 0.8 | 1.9 | 139 |
| gc-sensitive-values.bot | 22 | 24 | native-alloc, native-root-liveness, native-stack-map, string-allocation | 519 | 22 (0) | 1 | 1 (0) | 2.5 | 3.4 | 4.3 | 0.6 | 1.7 | 126 |
| harness.bot | 13 | 13 | argv, calls, coroutines, hir-lowering +6 | 363 | 14 (2) | 2 | 2 (0) | 1.5 | 1.3 | 3.0 | 0.5 | 1.2 | 101 |
| hir-values.bot | 14 | 12 | hir-aot, hir-lowering, hir-resolution, hir-samples | 277 | 14 (6) | 2 | 2 (0) | 1.4 | 0.7 | 1.4 | 0.4 | 1.0 | 86 |
| imports-abi-child.bot | 17 | 10 | imports, surface-modules | 169 | 17 (9) | 3 | 3 (0) | 3.2 | 0.7 | 1.7 | 0.5 | 1.3 | 89 |
| imports-abi-family.bot | 6 | 5 | imports, surface-modules | 89 | 6 (0) | 1 | 1 (0) | 1.3 | 0.4 | 1.3 | 0.3 | 0.5 | 74 |
| imports-library-modules.bot | 12 | 11 | imports, surface-modules | 156 | 12 (5) | 3 | 3 (0) | 5.1 | 2.2 | 3.6 | 0.6 | 1.3 | 121 |
| imports-unimported.bot | 16 | 6 | imports | 136 | 14 (12) | 2 | 2 (0) | 1.9 | 1.0 | 1.4 | 0.5 | 0.8 | 79 |
| imports.bot | 59 | 36 | imports, surface-modules | 524 | 58 (10) | 4 | 16 (11) | 42.5 | 5.9 | 10.8 | 0.9 | 2.6 | 181 |
| linux-io-native.bot | 5 | 4 | linux-syscall | 121 | 5 (0) | 1 | 1 (0) | 1.6 | excl. | excl. | 0.4 | 0.6 | 68 |
| linux-io.bot | 55 | 26 | argv, linux-syscall | 501 | 47 (29) | 3 | 3 (0) | 8.5 | 3.9 | 8.8 | 0.8 | 2.0 | 137 |
| lists-and-sets.bot | 86 | 89 | byte-set, immutable-set, list-stdlib, lists +2 | 778 | 72 (11) | 3 | 3 (0) | 7.1 | 6.9 | 13.9 | 1.2 | 2.9 | 221 |
| loop-collecting-refined-checks.bot | 1 | 1 | raw-count-loops | 50 | 1 (0) | 1 | 1 (0) | 1.8 | 15.0 | 3.5 | 0.6 | 1.0 | 100 |
| loop-collecting.bot | 110 | 110 | loop-collecting, raw-count-loops | 1366 | 106 (8) | 3 | 3 (0) | 11.8 | 12.6 | 26.9 | 1.8 | 10.0 | 393 |
| loops.bot | 55 | 72 | loop-counted, loop-in, loops | 783 | 55 (7) | 2 | 2 (0) | 3.5 | 3.9 | 9.7 | 0.9 | 3.2 | 184 |
| method-equivalence-imported.bot | 13 | 9 | method-eligible | 199 | 11 (4) | 3 | 5 (1) | 7.1 | 3.1 | 5.4 | 0.6 | 1.2 | 112 |
| method-equivalence.bot | 45 | 36 | method-eligible | 584 | 42 (6) | 3 | 3 (0) | 5.8 | 3.4 | 5.6 | 0.9 | 2.5 | 169 |
| methods-byte-without-list.bot | 3 | 2 | method-sugar | 54 | 3 (3) | 2 | 2 (0) | 1.9 | 1.0 | 1.2 | 0.4 | 0.6 | 68 |
| methods-list-without-str.bot | 3 | 2 | method-sugar | 47 | 3 (3) | 2 | 2 (0) | 1.6 | 1.0 | 1.2 | 0.3 | 0.5 | 65 |
| methods-struct-instances.bot | 8 | 5 | method-sugar | 109 | 8 (0) | 1 | 1 (0) | 1.2 | 0.3 | 1.4 | excl. | 0.7 | 69 |
| methods-type-import-only.bot | 1 | 1 | method-sugar | 29 | 1 (1) | 2 | 2 (0) | 1.5 | 0.6 | 1.3 | 0.4 | 0.6 | 62 |
| methods.bot | 195 | 104 | method-sugar | 1819 | 198 (22) | 4 | 6 (1) | 64.3 | 27.4 | 53.0 | 3.1 | 16.2 | 615 |
| modules.bot | 31 | 12 | context-traits, contexts, imports, namespaced-errors +5 | 572 | 33 (26) | 3 | 4 (0) | 9.7 | 4.1 | 10.0 | 0.7 | 2.0 | 205 |
| mutable-array.bot | 233 | 115 | mutable-array, mutable-array-type, mutarray-construction | 2930 | 233 (91) | 5 | 20 (14) | 351.9 | 59.3 | 124.5 | 4.3 | 32.6 | 866 |
| mutable-vector-str.bot | 1 | 1 | mutable-vector | 44 | 1 (0) | 1 | 1 (0) | 0.9 | 0.3 | 0.9 | 0.2 | 0.4 | 60 |
| mutable-vector.bot | 74 | 41 | mutable-vector | 1206 | 70 (26) | 4 | 13 (7) | 41.6 | 13.1 | 30.5 | 1.5 | 5.0 | 287 |
| names-and-scoping.bot | 58 | 61 | hir-syntax, strict-references, surface-lowering | 861 | 58 (35) | 2 | 2 (0) | 2.6 | 2.3 | 5.6 | 0.7 | 2.0 | 146 |
| native-aggregates.bot | 70 | 69 | native-mutarray, native-param-aggregate, native-refinement-propagation, native-tiny-leaf-inline | 1223 | 57 (0) | 1 | 1 (0) | 5.6 | 13.4 | 25.9 | 1.7 | 5.1 | 323 |
| native-values.bot | 89 | 62 | backends, native, native-bitwise-fold | 1102 | 79 (0) | 1 | 1 (0) | 4.4 | 12.1 | 17.2 | 1.3 | 4.3 | 267 |
| opaque-instances.bot | 1 | 1 | opaque-struct | 37 | 1 (0) | 1 | 1 (0) | 1.1 | 0.3 | 1.1 | excl. | 0.4 | 61 |
| opaque.bot | 91 | 73 | opaque-struct | 1124 | 91 (62) | 6 | 10 (2) | 49.3 | 21.2 | 22.0 | 1.5 | 5.5 | 305 |
| ownership.bot | 38 | 13 | affine, coroutines, mutable-array, mutable-vector | 700 | 38 (24) | 3 | 10 (5) | 21.7 | 4.9 | 9.3 | 1.3 | 2.9 | 177 |
| range-and-contract-values.bot | 78 | 68 | checked-domain-proof-provenance, closed-closure-entry-facts, conjunctive-entry-facts, exact-value-facts +5 | 1149 | 76 (25) | 4 | 4 (0) | 24.8 | 30.1 | 22.5 | 1.7 | 5.9 | 328 |
| raw-int-abi.bot | 52 | 50 | raw-int-abi, raw-internal-abi | 951 | 52 (0) | 1 | 1 (0) | 3.4 | 17.7 | 13.2 | 1.3 | 3.9 | 216 |
| recursive-types.bot | 9 | 4 | affine, mutable-vector, structs | 261 | 9 (0) | 1 | 3 (1) | 2.4 | 0.4 | 2.0 | 0.5 | 0.8 | 80 |
| refinements.bot | 66 | 52 | refined, refined-signatures, refinement-values | 1036 | 66 (29) | 3 | 10 (5) | 46.1 | 10.1 | 13.0 | 1.1 | 3.2 | 240 |
| representation.bot | 13 | 11 | abi-numeric, enums, loop-counted, native +6 | 332 | 13 (1) | 2 | 2 (0) | 3.0 | 0.9 | 3.4 | 0.6 | 1.1 | 106 |
| static-compile-erased-consumer.bot | 2 | 1 | static-economics | 59 | 2 (1) | 2 | 2 (0) | 1.7 | 0.3 | 1.1 | 0.3 | 0.6 | 66 |
| static-compile.bot | 81 | 58 | static-compile, static-economics | 1452 | 158 (84) | 7 | 14 (4) | 70.9 | 16.0 | 33.4 | 1.7 | 8.6 | 384 |
| stdlib-namespaces-entry-members.bot | 4 | 2 | stdlib-namespaces | 64 | 4 (0) | 1 | 1 (0) | 0.9 | 0.3 | 1.2 | 0.3 | 0.6 | 62 |
| stdlib-namespaces-str-only.bot | 1 | 1 | stdlib-namespaces | 25 | 1 (1) | 2 | 2 (0) | 1.5 | 0.2 | 0.9 | 0.3 | 0.3 | 58 |
| stdlib-namespaces-unimported.bot | 2 | 1 | stdlib-namespaces | 32 | 2 (2) | 2 | 2 (0) | 1.6 | 0.3 | 1.0 | 0.3 | 0.4 | 61 |
| stdlib-namespaces.bot | 114 | 49 | module-static-values, stdlib-namespaces | 1065 | 110 (46) | 3 | 9 (5) | 54.9 | 17.4 | 34.9 | 1.8 | 7.7 | 360 |
| string-natives.bot | 82 | 81 | native-string-region, native-string-traversal, native-string-view, native-uri-escape | 1077 | 45 (0) | 1 | 1 (0) | 5.6 | 9.9 | 22.9 | 1.5 | 5.5 | 294 |
| string-representations.bot | 48 | 50 | packed-ascii, short-string | 900 | 48 (0) | 1 | 1 (0) | 4.1 | 5.8 | 13.7 | 1.0 | 2.8 | 203 |
| strings.bot | 94 | 102 | ascii, emailish-predicate, native-tcl-unicode, str-char-at +2 | 932 | 67 (17) | 2 | 2 (0) | 8.7 | 14.0 | 21.4 | 1.5 | 4.9 | 276 |
| struct-representation-instances.bot | 15 | 14 | struct-scalar-replacement | 240 | 15 (0) | 1 | 1 (0) | 1.7 | 0.7 | 1.9 | excl. | 0.8 | 87 |
| struct-representation.bot | 110 | 98 | struct-scalar-replacement, virtual-construction | 1732 | 107 (0) | 1 | 1 (0) | 9.6 | 27.8 | 58.9 | 2.5 | 12.7 | 538 |
| structs-and-enums-instances.bot | 4 | 4 | structs | 84 | 4 (0) | 1 | 1 (0) | 1.1 | 0.3 | 1.0 | excl. | 0.5 | 65 |
| structs-and-enums-qualifiers.bot | 2 | 1 | enums | 49 | 2 (2) | 1 | 1 (0) | 1.0 | 0.3 | 1.3 | 0.3 | 0.4 | 61 |
| structs-and-enums.bot | 111 | 77 | enums, structs | 1335 | 111 (45) | 4 | 17 (11) | 60.6 | 10.9 | 19.4 | 1.5 | 5.2 | 298 |
| traits-path.bot | 2 | 2 | traits | 73 | 2 (0) | 1 | 2 (0) | 1.5 | 0.3 | 1.2 | 0.3 | 0.5 | 74 |
| traits.bot | 67 | 43 | traits | 1024 | 79 (38) | 8 | 13 (3) | 45.3 | 10.6 | 14.4 | 1.4 | 4.5 | 247 |
| types.bot | 96 | 93 | applied-types, empty-collection-admissibility, source-types, symbolic-type-identity +1 | 1269 | 94 (34) | 3 | 3 (0) | 14.6 | 10.3 | 19.5 | 1.5 | 6.2 | 290 |
| unicode-strings.bot | 56 | 56 | native-tcl-unicode | 190 | 5 (0) | 1 | 1 (0) | 1.9 | 1.4 | 4.3 | 0.5 | 1.0 | 94 |
| validators-and-proofs.bot | 153 | 54 | proof-loop-intervals, proven-bounds, refinement-validators | 1748 | 153 (76) | 3 | 4 (0) | 18.3 | 17.6 | 34.4 | 2.0 | 7.0 | 440 |
| values.bot | 32 | 36 | blocks, calls, control, elif +8 | 1005 | 26 (0) | 1 | 1 (0) | 4.3 | 5.4 | 14.9 | 1.1 | 3.0 | 280 |
| warning-programs.bot | 42 | 37 | fixed-arity-list-return, many-boolean-arguments, one-char-string-literal, proves-naming +1 | 623 | 42 (14) | 3 | 4 (0) | 6.2 | 1.1 | 4.5 | 0.7 | 1.7 | 148 |
| total (88 suites) | 4572 | 3287 | | 63212 | 4378 (1390) | 211 | 329 (81) | 1518.4 | 774.0 | 1404.0 | 93.5 | 402.6 | |
