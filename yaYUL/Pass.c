/*
 * Copyright 2003-2005,2009,2016-2018,2021 Ronald S. Burkey <info@sandroid.org>
 *
 * This file is part of yaAGC.
 *
 * yaAGC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * yaAGC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with yaAGC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Filename:    yaYUL.c
 * Purpose:     This is an assembler for Apollo Guidance Computer (AGC)
 *              assembly language.  It is called yaYUL because the original
 *              assembler was called YUL, and this "yet another YUL".
 * Mod History: 04/11/03 RSB    Began.
 *              07/03/04 RSB    Provided for placing the object code into
 *                              the object code buffer for subsequent
 *                              output to a file.
 *              07/04/04 RSB    For multi-word pseudo-ops like 2DEC, only
 *                              the first word was being written to the
 *                              binary.
 *              07/05/04 RSB    Added KeepExtend, to fix the INDEX instruction
 *                               resetting the Extend flag.
 *              07/23/04 RSB    Continued changes relating to interpretive
 *                              opcodes and operands.
 *              07/17/05 RSB    Fixed some structure-initializer problems
 *                              I discovered when trying to compile for
 *                              Kubuntu-PPC.
 *              07/27/05 JMS    Added support for symbolic debugging output.
 *              07/28/05 JMS    Added support for writing SymbolLines_to to symbol
 *                              table file.
 *              06/27/09 RSB    Began adding support for HtmlOut.
 *              06/29/09 RSB    Added some fixes for BASIC vs. PSEUDO-OP in
 *                              HTML colorizing.
 *              06/30/09 RSB    Added the feature of inserting arbitrary
 *                              HTML documentation.
 *              07/01/09 RSB    Altered style of comments in HTML.  Shortened
 *                              up symbol hyperlinks, where they're local to
 *                              the file.
 *              07/26/09 RSB    Fixed, I hope, some of the wrong colorization
 *                              that occurs occasionally when two interpretive
 *                              opcodes appear on the same line.
 *              2009-03-09 JL   Fixed an issue with CHECK= causing duplicate symbols.
 *                              Treat CHECK= like MEMORY when parsing labels.
 *              2012-10-08 JL   Initialise SB to 1 rather than 0.
 *              2016-08-18 RSB  Moved global variables originally allocated
 *                              in yaYUL.h, conditionally on the ORIGINAL_PASS_C
 *                              constant, directly into this file.  It's just too
 *                              difficult to work with them through the Eclipse IDE
 *                              otherwise, since the IDE can't resolve any of them.
 *              2016-08-19 RSB  Various Block 1 changes.  Perhaps more importantly,
 *                              no longer dependent on whether tabs vs. spaces
 *                              were used in the source files.
 *              2016-08-22 RSB	Implemented the pre-operator '-' across the board for
 *                              block 1.
 *              2016-08-29 RSB  Implemented Mike Stewart's fix for bug
 *                              https://github.com/rburkey2005/virtualagc/issues/45.
 *              2016-09-18 RSB	For --block1, changed NOOP from being a synonym
 *                              for XCH A to XCH 0; the only difference is that XCH A requires an
 *                              A = 0 pseudo-op (which Solarium, I guess, must already have had),
 *                              whereas XCH 0 does not.
 *              2016-09-28 RSB  With --format, interpretive operands were aligned
 *                              properly only for --block1.
 *             	2016-10-08 RSB	Added detection of file header consisting of a bunch
 *             			of ## or blank lines, using the inHeader state variable.
 *             	2016-10-12 RSB  Updated for --blk2.
 *             	2016-10-20 RSB  When the operand for CADR was a simple number, it was
 *             	                incorrectly treating it as an offset to the current location
 *             	                rather than a full pseudo-address.
 *              2016-10-21 RSB  Added some --blk2 interpreter fixes and changes to handling
 *                              of CADR and TC without operands sent in by Hartmuth Gutsche.
 *              2016-10-31 RSB  Added ITCQ as synonym for RVQ.
 *              2016-11-02 RSB  Now assumes that the left-hand interpretive operator can't
 *                              begin past column 17.  Had to do this because there's a
 *                              case in Sunburst where an interpretive operand (NORM) has
 *                              the same name as an interpregive operator (yes, you guessed
 *                              it ... NORM!), and otherwise there's no way to distinguish
 *                              them.  Changed handling of BBCON* (which was previously
 *                              hard-coded, but which no longer works in Sunburst, so now
 *                              operates, hopefully correctly, on the actual address).
 *                              Behavior of TC without an operand has been extended to
 *                              all targets (was previously just for block 1 and BLK2).
 *              2016-11-03 RSB  Added the "unestablished" state for superbits, required
 *                              for Sunburst 120.  Also, detecting the ## header didn't
 *                              work quite right if the first non-header line was "## Page N".
 *              2016-11-11 RSB  Added a heap of stuff for accepting either .agc
 *                              or .yul files (where the description of the
 *                              latter comes from the "Preliminary MOD 3C
 *                              Programmer's Manual", or a mixture, transparently
 *                              converting .yul to .agc internally on-the-fly.
 *                              It *almost* works, but not quite yet.
 *              2016-11-14 RSB  Added the '#>' construct in .yul files.  Added
 *                              --to-yul.
 *              2016-12-18 MAS  Added the "LOC" alias for SETLOC. Also altered
 *                              processing of numeric opcodes, determining if
 *                              a double-word operation is being assembled, and incrementing
 *                              the operand if so. This is needed for a word in the Retread
 *                              instruction checks.
 *              2017-01-05 RSB  Added BBCON* as distinct from BBCON.
 *              2017-01-27 MAS  Added "MSK" as an alias for "MASK", as supported by the
 *                              Raytheon assembler.
 *              2017-01-30 MAS  Added an array to store parity bites calculated on the fly,
 *                              for use with --hardware.
 *              2017-02-05 MAS  Added BBCON* handling to BLK2 as well.
 *              2017-06-17 MAS  Refactored superbank handling. Now any operation which
 *                              emits a word will update the current superbank. Also added
 *                              --early-sbank, which makes yaYUL use pre-1967 YUL behavior
 *                              when handling superbank bits.
 *             	2017-08-31 RSB	It seems as though for --block1, the variable NumInterpretiveOperands
 *             			was used without regard to the fact that it was sometimes used in
 *             			conjunction with RawNumInterpretiveOperands (which wasn't changed).
 *             			The result is that --block1 assembly was working essentially by
 *             			accident, and similarly was failing by accident in Mac OS X.
 *            	2018-10-12 RSB	Added --simulation stuff.
 *            	2021-01-24 RSB  Added a "Reconstruction" marker in .lst files.
 *
 * I don't really try to duplicate the formatting used by the original
 * assembly-language code, since that format was appropriate for
 * punch-cards, but not really for decent text editors.  [As near as I
 * can tell by just reading the source code, it appeared to involved
 * fixed-size fields:  (perhaps) nothing in column 1 (or maybe something
 * to indicate a remark), 8 characters for a label (but ignored if blank
 * in column 2), blank, 6 characters for opcode, blank, etc.]  It's
 * particularly easy to ignore the original format, since I don't have
 * any machine-readable AGC source code anyhow.  Since it all has to be
 * entered manually, it may as well be a more-flexible format.  So
 * here's how it will go:
 *
 *      Labels begin in column 1.
 *      The next field is the opcode or pseudo op (preferably at column 16).
 *      The next field is the operand, if any.
 *      Comments are anything following a pound #.
 *
 * An exception is anything that looks like +%d or -%d in col. 2.  (These
 * notations are just ignored.)
 *
 * Additionally, arbitrary HTML can be inserted.  This HTML vanishes as
 * far as the assembly or the output assembly listing is concerned, but
 * is inserted verbatim into output HTML (when the --html switch is used).
 * The insert begins with a line containing the tag <HTML> (and nothing
 * more) and ends with a line containing the tag </HTML> (and nothing
 * more).  There is no check to see that the HTML is legitimate.
 */

#include "yaYUL.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

//-------------------------------------------------------------------------
// Some global data.

Line_t CurrentFilename;
int CurrentLineInFile = 0;
int thisIsTheLastPass = 0;

// We allow a certain number of levels of include files.  To handle this,
// we need a stack of input files.
#define MAX_STACKED_INCLUDES 5
static int NumStackedIncludes = 0;
typedef struct
{
  FILE *InputFile;
  Line_t InputFilename;
  int CurrentLineInFile;
  FILE *HtmlOut;
  int yulType; // 0 for .agc, 1 for .yul.
} StackedInclude_t;
static StackedInclude_t StackedIncludes[MAX_STACKED_INCLUDES];

// Some dummy strings for parsing an input line.
static Line_t Fields[6];
static int NumFields = 0;

char *assemblyTarget = "AGC4";
int Block1 = 0;
int EarlySBank = 0;
int Raytheon = 0;
int blk2 = 0;
int Html = 0;
FILE *HtmlOut = NULL;
int inHeader = 1;

// Data structure used to map opcode or pseudo-op names to function calls.
// Basically, for each opcode or pseudo-op, there is an external
// parser function which can be called.  Aliases such as RELINT, which
// are intended to be replaced automatically by other instructions, are
// also included.  This table is explicitly sorted (by the operand name)
// before use at runtime, to allow binary searches.
//
// The table works as follows:  If the function pointer is NULL, then
// the Operator and Operand fields are assumed to contain an alias for
// the opcode, and the alias is used instead of the original opcode.
// If, further, Operator is empty, then the entire opcode is simply
// silently discarded.  This is good for things like BNKSUM, which
// apparently were useful long ago, but are not useful in the present
// context.
//
// Note that the solution for given below for EDRUPT
// isn't a perfect equivalent for an actual EDRUPT parser
// within the assembler, since it doesn't allow the assembler to check
// for the EXTEND bit as it does for other instructions.  However, as EDRUPT
// is used "for machine checkout only", I can't imagine that I even need
// it at all ... so I'm willing to dispense with a little cross-checking.
//
// This is the table of basic instructions used by default, and is
// the correct one for most AGC software.
static ParserMatch_t ParsersBlock2[] =
  {
    { "-1DNADR", OP_DOWNLINK, ParseECADR, "", "", 0, 077777 },
    { "-2CADR", OP_PSEUDO, Parse2CADR, "", "", 0, 077777, 0, 077777 },
    { "-2DNADR", OP_DOWNLINK, ParseECADR, "", "", 004000, 077777 },
    { "-3DNADR", OP_DOWNLINK, ParseECADR, "", "", 010000, 077777 },
    { "-4DNADR", OP_DOWNLINK, ParseECADR, "", "", 014000, 077777 },
    { "-5DNADR", OP_DOWNLINK, ParseECADR, "", "", 020000, 077777 },
    { "-6DNADR", OP_DOWNLINK, ParseECADR, "", "", 024000, 077777 },
    { "-CCS", OP_BASIC, ParseCCS, "", "", 0, 077777 },
    { "-DNCHAN", OP_DOWNLINK, ParseDNCHAN, "", "", 0, 077777 },
    { "-DNPTR", OP_DOWNLINK, ParseGENADR, "", "", 030000, 077777 },
    { "-GENADR", OP_PSEUDO, ParseGENADR, "", "", 0, 077777 },
    { "=", OP_PSEUDO, ParseEquate },
    { "=ECADR", OP_PSEUDO, ParseEqualsECADR },
    { "=MINUS", OP_PSEUDO, ParseEqMinus },
    { "1DNADR", OP_DOWNLINK, ParseECADR, "", "", 0, 0 },
    { "2BCADR", OP_PSEUDO, Parse2CADR },
    { "2CADR", OP_PSEUDO, Parse2CADR },
    { "2DEC", OP_PSEUDO, Parse2DEC },
    { "2DEC*", OP_PSEUDO, Parse2DECstar },
    { "2DNADR", OP_DOWNLINK, ParseECADR, "", "", 004000, 0 },
    { "2FCADR", OP_PSEUDO, Parse2FCADR },
    { "2OCT", OP_PSEUDO, Parse2OCT },
    { "3DNADR", OP_DOWNLINK, ParseECADR, "", "", 010000, 0 },
    { "4DNADR", OP_DOWNLINK, ParseECADR, "", "", 014000, 0 },
    { "5DNADR", OP_DOWNLINK, ParseECADR, "", "", 020000, 0 },
    { "6DNADR", OP_DOWNLINK, ParseECADR, "", "", 024000, 0 },
    { "AD", OP_BASIC, ParseAD },
    { "ADRES", OP_PSEUDO, ParseGENADR },
    { "ADS", OP_BASIC, ParseADS },
    { "AUG", OP_BASIC, ParseAUG },
    { "BANK", OP_PSEUDO, ParseBANK },
    { "BLOCK", OP_PSEUDO, ParseBLOCK },
    { "BBCON", OP_PSEUDO, ParseBBCON },
  /*{ "BBCON*", OP_PSEUDO, NULL, "OCT", "66100" },*/
    { "BBCON*", OP_PSEUDO, ParseBBCONstar },
    { "BNKSUM", OP_PSEUDO, NULL, "", "" },
    { "BZF", OP_BASIC, ParseBZF },
    { "BZMF", OP_BASIC, ParseBZMF },
    { "CA", OP_BASIC, ParseCA },
    { "CAE", OP_BASIC, ParseCAE },
    { "CAF", OP_BASIC, ParseCAF },
    { "CADR", OP_PSEUDO, ParseCADR, "", "", 0, 0, 0, 0, 1 },
    { "CCS", OP_BASIC, ParseCCS },
    { "CHECK=", OP_PSEUDO, ParseCHECKequals },
    { "COM", OP_BASIC, NULL, "CS", "A" },
    { "COUNT", OP_PSEUDO, NULL, "", "" },
    { "COUNT*", OP_PSEUDO, NULL, "", "" },
    { "CS", OP_BASIC, ParseCS },
    { "DAS", OP_BASIC, ParseDAS },
    { "DCA", OP_BASIC, ParseDCA },
    { "DCOM", OP_BASIC, NULL, "DCS", "A" },
    { "DCS", OP_BASIC, ParseDCS },
    { "DDOUBL", OP_BASIC, NULL, "DAS", "A" },
    { "DEC", OP_PSEUDO, ParseDEC, "", "", 0, 0, 0, 0, 1 },
    { "DEC*", OP_PSEUDO, ParseDECstar },
    { "DIM", OP_BASIC, ParseDIM },
    { "DNCHAN", OP_DOWNLINK, ParseDNCHAN },
    { "DNPTR", OP_DOWNLINK, ParseGENADR, "", "", 030000, 0 },
    { "DOUBLE", OP_BASIC, NULL, "AD", "A" },
    { "DTCB", OP_BASIC, NULL, "DXCH", "Z" },
    { "DTCF", OP_BASIC, NULL, "DXCH", "$4" },
    { "DV", OP_BASIC, ParseDV },
    { "DXCH", OP_BASIC, ParseDXCH },
    { "EBANK=", OP_PSEUDO, ParseEBANKEquals },
    { "ECADR", OP_PSEUDO, ParseECADR, "", "", 0, 0, 0, 0, 1 },
    { "EDRUPT", OP_BASIC, ParseEDRUPT },
    { "EQUALS", OP_PSEUDO, ParseEQUALS },
    { "ERASE", OP_PSEUDO, ParseERASE },
    { "EXTEND", OP_BASIC, NULL, "TC", "$6" },
    { "FCADR", OP_PSEUDO, ParseFCADR, "", "", 0, 0, 0, 0, 1 },
    { "GENADR", OP_PSEUDO, ParseGENADR },
    { "INCR", OP_BASIC, ParseINCR },
    { "INDEX", OP_BASIC, ParseINDEX },
    { "INHINT", OP_BASIC, NULL, "TC", "$4" },
    { "LXCH", OP_BASIC, ParseLXCH },
    { "MASK", OP_BASIC, ParseMASK },
    { "MSK", OP_BASIC, ParseMASK },
    { "MEMORY", OP_PSEUDO, NULL, "", "" },
    { "MM", OP_PSEUDO, ParseDEC },
    { "MP", OP_BASIC, ParseMP },
    { "MSU", OP_BASIC, ParseMSU },
    { "NDX", OP_BASIC, ParseINDEX },
    { "NV", OP_PSEUDO, ParseVN, "", "", 0, 0, 0, 0, 1 },
    { "OCT", OP_PSEUDO, ParseOCT, "", "", 0, 0, 0, 0, 1 },
    { "OCTAL", OP_PSEUDO, ParseOCT, "", "", 0, 0, 0, 0, 1 },
    { "OVSK", OP_BASIC, NULL, "TS", "A" },
    { "QXCH", OP_BASIC, ParseQXCH },
    { "RAND", OP_BASIC, ParseRAND },
    { "READ", OP_BASIC, ParseREAD },
    { "RELINT", OP_BASIC, NULL, "TC", "$3" },
    { "REMADR", OP_PSEUDO, ParseGENADR },
    { "RESUME", OP_BASIC, NULL, "INDEX", "$17" },
    { "RETURN", OP_BASIC, NULL, "TC", "Q" },
    { "ROR", OP_BASIC, ParseROR },
    { "RXOR", OP_BASIC, ParseRXOR },
    { "SBANK=", OP_PSEUDO, ParseSBANKEquals },
    { "SECSIZ", OP_PSEUDO, ParseSECSIZ },
    { "SETLOC", OP_PSEUDO, ParseSETLOC },
    { "SQUARE", OP_BASIC, NULL, "MP", "A" },
    { "STCALL", OP_INTERPRETER, ParseSTCALL },
    { "STODL", OP_INTERPRETER, ParseSTODL },
    { "STODL*", OP_INTERPRETER, ParseSTODL, "", "", 04000 },
    { "STORE", OP_INTERPRETER, ParseSTORE },
    { "STOVL", OP_INTERPRETER, ParseSTOVL },
    { "STOVL*", OP_INTERPRETER, ParseSTOVL, "", "", 04000 },
    { "SU", OP_BASIC, ParseSU },
    { "SUBRO", OP_PSEUDO, NULL, "" "" },
    { "TC", OP_BASIC, ParseTC },
    { "TCR", OP_BASIC, ParseTC },
    { "TCAA", OP_BASIC, NULL, "TS", "Z" },
    { "TCF", OP_BASIC, ParseTCF },
    { "TS", OP_BASIC, ParseTS },
    { "VN", OP_PSEUDO, ParseVN, "", "", 0, 0, 0, 0, 1 },
    { "WAND", OP_BASIC, ParseWAND },
    { "WOR", OP_BASIC, ParseWOR },
    { "WRITE", OP_BASIC, ParseWRITE },
    { "XCH", OP_BASIC, ParseXCH },
    { "XLQ", OP_BASIC, NULL, "TC", "L" },
    { "XXALQ", OP_BASIC, NULL, "TC", "A" },
    { "ZL", OP_BASIC, NULL, "LXCH", "$7" },
    { "ZQ", OP_BASIC, NULL, "QXCH", "$7" } };
#define NUM_PARSERS_BLOCK2 (sizeof (ParsersBlock2) / sizeof (ParsersBlock2[0]))

// This is the table of basic instructions for BLK2.  It is almost
// identical to ParsersBlock2[], but look at STORE, STODL, STOVL, STCALL, LOC.
static ParserMatch_t ParsersBLK2[] =
  {
    { "-1DNADR", OP_DOWNLINK, ParseECADR, "", "", 0, 077777 },
    { "-2CADR", OP_PSEUDO, Parse2CADR, "", "", 0, 077777, 0, 077777 },
    { "-2DNADR", OP_DOWNLINK, ParseECADR, "", "", 004000, 077777 },
    { "-3DNADR", OP_DOWNLINK, ParseECADR, "", "", 010000, 077777 },
    { "-4DNADR", OP_DOWNLINK, ParseECADR, "", "", 014000, 077777 },
    { "-5DNADR", OP_DOWNLINK, ParseECADR, "", "", 020000, 077777 },
    { "-6DNADR", OP_DOWNLINK, ParseECADR, "", "", 024000, 077777 },
    { "-CCS", OP_BASIC, ParseCCS, "", "", 0, 077777 },
    { "-DNCHAN", OP_DOWNLINK, ParseDNCHAN, "", "", 0, 077777 },
    { "-DNPTR", OP_DOWNLINK, ParseGENADR, "", "", 030000, 077777 },
    { "-GENADR", OP_PSEUDO, ParseGENADR, "", "", 0, 077777 },
    { "=", OP_PSEUDO, ParseEquate },
    { "=ECADR", OP_PSEUDO, ParseEqualsECADR },
    { "=MINUS", OP_PSEUDO, ParseEqMinus },
    { "1DNADR", OP_DOWNLINK, ParseECADR, "", "", 0, 0 },
    { "2BCADR", OP_PSEUDO, Parse2CADR },
    { "2CADR", OP_PSEUDO, Parse2CADR },
    { "2DEC", OP_PSEUDO, Parse2DEC },
    { "2DEC*", OP_PSEUDO, Parse2DECstar },
    { "2DNADR", OP_DOWNLINK, ParseECADR, "", "", 004000, 0 },
    { "2FCADR", OP_PSEUDO, Parse2FCADR },
    { "2OCT", OP_PSEUDO, Parse2OCT },
    { "3DNADR", OP_DOWNLINK, ParseECADR, "", "", 010000, 0 },
    { "4DNADR", OP_DOWNLINK, ParseECADR, "", "", 014000, 0 },
    { "5DNADR", OP_DOWNLINK, ParseECADR, "", "", 020000, 0 },
    { "6DNADR", OP_DOWNLINK, ParseECADR, "", "", 024000, 0 },
    { "AD", OP_BASIC, ParseAD },
    { "ADRES", OP_PSEUDO, ParseGENADR },
    { "ADS", OP_BASIC, ParseADS },
    { "AUG", OP_BASIC, ParseAUG },
    { "BANK", OP_PSEUDO, ParseBANK },
    { "BLOCK", OP_PSEUDO, ParseBLOCK },
    { "BBCON", OP_PSEUDO, ParseBBCON },
  /*{ "BBCON*", OP_PSEUDO, NULL, "OCT", "66100" },*/
    { "BBCON*", OP_PSEUDO, ParseBBCONstar },
    { "BNKSUM", OP_PSEUDO, NULL, "", "" },
    { "BZF", OP_BASIC, ParseBZF },
    { "BZMF", OP_BASIC, ParseBZMF },
    { "CA", OP_BASIC, ParseCA },
    { "CAE", OP_BASIC, ParseCAE },
    { "CAF", OP_BASIC, ParseCAF },
    { "CADR", OP_PSEUDO, ParseCADR, "", "", 0, 0, 0, 0, 1 },
    { "CCS", OP_BASIC, ParseCCS },
    { "CHECK=", OP_PSEUDO, ParseCHECKequals },
    { "COM", OP_BASIC, NULL, "CS", "A" },
    { "COUNT", OP_PSEUDO, NULL, "", "" },
    { "COUNT*", OP_PSEUDO, NULL, "", "" },
    { "CS", OP_BASIC, ParseCS },
    { "DAS", OP_BASIC, ParseDAS },
    { "DCA", OP_BASIC, ParseDCA },
    { "DCOM", OP_BASIC, NULL, "DCS", "A" },
    { "DCS", OP_BASIC, ParseDCS },
    { "DDOUBL", OP_BASIC, NULL, "DAS", "A" },
    { "DEC", OP_PSEUDO, ParseDEC, "", "", 0, 0, 0, 0, 1 },
    { "DEC*", OP_PSEUDO, ParseDECstar },
    { "DIM", OP_BASIC, ParseDIM },
    { "DNCHAN", OP_DOWNLINK, ParseDNCHAN },
    { "DNPTR", OP_DOWNLINK, ParseGENADR, "", "", 030000, 0 },
    { "DOUBLE", OP_BASIC, NULL, "AD", "A" },
    { "DTCB", OP_BASIC, NULL, "DXCH", "Z" },
    { "DTCF", OP_BASIC, NULL, "DXCH", "$4" },
    { "DV", OP_BASIC, ParseDV },
    { "DXCH", OP_BASIC, ParseDXCH },
    { "EBANK=", OP_PSEUDO, ParseEBANKEquals },
    { "ECADR", OP_PSEUDO, ParseECADR, "", "", 0, 0, 0, 0, 1 },
    { "EDRUPT", OP_BASIC, ParseEDRUPT },
    { "EQUALS", OP_PSEUDO, ParseEQUALS },
    { "ERASE", OP_PSEUDO, ParseERASE },
    { "EXTEND", OP_BASIC, NULL, "TC", "$6" },
    { "FCADR", OP_PSEUDO, ParseFCADR, "", "", 0, 0, 0, 0, 1 },
    { "GENADR", OP_PSEUDO, ParseGENADR },
    { "INCR", OP_BASIC, ParseINCR },
    { "INDEX", OP_BASIC, ParseINDEX },
    { "INHINT", OP_BASIC, NULL, "TC", "$4" },
    { "LOC", OP_PSEUDO, ParseSETLOC },
    { "LXCH", OP_BASIC, ParseLXCH },
    { "MASK", OP_BASIC, ParseMASK },
    { "MEMORY", OP_PSEUDO, NULL, "", "" },
    { "MM", OP_PSEUDO, ParseDEC },
    { "MP", OP_BASIC, ParseMP },
    { "MSU", OP_BASIC, ParseMSU },
    { "NDX", OP_BASIC, ParseINDEX },
    { "NV", OP_PSEUDO, ParseVN, "", "", 0, 0, 0, 0, 1 },
    { "OCT", OP_PSEUDO, ParseOCT, "", "", 0, 0, 0, 0, 1 },
    { "OCTAL", OP_PSEUDO, ParseOCT, "", "", 0, 0, 0, 0, 1 },
    { "OVSK", OP_BASIC, NULL, "TS", "A" },
    { "QXCH", OP_BASIC, ParseQXCH },
    { "RAND", OP_BASIC, ParseRAND },
    { "READ", OP_BASIC, ParseREAD },
    { "RELINT", OP_BASIC, NULL, "TC", "$3" },
    { "REMADR", OP_PSEUDO, ParseGENADR },
    { "RESUME", OP_BASIC, NULL, "INDEX", "$17" },
    { "RETURN", OP_BASIC, NULL, "TC", "Q" },
    { "ROR", OP_BASIC, ParseROR },
    { "RXOR", OP_BASIC, ParseRXOR },
    { "SBANK=", OP_PSEUDO, ParseSBANKEquals },
    { "SECSIZ", OP_PSEUDO, ParseSECSIZ },
    { "SETLOC", OP_PSEUDO, ParseSETLOC },
    { "SQUARE", OP_BASIC, NULL, "MP", "A" },
    { "STCALL", OP_INTERPRETER, ParseSTCALL },
    { "STODL", OP_INTERPRETER, ParseSTODL },
    { "STODL*", OP_INTERPRETER, ParseSTODL, "", "", 06000 },
    { "STORE", OP_INTERPRETER, ParseSTORE },
    { "STOVL", OP_INTERPRETER, ParseSTOVL },
    { "STOVL*", OP_INTERPRETER, ParseSTOVL, "", "", 06000 },
    { "SU", OP_BASIC, ParseSU },
    { "SUBRO", OP_PSEUDO, NULL, "" "" },
    { "TC", OP_BASIC, ParseTC },
    { "TCR", OP_BASIC, ParseTC },
    { "TCAA", OP_BASIC, NULL, "TS", "Z" },
    { "TCF", OP_BASIC, ParseTCF },
    { "TS", OP_BASIC, ParseTS },
    { "VN", OP_PSEUDO, ParseVN, "", "", 0, 0, 0, 0, 1 },
    { "WAND", OP_BASIC, ParseWAND },
    { "WOR", OP_BASIC, ParseWOR },
    { "WRITE", OP_BASIC, ParseWRITE },
    { "XCH", OP_BASIC, ParseXCH },
    { "XLQ", OP_BASIC, NULL, "TC", "L" },
    { "XXALQ", OP_BASIC, NULL, "TC", "A" },
    { "ZL", OP_BASIC, NULL, "LXCH", "$7" },
    { "ZQ", OP_BASIC, NULL, "QXCH", "$7" } };
#define NUM_PARSERS_BLK2 (sizeof (ParsersBLK2) / sizeof (ParsersBLK2[0]))

// This is the table of basic instructions for all Block 1 AGC software,
// as far as I know.
static ParserMatch_t ParsersBlock1[] =
  {
    { "=", OP_PSEUDO, ParseEquate },
    { "2DEC", OP_PSEUDO, Parse2DEC },
    { "2DEC*", OP_PSEUDO, Parse2DECstar },
    { "2OCT", OP_PSEUDO, Parse2OCT },
    { "AD", OP_BASIC, ParseAD },
    { "ADRES", OP_PSEUDO, ParseGENADR },
    { "BANK", OP_PSEUDO, ParseBANK },
    { "CAF", OP_BASIC, ParseXCH },
    { "CADR", OP_PSEUDO, ParseCADR, "", "", 0, 0, 0, 0, 1 },
    { "CCS", OP_BASIC, ParseCCS },
    { "COM", OP_BASIC, NULL, "CS", "0" },
    { "CS", OP_BASIC, ParseCS },
    { "DEC", OP_PSEUDO, ParseDEC, "", "", 0, 0, 0, 0, 1 },
    { "DOUBLE", OP_BASIC, NULL, "AD", "0" },
    { "DV", OP_BASIC, ParseDV },
    { "EQUALS", OP_PSEUDO, ParseEQUALS },
    { "ERASE", OP_PSEUDO, ParseERASE },
    { "EXTEND", OP_BASIC, NULL, "INDEX", "$5777" },
    { "INDEX", OP_BASIC, ParseINDEX },
    { "INHINT", OP_BASIC, NULL, "INDEX", "$17" },
    { "MASK", OP_BASIC, ParseMASK },
    { "MP", OP_BASIC, ParseMP },
    { "NDX", OP_BASIC, ParseINDEX },
    { "NOOP", OP_BASIC, NULL, "XCH", "0" },
    { "OCT", OP_PSEUDO, ParseOCT, "", "", 0, 0, 0, 0, 1 },
    { "OCTAL", OP_PSEUDO, ParseOCT, "", "", 0, 0, 0, 0, 1 },
    { "OVIND", OP_BASIC, ParseTS },
    { "OVSK", OP_BASIC, NULL, "TS", "0" },
    { "RELINT", OP_BASIC, NULL, "INDEX", "$16" },
    { "RESUME", OP_BASIC, NULL, "INDEX", "$25" },
    { "RETURN", OP_BASIC, NULL, "TC", "1" },
    { "SECSIZ", OP_PSEUDO, ParseSECSIZ },
    { "SETLOC", OP_PSEUDO, ParseSETLOC },
    { "SQUARE", OP_BASIC, NULL, "MP", "0" },
    { "STORE", OP_INTERPRETER, ParseSTORE },
    { "SU", OP_BASIC, ParseSU },
    { "TC", OP_BASIC, ParseTC },
    { "TCR", OP_BASIC, ParseTC },
    { "TCAA", OP_BASIC, NULL, "TS", "2" },
    { "TS", OP_BASIC, ParseTS },
    { "XAQ", OP_BASIC, NULL, "TC", "0" },
    { "XCADR", OP_PSEUDO, ParseXCADR, "", "", 0, 0, 0, 0, 1 },
    { "XCH", OP_BASIC, ParseXCH } };
#define NUM_PARSERS_BLOCK1 (sizeof (ParsersBlock1) / sizeof (ParsersBlock1[0]))

static ParserMatch_t *Parsers = ParsersBlock2;
static int NUM_PARSERS = NUM_PARSERS_BLOCK2;

// This is the default table of interpreter instructions, and
// is the one used for all Block 2 software except the BLK2 target
// (i.e., when the --blk2 command-line switch is used).
// This table has been pre-sorted and should be kept that way.
// Note that STCALL, STODL, STORE, and STOVL are implemented as
// aliases for basic instructions, and so don't appear here.
static InterpreterMatch_t InterpreterOpcodesBlock2[] =
  {
    { "ABS", 0130, 0 },
    { "ABVAL", 0130, 0 },
    { "ARCCOS", 0050, 0 },
    { "ACOS", 0050, 0 },
    { "ARCSIN", 0040, 0 },
    { "ASIN", 0040, 0 },
    { "AXC,1", 0016, 1 },
    { "AXC,2", 0012, 1 },
    { "AXT,1", 0006, 1 },
    { "AXT,2", 0002, 1 },
    { "BDDV", 0111, 1, 0, 000000,
      { 1, 0 } },
    { "BDDV*", 0113, 1, 0, 000000,
      { 1, 0 } },
    { "BDSU", 0155, 1, 0, 000000,
      { 1, 0 } },
    { "BDSU*", 0157, 1, 0, 000000,
      { 1, 0 } },
    { "BHIZ", 0146, 1 },
    { "BMN", 0136, 1 },
    { "BOFCLR", 0162, 2, 1, 000241 },
    { "BOF", 0162, 2, 1, 000341 },
    { "BOFF", 0162, 2, 1, 000341 },
    { "BOFINV", 0162, 2, 1, 000141 },
    { "BOFSET", 0162, 2, 1, 000041 },
    { "BON", 0162, 2, 1, 000301 },
    { "BONCLR", 0162, 2, 1, 000201 },
    { "BONINV", 0162, 2, 1, 000101 },
    { "BONSET", 0162, 2, 1, 000001 },
    { "BOV", 0176, 1 },
    { "BOVB", 0172, 1 },
    { "BPL", 0132, 1 },
    { "BVSU", 0131, 1, 0, 000000,
      { 1, 0 } },
    { "BVSU*", 0133, 1, 0, 000000,
      { 1, 0 } },
    { "BZE", 0122, 1 },
    { "CALL", 0152, 1 },
    { "CALRB", 0152, 1 },
    { "CCALL", 0065, 2, 0, 000000,
      { 1, 0 } },
    { "CCALL*", 0067, 2, 0, 000000,
      { 1, 0 } },
    { "CGOTO", 0021, 2, 0, 000000,
      { 1, 0 } },
    { "CGOTO*", 0023, 2, 0, 000000,
      { 1, 0 } },
    { "CLEAR", 0162, 1, 1, 000261 },
    { "CLR", 0162, 1, 1, 000261 },
    { "CLRGO", 0162, 2, 1, 000221 },
    { "COS", 0030, 0 },
    { "COSINE", 0030, 0 },
    { "DAD", 0161, 1, 0, 000000,
      { 1, 0 } },
    { "DAD*", 0163, 1, 0, 000000,
      { 1, 0 } },
    { "DCOMP", 0100, 0 },
    { "DDV", 0105, 1, 0, 000000,
      { 1, 0 } },
    { "DDV*", 0107, 1, 0, 000000,
      { 1, 0 } },
    { "DLOAD", 0031, 1, 0, 000000,
      { 1, 0 } },
    { "DLOAD*", 0033, 1, 0, 000000,
      { 1, 0 } },
    { "DMP", 0171, 1, 0, 000000,
      { 1, 0 } },
    { "DMP*", 0173, 1, 0, 000000,
      { 1, 0 } },
    { "DMPR", 0101, 1, 0, 000000,
      { 1, 0 } },
    { "DMPR*", 0103, 1, 0, 000000,
      { 1, 0 } },
    { "DOT", 0135, 1, 0, 000000,
      { 1, 0 } },
    { "DOT*", 0137, 1, 0, 000000,
      { 1, 0 } },
    { "DSQ", 0060, 0 },
    { "DSU", 0151, 1, 0, 000000,
      { 1, 0 } },
    { "DSU*", 0153, 1, 0, 000000,
      { 1, 0 } },
    { "EXIT", 0000, 0 },
    { "GOTO", 0126, 1 },
    { "INCR,1", 0066, 1 },
    { "INCR,2", 0062, 1 },
    { "INVERT", 0162, 1, 1, 000161 },
    { "INVGO", 0162, 2, 1, 000121 },
    { "ITA", 0156, 1 },
    { "ITCQ", 0160, 0 },
    { "LXA,1", 0026, 1 },
    { "LXA,2", 0022, 1 },
    { "LXC,1", 0036, 1 },
    { "LXC,2", 0032, 1 },
    { "MXV", 0055, 1, 0, 000000,
      { 1, 0 } },
    { "MXV*", 0057, 1, 0, 000000,
      { 1, 0 } },
    { "NORM", 0075, 1, 0, 000000,
      { 1, 0 } },
    { "NORM*", 0077, 1, 0, 000000,
      { 1, 0 } },
    { "PDDL", 0051, 1, 0, 000000,
      { 1, 0 } },
    { "PDDL*", 0053, 1, 0, 000000,
      { 1, 0 } },
    { "PDVL", 0061, 1, 0, 000000,
      { 1, 0 } },
    { "PDVL*", 0063, 1, 0, 000000,
      { 1, 0 } },
    { "PUSH", 0170, 0 },
    { "ROUND", 0070, 0 },
    { "RTB", 0142, 1 },
    { "RVQ", 0160, 0 },
    { "SET", 0162, 1, 1, 000061 },
    { "SETGO", 0162, 2, 1, 000021 },
    { "SETPD", 0175, 1, 0, 000000,
      { 1, 0 } },
    { "SIGN", 0011, 1, 0, 000000,
      { 1, 0 } },
    { "SIGN*", 0013, 1, 0, 000000,
      { 1, 0 } },
    { "SIN", 0020, 0 },
    { "SINE", 0020, 0 },
    { "SL", 0115, 1, 2, 020202,
      { 1, 0 } },
    { "SL*", 0117, 1, 2, 020202,
      { 1, 0 } },
    { "SLOAD", 0041, 1, 0, 000000,
      { 1, 0 } },
    { "SLOAD*", 0043, 1, 0, 000000,
      { 1, 0 } },
    { "SL1", 0024, 0, 0, 000000,
      { 1, 0 } },
    { "SL1R", 0004, 0, 0, 000000,
      { 1, 0 } },
    { "SL2", 0064, 0, 0, 000000,
      { 1, 0 } },
    { "SL2R", 0044, 0, 0, 000000,
      { 1, 0 } },
    { "SL3", 0124, 0, 0, 000000,
      { 1, 0 } },
    { "SL3R", 0104, 0, 0, 000000,
      { 1, 0 } },
    { "SL4", 0164, 0, 0, 000000,
      { 1, 0 } },
    { "SL4R", 0144, 0, 0, 000000,
      { 1, 0 } },
    { "SLR", 0115, 1, 2, 021202,
      { 1, 0 } },
    { "SLR*", 0117, 1, 2, 021202,
      { 1, 0 } },
    { "SQRT", 0010, 0 },
    { "SR", 0115, 1, 2, 020602,
      { 1, 0 } },
    { "SR*", 0117, 1, 2, 020602,
      { 1, 0 } },
    { "SR1", 0034, 0, 0, 000000,
      { 1, 0 } },
    { "SR1R", 0014, 0, 0, 000000,
      { 1, 0 } },
    { "SR2", 0074, 0, 0, 000000,
      { 1, 0 } },
    { "SR2R", 0054, 0, 0, 000000,
      { 1, 0 } },
    { "SR3", 0134, 0, 0, 000000,
      { 1, 0 } },
    { "SR3R", 0114, 0, 0, 000000,
      { 1, 0 } },
    { "SR4", 0174, 0, 0, 000000,
      { 1, 0 } },
    { "SR4R", 0154, 0, 0, 000000,
      { 1, 0 } },
    { "SRR", 0115, 1, 2, 021602,
      { 1, 0 } },
    { "SRR*", 0117, 1, 2, 021602,
      { 1, 0 } },
    { "SSP", 0045, 2, 0, 000000,
      { 1, 0 } },
    { "SSP*", 0047, 1, 0, 000000,
      { 1, 0 } },
    { "STADR", 0150, 0 },
    { "STQ", 0156, 1 },
    { "SXA,1", 0046, 1 },
    { "SXA,2", 0042, 1 },
    { "TAD", 0005, 1, 0, 000000,
      { 1, 0 } },
    { "TAD*", 0007, 1, 0, 000000,
      { 1, 0 } },
    { "TIX,1", 0076, 1 },
    { "TIX,2", 0072, 1 },
    { "TLOAD", 0025, 1, 0, 000000,
      { 1, 0 } },
    { "TLOAD*", 0027, 1, 0, 000000,
      { 1, 0 } },
    { "UNIT", 0120, 0 },
    { "V/SC", 0035, 1, 0, 000000,
      { 1, 0 } },
    { "V/SC*", 0037, 1, 0, 000000,
      { 1, 0 } },
    { "VAD", 0121, 1, 0, 000000,
      { 1, 0 } },
    { "VAD*", 0123, 1, 0, 000000,
      { 1, 0 } },
    { "VCOMP", 0100, 0 },
    { "VDEF", 0110, 0 },
    { "VLOAD", 0001, 1, 0, 000000,
      { 1, 0 } },
    { "VLOAD*", 0003, 1, 0, 000000,
      { 1, 0 } },
    { "VPROJ", 0145, 1, 0, 000000,
      { 1, 0 } },
    { "VPROJ*", 0147, 1, 0, 000000,
      { 1, 0 } },
    { "VSL", 0115, 1, 2, 020202,
      { 1, 0 } },
    { "VSL*", 0117, 1, 2, 020202,
      { 1, 0 } },
    { "VSL1", 0004, 0, 0, 000000,
      { 1, 0 } },
    { "VSL2", 0024, 0, 0, 000000,
      { 1, 0 } },
    { "VSL3", 0044, 0, 0, 000000,
      { 1, 0 } },
    { "VSL4", 0064, 0, 0, 000000,
      { 1, 0 } },
    { "VSL5", 0104, 0, 0, 000000,
      { 1, 0 } },
    { "VSL6", 0124, 0, 0, 000000,
      { 1, 0 } },
    { "VSL7", 0144, 0, 0, 000000,
      { 1, 0 } },
    { "VSL8", 0164, 0, 0, 000000,
      { 1, 0 } },
    { "VSQ", 0140, 0 },
    { "VSR", 0115, 1, 2, 020602,
      { 1, 0 } },
    { "VSR*", 0117, 1, 2, 020602,
      { 1, 0 } },
    { "VSR1", 0014, 0, 0, 000000,
      { 1, 0 } },
    { "VSR2", 0034, 0, 0, 000000,
      { 1, 0 } },
    { "VSR3", 0054, 0, 0, 000000,
      { 1, 0 } },
    { "VSR4", 0074, 0, 0, 000000,
      { 1, 0 } },
    { "VSR5", 0114, 0, 0, 000000,
      { 1, 0 } },
    { "VSR6", 0134, 0, 0, 000000,
      { 1, 0 } },
    { "VSR7", 0154, 0, 0, 000000,
      { 1, 0 } },
    { "VSR8", 0174, 0, 0, 000000,
      { 1, 0 } },
    { "VSU", 0125, 1, 0, 000000,
      { 1, 0 } },
    { "VSU*", 0127, 1, 0, 000000,
      { 1, 0 } },
    { "VXM", 0071, 1, 0, 000000,
      { 1, 0 } },
    { "VXM*", 0073, 1, 0, 000000,
      { 1, 0 } },
    { "VXSC", 0015, 1, 0, 000000,
      { 1, 0 } },
    { "VXSC*", 0017, 1, 0, 000000,
      { 1, 0 } },
    { "VXV", 0141, 1, 0, 000000,
      { 1, 0 } },
    { "VXV*", 0143, 1, 0, 000000,
      { 1, 0 } },
    { "XAD,1", 0106, 1 },
    { "XAD,2", 0102, 1 },
    { "XCHX,1", 0056, 1 },
    { "XCHX,2", 0052, 1 },
    { "XSU,1", 0116, 1 },
    { "XSU,2", 0112, 1 } };
#define NUM_INTERPRETERS_BLOCK2 (sizeof(InterpreterOpcodesBlock2) / sizeof(InterpreterOpcodesBlock2[0]))

// This is the interpreter table used for the BLK2 target
// (i.e., when the --blk2 command-line switch is used).
// It is *not* the default table used for normal Block 2
// software.  The differences are described in the original
// YUL code, in the Introduction section, on p. 11 for the
// BLK2 target (this one!), vs. p. 15 for the AGC target
// (the default one!). The tables are virtually identical,
// except the instructions CALL (or CCLRB) and RTB have
// swapped opcodes, and so have the instructions STQ and
// BHIZ for some reason.  I am told that there should be
// differences in STORE, STODL, STOVL, and STCALL as well,
// though it's not yet clear to me how that could be.
//
// Note that STCALL, STODL, STORE, and STOVL are implemented
// as basic instructions.
static InterpreterMatch_t InterpreterOpcodesBLK2[] =
  {
    { "ABS", 0130, 0 },
    { "ABVAL", 0130, 0 },
    { "ARCCOS", 0050, 0 },
    { "ACOS", 0050, 0 },
    { "ARCSIN", 0040, 0 },
    { "ASIN", 0040, 0 },
    { "AXC,1", 0016, 1 },
    { "AXC,2", 0012, 1 },
    { "AXT,1", 0006, 1 },
    { "AXT,2", 0002, 1 },
    { "BDDV", 0111, 1, 0, 000000,
      { 1, 0 } },
    { "BDDV*", 0113, 1, 0, 000000,
      { 1, 0 } },
    { "BDSU", 0155, 1, 0, 000000,
      { 1, 0 } },
    { "BDSU*", 0157, 1, 0, 000000,
      { 1, 0 } },
    { "BHIZ", 0156, 1 },
    { "BMN", 0136, 1 },
    { "BOFCLR", 0162, 2, 1, 000241 },
    { "BOF", 0162, 2, 1, 000341 },
    { "BOFF", 0162, 2, 1, 000341 },
    { "BOFINV", 0162, 2, 1, 000141 },
    { "BOFSET", 0162, 2, 1, 000041 },
    { "BON", 0162, 2, 1, 000301 },
    { "BONCLR", 0162, 2, 1, 000201 },
    { "BONINV", 0162, 2, 1, 000101 },
    { "BONSET", 0162, 2, 1, 000001 },
    { "BOV", 0176, 1 },
    { "BOVB", 0172, 1 },
    { "BPL", 0132, 1 },
    { "BVSU", 0131, 1, 0, 000000,
      { 1, 0 } },
    { "BVSU*", 0133, 1, 0, 000000,
      { 1, 0 } },
    { "BZE", 0122, 1 },
    { "CALL", 0142, 1 },
    { "CALRB", 0142, 1 },
    { "CCALL", 0065, 2, 0, 000000,
      { 1, 0 } },
    { "CCALL*", 0067, 2, 0, 000000,
      { 1, 0 } },
    { "CCLRB", 0065, 2, 0, 000000,
      { 1, 0 } },
    { "CCLRB*", 0067, 2, 0, 000000,
      { 1, 0 } },
    { "CGOTO", 0021, 2, 0, 000000,
      { 1, 0 } },
    { "CGOTO*", 0023, 2, 0, 000000,
      { 1, 0 } },
    { "CLEAR", 0162, 1, 1, 000261 },
    { "CLR", 0162, 1, 1, 000261 },
    { "CLRGO", 0162, 2, 1, 000221 },
    { "COS", 0030, 0 },
    { "COSINE", 0030, 0 },
    { "DAD", 0161, 1, 0, 000000,
      { 1, 0 } },
    { "DAD*", 0163, 1, 0, 000000,
      { 1, 0 } },
    { "DCOMP", 0100, 0 },
    { "DDV", 0105, 1, 0, 000000,
      { 1, 0 } },
    { "DDV*", 0107, 1, 0, 000000,
      { 1, 0 } },
    { "DLOAD", 0031, 1, 0, 000000,
      { 1, 0 } },
    { "DLOAD*", 0033, 1, 0, 000000,
      { 1, 0 } },
    { "DMP", 0171, 1, 0, 000000,
      { 1, 0 } },
    { "DMP*", 0173, 1, 0, 000000,
      { 1, 0 } },
    { "DMPR", 0101, 1, 0, 000000,
      { 1, 0 } },
    { "DMPR*", 0103, 1, 0, 000000,
      { 1, 0 } },
    { "DOT", 0135, 1, 0, 000000,
      { 1, 0 } },
    { "DOT*", 0137, 1, 0, 000000,
      { 1, 0 } },
    { "DSQ", 0060, 0 },
    { "DSU", 0151, 1, 0, 000000,
      { 1, 0 } },
    { "DSU*", 0153, 1, 0, 000000,
      { 1, 0 } },
    { "EXIT", 0000, 0 },
    { "GOTO", 0126, 1 },
    { "INCR,1", 0066, 1 },
    { "INCR,2", 0062, 1 },
    { "INVERT", 0162, 1, 1, 000161 },
    { "INVGO", 0162, 2, 1, 000121 },
    { "ITA", 0146, 1 },
    { "LXA,1", 0026, 1 },
    { "LXA,2", 0022, 1 },
    { "LXC,1", 0036, 1 },
    { "LXC,2", 0032, 1 },
    { "MXV", 0055, 1, 0, 000000,
      { 1, 0 } },
    { "MXV*", 0057, 1, 0, 000000,
      { 1, 0 } },
    { "NORM", 0075, 1, 0, 000000,
      { 1, 0 } },
    { "NORM*", 0077, 1, 0, 000000,
      { 1, 0 } },
    { "PDDL", 0051, 1, 0, 000000,
      { 1, 0 } },
    { "PDDL*", 0053, 1, 0, 000000,
      { 1, 0 } },
    { "PDVL", 0061, 1, 0, 000000,
      { 1, 0 } },
    { "PDVL*", 0063, 1, 0, 000000,
      { 1, 0 } },
    { "PUSH", 0170, 0 },
    { "ROUND", 0070, 0 },
    { "RTB", 0152, 1 },
    { "RVQ", 0160, 0 },
    { "SET", 0162, 1, 1, 000061 },
    { "SETGO", 0162, 2, 1, 000021 },
    { "SETPD", 0175, 1, 0, 000000,
      { 1, 0 } },
    { "SIGN", 0011, 1, 0, 000000,
      { 1, 0 } },
    { "SIGN*", 0013, 1, 0, 000000,
      { 1, 0 } },
    { "SIN", 0020, 0 },
    { "SINE", 0020, 0 },
    { "SL", 0115, 1, 2, 000202,
      { 1, 0 } },
    { "SL*", 0117, 1, 2, 000202,
      { 1, 0 } },
    { "SLOAD", 0041, 1, 0, 000000,
      { 1, 0 } },
    { "SLOAD*", 0043, 1, 0, 000000,
      { 1, 0 } },
    { "SL1", 0024, 0, 0, 000000,
      { 1, 0 } },
    { "SL1R", 0004, 0, 0, 000000,
      { 1, 0 } },
    { "SL2", 0064, 0, 0, 000000,
      { 1, 0 } },
    { "SL2R", 0044, 0, 0, 000000,
      { 1, 0 } },
    { "SL3", 0124, 0, 0, 000000,
      { 1, 0 } },
    { "SL3R", 0104, 0, 0, 000000,
      { 1, 0 } },
    { "SL4", 0164, 0, 0, 000000,
      { 1, 0 } },
    { "SL4R", 0144, 0, 0, 000000,
      { 1, 0 } },
    { "SLR", 0115, 1, 2, 001202,
      { 1, 0 } },
    { "SLR*", 0117, 1, 2, 001202,
      { 1, 0 } },
    { "SQRT", 0010, 0 },
    { "SR", 0115, 1, 2, 000602,
      { 1, 0 } },
    { "SR*", 0117, 1, 2, 000602,
      { 1, 0 } },
    { "SR1", 0034, 0, 0, 000000,
      { 1, 0 } },
    { "SR1R", 0014, 0, 0, 000000,
      { 1, 0 } },
    { "SR2", 0074, 0, 0, 000000,
      { 1, 0 } },
    { "SR2R", 0054, 0, 0, 000000,
      { 1, 0 } },
    { "SR3", 0134, 0, 0, 000000,
      { 1, 0 } },
    { "SR3R", 0114, 0, 0, 000000,
      { 1, 0 } },
    { "SR4", 0174, 0, 0, 000000,
      { 1, 0 } },
    { "SR4R", 0154, 0, 0, 000000,
      { 1, 0 } },
    { "SRR", 0115, 1, 2, 001602,
      { 1, 0 } },
    { "SRR*", 0117, 1, 2, 001602,
      { 1, 0 } },
    { "SSP", 0045, 2, 0, 000000,
      { 1, 0 } },
    { "SSP*", 0047, 1, 0, 000000,
      { 1, 0 } },
    { "STADR", 0150, 0 },
    { "STQ", 0146, 1 },
    { "SXA,1", 0046, 1 },
    { "SXA,2", 0042, 1 },
    { "TAD", 0005, 1, 0, 000000,
      { 1, 0 } },
    { "TAD*", 0007, 1, 0, 000000,
      { 1, 0 } },
    { "TIX,1", 0076, 1 },
    { "TIX,2", 0072, 1 },
    { "TLOAD", 0025, 1, 0, 000000,
      { 1, 0 } },
    { "TLOAD*", 0027, 1, 0, 000000,
      { 1, 0 } },
    { "UNIT", 0120, 0 },
    { "V/SC", 0035, 1, 0, 000000,
      { 1, 0 } },
    { "V/SC*", 0037, 1, 0, 000000,
      { 1, 0 } },
    { "VAD", 0121, 1, 0, 000000,
      { 1, 0 } },
    { "VAD*", 0123, 1, 0, 000000,
      { 1, 0 } },
    { "VCOMP", 0100, 0 },
    { "VDEF", 0110, 0 },
    { "VLOAD", 0001, 1, 0, 000000,
      { 1, 0 } },
    { "VLOAD*", 0003, 1, 0, 000000,
      { 1, 0 } },
    { "VPROJ", 0145, 1, 0, 000000,
      { 1, 0 } },
    { "VPROJ*", 0147, 1, 0, 000000,
      { 1, 0 } },
    { "VSL", 0115, 1, 2, 000202,
      { 1, 0 } },
    { "VSL*", 0117, 1, 2, 000202,
      { 1, 0 } },
    { "VSL1", 0004, 0, 0, 000000,
      { 1, 0 } },
    { "VSL2", 0024, 0, 0, 000000,
      { 1, 0 } },
    { "VSL3", 0044, 0, 0, 000000,
      { 1, 0 } },
    { "VSL4", 0064, 0, 0, 000000,
      { 1, 0 } },
    { "VSL5", 0104, 0, 0, 000000,
      { 1, 0 } },
    { "VSL6", 0124, 0, 0, 000000,
      { 1, 0 } },
    { "VSL7", 0144, 0, 0, 000000,
      { 1, 0 } },
    { "VSL8", 0164, 0, 0, 000000,
      { 1, 0 } },
    { "VSQ", 0140, 0 },
    { "VSR", 0115, 1, 2, 000602,
      { 1, 0 } },
    { "VSR*", 0117, 1, 2, 000602,
      { 1, 0 } },
    { "VSR1", 0014, 0, 0, 000000,
      { 1, 0 } },
    { "VSR2", 0034, 0, 0, 000000,
      { 1, 0 } },
    { "VSR3", 0054, 0, 0, 000000,
      { 1, 0 } },
    { "VSR4", 0074, 0, 0, 000000,
      { 1, 0 } },
    { "VSR5", 0114, 0, 0, 000000,
      { 1, 0 } },
    { "VSR6", 0134, 0, 0, 000000,
      { 1, 0 } },
    { "VSR7", 0154, 0, 0, 000000,
      { 1, 0 } },
    { "VSR8", 0174, 0, 0, 000000,
      { 1, 0 } },
    { "VSU", 0125, 1, 0, 000000,
      { 1, 0 } },
    { "VSU*", 0127, 1, 0, 000000,
      { 1, 0 } },
    { "VXM", 0071, 1, 0, 000000,
      { 1, 0 } },
    { "VXM*", 0073, 1, 0, 000000,
      { 1, 0 } },
    { "VXSC", 0015, 1, 0, 000000,
      { 1, 0 } },
    { "VXSC*", 0017, 1, 0, 000000,
      { 1, 0 } },
    { "VXV", 0141, 1, 0, 000000,
      { 1, 0 } },
    { "VXV*", 0143, 1, 0, 000000,
      { 1, 0 } },
    { "XAD,1", 0106, 1 },
    { "XAD,2", 0102, 1 },
    { "XCHX,1", 0056, 1 },
    { "XCHX,2", 0052, 1 },
    { "XSU,1", 0116, 1 },
    { "XSU,2", 0112, 1 } };
#define NUM_INTERPRETERS_BLK2 (sizeof(InterpreterOpcodesBLK2) / sizeof(InterpreterOpcodesBLK2[0]))

// This is the table of interpreter instructions used for all
// Block 1 software.
static InterpreterMatch_t InterpreterOpcodesBlock1[] =
  {
    { "ABS", 0124 },
    { "ABS*", 0120 },
    { "ABVAL", 0144 },
    { "ARCCOS", 0104 },
    { "ACOS", 0104 },
    { "ARCSIN", 0114 },
    { "ASIN", 0114 },
    { "AST,1", 0066 },
    { "AST,2", 0062 },
    { "AXC,1", 0056 },
    { "AXC,2", 0052 },
    { "AXT,1", 0166 },
    { "AXT,2", 0162 },
    { "BDDV", 0107 },
    { "BDSU", 0127 },
    { "BDSU*", 0125 },
    { "BHIZ", 0137 },
    { "BMN", 0157 },
    { "BOV", 0147 },
    { "BPL", 0017 },
    { "BVSU", 0033 },
    { "BZE", 0037 },
    { "COMP", 0034 },
    { "COMP*", 0030 },
    { "COS", 0064 },
    { "COS*", 0060 },
    { "COSINE", 0064 },
    { "DAD", 0143 },
    { "DAD*", 0141 },
    { "DDV", 0113 },
    { "DDV*", 0111 },
    { "DMOVE", 0024 },
    { "DMOVE*", 0020 },
    { "DMP", 0123 },
    { "DMP*", 0121 },
    { "DMPR", 0067 },
    { "DOT", 0013 },
    { "DSQ", 0044 },
    { "DSU", 0133 },
    { "DSU*", 0131 },
    { "EXIT", 0176 },
    { "INCR,1", 0116 },
    { "INCR,2", 0112 },
    { "ITA", 0026 },
    { "ITC", 0173 },
    { "ITC*", 0171 },
    { "ITCI", 0022 },
    { "ITCQ", 0002 },
    { "LODON", 0006 },
    { "LXA,1", 0156 },
    { "LXA,2", 0152 },
    { "LXC,1", 0146 },
    { "LXC,2", 0142 },
    { "MXV", 0053 },
    { "NOLOD", 0036 },
    { "ROUND", 0032 },
    { "RTB", 0172 },
    { "SIGN", 0057 },
    { "SIN", 0074 },
    { "SINE", 0074 },
    { "SMOVE", 0014 },
    { "SMOVE*", 0010 },
    { "SQRT", 0054 },
    { "STZ", 0153 },
    { "SWITCH", 0012 },
    { "SXA,1", 0136 },
    { "SXA,2", 0132 },
    { "TAD", 0103 },
    { "TEST", 0016 },
    { "TIX,1", 0046 },
    { "TIX,2", 0042 },
    { "TMOVE", 0174 },
    { "TP", 0174 },
    { "TSLC", 0077 },
    { "TSLT", 0117 },
    { "TSLT*", 0115 },
    { "TSRT", 0073 },
    { "TSRT*", 0071 },
    { "TSU", 0063 },
    { "UNIT", 0154 },
    { "UNIT*", 0150 },
    { "VAD", 0043 },
    { "VAD*", 0041 },
    { "VDEF", 0004 },
    { "VMOVE", 0164 },
    { "VMOVE*", 0160 },
    { "VPROJ", 0003 },
    { "VSLT", 0023 },
    { "VSLT*", 0021 },
    { "VSQ", 0134 },
    { "VSRT", 0027 },
    { "VSRT*", 0025 },
    { "VSU", 0163 },
    { "VXM", 0047 },
    { "VXSC", 0167 },
    { "VXSC*", 0165 },
    { "VXV", 0007 },
    { "VXV*", 0005 },
    { "XAD,1", 0106 },
    { "XAD,2", 0102 },
    { "XCHX,1", 0126 },
    { "XCHX,2", 0122 },
    { "XSU,1", 0076 },
    { "XSU,2", 0072 } };
#define NUM_INTERPRETERS_BLOCK1 (sizeof (InterpreterOpcodesBlock1) / sizeof (InterpreterOpcodesBlock1[0]))

static InterpreterMatch_t *InterpreterOpcodes = InterpreterOpcodesBlock2;
static int NUM_INTERPRETERS = NUM_INTERPRETERS_BLOCK2;

// Buffer for binary data.
int ObjectCode[044][02000];
unsigned char Parities[044][02000];

int NumInterpretiveOperands = 0, RawNumInterpretiveOperands;
int nnnnFields[4];
unsigned char SwitchIncrement[4], SwitchInvert[4];
int OpcodeOffset;
int ArgType = 0;

//-------------------------------------------------------------------------
// Add an opcode to OpcodeOffset.
static int
AddAgc(int Val1, int Val2)
{
  return (077777 & (Val1 + Val2));
}

//-------------------------------------------------------------------------
// A function used to compare two ParserMatch_t structures on the basis
// of the operator names they embody.  Used for sorting or searching the
// Parsers array.
static int
CompareParsers(const void *p1, const void *p2)
{
  return (strcmp(((ParserMatch_t *) p1)->Name, ((ParserMatch_t *) p2)->Name));
}

static int ParsersSorted = 0;

void
SortParsers(void)
{
  if (!ParsersSorted)
    {
      ParsersSorted = 1;
      qsort(Parsers, NUM_PARSERS, sizeof(Parsers[0]), CompareParsers);
    }
}

static ParserMatch_t *
FindParser(const char *Name)
{
  ParserMatch_t Key;
  strncpy(Key.Name, Name, MAX_LABEL_LENGTH);
  Key.Name[MAX_LABEL_LENGTH] = 0;
  return (bsearch(&Key, Parsers, NUM_PARSERS, sizeof(Parsers[0]),
      CompareParsers));
}

//-------------------------------------------------------------------------
// A function used to compare two InterpreterMatch_t structures on the basis
// of the operator names they embody.  Used for sorting or searching the
// InterpreterOpcodes array.
static int
CompareInterpreters(const void *p1, const void *p2)
{
  return (strcmp(((InterpreterMatch_t *) p1)->Name,
      ((InterpreterMatch_t *) p2)->Name));
}

static int InterpretersSorted = 0;

void
SortInterpreters(void)
{
  if (!InterpretersSorted)
    {
      InterpretersSorted = 1;
      qsort(InterpreterOpcodes, NUM_INTERPRETERS, sizeof(InterpreterOpcodes[0]),
          CompareInterpreters);
    }
}

static InterpreterMatch_t *
FindInterpreter(const char *Name)
{
  InterpreterMatch_t Key;

  strncpy(Key.Name, Name, MAX_LABEL_LENGTH);
  Key.Name[MAX_LABEL_LENGTH] = 0;

  return (bsearch(&Key, InterpreterOpcodes, NUM_INTERPRETERS,
      sizeof(InterpreterOpcodes[0]), CompareInterpreters));
}

//-------------------------------------------------------------------------
// This function simply checks to see if a given string is the name of an 
// interpreter instruction.  It is used only for colorizing HTML output.
// Returns 1 if yes, 0 if no.
static int
IsInterpretive(char *s)
{
  ParserMatch_t *Match;
  if (FindInterpreter(s))
    return (1);
  Match = FindParser(s);
  if (Match && Match->OpType == OP_INTERPRETER)
    return (1);
  return (0);
}

//------------------------------------------------------------------------
// Print an Address_t record.  Returns 0 on success, non-zero on error.

int
AddressPrint(Address_t *Address)
{
  if (Address->Invalid)
    {
      printf("???????  ");
      if (HtmlOut)
        fprintf(HtmlOut, "???????  ");
    }
  else if (Address->Constant)
    {
      printf("%07o  ", Address->Value & 07777777);
      if (HtmlOut)
        fprintf(HtmlOut, "%07o  ", Address->Value & 07777777);
    }
  else if (Address->Unbanked)
    {
      printf("   %04o  ", Address->SReg);
      if (HtmlOut)
        fprintf(HtmlOut, "   %04o  ", Address->SReg);
    }
  else if (Address->Banked)
    {
      if (Address->Erasable)
        {
          printf("E%1o,%04o  ", Address->EB, Address->SReg);
          if (HtmlOut)
            fprintf(HtmlOut, "E%1o,%04o  ", Address->EB, Address->SReg);
        }
      else if (Address->Fixed)
        {
          printf("%02o,%04o  ", Address->FB + 010 * Address->Super,
              Address->SReg);
          if (HtmlOut)
            fprintf(HtmlOut, "%02o,%04o  ", Address->FB + 010 * Address->Super,
                Address->SReg);
        }
      else
        {
          printf("int-err  ");
          if (HtmlOut)
            fprintf(HtmlOut, "int-err  ");
          return (1);
        }
    }
  else
    {
      printf("int-err  ");
      if (HtmlOut)
        fprintf(HtmlOut, "int-err  ");
      return (1);
    }
  return (0);
}

// Checks a string to see if is of one of the forms
//   +n
//   -n
//   +nD
//   -nD
// Returns 1 if so, or 0 otherwise.
int
IsFalseLabel(char *s)
{
  if (*s != '-' && *s != '+')
    return (0);
  if (!isdigit(*++s))
    return (0);
  for (s++; isdigit(*s); s++)
    ;
  if (*s == 0)
    return (1);
  if (*s++ != 'D')
    return (0);
  return (*s == 0);
}

// JMS: Returns 1 if the given operator is an "embedded" constant, meaning
// the label is a memory location which holds some data. The following
// operands are embedded constants: ERASE, DEC, DEC*, 2DEC, 2DEC*, OCT
int
IsEmbeddedConstant(char *s)
{
  if (!strcmp(s, "ERASE") || !strcmp(s, "DEC") || !strcmp(s, "DEC*")
      || !strcmp(s, "2DEC") || !strcmp(s, "2DEC*") || !strcmp(s, "OCT"))
    return 1;
  return 0;
}

//-------------------------------------------------------------------------
// The assembler itself.  If called with WriteOutput==0, simply tries to
// resolve symbols.  With each successive pass, resolves more symbols.
// It returns -1 on a completely unrecoverable error.  When called with 
// WriteOutput=1 tries to write the output binary.  It is assumed that 
// SymbolPass and SortSymbols have been used prior to the first call to Pass.

int WriteOutputDebug;

// The following used to be local to the Pass() function, but apparently
// the initializers don't work the way I expect, causing boogered-up 
// behavior, so I made them global.
static Address_t DefaultAddress = INVALID_ADDRESS;
  static ParseInput_t ParseInputRecord;

  static ParseInput_t DefaultParseInput =
    {
      INVALID_ADDRESS,    // ProgramCounter
    0,// Reserved
    "",// Label
    "",// FalseLabel
    "",// Operator
    "",// Operand
    "",// Mod1
    "",// Mod2
    "",// Comment
    "",// Extra
    "",// Alias
    0,// Index
    0,// Extend
    0,// IndexValid
    INVALID_EBANK,// EBank
    INVALID_SBANK// SBank
  };

static ParseOutput_t ParseOutputRecord,
  DefaultParseOutput=
  { INVALID_ADDRESS,    // ProgramCounter
0,                  // Reserved
        { 0, 0 },           // Words [0:1]
      0,                  // NumWords
      "",                 // ErrorMessage
      INVALID_ADDRESS,    // LabelValue
    0,                  // Index
      0,                  // Warning
      0,                  // Fatal
      0,                  // LabelValueValid
      0,                  // Extend
      0,                  // IndexValid
      INVALID_EBANK,       // EBank
    INVALID_SBANK,       // SBank
  0                   // Equals
    };

int
Pass(int WriteOutput, const char *InputFilename, FILE *OutputFile, int *Fatals,
    int *Warnings)
{
  void SaveUsedCounts(void);
  int yulType = 0;
  int IncludeDirective;
  ParserMatch_t *Match;
  InterpreterMatch_t *iMatch;
  int RetVal = 1, PinchHitting;
  Line_t s;
  FILE *InputFile;
  int CurrentLineAll = 0;
  int i, j, k;    // dummies.
  char *ss;    // dummies.
  int StadrInvert = 0;
  int BlockAssigned = 0;
  int expectedNumInterpreterOperatorLines = 0,
      currentNumInterpreterOperatorLines = 0;
  int noOperator = 1, foundInterpreterOperandCount /*, firstInterpreterColumn*/;
  static char lastLines[10][sizeof(s)] =
    { "", "", "", "", "", "", "", "", "", "" };
  int thisLineDoubleComment = 0;

  inReconstructionComment = 0;

  debugLineString = s;
  debugLine = 1;
  SaveUsedCounts();
  thisIsTheLastPass = WriteOutput;
  numSymbolsReassigned = 0;

  // Set for the proper assembly target
  // The default for these settings is Block2 (YUL name AGC, I think).
  if (!BlockAssigned && Block1)
    {
      // YUL target AGC4, I think.
      Parsers = ParsersBlock1;
      NUM_PARSERS = NUM_PARSERS_BLOCK1;
      InterpreterOpcodes = InterpreterOpcodesBlock1;
      NUM_INTERPRETERS = NUM_INTERPRETERS_BLOCK1;
    }
  if (!BlockAssigned && blk2)
    {
      // YUL target BLK2, I think, not to be confused with the ;
      // Block 2 target (AGC) used for most AGC programs.
      Parsers = ParsersBLK2;
      NUM_PARSERS = NUM_PARSERS_BLK2;
      InterpreterOpcodes = InterpreterOpcodesBLK2;
      NUM_INTERPRETERS = NUM_INTERPRETERS_BLK2;
    }
  BlockAssigned = 1;

  WriteOutputDebug = WriteOutput;

  CurrentLineInFile = 0;
  StartBankCounts();
  SortParsers();
  SortInterpreters();
  *Fatals = *Warnings = 0;

  for (i = 0; i < 044; i++)
    for (j = 0; j < 02000; j++)
      {
        ObjectCode[i][j] = 0;
        Parities[i][j] = 0;
      }

  // Open the input file.
  strcpy(CurrentFilename, InputFilename);
  InputFile = fopen(CurrentFilename, "r");
  if (!InputFile)
    goto Done;
  yulType = (NULL != strstr(InputFilename, ".yul"));

  // Loop on the lines of the input file.  The assembler passes differ
  // among themselves as follows:
  //
  // Pass 1    Assembly is performed, but no output is written.
  //           The purpose is simply to create a list of all symbols and
  //           their namespaces, and their values.
  // Pass 2    Output is written.

  s[sizeof(s) - 1] = 0;

  ParseOutputRecord.ProgramCounter = DefaultAddress;

  ParseOutputRecord.EBank = (const EBank_t
        )
          { 0,     // oneshotPending
                { 1 }, // current
                { 1 }  // last
          };

  // The SBank starts "unestablished", which = 0.
  ParseOutputRecord.SBank = (const SBank_t) INVALID_SBANK;

  for (;;)
    {
      IncludeDirective = 0;
      OpcodeOffset = 0;
      PinchHitting = 0;
      ArgType = 0;
      // Set up the default info for this line.
      ParseInputRecord = DefaultParseInput;
      ParseInputRecord.ProgramCounter = ParseOutputRecord.ProgramCounter;
      ParseInputRecord.EBank = ParseOutputRecord.EBank;
      ParseInputRecord.SBank = ParseOutputRecord.SBank;
      ParseInputRecord.Index = ParseOutputRecord.Index;
      ParseInputRecord.IndexValid = ParseOutputRecord.IndexValid;
      ParseInputRecord.Extend = ParseOutputRecord.Extend;
      ParseOutputRecord = DefaultParseOutput;
      ParseOutputRecord.EBank = ParseInputRecord.EBank;
      ParseOutputRecord.SBank = ParseInputRecord.SBank;
      // Get the next line from the file.
      ss = fgets(s, sizeof(s) - 1, InputFile);
      //printf("LINE -> %s", s);
      // At end of the file?
      if (!ss)
        {
          // We've reached the end of this input file.  Need to switch
          // files (if we were within an include-file) or to end the pass.
          inHeader = 0;
          if (NumStackedIncludes)
            {
              fclose(InputFile);
              NumStackedIncludes--;
              if (WriteOutput)
                {
                  printf("(End of include-file %s, resuming %s)\n",
                      CurrentFilename,
                      StackedIncludes[NumStackedIncludes].InputFilename);
                  if (HtmlOut)
                    {
                      fprintf(HtmlOut,
                          "\nEnd of include-file %s.  Parent file is <a href=\"%s\">%s</a>\n",
                          CurrentFilename,
                          NormalizeFilename(
                              StackedIncludes[NumStackedIncludes].InputFilename),
                          StackedIncludes[NumStackedIncludes].InputFilename);
                      HtmlClose();
                      HtmlOut = NULL;
                      IncludeDirective = 1;
                    }
                }
              strcpy(CurrentFilename,
                  StackedIncludes[NumStackedIncludes].InputFilename);
              InputFile = StackedIncludes[NumStackedIncludes].InputFile;
              CurrentLineInFile =
                  StackedIncludes[NumStackedIncludes].CurrentLineInFile;
              HtmlOut = StackedIncludes[NumStackedIncludes].HtmlOut;
              yulType = StackedIncludes[NumStackedIncludes].yulType;
              s[0] = 0;
            }
          else
            {
              // All done!
              break;
            }
        }
      else
        {
          // No, not at end of file, so we've just read a new line.
          CurrentLineAll++;
          CurrentLineInFile++;
        }
      debugLine = CurrentLineAll;

      // For --simulation.
      if (s[0] != '#')
	if ((Simulation && strstr(s, "-SIMULATION")) || (!Simulation && strstr(s, "+SIMULATION")))
	  {
	    memmove(&s[1], s, sizeof(s) - 1);
	    s[sizeof(s) - 1] = 0;
	    s[0] = '#';
	  }

      // Analyze the input line.

      // If it is not a ## line and not completely blank, then we are no longer
      // in the file header.
      thisLineDoubleComment = 0;
      for (ss = s; *ss && isspace(*ss); ss++)
        ;
      if (*ss == 0) // completely whitespace
        {
          if (toYulOnly)
            {
              printf("%-80s\n", "");
              continue;
            }
        }
      else if (s[0] == '#' && s[1] == '#' && 1 != sscanf(s, "## Page%d", &k)) // is a ## line
        {
          thisLineDoubleComment = 1;
	  if (!inHeader && strstr(s, "Reconstruction:") != NULL)
	    inReconstructionComment = 1;
        }
      else if (inHeader)
        {
          inHeader = 0;
          if (toYulOnly)
            {
              printf("P%04d   %-72s\n", toYulOnlySequenceNumber++,
                  toYulOnlyLogSection);
            }
        }
      if (!thisLineDoubleComment && inReconstructionComment)
        inReconstructionComment = 0;
      //if (WriteOutput && inReconstructionComment && reconstructionComments)
      //  printf ("%s", s);

      // Convert the construct "#>' (column 1) used in .yul files to an
      // indented ##-style comment.
      if (yulType && s[0] == '#' && s[1] == '>')
        {
          s[1] = '#';
          memmove(&s[6], s, 1 + strlen(s));
          memset(s, '\t', 6);
        }

      // Is it an HTML insert?  If so, transparently process and discard.
      if (formatOnly || toYulOnly)
        {
          if (s[0] == '#' && s[1] == '#')
            {
              printf("%s", s);
              continue;
            }
        }
      else if (HtmlCheck(WriteOutput, InputFile, s, sizeof(s), CurrentFilename,
          &CurrentLineAll, &CurrentLineInFile))
        {
          // The following 3 lines are a fix for the following bug:
          // https://github.com/rburkey2005/virtualagc/issues/45.
          ParseOutputRecord.ProgramCounter = ParseInputRecord.ProgramCounter;
          ParseOutputRecord.EBank = ParseInputRecord.EBank;
          ParseOutputRecord.SBank = ParseInputRecord.SBank;
          continue;
        }

      // Is it an "include" directive?
      if (formatOnly && s[0] == '$')
        {
          printf("%s", s);
          continue;
        }
      if (s[0] == '$')
        {
          // This is a directive to include another file.
          ParseOutputRecord.ProgramCounter = ParseInputRecord.ProgramCounter;
          ParseOutputRecord.EBank = ParseInputRecord.EBank;
          ParseOutputRecord.SBank = ParseInputRecord.SBank;
          if (WriteOutput)
            printf("%06d,%06d: %s", CurrentLineAll, CurrentLineInFile, s);

          if (NumStackedIncludes == MAX_STACKED_INCLUDES)
            {
              printf("Too many levels of include-files.\n");
              fprintf(stderr, "%s:%d: Too many levels of include-files.\n",
                  CurrentFilename, CurrentLineInFile);
              goto Done;
            }

          StackedIncludes[NumStackedIncludes].InputFile = InputFile;
          strcpy(StackedIncludes[NumStackedIncludes].InputFilename,
              CurrentFilename);
          StackedIncludes[NumStackedIncludes].CurrentLineInFile =
              CurrentLineInFile;
          StackedIncludes[NumStackedIncludes].HtmlOut = HtmlOut;
          StackedIncludes[NumStackedIncludes].yulType = yulType;
          NumStackedIncludes++;

          if (sscanf(s, "$%s", CurrentFilename) != 1)
            {
              printf("Include-directive has no filename.\n");
              fprintf(stderr, "%s:%d: Include-directive has no filename.\n",
                  CurrentFilename, CurrentLineInFile);
              goto Done;
            }

          if (WriteOutput && Html)
            {
              char *ss;
              for (ss = s; *ss; ss++)
                if (*ss == '\n')
                  {
                    *ss = 0;
                    break;
                  }
              if (HtmlOut)
                fprintf(HtmlOut, "%06d,%06d: <a href=\"%s\">%s</a>\n",
                    CurrentLineAll, CurrentLineInFile,
                    NormalizeFilename(CurrentFilename), NormalizeString(s));
              HtmlCreate(CurrentFilename);
              if (!HtmlOut)
                goto Done;
            }

          InputFile = fopen(CurrentFilename, "r");
          if (!InputFile)
            {
              printf("Include-file \"%s\" does not exist.\n", CurrentFilename);
              fprintf(stderr, "%s:%d: Include-file does not exist.\n",
                  CurrentFilename, CurrentLineInFile);
              goto Done;
            }
          yulType = (NULL != strstr(CurrentFilename, ".yul"));

          inHeader = 1;
          CurrentLineInFile = 0;
          continue;
        }

      // Frankly, tabs and newlines will cause me a lot of problems further down, since
      // there are actually a couple of things we need to use column alignment to check
      // out.  So let's just start by expanding all tabs to spaces.
      ParseInputRecord.Column8 = ' ';
      ParseInputRecord.InversionPending = 0;
      ss = strstr(s, "\n");
      if (ss != NULL )
        *ss = 0;
      s[sizeof(s) - 1] = 0;
      for (ss = s; *ss;)
        {
          if (*ss == '\t')
            {
              int pos, tabStop, len;
              pos = ss - s;
              tabStop = ((pos + 8) & ~7);
              len = strlen(ss + 1);
              if (tabStop + len >= sizeof(s))
                len = sizeof(s) - tabStop - 1;
              if (len > 0)
                memmove(&s[tabStop], &s[pos + 1], len + 1);
              else
                s[tabStop] = 0;
              for (; pos < tabStop && pos < sizeof(s); pos++)
                s[pos] = ' ';
              ss = &s[tabStop];
            }
          else
            ss++;
        }
      *ss = 0;

      if (yulType)
        yul2agc(s);

      // Find and remove the comment field, if any.
      //printf ("Line -> \"%s\"\n", s);
      ParseInputRecord.commentColumn = 0;
      for (ParseInputRecord.Comment = s;
          *ParseInputRecord.Comment
              && *ParseInputRecord.Comment != COMMENT_SEPARATOR;
          ParseInputRecord.Comment++)
        ;
      if (*ParseInputRecord.Comment == COMMENT_SEPARATOR)
        {
          ParseInputRecord.commentColumn = ParseInputRecord.Comment - s;
          *ParseInputRecord.Comment++ = 0;
          // Trim the newline at the end:
          //for (ss = ParseInputRecord.Comment; *ss; ss++)
          //    if (*ss == '\n')
          //        *ss = 0;
          if (toYulOnly && ParseInputRecord.Comment[0] == COMMENT_SEPARATOR)
            {
              ParseInputRecord.Comment++;
              if (*ParseInputRecord.Comment == ' ')
                ParseInputRecord.Comment++;
              printf("#>%-38s%-40s\n", "", ParseInputRecord.Comment);
              *ParseInputRecord.Comment = 0;
            }
        }
      //printf ("Comment -> \"%s\"\n", ParseInputRecord.Comment);

      if (Block1 && strlen(s) >= 16)
        {
          ParseInputRecord.Column8 = s[15];
          s[15] = ' ';
          ParseInputRecord.InversionPending = (ParseInputRecord.Column8 == '-');
        }

      // Suck in all other fields. Below, i is going to be the index of the next input field to be processed.
      NumFields = sscanf(s, "%s%s%s%s%s%s", Fields[0], Fields[1], Fields[2],
          Fields[3], Fields[4], Fields[5]);
      if (NumFields >= 1)
        {
          int whichColumn;
          // Column at which Field[0] starts.
          whichColumn = strstr(s, Fields[0]) - s;
          i = 0;
          if (whichColumn == 0)
            {
              ParseInputRecord.Label = Fields[i++];
            }
          else if (IsFalseLabel(Fields[0]) && whichColumn < 8)
            {
              if (NumFields == 1)
                goto NotOffset;
              else
                ParseInputRecord.FalseLabel = Fields[i++];
            }
          else if (whichColumn < 8)
            i++;

          if (!strcmp(ParseInputRecord.Label, "DECON"))
            {
              j++;
            }

          for (k = 9; k > 0; k--)
            strcpy(lastLines[k], lastLines[k - 1]);
          strcpy(lastLines[0], s);

          // It is assumed by convention that
          // the first operand appears at column 16, therefore if Fields[i] doesn't
          // appear at column 16, it can't be an operator.  This is used only for
          // Block 1 interpreter code, and only to determine that the line contains
          // an address rather than an operator.  Moreover, anything appearing in
          // column 15 is *not* part of the operator.
          noOperator = 1 /*Block1*/;
          if (strlen(s) >= 16)
            {
              if (!strncmp(&s[16], Fields[i], strlen(Fields[i])))
                noOperator = 0;
            }

          iMatch = noOperator ? NULL : FindInterpreter(Fields[i]);
          Match = FindParser(Fields[i]);

          if (Block1)
            {
              if (noOperator)
                {
                  if (currentNumInterpreterOperatorLines
                      < expectedNumInterpreterOperatorLines)
                    {
                      ParseOutputRecord.Warning = 1;
                      strcpy(ParseOutputRecord.ErrorMessage,
                          "Interpretive operator aligned badly.");
                      noOperator = 0;
                    }
                  else
                    {
                      iMatch = 0;
                      ParseInputRecord.Operator = "";
                      RawNumInterpretiveOperands = 1;
                      NumInterpretiveOperands = 1;
                    }
                }
              else
                NumInterpretiveOperands = 0;
            }

          foundInterpreterOperandCount = 0;
          if (Block1)
            {
              if (currentNumInterpreterOperatorLines
                  < expectedNumInterpreterOperatorLines)
                {
                  ParseInputRecord.Operator = Fields[i++];
                  // This line must be a line of interpretive operators.
                  currentNumInterpreterOperatorLines++;
                }
              else if (iMatch)
                {
                  int j;
                  // This must be the first line of a string of interpretive operators.
                  // I don't know that 7 is the maximum, but 7 is the most I've observed.
                  ParseInputRecord.Operator = Fields[i++];
                  expectedNumInterpreterOperatorLines = 0;
                  j = atoi(Fields[i]);
                  if (isdigit(Fields[i][0]) && strlen(Fields[i]) == 1 && j >= 0
                      && j <= 7)
                    {
                      // The operand is actually a count of the number of lines of operators
                      // that follow.
                      expectedNumInterpreterOperatorLines = j;
                      foundInterpreterOperandCount = 1;
                    }
                  currentNumInterpreterOperatorLines = 0;
                }
              else if (Match && Match->PinchHit)
                {
                  PinchHitting = 1;
                  if (i < NumFields)
                    ParseInputRecord.Operator = Fields[i++];
                }
              else
                {
                  if (!noOperator && i < NumFields)
                    ParseInputRecord.Operator = Fields[i++];
                }

            }
          else
            {
              if ((formatOnly || toYulOnly) && noOperator)
                {
                  ParseInputRecord.Operator = "";
                }
              else if (NumInterpretiveOperands && !iMatch && !Match)
                {
                  ParseInputRecord.Operator = "";
                }
              else if (Match && NumInterpretiveOperands && i + 1 >= NumFields)
                {
                  // This is to catch the annoying case where normal opcodes like
                  // TC and and pseudo-ops like VN are actually data labels as well,
                  // and are used as interpretive operands. We figure that if the
                  // operator has no operand, then it must be a label instead.
                  Match = NULL;
                  ParseInputRecord.Operator = "";
                }
              else if (Match && Match->PinchHit && NumInterpretiveOperands)
                {
                  NumInterpretiveOperands--;
                  PinchHitting = 1;
                  if (i < NumFields)
                    ParseInputRecord.Operator = Fields[i++];
                }
              else
                {
                  NumInterpretiveOperands = 0;
                  if (i < NumFields)
                    ParseInputRecord.Operator = Fields[i++];
                }
            }
          NotOffset: if (i < NumFields)
            ParseInputRecord.Operand = Fields[i++];
          if (i < NumFields)
            ParseInputRecord.Mod1 = Fields[i++];
          if (i < NumFields)
            ParseInputRecord.Mod2 = Fields[i++];
          if (i < NumFields)
            ParseInputRecord.Extra = Fields[i];
        }

      // Take care of the silly --block1 or --blk2 construct where some operators which are
      // intended to operate at their own address are not followed by an operand.
      // I'm not sure how many different operators are affected by this, so I'm
      // just hard-coding the ones I've seen.
      if (NULL == ParseInputRecord.Operand || 0 == ParseInputRecord.Operand[0])
        {
          if (!strcmp(ParseInputRecord.Operator, "TC")
              /*|| !strcmp(ParseInputRecord.Operator, "BBCON*") */)
            ParseInputRecord.Operand = "-0";
          else if (Block1)
            {
              if (!strcmp(ParseInputRecord.Operator, "CADR"))
                {
                  static char fakeOperand[32];
                  sprintf(fakeOperand, "%o",
                      (ParseInputRecord.ProgramCounter.FB << 10)
                          + (ParseInputRecord.ProgramCounter.SReg & 01777));
                  ParseInputRecord.Operand = fakeOperand;
                }
            }
        }

      // At this point, the input line has been completely parsed into
      // the fields Label, FalseLabel, Operator, Operand, Increment,
      // and Comment.  Proceed with the analysis.

      if (formatOnly)
        {
          int yes = 0;
          if (ParseInputRecord.Label[0] || ParseInputRecord.Operator[0]
              || ParseInputRecord.Operand[0])
            {
              yes = 1;
              if (ParseInputRecord.Label[0])
                printf("%-15s", ParseInputRecord.Label);
              else if (ParseInputRecord.FalseLabel[0])
                printf(" %-14s", ParseInputRecord.FalseLabel);
              else
                printf("               ");
              printf("%c", ParseInputRecord.Column8);
              if (ParseInputRecord.Operator[0])
                printf("%-16s", ParseInputRecord.Operator);
              else
                printf("                ");
              if (ParseInputRecord.Operand[0])
                printf("%-16s", ParseInputRecord.Operand);
              else
                printf("                ");
              if (ParseInputRecord.Mod1[0])
                printf("%-8s", ParseInputRecord.Mod1);
              else
                printf("        ");
              if (ParseInputRecord.Mod2[0])
                printf("%-8s", ParseInputRecord.Mod2);
              else
                printf("        ");
            }
          if (ParseInputRecord.Comment[0])
            {
              if (!yes && ParseInputRecord.commentColumn > 0)
                {
                  printf("%*s", 64, " ");
                }
              if (ParseInputRecord.Comment[0] != '#')
                {
                  printf("#%s", ParseInputRecord.Comment);
                }
              else
                {
                  printf("%s", ParseInputRecord.Comment);
                }
            }
          printf("\n");
          continue;
        }
      if (toYulOnly)
        {
          char dummyLabel[32], dummyOperator[32], dummyOperand[48];
          if (*ParseInputRecord.Comment == ' ')
            ParseInputRecord.Comment++;
          if (ParseInputRecord.commentColumn == 0
              && ParseInputRecord.Comment[0] != 0)
            {
              printf("R%04d   %-72s\n", toYulOnlySequenceNumber++,
                  ParseInputRecord.Comment);
              continue;
            }
          if (ParseInputRecord.Label[0] == 0
              && ParseInputRecord.Operator[0] == 0
              && ParseInputRecord.Operand[0] == 0)
            {
              if (ParseInputRecord.Comment[0] == 0)
                printf("R%04d   %-72s\n", toYulOnlySequenceNumber++, "");
              else
                printf("A%04d   %-32s%-40s\n", toYulOnlySequenceNumber++, "",
                    ParseInputRecord.Comment);
              continue;
            }

          if (ParseInputRecord.Label[0])
            strcpy(dummyLabel, ParseInputRecord.Label);
          else if (ParseInputRecord.FalseLabel[0])
            sprintf(dummyLabel, " %s", ParseInputRecord.FalseLabel);
          else
            dummyLabel[0] = 0;
          if (ParseInputRecord.Column8 != ' ')
            sprintf(dummyOperator, "%c%s", ParseInputRecord.Column8,
                ParseInputRecord.Operator);
          else
            strcpy(dummyOperator, ParseInputRecord.Operator);
          sprintf(dummyOperand, "%s %s %s", ParseInputRecord.Operand,
              ParseInputRecord.Mod1, ParseInputRecord.Mod2);
          printf(" %04d   %-8s %-6s %-16s%-40s\n", toYulOnlySequenceNumber++,
              dummyLabel, dummyOperator, dummyOperand,
              ParseInputRecord.Comment);
          continue;
        }

      ParseOutputRecord.Column8 = ParseInputRecord.Column8;
      if (*ParseInputRecord.Operator == 0 && !NumInterpretiveOperands)
        {
          ParseOutputRecord.ProgramCounter = ParseInputRecord.ProgramCounter;
          ParseOutputRecord.Extend = ParseInputRecord.Extend;
          ParseOutputRecord.EBank = ParseInputRecord.EBank;
          ParseOutputRecord.SBank = ParseInputRecord.SBank;
          ParseOutputRecord.Index = ParseInputRecord.Index;
          ParseOutputRecord.IndexValid = ParseInputRecord.IndexValid;
        }
      else
        {
          // Most aliases are included directly in the Parsers table.
          // The NOOP alias is treated specially, because it aliases in
          // two different ways, depending upon the location in memory.
          if (!strcmp(ParseInputRecord.Operator, "NOOP")
              && !NumInterpretiveOperands)
            {
              if (0 != *ParseInputRecord.Operand)
                {
                  strcpy(ParseOutputRecord.ErrorMessage,
                      "Extra fields in line.");
                  ParseOutputRecord.Warning = 1;
                }

              if (Block1)
                {
                  ParseInputRecord.Operator = "XCH";
                  ParseInputRecord.Operand = "0";
                }
              else
                {
                  if (ParseInputRecord.ProgramCounter.Erasable)
                    {
                      ParseInputRecord.Operator = "CA";
                      ParseInputRecord.Operand = "A";
                    }
                  else
                    {
                      ParseInputRecord.Operator = "TCF";
                      ParseInputRecord.Operand = "+1";
                    }
                }

              ParseInputRecord.Alias = "NOOP";
            }

          //-------------------------------------------------------------------------------------------------------
          AliasRetry:
          // We treat the interpretive opcodes first (except for STCALL, STODL,
          // STORE, and STOVL) separately, because they are more regular and
          // don't follow the pattern of the other opcodes.
          if (Block1 && noOperator)
            iMatch = 0;
          else
            iMatch = FindInterpreter(ParseInputRecord.Operator);
          if (iMatch)
            {
              InterpreterMatch_t *iMatch2;
              if (!strcmp(ParseInputRecord.Operator, "STADR")
                  || !strcmp(ParseInputRecord.Operand, "STADR"))
                StadrInvert = 2;
              // We check to see if the opcode is an interpretive opcode.
              // If not, then we can fall through and process regular opcodes.
              // If it is, there are two possibilities:  Either there is a
              // single interpretive opcode, or else there are two (with the
              // second being in the operand field).  We must also observe the
              // number of operands required by the instructions, and then to
              // increase NumInterpretive Operands by this amount.
              NumInterpretiveOperands = 0;
              // Look for a second one.
              iMatch2 = NULL;
              if (!foundInterpreterOperandCount)
                {
                  if (ParseInputRecord.Operand[0])
                    {
                      iMatch2 = FindInterpreter(ParseInputRecord.Operand);
                      if (!iMatch2)
                        {
                          sprintf(ParseOutputRecord.ErrorMessage,
                              "Unrecognized interpretive opcode \"%s\".",
                              ParseInputRecord.Operand);
                          ParseOutputRecord.Fatal = 1;
                        }
                    }
                }
              // At this point, iMatch should point to an interpretive
              // opcode's type record, and iMatch2 will either be NULL
              // or else point to one also.
              NumInterpretiveOperands = 0;
              ParseOutputRecord.NumWords = 1;
              if (Block1)
                {
                  ParseOutputRecord.Words[0] = 040000 | (iMatch->Code << 7);
                  if (foundInterpreterOperandCount)
                    ParseOutputRecord.Words[0] += 0177
                        - expectedNumInterpreterOperatorLines;
                  else if (*ParseInputRecord.Operand == 0)
                    ParseOutputRecord.Words[0] += 0177;
                  else if (iMatch2)
                    ParseOutputRecord.Words[0] += iMatch2->Code;
                  ParseOutputRecord.Words[0]--;
                }
              else
                {
                  if (iMatch->NumOperands)
                    {
                      SwitchIncrement[NumInterpretiveOperands] =
                          iMatch->ArgTypes[0];
                      nnnnFields[NumInterpretiveOperands++] = iMatch->nnnn0000;
                      if (iMatch->NumOperands > 1)
                        {
                          SwitchIncrement[NumInterpretiveOperands] =
                              iMatch->ArgTypes[1];
                          nnnnFields[NumInterpretiveOperands++] = 0;
                        }
                    }
                  if (iMatch2)
                    {
                      if (iMatch2->NumOperands)
                        {
                          SwitchIncrement[NumInterpretiveOperands] =
                              iMatch2->ArgTypes[0];
                          nnnnFields[NumInterpretiveOperands++] =
                              iMatch2->nnnn0000;
                          if (iMatch2->NumOperands > 1)
                            {
                              SwitchIncrement[NumInterpretiveOperands] =
                                  iMatch2->ArgTypes[1];
                              nnnnFields[NumInterpretiveOperands++] = 0;
                            }
                        }
                    }
                  RawNumInterpretiveOperands = NumInterpretiveOperands;
                  ParseOutputRecord.Words[0] = (0177 & (iMatch->Code + 1));
                  if (iMatch2)
                    ParseOutputRecord.Words[0] |= (037600
                        & ((iMatch2->Code + 1) << 7));
                  ParseOutputRecord.Words[0] = (077777
                      & ~ParseOutputRecord.Words[0]);
                }
              IncPc(&ParseInputRecord.ProgramCounter,
                  ParseOutputRecord.NumWords,
                  &ParseOutputRecord.ProgramCounter);
              ParseOutputRecord.EBank = ParseInputRecord.EBank;
              ParseOutputRecord.SBank = ParseInputRecord.SBank;
              //UpdateBankCounts(&ParseOutputRecord.ProgramCounter);
              goto WriteDoIt;
            }
          else if (NumInterpretiveOperands && !PinchHitting)
            {
              // In this case, we need to find an operand for an interpretive
              // opcode.  This will be either a label, or else a label with an
              // offset.  Having found such an argument, we need to decrement
              // NumInterpretiveOperands.
              if (*ParseInputRecord.Operator == 0
                  && *ParseInputRecord.Operand == 0)
                {
                  ParseOutputRecord.Words[0] = 0;
                  ParseOutputRecord.ProgramCounter =
                      ParseInputRecord.ProgramCounter;
                  ParseOutputRecord.EBank = ParseInputRecord.EBank;
                  ParseOutputRecord.SBank = ParseInputRecord.SBank;
                  goto WriteDoIt;
                }
              else if (*ParseInputRecord.Operator == 0
                  && *ParseInputRecord.Operand != 0)
                {
                  ParseOutputRecord.NumWords = 1;
                  ParseInterpretiveOperand(&ParseInputRecord,
                      &ParseOutputRecord);
                  //ParseOutputRecord.Words[0] = AddAgc(ParseOutputRecord.Words[0], OpcodeOffset);
                  NumInterpretiveOperands--;
                  IncPc(&ParseInputRecord.ProgramCounter,
                      ParseOutputRecord.NumWords,
                      &ParseOutputRecord.ProgramCounter);
                  ParseOutputRecord.EBank = ParseInputRecord.EBank;
                  ParseOutputRecord.SBank = ParseInputRecord.SBank;
                  //UpdateBankCounts(&ParseOutputRecord.ProgramCounter);
                  goto WriteDoIt;
                }
              else
                {
                  sprintf(ParseOutputRecord.ErrorMessage,
                      "Missing interpretive operands.");
                  ParseOutputRecord.Fatal = 1;
                  ParseOutputRecord.NumWords = 1;
                  ParseOutputRecord.Words[0] = 0;
                  NumInterpretiveOperands = 0;
                  IncPc(&ParseInputRecord.ProgramCounter,
                      ParseOutputRecord.NumWords,
                      &ParseOutputRecord.ProgramCounter);
                  ParseOutputRecord.EBank = ParseInputRecord.EBank;
                  ParseOutputRecord.SBank = ParseInputRecord.SBank;
                  //UpdateBankCounts(&ParseOutputRecord.ProgramCounter);
                  goto WriteDoIt;
                }
            }

          //-------------------------------------------------------------------------------------------------------
          // Now try regular, non-interpretive opcodes.
          Match = FindParser(ParseInputRecord.Operator);
          if (!Match)
            {
              int NumOperator;

              // Check for the special case of a number simply being used in place
              // of the operator.
              if (!GetOctOrDec(ParseInputRecord.Operator, &NumOperator))
                {
                  extern int
                  ParseGeneral(ParseInput_t *, ParseOutput_t *, int, int);
                  int i, Value;
                  int Flags = 0;

                  // Based on "2 0002" assembling to "20003" in Retread, it appears that we need
                  // to figure out if numeric codes correspond to double-word instructions (which
                  // would increment the operand by 1, assuming "2 0002" is treated as "DAS 0002").
                  // To do that we need to resolve the operand and figure out which quarter-code we're
                  // getting.
                  i = GetOctOrDec(ParseInputRecord.Operand, &Value);

                  if (i) {
                      // Operand wasn't numeric, so try it as a label.
                      Address_t K;
                      char args[32];
                      args[0] = '\0';

                      if (ParseInputRecord.Mod1) strcpy(args, ParseInputRecord.Mod1);
                      i = FetchSymbolPlusOffset(&ParseInputRecord.ProgramCounter, ParseInputRecord.Operand, args, &K);
                      if (i) {
                          // Wasn't a symbol either. Panic.
                          sprintf(ParseOutputRecord.ErrorMessage, "Symbol \"%s\" undefined or offset bad", 
                                  ParseInputRecord.Operand);
                          ParseOutputRecord.Fatal = 1;
                      }
                      // We were able to resolve our symbol
                      Value = K.SReg;
                  }
                  
                  // Check for one of the double-word instructions. If we find one, notify
                  // ParseGeneral that one needs to be added to the operand.
                  if ((!ParseInputRecord.Extend && (NumOperator == 2) && ((Value & 006000) == 0)) // DAS
                     || (!ParseInputRecord.Extend && (NumOperator == 5) && ((Value & 006000) == 002000)) // DXCH
                     || (ParseInputRecord.Extend && (NumOperator == 4)) // DCA
                     || (ParseInputRecord.Extend && (NumOperator == 5))) { // DCS
                      Flags |= KPLUS1;
                  }

                  ParseGeneral(&ParseInputRecord, &ParseOutputRecord,
                      NumOperator << 12, Flags);
                  ParseOutputRecord.Words[0] = AddAgc(
                      ParseOutputRecord.Words[0], OpcodeOffset);
                  ParseOutputRecord.EBank.oneshotPending = 0;
                  ParseOutputRecord.SBank.oneshotPending = 0;
                  goto WriteDoIt;
                }

              // Okay, nothing works.
              ParseOutputRecord.ProgramCounter =
                  ParseInputRecord.ProgramCounter;
              ParseOutputRecord.EBank = ParseInputRecord.EBank;
              ParseOutputRecord.SBank = ParseInputRecord.SBank;
              sprintf(ParseOutputRecord.ErrorMessage,
                  "Unrecognized opcode/pseudo-op \"%s\".",
                  ParseInputRecord.Operator);
              ParseOutputRecord.Fatal = 1;

              // The following is just an approximation.  Since almost every
              // operator produces a single word of output, it is more accurate
              // to ASSUME this rather than not to advance the program counter.
              IncPc(&ParseInputRecord.ProgramCounter, 1,
                  &ParseOutputRecord.ProgramCounter);
            }
          else
            {
              if (!Match->Parser && *Match->AliasOperator == 0)
                {
                  // This is the way we have marked operators we simply wish
                  // to silently discard.
                  ParseOutputRecord.ProgramCounter =
                      ParseInputRecord.ProgramCounter;
                }
              else if (!Match->Parser)
                {
                  if (*ParseInputRecord.Operand != 0)
                    {
                      strcpy(ParseOutputRecord.ErrorMessage,
                          "Extra fields are present.");
                      ParseOutputRecord.Warning = 1;
                    }
                  ParseInputRecord.Alias = ParseInputRecord.Operator;
                  ParseInputRecord.Operator = Match->AliasOperator;
                  ParseInputRecord.Operand = Match->AliasOperand;
                  ParseInputRecord.Mod1 = ParseInputRecord.Mod2 = "";
                  goto AliasRetry;
                }
              else
                {
                  int i;

                  (*Match->Parser)(&ParseInputRecord, &ParseOutputRecord);
                  i = ParseOutputRecord.Words[0];

                  ParseOutputRecord.Words[0] = AddAgc(
                      ParseOutputRecord.Words[0], OpcodeOffset);

                  if ((ParseOutputRecord.Words[0] & 040000) && !(i & 040000))
                    ParseOutputRecord.Words[0]--;

                  ParseOutputRecord.Words[0] = (ParseOutputRecord.Words[0]
                      + Match->Adder) ^ Match->XMask;
                  ParseOutputRecord.Words[1] = (ParseOutputRecord.Words[1]
                      + Match->Adder2) ^ Match->XMask2;

                  if (ParseInputRecord.EBank.oneshotPending
                      && (Match->Parser == ParseBBCON
                          || Match->Parser == Parse2CADR))
                    ParseOutputRecord.EBank.current =
                        ParseInputRecord.EBank.last;

                  if (ParseInputRecord.SBank.oneshotPending
                      && (Match->Parser == ParseBBCON
                          || Match->Parser == Parse2CADR))
                    {
//#ifdef YAYUL_TRACE
//                        printf("--- %s (\"%s\",\"%s\",\"%s\") - one-shot, resetting SBank...\n",
//                               ParseInputRecord.Operator, ParseInputRecord.Operand, ParseInputRecord.Mod1, ParseInputRecord.Mod2);
//#endif
                      ParseOutputRecord.SBank.current =
                          ParseInputRecord.SBank.last;
                    }

                  if (Match->Parser != &ParseEBANKEquals)
                    {
                      ParseOutputRecord.EBank.oneshotPending = 0;
                    }

                  if (Match->Parser != &ParseSBANKEquals)
                    {
//#ifdef YAYUL_TRACE
//                        printf("--- %s (\"%s\",\"%s\",\"%s\") - disabling one-shot-pending\n",
//                               ParseInputRecord.Operator, ParseInputRecord.Operand, ParseInputRecord.Mod1, ParseInputRecord.Mod2);
//#endif
                      ParseOutputRecord.SBank.oneshotPending = 0;
                    }
                }
            }

        }
      WriteDoIt: if (Block1 && ParseInputRecord.InversionPending)
        ParseOutputRecord.Words[0] = 077777 & ~ParseOutputRecord.Words[0];
      if (StadrInvert && ParseOutputRecord.NumWords > 0)
        {
          if (StadrInvert == 1)
            ParseOutputRecord.Words[0] = 077777 & ~ParseOutputRecord.Words[0];
          StadrInvert--;
        }

      UpdateBankCounts(&ParseOutputRecord.ProgramCounter);

      if (ParseOutputRecord.ProgramCounter.FB >= 030 && ParseOutputRecord.ProgramCounter.FB <= 037
         && ParseOutputRecord.NumWords > 0)
        {
          // If (and only if) this operation emitted at least one word, update the current
          // superbank to match whichever we're in.
          if (ParseOutputRecord.ProgramCounter.Super)
            ParseOutputRecord.SBank.current = 4;
          else
            ParseOutputRecord.SBank.current = 3;
      }


      // If there is a label, and if this isn't `=' or `EQUALS', then
      // the value of the label is the current address.
      if (*ParseInputRecord.Label != 0 && !ParseOutputRecord.Equals
          && strcmp(ParseInputRecord.Operator, "MEMORY")
          && strcmp(ParseInputRecord.Operator, "CHECK="))
        {
          int Type = SYMBOL_LABEL;

          // JMS: This seems to capture two cases: labels which are used
          // to denote program line numbers, and constants which really hold
          // the memory location. If the operator is ERASE/OCT/DEC/DEC*/2DEC
          // or 2DEC*, then the symbol is already an embedded constant so
          // we will treat it as variable
          //EditSymbol(ParseInputRecord.Label, &ParseInputRecord.ProgramCounter);
          if (IsEmbeddedConstant(ParseInputRecord.Operator))
            {
              Type = SYMBOL_VARIABLE;
            }

          EditSymbolNew(ParseInputRecord.Label,
              &ParseInputRecord.ProgramCounter, Type, CurrentFilename,
              CurrentLineInFile);
        }

      // Write the output.
      if (WriteOutput && !IncludeDirective)
        {
          char *Suffix;

          // If doing HTML output, need to put an anchor here if the line has a label
          // or is a definition of a variable or constant.
          if (HtmlOut && *ParseInputRecord.Label != 0)
            fprintf(HtmlOut, "<a name=\"%s\"></a>",
                NormalizeAnchor(ParseInputRecord.Label));

          if (*ParseInputRecord.Alias != 0)
            {
              ParseInputRecord.Operator = ParseInputRecord.Alias;
              ParseInputRecord.Operand = "";
            }

          if (ParseOutputRecord.Fatal)
            {
              printf("%s:%d: Fatal Error: %s\n", CurrentFilename,
                  CurrentLineInFile, ParseOutputRecord.ErrorMessage);
              if (HtmlOut)
                fprintf(HtmlOut, COLOR_FATAL "Fatal Error:  %s</span>\n",
                    ParseOutputRecord.ErrorMessage);
              fprintf(stderr, "%s:%d: Fatal Error: %s\n", CurrentFilename,
                  CurrentLineInFile, ParseOutputRecord.ErrorMessage);
              (*Fatals)++;
            }
          else if (ParseOutputRecord.Warning)
            {
              printf("Warning: %s:\n", ParseOutputRecord.ErrorMessage);
              if (HtmlOut)
                fprintf(HtmlOut, COLOR_WARNING "Warning:  %s</span>\n",
                    ParseOutputRecord.ErrorMessage);
              fprintf(stderr, "%s:%d: Warning: %s\n", CurrentFilename,
                  CurrentLineInFile, ParseOutputRecord.ErrorMessage);
              (*Warnings)++;
            }
          printf("%06d,%06d: ", CurrentLineAll, CurrentLineInFile);
          if (HtmlOut)
            fprintf(HtmlOut, "%06d,%06d: ", CurrentLineAll, CurrentLineInFile);
          if (*ParseInputRecord.Label != 0 || *ParseInputRecord.FalseLabel != 0
              || *ParseInputRecord.Operator != 0
              || *ParseInputRecord.Operand != 0
              || *ParseInputRecord.Comment != 0)
            {
              if (*ParseInputRecord.Label != 0
                  || *ParseInputRecord.FalseLabel != 0
                  || *ParseInputRecord.Operator != 0
                  || *ParseInputRecord.Operand != 0)
                {
                  AddressPrint(&ParseInputRecord.ProgramCounter);
                }
              else
                {
                  printf("         ");
                  if (HtmlOut)
                    fprintf(HtmlOut, "         ");
                }
              if (ParseOutputRecord.LabelValueValid)
                {
                  AddressPrint(&ParseOutputRecord.LabelValue);
                  //printf("%06o  ", ParseOutputRecord.LabelValue);
                }
              else
                {
                  printf("         ");
                  if (HtmlOut)
                    fprintf(HtmlOut, "         ");
                }
              if (ParseOutputRecord.NumWords > 0)
                {
                  if (ParseOutputRecord.Words[0] == ILLEGAL_SYMBOL_VALUE)
                    {
                      printf("????? ");
                      if (HtmlOut)
                        fprintf(HtmlOut, "????? ");
                    }
                  else
                    {
                      printf("%05o ", ParseOutputRecord.Words[0] & 077777);
                      if (HtmlOut)
                        fprintf(HtmlOut, "%05o ",
                            ParseOutputRecord.Words[0] & 077777);
                      // Write the binary.
                      if (!ParseInputRecord.ProgramCounter.Invalid
                          && ParseInputRecord.ProgramCounter.Address
                          && ParseInputRecord.ProgramCounter.Fixed)
                        {
                          int bank;

                          if (ParseInputRecord.ProgramCounter.Banked)
                            {
                              bank = ParseInputRecord.ProgramCounter.FB;
                              if (bank >= 020
                                  && ParseInputRecord.ProgramCounter.Super)
                                bank += 010;
                            }
                          else
                            {
                              bank = ParseInputRecord.ProgramCounter.SReg
                                  / 02000;
                            }

                          for (i = 0; i < ParseOutputRecord.NumWords; i++)
                            {
                              int SReg = (ParseInputRecord.ProgramCounter.SReg + i) & 01777;
                              int Data = ParseOutputRecord.Words[i] & 077777;
                              ObjectCode[bank][SReg] = Data;
                              Parities[bank][SReg] = CalculateParity(Data);
                            }

                          // JMS: 07.28
                          // When we place the object code in the buffer, we'll add it to the
                          // line table. We assume there are no duplicates here nor do we
                          // check. We will remove duplicates when sorting at the end.
                          AddLine(&ParseInputRecord.ProgramCounter,
                              CurrentFilename, CurrentLineInFile);
                        }
                    }
                }
              else
                {
                  printf("      ");
                  if (HtmlOut)
                    fprintf(HtmlOut, "%s", NormalizeStringN("", 6));
                }

              if (ParseOutputRecord.NumWords > 1)
                {
                  if (ParseOutputRecord.Words[1] == ILLEGAL_SYMBOL_VALUE)
                    {
                      printf("????? ");
                      if (HtmlOut)
                        fprintf(HtmlOut, "?????&nbsp");
                    }
                  else
                    {
                      printf("%05o ", ParseOutputRecord.Words[1] & 077777);
                      if (HtmlOut)
                        fprintf(HtmlOut, "%05o ",
                            ParseOutputRecord.Words[1] & 077777);
                    }
                }
              else
                {
                  printf("      ");
                  if (HtmlOut)
                    fprintf(HtmlOut, "%s", NormalizeStringN("", 6));
                }

              if (ArgType == 1)
                Suffix = ",1";
              else if (ArgType == 2)
                Suffix = ",2";
              else
                Suffix = "";

              if (*Suffix)
                {
                  if (*ParseInputRecord.Mod1)
                    strcat(ParseInputRecord.Mod1, Suffix);
                  else if (*ParseInputRecord.Operand)
                    strcat(ParseInputRecord.Operand, Suffix);
                }

              printf(" %-8s %-8s %c%-8s %-10s %-10s %-8s\t#%s",
                  ParseInputRecord.Label, ParseInputRecord.FalseLabel,
                  ParseOutputRecord.Column8, ParseInputRecord.Operator,
                  ParseInputRecord.Operand, ParseInputRecord.Mod1,
                  ParseInputRecord.Mod2, ParseInputRecord.Comment);

              if (HtmlOut)
                {
                  Symbol_t *Symbol;
                  int Comma = 0, Dollar = 0, n;

                  if (*ParseInputRecord.Label == 0)
                    fprintf(HtmlOut, " %s ",
                        NormalizeStringN(ParseInputRecord.Label, 8));
                  else
                    fprintf(HtmlOut, " " COLOR_SYMBOL "%s</span> ",
                        NormalizeStringN(ParseInputRecord.Label, 8));
                  fprintf(HtmlOut, "%s ",
                      NormalizeStringN(ParseInputRecord.FalseLabel, 8));
                  // The Operator could be an interpretive instruction, a basic opcode,
                  // a pseudo-op, or a downlink code, and we want to colorize them
                  // differently in those cases.
                  fprintf(HtmlOut, "%c", ParseOutputRecord.Column8);
                  Match = NULL;
                  iMatch = FindInterpreter(ParseInputRecord.Operator);
                  if (iMatch)
                    {
                      fprintf(HtmlOut, COLOR_INTERPRET);
                    }
                  else
                    {
                      Match = FindParser(ParseInputRecord.Operator);
                      if (Match)
                        {
                          if (Match->OpType == OP_DOWNLINK)
                            fprintf(HtmlOut, COLOR_DOWNLINK);
                          else if (Match->OpType == OP_PSEUDO)
                            fprintf(HtmlOut, COLOR_PSEUDO);
                          else if (Match->OpType == OP_INTERPRETER)
                            fprintf(HtmlOut, COLOR_INTERPRET);
                          else
                            fprintf(HtmlOut, COLOR_BASIC);
                        }
                      else if (!strcmp(ParseInputRecord.Operator, "NOOP"))
                        {
                          Match = FindParser("CAF");
                          fprintf(HtmlOut, COLOR_BASIC);
                        }
                    }

                  fprintf(HtmlOut, "%s",
                      NormalizeStringN(ParseInputRecord.Operator, 8));
                  if (iMatch || Match)
                    fprintf(HtmlOut, "</span>");
                  fprintf(HtmlOut, " ");
                  // Detecting a symbol here is a little tricky, since if used for
                  // the interpreter there may be a suffixed ",1" or ",2" which we
                  // have to detect and account for.  Or, for the COUNT* pseudo-op,
                  // may have a prefixed "$$/".
                  // ... For interpretive stuff it's even trickier than I thought,
                  // since there are often symbols with the same name as
                  // interpretive instructions, or where there's a symbol like
                  // "AXT" and an interpreter instruction like "AXT,1".  *Sigh!*
                  if (iMatch)
                    {
                      j = IsInterpretive(ParseInputRecord.Operand);
                      if (j)
                        goto InterpreterOpcode;
                    }
                  Symbol = GetSymbol(ParseInputRecord.Operand);
                  n = strlen(ParseInputRecord.Operand);
                  if (!Symbol)
                    {
                      if (iMatch)
                        {
                          if (n > 2 && ParseInputRecord.Operand[n - 2] == ','
                              && (ParseInputRecord.Operand[n - 1] == '1'
                                  || ParseInputRecord.Operand[n - 1] == '2'))
                            {
                              ParseInputRecord.Operand[n - 2] = 0;
                              Symbol = GetSymbol(ParseInputRecord.Operand);
                              ParseInputRecord.Operand[n - 2] = ',';
                              if (Symbol)
                                {
                                  Comma = 1;
                                  goto FoundComma;
                                }
                            }
                        }
                      if (!strncmp(ParseInputRecord.Operand, "$$/", 3))
                        {
                          Symbol = GetSymbol(&ParseInputRecord.Operand[3]);
                          if (Symbol)
                            {
                              Dollar = 3;
                              goto FoundComma;
                            }
                        }
                      // Well, it's not a variable or label match.  It could still be an
                      // interpreter opcode.
                      j = IsInterpretive(ParseInputRecord.Operand);

                      InterpreterOpcode: if (j)
                        fprintf(HtmlOut, COLOR_INTERPRET);
                      fprintf(HtmlOut, "%s",
                          NormalizeStringN(ParseInputRecord.Operand, 10));
                      if (j)
                        fprintf(HtmlOut, "</span>");
                      fprintf(HtmlOut, " ");
                    }
                  else
                    {
                      FoundComma: if (Dollar)
                        fprintf(HtmlOut, "$$/");
                      if (!strcmp(CurrentFilename, Symbol->FileName))
                        fprintf(HtmlOut, "<a href=\"");
                      else
                        fprintf(HtmlOut, "<a href=\"%s",
                            NormalizeFilename(Symbol->FileName));
                      if (Comma)
                        ParseInputRecord.Operand[n - 2] = 0;
                      fprintf(HtmlOut, "#%s\">",
                          NormalizeAnchor(&ParseInputRecord.Operand[Dollar]));
                      fprintf(HtmlOut, "%s</a>",
                          NormalizeString(&ParseInputRecord.Operand[Dollar]));
                      if (Comma)
                        {
                          ParseInputRecord.Operand[n - 2] = ',';
                          fprintf(HtmlOut, "%s",
                              &ParseInputRecord.Operand[n - 2]);
                        }
                      fprintf(HtmlOut, " ");
                      for (i = n; i < 10; i++)
                        fprintf(HtmlOut, " ");
                    }

                  fprintf(HtmlOut, "%s ",
                      NormalizeStringN(ParseInputRecord.Mod1, 10));
                  fprintf(HtmlOut, "%s",
                      NormalizeStringN(ParseInputRecord.Mod2, 8));
                  fprintf(HtmlOut, "%s", NormalizeStringN("", 8));

                  if (*ParseInputRecord.Comment)
                    fprintf(HtmlOut, COLOR_COMMENT "#%s%s</span>",
                        (ParseInputRecord.Comment[0] == '#') ? "" : " ",
                        NormalizeString(ParseInputRecord.Comment));
                }
            }

          printf("\n");
          if (HtmlOut)
            fprintf(HtmlOut, "\n");
        }
    }

  // Done with this pass.
  RetVal = 0;

  Done: if (InputFile)
    fclose(InputFile);

  for (i = 0; i < NumStackedIncludes; i++)
    fclose(StackedIncludes[i].InputFile);

  NumStackedIncludes = 0;

  return (RetVal);
}
