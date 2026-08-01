/* AGEHarness — Aerospace/Ground Equipment Harness, ported from
 * gpc/ageharness.coffee. Wraps an AP101 with development/debug-equipment
 * affordances: FCM loading, symbol-table loading, HalUCP wiring, entry
 * point management, register snapshotting for trace output.
 *
 * Omitted (all confirmed no-ops for `gpc run`'s CLI/batch context, since
 * `typeof window` is always undefined in Node/CLI — see
 * gpc/ageharness.coffee's `_storage` comment): `saveBreakpoints`/
 * `loadBreakpoints`/the `breakpoints` Map itself, and `_syncStep` (never
 * called — AGEHarness#_syncStep is grep-verified dead code across the
 * whole `gpc run` path, same finding as regmem.h/mcm.h's `step` omission
 * from Phase 2). */
#ifndef YAGPC_AGEHARNESS_H
#define YAGPC_AGEHARNESS_H

#include <stdbool.h>
#include <stdint.h>

#include "ap101.h"
#include "halucp.h"
#include "opts.h"
#include "symboltable.h"
#include "yaGpcIntegration.h"

typedef struct {
    AP101 gpc;
    HalUCP halUCP;
    SymbolTable sym;

    int stepCount;
    char *fcmName; /* basename of the loaded FCM */
    char *lastSymbolsPath; /* the path configure_from_opts actually loaded (explicit or auto-detected), or NULL */

    /* Saved by configure_from_opts for reset() to replay. */
    char *initialFcmPath;
    Options initialOpts;
    bool hasInitial;

    /* Set by src/gpcops.c's yagpc2_initializer() from GpcInitializerFn's
     * output/input/ioCtx parameters -- always non-NULL after
     * yagpc2_initializer() returns, since a NULL output/input argument
     * there resolves to gpcops.c's own built-in stdout/EOF default at
     * init time (see GpcOutputFn/GpcInputFn's own comments in
     * yaGpcIntegration.h). Consumed by the shim functions gpcops.c wires
     * onto halUCP.outputCallback/inputCallback. Not used anywhere in the
     * standalone `gpc run` CLI path (which wires halUCP's callbacks
     * directly to IOHost instead), same scope as htraceWanted above. */
    GpcOutputFn ioOutput;
    GpcInputFn ioInput;
    void *ioCtx;

    /* Set by src/gpcops.c's yagpc2_debugger() from debugger_wants_htrace()/
     * debugger_line_width() after each debugger_hook() call, and consumed
     * by yagpc2_engine() to decide whether (and how, honoring 'set width')
     * to print a trace line for the next instruction -- lets the
     * black-box engine (see yaGpcIntegration.h) honor 'htrace' without
     * debugger.c or a driver needing to own the snapshot/diff/print work
     * itself. Not read or written anywhere in the standalone `gpc run`
     * CLI path, which prints its own trace lines from run.c as before. */
    bool htraceWanted;
    int htraceLineWidth;
} AGEHarness;

void ageharness_init(AGEHarness *age);
void ageharness_free(AGEHarness *age);

typedef struct {
    long byteCount;
    bool hasEntryPoint;
    uint32_t entryPoint;
} ConfigureResult;

/* Loads symbols (with auto-detect), loads the FCM, sets the entry point,
 * and configures HalUCP. On any hard file-I/O failure loading the FCM
 * itself (not the symbols file, which fails soft — see symboltable.c),
 * this prints an error and calls exit(1), matching Node's uncaught
 * fs.readFileSync exception for a missing FCM (there's no recoverable
 * path in the JS either). `out` may be NULL if the caller doesn't need
 * the result (e.g. reset()'s internal replay). */
void ageharness_configure_from_opts(AGEHarness *age, const char *fcmPath, const Options *opts, ConfigureResult *out);

/* Minimal black-box initializer for embedding (see yaGpcIntegration.h's
 * GpcInitializerFn): calls ageharness_init(age), loads fcmPath, and --
 * if symbolsPath is non-NULL -- loads it and sets the entry point from
 * its numeric entryPoint field (silently leaves the default wait state
 * in place if the file has none, same as ageharness_configure_from_opts()
 * does for an --start-less, entryPoint-less symbols file). No other
 * Options concerns (--fcos, --line-width, etc). Not called anywhere in
 * the standalone `gpc run` CLI path (which uses
 * ageharness_configure_from_opts() instead); existing behavior there is
 * unchanged. Like load_fcm(), a missing/unreadable fcmPath prints an
 * error and exits(1) rather than returning false -- matching this file's
 * existing failure convention throughout (see load_fcm()'s own comment).
 * The bool return is for future graceful-failure support. */
bool ageharness_init_minimal(AGEHarness *age, const char *fcmPath, const char *symbolsPath);

void ageharness_set_entry_point(AGEHarness *age, uint32_t addr);

typedef struct {
    uint32_t r[8];  /* R0-R7 (or R8-R15, or F0-F7 per PSW's reg-set bit — see snapshot's own comment) */
    uint32_t fp[8]; /* FP0-FP7 */
    uint32_t nia;
    uint32_t cc;
    uint32_t psw1;
    uint32_t psw2;
} RegSnapshot;

void ageharness_snapshot_regs(AGEHarness *age, RegSnapshot *snap);

#define REG_SNAPSHOT_MAX_CHANGES 20
typedef struct {
    char name[8]; /* "R00".."R07", "FP0".."FP7", "NIA", "CC", "PSW1", "PSW2" */
    uint32_t oldVal, newVal;
} RegChange;

/* Returns the number of changes written to out (capacity
 * REG_SNAPSHOT_MAX_CHANGES, which covers all 20 possible fields). Order
 * matches gpc/ageharness.coffee's snapshotRegs field insertion order
 * (R00..R07, FP0..FP7, NIA, CC, PSW1, PSW2), since `diffRegs` iterates
 * the snapshot object's own keys in insertion order. */
int ageharness_diff_regs(const RegSnapshot *before, const RegSnapshot *after, RegChange *out);

void ageharness_reset(AGEHarness *age);

#endif
