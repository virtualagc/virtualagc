 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PUTBFNCT.xpl
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
 /* PROCEDURE NAME:  PUT_BFNC_TWIN                                          */
 /* MEMBER NAME:     PUTBFNCT                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          SINCOS                                                         */
 /*          OPTYPE                                                         */
 /*          SINOP                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          REARRANGE_HALMAT                                               */
 /***************************************************************************/
                                                                                03115000
 /* PUTS SINCOS OPERATOR IN HALMAT*/                                            03116000
PUT_BFNC_TWIN:                                                                  03117000
   PROCEDURE(PTR);                                                              03118000
      DECLARE PTR BIT(16);                                                      03119000
      OPR(PTR) =                                                                03120000
         SINCOS + SHL((OPTYPE ^= SINOP),24);   /* OPTYPE = REVERSE_OP HERE*/    03121000
   END PUT_BFNC_TWIN;                                                           03122000
