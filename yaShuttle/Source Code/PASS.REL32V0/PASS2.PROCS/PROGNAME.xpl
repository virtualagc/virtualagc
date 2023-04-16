 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PROGNAME.xpl
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
/* PROCEDURE NAME:  PROGNAME                                               */
/* MEMBER NAME:     PROGNAME                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          CHARACTER                                                      */
/* INPUT PARAMETERS:                                                       */
/*          ENTRY             BIT(16)                                      */
/*          FLAG              BIT(16)                                      */
/*          TASK              BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          ALPHSEQ           CHARACTER;                                   */
/*          NAMETYPE(11)      CHARACTER;                                   */
/*          NUMSEQ            CHARACTER;                                   */
/*          TEMPSTRING        CHARACTER;                                   */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          NONHAL_FLAG                                                    */
/*          PROGPOINT                                                      */
/*          SYM_FLAGS                                                      */
/*          SYM_NAME                                                       */
/*          SYM_TAB                                                        */
/*          SYT_FLAGS                                                      */
/*          SYT_NAME                                                       */
/*          Z_LINKAGE                                                      */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          IX1                                                            */
/*          IX2                                                            */
/*          WORK1                                                          */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          CHAR_INDEX                                                     */
/* CALLED BY:                                                              */
/*          INITIALISE                                                     */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> PROGNAME <==                                                        */
/*     ==> CHAR_INDEX                                                      */
/***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 DKB  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /* 03/04/91 RAH  23V2  CR11109  CLEANUP OF COMPILER SOURCE CODE            */
 /*                                                                         */
 /* 02/18/92 ADM   7V0  CR11114   MERGE PASS/BFS COMPILERS WITH DR FIXES    */
 /*                                                                         */
 /* 04/11/94 JAC  26V0  DR108643  'INCREM' INCORRECTLY LISTED IN            */
 /*               10V0            SDF LISTING AS 'NONHAL'                   */
 /*                                                                         */
 /***************************************************************************/
                                                                                00875000
 /*  SUBROUTINE FOR GENERATING PROGRAM NAMES  */                                00875500
PROGNAME:                                                                       00876000
   PROCEDURE (ENTRY, FLAG, TASK) CHARACTER;                                     00876500
      DECLARE (ENTRY, FLAG, TASK) BIT(16);                                      00877000
      DECLARE NAMETYPE(11) CHARACTER INITIAL (                                  00877500
        '$0', '#C', '@0', '#P', '#D', '#T', '#F', 'A0', '#Z', '#E', '#X', '#R'),00878000
 /?P     /* CR11114 -- BFS/PASS INTERFACE; NAMING CONVENTIONS */
         NUMSEQ CHARACTER INITIAL ('0123456789'),                               00879000
 ?/
         ALPHSEQ CHARACTER INITIAL ('ABCDEFGHIJKLMNOPQRSTUVWXYZ');              00879500
 /* ALPHSEQ IS ALSO CONTINUATION OF NUMSEQ FOR PROGRAM AND TASK NAMES */        00880000
 /?P     /* CR11114 -- BFS/PASS INTERFACE; NAMING CONVENTIONS */
      DECLARE TEMPSTRING CHARACTER;                                             00880500
      TEMPSTRING=SYT_NAME(ENTRY);                                               00881000
      WORK1=CHAR_INDEX(TEMPSTRING,'_');                                         00881500
      DO WHILE WORK1>0;                                                         00882000
         TEMPSTRING=SUBSTR(TEMPSTRING,0,WORK1)||SUBSTR(TEMPSTRING,WORK1+1);     00882500
         WORK1=CHAR_INDEX(TEMPSTRING,'_');                                      00883000
      END;                                                                      00883500
      IX1=LENGTH(TEMPSTRING);                                                   00884000
      IF IX1 > 6 THEN IX1 = 6;                                                  00884500
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; NAMING CONVENTIONS */
      DECLARE (TEMPSTRING, X_CHAR) CHARACTER;
      TEMPSTRING = REM_UNDIES(SYT_NAME(ENTRY));
      IX1=LENGTH(TEMPSTRING);                                                   00884000

      IF IX1 > 6 THEN DO;
         IX1 = 6;
         X_CHAR = SUBSTR(TEMPSTRING, 6, 1);
      END;
      ELSE
         X_CHAR = '';

 ?/
      TEMPSTRING = SUBSTR(TEMPSTRING, 0, IX1);                                  00885000
      IF (SYT_FLAGS2(ENTRY) & NONHAL_FLAG) ^= 0 THEN /* DR108643 */             00885500
         RETURN TEMPSTRING;                                                     00886000
      IF TASK = 0 THEN                                                          00886500
         IF FLAG = 1 & PROGPOINT = 0 & Z_LINKAGE THEN                           00887000
         RETURN NAMETYPE(8) || TEMPSTRING;                                      00887500
 /?P  /* CR11114 -- BFS/PASS INTERFACE; NAMING CONVENTIONS */
      ELSE RETURN NAMETYPE(FLAG) || TEMPSTRING;                                 00888000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; NAMING CONVENTIONS */
      ELSE DO;
         IF (FLAG = 0) | (FLAG = 2) THEN
            RETURN SUBSTR(NAMETYPE(FLAG), 0, 1) || TEMPSTRING || X_CHAR;
         ELSE
            RETURN NAMETYPE(FLAG) || TEMPSTRING;
      END;
 ?/
      IF FLAG = 7 THEN DO;  /* INTERNAL BLOCK NAME  */                          00888500
         TASK = TASK - PROGPOINT;                                               00889450
         IX1 = TASK / 10;                                                       00889500
         IX2 = TASK MOD 10;                                                     00890000
         TASK = 0;                                                              00890500
         RETURN SUBSTR(ALPHSEQ, IX1, 1) || SUBSTR(NUMSEQ, IX2, 1) || TEMPSTRING;00891000
      END;                                                                      00891500
 /?B  /* CR11114 -- BFS/PASS INTERFACE; NAMING CONVENTIONS */
      IF (FLAG = 0) | (FLAG = 2) THEN
         RETURN SUBSTR(NAMETYPE(FLAG), 0, 1) || TEMPSTRING || X_CHAR;
 ?/
      TEMPSTRING = SUBSTR(NAMETYPE(FLAG),0,1) || SUBSTR(NUMSEQ, TASK, 1) ||     00892000
         TEMPSTRING;                                                            00892500
      TASK = 0;                                                                 00893000
      RETURN TEMPSTRING;                                                        00893500
   END PROGNAME;                                                                00894000
