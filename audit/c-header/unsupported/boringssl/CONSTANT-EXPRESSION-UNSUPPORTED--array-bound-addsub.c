/* C-HEADER-ARCHAEOLOGY.md unsupported corpus: boringssl
 * category:    CONSTANT-EXPRESSION-UNSUPPORTED
 * shape:       array bound addsub
 * occurrences: boringssl-static 1, boringssl-shared 1, boringssl-prefix 1
 * examples:    bf_key_st
 * first seen:  boringssl-static (revision 427ec40cc8edc545253289232e885708c409e5ea), include/openssl/blowfish.h:38
 * reason:      the array bound {16 + 2} is an expression, not a literal
 * expect:      struct bf_key_st
 */
typedef unsigned int __uint32_t;
typedef __uint32_t uint32_t;
struct bf_key_st { uint32_t P[16 + 2]; uint32_t S[4 *256]; };
