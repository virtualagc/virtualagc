 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETCLASS.xpl
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
 /* PROCEDURE NAME:  GET_CLASS                                              */
 /* MEMBER NAME:     GETCLASS                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          LOOP_OPERANDS                                                  */
 /*          FINAL_PASS                                                     */
 /*          LOOPY                                                          */
 /***************************************************************************/
                                                                                00561000
 /* RETURNS CLASS*/                                                             00561010
GET_CLASS:                                                                      00561020
   PROCEDURE(PTR) BIT(8);                                                       00561030
      DECLARE PTR BIT(16);                                                      00561040
      RETURN SHR(OPR(PTR),12) & "F";                                            00561050
   END GET_CLASS;                                                               00561060
