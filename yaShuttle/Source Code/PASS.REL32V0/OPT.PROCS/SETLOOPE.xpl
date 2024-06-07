 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETLOOPE.xpl
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
 /* PROCEDURE NAME:  SET_LOOP_END                                           */
 /* MEMBER NAME:     SETLOOPE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          K                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          A_PARITY                                                       */
 /*          N_INX                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          NODE                                                           */
 /* CALLED BY:                                                              */
 /*          FINAL_PASS                                                     */
 /***************************************************************************/
                                                                                01897090
                                                                                01897100
 /* PUTS DLPE POSITION ON LOOP STACK*/                                          01897110
SET_LOOP_END:                                                                   01897120
   PROCEDURE(PTR);                                                              01897130
      DECLARE (PTR,K) BIT(16);                                                  01897140
      K = N_INX;                                                                01897150
      DO WHILE A_PARITY(K);                                                     01897160
         K = K - 1;                                                             01897170
      END;                                                                      01897180
      NODE(K) = NODE(K) | PTR;                                                  01897190
   END SET_LOOP_END;                                                            01897200
