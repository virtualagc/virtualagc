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
void FixSuperbankBits(ParseInput_t *record, Address_t *address, int *outValue)
{
    int sbfix = 0060;

#if 0
    if (address->Fixed && address->Banked) {
        if (address->FB < 030) {
            if (record->SBank.current.Super)
                sbfix = 0100;
            else
                sbfix = 0060;
        } else if (address->FB >= 030 && address->FB <= 033) {
            if (address->Super)
                sbfix = 0100;
            else
                sbfix = 0060;
        } else if (address->FB > 033 && address->FB <= 037) {
            sbfix = 0060;
        } else {
            sbfix = 0060;
        }
    } else {
        sbfix = 0060;
    }
#endif

    if (address->Fixed && address->Banked) {
        if (address->Super) {
            sbfix = 0100;
        } else {
            if (record->SBank.current.Super || record->ProgramCounter.Super)
                sbfix = 0100;
        }
    }

    *outValue |= sbfix;

#ifdef YAYUL_TRACE
    printf("--- %s: FB=%03o,super=%d,SB=%d bank=%03o,super=%d fix=%04o value=%05o\n",
           __FUNCTION__,
           record->ProgramCounter.FB,
           record->ProgramCounter.Super,
           record->SBank.current.Super,
           address->FB,
           address->Super,
           sbfix,
           *outValue);
#endif
}

//-------------------------------------------------------------------------
// Print an Address_t.
void PrintAddress(const Address_t *address)
{
    if (address->Invalid)
        printf("INV|");
    if (address->Constant)
        printf("CON|");
    if (address->Address)
        printf("ADR|");
    if (address->Erasable)
        printf("ERA|");
    if (address->Fixed)
        printf("FIX|");
    if (address->Invalid)
        printf("BNK|");
    if (address->Super)
        printf("SUP|");
    if (address->Overflow)
        printf("OVF|");
    printf("SREG=%04o|", address->SReg);
    if (address->Erasable)
        printf("EB=%02o|", address->EB);
    if (address->Fixed)
        printf("FB=%03o|", address->FB);
    printf("Value=%o", address->Value);
}

//-------------------------------------------------------------------------
// Print a Bank_t.
void PrintBank(const Bank_t *bank)
{
    printf("oneshot=%d, current=(", bank->oneshotPending);
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
    printf("), EB=(");
    PrintBank(&record->EBank);
    printf("), SB=(");
    PrintBank(&record->SBank);
    printf(")");
}

//-------------------------------------------------------------------------
// Print a ParseOutput_t.
void PrintOutputRecord(const ParseOutput_t *record)
{
    printf("PC=(");
    PrintAddress(&record->ProgramCounter);
    printf("), EB=(");
    PrintBank(&record->EBank);
    printf("), SB=(");
    PrintBank(&record->SBank);
    printf(")");
}

