 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FORMATNA.xpl
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
 /* PROCEDURE NAME:  FORMAT_NAME_TERM_CELLS                                 */
 /* MEMBER NAME:     FORMATNA                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          SYMB#             BIT(16)                                      */
 /*          PTR               FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          #SYTS             BIT(16)                                      */
 /*          DONE              LABEL                                        */
 /*          DONETOO           LABEL                                        */
 /*          FIRSTWORD         BIT(16)                                      */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          PTR_TEMP          FIXED                                        */
 /*          VARNAMES(100)     CHARACTER;                                   */
 /*          VMEM_F            FIXED                                        */
 /*          VMEM_H            BIT(16)                                      */
 /*          WORDTYPE          BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CLASS_BI                                                       */
 /*          FOREVER                                                        */
 /*          LINELENGTH                                                     */
 /*          MAXLINES                                                       */
 /*          MSG                                                            */
 /*          SYM_NAME                                                       */
 /*          SYM_TAB                                                        */
 /*          SYT_NAME                                                       */
 /*          TRUE                                                           */
 /*          VMEM_LOC_ADDR                                                  */
 /*          X10                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LEVEL                                                          */
 /*          PTR_INX                                                        */
 /*          S                                                              */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERRORS                                                         */
 /*          FLUSH                                                          */
 /*          FORMAT_VAR_REF_CELL                                            */
 /*          HEX                                                            */
 /*          LOCATE                                                         */
 /* CALLED BY:                                                              */
 /*          FORMAT_SYT_VPTRS                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> FORMAT_NAME_TERM_CELLS <==                                          */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> LOCATE                                                          */
 /*     ==> HEX                                                             */
 /*     ==> FLUSH                                                           */
 /*     ==> FORMAT_VAR_REF_CELL                                             */
 /*         ==> LOCATE                                                      */
 /*         ==> HEX                                                         */
 /*         ==> FLUSH                                                       */
 /*         ==> STACK_PTR                                                   */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /***************************************************************************/
                                                                                00295100
 /* FORMATS AND PRINTS A CHAIN OF NAME TERMINAL INITIALIZATION CELLS */         00295200
FORMAT_NAME_TERM_CELLS:                                                         00295300
   PROCEDURE (SYMB#,PTR);                                                       00295400
      DECLARE (#SYTS,SYMB#,I,J,K,WORDTYPE,FIRSTWORD) BIT(16);                   00295500
      DECLARE (PTR,PTR_TEMP) FIXED;                                             00295501
      DECLARE VARNAMES(100) CHARACTER;                                          00295502
      BASED VMEM_F FIXED, VMEM_H BIT(16);                                       00295503
                                                                                00295600
      OUTPUT = X10||HEX(PTR,8)||' --> '||                                       00295700
         'INITIAL VALUES FOR NAME TERMINALS IN STRUCTURE: '||SYT_NAME(SYMB#);   00295800
      DO WHILE PTR ^= 0;                                                        00295900
         CALL LOCATE(PTR,ADDR(VMEM_F),0);                                       00296000
         PTR = VMEM_F(1);                                                       00296100
         COREWORD(ADDR(VMEM_H)) = VMEM_LOC_ADDR;                                00296200
         K, PTR_INX = 0;                                                        00296300
         LEVEL = 1;                                                             00296400
         #SYTS = VMEM_H(1);                                                     00296600
         FIRSTWORD = (#SYTS+5) & "FFFE";                                        00296700
         S = SYT_NAME(VMEM_H(4));                                               00296800
         DO J = 5 TO #SYTS+3;                                                   00296900
            S = S || '.' || SYT_NAME(VMEM_H(J));                                00297000
         END;                                                                   00297100
         CALL FLUSH(0);                                                         00297200
         S = '';                                                                00297300
         LEVEL = 2;                                                             00297500
         J = FIRSTWORD;                                                         00297600
         IF VMEM_H(J) = 3 THEN DO;                                              00297601
            S = 'ALL COPIES NULL.';                                             00297602
            CALL FLUSH(0);                                                      00297603
            GO TO DONETOO;                                                      00297604
         END;                                                                   00297605
         DO FOREVER;                                                            00297700
            WORDTYPE = VMEM_H(J);                                               00297800
            IF WORDTYPE<0 | WORDTYPE>3 THEN DO;                                 00297801
               CALL ERRORS (CLASS_BI, 217);                                     00297802
               GO TO DONE;                                                      00297803
            END;                                                                00297804
            IF LENGTH(S(K)) > LINELENGTH THEN                                   00297900
               IF K >= MAXLINES THEN DO;                                        00297910
               CALL FLUSH(K,1);                                                 00297920
               K = 0;                                                           00297930
            END;                                                                00297940
            ELSE K = K + 1;                                                     00297950
            DO CASE WORDTYPE;                                                   00298000
               DO;                                                              00298100
                  PTR_TEMP = VMEM_F(SHR(J+2,1));                                00298101
                  IF PTR_TEMP > 0 THEN DO;                                      00298102
 /* GET VARIABLE USED TO INITIAL NAME VARIABLE.                                 00298201
                    NOTE THAT THIS SAME PROCEDURE IS IN PHASE 4 */              00298211
                     CALL FORMAT_VAR_REF_CELL(PTR_TEMP,1);                      00298221
                     S(K) = S(K)||VMEM_H(J+1)||':'||MSG||',';                   00298231
                  END;                                                          00298300
                 ELSE S(K) = S(K)||VMEM_H(J+1)||':'||SYT_NAME(VMEM_H(J+3))||',';00298310
                  J = J + 4;                                                    00298320
               END;                                                             00298500
               DO;                                                              00298600
                  S(K) = S(K)||'('||VMEM_H(J+2)||'#,+'||VMEM_H(J+3)||')(';      00298900
                  J = J + 4;                                                    00299000
               END;                                                             00299100
               DO;                                                              00299200
                  IF BYTE(S(K),LENGTH(S(K))-1) = BYTE(',') THEN                 00299300
                     S(K) = SUBSTR(S(K),0,LENGTH(S(K))-1);                      00299400
                  S(K) = S(K) || '),';                                          00299500
                  J = J + 2;                                                    00299600
               END;                                                             00299700
               IF VMEM_H(J+1) = 0 THEN GO TO DONE;                              00299800
               ELSE DO;                                                         00299810
                  CALL LOCATE(VMEM_F(SHR(J+2,1)),ADDR(VMEM_F),0);               00299820
                  COREWORD(ADDR(VMEM_H)) = VMEM_LOC_ADDR;                       00299830
                  J = 2;                                                        00299840
               END;                                                             00299850
            END;                                                                00299900
         END;                                                                   00300000
DONE:                                                                           00300100
         IF BYTE(S(K),LENGTH(S(K))-1) = BYTE(',') THEN                          00300101
            S(K) = SUBSTR(S(K),0,LENGTH(S(K))-1);                               00300102
         CALL FLUSH(K,1);                                                       00300103
 /* J = 1;                                                                      00300200
         K = PTR_INX;                                                           00300300
         DO WHILE J < K;                                                        00300400
            PTR_TEMP = EXP_PTRS(J);                                             00300500
            EXP_PTRS(J) = EXP_PTRS(K);                                          00300600
            EXP_PTRS(K) = PTR_TEMP;                                             00300700
            J = J + 1;                                                          00300800
            K = K - 1;                                                          00300900
         END;                                                                   00301000
         CALL FORMAT_CELL_TREE; */                                              00301500
DONETOO:                                                                        00301600
      END;                                                                      00301800
   END FORMAT_NAME_TERM_CELLS;                                                  00301900
