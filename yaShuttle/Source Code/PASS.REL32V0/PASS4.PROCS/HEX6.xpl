 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HEX6.xpl
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
/* PROCEDURE NAME:  HEX6                                                   */
/* MEMBER NAME:     HEX6                                                   */
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
/*          DUMP_SDF                                                       */
/***************************************************************************/
                                                                                00133900
HEX6:                                                                           00134000
   PROCEDURE (HVAL) CHARACTER;                                                  00134100
      DECLARE (HVAL, I) FIXED, T CHARACTER;                                     00134200
      T = '';                                                                   00134300
      DO I = 0 TO 5;                                                            00134400
         T = T||SUBSTR(HEXCODES,SHR(HVAL,SHL(5-I,2))&"F",1);                    00134500
      END;                                                                      00134600
      RETURN T;                                                                 00134700
   END HEX6;                                                                    00134800
