#include "trace.h"

#include <stdio.h>
#include <string.h>

#include "strfmt.h"

const TraceColors TRACE_COLOR_ANSI = {
    .reset = "\x1b[0m",
    .bold = "\x1b[1m",
    .dim = "\x1b[2m",
    .red = "\x1b[31m",
    .green = "\x1b[32m",
    .yellow = "\x1b[33m",
    .blue = "\x1b[34m",
    .magenta = "\x1b[35m",
    .cyan = "\x1b[36m",
    .white = "\x1b[37m",
    .bgRed = "\x1b[41m",
};

const TraceColors TRACE_COLOR_PLAIN = {
    .reset = "", .bold = "", .dim = "", .red = "", .green = "", .yellow = "",
    .blue = "", .magenta = "", .cyan = "", .white = "", .bgRed = "",
};

void trace_format_reg_val(char *out, size_t outSize, const char *name, uint32_t val) {
    if (strcmp(name, "CC") == 0 || strcmp(name, "NIA") == 0) {
        snprintf(out, outSize, "%u", val);
    } else {
        as_hex(out, outSize, (long long)val, 8);
    }
}

void trace_format_line(char *out, size_t outSize, int step, uint32_t nia, uint32_t hw1, uint32_t hw2,
                        const char *disasm, int instrLen, const RegChange *changes, int changeCount,
                        const TraceLineOpts *opts) {
    const TraceColors *c = (opts && opts->color) ? opts->color : &TRACE_COLOR_PLAIN;
    const SymbolTable *sym = opts ? opts->sym : NULL;
    int stepWidth = (opts && opts->stepWidth) ? opts->stepWidth : 6;
    int niaWidth = (opts && opts->niaWidth) ? opts->niaWidth : 5;

    char stepNum[32];
    snprintf(stepNum, sizeof stepNum, "%d", step);
    char stepStr[32];
    str_lpad(stepStr, sizeof stepStr, stepNum, " ", stepWidth);

    char niaStr[24];
    as_hex(niaStr, sizeof niaStr, (long long)nia, niaWidth);

    char sectStr[64];
    sectStr[0] = '\0';
    if (sym) {
        char csect[32];
        symtable_format_csect(sym, nia, csect, sizeof csect);
        snprintf(sectStr, sizeof sectStr, " %s", csect);
    }

    char hw1Str[16];
    as_hex(hw1Str, sizeof hw1Str, (long long)hw1, 4);
    char hw2Str[16];
    if (instrLen > 1) {
        as_hex(hw2Str, sizeof hw2Str, (long long)hw2, 4);
    } else {
        snprintf(hw2Str, sizeof hw2Str, "    ");
    }

    char changesStr[2048];
    changesStr[0] = '\0';
    if (changeCount > 0) {
        size_t pos = 0;
        int n = snprintf(changesStr + pos, sizeof changesStr - pos, "  ");
        pos += (n > 0) ? (size_t)n : 0;
        for (int i = 0; i < changeCount && pos < sizeof changesStr; i++) {
            char oldStr[16], newStr[16];
            trace_format_reg_val(oldStr, sizeof oldStr, changes[i].name, changes[i].oldVal);
            trace_format_reg_val(newStr, sizeof newStr, changes[i].name, changes[i].newVal);
            if (i > 0) {
                n = snprintf(changesStr + pos, sizeof changesStr - pos, ", ");
                pos += (n > 0) ? (size_t)n : 0;
            }
            n = snprintf(changesStr + pos, sizeof changesStr - pos, "%s: %s->%s", changes[i].name, oldStr, newStr);
            pos += (n > 0) ? (size_t)n : 0;
        }
    }

    char disasmPadded[256];
    str_rpad(disasmPadded, sizeof disasmPadded, disasm, " ", 28);

    char timeStr[32];
    timeStr[0] = '\0';
    if (opts && opts->elapsedTimeUs) snprintf(timeStr, sizeof timeStr, "T=%.2f ", *opts->elapsedTimeUs);

    snprintf(out, outSize, "%s[%s]%s %s%s%s: %s %s  %s%s%s%s",
             c->dim, stepStr, c->reset, timeStr, niaStr, sectStr, hw1Str, hw2Str, disasmPadded, c->yellow, changesStr, c->reset);
}

void trace_format_changes_wrapped(int lineWidth, const char *prefix, const RegChange *changes, int changeCount,
                                   char *out, size_t outSize) {
    out[0] = '\0';
    if (changeCount <= 0) return;

    size_t prefixLen = strlen(prefix);
    size_t pos = 0;
    size_t lineLen = prefixLen;
    bool firstOnLine = true;

    for (int i = 0; i < changeCount; i++) {
        char oldStr[16], newStr[16];
        trace_format_reg_val(oldStr, sizeof oldStr, changes[i].name, changes[i].oldVal);
        trace_format_reg_val(newStr, sizeof newStr, changes[i].name, changes[i].newVal);
        bool isLast = i == changeCount - 1;
        char token[64];
        snprintf(token, sizeof token, "%s: %s->%s%s", changes[i].name, oldStr, newStr, isLast ? "" : ", ");
        size_t tokenLen = strlen(token);

        if (!firstOnLine && lineWidth > 0 && lineLen + tokenLen > (size_t)lineWidth) {
            int n = snprintf(out + pos, pos < outSize ? outSize - pos : 0, "\n%*s", (int)prefixLen, "");
            pos += (n > 0) ? (size_t)n : 0;
            lineLen = prefixLen;
            firstOnLine = true;
        }
        int n = snprintf(out + pos, pos < outSize ? outSize - pos : 0, "%s", token);
        pos += (n > 0) ? (size_t)n : 0;
        lineLen += tokenLen;
        firstOnLine = false;
    }
}

void trace_format_debug_line(char *out, size_t outSize, long step, uint32_t nia, uint32_t hw1, uint32_t hw2,
                              const char *disasm, int instrLen, const RegChange *changes, int changeCount,
                              const SymbolTable *sym, const double *elapsedTimeUs, int lineWidth) {
    char stepNum[32];
    snprintf(stepNum, sizeof stepNum, "%ld", step);
    char stepStr[32];
    str_lpad(stepStr, sizeof stepStr, stepNum, " ", 5);

    char niaStr[16];
    as_hex(niaStr, sizeof niaStr, (long long)nia, 6);

    char sectOffsetStr[80];
    sectOffsetStr[0] = '\0';
    if (sym) {
        char off[64];
        symtable_format_section_offset(sym, nia, off, sizeof off);
        snprintf(sectOffsetStr, sizeof sectOffsetStr, " %s", off);
    }

    char hw1Str[16];
    as_hex(hw1Str, sizeof hw1Str, (long long)hw1, 4);
    char hw2Str[16];
    if (instrLen > 1) {
        as_hex(hw2Str, sizeof hw2Str, (long long)hw2, 4);
    } else {
        snprintf(hw2Str, sizeof hw2Str, "    ");
    }

    char disasmPadded[256];
    str_rpad(disasmPadded, sizeof disasmPadded, disasm, " ", 28);

    char timeStr[32];
    timeStr[0] = '\0';
    if (elapsedTimeUs) snprintf(timeStr, sizeof timeStr, "T=%.2f ", *elapsedTimeUs);

    char prefix[400];
    snprintf(prefix, sizeof prefix, "[%s] %s%s%s: %s %s  %s", stepStr, timeStr, niaStr, sectOffsetStr, hw1Str, hw2Str,
             disasmPadded);

    char changesBlob[4096];
    trace_format_changes_wrapped(lineWidth, prefix, changes, changeCount, changesBlob, sizeof changesBlob);
    snprintf(out, outSize, "%s%s", prefix, changesBlob);
}

void trace_format_reg_dump(CPU *cpu, int step, const TraceColors *color, char lines[TRACE_REGDUMP_LINES][200], size_t lineSize) {
    const TraceColors *c = color ? color : &TRACE_COLOR_PLAIN;
    uint32_t grSet = psw_get_reg_set(&cpu->psw);

    int li = 0;
    snprintf(lines[li++], lineSize, "%s--- Registers (step %d, bank %u) ---%s", c->bold, step, grSet, c->reset);

    for (int rowStart = 0; rowStart <= 4; rowStart += 4) {
        char parts[4][64];
        for (int k = 0; k < 4; k++) {
            int i = rowStart + k;
            char valHex[16];
            uint32_t val = register_get32(registerfile_r(&cpu->regFiles[grSet], i));
            as_hex(valHex, sizeof valHex, (long long)val, 8);
            snprintf(parts[k], sizeof parts[k], "%sR%02d%s=%s", c->cyan, i, c->reset, valHex);
        }
        snprintf(lines[li++], lineSize, "  %s  %s  %s  %s", parts[0], parts[1], parts[2], parts[3]);
    }

    for (int rowStart = 0; rowStart <= 4; rowStart += 4) {
        char parts[4][64];
        for (int k = 0; k < 4; k++) {
            int i = rowStart + k;
            char valHex[16];
            uint32_t val = register_get32(registerfile_r(&cpu->regFiles[2], i));
            as_hex(valHex, sizeof valHex, (long long)val, 8);
            snprintf(parts[k], sizeof parts[k], "%sFP%d%s=%s", c->cyan, i, c->reset, valHex);
        }
        snprintf(lines[li++], lineSize, "  %s  %s  %s  %s", parts[0], parts[1], parts[2], parts[3]);
    }

    uint32_t psw1 = register_get32(&cpu->psw.psw1);
    uint32_t psw2 = register_get32(&cpu->psw.psw2);
    uint32_t nia = psw_get_nia(&cpu->psw);
    uint32_t cc = psw_get_cc(&cpu->psw);
    uint32_t bsr = psw_get_bsr(&cpu->psw);
    uint32_t dsr = psw_get_dsr(&cpu->psw);
    char psw1Hex[16], psw2Hex[16], niaHex[16];
    as_hex(psw1Hex, sizeof psw1Hex, (long long)psw1, 8);
    as_hex(psw2Hex, sizeof psw2Hex, (long long)psw2, 8);
    as_hex(niaHex, sizeof niaHex, (long long)nia, 5);
    snprintf(lines[li++], lineSize, "  %sPSW1%s=%s  %sPSW2%s=%s  %sNIA%s=%s  %sCC%s=%u  %sBSR%s=%u  %sDSR%s=%u",
             c->cyan, c->reset, psw1Hex, c->cyan, c->reset, psw2Hex, c->cyan, c->reset, niaHex,
             c->cyan, c->reset, cc, c->cyan, c->reset, bsr, c->cyan, c->reset, dsr);
}
