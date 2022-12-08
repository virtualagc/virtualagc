 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GENCLAS4.xpl
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
 
   /* CLASS 4 OPERATORS - VECTOR OPERATIONS */                                  00010000
GEN_CLASS4:                                                                     00020000
   PROCEDURE;                                                                   00030000
   CLASS4:  DO;  /* CLASS 4 OPS  */                                             00040000
               DO CASE SUBCODE;                                                 00050000
                  DO;  /* VECTOR ASSIGNMENT  */                                 00060000
                     CALL MAT_ASSIGN;                                           00070000
                  END;                                                          00080000
                  ;                                                             00090000
                  DO;  /*  NEGATE  */                                           00100000
                     CALL MAT_NEGATE;                                           00110000
                  END;                                                          00120000
                  DO;  /* MATRIX - VECTOR OPERATIONS  */                        00130000
                     CALL ARG_ASSEMBLE;                                         00140000
                     IF OPCODE = XMVPR THEN DO;                                 00150000
                        TEMPSPACE = ROW(0);                                     00160000
                        OPTYPE = TYPE(RIGHTOP);                                 00170000
                     END;                                                       00180000
                     ELSE TEMPSPACE = COLUMN(RIGHTOP);                          00190000
                     ROW(0) = 1;                                                00200000
                     COLUMN(0) = TEMPSPACE;                                     00210000
                     CALL MAT_TEMP;                                             00220000
                  END;                                                          00230000
                  DO;  /* VECTOR - VECTOR OPERATIONS  */                        00240000
                     CALL ARG_ASSEMBLE;                                         00250000
                     TEMPSPACE = COLUMN(0);                                     00260000
                     IF OPCODE="02" | OPCODE="03" THEN CLASS3_OP=TRUE;          00270000
                     CALL MAT_TEMP;                                             00280000
                  END;                                                          00290000
                  DO;  /* VECTOR - SCALAR OPERATIONS  */                        00300000
                     CALL MIX_ASSEMBLE;                                         00310000
                     TEMPSPACE = COLUMN(0);                                     00320000
                     CLASS3_OP=TRUE;                                            00330000
                     CALL MAT_TEMP;                                             00340000
                  END;                                                          00350000
               END;  /* CASE SUBCODE  */                                        00360000
               CALL SETUP_VAC(RESULT);                                          00370000
            END CLASS4;                                                         00380000
   END GEN_CLASS4;                                                              00390000
