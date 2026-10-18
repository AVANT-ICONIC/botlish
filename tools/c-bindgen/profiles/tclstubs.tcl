# tclstubs.tcl -- Tcl 9 configured as a stubs-enabled extension sees it
# (C-BINDGEN.md, "Tcl stubs"): the header archaeology's tcl-stubs profile
# (USE_TCL_STUBS). The declarations are identical to the direct-link
# profile's (tcl.tcl), but tclDecls.h redirects every API name to
# `(tclStubsPtr->tcl_X)`, a member of the stub table libtclstub provides:
# no Tcl_X is a symbol an extension may link. The generator binds each
# redirected name as a thunk that calls through the table (the C compiler
# compiles the redirection), never as a direct extern. Generated for
# linux-x86_64 only, as the classification's evidence: the acceptance
# uses the direct-link tcl profile.
set archaeology [apply [list {} [list source [file join $::chdr::repoDir audit c-header profiles tcl.tcl]]]]
dict create \
    name tclstubs \
    description "Tcl 9.0.1's public C API for a stubs-enabled extension (USE_TCL_STUBS): every function through the stub table" \
    headers [dict remove [dict get $archaeology tcl-stubs] description] \
    targets {linux-x86_64} \
    modules {stripPrefix tcl} \
    libraries {
        {headers * targets * names {tclstub9.0}}
    } \
    stubs thunk \
    evidence none
