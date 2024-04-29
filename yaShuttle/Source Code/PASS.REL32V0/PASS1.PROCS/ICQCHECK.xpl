 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ICQCHECK.xpl
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
 /* PROCEDURE NAME:  ICQ_CHECK_TYPE                                         */
 /* MEMBER NAME:     ICQCHECK                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          SYT               BIT(16)                                      */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BIT_TYPE                                                       */
 /*          CHAR_TYPE                                                      */
 /*          CLASS_DI                                                       */
 /*          EVENT_TYPE                                                     */
 /*          IC_TYPE                                                        */
 /*          ID_LOC                                                         */
 /*          INT_TYPE                                                       */
 /*          MAJ_STRUC                                                      */
 /*          MP                                                             */
 /*          NAME_IMPLIED                                                   */
 /*          SCALAR_TYPE                                                    */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_TYPE                                                       */
 /*          TRUE                                                           */
 /*          VAR                                                            */
 /*          XBINT                                                          */
 /*          XNINT                                                          */
 /*          XTINT                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          ICQ_OUTPUT                                                     */
 /*          HALMAT_INIT_CONST                                              */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ICQ_CHECK_TYPE <==                                                  */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
 /*    DATE    DEV  REL    DR/CR/PCR    TITLE                               */
 /*  04/15/95  BAF/ 27V1   DR107302     INCORRECT ERROR MESSAGE FOR NAME    */
 /*            RCK  11V1                 INITIALIZATION                     */
 /*                                                                         */
 /*  08/06/96  SMR  28V0   DR109044      DI17 ERROR EMITTED FOR NAME        */
 /*                 12V0                 CHARACTER(*) PARAMETERS            */
 /***************************************************************************/
                                                                                01003800
ICQ_CHECK_TYPE :                                                                01003900
   PROCEDURE (J,K) BIT(16);                                                     01004000
      DECLARE (SYT,I,J) BIT(16),                                                01004100
         K BIT(1) INITIAL(TRUE);                                                01004200
      I=IC_TYPE(J)&"7F";                                                        01004300
      IF NAME_IMPLIED THEN RETURN XNINT;                /*DR109044*/            01004400
      IF SYT_TYPE(ID_LOC)=MAJ_STRUC THEN RETURN XTINT;  /*DR109044*/            01004500
      ELSE SYT=ID_LOC;                                  /*DR109044*/            01004600
      IF SYT_TYPE(SYT) = CHAR_TYPE THEN DO;  /*  CAN ONLY BE SET TO CHAR  */    01004700
         IF I ^= CHAR_TYPE THEN                                                 01004800
            CALL ERROR(CLASS_DI,6,VAR(MP));                                     01004900
         RETURN XBINT(CHAR_TYPE-BIT_TYPE);                                      01005000
      END;                                                                      01005100
                                                                                01005200
      IF SYT_TYPE(SYT) = BIT_TYPE THEN DO;                                      01005300
         IF I ^= BIT_TYPE THEN                                                  01005400
            CALL ERROR(CLASS_DI,7,VAR(MP));                                     01005500
         RETURN XBINT;                                                          01005600
      END;                                                                      01005700
                                                                                01005800
      IF SYT_TYPE(SYT) = EVENT_TYPE THEN DO;                                    01005900
         IF I ^= BIT_TYPE THEN                                                  01006000
            CALL ERROR(CLASS_DI,7,VAR(MP));                                     01006100
         RETURN XBINT;                                                          01006200
      END;                                                                      01006300
 /*  MUST NOW BE EITHER MATRIX, VECTOR, SCALAR, OR INTEGER  */                  01006400
      IF (I^=INT_TYPE)&(I^=SCALAR_TYPE) THEN                                    01006500
         CALL ERROR(CLASS_DI,8,VAR(MP));                                        01006600
      IF K THEN RETURN XBINT(SYT_TYPE(SYT)-BIT_TYPE);                           01006700
      RETURN XBINT(SCALAR_TYPE-BIT_TYPE);                                       01006800
                                                                                01006900
   END ICQ_CHECK_TYPE;                                                          01007000
