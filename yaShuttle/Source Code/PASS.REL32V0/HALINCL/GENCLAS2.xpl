 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GENCLAS2.xpl
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
 
/************************************************************************/
/*  REVISION HISTORY :                                                  */
/*  ------------------                                                  */
/*  DATE   NAME  REL     DR   TITLE                                     */
/*-------- ----  ----  ------ ----------------------------------------  */
/*08/31/94 TEV   27V0/ 109011 PARAMETERS FOR CATV MAY BE DESTROYED      */
/*               11V0                                                   */
/*                                                                      */
/*10/28/99 DCP   30V0/ 111344 CASRV FAILS FOR NAME NODE ASSIGNMENT      */
/*               15V0                                                   */
/*                                                                      */
/************************************************************************/
/* CLASS 2 OPERATORS - CHARACTER STRINGS */                                     06433000
GEN_CLASS2:                                                                     06433500
   PROCEDURE;                                                                   06434000
    CLASS2: DO;  /* CLASS 2 OPS  */                                             06434500
               DO CASE SUBCODE;                                                 06435000
                  DO CASE OPCODE;                                               06435500
                     ;                                                          06436000
                     DO;  /* CHARACTER ASSIGNMENT  */                           06436500
                        RIGHTOP = GET_OPERAND(1);                               06437000
                        IF NUMOP > 2 THEN                                       06437500
                           RIGHTOP = CHECK_AGGREGATE_ASSIGN(RIGHTOP);           06438000
                        CALL DROPSAVE(RIGHTOP);                                 06438500
                        DO LHSPTR = 2 TO NUMOP;                                 06439000
                           LEFTOP = GET_OPERAND(LHSPTR);                        06439500
                           CALL UPDATE_ASSIGN_CHECK(LEFTOP);                    06440000
           /*DR111344*/    CALL CHAR_CALL(OPCODE, LEFTOP, RIGHTOP, 0, 0, 1);    06440500
                           CALL RETURN_STACK_ENTRY(LEFTOP);                     06441000
                        END;                                                    06441500
                        CALL RETURN_STACK_ENTRY(RIGHTOP);                       06442000
                     END;                                                       06442500
                     DO;  /* CHARACTER CONCATENATION  */                        06443000
                        CALL GET_CHAR_OPERANDS;                                 06443500
                        IF (SIZE(LEFTOP) | SIZE(RIGHTOP)) < 0 THEN              06444000
                           TEMPSPACE = 255;                                     06444500
                        ELSE TEMPSPACE = MIN(SIZE(LEFTOP) + SIZE(RIGHTOP), 255);06445000
                        RESULT = GETFREESPACE(CHAR, TEMPSPACE+2);               06446000
                        SIZE(RESULT) = TEMPSPACE;                               06446500
                        CALL CHAR_CALL(OPCODE, RESULT, LEFTOP, RIGHTOP);        06447000
                        CALL RETURN_STACK_ENTRIES(LEFTOP, RIGHTOP);             06447500
                        LASTRESULT = RESULT;                                    06448000
                     END;                                                       06448500
                  END;                                                          06449000
                  DO;  /* BTOC  */                                              06449500
                     CLASS, LITTYPE = BITS;                                     06450000
                     RESULT = NTOC(GET_OPERAND(1), TAG);                        06450500
                  END;                                                          06451000
                  DO;  /* CTOC  */                                              06451500
                     RESULT = GET_OPERAND(1);                                   06452000
                  END;                                                          06452500
                  ;                                                             06453000
                  ;                                                             06453500
                  DO;  /* STOC  */                                              06454000
                     CLASS = SCALAR;                                            06454500
                     RESULT = NTOC(GET_OPERAND(1));                             06455000
                  END;                                                          06455500
                  DO;  /* ITOC  */                                              06456000
                     CLASS = INTEGER;                                           06456500
                     RESULT = NTOC(GET_OPERAND(1));                             06457000
                  END;                                                          06457500
               END;                                                             06458000
               TAG = CHAR;                                                      06458500
               IF SUBCODE > 0 & NUMOP > 1 THEN                                  06459000
                  CALL DO_DSUB;                                                 06459500
               ELSE CALL SETUP_VAC(RESULT);                                     06460000
            END CLASS2;                                                         06460500
   END GEN_CLASS2;                                                              06461000
