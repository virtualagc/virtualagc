 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   LHSCHECK.xpl
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
 /* PROCEDURE NAME:  LHS_CHECK                                              */
 /* MEMBER NAME:     LHSCHECK                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          #LHS                                                           */
 /*          LHS_SIZE                                                       */
 /*          PHASE3_ERROR                                                   */
 /*          P3ERR                                                          */
 /*          X1                                                             */
 /* CALLED BY:                                                              */
 /*          GET_STMT_DATA                                                  */
 /***************************************************************************/
                                                                                00206700
 /* ROUTINE TO CHECK FOR OVERFLOW OF LEFT-HAND-SIDE BUFFER */                   00206800
                                                                                00206900
LHS_CHECK:                                                                      00207000
   PROCEDURE;                                                                   00207100
      IF #LHS > LHS_SIZE THEN DO;                                               00207200
         OUTPUT = X1;                                                           00207300
         OUTPUT = P3ERR || 'LHS BUFFER OVERFLOW ***';                           00207400
         GO TO PHASE3_ERROR;                                                    00207500
      END;                                                                      00207600
   END LHS_CHECK;                                                               00207800
