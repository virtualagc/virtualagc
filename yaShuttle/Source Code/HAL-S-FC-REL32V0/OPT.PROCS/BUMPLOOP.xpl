 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BUMPLOOP.xpl
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
 /* PROCEDURE NAME:  BUMP_LOOPSTACK                                         */
 /* MEMBER NAME:     BUMPLOOP                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          NODEWORD          FIXED                                        */
 /*          VM                BIT(8)                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          A_PARITY                                                       */
 /*          N_INX                                                          */
 /*          NODE                                                           */
 /* CALLED BY:                                                              */
 /*          PUSH_LOOP_STACKS                                               */
 /***************************************************************************/
                                                                                01894690
                                                                                01894700
 /* PUTS PTR ON STACKS AND PUSHES.  IF ALREADY 2 VDLPS ON TOP, JUST THE         01894710
      VDLPS ARE PUSHED  */                                                      01894720
 /* ADDS LOOP BEGINNING AND ENDING TO NODE STACK.  A_PARITY = 1 IF JUST VM*/    01894730
BUMP_LOOPSTACK:                                                                 01894740
   PROCEDURE(NODEWORD,VM);                                                      01894750
      DECLARE NODEWORD FIXED,                                                   01894760
         VM BIT(8);                                                             01894770
      N_INX = N_INX + 1;                                                        01894780
      NODE(N_INX) = NODEWORD;                                                   01894790
      A_PARITY(N_INX) = VM;                                                     01894800
      VM = 0;                                                                   01894810
   END BUMP_LOOPSTACK;                                                          01894820
