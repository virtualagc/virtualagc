 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DECODEPO.xpl
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
 /* PROCEDURE NAME:  DECODEPOP                                              */
 /* MEMBER NAME:     DECODEPO                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          CTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CURCBLK                                                        */
 /*          HALMAT_REQUESTED                                               */
 /*          LEFTBRACKET                                                    */
 /*          OPR                                                            */
 /*          XSMRK                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CLASS                                                          */
 /*          MESSAGE                                                        */
 /*          NUMOP                                                          */
 /*          OPCODE                                                         */
 /*          SUBCODE                                                        */
 /*          SUBCODE2                                                       */
 /*          TAG                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          FORMAT                                                         */
 /*          HEX                                                            */
 /* CALLED BY:                                                              */
 /*          BLAB_BLOCK                                                     */
 /*          CHICKEN_OUT                                                    */
 /*          OPTIMISE                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> DECODEPOP <==                                                       */
 /*     ==> FORMAT                                                          */
 /*     ==> HEX                                                             */
 /***************************************************************************/
                                                                                00533000
 /* ROUTINE TO DECODE HALMAT OPERATIONS  */                                     00534000
DECODEPOP:                                                                      00535000
   PROCEDURE(CTR);                                                              00536000
      DECLARE CTR BIT(16);                                                      00537000
      CLASS=SHR(OPR(CTR),12)&"F";                                               00538000
      IF CLASS=0 THEN DO;                                                       00539000
         OPCODE=SHR(OPR(CTR),4)&"FF";                                           00540000
         SUBCODE=0;                                                             00541000
      END;                                                                      00542000
      ELSE DO;                                                                  00543000
         OPCODE=SHR(OPR(CTR),4)&"1F";                                           00544000
         SUBCODE=SHR(OPR(CTR),9)&"7";                                           00545000
      END;                                                                      00546000
      SUBCODE2 = SHR(OPR(CTR),4) & "FF";                                        00547000
      TAG=SHR(OPR(CTR),24)&"FF";                                                00548000
      NUMOP=SHR(OPR(CTR),16)&"FF";                                              00549000
      IF HALMAT_REQUESTED THEN DO;                                              00550000
         MESSAGE = FORMAT(TAG,3)                                                00551000
            ||','|| (SHR(OPR(CTR),1) & "7")|| ':' || CURCBLK-1||'.'||CTR;       00552000
         MESSAGE=FORMAT(NUMOP,3)||'),'||MESSAGE;                                00553000
         MESSAGE=HEX(SHR(OPR(CTR),4)&"FFF",3)||LEFTBRACKET||MESSAGE;            00554000
         OUTPUT='         HALMAT: '||MESSAGE;                                   00555000
         IF (OPR(CTR) & "FFF1") = XSMRK THEN                                    00556000
            OUTPUT = '                                        STATEMENT# '      00557000
            || SHR(OPR(CTR+1),16);                                              00558000
      END;                                                                      00559000
   END DECODEPOP;                                                               00560000
