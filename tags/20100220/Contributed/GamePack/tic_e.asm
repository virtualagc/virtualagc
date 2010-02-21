;==========================================================================
; TIC-TAC-TOE
;
; Version:  1.0
; Author:   John Pultorak
; Date:     06/06/2009
;
; PURPOSE:
; Eraseable memory portion of the AGC Tic-tac-toe game.
;
; THIS WORK IS PUBLIC DOMAIN.
;
; ERRATA: 
;==========================================================================

G1PLAYRS	DS	0	; 0=one player; 1=two players

G1DSPR1		DS	0	; gameboard
G1DSPR2		DS	0
G1DSPR3		DS	0

	; 0=clear board
	; 1=operator's move
	; 2=AGC's move
	; 3=no move (redisplay gameboard)

G1MODE		DS	0


G1CURMOV	DS	0

G1DSSAVQ	DS	0

G1OIVALU	DS	0
G1OISAVQ	DS	0

G1GTPOS		DS	0
G1GTSAVQ	DS	0

G1STPOS		DS	0
G1STSAVQ	DS	0

G1CTPOS		DS	0
G1CTSAVQ	DS	0

G1AISAVQ	DS	0

G1AMPOS		DS	0
G1AMSAVQ	DS	0

G1CWINDX	DS	0
G1CWVAL		DS	0
G1CWSAVQ	DS	0

G1FMPLYR	DS	0
G1FMINDX	DS	0
G1FMVAL		DS	0
G1FMSAVQ	DS	0

G1BMINDX	DS	0
G1BMSAVQ	DS	0
