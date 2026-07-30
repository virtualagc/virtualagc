#include "debugger.h"

#include <ctype.h>
#include <limits.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "cpu_instr.h"
#include "membus.h"
#include "sourcemap.h"
#include "strfmt.h"
#include "trace.h"

#define DEBUGGER_MAX_BREAKPOINTS 64
#define DEBUGGER_MAX_MEMWATCH 64
#define DEBUGGER_MAX_WATCH 32
#define DEBUGGER_BACKTRACE_SIZE 32
#define DEBUGGER_MAX_TOKENS 8

typedef struct {
    uint32_t addr;
    bool enabled;
    char name[64];
} Breakpoint;

/* 'mw': break-on-write. Checked every hook call by comparing against the
 * value snapshotted on the PREVIOUS call -- see debugger_hook()'s own
 * comment for why the snapshot/compare is split across two calls here
 * rather than bracketing ap101_exec1() the way cmd_debug.coffee's
 * execOne() does it in one place. */
typedef struct {
    uint32_t addr;
    bool enabled;
    char name[64];
    bool hasBefore;
    uint16_t beforeVal;
} MemWatchpoint;

/* 'watch': a display-on-stop expression, not break-on-write -- shown
 * once every time the debugger stops, alongside the current location. */
typedef struct {
    uint32_t addr;
    char name[64];
    int size; /* halfwords; >=2 also shows the fullword view */
} WatchExpr;

typedef struct {
    uint32_t addr;
    char disasm[80];
} RecentInstr;

struct Debugger {
    bool traceEnabled; /* 'trace'/'htrace' toggle -- see debugger_wants_trace() */

    Breakpoint breakpoints[DEBUGGER_MAX_BREAKPOINTS];
    int breakpointCount;

    MemWatchpoint memWatchpoints[DEBUGGER_MAX_MEMWATCH];
    int memWatchpointCount;

    WatchExpr watches[DEBUGGER_MAX_WATCH];
    int watchCount;

    RecentInstr recent[DEBUGGER_BACKTRACE_SIZE];
    int recentHead, recentCount;

    /* >0: hook returns true silently for this many more instructions
     * before stopping again ('step N'/'next'/'run' all drive this). */
    long stepsRemaining;
    bool hasTempBreakpoint; /* one-shot breakpoint used by 'next' */
    uint32_t tempBreakpoint;

    /* Register-state display at each stop (see show_stop_registers()):
     * beforeResumeRegs is snapshotted, and instructionsThisResume reset
     * to 1 (pre-counting the "free" instruction -- see debugger_hook's
     * own comment), each time a resume command is dispatched; every
     * subsequent flow-branch call increments it further. At the next
     * stop, exactly 1 instruction executed means the developer is shown
     * just what changed (a diff); 0 (startup) or >1 means a full
     * register dump instead, since a multi-instruction diff -- or a
     * diff against nothing at all -- isn't a meaningful single display. */
    RegSnapshot beforeResumeRegs;
    long instructionsThisResume;

    long currentStep;

    char lastLine[256];
    bool hasLastLine;

    /* Stage 3: HAL/S source-line display (see src/sourcemap.h). NULL
     * unless --source-map was given -- zero cost otherwise. */
    SourceMap *srcmap;
    int lastStmt;
    bool hasLastStmt; /* only show a source line when it differs from the
                       * last one shown, matching yaHALMAT2's --debug mode */

    /* 'set width N': wraps the register-changes list run.c prints during
     * 'trace'/'htrace' (see debugger_format_changes()); N<=0 disables
     * wrapping. Purely a debug-mode presentation setting -- has no
     * effect on plain --trace (no --debug). */
    int lineWidth;
};

/* ---------------------------------------------------------------------
 * Small formatting/resolution helpers
 * ------------------------------------------------------------------- */

static void format_addr_plain(uint32_t addr, char *out, size_t outSize) {
    as_hex(out, outSize, (long long)addr, 5);
}

/* Mirrors cmd_debug.coffee's formatAddr: "ADDR <label>" if a symbol sits
 * exactly at addr, else "ADDR <section+offset>" if inside a section,
 * else just "ADDR". */
static void format_addr(const AGEHarness *age, uint32_t addr, char *out, size_t outSize) {
    char hex[16];
    as_hex(hex, sizeof hex, (long long)addr, 5);

    const Symbol *label = symtable_get_label_at(&age->sym, addr);
    if (label) {
        snprintf(out, outSize, "%s <%s>", hex, label->name);
        return;
    }
    const char *sect = symtable_get_section_at(&age->sym, addr);
    if (sect) {
        for (int i = 0; i < age->sym.sectionCount; i++) {
            if (strcmp(age->sym.sections[i].name, sect) == 0) {
                uint32_t offset = addr - age->sym.sections[i].address;
                char offHex[16];
                as_hex(offHex, sizeof offHex, (long long)offset, 3);
                snprintf(out, outSize, "%s <%s+%s>", hex, sect, offHex);
                return;
            }
        }
    }
    snprintf(out, outSize, "%s", hex);
}

/* Mirrors cmd_debug.coffee's resolveAddr: a bare/0x-prefixed hex string,
 * or (failing that) an exact-match symbol name (case-insensitive). */
static bool resolve_addr(const AGEHarness *age, const char *s, uint32_t *out) {
    const char *p = s;
    if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X')) p += 2;
    bool isHex = *p != '\0';
    for (const char *q = p; isHex && *q; q++) {
        if (!isxdigit((unsigned char)*q)) isHex = false;
    }
    if (isHex) {
        *out = (uint32_t)strtoul(p, NULL, 16);
        return true;
    }

    char upper[64];
    size_t n = 0;
    for (const char *q = s; *q && n < sizeof(upper) - 1; q++, n++) upper[n] = (char)toupper((unsigned char)*q);
    upper[n] = '\0';

    for (int i = 0; i < age->sym.symbolCount; i++) {
        if (age->sym.symbols[i].name && strcmp(age->sym.symbols[i].name, upper) == 0) {
            *out = age->sym.symbols[i].address;
            return true;
        }
    }
    return false;
}

static Breakpoint *find_breakpoint_at(Debugger *dbg, uint32_t addr) {
    for (int i = 0; i < dbg->breakpointCount; i++) {
        if (dbg->breakpoints[i].addr == addr) return &dbg->breakpoints[i];
    }
    return NULL;
}

static MemWatchpoint *find_memwatch_at(Debugger *dbg, uint32_t addr) {
    for (int i = 0; i < dbg->memWatchpointCount; i++) {
        if (dbg->memWatchpoints[i].addr == addr) return &dbg->memWatchpoints[i];
    }
    return NULL;
}

static WatchExpr *find_watch_at(Debugger *dbg, uint32_t addr) {
    for (int i = 0; i < dbg->watchCount; i++) {
        if (dbg->watches[i].addr == addr) return &dbg->watches[i];
    }
    return NULL;
}

/* ---------------------------------------------------------------------
 * Display commands
 * ------------------------------------------------------------------- */

static void show_registers(Debugger *dbg, AGEHarness *age) {
    char lines[TRACE_REGDUMP_LINES][200];
    trace_format_reg_dump(&age->gpc.cpu, (int)dbg->currentStep, &TRACE_COLOR_PLAIN, lines, sizeof(lines[0]));
    for (int i = 0; i < TRACE_REGDUMP_LINES; i++) printf("%s\n", lines[i]);
}

/* Shown at every debugger stop, regardless of 'trace'/'htrace': exactly
 * one instruction executed since the last stop (the common case for a
 * plain 'step') gets just the register changes it made, the same
 * detail level 'htrace' shows per instruction; zero (startup) or more
 * than one (e.g. 'step N>1', or 'next'/'run' covering several
 * instructions) gets a full register dump instead, since neither "diff
 * against nothing" nor "diff spanning several instructions" is a
 * meaningful single display -- per user feedback. */
static void show_stop_registers(Debugger *dbg, AGEHarness *age) {
    if (dbg->instructionsThisResume != 1) {
        show_registers(dbg, age);
        return;
    }

    RegSnapshot after;
    ageharness_snapshot_regs(age, &after);
    RegChange changes[REG_SNAPSHOT_MAX_CHANGES];
    int changeCount = ageharness_diff_regs(&dbg->beforeResumeRegs, &after, changes);
    int filteredCount = 0;
    RegChange filtered[REG_SNAPSHOT_MAX_CHANGES];
    for (int i = 0; i < changeCount; i++) {
        if (strcmp(changes[i].name, "NIA") != 0) filtered[filteredCount++] = changes[i];
    }
    if (filteredCount == 0) return; /* e.g. a plain branch changed nothing else */

    char blob[4096];
    debugger_format_changes(dbg, "", filtered, filteredCount, blob, sizeof blob);
    printf("%s\n", blob);
}

static void show_register(AGEHarness *age, const char *nameIn) {
    char name[16];
    size_t n = 0;
    for (const char *p = nameIn; *p && n < sizeof(name) - 1; p++, n++) name[n] = (char)toupper((unsigned char)*p);
    name[n] = '\0';

    int grSet = (int)psw_get_reg_set(&age->gpc.cpu.psw);
    int idx, consumed;

    if (sscanf(name, "R%d%n", &idx, &consumed) == 1 && consumed == (int)strlen(name) && idx >= 0 && idx <= 7) {
        uint32_t val = register_get32(registerfile_r(&age->gpc.cpu.regFiles[grSet], idx));
        printf("  %s = 0x%08x (%d)\n", name, val, (int32_t)val);
        return;
    }
    if (sscanf(name, "FP%d%n", &idx, &consumed) == 1 && consumed == (int)strlen(name) && idx >= 0 && idx <= 7) {
        uint32_t val = register_get32(registerfile_r(&age->gpc.cpu.regFiles[2], idx));
        printf("  %s = 0x%08x\n", name, val);
        return;
    }
    if (strcmp(name, "NIA") == 0) {
        char hex[16];
        as_hex(hex, sizeof hex, (long long)psw_get_nia(&age->gpc.cpu.psw), 5);
        printf("  NIA = %s\n", hex);
        return;
    }
    if (strcmp(name, "CC") == 0) { printf("  CC = %u\n", psw_get_cc(&age->gpc.cpu.psw)); return; }
    if (strcmp(name, "PSW1") == 0) { printf("  PSW1 = 0x%08x\n", register_get32(&age->gpc.cpu.psw.psw1)); return; }
    if (strcmp(name, "PSW2") == 0) { printf("  PSW2 = 0x%08x\n", register_get32(&age->gpc.cpu.psw.psw2)); return; }
    if (strcmp(name, "BSR") == 0) { printf("  BSR = %u\n", psw_get_bsr(&age->gpc.cpu.psw)); return; }
    if (strcmp(name, "DSR") == 0) { printf("  DSR = %u\n", psw_get_dsr(&age->gpc.cpu.psw)); return; }
    printf("*** Unknown register: %s\n", name);
}

static void show_disasm(Debugger *dbg, AGEHarness *age, uint32_t startAddr, int count) {
    uint32_t nia = psw_get_nia(&age->gpc.cpu.psw);
    uint32_t addr = startAddr;
    uint32_t limit = age->gpc.ram.totalHWCount;

    for (int i = 0; i < count && addr < limit; i++) {
        const Symbol *label = symtable_get_label_at(&age->sym, addr);
        if (label) printf("%s:\n", label->name);

        uint32_t hw1 = membus_get16(&age->gpc.ram, addr);
        uint32_t hw2 = membus_get16(&age->gpc.ram, addr + 1);
        DInstr v;
        const InstrDesc *d = instr_decode(hw1, hw2, &v);

        char addrHex[16];
        as_hex(addrHex, sizeof addrHex, (long long)addr, 5);
        char marker = (addr == nia) ? '>' : ' ';
        Breakpoint *bp = find_breakpoint_at(dbg, addr);
        char bpMark = (bp && bp->enabled) ? '*' : ' ';

        if (d) {
            int instrLen = d->pb.origLen;
            char disasm[256];
            instr_to_str(hw1, hw2, disasm, sizeof disasm);
            char hw1Hex[16], hw2Hex[16];
            as_hex(hw1Hex, sizeof hw1Hex, (long long)hw1, 4);
            if (instrLen > 1) as_hex(hw2Hex, sizeof hw2Hex, (long long)hw2, 4);
            else snprintf(hw2Hex, sizeof hw2Hex, "    ");
            printf("%c%c%s: %s %s  %s\n", marker, bpMark, addrHex, hw1Hex, hw2Hex, disasm);
            addr += (uint32_t)instrLen;
        } else {
            char hw1Hex[16];
            as_hex(hw1Hex, sizeof hw1Hex, (long long)hw1, 4);
            printf("%c%c%s: %s       DC    X'%s'\n", marker, bpMark, addrHex, hw1Hex, hw1Hex);
            addr += 1;
        }
    }
}

static void show_memory(AGEHarness *age, uint32_t startAddr, int count) {
    int row = 0;
    while (row < count) {
        uint32_t rowAddr = startAddr + (uint32_t)row;
        int cols = count - row;
        if (cols > 8) cols = 8;

        char line[128];
        int lpos = 0;
        char ascii[17];
        int apos = 0;
        for (int col = 0; col < cols; col++) {
            uint32_t hw = membus_get16(&age->gpc.ram, rowAddr + (uint32_t)col);
            char hex[8];
            as_hex(hex, sizeof hex, (long long)hw, 4);
            lpos += snprintf(line + lpos, sizeof(line) - (size_t)lpos, "%s%s", col > 0 ? " " : "", hex);
            int b1 = (int)((hw >> 8) & 0xff), b2 = (int)(hw & 0xff);
            ascii[apos++] = (b1 >= 0x20 && b1 <= 0x7e) ? (char)b1 : '.';
            ascii[apos++] = (b2 >= 0x20 && b2 <= 0x7e) ? (char)b2 : '.';
        }
        ascii[apos] = '\0';

        char addrHex[16];
        as_hex(addrHex, sizeof addrHex, (long long)rowAddr, 5);
        printf("  %s: %-39s  |%s|\n", addrHex, line, ascii);
        row += cols;
    }
}

static void show_memory_fullword(AGEHarness *age, uint32_t addr) {
    uint32_t val = membus_get32(&age->gpc.ram, addr);
    char addrHex[16], valHex[16];
    as_hex(addrHex, sizeof addrHex, (long long)addr, 5);
    as_hex(valHex, sizeof valHex, (long long)val, 8);
    printf("  %s: %s (int32: %d, uint32: %u)\n", addrHex, valHex, (int32_t)val, val);
}

static void show_breakpoints(Debugger *dbg, AGEHarness *age) {
    if (dbg->breakpointCount == 0) {
        printf("  (no breakpoints)\n");
        return;
    }
    for (int i = 0; i < dbg->breakpointCount; i++) {
        Breakpoint *bp = &dbg->breakpoints[i];
        char addrStr[80];
        format_addr(age, bp->addr, addrStr, sizeof addrStr);
        char nameStr[80];
        if (bp->name[0]) snprintf(nameStr, sizeof nameStr, " <%s>", bp->name);
        else nameStr[0] = '\0';
        printf("  [%s] %s%s\n", bp->enabled ? "ON " : "OFF", addrStr, nameStr);
    }
}

static void show_memwatchpoints(Debugger *dbg, AGEHarness *age) {
    if (dbg->memWatchpointCount == 0) {
        printf("  (no memory watchpoints)\n");
        return;
    }
    for (int i = 0; i < dbg->memWatchpointCount; i++) {
        MemWatchpoint *w = &dbg->memWatchpoints[i];
        uint32_t val = membus_get16(&age->gpc.ram, w->addr);
        char addrFmt[80];
        format_addr(age, w->addr, addrFmt, sizeof addrFmt);
        char valHex[8];
        as_hex(valHex, sizeof valHex, (long long)val, 4);
        char nameStr[80];
        if (w->name[0]) snprintf(nameStr, sizeof nameStr, " <%s>", w->name);
        else nameStr[0] = '\0';
        printf("  [%s] %s%s = %s\n", w->enabled ? "ON " : "OFF", addrFmt, nameStr, valHex);
    }
}

static void show_watches(Debugger *dbg, AGEHarness *age) {
    if (dbg->watchCount == 0) {
        printf("  (no watches)\n");
        return;
    }
    for (int i = 0; i < dbg->watchCount; i++) {
        WatchExpr *w = &dbg->watches[i];
        uint32_t hw = membus_get16(&age->gpc.ram, w->addr);
        char addrHex[16];
        as_hex(addrHex, sizeof addrHex, (long long)w->addr, 5);
        if (w->size >= 2) {
            uint32_t fw = membus_get32(&age->gpc.ram, w->addr);
            char hwHex[8], fwHex[16];
            as_hex(hwHex, sizeof hwHex, (long long)hw, 4);
            as_hex(fwHex, sizeof fwHex, (long long)fw, 8);
            printf("  %s @ %s: HW=%s  FW=%s (%d)\n", w->name, addrHex, hwHex, fwHex, (int32_t)fw);
        } else {
            char hwHex[8];
            as_hex(hwHex, sizeof hwHex, (long long)hw, 4);
            printf("  %s @ %s: %s (%d)\n", w->name, addrHex, hwHex, (int16_t)hw);
        }
    }
}

static void show_sections(AGEHarness *age) {
    if (age->sym.sectionCount == 0) {
        printf("  (no symbols loaded)\n");
        return;
    }
    printf("--- Section Map ---\n");
    for (int i = 0; i < age->sym.sectionCount; i++) {
        const Section *s = &age->sym.sections[i];
        uint32_t endAddr = s->address + s->size - 1;
        char lo[16], hi[16];
        as_hex(lo, sizeof lo, (long long)s->address, 5);
        as_hex(hi, sizeof hi, (long long)endAddr, 5);
        printf("  %s - %s  %-14s (%u HW, %s)\n", lo, hi, s->name, s->size, s->module ? s->module : "");
    }
}

static void show_symbol(AGEHarness *age, const char *nameIn) {
    if (age->sym.symbolCount == 0) {
        printf("*** No symbols loaded\n");
        return;
    }
    char upper[64];
    size_t n = 0;
    for (const char *p = nameIn; *p && n < sizeof(upper) - 1; p++, n++) upper[n] = (char)toupper((unsigned char)*p);
    upper[n] = '\0';

    bool found = false;
    for (int i = 0; i < age->sym.symbolCount; i++) {
        const char *symName = age->sym.symbols[i].name;
        if (symName && strstr(symName, upper)) {
            uint32_t addr = age->sym.symbols[i].address;
            const char *sect = symtable_get_section_at(&age->sym, addr);
            char addrHex[16];
            as_hex(addrHex, sizeof addrHex, (long long)addr, 5);
            printf("  %-16s addr=%s  section=%s\n", symName, addrHex, sect ? sect : "?");
            found = true;
        }
    }
    if (!found) printf("*** Symbol not found: %s\n", upper);
}

static void show_current_location(AGEHarness *age) {
    uint32_t nia = psw_get_nia(&age->gpc.cpu.psw);
    uint32_t hw1 = membus_get16(&age->gpc.ram, nia);
    uint32_t hw2 = membus_get16(&age->gpc.ram, nia + 1);
    DInstr v;
    const InstrDesc *d = instr_decode(hw1, hw2, &v);
    int instrLen = d ? d->pb.origLen : 1;

    char disasm[256];
    instr_to_str(hw1, hw2, disasm, sizeof disasm);
    char hw1Hex[16], hw2Hex[16], niaHex[16];
    as_hex(hw1Hex, sizeof hw1Hex, (long long)hw1, 4);
    if (instrLen > 1) as_hex(hw2Hex, sizeof hw2Hex, (long long)hw2, 4);
    else snprintf(hw2Hex, sizeof hw2Hex, "    ");
    as_hex(niaHex, sizeof niaHex, (long long)nia, 5);

    char csect[32];
    symtable_format_csect(&age->sym, nia, csect, sizeof csect);
    printf(">> %s %s: %s %s  %s\n", niaHex, csect, hw1Hex, hw2Hex, disasm);
}

/* Prints the HAL/S source line active at addr, if a source map is
 * loaded and one is mapped there. Returns true iff something was
 * printed (callers use this to distinguish "no source map" from "no
 * statement mapped at this exact address"). */
static bool show_source_line(Debugger *dbg, uint32_t addr) {
    if (!dbg->srcmap) return false;
    int stmt = 0;
    const char *text = sourcemap_lookup(dbg->srcmap, addr, &stmt);
    if (!text) return false;
    printf("HAL/S %4d:%s\n", stmt, text);
    return true;
}

/* Auto-display variant used both at debugger stops and (new) as
 * instructions flow by during 'trace'/'htrace': shows the source line
 * only when it differs from the last one shown, matching yaHALMAT2's
 * --debug behavior, sharing the same lastStmt/hasLastStmt tracking in
 * both cases so flowing past a statement and later stopping inside it
 * doesn't reprint it twice. */
static void show_source_line_if_changed(Debugger *dbg, uint32_t addr) {
    if (!dbg->srcmap) return;
    int stmt = 0;
    const char *text = sourcemap_lookup(dbg->srcmap, addr, &stmt);
    if (text && (!dbg->hasLastStmt || stmt != dbg->lastStmt)) {
        printf("HAL/S %4d:%s\n", stmt, text);
        dbg->lastStmt = stmt;
        dbg->hasLastStmt = true;
    }
}

static void show_backtrace(Debugger *dbg) {
    if (dbg->recentCount == 0) {
        printf("  (no history yet)\n");
        return;
    }
    for (int i = 0; i < dbg->recentCount; i++) {
        int idx = (dbg->recentHead - 1 - i + DEBUGGER_BACKTRACE_SIZE * 2) % DEBUGGER_BACKTRACE_SIZE;
        char addrHex[16];
        as_hex(addrHex, sizeof addrHex, (long long)dbg->recent[idx].addr, 5);
        printf("  #%-3d %s: %s\n", i, addrHex, dbg->recent[idx].disasm);
    }
}

typedef struct {
    const char *names;
    const char *desc;
} HelpEntry;

static const HelpEntry HELP_ENTRIES[] = {
    {"step, s, si [N]", "Step N instructions (default 1)"},
    {"next, n", "Step over (run until just after this instruction)"},
    {"run, r, c, continue, g, go", "Run until breakpoint/halt"},
    {"break, b, bp ADDR", "Set breakpoint"},
    {"clear, bc, del, delete ADDR|*", "Clear breakpoint(s)"},
    {"bd ADDR", "Disable breakpoint"},
    {"be ADDR", "Enable breakpoint"},
    {"bl", "List breakpoints"},
    {"mw, memwatch, watchmem ADDR [count]", "Set memory watchpoint (break on write)"},
    {"mwc, memwatchclear ADDR|*", "Clear memory watchpoint(s)"},
    {"mwl", "List memory watchpoints"},
    {"watch, w ADDR [size]", "Add watch expression (shown on every stop)"},
    {"unwatch, wc ADDR|*", "Remove watch expression(s)"},
    {"wl", "List watch expressions"},
    {"reg, regs, registers [NAME]", "Show registers (all, or one by name)"},
    {"set REGISTER VALUE", "Set register value ($Rn/$FPn/NIA)"},
    {"set width N", "Wrap trace/htrace register changes at N columns (0 = off)"},
    {"disasm, d, u, unassemble [ADDR] [COUNT]", "Disassemble instructions (default: NIA, 20)"},
    {"mem, x, examine ADDR [COUNT]", "Examine memory, halfwords (default 16)"},
    {"xw, x32, fw ADDR", "Examine memory, one fullword"},
    {"deposit, dep, dw ADDR VALUE... [-w]", "Write halfwords (fullwords with -w)"},
    {"sym, symbol NAME", "Look up symbol (substring match)"},
    {"sections, sect", "Show section map"},
    {"where, loc, here", "Show current location"},
    {"source, src", "Show the HAL/S source line at the current location"},
    {"steps", "Show step count"},
    {"backtrace, bt", "Show recently executed instructions"},
    {"trace, htrace [on|off]", "Toggle or show instruction trace (+ HAL/S source lines, if mapped)"},
    {"info breakpoints|watches|memwatch|registers|sections", "Show info"},
    {"help, h, ? [command]", "Show this help"},
    {"quit, q, exit", "Exit the debugger"},
};
#define HELP_ENTRY_COUNT (sizeof(HELP_ENTRIES) / sizeof(HELP_ENTRIES[0]))

static void show_help(const char *forCmd) {
    if (forCmd) {
        for (size_t i = 0; i < HELP_ENTRY_COUNT; i++) {
            if (strstr(HELP_ENTRIES[i].names, forCmd)) {
                printf("  %-42s %s\n", HELP_ENTRIES[i].names, HELP_ENTRIES[i].desc);
                return;
            }
        }
        printf("*** Unknown command: %s\n", forCmd);
        return;
    }
    printf("Available commands:\n");
    for (size_t i = 0; i < HELP_ENTRY_COUNT; i++) {
        printf("  %-42s %s\n", HELP_ENTRIES[i].names, HELP_ENTRIES[i].desc);
    }
}

/* ---------------------------------------------------------------------
 * Breakpoint mutation commands
 * ------------------------------------------------------------------- */

static void cmd_break(Debugger *dbg, AGEHarness *age, const char *addrStr) {
    uint32_t addr;
    if (!resolve_addr(age, addrStr, &addr)) {
        printf("*** Cannot resolve: %s\n", addrStr);
        return;
    }
    Breakpoint *bp = find_breakpoint_at(dbg, addr);
    if (!bp) {
        if (dbg->breakpointCount >= DEBUGGER_MAX_BREAKPOINTS) {
            printf("*** Too many breakpoints\n");
            return;
        }
        bp = &dbg->breakpoints[dbg->breakpointCount++];
        bp->addr = addr;
    }
    bp->enabled = true;
    const Symbol *label = symtable_get_label_at(&age->sym, addr);
    snprintf(bp->name, sizeof bp->name, "%s", label ? label->name : addrStr);

    char addrFmt[80];
    format_addr(age, addr, addrFmt, sizeof addrFmt);
    printf("Breakpoint set at %s\n", addrFmt);
}

static void cmd_clear(Debugger *dbg, AGEHarness *age, const char *addrStr) {
    if (strcmp(addrStr, "*") == 0) {
        dbg->breakpointCount = 0;
        printf("All breakpoints cleared\n");
        return;
    }
    uint32_t addr;
    if (!resolve_addr(age, addrStr, &addr)) {
        printf("*** Cannot resolve: %s\n", addrStr);
        return;
    }
    for (int i = 0; i < dbg->breakpointCount; i++) {
        if (dbg->breakpoints[i].addr == addr) {
            char addrFmt[80];
            format_addr(age, addr, addrFmt, sizeof addrFmt);
            for (int j = i; j < dbg->breakpointCount - 1; j++) dbg->breakpoints[j] = dbg->breakpoints[j + 1];
            dbg->breakpointCount--;
            printf("Breakpoint cleared at %s\n", addrFmt);
            return;
        }
    }
    char hex[16];
    as_hex(hex, sizeof hex, (long long)addr, 5);
    printf("*** No breakpoint at %s\n", hex);
}

static void cmd_enable_disable(Debugger *dbg, AGEHarness *age, const char *addrStr, bool enable) {
    uint32_t addr;
    if (!resolve_addr(age, addrStr, &addr)) {
        printf("*** Cannot resolve: %s\n", addrStr);
        return;
    }
    Breakpoint *bp = find_breakpoint_at(dbg, addr);
    if (!bp) {
        char hex[16];
        as_hex(hex, sizeof hex, (long long)addr, 5);
        printf("*** No breakpoint at %s\n", hex);
        return;
    }
    bp->enabled = enable;
    char addrFmt[80];
    format_addr(age, addr, addrFmt, sizeof addrFmt);
    printf("Breakpoint %s at %s\n", enable ? "enabled" : "disabled", addrFmt);
}

static void cmd_deposit(AGEHarness *age, int argc, char **argv) {
    if (argc < 3) {
        printf("*** Usage: deposit ADDR VALUE... [-w]\n");
        return;
    }
    uint32_t addr;
    if (!resolve_addr(age, argv[1], &addr)) {
        printf("*** Cannot resolve: %s\n", argv[1]);
        return;
    }
    bool fullword = false;
    int idx = 0;
    for (int i = 2; i < argc; i++) {
        if (strcmp(argv[i], "-w") == 0 || strcmp(argv[i], "--fullword") == 0) {
            fullword = true;
            continue;
        }
        const char *s = argv[i];
        if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X')) s += 2;
        char *end;
        unsigned long val = strtoul(s, &end, 16);
        if (*end != '\0' || *s == '\0') {
            printf("*** Invalid hex value: %s\n", argv[i]);
            return;
        }
        char addrHex[16], valHex[16];
        if (fullword) {
            uint32_t a = addr + (uint32_t)(idx * 2);
            membus_set32(&age->gpc.ram, a, (uint32_t)val, false);
            as_hex(addrHex, sizeof addrHex, (long long)a, 5);
            as_hex(valHex, sizeof valHex, (long long)(uint32_t)val, 8);
        } else {
            uint32_t a = addr + (uint32_t)idx;
            membus_set16(&age->gpc.ram, a, (uint32_t)(val & 0xFFFF), false);
            as_hex(addrHex, sizeof addrHex, (long long)a, 5);
            as_hex(valHex, sizeof valHex, (long long)(val & 0xFFFF), 4);
        }
        printf("  %s: %s\n", addrHex, valHex);
        idx++;
    }
}

static void cmd_mw(Debugger *dbg, AGEHarness *age, const char *addrStr, int count) {
    uint32_t addr;
    if (!resolve_addr(age, addrStr, &addr)) {
        printf("*** Cannot resolve: %s\n", addrStr);
        return;
    }
    const Symbol *label = symtable_get_label_at(&age->sym, addr);
    for (int i = 0; i < count; i++) {
        uint32_t a = addr + (uint32_t)i;
        MemWatchpoint *w = find_memwatch_at(dbg, a);
        if (!w) {
            if (dbg->memWatchpointCount >= DEBUGGER_MAX_MEMWATCH) {
                printf("*** Too many memory watchpoints\n");
                return;
            }
            w = &dbg->memWatchpoints[dbg->memWatchpointCount++];
            w->addr = a;
            w->hasBefore = false;
        }
        w->enabled = true;
        if (count > 1) snprintf(w->name, sizeof w->name, "%s+%d", label ? label->name : addrStr, i);
        else snprintf(w->name, sizeof w->name, "%s", label ? label->name : addrStr);
    }
    char addrFmt[80];
    format_addr(age, addr, addrFmt, sizeof addrFmt);
    if (count > 1) printf("Memory watchpoint set at %s (%d HW)\n", addrFmt, count);
    else printf("Memory watchpoint set at %s\n", addrFmt);
}

static void cmd_mwc(Debugger *dbg, AGEHarness *age, const char *addrStr) {
    if (strcmp(addrStr, "*") == 0) {
        dbg->memWatchpointCount = 0;
        printf("All memory watchpoints cleared\n");
        return;
    }
    uint32_t addr;
    if (!resolve_addr(age, addrStr, &addr)) {
        printf("*** Cannot resolve: %s\n", addrStr);
        return;
    }
    for (int i = 0; i < dbg->memWatchpointCount; i++) {
        if (dbg->memWatchpoints[i].addr == addr) {
            char addrFmt[80];
            format_addr(age, addr, addrFmt, sizeof addrFmt);
            for (int j = i; j < dbg->memWatchpointCount - 1; j++) dbg->memWatchpoints[j] = dbg->memWatchpoints[j + 1];
            dbg->memWatchpointCount--;
            printf("Memory watchpoint cleared at %s\n", addrFmt);
            return;
        }
    }
    char hex[16];
    as_hex(hex, sizeof hex, (long long)addr, 5);
    printf("*** No memory watchpoint at %s\n", hex);
}

static void cmd_watch(Debugger *dbg, AGEHarness *age, const char *addrStr, int size) {
    uint32_t addr;
    if (!resolve_addr(age, addrStr, &addr)) {
        printf("*** Cannot resolve: %s\n", addrStr);
        return;
    }
    WatchExpr *w = find_watch_at(dbg, addr);
    if (!w) {
        if (dbg->watchCount >= DEBUGGER_MAX_WATCH) {
            printf("*** Too many watches\n");
            return;
        }
        w = &dbg->watches[dbg->watchCount++];
        w->addr = addr;
    }
    const Symbol *label = symtable_get_label_at(&age->sym, addr);
    snprintf(w->name, sizeof w->name, "%s", label ? label->name : addrStr);
    w->size = size;

    char addrFmt[80];
    format_addr(age, addr, addrFmt, sizeof addrFmt);
    printf("Watch added: %s @ %s\n", w->name, addrFmt);
}

static void cmd_unwatch(Debugger *dbg, AGEHarness *age, const char *addrStr) {
    if (strcmp(addrStr, "*") == 0) {
        dbg->watchCount = 0;
        printf("All watches cleared\n");
        return;
    }
    uint32_t addr;
    if (!resolve_addr(age, addrStr, &addr)) {
        printf("*** Cannot resolve: %s\n", addrStr);
        return;
    }
    for (int i = 0; i < dbg->watchCount; i++) {
        if (dbg->watches[i].addr == addr) {
            char addrFmt[80];
            format_addr(age, addr, addrFmt, sizeof addrFmt);
            for (int j = i; j < dbg->watchCount - 1; j++) dbg->watches[j] = dbg->watches[j + 1];
            dbg->watchCount--;
            printf("Watch removed at %s\n", addrFmt);
            return;
        }
    }
    char hex[16];
    as_hex(hex, sizeof hex, (long long)addr, 5);
    printf("*** No watch at %s\n", hex);
}

/* Register alteration (mirrors cmd_debug.coffee's setRegister) plus one
 * yaGPC2-specific extension not in the CoffeeScript original: 'set width
 * N' controls wrapping of the register-changes list printed during
 * 'trace'/'htrace' (see debugger_format_changes()) -- N<=0 disables
 * wrapping entirely. Memory alteration is 'deposit', not 'set'. */
static void cmd_set(Debugger *dbg, AGEHarness *age, const char *nameIn, const char *valStr) {
    char name[16];
    size_t n = 0;
    for (const char *p = nameIn; *p && n < sizeof(name) - 1; p++, n++) name[n] = (char)toupper((unsigned char)*p);
    name[n] = '\0';

    if (strcmp(name, "WIDTH") == 0) {
        char *end;
        long width = strtol(valStr, &end, 10);
        if (*end != '\0' || *valStr == '\0') {
            printf("*** Invalid value: %s\n", valStr);
            return;
        }
        dbg->lineWidth = (int)width;
        if (dbg->lineWidth > 0) printf("width = %d\n", dbg->lineWidth);
        else printf("width = 0 (wrapping disabled)\n");
        return;
    }

    bool isHex = valStr[0] == '0' && (valStr[1] == 'x' || valStr[1] == 'X');
    const char *v = valStr + (isHex ? 2 : 0);
    char *end;
    unsigned long val = strtoul(v, &end, isHex ? 16 : 10);
    if (*end != '\0' || *v == '\0') {
        printf("*** Invalid value: %s\n", valStr);
        return;
    }

    int grSet = (int)psw_get_reg_set(&age->gpc.cpu.psw);
    int idx, consumed;
    if (sscanf(name, "R%d%n", &idx, &consumed) == 1 && consumed == (int)strlen(name) && idx >= 0 && idx <= 7) {
        register_set32(registerfile_r(&age->gpc.cpu.regFiles[grSet], idx), (uint32_t)val);
        printf("%s = 0x%08x\n", name, (uint32_t)val);
        return;
    }
    if (sscanf(name, "FP%d%n", &idx, &consumed) == 1 && consumed == (int)strlen(name) && idx >= 0 && idx <= 7) {
        register_set32(registerfile_r(&age->gpc.cpu.regFiles[2], idx), (uint32_t)val);
        printf("%s = 0x%08x\n", name, (uint32_t)val);
        return;
    }
    if (strcmp(name, "NIA") == 0) {
        psw_set_nia(&age->gpc.cpu.psw, (uint32_t)val);
        char hex[16];
        as_hex(hex, sizeof hex, (long long)val, 5);
        printf("NIA = %s\n", hex);
        return;
    }
    printf("*** Cannot set: %s\n", name);
}

/* ---------------------------------------------------------------------
 * Resume commands: step / next / run
 * ------------------------------------------------------------------- */

/* debugger_hook() always lets the instruction it's currently stopped at
 * execute "for free" once a resume command is dispatched (see its own
 * comment) -- stepsRemaining only counts instructions BEYOND that one,
 * so 'step 1' sets 0, not 1. */
static void cmd_step(Debugger *dbg, long count) { dbg->stepsRemaining = count - 1; }

/* Sets a one-shot breakpoint right after the current instruction, then
 * runs freely (like 'run') until something stops it -- correctly skips
 * over a BAL/subroutine call without knowing anything about the HAL/S
 * runtime's call convention, since execution naturally lands back here
 * once (if) the call returns. Ported faithfully from cmd_debug.coffee's
 * 'next', which does exactly this. */
static void cmd_next(Debugger *dbg, uint32_t nia, uint32_t hw1, uint32_t hw2) {
    DInstr v;
    const InstrDesc *d = instr_decode(hw1, hw2, &v);
    int instrLen = d ? d->pb.origLen : 1;
    uint32_t nextAddr = nia + (uint32_t)instrLen;

    if (!find_breakpoint_at(dbg, nextAddr)) {
        dbg->hasTempBreakpoint = true;
        dbg->tempBreakpoint = nextAddr;
    }
    dbg->stepsRemaining = LONG_MAX;
}

static void cmd_run(Debugger *dbg) { dbg->stepsRemaining = LONG_MAX; }

/* ---------------------------------------------------------------------
 * Command dispatch / REPL
 * ------------------------------------------------------------------- */

static bool cmd_is(const char *tok, ...) {
    va_list ap;
    va_start(ap, tok);
    const char *alt;
    bool match = false;
    while ((alt = va_arg(ap, const char *)) != NULL) {
        if (strcmp(tok, alt) == 0) {
            match = true;
            break;
        }
    }
    va_end(ap);
    return match;
}

static int tokenize(char *line, char *tokens[DEBUGGER_MAX_TOKENS]) {
    int n = 0;
    char *p = strtok(line, " \t");
    while (p && n < DEBUGGER_MAX_TOKENS) {
        tokens[n++] = p;
        p = strtok(NULL, " \t");
    }
    return n;
}

/* gdb allows a repeat count to be typed directly after a command with no
 * intervening space (e.g. "step5" same as "step 5") -- split such a
 * token in place if the first one is letters immediately followed by
 * digits and nothing else, shifting the remaining tokens up by one
 * slot. "x32" (an alias for xw, not "x" + count 32) is the one existing
 * command name that itself ends in digits, so it's excluded. */
static int split_digit_suffix(char *tokens[DEBUGGER_MAX_TOKENS], int argc) {
    if (argc == 0 || argc >= DEBUGGER_MAX_TOKENS) return argc;
    char *tok = tokens[0];
    if (strcmp(tok, "x32") == 0) return argc;

    char *p = tok;
    while (*p && !isdigit((unsigned char)*p)) p++;
    if (p == tok || *p == '\0') return argc; /* no letters, or no digits at all */
    for (char *q = p; *q; q++) {
        if (!isdigit((unsigned char)*q)) return argc; /* letters after the digit run too -- leave it alone */
    }

    /* Copy the digit run out BEFORE truncating tok in place -- p+1 would
     * otherwise point one byte past the digit we just overwrote with the
     * new NUL terminator, not at a copy of it. */
    static char digitBuf[32];
    size_t digitLen = strlen(p);
    if (digitLen >= sizeof(digitBuf)) return argc;
    memcpy(digitBuf, p, digitLen + 1);

    *p = '\0';
    for (int i = argc; i > 1; i--) tokens[i] = tokens[i - 1];
    tokens[1] = digitBuf;
    return argc + 1;
}

/* Returns true if this command resumes execution (step/next/run) --
 * the caller should stop prompting and let debugger_hook return. */
static bool dispatch_command(Debugger *dbg, AGEHarness *age, uint32_t nia, uint32_t hw1, uint32_t hw2, int argc,
                              char **argv) {
    const char *cmd = argv[0];

    if (cmd_is(cmd, "step", "s", "si", NULL)) {
        long count = 1;
        if (argc > 1) count = strtol(argv[1], NULL, 10);
        if (count < 1) {
            printf("*** Usage: step [N]\n");
            return false;
        }
        cmd_step(dbg, count);
        return true;
    }
    if (cmd_is(cmd, "next", "n", NULL)) {
        cmd_next(dbg, nia, hw1, hw2);
        return true;
    }
    if (cmd_is(cmd, "run", "r", "c", "continue", "g", "go", NULL)) {
        cmd_run(dbg);
        return true;
    }
    if (cmd_is(cmd, "break", "b", "bp", NULL)) {
        if (argc < 2) printf("*** Usage: break ADDR\n");
        else cmd_break(dbg, age, argv[1]);
        return false;
    }
    if (cmd_is(cmd, "clear", "bc", "del", "delete", NULL)) {
        if (argc < 2) printf("*** Usage: clear ADDR|*\n");
        else cmd_clear(dbg, age, argv[1]);
        return false;
    }
    if (cmd_is(cmd, "bd", NULL)) {
        if (argc < 2) printf("*** Usage: bd ADDR\n");
        else cmd_enable_disable(dbg, age, argv[1], false);
        return false;
    }
    if (cmd_is(cmd, "be", NULL)) {
        if (argc < 2) printf("*** Usage: be ADDR\n");
        else cmd_enable_disable(dbg, age, argv[1], true);
        return false;
    }
    if (cmd_is(cmd, "bl", NULL)) {
        show_breakpoints(dbg, age);
        return false;
    }
    if (cmd_is(cmd, "mw", "memwatch", "watchmem", NULL)) {
        if (argc < 2) {
            printf("*** Usage: mw ADDR [count]\n");
            return false;
        }
        int count = 1;
        if (argc > 2) count = (int)strtol(argv[2], NULL, 10);
        cmd_mw(dbg, age, argv[1], count);
        return false;
    }
    if (cmd_is(cmd, "mwc", "memwatchclear", NULL)) {
        if (argc < 2) printf("*** Usage: mwc ADDR|*\n");
        else cmd_mwc(dbg, age, argv[1]);
        return false;
    }
    if (cmd_is(cmd, "mwl", NULL)) {
        show_memwatchpoints(dbg, age);
        return false;
    }
    if (cmd_is(cmd, "watch", "w", NULL)) {
        if (argc < 2) {
            printf("*** Usage: watch ADDR [size]\n");
            return false;
        }
        int size = 2;
        if (argc > 2) size = (int)strtol(argv[2], NULL, 10);
        cmd_watch(dbg, age, argv[1], size);
        return false;
    }
    if (cmd_is(cmd, "unwatch", "wc", NULL)) {
        if (argc < 2) printf("*** Usage: unwatch ADDR|*\n");
        else cmd_unwatch(dbg, age, argv[1]);
        return false;
    }
    if (cmd_is(cmd, "wl", NULL)) {
        show_watches(dbg, age);
        return false;
    }
    if (cmd_is(cmd, "reg", "regs", "registers", NULL)) {
        if (argc > 1) show_register(age, argv[1]);
        else show_registers(dbg, age);
        return false;
    }
    if (cmd_is(cmd, "set", NULL)) {
        if (argc < 3) printf("*** Usage: set REGISTER VALUE\n");
        else cmd_set(dbg, age, argv[1], argv[2]);
        return false;
    }
    if (cmd_is(cmd, "disasm", "d", "u", "unassemble", NULL)) {
        uint32_t startAddr = nia;
        if (argc > 1 && !resolve_addr(age, argv[1], &startAddr)) {
            printf("*** Cannot resolve: %s\n", argv[1]);
            return false;
        }
        int count = 20;
        if (argc > 2) count = (int)strtol(argv[2], NULL, 10);
        show_disasm(dbg, age, startAddr, count);
        return false;
    }
    if (cmd_is(cmd, "mem", "x", "examine", NULL)) {
        if (argc < 2) {
            printf("*** Usage: mem ADDR [count]\n");
            return false;
        }
        uint32_t addr;
        if (!resolve_addr(age, argv[1], &addr)) {
            printf("*** Cannot resolve: %s\n", argv[1]);
            return false;
        }
        int count = 16;
        if (argc > 2) count = (int)strtol(argv[2], NULL, 10);
        show_memory(age, addr, count);
        return false;
    }
    if (cmd_is(cmd, "xw", "x32", "fw", NULL)) {
        if (argc < 2) {
            printf("*** Usage: xw ADDR\n");
            return false;
        }
        uint32_t addr;
        if (!resolve_addr(age, argv[1], &addr)) {
            printf("*** Cannot resolve: %s\n", argv[1]);
            return false;
        }
        show_memory_fullword(age, addr);
        return false;
    }
    if (cmd_is(cmd, "deposit", "dep", "dw", NULL)) {
        cmd_deposit(age, argc, argv);
        return false;
    }
    if (cmd_is(cmd, "sym", "symbol", NULL)) {
        if (argc < 2) printf("*** Usage: sym NAME\n");
        else show_symbol(age, argv[1]);
        return false;
    }
    if (cmd_is(cmd, "sections", "sect", NULL)) {
        show_sections(age);
        return false;
    }
    if (cmd_is(cmd, "where", "loc", "here", NULL)) {
        show_current_location(age);
        return false;
    }
    if (cmd_is(cmd, "source", "src", NULL)) {
        if (!dbg->srcmap) printf("*** No source map loaded (see --source-map)\n");
        else if (!show_source_line(dbg, nia)) printf("*** No HAL/S source mapped at this address\n");
        return false;
    }
    if (cmd_is(cmd, "steps", NULL)) {
        printf("Step count: %ld\n", dbg->currentStep);
        return false;
    }
    if (cmd_is(cmd, "backtrace", "bt", NULL)) {
        show_backtrace(dbg);
        return false;
    }
    if (cmd_is(cmd, "trace", "htrace", NULL)) {
        if (argc > 1 && strcmp(argv[1], "on") == 0) {
            dbg->traceEnabled = true;
            printf("Trace enabled\n");
        } else if (argc > 1 && strcmp(argv[1], "off") == 0) {
            dbg->traceEnabled = false;
            printf("Trace disabled\n");
        } else {
            printf("Trace is %s\n", dbg->traceEnabled ? "on" : "off");
        }
        return false;
    }
    if (cmd_is(cmd, "info", "i", NULL)) {
        if (argc < 2) {
            printf("*** Usage: info breakpoints|watches|memwatch|registers|sections\n");
            return false;
        }
        if (cmd_is(argv[1], "breakpoints", "b", "bp", NULL)) show_breakpoints(dbg, age);
        else if (cmd_is(argv[1], "watches", "w", "watch", NULL)) show_watches(dbg, age);
        else if (cmd_is(argv[1], "memwatch", "mw", NULL)) show_memwatchpoints(dbg, age);
        else if (cmd_is(argv[1], "registers", "r", "reg", NULL)) show_registers(dbg, age);
        else if (cmd_is(argv[1], "sections", "s", NULL)) show_sections(age);
        else printf("*** Unknown info subcommand: %s\n", argv[1]);
        return false;
    }
    if (cmd_is(cmd, "help", "h", "?", NULL)) {
        show_help(argc > 1 ? argv[1] : NULL);
        return false;
    }
    if (cmd_is(cmd, "quit", "q", "exit", NULL)) {
        printf("Goodbye.\n");
        exit(0);
    }

    printf("*** Unknown command: %s (try 'help')\n", cmd);
    return false;
}

static void debugger_repl(Debugger *dbg, AGEHarness *age, uint32_t nia, uint32_t hw1, uint32_t hw2) {
    char line[512];
    for (;;) {
        printf("gpc> ");
        fflush(stdout);
        if (!fgets(line, sizeof line, stdin)) {
            printf("\nGoodbye.\n");
            exit(0);
        }
        size_t len = strlen(line);
        while (len > 0 && (line[len - 1] == '\n' || line[len - 1] == '\r')) line[--len] = '\0';

        char *trimmed = line;
        while (*trimmed == ' ' || *trimmed == '\t') trimmed++;

        char lineBuf[512];
        if (trimmed[0] == '\0') {
            if (!dbg->hasLastLine) continue;
            snprintf(lineBuf, sizeof lineBuf, "%s", dbg->lastLine);
        } else {
            snprintf(dbg->lastLine, sizeof dbg->lastLine, "%s", trimmed);
            dbg->hasLastLine = true;
            snprintf(lineBuf, sizeof lineBuf, "%s", trimmed);
        }

        char *tokens[DEBUGGER_MAX_TOKENS];
        int argc = tokenize(lineBuf, tokens);
        if (argc == 0) continue;
        argc = split_digit_suffix(tokens, argc);

        if (dispatch_command(dbg, age, nia, hw1, hw2, argc, tokens)) return;
    }
}

/* ---------------------------------------------------------------------
 * Public interface
 * ------------------------------------------------------------------- */

Debugger *debugger_create(const Options *opts) {
    Debugger *dbg = calloc(1, sizeof(Debugger));
    dbg->traceEnabled = opts->trace;
    dbg->lineWidth = 132;

    if (opts->sourceMap) dbg->srcmap = sourcemap_load(opts->sourceMap);

    if (opts->breakAddr) {
        const char *s = opts->breakAddr;
        if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X')) s += 2;
        Breakpoint *bp = &dbg->breakpoints[dbg->breakpointCount++];
        bp->addr = (uint32_t)strtoul(s, NULL, 16);
        bp->enabled = true;
        snprintf(bp->name, sizeof bp->name, "%s", opts->breakAddr);
    }
    return dbg;
}

void debugger_free(Debugger *dbg) {
    if (dbg->srcmap) sourcemap_free(dbg->srcmap);
    free(dbg);
}

bool debugger_wants_trace(const Debugger *dbg) { return dbg->traceEnabled; }

int debugger_line_width(const Debugger *dbg) { return dbg->lineWidth; }

/* Formats `changes` as "NAME: OLD->NEW, NAME: OLD->NEW, ..." (same token
 * format run.c's own flat join uses), wrapped so no printed line exceeds
 * dbg->lineWidth columns -- wrapping only ever happens between whole
 * "NAME: OLD->NEW" entries, never mid-entry, with continuation lines
 * indented to align under the first entry rather than the left margin.
 * `prefix` is everything the caller
 * has already printed earlier on this same line (used only to measure
 * that indent); `out` receives just the changes portion (no leading
 * content, no trailing newline) to be concatenated directly after
 * `prefix`. */
void debugger_format_changes(const Debugger *dbg, const char *prefix, const RegChange *changes, int changeCount,
                              char *out, size_t outSize) {
    out[0] = '\0';
    if (changeCount <= 0) return;

    int width = dbg->lineWidth;
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

        if (!firstOnLine && width > 0 && lineLen + tokenLen > (size_t)width) {
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

bool debugger_hook(Debugger *dbg, AGEHarness *age, uint32_t nia, uint32_t hw1, uint32_t hw2, long step) {
    dbg->currentStep = step;

    /* Checked on every call, including the first one after a resume
     * command: unlike cmd_debug.coffee's _execLoop (which shares one
     * "check, then execute" iteration for every instruction of a
     * dispatch, and so must skip the check on iteration 0 to avoid
     * instantly re-triggering the breakpoint it's already sitting on),
     * this hook only ever gets one call per nia -- the instruction it's
     * stopped at always executes unconditionally once resumed (below),
     * so there's no "same position" re-check to guard against, and
     * skipping this check would incorrectly miss a breakpoint/'next'
     * target landing on the very next instruction. */
    bool shouldStop = false;
    char stopMsg[256] = "";

    /* Memory write-watchpoints ('mw'): each entry's "before" value was
     * snapshotted at the end of the PREVIOUS hook call (right before
     * that call's instruction executed) -- comparing it here, at the
     * start of the call for the NEXT instruction, is equivalent to
     * cmd_debug.coffee's execOne() snapshotting before ap101_exec1()
     * and diffing after it in one place, just split across the two
     * calls that bracket the actual execution in this architecture.
     * Checked on every call, regardless of stepsRemaining, matching
     * memory watchpoints always taking priority over 'step'/'run'. */
    for (int i = 0; i < dbg->memWatchpointCount; i++) {
        MemWatchpoint *w = &dbg->memWatchpoints[i];
        if (!w->enabled) continue;
        uint16_t newVal = (uint16_t)membus_get16(&age->gpc.ram, w->addr);
        if (w->hasBefore && newVal != w->beforeVal) {
            char addrFmt[16];
            format_addr_plain(w->addr, addrFmt, sizeof addrFmt);
            char oldHex[8], newHex[8];
            as_hex(oldHex, sizeof oldHex, (long long)w->beforeVal, 4);
            as_hex(newHex, sizeof newHex, (long long)newVal, 4);
            char nameSuffix[80];
            if (w->name[0]) snprintf(nameSuffix, sizeof nameSuffix, " (%s)", w->name);
            else nameSuffix[0] = '\0';
            snprintf(stopMsg, sizeof stopMsg, "memory watchpoint: HW %s%s changed %s -> %s", addrFmt, nameSuffix,
                     oldHex, newHex);
            shouldStop = true;
        }
        w->beforeVal = newVal;
        w->hasBefore = true;
    }

    {
        bool tempHit = dbg->hasTempBreakpoint && nia == dbg->tempBreakpoint;
        Breakpoint *bp = find_breakpoint_at(dbg, nia);
        if (tempHit || (bp && bp->enabled)) {
            char addrFmt[16];
            format_addr_plain(nia, addrFmt, sizeof addrFmt);
            snprintf(stopMsg, sizeof stopMsg, "breakpoint at %s", addrFmt);
            shouldStop = true;
        }
    }

    /* Record every instruction the hook sees, stopped-at or not -- "how
     * did I get here" should include the one currently at the prompt. */
    char disasm[256];
    instr_to_str(hw1, hw2, disasm, sizeof disasm);
    RecentInstr *slot = &dbg->recent[dbg->recentHead];
    slot->addr = nia;
    snprintf(slot->disasm, sizeof slot->disasm, "%s", disasm);
    dbg->recentHead = (dbg->recentHead + 1) % DEBUGGER_BACKTRACE_SIZE;
    if (dbg->recentCount < DEBUGGER_BACKTRACE_SIZE) dbg->recentCount++;

    if (!shouldStop && dbg->stepsRemaining > 0) {
        dbg->stepsRemaining--;
        dbg->instructionsThisResume++;
        /* 'trace'/'htrace': show the HAL/S source line as instructions
         * flow by, not just at stops -- printed here (before returning)
         * so it lands just before this instruction's own trace line,
         * which run.c prints only after ap101_exec1() actually runs it. */
        if (debugger_wants_trace(dbg)) show_source_line_if_changed(dbg, nia);
        return true;
    }

    dbg->hasTempBreakpoint = false;
    dbg->stepsRemaining = 0;

    if (shouldStop) printf("--- stopped: %s (%ld steps) ---\n", stopMsg, step);
    show_current_location(age);
    show_source_line_if_changed(dbg, nia);
    show_stop_registers(dbg, age);
    if (dbg->watchCount > 0) show_watches(dbg, age);

    debugger_repl(dbg, age, nia, hw1, hw2);

    /* A resume command was just dispatched inside that REPL call:
     * snapshot "before" state for show_stop_registers()'s diff-vs-dump
     * decision at the *next* stop, and pre-count the "free" instruction
     * about to execute below (return true) -- it happens without another
     * debugger_hook() call to increment instructionsThisResume for it. */
    ageharness_snapshot_regs(age, &dbg->beforeResumeRegs);
    dbg->instructionsThisResume = 1;

    return true;
}
