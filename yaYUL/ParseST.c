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

  Filename:	ParseST.c
  Purpose:	Assembles STCALL, STODL, STORE, and STOVAL interpretive
  		opcodes.
  Mode:		07/27/04 RSB	Forked from ParseGeneral.c.
*/

#include "yaYUL.h"
#include <stdlib.h>
#include <string.h>

//------------------------------------------------------------------------

static int
ParseST (ParseInput_t *InRecord, ParseOutput_t *OutRecord, int Opcode,
	      int Flags)
{
  int Value, i;
  Address_t K;
  
  Opcode += 04000 * ArgType;
  IncPc (&InRecord->ProgramCounter, 1, &OutRecord->ProgramCounter);
  if (!OutRecord->ProgramCounter.Invalid && OutRecord->ProgramCounter.Overflow)
    {
      strcpy (OutRecord->ErrorMessage, "Next code may overflow storage.");
      OutRecord->Warning = 1;
    }
  OutRecord->Bank = InRecord->Bank;
  // Set the default binary word.
  OutRecord->NumWords = 1;
  if (Flags & PC1)
    Opcode |= 01000;   
  else if (Flags & PC2)
    Opcode |= 02000;
  else if (Flags & PC3)
    Opcode |= 03000;
  else if (Flags & PC4)
    Opcode |= 04000;  
  else if (Flags & PC5)
    Opcode |= 05000;  
  else if (Flags & PC6)
    Opcode |= 06000;  
  else if (Flags & PC7)
    Opcode |= 07000;  
  else if (Flags & QC1)
    Opcode |= 02000;   
  else if (Flags & QC2)
    Opcode |= 04000;
  else if (Flags & QC3)
    Opcode |= 06000;
  OutRecord->Words[0] = Opcode;
  if (Flags & QCNOT0)
    OutRecord->Words[0] |= 06000;
  // Do some sanity checking.
  if (InRecord->Extend && !(Flags & EXTENDED) && !InRecord->IndexValid)
    {
      strcpy (OutRecord->ErrorMessage, "Illegally preceded by EXTEND.");
      OutRecord->Fatal = 1;
      OutRecord->Extend = 0;
    }
  else if (!InRecord->Extend && (Flags & EXTENDED))
    {
      strcpy (OutRecord->ErrorMessage, "Required EXTEND is missing.");
      OutRecord->Fatal = 1;
      OutRecord->Extend = 0;
    }
  if (InRecord->IndexValid)
    {
      OutRecord->IndexValid = 0;
    }
  i = GetOctOrDec (InRecord->Operand, &Value);
  if (!i && (Flags & ENUMBER) && *InRecord->Operand != '+' && *InRecord->Operand != '-')
    {
      int Offset;
      PseudoToStruct (Value, &K);
      if (!GetOctOrDec (InRecord->Mod1, &Offset))
	OpcodeOffset = Offset;      
      goto DoIt;
    }
  if (!i && *InRecord->Mod1 == 0)
    {
      IncPc (&InRecord->ProgramCounter, Value, &K);
    DoIt:  
      if (K.Invalid)
        {
	  strcpy (OutRecord->ErrorMessage, "Destination address not resolved.");
	  OutRecord->Fatal = 1;
	}
      else if (K.Overflow)
        {
	  strcpy (OutRecord->ErrorMessage, "Destination address out of range.");
	  OutRecord->Fatal = 1;
	}
      else if (!K.Address)
        {
	  strcpy (OutRecord->ErrorMessage, "Destination not an address.");
	  OutRecord->Fatal = 1;
	}
      else 
        {
	//AddressFound:
	  // Here I had originally intended to add a check that the bank
	  // numbers were compatible.  This turns out not to be generally
	  // possible at assembly time, unless a bunch of analysis is 
	  // added to understand program flow.  However, certain checks,
	  // particularly having to do with quarter-codes, can be done.
	  // ... Later:  Not true for erasable banks, since the EBANK=
	  // pseudo-op tells the assembler what bank is expected.  Also,
	  // some constants need to be translated to erasable.
	  if (K.Constant)
	    PseudoToStruct (K.Value, &K);
	  if (Flags & KPLUS1)
	    IncPc (&K, 1, &K);
	  i = K.SReg;
	  if (!K.Erasable)
	    {
	      i = 0;  
	      strcpy (OutRecord->ErrorMessage, "The Address is not in erasable memory.");
	      OutRecord->Fatal = 1;
	    }
	  else
	    {
	      if (!K.Banked)
	        i = K.SReg;
	      else
	        i = 0400 * K.EB + (K.SReg - 01400);
	    }  
          OutRecord->Words[0] = Opcode | i;
	}
    }
  else
    {
      // The operand is NOT a number.  Presumably, it's a symbol.
      i = FetchSymbolPlusOffset (&InRecord->ProgramCounter, 
                                 InRecord->Operand, 
				 InRecord->Mod1, &K);
      if (!i)
        {
	  if (K.Constant)
	    PseudoToStruct (K.Value, &K);
          goto DoIt;
	}
      strcpy (OutRecord->ErrorMessage, "Symbol undefined or offset bad");
      OutRecord->Fatal = 1;
    }
  OutRecord->Extend = 0;
  //if (Opcode == 000000 && !(Flags & EXTENDED) && !K.Invalid && 
  //    (K.Constant || (K.Erasable && K.Unbanked)) && K.SReg == 06)
  //  OutRecord->Extend = 1;
  //else
  OutRecord->Extend = 0;  
  OutRecord->IndexValid = 0;  
  return (0);  
}

//------------------------------------------------------------------------
// Various little parsers based on ParseST.

int 
ParseSTCALL (ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  ArgType = ParseComma (InRecord);
  SwitchIncrement[0] = 0;
  SwitchInvert[0] = 0;
  nnnnFields[0] = 0;
  RawNumInterpretiveOperands = NumInterpretiveOperands = 1;
  return (ParseST (InRecord, OutRecord, 034000, 
          ERASABLE | ENUMBER | KPLUS1));
}

int 
ParseSTODL (ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  ArgType = ParseComma (InRecord);
  SwitchIncrement[0] = 1;
  SwitchInvert[0] = 0;
  nnnnFields[0] = 0;
  RawNumInterpretiveOperands = NumInterpretiveOperands = 1;
  return (ParseST (InRecord, OutRecord, 014000, 
          ERASABLE | ENUMBER | KPLUS1));
}

int 
ParseSTORE (ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  ArgType = ParseComma (InRecord);
  NumInterpretiveOperands = 0;
  return (ParseST (InRecord, OutRecord, 000000, 
          ERASABLE | ENUMBER | KPLUS1));
}

int 
ParseSTOVL (ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  ArgType = ParseComma (InRecord);
  SwitchIncrement[0] = 1;
  SwitchInvert[0] = 0;
  nnnnFields[0] = 0;
  RawNumInterpretiveOperands = NumInterpretiveOperands = 1;
  return (ParseST (InRecord, OutRecord, 024000, 
          ERASABLE | ENUMBER | KPLUS1));
}

//-------------------------------------------------------------------------
// What we have here is a function that parses the Operand and Mod1 fields
// of an instruction line, in order to find the suffices ",1" or ",2", and 
// to remove them.  The return value is 0 if no suffix, or is 1 or 2 if there
// is a suffix.  This concept applies only to the operands of interpretive
// instructions.

// Do it for just a single string.
static int
ParseCommaString (char *s)
{
  int Len;
  Len = strlen (s);
  if (Len < 3)
    return (0);
  s += Len - 2;
  if (!strcmp (",1", s))
    {
      *s = 0;
      return (1);
    }
  if (!strcmp (",2", s))
    {
      *s = 0;
      return (2);
    }
  return (0);
}

int
ParseComma (ParseInput_t *Record)
{
  // If there is a Mod1 field, then the comma-suffix (if any) will appear
  // on the Mod1 field.
  if (*Record->Mod1)
    return (ParseCommaString (Record->Mod1));
  // If there is NOT a Mod1 field, then the comma-suffix may appear on the
  // Operand field.
  if (*Record->Operand)
    return (ParseCommaString (Record->Operand));
  // Guess there was neither one!
  return (0);  
}

