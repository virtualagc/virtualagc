#ifndef HALMAT_CONTAINER_H
#define HALMAT_CONTAINER_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "literal.h"

/* Self-contained, compressed "linked HALMAT" container file (built via
 * `yaHALMAT2 --link-only FILENAME @list`, then run directly as
 * `yaHALMAT2 FILENAME` with no @list directory tree needed) -- see
 * reengineered-documentation/MULTI-FILE-LINKING.md's container-format
 * section for the full motivation and byte layout this implements:
 *
 *   bytes 0-3:   magic "YHLA"
 *   byte  4:     format version (1)
 *   bytes 5-12:  u64 BE uncompressed payload length
 *   bytes 13-20: u64 BE compressed payload length
 *   bytes 21..:  zlib-deflated payload (that many bytes)
 *
 * Payload (after decompression), all integers big-endian:
 *   u16 num_units
 *   u16 primary_idx
 *   repeated num_units times, a unit record:
 *     u16 label_len ; label_len bytes           -- diagnostic-only label
 *     u32 halmat_len ; halmat_len bytes          -- verbatim halmat.bin/optmat.bin
 *     u8  have_lit
 *     if have_lit:
 *       u32 litfile_len ; litfile_len bytes         -- verbatim litfile*.bin
 *       u32 string_blob_len ; string_blob_len bytes -- (u32 len; bytes) per
 *                                                       LIT_STRING cell, in
 *                                                       entries[] order --
 *                                                       replaces the 16MB
 *                                                       memory image
 *     u8  have_sym
 *     if have_sym:
 *       u32 symtab_len ; symtab_len bytes           -- verbatim COMMON*.out text
 *
 * Deliberately does NOT embed the COMMONn.out.bin.gz memory image: only a
 * handful of bytes out of its fixed 16MB (HALMAT_MEM_IMAGE_MAX, see
 * literal.c) are ever actually read by halmat_literal_load() -- the
 * string_blob above stores exactly those already-EBCDIC-decoded
 * CHARACTER-literal strings instead. */

#define HALMAT_CONTAINER_MAX_UNITS 64

/* Writer-side API: takes raw bytes directly (decoupled from main.c's
 * private unit_t struct), so it has no dependency on how the caller
 * obtained them. */
typedef struct {
    const char *label;
    const uint8_t *halmat_bytes;
    size_t halmat_len;
    bool have_lit;
    const uint8_t *litfile_bytes;
    size_t litfile_len;
    const halmat_literal_table_t *literals; /* used only to build the string blob: walk ->entries[],
                                                for each entry with type==LIT_STRING emit
                                                (u32 BE strlen; bytes) from its already-decoded
                                                ->string field, in entries[] order */
    bool have_sym;
    const uint8_t *symtab_bytes;
    size_t symtab_len;
} halmat_container_unit_t;

bool halmat_container_write(const char *path, const halmat_container_unit_t *units, int num_units,
                             int primary_idx, char *errbuf, size_t errbuf_size);

/* Reader-side API. */
typedef struct {
    char label[128];
    uint8_t *halmat_bytes;
    size_t halmat_len;
    bool have_lit;
    uint8_t *litfile_bytes;
    size_t litfile_len;
    uint8_t *string_blob;
    size_t string_blob_len;
    bool have_sym;
    uint8_t *symtab_bytes;
    size_t symtab_len;
} halmat_container_unit_view_t;

typedef struct {
    halmat_container_unit_view_t units[HALMAT_CONTAINER_MAX_UNITS];
    int num_units;
    int primary_idx;
} halmat_container_t;

/* True iff `path` opens and its first 4 bytes are "YHLA" -- used by
 * main.c to decide dispatch between a container file and an ordinary
 * halmat.bin/@list argument. Does not decompress or otherwise validate
 * the rest of the file. */
bool halmat_container_sniff(const char *path);

bool halmat_container_read(const char *path, halmat_container_t *out, char *errbuf, size_t errbuf_size);
void halmat_container_free(halmat_container_t *c);

#endif
