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
 * Filename:    parseCommandLineArguments.c
 * Purpose:     Parses the command line for yaLVDC.c.
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2019-09-18 RSB  Began.
 *              2020-04-29 RSB  Resumed development (including --ptc).
 *              2023-08-04 RSB  Added --log-pio.
 *              2023-08-08 RSB  Added --multiplier.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include "yaLVDC.h"

static char helpMessage[] = "Usage:\n"
    "              yaLVDC [OPTIONS]\n"
    "The available OPTIONS are:\n"
    "--assembly=B   Provides a base name for the output of an assembly\n"
    "               performed by the program yaASM.py.  B defaults to yaLVDC.\n"
    "               The program will try to read the files B.tsv, B.sym, and\n"
    "               B.src.  Respectively, these are the core memory, symbol\n"
    "               table, and source lines (vs address).  The B.tsv file\n"
    "               defines the initial contents of core memory, unless\n"
    "               a --core file (see below) overrides it.  The B.sym and\n"
    "               B.src files are used for symbolic debugging. Multiple\n"
    "               --assembly arguments can be used if several programs are\n"
    "               overlaid in core memory.\n"
    "--cold-start   If used, does not load a core-memory image (see --core)\n"
    "               upon startup.\n"
    "--core=F       The initial core-memory image is filename F. The default\n"
    "               is yaLVDC.core.  Note that the file will be periodically\n"
    "               modified during emulation as core memory changes.  If the\n"
    "               file does not exist initially, then the initial state is\n"
    "               instead taken from the --assembly file, but the --core\n"
    "               file will still be created and periodically updated.\n"
    "--log-pio=N    Logs PIO instructions to a file called yaLVDC.pio.\n"
    "               N is a set of flags to determine what's logged:\n"
    "                    1     Outputs\n"
    "--ptc          Emulate a PTC target rather than an LVDC target.\n"
    "--run          Start the LVDC/PTC program running freely.  By default,\n"
    "               (without --run), will simply pause without running.\n"
    "               This relates only to the built-in yaLVDC debugger.\n"
    "--panel-pause  Start the PTC program in a paused state relative to\n"
    "               control by the PTC front panel.  By default (without\n"
    "               --panel-pause), the emulation will be running freely.\n"
    "               This is unrelated to the built-in yaLVDC debugger, and\n"
    "               has no effect on whether a debugger prompt appears.\n"
    "--port=N       Specifies the port number used by the server for virtual\n"
    "               connection to peripherals.  Default is 19653.\n"
    "--divisor=N    Slows down the emulated CPU clock by a factor of N (with\n"
    "               the default obviously being 1).  This is intended to be\n"
    "               used with very slow peripheral emulations, such as \n"
    "               yaPTC.py that cannot keep up with yaLVDC otherwise.\n"
    "--multiplier=N Speeds up the emulated CPU clock by a factor of N \n"
    "               (default 1), primarily useful for repeatable flight test\n"
    "               mode, which requires no peripherals at all.  Can be used\n"
    "               with --divisor to get fractional adjustments.\n"
    "               WARNING: If you pause or exit yaLVDC but notice\n"
    "               continuing updates to peripherals such as telemetry, then\n"
    "               you are running TOO FAST and may find that the memory\n"
    "               used by the operating system's networking buffers\n"
    "               increases without limit.  Reduce the multiplier.\n"
    "The following comment applies only to PTC emulation, and not to LVDC.\n"
    "Regarding debugging using the yaLVDC built-in debugger vs the PTC panel's\n"
    "debugging features, such as the emulated PTC program being paused, single\n"
    "stepped, breakpointed, and so on, these two debugging capabilities\n"
    "are separate and essentially independent.  To a certain extent they can\n"
    "coexist without problems, but it is best to avoid using the yaLVDC debugger\n"
    "when using the PTC debugging, and vice-versa.  Specifically, to use the\n"
    "PTC debugger you'd normally allow the yaLVDC debugger to free-run the\n"
    "emulation, while to use the yaLVDC debugger you'd allow the PTC panel to\n"
    "free run the CPU.  Thus the command-line switches --run and --panel-pause\n"
    "would generally be used together (for PTC emulations), or not at all.\n"
    "";

char *coreFilename = "yaLVDC.core";
int ptc = 0;
int coldStart = 0;
int pioLogFlags = 0;
FILE *pioLogFile = NULL;

// Parse a set of command-line arguments and set global variables based
// on them.
int
parseCommandLineArguments (int argc, char *argv[])
{
  int retVal = 1;
  int i, j;

  for (i = 1; i < argc; i++)
    {
      if (!strncmp (argv[i], "--assembly=", 11))
	{
	  if (numAssemblies >= MAX_ASSEMBLIES)
	    {
	      printf ("Too many --assembly arguments\n");
	      goto help;
	    }
	  assemblies[numAssemblies++].name = &argv[i][11];
	}
      else if (!strncmp (argv[i], "--core=", 7))
	coreFilename = &argv[i][7];
      else if (!strncmp (argv[i], "--log-pio=", 10))
        {
          pioLogFlags = atoi(&argv[i][10]);
          if (pioLogFlags != 0)
            {
              pioLogFile = fopen("yaLVDC.pio", "w");
              if (pioLogFile == NULL)
                  pioLogFlags = 0;
            }
        }
      else if (!strcmp (argv[i], "--ptc"))
        ptc = 1;
      else if (1 == sscanf(argv[i], "--port=%d", &j))
        PortNum = j;
      else if (!strcmp (argv[i], "--cold-start"))
        coldStart = 1;
      else if (!strcmp (argv[i], "--run"))
        runStepN = INT_MAX;
      else if (!strcmp (argv[i], "--panel-pause"))
        panelPause = 2;
      else if (1 == sscanf(argv[i], "--divisor=%d", &j))
        clockDivisor = j;
      else if (1 == sscanf(argv[i], "--multiplier=%d", &j))
        {
          clockMultiplier = j;
          parmClockMultiplier = j;
        }
      else if (!strcmp (argv[i], "--help"))
	goto help;
      else
	{
	  printf ("Unrecognized command-line argument: %s\n", argv[i]);
	  help: ;
	  fprintf (stderr, "%s", helpMessage);
	  goto done;
	}
    }

  retVal = 0;
  done: ;
  return (retVal);
}

