 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   QUICKREL.xpl
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
 /* PROCEDURE NAME:  QUICK_RELOCATE                                         */
 /* MEMBER NAME:     QUICKREL                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          FINAL             BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          D_N               BIT(16)                                      */
 /*          INX               BIT(16)                                      */
 /*          LOOK              LABEL                                        */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          DIFF_PTR                                                       */
 /*          FOR                                                            */
 /*          TRACE                                                          */
 /*          XPXRC                                                          */
 /*          XVAC                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ADD                                                            */
 /*          D_N_INX                                                        */
 /*          DIFF_NODE                                                      */
 /*          OPR                                                            */
 /*          TOTAL                                                          */
 /*          XREC_PTR                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          MOVECODE                                                       */
 /*          RELOCATE                                                       */
 /*          VAC_OR_XPT                                                     */
 /*          XHALMAT_QUAL                                                   */
 /* CALLED BY:                                                              */
 /*          PUT_HALMAT_BLOCK                                               */
 /*          PREPASS                                                        */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> QUICK_RELOCATE <==                                                  */
 /*     ==> VAC_OR_XPT                                                      */
 /*     ==> RELOCATE                                                        */
 /*     ==> MOVECODE                                                        */
 /*         ==> ENTER                                                       */
 /*     ==> XHALMAT_QUAL                                                    */
 /***************************************************************************/
                                                                                01597420
                                                                                01598000
                                                                                01598010
                                                                                01598020
 /* QUICKLY PUSHES AND RELOCATES HALMAT.  INSERTS DIFF_PTR(D_N_INX)             01598030
   SPACES BEFORE DIFF_NODE(S_N_INX).  IF FINAL THEN STICKS IN EXTN'S */         01598040
QUICK_RELOCATE:                                                                 01598050
   PROCEDURE(PTR,FINAL);                                                        01598060
      DECLARE (PTR,TEMP) BIT(16);                                               01598070
      DECLARE (INX,D_N) BIT(16);                                                01598080
      DECLARE FINAL BIT(8);                                                     01598090
      DO FOR TEMP = PTR + 1 TO PTR + TOTAL;                                     01598100
         OPR(TEMP) = 0;                                                         01598110
      END;                                                                      01598120
                                                                                01598130
                                                                                01598140
      IF (OPR & "FFF1") = XPXRC THEN                                            01598150
         OPR(1) = OPR(1) + SHL(TOTAL,16);   /* RESET PXRC*/                     01598160
      XREC_PTR = XREC_PTR + TOTAL;                                              01598170
                                                                                01598180
      PTR = PTR + 1;                                                            01598190
                                                                                01598200
      D_N = D_N_INX;                                                            01598210
                                                                                01598220
      DO FOR INX = 1 TO D_N;                                                    01598230
         IF FINAL THEN D_N_INX = INX;                                           01598240
         ELSE D_N_INX = D_N + 1 - INX;                                          01598250
                                                                                01598260
         CALL MOVECODE(DIFF_NODE(D_N_INX),PTR,TOTAL);                           01598270
         CALL RELOCATE(DIFF_NODE(D_N_INX),PTR,TOTAL,0,0,FINAL);                 01598280
                                                                                01598290
         IF FINAL THEN DO;                                                      01598300
                                                                                01598310
                                                                                01598320
            DO FOR TEMP = 1 TO D_N;                                             01598330
               IF ADD(TEMP) < PTR THEN                                          01598340
                  IF ADD(TEMP) > DIFF_NODE(D_N_INX) THEN                        01598350
                  ADD(TEMP) = ADD(TEMP) + TOTAL;                                01598360
               IF TEMP ^= D_N_INX THEN IF DIFF_NODE(TEMP) = DIFF_NODE(D_N_INX)  01598370
                  THEN DIFF_NODE(TEMP) = DIFF_NODE(TEMP) + DIFF_PTR(D_N_INX);   01598380
            END;                                                                01598390
                                                                                01598400
                                                                                01598410
            ADD = SHR(OPR(ADD(D_N_INX)),16);                                    01598420
            DO FOR TEMP = DIFF_NODE(D_N_INX) TO                                 01598430
                  DIFF_NODE(D_N_INX) + DIFF_PTR(D_N_INX) - 1;                   01598440
                                                                                01598450
               OPR(TEMP) = OPR(ADD + TEMP - DIFF_NODE(D_N_INX));                01598460
            END;       /* EXTN NOW COPIED*/                                     01598470
                                                                                01598480
            IF TRACE THEN OUTPUT = '   ' || DIFF_PTR(D_N_INX) ||                01598490
               ' WORDS COPIED FROM ' || ADD || ' TO ' || DIFF_NODE(D_N_INX);    01598500
                                                                                01598510
            IF XHALMAT_QUAL(DIFF_NODE(D_N_INX)+1)=XVAC THEN                     01598512
               OPR(ADD(D_N_INX))=(OPR(ADD(D_N_INX)) & "FFFF")                   01598514
               | SHL(DIFF_NODE(D_N_INX),16);                                    01598516
            ELSE                                                                01598518
               OPR(ADD(D_N_INX)) = (OPR(ADD(D_N_INX)) & "FFF7")                 01598520
               | SHL(DIFF_NODE(D_N_INX),16);                                    01598530
                                                                                01598540
                                                                                01598550
            TEMP = ADD(D_N_INX);                                                01598560
LOOK:                                                                           01598570
            TEMP = TEMP - 1;                                                    01598580
            DO WHILE (SHR(OPR(TEMP),16) ^= ADD) AND TEMP >= 0;                  01598590
               TEMP = TEMP - 1;                                                 01598600
            END;                                                                01598610
            IF VAC_OR_XPT(TEMP) & XHALMAT_QUAL(ADD+1)^=XVAC THEN DO;            01598620
               OPR(TEMP) = OPR(TEMP) & "FFFF FFF7";  /* STRIP OFF CSE TAG*/     01598630
               IF TRACE THEN OUTPUT = '   CSE TAG STRIPPED FROM '|| TEMP;       01598640
            END;                                                                01598650
            ELSE IF TEMP > 0 THEN GO TO LOOK;                                   01598660
                                                                                01598670
         END;                                                                   01598680
                                                                                01598690
         IF TRACE THEN OUTPUT = 'QUICK_RELOCATE(' || DIFF_NODE(D_N_INX) ||      01598700
            ',' || PTR || ',' || TOTAL || ')';                                  01598710
         TOTAL = TOTAL - DIFF_PTR(D_N_INX);                                     01598720
         PTR = DIFF_NODE(D_N_INX) + DIFF_PTR(D_N_INX);                          01598730
         IF ^FINAL THEN                                                         01598740
            OPR(DIFF_NODE(D_N_INX)) = SHL(DIFF_PTR(D_N_INX) - 1,16);  /* NOP*/  01598750
      END;                                                                      01598760
      FINAL = 0;                                                                01598770
   END QUICK_RELOCATE;                                                          01598780
