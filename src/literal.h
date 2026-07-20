#ifndef HALMAT_LITERAL_H
#define HALMAT_LITERAL_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

/* Literal-file record layout (confirmed against unLitfile.py, the
 * reference decoder): 1560-byte records = 3x520-byte pages of 130
 * 4-byte cells (130 literals/record). Page 1 byte 3 of each cell is the
 * type; interpretation of the corresponding page-2/page-3 cells depends
 * on it. Types >2 (RLD/PASS2-only) are not needed for PASS1 halmat.bin
 * and are not decoded here yet. */
typedef enum {
    LIT_STRING = 0,
    LIT_FIXED = 1, /* IBM hex-float numeric; used for INTEGER/SCALAR literals alike */
    LIT_BIT = 2,
    LIT_DOUBLE = 5,
    LIT_OTHER = 255,
} halmat_lit_type_t;

typedef struct {
    halmat_lit_type_t type;
    char *string;       /* LIT_STRING: EBCDIC-decoded, NUL-terminated */
    double numeric;      /* LIT_FIXED/LIT_DOUBLE: decoded IBM hex-float value (for INTEGER-context use) */
    uint32_t msw, lsw;    /* LIT_FIXED/LIT_DOUBLE: raw IBM hex-float words (for SCALAR-context use, avoiding a lossy double round-trip -- see value.h) */
    uint32_t bits;        /* LIT_BIT: raw value */
} halmat_literal_t;

typedef struct {
    halmat_literal_t *entries;
    size_t count;
} halmat_literal_table_t;

/* memory may be NULL if no companion memory-image file is available;
 * LIT_STRING entries will then decode as empty strings rather than fail
 * (mirrors yaHALMAT's graceful degradation when --common isn't given). */
bool halmat_literal_load(const char *litfile_path, const char *memory_path,
                          halmat_literal_table_t *out, char *errbuf, size_t errbuf_size);
void halmat_literal_free(halmat_literal_table_t *table);

/* IBM System/360-style long (64-bit) hex-float decode: 1 sign bit + 7-bit
 * excess-64 characteristic + 56-bit (14 hex digit) fraction, split across
 * a most-significant word (sign+characteristic+high 24 fraction bits) and
 * least-significant word (low 32 fraction bits) -- confirmed against the
 * AP-101S Software Model PDF (Sec. 8) and unLitfile.py/halmat_float.c. */
double ibm_hex_float_to_double(uint32_t msw, uint32_t lsw);

#endif
