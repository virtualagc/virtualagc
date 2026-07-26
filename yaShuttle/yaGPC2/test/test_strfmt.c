/* Cross-checks str_lpad/str_rpad/as_hex (src/strfmt.c) against reference
 * values computed by the real com/util.coffee.
 *
 * Fixtures are regenerated via:
 *   node test/gen_strfmt_fixtures.cjs > fixtures.json
 *   python3 test/gen_strfmt_fixtures_header.py fixtures.json > test/strfmt_fixtures.h
 */
#include <stdio.h>
#include <string.h>

#include "../src/strfmt.h"
#include "strfmt_fixtures.h"

int main(void) {
    int failures = 0;
    char out[256];

    int nl = (int)(sizeof(LPAD_FIXTURES) / sizeof(LPAD_FIXTURES[0]));
    for (int i = 0; i < nl; i++) {
        const PadFixture *fx = &LPAD_FIXTURES[i];
        str_lpad(out, sizeof(out), fx->s, fx->pad, fx->len);
        if (strcmp(out, fx->expect) != 0) {
            printf("FAIL lpad(%s,%s,%d): got %s expected %s\n", fx->s, fx->pad, fx->len, out, fx->expect);
            failures++;
        }
    }

    int nr = (int)(sizeof(RPAD_FIXTURES) / sizeof(RPAD_FIXTURES[0]));
    for (int i = 0; i < nr; i++) {
        const PadFixture *fx = &RPAD_FIXTURES[i];
        str_rpad(out, sizeof(out), fx->s, fx->pad, fx->len);
        if (strcmp(out, fx->expect) != 0) {
            printf("FAIL rpad(%s,%s,%d): got %s expected %s\n", fx->s, fx->pad, fx->len, out, fx->expect);
            failures++;
        }
    }

    int nh = (int)(sizeof(HEX_FIXTURES) / sizeof(HEX_FIXTURES[0]));
    for (int i = 0; i < nh; i++) {
        const HexFixture *fx = &HEX_FIXTURES[i];
        as_hex(out, sizeof(out), fx->v, fx->len);
        if (strcmp(out, fx->expect) != 0) {
            printf("FAIL asHex(%lld,%d): got %s expected %s\n", fx->v, fx->len, out, fx->expect);
            failures++;
        }
    }

    printf("%d/%d strfmt fixtures passed\n", nl + nr + nh - failures, nl + nr + nh);
    return failures == 0 ? 0 : 1;
}
