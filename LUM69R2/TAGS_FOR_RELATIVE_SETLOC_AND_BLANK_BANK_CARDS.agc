### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    TAGS_FOR_RELATIVE_SETLOC_AND_BLANK_BANK_CARDS.agc
## Purpose:     A section of LUM69 revision 2.
##              It is part of the reconstructed source code for the flown
##              version of the flight software for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 10. The code has
##              been recreated from a copy of Luminary revsion 069, using
##              changes present in Luminary 099 which were described in
##              Luminary memos 75 and 78. The code has been adapted such
##              that the resulting bugger words exactly match those specified
##              for LUM69 revision 2 in NASA drawing 2021152B, which gives
##              relatively high confidence that the reconstruction is correct.
## Reference:   pp. 27-36
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-07-27 MAS  Created from Luminary 69.
##              2019-07-27 MAS  Added tag for LUM69 rev 2 lunar potential code.
##		2020-12-14 RSB	Tweaked the annotation relevant to the
##				change mentioned above to conform to the
##				style and extent of similar justifying
##				annotations previously added to 
##				Comanche 44 and 51.

## Page 27
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
FFTAG11         EQUALS
FFTAG12         EQUALS
FFTAG13         EQUALS
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
LOADDAP1        EQUALS
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


## Page 28
                BANK            05
FRANDRES        EQUALS
DOWNTELM        EQUALS
AOTMARK2        EQUALS
EPHEM1          EQUALS
                BNKSUM          05


# MODULE 2 CONTAINS BANKS 6 THROUGH 13

                BANK            06
IMUCOMP         EQUALS
T4RUP           EQUALS
RCSMONT         EQUALS
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
## <b>Reconstruction:</b> The alias immediately following this annotation
## was not present in Luminary 69. It is associated with the incorporation of the 
## R-2 Lunar Potential Model (see
## <a href="http://www.ibiblio.org/apollo/Documents/LUM75_text.pdf">LUMINARY Memo #75</a>).
## The alias is used for the purpose of placing the R-2 model functions QUALITY1
## and QUALITY2 into desired memory banks. The placement used differs between different revisions of Luminary and Colossus.
## The particular choice of BANK 11 in reconstructing Luminary 69/2 was determined empirically.
## Moreover, this particular placement of QUALITY1 and QUALITY2 into BANK 11 is not
## matched by any other available AGC software version, and hence there is no 
## particular reason to believe that the specific string "MODCHG1" was the alias used in the
## original Luminary 69/2 source code.  The string MODCHG1 was selected in the reconstruction
## process by analogy to the use in the original Comanche 55 source code of the
## aliases MODCHG2 and MODCHG3 for relocation of QUALITY1 and QUALITY2
## (into BANK 12 and BANK 13, respectively).  However, some other alias
## for BANK 11 (such as ORBITAL or ORBITAL1) could have just as easily been used for
## this purpose in Luminary 69/2.
MODCHG1         EQUALS
                BNKSUM          11


                BANK            12
CONICS          EQUALS
                BNKSUM          12


## Page 29
                BANK            13
LATLONG         EQUALS
INTINIT         EQUALS
LEMGEOM         EQUALS
P76LOC          EQUALS
ORBITAL2        EQUALS
                BNKSUM          13


## Page 30
# MODULE 3 CONTAINS BANKS 14 THROUGH 21

                BANK            14
P50S1           EQUALS
STARTAB         EQUALS
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
RODTRAP         EQUALS
                BNKSUM          20


                BANK            21
DAPS4           EQUALS
F2DPS*21        EQUALS
R10             EQUALS
R11             EQUALS
                BNKSUM          21

## Page 31

# MODULE 4 CONTAINS BANKS 22 THROUGH 27

                BANK            22
KALCMON1        EQUALS
KALCMON2        EQUALS
R30LOC          EQUALS
RENDEZ          EQUALS
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
EXTVB1          EQUALS
                BNKSUM          23


                BANK            24
PLANTIN         EQUALS
P20S            EQUALS
                BNKSUM          24


                BANK            25
P20S1           EQUALS
P20S2           EQUALS
RADARUPT        EQUALS
RRLEADIN        EQUALS
R29S1           EQUALS
                BNKSUM          25


                BANK            26
P20S3           EQUALS
BAWLANGS        EQUALS
MANUVER         EQUALS
MANUVER1        EQUALS
PLANTIN1        EQUALS
                BNKSUM          26


## Page 32
                BANK            27
TOF-FF          EQUALS
TOF-FF1         EQUALS
P40S1           EQUALS
VECPT           EQUALS
ASENT1          EQUALS
                BNKSUM          27


## Page 33
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
VB67            EQUALS
                BNKSUM          31


                BANK            32
P20S4           EQUALS
F2DPS*32        EQUALS
ABORTS          EQUALS
LRS22           EQUALS
FLOGSUB         EQUALS
SERV2           EQUALS
R47             EQUALS
                BNKSUM          32


                BANK            33
SERVICES        EQUALS
R29/SERV        EQUALS
                BNKSUM          33


                BANK            34
STBLEORB        EQUALS
P30S1           EQUALS
CSI/CDH1        EQUALS
ASCFILT         EQUALS
R12STUFF        EQUALS
                BNKSUM          34


                BANK            35
CSI/CDH         EQUALS

## Page 34
P30S            EQUALS
GLM             EQUALS
P40S2           EQUALS
                BNKSUM          35

## Page 35
# MODULE 6 CONTAINS BANKS 36 THROUGH 43

                BANK            36
P40S            EQUALS
                BNKSUM          36


                BANK            37
P05P06          EQUALS
IMU2            EQUALS
IMU4            EQUALS
R31             EQUALS
IMUSUPER        EQUALS
SERV1           EQUALS
                BNKSUM          37


                BANK            40
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
                BNKSUM          42


                BANK            43
EXTVERBS        EQUALS
SELFCHEC        EQUALS

                BNKSUM          43

## Page 36

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
