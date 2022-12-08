 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   XBITS.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  X_BITS                                                 */
 /* MEMBER NAME:     XBITS                                                  */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          CTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          PREPARE_HALMAT                                                 */
 /***************************************************************************/
                                                                                00620120
                                                                                00621000
 /*  SUBROUTINE FOR GETTING CODE OPTIMIZER BITS  */                             00622000
X_BITS:                                                                         00623000
   PROCEDURE (CTR) BIT(8);                                                      00624000
      DECLARE CTR BIT(16);                                                      00625000
      RETURN SHR(OPR(CTR),1)&"7";                                               00626000
   END X_BITS;                                                                  00627000
