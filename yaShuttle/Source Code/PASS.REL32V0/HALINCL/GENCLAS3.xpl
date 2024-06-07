 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GENCLAS3.xpl
    Purpose:    Part of the HAL/S-FC compiler.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section TBD.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/***********************************************************************   */   00001000
/*  REVISION HISTORY :                                                     */   00002000
/*  ------------------                                                     */   00003000
/*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */   00004000
/*                                                                         */   00005000
/*07/15/91 DAS   24V0  CR11096 #DPARM - COPY #D AGGREGATE DATA TO STACK    */   00006000
/*                             BEFORE VECTOR INVERSE RTL CALL.             */   00007000
/*                                                                         */   00007100
/*12/23/92 PMA   8V0   *       MERGED 7V0 AND 24V0 COMPILERS.              */   00007200
/*                             * REFERENCE 24V0 CR/DRS                     */   00007300
/***********************************************************************   */   00008000
   /* CLASS 3 OPERATORS - MATRIX OPERATIONS */                                  00010000
GEN_CLASS3:                                                                     00020000
   PROCEDURE;                                                                   00030000
   CLASS3:  DO;  /* CLASS 3 OPS  */                                             00040000
               DO CASE SUBCODE;                                                 00050000
                  DO;  /* MATRIX ASSIGNMENT  */                                 00060000
                     CALL MAT_ASSIGN;                                           00070000
                  END;                                                          00080000
                  DO;  /* TRANSPOSE  */                                         00090000
                     CALL ARG_ASSEMBLE;                                         00100000
                     ROW(0) = COLUMN(LEFTOP);                                   00110000
                     COLUMN(0) = ROW(LEFTOP);                                   00120000
                     TEMPSPACE = ROW(0) * COLUMN(0);                            00130000
                     CALL MAT_TEMP;                                             00140000
                  END;                                                          00150000
                  DO;  /* NEGATE  */                                            00160000
                     CALL MAT_NEGATE;                                           00170000
                  END;                                                          00180000
                  DO;  /* MATRIX - MATRIX OPERATIONS  */                        00190000
                     CALL ARG_ASSEMBLE;                                         00200000
                     COLUMN(0) = COLUMN(RIGHTOP);                               00210000
                     TEMPSPACE = ROW(0) * COLUMN(0);                            00220000
                     IF OPCODE="02" | OPCODE="03" THEN CLASS3_OP=TRUE;          00230000
                     CALL MAT_TEMP;                                             00240000
                  END;                                                          00250000
                  DO;  /* VECTOR OUTER PRODUCT  */                              00260000
                     CALL ARG_ASSEMBLE;                                         00270000
                     ROW(0) = COLUMN(LEFTOP);                                   00280000
                     COLUMN(0) = COLUMN(RIGHTOP);                               00290000
                     TEMPSPACE = ROW(0) * COLUMN(0);                            00300000
                     OPTYPE = OPTYPE & 8 | CLASS;                               00310000
                     CALL MAT_TEMP;                                             00320000
                  END;                                                          00330000
                  DO;  /* MATRIX - SCALAR OPERATIONS  */                        00340000
                     CALL MIX_ASSEMBLE;                                         00350000
                     TEMPSPACE = ROW(0) * COLUMN(0);                            00360000
                     CLASS3_OP=TRUE;                                            00370000
                     CALL MAT_TEMP;                                             00380000
                  END;                                                          00390000
                  DO;  /* INVERSE  */                                           00400000
                     LEFTOP = GET_OPERAND(1);                                   00410000
                     STMT_PREC=(TYPE(LEFTOP) & 8);                              00420000
                     IF CHECK_REMOTE(LEFTOP) | DEL(LEFTOP) > 0 THEN             00430000
                        LEFTOP = VECMAT_CONVERT(LEFTOP);                        00440000
   /*-------------------- DANNY #DPARM --- #D PASS-BY-REF TO RTL ----*/         00441000
   /* #D AGGREGATE DATA MUST BE COPIED TO THE STACK.                 */         00442000
                     IF DATA_REMOTE & (CSECT_TYPE(LOC(LEFTOP),LEFTOP)=LOCAL#D)  00443000
                        THEN LEFTOP = VECMAT_CONVERT(LEFTOP);                   00444000
   /*----------------------------------------------------------------*/         00445000
                     CALL DROPSAVE(LEFTOP);                                     00450000
                     LITTYPE = INTEGER;                                         00460000
                     RIGHTOP = GET_OPERAND(2);                                  00470000
                     IF VAL(RIGHTOP) = 1 THEN DO;                               00480000
                        RESULT = LEFTOP; /* IDENTITY */                         00490000
                        CALL RETURN_STACK_ENTRY(RIGHTOP);                       00500000
                     END;                                                       00510000
                     ELSE DO;                                                   00520000
                        ROW(0), COLUMN(0) = COLUMN(LEFTOP);                     00530000
                        TEMPSPACE = ROW(0) * COLUMN(0);                         00540000
                        OPTYPE = TYPE(LEFTOP);                                  00550000
                        IF VAL(RIGHTOP) < -1 THEN DO;                           00560000
                           VAL(RIGHTOP) = -VAL(RIGHTOP);                        00570000
                           RESULT = GET_VM_TEMP;                                00580000
                           EXTOP = GETINVTEMP(OPTYPE, ROW(0));                  00590000
                           CALL DROPSAVE(EXTOP);                                00600000
                           CALL VMCALL(OPCODE,(OPTYPE&8)^=0,RESULT,LEFTOP,EXTOP,00610000
                              0);                                               00620000
                           CALL RETURN_STACK_ENTRIES(LEFTOP, EXTOP);            00630000
                           CALL DROPFREESPACE;                                  00640000
                           LEFTOP, LASTRESULT = RESULT;                         00650000
                           CALL DROPSAVE(LEFTOP);                               00660000
                        END;                                                    00670000
                        IF VAL(RIGHTOP) > 1 THEN DO;                            00680000
                           TARGET_REGISTER = FIXARG2;                           00690000
                           CALL FORCE_ACCUMULATOR(RIGHTOP);                     00700000
                           CALL STACK_TARGET(RIGHTOP);                          00710000
                           RIGHTOP = 0;                                         00720000
                           OPCODE = XMEXP;                                      00730000
                        END;                                                    00740000
                        ELSE IF VAL(RIGHTOP)=0 THEN DO;                         00750000
                          OPCODE=XMIDN;                                         00760000
                          CLASS1_OP=TRUE;                                       00770000
                        END;                                                    00780000
                        CALL RETURN_STACK_ENTRY(RIGHTOP);                       00790000
                        IF OPCODE = XMINV THEN                                  00800000
                           RIGHTOP = GETINVTEMP(OPTYPE, ROW(0));                00810000
                        ELSE IF OPCODE = XMEXP THEN                             00820000
                           RIGHTOP = GETFREESPACE(OPTYPE, TEMPSPACE);           00830000
                        ELSE RIGHTOP = 0;                                       00840000
                        IF RIGHTOP > 0 THEN CALL DROPSAVE(RIGHTOP);             00850000
                     CALL MAT_TEMP;                                             00860000
                     END;                                                       00870000
                  END;                                                          00880000
               END;  /* CASE SUBCODE  */                                        00890000
               CALL SETUP_VAC(RESULT);                                          00900000
            END CLASS3;                                                         00910000
   END GEN_CLASS3;                                                              00920000
