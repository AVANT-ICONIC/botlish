/* C-HEADER-ARCHAEOLOGY.md unsupported corpus: boringssl
 * category:    ABI-INFORMATION-REQUIRED
 * shape:       union embedded by value
 * occurrences: boringssl-static 21, boringssl-shared 21, boringssl-prefix 21
 * examples:    evp_aead_ctx_st, asn1_type_st, cbb_st, MLDSA65_private_key, MLDSA65_public_key, MLDSA65_prehash, MLDSA87_private_key, MLDSA87_public_key
 * first seen:  boringssl-static (revision 427ec40cc8edc545253289232e885708c409e5ea), include/openssl/aead.h:229
 * reason:      a union field: overlapping storage the current layout cannot describe
 * expect:      struct evp_aead_ctx_st
 */
typedef unsigned char __uint8_t;
typedef __uint8_t uint8_t;
typedef struct evp_aead_st EVP_AEAD;
struct evp_aead_ctx_st { const EVP_AEAD *aead; union evp_aead_ctx_st_state state; uint8_t tag_len; };
