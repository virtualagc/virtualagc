/*
 * ODYSSEY-AGC -- Filename: tests/test_unit.c
 * Unit tests for the representation conversion, the sample queue, the
 * computer lifecycle, and instance routing of channel output.
 *
 * usage: test_unit ROMDIR      (ROMDIR contains SEQTEST.bin from build_roms.sh)
 *
 * Exit status 0 only if every check passes.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>
#include "odyssey_engine.h"

static int failures = 0, checks = 0;

#define CHECK(cond)                                                          \
  do {                                                                       \
    checks++;                                                                \
    if (!(cond)) {                                                           \
      failures++;                                                            \
      fprintf (stderr, "FAIL %s:%d: %s\n", __FILE__, __LINE__, #cond);       \
    }                                                                        \
  } while (0)

/* ---------------------------------------------------------------- conversion */
static void
test_conversion (void)
{
  /* both zeros */
  CHECK (ody_agc_to_value (000000) == 0);
  CHECK (ody_agc_to_value (077777) == 0);      /* negative zero */
  CHECK (ody_agc_to_pcm16 (000000) == 0);
  CHECK (ody_agc_to_pcm16 (077777) == 0);
  /* extremes */
  CHECK (ody_agc_to_value (037777) == 16383);
  CHECK (ody_agc_to_value (040000) == -16383);
  CHECK (ody_agc_to_pcm16 (037777) == 32766);
  CHECK (ody_agc_to_pcm16 (040000) == -32766);
  /* +-1 : the classic two's-complement trap (077776 is -1, NOT -2) */
  CHECK (ody_agc_to_value (000001) == 1);
  CHECK (ody_agc_to_value (077776) == -1);
  /* mid-range pair used by SEQTEST */
  CHECK (ody_agc_to_value (012345) == 5349);
  CHECK (ody_agc_to_value (065432) == -5349);
  /* upper bits beyond 15 are ignored */
  CHECK (ody_agc_to_value (0100000 | 000005) == 5);

  /* exhaustive: negation by bitwise complement must negate the value, and
   * the value must stay within +-16383 for every 15-bit word. */
  {
    int w, bad = 0;
    for (w = 0; w <= 077777; w++)
      {
        int v = ody_agc_to_value ((uint16_t) w);
        int vn = ody_agc_to_value ((uint16_t) (~w & 077777));
        if (v < -16383 || v > 16383 || vn != -v)
          bad++;
      }
    CHECK (bad == 0);
  }
}

/* --------------------------------------------------------------------- queue */
static void
test_queue (void)
{
  ody_sample_queue_t q;
  ody_sample_t s, o;
  uint32_t i;

  CHECK (ody_queue_init (&q, 0) != 0);          /* zero capacity rejected  */
  CHECK (ody_queue_init (&q, 12) != 0);         /* non power of two        */
  CHECK (ody_queue_init (&q, 8) == 0);

  CHECK (!ody_queue_pop (&q, &o));              /* empty pop               */

  memset (&s, 0, sizeof s);
  for (i = 0; i < 8; i++)
    {
      s.seq = i;
      s.word = (uint16_t) (i * 3);
      s.cycle = 100 + i;
      CHECK (ody_queue_push (&q, &s) == 1);
    }
  CHECK (ody_queue_size (&q) == 8);

  /* full: next pushes must be dropped (newest), never block, never corrupt */
  s.seq = 8;
  CHECK (ody_queue_push (&q, &s) == 0);
  s.seq = 9;
  CHECK (ody_queue_push (&q, &s) == 0);
  CHECK (q.dropped == 2);
  CHECK (q.pushed == 8);

  /* retained samples are the OLDEST eight, in order */
  for (i = 0; i < 8; i++)
    {
      CHECK (ody_queue_pop (&q, &o) == 1);
      CHECK (o.seq == i && o.word == (uint16_t) (i * 3) && o.cycle == 100 + i);
    }
  CHECK (!ody_queue_pop (&q, &o));

  /* wrap-around: push/pop many times capacity, order preserved */
  {
    uint32_t next_in = 0, next_out = 0;
    int ok = 1;
    for (i = 0; i < 100000; i++)
      {
        int burst = 1 + (int) (i % 5), b;
        for (b = 0; b < burst; b++)
          {
            s.seq = next_in;
            if (ody_queue_push (&q, &s))
              next_in++;
          }
        for (b = 0; b < burst; b++)
          if (ody_queue_pop (&q, &o))
            {
              if (o.seq != next_out++)
                ok = 0;
            }
      }
    CHECK (ok);
  }

  /* clear keeps capacity and resets counters */
  ody_queue_clear (&q);
  CHECK (ody_queue_size (&q) == 0 && q.pushed == 0 && q.dropped == 0 &&
         q.capacity == 8);
  CHECK (ody_queue_push (&q, &s) == 1);

  ody_queue_destroy (&q);
  ody_queue_destroy (&q);                       /* double destroy is safe  */
  CHECK (ody_queue_push (&q, &s) == 0);         /* destroyed: drops, no crash */
}

/* ----------------------------------------------------------------- lifecycle */
static int
run_until_samples (odyssey_computer_t *c, uint32_t want, uint32_t max_cycles)
{
  uint32_t done = 0;
  while (done < max_cycles && ody_queue_size (&c->samples) < want)
    done += odyssey_computer_step (c, 10);
  return ody_queue_size (&c->samples) >= want;
}

static void
test_lifecycle_and_routing (const char *romdir)
{
  char rom[600];
  odyssey_computer_t *a = (odyssey_computer_t *) calloc (1, sizeof *a);
  odyssey_computer_t *b = (odyssey_computer_t *) calloc (1, sizeof *b);
  odyssey_computer_t *bad = (odyssey_computer_t *) calloc (1, sizeof *bad);
  ody_sample_t s;
  uint64_t b_cycle_before;
  uint32_t a_cycles_before_reset;

  snprintf (rom, sizeof rom, "%s/SEQTEST.bin", romdir);

  /* failure paths leave a struct that is safe to destroy */
  CHECK (odyssey_computer_init (bad, ODY_COMPUTER_CMC,
                                "/nonexistent/no-such-rom.bin") != 0);
  odyssey_computer_destroy (bad);
  odyssey_computer_destroy (bad);               /* double destroy */
  CHECK (odyssey_computer_init (bad, 99, rom) != 0);      /* bad id */
  CHECK (odyssey_computer_init (NULL, 0, rom) != 0);
  CHECK (odyssey_computer_step (bad, 100) == 0);          /* uninitialised */
  odyssey_computer_destroy (NULL);

  CHECK (odyssey_computer_init (a, ODY_COMPUTER_CMC, rom) == 0);
  CHECK (odyssey_computer_init (b, ODY_COMPUTER_LGC, rom) == 0);
  CHECK (a->agc.agc_clientdata == a && b->agc.agc_clientdata == b);

  /* ROM image is loaded into each computer's OWN fixed memory */
  CHECK (a->agc.Fixed[2][0] == b->agc.Fixed[2][0]);
  CHECK (&a->agc.Fixed[2][0] != &b->agc.Fixed[2][0]);

  /* --- routing: stepping A must emit samples into A only ---------------- */
  CHECK (run_until_samples (a, 8, 5000));
  CHECK (ody_queue_size (&a->samples) >= 8);
  CHECK (ody_queue_size (&b->samples) == 0);
  CHECK (b->cycles_executed == 0 && b->agc.CycleCounter == 0);
  CHECK (b->sample_seq == 0 && b->other_channel_writes == 0);

  /* A's samples carry A's identity and start at seq 0 */
  CHECK (ody_queue_pop (&a->samples, &s) == 1);
  CHECK (s.computer == ODY_COMPUTER_CMC && s.seq == 0);

  /* --- stepping B afterwards: its own seq restarts at 0, own identity --- */
  CHECK (run_until_samples (b, 3, 5000));
  CHECK (ody_queue_pop (&b->samples, &s) == 1);
  CHECK (s.computer == ODY_COMPUTER_LGC && s.seq == 0);

  /* --- reset of A leaves B untouched ------------------------------------ */
  b_cycle_before = b->agc.CycleCounter;
  a_cycles_before_reset = (uint32_t) a->agc.CycleCounter;
  CHECK (a_cycles_before_reset > 0);
  CHECK (odyssey_computer_reset (a) == 0);
  CHECK (a->agc.CycleCounter == 0 && a->sample_seq == 0 &&
         ody_queue_size (&a->samples) == 0);
  CHECK (b->agc.CycleCounter == b_cycle_before);
  CHECK (b->agc.agc_clientdata == b);
  CHECK (a->agc.agc_clientdata == a);           /* back-pointer survives reset */

  /* A runs again from a clean start and reproduces seq 0.. */
  CHECK (run_until_samples (a, 1, 5000));
  CHECK (ody_queue_pop (&a->samples, &s) == 1 && s.seq == 0);

  /* --- simulated-peripheral state is per computer (milestone 4) ---------
   * Both computers have been stepped, so their Periph fields hold live
   * (non-zero, advancing) values.  Test independence, not absolute values. */
  {
    unsigned b_gyro_timer = b->agc.Periph.GyroTimer;
    int b_checker = b->agc.Periph.CduChecker;

    a->agc.Periph.GyroTimer = 77;             /* sentinels in A */
    a->agc.Periph.ImuCduCount = 99;
    CHECK (b->agc.Periph.GyroTimer == b_gyro_timer);       /* B unchanged */
    CHECK (b->agc.Periph.CduChecker == b_checker);

    b->agc.Periph.GyroCount = 5;              /* sentinel in B */
    CHECK (a->agc.Periph.GyroTimer == 77 && a->agc.Periph.ImuCduCount == 99);

    CHECK (odyssey_computer_reset (a) == 0);  /* reset of A clears A ... */
    CHECK (a->agc.Periph.GyroTimer == 0 && a->agc.Periph.ImuCduCount == 0 &&
           a->agc.Periph.CduChecker == 0 && a->agc.Periph.GyroCount == 0);
    CHECK (b->agc.Periph.GyroCount == 5 &&    /* ... and leaves B alone */
           b->agc.Periph.GyroTimer == b_gyro_timer &&
           b->agc.Periph.CduChecker == b_checker);
  }

  /* --- destroy A leaves B running --------------------------------------- */
  odyssey_computer_destroy (a);
  CHECK (odyssey_computer_step (a, 10) == 0);
  CHECK (odyssey_computer_step (b, 10) == 10);
  odyssey_computer_destroy (b);

  free (a);
  free (b);
  free (bad);
}

int
main (int argc, char **argv)
{
  if (argc < 2)
    {
      fprintf (stderr, "usage: %s ROMDIR\n", argv[0]);
      return 2;
    }
  test_conversion ();
  test_queue ();
  test_lifecycle_and_routing (argv[1]);
  printf ("test_unit: %d checks, %d failures\n", checks, failures);
  return failures ? 1 : 0;
}
