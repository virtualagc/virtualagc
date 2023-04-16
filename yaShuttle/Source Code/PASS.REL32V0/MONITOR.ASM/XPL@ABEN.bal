*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    XPL@ABEN.bal
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

         TITLE 'XPL@ABEN - XPL ABEND ROUTINE'                           00000100
XPL@ABEN CSECT                                                          00000200
         USING *,2                                                      00000300
         LR    3,0                SAVE ABEND CODE                       00000400
         MH    0,H10              DECIMAL LEFT SHIFT 1 FOR ED           00000500
         CVD   0,DBLWRD           TO DECIMAL                            00000600
         ED    CODE,DBLWRD+5      CONVERT 4 DIGITS TO EBCDIC            00000700
         SR    4,4                FOR IC                                00000800
         IC    4,0(1)             GET LENGTH-1 OF MSG                   00000900
         LA    5,L'MSG-1          LENGTH-1 OF MAXIMUM MSG               00001000
         CR    4,5                                                      00001100
         BNH   *+6                BR IF .LE. MAX                        00001200
         LR    4,5                TRUNCATE TO MAX LENGTH                00001300
         EX    4,MOVEMSG          COPY ABEND MSG                        00001400
         LA    4,L'HDR+5(4)       COMPUTE FINAL LENGTH+4                00001500
         STH   4,WTOMSG           SAVE IN PARM LIST                     00001600
         LA    1,WTOMSG           POINT TO SVC 35 PARM LIST             00001700
         LA    4,0(4,1)           POINT TO DESC AND ROUTECDE FIELD      00001800
         MVC   0(4,4),DESCROUT    COPY THEM IN                          00001900
         SVC   35                 WRITE TO PROGRAMMER                   00002000
         ABEND (3),DUMP                                                 00002100
H10      DC    H'10'                                                    00002200
DESCROUT DC    X'00000020'                                              00002300
*                                                                       00002400
MOVEMSG  MVC   MSG(0),1(1)        COPY ABEND MSG TO WTO BUFFER          00002500
WTOMSG   DS    H                                                        00002600
         DC    X'8000'                                                  00002700
HDR      DC    C'XPL ABEND 1234: '                                      00002800
         ORG   *-7                                                      00002900
CODE     DC    X'4020202120'                                            00003000
         ORG                                                            00003100
MSG      DS    CL116                                                    00003200
DBLWRD   DS    D                                                        00003300
         END                                                            00003400
