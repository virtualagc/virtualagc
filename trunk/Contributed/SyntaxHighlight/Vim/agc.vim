" Vim syntax file
" Language:	AGC Assembler
" Maintainer:	Onno Hommes <ohommes@cmu.edu>
" Last Change:	2007 Dec 29

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case ignore

" Common AGC Assembly instructions
syn keyword agcInstruction ADS AD AUG BZF BZMF CAE CAF CA CCS COM
syn keyword agcInstruction CS DAS DCA DCOM DCS DDOUBL DIM DOUBLE
syn keyword agcInstruction DTCB DTCF DV DXCH EDRUPT EXTEND INCR
syn keyword agcInstruction INDEX NDX INHINT LXCH MASK MSK MP MSU
syn keyword agcInstruction NOOP OVSK QXCH RAND READ RELINT RESUME
syn keyword agcInstruction RETURN ROR RXOR SQUARE SU TCR TCAA OVSK
syn keyword agcInstruction TCF TC TS WAND WOR WRITE XCH XLQ XXALQ ZL ZQ

" Any other stuff
syn match agcIdentifier		"[a-z_][a-z0-9_]*"

"Labels
syn match agcLabel		"^[a-z_][a-z0-9_./$]*"

" PreProcessor commands
syn keyword agcDirective	1DNADR
syn keyword agcDirective	2DEC
syn keyword agcDirective	2BCADR
syn keyword agcDirective	2CADR
syn keyword agcDirective	2FCADR
syn keyword agcDirective	2OCT
syn keyword agcDirective	2DNADR
syn keyword agcDirective	3DNADR
syn keyword agcDirective	4DNADR
syn keyword agcDirective	5DNADR
syn keyword agcDirective	6DNADR
syn keyword agcDirective	ADRES
syn keyword agcDirective	BBCON
syn keyword agcDirective	EBANK
syn keyword agcDirective	BANK
syn keyword agcDirective	BNKSUM
syn keyword agcDirective	BLOCK
syn keyword agcDirective	CADR
syn keyword agcDirective	COUNT
syn keyword agcDirective	COUNT*
syn keyword agcDirective	DEC
syn keyword agcDirective	DEC*
syn keyword agcDirective	DNCHAN
syn keyword agcDirective	DNPTR
syn keyword agcDirective	ECADR
syn keyword agcDirective	EQUALS
syn keyword agcDirective	ERASE
syn keyword agcDirective	MEMORY
syn keyword agcDirective	OCT
syn keyword agcDirective	REMADR
syn keyword agcDirective	SETLOC
syn keyword agcDirective	SUBRO

syn match agcInclude	"^\$/B"

" Common strings
syn match agcString		"\".*\""
syn match agcString		"\'.*\'"

" Numbers
syn match agcOctNum		"[0-9]\+"
syn match agcDecNum		"[0-9]\+D"

" Comments
syn match agcComment		"#.*"

syn case match

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_agc_syntax_inits")
  if version < 508
    let did_agc_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink agcSection		Special
  HiLink agcLabel		Label
  HiLink agcSpecialLabel	Label
  HiLink agcComment		Comment
  HiLink agcInstruction		Statement
  HiLink agcInclude		Include
  HiLink agcDirective		PreProc
  HiLink agcOctNum		Number
  HiLink agcDecNum		Number
  HiLink agcString		String

  delcommand HiLink
endif

let b:current_syntax = "agc"
" vim: ts=8
