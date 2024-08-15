/*
  File _RETURN_UNUSED.c generated by XCOM-I, 2024-08-09 12:38:15.
*/

#include "runtimeC.h"

int32_t
_RETURN_UNUSED (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "_RETURN_UNUSED");
  // DIF=_DOPE_ALLOC(DOPE)-_DOPE_USED(DOPE); (302)
  {
    int32_t numberRHS = (int32_t)(xsubtract (
        COREWORD (xadd (getFIXED (m_RETURN_UNUSEDxDOPE), 8)),
        COREWORD (xadd (getFIXED (m_RETURN_UNUSEDxDOPE), 12))));
    putFIXED (m_RETURN_UNUSEDxDIF, numberRHS);
  }
  // IF NRECS=0 THEN (303)
  if (1 & (xEQ (getFIXED (m_RETURN_UNUSEDxNRECS), 0)))
    // DO; (304)
    {
    rs1:;
      // NRECS=DIF; (305)
      {
        int32_t numberRHS = (int32_t)(getFIXED (m_RETURN_UNUSEDxDIF));
        putFIXED (m_RETURN_UNUSEDxNRECS, numberRHS);
      }
      // _NUM_TIMES_ZEROED(DOPE)=0; (306)
      {
        int32_t numberRHS = (int32_t)(0);
        COREHALFWORD2 (xadd (getFIXED (m_RETURN_UNUSEDxDOPE), 24), numberRHS);
      }
      // IF NRECS=0 THEN (307)
      if (1 & (xEQ (getFIXED (m_RETURN_UNUSEDxNRECS), 0)))
        // RETURN; (308)
        {
          reentryGuard = 0;
          return 0;
        }
    es1:;
    } // End of DO block
  // ELSE (309)
  else
    // IF NRECS=DIF THEN (310)
    if (1
        & (xEQ (getFIXED (m_RETURN_UNUSEDxNRECS),
                getFIXED (m_RETURN_UNUSEDxDIF))))
      // DO; (311)
      {
      rs2:;
        // _NUM_TIMES_ZEROED(DOPE)=_NUM_TIMES_ZEROED(DOPE)+1; (312)
        {
          int32_t numberRHS = (int32_t)(xadd (
              COREHALFWORD (xadd (getFIXED (m_RETURN_UNUSEDxDOPE), 24)), 1));
          COREHALFWORD2 (xadd (getFIXED (m_RETURN_UNUSEDxDOPE), 24),
                         numberRHS);
        }
        // IF _NUM_TIMES_ZEROED(DOPE)>_MAX_ZEROED THEN (313)
        if (1
            & (xGT (COREHALFWORD (xadd (getFIXED (m_RETURN_UNUSEDxDOPE), 24)),
                    2)))
          // DO; (314)
          {
          rs2s1:;
            // OUTPUT='BI010 SEVERITY 3  SPACE MANAGEMENT ' || 'YOYOING -- TRY
            // LARGER REGION.'; (315)
            {
              descriptor_t *stringRHS;
              stringRHS
                  = cToDescriptor (NULL, "BI010 SEVERITY 3  SPACE MANAGEMENT "
                                         "YOYOING -- TRY LARGER REGION.");
              OUTPUT (0, stringRHS);
              stringRHS->inUse = 0;
            }
            // CALL EXIT; (316)
            EXIT ();
          es2s1:;
          } // End of DO block
      es2:;
      } // End of DO block
    // ELSE (317)
    else
      // IF NRECS > DIF THEN (318)
      if (1
          & (xGT (getFIXED (m_RETURN_UNUSEDxNRECS),
                  getFIXED (m_RETURN_UNUSEDxDIF))))
        // DO; (319)
        {
        rs3:;
          // DO; (320)
          {
          rs3s1:;
            // CALL _SPMANERR('TRIED TO RETURN '||NRECS||' BUT ONLY
            // '||DIF||'ARE UNUSED IN '||DOPE); (321)
            {
              putCHARACTERp (
                  m_SPMANERRxMSG,
                  xsCAT (
                      xsCAT (
                          xsCAT (xsCAT (xsCAT (cToDescriptor (
                                                   NULL, "TRIED TO RETURN "),
                                               fixedToCharacter (getFIXED (
                                                   m_RETURN_UNUSEDxNRECS))),
                                        cToDescriptor (NULL, " BUT ONLY ")),
                                 fixedToCharacter (
                                     getFIXED (m_RETURN_UNUSEDxDIF))),
                          cToDescriptor (NULL, "ARE UNUSED IN ")),
                      fixedToCharacter (getFIXED (m_RETURN_UNUSEDxDOPE))));
              _SPMANERR (0);
            }
          es3s1:;
          } // End of DO block
          // NRECS=DIF; (322)
          {
            int32_t numberRHS = (int32_t)(getFIXED (m_RETURN_UNUSEDxDIF));
            putFIXED (m_RETURN_UNUSEDxNRECS, numberRHS);
          }
        es3:;
        } // End of DO block
  // IF DIF=_DOPE_ALLOC(DOPE) THEN (323)
  if (1
      & (xEQ (getFIXED (m_RETURN_UNUSEDxDIF),
              COREWORD (xadd (getFIXED (m_RETURN_UNUSEDxDOPE), 8)))))
    // CALL _RECORD_FREE(DOPE _IFA(NAME)); (324)
    {
      putFIXED (m_RECORD_FREExDOPE, getFIXED (m_RETURN_UNUSEDxDOPE));
      _RECORD_FREE (0);
    }
  // ELSE (325)
  else
    // DO; (326)
    {
    rs4:;
      // TOTAL_RDESC=TOTAL_RDESC-NRECS*_DOPE_#DESCRIPTORS(DOPE); (327)
      {
        int32_t numberRHS = (int32_t)(xsubtract (
            getFIXED (mTOTAL_RDESC),
            xmultiply (
                getFIXED (m_RETURN_UNUSEDxNRECS),
                COREHALFWORD (xadd (getFIXED (m_RETURN_UNUSEDxDOPE), 6)))));
        putFIXED (mTOTAL_RDESC, numberRHS);
      }
      // OLDNBYTES=_RECORD#BYTES(DOPE); (328)
      {
        int32_t numberRHS = (int32_t)((
            putFIXED (
                m_SPACE_ROUNDxBYTES,
                xmultiply (
                    COREWORD (xadd (getFIXED (m_RETURN_UNUSEDxDOPE), 8)),
                    COREHALFWORD (xadd (getFIXED (m_RETURN_UNUSEDxDOPE), 4)))),
            _SPACE_ROUND (0)));
        putFIXED (m_RETURN_UNUSEDxOLDNBYTES, numberRHS);
      }
      // _DOPE_ALLOC(DOPE)=_DOPE_ALLOC(DOPE)-NRECS; (329)
      {
        int32_t numberRHS = (int32_t)(xsubtract (
            COREWORD (xadd (getFIXED (m_RETURN_UNUSEDxDOPE), 8)),
            getFIXED (m_RETURN_UNUSEDxNRECS)));
        COREWORD2 (xadd (getFIXED (m_RETURN_UNUSEDxDOPE), 8), numberRHS);
      }
      // NEWNBYTES=_RECORD#BYTES(DOPE); (330)
      {
        int32_t numberRHS = (int32_t)((
            putFIXED (
                m_SPACE_ROUNDxBYTES,
                xmultiply (
                    COREWORD (xadd (getFIXED (m_RETURN_UNUSEDxDOPE), 8)),
                    COREHALFWORD (xadd (getFIXED (m_RETURN_UNUSEDxDOPE), 4)))),
            _SPACE_ROUND (0)));
        putFIXED (m_RETURN_UNUSEDxNEWNBYTES, numberRHS);
      }
      // DIF=OLDNBYTES-NEWNBYTES; (331)
      {
        int32_t numberRHS
            = (int32_t)(xsubtract (getFIXED (m_RETURN_UNUSEDxOLDNBYTES),
                                   getFIXED (m_RETURN_UNUSEDxNEWNBYTES)));
        putFIXED (m_RETURN_UNUSEDxDIF, numberRHS);
      }
      // IF DIF=0 THEN (332)
      if (1 & (xEQ (getFIXED (m_RETURN_UNUSEDxDIF), 0)))
        // RETURN; (333)
        {
          reentryGuard = 0;
          return 0;
        }
      // NEWBLOCK=_DOPE_POINTER(DOPE)+OLDNBYTES-4; (334)
      {
        int32_t numberRHS = (int32_t)(xsubtract (
            xadd (COREWORD (getFIXED (m_RETURN_UNUSEDxDOPE)),
                  getFIXED (m_RETURN_UNUSEDxOLDNBYTES)),
            4));
        putFIXED (m_RETURN_UNUSEDxNEWBLOCK, numberRHS);
      }
      // _FREEBLOCK_NEXT(NEWBLOCK)=0; (335)
      {
        int32_t numberRHS = (int32_t)(0);
        COREWORD2 (getFIXED (m_RETURN_UNUSEDxNEWBLOCK), numberRHS);
      }
      // _FREEBLOCK_SIZE(NEWBLOCK)=DIF; (336)
      {
        int32_t numberRHS = (int32_t)(getFIXED (m_RETURN_UNUSEDxDIF));
        COREWORD2 (xsubtract (getFIXED (m_RETURN_UNUSEDxNEWBLOCK), 4),
                   numberRHS);
      }
      // FREEBYTES=FREEBYTES+DIF; (337)
      {
        int32_t numberRHS = (int32_t)(xadd (getFIXED (mFREEBYTES),
                                            getFIXED (m_RETURN_UNUSEDxDIF)));
        putFIXED (mFREEBYTES, numberRHS);
      }
      // RECBYTES=RECBYTES-DIF; (338)
      {
        int32_t numberRHS = (int32_t)(xsubtract (
            getFIXED (mRECBYTES), getFIXED (m_RETURN_UNUSEDxDIF)));
        putFIXED (mRECBYTES, numberRHS);
      }
      // CALL _ATTACH_BLOCK(NEWBLOCK); (339)
      {
        putFIXED (m_ATTACH_BLOCKxBLOCK, getFIXED (m_RETURN_UNUSEDxNEWBLOCK));
        _ATTACH_BLOCK (0);
      }
    es4:;
    } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}