 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   INITIALI.xpl
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
 /* PROCEDURE NAME:  INITIALISE                                             */
 /* MEMBER NAME:     INITIALI                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          SHRINK_SYMBOLS    LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          #ZAP_BY_TYPE_ARRAYS                                            */
 /*          COMMONSE_LIST                                                  */
 /*          COMM                                                           */
 /*          CURLBLK                                                        */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          LIT_TOP                                                        */
 /*          LITERAL1                                                       */
 /*          LITFILE                                                        */
 /*          LITSIZ                                                         */
 /*          LIT1                                                           */
 /*          MAX_STACK_LEVEL                                                */
 /*          MOVEABLE                                                       */
 /*          OBPS                                                           */
 /*          OPTION_BITS                                                    */
 /*          PAR_SYM                                                        */
 /*          PULL_LOOP_HEAD                                                 */
 /*          REL                                                            */
 /*          STRUCT#                                                        */
 /*          SYM_NAME                                                       */
 /*          SYM_REL                                                        */
 /*          SYM_TAB                                                        */
 /*          SYT_NAME                                                       */
 /*          TOGGLE                                                         */
 /*          VAL_TABLE                                                      */
 /*          XPULL_LOOP_HEAD                                                */
 /*          ZAPIT                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          HALMAT_REQUESTED                                               */
 /*          LEVEL_STACK_VARS                                               */
 /*          LIT_PG                                                         */
 /*          LITMAX                                                         */
 /*          OPTIMIZER_OFF                                                  */
 /*          STATISTICS                                                     */
 /*          SYM_SHRINK                                                     */
 /*          SYT_SIZE                                                       */
 /*          TRACE                                                          */
 /*          VAL_SIZE                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          REFERENCED                                                     */
 /*          SETUP_ZAP_BY_TYPE                                              */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> INITIALISE <==                                                      */
 /*     ==> REFERENCED                                                      */
 /*     ==> SETUP_ZAP_BY_TYPE                                               */
 /***************************************************************************/
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 02/10/95 DAS  27V0/ DR103787 WRONG VALUE LOADED FROM REGISTER FOR       */
 /*               11V0           A STRUCTURE NODE DEREFERENCE               */
 /*                                                                         */
 /* 04/20/04 DCP  32V0/ CR13832  REMOVE UNPRINTED TYPE 1 HAL/S COMPILER     */
 /*               17V0           OPTIONS                                    */
 /*                                                                         */
 /***************************************************************************/
                                                                                00862000
                                                                                00879100
INITIALISE:                                                                     00879200
   PROCEDURE;                                                                   00879300
                                                                                00880000
 /* EJECTS UNREFERENCED SYMBOLS AND SETS UP REL PARALLEL TO SYT TABLE*/         00880010
SHRINK_SYMBOLS:                                                                 00880020
      PROCEDURE;                                                                00880030
         DECLARE INX BIT(16);                                                   00880040
         RECORD_CONSTANT(SYM_SHRINK,COMM(10)+1,MOVEABLE);                       00880050
         RECORD_USED(SYM_SHRINK) = RECORD_ALLOC(SYM_SHRINK);                    00880051
 /* COMM(10) = SYMBOLS DECLARED*/                                               00880060
         SYT_SIZE = 1;                                                          00880070
         REL(0),REL(1) = 1;                                                     00880080
         DO FOR INX = 2 TO COMM(10);                                            00880090
            IF REFERENCED(INX) THEN DO;                                         00880100
               SYT_SIZE = SYT_SIZE + 1;                                         00880110
               REL(INX) = SYT_SIZE;                                             00880120
            END;                                                                00880130
            ELSE REL(INX) = 1;                                                  00880140
            IF TRACE THEN OUTPUT = 'SYMBOL_SHRINKER('                           00880150
               || INX || '):   ' || REL(INX) || '  ' || SYT_NAME(INX);          00880151
         END;                                                                   00880160
      END SHRINK_SYMBOLS;                                                       00880170
                                                                                00880180
                                                                                00880190
      TRACE = (OPTION_BITS & "200") ^= 0;            /*X5*/                     00881000
      OPTIMIZER_OFF = FALSE;                                        /*CR13832*/ 00883000
      HALMAT_REQUESTED = ((TOGGLE & "40") ^= 0) & (OPTIMIZER_OFF = FALSE);      00884000
      HALMAT_REQUESTED = HALMAT_REQUESTED & TRACE;                              00885000
      STATISTICS = (OPTION_BITS & "0100 0000") ^= 0;                 /* X6 */   00886000
      HIGHOPT = (OPTION_BITS & "80") ^= 0; /*DR103787*/                         00887000
      LITMAX = LIT_TOP;                                                         00887000
      LITMAX = LITMAX/LITSIZ;                                                   00888000
      LIT1(0) = FILE(LITFILE,CURLBLK);                                          00889000
      CALL SHRINK_SYMBOLS;                                                      00890000
      SET_RECORD_WIDTH(PAR_SYM,SHL(SYT_SIZE+1,1));                              00890001
      ALLOCATE_SPACE(PAR_SYM,MAX_STACK_LEVEL);                                  00890002
      NEXT_ELEMENT(PAR_SYM);                                                    00890003
      RECORD_CONSTANT(STRUCT#,SHL(SYT_SIZE+1,1),MOVEABLE);                      00890004
      RECORD_USED(STRUCT#) = RECORD_ALLOC(STRUCT#);                             00890005
      VAL_SIZE = SHR(SYT_SIZE,5) + 1;                                           00890006
      SET_RECORD_WIDTH(VAL_TABLE,SHL(VAL_SIZE,2));                              00890007
      ALLOCATE_SPACE(VAL_TABLE,MAX_STACK_LEVEL);                                00890008
      NEXT_ELEMENT(VAL_TABLE);                                                  00890009
      ALLOCATE_SPACE(LEVEL_STACK_VARS, MAX_STACK_LEVEL);                        00890010
      NEXT_ELEMENT(LEVEL_STACK_VARS);                                           00890011
      PULL_LOOP_HEAD(0) = -1;                                                   00890012
      SET_RECORD_WIDTH(OBPS,SHL(VAL_SIZE,2));                                   00890013
      ALLOCATE_SPACE(OBPS,MAX_STACK_LEVEL);                                     00890014
      NEXT_ELEMENT(OBPS);                                                       00890015
      SET_RECORD_WIDTH(ZAPIT,SHL(VAL_SIZE,2));                                  00890016
      RECORD_CONSTANT(ZAPIT,#ZAP_BY_TYPE_ARRAYS-1,MOVEABLE);                    00890017
      RECORD_USED(ZAPIT) = RECORD_ALLOC(ZAPIT);                                 00890018
      ALLOCATE_SPACE(COMMONSE_LIST,1499);                                       00890019
      NEXT_ELEMENT(COMMONSE_LIST);                                              00890020
      CALL SETUP_ZAP_BY_TYPE;                                                   00898160
   END INITIALISE;                                                              00899000
