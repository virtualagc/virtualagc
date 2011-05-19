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

  Filename:     ParseSETLOC.c
  Purpose:      Assembles the SETLOC pseudo-op.
  Mode:         04/17/03 RSB.   Began.
                07/24/04 RSB.   Now allow offsets.
*/

#include "yaYUL.h"
#include <stdlib.h>
#include <string.h>

//------------------------------------------------------------------------
// Return non-zero on unrecoverable error.

int 
ParseSETLOC(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  int Value, i;

  Symbol_t *Symbol;
  OutRecord->ProgramCounter = InRecord->ProgramCounter;

  // Pass EXTEND through.
  OutRecord->Extend = InRecord->Extend;

  if (InRecord->IndexValid)
    {
      strcpy(OutRecord->ErrorMessage, "Illegally preceded by INDEX.");
      OutRecord->Fatal = 1;
      OutRecord->IndexValid = 0;
    }

  i = GetOctOrDec(InRecord->Operand, &Value);
  if (!i)
    {
      // What we've found here is that a constant, like 04000, is the
      // operand of the SETLOC pseudo-op.  I don't really know what is
      // supposed to be done with this in general.  (I've seen
      // `SETLOC 04000' in the source code, but I don't know if there
      // are others.)  I'm going to ASSUME that the operand is a
      // full 16-bit pseudo-address, and I'm going to choose the best
      // memory type based on that assumption.
      PseudoToSegmented(Value, OutRecord);
    }  
  else 
    {  
      Symbol = GetSymbol(InRecord->Operand);
      if (!Symbol)
        {
          sprintf(OutRecord->ErrorMessage, "Symbol \"%s\" undefined or offset bad", InRecord->Operand);
          OutRecord->Fatal = 1;
          OutRecord->ProgramCounter.Invalid = 1;
        }
      else 
          OutRecord->ProgramCounter = Symbol->Value;
    }

  i = GetOctOrDec(InRecord->Mod1, &Value);
  if (!i)
      IncPc(&OutRecord->ProgramCounter, Value, &OutRecord->ProgramCounter);

  InRecord->ProgramCounter = OutRecord->ProgramCounter;

  if (!OutRecord->ProgramCounter.Invalid)
    {
      if (OutRecord->ProgramCounter.Erasable)
        {
          OutRecord->EBank.current = OutRecord->ProgramCounter;
          OutRecord->EBank.last = OutRecord->ProgramCounter;
          OutRecord->EBank.oneshotPending = 0;
        }

      if (OutRecord->ProgramCounter.Fixed)
        {
          OutRecord->SBank.current = OutRecord->ProgramCounter;
          OutRecord->SBank.last = OutRecord->ProgramCounter;
          OutRecord->SBank.oneshotPending = 0;
        }
    }

  return (0);  
}

