 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SEARCHEX.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  SEARCH_EXPRESSION                                      */
 /* MEMBER NAME:     SEARCHEX                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          CTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          BUMP_VAC          LABEL                                        */
 /*          DO_OPERAND        LABEL                                        */
 /*          GET_SF_ARGS       LABEL                                        */
 /*          I                 BIT(16)                                      */
 /*          OP                BIT(16)                                      */
 /*          SAVE_INX          BIT(16)                                      */
 /*          SAVE_LIMIT        MACRO                                        */
 /*          SAVE_VACS(400)    BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK#                                                         */
 /*          CLASS                                                          */
 /*          CLASS_BI                                                       */
 /*          DSUB                                                           */
 /*          EXTN                                                           */
 /*          FCAL                                                           */
 /*          HALMAT_PTR                                                     */
 /*          IDEF                                                           */
 /*          ISHP                                                           */
 /*          LFNC                                                           */
 /*          MSHP                                                           */
 /*          NUMOP                                                          */
 /*          OPCODE                                                         */
 /*          OPR                                                            */
 /*          PCAL                                                           */
 /*          PROC_TRACE                                                     */
 /*          SFAR                                                           */
 /*          SFST                                                           */
 /*          TSUB                                                           */
 /*          VAC                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          EXP_VARS                                                       */
 /*          EXP_PTRS                                                       */
 /*          PTR_INX                                                        */
 /*          VAR_INX                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          DECODEPOP                                                      */
 /*          ERRORS                                                         */
 /*          NEXT_OP                                                        */
 /*          POPCODE                                                        */
 /*          PROCESS_EXTN                                                   */
 /*          TYPE_BITS                                                      */
 /* CALLED BY:                                                              */
 /*          GET_P_F_INV_CELL                                               */
 /*          GET_STMT_VARS                                                  */
 /*          GET_VAR_REF_CELL                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SEARCH_EXPRESSION <==                                               */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> POPCODE                                                         */
 /*     ==> TYPE_BITS                                                       */
 /*     ==> DECODEPOP                                                       */
 /*     ==> NEXT_OP                                                         */
 /*     ==> PROCESS_EXTN                                                    */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> POPNUM                                                      */
 /*         ==> POPVAL                                                      */
 /*         ==> TYPE_BITS                                                   */
 /*         ==> X_BITS                                                      */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/18/91 TKK  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /*                                                                         */
 /***************************************************************************/
                                                                                00167900
 /* SEARCHES THRU A VAC REFERENCE COLLECTING INVOCATION CELLS AND VAR REFS */   00168000
SEARCH_EXPRESSION:                                                              00168100
   PROCEDURE (CTR);                                                             00168200
      DECLARE (OP,CTR,SAVE_INX,I) BIT(16), SAVE_LIMIT LITERALLY '400',          00168300
         SAVE_VACS(SAVE_LIMIT) BIT(16);                                         00168400
                                                                                00168500
 /* SAVE VAC PTRS */                                                            00168600
BUMP_VAC:                                                                       00168700
      PROCEDURE (OPERAND);                                                      00168800
         DECLARE OPERAND BIT(16);                                               00168900
                                                                                00169000
         SAVE_INX = SAVE_INX + 1;                                               00169100
         IF SAVE_INX > SAVE_LIMIT THEN                                          00169200
            CALL ERRORS (CLASS_BI, 220);                                        00169300
         SAVE_VACS(SAVE_INX) = SHR(OPR(OPERAND),16);                            00169400
      END BUMP_VAC;                                                             00169500
                                                                                00169600
 /* COLLECTS OPERANDS ACCORDING TO TYPE */                                      00169700
DO_OPERAND:                                                                     00169800
      PROCEDURE (OPERAND);                                                      00169900
         DECLARE OPERAND BIT(16);                                               00170000
                                                                                00170100
         DO CASE TYPE_BITS(OPERAND);                                            00170200
            ;                                                                   00170300
            DO;                                                                 00170400
               VAR_INX = VAR_INX + 1;                                           00170500
               EXP_VARS(VAR_INX) = SHR(OPR(OPERAND),16);                        00170600
            END;                                                                00170700
            ;                                                                   00170800
            CALL BUMP_VAC(OPERAND);                                             00170900
            CALL PROCESS_EXTN(SHR(OPR(OPERAND),16));                            00171000
            ;;;;;;;                                                             00171100
            END;                                                                00171200
      END DO_OPERAND;                                                           00171300
                                                                                00171400
 /* GETS OPERANDS FROM A SHAPING FUNC ARG LIST */                               00171500
GET_SF_ARGS:                                                                    00171600
      PROCEDURE (CTR);                                                          00171700
         DECLARE (CTR,ARG_END) BIT(16);                                         00171800
                                                                                00171900
         ARG_END = CTR;                                                         00172000
         CTR = HALMAT_PTR(CTR);                                                 00172100
         IF POPCODE(CTR) ^= SFST THEN DO;                                       00172200
            CALL ERRORS (CLASS_BI, 203);                                        00172300
            RETURN;                                                             00172400
         END;                                                                   00172500
         CTR = NEXT_OP(CTR);                                                    00172600
         DO WHILE CTR < ARG_END;                                                00172700
            IF POPCODE(CTR) = SFST THEN CTR = HALMAT_PTR(CTR);                  00172701
            ELSE IF POPCODE(CTR) = SFAR THEN                                    00172800
               CALL DO_OPERAND(CTR+1);                                          00172900
            CTR = NEXT_OP(CTR);                                                 00173000
         END;                                                                   00173100
      END GET_SF_ARGS;                                                          00173200
                                                                                00173300
      IF PROC_TRACE THEN OUTPUT='SEARCH_EXPRESSION('||BLOCK#||':'||CTR||')';    00173301
      IF TYPE_BITS(CTR) ^= VAC THEN DO;                                         00173302
         CALL DO_OPERAND(CTR);                                                  00173303
         RETURN;                                                                00173304
      END;                                                                      00173305
      SAVE_INX = 0;                                                             00173400
      CALL BUMP_VAC(CTR);                                                       00173500
      DO WHILE SAVE_INX ^= 0;                                                   00173600
         OP = SAVE_VACS(SAVE_INX);                                              00173700
         SAVE_INX = SAVE_INX - 1;                                               00173701
         CALL DECODEPOP(OP);                                                    00173800
         IF CLASS = 0 THEN DO;                                                  00173900
            IF OPCODE = LFNC | (OPCODE >= MSHP & OPCODE <= ISHP) THEN           00174000
               CALL GET_SF_ARGS(OP);                                            00174100
            ELSE IF OPCODE=DSUB | OPCODE=TSUB | OPCODE=PCAL | OPCODE=FCAL       00174200
               | OPCODE=IDEF THEN DO;                                           00174300
               IF HALMAT_PTR(OP) ^= 0 THEN DO;                                  00174400
                  PTR_INX = PTR_INX + 1;                                        00174500
                  EXP_PTRS(PTR_INX) = HALMAT_PTR(OP);                           00174600
               END;                                                             00174700
               ELSE CALL ERRORS (CLASS_BI, 204, ' '||BLOCK#||':'||OP);          00174800
            END;                                                                00175000
            ELSE IF OPCODE = EXTN THEN CALL PROCESS_EXTN(OP);                   00175100
            ELSE DO I = 1 TO NUMOP;                                             00175200
               CALL DO_OPERAND(OP+I);                                           00175300
            END;                                                                00175400
         END;                                                                   00175500
         ELSE DO I = 1 TO NUMOP;                                                00175600
            CALL DO_OPERAND(OP+I);                                              00175700
         END;                                                                   00175800
      END;                                                                      00175900
   END SEARCH_EXPRESSION;                                                       00176000
