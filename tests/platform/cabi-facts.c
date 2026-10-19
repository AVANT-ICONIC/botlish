/* cabi-facts.c -- the host C compiler's own answer to the questions
 * core/cabi.tcl's target table answers for the host target (C-ABI-TYPES.md):
 * the bit widths of the C integer scalars and pointers, whether plain char
 * is signed, and each scalar's own width and signedness (ffi::c's names),
 * with size_t's width beside them (no ffi::c scalar: unsigned long's on
 * every LP64 target, the pointer's on every target of the table). Printed as
 * one Tcl dict line, with the target table's own keys, for
 * tests/platform/cabi-facts.tcl to compare. A toolchain fact, not a Botlish
 * one: Botlish never compiles or runs this file. */
#include <limits.h>
#include <stddef.h>
#include <stdio.h>

#define BITS(T) ((int)(sizeof(T) * CHAR_BIT))
#define SIGNED(T) ((T)-1 < (T)0 ? 1 : 0)

int main(void) {
    printf("char %d short %d int %d long %d longlong %d pointer %d charSigned %d sizeT %d sizeTSigned %d",
           BITS(char), BITS(short), BITS(int), BITS(long), BITS(long long), BITS(void *),
           CHAR_MIN < 0 ? 1 : 0, BITS(size_t), SIGNED(size_t));
    printf(" scalars {Char {%d %d} SChar {%d %d} UChar {%d %d} Short {%d %d} UShort {%d %d} Int {%d %d}"
           " UInt {%d %d} Long {%d %d} ULong {%d %d} LongLong {%d %d} ULongLong {%d %d}}\n",
           BITS(char), SIGNED(char), BITS(signed char), SIGNED(signed char),
           BITS(unsigned char), SIGNED(unsigned char), BITS(short), SIGNED(short),
           BITS(unsigned short), SIGNED(unsigned short), BITS(int), SIGNED(int),
           BITS(unsigned int), SIGNED(unsigned int), BITS(long), SIGNED(long),
           BITS(unsigned long), SIGNED(unsigned long), BITS(long long), SIGNED(long long),
           BITS(unsigned long long), SIGNED(unsigned long long));
    return 0;
}
