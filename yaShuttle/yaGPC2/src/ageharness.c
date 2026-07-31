#include "ageharness.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "compat.h"

static const char *simple_basename(const char *path) {
    const char *slash = strrchr(path, '/');
    return slash ? slash + 1 : path;
}

/* Ported from AGEHarness#autoDetectSymbols: replace a case-insensitive
 * trailing ".fcm" with ".sym.json" and check the result exists. Returns
 * NULL (no ownership transfer) if fcmPath doesn't end in ".fcm" or the
 * candidate file doesn't exist; otherwise returns a malloc'd path the
 * caller must free(). */
static char *auto_detect_symbols(const char *fcmPath) {
    size_t len = strlen(fcmPath);
    if (len < 4 || yagpc_strcasecmp(fcmPath + len - 4, ".fcm") != 0) return NULL;
    size_t stem = len - 4;
    char *out = malloc(stem + strlen(".sym.json") + 1);
    memcpy(out, fcmPath, stem);
    strcpy(out + stem, ".sym.json");
    FILE *f = fopen(out, "rb");
    if (f) {
        fclose(f);
        return out;
    }
    free(out);
    return NULL;
}

void ageharness_init(AGEHarness *age) {
    memset(age, 0, sizeof(*age));
    ap101_init(&age->gpc);
    halucp_init(&age->halUCP, &age->gpc.cpu);
    age->gpc.cpu.halUCP = &age->halUCP;
    age->gpc.cpu.halUCPLog = halucp_log_cb;
    age->gpc.cpu.halUCPHandleSVC = halucp_handle_svc;
    symtable_init(&age->sym);
    age->stepCount = 0;
}

void ageharness_free(AGEHarness *age) {
    ap101_free(&age->gpc);
    halucp_free(&age->halUCP);
    symtable_free(&age->sym);
    free(age->fcmName);
    free(age->lastSymbolsPath);
    free(age->initialFcmPath);
    memset(age, 0, sizeof(*age));
}

static long load_fcm(AGEHarness *age, const char *fcmPath) {
    free(age->fcmName);
    age->fcmName = yagpc_strdup(simple_basename(fcmPath));

    FILE *f = fopen(fcmPath, "rb");
    if (!f) {
        /* fs.readFileSync throws uncaught here in the JS — no recoverable
         * path to replicate; fail loudly instead. */
        fprintf(stderr, "Error: ENOENT: no such file or directory, open '%s'\n", fcmPath);
        exit(1);
    }
    fseek(f, 0, SEEK_END);
    long sz = ftell(f);
    fseek(f, 0, SEEK_SET);
    uint8_t *buf = malloc((size_t)sz);
    size_t got = fread(buf, 1, (size_t)sz, f);
    fclose(f);
    membus_load16(&age->gpc.ram, 0, buf, got);
    free(buf);
    return sz;
}

/* Returns true and sets *entryPointOut iff the symbols JSON has a numeric
 * entryPoint (mirrors loadSymbols' null-vs-address return). */
static bool load_symbols(AGEHarness *age, const char *symbolsPath, bool verbose, uint32_t *entryPointOut) {
    if (!symbolsPath) return false;
    uint32_t ep = 0;
    bool has = symtable_load(&age->sym, symbolsPath, verbose, &ep);
    if (has) {
        halucp_init_from_symbols(&age->halUCP, &age->sym);
        if (entryPointOut) *entryPointOut = ep;
    }
    return has;
}

/* Mirrors `parseHex = (s) -> parseInt(s.replace(/^0x/i,''),16)`. */
static uint32_t parse_hex(const char *s) {
    if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X')) s += 2;
    return (uint32_t)strtoul(s, NULL, 16);
}

void ageharness_configure_from_opts(AGEHarness *age, const char *fcmPath, const Options *opts, ConfigureResult *out) {
    age->halUCP.trapSvcError = opts->trapSvcError;
    age->halUCP.formatNumBlanks = atoi(opts->halucpFormatNumBlanks);
    /* Leave at halucp_init's sentinel (-1, meaning "use the per-channel
     * PAGED/UNPAGED default") unless the user explicitly overrode it --
     * see halucp.c's effective_line_width(). */
    if (opts->lineWidthSet) age->halUCP.lineWidth = atoi(opts->lineWidth);
    age->gpc.cpu.fcosMode = opts->fcos;

    char *autoSymbols = NULL;
    const char *symbolsPath = opts->symbols;
    if (!symbolsPath) {
        autoSymbols = auto_detect_symbols(fcmPath);
        symbolsPath = autoSymbols;
    }
    uint32_t symEntry = 0;
    bool hasSymEntry = load_symbols(age, symbolsPath, opts->verbose, &symEntry);

    free(age->lastSymbolsPath);
    age->lastSymbolsPath = symbolsPath ? yagpc_strdup(symbolsPath) : NULL;
    free(autoSymbols);

    bool hasEntryPoint = false;
    uint32_t entryPoint = 0;
    if (opts->start) {
        entryPoint = parse_hex(opts->start);
        hasEntryPoint = true;
    } else if (hasSymEntry) {
        entryPoint = symEntry;
        hasEntryPoint = true;
    }

    long byteCount = load_fcm(age, fcmPath);
    if (hasEntryPoint) ageharness_set_entry_point(age, entryPoint);

    if (age->initialFcmPath != fcmPath) {
        free(age->initialFcmPath);
        age->initialFcmPath = yagpc_strdup(fcmPath);
    }
    age->initialOpts = *opts;
    age->hasInitial = true;

    if (out) {
        out->byteCount = byteCount;
        out->hasEntryPoint = hasEntryPoint;
        out->entryPoint = entryPoint;
    }
}

bool ageharness_init_minimal(AGEHarness *age, const char *fcmPath) {
    ageharness_init(age);
    load_fcm(age, fcmPath); /* exits(1) on hard failure -- see header comment */
    return true;
}

void ageharness_set_entry_point(AGEHarness *age, uint32_t addr) {
    psw_set_nia(&age->gpc.cpu.psw, addr);
    psw_set_wait_state(&age->gpc.cpu.psw, false);
}

void ageharness_snapshot_regs(AGEHarness *age, RegSnapshot *snap) {
    uint32_t grSet = psw_get_reg_set(&age->gpc.cpu.psw);
    for (int i = 0; i <= 7; i++) {
        snap->r[i] = register_get32(registerfile_r(&age->gpc.cpu.regFiles[grSet], i));
    }
    for (int i = 0; i <= 7; i++) {
        snap->fp[i] = register_get32(registerfile_r(&age->gpc.cpu.regFiles[2], i));
    }
    snap->nia = psw_get_nia(&age->gpc.cpu.psw);
    snap->cc = psw_get_cc(&age->gpc.cpu.psw);
    snap->psw1 = register_get32(&age->gpc.cpu.psw.psw1);
    snap->psw2 = register_get32(&age->gpc.cpu.psw.psw2);
}

int ageharness_diff_regs(const RegSnapshot *before, const RegSnapshot *after, RegChange *out) {
    int n = 0;
    for (int i = 0; i <= 7; i++) {
        if (before->r[i] != after->r[i]) {
            snprintf(out[n].name, sizeof out[n].name, "R0%d", i);
            out[n].oldVal = before->r[i];
            out[n].newVal = after->r[i];
            n++;
        }
    }
    for (int i = 0; i <= 7; i++) {
        if (before->fp[i] != after->fp[i]) {
            snprintf(out[n].name, sizeof out[n].name, "FP%d", i);
            out[n].oldVal = before->fp[i];
            out[n].newVal = after->fp[i];
            n++;
        }
    }
    if (before->nia != after->nia) {
        snprintf(out[n].name, sizeof out[n].name, "NIA");
        out[n].oldVal = before->nia;
        out[n].newVal = after->nia;
        n++;
    }
    if (before->cc != after->cc) {
        snprintf(out[n].name, sizeof out[n].name, "CC");
        out[n].oldVal = before->cc;
        out[n].newVal = after->cc;
        n++;
    }
    if (before->psw1 != after->psw1) {
        snprintf(out[n].name, sizeof out[n].name, "PSW1");
        out[n].oldVal = before->psw1;
        out[n].newVal = after->psw1;
        n++;
    }
    if (before->psw2 != after->psw2) {
        snprintf(out[n].name, sizeof out[n].name, "PSW2");
        out[n].oldVal = before->psw2;
        out[n].newVal = after->psw2;
        n++;
    }
    return n;
}

void ageharness_reset(AGEHarness *age) {
    age->stepCount = 0;
    ap101_reset(&age->gpc);

    age->halUCP.waitingForInput = false;
    age->halUCP.hasPendingIocode = false;
    age->halUCP.skipTrap = false;
    age->halUCP.wasRunning = false;
    age->halUCP.svcTrapped = false;
    age->halUCP.active = false;

    if (age->hasInitial) {
        ageharness_configure_from_opts(age, age->initialFcmPath, &age->initialOpts, NULL);
    }
}
