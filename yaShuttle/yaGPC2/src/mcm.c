#include "mcm.h"

#include <stdlib.h>

MCM mcm_create(int wordCount) {
    MCM m;
    m.wordCount = wordCount;
    m.data = calloc((size_t)wordCount * 4, 1);
    m.protData = calloc((size_t)wordCount * 2, sizeof(bool));
    return m;
}

void mcm_free(MCM *m) {
    free(m->data);
    free(m->protData);
    m->data = NULL;
    m->protData = NULL;
}

/* mcm.coffee's get16/get32 mask the address into a 19-bit (512K-halfword)
 * space before indexing; that's larger than any actual MCM here (CPU:
 * 40K words = 80K halfwords, IOP: 24K words = 48K halfwords), so a
 * masked-but-still-out-of-range access is possible in principle. JS
 * TypedArray reads/writes at an out-of-range index silently yield
 * undefined (which the bitwise combine below coerces to 0) rather than
 * throwing — replicated here with explicit bounds checks instead of
 * relying on (unsafe, in C) out-of-bounds access. */

uint32_t mcm_get16(const MCM *m, uint32_t addr) {
    addr &= 0x7ffff;
    size_t byteIdx = (size_t)addr * 2;
    size_t total = (size_t)m->wordCount * 4;
    uint32_t hi = (byteIdx < total) ? m->data[byteIdx] : 0;
    uint32_t lo = (byteIdx + 1 < total) ? m->data[byteIdx + 1] : 0;
    return (hi << 8) | lo;
}

uint32_t mcm_get32(const MCM *m, uint32_t addr) {
    addr &= 0x7fffe;
    return (mcm_get16(m, addr) << 16) | mcm_get16(m, addr + 1);
}

static bool halfword_protected(const MCM *m, uint32_t addr) {
    return (addr < (uint32_t)(m->wordCount * 2)) && m->protData[addr];
}

bool mcm_set16(MCM *m, uint32_t addr, uint32_t v, bool checkProtect) {
    if (checkProtect && halfword_protected(m, addr)) return false;
    size_t byteIdx = (size_t)addr * 2;
    size_t total = (size_t)m->wordCount * 4;
    if (byteIdx < total) m->data[byteIdx] = (uint8_t)((v >> 8) & 0xff);
    if (byteIdx + 1 < total) m->data[byteIdx + 1] = (uint8_t)(v & 0xff);
    return true;
}

bool mcm_set32(MCM *m, uint32_t addr, uint32_t v, bool checkProtect) {
    if (checkProtect && (halfword_protected(m, addr) || halfword_protected(m, addr + 1))) return false;
    mcm_set16(m, addr, (v >> 16) & 0xffff, false);
    mcm_set16(m, addr + 1, v & 0xffff, false);
    return true;
}

void mcm_load16(MCM *m, uint32_t base, const uint8_t *bytes, size_t byteLen) {
    size_t hwCount = byteLen / 2;
    for (size_t i = 0; i < hwCount; i++) {
        uint32_t v = ((uint32_t)bytes[i * 2] << 8) | bytes[i * 2 + 1];
        mcm_set16(m, base + (uint32_t)i, v, false);
    }
}

void mcm_set_store_protect(MCM *m, uint32_t addr, bool v) {
    if (addr < (uint32_t)(m->wordCount * 2)) m->protData[addr] = v;
}

bool mcm_get_store_protect(const MCM *m, uint32_t addr) {
    return halfword_protected(m, addr);
}
