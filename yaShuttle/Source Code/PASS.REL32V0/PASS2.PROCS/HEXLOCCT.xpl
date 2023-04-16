 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HEXLOCCT.xpl
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
/* PROCEDURE NAME:  HEX_LOCCTR                                             */
/* MEMBER NAME:     HEXLOCCT                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          CHARACTER                                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          INDEXNEST                                                      */
/*          COLON                                                          */
/*          LOCCTR                                                         */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          HEX                                                            */
/* CALLED BY:                                                              */
/*          EMITC                                                          */
/*          EMITW                                                          */
/*          GENERATE                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> HEX_LOCCTR <==                                                      */
/*     ==> HEX                                                             */
/***************************************************************************/
                                                                                00618000
 /* ROUTINE TO GENERATE READABLE CURRENT LOCATION COUNTER  */                   00618500
HEX_LOCCTR:                                                                     00619000
   PROCEDURE CHARACTER;                                                         00619500
      RETURN HEX(LOCCTR(INDEXNEST),6)||COLON;                                   00620000
   END HEX_LOCCTR;                                                              00620500
