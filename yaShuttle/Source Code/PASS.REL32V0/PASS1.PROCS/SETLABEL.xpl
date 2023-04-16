 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETLABEL.xpl
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
 /* PROCEDURE NAME:  SET_LABEL_TYPE                                         */
 /* MEMBER NAME:     SETLABEL                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               FIXED                                        */
 /*          NEWTYPE           FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          LABEL_TYPE_CONFLICT  LABEL                                     */
 /*          LINKUP            LABEL                                        */
 /*          OLDTYPE           FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CLASS_DT                                                       */
 /*          CLASS_PL                                                       */
 /*          COMPOOL_LABEL                                                  */
 /*          DO_LEVEL                                                       */
 /*          DO_STMT#                                                       */
 /*          IND_CALL_LAB                                                   */
 /*          NEST                                                           */
 /*          PROC_LABEL                                                     */
 /*          SYM_LINK1                                                      */
 /*          SYM_LINK2                                                      */
 /*          SYM_NAME                                                       */
 /*          SYM_NEST                                                       */
 /*          SYM_PTR                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_LINK1                                                      */
 /*          SYT_LINK2                                                      */
 /*          SYT_NAME                                                       */
 /*          SYT_NEST                                                       */
 /*          SYT_PTR                                                        */
 /*          SYT_TYPE                                                       */
 /*          UNSPEC_LABEL                                                   */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          SYM_TAB                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SET_LABEL_TYPE <==                                                  */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
 /******************************************************************/
 /*  REVISION HISTORY:                                             */
 /*  -----------------                                             */
 /*  DATE      NAME  REL    DR/CR#    DESCRIPTION                  */
 /*                                                                */
 /*  01/29/01  TKN   31V0/  111350    COMPILER PHASE 3 LISTING     */
 /*                  16V0             INCORRECT                    */
 /*                                                                */
 /******************************************************************/
                                                                                01089100
SET_LABEL_TYPE:                                                                 01089200
   PROCEDURE (LOC, NEWTYPE);                                                    01089300
      DECLARE (LOC, NEWTYPE, OLDTYPE) FIXED;                                    01089400
      DECLARE (I, J) BIT(16);                                                   01089500
                                                                                01089600
      OLDTYPE = SYT_TYPE(LOC);                                                  01089700
      IF NEWTYPE < UNSPEC_LABEL THEN                                            01089800
         DO;      /*  STATEMENT LABEL  */                                       01089900
         IF OLDTYPE > UNSPEC_LABEL THEN                                         01090000
LABEL_TYPE_CONFLICT:                                                            01090100
         CALL ERROR(CLASS_DT,3,SYT_NAME(LOC));                                  01090200
         IF EXTERNAL_MODE ^= 0 THEN SYT_TYPE(LOC) = 0;  /*DR111350*/
         ELSE SYT_TYPE(LOC) = NEWTYPE;                  /*DR111350*/            01090300
      END;                                                                      01090400
      ELSE                                                                      01090500
         DO;      /*  CALLABLE LABEL  */                                        01090600
         IF OLDTYPE < UNSPEC_LABEL THEN GO TO LABEL_TYPE_CONFLICT;              01090700
         IF (OLDTYPE >= PROC_LABEL) & (OLDTYPE <= COMPOOL_LABEL) THEN           01090800
            IF OLDTYPE ^= NEWTYPE THEN                                          01090900
            CALL ERROR(CLASS_DT, 3, SYT_NAME(LOC));                             01091000
         IF OLDTYPE = IND_CALL_LAB THEN                                         01091100
            DO;                                                                 01091200
            J = LOC;                                                            01091300
            I = SYT_PTR(LOC);                                                   01091400
            DO WHILE SYT_NEST(I) >= NEST;                                       01091500
               J = I;                                                           01091600
               IF SYT_TYPE(I) = IND_CALL_LAB THEN                               01091700
                  I = SYT_PTR(I);                                               01091800
               ELSE IF SYT_TYPE(I) = PROC_LABEL THEN                            01091900
                  DO;                                                           01092000
                  SYT_TYPE(I) = IND_CALL_LAB;                                   01092100
                  GO TO LINKUP;                                                 01092200
               END;                                                             01092300
            END;                                                                01092400
LINKUP:                                                                         01092500
            SYT_PTR(J) = LOC;  /* LINK I-CALLS TO REAL DEFINITION */            01092600
            IF SYT_LINK1(J)>0 THEN IF DO_LEVEL>0 THEN                           01092610
               IF DO_STMT#(DO_LEVEL) > SYT_LINK1(J) THEN                        01092620
               CALL ERROR(CLASS_PL, 10);                                        01092630
            IF SYT_LINK1(LOC) >= 0 THEN DO;                                     01092640
               SYT_LINK1(LOC) = -DO_LEVEL;                                      01092650
               SYT_LINK2(LOC) = SYT_LINK2(0);                                   01092660
               SYT_LINK2(0) = LOC;                                              01092670
            END;                                                                01092680
         END;                                                                   01092700
         SYT_TYPE(LOC) = NEWTYPE;                                               01092800
      END;                                                                      01092900
   END SET_LABEL_TYPE;                                                          01093000
