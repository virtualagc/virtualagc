 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CSECTNAM.xpl
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
 /* PROCEDURE NAME:  CSECT_NAME                                             */
 /* MEMBER NAME:     CSECTNAM                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          ENTRY             BIT(16)                                      */
 /*          FLAG              BIT(16)                                      */
 /*          TASK              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ALPHSEQ           CHARACTER;                                   */
 /*          NAMETYPE(7)       CHARACTER;                                   */
 /*          NUMSEQ            CHARACTER;                                   */
 /*          TEMPSTRING        CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OP3                                                            */
 /*          SELFNAMELOC                                                    */
 /*          SRN_BLOCK_RECORD                                               */
 /*          SYM_NAME                                                       */
 /*          SYM_SCOPE                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_NAME                                                       */
 /*          SYT_SCOPE                                                      */
 /*          X10                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          IX1                                                            */
 /*          IX2                                                            */
 /*          OLD_INT_BLOCK#                                                 */
 /*          WORK1                                                          */
 /*          WORK2                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CHAR_INDEX                                                     */
 /* CALLED BY:                                                              */
 /*          INITIALIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CSECT_NAME <==                                                      */
 /*     ==> CHAR_INDEX                                                      */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 04/02/91 DKB  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /* 06/20/91 DKB  7V0   CR11114  MERGE BFS/PASS COMPILERS WITH DR FIXES     */
 /*                                                                         */
 /***************************************************************************/
                                                                                00147300
 /* SUBROUTINE FOR GENERATING CSECT NAMES */                                    00147400
CSECT_NAME:                                                                     00147500
   PROCEDURE (ENTRY, FLAG, TASK) CHARACTER;                                     00147600
      DECLARE (ENTRY, FLAG, TASK) BIT(16);                                      00147700
      DECLARE NAMETYPE(7) CHARACTER INITIAL (                                   00147800
         '$0', '#C', '@0', '#P', '#D', '#T', '#F', 'A0'),                       00147900
         NUMSEQ CHARACTER INITIAL ('0123456789'),                               00148000
         ALPHSEQ CHARACTER INITIAL ('ABCDEFGHIJKLMNOPQRSTUVWXYZ');              00148100
 /* ALPHSEQ IS ALSO CONTINUATION OF NUMSEQ FOR PROGRAM AND TASK NAMES */        00148200
      DECLARE TEMPSTRING CHARACTER;                                             00148300
 /?B  /* CR11114 -- BFS/PASS INTERFACE; CSECT NAMING CONVENTIONS */
      DECLARE FIRST_ENTRY BIT(1) INITIAL(1);
      IF FIRST_ENTRY THEN DO;
         FIRST_ENTRY = 0;
         IF FC THEN NAMETYPE(0) = SUBSTR(NAMETYPE(0), 0, 1);
      END;
 ?/
      TEMPSTRING = SYT_NAME(ENTRY);                                             00148400
      WORK1 = CHAR_INDEX(TEMPSTRING,'_');                                       00148500
      DO WHILE WORK1 > 0;                                                       00148600
         TEMPSTRING=SUBSTR(TEMPSTRING,0,WORK1)||SUBSTR(TEMPSTRING,WORK1+1);     00148700
         WORK1 = CHAR_INDEX(TEMPSTRING,'_');                                    00148800
      END;                                                                      00148900
      IX1 = LENGTH(TEMPSTRING);                                                 00149000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; CSECT NAMING CONVENTIONS */
      IF IX1 >= 6 THEN TEMPSTRING = SUBSTR(TEMPSTRING, 0, 6);                   00149100
      ELSE TEMPSTRING = TEMPSTRING || SUBSTR(X10, 0, 6-IX1);                    00149200
      IF TASK = 0 THEN                                                          00149300
         RETURN NAMETYPE(FLAG) || TEMPSTRING;                                   00149400
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; CSECT NAMING CONVENTIONS */
      IF IX1 >= 7 THEN TEMPSTRING = SUBSTR(TEMPSTRING, 0, 7);
      ELSE TEMPSTRING = TEMPSTRING || SUBSTR(X10, 0, 7-IX1);
      IF TASK = 0 THEN RETURN SUBSTR(NAMETYPE(FLAG) || TEMPSTRING, 0, 8);
      TEMPSTRING = SUBSTR(TEMPSTRING, 0, 6);
 ?/
      IF FLAG = 7 THEN DO;    /* INTERNAL BLOCK NAME */                         00149500
         TASK = TASK - SYT_SCOPE(SELFNAMELOC);                                  00149600
         IX1 = TASK / 10;                                                       00149700
         IX2 = TASK MOD 10;                                                     00149800
         TASK = 0;                                                              00149900
         RETURN SUBSTR(ALPHSEQ,IX1,1)||SUBSTR(NUMSEQ,IX2,1)||TEMPSTRING;        00150000
      END;                                                                      00150100
      TEMPSTRING = SUBSTR(NAMETYPE(FLAG),0,1) || SUBSTR(NUMSEQ,TASK,1) ||       00150200
         TEMPSTRING;                                                            00150300
      TASK = 0;                                                                 00150400
      RETURN TEMPSTRING;                                                        00150500
   END CSECT_NAME;                                                              00150600
