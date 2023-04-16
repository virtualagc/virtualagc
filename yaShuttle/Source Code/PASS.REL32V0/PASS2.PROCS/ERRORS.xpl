 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ERRORS.xpl
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
/* PROCEDURE NAME:  ERRORS                                                 */
/* MEMBER NAME:     ERRORS                                                 */
/* INPUT PARAMETERS:                                                       */
/*          CLASS             BIT(16)                                      */
/*          NUM               BIT(16)                                      */
/*          TEXT              CHARACTER;                                   */
/* LOCAL DECLARATIONS:                                                     */
/*          SEVERITY          BIT(16)                                      */
/*          AST               CHARACTER;                                   */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          BLANK                                                          */
/*          CTR                                                            */
/*          ERRLIM                                                         */
/*          GENERATING                                                     */
/*          LINE#                                                          */
/*          SMRK_CTR                                                       */
/*          SRCERR                                                         */
/*          SUBMONITOR                                                     */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          ERROR#                                                         */
/*          MAX_SEVERITY                                                   */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          NEXTCODE                                                       */
/*          COMMON_ERRORS                                                  */
/*          RELEASETEMP                                                    */
/* CALLED BY:                                                              */
/*          CHECKSIZE                                                      */
/*          EMIT_ADDRS                                                     */
/*          GENERATE                                                       */
/*          GETSTATNO                                                      */
/*          INITIALISE                                                     */
/*          OBJECT_CONDENSER                                               */
/*          OBJECT_GENERATOR                                               */
/*          OPTIMISE                                                       */
/*          PRINTSUMMARY                                                   */
/*          SET_MASKING_BIT                                                */
/*          TERMINATE                                                      */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> ERRORS <==                                                          */
/*     ==> NEXTCODE                                                        */
/*         ==> DECODEPOP                                                   */
/*             ==> FORMAT                                                  */
/*             ==> HEX                                                     */
/*             ==> POPCODE                                                 */
/*             ==> POPNUM                                                  */
/*             ==> POPTAG                                                  */
/*         ==> AUX_SYNC                                                    */
/*             ==> GET_AUX                                                 */
/*             ==> AUX_LINE                                                */
/*                 ==> GET_AUX                                             */
/*             ==> AUX_OP                                                  */
/*                 ==> GET_AUX                                             */
/*     ==> RELEASETEMP                                                     */
/*         ==> SETUP_STACK                                                 */
/*         ==> CLEAR_REGS                                                  */
/*             ==> SET_LINKREG                                             */
/*     ==> COMMON_ERRORS                                                   */
/***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 DKB  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /*                                                                         */
 /* 10/29/93 TEV  26V0  DR108630 OC4 ABEND OCCURS ON ILLEGAL DOWNGRADE      */
 /*               10V0                                                      */
 /*                                                                         */
 /* 07/14/99 DCP  30V0  CR12214  USE THE SAFEST %MACRO THAT WORKS           */
 /*               15V0                                                      */
 /*                                                                         */
 /***************************************************************************/
                                                                                00798000
   DECLARE DWN_STMT(1) LITERALLY 'DOWN_INFO(%1%).DOWN_STMT';                    00798010
   DECLARE DWN_ERR(1)  LITERALLY 'DOWN_INFO(%1%).DOWN_ERR';                     00798020
   DECLARE DWN_CLS(1)  LITERALLY 'DOWN_INFO(%1%).DOWN_CLS';                     00798030
/********************* DR108630 - TEV - 10/29/93 *********************/
   DECLARE DWN_UNKN(1) LITERALLY 'DOWN_INFO(%1%).DOWN_UNKN';
/********************* END DR108630 **********************************/
   DECLARE DWN_VER(1)  LITERALLY 'DOWN_INFO(%1%).DOWN_VER';                     00798040
   DECLARE SEVERITY BIT(16);                                                    00798050
 /*  INCLUDE TABLE FOR DOWNGRADE:  $%DWNTABLE   */                              00798060
 /*  INCLUDE DOWNGRADE SUMMARY:    $%DOWNSUM    */                              00798070
 /*  INCLUDE COMMON ERROR HANDLER: $%CERRORS    */                              00798080
                                                                                00798500
 /* NEW SUBROUTINE FOR HANDLING ERRORS */                                       00799000
ERRORS:PROCEDURE(CLASS,NUM,TEXT);                                               00799500
    DECLARE (CLASS, SEVERITY, NUM) BIT(16);                                     00800000
    DECLARE (TEXT) CHARACTER;                                                   00800010
    DECLARE AST CHARACTER INITIAL('***** ');                                    00801500
    IF CLASS <= CLASS_ZS THEN DO;                     /*CR12214*/
      ERROR# = ERROR# + 1;                                                      00802000
      SEVERITY = COMMON_ERRORS (CLASS, NUM, TEXT, ERROR#, LINE#);               00802010
      IF SEVERITY > MAX_SEVERITY THEN                                           00802020
         MAX_SEVERITY = SEVERITY;                                               00802030
      IF SEVERITY^=0 THEN DO;                                                   00819500
         IF (SEVERITY=1)&(ERROR#<ERRLIM)&GENERATING THEN DO;                    00820000
            CALL RELEASETEMP;                                                   00820500
            OUTPUT=BLANK;                                                       00821500
            DO WHILE CTR<SMRK_CTR;                                              00822000
               CALL NEXTCODE;                                                   00822500
            END;                                                                00823000
            GO TO SRCERR;                                                       00823500
         END;                                                                   00824000
         ELSE DO;                                                               00824500
            OUTPUT=AST||'CONVERSION ABANDONED';                                 00825000
            IF NUM = 504 THEN RETURN;                                           00825500
            GO TO SUBMONITOR;                                                   00825510
         END;                                                                   00826000
      END;                                                                      00826500
    END;                                                            /*CR12214*/
    ELSE DO;                                                        /*CR12214*/
      NEXT_ELEMENT(ADVISE);                                         /*CR12214*/
      ADV_STMT#(RECORD_USED(ADVISE)-1) = LINE#;                     /*CR12214*/
      ADV_ERROR#(RECORD_USED(ADVISE)-1) =                           /*CR12214*/
                       SUBSTR(ERROR_CLASSES,SHL(CLASS-1,1),2)||NUM; /*CR12214*/
    END;                                                            /*CR12214*/
   END ERRORS;                                                                  00827000
