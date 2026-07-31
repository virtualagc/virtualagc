#include "symboltable.h"

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "compat.h"
#include "json.h"
#include "strfmt.h"

void symtable_init(SymbolTable *st) {
    memset(st, 0, sizeof(*st));
}

void symtable_free(SymbolTable *st) {
    for (int i = 0; i < st->symbolCount; i++) free(st->symbols[i].name);
    free(st->symbols);
    for (int i = 0; i < st->sectionCount; i++) {
        free(st->sections[i].name);
        free(st->sections[i].module);
    }
    free(st->sections);
    for (int i = 0; i < st->relocCount; i++) free(st->relocs[i].symbol);
    free(st->relocs);
    for (int i = 0; i < st->symTypeCount; i++) {
        free(st->symTypes[i].name);
        free(st->symTypes[i].st.type);
    }
    free(st->symTypes);
    memset(st, 0, sizeof(*st));
}

static char *read_whole_file(const char *path, char **errOut) {
    FILE *f = fopen(path, "rb");
    if (!f) {
        if (errOut) {
            char buf[512];
            snprintf(buf, sizeof buf, "ENOENT: no such file or directory, open '%s'", path);
            *errOut = yagpc_strdup(buf);
        }
        return NULL;
    }
    fseek(f, 0, SEEK_END);
    long sz = ftell(f);
    fseek(f, 0, SEEK_SET);
    if (sz < 0) {
        fclose(f);
        if (errOut) *errOut = yagpc_strdup("could not determine file size");
        return NULL;
    }
    char *buf = malloc((size_t)sz + 1);
    size_t got = fread(buf, 1, (size_t)sz, f);
    fclose(f);
    buf[got] = '\0';
    return buf;
}

static int cmp_section_addr(const void *a, const void *b) {
    const Section *sa = a, *sb = b;
    if (sa->address < sb->address) return -1;
    if (sa->address > sb->address) return 1;
    return 0;
}

static const Section *find_section_containing(const SymbolTable *st, uint32_t addr) {
    int lo = 0, hi = st->sectionCount - 1, best = -1;
    while (lo <= hi) {
        int mid = (lo + hi) / 2;
        if (st->sections[mid].address <= addr) {
            best = mid;
            lo = mid + 1;
        } else {
            hi = mid - 1;
        }
    }
    if (best < 0) return NULL;
    const Section *s = &st->sections[best];
    if (addr < s->address + s->size) return s;
    return NULL;
}

/* True iff `path` ends with exactly ".sym.json" (matches JS's anchored
 * /\.sym\.json$/ regex, used before doing the suffix replace). */
static bool ends_with_sym_json(const char *path) {
    size_t len = strlen(path);
    const char *suffix = ".sym.json";
    size_t slen = strlen(suffix);
    return len >= slen && strcmp(path + (len - slen), suffix) == 0;
}

static void load_symtypes(SymbolTable *st, const char *symPath, bool verbose) {
    char typesPath[4096];
    if (ends_with_sym_json(symPath)) {
        size_t len = strlen(symPath);
        size_t base = len - strlen(".sym.json");
        snprintf(typesPath, sizeof typesPath, "%.*s.symtypes.json", (int)base, symPath);
    } else {
        snprintf(typesPath, sizeof typesPath, "%s", symPath);
    }

    char *text = read_whole_file(typesPath, NULL);
    if (text) {
        JsonValue *root = json_parse(text);
        free(text);
        if (root && root->type == JSON_OBJECT) {
            int cap = 16;
            st->symTypes = malloc((size_t)cap * sizeof(SymTypeEntry));
            for (JsonMember *m = root->objMembers; m; m = m->next) {
                if (st->symTypeCount >= cap) {
                    cap *= 2;
                    st->symTypes = realloc(st->symTypes, (size_t)cap * sizeof(SymTypeEntry));
                }
                SymTypeEntry *e = &st->symTypes[st->symTypeCount++];
                e->name = yagpc_strdup(m->key);
                const char *type = json_as_string(json_obj_get(m->value, "type"), NULL);
                e->st.type = type ? yagpc_strdup(type) : NULL;
                e->st.size = (int)json_as_number(json_obj_get(m->value, "size"), -1);
            }
            if (verbose) {
                fprintf(stderr, "SymbolTable: Loaded symtypes from %s (%d entries)\n", typesPath, st->symTypeCount);
            }
        }
        if (root) json_free(root);
    }
    /* @symTypes['IOBUF'] ?= { type: 'ascii', size: 43 } — always ensured,
     * whether or not a .symtypes.json was found. */
    bool hasIOBUF = false;
    for (int i = 0; i < st->symTypeCount; i++) {
        if (strcmp(st->symTypes[i].name, "IOBUF") == 0) {
            hasIOBUF = true;
            break;
        }
    }
    if (!hasIOBUF) {
        int idx = st->symTypeCount++;
        st->symTypes = realloc(st->symTypes, (size_t)st->symTypeCount * sizeof(SymTypeEntry));
        st->symTypes[idx].name = yagpc_strdup("IOBUF");
        st->symTypes[idx].st.type = yagpc_strdup("ascii");
        st->symTypes[idx].st.size = 43;
    }
}

bool symtable_load(SymbolTable *st, const char *symPath, bool verbose, uint32_t *entryPointOut) {
    char *err = NULL;
    char *text = read_whole_file(symPath, &err);
    if (!text) {
        fprintf(stderr, "SymbolTable: Could not load symbols: %s\n", err ? err : "unknown error");
        free(err);
        return false;
    }

    JsonValue *root = json_parse(text);
    free(text);
    if (!root) {
        fprintf(stderr, "SymbolTable: Could not load symbols: Unexpected token in JSON\n");
        return false;
    }

    JsonValue *sectionsJson = json_obj_get(root, "sections");
    int nSect = json_arr_count(sectionsJson);
    if (nSect > 0) {
        st->sections = calloc((size_t)nSect, sizeof(Section));
        for (int i = 0; i < nSect; i++) {
            JsonValue *s = json_arr_get(sectionsJson, i);
            st->sections[st->sectionCount].name = yagpc_strdup(json_as_string(json_obj_get(s, "name"), ""));
            st->sections[st->sectionCount].address = (uint32_t)json_as_number(json_obj_get(s, "address"), 0);
            st->sections[st->sectionCount].size = (uint32_t)json_as_number(json_obj_get(s, "size"), 0);
            st->sections[st->sectionCount].module = yagpc_strdup(json_as_string(json_obj_get(s, "module"), ""));
            st->sectionCount++;
        }
        qsort(st->sections, (size_t)st->sectionCount, sizeof(Section), cmp_section_addr);
    }

    JsonValue *symbolsJson = json_obj_get(root, "symbols");
    int nSym = json_arr_count(symbolsJson);
    if (nSym > 0) {
        st->symbols = calloc((size_t)nSym, sizeof(Symbol));
        for (int i = 0; i < nSym; i++) {
            JsonValue *s = json_arr_get(symbolsJson, i);
            st->symbols[st->symbolCount].address = (uint32_t)json_as_number(json_obj_get(s, "address"), 0);
            st->symbols[st->symbolCount].name = yagpc_strdup(json_as_string(json_obj_get(s, "name"), ""));
            st->symbolCount++;
        }
    }

    JsonValue *relocsJson = json_obj_get(root, "relocations");
    int nReloc = json_arr_count(relocsJson);
    if (nReloc > 0) {
        st->relocs = calloc((size_t)nReloc, sizeof(Reloc));
        for (int i = 0; i < nReloc; i++) {
            JsonValue *r = json_arr_get(relocsJson, i);
            st->relocs[st->relocCount].address = (uint32_t)json_as_number(json_obj_get(r, "address"), 0);
            st->relocs[st->relocCount].symbol = yagpc_strdup(json_as_string(json_obj_get(r, "symbol"), ""));
            st->relocCount++;
        }
    }

    load_symtypes(st, symPath, verbose);

    if (verbose) {
        fprintf(stderr, "SymbolTable: Loaded %d symbols, %d sections from %s\n", st->symbolCount, st->sectionCount, symPath);
    }

    JsonValue *ep = json_obj_get(root, "entryPoint");
    bool hasEp = !json_is_null_or_missing(ep) && ep->type == JSON_NUMBER;
    if (hasEp) {
        st->entryPoint = (uint32_t)json_as_number(ep, 0);
        st->hasEntryPoint = true;
        if (entryPointOut) *entryPointOut = st->entryPoint;
    }

    st->loaded = true;
    json_free(root);
    return hasEp;
}

const Symbol *symtable_get_label_at(const SymbolTable *st, uint32_t addr) {
    for (int i = 0; i < st->symbolCount; i++) {
        if (st->symbols[i].address == addr) return &st->symbols[i];
    }
    return NULL;
}

const char *symtable_get_section_at(const SymbolTable *st, uint32_t addr) {
    const Section *s = find_section_containing(st, addr);
    return s ? s->name : NULL;
}

const char *symtable_get_module_at(const SymbolTable *st, uint32_t addr) {
    const Section *s = find_section_containing(st, addr);
    return s ? s->module : NULL;
}

const char *symtable_get_reloc_at(const SymbolTable *st, uint32_t instrAddr, int instrLen) {
    for (int i = 0; i < instrLen; i++) {
        uint32_t addr = instrAddr + (uint32_t)i;
        for (int j = st->relocCount - 1; j >= 0; j--) {
            if (st->relocs[j].address == addr) return st->relocs[j].symbol;
        }
    }
    return NULL;
}

void symtable_format_csect(const SymbolTable *st, uint32_t addr, char *out, int outLen) {
    const Section *s = find_section_containing(st, addr);
    if (s) {
        uint32_t offset = addr - s->address;
        char nameBuf[9];
        snprintf(nameBuf, sizeof nameBuf, "%-8.8s", s->name);
        snprintf(out, (size_t)outLen, "%s+%05x", nameBuf, offset);
        return;
    }
    snprintf(out, (size_t)outLen, "        +     ");
}

void symtable_format_section_offset(const SymbolTable *st, uint32_t addr, char *out, size_t outSize) {
    if (!st->loaded) {
        out[0] = '\0';
        return;
    }
    const Section *s = find_section_containing(st, addr);
    if (s) {
        uint32_t offset = addr - s->address;
        char nameUpper[9];
        int n = 0;
        for (const char *p = s->name; *p && n < 8; p++, n++) nameUpper[n] = (char)toupper((unsigned char)*p);
        nameUpper[n] = '\0';
        char padded[9];
        str_rpad(padded, sizeof padded, nameUpper, " ", 8);
        char hex[16];
        as_hex(hex, sizeof hex, (long long)offset, 4);
        snprintf(out, outSize, "%s+%s", padded, hex);
        return;
    }
    snprintf(out, outSize, "        +    ");
}

const SymType *symtable_get_symtype(const SymbolTable *st, const char *name) {
    for (int i = 0; i < st->symTypeCount; i++) {
        if (strcmp(st->symTypes[i].name, name) == 0) return &st->symTypes[i].st;
    }
    return NULL;
}

int symtable_get_symbol_size(const SymbolTable *st, const Symbol *sym, const char *displayType, int displaySize) {
    if (displaySize > 1) return displaySize;
    if (displayType) {
        if (strcmp(displayType, "fw") == 0 || strcmp(displayType, "int32") == 0 || strcmp(displayType, "float") == 0) return 2;
        if (strcmp(displayType, "dfloat") == 0) return 4;
        if (strcmp(displayType, "ebcdic") == 0 || strcmp(displayType, "ascii") == 0) return displaySize;
    }
    const Section *s = find_section_containing(st, sym->address);
    if (s) {
        uint32_t sectionEnd = s->address + s->size;
        uint32_t nextAddr = sectionEnd;
        for (int i = 0; i < st->symbolCount; i++) {
            uint32_t oa = st->symbols[i].address;
            if (oa > sym->address && oa < nextAddr) nextAddr = oa;
        }
        int32_t diff = (int32_t)(nextAddr - sym->address);
        return diff > 1 ? diff : 1;
    }
    return 1;
}
