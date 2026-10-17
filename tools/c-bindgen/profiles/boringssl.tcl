# boringssl.tcl -- the BoringSSL binding profile (C-BINDGEN.md, "BoringSSL").
#
# The headers are the header archaeology's BoringSSL profile (audit/c-header/
# profiles/boringssl.tcl: tag 0.20260929.0, its commit pinned, the 98 public
# crypto and ssl headers in one translation unit), configured for the
# package-owned build the C FFI's acceptance links (tests/cffi/boringssl.tcl:
# BORINGSSL_PREFIX=botlish_bssl, a static libcrypto.a): the link symbols are
# whatever the compiler makes of the headers' `#pragma redefine_extname`
# under that prefix, read by the symbol probe for every function alike --
# nothing here names SHA256 or any other symbol.
#
# Libraries: the ssl headers' modules link libssl and libcrypto, every other
# module libcrypto; the static archives need the C++ runtime (libstdc++ on
# Linux, libc++ on macOS), a target fact of this build, declared per target.
#
# Manual policy: SHA256's contract (sha2.h documents it: DATA is read, OUT
# written with the digest and returned), the one the acceptance needs.
set archaeology [apply [list {} [list source [file join $::chdr::repoDir audit c-header profiles boringssl.tcl]]]]
namespace eval ::cffi {}
if {![info exists ::cffi::prefix]} {
    source [file join $::chdr::repoDir tests cffi boringssl.tcl]
}
set headers [dict remove [dict get $archaeology boringssl-static] description]
dict set headers defines [list BORINGSSL_PREFIX=$::cffi::prefix]
set ssl {include/openssl/ssl.h include/openssl/ssl3.h include/openssl/tls1.h include/openssl/dtls1.h include/openssl/srtp.h}
dict create \
    name boringssl \
    description "BoringSSL 0.20260929.0's public C API, for the symbol-prefixed static build (BORINGSSL_PREFIX=$::cffi::prefix)" \
    headers $headers \
    targets {linux-x86_64 linux-aarch64 macos-aarch64} \
    modules {stripPrefix ""} \
    libraries [list \
        [dict create headers $ssl targets * names {ssl}] \
        {headers * targets * names {crypto}} \
        {headers * targets linux-* names {stdc++}} \
        {headers * targets macos-* names {c++}}] \
    contracts {
        SHA256 {data {read noescape} out {write noescape} result {alias out}}
    } \
    evidence llvm
