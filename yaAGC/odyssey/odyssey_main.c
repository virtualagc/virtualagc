/*
 * ODYSSEY-AGC -- Filename: odyssey_main.c
 * Purpose: Offline (non-real-time) host for ONE ODYSSEY computer.
 *          Milestones 2 and 3: run a ROM for a bounded number of AGC cycles in
 *          deterministic slices, capture the AGC's audio-channel writes, and
 *          report ordering / loss / timing statistics.  No audio device.
 *
 * The dual-computer scheduler (milestone 5) will replace the single-computer
 * loop in main() but should reuse drain() and the odyssey_* modules as-is.
 *
 * Usage:
 *   odyssey-agc --rom ROM.bin [--cycles N] [--slice N] [--out samples.csv]
 *
 * Output: a CSV (seq,cycle,word_octal,value,pcm16) and key=value statistics
 * on stdout, one per line, intended to be parsed by tests/run_tests.sh.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>
#include <time.h>
#include "odyssey_engine.h"

typedef struct
{
  uint64_t samples;
  uint64_t seq_gaps;          /* total missing sequence numbers observed     */
  uint64_t out_of_order;      /* seq went backwards or repeated              */
  uint64_t cycle_regressions; /* cycle timestamp decreased                   */
  uint64_t first_cycle, last_cycle;
  uint32_t expected_seq;
  int have_prev;
  uint64_t prev_cycle;
} drain_stats_t;

/* Pop everything currently queued, validate it, and optionally log it. */
static void
drain (odyssey_computer_t *c, drain_stats_t *st, FILE *csv)
{
  ody_sample_t s;
  while (ody_queue_pop (&c->samples, &s))
    {
      if (s.seq > st->expected_seq)
        st->seq_gaps += s.seq - st->expected_seq;
      else if (s.seq < st->expected_seq)
        st->out_of_order++;
      st->expected_seq = s.seq + 1;

      if (st->have_prev && s.cycle < st->prev_cycle)
        st->cycle_regressions++;
      if (!st->have_prev)
        st->first_cycle = s.cycle;
      st->prev_cycle = st->last_cycle = s.cycle;
      st->have_prev = 1;
      st->samples++;

      if (csv != NULL)
        fprintf (csv, "%" PRIu32 ",%" PRIu64 ",%05o,%d,%d\n", s.seq, s.cycle,
                 (unsigned) s.word, ody_agc_to_value (s.word),
                 (int) ody_agc_to_pcm16 (s.word));
    }
}

static double
now_seconds (void)
{
  struct timespec ts;
  clock_gettime (CLOCK_MONOTONIC, &ts);
  return (double) ts.tv_sec + (double) ts.tv_nsec * 1e-9;
}

static void
usage (const char *argv0)
{
  fprintf (stderr,
           "usage: %s --rom ROM.bin [--cycles N] [--slice N] [--out samples.csv]\n"
           "  --cycles N  total AGC machine cycles to run (default 1000000)\n"
           "  --slice N   cycles per bounded slice (default %u)\n"
           "  --out FILE  write captured samples as CSV\n",
           argv0, ODY_DEFAULT_SLICE_CYCLES);
}

int
main (int argc, char **argv)
{
  const char *rom = NULL, *out = NULL;
  uint64_t total = 1000000, done = 0;
  uint32_t slice = ODY_DEFAULT_SLICE_CYCLES;
  odyssey_computer_t *c;
  drain_stats_t st;
  FILE *csv = NULL;
  double t0, t1;
  int i, rc;

  for (i = 1; i < argc; i++)
    {
      if (!strcmp (argv[i], "--rom") && i + 1 < argc)
        rom = argv[++i];
      else if (!strcmp (argv[i], "--cycles") && i + 1 < argc)
        total = strtoull (argv[++i], NULL, 10);
      else if (!strcmp (argv[i], "--slice") && i + 1 < argc)
        slice = (uint32_t) strtoul (argv[++i], NULL, 10);
      else if (!strcmp (argv[i], "--out") && i + 1 < argc)
        out = argv[++i];
      else
        {
          usage (argv[0]);
          return 2;
        }
    }
  if (rom == NULL || slice == 0)
    {
      usage (argv[0]);
      return 2;
    }

  c = (odyssey_computer_t *) malloc (sizeof *c);
  if (c == NULL)
    return 3;
  rc = odyssey_computer_init (c, ODY_COMPUTER_CMC, rom);
  if (rc != 0)
    {
      fprintf (stderr, "odyssey_computer_init failed (%d) for ROM '%s'\n", rc,
               rom);
      free (c);
      return 4;
    }

  if (out != NULL)
    {
      csv = fopen (out, "w");
      if (csv == NULL)
        {
          fprintf (stderr, "cannot open '%s' for writing\n", out);
          odyssey_computer_destroy (c);
          free (c);
          return 5;
        }
      fprintf (csv, "seq,cycle,word_octal,value,pcm16\n");
    }

  memset (&st, 0, sizeof st);
  t0 = now_seconds ();
  while (done < total)
    {
      uint32_t n = (total - done < slice) ? (uint32_t) (total - done) : slice;
      done += odyssey_computer_step (c, n);
      drain (c, &st, csv);          /* deterministic boundary: drain between slices */
    }
  t1 = now_seconds ();

  {
    double host_s = t1 - t0;
    double agc_s = (double) c->cycles_executed / (double) AGC_PER_SECOND;
    double span = (st.samples > 1) ? (double) (st.last_cycle - st.first_cycle) : 0.0;
    double cps = (st.samples > 1) ? span / (double) (st.samples - 1) : 0.0;

    printf ("rom=%s\n", rom);
    printf ("agc_cycles=%" PRIu64 "\n", c->cycles_executed);
    printf ("agc_seconds=%.6f\n", agc_s);
    printf ("slice_cycles=%u\n", slice);
    printf ("samples=%" PRIu64 "\n", st.samples);
    printf ("samples_emitted=%" PRIu32 "\n", c->sample_seq);
    printf ("queue_pushed=%" PRIu64 "\n", c->samples.pushed);
    printf ("queue_dropped=%" PRIu64 "\n", c->samples.dropped);
    printf ("seq_gaps=%" PRIu64 "\n", st.seq_gaps);
    printf ("out_of_order=%" PRIu64 "\n", st.out_of_order);
    printf ("cycle_regressions=%" PRIu64 "\n", st.cycle_regressions);
    printf ("audio_control_writes=%" PRIu64 "\n", c->audio_control_writes);
    printf ("other_channel_writes=%" PRIu64 "\n", c->other_channel_writes);
    printf ("last_other_channel=%o value=%05o\n", c->last_other_channel < 0 ? 0 : (unsigned) c->last_other_channel, (unsigned) c->last_other_value);
    printf ("alarm_restarts=%" PRIu64 "\n", c->alarm_restarts);
    printf ("last_alarm_bits=%05o\n", (unsigned) c->last_alarm_bits);
    printf ("mean_cycles_per_sample=%.3f\n", cps);
    printf ("agc_sample_rate_hz=%.3f\n",
            cps > 0.0 ? (double) AGC_PER_SECOND / cps : 0.0);
    printf ("host_seconds=%.6f\n", host_s);
    printf ("host_speed_vs_realtime=%.1f\n", host_s > 0.0 ? agc_s / host_s : 0.0);
  }

  if (csv != NULL)
    fclose (csv);
  odyssey_computer_destroy (c);
  free (c);
  return 0;
}
