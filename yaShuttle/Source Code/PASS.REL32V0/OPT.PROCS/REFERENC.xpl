 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   REFERENC.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  REFERENCED                                             */
 /* MEMBER NAME:     REFERENC                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CR_REF                                                         */
 /*          CROSS_REF                                                      */
 /*          FALSE                                                          */
 /*          SYM_TAB                                                        */
 /*          SYM_XREF                                                       */
 /*          SYT_XREF                                                       */
 /*          TRUE                                                           */
 /*          XREF                                                           */
 /* CALLED BY:                                                              */
 /*          INITIALISE                                                     */
 /***************************************************************************/
                                                                                00858010
 /* TRUE IF REFERENCED*/                                                        00858020
REFERENCED:                                                                     00858030
   PROCEDURE(PTR) BIT(8);                                                       00858040
      DECLARE PTR BIT(16);                                                      00858050
      PTR = SYT_XREF(PTR);                                                      00858060
      DO WHILE PTR ^= 0;                                                        00858070
         IF (XREF(PTR) & "E000") ^= 0 THEN RETURN TRUE;                         00858080
         PTR = SHR(XREF(PTR),16);                                               00858090
      END;                                                                      00858100
      RETURN FALSE;                                                             00858110
   END REFERENCED;                                                              00858120
