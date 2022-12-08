 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   RELOCAT2.xpl
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
 /* PROCEDURE NAME:  RELOCATE_HALMAT                                        */
 /* MEMBER NAME:     RELOCAT2                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CTR               BIT(16)                                      */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          K                 FIXED                                        */
 /*          NODE_PTR          BIT(16)                                      */
 /*          NON_CSE_EXTN      LABEL                                        */
 /*          PTR               BIT(16)                                      */
 /*          SECOND_REF        BIT(8)                                       */
 /*          TEMP              BIT(16)                                      */
 /*          XPT_LOC           BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          EXTN                                                           */
 /*          CSE_LIST                                                       */
 /*          FOR                                                            */
 /*          LIST_CSE                                                       */
 /*          N_INX                                                          */
 /*          OR                                                             */
 /*          OUTER_TERMINAL_VAC                                             */
 /*          TRACE                                                          */
 /*          TSUB                                                           */
 /*          TYPE_MASK                                                      */
 /*          VAC_PTR                                                        */
 /*          WATCH                                                          */
 /*          XEXTN                                                          */
 /*          XSMRK                                                          */
 /*          XXPT                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          COMMONSE_LIST                                                  */
 /*          CSE_L_INX                                                      */
 /*          D_N_INX                                                        */
 /*          DIFF_PTR                                                       */
 /*          NODE                                                           */
 /*          NODE2                                                          */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          DETAG                                                          */
 /*          HEX                                                            */
 /*          LAST_OP                                                        */
 /*          NO_OPERANDS                                                    */
 /*          OPOP                                                           */
 /*          REFERENCE                                                      */
 /*          TWIN_HALMATTED                                                 */
 /*          VAC_OR_XPT                                                     */
 /* CALLED BY:                                                              */
 /*          ZAP_TABLES                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> RELOCATE_HALMAT <==                                                 */
 /*     ==> HEX                                                             */
 /*     ==> OPOP                                                            */
 /*     ==> VAC_OR_XPT                                                      */
 /*     ==> LAST_OP                                                         */
 /*     ==> TWIN_HALMATTED                                                  */
 /*     ==> NO_OPERANDS                                                     */
 /*     ==> DETAG                                                           */
 /*     ==> REFERENCE                                                       */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> TERMINAL                                                    */
 /*             ==> VAC_OR_XPT                                              */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*             ==> CLASSIFY                                                */
 /*                 ==> PRINT_SENTENCE                                      */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /***************************************************************************/
                                                                                01917170
 /* REPLACES HALMAT_FLAGGED OPERANDS WITH THEIR ACTUAL LOCATIONS*/              01918000
RELOCATE_HALMAT:                                                                01919000
   PROCEDURE;                                                                   01920000
      DECLARE TEMP BIT(16);                                                     01921000
      DECLARE (I,PTR,NODE_PTR) BIT(16);                                         01922000
      DECLARE SECOND_REF BIT(8);                                                01922010
      DECLARE (XPT_LOC,J,CTR) BIT(16), K FIXED;                                 01922020
      IF TRACE THEN OUTPUT = 'RELOCATE_HALMAT:';                                01923000
      D_N_INX = 0;                                                              01923010
      DO FOR I = 1 TO CSE_L_INX;                                                01924000
         PTR = CSE_LIST(I);                                                     01925000
         IF TRACE THEN OUTPUT = '   CSE_LIST(' ||I||') = '||PTR;                01926000
         IF VAC_OR_XPT(PTR) & (OPR(PTR) & "C") = "C" THEN DO;                   01927000
                                                                                01928000
 /* IF NOT RELOCATED ALREADY*/                                                  01929000
                                                                                01930000
            NODE_PTR = SHR(OPR(PTR),16);                                        01931000
 /* NON-CSE EXTN POINTS TO TSUB CSE */                                          01932000
            TEMP = LAST_OP(PTR);                                                01932100
            IF (OPR(TEMP)&"FFF1")=XEXTN THEN DO;                                01932200
               IF (OPR(TEMP) & "8") = 0 THEN DO;                                01932300
                  XPT_LOC = REFERENCE(TEMP);                                    01932400
NON_CSE_EXTN:                                                                   01932500
                  OPR(XPT_LOC) = OPR(XPT_LOC) | "8";                            01932600
                  SECOND_REF = NODE2(NODE_PTR+1) < 0;                           01932700
                  IF SECOND_REF THEN NODE2(NODE_PTR+1) = NODE2(NODE_PTR+1) - 1; 01932800
                  ELSE NODE2(NODE_PTR+1) = -1;                                  01932900
                  TEMP = SHR(NODE(NODE_PTR+1),16);                              01933000
                  IF ^SECOND_REF OR XPT_LOC > TEMP THEN                         01933100
                 NODE(NODE_PTR+1)=(NODE(NODE_PTR+1)&"0000FFFF")|SHL(XPT_LOC,16);01933200
                  D_N_INX = D_N_INX + 1;                                        01933300
                  DIFF_PTR(D_N_INX) = NODE_PTR + 1;                             01933400
                  IF TRACE THEN OUTPUT='     NODE_PTR '||(NODE_PTR+1)||' XPT '||01933500
                     HEX(OPR(XPT_LOC),8)||' NODE '||HEX(NODE(NODE_PTR+1),8);    01933600
               END;                                                             01933700
               ELSE DO;                                                         01933800
                  K = VAC_PTR | TEMP;                                           01933900
                  J = N_INX;                                                    01934000
                  DO WHILE J>0;                                                 01934100
                     IF NODE(J) = K THEN DO;                                    01934200
                        IF NODE2(J) = 0 THEN DO;                                01934300
                           CTR = TEMP;                                          01934400
                           DO WHILE (OPR(CTR)&"FFF1")^=XSMRK;                   01934500
                              DO FOR K = CTR+1 TO CTR+NO_OPERANDS(CTR);         01934600
                                 IF (OPR(K)&"FD")="4D" THEN                     01934700
                                    IF SHR(OPR(K),16)=J THEN DO;                01934800
                                    XPT_LOC = K;                                01934900
                                    IF TRACE THEN OUTPUT = 'REFERENCE '||       01935000
                                       TEMP || ' IS ' || K;                     01935100
                                    GO TO NON_CSE_EXTN;                         01935200
                                 END;                                           01935300
                              END;                                              01935400
                              CTR = CTR + 1 + NO_OPERANDS(CTR);                 01935500
                           END;                                                 01935600
                        END;                                                    01935700
                        ELSE J = 0;                                             01935800
                     END;                                                       01935900
                     ELSE J = J - 1;                                            01936000
                  END;                                                          01936100
               END;                                                             01936200
            END;                                                                01936300
            OPR(PTR) = (OPR(PTR) & "0000FFFB") | SHL(NODE(NODE_PTR),16);        01936400
 /* REMOVE EXTRA BIT*/                                                          01936500
            IF WATCH THEN OUTPUT = 'REPLACE '||PTR||' PTR BY '||                01937000
               (NODE(NODE_PTR) & "FFFF");                                       01938000
                                                                                01939000
            IF (OPR(PTR) & "F1") = XXPT THEN                                    01939100
               IF (NODE(NODE_PTR+2) & TYPE_MASK) = OUTER_TERMINAL_VAC THEN      01939200
               NODE_PTR = (NODE(NODE_PTR+2) & "FFFF") + 1;                      01939300
            SECOND_REF = NODE2(NODE_PTR) < 0;                                   01939400
            IF SECOND_REF THEN NODE2(NODE_PTR) = NODE2(NODE_PTR) - 1;           01939500
            ELSE NODE2(NODE_PTR) = -1;                                          01939600
            TEMP = SHR(NODE(NODE_PTR),16);                                      01940000
            IF ^SECOND_REF OR PTR > TEMP THEN                                   01941000
               NODE(NODE_PTR) = (NODE(NODE_PTR) & "0000FFFF") | SHL(PTR,16);    01942000
 /* SET UP LAST REFERENCE*/                                                     01943000
            CSE_LIST(I) = NODE_PTR;               /* REPLACE WITH PTR */        01944000
            IF TRACE THEN OUTPUT = '      NODE_PTR '||NODE_PTR||                01945000
               ' OPR '||HEX(OPR(PTR),8)||' NODE '||HEX(NODE(NODE_PTR),8)||      01946000
               ' CSE_LIST '||CSE_LIST(I);                                       01947000
         END;                                                                   01948000
         ELSE CSE_LIST(I) = 0;                                                  01949000
      END; /* DO FOR*/                                                          01950000
      DO FOR I = 1 TO D_N_INX;                                                  01950100
         TEMP = SHR(NODE(DIFF_PTR(I)),16);                                      01950200
         IF SHR(OPR(TEMP),3) THEN CALL DETAG(TEMP);                             01950300
      END;                                                                      01950400
      DO FOR I = 1 TO CSE_L_INX;                                                01951000
         NODE_PTR = CSE_LIST(I);                                                01952000
         IF TRACE THEN OUTPUT = '   NODE_PTR = '||NODE_PTR;                     01953000
         IF NODE_PTR ^= 0 THEN DO;                                              01954000
            TEMP = SHR(NODE(NODE_PTR),16);                                      01955000
            IF SHR(OPR(TEMP),3) THEN CALL DETAG(TEMP); /* REMOVE HALMAT TAG FROM01956000
                                                   LAST REFERENCE*/             01957000
            PTR = NODE(NODE_PTR) & "FFFF";                                      01958000
            IF ^OPR(PTR) THEN IF ^TWIN_HALMATTED(PTR) THEN                      01958010
               IF NODE2(NODE_PTR) = -1 THEN DO;                                 01958020
               IF OPOP(PTR) = TSUB & OPOP(LAST_OP(TEMP)) = EXTN THEN DO;        01958030
                  IF NODE2(NODE_PTR+1) = -1 THEN CALL DETAG(PTR);               01958040
               END;                                                             01958050
               ELSE CALL DETAG(PTR);                                            01958060
            END;                                                                01958070
         END;                                                                   01962000
      END;                                                                      01963000
      CSE_L_INX = 0;                                                            01964000
   END RELOCATE_HALMAT;                                                         01965000
