/* Cross-checks cpu_instr.c's instr_decode() (decode()+decodef()) against
 * the real gpc/cpu_instr.coffee: every instruction's exact bit pattern
 * (with random field bits) plus fully-random hw1/hw2 pairs, which
 * exercise the mask-priority "most specific pattern wins" resolution
 * and the "no match" path.
 *
 * Fixtures regenerated via:
 *   node test/gen_cpu_instr_decode_fixtures.cjs > fixtures.json
 *   python3 test/gen_cpu_instr_decode_fixtures_header.py fixtures.json > test/cpu_instr_decode_fixtures.h
 */
#include <stdio.h>
#include <string.h>

#include "../src/cpu_instr.h"
#include "cpu_instr_decode_fixtures.h"

int main(void) {
    int failures = 0;
    int n = (int)(sizeof(DECODE_FIXTURES) / sizeof(DECODE_FIXTURES[0]));

    for (int i = 0; i < n; i++) {
        const DecodeFixture *fx = &DECODE_FIXTURES[i];
        DInstr v;
        const InstrDesc *desc = instr_decode(fx->hw1, fx->hw2, &v);

        if (!fx->matched) {
            if (desc) {
                printf("FAIL [%04x,%04x]: expected no match, got %s\n", fx->hw1, fx->hw2, desc->nm);
                failures++;
            }
            continue;
        }
        if (!desc) {
            printf("FAIL [%04x,%04x]: expected match %s, got no match\n", fx->hw1, fx->hw2, fx->nm);
            failures++;
            continue;
        }

        int ok = 1;
        if (strcmp(desc->nm, fx->nm) != 0) {
            printf("FAIL [%04x,%04x]: nm=%s expected %s\n", fx->hw1, fx->hw2, desc->nm, fx->nm);
            ok = 0;
        }
        if (v.niaIncr != fx->len) {
            printf("FAIL [%04x,%04x] %s: niaIncr=%d expected %d\n", fx->hw1, fx->hw2, fx->nm, v.niaIncr, fx->len);
            ok = 0;
        }
        if (v.extended != fx->extended) {
            printf("FAIL [%04x,%04x] %s: extended=%d expected %d\n", fx->hw1, fx->hw2, fx->nm, v.extended, fx->extended);
            ok = 0;
        }
        if (v.hasIa != fx->hasIa || (fx->hasIa && v.ia != fx->ia)) {
            printf("FAIL [%04x,%04x] %s: ia mismatch\n", fx->hw1, fx->hw2, fx->nm);
            ok = 0;
        }
        if (v.hasIi != fx->hasIi || (fx->hasIi && v.ii != fx->ii)) {
            printf("FAIL [%04x,%04x] %s: ii mismatch\n", fx->hw1, fx->hw2, fx->nm);
            ok = 0;
        }
        if (v.addrWidth != fx->addrWidth) {
            printf("FAIL [%04x,%04x] %s: addrWidth=%d expected %d\n", fx->hw1, fx->hw2, fx->nm, v.addrWidth, fx->addrWidth);
            ok = 0;
        }
        if (v.opType != fx->opType) {
            printf("FAIL [%04x,%04x] %s: opType=%d expected %d\n", fx->hw1, fx->hw2, fx->nm, v.opType, fx->opType);
            ok = 0;
        }
        for (int fi = 0; fi < fx->fieldCount; fi++) {
            char c = fx->fields[fi].c;
            if (!df_has(&v, c)) {
                printf("FAIL [%04x,%04x] %s: field '%c' missing\n", fx->hw1, fx->hw2, fx->nm, c);
                ok = 0;
                continue;
            }
            if (df_get(&v, c) != fx->fields[fi].val) {
                printf("FAIL [%04x,%04x] %s: field '%c' = %u expected %u\n",
                       fx->hw1, fx->hw2, fx->nm, c, df_get(&v, c), fx->fields[fi].val);
                ok = 0;
            }
        }
        /* No *extra* fields beyond what's expected. */
        for (int c = 0; c < DINSTR_FIELD_TABLE_SIZE; c++) {
            if (!v.present[c]) continue;
            int expected = 0;
            for (int fi = 0; fi < fx->fieldCount; fi++) {
                if (fx->fields[fi].c == (char)c) { expected = 1; break; }
            }
            if (!expected) {
                printf("FAIL [%04x,%04x] %s: unexpected extra field '%c' = %u\n", fx->hw1, fx->hw2, fx->nm, c, df_get(&v, (char)c));
                ok = 0;
            }
        }

        if (!ok) failures++;
    }

    printf("%d/%d decode fixtures passed\n", n - failures, n);
    return failures == 0 ? 0 : 1;
}
