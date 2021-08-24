/*
 * Copyright 2019 Ronald S. Burkey <info@sandroid.org>
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
 * Filename:    readWriteCore.c
 * Purpose:     This file contains routines for reading and writing a file
 * 		containing snapshots of the core-memory.
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2019-09-20 RSB  Began
 *
 * For simplicity, we simply directly read/write the using the internal
 * structures containing the memory contents rather than making the (slight)
 * extra effort two write portable structures instead.  I suspect the
 * files are portable anyway, other than byte-ordering within 32-bit integers,
 * but given the demise of most non-x86/ARM CPU architectures, I suspect even
 * that's 99% portable.
 *
 * I probably should read/write additional stuff that doesn't have an address,
 * like the accumulator ... I'll get to it later after I do more research.
 */

#include <stdio.h>
#include "yaLVDC.h"

int
readCore (void)
{
  int retVal = 1;
  FILE *fp = NULL;

  // Note that a missing file is not an error.
  fp = fopen (coreFilename, "rb");
  if (fp != NULL)
    {
      int module, sector, syllable, loc;
      int32_t value;
      if (1 != fread (&state, sizeof(state), 1, fp))
	{
	  printf ("Cannot read core-memory file: %s\n", coreFilename);
	  goto done;
	}
      // Do a sanity check.
      for (module = 0; module <= 07; module++)
	for (sector = 0; sector <= 017; sector++)
	  for (syllable = 0; syllable <= 2; syllable++)
	    for (loc = 0; loc <= 0377; loc++)
	      {
		value = state.core[module][sector][syllable][loc];
		if (value == -1)
		  continue;
		if (value < 0)
		  goto corrupted;
		if (syllable == 0)
		  {
		    if (value > 077777)
		      goto corrupted;
		    if ((value & 040001) != 0)
		      goto corrupted;
		  }
		else if (syllable == 1)
		  {
		    if (value > 077777)
		      goto corrupted;
		    if ((value & 000003) != 0)
		      goto corrupted;
		  }
		else // syllable == 2
		  {
		    if (value > 0777777777)
		      goto corrupted;
		    if ((value & 1) != 0)
		      goto corrupted;
		    if (state.core[module][sector][0][loc] != -1)
		      goto corrupted;
		    if (state.core[module][sector][1][loc] != -1)
		      goto corrupted;
		  }
	      }
    }
  retVal = writeCore ();

  done: ;
  if (0)
    {
      corrupted: ;
      printf ("Core-memory file corrupted: %s\n", coreFilename);
    }
  if (fp != NULL)
    fclose (fp);
  return (retVal);
}

int
writeCore (void)
{
  int retVal = 1;
  FILE *fp = NULL;

  fp = fopen (coreFilename, "wb");
  if (fp == NULL)
    {
      printf ("Cannot create core-memory file: %s\n", coreFilename);
      goto done;
    }
  if (1 != fwrite (&state, sizeof(state), 1, fp))
    {
      printf ("Cannot write to core-memory file: %s\n", coreFilename);
      goto done;
    }

  retVal = 0;
  done: ;
  if (fp != NULL)
    fclose (fp);
  return (retVal);
}
