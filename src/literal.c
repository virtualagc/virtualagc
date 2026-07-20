#include "literal.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef HAVE_ZLIB
#include <zlib.h>
#endif

#include "ebcdic.h"

#define LIT_RECORD_BYTES 1560
#define LIT_PAGE_BYTES 520
#define LIT_CELL_BYTES 4
#define LIT_CELLS_PER_PAGE (LIT_PAGE_BYTES / LIT_CELL_BYTES)

/* COMMONx.out.bin.gz, despite the name, is a gzip'd image of AP-101S
 * compiler memory (not closely related to the plain-text COMMONx.out
 * symbol table) -- CHARACTER literal text lives in it, addressed by the
 * litfile's pointer field. 16 MB matches the reference yaHALMAT
 * emulator's own HALMAT_MEM_SIZE (../Halmat/emu/halmat.h). */
#define HALMAT_MEM_IMAGE_MAX 0x1000000

double ibm_hex_float_to_double(uint32_t msw, uint32_t lsw) {
    int sign = (msw >> 31) & 1;
    int characteristic = (int)((msw >> 24) & 0x7F);
    uint64_t fraction56 = ((uint64_t)(msw & 0x00FFFFFFu) << 32) | lsw;

    if (fraction56 == 0) {
        return sign ? -0.0 : 0.0;
    }

    double value = (double)fraction56 / pow(2.0, 56.0);
    value *= pow(16.0, (double)(characteristic - 64));
    return sign ? -value : value;
}

static uint32_t read_be32(const uint8_t *p) {
    return ((uint32_t)p[0] << 24) | ((uint32_t)p[1] << 16) | ((uint32_t)p[2] << 8) | p[3];
}

static char *read_whole_file(const char *path, size_t *out_size) {
    FILE *f = fopen(path, "rb");
    if (!f) return NULL;
    if (fseek(f, 0, SEEK_END) != 0) { fclose(f); return NULL; }
    long size = ftell(f);
    if (size < 0 || fseek(f, 0, SEEK_SET) != 0) { fclose(f); return NULL; }
    char *buf = malloc((size_t)size);
    if (!buf) { fclose(f); return NULL; }
    if (fread(buf, 1, (size_t)size, f) != (size_t)size) { free(buf); fclose(f); return NULL; }
    fclose(f);
    *out_size = (size_t)size;
    return buf;
}

static bool has_gz_suffix(const char *path) {
    size_t len = strlen(path);
    return len > 3 && strcmp(path + len - 3, ".gz") == 0;
}

/* Decompresses a gzip'd memory image (COMMONx.out.bin.gz) into a capped
 * HALMAT_MEM_IMAGE_MAX buffer via zlib when available, falling back to
 * piping through the `gzip` binary otherwise (mirrors the reference
 * yaHALMAT emulator's halmat_loader.c precedent for the same file kind).
 * Non-.gz paths are read verbatim via read_whole_file. */
static uint8_t *read_memory_image(const char *path, size_t *out_size) {
    if (!has_gz_suffix(path)) {
        return (uint8_t *)read_whole_file(path, out_size);
    }

#ifdef HAVE_ZLIB
    gzFile gz = gzopen(path, "rb");
    if (!gz) return NULL;
    uint8_t *buf = malloc(HALMAT_MEM_IMAGE_MAX);
    if (!buf) { gzclose(gz); return NULL; }
    int nread = gzread(gz, buf, HALMAT_MEM_IMAGE_MAX);
    gzclose(gz);
    if (nread < 0) { free(buf); return NULL; }
    *out_size = (size_t)nread;
    return buf;
#else
    char cmd[1200];
    snprintf(cmd, sizeof(cmd), "gzip -dc \"%s\" 2>/dev/null", path);
#ifdef _WIN32
    FILE *fp = _popen(cmd, "rb");
#else
    FILE *fp = popen(cmd, "r");
#endif
    if (!fp) return NULL;
    uint8_t *buf = malloc(HALMAT_MEM_IMAGE_MAX);
    if (!buf) {
#ifdef _WIN32
        _pclose(fp);
#else
        pclose(fp);
#endif
        return NULL;
    }
    size_t nread = fread(buf, 1, HALMAT_MEM_IMAGE_MAX, fp);
#ifdef _WIN32
    _pclose(fp);
#else
    pclose(fp);
#endif
    *out_size = nread;
    return buf;
#endif
}

bool halmat_literal_load(const char *litfile_path, const char *memory_path,
                          halmat_literal_table_t *out, char *errbuf, size_t errbuf_size) {
    memset(out, 0, sizeof(*out));

    size_t lit_size = 0;
    uint8_t *litfile = (uint8_t *)read_whole_file(litfile_path, &lit_size);
    if (!litfile) {
        snprintf(errbuf, errbuf_size, "cannot read literal file '%s'", litfile_path);
        return false;
    }
    if (lit_size % LIT_RECORD_BYTES != 0) {
        snprintf(errbuf, errbuf_size, "'%s' is %zu bytes, not a multiple of the %d-byte literal record size",
                 litfile_path, lit_size, LIT_RECORD_BYTES);
        free(litfile);
        return false;
    }

    uint8_t *memory = NULL;
    size_t memory_size = 0;
    if (memory_path) {
        memory = read_memory_image(memory_path, &memory_size);
        if (!memory) {
            snprintf(errbuf, errbuf_size, "cannot read memory-image file '%s'", memory_path);
            free(litfile);
            return false;
        }
    }

    size_t num_records = lit_size / LIT_RECORD_BYTES;
    size_t total = num_records * LIT_CELLS_PER_PAGE;
    halmat_literal_t *entries = calloc(total, sizeof(halmat_literal_t));
    if (!entries) {
        snprintf(errbuf, errbuf_size, "out of memory decoding '%s'", litfile_path);
        free(litfile);
        free(memory);
        return false;
    }

    size_t idx = 0;
    for (size_t rec = 0; rec < num_records; rec++) {
        const uint8_t *page1 = litfile + rec * LIT_RECORD_BYTES;
        const uint8_t *page2 = page1 + LIT_PAGE_BYTES;
        const uint8_t *page3 = page1 + 2 * LIT_PAGE_BYTES;

        for (size_t cell = 0; cell < LIT_CELLS_PER_PAGE; cell++, idx++) {
            const uint8_t *c1 = page1 + cell * LIT_CELL_BYTES;
            const uint8_t *c2 = page2 + cell * LIT_CELL_BYTES;
            const uint8_t *c3 = page3 + cell * LIT_CELL_BYTES;
            uint8_t type = c1[3];
            halmat_literal_t *e = &entries[idx];

            switch (type) {
                case LIT_STRING: {
                    e->type = LIT_STRING;
                    uint8_t length_minus_1 = c2[0];
                    uint32_t pointer = ((uint32_t)c2[1] << 16) | ((uint32_t)c2[2] << 8) | c2[3];
                    if (length_minus_1 == 0 && pointer == 0) {
                        e->string = calloc(1, 1);
                        break;
                    }
                    size_t length = (size_t)length_minus_1 + 1;
                    e->string = malloc(length + 1);
                    if (!memory || pointer + length > memory_size) {
                        memset(e->string, ' ', length); /* no memory image: degrade gracefully */
                    } else {
                        for (size_t i = 0; i < length; i++) {
                            e->string[i] = ebcdic_to_ascii[memory[pointer + i]];
                        }
                    }
                    e->string[length] = '\0';
                    break;
                }
                case LIT_FIXED:
                case LIT_DOUBLE: {
                    e->type = (halmat_lit_type_t)type;
                    e->msw = read_be32(c2);
                    e->lsw = read_be32(c3);
                    e->numeric = ibm_hex_float_to_double(e->msw, e->lsw);
                    break;
                }
                case LIT_BIT: {
                    e->type = LIT_BIT;
                    e->bits = read_be32(c2);
                    break;
                }
                default: {
                    e->type = LIT_OTHER;
                    break;
                }
            }
        }
    }

    free(litfile);
    free(memory);
    out->entries = entries;
    out->count = total;
    return true;
}

void halmat_literal_free(halmat_literal_table_t *table) {
    for (size_t i = 0; i < table->count; i++) {
        free(table->entries[i].string);
    }
    free(table->entries);
    table->entries = NULL;
    table->count = 0;
}
