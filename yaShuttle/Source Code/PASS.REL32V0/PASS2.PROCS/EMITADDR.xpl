 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EMITADDR.xpl
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
/* PROCEDURE NAME:  EMITADDR                                               */
/* MEMBER NAME:     EMITADDR                                               */
/* INPUT PARAMETERS:                                                       */
/*          CTR               BIT(16)                                      */
/*          VAL               FIXED                                        */
/*          OP                BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          FLAG              BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          DADDR                                                          */
/*          HADDR                                                          */
/*          INDEXNEST                                                      */
/*          RLD                                                            */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          LOCCTR                                                         */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          EMITC                                                          */
/*          EMITW                                                          */
/* CALLED BY:                                                              */
/*          GENERATE                                                       */
/*          GENERATE_CONSTANTS                                             */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> EMITADDR <==                                                        */
/*     ==> EMITC                                                           */
/*         ==> FORMAT                                                      */
/*         ==> HEX                                                         */
/*         ==> HEX_LOCCTR                                                  */
/*             ==> HEX                                                     */
/*         ==> GET_CODE                                                    */
/*     ==> EMITW                                                           */
/*         ==> HEX                                                         */
/*         ==> HEX_LOCCTR                                                  */
/*             ==> HEX                                                     */
/*         ==> GET_CODE                                                    */
/***************************************************************************/
                                                                                00776500
 /* ROUTINE TO EMIT ADDRESSES IN THE PROGRAM STREAM  */                         00777000
EMITADDR:                                                                       00777500
   PROCEDURE(CTR, VAL, OP);                                                     00778000
      DECLARE VAL FIXED, (CTR, OP, FLAG) BIT(16);                               00778500
      FLAG = 0;                                                                 00779000
      IF VAL < 0 THEN DO;                                                       00779500
         IF OP ^= DADDR THEN                                                    00780000
            VAL = -VAL;                                                         00780500
         ELSE VAL = (-VAL&"FFFF0000")|(VAL&"FFFF");                             00781000
         FLAG = 8;                                                              00781500
      END;                                                                      00782000
      CALL EMITC(RLD, CTR + SHL(FLAG,12));                                      00782500
      CTR = CTR & "FFF";  /* ELIMINATE POSSIBLE FLAG BITS  */                     782600
      IF OP ^= 0 THEN                                                           00783000
         CALL EMITC(OP, CTR);                                                   00783500
      ELSE CALL EMITC(HADDR, CTR);                                              00784000
      CALL EMITW(VAL, 1);                                                       00784500
      IF OP ^= DADDR THEN LOCCTR(INDEXNEST) = LOCCTR(INDEXNEST) + 1;            00785000
      ELSE LOCCTR(INDEXNEST) = LOCCTR(INDEXNEST) + 2;                           00785500
      VAL, OP = 0;                                                              00786000
   END EMITADDR;                                                                00786500
