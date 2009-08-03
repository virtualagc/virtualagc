/*
  Copyright 2005,2009 Ronald S. Burkey <info@sandroid.org>
  
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
 
  Filename:	WinAGC.c
  Purpose:	This is a process manager for Virtual AGC in Win32.
   		It allows an orderly shutdown of all Virtual AGC processes
		after you exit from any one process.  (In other words
		exiting yaDSKY can shutdown yaAGC as well, and vice versa.)
		I was able to accomplish this perfectly well in Linux just
		with shell scripts, but Win32 is so crippled that I had
		to write an exe file to do it.  (Windows XP Pro contains
		programs TASKLIST and TASKKILL that allow appropriate scripts
		to be written, but Windows XP Home, and probably every other
		earlier version of Windows does not.)
  Compiler:	GNU gcc.
  Contact:	Ron Burkey <info@sandroid.org>
  Reference:	http://www.ibiblio.org/apollo/index.html
  Mods:		07/12/05 RSB	Created.  Note:  Right now, there's a
  			        problem with this program in that if
				you run yaAGC under it, it essentially 
				uses up all available CPU time. (Whereas 
				if you run yaAGC from a command line 
				or a batch file, it takes an immeasurably 
				small amount of CPU time.)
  		03/08/09 RSB	Tried a workaround for the 100% CPU time
				mentioned above. Increased the max command-line
				length from 128 to 256.
		04/25/09 RSB	Allow the startup delay to be changed from
				the command line, and changed the default to
				0 (was hard-coded at 30 seconds)
		08/02/09 RSB	The arbitrary limit I placed on command-line
				length was too arbitrary, and is easily 
				exceeded when command-line debugging is performed.
				Increased it from 256 to 2048, which should be
				tremendous overkill.

  This program expects to receive a list of command-lines for processes,
  separated by \n and/or \r, on the standard input.  It ignores white lines
  and lines that begin with '#'.
  
  For example, if the file test.txt contained
    	yaAGC --core=Luminary131.bin --cfg=LM.ini
	start yaDSKY --cfg=LM.ini --test-downlink
  then 
  	WinAGC <test.txt
  would execute the two commands shown, as separate processes, closing them
  both down when either one of them terminated.  
*/

#include <windows.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>

#define MAX_PROCESSES 20
#define MAX_LENGTH 2048
static char CommandLines[MAX_PROCESSES][MAX_LENGTH + 1];
STARTUPINFO si[MAX_PROCESSES];
PROCESS_INFORMATION pi[MAX_PROCESSES];
static int NumProcesses;

static int StartupDelay = 0;

static char s[MAX_LENGTH + 1];

int
main (int argc, char *argv[])
{
  int i, j;
  char *ss;

  // Read the command-line options.
  for (i = 1; i < argc; i++)
    if (1 == sscanf (argv[i], "--startup-delay=%d", &j))
      StartupDelay = j;

  // Read the input file.
  for (NumProcesses = 0;
       NumProcesses < MAX_PROCESSES && NULL != fgets (s, MAX_LENGTH, stdin); )
    {
      for (ss = s; isspace (*ss); ss++);
      if (*ss == '#' || *ss == '\n' || *ss == '\r' || *ss == 0)
        continue;
      strcpy (CommandLines[NumProcesses], ss);
      for (ss = CommandLines[NumProcesses]; *ss; ss++)
        if (*ss == '\r' || *ss == '\n')
          *ss = 0;
      NumProcesses++;
    }

  // Create all processes.
  printf ("\n");
  for (i = 0; i < NumProcesses; i++)
    {
      printf ("Creating process %d: \"%s\"\n", i, CommandLines[i]);
      if (!CreateProcess(NULL, // No module name (use command line). 
                         CommandLines[i],  // Command line. 
                         NULL,             // Process handle not inheritable. 
                         NULL,             // Thread handle not inheritable. 
                         FALSE,            // Set handle inheritance to FALSE. 
                         0,                // No creation flags. 
                         NULL,             // Use parent's environment block. 
                         NULL,             // Use parent's starting directory. 
                         &si[i],           // Pointer to STARTUPINFO structure.
                         &pi[i] ))         // Pointer to PROCESS_INFORMATION structure.
        {
          printf ("CreateProcess failed.\n");
          NumProcesses = i; 
          goto Done; 
        }
      Sleep (500);
    }

  // Wait for any one of them to exit.
  if (StartupDelay > 0)
    Sleep (StartupDelay);
  printf ("Scanning for process exits.\n"); 
  while (1)
    {
      for (i = 0; i < NumProcesses; i++)
	{
	  // Wait 10 ms. for process to end.
	  if (WAIT_TIMEOUT != WaitForSingleObject (pi[i].hProcess, 100))
	    {
	      printf ("Process #%d exited.\n", i); 
	      goto Done;           // Not timeout, so must be exit or error!
	    } 
	}
      Sleep (500);
    }

  // Now terminate all of them!
Done:
  Sleep (5000); 
  for (i = 0; i < NumProcesses; i++)
    {
      printf ("Stopping process #%d\n", i);
      TerminateProcess (pi[i].hProcess, 0);
      CloseHandle (pi[i].hProcess);
      CloseHandle (pi[i].hThread);
    }
  return (0);
}
