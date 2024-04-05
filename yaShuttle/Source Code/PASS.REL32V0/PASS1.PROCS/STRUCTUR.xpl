 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   STRUCTUR.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
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
 /*          ERR_CLASS         BIT(16)                                      */
 /*          ERR_NUM           BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          AX                BIT(16)                                      */
 /*          BX                BIT(16)                                      */
 /*          I                 BIT(16)                                      */
 /*          STRUC_ERR(1601)   LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          EVIL_FLAG                                                      */
 /*          EXT_ARRAY                                                      */
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
 /*          SYT_FLAGS                                                      */
 /*          SYT_LINK1                                                      */
 /*          SYT_LINK2                                                      */
 /*          SYT_TYPE                                                       */
 /*          VAR_LENGTH                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          SETUP_CALL_ARG                                                 */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> STRUCTURE_COMPARE <==                                               */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
                                                                                00837400
STRUCTURE_COMPARE:                                                              00837500
   PROCEDURE (A,B,ERR_CLASS,ERR_NUM);                                           00837600
      DECLARE (A,B,ERR_CLASS,ERR_NUM) BIT(16);                                  00837700
      DECLARE (AX,BX,I) BIT(16);                                                00837800
      IF ((SYT_FLAGS(A)|SYT_FLAGS(B))&EVIL_FLAG)^=0 THEN RETURN;                00837900
      IF A=B THEN RETURN;                                                       00838000
      AX=A;                                                                     00838100
      BX=B;                                                                     00838200
      DO FOREVER;                                                               00838300
         DO WHILE SYT_LINK1(AX)>0;                                              00838400
            AX=SYT_LINK1(AX);                                                   00838500
            BX=SYT_LINK1(BX);                                                   00838600
            IF BX=0 THEN GO TO STRUC_ERR;                                       00838700
         END;                                                                   00838800
         IF SYT_LINK1(BX)^=0 THEN GO TO STRUC_ERR;                              00838900
         IF SYT_TYPE(AX)^=SYT_TYPE(BX) THEN GO TO STRUC_ERR;                    00839000
         IF VAR_LENGTH(AX)^=VAR_LENGTH(BX) THEN GO TO STRUC_ERR;                00839100
         IF (SYT_FLAGS(AX)&SM_FLAGS)^=(SYT_FLAGS(BX)&SM_FLAGS) THEN             00839200
            GO TO STRUC_ERR;                                                    00839300
         DO I=0 TO EXT_ARRAY(SYT_ARRAY(AX));                                    00839400
            IF EXT_ARRAY(SYT_ARRAY(AX)+I)^=EXT_ARRAY(SYT_ARRAY(BX)+I) THEN      00839500
               GO TO STRUC_ERR;                                                 00839600
         END;                                                                   00839700
         DO WHILE SYT_LINK2(AX)<0;                                              00839800
            AX=-SYT_LINK2(AX);                                                  00839900
            BX=-SYT_LINK2(BX);                                                  00840000
            IF AX=A THEN DO;                                                    00840100
               IF BX^=B THEN GO TO STRUC_ERR;                                   00840200
               RETURN;                                                          00840300
            END;                                                                00840400
            IF BX<=0 THEN GO TO STRUC_ERR;                                      00840500
         END;                                                                   00840600
         AX=SYT_LINK2(AX);                                                      00840700
         BX=SYT_LINK2(BX);                                                      00840800
         IF BX<=0 THEN GO TO STRUC_ERR;                                         00840900
      END;                                                                      00841000
STRUC_ERR:                                                                      00841100
      CALL ERROR(ERR_CLASS,ERR_NUM);                                            00841200
   END STRUCTURE_COMPARE;                                                       00841300
