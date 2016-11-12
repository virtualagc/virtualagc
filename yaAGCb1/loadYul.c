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
 * Filename:    loadYul.c
 * Purpose:     Loads a rope-file created by yaYUL.
 * Compiler:    GNU gcc.
 * Contact:     Ron Burkey <info@sandroid.org>
 * Reference:   http://www.ibiblio.org/apollo/index.html
 * Mods:        2016-09-03 RSB  Wrote.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "yaAGCb1.h"

agcBlock1_t agc;

// Load AGC memory from a .bin file created by yaYUL or oct2bin.
// Returns 0 on success, non-zero on error.
int
loadYul(char *filename)
{
  int i;
  unsigned addr, data;
  uint8_t word[2];
  FILE* fp;

  // All of the non-memory parts of the agc structure are zeroed
  // (along with the memory).  Erasable memory above address 060 is
  // then reinitialized to 0166666, which is actually an illegal value
  // that the AGC itself couldn't have used, because all writes to these
  // locations by the AGC are 15-bit only.  Fixed memory is also reinitialized
  // to 0100000, which is also an illegal value, but it's reminiscent of
  // the 00000-but-with-wrong-parity which I'm told missing core locations
  // read back as.  (In the simulator, of course, the 16th bit doesn't
  // represent parity, merely an unused bit that will never have 1 in it
  // normally.)
  memset(&agc, 0, sizeof(agc));
  for (i = 060; i < 02000; i++)
    agc.memory[i] = defaultErasable;
  for (i = 02000; i < sizeof(agc.memory) / 2; i++)
    agc.memory[i] = 0100000;

  fp = fopen(filename, "rb");
  if (fp == NULL)
    return (1);
  for (addr = 02000; addr <= MEMORY_SIZE && 1 == fread(word, 2, 1, fp); addr++)
    {

      // The file-data is big-endian and aligned to the most-significant
      // bit, with a "parity" bit that's always 0 at the least-significant
      // position.  We need it aligned to the least-significant bit, with
      // an odd-parity bit at the most-significant position.
      data = (word[0] << 7) | (word[1] >> 1);
#if 0
      {
        unsigned parity;
        parity = (parity ^ (parity << 8));
        parity = (parity ^ (parity << 4));
        parity = (parity ^ (parity << 2));
        parity = (parity ^ (parity << 1));
        data |= (parity & 0x8000) ^ 0x8000;
      }
#endif
      agc.memory[addr] = data;
    }
  fclose(fp);
  return (0);
}

