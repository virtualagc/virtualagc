/* HAL/S User Control Program emulation, ported from gpc/halUCP.coffee.
 *
 * This is the ground-equipment I/O trap layer: it monitors three trap
 * addresses (OUTRAP/INTRAP/CNTRAP, resolved from the loaded symbol
 * table's IOINIT section) and, when the CPU's NIA lands on one,
 * intercepts the HAL/S runtime's WRITE/READ/control-statement protocol
 * instead of letting it execute for real. It also intercepts SVC
 * instructions for SEND ERROR / program-halt handling.
 *
 * Output/input/error are all routed through caller-supplied callbacks
 * (wired up by the batch runner in Phase 10) rather than touching stdio
 * directly, mirroring the JS's `outputCallback`/`inputCallback`/
 * `errorCallback` function-pointer fields. `controlCallback` (declared in
 * the JS constructor) is dead code — grep-verified never invoked
 * anywhere in halUCP.coffee — and is not ported.
 *
 * Per-channel state (`firstWrite`/`firstField`/`column`/`lineNumber`/
 * `deferred`/`suppressNextSep`/`suppressNextAdvance`) is fixed-size
 * arrays indexed directly by channel number (HAL/S device numbers are
 * always small integers in practice) rather than JS's dynamic objects. */
#ifndef YAGPC_HALUCP_H
#define YAGPC_HALUCP_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "cpu.h"
#include "symboltable.h"

#define HALUCP_MAX_CHANNEL 256

typedef void (*HalUCPOutputCB)(void *ctx, const char *text, int channel);
typedef void (*HalUCPInputCB)(void *ctx, int channel, int iocode);
typedef void (*HalUCPErrorCB)(void *ctx, const char *msg);

typedef struct {
    bool present;
    int downLines;
    int toCol;
} HalUCPDeferredPos;

typedef struct {
    CPU *cpu;

    bool hasTrapAddrs;
    uint32_t outrap, intrap, cntrap;
    uint32_t iocodeAddr;
    uint32_t iobufAddr;

    bool waitingForInput;
    bool hasPendingIocode;
    int pendingIocode;

    void *cbCtx;
    HalUCPOutputCB outputCallback;
    HalUCPInputCB inputCallback;
    HalUCPErrorCB errorCallback;

    bool trapSvcError;
    bool svcTrapped;
    bool active;
    bool wasRunning;
    bool skipTrap;

    bool iobufAscii; /* false = ebcdic (default), true = ascii */
    int channel;

    /* channelMode: 0 = unset (defaults per getChannelMode: paged), 1 =
     * paged, 2 = unpaged. */
    uint8_t channelMode[HALUCP_MAX_CHANNEL];

    char *inputBuffer; /* growable NUL-terminated string; '\0'-length == empty */
    size_t inputBufferLen, inputBufferCap;
    bool readTerminated;

    int formatNumBlanks;
    bool verbose;

    int lineWidth;
    int linesPerPage;

    /* Inverted polarity vs JS's `firstWrite[ch] != false`: true once
     * channel ch has had its first WRITE/PRINT IOINIT (see header
     * comment / halucp.c for why this is also what "for ch of
     * @firstWrite" iterates over). */
    bool hasWrittenBefore[HALUCP_MAX_CHANNEL];
    bool firstField[HALUCP_MAX_CHANNEL];
    int column[HALUCP_MAX_CHANNEL];
    int lineNumber[HALUCP_MAX_CHANNEL];
    HalUCPDeferredPos deferred[HALUCP_MAX_CHANNEL];
    bool suppressNextSep[HALUCP_MAX_CHANNEL];
    bool suppressNextAdvance[HALUCP_MAX_CHANNEL];
} HalUCP;

void halucp_init(HalUCP *h, CPU *cpu);
void halucp_free(HalUCP *h);

/* Wired into cpu->halUCPHandleSVC (see cpu.h); returns true if the SVC
 * was intercepted (caller should skip the standard PSW swap). */
bool halucp_handle_svc(void *halUCPvp, uint32_t ea, uint32_t r1);
/* Wired into cpu->halUCPLog. */
void halucp_log_cb(void *halUCPvp, const char *msg);

/* symbols/symTypes are the just-loaded SymbolTable's own arrays —
 * see symboltable.h. */
void halucp_init_from_symbols(HalUCP *h, const SymbolTable *st);

bool halucp_is_trap_addr(HalUCP *h, uint32_t nia);
/* Returns "continue" (true) or "block" (false) — matching checkTrap's
 * 'continue'/'block' string return, collapsed to bool since those are
 * the only two values ever returned. */
bool halucp_check_trap(HalUCP *h, uint32_t nia);

const char *halucp_get_channel_mode(HalUCP *h, int ch); /* "paged" or "unpaged" */
void halucp_set_channel_mode(HalUCP *h, int ch, const char *mode);
bool halucp_is_paged(HalUCP *h, int ch);

/* Feed one line of input text (caller strips/keeps the trailing newline
 * as iohost.c's reader decides — see BatchRunner's usage in Phase 10). */
void halucp_provide_input(HalUCP *h, const char *text);
void halucp_provide_eof(HalUCP *h);
void halucp_notify_interactive_input(HalUCP *h, int outputChannel);

/* Human-readable iocode name / input-text validation, for an interactive
 * front-end's input prompt (Phase 10). Return values point at static
 * buffers on the "formatted" paths (UNKNOWN(n) / unknown iocode n) —
 * copy out before the next call if the caller needs to retain it. */
const char *halucp_iocode_type_name(int iocode);
const char *halucp_validate_input(const char *text, int iocode); /* NULL if valid */

#endif
