#include "ageharness.h"
#include "discretes.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "compat.h"
#include "json.h"

#include "envcache.h"
static bool load_state(AGEHarness *age, const char *path, bool verbose);

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

/* Just the C9FB/C6C6 content -- no protection. Split out from ipl_fill()
 * below because BILDNEW5/GPCIPL's own self-test explicitly checks for
 * this fill pattern (confirmed by tracing: a sequence around GPCIPL+1820
 * reads a memory location and does `CHI 3,X'c9fb'` / `CHI 3,X'c6c6'`,
 * branching differently depending on which it finds), so a real Power-On
 * boot -- distinct from IPL's blanket *protection*, see opts.h's powerOn
 * comment -- still needs this content present or that check takes a path
 * self-test was never validated against. This does NOT by itself resolve
 * the SVCPWAIT spin at GPCIPL+1831 both --power-on and --ipl eventually
 * reach: that check reads the OLD SVC PSW save slot (hw 0x58, part of
 * the interrupt-vector table) to see whether an SVC/program-check has
 * ever fired yet, and SVCPWAIT (SSM X'1e85' then a self-branch) is a
 * genuine wait-for-first-interrupt construct, unmasking Clock 1 and the
 * IOP Program interrupt (EX2) specifically (X'1e85' & the low byte used
 * as intMask, per cpu_check_interrupts' 0x80/0x04 tests). Neither ever
 * fires in a standalone run with no real or emulated peripheral attached
 * and no counter ever armed (ICR "Write Counter" is never reached
 * either) -- --ipl only appears to get past this because its own
 * artificial barrage of store-protect program checks happens to write a
 * real value into that same hw 0x58 slot as a side effect, satisfying
 * the check by accident. This looks like it's waiting on real I/O
 * hardware (MEDS et al.) to be present, matching that Don Schmidt's own
 * working demo starts MEDS before gpc -- see --bce-network. */
static void mem_pattern_fill(AGEHarness *age) {
    uint32_t total = age->gpc.ram.totalHWCount;
    uint32_t split = 0x20000;
    if (split > total) split = total;
    for (uint32_t hw = 0; hw < split; hw++) {
        membus_set16(&age->gpc.ram, hw, 0xc9fb, false);
    }
    for (uint32_t hw = split; hw < total; hw++) {
        membus_set16(&age->gpc.ram, hw, 0xc6c6, false);
    }
}

/* Real AP-101S cold IPL's own memory-initialization step -- see opts.h's
 * ipl comment for the full primary-source citation
 * (AP-101S-instruction-set.txt Sec. 2.5.3.3 "IPL"). Runs before load_fcm()
 * so the loaded image's own content (written via membus_load16's
 * unchecked writes) overlays this fill -- matching real hardware, where
 * IPL's fill+protect happens first and the program image is loaded on
 * top, still protected, left for the program's own bootstrap (ISPB calls
 * driven by a table like BILDNEW5's $POFF/$PON-generated UNPRT) to
 * selectively unprotect whatever it needs to write. */
/* Storage protection as a loader leaves it.
 *
 * Store powers up unprotected (Sec. 2.5.3.1 gives Power-On no protection
 * step of its own -- the blanket protect belongs to IPL, Sec. 2.5.3.3).
 * Protection is then what the loader asserts over what it has LOADED, so
 * the loaded extents end up protected and everything else -- scratch,
 * buffers, the PSA -- does not.
 *
 * Booting a composed image at Power-On skips the loader that would have
 * done that, so assert it here from the section map the symbol file
 * carries.  Both of the alternatives are wrong in a way GPCIPL notices:
 * protect nothing and the Instruction Monitor fires the moment the
 * software sets PSW mask bit 34, because every instruction then appears
 * to be executing out of unprotected storage; protect everything (what
 * --ipl does) and GPCIPL's own error logging faults writing into
 * sector-1/ENVIRONS scratch that no loader would ever have protected. */
/* YAGPC_IPL_PROTECT selects what --ipl's initial fill protects:
 *   (unset)    every halfword, then the PSA carve-out -- the default.
 *   "0"        nothing.  REFUTED: the Instruction Monitor fires as soon as
 *              the software sets PSW mask bit 34, and boot dies at nia=0.
 *   "sections" nothing up front, then apply_load_protection() over the
 *              symbol file's sections after the image is in store -- the
 *              middle option, standing in for the loader that would have
 *              protected only what it wrote.  Needs --symbols.
 * Regions no load block covers stay protected forever under the default,
 * and #PCVNMMU (FIOMUWB2's staging buffer) is exactly such a region --
 * yet PHASE02.sym.json's own storeProtect map excludes it. */
static const char *ipl_protect_mode(void) {
    const char *e = yagpc_getenv("YAGPC_IPL_PROTECT");
    return e != NULL ? e : "all";
}
static bool ipl_protect_all(void) {
    const char *m = ipl_protect_mode();
    return !(m[0] == '0' || strcmp(m, "sections") == 0);
}
static bool ipl_protect_sections(void) {
    return strcmp(ipl_protect_mode(), "sections") == 0;
}

static long apply_load_protection(AGEHarness *age) {
    long n = 0;
    for (int i = 0; i < age->sym.sectionCount; i++) {
        const Section *s = &age->sym.sections[i];
        if (s->size == 0) continue;
        for (uint32_t a = s->address; a < s->address + s->size; a++) {
            membus_set_store_protect(&age->gpc.ram, a, true);
            n++;
        }
    }
    return n;
}

static void ipl_fill(AGEHarness *age) {
    uint32_t total = age->gpc.ram.totalHWCount;
    mem_pattern_fill(age);
    /* YAGPC_IPL_PROTECT=0 starts memory UNPROTECTED instead.  Blanket
     * protection here leaves any region no load block covers protected
     * forever: #PCVNMMU (FIOMUWB2's CDHV_BLOCKS staging buffer) is
     * allocated by the link but carries no data extent, so it gets no
     * load block, and FCMINSSL's DMA into it is then silently refused --
     * words vanish between wordsOut and wordsTaken and the SSL hangs.
     * On the --ipl path the real loader runs and applies each load
     * block's own protect flag, so code still ends up protected. */
    {
        for (uint32_t hw = 0; hw < total; hw++) {
            membus_set_store_protect(&age->gpc.ram, hw, ipl_protect_all());
        }
    }

    /* PSA locations the manual (AP-101S-instruction-set.txt Sec. 2.5.2,
     * "Preferred Storage Area (PSA) Assignments") names as "must not be
     * store protected" -- a permanent hardware carve-out, not something
     * a program has to unprotect for itself: hardware itself writes
     * these constantly (every interrupt dispatch saves the old PSW;
     * every Clock 1/2 underflow reloads from the counter halfwords).
     * Confirmed necessary, not just documented: without this carve-out,
     * BILDNEW5/GPCIPL's own very first interrupt-vector-table
     * initialization pass (walking through the old-PSW slots at
     * addresses 0x60-0xA6) trips a store-protect violation on its very
     * first write, before it has ever had a chance to run its own
     * $POFF/$PON-driven unprotect sweep -- turning what should be
     * ordinary early-boot bookkeeping into an unrecoverable interrupt
     * loop. */
    static const uint32_t oldPswVectors[] = {
        0x00, /* Power off interrupt PSW */
        0x40, /* Machine Check */
        0x48, /* Program Check */
        0x58, /* SVC */
        0x60, /* Clock 1 */
        0x68, /* Clock 2 */
        0x70, /* Instruction Monitor */
        0x78, /* EX0 */
        0x80, /* EX1 */
        0x88, /* EX2 */
        0x90, /* EX3 */
        0x98, /* EX4 */
    };
    for (size_t i = 0; i < sizeof(oldPswVectors) / sizeof(oldPswVectors[0]); i++) {
        for (uint32_t hw = oldPswVectors[i]; hw < oldPswVectors[i] + 4 && hw < total; hw++) {
            membus_set_store_protect(&age->gpc.ram, hw, false);
        }
    }
    struct { uint32_t start, end; } psaRanges[] = {
        {0x00a4, 0x00a5}, /* BCE 25 processor storage */
        {0x00b0, 0x00b1}, /* Counter 1 & 2 high halfword */
        {0x00c0, 0x0102}, /* Putaway locations */
        {0x0104, 0x013f}, /* Diagnostics */
    };
    for (size_t i = 0; i < sizeof(psaRanges) / sizeof(psaRanges[0]); i++) {
        for (uint32_t hw = psaRanges[i].start; hw <= psaRanges[i].end && hw < total; hw++) {
            membus_set_store_protect(&age->gpc.ram, hw, false);
        }
    }
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
    age->halUCP.svcEnabled = opts->halucpSvc;
    age->halUCP.formatNumBlanks = atoi(opts->halucpFormatNumBlanks);
    /* Leave at halucp_init's sentinel (-1, meaning "use the per-channel
     * PAGED/UNPAGED default") unless the user explicitly overrode it --
     * see halucp.c's effective_line_width(). */
    if (opts->lineWidthSet) age->halUCP.lineWidth = atoi(opts->lineWidth);
    age->gpc.cpu.fcosMode = opts->fcos;
    /* Discrete-input overrides, before anything reads them.  These set the
     * LOCAL value only; a bit an external publisher drives still wins, so
     * --discretes and a crew panel behave exactly as before. */
    if (opts->discreteA)
        iop_set_discrete_in(&age->gpc.iop, DISCRETES_REG_A,
                            (uint32_t)strtoul(opts->discreteA, NULL, 16));
    if (opts->discreteB)
        iop_set_discrete_in(&age->gpc.iop, DISCRETES_REG_B,
                            (uint32_t)strtoul(opts->discreteB, NULL, 16));
    /* --timing; see timing.h.  Validated in opts_parse(), so anything
     * other than "pass2" here is the section-17 default. */
    age->gpc.cpu.timingPass2 = (strcmp(opts->timing, "pass2") == 0);
    /* DATE()/CLOCKTIME() wall-clock anchor -- see cpu.h's own
     * dateTimeAnchorEpochSec comment and opts.h's --date-time-epoch.
     * Unset (NULL): the real host machine's own current wall-clock time
     * at this exact moment (program start, for all practical purposes --
     * this runs once, immediately after argv parsing), which is why this
     * lives here (the CLI's own default) rather than in cpu_init() (a
     * fixed, deterministic 0 there, so direct/embedded/test construction
     * of an AGEHarness/CPU -- e.g. every test_schedule.c scenario -- is
     * never affected by what real day/time it happens to run on). */
    age->gpc.cpu.dateTimeAnchorEpochSec = opts->dateTimeEpoch ? atof(opts->dateTimeEpoch) : (double)time(NULL);

    char *autoSymbols = NULL;
    const char *symbolsPath = opts->symbols;
    if (!symbolsPath && fcmPath) {
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
    } else if (hasSymEntry && !opts->ipl && !opts->powerOn) {
        /* Excluded under --ipl/--power-on: the linker's own "entry point"
         * is just the load address of the first CSECT (0x0 for BILDNEW5/
         * GPCIPL) -- a link-time bookkeeping value, not a real boot
         * vector. A real system reset (performed by both IPL and Power-
         * On -- AP-101S-instruction-set.txt Sec. 2.5.3.3/2.5.3.1) never
         * starts execution there: it loads the CPU's *entire* PSW pair
         * (address, mask, BSR/DSR, everything) from a fixed vector --
         * see cpu_reset() below and BILDNEW5.lst's own SRESINTN constant
         * ("SYSTEM RESET = START UP ENTRY POINT", address 0x14). Leaving
         * hasEntryPoint false here under --ipl/--power-on (falling
         * through to cpu_reset() after load_fcm(), below) is what makes
         * that happen; --start still explicitly overrides it either way,
         * same as without either flag. */
        entryPoint = symEntry;
        hasEntryPoint = true;
    }

    /* --ipl's blanket *protection* is IPL-specific (Sec. 2.5.3.3), not a
     * Power-On property (Sec. 2.5.3.1) -- see opts.h's powerOn comment.
     * The C9FB/C6C6 fill *content* itself, though, is confirmed needed
     * either way -- see mem_pattern_fill()'s own comment. */
    /* No .fcm at all: nothing is loaded and nothing is filled here.  The
     * machine comes up held in reset with empty store, exactly as a GPC
     * whose power is on but which has not been IPLed -- and it is the
     * panel's IPL that fills memory and reads the bootstrap in, because
     * that is the step which does so on the vehicle (Table 2-2 step 10).
     * Doing any of it here would be inventing an IPL nobody commanded. */
    if (!fcmPath) {
        if (out) {
            out->byteCount = 0;
            out->hasEntryPoint = false;
            out->entryPoint = 0;
        }
        free(autoSymbols);
        return;
    }
    if (opts->ipl) ipl_fill(age);
    else if (opts->powerOn) mem_pattern_fill(age);
    long byteCount = load_fcm(age, fcmPath);
    /* After the image is in store, not before: this stands in for the
     * loader that would have protected what it wrote.  --ipl already
     * protected everything up front, so it does not want this. */
    if ((opts->powerOn && !opts->ipl) || (opts->ipl && ipl_protect_sections())) {
        long protectedHW = apply_load_protection(age);
        if (opts->verbose) {
            printf("Load protection: %ld halfword(s) over %d section(s)\n",
                   protectedHW, age->sym.sectionCount);
        }
    }
    if (hasEntryPoint) {
        ageharness_set_entry_point(age, entryPoint);
    } else if (opts->ipl || opts->powerOn) {
        /* Confirmed necessary, not just theoretically correct: without
         * this, BILDNEW5/GPCIPL starts executing at address 0 -- itself
         * PSA data (BILDNEW5.lst: "RESERVED", "SKFBDPAR", "SPWRONN",
         * "RESERVE1"), not code -- and immediately wanders into the
         * interrupt-vector table (0x40-0x9F) as if it were instructions.
         * Under --ipl that also trips a store-protect violation on
         * essentially the first real write, looping forever in the
         * resulting program-check handler since nothing has been
         * unprotected yet either; --power-on's own memory starts
         * unprotected so it wouldn't fault the same way, but it would
         * still be executing PSA data as instructions, which is just as
         * wrong. Loading the real start-up PSW instead lands on GPCIPL's
         * actual first instruction.
         *
         * WHICH start-up PSW depends on which reset this is, and they are
         * NOT the same vector -- see cpu_power_on()'s comment for the
         * Figure 2-20 / PSA.asm evidence. --ipl performs a system reset
         * function (Sec. 2.5.3.3) and takes the System Reset vector at
         * 0x14 (SRESINTN -> IOPHISAM, BILDNEW5.lst address 0x013F);
         * --power-on takes the Power On vector at 0x04 (SPWRONN ->
         * FAILEXEC). --ipl still wins if both are given. */
        if (opts->ipl) {
            cpu_reset(&age->gpc.cpu);
            /* An IPL leaves interval timer 1 RUNNING, and the bootstrap
             * depends on it.
             *
             * FCMBOOT's first act after the system reset is a two-second
             * settling delay -- "DELAY 2 SECONDS TO ALLOW THE MODE SWITCH
             * TO STABILIZE" -- timed by reading the PC1 clock:
             *
             *     LA  R6,62
             *     XR  R4,R4 / ICR R5,R4      READ PC1 CLOCK
             *     S   R5,FCMBEXPT            F'32259', and its own comment
             *                                says "32259 * 62 = 2 SECONDS"
             *     ICR R4,R4 / SR R4,R5 / N R4,FCMBIT16 / BC
             *
             * which is a 1 MHz down-counter tested for borrow on IBM bit
             * 16 -- exactly counter 1 as cpu_advance_time_us() models it.
             * It never STARTS the counter, only reads it, so something
             * before it must have: the POO makes Load/Start/Stop Counter 1
             * separate ICR functions, so these do not free-run.  That
             * something is the firmware IPL itself -- PASS User's Guide
             * Table 2-2 step 10, "GPC IPL - P/R ... Fixed pattern stored
             * in memory ...; Bootstrap loader read in from MMU" -- the
             * same microcode that reads the bootstrap off the tape.
             *
             * We do not emulate that microcode, so without this FCMBOOT
             * spins in the delay forever: measured, 300,000 steps visiting
             * only the four instructions of the inner loop, with its outer
             * count of 62 never once decrementing.
             *
             * This is a MODEL OF ASSUMED FIRMWARE BEHAVIOUR, not something
             * the POO states.  It is under --ipl alone because that is the
             * flag standing in for the IPL pushbutton; the HALT->STBY
             * release in run.c does not restart anything, matching 3.2's
             * "released from the RESET state". */
            age->gpc.cpu.counter1Enabled = true;
        } else cpu_power_on(&age->gpc.cpu);
        /* Report the real, now-established entry point (rather than
         * leaving hasEntryPoint/entryPoint as their "nothing set yet"
         * defaults) so batchrunner_load()'s own "No entry point" check
         * (run.c) doesn't misread a real cpu_reset()-driven boot as an
         * unconfigured one, and so --verbose's "Start:" line reports
         * where execution actually begins. */
        entryPoint = psw_get_nia(&age->gpc.cpu.psw);
        hasEntryPoint = true;
    }

    /* LAST, deliberately: after the image, after --start, and after any
     * --ipl/--power-on reset, so a captured state wins over the reset
     * vector instead of being overwritten by it. */
    if (opts->state != NULL && load_state(age, opts->state, opts->verbose)) {
        entryPoint = psw_get_nia(&age->gpc.cpu.psw);
        hasEntryPoint = true;
    }

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

bool ageharness_init_minimal(AGEHarness *age, const char *fcmPath, const char *symbolsPath,
                              double startEpochSeconds) {
    ageharness_init(age);
    load_fcm(age, fcmPath); /* exits(1) on hard failure -- see header comment */
    if (symbolsPath) {
        uint32_t entryPoint = 0;
        if (load_symbols(age, symbolsPath, false, &entryPoint)) {
            ageharness_set_entry_point(age, entryPoint);
        }
    }
    age->gpc.cpu.dateTimeAnchorEpochSec = startEpochSeconds;
    return true;
}


/* --state: the CPU state a memory image does NOT carry.
 *
 * A .fcm is memory and nothing else.  Flight software resumed from one
 * stops dead, because the machine it was dumped from also had a PSW (mask
 * bits, condition code, and the BSR/DSR bank and segment registers) and
 * eight live general registers.  Measured on OI340700: entering
 * corrected-SSW.fcm at FCMINIOP -- the address the reference tape's own
 * handover actually uses -- stops after ONE instruction in "wait state
 * (masked)", because --start sets the NIA and leaves everything else at
 * its default.  The real handover is PSW1=8dca4031 PSW2=000c0000, i.e.
 * CC=1, BSR=3, DSR=1, with R0=41000000 R2=40000000 R3=86200000 ...
 *
 * Capture a state with --break <addr> (its "FINAL REGISTERS" block is
 * exactly these fields) and replay it here.  Numbers may be JSON numbers
 * or hex strings; "r" and "fp" are 8-element arrays, both optional.
 * Applied AFTER the image load and after any --ipl/--power-on reset, so
 * it overrides the reset vector rather than racing it. */
static uint32_t state_word(const JsonValue *v, uint32_t dflt) {
    if (v == NULL) return dflt;
    if (v->type == JSON_STRING) {
        const char *t = json_as_string(v, NULL);
        if (t == NULL) return dflt;
        return (uint32_t)strtoul(t, NULL, 16);
    }
    if (v->type == JSON_NUMBER) return (uint32_t)json_as_number(v, dflt);
    return dflt;
}

static bool load_state(AGEHarness *age, const char *path, bool verbose) {
    FILE *f = fopen(path, "rb");
    if (f == NULL) {
        fprintf(stderr, "--state: cannot open %s\n", path);
        return false;
    }
    fseek(f, 0, SEEK_END);
    long n = ftell(f);
    fseek(f, 0, SEEK_SET);
    char *text = malloc((size_t)n + 1);
    if (text == NULL || fread(text, 1, (size_t)n, f) != (size_t)n) {
        fprintf(stderr, "--state: cannot read %s\n", path);
        free(text); fclose(f); return false;
    }
    text[n] = 0;
    fclose(f);
    JsonValue *root = json_parse(text);
    free(text);
    if (root == NULL) {
        fprintf(stderr, "--state: %s is not valid JSON\n", path);
        return false;
    }
    JsonValue *p1 = json_obj_get(root, "psw1");
    JsonValue *p2 = json_obj_get(root, "psw2");
    if (p1 != NULL || p2 != NULL) {
        uint32_t w1 = state_word(p1, 0), w2 = state_word(p2, 0);
        cpu_load_psw(&age->gpc.cpu, w1, w2);
        if (verbose)
            fprintf(stderr, "--state: PSW1=%08x PSW2=%08x NIA=%05x\n",
                    w1, w2, psw_get_nia(&age->gpc.cpu.psw));
    }
    uint32_t grSet = psw_get_reg_set(&age->gpc.cpu.psw);
    JsonValue *r = json_obj_get(root, "r");
    for (int i = 0; i < 8 && json_arr_count(r) > i; i++)
        register_set32(registerfile_r(&age->gpc.cpu.regFiles[grSet], i),
                       state_word(json_arr_get(r, i), 0));
    JsonValue *fp = json_obj_get(root, "fp");
    for (int i = 0; i < 8 && json_arr_count(fp) > i; i++)
        register_set32(registerfile_r(&age->gpc.cpu.regFiles[2], i),
                       state_word(json_arr_get(fp, i), 0));
    /* AFTER "r", deliberately.  "rsets" carries BOTH general sets and is
     * the better source; "r" only ever held the one the PSW selected, so
     * where both are present the complete pair wins and where only the old
     * key is present nothing changes. */
    JsonValue *rs = json_obj_get(root, "rsets");
    for (int set = 0; set < 2 && json_arr_count(rs) > set; set++) {
        JsonValue *one = json_arr_get(rs, set);
        for (int i = 0; i < 8 && json_arr_count(one) > i; i++)
            register_set32(registerfile_r(&age->gpc.cpu.regFiles[set], i),
                           state_word(json_arr_get(one, i), 0));
    }
    /* The Data Sector Extensions extend every address their general
     * register forms, so getting these wrong does not fault -- it
     * addresses the wrong sector and carries on. */
    JsonValue *ds = json_obj_get(root, "dse");
    for (int set = 0; set < 3 && json_arr_count(ds) > set; set++) {
        JsonValue *one = json_arr_get(ds, set);
        for (int i = 0; i < 8 && json_arr_count(one) > i; i++)
            age->gpc.cpu.regFiles[set].dse[i] =
                (uint8_t)(state_word(json_arr_get(one, i), 0) & 0xf);
    }
    /* A MACHINE YOU ARE RESUMING HAD ITS INTERVAL TIMER RUNNING.  Counter 1
     * is a 1 MHz down-counter that the IPL firmware starts and nothing in
     * the software ever does -- see the --ipl comment above, which enables
     * it for exactly that reason.  A resume cannot take --ipl (its blanket
     * store protect faults the first STM), so without this the software
     * spins forever in FIOPC1DL: measured on corrected-G9.fcm, 55 million
     * steps visiting only 0x1a84d-0x1a851, the four instructions of the
     * delay loop.  "counter1": false in the JSON opts out. */
    /* The scheduling half -- see ageharness_dump_state's comment for why
     * each field has to travel.  elapsedTimeUs is restored BEFORE the IOP
     * section below, because the BCE deadlines there are absolute times
     * measured against this clock. */
    JsonValue *cs = json_obj_get(root, "cpu");
    if (cs != NULL) {
        CPU *c = &age->gpc.cpu;
        JsonValue *v;
        c->counter1 = state_word(json_obj_get(cs, "counter1"), c->counter1);
        c->counter2 = state_word(json_obj_get(cs, "counter2"), c->counter2);
        struct { const char *k; bool *p; } bs[] = {
            {"counter1Enabled", &c->counter1Enabled},
            {"counter2Enabled", &c->counter2Enabled},
            {"counter1Deferred", &c->counter1Deferred},
            {"counter2Deferred", &c->counter2Deferred},
        };
        for (size_t i = 0; i < sizeof bs / sizeof bs[0]; i++) {
            v = json_obj_get(cs, bs[i].k);
            if (v != NULL && v->type == JSON_BOOL) *bs[i].p = v->boolVal;
        }
        if ((v = json_obj_get(cs, "timerAccumUs")) != NULL)
            c->timerAccumUs = json_as_number(v, c->timerAccumUs);
        c->intCode = state_word(json_obj_get(cs, "intCode"), c->intCode);
        JsonValue *ip = json_obj_get(cs, "int");
        if (ip != NULL) {
            IntPending *q = &c->intPending;
            struct { const char *k; bool *p; } fl[] = {
                {"powerTransient", &q->powerTransient},
                {"systemReset", &q->systemReset}, {"ipl", &q->ipl},
                {"machineCheck", &q->machineCheck},
                {"programCheck", &q->programCheck}, {"svc", &q->svc},
                {"clk1", &q->clk1}, {"clk2", &q->clk2}, {"ext2", &q->ext2},
                {"instrMonitor", &q->instrMonitor}, {"ext3", &q->ext3},
                {"ext4", &q->ext4}, {"iopGrp1", &q->iopGrp1},
                {"iopGrp2", &q->iopGrp2}, {"iopProg", &q->iopProg},
                {"age", &q->age},
            };
            for (size_t i = 0; i < sizeof fl / sizeof fl[0]; i++) {
                v = json_obj_get(ip, fl[i].k);
                if (v != NULL && v->type == JSON_BOOL) *fl[i].p = v->boolVal;
            }
        }
        if (verbose)
            fprintf(stderr, "--state: clk1=%d clk2=%d c1=%08x c2=%08x t=%.3fs\n",
                    c->counter1Enabled, c->counter2Enabled,
                    c->counter1, c->counter2, c->elapsedTimeUs / 1e6);
    }

    /* The IOP half.  Restoring the CPU alone leaves every processor
     * enable at zero, so the machine executes correctly and drives no bus
     * at all -- which is precisely how corrected-G9.fcm looked when it was
     * running FPMDISP with the DEUs seeing nothing. */
    JsonValue *io_ = json_obj_get(root, "iop");
    if (io_ != NULL) {
        IOP *iop = &age->gpc.iop;
        struct { const char *k; Register *r; } regs[] = {
            {"halt", &iop->regHalt}, {"xmitEna", &iop->regXmitEna},
            {"recvEna", &iop->regRecvEna}, {"busyWait", &iop->regBusyWait},
            {"progExcept", &iop->regProgExcept},
            {"indicator", &iop->regIndicator},
            {"discreteOut", &iop->regDiscreteOut},
            {"rmStatus", &iop->regRMStatus},
            {"mscFailDisc", &iop->msc.regFailDisc},
            {"mscIntProg", &iop->msc.regIntProg},
        };
        for (size_t i = 0; i < sizeof regs / sizeof regs[0]; i++) {
            JsonValue *v = json_obj_get(io_, regs[i].k);
            if (v != NULL) register_set32(regs[i].r, state_word(v, 0));
        }
        JsonValue *v;
        if ((v = json_obj_get(io_, "curPE")) != NULL)
            iop->curPE = (int)json_as_number(v, iop->curPE);
        if ((v = json_obj_get(io_, "slice")) != NULL)
            iop->ls.slice = (int)json_as_number(v, iop->ls.slice);
        if ((v = json_obj_get(io_, "curBCE")) != NULL)
            iop->ls.curBCE = (int)json_as_number(v, iop->ls.curBCE);
        if ((v = json_obj_get(io_, "curPage")) != NULL)
            iop->ls.curPage = (int)json_as_number(v, iop->ls.curPage);
        JsonValue *ls = json_obj_get(io_, "ls");
        for (int pg = 0; pg < 26 && json_arr_count(ls) > pg; pg++) {
            JsonValue *page = json_arr_get(ls, pg);
            for (int w = 0; w < 16 && json_arr_count(page) > w; w++) {
                Register *r = iopls_at(&iop->ls, pg, w / 4, w % 4);
                if (r != NULL)
                    register_set32(r, state_word(json_arr_get(page, w), 0));
            }
        }
        JsonValue *bl = json_obj_get(io_, "bce");
        for (int i = 0; i < 24 && json_arr_count(bl) > i; i++) {
            JsonValue *e = json_arr_get(bl, i);
            BCE *b = &iop->bce[i];
            JsonValue *t;
            if ((t = json_obj_get(e, "delayActive")) != NULL)
                b->delayActive = t->type == JSON_BOOL ? t->boolVal : false;
            b->delayPC = state_word(json_obj_get(e, "delayPC"), b->delayPC);
            if ((t = json_obj_get(e, "recvActive")) != NULL)
                b->recvActive = t->type == JSON_BOOL ? t->boolVal : false;
            b->recvPC = state_word(json_obj_get(e, "recvPC"), b->recvPC);
            b->recvAddr = state_word(json_obj_get(e, "recvAddr"), b->recvAddr);
            b->recvLeft = state_word(json_obj_get(e, "recvLeft"), b->recvLeft);
            if ((t = json_obj_get(e, "recvGotAny")) != NULL)
                b->recvGotAny = t->type == JSON_BOOL ? t->boolVal : false;
            b->mia.latch = state_word(json_obj_get(e, "latch"), b->mia.latch);
            if ((t = json_obj_get(e, "latchValid")) != NULL)
                b->mia.latchValid = t->type == JSON_BOOL ? t->boolVal : false;
            /* Rebased onto THIS run's clock: a deadline is only
             * meaningful as "how much longer", never as the absolute
             * value it had on the captured machine. */
            if ((t = json_obj_get(e, "delayRemainUs")) != NULL)
                b->delayUntilUs = age->gpc.cpu.elapsedTimeUs
                                + json_as_number(t, 0.0);
            if ((t = json_obj_get(e, "recvElapsedUs")) != NULL)
                b->recvSinceUs = age->gpc.cpu.elapsedTimeUs
                               - json_as_number(t, 0.0);
            /* The nine that a capture taken before this simply did not
             * have.  Each defaults to what the freshly-built BCE already
             * holds, so an older file still loads and just leaves them
             * alone -- see the dump for why each has to travel. */
            struct { const char *k; bool *p; } bb[] = {
                {"recvAwaitCmd", &b->recvAwaitCmd},
                {"recvSkippedEcho", &b->recvSkippedEcho},
                {"recvErrored", &b->recvErrored},
                {"latchCmdSync", &b->mia.latchCmdSync},
                {"lastFromLatch", &b->mia.lastFromLatch},
                {"lastCmdSync", &b->mia.lastCmdSync},
            };
            for (size_t k = 0; k < sizeof bb / sizeof bb[0]; k++)
                if ((t = json_obj_get(e, bb[k].k)) != NULL && t->type == JSON_BOOL)
                    *bb[k].p = t->boolVal;
            if ((t = json_obj_get(e, "recvCount")) != NULL)
                b->recvCount = (long)json_as_number(t, (double)b->recvCount);
            /* Both rebased, for the same reason delayRemainUs is. */
            if ((t = json_obj_get(e, "wireHoldRemainUs")) != NULL)
                b->wireHoldUntilUs = age->gpc.cpu.elapsedTimeUs
                                   + json_as_number(t, 0.0);
            if ((t = json_obj_get(e, "rxNextRemainUs")) != NULL)
                b->mia.rxNextUs = age->gpc.cpu.elapsedTimeUs
                                + json_as_number(t, 0.0);
        }
        /* THE REST OF THE IOP -- see the dump for what each of these is
         * and why it cannot be reconstructed.  Every one defaults to what
         * the freshly-built IOP holds, so a capture taken before they were
         * written still loads and simply leaves them at their reset
         * values, which is exactly the old behaviour. */
        {
            double now = age->gpc.cpu.elapsedTimeUs;
            JsonValue *t;
            struct { const char *k; bool *p; } fb[] = {
                {"wdRunning", &iop->wdRunning}, {"wdTimeout", &iop->wdTimeout},
                {"rmVoterInhibit", &iop->rmVoterInhibit},
                {"rmVoterFail", &iop->rmVoterFail},
                {"intForceTest", &iop->intForceTest},
                {"parityEnabled", &iop->parityEnabled},
                {"forceHBusParity", &iop->forceHBusParity},
                {"forceQueueParity", &iop->forceQueueParity},
                {"forceDMAParity", &iop->forceDMAParity},
                {"forceMIAParity", &iop->forceMIAParity},
                {"mscRepeatActive", &iop->mscRepeatActive},
            };
            for (size_t k = 0; k < sizeof fb / sizeof fb[0]; k++)
                if ((t = json_obj_get(io_, fb[k].k)) != NULL && t->type == JSON_BOOL)
                    *fb[k].p = t->boolVal;
            iop->wdCount = state_word(json_obj_get(io_, "wdCount"), iop->wdCount);
            iop->msc.failDiscSeen = state_word(json_obj_get(io_, "mscFailDiscSeen"),
                                               iop->msc.failDiscSeen);
            iop->rmTestInputs = state_word(json_obj_get(io_, "rmTestInputs"),
                                           iop->rmTestInputs);
            iop->mscRepeatPC = state_word(json_obj_get(io_, "mscRepeatPC"),
                                          iop->mscRepeatPC);
            if ((t = json_obj_get(io_, "wdAccumUs")) != NULL)
                iop->wdAccumUs = json_as_number(t, iop->wdAccumUs);
            /* Rebased, as every other deadline is. */
            if ((t = json_obj_get(io_, "wdSinceLastUs")) != NULL)
                iop->wdLastUs = now - json_as_number(t, 0.0);
            if ((t = json_obj_get(io_, "mscRepeatRemainUs")) != NULL)
                iop->mscRepeatUntilUs = now + json_as_number(t, 0.0);
            if ((t = json_obj_get(io_, "ccData")) != NULL)
                register_set32(&iop->regCCData, state_word(t, 0));
            JsonValue *ia = json_obj_get(io_, "interrupts");
            for (int i = 0; i < 5 && json_arr_count(ia) > i; i++)
                register_set32(registerfile_r(&iop->regInterrupts, i),
                               state_word(json_arr_get(ia, i), 0));
            JsonValue *lb = json_obj_get(io_, "lsBadParity");
            for (int i = 0; i < 26 && json_arr_count(lb) > i; i++)
                iop->lsBadParity[i] = state_word(json_arr_get(lb, i), 0);
            JsonValue *bf = json_obj_get(io_, "busFreeRemainUs");
            for (int i = 0; i < 32 && json_arr_count(bf) > i; i++)
                iop->busFreeUs[i] = now + json_as_number(json_arr_get(bf, i), 0.0);
            JsonValue *xw = json_obj_get(io_, "xmitWords");
            for (int i = 0; i < 32 && json_arr_count(xw) > i; i++)
                iop->xmitWords[i] = (long)json_as_number(json_arr_get(xw, i), 0.0);
            JsonValue *dq = json_obj_get(io_, "dmaQueuedRead");
            for (int i = 0; i < 32 && json_arr_count(dq) > i; i++)
                iop->dmaQueuedRead[i] = (long)json_as_number(json_arr_get(dq, i), 0.0);
            JsonValue *cw = json_obj_get(io_, "clearWatch");
            for (int i = 0; i < 32 && json_arr_count(cw) > i; i++)
                iop->clearWatch[i] = (int)json_as_number(json_arr_get(cw, i), 0.0);
            /* IN ORDER, head first: the dump walks the ring from head, so
             * pushing them back in the order written restores the queue
             * the machine actually had rather than a permutation of it. */
            JsonValue *dma = json_obj_get(io_, "dma");
            for (int i = 0; i < json_arr_count(dma); i++) {
                JsonValue *e = json_arr_get(dma, i);
                iop_dma_queue_restore(
                    iop, state_word(json_obj_get(e, "addr"), 0),
                    (int)json_as_number(json_obj_get(e, "dir"), 0.0),
                    (int)json_as_number(json_obj_get(e, "bce"), -1.0));
            }
        }
        if (verbose)
            fprintf(stderr, "--state: IOP halt=%08x xmit=%08x recv=%08x\n",
                    (unsigned)register_get32(&iop->regHalt),
                    (unsigned)register_get32(&iop->regXmitEna),
                    (unsigned)register_get32(&iop->regRecvEna));
    }

    const char *pp = json_as_string(json_obj_get(root, "protect"), NULL);
    if (pp != NULL) {
        /* BESIDE THE STATE FILE FIRST.  A snapshot is moved after it is
         * written, so a path recorded at capture time need not exist any
         * more; the one thing that is always true is that the map sits next
         * to the .json that names it.  An older capture recorded a full
         * path, so that is still tried -- but second, because a stale one
         * may also still exist and belong to a different capture. */
        char ppPath[700];
        const char *base = strrchr(pp, '/');
        base = (base != NULL) ? base + 1 : pp;
        const char *slash = strrchr(path, '/');
        if (slash != NULL)
            snprintf(ppPath, sizeof ppPath, "%.*s/%s",
                     (int)(slash - path), path, base);
        else
            snprintf(ppPath, sizeof ppPath, "%s", base);
        FILE *pf = fopen(ppPath, "rb");
        if (pf == NULL && strcmp(ppPath, pp) != 0) pf = fopen(pp, "rb");
        if (pf == NULL) {
            /* NOT A WARNING.  A machine restored without its protection map
             * runs, answers nothing, and looks like a restore that half
             * worked -- which is how this was found. */
            fprintf(stderr, "--state: CANNOT OPEN THE PROTECT MAP (%s beside "
                            "%s, nor %s).  Refusing to resume: without it the "
                            "Instruction Monitor faults on every instruction "
                            "and the computer will run and answer nothing.\n",
                    base, path, pp);
            json_free(root);
            exit(1);
        }
        {
            uint32_t hw = (uint32_t)json_as_number(
                json_obj_get(root, "protectHalfwords"),
                age->gpc.cpu.mainStorage.wordCount * 2.0);
            uint32_t nprot = 0;
            int byte = 0;
            for (uint32_t a = 0; a < hw; a++) {
                if ((a & 7) == 0) {
                    byte = fgetc(pf);
                    if (byte == EOF) break;
                }
                bool v = (byte & (0x80 >> (a & 7))) != 0;
                membus_set_store_protect(age->gpc.cpu.ram, a, v);
                if (v) nprot++;
            }
            fclose(pf);
            if (verbose)
                fprintf(stderr, "--state: %u halfword(s) store-protected\n",
                        nprot);
        }
    }

    JsonValue *c1 = json_obj_get(root, "counter1");
    age->gpc.cpu.counter1Enabled =
        (c1 == NULL || c1->type != JSON_BOOL) ? true : c1->boolVal;

    if (verbose)
        fprintf(stderr, "--state: %d general, %d floating register(s) from %s\n",
                json_arr_count(r) < 0 ? 0 : json_arr_count(r),
                json_arr_count(fp) < 0 ? 0 : json_arr_count(fp), path);
    json_free(root);
    return true;
}


/* --dump-state: the other half of --state.
 *
 * A .fcm is memory only.  Everything below is machine state that lives
 * OUTSIDE main storage and is therefore absent from any memory image:
 *
 *   - the CPU's PSW pair and its general/floating registers;
 *   - counter 1's enable, started by IPL firmware and never by software;
 *   - the IOP's processor enables.  regHalt bit 0 is the MSC and bits
 *     1-24 are BCE 1-24, and a processor RUNS when its bit is SET, so a
 *     zero here means no bus traffic at all however good the image is.
 *     The MIA transmit/receive enables are separate again (FCMINIOP sets
 *     them from TFCMXMSK/TFCMRMSK, not by CONFIGURE PROCESSORS), so both
 *     have to travel or a BCE comes up enabled but mute;
 *   - the IOP local store, 26 pages of 16 registers -- page 0 the MSC,
 *     1-24 the BCEs, 25 the diagnostic processor.  Each BCE's PROGRAM
 *     COUNTER lives here, not in main storage, so without it a restored
 *     BCE resumes from nowhere;
 *   - each BCE's in-flight delay and commanded-receive state, which is
 *     keyed by PC and holds the processor mid-instruction.
 *
 * Written when the run stops, so `--break <addr> --dump-state f.json`
 * captures a transition exactly. */
bool ageharness_dump_state(AGEHarness *age, const char *path) {
    FILE *f = fopen(path, "w");
    if (f == NULL) {
        fprintf(stderr, "--dump-state: cannot write %s\n", path);
        return false;
    }
    CPU *cpu = &age->gpc.cpu;
    IOP *iop = &age->gpc.iop;
    uint32_t grSet = psw_get_reg_set(&cpu->psw);
    fprintf(f, "{\n");
    fprintf(f, "  \"psw1\": \"%08x\",\n", register_get32(&cpu->psw.psw1));
    fprintf(f, "  \"psw2\": \"%08x\",\n", register_get32(&cpu->psw.psw2));
    fprintf(f, "  \"counter1\": %s,\n", cpu->counter1Enabled ? "true" : "false");
    fprintf(f, "  \"r\": [");
    for (int i = 0; i < 8; i++)
        fprintf(f, "%s\"%08x\"", i ? ", " : "",
                register_get32(registerfile_r(&cpu->regFiles[grSet], i)));
    fprintf(f, "],\n  \"fp\": [");
    for (int i = 0; i < 8; i++)
        fprintf(f, "%s\"%08x\"", i ? ", " : "",
                register_get32(registerfile_r(&cpu->regFiles[2], i)));
    fprintf(f, "],\n");
    /* BOTH GENERAL REGISTER SETS, AND THE DSE REGISTERS.
     *
     * "r" above is regFiles[grSet] -- whichever set the PSW selects right
     * now -- so the OTHER one was never written and a restored machine got
     * it zeroed.  The AP-101S has two and the software switches between
     * them; a capture taken with set 1 active silently discarded set 0.
     *
     * The DSE registers are worse than merely missing.  There are eight,
     * one 4-bit Data Sector Extension per general register, loaded by LXA
     * and LDM (regmem.h), and they EXTEND EVERY ADDRESS those registers
     * form.  A machine restored with them zeroed does not fail: it
     * addresses the wrong sector and keeps going.
     *
     * "r" and "fp" stay exactly as they were so that captures taken before
     * this still load; these are additions, not a replacement. */
    fprintf(f, "  \"rsets\": [");
    for (int set = 0; set < 2; set++) {
        fprintf(f, "%s[", set ? ", " : "");
        for (int i = 0; i < 8; i++)
            fprintf(f, "%s\"%08x\"", i ? ", " : "",
                    register_get32(registerfile_r(&cpu->regFiles[set], i)));
        fprintf(f, "]");
    }
    fprintf(f, "],\n  \"dse\": [");
    for (int set = 0; set < 3; set++) {
        fprintf(f, "%s[", set ? ", " : "");
        for (int i = 0; i < 8; i++)
            fprintf(f, "%s%u", i ? ", " : "",
                    (unsigned)cpu->regFiles[set].dse[i]);
        fprintf(f, "]");
    }
    fprintf(f, "],\n");
    /* THE SCHEDULING STATE.  FCOS runs on the interval timers, so a
     * machine restored without them completes whatever transfer was in
     * flight and then issues no further START I/O -- measured: 2 DEU
     * commands and then silence.  All of it lives outside main storage:
     *
     *   - counter 1 and counter 2, the two 16-bit 1 MHz hardware
     *     down-counters, with their enables and their deferred-borrow
     *     flags.  (Their HIGH halfwords are in main store at 0x00B0 and
     *     0x00B1, so the image carries those.)
     *   - timerAccumUs, the sub-microsecond remainder between ticks.
     *   - elapsedTimeUs.  This one is not a nicety: the BCE delay and
     *     commanded-receive fields below are ABSOLUTE simulated times, so
     *     restoring them onto a clock that restarts at zero puts every
     *     deadline impossibly far in the future and the BCE waits for
     *     ever.  It is also what DATE()/CLOCKTIME() read off.
     *   - the pending-interrupt latches, since a timer interrupt raised
     *     but not yet taken is exactly what a capture can land on. */
    fprintf(f, "  \"cpu\": {\n");
    fprintf(f, "    \"counter1\": \"%08x\", \"counter2\": \"%08x\",\n",
            cpu->counter1, cpu->counter2);
    fprintf(f, "    \"counter1Enabled\": %s, \"counter2Enabled\": %s,\n",
            cpu->counter1Enabled ? "true" : "false",
            cpu->counter2Enabled ? "true" : "false");
    fprintf(f, "    \"counter1Deferred\": %s, \"counter2Deferred\": %s,\n",
            cpu->counter1Deferred ? "true" : "false",
            cpu->counter2Deferred ? "true" : "false");
    fprintf(f, "    \"timerAccumUs\": %.6f,\n", cpu->timerAccumUs);
    /* INFORMATIONAL ONLY -- deliberately not restored.  rtpacer_init
     * takes its simStartUs baseline from this at start-up, so moving the
     * clock forward afterwards makes the pacer believe it owes that much
     * wall time and sleep through the entire run: measured, restoring
     * 109.2 s dropped a replay from 2 DEU commands to none.  What the
     * BCE deadlines actually need is how much longer to wait, which is
     * what delayRemainUs/recvElapsedUs carry instead. */
    fprintf(f, "    \"capturedAtUs\": %.3f,\n", cpu->elapsedTimeUs);
    fprintf(f, "    \"intCode\": \"%08x\",\n", cpu->intCode);
    fprintf(f, "    \"int\": {");
    {
        const IntPending *ip = &cpu->intPending;
        struct { const char *k; bool v; } fl[] = {
            {"powerTransient", ip->powerTransient}, {"systemReset", ip->systemReset},
            {"ipl", ip->ipl}, {"machineCheck", ip->machineCheck},
            {"programCheck", ip->programCheck}, {"svc", ip->svc},
            {"clk1", ip->clk1}, {"clk2", ip->clk2}, {"ext2", ip->ext2},
            {"instrMonitor", ip->instrMonitor}, {"ext3", ip->ext3},
            {"ext4", ip->ext4}, {"iopGrp1", ip->iopGrp1},
            {"iopGrp2", ip->iopGrp2}, {"iopProg", ip->iopProg},
            {"age", ip->age},
        };
        for (size_t i = 0; i < sizeof fl / sizeof fl[0]; i++)
            fprintf(f, "%s\"%s\": %s", i ? ", " : "", fl[i].k,
                    fl[i].v ? "true" : "false");
    }
    fprintf(f, "}\n  },\n");
    fprintf(f, "  \"iop\": {\n");
    fprintf(f, "    \"halt\": \"%08x\",\n", register_get32(&iop->regHalt));
    fprintf(f, "    \"xmitEna\": \"%08x\",\n", register_get32(&iop->regXmitEna));
    fprintf(f, "    \"recvEna\": \"%08x\",\n", register_get32(&iop->regRecvEna));
    fprintf(f, "    \"busyWait\": \"%08x\",\n", register_get32(&iop->regBusyWait));
    fprintf(f, "    \"progExcept\": \"%08x\",\n", register_get32(&iop->regProgExcept));
    fprintf(f, "    \"indicator\": \"%08x\",\n", register_get32(&iop->regIndicator));
    fprintf(f, "    \"discreteOut\": \"%08x\",\n", register_get32(&iop->regDiscreteOut));
    fprintf(f, "    \"rmStatus\": \"%08x\",\n", register_get32(&iop->regRMStatus));
    fprintf(f, "    \"mscFailDisc\": \"%08x\",\n", register_get32(&iop->msc.regFailDisc));
    fprintf(f, "    \"mscIntProg\": \"%08x\",\n", register_get32(&iop->msc.regIntProg));
    fprintf(f, "    \"curPE\": %d,\n", iop->curPE);
    fprintf(f, "    \"slice\": %d,\n", iop->ls.slice);
    fprintf(f, "    \"curBCE\": %d,\n", iop->ls.curBCE);
    fprintf(f, "    \"curPage\": %d,\n", iop->ls.curPage);
    fprintf(f, "    \"ls\": [");
    for (int pg = 0; pg < 26; pg++) {
        fprintf(f, "%s\n      [", pg ? "," : "");
        for (int w = 0; w < 16; w++) {
            Register *r = iopls_at(&iop->ls, pg, w / 4, w % 4);
            fprintf(f, "%s\"%08x\"", w ? ", " : "",
                    r == NULL ? 0u : register_get32(r));
        }
        fprintf(f, "]");
    }
    fprintf(f, "\n    ],\n    \"bce\": [");
    for (int i = 0; i < 24; i++) {
        const BCE *b = &iop->bce[i];
        fprintf(f, "%s\n      {\"delayActive\": %s, \"delayPC\": \"%08x\", "
                   "\"recvActive\": %s, \"recvPC\": \"%08x\", "
                   "\"recvAddr\": \"%08x\", \"recvLeft\": \"%08x\", "
                   "\"recvGotAny\": %s, \"latch\": \"%08x\", "
                   "\"latchValid\": %s, \"delayRemainUs\": %.3f, "
                   "\"recvElapsedUs\": %.3f, "
                   /* THE OTHER NINE, and none of them is optional.  The
                    * first six put the BCE somewhere in the middle of a
                    * commanded receive that recvActive alone does not
                    * describe: recvAwaitCmd and recvSkippedEcho are the
                    * Listen/Command Mode first-input state, recvErrored
                    * says the transfer has already failed, recvCount is
                    * how much of it has arrived, and a restored BCE
                    * without them either re-reads a word it has had or
                    * reports a clean transfer that was not.  The last
                    * three are the wire: wireHoldUntilUs is a bus busy
                    * until a simulated time, rxNextUs is the MIA's 33 us
                    * receive pacing, and latchCmdSync/lastFromLatch/
                    * lastCmdSync are the echo and sync-mark latches that
                    * tell a commanded receive its own transmission from
                    * somebody else's.  All four times are DURATIONS from
                    * the capture, as delayRemainUs already is -- see the
                    * rebase in load_state. */
                   "\"recvAwaitCmd\": %s, \"recvSkippedEcho\": %s, "
                   "\"recvErrored\": %s, \"recvCount\": %ld, "
                   "\"wireHoldRemainUs\": %.3f, \"rxNextRemainUs\": %.3f, "
                   "\"latchCmdSync\": %s, \"lastFromLatch\": %s, "
                   "\"lastCmdSync\": %s}",
                i ? "," : "",
                b->delayActive ? "true" : "false", b->delayPC,
                b->recvActive ? "true" : "false", b->recvPC,
                b->recvAddr, b->recvLeft,
                b->recvGotAny ? "true" : "false",
                b->mia.latch, b->mia.latchValid ? "true" : "false",
                b->delayUntilUs - cpu->elapsedTimeUs,
                cpu->elapsedTimeUs - b->recvSinceUs,
                b->recvAwaitCmd ? "true" : "false",
                b->recvSkippedEcho ? "true" : "false",
                b->recvErrored ? "true" : "false",
                (long)b->recvCount,
                b->wireHoldUntilUs - cpu->elapsedTimeUs,
                b->mia.rxNextUs - cpu->elapsedTimeUs,
                b->mia.latchCmdSync ? "true" : "false",
                b->mia.lastFromLatch ? "true" : "false",
                b->mia.lastCmdSync ? "true" : "false");
    }
    fprintf(f, "\n    ],\n");

    /* THE REST OF THE IOP THAT LIVES OUTSIDE MAIN STORAGE.
     *
     * Found by diffing the IOP struct against what this function wrote,
     * rather than from a list: the list was short by the MSC's repeat-until
     * state, which holds the MSC mid-instruction exactly as a BCE's
     * delayActive holds a BCE, and that one was already being dumped.
     *
     * Each of these is state no memory image can carry:
     *
     *   - the GO/NO-GO WATCHDOG, a real counter that keeps running through
     *     the CPU's wait state because noticing a stopped CPU is its whole
     *     job.  Restored without it, a machine either never times out or
     *     times out immediately depending on which way the zero falls;
     *   - the RM VOTER's inhibit and test inputs, which arrive by LOAD TEST
     *     REGISTER and are not readable back from regRMStatus -- only its
     *     bits 17-18 live there, the rest is composed at read time;
     *   - regInterrupts, five registers holding what has been raised and
     *     not yet taken, and intForceTest;
     *   - the DATA FLOW PARITY state.  Checking starts disabled and an
     *     error leaves it disabled with the generators reset, so the enable
     *     is a latch with real consequences; lsBadParity tags which stored
     *     words arrived over a poisoned H-Bus, and the tag survives a read;
     *   - busFreeUs, when each wire comes free, and the MSC's repeat-until;
     *   - xmitWords, dmaQueuedRead and clearWatch, which are per-bus
     *     positions WITHIN a command in progress -- how much has gone out,
     *     what was queued, and whether the next MIA read is the CLEAR read.
     *     A restored machine that loses clearWatch reads a stale status.
     *
     * DELIBERATELY NOT HERE: discOverlayGen/Driven/Value (a memo, rebuilt
     * on the next publish), recvTimeoutFloorUs and recvFloorFromEnv (from
     * the command line), and servicer/peerWait and their contexts (host
     * wiring, restored by construction, and saving a function pointer
     * across processes would be a latent crash). */
    fprintf(f, "    \"wdCount\": %u, \"wdRunning\": %s, \"wdTimeout\": %s,\n",
            iop->wdCount, iop->wdRunning ? "true" : "false",
            iop->wdTimeout ? "true" : "false");
    fprintf(f, "    \"wdAccumUs\": %.3f, \"wdSinceLastUs\": %.3f,\n",
            iop->wdAccumUs, cpu->elapsedTimeUs - iop->wdLastUs);
    fprintf(f, "    \"rmVoterInhibit\": %s, \"rmTestInputs\": %u, "
               "\"rmVoterFail\": %s,\n",
            iop->rmVoterInhibit ? "true" : "false", iop->rmTestInputs,
            iop->rmVoterFail ? "true" : "false");
    /* failDiscSeen is a WORD, not a flag -- one bit per fail discrete
     * already noticed -- so it travels as one.  Dumping it as a boolean
     * would have restored "some bit was set" as "bit 31 was set". */
    fprintf(f, "    \"intForceTest\": %s, \"mscFailDiscSeen\": \"%08x\",\n",
            iop->intForceTest ? "true" : "false",
            (unsigned)iop->msc.failDiscSeen);
    fprintf(f, "    \"ccData\": \"%08x\",\n", register_get32(&iop->regCCData));
    fprintf(f, "    \"interrupts\": [");
    for (int i = 0; i < 5; i++)
        fprintf(f, "%s\"%08x\"", i ? ", " : "",
                register_get32(registerfile_r(&iop->regInterrupts, i)));
    fprintf(f, "],\n");
    fprintf(f, "    \"parityEnabled\": %s, \"forceHBusParity\": %s, "
               "\"forceQueueParity\": %s, \"forceDMAParity\": %s, "
               "\"forceMIAParity\": %s,\n",
            iop->parityEnabled ? "true" : "false",
            iop->forceHBusParity ? "true" : "false",
            iop->forceQueueParity ? "true" : "false",
            iop->forceDMAParity ? "true" : "false",
            iop->forceMIAParity ? "true" : "false");
    fprintf(f, "    \"lsBadParity\": [");
    for (int i = 0; i < 26; i++)
        fprintf(f, "%s\"%08x\"", i ? ", " : "", iop->lsBadParity[i]);
    fprintf(f, "],\n");
    fprintf(f, "    \"mscRepeatActive\": %s, \"mscRepeatPC\": \"%08x\", "
               "\"mscRepeatRemainUs\": %.3f,\n",
            iop->mscRepeatActive ? "true" : "false", iop->mscRepeatPC,
            iop->mscRepeatUntilUs - cpu->elapsedTimeUs);
    /* Per bus.  busFreeUs is a time and so travels as a duration; the
     * other three are counts and positions and travel as they are. */
    fprintf(f, "    \"busFreeRemainUs\": [");
    for (int i = 0; i < 32; i++)
        fprintf(f, "%s%.3f", i ? ", " : "", iop->busFreeUs[i] - cpu->elapsedTimeUs);
    fprintf(f, "],\n    \"xmitWords\": [");
    for (int i = 0; i < 32; i++)
        fprintf(f, "%s%ld", i ? ", " : "", iop->xmitWords[i]);
    fprintf(f, "],\n    \"dmaQueuedRead\": [");
    for (int i = 0; i < 32; i++)
        fprintf(f, "%s%ld", i ? ", " : "", iop->dmaQueuedRead[i]);
    fprintf(f, "],\n    \"clearWatch\": [");
    for (int i = 0; i < 32; i++)
        fprintf(f, "%s%d", i ? ", " : "", iop->clearWatch[i]);
    fprintf(f, "],\n");
    /* THE DMA QUEUE, which is a transfer in flight and not a statistic.
     * It is drained one halfword per IOP slice and has been measured 819
     * deep during a 511-word display fill, so a capture taken during one
     * -- and a display fill is exactly when a capture is interesting --
     * holds most of that fill in here and nowhere else. */
    fprintf(f, "    \"dma\": [");
    for (int i = 0; i < iop->dmaQueue.count; i++) {
        const DMARequest *q = &iop->dmaQueue.items[
            (iop->dmaQueue.head + i) % iop->dmaQueue.cap];
        fprintf(f, "%s{\"addr\": \"%08x\", \"dir\": %d, \"bce\": %d}",
                i ? ", " : "", q->addr, (int)q->direction,
                q->bce ? q->bce->bceNum : -1);
    }
    fprintf(f, "]\n  },\n");   /* closes "iop" */
    /* STORE PROTECTION, and it is not an optimisation.  The Instruction
     * Monitor fires on any instruction fetched from an UNPROTECTED
     * address (cpu.c: intMask & 0x20 && !membus_get_store_protect), so a
     * machine resumed with no protection map trips it on EVERY
     * instruction.  Measured: the replay logged FCOS error X'0503' --
     * FPMIHIM.asm's FPMIMGC, "INST. MON. GRP-CODE" -- through FPMERLOG
     * continuously and never got back to dispatching.  --ipl's blanket
     * protect is not a substitute; that faults the first legitimate
     * store instead.  One bit per halfword, packed, in a companion file
     * because it is 512 K halfwords. */
    {
        uint32_t hw = (uint32_t)(cpu->mainStorage.wordCount * 2);
        char pp[600];
        snprintf(pp, sizeof pp, "%s.protect.bin", path);
        FILE *pf = fopen(pp, "wb");
        if (pf != NULL) {
            uint8_t byte = 0;
            uint32_t nprot = 0;
            for (uint32_t a = 0; a < hw; a++) {
                bool v = membus_get_store_protect(cpu->ram, a);
                if (v) nprot++;
                byte = (uint8_t)((byte << 1) | (v ? 1 : 0));
                if ((a & 7) == 7) { fputc(byte, pf); byte = 0; }
            }
            if (hw & 7) fputc((uint8_t)(byte << (8 - (hw & 7))), pf);
            fclose(pf);
            /* THE NAME, NOT THE PATH.  This used to record `pp`, the path
             * the file was written at, and a snapshot is not written where
             * it ends up: the emulator writes to a staging directory and a
             * complete set is moved to wherever the save asked.  The
             * recorded path then pointed at a directory that had been
             * emptied, load_state could not open it, and the machine came
             * up with NO STORE PROTECTION -- which does not fail quietly.
             * See the Instruction Monitor note above: every instruction
             * fetched from an unprotected address faults, FCOS logs X'0503'
             * forever and never dispatches, so the computer is running and
             * answering nothing.  Recording the bare name and resolving it
             * beside the state file makes a snapshot relocatable, which it
             * has to be. */
            const char *ppName = strrchr(pp, '/');
            ppName = (ppName != NULL) ? ppName + 1 : pp;
            fprintf(f, "  \"protect\": \"%s\",\n", ppName);
            fprintf(f, "  \"protectHalfwords\": %u,\n", hw);
            fprintf(f, "  \"protectedHalfwords\": %u\n", nprot);
        } else {
            fprintf(f, "  \"protect\": null\n");
        }
    }
    fprintf(f, "}\n");
    fclose(f);
    fprintf(stderr, "--dump-state: wrote %s\n", path);
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

void ageharness_firmware_ipl(AGEHarness *age, const uint16_t *image,
                             uint32_t nHalfwords) {
    ipl_fill(age);
    uint32_t total = age->gpc.ram.totalHWCount;
    if (nHalfwords > total) nHalfwords = total;
    for (uint32_t i = 0; i < nHalfwords; i++) {
        membus_set16(&age->gpc.ram, i, image[i], false);
    }
    age->gpc.cpu.counter1Enabled = true;
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
