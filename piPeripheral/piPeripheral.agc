# Copyright:    Public domain
# Filename:     piPeripheral.agc
# Purpose:      Code for the short tutorial on AGC bare-metal programming
#               from http://www.ibiblio.org/apollo/DIY.html.
# Mod History:  2017-12-07 RSB  Wrote.
#		2017-12-09 RSB	Added displaying the current time and date
#				from input channels 040-042 supplied by the
#				template peripheral program (piPeriperal.py)
#				when it's used with its --time=1 cli switch.
#		2017-12-24 RSB	Added the stuff for supporting --imu and --gps.
#		2017-12-25 RSB	Added higher-resolution lat,lon data.  Deleted
#				the toggling of COMP ACTY on keystroke.  Replaced
#				use of PRO key for cycling through modes with
#				+ (for cycling forward) and - (for cycling 
#				backward).
#
# It extends the simple template program described in the tutorial by 
# receiving and displaying various data on input channels for a fake
# peripheral device defined by the program piPeripheral.py, and 
# sometimes spitting the unpacked data back out on similarly-defined
# output channels 043-050.  The input data supported is
# 1's-complement.  Here are the channels, all inputs unless 
# explicitly stated otherwise:
#	Second		Least-significant 6 bits of channel 040
#	Minute		Next higher 6 bits of channel 040
#			(Most-significant 3 bits of channel 040 unused)
#	Hour		Least-significant 5 bits of channel 041
#	Day		Next higher 5 bits of channel 041
#	Month		Next higher 4 bits of channel 041
#			(Most-significant bit of channel 041 unused)
#	Year		Channel 042.
#	Mode or year	Output channel 043.  If the value is <100,
#			it is the current display mode, otherwise the
#			mode is 0 and it is the year.
#	(TBD)		Output channels 044-050 contain data that's
#			dependent on the display mode, but generally
#			reflects what is actually being displayed
#			on the DSKY.  At present, though, it always
#			reflects mode 0 evem for other modes, namely,  
#			044 is the month, 045 is the day, 046 is
#			the hour, 047 is the minute, and 050 is the
#			second.  In other modes, they will be something
#			else. 
#	X acceleration	Channel 051, mm/sec/sec
#	Y acceleration	Channel 052, mm/sec/sec
#	Z acceleration	Channel 053, mm/sec/sec
#	X mag field	Channel 054, in units of 0.0001 gauss
#	Y mag field	Channel 055, in units of 0.0001 gauss
#	Z mag field	Channel 056, in units of 0.0001 gauss
#	X gyro		Channel 057, in units of 0.1 dps
#	Y gyro		Channel 060, in units of 0.1 dps
#	Y gyro		Channel 061, in units of 0.1 dps
#	baro pressure	Channel 062, in units of 0.1 hPa
#	temperature	Channel 063, in units of 0.01 degrees C
#	latitude10	Channel 064. int(latitude*10)
#	longitude10	Channel 065. int(longitude*10)
#	altitude	Channel 066, meters
#	ground speed	Channel 067, kph
#	bearing		Channel 070, 0.1 degrees from true North.
#	latitudeFrac	Channel 071, int(10000*(fractional part of latitude*10))
#	longitudeFrac	Channel 072, int(10000*(fractional part of longitude*10))
# ... though actually, for channels 051-063 & 066-072, the values from the input
# ports are simply displayed (after conversion to decimal) as-is, so
# the their interpretations and units aren't enforced by the AGC. 
# Note that the X, Y, and Z axes mentioned above are relative to
# the sensor board, and I don't know how that relates to DSKY axes.
# On the DSKY, what is displayed depends on the selected 
# display-mode, which you can cycle through with the PRO key.  The
# mode is always shown in the PROG area, and is:
#	00		time-display mode
#	01		acceleration-display mode
#	02		magnetometer-display mode
#	03		gyro-display mode
#	04		weather-sensor-display mode
#	05		GPS-location-display mode
#	06		GPS-track-display mode
#	07		High-res latitude display mode
#	08		High-res longitude display mode
# Specifically, here's what's shown on the display in the 
# various display modes.  For the time-display mode:
#	PROG		00
#	VERB		blank
#	NOUN		seconds
#	R1		hour, minute, separated by a blank
#	R2		month, day, separated by a blank
#	R3		year, prefixed by a blank
# For the acceleration-display mode:
#	PROG		01
#	VERB		blank
#	NOUN		blank
#	R1		X acceleration mm/sec/sec
#	R2		Y acceleration mm/sec/sec
#	R3		Z acceleration mm/sec/sec
# For the magnetometer-display mode:
#	PROG		02
#	VERB		blank
#	NOUN		blank
#	R1		X magnetometer 0.0001 gauss
#	R2		Y magnetometer 0.0001 gauss
#	R3		Z magnetometer 0.0001 gauss
# For the gyro-display mode:
#	PROG		03
#	VERB		blank
#	NOUN		blank
#	R1		X gyro 0.1 dps
#	R2		Y gyro 0.1 dps
#	R3		Z gyro 0.1 dps
# For the weather-sensor-display mode:
#	PROG		04
#	VERB		blank
#	NOUN		blank
#	R1		pressure 0.1 hPa
#	R2		temperature 0.01 degrees C
#	R3		blank
# For the GPS-location-display mode:
#	PROG		05
#	VERB		blank
#	NOUN		blank
#	R1		latitude, XX.XX
#	R2		longitude, XXX.XX
#	R3		altitude, meters
# For the GPS-track-display mode:
#	PROG		06
#	VERB		blank
#	NOUN		blank
#	R1		ground speed, kph
#	R2		direction, 0.1 degrees from true North
#	R3		blank
# For the hi-res-latitude-display mode:
#	PROG		07
#	VERB		blank
#	NOUN		blank
#	R1		latitude, XX
#	R2		latitude, .XXXXX
#	R3		longitude, XXX.XX
# For the hi-res-longitude-display mode:
#	PROG		08
#	VERB		blank
#	NOUN		blank
#	R1		latitude, XX.XXX
#	R2		latitude, XXX
#	R3		longitude, .XXXXX
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
LAST040                         ERASE                           # Most recent value from input channel 040.
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
SIGNA				ERASE				# For buffering sign+digits in conversion of integer to decimal string.
DIGIT1A				ERASE
DIGIT2A				ERASE
DIGIT3A				ERASE
DIGIT4A				ERASE
DIGIT5A				ERASE   
DSPR				ERASE				# Return address for DSPxxxx functions.
DIGIT25				ERASE
DIGIT31				ERASE
DIVISOR				ERASE				# A dummy variable used to store divisors.
DSPMODE				ERASE				# display-mode: 0 time, 1 acceleration, 2 magnetometer, etc.
LLLOW				ERASE				# LS word of lat or lon
LLHIGH				ERASE				# MS word of lat or lon.
LLRET				ERASE				# Return address for LL2.

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
                                TS		DSPMODE		# Display mode. 

				# Prepare the display in mode 0
				TC		BLANKALL	# Completely blank the display
				CA		DSPMODE		# Write the display mode to PROG.
				TC		DSPPROG			

                                EXTEND                          
                                READ            40              
                                TS              LAST040         
MAINLOOP                        CS              NEWJOB          # Tickle the Night Watchman.

                                                                #----------------------------------------------------------------------
                                                                # Check if there's a keycode ready, and process the keycode
                                                                # if there is.
                                CA              NOKEY           
                                XCH             KEYBUF          # Mark keycode buffer as empty and get keycode into A.
                                INDEX		A
                                TCF		KEYTABL
KEYTABL				TCF		ENDKYCK		# unused
				TCF		ENDKYCK		# 1
				TCF		ENDKYCK		# 2
				TCF		ENDKYCK		# 3
				TCF		ENDKYCK		# 4
				TCF		ENDKYCK		# 5
				TCF		ENDKYCK		# 6
				TCF		ENDKYCK		# 7
				TCF		ENDKYCK		# 8
				TCF		ENDKYCK		# 9
                                TCF		ENDKYCK		# unused
                                TCF		ENDKYCK		# unused
                                TCF		ENDKYCK		# unused
                                TCF		ENDKYCK		# unused
                                TCF		ENDKYCK		# unused
                                TCF		ENDKYCK		# unused
                                TCF		ENDKYCK		# 0
                                TCF		ENDKYCK		# VERB
                                TCF		ENDKYCK		# RSET
                                TCF		ENDKYCK		# unused
                                TCF		ENDKYCK		# unused
                                TCF		ENDKYCK		# unused
                                TCF		ENDKYCK		# unused
                                TCF		ENDKYCK		# unused
                                TCF		ENDKYCK		# unused
                                TCF		ENDKYCK		# KEY REL
                                TCF		DSPMODE+	# +
                                TCF		DSPMODE-	# -
                                TCF		ENDKYCK		# ENTR
                                TCF		ENDKYCK		# unused
                                TCF		ENDKYCK		# CLR
                                TCF		ENDKYCK		# NOUN
                                TCF		ENDKYCK		# NOKEY
                                
DSPMODE+			CA		DSPMODE		# Increment display mode.
				AD		ONE
				TS		DSPMODE
				AD		MINUS8		# Check for wraparound
				EXTEND
				BZMF		RETRIG		# No wraparound
				CA		ZERO		# Wraparound to 0.
				TS		DSPMODE  
                                TCF		RETRIG
                                
DSPMODE-			CA		DSPMODE		# Decrement display mode.
				EXTEND				# but pre-check for wraparound.
				BZF		WILLWRAP
				AD		MINUS1
				TS		DSPMODE
				TCF		RETRIG
WILLWRAP			CA		EIGHT
				TS		DSPMODE
				TCF		RETRIG

RETRIG				CA		MINUS1		# Trigger immediate redisplay. 
				TS		LAST040   
				TCR		BLANKALL
				                                
ENDKYCK                         NOOP                            

								#----------------------------------------------------------------------
								# We've now handled the keystrokes, so we need to update the display.
								# However, we only do that when data is changed.  We are guaranteed
								# by our bogus piPeripheral device that all of the input channels we're
								# interested in just change once per second, and that the LAST channel
								# written is 040.  So we only do something when we see that 040 has
								# changed, and we know at that point that we have an entire second
								# to handle our business.
				CA		LAST040
                                EXTEND                          
                                RXOR            40              # XOR last reading of channel 040 with current value.
                                EXTEND
                                BZF		MAINLOOP	# Hasn't changed, so just keep looping.
                                EXTEND
                                READ		40
                                TS		LAST040
                                
                                CA		DSPMODE
                                TCR		DSPPROG
								
								# Okay, input-channel 040 has changed, so all other input channels
								# are ripe for the plucking.  Proceed with displaying.
								# But exactly what we need to do along those lines depends on the 
								# display mode, which we handle with a jump-table.  Note that 
								# 0 <= DSPMODE <= 8.
				INDEX		DSPMODE		# JUMP!
				TCF		MODETABL
MODETABL			TCF		MODE0
				TCF		MODE1
				TCF		MODE2
				TCF		MODE3
				TCF		MODE4
				TCF		MODE5
				TCF		MODE6
				TCF		MODE7
				TCF		MODE8				
								
                                                                #----------------------------------------------------------------------
                                                                # Display-mode 0.
                                
                                                                # We now know that the time has changed.  Unpack the time
                                                                # data to get and save year/month/day/hour/minute/second. 
                                                                # Division is tricky.  The dividend is double precision (2 words)
                                                                # and the divisor is single-precision (1 word).  Put the MSW 
                                                                # of the dividend (in our case always 0) in A and the LSW
                                                                # into L.  Moreover, the divisor must be in erasable memory
                                                                # (and not just that, but the 10 address-bit subset of erasable
                                                                # memory).  
MODE0                           CA              LAST040         
				TS		L		# Minutes,seconds are quotient,remainder of (channel 040)/64.
				CA		D64
				TS		DIVISOR
				CA		ZERO
				EXTEND
				DV		DIVISOR
				TS		MINUTE
				CA		L
				TS		SECOND      
                                EXTEND                          
                                READ            41              # Get months,days,hours from (channel 041).
                                TS		L
                                CA		D1024
                                TS		DIVISOR
                                CA		ZERO
                                EXTEND
                                DV		DIVISOR		# A is now months and L is days,hours
                                TS		MONTH
                                CA		D32
                                TS		DIVISOR
                                CA		ZERO
                                EXTEND
                                DV		DIVISOR
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
				TCR		DSPR3Y		# Display digits for year.
				CA		MONTH
				EXTEND
				WRITE		44
				CA		DAY
				EXTEND
				WRITE		45
				TCR		DSPR2MD		# Display digits for month, day.
				CA		HOUR
				EXTEND
				WRITE		46
				CA		MINUTE
				EXTEND
				WRITE		47
				TCR		DSPR1HM		# Display digits for hour, minute
				CA		SECOND
				EXTEND
				WRITE		50
				TCR		DSPNOUN
				
ENDTMCK                         NOOP                            

                                TCF             MAINLOOP        

                                                                #----------------------------------------------------------------------
                                                                # Display-mode 1.
MODE1 				EXTEND
				READ		051
				TC		DSPR1
				EXTEND
				READ		052
				TC		DSPR2
				EXTEND
				READ		053
				TC		DSPR3
				TCF		MAINLOOP

                                                                #----------------------------------------------------------------------
                                                                # Display-mode 2.
MODE2 				EXTEND
				READ		054
				TC		DSPR1
				EXTEND
				READ		055
				TC		DSPR2
				EXTEND
				READ		056
				TC		DSPR3
				TCF		MAINLOOP

                                                                #----------------------------------------------------------------------
                                                                # Display-mode 3.
MODE3 				EXTEND
				READ		057
				TC		DSPR1
				EXTEND
				READ		060
				TC		DSPR2
				EXTEND
				READ		061
				TC		DSPR3
				TCF		MAINLOOP

                                                                #----------------------------------------------------------------------
                                                                # Display-mode 4.
MODE4 				EXTEND
				READ		062
				TC		DSPR1
				EXTEND
				READ		063
				TC		DSPR2
				TCF		MAINLOOP

                                                                #----------------------------------------------------------------------
                                                                # Display-mode 5.

MODE5				EXTEND				# Process latitude.
				READ		064
				TS		LLHIGH
				EXTEND
				READ		071
				TS		LLLOW
				TCR		LL2
				TCR		DIG2R1		# Display in R1.
				
				EXTEND				# Process longitude.
				READ		065
				TS		LLHIGH
				EXTEND
				READ		072
				TS		LLLOW
				TCR		LL2
				TCR		DIG2R2		# Display in R2.
				
				EXTEND				# Process altitude
				READ		066
				TC		DSPR3
				TCF		MAINLOOP

                                                                #----------------------------------------------------------------------
                                                                # Display-mode 6.
MODE6 				EXTEND
				READ		067
				TC		DSPR1
				EXTEND
				READ		070
				TC		DSPR2
				TCF		MAINLOOP

                                                                #----------------------------------------------------------------------
                                                                # Display-mode 7.
MODE7				EXTEND				# Process latitude.
				READ		064
				TS		LLHIGH
				EXTEND
				READ		071
				TS		LLLOW
				TCR		LL5
				TCR		DIG2R1		# Display in R1.
				TCR		A2DIG
				TCR		DIG2R2
				
				EXTEND				# Process longitude.
				READ		065
				TS		LLHIGH
				EXTEND
				READ		072
				TS		LLLOW
				TCR		LL2
				TCR		DIG2R3		# Display in R2.
				
				TCF		MAINLOOP

                                                                #----------------------------------------------------------------------
                                                                # Display-mode 8.
                                                                
MODE8				EXTEND				# Process latitude.
				READ		064
				TS		LLHIGH
				EXTEND
				READ		071
				TS		LLLOW
				TCR		LL2
				TCR		DIG2R1		# Display in R1.
				
				EXTEND				# Process longitude.
				READ		065
				TS		LLHIGH
				EXTEND
				READ		072
				TS		LLLOW
				TCR		LL5
				TCR		DIG2R2		# Display in R2.
				TCR		A2DIG
				TCR		DIG2R3
				
				TCF		MAINLOOP



#######################################################################################################################################
# This ends the main loop, which continues forever, so we can put other functions
# below this point.

# Blank all of the numerical displays.
BLANKALL 			CA		OPCODEP
				EXTEND
				WRITE		10
				CA		OPCODEV
				EXTEND
				WRITE		10
				CA		OPCODEN
				EXTEND
				WRITE		10
				CA		OPCODR11
				EXTEND
				WRITE		10
				CA		OPCDR123
				EXTEND
				WRITE		10
				CA		OPCDR145
				EXTEND
				WRITE		10
				CA		OPCDR212
				EXTEND
				WRITE		10
				CA		OPCDR234
				EXTEND
				WRITE		10
				CA		OPR25R31
				EXTEND
				WRITE		10
				CA		OPCDR323
				EXTEND
				WRITE		10
				CA		OPCDR345
				EXTEND
				WRITE		10
				CA		ZERO
				TS		DIGIT31
				TS		DIGIT25
				RETURN

# Convert an integer in the accumulator to SIGN/DIGIT1/.../DIGIT5.  At the end, all 5 DIGITx
# variables will have values from 0-9, and SIGN will be 0 for + or 1 for -.  Note: calls no
# other routines.
CONV10				TS		L		# Save the argument
				EXTEND
				BZF		CONV10Z		# Argument is 0.
				EXTEND
				BZMF		CONV10M		# Argument is negative, we'll need to invert
CONV10Z				CA		ZERO		# Record the sign as positive (0 -> SIGN).
				TS		SIGN
CONV10P				CA		TEN
				TS		DIVISOR
				CA		ZERO		# Note that L still contains the original argument.
				EXTEND	
				DV		DIVISOR
				LXCH		A		# Save remainder as digit 5 and put quotient into L.
				TS		DIGIT5
				CA		ZERO
				EXTEND	
				DV		DIVISOR
				LXCH		A
				TS		DIGIT4
				CA		ZERO
				EXTEND	
				DV		DIVISOR
				LXCH		A
				TS		DIGIT3
				CA		ZERO
				EXTEND	
				DV		DIVISOR
				LXCH		A
				TS		DIGIT2
				CA		ZERO
				EXTEND	
				DV		DIVISOR
				LXCH		A
				TS		DIGIT1
				RETURN
				
# Lat an lon are each input on two input channels, a more-significant one containing the integer part of
# the value times 10, and a less-significant on containing the fractional part of the value times 10, times
# 10000.  The LL2 function assumes that those values have been stored in variables called LLHIGH and LLLOW,
# respectively, and create SIGN, DIGIT1, ..., DIGIT5 containing the value in the form +/- XXX.XX.
LL2 				EXTEND
				QXCH		LLRET
				CA		LLLOW		# Process LS word
				TCR		CONV10		# Convert to (SIGN, DIGIT1, ..., DIGIT5)
				TCR		PATT5DIG
				TCR		DIG2A		# Move SIGN/DIGITx to SIGNA/DIGITxA
				CA		LLHIGH		# Process MS word
				TCR		CONV10		# Convert to SIGN/DIGITx
				TCR		PATT5DIG
				CA		DIGIT2		# Rearrange the DIGITx values somewhat. (Multiply by 10.)
				TS		DIGIT1
				CA		DIGIT3
				TS		DIGIT2
				CA		DIGIT4
				TS		DIGIT3
				CA		DIGIT5
				TS		DIGIT4
				CA		DIGIT2A
				TS		DIGIT5
				EXTEND	
				QXCH		LLRET
				RETURN
# Similarly, the LL5 function puts the integral lat or lon in SIGN,DIGITx and 5 decimal places in SIGNA,DIGITxA.
LL5 				EXTEND
				QXCH		LLRET
				CA		LLLOW		# Process LS word
				TCR		CONV10		# Convert to (SIGN, DIGIT1, ..., DIGIT5)
				TCR		PATT5DIG
				TCR		DIG2A		# Move SIGN/DIGITx to SIGNA/DIGITxA
				CA		LLHIGH		# Process MS word
				TCR		CONV10		# Convert to SIGN/DIGITx
				TCR		PATT5DIG
				CA		DIGIT5		# Rearrange the DIGITx values somewhat. (Divide by 10.)
				TS		DIGIT1A
				CA		DIGIT4
				TS		DIGIT5
				CA		DIGIT3
				TS		DIGIT4
				CA		DIGIT2
				TS		DIGIT3
				CA		DIGIT1
				TS		DIGIT2
				EXTEND	
				QXCH		LLRET
				RETURN
                                                                
# Transfer set of SIGN/DIGITx to SIGNA/DIGITxA
DIG2A				CA		SIGN
				TS		SIGNA
				CA		DIGIT1
				TS		DIGIT1A
				CA		DIGIT2
				TS		DIGIT2A
				CA		DIGIT3
				TS		DIGIT3A
				CA		DIGIT4
				TS		DIGIT4A
				CA		DIGIT5
				TS		DIGIT5A
				RETURN
# ... and vice-versa.
A2DIG				CA		SIGNA
				TS		SIGN
				CA		DIGIT1A
				TS		DIGIT1
				CA		DIGIT2A
				TS		DIGIT2
				CA		DIGIT3A
				TS		DIGIT3
				CA		DIGIT4A
				TS		DIGIT4
				CA		DIGIT5A
				TS		DIGIT5
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
# Note: calls no other routines.
PACK2DIG			CA		DIGIT5
				INDEX		A
				CA		DIGPATTS
				TS		DIGIT5
				CA		DIGIT4
				INDEX		A
				CA		DIGPATTS
				TS		DIGIT4
				EXTEND
				MP		D32		# Shift by 5 places.
				CA		DIGIT5
				AD		L
				RETURN				

# Convert DIGIT1 ... DIGIT5 to their DSKY patterns.  Note: calls no other
# routines.
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

# Display the number in the accumulator as decimal in DSKY R1.
DSPR1				EXTEND
				QXCH		DSPR
				TCR		CONV10
				TCR		PATT5DIG
				EXTEND
				QXCH		DSPR
				# Fall through to DIG2R1.

# Display the number in SIGN/DIGITx in DSKY R1
DIG2R1				EXTEND
				QXCH		DSPR
				CA		DIGIT1		# First write DIGIT1
				AD		OPCODR11
				EXTEND
				WRITE		10
				CA		DIGIT2		# Next, DIGIT2 and DIGIT3
				EXTEND
				MP		D32
				CA		DIGIT3
				ADS		L
				CA		OPCDR123
				ADS		L
				CA		SIGN
				EXTEND
				BZF		DSPR1POS
				TCF		DSPR1NPS
DSPR1POS			CA		SIGNBIT
				ADS		L
DSPR1NPS			CA		L
				EXTEND
				WRITE		10
				CA		DIGIT4		# And finally, DIGIT4 and DIGIT5
				EXTEND
				MP		D32
				CA		DIGIT5
				ADS		L
				CA		OPCDR145
				ADS		L
				CA		SIGN
				EXTEND
				BZF		DSPR1NNG
				CA		SIGNBIT
				ADS		L
DSPR1NNG			CA		L
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
				EXTEND
				QXCH		DSPR
				# Fall through to DIG2R2.

# Display the number in SIGN/DIGITx in DSKY R2
DIG2R2				EXTEND
				QXCH		DSPR
				CA		DIGIT5		# Save DIGIT5 for DSPR3 routine.
				TS		DIGIT25
				CA		DIGIT1		# First, DIGIT1 and DIGIT2
				EXTEND
				MP		D32
				CA		DIGIT2
				ADS		L
				CA		OPCDR212
				ADS		L
				CA		SIGN
				EXTEND
				BZF		DSPR2POS
				TCF		DSPR2NPS
DSPR2POS			CA		SIGNBIT
				ADS		L
DSPR2NPS			CA		L
				EXTEND
				WRITE		10
				CA		DIGIT3		# Next, DIGIT3 and DIGIT4
				EXTEND
				MP		D32
				CA		DIGIT4
				ADS		L
				CA		OPCDR234
				ADS		L
				CA		SIGN
				EXTEND
				BZF		DSPR2NNG
				CA		SIGNBIT
				ADS		L
DSPR2NNG			CA		L
				EXTEND
				WRITE		10
				CA		DIGIT5		# Finally, DIGIT5 (and R3 DIGIT1)
				EXTEND
				MP		D32
				CA		DIGIT31
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
				EXTEND
				QXCH		DSPR
				# Fall through to DIG2R3.

# Display the number in SIGN/DIGITx in DSKY R3
DIG2R3				EXTEND
				QXCH		DSPR
				CA		DIGIT1		# Save DIGIT1 for DSPR2 routine.
				TS		DIGIT31
				CA		DIGIT25		# First, (R2 DIGIT5 and) DIGIT1
				EXTEND
				MP		D32
				CA		DIGIT1
				AD		L
				AD		OPR25R31
				EXTEND
				WRITE		10
				CA		DIGIT2		# Next, DIGIT2 and DIGIT3
				EXTEND
				MP		D32
				CA		DIGIT3
				ADS		L
				CA		OPCDR323
				ADS		L
				CA		SIGN
				EXTEND	
				BZF		DSPR3POS
				TCF		DSPR3NPS
DSPR3POS			CA		SIGNBIT
				ADS		L
DSPR3NPS			CA		L					
				EXTEND
				WRITE		10
				CA		DIGIT4		# And finally, DIGIT4 and DIGIT5
				EXTEND
				MP		D32
				CA		DIGIT5
				ADS		L
				CA		OPCDR345
				ADS		L
				CA		SIGN
				EXTEND
				BZF		DSPR3NNG
				CA		SIGNBIT
				ADS		L
DSPR3NNG			CA		L
				EXTEND
				WRITE		10
				EXTEND
				QXCH		DSPR
				RETURN

# Display the number in YEAR as a year in DSKY R3.  (Similar to 
# DSPR3, except no sign bit, and first digit is blank.)
DSPR3Y				EXTEND
				QXCH		DSPR
				CA		YEAR
				TCR		CONV10
				TCR		PATT5DIG
				CA		ZERO		# Save first digit (a blank) for DSPR2 routine.
				TS		DIGIT31
				
				CA		DIGIT25		# First, (R2 DIGIT5 and) DIGIT1 (blank)
				EXTEND
				MP		D32
				CA		ZERO
				AD		L
				AD		OPR25R31
				EXTEND
				WRITE		10
				CA		DIGIT2		# Next, DIGIT2 and DIGIT3
				EXTEND
				MP		D32
				CA		DIGIT3
				AD		L
				AD		OPCDR323
				EXTEND
				WRITE		10
				
				CA		DIGIT4		# And finally, DIGIT4 and DIGIT5
				EXTEND
				MP		D32
				CA		DIGIT5
				AD		L
				AD		OPCDR345
				EXTEND
				WRITE		10
				
				EXTEND
				QXCH		DSPR
				RETURN

# Display the numbers in MONTH and DAY as two 2-digit fields in DSKY R2.
DSPR2MD				EXTEND
				QXCH		DSPR
				
				CA		MONTH
				TCR		CONV10
				TCR		PACK2DIG
				AD		OPCDR212
				EXTEND 
				WRITE		10
				
				CA		DAY
				TCR		CONV10
				CA		DIGIT5
				INDEX		A
				CA		DIGPATTS
				TS		DIGIT5
				CA		DIGIT4
				INDEX		A
				CA		DIGPATTS
				AD		OPCDR234
				EXTEND
				WRITE		10
				
				CA		DIGIT5
				TS		DIGIT25
				EXTEND
				MP		D32
				CA		L
				AD		DIGIT31
				AD		OPR25R31
				EXTEND
				WRITE		10
				
				EXTEND
				QXCH		DSPR
				RETURN

# Display the numbers in HOUR and MINUTE as two 2-digit fields in DSKY R1.
DSPR1HM				EXTEND
				QXCH		DSPR
				
				CA		HOUR
				TCR		CONV10
				
				CA		DIGIT4
				INDEX		A
				CA		DIGPATTS
				AD		OPCODR11
				EXTEND
				WRITE		10
				
				CA		DIGIT5
				INDEX		A
				CA		DIGPATTS
				EXTEND
				MP		D32
				CA		L
				AD		OPCDR123
				EXTEND 
				WRITE		10
				
				CA		MINUTE
				TCR		CONV10
				TCR		PACK2DIG
				AD		OPCDR145
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
EIGHT				DEC		8
MINUS1				DEC		-1 
MINUS8				DEC		-8 
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
SIGNBIT				DEC		1 B10	
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


