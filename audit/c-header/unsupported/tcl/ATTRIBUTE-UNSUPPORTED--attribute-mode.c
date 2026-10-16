/* C-HEADER-ARCHAEOLOGY.md unsupported corpus: tcl
 * category:    ATTRIBUTE-UNSUPPORTED
 * shape:       attribute mode
 * occurrences: tcl-embed 1, tcl-stubs 1
 * examples:    private_mp_word
 * first seen:  tcl-embed (revision 6230a12b3bf6f7d8128f6ef14b0a3650a9d479e0), libtommath/tommath.h:80
 * reason:      __attribute__((mode)) changes the type or the layout
 * expect:      typedef private_mp_word
 */
typedef unsigned long private_mp_word __attribute__((mode(TI)));
