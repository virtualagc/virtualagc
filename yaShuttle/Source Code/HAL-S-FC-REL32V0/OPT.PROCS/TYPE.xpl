 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   TYPE.xpl
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
 /* PROCEDURE NAME:  TYPE                                                   */
 /* MEMBER NAME:     TYPE                                                   */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          CSE_WORD          FIXED                                        */
 /* CALLED BY:                                                              */
 /*          ARRAYED_ELT                                                    */
 /*          CSE_MATCH_FOUND                                                */
 /*          FLAG_MATCHES                                                   */
 /*          GET_NODE                                                       */
 /*          INVAR                                                          */
 /*          SET_ARRAYNESS                                                  */
 /*          STRIP_NODES                                                    */
 /*          TABLE_NODE                                                     */
 /***************************************************************************/
                                                                                01890260
 /* RETURNS CSE WORD TYPE*/                                                     01890270
TYPE:                                                                           01890280
   PROCEDURE(CSE_WORD) BIT(8);                                                  01890290
      DECLARE CSE_WORD FIXED;                                                   01890300
      RETURN SHR(CSE_WORD,16) & "F";                                            01890310
   END TYPE;                                                                    01890320
