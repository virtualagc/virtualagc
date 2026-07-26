#include "membus.h"

typedef struct {
    MCM *mcm;
    uint32_t addr;
} Route;

static Route route(const MemoryBus *b, uint32_t addr) {
    addr &= b->addrMask;
    Route r;
    if (addr < b->cpuHWCount) {
        r.mcm = b->cpuMCM;
        r.addr = addr;
    } else {
        r.mcm = b->iopMCM;
        r.addr = addr - b->cpuHWCount;
    }
    return r;
}

MemoryBus membus_create(MCM *cpuMCM, MCM *iopMCM) {
    MemoryBus b;
    b.cpuMCM = cpuMCM;
    b.iopMCM = iopMCM;
    b.cpuHWCount = (uint32_t)cpuMCM->wordCount * 2;
    b.totalHWCount = b.cpuHWCount + (uint32_t)iopMCM->wordCount * 2;
    b.addrMask = b.totalHWCount - 1;
    return b;
}

uint32_t membus_get16(const MemoryBus *b, uint32_t addr) {
    Route r = route(b, addr);
    return mcm_get16(r.mcm, r.addr);
}

uint32_t membus_get32(const MemoryBus *b, uint32_t addr) {
    Route r = route(b, addr);
    return mcm_get32(r.mcm, r.addr);
}

bool membus_set16(MemoryBus *b, uint32_t addr, uint32_t v, bool checkProtect) {
    Route r = route(b, addr);
    return mcm_set16(r.mcm, r.addr, v, checkProtect);
}

bool membus_set32(MemoryBus *b, uint32_t addr, uint32_t v, bool checkProtect) {
    Route r = route(b, addr);
    return mcm_set32(r.mcm, r.addr, v, checkProtect);
}

void membus_load16(MemoryBus *b, uint32_t base, const uint8_t *bytes, size_t byteLen) {
    size_t hwCount = byteLen / 2;
    for (size_t i = 0; i < hwCount; i++) {
        uint32_t v = ((uint32_t)bytes[i * 2] << 8) | bytes[i * 2 + 1];
        membus_set16(b, base + (uint32_t)i, v, false);
    }
}

void membus_set_store_protect(MemoryBus *b, uint32_t addr, bool v) {
    Route r = route(b, addr);
    mcm_set_store_protect(r.mcm, r.addr, v);
}

bool membus_get_store_protect(const MemoryBus *b, uint32_t addr) {
    Route r = route(b, addr);
    return mcm_get_store_protect(r.mcm, r.addr);
}
