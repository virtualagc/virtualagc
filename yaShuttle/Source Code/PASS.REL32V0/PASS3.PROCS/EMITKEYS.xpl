 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EMITKEYS.xpl
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
 /* PROCEDURE NAME:  EMIT_KEY_SDF_INFO                                      */
 /* MEMBER NAME:     EMITKEYS                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CHAR_STRING       CHARACTER;                                   */
 /*          I                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          KLIM              BIT(16)                                      */
 /*          L                 BIT(16)                                      */
 /*          NODE_H            BIT(16)                                      */
 /*          PTR               FIXED                                        */
 /*          TEMP              FIXED                                        */
 /*          TS(10)            CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          #PROCS                                                         */
 /*          #SYMBOLS                                                       */
 /*          COMM                                                           */
 /*          FIRST_STMT                                                     */
 /*          LAST_STMT                                                      */
 /*          LOC_ADDR                                                       */
 /*          PROC_TAB1                                                      */
 /*          PROC_TAB5                                                      */
 /*          PROC_TAB8                                                      */
 /*          SORTING                                                        */
 /*          SRN_FLAG                                                       */
 /*          SYM_SCOPE                                                      */
 /*          SYM_SORT2                                                      */
 /*          SYM_SORT3                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_SCOPE                                                      */
 /*          SYT_SORT2                                                      */
 /*          SYT_SORT3                                                      */
 /*          X1                                                             */
 /*          X10                                                            */
 /*          X2                                                             */
 /*          X20                                                            */
 /*          X30                                                            */
 /*          X5                                                             */
 /*          X6                                                             */
 /*          X7                                                             */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          BLOCK_TO_PTR                                                   */
 /*          FORMAT                                                         */
 /*          HEX                                                            */
 /*          HEX8                                                           */
 /*          P3_LOCATE                                                      */
 /*          STMT_TO_PTR                                                    */
 /*          SYMB_TO_PTR                                                    */
 /*          SYT_NAME1                                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> EMIT_KEY_SDF_INFO <==                                               */
 /*     ==> FORMAT                                                          */
 /*     ==> HEX                                                             */
 /*     ==> HEX8                                                            */
 /*     ==> SYT_NAME1                                                       */
 /*     ==> STMT_TO_PTR                                                     */
 /*     ==> SYMB_TO_PTR                                                     */
 /*     ==> BLOCK_TO_PTR                                                    */
 /*     ==> P3_LOCATE                                                       */
 /*         ==> P3_PTR_LOCATE                                               */
 /*             ==> HEX8                                                    */
 /*             ==> ZERO_CORE                                               */
 /*             ==> P3_DISP                                                 */
 /*             ==> PAGING_STRATEGY                                         */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/07/91 DKB  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /*                                                                         */
 /***************************************************************************/
                                                                                00219600
 /* ROUTINE TO PRINT USEFUL SDF INFORMATION -- TO HELP WITH HEX LIST */         00219700
                                                                                00219710
EMIT_KEY_SDF_INFO:                                                              00219720
   PROCEDURE;                                                                   00219730
      DECLARE (PTR,TEMP) FIXED,                                                 00219740
         (I,K,L,KLIM) BIT(16),                                                  00219750
         TS(10) CHARACTER, CHAR_STRING CHARACTER;                               00219760
      BASED NODE_H BIT(16);                                                     00221200
                                                                                00221300
      CHAR_STRING = ' DEC   HEX  -HEX    PTR      BLOCK NAME '||                00223600
         '                     PTR    BLK#    SYMBOL NAME';                     00223700
      CHAR_STRING = CHAR_STRING || X20 ||                                       00223900
         'PTR      SRN   COUNT';                                                00224000
      OUTPUT(1) = '2'||CHAR_STRING;                                             00224100
      OUTPUT = CHAR_STRING;                                                     00224200
      OUTPUT = X1;                                                              00224300
      KLIM = LAST_STMT;                                                         00224400
      IF KLIM < #SYMBOLS THEN KLIM = #SYMBOLS;                                  00224500
      DO K = 1 TO KLIM;                                                         00224600
         TS = FORMAT(K,4)||X2;                                                  00224700
         TS(1) = HEX(K,4)||X2;                                                  00224800
         TEMP = (-K) & "FFFF";                                                  00224900
         TS(10) = HEX(TEMP,4) || X2;                                            00225000
         IF #PROCS >= K THEN DO;                                                00225100
            PTR = BLOCK_TO_PTR(K);                                              00225200
            TS(2) = HEX8(PTR)||X2;                                              00225300
            I = PROC_TAB8(PROC_TAB5(K));                                        00225400
            I = SYT_SORT2(PROC_TAB1(I));                                        00225500
            TS(3) = SYT_NAME1(I)||X2;                                           00225600
         END;                                                                   00225700
         ELSE DO;                                                               00225800
            TS(2) = X10;                                                        00225900
            TS(3) = X30;                                                        00226000
         END;                                                                   00226100
         IF #SYMBOLS >= K THEN DO;                                              00226200
            PTR = SYMB_TO_PTR(K);                                               00226300
            TS(4) = HEX8(PTR)||X2;                                              00226400
            L = SYT_SCOPE(SYT_SORT2(K));                                        00226500
            L = SYT_SORT2(PROC_TAB1(L));                                        00226600
            TS(9) = HEX(SYT_SORT3(L),4)||X2;                                    00226700
            TS(5) = SYT_NAME1(SYT_SORT2(K))||X2;                                00226800
         END;                                                                   00226900
         ELSE DO;                                                               00227000
            TS(4) = X10;                                                        00227100
            TS(9) = X6;                                                         00227200
            TS(5) = X30;                                                        00227300
         END;                                                                   00227400
         IF (K >= FIRST_STMT) & (K <= LAST_STMT) THEN DO;                       00227500
            PTR = STMT_TO_PTR(K);                                               00227600
            TS(6) = HEX8(PTR)||X2;                                              00227700
            IF SRN_FLAG THEN DO;                                                00227800
               CALL P3_LOCATE(PTR,ADDR(NODE_H),0);                              00227900
               COREWORD(ADDR(TS(7))) = LOC_ADDR + "05000000";                   00228000
               TS(7) = TS(7)||X1;                                               00228100
               TS(8) = FORMAT(NODE_H(3),5);                                     00228200
            END;                                                                00228300
            ELSE DO;                                                            00228400
               TS(7) = X7;                                                      00228500
               TS(8) = X5;                                                      00228600
            END;                                                                00228700
         END;                                                                   00228800
         ELSE DO;                                                               00228900
            TS(6) = X10;                                                        00229000
            TS(7) = X7;                                                         00229100
            TS(8) = X5;                                                         00229200
         END;                                                                   00229300
         OUTPUT = TS||TS(1)||TS(10)||                                           00229400
            TS(2)||                                                             00229500
            TS(3)||TS(4)||TS(9)||TS(5)                                          00229600
            ||TS(6)||TS(7)||TS(8);                                              00229700
      END;                                                                      00229800
   END EMIT_KEY_SDF_INFO;                                                       00229900
