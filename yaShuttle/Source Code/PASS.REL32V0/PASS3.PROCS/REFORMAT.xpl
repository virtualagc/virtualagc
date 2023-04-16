 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   REFORMAT.xpl
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
 /* PROCEDURE NAME:  REFORMAT_HALMAT                                        */
 /* MEMBER NAME:     REFORMAT                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          #HMAT_WORDS       MACRO                                        */
 /*          HCELL             BIT(16)                                      */
 /*          HLOC              FIXED                                        */
 /*          HMAT_BLK_SZ       MACRO                                        */
 /*          HMAT_PTR          FIXED                                        */
 /*          I                 BIT(16)                                      */
 /*          INITIAL_CASE      BIT(8)                                       */
 /*          LIMIT             BIT(16)                                      */
 /*          LINK_SPACE        MACRO                                        */
 /*          LINKCELL          FIXED                                        */
 /*          MOD_HMAT(1)       LABEL                                        */
 /*          RET_LOC           FIXED                                        */
 /*          SDF_PTR           FIXED                                        */
 /*          SIZE              BIT(16)                                      */
 /*          SLOC              FIXED                                        */
 /*          START             MACRO                                        */
 /*          TMP_LOC           FIXED                                        */
 /*          WORDS_IN_BLK      MACRO                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          MODF                                                           */
 /*          NILL                                                           */
 /*          PAGE_SIZE                                                      */
 /*          POINTER_PREFIX                                                 */
 /*          RELS                                                           */
 /*          RESV                                                           */
 /*          SORTING                                                        */
 /*          SYM_SORT1                                                      */
 /*          SYT_SORT1                                                      */
 /*          TRUE                                                           */
 /*          XREC_WORD                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          LOCATE                                                         */
 /*          GET_DATA_CELL                                                  */
 /*          MIN                                                            */
 /*          PTR_LOCATE                                                     */
 /*          P3_PTR_LOCATE                                                  */
 /* CALLED BY:                                                              */
 /*          GET_STMT_DATA                                                  */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> REFORMAT_HALMAT <==                                                 */
 /*     ==> MIN                                                             */
 /*     ==> PTR_LOCATE                                                      */
 /*     ==> LOCATE                                                          */
 /*     ==> P3_PTR_LOCATE                                                   */
 /*         ==> HEX8                                                        */
 /*         ==> ZERO_CORE                                                   */
 /*         ==> P3_DISP                                                     */
 /*         ==> PAGING_STRATEGY                                             */
 /*     ==> GET_DATA_CELL                                                   */
 /*         ==> P3_GET_CELL                                                 */
 /*             ==> P3_DISP                                                 */
 /*             ==> P3_LOCATE                                               */
 /*                 ==> P3_PTR_LOCATE                                       */
 /*                     ==> HEX8                                            */
 /*                     ==> ZERO_CORE                                       */
 /*                     ==> P3_DISP                                         */
 /*                     ==> PAGING_STRATEGY                                 */
 /*             ==> PUTN                                                    */
 /*                 ==> MOVE                                                */
 /*                 ==> P3_PTR_LOCATE                                       */
 /*                     ==> HEX8                                            */
 /*                     ==> ZERO_CORE                                       */
 /*                     ==> P3_DISP                                         */
 /*                     ==> PAGING_STRATEGY                                 */
 /***************************************************************************/
                                                                                00208480
                                                                                00208490
REFORMAT_HALMAT:                                                                00208500
   PROCEDURE(LOC) FIXED;                                                        00208510
      DECLARE (LOC,RET_LOC,HLOC,SLOC,TMP_LOC,LINKCELL) FIXED;                   00208520
      BASED (HMAT_PTR,SDF_PTR) FIXED;                                           00208530
      DECLARE (SIZE,HCELL,LIMIT,I) BIT(16),                                     00208540
         INITIAL_CASE BIT(1),                                                   00208550
         #HMAT_WORDS LITERALLY 'SHR(HMAT_PTR,16)', /* # OF HMAT WORDS */        00208560
         HMAT_BLK_SZ LITERALLY 'MIN(SIZE*4,PAGE_SIZE)', /* BYTES IN CELL */     00208570
         WORDS_IN_BLK LITERALLY 'MIN(SIZE,PAGE_SIZE/4)',  /* WORDS IN CELL */   00208580
         LINK_SPACE LITERALLY '(SIZE>420)*2', /*WORDS USED FOR LINKING BLKS */  00208590
         START LITERALLY 'INITIAL_CASE'; /* START AT SDF_PTR(0) IF NO HEADER */ 00208600
                                                                                00208610
MOD_HMAT:                                                                       00208620
      PROCEDURE(CELL) FIXED;                                                    00208630
         DECLARE CELL FIXED,                                                    00208640
            SYT_OPERAND(1) LITERALLY    '(HMAT_PTR(%1%)                         00208650
                                         &((SHR(HMAT_PTR(%1%),4)&"F")=1))',     00208660
            OPERAND_FIELD(1) LITERALLY 'SHR(HMAT_PTR(%1%),16)',                 00208670
            SUB_OPRND(1) LITERALLY '(SHL(%1%,16)|((HMAT_PTR(CELL)&"FFFF")))';   00208680
         IF SYT_OPERAND(CELL)                                                   00208690
            THEN RETURN SUB_OPRND(SYT_SORT1(OPERAND_FIELD(CELL)));              00208700
         RETURN HMAT_PTR(CELL);                                                 00208710
      END MOD_HMAT;                                                             00208720
                                                                                00208730
      IF LOC = NILL THEN RETURN NILL;  /* NO HALMAT */                          00208740
      HLOC = LOC;                                                               00208750
      CALL LOCATE(HLOC,ADDR(HMAT_PTR),RESV);                                    00208760
      SIZE = #HMAT_WORDS+1; /* WORDS OF HMAT PLUS HEADER WORD */                00208770
      INITIAL_CASE = TRUE;                                                      00208780
      HCELL = 1;                                                                00208790
      DO WHILE SIZE > 0;                                                        00208800
         TMP_LOC = SLOC;                                                        00208810
         SLOC = GET_DATA_CELL(HMAT_BLK_SZ,ADDR(SDF_PTR),RESV|MODF);             00208820
         IF INITIAL_CASE                                                        00208830
            THEN DO;                                                            00208840
            RET_LOC = SLOC;                                                     00208850
            SDF_PTR(0) = HMAT_PTR(0); /* HEADER WORD */                         00208860
         END;                                                                   00208870
         ELSE DO;                                                               00208880
            COREWORD(LINKCELL) = SLOC;                                          00208890
            CALL P3_PTR_LOCATE(TMP_LOC,RELS);                                   00208900
         END;                                                                   00208910
         LIMIT = WORDS_IN_BLK-LINK_SPACE;                                       00208920
         SIZE = SIZE-LIMIT;                                                     00208930
         DO I = START TO LIMIT-1;                                               00208940
            INITIAL_CASE = FALSE;                                               00208950
            IF HMAT_PTR(HCELL) = XREC_WORD                                      00208960
               THEN DO;                                                         00208970
               TMP_LOC = HLOC;                                                  00208980
               HLOC = HMAT_PTR(HCELL+1);                                        00208990
               CALL PTR_LOCATE(TMP_LOC,RELS);                                   00209000
               CALL LOCATE(HLOC,ADDR(HMAT_PTR),RESV);                           00209010
               HCELL = 0;                                                       00209020
            END;                                                                00209030
            SDF_PTR(I) = MOD_HMAT(HCELL);                                       00209040
            HCELL = HCELL+1;                                                    00209050
         END; /* FOR LOOP */                                                    00209060
         IF SIZE > 0                                                            00209070
            THEN DO;                                                            00209080
            SDF_PTR(I) = POINTER_PREFIX;                                        00209090
            LINKCELL = ADDR(SDF_PTR(I+1));                                      00209100
         END;                                                                   00209110
      END; /* WHILE LOOP */                                                     00209120
      CALL P3_PTR_LOCATE(SLOC,RELS);                                            00209130
      CALL PTR_LOCATE(HLOC,RELS);                                               00209140
      RETURN RET_LOC;                                                           00209150
   END REFORMAT_HALMAT;                                                         00209160
