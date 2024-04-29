 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SLIPSUBS.xpl
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
 /* PROCEDURE NAME:  SLIP_SUBSCRIPT                                         */
 /* MEMBER NAME:     SLIPSUBS                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          NUM               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          INX                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          NEXT_SUB                                                       */
 /* CALLED BY:                                                              */
 /*          ATTACH_SUB_ARRAY                                               */
 /*          ATTACH_SUB_COMPONENT                                           */
 /*          ATTACH_SUB_STRUCTURE                                           */
 /***************************************************************************/
                                                                                00941800
SLIP_SUBSCRIPT:                                                                 00941900
   PROCEDURE (NUM);                                                             00942000
      DECLARE NUM BIT(16);                                                      00942100
      DO WHILE NUM>0;                                                           00942200
         NUM=NUM-1;                                                             00942300
         NEXT_SUB=NEXT_SUB+1+(INX(NEXT_SUB)>1);                                 00942400
      END;                                                                      00942500
   END SLIP_SUBSCRIPT;                                                          00942600
