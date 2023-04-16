 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ADDINITI.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  ADD_INITIALIZED_NAME_VAR                               */
 /* MEMBER NAME:     ADDINITI                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          SYT_NO            BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CLOSE                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          INIT_NAME_HOLDER                                               */
 /* CALLED BY:                                                              */
 /*          GET_NAME_INITIALS                                              */
 /***************************************************************************/
                                                                                00143540
ADD_INITIALIZED_NAME_VAR:PROCEDURE(SYT_NO);                                     00143550
      DECLARE SYT_NO BIT(16);                                                   00143560
      INIT_NAME_HOLDER = SYT_NO;                                                00143570
      CLOSE ADD_INITIALIZED_NAME_VAR;                                           00143580
