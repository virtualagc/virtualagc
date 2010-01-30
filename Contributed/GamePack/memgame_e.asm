;==========================================================================
; MEMORY GAME
;
; Version:  1.0
; Author:   John Pultorak
; Date:     06/06/2009
;
; PURPOSE:
; Eraseable memory portion of the AGC memory game.
;
; THIS WORK IS PUBLIC DOMAIN.
;
; ERRATA: 
;==========================================================================

G2LIST		DS	0
			DS	0
			DS	0
			DS	0
			DS	0

			DS	0
			DS	0
			DS	0
			DS	0
			DS	0

			DS	0
			DS	0
			DS	0
			DS	0
			DS	0

			DS	0
			DS	0
			DS	0
			DS	0
			DS	0

			DS	0
			DS	0
			DS	0
			DS	0
			DS	0

			DS	0
			DS	0
			DS	0
			DS	0
			DS	0

	; index for insertion onto G2list
	; also keeps count of the items on G2list

G2PUT			DS	0

	; index for displaying G2list

G2GET			DS	0

G2LCNTR2		DS	0

G2NUM			DS	0

G2LSTNUM		DS	0
