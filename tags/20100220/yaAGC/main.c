/*
  Copyright 2003-2005,2007 Ronald S. Burkey <info@sandroid.org>
            2008-2009      Onno Hommes

  This file is part of yaAGC.

  yaAGC is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  yaAGC is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with yaAGC; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

  In addition, as a special exception, Ronald S. Burkey gives permission to
  link the code of this program with the Orbiter SDK library (or with
  modified versions of the Orbiter SDK library that use the same license as
  the Orbiter SDK library), and distribute linked combinations including
  the two. You must obey the GNU General Public License in all respects for
  all of the code used other than the Orbiter SDK library. If you modify
  this file, you may extend this exception to your version of the file,
  but you are not obligated to do so. If you do not wish to do so, delete
  this exception statement from your version.

  Filename:	main.c
  Purpose:	A top-level program for running the AGC simulation\
  		in a PC environment.
  Compiler:	GNU gcc.
  Contact:	Onno Hommes <virtualagc@googlegroups.com>
  Reference:	http://www.ibiblio.org/apollo/index.html
  Mods:
		04/05/03 RSB	Began the AGC project
		02/03/08 OH	Start adding GDB/MI interface
		08/23/08 OH	Only support GDB/MI and not proprietary debugging
		03/12/09 OH	Complete re-write of the main function
		03/23/09 OH	Reduced main to bare minimum
		04/16/09 OH 	Merge April changes from RSB
		04/24/09 RSB	Added #include for pthreads.h.
*/

#include "agc_cli.h"
#include "agc_simulator.h"
#ifdef PTW32_STATIC_LIB
#include <pthread.h>
#endif

/**
The AGC main function from here the Command Line is parsed, the
Simulator is initialized and subsequently executed.
*/
int main (int argc, char *argv[])
{
#ifdef PTW32_STATIC_LIB
    // You wouldn't need this if I had compiled pthreads_w32 as a DLL.
    pthread_win32_process_attach_np ();
#endif

	/* Delclare Options and parse the command line */
	Options_t *Options = CliParseArguments(argc, argv);

	/* Initialize the Simulator and debugger if enabled
	 * if the initialization fails or Options is NULL then the simulator will
	 * return a non zero value and subsequently bail and exit the program */
	if (SimInitialize(Options) == SIM_E_OK) SimExecute();

#ifdef PTW32_STATIC_LIB
    // You wouldn't need this if I had compiled pthreads_w32 as a DLL.
    pthread_win32_process_detach_np ();
#endif

	return (0);
}


