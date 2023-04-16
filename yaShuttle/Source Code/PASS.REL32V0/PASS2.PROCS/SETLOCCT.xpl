 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETLOCCT.xpl
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
 /* PROCEDURE NAME:  SET_LOCCTR                                             */
 /* MEMBER NAME:     SETLOCCT                                               */
 /* INPUT PARAMETERS:                                                       */
 /*       NEST              BIT(16)                                         */
 /*       VALUE             FIXED                                           */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*       CSECT                                                             */
 /*       DATA_REMOTE                                                       */
 /*       NEGMAX                                                            */
 /*       PROCLIMIT                                                         */
 /*       PROGPOINT                                                         */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*       LOCCTR                                                            */
 /*       INDEXNEST                                                         */
 /*       NOT_LEAF                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*       EMITC                                                             */
 /*       EMITW                                                             */
 /* CALLED BY:                                                              */
 /*       GENERATE                                                          */
 /*       GENERATE_CONSTANTS                                                */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SET_LOCCTR <==                                                      */
 /*     ==> EMITC                                                           */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /*         ==> HEX_LOCCTR                                                  */
 /*             ==> HEX                                                     */
 /*         ==> GET_CODE                                                    */
 /*     ==> EMITW                                                           */
 /*         ==> HEX                                                         */
 /*         ==> HEX_LOCCTR ****                                             */
 /*         ==> GET_CODE                                                    */
 /*                                                                         */
 /*                                                                         */
 /*  **** - BRANCH PREVIOUSLY EXPANDED                                      */
 /***************************************************************************/
 /*  REVISION HISTORY :                                                     */  00350000
 /*  ------------------                                                     */  00360000
 /*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */  00370000
 /*                                                                             00380000
 /*07/15/91 DAS   24V0  CR11096 #DREG - NEW #D REGISTER ALLOCATION:         */  00390000
 /*                             R1 OR R3 FOR #D, R2 OTHERWISE               */  00400000
 /*                                                                             00410000
 /*12/23/92 PMA    8V0  *       MERGED 7V0 AND 24V0 COMPILERS.              */
 /*                             * REFERENCE 24V0 CR/DRS                     */
 /*                                                                         */
 /**************************************************************************/   00420000
                                                                                00430000
 /* ROUTINE TO FORCE LOCATION COUNTER TO DESIRED CSECT AND VALUE  */            00440000
SET_LOCCTR:                                                                     00450000
   PROCEDURE(NEST, VALUE);                                                      00460000
      DECLARE NEST BIT(16), VALUE FIXED;                                        00470000
      IF INDEXNEST=NEST THEN IF LOCCTR(INDEXNEST)=VALUE THEN RETURN;            00480000
      INDEXNEST = NEST;                                                         00490000
/*-------------------------------- #DREG ---------------------------*/          00500000
/* TURN OFF REGISTER OPTIMIZATION FOR DATA_REMOTE MODULES & ALL */              00510000
/* INTERNAL PROCEDURES (BY SETTING THE "2" BIT IN NOT_LEAF.)    */              00520000
/* THIS LEAVES R3 AS THE #D POINTER & R2 CANNOT BE BORROWED.    */              00530000
      IF DATA_REMOTE THEN                                                       00540000
      IF (INDEXNEST >= PROGPOINT) & (INDEXNEST <= PROCLIMIT)                    00550000
         THEN NOT_LEAF(INDEXNEST) = NOT_LEAF(INDEXNEST) | 2;                    00560000
/*------------------------------------------------------------------*/          00570000
      LOCCTR(NEST) = VALUE;                                                     00580000
      CALL EMITC(CSECT, NEST);                                                  00590000
      CALL EMITW(NEGMAX | VALUE, 1);                                            00600000
   END SET_LOCCTR;                                                              00610000
