#include "opts.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Captured verbatim from `node dist/gpc.js run --help` so `yaGPC2 --help`
 * matches byte-for-byte. */
static const char *HELP_TEXT =
"Usage: gpc run [options] [<fcm-file>]\n"
"\n"
"Run an AP-101 program in batch mode\n"
"\n"
"Arguments:\n"
"  fcm-file                        FCM memory image to load.  Omit it to\n"
"                                  boot the way the machine does: the IPL\n"
"                                  pushbutton reads the bootstrap off the\n"
"                                  mass memory (needs --mmu-model and\n"
"                                  --discretes)\n"
"\n"
"Options:\n"
"  --start <addr>                  start address in hex\n"
"  --symbols <file>                load symbol table JSON from linker\n"
"  --ebcdic                        use EBCDIC encoding for character I/O\n"
"  --trap-svc-error                intercept HAL/S SEND ERROR SVCs (default)\n"
"                                  (default: true)\n"
"  --no-trap-svc-error             pass SEND ERROR SVCs to SVC handler\n"
"  --halucp-format-num-blanks <n>  blanks between WRITE output fields (default:\n"
"                                  5) (default: \"5\")\n"
"  --line-width <n>                WRITE line width for wrap, overriding the\n"
"                                  per-channel default (132 for PAGED\n"
"                                  channels, 80 for UNPAGED -- USA003090\n"
"                                  Sec. 6.1.4's default LRECL, less 1 non-\n"
"                                  printing byte on PAGED channels for the\n"
"                                  auto-generated ANSI/ASA carriage-control\n"
"                                  character)\n"
"  --infile0 <file>                read input for channel 0\n"
"  --outfile0 <file>               write output for channel 0\n"
"  --infile1 <file>                read input for channel 1\n"
"  --outfile1 <file>               write output for channel 1\n"
"  --infile2 <file>                read input for channel 2\n"
"  --outfile2 <file>               write output for channel 2\n"
"  --infile3 <file>                read input for channel 3\n"
"  --outfile3 <file>               write output for channel 3\n"
"  --infile4 <file>                read input for channel 4\n"
"  --outfile4 <file>               write output for channel 4\n"
"  --infile5 <file>                read input for channel 5\n"
"  --outfile5 <file>               write output for channel 5\n"
"  --infile6 <file>                read input for channel 6\n"
"  --outfile6 <file>               write output for channel 6\n"
"  --infile7 <file>                read input for channel 7\n"
"  --outfile7 <file>               write output for channel 7\n"
"  --max-steps <n>                 max instructions to execute (default:\n"
"                                  \"100000\")\n"
"  --break <addr>                  stop at halfword address (hex)\n"
"  --watch <spec>                  memory watchpoint: addr[:count] in hex\n"
"  --output <file>                 write trace/verbose output to file instead of\n"
"                                  stdout\n"
"  --dump-interval <n>             register dump every N steps (default: 100)\n"
"                                  (default: \"100\")\n"
"  --trace                         enable instruction trace (default: false)\n"
"  --no-trace                      disable instruction trace (default)\n"
"  --verbose                       print informational messages (default: false)\n"
"  --no-verbose                    suppress informational messages (default)\n"
"  --interactive                   interactive terminal I/O\n"
"  --watch-log                     log every watchpoint change instead of\n"
"                                  breaking (default: false)\n"
"  --fcos                          simulate specific known FCOS (Shuttle\n"
"                                  flight-software OS) behaviors that a\n"
"                                  standalone/no-OS program doesn't get\n"
"                                  (default: false)\n"
"  --no-fcos                       disable FCOS behavior simulation (default)\n"
"  --ipl                           simulate real AP-101S cold-IPL memory init\n"
"                                  (fill+protect, Sec 2.5.3.3) before loading\n"
"                                  (default: false)\n"
"  --no-ipl                        disable cold-IPL memory init (default)\n"
"  --power-on                      real AP-101S Power-On (Sec 2.5.3.1): system\n"
"                                  reset into the run state, with NO memory\n"
"                                  fill/protect step (unlike --ipl, whose\n"
"                                  blanket protect+fill is IPL-specific)\n"
"                                  (default: false)\n"
"  --no-power-on                   disable Power-On boot (default)\n"
"  --debug                         gdb-style interactive debugger (implies\n"
"                                  --interactive) (default: false)\n"
"  --no-debug                      disable the interactive debugger (default)\n"
"  --source-map <file>             HAL/S source-line map for --debug (see\n"
"                                  tools/gen_source_map.py)\n"
"  --timing <model>                instruction-timing model: \"poo\" (AP-101S\n"
"                                  Principles of Operation section 17, the\n"
"                                  hardware spec) or \"pass2\" (the HAL/S-FC\n"
"                                  compiler's own static estimate, kept for\n"
"                                  comparison) (default: \"poo\")\n"
"  --real-time                     pace execution at (approximately) real\n"
"                                  AP-101S speed, including through the wait\n"
"                                  state -- needed to drive a real peripheral\n"
"                                  over --bce-network (default: false)\n"
"  --rt-factor <x>                 real-time speed multiplier for --real-time\n"
"                                  (2 = 2x real speed) (default: 1)\n"
"  --rt-idle-timeout <ms>          give up on a --real-time wait state after\n"
"                                  this much wall time (default: 10000)\n"
"  --time-scale <factor>           wall-clock pacing divisor for SCHEDULE/WAIT\n"
"                                  real-time throttling (default: 1.0, genuine\n"
"                                  real time; factor > 0). A larger factor\n"
"                                  shrinks how long the CLI actually sleeps for\n"
"                                  a given HAL/S-seconds interval, without\n"
"                                  changing any SCHEDULE/WAIT tick arithmetic\n"
"                                  or program output at all (default: \"1.0\")\n"
"  --pacing <mode>                 wall-clock pacing implementation: burst\n"
"                                  (default) is the original burst-execute-\n"
"                                  then-sleep polling design; signal is an\n"
"                                  alternative POSIX/timer-notification-driven\n"
"                                  design, added for side-by-side comparison --\n"
"                                  both implement the same pacing contract and\n"
"                                  produce identical program output, only\n"
"                                  wall-clock jitter/precision differs. signal\n"
"                                  requires this build to have been compiled\n"
"                                  with POSIX real-time timer support; fails\n"
"                                  loudly at startup if not available\n"
"                                  (default: \"burst\")\n"
"  --date-time-epoch <seconds>     Unix epoch seconds (e.g. `date +%s`)\n"
"                                  overriding DATE()/CLOCKTIME()'s own\n"
"                                  wall-clock anchor for reproducible\n"
"                                  runs. Default: the real host machine's\n"
"                                  current wall-clock time (its own\n"
"                                  configured timezone) at program start.\n"
"  --mmu-model <volume>             Serve the mass memory bus from an\n"
"                                  IN-PROCESS model reading this .mmv tape,\n"
"                                  answering in the same call with no socket,\n"
"                                  no drops and no pacing -- so a run is\n"
"                                  reproducible.  Composes with --bce-network\n"
"                                  and --deu-model: only the mass memory bus\n"
"                                  is taken over (default: none)\n"
"  --mmu-unit <n>                   which mass memory the model is, 1 or 2\n"
"                                  (bus MM1/BCE 18 or MM2/BCE 19; default 1)\n"
"  --discrete-a <hex>              override discrete input A's local value\n"
"                                  (default 0A000000: MM1 IPL source, MM1\n"
"                                  ready).  Bits anyone publishes on the\n"
"                                  discretes bus still win over this.\n"
"  --discrete-b <hex>              override discrete input B's local value\n"
"                                  (default 21000000: GPC 1, CRT 1).  Clear\n"
"                                  bits 6-7 for NO CRT selected, which is\n"
"                                  what makes it a non-menu IPL.\n"
"  --discretes                      Subscribe to the discrete-input bus, so a\n"
"                                  mass memory asserting its own READY, or the\n"
"                                  crew panel in yaShuttle/discretePanel/,\n"
"                                  drives this machine's discrete registers.\n"
"                                  Bits nobody publishes keep the value derived\n"
"                                  for them (default: false)\n"
"  --bce-network                    Install the real-peripheral servicer\n"
"  --deu-model                      Install an IN-PROCESS display unit instead\n"
"                                  of the network one: same protocol, no socket,\n"
"                                  answers in the same call.  A diagnostic -- it\n"
"                                  makes a run deterministic so traces can be\n"
"                                  compared (default: false)\n"
"                                  bridge (multicast UDP, matching\n"
"                                  nsts-sim-gpc's own wire protocol) so\n"
"                                  BCE bus traffic can reach a real\n"
"                                  peripheral emulator (e.g. Don Schmidt's\n"
"                                  MEDS) instead of the inert MIA stub.\n"
"                                  (default: false)\n"
"  -h, --help                      display help for command\n";

static void set_defaults(Options *o) {
    memset(o, 0, sizeof(*o));
    o->trapSvcError = true;
    o->halucpFormatNumBlanks = "5";
    o->lineWidth = "132";
    o->maxSteps = "100000";
    o->dumpInterval = "100";
    o->timeScale = "1.0";
    o->pacing = "burst";
    o->timing = "poo";
    o->realTime = false;
    o->rtFactor = "1";
    o->rtIdleTimeout = "10000";
}

/* JS parseInt(s, 16) applied after stripping a leading "0x"/"0X" — matches
 * cmd_run.coffee's parseHex and IOHost/AGEHarness's addr parsing. Parses as
 * many leading hex digits as present; non-hex-digit or empty -> 0 (this
 * mirrors the common-case inputs; pathological garbage inputs are not a
 * priority per the port plan). */
static long parse_hex_opt(const char *s) {
    if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X')) s += 2;
    return strtol(s, NULL, 16);
}

static void unknown_option(const char *tok) {
    fprintf(stderr, "error: unknown option '%s'\n", tok);
    exit(1);
}

static void missing_value(const char *tok) {
    fprintf(stderr, "error: option '%s' argument missing\n", tok);
    exit(1);
}

/* Returns the value for an option token that may be "--opt value" (value is
 * argv[*i+1], consumed) or "--opt=value" (embedded, no consumption). */
static char *take_value(int argc, char **argv, int *i, const char *tok, size_t nameLen) {
    if (tok[nameLen] == '=') return (char *)(tok + nameLen + 1);
    if (*i + 1 >= argc) missing_value(tok);
    (*i)++;
    return argv[*i];
}

static bool tok_is(const char *tok, const char *name, size_t *nameLen) {
    size_t len = strlen(name);
    if (strncmp(tok, name, len) != 0) return false;
    if (tok[len] == '\0' || tok[len] == '=') {
        *nameLen = len;
        return true;
    }
    return false;
}

static void add_watch(Options *o, const char *spec) {
    char buf[256];
    strncpy(buf, spec, sizeof(buf) - 1);
    buf[sizeof(buf) - 1] = '\0';
    char *colon = strchr(buf, ':');
    long count = 1;
    if (colon) {
        *colon = '\0';
        count = strtol(colon + 1, NULL, 10);
    }
    o->watch = realloc(o->watch, (o->watchCount + 1) * sizeof(WatchSpec));
    o->watch[o->watchCount].addr = parse_hex_opt(buf);
    o->watch[o->watchCount].count = count;
    o->watchCount++;
}

void opts_parse(int argc, char **argv, Options *opts) {
    set_defaults(opts);

    int start = 1;
    if (start < argc && strcmp(argv[start], "run") == 0) start++;

    char *positional[2] = {0};
    int positionalCount = 0;

    for (int i = start; i < argc; i++) {
        char *tok = argv[i];
        size_t n;

        if (strcmp(tok, "-h") == 0 || strcmp(tok, "--help") == 0) {
            fputs(HELP_TEXT, stdout);
            exit(0);
        } else if (tok_is(tok, "--start", &n)) {
            opts->start = take_value(argc, argv, &i, tok, n);
        } else if (tok_is(tok, "--symbols", &n)) {
            opts->symbols = take_value(argc, argv, &i, tok, n);
        } else if (tok_is(tok, "--ebcdic", &n)) {
            (void)n; opts->ebcdic = true;
        } else if (tok_is(tok, "--trap-svc-error", &n)) {
            (void)n; opts->trapSvcError = true;
        } else if (tok_is(tok, "--no-trap-svc-error", &n)) {
            (void)n; opts->trapSvcError = false;
        } else if (tok_is(tok, "--halucp-format-num-blanks", &n)) {
            opts->halucpFormatNumBlanks = take_value(argc, argv, &i, tok, n);
        } else if (tok_is(tok, "--line-width", &n)) {
            opts->lineWidth = take_value(argc, argv, &i, tok, n);
            opts->lineWidthSet = true;
        } else if (tok_is(tok, "--max-steps", &n)) {
            opts->maxSteps = take_value(argc, argv, &i, tok, n);
        } else if (tok_is(tok, "--break", &n)) {
            opts->breakAddr = take_value(argc, argv, &i, tok, n);
        } else if (tok_is(tok, "--watch", &n)) {
            add_watch(opts, take_value(argc, argv, &i, tok, n));
        } else if (tok_is(tok, "--output", &n)) {
            opts->outputPath = take_value(argc, argv, &i, tok, n);
        } else if (tok_is(tok, "--dump-interval", &n)) {
            opts->dumpInterval = take_value(argc, argv, &i, tok, n);
        } else if (tok_is(tok, "--trace", &n)) {
            (void)n; opts->trace = true;
        } else if (tok_is(tok, "--no-trace", &n)) {
            (void)n; opts->trace = false;
        } else if (tok_is(tok, "--verbose", &n)) {
            (void)n; opts->verbose = true;
        } else if (tok_is(tok, "--no-verbose", &n)) {
            (void)n; opts->verbose = false;
        } else if (tok_is(tok, "--fcos", &n)) {
            (void)n; opts->fcos = true;
        } else if (tok_is(tok, "--no-fcos", &n)) {
            (void)n; opts->fcos = false;
        } else if (tok_is(tok, "--discrete-a", &n)) {
            opts->discreteA = take_value(argc, argv, &i, tok, n);
        } else if (tok_is(tok, "--discrete-b", &n)) {
            opts->discreteB = take_value(argc, argv, &i, tok, n);
        } else if (tok_is(tok, "--ipl", &n)) {
            (void)n; opts->ipl = true;
        } else if (tok_is(tok, "--no-ipl", &n)) {
            (void)n; opts->ipl = false;
        } else if (tok_is(tok, "--power-on", &n)) {
            (void)n; opts->powerOn = true;
        } else if (tok_is(tok, "--no-power-on", &n)) {
            (void)n; opts->powerOn = false;
        } else if (tok_is(tok, "--interactive", &n)) {
            (void)n; opts->interactive = true;
        } else if (tok_is(tok, "--watch-log", &n)) {
            (void)n; opts->watchLog = true;
        } else if (tok_is(tok, "--debug", &n)) {
            (void)n; opts->debug = true;
        } else if (tok_is(tok, "--no-debug", &n)) {
            (void)n; opts->debug = false;
        } else if (tok_is(tok, "--source-map", &n)) {
            opts->sourceMap = take_value(argc, argv, &i, tok, n);
        } else if (tok_is(tok, "--time-scale", &n)) {
            opts->timeScale = take_value(argc, argv, &i, tok, n);
        } else if (tok_is(tok, "--pacing", &n)) {
            opts->pacing = take_value(argc, argv, &i, tok, n);
        } else if (tok_is(tok, "--real-time", &n)) {
            opts->realTime = true;
        } else if (tok_is(tok, "--rt-factor", &n)) {
            opts->rtFactor = take_value(argc, argv, &i, tok, n);
            if (atof(opts->rtFactor) <= 0.0) {
                fprintf(stderr, "error: --rt-factor must be > 0 (got '%s')\n", opts->rtFactor);
                exit(1);
            }
        } else if (tok_is(tok, "--rt-idle-timeout", &n)) {
            opts->rtIdleTimeout = take_value(argc, argv, &i, tok, n);
        } else if (tok_is(tok, "--timing", &n)) {
            opts->timing = take_value(argc, argv, &i, tok, n);
            if (strcmp(opts->timing, "poo") != 0 && strcmp(opts->timing, "pass2") != 0) {
                fprintf(stderr, "error: --timing must be \"poo\" or \"pass2\"\n");
                exit(1);
            }
        } else if (tok_is(tok, "--date-time-epoch", &n)) {
            opts->dateTimeEpoch = take_value(argc, argv, &i, tok, n);
        } else if (tok_is(tok, "--bce-network", &n)) {
            (void)n; opts->bceNetwork = true;
        } else if (tok_is(tok, "--deu-model", &n)) {
            (void)n; opts->deuModel = true;
        } else if (tok_is(tok, "--discretes", &n)) {
            (void)n; opts->discretes = true;
        } else if (tok_is(tok, "--mmu-model", &n)) {
            opts->mmuModelVolume = take_value(argc, argv, &i, tok, n);
        } else if (tok_is(tok, "--mmu-unit", &n)) {
            opts->mmuModelUnit = take_value(argc, argv, &i, tok, n);
        } else {
            bool matched = false;
            for (int ch = 0; ch < OPTS_NUM_CHANNELS && !matched; ch++) {
                char name[16];
                snprintf(name, sizeof(name), "--infile%d", ch);
                if (tok_is(tok, name, &n)) {
                    opts->infile[ch] = take_value(argc, argv, &i, tok, n);
                    matched = true;
                    break;
                }
                snprintf(name, sizeof(name), "--outfile%d", ch);
                if (tok_is(tok, name, &n)) {
                    opts->outfile[ch] = take_value(argc, argv, &i, tok, n);
                    matched = true;
                    break;
                }
            }
            if (matched) continue;

            if (tok[0] == '-' && tok[1] != '\0') {
                unknown_option(tok);
            }
            if (positionalCount < 2) positional[positionalCount] = tok;
            positionalCount++;
        }
    }

    if (positionalCount == 0) {
        /* No image named.  That is the real machine's own arrangement:
         * the microcode reads the bootstrap off the mass memory when the
         * IPL pushbutton is pressed, so an fcm-file is what a run
         * SUBSTITUTES for that, not something a run must have.  But there
         * has to be a tape to read, and a panel to press IPL on. */
        /* Either mass memory will do: the in-process model, or a real
         * one on the far end of --bce-network.  The IPL reads it through
         * the installed servicer and does not care which. */
        if (!opts->mmuModelVolume && !opts->bceNetwork) {
            fprintf(stderr,
                "error: no 'fcm-file', so the bootstrap must come from a "
                "mass memory -- give --mmu-model VOLUME.mmv, or "
                "--bce-network to read a real one\n");
            exit(1);
        }
        if (!opts->discretes) {
            fprintf(stderr,
                "error: no 'fcm-file', so the run is driven from the crew "
                "panel -- give --discretes and press IPL, then STBY\n");
            exit(1);
        }
        opts->fcmPath = NULL;
        return;
    }
    if (positionalCount > 1) {
        fprintf(stderr,
            "error: too many arguments for 'run'. Expected 1 argument but got %d.\n",
            positionalCount);
        exit(1);
    }
    opts->fcmPath = positional[0];
}
