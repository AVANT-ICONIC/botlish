# Compilation isolation: a HIR's backends see its own declarations

A compilation registers its declarations in process-wide registries, and the
backends read them by bare name. So compiling one program could change or
break the lowering and the run of a HIR compiled earlier in the same process.
Every HIR now records the declaration state its build left behind, and every
entry point that reads the registries for a HIR activates that state first.

This document records the defect, the mechanism, the inventory it rests on,
and how it is tested. The investigation's raw data (reproducers, probes, phase
counts) was produced outside the repository; its findings are summarized here.

## Outcome

* **The defect.** Thirteen reproducers, each a pair of programs A and B, all
  failed on main at `2873664`. Each compiles A, runs it, compiles B, then runs
  A's same HIR again.
  - **Silently wrong values.** The Tcl backends used B's domain for A's
    `Small?`.
  - **Silently missing releases.** A coroutine owned by a dying struct was
    never released.
  - **Native code that built and then trapped.** Specialized lowering emitted
    `unreachable` for a projection, in the JIT and in a standalone executable.
  - **Lowering and run failures** in every other case. Two real golden suites
    were among them: traits-path.bot after contexts.bot.
  - **At corpus scale,** 44 of 72 artifact checksums of nine golden suites
    changed when the other suites were compiled in between, in the
    investigation's order. The audit below, in its own order, found 30.
* **The fix.**
  - `hir/declarations.tcl` captures the registries' state as a HIR side table,
    `declarations`, and `hir::activate` reinstalls it.
  - Eight procedures read the registries for a HIR they are given, and each
    activates it first.
  - The Tcl compiler's code cache no longer reuses a unit compiled under
    another state.
  - No lookup site changed.
* **Cost.**
  - Activating the HIR already active is one comparison, 0.8 µs.
  - A switch between two states (traits-path.bot and contexts.bot) is about
    64 µs.
  - A build costs 0.5-9 s.
* **Evidence.**
  - `tests/compilation-isolation.test`: all of its 19 tests pass, and all fail
    without the fix.
  - `audit/compilation-isolation/tools/interleave.tcl`: nine golden suites'
    artifacts and outcomes are identical in both orders. Before the fix, 30
    checksums of eight of the suites changed when the others were compiled in
    between: core IR, Tcl code, NIR and Tcl-backend outcomes.
  - Each suite's artifacts right after its own compilation are identical to
    the tree before the change.
  - The mutation harness kills every mutant.

## The registries

`hir::BuildOnce` resets and refills the registries on every build that
receives the declaration options. Every frontend passes them, and so does
every trial build, monomorphizing build and static-decision round. `hir::read`
re-registers the declarations printed in HIR text.

| Registry | Holds | Read by a backend |
|---|---|---|
| `core::type::registry`, source entries | integer domains, refinements | the interpreter (`validate`), compiled code (contract checks), native lowering (`normalize`, `integerFacts`) |
| `core::native::registry` and `sourceNatives`, source entries | each domain's `T?` predicate | the interpreter and compiled code, on every native call |
| `hir::sourcetypes::generation` | what to unregister | — |
| `hir::structs::registry` | fields, field types, opacity | `hir::lower` (drop descriptors), the Tcl compiler, native lowering (layouts, NIR shapes) |
| `hir::enums::registry` | cases in declaration order | native lowering (the NIR enum table) |
| `hir::errordecls::current` | canonical error identities | — |
| `hir::errordecls::payloads` | payload layouts | `hir::lower` (`ReleasingOnError`), native lowering |
| `hir::traits::registry`, `impls`, `unitNames` | trait requirements and candidates | — |
| `hir::imports::table` | import environments | — |

* **Derived caches.** `hir::structs::affinity`, `hir::traits::cache` and
  `hir::contexts::traitCache` are reset when a state is installed.
* **Process-lifetime entries.** Compiler-registered types and natives share
  the first two variables, but never change.
* **What the native runtime needs.** NIR is self-contained: its header carries
  the natives, shapes and enum tables. So `botlish-native` and standalone
  executables need nothing from the registries at run time.

## The mechanism

**Capture.** `hir::declarations::capture` returns the registries' values:
* the `core::type` and `core::native` entries named in `generation`;
* the `hir::` registries themselves.

These are plain values. A predicate's entry names `core::type::PredicateImpl`
and its type's name, never a procedure created for it. So the state can be
installed in another process too.

**Stamp.** `hir::BuildOnce` stamps its HIR once the declarations are
registered and resolved, before the check. `hir::read::Program` stamps the HIR
it reads. Both call `hir::declarations::invalidate` before they write a
registry. A compilation that fails half way therefore leaves the active state
unknown, so the next activation installs. Without this, an earlier HIR's
activation would have been a no-op over registries the failed compilation had
already reset: `ci-failed-compilation` tests it.

**Activate.** `hir::activate HIR` does nothing when HIR's state is the active
one. Tcl compares one shared object with itself in O(1), and content-equal
states compare equal. Otherwise `Install`:
1. unregisters the active source types and natives;
2. inserts HIR's entries;
3. assigns the `hir::` registries;
4. resets the derived caches.

It is called by:

* `hir::lower`: the interpreter path, and `hir::lower`'s own payload and drop
  decisions;
* `hir::format`, which prints types from the registries;
* `hir::specialize::analyze` and `hir::aot::analyze`. `native::executable`,
  `native::report` and `main.tcl -aot`/`-aot-spec` start with these.
* `core::compiler::compileHir`, and `runUnit`: a compiled unit calls
  predicates by name as it runs, so running it again after another
  compilation activates its HIR again;
* `native::prepareHir`, through which every native lowering passes
  (`native::lowered`).

`core::compiler::compileUnit`, the core IR *text* entry point, drops a cached
unit whose HIR's state is not the active one. The core IR text does not say
which declarations the unit was generated against.

**What it does not cover.** Core IR text carries no declarations. Core IR kept
and run on a Tcl backend after another compilation still reads the later
compilation's registries. Running the HIR instead, or lowering it again, is
covered.

## Options considered

* **A compilation context passed through every lookup.** This would touch the
  259 procedures that read the registries, directly or through calls, with
  about 1,400 call sites. It would also need a run-time handle in generated
  code. Rejected: it is activation with the context made explicit, at a
  thousand times the risk.
* **Compilation-qualified names.** Rejected. Identities live in runtime values
  (struct heads, enum cases, error ids), in printed output and in NIR tables,
  and qualifying them would put a compilation tag inside runtime values.
* **Backends reading the HIR's declaration fields.** This means reading
  `sourceTypes`, `errorPayloads` and the rest instead of the registries.
  There are 37 direct backend sites, but four layout queries and the type
  algebra in `hir::types` are shared with the front end. Deferred: it is
  needed only if a backend must run without the Tcl registries.
* **A child interpreter per compilation.** It isolates everything, at
  130-180 ms per compilation plus re-parsing the library. HIRs would have to
  cross the boundary as text. It is a possible driver for batch tools, not a
  fix for the library API.

## Tests and audits

* **`tests/compilation-isolation.test`** has 19 tests. They cover each kind of
  declaration on each backend that reads it:
  - a domain redeclared or dropped;
  - structs, enums and error payloads;
  - a payload crossing a releasing error edge;
  - a coroutine-owning struct.

  They also cover the compiled-once unit, the core IR code cache, reading HIR
  text, `hir::format`, the analyses tools call directly, two real golden
  suites, a standalone executable (stub linker), a failed compilation, and the
  activation counter.
* **`audit/compilation-isolation/tools/interleave.tcl`** works in one process.
  It checksums each of nine golden suites' backend artifacts and outcomes
  right after the suite's own compilation. Then, once every suite is compiled,
  it checksums them again in reverse order, and every checksum must be equal.
  - The artifacts are core IR, the Tcl compiler's code, and specialized and
    generic NIR.
  - The outcomes are those of interp, compile, cranelift and
    cranelift-generic.
  - With `-print 1`, two trees can be compared.
* **`audit/compilation-isolation/tools/mutate.tcl`** applies the 15 mutants in
  `mutants.txt`: each activation site, the cache check, each stamp, the
  invalidation, and the parts of `Install`. The test file must kill every
  one.

## Defects found on the way

* **`hir::affine::Descriptor`, fixed.** It pushed a struct's id onto the
  process-wide `descriptorVisiting` outside the `try` that pops it. One
  failing layout lookup then emptied every later drop descriptor of that
  struct in the process (`af-descriptor-exception-safe`).
* **`hir::structs::IsAffine`** answers 0 for a struct it does not know, where
  an internal error would be safer. Unreachable once activation holds.
* **Never reclaimed, but correct:** the Tcl compiler's code cache and unit
  procs, the vector and array stores, and `tests/helpers.tcl`'s
  `::hirOfLowered`. These grow for the life of the process.

## What it enables

A HIR together with its `declarations` is self-contained: it can be lowered
and run in any order, and in another process. The HIR interchange format
(HIR-INTERCHANGE.md) is built on that, and so is the front-end cache built on
the format (LARGE-SCALE-GOLDEN-MIGRATION.md, Recommendation 3).
