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
  interruptLatches|= (1 << (26 - n));
}
void
resetLatch(int n)
{
  if (n < 1 || n > 16)
    return;
  interruptLatches&= ~(1 << (26 - n));
}

/*
 The Typewriter CIO instructions (for some reason that's TBD) set the
 interrupt latches in a pattern that depends on the specific character
 (CIO 120, 124, 130) or other command (CIO 134) being output to the
 typewriter.  The following is a table of such interrupt-bit patterns
 derived from PTC documentation table 2-56, and more-or-less identical
 to the PATN array from the PAST program source code (but sorted
 differently, to conform to the order of BA8421b[] in yaPTC.py).

 Note that because I made things simpler for myself by cutting and pasting
 from OCT pseudo-ops in the PAST program's source code, all of the constants
 are shifted left by one position, so that's why all of the >>1 mods are
 present in the tables below.
 */
int TBDTBDTBDT = 0;
int PATN[] =
  {
      // ' ', '1', '2', '3', '4', '5', '6', '7'
      0000010000 >> 1, 0177000000 >> 1, 0067000000 >> 1, 0076000000 >> 1,
      0127000000 >> 1, 0136000000 >> 1, 0026000000 >> 1, 0037000000 >> 1,
      // '8', '9', '0', '#', "@", ':', '>', '√'
      0117000000 >> 1, 0106000000 >> 1, 0016000000 >> 1, 0007000000 >> 1,
      0517000000 >> 1, 0106000000 >> 1, 0016000000 >> 1, 0007000000 >> 1,
      // '¢', '/', 'S', 'T', 'U', 'V', 'W', 'X'
      0163000000 >> 1, 0172000000 >> 1, 0062000000 >> 1, 0073000000 >> 1,
      0122000000 >> 1, 0133000000 >> 1, 0023000000 >> 1, 0032000000 >> 1,
      // 'Y', 'Z', '≠', ',', '%', '=', '\\','⧻'
      0112000000 >> 1, 0103000000 >> 1, 0032000000 >> 1, 0002000000 >> 1,
      0112000000 >> 1, 0103000000 >> 1, 0163000000 >> 1, 0002000000 >> 1,
      // '-', 'J', 'K', 'L', 'M', 'N', 'O', 'P'
      0165000000 >> 1, 0174000000 >> 1, 0064000000 >> 1, 0075000000 >> 1,
      0124000000 >> 1, 0135000000 >> 1, 0025000000 >> 1, 0034000000 >> 1,
      // 'Q', 'R', '!', '$', '*', ']', ';', 'Δ'
      0114000000 >> 1, 0105000000 >> 1, 0034000000 >> 1, 0004000000 >> 1,
      0114000000 >> 1, 0105000000 >> 1, 0165000000 >> 1, 0004000000 >> 1,
      // '&', 'A', 'B', 'C', 'D', 'E', 'F', 'G'
      0160000000 >> 1, 0171000000 >> 1, 0061000000 >> 1, 0070000000 >> 1,
      0121000000 >> 1, 0130000000 >> 1, 0020000000 >> 1, 0031000000 >> 1,
      // 'H', 'I', '?', '.', '⌑', '[', '<', '⯒
      0111000000 >> 1, 0100000000 >> 1, 0031000000 >> 1, 0001000000 >> 1,
      0111000000 >> 1, 0100000000 >> 1, 0160000000 >> 1, 0001000000 >> 1 };
// Same kind of thing, but for the control-code bit flags in CIO 134.
int PATN134[] =
  {
      // space, black , red, index, return, tab
      0000010000 >> 1, 0000040000 >> 1, 0000100000 >> 1, 0000200000 >> 1,
      0000020000 >> 1, 0000400000 >> 1 };
// This array tells which of the typewriter characters are "upper case".
// This categorization has nothing whatever to do with your normal conception,
// since 'A', 'B', ..., 'Z' are all "lower case" in this categorization.
// Rather, it has to do with where various characters are positioned on the
// particular Selectric ball being used by the PTC's typewriter.
int UPCASE[] =
  {
  // ' ', '1', '2', '3', '4', '5', '6', '7'
      0, 0, 0, 0, 0, 0, 0, 0,
      // '8', '9', '0', '#', "@", ':', '>', '√'
      0, 0, 0, 0, 1, 1, 1, 1,
      // '¢', '/', 'S', 'T', 'U', 'V', 'W', 'X'
      0, 0, 0, 0, 0, 0, 0, 0,
      // 'Y', 'Z', '≠', ',', '%', '=', '\\','⧻'
      0, 0, 1, 0, 1, 1, 1, 1,
      // '-', 'J', 'K', 'L', 'M', 'N', 'O', 'P'
      0, 0, 0, 0, 0, 0, 0, 0,
      // 'Q', 'R', '!', '$', '*', ']', ';', 'Δ'
      0, 0, 1, 0, 1, 1, 1, 1,
      // '&', 'A', 'B', 'C', 'D', 'E', 'F', 'G'
      0, 0, 0, 0, 0, 0, 0, 0,
      // 'H', 'I', '?', '.', '⌑', '[', '<', '⯒
      0, 0, 1, 0, 1, 1, 1, 1 };

// Returns 0 on success, non-zero on fatal error.
int typewriterMargin = 80;
int typewriterTabStop = 5;
int typewriterCharsInLine = 0;
int
processInterruptsAndIO(void)
{
  int retVal = 1, channel, payload, lastInterruptLatch = 0;

  if (ptc)
    lastInterruptLatch = state.cio[0154];

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
      morePIO: ;
    }
  else if (state.cioChange != -1)
    {
      int remainder, quotient, index;
      channel = state.cioChange;
      payload = state.cio[channel];

      if (channel == 0250)
        {
          if ((payload & 0200000000) != 0)
            state.inhibit250 = 1;
          if ((payload & 0100000000) != 0)
            state.inhibit250 = 0;
        }

      if (channel == 0240)
        {
          // Light the PROG ERR lamp in the client.  Locally, we
          // must use this info along with the setting of switch 16
          // of PROG REG A either to pause the processor or else to
          // continue free run.
          if ((state.cio[0214] & (1 << 9)) == 0)
            {
              // printf("PROG ERR ... no change in run mode.\n");
            }
          else
            {
              printf("PROG ERR ... pausing CPU.\n");
              panelPause = 2;
            }
          goto moreCIO;
        }

      if (channel == 0234)
        state.ai3Shifter = payload;

      if (channel == 074)
        state.cio210CarrBusy &= ~0000010000;

      remainder = channel % 4;
      quotient = channel / 4;
      if (remainder == 0)
        {
          if (channel == 0000)
            {
              state.interruptInhibitLatches |= payload & 077777;
            }
          else if (channel == 0004)
            {
              state.interruptInhibitLatches &= ~(payload & 077777);
            }
          else if (channel <= 0104)
            {
              resetLatch(quotient - 1);
              state.cio264Buffer &= ~(1 << (quotient - 2));
            }
          else if (channel == 0110)
            {
              state.masterInterruptLatch = 0;
            }
          else if (channel == 0120)
            {
              int charCase;
              // Fix the interrupt bits.
              index = (payload >> 20) & 077;
              typeChar: ;
              typewriterCharsInLine++;
              charCase = UPCASE[index];
              if (charCase != state.lastTypewriterCharCase)
                {
                  state.lastTypewriterCharCase = charCase;
                  if (charCase)
                    state.currentCaseInterrupt = 0200000000;
                  else
                    state.currentCaseInterrupt = 0100000000;
                  state.cio[0154] |= state.currentCaseInterrupt;
                  state.caseChange = 1;
                  state.currentTypewriterInterrupt = PATN[index];
                  dPrintoutsTypewriter("PI CIO CASE CHANGE");
                }
              else
                state.cio[0154] |= PATN[index];
              dPrintoutsTypewriter("PI CIO 120/124/130");
              goto moreCIO;
            }
          else if (channel == 0124)
            {
              // Fix the interrupt bits.
              index = (payload >> 22) & 017;
              goto typeChar;
            }
          else if (channel == 0130)
            {
              // Fix the interrupt bits.
              index = (payload >> 23) & 07;
              if (index == 0) // In octal coding, a printed '0' is encoded as a space.
                index = 012;
              goto typeChar;
            }
          else if (channel == 0134)
            {
              // Fix the interrupt bits and see if we need to account for
              // an automatic carriage return.  (We don't actually need to
              // somehow generate on, but we need to account for the
              // busy bit if one happens.)
              int i, bits;
              for (i = 0, bits = payload; i < 6; i++, bits = bits << 1)
                if ((bits & 0200000000) != 0)
                  {
                    state.cio[0154] |= PATN134[i];
                    switch (i)
                      {
                    case 0:
                      typewriterCharsInLine++;
                      dPrintoutsTypewriter("PI CIO 134 SPACE");
                      break;
                    case 1:
                      dPrintoutsTypewriter("PI CIO 134 BLACK");
                      break;
                    case 2:
                      dPrintoutsTypewriter("PI CIO 134 RED");
                      break;
                    case 3:
                      dPrintoutsTypewriter("PI CIO 134 INDEX");
                      break;
                    case 4:
                      dPrintoutsTypewriter("PI CIO 134 RETURN");
                      typewriterCharsInLine = typewriterMargin;
                      break;
                    case 5:
                      do
                        typewriterCharsInLine++;
                      while (typewriterCharsInLine % typewriterTabStop != 0);
                      dPrintoutsTypewriter("PI CIO 134 TAB");
                      break;
                    default:
                      dPrintoutsTypewriter("PI CIO 134 other");
                      break;
                      }
                  }
              goto moreCIO;
            }
          else if (channel == 0210)
            {
              // Route the discrete outputs back into the (gated) discrete inputs.
              state.progRegA17_22 = (payload & 077) << 3;
              if ((payload & 035) != 0 && !state.bbPrinter) // D.O. 1, 3, 4, or 5.
                {
                  state.bbPrinter = 1;
                  dPrintoutsTypewriter("PI CIO 210 D.O. 1");
                  state.busyCountPrinter = MEDIUM_BUSY_CYCLES;
                }
              else if ((payload & 035) == 0 && state.bbPrinter)
                {
                  state.bbPrinter = 0;
                  state.busyCountPrinter = 0;
                }
              if ((payload & 05) == 0 && state.bbTypewriter)
                {
                  state.bbTypewriter = 0;
                  state.busyCountTypewriter = 0;
                }
              if ((payload & 4) != 0) // D.O. 3
                {
                  state.cio210CarrBusy = 0001020000 >> 1;
                  state.cio[0154] |= PATN134[4];
                  state.bbTypewriter = 4;
                  dPrintoutsTypewriter("PI CIO 210 D.O. 3");
                  typewriterCharsInLine = 0;
                  state.busyCountTypewriter = SHORT_BUSY_CYCLES;
                  state.busyCountPrinter = MEDIUM_BUSY_CYCLES;
                  state.busyCountCarriagePrinter = 3;
                }
              if ((payload & 32) != 0) // D.O. 6
                {
                  state.cio[0154] = (state.cio[0154] & ~0377770000) | 0305010000;
                  state.prsDelayedParity[1] = 0;
                  state.prsDelayedParity[2] = 0;
                  state.prsDelayedParity[3] = 0;
                }
              goto moreCIO;
            }
          else if (channel == 0224)
            {
              interruptLatches|= (payload & 0377774000) | ((payload & 03777) << 15);
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

  if (ptc && lastInterruptLatch != state.cio[0154])
    state.prsParityDelayCount = 100;

  pendingVirtualWireActivity();

  retVal = 0;
  //done: ;

  return (retVal);
}
