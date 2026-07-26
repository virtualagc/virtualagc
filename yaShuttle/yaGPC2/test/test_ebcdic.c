/* Cross-checks ebcdic.c's tables against the real gpc/ebcdic.coffee,
 * byte-for-byte over all 256 entries in each direction.
 *
 * Fixtures regenerated via the inline node snippet in the Phase 1 dev
 * session (bundles gpc/ebcdic.coffee with esbuild-coffeescript, dumps
 * EBCDIC_TO_ASCII/ASCII_TO_EBCDIC as JSON, then a small python script
 * converts to ebcdic_fixtures.h). */
#include <stdio.h>

#include "../src/ebcdic.h"
#include "ebcdic_fixtures.h"

int main(void) {
    int failures = 0;
    for (int i = 0; i < 256; i++) {
        if (EBCDIC_TO_ASCII[i] != REF_EBCDIC_TO_ASCII[i]) {
            printf("FAIL EBCDIC_TO_ASCII[0x%02x]: %d != expected %d\n", i, EBCDIC_TO_ASCII[i], REF_EBCDIC_TO_ASCII[i]);
            failures++;
        }
        if (ASCII_TO_EBCDIC[i] != REF_ASCII_TO_EBCDIC[i]) {
            printf("FAIL ASCII_TO_EBCDIC[0x%02x]: %d != expected %d\n", i, ASCII_TO_EBCDIC[i], REF_ASCII_TO_EBCDIC[i]);
            failures++;
        }
    }
    printf("%d/%d ebcdic entries passed\n", 512 - failures, 512);
    return failures == 0 ? 0 : 1;
}
