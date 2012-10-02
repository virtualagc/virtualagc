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

  Filename:     Parse2FCADR.c
  Purpose:      Assembles the 2FCADR pseudo-ops.
  Hsitory:      07/09/04 RSB.   Created.
                2012-10-02 JL   Added note.
 */

#include "yaYUL.h"
#include <stdlib.h>
#include <math.h>
#include <string.h>

//-------------------------------------------------------------------------
// Returns non-zero on unrecoverable error.

/* (JL, 2012-10-02)
 *
 * NOTE: 2FCADR is not used by any of the actual flight software sources we currently have.
 * 2CADR is used instead. So, any changes made here will have no effect, except on the
 * Validation code.
 */

int
Parse2FCADR (ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
    Address_t Address;
    int i;

    IncPc(&InRecord->ProgramCounter, 2, &OutRecord->ProgramCounter);
    if (!OutRecord->ProgramCounter.Invalid && OutRecord->ProgramCounter.Overflow) {
        strcpy(OutRecord->ErrorMessage, "Next code may overflow storage.");
        OutRecord->Warning = 1;
    }

    OutRecord->EBank = InRecord->EBank;
    OutRecord->SBank = InRecord->SBank;
    OutRecord->NumWords = 2;
    OutRecord->Words[0] = 0;

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

    i = FetchSymbolPlusOffset(&InRecord->ProgramCounter,
                              InRecord->Operand,
                              InRecord->Mod1, &Address);
    if (i) {
        sprintf(OutRecord->ErrorMessage, "Symbol \"%s\" undefined or offset bad", InRecord->Operand);
        OutRecord->Fatal = 1;
    } else {
        if (Address.Invalid) {
            strcpy(OutRecord->ErrorMessage, "Destination address not resolved.");
            OutRecord->Fatal = 1;
            return (0);
        }

        if (!Address.Address) {
            strcpy(OutRecord->ErrorMessage, "Destination is not a memory address.");
            OutRecord->Fatal = 1;
            return (0);
        }

        if (!Address.Fixed /*|| !Address.Banked */) {
            strcpy(OutRecord->ErrorMessage, "Destination not in fixed memory.");
            OutRecord->Fatal = 1;
            return (0);
        }

        //OutRecord->Words[0] = Address.Value - 010000;
        if (Address.SReg >= 02000 && Address.SReg <= 03777) {
            OutRecord->Words[0] = ((Address.FB << 10) | (Address.SReg - 02000));
            OutRecord->Words[1] = Address.SReg;
        } else if (Address.SReg >= 04000 && Address.SReg <= 07777) {
            OutRecord->Words[0] = Address.SReg;
            OutRecord->Words[1] = Address.SReg;
        } else {
            strcpy(OutRecord->ErrorMessage, "Internal error implementing 2FCADR.");
            OutRecord->Fatal = 1;
            return (0);
        }
    }
    return (0);
}

