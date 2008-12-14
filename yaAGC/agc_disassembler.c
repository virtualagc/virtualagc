/*
  Copyright 2003-2006 Ronald S. Burkey <info@sandroid.org>, 
  				2008 Onno Hommes

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

  In addition, as a special exception, permission is given to
  link the code of this program with the Orbiter SDK library (or with 
  modified versions of the Orbiter SDK library that use the same license as 
  the Orbiter SDK library), and distribute linked combinations including 
  the two. You must obey the GNU General Public License in all respects for 
  all of the code used other than the Orbiter SDK library. If you modify 
  this file, you may extend this exception to your version of the file, 
  but you are not obligated to do so. If you do not wish to do so, delete 
  this exception statement from your version. 
 
  Filename:	agc_disassembler.h
  Purpose:	Source file for AGC Disassembler.
  Contact:	Onno Hommes
  Reference:	http://www.ibiblio.org/apollo
  Mods:		08/31/08 OH.	Began.
*/

#include <stdio.h>
#include "agc_engine.h"
#include "agc_disassembler.h"

/* 
 * Displays the current address and its contents.
 */
static int sCurrentZ, sBank, sValue, sErasable, sFixed;
static char ShowAddressBuffer[17];

static char* ShowAddressContents (agc_t *State)
{
  sErasable = sFixed = 0;
  sCurrentZ = (State->Erasable[0][RegZ] & 07777);
  // Print the address.
  if (sCurrentZ < 01400)
    {
      sErasable = 1;
      sprintf (ShowAddressBuffer, "   %05o ", sCurrentZ);
      sBank = sCurrentZ / 0400;
      sValue = State->Erasable[sBank][sCurrentZ & 0377];
    }
  else if (sCurrentZ >= 04000)
    {
      sFixed = 1;
      sprintf (ShowAddressBuffer, "   %05o ", sCurrentZ);
      sBank = 2 + (sCurrentZ - 04000) / 02000;
      sValue = State->Fixed[sBank][sCurrentZ & 01777];
    }
  else if (sCurrentZ < 02000)
    {
      sErasable = 1;
      sBank = 7 & State->Erasable[0][RegBB];
      sprintf (ShowAddressBuffer, "E%o,%05o ", sBank, 01400 + (sCurrentZ & 0377));
      sValue = State->Erasable[sBank][sCurrentZ & 0377];
    }
  else
    {
      sFixed = 1;
      sBank = 037 & (State->Erasable[0][RegBB] >> 10);
      if (sBank >= 030 && State->OutputChannel7 & 0100)
	sBank += 010;
      sprintf (ShowAddressBuffer, "%02o,%05o ", sBank, 02000 + (sCurrentZ & 01777));
      sValue = State->Fixed[sBank][sCurrentZ & 01777];
    }
  sValue &= 077777;
  
  // Print the octal value stored at the address.  
  sprintf (&ShowAddressBuffer[9], "%05o  ", sValue);
  return (ShowAddressBuffer);
}

/*
 *  Displays a disassembly of the current address.
 */
void Disassemble (agc_t * State)
{
  /* The following also sets all of the global variables like sValue, etc. */
  printf ("%s", ShowAddressContents (State));
  
  /* Account for the index value. */
  if (State->SubstituteInstruction)
  {
      sValue = (State->Erasable[0][RegBB] & 077777);
      printf ("sub\t");
  }
  else if (State->IndexValue != 0)
  {
      /* The following calculation doesn't overflow-correct the instruction,
         whereas the agc_engine DOES overflow-correct. */
      if (0 == (040000 & State->IndexValue))	sValue += (State->IndexValue & 077777);
      else sValue -= (~State->IndexValue & 077777);
      printf ("w/i:\t");
  }
    
  /* Disassemble the instruction at the address. */
  if (State->ExtraCode == 0)
  {
           if (sValue == 040000) printf ("COM\n");
      else if (sValue == 020001) printf ("DDOUBL\n");
      else if (sValue == 060000)	printf ("DOUBLE\n");
      else if (sValue == 052006)	printf ("DTCB\n");
      else if (sValue == 052005)	printf ("DTCF\n");
      else if (sValue == 6)   	printf ("EXTEND\n");
      else if (sValue == 4)   	printf ("INHINT\n");
      else if (sFixed && sValue == sCurrentZ + 1 &&
               sValue != 10000)	printf ("NOOP\n");
      else if (sErasable && sValue == 030000) printf ("NOOP\n");
      else if (sValue == 054000) printf ("OVSK\n");
      else if (sValue == 3)printf ("RELINT\n");
      else if (sValue == 050017)	printf ("RESUME\n");
      else if (sValue == 2) printf ("RETURN\n");
      else if (sValue == 054005) printf ("TCAA\n");
      else if (sValue == 1) printf ("XLQ\n");
      else if (sValue == 0) printf ("XXALQ\n");
      else if (sValue == 022007)	printf ("ZL\n");
      else switch (sValue & 0x7000)
		{
		  case 0x0000: 
		  		printf ("TC\t%04o\n", sValue & 0xFFF);
		    	break;
		  case 0x1000:
		    	if (0 == (sValue & 0x0C00)) printf ("CCS\t%04o\n",sValue&0x3FF);
		    	else printf ("TCF\t%04o\n", sValue & 0xFFF);
		    	break;
		  case 0x2000:
		    	switch (sValue & 0x0C00)
		      {
		      	case 0x000:
		      		printf ("DAS\t%04o\n", (sValue - 1) & 0x3FF);
						break;
		      	case 0x400:
						printf ("LXCH\t%04o\n", sValue & 0x3FF);
						break;
			      case 0x800:
						printf ("INCR\t%04o\n", sValue & 0x3FF);
						break;
			      case 0xC00:
					printf ("ADS\t%04o\n", sValue & 0x3FF);
					break;
		      }
		    	break;
		  case 0x3000:
		    printf ("CA\t%04o\n", sValue & 0xFFF);
		    break;
		  case 0x4000:
		    printf ("CS\t%04o\n", sValue & 0xFFF);
		    break;
		  case 0x5000:
		    switch (sValue & 0x0C00)
		    {
		      case 0x000:
					printf ("INDEX\t%04o\n", sValue & 0x3FF);
					break;
		      case 0x400:
					printf ("DXCH\t%04o\n", (sValue - 1) & 0x3FF);
					break;
		      case 0x800:
					printf ("TS\t%04o\n", sValue & 0x3FF);
					break;
		      case 0xC00:
					printf ("XCH\t%04o\n", sValue & 0x3FF);
					break;
		    }
		    break;
		  case 0x6000:
		    printf ("AD\t%04o\n", sValue & 0xFFF);
		    break;
		  case 0x7000:
		    printf ("MASK\t%04o\n", sValue & 0xFFF);
		    break;
	   }
  }
  else
    {
      if (sValue == 040001) printf ("DCOM\n");
      else if (sValue == 050017) printf ("RESUME\n");
      else if (sValue == 070000)	printf ("SQUARE\n");
      else if (sValue == 022007)	printf ("ZQ\n");
      else switch (sValue & 0x7000)
	   {
	  case 0x0000:
	    switch (sValue & 0x0E00)
	    {
	      case 0x0000:
				printf ("READ\t%03o\n", sValue & 0777);
				break;
	      case 0x0200:
				printf ("WRITE\t%03o\n", sValue & 0777);
				break;
	      case 0x0400:
				printf ("RAND\t%03o\n", sValue & 0777);
				break;
	      case 0x0600:
				printf ("WAND\t%03o\n", sValue & 0777);
				break;
	      case 0x0800:
				printf ("ROR\t%03o\n", sValue & 0777);
				break;
	      case 0x0A00:
				printf ("WOR\t%03o\n", sValue & 0777);
				break;
	      case 0x0C00:
				printf ("RXOR\t%03o\n", sValue & 0777);
				break;
	      case 0x0E00:
				printf ("EDRUPT\t%03o\n", sValue & 0777);
				break;
	    }
	    break;
	  case 0x1000:
	    if (0 == (sValue & 0x0C00)) printf ("DV\t%04o\n", sValue & 0x3FF);
	    else printf ("BZF\t%04o\n", sValue & 0xFFF);
	    break;
	  case 0x2000:
	    switch (sValue & 0x0C00)
	    {
	      case 0x000:
				printf ("MSU\t%04o\n", sValue & 0x3FF);
				break;
	      case 0x400:
				printf ("QXCH\t%04o\n", sValue & 0x3FF);
				break;
	      case 0x800:
				printf ("AUG\t%04o\n", sValue & 0x3FF);
				break;
	      case 0xC00:
				printf ("DIM\t%04o\n", sValue & 0x3FF);
				break;
	      }
	    break;
	  case 0x3000:
	    printf ("DCA\t%04o\n", (sValue - 1) & 0xFFF);
	    break;
	  case 0x4000:
	    printf ("DCS\t%04o\n", (sValue - 1) & 0xFFF);
	    break;
	  case 0x5000:
	    printf ("INDEX\t%04o\n", sValue & 0xFFF);
	    break;
	  case 0x6000:
	    if (0 == (sValue & 0x0C00))
	      printf ("SU\t%04o\n", sValue & 0x3FF);
	    else
	      printf ("BZMF\t%04o\n", sValue & 0xFFF);
	    break;
	  case 0x7000:
	    printf ("MP\t%04o\n", sValue & 0xFFF);
	    break;
	  }
  }
}
