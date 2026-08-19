/* MemoryBus — a thin wrapper presenting the AP-101S's single, real, shared
 * main storage (see mcm.h/cpu.h: one MCM, sized to the full 19-bit/524,288-
 * halfword address space) through the get/set/protect API the rest of the
 * emulator already expects. Originally ported from gpc/membus.coffee, which
 * arbitrated between two SEPARATE MCMs (a "CPU" one and an "IOP" one,
 * concatenated) -- that split is not real hardware (AP-101S-instruction-
 * set.txt Sec. III "1.1.2 Addressing and Instruction Formats"/PDF p.451:
 * "the AP101S performs 19 bit addressing, and can address 524,288
 * halfwords. Only the first 256KHW of these ... are addressable by the
 * IOP" -- one shared storage, the IOP just can't reach the upper half of
 * it) and yaGPC2's own IOP instruction execution (iop.c's iop_g_eaf/
 * iop_g_eah/iop_s_eaf/iop_s_eah) already bypassed it, reading/writing
 * cpu->mainStorage directly -- so the split MCM a CPU-issued access via
 * this bus would land on for any address >= the old cpuHWCount was a
 * second, disjoint block of memory the IOP could never see or affect: CPU
 * and IOP silently disagreeing about the content of the same address.
 * GUI-only pass-throughs (setView, access-color helpers) are omitted —
 * see mcm.h's header comment for why. */
#ifndef YAGPC_MEMBUS_H
#define YAGPC_MEMBUS_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "mcm.h"

typedef struct {
    MCM *mcm;
    uint32_t totalHWCount;
    uint32_t addrMask;
} MemoryBus;

MemoryBus membus_create(MCM *mcm);

uint32_t membus_get16(const MemoryBus *b, uint32_t addr);
uint32_t membus_get32(const MemoryBus *b, uint32_t addr);
bool membus_set16(MemoryBus *b, uint32_t addr, uint32_t v, bool checkProtect);
bool membus_set32(MemoryBus *b, uint32_t addr, uint32_t v, bool checkProtect);
void membus_load16(MemoryBus *b, uint32_t base, const uint8_t *bytes, size_t byteLen);
void membus_set_store_protect(MemoryBus *b, uint32_t addr, bool v);
bool membus_get_store_protect(const MemoryBus *b, uint32_t addr);

#endif
