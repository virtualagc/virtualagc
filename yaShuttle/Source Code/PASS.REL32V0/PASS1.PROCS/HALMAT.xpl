 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HALMAT.xpl
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
 /* PROCEDURE NAME:  HALMAT                                                 */
 /* MEMBER NAME:     HALMAT                                                 */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ATOM#_FAULT                                                    */
 /*          ATOM#_LIM                                                      */
 /*          ATOMS                                                          */
 /*          CLASS_BB                                                       */
 /*          CONST_ATOMS                                                    */
 /*          CONTROL                                                        */
 /*          CURRENT_ATOM                                                   */
 /*          FALSE                                                          */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_ATOMS                                                      */
 /*          HALMAT_CRAP                                                    */
 /*          HALMAT_OK                                                      */
 /*          NEXT_ATOM#                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          HALMAT_BLAB                                                    */
 /*          HALMAT_OUT                                                     */
 /* CALLED BY:                                                              */
 /*          HALMAT_POP                                                     */
 /*          HALMAT_PIP                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> HALMAT <==                                                          */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> HALMAT_BLAB                                                     */
 /*         ==> HEX                                                         */
 /*         ==> I_FORMAT                                                    */
 /*     ==> HALMAT_OUT                                                      */
 /*         ==> HALMAT_BLAB                                                 */
 /*             ==> HEX                                                     */
 /*             ==> I_FORMAT                                                */
 /***************************************************************************/
                                                                                00801000
HALMAT:                                                                         00801100
   PROCEDURE;                                                                   00801200
      IF CONTROL(0) THEN CALL HALMAT_BLAB(CURRENT_ATOM,NEXT_ATOM#);             00801300
      IF HALMAT_OK THEN DO;                                                     00801400
         IF NEXT_ATOM# = ATOM#_LIM THEN CALL HALMAT_OUT;                        00801500
         IF NEXT_ATOM#=(ATOM#_FAULT - 1) THEN DO;                               00801600
            CALL ERROR(CLASS_BB,1);                                             00801700
            HALMAT_OK=FALSE;                                                    00801800
            HALMAT_CRAP=TRUE;                                                   00801900
         END;                                                                   00802000
         ELSE DO;                                                               00802100
            ATOMS(NEXT_ATOM#)=CURRENT_ATOM;                                     00802200
            NEXT_ATOM#=NEXT_ATOM#+1;                                            00802300
         END;                                                                   00802400
      END;                                                                      00802500
   END HALMAT;                                                                  00802600
