/*
  Copyright 2003-2006 Ronald S. Burkey <info@sandroid.org>

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
 
  Filename:	agc_engine_init.c
  Purpose:	This is the function which initializes the AGC simulation,
  		from a file representing the binary image of core memory.
  Compiler:	GNU gcc.
  Contact:	Ron Burkey <info@sandroid.org>
  Reference:	http://www.ibiblio.org/apollo/index.html
  Mods:		04/05/03 RSB.	Began.
  		09/07/03 RSB.	Fixed data ordering in the core-rope image
				file (to both endian CPU types to work).
		11/26/03 RSB.	Up to now, a pseudo-linear space was used to
				model internal AGC memory.  This was simply too
				tricky to work with, because it was too hard to
				understand the address conversions that were
				taking place.  I now use a banked model much
				closer to the true AGC memory map.
		11/29/03 RSB.	Added the core-dump save/load.
		05/06/04 RSB	Now use rfopen in looking for the binary.
		07/12/04 RSB	Q is now 16 bits.
		07/15/04 RSB	AGC data now aligned at bit 0 rathern then 1.
		07/17/04 RSB	I/O channels 030-033 now default to 077777
				instead of 00000, since the signals are 
				supposed to be inverted.
		02/27/05 RSB	Added the license exception, as required by
				the GPL, for linking to Orbiter SDK libraries.
		05/14/05 RSB	Corrected website references.
	 	07/05/05 RSB	Added AllOrErasable.
		07/07/05 RSB	On a resume, now restores 010 on up (rather
				than 020 on up), on Hugh's advice.
		02/26/06 RSB	Various changes requested by Mark Grant
				to make it easier to integrate with Orbiter.
				The main change is the addition of an
				agc_load_binfile function.  Shouldn't affect
				non-orbiter builds.
*/

// For Orbiter.
#ifndef AGC_SOCKET_ENABLED

#include <stdio.h>
#include "agc_engine.h"
FILE *rfopen (const char *Filename, const char *mode);

//---------------------------------------------------------------------------
// Returns:
//      0 -- success.
//      1 -- ROM image file not found.
//      2 -- ROM image file larger than core memory.
//      3 -- ROM image file size is odd.
//      4 -- agc_t structure not allocated.
//      5 -- File-read error.
//      6 -- Core-dump file not found.
// Normally, on input the CoreDump filename is NULL, in which case all of the 
// i/o channels, erasable memory, etc., are cleared to their reset values.
// When the CoreDump is loaded instead, it allows execution to continue precisely
// from the point at which the CoreDump was created, if AllOrErasable != 0.
// If AllOrErasable == 0, then only the erasable memory is initialized from the
// core-dump file.

int
agc_load_binfile(agc_t *State, const char *RomImage)

{
  FILE *fp = NULL;
  int Bank;
  int m, n, i, j;

  // The following sequence of steps loads the ROM image into the simulated
  // core memory, in what I think is a pretty obvious way.

  int RetVal = 1;
  fp = rfopen (RomImage, "rb");
  if (fp == NULL)
    goto Done;

  RetVal = 3;
  fseek (fp, 0, SEEK_END);
  n = ftell (fp);
  if (0 != (n & 1))		// Must be an integral number of words.
    goto Done;

  RetVal = 2;
  n /= 2;			// Convert byte-count to word-count.
  if (n > 36 * 02000)
    goto Done;

  RetVal = 4;
  fseek (fp, 0, SEEK_SET);
  if (State == NULL)
    goto Done;

  RetVal = 5;
  Bank = 2;
  for (Bank = 2, j = 0, i = 0; i < n; i++)
    {
      unsigned char In[2];
      m = fread (In, 1, 2, fp);
      if (m != 2)
	goto Done;
      // Within the input file, the fixed-memory banks are arranged in the order
      // 2, 3, 0, 1, 4, 5, 6, 7, ..., 35.  Therefore, we have to take a little care
      // reordering the banks.
      if (Bank > 35)
	{
	  RetVal = 2;
	  goto Done;
	}
      State->Fixed[Bank][j++] = (In[0] * 256 + In[1]) >> 1;
      if (j == 02000)
	{
	  j = 0;
	  // Bank filled.  Advance to next fixed-memory bank.
	  if (Bank == 2)
	    Bank = 3;
	  else if (Bank == 3)
	    Bank = 0;
	  else if (Bank == 0)
	    Bank = 1;
	  else if (Bank == 1)
	    Bank = 4;
	  else
	    Bank++;
	}
    }

Done:
  if (fp != NULL)
    fclose (fp);
  return (RetVal);
}

int
agc_engine_init (agc_t * State, const char *RomImage, const char *CoreDump,
		 int AllOrErasable)
{
  int RetVal = 0, i, j, Bank;
  FILE *cd = NULL;

#ifndef WIN32
  // The purpose of this is to make sure that getchar doesn't halt the program
  // when there's no keystroke immediately available.
  UnblockSocket (fileno (stdin));
#endif

  if (RomImage)
	  RetVal = agc_load_binfile(State, RomImage);
 
  // Clear i/o channels.
  for (i = 0; i < NUM_CHANNELS; i++)
    State->InputChannel[i] = 0;
  State->InputChannel[030] = 037777;
  State->InputChannel[031] = 077777;
  State->InputChannel[032] = 077777;
  State->InputChannel[033] = 077777;

  // Clear erasable memory.
  for (Bank = 0; Bank < 8; Bank++)
    for (j = 0; j < 0400; j++)
      State->Erasable[Bank][j] = 0;
  State->Erasable[0][RegZ] = 04000;	// Initial program counter.

  // Set up the CPU state variables that aren't part of normal memory.
  RetVal = 0;
  State->CycleCounter = 0;
  State->ExtraCode = 0;
  // I've seen no indication so far of a reset value for interrupt-enable. 
  State->AllowInterrupt = 0;
  State->InterruptRequests[8] = 1;	// DOWNRUPT.
  //State->RegA16 = 0;
  State->PendFlag = 0;
  State->PendDelay = 0;
  State->ExtraDelay = 0;
  //State->RegQ16 = 0;

  if (CoreDump != NULL)
    {
      cd = fopen (CoreDump, "r");
      if (cd == NULL)
        {
	  if (AllOrErasable)
	    RetVal = 6;
	  else
	    RetVal = 0;
	}
      else
	{
	  RetVal = 5;

	  // Load up the i/o channels.
	  for (i = 0; i < NUM_CHANNELS; i++)
	    {
	      if (1 != fscanf (cd, "%o", &j))
		goto Done;
	      if (AllOrErasable)
	        State->InputChannel[i] = j;
	    }

	  // Load up erasable memory.
	  for (Bank = 0; Bank < 8; Bank++)
	    for (j = 0; j < 0400; j++)
	      {
		if (1 != fscanf (cd, "%o", &i))
		  goto Done;
		if (AllOrErasable || Bank > 0 || j >= 010)
		  State->Erasable[Bank][j] = i;
	      }

          if (AllOrErasable)
	    {
	      // Set up the CPU state variables that aren't part of normal memory.
	      if (1 != fscanf (cd, "%o", &i))
		goto Done;
	      State->CycleCounter = i;
	      if (1 != fscanf (cd, "%o", &i))
		goto Done;
	      State->ExtraCode = i;
	      // I've seen no indication so far of a reset value for interrupt-enable. 
	      if (1 != fscanf (cd, "%o", &i))
		goto Done;
	      State->AllowInterrupt = i;
	      //if (1 != fscanf (cd, "%o", &i))
	      //  goto Done;
	      //State->RegA16 = i;
	      if (1 != fscanf (cd, "%o", &i))
		goto Done;
	      State->PendFlag = i;
	      if (1 != fscanf (cd, "%o", &i))
		goto Done;
	      State->PendDelay = i;
	      if (1 != fscanf (cd, "%o", &i))
		goto Done;
	      State->ExtraDelay = i;
	      //if (1 != fscanf (cd, "%o", &i))
	      //  goto Done;
	      //State->RegQ16 = i;
	    }

	  RetVal = 0;
	}
    }

Done:
  if (cd != NULL)
    fclose (cd);
  return (RetVal);
}

//-------------------------------------------------------------------------------
// A function for creating a core-dump which can be read by agc_engine_init.

void
MakeCoreDump (agc_t * State, const char *CoreDump)
{
  FILE *cd = NULL;
  int i, j, Bank;

  cd = fopen (CoreDump, "w");
  if (cd == NULL)
    {
      printf ("Could not create the core-dump file.\n");
      return;
    }

  // Write out the i/o channels.
  for (i = 0; i < NUM_CHANNELS; i++)
    fprintf (cd, "%06o\n", State->InputChannel[i]);

  // Write out the erasable memory.
  for (Bank = 0; Bank < 8; Bank++)
    for (j = 0; j < 0400; j++)
      fprintf (cd, "%06o\n", State->Erasable[Bank][j]);

  // Write out CPU state variables that aren't part of normal memory.
  fprintf (cd, "%llo\n", State->CycleCounter);
  fprintf (cd, "%o\n", State->ExtraCode);
  fprintf (cd, "%o\n", State->AllowInterrupt);
  //fprintf (cd, "%o\n", State->RegA16);
  fprintf (cd, "%o\n", State->PendFlag);
  fprintf (cd, "%o\n", State->PendDelay);
  fprintf (cd, "%o\n", State->ExtraDelay);
  //fprintf (cd, "%o\n", State->RegQ16);

  printf ("Core-dump file \"%s\" created.\n", CoreDump);
  fclose (cd);
  return;

//Done:
//  printf ("Write-error on core-dump file.\n");
//  fclose (cd);
//  return;

}

#endif // AGC_SOCKET_ENABLED
