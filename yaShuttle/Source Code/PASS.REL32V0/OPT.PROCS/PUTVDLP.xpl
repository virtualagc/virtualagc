 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PUTVDLP.xpl
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
 /* PROCEDURE NAME:  PUT_VDLP                                               */
 /* MEMBER NAME:     PUTVDLP                                                */
 /* LOCAL DECLARATIONS:                                                     */
 /*          EXCLUDE_ASSIGN    BIT(8)                                       */
 /*          LAST_PTR          BIT(16)                                      */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          ASSIGN_TOP                                                     */
 /*          DSUB_REF                                                       */
 /*          FALSE                                                          */
 /*          IMD_0                                                          */
 /*          LOOP_DIMENSION                                                 */
 /*          LOOP_START                                                     */
 /*          LOOPLESS_ASSIGN                                                */
 /*          NOT                                                            */
 /*          OR                                                             */
 /*          SUB_TRACE                                                      */
 /*          TAG_BIT                                                        */
 /*          VDLE                                                           */
 /*          VDLP_TAG                                                       */
 /*          VDLP                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LOOP_LAST                                                      */
 /*          OPR                                                            */
 /*          VDLP#                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ASSIGN_TYPE                                                    */
 /*          LAST_OPERAND                                                   */
 /*          MOVE_LIMB                                                      */
 /*          PUSH_HALMAT                                                    */
 /*          VU                                                             */
 /* CALLED BY:                                                              */
 /*          PUT_VM_INLINE                                                  */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PUT_VDLP <==                                                        */
 /*     ==> ASSIGN_TYPE                                                     */
 /*     ==> LAST_OPERAND                                                    */
 /*     ==> VU                                                              */
 /*         ==> HEX                                                         */
 /*     ==> MOVE_LIMB                                                       */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> RELOCATE                                                    */
 /*         ==> MOVECODE                                                    */
 /*             ==> ENTER                                                   */
 /*     ==> PUSH_HALMAT                                                     */
 /*         ==> HEX                                                         */
 /*         ==> OPOP                                                        */
 /*         ==> VAC_OR_XPT                                                  */
 /*         ==> BUMP_D_N                                                    */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> ENTER                                                       */
 /*         ==> LAST_OP                                                     */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> MOVE_LIMB                                                   */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> RELOCATE                                                */
 /*             ==> MOVECODE                                                */
 /*                 ==> ENTER                                               */
 /***************************************************************************/
                                                                                02371060
                                                                                02372000
                                                                                02372010
 /* ROUTINES FOR VECTOR MATRIX INLINE */                                        02372020
                                                                                02372030
                                                                                02372040
                                                                                02372050
                                                                                02372060
                                                                                02372070
                                                                                02372080
                                                                                02372090
                                                                                02372520
 /* PUSHES HALMAT AND INSERTS VDLP.  CHECKS IF ASSIGN CAN AND SHOULD BE         02372530
      INCLUDED AND SETS FLAGS*/                                                 02372540
PUT_VDLP:                                                                       02372550
   PROCEDURE;                                                                   02372560
      DECLARE EXCLUDE_ASSIGN BIT(8);                                            02372570
      DECLARE LAST_PTR BIT(16);                                                 02372575
      DECLARE TEMP BIT(16);                                                     02372580
                                                                                02372590
      IF LOOPLESS_ASSIGN & LOOP_START = LOOP_LAST THEN RETURN;                  02372600
                                                                                02372610
      EXCLUDE_ASSIGN = DSUB_REF AND ASSIGN_TOP;  /* TOP OP ASSIGNMENT*/         02372620
                                                                                02372630
      IF LOOPLESS_ASSIGN THEN DO;                                               02372640
         TEMP = LOOP_LAST;                                                      02372650
         LOOP_LAST = SHR(OPR(LOOP_LAST + 1),16);                                02372660
      END;                                                                      02372670
      ELSE TEMP = LAST_OPERAND(LOOP_LAST) + 1;                                  02372680
                                                                                02372690
                                                                                02372700
      IF EXCLUDE_ASSIGN & NOT LOOPLESS_ASSIGN & LOOP_START ^= LOOP_LAST         02372710
         THEN DO;                                                               02372720
                                                                                02372730
         LAST_PTR = SHR(OPR(LOOP_LAST + 1),16);                                 02372740
         OPR(LAST_PTR) = OPR(LAST_PTR) | TAG_BIT;                               02372750
         CALL PUSH_HALMAT(TEMP,6);                                              02372760
         OPR(TEMP + 5) = VDLE;                                                  02372770
         CALL MOVE_LIMB(LOOP_LAST,TEMP,5);                                      02372780
         OPR(LOOP_LAST + 3) = VDLP;                                             02372790
         OPR(LOOP_LAST + 4) = IMD_0 | SHL(LOOP_DIMENSION,16) | VDLP_TAG;        02372800
         TEMP = LOOP_LAST;                                                      02372810
         VDLP# = VDLP# + 2;                                                     02372820
      END;  /* EXCLUDE ASSIGN*/                                                 02372830
                                                                                02372840
      ELSE DO;                                                                  02372850
         CALL PUSH_HALMAT(TEMP,3);                                              02372860
         IF ^ASSIGN_TYPE(LOOP_LAST) THEN OPR(LOOP_LAST)=OPR(LOOP_LAST)|TAG_BIT; 02372870
         VDLP# = VDLP# + 1;                                                     02372880
      END;                                                                      02372890
                                                                                02372900
      CALL MOVE_LIMB(LOOP_START,TEMP,2);                                        02372910
      OPR(TEMP + 2) = VDLE;                                                     02372920
      OPR(LOOP_START) = VDLP;                                                   02372930
                                                                                02372940
      IF ASSIGN_TOP = FALSE OR EXCLUDE_ASSIGN & LOOP_START ^= LOOP_LAST THEN    02372950
         TEMP = "200";                                                          02372960
      ELSE TEMP = 0;                                                            02372970
                                                                                02372980
      OPR(LOOP_START + 1) = IMD_0 | SHL(LOOP_DIMENSION,16) | VDLP_TAG           02372990
         | TEMP;                                                                02373000
      IF SUB_TRACE THEN CALL VU(LOOP_START,LOOP_LAST - LOOP_START               02373010
         +6+ (3*EXCLUDE_ASSIGN));                                               02373020
   END PUT_VDLP;                                                                02373030
