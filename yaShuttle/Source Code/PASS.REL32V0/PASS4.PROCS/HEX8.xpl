 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HEX8.xpl
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
/* PROCEDURE NAME:  HEX8                                                   */
/* MEMBER NAME:     HEX8                                                   */
/* FUNCTION RETURN TYPE:                                                   */
/*          CHARACTER                                                      */
/* INPUT PARAMETERS:                                                       */
/*          HVAL              FIXED                                        */
/* LOCAL DECLARATIONS:                                                     */
/*          I                 FIXED                                        */
/*          T                 CHARACTER;                                   */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          HEXCODES                                                       */
/* CALLED BY:                                                              */
/*          PAGE_DUMP                                                      */
/*          DUMP_SDF                                                       */
/***************************************************************************/
                                                                                00132800
 /* SUBROUTINE TO CONVERT AN INTEGER INTO 8 HEX DIGITS */                       00132900
HEX8:                                                                           00133000
   PROCEDURE (HVAL) CHARACTER;                                                  00133100
      DECLARE (HVAL, I) FIXED, T CHARACTER;                                     00133200
      T = '';                                                                   00133300
      DO I = 0 TO 7;                                                            00133400
         T = T || SUBSTR(HEXCODES, SHR(HVAL, SHL(7-I,2))&"F", 1);               00133500
      END;                                                                      00133600
      RETURN T;                                                                 00133700
   END HEX8;                                                                    00133800
