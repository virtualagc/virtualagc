### FILE="Main.annotation"
# Copyright:    Public domain.
# Filename:     ALARM_AND_ABORT.agc
# Purpose:      Part of the source code for Aurora (revision 12).
# Assembler:    yaYUL
# Contact:      Ron Burkey <info@sandroid.org>.
# Website:      https://www.ibiblio.org/apollo.
# Pages:        XXXX-XXXX
# Mod history:  2016-09-20 JL   Created.

# This source code has been transcribed or otherwise adapted from
# digitized images of a hardcopy from the private collection of 
# Don Eyles.  The digitization was performed by archive.org.

# Notations on the hardcopy document read, in part:

#       473423A YUL SYSTEM FOR BLK2: REVISION 12 of PROGRAM AURORA BY DAP GROUP
#       NOV 10, 1966

#       [Note that this is the date the hardcopy was made, not the
#       date of the program revision or the assembly.]

# The scan images (with suitable reduction in storage size and consequent 
# reduction in image quality) are available online at 
#       https://www.ibiblio.org/apollo.  
# The original high-quality digital images are available at archive.org:
#       https://archive.org/details/aurora00dapg

## PAGE 336

# 473423A YUL SYSTEM FOR BLK2: REVISION 12 OF PROGRAM AURORA BY DAP GROUP 
#
# L PINBALL GAME BUTTONS AND LIGHTS

MODROUTB        =               DSPALARM                # **FIX LATER**
REQMM           CS              Q
                TS              REQRET
                CAF             ZERO
                TS              NOUNREG
                TC              BANKCALL
                CADR            2BLANK
                TC              FLASHON
                TC              ENTEXIT

# VBRQEXEC ENTERS REQUEST TO EXEC     FOR ANY ADDRESS WITH ANY PRIORITY.
# IT DOES ENDOFJOB AFTER ENTERING REQUEST. DISPLAY SYST IS RELEASED.
# IT ASSUMES NOUN 26 HAS BEEN PRELOADED WITH
# COMPONENT 1  PRIORITY(BITS 10-14) BIT1=0 FOR NOVAR, BIT1=1 FOR FINDVAC.
# COMPONENT 2  JOB ADRES (12 BIT )
# COMPONENT 3  BBCON

VBRQEXEC        CAF             BIT1
                MASK            DSPTEM1
                CCS             A
                TC              SETVAC                  # IF BIT1 = 1, FINDVAC
                CAF             TCNOVAC                 # IF BIT1 = 0, NOVAC
REQEX1          TS              MPAC                    # TC NOVAC  OR  TC FINDVAC INTO MPAC
                CS              BIT1
                MASK            DSPTEM1
                TS              MPAC            +4      # PRIO INTO MPAC+4 AS A TEMP
REQUESTC        TC              RELDSP
                CA              ENDINST
                TS              MPAC            +3      # TC ENDOFJOB INTO MPAC+3
                EXTEND
                DCA             DSPTEM1         +1      # JOB ADRES INTO MPAC+1
                DXCH            MPAC            +1      # BBCON INTO MPAC+2
                CA              MPAC            +4      # PRIO IN A
                INHINT
                TC              MPAC

SETVAC          CAF             TCFINDVC
                TC              REQEX1

# VBRQWAIT ENTERS REQUEST TO WAITLIST FOR ANY ADDRESS WITH ANY DELAY.
# IT DOES ENDOFJOB AFTER ENTERING REQUEST.DISPLAY SYST IS RELEASED.
# IT ASSUMES NOUN 26 HAS BEEN PRELOADED WITH
# COMPONENT 1  DELAY (LOW BITS)
# COMPONENT 2  TASK ADRES (12 BIT)
# COMPONENT 3  BBCON

## PAGE 337

VBRQWAIT        CAF             TCWAIT
                TS              MPAC                    # TC WAITLIST INTO MPAC
                CA              DSPTEM1                 # TIME DELAY
ENDRQWT         TC              REQUESTC        -1

# REQUESTC WILL PUT TASK ADRES INTO MPAC+1, BBCON INTO MPAC+2.
# TC ENDOFJOB INTO MPAC+3. IT WILL TAKE TIME DELAY OUT OF MPAC+4 AND
# LEAVE IT IN A, INHINT AND TC MPAC.

                SETLOC          NVSBENDL        +1
VBPROC          CAF             ONE                     # PROCEED WITHOUT DATA
                TS              LOADSTAT
                TC              RELDSP
                TC              FLASHOFF
                TC              RECALTST                # SEE IF THERE IS ANY RECALL FROM ENDIDLE

VBTERM          TC              KILMONON                # TURN ON KILL MONITOR BIT
                CS              ONE
                TC              VBPROC          +1      # TERM VERB SETS LOADSTAT NEG

# FLASH IS TURNED OFF ONLY BY PROCEED WITHOUT DATA, TERMINATE, END OF LOAD
#
# VBRELDSP TURNS OFF RELEASE DISPLAY SYSTEM LIGHT(AND SEARCHES LIST ONLY
# IF THIS LIGHT WAS TURNED ON BY NVSUBUSY), AND TURNS OFF UPACT LIGHT.

VBRELDSP        CS              BIT3
                EXTEND
                WAND            DSALMOUT                # TURNS OFF UPACT LIGHT
                TC              RELDSP                  # SEARCHES LIST
                TC              ENDOFJOB

# BUMP SHIFTS WORD DISPLAYED IN R2 TO R3, R1 TO R2. IT BLANKS R1.

BUMP            CAF             FIVE                    # R2D5
                TS              DSPCOUNT
                TS              COUNT
                CAF             ONE                     # SHIFT DATA OF R2 TO R3, R1 TO R2
                MASK            COUNT
                XCH             COUNT                   # +0 INTO COUNT IF EVEN (RIGHT)
                TS              SR                      # +1 INTO COUNT IF ODD (LEFT)
