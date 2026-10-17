/* fixture.c -- the C side of the C FFI tests (C-FFI.md, "Testing").
 *
 * Test infrastructure only: tests/c-ffi.test, audit/c-ffi/tools/ and
 * bench/c-ffi.tcl compile it with the host C compiler into a static archive
 * (libbotlish_cffi_fixture.a) in a private directory and link Botlish
 * programs against it with `extern c library "botlish_cffi_fixture"` and
 * -L. Nothing in the compiler, the runtime or the libraries depends on it.
 * Every function is a plain fixed-signature C function of the ABI universe
 * extern c fn supports: integer scalars, data and function pointers, void.
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

/* Scalars: each returns its argument, so a round trip shows the transport
 * (sign or zero extension, width) of both directions. */
signed char bcf_echo_schar(signed char x) { return x; }
unsigned char bcf_echo_uchar(unsigned char x) { return x; }
char bcf_echo_char(char x) { return x; }
short bcf_echo_short(short x) { return x; }
unsigned short bcf_echo_ushort(unsigned short x) { return x; }
int bcf_echo_int(int x) { return x; }
unsigned int bcf_echo_uint(unsigned int x) { return x; }
long bcf_echo_long(long x) { return x; }
unsigned long bcf_echo_ulong(unsigned long x) { return x; }
long long bcf_echo_longlong(long long x) { return x; }
unsigned long long bcf_echo_ulonglong(unsigned long long x) { return x; }

/* Widening inside C: what C sees of a narrow argument. */
long bcf_widen_schar(signed char x) { return x; }
long bcf_widen_uchar(unsigned char x) { return x; }
long bcf_widen_short(short x) { return x; }
long bcf_widen_ushort(unsigned short x) { return x; }
long long bcf_widen_int(int x) { return x; }
unsigned long long bcf_widen_uint(unsigned int x) { return x; }

int bcf_add(int a, int b) { return a + b; }
long bcf_sub_long(long a, long b) { return a - b; }

/* Ten arguments of mixed classes: past the six (x86-64 SysV) or eight
 * (AAPCS64) integer argument registers, so the last ones are on the stack.
 * Returns a checksum that sees every argument at its own weight. */
long long bcf_many(long a, int b, short c, signed char d, unsigned char e,
                   unsigned short f, unsigned int g, unsigned long h, long i, int j) {
    return (long long)a + 2LL * b + 3LL * c + 5LL * d + 7LL * e + 11LL * f
        + 13LL * (long long)g + 17LL * (long long)h + 19LL * i + 23LL * j;
}

/* The last argument alone, past the registers. */
int bcf_tenth(int a, int b, int c, int d, int e, int f, int g, int h, int i, int j) {
    (void)a; (void)b; (void)c; (void)d; (void)e; (void)f; (void)g; (void)h; (void)i;
    return j;
}

void bcf_nothing(void) {}

/* Pointers. */
static unsigned char bcf_cell[16];
void *bcf_address(void) { return bcf_cell; }
void *bcf_null(void) { return NULL; }
int bcf_is_null(void *p) { return p == NULL; }
void *bcf_echo_ptr(void *p) { return p; }
int bcf_same(void *a, void *b) { return a == b; }
/* A pointer one past P: a result that is *not* its argument, for the alias
 * contract's check. */
unsigned char *bcf_next(unsigned char *p) { return p + 1; }
/* An address no Botlish C pointer word holds (non-canonical on x86-64). */
void *bcf_wild(void) { return (void *)(uintptr_t)0xf000000000000010ull; }

/* Byte storage: read, write, both. */
unsigned long bcf_sum(const unsigned char *data, unsigned long count) {
    unsigned long sum = 0;
    for (unsigned long i = 0; i < count; i++) {
        sum += data[i];
    }
    return sum;
}

void bcf_fill(unsigned char *out, unsigned long count, unsigned char seed) {
    for (unsigned long i = 0; i < count; i++) {
        out[i] = (unsigned char)(seed + 37 * i);
    }
}

/* SHA256's shape: reads DATA, writes OUT, returns OUT. */
unsigned char *bcf_reverse(const unsigned char *data, unsigned long count, unsigned char *out) {
    for (unsigned long i = 0; i < count; i++) {
        out[i] = data[count - 1 - i];
    }
    return out;
}

/* The same, returning one byte past OUT (a false `alias out` contract). */
unsigned char *bcf_reverse_off(const unsigned char *data, unsigned long count, unsigned char *out) {
    bcf_reverse(data, count, out);
    return out + 1;
}

/* A pointer result inside its argument (memchr's shape). */
const unsigned char *bcf_find(const unsigned char *data, unsigned long count, unsigned char byte) {
    const void *found = memchr(data, byte, count);
    return found;
}

/* Retains its argument: a capturing contract (direct authority). */
static void *bcf_kept;
void bcf_keep(void *p) { bcf_kept = p; }
void *bcf_kept_pointer(void) { return bcf_kept; }

/* Function pointers: one is only passed and returned (Botlish never calls
 * one). */
typedef int (*bcf_callback)(int);
static int bcf_twice(int x) { return 2 * x; }
bcf_callback bcf_callback_twice(void) { return bcf_twice; }
int bcf_apply(bcf_callback f, int x) { return f(x); }

/* Narrow results with dirty upper register bits: the ABI leaves the bits of
 * a char or short result beyond its width unspecified, and GCC leaves them,
 * so a caller must extend the result itself. These return 0x80 (as unsigned
 * char), -128 (as signed char), 0x8000 and -32768 with every higher bit of
 * the result register set the other way. */
#if defined(__x86_64__)
__asm__(
    ".text\n"
    ".globl bcf_dirty_uchar\n.type bcf_dirty_uchar,@function\nbcf_dirty_uchar:\n"
    "    movabsq $0x5555555555555580, %rax\n    ret\n"
    ".globl bcf_dirty_schar\n.type bcf_dirty_schar,@function\nbcf_dirty_schar:\n"
    "    movabsq $0x5555555555555580, %rax\n    ret\n"
    ".globl bcf_dirty_ushort\n.type bcf_dirty_ushort,@function\nbcf_dirty_ushort:\n"
    "    movabsq $0x5555555555558000, %rax\n    ret\n"
    ".globl bcf_dirty_short\n.type bcf_dirty_short,@function\nbcf_dirty_short:\n"
    "    movabsq $0x5555555555558000, %rax\n    ret\n"
    ".globl bcf_dirty_uint\n.type bcf_dirty_uint,@function\nbcf_dirty_uint:\n"
    "    movabsq $0x55555555fffffff0, %rax\n    ret\n"
    ".globl bcf_dirty_int\n.type bcf_dirty_int,@function\nbcf_dirty_int:\n"
    "    movabsq $0x55555555fffffff0, %rax\n    ret\n");
#elif defined(__aarch64__)
__asm__(
    ".text\n"
    ".globl bcf_dirty_uchar\n.type bcf_dirty_uchar,%function\nbcf_dirty_uchar:\n"
    "    movz x0, #0x5580\n    movk x0, #0x5555, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n"
    ".globl bcf_dirty_schar\n.type bcf_dirty_schar,%function\nbcf_dirty_schar:\n"
    "    movz x0, #0x5580\n    movk x0, #0x5555, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n"
    ".globl bcf_dirty_ushort\n.type bcf_dirty_ushort,%function\nbcf_dirty_ushort:\n"
    "    movz x0, #0x8000\n    movk x0, #0x5555, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n"
    ".globl bcf_dirty_short\n.type bcf_dirty_short,%function\nbcf_dirty_short:\n"
    "    movz x0, #0x8000\n    movk x0, #0x5555, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n"
    ".globl bcf_dirty_uint\n.type bcf_dirty_uint,%function\nbcf_dirty_uint:\n"
    "    movz x0, #0xfff0\n    movk x0, #0xffff, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n"
    ".globl bcf_dirty_int\n.type bcf_dirty_int,%function\nbcf_dirty_int:\n"
    "    movz x0, #0xfff0\n    movk x0, #0xffff, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n");
#endif

/* Counts its own calls: the performance benchmark's per-call work. */
static unsigned long bcf_calls;
unsigned long bcf_count(void) { return ++bcf_calls; }
