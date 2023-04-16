 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HALMATIN.xpl
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
 /* PROCEDURE NAME:  HALMAT_INIT_CONST                                      */
 /* MEMBER NAME:     HALMATIN                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 FIXED                                        */
 /*          MULTI_VALUED      LABEL                                        */
 /*          NON_EVALUABLE     LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CHAR_TYPE                                                      */
 /*          CLASS_DI                                                       */
 /*          CONSTANT_FLAG                                                  */
 /*          FALSE                                                          */
 /*          IC_FORM                                                        */
 /*          IC_LEN                                                         */
 /*          IC_LOC                                                         */
 /*          IC_PTR1                                                        */
 /*          IC_PTR2                                                        */
 /*          IC_TYPE                                                        */
 /*          ID_LOC                                                         */
 /*          LOC_P                                                          */
 /*          MP                                                             */
 /*          NAME_IMPLIED                                                   */
 /*          PSEUDO_TYPE                                                    */
 /*          SYM_ARRAY                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_PTR                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_ARRAY                                                      */
 /*          SYT_FLAGS                                                      */
 /*          SYT_PTR                                                        */
 /*          SYT_TYPE                                                       */
 /*          TRUE                                                           */
 /*          VAR                                                            */
 /*          XLIT                                                           */
 /*          XSYT                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          DO_INIT                                                        */
 /*          IC_FOUND                                                       */
 /*          IC_LINE                                                        */
 /*          ICQ                                                            */
 /*          INIT_EMISSION                                                  */
 /*          INX                                                            */
 /*          PTR_TOP                                                        */
 /*          SYM_TAB                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          GET_ICQ                                                        */
 /*          HALMAT_PIP                                                     */
 /*          HALMAT_POP                                                     */
 /*          HOW_TO_INIT_ARGS                                               */
 /*          ICQ_ARRAYNESS_OUTPUT                                           */
 /*          ICQ_CHECK_TYPE                                                 */
 /*          ICQ_OUTPUT                                                     */
 /* CALLED BY:                                                              */
 /*          SET_SYT_ENTRIES                                                */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> HALMAT_INIT_CONST <==                                               */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
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
 /*     ==> GET_ICQ                                                         */
 /*     ==> ICQ_ARRAYNESS_OUTPUT                                            */
 /*         ==> HALMAT_POP                                                  */
 /*             ==> HALMAT                                                  */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> HALMAT_OUT                                          */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*         ==> HALMAT_PIP                                                  */
 /*             ==> HALMAT                                                  */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> HALMAT_OUT                                          */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*         ==> HALMAT_FIX_PIP#                                             */
 /*     ==> ICQ_CHECK_TYPE                                                  */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*     ==> ICQ_OUTPUT                                                      */
 /*         ==> HALMAT_POP                                                  */
 /*             ==> HALMAT                                                  */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> HALMAT_OUT                                          */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*         ==> HALMAT_PIP                                                  */
 /*             ==> HALMAT                                                  */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> HALMAT_OUT                                          */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*         ==> HALMAT_FIX_PIPTAGS                                          */
 /*         ==> GET_ICQ                                                     */
 /*         ==> ICQ_CHECK_TYPE                                              */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*     ==> HOW_TO_INIT_ARGS                                                */
 /*         ==> ICQ_TERM#                                                   */
 /*         ==> ICQ_ARRAY#                                                  */
 /***************************************************************************/
 /*     REVISION HISTORY :                                                  */
 /*     ------------------                                                  */
 /*     DATE    NAME  REL    DR NUMBER AND TITLE                            */
 /*                                                                         */
 /*    09/19/96 JMP   28V0/  109048 CHARACTER/BIT INITIALIZATION ERROR      */
 /*                   12V0          MESSAGES                                */
 /*                                                                         */
 /*    01/24/01 DCP   31V0/  13336  DON'T ALLOW ARITHMETIC EXPRESSIONS IN   */
 /*                   16V0          CHARACTER INITIAL CLAUSES               */
 /*                                                                         */
 /*    07/14/04 JAC   32V0/  120226 CONSTANT NOT CONVERTED TO INTEGER       */
 /*                   17V0                                                  */
 /*                                                                         */
 /***************************************************************************/
                                                                                01015100
HALMAT_INIT_CONST :                                                             01015200
   PROCEDURE;                                                                   01015300
      DECLARE I FIXED;                                                          01015400
      DECLARE TEMP CHARACTER; /*DR109048*/
      DECLARE CONSTLIT FIXED; /*DR109048*/

MULTI_VALUED:                                                                   01015500
      PROCEDURE BIT(8);                                                         01015600
         DECLARE MONO_VAL BIT(16) INITIAL ("(1) 110000011000");                 01015700
         IF NAME_IMPLIED THEN RETURN 2;                                         01015800
         IF SYT_ARRAY(ID_LOC)^=0 THEN RETURN TRUE;                              01015900
         IF SYT_TYPE(ID_LOC)<CHAR_TYPE THEN RETURN 2;                           01016000
         RETURN  SHR(MONO_VAL,SYT_TYPE(ID_LOC))&1;                              01016100
      END MULTI_VALUED;                                                         01016200
                                                                                01016300
/*DR120226 - ROUTINE CREATED TO ROUND A SCALAR LITERAL IN AN INTEGER CONSTANT*/
/*  DECLARATION TO THE NEAREST WHOLE NUMBER.  IT IS BASED ON MAKE_FIXED_LIT  */
/*  AND FLOATING.  IT RETURNS FALSE IF THE NUMBER IS OUTSIDE THE RANGE OF    */
/*  ALLOWED INTEGERS OR IT RETURNS TRUE AND THE ROUNDED NUMBER IS IN DW().   */
ROUND_SCALAR:
         PROCEDURE(PTR);
         DECLARE PTR FIXED;
         DECLARE NEG BIT(1);
         DECLARE LIMIT_OK LABEL;
         DECLARE ADJ_NEG FIXED INITIAL("41100000");
         PTR=GET_LITERAL(PTR);
         DW(0)=LIT2(PTR);
         DW(1)=LIT3(PTR);
         PTR=ADDR(LIMIT_OK);
         NEG = SHR(DW(0),31);
         CALL INLINE("58", 3, 0, DW_AD);           /* L    3,DW_AD            */
/*LOAD DOUBLE FROM STACK SPACE 3 TO REGISTER 0*/
         CALL INLINE("68", 0, 0, 3, 0);            /* LD   0,0(0,3)           */
/*LOAD POSITIVE VALUE OF REGISTER 0 INTO REGISTER 0*/
         CALL INLINE("20", 0, 0);                  /* LPDR 0,0                */
/*LOAD ROUNDING VALUE INTO STACK 1 THEN ADD TO REGISTER 0*/
         CALL INLINE("58", 1, 0, ADDR_ROUNDER);    /* L    1,ADDR_ROUNDER     */
         CALL INLINE("6A", 0, 0, 1, 0);            /* AD   0,0(0,1)           */
         CALL INLINE("58", 1, 0, ADDR_FIXED_LIMIT);/* L    1,ADDR_FIXED_LIMIT */
         CALL INLINE("58", 2, 0, PTR);             /* L    2,PTR              */
/*COMPARE REGISTER 0 TO THE POSITIVE INTEGER LIMIT*/
         CALL INLINE("69", 0, 0, 1, 0);            /* CD   0,0(0,1)           */
/*BRANCH TO 'LIMIT_OK' IF REGISTER 0 IS LESS THAN OR EQUAL TO THE LIMIT       */
         CALL INLINE("07",12, 2);                  /* BNHR 2                  */
/*FOR NEGATIVE VALUES OUTSIDE OF THE RANGE, SUBTRACT ONE THEN RETEST*/
/*SINCE THE NEGATIVE RANGE EXTENDS ONE MORE THAN THE POSITIVE RANGE.*/
/*USE REGISTER 4 SO THAT THE VALUE IN REGISTER 0 IS NOT CHANGED.    */
         IF NEG THEN DO;
            CALL INLINE("68", 4, 0, 3, 0);         /* LD   4,0(0,3)           */
            CALL INLINE("20", 4, 4);               /* LPDR 4,4                */
            CALL INLINE("2B", 2, 2);               /* SDR  2,2                */
            CALL INLINE("78", 2, 0, ADJ_NEG);      /* LE   2,ADJ_NEG          */
            CALL INLINE("2B", 4, 2);               /* SDR  4,2                */
            CALL INLINE("58", 1, 0, ADDR_ROUNDER); /* L    1,ADDR_ROUNDER     */
            CALL INLINE("6A", 4, 0, 1, 0);         /* AD   4,0(0,1)           */
            CALL INLINE("58", 1, 0, ADDR_FIXED_LIMIT);/* L 1,ADDR_FIXED_LIMIT */
            CALL INLINE("58", 2, 0, PTR);          /* L    2,PTR              */
            CALL INLINE("69", 4, 0, 1, 0);         /* CD   4,0(0,1)           */
/*BRANCH TO 'LIMIT_OK' IF THE NEGATIVE VALUE IS IN NEGATIVE RANGE*/
            CALL INLINE("07",12, 2);               /* BNHR 2                  */
         END;
         RETURN FALSE;
   LIMIT_OK:
/*COMPLETE THE ROUNDING PROCESS*/
         CALL INLINE("58", 1, 0, ADDR_FIXER);      /* L    1,ADDR_FIXER       */
         CALL INLINE("6E", 0, 0, 1, 0);            /* AW   0,0(0,1)           */
         CALL INLINE("60",0,0,3,8);                /* STD  0,8(0,3)           */
         DW(0)=DW(8);
         IF NEG THEN DO;
            CALL INLINE("58",1,0,DW_AD);
            CALL INLINE("97",8,0,1,0);
         END;
         DW(1)=DW(3);
         CALL INLINE("58",1,0,DW_AD);              /* L    1,DW_AD            */
         CALL INLINE("2B",0,0);                    /* SDR  0,0                */
         CALL INLINE("6A",0,0,1,0);                /* AD   0,0(0,1)           */
         CALL INLINE("60",0,0,1,0);                /* STD  0,0(0,1)           */
         RETURN TRUE;
      END ROUND_SCALAR;

      IF IC_FOUND = 0 THEN  /*  RETURN IN CASE OF NO INITIALIZATION  */         01016400
         RETURN;                                                                01016500
      IF IC_FOUND > 1 THEN DO;  /* IS NORMAL NON_FACTORED CASE */               01016600
         ICQ = IC_PTR2;  /* SET UP LIST PRT */                                  01016700
         IC_FOUND = IC_FOUND - 2;  /* THIS INIT CAN ONLY BE USED ONCE */        01016800
         IC_LINE = INX(IC_PTR2);  /* TO REUSE FILE_SPACE  */                    01016900
         PTR_TOP = IC_PTR2 - 1;  /* SO RESET PTR_TOP AND INDICATORS */          01017000
      END;                                                                      01017100
      ELSE  /* FACTORED CASE, SET PTR, BUT CAN'T RESET SINCE MULT. USAGE */     01017200
         ICQ = IC_PTR1;                                                         01017300
      IF DO_INIT THEN DO_INIT=FALSE;                                            01017400
      ELSE RETURN;                                                              01017500
      DO CASE HOW_TO_INIT_ARGS(LOC_P(ICQ));                                     01017600
 /*  CASE 0,  TOO FEW ELEMENTS  */                                              01017700
         DO;                                                                    01017800
            IF PSEUDO_TYPE(ICQ)=0 THEN CALL ERROR(CLASS_DI,5,VAR(MP));          01017900
            CALL ICQ_OUTPUT;                                                    01018000
         END;                                                                   01018100
 /*  CASE 1, ONE ARGUMENT  */                                                   01018200
         IF PSEUDO_TYPE(ICQ)^=0 THEN DO;                                        01018300
            IF ^MULTI_VALUED THEN CALL ERROR(CLASS_DI,4,VAR(MP));               01018400
            CALL ICQ_OUTPUT;                                                    01018500
         END;                                                                   01018600
         ELSE DO;                                                               01018700
            I=GET_ICQ(INX(ICQ)+1);                                              01018800
            DO WHILE IC_FORM(I)^=2;                                             01018900
               INX(ICQ)=INX(ICQ)+1;                                             01019000
               I=GET_ICQ(INX(ICQ)+1);                                           01019100
            END;                                                                01019200

            IF MULTI_VALUED > 0 THEN GO TO NON_EVALUABLE;

            IF (SYT_FLAGS(ID_LOC)&CONSTANT_FLAG)^=0 THEN DO;                    01019400
               IF IC_LEN(I)^=XLIT THEN GO TO NON_EVALUABLE;                     01019500
               CALL ICQ_CHECK_TYPE(I);                                          01019600

               CONSTLIT = GET_LITERAL(IC_LOC(I));               /*DR109048*/
               /*DR120226 - ROUND SCALARS IN INTEGER CONSTANT DECLARE     */
               /*   OR EMIT AN ERROR IF OUTSIDE OF RANGE OF INTEGERS      */
               IF SYT_TYPE(ID_LOC) = INT_TYPE THEN              /*DR120226*/
                  IF ROUND_SCALAR(IC_LOC(I)) THEN DO;           /*DR120226*/
                     IF IC_TYPE(I) = SCALAR_TYPE THEN           /*DR120226*/
                        IC_LOC(I) = SAVE_LITERAL(1,DW_AD);      /*DR120226*/
                  END;                                          /*DR120226*/
                  ELSE CALL ERRORS(CLASS_DI,17);                /*DR120226*/
  /*CR13336*/  IF (SYT_TYPE(ID_LOC) = CHAR_TYPE) &              /*DR109048*/
  /*CR13336*/     (LIT1(CONSTLIT) = 0)
  /*CR13336*/  THEN DO;
                  TEMP = STRING(LIT2(CONSTLIT));                /*DR109048*/
                  IF (LENGTH(TEMP) > VAR_LENGTH(ID_LOC))        /*DR109048*/
                  THEN DO;                                      /*DR109048*/
                     CALL ERROR(CLASS_DI,18,SYT_NAME(ID_LOC));  /*DR109048*/
                     TEMP = SUBSTR(TEMP,0,VAR_LENGTH(ID_LOC));  /*DR109048*/
                     SYT_PTR(ID_LOC) = -SAVE_LITERAL(0,TEMP);   /*DR109048*/
                  END;                                          /*DR109048*/
                  ELSE                                          /*DR109048*/
                     SYT_PTR(ID_LOC)=-IC_LOC(I);                /*DR109048*/
               END;                                             /*DR109048*/
               ELSE                                             /*DR109048*/
                  SYT_PTR(ID_LOC)=-IC_LOC(I);                   /*DR109048*/    01019700
            END;                                                                01019800
            ELSE DO;                                                            01019900
NON_EVALUABLE:                                                                  01020000
               CALL HALMAT_POP(ICQ_CHECK_TYPE(I,1),2,0,IC_TYPE(I));             01020100
               CALL HALMAT_PIP(ID_LOC,XSYT,0,0);                                01020200
               CALL HALMAT_PIP(IC_LOC(I),IC_LEN(I),0,0);                        01020300
               CALL ICQ_ARRAYNESS_OUTPUT;                                       01020400
            END;                                                                01020500
         END;                                                                   01020600
 /*  CASE 2,  MATCHES TERMINAL NUMBER  */                                       01020700
         DO;                                                                    01020800
            CALL ICQ_OUTPUT;                                                    01020900
            IF PSEUDO_TYPE(ICQ)=0 THEN CALL ICQ_ARRAYNESS_OUTPUT;               01021000
         END;                                                                   01021100
 /*  CASE 3,  MATCHES TOTAL NUMBER  */                                          01021200
         DO;                                                                    01021300
            IF PSEUDO_TYPE(ICQ)^=0 THEN CALL ERROR(CLASS_DI,4,VAR(MP));         01021400
            CALL ICQ_OUTPUT;                                                    01021500
         END;                                                                   01021600
 /*  CASE 4,  TOO MANY ELEMENTS  */                                             01021700
         DO;                                                                    01021800
            CALL ERROR(CLASS_DI,10,VAR(MP));                                    01021900
            CALL ICQ_OUTPUT;                                                    01022000
         END;                                                                   01022100
      END;                                                                      01022200
      INIT_EMISSION=TRUE;                                                       01022300
   END HALMAT_INIT_CONST;                                                       01022400
