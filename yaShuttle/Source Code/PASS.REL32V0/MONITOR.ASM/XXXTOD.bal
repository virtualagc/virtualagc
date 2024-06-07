*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    XXXTOD.bal
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

CTOD      TITLE 'EXTERNAL CHARACTER TO INTERNAL FLOAT(D) CONVERSION'    00000430
XXXTOD   CSECT                                                          00000440
         USING *,15                                                     00000450
         REGEQU                                                         00000460
         SDR   F0,F0                                                    00000470
         SR    R4,R4                                                    00000480
         SR    R5,R5                                                    00000490
         SR    R6,R6                                                    00000500
         STM   R4,R6,COUNTE                                             00000510
         MVI   SWITCH,NOESIGN                                           00000520
NOSIGNS  CLI   0(R2),C'0'                                               00000530
         BL    NOTNUM                                                   00000540
         TM    SWITCH,IGNORE                                            00000550
         BO    BCT1                                                     00000560
         MVO   X41ETC+1(1),0(1,R2)                                      00000570
         MD    F0,=D'10'                                                00000580
         AD    F0,X41ETC                                                00000590
         CE    F0,=X'4E19999A'                                          00000600
         BL    UPCNT                                                    00000610
         LTR   R5,R5                                                    00000611
         BZ    UPCNT                                                    00000612
         OI    SWITCH,IGNORE                                            00000620
*                                                                       00000630
UPCNT    SR    R4,R5                                                    00000640
         ST    R4,COUNTE                                                00000650
BCT1     LA    R2,1(0,R2)                                               00000660
         BCT   R1,NOSIGNS                                               00000670
         B     TIMES10                                                  00000680
         SPACE 3                                                        00000690
NOTNUM   CLI   0(R2),C'.'                                               00000700
         LA    R5,1                                                     00000710
         BE    BCT1                                                     00000720
         SPACE 3                                                        00000730
TESTFORE CLI   0(R2),C'E'                                               00000740
         BNE   TESTFORH                                                 00000750
         SR    R5,R5                                                    00000760
         B     EXPONENT                                                 00000770
TESTFORH CLI   0(R2),C'H'                                               00000780
         LA    R5,4                                                     00000790
         BE    EXPONENT                                                 00000800
         LA    R5,8                                                     00000810
         SPACE 3                                                        00000820
EXPONENT OI    SWITCH,NOEDIGIT+NOESIGN                                  00000830
         LA    R2,1(0,R2)                                               00000840
         BCTR  R1,0                                                     00000850
         SR    R4,R4                                                    00000860
         CLI   0(R2),C'+'                                               00000870
         BE    UPDATEE                                                  00000880
         CLI   0(R2),C'-'                                               00000890
         BNE   NOSIGNE                                                  00000900
         NI    SWITCH,255-NOESIGN                                       00000910
UPDATEE  LA    R2,1(0,R2)                                               00000920
         BCTR  R1,0                                                     00000930
         SPACE 3                                                        00000940
NOSIGNE  CLI   0(R2),C'0'                                               00000950
         BL    MOREEXPN                                                 00000960
         MH    R4,=H'10'                                                00000970
         IC    R6,0(0,R2)                                               00000980
         AR    R4,R6                                                    00000990
         SH    R4,=H'240'                                               00001000
         LA    R2,1(0,R2)                                               00001010
         BCT   R1,NOSIGNE                                               00001020
         OI    SWITCH,FINISHED                                          00001030
         SPACE 3                                                        00001040
MOREEXPN TM    SWITCH,NOESIGN                                           00001050
         BO    *+6                                                      00001060
         LNR   R4,R4                                                    00001070
         A     R4,COUNTE(R5)                                            00001080
         ST    R4,COUNTE(R5)                                            00001090
         TM    SWITCH,FINISHED                                          00001100
         BZ    TESTFORE                                                 00001110
         SPACE 5                                                        00001120
TIMES16  L     R4,COUNTH                                                00001130
         SLL   R4,2                                                     00001140
         A     R4,COUNTB                                                00001150
         BZ    TIMES10                                                  00001160
         STD   F0,TEMP                                                  00001170
         IC    R6,TEMP                                                  00001180
         BH    ADD16                                                    00001190
         LPR   R4,R4                                                    00001200
         SRDL  R4,2                                                     00001210
         SR    R6,R4                                                    00001220
         STC   R6,TEMP                                                  00001230
         SRL   R5,30                                                    00001240
         LA    R5,1(0,R5)                                               00001250
         BNL   *+12                                                     00001260
         MVI   TEMP,0 ERROR--UNDERFLOW IN H CONVERSION, SIMULATE ERROR  00001270
         LA    5,64                                                     00001280
         LD    F0,TEMP                                                  00001290
         B     *+6                                                      00001300
         HDR   F0,F0                                                    00001310
         BCT   R5,*-2                                                   00001320
         B     TIMES10                                                  00001330
ADD16    SRDL  R4,2                                                     00001340
         AR    R6,R4                                                    00001350
         STC   R6,TEMP                                                  00001360
         SRL   R5,30                                                    00001370
         CH    6,=H'127'                                                00001380
         BNH   *+12                                                     00001390
         MVI   TEMP,X'7F' ERROR--OVERFLOW IN H CONVERSION, SIMULATE ERR 00001400
         LA    5,64                                                     00001410
         LA    R5,1(0,R5)                                               00001420
         LD    F0,TEMP                                                  00001430
         B     *+6                                                      00001440
         ADR   F0,F0                                                    00001450
         BCT   R5,*-2                                                   00001460
         SPACE 5                                                        00001470
TIMES10  L     R6,COUNTE                                                00001480
         LPR   R4,R6                                                    00001490
         BZ    ENDALL                                                   00001500
         LD    F4,=D'1'                                                 00001510
         LD    F2,=D'10'                                                00001520
TIMES10A CH    R4,=H'23'                                                00001530
         BL    TIMES10B                                                 00001540
         LTR   R6,R6                                                    00001550
         BL    DIV1                                                     00001560
MUL1     MD    F0,=D'1E23'                                              00001570
         B     *+8                                                      00001580
DIV1     DD    F0,=D'1E23'                                              00001590
         SH    R4,=H'23'                                                00001600
         B     TIMES10A                                                 00001610
         SPACE                                                          00001620
TIMES10B SRDL  R4,1                                                     00001630
         LTR   R5,R5                                                    00001640
         BNL   *+6                                                      00001650
         MDR   F4,F2                                                    00001660
         LTR   R4,R4                                                    00001670
         BZ    TIMES10C                                                 00001680
         MDR   F2,F2                                                    00001690
         B     TIMES10B                                                 00001700
         SPACE                                                          00001710
TIMES10C LTR   R6,R6                                                    00001720
         BL    DIV2                                                     00001730
MUL2     MDR   F0,F4                                                    00001740
         B     *+6                                                      00001750
DIV2     DDR   F0,F4                                                    00001760
ENDALL   DC    0H'0'                                                    00001770
         BR    14                                                       00001780
         SPACE 5                                                        00001790
TEMP     DS    D                                                        00001800
X41ETC   DC    XL8'4100000000000000'                                    00001810
COUNTE   DS    F                                                        00001820
COUNTH   DS    F                                                        00001830
COUNTB   DS    F                                                        00001840
NOVSIGN  EQU   X'80'                                                    00001850
NOESIGN  EQU   X'40'                                                    00001860
NOVDIGIT EQU   X'20'                                                    00001870
NOEDIGIT EQU   X'10'                                                    00001880
IGNORE   EQU   X'08'                                                    00001890
FINISHED EQU   X'01'                                                    00001900
SWITCH   DC    X'00'                                                    00001910
         END                                                            00001920
