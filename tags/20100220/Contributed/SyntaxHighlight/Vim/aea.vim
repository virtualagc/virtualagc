" Vim syntax file
" Language:	AGC Assembler
" Maintainer:	Onno Hommes <ohommes@cmu.edu>
" Last Change:	2009 May 5th

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case ignore

" Common AGC Assembly instructions
syn keyword aeaInstruction ADD ADZ SUB SUZ MPY MPR MPZ DVP COM ABS
syn keyword aeaInstruction CLA CLZ LDQ STO STQ ALS LLS LRS TRA TSQ
syn keyword aeaInstruction TMI TOV AXT TIX DLY INP OUT


" Any other stuff
syn match aeaIdentifier		"[a-z_][a-z0-9_]*"

"Labels
syn match aeaLabel		"^[a-z_][a-z0-9_./$]*"

" PreProcessor commands
syn keyword aeaDirective	ORG        
syn keyword aeaDirective	BSS
syn keyword aeaDirective	BES
syn keyword aeaDirective	SYN
syn keyword aeaDirective	EQU
syn keyword aeaDirective	DEFINE
syn keyword aeaDirective	DEC
syn keyword aeaDirective	OCT
syn keyword aeaDirective	END


syn match aeaInclude	"^\$/B"

" Common strings
syn match aeaString		"\".*\""
syn match aeaString		"\'.*\'"

" Numbers
syn match aeaOctNum		"[0-9]\+"
syn match aeaDecNum		"[0-9]\+D"

" Comments
syn match aeaComment		"#.*"

syn case match

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_aea_syntax_inits")
  if version < 508
    let did_aea_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink aeaSection		Special
  HiLink aeaLabel		Label
  HiLink aeaSpecialLabel	Label
  HiLink aeaComment		Comment
  HiLink aeaInstruction		Statement
  HiLink aeaInclude		Include
  HiLink aeaDirective		PreProc
  HiLink aeaOctNum		Number
  HiLink aeaDecNum		Number
  HiLink aeaString		String

  delcommand HiLink
endif

let b:current_syntax = "aea"
" vim: ts=8
