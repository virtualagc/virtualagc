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

  Filename:  wasm.c
  Purpose:   Entrypoints for WebAssembly
  Contact:   Michael Karl Franzl <public.michael@franzl.name>
  Reference: http://www.ibiblio.org/apollo/index.html
  Mods:      2020-06-07 MKF.  Created.
*/

#include "yaAGC.h"
#include "agc_engine.h"
#include "ringbuffer.h"

#define export __attribute__((visibility("default")))

agc_t State;

ringbuffer ringbuffer_in;
ringbuffer ringbuffer_out;

/* Returns a pointer to the erasable memory of the AGC.
 * This should be used only for the inspection of the memory.
 */
export uint32_t
get_erasable_ptr ()
{
  return (uint64_t)&State.Erasable;
}


/* Copies rom_data to the fixed memory of the AGC.
 * This function is based on `main()` in EmbeddedDemo.c.
 */
export void
set_fixed (unsigned char* rom_data)
{
  unsigned int i = 0;
  unsigned int j = 0;

  for (unsigned int bank = 2; bank <= 35;)
    {
      unsigned int index = 2 * (i * 02000 + j);
      State.Fixed[bank][j++] =
        (rom_data[index] * 256 + rom_data[index + 1]) >> 1;

      if (j == 02000)
        {
          i++;
          j = 0;
          // bank filled.  Advance to next fixed-memory bank.
          if (bank == 2)
            bank = 3;
          else if (bank == 3)
            bank = 0;
          else if (bank == 0)
            bank = 1;
          else if (bank == 1)
            bank = 4;
          else
            bank++;
        }
    }
}


/* Resets the CPU. */
export void
cpu_reset ()
{
  agc_engine_init (&State, NULL, NULL, 0);
}


/*
 * Steps the CPU a number of (`steps`) times.
 * Call this function so that the CPU is stepped once every 11.72 microseconds.
 */
export void
cpu_step (uint32_t steps)
{
  for (uint32_t i = 0; i < steps; i++)
    agc_engine (&State);
}


/*
 * Compose a 4 byte "Packet for Socket Implementation of AGC I/O System" from a
 * given channel number and data, and put it into a ringbuffer for later
 * processing by yaAGC.
 *
 * `data` is 15 bits.
 *
 * `channel` is 9 bits, composed of:
 *
 * - Bit 0-6:  Port number `p`.
 * - Bit 7:    Type bit `t`. If set, this packet is an "unprogrammed counter
 *             increment".  If unset, this packet will write `data` to the
 *             port.
 * - Bit 8:    Mask bit `u`. If set, the data is set as a bit mask for the
 *             given port number.  Does not influence the state of the CPU.
 *
 * See https://www.ibiblio.org/apollo/developer.html
 *
 * You can call this function up to RINGBUFFER_ELEMENTS times at once before
 * the ring buffer is full. Some or all of the packets in the buffer will be
 * processed at the next call to `cpu_step`.
 *
 * Returns 0 when then ringbuffer was full and no write took place. You then
 * need to re-try later.
 *
 * Returns a positive number if the write was successful.
 *
 * Returns a negative number if a packed could not be formed.
 */
export int
packet_write (uint16_t channel, uint16_t data)
{
  unsigned char packet[4];

  if (FormIoPacket (channel, data, packet))
    return -1;

  return ringbuffer_put (&ringbuffer_in, packet);
}


/*
 * Returns from a ringbuffer the next output from yaAGC.
 *
 * The return value is a single integer number which is the combination of the
 * port number and the data.
 *
 * - Bits  0-14: 15 bit data
 * - Bits 15-21: 7 bit port number
 *
 * If 0 is returned, the ringbuffer was emtpy, and the value can be discarded.
 * To keep the ringbuffer depleted, call this function and process the return
 * values repeatedly until 0 is returned.
 *
 * If you want the timing to be perfect, you need to call this function every
 * time after calling `cpu_step()`.
 */
export uint32_t
packet_read ()
{
  unsigned char packet[4];
  int port, val, bit;

  if (ringbuffer_get (&ringbuffer_out, packet))
    {
      ParseIoPacket (packet, &port, &val, &bit);
      return (port << 16) + val;
    }
  return 0;
}

void
BacktraceAdd (agc_t* State, int Cause)
{
}
