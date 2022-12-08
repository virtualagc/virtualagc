 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   INCRSTAC.xpl
    Purpose:    Auxiliary functionality used by the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/***************************************************************************/
/* PROCEDURE NAME:  INCR_STACK_PTR                                         */
/* MEMBER NAME:     INCRSTAC                                               */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLOSE                                                          */
/*          STACK_FRAME                                                    */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          STACK_PTR                                                      */
/*          MAX_STACK_LEVEL                                                */
/* CALLED BY:                                                              */
/*          PASS1                                                          */
/***************************************************************************/
                                                                                02910000
/*******************************************************************************02912000
         S T A C K   H A N D L I N G    R O U T I N E S                         02914000
*******************************************************************************/02916000
                                                                                02918000
                                                                                02920000
         /* ROUTINE TO INCREMENT AND CHECK STACK_PTR */                         02922000
                                                                                02924000
INCR_STACK_PTR: PROCEDURE;                                                      02926000
                                                                                02928000
   STACK_PTR = STACK_PTR + 1;                                                   02930000
   IF STACK_PTR > MAX_STACK_LEVEL THEN                                          02932000
      MAX_STACK_LEVEL = STACK_PTR;                                              02934000
   IF STACK_PTR >= RECORD_TOP(STACK_FRAME) THEN                                 02936000
      NEXT_ELEMENT(STACK_FRAME);                                                02937000
                                                                                02940000
CLOSE INCR_STACK_PTR;                                                           02942000
