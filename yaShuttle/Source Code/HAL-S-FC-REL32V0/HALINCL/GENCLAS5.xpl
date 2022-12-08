 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GENCLAS5.xpl
    Purpose:    Part of the HAL/S-FC compiler.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section TBD.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /*    REVISION HISTORY :                                                   */
 /*    ------------------                                                   */
 /*   DATE    NAME  REL   DR NUMBER AND TITLE                               */
 /* --------  ---- -----  ------------------------------------------------- */
 /* 02/21/96  TEV  27V1/  CR12623  CLARIFY IMPLICIT CONVERSION REQUIREMENTS */
 /*                11V1                                                     */
 /*                                                                         */
 /* 10/22/03  JAC  32V0/  DR120223 NO FT101 ERROR FOR LITERAL ARGUMENT      */
 /*                17V0                                                     */
 /*                                                                         */
 /***************************************************************************/
   /* CLASS 5 OPERATORS - SCALAR ARITHMETIC */                                  06528500
GEN_CLASS5:                                                                     06529000
   PROCEDURE;                                                                   06529500
   CLASS5:  DO;   /* CLASS 5 OPS  */                                            06530000
               DO CASE SUBCODE;                                                 06530500
                  DO;   /* SCALAR ASSIGNMENT  */                                06531000
                     CALL DO_ASSIGNMENT;                                        06531500
                  END;                                                          06532000
                  DO;  /*  BTOS  */                                             06532500
                     LITTYPE = BITS;                                            06533000
                     LEFTOP = GET_OPERAND(1);                                   06533500
                     CALL FORCE_BY_MODE(LEFTOP, NEWPREC(TAG)|SCALAR);           06534000
                  END;                                                          06534500
                  DO;  /*  CTOS  */                                             06535000
                     LITTYPE = CHAR;                                            06535500
                     LEFTOP = CTON(GET_OPERAND(1), NEWPREC(TAG)|SCALAR);        06536000
                  END;                                                          06536500
                  DO;   /* SCALAR TO INTEGER POWER  */                          06537000
                     CALL EXPONENTIAL(OPCODE);                                  06537500
                  END;                                                          06538000
                  DO;  /* VDOT  */                                              06538500
                     CALL ARG_ASSEMBLE;                                         06539000
                     TEMPSPACE = COLUMN(0);                                     06539500
                     CALL VMCALL(OPCODE, (OPTYPE&8)^=0, 0, LEFTOP, RIGHTOP, 0); 06540000
                     CALL RETURN_STACK_ENTRY(RIGHTOP);                          06540500
                     CALL SET_RESULT_REG(LEFTOP, OPTYPE&8 | SCALAR);            06541000
                     COLUMN(LEFTOP) = 0;                                        06541500
                  END;                                                          06542000
                  DO;   /* SCALAR ARITHMETIC  */                                06542500
                     IF OPCODE = XXASN THEN DO;                                 06543000
                        LITTYPE = NEWPREC(TAG) | SCALAR;                        06543500
                        CALL GET_OPERANDS;                                      06544000
  /*DR120223*/          IF FORM(LEFTOP) = LIT THEN DO;                          06544500
                           TYPE(LEFTOP) = NEWPREC(TAG) | SCALAR;                06545000
  /*DR120223 - PERFORM COMPILE TIME CONVERSION TO SINGLE PRECISION FOR ALL */
  /*DR120223 - LITERAL/CONSTANTS IN SINGLE SCALAR() OR FOLLOWED BY @SINGLE.*/
  /*DR120223*/             IF TAG=1 & XVAL(LEFTOP)^=0 THEN DO;
  /*DR120223*/                XVAL(LEFTOP) = 0;
  /*DR120223*/                LOC(LEFTOP) = -1;
  /*DR120223*/             END;
  /*DR120223*/          END;
                        ELSE IF TYPE(LEFTOP) ^= LITTYPE THEN                     6545100
                           CALL FORCE_ACCUMULATOR(LEFTOP, LITTYPE);              6545200
                     END;                                                       06548500
                     ELSE IF OPCODE ^= XEXP THEN                                06549000
                        CALL EVALUATE(OPCODE);                                  06549500
                     ELSE                                                       06550000
                        CALL EXPONENTIAL(OPCODE);                               06550500
                  END;                                                          06551000
                  DO;   /* ITOS  */                                             06551500
                     LITTYPE = NEWPREC(TAG) | SCALAR;                           06552000
                     LEFTOP=GET_OPERAND(1);                                     06552500
                     IF FORM(LEFTOP) ^= LIT | LOC(LEFTOP) < 0 THEN              06553000
                     /* CR12623 FIX -- TEV -- 1/30/96                */
                     /* IF THERE WAS NO PRECISION MODIFIER SPECIFED  */
                     /* (TAG=0) AND IF THE OPERAND IS A DOUBLE INT., */
                     /* THEN FORCE THE RESULT TO A SCALAR DOUBLE.    */
       /* CR12623 */ DO;
       /* CR12623 */    IF ((TAG=0 ) & (TYPE(LEFTOP) = DINTEGER)) THEN
       /* CR12623 */       CALL FORCE_BY_MODE(LEFTOP, DSCALAR);
       /* CR12623 */    ELSE
                           CALL FORCE_BY_MODE(LEFTOP, LITTYPE);                 06553500
       /* CR12623 */ END;
                     ELSE IF TAG1 ^= LIT THEN                                   06554000
                       /* CHECK TO SEE IF WE ARE CONVERTING A BIT LITERAL*/     06554050
                       /* WHICH HAS BEEN INTEGERIZED INTO A SCALAR       */     06554100
                       IF (LIT1(GET_LITERAL(LOC(LEFTOP))) = 2)                  06554150
                       THEN CALL FORCE_BY_MODE(LEFTOP, LITTYPE);                06554200
                       ELSE                                                     06554250
                        CALL LITERAL(LOC(LEFTOP), LITTYPE, LEFTOP);             06554500
       /*DR120223 - PERFORM COMPILE TIME CONVERSION TO SINGLE PRECISION FOR*/
       /*DR120223 - INTEGER LITERAL/CONSTANTS THAT CONVERT TO DOUBLE SCALAR*/
       /*DR120223 - THAT ARE IN SINGLE SCALAR().                           */
       /*DR120223*/  IF FORM(LEFTOP) = LIT THEN
       /*DR120223*/     IF TAG=1 & XVAL(LEFTOP)^=0 THEN DO;
       /*DR120223*/        XVAL(LEFTOP) = 0;
       /*DR120223*/        LOC(LEFTOP) = -1;
       /*DR120223*/  END;
                  END;                                                          06555000
               END;                                                             06555500
               CALL SETUP_VAC(LEFTOP);                                          06556000
            END CLASS5;                                                         06556500
   END GEN_CLASS5;                                                              06557000
