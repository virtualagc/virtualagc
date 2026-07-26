/* Extended Performance/Modular Core Memory, ported from gpc/mcm.coffee.
 *
 * The JS class also carries access-tracking (lastRead/lastWritten/
 * protLastWritten, a `step` counter) and CSS-color helpers
 * (getProtColor/getAccessColor/getAccessInfo) purely for the debug GUI's
 * memory pane. `gpc run` never calls AGEHarness#_syncStep (grep-verified
 * — see regmem.h), so `step` never advances past 0 in batch mode and none
 * of that is observable in `run`'s output — omitted here, per the port
 * plan's Phase 2 scope. Store-protect (protData) *is* ported: it gates
 * set16/set32 in the real hardware and is directly observable in `run`'s
 * output when a program writes to a protected halfword. */
#ifndef YAGPC_MCM_H
#define YAGPC_MCM_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

typedef struct {
    int wordCount;    /* 32-bit words */
    uint8_t *data;    /* wordCount*4 bytes, big-endian */
    bool *protData;   /* wordCount*2 entries (one per halfword) */
} MCM;

MCM mcm_create(int wordCount);
void mcm_free(MCM *m);

uint32_t mcm_get16(const MCM *m, uint32_t addr);
uint32_t mcm_get32(const MCM *m, uint32_t addr);

/* Returns false if the write was blocked by store-protect (checkProtect
 * true and the target halfword(s) protected), matching mcm.coffee's
 * boolean return. */
bool mcm_set16(MCM *m, uint32_t addr, uint32_t v, bool checkProtect);
bool mcm_set32(MCM *m, uint32_t addr, uint32_t v, bool checkProtect);

/* Bulk-load big-endian halfwords starting at halfword `base` (used for
 * initial FCM image load — mirrors load16's DataView.getUint16(...,
 * false) reads, bypassing store-protect). */
void mcm_load16(MCM *m, uint32_t base, const uint8_t *bytes, size_t byteLen);

void mcm_set_store_protect(MCM *m, uint32_t addr, bool v);
bool mcm_get_store_protect(const MCM *m, uint32_t addr);

#endif
