 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKSUB.xpl
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
 /* PROCEDURE NAME:  CHECK_SUBSCRIPT                                        */
 /* MEMBER NAME:     CHECKSUB                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          MODE              BIT(16)                                      */
 /*          SIZE              BIT(16)                                      */
 /*          FLAG              BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          NEWSIZE           FIXED                                        */
 /*          SHARP_ELIM        LABEL                                        */
 /*          SHARP_GONE        LABEL                                        */
 /*          SHARP_LOC         BIT(16)                                      */
 /*          SHARP_PM          LABEL                                        */
 /*          SHARP_UNKNOWN     LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          INT_TYPE                                                       */
 /*          CLASS_SR                                                       */
 /*          LAST_POP#                                                      */
 /*          MAT_TYPE                                                       */
 /*          MP                                                             */
 /*          NEXT_SUB                                                       */
 /*          SCALAR_TYPE                                                    */
 /*          VAL_P                                                          */
 /*          VAR                                                            */
 /*          XASZ                                                           */
 /*          XCSZ                                                           */
 /*          XIMD                                                           */
 /*          XLIT                                                           */
 /*          XMADD                                                          */
 /*          XMSUB                                                          */
 /*          XSTOI                                                          */
 /*          XVAC                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LOC_P                                                          */
 /*          PSEUDO_FORM                                                    */
 /*          PSEUDO_TYPE                                                    */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          HALMAT_PIP                                                     */
 /*          HALMAT_POP                                                     */
 /*          MAKE_FIXED_LIT                                                 */
 /* CALLED BY:                                                              */
 /*          REDUCE_SUBSCRIPT                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CHECK_SUBSCRIPT <==                                                 */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> MAKE_FIXED_LIT                                                  */
 /*         ==> GET_LITERAL                                                 */
 /*     ==> HALMAT_POP                                                      */
 /*         ==> HALMAT                                                      */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HALMAT_BLAB                                             */
 /*                 ==> HEX                                                 */
 /*                 ==> I_FORMAT                                            */
 /*             ==> HALMAT_OUT                                              */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*     ==> HALMAT_PIP                                                      */
 /*         ==> HALMAT                                                      */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HALMAT_BLAB                                             */
 /*                 ==> HEX                                                 */
 /*                 ==> I_FORMAT                                            */
 /*             ==> HALMAT_OUT                                              */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /***************************************************************************/
 /*********************************************************************/
 /*                                                                   */
 /* REVISION HISTORY:                                                 */
 /*                                                                   */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                          */
 /*                                                                   */
 /* 05/14/01 TKN  31V0/ 111376   NO SR3 ERROR GENERATED FOR CHARACTER */
 /*               16V0           SHAPING FUNCTION                     */
 /*********************************************************************/
                                                                                00922600
CHECK_SUBSCRIPT:                                                                00922700
   PROCEDURE (MODE,SIZE,FLAG);                                                  00922800
      DECLARE FLAG BIT(1);                                                      00922900
      DECLARE (MODE,SIZE) BIT(16);                                              00923000
      DECLARE NEWSIZE FIXED, SHARP_LOC BIT(16);                                 00923100
      IF PSEUDO_FORM(NEXT_SUB)=XIMD THEN NEWSIZE=LOC_P(NEXT_SUB);               00923200
      ELSE IF PSEUDO_FORM(NEXT_SUB)=XLIT THEN DO;                               00923300
         NEWSIZE=MAKE_FIXED_LIT(LOC_P(NEXT_SUB));                               00923400
      /* IF A CHARACTER SUBSCRIPT (FLAG=1) IS LITERALLY A -1, CHANGE */
      /* IT TO A -2 TO DISTINGUISH IT FROM A CHECK_SUBSCRIPT RETURN  */
      /* VALUE OF -1 WHICH INDICATES AN UNKNOWN SUBSCRIPT            */
      /* (E.G. A VARIABLE).                                          */
         IF NEWSIZE=-1 & FLAG THEN NEWSIZE=-2;   /*DR111376*/
         PSEUDO_FORM(NEXT_SUB)=XIMD;                                            00923500
         PSEUDO_TYPE(NEXT_SUB)=INT_TYPE;                                        00923600
         LOC_P(NEXT_SUB)=NEWSIZE;                                               00923700
      END;                                                                      00923800
      ELSE NEWSIZE=-1;                                                          00923900
      IF VAL_P(NEXT_SUB)>0 THEN DO;                                             00924000
         IF MODE="0"& PSEUDO_TYPE(PTR(MP))=CHAR_TYPE /*DR111376*/
         THEN DO;                /*DR111376*/
            MODE=XCSZ;           /*DR111376*/                                   00924200
            SHARP_LOC=0;         /*DR111376*/                                   00924400
         END;                    /*DR111376*/                                   00924500
         ELSE IF SIZE<0 THEN DO; /*DR111376*/
            MODE=XASZ;
            SHARP_LOC=0;
         END;
         ELSE DO;                                                               00924600
            MODE=XIMD;                                                          00924700
            IF SIZE=0 THEN DO;                                                  00924800
               CALL ERROR(CLASS_SR,5,VAR(MP));                                  00924900
               RETURN -1;                                                       00925000
            END;                                                                00925100
            SHARP_LOC,NEWSIZE=SIZE;                                             00925200
         END;                                                                   00925300
      END;                                                                      00925400
      DO CASE VAL_P(NEXT_SUB);                                                  00925500
 /*  NO SHARP  */                                                               00925600
         DO;                                                                    00925700
SHARP_GONE:                                                                     00925800
            IF PSEUDO_FORM(NEXT_SUB)=XIMD THEN DO;                              00925900
               PSEUDO_TYPE(NEXT_SUB)=0;                                         00926000
               IF FLAG THEN RETURN NEWSIZE;                                     00926100
               IF NEWSIZE<1 THEN DO;                                            00926200
                  CALL ERROR(CLASS_SR,4,VAR(MP));                               00926300
                  RETURN 1;                                                     00926400
               END;                                                             00926500
               ELSE IF SIZE>0 & NEWSIZE>SIZE THEN DO;                           00926600
                  CALL ERROR(CLASS_SR,3,VAR(MP));                               00926700
                  RETURN SIZE;                                                  00926800
               END;                                                             00926900
               ELSE RETURN NEWSIZE;                                             00927000
            END;                                                                00927100
            MODE=0;                                                             00927200
SHARP_UNKNOWN:                                                                  00927300
            IF PSEUDO_TYPE(NEXT_SUB)=SCALAR_TYPE THEN DO;                       00927400
               CALL HALMAT_POP(XSTOI,1,0,0);                                    00927500
SHARP_ELIM:                                                                     00927600
               CALL HALMAT_PIP(LOC_P(NEXT_SUB),PSEUDO_FORM(NEXT_SUB),0,0);      00927700
               LOC_P(NEXT_SUB)=LAST_POP#;                                       00927800
               PSEUDO_FORM(NEXT_SUB)=XVAC;                                      00927900
            END;                                                                00928000
            IF (MODE&"F")=XIMD THEN DO;                                         00928100
               IF NEWSIZE="10" THEN NEWSIZE=XMADD(INT_TYPE-MAT_TYPE);           00928200
               ELSE NEWSIZE=XMSUB(INT_TYPE-MAT_TYPE);                           00928300
               CALL HALMAT_POP(NEWSIZE,2,0,0);                                  00928400
               CALL HALMAT_PIP(SIZE,XIMD,0,0);                                  00928500
               MODE=0;                                                          00928600
               GO TO SHARP_ELIM;                                                00928700
            END;                                                                00928800
            PSEUDO_TYPE(NEXT_SUB)=MODE;                                         00928900
            RETURN -1;                                                          00929000
         END;                                                                   00929100
 /*  SHARP BY ITSELF  */                                                        00929200
         DO;                                                                    00929300
            PSEUDO_FORM(NEXT_SUB)=MODE;                                         00929400
            LOC_P(NEXT_SUB)=SHARP_LOC;                                          00929500
            PSEUDO_TYPE(NEXT_SUB)=INT_TYPE;                                     00929600
            GO TO SHARP_GONE;                                                   00929700
         END;                                                                   00929800
 /*  SHARP PLUS EXPRESSION */                                                   00929900
         DO;                                                                    00930000
            IF PSEUDO_FORM(NEXT_SUB)=XIMD THEN DO;                              00930100
               IF MODE=XIMD THEN DO;                                            00930200
                  LOC_P(NEXT_SUB),NEWSIZE=LOC_P(NEXT_SUB)+NEWSIZE;              00930300
                  GO TO SHARP_GONE;                                             00930400
               END;                                                             00930500
            END;                                                                00930600
            NEWSIZE="10";                                                       00930700
SHARP_PM:                                                                       00930800
            MODE=MODE|NEWSIZE;                                                  00930900
            GO TO SHARP_UNKNOWN;                                                00931000
         END;                                                                   00931100
 /*  SHARP MINUS EXPRESSION  */                                                 00931200
         DO;                                                                    00931300
            IF PSEUDO_FORM(NEXT_SUB)=XIMD THEN DO;                              00931400
               IF MODE=XIMD THEN DO;                                            00931500
                  LOC_P(NEXT_SUB),NEWSIZE=NEWSIZE-LOC_P(NEXT_SUB);              00931600
                  GO TO SHARP_GONE;                                             00931700
               END;                                                             00931800
            END;                                                                00931900
            NEWSIZE="20";                                                       00932000
            GO TO SHARP_PM;                                                     00932100
         END;                                                                   00932200
      END;                                                                      00932300
   END CHECK_SUBSCRIPT;                                                         00932400
