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

bool halmat_symtab_load(const char *path, halmat_symtab_t *out, char *errbuf, size_t errbuf_size) {
    memset(out, 0, sizeof(*out));

    FILE *f = fopen(path, "r");
    if (!f) {
        snprintf(errbuf, errbuf_size, "cannot open symbol table '%s'", path);
        return false;
    }

    size_t capacity = 256;
    halmat_symtab_entry_t *entries = malloc(capacity * sizeof(halmat_symtab_entry_t));
    size_t count = 0;
    bool have_current = false;
    size_t current_index = 0;
    char *current_name = NULL;
    uint32_t current_flags = 0;

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
                }
                entries[count].index = current_index;
                entries[count].name = current_name ? current_name : dup_unquoted("");
                entries[count].flags = current_flags;
                count++;
            }
            have_current = true;
            current_index = (n >= 3) ? (size_t)strtoul(fields[2], NULL, 10) : 0;
            current_name = NULL;
            current_flags = 0;
        } else if (strcmp(fields[0], ".") == 0 && n >= 5) {
            if (strcmp(fields[1], "SYM_NAME") == 0) {
                free(current_name);
                current_name = dup_unquoted(fields[4]);
            } else if (strcmp(fields[1], "SYM_FLAGS") == 0) {
                current_flags = (uint32_t)strtoul(fields[4], NULL, 16);
            }
        }
    }
    if (have_current) {
        if (count >= capacity) {
            capacity += 1;
            entries = realloc(entries, capacity * sizeof(halmat_symtab_entry_t));
        }
        entries[count].index = current_index;
        entries[count].name = current_name ? current_name : dup_unquoted("");
        entries[count].flags = current_flags;
        count++;
    }

    fclose(f);
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
