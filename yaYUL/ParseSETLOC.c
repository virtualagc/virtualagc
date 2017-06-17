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
                12/18/16 MAS.   Added support for relative arguments
                                (eg. SETLOC +2)
                01/27/17 MAS.   Added support for Raytheon-style
                                absolute addresses (eg. FF024000)
                06/17/17 MAS.   SETLOC has no effect on the SBank.
 */

#include "yaYUL.h"
#include <stdlib.h>
#include <string.h>

//------------------------------------------------------------------------
// Return non-zero on unrecoverable error.
int ParseSETLOC(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
    int Value, i;
    Symbol_t *Symbol;

    OutRecord->ProgramCounter = InRecord->ProgramCounter;
    OutRecord->SBank= InRecord->SBank;

    // Pass EXTEND through.
    OutRecord->Extend = InRecord->Extend;

    if (InRecord->IndexValid) {
        strcpy(OutRecord->ErrorMessage, "Illegally preceded by INDEX.");
        OutRecord->Fatal = 1;
        OutRecord->IndexValid = 0;
    }

    i = GetOctOrDec(InRecord->Operand, &Value);
    if (!i) {
        if (InRecord->Operand[0] == '+' || InRecord->Operand[0] == '-') {
            // This is a relative SETLOC or LOC. Change the PC by the requested
            // value.
            IncPc(&OutRecord->ProgramCounter, Value, &OutRecord->ProgramCounter);
        } else {
            // What we've found here is that a constant, like 04000, is the
            // operand of the SETLOC pseudo-op.  I don't really know what is
            // supposed to be done with this in general.  (I've seen
            // `SETLOC 04000' in the source code, but I don't know if there
            // are others.)  I'm going to ASSUME that the operand is a
            // full 16-bit pseudo-address, and I'm going to choose the best
            // memory type based on that assumption.
            PseudoToSegmented(Value, OutRecord);
        }
    } else {
        Symbol = GetSymbol(InRecord->Operand);
        if (!Symbol) {
            char MemType;
            int Bank, SReg;
            int RaytheonAddr = 0;
            if (3 == sscanf(InRecord->Operand, "%cF%2o%4o", &MemType, &Bank, &SReg)) {
                if (MemType == 'C' || MemType == 'F') {
                    OutRecord->ProgramCounter = VALID_ADDRESS;
                    OutRecord->ProgramCounter.Address = 1;
                    OutRecord->ProgramCounter.Fixed = 1;
                    OutRecord->ProgramCounter.SReg = SReg;
                    if (MemType == 'C') {
                        OutRecord->ProgramCounter.Banked = 1;
                        OutRecord->ProgramCounter.FB = Bank;
                    } else {
                        OutRecord->ProgramCounter.Unbanked = 1;
                    }
                    RaytheonAddr = 1;
                }
            }

            if (!RaytheonAddr) {
                sprintf(OutRecord->ErrorMessage, "Symbol \"%s\" undefined or offset bad", InRecord->Operand);
                OutRecord->Fatal = 1;
                OutRecord->ProgramCounter.Invalid = 1;
            }
        } else {
            OutRecord->ProgramCounter = Symbol->Value;
        }
    }

    i = GetOctOrDec(InRecord->Mod1, &Value);
    if (!i)
        IncPc(&OutRecord->ProgramCounter, Value, &OutRecord->ProgramCounter);

    // Make sure this prints properly in the output listing (?).
    InRecord->ProgramCounter = OutRecord->ProgramCounter;

    if (!OutRecord->ProgramCounter.Invalid) {
        if (OutRecord->ProgramCounter.Erasable) {
            OutRecord->EBank.current = OutRecord->ProgramCounter;
            OutRecord->EBank.last = OutRecord->ProgramCounter;
            OutRecord->EBank.oneshotPending = 0;
        }
    }

#ifdef YAYUL_TRACE
    PrintTrace(InRecord, OutRecord);
#endif

    return (0);
}
