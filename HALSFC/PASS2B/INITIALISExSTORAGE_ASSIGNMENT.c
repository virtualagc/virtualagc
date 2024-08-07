/*
  File INITIALISExSTORAGE_ASSIGNMENT.c generated by XCOM-I, 2024-08-08
  04:34:25.
*/

#include "runtimeC.h"

int32_t
INITIALISExSTORAGE_ASSIGNMENT (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "INITIALISExSTORAGE_ASSIGNMENT");
  // M = SHR(NDECSY, 1); (2230)
  {
    int32_t numberRHS = (int32_t)(SHR (COREHALFWORD (mNDECSY), 1));
    putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxM, numberRHS);
  }
  // DO WHILE M > 0; (2231)
  while (1 & (xGT (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxM), 0)))
    {
      // DO J = 1 TO NDECSY - M; (2232)
      {
        int32_t from34, to34, by34;
        from34 = 1;
        to34 = xsubtract (COREHALFWORD (mNDECSY),
                          getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxM));
        by34 = 1;
        for (putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ, from34);
             getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ) <= to34;
             putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ,
                       getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ) + by34))
          {
            // I = J; (2233)
            {
              int32_t numberRHS
                  = (int32_t)(getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ));
              putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxI, numberRHS);
            }
            // DO WHILE SYT_SORT(I) > SYT_SORT(I+M); (2234)
            while (
                1
                & (xGT (
                    getFIXED (
                        getFIXED (mDOSORT)
                        + 4 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxI)) + 0
                        + 4 * (0)),
                    getFIXED (
                        getFIXED (mDOSORT)
                        + 4
                              * (xadd (
                                  getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxI),
                                  getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxM)))
                        + 0 + 4 * (0)))))
              {
                // L = SYT_SORT(I); (2235)
                {
                  int32_t numberRHS = (int32_t)(getFIXED (
                      getFIXED (mDOSORT)
                      + 4 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxI)) + 0
                      + 4 * (0)));
                  putFIXED (mINITIALISExL, numberRHS);
                }
                // SYT_SORT(I) = SYT_SORT(I+M); (2236)
                {
                  int32_t numberRHS = (int32_t)(getFIXED (
                      getFIXED (mDOSORT)
                      + 4
                            * (xadd (
                                getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxI),
                                getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxM)))
                      + 0 + 4 * (0)));
                  putFIXED (
                      getFIXED (mDOSORT)
                          + 4 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxI))
                          + 0 + 4 * (0),
                      numberRHS);
                }
                // SYT_SORT(I+M) = L; (2237)
                {
                  int32_t numberRHS = (int32_t)(getFIXED (mINITIALISExL));
                  putFIXED (
                      getFIXED (mDOSORT)
                          + 4
                                * (xadd (
                                    getFIXED (
                                        mINITIALISExSTORAGE_ASSIGNMENTxI),
                                    getFIXED (
                                        mINITIALISExSTORAGE_ASSIGNMENTxM)))
                          + 0 + 4 * (0),
                      numberRHS);
                }
                // I = I - M; (2238)
                {
                  int32_t numberRHS = (int32_t)(xsubtract (
                      getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxI),
                      getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxM)));
                  putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxI, numberRHS);
                }
                // IF I < 1 THEN (2239)
                if (1 & (xLT (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxI), 1)))
                  // GO TO SORT_EXIT; (2240)
                  goto SORT_EXIT;
              } // End of DO WHILE block
          // SORT_EXIT: (2241)
          SORT_EXIT:;
          }
      } // End of DO for-loop block
      // M = SHR(M, 1); (2242)
      {
        int32_t numberRHS
            = (int32_t)(SHR (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxM), 1));
        putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxM, numberRHS);
      }
    } // End of DO WHILE block
  // P = 1; (2243)
  {
    int32_t numberRHS = (int32_t)(1);
    putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxP, numberRHS);
  }
  // DO WHILE P <= NDECSY; (2244)
  while (1
         & (xLE (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxP),
                 COREHALFWORD (mNDECSY))))
    {
      // PROCPOINT = SHR(SYT_SORT(P),16); (2245)
      {
        int32_t numberRHS = (int32_t)(SHR (
            getFIXED (getFIXED (mDOSORT)
                      + 4 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxP)) + 0
                      + 4 * (0)),
            16));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mPROCPOINT, bitRHS);
        bitRHS->inUse = 0;
      }
      // SDF_INCLUDED = (SYT_FLAGS(PROC_LEVEL(PROCPOINT))&SDF_INCL_FLAG)~=0;
      // (2246)
      {
        int32_t numberRHS = (int32_t)(xNEQ (
            xAND (getFIXED (
                      getFIXED (mSYM_TAB)
                      + 34
                            * (COREHALFWORD (mPROC_LEVEL
                                             + 2 * COREHALFWORD (mPROCPOINT)))
                      + 8 + 4 * (0)),
                  getFIXED (mSDF_INCL_FLAG)),
            0));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (1, mINITIALISExSDF_INCLUDED, bitRHS);
        bitRHS->inUse = 0;
      }
      // RIGID_BLOCK = (SYT_FLAGS(PROC_LEVEL(PROCPOINT))&RIGID_FLAG) ~= 0 &
      // (SYT_FLAGS(PROC_LEVEL(PROCPOINT))&SDF_INCL_LIST) = 0; (2247)
      {
        int32_t numberRHS = (int32_t)(xAND (
            xNEQ (xAND (getFIXED (getFIXED (mSYM_TAB)
                                  + 34
                                        * (COREHALFWORD (
                                            mPROC_LEVEL
                                            + 2 * COREHALFWORD (mPROCPOINT)))
                                  + 8 + 4 * (0)),
                        getFIXED (mRIGID_FLAG)),
                  0),
            xEQ (xAND (getFIXED (getFIXED (mSYM_TAB)
                                 + 34
                                       * (COREHALFWORD (
                                           mPROC_LEVEL
                                           + 2 * COREHALFWORD (mPROCPOINT)))
                                 + 8 + 4 * (0)),
                       getFIXED (mSDF_INCL_LIST)),
                 0)));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (1, mINITIALISExSTORAGE_ASSIGNMENTxRIGID_BLOCK, bitRHS);
        bitRHS->inUse = 0;
      }
      // Q = P; (2248)
      {
        int32_t numberRHS
            = (int32_t)(getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxP));
        putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxQ, numberRHS);
      }
      // DO WHILE PROCPOINT = SHR(SYT_SORT(Q+1),16) & Q < NDECSY; (2249)
      while (1
             & (xAND (
                 xEQ (COREHALFWORD (mPROCPOINT),
                      SHR (getFIXED (
                               getFIXED (mDOSORT)
                               + 4
                                     * (xadd (
                                         getFIXED (
                                             mINITIALISExSTORAGE_ASSIGNMENTxQ),
                                         1))
                               + 0 + 4 * (0)),
                           16)),
                 xLT (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxQ),
                      COREHALFWORD (mNDECSY)))))
        {
          // Q = Q + 1; (2250)
          {
            int32_t numberRHS = (int32_t)(xadd (
                getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxQ), 1));
            putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxQ, numberRHS);
          }
        } // End of DO WHILE block
      // K = Q - P; (2251)
      {
        int32_t numberRHS = (int32_t)(xsubtract (
            getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxQ),
            getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxP)));
        putFIXED (mINITIALISExK, numberRHS);
      }
      // L = SHR(K+1, 1); (2252)
      {
        int32_t numberRHS
            = (int32_t)(SHR (xadd (getFIXED (mINITIALISExK), 1), 1));
        putFIXED (mINITIALISExL, numberRHS);
      }
      // EXCHANGES = CALL#(PROCPOINT) ~= 2 & PROCPOINT = DATAPOINT; (2253)
      {
        int32_t numberRHS = (int32_t)(xAND (
            xNEQ (BYTE0 (mCALLp + 1 * COREHALFWORD (mPROCPOINT)), 2),
            xEQ (COREHALFWORD (mPROCPOINT),
                 COREHALFWORD (mINITIALISExDATAPOINT))));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (1, mINITIALISExSTORAGE_ASSIGNMENTxEXCHANGES, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF ~RIGID_BLOCK THEN (2254)
      if (1 & (xNOT (BYTE0 (mINITIALISExSTORAGE_ASSIGNMENTxRIGID_BLOCK))))
        // DO WHILE L > 0; (2255)
        while (1 & (xGT (getFIXED (mINITIALISExL), 0)))
          {
            // DO J = P TO Q - L; (2256)
            {
              int32_t from35, to35, by35;
              from35 = getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxP);
              to35 = xsubtract (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxQ),
                                getFIXED (mINITIALISExL));
              by35 = 1;
              for (putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ, from35);
                   getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ) <= to35;
                   putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ,
                             getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ)
                                 + by35))
                {
                  // I = J; (2257)
                  {
                    int32_t numberRHS = (int32_t)(getFIXED (
                        mINITIALISExSTORAGE_ASSIGNMENTxJ));
                    putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxI, numberRHS);
                  }
                  // DO WHILE SWAP(I, I+L); (2258)
                  while (
                      1
                      & (bitToFixed ((
                          putBITp (
                              16, mINITIALISExSTORAGE_ASSIGNMENTxSWAPxL,
                              fixedToBit (
                                  32, (int32_t)(getFIXED (
                                          mINITIALISExSTORAGE_ASSIGNMENTxI)))),
                          putBITp (
                              16, mINITIALISExSTORAGE_ASSIGNMENTxSWAPxI,
                              fixedToBit (
                                  32,
                                  (int32_t)(xadd (
                                      getFIXED (
                                          mINITIALISExSTORAGE_ASSIGNMENTxI),
                                      getFIXED (mINITIALISExL))))),
                          INITIALISExSTORAGE_ASSIGNMENTxSWAP (0)))))
                    {
                      // SYT_SORT(I) = N; (2259)
                      {
                        int32_t numberRHS = (int32_t)(getFIXED (
                            mINITIALISExSTORAGE_ASSIGNMENTxN));
                        putFIXED (
                            getFIXED (mDOSORT)
                                + 4
                                      * (getFIXED (
                                          mINITIALISExSTORAGE_ASSIGNMENTxI))
                                + 0 + 4 * (0),
                            numberRHS);
                      }
                      // SYT_SORT(I+L) = M; (2260)
                      {
                        int32_t numberRHS = (int32_t)(getFIXED (
                            mINITIALISExSTORAGE_ASSIGNMENTxM));
                        putFIXED (
                            getFIXED (mDOSORT)
                                + 4
                                      * (xadd (
                                          getFIXED (
                                              mINITIALISExSTORAGE_ASSIGNMENTxI),
                                          getFIXED (mINITIALISExL)))
                                + 0 + 4 * (0),
                            numberRHS);
                      }
                      // I = I - L; (2261)
                      {
                        int32_t numberRHS = (int32_t)(xsubtract (
                            getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxI),
                            getFIXED (mINITIALISExL)));
                        putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxI, numberRHS);
                      }
                      // IF I < P THEN (2262)
                      if (1
                          & (xLT (
                              getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxI),
                              getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxP))))
                        // ESCAPE; (2263)
                        break;
                    } // End of DO WHILE block
                }
            } // End of DO for-loop block
            // L = SHR(L, 1); (2264)
            {
              int32_t numberRHS = (int32_t)(SHR (getFIXED (mINITIALISExL), 1));
              putFIXED (mINITIALISExL, numberRHS);
            }
          } // End of DO WHILE block
      // P = Q + 1; (2265)
      {
        int32_t numberRHS
            = (int32_t)(xadd (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxQ), 1));
        putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxP, numberRHS);
      }
    } // End of DO WHILE block
  // PROCPOINT, X = -1; (2266)
  {
    int32_t numberRHS = (int32_t)(-1);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mPROCPOINT, bitRHS);
    putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxX, numberRHS);
    bitRHS->inUse = 0;
  }
  // DO I = 1 TO NDECSY; (2267)
  {
    int32_t from36, to36, by36;
    from36 = 1;
    to36 = bitToFixed (getBIT (16, mNDECSY));
    by36 = 1;
    for (putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxI, from36);
         getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxI) <= to36;
         putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxI,
                   getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxI) + by36))
      {
        // J = SYT_SORT(I) &  65535; (2268)
        {
          int32_t numberRHS = (int32_t)(xAND (
              getFIXED (getFIXED (mDOSORT)
                        + 4 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxI)) + 0
                        + 4 * (0)),
              65535));
          putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ, numberRHS);
        }
        // IF PROCPOINT ~= SYT_DISP(J) THEN (2269)
        if (1
            & (xNEQ (COREHALFWORD (mPROCPOINT),
                     COREHALFWORD (
                         getFIXED (mP2SYMS)
                         + 12 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ))
                         + 6 + 2 * (0)))))
          // DO; (2270)
          {
          rs3s1:;
            // PROCPOINT = SYT_DISP(J); (2271)
            {
              descriptor_t *bitRHS = getBIT (
                  16, getFIXED (mP2SYMS)
                          + 12 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ))
                          + 6 + 2 * (0));
              putBIT (16, mPROCPOINT, bitRHS);
              bitRHS->inUse = 0;
            }
            // SDF_INCLUDED = (SYT_FLAGS(PROC_LEVEL(PROCPOINT)) &
            // SDF_INCL_FLAG) ~= 0; (2272)
            {
              int32_t numberRHS = (int32_t)(xNEQ (
                  xAND (getFIXED (getFIXED (mSYM_TAB)
                                  + 34
                                        * (COREHALFWORD (
                                            mPROC_LEVEL
                                            + 2 * COREHALFWORD (mPROCPOINT)))
                                  + 8 + 4 * (0)),
                        getFIXED (mSDF_INCL_FLAG)),
                  0));
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (1, mINITIALISExSDF_INCLUDED, bitRHS);
              bitRHS->inUse = 0;
            }
          es3s1:;
          } // End of DO block
        // Y = SYT_DISP(J); (2273)
        {
          descriptor_t *bitRHS = getBIT (
              16, getFIXED (mP2SYMS)
                      + 12 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ)) + 6
                      + 2 * (0));
          int32_t numberRHS;
          numberRHS = bitToFixed (bitRHS);
          putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxY, numberRHS);
          bitRHS->inUse = 0;
        }
        // IF Y = DATAPOINT THEN (2274)
        if (1
            & (xEQ (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxY),
                    COREHALFWORD (mINITIALISExDATAPOINT))))
          // K = DATABASE; (2275)
          {
            descriptor_t *bitRHS = getBIT (16, mDATABASE);
            int32_t numberRHS;
            numberRHS = bitToFixed (bitRHS);
            putFIXED (mINITIALISExK, numberRHS);
            bitRHS->inUse = 0;
          }
        // ELSE (2276)
        else
          // IF Y >= PROGPOINT THEN (2277)
          if (1
              & (xGE (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxY),
                      COREHALFWORD (mPROGPOINT))))
            // DO; (2278)
            {
            rs3s2:;
              // IF LASTBASE(Y) ~= TEMPBASE THEN (2279)
              if (1
                  & (xNEQ (
                      COREHALFWORD (
                          mLASTBASE
                          + 2 * getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxY)),
                      BYTE0 (mTEMPBASE))))
                // K = DATABASE; (2280)
                {
                  descriptor_t *bitRHS = getBIT (16, mDATABASE);
                  int32_t numberRHS;
                  numberRHS = bitToFixed (bitRHS);
                  putFIXED (mINITIALISExK, numberRHS);
                  bitRHS->inUse = 0;
                }
              // ELSE (2281)
              else
                // DO; (2282)
                {
                rs3s2s1:;
                  // K = Y; (2283)
                  {
                    int32_t numberRHS = (int32_t)(getFIXED (
                        mINITIALISExSTORAGE_ASSIGNMENTxY));
                    putFIXED (mINITIALISExK, numberRHS);
                  }
                  // CALL NEED_STACK(K); (2284)
                  {
                    putBITp (
                        16, mNEED_STACKxIX,
                        fixedToBit (32, (int32_t)(getFIXED (mINITIALISExK))));
                    NEED_STACK (0);
                  }
                es3s2s1:;
                } // End of DO block
            es3s2:;
            } // End of DO block
          // ELSE (2285)
          else
            // K = Y; (2286)
            {
              int32_t numberRHS
                  = (int32_t)(getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxY));
              putFIXED (mINITIALISExK, numberRHS);
            }
        // CALL SET_BLOCK_ADDRS; (2287)
        INITIALISExSTORAGE_ASSIGNMENTxSET_BLOCK_ADDRS (0);
        // Y = SYT_DISP(J); (2288)
        {
          descriptor_t *bitRHS = getBIT (
              16, getFIXED (mP2SYMS)
                      + 12 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ)) + 6
                      + 2 * (0));
          int32_t numberRHS;
          numberRHS = bitToFixed (bitRHS);
          putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxY, numberRHS);
          bitRHS->inUse = 0;
        }
        // IF ((SYT_FLAGS(J) & NAME_OR_REMOTE) = REMOTE_FLAG) & ((SYT_FLAGS(J)
        // & INCLUDED_REMOTE) = 0) THEN (2289)
        if (1
            & (xAND (
                xEQ (xAND (
                         getFIXED (getFIXED (mSYM_TAB)
                                   + 34
                                         * (getFIXED (
                                             mINITIALISExSTORAGE_ASSIGNMENTxJ))
                                   + 8 + 4 * (0)),
                         getFIXED (mNAME_OR_REMOTE)),
                     getFIXED (mREMOTE_FLAG)),
                xEQ (xAND (
                         getFIXED (getFIXED (mSYM_TAB)
                                   + 34
                                         * (getFIXED (
                                             mINITIALISExSTORAGE_ASSIGNMENTxJ))
                                   + 8 + 4 * (0)),
                         getFIXED (mINCLUDED_REMOTE)),
                     0))))
          // DO; (2290)
          {
          rs3s3:;
            // K = REMOTE_LEVEL(K); (2291)
            {
              descriptor_t *bitRHS
                  = getBIT (8, mREMOTE_LEVEL + 1 * getFIXED (mINITIALISExK));
              int32_t numberRHS;
              numberRHS = bitToFixed (bitRHS);
              putFIXED (mINITIALISExK, numberRHS);
              bitRHS->inUse = 0;
            }
          // ADDRESS_REMOTE: (2292)
          ADDRESS_REMOTE:
            // IF SDF_INCLUDED THEN (2293)
            if (1 & (bitToFixed (getBIT (1, mINITIALISExSDF_INCLUDED))))
              // L = SYT_ADDR(J); (2294)
              {
                int32_t numberRHS = (int32_t)(getFIXED (
                    getFIXED (mSYM_TAB)
                    + 34 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ)) + 4
                    + 4 * (0)));
                putFIXED (mINITIALISExL, numberRHS);
              }
            // ELSE (2295)
            else
              // L = ADJUST(SYT_BASE(J),MAXTEMP(K)); (2296)
              {
                int32_t numberRHS = (int32_t)((
                    putBITp (
                        16, mADJUSTxBIGHT,
                        getBIT (
                            16,
                            getFIXED (mP2SYMS)
                                + 12
                                      * (getFIXED (
                                          mINITIALISExSTORAGE_ASSIGNMENTxJ))
                                + 4 + 2 * (0))),
                    putFIXED (
                        mADJUSTxADDRESS,
                        getFIXED (mMAXTEMP + 4 * getFIXED (mINITIALISExK))),
                    ADJUST (0)));
                putFIXED (mINITIALISExL, numberRHS);
              }
            // SYT_BASE(J) = REMOTE_BASE + SHL(SINGLE_VALUED(J),3); (2297)
            {
              int32_t numberRHS = (int32_t)(xadd (
                  BYTE0 (mREMOTE_BASE),
                  SHL (
                      bitToFixed ((
                          putBITp (
                              16, mINITIALISExSINGLE_VALUEDxPTR,
                              fixedToBit (
                                  32, (int32_t)(getFIXED (
                                          mINITIALISExSTORAGE_ASSIGNMENTxJ)))),
                          INITIALISExSINGLE_VALUED (0))),
                      3)));
              putBIT (16,
                      getFIXED (mP2SYMS)
                          + 12 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ))
                          + 4 + 2 * (0),
                      fixedToBit (16, numberRHS));
            }
            // SYT_DISP(J) = SYT_LINK2(J); (2298)
            {
              descriptor_t *bitRHS = getBIT (
                  16, getFIXED (mSYM_TAB)
                          + 34 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ))
                          + 26 + 2 * (0));
              putBIT (16,
                      getFIXED (mP2SYMS)
                          + 12 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ))
                          + 6 + 2 * (0),
                      bitRHS);
              bitRHS->inUse = 0;
            }
            // SYT_LINK2(J) = 0; (2299)
            {
              int32_t numberRHS = (int32_t)(0);
              putBIT (16,
                      getFIXED (mSYM_TAB)
                          + 34 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ))
                          + 26 + 2 * (0),
                      fixedToBit (16, numberRHS));
            }
          es3s3:;
          } // End of DO block
        // ELSE (2300)
        else
          // IF ((SYT_FLAGS(PROC_LEVEL(Y)) & REMOTE_FLAG) ~= 0) &
          // (SYT_TYPE(PROC_LEVEL(Y)) = COMPOOL_LABEL) THEN (2301)
          if (1
              & (xAND (
                  xNEQ (
                      xAND (
                          getFIXED (
                              getFIXED (mSYM_TAB)
                              + 34
                                    * (COREHALFWORD (
                                        mPROC_LEVEL
                                        + 2
                                              * getFIXED (
                                                  mINITIALISExSTORAGE_ASSIGNMENTxY)))
                              + 8 + 4 * (0)),
                          getFIXED (mREMOTE_FLAG)),
                      0),
                  xEQ (
                      BYTE0 (
                          getFIXED (mSYM_TAB)
                          + 34
                                * (COREHALFWORD (
                                    mPROC_LEVEL
                                    + 2
                                          * getFIXED (
                                              mINITIALISExSTORAGE_ASSIGNMENTxY)))
                          + 32 + 1 * (0)),
                      BYTE0 (mCOMPOOL_LABEL)))))
            // GO TO ADDRESS_REMOTE; (2302)
            goto ADDRESS_REMOTE;
          // ELSE (2303)
          else
            // DO; (2304)
            {
            rs3s4:;
              // IF SDF_INCLUDED THEN (2305)
              if (1 & (bitToFixed (getBIT (1, mINITIALISExSDF_INCLUDED))))
                // L = SYT_ADDR(J); (2306)
                {
                  int32_t numberRHS = (int32_t)(getFIXED (
                      getFIXED (mSYM_TAB)
                      + 34 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ)) + 4
                      + 4 * (0)));
                  putFIXED (mINITIALISExL, numberRHS);
                }
              // ELSE (2307)
              else
                // L = ADJUST(SYT_BASE(J), MAXTEMP(K)); (2308)
                {
                  int32_t numberRHS = (int32_t)((
                      putBITp (
                          16, mADJUSTxBIGHT,
                          getBIT (
                              16,
                              getFIXED (mP2SYMS)
                                  + 12
                                        * (getFIXED (
                                            mINITIALISExSTORAGE_ASSIGNMENTxJ))
                                  + 4 + 2 * (0))),
                      putFIXED (
                          mADJUSTxADDRESS,
                          getFIXED (mMAXTEMP + 4 * getFIXED (mINITIALISExK))),
                      ADJUST (0)));
                  putFIXED (mINITIALISExL, numberRHS);
                }
              // IF SYMBOL_USED(J) THEN (2309)
              if (1
                  & (bitToFixed (
                      (putBITp (
                           16, mINITIALISExSYMBOL_USEDxPTR,
                           fixedToBit (
                               32, (int32_t)(getFIXED (
                                       mINITIALISExSTORAGE_ASSIGNMENTxJ)))),
                       INITIALISExSYMBOL_USED (0)))))
                // CALL ADDRESSABLE(J, L); (2310)
                {
                  putBITp (
                      16, mINITIALISExADDRESSABLExOP,
                      fixedToBit (32, (int32_t)(getFIXED (
                                          mINITIALISExSTORAGE_ASSIGNMENTxJ))));
                  putFIXED (mINITIALISExADDRESSABLExLOC,
                            getFIXED (mINITIALISExL));
                  INITIALISExADDRESSABLE (0);
                }
              // ELSE (2311)
              else
                // SYT_DISP(J) = -1; (2312)
                {
                  int32_t numberRHS = (int32_t)(-1);
                  putBIT (
                      16,
                      getFIXED (mP2SYMS)
                          + 12 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ))
                          + 6 + 2 * (0),
                      fixedToBit (16, numberRHS));
                }
            es3s4:;
            } // End of DO block
        // IF ASSEMBLER_CODE THEN (2313)
        if (1 & (bitToFixed (getBIT (1, mASSEMBLER_CODE))))
          // OUTPUT=SYT_NAME(J)||X2||LEFTBRACKET||EXTENT(J)||RIGHTBRACKET||X2
          // ||HEX(L,6)||X2||HEX(SYT_DISP(J),3)||LEFTBRACKET||SYT_BASE(J)
          // ||RIGHTBRACKET||X2||SYT_CONST(J); (2314)
          {
            descriptor_t *stringRHS;
            stringRHS = xsCAT (
                xsCAT (
                    xsCAT (
                        xsCAT (
                            xsCAT (
                                xsCAT (
                                    xsCAT (
                                        xsCAT (
                                            xsCAT (
                                                xsCAT (
                                                    xsCAT (
                                                        xsCAT (
                                                            xsCAT (
                                                                getCHARACTER (
                                                                    getFIXED (
                                                                        mSYM_TAB)
                                                                    + 34
                                                                          * (getFIXED (
                                                                              mINITIALISExSTORAGE_ASSIGNMENTxJ))
                                                                    + 0
                                                                    + 4 * (0)),
                                                                getCHARACTER (
                                                                    mX2)),
                                                            getCHARACTER (
                                                                mLEFTBRACKET)),
                                                        fixedToCharacter (getFIXED (
                                                            getFIXED (mSYM_TAB)
                                                            + 34
                                                                  * (getFIXED (
                                                                      mINITIALISExSTORAGE_ASSIGNMENTxJ))
                                                            + 12 + 4 * (0)))),
                                                    getCHARACTER (
                                                        mRIGHTBRACKET)),
                                                getCHARACTER (mX2)),
                                            (putFIXED (
                                                 mHEXxHVAL,
                                                 getFIXED (mINITIALISExL)),
                                             putFIXED (mHEXxN, 6), HEX (0))),
                                        getCHARACTER (mX2)),
                                    (putFIXED (
                                         mHEXxHVAL,
                                         COREHALFWORD (
                                             getFIXED (mP2SYMS)
                                             + 12
                                                   * (getFIXED (
                                                       mINITIALISExSTORAGE_ASSIGNMENTxJ))
                                             + 6 + 2 * (0))),
                                     putFIXED (mHEXxN, 3), HEX (0))),
                                getCHARACTER (mLEFTBRACKET)),
                            bitToCharacter (getBIT (
                                16,
                                getFIXED (mP2SYMS)
                                    + 12
                                          * (getFIXED (
                                              mINITIALISExSTORAGE_ASSIGNMENTxJ))
                                    + 4 + 2 * (0)))),
                        getCHARACTER (mRIGHTBRACKET)),
                    getCHARACTER (mX2)),
                fixedToCharacter (getFIXED (
                    getFIXED (mP2SYMS)
                    + 12 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ)) + 0
                    + 4 * (0))));
            OUTPUT (0, stringRHS);
            stringRHS->inUse = 0;
          }
        // IF (SYT_FLAGS(J) & NAME_FLAG) ~= 0 THEN (2315)
        if (1
            & (xNEQ (
                xAND (getFIXED (
                          getFIXED (mSYM_TAB)
                          + 34 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ))
                          + 8 + 4 * (0)),
                      getFIXED (mNAME_FLAG)),
                0)))
          // MAXTEMP(K) = L + NAMESIZE(J); (2316)
          {
            int32_t numberRHS = (int32_t)(xadd (
                getFIXED (mINITIALISExL),
                bitToFixed (
                    (putBITp (16, mNAMESIZExOP,
                              fixedToBit (
                                  32, (int32_t)(getFIXED (
                                          mINITIALISExSTORAGE_ASSIGNMENTxJ)))),
                     NAMESIZE (0)))));
            putFIXED (mMAXTEMP + 4 * (getFIXED (mINITIALISExK)), numberRHS);
          }
        // ELSE (2317)
        else
          // MAXTEMP(K) = L + EXTENT(J); (2318)
          {
            int32_t numberRHS = (int32_t)(xadd (
                getFIXED (mINITIALISExL),
                getFIXED (getFIXED (mSYM_TAB)
                          + 34 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ))
                          + 12 + 4 * (0))));
            putFIXED (mMAXTEMP + 4 * (getFIXED (mINITIALISExK)), numberRHS);
          }
        // WORKSEG(K) = MAXTEMP(K); (2319)
        {
          int32_t numberRHS
              = (int32_t)(getFIXED (mMAXTEMP + 4 * getFIXED (mINITIALISExK)));
          putFIXED (mWORKSEG + 4 * (getFIXED (mINITIALISExK)), numberRHS);
        }
        // SYT_ADDR(J) = L; (2320)
        {
          int32_t numberRHS = (int32_t)(getFIXED (mINITIALISExL));
          putFIXED (getFIXED (mSYM_TAB)
                        + 34 * (getFIXED (mINITIALISExSTORAGE_ASSIGNMENTxJ))
                        + 4 + 4 * (0),
                    numberRHS);
        }
      }
  } // End of DO for-loop block
  // Y = PROCLIMIT; (2321)
  {
    descriptor_t *bitRHS = getBIT (16, mPROCLIMIT);
    int32_t numberRHS;
    numberRHS = bitToFixed (bitRHS);
    putFIXED (mINITIALISExSTORAGE_ASSIGNMENTxY, numberRHS);
    bitRHS->inUse = 0;
  }
  // CALL SET_BLOCK_ADDRS; (2322)
  INITIALISExSTORAGE_ASSIGNMENTxSET_BLOCK_ADDRS (0);
  // PROGDATA = MAXTEMP(DATABASE); (2323)
  {
    int32_t numberRHS
        = (int32_t)(getFIXED (mMAXTEMP + 4 * COREHALFWORD (mDATABASE)));
    putFIXED (mPROGDATA, numberRHS);
  }
  // PROGDATA(1) = MAXTEMP(REMOTE_LEVEL); (2324)
  {
    int32_t numberRHS
        = (int32_t)(getFIXED (mMAXTEMP + 4 * BYTE0 (mREMOTE_LEVEL)));
    putFIXED (mPROGDATA + 4 * (1), numberRHS);
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
