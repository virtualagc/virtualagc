/*
  File GET_SUBSET.c generated by XCOM-I, 2024-08-08 04:31:11.
*/

#include "runtimeC.h"

int32_t
GET_SUBSET (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GET_SUBSET");
  // IF MONITOR(2,6,SUBSET) THEN (9421)
  if (1 & (MONITOR2 (6, getCHARACTER (mGET_SUBSETxSUBSET))))
    // RETURN 1; (9422)
    {
      reentryGuard = 0;
      return 1;
    }
  // S=INPUT(6); (9423)
  {
    descriptor_t *stringRHS;
    stringRHS = INPUT (6);
    putCHARACTER (mGET_SUBSETxS, stringRHS);
    stringRHS->inUse = 0;
  }
  // IF LENGTH(S)=0 THEN (9424)
  if (1 & (xEQ (LENGTH (getCHARACTER (mGET_SUBSETxS)), 0)))
    // RETURN 1; (9425)
    {
      reentryGuard = 0;
      return 1;
    }
  // LIMIT=LENGTH(S)-1; (9426)
  {
    int32_t numberRHS
        = (int32_t)(xsubtract (LENGTH (getCHARACTER (mGET_SUBSETxS)), 1));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGET_SUBSETxLIMIT, bitRHS);
    bitRHS->inUse = 0;
  }
  // OUTPUT(1)=SUBSET_MSG||S; (9427)
  {
    descriptor_t *stringRHS;
    stringRHS = xsCAT (getCHARACTER (mGET_SUBSETxSUBSET_MSG),
                       getCHARACTER (mGET_SUBSETxS));
    OUTPUT (1, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT=X1; (9428)
  {
    descriptor_t *stringRHS;
    stringRHS = getCHARACTER (mX1);
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // CP=LIMIT; (9429)
  {
    descriptor_t *bitRHS = getBIT (16, mGET_SUBSETxLIMIT);
    putBIT (16, mGET_SUBSETxCP, bitRHS);
    bitRHS->inUse = 0;
  }
  // I=1; (9430)
  {
    int32_t numberRHS = (int32_t)(1);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGET_SUBSETxI, bitRHS);
    bitRHS->inUse = 0;
  }
  // DO WHILE I~=0; (9431)
  while (1 & (xNEQ (COREHALFWORD (mGET_SUBSETxI), 0)))
    {
      // DO CASE GET_TOKEN; (9432)
      {
      rs1s1:
        switch (GET_SUBSETxGET_TOKEN (0))
          {
          case 0:
            // IF LENGTH(A_TOKEN)>0 THEN (9434)
            if (1 & (xGT (LENGTH (getCHARACTER (mGET_SUBSETxA_TOKEN)), 0)))
              {
                putBITp (16, mGET_SUBSETxSUBSET_ERRORxNUM,
                         fixedToBit (32, (int32_t)(0)));
                GET_SUBSETxSUBSET_ERROR (0);
              }
            break;
          case 1:
            // DO; (9436)
            {
            rs1s1s1:;
              // IF A_TOKEN='$BUILTINS' THEN (9436)
              if (1
                  & (xsEQ (getCHARACTER (mGET_SUBSETxA_TOKEN),
                           cToDescriptor (NULL, "$BUILTINS"))))
                // DO WHILE I; (9437)
                while (1 & (bitToFixed (getBIT (16, mGET_SUBSETxI))))
                  {
                    // DO CASE GET_TOKEN; (9438)
                    {
                    rs1s1s1s1s1:
                      switch (GET_SUBSETxGET_TOKEN (0))
                        {
                        case 0:
                          // CALL SUBSET_ERROR(0); (9440)
                          {
                            putBITp (16, mGET_SUBSETxSUBSET_ERRORxNUM,
                                     fixedToBit (32, (int32_t)(0)));
                            GET_SUBSETxSUBSET_ERROR (0);
                          }
                          break;
                        case 1:
                          // CALL SUBSET_ERROR(1); (9441)
                          {
                            putBITp (16, mGET_SUBSETxSUBSET_ERRORxNUM,
                                     fixedToBit (32, (int32_t)(1)));
                            GET_SUBSETxSUBSET_ERROR (0);
                          }
                          break;
                        case 2:
                        // CASE_B2: (9442)
                        CASE_B2:
                          {
                          rs1s1s1s1s1s1:;
                            // L=BI#; (9443)
                            {
                              int32_t numberRHS = (int32_t)(63);
                              descriptor_t *bitRHS;
                              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                              putBIT (16, mGET_SUBSETxL, bitRHS);
                              bitRHS->inUse = 0;
                            }
                            // DO WHILE L>0; (9444)
                            while (1 & (xGT (COREHALFWORD (mGET_SUBSETxL), 0)))
                              {
                                // IF SUBSTR(BI_NAME(BI_INDX(L)),BI_LOC(L),10)
                                // = PAD(A_TOKEN,10)  THEN (9445)
                                if (1
                                    & (xsEQ (
                                        SUBSTR (
                                            getCHARACTER (
                                                mBI_NAME
                                                + 4
                                                      * BYTE0 (
                                                          mBI_INDX
                                                          + 1
                                                                * COREHALFWORD (
                                                                    mGET_SUBSETxL))),
                                            BYTE0 (mBI_LOC
                                                   + 1
                                                         * COREHALFWORD (
                                                             mGET_SUBSETxL)),
                                            10),
                                        (putCHARACTERp (
                                             mPADxSTRING,
                                             getCHARACTER (
                                                 mGET_SUBSETxA_TOKEN)),
                                         putFIXED (mPADxWIDTH, 10), PAD (0)))))
                                  // DO; (9446)
                                  {
                                  rs1s1s1s1s1s1s1s1:;
                                    // BI_FLAGS(L)=BI_FLAGS(L)|FLAGS; (9447)
                                    {
                                      int32_t numberRHS = (int32_t)(xOR (
                                          BYTE0 (mBI_FLAGS
                                                 + 1
                                                       * COREHALFWORD (
                                                           mGET_SUBSETxL)),
                                          BYTE0 (mGET_SUBSETxFLAGS)));
                                      descriptor_t *bitRHS;
                                      bitRHS = fixedToBit (
                                          32, (int32_t)(numberRHS));
                                      putBIT (8,
                                              mBI_FLAGS
                                                  + 1
                                                        * (COREHALFWORD (
                                                            mGET_SUBSETxL)),
                                              bitRHS);
                                      bitRHS->inUse = 0;
                                    }
                                    // L=-1; (9448)
                                    {
                                      int32_t numberRHS = (int32_t)(-1);
                                      descriptor_t *bitRHS;
                                      bitRHS = fixedToBit (
                                          32, (int32_t)(numberRHS));
                                      putBIT (16, mGET_SUBSETxL, bitRHS);
                                      bitRHS->inUse = 0;
                                    }
                                  es1s1s1s1s1s1s1s1:;
                                  } // End of DO block
                                // ELSE (9449)
                                else
                                  // L=L-1; (9450)
                                  {
                                    int32_t numberRHS = (int32_t)(xsubtract (
                                        COREHALFWORD (mGET_SUBSETxL), 1));
                                    descriptor_t *bitRHS;
                                    bitRHS = fixedToBit (32,
                                                         (int32_t)(numberRHS));
                                    putBIT (16, mGET_SUBSETxL, bitRHS);
                                    bitRHS->inUse = 0;
                                  }
                              } // End of DO WHILE block
                            // IF L=0 THEN (9451)
                            if (1 & (xEQ (COREHALFWORD (mGET_SUBSETxL), 0)))
                              // CALL SUBSET_ERROR(2); (9452)
                              {
                                putBITp (16, mGET_SUBSETxSUBSET_ERRORxNUM,
                                         fixedToBit (32, (int32_t)(2)));
                                GET_SUBSETxSUBSET_ERROR (0);
                              }
                          es1s1s1s1s1s1:;
                          } // End of DO block
                          break;
                        case 3:
                          // GO TO CASE_B2; (9454)
                          goto CASE_B2;
                          break;
                        }
                    } // End of DO CASE block
                  }   // End of DO WHILE block
              // ELSE (9454)
              else
                // IF A_TOKEN='$PRODUCTIONS' THEN (9455)
                if (1
                    & (xsEQ (getCHARACTER (mGET_SUBSETxA_TOKEN),
                             cToDescriptor (NULL, "$PRODUCTIONS"))))
                  // DO WHILE I; (9456)
                  while (1 & (bitToFixed (getBIT (16, mGET_SUBSETxI))))
                    {
                      // DO CASE GET_TOKEN; (9457)
                      {
                      rs1s1s1s2s1:
                        switch (GET_SUBSETxGET_TOKEN (0))
                          {
                          case 0:
                            // CALL SUBSET_ERROR(0); (9459)
                            {
                              putBITp (16, mGET_SUBSETxSUBSET_ERRORxNUM,
                                       fixedToBit (32, (int32_t)(0)));
                              GET_SUBSETxSUBSET_ERROR (0);
                            }
                            break;
                          case 1:
                            // CALL SUBSET_ERROR(1); (9460)
                            {
                              putBITp (16, mGET_SUBSETxSUBSET_ERRORxNUM,
                                       fixedToBit (32, (int32_t)(1)));
                              GET_SUBSETxSUBSET_ERROR (0);
                            }
                            break;
                          case 2:
                          // CASE_P2: (9461)
                          CASE_P2:
                            {
                            rs1s1s1s2s1s1:;
                              // L=VALUE; (9462)
                              {
                                int32_t numberRHS
                                    = (int32_t)(GET_SUBSETxVALUE (0));
                                descriptor_t *bitRHS;
                                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                                putBIT (16, mGET_SUBSETxL, bitRHS);
                                bitRHS->inUse = 0;
                              }
                              // IF (L>0)&(L<=P#) THEN (9463)
                              if (1
                                  & (xAND (
                                      xGT (COREHALFWORD (mGET_SUBSETxL), 0),
                                      xLE (COREHALFWORD (mGET_SUBSETxL),
                                           453))))
                                // #PRODUCE_NAME(L)=
                                // #PRODUCE_NAME(L)|SHL(FLAGS,12); (9464)
                                {
                                  int32_t numberRHS = (int32_t)(xOR (
                                      COREHALFWORD (
                                          mpPRODUCE_NAME
                                          + 2 * COREHALFWORD (mGET_SUBSETxL)),
                                      SHL (BYTE0 (mGET_SUBSETxFLAGS), 12)));
                                  descriptor_t *bitRHS;
                                  bitRHS
                                      = fixedToBit (32, (int32_t)(numberRHS));
                                  putBIT (
                                      16,
                                      mpPRODUCE_NAME
                                          + 2 * (COREHALFWORD (mGET_SUBSETxL)),
                                      bitRHS);
                                  bitRHS->inUse = 0;
                                }
                              // ELSE (9465)
                              else
                                // CALL SUBSET_ERROR(3); (9466)
                                {
                                  putBITp (16, mGET_SUBSETxSUBSET_ERRORxNUM,
                                           fixedToBit (32, (int32_t)(3)));
                                  GET_SUBSETxSUBSET_ERROR (0);
                                }
                            es1s1s1s2s1s1:;
                            } // End of DO block
                            break;
                          case 3:
                            // GO TO CASE_P2; (9468)
                            goto CASE_P2;
                            break;
                          }
                      } // End of DO CASE block
                    }   // End of DO WHILE block
                // ELSE (9468)
                else
                  // IF A_TOKEN = '$BITLENGTH' THEN (9469)
                  if (1
                      & (xsEQ (getCHARACTER (mGET_SUBSETxA_TOKEN),
                               cToDescriptor (NULL, "$BITLENGTH"))))
                    // DO WHILE I; (9470)
                    while (1 & (bitToFixed (getBIT (16, mGET_SUBSETxI))))
                      {
                        // DO CASE GET_TOKEN; (9471)
                        {
                        rs1s1s1s3s1:
                          switch (GET_SUBSETxGET_TOKEN (0))
                            {
                            case 0:
                              // CALL SUBSET_ERROR(0); (9473)
                              {
                                putBITp (16, mGET_SUBSETxSUBSET_ERRORxNUM,
                                         fixedToBit (32, (int32_t)(0)));
                                GET_SUBSETxSUBSET_ERROR (0);
                              }
                              break;
                            case 1:
                              // CALL SUBSET_ERROR(1); (9474)
                              {
                                putBITp (16, mGET_SUBSETxSUBSET_ERRORxNUM,
                                         fixedToBit (32, (int32_t)(1)));
                                GET_SUBSETxSUBSET_ERROR (0);
                              }
                              break;
                            case 2:
                              // DO; (9475)
                              {
                              rs1s1s1s3s1s1:;
                                // L = VALUE; (9475)
                                {
                                  int32_t numberRHS
                                      = (int32_t)(GET_SUBSETxVALUE (0));
                                  descriptor_t *bitRHS;
                                  bitRHS
                                      = fixedToBit (32, (int32_t)(numberRHS));
                                  putBIT (16, mGET_SUBSETxL, bitRHS);
                                  bitRHS->inUse = 0;
                                }
                                // IF L < 1 | L > BIT_LENGTH_LIM THEN (9476)
                                if (1
                                    & (xOR (
                                        xLT (COREHALFWORD (mGET_SUBSETxL), 1),
                                        xGT (COREHALFWORD (mGET_SUBSETxL),
                                             COREHALFWORD (mBIT_LENGTH_LIM)))))
                                  // CALL SUBSET_ERROR(4); (9477)
                                  {
                                    putBITp (16, mGET_SUBSETxSUBSET_ERRORxNUM,
                                             fixedToBit (32, (int32_t)(4)));
                                    GET_SUBSETxSUBSET_ERROR (0);
                                  }
                                // ELSE (9478)
                                else
                                  // BIT_LENGTH_LIM = L; (9479)
                                  {
                                    descriptor_t *bitRHS
                                        = getBIT (16, mGET_SUBSETxL);
                                    putBIT (16, mBIT_LENGTH_LIM, bitRHS);
                                    bitRHS->inUse = 0;
                                  }
                              es1s1s1s3s1s1:;
                              } // End of DO block
                              break;
                            case 3:
                              // CALL SUBSET_ERROR(1); (9481)
                              {
                                putBITp (16, mGET_SUBSETxSUBSET_ERRORxNUM,
                                         fixedToBit (32, (int32_t)(1)));
                                GET_SUBSETxSUBSET_ERROR (0);
                              }
                              break;
                            }
                        } // End of DO CASE block
                      }   // End of DO WHILE block
                  // ELSE (9481)
                  else
                    // CALL SUBSET_ERROR(1); (9482)
                    {
                      putBITp (16, mGET_SUBSETxSUBSET_ERRORxNUM,
                               fixedToBit (32, (int32_t)(1)));
                      GET_SUBSETxSUBSET_ERROR (0);
                    }
            es1s1s1:;
            } // End of DO block
            break;
          case 2:
            // CALL SUBSET_ERROR(1); (9484)
            {
              putBITp (16, mGET_SUBSETxSUBSET_ERRORxNUM,
                       fixedToBit (32, (int32_t)(1)));
              GET_SUBSETxSUBSET_ERROR (0);
            }
            break;
          case 3:
            // CALL SUBSET_ERROR(1); (9485)
            {
              putBITp (16, mGET_SUBSETxSUBSET_ERRORxNUM,
                       fixedToBit (32, (int32_t)(1)));
              GET_SUBSETxSUBSET_ERROR (0);
            }
            break;
          }
      } // End of DO CASE block
    }   // End of DO WHILE block
  // OUTPUT=X1; (9485)
  {
    descriptor_t *stringRHS;
    stringRHS = getCHARACTER (mX1);
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // RETURN 0; (9486)
  {
    reentryGuard = 0;
    return 0;
  }
}
