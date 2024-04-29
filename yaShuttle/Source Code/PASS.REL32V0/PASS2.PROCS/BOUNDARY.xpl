 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BOUNDARY.xpl
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
/* PROCEDURE NAME:  BOUNDARY_ALIGN                                         */
/* MEMBER NAME:     BOUNDARY                                               */
/* INPUT PARAMETERS:                                                       */
/*          TYPE              BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          PLUS(5)           FIXED                                        */
/*          MASK(5)           FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CNOP                                                           */
/*          INDEXNEST                                                      */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          LOCCTR                                                         */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          EMITC                                                          */
/* CALLED BY:                                                              */
/*          GENERATE_CONSTANTS                                             */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> BOUNDARY_ALIGN <==                                                  */
/*     ==> EMITC                                                           */
/*         ==> FORMAT                                                      */
/*         ==> HEX                                                         */
/*         ==> HEX_LOCCTR                                                  */
/*             ==> HEX                                                     */
/*         ==> GET_CODE                                                    */
/***************************************************************************/
                                                                                00765000
 /* ROUTINE TO ALIGN DATA AREAS TO PROPER BOUNDARY  */                          00765500
BOUNDARY_ALIGN:                                                                 00766000
   PROCEDURE(TYPE);                                                             00766500
      DECLARE TYPE BIT(16),                                                     00767000
         PLUS(5) FIXED INITIAL (0, 0, 1, 1, 3, 1),                              00767500
         MASK(5) FIXED INITIAL (-1, -1, -2, -2, -4, -2);                        00768000
      IF (LOCCTR(INDEXNEST)&PLUS(TYPE))=0 THEN RETURN;                          00769000
      LOCCTR(INDEXNEST) = (LOCCTR(INDEXNEST) + PLUS(TYPE)) & MASK(TYPE);        00769500
      CALL EMITC(CNOP, PLUS(TYPE));                                             00770000
   END BOUNDARY_ALIGN;                                                          00770500
