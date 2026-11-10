/*
 * ODYSSEY-AGC -- Filename: odyssey_io.c
 * Purpose: Implements the I/O hooks that agc_engine.c requires at link time
 *          (the same set NullAPI.c provides in the upstream embedded demo),
 *          routed by INSTANCE rather than by any process-global flag.
 *
 * The engine calls ChannelOutput(State, ...) with the agc_t that executed the
 * WRITE.  We recover the owning odyssey_computer_t from State->agc_clientdata
 * and record the sample in THAT computer's queue.
 *
 * This file is linked INSTEAD of NullAPI.c / SocketAPI.c.  It must not be
 * linked into the normal yaAGC target, which has its own implementations.
 */
#include "odyssey_engine.h"

static odyssey_computer_t *
owner_of (agc_t *State)
{
  return (odyssey_computer_t *) State->agc_clientdata;
}

/* Called by the engine on every CPU write to an I/O channel (other than the
 * L/Q-overlapped channels 1 and 2).  Value is already masked to 15 bits. */
void
ChannelOutput (agc_t *State, int Channel, int Value)
{
  odyssey_computer_t *c = owner_of (State);
  if (c == NULL)
    return;

  switch (Channel)
    {
    case ODY_CH_AUDIO_SAMPLE:
      {
        ody_sample_t s;
        s.cycle = State->CycleCounter;
        s.seq = c->sample_seq++;     /* advances even if the push is dropped,
                                        so a drop shows up as a sequence gap */
        s.word = (uint16_t) (Value & 077777);
        s.computer = (uint8_t) c->id;
        s.reserved = 0;
        (void) ody_queue_push (&c->samples, &s);   /* never blocks */
        break;
      }
    case ODY_CH_AUDIO_CONTROL:
      c->audio_control = (uint16_t) (Value & 077777);
      c->audio_control_writes++;
      break;
    case 077:
      /* Restart-monitor alarm channel.  The engine calls ChannelOutput(077,
       * alarm bits) once per hardware alarm (TC Trap, Night Watchman, Rupt
       * Lock, parity), right after performing a GOJAM restart.  An AGC
       * program that itself writes channel 077 writes 0 (that clears the
       * latches), so a non-zero value here means a real alarm restart. */
      if (Value != 0)
        {
          c->alarm_restarts++;
          c->last_alarm_bits = (uint16_t) (Value & 077777);
        }
      c->other_channel_writes++;
      break;
    default:
      /* Real Apollo channels (DSKY, IMU, engine, ...) and the not-yet-built
       * bus channels land here.  Counted for diagnostics, otherwise ignored. */
      c->other_channel_writes++;
      c->last_other_channel = Channel;
      c->last_other_value = (uint16_t) (Value & 077777);
      break;
    }
}

/* No incoming data and no unprogrammed counter sequences, for now. */
int
ChannelInput (agc_t *State)
{
  (void) State;
  return 0;
}

void
ChannelRoutine (agc_t *State)
{
  (void) State;
}

void
ShiftToDeda (agc_t *State, int Data)
{
  (void) State;
  (void) Data;
}

void
RequestRadarData (agc_t *State)
{
  (void) State;
}

/* The engine calls this to record debugger backtraces; ODYSSEY has no
 * debugger, so keep it empty (same as the upstream embedded demo). */
void
BacktraceAdd (agc_t *State, int Cause)
{
  (void) State;
  (void) Cause;
}

/* Interposed on purpose.  agc_engine_init() calls UnblockSocket(fileno(stdin))
 * so the standalone simulator's getchar() never blocks.  That is a PROCESS
 * level side effect; ODYSSEY hosts several computers and must not touch stdin
 * once per AGC.  Defining this no-op here means we need no upstream edit to
 * agc_engine_init.c (see docs/UPSTREAM-CHANGES.md). */
void
UnblockSocket (int SocketNum)
{
  (void) SocketNum;
}
