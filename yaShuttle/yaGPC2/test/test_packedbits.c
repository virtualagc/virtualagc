/* Cross-checks pb_make_desc() (src/util.c) against reference values
 * computed by the real gpc/util.coffee PackedBits, over every distinct
 * instruction-descriptor string used across cpu_instr.coffee,
 * iop_bce_instr.coffee, and iop_msc_instr.coffee, plus the two
 * ProgramStatusWord field descriptors from regmem.coffee.
 *
 * Fixtures are regenerated via:
 *   node test/gen_packedbits_fixtures.cjs <descriptor-list> > fixtures.json
 *   python3 test/gen_fixtures_header.py fixtures.json > test/packedbits_fixtures.h
 */
#include <stdio.h>
#include <string.h>

#include "../src/util.h"
#include "packedbits_fixtures.h"

static const char *type_name(PBType t) {
    switch (t) {
        case PB_TYPE_RR: return "RR";
        case PB_TYPE_SRS: return "SRS";
        case PB_TYPE_RS: return "RS";
        case PB_TYPE_SI: return "SI";
        case PB_TYPE_RI: return "RI";
        default: return "NONE";
    }
}

int main(void) {
    int n = (int)(sizeof(PB_FIXTURES) / sizeof(PB_FIXTURES[0]));
    int failures = 0;

    for (int i = 0; i < n; i++) {
        const PBFixture *fx = &PB_FIXTURES[i];
        PBDesc d = pb_make_desc(fx->d);
        int ok = 1;

        if (d.len != fx->len) {
            printf("FAIL %s: len %d != expected %d\n", fx->d, d.len, fx->len);
            ok = 0;
        }
        if (strcmp(type_name(d.type), fx->type) != 0) {
            printf("FAIL %s: type %s != expected %s\n", fx->d, type_name(d.type), fx->type);
            ok = 0;
        }
        if (d.mask != fx->mask) {
            printf("FAIL %s: mask %u != expected %u\n", fx->d, d.mask, fx->mask);
            ok = 0;
        }
        if (d.maskedVal != fx->maskedVal) {
            printf("FAIL %s: maskedVal %u != expected %u\n", fx->d, d.maskedVal, fx->maskedVal);
            ok = 0;
        }
        if (d.origLen != d.len) {
            printf("FAIL %s: origLen %d != len %d\n", fx->d, d.origLen, d.len);
            ok = 0;
        }

        for (int fi = 0; fi < fx->fieldCount; fi++) {
            unsigned char c = (unsigned char)fx->fieldChars[fi];
            const PBField *f = &d.field[c];
            if (!f->present) {
                printf("FAIL %s: field '%c' missing\n", fx->d, c);
                ok = 0;
                continue;
            }
            if (f->mask != fx->fieldMask[fi]) {
                printf("FAIL %s: field '%c' mask %u != expected %u\n", fx->d, c, f->mask, fx->fieldMask[fi]);
                ok = 0;
            }
            if (f->shift != fx->fieldShift[fi]) {
                printf("FAIL %s: field '%c' shift %d != expected %d\n", fx->d, c, f->shift, fx->fieldShift[fi]);
                ok = 0;
            }
            if (f->bitlen != fx->fieldBitlen[fi]) {
                printf("FAIL %s: field '%c' bitlen %d != expected %d\n", fx->d, c, f->bitlen, fx->fieldBitlen[fi]);
                ok = 0;
            }
        }

        /* Also check no *extra* fields are present beyond the expected set. */
        for (int c = 0; c < PB_FIELD_TABLE_SIZE; c++) {
            if (!d.field[c].present) continue;
            int expected = 0;
            for (int fi = 0; fi < fx->fieldCount; fi++) {
                if ((unsigned char)fx->fieldChars[fi] == c) { expected = 1; break; }
            }
            if (!expected) {
                printf("FAIL %s: unexpected extra field '%c'\n", fx->d, c);
                ok = 0;
            }
        }

        if (!ok) failures++;
    }

    printf("%d/%d PackedBits fixtures passed\n", n - failures, n);
    return failures == 0 ? 0 : 1;
}
