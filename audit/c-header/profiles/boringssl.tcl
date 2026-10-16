# BoringSSL import profiles (C-HEADER-ARCHAEOLOGY.md, "Profiles").
#
# The entry set is the public C header set of the release:
# gen/sources.json's crypto "hdrs" and ssl "hdrs" (93 + 5 headers), in that
# order, included into one translation unit, as a consumer including
# everything would. pki/ (C++ only) is left out. Everything under
# include/openssl/ is public API; nothing else is reached.

set base [dict create \
    library boringssl \
    source {url https://github.com/google/boringssl tag 0.20260929.0 commit 427ec40cc8edc545253289232e885708c409e5ea} \
    includeDirs {include} \
    defines {} undefines {} flags {} \
    public {include/openssl/*} \
    internal {*} \
    entry {
    openssl/aead.h openssl/aes.h openssl/arm_arch.h openssl/asm_base.h
    openssl/asn1.h openssl/asn1_mac.h openssl/asn1t.h openssl/base.h
    openssl/base64.h openssl/bio.h openssl/blake2.h openssl/blowfish.h
    openssl/bn.h openssl/buf.h openssl/buffer.h openssl/bytestring.h
    openssl/cast.h openssl/chacha.h openssl/cipher.h openssl/cmac.h
    openssl/cms.h openssl/conf.h openssl/configuration.h openssl/cpu.h
    openssl/crypto.h openssl/ctrdrbg.h openssl/curve25519.h openssl/des.h
    openssl/dh.h openssl/digest.h openssl/dsa.h openssl/e_os2.h
    openssl/ec.h openssl/ec_key.h openssl/ecdh.h openssl/ecdsa.h
    openssl/engine.h openssl/err.h openssl/evp.h openssl/evp_errors.h
    openssl/ex_data.h openssl/hkdf.h openssl/hmac.h openssl/hpke.h
    openssl/hrss.h openssl/is_boringssl.h openssl/kdf.h openssl/lhash.h
    openssl/md4.h openssl/md5.h openssl/mem.h openssl/mldsa.h
    openssl/mlkem.h openssl/nid.h openssl/obj.h openssl/obj_mac.h
    openssl/objects.h openssl/opensslconf.h openssl/opensslv.h
    openssl/ossl_typ.h openssl/params.h openssl/pem.h openssl/pkcs12.h
    openssl/pkcs7.h openssl/pkcs8.h openssl/poly1305.h openssl/pool.h
    openssl/posix_time.h openssl/prefix_symbols.h openssl/rand.h
    openssl/rc4.h openssl/ripemd.h openssl/rsa.h openssl/safestack.h
    openssl/service_indicator.h openssl/sha.h openssl/sha2.h
    openssl/siphash.h openssl/slhdsa.h openssl/span.h openssl/stack.h
    openssl/target.h openssl/thread.h openssl/time.h openssl/tls_prf.h
    openssl/trust_token.h openssl/type_check.h openssl/types.h
    openssl/x509.h openssl/x509_vfy.h openssl/x509v3.h
    openssl/x509v3_errors.h openssl/xwing.h openssl/dtls1.h openssl/srtp.h
    openssl/ssl.h openssl/ssl3.h openssl/tls1.h
    }]

dict create \
    boringssl-static [dict merge $base [dict create \
        description "static-library consumer: no defines (the default build)"]] \
    boringssl-shared [dict merge $base [dict create \
        description "shared-library consumer: BORINGSSL_SHARED_LIBRARY" \
        defines {BORINGSSL_SHARED_LIBRARY}]] \
    boringssl-prefix [dict merge $base [dict create \
        description "static consumer of a symbol-prefixed build: BORINGSSL_PREFIX=bssl (a bundled BoringSSL beside a system OpenSSL)" \
        defines {BORINGSSL_PREFIX=bssl}]]
