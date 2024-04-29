 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ICQARRA2.xpl
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
 /* PROCEDURE NAME:  ICQ_ARRAYNESS_OUTPUT                                   */
 /* MEMBER NAME:     ICQARRA2                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AUTO_FLAG                                                      */
 /*          EXT_ARRAY                                                      */
 /*          ID_LOC                                                         */
 /*          LAST_POP#                                                      */
 /*          MAJ_STRUC                                                      */
 /*          NAME_IMPLIED                                                   */
 /*          SYM_ARRAY                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_ARRAY                                                      */
 /*          SYT_FLAGS                                                      */
 /*          SYT_TYPE                                                       */
 /*          XADLP                                                          */
 /*          XCO_D                                                          */
 /*          XCO_N                                                          */
 /*          XDLPE                                                          */
 /*          XIDLP                                                          */
 /*          XIMD                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          I                                                              */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT_PIP                                                     */
 /*          HALMAT_FIX_PIP#                                                */
 /*          HALMAT_POP                                                     */
 /* CALLED BY:                                                              */
 /*          HALMAT_INIT_CONST                                              */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ICQ_ARRAYNESS_OUTPUT <==                                            */
 /*     ==> HALMAT_POP                                                      */
 /*         ==> HALMAT                                                      */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HALMAT_BLAB                                             */
 /*                 ==> HEX                                                 */
 /*                 ==> I_FORMAT                                            */
 /*             ==> HALMAT_OUT                                              */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*     ==> HALMAT_PIP                                                      */
 /*         ==> HALMAT                                                      */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HALMAT_BLAB                                             */
 /*                 ==> HEX                                                 */
 /*                 ==> I_FORMAT                                            */
 /*             ==> HALMAT_OUT                                              */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*     ==> HALMAT_FIX_PIP#                                                 */
 /***************************************************************************/
                                                                                00998900
                                                                                00999000
                                                                                01001900
ICQ_ARRAYNESS_OUTPUT :                                                          01002000
   PROCEDURE;                                                                   01002100
      IF NAME_IMPLIED THEN RETURN;                                              01002200
      IF SYT_ARRAY(ID_LOC)^=0 THEN DO;                                          01002300
         IF (SYT_FLAGS(ID_LOC)&AUTO_FLAG)^=0 THEN I=XADLP;                      01002400
         ELSE I=XIDLP;                                                          01002500
         CALL HALMAT_POP(I,0,XCO_D,0);                                          01002600
         IF SYT_TYPE(ID_LOC)=MAJ_STRUC THEN DO;                                 01002700
            I=2;                                                                01002800
            CALL HALMAT_PIP(SYT_ARRAY(ID_LOC),XIMD,0,0);                        01002900
         END;                                                                   01003000
         ELSE DO I=1 TO EXT_ARRAY(SYT_ARRAY(ID_LOC));                           01003100
            CALL HALMAT_PIP(EXT_ARRAY(SYT_ARRAY(ID_LOC)+I),XIMD,0,0);           01003200
         END;                                                                   01003300
         CALL HALMAT_FIX_PIP#(LAST_POP#,I-1);                                   01003400
         CALL HALMAT_POP(XDLPE,0,XCO_N,0);                                      01003500
      END;                                                                      01003600
   END ICQ_ARRAYNESS_OUTPUT;                                                    01003700
