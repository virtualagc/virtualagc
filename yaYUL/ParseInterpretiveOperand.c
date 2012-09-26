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

  Filename:     ParseInterpretiveOperand.c
  Purpose:      Assembles stand-alone operands for interpretive opcodes.
  Mod History:  07/28/04 RSB    Forked from ParseGeneral.c.
                2012-09-25 JL   Handle arguments like "X + 2", i.e. Mod1=+, Mod2=2.
 */

#include "yaYUL.h"
#include <stdlib.h>
#include <string.h>

//------------------------------------------------------------------------

int
ParseInterpretiveOperand(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
    int Value, i;
    Address_t K, KMod;

    ArgType = ParseComma(InRecord);
    IncPc(&InRecord->ProgramCounter, 1, &OutRecord->ProgramCounter);

    if (!OutRecord->ProgramCounter.Invalid && OutRecord->ProgramCounter.Overflow) {
        strcpy(OutRecord->ErrorMessage, "Next code may overflow storage.");
        OutRecord->Warning = 1;
    }

    OutRecord->EBank = InRecord->EBank;
    OutRecord->SBank = InRecord->SBank;

    // Set the default binary word.
    OutRecord->NumWords = 1;
    OutRecord->Words[0] = 0;

    // Do some sanity checking.
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

    // Parse the operand field.
    i = GetOctOrDec(InRecord->Operand, &Value);
    if (!i) {
        if (*InRecord->Operand == '+' || *InRecord->Operand == '-') {
            IncPc(&InRecord->ProgramCounter, Value, &K);
        } else {
            K = (const Address_t) { 0 };
            K.Constant = 1;
            K.Value = Value;
        }
    } else {
        i = FetchSymbolPlusOffset(&InRecord->ProgramCounter, InRecord->Operand, "", &K);
    }

    if (i || K.Invalid) {
        sprintf(OutRecord->ErrorMessage, "Operand \"%s\" not resolved.", InRecord->Operand);
        OutRecord->Fatal = 1;
        return (0);
    }

    // Parse the modifier field.
    KMod = (const Address_t) { 0 };
    KMod.Constant = 1;
    KMod.Value = 0;

    if (*InRecord->Mod1) {
        char args[32];

        args[0] = '\0';
        strcpy(args, InRecord->Mod1);

        // Handle arguments like "DUMMYJOB + 2", i.e. Mod1=+, Mod2=2.
        if (*InRecord->Mod2)
            strcat(args, InRecord->Mod2);

        i = GetOctOrDec(args, &Value);
        if (!i) {
            KMod.Value = Value;
        } else {
            sprintf(OutRecord->ErrorMessage, "Modifier \"%s\" not resolved.", InRecord->Mod1);
            OutRecord->Fatal = 1;
            return (0);
        }
    }

    // Combine the operand and the modifier.
    //K.SReg += KMod.Value;
    //K.Value += KMod.Value;
    OpcodeOffset = KMod.Value;

    // There are 3 valid cases:  Erasable, Fixed, or constant (switch).
    // The encoding is different in each case.

    RetryMem:
    if (K.Constant) {
        i = nnnnFields[RawNumInterpretiveOperands - NumInterpretiveOperands];
        if ((i & 3) == 1) {
            // Switch instruction.
            // Use the encoding 00WWWWWWNNNNBBBB, where WWWWWW and BBBB
            // are the quotient and remainder when dividing the constant
            // by 15.  NNNN derives from the opcode.
            OutRecord->Words[0] = (((K.Value / 15) & 077) << 8) | (K.Value % 15);
            OutRecord->Words[0] |= (0360 & i);
        } else if ((i & 3) == 2) {
            // Shift instruction.
            OutRecord->Words[0] = K.Value;
            OutRecord->Words[0] |= (i & ~3);
        } else {
            // Not a switch or shift instruction.
            i = K.Value + OpcodeOffset;
            if (i < 0)
                i--;
            i &= 077777;
            OpcodeOffset = 0;

            if (040000 & i) {
                OutRecord->Words[0] = i;
            } else {
                PseudoToStruct(i, &K);
                if (K.Invalid || !K.Address)
                    goto BadOp;
                goto RetryMem;
            }
        }
    } else if (K.Address && K.Erasable) {
        if (!K.Banked)
            OutRecord->Words[0] = K.SReg;
        else
            OutRecord->Words[0] = 0400 * K.EB + (K.SReg - 01400);
    } else if (K.Address && K.Fixed) {
        if (!K.Banked)
            OutRecord->Words[0] = K.SReg;
        else
            OutRecord->Words[0] = 02000 * K.FB + (K.SReg - 02000);
    } else {
        BadOp:
        strcpy (OutRecord->ErrorMessage, "Incorrect operand type.");
        OutRecord->Fatal = 1;
    } 

    OutRecord->Words[0] = OutRecord->Words[0] + OpcodeOffset;
    OpcodeOffset = 0;

    if (SwitchIncrement[RawNumInterpretiveOperands - NumInterpretiveOperands]) {
        OutRecord->Words[0]++;
        OutRecord->Words[0] &= 037777;
        if (ArgType == 2)
            OutRecord->Words[0] = 077777 & ~OutRecord->Words[0];
    }

    return (0);
}

