/*
  Copyright 2003-2005,2009-2010 Ronald S. Burkey <info@sandroid.org>
  
  This file is part of yaAGC.

  yaAGC is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  yaAGC is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with yaAGC; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

  Filename:     yaYUL.h
  Purpose:      This is a header file for use with yaYUL.c.
  Mod History:  04/11/03 RSB   Began.
                04/19/03 RSB   Began reworking for better use of 
                               addresses.
                06/13/03 RSB   Changed criteria for assigning current
                               address to a label.
                07/03/04 RSB   Now provide an array into which the binary
                               can be buffered for later output to a file.
                07/07/04 RSB   Aliases for ZL and ZQ instructions fixed.
                07/09/04 RSB   Added 2FCADR.
                07/21/04 RSB   Now discard COUNT.  Added the "special
                               downlink opcodes".  Added CAE, CAF, BBCON,
                               2CADR, 2BCADR.
                07/22/04 RSB   Added interpretive opcodes.
                07/23/04 RSB   Added VN, 2OCT, SBANK=, MM, BOF.
                07/30/04 RSB   Allowed for operation types to be added
                               to shift operands.
                09/04/04 RSB   CADR can now pinch-hit for an interpretive operand.
                09/05/04 RSB   Added =MINUS pseudo-op.
                07/27/05 JMS   Added SymbolFile_t, SymbolLines_t and added to
                               Symbol_t for symbol debugging
                07/28/05 JMS   Added support for writing SymbolLines_to to symbol
                               table file.
                06/27/09 RSB   Added HtmlOut.
                06/29/09 RSB   Added the InstOpcode field.
                07/01/09 RSB   Altered the way the highlighting styles
                               (COLOR_XXX) work in order to make them
                               more flexible and to shorten up the HTML
                               files more.
                07/25/09 RSB   Added lots of stuff related to providing
                               separate binary codes for Block 1 vs. Block 2.
                09/03/09 JL    Added CHECK= and =ECADR directives.
                01/31/10 RSB   Added Syllable field to Address_t for 
                               Gemini OBC and Apollo LVDC.
*/

#ifndef INCLUDED_YAYUL_H
#define INCLUDED_YAYUL_H

#include <stdio.h>

//-------------------------------------------------------------------------
// Constants.

// The following constant should be commented out in production code.
// It is defined only to allow yaYUL to continue to be buildable while
// work on implementing block 1 (which would otherwise make a build 
// fail) is in progress.
#define TBD 0

enum OpType_t { OP_BASIC, OP_INTERPRETER, OP_DOWNLINK, OP_PSEUDO };

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
#define MAX_LINE_LENGTH 132
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

#define VALID_ADDRESS ((const Address_t) { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )
#define INVALID_ADDRESS { 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
#define INVALID_EBANK { INVALID_ADDRESS, INVALID_ADDRESS, 0, INVALID_ADDRESS }

//-------------------------------------------------------------------------
// Data types.

// A datatype used for addresses or symbol values.  It can represent constants,
// or addresses in all their glory. IF THIS STRUCTURE IS CHANGED, THE MACROS
// THAT IMMEDIATELY FOLLOW IT MUST ALSO BE FIXED.
typedef struct {
  // We always want the Invalid bit to come first, for the purpose of easily
  // writing static initializers.
  unsigned Invalid:1;                   // If 1, not yet resolved.
  unsigned Constant:1;                  // If 1, it's a constant, not an address.
  unsigned Address:1;                   // If 1, it really is an address.
  unsigned SReg:12;                     // S-register part of the address.
  unsigned Erasable:1;                  // If 1, it's in erasable memory.
  unsigned Fixed:1;                     // If 1, it's in fixed memory.
  // Note that for some address ranges, the following two are not in
  // conflict.  Erasable banks 0-1 overlap unbanked erasable memory,
  // while fixed banks 2-3 overlap unbanked fixed memory.
  unsigned Unbanked:1;                  // If 1, it's in unbanked memory.
  unsigned Banked:1;                    // If 1, it's in banked memory.
  // If Banked==0, the following bits are assigned to be zero.
  unsigned EB:3;                        // The EB bank bits.
  unsigned FB:5;                        // The FB bank bits.
  unsigned Super:1;                     // The super-bank bit.
  // Status bit.  If set, the address is actually invalid, since
  // by implication it is in the wrong bank.
  unsigned Overflow:1;                  // If 1, last inc. overflowed bank.
  // Last, but not least, the value itself.
  int Value;                            // Constant or full pseudo-address.
  // The syllable number ... just for Gemini OBC and Apollo LVDC.
  int Syllable;
} Address_t;
#define REG(n) ((const Address_t) { 0, 0, 1, n, 1, 0, 1, 0, 0, 0, 0, 0, n, 0 })
#define CONSTANT(n) ((const Address_t) { 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, n, 0 })
#define FIXEDADD(n) ((const Address_t) { 0, 0, 1, n, 0, 1, 1, 0, 0, 0, 0, 0, n, 0 })

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
typedef struct {
  char SourcePath[MAX_PATH_LENGTH];     // Base path for all source
  int  NumberSymbols;                   // # of Symbol_t structs
  int  NumberLines;                     // # of SymbolLine_t structs
} SymbolFile_t;

// The Symbol_t structure represents a symbol within the symbol table
// This structure has been added to for the purposes of debugging. Recent
// modifications include adding a "type" to distinguish between symbols
// which are labels in the code and symbols which are variable names, and
// the source file from which the symbol came from and its line number
typedef struct {
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

// The SymbolLine_t structure represents a given line of code and the
// source file in which it can be found and its line number in the source
// file. The location of the line of code is given by an Address_t struct
// although typically these should only contain addresses of fixed memory
// locations.
typedef struct {
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
int EditSymbolNew(const char *Name, Address_t *Value, int Type, char *FileName,
                  unsigned int LineNumber);

// Writes the symbol table to a file in binary format. See yaYUL.h for
// more information about the format. Takes the name of the symbol file.
void WriteSymbolsToFile(char *fname);

// JMS: 07.28
//-------------------------------------------------------------------------
// Delete the line table.
void ClearLines(void);

//-------------------------------------------------------------------------
// Adds a new program line to the table. Takes the Address_t at which this
// is stored in (fixed) memory, and the file name and line number where it
// is found. Takes the number of words the instruction takes up in memory.
// Returns 0 on success, or non-zero on fatal error.
int AddLine(Address_t *Address, const char *FileName, int LineNumber);

//-------------------------------------------------------------------------
// Sort the line table. Takes which assembler we are using (SORT_YUL or
// SORT_LEMAP) to use the proper sorting function for the addressing scheme.
void SortLines(int Type);

//----------------------------------------------------------------------------
// JMS: End additions for output of symbol table
//----------------------------------------------------------------------------

// For 'EBANK=' manipulations.
typedef struct {
  Address_t CurrentEBank;               // Current setting.
  Address_t LastEBank;                  // Backup used durint 1-shot.
  int OneshotPending;                   // Set while a one-shot is possible.
  Address_t CurrentSBank;
} EBank_t;

// A string type guaranteed to contain in input line.
typedef char Line_t[1 + MAX_LINE_LENGTH];

// Stuff for parsers.
typedef struct {
  Address_t ProgramCounter;             // Before the operation.
  int Reserved;                         // Unused.
  char *Label, *FalseLabel, *Operator, *Operand, *Mod1, *Mod2, *Comment,
       *Extra, *Alias;
  int Index;     
  unsigned Extend:1;
  unsigned IndexValid:1;     
  // For EBANK= manipulations.
  EBank_t Bank;
} ParseInput_t;

typedef struct {
  Address_t ProgramCounter;             // After the operation.
  int Reserved;                         // Unused.
  int Words[MAX_ASSEMBLED_WORDS];       // Binary data assembled
  int NumWords;                         // ... and how many of them.
  Line_t ErrorMessage;                  // If any.
  Address_t LabelValue;                 // Value of the label.
  int Index;
  unsigned Warning:1;                   // Non-zero for warning.
  unsigned Fatal:1;                     // Non-zero for fatal error.
  unsigned LabelValueValid:1;           // Non-zero if LabelValue valid. 
  unsigned Extend:1;
  unsigned IndexValid:1;     
  EBank_t Bank;                         // For EBANK=, SBANK= manipulations.
  int Equals;                           // Non-zero if = or EQUALS.
} ParseOutput_t;

typedef int Parser_t(ParseInput_t *ParseIn, ParseOutput_t *ParseOut);

// A structure for matching operator names to the functions for processing
// them.
typedef struct {
  char Name[MAX_LABEL_LENGTH + 1];
  enum OpType_t OpType;
  Parser_t *Parser;                     // If NULL, check for alias.
  char AliasOperator[MAX_LABEL_LENGTH + 1];
  char AliasOperand[MAX_LABEL_LENGTH + 1];
  // The following have really been introduced for the "special downlink
  // opcodes", which are just like some existing opcodes except that 
  // an extra value may be added and the total may be complemented.
  int Adder;                            // Extra value to add to binary (1st word).
  int XMask;                            // Value to XOR after adding.
  int Adder2;
  int XMask2;
  int PinchHit;                         // Act in place of an interpretive operand.
} ParserMatch_t;

// A structure for data about how to assemble interpreter opcodes.  This
// COULD be handled using the ParserMatch_t structure, if I was willing to
// add symbols for all of the interpreter codes to the symbol table.
// However, I'm not really willing to do that.
typedef struct {
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

int Add(int n1, int n2);
void IncPc(Address_t *Input, int Increment, Address_t *Output);
void PseudoToSegmented(int Value, ParseOutput_t *OutputRecord);
void PseudoToEBanked(int Value, ParseOutput_t *OutputRecord);
int PseudoToStruct(int Value, Address_t *Address);

// From SymbolPass.c
void SymbolPass(const char *InputFilename);

// From Pass.c
int Pass(int WriteOutput, const char *InputFilename, FILE *OutputFile, int *Fatals, int *Warnings);
int AddressPrint(Address_t *Address);

// From SymbolTable.c
void ClearSymbols(void);
int AddSymbol(const char *Name);
int EditSymbol(const char *Name, Address_t *Value);
int SortSymbols(void);
Symbol_t *GetSymbol(const char *Name);
void PrintSymbols(void);
void PrintSymbolsToFile(FILE *fp);
int UnresolvedSymbols(void);
double ScaleFactor(char *s);
int GetOctOrDec(const char *s, int *Value);
char *NormalizeFilename(char *SourceName);
int HtmlCreate(char *Filename);
void HtmlClose(void);
int HtmlCheck(int WriteOutput, FILE *InputFile, char *s, int sSize, 
              char *CurrentFilename, int *CurrentLineAll, int *CurrentLineInFile);
char *NormalizeAnchor(char *Name);
char *NormalizeString(char *Input);
char *NormalizeStringN(char *Input, int PadTo);

// From Parse2DEC.c.
int FetchSymbolPlusOffset(Address_t *OldPc, char *Operand, char *Mod1, Address_t *NewPc);

// From ParseERASE.c
int GetErasableBank(Address_t pc);

// From ParseGENADR.c
int GetFixedBank(Address_t pc);

// From ParseBANK.c
void StartBankCounts(void);
void UpdateBankCounts(Address_t *pc);
void PrintBankCounts(void);
int GetBankCount(int Bank);

// From ParseST.c
int ParseComma(ParseInput_t *Record);

// From Parse2CADR.c.
void FixSuperbankBits(ParseInput_t *InRecord, Address_t *Address, int *OutValue);

// Various parsers.
Parser_t ParseBLOCK, ParseEQUALS, ParseEqualsECADR, ParseCHECKequals, ParseBANK, ParseEquate,
         Parse2DEC, Parse2DECstar, ParseDEC, ParseDECstar,
         ParseSETLOC, ParseOCT, ParseTC, ParseCS, ParseAD,
         ParseMASK, ParseDCA, ParseDCS, ParseMP,
         ParseCCS, ParseTCF, ParseLXCH, ParseINCR, ParseCA,
         ParseDAS, ParseADS, ParseINDEX, ParseDXCH, ParseTS,
         ParseXCH, ParseDV, ParseBZF, ParseMSU, ParseQXCH,
         ParseAUG, ParseDIM, ParseBZMF, ParseSU, ParseRAND, 
         ParseREAD, ParseROR, ParseRXOR, ParseWAND, ParseWOR, 
         ParseWRITE, ParseERASE, ParseGENADR, ParseINDEX,
         ParseCADR, ParseFCADR, ParseECADR, ParseEBANK, 
         Parse2FCADR, ParseCAE, ParseCAF, ParseBBCON, Parse2CADR,
         ParseDNCHAN, ParseSTCALL, ParseSTODL, ParseSTORE, ParseSTOVL,
         ParseVN, Parse2OCT, ParseSBANKEquals, ParseEDRUPT,
         ParseInterpretiveOperand, ParseEqMinus,
         ParseXCADR; 

#ifdef ORIGINAL_PASS_C
int Block1 = 0;
int Html = 0;
FILE *HtmlOut = NULL;

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
// If, further, Operator is empten, then the entire opcode is simply
// silently discarded.  This is good for things like BNKSUM, which 
// apparently were useful long ago, but are not useful in the present
// context.
static ParserMatch_t ParsersBlock2[] = {
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
  { "BBCON*", OP_PSEUDO, NULL, "OCT", "66100" }, 
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
  { "EBANK=", OP_PSEUDO, ParseEBANK },
  { "ECADR", OP_PSEUDO, ParseECADR, "", "", 0, 0, 0, 0, 1 },
  // The following isn't a perfect equivalent for an actual EDRUPT parser
  // within the assembler, since it doesn't allow the assembler to check 
  // for the EXTEND bit as it does for other instructions.  However, as EDRUPT
  // is used "for machine checkout only", I can't imagine that I even need
  // it at all ... so I'm willing to dispense with a little cross-checking.
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
  { "ZQ", OP_BASIC, NULL, "QXCH", "$7" }
};
#define NUM_PARSERS_BLOCK2 (sizeof (ParsersBlock2) / sizeof (ParsersBlock2[0]))

static ParserMatch_t ParsersBlock1[] = { 
//  { "-1DNADR", OP_DOWNLINK, ParseECADR, "", "", 0, 077777 },
//  { "-2CADR", OP_PSEUDO, Parse2CADR, "", "", 0, 077777, 0, 077777 },
//  { "-2DNADR", OP_DOWNLINK, ParseECADR, "", "", 004000, 077777 },
//  { "-3DNADR", OP_DOWNLINK, ParseECADR, "", "", 010000, 077777 },
//  { "-4DNADR", OP_DOWNLINK, ParseECADR, "", "", 014000, 077777 },
//  { "-5DNADR", OP_DOWNLINK, ParseECADR, "", "", 020000, 077777 },
//  { "-6DNADR", OP_DOWNLINK, ParseECADR, "", "", 024000, 077777 },
//  { "-CCS", OP_BASIC, ParseCCS, "", "", 0, 077777 },
//  { "-DNCHAN", OP_DOWNLINK, ParseDNCHAN, "", "", 0, 077777 },
//  { "-DNPTR", OP_DOWNLINK, ParseGENADR, "", "", 030000, 077777 },
//  { "-GENADR", OP_PSEUDO, ParseGENADR, "", "", 0, 077777 },
  { "=", OP_PSEUDO, ParseEquate },
//  { "=ECADR", OP_PSEUDO, ParseEqualsECADR }, 
//  { "=MINUS", OP_PSEUDO, ParseEqMinus },
//  { "1DNADR", OP_DOWNLINK, ParseECADR, "", "", 0, 0 },
//  { "2BCADR", OP_PSEUDO, Parse2CADR },
//  { "2CADR", OP_PSEUDO, Parse2CADR },
  { "2DEC", OP_PSEUDO, Parse2DEC }, 
  { "2DEC*", OP_PSEUDO, Parse2DECstar },
//  { "2DNADR", OP_DOWNLINK, ParseECADR, "", "", 004000, 0 },
//  { "2FCADR", OP_PSEUDO, Parse2FCADR },
  { "2OCT", OP_PSEUDO, Parse2OCT },
//  { "3DNADR", OP_DOWNLINK, ParseECADR, "", "", 010000, 0 },
//  { "4DNADR", OP_DOWNLINK, ParseECADR, "", "", 014000, 0 },
//  { "5DNADR", OP_DOWNLINK, ParseECADR, "", "", 020000, 0 },
//  { "6DNADR", OP_DOWNLINK, ParseECADR, "", "", 024000, 0 },
  { "AD", OP_BASIC, ParseAD },
  { "ADRES", OP_PSEUDO, ParseGENADR },
//  { "ADS", OP_BASIC, ParseADS },
//  { "AUG", OP_BASIC, ParseAUG },
  { "BANK", OP_PSEUDO, ParseBANK },
//  { "BLOCK", OP_PSEUDO, ParseBLOCK },
//  { "BBCON", OP_PSEUDO, ParseBBCON },
//  { "BBCON*", OP_PSEUDO, NULL, "OCT", "66100" }, 
//  { "BNKSUM", OP_PSEUDO, NULL, "", "" },
//  { "BZF", OP_BASIC, ParseBZF },
//  { "BZMF", OP_BASIC, ParseBZMF },
//  { "CA", OP_BASIC, ParseCA }, 
//  { "CAE", OP_BASIC, ParseCAE }, 
  { "CAF", OP_BASIC, ParseXCH }, 
  { "CADR", OP_PSEUDO, ParseCADR, "", "", 0, 0, 0, 0, 1 }, 
  { "CCS", OP_BASIC, ParseCCS },
//  { "CHECK=", OP_PSEUDO, ParseCHECKequals }, 
  { "COM", OP_BASIC, NULL, "CS", "A" },
//  { "COUNT", OP_PSEUDO, NULL, "", "" },
//  { "COUNT*", OP_PSEUDO, NULL, "", "" },
  { "CS", OP_BASIC, ParseCS },
//  { "DAS", OP_BASIC, ParseDAS },
//  { "DCA", OP_BASIC, ParseDCA },
//  { "DCOM", OP_BASIC, NULL, "DCS", "A" },
//  { "DCS", OP_BASIC, ParseDCS },
//  { "DDOUBL", OP_BASIC, NULL, "DAS", "A" },
  { "DEC", OP_PSEUDO, ParseDEC, "", "", 0, 0, 0, 0, 1 }, 
//  { "DEC*", OP_PSEUDO, ParseDECstar },
//  { "DIM", OP_BASIC, ParseDIM },
//  { "DNCHAN", OP_DOWNLINK, ParseDNCHAN },
//  { "DNPTR", OP_DOWNLINK, ParseGENADR, "", "", 030000, 0 },
  { "DOUBLE", OP_BASIC, NULL, "AD", "A" },
//  { "DTCB", OP_BASIC, NULL, "DXCH", "Z" },
//  { "DTCF", OP_BASIC, NULL, "DXCH", "$4" },
  { "DV", OP_BASIC, ParseDV },
//  { "DXCH", OP_BASIC, ParseDXCH },
//  { "EBANK=", OP_PSEUDO, ParseEBANK },
//  { "ECADR", OP_PSEUDO, ParseECADR, "", "", 0, 0, 0, 0, 1 },
  // The following isn't a perfect equivalent for an actual EDRUPT parser
  // within the assembler, since it doesn't allow the assembler to check 
  // for the EXTEND bit as it does for other instructions.  However, as EDRUPT
  // is used "for machine checkout only", I can't imagine that I even need
  // it at all ... so I'm willing to dispense with a little cross-checking.
//  { "EDRUPT", OP_BASIC, ParseEDRUPT },
  { "EQUALS", OP_PSEUDO, ParseEQUALS }, 
  { "ERASE", OP_PSEUDO, ParseERASE },
  { "EXTEND", OP_BASIC, NULL, "INDEX", "$5777" },
//  { "FCADR", OP_PSEUDO, ParseFCADR, "", "", 0, 0, 0, 0, 1 },
//  { "GENADR", OP_PSEUDO, ParseGENADR },
//  { "INCR", OP_BASIC, ParseINCR },
  { "INDEX", OP_BASIC, ParseINDEX },
  { "INHINT", OP_BASIC, NULL, "INDEX", "$17" },
//  { "LXCH", OP_BASIC, ParseLXCH },
  { "MASK", OP_BASIC, ParseMASK },
//  { "MEMORY", OP_PSEUDO, NULL, "", "" },
//  { "MM", OP_PSEUDO, ParseDEC }, 
  { "MP", OP_BASIC, ParseMP },
//  { "MSU", OP_BASIC, ParseMSU },
  { "NDX", OP_BASIC, ParseINDEX },
  { "NOOP", OP_BASIC, NULL, "XCH", "A" },
//  { "NV", OP_PSEUDO, ParseVN, "", "", 0, 0, 0, 0, 1 },
  { "OCT", OP_PSEUDO, ParseOCT, "", "", 0, 0, 0, 0, 1 },
  { "OCTAL", OP_PSEUDO, ParseOCT, "", "", 0, 0, 0, 0, 1 },
  { "OVIND", OP_BASIC, ParseTS },
  { "OVSK", OP_BASIC, NULL, "TS", "A" },
//  { "QXCH", OP_BASIC, ParseQXCH },
//  { "RAND", OP_BASIC, ParseRAND },
//  { "READ", OP_BASIC, ParseREAD },
  { "RELINT", OP_BASIC, NULL, "INDEX", "$16" },
//  { "REMADR", OP_PSEUDO, ParseGENADR },
  { "RESUME", OP_BASIC, NULL, "INDEX", "$25" },
  { "RETURN", OP_BASIC, NULL, "TC", "Q" },
//  { "ROR", OP_BASIC, ParseROR },
//  { "RXOR", OP_BASIC, ParseRXOR },
//  { "SBANK=", OP_PSEUDO, ParseSBANKEquals },
  { "SETLOC", OP_PSEUDO, ParseSETLOC },
  { "SQUARE", OP_BASIC, NULL, "MP", "A" },
//  { "STCALL", OP_INTERPRETER, ParseSTCALL },
//  { "STODL", OP_INTERPRETER, ParseSTODL },
//  { "STODL*", OP_INTERPRETER, ParseSTODL, "", "", 04000 },
  { "STORE", OP_INTERPRETER, ParseSTORE },
//  { "STOVL", OP_INTERPRETER, ParseSTOVL },
//  { "STOVL*", OP_INTERPRETER, ParseSTOVL, "", "", 04000 },
  { "SU", OP_BASIC, ParseSU },
//  { "SUBRO", OP_PSEUDO, NULL, "" "" },
  { "TC", OP_BASIC, ParseTC },
  { "TCR", OP_BASIC, ParseTC },
  { "TCAA", OP_BASIC, NULL, "TS", "Z" },
//  { "TCF", OP_BASIC, ParseTCF },
  { "TS", OP_BASIC, ParseTS },
//  { "VN", OP_PSEUDO, ParseVN, "", "", 0, 0, 0, 0, 1 },
//  { "WAND", OP_BASIC, ParseWAND },
//  { "WOR", OP_BASIC, ParseWOR },
//  { "WRITE", OP_BASIC, ParseWRITE },
  { "XAQ", OP_BASIC, NULL, "TC", "A" },
  { "XCADR", OP_PSEUDO, ParseXCADR, "", "", 0, 0, 0, 0, 1 }, 
  { "XCH", OP_BASIC, ParseXCH },
//  { "XLQ", OP_BASIC, NULL, "TC", "L" },
//  { "XXALQ", OP_BASIC, NULL, "TC", "A" },
//  { "ZL", OP_BASIC, NULL, "LXCH", "$7" },
//  { "ZQ", OP_BASIC, NULL, "QXCH", "$7" }
};
#define NUM_PARSERS_BLOCK1 (sizeof (ParsersBlock1) / sizeof (ParsersBlock1[0]))

static ParserMatch_t *Parsers = ParsersBlock2;
static int NUM_PARSERS = NUM_PARSERS_BLOCK2;

// This table has been pre-sorted and should be kept that way.
static InterpreterMatch_t InterpreterOpcodesBlock2[] = {
  { "ABS",      0130, 0 },
  { "ABVAL",    0130, 0 },
  { "ARCCOS",   0050, 0 },
  { "ACOS",     0050, 0 },
  { "ARCSIN",   0040, 0 },
  { "ASIN",     0040, 0 },
  { "AXC,1",    0016, 1 },
  { "AXC,2",    0012, 1 },
  { "AXT,1",    0006, 1 },
  { "AXT,2",    0002, 1 },
  { "BDDV",     0111, 1, 0, 000000, { 1, 0 } },
  { "BDDV*",    0113, 1, 0, 000000, { 1, 0 } },
  { "BDSU",     0155, 1, 0, 000000, { 1, 0 } },
  { "BDSU*",    0157, 1, 0, 000000, { 1, 0 } },
  { "BHIZ",     0146, 1 },
  { "BMN",      0136, 1 },
  { "BOFCLR",   0162, 2, 1, 000241 },
  { "BOF",      0162, 2, 1, 000341 },
  { "BOFF",     0162, 2, 1, 000341 },
  { "BOFINV",   0162, 2, 1, 000141 },
  { "BOFSET",   0162, 2, 1, 000041 },
  { "BON",      0162, 2, 1, 000301 },
  { "BONCLR",   0162, 2, 1, 000201 },
  { "BONINV",   0162, 2, 1, 000101 },
  { "BONSET",   0162, 2, 1, 000001 },
  { "BOV",      0176, 1 },
  { "BOVB",     0172, 1 },
  { "BPL",      0132, 1 },
  { "BVSU",     0131, 1, 0, 000000, { 1, 0 } },
  { "BVSU*",    0133, 1, 0, 000000, { 1, 0 } },
  { "BZE",      0122, 1 },
  { "CALL",     0152, 1 },
  { "CALRB",    0152, 1 },
  { "CCALL",    0065, 2, 0, 000000, { 1, 0 } },
  { "CCALL*",   0067, 2, 0, 000000, { 1, 0 } },
  { "CGOTO",    0021, 2, 0, 000000, { 1, 0 } },
  { "CGOTO*",   0023, 2, 0, 000000, { 1, 0 } },
  { "CLEAR",    0162, 1, 1, 000261 },
  { "CLR",      0162, 1, 1, 000261 },
  { "CLRGO",    0162, 2, 1, 000221 },
  { "COS",      0030, 0 },
  { "COSINE",   0030, 0 },
  { "DAD",      0161, 1, 0, 000000, { 1, 0 } },
  { "DAD*",     0163, 1, 0, 000000, { 1, 0 } },
  { "DCOMP",    0100, 0 },
  { "DDV",      0105, 1, 0, 000000, { 1, 0 } },
  { "DDV*",     0107, 1, 0, 000000, { 1, 0 } },
  { "DLOAD",    0031, 1, 0, 000000, { 1, 0 } },
  { "DLOAD*",   0033, 1, 0, 000000, { 1, 0 } },
  { "DMP",      0171, 1, 0, 000000, { 1, 0 } },
  { "DMP*",     0173, 1, 0, 000000, { 1, 0 } },
  { "DMPR",     0101, 1, 0, 000000, { 1, 0 } },
  { "DMPR*",    0103, 1, 0, 000000, { 1, 0 } },
  { "DOT",      0135, 1, 0, 000000, { 1, 0 } },
  { "DOT*",     0137, 1, 0, 000000, { 1, 0 } },
  { "DSQ",      0060, 0 },
  { "DSU",      0151, 1, 0, 000000, { 1, 0 } },
  { "DSU*",     0153, 1, 0, 000000, { 1, 0 } },
  { "EXIT",     0000, 0 },
  { "GOTO",     0126, 1 },
  { "INCR,1",   0066, 1 },
  { "INCR,2",   0062, 1 },
  { "INVERT",   0162, 1, 1, 000161 },
  { "INVGO",    0162, 2, 1, 000121 },
  { "ITA",      0156, 1 },
  { "LXA,1",    0026, 1 },
  { "LXA,2",    0022, 1 },
  { "LXC,1",    0036, 1 },
  { "LXC,2",    0032, 1 },
  { "MXV",      0055, 1, 0, 000000, { 1, 0 } },
  { "MXV*",     0057, 1, 0, 000000, { 1, 0 } },
  { "NORM",     0075, 1, 0, 000000, { 1, 0 } },
  { "NORM*",    0077, 1, 0, 000000, { 1, 0 } },
  { "PDDL",     0051, 1, 0, 000000, { 1, 0 } },
  { "PDDL*",    0053, 1, 0, 000000, { 1, 0 } },
  { "PDVL",     0061, 1, 0, 000000, { 1, 0 } },
  { "PDVL*",    0063, 1, 0, 000000, { 1, 0 } },
  { "PUSH",     0170, 0 },
  { "ROUND",    0070, 0 },
  { "RTB",      0142, 1 },
  { "RVQ",      0160, 0 },
  { "SET",      0162, 1, 1, 000061 },
  { "SETGO",    0162, 2, 1, 000021 },
  { "SETPD",    0175, 1, 0, 000000, { 1, 0 } },
  { "SIGN",     0011, 1, 0, 000000, { 1, 0 } },
  { "SIGN*",    0013, 1, 0, 000000, { 1, 0 } },
  { "SIN",      0020, 0 },
  { "SINE",     0020, 0 },
  { "SL",       0115, 1, 2, 020202, { 1, 0 } },
  { "SL*",      0117, 1, 2, 020202, { 1, 0 } },
  { "SLOAD",    0041, 1, 0, 000000, { 1, 0 } },
  { "SLOAD*",   0043, 1, 0, 000000, { 1, 0 } },
  { "SL1",      0024, 0, 0, 000000, { 1, 0 } },
  { "SL1R",     0004, 0, 0, 000000, { 1, 0 } },
  { "SL2",      0064, 0, 0, 000000, { 1, 0 } },
  { "SL2R",     0044, 0, 0, 000000, { 1, 0 } },
  { "SL3",      0124, 0, 0, 000000, { 1, 0 } },
  { "SL3R",     0104, 0, 0, 000000, { 1, 0 } },
  { "SL4",      0164, 0, 0, 000000, { 1, 0 } },
  { "SL4R",     0144, 0, 0, 000000, { 1, 0 } },
  { "SLR",      0115, 1, 2, 021202, { 1, 0 } },
  { "SLR*",     0117, 1, 2, 021202, { 1, 0 } },
  { "SQRT",     0010, 0 },
  { "SR",       0115, 1, 2, 020602, { 1, 0 } },
  { "SR*",      0117, 1, 2, 020602, { 1, 0 } },
  { "SR1",      0034, 0, 0, 000000, { 1, 0 } },
  { "SR1R",     0014, 0, 0, 000000, { 1, 0 } },
  { "SR2",      0074, 0, 0, 000000, { 1, 0 } },
  { "SR2R",     0054, 0, 0, 000000, { 1, 0 } },
  { "SR3",      0134, 0, 0, 000000, { 1, 0 } },
  { "SR3R",     0114, 0, 0, 000000, { 1, 0 } },
  { "SR4",      0174, 0, 0, 000000, { 1, 0 } },
  { "SR4R",     0154, 0, 0, 000000, { 1, 0 } },
  { "SRR",      0115, 1, 2, 021602, { 1, 0 } },
  { "SRR*",     0117, 1, 2, 021602, { 1, 0 } },
  { "SSP",      0045, 2, 0, 000000, { 1, 0 } },
  { "SSP*",     0047, 1, 0, 000000, { 1, 0 } },
  { "STADR",    0150, 0 },
  // Note that STCALL, STODL, STORE, and STOVL are implemented as regular instructions.
  { "STQ",      0156, 1 },
  { "SXA,1",    0046, 1 },
  { "SXA,2",    0042, 1 },
  { "TAD",      0005, 1, 0, 000000, { 1, 0 } },
  { "TAD*",     0007, 1, 0, 000000, { 1, 0 } },
  { "TIX,1",    0076, 1 },
  { "TIX,2",    0072, 1 },
  { "TLOAD",    0025, 1, 0, 000000, { 1, 0 } },
  { "TLOAD*",   0027, 1, 0, 000000, { 1, 0 } },
  { "UNIT",     0120, 0 },
  { "V/SC",     0035, 1, 0, 000000, { 1, 0 } },
  { "V/SC*",    0037, 1, 0, 000000, { 1, 0 } },
  { "VAD",      0121, 1, 0, 000000, { 1, 0 } },
  { "VAD*",     0123, 1, 0, 000000, { 1, 0 } },
  { "VCOMP",    0100, 0 },
  { "VDEF",     0110, 0 },
  { "VLOAD",    0001, 1, 0, 000000, { 1, 0 } },
  { "VLOAD*",   0003, 1, 0, 000000, { 1, 0 } },
  { "VPROJ",    0145, 1, 0, 000000, { 1, 0 } },
  { "VPROJ*",   0147, 1, 0, 000000, { 1, 0 } },
  { "VSL",      0115, 1, 2, 020202, { 1, 0 } },
  { "VSL*",     0117, 1, 2, 020202, { 1, 0 } },
  { "VSL1",     0004, 0, 0, 000000, { 1, 0 } },
  { "VSL2",     0024, 0, 0, 000000, { 1, 0 } },
  { "VSL3",     0044, 0, 0, 000000, { 1, 0 } },
  { "VSL4",     0064, 0, 0, 000000, { 1, 0 } },
  { "VSL5",     0104, 0, 0, 000000, { 1, 0 } },
  { "VSL6",     0124, 0, 0, 000000, { 1, 0 } },
  { "VSL7",     0144, 0, 0, 000000, { 1, 0 } },
  { "VSL8",     0164, 0, 0, 000000, { 1, 0 } },
  { "VSQ",      0140, 0 },
  { "VSR",      0115, 1, 2, 020602, { 1, 0 } },
  { "VSR*",     0117, 1, 2, 020602, { 1, 0 } },
  { "VSR1",     0014, 0, 0, 000000, { 1, 0 } },
  { "VSR2",     0034, 0, 0, 000000, { 1, 0 } },
  { "VSR3",     0054, 0, 0, 000000, { 1, 0 } },
  { "VSR4",     0074, 0, 0, 000000, { 1, 0 } },
  { "VSR5",     0114, 0, 0, 000000, { 1, 0 } },
  { "VSR6",     0134, 0, 0, 000000, { 1, 0 } },
  { "VSR7",     0154, 0, 0, 000000, { 1, 0 } },
  { "VSR8",     0174, 0, 0, 000000, { 1, 0 } },
  { "VSU",      0125, 1, 0, 000000, { 1, 0 } },
  { "VSU*",     0127, 1, 0, 000000, { 1, 0 } },
  { "VXM",      0071, 1, 0, 000000, { 1, 0 } },
  { "VXM*",     0073, 1, 0, 000000, { 1, 0 } },
  { "VXSC",     0015, 1, 0, 000000, { 1, 0 } },
  { "VXSC*",    0017, 1, 0, 000000, { 1, 0 } },
  { "VXV",      0141, 1, 0, 000000, { 1, 0 } },
  { "VXV*",     0143, 1, 0, 000000, { 1, 0 } },
  { "XAD,1",    0106, 1 },
  { "XAD,2",    0102, 1 },
  { "XCHX,1",   0056, 1 },
  { "XCHX,2",   0052, 1 },
  { "XSU,1",    0116, 1 },
  { "XSU,2",    0112, 1 }
};
#define NUM_INTERPRETERS_BLOCK2 (sizeof(InterpreterOpcodesBlock2) / sizeof(InterpreterOpcodesBlock2[0]))

static InterpreterMatch_t InterpreterOpcodesBlock1[] = {
  { "ABS",      0130, 0 },
  { "ABVAL",    0130, 0 },
  { "ARCCOS",   0050, 0 },
  { "ACOS",     0050, 0 },
  { "ARCSIN",   0040, 0 },
  { "ASIN",     0040, 0 },
  { "AST,1",    TBD },
  { "AST,2",    TBD },
  { "AXC,1",    0016, 1 },
  { "AXC,2",    0012, 1 },
  { "AXT,1",    0006, 1 },
  { "AXT,2",    0002, 1 },
  { "BDDV",     0111, 1, 0, 000000, { 1, 0 } },
  { "BDDV*",    0113, 1, 0, 000000, { 1, 0 } },
  { "BDSU",     0155, 1, 0, 000000, { 1, 0 } },
  { "BDSU*",    0157, 1, 0, 000000, { 1, 0 } },
  { "BHIZ",     0146, 1 },
  { "BMN",      0136, 1 },
//  { "BOFCLR", 0162, 2, 1, 000241 },
//  { "BOF",    0162, 2, 1, 000341 },
//  { "BOFF",   0162, 2, 1, 000341 },
//  { "BOFINV", 0162, 2, 1, 000141 },
//  { "BOFSET", 0162, 2, 1, 000041 },
//  { "BON",    0162, 2, 1, 000301 },
//  { "BONCLR", 0162, 2, 1, 000201 },
//  { "BONINV", 0162, 2, 1, 000101 },
//  { "BONSET", 0162, 2, 1, 000001 },
  { "BOV",      0176, 1 },
//  { "BOVB",   0172, 1 },
  { "BPL",      0132, 1 },
//  { "BVSU",   0131, 1, 0, 000000, { 1, 0 } },
//  { "BVSU*",  0133, 1, 0, 000000, { 1, 0 } },
  { "BZE",      0122, 1 },
//  { "CALL",   0152, 1 },
//  { "CALRB",  0152, 1 },
//  { "CCALL",  0065, 2, 0, 000000, { 1, 0 } },
//  { "CCALL*", 0067, 2, 0, 000000, { 1, 0 } },
//  { "CGOTO",  0021, 2, 0, 000000, { 1, 0 } },
//  { "CGOTO*", 0023, 2, 0, 000000, { 1, 0 } },
//  { "CLEAR",  0162, 1, 1, 000261 },
//  { "CLR",    0162, 1, 1, 000261 },
//  { "CLRGO",  0162, 2, 1, 000221 },
  { "COMP",     TBD },
  { "COS",      0030, 0 },
  { "COS*",     TBD },
  { "COSINE",   0030, 0 },
  { "DAD",      0161, 1, 0, 000000, { 1, 0 } },
  { "DAD*",     0163, 1, 0, 000000, { 1, 0 } },
//  { "DCOMP",  0100, 0 },
  { "DDV",      0105, 1, 0, 000000, { 1, 0 } },
  { "DDV*",     0107, 1, 0, 000000, { 1, 0 } },
//  { "DLOAD",  0031, 1, 0, 000000, { 1, 0 } },
//  { "DLOAD*", 0033, 1, 0, 000000, { 1, 0 } },
  { "DMOVE",    TBD },
  { "DMOVE*",   TBD },
  { "DMP",      0171, 1, 0, 000000, { 1, 0 } },
  { "DMP*",     0173, 1, 0, 000000, { 1, 0 } },
  { "DMPR",     0101, 1, 0, 000000, { 1, 0 } },
  { "DMPR*",    0103, 1, 0, 000000, { 1, 0 } },
  { "DOT",      0135, 1, 0, 000000, { 1, 0 } },
  { "DOT*",     0137, 1, 0, 000000, { 1, 0 } },
  { "DSQ",      0060, 0 },
  { "DSU",      0151, 1, 0, 000000, { 1, 0 } },
  { "DSU*",     0153, 1, 0, 000000, { 1, 0 } },
  { "EXIT",     0000, 0 },
//  { "GOTO",   0126, 1 },
  { "INCR,1",   0066, 1 },
  { "INCR,2",   0062, 1 },
//  { "INVERT", 0162, 1, 1, 000161 },
//  { "INVGO",  0162, 2, 1, 000121 },
  { "ITA",      0156, 1 },
  { "ITC",      TBD },
  { "ITC*",     TBD },
  { "ITCI",     TBD },
  { "ITCQ",     TBD },
  { "LODON",    TBD },
  { "LXA,1",    0026, 1 },
  { "LXA,2",    0022, 1 },
  { "LXC,1",    0036, 1 },
  { "LXC,2",    0032, 1 },
  { "MXV",      0055, 1, 0, 000000, { 1, 0 } },
//  { "MXV*",   0057, 1, 0, 000000, { 1, 0 } },
  { "NOLOD",    TBD },
//  { "NORM",   0075, 1, 0, 000000, { 1, 0 } },
//  { "NORM*",  0077, 1, 0, 000000, { 1, 0 } },
//  { "PDDL",   0051, 1, 0, 000000, { 1, 0 } },
//  { "PDDL*",  0053, 1, 0, 000000, { 1, 0 } },
//  { "PDVL",   0061, 1, 0, 000000, { 1, 0 } },
//  { "PDVL*",  0063, 1, 0, 000000, { 1, 0 } },
//  { "PUSH",   0170, 0 },
  { "ROUND",    0070, 0 },
  { "RTB",      0142, 1 },
//  { "RVQ",    0160, 0 },
//  { "SET",    0162, 1, 1, 000061 },
//  { "SETGO",  0162, 2, 1, 000021 },
//  { "SETPD",  0175, 1, 0, 000000, { 1, 0 } },
  { "SIGN",     0011, 1, 0, 000000, { 1, 0 } },
  { "SIGN*",    0013, 1, 0, 000000, { 1, 0 } },
  { "SIN",      0020, 0 },
  { "SIN*",     TBD },
  { "SINE",     0020, 0 },
//  { "SL",     0115, 1, 2, 020202, { 1, 0 } },
//  { "SL*",    0117, 1, 2, 020202, { 1, 0 } },
//  { "SLOAD",  0041, 1, 0, 000000, { 1, 0 } },
//  { "SLOAD*", 0043, 1, 0, 000000, { 1, 0 } },
//  { "SL1",    0024, 0, 0, 000000, { 1, 0 } },
//  { "SL1R",   0004, 0, 0, 000000, { 1, 0 } },
//  { "SL2",    0064, 0, 0, 000000, { 1, 0 } },
//  { "SL2R",   0044, 0, 0, 000000, { 1, 0 } },
//  { "SL3",    0124, 0, 0, 000000, { 1, 0 } },
//  { "SL3R",   0104, 0, 0, 000000, { 1, 0 } },
//  { "SL4",    0164, 0, 0, 000000, { 1, 0 } },
//  { "SL4R",   0144, 0, 0, 000000, { 1, 0 } },
//  { "SLR",    0115, 1, 2, 021202, { 1, 0 } },
//  { "SLR*",   0117, 1, 2, 021202, { 1, 0 } },
  { "SMOVE",    TBD },
  { "SMOVE*",   TBD },
//  { "SQRT",   0010, 0 },
//  { "SR",     0115, 1, 2, 020602, { 1, 0 } },
//  { "SR*",    0117, 1, 2, 020602, { 1, 0 } },
//  { "SR1",    0034, 0, 0, 000000, { 1, 0 } },
//  { "SR1R",   0014, 0, 0, 000000, { 1, 0 } },
//  { "SR2",    0074, 0, 0, 000000, { 1, 0 } },
//  { "SR2R",   0054, 0, 0, 000000, { 1, 0 } },
//  { "SR3",    0134, 0, 0, 000000, { 1, 0 } },
//  { "SR3R",   0114, 0, 0, 000000, { 1, 0 } },
//  { "SR4",    0174, 0, 0, 000000, { 1, 0 } },
//  { "SR4R",   0154, 0, 0, 000000, { 1, 0 } },
//  { "SRR",    0115, 1, 2, 021602, { 1, 0 } },
//  { "SRR*",   0117, 1, 2, 021602, { 1, 0 } },
//  { "SSP",    0045, 2, 0, 000000, { 1, 0 } },
//  { "SSP*",   0047, 1, 0, 000000, { 1, 0 } },
//  { "STADR",  0150, 0 },
  // Note that STCALL, STODL, STORE, and STOVL are implemented as regular instructions.
//  { "STQ",    0156, 1 },
  { "STZ",      TBD },
  { "SWITCH",   TBD },
  { "SXA,1",    0046, 1 },
  { "SXA,2",    0042, 1 },
  { "TAD",      0005, 1, 0, 000000, { 1, 0 } },
  { "TAD*",     0007, 1, 0, 000000, { 1, 0 } },
  { "TEST",     TBD },
  { "TIX,1",    0076, 1 },
  { "TIX,2",    0072, 1 },
//  { "TLOAD",  0025, 1, 0, 000000, { 1, 0 } },
//  { "TLOAD*", 0027, 1, 0, 000000, { 1, 0 } },
  { "TP",       TBD },
  { "TSLC",     TBD },
  { "TSLT",     TBD },
  { "TSLT*",    TBD },
  { "TSRT",     TBD },
  { "TSRT*",    TBD },
  { "TSU",      TBD },
  { "UNIT",     0120, 0 },
//  { "V/SC",   0035, 1, 0, 000000, { 1, 0 } },
//  { "V/SC*",  0037, 1, 0, 000000, { 1, 0 } },
  { "VAD",      0121, 1, 0, 000000, { 1, 0 } },
  { "VAD*",     0123, 1, 0, 000000, { 1, 0 } },
//  { "VCOMP",  0100, 0 },
  { "VDEF",     0110, 0 },
//  { "VLOAD",  0001, 1, 0, 000000, { 1, 0 } },
//  { "VLOAD*", 0003, 1, 0, 000000, { 1, 0 } },
  { "VMOVE",    TBD },
  { "VMOVE*",   TBD },
  { "VPROJ",    0145, 1, 0, 000000, { 1, 0 } },
  { "VPROJ*",   0147, 1, 0, 000000, { 1, 0 } },
//  { "VSL",    0115, 1, 2, 020202, { 1, 0 } },
//  { "VSL*",   0117, 1, 2, 020202, { 1, 0 } },
//  { "VSL1",   0004, 0, 0, 000000, { 1, 0 } },
//  { "VSL2",   0024, 0, 0, 000000, { 1, 0 } },
//  { "VSL3",   0044, 0, 0, 000000, { 1, 0 } },
//  { "VSL4",   0064, 0, 0, 000000, { 1, 0 } },
//  { "VSL5",   0104, 0, 0, 000000, { 1, 0 } },
//  { "VSL6",   0124, 0, 0, 000000, { 1, 0 } },
//  { "VSL7",   0144, 0, 0, 000000, { 1, 0 } },
//  { "VSL8",   0164, 0, 0, 000000, { 1, 0 } },
  { "VSLT",     TBD },
  { "VSLT*",    TBD },
  { "VSQ",      0140, 0 },
//  { "VSR",    0115, 1, 2, 020602, { 1, 0 } },
//  { "VSR*",   0117, 1, 2, 020602, { 1, 0 } },
//  { "VSR1",   0014, 0, 0, 000000, { 1, 0 } },
//  { "VSR2",   0034, 0, 0, 000000, { 1, 0 } },
//  { "VSR3",   0054, 0, 0, 000000, { 1, 0 } },
//  { "VSR4",   0074, 0, 0, 000000, { 1, 0 } },
//  { "VSR5",   0114, 0, 0, 000000, { 1, 0 } },
//  { "VSR6",   0134, 0, 0, 000000, { 1, 0 } },
//  { "VSR7",   0154, 0, 0, 000000, { 1, 0 } },
//  { "VSR8",   0174, 0, 0, 000000, { 1, 0 } },
  { "VSRT",     TBD },
  { "VSRT*",    TBD },
  { "VSU",      0125, 1, 0, 000000, { 1, 0 } },
  { "VSU*",     0127, 1, 0, 000000, { 1, 0 } },
  { "VXM",      0071, 1, 0, 000000, { 1, 0 } },
  { "VXM*",     0073, 1, 0, 000000, { 1, 0 } },
  { "VXSC",     0015, 1, 0, 000000, { 1, 0 } },
  { "VXSC*",    0017, 1, 0, 000000, { 1, 0 } },
  { "VXV",      0141, 1, 0, 000000, { 1, 0 } },
  { "VXV*",     0143, 1, 0, 000000, { 1, 0 } },
  { "XAD,1",    0106, 1 },
  { "XAD,2",    0102, 1 },
  { "XCHX,1",   0056, 1 },
  { "XCHX,2",   0052, 1 },
  { "XSU,1",    0116, 1 },
  { "XSU,2",    0112, 1 }
};
#define NUM_INTERPRETERS_BLOCK1 (sizeof (InterpreterOpcodesBlock1) / sizeof (InterpreterOpcodesBlock1[0]))

static InterpreterMatch_t *InterpreterOpcodes = InterpreterOpcodesBlock2;
static int NUM_INTERPRETERS = NUM_INTERPRETERS_BLOCK2;

// Buffer for binary data.
int ObjectCode[044][02000]; 

int NumInterpretiveOperands = 0, RawNumInterpretiveOperands;
int nnnnFields[4];
unsigned char SwitchIncrement[4], SwitchInvert[4];
int OpcodeOffset;
int ArgType = 0;
  
#else // ORIGINAL_PASS_C

extern int Block1;
extern int Html;
extern FILE *HtmlOut;

extern int ObjectCode[044][02000];

extern int NumInterpretiveOperands, RawNumInterpretiveOperands;
extern int nnnnFields[4];
extern unsigned char SwitchIncrement[4], SwitchInvert[4];
extern int OpcodeOffset;
extern int ArgType;
  
#endif // ORIGINAL_PASS_C

#endif // INCLUDED_YAYUL_H

