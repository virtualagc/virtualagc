         MACRO                                                          00000100
         ACLOSE                                                         00000200
         GBLA  &ENTCNT                                                  00000300
         GBLB  &INPUT(20),&OUTPUT(20)                                   00000400
         GBLC  &NAMES(20)                                               00000500
         ERRPARMS                                                       00000600
&I       SETA  1                                                        00000700
.LOOP    AIF   (&INPUT(&I)).INOK                                        00000800
         MNOTE 1,'INPUT NOT SPECIFIED FOR &NAMES(&I)'                   00000900
.INOK    AIF   (&OUTPUT(&I)).OUTOK                                      00001000
         MNOTE 1,'OUTPUT NOT SPECIFIED FOR &NAMES(&I)'                  00001100
.OUTOK   ANOP                                                           00001200
&I       SETA  &I+1                                                     00001300
         AIF   (&I LE &ENTCNT).LOOP                                     00001400
         END                                                            00001500
         MEND                                                           00001600
