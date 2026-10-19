/* nedit-fixture.c -- the C side of the native layout write tests
 * (NATIVE-LAYOUT-WRITES.md, "The synthetic native oracle").
 *
 * Test infrastructure only: tests/native-edit.test compiles it with the
 * host C compiler into a static archive (libbotlish_nedit_fixture.a) in a
 * private directory and links Botlish programs against it. Nothing in the
 * compiler, the runtime or the libraries depends on it.
 *
 * It is the independent oracle of a write: the record below is an ordinary C
 * struct whose layout C itself decides -- the static assertions state, and
 * the C compiler checks, every offset, the size and the alignment the test's
 * Botlish `layout` declaration states explicitly. Botlish writes into it
 * (through a native edit of the address C hands out) or builds one in byte
 * storage (binary::write and binary::write_foreign into a MutableBytes, then
 * exposed for one noescape call), and C reads every field back with its own
 * typed loads, compares the pointer fields with the pointers it handed out,
 * and checks every padding byte. The expected values are written out below,
 * in C, independently of the Botlish test.
 */
#include <limits.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

struct bne_point {
    int16_t x;
    uint16_t y;
};

struct bne_record {
    uint8_t u8;                  /* 0 */
    int8_t i8;                   /* 1 */
    uint16_t u16;                /* 2 */
    int32_t i32;                 /* 4 */
    uint64_t u64;                /* 8 */
    int64_t i64;                 /* 16 */
    int16_t i16;                 /* 24, then 2 bytes of padding */
    uint32_t u32;                /* 28 */
    struct bne_point origin;     /* 32 */
    long lng;                    /* 40 (after 4 bytes of padding) */
    const void *data_ptr;        /* 48 */
    int (*callback)(int);        /* 56 */
    unsigned char tail;          /* 64, then 7 bytes of tail padding */
};

_Static_assert(sizeof(struct bne_point) == 4, "bne_point size");
_Static_assert(offsetof(struct bne_point, y) == 2, "bne_point.y");
_Static_assert(offsetof(struct bne_record, i8) == 1, "i8");
_Static_assert(offsetof(struct bne_record, u16) == 2, "u16");
_Static_assert(offsetof(struct bne_record, i32) == 4, "i32");
_Static_assert(offsetof(struct bne_record, u64) == 8, "u64");
_Static_assert(offsetof(struct bne_record, i64) == 16, "i64");
_Static_assert(offsetof(struct bne_record, i16) == 24, "i16");
_Static_assert(offsetof(struct bne_record, u32) == 28, "u32");
_Static_assert(offsetof(struct bne_record, origin) == 32, "origin");
_Static_assert(offsetof(struct bne_record, lng) == 40, "lng");
_Static_assert(offsetof(struct bne_record, data_ptr) == 48, "data_ptr");
_Static_assert(offsetof(struct bne_record, callback) == 56, "callback");
_Static_assert(offsetof(struct bne_record, tail) == 64, "tail");
_Static_assert(sizeof(struct bne_record) == 72, "bne_record size");
_Static_assert(_Alignof(struct bne_record) == 8, "bne_record alignment");
_Static_assert(sizeof(long) == 8 && sizeof(void *) == 8, "an LP64 target");

/* The padding bytes of struct bne_record: 26, 27, 36..39, 65..71. */
static const unsigned bne_padding[] = {26, 27, 36, 37, 38, 39, 65, 66, 67, 68, 69, 70, 71};

/* The byte a record's untouched memory holds: sentinel memory, so that a
 * write that strays into padding or a neighbouring field shows. */
#define BNE_SENTINEL 0xA5

/* The callback a record's function pointer field is given. */
int bne_callback(int x) { return x * 2; }

/* The data a record's data pointer field is given. */
static const int bne_target_object = 4242;

const void *bne_target(void) { return &bne_target_object; }

int (*bne_callback_ptr(void))(int) { return bne_callback; }

/* A null function pointer: Botlish has no operation making one (C-ABI-TYPES.md). */
int (*bne_no_callback(void))(int) { return NULL; }

/* Live native memory a native edit writes into: one record, every byte set
 * to the sentinel by bne_reset. */
static struct bne_record bne_live;

struct bne_record *bne_reset(void) {
    memset(&bne_live, BNE_SENTINEL, sizeof bne_live);
    return &bne_live;
}

/* Copies the live record's bytes to OUT (N at most): its representation. */
void bne_copy_live(unsigned char *out, unsigned long n) {
    if (n > sizeof bne_live) {
        n = sizeof bne_live;
    }
    memcpy(out, &bne_live, n);
}

/* The bit of each field in a check's mismatch mask. */
enum {
    BNE_U8 = 1 << 0, BNE_I8 = 1 << 1, BNE_U16 = 1 << 2, BNE_I32 = 1 << 3,
    BNE_U64 = 1 << 4, BNE_I64 = 1 << 5, BNE_I16 = 1 << 6, BNE_U32 = 1 << 7,
    BNE_X = 1 << 8, BNE_Y = 1 << 9, BNE_LNG = 1 << 10, BNE_DATA = 1 << 11,
    BNE_CALLBACK = 1 << 12, BNE_TAIL = 1 << 13, BNE_PADDING = 1 << 14,
};

/* The mask of the fields of R that differ from case WHICH's values, and of
 * padding bytes other than PAD:
 *
 *   case 0  every width's minimum (or all-ones pattern), a C long's maximum,
 *           the target object, the callback, tail 0x5A
 *   case 1  the other extreme and zero, LONG_MIN, two null pointers, tail 0
 *   case 2  only i32 (-2) and origin.y (513) written: every other field
 *           still holds the sentinel, so a write that strays shows
 */
static int bne_mismatches(const struct bne_record *r, int which, unsigned char pad) {
    const unsigned char *bytes = (const unsigned char *)r;
    int mask = 0;
    for (size_t i = 0; i < sizeof bne_padding / sizeof bne_padding[0]; i++) {
        if (bytes[bne_padding[i]] != pad) {
            mask |= BNE_PADDING;
        }
    }
    if (which == 2) {
        struct bne_record s;
        memset(&s, BNE_SENTINEL, sizeof s);
        s.i32 = -2;
        s.origin.y = 513;
        if (memcmp(bytes, &s, offsetof(struct bne_record, i32)) != 0) {
            mask |= BNE_U8 | BNE_I8 | BNE_U16;
        }
        if (r->i32 != -2) {
            mask |= BNE_I32;
        }
        if (memcmp(bytes + 8, (const unsigned char *)&s + 8, 24) != 0) {
            mask |= BNE_U64 | BNE_I64 | BNE_I16 | BNE_U32;
        }
        if (r->origin.x != s.origin.x) {
            mask |= BNE_X;
        }
        if (r->origin.y != 513) {
            mask |= BNE_Y;
        }
        if (memcmp(bytes + 40, (const unsigned char *)&s + 40, 25) != 0) {
            mask |= BNE_LNG | BNE_DATA | BNE_CALLBACK | BNE_TAIL;
        }
        return mask;
    }
    int big = which == 0;
    if (r->u8 != (big ? UINT8_MAX : 0)) mask |= BNE_U8;
    if (r->i8 != (big ? INT8_MIN : INT8_MAX)) mask |= BNE_I8;
    if (r->u16 != (big ? UINT16_MAX : 0)) mask |= BNE_U16;
    if (r->i32 != (big ? INT32_MIN : INT32_MAX)) mask |= BNE_I32;
    if (r->u64 != (big ? UINT64_MAX : 0)) mask |= BNE_U64;
    if (r->i64 != (big ? INT64_MIN : INT64_MAX)) mask |= BNE_I64;
    if (r->i16 != (big ? -1 : 0)) mask |= BNE_I16;
    if (r->u32 != (big ? 0x80000001u : UINT32_MAX)) mask |= BNE_U32;
    if (r->origin.x != (big ? INT16_MIN : INT16_MAX)) mask |= BNE_X;
    if (r->origin.y != (big ? UINT16_MAX : 0)) mask |= BNE_Y;
    if (r->lng != (big ? LONG_MAX : LONG_MIN)) mask |= BNE_LNG;
    if (r->data_ptr != (big ? (const void *)&bne_target_object : NULL)) mask |= BNE_DATA;
    if (r->callback != (big ? bne_callback : NULL)) mask |= BNE_CALLBACK;
    if (r->tail != (big ? 0x5A : 0)) mask |= BNE_TAIL;
    return mask;
}

/* The mismatch mask of the live record against case WHICH, its padding the
 * sentinel it was reset to (a native edit writes nothing else). */
int bne_check_live(int which) {
    return bne_mismatches(&bne_live, which, BNE_SENTINEL);
}

/* The mismatch mask of the N bytes at BYTES -- a record Botlish built in
 * byte storage and exposed for this call -- against case WHICH, its padding
 * zero (it was built from zeroed storage); -1 if N is not the record's size.
 * The bytes are copied first: byte storage promises no alignment. */
int bne_check_built(const unsigned char *bytes, unsigned long n, int which) {
    if (n != sizeof(struct bne_record)) {
        return -1;
    }
    struct bne_record r;
    memcpy(&r, bytes, sizeof r);
    return bne_mismatches(&r, which, 0);
}

/* 1 if P is exactly the target object bne_target returns. */
int bne_is_target(const void *p) { return p == (const void *)&bne_target_object; }

/* 1 if F is exactly bne_callback. */
int bne_is_callback(int (*f)(int)) { return f == bne_callback; }
