/*
 Copyright 2010 Ronald S. Burkey <info@sandroid.org>

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

 Filename:     Binsource2Bin.c
 Purpose:      This program assists in creating an executable
 binary from AGC programs like Luminary or Colossus.
 Unlike yaYUL (which processes the assembly language
 to product an executable) or Oct2Bin (which processes
 an octal listing to produce an executable),
 Binsource2Bin processes octal codes from the columns
 in an assembly listing which are parallel to the
 assembly language.  This is helpful for a listing
 like the Colossus 237 assembly listing obtained
 from Fred Martin in which the octal-listing section
 is mission completely, and yet we still need an
 executable obtained separately from yaYUL in order
 to cross-check the data entry of the assembly language.
 Contact:      Ron Burkey <info@sandroid.org>
 Website:      http://www.ibiblio.org/apollo/index.html
 Mods:         2010-12-11 RSB    Began.
               2010-12-19 RSB    Added the synonyms :.& for
                                 the commands c, p, and a.
               2010-12-23 RSB    Now allow comments, prefixed
                                 with #.

 For Binsource2Bin.c, the octal codes are provided in an input file
 created by moving through the assembly-language portion of the
 assembly listing page by page and line by line.  The octal codes
 are 5-digit octal numbers delimited either by commas or newlines
 (whichever seems convenient at the time).  Interspersed with lines
 containing octal codes are lines of one of the following forms:
 pN          (N being a 1-4 digit page number from the assembly listing)
 aNNNN       (NNNN being a 4-digit octal number indicating the
             CPU location counter for the next section of octal codes)
 aNN,NNNN    (Same, but with banked address NN,NNNN instead)
 cNNNN       (The address of the preceding octal code)
 cNN,NNNN    (Same, but with a banked address NN,NNNN instead)
 The following synonyms are also accepted:
   :    in place of     c
   .    in place of     p
   &    in place of     a
 These synonyms can be remembered easily since "colon", "period"
 (or "point"), and "and" (or "ampersand") begin with the same
 letter as the commands they're replacing.  The synonyms are
 very convenient when dictating the octal listing using
 Dragon NaturallySpeaking in "numbers" mode, since with these
 synonyms (and the words "comma" and "newline") *all* of the
 data-entry can be dictated without needing to use the keyboard
 for anything other than corrections.

 The pN, cNNNN, and cNN,NNNN codes would not be necessary *if*
 data entry is perfectly accurate, but are pragmatically necessary
 for debugging data entry because they allow Binsource2Bin to
 determine that the correct number of octal codes have been entered
 for any given address range, and all warning messages to be printed
 that localize such mismatches to the page.  It does not allow any
 determination that the octal codes are *correct*, of course.
 (Without an octal listing appearing in the assembly listing, the
 memory-bank checksums are unknown.  They can be computed by
 Binsource2Bin, but cannot be checked by Binsource2Bin.)  Thus,
 while pN, cNNNN, and cNN,NNNN are optional, Binsource2Bin will
 print warning messages wherever such a message would be useful
 but is not found.  In particular:

 * It is expected that pN lines appear in the order p1, p2, p3, ...
 pLAST throughout the input file, without any missing pages.  (If
 there are no octal codes on a page, its pN should appear anyway.)
 * A cNNNN or cNN,NNNN should appear before every pN (except for
 the first page or if the preceding page that contained no octal codes).
 * A cNNNN or cNN,NNNN should appear before every aNNNN or aNN,NNNN
 (except those immediately preceded by a pN).

 Whitespace (including completely blank lines) is ignored by
 Binsource2Bin, as are commas at the ends of lines.

 The input file is read on stdin, and a file capable of being used
 as input to Oct2Bin is written on stdout.  Error and warning messages
 are written to stderr.  The return value is zero on success, and
 is non-zero if there were any warnings or errors.
 */

#include <stdio.h>
#include <inttypes.h>
#include <string.h>

static char InputLine[16384];

enum
{
  UNASSIGNED = 0x8000, CORRUPTED, OVERWRITTEN
};
#define NUM_BANKS 044
#define WORDS_PER_BANK 02000
#define BANK_OFFSET 02000
static int16_t Rope[NUM_BANKS][WORDS_PER_BANK];

static int
Error(int Line, char *Message)
{
  fprintf(stderr, "%d: %s\n", Line, Message);
  return (1);
}

int
main(void)
{
  int i, j;
  char c;
  int RetVal = 0;
  int Line = 0;
  int InputLength;
  char *s, *ss;
  int CurrentPage = 0;
  int CurrentBank = -1, CurrentOffset = -1;
  char LastLineType = 'c';
  int Count = 0, Page = 2000;
  FILE *fout;

  // Initialize the rope with the special value UNASSIGNED,
  // which can't occur in the 15-bit input.  UNASSIGNED will be
  // automatically converted to 00000 when the rope is saved
  // later, but will be a good internal marker for us that
  // a given word hasn't been assigned a value.
  for (i = 0; i < NUM_BANKS; i++)
    for (j = 0; j < WORDS_PER_BANK; j++)
      Rope[i][j] = UNASSIGNED;

  // Now read the input file.
  while (NULL != fgets(InputLine, sizeof(InputLine), stdin))
    {
      Line++;

      // Eliminate spaces, newlines, comments.
      for (s = ss = InputLine; *s; s++)
        {
          if (*s == '\n' || *s == '\r' || *s == '#')
            break;
          if (*s == ' ')
            continue; // Ignore all spaces.
          *ss++ = *s;
        }

      // Ignore completely empty lines.
      if (ss == InputLine)
        continue;

      // Make sure there's exactly one ',' at the end of the line
      // by appending ',' and then reducing all multiple commas at
      // the end of line to a single comma.
      *ss++ = ',';
      for (; ss >= &InputLine[1] && ss[-1] == ',' && ss[-2] == ','; ss--)
        ;
      InputLength = ss - InputLine;
      *ss = 0;

      // Translate some command synonyms:
      switch (InputLine[0])
      {
      case ':': InputLine[0] = 'c'; break;
      case '.': InputLine[0] = 'p'; break;
      case '&': InputLine[0] = 'a'; break;
      }

      // Now that the input lines have been completely normalized,
      // we can begin parsing them.
      if (InputLine[0] == 'p')
        {
          s = strstr(InputLine, ",");
          if (s == &InputLine[InputLength - 1] && 2 == sscanf(InputLine,
              "p%d%c", &i, &c) && c == ',')
            {
              if (i != CurrentPage + 1)
                RetVal = Error(Line, "Page-number out of sequence.");
              if (LastLineType != 'c' && LastLineType != 'p')
                RetVal = Error(Line, "Missing address-check.");
              CurrentPage = i;
            }
          else
            RetVal = Error(Line, "Ill-formed page line.");
        }
      else if (InputLine[0] == 'c' || InputLine[0] == 'a')
        {
          s = strstr(InputLine, ",");
          if (s[1] != 0)
            s = strstr(s + 1, ",");
          if (s == &InputLine[InputLength - 1] && 3 == sscanf(&InputLine[1],
              "%o,%o%c", &i, &j, &c) && c == ',')
            {
              ProcessAorC: if (i < 0 || i >= NUM_BANKS || j < BANK_OFFSET || j
                  > BANK_OFFSET + WORDS_PER_BANK)
                RetVal = Error(Line, "Address out of range.");
              j -= BANK_OFFSET;
              if (InputLine[0] == 'a')
                {
                  if (LastLineType != 'c' && LastLineType != 'p')
                    RetVal = Error(Line, "Missing address-check.");
                  CurrentBank = i;
                  CurrentOffset = j;
                }
              else // InputLine[0] == 'c'
                {
                  if (CurrentBank != i || CurrentOffset != j + 1)
                    RetVal = Error(Line, "Address-check mismatch.");
                }
            }
          else if (s == &InputLine[InputLength - 1] && 2 == sscanf(
              &InputLine[1], "%o%c", &j, &c) && c == ',')
            {
              if (j >= 04000 && j <= 05777)
                {
                  i = 0;
                  j -= 02000;
                }
              else if (j >= 06000 && j <= 07777)
                {
                  i = 1;
                  j -= 04000;
                }
              else
                i = -1;
              goto ProcessAorC;
            }

          else
            RetVal = Error(Line, "Ill-formed address or check line.");
        }
      else // Must be octal codes.
        {
          if (CurrentBank < 0 || CurrentBank >= NUM_BANKS || CurrentOffset < 0
              || CurrentOffset >= WORDS_PER_BANK)
            RetVal = Error(Line, "Missing address assignment.");
          // Parse each field on the line.  Recall that the line ends with
          // a comma, so we can just search until there are no more commas.
          for (s = InputLine; NULL != (ss = strstr(s, ",")) && ss
              < &InputLine[InputLength]; s = ss + 1)
            {
              if (ss - s != 5)
                {
                  i = CORRUPTED;
                  RetVal = Error(Line, "Non 5-digit octal field.");
                }
              else if (2 != sscanf(s, "%o%c", &i, &c) || c != ',')
                {
                  i = CORRUPTED;
                  RetVal = Error(Line, "Junk characters in octal field.");
                }
              if (Rope[CurrentBank][CurrentOffset] >= 00000
                  && Rope[CurrentBank][CurrentOffset <= 077777])
                {
                  i = OVERWRITTEN;
                  RetVal = Error(Line, "Memory overwrite.");
                }
              if (RetVal == 0)
                Rope[CurrentBank][CurrentOffset] = i;
              CurrentOffset++;
            }
        }
      LastLineType = InputLine[0];
    }

  // Write the output.  This code was swiped and slightly altered from
  // Oct2Bin.
  if (RetVal == 0)
    {
      fout = stdout;
      fprintf(fout, "; Copyright:\tPublic domain\n");
      fprintf(fout, "; Filename:\tXXXX.binsource\n");
      fprintf(fout, "; Purpose:\tXXXX\n");
      fprintf(fout, "; Contact:\tinfo@sandroid.org\n");
      fprintf(fout,
          "; Mods:\t\tXXXX-XX-XX XXX\tAuto-generated by Binsource2Bin.\n");
      fprintf(fout, ";\t\tXXXX-XX-XX XXX\tXXXX\n");
      fprintf(fout, ";\n");
      fprintf(fout, "; Note that the \"page numbers\" shown below are completely fictitious.");
      // The \n missing from the line above is supplied below.

      // Read and write data.
      for (i = 0; i < NUM_BANKS; i++)
        for (j = 0; j < WORDS_PER_BANK; j++)
          {
            int Value;
            Value = Rope[(i < 4) ? (i ^ 2) : i][j];
            if (Value > 077777 || Value < 0)
              Value = 0;
            if (0 == (Count % 8))
              fprintf(fout, "\n");
            if (0 == (Count % 32))
              fprintf(fout, "\n");
            if (0 == (Count % 256))
              {
                char PageString[33], BankString[33];
                if (Page <= 0)
                  PageString[0] = 0;
                else
                  sprintf(PageString, " p. %d,", Page++);
                if (Count < 2048)
                  sprintf(BankString, " %o", 04000 + Count);
                else
                  sprintf(BankString, " %02o,%04o", ((i < 4) ? (i ^ 2) : i),
                      02000 + (Count % 1024));
                fprintf(fout, ";%s%s\n", PageString, BankString);
              }
            if (0 == (Count % 1024))
              fprintf(fout, "BANK=%o\n", ((i < 4) ? (i ^ 2) : i));
            fprintf(fout, "%05o ", Value);
            Count++;
          }
    }

  return (RetVal);
}
