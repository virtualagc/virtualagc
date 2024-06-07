 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SHAPINGF.xpl
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
 /* PROCEDURE NAME:  SHAPING_FN                                             */
 /* MEMBER NAME:     SHAPINGF                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ISHP                                                           */
 /*          MSHP                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          OPOP                                                           */
 /* CALLED BY:                                                              */
 /*          GROW_TREE                                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SHAPING_FN <==                                                      */
 /*     ==> OPOP                                                            */
 /***************************************************************************/
                                                                                00567100
 /* RETURNS TRUE IF OPR(PTR) IS SHAPING FN*/                                    00568000
SHAPING_FN:                                                                     00568010
   PROCEDURE(PTR) BIT(8);                                                       00568020
      DECLARE PTR BIT(16);                                                      00568030
      PTR = OPOP(PTR);                                                          00568040
      RETURN PTR >= MSHP & PTR <= ISHP;                                         00568050
   END SHAPING_FN;                                                              00568060
