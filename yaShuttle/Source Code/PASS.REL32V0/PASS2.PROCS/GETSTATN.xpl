 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETSTATN.xpl
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
/* PROCEDURE NAME:  GETSTATNO                                              */
/* MEMBER NAME:     GETSTATN                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          BIT(16)                                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          STATNOLIMIT                                                    */
/*          CLASS_BS                                                       */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          STATNO                                                         */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          ERRORS                                                         */
/* CALLED BY:                                                              */
/*          INITIALISE                                                     */
/*          GENERATE                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> GETSTATNO <==                                                       */
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
/***************************************************************************/
/*  REVISION HISTORY :                                                     */
/*  ------------------                                                     */
/*DATE     NAME  REL   CR/DR NUMBER AND TITLE                              */
/*                                                                         */
/*03/30/04 TKN   32V0  13670  ENHANCE & UPDATE INFORMATION ON THE USAGE    */
/*               17V0         OF TYPE 2 OPTIONS                            */
/***************************************************************************/   00862500
 /* SUBROUTINE FOR GETTING A FREE STATEMENT NUMBER */                           00863000
GETSTATNO:                                                                      00863500
   PROCEDURE BIT(16);                                                           00864000

      NEXT_ELEMENT(LAB_LOC);  /*CR13670*/
      STATNO=STATNO+1;                                                          00864500
      RETURN STATNO;          /*CR13670*/                                       00865500
   END GETSTATNO;                                                               00866000
