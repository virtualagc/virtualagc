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

  Filename:	ParseINDEX.c
  Purpose:	Assembles the INDEX opcode.
  Mode:		04/18/03 RSB.	Began.
  		07/03/04 RSB.	Didn't work properly with symbolic values.
		07/05/04 RSB.	Added KeepExtend.
		07/10/04 RSB.	Fixed the case of the operand being a constant
				(like "L").
*/

#include "yaYUL.h"
#include <stdlib.h>
#include <string.h>

#define OPCODE 050000

//------------------------------------------------------------------------
// Return non-zero on unrecoverable error.

int 
ParseINDEX (ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  Address_t Offset;
  int Value, i;
  //extern int KeepExtend;
  
  //KeepExtend = 1;
  OutRecord->Extend = InRecord->Extend;
  IncPc (&InRecord->ProgramCounter, 1, &OutRecord->ProgramCounter);
  if (!OutRecord->ProgramCounter.Invalid && OutRecord->ProgramCounter.Overflow)
    {
      strcpy (OutRecord->ErrorMessage, "Next code may overflow storage.");
      OutRecord->Warning = 1;
    }
  OutRecord->Bank = InRecord->Bank;
  OutRecord->NumWords = 1;
  OutRecord->IndexValid = 1;
  //if (InRecord->IndexValid)
  //  {
  //    strcpy (OutRecord->ErrorMessage, "Two consecutive INDEX operations.");
  //    OutRecord->Warning = 1;
  //  }
  i = GetOctOrDec (InRecord->Operand, &Value);
  if (!i)
    {
      if (*InRecord->Operand == '+' || *InRecord->Operand == '-')
        {
	  IncPc (&InRecord->ProgramCounter, Value, &Offset);
	  //IncPc (&InRecord->ProgramCounter, 1, &Offset);
        }
      else
        PseudoToStruct (Value, &Offset);
	
       if (*InRecord->Mod1 != 0)
         {
	   i = GetOctOrDec (InRecord->Mod1, &Value);
	   if (!i)
	     OpcodeOffset = Value;
	 }
      
    DoIt:  
      if (!Offset.Address && !Offset.Constant)
        {
	  strcpy (OutRecord->ErrorMessage, "Index is not an address.");
	  Offset.SReg = 0;
	  OutRecord->Fatal = 1;
	}
      if ((InRecord->Extend && (Offset.SReg & ~07777)) || (!InRecord->Extend && (Offset.SReg & ~01777)))
        {
	  strcpy (OutRecord->ErrorMessage, "Index is out of range.");
	  Offset.SReg = 0;
	  OutRecord->Fatal = 1;
	}
      if (Offset.Constant)
        OutRecord->Words[0] = OPCODE + Offset.Value;
      else
        OutRecord->Words[0] = OPCODE + Offset.SReg;
    }
  else
    {
      // The operand is NOT a number.  Presumably, it's a symbol.
      i = FetchSymbolPlusOffset (&InRecord->ProgramCounter, 
                                 InRecord->Operand, 
				 InRecord->Mod1, &Offset);
      if (!i)
        goto DoIt;
      sprintf(OutRecord->ErrorMessage, "Symbol \"%s\" undefined or offset bad", InRecord->Operand);
      OutRecord->Fatal = 1;
      OutRecord->Words[0] = OPCODE;
    }
  if (OutRecord->Words[0] == 050017)
    OutRecord->IndexValid = 0;
  return (0);  
}


