 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CREATEST.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  CREATE_STMT                                            */
 /* MEMBER NAME:     CREATEST                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CELL_STMT#        BIT(16)                                      */
 /*          HCELL_HEADER      MACRO                                        */
 /*          HMAT_PTR          MACRO                                        */
 /*          NO_OP_LST         MACRO                                        */
 /*          NODE              FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          #CELLS                                                         */
 /*          CLASS_BI                                                       */
 /*          FINAL_OP                                                       */
 /*          FOREVER                                                        */
 /*          MODF                                                           */
 /*          NILL                                                           */
 /*          OLD_STMT#                                                      */
 /*          SMRK_LIST                                                      */
 /*          STMT#                                                          */
 /*          TOTAL_HMAT_BYTES                                               */
 /*          TRUE                                                           */
 /*          XREC_WORD                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          COMM                                                           */
 /*          STMT_DATA_CELL                                                 */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          DISP                                                           */
 /*          ERRORS                                                         */
 /*          LOCATE                                                         */
 /* CALLED BY:                                                              */
 /*          KEEP_POINTERS                                                  */
 /*          PROCESS_HALMAT                                                 */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CREATE_STMT <==                                                     */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> DISP                                                            */
 /*     ==> LOCATE                                                          */
 /***************************************************************************/
                                                                                00139520
 /* PROCEDURE TO ASSOCIATE SMRK_LIST WITH A STATEMENT */                        00139530
CREATE_STMT:                                                                    00139540
   PROCEDURE;                                                                   00139550
      BASED NODE FIXED;                                                         00139560
      DECLARE CELL_STMT# BIT(16);                                               00139570
      DECLARE NO_OP_LST LITERALLY '((NODE(1)=XREC_WORD)&(NODE(2)=NILL))',       00139580
         HCELL_HEADER LITERALLY '(SHL(#CELLS-1,16)|FINAL_OP)',                  00139590
         HMAT_PTR LITERALLY '-1';                                               00139600
      IF SMRK_LIST = NILL THEN RETURN; /* NO HALMAT FOR THIS STMT */            00139610
      CALL LOCATE(SMRK_LIST,ADDR(NODE),MODF);                                   00139620
      IF NO_OP_LST THEN RETURN;  /* SMRK_LIST IS AN EMPTY LIST */               00139630
      TOTAL_HMAT_BYTES = TOTAL_HMAT_BYTES + (#CELLS*4);                         00139640
      NODE(0) = HCELL_HEADER;                                                   00139650
      DO FOREVER;                                                               00139660
         IF STMT_DATA_CELL = NILL                                               00139670
            THEN CALL ERRORS (CLASS_BI, 222, ' '||STMT#);                       00139680
         CALL LOCATE(STMT_DATA_CELL,ADDR(NODE),0);                              00139690
         CELL_STMT# = SHR(NODE(7),16);                                          00139700
         IF CELL_STMT# = OLD_STMT#                                              00139720
            THEN DO;                                                            00139730
            CALL DISP(MODF);                                                    00139740
            NODE(HMAT_PTR) = SMRK_LIST;                                         00139750
            RETURN;                                                             00139760
         END;                                                                   00139770
         STMT_DATA_CELL = NODE(0);                                              00139780
      END;                                                                      00139790
   END CREATE_STMT;                                                             00139800
