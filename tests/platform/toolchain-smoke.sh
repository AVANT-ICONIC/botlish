#!/usr/bin/env bash
# tests/platform/toolchain-smoke.sh -- the host's C and Rust toolchains, not
# Botlish (MACOS-AARCH64-PORT-AUDIT.md, "CI and test tiers").
#
#   tests/platform/toolchain-smoke.sh
#
# Compiles, links and runs a small C program (also against a static library
# of its own, the shape of an `extern c library` link with -L), a single-file
# Rust program (rustc) and a one-crate Cargo package, in a private temporary
# directory, and checks that every executable is the host's native format:
# a Mach-O arm64 executable on macOS arm64, an ELF executable of the host's
# architecture on Linux. Then prints the facts a port reads: the C ABI facts
# (tests/platform/cabi-facts.c), the page size, and whether rustc's code for
# this host keeps a frame record in a function that calls (the native GC's
# frame walk needs one, .cargo/config.toml).
#
# Success proves the host can build and run native code. It says nothing
# about Botlish's native backend, which is tested separately. Bash 3.2 (the
# macOS /bin/bash) is enough.
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
work=$(mktemp -d "${TMPDIR:-/tmp}/botlish-toolchain.XXXXXX")
trap 'rm -rf "$work"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

os=$(uname -s)
machine=$(uname -m)
case "$os-$machine" in
  Darwin-arm64)  format='Mach-O 64-bit( [a-z]+)? executable arm64' ;;
  Linux-x86_64)  format='ELF 64-bit LSB .*x86-64' ;;
  Linux-aarch64) format='ELF 64-bit LSB .*(ARM aarch64|ARM64)' ;;
  *) fail "no expected executable format for host $os $machine" ;;
esac
echo "== host: $os $machine; executables must match /$format/"

# The executable PATH is the host's native format.
check_format() {
  local description
  description=$(file -b "$1")
  echo "   file: $description"
  echo "$description" | grep -Eq "$format" || fail "$1 is not a native executable of this host: $description"
}

# PROGRAM's output is EXPECTED.
check_output() {
  local output
  output=$("$1")
  echo "   ran:  $output"
  [ "$output" = "$2" ] || fail "$1 printed \"$output\", expected \"$2\""
}

cc=${CC:-cc}
echo "== C: $cc"
"$cc" --version 2>&1 | sed -n 1p | sed 's/^/   /'
cat > "$work/hello.c" <<'EOF'
#include <stdio.h>
int main(void) { printf("hello from C\n"); return 0; }
EOF
"$cc" -O2 -o "$work/hello-c" "$work/hello.c"
check_format "$work/hello-c"
check_output "$work/hello-c" "hello from C"

echo "== C, linked against a static library (-L DIR -lNAME)"
mkdir -p "$work/lib"
cat > "$work/probe.c" <<'EOF'
long botlish_probe_add(long a, long b) { return a + b; }
EOF
cat > "$work/uses-probe.c" <<'EOF'
#include <stdio.h>
long botlish_probe_add(long a, long b);
int main(void) { printf("%ld\n", botlish_probe_add(40, 2)); return 0; }
EOF
"$cc" -O2 -c -o "$work/probe.o" "$work/probe.c"
ar rcs "$work/lib/libbotlishprobe.a" "$work/probe.o"
"$cc" -O2 -o "$work/uses-probe" "$work/uses-probe.c" -L"$work/lib" -lbotlishprobe
check_format "$work/uses-probe"
check_output "$work/uses-probe" "42"

echo "== Rust: $(rustc --version)"
cat > "$work/hello.rs" <<'EOF'
fn main() { println!("hello from Rust"); }
EOF
rustc -O -o "$work/hello-rs" "$work/hello.rs"
check_format "$work/hello-rs"
check_output "$work/hello-rs" "hello from Rust"

echo "== Cargo: $(cargo --version)"
mkdir -p "$work/crate/src"
cat > "$work/crate/Cargo.toml" <<'EOF'
[package]
name = "botlish-toolchain-probe"
version = "0.1.0"
edition = "2021"
publish = false
EOF
cat > "$work/crate/src/main.rs" <<'EOF'
fn main() { println!("hello from Cargo"); }
EOF
cargo build --quiet --release --manifest-path "$work/crate/Cargo.toml" --target-dir "$work/crate/target"
check_format "$work/crate/target/release/botlish-toolchain-probe"
check_output "$work/crate/target/release/botlish-toolchain-probe" "hello from Cargo"

echo "== facts (informational)"
"$cc" -o "$work/cabi-facts" "$here/cabi-facts.c"
echo "   C ABI: $("$work/cabi-facts")"
echo "   page size: $(getconf PAGESIZE)"
echo "   rustc host: $(rustc -vV | sed -n 's/^host: //p')"
# A function that calls another keeps a frame record (x86-64: push rbp; mov
# rbp, rsp. AArch64: stp x29, x30 ...; mov x29, sp) in rustc's default code
# for this host, without .cargo/config.toml's force-frame-pointers?
cat > "$work/frames.rs" <<'EOF'
#[inline(never)] #[no_mangle] pub extern "C" fn botlish_probe_leaf(x: u64) -> u64 { x.wrapping_mul(3) }
#[inline(never)] #[no_mangle] pub extern "C" fn botlish_probe_caller(x: u64) -> u64 { botlish_probe_leaf(x) ^ botlish_probe_leaf(x + 1) }
EOF
rustc -O --crate-type=lib --emit=asm -o "$work/frames.s" "$work/frames.rs"
prologue=$(awk '/^_?botlish_probe_caller:/ {found=1; next} found && /^[[:space:]]+[a-z]/ {print; n++} n == 4 {exit}' "$work/frames.s" | tr -s ' \t' ' ')
echo "   rustc -O prologue of a calling function:$(echo "$prologue" | tr '\n' ';')"
if echo "$prologue" | grep -Eq 'push.*rbp|x29, ?x30'; then
  echo "   frame record by default: yes"
else
  echo "   frame record by default: no"
fi

echo "ok: the host C and Rust toolchains build and run native $os $machine executables"
