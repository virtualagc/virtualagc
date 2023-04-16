 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MOVELIMB.xpl
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
 /* PROCEDURE NAME:  MOVE_LIMB                                              */
 /* MEMBER NAME:     MOVELIMB                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*                                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          LOW               BIT(16)                                      */
 /*          HIGH              BIT(16)                                      */
 /*          BIG               BIT(16)                                      */
 /*          QUICK_MOVE        BIT(8)                                       */
 /*          RELOCATE_ADD      BIT(8)                                       */
 /*          KEEP_D_N          BIT(8)                                       */
 /*          NOT_TOTAL_RELOCATE  BIT(8)                                     */
 /* LOCAL DECLARATIONS:                                                     */
 /*          BACK              BIT(16)                                      */
 /*          FBRA_FLO_NUM      BIT(16)                                      */
 /*          FBRA_FOUND        BIT(8)                                       */
 /*          I                 BIT(16)                                      */
 /*          NOT_PULLED_FROM_IF  BIT(8)                                     */
 /*          RELP              LABEL                                        */
 /*          STOP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          A_INX                                                          */
 /*          CLASS_ZO                                                       */
 /*          D_N_INX                                                        */
 /*          END_OF_LIST                                                    */
 /*          FALSE                                                          */
 /*          FBRA_FLAG                                                      */
 /*          FOR                                                            */
 /*          LEVEL                                                          */
 /*          N_INX                                                          */
 /*          NODE2                                                          */
 /*          OPR                                                            */
 /*          PULL_LOOP_HEAD                                                 */
 /*          STT#                                                           */
 /*          TRACE                                                          */
 /*          TRUE                                                           */
 /*          VAC_PTR                                                        */
 /*          XPULL_LOOP_HEAD                                                */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ADD                                                            */
 /*          AR_PTR                                                         */
 /*          CTR                                                            */
 /*          DIFF_NODE                                                      */
 /*          H_INX                                                          */
 /*          HALMAT_NODE_START                                              */
 /*          LAST_INX                                                       */
 /*          LAST_SMRK                                                      */
 /*          LEVEL_STACK_VARS                                               */
 /*          NODE                                                           */
 /*          SMRK_CTR                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERRORS                                                         */
 /*          MOVECODE                                                       */
 /*          RELOCATE                                                       */
 /* CALLED BY:                                                              */
 /*          GROUP_CSE                                                      */
 /*          EJECT_INVARS                                                   */
 /*          INSERT                                                         */
 /*          PUSH_HALMAT                                                    */
 /*          PUT_VDLP                                                       */
 /*          REARRANGE_HALMAT                                               */
 /*          SWITCH                                                         */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> MOVE_LIMB <==                                                       */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> RELOCATE                                                        */
 /*     ==> MOVECODE                                                        */
 /*         ==> ENTER                                                       */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS       DR/CR #  DESCRIPTION                            */
 /*                                                                         */
 /* 03/15/91 DKB  23V2      CR11109  CLEANUP COMPILER SOURCE CODE           */
 /* 02/10/95 JMP  27V0/11V0 DR104836 ELIMINATE EXTRANEOUS Z03 MESSAGES      */
 /*                                                                         */
 /***************************************************************************/
                                                                                01497000
 /* PROCEDURE TO MOVE AND RELOCATE HALMAT*/                                     01498000
MOVE_LIMB:                                                                      01499000
   PROCEDURE(LOW,HIGH,BIG,QUICK_MOVE,RELOCATE_ADD,KEEP_D_N,NOT_TOTAL_RELOCATE); 01500000
      DECLARE KEEP_D_N BIT(8);                                                  01500001
      DECLARE RELOCATE_ADD BIT(8);                                              01500010
      DECLARE NOT_TOTAL_RELOCATE BIT(8);                                        01500100
      DECLARE QUICK_MOVE BIT(8);                                                01501000
      DECLARE (HIGH,LOW,BIG,BACK,STOP,I,J)BIT(16);                              01502000
      DECLARE FBRA_FLO_NUM BIT(16);                             /* DR103032 */    502010
      DECLARE LBL_FOUND BIT(1);                                 /* DR104836 */
      DECLARE ZO3_FLAG  BIT(1);                                 /* DR104836 */
      IF TRACE THEN OUTPUT = 'MOVE_LIMB:  LOW '||LOW||'  HIGH '||HIGH           01503000
         || '  BIG '||BIG|| '  QUICK_MOVE '||QUICK_MOVE;                        01504000
                                                                                01504010
      IF BIG ^= 0 THEN DO;                                                      01504020
                                                                                01504030
 /************** DR103032  R. HANDLEY  8 MAR 89 ***********************/        01504040
 /*                                                                   */        01504050
 /* ONCE YOU GET THIS FAR SOME HALMAT IS GOING TO BE MOVED. HERE WE   */        01504060
 /* MAKE A CHECK TO SEE IF THIS CODE WAS PART OF AN IF-THEN GROUP. IF */        01504070
 /* THE CODE WAS IN AN IF-THEN GROUP THEN A MESSAGE IS PRINTED.       */        01504080
 /*                                                                   */        01504090
 /*********************************************************************/        01504100
         IF FBRA_FLAG & ^QUICK_MOVE THEN DO;                                    01504110
            I = HIGH - 1;                                                       01504120
            ZO3_FLAG = FALSE;                                   /* DR104836 */
                                                                                01504140
 /* SEARCH FOR FBRA OPERATORS BETWEEN HIGH AND LOW.             /* DR104836 */    504150
                                                                                01504160
            DO WHILE (I >= LOW & ^ZO3_FLAG);                    /* DR104836 */    504170
                                   /* "00A0" => FBRA OPERATOR      DR104836 */
               IF (OPR(I) & "FFF1") = "00A0" THEN DO;                           01504180
                                                                                01504200
 /* NOW DETERMINE IF THE HALMAT OPERATOR THAT IS THE OBJECT OF THE   */         01504210
 /* FBRA IS BETWEEN THE FBRA AND THE CODE MOVED. IF NOT THEN IT MUST */         01504220
 /* BE AFTER THE CODE TO BE MOVED. */                                           01504230
                                                                                01504240
                  FBRA_FLO_NUM = SHR(OPR(I+1),16);                              01504250
                  J = I + 3;                                    /* DR104836 */    504260
                                                                                01504270
 /* SEARCH FOR A LBL OPERATOR WITH THE SAME INTERNAL FLOW NUMBER AS */          01504280
 /* THE FBRA OPERATOR. */                                                       01504290
                                                                                01504300
                  LBL_FOUND = FALSE;                            /* DR104836 */    504310
                  DO WHILE (J < HIGH) & ^LBL_FOUND;             /* DR104836 */    504320
                                         /* "0080"=>LBL OPERATOR   DR104836 */
                     IF (OPR(J) & "FFF1") = "0080" THEN         /* DR104836 */    504330
                        IF FBRA_FLO_NUM = SHR(OPR(J+1),16) THEN /* DR104836 */    504340
                           LBL_FOUND = TRUE;                    /* DR104836 */    504350
                     J = J + 1;                                 /* DR104836 */    504360
                  END; /* DO WHILE */                                           01504370
                                                                                01504380
 /* PRINT OUT MESSAGE ONLY IF CODE WAS PULLED FROM IF STATEMENT. */             01504390
                                                                                01504400
                  IF ^LBL_FOUND THEN DO;                        /* DR104836 */    504410
                     ZO3_FLAG = TRUE;
                     CALL ERRORS(CLASS_ZO, 3, ''||STT#);                        01504420
                  END;
               END; /* FBRA FOUND */                                            01504430
               I = I - 1;                                                       01504440
            END; /* DO WHILE */                                                 01504450
         END; /* IF FBRA_FLAG */                                                01504460
 /*************************** END DR103032 ****************************/        01504470
                                                                                01504480
         IF ^QUICK_MOVE THEN DO;                                                01505000
            CALL MOVECODE(LOW,HIGH,BIG,1);                                      01506000
            CALL RELOCATE(LOW,HIGH,BIG,1,NOT_TOTAL_RELOCATE);                   01507000
         END;                                                                   01508000
                                                                                01509000
         STOP = HIGH + BIG;                                                     01510000
         BACK = LOW - HIGH;                                                     01511000
         I = 2;                                                                 01512000
         DO WHILE I <= N_INX - 1;                                               01513000
            IF NODE(I) = END_OF_LIST THEN I = I + 1;                            01514000
            ELSE DO;                                                            01515000
                                                                                01516000
                                                                                01517000
RELP:                                                                           01518000
               PROCEDURE(TEMP) BIT(16);                                         01519000
                  DECLARE TEMP BIT(16);                                         01520000
                  IF TEMP < HIGH THEN DO;                                       01521000
                     IF TEMP >= LOW THEN TEMP = TEMP + BIG;                     01522000
                  END;                                                          01523000
                  ELSE IF TEMP < STOP THEN TEMP = TEMP + BACK;                  01524000
                  RETURN TEMP;                                                  01525000
               END RELP;                                                        01526000
                                                                                01527000
                                                                                01528000
               NODE(I)=VAC_PTR | RELP(NODE(I) & "FFFF");                        01529000
               IF I = N_INX - 1 THEN I = N_INX;                                 01530000
               ELSE I = NODE2(I + 1) + 1;                                       01531000
               IF I = 1 THEN I = N_INX;                                         01532000
            END;                                                                01533000
         END; /* DO WHILE*/                                                     01534000
         DO FOR I = 0 TO LEVEL;                                                 01534010
            PULL_LOOP_HEAD(I) = RELP(PULL_LOOP_HEAD(I));                        01534020
         END;                                                                   01534030
         AR_PTR = RELP(AR_PTR);                                                 01534040
         HALMAT_NODE_START = RELP(HALMAT_NODE_START);                           01534050
                                                                                01534060
         IF ^KEEP_D_N THEN                                                      01534070
            DO FOR I = 0 TO D_N_INX;                                            01535000
            DIFF_NODE(I) = RELP(DIFF_NODE(I));                                  01536000
         END;                                                                   01537000
         IF RELOCATE_ADD THEN DO;                                               01537010
            DO FOR I = 0 TO A_INX;                                              01537020
               ADD(I) = RELP(ADD(I));                                           01537030
            END;                                                                01537040
         END;                                                                   01537050
      END;                                                                      01537060
                                                                                01537210
      CTR = RELP(CTR);                                                          01537220
      SMRK_CTR = RELP(SMRK_CTR);                                                01537230
      LAST_SMRK = RELP(LAST_SMRK);                                              01537240
      H_INX = LOW + BIG;                 /* SET_WORDS ADDS 3*/                  01538000
      LAST_INX = LOW + BIG - 3;                                                 01539000
      RELOCATE_ADD,                                                             01539010
         NOT_TOTAL_RELOCATE,                                                    01539020
         QUICK_MOVE = 0;                                                        01540000
      KEEP_D_N = 0;                                                             01540010
   END MOVE_LIMB;                                                               01541000
