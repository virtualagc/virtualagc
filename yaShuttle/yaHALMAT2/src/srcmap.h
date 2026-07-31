#ifndef HALMAT_SRCMAP_H
#define HALMAT_SRCMAP_H

#include <stdbool.h>
#include <stddef.h>

/* One physical card-image line from HALSFC's PASS1 report (pass1.rpt),
 * for --debug's source-line display. A single HAL/S statement can span
 * several of these (continuation lines all share the same `stmt`). */
typedef struct {
    long stmt; /* parsed from the line's own STMT field, for lookup only */
    char *text; /* the ENTIRE raw report line, verbatim -- STMT field,
                  * column-1 continuation marker, both bars, the full
                  * 101-character source-text field (trailing blanks
                  * intact), and the trailing revision/scope field. Only
                  * the line terminator itself is stripped. Not a
                  * reconstructed subset -- print as-is. */
} halmat_srcmap_line_t;

typedef struct {
    halmat_srcmap_line_t *lines;
    size_t count;
} halmat_srcmap_t;

/* Parses pass1.rpt's fixed-column "STMT ... SOURCE ... REVISION" report
 * lines (format: 4-char right-justified statement number, 1 space, 1
 * column-1 marker char, '|', 101 source-text characters covering HAL/S
 * source columns 2-102, '|', revision field). Confirmed empirically
 * against real HALSFC output. Non-matching lines (page headers, blank
 * lines, the '+'-pointer annotation lines HALSFC emits under statements
 * with diagnostics, whose statement-number field is blank) are skipped.
 * Also handles the OTHER real pass1.rpt layout, used whenever HALSFC is
 * invoked with `SRN` in --parms: every line above gets a 6-digit Source
 * Reference Number plus one separator space prepended, shifting every
 * column that follows by a constant 7 bytes -- auto-detected per file
 * (see srcmap.c's own SRCMAP_SRN_PREFIX_WIDTH comment), no caller-side
 * flag needed. */
bool halmat_srcmap_load(const char *path, halmat_srcmap_t *out, char *errbuf, size_t errbuf_size);
void halmat_srcmap_free(halmat_srcmap_t *map);

/* Finds the first source line for HAL/S statement `stmt`, and sets
 * *out_count to how many consecutive lines (continuation cards) belong
 * to it. Returns NULL if `stmt` has no source lines. */
const halmat_srcmap_line_t *halmat_srcmap_find(const halmat_srcmap_t *map, long stmt, size_t *out_count);

#endif
