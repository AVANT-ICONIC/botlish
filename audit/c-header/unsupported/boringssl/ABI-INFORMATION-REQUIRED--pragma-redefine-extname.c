/* C-HEADER-ARCHAEOLOGY.md unsupported corpus: boringssl
 * category:    ABI-INFORMATION-REQUIRED
 * shape:       pragma redefine_extname
 * occurrences: boringssl-prefix 3149
 * examples:    
 * first seen:  boringssl-prefix (revision 427ec40cc8edc545253289232e885708c409e5ea), include/openssl/prefix_symbols.h:40
 * reason:      #pragma redefine_extname survives preprocessing and changes layout or link names
 * expect:      pragma -
 */
#pragma redefine_extname ACCESS_DESCRIPTION_free bssl_ACCESS_DESCRIPTION_free
