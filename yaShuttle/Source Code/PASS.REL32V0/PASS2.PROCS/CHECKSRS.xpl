 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKSRS.xpl
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
/* PROCEDURE NAME:  CHECK_SRS                                              */
/* MEMBER NAME:     CHECKSRS                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          BIT(16)                                                        */
/* INPUT PARAMETERS:                                                       */
/*          INST              BIT(16)                                      */
/*          IX                BIT(16)                                      */
/*          BASE              BIT(16)                                      */
/*          DISP              FIXED                                        */
/* LOCAL DECLARATIONS:                                                     */
/*          RANGE(1)          BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          AP101INST                                                      */
/*          PRELBASE                                                       */
/*          PROGBASE                                                       */
/*          RXTYPE                                                         */
/*          SRSTYPE                                                        */
/* CALLED BY:                                                              */
/*          GENERATE                                                       */
/*          OBJECT_CONDENSER                                               */
/***************************************************************************/
                                                                                00698500
 /* ROUTINE TO CHECK IF SRS INSTRUCTION TYPE IS CALLED FOR */                   00699000
CHECK_SRS:                                                                      00699500
   PROCEDURE(INST, IX, BASE, DISP) BIT(16);                                     00700000
      DECLARE BASE BIT(16);                                                     00700010
      DECLARE (INST, IX) BIT(16), DISP FIXED, RANGE(1) BIT(16) INITIAL(55,110); 00700500
      IF IX ^= 0 THEN RETURN RXTYPE;                                            00701000
      IF BASE = PROGBASE THEN RETURN RXTYPE;                                    00701100
      IF BASE = PRELBASE THEN RETURN RXTYPE;                                    00701110
      IF DISP < 0 | DISP > RANGE(INST>="50" & INST<"80") THEN RETURN RXTYPE;    00701500
      IF (AP101INST(INST)&"F8") = 0 THEN RETURN SRSTYPE;                        00702000
      RETURN RXTYPE;                                                            00702500
   END CHECK_SRS;                                                               00703000
