### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    Q,R-AXES_JET_SELECT_AND_FAILURE_CONTROL_LOGIC.agc
## Purpose:     A section of Sunburst revision 37, or Shepatin revision 0.
##              It is part of an early development version of the software
##              for Apollo Guidance Computer (AGC) on the unmanned Lunar
##              Module (LM) flight Apollo 5. Sunburst 37 was the program
##              upon which Don Eyles's offline development program Shepatin
##              was based; the listing herein transcribed was actually for
##              the equivalent revision 0 of Shepatin.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 520-534
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-05-30 HG   Transcribed
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 520
# PROGRAM: POLTYPEP               MOD. NO. 1  DATE: NOVEMBER 14, 1966

# AUTHOR: JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)

# THIS PROGRAM IS DESIGNED TO SELECT A POLICY OF JETS (OF WHICH NONE HAVE FAILED) WHICH CAN BE USED TO CREATE THE
# ROTATION AND/OR TRANSLATION WHICH IS REQUIRED BY THE LM DAP.  FROM THE INDEX "NETACNDX" (WHICH MUST BE SET WHEN
# ROTATION IS REQUESTED), THE OPTIMAL POLICY IS SELECTED.  WHEN FAILURES ARE DETECTED WITHIN A CHOSEN POLICY, AN
# ALTERNATE POLICY IS SELECTED.  IF ALL ALTERNATE POLICIES ARE EXHAUSTED WITHOUT FINDING AN UNFAILED POLICY, A JET
# FAILURE ABORT IS INITIATED.  WHEN THE ROUTINE IS USE FOR TRANSLATION JETS ONLY, "TRANONLY" MUST BE SET POSITIVE
# (NONZERO) AND THE ENTRY POINT IS "+/-XTRAN".

# CALLING SEQUENCES:

# 1. FOR ROTATION (WITH POSSIBLE +X TRANSLATION):

#                                                  CAF    RETURN          (GENADR OF RETURN)
#                                                  TS     TJETADR
#                                                  ...
#                                                  CAF    INDEXVAL        INDICATE ROT. AXIS, DIRECTION,
#                                                  TS     NETACNDX        AND NUMBER OF JETS.
#                                                  EXTEND
#                                                  DCA    POLADR          TRANSFER ACROSS BANKS TO POLTYPEP.
#                                                  DTCB

# 2. FOR TRANSLATION ONLY:

#                                                  CAF    POSMAX/NEGMAX   INDICATE -X TRANSLATION BY POSMAX.
#                                                  TS     ANYTRANS                 +X TRANSLATION BY NEGMAX.
#                                                  CAF    ZERO            ZERO EXTRANEOUS FLAGS FOR ROUTINE
#                                                  TS     TRANSNOW        ...
#                                                  TS     TRANSAVE        ...
#                                                  EXTEND
#                                                  DCA    JTPOLADR        TRANSFER ACROSS BANKS TO +/-XTRAN
#                                                  TS     TRANONLY        (AND SET TRANONLY POSITIVE NONZERO.)
#                                                  DTCB

# SUBROUTINES CALLED: NONE.

# NORMAL RETURN  1. FOR ROTATION, TO ADDRESS IN BANK 17 SPECIFIED BY C(TJETADR).
#                2. FOR TRANSLATION, RESUME.

# ALARM/ABORT MODE: WHENEVER THERE IS NO USABLE JET POLICY FOUND, TRANSFER TO JETABORT.

# INPUT: NETACNDX,CH5MASK,1/NETACS.

# OUTPUT: JETS ON IN CHANNEL 5, JTSATCHG.

# DEBRIS: A,L,ALLL ITEMPS,ALL RUPTREGS.

# INITIALIZATION AT ROTATION REQUEST ENTRY POINT:

## Page 521
                BANK            20
                EBANK=          JTSONNOW

POLTYPEP        CAF             ZERO                    # SET VOLATILE SWITCHES TO INDICATE
                TS              TRANONLY                # 1) TRANSLATION ENTRY NOT MADE (ROTATION)
                TS              ANYTRANS                # 2) NO TRANSLATION KNOWN YET.
                TS              TRANSNOW                # 3) NO TRANS. DURING ROT. KNOWN YET.
                TS              TRANSAVE                # 4) NO TRANSLATION POLICY SELECTED YET.

# TEST FOR SENSE OF ROTATION JETS.  (MAKE TRANSLATION REQUEST FROM THE ASTRONAUT'S STICK OVERRIDE INTERNAL ULLAGE)

                CAF             BIT7                    # ASTRONAUT +X TRANSLATION REQUEST TEST.
                EXTEND
                RAND            31
                EXTEND
                BZF             +XTRANSL

                CAF             BIT8                    # ASTRONAUT -X TRANSLATION REQUEST TEST.
                EXTEND
                RAND            31
                EXTEND
                BZF             -XSENSE

# CHECK FOR ULLAGE OR ASCENT BURN:

ULL/+X          CAF             BITS6&8                 # CHECK FOR ULLAGE OR ASCENT BURN: (EITHER
                MASK            DAPBOOLS                # BIT REQUIRES +X SENSE FOR ROTATION JETS)
                CCS             A                       # BIT6: ULLAGE BIT  (+X TRANSLATION ASKED)
                TCF             +XSELECT                # BIT8: ASCENT BURN (NO TRANSLATION ASKED)

# LM IS EITHER IN POWERED DESCENT OR IN COASTING FLIGHT  SELECT JETS WHICH ARE PAIRED IN FORCE COUPLES.

                INDEX           NETACNDX                # PICK UP FORCE-COUPLE TABLE INDEX AND THE
                CAF             NORMLPOL                # NUMBER OF POLICIES TO CHECK (PACKED).

# UNPACK THE RELATIVE ADDRESS OF THE BEST POLICY AND THE NUMBER OF ALTERNATE POLICIES TO CHECK WITHIN THE LOOP.

# THIS BITS ARE PACKED THUSLY  0XYYY, WHERE X BECOMES C(LOOPCTR) AND YYY BECOMES C(POLRELOC). BITS8,9 ARE ZERO.

NUMBALTS        TS              L                       # SAVE FULL WORD TO GET BITS 10-12, LATER.
                MASK            LOW7                    # MASK BITS GIVING INDEX VALUE FOR BEST
                TS              POLRELOC                # POLICY (W.R.T. TOP OF POLTABLE).

                CAF             BIT6                    # EXTRACT BITS 10-12 OF ORIGINAL WORD:
                EXTEND                                  # THIS VALUE IS USED AS A LOOP COUNTER TO
                MP              L                       # TEST ALL THE FEASIBLE JET POLICIES FOR
BESTPOLS        TS              LOOPCTR                 # THE GIVEN REQUEST.  (ALSO TOP 0F LOOP.)

## Page 522
# LOOP TP SET UP "TRANSNOW" AND REJECT ALL FAILED POLICIES:

                INDEX           POLRELOC                # PICK UP NEXT POLICY TO CHECK FOR FAILURE
                CAF             POLTABLE                # (MUST DO A "CAF" THEN "CCS" FOR RANGE.)
                CCS             A                       # IF POLICY TABLE ENTRY IS NEGATIVE, THEN
CHKFAILS        TS              THISPOLY                # A FLAG IS SET TO DO SOME TRANSLATION
                TCF             +3                      # WITH THE ROTATION POLICY SELECTED. IF
                TS              TRANSNOW                # REQUESTED. POLTABLE VALUES ARE CCS-ABLE.
                TCF             CHKFAILS                # TRANSNOW (ONCE ON) STAYS ON FOR THIS CSP

                MASK            CH5MASK                 # COMPARE THISPOLY WITH BITS OF FAILED JET
                CCS             A                       # IF C(A) = +0, THEN THERE ARE NO FAILURES
                TCF             +2                      # IN THIS POLICY AND THE LM DAP USES IT.
                TCF             POLFOUND                # IF C(A) IS NOT +0, IT IS POSITIVE AND

                EXTEND                                  # FIRST THE RELATIVE ADDRESS INDEXER IS
                DIM             POLRELOC                # DECREMENTED BY ONE FOR THE NEXT POLICY,
                CCS             LOOPCTR                 # THEN A CHECK IS MADE FOR ANY MORE USABLE
                TCF             BESTPOLS                # POLICIES, IF NO MORE, C(LOOPCTR) = +0.

# ***** JET FAILURE ABORT SEQUENCE. *****

ABORTJET        CAF             ZERO                    # TURN OFF ALL JETS.
                EXTEND
                WRITE           5
                EXTEND
                WRITE           6

                CAF             PRIO37                  # ABORT PRIORITY.
                TC              NOVAC                   # CALL JETABORT THROUGH EXECUTIVE.
                EBANK=          JTSONNOW
                2CADR           JETABORT
                CS              GODAPGO                 # SET GODAPGO TO TURN LM DAP OFF WHEN THIS
                MASK            DAPBOOLS                # BIT IS CHECKED IN THE NEXT P-AXIS RUPT.
                TS              DAPBOOLS

                TCF             RESUME

# ***** END JET FAILURE ABORT SEQUENCE. *****

## Page 523
# ENTER HERE AFTER ULLAGE/ASCENT DETECTION:

+XSELECT        CS              DAPBOOLS                # CHECK FOR ULLAGE  BIT6/DAPBOOLS =1.
                MASK            ULLAGER                 # IF THE ULLAGE BIT IS 0, THEN THE LM IS
                CCS             A                       # IN AN ASCENT BURN AND NO +X TRANSLATION
                TCF             +XSENSE                 # HAS BEEN REQUESTED (SEE ULL/+X).

# ENTER HERE FOR +X TRANSLATION:

+XTRANSL        CAF             NEGMAX                  # INDICATE +X TRANSLATION FOR CCS LATER.
                TS              ANYTRANS                # (ANYTRANS IS A VOLATILE SWITCH.)

# ENTER HERE FOR +X SENSE JETS:

+XSENSE         INDEX           NETACNDX                # PICK UP +X SENSE TABLE INDEX AND THE
                CAF             +SENSTAB                # NUMBER OF ALTERNATE POLICIES TO CHECK.

                TCF             NUMBALTS                # GO TO BEGIN FAILURE CHECKING (ROTATION).

# ENTER HERE FOR -X TRANSLATION:

-XSENSE         CAF             POSMAX                  # INDICATE -X TRANSLATION FOR CCS LATER.
                TS              ANYTRANS                # (ANYTRANS IS A VOLATILE SWITCH.)

                INDEX           NETACNDX                # PICK UP -X SENSE TABLE INDEX AND THE
                CAF             -SENSTAB                # NUMBER OF ALTERNATE POLICIES TO CHECK.

                TCF             NUMBALTS                # GO TO BEGIN FAILURE CHECKING (ROTATION).

# ENTER HERE AFTER A ROTATION POLICY HAS BEEN FOUND:

POLFOUND        CAE             THISPOLY                # GET POSITIVE-VALUED POLICY TABLE ENTRY
                EXTEND                                  # WHICH IS INSURED AGAINST FAILURE.
                MP              BIT4                    # UNPACK BITS 12-14 OF TABLE ENTRY GET THE
                INDEX           A                       # NUMBER OF Q-AXIS JETS FROM TORQUE TABLE.
                CAF             TORKTABL                # SAVE FOR TORQUE VECTOR RECONSTRUCTION
                TS              NO.QJETS                # AND FOR DETERMINING 1/NETACC.

                CAE             L                       # UNPACK BITS 9-11 OF TABLE ENTRY WHICH
                EXTEND                                  # ARE NOW BITS 12-14 OF THE L-REGISTER.
                MP              BIT4                    # (BIT15 OF L IS 0 DUE TO SIGN AGREEMENT.)
                INDEX           A                       # GET NUMBER OF R-AXIS JETS FROM TORQUE
                CAF             TORKTABL                # TABLE.  SAVE FOR TORQUE VECTOR RECON-

                TS              NO.RJETS                # STRUCTION AND FOR GETTING 1/NETACC.

# PICK OUT ROTATION JETS FROM TABLE ENTRY:

                CAE             THISPOLY                # UNPACK BITS 1-8 OF TABLE ENTRY (DONE
                MASK            LOW8                    # MOST EASILY BY THE MASKING OPERATION).
                AD              BIT15                   # SET SIGN TO INDICATE Q,R-AXES JETS.

## Page 524
                TS              JTSONNOW                # SET POLICY UP FOR IMMEDIATE USE.

## Page 525

# ENTRY POINT FOR +X TRANS, OR -X TRANS. REQUEST ALONE:

# (ALSO CONTINUATION OF TRANSLATION-WITH-ROTATION LOGIC.)

+/-XTRAN        CAF             TWO                     # SET UP LOOP TO TEST ALL THREE POSSIBLE
                TS              LOOPCTR                 # TRANSLATION POLICIES, IF 4 JETS ASKED.

                CCS             ANYTRANS                # TEST FOR TRANSLATION REQUESTS: -0 UNUSED

                TCF             -XPOLICY                # POSMAX: -X TRANSLATION.
                TCF             LATERJET                #  +ZERO: NO TRANSLATION.

# ENTER HERE FOR +X TRANSLATION POLICIES:

+XPOLICY        CAF             TWO                     # NEGMAX: +X TRANSLATION.
                TCF             +2                      # SET POLRELOC FOR +X TRANS. INDEXING.

# ENTER HERE FOR -X TRANSLATION POLICIES:

-XPOLICY        CAF             FIVE                    # SET POLRELOC FOR -X TRANS. INDEXING.
                TS              POLRELOC                # (INITIAL VALUE ALWAYS FOR 4-JET POLICY.)

# TEST FOR TRANSLATION TO BE COMBINED WITH ROTATION JETS.

                CCS             TRANSNOW                # TEST IF TRANSLATION WITH ROTATION IS
                TCF             TRANCONT                # REQUESTED, IF SO, OVER-RIDE 4-JET TEST.

# DETERMINE IF LM DAP IS IN 2 OR 4 JET TRANSLATION MODE:

                CS              DAPBOOLS                # TEST FOR 2/4-JET TRANSLATION MODE IN
                MASK            ACC4OR2X                # BIT4/DAPBOOLS (ASTRONAUT DSKY INPUT)
                CCS             A                       # 0: 2 JET MODE (SKIP OUT).

                TCF             TRANCONT                # 1: 4 JET MODE (CONTINUE).

# TEST TRANSLATION POLICIES FOR JET FAILURES:

TRANNEXT        INDEX           POLRELOC                # PICK UP POLICY FOR +/-X TRANSLATION
                CAF             TRANPOLY                # FROM TABLE (INDEXED WITHIN REQUESTED
                TS              THISPOLY                # RANGE OF POLICIES); TEST FOR FAILURES
                MASK            CH5MASK                 # IF NO FAILURES, C(A) = +0.  IF POLICY
                CCS             A                       # CANNOT BE USED , C(A) IS POSITIVE.
                TCF             TRANCNTD                # IF FAILED, CHECK FOR STORE GOOD TRANS.

# SPECIAL TESTS ARE NEEDED FOR TRANSLATION DURING ROTATION:

                CCS             TRANSNOW                # TEST FOR TRANSLATION DURING ROTATION
                TCF             TRANSTOR                # IF SO, GO TEST THIS POLICY FOR USE NOW.

# TEST FOR ONLY TRANSLATION REQUEST:

                CCS             TRANONLY                # TEST FOR PURE TRANSLATION REQUEST

## Page 526
                TCF             TRANOROT                # IF SO, GIVE TRANSLATION, NO ROTATION

# SPECIAL TEST FOR GOOD 4-JET TRANSLATION:

                CS              TWO                     # TEST IF POLICY IS USING FOUR JETS (WHICH
                AD              LOOPCTR                 # IS EQUIVALENT TO LOOPCTR = 2).  IF 4-JET
                EXTEND                                  # THIS POLICY MUST BE USED AS JTSATCHG.
                BZF             TRAN4JET                # OTHERWISE, MUST CHECK TRANSAVE FIRST.

# WHEN NOT 4-JET TRANSLATION,  CHECK FOR SAVED POLICY:

                CCS             TRANSAVE                # TEST FOR SAVED POLICY; IF SAVED, USE IT.
                TCF             TRANUSED                # IF NOT SAVED YET, USE THIS POLICY.

# USE THIS POLICY (EITHER 4 JETS OR BEST 2 JET):

TRAN4JET        CAE             THISPOLY                # USE THIS UNFAILED POLICY AS THE TRANS-
                TCF             LATERJET                # LATION POLICY AFTER ROTATION.

# FOR TRANSLATION WITHOUT ROTATION, TURN JETS ON IMMEDIATELY AND RESUME:

TRANOROT        CAE             THISPOLY                # TURN ON UNFAILED Q,R-AXES JETS AS A PURE
                EXTEND                                  # TRANSLATION POLICY WITHOUT ANY TJETLAW
                WRITE           5                       # CALCULATIONS (AND NO TIME6 SETTING).

                TCF             RESUME                  # END T5RUPT SINCE JETS ON FOR FULL CSP.

# TEST THIS TRANSLATION FOR USE DURING ROTATION:

TRANSTOR        CAE             THISPOLY                # SAVE THIS POLICY FOR LATER USE AS THE
                TS              TRANSAVE                # JTSATCHG POLICY UNLESS IT IS SUPERCEDED.
                MASK            JTSONNOW                # TEST FOR USE WITH ROTATION POLICY  MUST
                CCS             A                       # HAVE NO JETS IN COMMON WITH JTSONNOW.
                TCF             TRANCONT                # C(A) POSITIVE MEANS POLICIES CONFLICT.

# COINCIDENT TRANSLATION FOUND, GO FIND PURE TRANSLATION POLICY (FOR USE AFTER ROTATION):

                CAE             THISPOLY                # USE BOTH ROTATION AND TRANSLATION JETS

                ADS             JTSONNOW                # AT JTSONNOW (BIT 15 IS ALREADY SET).

                TCF             TRANSLAT                # GO TO START FINDING JTSATCHG POLICY.

# STOP SEARCH IF GOOD TRANSLATION POLICY ALREADY RECORDED:

TRANCNTD        CCS             TRANSAVE                # TEST FOR PREVIOUSLY SAVED TRANSLATION
                TCF             TRANUSED                # POLICY, IF IT EXISTS, USE IT.

# CONTINUE FAILURE CHECKING LOOP:

TRANCONT        EXTEND                                  # CONTINUE THE TRANSLATION-FAIL LOOP

## Page 527
                DIM             POLRELOC                # DECREMENT THE TRANSLATION POLICY INDEX
                CCS             LOOPCTR                 # AND THEN TEST LOOPCTR FOR CONTINUATION
                TCF             TRNRESET                # OF JET FAILURE TESTING.

# IF NO TRANSLATION CAN BE FOUND FOR ROTATION POLICY, ALL IS NOT LOST, OTHERWISE, START JET FAILURE ABORT:

                CCS             TRANSNOW                # IF FAILURES STOP TRANSLATION DURING
                TCF             TRANSLAT                # ROTATION' CONTINUE BY FINDING JTSATCHG.

                TCF             ABORTJET                # TURN OFF JETS AND ABORT.

# BEGIN SEARCH FOR JTSATCHG POLICY:

TRANSLAT        CAF             ZERO                    # SET VOLATILE FLAG TO INDICATE SEARCH IS
                TS              TRANSNOW                # FOR JTSATCHG, AFTER TRANSNOW DONE.

                TCF             +/-XTRAN                # GO TO RE-INITIALIZE LOOP FROM SCRATCH.

# "TOP OF LOOP" (FOR ALL BUT FIRST PASS):

TRNRESET        TS              LOOPCTR                 # RESET LOOP COUNTER TO CONTINUE LOOPING
                TCF             TRANNEXT                # GO TO CONTINUATION OF LOOP (AT THE TOP).

# RECONSTRUCT FLAGGED JET POLICY:

TRANUSED        AD              ONE                     # RESET POLICY THAT WAS POSITIVE AND CCSED
LATERJET        AD              BIT15                   # SET BIT 15 TO INDICATE Q,R-AXES POLICY.
                TS              JTSATCHG                # USE FOR JTSATCHG TRANSLATION POLICY.

# TRANSFORM INITIAL POINTER TO 2-JET POLICY:

                CAF             ONE                     # FROM THE INDEX VALUE INDICATING NUMBER
                MASK            NETACNDX                # OF JETS, DIRECTION, AND AXIS' COMPUTE
                CCS             A                       # THE INDEX VALUE FOR 2 JETS ABOUT THAT
                TCF             +3                      # AXIS (IN THAT DIRECTION).  CONTRIVANCE
                EXTEND                                  # MAKES THIS EQUIVALENT TO  IF BIT1 IS ON.
                AUG             NETACNDX                # (INDEP. OF SIGN)  AUGMENT  NETACNDX.

# TRANSFORM POINTER TO CORRESPOND TO JETS ACTUALLY CHOSEN.

                CCS             NO.QJETS                # TRANSFORM INDEX TO APPROPRIATE VALUE FOR
                TCF             +2                      # THE NUMBER OF JETS SELECTED.
                TCF             ALLRJETS                # IF NO.QJETS ZERO, NO.RJETS IS NONZERO.

                CCS             A                       # IF NO.QJETS +/-1, NO.RJETS IS +/-1 (BY
                TCF             +2                      # DEFINITION)  SO SUBTRACT ONE FROM INDEX.
                TCF             SMALAXIS                # GO TRANSFORM FOR 1 U,V-AXIS JET.
                CCS             A                       # IF STILL NONZERO ON THIRD CCS, NO.QJETS
                INCR            NETACNDX                # MUST HAVE BEEN +/-4, SO ADD ONE TO THE
                TCF             NETACGET                # INDEX, OTHERWISE, NO CHANGE (2 JETS).

## Page 528
SMALAXIS        EXTEND                                  # DECREMENT INDEX FOR 1 JET AROUND EITHER
                DIM             NETACNDX                # THE U- OR V- AXIS.

                TCF             NETACGET                # (GO PICK UP INVERSE OF NET ACCELERATION)

ALLRJETS        CCS             NO.RJETS                # WHEN NO.QJETS ZERO, TEST NO.RJETS WHICH
                MASK            TWO                     # IS ONLY +/-2 OR +/-4.  NOTE LAST THREE
                TCF             +2                      # BITS OF THESE AFTER CCS  001 OR 011.
                MASK            TWO                     # ONLY BIT2 DISTINGUISHES BETWEEN THE TWO.
                EXTEND                                  # IF BIT2 = 0, THEN TWO JETS, NO CHANGE.
                BZF             +2                      # IF BIT2 = 1, THEN FOUR JETS, SO THE
                INCR            NETACNDX                # INDEX MUST BE INCREMENTED.

# PICK UP AND SAVE 1/NETACC FOR TJETLAW:

NETACGET        INDEX           NETACNDX                # USE THE INDEX VALUE FOR THE EXACT JETS
                CAE             1/NETACS                # USED, PICK UP THE APPROPRIATE 1/NETACC
                TS              1/NETACC                # AND SAVE FOR USE BY THE TJETLAW.

# RETURN TO APPROPRIATE TJETLAW:

                CAF             BBANKSET                # ALWAYS RETURN TO THE FIXED BANK OF THE
                TS              L                       # Q,R-AXES REACTION CONTROL SYSTEM LM DAP.
                CAE             TJETADR                 # USE VARIABLE GENADR WITH WHICH TO
                DTCB                                    # CROSS BANKS TO RETURN.

                EBANK=          OMEGAQ
BBANKSET        BBCON           QRAXIS                  # BBCON OF Q,R-AXES RCS LM DAP.

BITS6&8         OCTAL           00240                   # ULLAGE AND ASCENT BURN DAPBOOLS BITS.

## Page 529

# TABLE OF Q,R-JET NUMBERS AND DIRECTIONS:

TORKTABL        DEC             0                       # FROM THE 3 PACKED BITS IN A WORD FROM
                DEC             +1                      # POLTABLE, THE POLTYPEP PROGRAM SELECTS
                DEC             -1                      # THE APPROPRIATE NO.QJETS OR NO.RJETS
                DEC             +2                      # AS FOLLOWS:
                DEC             -2                      # 000: NO JETS
                DEC             +4                      # 001: +1 JET   011: +2 JETS  101: +4 JETS

                DEC             -4                      # 010: -1 JET   100: -2 JETS  110: -4 JETS


# RELATIVE ADDRESSES AND NUMBER OF ALTERNATE POLICIES ARE LISTED IN THE FOLLOWING TABLES.  EACH ENTRY HAS THE FORM
#          0XYYY  WHERE   X INDICATES THE NUMBER OF ALTERNATE POLICIES AND
#                       YYY IS THE RELATIVE ADDRESS IN POLTABLE OF THE "OPTIMAL" POLICY.

# FORCE-COUPLE POLICIES:

                OCTAL           03003                   # +2 Q-AXIS JETS
                OCTAL           04004                   # +4 Q-AXIS JETS
                OCTAL           03010                   # -2 Q-AXIS JETS
                OCTAL           04011                   # -4 Q-AXIS JETS
                OCTAL           03015                   # +2 R-AXIS JETS
                OCTAL           04016                   # +4 R-AXIS JETS
                OCTAL           03022                   # -2 R-AXIS JETS
                OCTAL           04023                   # -4 R-AXIS JETS
NORMLPOL        OCTAL           02026                   # +2 U-AXIS JETS
                OCTAL           02026                   # +2 U-AXIS JETS
                OCTAL           02031                   # -2 U-AXIS JETS
                OCTAL           02031                   # -2 U-AXIS JETS
                OCTAL           02034                   # +2 V-AXIS JETS

                OCTAL           02034                   # +2 V-AXIS JETS
                OCTAL           02037                   # -2 V-AXIS JETS
                OCTAL           02037                   # -2 V-AXIS JETS

## Page 530

# +X SENSE POLICIES:

                OCTAL           03043                   # +2 Q-AXIS JETS
                OCTAL           04044                   # +4 Q-AXIS JETS
                OCTAL           03050                   # -2 Q-AXIS JETS
                OCTAL           04051                   # -4 Q-AXIS JETS
                OCTAL           03055                   # +2 R-AXIS JETS
                OCTAL           04056                   # +4 R-AXIS JETS
                OCTAL           03062                   # -2 R-AXIS JETS
                OCTAL           04063                   # -4 R-AXIS JETS
+SENSTAB        OCTAL           01024                   # +1 U-AXIS JETS
                OCTAL           02025                   # +2 U-AXIS JETS
                OCTAL           01027                   # -1 U-AXIS JETS
                OCTAL           02030                   # -2 U-AXIS JETS

                OCTAL           01032                   # +1 V-AXIS JETS
                OCTAL           02033                   # +2 V-AXIS JETS
                OCTAL           01036                   # -1 V-AXIS JETS
                OCTAL           02037                   # -2 V-AXIS JETS

# -X SENSE POLICIES:

                OCTAL           03067                   # +2 Q-AXIS JETS
                OCTAL           04070                   # +4 Q-AXIS JETS
                OCTAL           03074                   # -2 Q-AXIS JETS
                OCTAL           04075                   # -4 Q-AXIS JETS
                OCTAL           03101                   # +2 R-AXIS JETS
                OCTAL           04102                   # +4 R-AXIS JETS
                OCTAL           03106                   # -2 R-AXIS JETS
                OCTAL           04107                   # -4 R-AXIS JETS
-SENSTAB        OCTAL           01111                   # +1 U-AXIS JETS
                OCTAL           02112                   # +2 U-AXIS JETS
                OCTAL           01114                   # -1 U-AXIS JETS
                OCTAL           02115                   # -2 U-AXIS JETS
                OCTAL           01117                   # +1 V-AXIS JETS
                OCTAL           02120                   # +2 V-AXIS JETS
                OCTAL           01122                   # -1 V-AXIS JETS
                OCTAL           02123                   # -2 V AXIS JETS

## Page 531

# X-AXIS TRANSLATION POLICIES:

TRANPOLY        OCTAL           +00042                  #  2 10       * +X TRANSLATION JETS     0
                OCTAL           +00210                  #  6 14       *                         1
                OCTAL           +00252                  #  2  6 10 14 *                         2

                OCTAL           +00104                  #  3 13       * -X TRANSLATION JETS     3
                OCTAL           +00021                  #  1  9       *                         4
                OCTAL           +00125                  #  1  5  9 13 *                         5

## Page 532

# ROTATION JET POLICIES;

# FORCE COUPLE POLICIES:

POLTABLE        OCTAL           +14025                  #  5  9       * +Q-AXIS FORCE COUPLES    0
                OCTAL           +14203                  #  2 14       *                          1
                OCTAL           +14221                  #  9 14       *                          2
                OCTAL           +14007                  #  2  5       *                          3
                OCTAL           +24227                  #  2  5  9 14 *                          4

                OCTAL           +20051                  #  6 10       * -Q-AXIS FORCE-COUPLES    5
                OCTAL           +20102                  #  1 13       *                          6
                OCTAL           +20141                  # 10 13       *                          7
                OCTAL           +20012                  #  1  6       *                         10
                OCTAL           +30152                  #  1  6 10 13 *                         11

                OCTAL           +01641                  # 10 14       * +R-AXIS FORCE-COUPLES   12
                OCTAL           +01406                  #  1  5       *                         13
                OCTAL           +01445                  #  5 10       *                         14
                OCTAL           +01602                  #  1 14       *                         15
                OCTAL           +02646                  #  1  5 10 14 *                         16

                OCTAL           +02121                  #  9 13       * -R-AXIS FORCE-COUPLES   17
                OCTAL           +02013                  #  2  6       *                         20
                OCTAL           +02103                  #  2 13       *                         21
                OCTAL           +02031                  #  6  9       *                         22

                OCTAL           +03133                  #  2  6  9 13 *                         23

# FORCE COUPLE AND +X SENSE POLICIES:

                OCTAL           -04405                  #  5          * +U-AXIS FORCE-COUPLES   24
                OCTAL           -04601                  # 14          *     AND +X SENSE        25
                OCTAL           -15605                  #  5 14       *                         26

                OCTAL           -11101                  # 13          * -U-AXIS FORCE-COUPLES   27
                OCTAL           -11011                  #  6          *     AND +X SENSE        30
                OCTAL           -22111                  #  6 13       *                         31

                OCTAL           -10402                  #  1          * +V-AXIS FORCE-COUPLES   32
                OCTAL           -10441                  # 10          *     AND +X SENSE        33
                OCTAL           -21442                  #  1 10       *                         34

                OCTAL           -05021                  #  9          * -V-AXIS FORCE-COUPLES   35
                OCTAL           -05003                  #  2          *     AND +X SENSE        36
                OCTAL           -16023                  #  2  9       *                         37

## Page 533

# +X SENSE POLICIES:

                OCTAL           +14025                  #  5  9       * +Q-AXIS +X SENSE JETS   40
                OCTAL           +14221                  #  9 14       *                         41
                OCTAL           +14007                  #  2  5       *                         42
                OCTAL           +14203                  #  2 14       *                         43
                OCTAL           +24227                  #  2  5  9 14 *                         44

                OCTAL           +20102                  #  1 13       * -Q-AXIS +X SENSE JETS   45
                OCTAL           +20141                  # 10 13       *                         46
                OCTAL           +20012                  #  1  6       *                         47
                OCTAL           +20051                  #  6 10       *                         50
                OCTAL           +30152                  #  1  6 10 13 *                         51

                OCTAL           +01406                  #  1  5       * +R-AXIS +X SENSE JETS   52
                OCTAL           +01445                  #  5 10       *                         53
                OCTAL           +01602                  #  1 14       *                         54
                OCTAL           +01641                  # 10 14       *                         55
                OCTAL           +02646                  #  1  5 10 14 *                         56

                OCTAL           +02121                  #  9 13       * -R-AXIS +X SENSE JETS   57
                OCTAL           +02103                  #  2 13       *                         60
                OCTAL           +02031                  #  6  9       *                         61
                OCTAL           +02013                  #  2  6       *                         62
                OCTAL           +03133                  #  2  6  9 13 *                         63

## Page 534

# -X SENSE POLICIES:

                OCTAL           +14203                  #  2 14       * +Q-AXIS -X SENSE JETS   64
                OCTAL           +14221                  #  9 14       *                         65
                OCTAL           +14007                  #  2  5       *                         66
                OCTAL           +14025                  #  5  9       *                         67
                OCTAL           +24227                  #  2  5  9 14 *                         70

                OCTAL           +20051                  #  6 10       * -Q-AXIS -X SENSE JETS   71
                OCTAL           +20141                  # 10 13       *                         72
                OCTAL           +20012                  #  1  6       *                         73
                OCTAL           +20102                  #  1 13       *                         74
                OCTAL           +30152                  #  1  6 10 13 *                         75

                OCTAL           +01641                  # 10 14       * +R-AXIS -X SENSE JETS   76
                OCTAL           +01445                  #  5 10       *                         77
                OCTAL           +01602                  #  1 14       *                        100
                OCTAL           +01406                  #  1  5       *                        101
                OCTAL           +02646                  #  1  5 10 14 *                        102

                OCTAL           +02013                  #  2  6       * -R-AXIS -X SENSE JETS  103
                OCTAL           +02103                  #  2 13       *                        104
                OCTAL           +02031                  #  6  9       *                        105
                OCTAL           +02121                  #  9  13      *                        106
                OCTAL           +03133                  #  2  6  9 13 *                        107

                OCTAL           -04601                  # 14          * +U-AXIS -X SENSE JETS  110
                OCTAL           -04405                  #  5          *                        111
                OCTAL           -15605                  #  5 14       *                        112

                OCTAL           -11011                  #  6          * -U-AXIS -X SENSE JETS  113
                OCTAL           -11101                  # 13          *                        114
                OCTAL           -22111                  #  6 13       *                        115

                OCTAL           -10441                  # 10          * +V-AXIS -X SENSE JETS  116
                OCTAL           -10402                  #  1          *                        117
                OCTAL           -21442                  #  1 10       *                        120

                OCTAL           -05003                  #  2          * -V-AXIS -X SENSE JETS  121
                OCTAL           -05021                  #  9          *                        122
                OCTAL           -16023                  #  2  9       *                        123
