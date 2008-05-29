/*
  Copyright 2003-2004 Ronald S. Burkey <info@sandroid.org>
  
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

  Filename:	ParseGENADR.c
  Purpose:	Assembles the GENADR, ADDRES, and REMADR pseudo-ops.
  Mode:		04/19/03 RSB.	Began.
  		04/27/03 RSB.	The earlier versions were completely 
				inadequate, because yaYUL didn't model
				memory properly.  yaYUL has now been
				substantially changed to account for this.
		07/21/04 RSB.	Now allow constants as destinations.
*/

#include "yaYUL.h"
#include <stdlib.h>
#include <math.h>
#include <string.h>

//-------------------------------------------------------------------------
// Returns non-zero on unrecoverable error.

int
ParseGENADR (ParseInput_t *InRecord, ParseOutput_t *OutRecord)
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
      if (Address.Constant && !Address.Address) 
        {
#if 0
	  if (Address.Value < 01400 || (Address.Value >= 04000 && Address.Value <= 07777))
	    {
	      Address.Constant = 0;
	      Address.Address = 1;
	      Address.SReg = Address.Value;
	      Address.Banked = 0;
	      if (Address.Value < 01400)
	        {
	          Address.Erasable = 1;
		  Address.EB = Address.Value / 0400;
		}
	      else 
	        {
	          Address.Fixed = 1;
		  Address.FB = Address.Value / 02000;
		}
	    }
#endif // 0
	  PseudoToStruct (Address.Value, &Address);
	}
      if (!Address.Address)
        {	
	  strcpy (OutRecord->ErrorMessage, "Destination is not a memory address.");
	  OutRecord->Fatal = 1;
	  return (0);
	}
      OutRecord->Words[0] = Address.SReg;
      if (!strcmp (InRecord->Operator, "ADRES") ||
          !strcmp (InRecord->Operator, "DNPTR") ||
	  !strcmp (InRecord->Operator, "-DNPTR"))
        {
	  if (InRecord->ProgramCounter.Erasable &&
	      Address.Erasable &&
	      InRecord->ProgramCounter.Banked &&
	      Address.Banked &&
	      InRecord->ProgramCounter.EB != Address.EB)
	    {
	      strcpy (OutRecord->ErrorMessage, "Destination must be in current erasable bank.");
	      OutRecord->Fatal = 1;
	    }
	  else if (InRecord->ProgramCounter.Fixed &&
	      Address.Fixed &&
	      InRecord->ProgramCounter.Banked &&
	      Address.Banked &&
	      (InRecord->ProgramCounter.FB != Address.FB ||
	       InRecord->ProgramCounter.Super != Address.Super))
	    {
	      strcpy (OutRecord->ErrorMessage, "Destination must be in current fixed bank.");
	      OutRecord->Fatal = 1;
	    }
	}
      else if (!strcmp (InRecord->Operator, "REMADR"))
        {
	  if (InRecord->ProgramCounter.Erasable &&
	      Address.Erasable &&
	      InRecord->ProgramCounter.EB == Address.EB)
	    {
	      strcpy (OutRecord->ErrorMessage, "Destination must not be in current erasable bank.");
	      OutRecord->Fatal = 1;
	    }
	  else if (InRecord->ProgramCounter.Fixed &&
	      Address.Fixed &&
	      InRecord->ProgramCounter.FB == Address.FB &&
	      InRecord->ProgramCounter.Super == Address.Super)
	    {
	      strcpy (OutRecord->ErrorMessage, "Destination must not be in current fixed bank.");
	      OutRecord->Fatal = 1;
	    }
	}	
    }
  else
    {
      // The operand is NOT a number.  Presumably, it's a symbol.
      i = FetchSymbolPlusOffset (&InRecord->ProgramCounter, 
                                 InRecord->Operand, 
				 InRecord->Mod1, &Address);
      if (!i)
        goto DoIt;
      strcpy (OutRecord->ErrorMessage, "Symbol undefined or offset bad");
      OutRecord->Fatal = 1;
      OutRecord->Words[0] = 0;
    }
  return (0);  
}

