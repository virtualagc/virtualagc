 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EMITOUTP.xpl
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
/* PROCEDURE NAME:  EMIT_OUTPUT                                            */
/* MEMBER NAME:     EMITOUTP                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          CHARACTER                                                      */
/* INPUT PARAMETERS:                                                       */
/*          STRING            CHARACTER;                                   */
/* CALLED BY:                                                              */
/*          INITIALIZE                                                     */
/***************************************************************************/
                                                                                00126000
 /* SUBROUTINE FOR PRINTING A LINE THAT MAY EXCEED THE PRINTER LINE WIDTH */    00126100
EMIT_OUTPUT:                                                                    00126200
   PROCEDURE (STRING) CHARACTER;                                                00126300
      DECLARE STRING CHARACTER;                                                 00126400
      IF LENGTH(STRING) < 133 THEN OUTPUT = STRING;                             00126500
      ELSE DO;                                                                  00126600
         OUTPUT = SUBSTR(STRING,0,132);                                         00126700
         OUTPUT = SUBSTR(STRING,132);                                           00126800
      END;                                                                      00126900
   END EMIT_OUTPUT;                                                             00127000
