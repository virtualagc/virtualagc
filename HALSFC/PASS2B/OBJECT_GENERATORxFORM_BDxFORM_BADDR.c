/*
  File OBJECT_GENERATORxFORM_BDxFORM_BADDR.c generated by XCOM-I, 2024-08-08
  04:34:25.
*/

#include "runtimeC.h"

int32_t
OBJECT_GENERATORxFORM_BDxFORM_BADDR (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard
      = guardReentry (reentryGuard, "OBJECT_GENERATORxFORM_BDxFORM_BADDR");
  // PTR = REAL_LABEL(PTR); (15660)
  {
    descriptor_t *bitRHS
        = (putBITp (16, mREAL_LABELxLBL,
                    getBIT (16, mOBJECT_GENERATORxFORM_BDxFORM_BADDRxPTR)),
           REAL_LABEL (0));
    putBIT (16, mOBJECT_GENERATORxFORM_BDxFORM_BADDRxPTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // DEST = LOCATION(PTR) + ADDRESS_MOD + ORIGIN(CURRENT_ESDID); (15661)
  {
    int32_t numberRHS = (int32_t)(xadd (
        xadd (
            getFIXED (
                getFIXED (mLAB_LOC)
                + 8 * (COREHALFWORD (mOBJECT_GENERATORxFORM_BDxFORM_BADDRxPTR))
                + 0 + 4 * (0)),
            getFIXED (mOBJECT_GENERATORxADDRESS_MOD)),
        getFIXED (mORIGIN + 4 * getFIXED (mCURRENT_ESDID))));
    putFIXED (mOBJECT_GENERATORxFORM_BDxFORM_BADDRxDEST, numberRHS);
  }
  // ADDRESS_MOD = 0; (15662)
  {
    int32_t numberRHS = (int32_t)(0);
    putFIXED (mOBJECT_GENERATORxADDRESS_MOD, numberRHS);
  }
  // CALL FORM_EFFAD(DEST); (15663)
  {
    putFIXED (mOBJECT_GENERATORxFORM_EFFADxI,
              getFIXED (mOBJECT_GENERATORxFORM_BDxFORM_BADDRxDEST));
    OBJECT_GENERATORxFORM_EFFAD (0);
  }
  // IF LHS = SRSTYPE THEN (15664)
  if (1 & (xEQ (COREHALFWORD (mLHS), BYTE0 (mSRSTYPE))))
    // DO; (15665)
    {
    rs1:;
      // B = -1; (15666)
      {
        int32_t numberRHS = (int32_t)(-1);
        putFIXED (mB, numberRHS);
      }
      // D = DEST - CURRENT_ADDRESS - 1; (15667)
      {
        int32_t numberRHS = (int32_t)(xsubtract (
            xsubtract (getFIXED (mOBJECT_GENERATORxFORM_BDxFORM_BADDRxDEST),
                       getFIXED (mWORKSEG + 4 * getFIXED (mCURRENT_ESDID))),
            1));
        putFIXED (mD, numberRHS);
      }
      // IF D < 0 THEN (15668)
      if (1 & (xLT (getFIXED (mD), 0)))
        // D = -D; (15669)
        {
          int32_t numberRHS = (int32_t)(xminus (getFIXED (mD)));
          putFIXED (mD, numberRHS);
        }
      // ELSE (15670)
      else
        // RHS = RHS - 2; (15671)
        {
          int32_t numberRHS = (int32_t)(xsubtract (COREHALFWORD (mRHS), 2));
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mRHS, bitRHS);
          bitRHS->inUse = 0;
        }
    es1:;
    } // End of DO block
  // ELSE (15672)
  else
    // DO; (15673)
    {
    rs2:;
      // B = 3; (15674)
      {
        int32_t numberRHS = (int32_t)(3);
        putFIXED (mB, numberRHS);
      }
      // AM = 1; (15675)
      {
        int32_t numberRHS = (int32_t)(1);
        putFIXED (mAM, numberRHS);
      }
      // IF DEST >= CURRENT_ADDRESS+2 THEN (15676)
      if (1
          & (xGE (
              getFIXED (mOBJECT_GENERATORxFORM_BDxFORM_BADDRxDEST),
              xadd (getFIXED (mWORKSEG + 4 * getFIXED (mCURRENT_ESDID)), 2))))
        // D = DEST - CURRENT_ADDRESS-2; (15677)
        {
          int32_t numberRHS = (int32_t)(xsubtract (
              xsubtract (getFIXED (mOBJECT_GENERATORxFORM_BDxFORM_BADDRxDEST),
                         getFIXED (mWORKSEG + 4 * getFIXED (mCURRENT_ESDID))),
              2));
          putFIXED (mD, numberRHS);
        }
      // ELSE (15678)
      else
        // DO; (15679)
        {
        rs2s1:;
          // D = CURRENT_ADDRESS+2 - DEST; (15680)
          {
            int32_t numberRHS = (int32_t)(xsubtract (
                xadd (getFIXED (mWORKSEG + 4 * getFIXED (mCURRENT_ESDID)), 2),
                getFIXED (mOBJECT_GENERATORxFORM_BDxFORM_BADDRxDEST)));
            putFIXED (mD, numberRHS);
          }
          // F = 1; (15681)
          {
            int32_t numberRHS = (int32_t)(1);
            putFIXED (mF, numberRHS);
          }
        es2s1:;
        } // End of DO block
      // IF D >= PCRELMAX THEN (15682)
      if (1
          & (xGE (
              getFIXED (mD),
              COREHALFWORD (mOBJECT_GENERATORxFORM_BDxFORM_BADDRxPCRELMAX))))
        // DO; (15683)
        {
        rs2s2:;
          // D = DEST; (15684)
          {
            int32_t numberRHS = (int32_t)(getFIXED (
                mOBJECT_GENERATORxFORM_BDxFORM_BADDRxDEST));
            putFIXED (mD, numberRHS);
          }
          // AM, F = 0; (15685)
          {
            int32_t numberRHS = (int32_t)(0);
            putFIXED (mAM, numberRHS);
            putFIXED (mF, numberRHS);
          }
          // IF CURRENT_ESDID<= PROCLIMIT THEN (15686)
          if (1 & (xLE (getFIXED (mCURRENT_ESDID), COREHALFWORD (mPROCLIMIT))))
            // DO; (15687)
            {
            rs2s2s1:;
              // IF LOCATION_LINK(PTR) < 0 THEN (15688)
              if (1
                  & (xLT (
                      COREHALFWORD (
                          getFIXED (mLAB_LOC)
                          + 8
                                * (COREHALFWORD (
                                    mOBJECT_GENERATORxFORM_BDxFORM_BADDRxPTR))
                          + 6 + 2 * (0)),
                      0)))
                // CALL EMIT_RLD(CURRENT_ESDID+SDELTA, CURRENT_ADDRESS+1);
                // (15689)
                {
                  putBITp (16, mOBJECT_GENERATORxEMIT_RLDxREL,
                           fixedToBit (
                               32, (int32_t)(xadd (getFIXED (mCURRENT_ESDID),
                                                   COREHALFWORD (mSDELTA)))));
                  putFIXED (mOBJECT_GENERATORxEMIT_RLDxADR,
                            xadd (getFIXED (mWORKSEG
                                            + 4 * getFIXED (mCURRENT_ESDID)),
                                  1));
                  OBJECT_GENERATORxEMIT_RLD (0);
                }
              // ELSE (15690)
              else
                // CALL EMIT_RLD(CURRENT_ESDID, CURRENT_ADDRESS+1); (15691)
                {
                  putBITp (
                      16, mOBJECT_GENERATORxEMIT_RLDxREL,
                      fixedToBit (32, (int32_t)(getFIXED (mCURRENT_ESDID))));
                  putFIXED (mOBJECT_GENERATORxEMIT_RLDxADR,
                            xadd (getFIXED (mWORKSEG
                                            + 4 * getFIXED (mCURRENT_ESDID)),
                                  1));
                  OBJECT_GENERATORxEMIT_RLD (0);
                }
            es2s2s1:;
            } // End of DO block
          // ELSE (15692)
          else
            // DO; (15693)
            {
            rs2s2s2:;
              // IF LOCATION_LINK(PTR)<0 THEN (15694)
              if (1
                  & (xLT (
                      COREHALFWORD (
                          getFIXED (mLAB_LOC)
                          + 8
                                * (COREHALFWORD (
                                    mOBJECT_GENERATORxFORM_BDxFORM_BADDRxPTR))
                          + 6 + 2 * (0)),
                      0)))
                // CALL EMIT_RLD(CURRENT_ESDID,CURRENT_ADDRESS+1); (15695)
                {
                  putBITp (
                      16, mOBJECT_GENERATORxEMIT_RLDxREL,
                      fixedToBit (32, (int32_t)(getFIXED (mCURRENT_ESDID))));
                  putFIXED (mOBJECT_GENERATORxEMIT_RLDxADR,
                            xadd (getFIXED (mWORKSEG
                                            + 4 * getFIXED (mCURRENT_ESDID)),
                                  1));
                  OBJECT_GENERATORxEMIT_RLD (0);
                }
              // ELSE (15696)
              else
                // CALL EMIT_RLD(CURRENT_ESDID-SDELTA,CURRENT_ADDRESS+1);
                // (15697)
                {
                  putBITp (16, mOBJECT_GENERATORxEMIT_RLDxREL,
                           fixedToBit (32, (int32_t)(xsubtract (
                                               getFIXED (mCURRENT_ESDID),
                                               COREHALFWORD (mSDELTA)))));
                  putFIXED (mOBJECT_GENERATORxEMIT_RLDxADR,
                            xadd (getFIXED (mWORKSEG
                                            + 4 * getFIXED (mCURRENT_ESDID)),
                                  1));
                  OBJECT_GENERATORxEMIT_RLD (0);
                }
            es2s2s2:;
            } // End of DO block
        es2s2:;
        } // End of DO block
    es2:;
    } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
