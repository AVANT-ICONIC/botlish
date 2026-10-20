# MACOS-AARCH64-MILESTONE-6.md

Milestone 6 of the macOS Apple Silicon port: the Apple AArch64 C ABI for
scalar and pointer calls, library linking and foreign symbol resolution on
`macos-aarch64`. Developed on Linux; every macOS fact below was observed on
GitHub's `macos-15` arm64 runners through `.github/workflows/macos-arm64.yml`
(the shared Apple Silicon development machine was not used). The audit it
updates is MACOS-AARCH64-PORT-AUDIT.md (sections 1, 5, 10, 15-17; its roadmap
calls this milestone entry 7); the milestones before it are
MACOS-AARCH64-MILESTONE-1.md to -5.md.

> A foreign call is correct only when the foreign implementation sees the
> exact values, locations, widths and lifetimes its ABI promises.

@@RESULT@@
