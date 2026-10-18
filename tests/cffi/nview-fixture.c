/* nview-fixture.c -- the C side of the native layout view tests
 * (NATIVE-LAYOUT-VIEWS.md, "The synthetic fixture").
 *
 * Test infrastructure only: tests/native-view.test and bench/native-view.tcl
 * compile it with the host C compiler into a static archive
 * (libbotlish_nview_fixture.a) in a private directory and link Botlish
 * programs against it. Nothing in the compiler, the runtime or the libraries
 * depends on it.
 *
 * It is the independent oracle of a record's representation: the records
 * below are ordinary C structs that C itself initializes and lays out, and
 * the static assertions state -- and the C compiler checks -- every offset,
 * the size and the alignment the test's Botlish `layout` declarations state
 * explicitly. Botlish never computes them: if this compiler laid the struct
 * out differently, this file would not compile.
 */
#include <limits.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

struct bnv_point {
    int16_t x;
    uint16_t y;
};

struct bnv_record {
    uint8_t u8;                  /* 0 */
    int8_t i8;                   /* 1 */
    uint16_t u16;                /* 2 */
    int32_t i32;                 /* 4 */
    uint64_t u64;                /* 8 */
    int64_t i64;                 /* 16 */
    int16_t i16;                 /* 24, then 2 bytes of padding */
    uint32_t u32;                /* 28 */
    struct bnv_point origin;     /* 32 */
    long lng;                    /* 40 (after 4 bytes of padding) */
    void *null_ptr;              /* 48 */
    const struct bnv_point *point_ptr; /* 56 */
    int (*callback)(int);        /* 64 */
    unsigned char tail;          /* 72, then 7 bytes of tail padding */
};

_Static_assert(sizeof(struct bnv_point) == 4, "bnv_point size");
_Static_assert(offsetof(struct bnv_point, y) == 2, "bnv_point.y");
_Static_assert(offsetof(struct bnv_record, i8) == 1, "i8");
_Static_assert(offsetof(struct bnv_record, u16) == 2, "u16");
_Static_assert(offsetof(struct bnv_record, i32) == 4, "i32");
_Static_assert(offsetof(struct bnv_record, u64) == 8, "u64");
_Static_assert(offsetof(struct bnv_record, i64) == 16, "i64");
_Static_assert(offsetof(struct bnv_record, i16) == 24, "i16");
_Static_assert(offsetof(struct bnv_record, u32) == 28, "u32");
_Static_assert(offsetof(struct bnv_record, origin) == 32, "origin");
_Static_assert(offsetof(struct bnv_record, lng) == 40, "lng");
_Static_assert(offsetof(struct bnv_record, null_ptr) == 48, "null_ptr");
_Static_assert(offsetof(struct bnv_record, point_ptr) == 56, "point_ptr");
_Static_assert(offsetof(struct bnv_record, callback) == 64, "callback");
_Static_assert(offsetof(struct bnv_record, tail) == 72, "tail");
_Static_assert(sizeof(struct bnv_record) == 80, "bnv_record size");
_Static_assert(_Alignof(struct bnv_record) == 8, "bnv_record alignment");
_Static_assert(sizeof(long) == 8 && sizeof(void *) == 8, "an LP64 target");

/* The callback a record's function pointer field holds. */
int bnv_callback(int x) { return x + 1; }

static const struct bnv_point bnv_the_point = {1234, 4321};

/* Two records: every width's minimum, maximum or all-ones pattern in the
 * first, the other extreme (and zero) in the second; the padding bytes are
 * set to 0xA5 so that a reader that mistakes them for a field shows. */
static struct bnv_record bnv_records[2];

static void bnv_init(void) {
    static int done;
    if (done) {
        return;
    }
    done = 1;
    memset(bnv_records, 0xA5, sizeof bnv_records);
    struct bnv_record *a = &bnv_records[0];
    a->u8 = UINT8_MAX;
    a->i8 = INT8_MIN;
    a->u16 = UINT16_MAX;
    a->i32 = INT32_MIN;
    a->u64 = UINT64_MAX;
    a->i64 = INT64_MIN;
    a->i16 = -1;
    a->u32 = 0x80000001u;
    a->origin.x = INT16_MIN;
    a->origin.y = UINT16_MAX;
    a->lng = LONG_MAX;
    a->null_ptr = NULL;
    a->point_ptr = &bnv_the_point;
    a->callback = bnv_callback;
    a->tail = 0x5A;
    struct bnv_record *b = &bnv_records[1];
    b->u8 = 0;
    b->i8 = INT8_MAX;
    b->u16 = 0;
    b->i32 = INT32_MAX;
    b->u64 = 0;
    b->i64 = INT64_MAX;
    b->i16 = 0;
    b->u32 = UINT32_MAX;
    b->origin.x = INT16_MAX;
    b->origin.y = 0;
    b->lng = LONG_MIN;
    b->null_ptr = NULL;
    b->point_ptr = NULL;
    b->callback = NULL;
    b->tail = 0;
}

/* The address of record WHICH (0 or 1). */
const struct bnv_record *bnv_record(int which) {
    bnv_init();
    return &bnv_records[which & 1];
}

/* Copies the first N bytes of record WHICH to OUT: its representation as
 * ordinary bytes. */
void bnv_copy_record(int which, unsigned char *out, unsigned long n) {
    bnv_init();
    if (n > sizeof(struct bnv_record)) {
        n = sizeof(struct bnv_record);
    }
    memcpy(out, &bnv_records[which & 1], n);
}

unsigned long bnv_record_size(void) { return sizeof(struct bnv_record); }

/* 1 if P is exactly the point record 0's point_ptr holds. */
int bnv_is_point(const void *p) { return p == (const void *)&bnv_the_point; }

/* 1 if F is exactly the callback record 0's callback holds. */
int bnv_is_callback(int (*f)(int)) { return f == bnv_callback; }

/* The address of the point record itself (independent of any record). */
const struct bnv_point *bnv_point(void) { return &bnv_the_point; }
