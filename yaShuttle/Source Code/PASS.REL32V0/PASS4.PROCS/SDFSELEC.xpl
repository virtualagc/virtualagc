 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SDFSELEC.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

/***************************************************************************/
/* PROCEDURE NAME:  SDF_SELECT                                             */
/* MEMBER NAME:     SDFSELEC                                               */
/* LOCAL DECLARATIONS:                                                     */
/*          NODE_H            BIT(16)                                      */
/*          NODE_F            FIXED                                        */
/*          TEMP              BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          COMMTABL_FULLWORD                                              */
/*          ADDRESS                                                        */
/*          FALSE                                                          */
/*          TRUE                                                           */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          #EXECS                                                         */
/*          #EXTERNALS                                                     */
/*          #PROCS                                                         */
/*          #STMTS                                                         */
/*          #SYMBOLS                                                       */
/*          ADDR_FLAG                                                      */
/*          BASE_BLOCK_OFFSET                                              */
/*          BASE_BLOCK_PAGE                                                */
/*          BASE_STMT_OFFSET                                               */
/*          BASE_STMT_PAGE                                                 */
/*          BASE_SYMB_OFFSET                                               */
/*          BASE_SYMB_PAGE                                                 */
/*          COMPOOL_FLAG                                                   */
/*          COMPUNIT                                                       */
/*          EMITTED_CNT                                                    */
/*          FC_FLAG                                                        */
/*          FCDATA_FLAG                                                    */
/*          FIRST_STMT                                                     */
/*          KEY_BLOCK                                                      */
/*          KEY_SYMB                                                       */
/*          LAST_PAGE                                                      */
/*          LAST_STMT                                                      */
/*          LOC_ADDR                                                       */
/*          NEW_FLAG                                                       */
/*          NOTRACE_FLAG                                                   */
/*          OVERFLOW_FLAG                                                  */
/*          SDL_FLAG                                                       */
/*          SRN_FLAG                                                       */
/*          SRN_FLAG1                                                      */
/*          SRN_FLAG2                                                      */
/*          STMT_NODE_SIZE                                                 */
/*          STMT_NODES                                                     */
/* CALLED BY:                                                              */
/*          DUMP_SDF                                                       */
/***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 02/19/91 RSJ  23V2  CR11109  REMOVE UNUSED VARIABLES AND REFORMAT       */
 /*                                                                         */
 /* 03/02/01 DAS  31V0 CR13353 ADD SIZE OF BUILTIN FUNCTIONS XREF TABLE     */
 /*               16V0         INTO SDF                                     */
 /*                                                                         */
 /***************************************************************************/
                                                                                00153000
 /* ROUTINE TO 'SELECT' AN SDF FOR PROCESSING */                                00153100
                                                                                00153200
SDF_SELECT:                                                                     00153300
   PROCEDURE;                                                                   00153400
      DECLARE TEMP   BIT(16);                                                   00153500
      BASED   NODE_H BIT(16),                                                   00153600
         NODE_F FIXED;                                                          00153700
                                                                                00153800
      CALL MONITOR(22,"80000007");                                              00153900
      LOC_ADDR = ADDRESS;                                                       00154000
      COREWORD(ADDR(NODE_H)) = ADDRESS;                                         00154100
      COREWORD(ADDR(NODE_F)) = ADDRESS;                                         00154200
      LAST_PAGE = NODE_H(1);                                                    00154300
      EMITTED_CNT = NODE_F(6);                                                  00154400
      #EXTERNALS = NODE_H(7);                                                   00154500
      #PROCS = NODE_H(8);                                                       00154600
      #SYMBOLS = NODE_H(9);                                                     00154700
      FIRST_STMT = NODE_H(26);                                                  00154800
      LAST_STMT = NODE_H(27);                                                   00154900
      #EXECS = NODE_H(28);                                                      00155000
      #STMTS = NODE_H(29);                                                      00155010
      KEY_BLOCK = NODE_H(44);                                                   00155100
      KEY_SYMB = NODE_H(14);                                                    00155200
      COMPUNIT = NODE_H(45);                                                    00155300
      TEMP = NODE_H(0);                                                         00155400
      IF (TEMP & "8000") ^= 0 THEN SRN_FLAG = TRUE;                             00155500
      ELSE SRN_FLAG = FALSE;                                                    00155600
      IF (TEMP & "4000") ^= 0 THEN ADDR_FLAG = TRUE;                            00155700
      ELSE ADDR_FLAG = FALSE;                                                   00155800
      IF (TEMP & "2000") ^= 0 THEN COMPOOL_FLAG = TRUE;                         00155900
      ELSE COMPOOL_FLAG = FALSE;                                                00156000
      IF (TEMP & "1000") ^= 0 THEN FC_FLAG = TRUE;                              00156100
      ELSE FC_FLAG = FALSE;                                                     00156200
      IF (TEMP & "0800") ^= 0 THEN                                              00156300
         OVERFLOW_FLAG = TRUE;                                                  00156400
      ELSE OVERFLOW_FLAG = FALSE;                                               00156500
      IF (TEMP & "0400") ^= 0 THEN                                              00156600
         SRN_FLAG1 = TRUE;                                                      00156700
      ELSE SRN_FLAG1 = FALSE;                                                   00156800
      IF (TEMP & "0200") ^= 0 THEN                                              00156900
         SRN_FLAG2 = TRUE;                                                      00157000
      ELSE SRN_FLAG2 = FALSE;                                                   00157100
      IF (TEMP & "0100") ^= 0 THEN                                              00157200
         NOTRACE_FLAG = TRUE;                                                   00157300
      ELSE NOTRACE_FLAG = FALSE;                                                00157400
      IF (TEMP & "0010") ^= 0 THEN FCDATA_FLAG = TRUE;                          00157500
      ELSE FCDATA_FLAG = FALSE;                                                 00157600
      IF (TEMP & "0008") ^= 0 THEN                                              00157700
         SDL_FLAG = TRUE;                                                       00157800
      ELSE SDL_FLAG = FALSE;                                                    00157900
      IF (TEMP & "0001") ^= 0 THEN                                              00158000
         NEW_FLAG = TRUE;                                                       00158100
      ELSE NEW_FLAG = FALSE;                                                    00158200
      BASE_SYMB_PAGE = SHR(NODE_F(9),16) & "FFFF";                              00158300
      BASE_SYMB_OFFSET = NODE_F(9) & "FFFF";                                    00158400
      BASE_STMT_PAGE = SHR(NODE_F(15),16) & "FFFF";                             00158500
      BASE_STMT_OFFSET = NODE_F(15) & "FFFF";                                   00158600
      BASE_BLOCK_PAGE = SHR(NODE_F(5),16) & "FFFF";                             00158700
      BASE_BLOCK_OFFSET = NODE_F(5) & "FFFF";                                   00158800
      IF SRN_FLAG THEN DO;                                                      00158900
         STMT_NODES = 140;                                                      00159000
         STMT_NODE_SIZE = 12;                                                   00159100
      END;                                                                      00159200
      ELSE DO;                                                                  00159300
         STMT_NODES = 420;                                                      00159400
         STMT_NODE_SIZE = 4;                                                    00159500
      END;                                                                      00159600
      IF VERSION >= 35 THEN DO;                     /*CR13553*/
         #BIFUNCS = NODE_H(92);                     /*CR13353*/
         BASE_BI_PTR = NODE_F(45);                  /*CR13353*/
      END;                                          /*CR13353*/
      ELSE #BIFUNCS = 0;                            /*CR13353*/
   END SDF_SELECT;                                                              00159700
