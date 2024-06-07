 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NONCONSE.xpl
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
 /* PROCEDURE NAME:  NONCONSEC                                              */
 /* MEMBER NAME:     NONCONSE                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          DSUB_INX          BIT(16)                                      */
 /*          STARSET           BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ALPHA                                                          */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          OPR                                                            */
 /*          TRUE                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          LAST_OPERAND                                                   */
 /* CALLED BY:                                                              */
 /*          PUT_VM_INLINE                                                  */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> NONCONSEC <==                                                       */
 /*     ==> LAST_OPERAND                                                    */
 /***************************************************************************/
                                                                                01496010
 /* TRUE IF DSUB AT OPR(PTR) IS POSSIBLY NONCONSECUTIVE*/                       01496020
NONCONSEC:                                                                      01496030
   PROCEDURE(PTR) BIT(8);                                                       01496040
      DECLARE (DSUB_INX,PTR) BIT(16);                                           01496050
      DECLARE STARSET BIT(8);                                                   01496060
                                                                                01496070
                                                                                01496080
      STARSET = FALSE;                                                          01496090
      DO FOR DSUB_INX = PTR + 2 TO LAST_OPERAND(PTR);                           01496100
         DO CASE ALPHA;                                                         01496110
            STARSET = TRUE;    /* * */                                          01496120
            IF STARSET THEN RETURN TRUE;                                        01496130
            RETURN TRUE;                                                        01496140
            RETURN TRUE;                                                        01496150
         END;                                                                   01496160
      END;                                                                      01496170
      RETURN FALSE;                                                             01496180
   END NONCONSEC;                                                               01496190
