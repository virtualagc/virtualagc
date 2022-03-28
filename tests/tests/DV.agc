# Special registers.
A                               EQUALS          0
L                               EQUALS          1               # L AND Q ARE BOTH CHANNELS AND REGISTERS.
Q                               EQUALS          2
EBANK                           EQUALS          3
FBANK                           EQUALS          4

BBANK                           EQUALS          5               # (DTCB) AND DXCH FBANK (DTCF).
                                                                # REGISTER 7 IS A ZERO-SOURCE, USED BY ZL.
CYR                             EQUALS          6
SR                              EQUALS          7
CYL                             EQUALS          8
TIME1                           EQUALS          9
TIME2                           EQUALS          10

TWOR                            EQUALS          50
EIGHTR                          EQUALS          51
MINUS1R                         EQUALS          52
THREER                          EQUALS          53

                                SETLOC          67
NEWJOB                          ERASE                           # Allocate a variable at the location checked by the Night Watchman.
# More variables.
KEYBUF                          ERASE                           # 040 when empty, 0-037 when holding a keycode
LAST040                         ERASE                           # Most recent value from input channel 040.
SECOND                          ERASE                           # Storage for components of time
MINUTE                          ERASE
HOUR                            ERASE
DAY                             ERASE
MONTH                           ERASE
YEAR                            ERASE
SIGN                            ERASE                           # For buffering sign+digits in conversion of integer to decimal string.
DIGIT1                          ERASE
DIGIT2                          ERASE
DIGIT3                          ERASE
DIGIT4                          ERASE
DIGIT5                          ERASE
SIGNA                           ERASE                           # For buffering sign+digits in conversion of integer to decimal string.
DIGIT1A                         ERASE
DIGIT2A                         ERASE
DIGIT3A                         ERASE
DIGIT4A                         ERASE
DIGIT5A                         ERASE
DSPR                            ERASE                           # Return address for DSPxxxx functions.
DIGIT25                         ERASE
DIGIT31                         ERASE
DIVISOR                         ERASE                           # A dummy variable used to store divisors.
DSPMODE                         ERASE                           # display-mode: 0 time, 1 acceleration, 2 magnetometer, etc.
LLLOW                           ERASE                           # LS word of lat or lon
LLHIGH                          ERASE                           # MS word of lat or lon.
LLRET                           ERASE                           # Return address for LL2.
                                SETLOC          4000            # The interrupt-vector table.
                                                                # Come here at power-up or GOJAM
                                # Come here at power-up or GOJAM
                                INHINT                # Disable interrupts for a moment.
                                TCF       STARTUP     # Go to your "real" code.
                                NOOP
                                NOOP

                                RESUME    # T6RUPT
                                NOOP
                                NOOP
                                NOOP

                                NOOP      # T5RUPT
                                NOOP
                                NOOP
                                NOOP

                                NOOP      # T3RUPT
                                NOOP
                                NOOP
                                NOOP

                                RESUME    # T4RUPT
                                NOOP
                                NOOP
                                NOOP

                                RESUME    # KEYRUPT1
                                NOOP
                                NOOP
                                NOOP

                                RESUME    # KEYRUPT2
                                NOOP
                                NOOP
                                NOOP

                                RESUME    # UPRUPT
                                NOOP
                                NOOP
                                NOOP

                                RESUME    # DOWNRUPT
                                NOOP
                                NOOP
                                NOOP

                                RESUME    # RADAR RUPT
                                NOOP
                                NOOP
                                NOOP

                                RESUME    # RUPT10
                                NOOP
                                NOOP
                                NOOP


STARTUP                         CA   TWO
                                TS   TWOR
                                CA   EIGHT
                                TS   EIGHTR
                                CA   THREE
                                TS   THREER
                                CA   MINUS1
                                TS   MINUS1R
                                CA   ZERO 
                                EXTEND
                                DV   TWOR
                                LXCH   EIGHTR
                                EXTEND
                                DV   TWOR
                                LXCH   A 
                                EXTEND
                                DV   THREER
                                CA   ONE
                                LXCH A
                                CA   ZERO
                                EXTEND
                                DV   MINUS1R
                                EXTEND
                                DCA  50
                                

#stored constants
ZERO                            OCT  0
ONE                             OCT  1
TWO                             OCT  2
THREE                           OCT  3
EIGHT                           DEC  8
MINUS1                          DEC  -1
