/* C-HEADER-ARCHAEOLOGY.md unsupported corpus: boringssl
 * category:    ABI-INFORMATION-REQUIRED
 * shape:       va_list param
 * occurrences: boringssl-static 2, boringssl-shared 2, boringssl-prefix 2
 * examples:    BIO_vsnprintf, OPENSSL_vasprintf
 * first seen:  boringssl-static (revision 427ec40cc8edc545253289232e885708c409e5ea), include/openssl/mem.h:134
 * reason:      va_list is a target-specific builtin type (an array of one struct on x86-64 SysV)
 * expect:      function BIO_vsnprintf
 */
typedef long unsigned int size_t;
typedef __builtin_va_list __gnuc_va_list;
typedef __gnuc_va_list va_list;
int BIO_vsnprintf(char *buf, size_t n, const char *format, va_list args) __attribute__((__format__(__printf__, 3, 0)));
