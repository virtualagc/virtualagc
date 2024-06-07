 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NEWHALMA.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  NEW_HALMAT_BLOCK                                       */
 /* MEMBER NAME:     NEWHALMA                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK_END                                                      */
 /*          CODEFILE                                                       */
 /*          PULL_LOOP_HEAD                                                 */
 /*          STACKED_BLOCK#                                                 */
 /*          XPULL_LOOP_HEAD                                                */
 /*          XPXRC                                                          */
 /*          XSTACKED_BLOCK#                                                */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          BLOCK_TOP                                                      */
 /*          BLOCK#                                                         */
 /*          CTR                                                            */
 /*          CURCBLK                                                        */
 /*          LAST_SMRK                                                      */
 /*          LAST_ZAP                                                       */
 /*          LEVEL_STACK_VARS                                               */
 /*          NUMOP                                                          */
 /*          OPR                                                            */
 /*          XREC_PTR                                                       */
 /***************************************************************************/
                                                                                00577000
 /* ROUTINE TO GET A NEW BLOCK OF HALMAT  */                                    00578000
NEW_HALMAT_BLOCK:                                                               00579000
   PROCEDURE;                                                                   00580000
      OPR=FILE(CODEFILE,CURCBLK);                                               00581000
      CURCBLK=CURCBLK+1;                                                        00582000
      CTR=0;                                                                    00583000
      LAST_ZAP = 0;                                                             00583010
      LAST_SMRK = 0;                                                            00584000
      STACKED_BLOCK#(0),BLOCK#,BLOCK_TOP = 1;                                   00584010
      IF (OPR & "FFF1") = XPXRC THEN                                            00584020
         XREC_PTR = SHR(OPR(1),16);                                             00584030
      ELSE                                                                      00584040
         XREC_PTR = BLOCK_END;                                                  00585000
      PULL_LOOP_HEAD(0) = -1;                                                   00585010
      NUMOP = SHR(OPR, 16) & "FF";                                              00586000
   END NEW_HALMAT_BLOCK;                                                        00587000
