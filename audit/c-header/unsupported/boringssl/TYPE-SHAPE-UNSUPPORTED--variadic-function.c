/* C-HEADER-ARCHAEOLOGY.md unsupported corpus: boringssl
 * category:    TYPE-SHAPE-UNSUPPORTED
 * shape:       variadic function
 * occurrences: boringssl-static 5, boringssl-shared 5, boringssl-prefix 5
 * examples:    ERR_add_error_data, ERR_add_error_dataf, BIO_printf, BIO_snprintf, OPENSSL_asprintf
 * first seen:  boringssl-static (revision 427ec40cc8edc545253289232e885708c409e5ea), include/openssl/err.h:379
 * reason:      C varargs: the caller must know the promoted types of the extra arguments
 * expect:      function ERR_add_error_data
 */
void ERR_add_error_data(unsigned count, ...);
