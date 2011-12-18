/*
 * Copyright 2011 Ronald S. Burkey <info@sandroid.org>
 *
 * This file is part of yaAGC.
 *
 * yaAGC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * yaAGC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with yaAGC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Filename:    yaASM.c
 * Purpose:     Cross-assembler for Gemini OBC and (potentially) Apollo LVDC
 *              source code.
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2010-01-30 RSB  Began adapting from yaLEMAP.c.
 *              2011-12-08 RSB  I've completely discarded the previous
 *                              uncompleted work, and have started
 *                              from scratch based on input from
 *                              original OBC developers
 *                              and on the fact that I had clearly
 *                              bit off more than I could chew by
 *                              trying to shoe-horn this into the
 *                              framework of yaLEMAP ... yes, I
 *                              lose some capabilities by doing so,
 *                              but better to have an assembler with
 *                              reduced capabilities than never to
 *                              have one at all if I can't bring it
 *                              to fruition!
 *              2011-12-16 RSB  I think it's fully functional right
 *                              now, with at least the minimal set of
 *                              new features that I think needed to be
 *                              added to the original ... though not
 *                              necessarily completely debugged.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <stdint.h>
#include <time.h>

// The following junk is to insure that if running on Linux or Mac that
// it produces a result that Windows can read.
#ifdef WIN32
#define NL "\n"
#else
#define NL "\r\n"
#endif

typedef struct
{
  int Module;
  int Page;
  // OBC: Note that for instructions, Syllable can be any
  // of 0, 1, 2.  For data, if 0 it implies that normal
  // mode is used and the 26-bit word fills up syllables
  // 0 *and* 1; if 2 it implies half-word mode and 13-bit
  // data is in syllable 2; a value of 1 isn't allowed for
  // for data.
  int Syllable;
  int Word;
  int HalfWordMode;
} Address_t;

// Command-line options.
static int Lvdc = 0; // If 0, then OBC.
static int HalfWordMode = 0; // Can change during assembly.
static Address_t InstructionPointer, StartingInstructionPointer =
  { 0, 0, 2, 0 };
static Address_t DataPointer, StartingDataPointer =
  { 0, 0, 0, 0 };

enum PassType_t
{
  PT_SYMBOLS, PT_CODE
};
static int
Pass(enum PassType_t PassType);

// Line- and field-buffers.  The line-length was originally limited to
// 80 characters by the characteristics of punch-cards.  We extend that
// to 132 characters, but the buffers must additionally have room for
// '\n' and a terminating nul.  Finally, we leave an additional space
// as a trick for detecting that the input line was too long for the
// buffer.
#define LINESIZE 135
typedef char Line_t[LINESIZE];
#define MAX_FIELDS 4
static Line_t InputLine, Comment, Fields[MAX_FIELDS];
static char *FieldStarts[MAX_FIELDS];
static int NumFields;

// Symbol table.
enum SymbolType_t
{
  ST_NONE = 0, ST_CODE, ST_VARIABLE, ST_CONSTANT, ST_HOPC, ST_EQU, ST_SYN
};
typedef struct
{
  enum SymbolType_t Type, RefType;
  Address_t Address;
  int Value;
  char Name[9];
  char RefName[9]; // For EQU or SYN.
  int Line; // Source-code line at which the symbol is defined.
} Symbol_t;
// I could save some memory here by making the symbol list dynamically
// expandable, but what would be the point? The number was chosen
// semi-arbitrarily.
#define MAXSYMBOLS 4096
static Symbol_t Symbols[MAXSYMBOLS];
static int NumSymbols = 0;

// Variables for tracking files and lines.
static char *Input = NULL;
static FILE *fin = NULL;
static int LineTotal = 0, LineInFile = 0;
typedef struct
{
  int LineInFile;
  FILE *fin;
  Line_t Input;
} File_t;
#define MAXFILEDEPTH 16
static File_t Files[MAXFILEDEPTH];
static int CurrentFileDepth = 0;

// Buffer for the binary.  This is initially filled
// with the illegal value 0xFFFF, and we use that later
// to detect uninitialized memory or else memory that
// has been overwritten (at assembly time).
static uint16_t Binary[8][16][3][256];
#define ILLEGAL_VALUE 0xFFFF

// List of opcodes and pseudo-ops.
static const char *Operators[] =
  { "HOP", "DIV", "PRO", "RSU", "ADD", "SUB", "CLA", "AND", "MPY", "TRA",
      "SHF", "TMI", "STO", "SPQ", "CLD", "TNZ", "NOP", "SHR", "SHL", "DEC",
      "OCT", "SYN", "EQU", "HOPC" };
enum OperandType_t
{
  OT_ADDRESS, OT_YX, OT_CYX, OT_NONE, OT_SHR, OT_SHL, OT_NOP
};
enum AddressType_t
{
  AT_DATA, AT_CODE
};
enum Operator_t
{
  OP_START = 0,
  OP_HOP = OP_START,
  OP_DIV,
  OP_PRO,
  OP_RSU,
  OP_ADD,
  OP_SUB,
  OP_CLA,
  OP_AND,
  OP_MPY,
  OP_TRA,
  OP_SHF,
  OP_TMI,
  OP_STO,
  OP_SPQ,
  OP_CLD,
  OP_TNZ,
  OP_OFFICIAL,
  OP_NOP = OP_OFFICIAL,
  OP_SHR,
  OP_SHL,
  OP_OPCODES,
  OP_DEC = OP_OPCODES,
  OP_OCT,
  OP_ALLOCS,
  OP_SYN = OP_ALLOCS,
  OP_EQU,
  OP_HOPC,
  OP_COUNT
};
typedef struct
{
  int NumericalOpCode;
  enum OperandType_t OperandType;
  enum AddressType_t AddressType; // Valid only for OperandType==OT_ADDRESS.
} ParseType_t;
static const ParseType_t ParseTypes[OP_OPCODES] =
  {
    { 00, OT_ADDRESS }, // HOP
        { 01, OT_ADDRESS, AT_DATA }, // DIV
        { 02, OT_CYX }, // PRO
        { 03, OT_ADDRESS, AT_DATA }, // RSU
        { 04, OT_ADDRESS, AT_DATA }, // ADD
        { 05, OT_ADDRESS, AT_DATA }, // SUB
        { 06, OT_ADDRESS, AT_DATA }, // CLA
        { 07, OT_ADDRESS, AT_DATA }, // AND
        { 010, OT_ADDRESS, AT_DATA }, // MPY
        { 011, OT_ADDRESS, AT_CODE }, // TRA
        { 012, OT_YX }, // SHF
        { 013, OT_ADDRESS, AT_CODE }, // TMI
        { 014, OT_ADDRESS, AT_DATA }, //STO
        { 015, OT_NONE }, // SPQ
        { 016, OT_YX }, // CLD
        { 017, OT_ADDRESS, AT_CODE }, // TNZ
        { 011, OT_NOP }, // NOP
        { 012, OT_SHR }, // SHR
        { 013, OT_SHL } };

/////////////////////////////////////////////////////////////////////////
// Various helper functions.

// Write the value of a symbol to binary.
static int
WriteBinary(enum SymbolType_t Type, Address_t *Address, uint16_t Value)
{
  int i, Count = 0, RetVal = 0;
  uint16_t *Destination;

  if (Type == ST_CODE)
    Count = 1;
  else if (Type == ST_VARIABLE || Type == ST_CONSTANT)
    Count = (Address->HalfWordMode ? 1 : 2); // Detect half-word mode.
  for (i = 0; i < Count; i++)
    {
      Destination = &Binary[Address->Module][Address->Page][Address->Syllable
          + i][Address->Word];
      if (*Destination != ILLEGAL_VALUE)
        {
          RetVal++;
          fprintf(stderr, "Trying to overwrite binary at address ");
          if (Lvdc)
            fprintf(stderr, "%02o-", Address->Module);
          fprintf(stderr, "%02o-%o-%03o\n", Address->Page, Address->Syllable,
              Address->Word);
        }
      else
        *Destination = 0x1FFF & (Value >> (13 * i));
    }
  return (RetVal);
}

// Compares two Symbol_t structures on the basis of symbol
// name, for use with qsort() or bsearch().
static int
CompareSymbols(const void *s1, const void *s2)
{
#define Sym1 ((Symbol_t *) s1)
#define Sym2 ((Symbol_t *) s2)
  return (strcmp(Sym1->Name, Sym2->Name));
}

// Compares two Symbol_t structures based on memory address,
// for use with qsort() or bsearch().
static int
CompareAddresses(const void *s1, const void *s2)
{
#define Sym1 ((Symbol_t *) s1)
#define Sym2 ((Symbol_t *) s2)
  int i;
  i = Sym1->Address.Module - Sym2->Address.Module;
  if (i)
    return (i);
  i = Sym1->Address.Page - Sym2->Address.Page;
  if (i)
    return (i);
  i = Sym1->Address.Syllable - Sym2->Address.Syllable;
  if (i)
    return (i);
  i = Sym1->Address.Word - Sym2->Address.Word;
  if (i)
    return (i);
  i = Sym1->RefType - Sym2->RefType;
  if (i)
    return (i);
  return (strcmp(Sym1->Name, Sym2->Name));
}

// This function finds all of the fields in the input line
// (up to a maximum of MAX_FIELDS), and stores them in
// the Fields[] array.  It also stores (in the FieldStarts[])
// array pointers to the starts of the fields within the
// input line.  The practical difference between Fields[]
// and FieldStarts[] is that the fields are nul-terminated
// in the former and continue to the end of the line in the
// latter.
static void
ParseToFields(void)
{
  char *s, *ss, c;
  int i;
  for (i = 0; i < MAX_FIELDS; i++)
    {
      Fields[i][0] = 0;
      FieldStarts[i] = NULL;
    }
  for (i = 0, s = InputLine; i < MAX_FIELDS; i++, s = ss)
    {
      for (; isspace (*s); s++)
        ; // Move past white-space.
      if (!*s) // End of the line?
        break;
      FieldStarts[i] = s;
      for (ss = s; *ss && !isspace (*ss); ss++)
        ; // Move to end of field.
      c = *ss;
      *ss = 0;
      strcpy(Fields[i], s);
      *ss = c;
    }
  NumFields = i;
}

// Add a SYN/EQU/HOPC back-reference to the symbol listing.
static void
PrintRef(Symbol_t *Symbol)
{
  if (Symbol->RefType == ST_NONE)
    return;
  printf(", created via \"");
  if (Symbol->RefType == ST_SYN)
    printf("SYN");
  else if (Symbol->RefType == ST_EQU)
    printf("EQU");
  else if (Symbol->RefType == ST_HOPC)
    printf("HOPC");
  printf(" %s\"", Symbol->RefName);
}

/////////////////////////////////////////////////////////////////////////
// The main program.

int
main(int argc, char *argv[])
{
  int i, j, k, n, RetVal = 1;
  int m, p, s, w;
  uint16_t *u;
  FILE *OutFile;

  // Initialize the binary as completely unused.
  for (i = 0, u = &Binary[0][0][0][0]; i < 8 * 16 * 256 * 3; i++, u++)
    *u = ILLEGAL_VALUE;

  // Parse the command-line options.
  for (i = 1; i < argc; i++)
    {
      if (!strcmp(argv[i], "--help"))
        {
          RetVal = 0;
          Help: ;
          fprintf(stderr, "USAGE:\n");
          fprintf(stderr, "\tyaASM [OPTIONS] --input=Input.obc >Output.lst\n");
          fprintf(stderr, "The binary (if any) is output to yaASM.bin.\n");
          fprintf(stderr, "The available OPTIONS are:\n");
          fprintf(stderr, "--help          Shows this help-menu.\n");
          fprintf(stderr,
              "--lvdc          Assemble for Apollo LVDC. (By default,\n");
          fprintf(stderr, "                assembles for Gemini OBC.\n");
          fprintf(stderr,
              "--hwm           (Gemini OBC only.) Start assembly in\n");
          fprintf(stderr,
              "                \"half-word mode\". (HALF or NORM\n");
          fprintf(stderr,
              "                directives within the source code itself\n");
          fprintf(stderr, "                can change the mode.)\n");
          fprintf(stderr,
              "--code=M-P-S-W  Starting address for instructions.\n");
          fprintf(stderr,
              "                M is the module number in octal (0-17\n");
          fprintf(stderr,
              "                for LVDC but always 0 for OBC). P is\n");
          fprintf(stderr,
              "                the page number in octal (0-17). S is\n");
          fprintf(stderr,
              "                the syllable number (0,1,2 for OBC or\n");
          fprintf(stderr,
              "                0,1 for LVDC). W is the word number in\n");
          fprintf(stderr,
              "                octal (0-377).  CODE directives embedded\n");
          fprintf(stderr,
              "                within the source code can change this.\n");
          fprintf(stderr,
              "--data=M-P-S-W  Starting address for data. The same\n");
          fprintf(stderr,
              "                interpretations apply as for --code, except\n");
          fprintf(stderr,
              "                that for the OBC S=2 is legal only with\n");
          fprintf(stderr,
              "                --hwm and S=0 is legal only without --hwm,\n");
          fprintf(stderr,
              "                while S=1 is never legal.  DATA directives\n");
          fprintf(stderr,
              "                within the source code can change the data\n");
          fprintf(stderr, "                pointer as well.\n");
          goto Done;
        }
      else if (!strncmp(argv[i], "--input=", 8))
        Input = &argv[i][8];
      else if (!strcmp(argv[i], "--lvdc"))
        Lvdc = 1;
      else if (!strcmp(argv[i], "--hwm"))
        HalfWordMode = 1;
      else if (4 == sscanf(argv[i], "--code=%d-%d-%d-%d", &m, &p, &s, &w))
        {
          StartingInstructionPointer.Module = m;
          StartingInstructionPointer.Page = p;
          StartingInstructionPointer.Syllable = s;
          StartingInstructionPointer.Word = w;
          goto ParseAddressForError;
        }
      else if (4 == sscanf(argv[i], "--data=%d-%d-%d-%d", &m, &p, &s, &w))
        {
          StartingDataPointer.Module = m;
          StartingDataPointer.Page = p;
          StartingDataPointer.Syllable = s;
          StartingDataPointer.Word = w;
          ParseAddressForError: ;
          if (m != 0 && !Lvdc)
            {
              fprintf(stderr, "For OBC, module number must be 0.\n");
              goto Help;
            }
          if ((m < 0 || m > 15) && Lvdc)
            {
              fprintf(stderr, "For LVDC, module number must be 0-17 octal.\n");
              goto Help;
            }
          if (p < 0 || p > 15)
            {
              fprintf(stderr, "Page is limited to 0-17 octal\n");
              goto Help;
            }
          if (s < 0 || s > 2 || (s > 1 && Lvdc))
            {
              fprintf(stderr,
                  "Syllable is limited to 0,1,2 for OBC or 0,1 for LVDC.\n");
              goto Help;
            }
          if (w < 0 || w > 255)
            {
              fprintf(stderr, "Word-number is limited to 0-377 octal.\n");
              goto Help;
            }
        }
      else
        {
          fprintf(stderr, "Unrecognized option: %s\n", argv[i]);
          goto Help;
        }
    }
  if (HalfWordMode && Lvdc)
    {
      fprintf(stderr, "Half-word mode is not legal for LVDC.\n");
      goto Help;
    }
  if (HalfWordMode && DataPointer.Syllable != 2)
    {
      fprintf(stderr, "Syllable must be 2 for data in half-word mode.\n");
      goto Help;
    }
  if (!Lvdc && !HalfWordMode && DataPointer.Syllable != 0)
    {
      fprintf(stderr,
          "Syllable must be 0 for data when OBC is not in half-word mode.\n");
      goto Help;
    }
  if (Input == NULL)
    {
      fprintf(stderr, "No input file specified.\n");
      goto Help;
    }
  fin = fopen(Input, "rb");
  if (fin == NULL)
    {
      fprintf(stderr, "Could not open input file %s\n", Input);
      goto Help;
    }

  // First pass on the input.  This pass simply determines the
  // memory locations for all left-hand symbols, variables, and
  // constants.
  if (Pass(PT_SYMBOLS))
    goto Done;

  // Let's check the symbol table for duplicates and sort for
  // faster access later.
  qsort(Symbols, NumSymbols, sizeof(Symbol_t), CompareSymbols);
  for (i = 1, j = 0; i < NumSymbols; i++)
    if (!strcmp(Symbols[i - 1].Name, Symbols[i].Name))
      {
        j++;
        fprintf(
            stderr,
            "The symbol %s had multiple definitions, at line %d and line %d.\n",
            Symbols[i].Name, Symbols[i - 1].Line, Symbols[i].Line);
      }
  if (j)
    goto Done;

  // Resolve all SYNs, EQUs, and HOPCs in the symbol table before proceeding.
  // Because of the way SYN works, we may not be able to resolve all symbols
  // on the first pass, so we keep performing passes until the final pass
  // didn't resolve any new symbols.  In this process, n is the number of symbols
  // resolved on the pass, j is the number of symbols left unresolved in the
  // pass, k counts the passes, and i is for looping through the symbols during
  // the pass.
  for (k = j = n = 1; n != 0 && j != 0; k++)
    {
      n = j = 0;
      for (i = 0; i < NumSymbols; i++)
        {
          enum SymbolType_t Type;
          Symbol_t *RefSymbol, Key;

          Type = Symbols[i].Type;
          if (Type != ST_SYN && Type != ST_EQU && Type != ST_HOPC)
            continue;
          strcpy(Key.Name, Symbols[i].RefName);
          RefSymbol = bsearch(&Key, Symbols, NumSymbols, sizeof(Symbol_t),
              CompareSymbols);
          if (RefSymbol == NULL || RefSymbol->Type == ST_SYN || RefSymbol->Type
              == ST_EQU || RefSymbol->Type == ST_HOPC)
            {
              j++;
              fprintf(
                  stderr,
                  "FYI: On pass %d, symbol %s referenced by symbol %s not resolved.\n",
                  k, Symbols[i].RefName, Symbols[i].Name);
              continue;
            }
          n = 1;
          switch (Type)
            {
          case ST_SYN:
            memcpy(&Symbols[i].Address, &RefSymbol->Address, sizeof(Address_t));
            Symbols[i].RefType = ST_SYN;
            Symbols[i].Type = RefSymbol->Type;
            Symbols[i].Value = RefSymbol->Value;
            break;
          case ST_EQU:
            if (RefSymbol->Type != ST_CONSTANT)
              {
                fprintf(stderr,
                    "EQU for %s->%s inappropriate since %s not a constant.\n",
                    Symbols[i].Name, Key.Name, Key.Name);
                goto Done;
              }
            Symbols[i].Type = ST_CONSTANT;
            Symbols[i].RefType = ST_EQU;
            Symbols[i].Value = RefSymbol->Value;
            if (WriteBinary(ST_CONSTANT, &Symbols[i].Address, Symbols[i].Value))
              {
                fprintf(stderr, "Aborting resolution of \"%s EQU %s\".\n",
                    Symbols[i].Name, Symbols[i].RefName);
                goto Done;
              }
            break;
          case ST_HOPC:
            if (RefSymbol->Type != ST_CODE)
              {
                fprintf(
                    stderr,
                    "EQU for %s->%s inappropriate since %s does not point to code.\n",
                    Symbols[i].Name, Key.Name, Key.Name);
                goto Done;
              }
            else
              {
                int OperandValue;
                Symbols[i].Type = ST_CONSTANT;
                Symbols[i].RefType = ST_HOPC;
                OperandValue = RefSymbol->Address.Word & 0377;
                if (RefSymbol->Address.HalfWordMode)
                  OperandValue |= 0400000;
                OperandValue |= (RefSymbol->Address.Syllable & 3) << 14;
                OperandValue |= (RefSymbol->Address.Page & 0x0F) << 9;
                if (RefSymbol->Address.Page == 0)
                  OperandValue |= 0400;
                Symbols[i].Value = OperandValue;
                if (WriteBinary(ST_CONSTANT, &Symbols[i].Address,
                    Symbols[i].Value))
                  {
                    fprintf(stderr, "Aborting resolution of \"%s HOPC %s\".\n",
                        Symbols[i].Name, Symbols[i].RefName);
                    goto Done;
                  }
              }
            break;
            ;
          default: // Can't actually get here, due to a test made earlier.
            break;
            }
        }
    }
  fprintf(
      stderr,
      "FYI: %d symbol-resolution passes performed, %d symbols remain unresolved.\n",
      k - 1, j);
  if (j)
    goto Done;

  // Final pass on the input.  This pass generates the output
  // binary and listing.
  rewind(fin);
  if (Pass(PT_CODE))
    goto Done;

  // Output the symbol table.
  printf(NL);
  printf("ALPHABETIZED SYMBOL TABLE" NL);
  printf("-------------------------" NL);
  for (i = 0; i < NumSymbols; i++)
    {
      printf("%-8s at address ", Symbols[i].Name);
      if (Lvdc)
        printf("%02o-", Symbols[i].Address.Module);
      printf("%02o-%o-%03o: ", Symbols[i].Address.Page,
          Symbols[i].Address.Syllable, Symbols[i].Address.Word);
      switch (Symbols[i].Type)
        {
      case ST_CODE:
        printf("Left-hand symbol");
        PrintRef(&Symbols[i]);
        break;
      case ST_VARIABLE:
        printf("Uninitialized variable");
        PrintRef(&Symbols[i]);
        break;
      case ST_CONSTANT:
        printf("Constant (%09o)", Symbols[i].Value);
        PrintRef(&Symbols[i]);
        break;
      case ST_SYN:
      case ST_EQU:
      case ST_HOPC:
        printf("Unresolved SYM, EQU, or HOPC (implementation error): %s",
            Symbols[i].RefName);
        break;
      default:
        printf("Unknown type (implementation error)");
        break;
        }
      printf(NL);
    }

  // Resort the symbol table by address and print it.
  qsort(Symbols, NumSymbols, sizeof(Symbol_t), CompareAddresses);
  printf(NL);
  printf("SYMBOL TABLE, BY ADDRESS" NL);
  printf("------------------------" NL);
  for (i = 0; i < NumSymbols; i++)
    {
      if (Lvdc)
        printf("%02o-", Symbols[i].Address.Module);
      printf("%02o-%o-%03o, ", Symbols[i].Address.Page,
          Symbols[i].Address.Syllable, Symbols[i].Address.Word);
      printf("%-8s: ", Symbols[i].Name);
      switch (Symbols[i].Type)
        {
      case ST_CODE:
        printf("Left-hand symbol");
        PrintRef(&Symbols[i]);
        break;
      case ST_VARIABLE:
        printf("Uninitialized variable");
        PrintRef(&Symbols[i]);
        break;
      case ST_CONSTANT:
        printf("Constant (%09o)", Symbols[i].Value);
        PrintRef(&Symbols[i]);
        break;
      case ST_SYN:
      case ST_EQU:
      case ST_HOPC:
        printf("Unresolved SYM, EQU, or HOPC (implementation error): %s",
            Symbols[i].RefName);
        break;
      default:
        printf("Unknown type (implementation error)");
        break;
        }
      printf(NL);
    }

  // Binary listing.
  printf(NL);
  printf("OCTAL LISTING (SYL2-SYL1-SYL0)" NL);
  printf("------------------------------" NL);
  // In this loop, j is a state variable that we use to
  // avoid printing chunks of uninitialized memory.
  j = 0;
  for (m = 0; m < (Lvdc ? 8 : 1); m++)
    for (p = 0; p < 16; p++)
      for (w = 0; w < 256; w++)
        {
          // We'll print 4 words per line.
          if (0 == (w & 3))
            {
              // Is the entire block uninitialized?
              for (s = 0; s < (Lvdc ? 2 : 3); s++)
                for (k = 0; k < 4; k++)
                  if (Binary[m][p][s][w + k] != ILLEGAL_VALUE)
                    {
                      s = 100;
                      k = 100;
                    }
              if (s >= 100)
                j = 0;
              else
                {
                  if (j)
                    {
                      w += 3;
                      continue; // No need to print anything for this block.
                    }
                  j = 1;
                }
              if (Lvdc)
                printf("%02o-", m);
              printf("%02o-N-%03o:", p, w);
              if (j)
                {
                  printf(
                      "  ----------------------------- (uninitialized) ----------------------------" NL);
                  w += 3;
                  continue;
                }
            }
          printf("  ");
          if (Binary[m][p][2][w] == ILLEGAL_VALUE)
            printf("XXXXX");
          else
            printf("%05o", Binary[m][p][2][w]);
          printf("-");
          if (Binary[m][p][1][w] == ILLEGAL_VALUE)
            printf("XXXXX");
          else
            printf("%05o", Binary[m][p][1][w]);
          printf("-");
          if (Binary[m][p][0][w] == ILLEGAL_VALUE)
            printf("XXXXX");
          else
            printf("%05o", Binary[m][p][0][w]);
          if (3 == (w & 3))
            printf(NL);
        }

  // Output the binary for use by the simulator if/when it's created.
  OutFile = fopen("yaASM.bin", "wb");
  if (OutFile == NULL)
    {
      fprintf(stderr, "Error: Cannot create the output file yaASM.bin.\n");
      goto Done;
    }
  else
    {
      if (sizeof(Binary) != fwrite(Binary, 1, sizeof(Binary), OutFile))
        {
          fclose(OutFile);
          fprintf(stderr, "Error: Write-error on output file yaASM.bin.\n");
          goto Done;
        }
      fclose(OutFile);
    }

  RetVal = 0;
  Done: ;
  if (fin != NULL)
    fclose(fin);
  return (RetVal);
}

/////////////////////////////////////////////////////////////////////////
// Perform a single pass on the source code.

static int
Pass(enum PassType_t PassType)
{
  int i, RetVal = 1, OperandIsInteger, OperandValue;
  double fOperandValue;
  enum Operator_t Operator;
  //char c, *s, *ss;
  char *sss;
  Address_t *Address; // A dummy.

  memcpy(&InstructionPointer, &StartingInstructionPointer, sizeof(Address_t));
  memcpy(&DataPointer, &StartingDataPointer, sizeof(Address_t));
  LineTotal = LineInFile = 0;

  if (PassType == PT_CODE)
    {
      time_t t;
      time(&t);
      printf(
          "Listing created by OBC assembler yaASM (build " __DATE__ " " __TIME__ ")" NL);
      printf("Source file %s processed %s" NL, Input, (char *) ctime(&t));
    }

  while (1)
    {
      int Commented = 0, LeftHandSymboled = 0, Operatored = 0, CurrentField = 0;
      enum SymbolType_t SymbolType = ST_NONE;
      char FirstChar;

      InputLine[LINESIZE - 1] = 255;
      if (NULL == fgets(InputLine, sizeof(Line_t), fin)) // Done with this file?

        {
          if (CurrentFileDepth == 0) // Done with ALL files?
            break;
          fclose(fin);
          // Pop parent file and proceed with processing it.
          CurrentFileDepth--;
          fin = Files[CurrentFileDepth].fin;
          Input = Files[CurrentFileDepth].Input;
          LineInFile = Files[CurrentFileDepth].LineInFile;
          continue;
        }

      LineTotal++;
      LineInFile++;
      if (InputLine[LINESIZE - 1] == 0)
        {
          fprintf(stderr, "%s:%d: error: Line too long.\n", Input, LineInFile);
          goto Done;
        }
      FirstChar = InputLine[0];

      sss = strstr(InputLine, "\n"); // Trim off trailing '\n'.
      if (sss != NULL)
        *sss = 0;
      sss = strstr(InputLine, "\r"); // Trim off trailing '\r'.
      if (sss != NULL)
        *sss = 0;

      sss = strstr(InputLine, "#"); // Pick off obvious comments;
      if (sss != NULL)
        {
          strcpy(Comment, sss + 1);
          *sss = 0;
          Commented = 1;
        }

      // Parse all of the fields in the input line.
      ParseToFields();

      // Pick off the first field in the line.
      if (NumFields == 0) // Blank line?

        {
          if (PassType == PT_CODE)
            {
              if (Commented)
                {
                  if (Lvdc)
                    printf("   ");
                  if (FirstChar == '#')
                    printf("                   \t#%s", Comment);
                  else
                    printf(
                        "                   \t                               \t#%s",
                        Comment);
                }
              printf(NL);
            }
          continue;
        }
      CurrentField = 0;

      // Is this a file-include directive?
      if (Fields[CurrentField][0] == '$')
        {
          if (strlen(Fields[CurrentField]) == 1)
            {
              fprintf(stderr, "%s:%d: error: No include-file specified.\n",
                  Input, LineInFile);
              goto Done;
            }
          // Push current file and open the include-file instead.
          if (CurrentFileDepth >= MAXFILEDEPTH)
            {
              fprintf(stderr, "%s:%d: error: Too many nested include-files.\n",
                  Input, LineInFile);
              goto Done;
            }
          Files[CurrentFileDepth].LineInFile = LineInFile;
          Files[CurrentFileDepth].fin = fin;
          strcpy(Files[CurrentFileDepth].Input, Input);
          CurrentFileDepth++;
          Input = &Fields[CurrentField][1];
          // Check what's left of the line.
          CurrentField++;
          if (CurrentField < NumFields)
            {
              if (Commented)
                fprintf(
                    stderr,
                    "%s:%d: warning: Garbage between include-directive and comment: %s\n",
                    Input, LineInFile, FieldStarts[CurrentField]);
              else
                {
                  strcpy(Comment, FieldStarts[CurrentField]);
                  Commented = 1;
                }
            }
          if (PassType == PT_CODE)
            {
              // ... output to listing ...
            }
          fin = fopen(Input, "rb");
          LineInFile = 0;
          if (fin == NULL)
            {
              fprintf(
                  stderr,
                  "%s:%d: error: Include-file %s not found or too many files open.\n",
                  Input, LineInFile, Input);
              goto Done;
            }
          continue;
        }

      // Is this a pointer change?
      if (!strcmp(Fields[0], "HALF"))
        {
          HalfWordMode = 1;
          InstructionPointer.HalfWordMode = HalfWordMode;
          if (PassType == PT_CODE)
            {
              if (Lvdc)
                printf("   ");
              printf("                   \t         %s" NL, Fields[0]);
            }
          continue;
        }
      if (!strcmp(Fields[0], "NORM"))
        {
          HalfWordMode = 0;
          InstructionPointer.HalfWordMode = HalfWordMode;
          if (PassType == PT_CODE)
            {
              if (Lvdc)
                printf("   ");
              printf("                   \t         %s" NL, Fields[0]);
            }
          continue;
        }
      if (!strcmp(Fields[0], "DATA") || !strcmp(Fields[0], "CODE"))
        {
          int m, p, s, w;
          if (NumFields < 2)
            {
              fprintf(stderr,
                  "%s:%d: error: DATA or CODE require an operand.\n", Input,
                  LineInFile);
              goto Done;
            }
          if (NumFields > 2)
            {
              fprintf(stderr,
                  "%s:%d: error: Garbage following operand for DATA/CODE.\n",
                  Input, LineInFile);
              goto Done;
            }
          if (Lvdc)
            {
              if (4 != sscanf(Fields[1], "%o-%o-%o-%o", &m, &p, &s, &w))
                {
                  fprintf(stderr,
                      "%s:%d: error: Operand for DATA/CODE needs 4 fields.\n",
                      Input, LineInFile);
                  goto Done;
                }
            }
          else
            {
              m = 0;
              if (3 != sscanf(Fields[1], "%o-%o-%o", &p, &s, &w))
                {
                  fprintf(stderr,
                      "%s:%d: error: Operand for DATA/CODE needs 3 fields.\n",
                      Input, LineInFile);
                  goto Done;
                }
            }
          if (m < 0 || m > 7 || p < 0 || p > 15 || s < 0 || s > (Lvdc ? 2 : 3)
              || w < 0 || w > 255)
            {
              if (4 != sscanf(Fields[1], "%o-%o-%o-%o", &m, &p, &s, &w))
                {
                  fprintf(stderr,
                      "%s:%d: error: Operand for DATA/CODE out of range.\n",
                      Input, LineInFile);
                  goto Done;
                }
            }
          if (!strcmp(Fields[0], "CODE"))
            {
              InstructionPointer.Module = m;
              InstructionPointer.Page = p;
              InstructionPointer.Syllable = s;
              InstructionPointer.Word = w;
              InstructionPointer.HalfWordMode = HalfWordMode;
            }
          else
            {
              if (!Lvdc && s == 1)
                {
                  fprintf(stderr,
                      "%s:%d: error: Data syllable for OBC must be 0 or 2.\n",
                      Input, LineInFile);
                  goto Done;
                }
              DataPointer.Module = m;
              DataPointer.Page = p;
              DataPointer.Syllable = s;
              DataPointer.Word = w;
              DataPointer.HalfWordMode = HalfWordMode;
              if (!Lvdc)
                HalfWordMode = s ? 1 : 0;
            }
          if (PassType == PT_CODE)
            {
              if (Lvdc)
                printf("   ");
              printf("                   \t         %s ", Fields[0]);
              if (Lvdc)
                printf("%02o-", m);
              printf("%02o-%o-%03o" NL, p, s, w);
            }
          continue;
        }

      // Does the line begin with a left-hand symbol or with an operator?
      // The difference is that an operator is one of the reserved words.
      for (Operator = OP_START; Operator < OP_COUNT; Operator++)
        if (!strcmp(Fields[CurrentField], Operators[Operator]))
          break;
      if (Operator >= OP_COUNT) // Must be a left-hand symbol.

        {
          LeftHandSymboled = 1;
          if (PassType == PT_SYMBOLS)
            {
              // Could be a duplicate symbol, but I'll do a separate check
              // for that later.  For now, just go ahead and add it to
              // the symbol list.
              if (strlen(Fields[CurrentField]) > 8)
                {
                  fprintf(
                      stderr,
                      "%s:%d: error: Left-hand symbol %s has too many characters.\n",
                      Input, LineInFile, Fields[CurrentField]);
                  goto Done;
                }
              if (NumSymbols >= MAXSYMBOLS)
                {
                  fprintf(stderr,
                      "%s:%d: error: Max symbol-table size exceeded.\n", Input,
                      LineInFile);
                  goto Done;
                }
              Symbols[NumSymbols].Line = LineTotal;
              strcpy(Symbols[NumSymbols].Name, Fields[CurrentField]);
              strcpy(Symbols[NumSymbols].RefName, "");
              Symbols[NumSymbols].RefType = ST_NONE;
              Symbols[NumSymbols].Value = 0xFFFFFFFF; // An invalid value.
              // There are a couple of more fields we have to fill in before
              // incrementing NumSymbols, but we can't do it quite yet without
              // determining the nature of the next input field.
            }
          CurrentField++;
        }

      // At this point, we must be out of fields (in which case this is a
      // variable allocation) or else must be the name of an opcode or pseudo-op.
      // (I arbitrarily disallow comments in variable allocations not having a
      // leading #, since otherwise it might be possible for s[] to be the leading
      // word of a comment.)
      if (CurrentField >= NumFields)
        {
          if (LeftHandSymboled)
            {
              SymbolType = ST_VARIABLE;
            }
        }
      else
        {
          Operatored = 1;
          for (Operator = OP_START; Operator < OP_COUNT; Operator++)
            if (!strcmp(Fields[CurrentField], Operators[Operator]))
              break;
          if (Operator < OP_OPCODES)
            SymbolType = ST_CODE;
          else if (Operator < OP_ALLOCS)
            {
              SymbolType = ST_CONSTANT;
            }
          else if (Operator == OP_SYN)
            {
              SymbolType = ST_SYN;
            }
          else if (Operator == OP_EQU)
            {
              SymbolType = ST_EQU;
            }
          else if (Operator == OP_HOPC)
            {
              SymbolType = ST_HOPC;
            }
          else
            {
              fprintf(stderr, "%s:%d: error: Unrecognized operator %s.\n",
                  Input, LineInFile, Fields[CurrentField]);
              goto Done;
            }
        }

      // Finish making the symbol-table entry, if necessary.
      if (LeftHandSymboled && PassType == PT_SYMBOLS)
        {
          if (SymbolType == ST_CODE)
            memcpy(&Symbols[NumSymbols].Address, &InstructionPointer,
                sizeof(Address_t));
          else
            memcpy(&Symbols[NumSymbols].Address, &DataPointer,
                sizeof(Address_t));
          Symbols[NumSymbols].Type = SymbolType;
          NumSymbols++;
        }

      if (Operatored)
        {
          CurrentField++; // Move on to operand field, if any.
          // Except for NOP and SPQ, every operator has a single operand,
          // so we can check at this point for non-existence (though
          // not correctness) of operands, as well as get any
          // remaining comment.
          if (SymbolType == ST_CODE && (Operator == OP_NOP || Operator
              == OP_SPQ))
            /* CurrentField-- */;
          else
            {
              if (CurrentField >= NumFields)
                {
                  fprintf(stderr, "%s:%d: error: Missing operand for %s.\n",
                      Input, LineInFile, Fields[CurrentField - 1]);
                  goto Done;
                }
            }
          if (CurrentField + 1 < NumFields) // Comment?

            {
              if (Commented)
                {
                  fprintf(stderr, "%s:%d: error: Garbage after operand: %s.\n",
                      Input, LineInFile, FieldStarts[CurrentField + 1]);
                  goto Done;
                }
              strcpy(Comment, FieldStarts[CurrentField + 1]);
              Commented = 1;
            }
        }

      // Perform whatever specific processing is needed for the assembly pass.
      switch (SymbolType)
        {
      case ST_VARIABLE:
        // There's really nothing to do here, regardless of what pass this
        // is, since a variable allocation does nothing more than advance
        // the location pointer.
        if (DataPointer.Word > 255)
          {
            fprintf(stderr,
                "%s:%d: error: Variable allocation past end of page.\n", Input,
                LineInFile);
            goto Done;
          }
        if (PassType == PT_CODE)
          {
            // Write to the listing.
            if (Lvdc)
              printf("%02o-", DataPointer.Module);
            else
              printf("   ");
            printf("%02o-%o-%03o ", DataPointer.Page, DataPointer.Syllable,
                DataPointer.Word);
            printf("          ");
            printf("\t%-8s ", Fields[0]);
            printf("(ALLOCATION)          ");
            if (Commented)
              printf("\t#%s", Comment);
            printf(NL);
          }
        DataPointer.Word++;
        break;
      case ST_SYN:
      case ST_EQU:
      case ST_HOPC:
        if (!LeftHandSymboled)
          {
            fprintf(
                stderr,
                "%s:%d: error: SYN, EQU, or SYN meaningful only with left-hand symbol.\n",
                Input, LineInFile);
            goto Done;
          }
        // The operand is the name of another symbol.  We can't resolve
        // that just yet, since we don't have a complete symbol table
        // to work with.  What we'll do right now is simply to record
        // in the symbol table that the new symbol refers to the old symbol.
        // We'll resolve all these references by processing between the
        // 1st pass (PT_SYMBOLS) and the 2nd pass (PT_CODE) and replace them
        // with actual OP_VARIABLE, OP_CONSTANT, etc.
        if (PassType == PT_SYMBOLS)
          strcpy(Symbols[NumSymbols - 1].RefName, Fields[CurrentField]);
        if (PassType == PT_CODE)
          {
            Symbol_t Key, *OurLeftHandSymbol;
            strcpy(Key.Name, Fields[0]);
            OurLeftHandSymbol = bsearch(&Key, Symbols, NumSymbols,
                sizeof(Symbol_t), CompareSymbols);
            // Print to listing.  The binary was written in between
            // the PT_SYMBOLS and PT_CODE.
            if (Lvdc)
              printf("%02o-", OurLeftHandSymbol->Address.Module);
            else
              printf("   ");
            printf("%02o-%o-%03o ", OurLeftHandSymbol->Address.Page,
                OurLeftHandSymbol->Address.Syllable,
                OurLeftHandSymbol->Address.Word);
            if (OurLeftHandSymbol->Type == ST_CONSTANT)
              {
                if (OurLeftHandSymbol->Address.Syllable == 2)
                  printf("    %05o ", OurLeftHandSymbol->Value);
                else
                  printf("%09o ", OurLeftHandSymbol->Value);
              }
            else
              printf("          ");
            printf("\t%-8s ", Fields[0]);
            printf("%-4s ", Operators[Operator]);
            printf("%-16s ", Fields[CurrentField]);
            if (Commented)
              printf("\t#%s", Comment);
            printf(NL);
          }
        if (Operator == OP_SYN)
          {
            // Don't need to increment address pointer here.
          }
        else if (Operator == OP_EQU || Operator == OP_HOPC)
          {
            DataPointer.Word++;
          }
        break;
      case ST_CONSTANT:
        // In this case, we either have a DEC or OCT pseudo-op.
        if (DataPointer.Word > 255)
          {
            fprintf(stderr,
                "%s:%d: error: Constant allocation past end of page.\n", Input,
                LineInFile);
            goto Done;
          }
        switch (Operator)
          {
        case OP_OCT:
          OperandIsInteger = 1;
          sss = Fields[CurrentField];
          for (; *sss >= '0' && *sss <= '7'; sss++)
            ;
          if (*sss)
            {
              fprintf(stderr, "%s:%d: error: Not an octal number: %s.\n",
                  Input, LineInFile, Fields[CurrentField]);
              goto Done;
            }
          sscanf(Fields[CurrentField], "%o", &OperandValue);
          if (OperandValue >= (2 << 26))
            {
              fprintf(stderr,
                  "%s:%d: error: Octal constant out-of-range: %s.\n", Input,
                  LineInFile, Fields[CurrentField]);
              goto Done;
            }
          break;
        case OP_DEC:
          OperandIsInteger = 1;
          sss = Fields[CurrentField];
          if (*sss == '+' || *sss == '-')
            sss++;
          for (; isdigit (*sss); sss++)
            ;
          if (*sss)
            {
              if (*sss == '.')
                {
                  sss++;
                  OperandIsInteger = 0;
                }
              for (; isdigit (*sss); sss++)
                ;
              if (*sss)
                {
                  fprintf(stderr, "%s:%d: error: Not a decimal number: %s.\n",
                      Input, LineInFile, Fields[CurrentField]);
                  goto Done;
                }
            }
          if (HalfWordMode)
            i = 12;
          else
            i = 25;
          if (OperandIsInteger)
            {
              sscanf(Fields[CurrentField], "%d", &OperandValue);
              if (OperandValue >= (2 << i) || (OperandValue < -(2 << i)))
                {
                  fprintf(
                      stderr,
                      "%s:%d: error: Integer decimal constant out-of-range: %s.\n",
                      Input, LineInFile, Fields[CurrentField]);
                  goto Done;
                }
            }
          else
            {
              sscanf(Fields[CurrentField], "%lf", &fOperandValue);
              // Must scale so that 0.5<=|fOperandValue|<1.0.  Yes, there
              // are probably more-efficient ways to do it.  So what?
              for (; fabs(fOperandValue) >= 1.0; fOperandValue /= 2.0)
                ;
              if (fOperandValue != 0.0)
                for (; fabs(fOperandValue) < 0.5; fOperandValue *= 2.0)
                  ;
              OperandValue = lround(fOperandValue * (1 << i));
            }
          break;
        default: // Shouldn't be able to get here.
          fprintf(stderr,
              "%s:%d: error: Implementation error, unparsed constant.\n",
              Input, LineInFile);
          goto Done;
          }
        // Having gotten to here, OperandValue contains a 2's-complement
        // value.
        OperandValue &= 0x3FFFFFF;
        if (LeftHandSymboled && PassType == PT_SYMBOLS)
          Symbols[NumSymbols - 1].Value = (unsigned) OperandValue;
        if (PassType == PT_CODE)
          {
            // Write to the binary.
            if (WriteBinary(ST_CONSTANT, &DataPointer, OperandValue))
              {
                fprintf(stderr, "%s:%d: error: Aborting.\n", Input, LineInFile);
                goto Done;
              }
            // Write to the listing.
            if (Lvdc)
              printf("%02o-", DataPointer.Module);
            else
              printf("   ");
            printf("%02o-%o-%03o ", DataPointer.Page, DataPointer.Syllable,
                DataPointer.Word);
            if (DataPointer.Syllable == 2)
              printf("    %05o ", OperandValue);
            else
              printf("%09o ", OperandValue);
            if (LeftHandSymboled)
              printf("\t%-8s ", Fields[0]);
            else
              printf("\t         ");
            printf("%-4s ", Operators[Operator]);
            printf("%-16s ", Fields[CurrentField]);
            if (Commented)
              printf("\t#%s", Comment);
            printf(NL);
          }
        DataPointer.Word++;
        break;
      case ST_CODE:
        if (PassType == PT_SYMBOLS)
          {
            InstructionPointer.Word++;
            break;
          }
        // Process the individual code types. The opcode is given by
        // ParseTypes[Operator].NumericalOpCode, but the operand bits
        // need some interpreting.  We'll pack the results into 13 bits
        // of OperandValue.
        if (InstructionPointer.Word > 255)
          {
            fprintf(stderr, "%s:%d: error: Code past end of page.\n", Input,
                LineInFile);
            goto Done;
          }
        switch (ParseTypes[Operator].OperandType)
          {
        case OT_YX:
          // Here we expect two octal digits. Perhaps later I'll add some
          // range-checking on this, since not all values are legal for
          // all opcodes accepting this type of operand.  For now, I'll
          // just sleaze through and accept any values for X and Y.
          if (Fields[CurrentField][0] < '0' || Fields[CurrentField][0] > '7'
              || Fields[CurrentField][1] < '0' || Fields[CurrentField][1] > '7'
              || Fields[CurrentField][2] != 0)
            {
              fprintf(stderr, "%s:%d: error: Not a legal YX operand.\n", Input,
                  LineInFile);
              goto Done;
            }
          sscanf(Fields[CurrentField], "%o", &OperandValue);
          break;
        case OT_CYX:
          {
            int Length, Bad;
            // Here we expect 2 *or* 3 octal digits. Perhaps later I'll add some
            // range-checking on this, since not all values are legal for
            // all opcodes accepting this type of operand.  For now, I'll
            // just sleaze through and accept any values for X and Y.  The
            // third octal digit, if present, has to be '4'.
            Length = strlen(Fields[CurrentField]);
            Bad = 0; // Initially, mark as "not bad", then perform tests.
            if (Length < 2 || Length > 3)
              Bad = 1; // Mark as "bad".
            else if (Fields[CurrentField][0] < '0' || Fields[CurrentField][0]
                > '7' || Fields[CurrentField][1] < '0'
                || Fields[CurrentField][1] > '7')
              Bad = 1;
            else if (Length == 3 && Fields[CurrentField][2] != '4')
              Bad = 1;
            if (Bad)
              {
                fprintf(stderr, "%s:%d: error: Not a legal operand.\n", Input,
                    LineInFile);
                goto Done;
              }
            sscanf(Fields[CurrentField], "%o", &OperandValue);
          }
          break;
        case OT_NONE:
          OperandValue = 0;
          break;
        case OT_SHR:
          if (!strcmp(Fields[CurrentField], "1"))
            OperandValue = 021;
          else if (!strcmp(Fields[CurrentField], "2"))
            OperandValue = 020;
          else
            {
              fprintf(stderr, "%s:%d: error: SHR operand must be 1 or 2.\n",
                  Input, LineInFile);
              goto Done;
            }
          break;
        case OT_SHL:
          if (!strcmp(Fields[CurrentField], "1"))
            OperandValue = 030;
          else if (!strcmp(Fields[CurrentField], "2"))
            OperandValue = 040;
          else
            {
              fprintf(stderr, "%s:%d: error: SHL operand must be 1 or 2.\n",
                  Input, LineInFile);
              goto Done;
            }
          break;
        case OT_NOP:
          OperandValue = InstructionPointer.Word + 1;
          break;
        case OT_ADDRESS:
          // We accept two cases here:  Either the operand is of the form
          // *+LiteralOctalConstant or *-LiteralOctalConstant, or else it
          // is the name of an existing symbol.  The former is actually
          // possible only if the operand is supposed to be code.
          // In the latter case, we must also check if is the
          // right type of address (variable/constant vs. code) for the
          // opcode type, and whether it's in the current sector vs. the
          // residual sector (vs. an unreachable sector).
          if (ParseTypes[Operator].AddressType == AT_DATA)
            Address = &DataPointer;
          else if (ParseTypes[Operator].AddressType == AT_CODE)
            Address = &InstructionPointer;
          else
            {
              fprintf(stderr, "%s:%d: error: Implementation error.\n", Input,
                  LineInFile);
              goto Done;
            }
          if (Fields[CurrentField][0] == '*'
              && ParseTypes[Operator].AddressType == AT_CODE)
            {
              // Could do some checking here for garbage at the end, but
              // am too lazy.
              if (Fields[CurrentField][1] == 0)
                OperandValue = Address->Word;
              else if (Fields[CurrentField][1] == '+' && 1 == sscanf(
                  &Fields[CurrentField][2], "%o", &OperandValue))
                OperandValue = Address->Word + OperandValue;
              else if (Fields[CurrentField][1] == '-' && 1 == sscanf(
                  &Fields[CurrentField][2], "%o", &OperandValue))
                OperandValue = Address->Word - OperandValue;
              else
                {
                  fprintf(stderr,
                      "%s:%d: error: Illegal relative addressing.\n", Input,
                      LineInFile);
                  goto Done;
                }
              if (OperandValue < 0 || OperandValue > 255)
                {
                  fprintf(stderr,
                      "%s:%d: error: Relative addressing past end of page.\n",
                      Input, LineInFile);
                  goto Done;
                }
            }
          else
            {
              Symbol_t *Result, Key;
              // Search for the symbol in the symbol table.
              strcpy(Key.Name, Fields[CurrentField]);
              Result = bsearch(&Key, Symbols, NumSymbols, sizeof(Symbol_t),
                  CompareSymbols);
              if (Result == NULL)
                {
                  fprintf(stderr,
                      "%s:%d: error: Symbol used as operand not found.\n",
                      Input, LineInFile);
                  goto Done;
                }
              if ((ParseTypes[Operator].AddressType == AT_CODE && Result->Type
                  != ST_CODE)
                  || (ParseTypes[Operator].AddressType == AT_DATA
                      && Result->Type != ST_VARIABLE && Result->Type
                      != ST_CONSTANT))
                {
                  fprintf(
                      stderr,
                      "%s:%d: error: Operand symbol is wrong type (code vs. data).\n",
                      Input, LineInFile);
                  goto Done;
                }
              // For LVDC, need to do some module checking here.
              // TBD
              // Need to do some checking on syllable matches.
              if (HalfWordMode)
                {
                  fprintf(stderr, "Half-word mode not implemented yet.\n");
                  goto Done;
                }
              else
                {
                  if (Result->Type == ST_VARIABLE || Result->Type
                      == ST_CONSTANT)
                    {
                      if (Result->Address.Syllable != 0)
                        {
                          fprintf(
                              stderr,
                              "%s:%d: error: Not in half-word mode, cannot access syllable 2 data.\n",
                              Input, LineInFile);
                          goto Done;
                        }
                    }
                  else
                    {
                      if (Result->Address.Syllable != Address->Syllable)
                        {
                          fprintf(
                              stderr,
                              "%s:%d: error: Cannot TRA, TMI, or TNZ to code in different syllable.\n",
                              Input, LineInFile);
                          goto Done;
                        }
                    }
                }
              OperandValue = Result->Address.Word;
              if (Result->Address.Page == 0)
                OperandValue |= 0400; // Set residual sector.

              else if (Result->Address.Page != Address->Page)
                {
                  fprintf(
                      stderr,
                      "%s:%d: error: Operand symbol is in an inaccessible page.\n",
                      Input, LineInFile);
                  goto Done;
                }
            }
          break;
        default:
          fprintf(stderr, "%s:%d: error: Implementation error.\n", Input,
              LineInFile);
          goto Done;
          }
        // Okay, OperandValue should now hold the A1-A9 field, so let's fill in the
        // opcode field.
        OperandValue |= (ParseTypes[Operator].NumericalOpCode << 9);
        if (WriteBinary(ST_CODE, &InstructionPointer, OperandValue))
          {
            fprintf(stderr, "%s:%d: error: Aborting.\n", Input, LineInFile);
            goto Done;
          }
        if (Lvdc)
          printf("%02o-", InstructionPointer.Module);
        else
          printf("   ");
        printf("%02o-%o-%03o ", InstructionPointer.Page,
            InstructionPointer.Syllable, InstructionPointer.Word);
        printf("    %05o ", OperandValue);
        if (LeftHandSymboled)
          printf("\t%-8s ", Fields[0]);
        else
          printf("\t         ");
        printf("%-4s ", Operators[Operator]);
        printf("%-16s ", Fields[CurrentField]);
        if (Commented)
          printf("\t#%s", Comment);
        printf(NL);
        InstructionPointer.Word++;
        break;
      default: // I don't think this can happen.
        fprintf(stderr, "%s:%d: error: Implementation error, unparsed line.\n",
            Input, LineInFile);
        goto Done;
        }
    }

  RetVal = 0;
  Done: ;
  return (RetVal);
}
