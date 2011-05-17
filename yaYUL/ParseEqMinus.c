/*
  Copyright 2004 Ronald S. Burkey <info@sandroid.org>
  
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

  Filename:	ParseEqMinus.c
  Purpose:	Assembles the =MINUS pseudo-op.
  Mode:		09/05/04 RSB.	Adapted from ParseEQUALS.
                07/27/05 JMS.   Added support for symbol debugging
*/

#include "yaYUL.h"
#include <stdlib.h>
#include <string.h>

//------------------------------------------------------------------------
// JMS: To properly add entries to the symbol table for debugging, we
// need the current file name and line number of the symbol, so i take the
// global variables in Pass.c. I am being lazy here, I probably should
// include this information in InputRecord_t.
extern Line_t CurrentFilename;
extern int CurrentLineInFile;

//------------------------------------------------------------------------
// Return 0 on success.

int 
ParseEqMinus (ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  Address_t LabelValue = INVALID_ADDRESS;
  int i;
  OutRecord->ProgramCounter = InRecord->ProgramCounter;
  OutRecord->EBank = InRecord->EBank;
  OutRecord->SBank = InRecord->SBank;
  OutRecord->LabelValue.Invalid = 1;
  OutRecord->NumWords = 0;
  OutRecord->Equals = 1;
  
  // As a special case, it sometimes happens that the label is empty.
  // I *believe* that this is done only for documentation purposes, and
  // has no other effect.
  if (*InRecord->Label == 0)
    {
      OutRecord->LabelValueValid = 0;
      return (0);
    }
    
  if (*InRecord->Operand == 0)
    {
      strcpy (OutRecord->ErrorMessage, "Missing operand.");
      OutRecord->Fatal = 1;
      return (0);
    }  
    
  i = FetchSymbolPlusOffset (&InRecord->ProgramCounter, 
			   InRecord->Operand, 
			   InRecord->Mod1, &LabelValue);
  if (i)
    {
      sprintf(OutRecord->ErrorMessage, "Symbol \"%s\" undefined or offset bad", InRecord->Operand);
      OutRecord->Fatal = 1;
    }
  else
    {
      // I should do some kind of checking here to make sure the operand and
      // the current PC are in the same namespace.  I'm too pooped.
      LabelValue.Invalid = 0;
      LabelValue.Constant = 1;
      LabelValue.Address = 0;
      LabelValue.Erasable = 0;
      LabelValue.Fixed = 0;
      LabelValue.Value = LabelValue.SReg - InRecord->ProgramCounter.SReg;
    }

  // JMS: Add a constant to the symbol table
  //EditSymbol (InRecord->Label, &LabelValue /*&TempOutput.ProgramCounter*/);
  EditSymbolNew (InRecord->Label, &LabelValue, SYMBOL_CONSTANT,
		 CurrentFilename, CurrentLineInFile);

  OutRecord->LabelValue = LabelValue;
  return (0);  
}


