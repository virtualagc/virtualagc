/* Cross-checks mcm.c/membus.c against the real gpc/mcm.coffee and
 * gpc/membus.coffee, including store-protect and a load16 that spans the
 * CPU/IOP boundary.
 *
 * Fixtures regenerated via:
 *   node test/gen_mcm_membus_fixtures.cjs > fixtures.json
 *   python3 test/gen_mcm_membus_fixtures_header.py fixtures.json > test/mcm_membus_fixtures.h
 */
#include <stdio.h>

#include "../src/mcm.h"
#include "../src/membus.h"
#include "mcm_membus_fixtures.h"

int main(void) {
    int failures = 0;

    /* --- MCM --- */
    MCM mcm = mcm_create(MCM_TEST_WORDCOUNT);
    int nm = (int)(sizeof(MCM_FIXTURES) / sizeof(MCM_FIXTURES[0]));
    for (int i = 0; i < nm; i++) {
        const McmFixture *fx = &MCM_FIXTURES[i];
        bool ok = fx->isSet32 ? mcm_set32(&mcm, fx->addr, fx->v, true) : mcm_set16(&mcm, fx->addr, fx->v, true);
        uint32_t after = fx->isSet32 ? mcm_get32(&mcm, fx->addr) : mcm_get16(&mcm, fx->addr);
        if (ok != fx->ok || after != fx->after) {
            printf("FAIL mcm %s(%u,%u): ok=%d(exp %d) after=%u(exp %u)\n",
                   fx->isSet32 ? "set32" : "set16", fx->addr, fx->v, ok, fx->ok, after, fx->after);
            failures++;
        }
    }

    int np = (int)(sizeof(PROTECT_FIXTURES) / sizeof(PROTECT_FIXTURES[0]));
    for (int i = 0; i < np; i++) {
        const ProtectFixture *fx = &PROTECT_FIXTURES[i];
        if (fx->hasProtWrite) {
            mcm_set_store_protect(&mcm, fx->addr, true);
            bool ok = mcm_set16(&mcm, fx->addr, 0xbeef, true);
            uint32_t after = mcm_get16(&mcm, fx->addr);
            bool prot = mcm_get_store_protect(&mcm, fx->addr);
            if (ok != fx->ok16 || after != fx->after16 || prot != fx->prot) {
                printf("FAIL protect addr=%u: ok=%d(exp %d) after=%u(exp %u) prot=%d(exp %d)\n",
                       fx->addr, ok, fx->ok16, after, fx->after16, prot, fx->prot);
                failures++;
            }
        } else if (fx->hasUnprotWrite) {
            mcm_set_store_protect(&mcm, fx->addr, false);
            bool ok = mcm_set16(&mcm, fx->addr, 0xcafe, true);
            uint32_t after = mcm_get16(&mcm, fx->addr);
            if (ok != fx->ok16Unprotected || after != fx->after16b) {
                printf("FAIL unprotect addr=%u: ok=%d(exp %d) after=%u(exp %u)\n",
                       fx->addr, ok, fx->ok16Unprotected, after, fx->after16b);
                failures++;
            }
        } else if (fx->hasSet32Block) {
            mcm_set_store_protect(&mcm, fx->addr32 + 1, true);
            bool ok = mcm_set32(&mcm, fx->addr32, 0x11223344, true);
            uint32_t after = mcm_get32(&mcm, fx->addr32);
            if (ok != fx->ok32BlockedBySecondHW || after != fx->val) {
                printf("FAIL set32-block addr=%u: ok=%d(exp %d) after=%u(exp %u)\n",
                       fx->addr32, ok, fx->ok32BlockedBySecondHW, after, fx->val);
                failures++;
            }
            mcm_set_store_protect(&mcm, fx->addr32 + 1, false);
        }
    }

    MCM mcm2 = mcm_create(MCM_TEST_WORDCOUNT);
    mcm_load16(&mcm2, 50, LOAD_BYTES, sizeof(LOAD_BYTES));
    int nl = (int)(sizeof(LOAD_RESULTS) / sizeof(LOAD_RESULTS[0]));
    for (int i = 0; i < nl; i++) {
        uint32_t got = mcm_get16(&mcm2, 45 + (uint32_t)i);
        if (got != LOAD_RESULTS[i]) {
            printf("FAIL load16 result[%d] (addr %d): %u != %u\n", i, 45 + i, got, LOAD_RESULTS[i]);
            failures++;
        }
    }
    mcm_free(&mcm2);
    mcm_free(&mcm);

    /* --- MemoryBus --- */
    MCM cpuMcm = mcm_create(40 * 1024);
    MCM iopMcm = mcm_create(24 * 1024);
    MemoryBus bus = membus_create(&cpuMcm, &iopMcm);

    int nb = (int)(sizeof(BUS_FIXTURES) / sizeof(BUS_FIXTURES[0]));
    for (int i = 0; i < nb; i++) {
        const BusFixture *fx = &BUS_FIXTURES[i];
        bool ok = fx->isSet32 ? membus_set32(&bus, fx->addr, fx->v, true) : membus_set16(&bus, fx->addr, fx->v, true);
        uint32_t after = fx->isSet32 ? membus_get32(&bus, fx->addr) : membus_get16(&bus, fx->addr);
        if (ok != fx->ok || after != fx->after) {
            printf("FAIL bus %s(%u,%u): ok=%d(exp %d) after=%u(exp %u)\n",
                   fx->isSet32 ? "set32" : "set16", fx->addr, fx->v, ok, fx->ok, after, fx->after);
            failures++;
        }
    }

    int nbp = (int)(sizeof(BUS_PROT_FIXTURES) / sizeof(BUS_PROT_FIXTURES[0]));
    for (int i = 0; i < nbp; i++) {
        const BusProtFixture *fx = &BUS_PROT_FIXTURES[i];
        membus_set_store_protect(&bus, fx->addr, true);
        bool ok = membus_set16(&bus, fx->addr, 0x4321, true);
        bool prot = membus_get_store_protect(&bus, fx->addr);
        uint32_t after = membus_get16(&bus, fx->addr);
        if (ok != fx->ok || prot != fx->prot || after != fx->after) {
            printf("FAIL bus-protect addr=%u: ok=%d(exp %d) prot=%d(exp %d) after=%u(exp %u)\n",
                   fx->addr, ok, fx->ok, prot, fx->prot, after, fx->after);
            failures++;
        }
        membus_set_store_protect(&bus, fx->addr, false);
    }

    membus_load16(&bus, BUS_LOAD_BASE, BUS_LOAD_BYTES, sizeof(BUS_LOAD_BYTES));
    int nbl = (int)(sizeof(BUS_LOAD_RESULTS) / sizeof(BUS_LOAD_RESULTS[0]));
    for (int i = 0; i < nbl; i++) {
        uint32_t addr = BUS_LOAD_BASE - 2 + (uint32_t)i;
        uint32_t got = membus_get16(&bus, addr);
        if (got != BUS_LOAD_RESULTS[i]) {
            printf("FAIL bus load16 result[%d] (addr %u): %u != %u\n", i, addr, got, BUS_LOAD_RESULTS[i]);
            failures++;
        }
    }

    mcm_free(&cpuMcm);
    mcm_free(&iopMcm);

    int grand = nm + np + nl + nb + nbp + nbl;
    printf("%d/%d mcm/membus fixtures passed\n", grand - failures, grand);
    return failures == 0 ? 0 : 1;
}
