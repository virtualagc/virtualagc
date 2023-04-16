 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DECOMPRE.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  DECOMPRESS                                             */
 /* MEMBER NAME:     DECOMPRE                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          DEV               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CNTL_BYTE         BIT(8)                                       */
 /*          CURRENT_RECORD    CHARACTER;                                   */
 /*          I                 BIT(16)                                      */
 /*          IN_REC_PTR(1)     BIT(16)                                      */
 /*          INPUT_PTR         BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          OUT_REC_PTR       BIT(16)                                      */
 /*          RECRD             CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          INPUT_DEV                                                      */
 /*          LRECL                                                          */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          INPUT_REC                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          BLANK                                                          */
 /* CALLED BY:                                                              */
 /*          NEXT_RECORD                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> DECOMPRESS <==                                                      */
 /*     ==> BLANK                                                           */
 /***************************************************************************/
                                                                                00427000
                                                                                00427100
DECOMPRESS:                                                                     00427200
   PROCEDURE(DEV) CHARACTER;                                                    00427300
      DECLARE DEV BIT(16);                                                      00427400
      DECLARE IN_REC_PTR(1) BIT(16) INITIAL(2, 2);                              00427500
      DECLARE RECRD CHARACTER INITIAL('                                         00427600
                                                                                00427700
            ');  /* 132 BLANKS = MAXIMUM ALLOWED LRECL */                       00427800
      DECLARE OUT_REC_PTR BIT(16);                                              00427900
      DECLARE (I, J, K) BIT(16);                                                00428000
      DECLARE CNTL_BYTE BIT(8);                                                 00428100
      DECLARE CURRENT_RECORD CHARACTER;                                         00428200
      DECLARE INPUT_PTR BIT(16);                                                00428300
      OUT_REC_PTR = 0;  /* BUILDING NEW RECORD */                               00428400
      INPUT_PTR = IN_REC_PTR(DEV);  /* PICK UP CURRENT POINTER */               00428500
      CURRENT_RECORD = INPUT_REC(DEV);  /* PICK UP CURRENT COMPRESSED RECORD */ 00428600
      CALL BLANK(RECRD, 0, 132);  /* BLANK OUT THE NEW RECRD */                 00428700
      DO WHILE OUT_REC_PTR <= LRECL(DEV);  /* STAY UNTIL A RECORD IS DONE */    00428800
         IF INPUT_PTR > LRECL(DEV) THEN DO;                                     00428900
            CURRENT_RECORD = INPUT(INPUT_DEV);                                  00429000
            INPUT_REC(DEV) = CURRENT_RECORD;                                    00429100
            INPUT_PTR = 2;                                                      00429200
         END;                                                                   00429300
         CNTL_BYTE = BYTE(CURRENT_RECORD, INPUT_PTR);  /* THE CONTROL BYTE */   00429400
         IF SHR(CNTL_BYTE, 7) THEN DO;  /* EOF OR BLANKS */                     00429500
            IF CNTL_BYTE = "FF" THEN DO;  /* EOF */                             00429600
               IN_REC_PTR(DEV) = 2;  /* SET UP FOR NEXT TIME */                 00429700
               RETURN '';  /* PASS ON EOF CONDITION */                          00429800
            END;                                                                00429900
            ELSE DO;  /* BLANKS */                                              00430000
               OUT_REC_PTR = OUT_REC_PTR + (CNTL_BYTE & "7F") + 1;              00430100
               INPUT_PTR = INPUT_PTR + 1;                                       00430200
            END;                                                                00430300
         END;                                                                   00430400
         ELSE DO;  /* DUPLICATE OR NON-DUPLICATE STRINGS OF NON-BLANKS */       00430500
            IF SHR(CNTL_BYTE, 6) THEN DO;  /* NON-DUPLICATE */                  00430600
               I = INPUT_PTR + 1;  /* FIRST CHAR */                             00430700
               J = I + (CNTL_BYTE & "3F");  /* HOW MANY */                      00430800
               DO WHILE I <= J;  /* UNTIL ALL ARE ACCOUNTED FOR */              00430900
                  IF I > LRECL(DEV) THEN DO;  /* WRAP AROUND */                 00431000
                     CURRENT_RECORD = INPUT(INPUT_DEV); /* READ ANOTHER */      00431100
                     INPUT_REC(DEV) = CURRENT_RECORD;                           00431200
                     I = 2;  /* SKIP 2 BYTE COUNT FIELD */                      00431300
                     J = J - LRECL(DEV) + 1;  /* ADJUST TO FINISH LOOP */       00431400
                  END;                                                          00431500
                  K = BYTE(CURRENT_RECORD, I);  /* PICK UP CHAR */              00431600
                  BYTE(RECRD, OUT_REC_PTR) = K;  /* PUT INTO CREATED RECRD */   00431700
                  OUT_REC_PTR = OUT_REC_PTR + 1;                                00431800
                  I = I + 1;                                                    00431900
               END;                                                             00432000
               INPUT_PTR = I;  /* CATCH UP */                                   00432100
            END;                                                                00432200
            ELSE DO;  /* DUPLICATE CHARACTERS */                                00432300
               INPUT_PTR = INPUT_PTR + 1;  /* POINT AT REPEATED CHARACTER */    00432400
               IF INPUT_PTR > LRECL(DEV) THEN DO;  /* ON NEXT RECORD */         00432500
                  CURRENT_RECORD = INPUT(INPUT_DEV);                            00432600
                  INPUT_REC(DEV) = CURRENT_RECORD;                              00432700
                  INPUT_PTR = 2;  /* SKIP 2 BYTES COUNT FIELD */                00432800
               END;                                                             00432900
               J = BYTE(CURRENT_RECORD, INPUT_PTR);                             00433000
               DO OUT_REC_PTR = OUT_REC_PTR TO OUT_REC_PTR + (CNTL_BYTE & "3F") 00433100
                     + 1;                                                       00433200
                  BYTE(RECRD, OUT_REC_PTR) = J;                                 00433300
               END;                                                             00433400
               INPUT_PTR = INPUT_PTR + 1;                                       00433500
            END;                                                                00433600
         END;                                                                   00433700
      END;                                                                      00433800
      IN_REC_PTR(DEV) = INPUT_PTR;  /* SAVE FINAL RESTING PLACE */              00433900
 /* MAKE RESULT HAVE A UNIQUE DESCRIPTOR */                                     00434000
      RETURN SUBSTR(X1 || RECRD, 1, LRECL(DEV) + 1);                            00434100
   END DECOMPRESS;                                                              00434200
