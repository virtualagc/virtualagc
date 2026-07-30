/* HAL/S source-line lookup for yaGPC2's --debug mode (Stage 3), loaded
 * from a JSON file produced by tools/gen_source_map.py -- see that
 * script's own header comment for why this reads pass1.rpt/pass2.rpt
 * text reports rather than the SDF binary format debugger-planner.md
 * originally targeted (SDF's own per-statement SRN field turned out to
 * be the wrong thing to key off of, not just unavailable in test data).
 * Deliberately isolated from the rest of the debugger (a single opaque
 * type plus a lookup call) the same way Debugger itself is kept isolated
 * from AGEHarness. */
#ifndef YAGPC_SOURCEMAP_H
#define YAGPC_SOURCEMAP_H

#include <stdint.h>

typedef struct SourceMap SourceMap;

/* Returns NULL on any load/parse failure (prints a diagnostic to
 * stderr) -- never fatal, since source-line display is a debugger
 * nicety, not a hard requirement. */
SourceMap *sourcemap_load(const char *jsonPath);
void sourcemap_free(SourceMap *sm);

/* Returns the number of physical pass1.rpt listing lines for whichever
 * HAL/S statement is "active" at addr (the mapped statement whose
 * start address is <= addr and closest to it), or 0 if addr is before
 * every mapped statement. *stmtOut receives the HAL/S statement number
 * (its 1-based position in the SDF's statementIndexTable, matching
 * pass1.rpt's leftmost column -- *not* the SDF's own SRN field, a
 * different and less reliable identifier) and *linesOut the statement's
 * own lines (owned by sm, valid until sourcemap_free(), each already
 * trimmed of pass1.rpt's own fixed-column padding and trailing scope
 * field but otherwise exactly as that line appeared in pass1.rpt) when
 * both are non-NULL and a mapping is found. A statement can span more
 * than one such line (e.g. a label and the statement it labels sharing
 * one statement number but printed as separate pass1.rpt lines even
 * when they came from the same source line) -- callers should print
 * each line on its own, rather than collapsing them into one, to match
 * pass1.rpt's own layout instead of an artificially shortened summary. */
int sourcemap_lookup(const SourceMap *sm, uint32_t addr, int *stmtOut, const char *const **linesOut);

#endif
