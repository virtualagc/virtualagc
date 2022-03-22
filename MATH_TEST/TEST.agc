## AGC Math Test - Jae Choi 2022
$ERASABLE_ASSIGNMENTS.agc

                SETLOC          6000

DPOSMAX         OCT             37777
POSMAX          OCT             37777
LIMITS          EQUALS          POSMAX          +1
NEG1/2          OCT             -20000                  # MUST BE TWO LOCATIONS AHEAD OF POS1/2.

BIT15           OCT             40000                   # BIT TABLE FOLLOWS.
BIT14           OCT             20000
BIT13           OCT             10000
BIT12           OCT             04000
BIT11           OCT             02000
BIT10           OCT             01000
BIT9            OCT             00400
BIT8            OCT             00200
BIT7            OCT             00100
BIT6            OCT             00040
BIT5            OCT             00020
BIT4            OCT             00010
BIT3            OCT             00004
BIT2            OCT             00002
BIT1            OCT             00001

NEGMAX          EQUALS          BIT15
HALF            EQUALS          BIT14
POS1/2          EQUALS          HALF
QUARTER         EQUALS          BIT13
2K              EQUALS          BIT11
ELEVEN          DEC             11
NOUTCON         =               ELEVEN
TEN             DEC             10
NINE            DEC             9
EIGHT           EQUALS          BIT4
SEVEN           OCT             7
SIX             OCT             6
FIVE            OCT             5
FOUR            EQUALS          BIT3
THREE           OCT             3
TWO             EQUALS          BIT2
ONE             EQUALS          BIT1
ZERO            OCT             0
NEG0            OCT             77777
NEGONE          DEC             -1

NEG1            =               NEGONE
MINUS1          EQUALS          NEG1
NEG2            OCT             77775
NEG3            DEC             -3
LOW9            OCT             777
LOW4            OCT             17

## Page 77
LOW3            EQUALS          SEVEN
LOW2            EQUALS          THREE

CALLCODE        OCT             00030
DLOADCOD        OCT             40014
VLOADCOD        EQUALS          BIT15
DLOAD*          OCT             40015
VLOAD*          EQUALS          40001
BIT13-14        OCTAL           30000


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


STARTUP                         NOOP
CALCSIN                         CA      QUARTER
                                TC      SPSIN
CALCROOT                        CA      HALF
                                TC      SPROOT
LOOP                            NOOP
                                TCF     LOOP

ENDIBNKF                        EQUALS

$SINGLE_PRECISION_SUBROUTINES.agc