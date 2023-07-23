#!/usr/bin/env python3
# Copyright 2019 Ronald S. Burkey <info@sandroid.org>
#
# This file is part of yaAGC. 
#
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# Filename:    	yaASM.py
# Purpose:     	An LVDC assembler, intended to replace yaASM.c for LVDC
#              	(but not for OBC) assemblies. 
# Reference:   	http://www.ibibio.org/apollo
# Mods:        	2019-07-10 RSB  Began playing around with the concept.
#               2019-08-14 RSB	Began working on this more seriously since
#                               the LVDC-206RAM transcription is now available.
#                               Specifically, began adding preprocessor pass.
#               2019-08-22 RSB	I think the preprocessor and discovery passes
#                               are essentially working, except for 
#                               auto-allocation of =... constants.
#               2019-09-18 RSB	Now outputs .sym and .sch files in addition to
#                               the .tsv file that was already being output.
#               2020-04-21 RSB	Began adding the --ptc command-line options
#                               along with --past-bugs and --help.
#               2020-05-01 RSB	Added line number field to .src output file.
#               2020-05-09 RSB	Added the assembled octals for the source lines
#                               to the .src file.  Needed by the debugger for
#                               detecting locations which have been changed by
#                               self-modifying code, and hence whose original
#                               source lines are no longer applicable.
#               2023-04-01 RSB	Now formfeeds in listing file at "Copyright" lines.
#               2023-05-17 RSB	Began looking at fixes for unexpected conditions
#                               in AS-512 source code (vs AS-206RAM).  The 
#                               difference I see far that's a big "gotcha" is
#                               the use of constants in macro argument lists
#                               that are resolvable only after the macro has
#                               been expanded, and not at the time the macro
#                               is defined.  What to do about that, I'm not yet
#                               clear.
#               2023-05-22 RSB  Some incomplete notes on notable changes:
#                               1.  Formerly-monolithic program split into
#                                   several Python modules.
#                               2.  Lots of problems that previously would cause
#                                   abort now insert messages in the listing.
#                               3.  "$SEGMENT" lines (actually, any line with $
#                                   in column 1) are ignored.
#               2023-05-23 RSB  4.  Extraneous "*" and "$" characters in label
#                                   field.
#                               5.  Wrong display in symbol table of DEQD and 
#                                   DEQS constants (inherited from AS-206RAM).
#                               6.  Allowed symbolic labels or asterisk 
#                                   expressions in DOG parameters.
#               2023-05-24 RSB  7.  Removed restrictions on some pseudo-ops
#                                   formerly tagged as PTC-only.
#                               8.  Allowed symbolic labels for TABLE pseudo-op.
#                               9.  Allowed asterisk expressions in ORG 
#                                   parameters.
#               2023-05-25 RSB  10. In symbol-discovery loop, labels for TABLE 
#                                   pseudo-ops now added immediately to symbol 
#                                   table for use by DOG pseudo-ops, rather than
#                                   being handled later in symbol-table loop.
#                                   (All of the fixes above either decreased the
#                                   assembly-time errors by tiny amounts or 
#                                   resulted in big increases.  This change was
#                                   the first resulting in a big decrease: from
#                                   >24K before to <10K after.  Yay!)  Note that
#                                   this doesn't yet implement the exclusion
#                                   properties TABLE is supposed to have.
#                               11. Handles SYN *INS and SYN *DAT.
#               2023-05-26 RSB  12. Handles ORG SYMBOL and ORG SYMBOL1,SYMBOL2.
#               2023-05-27 RSB  13. Created partial implementation for BLOCK
#                                   similar to the one for TABLE (#10 above).
#               2023-06-04 RSB  Fixed incorrect alignment check for VEC and 
#                               MAT.  Corrected DEQD, DEQS. PTC ADAPT Self-Test 
#                               and AS-206RAM continue
#                               to build correctly, though there are 2 less 
#                               warnings for the latter.
#               2023-06-06 RSB  Various fixes.
#               2023-06-09 RSB  Corrected module increment in checkLOC() to 2.
#               2023-06-10 RSB  Several seeming changes in the original compiler
#                               are condition on the --newer CLI switch.
#               2023-06-13 RSB  Replaced used[] boolean structure by ms[] 
#                               integer structure and bit flags msUSED, msTABLE,
#                               msBLOCK, msLITERAL.
#               2023-06-15 RSB  Restored used[] structure (in place of ms[]),
#                               eliminating associated bit flags, but now named 
#                               memUsed[] instead of just used[].
#               2023-06-17 RSB  Various fixes, such as correct sector for using
#                               an instruction location as the operand of a 
#                               data instruction like CLA or STO.
#               2023-06-19 RSB  Fixed SYN *DAT, I think.  There's also similar
#                               scaffolding in place for SYN *INS, but I'm
#                               unsure it's needed, so it's disabled.  Fixed
#                               my previous fix for allocateNameless, which had
#                               its conditional reversed for the residual
#                               sector.
#               2023-06-21 RSB  Now extracts page titles from TITLE directives,
#                               and prints those titles (along with page 
#                               numbers) in the page headers of assembly 
#                               listings.
#               2023-07-02 RSB  Accounted for the occasional trailing ' found
#                               in "=H'..." constructs in AS-513.
#               2023-07-04 RSB  Added WORK FLOOR and WORK CDS.  Corrected 
#                               data-sector assumptions for reuse of HOPs with 
#                               TMI*/TNZ*.  Various other fixes needed for 
#                               AS-513.
#               2023-07-06 RSB  More of the same.  *Almost* working fully now.
#                               Also added constant table to assembly listing.
#               2023-07-07 RSB  Partially handled rounding problem, reducing
#                               total number of rounding mismatches in 
#                               AS-512 + AS-513 from 19 + 11 to 5 + 1; i.e.,
#                               an 80% reduction.
#               2023-07-14 RSB  Eliminated FLOW directives.
#               2023-07-21 RSB  Printing of + expansions enabled (except within
#                               macro expansions).  Began implementing --html.
#               2023-07-22 RSB  In the assembly listing, eliminated certain 
#                               Warning messages and replaced others by W in
#                               in column 1, to match original assembler.
#                               Fixed printed address fields following automatic
#                               sector change.  Tables at the end of the listing
#                               are now printed in columns to save space.  Fixed
#                               links to constants in expressions.
#               2023-07-23 RSB  Clip printout lines.  Added flowchart links
#                               to HTML listings.
#
# Regardless of whether or not the assembly is successful, the following
# additional files are produced at the end of the assembly process:
#
#	yaASM.tsv	An octal-listing file.
#
#	yaASM.sym	A symbol file.
#
#	yaASM.src	A source file.
#
# These 3 output files basically duplicate the information in the output
# assembly-listing file, but are formatted more-suitably for machine-reading.
# They are intended for use by the yaLVDC program, which as an LVDC emulator.
# In spite of the naming, they are *all* TSV files, and what they provide will
# be pretty obvious in examining one of them.  The only tricky aspects are
# these:
#   1.	The fields in the .tsv file are empty for unused locations.
#   2.  The fields in the .tsv file that define the value of a memory location
#	(when not empty) have either the format "%05o %05o" (for instructions) 
#	or " %09o " (for data), so the parser must detect which format is 
#	used in order to interpret the data.
#   3.  In the .sym file, symbols for code areas have either syllable 0 or 1,
#	while those for data areas have syllable 2 (which means that the
#	value spans both syllables 0 and 1).
#   4.	In addition to symbols, the .sym file also gives the locations for 
#	automatically-allocated nameless constants, using their "%09o"
#	representations as symbol names.  Since the same nameless constant may
#	appear in several sectors, they may also appear multiple times in the
#	file, whereas actual symbolic names can only appear once.
#   5.  The .src file gives source lines that are post-preprocessing; moreover,
#	their tabs are expanded to the appropriate number of spaces, so even
#	though the original source lines may have included tabs, each of them
#	nevertheless appears in the .src file as a single field.
#
# It is also possible to optionally have an octal-listing file -- i.e, a
# file formatted like yaASM.tsv -- as in input.  If so, it does not affect
# the assembly process at all, but is used for checking purposes and for 
# marking lines in the output assembly listing which disagree with OCTALS.tsv.
# No separate binary file of octals is produced; the yaASM.tsv file, which 
# is tab-delimited ASCII, should be parsed instead if required for (for example)
# an LVDC simulator.

import sys
import copy
import re
# The next line imports expression.py.
from yaASMerrors import *
from yaASMexpression import *
from yaASMdefineMacros import *
from yaASMpreprocessor import preprocessor, unlistSuffix
#import arithmeticIBM

'''
Here's an explanation of the overall structure of the assembler.

Pass 0:		Read in all of the source code and store it in the lines[] array.
			There are additional arrays of the same length that will correlate
			processed data to the original source lines throughout the assembly
			process's subsequent passes:
				errors[]		Lists all error, warning, info messages.  Each
								entry is an ordered pair (nn, msg), where
								msg is the error message (a string) and for 
								errors[n], nn is an index into 
								expandedLines[n][].
				expandedLines[]	As the processing proceeds, macros may be 
								expanded, causing an original source line to
								turn into multiple lines of code.  The entries
								are themselves arrays of lines.  Initially,
								each of these lists contains a single line,
								but that changes as processing proceeds later.
Pass 1:		Find all MACRO/ENDMAC definitions in the lines[] array, and store
			them in a dictionary called macros{}.
Pass 2:		Preprocessor.  Handles all of the following, by modifying the
			expandedLines[] array: EQU, REQ, TELD, expansion of TELM,
			expansion of CALL, expansion of SHL and SHR, expansion of macros,
			conditional blocks, evaluation of all parenthesized expressions.
			Constants (defined by EQU and possibly modified by REQ) are stored
			in the constants{} dictionary.  Note, however, that *all* uses of
			constants (and macros) are handled by the preprocessor, and thus
			constants{} and macros{} are irrelevant to subsequent passes.
			Note also that preprocessing is an iterative process, in that 
			macro expansions may contain other macro expansions and/or 
			conditional blocks.  Moreover, the values of constants may change
			throughout the preprocessing, as REQs are encountered.
			All all constants or macros are required to have been defined prior
			to any use of them.
Pass 3:		Symbol-table generation.  This pass determines locations for all
			symbols (other than those representing constants and macros).
			It must handle pseudo-ops such as ORG, as well as modifications 
			related to HOP*, TRA*, TMI*, TNZ*, BLOCK, TABLE, and insertion of
			automatic jumps at the ends of sectors.
Pass 4:		Assembly and output.  

'''

#----------------------------------------------------------------------------
#	Definitions of global variables.
#----------------------------------------------------------------------------
# Array for keeping track of which memory locations have been used already, 
# and other memory characteristics.
memUsed = [[[[False for offset in range(256)] for syllable in range(2)] \
			for sector in range(16)] for module in range(8)]

# BA8421 character set in its native encoding.  All of the unprintable
# characters are replaced by '?', which isn't a legal character anyway.
# Used only for --ptc.
BA8421 = [
	' ', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', '0', '#', '@', '?', '?', '?',
	'?', '/', 'S', 'T', 'U', 'V', 'W', 'X',
	'Y', 'Z', '‡', ',', '(', '?', '?', '?',
	'-', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', '?', '$', '*', '?', '?', '?',
	'+', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
	'H', 'I', '?', '.', ')', '?', '?', '?'
]
# EBCDIC-like character table.  The table has been massaged, and in particular 
# shifted to a different numerical range, in such a way to as to make
# it convenient for the purposes of this program, so it's not really EBCDIC
# any longer.  Only the 0x40-0x7F and 0xC0-0xFF ranges have been reproduced.
# They have been merged (with printable characters overriding unprintable ones) 
# into a single 0x00-0x3F range.  All unprintable positions left over after 
# that have been set to '!'.  I guess that it probably makes more sense to 
# consider it as just a substitution table representing buggy original-assembler
# printout, rather than thinking of it as EBCDIC at all, although there are 
# entries in the table (deriving from EBCDIC) that are not actually used by
# the assembler.  Used only for --ptc --past-bugs.
EBCDIClike = [
	'0', '1', '2', '3', '4', '5', '6', '7', 
	'8', '9', '0', '!', '!', "'", '=', '"',
	' ', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 
	'H', 'I', '!', '.', ')', '(', '+', '!',
	'&', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 
	'Q', 'R', '!', '!', '*', ')', ';', '!',
	' ', '/', 'S', 'T', 'U', 'V', 'W', 'X', 
	'Y', 'Z', '!', ',', '(', '_', '>', '?'
]
# Characters which are printable in both BA8421 and EBCDIC.
legalCharsBCI = set(BA8421).intersection(set(EBCDIClike))

def bciPad(string):
	while len(string) % 4 != 0:
		string = string + " "
	if string[-2:] != "  ":
		string = string + "    "
	return string

# Some modifications to the following are made later,
# after the command line arguments have been parsed
# to detect presence or absence of --ptc.
operators = {
    "HOP": { "opcode":0b0000 }, 
    "MPY": { "opcode":0b0001 }, 
    "PRS": { "opcode":0b0001 }, 
    "SUB": { "opcode":0b0010 }, 
    "DIV": { "opcode":0b0011 }, 
    "TNZ": { "opcode":0b0100 }, 
    "MPH": { "opcode":0b0101 }, 
    "CIO": { "opcode":0b0101 }, 
    "AND": { "opcode":0b0110 }, 
    "ADD": { "opcode":0b0111 },
    "TRA": { "opcode":0b1000 }, 
    "XOR": { "opcode":0b1001 }, 
    "PIO": { "opcode":0b1010 }, 
    "STO": { "opcode":0b1011 }, 
    "TMI": { "opcode":0b1100 }, 
    "RSU": { "opcode":0b1101 }, 
    "CDS": { "opcode":0b1110, "a9":0 }, 
    "CDSD": { "opcode":0b1110, "a9":0 }, 
    "CDSS": { "opcode":0b1110, "a9":0 }, 
    "SHF": { "opcode":0b1110, "a9":1, "a8":0 }, 
    "EXM": { "opcode":0b1110, "a9":1, "a8":1 },
    "CLA": { "opcode":0b1111 }, 
    "SHR": { "opcode":0b1110, "a9":1, "a8":0 }, 
    "SHL": { "opcode":0b1110, "a9":1, "a8":0 }
}
pseudos = []
preprocessed = ["EQU", "IF", "ENDIF", "MACRO", "ENDMAC", "FORM", "TELD", "REQ",
			"SPACE", "UNLIST", "LIST"]
ignore = ["TITLE"]

# Bit patterns used by DFW pseudo-ops. The key value is the DS.
dfwBits = {
	0o04: { "a2": 0, "a1": 0, "a9": 0 },
	0o14: { "a2": 0, "a1": 0, "a9": 1 },
	0o05: { "a2": 0, "a1": 1, "a9": 0 },
	0o15: { "a2": 0, "a1": 1, "a9": 1 },
	0o06: { "a2": 1, "a1": 0, "a9": 0 },
	0o16: { "a2": 1, "a1": 0, "a9": 1 },
	0o07: { "a2": 1, "a1": 1, "a9": 0 },
	0o17: { "a2": 1, "a1": 1, "a9": 1 }
}

expandedLines = []
constants = {}
macros = {}
inMacro = ""
inFalseIf = False

inputFile = []
IM = 0
IS = 0
S = 1
LOC = 0
DM = 0
DS = 0
dS = 0
DLOC = 0
useDat = False
lineNumber = 0
forms = {}
synonyms = {}
nameless = {}
lastORG = False
inDataMemory = True
symbols = {}
lastLineNumber = -1
roofWorkarounds = []
floorWorkarounds = []
blockWorkarounds = []
cdsWorkarounds = set()
incWorkarounds = []
decWorkarounds = []

# Array for keeping track of assembled octals
octals = [[[[None for offset in range(256)] for syllable in range(3)] for sector in range(16)] for module in range(8)]
octalsForChecking = [[[[None for offset in range(256)] for syllable in range(3)] for sector in range(16)] for module in range(8)]
checkTheOctals = False

countRollovers = 0

checkFilename = ""
ptc = False
pastBugs = False
ignoreResiduals = False
debugRoof = 0
ceiling = 0o1000
newer = False
allowUnlist = True
fuzzy = False
synFix = True
htmlFile = None
flowchartFolder = ""
for arg in sys.argv[1:]:
	if arg[:2] == "--":
		if arg == "--ptc":
			ptc = True
		elif arg == "--past-bugs":
			pastBugs = True
		elif arg == "--ignore-residuals":
			ignoreResiduals = True
		elif arg.startswith("--debug-roof="):
			debugRoof = int(arg.removeprefix("--debug-roof="))
		elif arg.startswith("--ceiling="):
			ceiling = int(arg.removeprefix("--ceiling="), 8)
		elif arg == "--newer":
			newer = True
		elif arg == "--no-unlist":
			allowUnlist = False
		elif arg == "--fuzzy":
			fuzzy = True
		elif arg == "--no-syn-fix":
			synFix = False
		elif arg == "--html":
			htmlFile = open("yaASM.html", "w")
		elif arg.startswith("--flowcharts="):
			flowchartFolder = arg[13:]
		elif arg == "--help":
			print("Usage:", file=sys.stderr)
			print("\tyaASM.py [OPTIONS] [OCTALS.tsv] <INPUT.lvdc >OUTPUT.listing", file=sys.stderr)
			print("The OPTIONS are", file=sys.stderr)
			print("\t--help -- to print this message.", file=sys.stderr)
			print("\t--html -- create syntax-highlighted listing.", file=sys.stderr)
			print("\t--flowcharts=D -- flowchart folder for html.", file=sys.stderr)
			print("\t--newer -- assemble for AS-512/513 rather than AS-206RAM.", file=sys.stderr)
			print("\t--ceiling=n -- (leave at default 1000) octal limit forward TNZ/TMI distance.", file=sys.stderr)
			print("\t--no-unlist -- (debugging) option to ignore UNLIST directives.", file=sys.stderr)
			print("\t--fuzzy -- (debugging) in octal-mismatch check, ignore rounding error.", file=sys.stderr)
			print("\t--no-syn-fix -- (debugging) do not fix SYN *DAT and SYN *INS.", file=sys.stderr)
			print("\t--debug-roof=n -- debug automatic sector changes to level n>0.", file=sys.stderr)
			print("\t--ptc -- to use PTC source/octal input rather than the default LVDC.", file=sys.stderr)
			print("\t--past-bugs -- only with --ptc, reproduces some original assembler bugs.", file=sys.stderr)
			print("\t--ignore-residuals -- (debug) for --ptc octal checks, ignore residual flag.", file=sys.stderr)
			print("Files produced by the assembly are:", file=sys.stderr)
			print("\tyaASM.tsv\tAn octal-listing file.", file=sys.stderr)
			print("\tyaASM.sym\tA symbol file.", file=sys.stderr)
			print("\tyaASM.src\tA source file.", file=sys.stderr)
			sys.exit(0)
		else:
			print("Unknown command-line option " + arg, file=sys.stderr)
			sys.exit(1)
	else:
		module = -1
		sector = -1
		offset = -1
		try:
			checkFilename = arg
			f = open(checkFilename, "r")
			for line in f:
				line = line.strip()
				if line[:1] == "#" or len(line) == 0:
					continue
				fields = line.split("\t")
				if len(fields) == 0:
					continue
				if fields[0] == "SECTOR":
					module = int(fields[1], 8)
					sector = int(fields[2], 8)
					if module > 7 or sector > 15:
						raise("Warning: module or sector out of range (%o %02o)" % (module, sector))
					continue
				offset = int(fields[0], 8)
				# Note that the format of the data lines from the input file differs
				# depending on whether the file is based on the PAST program listing
				# (PTC) or the AS206-RAM Flight Program listing (LVDC).
				if ptc:
					if len(fields) != 9:
						raise("Warning: wrong number of fields (%d, must be 9)" % len(fields))
					for n in range(1, 9):
						entry = fields[n].strip()
						if entry == "":
							continue
						if len(entry) != 12 or not entry.isdigit():
							raise("Warning: octal value is corrupted (%s)" % entry)
						value = int(entry, 8)
						valid = value & 0o777
						value = value >> 9
						if valid > 3:
							raise("Validity bits incorrect")
						# Unfortunately, the PTC octal format cannot distinguish between
						# data areas vs instruction areas as the LVDC octal format can,
						# so we have to treat the octals as both.  While we can correctly
						# deduce _some_ of that, we can't correctly deduce all of it, so
						# we just have to rely on some fancier test logic farther down
						# in the process.  (Specifically, if both syl0 and syl1 are valid,
						# we can't tell if that's one data value or two instructions. I
						# think all other cases are distinguishable.)
						if valid != 3:
							octalsForChecking[module][sector][2][offset] = None
						else:
							octalsForChecking[module][sector][2][offset] = value
						syl1 = (value >> 12) & 0o77774
						syl0 = value & 0o37776
						if (valid & 2) == 0:
							if syl1 != 0:
								raise("Warning: syllable 2 should be 0 (%o %02o %03o)" % (module, sector, offset))
							syl1 = None
						if (valid & 1) == 0:
							if syl0 != 0:
								raise("Warning: syllable 1 should be 0 (%o %02o %03o)" % (module, sector, offset))
							syl0 = None
						octalsForChecking[module][sector][1][offset] = syl1
						octalsForChecking[module][sector][0][offset] = syl0
						offset += 1
				else:
					ptr = 1
					for count in range((len(fields) - 1) // 2):
						if len(fields[ptr]) != 11:
							raise("Warning: wrong field length")
						elif fields[ptr].strip() == "" and fields[ptr + 1].strip() == "":
							# An unused word.
							pass
						elif fields[ptr + 1] == "D" and fields[ptr][0] == " " and fields[ptr][-1] == " " and fields[ptr][1:-2].isdigit():
							# A data word.
							value = int(fields[ptr].strip(), 8)
							octalsForChecking[module][sector][2][offset] = value
						elif fields[ptr + 1] == "D" and (fields[ptr][:5] == "     " or fields[ptr][:5].isdigit()) \
							and fields[ptr][5] == " " and (fields[ptr][6:] == "     " or fields[ptr][6:].isdigit()):
							# An instruction-pair word.
							syl1 = fields[ptr][:5]
							syl0 = fields[ptr][6:]
							if syl1.strip() != "":
								value = int(syl1, 8)
								octalsForChecking[module][sector][1][offset] = value
							if syl0.strip() != "":
								value = int(syl0, 8)
								octalsForChecking[module][sector][0][offset] = value
						else:
							raise("Warning: unrecognized format: " + line)	
						ptr += 2
						offset += 1
			f.close()
			checkTheOctals = True
		except:
			counts["warnings"] += 1
			print("Warning (%o %02o %03o): Cannot open octal-comparison file %s or file is corrupted" \
					% (module, sector, offset, checkFilename))
			checkFilename = ""
#print(octalsForChecking)
if ptc:
	del operators["MPY"]
	del operators["MPH"]
	del operators["DIV"]
	del operators["EXM"]
	operators["SHF"]["a9"] = 0
	operators["SHL"]["a9"] = 0
	operators["SHR"]["a9"] = 0
	operators["XOR"] = operators["RSU"].copy()
	operators["RSU"]["opcode"] = 0b0011
else:
	del operators["PRS"]
	del operators["CIO"]

# Write out header to html file and store up lines for footer of html file to
# use later.
if htmlFile != None:
	template = open(sys.path[0] + "/template.html", "r")
	for line in template:
		if line.startswith("<!--"):
			break
		print(line, end="", file=htmlFile)
	for line in template:
		if line.startswith("<!--"):
			break
	htmlFooterLines = []
	for line in template:
		htmlFooterLines.append(line)
	template.close()
	print('<a id="source"></a><h1>Assembly Listing</h1>', file=htmlFile)

# The following structures are used for tracking instructions transparently
# inserted at the ends of syllable 1 of memory sectors by the assembler when
# TMI or TNZ instruction targets not in the current sector.  In those cases,
# the TMI or TNZ is made to jump to the end of the current sector, where they
# will find a HOP instruction to the desired target.  The roofAdders and 
# roofRemovers structures are used during the Discovery pass to figure out 
# how many locations need to be reserved at the ends of the sectors for 
# such stuff, whereas, the roofed structure tracks which target locations are
# associated with which of the inserted HOPs (which is info that's needed if
# more than one TMI or TNZ uses the same target).
roofAdders = []
roofRemovers = []
roofed = []
for n in range(8):
	roofAdders.append([])
	roofRemovers.append([])
	roofed.append([])
	for m in range(16):
		roofAdders[n].append({})
		roofRemovers[n].append(set())
		roofed[n].append([])

# The following function handles adding a symbol to the roofAdders[] structure.
# Used only during the symbol-discovery pass.
def addAdder(symbol, IM, IS, S, LOC, DM, DS):
	global roofAdders
	if symbol not in roofAdders[IM][IS]:
		roofAdders[IM][IS][symbol] = [S, LOC, DM, DS]

# The following function handles adding a symbol to the roofRemovers[] 
# structure.  Used only during the symbol-discovery pass.
def addRemover(symbol, IM, IS, S, LOC, DM, DS):
	global roofRemovers
	if symbol not in roofRemovers[IM][IS]:
		if symbol in roofAdders[IM][IS]:
			addedAt = roofAdders[IM][IS][symbol]
			if newer and (DM != addedAt[2] or DS != addedAt[3]):
				return
			if ceiling < 0o1000: # I don't think this should ever occur.
				distance = (0o400 * S + LOC) - (0o400 * addedAt[0] + addedAt[1])
				if distance >= ceiling:
					return
		roofRemovers[IM][IS].add(symbol)

lines = sys.stdin.readlines()
n = 0
while n < len(lines):
	if lines[n].strip() == "":
		del lines[n]
		continue
	line = lines[n].expandtabs().rstrip()
	# Eliminate any line with the FLOW directive in it.
	if line[0] == " " and line.lstrip().startswith("FLOW"):
		del lines[n]
		continue
	
	# In AS-512, columns 2-5 sometimes have a "random" (meaning we can't figure
	# out what they mean) sprinkling of "*" and "$" characters that seem to 
	# have nothing to do with how the lines are actually assembled.  I probably
	# should retain them somehow for printing in the output assembly listing,
	# but for now I just get rid of them.
	if len(line) >= 6 and line[0] == " " and not line[1:6].isspace():
		line = "      " + line[6:]
	lines[n] = line
		
	if ptc and 'BCI' in lines[n] and '^' in lines[n] and '$' in lines[n]:
		# Convert all spaces within a BCI pseudo-op's operand to
		# '_', so that the line can be parsed properly into
		# fields later.  Any character not in the BA8421 character
		# set could be used.
		p = lines[n].index('BCI')
		a = lines[n].index('^')
		b = lines[n].index('$')
		if p < a and a < b:
			lines[n] = lines[n][:a] + lines[n][a:b].replace(' ', '_') + lines[n][b:]
	
	n += 1

#----------------------------------------------------------------------------
#	Definitions of utility functions
#----------------------------------------------------------------------------

def incDLOC(increment = 1, mark = True):
	global DLOC, used
	while increment > 0:
		increment -= 1
		DLOC1 = DLOC + 1
		if DLOC < 0o400 and mark:
			memUsed[DM][DS][0][DLOC] = True
			memUsed[DM][DS][1][DLOC] = True
			if increment == 0 and \
					(DLOC == 0o377 or sectorTopData[DM][DS] == DLOC1):
				top = DLOC
				while top > 0 and memUsed[DM][DS][1][top-1]:
					top -= 1
				sectorTopData[DM][DS] = top
		DLOC = DLOC1

# This function checks to see if a block of the desired size is 
# available at the currently selected DM/DS/DLOC, and if not,
# increments DLOC until it finds the space.
def findDLOC(start = 0, increment = 1):
	n = start
	length = 0
	reuse = False
	while n < 0o400 and length < increment:
		syl0 = memUsed[DM][DS][0][n]
		syl1 = memUsed[DM][DS][1][n]
		used = syl0 or syl1
		if used:
			n += 1
			length = 0
			reuse = True
			continue
		if length == 0:
			start = n
		n += 1
		length += 1
	if reuse:
		addError(lineNumber, \
				"Warning: Skipping memory locations already used (%o-%02o-%03o)" \
				% (DM, DS, n))
	if length < increment or start + length > 0o400:
		addError(lineNumber, \
				"Error: No space of size %d found in memory bank (%o-%02o)" \
				% (increment, DM, DS))
	return start
	
def checkDLOC(increment = 1):
	global DLOC
	DLOC = findDLOC(start=DLOC, increment=increment)

def incLOC():
	global LOC, DLOC, dS, used
	try:
		if useDat:
			if DLOC < 256:
				memUsed[DM][DS][dS][DLOC] = True
			dS = 1 - dS
			if dS == 1:
				DLOC += 1
		else:
			if LOC < 256:
				memUsed[IM][IS][S][LOC] = True
			LOC += 1
	except:
		return

# Find out the last usable instruction location in a sector,
# because _some_ TMI or TMZ instructions need an extra word
# at the top of syllable 1.  The assembler is going to automatically
# shove a HOP into this location if an automatic syllable switch
# occurs.
getRoofReported = [[[[[] for offset in range(256)] for syllable in range(2)] \
		for sector in range(16)] for module in range(8)]
sectorTopData = []
for i in range(8):
	sectorTopData.append([0o400]*16)
def getRoof(imod, isec, syl, loc, extra):
	global getRoofReported
	roof = sectorTopData[imod][isec] - 1
	# This is purely ad-hoc.  For AS-512, at 4-17-0-374 and at 6-17-0-374,
	# the original assembler inserted a sector change for no reason I can 
	# see. There's no data being avoided.  I figure (well, hope) that
	# it means that the assembler reserved a few words at the ends
	# of residual sectors into which it wouldn't put instructions.  In
	# point of fact, the final three words (both syllables) are unused
	# in every residual sector in every available LVDC program 
	# (PTC-ADAPT-SELF-TEST-PROGRAM, AS-206RAM, AS-512, and AS-153)
	# processed by the original assembler, although the two addresses I
	# just mentioned are the only ones that caused me a problem.
	if isec == 0o17 and roof >= 0o375:
		roof = 0o374
	if syl == 0:
		# No space needs to be reserved in syllable 0.
		needed = set()
		numNeeded = 0
	else:
		# In syllable 1, the default amount of reserved
		# space is 3 words:  0o377 and 0o376 can be used by
		# TNZ and TMI, but 0o375 is never used for any instructions,
		# as far as I can see.  Because of that, if less 
		# than 2 words is needed by TMI/TNZ, the amount of
		# reserved space can't be reduced.  But if more than
		# 2 words are needed by TMI or TNZ, we can add them 
		# below 0o375.  However, there are some cases in which a
		# data word has been written to 0o375, and we have to 
		# detect that case.
		needed = set(roofAdders[imod][isec]) - roofRemovers[imod][isec]
		numNeeded = len(needed)
		if roof == 0o377:
			roof = 0o374
			if numNeeded > 2:
				roof -= (numNeeded - 2)
		elif roof == 0o376:
			roof = 0o374
			if numNeeded > 1:
				roof -= (numNeeded - 1)
		elif roof == 0o375:
			roof == 0o374 - numNeeded
		else:
			roof -= numNeeded
	if extra > 0:
		extra -= 1
	roof -= extra
	if debugRoof == 1:
		getRoofReported[imod][isec][syl][loc] = [roof, numNeeded]
	elif debugRoof == 2:
		getRoofReported[imod][isec][syl][loc] = [roof, numNeeded,
										str(sorted(roofAdders[imod][isec])),
										str(sorted(roofRemovers[imod][isec])),
										str(sorted(needed))]
	parameters = (imod, isec, syl, loc)
	if parameters in roofWorkarounds:
		roof -= 1
	if parameters in floorWorkarounds:
		roof += floorWorkarounds.count(parameters)
	return roof

# This function is an attempt to mutilate (oops, I meant "round") fixed-point
# and floating-point decimal numbers in a manner similar to that used by the
# original assembler.
def normalizeDecimal(decimal):
	# The theory here is that the original assembler normalized numbers before 
	# converting them to octal form in the following manner:
	#	1.	Put them into the form 0.nnnn...Emm.
	#	2.	Round so that the number of fraction digits (the n's) is exactly 8.
	#		(In spite of the fact that both the computer running the assembler
	#       and the LVDC itself had a slightly-higher precision than that.)
	# This notion comes from the fact that the assembler always prints the
	# numbers in this format in the assembly listings, and that it works in the
	# few cases I've tried it with.
	# We don't actually need to duplicate this completely, since the form
	# n.nnnnnnnEmm works equally well for us, as long as the leading n is not 0.
	#decimal = arithmeticIBM.fromIBM(arithmeticIBM.toIBM(decimal))
	return float("%.7e" % decimal)

# Convert a numeric literal to LVDC binary format.  I accept literals of the forms:
#	if isOctal == False:
#		O + octal digits
#		float + optional Bn
#		decimal + Bn + optional En
#	if isOctal == True:
#		octal digits
# Returns a string of 9 octal digits, or else "" if error.
def convertNumericLiteral(lineNumber, n, isOctal = False):
	if isOctal or n[:1] == "O":
		if isOctal:
			constantString = n[0:]
		else:
			constantString = n[1:]
		if len(constantString) > 9 or len(constantString) == 0:
			return ""
		for c in constantString:
			if c not in ["0", "1", "2", "3", "4", "5", "6", "7"]:
				return ""
		while len(constantString) < 9:
			constantString += "0"
	else:
		# The decimal-number case.
		# The following manipulations try to produce two strings called
		# "decimal" (which includes the decimal portion of the number, 
		# including sign, decimal point, and En exponent) and "scale"
		# (which is just the Bn portion).  The trick is that the En may
		# follow the Bn in the original operand.
		decimal = n[0:]
		scale = "B26"
		isInt = True
		if "." in decimal or "E" in decimal:
			isInt = False
		if "B" in decimal:
			isInt = False
			whereB = decimal.index("B")
			scale = decimal[whereB:]
			decimal = decimal[:whereB]
			if "E" in scale:
				whereE = scale.index("E")
				decimal += scale[whereE:]
				scale = scale[:whereE]
		elif newer:
			try:
				decimal = "%d" % hround(decimal)
			except:
				addError(lineNumber, \
						"Implementation: Non-decimal expression: " + decimal)
				decimal = "0"
			isInt = True
		try:
			if not isInt:
				decimal = float(decimal)
				scale = int(scale[1:])
				if newer:
					decimal = normalizeDecimal(decimal)
				value = hround(decimal * pow(2, 27 - scale - 1 - 1)) << 1
			else:
				decimal = int(decimal)
				scale = int(scale[1:])
				value = hround(decimal * pow(2, 27 - scale))
			if value < 0:
				value += 0o1000000000
			constantString = "%09o" % value
		except:
			addError(lineNumber, "Error: Cannot compute constant expression " + str(n))
			return ""	
	if (DM,DS,DLOC) in incWorkarounds:
		constantString = "%09o" % (2 + int(constantString, 8))
	elif (DM,DS,DLOC) in decWorkarounds:
		constantString = "%09o" % (-2 + int(constantString, 8))
	return constantString

# Note: By a "nameless memory location", I mean the same thing as what I believe
# was known as "literal memory" in LVDC lingo.  I'm just guessing, of course,
# since there's no surviving documentation about LVDC assembly language.  This
# function allocates/stores a nameless memory location, returning its offset
# into the sector, and a residual (0 if in sector specified or 1 if in residual
# sector).  There are various reasons why this might be done:  for "=..." 
# operands, for HOP*, for TRA*, for TMI*, for TNZ*, and for sector changes.
# Later: Use has been extended, for --ptc, to automatic allocation of 
# named variables from their implicit usage as operands in some instructions.
# Still later:  No, automatic allocation of named variables for --ptc has to be done
# earlier in the process than this, since if it's done here, the locations the
# variables are supposed to go into have already been allocated.  Fortunately,
# there's no code here that needs to be backed out.
allocationRecords = []	# For debugging ordering of named and nameless allocationis.
def allocateNameless(lineNumber, constantString, \
					useResidual = True, searchResidual = True):
	global nameless, allocationRecords, used
	value = "%o_%02o_%s" % (DM, DS, constantString)
	valueR = "%o_17_%s" % (DM, constantString)
	if value in nameless:
		return nameless[value],0
	if searchResidual and DS != 0o17:
		if valueR in nameless:
			return nameless[valueR],1
	for loc in range(0o400):
		location = (DM, DS, loc)
		try:
			syl0 = memUsed[DM][DS][0][loc]
			syl1 = memUsed[DM][DS][1][loc]
			used = syl0 or syl1
			if not used:
				if False:
					addError(lineNumber, "Info: Allocation of nameless " + value)
				memUsed[DM][DS][0][loc] = True
				memUsed[DM][DS][1][loc] = True
				octals[DM][DS][2][loc] = 0
				nameless[value] = loc
				allocationRecords.append({ "symbol": value, "lineNumber":lineNumber, 
					"inputLine": inputFile[lineNumber]["expandedLine"], 
					"DM": DM, "DS": DS, "LOC": loc })
				return loc,0
		except:
			addError(lineNumber, 
					"Error: Nameless allocation to %o-%02o-%03o" % (DM, DS, loc))
			return 0,0
	if useResidual and DS != 0o17:
		for loc in range(0o400):
			location = (DM, 0o17, loc)
			try:
				syl0 = memUsed[DM][0o17][0][loc]
				syl1 = memUsed[DM][0o17][1][loc]
				used = syl0 or syl1
				if not used:
					if False:
						addError(lineNumber, "Info: Allocation of nameless " + valueR)
					memUsed[DM][0o17][0][loc] = True
					memUsed[DM][0o17][1][loc] = True
					octals[DM][0o17][2][loc] = 0
					nameless[valueR] = loc
					allocationRecords.append({ "symbol": valueR, "lineNumber":lineNumber, 
						"inputLine": inputFile[lineNumber]["expandedLine"], 
						"DM": DM, "DS": DS, "LOC": loc })
					return loc,1
			except:
				addError(lineNumber, 
						"Error: Nameless allocation to %o-17-%03o" % (DM, loc))
				return 0,0
	addError(lineNumber, "Error: No remaining memory to store nameless constant (" + value + ")")
	return 0,0

# This function finds the next location available for storing instructions.
# If we determine that an automatic switch to a different memory sector is
# needed, we return an array [oldIM,oldIS,oldS,oldLOC,newIM,newIS,newS,newLOC]
# containing enough info to create a TRA or HOP instruction to the starting
# location in the new sector. Hopefully the calling routine can figure out 
# something sensible to do with the returned array.
def checkLOC(extra = 0):
	global LOC
	global IM
	global IS
	global S
	global DLOC
	if ptc and lastORG:
		return []
	if useDat:
		# This is the "USE DAT" case. 
		if DLOC >= 256:
		 	addError(lineNumber, "Error: No room left in memory sector")
		elif dS == 1 and (memUsed[DM][DS][0][DLOC] or memUsed[DM][DS][1][DLOC]):
			tLoc = DLOC
			addError(lineNumber, \
					"Warning: Skipping memory locations already used (%o-%02o-%03o)" \
					% (DM, DS, DLOC))
			while tLoc < 256 and dS == 1 \
					and (memUsed[DM][DS][0][tLoc] or memUsed[DM][DS][1][tLoc]):
				tLoc += 1
			if tLoc >= 256:
				addError(lineNumber, \
						"Error: No room left in memory sector (%o-%02o)" \
						% (DM, DS))
			else:
				DLOC = tLoc
				return []
		return []
	else:
		# This is the "USE INST" case.
		autoSwitch = False
		try:
			if not lastORG and LOC < 256:
				nextUsed = memUsed[IM][IS][S][LOC]
			else:
				nextUsed = False
		except:
			addError(lineNumber, \
					"Error: Space-check failed %o-%02o-%o-%03o" \
						% (IM, IS, S, LOC))
			return []
		if not lastORG and (LOC >= 256 or nextUsed):
			# If the current location is already used up, we're out
			# of luck since there's no room to even insert a TRA or HOP.
			addError(lineNumber, "Error: No memory available at current location")
			return []
		roof = getRoof(IM, IS, S, LOC, extra)
		try:
			if LOC < roof:
				nextUsed = memUsed[IM][IS][S][LOC + 1]
			else:
				nextUsed = False
		except:
			addError(lineNumber, \
					"Error: Space-check failed %o-%02o-%o-%03o" \
						% (IM, IS, S, LOC+1))
			return []
		if LOC >= roof or nextUsed:
			# Only one word available here, just insert TRA or HOP.  However, we need
			# to find address for the TRA or HOP to take us to, always searching
			# upward.
			if lastORG:
				addError(lineNumber, \
						"Warning: Skipping memory locations already used (%o-%02o-%o-%03o)" \
						% (IM, IS, S, LOC + 1))
			else:
				memUsed[IM][IS][S][LOC] = True
				autoSwitch = True
			tLoc = LOC
			tSyl = S
			tSec = IS
			tMod = IM
			while True:
				roof = getRoof(tMod, tSec, tSyl, tLoc, extra)
				if tLoc < roof and not memUsed[tMod][tSec][tSyl][tLoc] \
						and not memUsed[tMod][tSec][tSyl][tLoc + 1]:
					if autoSwitch:
						retVal = [IM, IS, S, LOC, tMod, tSec, tSyl, tLoc]
					else:
						retVal = []
					IM = tMod
					IS = tSec
					S = tSyl
					LOC = tLoc
					return retVal
				tLoc += 1
				if tLoc >= roof:
					tLoc = 0
					tSyl += 1
					if tSyl >= 2:
						tSyl = 0
						tSec += 1
						if tSec >= 16:
							tSec = 0
							tMod += 2
							if tMod >= 8:
								addError(lineNumber, "Error: Memory totally exhausted")
								return []
		# At this point, we know there are two consecutive words available at the 
		# current location, so we can just keep the current address.
		return []

# Similar to checkLOC() above, but simply changes the assembler's internal 
# pointers to the next unused location.  The situation it envisages is that 
# there has just been an ORG, and that the next instruction has a label by
# which it is reached, so that it can be moved upward at will.  It also assumes
# USE INST.  Returns True on success, False on failure.
def moveLOC():
	global LOC
	global IM
	global IS
	global S
	tLoc = LOC
	tSyl = S
	tSec = IS
	tMod = IM
	while True:
		roof = getRoof(tMod, tSec, tSyl, tLoc, extra)
		if tLoc < roof and not memUsed[tMod][tSec][tSyl][tLoc] \
				and not memUsed[tMod][tSec][tSyl][tLoc + 1]:
			IM = tMod
			IS = tSec
			S = tSyl
			LOC = tLoc
			return True
		tLoc += 1
		if tLoc >= roof:
			tLoc = 0
			tSyl += 1
			if tSyl >= 2:
				tSyl = 0
				tSec += 1
				if tSec >= 16:
					tSec = 0
					tMod += 2
					if tMod >= 8:
						addError(lineNumber, "Error: Memory totally exhausted")
						return False
	return False

# This is used to find a block of n unallocated locations in instruction space,
# starting at the current LOC.  It returns either the found location, in the
# form of an array [IM, IS, S, LOC] (with the global values of those variables
# remaining unchanged), or else an empty array upon error.
def checkBLOCKafterORG(n, extra = 0):
	index = []
	sector = IS
	syllable = S
	offset = LOC
	for i in range(IM, 0o10, 2):
		for j in range(sector, 0o20):
			for k in range(syllable, 2):
				roof = getRoof(i, j, k, offset, extra)
				inUsed = True
				for l in range(offset, roof):
					if memUsed[i][j][k][l]:
						inUsed = True
						index = []
						lenUnused = 0
					elif inUsed:
						inUsed = False
						index = [i, j, k, l]
						lenUnused = 1
					else:
						lenUnused += 1
					if lenUnused >= n:
						return index
				offset = 0
			syllable = 0
		sector = 0
	return []

# Disassembles the two syllables of a word into instructions.  Useful only for debugging
# DFW pseudo-ops, and now that DFW is working properly, I've actually commented its use out.  
# However, I like the function definition, so I'll leave it here for a while in case I think
# of something else to use it for.  The code was adapted from unOP.py.  It has not been 
# adapted yet for --ptc.
def unassemble(word):
	instructions = [ "HOP", "MPY", "SUB", "DIV", "TNZ", "MPH", "AND", "ADD", "TRA", "XOR", "PIO", "STO", "TMI", "RSU", "", "CLA" ]
	syllables = [(word & 0o777740000) >> 13 , word & 0o37776]
	s = ""
	for syllable in syllables:
		if s != "":
			s += "   "
		op = (syllable >> 1) & 0x0F
		if op == 0o16:
			if (syllable & 32) == 0:
				instruction = "CDS"
				DM = (syllable >> 7) & 3
				DS = (syllable >> 10) & 15
				s += "%s %o,%02o" % (instruction, DM, DS)
			elif (syllable & 0o10000) == 0:
				instruction = "SHF"
				address = (syllable >> 6) & 0o63
				if address == 0:
					s += "SHL 0"
				elif address == 1:
					s += "SHR 1"
				elif address == 2:
					s += "SHR 2"
				elif address == 16:
					s += "SHL 1"
				elif address == 32:
					s += "SHL 2"
				else:
					s += "%s %03o" % (instruction, address)
			else:
				instruction = "EXM"
				left = (syllable >> 11) & 3
				middle = (syllable >> 10) & 1
				right = (syllable >> 6) & 15
				s += "%s %o,%o,%02o" % (instruction, left, middle, right)
		else:
			instruction = instructions[op]
			address = ((syllable >> 6) & 0xFF) | ((syllable << 3) & 0x100)
			residual = 0
			if address > 0o377:
				residual = 1
				address = address & 0o377
			s += "%s %o %03o" % (instruction, residual, address)
	return s

# Put the assembled value wherever it's supposed to go in the executable image.
def storeAssembled(lineNumber, value, hop, data = True):
	global octals
	checkSyl = -1
	if data:
		module = hop["DM"]
		sector = hop["DS"]
		location = hop["DLOC"]
		checkSyl = 2
		try:
			octals[module][sector][2][location] = value
		except:
			addError(lineNumber, "Error: Invalid data address %o-%02o-%03o." % (module, sector, location))
	else:
		module = hop["IM"]
		sector = hop["IS"]
		syllable = hop["S"]
		location = hop["LOC"]
		if useDat:
			value = value & 0o17777
			if syllable == 1:
				value = value << 14
			else:
				value = value << 1
			try:
				if octals[module][sector][2][location] == None:
					octals[module][sector][2][location] = value
				else:
					checkSyl = 2
					octals[module][sector][2][location] = \
									octals[module][sector][2][location] | value
			except:
				addError(lineNumber, \
						"Error: Storing non-existent data %o-%02o-%03o" \
						% (module, sector, location))
				return
		else:
			checkSyl = syllable
			try:
				if syllable == 1:
					octals[module][sector][syllable][location] = \
														(value << 2) & 0o77774
				else:
					octals[module][sector][syllable][location] = \
														(value << 1) & 0o37776
			except:
				addError(lineNumber, \
					"Error: Storing non-existent instruction %o-%02o-%o-%03o" \
								% (module, sector, checkSyl, location))
				return
	if checkTheOctals and checkSyl >= 0:
		try:
			assembledOctal = octals[module][sector][checkSyl][location]
			checkOctal = octalsForChecking[module][sector][checkSyl][location]
		except:
			addError(lineNumber, \
					"Error: Checking non-existent instruction %o-%02o-%o-%03o" \
								% (module, sector, checkSyl, location))
			return
		if fuzzy and assembledOctal != None and checkOctal != None \
				and abs(assembledOctal - checkOctal) == 2:
			if assembledOctal > checkOctal:
				direction = "large"
			else:
				direction = "small"
			msg = "Rounding: %09o too %s by 1" % (assembledOctal, direction)
			addError(lineNumber, msg)
		elif assembledOctal != checkOctal:
			msg = "Mismatch: Octal mismatch, "
			xor = 0
			if checkOctal == None:
				if checkSyl == 2:
					fmt = "%o,%02o,%o,%03o, %09o != None" 
				else:
					fmt = "%o,%02o,%o,%03o, %05o != None"
				msg += fmt % (module, sector, checkSyl, location, assembledOctal)
			else:
				if checkSyl == 2:
					fmt = "%o,%02o,%o,%03o, %09o != %09o, xor = %09o" 
				else:
					fmt = "%o,%02o,%o,%03o, %05o != %05o, xor = %05o"
				xor = assembledOctal ^ checkOctal
				msg += fmt % (module, sector, checkSyl, location, 
								assembledOctal, checkOctal, xor)
				#msg += ", disassembly   " + unassemble(assembledOctal)
				#msg += "   !=   " + unassemble(checkOctal)
			if not (ptc and ignoreResiduals and \
					((checkSyl == 0 and xor == 0o100) 
					or (checkSyl == 1 and xor == 0o100))):
				addError(lineNumber, msg)

# Form a HOP constant from a hop dictionary.
def formConstantHOP(hop):
	if hop == {}:
		return 0
	hopConstant = 0
	hopConstant |= (hop["IM"] & 1) << 25
	if not ptc:
		hopConstant |= 1 << 24
	hopConstant |= hop["DS"] << 20
	hopConstant |= hop["DM"] << 17
	if not ptc:
		hopConstant |= 1 << 16
	hopConstant |= hop["LOC"] << 7
	hopConstant |= hop["S"] << 6
	hopConstant |= hop["IS"] << 2
	hopConstant |= (hop["IM"] & 6) >> 1
	return hopConstant << 1

for n in range(0, len(lines)):
	line = lines[n]
	errors.append([])
	expandedLines.append([line])

#----------------------------------------------------------------------------
#	Preprocessor pass
#----------------------------------------------------------------------------

defineMacros(lines, macros)

# The idea for this pass is to process:
#	EQU, expansion of CALL, expansion of SHL, SHR,
#	usage of EQU-defined constants in assembly-language operands,
#	expansion of macros, conditionally-assembled code.
# The array expandedLines[] will end up being exactly the same length as 
# lines[], and the entries will correspond 1-to-1 to it, but the entries will 
# be arrays of replacement lines.  The errors[] array is also in a similar 
# 1-to-1 relationship, and errors[n] contains an array (hopefully usually 
# empty) of error/warning messages for lines[n].
preprocessor(lines, expandedLines, constants, macros, ptc, allowUnlist)

#----------------------------------------------------------------------------
#     	Discovery pass (creation of symbol table)
#----------------------------------------------------------------------------
# The object of this pass is to discover all addresses for left-hand symbols,
# or in other words, to assign an address (HOP constant) to each line of code.
# It also collects any workarounds (WORK directives) into a structure for later
# reference during the assembly pass.
  
# The result of the pass is a hopefully easy-to-understand list of dictionaries, 
# inputFile. It also buffers the lhs, operator, and operand fields, so they 
# don't have to be parsed out again on the next pass.

# For either discovery pass, we can just loop through all of the lines of code by 
# having an outer loop on all of the elements of expandedLines[], and an inner 
# loop on all of the elements of expandedLines[n][].

# Here, "d" is an integer.  "field" is supposed to be one of the following:
#	*
#	*+n
#	*-n
# where n is a non-negative octal integer.  The return value is the adjusted 
# value of d by n.  Or else d is simply returned on error.  These represent
# adjustments to fields of the DOG pseudo-op, and don't actually appear in the
# source code in this form.  Rather, they appear as *, *+(n), *-(n), *+(C), or
# *-(C), where C is the symbolic name of a constant.  However, the processing
# which has already occurred prior to calling adjustDogField() have  
# computed the parenthesized expressions and replaced the original source.
def adjustDogField(lineNumber, d, field):
	if field == "*":
		return d
	elif field[:2] == "*+":
		sign = 1
		n = field[2:]
	elif field[:2] == "*-":
		sign = -1
		n = field[2:]
	else:
		addError(lineNumber, "Error: Illegal DOG field " + field)
		return d
	if n[0] == "(" and n[-1] == ")":
		value,error = yaEvaluate(n[1:-1], constants)
		if error != "":
			addError(lineNumber, "Error: %s" % error)
		else:
			v = value["number"]
			if "scale" in value:
				v *= 2**value["scale"]
			return d + sign * hround(v)
	try:
		return d + sign * hround(float(n))
	except:
		addError(lineNumber, "Error: Cannot evaluate increment in DOG field (%s)" % n)
		return d

page = 0
ptcDLOC = [[1 for sector in range(16)] for module in range(8)]
IM = 0
IS = 0
S = 1
LOC = 0
DM = 0
DS = 0
dS = 0
DLOC = 0
useDat = False
udDM = 0
udDS = 0
inMacro = ""
pendingSyn = -1
for lineNumber in range(len(expandedLines)):
	for expandedNumber in range(len(expandedLines[lineNumber])):
		line = expandedLines[lineNumber][expandedNumber]
		if ptc:
			ptcDLOC[DM][DS] = DLOC
		lFields = line.split()
		if len(lFields) >= 3 and lFields[0] == "#" and \
				lFields[1] == "PAGE" and lFields[2][:-1].isdigit():
			page = int(lFields[2][:-1])
		inDataMemory = True
		inputLine = { "raw": line, "VEC": False, "MAT": False, 
					"numExpanded": len(expandedLines[lineNumber]), 
					"page": page }
		if expandedNumber == 0 and line != lines[lineNumber]:
			inputLine["notRaw"] = True
		isCDS = False
		    
		# Split the line into fields.
		if line[:1] in [" ", "\t"] and not line.isspace():
			line = "@" + line
		fields = line.split()
		if len(fields) > 0 and fields[0] == "@":
			fields[0] = ""
		lhs = ""
		if len(fields) > 0:
			lhs = fields[0]
		    
		# Ignore full-line comments.
		if inputLine["raw"][:1] in ["*", "#", "$"]:
			#continue
			fields = []

		# Immediately deal with INFO directives.
		infoRequest = []
		if len(fields) >= 3 and fields[1] == "INFO":
			parameters = fields[2].split(",")
			if parameters[0] == "CONSTANT" and parameters[1] in constants:
				infoRequest = parameters

		# Collect WORK directives for later use.
		if len(fields) >= 3 and fields[1] == "WORK":
			parameters = fields[2].split(",")
			if len(parameters) == 2 and parameters[0] == "CDS":
				cdsWorkarounds.add(parameters[1])
			elif len(parameters) == 5 and parameters[0] \
					in ["ROOF", "BLOCK", "FLOOR"]:
				try:
					name = parameters[0]
					parameters = (int(parameters[1], 8), int(parameters[2], 8),
								  int(parameters[3], 8), int(parameters[4], 8))
					if name == "ROOF":
						if parameters not in roofWorkarounds:
							roofWorkarounds.append(parameters)
					elif name == "FLOOR":
						floorWorkarounds.append(parameters)
					elif name == "BLOCK":
						if parameters not in blockWorkarounds:
							blockWorkarounds.append(parameters)
				except:
					addError(lineNumber, "Info: Illegal workaround parameters: " + fields[2], expandedNumber)
			elif len(parameters) == 4 and parameters[0] in ["INC","DEC"]:
				try:
					name = parameters[0]
					parameters = (int(parameters[1], 8), int(parameters[2], 8),
								  int(parameters[3], 8))
					if name == "INC":
						if parameters not in incWorkarounds:
							incWorkarounds.append(parameters)
					elif name == "DEC":
						if parameters not in decWorkarounds:
							decWorkarounds.append(parameters)
				except:
					addError(lineNumber, "Info: Illegal workaround parameters: " + fields[2], expandedNumber)
			else:
				addError(lineNumber, "Info: Unknown workaround: "+fields[2], expandedNumber)
			continue

		# Detect MACRO / ENDMAC definitions.
		if len(fields) >= 2:
			if inMacro != "":
				inputLine["inMacroDef"] = True
				if fields[1] == "ENDMAC":
					inMacro = ""
					fields = []
			elif fields[1] == "MACRO":
				inMacro = fields[0]
		if inMacro != "":
			inputLine["inMacroDef"] = True
			fields = []
		
		if len(fields) >= 2 and fields[1] == "VEC":
			while DLOC < 256:
				DLOC = (DLOC + 3) & ~3
				checkDLOC(3)
				if (DLOC & 3) == 0:
					break
		elif len(fields) >= 2 and fields[1] == "MAT":
			while DLOC < 256:
				DLOC = (DLOC + 15) & ~15
				checkDLOC(9)
				if (DLOC & 15) == 0:
					break
		elif len(fields) >= 2 and fields[1] in macros and macros[fields[1]]["numArgs"] == 0:
			pass
		elif len(fields) >= 2 and fields[1] in ["ENDIF", "END"]:
			pass
		elif len(fields) >= 3:
			ofields = fields[2].split(",")
			if fields[1] in ignore:
				pass
			elif fields[1] == "USE":
				if fields[2] == "INST":
					useDat = False
				elif fields[2] == "DAT":
					dS = 1
					useDat = True
				else:
					addError(lineNumber, "Error: Wrong operand for USE")
			elif fields[1] == "TABLE":
				try:
					length = int(fields[2])
					checkDLOC(length)
					for i in range(length):
						location = (DM, DS, DLOC+i)
				except:
					addError(lineNumber, "Implementation: Error in TABLE")
				if fields[0] != "":
					lhs = fields[0]
					inputLine["lhs"] = lhs
					inputLine["hop"] = {"IM":DM, "IS":DS, "S":0, "LOC":DLOC, 
										"DM":DM, "DS":DS, "DLOC":DLOC}
					inputLine["isTABLE"] = True
					# Ordinarily, addition to the symbol table would be handled
					# later on, outside of this loop.  However, I find that 
					# DOG instructions processed by this loop need the labels
					# for TABLE instructions, so we add them to the symbol table
					# right now.
					if lhs in symbols:
						addError(lineNumber, "Error: Symbol already defined")
					symbols[lhs] = inputLine["hop"]
					symbols[lhs]["inDataMemory"] = inDataMemory
					symbols[lhs]["isCDS"] = False
					symbols[lhs]["isTABLE"] = True
			elif fields[1] == "BLOCK":
				inDataMemory = False
				value, error = yaEvaluate(fields[2], constants)
				if error != "":
					addError(lineNumber, "Error: " + error)
					index = [IM, IS, S, LOC]
					length = 0
				else:
					v = value["number"]
					if "scale" in value:
						v *= 2**value["scale"]
					length = hround(v)
					index = checkBLOCKafterORG(length)
				if len(index) == 0:
					addError(lineNumber, "Error: No space for BLOCK")
				elif index == [IM, IS, S, LOC]:
					pass # Okay as-is!
				elif lastORG or (IM,IS,S,LOC) in blockWorkarounds:
					IM, IS, S, LOC = tuple(index)
					if False:
						addError(lineNumber, \
								"Warning: Skipping already-used locations (%o-%02o-%o-%03o)" \
								% tuple(index))
				else:
					inputLine["switchSectorAt"] = [IM, IS, S, LOC] + index
					memUsed[IM][IS][S][LOC] = True
					IM, IS, S, LOC = tuple(index)
					inputLine["hop"] = {"IM":index[0], "IS":index[1], 
										"S":index[2], "LOC":index[3], 
										"DM":DM, "DS":DS, "DLOC":DLOC}
				if fields[0] != "":
					lhs = fields[0]
					inputLine["lhs"] = lhs
					inputLine["hop"] = {"IM":index[0], "IS":index[1], 
										"S":index[2], "LOC":index[3], 
										"DM":DM, "DS":DS, "DLOC":DLOC}
					inputLine["isBLOCK"] = True
					# Ordinarily, addition to the symbol table would be handled
					# later on, outside of this loop.  However, I find that 
					# DOG instructions processed by this loop need the labels
					# for TABLE instructions, so we add them to the symbol table
					# right now.
					if lhs in symbols:
						addError(lineNumber, "Error: Symbol already defined")
					symbols[lhs] = copy.deepcopy(inputLine["hop"])
					symbols[lhs]["inDataMemory"] = inDataMemory
					symbols[lhs]["isCDS"] = False
					symbols[lhs]["isBLOCK"] = True
			elif fields[0] != "" and fields[1] == "SYN":
				if fields[2] == "*INS":
					inputLine["syn"] = "ins"
					inDataMemory = False
					inputLine["lhs"] = fields[0]
					inputLine["hop"] = {"IM":IM, "IS":IS, "S":S, "LOC":LOC, "DM":DM, "DS":DS, "DLOC":DLOC}
					if False and synFix:
						# This case may (or may not) be the more-correct 
						# behavior, but I've disallowed it because of 
						# implementation difficulty.
						pendingSyn = 1
					else:
						addRemover(fields[0], IM, IS, S, LOC, DM, DS)
				elif fields[2] == "*DAT":
					inputLine["syn"] = "dat"
					inputLine["lhs"] = fields[0]
					inputLine["hop"] = {"IM":DM, "IS":DS, "S":0, "LOC":DLOC, "DM":DM, "DS":DS, "DLOC":DLOC}
					if synFix:
						pendingSyn = 0
					else:
						addRemover(fields[0], DM, DS, 0, DLOC, DM, DS)
				else:
					inputLine["syn"] = "symbol"
					synonyms[fields[0]] = fields[2]
			elif fields[0] != "" and fields[1] == "FORM":
				if fields[0] in forms:
					addError(n, "Error: Form already defined")
				for i in range(len(ofields)):
					ofield = ofields[i]
					if ofield[:1] == "(":
						value,error = yaEvaluate(ofield, constants)
						if error != "":
							addError(n, error)
						ofields[i] = "%d" % hround(value)
					elif ofield in constants:
						pass
					elif ofield[:-1].isdigit() and \
							ofield[-1:] in ["B", "O", "D", "P"]:
						ofields[i] = ofield
					else:
						pass
				forms[fields[0]] = ofields
			elif (not ptc) and fields[1] == "ORGDD":
				lastORG = True
				if len(ofields) != 7:
					addError(lineNumber, "Error: Wrong number of ORGDD arguments")
				else:
					IM = int(ofields[0], 8)
					IS = int(ofields[1], 8)
					S = int(ofields[2], 8)
					LOC = int(ofields[3], 8)
					DM = int(ofields[4], 8)
					DS = int(ofields[5], 8)
					if ofields[6].strip() != "":
						DLOC = int(ofields[6], 8)
					else:
						DLOC = 0
					inputLine["udDM"] = DM
					inputLine["udDS"] = DS
			elif fields[1] == "ORG":
				lastORG = True
				if len(ofields) == 1:
					# In this case we expect the operand to be the name of an
					# existing symbol associated with a memory location.
					symbol = ofields[0]
					if symbol not in symbols:
						addError(lineNumber, "Error: Undefined symbol "+symbol)
					else:
						hop = symbols[symbol]
						IM = hop["IM"]
						IS = hop["IS"]
						S = hop["S"]
						LOC = hop["LOC"]
						if False:
							DM = hop["DM"]
							DS = hop["DS"]
							DLOC = hop["DLOC"]
				elif len(ofields) == 2:
					symbol = ofields[0]
					symbol2 = ofields[1]
					bad = False
					if symbol not in symbols:
						addError(lineNumber, "Error: Undefined symbol "+symbol)
						bad = True
					if symbol2 not in symbols:
						addError(lineNumber, "Error: Undefined symbol "+symbol2)
						bad = True
					if not bad:
						hop = symbols[symbol]
						hop2 = symbols[symbol2]
						IM = hop["IM"]
						IS = hop["IS"]
						S = hop["S"]
						LOC = hop["LOC"]
						DM = hop2["DM"]
						DS = hop2["DS"]
						DLOC = hop2["DLOC"]
				elif len(ofields) != 7:
					addError(lineNumber, "Error: Wrong number of ORG arguments")
				else:
					fIM = ofields[0].strip()
					fIS = ofields[1].strip()
					fS = ofields[2].strip()
					fLOC = ofields[3].strip()
					fDM = ofields[4].strip()
					fDS = ofields[5].strip()
					fDLOC = ofields[6].strip()
					if fIM[:1] == "*":
						IM = adjustDogField(lineNumber, IM, fIM)
					elif fIM != "":
						IM = int(fIM, 8)
					else:
						IM = 0
					if fIS[:1] == "*":
						IS = adjustDogField(lineNumber, IS, fIS)
					elif fIS != "":
						IS = int(fIS, 8)
					else:
						IS = 0
					if fS[:1] == "*":
						S = adjustDogField(lineNumber, S, fS)
						if S == 2:
							S = 0
					elif fS != "":
						S = int(fS, 8)
					else:
						S = 0
					if fLOC[:1] == "*":
						LOC = adjustDogField(lineNumber, LOC, fLOC)
						if LOC >= 0o400:
							S += LOC // 0o400
							LOC = LOC % 0o400
							if S >= 2:
								IS += S // 2
								S = S % 2
								if IS >= 0o20:
									IM += IS // 0o20
									IS = IS % 0o20
					elif fLOC != "":
						LOC = int(fLOC, 8)
					else:
						LOC = 0
					if fDM[:1] == "*":
						DM = adjustDogField(lineNumber, DM, fDM)
					elif fDM != "":
						DM = int(fDM, 8)
					else:
						DM = 0
					if fDS[:1] == "*":
						DS = adjustDogField(lineNumber, DS, fDS)
					elif fDS != "":
						DS = int(fDS, 8)
					else:
						DS = 0
					if fDLOC[:1] == "*":
						DLOC = adjustDogField(lineNumber, DLOC, fDLOC)
					elif fDLOC != "":
						DLOC = int(fDLOC, 8)
					elif not ptc:
						DLOC = 0
					else:
						DLOC = ptcDLOC[DM][DS]
			elif fields[1] in ["DOGD", "DOG"]:
				if len(ofields) == 1:
					# In this case we expect the operand to be the name of an
					# existing symbol representing a variable.
					symbol = ofields[0]
					if symbol in constants and len(constants[symbol]) > 0 and \
							symbol not in symbols:
						try:
							if "DEQD" == constants[symbol][0]:
								DM = int(constants[symbol][1], 8)
								DS = int(constants[symbol][2], 8)
								DLOC = int(constants[symbol][3], 8)
						except:
							addError(lineNumber, "Implementation: %s %s" \
									% (symbol, str(constants[symbol])))
					elif symbol not in symbols:
						addError(lineNumber, "Error: Undefined symbol "+symbol)
					elif "inDataMemory" not in symbols[symbol] \
							or not symbols[symbol]["inDataMemory"]:
						#addError(lineNumber, "Error: Symbol " + symbol + " not data")
						DM = symbols[symbol]["IM"]
						DS = symbols[symbol]["IS"]
						DLOC = symbols[symbol]["LOC"]
					else:
						DM = symbols[symbol]["DM"]
						DS = symbols[symbol]["DS"]
						DLOC = symbols[symbol]["DLOC"]
				elif len(ofields) != 3:
					addError(lineNumber, "Error: Wrong number of DOGD/DOG arguments")
				else:
					fDM = ofields[0].strip()
					fDS = ofields[1].strip()
					fDLOC = ofields[2].strip()
					if fDM[:1] == "*":
						DM = adjustDogField(lineNumber, DM, fDM)
					elif fDM != "":
						DM = int(fDM, 8)
					else:
						DM = 0
					if fDS[:1] == "*":
						DS = adjustDogField(lineNumber, DS, fDS)
					elif fDS != "":
						DS = int(fDS, 8)
					else:
						DS = 0
					if fDLOC[:1] == "*":
						DLOC = adjustDogField(lineNumber, DLOC, fDLOC)
					elif fDLOC != "":
						DLOC = int(fDLOC, 8)
					elif ptc:
						DLOC = ptcDLOC[DM][DS]
					else:
						DLOC = 0
				inputLine["udDM"] = DM
				inputLine["udDS"] = DS
			elif fields[1] in ["DEQS", "DEQD"] and fields[0] in constants:
				newDM = int(constants[fields[0]][1], 8)
				newDS = int(constants[fields[0]][2], 8)
				newDLOC = int(constants[fields[0]][3], 8)
				symbols[fields[0]] = {	"IM": newDM, "IS": newDS, "S": 0, 
								"LOC": newDLOC, "DM": newDM, 
								"DS": newDS, 
								"DLOC": newDLOC, "inDataMemory":True }
				inputLine["udDM"] = int(constants[fields[0]][1], 8)
				inputLine["udDS"] = int(constants[fields[0]][2], 8)
			elif fields[1] == "BSS":
				try:
					checkDLOC(int(fields[2]))
					if fields[0] != "":
						inputLine["lhs"] = fields[0]
					inputLine["operator"] = fields[1]
					inputLine["operand"] = fields[2]
					inputLine["hop"] = {"IM":DM, "IS":DS, "S":0, "LOC":DLOC, "DM":DM, "DS":DS, "DLOC":DLOC}
					incDLOC(int(fields[2]))
				except:
					addError(lineNumber, "Error: Improper BSS")
			elif ptc and fields[1] == "BCI":
				text = bciPad(fields[2][1:-1])
				textLength = len(text) / 4
				checkDLOC(textLength)
				if fields[0] != "":
					inputLine["lhs"] = fields[0]
				inputLine["operator"] = fields[1]
				inputLine["operand"] = fields[2]
				inputLine["hop"] = {"IM":DM, "IS":DS, "S":0, "LOC":DLOC, "DM":DM, "DS":DS, "DLOC":DLOC}
				incDLOC(textLength)
			elif fields[1] in ["DEC", "OCT", "HPC", "HPCDD", "DFW"] or fields[1] in forms:
				checkDLOC()
				if fields[0] != "":
					inputLine["lhs"] = fields[0]
				inputLine["operator"] = fields[1]
				inputLine["operand"] = fields[2]
				inputLine["hop"] = {"IM":DM, "IS":DS, "S":0, "LOC":DLOC, "DM":DM, "DS":DS, "DLOC":DLOC}
				incDLOC()	
			elif fields[1] in operators:
				inDataMemory = False
				# This code is intended for inserting automatic sector changes
				# or jumps around memory already allocated for something else. 
				extra = 0
				if fields[2][:2] == "*+" and fields[2][2:].isdigit():
					extra += int(fields[2][2:])
				if ptc and fields[1] in ["TRA", "HOP"] \
						and not memUsed[IM][IS][S][LOC]:
					pass
				elif newer and lastORG:
					if not moveLOC():
						addError(lineNumber, "Error: No free memory in sector")
				else:
					oldLocation = checkLOC(extra)
					if oldLocation != []:
						inputLine["switchSectorAt"] = oldLocation
				lastORG = False
				if fields[0] != "":
					inputLine["lhs"] = fields[0]
				inputLine["operator"] = fields[1]
				inputLine["operand"] = fields[2]
				
				# Try to track the number of locations we need for remapping TMI and TNZ targets.
				try:
					if len(fields) >= 2 and fields[0] != "":
						addRemover(fields[0], IM, IS, S, LOC, DM, DS)
					if len(fields) >= 3 and fields[1] in ["TMI", "TNZ"] and \
							fields[2][:1].isalpha():
						symbol = fields[2].split("+")[0].split("-")[0]
						addAdder(symbol, IM, IS, S, LOC, DM, DS)
				except:
					addError(lineNumber, "Error: Tracking TMI/TNZ failed")
				
				if useDat:
					inputLine["hop"] = {"IM":DM, "IS":DS, "S":dS, "LOC":DLOC, "DM":DM, "DS":DS, "DLOC":DLOC}
					inputLine["useDat"] = True
					inputLine["inDataMemory"] = True
					memUsed[DM][DS][dS][DLOC] = True
				else:
					inputLine["hop"] = {"IM":IM, "IS":IS, "S":S, "LOC":LOC, "DM":DM, "DS":DS, "DLOC":DLOC}
					memUsed[IM][IS][S][LOC] = True
				incLOC()
				if ptc and "incDLOC" in inputLine:
					incDLOC(mark = False)
				if fields[1] in ["CDS", "CDSD", "CDSS"]:
					# I should be doing something here with the simplex vs duplex info, but I don't
					# know what, so I'll just ignore it for now.
					isCDS = True
					if len(ofields) == 1:
						if not useDat:
							found = False
							# Operand symbol could have been defined by a DEQS or DEQD
							if fields[2] in constants:
								constant = constants[fields[2]]
								if type(constant) == type([]) and len(constant) >= 3:
									if not useDat:
										DM = int(constant[1], 8)
										DS = int(constant[2], 8)
									inputLine["udDM"] = int(constant[1], 8)
									inputLine["udDS"] = int(constant[2], 8)
									found = True
							# We assume this is the name of a variable, and we have to
							# find it to determine its DM/DS.  I presume it could be
							# defined later, and so we don't find it ... let's hope not!
							if not found:
								for testEntry in inputFile:
									testLine = testEntry["expandedLine"]
									if "lhs" in testLine and testLine["lhs"] == fields[2] and "hop" in testLine:
										if fields[1] == "CDSD":
											if not useDat:
												DM = testLine["hop"]["DM"]
												DS = testLine["hop"]["DS"]
											inputLine["udDM"] = testLine["hop"]["DM"]
											inputLine["udDS"] = testLine["hop"]["DS"]
										elif fields[1] == "CDS":
											if not useDat:
												DM = testLine["hop"]["IM"]
												DS = testLine["hop"]["IS"]
											inputLine["udDM"] = testLine["hop"]["IM"]
											inputLine["udDS"] = testLine["hop"]["IS"]
										found = True
										break
							if not found:
								addError(lineNumber, "Error: Symbol not found, " + fields[2])
					elif len(ofields) != 2:
						addError(lineNumber, "Error: Wrong number of CDS/CDSD arguments")
					elif not useDat:
						if not useDat:
							DM = int(ofields[0], 8)
							DS = int(ofields[1], 8)
						inputLine["udDM"] = int(ofields[0], 8)
						inputLine["udDS"] = int(ofields[1], 8)
					if ptc:
						DLOC = ptcDLOC[DM][DS]
			elif fields[1] in preprocessed:
				pass
			elif fields[1] in pseudos:
				pass
			else:
				addError(lineNumber, "Error: Unrecognized operator: %s" % fields[1])
		elif len(fields) > 1 and fields[1] in ["LIT", "ENDLIT", "LIST", "UNLIST"]:
			inputLine["operator"] = fields[1]
		elif len(fields) != 0:
			addError(lineNumber, "Error: Wrong number of fields: %s" % str(fields))
		inputLine["inDataMemory"] = inDataMemory
		inputLine["useDat"] = useDat
		inputLine["isCDS"] = isCDS
		inputFile.append({"lineNumber":lineNumber, "expandedLine":inputLine })
		if lhs != "" and "hop" in inputLine:
			symbols[lhs] = inputLine["hop"]
			symbols[lhs]["inDataMemory"] = inDataMemory or useDat
			symbols[lhs]["isCDS"] = inputLine["isCDS"]
			symbols[lhs]["1stPass"] = True
			if "syn" in inputLine:
				symbols[lhs]["syn"] = inputLine["syn"]
		if pendingSyn > 1 and "hop" in inputLine:
			for pendingLine in reversed(inputFile):
				pendingInputLine = pendingLine["expandedLine"]
				if "syn" in pendingInputLine and \
						pendingInputLine["syn"] in ["ins", "dat"]:
					lhs = pendingInputLine["lhs"]
					newHop = inputLine["hop"]
					pendingInputLine["hop"].update(newHop)
					symbols[lhs].update(newHop)
					odd = pendingSyn & 1
					if odd: # *INS
						addRemover(lhs, IM, IS, S, LOC, DM, DS)
					else: # *DAT
						addRemover(lhs, DM, DS, 0, DLOC, DM, DS)
					break
			pendingSyn = -1
		if pendingSyn >= 0:
			pendingSyn += 2


# Create a table to quickly look up addresses of symbols. I think that all or
# most of these will already have been done by the preprocessor or the loop 
# above, though.
for entry in inputFile:
	inputLine = entry["expandedLine"]
	if "isTABLE" in inputLine: # Already added.
		continue
	lineNumber = entry["lineNumber"]
	if "lhs" in inputLine:
		lhs = inputLine["lhs"]
		if "hop" in inputLine:
			if lhs in symbols:
				if "1stPass" not in symbols[lhs]:
					addError(lineNumber, "Error: Symbol (%s) already defined" % lhs)
				else:
					symbols[lhs].pop("1stPass")
			else:
				usingDat = inputLine["useDat"]
				symbols[lhs] = inputLine["hop"]
				symbols[lhs]["inDataMemory"] = inputLine["inDataMemory"]
				symbols[lhs]["isCDS"] = inputLine["isCDS"]
				symbols[lhs]["useDat"] = usingDat
			if inputLine["inDataMemory"]:
				allocationRecords.append({ "symbol": lhs, "lineNumber": lineNumber, 
					"inputLine": inputLine, "DM": inputLine["hop"]["DM"], 
					"DS": inputLine["hop"]["DS"], "LOC": inputLine["hop"]["LOC"] })
		else:
			addError(lineNumber, "Error: Symbol location unknown (%s)" % lhs)
	if "autoVariable" in inputLine:
		autoVariable = inputLine["autoVariable"]
		if "hop" in inputLine:
			symbols[autoVariable] = inputLine["hop"]
			symbols[autoVariable]["inDataMemory"] = True
			symbols[autoVariable]["isCDS"] = False
			addError(lineNumber, "Info: Auto-allocation of variable %s" % autoVariable)
			allocationRecords.append({ "symbol": autoVariable, "lineNumber": lineNumber, 
				"inputLine": inputLine, "DM": inputLine["hop"]["DM"], 
				"DS": inputLine["hop"]["DS"], "LOC": inputLine["hop"]["DLOC"] })
		else:
			addError(lineNumber, "Error: Symbol location unknown (%s)" % autoVariable)

# A mini-pass to set up SYN symbols.
for s in synonyms:
	upper = [s]
	while synonyms[s] in synonyms:
		s = synonyms[s]
		upper.append(s)
	original = synonyms[s]
	if original not in symbols:
		addError(n, "Error: Referent (%s) not found for synonyms %s" \
				% (original, str(upper)))
	else:
		for u in upper:
			if u not in symbols:
				symbols[u] = symbols[original]

if False:
	for key in sorted(symbols):
		symbol = symbols[key]
		print("%-8s  %o %02o %o %03o  %o %02o %03o" % (key, symbol["IM"], 
                symbol["IS"], symbol["S"], symbol["LOC"], symbol["DM"], 
                symbol["DS"], symbol["DLOC"]))

#----------------------------------------------------------------------------
#   	Assembly pass, printout of assembly listing, saving .src file
#----------------------------------------------------------------------------
# At this point we have a dictionary called inputFile in which the entire 
# input source file has been parsed into a relatively simple structure.  The
# addresses of all symbols (constants, variables, code) are known.  One memory
# allocation task the "discovery" pass was NOT able to do was to do automatic
# assignments of nameless variables or targets of code jumps for things like
#   1.  Operands of the form "=something"
#   2.  Operands of HOP*, TRA*.
#   3.  Targets of HOPs transparently added for automatic sector changes.
#   4.  For --ptc, variables used as operands of instructions but not explicitly 
#       allocated.
# Note that the discovery pass should have already taken care of TMI*
# and TNZ*, even though unable to take care of HOP*.  Now, though, we should
# have all of the info need to allocate those during assembly pass,
# and should therefore be able to actually complete the entire assembly and 
# print it out in a single pass.

# If we're going to be making HTML, let's add names of HTML anchors to all of
# the various types of symbols.
anchorCount = 0
for key in symbols:
	symbols[key]["anchor"] = "a%d" % anchorCount
	anchorCount += 1
constantAnchors = {}
for key in constants:
	constantAnchors[key] = "a%d" % anchorCount
	anchorCount += 1
for key in macros:
	macros[key]["anchor"] = "a%d" % anchorCount
	anchorCount += 1
formAnchors = {}
for key in forms:
	formAnchors[key] = "a%d" % anchorCount
	anchorCount += 1

# For the visual purposes of the assembly listing, it's a bit tricky to try and 
# describe succinctly where the data is coming from, because there are several 
# cases depending on what the preprocessor had done.
#	Case 1: Conditionally-compiled code that is being discarded.  In this case,
#		expandedLines[n][] will be empty because the code is being discarded,
#		so there's actually nothing much to process.
#	Case 2: expandedLines[n][] contains a single element that's identical to lines[n].
#		In this (the usual) case, the preprocessor made no changes, so it's 
#		equivalent to just assembling lines[n] by itself.
#	Case 3:	expandedLines[n][] contains a single element that differs from lines[n].
#		In this case, it's expandedLines[n][0] that needs to be assembled, but
#		lines[n] will serve as the visual model for the assembly listing.  Note
#		that we disallow macros with a single line in them, and that's what allows
#		this conclusion.
#	Case 4:	expandedLines[n][] contains more than one element.  In this case, lines[n]
#		is a macro invocation and does generate something visually in the assembly
#		listing, but is not itself assembled.  Only the lines in expandedLines[n][]
#		actually need to be assembled.
f = open("yaASM.src", "w")
if False:
	for key in sorted(nameless):
		print(key + " " + ("%03o" % nameless[key]))
if ptc:
	lineFieldFormats = [ "%1s", "   %2s ", "%2s ", "%1s ", "%03s    ", "%02s ", 
						"%2s ", "%02s ", "%1s ", "%03s    ", "%9s  ", "%1s ", 
						"%s" ]
	header = "    IM IS S LOC    OP DM DS 9 ADR     OCT VAL     LHS     OPC     VARIABLE                COMMENT"
	traField = 0
	imField = 1
	isField = 2
	sylField = 3
	locField = 4
	opField = 5
	dmField = 6
	dsField = 7
	a9Field = 8
	adrField = 9
	constantField = 10
	expansionField = 11
	rawField = 12
else:
	lineFieldFormats = [ "%1s", "   %2s ", "%02s ", "%1s ", "%03s ", "%2s ", 
						"%02s   "," %03s  ", "%1s  ", "%02s    ", "%09s ", 
						"%1s ", "%s"]
	header = "    IM IS S LOC DM DS   A8-A1 A9 OP    CONSTANT    SOURCE STATEMENT"
	traField = 0
	imField = 1
	isField = 2
	sylField = 3
	locField = 4
	dmField = 5
	dsField = 6
	adrField = 7
	a9Field = 8
	opField = 9
	constantField = 10
	expansionField = 11
	rawField = 12
lineFields = []

wPending = False
def clearLineFields():
	global lineFields, wPending
	lineFields = []
	for n in range(len(lineFieldFormats)):
		lineFields.append("")
	if wPending:
		lineFields[traField] = "W"
		wPending = False

# The colorize function applies colorization to a raw LVDC source line.  There
# has to be a better way to do this by taking advantage of the parsed line, but
# for now I'm doing it like this.  Some stuff like modern comments is taken care
# of elsewhere and so doesn't need to be handled here.
opcodes = {
    "HOP", "HOP*", "MPY", "PRS", "SUB", "DIV", "TNZ", "TNZ*", "MPH", "CIO", 
    "AND", "ADD", "TRA", "TRA*", "XOR", "PIO", "STO", "TMI", "TMI*", "RSU", 
    "CDS", "CDSD", "CDSS", "SHF", "EXM", "CLA", "SHR", "SHL"
}
def applyClass(cl, string, anchor=None, lhs=False):
	if cl != "" and string != "":
		string = '<span class="%s">%s</span>' % (cl, string)
	if anchor != None:
		if lhs:
			string = ('<a id="%s"></a>' % anchor) + string
		else:
			string = ('<a href="#%s">' % anchor) + string + '</a>'
	return string
# This just colorizes a symbol.
def colorizeSymbol(op, lhs=False):
	if op in symbols:
		if symbols[op]["inDataMemory"]:
			op = applyClass("va", op, symbols[op]["anchor"], lhs)
		else:
			op = applyClass("sm", op, symbols[op]["anchor"], lhs)
	elif op in constants:
		op = applyClass("cn", op, constantAnchors[op], lhs)
	elif op in macros:
		op = applyClass("ma", op, macros[op]["anchor"], lhs)
	elif op in forms:
		op = applyClass("fo", op, formAnchors[op], lhs)
	return op
# This colorized just an operand.
constantNamePattern = re.compile("\\b[A-Z][.#A-Z0-9]*\\b")
paranExpPattern = re.compile("\\([^)]+\\)")
poundPattern = re.compile("#[0-9]+")
def colorizeOperand(operand):
	# Take care of any #nnn suffixes added to constant names by the assembler.
	poundMatches = []
	for p in poundPattern.finditer(operand):
		poundMatches.append(p)
	for p in reversed(poundMatches):
		span = p.span()
		operand = operand[:span[0]] + operand[span[1]:]
	# Take care of stuff like:
	#		op1,op2,...
	#		op1+n,op2-m,...
	#		=H'sym1,sym2
	prefix = ""
	suffix = ""
	if operand.startswith("=H'"):
		prefix = "=H'"
		operand = operand[3:]
		if operand[-1:] == "'":
			suffix = "'"
			operand = operand[:-1]
	fields = operand.split(",")
	for i in range(len(fields)):
		field = fields[i]
		if "+" in field:
			index = field.index("+")
		elif "-" in field:
			index = field.index("-")
		else:
			index = len(field)
		fields[i] = colorizeSymbol(field[:index]) + field[index:]
	operand = prefix + ",".join(fields) + suffix
	# Now if the operand contains any parenthesized expressions, try to 
	# colorize any symbolic constants in the expression.
	paranMatches = []
	for p in paranExpPattern.finditer(operand):
		paranMatches.append(p)
	for p in reversed(paranMatches):
		expression = p.group()
		paranSpan = p.span()
		matches = []
		for m in constantNamePattern.finditer(expression):
			matches.append(m)
		for m in reversed(matches):
			name = m.group()
			span = m.span()
			if name in constantAnchors:
				expression = expression[:span[0]] + \
							applyClass("cn", name, constantAnchors[name]) \
							+ expression[span[1]:]
		operand = operand[:paranSpan[0]] + expression + operand[paranSpan[1]:]
	return operand
def colorize(raw):
	if len(raw) == 0:
		return raw
	flow = ""
	if len(raw) >= 71 and raw[70] != " ":
		flow = applyClass("fl", raw[70])
		raw = raw[:70]
	if raw[0] == "*": # Take care of full-line comments.
		return applyClass("co", raw.replace("<", "&lt;")) + flow
	# Split the line into lhs + opcode + operand + comment, accounting for
	# .lvdc vs .lvdc8.
	if len(raw) < 9 or raw[6] != " ":
		return (raw)
	if raw[7] == " " and raw[8] != " ": # lvdc8
		opcodeColumn = 8
	else: # lvdc
		opcodeColumn = 7
	operandColumn = opcodeColumn + 8
	commentColumn = len(raw)
	for commentColumn in range(operandColumn, len(raw)):
		if raw[commentColumn] == " ":
			break
	if commentColumn == len(raw) - 1 and raw[commentColumn] != " ":
		commentColumn += 1
	lhs = raw[:opcodeColumn].rstrip()
	opcode = raw[opcodeColumn:operandColumn].rstrip()
	operand = raw[operandColumn:commentColumn]
	# lhs colorization.
	lhsClass = ""
	if lhs in constants and opcode in ["EQU", "REQ", "DEQD", "DEQS"]:
		lhsClass = "cn"
		lhsAnchor = constantAnchors[lhs]
	elif lhs in symbols:
		if symbols[lhs]["inDataMemory"]:
			lhsClass = "va"
		else:
			lhsClass = "sm"
		lhsAnchor = symbols[lhs]["anchor"]
	elif opcode == "MACRO":
		lhsClass = "ma"
		lhsAnchor = macros[lhs]["anchor"]
	elif opcode == "FORM":
		lhsClass = "fo"
		lhsAnchor = formAnchors[lhs]
	# Determine opcode colorization.
	opcodeClass = ""
	if opcode in opcodes:
		opcodeClass = "op"
	elif opcode in macros or opcode in ["CALL", "TELM"]:
		opcodeClass = "ma"
	elif opcode in forms:
		opcodeClass = "fo"
	else:
		opcodeClass = "ps"
	# Now apply the colorization:
	lhs = raw[:opcodeColumn]
	opcode = raw[opcodeColumn:operandColumn]
	operand = colorizeOperand(operand)
	comment = raw[commentColumn:]
	if lhsClass != "" and lhs != "":
		lhs = applyClass(lhsClass, lhs, lhsAnchor, True)
	if opcodeClass != "" and opcode != "":
		opcode = applyClass(opcodeClass, opcode)
	comment = applyClass("co", comment.replace("<", "&lt;"))
	return lhs + opcode + operand + comment + flow

def printLineFields():
	line = ""
	for n in range(len(lineFieldFormats)):
		line += lineFieldFormats[n] % lineFields[n]
	if line[-2:] !=  unlistSuffix:
		print(line)
		if htmlFile != None:
			line = ""
			flowchartName = ""
			flowchartLink = ""
			if flowchartFolder != "":
				raw = lineFields[rawField]
				if raw[:1] == "*" and raw[70:] == "J":
					# Pick off the title of the flowchart and normalize it to
					# a filename the same way as yaASMflowchart2.py does.
					# I.e. strip off leading and trailing spaces and asterisks.
					# Collapse all whitespace to a single underline.  Make sure
					# there are no forward slashes.
					flowchartName = "_".join(raw[:70].strip(" *").split()).replace("/", "-")
			lineFields[rawField] = colorize(lineFields[rawField][:71])
			for n in range(len(lineFieldFormats)):
				field = lineFieldFormats[n] % lineFields[n]
				if n == traField and field[0] == "W":
					field = applyClass("wn", field)
				if n == constantField and flowchartName != "":
					#field = '<a href="%s/%s.dot.ps.png"><u>Flowchart</u></a> ' \
					#	% (flowchartFolder, flowchartName)
					flowchartLink = \
						'<a href="%s/%s.dot.ps.png" target="_blank" rel="noopener noreferrer" style="float:right"><img src="flowchart.png"></a>' \
						% (flowchartFolder, flowchartName)
				line = line + field
			print(line + flowchartLink, file=htmlFile)

# Determine if module dm, sector ds is reachable from the global 
# module DM, sector DS.  Return True if so, False if not.
def inSectorOrResidual(dm, ds, DM, DS, useDat, udDM, udDS):
	if useDat:
		# I'm having no luck trying to figure this out for USE DATA
		# sections, so for now I just let the test pass.
		return True
		addError(lineNumber, "%o %02o, %o %02o, %o %02o" % (dm, ds, DM, DS, udDM, udDS))
		DM = udDM
		DS = udDS
	if ptc:
		if dm == 0 and ds == 0o17:
			return True
		if dm == DM and ds == DS:
			return True
	else:
		if dm == DM and (ds == DS or ds == 0o17):
			return True
	return False

# Determine if module dm, sector ds is the residual sector
# based on the current DM, DS.
def residualBit(dm, ds):
	if ptc:
		if dm == 0 and ds == 0o17 and not (DM == 0 and DS == 0o17):
			return 1
	else:
		if dm == DM and ds == 0o17: # and DS != 0o17:
			return 1 
	return 0

# This function is used only in the big assembly loop below.  The idea is that
# you feed it a HOP constant tricked up like a symbol-table entry:
#	1.	Assembles octal form of the HOP constant.
#	2.	Allocates a variable to hold the HOP constant.
#	3.	Assembles a HOP instruction with the variable as operand.
#	4.	Stores the assembled instruction and HOP constant in memory.
def hopStar(hop2):
	global star, residual, loc
	star = True
	# We need to allocate a nameless variable to hold the HOP constant.
	hopConstant = formConstantHOP(hop2)
	constantString = "%09o" % hopConstant
	loc,residual = allocateNameless(lineNumber, constantString)
	ds = DS
	if loc > 0o377 or DS == 0o17 or residual != 0:
		loc = loc & 0o377
		residual = 1
		ds = 0o17
	#addError(lineNumber, "Info: Allocating variable for HOP at %o,%02o,%03o" % (DM, ds, loc))
	storeAssembled(lineNumber, hopConstant, {
		"IM": IM,
		"IS": IS,
		"S": S,
		"LOC": loc,
		"DM": DM,
		"DS": ds,
		"DLOC": loc
	})

# The following function is used only in the big assembly loop below.  It
# accepts an operand of the form "=H'symbol" or "=H'symbol1,symbol2", with or
# without an optional trailing single quote (as in "=H'symbol'), and returns
# a dictionary describing the associated HOP constant suitable for being fed
# into formConstantHOP().  Or else it returns {} on error.
def equalsH(operand):
	ofields = operand[3:].rstrip("'").split(",")
	if len(ofields) == 1:
		symbol = ofields[0]
		symbold = ""
	elif len(ofields) == 2:
		symbol = ofields[0]
		symbold = ofields[1]
	else:
		addError(lineNumber, "Error: Corrupt =H'...")
		return {}
	if symbol not in symbols:
		addError(lineNumber, "Error: Symbol (%s) not found" % symbol)
		return {}
	if symbold != "" and symbold not in symbols:
		addError(lineNumber, "Error: Symbol (%s) not found" % symbold)
		return {}
	# The symbol was found, and we want to convert it to a
	# hop constant, in the form of a string that's an octal
	# representation of the constant.
	symbol1 = symbols[symbol]
	if symbold == "":
		symbol2 = symbol1
	else:
		symbol2 = symbols[symbold]
	return {
		"IM": symbol1["IM"],
		"IS": symbol1["IS"],
		"S": symbol1["S"],
		"LOC": symbol1["LOC"],
		"DM": symbol2["DM"],
		"DS": symbol2["DS"],
		"DLOC": symbol2["DLOC"]
	}

useDat = False
errorsPrinted = []
lastLineNumber = -1
expansionMarker = " "
pageNumber = 0
pageTitle = ""
inLiteralMemory = False
for entry in inputFile:
	lineNumber = entry["lineNumber"]
	inputLine = entry["expandedLine"]
	if inputLine["raw"].startswith("# PAGE "):
		fields = inputLine["raw"].split()
		try:
			if fields[2][-1] == ",":
				pageNumber = int(fields[2][:-1])
			else:
				pageNumber = int(fields[2])
		except:
			addError(lineNumber, "Warning: Corrupted page marker")
	errorList = errors[lineNumber]
	originalLine = lines[lineNumber]
	constantString = ""
	clearLineFields()
	star = False
	if originalLine[:7] == "# PAGE " or originalLine[:11] == "# Copyright":
		print("\f")
		if htmlFile != None and pageNumber > 0:
			print("\n<hr>", file=htmlFile)
	if "udDM" in inputLine:
		udDM = inputLine["udDM"]
	if "udDS" in inputLine:
		udDS = inputLine["udDS"]
	
	# If the line is expanded by the preprocessor, we have to display its unexpanded form
	# before proceeding.
	if lineNumber != lastLineNumber:
		lastLineNumber = lineNumber
		#if inputLine["numExpanded"] == 1: # inputLine["raw"] == originalLine:
		if "notRaw" not in inputLine:
			expansionMarker = " "
		else:
			expansionMarker = "+"
			lineFields[rawField] = originalLine[:71]
			printLineFields()
			clearLineFields()
			
	# If there's an automatic sector switch here, we have to take care of it prior to
	# doing anything with the instruction that's actually associated with this line.
	if "switchSectorAt" in inputLine:
		switch = inputLine["switchSectorAt"]
		countRollovers += 1
		im0 = switch[0]
		is0 = switch[1]
		s0 = switch[2]
		loc0 = switch[3]
		im1 = switch[4]
		is1 = switch[5]
		s1 = switch[6]
		loc1 = switch[7]
		if debugRoof > 0:
			here = getRoofReported[im0][is0][s0][loc0]
			print("Sector change at %o-%02o-%o-%03o:" % (im0, is0, s0, loc0), \
				"roof=%03o goo=%s" % (here[0], str(here[1])), \
				file=sys.stderr)
			if debugRoof > 1:
				print("\tRoof adders:  ", here[2], file=sys.stderr)
				print("\tRoof removers:", here[3], file=sys.stderr)
				print("\tDifference:   ", here[4], file=sys.stderr)
		if IM == im1 and IS == is1:
			# Can use a TRA.
			assembled = (operators["TRA"]["opcode"] | (loc1 << 5) | (s1 << 4))
			a81 = "%03o" % loc1
			a9 = "%o" % s1
			op = "%02o" % operators["TRA"]["opcode"]
		else:
			# Must use a HOP.
			hopConstant = formConstantHOP(inputLine["hop"])
			constantString = "%09o" % hopConstant
			loc,residual = allocateNameless(lineNumber, constantString, newer)
			assembled = (operators["HOP"]["opcode"] | (loc << 5) | (residual << 4))
			a81 = "%03o" % loc
			a9 = "%o" % residual
			op = "%02o" % operators["HOP"]["opcode"]
			ds = DS
			if residual != 0:
				ds = 0o17
			storeAssembled(lineNumber, hopConstant, {
				"IM": IM,
				"IS": IS,
				"S": residual,
				"LOC": loc,
				"DM": DM,
				"DS": ds,
				"DLOC": loc
			}, True)
		storeAssembled(lineNumber, assembled, \
					{"IM":im0, "IS":is0, "S":s0, "LOC":loc0}, False)
		lineFields[imField] = "%2o" % im0
		lineFields[isField] = "%02o" % is0
		lineFields[sylField] = "%1o" % s0
		lineFields[locField] = "%03o" % loc0
		lineFields[dmField] = "%2o" % inputLine["hop"]["DM"]
		lineFields[dsField] = "%02o" % inputLine["hop"]["DS"]
		lineFields[opField] = op
		lineFields[a9Field] = a9
		lineFields[adrField] = a81
		if newer:
			lineFields[traField] = " "
			lineFields[constantField] = "        *"
		else:
			lineFields[traField] = "*"
			lineFields[constantField] = "%9s" % constantString
		printLineFields()
		clearLineFields()
		constantString = ""
	operator = ""
	if "operator" in inputLine:
		operator = inputLine["operator"]
	operand = ""
	operandModifierOperation = ""
	operandModifier = 0
	if "operand" in inputLine:
		operand = inputLine["operand"]
		if operand[:1].isalpha() or operand[:1] == "*":
			where = -1
			if "+" in operand:
				where = operand.index("+")
			elif "-" in operand: 
				where = operand.index("-")
			if where > 0:
				operandModifier = operand[where:]
				operand = operand[:where]
				operandModifierOperation = operandModifier[:1]
				operandModifier = operandModifier[1:]
				if len(operandModifier) == 0 or not operandModifier.isdigit():
					addError(lineNumber, "Error: Improper modifer for symbol in operand")
					operandModiferOperation = ""
					operandModifier = 0
				else:
					operandModifier = int(operandModifier)
	
	# Print the address portion of the line.
	if "hop" in inputLine and "syn" not in inputLine \
			and "isTABLE" not in inputLine and "isBLOCK" not in inputLine:
		hop = inputLine["hop"]
		DM = hop["DM"]
		DS = hop["DS"]
		DLOC = hop["DLOC"]
		IM = hop["IM"]
		IS = hop["IS"]
		S = hop["S"]
		LOC = hop["LOC"]
		if "useDat" in inputLine and inputLine["useDat"]:
			lineFields[sylField] = "%1o" % S
			lineFields[locField] = "%03o" % DLOC
			lineFields[dmField] = "%2o" % DM
			lineFields[dsField] = "%02o" % DS
			#lineFields[adrField] = "%03o" % DLOC
		elif operator in ["DEC", "OCT", "DFW", "BSS", "HPC", "HPCDD"] or operator in forms:
			if ptc:
				lineFields[adrField] = "%03o" % DLOC
			else:
				lineFields[locField] = "%03o" % DLOC
			lineFields[dmField] = "%2o" % DM
			lineFields[dsField] = "%02o" % DS
		elif operator in ["CDS", "CDSS", "CDSD", "SHL", "SHR", "SHF"]:
			lineFields[imField] = "%2o" % IM
			lineFields[isField] = "%02o" % IS
			lineFields[sylField] = "%1o" % S
			lineFields[locField] = "%03o" % LOC
			if ptc:
				lineFields[dmField] = "%2o" % DM
				lineFields[dsField] = "%02o" % DS
		elif operator in ["DEQD", "DEQS"]:
			pass
		else:
			lineFields[imField] = "%2o" % IM
			lineFields[isField] = "%02o" % IS
			lineFields[sylField] = "%1o" % S
			lineFields[locField] = "%03o" % LOC
			lineFields[dmField] = "%2o" % DM
			lineFields[dsField] = "%02o" % DS
	if "useDat" in inputLine:
		useDat = inputLine["useDat"]
	
	# Assemble.
	a81 = "   "
	a9 = " "
	op = "  "
	constantString = ""
	inDataMemory = True
	rawLine = inputLine["raw"]
	if rawLine.lstrip().startswith("TITLE"):
		lfields = rawLine.split("TITLE", 1)
		if len(lfields) != 2:
			continue
		pageTitle = lfields[1].strip().strip("'").replace("''", "'").replace("&&", "&")
		continue
	elif operator == "BSS":
		bssHop = hop.copy()
		for n in range(int(operand)):
			storeAssembled(lineNumber, 0, bssHop)
			bssHop["DLOC"] += 1
	elif ptc and operator == "BCI":
		bciHop = hop.copy()
		text = bciPad(operand[1:-1])
		textLen = len(text)
		# Recall that the test-string operand had previously had
		# its spaces replaced by underlines, and that it needs to
		# both have its delimiters removed and to be padded on the
		# right with spaces to be the proper length for assembly.
		operand = text.replace("_", " ")
		opLen = len(operand)
		#while opLen < textLen:
		#	opLen += 1
		#	operand += " "
		# Now assemble it in blocks of 4 characters per assembled
		# word.  At the same time, create the message that will
		# ultimately be printed in the assembly listing, and 
		# store it back into the input-file array so that it
		# will be available at printout time.
		printArray = []
		for n in range(0, opLen, 4):
			printLine = ""
			octal = 0
			for i in range(4):
				char = operand[n+i]
				if char not in legalCharsBCI:
					addError(lineNumber, "Error: Character %c not legal for BCI" % char)
					char = " "
					printLine += "?"
				else:
					ba8421 = BA8421.index(char)
					if pastBugs:
						printLine += EBCDIClike[ba8421]
					else:
						printLine += char
					octal |= ba8421 << (21 - 6 * i)
			printArray.append(printLine)
			storeAssembled(lineNumber, octal, bciHop)
			bciHop["DLOC"] += 1
		inputFile[lineNumber]["bciLines"] = printArray	
		entry["bciLines"] = printArray
		#addError(lineNumber, "Info: " + str(printArray))
	elif operator == "LIT":
		inLiteralMemory = True
	elif operator == "ENDLIT":
		inLiteralMemory = False
	elif operator in [ "DEC", "OCT", "HPC", "HPCDD", "DFW" ] or operator in forms:
		assembled = 0
		if operator in forms:
			formDef = forms[operator]
			ofields = operand.split(",")
			if len(formDef) != len(ofields):
				addError(lineNumber, "Error: Wrong number of operand fields")
			else:
				try:
					numBits = 0
					cumulative = 0
					for n in range(len(formDef)):
						form = formDef[n]
						last = form[-1:]
						first = form[:-1]
						ofield = ofields[n]
						patternValue = 0
						usageValue = 8
						if last in ["B", "O", "D", "P", "0", "1", "2", 
										"3", "4", "5", "6", "7", "8", "9"] \
								and (first == "" or first.isdigit()):
							if last.isdigit():
								patternValue = int(form)
							else:
								patternValue = int(first)
							if ofield in constants:
								usageValue = constants[ofield]["number"]
							elif "(" in ofield or "B" in ofield:
								value,error = yaEvaluate(ofield, constants)
								if error == "":
									v = value["number"]
									s = 0
									if "scale" in value:
										s = value["scale"]
									if last == "P" and not isinstance(v, int) \
											and "scale" in value:
										s -= 29
									v *= 2**s
									usageValue = hround(v)
								else:
									addError(lineNumber, "Cannot evaluate constant expression (%s)" % ofield)
							elif last == "B":
								usageValue = int(ofield, 2)
							elif last == "O":
								usageValue = int(ofield, 8)
							elif last == "D":
								usageValue = hround(float(ofield))
							elif last == "P":
								usageValue = hround(float(ofield))
							else: # Pure integer
								# This was all that was needed for AS-206RAM.
								usageValue = int(ofield, 8)
						elif form == "DM" and ofield in symbols:
							patternValue = 3
							usageValue = symbols[ofield]["DM"]
						elif form == "DS" and ofield in symbols:
							patternValue = 4
							usageValue = symbols[ofield]["DS"]
						elif form == "DA" and ofield in symbols:
							patternValue = 8
							usageValue = symbols[ofield]["DLOC"]
						elif form in ["DM", "DS", "DA"]:
							addError(lineNumber, \
									"Error: Symbol (%s) not found" % ofield)
						else:
							addError(lineNumber, \
									"Error: Unknown form parameter (%s)" % form)
						ceiling = pow(2, patternValue)
						if usageValue >= ceiling:
							addError(lineNumber, \
								"Error: Field value too large for defined form")
							usageValue = usageValue & (ceiling - 1)
						cumulative = cumulative << patternValue
						cumulative = cumulative | \
									 (usageValue & ((1 << patternValue)-1))
						numBits += patternValue
					if numBits > 26:
						addError(lineNumber, "Error: Form definition was too big")
						cumulative = cumulative >> (numBits - 26)
						numbits = 26
					hopConstant = cumulative << (27 - numBits)
					if (DM,DS,DLOC) in incWorkarounds:
						hopConstant += 2
					elif (DM,DS,DLOC) in decWorkarounds:
						hopConstant -= 2
					constantString = "%09o" % hopConstant
				except:
					addError(lineNumber, "Error: Illegal operand or form definition")
		elif operator == "DEC":
			constantString = convertNumericLiteral(lineNumber, operand)
		elif operator == "OCT":
			constantString = convertNumericLiteral(lineNumber, operand, True)
		elif operator == "HPC":
			ofields = operand.split(",")
			if len(ofields) == 1:
				ofields.append(ofields[0])
			if ofields[0] not in symbols or ofields[1] not in symbols:
				addError(lineNumber, "Error: Symbol(s) not found")
				constantString = ""
			else:
				symbol1 = symbols[ofields[0]]
				symbol2 = symbols[ofields[1]]
				hopConstant = formConstantHOP({
					"IM":  symbol1["IM"],
					"IS":  symbol1["IS"],
					"S":   symbol1["S"],
					"LOC": symbol1["LOC"],
					"DM":  symbol2["DM"],
					"DS":  symbol2["DS"]
				})
				constantString = "%09o" % hopConstant
		elif operator == "HPCDD":
			ofields = operand.split(",")
			if len(ofields) == 2 and ofields[0] in symbols and ofields[1] in symbols:
				symbol1 = symbols[ofields[0]]
				symbol2 = symbols[ofields[1]]
				im = symbol1["IM"]
				isc = symbol1["IS"]
				s = symbol1["S"]
				loc = symbol1["LOC"]
				dm = symbol2["DM"]
				ds = symbol2["DS"]
			elif len(ofields) != 6 or not ofields[0].isdigit() or not ofields[1].isdigit() \
				or not ofields[2].isdigit() or not ofields[3].isdigit() \
				or not ofields[4].isdigit() or not ofields[5].isdigit() \
				or int(ofields[0], 8) > 7 or int(ofields[1], 8) > 15 \
				or int(ofields[2], 8) > 1 or int(ofields[3], 8) > 255 \
				or int(ofields[4], 8) > 7 or int(ofields[5], 8) > 15:
				addError(lineNumber, "Error: Illegal operand for HPC")
				im = 0
				isc = 0
				s = 0
				loc = 0
				dm = 0
				ds = 0
			else:
				im = int(ofields[0], 8)
				isc = int(ofields[1], 8)
				s = int(ofields[2], 8)
				loc = int(ofields[3], 8)
				dm = int(ofields[4], 8)
				ds = int(ofields[5], 8)
			hopConstant = formConstantHOP({"IM":im, "IS":isc, "S":s, "LOC":loc, "DM":dm, "DS":ds})
			constantString = "%09o" % hopConstant
		elif operator == "DFW":
			constantString = ""
			ofields = operand.split(",")
			if len(ofields) != 4:
				addError(lineNumber, "Error: Improperly-formed operand for DFW")
			elif ofields[0] not in operators or ofields[2] not in operators:
				addError(lineNumber, "Error: Unknown operator")
			elif ofields[1] not in symbols:
				addError(lineNumber, "Error: Symbol (%s) not found" % ofields[1])
			elif ofields[3] not in symbols:
				addError(lineNumber, "Error: Symbol (%s) not found" % ofields[3])
			else:
				assembled1 = operators[ofields[0]]["opcode"]
				assembled0 = operators[ofields[2]]["opcode"]
				symbol1 = symbols[ofields[1]]
				symbol0 = symbols[ofields[3]]
				residual1 = 0
				residual0 = 0
				loc1 = symbol1["LOC"]
				loc0 = symbol0["LOC"]
				ds1 = symbol1["DS"]
				ds0 = symbol0["DS"]
				if ds1 not in dfwBits:
					addError(lineNumber, "Error: Wrong sector in DFW constant for syllable 1")
				else:
					residual1 = dfwBits[ds1]["a9"]
					loc1 = (loc1 & ~3) | (dfwBits[ds1]["a2"] << 1) | dfwBits[ds1]["a1"]
				if ds0 not in dfwBits:
					addError(lineNumber, "Error: Wrong sector in DFW constant for syllable 0")
				else:
					residual0 = dfwBits[ds0]["a9"]
					loc0 = (loc0 & ~3) | (dfwBits[ds0]["a2"] << 1) | dfwBits[ds0]["a1"]
				assembled1 |= (residual1 << 4) | (loc1 << 5)
				assembled0 |= (residual0 << 4) | (loc0 << 5)
				hopConstant = (assembled1 << 14) | (assembled0 << 1)
				constantString = "%09o" % hopConstant
		else:
			constantString = ""
		if constantString == "":
			addError(lineNumber, "Error: Invalid operand")
		else:
			assembled = int(constantString, 8)
		# Put the assembled value wherever it's supposed to 
		storeAssembled(lineNumber, assembled, inputLine["hop"])
		if newer and inLiteralMemory and len(constantString) == 9:
			key = "%o_%02o_%s" % (DM, DS, constantString)
			if key not in nameless:
				nameless[key] = DLOC
	elif operator in operators:
		inDataMemory = False
		loc = 0
		residual = 0
		if "a9" in operators[operator]:
			residual = operators[operator]["a9"]
		assembled = operators[operator]["opcode"]
		op = "%02o" % assembled
		if len(operand) == 0:
			addError(lineNumber, "Error: Operand is empty")
		elif operand.isdigit():
			if operator in ["SHL", "SHR"]:
				loc = int(operand)
			else:
				loc = int(operand, 8)
				if loc > 0o777:
					addError(lineNumber, "Error: Operand is out of range")
					loc = 0
		if operator == "EXM":
			ofields = operand.split(",")
			try:
				a76 = int(ofields[0], 8)
				a5 = int(ofields[1], 8)
				a41 = int(ofields[2], 8)
				if a76 > 3 or a5 > 1 or a41 > 15:
					addError(lineNumber, "Error: Illegal operands")
				else:
					loc = (a76 << 5) | (a5 << 4) | a41
					residual = 1
			except:
				addError(lineNumber, "Error: Illegal operands")
		elif operator in ["SHR", "SHL"]:
			if ptc:
				if loc < 1 or loc > 6:
					addError(lineNumber, "Error: Shift count must be 1, 2, 3, 4, 5, or 6")
				else:
					loc = 1 << (loc - 1)
					if operator == "SHR":
						loc |= 0o100
			else:
				if loc == 0:
					pass
				elif operator == "SHR" and loc <= 2:
					pass
				elif operator == "SHL" and loc <= 2:
					loc = loc << 4
				else:
					addError(lineNumber, "Error: Shift count must be 0, 1, or 2")
		elif operator[:3] in ["TRA", "TNZ", "TMI"]:
			if operand == "*":
				loc = LOC
				residual = S
				if operandModifierOperation == "+":
					loc = LOC + operandModifier
				elif operandModifierOperation == "-":
					loc = LOC - operandModifier
				if loc < 0 or loc > 0o377:
					addError(lineNumber, "Error: Target location out of range")
					loc = 0 
					residual = 0
			elif operand.isdigit():
				pass
			elif operand not in symbols:
				addError(lineNumber, "Error: Target location of TRA not found")
			elif symbols[operand]["IM"] == IM and symbols[operand]["IS"] == IS \
					and ((symbols[operand]["DM"] == DM \
					and symbols[operand]["DS"] in [DS, 0o17]) \
						or symbols[operand]["isCDS"] or operand in cdsWorkarounds):
				# Regarding DM/DS, which appears in this conditional, a TRA/TMI/TNZ 
				# instruction doesn't require the target location to be in the same
				# DM/DS, but the original assembler seemed to disallow it.  I assume
				# that's for safety purposes.  On the other hand, even if there's a 
				# DM/DS mismatch, the TRA seems to be allowed if there's a CDS instruction
				# at the target location or if the target is on the residual sector.  
				# Which seems pretty convoluted, though pragmatically reasonable, so I may be
				# misinterpreting what's going on.
				loc = symbols[operand]["LOC"]
				if operandModifierOperation == "+":
					loc += operandModifier
				elif operandModifierOperation == "-":
					loc -= operandModifier
				residual = symbols[operand]["S"]
			elif operator == "TRA":
				# The target location exists, but is not in this IM/IS/DM/DS.
				# We must therefore substitute a HOP instruction instead,
				# and allocate a HOP constant nameless variable.
				hopConstant = formConstantHOP(symbols[operand])
				constantString = "%09o" % hopConstant
				loc,residual = allocateNameless(lineNumber, constantString, newer)
				assembled = operators["HOP"]["opcode"]
				op = "%02o" % assembled
				#addError(lineNumber, "Info: Converting TRA to HOP at %o,%02o,%03o" % (DM, DS, loc))	
				ds = DS
				if residual != 0:
					ds = 0o17
				storeAssembled(lineNumber, hopConstant, {
					"IM": IM,
					"IS": IS,
					"S": residual,
					"LOC": loc,
					"DM": DM,
					"DS": ds,
					"DLOC": loc
				})
				star = True
			else: 
				# For the moment, I'm ignoring the possibility of 
				#	(TMI|TNZ)	SYMBOL(+|-)offset
				# I'm just assuming that the operand is a symbol.
				if operandModifierOperation != "":
					addError(lineNumber, "Error: Not implemented yet")
				
				# Operator is TNZ or TMI and the target is out of the sector.
				# The technique in this case is to use a word at the top of syllable
				# 1 of the sector to store a HOP instruction that gets us to the 
				# target.  The words are used in the order 0o377, 0o376, 0o374 (0o375
				# is alway skipped), 0o373, etc.  Unless there are already
				# data words allocated up there, in which case we start below
				# those data words.
				star = True
				residual = 1
				hopConstant2 = formConstantHOP(symbols[operand])
				constantString = "%09o" % hopConstant2
				try:
					# In looking to see if any suitable HOPs have already been
					# placed at the top of the sector, note such HOPs would 
					# need not only the correct destination address, but would
					# also need to share the same assumptions for data pointers.
					key = "%s_%o_%03o" % (operand, DM, DS)
					hoppedAlready = (key in roofed[IM][IS])
					failed = False
				except:
					addError(lineNumber, "Error: Check for prior HOP failed")
					failed = True
				if not failed:
					start = 0o377
					if IS == 0o17:
						start = 0o374
					if hoppedAlready:
						# An appropriate HOP instruction has already been put at the 
						# end of the sector, so we can just take advantage of it.
						index = roofed[IM][IS].index(key)
						loc = start - index
						if loc <= 0o375 and IS != 0o17:
							loc -= 1
					else:
						# No HOP to this target has been added to the end of the sector,
						# so we must do so now.
						for loc in range(start, -1, -1):
							if memUsed[IM][IS][1][loc] or loc == 0o375:
								continue
							break
						roofed[IM][IS].append(key)
						loc2,residual2 = allocateNameless(lineNumber, constantString, True)
						ds = DS
						if residual2 != 0:
							ds = 0o17
						storeAssembled(lineNumber, hopConstant2, {
							"IM": IM,
							"IS": IS,
							"S": residual2,
							"LOC": loc2,
							"DM": DM,
							"DS": ds,
							"DLOC": loc2
						})
						assembled2 = operators["HOP"]["opcode"]
						assembled2 = (assembled2 | (loc2 << 5) | (residual2 << 4))
						storeAssembled(lineNumber, assembled2, {
							"IM": IM,
							"IS": IS,
							"S": 1,
							"LOC": loc,
							"DM": DM,
							"DS": DS
						}, False)
						memUsed[IM][IS][1][loc] = True
		elif operator == "HOP":
			# Note that the only arithmetical evaluation is for 
			#	symbol+n
			#	symbol-n
			if operand.isdigit():
				#addError(lineNumber, "Info: Converting HOP to TRA")
				pass
			elif operand.startswith("=H'"):
				hopSing = equalsH(operand)
				hopStar(hopSing)
			elif operand not in symbols:
				addError(lineNumber, "Error: Target location of HOP not found")
			else: # The case of "HOP symbol", or "HOP symbol+n", or 
				  # "HOP symbol-n".
				hop2 = copy.deepcopy(symbols[operand])
				# I have no idea what the following is supposed to do if there's
				# overflow or underflow.
				if False and operandModifierOperation != "":
					addError(lineNumber, "Error: Cannot apply + or - in HOP operand")
				elif "inDataMemory" in hop2 and hop2["inDataMemory"]:
					# The operand is a variable, as it ought to be.
					if operandModifierOperation == "+":
						hop2["DLOC"] += operandModifier
					elif operandModifierOperation == "-":
						hop2["DLOC"] -= operandModifier
					#if (not ptc and hop2["DM"] != DM or (hop2["DS"] != DS and hop2["DS"] != 0o17)):
					#	if not useDat: # or S == 1:
					if not inSectorOrResidual(hop2["DM"], hop2["DS"], DM, \
												DS, useDat, udDM, udDS):
						addError(lineNumber, \
								"Error: Operand not in current data-memory sector or residual sector (%o-%02o-%03o)" \
								% (hop2["DM"], hop2["DS"], hop2["DLOC"]))
					loc = hop2["DLOC"]
					residual = residualBit(hop2["DM"], hop2["DS"])
				else:
					if operandModifierOperation == "+":
						hop2["LOC"] += operandModifier
					elif operandModifierOperation == "-":
						hop2["LOC"] -= operandModifier
					# The operand is an LHS in instruction space.  If that's within the 
					# current instruction sector, we should be able to convert the HOP 
					# to a TRA and be done with it, and I could have sworn I saw
					# cases where that had happened. However, I can't find them any
					# longer, and I definitely know cases where that _doesn't_ happen:
					# see HOPs to MMSET.  At any rate, that's why the first half of the
					# conditional was written and then disabled. 
					if False and hop2["IM"] == IM and hop2["IS"] == IS:
						loc = hop2["LOC"]
						residual = hop2["S"]
						assembled = operators["TRA"]["opcode"]
						op = "%02o" % assembled
						#addError(lineNumber, "Info: Converting HOP to TRA")
					else:
						hopStar(hop2)
		elif ptc and operator == "CDS":
			ofields = operand.split(",")
			if len(ofields) != 2 or not ofields[0].isdigit() or not ofields[1].isdigit() or int(ofields[0],8) > 1 or int(ofields[1],8) > 15:
				loc = 0
				addError(lineNumber, "Error: Illegal operand for CDS")
			loc = 0x80 | (int(ofields[0], 8) << 4) | int(ofields[1], 8)
			residual = 0
			#lineFields[adrField] = "%03o" % loc
		elif (not ptc) and operator == "CDS":
			if operand not in symbols:
				addError(lineNumber, "Error: Symbol not found, " + operand)
				loc = 0
			elif "inDataMemory" in symbols[operand] and \
					symbols[operand]["inDataMemory"]:
				loc = 1 | (symbols[operand]["DM"] << 1) | (symbols[operand]["DS"] << 4)
			else:
				loc = 1 | (symbols[operand]["IM"] << 1) | (symbols[operand]["IS"] << 4)
			residual = 0
		elif operator in ["CDSD", "CDSS"]:
			ofields = operand.split(",")
			duplex = 1
			if len(ofields) != 2 or not ofields[0].isdigit() or not ofields[1].isdigit() or int(ofields[0],8) > 7 or int(ofields[1],8) > 15:
				loc = 0
				addError(lineNumber, "Error: Illegal operand for CDSS/CDSD")
			if operator == "CDSS":
				duplex = 0
			loc = duplex | (int(ofields[0], 8) << 1) | (int(ofields[1], 8) << 4)
			residual = 0
		else:
			# Instruction is a "regular" one ... not one of the ones dealt with above.
			searchResidual = True
			if operand [:1] == "=":
				if operand[:3] == "=H'":
					hopSing = equalsH(operand)
					hopConstant = formConstantHOP(hopSing)
					constantString = "%09o" % hopConstant
					searchResidual = False
				elif "(" in operand:
					addError(lineNumber, \
							"Implementation: Expression %s unevaluated" %\
								operand[1:])
					constantString = "000000000"
				else:
					constantString = convertNumericLiteral(lineNumber, operand[1:])
				if constantString == "":
					addError(lineNumber, "Error: Illegal \"=...\" string")
					loc = 0
				else:
					loc,residual = allocateNameless(lineNumber, constantString,\
												    True, searchResidual)
					ds = DS
					if loc > 0o377 or DS == 0o17 or residual != 0:
						loc = loc & 0o377
						residual = 1
						ds = 0o17
					#addError(lineNumber, "Info: Allocating nameless variable for =constant at %o,%02o,%03o" % (DM, ds, loc))
					storeAssembled(lineNumber, int(constantString, 8), {
						"IM": IM,
						"IS": IS,
						"S": residual,
						"LOC": loc,
						"DM": DM,
						"DS": ds,
						"DLOC": loc
					})
			elif operand.isdigit():
				pass
			elif operand in constants and type(constants[operand]) == type([]) and len(constants[operand]) == 4:
				dm = int(constants[operand][1], 8)
				ds = int(constants[operand][2], 8)
				dloc = int(constants[operand][3], 8)
				#if (not ptc and (dm != DM or (ds != DS and ds != 0o17)) or (ptc and ds != 0o17 and not (dm == DM and ds == DS))):
				if not inSectorOrResidual(dm, ds, DM, DS, \
												useDat, udDM, udDS):
					addError(lineNumber, \
							"Error: Operand not in current data-memory sector or residual sector (%o-%02o-%03o)" \
							% (dm, ds, dloc))
				else:
					loc = dloc
					if ds == 0o17:
						residual = 1
			elif operand not in symbols:
				if ptc:
					loc,residual = allocateNameless(lineNumber, operand, useResidual = False)
					#addError(lineNumber, "Error: Symbol (" + operand + ") from operand not found")
				else:
					addError(lineNumber, "Error: Symbol (" + operand + ") from operand not found")
			else: 
				hop2 = symbols[operand]
				if hop2["inDataMemory"]:
					loc = hop2["DLOC"]
					if not inSectorOrResidual(hop2["DM"], hop2["DS"], \
													DM, DS, useDat, udDM, udDS):
						addError(lineNumber, \
								"Error: Operand not in current data-memory sector or residual sector (%o-%02o-%03o)" \
								% (hop2["DM"], hop2["DS"], loc))
					if operandModifierOperation == "+":
						loc += operandModifier
					elif operandModifierOperation == "-":
						loc -= operandModifier
					residual = residualBit(hop2["DM"], hop2["DS"])
				else:
					if hop2["IM"] != DM or (hop2["IS"] != 0o17 and hop2["IS"] != DS):
						if useDat:
							etype = "Warning"
						else:
							etype = "Error"
						if etype == "Error" and (not useDat or S == 1):
							addError(lineNumber, \
									"%s: Operand not in current data-memory sector (%o-%02o-%o-%03o)" \
									% (etype, hop2["IM"], hop2["IS"], hop2["S"], hop2["LOC"]))
					loc = hop2["LOC"]
					if operandModifierOperation == "+":
						loc += operandModifier
					elif operandModifierOperation == "-":
						loc -= operandModifier
					residual = residualBit(hop2["IM"], hop2["IS"])
		if loc > 0o377:
			loc = loc & 0o377
			residual = 1
		if "a8" in operators[operator]:
			loc = (loc & 0o177) | (operators[operator]["a8"] << 7)
		a81 = "%03o" % loc
		a9 = "%o" % residual
		assembled = assembled | (loc << 5) | (residual << 4)
		storeAssembled(lineNumber, assembled, hop, False)
		msg = "%o\t%02o\t%o\t%03o\t%d\t%05o\t%o\t%02o\t%s" \
				% (hop["IM"], hop["IS"], hop["S"], hop["LOC"], lineNumber, 
				assembled, hop["DM"], hop["DS"], inputLine["raw"])
		print(msg, file=f)
	
	if lineNumber != lastLineNumber:
		errorsPrinted = []
		lastLineNumber = lineNumber
	for error in errorList:
		if error[1] not in errorsPrinted:
			errorsPrinted.append(error[1])
			if error[1].startswith("Warning"):
				# It turns out that the original assembler doesn't print few
				# (or perhaps any) explicit warnings as I understand them, 
				# except putting a W in column 1 sometimes.
				if "Skipping memory locations" in error[1]:
					wPending = True
					continue
			msg = "%d: %s" % error
			print(msg)
			if htmlFile != None:
				if error[1].startswith("Error") or \
						error[1].startswith("Implementation") or \
						error[1].startswith("Mismatch"):
					msg = applyClass("fe", msg)
				elif error[1].startswith("Warning") or \
						error[1].startswith("Rounding"):
					msg = applyClass("wn", msg)
				print(msg, file=htmlFile)
	# If jump instructions have been remapped mark them with an asterisk.
	raw = inputLine["raw"]
	if star and operator in ["HOP", "TRA", "TNZ", "TMI"]:
		for n in range(len(raw)):
			if raw[n] in [" ", "\t"]:
				break
		for m in range(n, len(raw)):
			if raw[m] not in [" ", "\t"]:
				break
		m += 3
		if raw[m] == " ":
			raw = raw[:m] + "*" + raw[(m+1):]
		elif raw[m] == "\t":
			raw = raw[:m] + "*" + raw[m:]
	fields = originalLine.split()
	if originalLine[:1] == "#":
		msg = "    " + originalLine
		print(msg)
		if htmlFile != None:
			print(applyClass("mo", msg.replace("<", "&lt;")), file=htmlFile)
		if len(fields) > 1 and fields[1] == "PAGE":
			firstPart = 87
			lenTitle = len(pageTitle)
			leadIn = 35
			leadOut = firstPart - leadIn - lenTitle
			header0 = "%*s%s%*s%25sPAGE %03d" % (leadIn, "", pageTitle, leadOut, 
											"", "", pageNumber)
			msg = "\n" + header0 + "\n\n" + header + "\n"
			print(msg)
			if htmlFile != None:
				print(msg, file=htmlFile)
		
	else:
		if "bciLines" in entry:
			clearLineFields()
		lineFields[opField] = op
		lineFields[constantField] = "%9s" % constantString
		lineFields[expansionField] = expansionMarker
		if "bciLines" in entry and "BCI" in raw and "^" in raw and "$" in raw:
			iBCI = raw.index("BCI")
			iCarat = raw.index("^")
			iDollar = raw.index("$")
			if iBCI < iCarat and iCarat < iDollar:
				raw = raw[:iCarat] + raw[iCarat:iDollar].replace("_", " ") + raw[iDollar:]
		lineFields[rawField] = raw[:71]
		if a9 == "1" or not ptc:
			lineFields[a9Field] = a9
		if lineFields[adrField] == "":
			lineFields[adrField] = a81
		printLineFields()
		if "bciLines" in entry:
			hop = entry["expandedLine"]["hop"]
			for n in range(len(entry["bciLines"])):
				bciLine = entry["bciLines"][n]
				clearLineFields()
				lineFields[dmField] = "%o" % hop["DM"]
				lineFields[dsField] = "%02o" % hop["DS"]
				lineFields[adrField] = "%03o" % (hop["DLOC"] + n)
				lineFields[constantField] = "%-9s" % bciLine
				printLineFields()
		if False and len(fields) > 1 and fields[1] == "MACRO" and fields[0] in macros:
			macroLines = macros[fields[0]]["lines"]
			clearLineFields()
			for ml in macroLines:
				macroLine = lineSplit(ml)
				lineText = ""
				for n in macroLine:
					lineText += "%-8s" % n
				lineFields[rawField] = lineText[:71]
				printLineFields()
			lineFields[rawField] = "        ENDMAC"
			printLineFields()
f.close()

# Highly speculative:  The AS-512 code, at the current state of the assembler
# (2023-06-19) requires a single WORK ROOF workaround, at 6-03-1-370.  Perhaps
# not so coincidentally, a single mismatch of the modern assembly vs the 
# original exists, at 6-03-1-371.  The original assembler fills this location
# with 00000, whereas I see no reason (and nor does the modern assembler) for
# anything to be at this location.  So the modern assembler leaves it 
# uninitialized.  *Perhaps* the original assembler filled this location
# with 00000 as some side-effect of whatever computation it was doing that 
# corresponded to WORK ROOF.  In fact, now that I think of it, filling that
# location with 00000 (or indeed with anything whatsoever) would indeed 
# accomplish what WORK ROOF is doing, namely to force an automatic sector change
# on location earlier than it otherwise would.  The inference is that we should 
# go to all of the roofWorkarounds[] locations and insert 00000 immediately after
# them if those locations are otherwise unused.  If true, it's probably a bug
# in the original assembler that it kept those locations filled with 00000, 
# which really was only a bookkeeping move rather than anything necessary to
# operation.
for w in roofWorkarounds:
	if memUsed[w[0]][w[1]][w[2]][w[3]+1]:
		msg = "Warning: Location following WORK ROOF %o,%02o,%o,%03o already filled" % w
		print(msg)
		if htmlFile != None:
			print(applyClass("wn", msg), file=htmlFile)
		counts["warnings"] += 1
	else:
		storeAssembled(lineNumber, 0o00000, \
					{ "IM": w[0], "IS": w[1], "S": w[2], "LOC": w[3]+1}, False)

if checkTheOctals:
	# While we have now checked all of the assembed values against the 
	# octal cross-check file, it's still possible that the cross-check
	# file contains octals which didn't come from the assembled source
	# code.  We need to check for those.
	for module in range(0, 8, 2):
		for sector in range(16):
			for syllable in range(3):
				for location in range(0o400):
					if ptc and syllable < 2 and octals[module][sector][2][location] != None:
						continue
					assembledOctal = octals[module][sector][syllable][location]
					checkOctal = octalsForChecking[module][sector][syllable][location]
					if assembledOctal == None and checkOctal != None:
						# This is an adequate test for LVDC, but for PTC it's
						# still possible to have gotten to this point and to have
						# a false positive, because the PTC octal listing doesn't
						# distinguish between an entry containg 1 valid data value
						# vs 2 valid instructions.  So we need to apply an additional
						# test to check for that.
						if ptc and syllable == 2:
							continue
						counts["mismatches"] += 1
						msg = "Mismatch: Missing octal at %o,%02o,%o,%03o" \
								%(module,sector,syllable,location)
						print(msg)
						if htmlFile != None:
							print(applyClass("fe", msg), file=htmlFile)

for f in [sys.stdout, htmlFile]:
	if f == None:
		continue
	if f == htmlFile:
		print("\n<hr>", file=f)
		print('<a id="messages"></a><h1>Assembly Messages</h1>', file=f)
	else:
		print("\f", file=f)
		print("", file=f)
		print("Assembly-message summary:", file=f)
	print("\tImplementation errors:  %d" % counts["implementation"], file=f)
	print("\tErrors:                 %d" % counts["errors"], file=f)
	print("\tWarnings:               %d" % counts["warnings"], file=f)
	if checkTheOctals and fuzzy:
		print("\tRounding-mismatches:    %d" % counts["rounding"], file=f)
	if checkTheOctals:
		print("\tMismatches:             %d (vs %s)" % \
				(counts["mismatches"],checkFilename), file=f)
	else:
		print("\tMismatches:             (not checked)", file=f)
	print("\tRollovers:              %d" % countRollovers, file=f)
	print("\tInfos:                  %d" % counts["infos"], file=f)
	print("\tOther:                  %d" % counts["others"], file=f)

#----------------------------------------------------------------------------
#   	Print a symbol table and save as a .sym file too
#----------------------------------------------------------------------------

# First, here are 4 utilities to print out a sequence entries in the form of
# a table with 4 columns.  It's used for all of the tables that follow, not
# just the symbol table.
plainLine = ""
htmlLine = ""
def initializeTable():
	global plainLine, htmlLine
	plainLine = ""
	htmlLine = ""
def flushTable():
	global plainLine, htmlLine
	if len(plainLine) > 0:
		print(plainLine)
		plainLine = ""
	if htmlFile and len(htmlLine) > 0:
		print(htmlLine, file=htmlFile)
		htmlLine = ""
def printToTable(rawEntry, htmlEntry):
	global plainLine, htmlLine
	columnWidth = 38
	nextColumn = (len(plainLine) + columnWidth - 1) // columnWidth
	padLength = nextColumn * columnWidth - len(plainLine)
	if padLength <= 0:
		pad = " "
	else:
		pad = "%*s" % (padLength, "")
	plainLine = plainLine + pad + rawEntry
	htmlLine = htmlLine + pad + htmlEntry
	if nextColumn >= 3:
		flushTable()
def advanceTable():
	flushTable()
	print("")
	if htmlFile != None:
		print("", file=htmlFile)

f = open("yaASM.sym", "w")
print("\n\nSymbol Table:")
print("")
if htmlFile != None:
	print("\n<hr>", file=htmlFile)
	print('<a id="symbols"></a><h1>Symbol Table</h1>', file=htmlFile)
	print("Program labels and variables.\n", file=htmlFile)
initializeTable()
lastInitial = ""
for key in sorted(symbols):
	if key[:1] != lastInitial:
		advanceTable()
		lastInitial = key[:1]
	hop = symbols[key]
	if "inDataMemory" in symbols[key] and symbols[key]["inDataMemory"]:
		msg = "%o %02o   %03o" % (hop["DM"], hop["DS"], 
							hop["DLOC"]) + "  " + key
		if htmlFile == None:
			hmsg = ""
		else:
			hmsg = "%o %02o   %03o" % (hop["DM"], hop["DS"], 
					hop["DLOC"]) + "  " + \
					applyClass("va", key, symbols[key]["anchor"])
		printToTable(msg, hmsg)
			
		syl = 2
		print("%s\t%o\t%02o\t%o\t%03o" % (key, hop["DM"], hop["DS"], syl, hop["DLOC"]), file=f)
	else:
		msg = "%o %02o %o %03o" % (hop["IM"], hop["IS"], hop["S"], 
				hop["LOC"]) + "  " + key
		if htmlFile == None:
			hmsg = ""
		else:
			hmsg = "%o %02o %o %03o" % (hop["IM"], hop["IS"], hop["S"], 
					hop["LOC"]) + "  " + \
					applyClass("sm", key, symbols[key]["anchor"])
		printToTable(msg, hmsg)
		syl = hop["S"]
		print("%s\t%o\t%02o\t%o\t%03o" % (key, hop["IM"], hop["IS"], syl, hop["LOC"]), file=f)
flushTable()

print("\n\nLiteral Table:")
print("")
if htmlFile != None:
	print("\n<hr>", file=htmlFile)
	print('<a id="literals"></a><h1>Literal Table</h1>', file=htmlFile)
	print("Values allocated silently by the assembler.", file=htmlFile)
lastKey = ""
initializeTable()
for key in sorted(nameless):
	loc = nameless[key]
	fields = key.split("_")
	print("%s\t%s\t%s\t2\t%03o" % (fields[2], fields[0], fields[1], loc), file=f)
	newKey = fields[0] + "_" + fields[1]
	if newKey != lastKey:
		advanceTable()
		lastKey = newKey
	msg = fields[0] + " " + fields[1] + "   " + ("%03o" % loc) + "  " + fields[2]
	printToTable(msg, msg)
flushTable()
f.close()

#----------------------------------------------------------------------------
#   	Print a table of constants.
#----------------------------------------------------------------------------

print("\n\nConstant Table:\n")
if htmlFile != None:
	print("\n<hr>", file=htmlFile)
	print('<a id="constants"></a><h1>Constant Table</h1>', file=htmlFile)
	print("Defined via EQU, REQ, DEQD, and DEQS. Suffixes such as #nnn indicate reassigments by REQ.", file=htmlFile)
	print("", file=htmlFile)
initializeTable()
lastInitial = ""
for constant in sorted(constants):
	if constant[:1] != lastInitial:
		advanceTable()
		lastInitial = constant[:1]
	c = constants[constant]
	if "#" not in constant and isinstance(c, dict):
		continue
	if isinstance(c, dict):
		number = str(c["number"])
		if "scale" in c:
			number = number + "B%d" % c["scale"]
	elif isinstance(c, list) and c[0] == "DEQD":
		number = "%o-%02o-%03o" % (int(c[1],8), int(c[2],8), int(c[3],8))
	else:
		number = str(c)
	constant = "%-11s" % constant.replace("#000", "")
	msg = "%s%s" % (constant, number)
	if htmlFile == None:
		hmsg = ""
	else:
		fields = constant.split("#")
		hmsg = "%s%s" % \
				(applyClass("cn", constant, \
						constantAnchors[fields[0].strip()]), number)
	printToTable(msg, hmsg)
flushTable()

#----------------------------------------------------------------------------
#   	Print octal listing and save as a .tsv file too
#----------------------------------------------------------------------------

print("\n\nOctal Listing:")
if htmlFile != None:
	print("\n<hr>", file=htmlFile)
	print('<a id="octals"></a><h1>Octal Listing</h1>', file=htmlFile)
f = open("yaASM.tsv", "w")
formatLine = " %03o"
for n in range(8):
	formatLine += "   %s %1s"
formatFileLine = "%03o"
for n in range(8):
	formatFileLine += "\t%s\t%s"
heading = "      "
firstPage = True
for n in range(8):
	heading += "      %o         " % n
for module in range(8):
	for sector in range(16):
		sectorUsed = False
		for syllable in range(2):
			if sectorUsed:
				break
			for loc in range(256):
				if memUsed[module][sector][syllable][loc]:
					sectorUsed = True
					break
		if not sectorUsed:
			continue
		print("SECTOR\t%o\t%02o" % (module, sector), file=f)
		print("\n\n%57sMODULE %o      SECTOR %02o\n\n" % ("", module, sector))
		print(heading)
		print("")
		if htmlFile != None:
			if not firstPage:
				print("\n<hr>", file=htmlFile)
			firstPage = False
			print("\n\n%57sMODULE %o      SECTOR %02o\n\n" \
				% ("", module, sector), file=htmlFile)
			print(heading, file=htmlFile)
			print("", file=htmlFile)
		for row in range(0, 256, 8):
			rowList = [row]
			for loc in range(row, row + 8):
				if not (memUsed[module][sector][0][loc] \
						or memUsed[module][sector][1][loc]):
					rowList.append("           ")
					rowList.append(" ")
				elif octals[module][sector][2][loc] != None:
					rowList.append(" %09o " % octals[module][sector][2][loc])
					rowList.append("D")
				else:
					col = ""
					usedEntry = False
					for syl in [1, 0]:
						if syl == 0:
							col += " "
						if not memUsed[module][sector][syl][loc]:
							col += "     "
						elif octals[module][sector][syl][loc] == None:
							col += "-----"
							usedEntry = True
						else:
							col += "%05o" % octals[module][sector][syl][loc]
							usedEntry = True
					rowList.append(col)
					if usedEntry:
						rowList.append("D")
					else:
						rowList.append(" ")
			print(formatLine % tuple(rowList))
			if htmlFile != None:
				print(formatLine % tuple(rowList), file=htmlFile)
			print(formatFileLine % tuple(rowList), file=f)
f.close()

# Finish up html version of assembly listing, if any.
if htmlFile != None:
	for line in htmlFooterLines:
		print(line, end="", file=htmlFile)
	htmlFile.close()

if False:
	for key in sorted(nameless):
		print("\"%s\" \"%03o\"" % (key, nameless[key]), file=sys.stderr)

# Prints out some debugging stuff about the order in which symbols are allocated.
# It may be useful for figuring out where the assembly process stuff starts 
# getting allocated to the wrong addresses, but is of no value outside of that
# kind of debugging of the assembler.
if False:
	for record in allocationRecords:
		symbol = record["symbol"]
		inputLine = record["inputLine"]
		lineNumber = record["lineNumber"]
		page = inputLine["page"]
		DM = record["DM"]
		DS = record["DS"]
		LOC = record["LOC"]
		raw = inputLine["raw"]
		print("PAGE=%-3d LINE=%-5d SYMBOL=%-15s DM=%o DS=%02o LOC=%03o:  %s" % (page, lineNumber, symbol, DM, DS, LOC, raw))
	