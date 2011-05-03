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

  Filename:	ParseEQUALS.c
  Purpose:	Assembles the EQUALS or = pseudo-op.
  Mode:		04/16/03 RSB.	Began.
  		07/26/04 RSB.	Offset moved out of symbol and into 
				global variable.
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
// Fetch a symbol value, possibly with offset.  Return 0 on success.
// The symbol value will have an Invalid field if not resolved yet.
// ... Later:  For a very long time, I simply added the offset into the
// symbol value.  However, I eventually realized that in doing this it 
// circumvent all kinds of crazy things the assembler wants to do with
// offsets --- such as converting one operand type to another.  Therefore,
// I now simply put the offset into a global variable, where it is 
// eventually added to the already-processed opcode+operand.  

int
FetchSymbolPlusOffset (Address_t *pc, char *Operand, char *Mod1,
		       Address_t *Value)
{
  Symbol_t *Symbol;
  int i, Offset;
  
  i = GetOctOrDec (Operand, &Offset);
  if (!i)
    {
      IncPc (pc, Offset, Value);
      return (0);
    }
  Value->Invalid = 1;
  Symbol = GetSymbol (Operand);
  if (Symbol == NULL)
    return (1);
  *Value = Symbol->Value;
  i = GetOctOrDec (Mod1, &Offset);
  if (!i)
    {
      //IncPc (&Symbol->Value, Offset, Value);
      OpcodeOffset = Offset;
      // I'm not sure how to treat very big offsets.  Empirically, this works.
      if (OpcodeOffset >= 0)
        OpcodeOffset &= 07777;
      else
        OpcodeOffset = -(07777 & -OpcodeOffset);
    }
  return (0);    
}

//------------------------------------------------------------------------
// Return 0 on success.

int
ParseEquate (ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  return (ParseEQUALS (InRecord, OutRecord));
}

int 
ParseEQUALS (ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  Address_t LabelValue = { 1 };
  int Value, i;

  OutRecord->ProgramCounter = InRecord->ProgramCounter;
  OutRecord->Bank = InRecord->Bank;
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
  // As another special case, there is sometimes no operand.  *That* means
  // that the current program counter is the value.  
  if (*InRecord->Operand == 0 && *InRecord->Mod1 == 0)
    {
      EditSymbolNew(InRecord->Label, &InRecord->ProgramCounter, SYMBOL_CONSTANT,
		    CurrentFilename, CurrentLineInFile);
      OutRecord->LabelValue = InRecord->ProgramCounter;
      return (0);
    }  
  i = GetOctOrDec(InRecord->Operand, &Value);
  if (i)
    {
      // The operand is NOT a number.  Presumably, it's a symbol.

      if (!strcmp(InRecord->Mod1, "+") || !strcmp(InRecord->Mod1, "-"))
      {
          // Handle the case of whitespace between +/- and the actual offset. 
          if (*InRecord->Mod2 != 0)
          {
              char mod[1 + MAX_LINE_LENGTH];

              strcpy(mod, InRecord->Mod1);
              strcat(mod, InRecord->Mod2);
              i = FetchSymbolPlusOffset(&InRecord->ProgramCounter, 
                                        InRecord->Operand, 
                                        mod, 
                                        &LabelValue);
          }
          else
          {
              sprintf(OutRecord->ErrorMessage, "Syntax error, invalid offset specified");
              OutRecord->Fatal = 1;
              return(0);
          }
      }
      else
      {
          i = FetchSymbolPlusOffset(&InRecord->ProgramCounter, 
                                    InRecord->Operand, 
				    InRecord->Mod1, 
                                    &LabelValue);
      }
      if (i)
      {
          sprintf(OutRecord->ErrorMessage, "Symbol \"%s\" undefined or offset bad", InRecord->Operand);
          OutRecord->Fatal = 1;
          return(0);
      }

      if (OpcodeOffset)
        {
	  if (LabelValue.Constant)
	    {
	      LabelValue.Value += OpcodeOffset;
	    }
          else
	    IncPc(&LabelValue, OpcodeOffset, &LabelValue);
        }

      EditSymbolNew(InRecord->Label, &LabelValue, SYMBOL_CONSTANT, CurrentFilename, CurrentLineInFile);
      OutRecord->LabelValueValid = 1;
    }
  else
    {
      // Next, it may be that the operand is simply a number.  If so, then
      // we're talking about a simple constant.  

      ParseOutput_t TempOutput;

      if (*InRecord->Operand == '+' || *InRecord->Operand == '-')
        {
	  IncPc(&InRecord->ProgramCounter, Value, &LabelValue);
	}
      else
        {
	  if (Value < -16383 || Value > 32767)
	    {
	      strcpy(OutRecord->ErrorMessage, "Value out of range---truncating");
	      OutRecord->Warning = 1;
	      if (Value < -16383)
		Value = -16383;
	      else if (Value > 32767)
		Value = 32767;  
	    }
	  LabelValue.Invalid = 0;
	  LabelValue.Constant = 1;
	  LabelValue.Value = Value;
	  PseudoToSegmented(Value, &TempOutput);
	}

      EditSymbolNew(InRecord->Label, &LabelValue, SYMBOL_CONSTANT, CurrentFilename, CurrentLineInFile);
    }  
  OutRecord->LabelValue = LabelValue;  
  return (0);  
}

