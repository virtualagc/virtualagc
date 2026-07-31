/* Trace/register-dump formatting, ported from gpc/trace.coffee. Shared by
 * batch (plain) and debug (ANSI color) CLI modes — `gpc run` always uses
 * the plain palette (TRACE_COLOR_PLAIN); TRACE_COLOR_ANSI is ported for
 * completeness/parity but not expected to be reachable from `run`. */
#ifndef YAGPC_TRACE_H
#define YAGPC_TRACE_H

#include <stddef.h>
#include <stdint.h>

#include "ageharness.h"
#include "cpu.h"
#include "symboltable.h"

typedef struct {
    const char *reset, *bold, *dim, *red, *green, *yellow, *blue, *magenta, *cyan, *white, *bgRed;
} TraceColors;

extern const TraceColors TRACE_COLOR_ANSI;  /* C */
extern const TraceColors TRACE_COLOR_PLAIN; /* P — every field "" */

/* Number::asHex(8) for everything except CC/NIA (plain decimal). */
void trace_format_reg_val(char *out, size_t outSize, const char *name, uint32_t val);

typedef struct {
    const TraceColors *color; /* NULL -> TRACE_COLOR_PLAIN */
    const SymbolTable *sym;   /* NULL -> no section-offset field */
    int stepWidth;            /* 0 -> 6 */
    int niaWidth;              /* 0 -> 5 */
    const double *elapsedTimeUs; /* NULL -> omit; else prepends "T=%.2f "
                                   * before the NIA field, matching run.c's
                                   * own --debug display (see cpu.h's
                                   * elapsedTimeUs comment) */
} TraceLineOpts;

/* Writes one formatted trace line (no trailing newline) into out. */
void trace_format_line(char *out, size_t outSize, int step, uint32_t nia, uint32_t hw1, uint32_t hw2,
                        const char *disasm, int instrLen, const RegChange *changes, int changeCount,
                        const TraceLineOpts *opts);

#define TRACE_REGDUMP_LINES 6
/* Writes TRACE_REGDUMP_LINES formatted lines (no trailing newlines) into
 * lines[i], each up to lineSize bytes. */
void trace_format_reg_dump(CPU *cpu, int step, const TraceColors *color, char lines[TRACE_REGDUMP_LINES][200], size_t lineSize);

/* Formats `changes` as "NAME: OLD->NEW, NAME: OLD->NEW, ..." wrapped so
 * no line exceeds lineWidth columns (<=0 disables wrapping) -- wrapping
 * only ever happens between whole "NAME: OLD->NEW" entries, never
 * mid-entry, with continuation lines indented to align under the first
 * entry. `prefix` is everything the caller has already printed earlier
 * on this same line (used only to measure that indent); `out` receives
 * just the changes portion (no leading content, no trailing newline).
 * Shared by debugger.c's always-on stop summary, run.c's --debug
 * trace-line wrapping, and gpcops.c's embedded-engine htrace output. */
void trace_format_changes_wrapped(int lineWidth, const char *prefix, const RegChange *changes, int changeCount,
                                   char *out, size_t outSize);

/* Full trace-line composer: "[STEP] T=... NIA SECT+OFF: HW1 HW2  DISASM
 * CHANGES", byte-identical to what run.c's --trace/--debug output has
 * always printed -- the single implementation both run.c's CLI path
 * (batchrunner_format_trace_line(), now a thin wrapper) and gpcops.c's
 * embedded engine use, so they can't drift apart. sym/elapsedTimeUs are
 * both NULL-able (NULL -> that field omitted, matching "no symbols
 * loaded" / "not tracking elapsed time here" respectively); lineWidth
 * <=0 disables register-change wrapping (see
 * trace_format_changes_wrapped()). */
void trace_format_debug_line(char *out, size_t outSize, long step, uint32_t nia, uint32_t hw1, uint32_t hw2,
                              const char *disasm, int instrLen, const RegChange *changes, int changeCount,
                              const SymbolTable *sym, const double *elapsedTimeUs, int lineWidth);

#endif
