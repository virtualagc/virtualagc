/*
  Copyright 2003,2004 Ronald S. Burkey <info@sandroid.org>

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

  Filename:    ParseSBANKEquals.c
  Purpose:     Assembles the SBANK= pseudo-op.
  Mod history: 04/29/03 RSB   Began.
               07/23/04 RSB   Added SBANK.
               2011-05-17 JL  Split EBANK= and SBANK= parsers, and renamed.
 */

#include "yaYUL.h"
#include <stdlib.h>
#include <math.h>
#include <string.h>

int ParseSBANKEquals(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
    ParseOutput_t Dummy;
    Address_t Address;
    int Value, i;

    printf("--- SBANK= %s i/p PC=%o FB=%o S=%d SB=%d\n",
           InRecord->Operand,
           InRecord->ProgramCounter.Value,
           InRecord->ProgramCounter.FB,
           InRecord->ProgramCounter.Super,
           InRecord->SBank.current.Super);

    OutRecord->EBank = InRecord->EBank;
    OutRecord->SBank = InRecord->SBank;
    OutRecord->NumWords = 0;
    OutRecord->ProgramCounter = InRecord->ProgramCounter;

    if (*InRecord->Mod1) {
        strcpy(OutRecord->ErrorMessage, "Extra fields.");
        OutRecord->Warning = 1;
    }

    if (InRecord->Extend && !InRecord->IndexValid) {
        strcpy(OutRecord->ErrorMessage, "Illegally preceded by EXTEND.");
        OutRecord->Fatal = 1;
        OutRecord->Extend = 0;
    }

    if (InRecord->IndexValid) {
        strcpy(OutRecord->ErrorMessage, "Illegally preceded by INDEX.");
        OutRecord->Fatal = 1;
        OutRecord->IndexValid = 0;
    }

    i = GetOctOrDec(InRecord->Operand, &Value);
    if (!i) {
        PseudoToSegmented(Value, &Dummy);
        Address = Dummy.ProgramCounter;

        DoIt:
        if (Address.Invalid) {
            strcpy(OutRecord->ErrorMessage, "Destination address not resolved.");
            OutRecord->Fatal = 1;
            return (0);
        }

        if (!Address.Fixed) {
            strcpy(OutRecord->ErrorMessage, "Destination not in fixed memory.");
            OutRecord->Fatal = 1;
            return (0);
        }

        if (Address.SReg < 02000 || Address.SReg > 03777) {
            strcpy(OutRecord->ErrorMessage, "Destination address out of range.");
            OutRecord->Fatal = 1;
            return (0);
        }

        OutRecord->SBank.last = OutRecord->SBank.current;
        OutRecord->SBank.current = Address;
        OutRecord->SBank.oneshotPending = 1;
        OutRecord->LabelValue = Address;
        OutRecord->LabelValueValid = 1;
    } else {
        // The operand is NOT a number.  Presumably, it's a symbol.
        i = FetchSymbolPlusOffset(&InRecord->ProgramCounter, InRecord->Operand, "", &Address);
        if (!i) {
            IncPc(&Address, OpcodeOffset, &Address);
            goto DoIt;
        }

        strcpy(OutRecord->ErrorMessage, "Symbol undefined or offset bad");
        OutRecord->Fatal = 1;
    }

    printf("--- SBANK= %s o/p PC=%o FB=%o S=%d SB=%d\n",
           InRecord->Operand,
           OutRecord->ProgramCounter.Value,
           OutRecord->ProgramCounter.FB,
           OutRecord->ProgramCounter.Super,
           OutRecord->SBank.current.Super);

    return (0);
}
