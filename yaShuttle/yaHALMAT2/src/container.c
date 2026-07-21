#include "container.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#ifdef HAVE_ZLIB
#include <zlib.h>
#elif defined(_WIN32)
#include <windows.h>
#else
#include <unistd.h>
#endif

#define HALMAT_CONTAINER_MAGIC "YHLA"
#define HALMAT_CONTAINER_VERSION 1
#define HALMAT_CONTAINER_HEADER_BYTES 21

/* ---- Growable byte buffer, used to serialize the payload before
 * compression (writer) and while parsing it back (reader uses raw
 * pointers into the decompressed buffer instead). ---- */

typedef struct {
    uint8_t *data;
    size_t len, cap;
} byte_buf_t;

static void bb_init(byte_buf_t *b) {
    b->data = NULL;
    b->len = 0;
    b->cap = 0;
}

static void bb_free(byte_buf_t *b) {
    free(b->data);
    b->data = NULL;
    b->len = b->cap = 0;
}

static bool bb_reserve(byte_buf_t *b, size_t extra) {
    if (b->len + extra <= b->cap) return true;
    size_t new_cap = b->cap ? b->cap * 2 : 4096;
    while (new_cap < b->len + extra) new_cap *= 2;
    uint8_t *nd = realloc(b->data, new_cap);
    if (!nd) return false;
    b->data = nd;
    b->cap = new_cap;
    return true;
}

static bool bb_append(byte_buf_t *b, const void *data, size_t len) {
    if (len == 0) return true;
    if (!bb_reserve(b, len)) return false;
    memcpy(b->data + b->len, data, len);
    b->len += len;
    return true;
}

static bool bb_append_u8(byte_buf_t *b, uint8_t v) {
    return bb_append(b, &v, 1);
}

static bool bb_append_u16be(byte_buf_t *b, uint16_t v) {
    uint8_t buf[2] = {(uint8_t)(v >> 8), (uint8_t)v};
    return bb_append(b, buf, 2);
}

static bool bb_append_u32be(byte_buf_t *b, uint32_t v) {
    uint8_t buf[4] = {(uint8_t)(v >> 24), (uint8_t)(v >> 16), (uint8_t)(v >> 8), (uint8_t)v};
    return bb_append(b, buf, 4);
}

static uint16_t read_be16(const uint8_t *p) {
    return (uint16_t)(((uint16_t)p[0] << 8) | p[1]);
}

static uint32_t read_be32(const uint8_t *p) {
    return ((uint32_t)p[0] << 24) | ((uint32_t)p[1] << 16) | ((uint32_t)p[2] << 8) | p[3];
}

static uint64_t read_be64(const uint8_t *p) {
    uint64_t v = 0;
    for (int i = 0; i < 8; i++) v = (v << 8) | p[i];
    return v;
}

static void write_be64(uint8_t *p, uint64_t v) {
    for (int i = 0; i < 8; i++) p[7 - i] = (uint8_t)(v >> (8 * i));
}

/* ---- zlib one-shot compress/decompress, falling back to piping through
 * the `gzip` binary when HAVE_ZLIB isn't defined -- mirrors literal.c's
 * read_memory_image() dual-path convention (including its _WIN32
 * _popen/_pclose vs popen/pclose split), except operating on in-memory
 * buffers on both ends rather than a named file, so the fallback first
 * spools its input to a temporary file (gzip has no "compress this
 * buffer I already have in memory" mode without one). ---- */

#ifndef HAVE_ZLIB
static bool make_temp_path(char *buf, size_t bufsize) {
#ifdef _WIN32
    char tmpdir[MAX_PATH];
    if (GetTempPathA((DWORD)sizeof(tmpdir), tmpdir) == 0) return false;
    char tmpfile[MAX_PATH];
    if (GetTempFileNameA(tmpdir, "yhl", 0, tmpfile) == 0) return false;
    strncpy(buf, tmpfile, bufsize - 1);
    buf[bufsize - 1] = '\0';
    return true;
#else
    const char *tmpdir = getenv("TMPDIR");
    if (!tmpdir) tmpdir = "/tmp";
    snprintf(buf, bufsize, "%s/yhla_%ld_%d.tmp", tmpdir, (long)time(NULL), (int)getpid());
    return true;
#endif
}

static bool read_pipe_all(FILE *fp, uint8_t **out_buf, size_t *out_len) {
    size_t cap = 65536, len = 0;
    uint8_t *buf = malloc(cap);
    if (!buf) return false;
    size_t n;
    while ((n = fread(buf + len, 1, cap - len, fp)) > 0) {
        len += n;
        if (len == cap) {
            cap *= 2;
            uint8_t *nb = realloc(buf, cap);
            if (!nb) {
                free(buf);
                return false;
            }
            buf = nb;
        }
    }
    *out_buf = buf;
    *out_len = len;
    return true;
}

/* Spools `src` to a temp file, runs `gzip_args` (either "-c" to compress
 * or "-dc" to decompress) against that file, and captures the single-
 * directional stdout via popen/fread -- same "popen reads a named file's
 * output" shape as literal.c's read_memory_image fallback, just with a
 * self-created temp file standing in for a real on-disk companion. */
static bool gzip_pipe_fallback(const char *gzip_args, const uint8_t *src, size_t src_len,
                                uint8_t **out_buf, size_t *out_len, char *errbuf, size_t errbuf_size) {
    char tmp_path[1024];
    if (!make_temp_path(tmp_path, sizeof(tmp_path))) {
        snprintf(errbuf, errbuf_size, "cannot create a temporary file for the gzip fallback");
        return false;
    }
    FILE *tf = fopen(tmp_path, "wb");
    if (!tf) {
        snprintf(errbuf, errbuf_size, "cannot open temporary file '%s'", tmp_path);
        return false;
    }
    if (src_len > 0 && fwrite(src, 1, src_len, tf) != src_len) {
        fclose(tf);
        remove(tmp_path);
        snprintf(errbuf, errbuf_size, "short write to temporary file '%s'", tmp_path);
        return false;
    }
    fclose(tf);

    char cmd[1200];
    snprintf(cmd, sizeof(cmd), "gzip %s \"%s\" 2>/dev/null", gzip_args, tmp_path);
#ifdef _WIN32
    FILE *fp = _popen(cmd, "rb");
#else
    FILE *fp = popen(cmd, "r");
#endif
    if (!fp) {
        remove(tmp_path);
        snprintf(errbuf, errbuf_size, "cannot run gzip for the fallback (no zlib at build time)");
        return false;
    }
    bool ok = read_pipe_all(fp, out_buf, out_len);
#ifdef _WIN32
    _pclose(fp);
#else
    pclose(fp);
#endif
    remove(tmp_path);
    if (!ok) {
        snprintf(errbuf, errbuf_size, "out of memory reading gzip fallback output");
        return false;
    }
    return true;
}
#endif /* !HAVE_ZLIB */

static bool container_compress(const uint8_t *src, size_t src_len, uint8_t **out_buf, size_t *out_len,
                                char *errbuf, size_t errbuf_size) {
#ifdef HAVE_ZLIB
    uLongf bound = compressBound((uLong)src_len);
    uint8_t *dst = malloc(bound ? bound : 1);
    if (!dst) {
        snprintf(errbuf, errbuf_size, "out of memory compressing container payload");
        return false;
    }
    uLongf dst_len = bound;
    int rc = compress2(dst, &dst_len, src, (uLong)src_len, Z_DEFAULT_COMPRESSION);
    if (rc != Z_OK) {
        snprintf(errbuf, errbuf_size, "zlib compression failed (code %d)", rc);
        free(dst);
        return false;
    }
    *out_buf = dst;
    *out_len = (size_t)dst_len;
    return true;
#else
    return gzip_pipe_fallback("-c", src, src_len, out_buf, out_len, errbuf, errbuf_size);
#endif
}

static bool container_decompress(const uint8_t *src, size_t src_len, size_t expected_uncompressed_len,
                                  uint8_t **out_buf, char *errbuf, size_t errbuf_size) {
#ifdef HAVE_ZLIB
    uint8_t *dst = malloc(expected_uncompressed_len ? expected_uncompressed_len : 1);
    if (!dst) {
        snprintf(errbuf, errbuf_size, "out of memory decompressing container payload");
        return false;
    }
    uLongf dst_len = (uLongf)expected_uncompressed_len;
    int rc = uncompress(dst, &dst_len, src, (uLong)src_len);
    if (rc != Z_OK || (size_t)dst_len != expected_uncompressed_len) {
        snprintf(errbuf, errbuf_size,
                 "zlib decompression failed or size mismatch (code %d, got %lu bytes, expected %zu)",
                 rc, (unsigned long)dst_len, expected_uncompressed_len);
        free(dst);
        return false;
    }
    *out_buf = dst;
    return true;
#else
    uint8_t *buf = NULL;
    size_t len = 0;
    if (!gzip_pipe_fallback("-dc", src, src_len, &buf, &len, errbuf, errbuf_size)) return false;
    if (len != expected_uncompressed_len) {
        snprintf(errbuf, errbuf_size, "gzip fallback decompression size mismatch (got %zu bytes, expected %zu)",
                 len, expected_uncompressed_len);
        free(buf);
        return false;
    }
    *out_buf = buf;
    return true;
#endif
}

/* ---- Writer ---- */

bool halmat_container_write(const char *path, const halmat_container_unit_t *units, int num_units,
                             int primary_idx, char *errbuf, size_t errbuf_size) {
    if (num_units < 0 || num_units > HALMAT_CONTAINER_MAX_UNITS) {
        snprintf(errbuf, errbuf_size, "cannot write container: %d units exceeds the %d-unit cap",
                 num_units, HALMAT_CONTAINER_MAX_UNITS);
        return false;
    }
    if (primary_idx < 0 || primary_idx >= num_units) {
        snprintf(errbuf, errbuf_size, "cannot write container: primary_idx %d out of range for %d units",
                 primary_idx, num_units);
        return false;
    }

    byte_buf_t payload;
    bb_init(&payload);
    bool ok = true;

    ok = ok && bb_append_u16be(&payload, (uint16_t)num_units);
    ok = ok && bb_append_u16be(&payload, (uint16_t)primary_idx);

    for (int i = 0; ok && i < num_units; i++) {
        const halmat_container_unit_t *u = &units[i];
        const char *label = u->label ? u->label : "";
        size_t label_len = strlen(label);
        if (label_len > 0xFFFF) label_len = 0xFFFF; /* diagnostics-only field; cap to fit u16 */
        ok = ok && bb_append_u16be(&payload, (uint16_t)label_len);
        ok = ok && bb_append(&payload, label, label_len);

        ok = ok && bb_append_u32be(&payload, (uint32_t)u->halmat_len);
        ok = ok && bb_append(&payload, u->halmat_bytes, u->halmat_len);

        ok = ok && bb_append_u8(&payload, u->have_lit ? 1 : 0);
        if (ok && u->have_lit) {
            ok = ok && bb_append_u32be(&payload, (uint32_t)u->litfile_len);
            ok = ok && bb_append(&payload, u->litfile_bytes, u->litfile_len);

            byte_buf_t blob;
            bb_init(&blob);
            bool blob_ok = true;
            if (u->literals) {
                for (size_t k = 0; blob_ok && k < u->literals->count; k++) {
                    const halmat_literal_t *e = &u->literals->entries[k];
                    if (e->type != LIT_STRING) continue;
                    const char *s = e->string ? e->string : "";
                    size_t slen = strlen(s);
                    blob_ok = blob_ok && bb_append_u32be(&blob, (uint32_t)slen);
                    blob_ok = blob_ok && bb_append(&blob, s, slen);
                }
            }
            if (!blob_ok) {
                ok = false;
            } else {
                ok = ok && bb_append_u32be(&payload, (uint32_t)blob.len);
                ok = ok && bb_append(&payload, blob.data, blob.len);
            }
            bb_free(&blob);
        }

        ok = ok && bb_append_u8(&payload, u->have_sym ? 1 : 0);
        if (ok && u->have_sym) {
            ok = ok && bb_append_u32be(&payload, (uint32_t)u->symtab_len);
            ok = ok && bb_append(&payload, u->symtab_bytes, u->symtab_len);
        }
    }

    if (!ok) {
        snprintf(errbuf, errbuf_size, "out of memory building container payload");
        bb_free(&payload);
        return false;
    }

    uint8_t *compressed = NULL;
    size_t compressed_len = 0;
    if (!container_compress(payload.data, payload.len, &compressed, &compressed_len, errbuf, errbuf_size)) {
        bb_free(&payload);
        return false;
    }

    FILE *f = fopen(path, "wb");
    if (!f) {
        snprintf(errbuf, errbuf_size, "cannot create '%s': %s", path, strerror(errno));
        free(compressed);
        bb_free(&payload);
        return false;
    }

    uint8_t header[HALMAT_CONTAINER_HEADER_BYTES];
    memcpy(header, HALMAT_CONTAINER_MAGIC, 4);
    header[4] = HALMAT_CONTAINER_VERSION;
    write_be64(header + 5, (uint64_t)payload.len);
    write_be64(header + 13, (uint64_t)compressed_len);

    bool write_ok = fwrite(header, 1, sizeof(header), f) == sizeof(header) &&
                    (compressed_len == 0 || fwrite(compressed, 1, compressed_len, f) == compressed_len);
    fclose(f);
    free(compressed);
    bb_free(&payload);

    if (!write_ok) {
        snprintf(errbuf, errbuf_size, "short write to '%s'", path);
        return false;
    }
    return true;
}

/* ---- Reader ---- */

bool halmat_container_sniff(const char *path) {
    FILE *f = fopen(path, "rb");
    if (!f) return false;
    uint8_t magic[4];
    size_t n = fread(magic, 1, 4, f);
    fclose(f);
    return n == 4 && memcmp(magic, HALMAT_CONTAINER_MAGIC, 4) == 0;
}

bool halmat_container_read(const char *path, halmat_container_t *out, char *errbuf, size_t errbuf_size) {
    memset(out, 0, sizeof(*out));

    FILE *f = fopen(path, "rb");
    if (!f) {
        snprintf(errbuf, errbuf_size, "cannot open '%s': %s", path, strerror(errno));
        return false;
    }
    if (fseek(f, 0, SEEK_END) != 0) {
        snprintf(errbuf, errbuf_size, "cannot seek '%s'", path);
        fclose(f);
        return false;
    }
    long fsize = ftell(f);
    if (fsize < 0 || fseek(f, 0, SEEK_SET) != 0) {
        snprintf(errbuf, errbuf_size, "cannot determine size of '%s'", path);
        fclose(f);
        return false;
    }
    if ((size_t)fsize < HALMAT_CONTAINER_HEADER_BYTES) {
        snprintf(errbuf, errbuf_size, "'%s' is too small to be a linked-archive container", path);
        fclose(f);
        return false;
    }
    uint8_t *filebuf = malloc((size_t)fsize);
    if (!filebuf) {
        snprintf(errbuf, errbuf_size, "out of memory reading '%s'", path);
        fclose(f);
        return false;
    }
    if (fread(filebuf, 1, (size_t)fsize, f) != (size_t)fsize) {
        snprintf(errbuf, errbuf_size, "short read on '%s'", path);
        free(filebuf);
        fclose(f);
        return false;
    }
    fclose(f);

    if (memcmp(filebuf, HALMAT_CONTAINER_MAGIC, 4) != 0) {
        snprintf(errbuf, errbuf_size, "'%s' is not a linked-archive container (bad magic)", path);
        free(filebuf);
        return false;
    }
    uint8_t version = filebuf[4];
    if (version != HALMAT_CONTAINER_VERSION) {
        snprintf(errbuf, errbuf_size,
                 "'%s' is a linked-archive container with unrecognized format version %u (expected %u)",
                 path, version, HALMAT_CONTAINER_VERSION);
        free(filebuf);
        return false;
    }

    uint64_t uncompressed_len = read_be64(filebuf + 5);
    uint64_t compressed_len = read_be64(filebuf + 13);

    if ((uint64_t)fsize - HALMAT_CONTAINER_HEADER_BYTES != compressed_len) {
        snprintf(errbuf, errbuf_size,
                 "'%s' is corrupt: header claims %llu bytes of compressed payload but the file has %llu",
                 path, (unsigned long long)compressed_len,
                 (unsigned long long)((uint64_t)fsize - HALMAT_CONTAINER_HEADER_BYTES));
        free(filebuf);
        return false;
    }

    uint8_t *payload = NULL;
    bool dec_ok = container_decompress(filebuf + HALMAT_CONTAINER_HEADER_BYTES, (size_t)compressed_len,
                                        (size_t)uncompressed_len, &payload, errbuf, errbuf_size);
    free(filebuf);
    if (!dec_ok) return false;

    size_t pos = 0;
    size_t plen = (size_t)uncompressed_len;

#define CONTAINER_NEED(nbytes)                                                              \
    do {                                                                                     \
        if (pos + (size_t)(nbytes) > plen) {                                                 \
            snprintf(errbuf, errbuf_size, "'%s' is corrupt: payload truncated while parsing", path); \
            free(payload);                                                                   \
            halmat_container_free(out);                                                      \
            return false;                                                                    \
        }                                                                                     \
    } while (0)

    CONTAINER_NEED(4);
    uint16_t num_units = read_be16(payload + pos);
    pos += 2;
    uint16_t primary_idx = read_be16(payload + pos);
    pos += 2;

    if (num_units > HALMAT_CONTAINER_MAX_UNITS) {
        snprintf(errbuf, errbuf_size, "'%s' is corrupt: %u units exceeds the %d-unit cap",
                 path, num_units, HALMAT_CONTAINER_MAX_UNITS);
        free(payload);
        return false;
    }
    if (primary_idx >= num_units) {
        snprintf(errbuf, errbuf_size, "'%s' is corrupt: primary_idx %u out of range for %u units",
                 path, primary_idx, num_units);
        free(payload);
        return false;
    }

    out->num_units = num_units;
    out->primary_idx = primary_idx;

    for (int i = 0; i < num_units; i++) {
        halmat_container_unit_view_t *u = &out->units[i];

        CONTAINER_NEED(2);
        uint16_t label_len = read_be16(payload + pos);
        pos += 2;
        CONTAINER_NEED(label_len);
        size_t copy_len = label_len < sizeof(u->label) - 1 ? label_len : sizeof(u->label) - 1;
        memcpy(u->label, payload + pos, copy_len);
        u->label[copy_len] = '\0';
        pos += label_len;

        CONTAINER_NEED(4);
        uint32_t halmat_len = read_be32(payload + pos);
        pos += 4;
        CONTAINER_NEED(halmat_len);
        u->halmat_bytes = malloc(halmat_len ? halmat_len : 1);
        memcpy(u->halmat_bytes, payload + pos, halmat_len);
        u->halmat_len = halmat_len;
        pos += halmat_len;

        CONTAINER_NEED(1);
        u->have_lit = payload[pos] != 0;
        pos += 1;
        if (u->have_lit) {
            CONTAINER_NEED(4);
            uint32_t litfile_len = read_be32(payload + pos);
            pos += 4;
            CONTAINER_NEED(litfile_len);
            u->litfile_bytes = malloc(litfile_len ? litfile_len : 1);
            memcpy(u->litfile_bytes, payload + pos, litfile_len);
            u->litfile_len = litfile_len;
            pos += litfile_len;

            CONTAINER_NEED(4);
            uint32_t blob_len = read_be32(payload + pos);
            pos += 4;
            CONTAINER_NEED(blob_len);
            u->string_blob = malloc(blob_len ? blob_len : 1);
            memcpy(u->string_blob, payload + pos, blob_len);
            u->string_blob_len = blob_len;
            pos += blob_len;
        }

        CONTAINER_NEED(1);
        u->have_sym = payload[pos] != 0;
        pos += 1;
        if (u->have_sym) {
            CONTAINER_NEED(4);
            uint32_t symtab_len = read_be32(payload + pos);
            pos += 4;
            CONTAINER_NEED(symtab_len);
            u->symtab_bytes = malloc(symtab_len ? symtab_len : 1);
            memcpy(u->symtab_bytes, payload + pos, symtab_len);
            u->symtab_len = symtab_len;
            pos += symtab_len;
        }
    }

#undef CONTAINER_NEED

    free(payload);
    return true;
}

void halmat_container_free(halmat_container_t *c) {
    if (!c) return;
    for (int i = 0; i < c->num_units; i++) {
        halmat_container_unit_view_t *u = &c->units[i];
        free(u->halmat_bytes);
        free(u->litfile_bytes);
        free(u->string_blob);
        free(u->symtab_bytes);
    }
    memset(c, 0, sizeof(*c));
}
