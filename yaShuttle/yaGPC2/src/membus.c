#include <stdio.h>
#include <stdlib.h>
#include "membus.h"

#include "envcache.h"
MemoryBus membus_create(MCM *mcm) {
    MemoryBus b;
    b.mcm = mcm;
    b.totalHWCount = (uint32_t)mcm->wordCount * 2;
    b.addrMask = b.totalHWCount - 1;
    return b;
}

uint32_t membus_get16(const MemoryBus *b, uint32_t addr) {
    return mcm_get16(b->mcm, addr & b->addrMask);
}

uint32_t membus_get32(const MemoryBus *b, uint32_t addr) {
    return mcm_get32(b->mcm, addr & b->addrMask);
}

bool membus_set16(MemoryBus *b, uint32_t addr, uint32_t v, bool checkProtect) {
    return mcm_set16(b->mcm, addr & b->addrMask, v, checkProtect);
}

bool membus_set32(MemoryBus *b, uint32_t addr, uint32_t v, bool checkProtect) {
    return mcm_set32(b->mcm, addr & b->addrMask, v, checkProtect);
}

void membus_load16(MemoryBus *b, uint32_t base, const uint8_t *bytes, size_t byteLen) {
    size_t hwCount = byteLen / 2;
    for (size_t i = 0; i < hwCount; i++) {
        uint32_t v = ((uint32_t)bytes[i * 2] << 8) | bytes[i * 2 + 1];
        membus_set16(b, base + (uint32_t)i, v, false);
    }
}

/* PSA locations the POO (AP-101S-instruction-set.txt 2.5.2, "Preferred
 * Storage Area (PSA) Assignments") says "must not be store protected":
 *
 *   1. Power off interrupt PSW          2. All old PSW locations
 *   3. BCE 25 processor storage 00A4-00A5
 *   4. Counter 1 and 2 high halfwords 00B0 and 00B1
 *   5. Putaway locations 00C0-0102      6. Diagnostics 0104-013F
 *
 * That is a property of the MACHINE, not of whoever last loaded memory, so
 * it belongs here rather than in one loader's setup: the hardware itself
 * writes these constantly -- every interrupt saves the old PSW, every
 * Clock 1/2 underflow reloads from the counter halfwords -- and no program
 * has to unprotect them first.
 *
 * It used to be applied only by the AGE harness's ipl_fill(), i.e. only on
 * the --ipl path.  A tape boot got none of it, because there the real
 * loader runs and applies each load block's own protect flag over the top
 * of the PSA.  The cost was not subtle: FIOSVC1's store to 00007 (the
 * power-off PSW area) and stores to 00B0/00B1 were refused, and a store
 * protect taken inside the Clock 2 handler stopped FPMIHPC2 before its
 * CALL FPMITUPD -- the only code that re-arms Clock 2.  With no 40 ms
 * tick no TQE can expire, so the mass-memory monitor never runs again, an
 * overlay read is never completed, and an OPS transition hangs after the
 * phase it was loading.  See HANDOFF-OPS9.md. */
static bool psa_must_not_protect(uint32_t hw) {
    if (hw <= 0x0007) return true;            /* power off interrupt PSW */
    if (hw >= 0x00a4 && hw <= 0x00a5) return true;   /* BCE 25 storage */
    if (hw >= 0x00b0 && hw <= 0x00b1) return true;   /* counter 1/2 high */
    if (hw >= 0x00c0 && hw <= 0x0102) return true;   /* putaway */
    if (hw >= 0x0104 && hw <= 0x013f) return true;   /* diagnostics */
    /* Old PSW locations.  Each interrupt class has an old/new pair four
     * halfwords apart -- the trace prints them as old=0048 new=004c -- and
     * it is the OLD half the hardware stores into. */
    static const uint32_t oldPsw[] = {0x0040, 0x0048, 0x0058, 0x0060, 0x0068,
                                      0x0070, 0x0078, 0x0080, 0x0088, 0x0090,
                                      0x0098};
    for (size_t i = 0; i < sizeof oldPsw / sizeof oldPsw[0]; i++)
        if (hw >= oldPsw[i] && hw < oldPsw[i] + 4) return true;
    return false;
}

void membus_set_store_protect(MemoryBus *b, uint32_t addr, bool v) {
    /* YAGPC_PROTSET=lo[-hi] reports every change to a protect bit in that
     * window.  A region that is protected when the flight software expects
     * it not to be is otherwise untraceable: the bit has no other reader
     * than the store paths, which only say that a store was refused. */
    {
        static int inited = 0;
        static long lo = -1, hi = -1;
        if (!inited) {
            const char *w = yagpc_getenv("YAGPC_PROTSET");
            if (w != NULL) {
                char *end = NULL;
                lo = strtol(w, &end, 16);
                hi = (end != NULL && *end == '-') ? strtol(end + 1, NULL, 16) : lo;
            }
            inited = 1;
        }
        if (lo >= 0 && (long)addr >= lo && (long)addr <= hi)
            fprintf(stderr, "PROTSET addr=%05x -> %d  from=+%td\n",
                    (unsigned)addr, (int)v,
                    (char *)__builtin_return_address(0)
                        - (char *)(void *)&membus_get_store_protect);
    }
    if (v && psa_must_not_protect(addr & b->addrMask)) v = false;
    mcm_set_store_protect(b->mcm, addr & b->addrMask, v);
}

bool membus_get_store_protect(const MemoryBus *b, uint32_t addr) {
    return mcm_get_store_protect(b->mcm, addr & b->addrMask);
}
