# thunks.tcl -- can a generated C wrapper stand in for a macro API?
# (C-HEADER-ARCHAEOLOGY.md, "Thunk feasibility").
#
#   tclsh9.0 audit/c-header/tools/thunks.tcl ?-compilers {gcc clang}?
#
# A throwaway prototype, not the thunk system: for a hand-picked sample of
# real BoringSSL and Tcl macros (every census category that claims "yes",
# "per signature" or "per identifier argument", and the ones that claim
# "no"), a wrapper written the way a generator would write it --
#
#   RESULT botlish_thunk_NAME(PARAMS) { return MACRO(ARGS); }
#
# with the signature supplied by hand, because a macro has none -- is
# compiled after the profile's headers with -Wall -Wextra by every listed
# compiler. Each sample states what the census predicts; the report is
# results/thunks.txt (one line per sample and compiler: ok, rejected, or ok
# with warnings, and the first diagnostic).

set here [file dirname [file normalize [info script]]]
source [file join $here common.tcl]
source [file join $here toolchain.tcl]

# {PROFILE MACRO CATEGORY EXPECT CODE}: EXPECT is ok, rejected, or wrong
# (compiles, but does not mean what the macro means).
set samples {
    {tcl-embed Tcl_IncrRefCount "expression with side effects" ok
        {void botlish_thunk(Tcl_Obj *objPtr) { Tcl_IncrRefCount(objPtr); }}}
    {tcl-embed Tcl_DecrRefCount "statement (do-while with a local declaration)" ok
        {void botlish_thunk(Tcl_Obj *objPtr) { Tcl_DecrRefCount(objPtr); }}}
    {tcl-embed Tcl_IsShared "member access" ok
        {int botlish_thunk(Tcl_Obj *objPtr) { return Tcl_IsShared(objPtr); }}}
    {tcl-embed Tcl_GetHashValue "member access (an lvalue: the read)" ok
        {void *botlish_thunk(Tcl_HashEntry *h) { return Tcl_GetHashValue(h); }}}
    {tcl-embed Tcl_SetHashValue "assignment through a member" ok
        {void botlish_thunk(Tcl_HashEntry *h, void *v) { Tcl_SetHashValue(h, v); }}}
    {tcl-embed Tcl_FindHashEntry "call through a function pointer in a struct, argument evaluated twice" ok
        {Tcl_HashEntry *botlish_thunk(Tcl_HashTable *t, const void *key) { return Tcl_FindHashEntry(t, key); }}}
    {tcl-embed Tcl_DStringValue "member access" ok
        {char *botlish_thunk(Tcl_DString *d) { return Tcl_DStringValue(d); }}}
    {tcl-embed Tcl_Main "call wrapper, computed arguments" ok
        {void botlish_thunk(Tcl_Size argc, char **argv, Tcl_AppInitProc *p) { Tcl_Main(argc, argv, p); }}}
    {tcl-embed Tcl_GetBooleanFromObj "type-generic (sizeof dispatch), signature int *" ok
        {int botlish_thunk(Tcl_Interp *i, Tcl_Obj *o, int *b) { return Tcl_GetBooleanFromObj(i, o, b); }}}
    {tcl-embed Tcl_GetBooleanFromObj "type-generic (sizeof dispatch), signature char * (another callee)" ok
        {int botlish_thunk(Tcl_Interp *i, Tcl_Obj *o, char *b) { return Tcl_GetBooleanFromObj(i, o, b); }}}
    {tcl-embed Tcl_GetBooleanFromObj "type-generic (sizeof dispatch), signature long long * (refused by its static assertion)" rejected
        {int botlish_thunk(Tcl_Interp *i, Tcl_Obj *o, long long *b) { return Tcl_GetBooleanFromObj(i, o, b); }}}
    {tcl-embed Tcl_GetIndexFromObjStruct "type-generic (sizeof of the result pointer's target)" ok
        {int botlish_thunk(Tcl_Interp *i, Tcl_Obj *o, const void *t, Tcl_Size off, const char *msg, int flags, int *idx) { return Tcl_GetIndexFromObjStruct(i, o, t, off, msg, flags, idx); }}}
    {tcl-embed mp_iszero "member access (bundled libtommath)" ok
        {int botlish_thunk(const mp_int *a) { return mp_iszero(a); }}}
    {tcl-embed TCL_DECLARE_MUTEX "declaration-generating: as a wrapper body it declares, it does not act" ok
        {void botlish_thunk(void) { TCL_DECLARE_MUTEX(m) (void)m; }}}
    {tcl-stubs Tcl_CreateObjCommand "stubs: an object-like macro naming a stub-table member" ok
        {Tcl_Command botlish_thunk(Tcl_Interp *i, const char *n, Tcl_ObjCmdProc *p, void *cd, Tcl_CmdDeleteProc *d) { return Tcl_CreateObjCommand(i, n, p, cd, d); }}}
    {tcl-stubs Tcl_InitStubs "stubs: call wrapper with the version and magic baked in" ok
        {const char *botlish_thunk(Tcl_Interp *i, const char *v, int exact) { return Tcl_InitStubs(i, v, exact); }}}
    {boringssl-static OPENSSL_PUT_ERROR "pasted argument, given a value parameter" rejected
        {void botlish_thunk(int library, int reason) { OPENSSL_PUT_ERROR(library, reason); }}}
    {boringssl-static OPENSSL_PUT_ERROR "pasted argument, one wrapper per library name (__FILE__/__LINE__ become the wrapper's)" ok
        {void botlish_thunk(int reason) { OPENSSL_PUT_ERROR(SSL, reason); }}}
    {boringssl-static ASN1_ITEM_ref "pasted argument, one wrapper per item name" ok
        {const ASN1_ITEM *botlish_thunk(void) { return ASN1_ITEM_ref(ASN1_INTEGER); }}}
    {boringssl-static BIO_get_app_data "call wrapper, computed arguments" ok
        {void *botlish_thunk(BIO *b) { return BIO_get_app_data(b); }}}
    {boringssl-static BN_mod "call wrapper, computed arguments (NULL supplied)" ok
        {int botlish_thunk(BIGNUM *rem, const BIGNUM *a, const BIGNUM *m, BN_CTX *ctx) { return BN_mod(rem, a, m, ctx); }}}
    {boringssl-static ERR_PACK "expression over its arguments" ok
        {uint32_t botlish_thunk(int lib, int reason) { return ERR_PACK(lib, reason); }}}
    {boringssl-static BSSL_CHECK "statement" ok
        {void botlish_thunk(int condition) { BSSL_CHECK(condition); }}}
    {boringssl-static CHECKED_CAST "type-generic (a type argument): one wrapper per type pair" ok
        {X509 *botlish_thunk(void *p) { return CHECKED_CAST(X509 *, void *, p); }}}
    {boringssl-static sk_X509_num "a static inline function DEFINE_STACK_OF generated (STACK_OF in the signature)" ok
        {size_t botlish_thunk(const STACK_OF(X509) *sk) { return sk_X509_num(sk); }}}
    {boringssl-static sk_X509_pop_free "a static inline function taking a callback" ok
        {void botlish_thunk(STACK_OF(X509) *sk, sk_X509_free_func f) { sk_X509_pop_free(sk, f); }}}
    {boringssl-static ERR_GET_LIB "a static inline function written in the header" ok
        {int botlish_thunk(uint32_t e) { return ERR_GET_LIB(e); }}}
    {boringssl-static DEFINE_STACK_OF "declaration-generating: as a wrapper body" rejected
        {void botlish_thunk(void) { DEFINE_STACK_OF(X509_NAME_ENTRY) }}}
    {boringssl-static ASN1_SIMPLE "initializer fragment: as an expression" rejected
        {int botlish_thunk(void) { return (int)sizeof(ASN1_SIMPLE(X509_ALGOR, algorithm, ASN1_OBJECT)); }}}
    {boringssl-static OBJ_rsadsi "comma list (OID arcs): as an expression it compiles to the comma operator, the last arc" wrong
        {long botlish_thunk(void) { return OBJ_rsadsi; }}}
}

proc main {argv} {
    set options [dict create -compilers {gcc clang}]
    foreach {k v} $argv { dict set options $k $v }
    set lines {}
    set summary [dict create]
    foreach compiler [dict get $options -compilers] {
        set ::env(BOTLISH_C_CC) $compiler
        set config [::chdr::toolchain::config]
        lappend lines "# compiler $compiler: [dict get $config version]"
        foreach s $::samples {
            lassign $s profileName macro category expect code
            set profile [::chdr::profile $profileName]
            set root [file dirname [file normalize [file join [::chdr::sourcesDir] [dict get $profile library] .x]]]
            set abs {}
            foreach d [dict get $profile includeDirs] { lappend abs [file join $root $d] }
            set p [dict replace $profile includeDirs $abs flags [concat [dict get $profile flags] -Wall -Wextra]]
            set src ""
            foreach h [dict get $profile entry] { append src "#include <$h>\n" }
            append src "$code\n"
            lassign [::chdr::toolchain::compile $config $p $src] ok stderr
            set diag ""
            foreach want {error warning} {
                foreach l [split $stderr \n] {
                    if {$diag eq "" && [regexp {^[^:]+:[0-9]+:[0-9]+: (error|warning): (.*)$} $l -> kind msg] && $kind eq $want} {
                        set diag "$kind: $msg"
                    }
                }
            }
            set outcome [expr {$ok ? ($diag eq "" ? "ok" : "ok-with-warnings") : "rejected"}]
            set agrees [expr {($outcome eq "rejected") == ($expect eq "rejected")}]
            dict incr summary "$compiler [expr {$agrees ? {as predicted} : {NOT as predicted}}]"
            lappend lines [join [list $compiler $profileName $macro $outcome "predicted $expect" $category $code $diag] \t]
        }
    }
    foreach {k v} $summary { lappend lines "# $k: $v" }
    set out [file join $::chdr::root results thunks.txt]
    ::chdr::writeFile $out [join $lines \n]\n
    foreach {k v} $summary { puts "$k: $v" }
}

main $argv
