/* C-HEADER-ARCHAEOLOGY.md unsupported corpus: tcl
 * category:    TYPE-SHAPE-UNSUPPORTED
 * shape:       variadic callback param
 * occurrences: tcl-embed 1, tcl-stubs 1, tcl-notommath 1
 * examples:    Tcl_SetPanicProc
 * first seen:  tcl-embed (revision 6230a12b3bf6f7d8128f6ef14b0a3650a9d479e0), generic/tcl.h:2385
 * reason:      a callback the library calls with C varargs
 * expect:      function Tcl_SetPanicProc
 */
typedef void (Tcl_PanicProc) (const char *format, ...);
extern const char *Tcl_SetPanicProc(Tcl_PanicProc *panicProc);
