# Copyright:	Public domain.
# Filename:	Tic-Tac-Toe.agc
# Purpose:	Tic-Tac-Toe game for the AGC for either one or two players.
#		The numbers 1-9 on the DSKY place moves.
#		The RSET button starts a new game.
#		The +/- buttons add/remove the computer player.
# Assembler:	yaYUL
# Contact:	Lena Ku <lenaku@163.com>
# Contact:	Neil Fraser <agc@neil.fraser.name>

# Interrupts, must have 4 lines per interrupt
	SETLOC	4000

	# Power up
	TCF	START
	NOOP
	NOOP
	NOOP

	# T6 (interrupt #1)
	DXCH	ARUPT	# Back up A,L register
	EXTEND
	QXCH	QRUPT
	TCF	T6RUPT

	# T5 (interrupt #2)
	RESUME
	NOOP
	NOOP
	NOOP

	# T3 (interrupt #3)
	XCH	ARUPT	# Back up A register
	TCF	T3RUPT
	NOOP
	NOOP

	# T4 (interrupt #4)
	RESUME
	NOOP
	NOOP
	NOOP

	# DSKY1 (interrupt #5)
	DXCH	ARUPT	# Back up A,L register
	EXTEND
	QXCH	QRUPT
	TCF	KEYRUPT1

	# DSKY2 (interrupt #6)
	RESUME
	NOOP
	NOOP
	NOOP

	# Uplink (interrupt #7)
	RESUME
	NOOP
	NOOP
	NOOP

	# Downlink (interrupt #8)
	RESUME
	NOOP
	NOOP
	NOOP

	# Radar (interrupt #9)
	RESUME
	NOOP
	NOOP
	NOOP

	# Hand controller (interrupt #10)
	RESUME
	NOOP
	NOOP
	NOOP


# Time3 interrupt every 100 ms.
# No inputs or outputs.
T3RUPT	CAF	T3-100MS	# Schedule another T3RUPT in 100 ms
	TS	TIME3

	CAE	NEWJOB	# Tickle NEWJOB to keep Night Watchman GOJAMs from happening

	XCH	ARUPT	# Restore A, and exit the interrupt
	RESUME


# Time6 interrupt.  Every second when blinking a winner.  One second single call on OPP-ERR.
# No inputs or outputs.
T6RUPT	CA	OPR-ERR	# Turn off OPR-ERR lamp (even if its not on...)
	COM
	EXTEND
	WAND	LAMP163
	CA	TURN	# Check if Game Over
	EXTEND
	BZF	T6WIN	# Game Over, blink
	CA	MANTURN
	EXTEND
	BZF	T6CPU
	TCF	T6DONE

T6WIN	TCR	DRAW	# Not drawing right after THINK, so draw here
	CA	DOBLINK	# Check if need to reset +/- 1s to +/- 2s
	EXTEND
	BZF	T6UNDO	# Change win val back to 2
	TCR	THINK
	TCF	T6DONE

T6UNDO	EXTEND
	AUG	DOBLINK	# Set DOBLINK to 1
	CAF	T6-1SEC	# Schedule T6RUPT in 1 second to restore the blinked win cells
	TS	TIME6
	CA	T6START
	EXTEND
	WOR	IO-13
	CA	NINE	# Change win val back to 2
	TS	L

T6LOOP	INDEX	L
	CA	BOARD
	EXTEND
	BZF	T6NEXT
	EXTEND
	DIM	A	# Not DIM BOARD, cuz that changes BOARD val
	EXTEND
	BZF	T6AUG
	TCF	T6NEXT

T6AUG	EXTEND
	INDEX	L
	AUG	BOARD	# Increment value
T6NEXT	EXTEND
	DIM	L
	CA	L
	EXTEND
	BZF	T6DONE
	TCF	T6LOOP

T6CPU	TCR	CPUPLAY
	TCR	COMPOFF
	TCF	T6DONE

T6DONE	DXCH	ARUPT	# Restore registers
	EXTEND
	QXCH	QRUPT
	RESUME


# Main program start.  Initializes, then idle loops.
START	CA	T3-100MS	# T3RUPT in 100 ms to tickle night watchman
	TS	TIME3
	CAE	ZEROREG	# Disable all lamps (io channel 0163)
	EXTEND
	WRITE	LAMP163	################################ #TODO# WOR or so
	CA	TRUE	# Set CPUPYR to 1
	TS	CPUPYR
	TCR	PROGLAMP	# Update DSKY PROG lamp
	CA	PLAYERX
	TS	STARTPYR
	TCR	GAMEINI	# Clear BOARD values

	CA	ZEROREG	# Initialize RAND9 to zero
	TS	RAND9
IDLELOOP	CCS	RAND9	# CCS instead of BZF, fewer steps
	TCF	RNDSTOR1	# RAND9 > 0 (A = RAND9-1)
	CAF	EIGHT	# RAND9 = 0, make it 8 again
RNDSTOR1	TS	RAND9
	TCF	IDLELOOP	# Loop again (wrapping around to 8 after 0)


# Function to initialize a new game.
# No inputs or outputs.
GAMEINI	CA	Q	# Save return pointer, cuz of TCRs
	TS	QGAMEINI
	CA	STARTPYR	# Starting player
	TS	TURN
	COM		# Toggle the starting player for the next game.
	TS	STARTPYR
	TCR	CLEAR	# Clear board values
	CA 	NINE	# Reset the countdown of moves.
	TS	CNTDOWN

	CA	CPUPYR	# No CPU player means 2 person game.
	EXTEND
	BZF	INIHUMAN
	CA	TURN	# If current Turn is 'O' (-2), CPU starts.
	COM
	EXTEND
	BZMF	INIHUMAN
	CA	ZEROREG
	TCF	INISAVE
INIHUMAN	CA	TRUE	# Humans first! (TM)
INISAVE	TS	MANTURN
	EXTEND
	BZF	INICPU

INIDRAW	TCR	DRAW
	CA	QGAMEINI	# Restore Q
	TS	Q
	RETURN

INICPU	TCR	CPUPLAY
	TCF	INIDRAW


# Function to set all cells to 0.
# No inputs or outputs.
CLEAR	CA	ZEROREG	# Using loop takes 2 more instructions
	TS	BOARD1
	TS	BOARD2
	TS	BOARD3
	TS	BOARD4
	TS	BOARD5
	TS	BOARD6
	TS	BOARD7
	TS	BOARD8
	TS	BOARD9
	RETURN


# Function to convert cell value (2,1,0,-1,-2) into DSKY code for '1', '0', or ' '.
# Input: A is cell value.  Output: A is DSKY code.
CELLVAL	CCS	A
	TCF	CELLX	# +2 (X) or +1 if blinking
	TCF	CELL-	# +0 ( )
	TCF	CELLO	# -2 (O) or -1 if blinking
	TCF	CELL-	# -0 (N/A)

CELLX	EXTEND
	BZF	CELL-	# Blinking, draw blank
	CA	DISPLAYX
	RETURN		# Draw X ('1')

CELLO	EXTEND
	BZF	CELL-	# Blinking, draw blank
	CA	DISPLAYO
	RETURN		# Draw O ('0')

CELL-	CA	DISPLAY-	# Draw blank
	RETURN


# Function to draw the entire board on the DSKY, including the player number as the Prog.
# No inputs or outputs.
DRAW	CA	Q	# Save return pointer, cuz of TCRs
	TS	QDRAW
	# Pair 11 PROG to indicate whos turn it is #TODO# COMP ACTY if computers turn
	CA	TURN
	TCR	CELLVAL
	AD	PAIR11
	EXTEND
	WRITE	DSPL10
	# Pair 8 has digit 11 (board position 7)
	CA	BOARD7
	TCR	CELLVAL
	AD	PAIR8
	EXTEND
	WRITE	DSPL10
	# Pair 7 has digit 13 (board position 8)
	CA	BOARD8
	TCR	CELLVAL
	AD	PAIR7
	EXTEND
	WRITE	DSPL10
	# Pair 6 has digit 15 (board position 9)
	CA	BOARD9
	TCR	CELLVAL
	AD	PAIR6
	EXTEND
	WRITE	DSPL10
	# Pair 5 has digit 21 (board position 4)
	CA	BOARD4
	TCR	CELLVAL
	EXTEND
	MP	CSHIFT	# Shift for CCCCC Position (*32)
	XCH	L	# MP Val gets stored in L
	AD	PAIR5
	EXTEND
	WRITE	DSPL10
	# Pair 4 has digit 23 (board position 5)
	CA	BOARD5
	TCR	CELLVAL
	EXTEND
	MP	CSHIFT	# Shift for CCCCC Position (*32)
	XCH	L	# MP Val gets stored in L
	AD	PAIR4
	EXTEND
	WRITE	DSPL10
	# Pair 3 has digit 25 and 31 (board positions 6 and 1)
	CA	BOARD6
	TCR	CELLVAL
	EXTEND		# Shift for CCCCC Position (*32)
	MP	CSHIFT	# MP Val gets stored in L
	CA	BOARD1
	TCR	CELLVAL
	AD	L
	AD	PAIR3
	EXTEND
	WRITE	DSPL10
	# Pair 2 has digit 33 (board position 2)
	CA	BOARD2
	TCR	CELLVAL
	AD	PAIR2
	EXTEND
	WRITE	DSPL10
	# Pair 1 has digit 35 (board position 3)
	CA	BOARD3
	TCR	CELLVAL
	AD	PAIR1
	EXTEND
	WRITE	DSPL10
	CA	QDRAW	# Restore Q
	TS	Q
	RETURN


# Function to turn on or off the Prog lamp, controlled by 'CPUPYR'
# No inputs or outputs.
PROGLAMP	CA	CPUPYR
	EXTEND
	BZF	LAMPOFF
	CA	PAIR12
	AD	PROGBIT
	TCF	LAMPSEND
LAMPOFF	CA	PAIR12
LAMPSEND	EXTEND
	WRITE	DSPL10
	RETURN


# Interrupt called when button pushed.  Handle the keystroke.
# No inputs or outputs.
KEYRUPT1	CA	NINE
	TS	Q
	CA	EIGHT
	TS	CALC
	EXTEND
	READ	KEY15	# Read DSKY keystrokes (io channel 015)
	TS	L
	EXTEND		# Subtract 9.  Check if btn is 1-9
	SU	Q
	EXTEND
	BZMF	BTN1-9
	EXTEND		# Subtract 9.  Check if is 18 (RSET btn)
	SU	Q
	EXTEND
	BZF	BTNRSET
	EXTEND		# Subtract 8.  Check if is 26 (+ btn)
	SU	CALC
	EXTEND
	BZF	BTN1PL
	AD	EIGHT	# Subtract 1 (+8,-9).  Check if is 27 (- btn)
	EXTEND
	SU	Q
	EXTEND
	BZF	BTN2PL
	TCF	B-ERROR

BTNRSET	TCR	GAMEINI
	TCF	B-END

BTN2PL	CA	ZEROREG
	TS	CPUPYR	# Set to Zero, no CPU player
	TCR	PROGLAMP	# DSKY PROG light
	TCF	B-END

BTN1PL	CA	TRUE	# Set CPUPYR to 1
	TS	CPUPYR
	TCR	PROGLAMP	# DSKY PROG light
	TCF	B-END

BTN1-9	INDEX	L
	CA	BOARD
	EXTEND
	BZF	BTN-FREE	# Check if btn is available (free cell)
	TCF	B-ERROR

BTN-FREE	CA	TURN
	EXTEND
	BZF	B-ERROR	# Game was already over
	CA	MANTURN
	EXTEND
	BZF	B-ERROR	# Keyboard locked due to pending CPU move.
	TCR	PLAYHERE	# Play Human's move
	CA	CPUPYR # If a 2 player game, skip the CPU player.
	EXTEND
	BZF	B-END

	CA	TURN
	EXTEND
	BZF	B-END	# Game over after human played
	CA	ZEROREG
	TS	MANTURN
	TCR	COMPON
	TCR	CALLT6

B-END	DXCH	ARUPT	# Restore registers
	EXTEND
	QXCH	QRUPT
	RESUME

B-ERROR	CA	OPR-ERR	# Turn on OPR-ERR lamp
	EXTEND
	WOR	LAMP163
	TCR	CALLT6
	TCF	B-END


# Function to schedule T6RUPT in 1 second.
# No inputs or outputs.
CALLT6	CAF	T6-1SEC
	TS	TIME6
	CA	T6START
	EXTEND
	WOR	IO-13
	RETURN

# Function to turn COMP ACTY light on or off
# No inputs or outputs.
COMPON	CA	COMPBIT
	EXTEND
	WOR	IO-11
	RETURN

COMPOFF	CA	COMPBIT
	COM
	EXTEND
	WAND	IO-11
	RETURN


# Function to play in a cell.
# Input: L is the cell number to play.  No outputs.
PLAYHERE	CA	Q	# Save return pointer, cuz of TCRs
	TS	QPLYHERE
	CA	TURN
	INDEX	L
	TS	BOARD
	COM		# Flip TURN value (+ <-> -), here bc after updating BOARD val &
	TS	TURN	# before drawing board so VERB can show whose turn it is
	EXTEND		# Decrement the number of remaining moves.
	DIM	CNTDOWN
	TCR	DRAW
	TCR	THINK	# Analyze board & check win (not AI)
	CA	QPLYHERE	# Restore Q
	TS	Q
	RETURN


# Function to check for winning condition.  Ends game if needed.
# No inputs or outputs.
THINK			# For each of the eight possible lines,
			# add up the values of the three cells on that line.
			# If the sum is 6, then X has three in that line.
			#  2 +  2 +  2 =  6
			# If the sum is -6, then O has three in that line.
			# -2 + -2 + -2 = -6
	CA	Q	# Save return pointer, cuz of TCRs
	TS	QTHINK
	CA	EIGHT
	TS	L	# L is the line counter (7 -> 0).
T-LOOP	EXTEND
	DIM	L
	INDEX	L	# Add up the values of each line on the board
	CA	CHECK1
	INDEX	A
	CA	BOARD
	TS	CALC	# CALC is a local summing location
	INDEX	L
	CA	CHECK2
	INDEX	A
	CA	BOARD
	AD	CALC
	TS	CALC
	INDEX	L
	CA	CHECK3
	INDEX	A
	CA	BOARD
	AD	CALC
	EXTEND		# Take absolute negative value
	BZMF	T-NEG
	COM
T-NEG	AD	FIVE	# Compare with 5 (not 6) since one cell might intersect with another winning line.
	EXTEND
	BZMF	T-WIN	# Found a win
T-NEXT	CA	L
	EXTEND
	BZF	T-NOLOOP	# Checked all options
	TCF	T-LOOP
T-NOLOOP	CA	CNTDOWN
	EXTEND
	BZF	T-FULL
T-DONE	CA	ZEROREG
	TS	DOBLINK
	CA	QTHINK	# Restore Q
	TS	Q
	RETURN

T-FULL	TCR	T-OVER	# The board is completely full (tie or win)
	TCF	T-DONE

T-WIN	TCR	T-OVER	# A player has won, modify current line to blink
	INDEX	L
	CA	CHECK1
	TCR	T-MOD
	INDEX	L
	CA	CHECK2
	TCR	T-MOD
	INDEX	L
	CA	CHECK3
	TCR	T-MOD
	CAF	T6-1SEC	# Schedule T6RUPT in 1 second to blink off win cells
	TS	TIME6
	CA	T6START
	EXTEND
	WOR	IO-13
	TCF	T-NEXT

T-OVER	CA	ZEROREG	# Set TURN for Game Over
	TS	TURN
	CA	DISPLAY-	# Blank the Prog turn display
	AD	PAIR11
	EXTEND
	WRITE	DSPL10
	RETURN


# Function to modify a cell to blink if not blank.
# Input: A is cell index.  No outputs.
T-MOD	TS	CALC	# For the cell specified in A, signal it to blink if not blank.
			# Thus change 2 -> 1, -2 -> -1, but leave 0 alone.
	INDEX	A
	CA	BOARD
	EXTEND
	DIM	A
	EXTEND
	BZF	T-MODEND
	INDEX	CALC
	TS	BOARD	# Set BOARD to blink (-1/1)
T-MODEND	RETURN


# Function to compute the CPU player's move.
# No inputs or outputs.
CPUPLAY	CA	TURN	# Bail if game is over
	EXTEND
	BZF	CPUOVER
	CA	Q	# Save return pointer, cuz of TCRs
	TS	QCPUPLAY
	CA	TURN	# Strategy 1: Search for winning hole.
	TCR	SEARCH
	EXTEND
	BZF	PLAYBLOK
	TCF	PLAYSPOT
PLAYBLOK	CA	TURN
	COM		# Strategy 2: Search for blocking hole.
	TCR	SEARCH
	EXTEND
	BZF	PLAYRAND
	TCF	PLAYSPOT

PLAYRAND	INDEX	RAND9	# Strategy 3: Out of good ideas, just play randomly.
	CA	BOARD1
	EXTEND
	BZF	PLAYFREE	# If cell is not empty, step the random number
RANDSTEP	CCS	RAND9	# CCS instead of BZF, fewer steps
	TCF	RNDSTOR2	# RAND9 > 0 (A = RAND9-1)
	CAF	EIGHT	# RAND9 = 0, make it 8 again
RNDSTOR2	TS	RAND9
	TCF	PLAYRAND
PLAYFREE	CA	RAND9	# Found a free cell, play here.
	INCR	A	# RAND9 is 0-8, the board is 1-9.
PLAYSPOT	TS	L
	TCR	PLAYHERE
	CA	TRUE	# Human turn next.
	TS	MANTURN
	CA	QCPUPLAY	# Restore Q
	TS	Q
CPUOVER	RETURN


# Function to search the board for lines with two of a player and a blank.
# Input: A is desired player (2 or -2).  Output: A is cell number to play, or zero.
SEARCH			# For each of the eight possible lines,
			# add up the values of the three cells on that line.
			# If the sum is 4, then X has two in that line.
			#  2 +  0 +  2 =  4
			# If the sum is -4, then O has two in that line.
			# -2 + -2 +  0 = -4
	DOUBLE
	TS	GOAL
	CA	EIGHT
	TS	L	# L is the line counter (7 -> 0).
S-LOOP	EXTEND
	DIM	L
	INDEX	L	# Add up the values of each line on the board
	CA	CHECK1
	INDEX	A
	CA	BOARD
	TS	CALC	# CALC is a local summing location
	INDEX	L
	CA	CHECK2
	INDEX	A
	CA	BOARD
	AD	CALC
	TS	CALC
	INDEX	L
	CA	CHECK3
	INDEX	A
	CA	BOARD
	AD	CALC

	EXTEND
	SU	GOAL	# Compare with 4 or -4.
	EXTEND
	BZF	S-MATCH	# Found a match.
	CA	L
	EXTEND
	BZF	S-NOLOOP	# Checked all options, no match.
	TCF	S-LOOP
S-NOLOOP	CA	ZEROREG
	RETURN

S-MATCH	INDEX	L	# Check first cell for hole.
	CA	CHECK1
	TS	CALC
	INDEX	A
	CA	BOARD
	EXTEND
	BZF	S-HOLE
	INDEX	L	# Check second cell for hole.
	CA	CHECK2
	TS	CALC
	INDEX	A
	CA	BOARD
	EXTEND
	BZF	S-HOLE
	INDEX	L	# Must be third cell.
	CA	CHECK3
	TS	CALC
S-HOLE	CA	CALC
	RETURN


# Values:
T3-100MS	OCT	37766
T6-1SEC	OCT	1600
T6START	DEC	16384
TRUE	DEC	1
FIVE	DEC	5
EIGHT	DEC	8
NINE	DEC	9
CSHIFT	DEC	32
OPR-ERR	DEC	64
PROGBIT	DEC	256
COMPBIT	DEC	2
# Values for Board:
PLAYERX	DEC	2	# X
PLAYERXB	DEC	1	# X (blinking)
PLAYERO	DEC	-2	# O
PLAYEROB	DEC	-1	# O (blinking)
# IO Values for X/O/-
DISPLAYX	DEC	3	# DSKY code for '1'
DISPLAYO	DEC	21	# DSKY code for '0'
DISPLAY-	DEC	0	# DSKY code for ' '
# IO Values for DSKY pairs
PAIR12	OCT	60000	# Status lamp address
PAIR11	OCT	54000	# Prog 7-segment pair address
PAIR8	OCT	40000	# DSKY 7-segment pair addresses
PAIR7	OCT	34000
PAIR6	OCT	30000
PAIR5	OCT	24000
PAIR4	OCT	20000
PAIR3	OCT	14000
PAIR2	OCT	10000
PAIR1	OCT	04000
# Cell indicies for every possible line (7/8/9, 4/5/6, etc)
CHECK1	DEC	7
	DEC	4
	DEC	1
	DEC	7
	DEC	8
	DEC	9
	DEC	7
	DEC	9

CHECK2	DEC	8
	DEC	5
	DEC	2
	DEC	4
	DEC	5
	DEC	6
	DEC	5
	DEC	5

CHECK3	DEC	9
	DEC	6
	DEC	3
	DEC	1
	DEC	2
	DEC	3
	DEC	3
	DEC	1


# System Address Locations
A	=	00	# A register
ARUPT	=	10
L	=	01	# L register
Q	=	02	# Q register
QRUPT	=	12
ZEROREG	=	07	# Zero register
NEWJOB	=	067	# Night watchman
TIME3	=	26
TIME6	=	31
# IO Channels
DSPL10	=	010
LAMP163	=	0163
KEY15	=	015
IO-11	=	011
IO-13	=	013
# Address Locations
RAND9	=	061	# Address for random number
TURN	=	062	# Whose turn is it? (2 = X, -2 = O, 0 = END)
BOARD	=	062
BOARD1	=	063	# Address for start of board
BOARD2	=	064
BOARD3	=	065
BOARD4	=	066
BOARD5	=	067
BOARD6	=	070
BOARD7	=	071
BOARD8	=	072
BOARD9	=	073

QGAMEINI	=	074	# Backup locations for Q register (allows more than one function call depth).
QDRAW	=	075	# Some of these could be shared, if space is tight.
QTHINK	=	076
QCPUPLAY	=	077
QPLYHERE	=	100

CALC	=	101	# Local scratchpad (ran out of free registers)
DOBLINK	=	102	# Global flag indicating that a blink out is needed (1=blink, 0=undo blink)
CNTDOWN	=	103	# Countdown of moves from 9 to 0.  Game ends at 0.
CPUPYR	=	104	# If Computer has to play (0 = False, 1 is player O)
MANTURN	=	105	# Waiting for human (1), or computer player is scheduled to play within a second (0).
STARTPYR	=	106	# Which player (2 = X, -2 = O) starts the game.
GOAL	=	107	# Local scratchpad (ran out of free registers)
