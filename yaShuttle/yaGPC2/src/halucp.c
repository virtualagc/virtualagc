#include "halucp.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ebcdic.h"
#include "floatIBM.h"
#include "symboltable.h"

/* Forward decls (used before their definitions further down). */
static void read_char_string(HalUCP *h, char *out, size_t outSize);
static void write_char_string(HalUCP *h, const char *text);
static void write_input_value(HalUCP *h, const char *text);
static bool try_on_error_dispatch(HalUCP *h, int errGroup, int errNum);
static bool match_error_handler(uint32_t fixv, int errGroup, int errNum);
static bool handle_input(HalUCP *h);
static void hal_newline(HalUCP *h, int ch);

/* EVENT bit manipulation (SIGNAL/SET/RESET) -- see the definitions near
 * try_on_error_dispatch() for the full derivation. Shared between plain
 * SIGNAL/SET/RESET statements (handled directly in halucp_handle_svc,
 * below) and the ON ERROR ... IGNORE AND <action> disposition. */
typedef enum { IGNORE_EVENT_NONE, IGNORE_EVENT_SIGNAL, IGNORE_EVENT_SET, IGNORE_EVENT_RESET } IgnoreEventAction;
static void apply_ignore_event_action(HalUCP *h, uint32_t eventAddr, IgnoreEventAction action);

/* ---------------------------------------------------------------------
 * HAL/S Runtime Error Groups/Messages (AERROR macro GROUP/NUM params).
 * Verbatim from halUCP.coffee's SVC_ERROR_GROUPS/SVC_ERROR_MESSAGES —
 * including entry 22's mangled text, which is genuinely present in the
 * reference source (looks like an accidental paste of a file path into
 * the middle of the message during editing) and is reproduced exactly
 * for byte-for-byte fidelity, not "fixed".
 * ------------------------------------------------------------------- */

static const char *svc_error_group_name(int errGroup, char *buf, size_t bufSize) {
    if (errGroup >= 1 && errGroup <= 6) return "RUNTIME";
    snprintf(buf, bufSize, "GROUP %d", errGroup);
    return buf;
}

static const char *svc_error_message(int errNum, char *buf, size_t bufSize) {
    switch (errNum) {
        case 4: return "EXPONENTIATION OF ZERO TO POWER < = 0";
        case 5: return "SQRT HAS ARGUMENT < 0 ";
        case 6: return "EXP FUNCTION HAS ARGUMENT > 174.673";
        case 7: return "LOG FUNCTION (NATURAL LOG) HAS ARGUMENT < = 0";
        case 8: return "TSIN OR COS FUNCTION HAS |ARGUMENT| > ~2**18\xCE\xA0 (823,296)";
        case 9: return "SINH OR COSH FUNCTION HAS ARGUMENT > 175,366";
        case 10: return "ARCSIN OR ARCCOS FUNCTION HAS \xE2\x8F\x90""ARGUMENT\xE2\x8F\x90 > 1";
        case 11: return "TAN FUNCTION HAS |ARGUMENT| > ~2**18\xCE\xA0 (823,549.625) (SP) OR ~2**50\xCE\xA0 (3.537 X 10**15) (DP)";
        case 12: return "TAN FUNCTION TOO CLOSE TO SINGULARITY";
        case 14: return "NO RETURN STATEMENT IN FUNCTION";
        case 15: return "SCALAR TOO LARGE FOR INTEGER CONVERSION";
        case 16: return "DIVISION BY ZERO IN REMAINDER";
        case 17: return "ILLEGAL CHARACTER SUBSCRIPT";
        case 18: return "BAD LENGTH IN LJUST OR RJUST";
        case 19: return "MOD DOMAIN ERROR ";
        case 20: return "CHARACTER TO SCALAR CONVERSION";
        case 22: return "CHARACTER TO INTEGER CONVERSION";
        case 24: return "NEGATIVE BASE IN EXPONENTIATION";
        case 25: return "VECTOR/MATRIX DIVISION BY ZERO";
        case 27: return "ARGUMENT OF INVERSE IS A SINGULAR MATRIX";
        case 28: return "ARGUMENT OF UNIT FUNCTION IS NULL VECTOR";
        case 29: return "ILLEGAL BIT STRING ";
        case 30: return "ILLEGAL SUBBIT SUBSCRIPT ";
        case 31: return "BIT@OCT - INVALID CHARACTER";
        case 32: return "BIT@HEX - INVALID CHARACTER";
        case 33: return "MOD RELATIVE MAGNITUDE ERROR";
        case 50: return "ERROR IN HAL/S SOURCE ";
        case 59: return "ARCCOSH FUNCTION HAS ARGUMENT <1";
        case 60: return "ARCTANH FUNCTION HAS \xE2\x8F\x90""ARGUMENT\xE2\x8F\x90 >= 1";
        case 62: return "ARCTAN2 ARGUMENTS ARE ZERO";
        default:
            snprintf(buf, bufSize, "ERROR %d", errNum);
            return buf;
    }
}

/* ---------------------------------------------------------------------
 * Construction / mainStorage helpers
 * ------------------------------------------------------------------- */

void halucp_init(HalUCP *h, CPU *cpu) {
    memset(h, 0, sizeof(*h));
    h->cpu = cpu;
    h->trapSvcError = true;
    h->iobufAscii = false; /* ebcdic default */
    h->formatNumBlanks = 5;
    h->lineWidth = -1; /* sentinel: no explicit override, use per-channel
                         * PAGED(132)/UNPAGED(80) default -- see
                         * effective_line_width() */
    h->linesPerPage = 66; /* IBM 1403 line printer's own documented
                           * lines-per-page (this project's own
                           * historical target hardware) -- matches
                           * yaHALMAT2's independently-researched same
                           * default (state.h). Only meaningful for
                           * PAGED devices (see hal_newline's automatic
                           * page-turn and handle_control's LINE/PAGE
                           * cases). */
    h->inputBufferCap = 64;
    h->inputBuffer = malloc(h->inputBufferCap);
    h->inputBuffer[0] = '\0';
    h->inputBufferLen = 0;
    h->inputColumn = 1;
    h->readSkipPending = -1;
    h->readColumnPending = -1;
    for (int i = 0; i < HALUCP_MAX_CHANNEL; i++) {
        h->column[i] = 1;
        h->lineNumber[i] = 1;
    }
}

void halucp_free(HalUCP *h) {
    free(h->inputBuffer);
    for (int i = 0; i < HALUCP_MAX_CHANNEL; i++) free(h->lineBuf[i]);
    memset(h, 0, sizeof(*h));
}

static uint32_t hal_get32(HalUCP *h, uint32_t addr) {
    uint32_t hi = mcm_get16(&h->cpu->mainStorage, addr);
    uint32_t lo = mcm_get16(&h->cpu->mainStorage, addr + 1);
    return (hi << 16) | lo;
}

static void hal_set32(HalUCP *h, uint32_t addr, uint32_t val) {
    mcm_set16(&h->cpu->mainStorage, addr, (val >> 16) & 0xffff, false);
    mcm_set16(&h->cpu->mainStorage, addr + 1, val & 0xffff, false);
}

static void hal_log(HalUCP *h, const char *s) {
    if (h->verbose) fputs(s, stderr);
}

void halucp_log_cb(void *halUCPvp, const char *msg) {
    hal_log((HalUCP *)halUCPvp, msg);
}

static void hal_report_error(HalUCP *h, const char *msg) {
    if (h->errorCallback) {
        h->errorCallback(h->cbCtx, msg);
    } else {
        fprintf(stderr, "%s\n", msg);
    }
}

/* ---------------------------------------------------------------------
 * SVC handling
 * ------------------------------------------------------------------- */

bool halucp_handle_svc(void *halUCPvp, uint32_t ea, uint32_t r1) {
    HalUCP *h = halUCPvp;
    if (!h->trapSvcError) return false;

    uint32_t hw0 = mcm_get16(&h->cpu->mainStorage, ea);
    uint32_t hw1 = mcm_get16(&h->cpu->mainStorage, ea + 1);
    uint32_t nia = psw_get_nia(&h->cpu->psw);
    char dbg[256];
    snprintf(dbg, sizeof dbg, "SVC DEBUG: ea=0x%x R1=0x%x NIA=0x%x mem[ea]=0x%04x mem[ea+1]=0x%04x\n",
             ea, r1, nia, hw0, hw1);
    hal_log(h, dbg);

    uint32_t svcCode = hw0;

    if (svcCode == 0x0015) {
        if (h->inputBufferLen > 0) {
            size_t need = h->inputBufferLen + 64;
            char *warnMsg = malloc(need);
            snprintf(warnMsg, need, "HalUCP: WARNING: unconsumed buffered input: %s", h->inputBuffer);
            hal_report_error(h, warnMsg);
            free(warnMsg);
            h->inputBufferLen = 0;
            h->inputBuffer[0] = '\0';
        }
        for (int ch = 0; ch < HALUCP_MAX_CHANNEL; ch++) {
            if (h->lineBufLen[ch] > 0 && h->outputCallback) {
                /* hal_newline(), not a bare "\n": the program is halting
                 * with its last line's content possibly still sitting in
                 * lineBuf[ch] (never yet flushed by an explicit
                 * SKIP/LINE/PAGE), and a bare newline here would discard
                 * it silently. Gated on lineBufLen (not just
                 * hasWrittenBefore) so a channel some OTHER code path
                 * (e.g. run.c's interactive-prompt logic) already
                 * flushed doesn't get a second, spurious blank line. */
                hal_newline(h, ch);
            }
        }
        const char *msg = "HAL/S PROGRAM HALT (SVC 0)";
        if (h->errorCallback) {
            h->errorCallback(h->cbCtx, msg);
        } else {
            fprintf(stderr, "%s\n", msg);
        }
        psw_set_wait_state(&h->cpu->psw, true);
        h->svcTrapped = true;
        return true;
    }

    if (svcCode == 0x0014) {
        uint32_t errDesc = mcm_get16(&h->cpu->mainStorage, ea + 1);
        int errGroup = (int)((errDesc >> 8) & 0xff);
        int errNum = (int)(errDesc & 0xff);
        h->lastErrGroup = errGroup;
        h->lastErrNum = errNum;
        char gbuf[32], mbuf[32];
        const char *groupName = svc_error_group_name(errGroup, gbuf, sizeof gbuf);
        const char *errMsg = svc_error_message(errNum, mbuf, sizeof mbuf);
        char msg[512];
        snprintf(msg, sizeof msg, "HAL/S SEND ERROR: %s: #%d %s", groupName, errNum, errMsg);
        hal_report_error(h, msg);
        try_on_error_dispatch(h, errGroup, errNum);
        return true;
    }

    /* ERRGRP/ERRNUM built-ins (USA003087: "returns group/number of last
     * error detected, or zero") -- confirmed via a real HALSFC-compiled
     * listing (test_errgrp_errnum.hal) to compile to these two fixed SVC
     * codes (identical at every call site in the test, not a per-site
     * literal like SEND ERROR's AERROR-macro-generated ones), with the
     * result expected back in R5's upper halfword (the immediately
     * following compiled instruction is always `STH 5,<dest>`, and
     * exec_STH stores register_get32(...)>>16). Neither `gpc` nor
     * `yaGPC` ever implemented these -- a genuine omission inherited
     * into yaGPC2 until now, not a per-tool quirk. */
    if (svcCode == 0x0117) {
        register_set32(cpu_r(h->cpu, 5), (uint32_t)h->lastErrGroup << 16);
        return true;
    }
    if (svcCode == 0x0217) {
        register_set32(cpu_r(h->cpu, 5), (uint32_t)h->lastErrNum << 16);
        return true;
    }

    /* Plain SIGNAL/SET/RESET <event> statements (not part of an ON ERROR
     * IGNORE disposition -- see apply_ignore_event_action's own comment
     * near try_on_error_dispatch() for the EVENT bit representation this
     * relies on). Confirmed via a minimal compiled test: these compile
     * directly to these three fixed SVC codes, with the event's own
     * address as the second operand halfword (mem[ea+1]) -- the exact
     * same convention SEND ERROR (0x0014) uses for its group/num data. */
    if (svcCode == 0x000C || svcCode == 0x000D || svcCode == 0x000E) {
        uint32_t eventAddr = mcm_get16(&h->cpu->mainStorage, ea + 1);
        IgnoreEventAction action = svcCode == 0x000E ? IGNORE_EVENT_RESET
                                  : svcCode == 0x000D ? IGNORE_EVENT_SET
                                                       : IGNORE_EVENT_SIGNAL;
        apply_ignore_event_action(h, eventAddr, action);
        return true;
    }

    char msg[160];
    snprintf(msg, sizeof msg, "HAL/S SVC trapped (ea=0x%x, R1=0x%x, code=0x%x)", ea, r1, svcCode);
    hal_report_error(h, msg);
    h->svcTrapped = true;
    return true;
}

/* ---------------------------------------------------------------------
 * Trap-address resolution from symbols
 * ------------------------------------------------------------------- */

void halucp_init_from_symbols(HalUCP *h, const SymbolTable *st) {
    if (!st->loaded || st->sectionCount == 0 || st->symbolCount == 0) return;

    uint32_t ioinitBase = 0;
    bool hasIoinit = false;
    for (int i = 0; i < st->sectionCount; i++) {
        if (strcmp(st->sections[i].name, "IOINIT") == 0) {
            ioinitBase = st->sections[i].address;
            hasIoinit = true;
            break;
        }
    }
    if (!hasIoinit) {
        hal_log(h, "HalUCP: IOINIT section not found in symbols\n");
        return;
    }

    /* Note: the JS checks `sym.type == 'entry'`, but this port's Symbol
     * struct doesn't carry a `type` field (symboltable.c never reads it
     * — the .sym.json schema this repo has seen doesn't populate a
     * per-symbol `type`). Matching on name alone is a deliberate,
     * documented simplification: if a real symbols file ever has
     * multiple same-named INTRAP/IOCODE/IOBUF entries where the 'entry'
     * one isn't first, this would diverge. Revisit if Phase 11 finds
     * such a file. */
    bool hasIntrap = false, hasIocode = false, hasIobuf = false;
    uint32_t intrapAddr = 0, iocodeAddr = 0, iobufAddr = 0;
    for (int i = 0; i < st->symbolCount; i++) {
        if (!hasIntrap && strcmp(st->symbols[i].name, "INTRAP") == 0) {
            intrapAddr = st->symbols[i].address;
            hasIntrap = true;
        } else if (!hasIocode && strcmp(st->symbols[i].name, "IOCODE") == 0) {
            iocodeAddr = st->symbols[i].address;
            hasIocode = true;
        } else if (!hasIobuf && strcmp(st->symbols[i].name, "IOBUF") == 0) {
            iobufAddr = st->symbols[i].address;
            hasIobuf = true;
        }
    }
    if (!hasIntrap || !hasIocode || !hasIobuf) {
        char msg[128];
        snprintf(msg, sizeof msg, "HalUCP: Missing required symbols (INTRAP=%s, IOCODE=%s, IOBUF=%s)\n",
                 hasIntrap ? "set" : "undefined", hasIocode ? "set" : "undefined", hasIobuf ? "set" : "undefined");
        hal_log(h, msg);
        return;
    }

    uint32_t outrap = ioinitBase + 0x11;
    uint32_t cntrap = ioinitBase + 0x40;

    h->outrap = outrap;
    h->intrap = intrapAddr;
    h->cntrap = cntrap;
    h->hasTrapAddrs = true;
    h->iocodeAddr = iocodeAddr;
    h->iobufAddr = iobufAddr;

    h->iobufAscii = false;
    if (st->symTypeCount > 0) {
        const char *iobufSection = NULL;
        for (int i = 0; i < st->sectionCount; i++) {
            if (iobufAddr >= st->sections[i].address && iobufAddr < st->sections[i].address + st->sections[i].size) {
                iobufSection = st->sections[i].name;
                break;
            }
        }
        const SymType *typeInfo = NULL;
        if (iobufSection) {
            char qualified[256];
            snprintf(qualified, sizeof qualified, "%s.IOBUF", iobufSection);
            typeInfo = symtable_get_symtype(st, qualified);
        }
        if (!typeInfo) typeInfo = symtable_get_symtype(st, "IOBUF");
        if (typeInfo && typeInfo->type && strcmp(typeInfo->type, "ascii") == 0) {
            h->iobufAscii = true;
        }
    }

    h->active = true;

    char msg[256];
    snprintf(msg, sizeof msg, "HalUCP: Trap addresses resolved - OUTRAP=0x%x, INTRAP=0x%x, CNTRAP=0x%x\n", outrap, intrapAddr, cntrap);
    hal_log(h, msg);
    snprintf(msg, sizeof msg, "HalUCP: IOCODE=0x%x, IOBUF=0x%x, encoding=%s\n", iocodeAddr, iobufAddr, h->iobufAscii ? "ascii" : "ebcdic");
    hal_log(h, msg);
}

bool halucp_is_trap_addr(HalUCP *h, uint32_t nia) {
    if (!h->hasTrapAddrs) return false;
    if (h->skipTrap) {
        h->skipTrap = false;
        return false;
    }
    return nia == h->outrap || nia == h->intrap || nia == h->cntrap;
}

/* ---------------------------------------------------------------------
 * Channel mode
 * ------------------------------------------------------------------- */

const char *halucp_get_channel_mode(HalUCP *h, int ch) {
    if (ch < 0 || ch >= HALUCP_MAX_CHANNEL) return "paged";
    return h->channelMode[ch] == 2 ? "unpaged" : "paged";
}

void halucp_set_channel_mode(HalUCP *h, int ch, const char *mode) {
    if (ch < 0 || ch >= HALUCP_MAX_CHANNEL) return;
    h->channelMode[ch] = (strcmp(mode, "unpaged") == 0) ? 2 : 1;
}

bool halucp_is_paged(HalUCP *h, int ch) {
    return strcmp(halucp_get_channel_mode(h, ch), "paged") == 0;
}

/* USA003090 Sec. 6.1.4: a channel with no RECFM/LRECL supplied defaults to
 * LRECL 133 (PAGED) or 80 (UNPAGED). PAGED additionally defaults to RECFM
 * FBA -- the "A" meaning an ANSI/ASA carriage-control character is
 * automatically generated as byte 1 of every output record -- so PAGED's
 * 133-byte LRECL is 1 non-printing control byte plus 132 *printable*
 * columns (matching the IBM 1403 line printer's own documented print
 * width, this runtime's historical target hardware), not 133 printable
 * columns; UNPAGED has no such byte, so its 80-byte LRECL is fully
 * printable. yaHALMAT2 independently reached the same conclusion (see its
 * state.h). `--line-width` overrides this per-channel default uniformly
 * for every channel, when explicitly passed (h->lineWidth >= 0). */
static int effective_line_width(HalUCP *h, int ch) {
    if (h->lineWidth >= 0) return h->lineWidth;
    return halucp_is_paged(h, ch) ? 132 : 80;
}

/* ---------------------------------------------------------------------
 * Field formatting
 * ------------------------------------------------------------------- */

static void format_integer(int64_t val, char *out, size_t outSize) {
    char digits[24];
    snprintf(digits, sizeof digits, "%lld", (long long)val);
    size_t len = strlen(digits);
    if (len < 11) {
        size_t pad = 11 - len;
        if (pad >= outSize) pad = outSize > 0 ? outSize - 1 : 0;
        size_t i = 0;
        for (; i < pad; i++) out[i] = ' ';
        snprintf(out + i, outSize - i, "%s", digits);
    } else {
        snprintf(out, outSize, "%s", digits);
    }
}

static void format_scalar(const FloatIBM *ibmFloat, int fracDigits, int totalWidth, char *out, size_t outSize) {
    double v = fibm_to_float(ibmFloat);
    if (v == 0) {
        snprintf(out, outSize, "%-*s", totalWidth, " 0.0");
        return;
    }
    char sign = v < 0 ? '-' : ' ';
    double av = fabs(v);
    int exp = (int)floor(log10(av));
    double mantissa = av / pow(10.0, exp);
    if (mantissa >= 10) {
        mantissa /= 10;
        exp += 1;
    } else if (mantissa < 1 && mantissa > 0) {
        mantissa *= 10;
        exp -= 1;
    }
    char mantissaStr[64];
    snprintf(mantissaStr, sizeof mantissaStr, "%.*f", fracDigits, mantissa);
    char *dot = strchr(mantissaStr, '.');
    if (!dot || (dot - mantissaStr) != 1) {
        mantissa = mantissa / 10;
        exp += 1;
        snprintf(mantissaStr, sizeof mantissaStr, "%.*f", fracDigits, mantissa);
    }
    char expSign = exp >= 0 ? '+' : '-';
    int absExp = exp >= 0 ? exp : -exp;
    snprintf(out, outSize, "%c%sE%c%02d", sign, mantissaStr, expSign, absExp);
}

/* ---------------------------------------------------------------------
 * Output positioning / field emission
 * ------------------------------------------------------------------- */

/* Flushes ch's buffered (not yet newline-terminated) line to
 * outputCallback, then resets the buffer for the next line. Mirrors
 * yaHALMAT2's dm_finalize_line (interp.c) — the buffer is what makes
 * out-of-order/backward TAB/COLUMN placement possible (see halucp.h's
 * lineBuf comment): fields are written into it at their target column
 * regardless of call order, and only this flush commits the assembled
 * bytes to the real output stream. */
static void hal_newline(HalUCP *h, int ch) {
    if (h->outputCallback) {
        if (h->lineBufLen[ch] > 0) h->outputCallback(h->cbCtx, h->lineBuf[ch], ch);
        h->outputCallback(h->cbCtx, "\n", ch);
    }
    h->lineBufLen[ch] = 0;
    h->lineNumber[ch] += 1;
    h->column[ch] = 1;
    /* Automatic page turn: USA003087 Sec. 12.4 rule 2 documents that an
     * explicit SKIP(alpha) may cross page boundaries ("SKIPs over page
     * boundaries are allowed"), and gives no reason the device mechanism
     * would behave any differently for the *default* one-line advance
     * every WRITE/READ gets absent an overriding SKIP/LINE/PAGE -- it's
     * the same "device mechanism" either way, just moved by a different
     * trigger. The manual never spells out "and when a PAGED device's
     * line count would exceed its page length, turn the page" explicitly
     * because that's simply how a physical line printer behaves --
     * obvious enough not to need stating, unlike the deliberately-
     * documented SKIP/LINE/PAGE pseudo-functions themselves. This is
     * every ordinary line advance's single shared choke point (the
     * implicit per-WRITE default, an explicit SKIP(n) via the loop
     * below, and LINE(gamma)/PAGE(beta)'s own delta-based loops in
     * handle_control) -- one check here covers all of them uniformly,
     * without needing a separate explicit page-break emission at each
     * call site, and (for PAGE(beta) specifically) naturally reproduces
     * Fig. 12-7's "relative line number unchanged" behavior as a side
     * effect of always wrapping at exactly linesPerPage regardless of
     * the starting line. */
    if (halucp_is_paged(h, ch) && h->lineNumber[ch] > h->linesPerPage) {
        if (h->outputCallback) h->outputCallback(h->cbCtx, "\f", ch);
        h->lineNumber[ch] = 1;
    }
}

void halucp_flush_channel(HalUCP *h, int ch) {
    hal_newline(h, ch);
}

void halucp_notify_interactive_input(HalUCP *h, int ch) {
    if (ch < 0 || ch >= HALUCP_MAX_CHANNEL) return;
    h->column[ch] = 1;
    h->suppressNextAdvance[ch] = true;
}

/* Writes `text` (length `len`) into ch's line buffer starting at 1-based
 * column `col`, growing the buffer as needed and space-padding any gap
 * between its current high-water content and `col` (so a forward jump
 * past what's been written so far reads as blanks, matching a real
 * device mechanism moving right over untouched paper). Does not touch
 * anything already in the buffer beyond `col + len` — a COLUMN/TAB that
 * jumps backward and writes a *shorter* field correctly leaves the
 * remainder of what's already there untouched (overstrike, not
 * replace-to-end-of-line — confirmed against yaHALMAT2's dm_write_at,
 * which this mirrors, and against USA003087 Fig. 12-5's own worked
 * example of exactly this scenario). */
static void buf_write_at(HalUCP *h, int ch, int col, const char *text, int len) {
    size_t start = (size_t)(col - 1);
    size_t need = start + (size_t)len;
    if (need > h->lineBufCap[ch]) {
        size_t newCap = h->lineBufCap[ch] ? h->lineBufCap[ch] * 2 : 128;
        while (newCap < need) newCap *= 2;
        h->lineBuf[ch] = realloc(h->lineBuf[ch], newCap + 1);
        h->lineBufCap[ch] = newCap;
    }
    if (start > h->lineBufLen[ch]) {
        memset(h->lineBuf[ch] + h->lineBufLen[ch], ' ', start - h->lineBufLen[ch]);
    }
    if (len > 0) memcpy(h->lineBuf[ch] + start, text, (size_t)len);
    if (need > h->lineBufLen[ch]) h->lineBufLen[ch] = need;
    h->lineBuf[ch][h->lineBufLen[ch]] = '\0';
}

static void flush_positioning(HalUCP *h, int ch) {
    if (!h->deferred[ch].present) return;
    HalUCPDeferredPos pos = h->deferred[ch];
    h->deferred[ch].present = false;
    for (int i = 0; i < pos.downLines; i++) hal_newline(h, ch);
    h->everEmittedField[ch] = true;
    /* Unconditional, not just "if toCol > column": a leading COLUMN/TAB
     * that lands *before* the default column-1 reset is exactly Fig.
     * 12-5's scenario (fixes problems.md 2.5) — the actual byte
     * placement happens lazily, via buf_write_at when the next field is
     * emitted, which pads or overstrikes correctly either direction. */
    h->column[ch] = pos.toCol;
}

static void emit_field(HalUCP *h, const char *fieldText, bool isChar) {
    int ch = h->channel;
    flush_positioning(h, ch);
    int lineWidth = effective_line_width(h, ch);

    bool needSep = (!h->firstField[ch]) && (!h->suppressNextSep[ch]);
    h->suppressNextSep[ch] = false;
    int sepLen = needSep ? h->formatNumBlanks : 0;
    int fieldLen = (int)strlen(fieldText);

    if (!isChar) {
        if (h->column[ch] + sepLen + fieldLen - 1 > lineWidth) {
            hal_newline(h, ch);
            buf_write_at(h, ch, h->column[ch], fieldText, fieldLen);
            h->column[ch] += fieldLen;
        } else {
            int col = h->column[ch] + sepLen;
            buf_write_at(h, ch, col, fieldText, fieldLen);
            h->column[ch] = col + fieldLen;
        }
    } else {
        if (sepLen > 0) {
            if (h->column[ch] + sepLen > lineWidth + 1) {
                hal_newline(h, ch);
            } else {
                h->column[ch] += sepLen;
            }
        }
        int pos = 0;
        while (pos < fieldLen) {
            if (h->column[ch] > lineWidth) hal_newline(h, ch);
            int remaining = lineWidth - h->column[ch] + 1;
            int take = remaining < (fieldLen - pos) ? remaining : (fieldLen - pos);
            if (take <= 0) take = fieldLen - pos; /* defensive: avoid infinite loop */
            buf_write_at(h, ch, h->column[ch], fieldText + pos, take);
            h->column[ch] += take;
            pos += take;
        }
    }
    h->firstField[ch] = false;
}

/* ---------------------------------------------------------------------
 * handleOutput / handleControl
 * ------------------------------------------------------------------- */

static void handle_output(HalUCP *h) {
    int iocode = (int)mcm_get16(&h->cpu->mainStorage, h->iocodeAddr);
    char text[1024];
    text[0] = '\0';
    bool isChar = false;

    switch (iocode) {
        case 8: { /* BOUT - bit string */
            int len = (int)mcm_get16(&h->cpu->mainStorage, h->iobufAddr);
            uint32_t bits = hal_get32(h, h->iobufAddr + 2);
            char bitStr[33];
            for (int i = 0; i < 32; i++) bitStr[i] = ((bits >> (31 - i)) & 1) ? '1' : '0';
            bitStr[32] = '\0';
            int start = 32 - len;
            if (start < 0) start = 0;
            if (start > 32) start = 32;
            const char *sub = bitStr + start;
            char spaced[80];
            int sp = 0;
            int sublen = (int)strlen(sub);
            for (int j = 0; j < sublen; j += 4) {
                if (j > 0) spaced[sp++] = ' ';
                int take = sublen - j < 4 ? sublen - j : 4;
                memcpy(spaced + sp, sub + j, (size_t)take);
                sp += take;
            }
            spaced[sp] = '\0';
            if (halucp_is_paged(h, h->channel)) {
                snprintf(text, sizeof text, "%s", spaced);
            } else {
                snprintf(text, sizeof text, "'%s'", spaced);
            }
            break;
        }
        case 9: { /* IOUT - int32 */
            uint32_t raw = hal_get32(h, h->iobufAddr);
            int64_t val = (raw & 0x80000000u) ? (int64_t)raw - 0x100000000LL : (int64_t)raw;
            format_integer(val, text, sizeof text);
            break;
        }
        case 10: { /* HOUT - int16 */
            uint32_t raw = mcm_get16(&h->cpu->mainStorage, h->iobufAddr);
            int64_t val = (raw & 0x8000u) ? (int64_t)raw - 0x10000LL : (int64_t)raw;
            format_integer(val, text, sizeof text);
            break;
        }
        case 11: { /* EOUT - float SP */
            uint32_t w = hal_get32(h, h->iobufAddr);
            FloatIBM f = fibm_from32(w);
            format_scalar(&f, 7, 14, text, sizeof text);
            break;
        }
        case 12: { /* DOUT - float DP */
            uint32_t w1 = hal_get32(h, h->iobufAddr);
            uint32_t w2 = hal_get32(h, h->iobufAddr + 2);
            FloatIBM f = fibm_from64(w1, w2);
            format_scalar(&f, 16, 23, text, sizeof text);
            break;
        }
        case 13: { /* COUT - character string */
            isChar = true;
            char raw[512];
            read_char_string(h, raw, sizeof raw);
            if (!halucp_is_paged(h, h->channel)) {
                /* UNPAGED: enclose in apostrophes, double internal apostrophes */
                char quoted[1024];
                size_t qi = 0;
                quoted[qi++] = '\'';
                for (const char *p = raw; *p && qi < sizeof(quoted) - 3; p++) {
                    if (*p == '\'') quoted[qi++] = '\'';
                    quoted[qi++] = *p;
                }
                quoted[qi++] = '\'';
                quoted[qi] = '\0';
                snprintf(text, sizeof text, "%s", quoted);
            } else {
                snprintf(text, sizeof text, "%s", raw);
            }
            break;
        }
        default:
            snprintf(text, sizeof text, "[IOCODE=%d?]", iocode);
            break;
    }

    emit_field(h, text, isChar);
}

static void handle_control(HalUCP *h) {
    int iocode = (int)mcm_get16(&h->cpu->mainStorage, h->iocodeAddr);
    int32_t param = (int32_t)mcm_get16(&h->cpu->mainStorage, h->iobufAddr);
    if (iocode == 6 && (param & 0x8000)) param -= 0x10000;

    switch (iocode) {
        case 0:
        case 1:
        case 2:
        case 3: { /* IOINIT */
            int ch = (int)param;
            h->channel = ch;
            if (iocode <= 1) {
                h->readTerminated = false;
                h->inReadIOInit = true;
                h->readSkipPending = -1;
                h->readColumnPending = -1;
                h->readPositioningApplied = false;
                /* inputBuffer is deliberately NOT wiped here anymore --
                 * see apply_read_positioning(), which defers that
                 * decision until this statement's SKIP/COLUMN control
                 * specifiers (processed next, before any XXAR) are
                 * known. */
            } else {
                h->inReadIOInit = false;
                if (h->deferred[ch].present) flush_positioning(h, ch);
                if (!h->hasWrittenBefore[ch]) {
                    h->hasWrittenBefore[ch] = true;
                    /* Must clear here too, not just in the sibling
                     * suppressNextAdvance branch below -- otherwise a
                     * flag set by halucp_notify_interactive_input() and
                     * left dangling (because THIS write happened to be
                     * the channel's first-ever, taking this branch
                     * instead) would incorrectly suppress the *next*
                     * WRITE's newline advance too, merging two unrelated
                     * WRITE statements onto one line (found via
                     * 254-TEST2.hal: a READ followed by two independent
                     * IF-THEN-WRITE statements printed with no newline
                     * between them). */
                    h->suppressNextAdvance[ch] = false;
                    h->deferred[ch].present = true;
                    h->deferred[ch].downLines = 0;
                    /* No real line movement — column[ch] is already 1
                     * (halucp_init's default), so this just carries it
                     * forward rather than hardcoding 1. Matters because
                     * a compiled WRITE statement issues a fresh IOINIT
                     * per field, not just once at the statement's start
                     * (confirmed via tracing test_read_eof_onerror.hal's
                     * "RESULTS OF TESTING..." line) — hardcoding toCol=1
                     * here would clobber the running column of every
                     * field after the first, undoing problems.md 2.5's
                     * fix (the old "only apply toCol if greater than
                     * column[ch]" guard papered over this by accident;
                     * the real fix is to only ever *reset* to column 1
                     * when downLines>0 actually moves to a fresh line,
                     * below). */
                    h->deferred[ch].toCol = h->column[ch];
                } else if (h->suppressNextAdvance[ch]) {
                    h->suppressNextAdvance[ch] = false;
                    h->deferred[ch].present = true;
                    h->deferred[ch].downLines = 0;
                    h->deferred[ch].toCol = h->column[ch]; /* see comment above */
                } else {
                    h->deferred[ch].present = true;
                    h->deferred[ch].downLines = 1;
                    h->deferred[ch].toCol = 1;
                }
                h->firstField[ch] = true;
                h->suppressNextSep[ch] = false;
                /* Nothing has positioned the mechanism within this new
                 * WRITE statement yet — see the TAB case's comment. */
                h->positioned[ch] = false;
            }
            break;
        }
        case 4: { /* LINE */
            int ch = h->channel;
            int curLine = h->lineNumber[ch];
            int delta;
            if (halucp_is_paged(h, ch)) {
                if (param >= curLine) delta = (int)param - curLine;
                else delta = (h->linesPerPage - curLine) + (int)param;
            } else {
                delta = (int)param - curLine;
                if (delta < 0) {
                    char msg[128];
                    snprintf(msg, sizeof msg, "HalUCP: LINE(%d) cannot move upward from line %d\n", param, curLine);
                    hal_log(h, msg);
                    delta = 0;
                }
            }
            if (h->deferred[ch].present) {
                h->deferred[ch].downLines = delta;
            } else {
                for (int i = 0; i < delta; i++) hal_newline(h, ch);
            }
            h->positioned[ch] = true;
            break;
        }
        case 5: { /* COLUMN: absolute — USA003087 Sec. 12.4 rule 3. Any
                   * target column (forward or backward relative to
                   * wherever the mechanism currently is) is valid; the
                   * actual byte placement is handled lazily by
                   * buf_write_at when the next field is emitted, which
                   * pads or overstrikes correctly either direction
                   * (fixes problems.md 2.5's "backwards, unimplemented"
                   * gap). */
            int ch = h->channel;
            if (param < 1) {
                char msg[64];
                snprintf(msg, sizeof msg, "HalUCP: COLUMN(%d) below column 1\n", param);
                hal_log(h, msg);
            } else if (h->inReadIOInit) {
                h->readColumnPending = (int)param;
            } else if (h->deferred[ch].present) {
                h->deferred[ch].toCol = (int)param;
            } else {
                h->column[ch] = (int)param;
            }
            if (!h->inReadIOInit) {
                h->positioned[ch] = true;
                h->suppressNextSep[ch] = true;
            }
            break;
        }
        case 6: { /* TAB: relative — USA003087 Sec. 12.4 rule 2/Fig.
                   * 12-5. A *leading* TAB (nothing has positioned this
                   * WRITE statement's mechanism yet) is relative to the
                   * column the mechanism was already at *before* this
                   * statement's default line advance reset it — which
                   * is exactly what `column[ch]` still holds, since
                   * nothing else touches it between the previous
                   * statement's last field and here. Once something has
                   * positioned the mechanism this statement, subsequent
                   * TABs are relative to that instead (ordinary
                   * sequential application). Fixes problems.md 2.5. */
            int ch = h->channel;
            if (h->deferred[ch].present) {
                int base = h->positioned[ch] ? h->deferred[ch].toCol : h->column[ch];
                int newCol = base + (int)param;
                if (newCol < 1) {
                    char msg[64];
                    snprintf(msg, sizeof msg, "HalUCP: TAB(%d) cannot move left of column 1\n", param);
                    hal_log(h, msg);
                    newCol = 1;
                }
                h->deferred[ch].toCol = newCol;
            } else {
                int target = h->column[ch] + (int)param;
                if (target < 1) {
                    char msg[64];
                    snprintf(msg, sizeof msg, "HalUCP: TAB(%d) cannot move left of column 1\n", param);
                    hal_log(h, msg);
                    target = 1;
                }
                h->column[ch] = target;
            }
            h->positioned[ch] = true;
            h->suppressNextSep[ch] = true;
            break;
        }
        case 7: { /* PAGE */
            int ch = h->channel;
            if (param > 0) {
                int downLines = (int)param * h->linesPerPage;
                if (h->deferred[ch].present) {
                    h->deferred[ch].downLines = downLines;
                } else {
                    for (int i = 0; i < downLines; i++) hal_newline(h, ch);
                }
                h->positioned[ch] = true;
            }
            break;
        }
        case 8: { /* SKIP */
            int ch = h->channel;
            if (param < 0) {
                char msg[64];
                snprintf(msg, sizeof msg, "HalUCP: SKIP(%d) negative count not allowed\n", param);
                hal_log(h, msg);
            } else if (h->inReadIOInit) {
                h->readSkipPending = (int)param;
            } else if (h->deferred[ch].present) {
                /* USA003087 Sec. 12.2: a device's TRUE first-ever WRITE
                 * performs only "initial positioning" -- zero downward
                 * movement -- regardless of any SKIP/LINE/PAGE request.
                 * IOINIT (case 2/3 above) already encodes this correctly
                 * (downLines=0 when !hasWrittenBefore), but MMWSNP.asm's
                 * VECTOR/MATRIX output routine unconditionally issues its
                 * own "ACALL SKIP" before every row -- including row 1 --
                 * with no way (at this SVC-trap level, mirroring the real
                 * hardware's own shared trap handler) to tell an RTL-
                 * internal row-separator SKIP apart from a genuine
                 * user-authored SKIP() pseudo-function.
                 *
                 * Gated on everEmittedField (has *any* field ever been
                 * flushed on this channel, whole-program lifetime), NOT
                 * on the device's current column. An earlier version of
                 * this fix gated on column[ch]!=1 instead, reasoning by
                 * analogy with yaHALMAT2's own WITHIN-a-statement
                 * "`WRITE(6) 'SUM=',V;` still forces V's own fresh line
                 * since column has already advanced past 1" case -- but
                 * that conflates two different things (caught in review):
                 * "this is genuinely the device's first-ever WRITE
                 * statement" (a one-time, whole-program condition, where
                 * discarding the redundant leading advance is correct)
                 * vs. "the device currently happens to sit at column 1"
                 * (which can ALSO be true anywhere later in the program,
                 * e.g. right after some earlier, unrelated statement's
                 * output happened to end exactly at a line boundary) --
                 * in that second case a MATRIX's forced-fresh-line
                 * separator is a real, intentional effect, not
                 * redundant, and suppressing it on column==1 alone
                 * silently discarded a *later*, unrelated explicit
                 * SKIP(n>1)'s own requested value too whenever it
                 * happened to follow a coincidental column-1 start. */
                if (h->everEmittedField[ch]) {
                    h->deferred[ch].downLines = (int)param;
                }
            } else {
                for (int i = 0; i < (int)param; i++) hal_newline(h, ch);
            }
            if (!h->inReadIOInit) h->positioned[ch] = true;
            break;
        }
        default: {
            char msg[64];
            snprintf(msg, sizeof msg, "HalUCP: Unknown control IOCODE=%d\n", iocode);
            hal_log(h, msg);
            break;
        }
    }
}

bool halucp_check_trap(HalUCP *h, uint32_t nia) {
    if (!h->hasTrapAddrs) return true; /* 'continue' */

    if (nia == h->outrap) {
        handle_output(h);
        return true;
    } else if (nia == h->cntrap) {
        handle_control(h);
        return true;
    } else if (nia == h->intrap) {
        return handle_input(h);
    }
    return true;
}

/* ---------------------------------------------------------------------
 * Input buffer (growable string) helpers
 * ------------------------------------------------------------------- */

static void ib_reset(HalUCP *h) {
    h->inputBufferLen = 0;
    h->inputBuffer[0] = '\0';
    h->inputColumn = 1;
}

static void ib_ensure_cap(HalUCP *h, size_t need) {
    if (need + 1 > h->inputBufferCap) {
        size_t cap = h->inputBufferCap;
        while (cap < need + 1) cap *= 2;
        h->inputBufferCap = cap;
        h->inputBuffer = realloc(h->inputBuffer, h->inputBufferCap);
    }
}

static void ib_append(HalUCP *h, const char *s) {
    size_t slen = strlen(s);
    ib_ensure_cap(h, h->inputBufferLen + slen);
    memcpy(h->inputBuffer + h->inputBufferLen, s, slen + 1);
    h->inputBufferLen += slen;
}

/* Removes the first n bytes (mirrors `@inputBuffer = buf.substring(n)`). */
static void ib_consume_prefix(HalUCP *h, size_t n) {
    if (n > h->inputBufferLen) n = h->inputBufferLen;
    /* Track inputColumn (1-indexed column, since the last newline, of the
     * next unconsumed byte) as bytes are discarded -- READ's COLUMN(n)
     * control specifier needs this to reposition within the current
     * still-buffered line (see apply_read_positioning()). */
    size_t lastNl = (size_t)-1;
    for (size_t i = 0; i < n; i++) {
        if (h->inputBuffer[i] == '\n') lastNl = i;
    }
    if (lastNl != (size_t)-1) {
        h->inputColumn = n - lastNl;
    } else {
        h->inputColumn += n;
    }
    memmove(h->inputBuffer, h->inputBuffer + n, h->inputBufferLen - n + 1);
    h->inputBufferLen -= n;
}

/* ---------------------------------------------------------------------
 * Input field extraction (10.1.1 rules 4-6)
 * ------------------------------------------------------------------- */

typedef enum { FIELD_NONE, FIELD_VALUE, FIELD_NULL_FIELD, FIELD_TERMINATED } FieldKind;
typedef struct {
    FieldKind kind;
    char *value; /* owned by caller when kind == FIELD_VALUE; must free() */
} ExtractedField;

static void consume_trailing_separator(HalUCP *h) {
    char *buf = h->inputBuffer;
    size_t len = h->inputBufferLen;
    size_t i = 0;
    while (i < len && (buf[i] == ' ' || buf[i] == '\t')) i++;
    if (i < len && buf[i] == ',') i++;
    ib_consume_prefix(h, i);
}

static ExtractedField extract_next_field(HalUCP *h, int iocode) {
    ExtractedField result = {FIELD_NONE, NULL};
    char *buf = h->inputBuffer;
    size_t len = h->inputBufferLen;

    size_t i = 0;
    while (i < len && (buf[i] == ' ' || buf[i] == '\t' || buf[i] == '\n' || buf[i] == '\r')) i++;

    if (i >= len) {
        ib_reset(h);
        return result;
    }

    char c = buf[i];

    if (c == ';') {
        ib_consume_prefix(h, i + 1);
        result.kind = FIELD_TERMINATED;
        return result;
    }

    if (c == ',') {
        ib_consume_prefix(h, i + 1);
        result.kind = FIELD_NULL_FIELD;
        return result;
    }

    if (c == '\'' && (iocode == 13 || iocode == 8)) {
        size_t pos = i + 1;
        char *value = malloc(len - pos + 1);
        size_t vi = 0;
        while (pos < len) {
            if (buf[pos] == '\'') {
                if (pos + 1 < len && buf[pos + 1] == '\'') {
                    value[vi++] = '\'';
                    pos += 2;
                } else {
                    pos++;
                    break;
                }
            } else {
                value[vi++] = buf[pos];
                pos++;
            }
        }
        value[vi] = '\0';
        ib_consume_prefix(h, pos);
        consume_trailing_separator(h);
        result.kind = FIELD_VALUE;
        result.value = value;
        return result;
    }

    size_t j = i;
    while (j < len && buf[j] != ',' && buf[j] != ';' && buf[j] != '\n' && buf[j] != '\r' && buf[j] != ' ' && buf[j] != '\t') j++;
    size_t flen = j - i;
    char *field = malloc(flen + 1);
    memcpy(field, buf + i, flen);
    field[flen] = '\0';
    ib_consume_prefix(h, j);
    consume_trailing_separator(h);
    result.kind = FIELD_VALUE;
    result.value = field;
    return result;
}

/* ---------------------------------------------------------------------
 * JS parseInt/parseFloat-compatible parsing (for _writeInputValue)
 * ------------------------------------------------------------------- */

/* Mirrors `parseInt(str, 10) or 0`: skip leading whitespace, optional
 * sign, consume decimal digits; 0 if no valid digits (JS NaN, which the
 * `or 0` idiom always collapses to 0 at every call site in this file). */
static int64_t js_parse_int10_or0(const char *s) {
    while (*s == ' ' || *s == '\t' || *s == '\n' || *s == '\r' || *s == '\v' || *s == '\f') s++;
    bool neg = false;
    if (*s == '+' || *s == '-') {
        neg = (*s == '-');
        s++;
    }
    bool any = false;
    long long val = 0;
    while (*s >= '0' && *s <= '9') {
        any = true;
        val = val * 10 + (*s - '0');
        s++;
    }
    if (!any) return 0;
    return neg ? -val : val;
}

/* Mirrors `parseInt(str, 2) or 0` on an already-[01]-only string. */
static uint32_t js_parse_int_binary_or0(const char *s) {
    bool any = false;
    uint32_t val = 0;
    while (*s == '0' || *s == '1') {
        any = true;
        val = val * 2 + (uint32_t)(*s - '0');
        s++;
    }
    return any ? val : 0;
}

/* Mirrors `parseFloat(str) or 0.0`. */
static double js_parse_float_or0(const char *s) {
    char *end;
    double v = strtod(s, &end);
    if (end == s) return 0.0;
    return v;
}

/* ---------------------------------------------------------------------
 * Character-string IOBUF encode/decode
 * ------------------------------------------------------------------- */

static void read_char_string(HalUCP *h, char *out, size_t outSize) {
    uint32_t descriptor = mcm_get16(&h->cpu->mainStorage, h->iobufAddr);
    int len = (int)(descriptor & 0xFF);
    size_t oi = 0;
    for (int i = 0; i < len && oi + 1 < outSize; i++) {
        int hwOffset = i / 2;
        uint32_t hw = mcm_get16(&h->cpu->mainStorage, h->iobufAddr + 1 + (uint32_t)hwOffset);
        uint32_t byte = (i % 2 == 0) ? ((hw >> 8) & 0xFF) : (hw & 0xFF);
        char c;
        if (h->iobufAscii) {
            /* AP-101S DEU encoding: ASCII except 0x00 = '"' and 0x16 = '_' */
            if (byte == 0x00) c = '"';
            else if (byte == 0x16) c = '_';
            else if (byte >= 0x20 && byte < 0x7F) c = (char)byte;
            else c = '.';
        } else {
            int mapped = EBCDIC_TO_ASCII[byte];
            c = (mapped >= 0) ? (char)mapped : '?';
        }
        out[oi++] = c;
    }
    out[oi] = '\0';
}

static void write_char_string(HalUCP *h, const char *text) {
    uint32_t descriptor = mcm_get16(&h->cpu->mainStorage, h->iobufAddr);
    uint32_t maxLen = (descriptor >> 8) & 0xFF;
    size_t textLen = strlen(text);
    size_t len = (maxLen > 0) ? (textLen < maxLen ? textLen : (size_t)maxLen) : textLen;
    mcm_set16(&h->cpu->mainStorage, h->iobufAddr, (maxLen << 8) | ((uint32_t)len & 0xFF), false);
    for (size_t i = 0; i < len; i += 2) {
        uint32_t hiByte, loByte;
        unsigned char c0 = (unsigned char)text[i];
        if (h->iobufAscii) {
            hiByte = (c0 == '"') ? 0x00u : (c0 == '_') ? 0x16u : (uint32_t)c0;
            if (i + 1 >= len) {
                loByte = 0x20;
            } else {
                unsigned char c1 = (unsigned char)text[i + 1];
                loByte = (c1 == '"') ? 0x00u : (c1 == '_') ? 0x16u : (uint32_t)c1;
            }
        } else {
            int m0 = ASCII_TO_EBCDIC[c0];
            hiByte = (m0 >= 0) ? (uint32_t)m0 : 0x40u;
            if (i + 1 < len) {
                unsigned char c1 = (unsigned char)text[i + 1];
                int m1 = ASCII_TO_EBCDIC[c1];
                loByte = (m1 >= 0) ? (uint32_t)m1 : 0x40u;
            } else {
                loByte = 0x40;
            }
        }
        mcm_set16(&h->cpu->mainStorage, h->iobufAddr + 1 + (uint32_t)(i / 2), (hiByte << 8) | loByte, false);
    }
}

static void write_input_value(HalUCP *h, const char *text) {
    switch (h->pendingIocode) {
        case 8: { /* BIN - bit string */
            char *stripped = malloc(strlen(text) + 1);
            size_t si = 0;
            for (const char *p = text; *p; p++) {
                if (*p == '0' || *p == '1') stripped[si++] = *p;
            }
            stripped[si] = '\0';
            uint32_t bits = js_parse_int_binary_or0(stripped);
            free(stripped);
            hal_set32(h, h->iobufAddr, bits);
            break;
        }
        case 9: { /* IIN - int32 */
            int64_t val = js_parse_int10_or0(text);
            if (val < 0) val += 0x100000000LL;
            hal_set32(h, h->iobufAddr, (uint32_t)val);
            break;
        }
        case 10: { /* HIN - int16 */
            int64_t val = js_parse_int10_or0(text);
            if (val < 0) val += 0x10000LL;
            mcm_set16(&h->cpu->mainStorage, h->iobufAddr, (uint32_t)val & 0xFFFF, false);
            break;
        }
        case 11: { /* EIN - float SP */
            double fval = js_parse_float_or0(text);
            FloatIBM f = fibm_from_float(fval);
            hal_set32(h, h->iobufAddr, fibm_to32(&f));
            break;
        }
        case 12: { /* DIN - float DP */
            double fval = js_parse_float_or0(text);
            FloatIBM f = fibm_from_float(fval);
            hal_set32(h, h->iobufAddr, fibm_to64x(&f));
            hal_set32(h, h->iobufAddr + 2, fibm_to64y(&f));
            break;
        }
        case 13: /* CIN - character string */
            write_char_string(h, text);
            break;
        default: {
            char msg[64];
            snprintf(msg, sizeof msg, "HalUCP: Unknown input IOCODE=%d\n", h->pendingIocode);
            hal_log(h, msg);
            break;
        }
    }
}

/* ---------------------------------------------------------------------
 * handleInput / provideInput / provideEof
 * ------------------------------------------------------------------- */

/* Applies this READ statement's SKIP(n)/COLUMN(n) control specifiers
 * (collected into readSkipPending/readColumnPending by handle_control,
 * which runs — per compiled HALMAT order XXST->IOINIT->specifiers->XXAR —
 * after IOINIT but before any argument is actually read) to inputBuffer,
 * exactly once per statement, right before its first argument's field
 * extraction. Default (readSkipPending == -1, i.e. no explicit SKIP, or
 * an explicit SKIP(n>=1)): advance to a fresh line, discarding whatever
 * of the old line is still buffered — the traditional/pre-existing
 * behavior. Explicit SKIP(0): stay on the current still-buffered line
 * instead, then let COLUMN(n) reposition forward within it. */
static void apply_read_positioning(HalUCP *h) {
    if (h->readPositioningApplied) return;
    h->readPositioningApplied = true;

    if (h->readSkipPending == 0) {
        /* Stay on the current line -- leave inputBuffer/inputColumn as-is. */
    } else {
        ib_reset(h);
    }

    if (h->readColumnPending >= 1) {
        size_t target = (size_t)h->readColumnPending;
        if (target > h->inputColumn) {
            size_t advance = target - h->inputColumn;
            if (advance > h->inputBufferLen) advance = h->inputBufferLen;
            ib_consume_prefix(h, advance);
        } else if (target < h->inputColumn) {
            char msg[96];
            snprintf(msg, sizeof msg,
                     "HalUCP: COLUMN(%d) requests rewind before already-consumed column %zu (not supported)\n",
                     h->readColumnPending, h->inputColumn);
            hal_log(h, msg);
        }
    }
}

static bool handle_input(HalUCP *h) {
    int iocode = (int)mcm_get16(&h->cpu->mainStorage, h->iocodeAddr);

    /* channels used for input default to UNPAGED */
    if (h->channelMode[h->channel] == 0) h->channelMode[h->channel] = 2;

    apply_read_positioning(h);

    if (h->readTerminated) {
        char msg[96];
        snprintf(msg, sizeof msg, "HalUCP: Input IOCODE=%d skipped (READ terminated by semicolon)\n", iocode);
        hal_log(h, msg);
        h->skipTrap = true;
        return true; /* 'continue' */
    }

    ExtractedField field = extract_next_field(h, iocode);
    if (field.kind != FIELD_NONE) {
        if (field.kind == FIELD_TERMINATED) {
            h->readTerminated = true;
            ib_reset(h);
            char msg[96];
            snprintf(msg, sizeof msg, "HalUCP: Input IOCODE=%d — semicolon terminates READ\n", iocode);
            hal_log(h, msg);
            h->skipTrap = true;
            return true;
        }
        if (field.kind == FIELD_NULL_FIELD) {
            char msg[80];
            snprintf(msg, sizeof msg, "HalUCP: Input IOCODE=%d — null field (unchanged)\n", iocode);
            hal_log(h, msg);
            h->skipTrap = true;
            return true;
        }
        char msg[512];
        snprintf(msg, sizeof msg, "HalUCP: Input IOCODE=%d field=\"%s\" (remaining: \"%s\")\n", iocode, field.value, h->inputBuffer);
        hal_log(h, msg);
        h->pendingIocode = iocode;
        h->hasPendingIocode = true;
        write_input_value(h, field.value);
        h->hasPendingIocode = false;
        free(field.value);
        h->skipTrap = true;
        return true;
    }

    h->waitingForInput = true;
    h->pendingIocode = iocode;
    h->hasPendingIocode = true;
    char msg[64];
    snprintf(msg, sizeof msg, "HalUCP: Input requested, IOCODE=%d\n", iocode);
    hal_log(h, msg);
    if (h->inputCallback) h->inputCallback(h->cbCtx, h->channel, iocode);
    return false; /* 'block' */
}

void halucp_provide_input(HalUCP *h, const char *text) {
    if (!h->waitingForInput) return;

    ib_append(h, text);
    int iocode = h->pendingIocode;

    ExtractedField field = extract_next_field(h, iocode);
    if (field.kind == FIELD_NONE) {
        hal_log(h, "HalUCP: provideInput — still no field after appending\n");
        return;
    }

    h->waitingForInput = false;

    if (field.kind == FIELD_TERMINATED) {
        h->readTerminated = true;
        ib_reset(h);
        char msg[96];
        snprintf(msg, sizeof msg, "HalUCP: Input IOCODE=%d — semicolon terminates READ\n", iocode);
        hal_log(h, msg);
    } else if (field.kind == FIELD_NULL_FIELD) {
        char msg[80];
        snprintf(msg, sizeof msg, "HalUCP: Input IOCODE=%d — null field (unchanged)\n", iocode);
        hal_log(h, msg);
    } else {
        char msg[512];
        snprintf(msg, sizeof msg, "HalUCP: Input IOCODE=%d field=\"%s\" (remaining: \"%s\")\n", iocode, field.value, h->inputBuffer);
        hal_log(h, msg);
        write_input_value(h, field.value);
        free(field.value);
    }

    h->hasPendingIocode = false;
    h->skipTrap = true; /* let the trap instruction (BR R4) execute to return to caller */
}

void halucp_provide_eof(HalUCP *h) {
    if (!h->waitingForInput) return;

    /* IO = 10, EOF = 5. */
    if (try_on_error_dispatch(h, 10, 5)) {
        h->waitingForInput = false;
        h->hasPendingIocode = false;
        h->skipTrap = true;
        return;
    }

    char logmsg[96];
    snprintf(logmsg, sizeof logmsg, "HalUCP: EOF on input channel %d, no ON ERROR handler — halting\n", h->channel);
    hal_log(h, logmsg);
    /* Same reasoning as the SVC 0x0015 (explicit HALT) path: this halts
     * the program too, and any channel's current line may still be
     * sitting unflushed in lineBuf[ch] (never terminated by an explicit
     * SKIP/LINE/PAGE) -- found via the "Programming in HAL/S" sweep,
     * where several simple `WRITE(6) '...'; READ(5) ...;` programs (no
     * ON ERROR installed, /dev/null stdin) silently lost their very
     * first WRITE'd line here before this fix. Gated on lineBufLen (not
     * just hasWrittenBefore) so a channel run.c's own interactive-prompt
     * logic already flushed (see prompt_and_provide_input) doesn't get a
     * second, spurious blank line. */
    for (int ch = 0; ch < HALUCP_MAX_CHANNEL; ch++) {
        if (h->lineBufLen[ch] > 0 && h->outputCallback) hal_newline(h, ch);
    }
    char msg[160];
    snprintf(msg, sizeof msg, "HalUCP: READ exhausted input on channel %d with no ON ERROR handler installed", h->channel);
    hal_report_error(h, msg);
    psw_set_wait_state(&h->cpu->psw, true);
    h->svcTrapped = true;
    h->waitingForInput = false;
    h->hasPendingIocode = false;
    h->skipTrap = true;
}

/* ---------------------------------------------------------------------
 * ON ERROR dispatch (simplified — see halUCP.coffee's _tryOnErrorDispatch
 * doc comment for the SCAL-frame slot layout this reads).
 * ------------------------------------------------------------------- */

static bool match_error_handler(uint32_t fixv, int errGroup, int errNum) {
    if (fixv == 0) return false;
    if (fixv == 63) return true; /* bare ON ERROR catch-all */
    uint32_t tag = (fixv >> 12) & 0x0F;
    if (tag != 0) return false; /* only user DO-block (TAG=0) handled */
    uint32_t numField = (fixv >> 6) & 0x3F;
    uint32_t grpField = fixv & 0x3F;
    bool groupOk = (grpField == 0x3F) || ((int)grpField == errGroup);
    bool numOk = (numField == 0x3F) || ((int)numField == errNum);
    return groupOk && numOk;
}

/* ON ERROR$(...) IGNORE AND SIGNAL/SET/RESET <event> — a disposition
 * that doesn't divert control flow at all, just flips an EVENT variable
 * as a side effect before letting the erroring statement's own SEND
 * ERROR SVC return control normally ("for standard fixup", same as an
 * unhandled/uncaught error already does). Confirmed via three isolated
 * single-statement compiles (one each for SIGNAL/SET/RESET, with an
 * LSTALL listing) that this uses the *same* FIXV layout as the TAG=0
 * GO TO case (group/num in the low 12 bits) but with one of these three
 * TAG values instead of 0 — and, critically, the paired "handler" slot
 * holds the EVENT variable's own address directly (`LA R4,EVn / STH R4,
 * slot+1`), not a jump target, so it must never be run through
 * dispatch_to_handler(). No bit relationship was found between the
 * three tag values (0xF/0x7/0xB) that would generalize to other
 * actions, so they're matched by direct enumeration rather than a
 * decoded sub-field. (IgnoreEventAction itself is declared up near this
 * file's other forward decls, since halucp_handle_svc's own plain
 * SIGNAL/SET/RESET handling, earlier in the file, needs it too.) */

static IgnoreEventAction ignore_event_action_for_tag(uint32_t tag) {
    switch (tag) {
        case 0xF: return IGNORE_EVENT_SIGNAL;
        case 0x7: return IGNORE_EVENT_SET;
        case 0xB: return IGNORE_EVENT_RESET;
        default: return IGNORE_EVENT_NONE;
    }
}

static bool match_ignore_event_handler(uint32_t fixv, int errGroup, int errNum, IgnoreEventAction *outAction) {
    if (fixv == 0) return false;
    IgnoreEventAction action = ignore_event_action_for_tag((fixv >> 12) & 0x0F);
    if (action == IGNORE_EVENT_NONE) return false;
    uint32_t numField = (fixv >> 6) & 0x3F;
    uint32_t grpField = fixv & 0x3F;
    bool groupOk = (grpField == 0x3F) || ((int)grpField == errGroup);
    bool numOk = (numField == 0x3F) || ((int)numField == errNum);
    if (!groupOk || !numOk) return false;
    *outAction = action;
    return true;
}

/* EVENT representation confirmed via a minimal compiled SIGNAL/SET/RESET
 * test (RUNMAC-free — these compile directly to SVC 0x000C/0x000D/0x000E
 * with the event's address as the SVC's second operand halfword, not to
 * an RTL call) and its matching `IF EVn THEN` check (`TB 0(Rn),1`): an
 * EVENT's "is it currently set" state is bit 0 (mask 1) of the halfword
 * at its own address. SIGNAL and SET both set it; RESET clears it —
 * this only models that one bit, not the fuller LATCHED-vs-unlatched
 * event/scheduling semantics real FCOS task management would add on
 * top, which yaGPC2 has no other support for anyway (problems.md 2.7). */
static void apply_ignore_event_action(HalUCP *h, uint32_t eventAddr, IgnoreEventAction action) {
    uint32_t word = mcm_get16(&h->cpu->mainStorage, eventAddr);
    uint32_t newWord = (action == IGNORE_EVENT_RESET) ? (word & ~1u) : (word | 1u);
    mcm_set16(&h->cpu->mainStorage, eventAddr, newWord, false);
}

static void dispatch_to_handler(HalUCP *h, uint32_t handlerAddr16, int errGroup, int errNum) {
    uint32_t handler19;
    if (handlerAddr16 & 0x8000) {
        handler19 = (psw_get_bsr(&h->cpu->psw) << 15) | (handlerAddr16 & 0x7FFF);
    } else {
        handler19 = handlerAddr16;
    }
    psw_set_nia(&h->cpu->psw, handler19);
    char msg[128];
    snprintf(msg, sizeof msg, "HalUCP: dispatched (group=%d,num=%d) to ON ERROR handler at 0x%x\n", errGroup, errNum, handler19);
    hal_log(h, msg);
}

/* How many (FIXV, handler) slot pairs to probe in the direct-case scan
 * below. Each distinct ON ERROR statement in a routine gets its own
 * dedicated 2-halfword slot, allocated sequentially by the compiler's
 * SET_ERRLOC (HALINCL/GENCLAS0.xpl: DISP(OP) = SHL(slot_index,1) +
 * ERRSEG(nesting_level)) — ERRSEG (the per-routine starting offset) and
 * the number of distinct ON ERROR statements both vary per compiled
 * routine and aren't recoverable at runtime without deeper compiler-
 * symbol support, so this scans a generous range from the first offset
 * confirmed against a real compiled program (test_eron_goto_appc.hal,
 * 4 sequential ON ERROR blocks at offsets 18/20/22/24) rather than
 * checking a single fixed slot. match_error_handler()'s specificity
 * (requiring TAG=0 and a real group/num match) makes a false-positive
 * match against unrelated frame data very unlikely. */
#define ON_ERROR_DIRECT_SLOT_BASE 18
#define ON_ERROR_DIRECT_SLOT_COUNT 16

static bool try_on_error_dispatch(HalUCP *h, int errGroup, int errNum) {
    /* group=4/num=27 (singular-matrix inverse, raised by MM14S3's 3x3
     * cofactor-expansion path): confirmed via confidential FCOS source
     * (FPMSDERR.asm, the real SEND ERROR SVC handler -- "DELETE ON ERROR
     * SUPPORT" since 1978) that no OS/SVC-level mechanism dispatches to a
     * user's ON ERROR handler at all, ever, for any error. Real GOTO-style
     * dispatch (confirmed working for SQRT/UNIT/MDIV/ZEROPOW in
     * test_eron_goto_appc.hal) instead happens because the COMPILER emits
     * its own redundant, statically-known re-check of the error condition
     * (e.g. "is the SQRT argument negative") directly in the calling code,
     * immediately after the call, and branches on it -- confirmed by
     * disassembling $0TESTER's own compiled code, which has exactly such a
     * check after its SQRT call. $0P's own compiled code (197-P.hal),
     * traced the same way immediately after its call to MM14S3, has NO
     * such check at all -- it falls straight through, unconditionally, to
     * the next statement (WRITE(6) M). This matches real yaGPC's actual
     * output (the identity matrix MM14S3's own fallback produces via
     * MM15SN, not the user's registered GO TO L1 handler) even when that
     * handler is present. Matrix inversion's singularity condition can't
     * be cheaply re-verified at the call site the way SQRT's can (it would
     * require redoing the whole cofactor expansion), which is presumably
     * why the compiler doesn't bother emitting a check here at all -- so,
     * unlike every other error this function handles, this one must never
     * dispatch, regardless of what ON ERROR disposition is registered. */
    if (errGroup == 4 && errNum == 27) return false;

    uint32_t sa = (register_get32(cpu_r(h->cpu, 0)) >> 16) & 0xffff;

    /* Direct case, walked up the call-frame chain as needed: the erroring
     * code was reached via a plain BAL@# call (e.g. RTL intrinsics like
     * SQRT/#MDIV's zero-divide check), which never reassigns R0 — the ON
     * ERROR statement's own FIXV/handler slots are still exactly where R0
     * already points, no unwind needed, found at level 0 below.
     *
     * But some RTL routines (e.g. UNIT's VV10S3, which normalizes a vector
     * and internally calls SQRT) bump R0 forward to claim their own scratch
     * frame even though they're entered via a plain BAL, not SCAL (see
     * RUNMAC/AMAIN.asm's "IAL 0,STACKEND-STACK SET STACK SIZE", emitted
     * for any routine declared ACALL=YES). Such a routine has no ON ERROR
     * statement of its own, so its frame's direct slots (18+) are unused;
     * confirmed via compiled test_eron_goto_appc.hal + --verbose tracing
     * that the caller's original R0 is recoverable as the halfword at
     * SA+2 (the same "old R0, saved as hi/lo halfwords" convention AEXIT
     * and the SCAL case below both rely on) — walking up through it and
     * re-running the same direct-slot scan at each level finds the FIXV
     * the user's ON ERROR statement actually installed in the enclosing
     * PROGRAM/procedure's own frame. Bounded to a handful of levels; a
     * caller of 0 (top of chain) or a self-loop stops the walk. */
    uint32_t walkSa = sa;
    uint32_t walkR0 = register_get32(cpu_r(h->cpu, 0));
    for (int level = 0; level < 8; level++) {
        for (int slot = 0; slot < ON_ERROR_DIRECT_SLOT_COUNT; slot++) {
            uint32_t off = (uint32_t)(ON_ERROR_DIRECT_SLOT_BASE + slot * 2);
            uint32_t directFixv = mcm_get16(&h->cpu->mainStorage, walkSa + off);

            IgnoreEventAction ignoreAction;
            if (match_ignore_event_handler(directFixv, errGroup, errNum, &ignoreAction)) {
                /* No jump, no R0/R1/R3 fixup — the erroring routine's own
                 * epilogue runs completely normally afterward, exactly as
                 * if this SEND ERROR had gone unhandled; only the event's
                 * bit changes. */
                uint32_t eventAddr = mcm_get16(&h->cpu->mainStorage, walkSa + off + 1);
                apply_ignore_event_action(h, eventAddr, ignoreAction);
                char msg[128];
                snprintf(msg, sizeof msg,
                         "HalUCP: ON ERROR IGNORE (group=%d,num=%d) -> event action %d on 0x%x\n",
                         errGroup, errNum, (int)ignoreAction, eventAddr);
                hal_log(h, msg);
                return true;
            }

            if (!match_error_handler(directFixv, errGroup, errNum)) continue;

            /* Jumping away here bypasses the erroring RTL routine's own
             * AEXIT epilogue (RUNMAC/AEXIT.asm's default intrinsic-return
             * path: `LH 1,5(0)` / `LH 3,9(0)`, "RESTORE PROGRAM DATA
             * BASE"/"RESTORE LOCAL DATA BASE") — R1/R3 are conventionally
             * used as data-area base registers throughout the *caller's*
             * compiled code, and intrinsics like SQRT are documented to use
             * R1 as their own scratch ("WORK R1,..." in SQRT.asm) without
             * restoring it themselves before erroring out. Without this,
             * the handler code's own R1/R3-relative addressing (e.g. string
             * literals) reads from the wrong location. Must replicate
             * exactly what AEXIT would have done, using the matched
             * frame's own save slots (walkSa, not the original sa — when
             * the walk went up a level, the original frame never had its
             * own R1/R3 restore values populated at all).
             *
             * If the walk went up at least one level, R0 itself must also
             * be restored to what it was in the matched ancestor frame
             * (walkR0, reconstructed while walking below) — otherwise it's
             * left pointing at the abandoned child frame, and the *next*
             * error dispatched from the resumed ancestor code would
             * wrongly start its own walk from stale, reused stack memory
             * instead of the ancestor's real frame. */
            if (level > 0) register_set32(cpu_r(h->cpu, 0), walkR0);
            register_set32(cpu_r(h->cpu, 1), mcm_get16(&h->cpu->mainStorage, walkSa + 5) << 16);
            register_set32(cpu_r(h->cpu, 3), mcm_get16(&h->cpu->mainStorage, walkSa + 9) << 16);
            dispatch_to_handler(h, mcm_get16(&h->cpu->mainStorage, walkSa + off + 1), errGroup, errNum);
            return true;
        }
        uint32_t callerHi = mcm_get16(&h->cpu->mainStorage, walkSa + 2);
        uint32_t callerLo = mcm_get16(&h->cpu->mainStorage, walkSa + 3);
        if (callerHi == 0 || callerHi == walkSa) break;
        walkR0 = (callerHi << 16) | callerLo;
        walkSa = callerHi;
    }

    /* SCAL-frame-unwind case: the erroring code was reached via a
     * SCAL@#-called routine (e.g. I/O RTL routines), which reassigns R0
     * to its own local save area — SA..SA+1 = saved PSW1, then R0..R7
     * each as two halfwords at SA+2+2i/SA+2+2i+1 (see halUCP.coffee's
     * _tryOnErrorDispatch doc comment) — so the caller's original R0
     * (saved at SA+2/SA+3) must be recovered first to find its FIXV/
     * handler slots. */
    uint32_t callerR0Hi = mcm_get16(&h->cpu->mainStorage, sa + 2);
    uint32_t callerR0Lo = mcm_get16(&h->cpu->mainStorage, sa + 3);
    uint32_t stackEnd = (callerR0Hi + callerR0Lo) & 0xffff;
    uint32_t fixv = mcm_get16(&h->cpu->mainStorage, stackEnd - 2);
    uint32_t handlerAddr16 = mcm_get16(&h->cpu->mainStorage, stackEnd - 1);

    if (!match_error_handler(fixv, errGroup, errNum)) {
        char msg[160];
        snprintf(msg, sizeof msg, "HalUCP: ON ERROR slot FIXV=0x%x at hw 0x%x does not match (group=%d,num=%d)\n",
                 fixv, stackEnd - 2, errGroup, errNum);
        hal_log(h, msg);
        return false;
    }

    uint32_t psw1hi = mcm_get16(&h->cpu->mainStorage, sa);
    uint32_t psw1lo = mcm_get16(&h->cpu->mainStorage, sa + 1);
    uint32_t newPsw1 = (psw1hi << 16) | psw1lo;
    for (int i = 0; i <= 7; i++) {
        uint32_t hi = mcm_get16(&h->cpu->mainStorage, sa + 2 + (uint32_t)i * 2);
        uint32_t lo = mcm_get16(&h->cpu->mainStorage, sa + 2 + (uint32_t)i * 2 + 1);
        register_set32(cpu_r(h->cpu, i), (hi << 16) | lo);
    }
    register_set32(&h->cpu->psw.psw1, newPsw1);

    dispatch_to_handler(h, handlerAddr16, errGroup, errNum);
    return true;
}

/* ---------------------------------------------------------------------
 * Input validation helpers (interactive-mode use, Phase 10)
 * ------------------------------------------------------------------- */

const char *halucp_iocode_type_name(int iocode) {
    switch (iocode) {
        case 8: return "BIT";
        case 9: return "INTEGER";
        case 10: return "SHORT INTEGER";
        case 11: return "SCALAR";
        case 12: return "DOUBLE SCALAR";
        case 13: return "CHARACTER";
        default: {
            static char buf[32];
            snprintf(buf, sizeof buf, "UNKNOWN(%d)", iocode);
            return buf;
        }
    }
}

const char *halucp_validate_input(const char *text, int iocode) {
    switch (iocode) {
        case 8: {
            for (const char *p = text; *p; p++) {
                if (*p == '0' || *p == '1') return NULL;
            }
            return "expected binary string (0s and 1s)";
        }
        case 9:
        case 10: {
            const char *p = text;
            while (*p == ' ' || *p == '\t' || *p == '\n' || *p == '\r') p++;
            const char *s = p;
            if (*s == '-') s++;
            const char *digitsStart = s;
            while (*s >= '0' && *s <= '9') s++;
            const char *end = s;
            while (*end == ' ' || *end == '\t' || *end == '\n' || *end == '\r') end++;
            if (s == digitsStart || *end != '\0') return "expected integer";
            long long val = atoll(p);
            if (iocode == 9) {
                if (val < -2147483648LL || val > 2147483647LL) return "integer out of 32-bit range";
            } else {
                if (val < -32768 || val > 32767) return "integer out of 16-bit range";
            }
            return NULL;
        }
        case 11:
        case 12: {
            char trimmed[256];
            size_t n = 0;
            const char *p = text;
            while (*p == ' ' || *p == '\t' || *p == '\n' || *p == '\r') p++;
            while (*p && n < sizeof(trimmed) - 1) trimmed[n++] = *p++;
            trimmed[n] = '\0';
            while (n > 0 && (trimmed[n - 1] == ' ' || trimmed[n - 1] == '\t' || trimmed[n - 1] == '\n' || trimmed[n - 1] == '\r')) {
                trimmed[--n] = '\0';
            }
            char *end;
            double v = strtod(trimmed, &end);
            if (end == trimmed || !isfinite(v)) return "expected number";
            return NULL;
        }
        case 13:
            return NULL;
        default: {
            static char buf[32];
            snprintf(buf, sizeof buf, "unknown iocode %d", iocode);
            return buf;
        }
    }
}
