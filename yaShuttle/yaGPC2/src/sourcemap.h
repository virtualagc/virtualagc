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

/* Returns the HAL/S source text for whichever statement is "active" at
 * addr (the mapped statement whose start address is <= addr and
 * closest to it), or NULL if addr is before every mapped statement.
 * *stmtOut receives the HAL/S statement number (its 1-based position in
 * the SDF's statementIndexTable, matching pass1.rpt's leftmost column --
 * *not* the SDF's own SRN field, a different and less reliable
 * identifier) when non-NULL and a mapping is found. */
const char *sourcemap_lookup(const SourceMap *sm, uint32_t addr, int *stmtOut);

#endif
