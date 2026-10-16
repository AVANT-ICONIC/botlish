/* C-HEADER-ARCHAEOLOGY.md unsupported corpus: boringssl
 * category:    POSSIBLE-THUNK-REQUIRED
 * shape:       inline definition, written directly in the header
 * occurrences: boringssl-static 7, boringssl-shared 7, boringssl-prefix 7
 * examples:    ERR_GET_LIB, ERR_GET_REASON, ERR_equals, ERR_GET_FUNC, CBS_init, CBS_data, CBS_len
 * first seen:  boringssl-static (revision 427ec40cc8edc545253289232e885708c409e5ea), include/openssl/err.h:52
 * reason:      a static inline definition has no link symbol: callable only through a generated C thunk (or reimplemented)
 * expect:      function ERR_GET_LIB
 */
typedef unsigned int __uint32_t;
typedef __uint32_t uint32_t;
static inline __attribute__((unused)) int ERR_GET_LIB(uint32_t packed_error) { ... }
