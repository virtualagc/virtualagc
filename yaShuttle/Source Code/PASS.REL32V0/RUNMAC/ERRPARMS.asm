         MACRO                                                          00000100
         ERRPARMS                                                       00000200
         GBLA  &ERRCNT,&ERRNUMS(10),&ERRGRPS(10)                        00000300
         GBLB  &DONE                                                    00000400
         GBLC  &CSECT                                                   00000500
         LCLA  &I                                                       00000600
         LCLC  &S                                                       00000700
         AIF   (&DONE).MEND                                             00000800
&DONE    SETB  1                                                        00000900
         LTORG                                                          00001000
****************ERROR PARAMETER AREA*********************************** 00001100
         AIF   (&ERRCNT EQ 0).NOERROR                                   00001200
&ECSECT  SETC  '#L'.'&CSECT'(1,6)                                       00001300
&ECSECT  CSECT                                                          00001400
         AIF   (&ERRCNT EQ 1).MSG                                       00001500
&S       SETC  'S'                                                      00001600
.MSG     MNOTE '***  &CSECT SENDS THE FOLLOWING ERROR&S'                00001700
.LOOP    ANOP                                                           00001800
&I       SETA  &I+1                                                     00001900
         SPACE 2                                                        00002000
         MNOTE '***  ERROR NUMBER &ERRNUMS(&I) IN GROUP &ERRGRPS(&I)'   00002100
         SPACE 1                                                        00002200
AERROR&I DC    H'20'          SVC CODE FOR SEND ERROR                   00002300
         DC    Y(&ERRGRPS(&I)*256+&ERRNUMS(&I)) 8 BIT GROUP AND NUMBER  00002400
         AIF   (&I LT &ERRCNT).LOOP                                     00002500
         AGO   .COMMON                                                  00002600
.NOERROR MNOTE '***  NO ERRORS SENT IN &CSECT'                          00002700
.COMMON  ANOP                                                           00002800
****************END OF ERROR PARAMETER AREA**************************** 00002900
.MEND    MEND                                                           00003000
