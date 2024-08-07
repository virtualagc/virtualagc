/*
  File RELOCATE.c generated by XCOM-I, 2024-08-08 04:34:00.
*/

#include "runtimeC.h"

int32_t
RELOCATE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "RELOCATE");
  // I=NEW; (1233)
  {
    descriptor_t *bitRHS = getBIT (16, mRELOCATExNEW);
    putBIT (16, mRELOCATExI, bitRHS);
    bitRHS->inUse = 0;
  }
  // REL_STOP, STOP=START+SIZE; (1234)
  {
    int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mRELOCATExSTART),
                                        COREHALFWORD (mRELOCATExROW)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mRELOCATExREL_STOP, bitRHS);
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mRELOCATExSTOP, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF CHECK_TO_XREC THEN (1235)
  if (1 & (bitToFixed (getBIT (8, mRELOCATExCHECK_TO_XREC))))
    // STOPPING = XXREC; (1236)
    {
      descriptor_t *bitRHS = getBIT (16, mXXREC);
      putBIT (16, mRELOCATExSTOPPING, bitRHS);
      bitRHS->inUse = 0;
    }
  // ELSE (1237)
  else
    // DO; (1238)
    {
    rs1:;
      // STOPPING = XSMRK; (1239)
      {
        descriptor_t *bitRHS = getBIT (16, mXSMRK);
        putBIT (16, mRELOCATExSTOPPING, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF ~ NOT_TOTAL_RELOCATE THEN (1240)
      if (1 & (xNOT (BYTE0 (mRELOCATExNOT_TOTAL_RELOCATE))))
        // IF SMRK_CTR > REL_STOP THEN (1241)
        if (1
            & (xGT (COREHALFWORD (mSMRK_CTR),
                    COREHALFWORD (mRELOCATExREL_STOP))))
          // REL_STOP = SMRK_CTR; (1242)
          {
            descriptor_t *bitRHS = getBIT (16, mSMRK_CTR);
            putBIT (16, mRELOCATExREL_STOP, bitRHS);
            bitRHS->inUse = 0;
          }
    es1:;
    } // End of DO block
  // BACK=NEW-START; (1243)
  {
    int32_t numberRHS = (int32_t)(xsubtract (COREHALFWORD (mRELOCATExNEW),
                                             COREHALFWORD (mRELOCATExSTART)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mRELOCATExBACK, bitRHS);
    bitRHS->inUse = 0;
  }
  // DO WHILE I < REL_STOP; (1244)
  while (
      1
      & (xLT (COREHALFWORD (mRELOCATExI), COREHALFWORD (mRELOCATExREL_STOP))))
    {
      // DO WHILE (OPR(I) &  65521) ~= STOPPING &  (OPR(I) &  65521) ~= XXREC;
      // (1245)
      while (1
             & (xAND (
                 xNEQ (xAND (getFIXED (mOPR + 4 * COREHALFWORD (mRELOCATExI)),
                             65521),
                       COREHALFWORD (mRELOCATExSTOPPING)),
                 xNEQ (xAND (getFIXED (mOPR + 4 * COREHALFWORD (mRELOCATExI)),
                             65521),
                       COREHALFWORD (mXXREC)))))
        {
          // IF OPR(I) THEN (1246)
          if (1 & (getFIXED (mOPR + 4 * COREHALFWORD (mRELOCATExI))))
            // DO; (1247)
            {
            rs2s1s1:;
              // TAG1=SHR(OPR(I),4)& 15; (1248)
              {
                int32_t numberRHS = (int32_t)(xAND (
                    SHR (getFIXED (mOPR + 4 * COREHALFWORD (mRELOCATExI)), 4),
                    15));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mTAG1, bitRHS);
                bitRHS->inUse = 0;
              }
              // OP1=SHR(OPR(I),16); (1249)
              {
                int32_t numberRHS = (int32_t)(SHR (
                    getFIXED (mOPR + 4 * COREHALFWORD (mRELOCATExI)), 16));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mOP1, bitRHS);
                bitRHS->inUse = 0;
              }
              // IF (TAG1=VAC | TAG1=XPT) & ~((OPR(I)& 12) =  12 &CHECKTAG)
              // THEN (1250)
              if (1
                  & (xAND (
                      xOR (xEQ (COREHALFWORD (mTAG1), COREHALFWORD (mVAC)),
                           xEQ (COREHALFWORD (mTAG1), COREHALFWORD (mXPT))),
                      xNOT (xAND (
                          xEQ (
                              xAND (getFIXED (
                                        mOPR + 4 * COREHALFWORD (mRELOCATExI)),
                                    12),
                              12),
                          BYTE0 (mRELOCATExCHECKTAG))))))
                // DO; (1251)
                {
                rs2s1s1s1:;
                  // IF OP1<START THEN (1252)
                  if (1
                      & (xLT (COREHALFWORD (mOP1),
                              COREHALFWORD (mRELOCATExSTART))))
                    // DO; (1253)
                    {
                    rs2s1s1s1s1:;
                      // IF OP1>=NEW THEN (1254)
                      if (1
                          & (xGE (COREHALFWORD (mOP1),
                                  COREHALFWORD (mRELOCATExNEW))))
                        // OP1=OP1+SIZE; (1255)
                        {
                          int32_t numberRHS
                              = (int32_t)(xadd (COREHALFWORD (mOP1),
                                                COREHALFWORD (mRELOCATExROW)));
                          descriptor_t *bitRHS;
                          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                          putBIT (16, mOP1, bitRHS);
                          bitRHS->inUse = 0;
                        }
                    es2s1s1s1s1:;
                    } // End of DO block
                  // ELSE (1256)
                  else
                    // IF OP1<STOP THEN (1257)
                    if (1
                        & (xLT (COREHALFWORD (mOP1),
                                COREHALFWORD (mRELOCATExSTOP))))
                      // OP1=OP1+BACK; (1258)
                      {
                        int32_t numberRHS
                            = (int32_t)(xadd (COREHALFWORD (mOP1),
                                              COREHALFWORD (mRELOCATExBACK)));
                        descriptor_t *bitRHS;
                        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                        putBIT (16, mOP1, bitRHS);
                        bitRHS->inUse = 0;
                      }
                  // OPR(I)=SHL(OP1,16)+(OPR(I)& 65535); (1259)
                  {
                    int32_t numberRHS = (int32_t)(xadd (
                        SHL (COREHALFWORD (mOP1), 16),
                        xAND (getFIXED (mOPR + 4 * COREHALFWORD (mRELOCATExI)),
                              65535)));
                    putFIXED (mOPR + 4 * (COREHALFWORD (mRELOCATExI)),
                              numberRHS);
                  }
                es2s1s1s1:;
                } // End of DO block
            es2s1s1:;
            } // End of DO block
          // I=I+1; (1260)
          {
            int32_t numberRHS
                = (int32_t)(xadd (COREHALFWORD (mRELOCATExI), 1));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mRELOCATExI, bitRHS);
            bitRHS->inUse = 0;
          }
        } // End of DO WHILE block
      // I = I + 2; (1261)
      {
        int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mRELOCATExI), 2));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mRELOCATExI, bitRHS);
        bitRHS->inUse = 0;
      }
    } // End of DO WHILE block
  // IF PRESENT_HALMAT<START THEN (1262)
  if (1
      & (xLT (COREHALFWORD (mPRESENT_HALMAT), COREHALFWORD (mRELOCATExSTART))))
    // DO; (1263)
    {
    rs3:;
      // IF PRESENT_HALMAT>=NEW THEN (1264)
      if (1
          & (xGE (COREHALFWORD (mPRESENT_HALMAT),
                  COREHALFWORD (mRELOCATExNEW))))
        // PRESENT_HALMAT=PRESENT_HALMAT+SIZE; (1265)
        {
          int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mPRESENT_HALMAT),
                                              COREHALFWORD (mRELOCATExROW)));
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mPRESENT_HALMAT, bitRHS);
          bitRHS->inUse = 0;
        }
    es3:;
    } // End of DO block
  // ELSE (1266)
  else
    // IF PRESENT_HALMAT<STOP THEN (1267)
    if (1
        & (xLT (COREHALFWORD (mPRESENT_HALMAT),
                COREHALFWORD (mRELOCATExSTOP))))
      // PRESENT_HALMAT=PRESENT_HALMAT+BACK; (1268)
      {
        int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mPRESENT_HALMAT),
                                            COREHALFWORD (mRELOCATExBACK)));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mPRESENT_HALMAT, bitRHS);
        bitRHS->inUse = 0;
      }
  // IF HP < START THEN (1269)
  if (1 & (xLT (COREHALFWORD (mHP), COREHALFWORD (mRELOCATExSTART))))
    // DO; (1270)
    {
    rs4:;
      // IF HP >= NEW THEN (1271)
      if (1 & (xGE (COREHALFWORD (mHP), COREHALFWORD (mRELOCATExNEW))))
        // HP = HP + SIZE; (1272)
        {
          int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mHP),
                                              COREHALFWORD (mRELOCATExROW)));
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mHP, bitRHS);
          bitRHS->inUse = 0;
        }
    es4:;
    } // End of DO block
  // ELSE (1273)
  else
    // IF HP < STOP THEN (1274)
    if (1 & (xLT (COREHALFWORD (mHP), COREHALFWORD (mRELOCATExSTOP))))
      // HP = HP + BACK; (1275)
      {
        int32_t numberRHS = (int32_t)(xadd (COREHALFWORD (mHP),
                                            COREHALFWORD (mRELOCATExBACK)));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mHP, bitRHS);
        bitRHS->inUse = 0;
      }
  // IF MOVE_TRACE THEN (1276)
  if (1 & (bitToFixed (getBIT (8, mMOVE_TRACE))))
    // OUTPUT = 'MOVE_TRACE:  ' || START || ' TO ' || STOP - 1 || ' MOVED
    // BEFORE ' || NEW || ' AND RELOCATED TO ' || I; (1277)
    {
      descriptor_t *stringRHS;
      stringRHS = xsCAT (
          xsCAT (xsCAT (xsCAT (xsCAT (xsCAT (xsCAT (cToDescriptor (
                                                        NULL, "MOVE_TRACE:  "),
                                                    bitToCharacter (getBIT (
                                                        16, mRELOCATExSTART))),
                                             cToDescriptor (NULL, " TO ")),
                                      fixedToCharacter (xsubtract (
                                          COREHALFWORD (mRELOCATExSTOP), 1))),
                               cToDescriptor (NULL, " MOVED BEFORE ")),
                        bitToCharacter (getBIT (16, mRELOCATExNEW))),
                 cToDescriptor (NULL, " AND RELOCATED TO ")),
          bitToCharacter (getBIT (16, mRELOCATExI)));
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  // CHECK_TO_XREC, CHECKTAG = 0; (1278)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (8, mRELOCATExCHECK_TO_XREC, bitRHS);
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (8, mRELOCATExCHECKTAG, bitRHS);
    bitRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
