 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PAD.xpl
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
/* PROCEDURE NAME:  PAD                                                    */
/* MEMBER NAME:     PAD                                                    */
/* FUNCTION RETURN TYPE:                                                   */
/*          CHARACTER                                                      */
/* INPUT PARAMETERS:                                                       */
/*          STRING            CHARACTER;                                   */
/*          MAX               BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          L                 BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          X72                                                            */
/* CALLED BY:                                                              */
/*          INITIALIZE                                                     */
/*          SDF_PROCESSING                                                 */
/***************************************************************************/
                                                                                00127100
 /* SUBROUTINE FOR FORCING A CHARACTER STRING TO A SPECIFIED LENGTH */          00127200
PAD:                                                                            00127300
   PROCEDURE (STRING,MAX) CHARACTER;                                            00127400
      DECLARE (STRING) CHARACTER, (MAX,L) BIT(16);                              00127500
                                                                                00127600
      L = LENGTH(STRING);                                                       00127700
      IF L < MAX THEN STRING = STRING||SUBSTR(X72,0,MAX-L);                     00127800
      ELSE IF L > MAX THEN STRING = SUBSTR(STRING,0,MAX);                       00127900
      RETURN STRING;                                                            00128000
   END PAD;                                                                     00128100
