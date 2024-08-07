/*
  File _SQUASH_RECORDS.c generated by XCOM-I, 2024-08-08 04:31:35.
*/

#include "runtimeC.h"

int32_t
_SQUASH_RECORDS (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "_SQUASH_RECORDS");
  // SQUASHED=0; (140)
  {
    int32_t numberRHS = (int32_t)(0);
    putFIXED (m_SQUASH_RECORDSxSQUASHED, numberRHS);
  }
  // BYTES_TO_MOVE_BY=0; (141)
  {
    int32_t numberRHS = (int32_t)(0);
    putFIXED (m_SQUASH_RECORDSxBYTES_TO_MOVE_BY, numberRHS);
  }
  // CURBLOCK=FIRSTBLOCK; (142)
  {
    int32_t numberRHS = (int32_t)(getFIXED (mFIRSTBLOCK));
    putFIXED (m_SQUASH_RECORDSxCURBLOCK, numberRHS);
  }
  // CURDOPE=FIRSTRECORD; (143)
  {
    int32_t numberRHS = (int32_t)(getFIXED (mFIRSTRECORD));
    putFIXED (m_SQUASH_RECORDSxCURDOPE, numberRHS);
  }
  // DO WHILE CURDOPE > 0; (144)
  while (1 & (xGT (getFIXED (m_SQUASH_RECORDSxCURDOPE), 0)))
    {
      // IF ~_IS_REC_UNMOVEABLE(CURDOPE) THEN (145)
      if (1
          & (xNOT (xNEQ (
              xAND (COREWORD (xadd (getFIXED (m_SQUASH_RECORDSxCURDOPE), 20)),
                    33554432),
              0))))
        // ESCAPE; (146)
        break;
      // CURDOPE=_DOPE_NEXT(CURDOPE); (147)
      {
        int32_t numberRHS = (int32_t)(COREWORD (
            xadd (getFIXED (m_SQUASH_RECORDSxCURDOPE), 16)));
        putFIXED (m_SQUASH_RECORDSxCURDOPE, numberRHS);
      }
    } // End of DO WHILE block
  // IF CURDOPE <= 0 THEN (148)
  if (1 & (xLE (getFIXED (m_SQUASH_RECORDSxCURDOPE), 0)))
    // RETURN; (149)
    {
      reentryGuard = 0;
      return 0;
    }
  // RECPTR=_DOPE_POINTER(CURDOPE); (150)
  {
    int32_t numberRHS
        = (int32_t)(COREWORD (getFIXED (m_SQUASH_RECORDSxCURDOPE)));
    putFIXED (m_SQUASH_RECORDSxRECPTR, numberRHS);
  }
// BLOCKLOOP: (151)
BLOCKLOOP:
  // DO WHILE CURBLOCK > 0; (152)
  while (1 & (xGT (getFIXED (m_SQUASH_RECORDSxCURBLOCK), 0)))
    {
      // BYTES_TO_MOVE_BY=BYTES_TO_MOVE_BY+_FREEBLOCK_SIZE(CURBLOCK); (153)
      {
        int32_t numberRHS = (int32_t)(xadd (
            getFIXED (m_SQUASH_RECORDSxBYTES_TO_MOVE_BY),
            COREWORD (xsubtract (getFIXED (m_SQUASH_RECORDSxCURBLOCK), 4))));
        putFIXED (m_SQUASH_RECORDSxBYTES_TO_MOVE_BY, numberRHS);
      }
      // NEXTBLOCK=_FREEBLOCK_NEXT(CURBLOCK); (154)
      {
        int32_t numberRHS
            = (int32_t)(COREWORD (getFIXED (m_SQUASH_RECORDSxCURBLOCK)));
        putFIXED (m_SQUASH_RECORDSxNEXTBLOCK, numberRHS);
      }
      // DO WHILE RECPTR>CURBLOCK; (155)
      while (1
             & (xGT (getFIXED (m_SQUASH_RECORDSxRECPTR),
                     getFIXED (m_SQUASH_RECORDSxCURBLOCK))))
        {
          // CURDOPE=_DOPE_NEXT(CURDOPE); (156)
          {
            int32_t numberRHS = (int32_t)(COREWORD (
                xadd (getFIXED (m_SQUASH_RECORDSxCURDOPE), 16)));
            putFIXED (m_SQUASH_RECORDSxCURDOPE, numberRHS);
          }
          // IF CURDOPE=0 THEN (157)
          if (1 & (xEQ (getFIXED (m_SQUASH_RECORDSxCURDOPE), 0)))
            // ESCAPE BLOCKLOOP; (158)
            goto es2;
          // RECPTR=_DOPE_POINTER(CURDOPE); (159)
          {
            int32_t numberRHS
                = (int32_t)(COREWORD (getFIXED (m_SQUASH_RECORDSxCURDOPE)));
            putFIXED (m_SQUASH_RECORDSxRECPTR, numberRHS);
          }
          // IF _IS_REC_UNMOVEABLE(CURDOPE) THEN (160)
          if (1
              & (xNEQ (xAND (COREWORD (xadd (
                                 getFIXED (m_SQUASH_RECORDSxCURDOPE), 20)),
                             33554432),
                       0)))
            // DO; (161)
            {
            rs2s1s1:;
              // CALL _SPMANERR('IN _SQUASH_RECORDS, UNMOVEABLE AFTER
              // MOVEABLES, DOPE='||CURDOPE); (162)
              {
                putCHARACTERp (
                    m_SPMANERRxMSG,
                    xsCAT (
                        cToDescriptor (NULL, "IN _SQUASH_RECORDS, UNMOVEABLE "
                                             "AFTER MOVEABLES, DOPE="),
                        fixedToCharacter (
                            getFIXED (m_SQUASH_RECORDSxCURDOPE))));
                _SPMANERR (0);
              }
            es2s1s1:;
            } // End of DO block
        }     // End of DO WHILE block
      // DO UNTIL RECPTR<NEXTBLOCK; (163)
      do
        {
          // RECBYTES=_RECORD#BYTES(CURDOPE); (164)
          {
            int32_t numberRHS = (int32_t)((
                putFIXED (
                    m_SPACE_ROUNDxBYTES,
                    xmultiply (COREWORD (xadd (
                                   getFIXED (m_SQUASH_RECORDSxCURDOPE), 8)),
                               COREHALFWORD (xadd (
                                   getFIXED (m_SQUASH_RECORDSxCURDOPE), 4)))),
                _SPACE_ROUND (0)));
            putFIXED (m_SQUASH_RECORDSxRECBYTES, numberRHS);
          }
          // CALL
          // _MOVE_WORDS(RECPTR+RECBYTES-4,RECPTR+RECBYTES-4+BYTES_TO_MOVE_BY,
          // RECBYTES); (165)
          {
            putFIXED (m_MOVE_WORDSxSOURCE,
                      xsubtract (xadd (getFIXED (m_SQUASH_RECORDSxRECPTR),
                                       getFIXED (m_SQUASH_RECORDSxRECBYTES)),
                                 4));
            putFIXED (
                m_MOVE_WORDSxDEST,
                xadd (xsubtract (xadd (getFIXED (m_SQUASH_RECORDSxRECPTR),
                                       getFIXED (m_SQUASH_RECORDSxRECBYTES)),
                                 4),
                      getFIXED (m_SQUASH_RECORDSxBYTES_TO_MOVE_BY)));
            putFIXED (m_MOVE_WORDSxNUMBYTES,
                      getFIXED (m_SQUASH_RECORDSxRECBYTES));
            _MOVE_WORDS (0);
          }
          // SQUASHED=SQUASHED+RECBYTES; (166)
          {
            int32_t numberRHS
                = (int32_t)(xadd (getFIXED (m_SQUASH_RECORDSxSQUASHED),
                                  getFIXED (m_SQUASH_RECORDSxRECBYTES)));
            putFIXED (m_SQUASH_RECORDSxSQUASHED, numberRHS);
          }
          // _DOPE_POINTER(CURDOPE)=_DOPE_POINTER(CURDOPE)+BYTES_TO_MOVE_BY;
          // (167)
          {
            int32_t numberRHS = (int32_t)(xadd (
                COREWORD (getFIXED (m_SQUASH_RECORDSxCURDOPE)),
                getFIXED (m_SQUASH_RECORDSxBYTES_TO_MOVE_BY)));
            COREWORD2 (getFIXED (m_SQUASH_RECORDSxCURDOPE), numberRHS);
          }
          // CURDOPE=_DOPE_NEXT(CURDOPE); (168)
          {
            int32_t numberRHS = (int32_t)(COREWORD (
                xadd (getFIXED (m_SQUASH_RECORDSxCURDOPE), 16)));
            putFIXED (m_SQUASH_RECORDSxCURDOPE, numberRHS);
          }
          // IF CURDOPE <= 0 THEN (169)
          if (1 & (xLE (getFIXED (m_SQUASH_RECORDSxCURDOPE), 0)))
            // ESCAPE BLOCKLOOP; (170)
            goto es2;
          // LAST_RECPTR=RECPTR; (171)
          {
            int32_t numberRHS = (int32_t)(getFIXED (m_SQUASH_RECORDSxRECPTR));
            putFIXED (m_SQUASH_RECORDSxLAST_RECPTR, numberRHS);
          }
          // RECPTR=_DOPE_POINTER(CURDOPE); (172)
          {
            int32_t numberRHS
                = (int32_t)(COREWORD (getFIXED (m_SQUASH_RECORDSxCURDOPE)));
            putFIXED (m_SQUASH_RECORDSxRECPTR, numberRHS);
          }
        }
      while (!(
          1
          & (xLT (getFIXED (m_SQUASH_RECORDSxRECPTR),
                  getFIXED (
                      m_SQUASH_RECORDSxNEXTBLOCK))))); // End of DO UNTIL block
      // CURBLOCK=NEXTBLOCK; (173)
      {
        int32_t numberRHS = (int32_t)(getFIXED (m_SQUASH_RECORDSxNEXTBLOCK));
        putFIXED (m_SQUASH_RECORDSxCURBLOCK, numberRHS);
      }
      if (0)
        {
        rs2:
          continue;
        es2:
          break;
        } // block labeled BLOCKLOOP
    }     // End of DO WHILE block
  // IF BYTES_TO_MOVE_BY > 0 THEN (174)
  if (1 & (xGT (getFIXED (m_SQUASH_RECORDSxBYTES_TO_MOVE_BY), 0)))
    // DO; (175)
    {
    rs3:;
      // FIRSTBLOCK=FREELIMIT+FREEBYTES-4+512; (176)
      {
        int32_t numberRHS = (int32_t)(xadd (
            xsubtract (xadd (FREELIMIT (), getFIXED (mFREEBYTES)), 4), 512));
        putFIXED (mFIRSTBLOCK, numberRHS);
      }
      // _FREEBLOCK_SIZE(FIRSTBLOCK)=FREEBYTES; (177)
      {
        int32_t numberRHS = (int32_t)(getFIXED (mFREEBYTES));
        COREWORD2 (xsubtract (getFIXED (mFIRSTBLOCK), 4), numberRHS);
      }
      // _FREEBLOCK_NEXT(FIRSTBLOCK)=0; (178)
      {
        int32_t numberRHS = (int32_t)(0);
        COREWORD2 (getFIXED (mFIRSTBLOCK), numberRHS);
      }
    es3:;
    } // End of DO block
  // IF SQUASHED > 0 THEN (179)
  if (1 & (xGT (getFIXED (m_SQUASH_RECORDSxSQUASHED), 0)))
    // CALL _FREEBLOCK_CHECK; (180)
    _FREEBLOCK_CHECK (0);
  {
    reentryGuard = 0;
    return 0;
  }
}
