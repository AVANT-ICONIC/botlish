/* C-HEADER-ARCHAEOLOGY.md unsupported corpus: boringssl
 * category:    ABI-INFORMATION-REQUIRED
 * shape:       enum param
 * occurrences: boringssl-static 15, boringssl-shared 15, boringssl-prefix 15
 * examples:    EVP_AEAD_CTX_init_with_direction, FIPS_read_counter, SPAKE2_CTX_new, EC_POINT_point2oct, EC_POINT_point2buf, EC_POINT_point2cbb, EC_GROUP_set_point_conversion_form, EC_KEY_set_conv_form
 * first seen:  boringssl-static (revision 427ec40cc8edc545253289232e885708c409e5ea), include/openssl/aead.h:599
 * reason:      an enum's integer type is implementation-defined: its width and signedness need the compiler
 * expect:      function EVP_AEAD_CTX_init_with_direction
 */
typedef long unsigned int size_t;
typedef unsigned char __uint8_t;
typedef __uint8_t uint8_t;
typedef struct evp_aead_st EVP_AEAD;
typedef struct evp_aead_ctx_st EVP_AEAD_CTX;
int EVP_AEAD_CTX_init_with_direction(EVP_AEAD_CTX *ctx, const EVP_AEAD *aead, const uint8_t *key, size_t key_len, size_t tag_len, enum evp_aead_direction_t dir);
