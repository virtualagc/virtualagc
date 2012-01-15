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
 * Filename:    yaASM.h
 * Purpose:     Header file containing some stuff in common between
 *              yaASM and yaOBC.
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2011-12-23 RSB  Split off from yaASM.c
 */

#ifndef yaASM_H
#define yaASM_H

#include <stdint.h>

// The following junk is to insure that if running on Linux or Mac that
// it produces a result that Windows can read.
#ifdef WIN32
#define NL "\n"
#else
#define NL "\r\n"
#endif

// Line-buffers.  The line-length was originally limited to
// 80 characters by the characteristics of punch-cards.  We extend that
// to 132 characters, but the buffers must additionally have room for
// '\n' and a terminating nul.  Finally, we leave an additional space
// as a trick for detecting that the input line was too long for the
// buffer.
#define LINESIZE 135
typedef char Line_t[LINESIZE];

typedef struct
{
  int16_t Module;
  int16_t Page;
  // OBC: Note that for instructions, Syllable can be any
  // of 0, 1, 2.  For data, if 0 it implies that normal
  // mode is used and the 26-bit word fills up syllables
  // 0 *and* 1; if 2 it implies half-word mode and 13-bit
  // data is in syllable 2; a value of 1 isn't allowed for
  // for data.
  int16_t Syllable;
  int16_t Word;
  int16_t HalfWordMode;
} Address_t;

// Symbol table.
enum SymbolType_t
{
  ST_NONE = 0,
  ST_CODE,
  ST_VARIABLE,
  ST_CONSTANT,
  ST_HOPC,
  ST_EQU,
  ST_SYN,
  ST_HOPLHS
};
#define MAX_SYMSIZE 8
typedef struct
{
  enum SymbolType_t Type, RefType;
  Address_t Address;
  int Value;
  char Name[MAX_SYMSIZE + 1];
  char RefName[MAX_SYMSIZE + 1]; // For EQU or SYN.
  int Line; // Source-code line at which the symbol is defined.
} Symbol_t;
#define MAXSYMBOLS 4096
typedef Symbol_t SymbolList_t[MAXSYMBOLS];

#define MAX_MODULES 8
#define MAX_SECTORS 16
#define MAX_SYLLABLES 3
#define MAX_WORDS 256
#define MAX_ADDRESSES (MAX_MODULES * MAX_SECTORS * MAX_SYLLABLES * MAX_WORDS)
#define MAX_YX 0100
typedef uint16_t
    BinaryImage_t[MAX_MODULES][MAX_SECTORS][MAX_SYLLABLES][MAX_WORDS];
#define ILLEGAL_VALUE 0xFFFF
#define RESIDUAL_SECTOR 017

#endif // yaASM_H
