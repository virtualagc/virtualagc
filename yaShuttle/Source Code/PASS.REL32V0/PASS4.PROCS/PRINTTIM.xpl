 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTTIM.xpl
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
/* PROCEDURE NAME:  PRINT_TIME                                             */
/* MEMBER NAME:     PRINTTIM                                               */
/* INPUT PARAMETERS:                                                       */
/*          MESSAGE           CHARACTER;                                   */
/*          T                 FIXED                                        */
/* LOCAL DECLARATIONS:                                                     */
/*          C                 CHARACTER;                                   */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          CHARTIME                                                       */
/* CALLED BY:                                                              */
/*          PRINT_DATE_AND_TIME                                            */
/*          PRINTSUMMARY                                                   */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> PRINT_TIME <==                                                      */
/*     ==> CHARTIME                                                        */
/***************************************************************************/
                                                                                00137700
PRINT_TIME:                                                                     00137800
   PROCEDURE (MESSAGE,T);                                                       00137900
      DECLARE (MESSAGE,C) CHARACTER, T FIXED;                                   00138000
      C = CHARTIME(T);                                                          00138100
      OUTPUT = MESSAGE || C;                                                    00138200
   END PRINT_TIME;                                                              00138300
