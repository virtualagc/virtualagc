#include "ageharness.h"
#include "discretes.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

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
    for (uint32_t hw = 0; hw < total; hw++) {
        membus_set_store_protect(&age->gpc.ram, hw, true);
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
    if (opts->powerOn && !opts->ipl) {
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
