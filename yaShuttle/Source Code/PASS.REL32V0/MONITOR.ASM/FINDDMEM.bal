*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    FINDDMEM.bal
*/ Purpose:     This is a part of the "Monitor" of the HAL/S-FC 
*/              compiler program.
*/ Reference:   "HAL/S Compiler Functional Specification", 
*/              section 2.1.1.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-07 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ are from the Virtual AGC Project.
*/              Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'FINDDMEM - DYNAMICALLY INSERTS MEMBER NAME ON DD CARD ' 00000100
*                                                                       00000200
*INPUT   R1 - XPL DESCRIPTOR TO 16 CHAR STRING.                         00000300
*        1ST 8 CHARS ARE DDNAME, LAST 8 ARE MEMBER NAME                 00000400
*                                                                       00000500
*OUTPUT  - THE SPECIFIED DD CARD IS MODIFIED                            00000600
*                                                                       00000700
FINDDMEM CSECT                                                          00000800
         USING *,15                                                     00000900
         SAVE  (14,12)                                                  00001000
         ST    13,SAVE+4          BOOKKEEPING STUFF                     00001100
         CNOP  0,4                                                      00001200
         BAL   13,START                                                 00001300
         USING *,13                                                     00001400
SAVE     DS    18F                                                      00001500
START    LR    2,1                SAVE DESC IN SAFE REG                 00001600
         SRL   1,24                                                     00001700
         LA    0,15                                                     00001800
         CR    0,1                                                      00001900
         BNE   BADESC                                                   00002000
         CLC   DCBDDNAM,0(2)      IS DDNAME SAME AS LAST TIME?          00002100
         BE    SAMEDD             BR IF YES                             00002200
*        MUST PERFORM RDJFCB ON NEW DDNAME                              00002300
         MVC   DCBDDNAM,0(2)                                            00002400
         RDJFCB (DCB)                                                   00002500
         LTR   15,15                                                    00002600
         BNZ   NODD                                                     00002700
         OI    JFCB+72+4,X'80'                                          00002800
         OI    JFCB+86,X'01'      MAKE OPEN WRITE JFCB BACK OUT         00002900
SAMEDD   MVC   JFCB+44(8),8(2)    COPY MEMBER TO  JFCB                  00003000
         OPEN  (DCB),TYPE=J                                             00003100
         CLOSE (DCB)                                                    00003200
         L     13,SAVE+4                                                00003300
         RETURN (14,12)                                                 00003400
BADESC   XPLABEND 30,'FINDDMEM: 1ST ARG MUST BE STRING, LENGTH 16'      00003500
NODD     XPLABEND 40,'FINDDMEM: REQUESTED DD CARD MISSING'              00003600
DCB      DCB   DSORG=PS,MACRF=R,BUFNO=0,EXLST=EXLST                     00003700
         ORG   DCB+40                                                   00003800
DCBDDNAM DS    CL8                                                      00003900
         ORG                                                            00004000
EXLST    DC    X'87',AL3(JFCB)                                          00004100
JFCB     DC    XL176'0'                                                 00004200
         END                                                            00004300
