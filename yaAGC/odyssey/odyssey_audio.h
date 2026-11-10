/*
 * ODYSSEY-AGC -- Filename: odyssey_audio.h
 * Purpose: AGC audio-sample events, the per-computer sample queue, and the
 *          AGC-word -> host-PCM representation conversion.
 *
 * The host's job here is TRANSPORT ONLY.  Nothing in this module computes an
 * oscillator waveform; it stores, orders, converts the representation of, and
 * counts values that an AGC program wrote to the audio channel.
 */
#ifndef ODYSSEY_AUDIO_H
#define ODYSSEY_AUDIO_H

#include <stdint.h>
#include <stddef.h>
#include "odyssey_config.h"

/* One captured audio-sample write.  Everything the acceptance tests need to
 * check ordering, loss, and timing is kept with the sample. */
typedef struct
{
  uint64_t cycle;     /* AGC CycleCounter when the WRITE completed (MCT units) */
  uint32_t seq;       /* per-computer, monotonically increasing, starts at 0   */
  uint16_t word;      /* original 15-bit AGC word, untouched                   */
  uint8_t computer;   /* ODY_COMPUTER_*                                        */
  uint8_t reserved;
} ody_sample_t;

/* Fixed-capacity ring.  Single producer (the AGC channel callback), single
 * consumer (the drain/mixer side).  Today both run on one host thread, so no
 * atomics are used; if the audio callback ever drains on another thread,
 * head/tail MUST become C11 atomics with acquire/release ordering.  (That is
 * a documented TODO for milestone 8, not an implemented guarantee.) */
typedef struct
{
  ody_sample_t *slots;
  uint32_t capacity;     /* power of two */
  uint32_t head;         /* next write index (monotonic, masked on use) */
  uint32_t tail;         /* next read index  (monotonic, masked on use) */
  uint64_t pushed;       /* samples accepted                            */
  uint64_t dropped;      /* samples rejected because the ring was full  */
} ody_sample_queue_t;

int      ody_queue_init (ody_sample_queue_t *q, uint32_t capacity);
void     ody_queue_destroy (ody_sample_queue_t *q);
void     ody_queue_clear (ody_sample_queue_t *q);   /* keeps capacity */
uint32_t ody_queue_size (const ody_sample_queue_t *q);
/* Never blocks.  Returns 1 if stored, 0 if dropped (counter incremented). */
int      ody_queue_push (ody_sample_queue_t *q, const ody_sample_t *s);
/* Returns 1 and fills *out, or 0 if empty. */
int      ody_queue_pop (ody_sample_queue_t *q, ody_sample_t *out);

/* ------------------------------------------------------------------------
 * AGC word -> PCM.
 *
 * An AGC data word is 15 bits, ONE'S COMPLEMENT: bit 14 (040000) is the sign,
 * bits 13..0 are the magnitude (positive) or the bitwise complement of the
 * magnitude (negative).  Hence 000000 is +0, 077777 is -0, 037777 is +16383,
 * 040000 is -16383.  Ordinary two's-complement sign extension is WRONG here.
 *
 * Conversion (ODYSSEY extension): value = sign * magnitude, in [-16383,
 * +16383]; PCM16 = value * 2, i.e. [-32766, +32766].  Both zeros map to PCM 0
 * (PCM has no negative zero); the original word is kept in ody_sample_t.
 * ---------------------------------------------------------------------- */
int ody_agc_to_value (uint16_t word15);   /* -16383 .. +16383 */
int16_t ody_agc_to_pcm16 (uint16_t word15);

#endif /* ODYSSEY_AUDIO_H */
