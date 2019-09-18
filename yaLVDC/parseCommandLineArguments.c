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
 * Filename:    parseCommandLineArguments.c
 * Purpose:     Parses the command line for yaLVDC.c.
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2019-09-18 RSB  Began.
 */

#include <stdio.h>
#include <string.h>
#include "yaLVDC.h"

static char helpMessage[] = "Usage:\n"
    "              yaLVDC [OPTIONS]\n"
    "The available OPTIONS are:\n"
    "--assembly=B  Provides a base name for the output of an assembly\n"
    "              performed by the program yaASM.py.  B defaults to yaLVDC.\n"
    "              The program will try to read the files B.tsv, B.sym, and\n"
    "              B.src.  Respectively, these are the core rope, symbol\n"
    "              table, and source lines (vs address).  The B.tsv file\n"
    "              defines the initial contents of rope memory, unless\n"
    "              a --core file (see below) overrides it.  The B.sym and\n"
    "              B.src files are used for symbolic debugging. Multiple\n"
    "              --assembly arguments can be used if several programs are\n"
    "              overlaid in core memory.\n"
    "--core=F      The initial core-rope image is in filename F. The default\n"
    "              is yaLVDC.core.  Note that the file will be periodically\n"
    "              modified during emulation as core memory changes.  If the\n"
    "              file does not exist initially, then the initial state is\n"
    "              instead taken from the --assembly file, but the --core\n"
    "              file will still be created and periodically updated.\n"
    "";

char *assemblyBasenames[MAX_PROGRAMS] =
  { "yaLVDC" };
char *coreRopeFilename = "yaLVDC.core";

// Parse a set of command-line arguments and set global variables based
// on them.
int
parseCommandLineArguments (int argc, char *argv[])
{
  int retVal = 1;
  int i, jAssembly = 0;

  for (i = 1; i < argc; i++)
    {
      if (!strncmp (argv[i], "--assembly=", 11))
	{
	  if (jAssembly >= MAX_PROGRAMS)
	    {
	      fprintf (stderr, "Too many --assembly arguments.\n");
	      goto help;
	    }
	  assemblyBasenames[jAssembly++] = &argv[i][11];
	}
      else if (!strncmp (argv[i], "--core=", 7))
	{
	  coreRopeFilename = &argv[i][7];
	}
      else if (!strcmp (argv[i], "--help"))
	goto help;
      else
	{
	  fprintf (stderr, "Unrecognized argument: %s\n", argv[i]);
	  help: ;
	  fprintf (stderr, "%s", helpMessage);
	  goto done;
	}
    }

  retVal = 0;
  done: ;
  return (retVal);
}

