 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NEXTCODE.xpl
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
/* PROCEDURE NAME:  NEXTCODE                                               */
/* MEMBER NAME:     NEXTCODE                                               */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CONST_ATOMS                                                    */
/*          FOR_ATOMS                                                      */
/*          NUMOP                                                          */
/*          OPR                                                            */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          CTR                                                            */
/*          PP                                                             */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          DECODEPOP                                                      */
/*          AUX_SYNC                                                       */
/* CALLED BY:                                                              */
/*          ERRORS                                                         */
/*          GENERATE                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> NEXTCODE <==                                                        */
/*     ==> DECODEPOP                                                       */
/*         ==> FORMAT                                                      */
/*         ==> HEX                                                         */
/*         ==> POPCODE                                                     */
/*         ==> POPNUM                                                      */
/*         ==> POPTAG                                                      */
/*     ==> AUX_SYNC                                                        */
/*         ==> GET_AUX                                                     */
/*         ==> AUX_LINE                                                    */
/*             ==> GET_AUX                                                 */
/*         ==> AUX_OP                                                      */
/*             ==> GET_AUX                                                 */
/***************************************************************************/
/*  REVISION HISTORY:                                                      */
/*  -----------------                                                      */
/*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
/*12/19/97 SMR   29V0/ 109084 STRUCTURE INITIALIZATION MAY CAUSE           */
/*               14V0         INCORRECT HALMAT                             */
/***************************************************************************/
                                                                                00637500
 /* ROUTINE TO POSITION TO THE NEXT HALMAT OPERATOR  */                         00638000
NEXTCODE:                                                                       00638500
   PROCEDURE;                                                                   00639000
   /*DR109084 - CHECK TO SEE IF OPR(CTR) VALUE WAS WRITTEN OVER IN */
   /*CHECK_VAC.  IF SO, RESTORE IT TO GENERATE THE CORRECT HALMAT. */
   CHECK_OPR:
      PROCEDURE;
         IF VAC_VAL(CTR) THEN DO;
            OPR(CTR) = OPR_VAL(CTR);
         END;
   END CHECK_OPR;
      CTR=CTR+NUMOP+1;                                                          00639500
      PP=PP+1;                                                                  00640000
      CALL CHECK_OPR;     /*DR109084*/
      DO WHILE OPR(CTR);                                                        00640500
         CTR = CTR + 1;                                                         00641000
         CALL CHECK_OPR;  /*DR109084*/
      END;                                                                      00641500
      CALL AUX_SYNC(CTR);                                                         641600
      CALL DECODEPOP(CTR);                                                      00642000
   END NEXTCODE;                                                                00642500
