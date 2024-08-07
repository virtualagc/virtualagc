/*
  File CHECK_LIST.c generated by XCOM-I, 2024-08-08 04:31:49.
*/

#include "runtimeC.h"

int32_t
CHECK_LIST (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "CHECK_LIST");
  // IF C_TRACE THEN (2668)
  if (1 & (bitToFixed (getBIT (8, mC_TRACE))))
    // DO; (2669)
    {
    rs1:;
      // OUTPUT = 'CHECK_LIST(' || DN || ',' || INX || '):'; (2670)
      {
        descriptor_t *stringRHS;
        stringRHS = xsCAT (
            xsCAT (xsCAT (xsCAT (cToDescriptor (NULL, "CHECK_LIST("),
                                 bitToCharacter (getBIT (8, mCHECK_LISTxDN))),
                          cToDescriptor (NULL, ",")),
                   bitToCharacter (getBIT (16, mCHECK_LISTxINX))),
            cToDescriptor (NULL, "):"));
        OUTPUT (0, stringRHS);
        stringRHS->inUse = 0;
      }
      // IF N_INX > 0 THEN (2671)
      if (1 & (xGT (COREHALFWORD (mN_INX), 0)))
        // OUTPUT = '   K   NODE(K) A_PARITY(K)'; (2672)
        {
          descriptor_t *stringRHS;
          stringRHS = cToDescriptor (NULL, "   K   NODE(K) A_PARITY(K)");
          OUTPUT (0, stringRHS);
          stringRHS->inUse = 0;
        }
      // DO FOR TEMP = 1 TO N_INX; (2673)
      {
        int32_t from60, to60, by60;
        from60 = 1;
        to60 = bitToFixed (getBIT (16, mN_INX));
        by60 = 1;
        for (putBIT (16, mCHECK_LISTxTEMP, fixedToBit (16, from60));
             bitToFixed (getBIT (16, mCHECK_LISTxTEMP)) <= to60;
             putBIT (16, mCHECK_LISTxTEMP,
                     fixedToBit (16, bitToFixed (getBIT (16, mCHECK_LISTxTEMP))
                                         + by60)))
          {
            // OUTPUT = FORMAT(TEMP,4) || ' ' || FORMAT(SHR(NODE(TEMP),16),4)
            // || ' ' || FORMAT(NODE(TEMP) &  65535,4)||
            // FORMAT(A_PARITY(TEMP),12); (2674)
            {
              descriptor_t *stringRHS;
              stringRHS = xsCAT (
                  xsCAT (
                      xsCAT (
                          xsCAT (
                              xsCAT (
                                  (putFIXED (mFORMATxIVAL,
                                             COREHALFWORD (mCHECK_LISTxTEMP)),
                                   putFIXED (mFORMATxN, 4), FORMAT (0)),
                                  cToDescriptor (NULL, " ")),
                              (putFIXED (
                                   mFORMATxIVAL,
                                   SHR (getFIXED (mNODE
                                                  + 4
                                                        * COREHALFWORD (
                                                            mCHECK_LISTxTEMP)),
                                        16)),
                               putFIXED (mFORMATxN, 4), FORMAT (0))),
                          cToDescriptor (NULL, " ")),
                      (putFIXED (
                           mFORMATxIVAL,
                           xAND (getFIXED (
                                     mNODE
                                     + 4 * COREHALFWORD (mCHECK_LISTxTEMP)),
                                 65535)),
                       putFIXED (mFORMATxN, 4), FORMAT (0))),
                  (putFIXED (mFORMATxIVAL,
                             BYTE0 (mA_PARITY
                                    + 1 * COREHALFWORD (mCHECK_LISTxTEMP))),
                   putFIXED (mFORMATxN, 12), FORMAT (0)));
              OUTPUT (0, stringRHS);
              stringRHS->inUse = 0;
            }
          }
      } // End of DO for-loop block
    es1:;
    } // End of DO block
  // DO WHILE INX > 0; (2675)
  while (1 & (xGT (COREHALFWORD (mCHECK_LISTxINX), 0)))
    {
      // IF DN THEN (2676)
      if (1 & (bitToFixed (getBIT (8, mCHECK_LISTxDN))))
        // DO; (2677)
        {
        rs2s1:;
          // TEMP = DIFF_NODE(INX); (2678)
          {
            descriptor_t *bitRHS
                = getBIT (16, mDIFF_NODE + 2 * COREHALFWORD (mCHECK_LISTxINX));
            putBIT (16, mCHECK_LISTxTEMP, bitRHS);
            bitRHS->inUse = 0;
          }
          // IF C_TRACE THEN (2679)
          if (1 & (bitToFixed (getBIT (8, mC_TRACE))))
            // OUTPUT = '   REF=' || TEMP || ', LOOP_HEAD='|| LOOP_HEAD; (2680)
            {
              descriptor_t *stringRHS;
              stringRHS = xsCAT (xsCAT (xsCAT (cToDescriptor (NULL, "   REF="),
                                               bitToCharacter (getBIT (
                                                   16, mCHECK_LISTxTEMP))),
                                        cToDescriptor (NULL, ", LOOP_HEAD=")),
                                 bitToCharacter (getBIT (16, mLOOP_HEAD)));
              OUTPUT (0, stringRHS);
              stringRHS->inUse = 0;
            }
          // IF TEMP < LOOP_HEAD THEN (2681)
          if (1
              & (xLT (COREHALFWORD (mCHECK_LISTxTEMP),
                      COREHALFWORD (mLOOP_HEAD))))
            // DO; (2682)
            {
            rs2s1s1:;
              // IF OPOP(TEMP) ~= EXTN THEN (2683)
              if (1
                  & (xNEQ (
                      bitToFixed ((putBITp (16, mOPOPxPTR,
                                            getBIT (16, mCHECK_LISTxTEMP)),
                                   OPOP (0))),
                      COREHALFWORD (mEXTN))))
                // CALL SET_V_M_TAGS(TEMP,1); (2684)
                {
                  putBITp (16, mSET_V_M_TAGSxPTR,
                           getBIT (16, mCHECK_LISTxTEMP));
                  putBITp (8, mSET_V_M_TAGSxCSE,
                           fixedToBit (32, (int32_t)(1)));
                  SET_V_M_TAGS (0);
                }
            es2s1s1:;
            } // End of DO block
        es2s1:;
        } // End of DO block
      // ELSE (2685)
      else
        // DO; (2686)
        {
        rs2s2:;
          // INX2 = N_INX; (2687)
          {
            descriptor_t *bitRHS = getBIT (16, mN_INX);
            putBIT (16, mCHECK_LISTxINX2, bitRHS);
            bitRHS->inUse = 0;
          }
          // DO WHILE INX2 > 0; (2688)
          while (1 & (xGT (COREHALFWORD (mCHECK_LISTxINX2), 0)))
            {
              // TEMP = NODE(INX2) &  65535; (2689)
              {
                int32_t numberRHS = (int32_t)(xAND (
                    getFIXED (mNODE + 4 * COREHALFWORD (mCHECK_LISTxINX2)),
                    65535));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mCHECK_LISTxTEMP, bitRHS);
                bitRHS->inUse = 0;
              }
              // IF C_TRACE THEN (2690)
              if (1 & (bitToFixed (getBIT (8, mC_TRACE))))
                // OUTPUT = '   REF=' || TEMP || ', NODE2(INX)=' ||NODE2(INX);
                // (2691)
                {
                  descriptor_t *stringRHS;
                  stringRHS = xsCAT (
                      xsCAT (xsCAT (cToDescriptor (NULL, "   REF="),
                                    bitToCharacter (
                                        getBIT (16, mCHECK_LISTxTEMP))),
                             cToDescriptor (NULL, ", NODE2(INX)=")),
                      bitToCharacter (getBIT (
                          16, mNODE2 + 2 * COREHALFWORD (mCHECK_LISTxINX))));
                  OUTPUT (0, stringRHS);
                  stringRHS->inUse = 0;
                }
              // IF TEMP < NODE2(INX) THEN (2692)
              if (1
                  & (xLT (COREHALFWORD (mCHECK_LISTxTEMP),
                          COREHALFWORD (
                              mNODE2 + 2 * COREHALFWORD (mCHECK_LISTxINX)))))
                // DO; (2693)
                {
                rs2s2s1s1:;
                  // IF SHR(OPR(NODE2(INX)),16) < TEMP THEN (2694)
                  if (1
                      & (xLT (SHR (getFIXED (
                                       mOPR
                                       + 4
                                             * COREHALFWORD (
                                                 mNODE2
                                                 + 2
                                                       * COREHALFWORD (
                                                           mCHECK_LISTxINX))),
                                   16),
                              COREHALFWORD (mCHECK_LISTxTEMP))))
                    // DO; (2695)
                    {
                    rs2s2s1s1s1:;
                      // CALL SET_V_M_TAGS(SHR(OPR(NODE2(INX)),16),0); (2696)
                      {
                        putBITp (
                            16, mSET_V_M_TAGSxPTR,
                            fixedToBit (
                                32,
                                (int32_t)(SHR (
                                    getFIXED (
                                        mOPR
                                        + 4
                                              * COREHALFWORD (
                                                  mNODE2
                                                  + 2
                                                        * COREHALFWORD (
                                                            mCHECK_LISTxINX))),
                                    16))));
                        putBITp (8, mSET_V_M_TAGSxCSE,
                                 fixedToBit (32, (int32_t)(0)));
                        SET_V_M_TAGS (0);
                      }
                    es2s2s1s1s1:;
                    } // End of DO block
                  // GO TO EXITT; (2697)
                  goto EXITT;
                es2s2s1s1:;
                } // End of DO block
              // INX2 = INX2 - 1; (2698)
              {
                int32_t numberRHS = (int32_t)(xsubtract (
                    COREHALFWORD (mCHECK_LISTxINX2), 1));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mCHECK_LISTxINX2, bitRHS);
                bitRHS->inUse = 0;
              }
            } // End of DO WHILE block
        es2s2:;
        } // End of DO block
    // EXITT: (2699)
    EXITT:
      // INX = INX - 1; (2700)
      {
        int32_t numberRHS
            = (int32_t)(xsubtract (COREHALFWORD (mCHECK_LISTxINX), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mCHECK_LISTxINX, bitRHS);
        bitRHS->inUse = 0;
      }
    } // End of DO WHILE block
  {
    reentryGuard = 0;
    return 0;
  }
}
