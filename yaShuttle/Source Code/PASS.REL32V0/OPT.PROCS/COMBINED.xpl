 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   COMBINED.xpl
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
 /* PROCEDURE NAME:  COMBINED_LITERALS                                      */
 /* MEMBER NAME:     COMBINED                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          FLAG              BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CNTL_BIT          BIT(8)                                       */
 /*          CSE_BASE          FIXED                                        */
 /*          INX               BIT(16)                                      */
 /*          LIT_PTR           BIT(16)                                      */
 /*          MODE              BIT(16)                                      */
 /*          OPT               BIT(16)                                      */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CONST_DW                                                       */
 /*          CLASS_BI                                                       */
 /*          CSE                                                            */
 /*          CSE_FOUND_INX                                                  */
 /*          CSE2                                                           */
 /*          DW                                                             */
 /*          END_OF_NODE                                                    */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          LIT_PG                                                         */
 /*          LITERAL2                                                       */
 /*          LITERAL3                                                       */
 /*          LIT2                                                           */
 /*          LIT3                                                           */
 /*          OPTYPE                                                         */
 /*          WATCH                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_DW                                                         */
 /*          MSG1                                                           */
 /*          MSG2                                                           */
 /*          TEMP                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERRORS                                                         */
 /*          FILL_DW                                                        */
 /*          GET_LITERAL                                                    */
 /*          HEX                                                            */
 /*          LIT_ARITHMETIC                                                 */
 /*          MESSAGE_FORMAT                                                 */
 /*          SAVE_LITERAL                                                   */
 /* CALLED BY:                                                              */
 /*          COLLAPSE_LITERALS                                              */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> COMBINED_LITERALS <==                                               */
 /*     ==> HEX                                                             */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> MESSAGE_FORMAT                                                  */
 /*         ==> HEX                                                         */
 /*     ==> GET_LITERAL                                                     */
 /*     ==> FILL_DW                                                         */
 /*         ==> GET_LITERAL                                                 */
 /*     ==> SAVE_LITERAL                                                    */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> GET_LITERAL                                                 */
 /*     ==> LIT_ARITHMETIC                                                  */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /***************************************************************************/
                                                                                00788000
 /* FOLD LITERAL CONSTANTS  */                                                  00789000
COMBINED_LITERALS:                                                              00790000
   PROCEDURE(FLAG);                                                             00791000
      DECLARE CSE_BASE FIXED;                                                   00792000
      DECLARE (CNTL_BIT,FLAG) BIT(8);                                           00793000
      DECLARE (OPT,MODE,LIT_PTR,PTR,INX) BIT(16);                               00794000
      OPT=(OPTYPE & "F")-11;                                                    00795000
      IF OPT^=0 THEN CSE_BASE="41100000";  /* MULT/DIV BASE */                  00796000
      ELSE CSE_BASE="00000000";  /* ADD'N/SUB'N BASE */                         00797000
      DW(0) = CSE_BASE;                                                         00798000
      DW(1) = 0;                                                                00799000
      DO FOR INX=1 TO CSE_FOUND_INX-1;                                          00800000
         LIT_PTR=CSE2(INX);                                                     00801000
         CALL FILL_DW(LIT_PTR);                                                 00802000
         IF WATCH THEN OUTPUT = 'LIT(' || LIT_PTR || '):  '||                   00803000
            HEX(DW(2),8)||HEX(DW(3),8);                                         00804000
         IF OPT^=0 THEN MODE=3;                                                 00805000
         ELSE MODE=1;                                                           00806000
         CNTL_BIT=(SHR(CSE(INX),20) & "1");                                     00807000
         IF (^FLAG & CNTL_BIT^=0) THEN MODE=MODE+1;                             00808000
         IF LIT_ARITHMETIC(MODE) THEN DO;                                       00809000
            PTR=0;                                                              00810000
            CALL ERRORS (CLASS_BI, 304);                                        00811000
            RETURN PTR;                                                         00812000
         END;                                                                   00813000
         IF CSE(INX+1)=END_OF_NODE THEN DO;                                     00814000
            PTR=SAVE_LITERAL(0,1,LIT_PTR,0,1);                                  00815000
            IF WATCH THEN DO;                                                   00816000
               TEMP = GET_LITERAL(PTR);                                         00817000
               MSG1=MESSAGE_FORMAT(LIT2(TEMP));                                 00818000
               MSG2=MESSAGE_FORMAT(LIT3(TEMP));                                 00819000
               OUTPUT='PTR TO LIT=' || PTR || ',LIT VALUE=' || MSG1 || MSG2;    00820000
            END;                                                                00821000
         END;                                                                   00822000
      END;  /* DO FOR INX  */                                                   00823000
      FLAG=FALSE;                                                               00824000
      RETURN PTR;                                                               00825000
   END COMBINED_LITERALS;                                                       00826000
