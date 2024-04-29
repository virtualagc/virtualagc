 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   INTRINSI.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

/***************************************************************************/
/* PROCEDURE NAME:  INTRINSIC                                              */
/* MEMBER NAME:     INTRINSI                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          BIT(8)                                                         */
/* INPUT PARAMETERS:                                                       */
/*          NAME              CHARACTER;                                   */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          FALSE                                                          */
/*          LIB_INDEX                                                      */
/*          LIB_POINTER                                                    */
/*          LIB_TABLE                                                      */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          LIB_LOOK                                                       */
/* CALLED BY:                                                              */
/*          GENERATE                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> INTRINSIC <==                                                       */
/*     ==> LIB_LOOK                                                        */
/*         ==> HASH                                                        */
/***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
 /*                                                                         */
 /*10/19/90 DAS   23V1  11053  (CR) RESTRICT RUNTIME LIBRARY USE            */
 /*                                                                         */
 /*11/17/99  DAS  30V0/ CR13222 REMOVE ERROR-PRONE DESIGN OF COMPILER       */
 /*               15V0          LIBRARY DESCRIPTION TABLE                   */
 /*                                                                         */
 /***************************************************************************/
                                                                                00855000
 /* ROUTINE TO CHECK WHETHER NAMED ROUTINE IS AN INTRINSIC OR NOT */            00855500
INTRINSIC:                                                                      00856000
   PROCEDURE(NAME) BIT(1);                                                      00856500
      DECLARE NAME CHARACTER;                                                   00857000
      IF LIB_LOOK(NAME) > 0 THEN                                                00857500
 /* DANNY ------------------- CR11053 -------------------------------*/         00857500
 /* LIB_POINTER MAY BE NEGATIVE, SO TAKE ABSOLUTE VALUE.             */         00857500
         RETURN LIB_CALLTYPE(ABS(LIB_POINTER)); /* CR13222 */
 /* DANNY -----------------------------------------------------------*/         00857500
      RETURN FALSE;                                                             00861500
   END INTRINSIC;                                                               00862000
