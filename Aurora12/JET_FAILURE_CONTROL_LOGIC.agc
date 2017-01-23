### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     JET_FAILURE_CONTROL_LOGIC.agc
## Purpose:      Part of the source code for Aurora (revision 12).
## Assembler:    yaYUL
## Contact:      Hartmuth GUtsche<hgutsche@xplornet.com>.
## Website:      https://www.ibiblio.org/apollo.
## Pages:        594-603
## Mod history:  2016-09-20 JL   Created.
##               2016-10-04 HG   transcription from scan
##               2016-10-05 HG   BIT14 -> BIT4
##               2016-10-15 HG   fix operand PLOTAB2 -> POLTAB2
##                                           ASNTPOOL-> ASCNTPOL
##                               fix label   POLFIND -> POLFND  
##               2016-10-16 HG   fix operand BIT17 -> bit7
##		 2016-12-08 RSB	 Proofed comments with octopus/ProoferComments
##				 and fixed the errors found.

## This source code has been transcribed or otherwise adapted from
## digitized images of a hardcopy from the private collection of
## Don Eyles.  The digitization was performed by archive.org.

## Notations on the hardcopy document read, in part:

##       473423A YUL SYSTEM FOR BLK2: REVISION 12 of PROGRAM AURORA BY DAP GROUP
##       NOV 10, 1966

##       [Note that this is the date the hardcopy was made, not the
##       date of the program revision or the assembly.]

## The scan images (with suitable reduction in storage size and consequent
## reduction in image quality) are available online at
##       https://www.ibiblio.org/apollo.
## The original high-quality digital images are available at archive.org:
##       https://archive.org/details/aurora00dapg

## Page 594
                BANK            25
                EBANK=          DT



# DETERMINE MODE - +XTRANS, -XTRANS, ASCENT, MANDATORY ROTATION, OR NORMAL
POLTYPEP        CA              BIT7                    # CHECK + X TRANSLATION
                EXTEND
                RAND            31
                EXTEND
                BZF             POSXPOLS

                CA              BIT8                    # CHECK -X TRANSLATION
                EXTEND
                RAND            31
                EXTEND
                BZF             NEGXPOLS                # CHECK U,V-MANDATORY AND 4-JET Q,R

                CA              DAPBOOLS                # CHECK ASCENT BIT OF DAPBOOLS
                MASK            BIT8
                EXTEND
                BZF             NORMATT

ASCFLGHT        INDEX           POLRELOC
                CA              ASCNTPOL
                TCF             +9D
NORMATT         INDEX           POLRELOC
                CA              NORMLPOL
                TCF             +6
NEGXPOLS        INDEX           POLRELOC
                CA              -XPOLADR
                TCF             +3
POSXPOLS        INDEX           POLRELOC
                CA              +XPOLADR
                TS              POLRELOC                # RESET POLRELOC TO NEW TABLE ENTRY

                INDEX           POLRELOC                # USE POLRELOC POINTER TO FIND AND
                CA              POLTAB1                 # EXTRACT THE NUMBER OF TESTABLE
                EXTEND                                  # POLICIES AND SAVE IN LOOPCTR
                MP              BIT7
                MASK            SEVEN
                TS              LOOPCTR
                TCF             +4

POLLOOP         TS              LOOPCTR                 # RESTORE COUNTER
                EXTEND                                  # CHANGE EFFECTIVE ADDRESS TO NEXT POLICY
                DIM             POLRELOC
                INDEX           POLRELOC
                CA              POLTAB1                 # PICK UP ROTATIONAL JETS
                TS              L

## Page 595
                INDEX           POLRELOC
                CA              POLTAB2                 # PICK UP TRANSLATIONAL JETS (MAY BE NONE)
                EXTEND                                  # GET ALL JETS USED IN THIS POLICY
                WOR             L                       # (LOW ORDER 8 BITS ONLY)
                MASK            CH5MASK                 # TEST FOR POLICY FEASIBILITY -
                CCS             A                       # REJECT POLICY IF ANY OF THE JETS IT USES
                TCF             +2                      # ARE THOUGHT TO HAVE FAILED
                TCF             POLFND
                CCS             LOOPCTR                 # TEST FOR EXISTENCE OF ADDITIONAL
                TCF             POLLOOP                 # TESTABLE POLICY

                EXTEND                                  # LAST FEASIBLE CHOICE -
                DIM             POLRELOC                # CREATE UNTESTED POLICY ADDRESS

POLFND          INDEX           POLRELOC
                CA              POLTAB1
                MASK            LOW8                    # GET CHANNEL 5 BIT CONFIGURATION FOR
                AD              BIT15                   # SET SIGN FOR Q,R AXIS FLAG
                TS              JTSONNOW                # JETS TO BE TURNED ON IMMEDIATELY
                INDEX           POLRELOC
                CA              POLTAB1
                EXTEND
                MP              BIT4                    # GET CODE FOR NUMBER OF TORQUING JETS
                CCS             A
                TCF             +2
                TCF             TORKSETP                # N=2, CODE=0
                CCS             A
                TCF             1/4JETAC
                CA              1/NJETAC                # N=4, CODE=2
                DOUBLE                                  # N = 1, CODE = 1
                TCF             NJETCORR
1/4JETAC        CA              1/NJETAC                # N = 4, CODE = 2
                EXTEND
                MP              BIT14
NJETCORR        TS              1/NJETAC

TORKSETP        INDEX           POLRELOC
                CA              POLTAB2
                EXTEND
                MP              BIT4                    # GET CODE FOR NUMBER OF Q-JETS
                INDEX           A
                CA              TORKTABL                # GET NUMBER OF Q-JETS FROM TABLE AND
                TS              NO.QJETS                # SAVE FOR TORQUE VECTOR RECONSTRUCTION
                CA              L
                EXTEND
                MP              BIT4                    # GET CODE FOR NUMBER OF R-JETS
                INDEX           A
                CA              TORKTABL                # GET NUMBER OF R-JETS FROM TABLE AND
                TS              NO.RJETS                # SAVE FOR TORQUE VECTOR RECONSTRUCTION
                CA              L

## Page 596
                EXTEND
                MP              BIT9                    # GET CHANNEL 5 BIT CONFIGURATION FOR
                AD              BIT15                   # SET SIGN FOR Q,R AXIS FLAG
                TS              JTSATCHG                # JETS TO BE TURNED ON AFTER TORQUING

                CA              BBANKSET
                TS              L
                CA              TJETADR
                DTCB                                    # RETURN TO FBANK 24

BBANKSET        OCTAL           50006




# TABLE OF Q,R-JET NUMBERS AND DIRECTIONS FOR TORQUE RECONSTRUCTION

TORKTABL        DEC             -4
                DEC             -2
                DEC             -1
                DEC             0
                DEC             +1
                DEC             +2
                DEC             +4

# POLTAB1 LISTS Q,R-AXIS ROTATIONAL JET POLICIES

POLTAB1         OCTAL             220                   # JETS  9 14  0  0 NO 2  CTR 0
                OCTAL               6                   # JETS  2  5  0  0 NO 2  CTR 0
                OCTAL             602                   # JETS  2 14  0  0 NO 2  CTR 1
                OCTAL           10226                   # JETS  2  5  9 14 NO 4  CTR 0
                OCTAL           11626                   # JETS  2  5  9 14 NO 4  CTR 3
                OCTAL             201                   # JETS  1 14  0  0 NO 2  CTR 0
                OCTAL              44                   # JETS  5 10  0  0 NO 2  CTR 0
                OCTAL             640                   # JETS 10 14  0  0 NO 2  CTR 1
                OCTAL           10245                   # JETS  1  5 10 14 NO 4  CTR 0
                OCTAL           11645                   # JETS  1  5 10 14 NO 4  CTR 3
                OCTAL             140                   # JETS 10 13  0  0 NO 2  CTR 0
                OCTAL              11                   # JETS  1  6  0  0 NO 2  CTR 0
                OCTAL             450                   # JETS  6 10  0  0 NO 2  CTR 1
                OCTAL           10151                   # JETS  1  6 10 13 NO 4  CTR 0
                OCTAL           11551                   # JETS  2  6 10 13 NO 4  CTR 3
                OCTAL             102                   # JETS  2 13  0  0 NO 2  CTR 0
                OCTAL              30                   # JETS  6  9  0  0 NO 2  CTR 0
                OCTAL             412                   # JETS  2  6  0  0 NO 1  CTR 1
                OCTAL           10132                   # JETS  2  6  9 13 NO 4  CTR 0
                OCTAL           11532                   # JETS  2  5  9 13 NO 4  CTR 3
                OCTAL             220                   # JETS  9 14  0  0 NO 2  CTR 0
                OCTAL               6                   # JETS  2  5  0  0 NO 2  CTR 0
                OCTAL             424                   # JETS  5  9  0  0 NO 2  CTR 1
                OCTAL           10226                   # JETS  2  5  9 14 NO 4  CTR 0

## Page 597
                OCTAL           11626                   # JETS  2  5  9 14 NO 4  CTR 3
                OCTAL              44                   # JETS  5 10  0  0 NO 2  CTR 3
                OCTAL             201                   # JETS  1 14  0  0 NO 2  CTR 0
                OCTAL             405                   # JETS  1  5  0  0 NO 2  CTR 1
                OCTAL           10245                   # JETS  1  5 10 14 NO 4  CTR 0
                OCTAL           11645                   # JETS  1  5 10 14 NO 4  CTR 3
                OCTAL             140                   # JETS 10 13  0  0 NO 2  CTR 0
                OCTAL              11                   # JETS  1  6  0  0 NO 2  CTR 0
                OCTAL             501                   # JETS  1 13  0  0 NO 2  CTR 1
                OCTAL           10151                   # JETS  1  6 10 13 NO 4  CTR 0
                OCTAL           11551                   # JETS  1  6 10 13 NO 4  CTR 3
                OCTAL              30                   # JETS  6  9  0  0 NO 2  CTR 0
                OCTAL             102                   # JETS  2 13  0  0 NO 2  CTR 0
                OCTAL             520                   # JETS  9 13  0  0 NO 2  CTR 1
                OCTAL           10132                   # JETS  2  6  9 13 NO 4  CTR 0
                OCTAL           11532                   # JETS  2  6  9 13 NO 4  CTR 3
                OCTAL            4046                   # JETS  2  5 10  0 NO 1  CTR 0
                OCTAL            4242                   # JETS  2 10 14  0 NO 1  CTR 0
                OCTAL            4600                   # JETS 14  0  0  0 NO 1  CTR 1
                OCTAL             204                   # JETS  5 14  0  0 NO 2  CTR 0
                OCTAL            1604                   # JETS  5 14  0  0 NO 2  CTR 3
                OCTAL            4142                   # JETS  2 10 13  0 NO 1  CTR 0
                OCTAL            4052                   # JETS  2  6 10  0 NO 1  CTR 0
                OCTAL            4410                   # JETS  6  0  0  0 NO 1  CTR 1
                OCTAL             110                   # JETS  6 13  0  0 NO 2  CTR 0
                OCTAL            1510                   # JETS  6 13  0  0 NO 2  CTR 3
                OCTAL            4211                   # JETS  1  6 14  0 NO 1  CTR 0
                OCTAL            4250                   # JETS  6 10 14  0 NO 1  CTR 0
                OCTAL            4440                   # JETS 10  0  0  0 NO 1  CTR 1
                OCTAL              41                   # JETS  1 10  0  0 NO 2  CTR 0
                OCTAL            1441                   # JETS  1 10  0  0 NO 2  CTR 3
                OCTAL            4230                   # JETS  6  9 14  0 NO 1  CTR 0
                OCTAL            4212                   # JETS  2  6 14  0 NO 1  CTR 0
                OCTAL            4402                   # JETS  2  0  0  0 NO 1  CTR 1
                OCTAL              22                   # JETS  2  9  0  0 NO 2  CTR 0
                OCTAL            1422                   # JETS  2  9  0  0 NO 2  CTR 3
                OCTAL            4221                   # JETS  1  9 14  0 NO 1  CTR 0
                OCTAL            4025                   # JETS  1  5  9  0 NO 1  CTR 0
                OCTAL            4404                   # JETS  5  0  0  0 NO 1  CTR 1
                OCTAL             204                   # JETS  5 14  0  0 NO 2  CTR 0
                OCTAL            1604                   # JETS  5 14  0  0 NO 2  CTR 3
                OCTAL            4031                   # JETS  1  6  9  0 NO 1  CTR 0
                OCTAL            4121                   # JETS  1  9 13  0 NO 1  CTR 0
                OCTAL            4500                   # JETS 13  0  0  0 NO 1  CTR 1
                OCTAL             110                   # JETS  6 13  0  0 NO 2  CTR 0
                OCTAL            1510                   # JETS  6 13  0  0 NO 2  CTR 3
                OCTAL            4144                   # JETS  5 10 13  0 NO 1  CTR 0
                OCTAL            4105                   # JETS  1  5 13  0 NO 1  CTR 0
                OCTAL            4401                   # JETS  1  0  0  0 NO 1  CTR 1
                OCTAL              41                   # JETS  1 10  0  0 NO 2  CTR 0

## Page 598
                OCTAL            1441                   # JETS  1 10  0  0 NO 2  CTR 3
                OCTAL            4106                   # JETS  2  5 13  0 NO 1  CTR 0
                OCTAL            4124                   # JETS  5  9 13  0 NO 1  CTR 0
                OCTAL            4420                   # JETS  9  0  0  0 NO 1  CTR 1
                OCTAL              22                   # JETS  2  9  0  0 NO 2  CTR 0
                OCTAL            1422                   # JETS  2  9  0  0 NO 2  CTR 3
                OCTAL            4004                   # JETS  5  0  0  0 NO 1  CTR 0
                OCTAL            4200                   # JETS 14  0  0  0 NO 1  CTR 0
                OCTAL             604                   # JETS  5 14  0  0 NO 2  CTR 1
                OCTAL            4001                   # JETS  1  0  0  0 NO 1  CTR 0
                OCTAL            4040                   # JETS 10  0  0  0 NO 1  CTR 0
                OCTAL             441                   # JETS  1 10  0  0 NO 1  CTR 1
                OCTAL            4100                   # JETS 13  0  0  0 NO 1  CTR 0
                OCTAL            4010                   # JETS  6  0  0  0 NO 1  CTR 0
                OCTAL             510                   # JETS  6 13  0  0 NO 2  CTR 1
                OCTAL            4020                   # JETS  9  0  0  0 NO 1  CTR 0
                OCTAL            4002                   # JETS  2  0  0  0 NO 1  CTR 0
                OCTAL             422                   # JETS  2  9  0  0 NO 2  CTR 1
                OCTAL              24                   # JETS  5  9  0  0 NO 2  CTR 0
                OCTAL             220                   # JETS  9 14  0  0 NO 2  CTR 0
                OCTAL               6                   # JETS  2  5  0  0 NO 2  CTR 0
                OCTAL            1202                   # JETS  2 14  0  0 NO 2  CTR 2
                OCTAL               5                   # JETS  1  5  0  0 NO 2  CTR 0
                OCTAL             201                   # JETS  1 14  0  0 NO 2  CTR 0
                OCTAL              44                   # JETS  5 10  0  0 NO 2  CTR 0
                OCTAL            1240                   # JETS 10 14  0  0 NO 2  CTR 2
                OCTAL             101                   # JETS  1 13  0  0 NO 2  CTR 0
                OCTAL             140                   # JETS 10 13  0  0 NO 2  CTR 0
                OCTAL              11                   # JETS  1  6  0  0 NO 2  CTR 0
                OCTAL            1050                   # JETS  6 10  0  0 NO 2  CTR 2
                OCTAL             120                   # JETS  9 13  0  0 NO 2  CTR 0
                OCTAL             102                   # JETS  2 13  0  0 NO 2  CTR 0
                OCTAL              30                   # JETS  6  9  0  0 NO 2  CTR 0
                OCTAL            1012                   # JETS  2  6  0  0 NO 2  CTR 2
                OCTAL              24                   # JETS  5  9  0  0 NO 2  CTR 0
                OCTAL             202                   # JETS  2 14  0  0 NO 2  CTR 0
                OCTAL             220                   # JETS  9 14  0  0 NO 2  CTR 0
                OCTAL            1006                   # JETS  2  5  0  0 NO 2  CTR 2
                OCTAL           11626                   # JETS  2  5  9 14 NO 4  CTR 3
                OCTAL               5                   # JETS  1  5  0  0 NO 2  CTR 0
                OCTAL             240                   # JETS 10 14  0  0 NO 2  CTR 0
                OCTAL             201                   # JETS  1 14  0  0 NO 2  CTR 0
                OCTAL            1044                   # JETS  5 10  0  0 NO 2  CTR 2
                OCTAL           11645                   # JETS  1  5 10 14 NO 4  CTR 3
                OCTAL              50                   # JETS  6 10  0  0 NO 2  CTR 0
                OCTAL             101                   # JETS  1 13  0  0 NO 2  CTR 0
                OCTAL             140                   # JETS 10 13  0  0 NO 2  CTR 0
                OCTAL            1011                   # JETS  1  6  0  0 NO 2  CTR 2
                OCTAL           11551                   # JETS  1  6 10 13 NO 4  CTR 3
                OCTAL             120                   # JETS  9 13  0  0 NO 2  CTR 0

## Page 599
                OCTAL              12                   # JETS  2  6  0  0 NO 2  CTR 0
                OCTAL             102                   # JETS  2 13  0  0 NO 2  CTR 0
                OCTAL            1030                   # JETS  6  9  0  0 NO 2  CTR 2
                OCTAL           11532                   # JETS  2  6  9 13 NO 4  CTR 3

# POLTAB2 LISTS Q,R-AXIS TRANSLATIONAL POLICIES

POLTAB2         OCTAL           25610                   # JETS  6 14  QNO  2  RNO  0
                OCTAL           25442                   # JETS  2 10  QNO  2  RNO  0
                OCTAL           25400                   # JETS  0  0  QNO  2  RNO  0
                OCTAL           31610                   # JETS  6 14  QNO  4  RNO  0
                OCTAL           31442                   # JETS  2 10  QNO  4  RNO  0
                OCTAL           16610                   # JETS  6 14  QNO  0  RNO  2
                OCTAL           16442                   # JETS  2 10  QNO  0  RNO  2
                OCTAL           16400                   # JETS  0  0  QNO  0  RNO  2
                OCTAL           17210                   # JETS  6 14  QNO  0  RNO  4
                OCTAL           17042                   # JETS  2 10  QNO  0  RNO  4
                OCTAL            5442                   # JETS  2 10  QNO- 2  RNO  0
                OCTAL            5610                   # JETS  6 14  QNO- 2  RNO  0
                OCTAL            5400                   # JETS  0  0  QNO- 2  RNO  0
                OCTAL            1610                   # JETS  6 14  QNO- 4  RNO  0
                OCTAL            1442                   # JETS  2 10  QNO- 4  RNO  0
                OCTAL           14442                   # JETS  2 10  QNO  0  RNO- 2
                OCTAL           14610                   # JETS  6 14  QNO  0  RNO- 2
                OCTAL           14400                   # JETS  0  0  QNO  0  RNO- 2
                OCTAL           14210                   # JETS  6 14  QNO  0  RNO- 4
                OCTAL           14042                   # JETS  2 10  QNO  0  RNO- 4
                OCTAL           25421                   # JETS  1  9  QNO  2  RNO  0
                OCTAL           25504                   # JETS  5 13  QNO  2  RNO  0
                OCTAL           25400                   # JETS  0  0  QNO  2  RNO  0
                OCTAL           31504                   # JETS  5 13  QNO  4  RNO  0
                OCTAL           31421                   # JETS  1  9  QNO  4  RNO  0
                OCTAL           16504                   # JETS  5 13  QNO  0  RNO  2
                OCTAL           16421                   # JETS  1  9  QNO  0  RNO  2
                OCTAL           16400                   # JETS  0  0  QNO  0  RNO  2
                OCTAL           17104                   # JETS  5 13  QNO  0  RNO  4
                OCTAL           17021                   # JETS  1  9  QNO  0  RNO  4
                OCTAL            5504                   # JETS  5 13  QNO- 2  RNO  0
                OCTAL            5421                   # JETS  1  9  QNO- 2  RNO  0
                OCTAL            5400                   # JETS  0  0  QNO- 2  RNO  0
                OCTAL            1504                   # JETS  5 13  QNO- 4  RNO  0
                OCTAL            1421                   # JETS  1  9  QNO- 4  RNO  0
                OCTAL           14421                   # JETS  1  9  QNO  0  RNO- 2
                OCTAL           14504                   # JETS  5 13  QNO  0  RNO- 2
                OCTAL           14400                   # JETS  0  0  QNO  0  RNO- 2
                OCTAL           14104                   # JETS  5 13  QNO  0  RNO- 4
                OCTAL           14021                   # JETS  1  9  QNO  0  RNO- 4
                OCTAL           22042                   # JETS  2 10  QNO  1  RNO  1
                OCTAL           22042                   # JETS  2 10  QNO  1  RNO  1
                OCTAL           22210                   # JETS  6 14  QNO  1  RNO  1

## Page 600
                OCTAL           26610                   # JETS  6 14  QNO  2  RNO  2
                OCTAL           26442                   # JETS  2 10  QNO  2  RNO  2
                OCTAL           11042                   # JETS  2 10  QNO- 1  RNO- 1
                OCTAL           11042                   # JETS  2 10  QNO- 1  RNO- 1
                OCTAL           11210                   # JETS  6 14  QNO- 1  RNO- 1
                OCTAL            4610                   # JETS  6 14  QNO- 2  RNO- 2
                OCTAL            4442                   # JETS  2 10  QNO- 2  RNO- 2
                OCTAL           12210                   # JETS  6 14  QNO- 1  RNO  1
                OCTAL           12210                   # JETS  6 14  QNO- 1  RNO  1
                OCTAL           12042                   # JETS  2 10  QNO- 1  RNO  1
                OCTAL            6442                   # JETS  2 10  QNO- 2  RNO  2
                OCTAL            6610                   # JETS  6 14  QNO- 2  RNO  2
                OCTAL           21210                   # JETS  6 14  QNO  1  RNO- 1
                OCTAL           21210                   # JETS  6 14  QNO  1  RNO- 1
                OCTAL           21042                   # JETS  2 10  QNO  1  RNO- 1
                OCTAL           24442                   # JETS  2 10  QNO  2  RNO- 2
                OCTAL           24610                   # JETS  6 14  QNO  2  RNO- 2
                OCTAL           22021                   # JETS  1  9  QNO  1  RNO  1
                OCTAL           22021                   # JETS  1  9  QNO  1  RNO  1
                OCTAL           22104                   # JETS  5 13  QNO  1  RNO  1
                OCTAL           26504                   # JETS  5 13  QNO  2  RNO  2
                OCTAL           26421                   # JETS  1  9  QNO  2  RNO  2
                OCTAL           11021                   # JETS  1  9  QNO- 1  RNO- 1
                OCTAL           11021                   # JETS  1  9  QNO- 1  RNO- 1
                OCTAL           11104                   # JETS  5 13  QNO- 1  RNO- 1
                OCTAL            4504                   # JETS  5 13  QNO- 2  RNO- 2
                OCTAL            4421                   # JETS  1  9  QNO- 2  RNO- 2
                OCTAL           12104                   # JETS  5 13  QNO- 1  RNO  1
                OCTAL           12104                   # JETS  5 13  QNO- 1  RNO  1
                OCTAL           12021                   # JETS  1  9  QNO- 1  RNO  1
                OCTAL            6421                   # JETS  1  9  QNO- 2  RNO  2
                OCTAL            6504                   # JETS  5 13  QNO- 2  RNO  2
                OCTAL           21104                   # JETS  5 13  QNO  1  RNO- 1
                OCTAL           21104                   # JETS  5 13  QNO  1  RNO- 1
                OCTAL           21021                   # JETS  1  9  QNO  1  RNO- 1
                OCTAL           24421                   # JETS  1  9  QNO  2  RNO- 2
                OCTAL           24504                   # JETS  5 13  QNO  2  RNO- 2
                OCTAL           22000                   # JETS  0  0  QNO  1  RNO  1
                OCTAL           22000                   # JETS  0  0  QNO  1  RNO  1
                OCTAL           26400                   # JETS  0  0  QNO  2  RNO  2
                OCTAL           12000                   # JETS  0  0  QNO- 1  RNO  1
                OCTAL           12000                   # JETS  0  0  QNO- 1  RNO  1
                OCTAL            6400                   # JETS  0  0  QNO- 2  RNO  2
                OCTAL           11000                   # JETS  0  0  QNO- 1  RNO- 1
                OCTAL           11000                   # JETS  0  0  QNO- 1  RNO- 1
                OCTAL            4400                   # JETS  0  0  QNO- 2  RNO- 2
                OCTAL           21000                   # JETS  0  0  QNO  1  RNO- 1
                OCTAL           21000                   # JETS  0  0  QNO  1  RNO- 1
                OCTAL           24400                   # JETS  0  0  QNO  2  RNO- 2
                OCTAL           25400                   # JETS  0  0  QNO  2  RNO  0

## Page 601
                OCTAL           25400                   # JETS  0  0  QNO  2  RNO  0
                OCTAL           25400                   # JETS  0  0  QNO  2  RNO  0
                OCTAL           25400                   # JETS  0  0  QNO  2  RNO  0
                OCTAL           16400                   # JETS  0  0  QNO  0  RNO  2
                OCTAL           16400                   # JETS  0  0  QNO  0  RNO  2
                OCTAL           16400                   # JETS  0  0  QNO  0  RNO  2
                OCTAL           16400                   # JETS  0  0  QNO  0  RNO  2
                OCTAL            5400                   # JETS  0  0  QNO- 2  RNO  0
                OCTAL            5400                   # JETS  0  0  QNO- 2  RNO  0
                OCTAL            5400                   # JETS  0  0  QNO- 2  RNO  0
                OCTAL            5400                   # JETS  0  0  QNO- 2  RNO  0
                OCTAL           14400                   # JETS  0  0  QNO  0  RNO- 2
                OCTAL           14400                   # JETS  0  0  QNO  0  RNO- 2
                OCTAL           14400                   # JETS  0  0  QNO  0  RNO- 2
                OCTAL           14400                   # JETS  0  0  QNO  0  RNO- 2
                OCTAL           25400                   # JETS  0  0  QNO  2  RNO  0
                OCTAL           25400                   # JETS  0  0  QNO  2  RNO  0
                OCTAL           25400                   # JETS  0  0  QNO  2  RNO  0
                OCTAL           25400                   # JETS  0  0  QNO  2  RNO  0
                OCTAL           31400                   # JETS  0  0  QNO  4  RNO  0
                OCTAL           16400                   # JETS  0  0  QNO  0  RND  2
                OCTAL           16400                   # JETS  0  0  QNO  0  RND  2
                OCTAL           16400                   # JETS  0  0  QNO  0  RNO  2
                OCTAL           16400                   # JETS  0  0  QNO  0  RNO  2
                OCTAL           17000                   # JETS  0  0  QNO  0  RNO  4
                OCTAL            5400                   # JETS  0  0  QNO- 2  RNO  0
                OCTAL            5400                   # JETS  0  0  QNO- 2  RNO  0
                OCTAL            5400                   # JETS  0  0  QNO- 2  RNO  0
                OCTAL            5400                   # JETS  0  0  QNO- 2  RNO  0
                OCTAL            1400                   # JETS  0  0  QNO- 4  RNO  0
                OCTAL           14400                   # JETS  0  0  QNO  0  RNO- 2
                OCTAL           14400                   # JETS  0  0  QNO  0  RNO- 2
                OCTAL           14400                   # JETS  0  0  QNO  0  RNO- 2
                OCTAL           14400                   # JETS  0  0  QNO  0  RNO- 2
                OCTAL           14000                   # JETS  0  0  QNO  0  RNO- 4



# NORMLPOL LISTS THE ENTRY POINTS OF NORMAL POLICIES
                DEC             127
                DEC             126
                DEC             88
                DEC             88
                DEC             122
                DEC             121
                DEC             85
NORMLPOL        DEC             85
                DEC             91
                DEC             91

## Page 602
                DEC             82
                DEC             82
                DEC             117
                DEC             116
                DEC             112
                DEC             111

# ASCNTPOL LISTS THE ENTRY POINTS UNDER ASCENT CONDITIONS

                DEC             127
                DEC             107
                DEC             88
                DEC             88
                DEC             122
                DEC             103
                DEC             85
ASCNTPOL        DEC             85
                DEC             91
                DEC             91
                DEC             82
                DEC             82
                DEC             117
                DEC             99
                DEC             112
                DEC             95

# +XPOLADR LISTS THE ENTRY POINTS UNDER +X TRANSLATION CONDITIONS

                DEC             19
                DEC             17
                DEC             49
                DEC             47
                DEC             14
                DEC             12
                DEC             54
+XPOLADR        DEC             52
                DEC             59
                DEC             57
                DEC             44
                DEC             42
                DEC             9
                DEC             7
                DEC             4
                DEC             2

# -XPOLADR LISTS THE ENTRY POINTS UNDER -X TRANSLATION CONDITIONS

                DEC             39
                DEC             37
                DEC             69

## Page 603
                DEC             67
                DEC             34
                DEC             32
                DEC             74
-XPOLADR        DEC             72
                DEC             79
                DEC             77
                DEC             64
                DEC             62
                DEC             29
                DEC             27
                DEC             24
                DEC             22
