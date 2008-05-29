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
 
  Filename:	EmbeddedDemo.c
  Purpose:	This shows you how to build a minimalist version of 
  		yaAGC, suitable for embedded firmware.  It should also
		serve to show somebody wanting to embed yaAGC into 
		a PC-based flight simulator how to do it without
		shredding agc_engine.c.
  Compiler:	GNU gcc.
  Contact:	Ron Burkey <info@sandroid.org>
  Reference:	http://www.ibiblio.org/apollo/index.html
  Mods:		08/18/04 RSB	Wrote.
		02/27/05 RSB	Added the license exception, as required by
				the GPL, for linking to Orbiter SDK libraries.
		05/14/05 RSB	Corrected website references
  
  This minimalist demo of yaAGC uses only agc_engine.c (as-is, unmodified),
  NullAPI.c (which you would modify to incoporate your own model of how 
  you'd like i/o to work), and this main-program file, EmbeddedDemo.c (which
  you would presumably discard after copying its few useful portions).  So
  any difficulties you may have with compiling any of the OTHER files in
  the yaAGC directory are unimportant.
  
  You compile this demo for a PC environment as follows:
  
  	gcc EmbeddedDemo.c NullAPI.c agc_engine.c

  (and, in some environments, random.c).  Only the most vanilla of vanilla
  C is used, so it should work in any compiler.  If you want to write your
  own code in C++, you should be able to handle intermixing of C and C++
  code by cunning use of 
  	extern "C" { ... }
  without changing agc_engine.c.
  
  What is needed to turn this into a complete embedded program:
  
  1.  Startup code (crt.o) for the processor you're using.
  2.  A linker script that defines a new const memory section for holding
      the CoreRope array (see below).
  3.  Cunning use of objdump (in the proper cross-version) during your build
      proces to copy Luminary131.bin or Colossus249.bin into that memory 
      section.
  4.  Modification of the template file NullAPI.c so that i/o operations 
      affect your actual i/o signals.
  5.  An interrupt service routine that calls agc_engine at 11.7 microsecond
      intervals.
*/
  
#include "yaAGC.h"
#include "agc_engine.h"
agc_t State;
#define CORE_SIZE (044 * 02000)
#ifdef __embedded__
// Stuff that's missing.  Figure it out later.
int __errno;
int atexit(void (*function)(void)) { return (0); };
#endif

int 
main (void)
{
  extern const unsigned char CoreRope[CORE_SIZE][2];
  int i, j, Bank;
  
  // In a PC-based program, Step 1 and Step 2 below would be bypassed by
  // simply running agc_engine_init.c.
  
  // Step 1:  Somehow, get the binary for Luminary or Colossus loaded into
  // State.Fixed[][].  There are numerous ways to do this, but the way I'm
  // going to use for illustration is this:  When the embedded code is 
  // built, the objcopy program of the compiler toolchain (which I'm assuming
  // is gcc) is used to create a const array duplicating byte-for-byte the 
  // contents of one of the existing core-rope images (Luminary131.bin, 
  // Colossus249.bin, etc.).  What we do here is to copy these arrays into 
  // State.Fixed[][], whilst transcoding them to the proper format.  We'll
  // assume the const array is named CoreRope[], but you could play tricks like
  // having separate arrays for the various available core-ropes, and 
  // selecting whichever one you wanted at power-up by using a DIP switch. 
  // Or you could transcode them at compile-time, and eliminate the 
  // transcoding.
  Bank = 2;
  for (Bank = 2, j = 0, i = 0; i < CORE_SIZE; i++)
    {
      // Within the input file, the fixed-memory banks are arranged in the order
      // 2, 3, 0, 1, 4, 5, 6, 7, ..., 35.  Therefore, we have to take a little care
      // reordering the banks.
      State.Fixed[Bank][j++] = (CoreRope[i][0] * 256 + CoreRope[i][1]) >> 1;
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
  
  // Step 2:  Initialize erasable memory and i/o-channel space.
  // Clear i/o channels.
  for (i = 0; i < NUM_CHANNELS; i++)
    State.InputChannel[i] = 0;
  State.InputChannel[030] = 037777;
  State.InputChannel[031] = 077777;
  State.InputChannel[032] = 077777;
  State.InputChannel[033] = 077777;

  // Clear erasable memory.
  for (Bank = 0; Bank < 8; Bank++)
    for (j = 0; j < 0400; j++)
      State.Erasable[Bank][j] = 0;
  State.Erasable[0][RegZ] = 04000;	// Initial program counter.

  // Set up the CPU state variables that aren't part of normal memory.
  State.CycleCounter = 0;
  State.ExtraCode = 0;
  State.AllowInterrupt = 0;
  State.PendFlag = 0;
  State.PendDelay = 0;
  State.ExtraDelay = 0;

  // Step 3:  Set up a master interrupt to call agc_engine at 11.7 microsecond
  // intervals, and then just wait forever.
  // SetUpInterrupts ();
  // while (1);
  
  // ... but lacking the ability to do that hardware-specific thing in this test 
  // program, we just call agc_engine repeatedly, so that it runs flat-out.
  for (;;)
    agc_engine (&State);
}

// This stub-function is here to keep agc_engine from slowing itself down by 
// saving backtrace information, which is useful only for a debugger we're not
// building into the code anyway.
void
BacktraceAdd (agc_t *State, int Cause)
{
  // Keep this empty.
}

