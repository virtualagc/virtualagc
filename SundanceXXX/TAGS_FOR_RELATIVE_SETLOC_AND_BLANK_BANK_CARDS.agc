### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    TAGS_FOR_RELATIVE_SETLOC_AND_BLANK_BANK_CARDS.agc
## Purpose:     A section of a reconstructed, mixed version of Sundance
##              It is part of the reconstructed source code for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 9.
##              No original listings of this program are available;
##              instead, this file was created via disassembly of dumps
##              of various revisions of Sundance core rope modules.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-06-17 MAS  Created from Luminary 69.

## This section allocates tags to match our particular set of Sundance modules.

                COUNT           BANKSUM

# MODULE 1 CONTAINS BANKS 0 THROUGH 5

                BLOCK           02
RADARFF         EQUALS
FFTAG1          EQUALS
FFTAG2          EQUALS
FFTAG3          EQUALS
FFTAG4          EQUALS
FFTAG7          EQUALS
FFTAG8          EQUALS
FFTAG9          EQUALS
FFTAG10         EQUALS
                BNKSUM          02


                BLOCK           03
FFTAG5          EQUALS
FFTAG6          EQUALS
                BNKSUM          03


                BANK            00
DLAYJOB         EQUALS
                BNKSUM          00


                BANK            01
RESTART         EQUALS
                BNKSUM          01


                BANK            04
R02             EQUALS
VERB37          EQUALS
PINBALL4        EQUALS
CONICS1         EQUALS
KEYRUPT         EQUALS
R36LM           EQUALS
UPDATE2         EQUALS
E/PROG          EQUALS
                BNKSUM          04


                BANK            05
FRANDRES        EQUALS
DOWNTELM        EQUALS
                BNKSUM          05


# MODULE 2 CONTAINS BANKS 6 THROUGH 13

                BANK            06
IMUCOMP         EQUALS
T4RUP           EQUALS
RCSMONT         EQUALS
STGMONT         EQUALS
                BNKSUM          06


                BANK            07
AOTMARK1        EQUALS
MODESW          EQUALS
                BNKSUM          07


                BANK            10
RTBCODES        EQUALS
DISPLAYS        EQUALS
PHASETAB        EQUALS
MIDDGIM         EQUALS
                BNKSUM          10


                BANK            11
ORBITAL         EQUALS
ORBITAL1        EQUALS
INTVEL          EQUALS
INTPRET2        EQUALS
                BNKSUM          11


                BANK            12
CONICS          EQUALS
                BNKSUM          12


                BANK            13
LATLONG         EQUALS
INTINIT         EQUALS
LEMGEOM         EQUALS
R32LOC          EQUALS
                BNKSUM          13


# MODULE 3 CONTAINS BANKS 14 THROUGH 21

                BANK            14
P50S1           EQUALS
STARTAB         EQUALS
EPHEM1          EQUALS
                BNKSUM          14


                BANK            15
P50S            EQUALS
EPHEM           EQUALS
                BNKSUM          15


                BANK            16
DAPS1           EQUALS
                BNKSUM          16


                BANK            17
DAPS2           EQUALS
                BNKSUM          17


                BANK            20
DAPS3           EQUALS
LOADDAP         EQUALS
                BNKSUM          20


                BANK            21
DAPS4           EQUALS
RODTRAP         EQUALS
F2DPS*21        EQUALS
R10             EQUALS
                BNKSUM          21


# MODULE 4 CONTAINS BANKS 22 THROUGH 27

                BANK            22
KALCMON1        EQUALS
KALCMON2        EQUALS
R30LOC          EQUALS
                BNKSUM          22


                BANK            23
POWFLITE        EQUALS
POWFLIT1        EQUALS
INFLIGHT        EQUALS
APOPERI         EQUALS
R61             EQUALS
R62             EQUALS
INTPRET1        EQUALS
MEASINC         EQUALS
MEASINC1        EQUALS
                BNKSUM          23


                BANK            24
PLANTIN         EQUALS
P20S            EQUALS
                BNKSUM          24


                BANK            25
P20S1           EQUALS
P20S2           EQUALS
LRS22           EQUALS
RADARUPT        EQUALS
RRLEADIN        EQUALS
                BNKSUM          25


                BANK            26
P20S3           EQUALS
BAWLANGS        EQUALS
MANUVER         EQUALS
MANUVER1        EQUALS
                BNKSUM          26


                BANK            27
TOF-FF          EQUALS
TOF-FF1         EQUALS
P40S1           EQUALS
VECPT           EQUALS
                BNKSUM          27


# MODULE 5 CONTAINS BANKS 30 THROUGH 35

                BANK            30
LOWSUPER        EQUALS
P12             EQUALS
ASENT           EQUALS
FCDUW           EQUALS
                BNKSUM          30


                BANK            31
FTHROT          EQUALS
F2DPS*31        EQUALS
                BNKSUM          31


                BANK            32
P10S            EQUALS
F2DPS*32        EQUALS
ABORTS          EQUALS
P40S2           EQUALS
R11             EQUALS
                BNKSUM          32


                BANK            33
SERVICES        EQUALS
                BNKSUM          33


                BANK            34
STBLEORB        EQUALS
GLM             EQUALS
P30S1           EQUALS
CSI/CDH1        EQUALS
                BNKSUM          34


                BANK            35
CSI/CDH         EQUALS
P30S            EQUALS
                BNKSUM          35

# MODULE 6 CONTAINS BANKS 36 THROUGH 43

                BANK            36
P40S            EQUALS
                BNKSUM          36


                BANK            37
VB45            EQUALS
P05P06          EQUALS
IMU2            EQUALS
IMU4            EQUALS
R31             EQUALS
IMUSUPER        EQUALS
                BNKSUM          37


                BANK            40
R47             EQUALS
PINBALL1        EQUALS
SELFSUPR        EQUALS
PINSUPER        EQUALS
                BNKSUM          40


                BANK            41
PINBALL2        EQUALS
                BNKSUM          41


                BANK            42
SBAND           EQUALS
PINBALL3        EQUALS
EXTVB1          EQUALS
                BNKSUM          42


                BANK            43
EXTVERBS        EQUALS
SELFCHEC        EQUALS

                BNKSUM          43


HI6ZEROS        EQUALS          ZEROVECS                # ZERO VECTOR ALWAYS IN HIGH MEMORY
LO6ZEROS        EQUALS          ZEROVEC                 # ZERO VECTOR ALWAYS IN LOW MEMORY
HIDPHALF        EQUALS          UNITX
LODPHALF        EQUALS          XUNIT
HIDP1/4         EQUALS          DP1/4TH
LODP1/4         EQUALS          D1/4                    # 2DEC .25
HIUNITX         EQUALS          UNITX
HIUNITY         EQUALS          UNITY
HIUNITZ         EQUALS          UNITZ
LOUNITX         EQUALS          XUNIT                   # 2DEC .5
LOUNITY         EQUALS          YUNIT                   # 2DEC 0
LOUNITZ         EQUALS          ZUNIT                   # 2DEC 0
#


DELRSPL         EQUALS          SPLRET                  # COL PGM, ALSO CALLED BY R30 IN LUMINARY
# ROPE-SPECIFIC ASSIGNS OBVIATING NEED TO CHECK COMPUTER FLAG IN           DETERMINING INTEGRATION AREA ENTRIES.

ATOPTHIS        EQUALS          ATOPLEM
ATOPOTH         EQUALS          ATOPCSM
OTHPREC         EQUALS          CSMPREC
MOONTHIS        EQUALS          LMOONFLG
MOONOTH         EQUALS          CMOONFLG
MOVATHIS        EQUALS          MOVEALEM
RMM             =               LODPMAX
RME             =               LODPMAX1
THISPREC        EQUALS          LEMPREC
THISAXIS        =               UNITZ
NB1NB2          EQUALS          THISAXIS                # FOR R31
ERASID          EQUALS          BITS2-10                # DOWNLINK ERASABLE DUMP ID
DELAYNUM        EQUALS          TWO
