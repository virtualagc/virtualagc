#ifndef HALMAT_SRCMAP_H
#define HALMAT_SRCMAP_H

#include <stdbool.h>
#include <stddef.h>

/* One physical card-image line from HALSFC's PASS1 report (pass1.rpt),
 * for --debug's source-line display. A single HAL/S statement can span
 * several of these (continuation lines all share the same `stmt`). */
typedef struct {
    long stmt;
    char *text; /* reconstructed source text: column 1 (the compiler's
                  * continuation marker -- 'M' for a normal/main line,
                  * rendered as a space since it's not real source text)
                  * followed by columns 2-102, trailing blanks trimmed. */
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
 * with diagnostics, whose statement-number field is blank) are skipped. */
bool halmat_srcmap_load(const char *path, halmat_srcmap_t *out, char *errbuf, size_t errbuf_size);
void halmat_srcmap_free(halmat_srcmap_t *map);

/* Finds the first source line for HAL/S statement `stmt`, and sets
 * *out_count to how many consecutive lines (continuation cards) belong
 * to it. Returns NULL if `stmt` has no source lines. */
const halmat_srcmap_line_t *halmat_srcmap_find(const halmat_srcmap_t *map, long stmt, size_t *out_count);

#endif
