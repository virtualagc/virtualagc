/*
 * Copyright 2003-2005,2008-2016 Ronald S. Burkey <info@sandroid.org>
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
 * Filename:	nbfgets.c
 * Purpose:	A portable (i.e., Linux AND Win32) non-blocking variant of fgets.
 * 		Requires pthreads (on *nix) or "POSIX Threads for Win32"
 * 		(http://sources.redhat.com/pthreads-win32/).
 * Compiler:	GNU gcc.
 * Contact:	Ron Burkey <info@sandroid.org>
 * Reference:	http://www.ibiblio.org/apollo/index.html
 * Mods:	08/09/04 RSB.	Began.
 * 		02/27/05 RSB	Added the license exception, as required by
 * 				the GPL, for linking to Orbiter SDK libraries.
 * 		05/14/05 RSB	Corrected website references.
 * 		07/13/05 RSB	Fixed the of using too much CPU time in Win32.
 * 		07/30/05 JMS    Added use of GNU libreadline to read in the
 * 		                debug command, and source file name completion.
 * 		08/13/05 RSB	Added an initializer for nbfgetsCond, on the
 * 				advice of "grosman".
 * 		06/13/08 OH	Intercept rl_getc_function to ignore LF
 * 		04/24/09 RSB	Added some conditioning for some readline stuff.
 * 		08/01/09 RSB	I believe that the return value of readline()
 * 				was being treated incorrectly, in that EOF was
 * 				being checked for in the returned string when
 * 				actually the returned string would be NULL,
 * 				thus causing a segfault.  Also, added WIN32-only
 * 				checking for goofiness in the return values of
 * 				readline() and rl_getc().
 * 		08/02/09 RSB	Tried to make it work again without readline
 * 				support.
 * 		11/22/10 RSB    Eliminated a compiler warning I encountered
 *                              in Ubuntu 10.04.
 *              09/03/16 RSB    Pulled this into yaAGC-Block1-Pultorak/ from
 *                              yaAGC/, because I don't want dependencies,
 *                              because I'm developing in a different branch
 *                              of the git repo, in which yaAGC/ doesn't exist,
 *                              and simplified ... not a value judgement on the
 *                              stuff I removed, just trying to achieve maximal
 *                              simplicity for myself at this exact instant in
 *                              time.  The original stuff still exists in yaAGC
 *                              and could be substituted if desired.
 */

#include <pthread.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifdef WIN32
#include <winsock2.h>
#include <windows.h>
#endif

#define MAX_NBFGETS 256
static int nbfgetsInitialized = 0;
static volatile int nbfgetsReady = 0;
static char nbfgetsBuffer[MAX_NBFGETS];
static pthread_cond_t nbfgetsCond = PTHREAD_COND_INITIALIZER;
//static pthread_mutex_t nbfgetsMutex;
static pthread_mutex_t nbfgetsMutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_t nbfgetsThread;

static void *
nbfgetsThreadFunction(void *Arg)
{
  nbfgetsBuffer[MAX_NBFGETS - 1] = 0;
  while (1)
    {
      // Wait for an input string, presumably sleeping.
      if (nbfgetsBuffer != fgets(nbfgetsBuffer, MAX_NBFGETS - 1, stdin))
        {
#ifdef WIN32	    
          Sleep (10);
#else
          struct timespec req, rem;
          req.tv_sec = 0;
          req.tv_nsec = 10000000;
          nanosleep(&req, &rem);
#endif // WIN32
          continue;
        }

      nbfgetsReady = 1;

      // Go to sleep until the string has been processed.
      pthread_mutex_lock(&nbfgetsMutex);
      if (pthread_cond_wait(&nbfgetsCond, &nbfgetsMutex) != 0)
        {
          fputs("pthread error\n", stderr);
        }
      pthread_mutex_unlock(&nbfgetsMutex);
    }
  // This function doesn't actually return, but I've
  // put in the following line to avoid a compiler
  // warning in some compiler versions.
#ifndef SOLARIS
  return (NULL);
#endif
}

// Signals to the thread reading in the input from stdin to actually go
// ahead and read.
void
nbfgets_ready(void)
{
  pthread_mutex_lock(&nbfgetsMutex);
  pthread_cond_broadcast(&nbfgetsCond);
  pthread_mutex_unlock(&nbfgetsMutex);
}

// Returns NULL until a string is ready.  The string is always fetched from
// stdin, and has a maximum size of MAX_NBFGETS (including the nul-terminator).
// (In other words, making Length bigger than MAX_NBFGETS has the same effect
// as making it equal to MAX_NBFGETS.)  Length also includes the nul-termination.

char *
nbfgets(char *Buffer, int Length)
{
  if (!nbfgetsInitialized)
    {

      // We haven't started the other thread yet.  Better do that.
      nbfgetsReady = 0;
      pthread_cond_init(&nbfgetsCond, NULL);
      pthread_mutex_init(&nbfgetsMutex, NULL);
      pthread_create(&nbfgetsThread, NULL, nbfgetsThreadFunction, NULL);
      nbfgetsInitialized = 1;
    }

  // Has the other thread managed to fetch a string yet?
  if (!nbfgetsReady || Length < 1)
    {
      return (NULL);		// No string ready yet.
    }
  Length--;
  strncpy(Buffer, nbfgetsBuffer, Length);
  Buffer[Length] = 0;		// Make sure nul-terminated.
  nbfgetsReady = 0;
  // Tell the other thread to wake up and get another string.
  pthread_cond_broadcast(&nbfgetsCond);
  return (Buffer);
}

