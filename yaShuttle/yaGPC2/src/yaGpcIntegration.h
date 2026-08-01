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

/* Servicer: the GPC's interface to vehicle peripherals. Deliberately
 * word/data-level (not bit/signal-level, not protocol-shaped) so a
 * shared-memory implementation is trivial; a networked/standalone
 * implementation is equally valid behind the same signature. This enum
 * is a provisional first draft covering only yaGPC2's known MIA-boundary
 * transactions -- yaHALMAT2's agent should extend it once that side's
 * needs are known, not treat it as closed.
 *
 * Deliberately generic: a servicer call has no dependency of any kind on
 * a particular emulator's internal state or type, since it represents
 * the peripheral/bus side of the interface, not the GPC side. It's a
 * pure function of a service number plus an input/output pair whose
 * shapes vary by service number -- one union each, tagged externally by
 * the serviceNumber argument (not embedded in the structs, since both
 * sides already have it in hand from the call itself). */
typedef enum {
    GPC_SVC_XMIT_WORD = 0,
    GPC_SVC_XMIT_CMD  = 1,
    GPC_SVC_RECV_WORD = 2,
    GPC_SVC_RECV_POLL = 3
} GpcServiceNumber;

typedef struct {
    int busID;      /* e.g. BCE number -- meaningful for every service */
    int address;    /* IUA/subaddress or equivalent; meaning is bus-specific.
                      * Unused (0) for services that don't need it. */
    union {
        uint32_t word; /* GPC_SVC_XMIT_WORD: data word. GPC_SVC_XMIT_CMD: command word. */
    } in;
} GpcServiceInput;

typedef struct {
    union {
        struct { bool ok; } xmit;                        /* GPC_SVC_XMIT_WORD / GPC_SVC_XMIT_CMD */
        struct { bool available; } poll;                  /* GPC_SVC_RECV_POLL */
        struct { bool available; uint32_t word; } recv;   /* GPC_SVC_RECV_WORD */
    } out;
} GpcServiceOutput;

/* servicerCtx is whatever opaque context the embedding simulator
 * registered when wiring the servicer up (e.g. a handle to its own
 * peripheral-bus simulation) -- never a GpcState, and never touched by
 * yaGPC2/yaHALMAT2 themselves, same shape as HalUCP's own
 * cbCtx/outputCallback pattern. Each GPC instance is still wired to its
 * own servicer+servicerCtx pair (a Shuttle sim's GPC1 and GPC3 may sit
 * on different buses) -- see GpcInitializerFn, which is where that
 * wiring happens; the callback itself just never sees which GpcState
 * triggered it, by design. */
typedef void (*GpcServicerFn)(void *servicerCtx, GpcServiceNumber serviceNumber, const GpcServiceInput *input,
                               GpcServiceOutput *output);

/* symbolsPath: optional (NULL allowed) path to a linker/symbols JSON file
 * providing, at minimum, an entry point. yaGPC2 reads it and establishes
 * the start address from it (a freshly loaded .fcm otherwise sits in the
 * CPU's default wait state, per real AP-101S reset behavior -- there is
 * no implicit "start at word 0"). yaHALMAT2 ignores this parameter: its
 * entry point comes from the HALMAT program itself, not a companion
 * file.
 *
 * servicer/servicerCtx: optional (NULL allowed) -- installs this
 * instance's peripheral-I/O callback, if any. This belongs on the
 * initializer rather than as a separate per-emulator function (the way
 * yaGPC2's own ap101_set_servicer() works internally) or as a field on
 * GpcOps itself: GpcOps is one shared, effectively-const vtable per
 * emulator *type* (yaGPC2_ops/yaHALMAT2_ops), used identically by every
 * instance of that type, so a servicer living there would be forced to
 * be the same for every instance -- exactly the kind of shared state
 * this contract has avoided since GpcState's own design. The
 * initializer already takes other per-instance configuration
 * (programPath, symbolsPath), so this is the natural place for
 * per-instance servicer wiring too. Pass NULL for both to run this
 * instance with no peripheral I/O at all (matches yaGPC2's original
 * inert MIA stub behavior). */
typedef bool (*GpcInitializerFn)(GpcState *state, const char *programPath, const char *symbolsPath,
                                  GpcServicerFn servicer, void *servicerCtx);

/* Releases whatever initializer allocated for state->impl (and, on
 * yaGPC2's side, flushes any output still buffered but not yet
 * newline-terminated -- see halucp_flush_all_pending() -- since a
 * driver tearing down or replacing an instance is another way a
 * program's session can end besides its own HALT/EOF). Leaves *state
 * otherwise unspecified after the call; the caller must not use it
 * again without re-initializing. */
typedef void (*GpcReleaseFn)(GpcState *state);

/* Creates a fresh, opaque debugger-session state for GpcDebuggerFn's
 * dbgState parameter -- session/REPL state (breakpoints, step mode,
 * htrace toggle, etc.), independent of any particular GpcState instance,
 * matching how yaGPC2's own Debugger and yaHALMAT2's own
 * debugger_state_t are already kept separate from emulator state.
 * sourceMapPath is optional (NULL allowed), mirroring
 * GpcInitializerFn's symbolsPath -- meaning/support is emulator-specific
 * (yaGPC2: a --source-map-equivalent HAL/S source map, loaded once at
 * creation since there's no way to load one later through the debugger's
 * own commands). Returns NULL on failure. */
typedef void *(*GpcDebuggerStateCreateFn)(const char *sourceMapPath);

/* Releases a debugger-session state created by GpcDebuggerStateCreateFn.
 * Does not touch any GpcState -- a debugger session and a GPC instance
 * are independently created/destroyed and one dbgState may outlive, or
 * be reused across, more than one GpcState over a debugging session. */
typedef void (*GpcDebuggerStateDestroyFn)(void *dbgState);

typedef struct {
    GpcEngineFn engine;
    GpcDebuggerFn debugger;
    GpcInitializerFn initializer;
    GpcReleaseFn release;
    GpcDebuggerStateCreateFn debuggerStateCreate;
    GpcDebuggerStateDestroyFn debuggerStateDestroy;
} GpcOps;

#endif
