 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BLOCKSUM.xpl
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
 /* PROCEDURE NAME:  BLOCK_SUMMARY                                          */
 /* MEMBER NAME:     BLOCKSUM                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CHECK_IDENT(1538) LABEL                                        */
 /*          CLASS(17)         BIT(8)                                       */
 /*          CONDITION(17)     BIT(8)                                       */
 /*          FIRST_HEADING     CHARACTER;                                   */
 /*          FIRST_TIME        BIT(8)                                       */
 /*          HEADER_ISSUED     BIT(8)                                       */
 /*          HEADING(2)        CHARACTER;                                   */
 /*          I                 BIT(16)                                      */
 /*          INDIRECT(1569)    LABEL                                        */
 /*          ISSUE_HEADER(1563)  LABEL                                      */
 /*          J                 BIT(16)                                      */
 /*          MASK(17)          BIT(8)                                       */
 /*          MASK2(17)         BIT(8)                                       */
 /*          MAX_SUM           MACRO                                        */
 /*          OUT_BLOCK_SUMMARY(1543)  LABEL                                 */
 /*          OUTPUT_IDENT(1560)  LABEL                                      */
 /*          PTR               BIT(16)                                      */
 /*          TYPE(17)          BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK_SYTREF                                                   */
 /*          DOUBLE                                                         */
 /*          EXTERNAL_FLAG                                                  */
 /*          FALSE                                                          */
 /*          IND_CALL_LAB                                                   */
 /*          LABEL_CLASS                                                    */
 /*          NEST                                                           */
 /*          OUT_REF                                                        */
 /*          OUT_REF_FLAGS                                                  */
 /*          OUTER_REF_INDEX                                                */
 /*          OUTER_REF_PTR                                                  */
 /*          OUTER_REF                                                      */
 /*          OUTER_REF_FLAGS                                                */
 /*          SYM_CLASS                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_NAME                                                       */
 /*          SYM_NEST                                                       */
 /*          SYM_PTR                                                        */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_CLASS                                                      */
 /*          SYT_FLAGS                                                      */
 /*          SYT_NAME                                                       */
 /*          SYT_NEST                                                       */
 /*          SYT_PTR                                                        */
 /*          SYT_TYPE                                                       */
 /*          TRUE                                                           */
 /*          X4                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          C                                                              */
 /*          LINE_MAX                                                       */
 /*          OUTER_REF_TABLE                                                */
 /*          PAGE_THROWN                                                    */
 /*          S                                                              */
 /*          TEMP1                                                          */
 /*          TEMP2                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          COMPRESS_OUTER_REF                                             */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> BLOCK_SUMMARY <==                                                   */
 /*     ==> COMPRESS_OUTER_REF                                              */
 /*         ==> MAX                                                         */
 /***************************************************************************/
                                                                                00535300
                                                                                00535400
BLOCK_SUMMARY:                                                                  00535500
   PROCEDURE;                                                                   00535600
      DECLARE (I, J, PTR) BIT(16), (HEADER_ISSUED, FIRST_TIME) BIT(1);          00535700
      DECLARE MAX_SUM LITERALLY '17',                                           00535800
         CLASS(MAX_SUM) BIT(8) INITIAL                                          00535900
         (2,2,2,1,1,2,2,2,3,2,3,0,3,6,7,3,6,7),                                 00536000
         TYPE(MAX_SUM) BIT(8) INITIAL                                           00536100
         ("48","48","48",9,9,"48","48","47",0,"47",0,0,1,0,"3E",1,0,"3E"),      00536200
         CONDITION(MAX_SUM) BIT(8) INITIAL                                      00536300
         (1,1,1,0,0,1,1,0,2,0,2,0,1,2,0,1,2,0),                                 00536400
         MASK(MAX_SUM) BIT(8) INITIAL                                           00536500
         (3,7,5,4,2,1,6,3,3,3,3,0,0,2,2,0,2,2),                                 00536600
         MASK2(MAX_SUM) BIT(8) INITIAL                                          00536700
         (0,0,0,0,0,0,0,1,1,0,0,0,1,1,1,0,0,0),                                 00536800
         HEADING(2) CHARACTER INITIAL(                                          00536900
'PROGRAMS AND TASKS SCHEDULED    PROGRAMS AND TASKS TERMINATED   PROGRAMS AND TA00537000
SKS CANCELLED    EVENTS SIGNALLED, SET OR RESET  EVENTS REFERENCED              00537100
 PROCESS EVENTS REFERENCED       PROCESS PRIORITIES UPDATED      EXTERNAL PROCED00537200
URES CALLED      ',                                                             00537300
'EXTERNAL FUNCTIONS INVOKED      OUTER PROCEDURES CALLED         OUTER FUNCTIONS00537400
 INVOKED         ERRORS SENT                     COMPOOL VARIABLES USED         00537500
 COMPOOL REPLACE MACROS USED     COMPOOL STRUCTURE TEMPLATES USEDOUTER VARIABLES00537600
 USED            ',                                                             00537700
         'OUTER REPLACE MACROS USED       OUTER STRUCTURE TEMPLATES USED  ');   00537800
      DECLARE FIRST_HEADING CHARACTER INITIAL(                                  00537900
         '-**** B L O C K   S U M M A R Y ****');                               00538000
                                                                                00538100
INDIRECT:                                                                       00538200
      PROCEDURE;                                                                00538300
         IF SYT_CLASS(PTR) ^= LABEL_CLASS THEN RETURN;                          00538400
         DO WHILE SYT_TYPE(PTR) = IND_CALL_LAB;                                 00538500
            PTR = SYT_PTR(PTR);                                                 00538600
         END;                                                                   00538700
      END INDIRECT;                                                             00538800
                                                                                00538900
ISSUE_HEADER:                                                                   00539000
      PROCEDURE;                                                                00539100
         IF HEADER_ISSUED THEN RETURN;                                          00539200
         IF FIRST_TIME THEN DO;                                                 00539300
            OUTPUT(1) = FIRST_HEADING;                                          00539400
            FIRST_TIME = FALSE;                                                 00539500
         END;                                                                   00539600
         TEMP1 = SHR(I, 3);                                                     00539700
         TEMP2 = SHL(I - SHL(TEMP1, 3), 5);                                     00539800
         OUTPUT(1) = DOUBLE || SUBSTR(HEADING(TEMP1), TEMP2, 32);               00539900
         HEADER_ISSUED = TRUE;                                                  00540000
      END ISSUE_HEADER;                                                         00540100
                                                                                00540200
OUTPUT_IDENT:                                                                   00540300
      PROCEDURE(FLAG);                                                          00540400
         DECLARE FLAG BIT(1);                                                   00540500
         CALL ISSUE_HEADER;                                                     00540600
         IF FLAG THEN DO;                                                       00540700
            IF PTR="3FFF" THEN S='*:*';                                         00540800
            ELSE DO;                                                            00540900
               S=SHR(PTR,6)||':';                                               00541000
               IF (PTR&"3F")="3F" THEN S=S||'*';                                00541100
               ELSE S=S||(PTR&"3F");                                            00541200
            END;                                                                00541300
         END;                                                                   00541400
         ELSE IF FLAG = 4 THEN S = SYT_NAME(PTR) || '*';                        00541500
         ELSE S = SYT_NAME(PTR);                                                00541600
         IF LENGTH(S) + LENGTH(C) > 130 THEN DO;                                00541700
            OUTPUT = C;                                                         00541800
            C = '';                                                             00541900
            C(1) = X4;                                                          00542000
         END;                                                                   00542100
         C = C || C(1) || S;                                                    00542200
         C(1) = ', ';                                                           00542300
         FLAG = FALSE;                                                          00542400
      END OUTPUT_IDENT;                                                         00542500
                                                                                00542600
CHECK_IDENT:                                                                    00542700
      PROCEDURE;                                                                00542800
         IF SYT_NEST(PTR) ^< NEST THEN RETURN;                                  00542900
         IF MASK2(I) THEN IF SYT_NEST(PTR) > 0 THEN RETURN;                     00543000
         IF MASK(I) ^= 0 THEN IF TEMP1 ^= MASK(I) THEN RETURN; ELSE TEMP1 = 0;  00543100
            CALL OUTPUT_IDENT(TEMP1&6);                                         00543200
         OUTER_REF(J) = -1;                                                     00543300
      END CHECK_IDENT;                                                          00543400
                                                                                00543500
OUT_BLOCK_SUMMARY:                                                              00543600
      PROCEDURE;                                                                00543700
         DO J = OUTER_REF_PTR(NEST) & "7FFF" TO OUTER_REF_INDEX;                00543800
            IF OUTER_REF(J) = -1 THEN GO TO NEXT_ENTRY;                         00543900
            PTR = OUTER_REF(J);                                                 00544000
            TEMP1 = OUTER_REF_FLAGS(J);                                         00544010
            IF TEMP1=0 THEN DO;                                                 00544200
               IF CLASS(I)=0 THEN DO;                                           00544300
                  CALL OUTPUT_IDENT(TRUE);                                      00544400
                  OUTER_REF(J) = -1;                                            00544500
               END;                                                             00544600
            END;                                                                00544700
            ELSE DO;                                                            00544800
               CALL INDIRECT;                                                   00544900
               IF SYT_CLASS(PTR)<=CLASS(I) THEN                                 00545000
                  DO CASE CONDITION(I);                                         00545100
                  IF SYT_TYPE(PTR) = TYPE(I) THEN CALL CHECK_IDENT;             00545200
                  IF SYT_TYPE(PTR) >= TYPE(I) THEN CALL CHECK_IDENT;            00545300
                  IF SYT_CLASS(PTR)=CLASS(I) THEN CALL CHECK_IDENT;             00545400
               END;                                                             00545500
            END;                                                                00545600
NEXT_ENTRY:                                                                     00545700
         END;                                                                   00545800
      END OUT_BLOCK_SUMMARY;                                                    00545900
                                                                                00546000
                                                                                00546100
      CALL COMPRESS_OUTER_REF;                                                  00546200
      FIRST_TIME = TRUE;                                                        00546300
      DO I = 0 TO MAX_SUM;                                                      00546400
         C = '';                                                                00546500
         C(1) = X4;                                                             00546600
         HEADER_ISSUED = FALSE;                                                 00546700
         CALL OUT_BLOCK_SUMMARY;                                                00546800
         IF LENGTH(C) ^= 0 THEN OUTPUT = C;                                     00546900
      END;  /* DO I  */                                                         00547000
      IF (SYT_FLAGS(BLOCK_SYTREF(NEST)) & EXTERNAL_FLAG) = 0 THEN DO;           00547100
         LINE_MAX = 0;                                                          00547200
         PAGE_THROWN=TRUE;                                                      00547300
      END;                                                                      00547400
   END BLOCK_SUMMARY;                                                           00547500
