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
 * Filename:    loadPads.c
 * Purpose:     Loads a pad-load file created somehow.
 * Compiler:    GNU gcc.
 * Contact:     Ron Burkey <info@sandroid.org>
 * Reference:   http://www.ibiblio.org/apollo/index.html
 * Mods:        2016-09-08 RSB  Wrote.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "yaAGCb1.h"

/*
 * Load pad-loads from a file which has probably been created manually.
 * Such a file is ASCII, consisting of lines, each of which is of the
 * form
 *
 *      %o %o
 *
 * where the first field is an address in erasable (0-1777), and the
 * second is a value of up to 16 bits to store at that location.  However,
 * only 15 bits are used by the simulator, so if the 16th bit is 1, it
 * will indicate an illegal value.
 *
 * Any lines whose initial portions aren't of this form are ignored,
 * so you can add blank lines an comments almost at will, though I'd
 * suggest only adding comments beginning with the # character.
 *
 * This function is intended to be called *after* loadYUL(), since
 * loadYUL() will initialize all of erasable memory, and hence would
 * overwrite any changes made by this function.
 *
 * Note that for Solarium 055, these pad loads are a necessity rather than
 * a luxury, since the waitlist will not be initialized otherwise, and
 * Solarium 055 will behave in an an obnoxious way.  Thus at the very
 * least, the list of 8 locations beginning at LST2 must be all set to
 * CADR ENDTASK.
 *
 * Returns 0 on success, non-zero on error.
 */
int
loadPads(char *filename)
{
  int i;
  unsigned addr, data;
  char s[1024];
  uint8_t word[2];
  FILE* fp;

  fp = fopen (filename, "r");
  if (fp == NULL)
    return (1);

  while (NULL != fgets (s, sizeof(s), fp))
    {
      if (2 == sscanf(s, "%o %o", &addr, &data) && addr < 02000 && data < 0x10000)
        {
          printf ("Pad load erasable[%04o] = %06o\n", addr, data);
          agc.memory[addr] = data;
        }
      else if (2 == sscanf(s, "%o %o", &addr, &data) && addr >= 02000 && addr < MEMORY_SIZE && data < 0x10000)
        {
          if (addr < 06000)
            printf ("Patch fixed[%04o] = %06o\n", addr, data);
          else
            printf ("Patch fixed[%02o,%04o] = %06o\n", addr / 02000, 06000 + addr % 02000, data);
          agc.memory[addr] = data;
        }
    }

  fclose(fp);
  return (0);
}

