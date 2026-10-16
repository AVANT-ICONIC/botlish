/* C-HEADER-ARCHAEOLOGY.md unsupported corpus: boringssl
 * category:    ABI-INFORMATION-REQUIRED
 * shape:       bitfield
 * occurrences: boringssl-static 3, boringssl-shared 3, boringssl-prefix 3
 * examples:    cbb_buffer_st, cbb_child_st
 * first seen:  boringssl-static (revision 427ec40cc8edc545253289232e885708c409e5ea), include/openssl/bytestring.h:478
 * reason:      bit allocation within storage units is the ABI's
 * expect:      struct cbb_buffer_st
 */
typedef long unsigned int size_t;
typedef unsigned char __uint8_t;
typedef __uint8_t uint8_t;
struct cbb_buffer_st { uint8_t *buf; size_t len; size_t cap; unsigned can_resize : 1; unsigned error : 1; };
