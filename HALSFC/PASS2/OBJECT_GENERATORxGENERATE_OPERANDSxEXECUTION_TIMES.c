/*
  File OBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMES.c generated by
  XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
OBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMES (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (
      reentryGuard, "OBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMES");
  // IF TAG_NAME ~= '' THEN (15549)
  if (1
      & (xsNEQ (getCHARACTER (mOBJECT_GENERATORxTAG_NAME),
                cToDescriptor (NULL, ""))))
    // TAG_NAME = '; '||TAG_NAME; (15550)
    {
      descriptor_t *stringRHS;
      stringRHS = xsCAT (cToDescriptor (NULL, "; "),
                         getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
      putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
      stringRHS->inUse = 0;
    }
  // DO CASE M; (15551)
  {
  rs1:
    switch (BYTE0 (mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxM))
      {
      case 0:
        // DO; (15553)
        {
        rs1s1:;
          // IF (INST=MR) & (R MOD 2 ~= 0) THEN (15553)
          if (1
              & (xAND (xEQ (getFIXED (mINST), BYTE0 (mMR)),
                       xNEQ (xmod (getFIXED (mR), 2), 0))))
            // TAG_NAME = TIMES(11)||TAG_NAME; (15554)
            {
              descriptor_t *stringRHS;
              stringRHS = xsCAT (
                  getCHARACTER (
                      mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                      + 4 * 11),
                  getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
              putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
              stringRHS->inUse = 0;
            }
          // ELSE (15555)
          else
            // IF (INST=29  ) & (R MOD 2 ~= 0) THEN (15556)
            if (1
                & (xAND (xEQ (getFIXED (mINST), 29),
                         xNEQ (xmod (getFIXED (mR), 2), 0))))
              // TAG_NAME = TIMES(21)||TAG_NAME; (15557)
              {
                descriptor_t *stringRHS;
                stringRHS = xsCAT (
                    getCHARACTER (
                        mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                        + 4 * 21),
                    getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                stringRHS->inUse = 0;
              }
            // ELSE (15558)
            else
              // IF (INST=60  ) & (R MOD 2 ~= 0) THEN (15559)
              if (1
                  & (xAND (xEQ (getFIXED (mINST), 60),
                           xNEQ (xmod (getFIXED (mR), 2), 0))))
                // TAG_NAME = TIMES(27)||TAG_NAME; (15560)
                {
                  descriptor_t *stringRHS;
                  stringRHS = xsCAT (
                      getCHARACTER (
                          mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                          + 4 * 27),
                      getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                  putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                  stringRHS->inUse = 0;
                }
              // ELSE (15561)
              else
                // IF (INST = MVH) THEN (15562)
                if (1 & (xEQ (getFIXED (mINST), BYTE0 (mMVH))))
                  // DO; (15563)
                  {
                  rs1s1s1:;
                    // IF MVH_CNT_KNOWN(R) THEN (15564)
                    if (1
                        & (bitToFixed (
                            getBIT (1, mOBJECT_GENERATORxMVH_CNT_KNOWN
                                           + 1 * getFIXED (mR)))))
                      // DO; (15565)
                      {
                      rs1s1s1s1:;
                        // IF MVH_COUNT(R) = 1 THEN (15566)
                        if (1
                            & (xEQ (COREHALFWORD (mOBJECT_GENERATORxMVH_COUNT
                                                  + 2 * getFIXED (mR)),
                                    1)))
                          // TAG_NAME = '11.25'||TAG_NAME; (15567)
                          {
                            descriptor_t *stringRHS;
                            stringRHS = xsCAT (
                                cToDescriptor (NULL, "11.25"),
                                getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                            putCHARACTER (mOBJECT_GENERATORxTAG_NAME,
                                          stringRHS);
                            stringRHS->inUse = 0;
                          }
                        // ELSE (15568)
                        else
                          // IF MVH_COUNT(R) = 0 THEN (15569)
                          if (1
                              & (xEQ (COREHALFWORD (mOBJECT_GENERATORxMVH_COUNT
                                                    + 2 * getFIXED (mR)),
                                      0)))
                            // TAG_NAME = '7.75'||TAG_NAME; (15570)
                            {
                              descriptor_t *stringRHS;
                              stringRHS = xsCAT (
                                  cToDescriptor (NULL, "7.75"),
                                  getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                              putCHARACTER (mOBJECT_GENERATORxTAG_NAME,
                                            stringRHS);
                              stringRHS->inUse = 0;
                            }
                          // ELSE (15571)
                          else
                            // IF MVH_COUNT(R) < 0 THEN (15572)
                            if (1
                                & (xLT (
                                    COREHALFWORD (mOBJECT_GENERATORxMVH_COUNT
                                                  + 2 * getFIXED (mR)),
                                    0)))
                              // TAG_NAME = '7.5'; (15573)
                              {
                                descriptor_t *stringRHS;
                                stringRHS = cToDescriptor (NULL, "7.5");
                                putCHARACTER (mOBJECT_GENERATORxTAG_NAME,
                                              stringRHS);
                                stringRHS->inUse = 0;
                              }
                            // ELSE (15574)
                            else
                              // IF (MVH_COUNT(R) MOD 2) = 0 THEN (15575)
                              if (1
                                  & (xEQ (xmod (COREHALFWORD (
                                                    mOBJECT_GENERATORxMVH_COUNT
                                                    + 2 * getFIXED (mR)),
                                                2),
                                          0)))
                                // TAG_NAME =
                                // '10.25+.875*'||MVH_COUNT(R)||TAG_NAME;
                                // (15576)
                                {
                                  descriptor_t *stringRHS;
                                  stringRHS = xsCAT (
                                      xsCAT (
                                          cToDescriptor (NULL, "10.25+.875*"),
                                          bitToCharacter (getBIT (
                                              16, mOBJECT_GENERATORxMVH_COUNT
                                                      + 2 * getFIXED (mR)))),
                                      getCHARACTER (
                                          mOBJECT_GENERATORxTAG_NAME));
                                  putCHARACTER (mOBJECT_GENERATORxTAG_NAME,
                                                stringRHS);
                                  stringRHS->inUse = 0;
                                }
                              // ELSE (15577)
                              else
                                // TAG_NAME =
                                // '12.0+.875*('||MVH_COUNT(R)||'-1)'||TAG_NAME;
                                // (15578)
                                {
                                  descriptor_t *stringRHS;
                                  stringRHS = xsCAT (
                                      xsCAT (
                                          xsCAT (
                                              cToDescriptor (NULL,
                                                             "12.0+.875*("),
                                              bitToCharacter (getBIT (
                                                  16,
                                                  mOBJECT_GENERATORxMVH_COUNT
                                                      + 2 * getFIXED (mR)))),
                                          cToDescriptor (NULL, "-1)")),
                                      getCHARACTER (
                                          mOBJECT_GENERATORxTAG_NAME));
                                  putCHARACTER (mOBJECT_GENERATORxTAG_NAME,
                                                stringRHS);
                                  stringRHS->inUse = 0;
                                }
                      es1s1s1s1:;
                      } // End of DO block
                    // ELSE (15579)
                    else
                      // TAG_NAME = TIMES(NORMAL_TIMES(INST))||TAG_NAME;
                      // (15580)
                      {
                        descriptor_t *stringRHS;
                        stringRHS = xsCAT (
                            getCHARACTER (
                                mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                                + 4
                                      * BYTE0 (
                                          mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxNORMAL_TIMES
                                          + 1 * getFIXED (mINST))),
                            getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                        putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                        stringRHS->inUse = 0;
                      }
                  es1s1s1:;
                  } // End of DO block
                // ELSE (15581)
                else
                  // TAG_NAME = TIMES(NORMAL_TIMES(INST))||TAG_NAME; (15582)
                  {
                    descriptor_t *stringRHS;
                    stringRHS = xsCAT (
                        getCHARACTER (
                            mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                            + 4
                                  * BYTE0 (
                                      mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxNORMAL_TIMES
                                      + 1 * getFIXED (mINST))),
                        getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                    putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                    stringRHS->inUse = 0;
                  }
        es1s1:;
        } // End of DO block
        break;
      case 1:
        // DO; (15584)
        {
        rs1s2:;
          // IF (INST=92  ) & (R MOD 2 ~= 0) THEN (15584)
          if (1
              & (xAND (xEQ (getFIXED (mINST), 92),
                       xNEQ (xmod (getFIXED (mR), 2), 0))))
            // DO; (15585)
            {
            rs1s2s1:;
              // IF IX ~= 0 THEN (15586)
              if (1 & (xNEQ (getFIXED (mIX), 0)))
                // DO; (15587)
                {
                rs1s2s1s1:;
                  // IF (SHL(F,1) + IA) > 0 THEN (15588)
                  if (1
                      & (xGT (xadd (SHL (getFIXED (mF), 1), getFIXED (mIA)),
                              0)))
                    // TAG_NAME = TIMES(31)||' (SEE POO)'||TAG_NAME; (15589)
                    {
                      descriptor_t *stringRHS;
                      stringRHS = xsCAT (
                          xsCAT (
                              getCHARACTER (
                                  mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                                  + 4 * 31),
                              cToDescriptor (NULL, " (SEE POO)")),
                          getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                      putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                      stringRHS->inUse = 0;
                    }
                  // ELSE (15590)
                  else
                    // TAG_NAME = TIMES(54)||TAG_NAME; (15591)
                    {
                      descriptor_t *stringRHS;
                      stringRHS = xsCAT (
                          getCHARACTER (
                              mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                              + 4 * 54),
                          getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                      putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                      stringRHS->inUse = 0;
                    }
                es1s2s1s1:;
                } // End of DO block
              // ELSE (15592)
              else
                // TAG_NAME = TIMES(21)||TAG_NAME; (15593)
                {
                  descriptor_t *stringRHS;
                  stringRHS = xsCAT (
                      getCHARACTER (
                          mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                          + 4 * 21),
                      getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                  putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                  stringRHS->inUse = 0;
                }
            es1s2s1:;
            } // End of DO block
          // ELSE (15594)
          else
            // IF (INST=93  ) & (R MOD 2 ~= 0) THEN (15595)
            if (1
                & (xAND (xEQ (getFIXED (mINST), 93),
                         xNEQ (xmod (getFIXED (mR), 2), 0))))
              // DO; (15596)
              {
              rs1s2s2:;
                // IF IX ~= 0 THEN (15597)
                if (1 & (xNEQ (getFIXED (mIX), 0)))
                  // DO; (15598)
                  {
                  rs1s2s2s1:;
                    // IF (SHL(F,1) + IA) > 0 THEN (15599)
                    if (1
                        & (xGT (xadd (SHL (getFIXED (mF), 1), getFIXED (mIA)),
                                0)))
                      // TAG_NAME = TIMES(39)||' (SEE POO)'||TAG_NAME; (15600)
                      {
                        descriptor_t *stringRHS;
                        stringRHS = xsCAT (
                            xsCAT (
                                getCHARACTER (
                                    mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                                    + 4 * 39),
                                cToDescriptor (NULL, " (SEE POO)")),
                            getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                        putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                        stringRHS->inUse = 0;
                      }
                    // ELSE (15601)
                    else
                      // TAG_NAME = TIMES(52)||TAG_NAME; (15602)
                      {
                        descriptor_t *stringRHS;
                        stringRHS = xsCAT (
                            getCHARACTER (
                                mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                                + 4 * 52),
                            getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                        putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                        stringRHS->inUse = 0;
                      }
                  es1s2s2s1:;
                  } // End of DO block
                // ELSE (15603)
                else
                  // TAG_NAME = TIMES(21)||TAG_NAME; (15604)
                  {
                    descriptor_t *stringRHS;
                    stringRHS = xsCAT (
                        getCHARACTER (
                            mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                            + 4 * 21),
                        getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                    putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                    stringRHS->inUse = 0;
                  }
              es1s2s2:;
              } // End of DO block
            // ELSE (15605)
            else
              // IF (INST=124  ) & ((R MOD 2 ~= 0) | (LHS=SRSTYPE)) THEN
              // (15606)
              if (1
                  & (xAND (xEQ (getFIXED (mINST), 124),
                           xOR (xNEQ (xmod (getFIXED (mR), 2), 0),
                                xEQ (COREHALFWORD (mLHS), BYTE0 (mSRSTYPE))))))
                // DO; (15607)
                {
                rs1s2s3:;
                  // IF IX ~= 0 THEN (15608)
                  if (1 & (xNEQ (getFIXED (mIX), 0)))
                    // DO; (15609)
                    {
                    rs1s2s3s1:;
                      // IF (SHL(F,1) + IA) > 0 THEN (15610)
                      if (1
                          & (xGT (
                              xadd (SHL (getFIXED (mF), 1), getFIXED (mIA)),
                              0)))
                        // TAG_NAME = TIMES(50)||' (SEE POO)'||TAG_NAME;
                        // (15611)
                        {
                          descriptor_t *stringRHS;
                          stringRHS = xsCAT (
                              xsCAT (
                                  getCHARACTER (
                                      mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                                      + 4 * 50),
                                  cToDescriptor (NULL, " (SEE POO)")),
                              getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                          putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                          stringRHS->inUse = 0;
                        }
                      // ELSE (15612)
                      else
                        // TAG_NAME = TIMES(62)||TAG_NAME; (15613)
                        {
                          descriptor_t *stringRHS;
                          stringRHS = xsCAT (
                              getCHARACTER (
                                  mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                                  + 4 * 62),
                              getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                          putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                          stringRHS->inUse = 0;
                        }
                    es1s2s3s1:;
                    } // End of DO block
                  // ELSE (15614)
                  else
                    // TAG_NAME = TIMES(29)||TAG_NAME; (15615)
                    {
                      descriptor_t *stringRHS;
                      stringRHS = xsCAT (
                          getCHARACTER (
                              mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                              + 4 * 29),
                          getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                      putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                      stringRHS->inUse = 0;
                    }
                es1s2s3:;
                } // End of DO block
              // ELSE (15616)
              else
                // IF IX ~= 0 THEN (15617)
                if (1 & (xNEQ (getFIXED (mIX), 0)))
                  // DO; (15618)
                  {
                  rs1s2s4:;
                    // IF (SHL(F,1) + IA) > 0 THEN (15619)
                    if (1
                        & (xGT (xadd (SHL (getFIXED (mF), 1), getFIXED (mIA)),
                                0)))
                      // TAG_NAME = TIMES(INDIRECT_TIMES(INST))||' (SEE
                      // POO)'||TAG_NAME; (15620)
                      {
                        descriptor_t *stringRHS;
                        stringRHS = xsCAT (
                            xsCAT (
                                getCHARACTER (
                                    mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                                    + 4
                                          * BYTE0 (
                                              mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxINDIRECT_TIMES
                                              + 1 * getFIXED (mINST))),
                                cToDescriptor (NULL, " (SEE POO)")),
                            getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                        putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                        stringRHS->inUse = 0;
                      }
                    // ELSE (15621)
                    else
                      // TAG_NAME = TIMES(INDEX_TIMES(INST))||TAG_NAME; (15622)
                      {
                        descriptor_t *stringRHS;
                        stringRHS = xsCAT (
                            getCHARACTER (
                                mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                                + 4
                                      * BYTE0 (
                                          mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxINDEX_TIMES
                                          + 1 * getFIXED (mINST))),
                            getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                        putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                        stringRHS->inUse = 0;
                      }
                  es1s2s4:;
                  } // End of DO block
                // ELSE (15623)
                else
                  // TAG_NAME = TIMES(NORMAL_TIMES(INST))||TAG_NAME; (15624)
                  {
                    descriptor_t *stringRHS;
                    stringRHS = xsCAT (
                        getCHARACTER (
                            mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                            + 4
                                  * BYTE0 (
                                      mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxNORMAL_TIMES
                                      + 1 * getFIXED (mINST))),
                        getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                    putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                    stringRHS->inUse = 0;
                  }
          // IF INST = IAL THEN (15625)
          if (1 & (xEQ (getFIXED (mINST), BYTE0 (mIAL))))
            // DO; (15626)
            {
            rs1s2s5:;
              // IF LHS ~= SRSTYPE & B = 3 THEN (15627)
              if (1
                  & (xAND (xNEQ (COREHALFWORD (mLHS), BYTE0 (mSRSTYPE)),
                           xEQ (getFIXED (mB), 3))))
                // DO; (15628)
                {
                rs1s2s5s1:;
                  // MVH_COUNT(R) = D; (15629)
                  {
                    int32_t numberRHS = (int32_t)(getFIXED (mD));
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (16,
                            mOBJECT_GENERATORxMVH_COUNT + 2 * (getFIXED (mR)),
                            bitRHS);
                    bitRHS->inUse = 0;
                  }
                  // MVH_CNT_KNOWN(R) = TRUE; (15630)
                  {
                    int32_t numberRHS = (int32_t)(1);
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (1,
                            mOBJECT_GENERATORxMVH_CNT_KNOWN
                                + 1 * (getFIXED (mR)),
                            bitRHS);
                    bitRHS->inUse = 0;
                  }
                es1s2s5s1:;
                } // End of DO block
              // ELSE (15631)
              else
                // MVH_CNT_KNOWN(R) = FALSE; (15632)
                {
                  int32_t numberRHS = (int32_t)(0);
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (
                      1, mOBJECT_GENERATORxMVH_CNT_KNOWN + 1 * (getFIXED (mR)),
                      bitRHS);
                  bitRHS->inUse = 0;
                }
            es1s2s5:;
            } // End of DO block
        es1s2:;
        } // End of DO block
        break;
      case 2:
        // DO; (15634)
        {
        rs1s3:;
          // IF (INST >=  144) & (INST <=  159) & (IX ~= 0) THEN (15634)
          if (1
              & (xAND (xAND (xGE (getFIXED (mINST), 144),
                             xLE (getFIXED (mINST), 159)),
                       xNEQ (getFIXED (mIX), 0))))
            // DO; (15635)
            {
            rs1s3s1:;
              // IF (SHL(F,1) + IA) > 0 THEN (15636)
              if (1 & (xGT (xadd (SHL (getFIXED (mF), 1), getFIXED (mIA)), 0)))
                // TAG_NAME = TIMES(INDIRECT_TIMES(INST))||' (SEE
                // POO)'||TAG_NAME; (15637)
                {
                  descriptor_t *stringRHS;
                  stringRHS = xsCAT (
                      xsCAT (
                          getCHARACTER (
                              mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                              + 4
                                    * BYTE0 (
                                        mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxINDIRECT_TIMES
                                        + 1 * getFIXED (mINST))),
                          cToDescriptor (NULL, " (SEE POO)")),
                      getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                  putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                  stringRHS->inUse = 0;
                }
              // ELSE (15638)
              else
                // TAG_NAME = TIMES(INDEX_TIMES(INST))||TAG_NAME; (15639)
                {
                  descriptor_t *stringRHS;
                  stringRHS = xsCAT (
                      getCHARACTER (
                          mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                          + 4
                                * BYTE0 (
                                    mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxINDEX_TIMES
                                    + 1 * getFIXED (mINST))),
                      getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                  putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                  stringRHS->inUse = 0;
                }
            es1s3s1:;
            } // End of DO block
          // ELSE (15640)
          else
            // IF (INST=SRL) | (INST=SRA) | (INST=SLDL) | (INST=SRDA) |
            // (INST=SLL) | (INST=140  ) THEN (15641)
            if (1
                & (xOR (
                    xOR (xOR (xOR (xOR (xEQ (getFIXED (mINST), BYTE0 (mSRL)),
                                        xEQ (getFIXED (mINST), BYTE0 (mSRA))),
                                   xEQ (getFIXED (mINST), BYTE0 (mSLDL))),
                              xEQ (getFIXED (mINST), BYTE0 (mSRDA))),
                         xEQ (getFIXED (mINST), BYTE0 (mSLL))),
                    xEQ (getFIXED (mINST), 140))))
              // DO; (15642)
              {
              rs1s3s2:;
                // IF B = 0 THEN (15643)
                if (1 & (xEQ (getFIXED (mB), 0)))
                  // TAG_NAME = TIMES(NORMAL_TIMES(INST))||D||')'||TAG_NAME;
                  // (15644)
                  {
                    descriptor_t *stringRHS;
                    stringRHS = xsCAT (
                        xsCAT (
                            xsCAT (
                                getCHARACTER (
                                    mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                                    + 4
                                          * BYTE0 (
                                              mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxNORMAL_TIMES
                                              + 1 * getFIXED (mINST))),
                                fixedToCharacter (getFIXED (mD))),
                            cToDescriptor (NULL, ")")),
                        getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                    putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                    stringRHS->inUse = 0;
                  }
                // ELSE (15645)
                else
                  // TAG_NAME =
                  // TIMES(NORMAL_TIMES(INST))||'R'||ABS(B)||')'||TAG_NAME;
                  // (15646)
                  {
                    descriptor_t *stringRHS;
                    stringRHS = xsCAT (
                        xsCAT (
                            xsCAT (
                                xsCAT (
                                    getCHARACTER (
                                        mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                                        + 4
                                              * BYTE0 (
                                                  mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxNORMAL_TIMES
                                                  + 1 * getFIXED (mINST))),
                                    cToDescriptor (NULL, "R")),
                                fixedToCharacter (ABS (getFIXED (mB)))),
                            cToDescriptor (NULL, ")")),
                        getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                    putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                    stringRHS->inUse = 0;
                  }
              es1s3s2:;
              } // End of DO block
            // ELSE (15647)
            else
              // TAG_NAME = TIMES(NORMAL_TIMES(INST))||TAG_NAME; (15648)
              {
                descriptor_t *stringRHS;
                stringRHS = xsCAT (
                    getCHARACTER (
                        mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                        + 4
                              * BYTE0 (
                                  mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxNORMAL_TIMES
                                  + 1 * getFIXED (mINST))),
                    getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                stringRHS->inUse = 0;
              }
        es1s3:;
        } // End of DO block
        break;
      case 3:
        // DO; (15650)
        {
        rs1s4:;
          // IF (INST=LDM) THEN (15650)
          if (1 & (xEQ (getFIXED (mINST), BYTE0 (mLDM))))
            // DO; (15651)
            {
            rs1s4s1:;
              // IF IX = 0 THEN (15652)
              if (1 & (xEQ (getFIXED (mIX), 0)))
                // TAG_NAME = TIMES(NORMAL_TIMES(INST))||TAG_NAME; (15653)
                {
                  descriptor_t *stringRHS;
                  stringRHS = xsCAT (
                      getCHARACTER (
                          mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                          + 4
                                * BYTE0 (
                                    mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxNORMAL_TIMES
                                    + 1 * getFIXED (mINST))),
                      getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                  putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                  stringRHS->inUse = 0;
                }
              // ELSE (15654)
              else
                // DO; (15655)
                {
                rs1s4s1s1:;
                  // IF (SHL(F,1) + IA) > 0 THEN (15656)
                  if (1
                      & (xGT (xadd (SHL (getFIXED (mF), 1), getFIXED (mIA)),
                              0)))
                    // TAG_NAME = TIMES(INDIRECT_TIMES(INST))||' (SEE
                    // POO)'||TAG_NAME; (15657)
                    {
                      descriptor_t *stringRHS;
                      stringRHS = xsCAT (
                          xsCAT (
                              getCHARACTER (
                                  mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                                  + 4
                                        * BYTE0 (
                                            mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxINDIRECT_TIMES
                                            + 1 * getFIXED (mINST))),
                              cToDescriptor (NULL, " (SEE POO)")),
                          getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                      putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                      stringRHS->inUse = 0;
                    }
                  // ELSE (15658)
                  else
                    // TAG_NAME = TIMES(INDEX_TIMES(INST))||TAG_NAME; (15659)
                    {
                      descriptor_t *stringRHS;
                      stringRHS = xsCAT (
                          getCHARACTER (
                              mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                              + 4
                                    * BYTE0 (
                                        mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxINDEX_TIMES
                                        + 1 * getFIXED (mINST))),
                          getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                      putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                      stringRHS->inUse = 0;
                    }
                es1s4s1s1:;
                } // End of DO block
            es1s4s1:;
            } // End of DO block
          // ELSE (15660)
          else
            // IF (INST=SRR) THEN (15661)
            if (1 & (xEQ (getFIXED (mINST), BYTE0 (mSRR))))
              // TAG_NAME = TIMES(NORMAL_TIMES(INST))||D||')'||TAG_NAME;
              // (15662)
              {
                descriptor_t *stringRHS;
                stringRHS = xsCAT (
                    xsCAT (
                        xsCAT (
                            getCHARACTER (
                                mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxTIMES
                                + 4
                                      * BYTE0 (
                                          mOBJECT_GENERATORxGENERATE_OPERANDSxEXECUTION_TIMESxNORMAL_TIMES
                                          + 1 * getFIXED (mINST))),
                            fixedToCharacter (getFIXED (mD))),
                        cToDescriptor (NULL, ")")),
                    getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
                putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
                stringRHS->inUse = 0;
              }
        es1s4:;
        } // End of DO block
        break;
      }
  } // End of DO CASE block
  // TAG_NAME = 'TIME: '||TAG_NAME; (15663)
  {
    descriptor_t *stringRHS;
    stringRHS = xsCAT (cToDescriptor (NULL, "TIME: "),
                       getCHARACTER (mOBJECT_GENERATORxTAG_NAME));
    putCHARACTER (mOBJECT_GENERATORxTAG_NAME, stringRHS);
    stringRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
