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
        case 22: return "CHARACTER TO INTEGEgpc/halUCP.coffeegpc/halUCP.coffeeR CONVERSION";
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
    h->lineWidth = 132;
    h->linesPerPage = 60;
    h->inputBufferCap = 64;
    h->inputBuffer = malloc(h->inputBufferCap);
    h->inputBuffer[0] = '\0';
    h->inputBufferLen = 0;
    for (int i = 0; i < HALUCP_MAX_CHANNEL; i++) {
        h->column[i] = 1;
        h->lineNumber[i] = 1;
    }
}

void halucp_free(HalUCP *h) {
    free(h->inputBuffer);
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
            if (h->hasWrittenBefore[ch] && h->outputCallback) {
                h->outputCallback(h->cbCtx, "\n", ch);
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
        char gbuf[32], mbuf[32];
        const char *groupName = svc_error_group_name(errGroup, gbuf, sizeof gbuf);
        const char *errMsg = svc_error_message(errNum, mbuf, sizeof mbuf);
        char msg[512];
        snprintf(msg, sizeof msg, "HAL/S SEND ERROR: %s: #%d %s", groupName, errNum, errMsg);
        hal_report_error(h, msg);
        try_on_error_dispatch(h, errGroup, errNum);
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

static void hal_newline(HalUCP *h, int ch) {
    if (h->outputCallback) h->outputCallback(h->cbCtx, "\n", ch);
    h->lineNumber[ch] += 1;
    h->column[ch] = 1;
}

void halucp_notify_interactive_input(HalUCP *h, int ch) {
    if (ch < 0 || ch >= HALUCP_MAX_CHANNEL) return;
    h->column[ch] = 1;
    h->suppressNextAdvance[ch] = true;
}

static void emit_spaces(HalUCP *h, int ch, int n) {
    if (n <= 0 || !h->outputCallback) return;
    char *buf = malloc((size_t)n + 1);
    memset(buf, ' ', (size_t)n);
    buf[n] = '\0';
    h->outputCallback(h->cbCtx, buf, ch);
    free(buf);
}

static void emit_text_n(HalUCP *h, int ch, const char *text, int len) {
    if (!h->outputCallback || len <= 0) return;
    char *buf = malloc((size_t)len + 1);
    memcpy(buf, text, (size_t)len);
    buf[len] = '\0';
    h->outputCallback(h->cbCtx, buf, ch);
    free(buf);
}

static void flush_positioning(HalUCP *h, int ch) {
    if (!h->deferred[ch].present) return;
    HalUCPDeferredPos pos = h->deferred[ch];
    h->deferred[ch].present = false;
    if (pos.downLines > 0) {
        for (int i = 0; i < pos.downLines; i++) hal_newline(h, ch);
    }
    if (pos.toCol > h->column[ch]) {
        emit_spaces(h, ch, pos.toCol - h->column[ch]);
        h->column[ch] = pos.toCol;
    }
}

static void emit_field(HalUCP *h, const char *fieldText, bool isChar) {
    int ch = h->channel;
    flush_positioning(h, ch);

    bool needSep = (!h->firstField[ch]) && (!h->suppressNextSep[ch]);
    h->suppressNextSep[ch] = false;
    int sepLen = needSep ? h->formatNumBlanks : 0;
    int fieldLen = (int)strlen(fieldText);

    if (!isChar) {
        if (h->column[ch] + sepLen + fieldLen - 1 > h->lineWidth) {
            hal_newline(h, ch);
            emit_text_n(h, ch, fieldText, fieldLen);
            h->column[ch] += fieldLen;
        } else {
            if (sepLen > 0) {
                emit_spaces(h, ch, sepLen);
                h->column[ch] += sepLen;
            }
            emit_text_n(h, ch, fieldText, fieldLen);
            h->column[ch] += fieldLen;
        }
    } else {
        if (sepLen > 0) {
            if (h->column[ch] + sepLen > h->lineWidth + 1) {
                hal_newline(h, ch);
            } else {
                emit_spaces(h, ch, sepLen);
                h->column[ch] += sepLen;
            }
        }
        int pos = 0;
        while (pos < fieldLen) {
            if (h->column[ch] > h->lineWidth) hal_newline(h, ch);
            int remaining = h->lineWidth - h->column[ch] + 1;
            int take = remaining < (fieldLen - pos) ? remaining : (fieldLen - pos);
            if (take <= 0) take = fieldLen - pos; /* defensive: avoid infinite loop */
            emit_text_n(h, ch, fieldText + pos, take);
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
                h->inputBufferLen = 0;
                h->inputBuffer[0] = '\0';
            } else {
                if (h->deferred[ch].present) flush_positioning(h, ch);
                if (!h->hasWrittenBefore[ch]) {
                    h->hasWrittenBefore[ch] = true;
                    h->deferred[ch].present = true;
                    h->deferred[ch].downLines = 0;
                    h->deferred[ch].toCol = 1;
                } else if (h->suppressNextAdvance[ch]) {
                    h->suppressNextAdvance[ch] = false;
                    h->deferred[ch].present = true;
                    h->deferred[ch].downLines = 0;
                    h->deferred[ch].toCol = 1;
                } else {
                    h->deferred[ch].present = true;
                    h->deferred[ch].downLines = 1;
                    h->deferred[ch].toCol = 1;
                }
                h->firstField[ch] = true;
                h->suppressNextSep[ch] = false;
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
            break;
        }
        case 5: { /* COLUMN */
            int ch = h->channel;
            if (param < 1) {
                char msg[64];
                snprintf(msg, sizeof msg, "HalUCP: COLUMN(%d) below column 1\n", param);
                hal_log(h, msg);
            } else if (h->deferred[ch].present) {
                h->deferred[ch].toCol = (int)param;
            } else {
                if (param > h->column[ch]) {
                    emit_spaces(h, ch, (int)param - h->column[ch]);
                    h->column[ch] = (int)param;
                } else {
                    char msg[96];
                    snprintf(msg, sizeof msg, "HalUCP: COLUMN(%d); CUR=%d backwards, umimplemented.\n", param, h->column[ch]);
                    hal_log(h, msg);
                }
            }
            h->suppressNextSep[ch] = true;
            break;
        }
        case 6: { /* TAB */
            int ch = h->channel;
            if (h->deferred[ch].present) {
                int newCol = h->deferred[ch].toCol + (int)param;
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
                if (target > h->column[ch]) {
                    emit_spaces(h, ch, target - h->column[ch]);
                    h->column[ch] = target;
                } else {
                    char msg[64];
                    snprintf(msg, sizeof msg, "HalUCP: TAB(%d); negative tab, umimplemented.\n", param);
                    hal_log(h, msg);
                }
            }
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
            }
            break;
        }
        case 8: { /* SKIP */
            int ch = h->channel;
            if (param < 0) {
                char msg[64];
                snprintf(msg, sizeof msg, "HalUCP: SKIP(%d) negative count not allowed\n", param);
                hal_log(h, msg);
            } else if (h->deferred[ch].present) {
                h->deferred[ch].downLines = (int)param;
            } else {
                for (int i = 0; i < (int)param; i++) hal_newline(h, ch);
            }
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

static bool handle_input(HalUCP *h) {
    int iocode = (int)mcm_get16(&h->cpu->mainStorage, h->iocodeAddr);

    /* channels used for input default to UNPAGED */
    if (h->channelMode[h->channel] == 0) h->channelMode[h->channel] = 2;

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

static bool try_on_error_dispatch(HalUCP *h, int errGroup, int errNum) {
    uint32_t sa = (register_get32(cpu_r(h->cpu, 0)) >> 16) & 0xffff;
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
