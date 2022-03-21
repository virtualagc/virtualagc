### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     ERASABLE_ASSIGNMENTS.agc
## Purpose:      Part of the source code for Aurora (revision 12).
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      https://www.ibiblio.org/apollo.
## Pages:        7-25
## Mod history:  2016-09-20 JL   Created.
##               2016-10-04 HG   Insert missed statements
##               2016-10-12 HG   add missing  THRUST  EQUALS  55
##                               fix label   SQRANG -> SQRARG
##               2016-10-15 HG   fix label   LASTXMCD -> LASTXCMD
##               2016-10-16 HG   FIX LABEL   SCALSAVE -> SCALSAV
##		 2016-12-07 RSB	 Proofed comments with octopus/ProoferComments
##				 and made a few changes.
##		 2021-05-30 ABS  Fixed NEWLOC+1 line to be a remark.
##
## This source code has been transcribed or otherwise adapted from
## digitized images of a hardcopy from the private collection of
## Don Eyles.  The digitization was performed by archive.org.
##
## Notations on the hardcopy document read, in part:
##
##       473423A YUL SYSTEM FOR BLK2: REVISION 12 of PROGRAM AURORA BY DAP GROUP
##       NOV 10, 1966
##
##       [Note that this is the date the hardcopy was made, not the
##       date of the program revision or the assembly.]
##
## The scan images (with suitable reduction in storage size and consequent
## reduction in image quality) are available online at
##       https://www.ibiblio.org/apollo.
## The original high-quality digital images are available at archive.org:
##       https://archive.org/details/aurora00dapg

## Page 7
A               EQUALS          0
L               EQUALS          1                               # L AND Q ARE BOTH CHANNELS AND REGISTERS.
Q               EQUALS          2
EBANK           EQUALS          3
FBANK           EQUALS          4
Z               EQUALS          5                               # ADJACENT TO FBANK AND BBANK FOR DXCH Z
BBANK           EQUALS          6                               # (DTCB) AND DXCH FBANK (DTCF).
                                                                # REGISTER 7 IS A ZERO-SOURCE, USED BY ZL.

ARUPT           EQUALS          10                              # INTERRUPT STORAGE.
LRUPT           EQUALS          11
QRUPT           EQUALS          12
SAMPTIME        EQUALS          13                              # SAMPLED TIME 1 & 2.
ZRUPT           EQUALS          15                              # (13 AND 14 ARE SPARES.)
BANKRUPT        EQUALS          16                              # USUALLY HOLDS FBANK OR BBANK.
BRUPT           EQUALS          17                              # RESUME ADDRESS AS WELL.

CYR             EQUALS          20
SR              EQUALS          21
CYL             EQUALS          22
EDOP            EQUALS          23                              # EDITS INTERPRETIVE OPERATION CODE PAIRS.


TIME2           EQUALS          24
TIME1           EQUALS          25
TIME3           EQUALS          26
TIME4           EQUALS          27
TIME5           EQUALS          30
TIME6           EQUALS          31
CDUX            EQUALS          32
CDUY            EQUALS          33
CDUZ            EQUALS          34
OPTY            EQUALS          35
OPTX            EQUALS          36
PIPAX           EQUALS          37
PIPAY           EQUALS          40
PIPAZ           EQUALS          41
BMAGX           EQUALS          42
RHCP            EQUALS          42
BMAGY           EQUALS          43
RHCY            EQUALS          43
BMAGZ           EQUALS          44
RHCR            EQUALS          44
INLINK          EQUALS          45
RNRAD           EQUALS          46
GYROCTR         EQUALS          47
GYROCMD         EQUALS          47
CDUXCMD         EQUALS          50
CDUYCMD         EQUALS          51

## Page 8
CDUZCMD         EQUALS          52
OPTYCMD         EQUALS          53
OPTXCMD         EQUALS          54
EMSD            EQUALS          55
THRUST          EQUALS          55
LEMONM          EQUALS          56
OUTLINK         EQUALS          57
ALTM            EQUALS          60

                SETLOC          67                              # DECODED REGISTER FOR NIGHT-WATCHMAN ALM.
NEWJOB          ERASE

LVSQUARE        EQUALS          34D                             # SQUARE OF VECTOR INPUT TO ABVAL AND UNIT
LV              EQUALS          36D                             # LENGTH OF VECTOR INPUT TO UNIT.
X1              EQUALS          38D                             # INTERPRETIVE SPECIAL REGISTERS RELATIVE
X2              EQUALS          39D                             # TO THE WORK AREA.
S1              EQUALS          40D
S2              EQUALS          41D
QPRET           EQUALS          42D

## Page 9

# GENERAL ERASABLE ASSIGNMENTS.

                SETLOC          61

                SETLOC          1000

# ERASABLE FOR SINGLE PRECISION SUBROUTINES.

HALFY           ERASE
ROOTRET         ERASE
SQRARG          ERASE
TEMK            EQUALS          HALFY
SQ              EQUALS          ROOTRET

1/PIPADT        ERASE                                           # IMU COMPENSATION PACKAGE
OLDBT1          =               1/PIPADT

