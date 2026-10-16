/* C-HEADER-ARCHAEOLOGY.md unsupported corpus: boringssl
 * category:    ABI-INFORMATION-REQUIRED
 * shape:       enum result
 * occurrences: boringssl-static 6, boringssl-shared 6, boringssl-prefix 6
 * examples:    EC_KEY_get_conv_form, SSL_quic_read_level, SSL_quic_write_level, SSL_get_early_data_reason, SSL_CTX_get_compliance_policy, SSL_get_compliance_policy
 * first seen:  boringssl-static (revision 427ec40cc8edc545253289232e885708c409e5ea), include/openssl/ec_key.h:106
 * reason:      an enum's integer type is implementation-defined: its width and signedness need the compiler
 * expect:      function EC_KEY_get_conv_form
 */
typedef struct ec_key_st EC_KEY;
typedef enum { POINT_CONVERSION_COMPRESSED = 2, POINT_CONVERSION_UNCOMPRESSED = 4, POINT_CONVERSION_HYBRID = 6, } point_conversion_form_t;
point_conversion_form_t EC_KEY_get_conv_form(const EC_KEY *key);
