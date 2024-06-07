 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   KEEPPOIN.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  KEEP_POINTERS                                          */
 /* MEMBER NAME:     KEEPPOIN                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CTR                                                            */
 /*          INIT_SMRK_LINK                                                 */
 /*          NILL                                                           */
 /*          OLD_STMT#                                                      */
 /*          RELS                                                           */
 /*          STMT#                                                          */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          #CELLS                                                         */
 /*          END_NODE                                                       */
 /*          INITIAL_CASE                                                   */
 /*          OLD_SMRK_NODE                                                  */
 /*          SMRK_LINK                                                      */
 /*          SMRK_LIST                                                      */
 /*          START_NODE                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ADD_SMRK_NODE                                                  */
 /*          CREATE_STMT                                                    */
 /*          NEXT_OP                                                        */
 /*          PTR_LOCATE                                                     */
 /* CALLED BY:                                                              */
 /*          GET_NAME_INITIALS                                              */
 /*          PROCESS_HALMAT                                                 */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> KEEP_POINTERS <==                                                   */
 /*     ==> PTR_LOCATE                                                      */
 /*     ==> NEXT_OP                                                         */
 /*     ==> ADD_SMRK_NODE                                                   */
 /*         ==> PTR_LOCATE                                                  */
 /*         ==> GET_CELL                                                    */
 /*         ==> MIN                                                         */
 /*         ==> POPCODE                                                     */
 /*         ==> TYPE_BITS                                                   */
 /*         ==> INDIRECT                                                    */
 /*     ==> CREATE_STMT                                                     */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> DISP                                                        */
 /*         ==> LOCATE                                                      */
 /***************************************************************************/
                                                                                00139810
 /* KEEPS START_NODE, END_NODE, AND SMRK_LIST POINTERS */                       00139820
 /* INVOKES ADD_SMRK_NODE AND CREATE_STMT */                                    00139830
KEEP_POINTERS:                                                                  00139840
   PROCEDURE;                                                                   00139850
      END_NODE = CTR-1;                                                         00139860
      IF STMT# ^= OLD_STMT#                                                     00139870
         THEN DO;                                                               00139880
         CALL CREATE_STMT;                                                      00139890
         IF OLD_SMRK_NODE ^= NILL                                               00139900
            THEN CALL PTR_LOCATE(OLD_SMRK_NODE,RELS);/* RELEASE LAST NODE */    00139910
         #CELLS = 0;                                                            00139920
         INITIAL_CASE = TRUE;                                                   00139930
         SMRK_LIST = NILL; /* RE-INITIALIZE POINTERS */                         00139940
         SMRK_LINK = INIT_SMRK_LINK;                                            00139950
         OLD_SMRK_NODE = NILL;                                                  00139960
      END;                                                                      00139970
      CALL ADD_SMRK_NODE(START_NODE,END_NODE);                                  00139980
      START_NODE = NEXT_OP(CTR);                                                00139990
   END KEEP_POINTERS;                                                           00140000
