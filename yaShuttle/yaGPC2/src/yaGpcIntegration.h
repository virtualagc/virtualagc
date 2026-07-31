/* Shared contract between yaGPC2 and yaHALMAT2 for embedding either as
 * one of several GPC emulator instances inside a larger simulator (e.g.
 * a Space Shuttle simulator running GPC1-GPC5 as any mix of the two).
 *
 * Must be kept byte-for-byte identical between the two repos -- there is
 * no shared/common location for it yet, so each repo carries its own
 * copy. Do not add emulator-specific fields here; put those behind the
 * opaque `impl` pointer instead, so this header never needs to #include
 * either emulator's internal headers (keeps the two repos' builds fully
 * decoupled).
 *
 * See yaGPC2's integration-planning.md and its plan-mode discussion
 * history for the full design rationale. */
#ifndef YAGPC_INTEGRATION_H
#define YAGPC_INTEGRATION_H
#include <stdint.h>
#include <stdbool.h>

typedef enum { GPC_EMULATOR_HALMAT = 0, GPC_EMULATOR_YAGPC2 = 1 } GpcEmulatorType;

typedef struct {
    int gpcID;                 /* 1..5 (or more), caller-assigned */
    GpcEmulatorType emulator;
    double elapsedTime;        /* microseconds, monotonically increasing */
    void *impl;                /* AGEHarness* (yaGPC2) or halmat_state_t* (yaHALMAT2) */
} GpcState;

typedef void (*GpcEngineFn)(GpcState *state);
typedef bool (*GpcDebuggerFn)(GpcState *state, void *dbgState); /* false => stop */

/* symbolsPath: optional (NULL allowed) path to a linker/symbols JSON file
 * providing, at minimum, an entry point. yaGPC2 reads it and establishes
 * the start address from it (a freshly loaded .fcm otherwise sits in the
 * CPU's default wait state, per real AP-101S reset behavior -- there is
 * no implicit "start at word 0"). yaHALMAT2 ignores this parameter: its
 * entry point comes from the HALMAT program itself, not a companion
 * file. */
typedef bool (*GpcInitializerFn)(GpcState *state, const char *programPath, const char *symbolsPath);

typedef struct {
    GpcEngineFn engine;
    GpcDebuggerFn debugger;
    GpcInitializerFn initializer;
} GpcOps;

/* Servicer: the GPC's interface to vehicle peripherals. Deliberately
 * word/data-level (not bit/signal-level, not protocol-shaped) so a
 * shared-memory implementation is trivial; a networked/standalone
 * implementation is equally valid behind the same signature. This enum
 * is a provisional first draft covering only yaGPC2's known MIA-boundary
 * transactions -- yaHALMAT2's agent should extend it once that side's
 * needs are known, not treat it as closed. */
typedef enum {
    GPC_SVC_XMIT_WORD = 0,
    GPC_SVC_XMIT_CMD  = 1,
    GPC_SVC_RECV_WORD = 2,
    GPC_SVC_RECV_POLL = 3
} GpcServiceNumber;

typedef struct {
    int busID;       /* e.g. BCE number */
    int address;      /* IUA/subaddress or equivalent; meaning is bus-specific */
    uint32_t word;    /* data or command word; direction implied by serviceNumber */
} GpcServiceArgs;

typedef bool (*GpcServicerFn)(GpcState *state, GpcServiceNumber serviceNumber, GpcServiceArgs *args);

#endif
