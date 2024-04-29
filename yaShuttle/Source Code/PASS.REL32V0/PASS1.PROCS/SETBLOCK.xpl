 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETBLOCK.xpl
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
 /* PROCEDURE NAME:  SET_BLOCK_SRN                                          */
 /* MEMBER NAME:     SETBLOCK                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          SYMNUM            FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          BLOCK_PTR         FIXED                                        */
 /*          BLOCK_SRN         FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK_SRN_DATA                                                 */
 /*          COMM                                                           */
 /*          MAIN_SCOPE                                                     */
 /*          MODF                                                           */
 /*          SRN                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          SRN_BLOCK_RECORD                                               */
 /*          I                                                              */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          LOCATE                                                         */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SET_BLOCK_SRN <==                                                   */
 /*     ==> LOCATE                                                          */
 /***************************************************************************/
SET_BLOCK_SRN:PROCEDURE(SYMNUM);                                                01101010
 /*CONVERT SRN TO FIXED AND INSERT WITH SYM_NUM  IN TABLE FOR PHASE2*/          01101020
      DECLARE BLOCK_PTR FIXED INITIAL(1);                                       01101030
      DECLARE SYMNUM FIXED;                                                     01101040
      DECLARE BLOCK_SRN FIXED;                                                  01101050
      IF MAIN_SCOPE=0 THEN RETURN;   /* STILL EXTERNAL CSECTS*/                 01101060
 /* CONVERT SRN TO FIXED*/                                                      01101070
      BLOCK_SRN=0;                                                              01101080
      DO I=0 TO 5;                                                              01101090
         BLOCK_SRN=(BLOCK_SRN*10)+(BYTE(SRN,I)-BYTE('0'));                      01101100
      END;                                                                      01101110
 /* INCREMENT ENTRY COUNT AND ENTER PAIR*/                                      01101120
      CALL LOCATE(BLOCK_SRN_DATA,ADDR(SRN_BLOCK_RECORD),MODF);                  01101125
      SRN_BLOCK_RECORD(0)=SRN_BLOCK_RECORD(0) +1;                               01101130
      SRN_BLOCK_RECORD(BLOCK_PTR)=SYMNUM;                                       01101140
      SRN_BLOCK_RECORD(BLOCK_PTR+1)=BLOCK_SRN;                                  01101150
      BLOCK_PTR=BLOCK_PTR+2;                                                    01101160
      RETURN;                                                                   01101170
   END SET_BLOCK_SRN;                                                           01101180
