/* Cross-checks regmem.c (Register/RegisterFile/ProgramStatusWord) against
 * the real gpc/regmem.coffee.
 *
 * Fixtures regenerated via:
 *   node test/gen_regmem_fixtures.cjs > fixtures.json
 *   python3 test/gen_regmem_fixtures_header.py fixtures.json > test/regmem_fixtures.h
 */
#include <stdio.h>
#include <string.h>

#include "../src/regmem.h"
#include "regmem_fixtures.h"

static const char *GETTER_NAMES[] = {
    "getNIA", "getCC", "getCarry", "getOverflow", "getFixedPtOverflow",
    "getExponentUnderflow", "getSignificanceMask", "getBSR", "getDSR",
    "getIntMask", "getRegSet", "getMachCheckMask", "getWaitState",
    "getProblemState", "getIntCode",
};

static uint32_t call_getter(const ProgramStatusWord *p, int idx) {
    switch (idx) {
        case 0: return psw_get_nia(p);
        case 1: return psw_get_cc(p);
        case 2: return psw_get_carry(p);
        case 3: return psw_get_overflow(p);
        case 4: return psw_get_fixed_pt_overflow(p);
        case 5: return psw_get_exponent_underflow(p);
        case 6: return psw_get_significance_mask(p);
        case 7: return psw_get_bsr(p);
        case 8: return psw_get_dsr(p);
        case 9: return psw_get_int_mask(p);
        case 10: return psw_get_reg_set(p);
        case 11: return psw_get_mach_check_mask(p);
        case 12: return (uint32_t)psw_get_wait_state(p);
        case 13: return (uint32_t)psw_get_problem_state(p);
        case 14: return psw_get_int_code(p);
    }
    return 0xdeadbeef;
}

static void call_setter(ProgramStatusWord *p, const char *name, uint32_t val) {
    if (!strcmp(name, "setNIA")) psw_set_nia(p, val);
    else if (!strcmp(name, "setCC")) psw_set_cc(p, val);
    else if (!strcmp(name, "setCarry")) psw_set_carry(p, val);
    else if (!strcmp(name, "setOverflow")) psw_set_overflow(p, val);
    else if (!strcmp(name, "setFixedPtOverflow")) psw_set_fixed_pt_overflow(p, val);
    else if (!strcmp(name, "setExponentUnderflow")) psw_set_exponent_underflow(p, val);
    else if (!strcmp(name, "setSignificanceMask")) psw_set_significance_mask(p, val);
    else if (!strcmp(name, "setBSR")) psw_set_bsr(p, val);
    else if (!strcmp(name, "setDSR")) psw_set_dsr(p, val);
    else if (!strcmp(name, "setIntMask")) psw_set_int_mask(p, val);
    else if (!strcmp(name, "setRegSet")) psw_set_reg_set(p, val);
    else if (!strcmp(name, "setMachCheckMask")) psw_set_mach_check_mask(p, val);
    else if (!strcmp(name, "setWaitState")) psw_set_wait_state(p, (int)val);
    else if (!strcmp(name, "setProblemState")) psw_set_problem_state(p, (int)val);
    else if (!strcmp(name, "setIntCode")) psw_set_int_code(p, val);
    else printf("unknown setter %s\n", name);
}

int main(void) {
    int failures = 0;

    int nr = (int)(sizeof(REGISTER_FIXTURES) / sizeof(REGISTER_FIXTURES[0]));
    for (int i = 0; i < nr; i++) {
        const RegisterFixture *fx = &REGISTER_FIXTURES[i];
        Register r;
        register_init(&r);
        if (!strcmp(fx->op, "set32")) register_set32(&r, fx->v);
        else register_set16(&r, fx->v);
        if (register_get32(&r) != fx->get32 || register_get16(&r) != fx->get16) {
            printf("FAIL Register %s(%u): get32=%u(exp %u) get16=%u(exp %u)\n",
                   fx->op, fx->v, register_get32(&r), fx->get32, register_get16(&r), fx->get16);
            failures++;
        }
    }

    int nb = (int)(sizeof(BIT_FIXTURES) / sizeof(BIT_FIXTURES[0]));
    for (int i = 0; i < nb; i++) {
        const BitFixture *fx = &BIT_FIXTURES[i];
        if (fx->hasGet) {
            Register r; register_init(&r); register_set32(&r, fx->v);
            uint32_t got = register_getbit32(&r, fx->b);
            if (got != fx->get) { printf("FAIL getbit32(%u,%d): %u != %u\n", fx->v, fx->b, got, fx->get); failures++; }
        }
        if (fx->hasSet1) {
            Register r; register_init(&r); register_set32(&r, fx->v);
            register_setbit32(&r, fx->b, 1);
            if (register_get32(&r) != fx->set1) { printf("FAIL setbit32(%u,%d,1): %u != %u\n", fx->v, fx->b, register_get32(&r), fx->set1); failures++; }
        }
        if (fx->hasSet0) {
            Register r; register_init(&r); register_set32(&r, fx->v);
            register_setbit32(&r, fx->b, 0);
            if (register_get32(&r) != fx->set0) { printf("FAIL setbit32(%u,%d,0): %u != %u\n", fx->v, fx->b, register_get32(&r), fx->set0); failures++; }
        }
    }

    int nd = (int)(sizeof(DSE_FIXTURES) / sizeof(DSE_FIXTURES[0]));
    RegisterFile rf = registerfile_create(8);
    for (int i = 0; i < nd; i++) {
        const DseFixture *fx = &DSE_FIXTURES[i];
        registerfile_set_dse(&rf, fx->base, fx->val);
        uint32_t got = registerfile_get_dse(&rf, fx->base);
        if (got != fx->dse) {
            printf("FAIL DSE base=%d val=%u: %u != %u\n", fx->base, fx->val, got, fx->dse);
            failures++;
        }
    }
    registerfile_free(&rf);

    int ng = (int)(sizeof(GETTER_NAMES) / sizeof(GETTER_NAMES[0]));
    int npsw = (int)(sizeof(PSW_FIXTURES) / sizeof(PSW_FIXTURES[0]));
    for (int i = 0; i < npsw; i++) {
        const PswFixture *fx = &PSW_FIXTURES[i];
        ProgramStatusWord p;
        psw_init(&p);
        psw_load(&p, fx->p1, fx->p2);
        for (int g = 0; g < ng; g++) {
            uint32_t got = call_getter(&p, g);
            if (got != fx->getters[g]) {
                printf("FAIL PSW(%u,%u).%s(): %u != %u\n", fx->p1, fx->p2, GETTER_NAMES[g], got, fx->getters[g]);
                failures++;
            }
        }
    }

    int ns = (int)(sizeof(PSW_SETTER_FIXTURES) / sizeof(PSW_SETTER_FIXTURES[0]));
    for (int i = 0; i < ns; i++) {
        const PswSetterFixture *fx = &PSW_SETTER_FIXTURES[i];
        ProgramStatusWord p;
        psw_init(&p);
        psw_load(&p, fx->p1, fx->p2);
        call_setter(&p, fx->setter, fx->val);
        uint32_t gotP1 = register_get32(&p.psw1);
        uint32_t gotP2 = register_get32(&p.psw2);
        if (gotP1 != fx->psw1 || gotP2 != fx->psw2) {
            printf("FAIL PSW(%u,%u).%s(%u): psw1=%u(exp %u) psw2=%u(exp %u)\n",
                   fx->p1, fx->p2, fx->setter, fx->val, gotP1, fx->psw1, gotP2, fx->psw2);
            failures++;
        }
    }

    int total = nr + nb * 0 /* counted separately below */;
    (void)total;
    int bitChecks = 0;
    for (int i = 0; i < nb; i++) {
        bitChecks += BIT_FIXTURES[i].hasGet + BIT_FIXTURES[i].hasSet1 + BIT_FIXTURES[i].hasSet0;
    }
    int grand = nr + bitChecks + nd + npsw * ng + ns;
    printf("%d/%d regmem fixtures passed\n", grand - failures, grand);
    return failures == 0 ? 0 : 1;
}
