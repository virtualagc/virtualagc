#include "run.h"

#include <ctype.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "compat.h"
#include "cpu_instr.h"
#include "strfmt.h"
#include "trace.h"

static void halucp_error_cb(void *ctx, const char *msg) {
    (void)ctx;
    fprintf(stderr, "\n*** %s\n\n", msg);
}

void batchrunner_init(BatchRunner *r, const Options *opts) {
    memset(r, 0, sizeof(*r));
    r->opts = opts;
    r->maxSteps = atol(opts->maxSteps);
    if (opts->breakAddr) {
        const char *s = opts->breakAddr;
        if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X')) s += 2;
        r->breakpoint = (uint32_t)strtoul(s, NULL, 16);
        r->hasBreakpoint = true;
    }
    r->watchLog = opts->watchLog;
    r->outputPath = opts->outputPath;
    r->dumpInterval = atol(opts->dumpInterval);
    r->traceEnabled = opts->trace;
    r->verbose = opts->verbose;
    r->interactive = opts->interactive;

    ageharness_init(&r->age);
    r->age.halUCP.verbose = r->verbose;
    r->age.halUCP.cbCtx = NULL;
    r->age.halUCP.errorCallback = halucp_error_cb;

    iohost_init_from_opts(&r->iohost, &r->age.halUCP, opts);
}

void batchrunner_free(BatchRunner *r) {
    for (size_t i = 0; i < r->lineCount; i++) free(r->lines[i]);
    free(r->lines);
    iohost_free(&r->iohost);
    ageharness_free(&r->age);
    memset(r, 0, sizeof(*r));
}

static void batchrunner_write(BatchRunner *r, const char *s) {
    if (r->outputPath) {
        if (r->lineCount >= r->lineCap) {
            r->lineCap = r->lineCap ? r->lineCap * 2 : 64;
            r->lines = realloc(r->lines, r->lineCap * sizeof(char *));
        }
        r->lines[r->lineCount++] = yagpc_strdup(s);
    } else {
        fputs(s, stdout);
        fputc('\n', stdout);
    }
}

static void batchrunner_info(BatchRunner *r, const char *s) {
    if (r->verbose) batchrunner_write(r, s);
}

static void batchrunner_flush(BatchRunner *r) {
    if (r->outputPath && r->lineCount > 0) {
        FILE *f = fopen(r->outputPath, "wb");
        if (f) {
            for (size_t i = 0; i < r->lineCount; i++) {
                fputs(r->lines[i], f);
                fputc('\n', f);
            }
            fclose(f);
        }
    }
    iohost_close(&r->iohost);
}

static void batchrunner_fatal(BatchRunner *r, const char *msg) {
    fprintf(stderr, "FATAL: %s\n", msg);
    batchrunner_flush(r);
    exit(1);
}

static void reg_dump_lines(BatchRunner *r, long step, char lines[TRACE_REGDUMP_LINES][200]) {
    trace_format_reg_dump(&r->age.gpc.cpu, (int)step, &TRACE_COLOR_PLAIN, lines, sizeof(lines[0]));
}

static void write_reg_dump(BatchRunner *r, long step) {
    char lines[TRACE_REGDUMP_LINES][200];
    reg_dump_lines(r, step, lines);
    for (int i = 0; i < TRACE_REGDUMP_LINES; i++) batchrunner_write(r, lines[i]);
}

static void info_reg_dump(BatchRunner *r, long step) {
    char lines[TRACE_REGDUMP_LINES][200];
    reg_dump_lines(r, step, lines);
    for (int i = 0; i < TRACE_REGDUMP_LINES; i++) batchrunner_info(r, lines[i]);
}

/* Ported from BatchRunner#formatSectionOffset — deliberately different
 * from symtable_format_csect (uppercases the section name, 4 hex digits
 * for the offset not 5, "" when no symbols loaded at all vs a blank
 * placeholder) — see run.h's header comment. */
static void format_section_offset(BatchRunner *r, uint32_t addr, char *out, size_t outSize) {
    if (!r->age.sym.loaded) {
        out[0] = '\0';
        return;
    }
    const char *sect = symtable_get_section_at(&r->age.sym, addr);
    if (sect) {
        for (int i = 0; i < r->age.sym.sectionCount; i++) {
            if (strcmp(r->age.sym.sections[i].name, sect) == 0) {
                uint32_t offset = addr - r->age.sym.sections[i].address;
                char nameUpper[9];
                int n = 0;
                for (const char *p = sect; *p && n < 8; p++, n++) nameUpper[n] = (char)toupper((unsigned char)*p);
                nameUpper[n] = '\0';
                char padded[9];
                str_rpad(padded, sizeof padded, nameUpper, " ", 8);
                char hex[16];
                as_hex(hex, sizeof hex, (long long)offset, 4);
                snprintf(out, outSize, "%s+%s", padded, hex);
                return;
            }
        }
    }
    snprintf(out, outSize, "        +    ");
}

static void batchrunner_format_trace_line(BatchRunner *r, long step, uint32_t nia, uint32_t hw1, uint32_t hw2,
                                           const char *disasm, int instrLen, const RegChange *changes, int changeCount,
                                           char *out, size_t outSize) {
    char stepNum[32];
    snprintf(stepNum, sizeof stepNum, "%ld", step);
    char stepStr[32];
    str_lpad(stepStr, sizeof stepStr, stepNum, " ", 5);

    char niaStr[16];
    as_hex(niaStr, sizeof niaStr, (long long)nia, 6);

    char sectOffsetStr[80];
    sectOffsetStr[0] = '\0';
    if (r->age.sym.loaded) {
        char off[64];
        format_section_offset(r, nia, off, sizeof off);
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

    char changesStr[2048];
    changesStr[0] = '\0';
    if (changeCount > 0) {
        size_t pos = 0;
        for (int i = 0; i < changeCount; i++) {
            char oldStr[16], newStr[16];
            trace_format_reg_val(oldStr, sizeof oldStr, changes[i].name, changes[i].oldVal);
            trace_format_reg_val(newStr, sizeof newStr, changes[i].name, changes[i].newVal);
            int n;
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

    snprintf(out, outSize, "[%s] %s%s: %s %s  %s%s", stepStr, niaStr, sectOffsetStr, hw1Str, hw2Str, disasmPadded, changesStr);
}

static long batchrunner_load(BatchRunner *r) {
    ConfigureResult res;
    ageharness_configure_from_opts(&r->age, r->opts->fcmPath, r->opts, &res);
    if (!res.hasEntryPoint) {
        batchrunner_fatal(r, "No entry point: use --start=ADDR or provide a symbols file with a START symbol");
    }
    r->entryPoint = res.entryPoint;
    if (r->age.sym.loaded) {
        char msg[512];
        snprintf(msg, sizeof msg, "Symbols: %s (%d symbols, %d sections)",
                 r->age.lastSymbolsPath ? r->age.lastSymbolsPath : "", r->age.sym.symbolCount, r->age.sym.sectionCount);
        batchrunner_info(r, msg);
    }
    return res.byteCount;
}

/* channel==-1 -> "no channel" (used before HalUCP ever emits real
 * output); useRawStdout(6) always true regardless of @interactive per
 * `(not @interactive) or ch == '6'`. */
static bool use_raw_stdout(BatchRunner *r, int channel) {
    return (!r->interactive) || channel == 6;
}

static void batchrunner_handle_output(void *ctx, const char *text, int channel) {
    BatchRunner *r = ctx;
    if (channel >= 0 && channel < IOHOST_MAX_CHANNEL && r->iohost.outStreams[channel]) {
        fputs(text, r->iohost.outStreams[channel]);
        return;
    }
    if (use_raw_stdout(r, channel)) {
        fputs(text, stdout);
    } else {
        printf("OUTPUT(%d): %s\n", channel, text);
    }
}

static void batchrunner_init_io(BatchRunner *r) {
    iohost_init(&r->iohost, r->age.sym.loaded ? &r->age.sym : NULL);
    /* IOHost#init already wired halUCP.outputCallback to its own
     * handleOutput (file-write only); BatchRunner overrides it with the
     * combined (file XOR stdout) behavior — see run.h's header comment. */
    r->age.halUCP.cbCtx = r;
    r->age.halUCP.outputCallback = batchrunner_handle_output;
}

static const char *batchrunner_read_input_line(BatchRunner *r, int channel, int iocode) {
    if (!iohost_has_file_configured(&r->iohost, channel)) {
        char msg[256];
        snprintf(msg, sizeof msg, "Program requests input on channel %d (%s) but no --infile%d was provided",
                 channel, halucp_iocode_type_name(iocode), channel);
        batchrunner_fatal(r, msg);
    }
    return iohost_read_input_line(&r->iohost, channel);
}

static void batchrunner_input_cb(void *ctx, int channel, int iocode) {
    BatchRunner *r = ctx;
    const char *line = batchrunner_read_input_line(r, channel, iocode);
    if (line) {
        halucp_provide_input(&r->age.halUCP, line);
    } else {
        halucp_provide_eof(&r->age.halUCP);
    }
}

static void print_section_map(BatchRunner *r) {
    if (!r->age.sym.loaded) return;
    batchrunner_info(r, "=== SECTION MAP ===");
    for (int i = 0; i < r->age.sym.sectionCount; i++) {
        const Section *s = &r->age.sym.sections[i];
        char lo[16], hi[16], nameP[16], msg[256];
        as_hex(lo, sizeof lo, (long long)s->address, 4);
        as_hex(hi, sizeof hi, (long long)(s->address + s->size - 1), 4);
        str_rpad(nameP, sizeof nameP, s->name, " ", 12);
        snprintf(msg, sizeof msg, "  0x%s - 0x%s  %s (%s)", lo, hi, nameP, s->module ? s->module : "");
        batchrunner_info(r, msg);
    }
    char startHex[16], off[64], msg[256];
    as_hex(startHex, sizeof startHex, (long long)r->entryPoint, 4);
    format_section_offset(r, r->entryPoint, off, sizeof off);
    snprintf(msg, sizeof msg, "  Start: 0x%s (%s)", startHex, off);
    batchrunner_info(r, msg);
    batchrunner_info(r, "");
}

typedef struct {
    uint32_t *addrs;
    int count;
} WatchAddrs;

static WatchAddrs build_watch_addrs(const Options *opts) {
    WatchAddrs wa = {NULL, 0};
    if (opts->watchCount == 0) return wa;
    int cap = 16;
    wa.addrs = malloc((size_t)cap * sizeof(uint32_t));
    for (size_t i = 0; i < opts->watchCount; i++) {
        for (long c = 0; c < opts->watch[i].count; c++) {
            if (wa.count >= cap) {
                cap *= 2;
                wa.addrs = realloc(wa.addrs, (size_t)cap * sizeof(uint32_t));
            }
            wa.addrs[wa.count++] = (uint32_t)(opts->watch[i].addr + c);
        }
    }
    return wa;
}

static void format_watchpoint_msg(BatchRunner *r, uint32_t addr, uint16_t before, uint16_t after16,
                                   const char *disasm, uint32_t nia, long step, const RegSnapshot *after,
                                   char *out, size_t outSize) {
    char addrHex[16], beforeHex[16], afterHex[16], niaHex[16];
    as_hex(addrHex, sizeof addrHex, (long long)addr, 5);
    as_hex(beforeHex, sizeof beforeHex, (long long)before, 4);
    as_hex(afterHex, sizeof afterHex, (long long)after16, 4);
    as_hex(niaHex, sizeof niaHex, (long long)nia, 5);
    const char *section = symtable_get_section_at(&r->age.sym, nia);
    char sectionPart[80];
    if (section) snprintf(sectionPart, sizeof sectionPart, " (%s)", section);
    else sectionPart[0] = '\0';
    char r0h[16], r1h[16], r3h[16], r5h[16], r7h[16];
    as_hex(r0h, sizeof r0h, (long long)after->r[0], 8);
    as_hex(r1h, sizeof r1h, (long long)after->r[1], 8);
    as_hex(r3h, sizeof r3h, (long long)after->r[3], 8);
    as_hex(r5h, sizeof r5h, (long long)after->r[5], 8);
    as_hex(r7h, sizeof r7h, (long long)after->r[7], 8);
    snprintf(out, outSize,
             "memory watchpoint: HW 0x%s changed 0x%s -> 0x%s by %s at NIA=0x%s step=%ld%s R0=%s R1=%s R3=%s R5=%s R7=%s",
             addrHex, beforeHex, afterHex, disasm, niaHex, step, sectionPart, r0h, r1h, r3h, r5h, r7h);
}

int batchrunner_run(BatchRunner *r) {
    long byteCount = batchrunner_load(r);
    batchrunner_init_io(r);

    r->age.halUCP.cbCtx = r;
    r->age.halUCP.inputCallback = batchrunner_input_cb;

    char msg[700];
    batchrunner_info(r, "=== GPC Batch Simulator ===");
    snprintf(msg, sizeof msg, "FCM: %s (%ld bytes)", r->opts->fcmPath, byteCount);
    batchrunner_info(r, msg);
    char epHex[16];
    as_hex(epHex, sizeof epHex, (long long)r->entryPoint, 4);
    snprintf(msg, sizeof msg, "Entry: 0x%s", epHex);
    batchrunner_info(r, msg);
    snprintf(msg, sizeof msg, "Max steps: %ld", r->maxSteps);
    batchrunner_info(r, msg);
    snprintf(msg, sizeof msg, "Trace: %s", r->traceEnabled ? "on" : "off");
    batchrunner_info(r, msg);
    if (r->hasBreakpoint) {
        char bpHex[16];
        as_hex(bpHex, sizeof bpHex, (long long)r->breakpoint, 4);
        snprintf(msg, sizeof msg, "Breakpoint: 0x%s", bpHex);
        batchrunner_info(r, msg);
    }
    batchrunner_info(r, "");

    print_section_map(r);

    long step = 0;
    bool hasStopReason = false;
    char stopReason[600] = "";
    bool hasLastSection = false;
    char lastSection[256] = "";

    WatchAddrs watchAddrs = build_watch_addrs(r->opts);
    bool hasWatchpoints = watchAddrs.count > 0;
    uint16_t *watchBefore = hasWatchpoints ? malloc((size_t)watchAddrs.count * sizeof(uint16_t)) : NULL;

    while (step < r->maxSteps) {
        RegSnapshot before, after;
        ageharness_snapshot_regs(&r->age, &before);
        uint32_t nia = psw_get_nia(&r->age.gpc.cpu.psw);

        if (r->traceEnabled && r->age.sym.loaded) {
            const char *currentSection = symtable_get_section_at(&r->age.sym, nia);
            if (currentSection && (!hasLastSection || strcmp(currentSection, lastSection) != 0)) {
                char line[300];
                snprintf(line, sizeof line, "--- ENTERING: %s ---", currentSection);
                batchrunner_write(r, line);
                hasLastSection = true;
                snprintf(lastSection, sizeof lastSection, "%s", currentSection);
            }
        }

        if (r->hasBreakpoint && nia == r->breakpoint) {
            char bpHex[16];
            as_hex(bpHex, sizeof bpHex, (long long)nia, 4);
            snprintf(stopReason, sizeof stopReason, "breakpoint at 0x%s", bpHex);
            hasStopReason = true;
            break;
        }

        uint32_t hw1 = mcm_get16(&r->age.gpc.cpu.mainStorage, nia);
        uint32_t hw2 = mcm_get16(&r->age.gpc.cpu.mainStorage, nia + 1);

        char disasm[256];
        instr_to_str(hw1, hw2, disasm, sizeof disasm);
        DInstr v;
        const InstrDesc *d = instr_decode(hw1, hw2, &v);
        int instrLen = d ? d->pb.origLen : 1;

        if (!d) {
            if (r->traceEnabled) {
                char line[400];
                batchrunner_format_trace_line(r, step, nia, hw1, hw2, "??? (invalid)", 1, NULL, 0, line, sizeof line);
                batchrunner_write(r, line);
            }
            char hexv[16];
            as_hex(hexv, sizeof hexv, (long long)hw1, 4);
            char niaHex[16];
            as_hex(niaHex, sizeof niaHex, (long long)nia, 4);
            snprintf(stopReason, sizeof stopReason, "invalid instruction 0x%s at 0x%s", hexv, niaHex);
            hasStopReason = true;
            break;
        }

        if (hasWatchpoints) {
            for (int i = 0; i < watchAddrs.count; i++) {
                watchBefore[i] = (uint16_t)mcm_get16(&r->age.gpc.cpu.mainStorage, watchAddrs.addrs[i]);
            }
        }

        if (r->age.halUCP.active && halucp_is_trap_addr(&r->age.halUCP, nia)) {
            halucp_check_trap(&r->age.halUCP, nia);
        }

        ap101_exec1(&r->age.gpc);

        ageharness_snapshot_regs(&r->age, &after);
        RegChange changes[REG_SNAPSHOT_MAX_CHANGES];
        int changeCount = ageharness_diff_regs(&before, &after, changes);
        int filteredCount = 0;
        RegChange filtered[REG_SNAPSHOT_MAX_CHANGES];
        for (int i = 0; i < changeCount; i++) {
            if (strcmp(changes[i].name, "NIA") != 0) filtered[filteredCount++] = changes[i];
        }

        if (r->traceEnabled) {
            char line[2400];
            batchrunner_format_trace_line(r, step, nia, hw1, hw2, disasm, instrLen, filtered, filteredCount, line, sizeof line);
            batchrunner_write(r, line);
        }

        step++;

        if (r->traceEnabled && r->dumpInterval > 0 && step % r->dumpInterval == 0) {
            write_reg_dump(r, step);
            batchrunner_write(r, "");
        }

        if (hasWatchpoints) {
            for (int i = 0; i < watchAddrs.count; i++) {
                uint16_t newVal = (uint16_t)mcm_get16(&r->age.gpc.cpu.mainStorage, watchAddrs.addrs[i]);
                if (newVal != watchBefore[i]) {
                    char wmsg[512];
                    format_watchpoint_msg(r, watchAddrs.addrs[i], watchBefore[i], newVal, disasm, nia, step, &after, wmsg, sizeof wmsg);
                    if (r->watchLog) {
                        fprintf(stderr, "%s\n", wmsg);
                        watchBefore[i] = newVal;
                    } else {
                        snprintf(stopReason, sizeof stopReason, "%s", wmsg);
                        hasStopReason = true;
                        break;
                    }
                }
            }
            if (hasStopReason) break;
        }

        if (psw_get_wait_state(&r->age.gpc.cpu.psw)) {
            snprintf(stopReason, sizeof stopReason, "wait state");
            hasStopReason = true;
            break;
        }
    }

    free(watchBefore);
    free(watchAddrs.addrs);

    if (!hasStopReason) {
        snprintf(stopReason, sizeof stopReason, "max steps reached (%ld)", r->maxSteps);
    }

    snprintf(msg, sizeof msg, "--- STOPPED after %ld steps (reason: %s) ---", step, stopReason);
    batchrunner_info(r, msg);
    batchrunner_info(r, "--- FINAL REGISTERS ---");
    info_reg_dump(r, step);

    batchrunner_flush(r);

    if (strcmp(stopReason, "wait state") != 0) {
        fprintf(stderr, "ERROR: %s\n", stopReason);
        return 1;
    }
    return 0;
}

/* ---------------------------------------------------------------------
 * runInteractive() / execLoop() / promptInput()
 *
 * Restructured from JS's async readline-callback + event-loop-reentry
 * style into a single synchronous loop: when HalUCP needs input, this
 * port just blocks on a stdin read right there instead of returning out
 * of the loop and waiting to be re-entered from a callback — there's
 * nothing else that could run "in between" in a single-threaded CLI tool
 * either way, so the observable behavior (prompts, output ordering,
 * final state) is the same. See run.h's header comment.
 * ------------------------------------------------------------------- */

static volatile sig_atomic_t g_sigint_received = 0;

static void on_sigint(int sig) {
    (void)sig;
    g_sigint_received = 1;
}

static void interactive_report_and_exit(BatchRunner *r, const char *headerFmt, long step, int exitCode) {
    char msg[128];
    snprintf(msg, sizeof msg, headerFmt, step);
    batchrunner_info(r, msg);
    batchrunner_info(r, "--- FINAL REGISTERS ---");
    info_reg_dump(r, step);
    batchrunner_flush(r);
    exit(exitCode);
}

/* Prompts on stdout (matching promptInput's column-6 newline + " INPUT(ch): "
 * / "" prompt logic) and blocks for one line of stdin input. */
static void prompt_and_provide_input(BatchRunner *r, int channel) {
    if (r->age.halUCP.column[6] > 1) {
        fputs("\n", stdout);
    }
    if (channel != 5) {
        printf(" INPUT(%d): ", channel);
    }
    fflush(stdout);

    char line[4096];
    if (!fgets(line, sizeof line, stdin)) {
        if (g_sigint_received) {
            interactive_report_and_exit(r, "\n--- INTERRUPTED after %ld steps ---", r->step, 0);
        }
        halucp_provide_eof(&r->age.halUCP);
        return;
    }
    size_t len = strlen(line);
    while (len > 0 && (line[len - 1] == '\n' || line[len - 1] == '\r')) line[--len] = '\0';
    halucp_provide_input(&r->age.halUCP, line);
    halucp_notify_interactive_input(&r->age.halUCP, 6);
}

/* Deliberate divergence from the JS reference (gpc/cmd_run.coffee's
 * inputCallback in runInteractive): iohost_has_file_input() (like JS's
 * IOHost#hasFileInput) is true only while unread lines remain, so once
 * a --infileN channel's lines run out this falls into the terminal-
 * prompt branch below exactly as the JS does. In the JS, that branch
 * (promptInput -> readline's rl.question()) never resolves on real EOF
 * — its callback only fires on a 'line' event, so an exhausted/closed
 * stdin just stalls forever with nothing keeping Node's event loop
 * alive, and the process silently exits 0 without ever reaching
 * HalUCP#provideEof() or the program's ON ERROR handler. Confirmed
 * against the live reference with a real HALSFC/lnk101-compiled
 * READ-until-EOF program (the classic HAL/S idiom from "Programming in
 * HAL/S" p.193): gpc run --interactive truncates it silently; this
 * port's prompt_and_provide_input() below uses a blocking fgets(),
 * which correctly returns EOF and calls halucp_provide_eof() here,
 * completing the program as intended. Kept as the correct behavior
 * rather than replicated bug-for-bug — see yaGPC port session notes. */
static void interactive_input_cb(void *ctx, int channel, int iocode) {
    BatchRunner *r = ctx;
    (void)iocode;
    if (iohost_has_file_input(&r->iohost, channel)) {
        const char *line = iohost_read_input_line(&r->iohost, channel);
        if (line) {
            halucp_provide_input(&r->age.halUCP, line);
        } else {
            halucp_provide_eof(&r->age.halUCP);
        }
    } else {
        prompt_and_provide_input(r, channel);
    }
}

int batchrunner_run_interactive(BatchRunner *r) {
    long byteCount = batchrunner_load(r);
    batchrunner_init_io(r);

    r->age.halUCP.cbCtx = r;
    r->age.halUCP.inputCallback = interactive_input_cb;

    char msg[700];
    batchrunner_info(r, "=== GPC Interactive Simulator ===");
    snprintf(msg, sizeof msg, "FCM: %s (%ld bytes)", r->opts->fcmPath, byteCount);
    batchrunner_info(r, msg);
    char epHex[16];
    as_hex(epHex, sizeof epHex, (long long)r->entryPoint, 4);
    snprintf(msg, sizeof msg, "Entry: 0x%s", epHex);
    batchrunner_info(r, msg);
    snprintf(msg, sizeof msg, "Trace: %s", r->traceEnabled ? "on" : "off");
    batchrunner_info(r, msg);
    batchrunner_info(r, "(Ctrl-C to halt)");
    batchrunner_info(r, "");

    print_section_map(r);

    r->step = 0;
    r->hasStopReason = false;
    r->stopReason[0] = '\0';
    r->hasLastSection = false;
    r->lastSection[0] = '\0';

    signal(SIGINT, on_sigint);

    while (r->step < r->maxSteps) {
        if (g_sigint_received) {
            interactive_report_and_exit(r, "\n--- INTERRUPTED after %ld steps ---", r->step, 0);
        }

        RegSnapshot before, after;
        ageharness_snapshot_regs(&r->age, &before);
        uint32_t nia = psw_get_nia(&r->age.gpc.cpu.psw);

        if (r->traceEnabled && r->age.sym.loaded) {
            const char *currentSection = symtable_get_section_at(&r->age.sym, nia);
            if (currentSection && (!r->hasLastSection || strcmp(currentSection, r->lastSection) != 0)) {
                char line[300];
                snprintf(line, sizeof line, "--- ENTERING: %s ---", currentSection);
                batchrunner_write(r, line);
                r->hasLastSection = true;
                snprintf(r->lastSection, sizeof r->lastSection, "%s", currentSection);
            }
        }

        if (r->hasBreakpoint && nia == r->breakpoint) {
            char bpHex[16];
            as_hex(bpHex, sizeof bpHex, (long long)nia, 4);
            snprintf(r->stopReason, sizeof r->stopReason, "breakpoint at 0x%s", bpHex);
            r->hasStopReason = true;
            break;
        }

        uint32_t hw1 = mcm_get16(&r->age.gpc.cpu.mainStorage, nia);
        uint32_t hw2 = mcm_get16(&r->age.gpc.cpu.mainStorage, nia + 1);

        char disasm[256];
        instr_to_str(hw1, hw2, disasm, sizeof disasm);
        DInstr v;
        const InstrDesc *d = instr_decode(hw1, hw2, &v);
        int instrLen = d ? d->pb.origLen : 1;

        if (!d) {
            if (r->traceEnabled) {
                char line[400];
                batchrunner_format_trace_line(r, r->step, nia, hw1, hw2, "??? (invalid)", 1, NULL, 0, line, sizeof line);
                batchrunner_write(r, line);
            }
            char hexv[16], niaHex[16];
            as_hex(hexv, sizeof hexv, (long long)hw1, 4);
            as_hex(niaHex, sizeof niaHex, (long long)nia, 4);
            snprintf(r->stopReason, sizeof r->stopReason, "invalid instruction 0x%s at 0x%s", hexv, niaHex);
            r->hasStopReason = true;
            break;
        }

        if (r->age.halUCP.active && halucp_is_trap_addr(&r->age.halUCP, nia)) {
            halucp_check_trap(&r->age.halUCP, nia); /* may synchronously block on stdin via interactive_input_cb */
        }

        ap101_exec1(&r->age.gpc);

        ageharness_snapshot_regs(&r->age, &after);
        RegChange changes[REG_SNAPSHOT_MAX_CHANGES];
        int changeCount = ageharness_diff_regs(&before, &after, changes);
        int filteredCount = 0;
        RegChange filtered[REG_SNAPSHOT_MAX_CHANGES];
        for (int i = 0; i < changeCount; i++) {
            if (strcmp(changes[i].name, "NIA") != 0) filtered[filteredCount++] = changes[i];
        }

        if (r->traceEnabled) {
            char line[2400];
            batchrunner_format_trace_line(r, r->step, nia, hw1, hw2, disasm, instrLen, filtered, filteredCount, line, sizeof line);
            batchrunner_write(r, line);
        }

        r->step++;

        if (r->traceEnabled && r->dumpInterval > 0 && r->step % r->dumpInterval == 0) {
            write_reg_dump(r, r->step);
            batchrunner_write(r, "");
        }

        if (psw_get_wait_state(&r->age.gpc.cpu.psw)) {
            snprintf(r->stopReason, sizeof r->stopReason, "wait state");
            r->hasStopReason = true;
            break;
        }
    }

    if (!r->hasStopReason && r->step >= r->maxSteps) {
        snprintf(r->stopReason, sizeof r->stopReason, "max steps reached (%ld)", r->maxSteps);
        r->hasStopReason = true;
    }

    if (r->hasStopReason) {
        snprintf(msg, sizeof msg, "--- STOPPED after %ld steps (reason: %s) ---", r->step, r->stopReason);
        batchrunner_info(r, msg);
        batchrunner_info(r, "--- FINAL REGISTERS ---");
        info_reg_dump(r, r->step);
        batchrunner_flush(r);
        int exitCode = strcmp(r->stopReason, "wait state") == 0 ? 0 : 1;
        if (exitCode != 0) {
            fprintf(stderr, "ERROR: %s\n", r->stopReason);
        }
        return exitCode;
    }
    return 0;
}
