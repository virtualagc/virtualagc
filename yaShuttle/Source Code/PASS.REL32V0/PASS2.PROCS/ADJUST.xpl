 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ADJUST.xpl
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
/* PROCEDURE NAME:  ADJUST                                                 */
/* MEMBER NAME:     ADJUST                                                 */
/* FUNCTION RETURN TYPE:                                                   */
/*          FIXED                                                          */
/* INPUT PARAMETERS:                                                       */
/*          BIGHT             BIT(16)                                      */
/*          ADDRESS           FIXED                                        */
/* LOCAL DECLARATIONS:                                                     */
/*          TEMP              FIXED                                        */
/* CALLED BY:                                                              */
/*          INITIALISE                                                     */
/*          GENERATE                                                       */
/***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 DKB  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /***************************************************************************/
                                                                                00703500
 /* ROUTINE FOR ADJUSTING STORAGE BOUNDARIES  */                                00704000
ADJUST:                                                                         00704500
   PROCEDURE(BIGHT, ADDRESS) FIXED;                                             00705000
      DECLARE BIGHT BIT(16), (ADDRESS, TEMP) FIXED;                             00705500
      TEMP = BIGHT - 1;                                                         00706000
      RETURN ADDRESS + TEMP & (^TEMP);                                          00706500
   END ADJUST;                                                                  00707000
