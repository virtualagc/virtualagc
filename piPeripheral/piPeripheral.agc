# Copyright:	Public domain
# Filename:	piPeripheral.agc
# Purpose:	Code for the short tutorial on AGC bare-metal programming
#		from http://www.ibiblio.org/apollo/DIY.html.
# Mod History:	2017-12-07 RSB	Wrote.
#
# Simple AGC program that just toggles COMP ACTY lamp on DSKY whenever a 
# DSKY keycode is received.

# Definitions of various registers,
	    SETLOC    10
ARUPT	    ERASE
	    SETLOC    12
QRUPT	    ERASE
	    SETLOC    26
TIME3	    ERASE

            SETLOC    67
NEWJOB      ERASE                 # Allocate a variable at the location checked by the Night Watchman.
KEYBUF      ERASE                 # 040 when empty, 0-037 when holding a keycode
CASTATUS    ERASE                 # 0 if COMP ACTY off, 2 if on.

            SETLOC    4000        # The interrupt-vector table.

            # Come here at power-up or GOJAM
            INHINT                # Disable interrupts for a moment.
            # Set up the TIME3 interrupt, T3RUPT.  TIME3 is a 15-bit
            # register at address 026, which automatically increments every
            # 10 ms, and a T3RUPT interrupt occurs when the timer
            # overflows.  Thus if it is initially loaded with 037774,
            # and overflows when it hits 040000, then it will
            # interrupt after 40 ms.
            CA        O37774
            TS        TIME3
            TCF       STARTUP     # Go to your "real" code.

            RESUME    # T6RUPT
            NOOP
            NOOP
            NOOP

            RESUME    # T5RUPT
            NOOP
            NOOP
            NOOP

            DXCH      ARUPT        # T3RUPT
            EXTEND                 # Back up A, L, and Q registers
            QXCH      QRUPT
            TCF       T3RUPT

            RESUME    # T4RUPT
            NOOP
            NOOP
            NOOP

            DXCH      ARUPT        # KEYRUPT1
            EXTEND                 # Back up A, L, and Q registers
            QXCH      QRUPT
            TCF       KEYRUPT

            DXCH      ARUPT        # KEYRUPT2
            EXTEND                 # Back up A, L, and Q registers
            QXCH      QRUPT
            TCF       KEYRUPT

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

# The interrupt-service routine for the TIME3 interrupt every 40 ms. 
T3RUPT      CAF     O37774         # Schedule another TIME3 interrupt in 40 ms.
            TS      TIME3

            # And resume the main program
            DXCH    ARUPT          # Restore A, L, and Q, and exit the interrupt
            EXTEND
            QXCH    QRUPT
            RESUME       

# Interrupt-service code for DSKY keycode
KEYRUPT     EXTEND
            READ      15           # Read the DSKY keycode input channel
            MASK      O37          # Get rid of all but lowest 5 bits.
            TS        KEYBUF       # Save the keycode for later.
            CA	      ZERO	   # Clear the input channel.
            EXTEND
            WRITE     15
            DXCH      ARUPT        # Restore A, L, and Q, and exit the interrupt
            EXTEND
            QXCH      QRUPT
            RESUME       

STARTUP     RELINT    # Reenable interrupts.
            # Initialization
            CA        NOKEY         # Clear the keypad buffer variable
            TS        KEYBUF        # to initially hold an illegal keycode.
            CA	      ZERO
            TS	      CASTATUS
            
MAINLOOP    CS	      NEWJOB	    # Tickle the Night Watchman.

            # Occasionally check if there's a keycode ready, and toggle
            # DSKY COMP ACTY if there is.  Presumably this is inside of a
            # loop.
            CA        NOKEY
            EXTEND
            SU        KEYBUF        # Acc will now be zero if no key, non-zero otherwise
            EXTEND
            BZF       MAINLOOP
            CA        NOKEY
            TS        KEYBUF        # Mark keycode buffer as empty.
            CA        CASTATUS      # Toggle COMP ACTY.
            EXTEND
            BZF       CAOFF
            CA        ZERO
            TCF       CATOGGLE
CAOFF       CA        TWO
CATOGGLE    TS	      CASTATUS
	    EXTEND
            WRITE     11            # Write to the DSKY lamps
	    TCF	      MAINLOOP

# Define any constants that are needed.
O37774      OCT     37774
ZERO        OCT       0
TWO         OCT       2
O37         OCT       37            # Mask with lowest 5 bits set.
NOKEY       OCT       40
