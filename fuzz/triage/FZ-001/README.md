# FZ-001 — csv-argv never terminates on an unterminated quoted field

Filed: 2026-10-05 (campaign 2, FUZZING-ARGV-PROGRAMS.md)
Target: `csv-argv` (fuzz/programs/csv-argv.bot, from examples/stdlib/csv.bot)
Minimized input: 1 byte, `22` (`"`) — an argument consisting of a single
double-quote. (Raw AFL artifacts: 8 hang files, release + ASan campaigns,
all deduplicated into this one signature; the smallest raw is 3 bytes.)

## Signature

`csv-argv` does not terminate on any argument whose first character is a
quote with no closing quote in the rest of the text (the quoted-field
scanner walks past the end of the text forever).

## Vertical replay matrix (manually reproduced, commands below)

| vertical          | behavior                                             |
|-------------------|------------------------------------------------------|
| aot               | non-terminating (no exit within 120 s; also under GC-stress, valgrind, ASan) |
| interp            | `TCL LIMIT STACK`, exit 1 (clean error; only Tcl's recursion limit stops the same infinite recursion) |
| compile           | non-terminating (self tail call lowered to a loop)    |
| cranelift         | non-terminating (self tail call eliminated)           |
| cranelift-generic | non-terminating (self tail call eliminated)           |

## Mechanism

`scan_quoted(text, index, field)` (examples/stdlib/csv.bot, copied
verbatim into fuzz/programs/csv-argv.bot) recurses with `index + 1`
whenever `peek(text, index)` is not a quote. `peek` returns `""` past
the end of the text and nothing checks for it, so an unterminated quoted
field makes the scan walk past the end forever. In the native and
Tcl-compiled backends the recursion is a self tail call and becomes an
infinite loop; in the interpreter it is real recursion and stops at
Tcl's limit with a clean error.

## Classification

Program logic (shared algorithm), not a compiler or runtime defect:
examples/stdlib/csv.bot documents its input contract as "valid CSV of
this subset" and the sample driver only ever passes well-formed text,
so the example is within its own contract. The argv-driven program
violated its stated totality ("a value for ANY argv"): it diverges on
out-of-contract input. The divergence pattern (interp errors cleanly,
every other vertical loops) is the self-tail-call difference between the
interpreter and the compilers, working as designed.

Suspected layer: `fuzz/programs/csv-argv.bot`'s driver (and, latently,
the example's scanner for any future caller that passes unvalidated
text). Fix deferred to the downstream milestone per campaign policy; a
natural fix is an end-of-text exit in the driver's text (or rejecting
unterminated quotes before scanning).

## Reproduce by hand

```sh
printf '"' > /tmp/quote-arg
# aot (and aot-asan, +gc-stress, +valgrind): never exits
timeout 120 fuzz/harness/argv-file fuzz/build/aot/csv-argv /tmp/quote-arg
# interp: clean error
timeout 120 tclsh9.0 main.tcl -backend interp fuzz/build/aot/csv-argv.bot \
    -argv-hex 2f686f6d652f6d61726b75732f626f746c6973682d66757a7a2f66757a7a2f6275696c642f616f742f6373762d61726776 -argv-hex 22
# compile / cranelift / cranelift-generic: never exit
timeout 120 tclsh9.0 fuzz/scripts/replay.tcl compile csv-argv /tmp/quote-arg
timeout 120 tclsh9.0 fuzz/scripts/replay.tcl cranelift csv-argv /tmp/quote-arg
timeout 120 tclsh9.0 fuzz/scripts/replay.tcl cranelift-generic csv-argv /tmp/quote-arg
```

The suite form is `tclsh9.0 fuzz/scripts/replay-known-failures.tcl`
(expected.tsv; `HANG` means "no verdict within the suite's bound").

## Status update (2026-10-13, branch fuzz/argv-campaign)

Main (5e4b4cb2, 353 commits past the campaign base) has **not** fixed the
hang: examples/stdlib/csv.bot was rewritten (method sugar, `char_at`,
`quote_at?`) but `scan_quoted` still recurses past end-of-text -- verified
empirically by building the current example's definitions with this
driver: the 1-byte `"` input still does not exit (rc=124 after 30 s).

Fixed here in fuzz/programs/csv-argv.bot only (the example keeps its
documented valid-CSV contract): `scan_quoted` returns the accumulated
field at end-of-text. Post-fix behavior, all five verticals agreeing:

* `"`            -> `[[""]]` (exit 0)
* `"unterminated,x` -> `[["unterminated,x"]]` (EOF closes the field)
* every valid input parses exactly as before (seed baselines unchanged)

The known-failure suite now expects the post-fix values; the pre-fix
matrix above remains as the original evidence. Recommendation recorded
for the example's future: an end-of-text exit in scan_quoted (or an
explicit unterminated-quote error) would close the latent loop for any
caller that passes unvalidated text.
