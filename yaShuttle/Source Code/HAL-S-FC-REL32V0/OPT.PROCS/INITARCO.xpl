 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   INITARCO.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  INIT_ARCONFS                                           */
 /* MEMBER NAME:     INITARCO                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          C_TRACE                                                        */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CA_INX                                                         */
 /*          ARRAYNESS_CONFLICT                                             */
 /*          CR_INX                                                         */
 /* CALLED BY:                                                              */
 /*          PUSH_LOOP_STACKS                                               */
 /*          FINAL_PASS                                                     */
 /***************************************************************************/
 /* INITIALIZES ARRAY CONFLICT STACKS */                                        01893310
INIT_ARCONFS:                                                                   01893320
   PROCEDURE;                                                                   01893330
      ARRAYNESS_CONFLICT = FALSE;                                               01893340
      CA_INX , CR_INX = 0;                                                      01893350
      IF C_TRACE THEN OUTPUT = 'INIT_ARCONFS';                                  01893360
   END INIT_ARCONFS;                                                            01893370
