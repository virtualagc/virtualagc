/*
  Copyright 2005 Ronald S. Burkey <info@sandroid.org>

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

  Filename:	aea_engine_init.c
  Purpose:	This is the function which initializes the AGS/AEA simulation,
  		from a file representing the binary image of core memory.
  Compiler:	GNU gcc.
  Contact:	Ron Burkey <info@sandroid.org>
  Reference:	http://www.ibiblio.org/apollo/yaAGS.html
  Mods:		2005-02-13 RSB	Began adapting from corresponding AGC
  				file.
		2005-06-02 RSB	Added Accumulator, Index registers.
		2005-06-04 RSB	Added 20 ms. timing signal.
*/

#include <stdio.h>
#include "aea_engine.h"
FILE *rfopen (const char *Filename, const char *mode);

//---------------------------------------------------------------------------
// Returns:
//      0 -- success.
//      1 -- ROM image file not found.
//      2 -- ROM image file larger than core memory.
//      3 -- ROM image file size is not a multiple of 4.
//      4 -- ags_t structure not allocated.
//      5 -- File-read error.
//      6 -- Core-dump file not found.
// Normally, on input the CoreDump filename is NULL, in which case all of the 
// i/o channels, erasable memory, etc., are cleared to their reset values.
// When the CoreDump is loaded instead, it allows execution to continue precisely
// from the point at which the CoreDump was created.

int
aea_engine_init (ags_t * State, const char *RomImage, const char *CoreDump)
{
  int RetVal, i, j;
  FILE *fp;
  FILE *cd = NULL;
  int m, n;

#ifndef WIN32
  // The purpose of this is to make sure that getchar doesn't halt the program
  // when there's no keystroke immediately available.
  UnblockSocket (fileno (stdin));
#endif

  // The following sequence of steps loads the ROM image into the simulated
  // core memory, in what I think is a pretty obvious way.

  RetVal = 1;
  fp = rfopen (RomImage, "rb");
  if (fp == NULL)
    goto Done;

  RetVal = 3;
  fseek (fp, 0, SEEK_END);
  n = ftell (fp);
  if (0 != (n & 3))		// Must be an integral number of words.
    goto Done;

  RetVal = 2;
  n /= 4;			// Convert byte-count to word-count.
  if (n > MEM_SIZE)
    goto Done;

  RetVal = 4;
  fseek (fp, 0, SEEK_SET);
  if (State == NULL)
    goto Done;

  RetVal = 5;
  for (i = 0; i < n; i++)
    {
      unsigned char In[4];
      m = fread (In, 1, 4, fp);
      if (m != 4)
	goto Done;
      // Note that In[4] is always 0.
      State->Memory[i] = In[0] + (In[1] << 8) + (In[2] << 16);
      State->Memory[i] &= 0777777;
    }
  printf ("Loaded 0%o (octal) 18-bit values.\n", n);

  // Clear i/o channels.
  for (i = 0; i < NUM_IO; i++)
    State->InputPorts[i] = State->OutputPorts[i] = 0;

  // Set up the CPU state variables that aren't part of normal memory.
  RetVal = 0;
  State->CycleCounter = 0;
  State->Next20msSignal = AEA_PER_SECOND / 50;
  i = State->Memory[06000];
  printf ("Address 06000 contains the value %06o, opcode ", i);
  i = ((i >> 12) & 076);
  printf ("%02o\n", i);
  if (i == 040 || i == 072 || i == 070)
    State->ProgramCounter = 06000;
  else
    State->ProgramCounter = 00001;
  State->Accumulator = 0;
  State->Quotient = 0;
  State->Index = 0;
  State->Overflow = 0;
  // The discrete outputs and inputs.
  State->OutputPorts[IO_ODISCRETES] = 0777777;
  State->InputPorts[IO_2020] = 0777777;
  State->InputPorts[IO_2040] = 0777777;

  if (CoreDump != NULL)
    {
      cd = fopen (CoreDump, "r");
      if (cd == NULL)
	RetVal = 6;
      else
	{
	  long long lli;
	
	  RetVal = 5;

	  // Load up the input channels.
	  for (i = 0; i < NUM_IO; i++)
	    {
	      if (1 != fscanf (cd, "%o", &j))
		goto Done;
	      State->InputPorts[i] = j & 0777777;
	    }

	  // Load up the output channels.
	  for (i = 0; i < NUM_IO; i++)
	    {
	      if (1 != fscanf (cd, "%o", &j))
		goto Done;
	      State->OutputPorts[i] = j & 0777777;
	    }

	  // Load up erasable memory.
	  for (i = 0; i < 04000; i++)
	    {
	      if (1 != fscanf (cd, "%o", &j))
		goto Done;
	      State->Memory[i] = j & 0777777;
	    }

	  // Set up the CPU state variables that aren't part of normal memory.
	  if (1 != fscanf (cd, "%llo", &lli))
	    goto Done;
	  State->CycleCounter = lli;
	  if (1 != fscanf (cd, "%o", &i))
	    goto Done;
	  State->ProgramCounter = i;
	  if (1 != fscanf (cd, "%o", &i))
	    goto Done;
	  State->Accumulator = i;
	  if (1 != fscanf (cd, "%o", &i))
	    goto Done;
	  State->Quotient = i;
	  if (1 != fscanf (cd, "%o", &i))
	    goto Done;
	  State->Index = i;
	  if (1 != fscanf (cd, "%o", &i))
	    goto Done;
	  State->Overflow = i;

	  RetVal = 0;
	}
    }

Done:
  if (cd != NULL)
    fclose (cd);
  if (fp != NULL)
    fclose (fp);
  return (RetVal);
}

//-------------------------------------------------------------------------------
// A function for creating a core-dump which can be read by aea_engine_init.

void
MakeCoreDumpAGS (ags_t * State, const char *CoreDump)
{
  FILE *cd = NULL;
  int i;

  cd = fopen (CoreDump, "w");
  if (cd == NULL)
    {
      printf ("Could not create the core-dump file.\n");
      return;
    }

  // Write out the i/o channels.
  for (i = 0; i < NUM_IO; i++)
    fprintf (cd, "%06o\n", State->InputPorts[i]);
  for (i = 0; i < NUM_IO; i++)
    fprintf (cd, "%06o\n", State->OutputPorts[i]);

  // Write out the erasable memory.
  for (i = 0; i < NUM_IO; i++)
    fprintf (cd, "%06o\n", State->Memory[i]);

  // Write out CPU state variables that aren't part of normal memory.
  fprintf (cd, "%llo\n", State->CycleCounter);
  fprintf (cd, "%o\n", State->ProgramCounter);
  fprintf (cd, "%o\n", State->Accumulator);
  fprintf (cd, "%o\n", State->Quotient);
  fprintf (cd, "%o\n", State->Index);
  fprintf (cd, "%o\n", State->Overflow);

  printf ("Core-dump file \"%s\" created.\n", CoreDump);
  fclose (cd);
  return;

}
