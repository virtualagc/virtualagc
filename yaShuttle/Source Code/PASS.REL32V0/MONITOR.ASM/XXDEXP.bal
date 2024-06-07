*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    XXDEXP.bal
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

DEXP     TITLE 'COMPILER''S DEXP ROUTINE'                               00000100
XXDEXP   CSECT                                                          00000200
         REGEQU                                                         00000300
         USING *,15                                                     00000400
        SDR     F2,F2                                                   00000500
        STD     F2,FIELDS                                               00000600
       CE      F0,MAX         MAX = 63*LOG16 = 174.67309                00000700
       BC      2,ERROR           IF ARG GREATER THAN THIS, ERROR        00000800
       CE      F0,MIN         MIN = -65*LOG16 = -180.21867              00000900
       BC      12,SMALL        IF ARG LESS THAN THIS, GIVE UNDERFLOW    00001000
       SPACE                                                            00001100
       LER     F2,F0         DECOMPOSE X = P*LOG2+R,                    00001200
       DE      F2,LOG2H         P MULTIPLE OF 1/16, ACCURATELY          00001300
       AU      F2,SCALER      FIRST (UNDER)ESTIMATE P BY                00001400
       STE     F2,FIELDS        DIVIDING HIGH PART X BY LOG2H           00001500
       ME      F2,LOG2H                                                 00001600
       SDR     F0,F2         LOG(2) = LOG2H+LOG2L,                      00001700
       LD      F2,FIELDS        WHERE LOG2H IS ROUNDED UP.              00001800
       MD      F2,LOG2L           TOTAL PRECISION 80 BITS               00001900
       SDR     F0,F2         X = P'*LOG2+R', /R'/ MAY BE                00002000
       L       R0,FIELDS        SLIGHTLY OVER (LOG2)/16                 00002100
       BC      12,ZMINUS                                                00002200
       SPACE                                                            00002300
       LCR     R0,R0         CASE WHEN X AND R' ARE POSITIVE            00002400
PLUS   BCTR    R0,0             CHANGE SIGN OF P AND SUBTRACT           00002500
       AD      F0,ML216           (LOG2)/16 UNTIL R BECOMES NEGATIVE,   00002600
       BC      2,PLUS                EACH TIME SUBTRACT 1 FROM -P       00002700
       BC      15,READY                                                 00002800
       SPACE                                                            00002900
ZMINUS CD      F0,ML216       CASE WHEN X AND R' 0 OR NEGATIVE          00003000
       BC      2,READY           IF R' SMALLER THAN -(LOG2)/16,         00003100
       SD      F0,ML216           ADD (LOG2)/16, AND INCREMENT          00003200
       SH      R0,INCR              R0 WHOSE LOW PART IS -P             00003300
       SPACE                                                            00003400
READY  SR      R1,R1         R1 = -P = -4A+B+C/16                       00003500
       SRDL    R0,4           C IN HIGH R1                              00003600
       SRL     R1,25                                                    00003700
       SRDL    R0,2           B IN HIGH R1, C IN LOW R1                 00003800
       SLL     R0,24                                                    00003900
       LCR     R2,R0         A (IN SCALE B7) IN R2, CHAR MODIFIER       00004000
       SR      R0,R0                                                    00004100
       SLDL    R0,2           B IN R0, 8*C IN R1                        00004200
       SPACE                                                            00004300
       CE      F0,NEAR0       IF /R/ IS LESS THAN 2**-60, AVOID         00004400
       BC      2,SKIP1           UNDERFLOW BY TAKING  E**R = 1          00004500
       LDR     F2,F0         COMPUTE E**R FOR R BETWEEN                 00004600
       ME      F0,C6            -(LOG2)/16 AND 0 BY MINIMAX             00004700
       AD      F0,C5              POLYNOMIAL APPROX OF DEGREE 6         00004800
       MDR     F0,F2                                                    00004900
       AD      F0,C4                                                    00005000
       MDR     F0,F2                                                    00005100
       AD      F0,C3                                                    00005200
       MDR     F0,F2                                                    00005300
       AD      F0,C2                                                    00005400
       MDR     F0,F2                                                    00005500
       AD      F0,C1                                                    00005600
       MDR     F0,F2         E**R-1 READY                               00005700
       MD      F0,MCONST(R1)                                            00005800
       SPACE                                                            00005900
SKIP1  AD      F0,MCONST(R1) (E**R)*2**(-C/16) READY                    00006000
       SPACE                                                            00006100
       LTR     R0,R0         MULTIPLY BY 2**(-B)                        00006200
       BC      8,SKIP2           BY HALVING B TIMES                     00006300
       HDR     F0,F0                                                    00006400
       BCT     R0,*-2                                                   00006500
       SPACE                                                            00006600
SKIP2  STE     F0,FIELDS      ADD A TO CHARACTERISTIC                   00006700
       A       R2,FIELDS                                                00006800
       ST      R2,FIELDS                                                00006900
       LE      F0,FIELDS                                                00007000
       SPACE                                                            00007100
EXIT     BR    14                                                       00007200
SMALL  DS      0H                                                       00007300
ERROR    LA    15,1                                                     00007400
         BR    14                                                       00007500
       DS      0D                                                       00007600
LOG2H  DC      X'40B17218'     LOG(2) ROUNDED UP                        00007700
MAX    DC      X'42AEAC4E'     174.6731                                 00007800
MIN    DC      X'C2B437DF'    -180.2187                                 00007900
       DS      0D                                                       00008000
FIELDS   DS    D                                                        00008100
NEAR0  DC      X'B2100000'    -2**60                                    00008200
C6     DC      X'3E591893'             0.13594970E-2                    00008300
C5     DC      X'3F2220559A15E158'     0.8331617720039062E-2            00008400
C4     DC      X'3FAAAA9D6AC1D734'     0.4166661730788750E-1            00008500
C3     DC      X'402AAAAAA794AA99'     0.1666666659481656               00008600
C2     DC      X'407FFFFFFFFAB64A'     0.4999999999951906               00008700
C1     DC      X'40FFFFFFFFFFFCFC'     0.9999999999999892               00008800
LOG2L  DC      X'B982E308654361C4'     LOG(2)-LOG2H TO 80 BITS          00008900
MCONST DC      X'4110000000000000'     2**(-0/16)                       00009000
       DC      X'40F5257D152486CD'     2**(-1/16) +F                    00009100
       DC      X'40EAC0C6E7DD243A'     2**(-2/16) +F                    00009200
       DC      X'40E0CCDEEC2A94E1'     2**(-3/16)                       00009300
       DC      X'40D744FCCAD69D6B'     2**(-4/16)                       00009400
       DC      X'40CE248C151F8481'     2**(-5/16)                       00009500
       DC      X'40C5672A115506DB'     2**(-6/16)                       00009600
       DC      X'40BD08A39F580C37'     2**(-7/16)                       00009700
       DC      X'40B504F333F9DE65'     2**(-8/16)                       00009800
       DC      X'40AD583EEA42A14B'     2**(-9/16)                       00009900
       DC      X'40A5FED6A9B15139'     2**(-10/16)                      00010000
       DC      X'409EF5326091A112'     2**(-11/16)                      00010100
       DC      X'409837F0518DB8AA'     2**(-12/16)+F                    00010200
       DC      X'4091C3D373AB11C4'     2**(-13/16)+F                    00010300
       DC      X'408B95C1E3EA8BD7'     2**(-14/16)                      00010400
       DC      X'4085AAC367CC487C'     2**(-15/16)+F                    00010500
ML216  DC      X'BFB17217F7D1CF7A'    -LOG(2)/16   ROUNDED UP           00010600
SCALER DC      X'45000000'                                              00010700
INCR   EQU     C1+2                                                     00010800
BOMB   EQU     C5+4                                                     00010900
       END                                                              00011000
