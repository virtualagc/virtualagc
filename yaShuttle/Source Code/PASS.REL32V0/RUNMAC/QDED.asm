         MACRO                                                          00000010
&L       QDED   &R,&A                                                   00000020
         GBLB  &QDEDOK                                                  00000030
         AIF   (&QDEDOK).DOIT                                           00000040
         MNOTE 12,'QDED OPTION NOT SPECIFIED IN AMAIN OR INTSIC=YES SPEX00000050
               CIFIED'                                                  00000060
         MEXIT                                                          00000070
.DOIT    ANOP                                                           00000080
&L       STED  &R,QARGA                                                 00000090
         STED  6,QARGB                                                  00000100
         DE    &R,&A                                                    00000110
.*MOD??* SER   &R+1,&R+1   DWE 9/28                                     00000115
         LER   6,&R                                                     00000120
         LER   7,&R+1                                                   00000130
         MED   6,&A                                                     00000140
         SED   6,QARGA                                                  00000150
         DE    6,&A                                                     00000160
         SEDR  &R,6                                                     00000170
         LED   6,QARGB                                                  00000180
         MEND                                                           00000190
