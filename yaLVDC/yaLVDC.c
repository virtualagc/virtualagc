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

  if (parseCommandLineArguments(argc, argv)) goto done;
  if (readAssemblies(assemblyBasenames, MAX_PROGRAMS)) goto done;

  /*
  {
      int i;
      for (i = 0; i < numSymbols; i++)
	{
	  printf ("%d\t%s\t%o\t%02o\t%o\t%03o\n", i, symbols[i].name,
	    symbols[i].module, symbols[i].sector, symbols[i].syllable,
	    symbols[i].loc);
	}
  }
  */

  retVal = 0;
  done:;
  return (retVal);
}
