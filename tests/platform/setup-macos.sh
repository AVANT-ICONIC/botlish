#!/usr/bin/env bash
# tests/platform/setup-macos.sh -- the macOS prerequisites of this checkout
# (MACOS-AARCH64-PORT-AUDIT.md, "CI and test tiers"): what
# .devcontainer/setup.sh installs on Linux, for a macOS host.
#
#   tests/platform/setup-macos.sh ?GITHUB_PATH-FILE?
#
# Tcl: core/core.tcl needs Tcl 9 (Linux pins the 9.0.1 .deb packages,
# AGENTS.md); on macOS it is Homebrew's tcl-tk formula, installed only when
# no tclsh9.0 is on PATH. The formula's version is whatever Homebrew ships
# (printed, and required to be 9.x with tcltest 2.5), not the Linux pin.
# Rust: the stable toolchain, as on Linux (the pinned cranelift crates need
# a recent rustc). With a file argument (a workflow's $GITHUB_PATH) the
# directory holding tclsh9.0 is appended to it for later steps.
set -euo pipefail

[ "$(uname -s)" = Darwin ] || { echo "setup-macos.sh: not a macOS host" >&2; exit 1; }

if ! command -v tclsh9.0 >/dev/null 2>&1; then
  command -v brew >/dev/null 2>&1 || { echo "setup-macos.sh: Tcl 9 needs Homebrew (https://brew.sh)" >&2; exit 1; }
  HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1 \
    brew install tcl-tk
  bin="$(brew --prefix tcl-tk)/bin"
  echo "tcl-tk bin directory: $bin"
  ls "$bin"
  [ -x "$bin/tclsh9.0" ] || { echo "setup-macos.sh: Homebrew's tcl-tk has no tclsh9.0 in $bin" >&2; exit 1; }
  export PATH="$bin:$PATH"
  if [ $# -ge 1 ]; then
    echo "$bin" >> "$1"
  fi
fi

if ! command -v rustup >/dev/null 2>&1; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain stable
  export PATH="$HOME/.cargo/bin:$PATH"
  if [ $# -ge 1 ]; then
    echo "$HOME/.cargo/bin" >> "$1"
  fi
fi
rustup toolchain install stable --profile minimal
rustup default stable

tclsh9.0 <<'EOF'
puts "Tcl [info patchlevel] ([info nameofexecutable]), tcltest [package require tcltest 2.5]"
if {[package vcompare [info tclversion] 9.0] < 0 || [package vcompare [info tclversion] 10.0] >= 0} {
    puts stderr "setup-macos.sh: Tcl 9.x is required, found [info patchlevel]"
    exit 1
}
EOF
rustc --version
cargo --version
