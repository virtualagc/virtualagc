### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    KEYRUPT,_UPRUPT.agc
## Purpose:     Part of the source code for AGC program Retread 50. 
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/Restoration.html
## Mod history: 2019-06-12 MAS  Recreated from Computer History Museum's
##				physical core-rope modules.

## Page 131
KEYRUPT1        TS              BANKRUPT
                XCH             Q
                TS              QRUPT
                TC              LODSAMPT                # TIME IS SNATCHED IN RUPT FOR NOUN 65.
                CAF             LOW5
                EXTEND 
                RAND            MNKEYIN
KEYCOM          AD              BIT11
                TS              TMKEYBUF
                CAF             CHRPRIO
                TC              NOVAC
                EBANK=          DSPCOUNT
                2CADR           CHARIN

                CA              LOW5
                MASK            TMKEYBUF
                INDEX           LOCCTR
                TS              MPAC                    # LEAVE 5 BIT KEY CDE IN MPAC FOR CHARIN
                TC              RESUME



KEYRUPT2        TS              BANKRUPT
                XCH             Q
                TS              QRUPT
                TC              LODSAMPT                # TIME IS SNATCHED IN RUPT FOR NOUN 65.
                CAF             LOW5
                EXTEND
                RAND            NAVKEYIN
                TC              KEYCOM

## Page 132
# UPRUPT PROGRAM

UPRUPT          TS              BANKRUPT
                XCH             Q
                TS              QRUPT
                TC              LODSAMPT                # TIME IS SNATCHED IN RUPT FOR NOUN 65.
                CAF             ZERO
                XCH             INLINK
                TS              KEYTEMP1
                CAF             BIT3                    # TURN ON UPACT LIGHT
                EXTEND                                  # (BIT 3 OF CHANNEL 11)
                WOR             DSALMOUT
UPRUPT1         CAF             LOW5                    # TEST FOR TRIPLE CHAR REDUNDANCY
                MASK            KEYTEMP1                # LOW5 OF WORD
                XCH             KEYTEMP1                # LOW5 INTO KEYTEMP1
                XCH             SR                      # WHOLE WORD INTO SR
                TS              KEYTEMP2                # ORIGINAL SR INTO KEYTEMP2
                TC              SRGHT5
                MASK            LOW5                    # MID 5
                AD              HI10
                TC              UPTEST
                TC              SRGHT5
                MASK            LOW5                    # HIGH 5
                COM
                TC              UPTEST
UPOK            TC              RESTORSR                # CODE IS GOOD
                CS              ELRCODE                 # IF CODE = ERROR LIGHT RESET, PUT +0
                AD              KEYTEMP1                # INTO BIT1 OF UPLOCK.
                CCS             A                       # IF CODE NOT= ELR, PASS CODE ONLY IF
                TC              TSTUPLOK                # BIT1 OF UPLOCK = 0.
ELRCODE         OCT             22
                TC              TSTUPLOK
                CS              BIT1                    # PUT 0 INTO BIT1 OF UPLOCK
                MASK            UPLOCK
                TS              UPLOCK
                TC              ACCEPTUP
TSTUPLOK        CAF             BIT1
                MASK            UPLOCK
                CCS             A
                TC              RESUME                  # BIT1 OF UPLOCK = 1.
ACCEPTUP        XCH             KEYTEMP1                # BIT1 OF UPLOCK = 0.
                AD              BIT6
                TC              KEYCOM
         
TMFAIL2         TC              RESTORSR                # CODE IS BAD
                CS              BIT1                    # LOCK OUT FURTHER UPLINK ACTIVITY (BY
                MASK            UPLOCK                  # PUTTING 1 INTO BIT1 OF UPLOCK) UNTIL ELR
                AD              BIT1                    # IS SENT UP UPLINK.
                TS              UPLOCK
                CAF             BIT9                    # SEND DOWN INDICATION THAT UPLINK HAS
## Page 133
                AD              BIT11                   # RECEIVED BAD CODE.
                TS              TMKEYBUF
TMFAIL1         TC              TMALM
                TC              RESUME

RESTORSR        XCH             KEYTEMP2
                DOUBLE
                TS              SR
                TC              Q
         
TMALM           =               RESUME                  # FOR NOW

SRGHT5          CS              SR
                CS              SR
                CS              SR
                CS              SR
                CS              SR
                CS              A
                TC              Q                       # DELIVERS WORD UNCOMPLEMENTED
          
UPTEST          AD              KEYTEMP1
                CCS             A
                TC              TMFAIL2
                LOC             +1
                TC              TMFAIL2
                TC              Q

HI10            OCT             77740
UPBANK          EQUALS          EXECBANK                # IN SAME BANK AS EXEC.

B12-1           OCT             3777
                
# UPACT IS TURNED OFF BY VBRELDSP, ALSO BY ERROR LIGHT RESET.       

## Page 134
# THE RECEPTION OF A BAD CODE BY UPLINK LOCKS OUT FURTHER UPLINK ACTIVITY
# BY PLACING A 1 INTO BIT1 OF UPLOCK. BIT9 (ALONG WITH BIT11) OF TMKEYBUF
# IS SET TO 1 TO SEND AN INDICATION OF THIS SITUATION DOWN THE DOWNLINK.
# THE UPLINK INTERLOCK IS ALLOWED WHEN AN ERROR LIGHT RESET CODE IS SENT
# UP THE UPLINK, OR WHEN A FRESH START IS PERFORMED.
