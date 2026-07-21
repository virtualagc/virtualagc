#ifndef HALMAT_H
#define HALMAT_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

/* HALMAT binary word format (reengineered-documentation/HALMAT.md):
 * a stream of 32-bit words in fixed 7200-byte (1800-word) records.
 * The word's least-significant bit distinguishes the two word kinds:
 *   operator word (bit0=0): TAG(8)|NUMOP(8)|CLASS(4)|OPCODE(8)|COPT(3)|0(1)
 *   operand  word (bit0=1): DATA(16)|TAG1(8)|QUAL(4)|TAG2(3)|1(1)
 * "opcode" below is always the combined 12-bit CLASS:OPCODE field. */

#define HALMAT_RECORD_BYTES 7200
#define HALMAT_RECORD_WORDS 1800

/* QUAL field values (primary-source-confirmed against ##DRIVER.xpl's own
 * XPL/I constants; see reengineered-documentation/HALMAT.md). */
typedef enum {
    QUAL_EMPTY = 0,
    QUAL_SYT = 1,
    QUAL_INL = 2,
    QUAL_VAC = 3,
    QUAL_XPT = 4,
    QUAL_LIT = 5,
    QUAL_IMD = 6,
    QUAL_AST = 7,
    QUAL_CSZ = 8,
    QUAL_ASZ = 9,
    QUAL_OFF = 10,
} halmat_qual_t;

const char *halmat_qual_name(uint8_t qual);

typedef struct {
    uint16_t data;
    uint8_t tag1;
    uint8_t qual;
    uint8_t tag2;
} halmat_operand_t;

/* WRIT-style variadic argument lists (see XXST/XXAR/XXND) are expressed as
 * separate instructions in the stream, not as one instruction with many
 * operand words -- NUMOP has never been observed above single digits in
 * the fixtures read so far. Generous fixed cap; loader errors out loudly
 * if a real file ever exceeds it, rather than silently truncating. */
#define HALMAT_MAX_OPERANDS 16

typedef struct {
    size_t index; /* word index within the whole loaded stream, 0-based */
    uint8_t tag;
    uint8_t numop;
    uint16_t opcode; /* combined 12-bit class:opcode */
    uint8_t copt;
    uint8_t operand_count;
    halmat_operand_t operands[HALMAT_MAX_OPERANDS];
} halmat_instr_t;

typedef struct {
    halmat_instr_t *instrs;
    size_t count;
} halmat_program_t;

/* Loads a raw HALMAT binary (halmat.bin/optmat.bin-style file) from path.
 * Returns true on success and fills *out; on failure returns false and
 * writes a human-readable message to errbuf. */
bool halmat_load(const char *path, halmat_program_t *out, char *errbuf, size_t errbuf_size);
void halmat_program_free(halmat_program_t *prog);

#endif
