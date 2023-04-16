 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   UNBRANCH.xpl
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
 /* PROCEDURE NAME:  UNBRANCHABLE                                           */
 /* MEMBER NAME:     UNBRANCH                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /*          CAUSE             BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          FLAGGED           BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          CLASS_GL                                                       */
 /*          FIXF                                                           */
 /*          SYM_LENGTH                                                     */
 /*          SYM_PTR                                                        */
 /*          SYT_PTR                                                        */
 /*          TRUE                                                           */
 /*          VAR_LENGTH                                                     */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          SYM_TAB                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> UNBRANCHABLE <==                                                    */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
                                                                                00816200
UNBRANCHABLE:PROCEDURE(LOC,CAUSE);                                              00816300
      DECLARE (LOC,CAUSE,FLAGGED) BIT(16);                                      00816400
      FLAGGED=FALSE;                                                            00816500
      LOC=FIXF(LOC);                                                            00816600
      DO WHILE LOC>0;                                                           00816700
         IF VAR_LENGTH(LOC)=3 THEN FLAGGED=TRUE;                                00816800
         VAR_LENGTH(LOC)=CAUSE;                                                 00816900
         LOC=SYT_PTR(LOC);                                                      00817000
      END;                                                                      00817100
      IF FLAGGED THEN CALL ERROR(CLASS_GL,CAUSE);                               00817200
   END;                                                                         00817300
