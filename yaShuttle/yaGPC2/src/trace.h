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
} TraceLineOpts;

/* Writes one formatted trace line (no trailing newline) into out. */
void trace_format_line(char *out, size_t outSize, int step, uint32_t nia, uint32_t hw1, uint32_t hw2,
                        const char *disasm, int instrLen, const RegChange *changes, int changeCount,
                        const TraceLineOpts *opts);

#define TRACE_REGDUMP_LINES 6
/* Writes TRACE_REGDUMP_LINES formatted lines (no trailing newlines) into
 * lines[i], each up to lineSize bytes. */
void trace_format_reg_dump(CPU *cpu, int step, const TraceColors *color, char lines[TRACE_REGDUMP_LINES][200], size_t lineSize);

#endif
