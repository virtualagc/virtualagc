#include "sourcemap.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "compat.h"
#include "json.h"

typedef struct {
    uint32_t addr;
    int stmt;
} AddrEntry;

typedef struct {
    int stmt;
    char **lines;
    int lineCount;
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

static char **load_lines(const JsonValue *lines, int *countOut) {
    int n = json_arr_count(lines);
    char **out = n > 0 ? calloc((size_t)n, sizeof(char *)) : NULL;
    for (int i = 0; i < n; i++) out[i] = yagpc_strdup(json_as_string(json_arr_get(lines, i), ""));
    *countOut = n;
    return out;
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
            sm->stmts[i].stmt = (int)json_as_number(json_obj_get(st, "stmt"), 0);
            sm->stmts[i].lines = load_lines(json_obj_get(st, "lines"), &sm->stmts[i].lineCount);
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
            sm->addrs[i].stmt = (int)json_as_number(json_obj_get(e, "stmt"), 0);
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
    for (int i = 0; i < sm->stmtCount; i++) {
        for (int j = 0; j < sm->stmts[i].lineCount; j++) free(sm->stmts[i].lines[j]);
        free(sm->stmts[i].lines);
    }
    free(sm->stmts);
    free(sm->addrs);
    free(sm);
}

static const StmtEntry *find_stmt(const SourceMap *sm, int stmt) {
    for (int i = 0; i < sm->stmtCount; i++) {
        if (sm->stmts[i].stmt == stmt) return &sm->stmts[i];
    }
    return NULL;
}

int sourcemap_lookup(const SourceMap *sm, uint32_t addr, int *stmtOut, const char *const **linesOut) {
    if (!sm || sm->addrCount == 0) return 0;
    if (addr < sm->codeStart || addr >= sm->codeEnd) return 0;
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
    if (best < 0) return 0;
    int stmt = sm->addrs[best].stmt;
    const StmtEntry *e = find_stmt(sm, stmt);
    if (!e) return 0;
    if (stmtOut) *stmtOut = stmt;
    if (linesOut) *linesOut = (const char *const *)e->lines;
    return e->lineCount;
}
