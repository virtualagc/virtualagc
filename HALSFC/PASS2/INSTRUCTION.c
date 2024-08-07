/*
  File INSTRUCTION.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

descriptor_t *
INSTRUCTION (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "INSTRUCTION");
  // SUBCODE = SHR(OPCODE,6); (901)
  {
    int32_t numberRHS = (int32_t)(SHR (COREHALFWORD (mINSTRUCTIONxOPCODE), 6));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mINSTRUCTIONxSUBCODE, bitRHS);
    bitRHS->inUse = 0;
  }
  // DUMMY = SUBSTR(OPNAMES(SUBCODE), OPER(OPCODE), 4); (902)
  {
    descriptor_t *stringRHS;
    stringRHS = SUBSTR (
        getCHARACTER (mOPNAMES + 4 * COREHALFWORD (mINSTRUCTIONxSUBCODE)),
        BYTE0 (mOPER + 1 * COREHALFWORD (mINSTRUCTIONxOPCODE)), 4);
    putCHARACTER (mINSTRUCTIONxDUMMY, stringRHS);
    stringRHS->inUse = 0;
  }
  // IF OPCODE = BCF THEN (903)
  if (1 & (xEQ (COREHALFWORD (mINSTRUCTIONxOPCODE), BYTE0 (mBCF))))
    // DO; (904)
    {
    rs1:;
      // IF ASM_LST THEN (905)
      if (1 & (bitToFixed (getBIT (1, mINSTRUCTIONxASM_LST))))
        // DO; (906)
        {
        rs1s1:;
          // IF (RHS &  2) =  2 THEN (907)
          if (1 & (xEQ (xAND (COREHALFWORD (mRHS), 2), 2)))
            // DO; (908)
            {
            rs1s1s1:;
              // DUMMY = 'BCB '; (909)
              {
                descriptor_t *stringRHS;
                stringRHS = cToDescriptor (NULL, "BCB ");
                putCHARACTER (mINSTRUCTIONxDUMMY, stringRHS);
                stringRHS->inUse = 0;
              }
              // BCB_COUNT = BCB_COUNT + 1; (910)
              {
                int32_t numberRHS
                    = (int32_t)(xadd (COREHALFWORD (mBCB_COUNT), 1));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mBCB_COUNT, bitRHS);
                bitRHS->inUse = 0;
              }
            es1s1s1:;
            } // End of DO block
        es1s1:;
        } // End of DO block
      // ELSE (911)
      else
        // DUMMY = 'BC  '; (912)
        {
          descriptor_t *stringRHS;
          stringRHS = cToDescriptor (NULL, "BC  ");
          putCHARACTER (mINSTRUCTIONxDUMMY, stringRHS);
          stringRHS->inUse = 0;
        }
    es1:;
    } // End of DO block
  // IF TAG > 0 THEN (913)
  if (1 & (xGT (COREHALFWORD (mINSTRUCTIONxTAG), 0)))
    // DO; (914)
    {
    rs2:;
      // SUBCODE = CHAR_INDEX(DUMMY, BLANK); (915)
      {
        descriptor_t *bitRHS
            = (putCHARACTERp (mCHAR_INDEXxSTRING1,
                              getCHARACTER (mINSTRUCTIONxDUMMY)),
               putCHARACTERp (mCHAR_INDEXxSTRING2, getCHARACTER (mBLANK)),
               CHAR_INDEX (0));
        putBIT (16, mINSTRUCTIONxSUBCODE, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF SUBCODE < 0 THEN (916)
      if (1 & (xLT (COREHALFWORD (mINSTRUCTIONxSUBCODE), 0)))
        // DUMMY = DUMMY || INDIRECTION(TAG); (917)
        {
          descriptor_t *stringRHS;
          stringRHS
              = xsCAT (getCHARACTER (mINSTRUCTIONxDUMMY),
                       getCHARACTER (mINDIRECTION
                                     + 4 * COREHALFWORD (mINSTRUCTIONxTAG)));
          putCHARACTER (mINSTRUCTIONxDUMMY, stringRHS);
          stringRHS->inUse = 0;
        }
      // ELSE (918)
      else
        // DUMMY = SUBSTR(DUMMY, 0, SUBCODE) || INDIRECTION(TAG); (919)
        {
          descriptor_t *stringRHS;
          stringRHS
              = xsCAT (SUBSTR (getCHARACTER (mINSTRUCTIONxDUMMY), 0,
                               COREHALFWORD (mINSTRUCTIONxSUBCODE)),
                       getCHARACTER (mINDIRECTION
                                     + 4 * COREHALFWORD (mINSTRUCTIONxTAG)));
          putCHARACTER (mINSTRUCTIONxDUMMY, stringRHS);
          stringRHS->inUse = 0;
        }
    es2:;
    } // End of DO block
  // TAG = 0; (920)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mINSTRUCTIONxTAG, bitRHS);
    bitRHS->inUse = 0;
  }
  // ASM_LST = FALSE; (921)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mINSTRUCTIONxASM_LST, bitRHS);
    bitRHS->inUse = 0;
  }
  // RETURN PAD(DUMMY, 6); (922)
  {
    reentryGuard = 0;
    return (putCHARACTERp (mPADxSTRING, getCHARACTER (mINSTRUCTIONxDUMMY)),
            putFIXED (mPADxWIDTH, 6), PAD (0));
  }
}
