### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    CHECK_EQUALS_LIST.agc
## Purpose:     A section of Luminary revision 210.
##              It is part of the source code for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 15-17.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 161-162
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-11-17 JL   Created from Artemis072 version.
##              2016-11-20 HG   Transcribed
##		2016-12-23 RSB	Proofed comment text with octopus/ProoferComments
##				and fixed all errors found.

## Page 161
# THIS LIST IS MAINTAINED TO ENSURE THAT CERTAIN ERASABLE LOCATIONS
# ARE LOCATED AT A SPECIFIED DISTANCE FROM ANOTHER ERASABLE LOCATION
# AS REQUIRED BY THE STRUCTURE OF THE DOWNLINK LISTS:
#       1. IF A LOCATION IS THE SECOND PART OF A DOWNLINK WORD, IT MUST
#          BE CONTIGUOUS TO THE LOCATION THAT IS THE FIRST PART.
#       2. IF A LOCATION IS NOT THE FIRST WORD OF AN NDNADR IT
#          MUST BE AT A SPECIFIC NUMBER OF LOCATIONS FROM THE FIRST
#          LOCATION IN THE INSTRUCTION.
#       3. OTHER NAMES MAY BE GIVEN TO LOCATIONS IN THE DOWNLIND LISTS
#          THAT ARE NOT REFERENCED IN THE LISTS. THESE MUST NOT BE MOVED.
# THIS IS ACCOMPLISHED USING THE INSTRUCTION    CHECK=   .
# THIS INSTRUCTION GIVES A CUSS IN THE ASSEMBLY IF THE LOCATION OF THE
# FIRST TAG FIELD IS NOT EQUAL TO THE LOCATION OF THE SECOND TAG FIELD.
# THE INSTRUCTION HAS NO OTHER EFFECT ON THE ASSEMBLY OR CODE.

# THIS LIST SHOULD BE UPDATED FOR ANY CHANGES TO THE DOWNLINK LISTS.

# THIS LIST IS MAINTAINED BY  SUMNER ROSENBERG
#

TIME1           CHECK=          TIME2           +1
CDUY            CHECK=          CDUX            +1
CDUZ            CHECK=          CDUY            +1
CDUT            CHECK=          CDUZ            +1
PIPAX           CHECK=          CDUS            +1
PIPAY           CHECK=          PIPAX           +1
PIPAZ           CHECK=          PIPAY           +1
DAPBOOLS        CHECK=          RADMODES        +1
LASTXCMD        CHECK=          LASTYCMD        +1
THETAD          CHECK=          REDOCTR         +1
FAILREG         CHECK=          CHANBKUP        +1
UPOLDMOD        CHECK=          COMPNUMB        +1
UPVERB          CHECK=          UPOLDMOD        +1
UPCOUNT         CHECK=          UPVERB          +1
UPBUFF          CHECK=          UPCOUNT         +1
SPIRAL          CHECK=          CURSOR          +1
IMODES33        CHECK=          IMODES30        +1
CSMMASS         CHECK=          LEMMASS         +1
DNRRDOT         CHECK=          DNRRANGE        +1
DNLRVELY        CHECK=          DNLRVELX        +1
DNLRVELZ        CHECK=          DNLRVELY        +1
DNLRALT         CHECK=          DNLRVELZ        +1
DUMLOOPS        CHECK=          SERVDURN        +1
ZNBSAV          CHECK=          YNBSAV          +6
IGC             CHECK=          OGC             +2
MGC             CHECK=          IGC             +2
BESTJ           CHECK=          BESTI           +1
OMEGAQ          CHECK=          OMEGAP          +1
OMEGAR          CHECK=          OMEGAQ          +1
ALPHAR          CHECK=          ALPHAQ          +1

## Page 162
NEGTORKP        CHECK=          POSTORKP        +1
NEGTORKU        CHECK=          POSTORKU        +1
POSTORKV        CHECK=          NEGTORKU        +1
NEGTORKV        CHECK=          POSTORKV        +1
CDUYD           CHECK=          CDUXD           +1
CDUZD           CHECK=          CDUYD           +1
OMEGAQD         CHECK=          OMEGAPD         +1
OMEGARD         CHECK=          OMEGAQD         +1
AMG             CHECK=          AIG             +1
TRKMKCNT        CHECK=          AOG             +1
VSELECT         CHECK=          AOG             +1
FORVMETR        CHECK=          LATVMETR        +1
FLAGWRD0        CHECK=          STATE
FLGWRD12        CHECK=          RADMODES
FLGWRD13        CHECK=          DAPBOOLS
CPHI            CHECK=          THETAD
CTHETA          CHECK=          THETAD          +1
CPSI            CHECK=          THETAD          +2
DELVX           CHECK=          DELV
DELVY           CHECK=          DELV            +2
DELVZ           CHECK=          DELV            +4
CTLIST          CHECK=          DNLSTCOD        +1
CADRMARK        CHECK=          CADRFLSH        +1
TEMPFLSH        CHECK=          CADRFLSH        +2
STARCODE        CHECK=          AOTCODE
TETCSM          CHECK=          T-OTHER
TETOTHER        CHECK=          T-OTHER
R(CSM)          CHECK=          R-OTHER
V(CSM)          CHECK=          V-OTHER
DOWNTORK        CHECK=          POSTORKP
DCDU            CHECK=          CDUXD
DELVLVC         CHECK=          DELVSLV
MARKCTR         CHECK=          TRKMKCNT
VGPREV          CHECK=          VGTIG
CH6MASK         CHECK=          CH5MASK         +1
