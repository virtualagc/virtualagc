 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   STABHDR.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  STAB_HDR                                               */
 /* MEMBER NAME:     STABHDR                                                */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CELL_PTR          FIXED                                        */
 /*          CELLSIZE          BIT(16)                                      */
 /*          FIRST_CALL        BIT(8)                                       */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          NODE_F            FIXED                                        */
 /*          NODE_H            BIT(16)                                      */
 /*          SRN_INX           BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ADDR_PRESENT                                                   */
 /*          BLOCK_SYTREF                                                   */
 /*          FALSE                                                          */
 /*          HMAT_OPT                                                       */
 /*          INCL_SRN                                                       */
 /*          MODF                                                           */
 /*          NEST                                                           */
 /*          NILL                                                           */
 /*          RELS                                                           */
 /*          RESV                                                           */
 /*          SRN                                                            */
 /*          SRN_COUNT                                                      */
 /*          SRN_PRESENT                                                    */
 /*          STAB_MARK                                                      */
 /*          STAB_STACK                                                     */
 /*          STAB2_MARK                                                     */
 /*          STAB2_STACK                                                    */
 /*          STMT_DATA_HEAD                                                 */
 /*          STMT_NUM                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          COMM                                                           */
 /*          LAST_STAB_CELL_PTR                                             */
 /*          S                                                              */
 /*          STAB_STACKTOP                                                  */
 /*          STAB2_STACKTOP                                                 */
 /*          STMT_TYPE                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_CELL                                                       */
 /*          LOCATE                                                         */
 /*          PTR_LOCATE                                                     */
 /* CALLED BY:                                                              */
 /*          EMIT_SMRK                                                      */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> STAB_HDR <==                                                        */
 /*     ==> PTR_LOCATE                                                      */
 /*     ==> GET_CELL                                                        */
 /*     ==> LOCATE                                                          */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 07/14/99 DCP  30V0  CR12214  USE THE SAFEST %MACRO THAT WORKS           */
 /*               15V0                                                      */
 /*                                                                         */
 /***************************************************************************/
                                                                                00786700
                                                                                00787500
STAB_HDR:                                                                       00787600
   PROCEDURE;                                                                   00787700
      DECLARE (CELLSIZE,SRN_INX,I,J) BIT(16), CELL_PTR FIXED,                   00787800
         FIRST_CALL BIT(8) INITIAL(1);                                          00787820
      BASED NODE_H BIT(16), NODE_F FIXED;                                       00787840
                                                                                00787860
      CELLSIZE = 32;                                                            00787880
      IF ADDR_PRESENT THEN CELLSIZE=CELLSIZE+16;                                00787900
      SRN_INX = CELLSIZE;                                                       00787920
 /* ADD SPACE FOR HALMAT CELL PTR */                                            00787922
      IF HMAT_OPT                                                               00787924
         THEN CELLSIZE = CELLSIZE+4;                                            00787926
      IF SRN_PRESENT THEN                                                       00787940
         IF SRN_COUNT(2) > 0 THEN CELLSIZE = CELLSIZE + 17;  /*CR12214*/        00787960
      ELSE CELLSIZE = CELLSIZE + 9;                          /*CR12214*/        00787980
      CELL_PTR = GET_CELL(CELLSIZE,ADDR(NODE_H),RESV+MODF);                     00788000
 /* KEEP OFFSETS THE SAME; HALMAT CELL PTR IS AT NODE_F(-1) ASSUMING THAT       00788001
         NODE_F POINTS AT THE CELL (ONLY IF HMAT_OPT) */                        00788002
      IF HMAT_OPT                                                               00788003
         THEN DO;                                                               00788004
         CELL_PTR = CELL_PTR+4;                                                 00788005
         COREWORD(ADDR(NODE_H))=COREWORD(ADDR(NODE_H))+4;                       00788006
      END;                                                                      00788007
      IF FIRST_CALL THEN DO;                                                    00788020
         STMT_DATA_HEAD = CELL_PTR;                                             00788040
         FIRST_CALL = FALSE;                                                    00788060
      END;                                                                      00788080
      IF LAST_STAB_CELL_PTR ^= -1 THEN DO;                                      00788100
         CALL LOCATE(LAST_STAB_CELL_PTR,ADDR(NODE_F),MODF);                     00788120
         NODE_F(0) = CELL_PTR;                                                  00788140
      END;                                                                      00788160
      COREWORD(ADDR(NODE_F)) = ADDR(NODE_H(0));                                 00788180
      IF HMAT_OPT THEN NODE_F(-1) = NILL;                                       00788200
      NODE_F(0) = NILL;                                                         00788210
      NODE_F(1) = LAST_STAB_CELL_PTR;                                           00788220
      NODE_H(12) = 0;                                                           00788240
      NODE_H(13) = STMT_TYPE;                                                   00788250
      NODE_H(14) = STMT_NUM;                                                    00788260
      NODE_H(15) = BLOCK_SYTREF(NEST);                                          00788270
      IF SRN_PRESENT THEN DO;                                                   00788320
         S = SRN(2);                                                            00788340
         CALL INLINE("48",1,0,SRN_INX);                                         00788360
         CALL INLINE("5A",1,0,NODE_H);                                          00788380
         CALL INLINE("58",2,0,S);                                               00788400
         CALL INLINE("D2",0,7,1,0,2,0);           /*CR12214*/                   00788420
         NODE_H(SHR(SRN_INX,1)+4) = SRN_COUNT(2); /*CR12214*/                   00788440
         IF SRN_COUNT(2) > 0 THEN DO;                                           00788460
            S = INCL_SRN(2);                                                    00788480
            SRN_INX = SRN_INX + 10;               /*CR12214*/                   00788500
            CALL INLINE("48", 1, 0, SRN_INX);                                   00788520
            CALL INLINE("5A", 1, 0, NODE_H);                                    00788540
            CALL INLINE("58", 2, 0, S);                                         00788560
            CALL INLINE("D2", 0, 7, 1, 0, 2, 0);  /*CR12214*/                   00788580
            NODE_H(13) = NODE_H(13) | "8000";                                   00788600
         END;                                                                   00788620
      END;                                                                      00788640
      CELLSIZE = STAB2_STACKTOP - STAB2_MARK;                                   00788660
      IF CELLSIZE > 0 THEN DO;                                                  00788680
         NODE_F(2) = GET_CELL(SHL(CELLSIZE,1)+2,ADDR(NODE_H),MODF);             00788700
         NODE_H(0) = CELLSIZE;                                                  00788720
         DO I = STAB2_MARK + 1 TO STAB2_STACKTOP;                               00788740
            J = I - STAB2_MARK;                                                 00788760
            NODE_H(J) = STAB2_STACK(I);                                         00788780
         END;                                                                   00788800
      END;                                                                      00788820
      ELSE NODE_F(2) = -1;                                                      00788840
      CELLSIZE = STAB_STACKTOP - STAB_MARK;                                     00788860
      IF CELLSIZE > 0 THEN DO;                                                  00788880
         NODE_F(3) = GET_CELL(SHL(CELLSIZE,1)+2,ADDR(NODE_H),MODF);             00788900
         NODE_H(0) = CELLSIZE;                                                  00788920
         DO I = STAB_MARK+1 TO STAB_STACKTOP;                                   00788940
            J = I - STAB_MARK;                                                  00788960
            NODE_H(J) = STAB_STACK(I);                                          00788980
         END;                                                                   00789000
      END;                                                                      00789020
      ELSE NODE_F(3) = -1;                                                      00789040
      CALL PTR_LOCATE(CELL_PTR,RELS);                                           00789060
      LAST_STAB_CELL_PTR = CELL_PTR;                                            00789080
      STAB_STACKTOP =STAB_MARK;                                                 00789100
      STAB2_STACKTOP = STAB2_MARK;                                              00789120
      STMT_TYPE=0;                                                              00789700
   END STAB_HDR;                                                                00789800
