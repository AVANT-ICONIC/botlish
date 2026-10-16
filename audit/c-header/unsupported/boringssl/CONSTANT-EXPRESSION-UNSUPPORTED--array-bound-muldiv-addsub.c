/* C-HEADER-ARCHAEOLOGY.md unsupported corpus: boringssl
 * category:    CONSTANT-EXPRESSION-UNSUPPORTED
 * shape:       array bound muldiv+addsub
 * occurrences: boringssl-static 12, boringssl-shared 12, boringssl-prefix 12
 * examples:    aes_key_st, anon@mldsa.h:43, anon@mldsa.h:52, anon@mldsa.h:193, anon@mldsa.h:202, anon@mldsa.h:340, anon@mldsa.h:349, anon@mlkem.h:34
 * first seen:  boringssl-static (revision 427ec40cc8edc545253289232e885708c409e5ea), include/openssl/aes.h:38
 * reason:      the array bound {4 * (14 + 1)} is an expression, not a literal
 * expect:      struct aes_key_st
 */
typedef unsigned int __uint32_t;
typedef __uint32_t uint32_t;
struct aes_key_st { uint32_t rd_key[4 * (14 + 1)]; unsigned rounds; };
