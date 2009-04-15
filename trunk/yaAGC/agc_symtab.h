/*
 * agc_symtab.h
 *
 *  Created on: Dec 21, 2008
 *      Author: O. Hommes
 */

#ifndef AGC_SYMTAB_H_
#define AGC_SYMTAB_H_

//--------------------------------------------------------------------------
// JMS: Begin section of code dealing with the symbol table
//--------------------------------------------------------------------------

// The following definitions were copied directly from yaYUL/yaYUL.h. These
// structure definitions are necessary to read in the binary symbol table file.

// The maximum length of the path for source files and the maximum length of
// a source file name. This perhaps should be MAXPATHLEN (in sys/param.h) but
// I wanted to keep things somewhat platform independent. Also, these are my
// best guesses at reasonable lengths
#define MAX_PATH_LENGTH  (1024)        // Maximum directory length of source
#define MAX_FILE_LENGTH  (256)         // Maximum length of sourc file name
#define MAX_LABEL_LENGTH (10)          // Maximum length of label
#define MAX_LINE_LENGTH  (132)         // Maximum length of source line
#define MAX_LIST_LENGTH  (10)          // # of source lines to display

// The maximum number of source files. This is a generous estimate based
// upon that Luminary131 has 88 files and Colossus249 has 85. Assuming
// this constant makes the code a bit simpler
#define MAX_NUM_FILES    (128)

// A datatype used for addresses or symbol values.  It can represent constants,
// or addresses in all their glory. IF THIS STRUCTURE IS CHANGED, THE MACROS
// THAT IMMEDIATELY FOLLOW IT MUST ALSO BE FIXED.
typedef struct {
  // We always want the Invalid bit to come first, for the purpose of easily
  // writing static initializers.
  unsigned Invalid:1;			// If 1, not yet resolved.
  unsigned Constant:1;			// If 1, it's a constant, not an address.
  unsigned Address:1;			// If 1, it really is an address.
  unsigned SReg:12;			// S-register part of the address.
  unsigned Erasable:1;			// If 1, it's in erasable memory.
  unsigned Fixed:1;			// If 1, it's in fixed memory.
  // Note that for some address ranges, the following two are not in
  // conflict.  Erasable banks 0-1 overlap unbanked erasable memory,
  // while fixed banks 2-3 overlap unbanked fixed memory.
  unsigned Unbanked:1;			// If 1, it's in unbanked memory.
  unsigned Banked:1;			// If 1, it's in banked memory.
  // If Banked==0, the following bits are assigned to be zero.
  unsigned EB:3;			// The EB bank bits.
  unsigned FB:5;			// The FB bank bits.
  unsigned Super:1;			// The super-bank bit.
  // Status bit.  If set, the address is actually invalid, since
  // by implication it is in the wrong bank.
  unsigned Overflow:1;			// If 1, last inc. overflowed bank.
  // Last, but not least, the value itself.
  int Value;				// Constant or full pseudo-address.
} Address_t;

#define FIXED() ((const Address_t) { 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 })

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

// The Symbol_t sturcture represents a symbol within the symbol table
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
// are meant to be masks.
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

// These constants define the architecture to use for various routines
#define ARCH_AGC              (30)
#define ARCH_AGS              (31)

//------------------------------------------------------------------------
// Print an Address_t record formatted for the AGC architecture.  Returns
// 0 on success, non-zero on error. This was copied directly from yaYUL/Pass.c
int AddressPrintAGC (Address_t *Address, char *AddressStr);

//------------------------------------------------------------------------
// Print an Address_t record formatted to the AGS architecture.  Returns 0
// on success, non-zero on error. This was copied from yaLEMAP.c
int AddressPrintAGS (Address_t *Address, char *AddressStr);

//-------------------------------------------------------------------------
// Reads in the symbol table. The .symtab file is given as an argument. This
// routine updates the global variables storing the symbol table. Returns
// 0 upon success, 1 upon failure
int ReadSymbolTable (char *fname);

//-------------------------------------------------------------------------
// Returns information about a given symbol if found
void WhatIsSymbol (char *SymbolName, int Arch);

//-------------------------------------------------------------------------
// Clears out symbol table
void ResetSymbolTable (void);

//-------------------------------------------------------------------------
// Dumps the entire symbol table to the screen
void DumpSymbols (const char *Pattern, int Arch);

//-------------------------------------------------------------------------
// Outputs the sources for the given file name and line number to the
// console. The 5 lines before the line given and the 10 lines after the
// line number given is displayed, subject to the file bounds. If the given
// LineNumber is -1, then display the next MAX_LIST_LENGTH line numbers.
void ListSource (char *SourceFile, int LineNumber);

//-------------------------------------------------------------------------
// Displays a listing of source before the last one. This call results from
// a "LIST -" command which it is assumed follows some "LIST" command. We
// just backup 2 * MAX_LIST_LENGTH. It also assumes we want to list in the
// current file, so if there is not, this does nothing
void ListBackupSource (void);

//-------------------------------------------------------------------------
// Displays a listing of source for the current file for the line given
// line numbers. Both given line numbers must be positive and LineNumberTo
// >= LineNumberFrom.
void ListSourceRange (int LineNumberFrom, int LineNumberTo);

//-------------------------------------------------------------------------
// Resolves the given symbol name into a Symbol_t structure. Returns NULL
// if the symbol is not found
Symbol_t *ResolveSymbol (char *SymbolName, int TypeMask);

Symbol_t* ResolveSymbolAGC(int Address12, int FB, int SBB);

Symbol_t* ResolveLastLabel(SymbolLine_t *Line);

SymbolLine_t* ResolveFileLineNumber (char* FileName, int LineNumber);

//-------------------------------------------------------------------------
// Resolves the given program counter into a SymbolFile_t structure for
// the AGC address architecture. Returns NULL if the program line was not
// found.
SymbolLine_t *ResolveLineAGC (int Address12, int FB, int SBB);

//-------------------------------------------------------------------------
// Resolves the given program counter into a SymbolFile_t structure.
// Returns NULL if the program line was not found
SymbolLine_t *ResolveLineAGS (int Address12);

//-------------------------------------------------------------------------
// Displays a single line given the file name and line number. This is
// called when displaying the next line to display while stepping through
// code. It is optimized for such: it looks to see if the file name is the
// same as the request file and if the requested line number is greater
// than the current line number. Returns 0 upon success, 1 upon failure.
int ListSourceLine (char *SourceFile, int LineNumber, char *Contents);

//-------------------------------------------------------------------------
// Resolves a line number by searching the file name and line number.
// This is used for the "break <line>" debugging command. It is a rather
// inefficient implementation as it searches this entire ~32k list of
// program lines each time. However, I felt this wouldn't take too long
// and it saves another ~8MB of RAM for a LineTable which is sorted  by
// <file name, line number>.  The line number is referenced to the currently
// opened file. If there is none, then print an error and return NULL, although
// this should not happen in practice.
SymbolLine_t *ResolveLineNumber (int LineNumber);

//-------------------------------------------------------------------------
// Dumps a list of source files given a regular expression pattern
/*void DumpFiles (const char *Pattern); */

// Load a source line
int LoadSourceLine (char *SourceFile, int LineNumber);

//--------------------------------------------------------------------------
// JMS: End section of code dealing with the symbol table
//--------------------------------------------------------------------------


#endif /* AGC_SYMTAB_H_ */
