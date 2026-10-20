/* nunion-fixture.c -- the C side of the union layout tests (LAYOUT-UNIONS.md,
 * "Tests and oracles").
 *
 * Test infrastructure only: tests/layout-unions.test compiles it with the
 * host C compiler into a static archive (libbotlish_nunion_fixture.a) in a
 * private directory and links Botlish programs against it. Nothing in the
 * compiler, the runtime or the libraries depends on it.
 *
 * It is the independent oracle of unions: the record below is an ordinary C
 * struct holding a named union of every kind of alternative the layout
 * language represents (scalars of every width, a union of a record and an
 * array inside it, a byte array, a word array), the OVERLAPPED shape -- an
 * anonymous union of an anonymous struct and a pointer -- and an array of
 * unions, whose layout C itself decides; the static assertions state, and
 * the C compiler checks, every offset, every union's size and alignment and
 * every alternative's offset (0) and size, as the test's Botlish
 * declarations state them explicitly.
 *
 * The expected bytes are never C's reading of an inactive member: every
 * expectation is built here by copying typed values into a byte image at
 * their offsets (memcpy, little-endian as the target is), so the oracle
 * checks Botlish's interpretation of the bytes against C's representation of
 * the values, not against C's union-punning rules. C fills the record with
 * typed member stores and every other byte with 0xA5; Botlish reads it
 * through a native view; Botlish writes it through a native edit and C
 * checks every byte against its own image and the written members with its
 * own typed reads; Botlish builds the record in byte storage and C checks
 * that image.
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

union bnu_word {
    uint32_t whole;
    struct {
        uint16_t low;
        int16_t high;
    } halves;
    uint8_t bytes[4];
};

union bnu_wide {
    uint8_t b;
    int16_t h;
    uint32_t w;
    uint64_t q;
    union bnu_word word;
    uint8_t bytes[16];
    uint32_t words[4];
};

struct bnu_target {
    int tag;
};

struct bnu_record {
    uint8_t tag;                      /* 0, then 7 bytes of padding */
    union bnu_wide w;                 /* 8 .. 23 */
    union {                           /* 24 .. 31: the OVERLAPPED shape */
        struct {
            uint32_t offset;
            uint32_t offset_high;
        };
        const struct bnu_target *pointer;
    };
    union bnu_word ws[3];             /* 32 .. 43 */
    uint16_t after;                   /* 44, then 2 bytes of tail padding */
};

_Static_assert(sizeof(union bnu_word) == 4, "bnu_word size");
_Static_assert(_Alignof(union bnu_word) == 4, "bnu_word alignment");
_Static_assert(offsetof(union bnu_word, whole) == 0, "whole");
_Static_assert(offsetof(union bnu_word, halves) == 0, "halves");
_Static_assert(offsetof(union bnu_word, bytes) == 0, "bytes");
_Static_assert(sizeof(union bnu_wide) == 16, "bnu_wide size");
_Static_assert(_Alignof(union bnu_wide) == 8, "bnu_wide alignment");
_Static_assert(offsetof(union bnu_wide, q) == 0 && offsetof(union bnu_wide, words) == 0, "wide alternatives at 0");
_Static_assert(sizeof(((union bnu_wide *)0)->words) == 16, "words size");
_Static_assert(offsetof(struct bnu_record, w) == 8, "w");
_Static_assert(offsetof(struct bnu_record, offset) == 24, "offset");
_Static_assert(offsetof(struct bnu_record, offset_high) == 28, "offset_high");
_Static_assert(offsetof(struct bnu_record, pointer) == 24, "pointer");
_Static_assert(offsetof(struct bnu_record, ws) == 32, "ws");
_Static_assert(sizeof(((struct bnu_record *)0)->ws) == 12, "ws size");
_Static_assert(offsetof(struct bnu_record, after) == 44, "after");
_Static_assert(sizeof(struct bnu_record) == 48, "bnu_record size");
_Static_assert(_Alignof(struct bnu_record) == 8, "bnu_record alignment");

static struct bnu_record live;
static struct bnu_target the_target = {7};

const struct bnu_target *bnu_target(void) { return &the_target; }

int bnu_is_target(const struct bnu_target *p) { return p == &the_target; }

/* The image IMAGE with the WIDTH bytes of the typed value at VALUE copied in
 * at byte AT: the oracle's own model of where C puts a member's bytes. */
static void put(unsigned char *image, size_t at, const void *value, size_t width) {
    memcpy(image + at, value, width);
}

/* Case 0, C's own values, each written with a typed member store: w through
 * its 8-byte alternative, the offsets of the anonymous union, each element
 * of ws through a different alternative. */
static void fill_case0(struct bnu_record *r) {
    r->tag = 0x5A;
    r->w.q = UINT64_C(0xF0E1D2C3B4A59687);
    r->offset = 0x81020304u;
    r->offset_high = 0x00000001u;     /* an address the pointer alternative can hold */
    r->ws[0].whole = 0xDEADBEEFu;
    r->ws[1].halves.low = 0x1234;
    r->ws[1].halves.high = -2;
    r->ws[2].bytes[0] = 1;
    r->ws[2].bytes[1] = 2;
    r->ws[2].bytes[2] = 3;
    r->ws[2].bytes[3] = 255;
    r->after = 0xBEEF;
}

/* The record, every byte 0xA5 and then case 0's members: its address. */
struct bnu_record *bnu_reset(void) {
    memset(&live, 0xA5, sizeof live);
    fill_case0(&live);
    return &live;
}

/* The record, every byte 0xA5 (nothing filled): its address. */
struct bnu_record *bnu_blank(void) {
    memset(&live, 0xA5, sizeof live);
    return &live;
}

void bnu_copy_live(unsigned char *out, unsigned long n) {
    memcpy(out, &live, n < sizeof live ? n : sizeof live);
}

/* The image of case WHICH, built with put() over FILL bytes:
 *
 *   case 1 -- what the test stores through a native edit, each into its
 *             own alternative, each narrower than the union around it: tag
 *             = 9, w.h = -2 (2 of w's 16 bytes), offset_high = 7 (the
 *             second half of the anonymous struct), ws[1].halves.high = -1,
 *             ws[2].bytes[3] = 0x80; every other byte 0xA5;
 *   case 2 -- the pointer alternative: pointer = the target, and w.words[3]
 *             = 0xFFFFFFFF (the last 4 of w's 16 bytes); every other byte
 *             0xA5;
 *   case 3 -- built in byte storage: tag = 1, w.word.halves.low = 0xABCD,
 *             offset = 4096, offset_high = 1, ws[0].bytes[3] = 0x7F,
 *             ws[2].whole = 0x01020304, after = 0x0102; every other byte 0.
 */
static void image_of(unsigned char *image, int which) {
    memset(image, which == 3 ? 0 : 0xA5, sizeof(struct bnu_record));
    if (which == 1) {
        uint8_t tag = 9;
        int16_t h = -2;
        uint32_t high = 7;
        int16_t hh = -1;
        uint8_t byte = 0x80;
        put(image, 0, &tag, 1);
        put(image, 8, &h, 2);
        put(image, 28, &high, 4);
        put(image, 36 + 2, &hh, 2);
        put(image, 40 + 3, &byte, 1);
    } else if (which == 2) {
        const struct bnu_target *p = &the_target;
        uint32_t last = 0xFFFFFFFFu;
        put(image, 24, &p, sizeof p);
        put(image, 8 + 12, &last, 4);
    } else if (which == 3) {
        uint8_t tag = 1;
        uint16_t low = 0xABCD;
        uint32_t offset = 4096, high = 1;
        uint8_t byte = 0x7F;
        uint32_t whole = 0x01020304u;
        uint16_t after = 0x0102;
        put(image, 0, &tag, 1);
        put(image, 8, &low, 2);
        put(image, 24, &offset, 4);
        put(image, 28, &high, 4);
        put(image, 32 + 3, &byte, 1);
        put(image, 40, &whole, 4);
        put(image, 44, &after, 2);
    }
}

/* A mask of the regions of R that differ from case WHICH's image (0 when
 * every byte matches), and of the members C reads back with its own typed
 * loads: bit 0 tag and its padding (0..7), 1 w (8..23), 2 the anonymous
 * union (24..31), 3 ws (32..43), 4 after and the tail padding (44..47), 5 a
 * typed read of a written member. */
static int mismatches(const struct bnu_record *r, int which) {
    unsigned char image[sizeof(struct bnu_record)];
    image_of(image, which);
    const unsigned char *bytes = (const unsigned char *)r;
    static const size_t bounds[] = {0, 8, 24, 32, 44, 48};
    int mask = 0;
    for (int region = 0; region < 5; region++) {
        if (memcmp(bytes + bounds[region], image + bounds[region], bounds[region + 1] - bounds[region])) {
            mask |= 1 << region;
        }
    }
    int typed = 1;
    if (which == 1) {
        typed = r->tag == 9 && r->w.h == -2 && r->offset_high == 7 && r->ws[1].halves.high == -1
            && r->ws[2].bytes[3] == 0x80;
    } else if (which == 2) {
        typed = r->pointer == &the_target && r->w.words[3] == 0xFFFFFFFFu;
    } else if (which == 3) {
        typed = r->tag == 1 && r->w.word.halves.low == 0xABCD && r->offset == 4096 && r->offset_high == 1
            && r->ws[0].bytes[3] == 0x7F && r->ws[2].whole == 0x01020304u && r->after == 0x0102;
    }
    if (!typed) {
        mask |= 32;
    }
    return mask;
}

int bnu_check_live(int which) { return mismatches(&live, which); }

/* The record image BYTES (N of them, a Botlish byte storage exposed for this
 * call): exactly sizeof, then its bytes and members against case WHICH. */
int bnu_check_built(const unsigned char *bytes, unsigned long n, int which) {
    if (n != sizeof(struct bnu_record)) return 1 << 10;
    struct bnu_record r;
    memcpy(&r, bytes, sizeof r);
    return mismatches(&r, which);
}

/* Writes the 4 bytes of union bnu_word ws[I] of the live record through the
 * member alternative ALT (0 whole, 1 halves, 2 bytes) from VALUE's bits --
 * C's typed store of one interpretation, for Botlish to read through
 * another. */
void bnu_store_word(int i, int alt, unsigned long value) {
    union bnu_word *w = &live.ws[i];
    if (alt == 0) {
        w->whole = (uint32_t)value;
    } else if (alt == 1) {
        w->halves.low = (uint16_t)(value & 0xFFFF);
        w->halves.high = (int16_t)(uint16_t)((value >> 16) & 0xFFFF);
    } else {
        for (int k = 0; k < 4; k++) w->bytes[k] = (uint8_t)((value >> (8 * k)) & 0xFF);
    }
}
