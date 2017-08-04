/*
 * Copyright 2004,2016-2017 Ronald S. Burkey <info@sandroid.org>
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
 * Filename:     ParseBBCON.c
 * Purpose:      Assembles the BBCON and BBCON* pseudo-ops.
 * History:      07/21/04 RSB.  Adapted from ParseECADR.c.
 *               11/02/16 RSB.  Changed handling of BBCON*, which was previously
 *                              hard-coded, but for which the value is no
 *                              longer correct in Sunburst 120.  Hopefully
 *                              works correctly in all cases now.
 *               11/03/16 RSB.  Permanently removed some code I had temporarily
 *                              commented out yesterday.
 *               2017-01-05 RSB Added BBCON* as distinct from BBCON.
 *               2017-06-17 MAS Refactored superbank bit logic.
 */

#include "yaYUL.h"
#include <stdlib.h>
#include <math.h>
#include <string.h>

//-------------------------------------------------------------------------
// Returns non-zero on unrecoverable error.

static int
ParseBBCONraw(int star, ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
    Address_t Address, ebank;
    int Value, i;
    //extern Line_t CurrentFilename;
    //extern int CurrentLineInFile;

    IncPc(&InRecord->ProgramCounter, 1, &OutRecord->ProgramCounter);
    if (!OutRecord->ProgramCounter.Invalid && OutRecord->ProgramCounter.Overflow) {
        strcpy(OutRecord->ErrorMessage, "Next code may overflow storage.");
        OutRecord->Warning = 1;
    }

    OutRecord->EBank = InRecord->EBank;
    OutRecord->SBank = InRecord->SBank;
    OutRecord->NumWords = 1;
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

    i = GetOctOrDec(InRecord->Operand, &Value);
    if ((!i && *InRecord->Mod1 == 0) || star) {
        IncPc(&InRecord->ProgramCounter, Value, &Address);
        DoIt:
        if (star)
          {
            /*
             * Since this is BBCON*, we need to generate an address, instead find the
             * last address used in the last non-empty fixed bank.
             */
            int GetPriorBankCount(int bank); // From ParseBANK.c.
            int bank, highestOffset = 0;
            for (bank = 043; bank >= 0; bank--)
              {
                highestOffset = GetPriorBankCount(bank);
                if (highestOffset > 0)
                  break;
              }
            //printf("Debug %02o %04o\n", bank, highestOffset);
            Address.Address = 1;
            Address.Banked = 1;
            Address.Constant = 0;
            Address.EB = 0;
            Address.Erasable = 0;
            Address.FB = (bank >= 040) ? (bank - 010) : bank;
            Address.Fixed = 1;
            Address.Invalid = 0;
            Address.Overflow = 0;
            Address.SReg = 04000 + highestOffset;
            Address.Super = (bank >= 040) ? 1 : 0;
            Address.Syllable = 0;
            Address.Unbanked = 0;
            Address.Value = 010000 + (Address.SReg - 02000) + 02000 * Address.FB;
            if (Address.Super && Address.FB >= 030)
                Address.Value += 010 * 02000;
          }

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

        if (!Address.Fixed) {
            strcpy(OutRecord->ErrorMessage, "Destination is not in fixed memory.");
            OutRecord->Fatal = 1;
            return (0);
        }

        if (Address.SReg < 02000 || Address.SReg > 07777) {
            strcpy(OutRecord->ErrorMessage, "Destination address out of range.");
            OutRecord->Fatal = 1;
            return (0);
        }

        if (!Address.Banked)
            Address.Value = Address.SReg / 02000;
        else
            Address.Value = Address.FB;

        ebank = InRecord->EBank.current;

        if (ebank.SReg >= 0 && ebank.SReg < 01400)
            ebank.EB = ebank.SReg / 0400;

        Address.Value = (Address.Value << 10) | ebank.EB;

        if (Address.FB >= 030 && Address.FB <= 037) {
            // Determine the superbank needed for the target address
            unsigned AddressSBank;
            if (Address.Super)
                AddressSBank = 4;
            else
                AddressSBank = 3;

            Address.Value |= AddressSBank << 4;

            // Generate a warning if we're implicitly referencing a different superbank
            // ... someday? It really looks like there are things that YUL would have cussed
            // in, e.g., Luminary 210, but GAP does not appear to have done so. For now
            // we will just let it slide...

            //if (InRecord->ProgramCounter.FB >= 030 && InRecord->ProgramCounter.FB <= 037 
            //   && AddressSBank != InRecord->SBank.current) {
            //    sprintf(OutRecord->ErrorMessage, 
            //            "BBCON referencing unestablished superbank %u when in superbank %u", 
            //            AddressSBank, 
            //            InRecord->SBank.current);
            //    OutRecord->Warning = 1;
            //}
        } else if (!EarlySBank) {
            // If the target address is not in a superbank, then simply fill in the
            // superbank bits with whatever the established superbank is...
            // *unless* we're building with pre-1967 superbank behavior.
            Address.Value |= InRecord->SBank.current << 4;
        }

        OutRecord->Words[0] = Address.Value;
    } else {
        // The operand is NOT a number.  Presumably, it's a symbol.
        i = FetchSymbolPlusOffset(&InRecord->ProgramCounter, InRecord->Operand, InRecord->Mod1, &Address);
        if (!i)
            goto DoIt;
        sprintf(OutRecord->ErrorMessage, "Symbol \"%s\" undefined or offset bad", InRecord->Operand);
        OutRecord->Fatal = 1;
    }

#ifdef YAYUL_TRACE
    PrintTrace(InRecord, OutRecord);
#endif

    return (0);
}

int ParseBBCON(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  return (ParseBBCONraw(0, InRecord, OutRecord));
}

int ParseBBCONstar(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  return (ParseBBCONraw(1, InRecord, OutRecord));
}

