/* narray-fixture.c -- the C side of the fixed-array layout tests
 * (FIXED-LAYOUT-ARRAYS.md, "Tests and oracles").
 *
 * Test infrastructure only: tests/layout-arrays.test compiles it with the
 * host C compiler into a static archive (libbotlish_narray_fixture.a) in a
 * private directory and links Botlish programs against it. Nothing in the
 * compiler, the runtime or the libraries depends on it.
 *
 * It is the independent oracle of fixed arrays: the record below is an
 * ordinary C struct holding arrays of every kind the layout language
 * represents -- characters, wide characters, a two-dimensional array of
 * ints, data pointers, records (one with tail padding, so its stride is not
 * the end of its last field) and 64-bit integers -- whose layout C itself
 * decides; the static assertions state, and the C compiler checks, every
 * offset, every array's size and element size, the record's size and its
 * alignment, as the test's Botlish `layout` declaration states them
 * explicitly. C fills the arrays with distinct typed values (each element
 * its own, so a swapped or reversed index cannot pass) and every padding
 * byte with 0xA5; Botlish reads them through a native view, element by
 * element and whole; Botlish writes through a native edit, and C reads every
 * element back with its own typed loads and checks every padding byte;
 * Botlish builds the record in byte storage, and C checks that image. The
 * expected values are written out here, in C, independently of the Botlish
 * test.
 */
#include <limits.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

struct bna_point {
    int16_t x;
    uint16_t y;
};

struct bna_tail {
    uint32_t a;
    uint8_t b;                   /* then 3 bytes of tail padding */
};

struct bna_target {
    int tag;
};

struct bna_record {
    char name[16];               /* 0 */
    uint16_t wide[5];            /* 16, then 2 bytes of padding */
    int32_t m[2][3];             /* 28, two rows of three */
    const void *ptrs[2];         /* 56 (after 4 bytes of padding) */
    struct bna_point pts[3];     /* 72 */
    struct bna_tail tails[2];    /* 84: stride 8, its tail padding included */
    long long big[2];            /* 104 (after 4 bytes of padding) */
    unsigned char last;          /* 120, then 7 bytes of tail padding */
};

_Static_assert(sizeof(struct bna_point) == 4, "bna_point size");
_Static_assert(sizeof(struct bna_tail) == 8, "bna_tail size (tail padding)");
_Static_assert(_Alignof(struct bna_tail) == 4, "bna_tail alignment");
_Static_assert(offsetof(struct bna_record, name) == 0, "name");
_Static_assert(sizeof(((struct bna_record *)0)->name) == 16, "name size");
_Static_assert(offsetof(struct bna_record, wide) == 16, "wide");
_Static_assert(sizeof(((struct bna_record *)0)->wide) == 10, "wide size");
_Static_assert(offsetof(struct bna_record, m) == 28, "m");
_Static_assert(sizeof(((struct bna_record *)0)->m) == 24, "m size");
_Static_assert(sizeof(((struct bna_record *)0)->m[0]) == 12, "m row size");
_Static_assert(offsetof(struct bna_record, ptrs) == 56, "ptrs");
_Static_assert(sizeof(((struct bna_record *)0)->ptrs) == 16, "ptrs size");
_Static_assert(offsetof(struct bna_record, pts) == 72, "pts");
_Static_assert(sizeof(((struct bna_record *)0)->pts) == 12, "pts size");
_Static_assert(offsetof(struct bna_record, tails) == 84, "tails");
_Static_assert(sizeof(((struct bna_record *)0)->tails) == 16, "tails size");
_Static_assert(offsetof(struct bna_record, big) == 104, "big");
_Static_assert(sizeof(((struct bna_record *)0)->big) == 16, "big size");
_Static_assert(offsetof(struct bna_record, last) == 120, "last");
_Static_assert(sizeof(struct bna_record) == 128, "bna_record size");
_Static_assert(_Alignof(struct bna_record) == 8, "bna_record alignment");

static struct bna_record live;
static struct bna_target the_target = {7};

const struct bna_target *bna_target(void) { return &the_target; }

int bna_is_target(const struct bna_target *p) { return p == &the_target; }

/* The bytes of the record that belong to no element of any field: the
 * padding between fields, inside struct bna_tail and at the end. */
static int is_padding(size_t at) {
    if (at >= 26 && at < 28) return 1;
    if (at >= 52 && at < 56) return 1;
    if (at >= 84 && at < 100 && (at - 84) % 8 >= 5) return 1;
    if (at >= 100 && at < 104) return 1;
    if (at >= 121) return 1;
    return 0;
}

/* Case 0, C's own values: every element distinct, each width's extremes
 * among them. name holds a NUL in the middle and is not terminated: an
 * array of characters, never a string. */
static void fill_case0(struct bna_record *r) {
    for (int i = 0; i < 16; i++) r->name[i] = (char)(i == 5 ? 0 : 'A' + i);
    r->name[15] = (char)-1;
    for (int i = 0; i < 5; i++) r->wide[i] = (uint16_t)(0x1000 * i + i + 1);
    r->wide[4] = 0xFFFF;
    for (int i = 0; i < 2; i++)
        for (int j = 0; j < 3; j++) r->m[i][j] = -(i * 100 + j * 10 + 1);
    r->m[1][2] = INT32_MIN;
    r->ptrs[0] = &the_target;
    r->ptrs[1] = NULL;
    for (int i = 0; i < 3; i++) {
        r->pts[i].x = (int16_t)(-(i + 1) * 1000);
        r->pts[i].y = (uint16_t)(60000 + i);
    }
    for (int i = 0; i < 2; i++) {
        r->tails[i].a = 0x01020304u * (uint32_t)(i + 1);
        r->tails[i].b = (uint8_t)(0xB0 + i);
    }
    r->big[0] = LLONG_MIN;
    r->big[1] = LLONG_MAX;
    r->last = 0x5A;
}

/* The record, every byte 0xA5 and then case 0's elements: its address. */
struct bna_record *bna_reset(void) {
    memset(&live, 0xA5, sizeof live);
    fill_case0(&live);
    return &live;
}

/* The record, every byte 0xA5 (nothing filled): its address. */
struct bna_record *bna_blank(void) {
    memset(&live, 0xA5, sizeof live);
    return &live;
}

void bna_copy_live(unsigned char *out, unsigned long n) {
    memcpy(out, &live, n < sizeof live ? n : sizeof live);
}

/* A mask of the element groups of R that differ from case WHICH, with C's
 * typed reads (0 when every one matches):
 *
 *   case 1 -- what the test writes element by element through a native
 *             edit: name[0] = 'z', name[15] = 0 (the rest of name, 0xA5),
 *             wide[2] = 0xBEEF, m[0][1] = 77 and m[1][2] = INT32_MAX,
 *             ptrs[1] = the target, pts[2].x = -5, tails[1].b = 0x11,
 *             big[0] = -2; every other element keeps its sentinel bytes;
 *   case 2 -- what the test writes whole: name = 'a'.. 'p' with a NUL at 3,
 *             wide = 1..5, m = {{10, 11, 12}, {20, 21, 22}}, ptrs = {NULL,
 *             the target}, pts = {(1, 2), (3, 4), (5, 6)}, tails = {(9, 8),
 *             (7, 6)}, big = {LLONG_MAX, LLONG_MIN}; last untouched;
 *   case 3 -- case 2 built in byte storage (the record image): last = 0,
 *             its padding zero.
 *
 * Bit 0 name, 1 wide, 2 m, 3 ptrs, 4 pts, 5 tails, 6 big, 7 last, 8 a
 * padding byte. */
static int mismatches(const struct bna_record *r, int which) {
    int mask = 0;
    struct bna_record e;
    memset(&e, which == 3 ? 0 : 0xA5, sizeof e);
    if (which == 1) {
        e.name[0] = 'z';
        e.name[15] = 0;
        e.wide[2] = 0xBEEF;
        e.m[0][1] = 77;
        e.m[1][2] = INT32_MAX;
        e.ptrs[1] = &the_target;
        e.pts[2].x = -5;
        e.tails[1].b = 0x11;
        e.big[0] = -2;
    } else {
        for (int i = 0; i < 16; i++) e.name[i] = (char)(i == 3 ? 0 : 'a' + i);
        for (int i = 0; i < 5; i++) e.wide[i] = (uint16_t)(i + 1);
        for (int i = 0; i < 2; i++)
            for (int j = 0; j < 3; j++) e.m[i][j] = (i + 1) * 10 + j;
        e.ptrs[0] = NULL;
        e.ptrs[1] = &the_target;
        for (int i = 0; i < 3; i++) {
            e.pts[i].x = (int16_t)(2 * i + 1);
            e.pts[i].y = (uint16_t)(2 * i + 2);
        }
        e.tails[0].a = 9;
        e.tails[0].b = 8;
        e.tails[1].a = 7;
        e.tails[1].b = 6;
        e.big[0] = LLONG_MAX;
        e.big[1] = LLONG_MIN;
        if (which == 3) e.last = 0;
    }
    if (memcmp(r->name, e.name, sizeof e.name)) mask |= 1;
    for (int i = 0; i < 5; i++) if (r->wide[i] != e.wide[i]) mask |= 2;
    for (int i = 0; i < 2; i++)
        for (int j = 0; j < 3; j++) if (r->m[i][j] != e.m[i][j]) mask |= 4;
    for (int i = 0; i < 2; i++) {
        /* A sentinel pointer word is compared as bytes; a pointer the test
         * stores, as the pointer. */
        if (memcmp(&r->ptrs[i], &e.ptrs[i], sizeof(void *))) mask |= 8;
    }
    for (int i = 0; i < 3; i++) if (r->pts[i].x != e.pts[i].x || r->pts[i].y != e.pts[i].y) mask |= 16;
    for (int i = 0; i < 2; i++) if (r->tails[i].a != e.tails[i].a || r->tails[i].b != e.tails[i].b) mask |= 32;
    for (int i = 0; i < 2; i++) if (r->big[i] != e.big[i]) mask |= 64;
    if (which != 2 && r->last != e.last) mask |= 128;
    if (which == 2 && r->last != 0x5A) mask |= 128;
    const unsigned char *bytes = (const unsigned char *)r;
    for (size_t at = 0; at < sizeof *r; at++) {
        if (is_padding(at) && bytes[at] != (which == 3 ? 0 : 0xA5)) mask |= 256;
    }
    return mask;
}

int bna_check_live(int which) { return mismatches(&live, which); }

/* The record image BYTES (N of them, a Botlish byte storage exposed for this
 * call): exactly sizeof, then its elements against case WHICH. */
int bna_check_built(const unsigned char *bytes, unsigned long n, int which) {
    if (n != sizeof(struct bna_record)) return 1 << 10;
    struct bna_record r;
    memcpy(&r, bytes, sizeof r);
    return mismatches(&r, which);
}
