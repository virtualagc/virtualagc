 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GROUPCSE.xpl
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
 /* PROCEDURE NAME:  GROUP_CSE                                              */
 /* MEMBER NAME:     GROUPCSE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          INX               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          K                 BIT(16)                                      */
 /*          LAST              BIT(16)                                      */
 /*          PTR               BIT(16)                                      */
 /*          PTR2              BIT(16)                                      */
 /*          TEMP              BIT(16)                                      */
 /*          TOP               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FOR                                                            */
 /*          NODE                                                           */
 /*          NONCOMMUTATIVE                                                 */
 /*          OPR                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          A_INX                                                          */
 /*          ADD                                                            */
 /*          HALMAT_NODE_START                                              */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          BUMP_ADD                                                       */
 /*          LAST_OP                                                        */
 /*          LAST_OPERAND                                                   */
 /*          MOVE_LIMB                                                      */
 /*          TERMINAL                                                       */
 /* CALLED BY:                                                              */
 /*          EJECT_INVARS                                                   */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GROUP_CSE <==                                                       */
 /*     ==> LAST_OP                                                         */
 /*     ==> LAST_OPERAND                                                    */
 /*     ==> MOVE_LIMB                                                       */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> RELOCATE                                                    */
 /*         ==> MOVECODE                                                    */
 /*             ==> ENTER                                                   */
 /*     ==> BUMP_ADD                                                        */
 /*     ==> TERMINAL                                                        */
 /*         ==> VAC_OR_XPT                                                  */
 /*         ==> HALMAT_FLAG                                                 */
 /*             ==> VAC_OR_XPT                                              */
 /*         ==> CLASSIFY                                                    */
 /*             ==> PRINT_SENTENCE                                          */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /***************************************************************************/
                                                                                01890330
                                                                                01890340
                                                                                01890350
 /* ROUTINES FOR PULLING INVARIANT COMPUTATIONS FROM LOOPS*/                    01890360
                                                                                01890370
                                                                                01890380
 /* GOOUPS CSE WHOSE HEAD IS POINTED AT BY NODE(INX) & "FFFF".  RESETS          01890390
      NODE(INX).  SETS HALMAT_NODE_START POINTING TO BEGINNING.*/               01890400
GROUP_CSE:                                                                      01890410
   PROCEDURE(INX);                                                              01890420
      DECLARE INX BIT(16);                                                      01890430
      DECLARE (TEMP,TOP,K,LAST,PTR,PTR2) BIT(16);                               01890440
      TOP,INX = NODE(INX) & "FFFF";                                             01890450
      IF ^NONCOMMUTATIVE THEN DO;                                               01890460
         A_INX = 1;                                                             01890470
         ADD(1) = INX;                                                          01890480
                                                                                01890490
         DO WHILE A_INX > 0;                                                    01890500
            TEMP = ADD(A_INX);                                                  01890510
            A_INX = A_INX - 1;                                                  01890520
            DO FOR K = TEMP + 1 TO LAST_OPERAND(TEMP);                          01890530
                                                                                01890540
               IF ^TERMINAL(K,1) THEN DO;                                       01890550
                  LAST = LAST_OP(TOP - 1);                                      01890560
                  PTR = SHR(OPR(K),16);                                         01890570
                  CALL BUMP_ADD(PTR);                                           01890580
                  IF LAST = PTR THEN TOP = LAST;                                01890590
                  ELSE DO;   /* GROUP*/                                         01890600
                     PTR2 = LAST_OPERAND(PTR) + 1;                              01890610
                     CALL MOVE_LIMB(PTR,PTR2,TOP - PTR2,0,1);                   01890620
                     TOP = PTR + TOP - PTR2;                                    01890630
                  END;                                                          01890640
               END;  /* VAC OR XPT*/                                            01890650
            END;    /* DO FOR*/                                                 01890660
         END;    /* DO WHILE*/                                                  01890670
                                                                                01890680
         HALMAT_NODE_START = TOP;                                               01890690
      END;                                                                      01890700
      RETURN INX;                                                               01890710
   END GROUP_CSE;                                                               01890720
