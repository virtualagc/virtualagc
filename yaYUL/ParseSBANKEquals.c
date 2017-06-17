/*
 * Copyright 2003,2004 Ronald S. Burkey <info@sandroid.org>
 *
 * This file is part of yaAGC.
 *
 * yaAGC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * yaAGC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with yaAGC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Filename:    ParseSBANKEquals.c
 * Purpose:     Assembles the SBANK= pseudo-op.
 * Mod history: 04/29/03 RSB   Began.
 *              07/23/04 RSB   Added SBANK.
 *              2011-05-17 JL  Split EBANK= and SBANK= parsers, and renamed.
 *              2016-11-03 RSB Using SBANK= without an operand now "unestablishes"
 *                             the superbit setting, which results in things like
 *                             BBCON and 2CADR being assembled to different (though
 *                             operationally identical) octals.  There should be
 *                             no reason to have to do that, as far as I can see
 *                             from YUL's program comments, but I needed it as a
 *                             workaround for Sunburst 120.
 *              2017-06-17 MAS Refactored the SBANK= logic. Once established,
 *                             the SBank remains established. It is also now
 *                             tracked simply as a superbank number, as in YUL.
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

    OutRecord->EBank = InRecord->EBank;
    OutRecord->SBank = InRecord->SBank;
    OutRecord->NumWords = 0;
    OutRecord->ProgramCounter = InRecord->ProgramCounter;

    if (!*InRecord->Operand)
      {
        return (0);
      }

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

        if (Address.FB >= 030 && Address.FB <= 037) {
            // Back up the current SBank in case of a oneshot.
            OutRecord->SBank.last = OutRecord->SBank.current;

            // Determine if the target address is in superbank 3 or 4.
            if (Address.Super) {
                OutRecord->SBank.current = 4;
            } else {
                OutRecord->SBank.current = 3;
            }
        } else {
            strcpy(OutRecord->ErrorMessage, "Destination address not in superbank.");
            OutRecord->SBank.current = 0;
            OutRecord->Fatal = 1;
            return (0);
        }

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

#ifdef YAYUL_TRACE
    PrintTrace(InRecord, OutRecord);
#endif

    return (0);
}
