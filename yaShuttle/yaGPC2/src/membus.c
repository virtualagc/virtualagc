#include <stdio.h>
#include <stdlib.h>
#include "membus.h"

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

void membus_set_store_protect(MemoryBus *b, uint32_t addr, bool v) {
    /* YAGPC_PROTSET=lo[-hi] reports every change to a protect bit in that
     * window.  A region that is protected when the flight software expects
     * it not to be is otherwise untraceable: the bit has no other reader
     * than the store paths, which only say that a store was refused. */
    {
        static int inited = 0;
        static long lo = -1, hi = -1;
        if (!inited) {
            const char *w = getenv("YAGPC_PROTSET");
            if (w != NULL) {
                char *end = NULL;
                lo = strtol(w, &end, 16);
                hi = (end != NULL && *end == '-') ? strtol(end + 1, NULL, 16) : lo;
            }
            inited = 1;
        }
        if (lo >= 0 && (long)addr >= lo && (long)addr <= hi)
            fprintf(stderr, "PROTSET addr=%05x -> %d\n", (unsigned)addr, (int)v);
    }
    mcm_set_store_protect(b->mcm, addr & b->addrMask, v);
}

bool membus_get_store_protect(const MemoryBus *b, uint32_t addr) {
    return mcm_get_store_protect(b->mcm, addr & b->addrMask);
}
