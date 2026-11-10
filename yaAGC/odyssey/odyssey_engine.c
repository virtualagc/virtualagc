/*
 * ODYSSEY-AGC -- Filename: odyssey_engine.c
 * See odyssey_engine.h.
 */
#include <stdio.h>
#include <string.h>
#include "odyssey_engine.h"

/* Bring the AGC and host-side state to power-on values, keeping the ROM path
 * and the queue allocation.  Used by init() and reset(). */
static int
power_on (odyssey_computer_t *c)
{
  int rc;

  /* Zero the whole agc_t first so no field is ever indeterminate, then set
   * the clientdata back-pointer BEFORE the engine can call any callback. */
  memset (&c->agc, 0, sizeof c->agc);
  c->agc.agc_clientdata = c;

  rc = agc_engine_init (&c->agc, c->rom_path, NULL, 0);
  if (rc != 0)
    return rc;

  ody_queue_clear (&c->samples);
  c->sample_seq = 0;
  c->audio_control = 0;
  c->audio_control_writes = 0;
  c->other_channel_writes = 0;
  c->last_other_channel = -1;
  c->last_other_value = 0;
  c->alarm_restarts = 0;
  c->last_alarm_bits = 0;
  c->cycles_executed = 0;
  return 0;
}

int
odyssey_computer_init (odyssey_computer_t *c, int id, const char *rom_path)
{
  int rc;

  if (c == NULL || rom_path == NULL || id < 0 || id >= ODY_MAX_COMPUTERS)
    return -1;
  if (strlen (rom_path) >= sizeof c->rom_path)
    return -2;

  /* Everything starts zeroed so destroy() is always safe, even if a later
   * step fails. */
  memset (c, 0, sizeof *c);
  c->id = id;
  strcpy (c->rom_path, rom_path);

  rc = ody_queue_init (&c->samples, ODY_SAMPLE_QUEUE_CAPACITY);
  if (rc != 0)
    {
      odyssey_computer_destroy (c);
      return 100 + rc;
    }

  rc = power_on (c);
  if (rc != 0)
    {
      odyssey_computer_destroy (c);
      return 200 + rc;           /* 200 + agc_engine_init() code */
    }

  c->initialized = 1;
  return 0;
}

uint32_t
odyssey_computer_step (odyssey_computer_t *c, uint32_t budget)
{
  uint32_t i;

  if (c == NULL || !c->initialized)
    return 0;
  for (i = 0; i < budget; i++)
    if (agc_engine (&c->agc) != 0)
      {
        i++;                     /* count the call that reported the error */
        break;
      }
  c->cycles_executed += i;
  return i;
}

int
odyssey_computer_reset (odyssey_computer_t *c)
{
  if (c == NULL || !c->initialized)
    return -1;
  return power_on (c);
}

void
odyssey_computer_destroy (odyssey_computer_t *c)
{
  if (c == NULL)
    return;
  ody_queue_destroy (&c->samples);
  memset (&c->agc, 0, sizeof c->agc);
  c->initialized = 0;
}
