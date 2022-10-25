/*
  Copyright 2020 Michael Karl Franzl <public.michael@franzl.name>

  This file is part of yaAGC.

  yaAGC is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  yaAGC is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with yaAGC; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

  In addition, as a special exception, Ronald S. Burkey gives permission to
  link the code of this program with the Orbiter SDK library (or with
  modified versions of the Orbiter SDK library that use the same license as
  the Orbiter SDK library), and distribute linked combinations including
  the two. You must obey the GNU General Public License in all respects for
  all of the code used other than the Orbiter SDK library. If you modify
  this file, you may extend this exception to your version of the file,
  but you are not obligated to do so. If you do not wish to do so, delete
  this exception statement from your version.

  Filename:  ringbuffer_api.c
  Purpose:   Allows yaAGC to read/write i/o packets from/to simple ringbuffers
             in memory.  This file was based on NullAPI.c. Some code was copied
             from SocketAPI.c (where noted).
             Ring buffers were chosen so as to not slow down the AGC execution
             from possibly slow foreign function calls. The ringbuffers
             obviously have to be filled and emptied from other places where
             exact timing is not so relevant.
  Contact:   Michael Karl Franzl <public.michael@franzl.name>
  Reference: http://www.ibiblio.org/apollo/index.html
  Mods:      2020-06-07 MKF  Created.
*/

#include "yaAGC.h"
#include "agc_engine.h"
#include "ringbuffer.h"

static int CurrentChannelValues[256] = { 0 };
static int ChannelMasks[256] = { 077777 };

static int ChannelIsSetUp = 0;

static void
ChannelSetup (agc_t* State)
{
  ChannelIsSetUp = 1;

  ringbuffer_init (&ringbuffer_out);
  ringbuffer_init (&ringbuffer_in);

  for (int i = 0; i < 256; i++)
    ChannelMasks[i] = 077777;
}

/* The simulated AGC CPU calls this function when it wants to output data.  It
 * stores the data in ringbuffer_out so as to not have to call
 * a foreign and possibly slow function.  The data is supposed to be read from
 * the ring buffer asynchronously. See also NullAPI.c
 *
 * The bulk of the code was copied from SocketAPI.c
 */
void
ChannelOutput (agc_t* State, int Channel, int Value)
{
  if (!ChannelIsSetUp)
    ChannelSetup (State);

  // Some output channels have purposes within the CPU, so we have to
  // account for those separately.
  if (Channel == 7)
    {
      State->InputChannel[7] = State->OutputChannel7 = (Value & 0160);
      return;
    }

  // Stick data into the RHCCTR registers, if bits 8,9 of channel 013 are set.
  if (Channel == 013 && 0600 == (0600 & Value) && !CmOrLm)
    {
      State->Erasable[0][042] = LastRhcPitch;
      State->Erasable[0][043] = LastRhcYaw;
      State->Erasable[0][044] = LastRhcRoll;
    }

  unsigned char Packet[4];
  if (!FormIoPacket (Channel, Value, Packet))
    ringbuffer_put (&ringbuffer_out, Packet);
}


/* The simulated AGC CPU calls this function when it wants to input data.
 * The data is read from the ring buffer ringbuffer_in.
 * See also NullAPI.c
 */
int
ChannelInput (agc_t* State)
{
  if (!ChannelIsSetUp)
    ChannelSetup (State);

  unsigned char Packet[4];
  while (ringbuffer_get(&ringbuffer_in, Packet))
    {
      // This body of the while loop follows the work done in SocketAPI.c.
      // I removed socket client related code, and refactored and reformatted
      // the code.

      int uBit, Value, Channel;

      if (ParseIoPacket (Packet, &Channel, &Value, &uBit))
        continue; // Not a valid packet; try the next one.

      Value &= 077777; // Convert to AGC format (only keep upper 15 bits).

      if (uBit)
        {
          // This is not an actual input to the CPU. It only sets a bit mask
          // for masking of future inputs.
          ChannelMasks[Channel] = Value;
          continue; // Proceed with the next packet in the ring buffer.
        }

      if (Channel & 0x80)
        {
          // This is a counter increment. According to NullAPI.c we need to
          // immediately return a value of 1.
          UnprogrammedIncrement (State, Channel, Value);
          return 1;
        }

      // Mask out irrelevant bits, set current bits, and write to CPU.
      Value &= ChannelMasks[Channel];
      Value |= ReadIO (State, Channel) & ~ChannelMasks[Channel];
      WriteIO (State, Channel, Value);

      // If this is a keystroke from the DSKY, generate an interrupt req.
      if (Channel == 015)
        State->InterruptRequests[5] = 1;
      // If this is on fictitious input channel 0173, then the data
      // should be placed in the INLINK counter register, and an
      // UPRUPT interrupt request should be set.
      else if (Channel == 0173)
        {
          State->Erasable[0][RegINLINK] = (Value & 077777);
          State->InterruptRequests[7] = 1;
        }
      // Fictitious registers for rotational hand controller (RHC).
      // Note that the RHC angles are not immediately used, but
      // merely squirreled away for later.  They won't actually
      // go into the counter registers until the RHC counters are
      // enabled and the data requested (bits 8,9 of channel 13).
      else if (Channel == 0166)
        {
          LastRhcPitch = Value;
          ChannelOutput (State, Channel, Value);  // echo
        }
      else if (Channel == 0167)
        {
          LastRhcYaw = Value;
          ChannelOutput (State, Channel, Value);  // echo
        }
      else if (Channel == 0170)
        {
          LastRhcRoll = Value;
          ChannelOutput (State, Channel, Value);  // echo
        }
    } // while

  return 0;
}

void
ChannelRoutine (agc_t* State)
{
}

void
ShiftToDeda (agc_t* State, int Data)
{
}
