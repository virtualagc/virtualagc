 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETARRAY.xpl
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
 /* PROCEDURE NAME:  SET_ARRAYNESS                                          */
 /* MEMBER NAME:     SETARRAY                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          INX               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          DSUB_FLAG         BIT(8)                                       */
 /*          DSUB_INX          BIT(16)                                      */
 /*          EXITT             LABEL                                        */
 /*          PTR               BIT(16)                                      */
 /*          RET               BIT(8)                                       */
 /*          RET1              BIT(8)                                       */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          DA_MASK                                                        */
 /*          DSUB                                                           */
 /*          END_OF_NODE                                                    */
 /*          EXTN                                                           */
 /*          FOR                                                            */
 /*          I_TRACE                                                        */
 /*          NODE2                                                          */
 /*          OPR                                                            */
 /*          OR                                                             */
 /*          STACK_TRACE                                                    */
 /*          TRUE                                                           */
 /*          TSUB                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          NODE                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          LAST_OPERAND                                                   */
 /*          ARRAYED_ELT                                                    */
 /*          TYPE                                                           */
 /* CALLED BY:                                                              */
 /*          STRIP_NODES                                                    */
 /*          GET_NODE                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SET_ARRAYNESS <==                                                   */
 /*     ==> LAST_OPERAND                                                    */
 /*     ==> TYPE                                                            */
 /*     ==> ARRAYED_ELT                                                     */
 /*         ==> CSE_WORD_FORMAT                                             */
 /*             ==> HEX                                                     */
 /*         ==> TYPE                                                        */
 /***************************************************************************/  01891420
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 05/10/99 SMR  30V0  DR111323 BS122 ERROR FOR NAME STRUCTURE COMPARE     */
 /*               15V0                                                      */
 /*                                                                         */
 /***************************************************************************/


 /* SETS DUMMY AND ARRAYED BITS IN NODE OPTYPE .  NODE(INX) IS OPTYPE*/         01891430
SET_ARRAYNESS:                                                                  01891440
   PROCEDURE(INX) BIT(8);                                                       01891450
      DECLARE (INX,PTR,TEMP,DSUB_INX) BIT(16);                                  01891460
      DECLARE (RET,RET1,DSUB_FLAG) BIT(8);                                      01891470
      RET,RET1,DSUB_FLAG = 0;                                                   01891480
      PTR = INX - 1;                                                            01891490
      TEMP = NODE(INX) & "FFFF";                                                01891493
      IF TEMP = DSUB THEN DSUB_FLAG = TRUE;                                     01891496
                                                                                01891500
      IF TEMP = EXTN THEN PTR = PTR - 1;                                        01891505
      DO WHILE NODE(PTR) ^= END_OF_NODE;                                        01891510
         RET = RET | RET1;                                                      01891540
         RET1 = ARRAYED_ELT(NODE(PTR),NODE2(PTR),DSUB_FLAG);                    01891550
         PTR = PTR - 1;                                                         01891560
      END;                                                                      01891570
                                                                                01891580
      IF TEMP = DSUB THEN                                                       01891581
         IF TYPE(NODE(PTR + 1)) = "C" | TYPE(NODE(PTR + 1)) = "3" THEN          01891582
         /*EXIT IF ARRAYED OR DUMMY NODE FOUND*/
         IF RET1  = 1 THEN DO;  RET = RET | RET1;  GOTO EXITT;  END;            01891583
         ELSE IF RET1 = 2 THEN DO; RET = RET|RET1; GOTO EXITT; END;/*DR111323*/
            ELSE RET1 = 1;                                                      01891584
                                                                                01891585
         IF RET1 & ^RET THEN DO;                                                01891590
            IF TEMP = DSUB OR TEMP = TSUB THEN DO;                              01891610
               RET = (RET1 | RET) & "2";                                        01891620
               PTR = NODE(PTR - 1) & "FFFF";   /* DSUB HALMAT*/                 01891630
               DO FOR DSUB_INX = PTR + 2 TO LAST_OPERAND(PTR);                  01891640
                  TEMP = SHR(OPR(DSUB_INX),8) & "F";                            01891650
                  IF TEMP < 4 THEN GO TO EXITT;   /* ^ARRAY OR TSUB COMPONENT*/ 01891660
                  IF (TEMP & "3") ^= 1 THEN DO;                                 01891670
                     RET = RET | 1;   /* *,TO,AT => ARRAYED*/                   01891680
                     GO TO EXITT;                                               01891690
                  END;                                                          01891700
               END;   /* DO FOR*/                                               01891710
            END;  /* DSUB OR TSUB*/                                             01891720
            ELSE RET = RET | RET1;                                              01891730
         END;                                                                   01891740
         ELSE RET = RET | RET1;                                                 01891750
                                                                                01891760
EXITT:                                                                          01891770
                                                                                01891780
         NODE(INX) = NODE(INX) & ^DA_MASK | SHL(RET,29);                        01891790
         IF I_TRACE THEN OUTPUT =                                               01891800
            'SET_ARRAYNESS(' || INX || '):  ' || RET;                           01891810
         RETURN RET;                                                            01891820
      END SET_ARRAYNESS;                                                        01891830
