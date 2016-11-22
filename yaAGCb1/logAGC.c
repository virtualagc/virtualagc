/*
 * Copyright 2016 Ronald S. Burkey <info@sandroid.org>
 *
 * This file is part of yaAGC.
 *
 * yaAGC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
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
 * Filename:    logAGC.c
 * Purpose:     A logging function for the Block 1 simulator.
 * Compiler:    GNU gcc.
 * Contact:     Ron Burkey <info@sandroid.org>
 * Reference:   http://www.ibiblio.org/apollo/index.html
 * Mods:        2016-09-04 RSB  Wrote.
 *
 * If you modify this, be aware that my intention for using this was to be able
 * to make logs from yaAGCb1 *and* to make logs in an identical format from
 * yaAGC-Block1-Pultorak, so as to be able to compare them on an instruction by
 * instruction basis.  So of you change this in a way that doesn't correspond to
 * changes in the function of the same name in yaAGC-Block1-Pultorak, you will
 * have destroyed that capability.  Note also that for pragmatic reasons, the
 * Z register in this simulator is incremented immediately upon starting an
 * instruction, whereas in yaAGC-Block1-Pultorak (which is command-sequence based
 * rather than basic-instruction based, it updates the Z register just prior to
 * the start of the instruction ... so they would never match.  That's why the
 * Z register isn't shown in the log.  You don't lose anything by doing this,
 * except for the knowledge of the overflow bit in Z (which is only set by being
 * copied from the A register), so you haven't lost much at all.
 */

#include <stdio.h>
#include "yaAGCb1.h"

extern int numLogExtras;
extern uint16_t logExtras[];
int logInstruction = 0;

void
logAGC(FILE *logFile, uint16_t lastZ)
{
  int flatAddress, index;
  if (logInstruction)
    fprintf(logFile, "-------------------------------------------------------------------------------------\n");
  if ((regZ& 07777) < 06000 || regBank == 0)
    {
      flatAddress = lastZ & 07777;
      fprintf (logFile, "%04o", flatAddress);
    }
  else
    {
      flatAddress = regBank | (lastZ & 01777);
      fprintf (logFile, "%02o,%04o", regBank >> 10, (lastZ & 07777));
    }
  fprintf (logFile, "\tA=%06o\tQ=%06o\tLP=%06o\tBANK=%03o\tMCT=" FORMAT_64U, regA, regQ, regLP, (regBank >> 10) & 037, agc.countMCT);
  fprintf (logFile, "\n\tOUT0=%05o\tOUT1=%05o\tOUT2=%05o\tOUT3=%05o\tOUT4=%05o", regOUT0, regOUT1, regOUT2, regOUT3, regOUT4);
  fprintf (logFile, "\n\tIN0=%05o\tIN1=%05o\tIN2=%05o\tIN3=%05o", regIN0, regIN1, regIN2, regIN3);
  fprintf (logFile, "\n\tTIME1=%06o\tTIME2=%06o\tTIME3=%06o\tTIME4=%06o", ctrTIME1, ctrTIME2, ctrTIME3, ctrTIME4);
  fprintf (logFile, "\n\tARUPT=%06o\tQRUPT=%06o\tZRUPT=%06o\tBRUPT=%06o\tB=%06o", regARUPT, regQRUPT, regZRUPT, regBRUPT, agc.B);
  fprintf(logFile, "\n\tCYR=%06o\tSR=%06o\tCYL=%06o\tSL=%06o", regCYR, regSR, regCYL, regSL);
  if (numLogExtras > 0)
    {
      int i;
      fprintf(logFile, "\n");
      for (i = 0; i < numLogExtras; i++)
        fprintf(logFile, "\t%05o=%06o", logExtras[i], agc.memory[logExtras[i]]);
    }
  fprintf (logFile, "\n");
  if (logInstruction)
    {
      index = listingAddresses[flatAddress];
      if (index > 0)
        fprintf(logFile, "%s\n", bufferedListing[index]);
      else
        fprintf(logFile, "No source line.\n");
    }
}

