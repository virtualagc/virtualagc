 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NEEDSTAC.xpl
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
/* PROCEDURE NAME:  NEED_STACK                                             */
/* MEMBER NAME:     NEEDSTAC                                               */
/* INPUT PARAMETERS:                                                       */
/*          IX                BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          STACK_FREEPOINT                                                */
/*          GENERATING                                                     */
/*          TRUE                                                           */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          MAXTEMP                                                        */
/*          NOT_LEAF                                                       */
/*          ORIGIN                                                         */
/*          WORKSEG                                                        */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          NO_BRANCH_AROUND                                               */
/* CALLED BY:                                                              */
/*          INITIALISE                                                     */
/*          GENERATE                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> NEED_STACK <==                                                      */
/*     ==> NO_BRANCH_AROUND                                                */
/*         ==> EMIT_NOP                                                    */
/*             ==> EMITC                                                   */
/*                 ==> FORMAT                                              */
/*                 ==> HEX                                                 */
/*                 ==> HEX_LOCCTR                                          */
/*                     ==> HEX                                             */
/*                 ==> GET_CODE                                            */
/*             ==> EMITW                                                   */
/*                 ==> HEX                                                 */
/*                 ==> HEX_LOCCTR                                          */
/*                     ==> HEX                                             */
/*                 ==> GET_CODE                                            */
/***************************************************************************/
/*  REVISION HISTORY:                                                      */
/*  -----------------                                                      */
/*  DATE      NAME REL    DR NUMBER AND TITLE                              */
/*                                                                         */
/*  05/03/01  JAC  31V0/  DR111362 UNNECESSARY STACK WALKBACK              */
/*                 16V0                                                    */
/*                                                                         */
/*  03/02/04  DCP  32V0/  CR13811  ELIMINATE STACK WALKBACK CAPABILITY     */
/*                 17V0                                                    */
/*                                                                         */
/***************************************************************************/
                                                                                00786750
 /* ROUTINE TO ALLOCATE PRIMARY STACK SPACE AND INHIBIT LEAF PROCEDURE */       00786755
NEED_STACK:                                                                     00786760
   PROCEDURE(IX);                                                               00786765
      DECLARE IX BIT(16);                                                       00786770
      NOT_LEAF(IX) = NOT_LEAF(IX) | TRUE;                                       00786775
      IF MAXTEMP(IX) = 0 THEN  /* NEW STACK */                                  00786780
         WORKSEG(IX), MAXTEMP(IX) = STACK_FREEPOINT;                            00786785
      IF GENERATING THEN IF ORIGIN(IX) > 0 THEN  /* LEAF PROCEDURE PROLOG */    00786790
         ORIGIN(IX) = NO_BRANCH_AROUND(ORIGIN(IX));                             00786795
   END NEED_STACK;                                                              00786800
