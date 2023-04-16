 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HALMATOU.xpl
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
 /* PROCEDURE NAME:  HALMAT_OUT                                             */
 /* MEMBER NAME:     HALMATOU                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          SAVE_ATOM         FIXED                                        */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ATOMS                                                          */
 /*          CONST_ATOMS                                                    */
 /*          CONTROL                                                        */
 /*          DOUBLE                                                         */
 /*          DOUBLE_SPACE                                                   */
 /*          EJECT_PAGE                                                     */
 /*          HALMAT_FILE                                                    */
 /*          PAGE                                                           */
 /*          TRUE                                                           */
 /*          XXREC                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ATOM#_FAULT                                                    */
 /*          FOR_ATOMS                                                      */
 /*          HALMAT_BLOCK                                                   */
 /*          HALMAT_RELOCATE_FLAG                                           */
 /*          NEXT_ATOM#                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT_BLAB                                                    */
 /* CALLED BY:                                                              */
 /*          HALMAT                                                         */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> HALMAT_OUT <==                                                      */
 /*     ==> HALMAT_BLAB                                                     */
 /*         ==> HEX                                                         */
 /*         ==> I_FORMAT                                                    */
 /***************************************************************************/
                                                                                00798600
HALMAT_OUT:                                                                     00798700
   PROCEDURE;                                                                   00798800
      DECLARE SAVE_ATOM FIXED, I BIT(16);                                       00798900
      IF ATOM#_FAULT<0 THEN ATOM#_FAULT=NEXT_ATOM#-1;    /* FINAL BLOCK */      00799000
      ELSE DO;                                                                  00799100
         NEXT_ATOM# = 2;                                                        00799200
         IF HALMAT_RELOCATE_FLAG THEN RETURN;    /* BACKUP OVER WRAPAROUND */   00799300
         SAVE_ATOM=ATOMS(ATOM#_FAULT);                                          00799400
         ATOMS(ATOM#_FAULT)=SHL(XXREC,4);                                       00799500
      END;                                                                      00799600
      ATOMS(1) = SHL(ATOM#_FAULT, 16) | 1;  /* INSERT PTR TO XREC IN XPXRC */   00799610
      IF CONTROL(11) THEN DO;                                                   00799700
         EJECT_PAGE;                                                            00799800
         OUTPUT='         *** HALMAT BLOCK '||HALMAT_BLOCK||' ***';             00799900
         DOUBLE_SPACE;                                                          00800000
         DO I= 0 TO ATOM#_FAULT;                                                00800100
            CALL HALMAT_BLAB(ATOMS(I),I);                                       00800200
         END;                                                                   00800300
      END;                                                                      00800400
      FILE(HALMAT_FILE,HALMAT_BLOCK) = ATOMS(0);                                00800500
      HALMAT_BLOCK=HALMAT_BLOCK+1;                                              00800600
      ATOMS(ATOM#_FAULT)=SAVE_ATOM;                                             00800700
      HALMAT_RELOCATE_FLAG=TRUE;                                                00800800
   END HALMAT_OUT;                                                              00800900
