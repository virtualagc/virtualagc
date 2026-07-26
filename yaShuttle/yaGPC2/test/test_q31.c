/* Cross-checks q31.c against the real gpc/q31.coffee (BigInt-based),
 * including edge cases designed to hit signed-overflow-adjacent paths
 * (e.g. INT32_MIN operands, divisor of -1) that a naive int64_t port
 * could mishandle.
 *
 * Fixtures regenerated via:
 *   node test/gen_q31_fixtures.cjs > fixtures.json
 *   python3 test/gen_q31_fixtures_header.py fixtures.json > test/q31_fixtures.h
 */
#include <stdio.h>

#include "../src/q31.h"
#include "q31_fixtures.h"

int main(void) {
    int failures = 0;

    int nm = (int)(sizeof(MUL_FIXTURES) / sizeof(MUL_FIXTURES[0]));
    for (int i = 0; i < nm; i++) {
        const MulFixture *fx = &MUL_FIXTURES[i];
        Q31MulResult r = q31_mul32(fx->a, fx->b);
        if (r.hi != fx->hi || r.lo != fx->lo || r.overflow != fx->overflow) {
            printf("FAIL q31_mul32(%d,%d): got hi=%u lo=%u ov=%d expected hi=%u lo=%u ov=%d\n",
                   fx->a, fx->b, r.hi, r.lo, r.overflow, fx->hi, fx->lo, fx->overflow);
            failures++;
        }
    }

    int nq = (int)(sizeof(Q15_FIXTURES) / sizeof(Q15_FIXTURES[0]));
    for (int i = 0; i < nq; i++) {
        const Q15Fixture *fx = &Q15_FIXTURES[i];
        Q15MulResult r = q15_mul(fx->a, fx->b);
        if (r.result != fx->result || r.overflow != fx->overflow) {
            printf("FAIL q15_mul(%d,%d): got result=%d ov=%d expected result=%d ov=%d\n",
                   fx->a, fx->b, r.result, r.overflow, fx->result, fx->overflow);
            failures++;
        }
    }

    int nd = (int)(sizeof(DIV_FIXTURES) / sizeof(DIV_FIXTURES[0]));
    for (int i = 0; i < nd; i++) {
        const DivFixture *fx = &DIV_FIXTURES[i];
        Q31DivResult r = q31_div(fx->hi, fx->lo, fx->d);
        if (r.quotient != fx->quotient || r.overflow != fx->overflow) {
            printf("FAIL q31_div(%d,%d,%d): got q=%d ov=%d expected q=%d ov=%d\n",
                   fx->hi, fx->lo, fx->d, r.quotient, r.overflow, fx->quotient, fx->overflow);
            failures++;
        }
    }

    printf("%d/%d q31 fixtures passed\n", nm + nq + nd - failures, nm + nq + nd);
    return failures == 0 ? 0 : 1;
}
