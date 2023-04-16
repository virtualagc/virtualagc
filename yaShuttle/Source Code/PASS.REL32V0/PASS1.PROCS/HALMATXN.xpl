 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HALMATXN.xpl
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
 /* PROCEDURE NAME:  HALMAT_XNOP                                            */
 /* MEMBER NAME:     HALMATXN                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          FIX_ATOM          FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ATOMS                                                          */
 /*          CONST_ATOMS                                                    */
 /*          HALMAT_OK                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_ATOMS                                                      */
 /* CALLED BY:                                                              */
 /*          END_ANY_FCN                                                    */
 /***************************************************************************/
                                                                                00802700
HALMAT_XNOP:                                                                    00802800
   PROCEDURE (FIX_ATOM);                                                        00802900
      DECLARE FIX_ATOM FIXED;                                                   00803000
      IF HALMAT_OK THEN ATOMS(FIX_ATOM)=ATOMS(FIX_ATOM)&"FF0000";               00803100
 /*  XNOP IS  A ZERO OPCODE  */                                                 00803200
   END HALMAT_XNOP;                                                             00803300
