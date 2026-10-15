# HIR interchange: the analyzed HIR as a file

The front end's output, a fully analyzed HIR, can now be written to a file and
read back, by the same process later or by another one. Lowering and running
it then behave exactly as if the HIR had just been built: the same core IR, the
same NIR, the same outcome on every backend. No front-end work is repeated.

It serves two purposes:

* **Cross-process caching of the front end** (short term). The front end
  dominates the cost of every compilation, at 0.5-9 s per build of a golden
  suite. A cache keyed by the program and the compiler can now skip it in a
  later process.
* **A front end written in Botlish** (medium term). Such a front end would
  produce this format, and the existing backends would consume it.
  [Towards a front end in Botlish](#towards-a-front-end-in-botlish) says what
  that still needs.

The format rests on compilation isolation (COMPILATION-ISOLATION.md). A HIR
records the declaration state its build left behind, and its backends install
that state before reading the registries. That makes a HIR self-contained,
which is what lets it cross a process boundary.

## Outcome

* **The format.** `hir/interchange.tcl` writes a header line and a Tcl dict:
  the front end's fingerprint, the Tcl libraries required, and the HIR
  itself, `declarations` included. The trait source build is left out unless
  asked for.
* **Entry points.**
  - `hir::interchange::encode`, `decode`, `writeFile` and `readFile`.
  - `main.tcl -emit-hir-interchange FILE.bot` writes `FILE.hirx`.
  - `main.tcl` runs a `.hirx` file on any backend.
  - `main.tcl -emit-native-executable FILE.hirx` builds a standalone
    executable from one.
* **Validity.** A text is valid for the front end that built it (`core`,
  `hir`, `surface`): `decode` refuses one from any other. The backends may
  differ.
* **Evidence.**
  - `tests/hir-interchange.test` (11 tests) and `tests/hir-cache.test`
    (15 tests).
  - `audit/hir-interchange/tools/roundtrip.tcl`: nine golden suites written by
    one process and read by a fresh one, through the format and through the
    cache. Every HIR, artifact checksum and outcome on four backends is
    identical, and the fresh process ran no build.
  - The mutation harness kills every mutant.
* **Cost.** See [Cost](#cost).

## The format

```
botlish-hir-interchange VERSION
compiler FINGERPRINT requires LIBRARIES hir HIR
```

* **Line 1** names the format and its version, now 1. `decode` refuses any
  other first line or version (`{HIR INTERCHANGE FORMAT}`).
* **The rest** is one Tcl dict, which spans many lines:
  - `compiler`: the fingerprint of the front end that built the HIR (see
    [Validity](#validity)).
  - `requires`: the optional Tcl libraries (`core::loadLibrary`) loaded in the
    writing process. `decode` loads them first. Today lib/ has no Tcl library,
    so the list is empty; the mechanism stays because `# requires:` does.
  - `hir`: the HIR dict, exactly as the front end returned it, side tables
    included.
* **The trait source build.** The front end keeps the checked source build of
  a trait program as `traitSource`, for warnings and the context-trait summary.
  No backend reads it, and it is about half the size, so it is left out unless
  `encode -trait-source 1` keeps it.
* **Encoding.** Files are UTF-8 with LF line ends, whatever the platform.

A HIR read back is equal (`eq`) to the HIR written, minus `traitSource`.

## What makes a HIR self-contained

A backend reads three things for a HIR:

1. **The HIR's own nodes and side tables.** Examples: semantic instances,
   coroutine protocols, completion verdicts, method choices, error payloads.
   These are values inside the dict, so they travel with it.
2. **The declaration registries** that `hir::BuildOnce` fills: source-defined
   types and their predicates, structs, enums, error identities and payloads,
   traits, imports. The HIR's `declarations` side table holds their values,
   and `hir::activate` installs it. Every backend entry point already calls
   it, and `decode` calls it too.
   - A predicate's entry is data (`core::type::PredicateImpl NAME`), never a
     procedure created by a build, so installing it in a fresh process works.
3. **Process-lifetime state.** This is compiler-registered types and natives,
   and the Tcl libraries. It is the same in every process of one front end,
   apart from the libraries, which `requires` names.

`encode` refuses a HIR without `declarations`: one built before compilation
isolation, or assembled by hand.

`hir::format`'s text is not this format. It is a readable rendering for
debugging and tests, and `hir::read` rebuilds a HIR from it. It carries no
module sections and no side tables, so it is no substitute.

## Validity

A HIR's representation is the front end's own, and it changes whenever the
front end does. A HIR built by one front end and read by a backend expecting
another's could be silently wrong, not just rejected. So:

* **Fingerprint.** The format records the fingerprint of the front end that
  built the HIR, `hir::interchange::fingerprint`.
  - It is a checksum (CRC-32 and Adler-32) of every Tcl source file that can
    change the HIR a build returns, with each file's name and size:
    `core` (registered types and natives, and the evaluator the front end
    shares), `hir`, `surface`, and any Tcl library in `lib`. It also covers
    the Tcl patch level.
  - It is computed once per process, in about 3 ms.
* **The backends are not in it.** `compiler/` and `native/` read a HIR and
  never shape one: no front-end procedure calls them, and they define no
  front-end procedure and register no type or native. A text built by an
  unchanged front end therefore equals the HIR the current backends would get
  from a fresh build, so editing a backend keeps every text valid. This is
  what makes the front-end cache pay off while working on native lowering.
  (`hir/lower.tcl`, `hir/aot.tcl` and `hir/specialize.tcl` are backend-side
  but live in `hir/`, so editing them invalidates texts needlessly.)
* **Refusal.** `decode` refuses a text whose fingerprint differs
  (`{HIR INTERCHANGE COMPILER}`). There is no option to skip the check.
* **The native binaries** consume NIR, not HIR, and are not in the
  fingerprint either.

## Using it

```sh
tclsh9.0 main.tcl -emit-hir-interchange prog.bot   # writes prog.hirx
tclsh9.0 main.tcl -backend cranelift prog.hirx     # runs it, with no front end
BOTLISH_NATIVE_LINKER=stub tclsh9.0 main.tcl -emit-native-executable prog.hirx
```

From Tcl:

```tcl
set hir [surface::readProgramFile prog.bot]
hir::interchange::writeFile prog.hirx $hir
# ... in any later process with the same front end:
set hir [hir::interchange::readFile prog.hirx]
native::evalHir $hir
```

A `.hirx` file is a compilation result, not a source. `main.tcl` prints a
program's warnings when it compiles the source, not when it runs the file.

## The front-end cache

`surface/cache.tcl` keeps program files' HIRs across processes, in the
interchange format, in a directory the user names:

```sh
export BOTLISH_HIR_CACHE=$HOME/.cache/botlish-hir
tclsh9.0 main.tcl -backend cranelift prog.bot     # builds, keeps the HIR
tclsh9.0 main.tcl -backend interp prog.bot        # reads it: no front end
tclsh9.0 tests/golden/run.tcl tests/golden/traits-path.bot
```

* **Opt-in.** `BOTLISH_HIR_CACHE` names the directory; it is read fresh by
  each compilation, like `BOTLISH_WARNINGS`. `surface::readProgramFile`
  takes `-cache DIR` to override it (`-cache ""` for none).
  - **Who uses it.** Everything that compiles a program file through it:
    `main.tcl`, the golden runner (`tests/golden/run.tcl`, and
    `audit/golden/tools/check.tcl`'s children) and the benchmarks that run
    programs. `surface::compile` of a source string does not.
  - **Who bypasses it.** The benchmarks that time the front end
    (`bench/golden-suites.tcl`, `bench/golden-framework.tcl`). The test
    suite's harness unsets the variable, so a developer's cache never decides
    what a test compiles.
* **Exact.** A hit returns exactly the HIR the build would have returned. That
  holds because a build's HIR is a pure function of what the key and the
  dependencies record. A build after other compilations returns the same HIR
  as one built alone in a fresh process (compilation isolation), and the
  audit checks it suite by suite.
  - **One exception.** `staticStats` records `depMs`, the time the static
    decisions spent in their dependency analysis. It is the one measurement
    a HIR holds, and a hit carries the time of the build it kept. Only
    `hir/static.tcl`'s own statistics read it.
* **The key**, compared exactly; its checksum only names the entry file:
  - the front end's fingerprint;
  - the program's path as given (the HIR records it) and its exact text;
  - the library directory modules are read from, and the Tcl libraries
    loaded;
  - `-strict`, the warning mode, and `BOTLISH_STATIC_SCHEDULER`.
* **The dependencies**, checked on every hit: the module path of every
  namespace a file of the program imports, by `import NS` or by `import type
  NS::Type`, with the exact text the build read there, or none.
  - Imports are the only thing that loads a module (IMPORTS.md: dependencies
    are declared, never discovered), so these are all the files a build reads
    besides the program. The cache audit checks this for every suite.
  - A namespace with no module file (an intrinsics-only one such as `str`)
    must still have none.
  - A module's path is a function of its namespace and the library directory
    alone (no search path, surface/modules.tcl), so nothing else can change
    which files a program reads.
  - The text recorded is the one the loader read during the build, so a
    module edited during the build leaves an entry that misses.

  So an edited module misses and builds again, and so does a namespace that
  gains a file.
* **Warnings.** An entry belongs to one warning mode. In the default mode, a
  hit prints the warnings its HIR carries on the compilation's channel, in
  the build's order and words. In the error mode a kept HIR has none, because
  a build that found one raised it.
* **Never kept:** a compilation that fails, and one that traces its static
  decisions (`BOTLISH_STATIC_TRACE`), whose trace a hit could not print.
* **Never an error.** A missing, unreadable, foreign or stale entry is a miss,
  and so is an entry with another key under the same name or another front
  end's HIR. An unwritable directory just isn't written. An entry is written
  under a private name and renamed into place, so a concurrent reader sees
  all of it or none.
* **Growth.** Entries are about twice the interchange text, because they keep
  `traitSource` (1.5 MB for traits-path.bot). Nothing is evicted: entries of
  an older front end stay until the directory is cleared.
* **What it saves.** The front end. See [Cost](#cost).

## Tests and audits

* **`tests/hir-interchange.test`** covers:
  - a program with every kind of declaration a backend reads. It is encoded,
    decoded after another program redeclares the same names, and then lowered
    and run on every backend.
  - the same program in a fresh process, which must build nothing.
  - the text's shape;
  - the trait source build, left out and kept;
  - decoding after a failed compilation;
  - each format error, and the fingerprint's inputs;
  - `encode` of a HIR without `declarations`;
  - `main.tcl`'s `.hirx` output and input;
  - a standalone executable built from a `.hirx` file.
* **`tests/hir-cache.test`** covers:
  - a miss, then a hit that builds nothing and equals the built HIR, a trait
    program's (with its source build) included;
  - a hit in a fresh process;
  - an edited program, and an edited module (stale);
  - a module read only through `import type` (stale when edited);
  - a module edited during the build (stale);
  - a namespace that gains a module file (stale);
  - each part of the key, the Tcl libraries loaded included;
  - warnings replayed;
  - damaged, colliding and foreign entries;
  - a failed compilation, kept nowhere;
  - an unwritable directory;
  - `BOTLISH_HIR_CACHE`, `-cache ""` and `BOTLISH_STATIC_TRACE`.
* **`audit/hir-interchange/tools/roundtrip.tcl`.**
  - **Parent.** One process compiles each golden suite of a list (nine by
    default, `-suites all` for every one). It checksums the HIR, the suite's
    core IR, the Tcl compiler's code (numbering normalized), and specialized
    and generic NIR. It also checksums the outcome on interp, compile,
    cranelift and cranelift-generic.
    - With `-via interchange`, the default, it writes each HIR to a private
      temporary directory.
    - With `-via cache`, it compiles through a front-end cache there.
  - **Child.** A fresh `tclsh9.0` then reads every HIR back (the files, or
    the suites through the cache) and takes the same checksums. It reports how
    many HIRs it built and how many cache misses it had, which must both be
    zero.
  - **Purity (`-via cache`).** A fresh process per suite builds it alone,
    without the cache. Its HIR must equal the one the cache holds, which the
    parent built after the suites before it. The comparison sets `depMs` to
    0 first.
  - **Result.** Any difference is printed and fails the run.
* **`audit/hir-interchange/tools/mutate.tcl`** applies the mutants in
  `mutants.txt` (beside it), each a deliberate bug, to a private copy of the
  compiler, and runs the two test files against each. Every mutant must be
  killed. The mutants cover:
  - the format: the fingerprint check, activation, the declarations, the
    fingerprint's inputs;
  - the cache key: each of its parts;
  - the dependencies, and the texts recorded for them;
  - the lookup's checks and its errors;
  - the warnings replay, tracing, the stored trait source, store errors and
    the `-cache` option.

## Cost

Measured on traits-path.bot: the HIR is 1.45 million characters, half of it
`traitSource`.

| Step | Time |
|---|---|
| `fingerprint` (once per process) | 3 ms |
| `encode` (without `traitSource`) | 16 ms |
| `decode`, activation included | 17 ms |
| the build it replaces | about 2 s |

The text is 725 KB without `traitSource`.

## Towards a front end in Botlish

The format is the boundary such a front end would write to. Version 1 is a
*trusted, same-front-end* format: `decode` checks the fingerprint, then
believes the HIR. A front end written in Botlish would be a different front
end by construction, so before one can use it, the format needs:

* **A specified schema.** Today's is the Tcl dict the front end happens to
  build. The schema would cover the node kinds, the side tables a backend
  reads, and the declaration state.
* **A validating reader** in place of the fingerprint check. It would check
  the schema, the way `hir::read` checks HIR text, and recompute or verify the
  facts a backend trusts.
* **A smaller surface.** Some of the side tables are analysis caches the
  backends could recompute, not front-end output.

Those are a format version 2 decision, best made with the Botlish front end's
first milestone in view.
