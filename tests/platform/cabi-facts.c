/* cabi-facts.c -- the host C compiler's own answer to the questions
 * core/cabi.tcl's target table answers for the host target (C-ABI-TYPES.md):
 * the bit widths of the C integer scalars and pointers, and whether plain
 * char is signed. Printed as one Tcl dict line, with the target table's own
 * keys, for tests/platform/cabi-facts.tcl to compare. A toolchain fact, not
 * a Botlish one: Botlish never compiles or runs this file. */
#include <limits.h>
#include <stdio.h>

int main(void) {
    printf("char %d short %d int %d long %d longlong %d pointer %d charSigned %d\n",
           (int)(sizeof(char) * CHAR_BIT), (int)(sizeof(short) * CHAR_BIT),
           (int)(sizeof(int) * CHAR_BIT), (int)(sizeof(long) * CHAR_BIT),
           (int)(sizeof(long long) * CHAR_BIT), (int)(sizeof(void *) * CHAR_BIT),
           CHAR_MIN < 0 ? 1 : 0);
    return 0;
}
