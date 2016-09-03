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
 * Filename:    executeOneInstruction.c
 * Purpose:     Executes a single instruction on the virtual AGC.
 * Compiler:    GNU gcc.
 * Contact:     Ron Burkey <info@sandroid.org>
 * Reference:   http://www.ibiblio.org/apollo/index.html
 * Mods:        2016-09-03 RSB  Wrote.
 */

#include <time.h>
#include "yaAGCb1.h"

void
executeOneInstruction (void)
{
  uint16_t flatAddress, instruction, operand, dummy;

  flatAddress = (regZ < 06000) ? regZ : flatten(regBank, regZ);
  regZ = (regZ & ~01777) + ((regZ + 1) & 01777);
  instruction = agc.memory[flatAddress];
  operand = instruction & 007777;

  switch (instruction & 070000)
  {
  case 000000: // TC
    agc.countMCT += 1;
    regZ = instruction;
    break;
  case 030000:
    agc.countMCT += 2;
    if (operand < 02000) // XCH
      {
        dummy = regA;
        regA = agc.memory[operand];
        agc.memory[operand] = dummy;
      }
    else  // CAF
      {
        if (operand < 06000)
          regA = agc.memory[operand];
        else
          regA = agc.memory[flatten(regBank, operand)];
      }
    break;
  case 050000:
    agc.countMCT += 2;
    if (operand < 02000) // TS
      {
        if (&agc.memory[operand] == &regBank)
          agc.memory[operand] = regA & 037;
        else
          agc.memory[operand] = regA;
      }
    else  // ???
      {
      }
    break;
  default:
    agc.countMCT += 2;
    break;
  }

}
