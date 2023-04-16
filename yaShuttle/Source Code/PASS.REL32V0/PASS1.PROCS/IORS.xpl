 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   IORS.xpl
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
 /* PROCEDURE NAME:  IORS                                                   */
 /* MEMBER NAME:     IORS                                                   */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          INT_TYPE                                                       */
 /*          CLASS_ST                                                       */
 /*          MP                                                             */
 /*          PTR                                                            */
 /*          SCALAR_TYPE                                                    */
 /*          VAR                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          PSEUDO_TYPE                                                    */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> IORS <==                                                            */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
                                                                                00861500
                                                                                00861600
IORS:                                                                           00861700
   PROCEDURE (LOC);                                                             00861800
      DECLARE LOC BIT(16);                                                      00861900
      LOC=PTR(LOC);                                                             00862000
      IF PSEUDO_TYPE(LOC)^=INT_TYPE THEN                                        00862100
         IF PSEUDO_TYPE(LOC)^=SCALAR_TYPE THEN DO;                              00862200
         CALL ERROR(CLASS_ST,1,VAR(MP));                                        00862300
         PSEUDO_TYPE(LOC)=INT_TYPE;                                             00862400
      END;                                                                      00862500
   END IORS;                                                                    00862600
