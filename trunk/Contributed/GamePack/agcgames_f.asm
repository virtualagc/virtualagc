;--------------------------------------------------------------------------
; AGC MEMORY GAME
;
; Version:  1.0
; Author:   John Pultorak
; Date:     6/6/2009
;
; THIS WORK IS PUBLIC DOMAIN.
;
; PURPOSE:
; A game to test your memory. The AGC presents you with a sequence of digits,
; one digit at a time. You have to remember the sequence and type it back in.
; If you're successful, AGC adds another digit to the sequence.
;   This continues until the limits of your memory are reached. The sequence
; begins with one digit and increases until you fail or until it reaches 30
; digits in length.
;   The digits are 1-7. Zero is not considered a digit in the sequence.
;
;
; GAMEBOARD:
; The sequence of digits is displayed in the rightmost digit of R1 on the
; DSKY. The display begins with 0, which is not considered part of the
; sequence. The sequence then begins with the digits appearing about once-
; per-second. The number of digits in your sequence is displayed in R2.
; After all digits in the sequence have been displayed, 0 is briefly dis-
; played again. Then, you have to repeat the sequence by typing it back
; into R1.
;
;
; OPERATOR INPUT:
; AGC uses VERB 21, NOUN 2 to get your input. You may enter as few as 1 or
; as many as 4 digits at any time. Although there is space for a 5th digit,
; you must not enter a 5th digit; if you do, you will lose the game.
;    When the sequence grows beyond 4, or if you enter fewer than 4 digits
; at a time, the AGC will enter another VERB 21, NOUN 2 to get additional
; digits. It will keep doing that until you enter the entire sequence or
; until you make a mistake.
;
;
; GETTING STARTED:
; Kick things off by selecting the program. To play against the AGC:
;   <VERB> <37> <NOUN> <77> <ENTER>
;
; This selects PROGRAM 77 which will start the memory game job.
;
;
; IMPLEMENTATION:
; The game is started with the PROGRAM code P77. The program starts
; an EXEC job that runs until a delay (time interval) is needed. At that
; point, the job starts a WAITLIST task and then terminates. The task
; waits for the desired time interval, starts a job for the next portion of
; code, and terminates. The code is therefore a chain of jobs that
; do something alternating with tasks that produce delay intervals.
;    The random numbers in the digit sequence are obtained from the least
; significant bits of the AGC real-time clock.
;
;
; ERRATA:
; The 4-digit limitation on key entries is annoying. The only alternative
; I could come up with is to change the number field from 3-bits to 2-bits.
; This avoids setting bit 15 which causes the problem. But it would limit
; the digit range to 1-3 which seems too small. It is hard to remember to
; limit your key entries to groups of 4. But then again, this IS a memory game.
;--------------------------------------------------------------------------

G2MAX		DS	30		; max numbers
G2MASKT1	DS	7

	; clear the memory list

P77		CAF	ZERO
		TS	G2PUT
		TS	G2LSTNUM	; last number to be inserted

	; if G2PUT equals G2MAX, the insertion limit is reached.

G2NXTMOV	CS	G2MAX		; 1's compliment of G2MAX
		AD	G2PUT		; put (-A) + val in A
		CCS	A		; A = DABS
		TC	*+4		; >0 (A < val)
		TC	G2END1		; +0 (never happens)
		TC	*+2		; <0 (A > val)
		TC	G2END1		; -0 (A == val)

	; add a number to the memory list

		CAF	ZERO
		AD	TIME1		; get a random number
		MASK	G2MASKT1
		TS	G1OIVALU

		CCS	G1OIVALU	; number is nonzero, right?
		TC	*+2		; yes
		TC	G2NXTMOV	; no, get a different number

	; number is different from the previous number, right?

		CS	G1OIVALU	; 1's compliment of G1OIVALU
		AD	G2LSTNUM	; put (-A) + val in A
		CCS	A		; A = DABS
		TC	*+4		; >0 (A < val)
		TC	G2NXTMOV	; +0 (never happens)
		TC	*+2		; <0 (A > val)
		TC	G2NXTMOV	; -0 (A == val)

		XCH	G1OIVALU	; new number becomes the previous
		TS	G1OIVALU
		TS	G2LSTNUM

		INDEX	G2PUT
		TS	G2LIST		; indexed insert onto list

		XCH	G2PUT
		AD	ONE
		TS	G2PUT		; bump insertion index

	; clear the display

		TS	G1DSPR2	; display the sequence count

		CAF	ZERO
		TS	G1DSPR1
		TS	G1DSPR3

		TCR	G1DISPLY	; clear the display

	; delay before starting the number display sequence

		CAF	G2T300		; add a timer task
		TC	WAITLIST
		CADR	G2TASK0		; 14-bit task address

		TC	ENDOFJOB


	; loop to display all numbers on the memory list

G2ADDNUM	CAF	ZERO
		TS	G2GET		; initialize display index


	; if G2GET equals G2PUT, all numbers have been displayed

G2DISPLY	CS	G2GET		; 1's compliment of G2GET
		AD	G2PUT		; put (-A) + val in A
		CCS	A		; A = DABS
		TC	*+4		; >0 (A < val)
		TC	G2DSDONE	; +0 (never happens)
		TC	*+2		; <0 (A > val)
		TC	G2DSDONE	; -0 (A == val)

		INDEX	G2GET
		XCH	G2LIST
		INDEX	G2GET
		TS	G2LIST		; get number from list

		TS	G1DSPR1
		TCR	G1DISPLY	; display the number

		XCH	G2GET
		AD	ONE
		TS	G2GET		; bump retrieval index

	; start task delay before displaying the next number

		CAF	G2T100		; add a timer task
		TC	WAITLIST
		CADR	G2TASK1		; 14-bit task address

		TC	ENDOFJOB


	; done displaying the memory sequence

G2DSDONE	CAF	ZERO
		TS	G1DSPR1

		TCR	G1DISPLY	; display the number

		CAF	G2T100		; add a timer task
		TC	WAITLIST
		CADR	G2TASK2		; 14-bit task address

		TC	ENDOFJOB


G2MASK		DS	%07000
G2MASKA		DS	%00777

	; get user input

G2GETINP	CAF	ZERO
		TS	G2GET		; initialize display index

G2ILOOP		TCR	G1INPUT

	; Extract octal digits from the input word
	; Decrementing loop (loop G2LCNTR2 times)

		CAF	FOUR
		TS	G2LCNTR2

G2DLOOP		CCS	G2LCNTR2	; got all digits?
		TC	*+2		; not yet
		TC	G2ILOOP		; yes, get more user input
		TS	G2LCNTR2

	; Extract the digit in in bits 10-12

		XCH	G1OIVALU
		TS	G1OIVALU
		MASK	G2MASK
		TS	G2NUM

	; if digit is zero, ignore it.

		CCS	G2NUM		; zero?
		TC	*+2		; no
		TC	G2SHR3		; yes, get next digit

	; shift right 9 times to place digit in lsb.

		XCH	G2NUM
		TS	SR
		CS	SR
		CS	SR
		CS	SR
		CS	SR
		CS	SR
		CS	SR
		CS	SR
		CS	SR
		XCH	SR
		TS	G2NUM

	; digit matches list? If not, game over.

		INDEX	G2GET
		XCH	G2LIST
		INDEX	G2GET
		TS	G2LIST		; get number from list

		COM	A		; 1's compliment of A
		AD	G2NUM		; put (-A) + val in A
		CCS	A		; A = DABS
		TC	G2END2		; >0 (A < val)
		TC	*+2		; +0 (never happens)
		TC	G2END2		; <0 (A > val)

	; End of list? If so, increase number sequence

		XCH	G2GET
		AD	ONE
		TS	G2GET		; bump retrieval index

		CS	G2GET		; 1's compliment of G2GET
		AD	G2PUT		; put (-A) + val in A
		CCS	A		; A = DABS
		TC	*+4		; >0 (A < val)
		TC	G2NXTMOV	; +0 (never happens)
		TC	*+2		; <0 (A > val)
		TC	G2NXTMOV	; -0 (A == val)

	; shift user input left 3 times to get next digit

G2SHR3		XCH	G1OIVALU
		MASK	G2MASKA
		TS	SL
		CS	SL		; shift left 3 bits
		CS	SL
		XCH	SL
		TS	G1OIVALU

		TC	G2DLOOP		; get next digit


	; game over, max sequence length reached!!!

G2END1		TC	ENDOFJOB

	; game over, user made an error!!!

G2END2		TC	ENDOFJOB


G2T100		DS	100		; 1 second
G2T300		DS	300		; 3 seconds
G2PRIO		DS	%3		; lowest priority

	; task initiates delay before start of game

G2TASK0		XCH	G2PRIO		; job priority
		TC	NOVAC
		CADR	G2ADDNUM	; 14-bit job address
		TC	TASKOVER

	; task initiates display of next digit after a delay

G2TASK1		XCH	G2PRIO		; job priority
		TC	NOVAC
		CADR	G2DISPLY	; 14-bit job address
		TC	TASKOVER

	; task initiates delay after all digits have been displayed

G2TASK2		XCH	G2PRIO		; job priority
		TC	NOVAC
		CADR	G2GETINP	; 14-bit job address
		TC	TASKOVER

;--------------------------------------------------------------------------
; AGC TIC-TAC-TOE
;
; P78: player1 vs. AGC
; P79: player1 vs. player2
;
; Version:  1.0
; Author:   John Pultorak
; Date:     6/6/2009
;
; THIS WORK IS PUBLIC DOMAIN.
;
; PURPOSE:
; A one- or two-player classical tic-tac-toe game. The primitive gameboard
; and the timed-interval between moves adds a certain additional challenge.
;
;
; GAMEBOARD:
; The gameboard is displayed on the DSKY. The board positions occupy the
; middle 3 digits of each register:
;
;   R1: 0XXX0
;   R2: 0XXX0
;   R3: 0XXX0
;
; Digits on the right and left margins are ignored. Each position on the 
; gameboard is identified by a number (1-9):
;
;   R1: 01230
;   R2: 04560
;   R3: 07890
;
; The user selects a move by entering the number (1-9) for the desired
; position. To redisplay the gameboard without making a move, enter 0.
;    There are no X'es and O's. Player 1 is a '1' and Player 2 is a '2'.
; An unoccupied space is a zero.
;    You enter the position code (1-9) or 0 to redisplay. The AGC keeps
; track of whose turn it is and will put a '1' or '2' in the selected
; position as appropriate.
;    AGC monitors the game and freezes the display when the game is over.
;
;
; MAKING A MOVE:
; When it's time to make your move, AGC uses VERB 21, NOUN 2 to get your
; input. You can make your move in octal or decimal. If you use octal, you
; can enter a single digit for the first 7 positions on the board. For
; position 8, enter '10' and, for postion 9, '11'.
;    If you want to use decimal entries, you must preceed them with a '+'
; sign and enter the entire 5 digits: i.e.: +00008. You'll probably find
; the octal digits a better choice.
;
;
; GETTING STARTED:
; Kick things off by selecting the program. To play against the AGC:
;   <VERB> <37> <NOUN> <78> <ENTER>
;
; This selects PROGRAM 78 which will start the tic-tac-toe job.
;
;
; IMPLEMENTATION:
; The game is started with the PROGRAM code P78 or P79. The program starts
; an EXEC job that initializes the gameboard and then displays it using
; VERB 5, NOUN 2. The job then terminates with an ENDOFJOB but, before it
; terminates, it starts a task on the WAITLIST.
;    The purpose of the task is to create a short time interval between moves
; so the player(s) can study the gameboard. When the task times out, it re-
; starts the job. The job handles one move and then terminates, restarting
; the task which then restarts the job for the next move.
;    Each job begins by getting a move from the AGC or from the player using
; VERB 21, NOUN 2. The move is checked to verify that it's valid (an un-
; occupied position. The move is then entered into the gameboard, the board
; is redisplayed, and the board is checked for a win or stalemate. In the
; event of a win or stalemate, the job terminates without starting the task
; so the final state of the board remains frozen on the DSKY.
;    If the AGC is making a move, it begins by searching for a move that will
; give it a win on this turn. If no such move is found, it searches for a move
; that will block the opponent's win on his next turn. If no such move is
; found, it checks whether the opponent is occupying any corner positions
; the opposite corner is unoccupied. This could lead to a dilemma where the
; opponent could force a win. If no such move is found, the AGC does a
; default move using an order of preference.
;    The code uses and re-uses a small number of simple techniques: subroutine
; calls, a decrementing loop, an indexed table lookup, a variable comparison,
; and calls to internal AGC "PINBALL" I/O routines. If you examine the code,
; there is a great deal of building-block type repetition.
;
; ERRATA:
; There is no range-checking on the user's move. If you enter a number other
; than 0-9, it will malfunction.
; Each game always begins with player 1. If you're playing the AGC, it might
; be fun to have the AGC begin once and awhile.
;
;--------------------------------------------------------------------------

P78		CAF	ZERO		; player1 vs. AGC
		TS	G1PLAYRS
		TC	G1_initialize

P79		CAF	ONE		; player1 vs. player2
		TS	G1PLAYRS

	; initialize gameboard

G1_initialize	CAF	ZERO
		TS	G1MODE

G1_gameLoop	INDEX	G1MODE		; mode = 0..3
		TC	G1_indexGOTO

G1_indexGOTO	TC	G1_clearBoard	; mode = 0
		TC	G1_player1Moves	; mode = 1
		TC	G1_player2Moves	; mode = 2
		TC	G1_showBoard	; mode = 3

	; clear gameboard

G1_clearBoard	CAF	ZERO
		TS	G1DSPR1
		TS	G1DSPR2
		TS	G1DSPR3

		CAF	ONE		; human makes first move
		TS	G1MODE
		TC	G1_showBoard

	; get player 1's move (player 1 is always a person)

G1_player1Moves	TCR	G1INPUT		; put move into G1OIVALU

		CCS	G1OIVALU
		TC	G1_checkPlayer1	; (1-9) player 1 selects a move
		TC	G1_showBoard	; (0) redisplay the gameboard

	; validate player 1's move.

G1_checkPlayer1	XCH	G1OIVALU
		TS	G1CURMOV

		TCR	G1getpos	; check if space is already occupied
		CCS	A		; space already occupied?
		TC	G1_player1Moves	; yes, get a different move

		XCH	G1CURMOV
		TS	G1CURMOV
		TCR	G1setpos	; make the move

		CAF	TWO
		TS	G1MODE		; player 2 makes next move
		TC	G1_showBoard

	; get player 2's move (player 2 is a person or the AGC).

G1_player2Moves	CCS	G1PLAYRS	; human or AGC?
		TC	G1_player2human	; human
		TCR	G1AGCinput	; AGC, put move into G1OIVALU
		TC	G1_checkPlayer2

G1_player2human	TCR	G1INPUT		; put move into G1OIVALU

		CCS	G1OIVALU
		TC	G1_checkPlayer2	; (1-9) player 2 selects a move
		TC	G1_showBoard	; (0) redisplay the gameboard

	; validate player 2's move.

G1_checkPlayer2	XCH	G1OIVALU
		TS	G1CURMOV

		TCR	G1getpos	; check if space is already occupied
		CCS	A		; space already occupied?
		TC	G1_player2Moves	; yes, get a different move

		XCH	G1CURMOV
		TS	G1CURMOV
		TCR	G1setpos	; make the move

		CAF	ONE
		TS	G1MODE		; player 1 makes next move

	; display gameboard

G1_showBoard	TCR	G1DISPLY	; display G1DSPR1

	; check for game over: a win or a tie.
		TCR	G1checkWin	; exit if there's a winner
		TCR	G1checkTie	; exit if there's a tie

	; start task to make the next move

		CAF	G1_time		; add a test task
		TC	WAITLIST
		CADR	G1_task		; 14-bit task address

		TC	ENDOFJOB


	; task initiates the next move after a delay

G1_time		DS	500		; 5 seconds

G1_task		XCH	G1_prio		; job priority
		TC	NOVAC
		CADR	G1_gameLoop	; 14-bit job address
		TC	TASKOVER

G1_prio		DS	%3		; lowest priority


;--------------------------------------------------------------------------
; Display the gameboard in R1, R2, and R3, Calls pinball: verb 5, noun 2.
; Entry:  G1DISPLY
; Input:  none
; Output: The octal contents of G1DSPR1, G1DSPR2, and G1DSPR3
;         are written to DSKY registers R1, R2, and R3.
;--------------------------------------------------------------------------

G1DSNVCD	DS	%01202		; verb 05, noun 02
G1DSADDR	DS	G1DSRSTR
G1DSTCDR	DS	G1DSPR1

G1DISPLY	XCH	Q
		TS	G1DSSAVQ	; save return address

		CAF	G1DSTCDR	; load 'machine address to be specified'
		TS	MPAC+2

G1DSRSTR	CAF	G1DSNVCD
		TC	NVSUB

		TC	*+2		; display busy
		TC	G1DSSAVQ	; execution of verb/noun succeeded so RETURN

		CAF	G1DSADDR
		TC	NVSUBUSY	; go to sleep until display released

		TC	ENDOFJOB	; error: another job is already waiting


;--------------------------------------------------------------------------
; Get operator input. Calls pinball: verb 21, noun 2.
; Sleeps if DSKY is busy until KEYREL. Executes verb 21, noun 2 to do
; an external load. Then it sleeps with ENDIDLE until the user loads
; the data or terminates the load with PROCEED or TERMINATE.
; NOTE: routines that call ENDIDLE must be in fixed-switchable memory.
; Entry:  G1INPUT
; Input:  none
; Output: The operator input is put into G1OIVALU.
;--------------------------------------------------------------------------

G1OINVCD	DS	%05202		; verb 21, noun 02
G1OIADDR	DS	G1OIRSTR
G1OITCDR	DS	G1OIVALU


G1INPUT		XCH	Q
		TS	G1OISAVQ	; save return address

		CAF	G1OITCDR
		TS	MPAC+2

G1OIRSTR	CAF	G1OINVCD
		TC	NVSUB

		TC	*+2		; display busy
		TC	G1OIWAIT	; execution of verb/noun succeeded

		CAF	G1OIADDR
		TC	NVSUBUSY	; go to sleep until display released
		TC	ENDOFJOB	; another job is already sleeping

G1OIWAIT	TC	ENDIDLE
		TC	ENDOFJOB	; terminate
		TC	ENDOFJOB	; proceed without data

		TC	G1OISAVQ	; execution of verb/noun succeeded so RETURN


;--------------------------------------------------------------------------
; Set a value at the indicated position on the gameboard. If A=0, the board 
; is not changed.
; Entry:  G1setpos
; Input:  The position (1-9) is in the A register. 
;         G1MODE contains the player (1-2)
; Output: the value in G1MODE is placed at the indicated position.
;--------------------------------------------------------------------------

G1setpos	TS	G1STPOS	; save pos
		XCH	Q
		TS	G1STSAVQ	; save return address

		XCH	G1MODE
		TS	G1MODE

		TS	SL

		INDEX	G1STPOS	; pos = 0..9
		TC	G1ST_GOTO	; indexed GOTO

G1ST_GOTO	TC	G1STSAVQ	; RETURN
		TC	G1STPOS1
		TC	G1STPOS2
		TC	G1STPOS3
		TC	G1STPOS4
		TC	G1STPOS5
		TC	G1STPOS6
		TC	G1STPOS7
		TC	G1STPOS8
		TC	G1STPOS9

G1STPOS1	TCR	G1ST_SL9	; shift left 9 bits
		TC	G1ST_maskR1

G1STPOS2	TCR	G1ST_SL6	; shift left 6 bits
		TC	G1ST_maskR1

G1STPOS3	TCR	G1ST_SL3	; shift left 3 bits
		TC	G1ST_maskR1

G1STPOS4	TCR	G1ST_SL9	; shift left 9 bits
		TC	G1ST_maskR2

G1STPOS5	TCR	G1ST_SL6	; shift left 6 bits
		TC	G1ST_maskR2

G1STPOS6	TCR	G1ST_SL3	; shift left 3 bits
		TC	G1ST_maskR2

G1STPOS7	TCR	G1ST_SL9	; shift left 9 bits
		TC	G1ST_maskR3

G1STPOS8	TCR	G1ST_SL6	; shift left 6 bits
		TC	G1ST_maskR3

G1STPOS9	TCR	G1ST_SL3	; shift left 3 bits
		TC	G1ST_maskR3

G1ST_SL9	CS	SL		; shift left 9 bits
		CS	SL
		CS	SL
G1ST_SL6	CS	SL		; shift left 6 bits
		CS	SL
		CS	SL
G1ST_SL3	CS	SL		; shift left 3 bits
		CS	SL
		XCH	SL
		TC	Q		; RETURN

G1ST_maskR1	COM
		TS	Q
		CS	G1DSPR1
		MASK	Q		; 'OR' A with G1DSPR1
		COM
		TS	G1DSPR1
		TC	G1STSAVQ	; RETURN

G1ST_maskR2	COM
		TS	Q
		CS	G1DSPR2
		MASK	Q		; 'OR' A with G1DSPR2
		COM
		TS	G1DSPR2
		TC	G1STSAVQ	; RETURN

G1ST_maskR3	COM
		TS	Q
		CS	G1DSPR3
		MASK	Q		; 'OR' A with G1DSPR3
		COM
		TS	G1DSPR3
		TC	G1STSAVQ	; RETURN


;--------------------------------------------------------------------------
; Get the value at the indicated position on the gameboard.
; Entry:  G1getpos
; Input:  The position (1-9) is in the A register.
; Output: Gameboard value at that position is returned in the A register.
;--------------------------------------------------------------------------

G1GT_maskL	DS	%07000
G1GT_maskM	DS	%00700
G1GT_maskR	DS	%00070

G1getpos	TS	G1GTPOS	; save pos
		XCH	Q
		TS	G1GTSAVQ	; save return address

		CAF	ZERO		; zero constant in fixed memory

		INDEX	G1GTPOS	; pos = 0..9
		TC	G1GT_GOTO	; indexed GOTO

G1GT_GOTO	TC	G1GTSAVQ	; RETURN
		TC	G1GTPOS1
		TC	G1GTPOS2
		TC	G1GTPOS3
		TC	G1GTPOS4
		TC	G1GTPOS5
		TC	G1GTPOS6
		TC	G1GTPOS7
		TC	G1GTPOS8
		TC	G1GTPOS9

G1GTPOS1	AD	G1DSPR1
		MASK	G1GT_maskL
		TC	G1GT_SR9

G1GTPOS2	AD	G1DSPR1
		MASK	G1GT_maskM
		TC	G1GT_SR6

G1GTPOS3	AD	G1DSPR1
		MASK	G1GT_maskR
		TC	G1GT_SR3

G1GTPOS4	AD	G1DSPR2
		MASK	G1GT_maskL
		TC	G1GT_SR9

G1GTPOS5	AD	G1DSPR2
		MASK	G1GT_maskM
		TC	G1GT_SR6

G1GTPOS6	AD	G1DSPR2
		MASK	G1GT_maskR
		TC	G1GT_SR3

G1GTPOS7	AD	G1DSPR3
		MASK	G1GT_maskL
		TC	G1GT_SR9

G1GTPOS8	AD	G1DSPR3
		MASK	G1GT_maskM
		TC	G1GT_SR6

G1GTPOS9	AD	G1DSPR3
		MASK	G1GT_maskR
		TC	G1GT_SR3

G1GT_SR9	TS	SR
		TC	G1GT_SR9A
G1GT_SR6	TS	SR
		TC	G1GT_SR6A
G1GT_SR3	TS	SR
		TC	G1GT_SR3A

G1GT_SR9A	CS	SR		; shift right 9 bits
		CS	SR
		CS	SR
G1GT_SR6A	CS	SR		; shift right 6 bits
		CS	SR
		CS	SR
G1GT_SR3A	CS	SR		; shift right 3 bits
		CS	SR
		XCH	SR

		TC	G1GTSAVQ	; RETURN


;--------------------------------------------------------------------------
; Check for end-of-game because someone won. Call ENDOFJOB if there's a
; winner, otherwise return.
; Entry:   G1checkWin
; Inputs:  none
; Outputs: none
;--------------------------------------------------------------------------

G1CW_chkval1	DS	1		; index 0
		DS	4		; index 1
		DS	7		; index 2
		DS	1		; index 3
		DS	2		; index 4
		DS	3		; index 5
		DS	1		; index 6
		DS	7		; index 7

G1CW_chkval2	DS	2		; index 0
		DS	5		; index 1
		DS	8		; index 2
		DS	4		; index 3
		DS	5		; index 4
		DS	6		; index 5
		DS	5		; index 6
		DS	5		; index 7

G1CW_chkval3	DS	3		; index 0
		DS	6		; index 1
		DS	9		; index 2
		DS	7		; index 3
		DS	8		; index 4
		DS	9		; index 5
		DS	9		; index 6
		DS	3		; index 7

G1CW_start	DS	8		; check all 8 ways to win

G1checkWin	XCH	Q
		TS	G1CWSAVQ	; save return address

		XCH	G1CW_start
		TS	G1CWINDX

	; Decrementing loop (loop G1CW_start times)

G1CW_loop	CCS	G1CWINDX	; checked all possible wins?
		TC	G1CW_chkpos	; not yet
		TC	G1CWSAVQ	; yes, no winner so RETURN

G1CW_chkpos	TS	G1CWINDX	; index is DABS of G1CWINDX

	; Compare the board positions at chkva1 and chkval2

		INDEX	G1CWINDX
		CAF	G1CW_chkval1	
		TCR	G1getpos	; read the board position into A
		TS	G1CWVAL	; temporarily save it

		INDEX	G1CWINDX
		CAF	G1CW_chkval2	
		TCR	G1getpos	; read the board position into A

		COM			; 1's compliment of A
		AD	G1CWVAL	; put (-A) + val in A
		CCS	A		; A = DABS
		TC	G1CW_loop	; >0 (A < val)
		TC	G1CW_chkNext	; +0 (never happens)
		TC	G1CW_loop	; <0 (A > val)
		TC	G1CW_chkNext	; -0 (A == val)

	; chkval1 and chkval2 positions match.
	; Compare the board positions at chkva1 and chkval3

G1CW_chkNext	INDEX	G1CWINDX
		CAF	G1CW_chkval3	
		TCR	G1getpos	; read the board position into A

		COM			; 1's compliment of A
		AD	G1CWVAL	; put (-A) + val in A
		CCS	A		; A = DABS
		TC	G1CW_loop	; >0 (A < val)
		TC	G1CW_foundwin	; +0 (never happens)
		TC	G1CW_loop	; <0 (A > val)
		TC	G1CW_foundwin	; -0 (A == val)

G1CW_foundwin	CCS	G1CWVAL	; the winning combo is nonzero, right?
		TC	ENDOFJOB	; yes, game over
		TC	G1CW_loop	; no


;--------------------------------------------------------------------------
; Check for end-of-game because all positions are occupied. If the game is
; over, call ENDOFJOB; otherwise return.
; Entry:   G1checkTie
; Inputs:  none
; Outputs: none
;--------------------------------------------------------------------------

G1CT_start	DS	9		; check all nine board positions

G1checkTie	XCH	Q
		TS	G1CTSAVQ	; save return address

		XCH	G1CT_start
		TS	G1CTPOS

	; Decrementing loop (loop G1CT_start times)

G1CT_loop	CCS	G1CTPOS	; checked all positions?
		TC	G1CT_chkpos	; not yet
		TC	ENDOFJOB	; yes, game is a tie.

G1CT_chkpos	XCH	G1CTPOS
		TCR	G1getpos	; check if space is already occupied
		CCS	A		; space already occupied?
		TC	G1CT_loop	; yes, check the next space
		TC	G1CTSAVQ	; no, not a tie so RETURN


;--------------------------------------------------------------------------
; Get the AGC move. Return the move (1-9) in G1OIVALU.
; Entry:   G1AGCinput
; Inputs:  none
; Outputs: AGC move (range 1-9) in G1OIVALU
;--------------------------------------------------------------------------

G1AGCinput	XCH	Q
		TS	G1AISAVQ	; save return address

	; Check for a move to win the game.

		CAF	TWO		; AGC is always player 2
		TCR	G1findmove
		TS	G1OIVALU	; save the potential move
		CCS	A
		TC	G1AISAVQ	; found a move to win so RETURN

	; Check for a move to block the opponent from winnning.

		CAF	ONE		; opponent is always player 1
		TCR	G1findmove
		TS	G1OIVALU	; save the potential move
		CCS	A
		TC	G1AISAVQ	; found a move to win so RETURN

	; Check for a move to block the opponent from setting up
	; a dilemma that will force his win.

		TCR	G1blkmove
		TS	G1OIVALU	; save the potential move
		CCS	A
		TC	G1AISAVQ	; found a move to win so RETURN

	; Just get any move.

		TCR	G1AGCmove
		TC	G1AISAVQ	; RETURN

;--------------------------------------------------------------------------
; Get the AGC move. Return the move (1-9) in G1OIVALU.
; Entry:   G1AGCmove
; Inputs:  none
; Outputs: AGC move (range 1-9) in G1OIVALU
;--------------------------------------------------------------------------

G1AM_moves	DS	0
		DS	4		; try this one last
		DS	8
		DS	6
		DS	2
		DS	9
		DS	7
		DS	3
		DS	1
		DS	5		; try this one first

G1AM_start	DS	9		; check all nine possible moves

G1AGCmove	XCH	Q
		TS	G1AMSAVQ	; save return address

		XCH	G1AM_start
		TS	G1AMPOS

	; Decrementing loop (loop G1AM_start times)

G1AM_loop	CCS	G1AMPOS	; checked all moves?
		TC	G1AM_chkpos	; not yet
		TC	G1AMSAVQ	; yes, RETURN

G1AM_chkpos	XCH	G1AMPOS
		INDEX	A
		CAF	G1AM_moves
		TS	G1OIVALU	; save the potential move

		TCR	G1getpos	; check if space is already occupied
		CCS	A		; space already occupied?
		TC	G1AM_loop	; yes, try another move
		TC	G1AMSAVQ	; no, so RETURN

;--------------------------------------------------------------------------
; Return the position code (1-9) for a move that will win the game for you
; or block a win by your opponent. If the player code (1 or 2) is your code,
; the return value will be the move you need to win. If the player code is
; your opponent's code, the return value will be the move you need to block
; a win by your opponent. If zero is returned, there is no move that will
; win or block a win.
; Entry:   G1findmove
; Inputs:  A contains the player (1 or 2)
; Outputs: A contains the position code for the move, or 0 if there
;          is no move.
;--------------------------------------------------------------------------

G1FM_chkval1	DS	1
		DS	2
		DS	3

		DS	4
		DS	5
		DS	6

		DS	7
		DS	8
		DS	9

		DS	1
		DS	4
		DS	7

		DS	2
		DS	5
		DS	8

		DS	3
		DS	6
		DS	9

		DS	1
		DS	5
		DS	9

		DS	3
		DS	5
		DS	7

G1FM_chkval2	DS	2
		DS	3
		DS	1

		DS	5
		DS	6
		DS	4

		DS	8
		DS	9
		DS	7

		DS	4
		DS	7
		DS	1

		DS	5
		DS	8
		DS	2

		DS	6
		DS	9
		DS	3

		DS	5
		DS	9
		DS	1

		DS	5
		DS	7
		DS	3

G1FM_chkval3	DS	3
		DS	1
		DS	2

		DS	6
		DS	4
		DS	5

		DS	9
		DS	7
		DS	8

		DS	7
		DS	1
		DS	4

		DS	8
		DS	2
		DS	5

		DS	9
		DS	3
		DS	6

		DS	9
		DS	1
		DS	5

		DS	7
		DS	3
		DS	5

G1FM_start	DS	24		; check all 24 possiblities

G1findmove	TS	G1FMPLYR

		XCH	Q
		TS	G1FMSAVQ	; save return address

		XCH	G1FM_start
		TS	G1FMINDX

	; Decrementing loop (loop G1FM_start times)

G1FM_loop	CCS	G1FMINDX	; checked all possibilities?
		TC	G1FM_chkpos	; not yet
		TC	G1FM_nomove	; yes, no recommended move

G1FM_chkpos	TS	G1FMINDX	; index is DABS of G1FMINDX

	; Compare the board positions at chkva1 and chkval2

		INDEX	G1FMINDX
		CAF	G1FM_chkval1	
		TCR	G1getpos	; read the board position into A
		TS	G1FMVAL	; temporarily save it

		INDEX	G1FMINDX
		CAF	G1FM_chkval2	
		TCR	G1getpos	; read the board position into A

		COM			; 1's compliment of A
		AD	G1FMVAL	; put (-A) + val in A
		CCS	A		; A = DABS
		TC	G1FM_loop	; >0 (A < val)
		TC	G1FM_chkNext	; +0 (never happens)
		TC	G1FM_loop	; <0 (A > val)
		TC	G1FM_chkNext	; -0 (A == val)

	; chkval1 and chkval2 positions match.
	; Compare them to player.

G1FM_chkNext	CS	G1FMPLYR	; 1's compliment of player
		AD	G1FMVAL	; put (-A) + val in A
		CCS	A		; A = DABS
		TC	G1FM_loop	; >0 (A < val)
		TC	G1FM_chkLast	; +0 (never happens)
		TC	G1FM_loop	; <0 (A > val)
		TC	G1FM_chkLast	; -0 (A == val)

	; chkval1 and chkval2 positions match and are equal to player.
	; Check if the third position in the sequence is unoccupied.

G1FM_chkLast	INDEX	G1FMINDX
		CAF	G1FM_chkval3	
		TCR	G1getpos	; read the board position into A

		CCS	A		; last position unoccupied?
		TC	G1FM_loop	; no, go check another position
		INDEX	G1FMINDX	; yes, found the recommended move
		CAF	G1FM_chkval3	
		TC	G1FMSAVQ	; RETURN		

G1FM_nomove	CAF	ZERO		; no recommended move
		TC	G1FMSAVQ	; RETURN

;--------------------------------------------------------------------------
; If the opponent has occupied a corner of the board, occupy the opposite
; corner if unoccupied.
; Entry:   G1blkmove
; Inputs:  None.
; Outputs: A contains the position code for the move, or 0 if there
;          is no move.
;--------------------------------------------------------------------------

G1BM_chkval1	DS	1
		DS	9
		DS	3
		DS	7

G1BM_chkval2	DS	9
		DS	1
		DS	7
		DS	3


G1BM_start	DS	4		; check all 4 possiblities

G1blkmove	XCH	Q
		TS	G1BMSAVQ	; save return address

		XCH	G1BM_start
		TS	G1BMINDX

	; Decrementing loop (loop G1BM_start times)

G1BM_loop	CCS	G1BMINDX	; checked all possibilities?
		TC	G1BM_chkpos	; not yet
		TC	G1BM_nomove	; yes, no recommended move

G1BM_chkpos	TS	G1BMINDX	; index is DABS of G1BMINDX

	; Compare the board positions at chkva1 and chkval2

		INDEX	G1BMINDX
		CAF	G1BM_chkval1	
		TCR	G1getpos	; read the board position into A

		COM			; 1's compliment of A
		AD	ONE		; put (-A) + val in A
		CCS	A		; A = DABS
		TC	G1BM_loop	; >0 (A < val)
		TC	G1BM_chkNext	; +0 (never happens)
		TC	G1BM_loop	; <0 (A > val)
		TC	G1BM_chkNext	; -0 (A == val)

	; The opponent occupies the corner.

G1BM_chkNext	INDEX	G1BMINDX
		CAF	G1BM_chkval2	
		TCR	G1getpos	; read the board position into A

		CCS	A		; opposite corner unoccupied?
		TC	G1BM_loop	; no, go check another position
		INDEX	G1BMINDX	; yes, found the recommended move
		CAF	G1BM_chkval2	
		TC	G1BMSAVQ	; RETURN		

G1BM_nomove	CAF	ZERO		; no recommended move
		TC	G1BMSAVQ	; RETURN
