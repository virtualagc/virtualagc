 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   STRUCTUR.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  STRUCTURE_COMPARE                                      */
 /* MEMBER NAME:     STRUCTUR                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          A                 BIT(16)                                      */
 /*          B                 BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          AX                BIT(16)                                      */
 /*          BX                BIT(16)                                      */
 /*          I                 BIT(16)                                      */
 /*          STRUC_ERR         LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          EVIL_FLAGS                                                     */
 /*          EXT_ARRAY                                                      */
 /*          FALSE                                                          */
 /*          FOREVER                                                        */
 /*          SM_FLAGS                                                       */
 /*          SYM_ARRAY                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_LENGTH                                                     */
 /*          SYM_LINK1                                                      */
 /*          SYM_LINK2                                                      */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_ARRAY                                                      */
 /*          SYT_DIMS                                                       */
 /*          SYT_FLAGS                                                      */
 /*          SYT_LINK1                                                      */
 /*          SYT_LINK2                                                      */
 /*          SYT_TYPE                                                       */
 /*          TRUE                                                           */
 /* CALLED BY:                                                              */
 /*          TEMPLATE_LIT                                                   */
 /***************************************************************************/
                                                                                00576010
 /* ROUTINE TO MATCH STRUCTURE TEMPLATES FOR LEGALITY  */                       00576020
STRUCTURE_COMPARE:                                                              00576030
   PROCEDURE(A, B);                                                             00576040
      DECLARE (A, B, AX, BX, I) BIT(16);                                        00576050
      IF A = B THEN RETURN TRUE;                                                00576060
      IF ((SYT_FLAGS(A) | SYT_FLAGS(B)) & EVIL_FLAGS) = EVIL_FLAGS THEN         00576070
         GO TO STRUC_ERR;                                                       00576080
      AX = A;                                                                   00576090
      BX = B;                                                                   00576100
      DO FOREVER;                                                               00576110
         DO WHILE SYT_LINK1(AX) > 0;                                            00576120
            AX = SYT_LINK1(AX);                                                 00576130
            BX = SYT_LINK1(BX);                                                 00576140
            IF BX = 0 THEN GO TO STRUC_ERR;                                     00576150
         END;                                                                   00576160
         IF SYT_LINK1(BX) ^= 0 THEN GO TO STRUC_ERR;                            00576170
         IF SYT_TYPE(AX) ^= SYT_TYPE(BX) THEN GO TO STRUC_ERR;                  00576180
         IF SYT_DIMS(AX) ^= SYT_DIMS(BX) THEN GO TO STRUC_ERR;                  00576190
         IF (SYT_FLAGS(AX)&SM_FLAGS) ^= (SYT_FLAGS(BX)&SM_FLAGS) THEN           00576200
            GO TO STRUC_ERR;                                                    00576210
         DO I = 0 TO EXT_ARRAY(SYT_ARRAY(AX));                                  00576220
            IF EXT_ARRAY(SYT_ARRAY(AX)+I) ^= EXT_ARRAY(SYT_ARRAY(BX)+I) THEN    00576230
               GO TO STRUC_ERR;                                                 00576240
         END;                                                                   00576250
         DO WHILE SYT_LINK2(AX) < 0;                                            00576260
            AX = -SYT_LINK2(AX);                                                00576270
            BX = -SYT_LINK2(BX);                                                00576280
            IF AX = A THEN DO;                                                  00576290
               IF BX ^= B THEN GO TO STRUC_ERR;                                 00576300
               RETURN TRUE;                                                     00576310
            END;                                                                00576320
            IF BX <= 0 THEN GO TO STRUC_ERR;                                    00576330
         END;                                                                   00576340
         AX = SYT_LINK2(AX);                                                    00576350
         BX = SYT_LINK2(BX);                                                    00576360
         IF BX <= 0 THEN GO TO STRUC_ERR;                                       00576370
      END;                                                                      00576380
STRUC_ERR:                                                                      00576390
      RETURN FALSE;                                                             00576400
   END STRUCTURE_COMPARE;                                                       00576410
