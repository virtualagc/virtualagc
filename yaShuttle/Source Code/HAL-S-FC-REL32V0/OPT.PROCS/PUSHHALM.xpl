 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PUSHHALM.xpl
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
 /* PROCEDURE NAME:  PUSH_HALMAT                                            */
 /* MEMBER NAME:     PUSHHALM                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          START             BIT(16)                                      */
 /*          DISP              BIT(16)                                      */
 /*          FINAL_PUSH        BIT(8)                                       */
 /*          EXTN_CHK          BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          NEW_XREC          BIT(16)                                      */
 /*          OLD_XREC          BIT(16)                                      */
 /*          PTR               BIT(16)                                      */
 /*          PTR2              BIT(16)                                      */
 /*          RELO              LABEL                                        */
 /*          RET               BIT(8)                                       */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ACROSS_BLOCK_TAG                                               */
 /*          AND                                                            */
 /*          BLOCK_END                                                      */
 /*          BLOCK_PLUS_1                                                   */
 /*          CLASS_BI                                                       */
 /*          DIFF_PTR                                                       */
 /*          DOUBLEBLOCK_SIZE                                               */
 /*          EXTN                                                           */
 /*          FOR                                                            */
 /*          OR                                                             */
 /*          SMRK_CTR                                                       */
 /*          STATISTICS                                                     */
 /*          TRACE                                                          */
 /*          TRUE                                                           */
 /*          XNOP                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ADD                                                            */
 /*          CROSS_BLOCK_OPERATORS                                          */
 /*          D_N_INX                                                        */
 /*          DSUB_INX                                                       */
 /*          DSUB_LOC                                                       */
 /*          FLAG                                                           */
 /*          OPR                                                            */
 /*          PUSH_SIZE                                                      */
 /*          PUSH#                                                          */
 /*          ROOM                                                           */
 /*          TOTAL                                                          */
 /*          XREC_PTR                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          BUMP_D_N                                                       */
 /*          ENTER                                                          */
 /*          ERRORS                                                         */
 /*          HEX                                                            */
 /*          LAST_OP                                                        */
 /*          MOVE_LIMB                                                      */
 /*          NO_OPERANDS                                                    */
 /*          OPOP                                                           */
 /*          VAC_OR_XPT                                                     */
 /* CALLED BY:                                                              */
 /*          CHICKEN_OUT                                                    */
 /*          EJECT_INVARS                                                   */
 /*          INSERT_HALMAT_TRIPLE                                           */
 /*          PUT_HALMAT_BLOCK                                               */
 /*          PUT_VDLP                                                       */
 /*          SET_SAV                                                        */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PUSH_HALMAT <==                                                     */
 /*     ==> HEX                                                             */
 /*     ==> OPOP                                                            */
 /*     ==> VAC_OR_XPT                                                      */
 /*     ==> BUMP_D_N                                                        */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> ENTER                                                           */
 /*     ==> LAST_OP                                                         */
 /*     ==> NO_OPERANDS                                                     */
 /*     ==> MOVE_LIMB                                                       */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> RELOCATE                                                    */
 /*         ==> MOVECODE                                                    */
 /*             ==> ENTER                                                   */
 /***************************************************************************/
                                                                                01542000
 /* PUSHES HALMAT FORWARD FROM START BY DISP AND RELOCATES*/                    01543000
PUSH_HALMAT:                                                                    01544000
   PROCEDURE(START,DISP,FINAL_PUSH,EXTN_CHK) BIT(8);                            01545000
      DECLARE (EXTN_CHK,RET) BIT(8);                                            01545010
      DECLARE PTR2 BIT(16);                                                     01545020
      DECLARE OLD_XREC BIT(16);                                                 01545030
      DECLARE FINAL_PUSH BIT(8);                                                01546000
      DECLARE (START,DISP,NEW_XREC,TEMP,PTR) BIT(16),                           01547000
         (I,J) BIT(16);                                                         01548000
                                                                                01549000
                                                                                01550000
 /* RELOCATES*/                                                                 01551000
RELO:                                                                           01552000
      PROCEDURE(PTR) BIT(16);                                                   01553000
         DECLARE PTR BIT(16);                                                   01554000
         IF PTR < START THEN RETURN PTR;                                        01555000
         RETURN PTR + DISP;                                                     01556000
      END RELO;                                                                 01557000
                                                                                01558000
                                                                                01559000
      IF TRACE THEN OUTPUT = 'PUSH_HALMAT:  (' || START||','||DISP||','||       01560000
         FINAL_PUSH||')';                                                       01561000
                                                                                01562000
      TOTAL,RET = 0;                                                            01562010
      IF EXTN_CHK THEN D_N_INX = 0;                                             01562015
      IF DISP <= ROOM AND (OPR(SMRK_CTR - ROOM) & "FFF1") = XNOP                01562020
         AND ^FINAL_PUSH AND ^EXTN_CHK THEN DO;                                 01562030
                                                                                01562040
         OLD_XREC = XREC_PTR;                                                   01562050
         XREC_PTR = SMRK_CTR - ROOM - 1;                                        01562060
         ROOM = ROOM - DISP;                                                    01562070
         IF ROOM > 0 THEN DO;                                                   01562080
            OPR(SMRK_CTR - ROOM) = SHL(ROOM - 1,16);                            01562090
         END;                                                                   01562100
      END;                                                                      01562110
      ELSE OLD_XREC = XREC_PTR + DISP;                                          01562120
      NEW_XREC = XREC_PTR + DISP;                                               01563000
                                                                                01564000
      IF NEW_XREC > DOUBLEBLOCK_SIZE THEN CALL ERRORS (CLASS_BI, 309);          01565000
                                                                                01567000
                                                                                01567010
      IF STATISTICS THEN IF ^FINAL_PUSH THEN DO;                                01567020
         PUSH# = PUSH# + 1;                                                     01567030
         PUSH_SIZE = PUSH_SIZE + XREC_PTR -START + 1;                           01567040
      END;                                                                      01567050
                                                                                01567060
      DO FOR TEMP = 0 TO XREC_PTR - START;                                      01568000
                                                                                01569000
         I = XREC_PTR - TEMP;                                                   01570000
         J = NEW_XREC - TEMP;                                                   01571000
         IF VAC_OR_XPT(I) & (^((OPR(I)&"C") = "C") OR FINAL_PUSH OR EXTN_CHK)   01572000
            THEN DO;                                                            01572005
            PTR2,                                                               01572010
               PTR = SHR(OPR(I),16);                                            01573000
            IF PTR >= START THEN PTR = PTR + DISP;                              01574000
            IF FINAL_PUSH THEN                                                  01575000
               IF PTR > BLOCK_END THEN PTR = PTR - BLOCK_PLUS_1;                01576000
            ELSE DO;                                                            01577000
               IF (OPR(PTR) & ACROSS_BLOCK_TAG) = 0 THEN                        01577010
                  CROSS_BLOCK_OPERATORS = CROSS_BLOCK_OPERATORS + 1;            01577020
               OPR(PTR) = OPR(PTR) | ACROSS_BLOCK_TAG;                          01578000
               PTR = PTR | "8000";  /* LEFT BIT 1 IN CROSS BLOCK CSE*/          01579000
            END;                                                                01580000
            OPR(J) = SHL(PTR,16) | OPR(I) & "FFFF";                             01581000
                                                                                01581010
            IF EXTN_CHK THEN IF PTR <= BLOCK_END THEN IF J > BLOCK_END THEN     01581020
               IF OPOP(PTR2) = EXTN THEN DO;                                    01581030
                                                                                01581040
               RET = TRUE;                                                      01581050
               CALL BUMP_D_N(J - I + LAST_OP(I),NO_OPERANDS(PTR2) + 1);         01581060
 /* REMEMBER CROSS BLOCK EXTN CSE'S*/                                           01581070
               IF TRACE THEN OUTPUT =                                           01581080
                  '   J=' || J ||                                               01581090
                  ', I=' || I|| ', LAST_OP(I)=' || LAST_OP(I) ||                01581100
                  ', OPR(PTR2)=' || HEX(OPR(PTR2),8);                           01581110
               ADD(D_N_INX) = J;                                                01581120
               TOTAL = TOTAL + DIFF_PTR(D_N_INX);                               01581130
            END;                                                                01581140
                                                                                01581150
         END;                                                                   01582000
         ELSE DO;                                                               01583000
            OPR(J) = OPR(I);                                                    01583010
         END;                                                                   01583020
                                                                                01584000
         IF ^FINAL_PUSH AND ^EXTN_CHK THEN DO;                                  01585000
            FLAG(J) = FLAG(I);                                                  01586000
            IF (OPR(J) & "C") = "C" THEN CALL ENTER(J);                         01587000
         END;                                                                   01588000
                                                                                01589000
      END;  /* DO FOR*/                                                         01590000
                                                                                01591000
      DO FOR TEMP = START TO START + DISP - 1;                                  01591010
         OPR(TEMP) = 0;                                                         01591020
      END;                                                                      01591030
                                                                                01591040
      IF ^FINAL_PUSH THEN CALL MOVE_LIMB(START,XREC_PTR + 1,DISP,1,0,EXTN_CHK); 01592000
      ELSE DO;                                                                  01592010
         IF CROSS_BLOCK_OPERATORS > CROSS_BLOCK_OPERATORS(1) THEN               01592020
            CROSS_BLOCK_OPERATORS(1) = CROSS_BLOCK_OPERATORS;                   01592030
         CROSS_BLOCK_OPERATORS = 0;                                             01592040
      END;                                                                      01592050
                                                                                01592060
      DSUB_LOC = RELO(DSUB_LOC);                                                01594010
      DSUB_INX = RELO(DSUB_INX);                                                01594020
      FINAL_PUSH = 0;                                                           01596000
      EXTN_CHK = 0;                                                             01596010
      XREC_PTR = OLD_XREC;                                                      01596020
      RETURN RET;                                                               01596030
   END PUSH_HALMAT;                                                             01597000
