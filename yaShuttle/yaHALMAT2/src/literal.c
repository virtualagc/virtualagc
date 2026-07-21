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

/* Selects how a LIT_STRING cell's text is obtained -- the only way
 * halmat_literal_load()'s file-based path and halmat_literal_load_from_
 * buffer()'s container-based path differ; everything else about the
 * record/page/cell decode loop below is shared between them. */
typedef struct {
    bool use_blob;
    /* File-based (use_blob == false): index [pointer, pointer+length) out
     * of a decompressed memory-image buffer, degrading gracefully to
     * spaces if `memory` is NULL or the range is out of bounds -- same
     * as this project's established behavior when no memory-image
     * companion file is available. */
    const uint8_t *memory;
    size_t memory_size;
    /* Buffer-based (use_blob == true): read sequentially from a
     * (u32 BE length; length bytes)-record string blob. Exhausting or
     * lacking the blob here is a genuine container-corruption error,
     * not a "missing optional companion" -- see literal.h. */
    const uint8_t *string_blob;
    size_t string_blob_size;
    size_t string_blob_pos;
} lit_string_source_t;

static bool resolve_lit_string(lit_string_source_t *src, uint8_t length_minus_1, uint32_t pointer,
                                char **out_string, char *errbuf, size_t errbuf_size) {
    if (src->use_blob) {
        /* container.c's writer emits exactly one (u32 len; bytes) blob
         * entry per LIT_STRING-typed cell -- including "both zero"
         * placeholder/unused cells (per container.h's documented
         * format) -- so this must always consume one entry here too,
         * unlike the file-based path below's early-out for that same
         * case; skipping it here would desync the blob cursor from the
         * writer's positions for every later cell in the unit. */
        if (!src->string_blob || src->string_blob_pos + 4 > src->string_blob_size) {
            snprintf(errbuf, errbuf_size,
                     "corrupt linked-archive container: string blob exhausted while decoding a CHARACTER literal");
            return false;
        }
        uint32_t str_len = read_be32(src->string_blob + src->string_blob_pos);
        src->string_blob_pos += 4;
        if (src->string_blob_pos + str_len > src->string_blob_size) {
            snprintf(errbuf, errbuf_size,
                     "corrupt linked-archive container: string blob truncated (need %u more bytes "
                     "for a CHARACTER literal, only %zu remain)",
                     str_len, src->string_blob_size - src->string_blob_pos);
            return false;
        }
        char *s = malloc((size_t)str_len + 1);
        memcpy(s, src->string_blob + src->string_blob_pos, str_len);
        s[str_len] = '\0';
        src->string_blob_pos += str_len;
        *out_string = s;
        return true;
    }

    if (length_minus_1 == 0 && pointer == 0) {
        *out_string = calloc(1, 1);
        return true;
    }
    size_t length = (size_t)length_minus_1 + 1;

    char *s = malloc(length + 1);
    if (!src->memory || pointer + length > src->memory_size) {
        memset(s, ' ', length); /* no memory image: degrade gracefully */
    } else {
        for (size_t i = 0; i < length; i++) {
            s[i] = ebcdic_to_ascii[src->memory[pointer + i]];
        }
    }
    s[length] = '\0';
    *out_string = s;
    return true;
}

/* Shared record/page/cell decode loop, factored out of halmat_literal_
 * load() so both the file-based and buffer-based (container) entry
 * points use exactly the same litfile-parsing logic; `oom_label` is only
 * used to phrase the (extremely unlikely) out-of-memory message. */
static bool decode_literal_entries(const uint8_t *litfile, size_t lit_size, const char *oom_label,
                                    lit_string_source_t *src,
                                    halmat_literal_table_t *out, char *errbuf, size_t errbuf_size) {
    size_t num_records = lit_size / LIT_RECORD_BYTES;
    size_t total = num_records * LIT_CELLS_PER_PAGE;
    halmat_literal_t *entries = calloc(total, sizeof(halmat_literal_t));
    if (!entries) {
        snprintf(errbuf, errbuf_size, "out of memory decoding '%s'", oom_label);
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
                    if (!resolve_lit_string(src, length_minus_1, pointer, &e->string, errbuf, errbuf_size)) {
                        for (size_t j = 0; j <= idx; j++) free(entries[j].string);
                        free(entries);
                        return false;
                    }
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

    out->entries = entries;
    out->count = total;
    return true;
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

    lit_string_source_t src = {0};
    src.use_blob = false;
    src.memory = memory;
    src.memory_size = memory_size;

    bool ok = decode_literal_entries(litfile, lit_size, litfile_path, &src, out, errbuf, errbuf_size);
    free(litfile);
    free(memory);
    return ok;
}

bool halmat_literal_load_from_buffer(const uint8_t *litfile_buf, size_t litfile_size,
                                      const uint8_t *string_blob, size_t string_blob_size,
                                      halmat_literal_table_t *out, char *errbuf, size_t errbuf_size) {
    memset(out, 0, sizeof(*out));

    if (!litfile_buf) {
        snprintf(errbuf, errbuf_size, "no literal-table buffer given");
        return false;
    }
    if (litfile_size % LIT_RECORD_BYTES != 0) {
        snprintf(errbuf, errbuf_size,
                 "linked-archive literal table is %zu bytes, not a multiple of the %d-byte literal record size",
                 litfile_size, LIT_RECORD_BYTES);
        return false;
    }

    lit_string_source_t src = {0};
    src.use_blob = true;
    src.string_blob = string_blob;
    src.string_blob_size = string_blob_size;
    src.string_blob_pos = 0;

    return decode_literal_entries(litfile_buf, litfile_size, "<container litfile>", &src, out, errbuf, errbuf_size);
}

void halmat_literal_free(halmat_literal_table_t *table) {
    for (size_t i = 0; i < table->count; i++) {
        free(table->entries[i].string);
    }
    free(table->entries);
    table->entries = NULL;
    table->count = 0;
}
