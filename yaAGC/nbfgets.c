/*
  Copyright 2003-2005 Ronald S. Burkey <info@sandroid.org>
  
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
 
  Filename:	nbfgets.c
  Purpose:	A portable (i.e., Linux AND Win32) non-blocking variant of fgets. 
  		Requires pthreads (on *nix) or "POSIX Threads for Win32"
		(http://sources.redhat.com/pthreads-win32/).
  Compiler:	GNU gcc.
  Contact:	Ron Burkey <info@sandroid.org>
  Reference:	http://www.ibiblio.org/apollo/index.html
  Mods:		08/09/04 RSB.	Began.
		02/27/05 RSB	Added the license exception, as required by
				the GPL, for linking to Orbiter SDK libraries.
		05/14/05 RSB	Corrected website references.
		07/13/05 RSB	Fixed the of using too much CPU time in Win32.
		07/30/05 JMS    Added use of GNU libreadline to read in the
		                debug command, and source file name completion.
		08/13/05 RSB	Added an initializer for nbfgetsCond, on the
				advice of "grosman".
*/

#include <pthread.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifdef WIN32
#include <windows.h>
#endif

#define MAX_NBFGETS 256
static int nbfgetsInitialized = 0;
static volatile int nbfgetsReady = 0;
static char nbfgetsBuffer[MAX_NBFGETS];
static pthread_cond_t nbfgetsCond = PTHREAD_COND_INITIALIZER;
//static pthread_mutex_t nbfgetsMutex;
static pthread_mutex_t nbfgetsMutex= PTHREAD_MUTEX_INITIALIZER;
static pthread_t nbfgetsThread;

// JMS: These hold the number of source files and the source file
// names. This information is generated in symbol_table.c. To
// decouple from this file, symbol_table.c will update the table
// here instead of this file calling functions in symbol_table.c.
// I would imagine this is temporary until yaAGS supports
// symbolic debugging as well.
#define MAX_NUM_FILES   (128)
#define MAX_FILE_LENGTH (256)
int nbNumberSourceFiles = 0;
char nbSourceFiles[MAX_NUM_FILES][MAX_FILE_LENGTH];

#ifdef USE_READLINE
#include <readline/readline.h>
#include <readline/history.h>

char *source_generator __P ((const char *, int));

// Use to initialize the readline mechanism
static int rl_gets_initialized = 0;

// The current prompt for readline
char nbPrompt[16];
extern char agcPrompt[16];

// Read a string, and return a pointer to it using the GNU
// readline facility. Returns NULL on EOF. Taken from the
// GNU documentation.
static char *
rl_gets (void)
{
  char *line_read = NULL;

  // If we have not yet initialize, do this by setting up
  // the proper callback for file name completion.
  if (!rl_gets_initialized)
    {
      rl_readline_name = "yaAGC";
      rl_completion_entry_function = source_generator;
#ifdef GDBMI
      strcpy (nbPrompt, "(agc) ");
      strcpy (agcPrompt, nbPrompt);
#else
      strcpy (nbPrompt, "> ");
#endif

      rl_gets_initialized = 1;
    }

  // Get a line from the user.
  line_read = readline (nbPrompt);
  strcpy(nbfgetsBuffer, line_read);

  // If the line has any text in it,
  // save it on the history.
  if (line_read && *line_read)
    add_history (line_read);

  free (line_read);
  return (nbfgetsBuffer);
}
#endif // USE_READLINE

// Given a partial string return matches. Successive call to this
// should return success partial matches until there are no more.
char *
source_generator (const char *text, int state)
{
  static int list_index, len;
  char *name;

  if (!state)
    {
      list_index = 0;
      len = strlen (text);
    }

  while (list_index < nbNumberSourceFiles)
    {
      name = nbSourceFiles[list_index];
      list_index++;
      if (strncmp (name, text, len) == 0)
	return (strdup(name));
    }
  
  return (char *)NULL;
}

// Adds a source file to the list, assume we do not exceed this
// list. This facility is temporary anyhow.
void
nbadd_source_file (const char *file)
{
  strcpy (nbSourceFiles[nbNumberSourceFiles], file);
  nbNumberSourceFiles++;
}

// Resets the number of source files to zero. This is needed if
// we reload the symbol table
void
nbclear_files (void)
{
  nbNumberSourceFiles = 0;
}

static void *
nbfgetsThreadFunction (void *Arg)
{
  nbfgetsBuffer[MAX_NBFGETS - 1] = 0;
  while (1)
    {
      // Wait for an input string, presumably sleeping.
#ifdef USE_READLINE
      if (rl_gets() == NULL)
#else
      if (nbfgetsBuffer != fgets (nbfgetsBuffer, MAX_NBFGETS - 1, stdin))
#endif
        {
#ifdef WIN32	    
	  Sleep (10);
#else
	  struct timespec req, rem;
	  req.tv_sec = 0;
	  req.tv_nsec = 10000000;
	  nanosleep (&req, &rem);
#endif // WIN32
          continue;
	}
      nbfgetsReady = 1;
      // Go to sleep until the string has been processed.
      pthread_cond_wait (&nbfgetsCond, &nbfgetsMutex);
    }
}

// Signals to the thread reading in the input from stdin to actually go
// ahead and read.
void
nbfgets_ready (const char *prompt)
{
#ifdef USE_READLINE
  strcpy (nbPrompt, prompt);
#endif
  pthread_cond_broadcast (&nbfgetsCond);
}

// Returns NULL until a string is ready.  The string is always fetched from
// stdin, and has a maximum size of MAX_NBFGETS (including the nul-terminator).
// (In other words, making Length bigger than MAX_NBFGETS has the same effect
// as making it equal to MAX_NBFGETS.)  Length also includes the nul-termination.

char *
nbfgets (char *Buffer, int Length)
{
  if (!nbfgetsInitialized)
    {
      // We haven't started the other thread yet.  Better do that.
      nbfgetsReady = 0;
      pthread_create (&nbfgetsThread, NULL, nbfgetsThreadFunction, NULL);
      nbfgetsInitialized = 1;
    }
  // Has the other thread managed to fetch a string yet?
  if (!nbfgetsReady || Length < 1)
    return (NULL);// No string ready yet.
  Length--;
  strncpy (Buffer, nbfgetsBuffer, Length);
  Buffer[Length] = 0;		// Make sure nul-terminated.
  nbfgetsReady = 0;
  // Tell the other thread to wake up and get another string.
  //pthread_cond_broadcast (&nbfgetsCond);
  return (Buffer);
}

#if 0
// A test program.
int
main (void)
{
  char String[100] = { 0 };
  setvbuf (stdout, NULL, _IONBF, 0);
  while (1)
    {
      printf ("> ");
      while (NULL == nbfgets (String, sizeof (String)));
      printf ("< %s", String);
    }
}
#endif //0

