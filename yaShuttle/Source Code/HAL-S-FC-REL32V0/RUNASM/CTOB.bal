*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CTOB.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'CTOB--CHARACTER TO BIT STRING CONVERSION'               00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
CTOB     AMAIN                                                          00000200
*                                                                       00000300
* CONVERT A CHARACTER STRING, C1, TO A BIT STRING, B2.                  00000400
*                                                                       00000500
         INPUT R2             CHARACTER(C1)                             00000600
         OUTPUT R5            BIT(32) ( THIS IS B1 )                    00000700
         WORK  R3,R6,R7,F0                                              00000800
*                                                                       00000900
* ALGORITHM:                                                            00001000
*   TEMP = 0;                                                           00001100
*   ONES = -1;                                                          00001200
*   IF CURRENT_LENGTH(C1) = 0 THEN                                      00001300
*     DO;                                                               00001400
*       SEND ERROR$(4:29);                                              00001500
*       RETURN 0;                                                       00001600
*     END;                                                              00001700
*   DO FOR I = 1 TO CURRENT_LENGTH(C1);                                 00001800
*     IF C1$(I) = '0' THEN                                              00001900
*       TEMP = SLL(TEMP,1);                                             00002000
*     ELSE                                                              00002100
*       IF C1$(I) = '1' THEN                                            00002200
*         DO;                                                           00002300
*           TEMP = SLDL(TEMP || ONES,1);                                00002400
*           ONES = SRA(ONES,1); /* MAINTAINS # OF ONES IN ONES */       00002500
*         END;                                                          00002600
*       ELSE                                                            00002700
*         IF C1$(I) ^= ' ' THEN                                         00002800
*           DO;                                                         00002900
*             SEND ERROR$(4:29);                                        00003000
*             RETURN 0;                                                 00003100
*           END;                                                        00003200
*   END;                                                                00003300
*   RETURN TEMP;                                                        00003400
*                                                                       00003500
         XR    R6,R6          CLEAR R6 (WILL ACT AS ACCUMULATOR)        00003600
         LH    R3,0(R2)       GET C1 DESCRIPTOR                         00003700
         NHI   R3,X'00FF'     MASK OFF MAXIMUM LENGTH                   00003800
         BZ    ERROR          IF CURRENT LENGTH = 0 THEN ERROR          00003900
         LHI   R7,X'FFFF'     PUT ONES IN R7                            00004000
*                                                                       00004100
LOOP     ABAL  GTBYTE         CHARACTER IN TOP HALF R5                  00004200
         CHI   R5,X'30'       IF CHARACTER IS NOT '0',                  00004300
         BNE   CK1            SEE IF IT IS '1'.                         00004400
         SLL   R6,1           ENTER 0 IN LOW BIT R6                     00004500
         B     DECLEN                                                   00004600
*                                                                       00004700
CK1      CHI   R5,X'31'       IF CHARACTER IS NOT '1',                  00004800
         BNE   CKB            SEE IF IT IS A BLANK                      00004900
         SLDL  R6,1           ENTER 1 IN LOW BIT R6                     00005000
         SRA   R7,1           KEEP PLENTY OF ONES IN R7                 00005100
         B     DECLEN                                                   00005200
*                                                                       00005300
CKB      CHI   R5,X'20'       IF CHARACTER IS NOT BLANK, ERROR:         00005400
         BNE   ERROR          ONLY '0','1',AND ' ' ARE VALID            00005500
*                                                                       00005600
DECLEN   BCT   R3,LOOP        DECREMENT LENGTH AND LOOP IF ^=0          00005700
*                                                                       00005800
EXIT     ST    R6,ARG5        RETURN VALUE IN R5                        00005900
         AEXIT                                                          00006000
*                                                                       00006100
ERROR    AERROR 29            ILLEGAL BIT STRING                        00006200
         XR    R6,R6          FIXUP RETURNS 0                           00006300
         B     EXIT                                                     00006400
*                                                                       00006500
         ACLOSE                                                         00006600
