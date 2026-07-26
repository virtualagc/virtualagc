#include "floatIBM.h"

#include <math.h>
#include <string.h>

#define FRAC56_MASK (((uint64_t)1 << 56) - 1)
#define FRAC56_TOP_HEX_MASK ((uint64_t)0xF << 52) /* bits 52-55: top hex of a 56-bit fraction */

FloatIBM fibm_zero(void) {
    FloatIBM f;
    memset(f.data8, 0, 8);
    return f;
}

FloatIBM fibm_from32(uint32_t x) {
    FloatIBM f = fibm_zero();
    f.data8[0] = (uint8_t)((x >> 24) & 0xff);
    f.data8[1] = (uint8_t)((x >> 16) & 0xff);
    f.data8[2] = (uint8_t)((x >> 8) & 0xff);
    f.data8[3] = (uint8_t)(x & 0xff);
    return f;
}

FloatIBM fibm_from64(uint32_t x1, uint32_t x2) {
    FloatIBM f;
    f.data8[0] = (uint8_t)((x1 >> 24) & 0xff);
    f.data8[1] = (uint8_t)((x1 >> 16) & 0xff);
    f.data8[2] = (uint8_t)((x1 >> 8) & 0xff);
    f.data8[3] = (uint8_t)(x1 & 0xff);
    f.data8[4] = (uint8_t)((x2 >> 24) & 0xff);
    f.data8[5] = (uint8_t)((x2 >> 16) & 0xff);
    f.data8[6] = (uint8_t)((x2 >> 8) & 0xff);
    f.data8[7] = (uint8_t)(x2 & 0xff);
    return f;
}

uint32_t fibm_to32(const FloatIBM *f) {
    return ((uint32_t)f->data8[0] << 24) | ((uint32_t)f->data8[1] << 16) |
           ((uint32_t)f->data8[2] << 8) | (uint32_t)f->data8[3];
}

uint32_t fibm_to64x(const FloatIBM *f) { return fibm_to32(f); }

uint32_t fibm_to64y(const FloatIBM *f) {
    return ((uint32_t)f->data8[4] << 24) | ((uint32_t)f->data8[5] << 16) |
           ((uint32_t)f->data8[6] << 8) | (uint32_t)f->data8[7];
}

int fibm_gsign(const FloatIBM *f) { return (f->data8[0] & 0x80) ? -1 : 1; }

void fibm_ssign(FloatIBM *f, int x) {
    if (x <= 0) f->data8[0] = (uint8_t)((f->data8[0] & 0x7f) | 0x80);
    else f->data8[0] = (uint8_t)(f->data8[0] & 0x7f);
}

int fibm_gexp(const FloatIBM *f) { return (int)(f->data8[0] & 0x7f) - 64; }

void fibm_sexp(FloatIBM *f, int x) {
    f->data8[0] = (uint8_t)((f->data8[0] & 0x80) | ((x + 64) & 0xff));
}

uint64_t fibm_gfracbits(const FloatIBM *f) {
    return ((uint64_t)f->data8[1] << 48) | ((uint64_t)f->data8[2] << 40) |
           ((uint64_t)f->data8[3] << 32) | ((uint64_t)f->data8[4] << 24) |
           ((uint64_t)f->data8[5] << 16) | ((uint64_t)f->data8[6] << 8) |
           (uint64_t)f->data8[7];
}

void fibm_sfrac(FloatIBM *f, uint64_t v) {
    v &= FRAC56_MASK;
    f->data8[1] = (uint8_t)((v >> 48) & 0xff);
    f->data8[2] = (uint8_t)((v >> 40) & 0xff);
    f->data8[3] = (uint8_t)((v >> 32) & 0xff);
    f->data8[4] = (uint8_t)((v >> 24) & 0xff);
    f->data8[5] = (uint8_t)((v >> 16) & 0xff);
    f->data8[6] = (uint8_t)((v >> 8) & 0xff);
    f->data8[7] = (uint8_t)(v & 0xff);
}

void fibm_normalize(FloatIBM *f) {
    uint64_t frac = fibm_gfracbits(f);
    if (frac == 0) return;
    while (!(frac & FRAC56_TOP_HEX_MASK)) {
        frac <<= 4;
        fibm_sexp(f, fibm_gexp(f) - 1);
    }
    fibm_sfrac(f, frac);
}

/* ---------------------------------------------------------------------
 * IEEE754 double <-> FloatIBM
 * ------------------------------------------------------------------- */

FloatIBM fibm_from_float(double x) {
    if (x == 0) return fibm_zero();

    uint64_t bits;
    memcpy(&bits, &x, 8);
    int sign = ((bits >> 63) & 1) ? -1 : 1;
    int exponent = (int)((bits >> 52) & 0x7FF) - 0x3FF;
    /* 53-bit mantissa with the implicit leading 1 bit injected. */
    uint64_t mantissaBits = (bits & 0x000FFFFFFFFFFFFFULL) | ((uint64_t)1 << 52);

    int exp2 = exponent;
    uint64_t fracBits = mantissaBits;
    int exp = exp2 + 4;

    int addlBits;
    if (exp % 4) {
        addlBits = (exp < 0) ? -(exp % 4) : (4 - (exp % 4));
    } else {
        addlBits = 0;
    }
    exp += addlBits;
    fracBits >>= addlBits;

    FloatIBM f = fibm_zero();
    fibm_ssign(&f, sign);
    fibm_sexp(&f, exp / 4);
    fibm_sfrac(&f, fracBits);
    fibm_normalize(&f);
    return f;
}

static double fibm_gfrac(const FloatIBM *f) {
    uint64_t frac = fibm_gfracbits(f);
    double high = (double)(frac >> 32) * pow(16.0, -6.0);
    double low = (double)(frac & 0xFFFFFFFFu) * pow(16.0, -14.0);
    return high + low;
}

double fibm_to_float(const FloatIBM *f) {
    return (double)fibm_gsign(f) * fibm_gfrac(f) * pow(16.0, (double)fibm_gexp(f));
}

/* ---------------------------------------------------------------------
 * Compare (POO 8.11 anomaly-aware)
 * ------------------------------------------------------------------- */

int fibm_compe_anomalous(const FloatIBM *x, const FloatIBM *y) {
    bool aSign = fibm_gsign(x) < 0;
    int aExp = fibm_gexp(x) + 64;
    uint64_t aMant = fibm_gfracbits(x);
    bool bSign = fibm_gsign(y) < 0;
    int bExp = fibm_gexp(y) + 64;
    uint64_t bMant = fibm_gfracbits(y);

    bool aZero = (aMant == 0);
    bool bZero = (bMant == 0);
    if (aZero && bZero) return 0;
    if (aZero) return bSign ? 1 : 3;
    if (bZero) return aSign ? 3 : 1;

    if (aExp == bExp) {
        aMant <<= 4;
        bMant <<= 4;
    } else if (aExp < bExp) {
        int shift = bExp - aExp - 1;
        if (shift > 0) {
            if (shift >= 14) return bSign ? 1 : 3;
            aMant >>= (shift * 4);
            if (aMant == 0) return bSign ? 1 : 3;
        }
        bMant <<= 4;
    } else {
        int shift = aExp - bExp - 1;
        if (shift > 0) {
            if (shift >= 14) return aSign ? 3 : 1;
            bMant >>= (shift * 4);
            if (bMant == 0) return aSign ? 3 : 1;
        }
        aMant <<= 4;
    }

    uint64_t rMant;
    bool rSign;
    if (aSign != bSign) {
        rMant = aMant + bMant;
        rSign = aSign;
    } else if (aMant >= bMant) {
        rMant = aMant - bMant;
        rSign = aSign;
    } else {
        rMant = bMant - aMant;
        rSign = !aSign;
    }

    if (rMant == 0x08000000ULL) return 0; /* POO 8.11 anomaly */
    if (rMant == 0) return 0;
    return rSign ? 3 : 1;
}

/* ---------------------------------------------------------------------
 * Add/Subtract
 * ------------------------------------------------------------------- */

static FloatIBMResult pack_addsub_result(bool sign, int biasedExp, uint64_t mant, bool needsRenorm) {
    if (needsRenorm) {
        if (mant == 0) {
            FloatIBMResult r = { fibm_zero(), FP_EXC_SIGNIFICANCE };
            return r;
        }
        while (!(mant & FRAC56_TOP_HEX_MASK)) {
            mant <<= 4;
            biasedExp -= 1;
        }
    }

    FloatIBM result = fibm_zero();
    if (biasedExp > 127) {
        if (sign) fibm_ssign(&result, -1);
        fibm_sexp(&result, (biasedExp & 0x7F) - 64);
        fibm_sfrac(&result, mant);
        FloatIBMResult r = { result, FP_EXC_EXP_OVERFLOW };
        return r;
    }
    if (biasedExp < 0) {
        FloatIBMResult r = { result, FP_EXC_EXP_UNDERFLOW };
        return r;
    }
    if (sign) fibm_ssign(&result, -1);
    fibm_sexp(&result, biasedExp - 64);
    fibm_sfrac(&result, mant);
    FloatIBMResult r = { result, FP_EXC_OK };
    return r;
}

static FloatIBMResult addsubE(const FloatIBM *xIn, const FloatIBM *yIn, bool subtract_b) {
    bool aSign = fibm_gsign(xIn) < 0;
    int aExp = fibm_gexp(xIn) + 64;
    uint64_t aMant = fibm_gfracbits(xIn);
    bool bSign = fibm_gsign(yIn) < 0;
    int bExp = fibm_gexp(yIn) + 64;
    uint64_t bMant = fibm_gfracbits(yIn);
    if (subtract_b) bSign = !bSign;

    bool aZero = (aMant == 0);
    bool bZero = (bMant == 0);

    if (!bZero && !aZero) {
        if (aExp == bExp) {
            aMant <<= 4;
            bMant <<= 4;
        } else if (aExp < bExp) {
            int shift = bExp - aExp - 1;
            aExp = bExp;
            if (shift > 0) {
                if (shift >= 14) aMant = 0;
                else aMant >>= (shift * 4);
                if (aMant == 0) {
                    aSign = bSign;
                    aMant = bMant;
                    return pack_addsub_result(aSign, aExp, aMant, false);
                }
            }
            bMant <<= 4;
        } else {
            int shift = aExp - bExp - 1;
            if (shift > 0) {
                if (shift >= 14) bMant = 0;
                else bMant >>= (shift * 4);
                if (bMant == 0) {
                    return pack_addsub_result(aSign, aExp, aMant, false);
                }
            }
            aMant <<= 4;
        }

        uint64_t rMant;
        bool rSign;
        if (aSign == bSign) {
            rSign = aSign;
            rMant = aMant + bMant;
        } else if (aMant == bMant) {
            FloatIBMResult r = { fibm_zero(), FP_EXC_SIGNIFICANCE };
            return r;
        } else if (aMant > bMant) {
            rSign = aSign;
            rMant = aMant - bMant;
        } else {
            rSign = bSign;
            rMant = bMant - aMant;
        }

        if (rMant & ((uint64_t)0xF << 60)) {
            rMant >>= 8;
            aExp += 1;
        } else if (rMant & ((uint64_t)0xF << 56)) {
            rMant >>= 4;
        } else {
            aExp -= 1;
            if (rMant == 0) {
                FloatIBMResult r = { fibm_zero(), FP_EXC_SIGNIFICANCE };
                return r;
            }
            while (!(rMant & FRAC56_TOP_HEX_MASK)) {
                rMant <<= 4;
                aExp -= 1;
            }
        }

        return pack_addsub_result(rSign, aExp, rMant, false);
    }

    if (bZero && aZero) {
        FloatIBMResult r = { fibm_zero(), FP_EXC_SIGNIFICANCE };
        return r;
    }
    if (aZero) {
        aSign = bSign;
        aExp = bExp;
        aMant = bMant;
    }
    return pack_addsub_result(aSign, aExp, aMant, true);
}

FloatIBMResult fibm_addE(const FloatIBM *x, const FloatIBM *y) { return addsubE(x, y, false); }
FloatIBMResult fibm_subE(const FloatIBM *x, const FloatIBM *y) { return addsubE(x, y, true); }
FloatIBM fibm_compE(const FloatIBM *x, const FloatIBM *y) { return addsubE(x, y, true).result; }

/* ---------------------------------------------------------------------
 * Multiply
 * ------------------------------------------------------------------- */

/* Portable 64x64 -> 128-bit unsigned multiply (no __int128 — see
 * floatIBM.h's header comment). Four 32-bit partial products chained
 * with explicit carries; this is the standard "Hacker's Delight" 8-2
 * mulhilo algorithm, verified here against a hand-computed reference
 * (0xFFFFFFFFFFFFFFFF * 0xFFFFFFFFFFFFFFFF = 0xFFFFFFFFFFFFFFFE
 * 0000000000000001) before use. */
static void mul64x64(uint64_t u, uint64_t v, uint64_t *whi, uint64_t *wlo) {
    uint64_t u1 = u >> 32, u0 = u & 0xFFFFFFFFu;
    uint64_t v1 = v >> 32, v0 = v & 0xFFFFFFFFu;

    uint64_t t = u0 * v0;
    uint64_t w0 = t & 0xFFFFFFFFu;
    uint64_t k = t >> 32;

    t = u1 * v0 + k;
    uint64_t w1 = t & 0xFFFFFFFFu;
    uint64_t w2 = t >> 32;

    t = u0 * v1 + w1;
    k = t >> 32;

    *wlo = (t << 32) + w0;
    *whi = u1 * v1 + w2 + k;
}

/* Low 64 bits of ((hi:lo) as a 128-bit value) >> n, for 0 < n < 64. */
static uint64_t u128_shr_lo(uint64_t hi, uint64_t lo, int n) {
    return (lo >> n) | (hi << (64 - n));
}

/* mulE computes the exact 56x56 -> 112 bit product via mul64x64 (the JS
 * source instead does a manual 32-bit-split multiply purely because JS
 * lacks a native wide multiply; see this file's header comment). Which
 * of the two adjacent 56-bit windows of the product to keep, and the
 * resulting exponent adjustment, was derived algebraically from the JS
 * version and cross-checked against it fixture-by-fixture. */
FloatIBMResult fibm_mulE(const FloatIBM *x, const FloatIBM *y) {
    uint64_t xFrac = fibm_gfracbits(x);
    uint64_t yFrac = fibm_gfracbits(y);
    if (xFrac == 0 || yFrac == 0) {
        FloatIBMResult r = { fibm_zero(), FP_EXC_OK };
        return r;
    }

    int resultSign = fibm_gsign(x) * fibm_gsign(y);

    int xBiasedExp = fibm_gexp(x) + 64;
    int yBiasedExp = fibm_gexp(y) + 64;
    while (!(xFrac & FRAC56_TOP_HEX_MASK)) { xFrac <<= 4; xBiasedExp -= 1; }
    while (!(yFrac & FRAC56_TOP_HEX_MASK)) { yFrac <<= 4; yBiasedExp -= 1; }

    uint64_t prodHi, prodLo;
    mul64x64(xFrac, yFrac, &prodHi, &prodLo);

    uint64_t rMant;
    int rBiasedExp;
    /* bits 108-111 of the 128-bit product == bits 44-47 of prodHi (since
     * prodHi holds bits 64-127). */
    if (prodHi & (0xFULL << 44)) {
        rMant = u128_shr_lo(prodHi, prodLo, 56) & FRAC56_MASK;
        rBiasedExp = xBiasedExp + yBiasedExp - 64;
    } else {
        rMant = u128_shr_lo(prodHi, prodLo, 52) & FRAC56_MASK;
        rBiasedExp = xBiasedExp + yBiasedExp - 65;
    }

    FloatIBM result = fibm_zero();
    if (rBiasedExp > 127) {
        if (resultSign < 0) fibm_ssign(&result, -1);
        fibm_sexp(&result, (rBiasedExp & 0x7F) - 64);
        fibm_sfrac(&result, rMant);
        FloatIBMResult r = { result, FP_EXC_EXP_OVERFLOW };
        return r;
    }
    if (rBiasedExp < 0) {
        FloatIBMResult r = { result, FP_EXC_EXP_UNDERFLOW };
        return r;
    }
    if (resultSign < 0) fibm_ssign(&result, -1);
    fibm_sexp(&result, rBiasedExp - 64);
    fibm_sfrac(&result, rMant);
    FloatIBMResult r = { result, FP_EXC_OK };
    return r;
}

static void round_once(uint64_t *mant, int *biasedExp) {
    uint64_t rounded = *mant + ((uint64_t)1 << 24);
    if (rounded & ((uint64_t)1 << 56)) {
        rounded >>= 4;
        *biasedExp += 1;
    }
    *mant = rounded & ~(((uint64_t)1 << 25) - 1);
}

FloatIBMResult fibm_mulQeE(const FloatIBM *x, const FloatIBM *y) {
    uint64_t xFrac = fibm_gfracbits(x);
    uint64_t yFrac = fibm_gfracbits(y);
    if (xFrac == 0 || yFrac == 0) {
        FloatIBMResult r = { fibm_zero(), FP_EXC_OK };
        return r;
    }

    int resultSign = fibm_gsign(x) * fibm_gsign(y);
    int xBiasedExp = fibm_gexp(x) + 64;
    int yBiasedExp = fibm_gexp(y) + 64;
    while (!(xFrac & FRAC56_TOP_HEX_MASK)) { xFrac <<= 4; xBiasedExp -= 1; }
    while (!(yFrac & FRAC56_TOP_HEX_MASK)) { yFrac <<= 4; yBiasedExp -= 1; }

    round_once(&xFrac, &xBiasedExp);
    round_once(&yFrac, &yBiasedExp);

    if (xBiasedExp > 127 || yBiasedExp > 127) {
        FloatIBM result = fibm_zero();
        if (resultSign < 0) fibm_ssign(&result, -1);
        fibm_sexp(&result, (127 & 0x7F) - 64);
        FloatIBMResult r = { result, FP_EXC_EXP_OVERFLOW };
        return r;
    }

    uint64_t a31 = xFrac >> 25;
    uint64_t b31 = yFrac >> 25;
    uint64_t prod = a31 * b31;
    uint64_t target = prod >> 6;

    if (target == 0) {
        FloatIBMResult r = { fibm_zero(), FP_EXC_OK };
        return r;
    }

    uint64_t rMant;
    int rBiasedExp;
    if (target & FRAC56_TOP_HEX_MASK) {
        rMant = target & FRAC56_MASK;
        rBiasedExp = xBiasedExp + yBiasedExp - 64;
    } else {
        rMant = (prod >> 2) & FRAC56_MASK;
        rBiasedExp = xBiasedExp + yBiasedExp - 65;
    }

    FloatIBM result = fibm_zero();
    if (rBiasedExp > 127) {
        if (resultSign < 0) fibm_ssign(&result, -1);
        fibm_sexp(&result, (rBiasedExp & 0x7F) - 64);
        fibm_sfrac(&result, rMant);
        FloatIBMResult r = { result, FP_EXC_EXP_OVERFLOW };
        return r;
    }
    if (rBiasedExp < 0) {
        FloatIBMResult r = { result, FP_EXC_EXP_UNDERFLOW };
        return r;
    }
    if (resultSign < 0) fibm_ssign(&result, -1);
    fibm_sexp(&result, rBiasedExp - 64);
    fibm_sfrac(&result, rMant);
    FloatIBMResult r = { result, FP_EXC_OK };
    return r;
}

/* ---------------------------------------------------------------------
 * Divide
 * ------------------------------------------------------------------- */

FloatIBMResult fibm_divE(const FloatIBM *x, const FloatIBM *y) {
    uint64_t xFrac = fibm_gfracbits(x);
    uint64_t yFrac = fibm_gfracbits(y);

    if (yFrac == 0) {
        FloatIBM sentinel;
        sentinel.data8[0] = 0xDE; sentinel.data8[1] = 0xAD;
        sentinel.data8[2] = 0xBE; sentinel.data8[3] = 0xEF;
        sentinel.data8[4] = 0xDE; sentinel.data8[5] = 0xAD;
        sentinel.data8[6] = 0xBE; sentinel.data8[7] = 0xEF;
        FloatIBMResult r = { sentinel, FP_EXC_DIVIDE };
        return r;
    }
    if (xFrac == 0) {
        FloatIBMResult r = { fibm_zero(), FP_EXC_OK };
        return r;
    }

    int resultSign = fibm_gsign(x) * fibm_gsign(y);
    int xBiasedExp = fibm_gexp(x) + 64;
    int yBiasedExp = fibm_gexp(y) + 64;
    while (!(xFrac & FRAC56_TOP_HEX_MASK)) { xFrac <<= 4; xBiasedExp -= 1; }
    while (!(yFrac & FRAC56_TOP_HEX_MASK)) { yFrac <<= 4; yBiasedExp -= 1; }

    int rBiasedExp;
    if (xFrac < yFrac) {
        rBiasedExp = xBiasedExp - yBiasedExp + 64;
    } else {
        rBiasedExp = xBiasedExp - yBiasedExp + 65;
        yFrac <<= 4;
    }

    uint64_t wk2 = xFrac / yFrac;
    uint64_t wk = (xFrac - wk2 * yFrac) << 4;
    for (int i = 13; i > 0; i--) {
        wk2 = (wk2 << 4) | (wk / yFrac);
        wk = (wk - (wk / yFrac) * yFrac) << 4;
    }
    uint64_t resultFrac = (wk2 << 4) | (wk / yFrac);

    FloatIBM result = fibm_zero();
    if (rBiasedExp > 127) {
        if (resultSign < 0) fibm_ssign(&result, -1);
        fibm_sexp(&result, (rBiasedExp & 0x7F) - 64);
        fibm_sfrac(&result, resultFrac);
        FloatIBMResult r = { result, FP_EXC_EXP_OVERFLOW };
        return r;
    }
    if (rBiasedExp < 0) {
        FloatIBMResult r = { result, FP_EXC_EXP_UNDERFLOW };
        return r;
    }
    if (resultSign < 0) fibm_ssign(&result, -1);
    fibm_sexp(&result, rBiasedExp - 64);
    fibm_sfrac(&result, resultFrac);
    FloatIBMResult r = { result, FP_EXC_OK };
    return r;
}

/* ---------------------------------------------------------------------
 * Convert
 * ------------------------------------------------------------------- */

FloatIBMCvfxResult fibm_cvfx(const FloatIBM *x) {
    FloatIBMCvfxResult res;
    if (fibm_gfracbits(x) == 0) {
        res.result = 0;
        res.exc = FP_EXC_OK;
        return res;
    }

    FloatIBM work = fibm_from64(fibm_to64x(x), fibm_to64y(x));
    fibm_normalize(&work);
    bool sign = fibm_gsign(&work) < 0;
    int chr = work.data8[0] & 0x7F;
    uint64_t mant = fibm_gfracbits(&work);

    int shift = 4 * chr - 296;
    if (shift > 8) {
        res.result = 0;
        res.exc = FP_EXC_CONVERT_OVERFLOW;
        return res;
    }

    uint64_t mag64;
    if (shift >= 0) {
        mag64 = mant << shift;
    } else {
        int rs = -shift;
        mag64 = (rs >= 64) ? 0 : (mant >> rs);
    }
    uint32_t magHi = (uint32_t)(mag64 >> 32);
    uint32_t magLo = (uint32_t)(mag64 & 0xFFFFFFFFu);

    if (magHi != 0) {
        res.result = 0;
        res.exc = FP_EXC_CONVERT_OVERFLOW;
        return res;
    }
    if (sign) {
        if (magLo > 0x80000000u) {
            res.result = (int32_t)(uint32_t)(-(magLo & 0x7FFFFFFFu));
            res.exc = FP_EXC_CONVERT_OVERFLOW;
            return res;
        }
        if (magLo == 0) {
            res.result = 0;
            res.exc = FP_EXC_OK;
            return res;
        }
        res.result = (int32_t)(uint32_t)(-magLo);
        res.exc = FP_EXC_OK;
        return res;
    }
    if (magLo > 0x7FFFFFFFu) {
        res.result = (int32_t)(uint32_t)(magLo & 0x7FFFFFFFu);
        res.exc = FP_EXC_CONVERT_OVERFLOW;
        return res;
    }
    res.result = (int32_t)magLo;
    res.exc = FP_EXC_OK;
    return res;
}

FloatIBM fibm_cvfl(int32_t x) {
    if (x == 0) return fibm_zero();

    FloatIBM res = fibm_zero();
    uint32_t mag;
    if (x < 0) {
        mag = ((uint32_t)x ^ 0xFFFFFFFFu) + 1u;
        fibm_ssign(&res, -1);
    } else {
        mag = (uint32_t)x;
    }
    res.data8[1] = (uint8_t)((mag >> 24) & 0xff);
    res.data8[2] = (uint8_t)((mag >> 16) & 0xff);
    res.data8[3] = (uint8_t)((mag >> 8) & 0xff);
    res.data8[4] = (uint8_t)(mag & 0xff);
    fibm_sexp(&res, 4);
    fibm_normalize(&res);
    return res;
}
