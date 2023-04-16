 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SAVELITE.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  SAVE_LITERAL                                           */
 /* MEMBER NAME:     SAVELITE                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          N                 BIT(16)                                      */
 /*          M                 BIT(16)                                      */
 /*          PTR               BIT(16)                                      */
 /*          FLAG              BIT(8)                                       */
 /*          L1                FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          LIT_PTR           BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CONST_DW                                                       */
 /*          CLASS_BI                                                       */
 /*          DW                                                             */
 /*          FOR_DW                                                         */
 /*          LIT_TOP_MAX                                                    */
 /*          LIT_TOP                                                        */
 /*          LITERAL1                                                       */
 /*          LITERAL2                                                       */
 /*          LITERAL3                                                       */
 /*          LIT1                                                           */
 /*          LIT2                                                           */
 /*          LIT3                                                           */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          COMM                                                           */
 /*          LIT_PG                                                         */
 /*          LITCHANGE                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERRORS                                                         */
 /*          GET_LITERAL                                                    */
 /* CALLED BY:                                                              */
 /*          COMBINED_LITERALS                                              */
 /*          COMPUTE_DIM_CONSTANT                                           */
 /*          GENERATE_TEMPLATE_LIT                                          */
 /*          GET_LIT_ONE                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SAVE_LITERAL <==                                                    */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> GET_LITERAL                                                     */
 /***************************************************************************/
                                                                                00724000
 /*  CREATE NEW LITERAL TABLE ENTRY AND RETURN PTR  */                          00725000
SAVE_LITERAL:                                                                   00726000
   PROCEDURE(N,M,PTR,FLAG,L1) BIT(16);   /* ALL ARGUMENTS MUST BE               00727000
         PASSED*/                                                               00727010
                                                                                00727020
      DECLARE L1 FIXED;                                                         00727030
      DECLARE  (LIT_PTR,PTR,N,M) BIT(16);                                       00728000
      DECLARE FLAG BIT(8);                                                      00729000
      LITCHANGE = TRUE;                                                         00730000
      LIT_TOP = LIT_TOP + 1;                                                    00731000
      IF LIT_TOP>=LIT_TOP_MAX THEN DO;                                          00732000
         IF FLAG THEN DO;  /* ONLY FROM GET_LIT_ONE */                          00733000
            PTR=0;                                                              00734000
            CALL ERRORS (CLASS_BI, 305);                                        00735000
         END;                                                                   00736000
         ELSE DO;                                                               00737000
            CALL ERRORS (CLASS_BI, 305);                                        00738000
            LIT_PTR=GET_LITERAL(PTR);                                           00739000
            LIT2(LIT_PTR)=DW(N);                                                00740000
            IF M^=0 THEN LIT3(LIT_PTR)=DW(M);                                   00741000
            ELSE LIT3(LIT_PTR)=0;                                               00742000
         END;                                                                   00743000
         FLAG=0;                                                                00744000
         RETURN PTR;                                                            00745000
      END;                                                                      00746000
      LIT_PTR=GET_LITERAL(LIT_TOP);                                             00747000
      LIT1(LIT_PTR) = L1;                                                       00748000
      LIT2(LIT_PTR)=DW(N);                                                      00749000
      IF M^=0 THEN LIT3(LIT_PTR)=DW(M);                                         00750000
      ELSE LIT3(LIT_PTR)=0;                                                     00751000
      FLAG=0;                                                                   00752000
      RETURN LIT_TOP;                                                           00753000
   END SAVE_LITERAL;                                                            00754000
