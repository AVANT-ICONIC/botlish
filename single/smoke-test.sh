#!/usr/bin/env bash
# single/smoke-test.sh -- checks a single-file Botlish compiler (SINGLE-EXECUTABLE.md).
#
#   single/smoke-test.sh BOTLISH
#
# Runs BOTLISH, the executable single/build.sh built, the way a user without
# this checkout's toolchain would: in an empty environment (no PATH, so no
# tclsh, rustc, cc or ld, and no locale), with a fresh HOME. It needs this
# checkout's examples/ (the programs it compiles), and nothing else of it.
# .github/workflows/single-executable.yml runs it in a stock ubuntu:24.04
# container.
#
# Checked: every backend runs the sample programs to the same values; the
# no-argument default run; the inspection options; a rejected program fails;
# -emit-native-executable produces executables that run without anything
# else; and the native backend still works with no cache directory at all
# (no HOME).
set -euo pipefail

botlish=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
work=$(mktemp -d "${TMPDIR:-/tmp}/botlish-smoke.XXXXXX")
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/home" "$work/programs/samples"
# The programs CI's native job runs on every backend (.github/workflows/tests.yml).
cp "$root"/examples/surface/0[1-8]*.bot "$root"/examples/surface/1[1-3]*.bot \
   "$root"/examples/stdlib/*.bot "$root"/examples/hir/0[1-3]*.hir "$work/programs/samples/"
cp "$root/examples/io/hello.bot" "$root/examples/linux/context-hello.bot" "$work/programs/"
cd "$work/programs"

fail() { echo "FAIL: $*" >&2; exit 1; }
# BOTLISH ARGS... in an empty environment with a fresh HOME.
run() { env -i HOME="$work/home" "$botlish" "$@"; }

echo "== $botlish"
for tool in tclsh tclsh9.0 rustc cargo cc ld; do
  echo "   host $tool: $(command -v "$tool" || echo no)"
done

for backend in interp compile cranelift; do
  run -backend "$backend" -warnings off samples/* >"$work/$backend.out" ||
    fail "backend $backend"
  grep -E '^(==|   value:)' "$work/$backend.out" | sed "s/ ($backend)\$//" >"$work/$backend.values"
  echo "   $backend: $(grep -c '^   value:' "$work/$backend.values") values"
done
for backend in compile cranelift; do
  cmp -s "$work/interp.values" "$work/$backend.values" ||
    { diff "$work/interp.values" "$work/$backend.values" >&2; fail "$backend disagrees with interp"; }
done
# (The unspecialized baseline does not compile every corpus program.)
run -backend cranelift-generic -warnings off samples/0*.bot >"$work/generic.out" || fail "backend cranelift-generic"

run >"$work/default.out" || fail "the no-argument run (examples/*.ir)"
grep -q '01-adder.ir (interp)' "$work/default.out" || fail "the no-argument run printed no example"

for option in -code -hir -ast -aot -aot-spec -contexts -traits -emit-nir -emit-clif; do
  run -backend compile -warnings off "$option" samples/01-arithmetic.bot >/dev/null || fail "option $option"
done
printf 'x = \n' >broken.bot
if run broken.bot >"$work/broken.out"; then fail "a broken program was accepted"; fi
grep -q 'SURFACE SYNTAX' "$work/broken.out" || fail "a broken program reported no syntax error"

for program in hello:unit context-hello:14; do
  name=${program%%:*}
  run -warnings off -emit-native-executable "$name.bot" >/dev/null || fail "emit $name"
  [[ $(env -i "./$name") == "Hello, world!"$'\n'"${program#*:}" ]] || fail "executable $name"
done
# Without HOME the native backend lives in a temporary directory for the run.
env -i "$botlish" -warnings off -emit-native-executable hello.bot >/dev/null || fail "emit without HOME"
[[ $(env -i ./hello) == $'Hello, world!\nunit' ]] || fail "executable built without HOME"
env -i "$botlish" -backend cranelift samples/01-arithmetic.bot >"$work/nohome.out" || fail "cranelift without HOME"
grep -q 'value: 50' "$work/nohome.out" || fail "cranelift without HOME: wrong value"

echo "== smoke test passed"
