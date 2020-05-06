/*
 * Copyright 2019-20 Ronald S. Burkey <info@sandroid.org>
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
 * Filename:    debug.c
 * Purpose:     This file contains stuff I'm using for debugging yaLVDC as
 * 		I write it.  It does *not* contain the code for yaLVDC's
 * 		features for acting as a debugger for LVDC code (look in gdb.c).
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2019-09-20 RSB  Began
 *              2020-04-30 RSB  Fixed DEBUG_CORE, which referenced a
 *                              non-existent structure.
 *              2020-05-01 RSB  Corrected shift for new way of buffering
 *                              octals in RAM.
 */

#include <stdio.h>
#include "yaLVDC.h"

#ifdef DEBUG

// Prints out some data structures.
void
dPrintouts (void)
{

#if (DEBUG_FLAGS & DEBUG_SYMBOLS) != 0
    {
      int i;
      printf ("\n*** TABLE OF SYMBOLS AND AUTO-ALLOCATED CONSTANTS BY ADDRESS ***\n");
      for (i = 0; i < numSymbols; i++)
	{
	  printf ("%d\t%o\t%02o\t%o\t%03o\t%s\n", i, symbols[i].module,
		  symbols[i].sector, symbols[i].syllable, symbols[i].loc,
		  symbols[i].name);
	}
    }
#endif
#if (DEBUG_FLAGS & DEBUG_SOURCE_LINES) != 0
    {
      int i;
      printf ("\n*** TABLE OF SOURCE CODE ***\n");
      for (i = 0; i < numSourceLines; i++)
	{
	  printf ("%d\t%o\t%02o\t%o\t%03o\t%s\n", i, sourceLines[i].module,
		  sourceLines[i].sector, sourceLines[i].syllable,
		  sourceLines[i].loc, sourceLines[i].line);
	}
    }
#endif
#if (DEBUG_FLAGS & DEBUG_CORE) != 0
    {
      int module, sector, syllable, loc;
      printf ("\n*** TABLE OF CORE MEMORY ***\n");
      for (module = 0; module <= 7; module++)
	for (sector = 0; sector <= 017; sector++)
	  {
	    int empty = 1, offset;
	    // Check if the sector is completely empty.
	    for (syllable = 0; empty && syllable <= 2; syllable++)
	      for (loc = 0; empty && loc <= 0377; loc++)
		if (state.core[module][sector][syllable][loc] != -1)
		  empty = 0;
	    if (empty)
	      continue;
	    // Sector not completely empty, so print it out.
	    printf ("SECTOR\t%o\t%02o\n", module, sector);
	for (offset = 0; offset <= 0377; offset += 8)
	  {
	    printf ("%03o", offset);
	    for (loc = offset; loc < offset + 8; loc++)
	      {
		if (state.core[module][sector][2][loc] != -1)
		  {
		    printf ("\t %09o \tD", state.core[module][sector][2][loc] << 1);
		    continue;
		  }
		if (state.core[module][sector][0][loc] == -1 && state.core[module][sector][1][loc] == -1)
		  {
		    printf ("\t           \t ");
		    continue;
		  }
		if (state.core[module][sector][1][loc] == -1)
		  printf ("\t      ");
		else
		  printf ("\t%05o ", state.core[module][sector][1][loc] << 2);
		if (state.core[module][sector][0][loc] == -1)
		  printf ("     \tD");
		else
		  printf ("%05o\tD", state.core[module][sector][0][loc] << 1);
	      }
	    printf ("\n");
	  }
      }
    }
#endif
}

#endif //DEBUG
