# tcl.tcl -- the Tcl 9 binding profile (C-BINDGEN.md, "Tcl").
#
# The headers are the header archaeology's tcl-embed profile, reused as it
# is (audit/c-header/profiles/tcl.tcl: tag core-9-0-1, its commit pinned,
# tcl.h + tclOO.h + tclTomMath.h, no defines): the direct-link, non-stubs
# API configuration an embedding application uses. Without USE_TCL_STUBS,
# tclDecls.h defines no `#define Tcl_X (tclStubsPtr->tcl_X)` redirections,
# so every declared function is the exported symbol of libtcl9.0; the
# generator still classifies every macro, and a stub-table redirection
# would become a thunk, never a direct symbol (C-BINDGEN.md, "Tcl stubs").
#
# Manual policy: the three acceptance functions' contracts (the hand-written
# examples/ffi/tcl/tcl.bot's, which the generated binding must match) and
# Tcl_Eval's (the macro is Tcl_EvalEx, so Tcl_EvalEx's documented contract),
# the signatures of three macro APIs the binding thunks (a macro has none).
set archaeology [apply [list {} [list source [file join $::chdr::repoDir audit c-header profiles tcl.tcl]]]]
dict create \
    name tcl \
    description "Tcl 9.0.1's public C API (tcl.h, tclOO.h, tclTomMath.h), linked directly (no stubs)" \
    headers [dict remove [dict get $archaeology tcl-embed] description] \
    targets {linux-x86_64 linux-aarch64 macos-aarch64} \
    modules {stripPrefix tcl} \
    libraries {
        {headers * targets * names {tcl9.0}}
    } \
    contracts {
        Tcl_CreateInterp {result independent}
        Tcl_EvalEx {interp noescape script {read noescape}}
        Tcl_DeleteInterp {interp noescape}
        Tcl_Eval {interp noescape script {read noescape}}
    } \
    thunks {
        Tcl_Eval {int Tcl_Eval(Tcl_Interp *interp, const char *script)}
        Tcl_DStringLength {Tcl_Size Tcl_DStringLength(Tcl_DString *dsPtr)}
        Tcl_GetHashValue {void *Tcl_GetHashValue(Tcl_HashEntry *h)}
    } \
    evidence llvm
