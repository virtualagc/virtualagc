#include "symtab.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINE 2048
#define MAX_FIELDS 8

/* Splits a tab-separated line (trailing newline already stripped) into
 * up to MAX_FIELDS fields, returning the count. Modifies `line` in
 * place (inserts NULs), same convention as strtok. */
static int split_tabs(char *line, char *fields[MAX_FIELDS]) {
    int n = 0;
    char *p = line;
    fields[n++] = p;
    while (*p && n < MAX_FIELDS) {
        if (*p == '\t') {
            *p = '\0';
            fields[n++] = p + 1;
        }
        p++;
    }
    return n;
}

static char *dup_unquoted(const char *s) {
    size_t len = strlen(s);
    if (len >= 2 && s[0] == '\'' && s[len - 1] == '\'') {
        char *out = malloc(len - 1);
        memcpy(out, s + 1, len - 2);
        out[len - 2] = '\0';
        return out;
    }
    char *out = malloc(len + 1);
    memcpy(out, s, len + 1);
    return out;
}

/* Raw per-symbol fields needed to resolve MATRIX/VECTOR/ARRAY shape,
 * kept alongside (not instead of) the public entries array so the
 * resolution pass below can run after the whole file -- including the
 * "+  EXTuARRAY  idx  BIT  hex" table, which appears after every
 * SYMuTAB block in the file -- has been read. See symtab.h's shape
 * documentation for the field encodings themselves. */
typedef struct {
    uint32_t sym_type;
    uint32_t sym_length;
    uint32_t sym_array;
    uint32_t sym_ptr;
    uint32_t sym_link1;
    uint32_t sym_link2;
} raw_shape_t;

/* Shared mutable parse state, so the per-line body (symtab_process_line)
 * and the final resolution pass (symtab_finalize) are usable by both the
 * FILE*-based (halmat_symtab_load) and buffer-based (halmat_symtab_load_
 * from_buffer) entry points without duplicating either. */
typedef struct {
    halmat_symtab_entry_t *entries;
    raw_shape_t *raw;
    size_t capacity, count;

    bool have_current;
    size_t current_index;
    char *current_name;
    uint32_t current_flags;
    raw_shape_t current_raw;

    size_t extarray_capacity, extarray_count;
    uint32_t *extarray;
} symtab_parse_state_t;

static void symtab_parse_init(symtab_parse_state_t *st) {
    memset(st, 0, sizeof(*st));
    st->capacity = 256;
    st->entries = malloc(st->capacity * sizeof(halmat_symtab_entry_t));
    st->raw = malloc(st->capacity * sizeof(raw_shape_t));
}

/* Appends the in-progress current_* record (if any) to entries[]/raw[],
 * transferring ownership of current_name's allocation into the new
 * entry -- same convention as the pre-refactor code (no free/dup here). */
static void symtab_flush_current(symtab_parse_state_t *st) {
    if (!st->have_current) return;
    if (st->count >= st->capacity) {
        st->capacity *= 2;
        st->entries = realloc(st->entries, st->capacity * sizeof(halmat_symtab_entry_t));
        st->raw = realloc(st->raw, st->capacity * sizeof(raw_shape_t));
    }
    memset(&st->entries[st->count], 0, sizeof(st->entries[st->count]));
    st->entries[st->count].index = st->current_index;
    st->entries[st->count].name = st->current_name ? st->current_name : dup_unquoted("");
    st->entries[st->count].flags = st->current_flags;
    st->raw[st->count] = st->current_raw;
    st->count++;
}

/* Processes one already newline-stripped-or-not line (trailing \n/\r are
 * stripped here, same as the pre-refactor code did right after fgets). */
static void symtab_process_line(symtab_parse_state_t *st, char *line) {
    size_t len = strlen(line);
    while (len > 0 && (line[len - 1] == '\n' || line[len - 1] == '\r')) line[--len] = '\0';
    if (len == 0) return;

    char *fields[MAX_FIELDS];
    int n = split_tabs(line, fields);
    if (n < 2) return;

    if (strcmp(fields[0], "/") == 0 && strcmp(fields[1], "SYMuTAB") == 0) {
        symtab_flush_current(st);
        st->have_current = true;
        st->current_index = (n >= 3) ? (size_t)strtoul(fields[2], NULL, 10) : 0;
        st->current_name = NULL;
        st->current_flags = 0;
        memset(&st->current_raw, 0, sizeof(st->current_raw));
    } else if (strcmp(fields[0], ".") == 0 && n >= 5) {
        if (strcmp(fields[1], "SYM_NAME") == 0) {
            free(st->current_name);
            st->current_name = dup_unquoted(fields[4]);
        } else if (strcmp(fields[1], "SYM_FLAGS") == 0) {
            st->current_flags = (uint32_t)strtoul(fields[4], NULL, 16);
        } else if (strcmp(fields[1], "SYM_TYPE") == 0) {
            st->current_raw.sym_type = (uint32_t)strtoul(fields[4], NULL, 16);
        } else if (strcmp(fields[1], "SYM_LENGTH") == 0) {
            st->current_raw.sym_length = (uint32_t)strtoul(fields[4], NULL, 16);
        } else if (strcmp(fields[1], "SYM_ARRAY") == 0) {
            st->current_raw.sym_array = (uint32_t)strtoul(fields[4], NULL, 16);
        } else if (strcmp(fields[1], "SYM_PTR") == 0) {
            st->current_raw.sym_ptr = (uint32_t)strtoul(fields[4], NULL, 16);
        } else if (strcmp(fields[1], "SYM_LINK1") == 0) {
            st->current_raw.sym_link1 = (uint32_t)strtoul(fields[4], NULL, 16);
        } else if (strcmp(fields[1], "SYM_LINK2") == 0) {
            st->current_raw.sym_link2 = (uint32_t)strtoul(fields[4], NULL, 16);
        }
    } else if (strcmp(fields[0], "+") == 0 && n >= 5 && strcmp(fields[1], "EXTuARRAY") == 0) {
        size_t idx = (size_t)strtoul(fields[2], NULL, 10);
        if (idx >= st->extarray_capacity) {
            size_t new_cap = idx + 64;
            st->extarray = realloc(st->extarray, new_cap * sizeof(uint32_t));
            memset(st->extarray + st->extarray_capacity, 0, (new_cap - st->extarray_capacity) * sizeof(uint32_t));
            st->extarray_capacity = new_cap;
        }
        st->extarray[idx] = (uint32_t)strtoul(fields[4], NULL, 16);
        if (idx + 1 > st->extarray_count) st->extarray_count = idx + 1;
    }
}

/* Flushes any still-pending record, then runs the MATRIX/VECTOR/ARRAY/BIT
 * shape-resolution pass (needs the whole file read first, since EXTuARRAY
 * appears after the SYMuTAB blocks that reference it) and hands the
 * finished table to `out`. */
static void symtab_finalize(symtab_parse_state_t *st, halmat_symtab_t *out) {
    symtab_flush_current(st);

    for (size_t i = 0; i < st->count; i++) {
        st->entries[i].hal_class = (uint8_t)st->raw[i].sym_type;
        st->entries[i].sym_ptr = (int)st->raw[i].sym_ptr;
        /* BIT (hal_class==1): SYM_LENGTH is the per-element declared
         * width, independent of whether this symbol is *also* ARRAY-
         * shaped below -- unlike MATRIX/VECTOR (whose own dimensions
         * only make sense for the unarrayed case, SYM_LENGTH packing
         * rows/cols or the vector length directly), a BIT ARRAY has
         * both a shape (ARRAY, from SYM_ARRAY) and a per-element width
         * (BIT(n), from this same SYM_LENGTH) that need to coexist --
         * confirmed empirically this session (test_arrinit_types.hal's
         * `B ARRAY(3) BIT(4)`: SYM_TYPE=01, SYM_LENGTH=0004, SYM_ARRAY=
         * 0001, i.e. genuinely both). Checked unconditionally, before
         * the shape if/else chain below (which was silently discarding
         * this for any BIT symbol that also happened to be an ARRAY --
         * user-reported via a WRITE(6) of such an array formatting with
         * the wrong width). */
        if (st->raw[i].sym_type == 1) {
            st->entries[i].bit_width = (int)st->raw[i].sym_length;
        }
        /* Structure-field linked list (symtab.h's struct_first_field/
         * struct_next_field comment): SYM_LINK1 (template only) and
         * SYM_LINK2 (every field) are raw 16-bit values where a real
         * forward reference is always a small, in-range, strictly-
         * increasing-from-the-template SYT index, and "no next field"
         * is consistently negative when reinterpreted as int16_t (every
         * terminal value observed empirically -- 0xFFFC, 0xFFFB -- is
         * negative this way, though the two aren't the same constant,
         * so this checks sign rather than a specific sentinel). */
        st->entries[i].struct_first_field = (int16_t)(uint16_t)st->raw[i].sym_link1;
        if (st->entries[i].struct_first_field < 0) st->entries[i].struct_first_field = -1;
        st->entries[i].struct_next_field = (int16_t)(uint16_t)st->raw[i].sym_link2;
        if (st->entries[i].struct_next_field < 0) st->entries[i].struct_next_field = -1;
        if (st->raw[i].sym_type == 0x0A) { /* MAJ_STRUC: SYM_ARRAY is a direct copy count, not an EXTuARRAY index -- see symtab.h */
            st->entries[i].struct_copies = (int)st->raw[i].sym_array;
        } else if (st->raw[i].sym_array != 0) {
            st->entries[i].shape = HALMAT_SHAPE_ARRAY;
            uint32_t base = st->raw[i].sym_array;
            if (base < st->extarray_count) {
                uint32_t dim_count = st->extarray[base];
                if (dim_count > HALMAT_SYM_MAX_ARRAY_DIMS) dim_count = HALMAT_SYM_MAX_ARRAY_DIMS;
                st->entries[i].array_dim_count = (int)dim_count;
                for (uint32_t d = 0; d < dim_count && base + 1 + d < st->extarray_count; d++) {
                    /* Each EXT_ARRAY dimension-bound entry is a 16-bit BIT
                     * field (confirmed via the raw COMMON0.out dump --
                     * "EXTuARRAY n BIT xxxx", always 4 hex digits), so it
                     * must be sign-extended from int16_t, not read as a
                     * plain unsigned value -- an `ARRAY(*)` (assumed-size)
                     * parameter's own bound is encoded as a *negative*
                     * 16-bit value (user-reported, 140-STATISTICS.hal's
                     * `DECLARE DATA ARRAY(*) SCALAR;`: EXT_ARRAY entry
                     * 0xFFF9 = -7, confirmed against a second real-corpus
                     * case, 141-VSUM.hal's `ARRAY(*) VECTOR`: 0xFFFC = -4
                     * -- a different magnitude, so the sentinel is "any
                     * negative value," not one fixed constant). Read as
                     * plain unsigned (the prior behavior), -7 became 65529
                     * and -4 became 65532, both silently accepted as
                     * enormous-but-"valid" array sizes by ensure_container
                     * (falling through to its own generic 64-element
                     * placeholder capacity instead), rather than being
                     * recognized as the assumed-size marker they are --
                     * see ensure_container()'s and bind_call_argument()'s
                     * own comments (interp.c) for how a negative bound is
                     * actually handled now. */
                    st->entries[i].array_dims[d] = (int16_t)(uint16_t)st->extarray[base + 1 + d];
                }
            }
            /* ARRAY-of-VECTOR/MATRIX (`ARRAY(n) VECTOR`, `ARRAY(n)
             * MATRIX(r,c)`): SYM_LENGTH still packs the *element*'s own
             * VECTOR/MATRIX shape, exactly like the plain (unarrayed)
             * VECTOR/MATRIX branches below -- confirmed against
             * 117-EXAMPLE_8.hal's `POSITIONS ARRAY(5) VECTOR` (SYM_TYPE=
             * 04, SYM_LENGTH=0003, SYM_ARRAY=0001, i.e. an ARRAY(5) of
             * VECTOR(3)). rows/cols are otherwise unused when shape==
             * ARRAY (array_dims/array_dim_count carry the outer shape
             * instead), so reused here for the element shape rather than
             * adding new fields -- interp.c's ensure_container() is what
             * actually turns this into real container storage. */
            if (st->raw[i].sym_type == 3) {
                st->entries[i].rows = (int)((st->raw[i].sym_length >> 8) & 0xFF);
                st->entries[i].cols = (int)(st->raw[i].sym_length & 0xFF);
            } else if (st->raw[i].sym_type == 4) {
                st->entries[i].cols = (int)st->raw[i].sym_length;
            }
        } else if (st->raw[i].sym_type == 3) { /* MATRIX, HALMAT class number */
            st->entries[i].shape = HALMAT_SHAPE_MATRIX;
            st->entries[i].rows = (int)((st->raw[i].sym_length >> 8) & 0xFF);
            st->entries[i].cols = (int)(st->raw[i].sym_length & 0xFF);
        } else if (st->raw[i].sym_type == 4) { /* VECTOR */
            st->entries[i].shape = HALMAT_SHAPE_VECTOR;
            st->entries[i].cols = (int)st->raw[i].sym_length;
        }
    }

    free(st->raw);
    free(st->extarray);
    out->entries = st->entries;
    out->count = st->count;
}

bool halmat_symtab_load(const char *path, halmat_symtab_t *out, char *errbuf, size_t errbuf_size) {
    memset(out, 0, sizeof(*out));

    FILE *f = fopen(path, "r");
    if (!f) {
        snprintf(errbuf, errbuf_size, "cannot open symbol table '%s'", path);
        return false;
    }

    symtab_parse_state_t st;
    symtab_parse_init(&st);

    char line[MAX_LINE];
    while (fgets(line, sizeof(line), f)) {
        symtab_process_line(&st, line);
    }
    fclose(f);

    symtab_finalize(&st, out);
    return true;
}

bool halmat_symtab_load_from_buffer(const uint8_t *buf, size_t size, halmat_symtab_t *out,
                                     char *errbuf, size_t errbuf_size) {
    memset(out, 0, sizeof(*out));

    if (!buf && size > 0) {
        snprintf(errbuf, errbuf_size, "no symbol-table buffer given");
        return false;
    }

    symtab_parse_state_t st;
    symtab_parse_init(&st);

    /* Portable in-buffer line reader (no fmemopen(), a POSIX/glibc
     * extension unavailable to this project's MSVC/nmake Windows build --
     * see symtab.h): scan for '\n', and treat a bare trailing partial
     * line at EOF as a line too, matching fgets' own behavior on a file
     * that doesn't end with a trailing newline. */
    char line[MAX_LINE];
    size_t pos = 0;
    while (pos < size) {
        size_t start = pos;
        while (pos < size && buf[pos] != '\n') pos++;
        size_t line_len = pos - start;
        if (line_len > sizeof(line) - 1) line_len = sizeof(line) - 1; /* match fgets' MAX_LINE cap */
        memcpy(line, buf + start, line_len);
        line[line_len] = '\0';
        if (pos < size) pos++; /* consume the '\n' itself */
        symtab_process_line(&st, line);
    }

    symtab_finalize(&st, out);
    return true;
}

void halmat_symtab_free(halmat_symtab_t *table) {
    for (size_t i = 0; i < table->count; i++) free(table->entries[i].name);
    free(table->entries);
    table->entries = NULL;
    table->count = 0;
}

const halmat_symtab_entry_t *halmat_symtab_find(const halmat_symtab_t *table, const char *name) {
    if (!name || !name[0]) return NULL;
    for (size_t i = 0; i < table->count; i++) {
        if (table->entries[i].name[0] && strcmp(table->entries[i].name, name) == 0) {
            return &table->entries[i];
        }
    }
    return NULL;
}

const halmat_symtab_entry_t *halmat_symtab_find_by_index(const halmat_symtab_t *table, size_t index) {
    for (size_t i = 0; i < table->count; i++) {
        if (table->entries[i].index == index) return &table->entries[i];
    }
    return NULL;
}
