# audit/react-native

The probes of the React Native target census (REACT-NATIVE-TARGET-CENSUS.md):
Botlish functions called from JavaScript as a Pure C++ TurboModule. Nothing
here is part of the compiler. Nothing in `core/`, `hir/`, `surface/`,
`compiler/` or `native/` loads it.

* `probe/rnprobe.bot` -- the exported Botlish functions (Int, String, Bool,
  a declared error, non-tail recursion). Its top level only gives native
  lowering their instances.
* `probe/standin.c` -- the same C ABI in C, for telling a React Native
  failure from a Botlish one.
* `tools/libmode.tcl` -- a stand-in for the library mode the compiler lacks.
  * It produces a static library of C wrappers over the functions' generic
    entries, built from the executable link's captured startup crate.
  * It writes the library, the C header and an export manifest.
* `tools/rnpackage.tcl` -- a prototype of the React Native plugin's
  generator.
  * From the export manifest and header it writes a complete package:
    `package.json` with `codegenConfig`, `react-native.config.js`, the
    TypeScript spec and entry point, the C++ adapter, the Android CMake
    file, the iOS module provider and podspec.
  * With `-codegen-project` it also runs Codegen.
* `tools/host-spike.tcl` -- the host probe.
  * Library, package, Codegen, React Native's TurboModule sources and
    `host/host_main.cpp`, on a Hermes built at React Native's pinned tag,
    running `host/probe.js`.
  * Then `host/host_async.cpp` (Promise methods on a Botlish worker thread)
    running `host/async.js`.
* `tools/macho-platform.tcl` -- reads or rewrites a Mach-O object's
  `LC_BUILD_VERSION`.
* `app/App.tsx` -- the probe app's screen.
* `ci/` -- the steps of `.github/workflows/react-native-probe.yml`:
  * the Botlish library for a mobile Rust target;
  * a stock React Native 0.88 app with the generated package installed from
    its npm tarball;
  * the emulator and simulator runs.
* `patches/runtime-aarch64-cfg.patch` -- the one-line runtime fix the AArch64
  Android and iOS builds apply. Without it the runtime does not compile for
  them: `prepare` is defined twice.

```
tclsh9.0 audit/react-native/tools/host-spike.tcl -work DIR -react-native-project RN-PROJECT \
    -hermes-src HERMES -hermes-build HERMES-BUILD -folly FOLLY ?-stack-kib 512? ?-gc-stress 1?
```

REACT-NATIVE-TARGET-CENSUS.md, section 16, has the prerequisites.
