/* fixture.c -- the C side of the C FFI tests (C-FFI.md, "Testing").
 *
 * Test infrastructure only: tests/c-ffi.test, audit/c-ffi/tools/ and
 * bench/c-ffi.tcl compile it with the host C compiler (GCC or Clang on
 * Linux, Apple clang on macOS) into a static archive
 * (libbotlish_cffi_fixture.a) in a private directory and link Botlish
 * programs against it with `extern c library "botlish_cffi_fixture"` and
 * -L. Nothing in the compiler, the runtime or the libraries depends on it.
 * Every function is a plain fixed-signature C function of the ABI universe
 * extern c fn supports: integer scalars, C _Bool, data and function
 * pointers, void.
 *
 * A few functions are assembly, where C cannot observe what the ABI
 * promises (a result register's bits beyond its width, the registers and
 * stack slots an argument arrives in): one text per instruction set, spelled
 * for the object format through BCF_FUNCTION (ELF's bare symbol and `.type`,
 * Mach-O's `_` user label prefix).
 */
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

/* An assembly function's header: the global symbol NAME, aligned, in the
 * object format's spelling. */
#if defined(__APPLE__)
#define BCF_FUNCTION(name) ".globl _" #name "\n.p2align 2\n_" #name ":\n"
#define BCF_CALL(name) "_" #name
#elif defined(__aarch64__)
#define BCF_FUNCTION(name) ".globl " #name "\n.type " #name ",%function\n.p2align 2\n" #name ":\n"
#define BCF_CALL(name) #name
#endif

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
long bcf_widen_char(char x) { return x; }
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
#if defined(__x86_64__) && !defined(__APPLE__)
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
    BCF_FUNCTION(bcf_dirty_uchar)
    "    movz x0, #0x5580\n    movk x0, #0x5555, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n"
    BCF_FUNCTION(bcf_dirty_schar)
    "    movz x0, #0x5580\n    movk x0, #0x5555, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n"
    BCF_FUNCTION(bcf_dirty_ushort)
    "    movz x0, #0x8000\n    movk x0, #0x5555, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n"
    BCF_FUNCTION(bcf_dirty_short)
    "    movz x0, #0x8000\n    movk x0, #0x5555, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n"
    BCF_FUNCTION(bcf_dirty_uint)
    "    movz x0, #0xfff0\n    movk x0, #0xffff, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n"
    BCF_FUNCTION(bcf_dirty_int)
    "    movz x0, #0xfff0\n    movk x0, #0xffff, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n");
#endif

/* C _Bool (ffi::c::Bool, C-BINDGEN.md "C bool"): round trips, what C
 * sees, and the transport's corners. */
bool bcf_echo_bool(bool x) { return x; }
bool bcf_bool_false(void) { return false; }
bool bcf_bool_true(void) { return true; }
int bcf_observe_bool(bool x) { return x ? 1 : 0; }
bool bcf_not(bool x) { return !x; }
bool bcf_is_positive(int x) { return x > 0; }
int bcf_bool_args(bool a, int b, bool c) { return (a ? 100 : 0) + b + (c ? 1 : 0); }
/* Ten arguments, the bools last: on the stack on both targets. */
int bcf_bool_stack(long a, long b, long c, long d, long e, long f, long g, long h, bool i, bool j) {
    (void)a; (void)b; (void)c; (void)d; (void)e; (void)f; (void)g; (void)h;
    return (i ? 2 : 0) + (j ? 1 : 0);
}
/* A pointer to _Bool is only passed through. */
bool *bcf_echo_bool_ptr(bool *p) { return p; }
typedef bool (*bcf_predicate)(int);
static bool bcf_odd(int x) { return x % 2 != 0; }
bcf_predicate bcf_predicate_odd(void) { return bcf_odd; }

/* The register a _Bool argument arrives in, all 32 low bits of it (the
 * platform ABIs have the caller zero-extend it as an unsigned char), and
 * _Bool results with dirty bits above the byte (valid: the bits are
 * unspecified) or a byte that is no _Bool (2: the call must fail). */
#if defined(__x86_64__) && !defined(__APPLE__)
__asm__(
    ".text\n"
    ".globl bcf_bool_register\n.type bcf_bool_register,@function\nbcf_bool_register:\n"
    "    movl %edi, %eax\n    ret\n"
    ".globl bcf_dirty_bool_true\n.type bcf_dirty_bool_true,@function\nbcf_dirty_bool_true:\n"
    "    movabsq $0x5555555555555501, %rax\n    ret\n"
    ".globl bcf_dirty_bool_false\n.type bcf_dirty_bool_false,@function\nbcf_dirty_bool_false:\n"
    "    movabsq $0x5555555555555500, %rax\n    ret\n"
    ".globl bcf_invalid_bool\n.type bcf_invalid_bool,@function\nbcf_invalid_bool:\n"
    "    movl $2, %eax\n    ret\n");
#elif defined(__aarch64__)
__asm__(
    ".text\n"
    BCF_FUNCTION(bcf_bool_register)
    "    mov w0, w0\n    ret\n"
    BCF_FUNCTION(bcf_dirty_bool_true)
    "    movz x0, #0x5501\n    movk x0, #0x5555, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n"
    BCF_FUNCTION(bcf_dirty_bool_false)
    "    movz x0, #0x5500\n    movk x0, #0x5555, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n"
    BCF_FUNCTION(bcf_invalid_bool)
    "    mov w0, #2\n    ret\n");
#endif

/* Counts its own calls: the performance benchmark's per-call work. */
static unsigned long bcf_calls;
unsigned long bcf_count(void) { return ++bcf_calls; }

/* ---------------------------------------------------------------------------
 * The Apple AArch64 milestone's ABI evidence (MACOS-AARCH64-MILESTONE-6.md):
 * every C scalar in registers and on the stack, read back by C compiled by
 * the platform's own compiler, and the raw machine state a call arrives
 * in. */

/* What a call of bcf_capture arrived in: the integer argument registers
 * (x0-x7 on AArch64; rdi, rsi, rdx, rcx, r8, r9 on x86-64), all 64 bits of
 * each, and the first 128 bytes at the stack pointer the caller left, where
 * its stack-passed arguments start. bcf_capture is assembly (below): it
 * saves the registers before any compiled code can touch them and hands
 * them to bcf_capture_record, which keeps them here. Declared with any
 * signature (each Botlish binding gives it one), it reads the arguments of
 * that signature without interpreting them, and returns 0. */
static unsigned long long bcf_regs[8];
static unsigned char bcf_stack[128];
static unsigned long long bcf_ref_regs[8];
static unsigned char bcf_ref_stack[128];

int bcf_capture_record(const unsigned long long *regs, const unsigned char *stack, int count) {
    for (int i = 0; i < 8; i++) {
        bcf_regs[i] = i < count ? regs[i] : 0;
    }
    memcpy(bcf_stack, stack, sizeof bcf_stack);
    return 0;
}

int bcf_capture(void);

#if defined(__x86_64__) && !defined(__APPLE__)
__asm__(
    ".text\n"
    ".globl bcf_capture\n.type bcf_capture,@function\nbcf_capture:\n"
    "    pushq %rbp\n    movq %rsp, %rbp\n    subq $48, %rsp\n"
    "    movq %rdi, 0(%rsp)\n    movq %rsi, 8(%rsp)\n    movq %rdx, 16(%rsp)\n"
    "    movq %rcx, 24(%rsp)\n    movq %r8, 32(%rsp)\n    movq %r9, 40(%rsp)\n"
    "    movq %rsp, %rdi\n    leaq 16(%rbp), %rsi\n    movl $6, %edx\n"
    "    call bcf_capture_record@PLT\n"
    "    leave\n    ret\n");
#elif defined(__aarch64__)
__asm__(
    ".text\n"
    BCF_FUNCTION(bcf_capture)
    "    stp x29, x30, [sp, #-80]!\n    mov x29, sp\n"
    "    stp x0, x1, [sp, #16]\n    stp x2, x3, [sp, #32]\n"
    "    stp x4, x5, [sp, #48]\n    stp x6, x7, [sp, #64]\n"
    "    add x0, sp, #16\n    add x1, sp, #80\n    mov w2, #8\n"
    "    bl " BCF_CALL(bcf_capture_record) "\n"
    "    ldp x29, x30, [sp], #80\n    ret\n");
#endif

/* The last capture: register I's 64 bits and its low 32, stack byte I. */
unsigned long long bcf_captured_register(int i) { return bcf_regs[i & 7]; }
unsigned int bcf_captured_register32(int i) { return (unsigned int)bcf_regs[i & 7]; }
unsigned char bcf_captured_stack_byte(int i) { return bcf_stack[i & 127]; }

/* The same, of the reference call bcf_reference_* made: the call this C
 * compiler makes of bcf_capture with the same prototype and values as a
 * Botlish binding's, its own answer to where each argument goes. */
unsigned int bcf_reference_register32(int i) { return (unsigned int)bcf_ref_regs[i & 7]; }
unsigned long long bcf_reference_register(int i) { return bcf_ref_regs[i & 7]; }
unsigned char bcf_reference_stack_byte(int i) { return bcf_ref_stack[i & 127]; }

static void bcf_keep_reference(void) {
    memcpy(bcf_ref_regs, bcf_regs, sizeof bcf_regs);
    memcpy(bcf_ref_stack, bcf_stack, sizeof bcf_stack);
}

/* The registers, all narrow: one of every narrow class, C _Bool and plain
 * char, the values those of c-ffi.test's cf-abi-register-extension.
 * Exactly the eight argument registers of AArch64, the last (x7) a char
 * (x86-64 passes the last two on the stack). */
typedef int (*bcf_narrow8_fn)(signed char, unsigned char, short, unsigned short, int, unsigned int, bool, char);

int bcf_reference_narrow8(void) {
    volatile bcf_narrow8_fn f = (bcf_narrow8_fn)bcf_capture;
    int r = f(-2, 253, -1234, 65244, -123456789, 4275878552u, true, (char)-3);
    bcf_keep_reference();
    return r;
}

/* Twenty parameters: a selector, seven narrow register arguments and
 * twelve stack arguments of mixed width and signedness -- adjacent narrow
 * ones, a 64-bit one after narrow ones, narrow ones after it. Apple packs
 * them at their natural size and alignment (bytes 0, 1, 2, 4, 6, 8, 12,
 * 16, 24, 26, 28, 32); AAPCS64 and SysV give each its own 8-byte slot. */
#define BCF_PICK_PARAMS int which, signed char a1, unsigned char a2, short a3, \
    unsigned short a4, int a5, unsigned int a6, char a7, signed char s8, \
    unsigned char s9, short s10, signed char s11, unsigned short s12, int s13, \
    signed char s14, long s15, unsigned char s16, short s17, unsigned int s18, \
    signed char s19

/* Argument WHICH (1-19) as C received it, read by this compiler's code for
 * this prototype: what a callee makes of each argument's location and
 * extension. */
long long bcf_pick(BCF_PICK_PARAMS) {
    switch (which) {
    case 1: return a1;
    case 2: return a2;
    case 3: return a3;
    case 4: return a4;
    case 5: return a5;
    case 6: return a6;
    case 7: return a7;
    case 8: return s8;
    case 9: return s9;
    case 10: return s10;
    case 11: return s11;
    case 12: return s12;
    case 13: return s13;
    case 14: return s14;
    case 15: return s15;
    case 16: return s16;
    case 17: return s17;
    case 18: return s18;
    case 19: return s19;
    default: return -999;
    }
}

typedef int (*bcf_pick_fn)(BCF_PICK_PARAMS);

int bcf_reference_pick(void) {
    volatile bcf_pick_fn f = (bcf_pick_fn)bcf_capture;
    int r = f(0, -2, 253, -1234, 65244, -123456789, 4275878552u, (char)-3,
              -4, 247, -30000, -128, 48879, -2000000000, 127, -81985529216486895L,
              128, -2, 2147483649u, -1);
    bcf_keep_reference();
    return r;
}

/* One stack argument past eight register ones: a signed char at the start
 * of the stack area. */
int bcf_ninth(long a, long b, long c, long d, long e, long f, long g, long h, signed char i) {
    (void)a; (void)b; (void)c; (void)d; (void)e; (void)f; (void)g; (void)h;
    return i;
}

/* Stack arguments ending two bytes short of a 16-byte boundary: a long at
 * 0, an int at 8, a short at 12 and a signed char at 14 under Apple's
 * packing. The arguments are checked here; what matters as much is that
 * the caller wrote nothing past them (cf-abi-stack-tail-frame). */
long long bcf_stack_tail(long a, long b, long c, long d, long e, long f, long g, long h,
                         long i, int j, short k, signed char l) {
    return a + 2 * b + 3 * c + 4 * d + 5 * e + 6 * f + 7 * g + 8 * h
        + 9 * i + 10LL * j + 11LL * k + 12LL * l;
}

/* Pointers among integers, in registers and on the stack: a bit per
 * argument that is exactly what cf-abi-pointer-mix passes, 0xfff for all. */
static unsigned char bcf_cell2[16];
void *bcf_address2(void) { return bcf_cell2; }
/* Addresses never dereferenced: the top of the 47-bit user space and an
 * address with every high bit set, which a C pointer word holds as its
 * sign-extended 60 bits. */
void *bcf_user_top(void) { return (void *)(uintptr_t)0x00007ffffffffff0ull; }
void *bcf_high_address(void) { return (void *)(uintptr_t)0xfffffffffffffff0ull; }
int bcf_needs_64_bits(void *p) { return ((uintptr_t)p >> 32) != 0; }

int bcf_pointer_mix(void *a, signed char b, void *c, unsigned short d, long e, void *f, int g,
                    void *h, void *s0, signed char s1, void *s2, short s3) {
    int mask = 0;
    mask |= (a == (void *)bcf_cell) << 0;
    mask |= (b == -5) << 1;
    mask |= (c == NULL) << 2;
    mask |= (d == 65000) << 3;
    mask |= (e == -1234567890123L) << 4;
    mask |= (f == (void *)bcf_cell2) << 5;
    mask |= (g == -7) << 6;
    mask |= (h == bcf_high_address()) << 7;
    mask |= (s0 == (void *)bcf_cell) << 8;
    mask |= (s1 == -128) << 9;
    mask |= (s2 == bcf_user_top()) << 10;
    mask |= (s3 == -32768) << 11;
    return mask;
}

/* A C function's own sentinel: -1 for a zero divisor, the quotient
 * otherwise. Botlish interprets it; nothing translates it. */
int bcf_checked_div(int a, int b) { return b == 0 ? -1 : a / b; }

/* C recursion as deep as N, returning N: each frame keeps a volatile
 * buffer it reads after the recursive call (so the call is no tail call),
 * and a large N exhausts the stack it runs on (the native worker thread's
 * or a coroutine's) inside C. */
__attribute__((noinline)) long bcf_deep(long n) {
    volatile unsigned char pad[256];
    pad[0] = (unsigned char)n;
    if (n <= 0) {
        return 0;
    }
    return bcf_deep(n - 1) + (pad[0] == (unsigned char)n);
}

#if defined(__APPLE__)
/* A call clang compiles to its compiler runtime's
 * `__isPlatformVersionAtLeast` (libclang_rt.osx.a, not libSystem): linked
 * only with the C driver's default libraries (codegen/aot.rs's
 * link_plan_args_for). macOS 99 is no version a runner has: 0. */
int bcf_available(void) {
    if (__builtin_available(macOS 99, *)) {
        return 1;
    }
    return 0;
}
#endif
