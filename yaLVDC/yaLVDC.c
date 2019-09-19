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
 * Filename:    yaLVDC.c
 * Purpose:     Emulator for LVDC CPU
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2019-09-18 RSB  I originally intended to add LVDC-emulation
 * 				capability the the yaOBC program, but I'm
 * 				just too lazy and would prefer to write it
 * 				from scratch.
 */

#include <stdio.h>
#include "yaLVDC.h"

int
main (int argc, char *argv[])
{
  int retVal = 1;
  int i;

  if (parseCommandLineArguments (argc, argv))
    goto done;
  if (readAssemblies (assemblyBasenames, MAX_PROGRAMS))
    goto done;

#define DEBUG
#ifdef DEBUG
  if (0)
    {
      int i;
      for (i = 0; i < numSymbols; i++)
	{
	  printf ("%d\t%o\t%02o\t%o\t%03o\t%s\n", i, symbols[i].module,
		  symbols[i].sector, symbols[i].syllable, symbols[i].loc,
		  symbols[i].name);
	}
    }
  if (0)
    {
      int i;
      for (i = 0; i < numSymbolsByName; i++)
	{
	  printf ("%d\t%o\t%02o\t%o\t%03o\t%s\n", i, symbolsByName[i].module,
		  symbolsByName[i].sector, symbolsByName[i].syllable,
		  symbolsByName[i].loc, symbolsByName[i].name);
	}
    }
  if (0)
    {
      int i;
      for (i = 0; i < numSourceLines; i++)
	{
	  printf ("%d\t%o\t%02o\t%o\t%03o\t%s\n", i, sourceLines[i].module,
		  sourceLines[i].sector, sourceLines[i].syllable,
		  sourceLines[i].loc, sourceLines[i].line);
	}
    }
  if (1)
    {
      int module, sector, syllable, loc;
      for (module = 0; module <= 7; module++)
	for (sector = 0; sector <= 017; sector++)
	  {
	    int empty = 1, offset;
	    // Check if the sector is completely empty.
	    for (syllable = 0; empty && syllable <= 2; syllable++)
	      for (loc = 0; empty && loc <= 0377; loc++)
		if (rope[module][sector][syllable][loc] != -1)
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
		if (rope[module][sector][2][loc] != -1)
		  {
		    printf ("\t %09o \tD", rope[module][sector][2][loc]);
		    continue;
		  }
		if (rope[module][sector][0][loc] == -1 && rope[module][sector][1][loc] == -1)
		  {
		    printf ("\t           \t ");
		    continue;
		  }
		if (rope[module][sector][1][loc] == -1)
		  printf ("\t      ");
		else
		  printf ("\t%05o ", rope[module][sector][1][loc]);
		if (rope[module][sector][0][loc] == -1)
		  printf ("     \tD");
		else
		  printf ("%05o\tD", rope[module][sector][0][loc]);
	      }
	    printf ("\n");
	  }
      }
}
#endif

retVal = 0;
done: ;
for (i = 0; i < numErrorMessages; i++)
fprintf (stderr, "%s\n", errorMessageStack[i]);
return (retVal);
}
