/* C-HEADER-ARCHAEOLOGY.md unsupported corpus: tcl
 * category:    ABI-INFORMATION-REQUIRED
 * shape:       enum result
 * occurrences: tcl-embed 2, tcl-stubs 2, tcl-notommath 2
 * examples:    Tcl_GetPathType, Tcl_FSGetPathType
 * first seen:  tcl-embed (revision 6230a12b3bf6f7d8128f6ef14b0a3650a9d479e0), generic/tclDecls.h:485
 * reason:      an enum's integer type is implementation-defined: its width and signedness need the compiler
 * expect:      function Tcl_GetPathType
 */
typedef enum Tcl_PathType { TCL_PATH_ABSOLUTE, TCL_PATH_RELATIVE, TCL_PATH_VOLUME_RELATIVE } Tcl_PathType;
extern Tcl_PathType Tcl_GetPathType(const char *path);
