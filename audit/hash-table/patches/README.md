# Hash-table experiment: patches not proposed for main

* `probe-primitive.patch` is the runtime half of RT-1's probe primitive,
  `mutable_array::probe_linear` (HASH-TABLE-COMPILER-PRESSURE.md, RT-1;
  HASH-TABLE-EXPERIMENT.md, "Runtime experiments"): the Tcl
  implementation and registration in core/mutarray.tcl, and the native
  op `mutarrayprobe` with its Rust helper `rt_mutarray_probe`.
  * It measures the primitive. It is not proposed as an intrinsic.
  * `git am` applies it to `f496a91`; that is the `probe` tree of
    `results/`. The `comboprobe` tree is the merged prototypes at
    `19bd2ff` with the same change merged in.
  * Later changes to core/mutarray.tcl conflict with it, so on today's
    tree it needs `git apply -3` and a resolution of that file.
  * `impl/lpp.bot`, its one user, compiles only with it applied.
