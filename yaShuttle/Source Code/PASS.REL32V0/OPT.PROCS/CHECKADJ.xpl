 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKADJ.xpl
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
 /* PROCEDURE NAME:  CHECK_ADJACENT_LOOPS                                   */
 /* MEMBER NAME:     CHECKADJ                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          TAG               BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ADLP                                                           */
 /*          C_TRACE                                                        */
 /*          CROSS_STATEMENTS                                               */
 /*          DLPE                                                           */
 /*          EXTN                                                           */
 /*          FALSE                                                          */
 /*          NOP                                                            */
 /*          OPR                                                            */
 /*          SMRK                                                           */
 /*          VDLP_TAG                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          LAST_OP                                                        */
 /*          LAST_OPERAND                                                   */
 /*          OPOP                                                           */
 /* CALLED BY:                                                              */
 /*          PUSH_LOOP_STACKS                                               */
 /*          FINAL_PASS                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CHECK_ADJACENT_LOOPS <==                                            */
 /*     ==> OPOP                                                            */
 /*     ==> LAST_OP                                                         */
 /*     ==> LAST_OPERAND                                                    */
 /***************************************************************************/
                                                                                01894330
                                                                                01894340
 /* RETURNS TRUE IF LAST OPERATOR BEFORE PTR WAS DLPE.  IF TAG                  01894350
      = 1, THEN CHECKS FOR ADLP ONLY.  IF TAG = 2 THEN CHECKS FORWARD FOR       01894360
      DLPE.*/                                                                   01894370
CHECK_ADJACENT_LOOPS:                                                           01894380
   PROCEDURE(PTR,TAG) BIT(8);                                                   01894390
      DECLARE (PTR,TEMP) BIT(16);                                               01894400
      DECLARE TAG BIT(8);                                                       01894410
      IF C_TRACE THEN OUTPUT = 'CHECK_ADJACENT_LOOPS:  '||PTR||','||TAG;        01894420
      IF PTR = 0 THEN RETURN FALSE;                                             01894430
      TEMP = NOP;                                                               01894440
      DO WHILE TEMP <= EXTN | (TEMP = SMRK & CROSS_STATEMENTS);                 01894450
         IF TAG ^= 2 THEN PTR = LAST_OP(PTR - 1);                               01894460
         ELSE PTR = LAST_OPERAND(PTR) + 1;                                      01894470
         TEMP = OPOP(PTR);                                                      01894480
      END;                                                                      01894490
                                                                                01894500
      IF ^TAG THEN TEMP = TEMP = DLPE;                                          01894510
      ELSE TEMP = TEMP = ADLP & ((OPR(PTR + 1) & VDLP_TAG) = 0);                01894520
      TAG = 0;                                                                  01894530
      IF C_TRACE THEN OUTPUT = '   RETURNS '||TEMP;                             01894540
      RETURN TEMP;                                                              01894550
   END CHECK_ADJACENT_LOOPS;                                                    01894560
