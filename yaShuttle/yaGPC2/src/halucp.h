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
#include "schedule.h"
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

    /* HAL/S TASK/SCHEDULE/WAIT task executive -- see schedule.h. yaGPC2
     * substitutes for FCOS here at the same SVC-trap level it already
     * substitutes for SEND ERROR/QUIT/EVENT, below. */
    Scheduler scheduler;

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

    /* Set only by the unhandled-READ-EOF halt path (halucp_provide_eof()),
     * never by the normal SVC 0x0015 halt -- both set the AP-101S PSW
     * wait-state bit identically, so this is the only way to tell them
     * apart from outside (see gpcops.c's yagpc2_engine(), which maps
     * this to GpcEngineStatus's GPC_ENGINE_HALTED_UNHANDLED_EOF vs.
     * GPC_ENGINE_HALTED_NORMAL). */
    bool haltedOnUnhandledEof;

    /* Group/number of the last SEND ERROR (SVC 0x0014), whether or not
     * it was caught by an ON ERROR handler -- backs the ERRGRP/ERRNUM
     * built-in functions (USA003087: "returns group/number of last
     * error detected, or zero"), which compile to their own dedicated
     * query SVCs (0x0117/0x0217) rather than reading ordinary program
     * memory. 0 until the first SEND ERROR. Sticky -- stays set until
     * the next SEND ERROR, so it alone can't tell a caller whether one
     * just fired on this specific instruction; see sendErrorPending. */
    int lastErrGroup, lastErrNum;

    /* Set true every time the SVC 0x0014 (SEND ERROR) path runs, read
     * and cleared by gpcops.c's yagpc2_engine() immediately after each
     * instruction -- a one-shot "did this exact instruction just fire
     * one" signal, unlike lastErrGroup/lastErrNum above, which stay set
     * indefinitely and can't distinguish a fresh SEND ERROR from a
     * stale one several instructions old. */
    bool sendErrorPending;

    bool iobufAscii; /* false = ebcdic (default), true = ascii */
    int channel;

    /* channelMode: 0 = unset (defaults per getChannelMode: paged), 1 =
     * paged, 2 = unpaged. */
    uint8_t channelMode[HALUCP_MAX_CHANNEL];

    char *inputBuffer; /* growable NUL-terminated string; '\0'-length == empty */
    size_t inputBufferLen, inputBufferCap;
    bool readTerminated;

    /* 1-indexed column (since the last newline consumed out of
     * inputBuffer) of the next unconsumed character -- tracked
     * incrementally by ib_consume_prefix/ib_reset so a READ statement's
     * COLUMN(n) control specifier can reposition forward within the
     * still-buffered current line (see readSkipPending/readColumnPending
     * below and apply_read_positioning() in halucp.c). */
    size_t inputColumn;

    /* READ-only pending SKIP(n)/COLUMN(n) state for the *current* READ
     * statement, distinct from WRITE's output-side deferred[]/column[].
     * Needed for the READALL-then-"SKIP(0), COLUMN(n)"-re-read-the-
     * -same-line idiom (USA003087 Sec. 10.1.1; see "Programming in
     * HAL/S" p.164's name/value initialization-file reader, corpus file
     * 164-OUTER.hal) -- without this, SKIP(0)/COLUMN(n) had no effect on
     * input parsing at all and every READ unconditionally discarded the
     * current line, causing a spurious "exhausted input" abort as soon
     * as a program tried to re-read a value from later in a line
     * READALL had already consumed part of.
     * inReadIOInit: true from the most recent IOINIT until the next one,
     * iff that IOINIT was a READ/READALL (iocode<=1) rather than a WRITE
     * (iocode 2/3) -- lets handle_control's shared SKIP/COLUMN cases
     * route to this read-side state instead of the write-side one.
     * readSkipPending/readColumnPending: -1 = not specified this
     * statement (apply_read_positioning's default: advance to a fresh
     * line, matching HAL/S's implicit SKIP(1) and yaGPC2's pre-existing
     * behavior for the common case).
     * readPositioningApplied: guards apply_read_positioning() to run
     * exactly once per READ statement (right before its first argument's
     * field extraction), since SKIP/COLUMN control specifiers can arrive
     * as multiple separate control-trap calls before any XXAR.
     * readAllStatement: true iff the current READ-family IOINIT's iocode
     * was 1 (READALL) rather than 0 (plain READ) -- USA003087 10.1.2:
     * READALL transfers CHARACTER data as a raw column range (no comma/
     * blank/semicolon delimiter parsing), unlike everything extract_next_
     * field() handles. See extract_readall_field() in halucp.c. */
    bool inReadIOInit;
    int readSkipPending;
    int readColumnPending;
    bool readPositioningApplied;
    /* Guards apply_read_positioning()'s SKIP-driven ib_reset() (the
     * "advance to a fresh line" step) separately from
     * readPositioningApplied (the whole-statement completion flag) --
     * needed because a COLUMN/TAB target can land beyond data that
     * hasn't been fetched yet (this READ statement is itself what
     * triggers the fetch, the common case for the first READ of a new
     * line under --interactive), in which case apply_read_positioning()
     * must return without finishing (leaving readPositioningApplied
     * false so it retries once halucp_provide_input() delivers the
     * awaited line) but must NOT re-run ib_reset() on that retry, which
     * would wipe the freshly-delivered data it's retrying against. */
    bool readSkipApplied;
    bool readAllStatement;

    int formatNumBlanks;
    bool verbose;

    int lineWidth;
    int linesPerPage;

    /* Inverted polarity vs JS's `firstWrite[ch] != false`: true once
     * channel ch has had its first WRITE/PRINT IOINIT (see header
     * comment / halucp.c for why this is also what "for ch of
     * @firstWrite" iterates over). */
    bool hasWrittenBefore[HALUCP_MAX_CHANNEL];
    /* Distinct from hasWrittenBefore, which flips true the moment IOINIT
     * runs -- i.e. already true by the time any item (including a
     * MATRIX/VECTOR's own row-1 SKIP) in that SAME first statement gets
     * processed, so it can't distinguish "this genuinely is the device's
     * first-ever WRITE statement" from "this is the 2nd, 3rd, ... one" at
     * the point where that distinction actually matters. everEmittedField
     * only flips true once a real field has actually been flushed --
     * still false throughout the whole first statement's own item
     * processing, true for every later one. Needed because MMWSNP.asm
     * (VECTOR/MATRIX WRITE output) unconditionally issues an "ACALL SKIP"
     * before every row, including row 1 -- see halucp.c's SKIP case.
     * USA003087 Sec. 12.2's "first WRITE statement executed for this
     * device" rule is a one-time, whole-program condition, NOT "is the
     * device currently sitting at column 1" -- those are different
     * things: a MATRIX's forced-fresh-line separator is a deliberate,
     * real effect anywhere *after* the true first write, even if column
     * happens to be 1 for some unrelated reason (e.g. the previous
     * statement's own output happened to end exactly at a line
     * boundary) -- conflating the two (an earlier attempt at this fix
     * gated on column==1 instead) silently discarded a following
     * explicit SKIP(n>1)'s own requested value whenever column
     * coincidentally started at 1, a real regression caught in review. */
    bool everEmittedField[HALUCP_MAX_CHANNEL];
    bool firstField[HALUCP_MAX_CHANNEL];
    int column[HALUCP_MAX_CHANNEL];
    int lineNumber[HALUCP_MAX_CHANNEL];
    HalUCPDeferredPos deferred[HALUCP_MAX_CHANNEL];
    bool suppressNextSep[HALUCP_MAX_CHANNEL];
    bool suppressNextAdvance[HALUCP_MAX_CHANNEL];

    /* Fixes problems.md 2.5 (negative TAB / backward COLUMN): USA003087
     * Sec. 12.4's TAB/COLUMN pseudo-functions can reposition the device
     * mechanism to any column, including *before* content already
     * written earlier in the same WRITE statement (Fig. 12-5's own
     * worked example) — a plain append-only output stream can't do
     * that, so each channel's current (not yet newline-terminated) line
     * is buffered here and fields are written into it at their target
     * column (arbitrary order, arbitrary direction), flushed to
     * outputCallback only when the line actually advances. positioned
     * tracks whether a TAB/COLUMN/SKIP/LINE/PAGE has already applied
     * within the current WRITE statement — a *leading* TAB is relative
     * to the column the mechanism was already at before this statement
     * began (persisted in `column`, never reset except by a real
     * newline), not column 1; once something has positioned the
     * mechanism, subsequent TABs are relative to that instead (see
     * halucp.c's handle_control TAB/COLUMN cases). */
    char *lineBuf[HALUCP_MAX_CHANNEL];
    size_t lineBufLen[HALUCP_MAX_CHANNEL], lineBufCap[HALUCP_MAX_CHANNEL];
    bool positioned[HALUCP_MAX_CHANNEL];
} HalUCP;

void halucp_init(HalUCP *h, CPU *cpu);
void halucp_free(HalUCP *h);

/* Wired into cpu->halUCPHandleSVC (see cpu.h); returns true if the SVC
 * was intercepted (caller should skip the standard PSW swap). */
bool halucp_handle_svc(void *halUCPvp, uint32_t ea, uint32_t r1);

/* Flushes channel ch's current line (whatever's sitting in lineBuf[ch],
 * per problems.md 2.5's per-channel line-buffering model) through
 * outputCallback and terminates it with a real newline. For callers
 * outside halucp.c (run.c's interactive-mode prompt logic) that need to
 * move to a fresh line before printing a prompt or detecting EOF --
 * calling this instead of writing a raw "\n" directly is what actually
 * flushes any buffered-but-not-yet-emitted text instead of silently
 * discarding it. */
void halucp_flush_channel(HalUCP *h, int ch);

/* Flushes every channel that still has an unflushed, non-newline-
 * terminated line buffered (lineBufLen[ch] > 0) -- the same guarded
 * all-channel loop the SVC 0x0015 (HALT) and unhandled-READ-EOF halt
 * paths already run inline, now shared so any other "this session is
 * ending" point (a driver stopping the run loop for --max-steps/
 * --break/--watch, or gpcops.c's embedded-engine release hook) can get
 * the same guarantee: a program's still-buffered last WRITE'd line is
 * never silently dropped just because it never itself executed a HALT.
 * Idempotent -- already-flushed channels have lineBufLen[ch] == 0 and
 * are skipped, so calling this after a HALT/EOF-triggered flush already
 * ran is a safe no-op, not a double flush. */
void halucp_flush_all_pending(HalUCP *h);

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
