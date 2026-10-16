/* C-HEADER-ARCHAEOLOGY.md unsupported corpus: tcl
 * category:    TYPE-SHAPE-UNSUPPORTED
 * shape:       variadic function
 * occurrences: tcl-embed 11, tcl-stubs 11, tcl-notommath 9
 * examples:    Tcl_Panic, Tcl_AppendStringsToObj, Tcl_AppendResult, Tcl_SetErrorCode, Tcl_VarEval, Tcl_ObjPrintf, Tcl_AppendPrintfToObj, mp_init_multi
 * first seen:  tcl-embed (revision 6230a12b3bf6f7d8128f6ef14b0a3650a9d479e0), generic/tclDecls.h:62
 * reason:      C varargs: the caller must know the promoted types of the extra arguments
 * expect:      function Tcl_Panic
 */
extern __attribute__((noreturn)) void Tcl_Panic(const char *format, ...) __attribute__((__format__(__printf__, 1, 2)));
