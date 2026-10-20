/* bwp.c -- the Windows toolchain probe's C library (WINDOWS-TOOLCHAIN-CENSUS.md).
 *
 * Plain C, built by the toolchain under test (cl.exe, MinGW-w64 gcc, or the
 * host's cc for the Linux control) as a static library or a DLL, and called
 * from audit/windows-toolchain/programs/ffi-probe.bot. Each function checks one
 * fact of the target's C ABI that a Botlish foreign call depends on: the data
 * model (sizeof long, wchar_t, pointers), positional register assignment of
 * mixed integer and double arguments, arguments on the stack, narrow results,
 * and byte storage exposed for one call. */
#include <stddef.h> /* size_t, wchar_t: no C runtime header needed */

#if defined(_WIN32) && defined(BWP_DLL)
#define BWP_API __declspec(dllexport)
#else
#define BWP_API
#endif

BWP_API int bwp_add(int a, int b) { return a + b; }

/* The data model: 4 8 2 on Windows (LLP64), 8 8 4 on Linux (LP64). */
BWP_API int bwp_sizeof_long(void) { return (int)sizeof(long); }
BWP_API int bwp_sizeof_pointer(void) { return (int)sizeof(void *); }
BWP_API int bwp_sizeof_wchar(void) { return (int)sizeof(wchar_t); }

BWP_API long bwp_long_echo(long x) { return x; }

/* Win64 assigns argument registers by position (a: rcx, b: xmm1, c: r8,
 * d: xmm3) and passes e and f on the stack above the 32-byte shadow space;
 * SysV counts integer and double registers separately. Any misplacement
 * changes the weighted sum. */
BWP_API double bwp_mix(int a, double b, int c, double d, signed char e, double f) {
    return a + b * 2.0 + c * 4.0 + d * 8.0 + e * 16.0 + f * 32.0;
}

/* Ten integer arguments: six of them on the stack on Win64, four on SysV. */
BWP_API long long bwp_sum10(long long a, long long b, long long c, long long d, long long e,
                            long long f, long long g, long long h, long long i, int j) {
    return a + 2 * b + 3 * c + 4 * d + 5 * e + 6 * f + 7 * g + 8 * h + 9 * i + 10LL * j;
}

/* A narrow result: the callee leaves the upper bits of the register as it likes. */
BWP_API signed char bwp_narrow(int x) { return (signed char)x; }

/* Byte storage exposed for one call (C-POINTER-BORROWING.md). */
BWP_API unsigned long bwp_sum_bytes(const unsigned char *data, unsigned long count) {
    unsigned long sum = 0;
    for (unsigned long i = 0; i < count; i++) sum += data[i];
    return sum;
}

BWP_API void bwp_fill(unsigned char *out, unsigned long count, unsigned char seed) {
    for (unsigned long i = 0; i < count; i++) out[i] = (unsigned char)(seed + i);
}
