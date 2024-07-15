 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PATCHINC.xpl
    Purpose:    Part of the HAL/S-FC compiler.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section TBD.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
                2024-07-14 RSB	Enclosed call to INCLUDE_SDF in /?W ... ?/.
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/***************************************************************************/
/*                                                                         */
/* REVISION HISTORY:                                                       */
/*                                                                         */
/* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
/*                                                                         */
/* 01/21/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
/*                                                                         */
/* 12/02/97 JAC  29V0  DR109074 DOWNGRADE OF DI21 ERROR FAILS WHEN         */
/*               14V0           INCLUDING A REMOTELY INCLUDED COMPOOL      */
/***************************************************************************/
   /* ROUTINE CALLED TO HANDLE PROCESSING OF INCLUDE DIRECTIVE.     */          00001710
   /* RETURNS TRUE IF TEMPLATE IS TO BE PROCESSED, FALSE OTHERWISE. */          00001720
                                                                                00001730
INCLUDE_OK:                                                                     00001740
   PROCEDURE BIT(1);                                                            00001750
      DECLARE INCL_FLAGS BIT(8);                                                00001760
      DECLARE (LIST_FLAG, SDF_FLAG) BIT(1);                                     00001770
      IF INCLUDING THEN                                                         00001780
         DO;                                                                    00001790
            CALL ERROR(CLASS_XI,1);                                             00001800
            RETURN FALSE;                                                       00001810
         END;                                                                   00001820
      INCL_FLAGS = 0;                                                           00001830
      C = D_TOKEN;                                                              00001840
      TEMPLATE_FLAG, SDF_FLAG = FALSE;                                          00001850
      IF C = 'TEMPLATE' THEN DO;                                                00001860
         SDF_FLAG, TEMPLATE_FLAG = TRUE;                                        00001870
         INCL_FLAGS = INCL_FLAGS | INCL_TEMPLATE_FLAG;                          00001880
         MEMBER = D_TOKEN;                                                      00001890
      END;                                                                      00001900
      ELSE IF C = 'SDF' THEN DO;                                                00001910
         SDF_FLAG = TRUE;                                                       00001920
         MEMBER = D_TOKEN;                                                      00001930
      END;                                                                      00001940
      ELSE MEMBER = C;                                                          00001950
      IF LENGTH(MEMBER) = 0 THEN                                                00001960
         DO;                                                                    00001970
            CALL ERROR(CLASS_XI,2);                                             00001980
            RETURN FALSE;                                                       00001990
         END;                                                                   00002000
      C = D_TOKEN;                                                              00002010
      LIST_FLAG = TRUE;                                                         00002020
      DO FOREVER;                                                               00002030
         IF C = 'NOLIST' THEN LIST_FLAG = FALSE;                                00002040
         ELSE IF (C = 'NOSDF') & TEMPLATE_FLAG THEN SDF_FLAG = FALSE;           00002050
         ELSE IF C = 'REMOTE' THEN DO;                                          00002060
            INCL_FLAGS = INCL_FLAGS | INCL_REMOTE_FLAG;                         00002070
            IF TEMPLATE_FLAG THEN TPL_REMOTE = TRUE;                            00002080
            ELSE IF ^SDF_FLAG THEN CALL ERROR(CLASS_XI, 4);                     00002090
         END;                                                                   00002100
         ELSE ESCAPE;                                                           00002110
         C = D_TOKEN;                                                           00002120
      END;                                                                      00002130
      IF (TEMPLATE_FLAG | SDF_FLAG) & CREATING THEN DO; /*DR109074*/            00002140
         CALL ERROR(CLASS_XI, 12);                                              00002160
         RETURN FALSE;                                                          00002170
      END;                                                                      00002180
      IF SDF_FLAG THEN DO;
         /?W
         IF INCLUDE_SDF(MEMBER, INCL_FLAGS) THEN RETURN FALSE;                  00002190
         ?/
         IF ^TEMPLATE_FLAG THEN RETURN FALSE;                                   00002200
      END;                                                                      00002210
      IF TEMPLATE_FLAG THEN MEMBER = DESCORE(MEMBER);                           00002220
      ELSE IF LENGTH(MEMBER) < 8 THEN MEMBER = PAD(MEMBER, 8);                  00002230
      ELSE MEMBER = SUBSTR(MEMBER, 0, 8);                                       00002240
      IF FINDER(4, MEMBER, 0) THEN /* FIND THE MEMBER */                        00002270
         DO;                                                                    00002280
            CALL ERROR(CLASS_XI,3,MEMBER);                                      00002290
            RETURN FALSE;                                                       00002300
         END;                                                                   00002310
      IF TEMPLATE_FLAG THEN DO;                         /*DR109074*/            00002320
         COMPARE_SOURCE=FALSE;
         /* SAVE CURRENT STMT NUMBER FOR 'INCLUDE TEMPLATE NOSDF' */
         INCLUDE_STMT = STMT_NUM;                       /*DR109074*/
      END;                                              /*DR109074*/
      INCL_FLAGS = INCL_FLAGS | SHL("1",SHR(INCLUDE_FILE#,1));                  00002330
      REV_CAT = MONITOR(15);                                                    00002340
      INCLUDE_MSG = ' OF INCLUDED MEMBER, RVL '                                 00002350
         || STRING("01000000" | ADDR(REV_CAT)) ||                               00002360
         ', CATENATION NUMBER ' || (REV_CAT & "FFFF");                          00002370
      INCLUDE_LIST, INCLUDE_LIST2 = LIST_FLAG;                                  00002380
      INCLUDE_OFFSET = CARD_COUNT + 1;                                          00002390
      IF SIMULATING THEN CALL MAKE_INCL_CELL(MEMBER, INCL_FLAGS, REV_CAT);      00002400
      INCLUDING = TRUE;                                                         00002410
      INPUT_DEV = 4;                                                            00002420
      INCLUDE_OPENED = TRUE;                                                    00002430
      CURRENT_CARD = INPUT(INPUT_DEV);                                          00002440
      LRECL(1) = LENGTH(CURRENT_CARD) - 1;                                      00002450
      IF BYTE(CURRENT_CARD) = "00" THEN                                         00002460
         DO;  /* COMPRESSED SOURCE */                                           00002470
            INCLUDE_COMPRESSED = TRUE;                                          00002480
            INPUT_REC(1) = CURRENT_CARD;                                        00002490
         END;                                                                   00002500
      ELSE INITIAL_INCLUDE_RECORD = TRUE;                                       00002510
      RETURN TRUE;                                                              00002520
   END INCLUDE_OK;                                                              00002530
