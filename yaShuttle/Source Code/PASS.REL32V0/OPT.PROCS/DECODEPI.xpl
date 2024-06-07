 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DECODEPI.xpl
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
 /* PROCEDURE NAME:  DECODEPIP                                              */
 /* MEMBER NAME:     DECODEPI                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          OP                BIT(16)                                      */
 /*          N                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          COMMA                                                          */
 /*          CTR                                                            */
 /*          CURCBLK                                                        */
 /*          HALMAT_REQUESTED                                               */
 /*          LEFTBRACKET                                                    */
 /*          OPR                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OP1                                                            */
 /*          MESSAGE                                                        */
 /*          TAG1                                                           */
 /*          TAG2                                                           */
 /*          TAG3                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          FORMAT                                                         */
 /* CALLED BY:                                                              */
 /*          BLAB_BLOCK                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> DECODEPIP <==                                                       */
 /*     ==> FORMAT                                                          */
 /***************************************************************************/
                                                                                00516000
 /* ROUTINE TO DECODE HALMAT OPERAND  */                                        00517000
DECODEPIP:                                                                      00518000
   PROCEDURE(OP, N);                                                            00519000
      DECLARE (OP, N) BIT(16);                                                  00520000
      OP=OP+CTR;                                                                00521000
      OP1=SHR(OPR(OP),16) & "7FFF";                                             00522000
      TAG1=SHR(OPR(OP),4)&"F";                                                  00523000
      TAG2(N)=SHR(OPR(OP),1)&"7";                                               00524000
      TAG3(N)=SHR(OPR(OP),8)&"FF";                                              00525000
      IF HALMAT_REQUESTED THEN DO;                                              00526000
         MESSAGE=FORMAT(TAG3(N),3)||COMMA||TAG2(N)||' :'||CURCBLK-1||'.'||OP;   00527000
         IF SHR(OPR(OP),31) THEN MESSAGE = MESSAGE || '*';                      00527010
         MESSAGE=FORMAT(TAG1,2)||'),'||MESSAGE;                                 00528000
         OUTPUT=FORMAT(OP1,20)||LEFTBRACKET||MESSAGE;                           00529000
      END;                                                                      00530000
      N = 0;                                                                    00531000
   END DECODEPIP;                                                               00532000
