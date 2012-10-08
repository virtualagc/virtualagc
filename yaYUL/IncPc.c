/*
  Copyright 2003 Ronald S. Burkey <info@sandroid.org>

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

  Filename:     IncPc.c
  Purpose:      Increments (or decrements) an Address_t structure, with 
                detection of out-of range.  This is a more complicated
                thing than it seems, because of the variety of different
                types of memory bank.  (Also, since the Address_t 
                structure can represent a constant rather than an address.)
  History:      04/15/03 RSB.  Began.
 */

#include "yaYUL.h"
#include <stdlib.h>
#include <math.h>
#include <string.h>

//-------------------------------------------------------------------------
// Increment program counter by a certain amount. 
// Sets the Overflow flag in the Address_t structure.
void IncPc(Address_t *OldPc, int Increment, Address_t *NewPc)
{
    int i, j, Max, Min, BankIncrement;

    // I have no theoretical basis for how to treat the case of Increment
    // being very large (larger than a bank size), but there is a place
    // in the Luminary source code where decrements of about 12000 (octal)
    // are used.  The lower 12 bits seem to be applied to SREG, whereas
    // the upper 3 bits seem to be applied to the bank number.
    if (Increment >= 0) {
        BankIncrement = 7 & (Increment >> 12);
        Increment &= 07777;
    } else {
        Increment = -Increment;
        BankIncrement = -(7 & (Increment >> 12));
        Increment = -(07777 & Increment);
    }

    // Get a good starting point for the calculation.
    *NewPc = *OldPc;

    // If the value is invalid---not yet assigned---then adding to it makes
    // no sense.
    if (NewPc->Invalid)
        return;

    // Okay, add to the existing Value.  This is something that ALWAYS works.
    // (Only overflowing 32-bit arithmetic could make it fail, but since
    // all possible starting values and increments are 15-bit or less,
    // overflowing 32-bit arithmetic would be a real feat!
    //NewPc->Value += Increment;

    // Convert constants (which are presumably pseudo-addresses) to real
    // addresses.
    if (NewPc->Constant) {
        // ... except we do want to check that the constant is in range.
        //if (NewPc->Value < -16383 || NewPc->Value > 32767)
        //  NewPc->Overflow = 1;
        if (NewPc->Value < 0)
            return;
        else if (NewPc->Value < 01400) {
            NewPc->Constant = 0;
            NewPc->Address = 1;
            NewPc->Erasable = 1;
            NewPc->Fixed = 0;
            NewPc->Banked = 0;
            NewPc->Unbanked = 1;
            NewPc->EB = 0;
            NewPc->FB = 0;
#ifdef YAYUL_TRACE
            printf("*** IncPc (%d): clearing superbank...\n", __LINE__);
#endif
            NewPc->Super = 0;
            NewPc->SReg = NewPc->Value;
        } else
            return;
    }

    // Okey-smokey, the "address" is really an address. If it has previously
    // overflowed, there's no particular reason to continue.
    if (NewPc->Overflow)
        return;

    // Compute the new S-register value (in the absence of overflow).
    i = (j = NewPc->SReg) + Increment;
    NewPc->SReg = i;
    if (NewPc->Erasable && NewPc->Banked)
        NewPc->EB += BankIncrement;
    else if (NewPc->Fixed && NewPc->Banked)
        NewPc->FB += BankIncrement;

    // Okay, here's some workaround code for the weird construct
    // TC FixedMemoryLabel -LargeOffset
    // taking a location in fixed memory down to a location in erasable.
    // Don't blame me!
    if (NewPc->Fixed && BankIncrement != 0 && NewPc->FB == 0) {
        NewPc->Constant = 0;
        NewPc->Address = 1;
        NewPc->Erasable = 1;
        NewPc->Fixed = 0;
        NewPc->Banked = 0;
        NewPc->Unbanked = 1;
        NewPc->EB = 0;
        NewPc->FB = 0;
#ifdef YAYUL_TRACE
        //printf("--- IncPc (%d): clearing superbank...\n", __LINE__);
#endif
        NewPc->Super = 0;
    }  

    // Determine the apppropriate SReg ranges for this memory region.
    // The address will be either banked or unbanked, and either in fixed
    // memory or erasable memory.  So, there are four possible combos.
    if (NewPc->Erasable) {
        if (NewPc->Unbanked) {
            Min = 0;
            Max = 01377;
        } else if (NewPc->Banked) {
            Min = 01400;
            Max = 01777;
            NewPc->EB += BankIncrement;
        } else
            goto ImplementationError;
    } else if (NewPc->Fixed) {
        if (NewPc->Banked) {
            Min = 02000;
            Max = 03777;
            NewPc->FB += BankIncrement;
        } else if (NewPc->Unbanked) {
            Min = 04000;
            Max = 07777;
        } else
            goto ImplementationError;
    } else
        goto ImplementationError;

    // Did the new S-register value go out of range for the memory region?
    if (i < Min) {
        NewPc->Overflow = 1;
        NewPc->SReg = Min;
    } else if (i > Max) {
        NewPc->Overflow = 1;
        NewPc->SReg = Max;
    }  

    // Back-convert to get a pseudo-address.
    if (NewPc->Unbanked)
        NewPc->Value = NewPc->SReg;
    else if (NewPc->Erasable)
        NewPc->Value = (NewPc->SReg - 01400) + 0400 * NewPc->EB;
    else if (NewPc->Fixed) {
        NewPc->Value = 010000 + (NewPc->SReg - 02000) + 02000 * NewPc->FB;
        if (NewPc->Super && NewPc->FB >= 030)
            NewPc->Value += 010 * 02000;
    } else
        goto ImplementationError;
    return;

    ImplementationError:
    // Can't occur, but I give it a good pinch if it does!
    NewPc->Invalid = 1;
}
