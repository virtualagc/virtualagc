 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GENCLAS6.xpl
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
 
/*  REVISION HISTORY :                                                     */
/*  ------------------                                                     */
/*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
/*                                                                         */
/*03/05/91 RAH   23V2  CR11109 CLEANUP OF COMPILER SOURCE CODE             */
/*                                                                         */
/*09/01/04 DCP/ 32V0   DR120224 INCORRECT SUBBIT FOR DOUBLE LITERAL        */
/*         JAC                                                             */
/*                                                                         */
/*05/12/04 JAC  32V0/  DR120223 NO FT101 ERROR FOR LITERAL ARGUMENT        */
/*              17V0                                                       */
/*                                                                         */
/***************************************************************************/
   /* CLASS 6 OPERATORS - INTEGER ARITHMETIC */                                 06558000
GEN_CLASS6:                                                                     06558500
   PROCEDURE;                                                                   06559000
                                                                                06570000
INTEGER_MULTIPLY:                                                               06570500
   PROCEDURE(OPCODE);                                                           06571000
      DECLARE (OPCODE, LEFTR, RIGHTR) BIT(16), (LREG, RREG) BIT(1);             06571500
                                                                                06572000
      /* INTERNAL ROUTINE TO SET UP INPUT REGISTER FOR MULTIPLY */              06572500
   SET_LEFTOP_REG:                                                              06573000
      PROCEDURE(OP);                                                            06573500
         DECLARE OP BIT(16);                                                    06574000
         IF REG(OP) THEN DO;                                                    06574500
            IF OPTYPE = INTEGER THEN RETURN;                                    06575000
            CALL MOVEREG(REG(OP), REG(OP)-1, TYPE(OP), 1);                      06575500
            REG(OP) = REG(OP) - 1;                                              06576000
         END;                                                                   06576500
      END SET_LEFTOP_REG;                                                       06577000
                                                                                06577500
      /* INTERNAL ROUTINE TO SET UP FINAL RESULT REGISTERS  */                  06578000
   SET_RESULT_REG:                                                              06578500
      PROCEDURE(OP1, OP2);                                                      06579000
         DECLARE (OP1, OP2) BIT(16);                                            06579500
/************** DR58234  R. HANDLEY  24/02/89 ********************/             06579505
/*                                                               */             06579510
/* SET_RESULT_REG PREVIOUSLY ASSUMED THAT IF EITHER OPERAND WERE */             06579515
/* A DOUBLE THEN THE RESULT WILL BE A DOUBLE. A POST MULTIPLY    */             06579520
/* CONVERSION IS ADDED HERE FOR THE CASE: SP <-- (SP)(DP).       */             06579525
/*                                                               */             06579530
/*****************************************************************/             06579535
         IF ((OPTYPE&8) = 0) & (TYPE(OP1) ^= TYPE(OP2)) THEN DO;                06579540
            /* SP <-- (SP)(DP) */                                               06579545
            IF ^REG(OP1) THEN DO; /* EVEN REG */                                06579550
               CALL EMITP(SLDL, REG(OP1), 0, SHCOUNT, 31);                      06579555
               USAGE(REG(OP1)+1) = 0;  /* OK TO GET RID OF 2ND REG              06579560
                                          BECAUSE MR DESTROYS IT */             06579565
            END;                                                                06579570
            ELSE /* ODD REG */                                                  06579575
               CALL EMITP(SLL, REG(OP1), 0, SHCOUNT, 15);                       06579580
         END;                                                                   06579585
         ELSE                                                                   06579590
/*********************** END DR58234 *****************************/             06579595
         DO CASE (OPTYPE&8) ^= 0;                                               06580000
            DO;  /* BOTH SINGLE  */                                             06580500
               CALL EMITP(SLL, REG(OP1), 0, SHCOUNT, 15);                       06581000
               IF ^REG(OP1) THEN                                                06581500
                  USAGE(REG(OP1)+1) = 0;                                        06582000
            END;                                                                06582500
            DO;  /* ONE DOUBLE, ONE SINGLE  */                                  06583000
               IF TYPE(OP1) ^= TYPE(OP2) THEN DO;                               06583500
                  CALL EMITP(SLDL, REG(OP1), 0, SHCOUNT, 15);                   06584000
                  USAGE(REG(OP1)+1) = 0;                                        06584500
               END;                                                             06585000
               ELSE DO;  /* BOTH DOUBLE  */                                     06585500
                  CALL EMITP(SRDA, REG(OP1), 0, SHCOUNT, 1);                    06586000
                  USAGE(REG(OP1)) = 0;                                          06586500
                  REG(OP1) = REG(OP1) + 1;                                      06587000
                  USAGE(REG(OP1)) = 2;                                          06587500
               END;                                                             06588000
            END;                                                                06588500
         END;                                                                   06589000
      END SET_RESULT_REG;                                                       06589500
                                                                                06590000
      /* INTERNAL ROUTINE TO TO RR INTEGER MULTIPLICATION */                    06590500
   DO_MR:                                                                       06591000
      PROCEDURE(OP1, OP2);                                                      06591500
         DECLARE (OP1, OP2) BIT(16);                                            06592000
         CALL SET_LEFTOP_REG(OP1);                                              06592500
         CALL EMITRR(MR, REG(OP1), REG(OP2));                                   06593000
         CALL DROP_REG(OP2);                                                    06593500
         CALL SET_RESULT_REG(OP1, OP2);                                         06594000
      END DO_MR;                                                                06594500
                                                                                06595000
      /* INTERNAL ROUTINE TO SEE IF OPERAND OCCUPIES DOUBLE REGISTER PAIR */    06595500
   PAIRED:                                                                      06596000
      PROCEDURE(OP) BIT(1);                                                     06596500
         DECLARE (OP, MATE) BIT(16);                                            06597000
         IF USAGE(REG(OP)) > 3 THEN RETURN FALSE;                               06597500
         IF REG(OP) THEN DO;                                                    06598000
            IF OPTYPE = INTEGER THEN RETURN TRUE;                               06598500
            MATE = REG(OP) - 1;                                                 06599000
         END;                                                                   06599500
         ELSE MATE = REG(OP) + 1;                                               06600000
         IF USAGE(MATE) < 2 THEN RETURN TRUE;                                   06600500
         RETURN FALSE;                                                          06601000
      END PAIRED;                                                               06601500
                                                                                06602000
      /* INTERNAL ROUTINE TO SET UP TARGET REGISTER FOR MULTIPLY */             06602500
   GET_TARGET:                                                                  06603000
      PROCEDURE;                                                                06603500
         IF (FORM(LEFTOP)=VAC & PAIRED(LEFTOP)) THEN RETURN;                    06604000
         TARGET_REGISTER = BESTAC(DOUBLE_ACC);                                  06604500
         CALL CHECKPOINT_REG(TARGET_REGISTER+1);                                06605000
      END GET_TARGET;                                                           06606000
                                                                                06606500
      CALL GET_OPERANDS;                                                        06607000
      IF TAG & FORM(RIGHTOP) = LIT THEN DO;                                      6607500
         TO_BE_INCORPORATED = FALSE;                                             6607550
         TO_BE_MODIFIED = TRUE;                                                  6607600
         IF FORM(LEFTOP) ^= SYM | INX(LEFTOP) ^= 0 THEN                         06607650
            CALL FORCE_ACCUMULATOR(LEFTOP, INTEGER, INDEX_REG);                 06607660
         TMP = CONST(LEFTOP) * VAL(RIGHTOP);                                    06607700
         CALL SUBSCRIPT2_MULT(VAL(RIGHTOP));                                    06607710
         CONST(LEFTOP) = TMP;                                                   06607720
         CALL RETURN_STACK_ENTRY(RIGHTOP);                                       6607800
      END;                                                                       6607850
     ELSE DO;                                                                    6607900
      IF FORM(LEFTOP) = VAC & FORM(RIGHTOP) = VAC THEN DO;                       6607950
         IF USAGE(REG(LEFTOP))<4 & USAGE(REG(RIGHTOP))<4 THEN DO;               06608000
            CALL INCORPORATE(LEFTOP);                                           06608500
            CALL INCORPORATE(RIGHTOP);                                          06609000
            IF REG(RIGHTOP)-REG(LEFTOP) = 1 & REG(RIGHTOP) | PAIRED(LEFTOP)     06609500
            THEN DO;                                                            06610000
               CALL DO_MR(LEFTOP, RIGHTOP);                                     06610500
            END;                                                                06611500
            ELSE IF REG(LEFTOP)-REG(RIGHTOP) = 1 & REG(LEFTOP) | PAIRED(RIGHTOP)06612000
            THEN DO;                                                            06612500
               CALL DO_MR(RIGHTOP, LEFTOP);                                     06613000
               CALL COMMUTEM;                                                   06613500
            END;                                                                06614000
            ELSE GO TO NEW_RR;                                                  06614500
         END;                                                                   06615000
         ELSE DO;                                                               06615500
            IF USAGE(REG(LEFTOP))>USAGE(REG(RIGHTOP)) THEN CALL COMMUTEM;       06616000
      NEW_RR:                                                                   06616500
            CALL GET_TARGET;                                                    06617000
            TO_BE_MODIFIED = TRUE;                                              06617500
            CALL FORCE_ACCUMULATOR(LEFTOP);                                     06618000
            TARGET_REGISTER = -1;                                               06618500
            CALL FORCE_ACCUMULATOR(RIGHTOP);                                    06619000
            CALL DO_MR(LEFTOP, RIGHTOP);                                        06619500
         END;                                                                   06620000
         CALL RETURN_STACK_ENTRY(RIGHTOP);                                      06620500
      END;                                                                      06621000
      ELSE DO;                                                                  06621500
         IF SHOULD_COMMUTE(OPCODE) THEN CALL COMMUTEM;                          06622000
/*************  DR58234  R. HANDLEY  24/02/89 *******************/              06622500
/*                                                              */              06622505
/* CHECK FOR LEFTOP AND RIGHTOP IN A REGISTER. IF EITHER ARE IN */              06622510
/* A REGISTER SET THE INDIRECT STACK TYPE TO THE REGISTER TYPE. */              06622515
/*                                                              */              06622520
/****************************************************************/              06622525
         LEFTR = SEARCH_REGS(LEFTOP);                                           06622530
         RIGHTR = SEARCH_REGS(RIGHTOP);                                         06622535
         IF LEFTR >= 0 THEN                                                     06622540
            TYPE(LEFTOP) = R_TYPE(LEFTR);                                       06622545
         IF RIGHTR >= 0 THEN                                                    06622550
            TYPE(RIGHTOP) = R_TYPE(RIGHTR);                                     06622555
         LREG = LEFTR>=0 | FORM(LEFTOP) = VAC;                                  06622560
         RREG = RIGHTR>=0 | FORM(RIGHTOP) = VAC;                                06622565
/*********************** END DR58234*****************************/              06622570
         IF LREG & RREG THEN GO TO NEW_RR;                                      06623500
         IF FORM(LEFTOP)=FORM(RIGHTOP) & LOC(LEFTOP)=LOC(RIGHTOP) THEN          06624000
            GO TO NEW_RR;                                                       06624500
         IF POWER_OF_TWO(RIGHTOP) THEN DO;                                      06625000
            TO_BE_MODIFIED = INX_SHIFT(0) > 0;                                  06625500
            CALL FORCE_ACCUMULATOR(LEFTOP);                                     06626000
            IF INX_SHIFT(0) > 0 THEN DO;                                        06626500
               DO CASE INX_SHIFT(0) ^= 1;                                       06627000
                  CALL EMITRR(AR, REG(LEFTOP), REG(LEFTOP));                    06627500
                  CALL EMITP(SLA, REG(LEFTOP), 0, SHCOUNT, INX_SHIFT(0));       06628000
               END;                                                             06628500
               CALL UNRECOGNIZABLE(REG(LEFTOP));                                06629000
            END;                                                                06629500
            CALL RETURN_STACK_ENTRY(RIGHTOP);                                   06630000
         END;                                                                   06630500
         ELSE IF OPTYPE = INTEGER & CONST(RIGHTOP) = 0 & ^RREG THEN             06631000
            DO;                                                                 06631500
               CALL EXPRESSION(XEXP);  /* WILL NOT COMMUTE  */                  06632000
               CALL EMITP(SLL, REG(LEFTOP), 0, SHCOUNT, 15);                    06632500
            END;                                                                06633000
         ELSE DO;                                                               06633500
            CALL GET_TARGET;                                                    06634000
            TO_BE_MODIFIED = TRUE;                                              06634500
            CALL FORCE_ACCUMULATOR(LEFTOP);                                     06635000
            TARGET_REGISTER = -1;                                               06635500
            CALL SET_LEFTOP_REG(LEFTOP);                                        06636000
            CALL EXPRESSION(XEXP);                                              06637000
            CALL SET_RESULT_REG(LEFTOP, RIGHTOP);  /* ONLY TYPE(RIGHTOP) USED */06637500
         END;                                                                   06638500
      END;                                                                      06639000
      TYPE(LEFTOP), R_TYPE(REG(LEFTOP)) = OPTYPE;                               06639500
      CALL UNRECOGNIZABLE(REG(LEFTOP));                                         06640000
     END;                                                                        6640100
   END INTEGER_MULTIPLY;                                                        06640500
   CLASS6:  DO;   /* CLASS 6 OPS  */                                            06641000
               DO CASE SUBCODE;                                                 06641500
                  DO;   /* INTEGER ASSIGNMENT  */                               06642000
                     CALL DO_ASSIGNMENT;                                        06642500
                  END;                                                          06643000
                  DO;  /* BTOI  */                                              06643500
                     LITTYPE = BITS;                                            06644000
                     LEFTOP = GET_OPERAND(1);                                   06644500
   /*DR120224*/      IF FORM(LEFTOP) ^= LIT                                     06645000
   /*DR120224*/         | (LOC(LEFTOP)<0 & VAL(LEFTOP) ^=0) THEN
                        CALL FORCE_ACCUMULATOR(LEFTOP, NEWPREC(TAG) | INTEGER); 06645500
   /*DR120223*/      ELSE DO;
   /*DR120223 - PERFORM COMPILE TIME CONVERSION TO SINGLE PRECISION FOR   */
   /*DR120223 - BIT LITERAL/CONSTANTS GREATER THAN "FFFF" (DOUBLE INTEGER)*/
   /*DR120223 - THAT ARE IN SINGLE INTEGER().                             */
   /*DR120223*/         IF ((TYPE(LEFTOP)&8)=8) & NEWPREC(TAG)=0 THEN DO;
   /*DR120223*/            VAL(LEFTOP) = VAL(LEFTOP) & "FFFF";
   /*DR120223*/            IF (VAL(LEFTOP)&"8000")="8000" THEN
   /*DR120223*/               VAL(LEFTOP) = VAL(LEFTOP) | "FFFF0000";
   /*DR120223*/         END;
   /*DR120223*/         LOC(LEFTOP) = -1;
   /*DR120223*/      END;
                     TYPE(LEFTOP) = NEWPREC(TAG) | INTEGER;                     06646000
                  END;                                                          06646500
                  DO;  /* CTOI  */                                              06647000
                     LITTYPE = CHAR;                                            06647500
                     LEFTOP = CTON(GET_OPERAND(1), NEWPREC(TAG)|INTEGER);       06648000
                  END;                                                          06648500
                  ;                                                             06649000
                  ;                                                             06649500
                  DO;   /* STOI  */                                             06650000
                     LITTYPE = NEWPREC(TAG) | INTEGER;                          06650500
                     LEFTOP=GET_OPERAND(1);                                     06651000
                     IF FORM(LEFTOP) ^= LIT | LOC(LEFTOP) < 0 THEN              06651500
                        CALL FORCE_BY_MODE(LEFTOP, NEWPREC(TAG)|INTEGER);       06652000
   /*DR120223*/      ELSE DO;
                        IF TAG1 ^= LIT THEN                                     06652500
                          CALL LITERAL(LOC(LEFTOP),NEWPREC(TAG)|INTEGER,LEFTOP);06653000
   /*DR120223 - PERFORM COMPILE TIME CONVERSION TO SINGLE PRECISION FOR */
   /*DR120223 - SCALAR LITERAL/CONSTANTS THAT CONVERT TO DOUBLE INTEGER */
   /*DR120223 - THAT ARE IN SINGLE INTEGER().                           */
   /*DR120223*/         IF ((TYPE(LEFTOP)&8)=8) & TAG=1 THEN DO;
   /*DR120223*/            VAL(LEFTOP) = VAL(LEFTOP) & "FFFF";
   /*DR120223*/            IF (VAL(LEFTOP)&"8000")="8000" THEN
   /*DR120223*/               VAL(LEFTOP) = VAL(LEFTOP) | "FFFF0000";
   /*DR120223*/            TYPE(LEFTOP) = INTEGER;
   /*DR120223*/         END;
   /*DR120223*/         LOC(LEFTOP) = -1;
   /*DR120223*/      END;
                  END;                                                          06653500
                  DO;   /* INTEGER ARITHMETIC  */                               06654000
                     IF OPCODE = XXASN THEN DO;                                 06654500
                        LITTYPE = NEWPREC(TAG) | INTEGER;                       06655000
                        CALL GET_OPERANDS;                                      06655500
   /*DR120223*/         IF FORM(LEFTOP) = LIT THEN DO;                          06656000
   /*DR120223 - PERFORM COMPILE TIME CONVERSION TO SINGLE PRECISION FOR */
   /*DR120223 - DOUBLE PRECISION INTEGER LITERAL/CONSTANTS              */
   /*DR120223 - THAT ARE IN SINGLE INTEGER() OR FOLLOWED BY @SINGLE.    */
   /*DR120223*/            IF ((TYPE(LEFTOP)&8)=8) & TAG=1 THEN DO;
   /*DR120223*/               VAL(LEFTOP) = VAL(LEFTOP) & "FFFF";
   /*DR120223*/               IF (VAL(LEFTOP)&"8000")="8000" THEN
   /*DR120223*/                  VAL(LEFTOP) = VAL(LEFTOP) | "FFFF0000";
   /*DR120223*/               LOC(LEFTOP) = -1;
   /*DR120223*/            END;
                           TYPE(LEFTOP) = NEWPREC(TAG) | INTEGER;               06656500
   /*DR120223*/         END;
                        ELSE IF TYPE(LEFTOP) ^= LITTYPE THEN                    06657000
                           CALL FORCE_ACCUMULATOR(LEFTOP, LITTYPE);             06657500
                     END;                                                       06658000
                     ELSE DO CASE OPCODE - XADD;                                06658500
                        DO;  /*  ADD  */                                        06659000
                           CALL GET_OPERANDS;                                   06659500
  /* DR103 */              IF FORM(RIGHTOP) = LIT  &                            06660000
  /* DR103 */                 ^CSE_FLAG               THEN DO ;                 06660010
                              IF FORM(LEFTOP) = LIT THEN DO;                    06661500
                                 VAL(LEFTOP) = VAL(LEFTOP) + VAL(RIGHTOP);      06662000
                                 LOC(LEFTOP) = -1;                              06662010
                              END;                                              06662020
                              ELSE CONST(LEFTOP) = CONST(LEFTOP) + VAL(RIGHTOP);06662500
                              CALL RETURN_STACK_ENTRY(RIGHTOP);                 06663000
                           END;                                                 06663500
  /* DR103 */              ELSE IF FORM(LEFTOP) = LIT  &                        06664000
  /* DR103 */                 ^CSE_FLAG                   THEN DO ;             06664010
                              CONST(RIGHTOP) = CONST(RIGHTOP) + VAL(LEFTOP);    06664500
                              CALL COMMUTEM;                                    06665000
                              CALL RETURN_STACK_ENTRY(RIGHTOP);                 06665500
                           END;                                                 06666000
                           ELSE DO;                                             06666500
                              CONST(LEFTOP) = CONST(LEFTOP) + CONST(RIGHTOP);   06667000
                              CONST(RIGHTOP) = 0;                               06667500
                              CALL EXPRESSION(OPCODE);                          06668000
                           END;                                                 06668500
                        END;                                                    06669000
                        DO;  /* SUB  */                                         06669500
                           CALL GET_OPERANDS;                                   06670000
 /* DR103 */               IF FORM(RIGHTOP) = LIT & ^CSE_FLAG THEN DO;          06670500
                              IF FORM(LEFTOP) = LIT THEN DO;                    06672000
                                 VAL(LEFTOP) = VAL(LEFTOP) - VAL(RIGHTOP);      06672500
                                 LOC(LEFTOP) = -1;                              06672510
                              END;                                              06672520
                              ELSE CONST(LEFTOP) = CONST(LEFTOP) - VAL(RIGHTOP);06673000
                              CALL RETURN_STACK_ENTRY(RIGHTOP);                 06673500
                           END;                                                 06674000
 /* DR103 */               ELSE IF FORM(LEFTOP) = LIT   &                       06674500
 /* DR103 */                       FORM(RIGHTOP) = VAC  &                       06674510
 /* DR103 */                       ^CSE_FLAG               THEN DO ;            06674520
                              VAL(LEFTOP) = VAL(LEFTOP) - CONST(RIGHTOP);       06675500
                              CONST(RIGHTOP) = 0;                               06676000
                              CALL COMMUTEM;                                    06676500
                              CALL UNARYOP(PREFIXMINUS);                        06677000
                              CONST(LEFTOP) = VAL(RIGHTOP);                     06677500
                              CALL RETURN_STACK_ENTRY(RIGHTOP);                 06678000
                           END;                                                 06678500
                           ELSE DO;                                             06679000
                              IF FORM(LEFTOP) = LIT THEN                        06679500
                                 VAL(LEFTOP) = VAL(LEFTOP) - CONST(RIGHTOP);    06680000
                              ELSE CONST(LEFTOP) = CONST(LEFTOP)-CONST(RIGHTOP);06680500
                              CONST(RIGHTOP) = 0;                               06681000
                              CALL EXPRESSION(OPCODE);                          06681500
                           END;                                                 06682000
                        END;                                                    06682500
                        CALL INTEGER_MULTIPLY(OPCODE);                          06683000
                        CALL INTEGER_DIVIDE;                                    06683500
                        ;                                                       06684000
                        CALL EVALUATE(OPCODE);                                  06684500
                        ;                                                       06685000
                        CALL EXPONENTIAL(OPCODE);                               06685500
                     END;                                                       06686000
                  END;                                                          06686500
               END;                                                             06687000
               CALL SETUP_VAC(LEFTOP);                                          06687500
            END CLASS6;                                                         06688000
   END GEN_CLASS6;                                                              06688500
