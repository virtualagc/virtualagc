/*
 * Copyright 2020 Ronald S. Burkey <info@sandroid.org>
 *
 * This file is part of yaAGC.
 *
 * yaAGC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * yaAGC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with yaAGC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * In addition, as a special exception, Ronald S. Burkey gives permission to
 * link the code of this program with the Orbiter SDK library (or with
 * modified versions of the Orbiter SDK library that use the same license as
 * the Orbiter SDK library), and distribute linked combinations including
 * the two. You must obey the GNU General Public License in all respects for
 * all of the code used other than the Orbiter SDK library. If you modify
 * this file, you may extend this exception to your version of the file,
 * but you are not obligated to do so. If you do not wish to do so, delete
 * this exception statement from your version.
 *
 * Filename:    processInterruptsAndIO.c
 * Purpose:     This function is used between emulations of LVDC/PTC
 *              instructions.  If external conditions require an interrupt
 *              on the next LVDC/PTC machine cycle, this function is the
 *              one that's supposed to notice that and to set up
 *              the emulation so that the interrupt actually occurs.
 *              Also processes PIO and (for PTC) CIO and PRS.
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2020-05-02 RSB  Began.
 *              2020-05-06 RSB  Merged Interrupts, PIO, CIO, PRS processing
 *                              into this one file, since they seem to
 *                              interact a lot.
 *              2020-05-11 RSB  Moved processing of the "interrupt latch"
 *                              from yaPTC.py to here.  I found that the
 *                              PTC ADAPT Self-Test Program expected to be
 *                              able to read back the contents of the
 *                              interrupt latch the very next instruction
 *                              cycle after it had written them out, which
 *                              precludes them being handled by a peripheral
 *                              like yaPTC that's communicating with yaLVDC
 *                              via the "virtual wire" system.  It turns out
 *                              also that there were errors in the yaPTC.py
 *                              implementation of this that I fixed here.
 *              2020-06-05 RSB  Corrected CIO 065, 071.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "yaLVDC.h"

// Note the mapping of the individual bits in the interrupt
// latch (CIO 154):  interrupt 1 is the most-significant
// bit (1<<25), etc.  This is not the same as the mapping
// in the interrupt inhibit latch (CIO 000 and 004), in
// which interrupt 1 is instead the least-significant bit.
#define interruptLatches state.cio[0154]
void
setLatch(int n)
{
  if (n < 1 || n > 16)
    return;
  interruptLatches |= (1 << (26 - n));
}
void
resetLatch(int n)
{
  if (n < 1 || n > 16)
    return;
  interruptLatches &= ~(1 << (26 - n));
}

// Returns 0 on success, non-zero on fatal error.
int
processInterruptsAndIO(void)
{
  int retVal = 1, channel, payload;

  // Some of these operations we want to performed entirely locally here,
  // in the yaLVDC program; some we want to be done entirely in the client,
  // yaPTC; some need processing in both places.  Interrupt processing
  // is an example of the former.  If we want the client to do *anything*
  // (i.e., if the processing isn't 100% local), then we need to skip
  // down to the appropriate label (doneCIO, donePIO) after doing the
  // appropriate local processing.
  if (state.pioChange != -1)
    {
      int *interruptLatch;

      channel = state.pioChange;
      payload = state.pio[channel];
      if (ptc)
        interruptLatch = &state.cio[0154];
      else
        interruptLatch = &state.pio[0137];

      //printf("here PIO channel %03o\n", channel);

      if (channel == 0000)
        *interruptLatch = 0;
      else if (channel == 0001) // Interrupt latch 1
        *interruptLatch |= 0200000000;
      else if (channel == 0002) // Interrupt latch 2
        *interruptLatch |= 0100000000;
      else if (channel == 0004) // Interrupt latch 3
        *interruptLatch |= 0040000000;
      else if (channel == 0010) // Interrupt latch 4
        *interruptLatch |= 0020000000;
      else if (channel == 0020) // Interrupt latch 5
        *interruptLatch |= 0010000000;
      else if (channel == 0040) // Interrupt latch 6
        *interruptLatch |= 0004000000;
      else if (channel == 0100) // Interrupt latch 7
        *interruptLatch |= 0002000000;
      else if (channel == 0200) // Interrupt latch 8
        *interruptLatch |= 0001000000;
      else if (channel == 0400) // Interrupt latch 9
        *interruptLatch |= 0000400000;
      else
        goto morePIO;

      // If we've gotten to here, the channel has been fully processed
      // and doesn't need to be processed by pendingVirtualWireActivity().
      // On the other hand, if we've skipped down to morePIO, then the
      // converse is true.
      state.pioChange = -1;
      morePIO:;
    }
  else if (state.cioChange != -1)
    {
      int remainder, quotient;
      channel = state.cioChange;
      payload = state.cio[channel];

      if (channel == 0240)
        {
          // Light the PROG ERR lamp in the client.  Locally, we
          // must use this info along with the setting of switch 16
          // of PROG REG A either to pause the processor or else to
          // continue free run.
          if ((state.cio[0214] & (1 << 9)) == 0)
            printf("PROG ERR ... no change in run mode.\n");
          else
            {
              printf("PROG ERR ... pausing CPU.\n");
              panelPause = 2;
            }
          goto moreCIO;
        }

      remainder = channel % 4;
      quotient = channel / 4;
      if (remainder == 0)
        {
          if (channel == 0000)
            {
              state.interruptInhibitLatches|= payload & 077777;
            }
          else if (channel == 0004)
            {
              state.interruptInhibitLatches &= ~(payload & 077777);
            }
          else if (channel <= 0104)
            {
              resetLatch(quotient - 1);
            }
          else if (channel == 0110)
            {
              state.masterInterruptLatch = 0;
            }
          else if (channel == 0210)
            {
              state.gateProgRegA = (payload & 077) << 3;
              goto moreCIO;
            }
          else if (channel == 0224)
            {
              interruptLatches |= (payload & 0377774000) | ((payload & 03777) << 15);
            }
          else
            {
              goto moreCIO;
            }
        }
      else if (remainder == 1)
        {
          if (channel <= 0061)
            {
              setLatch(quotient + 3);
            }
          else if (channel <= 0071)
            {
              setLatch(quotient - 4);
            }
          else if (channel <= 0151)
            {
              setLatch(quotient - 016);
            }
          else if (channel <= 0175)
            {
              // These are marked as SPARE, and thus presumably
              // need no processing at all.
            }
          else
            {
              goto moreCIO;
            }
        }
      else if (remainder == 2)
        {
          if (channel <= 0072)
            {
              setLatch(quotient + 1);
            }
          else if (channel == 0076)
            {
              setLatch(11);
            }
          else if (channel == 0102)
            {
              setLatch(13);
            }
          else if (channel <= 0176)
            {
              setLatch(quotient - 020);
            }
          else if (channel == 0202)
            {
              setLatch(12);
            }
          else if (channel == 0206)
            {
              setLatch(14);
            }
          else if (channel <= 0216)
            {
              setLatch(quotient - 041);
            }
          else
            {
              goto moreCIO;
            }
        }
      else if (remainder == 3)
        {
          if (0)
            {

            }
          else
            {
              goto moreCIO;
            }
        }
      // If we've gotten to here, the channel has been fully processed
      // and doesn't need to be processed by pendingVirtualWireActivity().
      // On the other hand, if we've skipped down to moreCIO, then the
      // converse is true.
      state.cioChange = -1;
      moreCIO: ;
    }

  pendingVirtualWireActivity();

  retVal = 0;
  //done: ;
  return (retVal);
}
