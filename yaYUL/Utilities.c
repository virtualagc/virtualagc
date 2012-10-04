/*
  Copyright 2012 Jim Lawton <jim dot lawton at gmail dot com>

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

  Filename:     Utilities.c
  Purpose:      Useful utility functions for yaYUL.
  History:      2012-10-04 JL   Began.
 */

#include "yaYUL.h"
#include <stdlib.h>
#include <string.h>

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
// Print an Address_t.
void PrintAddress(const Address_t *address)
{
    printf("INV=%d,CON=%d,ADR=%d,SREG=%04o,ERA=%d,FIX=%d,UNB=%d,BNK=%d,EB=%o,FB=%02o,S=%d,OVF=%d,Value=%o",
           address->Invalid,
           address->Constant,
           address->Address,
           address->SReg,
           address->Erasable,
           address->Fixed,
           address->Unbanked,
           address->Banked,
           address->EB,
           address->FB,
           address->Super,
           address->Overflow,
           address->Value);
}

//-------------------------------------------------------------------------
// Print a Bank_t.
void PrintBank(const Bank_t *bank)
{
    printf("oneshot=%d,current=(", bank->oneshotPending);
    PrintAddress(&bank->current);
    printf("), last=(");
    PrintAddress(&bank->last);
    printf(")");
}

//-------------------------------------------------------------------------
// Print a ParseInput_t.
void PrintInputRecord(const ParseInput_t *record)
{
    printf("PC=(");
    PrintAddress(&record->ProgramCounter);
    printf("),EB=(");
    PrintBank(&record->EBank);
    printf("),SB=(");
    PrintBank(&record->SBank);
    printf(")");
}

//-------------------------------------------------------------------------
// Print a ParseOutput_t.
void PrintOutputRecord(const ParseOutput_t *record)
{
    printf("PC=(");
    PrintAddress(&record->ProgramCounter);
    printf("),EB=(");
    PrintBank(&record->EBank);
    printf("),SB=(");
    PrintBank(&record->SBank);
    printf(")");
}

