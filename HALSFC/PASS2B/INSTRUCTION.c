/*
  File INSTRUCTION.c generated by XCOM-I, 2024-08-08 04:34:25.
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
  // SUBCODE = SHR(OPCODE,6); (899)
  {
    int32_t numberRHS = (int32_t)(SHR (COREHALFWORD (mINSTRUCTIONxOPCODE), 6));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mINSTRUCTIONxSUBCODE, bitRHS);
    bitRHS->inUse = 0;
  }
  // DUMMY = SUBSTR(OPNAMES(SUBCODE), OPER(OPCODE), 4); (900)
  {
    descriptor_t *stringRHS;
    stringRHS = SUBSTR (
        getCHARACTER (mOPNAMES + 4 * COREHALFWORD (mINSTRUCTIONxSUBCODE)),
        BYTE0 (mOPER + 1 * COREHALFWORD (mINSTRUCTIONxOPCODE)), 4);
    putCHARACTER (mINSTRUCTIONxDUMMY, stringRHS);
    stringRHS->inUse = 0;
  }
  // IF OPCODE = BCF THEN (901)
  if (1 & (xEQ (COREHALFWORD (mINSTRUCTIONxOPCODE), BYTE0 (mBCF))))
    // DO; (902)
    {
    rs1:;
      // IF ASM_LST THEN (903)
      if (1 & (bitToFixed (getBIT (1, mINSTRUCTIONxASM_LST))))
        // DO; (904)
        {
        rs1s1:;
          // IF (RHS &  2) =  2 THEN (905)
          if (1 & (xEQ (xAND (COREHALFWORD (mRHS), 2), 2)))
            // DO; (906)
            {
            rs1s1s1:;
              // DUMMY = 'BCB '; (907)
              {
                descriptor_t *stringRHS;
                stringRHS = cToDescriptor (NULL, "BCB ");
                putCHARACTER (mINSTRUCTIONxDUMMY, stringRHS);
                stringRHS->inUse = 0;
              }
              // BCB_COUNT = BCB_COUNT + 1; (908)
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
      // ELSE (909)
      else
        // DUMMY = 'BC  '; (910)
        {
          descriptor_t *stringRHS;
          stringRHS = cToDescriptor (NULL, "BC  ");
          putCHARACTER (mINSTRUCTIONxDUMMY, stringRHS);
          stringRHS->inUse = 0;
        }
    es1:;
    } // End of DO block
  // IF TAG > 0 THEN (911)
  if (1 & (xGT (COREHALFWORD (mINSTRUCTIONxTAG), 0)))
    // DO; (912)
    {
    rs2:;
      // SUBCODE = CHAR_INDEX(DUMMY, BLANK); (913)
      {
        descriptor_t *bitRHS
            = (putCHARACTERp (mCHAR_INDEXxSTRING1,
                              getCHARACTER (mINSTRUCTIONxDUMMY)),
               putCHARACTERp (mCHAR_INDEXxSTRING2, getCHARACTER (mBLANK)),
               CHAR_INDEX (0));
        putBIT (16, mINSTRUCTIONxSUBCODE, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF SUBCODE < 0 THEN (914)
      if (1 & (xLT (COREHALFWORD (mINSTRUCTIONxSUBCODE), 0)))
        // DUMMY = DUMMY || INDIRECTION(TAG); (915)
        {
          descriptor_t *stringRHS;
          stringRHS
              = xsCAT (getCHARACTER (mINSTRUCTIONxDUMMY),
                       getCHARACTER (mINDIRECTION
                                     + 4 * COREHALFWORD (mINSTRUCTIONxTAG)));
          putCHARACTER (mINSTRUCTIONxDUMMY, stringRHS);
          stringRHS->inUse = 0;
        }
      // ELSE (916)
      else
        // DUMMY = SUBSTR(DUMMY, 0, SUBCODE) || INDIRECTION(TAG); (917)
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
  // TAG = 0; (918)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mINSTRUCTIONxTAG, bitRHS);
    bitRHS->inUse = 0;
  }
  // ASM_LST = FALSE; (919)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mINSTRUCTIONxASM_LST, bitRHS);
    bitRHS->inUse = 0;
  }
  // RETURN PAD(DUMMY, 6); (920)
  {
    reentryGuard = 0;
    return (putCHARACTERp (mPADxSTRING, getCHARACTER (mINSTRUCTIONxDUMMY)),
            putFIXED (mPADxWIDTH, 6), PAD (0));
  }
}
