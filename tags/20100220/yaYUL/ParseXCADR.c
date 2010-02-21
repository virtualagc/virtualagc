/*
  Copyright 2009 Ronald S. Burkey <info@sandroid.org>
  
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

  Filename:	ParseXCADR.c
  Purpose:	Assembles the XCADR pseudo-op.  This is a pseudo-op
  		unique to Block 1.
  Mode:		2009-07-25 RSB	Copied from ParseCADR.c.
  
  At the moment I don't know how or if XCADR differs from CADR, so I've
  just copied ParseCADR().
*/

#include "yaYUL.h"
#include <stdlib.h>
#include <math.h>
#include <string.h>

//-------------------------------------------------------------------------
// Returns non-zero on unrecoverable error.

int
ParseXCADR (ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  Address_t Address;
  int Value, i;
  IncPc (&InRecord->ProgramCounter, 1, &OutRecord->ProgramCounter);
  if (!OutRecord->ProgramCounter.Invalid && OutRecord->ProgramCounter.Overflow)
    {
      strcpy (OutRecord->ErrorMessage, "Next code may overflow storage.");
      OutRecord->Warning = 1;
    }
  OutRecord->Bank = InRecord->Bank;
  OutRecord->NumWords = 1;
  OutRecord->Words[0] = 0;
  if (InRecord->Extend && !InRecord->IndexValid)
    {
      strcpy (OutRecord->ErrorMessage, "Illegally preceded by EXTEND.");
      OutRecord->Fatal = 1;
      OutRecord->Extend = 0;
    }
  if (InRecord->IndexValid)
    {
      strcpy (OutRecord->ErrorMessage, "Illegally preceded by INDEX.");
      OutRecord->Fatal = 1;
      OutRecord->IndexValid = 0;
    }
  i = GetOctOrDec (InRecord->Operand, &Value);
  if (!i && *InRecord->Mod1 == 0)
    {
      IncPc (&InRecord->ProgramCounter, Value, &Address);
    DoIt:  
      if (Address.Invalid)
        {
	  strcpy (OutRecord->ErrorMessage, "Destination address not resolved.");
	  OutRecord->Fatal = 1;
	  return (0);
	}
      if (!Address.Address)
        {
	  strcpy (OutRecord->ErrorMessage, "Destination is not a memory address.");
	  OutRecord->Fatal = 1;
	  return (0);
	}
      if (!Address.Fixed || !Address.Banked)
        {
	  strcpy (OutRecord->ErrorMessage, "Destination not in an F-bank.");
	  OutRecord->Fatal = 1;
	  return (0);
	}	
      // If this is a superbank, we massage a little more to get into the 15-bit
      // address range.
      if (Address.Super && Address.FB >= 030)
        Address.Value -= 010 * 02000;
      if (Address.Value < 010000 || Address.Value > 0107777)
        {
	  strcpy (OutRecord->ErrorMessage, "Destination address out of range.");
	  OutRecord->Fatal = 1;
	  return (0);
	}	
      OutRecord->Words[0] = Address.Value - 010000;	
    }
  else
    {
      // The operand is NOT a number.  Presumably, it's a symbol.
      i = FetchSymbolPlusOffset (&InRecord->ProgramCounter, 
                                 InRecord->Operand, 
				 InRecord->Mod1, &Address);
      if (!i)
        goto DoIt;
      sprintf(OutRecord->ErrorMessage, "Symbol \"%s\" undefined or offset bad", InRecord->Operand);
      OutRecord->Fatal = 1;
    }
  return (0);  
}

