/* C-HEADER-ARCHAEOLOGY.md unsupported corpus: boringssl
 * category:    ABI-INFORMATION-REQUIRED
 * shape:       array bound sizeof+muldiv+addsub+cast+identifier
 * occurrences: boringssl-static 3, boringssl-shared 3, boringssl-prefix 3
 * examples:    anon@mldsa.h:62, anon@mldsa.h:212, anon@mldsa.h:359
 * first seen:  boringssl-static (revision 427ec40cc8edc545253289232e885708c409e5ea), include/openssl/mldsa.h:62
 * reason:      the array bound {200 + 4 + 4 + 4 *sizeof (size_t)} is an expression, not a literal
 * expect:      struct anon@mldsa.h:62
 */
typedef long unsigned int size_t;
typedef unsigned char __uint8_t;
typedef unsigned long int __uint64_t;
typedef __uint8_t uint8_t;
typedef __uint64_t uint64_t;
union { uint8_t bytes[200 + 4 + 4 + 4 *sizeof (size_t)]; uint64_t alignment; };
