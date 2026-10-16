# Tcl import profiles (C-HEADER-ARCHAEOLOGY.md, "Profiles").
#
# The entry set is what an extension author includes: tcl.h (which includes
# tclDecls.h and tclPlatDecls.h), tclOO.h and tclTomMath.h. Public means
# TCL_PUBLIC_HEADERS of unix/Makefile.in (the installed headers);
# libtommath/tommath.h, which tclTomMath.h includes unless
# TCL_NO_TOMMATH_H is defined, is a bundled third-party header (not
# installed by Tcl). The internal headers (tclInt.h ...) are not reached.

set base [dict create \
    library tcl \
    source {url https://github.com/tcltk/tcl tag core-9-0-1 commit 6230a12b3bf6f7d8128f6ef14b0a3650a9d479e0} \
    includeDirs {generic unix libtommath} \
    defines {} undefines {} flags {} \
    public {generic/tcl.h generic/tclDecls.h generic/tclOO.h generic/tclOODecls.h
        generic/tclPlatDecls.h generic/tclTomMath.h generic/tclTomMathDecls.h} \
    bundled {libtommath/*} \
    internal {*} \
    entry {tcl.h tclOO.h tclTomMath.h}]

dict create \
    tcl-embed [dict merge $base [dict create \
        description "direct linkage (an embedding application or a statically linked extension): no defines"]] \
    tcl-stubs [dict merge $base [dict create \
        description "stubs-enabled extension: USE_TCL_STUBS (the normal extension build, linked with libtclstub)" \
        defines {USE_TCL_STUBS}]] \
    tcl-notommath [dict merge $base [dict create \
        description "installed-header consumer of tclTomMath.h without libtommath: TCL_NO_TOMMATH_H, no libtommath include directory" \
        includeDirs {generic unix} \
        defines {TCL_NO_TOMMATH_H}]]
