 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DECODEPO.xpl
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
/* PROCEDURE NAME:  DECODEPOP                                              */
/* MEMBER NAME:     DECODEPO                                               */
/* INPUT PARAMETERS:                                                       */
/*          CTR               BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          CODE              BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CONST_ATOMS                                                    */
/*          CURCBLK                                                        */
/*          FOR_ATOMS                                                      */
/*          HALMAT_REQUESTED                                               */
/*          LEFTBRACKET                                                    */
/*          OPR                                                            */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          CLASS                                                          */
/*          COPT                                                           */
/*          HALMAT_OPCODE                                                  */
/*          MESSAGE                                                        */
/*          NUMOP                                                          */
/*          OPCODE                                                         */
/*          SUBCODE                                                        */
/*          TAG                                                            */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          FORMAT                                                         */
/*          HEX                                                            */
/*          POPCODE                                                        */
/*          POPNUM                                                         */
/*          POPTAG                                                         */
/* CALLED BY:                                                              */
/*          NEXTCODE                                                       */
/*          GENERATE                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> DECODEPOP <==                                                       */
/*     ==> FORMAT                                                          */
/*     ==> HEX                                                             */
/*     ==> POPCODE                                                         */
/*     ==> POPNUM                                                          */
/*     ==> POPTAG                                                          */
/***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
 /*                                                                         */
 /*08/03/90 RPC   23V1  102971 %COPY OF A REMOTE NAME                       */
 /***************************************************************************/
                                                                                00621000
 /* ROUTINE TO DECODE HALMAT OPERATIONS  */                                     00621500
DECODEPOP:                                                                      00622000
   PROCEDURE(CTR);                                                              00622500
      DECLARE (CTR, CODE) BIT(16);                                                623000
      CODE = SHR(POPCODE(CTR), 4);                                                623250
      CLASS=SHR(CODE,8) & "F";                                                    623500
      IF CLASS=0 THEN DO;                                                       00624000
         OPCODE = CODE & "FF";                                                    624500
         SUBCODE=0;                                                             00625000
      END;                                                                      00625500
      ELSE DO;                                                                  00626000
         OPCODE = CODE & "1F";                                                    626500
         SUBCODE = SHR(CODE,5) & "7";                                             627000
      END;                                                                      00627500
 /* SAVE THE HALMAT OPCODE FOR USE IN THE DEREF PROCEDURE.     */               00627500
      HALMAT_OPCODE = OPCODE;                                                   00627500
      COPT = SHR(OPR(CTR),1)&"7";                                                 628000
      TAG = POPTAG(CTR);                                                          628500
      NUMOP = POPNUM(CTR);                                                        629000
      IF HALMAT_REQUESTED THEN DO;                                              00629500
         MESSAGE=FORMAT(TAG,3)||','||COPT||':'||CURCBLK-1||'.'||CTR;            00630000
         MESSAGE=FORMAT(NUMOP,3)||'),'||MESSAGE;                                00630500
         MESSAGE=HEX(CODE,3)||LEFTBRACKET||MESSAGE;                               631000
         OUTPUT='         HALMAT: '||MESSAGE;                                   00631500
      END;                                                                      00632000
   END DECODEPOP;                                                               00632500
