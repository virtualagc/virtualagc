 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   RELEASET.xpl
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
/* PROCEDURE NAME:  RELEASETEMP                                            */
/* MEMBER NAME:     RELEASET                                               */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          DOLEVEL                                                        */
/*          FALSE                                                          */
/*          NARGINDEX                                                      */
/*          PROC_LINK                                                      */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          ARG_STACK_PTR                                                  */
/*          ARRAY_FLAG                                                     */
/*          BNOT_FLAG                                                      */
/*          CALL_LEVEL                                                     */
/*          DOCOPY                                                         */
/*          DOTYPE                                                         */
/*          IX1                                                            */
/*          PMINDEX                                                        */
/*          POINT                                                          */
/*          R_PARM#                                                        */
/*          REMOTE_ADDRS                                                   */
/*          SAVEPTR                                                        */
/*          STACK#                                                         */
/*          STRI_ACTIVE                                                    */
/*          UPPER                                                          */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          SETUP_STACK                                                    */
/*          CLEAR_REGS                                                     */
/* CALLED BY:                                                              */
/*          ERRORS                                                         */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> RELEASETEMP <==                                                     */
/*     ==> SETUP_STACK                                                     */
/*     ==> CLEAR_REGS                                                      */
/*         ==> SET_LINKREG                                                 */
/***************************************************************************/
                                                                                00787000
 /*  SUBROUTINE FOR RELEASING TEMPORARY VARIABLE SPACE */                       00787500
RELEASETEMP:                                                                    00788000
   PROCEDURE;                                                                   00788500
      ARRAY_FLAG, STRI_ACTIVE = FALSE;                                          00789000
      BNOT_FLAG, REMOTE_ADDRS = FALSE;                                          00789500
      SAVEPTR, PMINDEX = 0;                                                     00790000
      ARG_STACK_PTR, DOCOPY, CALL_LEVEL, STACK# = 0;                            00790500
      R_PARM# = -1;                                                             00791000
      IX1 = POINT(PROC_LINK(NARGINDEX));                                        00792000
      DO WHILE IX1 ^= PROC_LINK(NARGINDEX);                                     00792500
         UPPER(IX1)=-1;                                                         00793000
         IX1=POINT(IX1);                                                        00793500
      END;                                                                      00794000
      POINT(PROC_LINK(NARGINDEX)) = PROC_LINK(NARGINDEX);                       00794500
      CALL CLEAR_REGS;                                                          00795000
      CALL SETUP_STACK;                                                         00795500
      DO IX1 = 0 TO DOLEVEL;                                                    00796000
         DOTYPE(IX1) = "FF";                                                    00796500
      END;                                                                      00797000
   END RELEASETEMP;                                                             00797500
