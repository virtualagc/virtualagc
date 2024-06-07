         MACRO                                                          00000100
&NAME    AEXIT &CC=,&COND=                                              00000200
         GBLA  &RET                                                     00000300
         GBLB  &LIB,&CCTYPE,&INTERN,&SECT0                              00000400
         LCLA  &MASK                                                    00000500
&MASK    SETA  7                                                        00000600
&RET     SETA  &RET+1                                                   00000700
*********RETURN TO CALLER********************************************** 00000800
&NAME    DS    0H                                                       00000900
         AIF   ('&CC' EQ '' AND NOT &CCTYPE).OK1                        00001000
         AIF   ('&CC' NE '' AND &CCTYPE).OK1                            00001100
         MNOTE 1,'CONFLICTING CC OPERANDS IN OUTPUT AND AEXIT MACROS'   00001200
.OK1     AIF   (&LIB).LIB                                               00001300
.*       GENERATE EXIT SEQUENCE FOR INTRINSICS                          00001400
         AIF   ('&COND' EQ '').OK2                                      00001500
         MNOTE 4,'COND OPERAND INVALID FOR INTRINSIC'                   00001600
.OK2     AIF   ('&CC' EQ '').LHS                                        00001700
         AIF   ('&CC'(1,2) EQ '(R').LHS                                 00001800
         AIF   ('&CC' EQ 'KEEP').IHLS                                   00001900
         MNOTE 4,'INVALID CC OPERAND FOR INTRINSIC'                     00002000
.LHS     AIF   (&INTERN).SKIP1                                          00002100
         AIF   (NOT D'R3).SKIP3                                         00002200
         LH    3,9(0)         RESTORE LOCAL DATA BASE                   00002300
.SKIP3   AIF   (NOT D'R1).SKIP1                                         00002400
         LH    1,5(0)         RESTORE PROGRAM DATA BASE                 00002500
.SKIP1   AIF   ('&CC' EQ '').BCRE                                       00002600
&R       SETC  '&CC(1)'                                                 00002700
         AIF   ('&R' NE 'R1' AND '&R' NE 'R3').LROK                     00002800
         MNOTE 4,'INVALID REGISTER IN CC= OPERAND'                      00002900
.LROK    LR    &R,&R          SET CONDITION CODE                        00003000
         AGO   .BCRE                                                    00003100
.IHLS    AIF   (&INTERN).BCRE                                           00003200
         AIF   (NOT D'R3).SKIPR3                                        00003300
         IHL   R3,9(0)        LOAD R3, PRESERVING CC                    00003400
         SLL   R3,16          POSITION IN UPPER HALFWORD                00003500
.SKIPR3  AIF   (NOT D'R1).BCRE                                          00003600
         IHL   R1,5(0)        LOAD R1, PRESERVING CC                    00003700
         SLL   R1,16          POSITION IN UPPER HALFWORD                00003800
.BCRE    ANOP                                                           00003900
         AIF   (&SECT0 OR &INTERN).BCR                                  00004000
$RET&RET BCRE  7,4            RETURN TO CALLER                          00004100
*********************************************************************** 00004200
         SPACE                                                          00004300
         MEXIT                                                          00004400
.BCR     ANOP                                                           00004500
$RET&RET BCR   7,4            RETURN TO CALLER                          00004600
*********************************************************************** 00004700
               SPACE                                                    00004800
         MEXIT                                                          00004900
.LIB     AIF   ('&CC' EQ '' OR '&COND' EQ '').OK3                       00005000
         MNOTE 4,'CC AND COND OPERANDS ARE MUTUALLY EXCLUSIVE'          00005100
.OK3     AIF   ('&CC' EQ '').NOCC                                       00005200
         AIF   ('&CC' EQ 'EQ').ZB                                       00005300
         AIF   ('&CC' EQ 'NE').SB                                       00005400
         MNOTE 4,'INVALID CC OPERAND FOR PROCEDURE ROUTINE'             00005500
.ZB      ZB    1(0),X'C000'   SET PSW CC TO 00 (EQ)                     00005600
         AGO   .NOCC                                                    00005700
.SB      SB    1(0),X'C000'   SET PSW CC TO 11 (LT (NE))                00005800
.NOCC    AIF   (T'&COND NE 'N').CONDTST                                 00005900
&MASK    SETA  &COND                                                    00006000
         AGO   .SRET                                                    00006100
.CONDTST AIF   ('&COND' EQ '').SRET                                     00006200
&MASK    SETA  1                                                        00006300
         AIF   ('&COND' EQ 'H' OR '&COND' EQ 'O').SRET                  00006400
&MASK    SETA  2                                                        00006500
         AIF   ('&COND' EQ 'L' OR '&COND' EQ 'M').SRET                  00006600
&MASK    SETA  3                                                        00006700
         AIF   ('&COND' EQ 'NE' OR '&COND' EQ 'NZ').SRET                00006800
&MASK    SETA  4                                                        00006900
         AIF   ('&COND' EQ 'E' OR '&COND' EQ 'Z').SRET                  00007000
&MASK    SETA  5                                                        00007100
    AIF ('&COND' EQ 'HE' OR '&COND' EQ 'NL' OR '&COND' EQ 'NM').SRET    00007200
&MASK    SETA  6                                                        00007300
     AIF ('&COND' EQ 'LE' OR '&COND' EQ 'NH' OR '&COND' EQ 'NO').SRET   00007400
&MASK    SETA  7                                                        00007500
         MNOTE 4,'INVALID COND OPERAND'                                 00007600
.SRET    ANOP                                                           00007700
$RET&RET SRET  &MASK,0        RETURN TO CALLER                          00007800
*********************************************************************** 00007900
         SPACE                                                          00008000
         MEND                                                           00008100
