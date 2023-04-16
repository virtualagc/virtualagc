 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PTRTOVAC.xpl
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
 /* PROCEDURE NAME:  PTR_TO_VAC                                             */
 /* MEMBER NAME:     PTRTOVAC                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          VAC_PTR                                                        */
 /* CALLED BY:                                                              */
 /*          REARRANGE_HALMAT                                               */
 /*          GROW_TREE                                                      */
 /***************************************************************************/
                                                                                01717000
 /* FORMATS A "PTR_TO_VAC" WORD FOR NODE LIST */                                01718000
PTR_TO_VAC:                                                                     01719000
   PROCEDURE(PTR);                                                              01720000
      DECLARE PTR BIT(16);                                                      01721000
      RETURN VAC_PTR|PTR;                                                       01722000
   END PTR_TO_VAC;                                                              01723000
