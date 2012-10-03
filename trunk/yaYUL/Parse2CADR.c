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

  Filename:     Parse2CADR.c
  Purpose:      Assembles the 2CADR and 2BCADR pseudo-ops.
  History:      07/09/04 RSB.   Adapted from 2FCADR.
                2012-10-02 JL   Added note.
 */

#include "yaYUL.h"
#include <stdlib.h>
#include <math.h>
#include <string.h>

/* (JL, 2012-10-02)
 *
 * NOTE: 2FCADR is not used by any of the actual flight software sources we currently have.
 * 2CADR is used instead.
 */

//-------------------------------------------------------------------------
// Adjust superbank bits in terms of SBANK= and so on.
void FixSuperbankBits(ParseInput_t *InRecord, Address_t *Address, int *OutValue)
{
    int sbfix = 0;

    if (Address->Fixed && Address->Banked) {
        if (Address->FB < 030) {
            if (InRecord->SBank.current.Super)
                sbfix = 0100;
            else
                sbfix = 0060;
        } else if (Address->FB >= 030 && Address->FB <= 033) {
            if (Address->Super)
                sbfix = 0100;
            else
                sbfix = 0060;
        } else if (Address->FB > 033 && Address->FB <= 037) {
            sbfix = 0060;
        } else {
            sbfix = 0060;
        }
    } else {
        sbfix = 0060;
    }

    *OutValue |= sbfix;

#ifdef YAYUL_TRACE
    printf("--- %s: FB=%03o,super=%d,SB=%d bank=%03o,super=%d fix=%04o value=%05o\n",
           __FUNCTION__,
           InRecord->ProgramCounter.FB,
           InRecord->ProgramCounter.Super,
           InRecord->SBank.current.Super,
           Address->FB,
           Address->Super,
           sbfix,
           *OutValue);
#endif
}

//-------------------------------------------------------------------------
// Returns non-zero on unrecoverable error.
int Parse2CADR(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
    Address_t Address;
    int i;

#ifdef YAYUL_TRACE
    printf("--- 2CADR %s: i/p PC=%o FB=%o S=%d SB=%d\n",
           InRecord->Operand,
           InRecord->ProgramCounter.Value,
           InRecord->ProgramCounter.FB,
           InRecord->ProgramCounter.Super,
           InRecord->SBank.current.Super);
#endif

    IncPc(&InRecord->ProgramCounter, 2, &OutRecord->ProgramCounter);
    if (!OutRecord->ProgramCounter.Invalid && OutRecord->ProgramCounter.Overflow) {
        strcpy(OutRecord->ErrorMessage, "Next code may overflow storage.");
        OutRecord->Warning = 1;
    }

    OutRecord->EBank = InRecord->EBank;
    OutRecord->SBank = InRecord->SBank;
    OutRecord->NumWords = 2;
    OutRecord->Words[0] = 0;
    OutRecord->Words[1] = 0;

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

    i = FetchSymbolPlusOffset(&InRecord->ProgramCounter, InRecord->Operand, InRecord->Mod1, &Address);
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

        OutRecord->Words[0] = Address.SReg;

        if (InRecord->EBank.current.SReg >= 0 && InRecord->EBank.current.SReg < 01400)
            OutRecord->Words[1] = InRecord->EBank.current.SReg / 0400;
        else
            OutRecord->Words[1] = InRecord->EBank.current.EB;

        if (Address.SReg < 02000)
            ;
        else if (Address.SReg <= 07777) {
            if (Address.SReg < 04000)
                OutRecord->Words[1] |= (Address.FB << 10);
            else
                OutRecord->Words[1] |= ((Address.SReg / 02000) << 10);

            // Superbank processing.
            FixSuperbankBits(InRecord, &Address, &OutRecord->Words[1]);
        } else {
            strcpy(OutRecord->ErrorMessage, "Internal error implementing 2CADR.");
            OutRecord->Fatal = 1;
            return (0);
        }
#ifdef YAYUL_TRACE
        printf("--- 2CADR %s: o/p PC=%o FB=%o S=%d SB=%d\n",
               InRecord->Operand,
               OutRecord->ProgramCounter.Value,
               OutRecord->ProgramCounter.FB,
               OutRecord->ProgramCounter.Super,
               OutRecord->SBank.current.Super);
#endif
    }

    return (0);
}

