 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PROCESSD.xpl
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
 /* PROCEDURE NAME:  PROCESS_DECL_SMRK                                      */
 /* MEMBER NAME:     PROCESSD                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ADD_EXPR_VAR_CELL LABEL                                        */
 /*          EXPR_VAR_CELL     RECORD                                       */
 /*          EXPR_VAR_CELL_OVHD  MACRO                                      */
 /*          EXPR_VAR_CELL_PTR FIXED                                        */
 /*          FIND_STMT_CELL    LABEL                                        */
 /*          LOOP_TEMP         BIT(16)                                      */
 /*          NO_INIT_NAMES     BIT(16)                                      */
 /*          PROCESS_NAME_INIT LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CLASS_BI                                                       */
 /*          CLOSE                                                          */
 /*          DECL_STMT_TYPE                                                 */
 /*          FOREVER                                                        */
 /*          MODF                                                           */
 /*          NAME_INIT_PTR                                                  */
 /*          NILL                                                           */
 /*          OLD_STMT#                                                      */
 /*          STMT_NO                                                        */
 /*          STMT_TYPE                                                      */
 /*          STMT#                                                          */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CELLSIZE                                                       */
 /*          INIT_NAME_HOLDER                                               */
 /*          NAME_INITIALS                                                  */
 /*          STMT_DATA_CELL                                                 */
 /*          STMT_DECL_CELL                                                 */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          DISP                                                           */
 /*          ERRORS                                                         */
 /*          GET_CELL                                                       */
 /*          LOCATE                                                         */
 /* CALLED BY:                                                              */
 /*          GET_NAME_INITIALS                                              */
 /*          PROCESS_HALMAT                                                 */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PROCESS_DECL_SMRK <==                                               */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> DISP                                                            */
 /*     ==> GET_CELL                                                        */
 /*     ==> LOCATE                                                          */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/07/91 TKK  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /*                                                                         */
 /***************************************************************************/
                                                                                00142800
                                                                                00142810
PROCESS_DECL_SMRK:PROCEDURE;                                                    00142820
 /***************************************************************************   00142830
      PROCESS_DECL_SMRK IS CALLED FOR EACH SMRK OR IMRK SEEN. IT DETERMINES IF  00142840
      THIS IS A NEW STATEMENT, IF IT IS IT CREATES A NEW EXPRESSION VARIABLE    00142850
      CELL AND REINITIALIZES ITS COUNTERS AND ADDS ANY NEW INITIALIZED NAME TO  00142860
      NAME_INITIALS. IF IT IS A CONTINUATION, IT ADDS ANY INITIALIZED NAME      00142870
      VARIABLE TO  NAME_INITIALS AND INCREMENTS THE NUMBER OF INITIALIZED NAME  00142880
      VARIABLES SEEN.                                                           00142890
    ***************************************************************************/00142900
      DECLARE NO_INIT_NAMES BIT(16) INITIAL(0),                                 00142910
         LOOP_TEMP BIT(16),EXPR_VAR_CELL_PTR FIXED INITIAL(NILL);               00142920
      BASED EXPR_VAR_CELL RECORD:                                               00142930
            LENGTH BIT(16),                                                     00142940
            NO_VAR_ENTRIES BIT(16),                                             00142950
            ENTRIES BIT(16),                                                    00142960
         END;                                                                   00142970
   DECLARE EXPR_VAR_CELL_OVHD LITERALLY '4';/* LENGTH OF EXPR_VAR_CELL HEADER */00142990
                                                                                00143000
ADD_EXPR_VAR_CELL:PROCEDURE FIXED;                                              00143010
         IF NO_INIT_NAMES ^= 0 THEN DO;                                         00143020
            CELLSIZE = (2*NO_INIT_NAMES)+EXPR_VAR_CELL_OVHD;                    00143030
            EXPR_VAR_CELL_PTR = GET_CELL(CELLSIZE,ADDR(EXPR_VAR_CELL),MODF);    00143040
            EXPR_VAR_CELL.LENGTH = CELLSIZE;                                    00143050
            EXPR_VAR_CELL.NO_VAR_ENTRIES = NO_INIT_NAMES;                       00143060
            DO LOOP_TEMP = 1 TO NO_INIT_NAMES;                                  00143070
               EXPR_VAR_CELL.ENTRIES(LOOP_TEMP-1) = NAME_INITIALS(LOOP_TEMP);   00143080
            END;                                                                00143090
            NO_INIT_NAMES = 0;                                                  00143100
            RETURN EXPR_VAR_CELL_PTR;                                           00143110
         END;                                                                   00143120
         ELSE RETURN NILL;                                                      00143130
         CLOSE ADD_EXPR_VAR_CELL;                                               00143140
                                                                                00143150
PROCESS_NAME_INIT:PROCEDURE;                                                    00143160
            IF INIT_NAME_HOLDER ^= 0 THEN DO;                                   00143170
               NO_INIT_NAMES = NO_INIT_NAMES+1;                                 00143180
               NAME_INITIALS(NO_INIT_NAMES) = INIT_NAME_HOLDER;                 00143190
               INIT_NAME_HOLDER = 0;                                            00143200
            END;                                                                00143210
            CLOSE PROCESS_NAME_INIT;                                            00143220
                                                                                00143230
FIND_STMT_CELL:PROCEDURE FIXED;                                                 00143240
               BASED STNODE FIXED;                                              00143250
               DECLARE CELL_STMT# BIT(16);                                      00143260
                                                                                00143270
               DO FOREVER;                                                      00143280
                  IF STMT_DATA_CELL = NILL                                      00143290
                     THEN CALL ERRORS (CLASS_BI, 218, ' '||STMT#);              00143300
                  CALL LOCATE(STMT_DATA_CELL,ADDR(STNODE),0);                   00143310
                  CELL_STMT# = SHR(STNODE(7),16);                               00143320
                  IF CELL_STMT# >= OLD_STMT# THEN RETURN ADDR(STNODE(0));       00143330
                  STMT_DATA_CELL = STNODE(0);                                   00143340
               END;                                                             00143350
               CLOSE FIND_STMT_CELL;                                            00143360
                                                                                00143370
 /* MAIN CODE FOR PROCESSING DECLARE SMRKS */                                   00143380
                                                                                00143390
               IF STMT# = OLD_STMT# THEN DO;/* STILL SAME STATEMENT */          00143400
                  CALL PROCESS_NAME_INIT;                                       00143410
               END;                                                             00143420
               ELSE DO;                                                         00143430
                  COREWORD(ADDR(STMT_DECL_CELL)) = FIND_STMT_CELL - 4;          00143440
                  IF (((STMT_DECL_CELL.STMT_TYPE & "FF") = DECL_STMT_TYPE) &    00143450
                     (STMT_DECL_CELL.STMT_NO = OLD_STMT#))                      00143460
                     THEN DO;                                                   00143470
                     CALL DISP(MODF);                                           00143480
                     STMT_DECL_CELL.NAME_INIT_PTR = ADD_EXPR_VAR_CELL;          00143490
                  END;                                                          00143500
                  CALL PROCESS_NAME_INIT;                                       00143510
               END;                                                             00143520
               CLOSE PROCESS_DECL_SMRK;                                         00143530
