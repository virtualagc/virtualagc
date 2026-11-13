/*
 * ODYSSEY-AGC -- Filename: odyssey_engine.h
 * Purpose: One ODYSSEY "computer": an official VirtualAGC agc_t plus the
 *          host-side state that belongs to it (sample queue, counters).
 *
 * OWNERSHIP
 *   odyssey_computer_t owns its agc_t and its sample queue.  The host
 *   scheduler owns the odyssey_computer_t objects.  A computer never reads or
 *   writes another computer's memory, registers or queues.
 *
 *   The back-pointer from agc_t to the owning odyssey_computer_t is stored in
 *   agc_t.agc_clientdata (an existing upstream hook that VirtualAGC itself
 *   never uses).  Its lifetime equals the computer's: it is set in
 *   odyssey_computer_init() and the computer is the only owner.
 *
 * STATE ISOLATION (milestone 4)
 *   The process-wide mutable statics that agc_engine.c used to keep (gyro, IMU
 *   CDU drive, CDU input FIFOs) now live in agc_t.Periph, so each computer owns
 *   its own.  The remaining engine globals are classified, with reasons, in
 *   docs/STATE-ISOLATION-AUDIT.md; in particular the debugger/telemetry/
 *   coverage globals are process-wide and MUST stay unused (debugger off,
 *   coverage off) while several computers share a process.
 */
#ifndef ODYSSEY_ENGINE_H
#define ODYSSEY_ENGINE_H

#include <stdint.h>
#include "yaAGC.h"
#include "agc_engine.h"
#include "odyssey_config.h"
#include "odyssey_audio.h"

typedef struct odyssey_computer
{
  agc_t agc;                       /* official engine state; keep first       */
  int id;                          /* ODY_COMPUTER_*                          */
  int initialized;
  char rom_path[512];

  ody_sample_queue_t samples;      /* AGC audio output (channel ODY_CH_AUDIO_SAMPLE) */
  uint32_t sample_seq;             /* next sequence number to assign          */

  uint16_t audio_control;          /* last value written to ODY_CH_AUDIO_CONTROL */
  uint64_t audio_control_writes;
  uint64_t other_channel_writes;   /* writes to channels ODYSSEY does not handle */
  int last_other_channel;          /* channel of the most recent such write (diagnostic) */
  uint16_t last_other_value;

  /* AGC hardware-watchdog restarts.  The engine models the TC Trap, Night
   * Watchman and Rupt Lock alarms; on any alarm it performs a GOJAM restart
   * and reports the alarm bits through ChannelOutput(ch 077).  A non-zero
   * count means the AGC program is NOT keeping its watchdogs happy and was
   * restarted -- see docs/AGC-PROGRAMMING-RULES.md. */
  uint64_t alarm_restarts;
  uint16_t last_alarm_bits;        /* channel 077 value of the latest alarm   */

  uint64_t cycles_executed;        /* engine calls made through step()        */
} odyssey_computer_t;

/* Returns 0 on success, nonzero on failure.  On failure everything allocated
 * so far is released and the struct is left safe to pass to destroy(). */
int  odyssey_computer_init (odyssey_computer_t *c, int id, const char *rom_path);

/* Execute up to `budget` AGC machine cycles on THIS computer only.
 * Returns the number of cycles executed.  Never blocks. */
uint32_t odyssey_computer_step (odyssey_computer_t *c, uint32_t budget);

/* Power-on reset of this computer only: re-initialise the AGC from its ROM,
 * clear its sample queue and counters, restart sequence numbers at 0. */
int  odyssey_computer_reset (odyssey_computer_t *c);

/* Release all resources.  Safe on a zeroed, partially-initialised or already
 * destroyed computer. */
void odyssey_computer_destroy (odyssey_computer_t *c);

#endif /* ODYSSEY_ENGINE_H */
