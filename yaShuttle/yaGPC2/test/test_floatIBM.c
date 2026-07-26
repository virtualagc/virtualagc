/* Cross-checks floatIBM.c against the real gpc/floatIBM.coffee across
 * ~74,000 fixtures covering every exported operation: accessors,
 * normalize, compE_anomalous, addE/subE/mulE/mulQeE/divE (pairwise over
 * a mix of edge-case and random bit patterns, including deliberately
 * unnormalized operands), cvfx, cvfl, and setFromFloat/toFloat
 * round-trips.
 *
 * Fixtures regenerated via:
 *   node test/gen_floatIBM_fixtures.cjs > fixtures.json
 *   python3 test/gen_floatIBM_fixtures_header.py fixtures.json > test/floatIBM_fixtures.h
 */
#include <stdio.h>
#include <string.h>

#include "../src/floatIBM.h"
#include "floatIBM_fixtures.h"

static double bits_to_double(uint64_t bits) {
    double d;
    memcpy(&d, &bits, 8);
    return d;
}

static uint64_t double_to_bits(double d) {
    uint64_t bits;
    memcpy(&bits, &d, 8);
    return bits;
}

static int check_binop(const char *name, const BinOpFixture *fx, FloatIBMResult (*fn)(const FloatIBM *, const FloatIBM *)) {
    FloatIBM x = fibm_from64(fx->hi1, fx->lo1);
    FloatIBM y = fibm_from64(fx->hi2, fx->lo2);
    FloatIBMResult r = fn(&x, &y);
    uint32_t rHi = fibm_to64x(&r.result);
    uint32_t rLo = fibm_to64y(&r.result);
    if (r.exc != fx->exc || rHi != fx->resultHi || rLo != fx->resultLo) {
        printf("FAIL %s(%08x%08x, %08x%08x): exc=%d(exp %d) result=%08x%08x(exp %08x%08x)\n",
               name, fx->hi1, fx->lo1, fx->hi2, fx->lo2, r.exc, fx->exc, rHi, rLo, fx->resultHi, fx->resultLo);
        return 0;
    }
    return 1;
}

int main(void) {
    int failures = 0;
    long total = 0;

    int na = (int)(sizeof(ACCESSOR_FIXTURES) / sizeof(ACCESSOR_FIXTURES[0]));
    for (int i = 0; i < na; i++) {
        const AccessorFixture *fx = &ACCESSOR_FIXTURES[i];
        FloatIBM f = fibm_from64(fx->hi, fx->lo);
        uint64_t fb = fibm_gfracbits(&f);
        uint32_t fbHi = (uint32_t)(fb >> 32);
        uint32_t fbLo = (uint32_t)(fb & 0xFFFFFFFFu);
        total += 6;
        if (fibm_to32(&f) != fx->to32) { printf("FAIL to32(%08x%08x)\n", fx->hi, fx->lo); failures++; }
        if (fibm_to64x(&f) != fx->to64x) { printf("FAIL to64x(%08x%08x)\n", fx->hi, fx->lo); failures++; }
        if (fibm_to64y(&f) != fx->to64y) { printf("FAIL to64y(%08x%08x)\n", fx->hi, fx->lo); failures++; }
        if (fibm_gsign(&f) != fx->gSign) { printf("FAIL gSign(%08x%08x)\n", fx->hi, fx->lo); failures++; }
        if (fibm_gexp(&f) != fx->gExp) { printf("FAIL gExp(%08x%08x): %d != %d\n", fx->hi, fx->lo, fibm_gexp(&f), fx->gExp); failures++; }
        if (fbHi != fx->fbHi || fbLo != fx->fbLo) { printf("FAIL gFracBits(%08x%08x)\n", fx->hi, fx->lo); failures++; }
    }

    int nn = (int)(sizeof(NORMALIZE_FIXTURES) / sizeof(NORMALIZE_FIXTURES[0]));
    total += nn;
    for (int i = 0; i < nn; i++) {
        const NormalizeFixture *fx = &NORMALIZE_FIXTURES[i];
        FloatIBM f = fibm_from64(fx->hi, fx->lo);
        fibm_normalize(&f);
        if (fibm_to64x(&f) != fx->resultHi || fibm_to64y(&f) != fx->resultLo) {
            printf("FAIL normalize(%08x%08x): got %08x%08x exp %08x%08x\n",
                   fx->hi, fx->lo, fibm_to64x(&f), fibm_to64y(&f), fx->resultHi, fx->resultLo);
            failures++;
        }
    }

    int nc = (int)(sizeof(COMPE_FIXTURES) / sizeof(COMPE_FIXTURES[0]));
    total += nc;
    for (int i = 0; i < nc; i++) {
        const CompEFixture *fx = &COMPE_FIXTURES[i];
        FloatIBM x = fibm_from64(fx->hi1, fx->lo1);
        FloatIBM y = fibm_from64(fx->hi2, fx->lo2);
        int cc = fibm_compe_anomalous(&x, &y);
        if (cc != fx->cc) {
            printf("FAIL compE_anomalous(%08x%08x, %08x%08x): %d != %d\n", fx->hi1, fx->lo1, fx->hi2, fx->lo2, cc, fx->cc);
            failures++;
        }
    }

    int nAdd = (int)(sizeof(ADDE_FIXTURES) / sizeof(ADDE_FIXTURES[0]));
    total += nAdd;
    for (int i = 0; i < nAdd; i++) failures += !check_binop("addE", &ADDE_FIXTURES[i], fibm_addE);

    int nSub = (int)(sizeof(SUBE_FIXTURES) / sizeof(SUBE_FIXTURES[0]));
    total += nSub;
    for (int i = 0; i < nSub; i++) failures += !check_binop("subE", &SUBE_FIXTURES[i], fibm_subE);

    int nMul = (int)(sizeof(MULE_FIXTURES) / sizeof(MULE_FIXTURES[0]));
    total += nMul;
    for (int i = 0; i < nMul; i++) failures += !check_binop("mulE", &MULE_FIXTURES[i], fibm_mulE);

    int nMulQe = (int)(sizeof(MULQEE_FIXTURES) / sizeof(MULQEE_FIXTURES[0]));
    total += nMulQe;
    for (int i = 0; i < nMulQe; i++) failures += !check_binop("mulQeE", &MULQEE_FIXTURES[i], fibm_mulQeE);

    int nDiv = (int)(sizeof(DIVE_FIXTURES) / sizeof(DIVE_FIXTURES[0]));
    total += nDiv;
    for (int i = 0; i < nDiv; i++) failures += !check_binop("divE", &DIVE_FIXTURES[i], fibm_divE);

    int nCvfx = (int)(sizeof(CVFX_FIXTURES) / sizeof(CVFX_FIXTURES[0]));
    total += nCvfx;
    for (int i = 0; i < nCvfx; i++) {
        const CvfxFixture *fx = &CVFX_FIXTURES[i];
        FloatIBM x = fibm_from64(fx->hi, fx->lo);
        FloatIBMCvfxResult r = fibm_cvfx(&x);
        if (r.result != fx->result || r.exc != fx->exc) {
            printf("FAIL cvfx(%08x%08x): result=%d(exp %d) exc=%d(exp %d)\n",
                   fx->hi, fx->lo, r.result, fx->result, r.exc, fx->exc);
            failures++;
        }
    }

    int nCvfl = (int)(sizeof(CVFL_FIXTURES) / sizeof(CVFL_FIXTURES[0]));
    total += nCvfl;
    for (int i = 0; i < nCvfl; i++) {
        const CvflFixture *fx = &CVFL_FIXTURES[i];
        FloatIBM f = fibm_cvfl(fx->v);
        if (fibm_to64x(&f) != fx->resultHi || fibm_to64y(&f) != fx->resultLo) {
            printf("FAIL cvfl(%d): got %08x%08x exp %08x%08x\n", fx->v, fibm_to64x(&f), fibm_to64y(&f), fx->resultHi, fx->resultLo);
            failures++;
        }
    }

    int nRt = (int)(sizeof(FLOAT_RT_FIXTURES) / sizeof(FLOAT_RT_FIXTURES[0]));
    total += (long)nRt * 2;
    for (int i = 0; i < nRt; i++) {
        const FloatRTFixture *fx = &FLOAT_RT_FIXTURES[i];
        double v = bits_to_double(fx->vBits);
        FloatIBM f = fibm_from_float(v);
        int ok = 1;
        if (fibm_to64x(&f) != fx->resultHi || fibm_to64y(&f) != fx->resultLo) {
            printf("FAIL fibm_from_float(%.17g): got %08x%08x exp %08x%08x\n",
                   v, fibm_to64x(&f), fibm_to64y(&f), fx->resultHi, fx->resultLo);
            failures++;
            ok = 0;
        }
        double back = fibm_to_float(&f);
        if (ok && double_to_bits(back) != fx->backBits) {
            printf("FAIL toFloat() after fibm_from_float(%.17g): got %.17g exp %.17g\n", v, back, bits_to_double(fx->backBits));
            failures++;
        }
    }

    int nTf = (int)(sizeof(TOFLOAT_FIXTURES) / sizeof(TOFLOAT_FIXTURES[0]));
    total += nTf;
    for (int i = 0; i < nTf; i++) {
        const ToFloatFixture *fx = &TOFLOAT_FIXTURES[i];
        FloatIBM f = fibm_from64(fx->hi, fx->lo);
        double v = fibm_to_float(&f);
        if (double_to_bits(v) != fx->vBits) {
            printf("FAIL toFloat(%08x%08x): got %.17g exp %.17g\n", fx->hi, fx->lo, v, bits_to_double(fx->vBits));
            failures++;
        }
    }

    printf("%ld/%ld floatIBM fixtures passed\n", total - failures, total);
    return failures == 0 ? 0 : 1;
}
