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

/* GpcEngineFn's return value: whether the caller should keep calling it,
 * and (unlike an earlier draft of this contract) specifically why.
 * Existed as a real, confirmed gap before this: a driver written purely
 * against GpcOps had no way to tell "has this instance's program
 * finished?" (that's AP-101S PSW wait-state / yaHALMAT2's own halted
 * flag, neither exposed through GpcState). Concretely verified what
 * happens without it: calling the engine past a program's own natural
 * completion runs it into whatever memory/state follows, which surfaces
 * as nonsense (observed on yaGPC2: repeated bogus "SVC trapped" reports
 * from decoding non-code memory as instructions).
 *
 * Investigated both emulators' real, existing conditions before settling
 * on this list (see plan-mode discussion history) rather than inventing
 * plausible-sounding ones -- every negative value below corresponds to
 * something at least one emulator's code was already found to do (though
 * not every value is reachable from both; a value neither has evidence
 * for yet is still reserved here so the numbering stays identical across
 * both repos as either side's needs grow, per the user's explicit
 * requirement that a given code can't mean different things in each).
 *
 *   0        RUNNING: keep calling engine().
 *   1000+N   WARNING: a HAL/S runtime error (SEND ERROR/AERROR) fired,
 *            group/N in the real HAL/S-FC AERROR numbering -- confirmed
 *            byte-for-byte identical between yaGPC2's svc_error_message()
 *            table and yaHALMAT2's HAL_S_ERROR_* defines, both porting
 *            the same historical spec. Execution continues normally
 *            (the program's own ON ERROR handler, if any, already ran).
 *            Message text: gpc_engine_status_message() below.
 *   -1       HALTED: clean, expected program termination.
 *   -2       HALTED: unhandled end-of-input (a READ ran out of data with
 *            no ON ERROR handler installed). Confirmed reachable on
 *            yaHALMAT2 (all 7 READ call sites, SCALAR/INTEGER/BIT/
 *            CHARACTER variants); not currently known to be reachable
 *            on yaGPC2 outside the one case this contract's own gap
 *            analysis already found.
 *   -3       HALTED: scheduler exhausted -- nothing left ready to run,
 *            or ever going to become ready (yaHALMAT2's own "silent
 *            starvation" case; reachable in principle on yaHALMAT2 --
 *            the code path exists -- but not known to be exercised by
 *            any real HAL/S source, since it requires a task graph a
 *            well-formed program's own dependency rules shouldn't
 *            produce; not currently known to be reachable on yaGPC2,
 *            reserved).
 *   -4       ERROR: invalid/unrecognized instruction or opcode.
 *            Confirmed reachable on yaHALMAT2 (unrecognized-opcode
 *            default case, plus %SVC-etc. macro invocations -- those
 *            compile to raw AP-101S instructions outside portable
 *            HALMAT semantics, a deliberate scope boundary, but "can't
 *            execute this" is the same outcome from a driver's view).
 *   -5       ERROR: unrecognized/unhandled low-level trap (yaGPC2's
 *            unhandled SVC code). Confirmed NOT reachable on yaHALMAT2
 *            -- it interprets HALMAT bytecode directly, never AP-101S
 *            object code, so it has no SVC/trap layer of its own to be
 *            unhandled from. Stays yaGPC2-only, reserved.
 *   -6       ERROR: index/subscript/array bounds violation. Confirmed
 *            reachable on yaHALMAT2 (114 call sites -- SYT/VAC/
 *            subscript/literal-index checks; deliberately excludes 3
 *            other "out of range" sites that are plain argument-value-
 *            range validations, not indexing, and stay tagged -9); not
 *            currently known to be reachable on yaGPC2, reserved.
 *   -7       ERROR: call-stack/nesting depth exceeded. Confirmed
 *            reachable on yaHALMAT2 (3 sites: PCAL/FCAL call-nesting,
 *            inline-FUNCTION nesting); not currently known to be
 *            reachable on yaGPC2, reserved.
 *   -8       ERROR: call to undefined procedure/function. Confirmed
 *            reachable on yaHALMAT2 (2 sites: undefined procedure,
 *            undefined function); not currently known to be reachable
 *            on yaGPC2, reserved.
 *   -9       ERROR: internal-consistency failure not covered above.
 *            On yaHALMAT2 this is the catch-all for the ~365 fail()
 *            call sites (of ~490 total) not individually mapped above
 *            -- a deliberate scope boundary, not an oversight; see
 *            yaHALMAT2's own history for the full site-by-site mapping
 *            if a specific one ever needs promoting out of -9.
 *
 * HALTED (-1..-3) vs. ERROR (-4..-9): the former means the instance
 * stopped for a reason inherent to the program/its input, not a bug;
 * the latter means something the emulator itself couldn't make sense
 * of. Both mean the same thing to a driver -- stop calling engine() --
 * the distinction is purely diagnostic. */
typedef enum {
    GPC_ENGINE_RUNNING = 0,

    GPC_ENGINE_WARNING_HAL_S_ERROR_BASE = 1000, /* + real AERROR group/N number */

    GPC_ENGINE_HALTED_NORMAL        = -1,
    GPC_ENGINE_HALTED_UNHANDLED_EOF = -2,
    GPC_ENGINE_HALTED_STARVED       = -3,
    GPC_ENGINE_ERROR_INVALID_OPCODE = -4,
    GPC_ENGINE_ERROR_UNHANDLED_TRAP = -5,
    GPC_ENGINE_ERROR_BOUNDS         = -6,
    GPC_ENGINE_ERROR_STACK_DEPTH    = -7,
    GPC_ENGINE_ERROR_UNDEFINED_CALL = -8,
    GPC_ENGINE_ERROR_INTERNAL       = -9
} GpcEngineStatus;

typedef GpcEngineStatus (*GpcEngineFn)(GpcState *state);
typedef bool (*GpcDebuggerFn)(GpcState *state, void *dbgState); /* false => stop */

/* Textual description for any GpcEngineStatus value, including the full
 * 1000+N HAL/S-runtime-error range -- maintained here so an integrator
 * never has to invent or guess error text themselves (a real ~25-entry
 * message table already existed, HAL/S-FC-runtime-accurate, before this
 * function did -- see the shared implementation file's own header
 * comment). Must be kept byte-for-byte identical between both repos,
 * same discipline as this whole file. Never free() the result -- every
 * named/reserved code returns a string literal (valid for the life of
 * the process); an unrecognized value (including an unreserved N in
 * 1000+N) returns a shared static buffer instead, valid only until the
 * next call to this function -- copy it immediately if you need to
 * retain it past that. Never returns NULL, so a caller can always print
 * *something*. */
const char *gpc_engine_status_message(GpcEngineStatus status);

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

/* The two emulators' actual vtable instances (yaGPC2: src/gpcops.c;
 * yaHALMAT2: its own equivalent .c file). Declared here rather than in
 * a separate per-repo header (yaGPC2's old gpcops.h / yaHALMAT2's old
 * yaGpcOps.h, both eliminated) since each was nothing but this one
 * extern plus an #include of this file -- a real integrator wants both
 * emulators' vtables visible from the one shared contract header, not
 * two extra near-empty per-emulator headers to separately track. */
extern const GpcOps yaGPC2_ops;
extern const GpcOps yaHALMAT2_ops;

#endif
