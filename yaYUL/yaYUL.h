/*
 *  Copyright 2003-2005,2009-2010,2016-2018,2021 Ronald S. Burkey <info@sandroid.org>
 *
 *  This file is part of yaAGC.
 *
 *  yaAGC is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  yaAGC is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with yaAGC; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *  Filename:     yaYUL.h
 *  Purpose:      This is a header file for use with yaYUL.c.
 *  Mod History:  04/11/03 RSB   Began.
 *                04/19/03 RSB   Began reworking for better use of
 *                               addresses.
 *                06/13/03 RSB   Changed criteria for assigning current
 *                               address to a label.
 *                07/03/04 RSB   Now provide an array into which the binary
 *                               can be buffered for later output to a file.
 *                07/07/04 RSB   Aliases for ZL and ZQ instructions fixed.
 *                07/09/04 RSB   Added 2FCADR.
 *                07/21/04 RSB   Now discard COUNT.  Added the "special
 *                               downlink opcodes".  Added CAE, CAF, BBCON,
 *                               2CADR, 2BCADR.
 *                07/22/04 RSB   Added interpretive opcodes.
 *                07/23/04 RSB   Added VN, 2OCT, SBANK=, MM, BOF.
 *                07/30/04 RSB   Allowed for operation types to be added
 *                               to shift operands.
 *                09/04/04 RSB   CADR can now pinch-hit for an interpretive operand.
 *                09/05/04 RSB   Added =MINUS pseudo-op.
 *                07/27/05 JMS   Added SymbolFile_t, SymbolLines_t and added to
 *                               Symbol_t for symbol debugging
 *                07/28/05 JMS   Added support for writing SymbolLines_to to symbol
 *                               table file.
 *                06/27/09 RSB   Added HtmlOut.
 *                06/29/09 RSB   Added the InstOpcode field.
 *                07/01/09 RSB   Altered the way the highlighting styles
 *                               (COLOR_XXX) work in order to make them
 *                               more flexible and to shorten up the HTML
 *                               files more.
 *                07/25/09 RSB   Added lots of stuff related to providing
 *                               separate binary codes for Block 1 vs. Block 2.
 *                09/03/09 JL    Added CHECK= and =ECADR directives.
 *                01/31/10 RSB   Added Syllable field to Address_t for
 *                               Gemini OBC and Apollo LVDC.
 *                08/18/16 RSB   Moved global variables originally allocated
 *                               here, but only when #included in Pass.c,
 *                               directly into Pass.c.  It's just too difficult
 *                               to work with them through the Eclipse IDE
 *                               otherwise.
 *                10/21/16 RSB   Added provision for --flip.  Made some changes
 *                               which might be helpful for building with
 *                               MS Visual Studio.
 *                11/02/16 RSB   Added provision for --yul and --trace.
 *                11/03/16 RSB   Added variable needed for tracking whether or not
 *                               a "superbit" setting has been established in the
 *                               program or not.
 *                11/14/16 RSB   Added --to-yul.
 *                2017-01-05 RSB Added BBCON* as distinct from BBCON.
 *                2017-06-17 MAS Added --early-sbank, for simulating early (pre-1967)
 *                               YUL superbank behavior. Also lightly refactored
 *                               superbank data storage.
 *             	  2017-08-31 RSB Added stuff associated with --debug.
 *             	  2018-10-12 RSB Added stuff associated with --simulation.
 *                2021-01-24 RSB reconstructionComments.
 *             	  2021-04-20 RSB Added stuff associated with --ebcdic.
 *                2021-05-24 RSB Workaround for bad cygwin pow() function.
 *                2021-05-24 RSB ... and apparently, for MINGW as well.
 *                2021-05-24 RSB My workarounds were bogus.  I've rolled them back.
 */

#ifndef INCLUDED_YAYUL_H
#define INCLUDED_YAYUL_H

#include <stdio.h>

#if defined(WIN32) && defined(_MSC_VER )
#define MSC_VS
#endif

//-------------------------------------------------------------------------
// Constants.

#ifdef MSC_VS
#define NVER "TBD"
#define _CONSOLE
#define _CRT_SECURE_NO_WARNINGS
#endif

// The following constant should be commented out in production code.
// It is defined only to allow yaYUL to continue to be buildable while
// work on implementing block 1 (which would otherwise make a build 
// fail) is in progress.
#define TBD 0

enum OpType_t
{
  OP_BASIC, OP_INTERPRETER, OP_DOWNLINK, OP_PSEUDO
};

// Colors for HTML.
#if 0
#define COLOR_BASIC     "<span style=\"color: rgb(153, 51, 0);\">"
#define COLOR_DOWNLINK  "<span style=\"color: rgb(0, 153, 0);\">"
#define COLOR_FATAL     "<span style=\"color: rgb(255, 0, 0);\">"
#define COLOR_INTERPRET "<span style=\"color: rgb(255, 102, 0);\">"
#define COLOR_PSEUDO    "<span style=\"color: rgb(51, 102, 102);\">"
#define COLOR_SYMBOL    "<span style=\"color: rgb(0, 0, 255);\">"
#define COLOR_WARNING   "<span style=\"color: rgb(255, 153, 0);\">"
#else
#define COLOR_BASIC     "<span class=\"op\">"
#define COLOR_DOWNLINK  "<span class=\"dn\">"
#define COLOR_FATAL     "<span class=\"fe\">"
#define COLOR_INTERPRET "<span class=\"in\">"
#define COLOR_PSEUDO    "<span class=\"ps\">"
#define COLOR_SYMBOL    "<span class=\"sm\">"
#define COLOR_WARNING   "<span class=\"wn\">"
#define COLOR_COMMENT   "<span class=\"co\">"
#endif
// Default HTML styling applied.  These strings are intended to be output
// as-is, except for HTML_TABLE_START, which is used as the format string
// for a printf.
#define HTML_STYLE_START \
        "<p class=\"nobreak\">\n" \
        "<span style=\"font-family: monospace;\">\n" \
        "<pre>\n"
#define HTML_STYLE_END "</pre>\n</span>\n</p>\n"
#define HTML_TABLE_START \
        "<table style=\"margin-left: auto; margin-right: auto; width: %d%%; text-align: left;\" " \
                "border=\"1\" cellpadding=\"2\" cellspacing=\"2\">\n" \
        "<tbody>\n" \
        "<tr>\n" \
        "<td style=\"vertical-align: top;\">\n"
#define HTML_TABLE_END "</td>\n</tr>\n</tbody>\n</table>\n"

#define MAX_LABEL_LENGTH 10    // Max length of symbols (8 + optional ,1 or ,2).
#define MAX_LINE_LENGTH 256    // Was 132, but it's easy to accidentally make
                               // the lines longer by poorly estimating the
                               // amount of space in comments, and so on.
#define COMMENT_SEPARATOR '#'
// The following value is stored in the symbol table for any symbols
// whose values have not yet been resolved.
#define ILLEGAL_SYMBOL_VALUE 0x80000000
#define MAX_ASSEMBLED_WORDS 2

// Parse-behavior modification flags.  The various QCxxxx flags are
// mutually exclusive.
#define KPLUS1          0x1     // Instruction compiles to K+1 rather than K.
#define EXTENDED        0x2     // Is an extended instruction.
#define PC0             0x4     // Instruction requires peripheral-code 0.
#define QC0             0x8
#define PC1             0x10    // Inst. reqs. peripheral-code 1 or quarter-code 0.
#define PC2             0x20
#define QC1             0x40
#define PC3             0x80
#define PC4             0x100
#define QC2             0x200
#define PC5             0x400
#define PC6             0x800
#define QC3             0x1000
#define PC7             0x2000
#define QCNOT0          0x4000
#define FIXED           0x8000
#define ERASABLE        0x10000
#define ENUMBER         0x20000

#define INVALID_ADDRESS { 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
#define INVALID_EBANK { 0, INVALID_ADDRESS, INVALID_ADDRESS }
#define INVALID_SBANK { 0, 0, 0 }

//-------------------------------------------------------------------------
// Data types.

// A datatype used for addresses or symbol values.  It can represent constants,
// or addresses in all their glory. IF THIS STRUCTURE IS CHANGED, THE MACROS
// THAT IMMEDIATELY FOLLOW IT MUST ALSO BE FIXED.
typedef struct
{
  // We always want the Invalid bit to come first, for the purpose of easily
  // writing static initializers.
  unsigned Invalid :1;                   // If 1, not yet resolved.
  unsigned Constant :1;                // If 1, it's a constant, not an address.
  unsigned Address :1;                   // If 1, it really is an address.
  unsigned SReg :12;                     // S-register part of the address.
  unsigned Erasable :1;                  // If 1, it's in erasable memory.
  unsigned Fixed :1;                     // If 1, it's in fixed memory.
  // Note that for some address ranges, the following two are not in
  // conflict.  Erasable banks 0-1 overlap unbanked erasable memory,
  // while fixed banks 2-3 overlap unbanked fixed memory.
  unsigned Unbanked :1;                  // If 1, it's in unbanked memory.
  unsigned Banked :1;                    // If 1, it's in banked memory.
  // If Banked==0, the following bits are assigned to be zero.
  unsigned EB :3;                        // The EB bank bits.
  unsigned FB :5;                        // The FB bank bits.
  unsigned Super :1;                     // The super-bank bit.
  // Status bit.  If set, the address is actually invalid, since
  // by implication it is in the wrong bank.
  unsigned Overflow :1;                  // If 1, last inc. overflowed bank.
  // Last, but not least, the value itself.
  int Value;                            // Constant or full pseudo-address.
  // The syllable number ... just for Gemini OBC and Apollo LVDC.
  int Syllable;
} Address_t;

// Invalid, Constant, Address, SReg, Erasable, Fixed, Unbanked, Banked, EB, FB, Super, Overflow, Value, Syllable.
#if defined(MSC_VS)
#define VALID_ADDRESS ( { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )
#define REG(n) ( { 0, 0, 1, n, 1, 0, 1, 0, 0, 0, 0, 0, n, 0 })
#define CONSTANT(n) ( { 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, n, 0 })
#define FIXEDADD(n) ( { 0, 0, 1, n, 0, 1, 1, 0, 0, 0, 0, 0, n, 0 })
#elif defined(SOLARIS)
#define VALID_ADDRESS ((const Address_t) { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )
#define REG(n) { 0, 0, 1, n, 1, 0, 1, 0, 0, 0, 0, 0, n, 0 }
#define CONSTANT(n) { 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, n, 0 }
#define FIXEDADD(n) { 0, 0, 1, n, 0, 1, 1, 0, 0, 0, 0, 0, n, 0 }
#else
#define VALID_ADDRESS ((const Address_t) { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )
#define REG(n) ((const Address_t) { 0, 0, 1, n, 1, 0, 1, 0, 0, 0, 0, 0, n, 0 })
#define CONSTANT(n) ((const Address_t) { 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, n, 0 })
#define FIXEDADD(n) ((const Address_t) { 0, 0, 1, n, 0, 1, 1, 0, 0, 0, 0, 0, n, 0 })
#endif

//----------------------------------------------------------------------------
// JMS: Begin additions for output of symbol table to a file for symbolic
// debugging purposes.
//----------------------------------------------------------------------------

// The maximum length of the path for source files and the maximum length of
// a source file name. This perhaps should be MAXPATHLEN (in sys/param.h) but
// I wanted to keep things somewhat platform independent. Also, these are my
// best guesses at reasonable lengths
#define MAX_PATH_LENGTH  (1024)
#define MAX_FILE_LENGTH  (256)

// The SymbolFile_t structure represents the header to a symbol table
// file. The symbol file has the following structure:
//
// SymbolFile_t
// Symbol_t (many of these)
// SymbolLine_t (many of these)
//
// The SymbolFile_t structure holds the path of the source files (we
// assume for now there is only one), and the number of Symbol_t and
// SymbolLine_t structures which follow in the file.
typedef struct
{
  char SourcePath[MAX_PATH_LENGTH];     // Base path for all source
  int NumberSymbols;                   // # of Symbol_t structs
  int NumberLines;                     // # of SymbolLine_t structs
} SymbolFile_t;

// The Symbol_t structure represents a symbol within the symbol table
// This structure has been added to for the purposes of debugging. Recent
// modifications include adding a "type" to distinguish between symbols
// which are labels in the code and symbols which are variable names, and
// the source file from which the symbol came from and its line number
typedef struct
{
  char Namespace;                       // Kept for historical purposes
  char Name[1 + MAX_LABEL_LENGTH];      // The name of the symbol
  Address_t Value;                      // The symbol address
  int Type;                             // Type of symbol, see below
  char FileName[1 + MAX_FILE_LENGTH];   // Source file name
  unsigned int LineNumber;              // Line number in source file
} Symbol_t;

// Constants for the symbol type. A "register" is one of the basic
// AGC registers such as A (accumulator) or Z (program counter) which
// are found at the beginning of erasable memory. A "label" is a program
// label to which control may be transfered (say, from a branch 
// instruction like BZF). A "variable" is a names memory address which
// stores some data (from ERASE or DEC/2DEC or OCT for example). A
// "constant" is a compiler constant defined by EQUALS or "=". These
// are meant to be "masks".
#define SYMBOL_REGISTER        (1)      // A register like "A" or "L"
#define SYMBOL_LABEL           (2)      // A program label
#define SYMBOL_VARIABLE        (4)      // A memory address (ERASE)
#define SYMBOL_CONSTANT        (8)      // A constant (EQUALS or =)
#define SYMBOL_SEPARATOR       (256)    // Used for printing separators.
#define SYMBOL_EMPTY           (0)      // Use only for end of table.

// The SymbolLine_t structure represents a given line of code and the
// source file in which it can be found and its line number in the source
// file. The location of the line of code is given by an Address_t struct
// although typically these should only contain addresses of fixed memory
// locations.
typedef struct
{
  Address_t CodeAddress;              // The fixed memory location of the code
  char FileName[MAX_FILE_LENGTH];     // The source file name
  unsigned int LineNumber;            // Line number in the source
} SymbolLine_t;

// The constants are used in SortLine to tell it which sorting method to
// use, either SORT_YUL, SORT_LEMAP, or SORT_ASM depending upon the compiler.
#define SORT_YUL               (30)
#define SORT_LEMAP             (31)
#define SORT_ASM               (32)

// Edit a symbol in the table, but include symbol debugging information
// such as the symbol's type, and the source file/line number from which
// it came.
int
EditSymbolNew(const char *Name, Address_t *Value, int Type, char *FileName,
    unsigned int LineNumber);

// Writes the symbol table to a file in binary format. See yaYUL.h for
// more information about the format. Takes the name of the symbol file.
void
WriteSymbolsToFile(char *fname);

// JMS: 07.28
//-------------------------------------------------------------------------
// Delete the line table.
void
ClearLines(void);

//-------------------------------------------------------------------------
// Adds a new program line to the table. Takes the Address_t at which this
// is stored in (fixed) memory, and the file name and line number where it
// is found. Takes the number of words the instruction takes up in memory.
// Returns 0 on success, or non-zero on fatal error.
int
AddLine(Address_t *Address, const char *FileName, int LineNumber);

//-------------------------------------------------------------------------
// Sort the line table. Takes which assembler we are using (SORT_YUL or
// SORT_LEMAP) to use the proper sorting function for the addressing scheme.
void
SortLines(int Type);

//----------------------------------------------------------------------------
// JMS: End additions for output of symbol table
//----------------------------------------------------------------------------

// For EBANK= manipulations.
typedef struct
{
  int oneshotPending;              // Set while a one-shot is possible.
  Address_t current;               // Current setting.
  Address_t last;                  // Backup used during 1-shot.
} EBank_t;

// For SBANK= manipulations.
typedef struct
{
  int oneshotPending;              // Set while a one-shot is possible.
  unsigned current;               // Current setting.
  unsigned last;                  // Backup used during 1-shot.
} SBank_t;

// A string type guaranteed to contain in input line.
typedef char Line_t[1 + MAX_LINE_LENGTH];

// Stuff for parsers.
typedef struct
{
  Address_t ProgramCounter;             // Before the operation.
  int Reserved;                         // Unused.
  char *Label, *FalseLabel, *Operator, *Operand, *Mod1, *Mod2, *Comment, *Extra,
      *Alias;
  int Index;
  unsigned Extend :2;
  unsigned IndexValid :1;
  EBank_t EBank;
  SBank_t SBank;
  // This isn't really column 8, but rather the column preceding the operator,
  // which in our syntax really forms the first character of the operator,
  // but needs to be removed before the operator is processed.  The only way
  // I'm aware of in which this occurs is in Block 1, in which that character
  // may be a '-'.  At any rate, if one of these funky extra characters appears,
  // it is deposited in the following field.
  char Column8;
  int InversionPending;
  int commentColumn;
} ParseInput_t;

typedef struct
{
  Address_t ProgramCounter;             // After the operation.
  int Reserved;                         // Unused.
  int Words[MAX_ASSEMBLED_WORDS];       // Binary data assembled
  int NumWords;                         // ... and how many of them.
  Line_t ErrorMessage;                  // If any.
  Address_t LabelValue;                 // Value of the label.
  int Index;
  unsigned Warning :1;                   // Non-zero for warning.
  unsigned Fatal :1;                     // Non-zero for fatal error.
  unsigned LabelValueValid :1;           // Non-zero if LabelValue valid.
  unsigned Extend :2;
  unsigned IndexValid :1;
  EBank_t EBank;                        // For EBANK= manipulations.
  SBank_t SBank;                        // For SBANK= manipulations.
  int Equals;                           // Non-zero if = or EQUALS.
  char Column8;                         // Used only for Block1.
} ParseOutput_t;

typedef int
Parser_t(ParseInput_t *ParseIn, ParseOutput_t *ParseOut);

// A structure for matching operator names to the functions for processing
// them.
typedef struct
{
  char Name[MAX_LABEL_LENGTH + 1];
  enum OpType_t OpType;
  Parser_t *Parser;                     // If NULL, check for alias.
  char AliasOperator[MAX_LABEL_LENGTH + 1];
  char AliasOperand[MAX_LABEL_LENGTH + 1];
  // The following have really been introduced for the "special downlink
  // opcodes", which are just like some existing opcodes except that 
  // an extra value may be added and the total may be complemented.
  int Adder;                         // Extra value to add to binary (1st word).
  int XMask;                            // Value to XOR after adding.
  int Adder2;
  int XMask2;
  int PinchHit;                      // Act in place of an interpretive operand.
} ParserMatch_t;

// A structure for data about how to assemble interpreter opcodes.  This
// COULD be handled using the ParserMatch_t structure, if I was willing to
// add symbols for all of the interpreter codes to the symbol table.
// However, I'm not really willing to do that.
typedef struct
{
  char Name[MAX_LABEL_LENGTH + 1];
  unsigned char Code;
  unsigned char NumOperands;
  unsigned char SwitchInstruction;      // 0 normally, 1 switch, 2 shifts.
  int nnnn0000;
  unsigned char ArgTypes[2];
} InterpreterMatch_t;

//-------------------------------------------------------------------------
// Data.

//-------------------------------------------------------------------------
// Function prototypes.

int
Add(int n1, int n2);
void
IncPc(Address_t *Input, int Increment, Address_t *Output);
void
PseudoToSegmented(int Value, ParseOutput_t *OutputRecord);
void
PseudoToEBanked(int Value, ParseOutput_t *OutputRecord);
int
PseudoToStruct(int Value, Address_t *Address);

// From SymbolPass.c
void
SymbolPass(const char *InputFilename);

// From Pass.c
int
Pass(int WriteOutput, const char *InputFilename, FILE *OutputFile, int *Fatals,
    int *Warnings);
int
AddressPrint(Address_t *Address);

// From SymbolTable.c
void
ClearSymbols(void);
int
AddSymbol(const char *Name);
int
EditSymbol(const char *Name, Address_t *Value);
int
SortSymbols(void);
Symbol_t *
GetSymbol(const char *Name);
void
PrintSymbols(void);
void
PrintSymbolsToFile(FILE *fp);
int
UnresolvedSymbols(void);
double
ScaleFactor(char *s);
int
GetOctOrDec(const char *s, int *Value);
char *
NormalizeFilename(char *SourceName);
int
HtmlCreate(char *Filename);
void
HtmlClose(void);
int
HtmlCheck(int WriteOutput, FILE *InputFile, char *s, int sSize,
    char *CurrentFilename, int *CurrentLineAll, int *CurrentLineInFile);
char *
NormalizeAnchor(char *Name);
char *
NormalizeString(char *Input);
char *
NormalizeStringN(char *Input, int PadTo);

// From ParseGeneral.c.
int
ParseGeneral(ParseInput_t *, ParseOutput_t *, int, int);

// From Parse2DEC.c.
int
FetchSymbolPlusOffset(Address_t *OldPc, char *Operand, char *Mod1,
    Address_t *NewPc);

// From ParseERASE.c
int
GetErasableBank(Address_t pc);

// From ParseGENADR.c
int
GetFixedBank(Address_t pc);

// From ParseBANK.c
void
StartBankCounts(void);
void
UpdateBankCounts(Address_t *pc);
void
PrintBankCounts(void);
int
GetBankCount(int Bank);

// From ParseST.c
int
ParseComma(ParseInput_t *Record);

// From yul2agc.c.
void
yul2agc (char *s);

// From Utilities.c.
void
PrintAddress(const Address_t *address);
void
PrintEBank(const EBank_t *bank);
void
PrintSBank(const SBank_t *bank);
void
PrintAddress(const Address_t *address);
void
PrintInputRecord(const ParseInput_t *record);
void
PrintOutputRecord(const ParseOutput_t *record);
void
PrintTrace(const ParseInput_t *inRecord, const ParseOutput_t *outRecord);
int
CalculateParity(int Value);

// From strcmpEBCDIC.c.
int
strcmpEBCDIC(const char *s1, const char *s2);
int
strcmpHoneywell(const char *s1, const char *s2);

// Various parsers.
Parser_t ParseBLOCK, ParseEQUALS, ParseEqualsECADR, ParseCHECKequals, ParseBANK,
    ParseEquate, Parse2DEC, Parse2DECstar, ParseDEC, ParseDECstar, ParseSETLOC,
    ParseOCT, ParseTC, ParseCS, ParseAD, ParseMASK, ParseDCA, ParseDCS, ParseMP,
    ParseCCS, ParseTCF, ParseLXCH, ParseINCR, ParseCA, ParseDAS, ParseADS,
    ParseINDEX, ParseDXCH, ParseTS, ParseXCH, ParseDV, ParseBZF, ParseMSU,
    ParseQXCH, ParseAUG, ParseDIM, ParseBZMF, ParseSU, ParseRAND, ParseREAD,
    ParseROR, ParseRXOR, ParseWAND, ParseWOR, ParseWRITE, ParseERASE,
    ParseGENADR, ParseINDEX, ParseCADR, ParseFCADR, ParseECADR, ParseEBANKEquals,
    Parse2FCADR, ParseCAE, ParseCAF, ParseBBCON, ParseBBCONstar, Parse2CADR,
    ParseDNCHAN, ParseSTCALL, ParseSTODL, ParseSTORE, ParseSTOVL, ParseVN,
    Parse2OCT, ParseSBANKEquals, ParseEDRUPT, ParseInterpretiveOperand,
    ParseEqMinus, ParseXCADR, ParseSECSIZ;

extern int forceAscii;
extern int ebcdic;
extern int honeywell;
extern int Block1;
extern int EarlySBank;
extern int Raytheon;
extern int blk2;
extern char *assemblyTarget;
extern int Html;
extern FILE *HtmlOut;
extern int Simulation;

extern int ObjectCode[044][02000];
extern unsigned char Parities[044][02000];

extern int NumInterpretiveOperands, RawNumInterpretiveOperands;
extern int nnnnFields[4];
extern unsigned char SwitchIncrement[4], SwitchInvert[4];
extern int OpcodeOffset;
extern int ArgType;

extern int formatOnly;
extern int toYulOnly, toYulOnlySequenceNumber;
extern Line_t toYulOnlyLogSection;
extern int flipBugger[044];

extern int trace;
extern int asYUL;
extern int numSymbolsReassigned;
extern int thisIsTheLastPass;

extern int debugLevel;
#define DEBUG_SOLARIUM 0x8000
extern int debugPass;
extern int debugLine;
extern char *debugLineString;
void debugPrint(char *msg);

extern int reconstructionComments;
extern int inReconstructionComment;

#endif // INCLUDED_YAYUL_H

