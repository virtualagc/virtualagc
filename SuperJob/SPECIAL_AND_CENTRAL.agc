### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    MAIN.agc
## Purpose:     Part of the source code for SUPER JOB, a program developed
##              at Raytheon to exercise the Auxiliary Memory for the AGC.
##              It appears to have been developed from scratch, and shares
##              no heritage with any programs from MIT. It was also built
##              with a Raytheon assembler rather than YUL or GAP.
## Reference:   pp. D-2 - D-4
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     https://www.ibiblio.org/apollo/index.html
## Page Scans:  http://www.ibiblio.org/apollo/Documents/R68-4125-Volume2.pdf
## Mod history: 2017-01-27 MAS  Created and transcribed, then corrected
##                              errors until assembly succeeded. Octals
##                              have not yet been extracted, so errors
##                              almost certainly remain.

## Page D-2
# C       SPECIAL AND CENTRAL
A               =       0000
L               =       0001
Q               =       0002
EB              =       0003
FB              =       0004
Z               =       0005
BB              =       0006
ZEROS           =       0007
ARUPT           =       0010
LRUPT           =       0011
QRUPT           =       0012
ZRUPT           =       0015
BBRUPT          =       0016
BRUPT           =       0017
CYR             =       0020
SR              =       0021
CYL             =       0022
EDOP            =       0023
TIME2           =       0024
TIME1           =       0025
TIME3           =       0026
TIME4           =       0027
TIME5           =       0030
TIME6           =       0031
CDUX            =       0032
CDUY            =       0033
CDUZ            =       0034
OPTY            =       0035
OPTX            =       0036
PIPAX           =       0037
PIPAY           =       0040
PIPAZ           =       0041
BMAGX           =       0042
BMAGY           =       0043
BMAGZ           =       0044
INLINK          =       0045
RNRAD           =       0046
GYROCTR         =       0047
CDUXCMD         =       0050
CDUYCMD         =       0051
CDUZCMD         =       0052
OPTYCMD         =       0053
OPTXCMD         =       0054
EMSD            =       0055
LEMONM          =       0056
OUTLINK         =       0057
ALTM            =       0060
DEXA            =       0061
JUNKA           =       0062
TEMPAA          =       0064
NWATCH          =       0067
QSTORE          =       0070
STATUS          =       0071
NOUN            =       0072
R1              =       0073
R2              =       0074
## Page D-3
R3              =       0075
TMASKA          =       0076
RESUMEA         =       0077
LOCSTOA         =       0100
ITA             =       0101
ADDERA          =       0102
TEMPA           =       0103
GOBAKA          =       0104
NUMA            =       0105
DCNTL           =       0106
ZZTAG           =       0107            # SET WHEN V00 IS HIT
TEMP1L          =       0110
TEMP2L          =       0111
TEMP3L          =       0112
TEMP4L          =       0113
VERBFFL         =       0114
VERBREGL        =       0115
ACMSTAT         =       0116
R1ADD           =       0117
IDSTARTL        =       0120
IDSTOPL         =       0121
JUNK1L          =       0122
TPBNKL          =       0123
CH25LOAD        =       0124
CORERCNT        =       0125
CNTDWN2L        =       0126
CNTDWN1L        =       0127
SUML            =       0130
OVFLOL          =       0131
INCRDEDA        =       0132
BANKNUMA        =       0133
LOCA            =       0134
DISYES          =       0135
READKSTA        =       0136
QSTORL          =       0137
HOLD1STB        =       0140
EBCOUNT         =       0141
FBCOUNT         =       0142
ERRCOUNT        =       0143
HOLD            =       0144
BBK             =       0145
HOLDIT          =       0146
1STDIGPR        =       0147
BNKPR           =       0150
GETADD          =       0151
READX           =       0152
BANKNO          =       0153
ADDHOLD         =       0154
BNKSHFT         =       0156
1STBNKNO        =       0157
HOLDBKDG        =       0160
GETDATA         =       0161
DATAHOLD        =       0162
BNKNUMAA        =       0163
BNKNUMBA        =       0164
ACMFBK          =       0165
SWITCH          =       0166
NEWID           =       0167
## Page D-4
OLDID           =       0170
LSTCNT          =       0171
ONETO5          =       0172
SIXTH           =       0173
SEVENTH         =       0174
EIGHTH          =       0175
RDLD            =       0176
HOLDNO          =       0177
NOOFBNKS        =       0200
PUNCH5          =       0201
LDFBLL          =       0202
LDEBLL          =       0203
TRXYB           =       0204
TRYXB           =       0205
TRXXB           =       0206
TRYYB           =       0207
PUNCH6          =       0210
FXDSUM          =       3776
FXDOVFLO        =       3777
