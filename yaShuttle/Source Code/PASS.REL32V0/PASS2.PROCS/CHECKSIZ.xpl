 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKSIZ.xpl
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
/* PROCEDURE NAME:  CHECKSIZE                                              */
/* MEMBER NAME:     CHECKSIZ                                               */
/* INPUT PARAMETERS:                                                       */
/*          NUMBER            FIXED                                        */
/*          SEVERITY          BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          BIGNUMBER                                                      */
/*          CLASS_BS                                                       */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          ERRORS                                                         */
/* CALLED BY:                                                              */
/*          INITIALISE                                                     */
/*          GENERATE                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> CHECKSIZE <==                                                       */
/*     ==> ERRORS                                                          */
/*         ==> NEXTCODE                                                    */
/*             ==> DECODEPOP                                               */
/*                 ==> FORMAT                                              */
/*                 ==> HEX                                                 */
/*                 ==> POPCODE                                             */
/*                 ==> POPNUM                                              */
/*                 ==> POPTAG                                              */
/*             ==> AUX_SYNC                                                */
/*                 ==> GET_AUX                                             */
/*                 ==> AUX_LINE                                            */
/*                     ==> GET_AUX                                         */
/*                 ==> AUX_OP                                              */
/*                     ==> GET_AUX                                         */
/*         ==> RELEASETEMP                                                 */
/*             ==> SETUP_STACK                                             */
/*             ==> CLEAR_REGS                                              */
/*                 ==> SET_LINKREG                                         */
/*         ==> COMMON_ERRORS                                               */
/***************************************************************************/
/*  REVISION HISTORY :                                                     */
/*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
/*                                                                         */
/*02/13/02 JAC  32V0   DR111386  BIX LOOP INCORRECT FOR CHARACTER(*)       */
/*              17V0                                                       */
/*                                                                         */
/***************************************************************************/
                                                                                00827500
 /*  SUBROUTINE FOR CHECKING FOR TOO MUCH STORAGE  */                           00828000
CHECKSIZE:                                                                      00828500
   PROCEDURE (NUMBER,SEVERITY);                                                 00829000
      DECLARE NUMBER FIXED, SEVERITY BIT(16);                                   00829500
      IF NUMBER>=BIGNUMBER THEN                                                 00830000
         DO CASE SEVERITY-1;                                                    00830500
         CALL ERRORS(CLASS_BS,105);                                             00831000
         CALL ERRORS(CLASS_BS,120);                                             00831500
      END;                                                                      00832000
      IF NUMBER < 0 THEN CALL ERRORS(CLASS_BI,223); /*DR111386*/
   END CHECKSIZE;                                                               00832500
