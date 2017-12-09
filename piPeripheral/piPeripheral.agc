# Copyright:    Public domain
# Filename:     piPeripheral.agc
# Purpose:      Code for the short tutorial on AGC bare-metal programming
#               from http://www.ibiblio.org/apollo/DIY.html.
# Mod History:  2017-12-07 RSB  Wrote.
#
# It extends the simple template program described in the tutorial (which
# only toggles COMP ACTY whenever a DSKY keycode is detected) by 
# additionally receiving current time&date data in input channels 040-042,
# displaying that data on the DSKY, and spitting the unpacked data back
# out on output channels 043-050.  The input data is:
#	Second		Least-significant 6 bits of channel 040
#	Minute		Next higher 6 bits of channel 040
#			(Most-significant 3 bits of channel 040 unused)
#	Hour		Least-significant 5 bits of channel 041
#	Day		Next higher 5 bits of channel 041
#	Month		Next higher 4 bits of channel 041
#			(Most-significant bit of channel 041 unused)
#	Year		Channel 042.
# The output channels used are:
#	Year		Channel 043
#	Month		Channel 044
#	Day		Channel 045
#	Hour		Channel 046
#	Minute		Channel 047
#	Second		Channel 050
# The piPeripheral.py template for peripheral programs provides and interprets
# this additional data if its --time=1 command-line switch is used.

# Special registers.
A               		EQUALS          0
L               		EQUALS          1               # L AND Q ARE BOTH CHANNELS AND REGISTERS.
Q               		EQUALS          2
EBANK           		EQUALS          3
FBANK           		EQUALS          4
Z               		EQUALS          5               # ADJACENT TO FBANK AND BBANK FOR DXCH Z
BBANK           		EQUALS          6               # (DTCB) AND DXCH FBANK (DTCF).
                                                        	# REGISTER 7 IS A ZERO-SOURCE, USED BY ZL.
ARUPT           		EQUALS          10              # INTERRUPT STORAGE.
LRUPT           		EQUALS          11
QRUPT           		EQUALS          12
SAMPTIME        		EQUALS          13              # SAMPLED TIME 1 & 2.
ZRUPT           		EQUALS          15              # (13 AND 14 ARE SPARES.)
BANKRUPT        		EQUALS          16              # USUALLY HOLDS FBANK OR BBANK.
BRUPT           		EQUALS          17              # RESUME ADDRESS AS WELL.
CYR             		EQUALS          20
SR              		EQUALS          21
CYL             		EQUALS          22
EDOP            		EQUALS          23              # EDITS INTERPRETIVE OPERATION CODE PAIRS.
TIME2           		EQUALS          24
TIME1           		EQUALS          25
TIME3           		EQUALS          26
TIME4           		EQUALS          27
TIME5           		EQUALS          30
TIME6           		EQUALS          31

                                SETLOC          67              
NEWJOB                          ERASE                           # Allocate a variable at the location checked by the Night Watchman.

# More variables.
KEYBUF                          ERASE                           # 040 when empty, 0-037 when holding a keycode
CASTATUS                        ERASE                           # 0 if COMP ACTY off, 2 if on.
LAST040                         ERASE                           # Most recent value from input channel 040.
THIS040                         ERASE                           
SECOND                          ERASE                           # Storage for components of time
MINUTE                          ERASE                           
HOUR                            ERASE                           
DAY                             ERASE                           
MONTH                           ERASE                           
YEAR                            ERASE 
SIGN				ERASE				# For buffering sign+digits in conversion of integer to decimal string.
DIGIT1				ERASE
DIGIT2				ERASE
DIGIT3				ERASE
DIGIT4				ERASE
DIGIT5				ERASE   
DUMMY				ERASE				# Dummy value for computations.
DSPR				ERASE				# Return address for DSPxxxx functions.
DIGIT25				ERASE
DIGIT31				ERASE

                                SETLOC          4000            # The interrupt-vector table.

                                                                # Come here at power-up or GOJAM
                                INHINT                          # Disable interrupts for a moment.
                                                                # Set up the TIME3 interrupt, T3RUPT.  TIME3 is a 15-bit
                                                                # register at address 026, which automatically increments every
                                                                # 10 ms, and a T3RUPT interrupt occurs when the timer
                                                                # overflows.  Thus if it is initially loaded with 037774,
                                                                # and overflows when it hits 040000, then it will
                                                                # interrupt after 40 ms.
                                CA              O37774          
                                TS              TIME3           
                                TCF             STARTUP         # Go to your "real" code.

                                RESUME                          # T6RUPT
                                NOOP                            
                                NOOP                            
                                NOOP                            

                                RESUME                          # T5RUPT
                                NOOP                            
                                NOOP                            
                                NOOP                            

                                DXCH            ARUPT           # T3RUPT
                                EXTEND                          # Back up A, L, and Q registers
                                QXCH            QRUPT           
                                TCF             T3RUPT          

                                RESUME                          # T4RUPT
                                NOOP                            
                                NOOP                            
                                NOOP                            

                                DXCH            ARUPT           # KEYRUPT1
                                EXTEND                          # Back up A, L, and Q registers
                                QXCH            QRUPT           
                                TCF             KEYRUPT         

                                DXCH            ARUPT           # KEYRUPT2
                                EXTEND                          # Back up A, L, and Q registers
                                QXCH            QRUPT           
                                TCF             KEYRUPT         

                                RESUME                          # UPRUPT
                                NOOP                            
                                NOOP                            
                                NOOP                            

                                RESUME                          # DOWNRUPT
                                NOOP                            
                                NOOP                            
                                NOOP                            

                                RESUME                          # RADAR RUPT
                                NOOP                            
                                NOOP                            
                                NOOP                            

                                RESUME                          # RUPT10
                                NOOP                            
                                NOOP                            
                                NOOP                            

# The interrupt-service routine for the TIME3 interrupt every 40 ms. 
T3RUPT                          CAF             O37774          # Schedule another TIME3 interrupt in 40 ms.
                                TS              TIME3           

                                                                # And resume the main program
                                DXCH            ARUPT           # Restore A, L, and Q, and exit the interrupt
                                EXTEND                          
                                QXCH            QRUPT           
                                RESUME                          

# Interrupt-service code for DSKY keycode
KEYRUPT                         EXTEND                          
                                READ            15              # Read the DSKY keycode input channel
                                MASK            O37             # Get rid of all but lowest 5 bits.
                                TS              KEYBUF          # Save the keycode for later.
                                CA              ZERO            # Clear the input channel.
                                EXTEND                          
                                WRITE           15              
                                DXCH            ARUPT           # Restore A, L, and Q, and exit the interrupt
                                EXTEND                          
                                QXCH            QRUPT           
                                RESUME                          

STARTUP                         RELINT                          # Reenable interrupts.
                                                                # Initialization
                                CA              NOKEY           # Clear the keypad buffer variable
                                TS              KEYBUF          # to initially hold an illegal keycode.
                                CA              ZERO            
                                TS              CASTATUS        

                                EXTEND                          
                                READ            40              
                                TS              LAST040         
MAINLOOP                        CS              NEWJOB          # Tickle the Night Watchman.

                                                                #----------------------------------------------------------------------
                                                                # Occasionally check if there's a keycode ready, and toggle
                                                                # DSKY COMP ACTY if there is.
                                CA              NOKEY           
                                EXTEND                          
                                SU              KEYBUF          # Acc will now be zero if no key, non-zero otherwise
                                EXTEND                          
                                BZF             ENDKYCK   	# No key, so just jump ahead to the end of this code block.
                                      
                                CA              NOKEY           
                                TS              KEYBUF          # Mark keycode buffer as empty.
                                CA              CASTATUS        # Toggle COMP ACTY.
                                EXTEND                          
                                BZF             CAOFF           
                                CA              ZERO            
                                TCF             CATOGGLE        
CAOFF                           CA              TWO             
CATOGGLE                        TS              CASTATUS        
                                EXTEND                          
                                WRITE           11              # Write to the DSKY lamps
ENDKYCK                         NOOP                            

                                                                #----------------------------------------------------------------------
                                                                # Occasionally check input channel 040 to see if the time (presumably
                                                                # being reported from time to time by piPeripheral.py) has changed.
                                EXTEND                          
                                READ            40              # Get minutes/seconds
                                TS              THIS040         
                                EXTEND                          
                                SU              LAST040         # Acc will now be zero if time not changed, non-zero otherwise
                                EXTEND                          
                                BZF             ENDTMCK         # Unchanged, so just jump ahead to the end of this code block.
                                
                                                                # We now know that the time has changed.  Unpack the time
                                                                # data to get and save year/month/day/hour/minute/second. 
                                                                # Division is tricky.  The dividend is double precision (2 words)
                                                                # and the divisor is single-precision (1 word).  Put the MSW 
                                                                # of the dividend (in our case always 0) in A and the LSW
                                                                # into L.  The divisor must be in the 12-bit address space, so
                                                                # it has to be in erasable memory.
                                CA              THIS040         
                                TS              LAST040
				TS		L		# Minutes,seconds are quotient,remainder of (channel 040)/64.
				CA		D64
				TS		DUMMY
				CA		ZERO
				EXTEND
				DV		DUMMY
				TS		MINUTE
				CA		L
				TS		SECOND      
                                EXTEND                          
                                READ            41              # Get months,days,hours from (channel 041).
                                TS		L
                                CA		D1024
                                TS		DUMMY
                                CA		ZERO
                                EXTEND
                                DV		DUMMY		# A is now months and L is days,hours
                                TS		MONTH
                                CA		D32
                                TS		DUMMY
                                CA		ZERO
                                EXTEND
                                DV		DUMMY
                                TS		DAY
                                CA		L
                                TS		HOUR
                                EXTEND                          
                                READ            42              # Get year
                                TS              YEAR         

								# Now display date&time on DSKY.  Also, at least for 
								# testing purposes, spit it back on output
								# channels 043-050.
				CA		YEAR
				EXTEND		
				WRITE		43
				TCR		DSPR3		# Display those digits.
				CA		MONTH
				EXTEND
				WRITE		44
				TCR		DSPR2
				CA		DAY
				EXTEND
				WRITE		45
				TCR		DSPR1
				CA		HOUR
				EXTEND
				WRITE		46
				TCR		DSPPROG
				CA		MINUTE
				EXTEND
				WRITE		47
				TCR		DSPVERB
				CA		SECOND
				EXTEND
				WRITE		50
				TCR		DSPNOUN
				
ENDTMCK                         NOOP                            

                                TCF             MAINLOOP        
# This ends the main loop, which continues forever, so we can put other functions
# below this point.

# Convert an integer in the accumulator to SIGN/DIGIT1/.../DIGIT5.  At the end, all 5 DIGITx
# variables will have values from 0-9, and SIGN will be 0 for + or 1 for -.
CONV10				TS		L		# Save the argument
				EXTEND
				BZF		CONV10Z		# Argument is 0.
				EXTEND
				BZMF		CONV10M		# Argument is negative, we'll need to invert
CONV10Z				CA		ZERO		# Record the sign as positive (0 -> SIGN).
				TS		SIGN
CONV10P				CA		TEN		# Prepare for lots of dividing by 10.	
				TS		DUMMY		# The remainders will be the DIGITx.
				CA		ZERO		# Note that L still contains the original argument.
				EXTEND	
				DV		DUMMY
				LXCH		A		# Save remainder as digit 5 and put quotient into L.
				TS		DIGIT5
				CA		ZERO
				EXTEND	
				DV		DUMMY
				LXCH		A
				TS		DIGIT4
				CA		ZERO
				EXTEND	
				DV		DUMMY
				LXCH		A
				TS		DIGIT3
				CA		ZERO
				EXTEND	
				DV		DUMMY
				LXCH		A
				TS		DIGIT2
				CA		ZERO
				EXTEND	
				DV		DUMMY
				LXCH		A
				TS		DIGIT1
				RETURN
# The argument was negative.  Must invert.
CONV10M				CA		ONE		# Record the sign as negative (1 -> SIGN).
				TS		SIGN
				CA		L		# Invert the argument to make it positive.
				COM
				TS		L
				TCF		CONV10P		# Go back to the processing for positive numbers.

# Packs two digits previously formed by CONV10 into a suitable
# form for output.  The channel 10 opcode has to be added in afterward.
# Suitable for PROG, VERB, and NOUN areas.  Result returned in A.
PACK2DIG			CA		DIGIT4
				INDEX		A
				CA		DIGPATTS
				TS		DIGIT4
				CA		DIGIT5
				INDEX		A
				CA		DIGPATTS
				TS		DIGIT5
				CA		D32		# Prepare for shifting by 5 places.
				TS		DUMMY
				CA		DIGIT4
				EXTEND
				MP		DUMMY
				CA		DIGIT5
				AD		L
				RETURN				

# Convert DIGIT1 ... DIGIT5 to their DSKY patterns.
PATT5DIG			CA		DIGIT1
				INDEX		A
				CA		DIGPATTS
				TS		DIGIT1
				CA		DIGIT2
				INDEX		A
				CA		DIGPATTS
				TS		DIGIT2
				CA		DIGIT3
				INDEX		A
				CA		DIGPATTS
				TS		DIGIT3
				CA		DIGIT4
				INDEX		A
				CA		DIGPATTS
				TS		DIGIT4
				CA		DIGIT5
				INDEX		A
				CA		DIGPATTS
				TS		DIGIT5
				RETURN
				
# Display the number in the accumulator as decimal in DSKY PROG
DSPPROG				EXTEND
				QXCH		DSPR
				TCR		CONV10
				TCR		PACK2DIG
				AD		OPCODEP
				EXTEND 
				WRITE		10
				EXTEND
				QXCH		DSPR
				RETURN

# Display the number in the accumulator as decimal in DSKY VERB
DSPVERB				EXTEND
				QXCH		DSPR
				TCR		CONV10
				TCR		PACK2DIG
				AD		OPCODEV
				EXTEND 
				WRITE		10
				EXTEND
				QXCH		DSPR
				RETURN

# Display the number in the accumulator as decimal in DSKY NOUN
DSPNOUN				EXTEND
				QXCH		DSPR
				TCR		CONV10
				TCR		PACK2DIG
				AD		OPCODEN
				EXTEND 
				WRITE		10
				EXTEND
				QXCH		DSPR
				RETURN

# Display the number in the accumulator as decimal in DSKY R1.  Ignore SIGN for now.
DSPR1				EXTEND
				QXCH		DSPR
				TCR		CONV10
				TCR		PATT5DIG
				#CA		DIGIT1		# First write DIGIT1
				CA		ZERO		# blank
				AD		OPCODR11
				EXTEND
				WRITE		10
				CA		D32
				TS		DUMMY
				#CA		DIGIT2		# Next, DIGIT2 and DIGIT3
				CA		ZERO		# blank
				EXTEND
				MP		DUMMY
				#CA		DIGIT3
				CA		ZERO		# blank
				AD		L
				AD		OPCDR123
				EXTEND
				WRITE		10
				CA		DIGIT4		# And finally, DIGIT4 and DIGIT5
				EXTEND
				MP		DUMMY
				CA		DIGIT5
				AD		L
				AD		OPCDR145
				EXTEND
				WRITE		10
				EXTEND
				QXCH		DSPR
				RETURN

# Display the number in the accumulator as decimal in DSKY R2
DSPR2				EXTEND
				QXCH		DSPR
				TCR		CONV10
				TCR		PATT5DIG
				CA		DIGIT5		# Save DIGIT5 for DSPR3 routine.
				TS		DIGIT25
				CA		D32
				TS		DUMMY
				#CA		DIGIT1		# First, DIGIT1 and DIGIT2
				CA		ZERO		# blank
				EXTEND
				MP		DUMMY
				#CA		DIGIT2
				CA		ZERO		# blank
				AD		L
				AD		OPCDR212
				EXTEND
				WRITE		10
				#CA		DIGIT3		# Next, DIGIT3 and DIGIT4
				CA		ZERO		# blank
				EXTEND
				MP		DUMMY
				CA		DIGIT4
				AD		L
				AD		OPCDR234
				EXTEND
				WRITE		10
				CA		DIGIT5		# Finally, DIGIT5 (and R3 DIGIT1)
				EXTEND
				MP		DUMMY
				#CA		DIGIT31
				CA		ZERO		# blank
				AD		L
				AD		OPR25R31
				EXTEND
				WRITE		10
				EXTEND
				QXCH		DSPR
				RETURN

# Display the number in the accumulator as decimal in DSKY R3
DSPR3				EXTEND
				QXCH		DSPR
				TCR		CONV10
				TCR		PATT5DIG
				CA		DIGIT1		# Save DIGIT1 for DSPR2 routine.
				TS		DIGIT31
				CA		D32
				TS		DUMMY
				CA		DIGIT25		# First, (R2 DIGIT5 and) DIGIT1
				EXTEND
				MP		DUMMY
				#CA		DIGIT1
				CA		ZERO		# Blank
				AD		L
				AD		OPR25R31
				EXTEND
				WRITE		10
				CA		DIGIT2		# Next, DIGIT2 and DIGIT3
				EXTEND
				MP		DUMMY
				CA		DIGIT3
				AD		L
				AD		OPCDR323
				EXTEND
				WRITE		10
				CA		DIGIT4		# And finally, DIGIT4 and DIGIT5
				EXTEND
				MP		DUMMY
				CA		DIGIT5
				AD		L
				AD		OPCDR345
				EXTEND
				WRITE		10
				EXTEND
				QXCH		DSPR
				RETURN

# Define any constants that are needed.
O37774                          OCT             37774           
ZERO                            OCT             0  
ONE				OCT		1             
TWO                             OCT             2               
FOUR                            OCT             4   
TEN				DEC		10            
O37                             OCT             37              # Mask with lowest 5 bits set.
O77                             OCT             77              # Mask with lowest 6 bits set.
NOKEY                           OCT             40      
D32				DEC		32
D64				DEC		64        
D1024				DEC		1024
OPCODEP				DEC		11 B11
OPCODEV				DEC		10 B11
OPCODEN				DEC		9 B11
OPCODR11			DEC		8 B11
OPCDR123			DEC		7 B11
OPCDR145			DEC		6 B11
OPCDR212			DEC		5 B11
OPCDR234			DEC		4 B11
OPR25R31			DEC		3 B11
OPCDR323			DEC		2 B11
OPCDR345			DEC		1 B11		
# DSKY digit patterns for the digit 0-9.
DIGPATTS			DEC		21
				DEC		3
				DEC		25
				DEC		27
				DEC		15
				DEC		30
				DEC		28
				DEC		19
				DEC		29
				DEC		31				


