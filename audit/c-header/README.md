# audit/c-header

The empirical C header experiment of C-HEADER-ARCHAEOLOGY.md
(`docs/C-HEADER-ARCHAEOLOGY.md`): a research instrument that preprocesses
real C headers with the installed toolchain, parses the result into an
exploratory FFI IR and counts what it finds. It is not part of the
compiler, not the C FFI, and not run by `tests/local.tcl` or CI.

```sh
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 audit/c-header/tools/fetch.tcl     # BoringSSL 0.20260929.0 and Tcl 9.0.1, pinned
tclsh9.0 audit/c-header/tools/all.tcl       # regenerate results/ and unsupported/ (about 90 s)
tclsh9.0 audit/c-header/tests/parser.test   # the parser, no toolchain needed
tclsh9.0 audit/c-header/tests/corpus.test   # the unsupported corpus reproduces
tclsh9.0 audit/c-header/tools/query.tcl tcl-stubs callbacks
tclsh9.0 audit/c-header/tools/diff.tcl tcl-embed tcl-stubs
```

* `profiles/` -- the import profiles (library revision, entry headers,
  include directories, defines).
* `tools/` -- the toolchain adapter (`toolchain.tcl`, the only place that
  builds a command line), the tokenizer and declaration parser
  (`cdecl.tcl`), the IR text and type utilities (`ir.tcl`), the census,
  the compiler oracle, the ABI probe, the thunk prototype, queries and
  diffs.
* `results/PROFILE/` -- the IR (`ir.txt`), the system declarations it
  depends on (`system.txt`), the macro records (`macros.txt`), the census
  (`census.txt`, `census.tsv`), the import profile (`profile.txt`), the
  oracle's and the ABI probe's reports, generated Botlish layouts, and
  timings. Everything but `timing.txt` is byte-identical between runs of
  the same profile, toolchain and revision.
* `unsupported/LIBRARY/` -- one small reproducible C fixture per shape the
  low-level FFI cannot take as an ordinary declaration.

The toolchain comes from `BOTLISH_C_CC` (default: the first of cc, gcc,
clang), `BOTLISH_C_CPP`, `BOTLISH_C_TARGET`, `BOTLISH_C_INCLUDE`,
`BOTLISH_C_DEFINES`, `BOTLISH_C_UNDEFINES` and `BOTLISH_C_FLAGS`; the
library sources from `BOTLISH_C_HEADER_SOURCES` (default:
`c-header-src/` under Botlish's cache directory).
