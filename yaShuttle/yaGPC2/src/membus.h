/* MemoryBus — arbitrates access between the CPU's and IOP's MCMs,
 * presenting them as one contiguous address space. Ported from
 * gpc/membus.coffee. GUI-only pass-throughs (setView, access-color
 * helpers) are omitted — see mcm.h's header comment for why. */
#ifndef YAGPC_MEMBUS_H
#define YAGPC_MEMBUS_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "mcm.h"

typedef struct {
    MCM *cpuMCM;
    MCM *iopMCM;
    uint32_t cpuHWCount;
    uint32_t totalHWCount;
    uint32_t addrMask;
} MemoryBus;

MemoryBus membus_create(MCM *cpuMCM, MCM *iopMCM);

uint32_t membus_get16(const MemoryBus *b, uint32_t addr);
uint32_t membus_get32(const MemoryBus *b, uint32_t addr);
bool membus_set16(MemoryBus *b, uint32_t addr, uint32_t v, bool checkProtect);
bool membus_set32(MemoryBus *b, uint32_t addr, uint32_t v, bool checkProtect);
void membus_load16(MemoryBus *b, uint32_t base, const uint8_t *bytes, size_t byteLen);
void membus_set_store_protect(MemoryBus *b, uint32_t addr, bool v);
bool membus_get_store_protect(const MemoryBus *b, uint32_t addr);

#endif
