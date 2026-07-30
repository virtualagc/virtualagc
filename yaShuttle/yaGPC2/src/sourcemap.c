#include "sourcemap.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "json.h"

typedef struct {
    uint32_t addr;
    int srn;
} AddrEntry;

typedef struct {
    int srn;
    char *text;
} StmtEntry;

struct SourceMap {
    AddrEntry *addrs;
    int addrCount;
    StmtEntry *stmts;
    int stmtCount;
    uint32_t codeStart, codeEnd; /* [codeStart, codeEnd) -- addresses outside
                                   * this range (e.g. the entry trampoline
                                   * sitting after the mapped module in the
                                   * linked image) must never match, or a
                                   * lookup would spuriously return whichever
                                   * mapped statement happens to have the
                                   * highest address */
};

static int cmp_addr(const void *a, const void *b) {
    uint32_t x = ((const AddrEntry *)a)->addr, y = ((const AddrEntry *)b)->addr;
    return (x > y) - (x < y);
}

static char *join_lines(const JsonValue *lines) {
    int n = json_arr_count(lines);
    size_t total = 1;
    for (int i = 0; i < n; i++) total += strlen(json_as_string(json_arr_get(lines, i), "")) + 1;
    char *text = malloc(total);
    text[0] = '\0';
    for (int i = 0; i < n; i++) {
        if (i > 0) strcat(text, " ");
        strcat(text, json_as_string(json_arr_get(lines, i), ""));
    }
    return text;
}

SourceMap *sourcemap_load(const char *jsonPath) {
    FILE *f = fopen(jsonPath, "rb");
    if (!f) {
        fprintf(stderr, "SourceMap: could not open %s\n", jsonPath);
        return NULL;
    }
    fseek(f, 0, SEEK_END);
    long len = ftell(f);
    fseek(f, 0, SEEK_SET);
    char *buf = malloc((size_t)len + 1);
    size_t got = fread(buf, 1, (size_t)len, f);
    fclose(f);
    if (got != (size_t)len) {
        fprintf(stderr, "SourceMap: could not read %s\n", jsonPath);
        free(buf);
        return NULL;
    }
    buf[len] = '\0';

    JsonValue *root = json_parse(buf);
    free(buf);
    if (!root) {
        fprintf(stderr, "SourceMap: could not parse %s\n", jsonPath);
        return NULL;
    }

    SourceMap *sm = calloc(1, sizeof(SourceMap));
    sm->codeStart = (uint32_t)json_as_number(json_obj_get(root, "codeStart"), 0);
    sm->codeEnd = (uint32_t)json_as_number(json_obj_get(root, "codeEnd"), 0);

    JsonValue *stmts = json_obj_get(root, "statements");
    int stmtCount = json_arr_count(stmts);
    if (stmtCount > 0) {
        sm->stmts = calloc((size_t)stmtCount, sizeof(StmtEntry));
        for (int i = 0; i < stmtCount; i++) {
            JsonValue *st = json_arr_get(stmts, i);
            sm->stmts[i].srn = (int)json_as_number(json_obj_get(st, "srn"), 0);
            sm->stmts[i].text = join_lines(json_obj_get(st, "lines"));
            sm->stmtCount++;
        }
    }

    JsonValue *addrs = json_obj_get(root, "addresses");
    int addrCount = json_arr_count(addrs);
    if (addrCount > 0) {
        sm->addrs = calloc((size_t)addrCount, sizeof(AddrEntry));
        for (int i = 0; i < addrCount; i++) {
            JsonValue *e = json_arr_get(addrs, i);
            sm->addrs[i].addr = (uint32_t)json_as_number(json_obj_get(e, "addr"), 0);
            sm->addrs[i].srn = (int)json_as_number(json_obj_get(e, "srn"), 0);
            sm->addrCount++;
        }
        qsort(sm->addrs, (size_t)sm->addrCount, sizeof(AddrEntry), cmp_addr);
    }

    json_free(root);

    if (sm->addrCount == 0) {
        fprintf(stderr, "SourceMap: %s has no address entries\n", jsonPath);
        sourcemap_free(sm);
        return NULL;
    }
    return sm;
}

void sourcemap_free(SourceMap *sm) {
    if (!sm) return;
    for (int i = 0; i < sm->stmtCount; i++) free(sm->stmts[i].text);
    free(sm->stmts);
    free(sm->addrs);
    free(sm);
}

static const char *find_stmt_text(const SourceMap *sm, int srn) {
    for (int i = 0; i < sm->stmtCount; i++) {
        if (sm->stmts[i].srn == srn) return sm->stmts[i].text;
    }
    return NULL;
}

const char *sourcemap_lookup(const SourceMap *sm, uint32_t addr, int *srnOut) {
    if (!sm || sm->addrCount == 0) return NULL;
    if (addr < sm->codeStart || addr >= sm->codeEnd) return NULL;
    int lo = 0, hi = sm->addrCount - 1, best = -1;
    while (lo <= hi) {
        int mid = (lo + hi) / 2;
        if (sm->addrs[mid].addr <= addr) {
            best = mid;
            lo = mid + 1;
        } else {
            hi = mid - 1;
        }
    }
    if (best < 0) return NULL;
    int srn = sm->addrs[best].srn;
    if (srnOut) *srnOut = srn;
    return find_stmt_text(sm, srn);
}
