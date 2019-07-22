/*
  Copyright 2003,2019 Ronald S. Burkey <info@sandroid.org>
  
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

  Filename:     ParseBLOCK.c
  Purpose:      Assembles the BLOCK pseudo-op.
  Mode:         04/25/03 RSB   	Began.
		07/22/19 RSB	There was an error (or at least a confusion)
				in the way "BLOCK 0" was being parsed,
				which is hopefully fixed.  As it happens,
				"BLOCK 0" is never used in the original
				AGC code.  The fix is in response to GitHub
				issue #1072, but it does not fix #1072,
				which I don't think is conceptually fixable.
				At any rate, all existing code assembles
				word-for-word identically to the way it
				assembled before.
*/

#include "yaYUL.h"
#include <stdlib.h>
#include <string.h>

//------------------------------------------------------------------------
// Return non-zero on unrecoverable error.

int 
ParseBLOCK(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  int Value, used, i;
  
  if (InRecord->Extend && !InRecord->IndexValid)
    {
      strcpy(OutRecord->ErrorMessage, "Illegally preceded by EXTEND.");
      OutRecord->Fatal = 1;
      OutRecord->Extend = 0;
    }

  if (InRecord->IndexValid)
    {
      strcpy(OutRecord->ErrorMessage, "Illegally preceded by INDEX.");
      OutRecord->Fatal = 1;
      OutRecord->Index = 0;
    }

  i = GetOctOrDec(InRecord->Operand, &Value);
  if (!i)
    {
      if (Value == 0 || Value == 2 || Value == 3)
        {
	  //fprintf(stderr, "BLOCK %d, %d\n", Value, GetBankCount(Value));
          used = GetBankCount(Value) + Value * 02000;
          OutRecord->ProgramCounter = (const Address_t) { 0 };
          OutRecord->ProgramCounter.Address = 1;
          OutRecord->ProgramCounter.SReg = used;

          if (Value == 0)
              OutRecord->ProgramCounter.Erasable = 1;
          else
              OutRecord->ProgramCounter.Fixed = 1;  

          OutRecord->ProgramCounter.Unbanked = 1;
          OutRecord->ProgramCounter.Value = used;

          if (Value == 0)
              OutRecord->EBank.current = OutRecord->ProgramCounter;
        }
      else
        {
          strcpy(OutRecord->ErrorMessage, "BLOCK operand must be 0, 2, or 3.");
          OutRecord->ProgramCounter = (const Address_t) { 0 };
          OutRecord->ProgramCounter.Invalid = 1;
        }
    } 
  else 
    {  
      strcpy(OutRecord->ErrorMessage, "BLOCK pseudo-op has no operand.");
      OutRecord->ProgramCounter = (const Address_t) { 0 };
      OutRecord->ProgramCounter.Invalid = 1;
    }

  // Make sure this prints properly in the output listing.  
  InRecord->ProgramCounter = OutRecord->ProgramCounter;
  return (0);  
}

