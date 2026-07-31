#include "sourcemap.h"

#include <stdbool.h>
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
    uint32_t start, end; /* [start, end) */
} CodeRange;

typedef struct {
    int stmt;
    char **lines;
    int lineCount;
    uint32_t *halmat;
    int halmatCount;
} StmtEntry;

/* One compiled unit's worth of statements/addresses -- see sourcemap.h's
 * header comment. `ranges` holds every CSECT's own [start,end) that
 * actually contributed an address entry -- a unit's code isn't always
 * one contiguous range (e.g. a HAL/S PROGRAM plus an internal
 * PROCEDURE compile to separate CSECTs), so this can't be a single
 * [codeStart,codeEnd) the way a single-unit design could get away
 * with. It's still needed even though module-name dispatch (see
 * sourcemap_lookup) already narrows a lookup to this unit: a linker-
 * generated section with no HAL/S statements of its own (e.g. the
 * entry trampoline) can still carry this same module's name while
 * sitting far outside its real mapped code, which would otherwise make
 * "nearest address <= target" spuriously match whichever statement has
 * the highest address (confirmed: this happened for real once module
 * dispatch replaced the old flat codeStart/codeEnd bounds check). */
typedef struct {
    char *module;
    AddrEntry *addrs;
    int addrCount;
    StmtEntry *stmts;
    int stmtCount;
    CodeRange *ranges;
    int rangeCount;
} SourceUnit;

struct SourceMap {
    SourceUnit *units;
    int unitCount;
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

static uint32_t *load_halmat(const JsonValue *halmat, int *countOut) {
    int n = json_arr_count(halmat);
    uint32_t *out = n > 0 ? calloc((size_t)n, sizeof(uint32_t)) : NULL;
    for (int i = 0; i < n; i++) out[i] = (uint32_t)json_as_number(json_arr_get(halmat, i), 0);
    *countOut = n;
    return out;
}

static void load_unit(SourceUnit *u, const JsonValue *unitJson) {
    u->module = yagpc_strdup(json_as_string(json_obj_get(unitJson, "module"), ""));

    JsonValue *stmts = json_obj_get(unitJson, "statements");
    int stmtCount = json_arr_count(stmts);
    if (stmtCount > 0) {
        u->stmts = calloc((size_t)stmtCount, sizeof(StmtEntry));
        for (int i = 0; i < stmtCount; i++) {
            JsonValue *st = json_arr_get(stmts, i);
            u->stmts[i].stmt = (int)json_as_number(json_obj_get(st, "stmt"), 0);
            u->stmts[i].lines = load_lines(json_obj_get(st, "lines"), &u->stmts[i].lineCount);
            u->stmts[i].halmat = load_halmat(json_obj_get(st, "halmat"), &u->stmts[i].halmatCount);
            u->stmtCount++;
        }
    }

    JsonValue *addrs = json_obj_get(unitJson, "addresses");
    int addrCount = json_arr_count(addrs);
    if (addrCount > 0) {
        u->addrs = calloc((size_t)addrCount, sizeof(AddrEntry));
        for (int i = 0; i < addrCount; i++) {
            JsonValue *e = json_arr_get(addrs, i);
            u->addrs[i].addr = (uint32_t)json_as_number(json_obj_get(e, "addr"), 0);
            u->addrs[i].stmt = (int)json_as_number(json_obj_get(e, "stmt"), 0);
            u->addrCount++;
        }
        qsort(u->addrs, (size_t)u->addrCount, sizeof(AddrEntry), cmp_addr);
    }

    JsonValue *ranges = json_obj_get(unitJson, "codeRanges");
    int rangeCount = json_arr_count(ranges);
    if (rangeCount > 0) {
        u->ranges = calloc((size_t)rangeCount, sizeof(CodeRange));
        for (int i = 0; i < rangeCount; i++) {
            JsonValue *r = json_arr_get(ranges, i);
            u->ranges[i].start = (uint32_t)json_as_number(json_obj_get(r, "start"), 0);
            u->ranges[i].end = (uint32_t)json_as_number(json_obj_get(r, "end"), 0);
            u->rangeCount++;
        }
    }
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
    JsonValue *units = json_obj_get(root, "units");
    int unitCount = json_arr_count(units);
    if (unitCount > 0) {
        sm->units = calloc((size_t)unitCount, sizeof(SourceUnit));
        for (int i = 0; i < unitCount; i++) {
            load_unit(&sm->units[i], json_arr_get(units, i));
            sm->unitCount++;
        }
    }

    json_free(root);

    if (sm->unitCount == 0) {
        fprintf(stderr, "SourceMap: %s has no units\n", jsonPath);
        sourcemap_free(sm);
        return NULL;
    }
    return sm;
}

void sourcemap_free(SourceMap *sm) {
    if (!sm) return;
    for (int i = 0; i < sm->unitCount; i++) {
        SourceUnit *u = &sm->units[i];
        for (int j = 0; j < u->stmtCount; j++) {
            for (int k = 0; k < u->stmts[j].lineCount; k++) free(u->stmts[j].lines[k]);
            free(u->stmts[j].lines);
            free(u->stmts[j].halmat);
        }
        free(u->stmts);
        free(u->addrs);
        free(u->ranges);
        free(u->module);
    }
    free(sm->units);
    free(sm);
}

static const SourceUnit *find_unit(const SourceMap *sm, const char *module) {
    for (int i = 0; i < sm->unitCount; i++) {
        if (strcmp(sm->units[i].module, module) == 0) return &sm->units[i];
    }
    return NULL;
}

static const StmtEntry *find_stmt(const SourceUnit *u, int stmt) {
    for (int i = 0; i < u->stmtCount; i++) {
        if (u->stmts[i].stmt == stmt) return &u->stmts[i];
    }
    return NULL;
}

static bool addr_in_ranges(const SourceUnit *u, uint32_t addr) {
    for (int i = 0; i < u->rangeCount; i++) {
        if (addr >= u->ranges[i].start && addr < u->ranges[i].end) return true;
    }
    return false;
}

int sourcemap_lookup(const SourceMap *sm, const char *module, uint32_t addr, int *stmtOut,
                      const char *const **linesOut, const uint32_t **halmatOut, int *halmatCountOut) {
    if (!sm || !module) return 0;
    const SourceUnit *u = find_unit(sm, module);
    if (!u || u->addrCount == 0) return 0;
    if (!addr_in_ranges(u, addr)) return 0;
    int lo = 0, hi = u->addrCount - 1, best = -1;
    while (lo <= hi) {
        int mid = (lo + hi) / 2;
        if (u->addrs[mid].addr <= addr) {
            best = mid;
            lo = mid + 1;
        } else {
            hi = mid - 1;
        }
    }
    if (best < 0) return 0;
    int stmt = u->addrs[best].stmt;
    const StmtEntry *e = find_stmt(u, stmt);
    if (!e) return 0;
    if (stmtOut) *stmtOut = stmt;
    if (linesOut) *linesOut = (const char *const *)e->lines;
    if (halmatOut) *halmatOut = e->halmat;
    if (halmatCountOut) *halmatCountOut = e->halmatCount;
    return e->lineCount;
}
