 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETARRAY.xpl
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
 /* PROCEDURE NAME:  GETARRAYDIM                                            */
 /* MEMBER NAME:     GETARRAY                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          IX                BIT(8)                                       */
 /*          OP1               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          EXT_ARRAY                                                      */
 /*          STRUCTURE                                                      */
 /*          SYM_ARRAY                                                      */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_ARRAY                                                      */
 /*          SYT_TYPE                                                       */
 /* CALLED BY:                                                              */
 /*          BUILD_SDF                                                      */
 /***************************************************************************/
                                                                                00143900
 /*  SUBROUTINE FOR PICKING UP AN ARRAY DIMENSION FROM SYMBOL TABLE  */         00144000
GETARRAYDIM:                                                                    00144100
   PROCEDURE (IX,OP1) BIT(16);                                                  00144200
      DECLARE IX BIT(8), OP1 BIT(16);                                           00144300
      IF SYT_TYPE(OP1) = STRUCTURE THEN                                         00144400
         RETURN SYT_ARRAY(OP1);                                                 00144500
      RETURN EXT_ARRAY(SYT_ARRAY(OP1)+IX);                                      00144600
   END GETARRAYDIM;                                                             00144700
