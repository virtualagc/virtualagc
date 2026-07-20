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
} raw_shape_t;

bool halmat_symtab_load(const char *path, halmat_symtab_t *out, char *errbuf, size_t errbuf_size) {
    memset(out, 0, sizeof(*out));

    FILE *f = fopen(path, "r");
    if (!f) {
        snprintf(errbuf, errbuf_size, "cannot open symbol table '%s'", path);
        return false;
    }

    size_t capacity = 256;
    halmat_symtab_entry_t *entries = malloc(capacity * sizeof(halmat_symtab_entry_t));
    raw_shape_t *raw = malloc(capacity * sizeof(raw_shape_t));
    size_t count = 0;
    bool have_current = false;
    size_t current_index = 0;
    char *current_name = NULL;
    uint32_t current_flags = 0;
    raw_shape_t current_raw = {0};

    size_t extarray_capacity = 0, extarray_count = 0;
    uint32_t *extarray = NULL;

    char line[MAX_LINE];
    while (fgets(line, sizeof(line), f)) {
        size_t len = strlen(line);
        while (len > 0 && (line[len - 1] == '\n' || line[len - 1] == '\r')) line[--len] = '\0';
        if (len == 0) continue;

        char *fields[MAX_FIELDS];
        int n = split_tabs(line, fields);
        if (n < 2) continue;

        if (strcmp(fields[0], "/") == 0 && strcmp(fields[1], "SYMuTAB") == 0) {
            if (have_current) {
                if (count >= capacity) {
                    capacity *= 2;
                    entries = realloc(entries, capacity * sizeof(halmat_symtab_entry_t));
                    raw = realloc(raw, capacity * sizeof(raw_shape_t));
                }
                memset(&entries[count], 0, sizeof(entries[count]));
                entries[count].index = current_index;
                entries[count].name = current_name ? current_name : dup_unquoted("");
                entries[count].flags = current_flags;
                raw[count] = current_raw;
                count++;
            }
            have_current = true;
            current_index = (n >= 3) ? (size_t)strtoul(fields[2], NULL, 10) : 0;
            current_name = NULL;
            current_flags = 0;
            memset(&current_raw, 0, sizeof(current_raw));
        } else if (strcmp(fields[0], ".") == 0 && n >= 5) {
            if (strcmp(fields[1], "SYM_NAME") == 0) {
                free(current_name);
                current_name = dup_unquoted(fields[4]);
            } else if (strcmp(fields[1], "SYM_FLAGS") == 0) {
                current_flags = (uint32_t)strtoul(fields[4], NULL, 16);
            } else if (strcmp(fields[1], "SYM_TYPE") == 0) {
                current_raw.sym_type = (uint32_t)strtoul(fields[4], NULL, 16);
            } else if (strcmp(fields[1], "SYM_LENGTH") == 0) {
                current_raw.sym_length = (uint32_t)strtoul(fields[4], NULL, 16);
            } else if (strcmp(fields[1], "SYM_ARRAY") == 0) {
                current_raw.sym_array = (uint32_t)strtoul(fields[4], NULL, 16);
            }
        } else if (strcmp(fields[0], "+") == 0 && n >= 5 && strcmp(fields[1], "EXTuARRAY") == 0) {
            size_t idx = (size_t)strtoul(fields[2], NULL, 10);
            if (idx >= extarray_capacity) {
                size_t new_cap = idx + 64;
                extarray = realloc(extarray, new_cap * sizeof(uint32_t));
                memset(extarray + extarray_capacity, 0, (new_cap - extarray_capacity) * sizeof(uint32_t));
                extarray_capacity = new_cap;
            }
            extarray[idx] = (uint32_t)strtoul(fields[4], NULL, 16);
            if (idx + 1 > extarray_count) extarray_count = idx + 1;
        }
    }
    if (have_current) {
        if (count >= capacity) {
            capacity += 1;
            entries = realloc(entries, capacity * sizeof(halmat_symtab_entry_t));
            raw = realloc(raw, capacity * sizeof(raw_shape_t));
        }
        memset(&entries[count], 0, sizeof(entries[count]));
        entries[count].index = current_index;
        entries[count].name = current_name ? current_name : dup_unquoted("");
        entries[count].flags = current_flags;
        raw[count] = current_raw;
        count++;
    }
    fclose(f);

    /* Resolution pass: now that EXTuARRAY (if present) is fully read,
     * turn each symbol's raw SYM_TYPE/SYM_LENGTH/SYM_ARRAY into a
     * shape + dimensions. See symtab.h for the encoding. */
    for (size_t i = 0; i < count; i++) {
        entries[i].hal_class = (uint8_t)raw[i].sym_type;
        if (raw[i].sym_array != 0) {
            entries[i].shape = HALMAT_SHAPE_ARRAY;
            uint32_t base = raw[i].sym_array;
            if (base < extarray_count) {
                uint32_t dim_count = extarray[base];
                if (dim_count > HALMAT_SYM_MAX_ARRAY_DIMS) dim_count = HALMAT_SYM_MAX_ARRAY_DIMS;
                entries[i].array_dim_count = (int)dim_count;
                for (uint32_t d = 0; d < dim_count && base + 1 + d < extarray_count; d++) {
                    entries[i].array_dims[d] = (int)extarray[base + 1 + d];
                }
            }
        } else if (raw[i].sym_type == 3) { /* MATRIX, HALMAT class number */
            entries[i].shape = HALMAT_SHAPE_MATRIX;
            entries[i].rows = (int)((raw[i].sym_length >> 8) & 0xFF);
            entries[i].cols = (int)(raw[i].sym_length & 0xFF);
        } else if (raw[i].sym_type == 4) { /* VECTOR */
            entries[i].shape = HALMAT_SHAPE_VECTOR;
            entries[i].cols = (int)raw[i].sym_length;
        } else if (raw[i].sym_type == 1) { /* BIT */
            entries[i].bit_width = (int)raw[i].sym_length;
        }
    }

    free(raw);
    free(extarray);
    out->entries = entries;
    out->count = count;
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
