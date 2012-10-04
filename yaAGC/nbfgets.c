/*
  Copyright 2003-2005,2008-2010 Ronald S. Burkey <info@sandroid.org>
  
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
		06/13/08 OH	Intercept rl_getc_function to ignore LF
		04/24/09 RSB	Added some conditioning for some readline stuff.
		08/01/09 RSB	I believe that the return value of readline()
				was being treated incorrectly, in that EOF was
				being checked for in the returned string when
				actually the returned string would be NULL, 
				thus causing a segfault.  Also, added WIN32-only
				checking for goofiness in the return values of
				readline() and rl_getc().
		08/02/09 RSB	Tried to make it work again without readline
				support.
		11/22/10 RSB    Eliminated a compiler warning I encountered
                                in Ubuntu 10.04.
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


#ifdef USE_READLINE //--------------------------------------------

#include <readline/readline.h>
#include <readline/history.h>


// Use to initialize the readline mechanism
static int rl_gets_initialized = 0;

// The current prompt for readline
char nbPrompt[16];
extern char agcPrompt[16];


char * source_generator (const char *text, int state)
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
	return ((void *) strdup(name));
  }
  
  return (void *)NULL;
}

/**
 * Why sometimes the input stream returns huge numbers is beyond me
 * Maybe a Code::Blocks stream issue
 * ... [RSB] The readline documentation does not describe what the 
 * legal return values of rl_getc() are.  There's no reason to suppose
 * (without going through the rl_getc() source code) that they are 
 * always 8-bit characters.  so we need to catch illegal characters
 * and fix them somehow.  On Vista, all kinds of rotten garbage can be
 * returned, so we go out of our way to reject and clear the input
 * buffer in this case.
 */
int rl_getchar(FILE *stream)
{
#if 0 // RSB

   char c;
#ifdef WIN32
   while ((c = (char) rl_getc(stream) ) == 10); /* Ignore LF */
#else
   c = /*(char)*/ rl_getc (stream);
#endif
   return ((int)c);
   
#else // 0

  int c;
  while (1)
    {
      c = rl_getc (stream);
#ifdef WIN32
      if (c == '\n')
        continue;
#endif
      if (c < 1 || c >= 0x7F)
        continue;
      break;
    }
  return (c);

#endif // 0
}


// Read a string, and return a pointer to it using the GNU
// readline facility. Returns NULL on EOF. Taken from the
// GNU documentation.
static char * rl_gets (void)
{
   char *line_read = NULL;

   // If we have not yet initialize, do this by setting up
   // the proper callback for file name completion.
   if (!rl_gets_initialized)
   {
     rl_readline_name = "yaAGC";
     rl_completion_entry_function = source_generator;
#ifdef GDBMI
     strcpy (nbPrompt, agcPrompt);
#else
     strcpy (nbPrompt, "> ");
#endif
     rl_gets_initialized = 1;
   }

   // Get a line from the user.
   do
   {
      line_read = readline (NULL);
#ifdef WIN32
      // In Vista, there are circumstances where tremendous garbage is
      // returned here.  So we try to recover.
      // ... Sadly, these goggles do nothing!
      if (line_read != NULL)
	{
	  char *s;
	  for (s = line_read; *s; s++)
	    {
	      if (*s < ' ' || *s >= 0x7F)
	        {
		  free (line_read);
		  line_read = NULL;
		  break;
		}
	    }
	}
#endif   
   } while (line_read == NULL);
   strcpy(nbfgetsBuffer, line_read);
	 
   // If the line has any text in it,
   // save it on the history.
   if (line_read && *line_read ) add_history (line_read);

   free (line_read);
   return (nbfgetsBuffer);
}

#endif // USE_READLINE --------------------------------------------------


// Adds a source file to the list, assume we do not exceed this
// list. This facility is temporary anyhow.
void nbadd_source_file (const char *file)
{
  strcpy (nbSourceFiles[nbNumberSourceFiles], file);
  nbNumberSourceFiles++;
}

/** 
 * Resets the number of source files to zero. This is needed if
 * we reload the symbol table
 */
void nbclear_files (void)
{
  nbNumberSourceFiles = 0;
}

static void * nbfgetsThreadFunction (void *Arg)
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
      pthread_mutex_lock(&nbfgetsMutex);
      if (pthread_cond_wait (&nbfgetsCond, &nbfgetsMutex) != 0)
      {
      	fputs("pthread error\n",stderr);
      }
      pthread_mutex_unlock(&nbfgetsMutex);     
    }
  // This function doesn't actually return, but I've
  // put in the following line to avoid a compiler
  // warning in some compiler versions.
  return (NULL);
}

// Signals to the thread reading in the input from stdin to actually go
// ahead and read.
void nbfgets_ready (const char *prompt)
{
   pthread_mutex_lock(&nbfgetsMutex);
   pthread_cond_broadcast (&nbfgetsCond);
   pthread_mutex_unlock(&nbfgetsMutex);
}

// Returns NULL until a string is ready.  The string is always fetched from
// stdin, and has a maximum size of MAX_NBFGETS (including the nul-terminator).
// (In other words, making Length bigger than MAX_NBFGETS has the same effect
// as making it equal to MAX_NBFGETS.)  Length also includes the nul-termination.

char * nbfgets (char *Buffer, int Length)
{
  if (!nbfgetsInitialized)
  {
#ifdef USE_READLINE
      rl_getc_function = rl_getchar;
#endif      
      
      // We haven't started the other thread yet.  Better do that.
      nbfgetsReady = 0;
      pthread_cond_init (&nbfgetsCond,NULL);
      pthread_mutex_init (&nbfgetsMutex,NULL);
      pthread_create (&nbfgetsThread, NULL, nbfgetsThreadFunction, NULL);
      nbfgetsInitialized = 1;
  }

  // Has the other thread managed to fetch a string yet?
  if (!nbfgetsReady || Length < 1)
    {
      return (NULL);		// No string ready yet.
    }
  Length--;
  strncpy (Buffer, nbfgetsBuffer, Length);
  Buffer[Length] = 0;		// Make sure nul-terminated.
  nbfgetsReady = 0;
#ifndef USE_READLINE  
  // Tell the other thread to wake up and get another string.
  pthread_cond_broadcast (&nbfgetsCond);
#endif  
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

