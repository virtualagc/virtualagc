 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ERRORSUB.xpl
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
 /* PROCEDURE NAME:  ERROR_SUB                                              */
 /* MEMBER NAME:     ERRORSUB                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          MODE              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          BAD_ERROR_SUB     LABEL                                        */
 /*          ERROR_SS_FIX(1597)  LABEL                                      */
 /*          RUN_ERR_MAX(2)    BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK_SYTREF                                                   */
 /*          CLASS_RE                                                       */
 /*          EXT_ARRAY_PTR                                                  */
 /*          INX                                                            */
 /*          MP                                                             */
 /*          NEST                                                           */
 /*          PSEUDO_LENGTH                                                  */
 /*          PTR                                                            */
 /*          SYM_ARRAY                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_ARRAY                                                      */
 /*          VAL_P                                                          */
 /*          XIMD                                                           */
 /*          XLIT                                                           */
 /*          XSET                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          EXT_ARRAY                                                      */
 /*          FIXV                                                           */
 /*          LOC_P                                                          */
 /*          ON_ERROR_PTR                                                   */
 /*          PSEUDO_FORM                                                    */
 /*          STMT_TYPE                                                      */
 /*          TEMP                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          MAKE_FIXED_LIT                                                 */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ERROR_SUB <==                                                       */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> MAKE_FIXED_LIT                                                  */
 /*         ==> GET_LITERAL                                                 */
 /***************************************************************************/
                                                                                00827100
ERROR_SUB:                                                                      00827200
   PROCEDURE (MODE);                                                            00827300
      DECLARE MODE BIT(16), BAD_ERROR_SUB LABEL;                                00827400
      DECLARE RUN_ERR_MAX(2) BIT(16) INITIAL(0,127,63);                         00827500
                                                                                00827600
ERROR_SS_FIX:                                                                   00827700
      PROCEDURE (LOC) BIT(16);                                                  00827800
         DECLARE LOC FIXED;                                                     00827900
         RUN_ERR_MAX=RUN_ERR_MAX(LOC);                                          00828000
         LOC=LOC+TEMP;                                                          00828100
         IF VAL_P(LOC)^=0 THEN GO TO BAD_ERROR_SUB;                             00828200
         IF INX(LOC)^=1 THEN GO TO BAD_ERROR_SUB;                               00828300
         IF PSEUDO_FORM(LOC)=XIMD THEN LOC=LOC_P(LOC);                          00828400
         ELSE IF PSEUDO_FORM(LOC)=XLIT THEN LOC=MAKE_FIXED_LIT(LOC_P(LOC));     00828500
         ELSE GO TO BAD_ERROR_SUB;                                              00828600
         IF (LOC<0)|(LOC>RUN_ERR_MAX) THEN GO TO BAD_ERROR_SUB;                 00828700
         RETURN LOC;                                                            00828800
      END ERROR_SS_FIX;                                                         00828900
                                                                                00829000
      TEMP=PTR(MP+2);                                                           00829100
      FIXV(MP)="3FFF";                                                          00829200
      LOC_P(TEMP)="FF";                                                         00829300
      IF PSEUDO_FORM(TEMP)^=0 THEN DO;                                          00829400
BAD_ERROR_SUB:                                                                  00829500
         CALL ERROR(CLASS_RE,MODE);                                             00829600
         RETURN;                                                                00829700
      END;                                                                      00829800
      PSEUDO_FORM(TEMP)=XIMD;                                                   00829900
      IF MODE=2 THEN DO;   /*  SEND ERROR  */                                   00830000
         IF INX(TEMP)^=2 THEN GO TO BAD_ERROR_SUB;                              00830100
         IF PSEUDO_LENGTH(TEMP)^=0 THEN GO TO BAD_ERROR_SUB;                    00830200
         IF VAL_P(TEMP)^=1 THEN GO TO BAD_ERROR_SUB;                            00830300
         XSET"E";                                                               00830400
         LOC_P(TEMP)=ERROR_SS_FIX(1);                                           00830500
         FIXV(MP)=ERROR_SS_FIX(2)|SHL(LOC_P(TEMP),6);                           00830600
      END;                                                                      00830700
      ELSE DO;  /*  ON OR OFF ERROR */                                          00830800
         XSET"F";                                                               00830900
         IF INX(TEMP)>2 THEN GO TO BAD_ERROR_SUB;                               00831000
         DO CASE INX(TEMP);                                                     00831100
            ;                                                                   00831200
            DO;                                                                 00831300
               IF PSEUDO_LENGTH(TEMP)>0 THEN GO TO BAD_ERROR_SUB;               00831400
               IF ^VAL_P(TEMP) THEN GO TO BAD_ERROR_SUB;                        00831500
               LOC_P(TEMP)=ERROR_SS_FIX(1);                                     00831600
               FIXV(MP)=SHL(LOC_P(TEMP),6)|"3F";                                00831700
            END;                                                                00831800
            DO;                                                                 00831900
               IF PSEUDO_LENGTH(TEMP)^=0 THEN GO TO BAD_ERROR_SUB;              00832000
               IF VAL_P(TEMP)^=1 THEN GO TO BAD_ERROR_SUB;                      00832100
               LOC_P(TEMP)=ERROR_SS_FIX(1);                                     00832200
               FIXV(MP)=ERROR_SS_FIX(2)|SHL(LOC_P(TEMP),6);                     00832300
            END;                                                                00832400
         END;                                                                   00832500
         MODE=-SYT_ARRAY(BLOCK_SYTREF(NEST));                                   00832600
         DO WHILE MODE>ON_ERROR_PTR;                                            00832700
            MODE=MODE-1;                                                        00832800
            IF FIXV(MP)=EXT_ARRAY(MODE) THEN MODE=0;                            00832900
         END;                                                                   00833000
         IF MODE>0 THEN DO;                                                     00833100
            IF ON_ERROR_PTR=EXT_ARRAY_PTR THEN CALL ERROR(CLASS_RE,3);          00833200
            ELSE DO;                                                            00833300
               ON_ERROR_PTR=ON_ERROR_PTR-1;                                     00833400
               EXT_ARRAY(ON_ERROR_PTR)=FIXV(MP);                                00833500
            END;                                                                00833600
         END;                                                                   00833700
      END;                                                                      00833800
   END ERROR_SUB;                                                               00833900
