/*
 * ODYSSEY-AGC -- Filename: tests/diff/diff_harness.c
 * Purpose: Milestone 4 evidence.  A deterministic harness that drives one or
 *          two AGC instances through scripted IMU/CDU/gyro/PIPA activity and
 *          prints a fingerprint of everything observable.  It uses ONLY public
 *          engine API and public agc_t fields, so the SAME source is compiled
 *          against both:
 *            - the frozen pristine upstream engine  (tests/baseline/), and
 *            - the modified engine                   (yaAGC/agc_engine.c).
 *
 * What the tests prove (see tests/run_isolation_tests.sh):
 *   1. DIFFERENTIAL: a single instance behaves bit-identically on the
 *      pristine and the modified engine.
 *   2. INTERFERENCE: two instances interleaved at single-cycle granularity
 *      each reproduce their own solo-run fingerprint -- on the modified
 *      engine.  The same test run on the PRISTINE engine is expected to FAIL
 *      (shared statics), which shows the test can actually detect the hazard.
 *   3. RESET: re-initialising one instance mid-run does not disturb the other,
 *      and the re-initialised instance behaves like a fresh one.
 *
 * usage:
 *   diff_harness ROM solo  A|B STEPS
 *   diff_harness ROM inter CHUNK STEPS
 *   diff_harness ROM reset CHUNK STEPS RESET_AT
 * Output (one line per instance):
 *   <A|B> steps=N hash=H state=S n174=.. n175=.. n176=.. n177=..
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <inttypes.h>
#include "yaAGC.h"
#include "agc_engine.h"

typedef struct
{
  agc_t agc;
  uint64_t logh;            /* hash of every ChannelOutput call            */
  uint64_t nout[4];         /* counts for channels 0174..0177              */
  uint32_t rng;             /* per-instance deterministic PRNG state       */
  uint64_t n;               /* local step counter (drives the script)      */
  int which;                /* 0 = A, 1 = B                                */
} inst_t;

static inst_t inst[2];

#define FNV_OFFSET 1469598103934665603ULL
#define FNV_PRIME 1099511628211ULL

static uint64_t
fnv (uint64_t h, uint64_t v)
{
  int i;
  for (i = 0; i < 8; i++)
    {
      h ^= (v >> (8 * i)) & 0xFF;
      h *= FNV_PRIME;
    }
  return h;
}

static uint32_t
rnd (inst_t *p)
{
  uint32_t x = p->rng;
  x ^= x << 13;
  x ^= x >> 17;
  x ^= x << 5;
  return p->rng = x;
}

/* ---- the engine's link-time hooks, routed by agc_t pointer ---------------- */
static inst_t *
find (agc_t *S)
{
  return (S == &inst[0].agc) ? &inst[0] : (S == &inst[1].agc) ? &inst[1] : NULL;
}

void
ChannelOutput (agc_t *S, int Channel, int Value)
{
  inst_t *p = find (S);
  if (p == NULL)
    return;
  p->logh = fnv (p->logh, (uint64_t) Channel);
  p->logh = fnv (p->logh, (uint64_t) (unsigned) Value);
  p->logh = fnv (p->logh, S->CycleCounter);
  if (Channel >= 0174 && Channel <= 0177)
    p->nout[Channel - 0174]++;
}
int ChannelInput (agc_t *S) { (void) S; return 0; }
void ChannelRoutine (agc_t *S) { (void) S; }
void ShiftToDeda (agc_t *S, int D) { (void) S; (void) D; }
void RequestRadarData (agc_t *S) { (void) S; }
void BacktraceAdd (agc_t *S, int C) { (void) S; (void) C; }
void UnblockSocket (int N) { (void) N; }

/* ---- scripted activity ----------------------------------------------------
 * Both scripts hit: gyro pulse drive (ch 014 bit 01000 + RegGYROCTR), IMU CDU
 * coarse-alignment bursts (ch 014 bits 070000 + RegCDU{X,Y,Z}CMD), the CDU
 * input FIFOs (UnprogrammedIncrement on counters 032-034, all four increment
 * types) and the PIPA counters (037-041).  A and B use different timing,
 * values and PRNG seeds, so any cross-talk changes at least one fingerprint. */
static void
script (inst_t *p)
{
  agc_t *S = &p->agc;
  uint64_t n = p->n;
  int A = (p->which == 0);

  /* gyro torquing */
  if (n == (A ? 3000u : 5000u))
    {
      S->Erasable[0][RegGYROCTR] = A ? 300 : 700;
      S->InputChannel[014] |= 01000 | (A ? 0140 : 0600);
    }
  if (n == (A ? 120000u : 90000u))
    {
      S->Erasable[0][RegGYROCTR] = A ? 1500 : 450;
      S->InputChannel[014] |= 01000;
    }

  /* IMU CDU coarse-align drive */
  if (n == (A ? 40000u : 70000u))
    {
      S->Erasable[0][RegCDUXCMD] = A ? 0500 : 077777 - 0200;
      S->Erasable[0][RegCDUYCMD] = A ? 077777 - 0300 : 0700;
      S->Erasable[0][RegCDUZCMD] = A ? 0100 : 0333;
      S->InputChannel[014] |= 070000;
    }
  if (n == (A ? 150000u : 160000u))
    {
      S->Erasable[0][RegCDUXCMD] = A ? 077777 - 0700 : 0600;
      S->Erasable[0][RegCDUYCMD] = A ? 0250 : 077777 - 0111;
    }
  if (n == (A ? 220000u : 250000u))
    S->InputChannel[014] &= ~070000;

  /* CDU input FIFOs: all four increment types */
  if (n % (A ? 97u : 53u) == 0)
    {
      static const int types[4] = { 1, 3, 021, 023 };
      uint32_t r = rnd (p);
      UnprogrammedIncrement (S, 032 + (int) (r % 3), types[(r >> 8) & 3]);
    }
  /* PIPA counters */
  if (n % (A ? 211u : 149u) == 0)
    {
      uint32_t r = rnd (p);
      UnprogrammedIncrement (S, 037 + (int) (r % 3), (r & 0x100) ? 0 : 2);
    }
}

static int
boot (inst_t *p, int which, const char *rom)
{
  memset (p, 0, sizeof *p);               /* caller-zeroed, like ODYSSEY */
  p->which = which;
  p->logh = FNV_OFFSET;
  p->rng = which == 0 ? 0x1234567u : 0x7654321u;
  return agc_engine_init (&p->agc, rom, NULL, 0);
}

static void
step (inst_t *p)
{
  script (p);
  agc_engine (&p->agc);
  p->n++;
}

static void
report (inst_t *p)
{
  uint64_t s = FNV_OFFSET;
  int b, w;
  for (b = 0; b < 8; b++)
    for (w = 0; w < 0400; w++)
      s = fnv (s, (uint64_t) (uint16_t) p->agc.Erasable[b][w]);
  for (w = 0; w < NUM_CHANNELS; w++)
    s = fnv (s, (uint64_t) (unsigned) p->agc.InputChannel[w]);
  s = fnv (s, p->agc.CycleCounter);
  s = fnv (s, (uint64_t) (unsigned) p->agc.OutputChannel7);
  s = fnv (s, (uint64_t) p->agc.DskyChannel163);
  printf ("%c steps=%" PRIu64 " hash=%016" PRIx64 " state=%016" PRIx64
          " n174=%" PRIu64 " n175=%" PRIu64 " n176=%" PRIu64 " n177=%" PRIu64 "\n",
          p->which == 0 ? 'A' : 'B', p->n, p->logh, s, p->nout[0], p->nout[1],
          p->nout[2], p->nout[3]);
}

int
main (int argc, char **argv)
{
  const char *rom;
  const char *mode;

  if (argc < 4)
    {
      fprintf (stderr, "usage: %s ROM solo A|B STEPS | ROM inter CHUNK STEPS | "
               "ROM reset CHUNK STEPS RESET_AT\n", argv[0]);
      return 2;
    }
  rom = argv[1];
  mode = argv[2];

  if (!strcmp (mode, "solo") && argc == 5)
    {
      int which = (argv[3][0] == 'B');
      uint64_t steps = strtoull (argv[4], NULL, 10), i;
      if (boot (&inst[which], which, rom))
        return 3;
      for (i = 0; i < steps; i++)
        step (&inst[which]);
      report (&inst[which]);
      return 0;
    }

  if ((!strcmp (mode, "inter") && argc == 5) || (!strcmp (mode, "reset") && argc == 6))
    {
      uint64_t chunk = strtoull (argv[3], NULL, 10);
      uint64_t steps = strtoull (argv[4], NULL, 10), i, k;
      uint64_t reset_at = (argc == 6) ? strtoull (argv[5], NULL, 10) : 0;
      int do_reset = !strcmp (mode, "reset"), reset_done = 0;
      if (chunk == 0 || boot (&inst[0], 0, rom) || boot (&inst[1], 1, rom))
        return 3;
      for (i = 0; i < steps; i += chunk)
        {
          uint64_t c = (steps - i < chunk) ? steps - i : chunk;
          for (k = 0; k < c; k++)
            step (&inst[0]);
          for (k = 0; k < c; k++)
            step (&inst[1]);
          /* chunk-granular reset of A, once, at/after RESET_AT */
          if (do_reset && !reset_done && i + c >= reset_at)
            {
              if (boot (&inst[0], 0, rom))
                return 3;
              reset_done = 1;
            }
        }
      report (&inst[0]);
      report (&inst[1]);
      return 0;
    }

  fprintf (stderr, "bad arguments\n");
  return 2;
}
