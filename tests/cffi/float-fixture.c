/* float-fixture.c -- the C side of tests/float64.test's C double tests
 * (FLOAT64-MILESTONE-1.md): functions taking and returning doubles in the
 * platform C ABI, among them ones returning what no Float64 is (NaN, the
 * infinities) and negative zero, and one reporting the sign of the zero it
 * was given. Compiled by the test into a static archive in a private
 * directory; test infrastructure only. */

#include <math.h>

double bff_twice(double x) { return 2.0 * x; }

double bff_add3(double a, double b, double c) { return a + b + c; }

/* Integer and floating-point parameters interleaved: each class fills its
 * own registers. */
double bff_mix(int n, double x, long k, double y) { return n * x + k * y; }

/* More doubles than there are argument registers on any target (8 on
 * SysV x86-64 and AAPCS64): the rest go on the stack. */
double bff_sum10(double a, double b, double c, double d, double e,
                 double f, double g, double h, double i, double j) {
    return a + 2 * b + 3 * c + 4 * d + 5 * e + 6 * f + 7 * g + 8 * h + 9 * i + 10 * j;
}

double bff_positive_infinity(void) { return INFINITY; }

double bff_negative_infinity(void) { return -INFINITY; }

double bff_not_a_number(void) { return NAN; }

double bff_negative_zero(void) { return -0.0; }

double bff_largest(void) { return 1.7976931348623157e308; }

double bff_smallest(void) { return 4.9406564584124654e-324; }

/* 1 when C received negative zero. */
int bff_signbit(double x) { return signbit(x) != 0; }

/* The high 32 bits of X's binary64 representation: what C received,
 * exactly. */
long long bff_bits_high(double x) {
    union { double d; unsigned long long u; } v;
    v.d = x;
    return (long long)(v.u >> 32);
}
