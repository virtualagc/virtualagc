         MACRO                                                          00000100
         WORK    &X                                                     00000200
         GBLB  &LIB,&NOEXTRA                                            00000300
         AIF   ('&X' EQ 'NONE').SPACE                                   00000400
&I       SETA  1                                                        00000500
&LAST    SETA  N'&SYSLIST                                               00000600
.LOOP    AIF   (K'&SYSLIST(&I) NE 2).BADREG                             00000700
&R       SETC  '&SYSLIST(&I)'                                           00000800
         AIF   ('&R'(1,1) NE 'F' AND '&R'(1,1) NE 'R').BADREG           00000900
         AIF   ('&R' EQ 'R0').BADREG                                    00001000
         AIF   ('&R' NE 'F6').TESTD                                     00001100
 MNOTE '***** WARNING: F6 MUST BE PRESERVED ACROSS CALLS'               00001200
.TESTD   AIF   (D'&R).NEXT                                              00001300
&N       SETC  '&R'(2,1)                                                00001400
&R       EQU   &N                                                       00001500
.NEXT    ANOP                                                           00001600
&I       SETA  &I+1                                                     00001700
         AIF   (&I LE &LAST).LOOP                                       00001800
.SPACE   SPACE                                                          00001900
         MEXIT                                                          00002000
.BADREG  MNOTE 4,' ILLEGAL REGISTER SPECIFICATION - &SYSLIST(&I)'       00002100
         AGO   .NEXT                                                    00002200
         MEND                                                           00002300
