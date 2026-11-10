/*
 * ODYSSEY-AGC -- Filename: odyssey_audio.c
 * See odyssey_audio.h.  Transport/representation only; no waveform synthesis.
 */
#include <stdlib.h>
#include <string.h>
#include "odyssey_audio.h"

int
ody_queue_init (ody_sample_queue_t *q, uint32_t capacity)
{
  memset (q, 0, sizeof *q);
  /* capacity must be a non-zero power of two */
  if (capacity == 0 || (capacity & (capacity - 1)) != 0)
    return 1;
  q->slots = (ody_sample_t *) calloc (capacity, sizeof (ody_sample_t));
  if (q->slots == NULL)
    return 2;
  q->capacity = capacity;
  return 0;
}

void
ody_queue_destroy (ody_sample_queue_t *q)
{
  if (q == NULL)
    return;
  free (q->slots);
  memset (q, 0, sizeof *q);
}

void
ody_queue_clear (ody_sample_queue_t *q)
{
  q->head = q->tail = 0;
  q->pushed = q->dropped = 0;
}

uint32_t
ody_queue_size (const ody_sample_queue_t *q)
{
  return q->head - q->tail;      /* unsigned wrap-around is intentional */
}

int
ody_queue_push (ody_sample_queue_t *q, const ody_sample_t *s)
{
  if (q->slots == NULL || ody_queue_size (q) >= q->capacity)
    {
      q->dropped++;              /* drop NEWEST; never block the AGC */
      return 0;
    }
  q->slots[q->head & (q->capacity - 1)] = *s;
  q->head++;
  q->pushed++;
  return 1;
}

int
ody_queue_pop (ody_sample_queue_t *q, ody_sample_t *out)
{
  if (q->slots == NULL || ody_queue_size (q) == 0)
    return 0;
  *out = q->slots[q->tail & (q->capacity - 1)];
  q->tail++;
  return 1;
}

int
ody_agc_to_value (uint16_t word15)
{
  int w = word15 & 077777;
  if (w & 040000)                /* negative: magnitude is the complement */
    return -((~w) & 037777);
  return w & 037777;             /* positive */
}

int16_t
ody_agc_to_pcm16 (uint16_t word15)
{
  return (int16_t) (ody_agc_to_value (word15) * 2);
}
