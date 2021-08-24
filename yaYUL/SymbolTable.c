/*
 * Copyright 2003,2009-2010,2016,2020-2021 Ronald S. Burkey <info@sandroid.org>
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
 * Filename:    SymbolTable.c
 * Purpose:     Stuff for managing the assembler's symbol table.
 * Mod History: 04/11/03 RSB    Began.
 *              04/17/03 RSB    Removed Namespaces.
 *              07/27/05 JMS    Added support for writing the symbol
 *                              table to a file for symbol debugging
 *                              purposes.
 *              07/28/05 JMS    Added support for writing SymbolLines
 *                              to symbol table file.
 *              08/03/05 JMS    Support for yaLEMAP
 *              03/20/09 RSB    Corrected symbol tables (as written
 *                              to files) to always use little-endian
 *                              representations of integers.  This
 *                              isn't important for someone compiling
 *                              their own AGC code, but is needed for
 *                              moving symbol tables from one CPU type
 *                              to another, such as for distributing
 *                              Virtual AGC binaries to PowerPC vs.
 *                              Intel CPUs. Also, in the on-disk symbol
 *                              table we now pad filenames with 0
 *                              to make automated regression testing of
 *                              the symtabs easier.
 *              06/28/09 RSB    Added HTML output.
 *              06/29/09 RSB    Added a little css to prevent wrapping
 *                              in the HTML output.
 *              06/27/09 RSB    (Later.)  Used more css to get rid of
 *                              the underlining for links, and to change
 *                              the color of a visited link from purple
 *                              to a dimmer bluish color.
 *              06/30/09 RSB    Added HtmlCheck for processing
 *                              "<HTML>...</HTML>" stuff in source files.
 *                              Includes <HTMLn> and <HTML=f>.
 *              07/01/09 RSB    Altered the way the highlighting styles
 *                              (COLOR_XXX) work in order to make them
 *                               more flexible and to shorten up the HTML
 *                              files more.  Added "##" HTML-insert
 *                              syntax, default style, etc.
 *              2010-02-17 JL   Don't try to process Page meta-comments.
 *              2010-02-20 RSB  Somehow, processing of "##\t" got lost.
 *                              Hopefully, I've restored it.  Allow
 *                              Jim's Page stuff from the last change
 *                              only if UnpoundPage is non-zero --- i.e.,
 *                              only if --unpound-page command-line
 *                              switch was used.
 *              2016-08-01 RSB  Various checks for return errors of library
 *                              functions.
 *              2016-08-20 RSB  Added some error messages to the symbol-table
 *                              writer.  It turns out that writing the
 *                              line-data to the symbol table was always
 *                              failing at the first write, due to bad
 *                              interpretation of a return code.  How
 *                              could they have ever worked in the debugger?
 *              2016-08-23 RSB  For Block 1 only, added an indicator to the
 *                              symbol table, as to whether a given symbol
 *                              is invalid (I), constant (C), erasable (E),
 *                              or fixed (F) ... or unknown (?).  This is
 *                              mainly for debugging, since I seem to have
 *                              some invalid symbols, but there's no reason
 *                              to remove it now that it's there.
 *              2016-10-05 RSB  Hyperlinked the entire HTML symbol table ... in other words, all of the
 *                              labels appearing in the symbol table at the end of MAIN.agc.html now
 *                              consists of hyperlinks.  Also, fixed a symbol-table formatting error for
 *                              labels containing '&' (which is an HTML entity and thus has extra escape
 *                              characters in it and thus has a different length than a normal symbol),
 *                              though I'm sure there are other such special characters used that I
 *                              haven't caught yet.  Fixed the formatting of this
 *                              file header, which had gotten all gummed up and
 *                              painful to read.
 *            	2016-10-08 RSB	Added exception to ## (--html) for inHeader.
 *            	2016-10-20 RSB  Added stuff which may or may not be helpful in building
 *            	                with Visual Studio.
 *              2016-11-02 RSB  The symbol table, which formerly displayed the C, I, etc.
 *                              notations only in block 1, now does it for all targets.
 *                              EditSymbolNew() now tracks how many symbol values have
 *                              *changed*" during a pass, for post-analysis by pass().
 *              2020-12-14 RSB  In colorized html of assembly listings, changed the
 *                              formerly-custom color used for visited hyperlinks back to
 *                              the default.  I think the reason I originally customized it
 *                              must have been that I thought the default was too close to
 *                              the color being used for colorized comments. But the custom
 *                              color is far too close to the (black) color of the text in
 *                              ##-style annotations, so it's made it really, really hard
 *                              to visually distinguish visited lines in annotations from
 *                              the plain text. And in retrospect, I don't see any way for
 *                              it to really be confused with a comment.
 *              2021-04-20 RSB  Added --ebcdic.
 *
 * Concerning the concept of a symbol's namespace.  I had originally
 * intended to implement this, and so many functions had a namespace
 * parameter.  I've decided to remove the parameters, but there is
 * still the underlying code for it, in case it might be handy in the
 * future.
 */

#include "yaYUL.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#ifndef MSC_VS
#include <unistd.h>
#else
#include <io.h>
#include <share.h>
#include <direct.h>
#include <sys\stat.h>
#define write(a,b,c) _write((a),(b),(c))
#define getcwd(a,b) _getcwd((a),(b))
#define close(a) _close(a)
#endif

//-------------------------------------------------------------------------
// Some global data.

// On the first pass, the symbols are collected into an unsorted array.  
// At the end of the pass the array is sorted, and duplicates will cause 
// error messages.  The symbol table is initially empty.  Whenever more 
// symbols are defined than the table has room for, its space is enlarged.  
// On the second pass, true values are assigned to the symbols.
Symbol_t *SymbolTable = NULL;
int SymbolTableSize = 0, SymbolTableMax = 0;

// Set these variables to set symbol-table collation.  No more than one
// of them non-zero.  If both zero, then native collation is used.
int forceAscii = 1;  // Kept this way until just about to print symbol table.
int ebcdic = 1;
int honeywell = 0;

// Set this variable non-zero to treat "## Page" as "# Page".
int UnpoundPage = 0;

//-------------------------------------------------------------------------
// Here are functions for converting integers in-place between the CPU native
// representation and little-endian format.  These functions are symmetric,
// in the sense that they convert in either direction.  The functions do
// not check in any way that the data being pointed to is 32-bit.  The 
// case of an Address_t datatype as input is particularly interesting.
// This datatype has 32-bit fields, and they must each be converted by a
// separate call to LittleEndian32.  However, the datatype *begins* with a 
// bunch of packed bitfields, so calling LittleEndian32 on an Address_t will
// attempt to rearrange the packing of those bitfields.  Whether that's 
// correct and perfectly portable thing to do, I'm not sure.

#if __BYTE_ORDER != __LITTLE_ENDIAN

static
void SwapBytes(void *Pointer, int Loc1, int Loc2)
  {
    char c, *s1, *s2;

    s1 = ((char *) Pointer) + Loc1;
    s2 = ((char *) Pointer) + Loc2;
    c = *s1;
    *s1 = *s2;
    *s2 = c;
  }

#endif

#if __BYTE_ORDER == __LITTLE_ENDIAN

void
LittleEndian32(void *Value)
{
}

#elif __BYTE_ORDER == __BIG_ENDIAN

void
LittleEndian32 (void *Value)
  {
    SwapBytes(Value, 0, 3);
    SwapBytes(Value, 1, 2);
  }

#elif __BYTE_ORDER == __PDP_ENDIAN

void
LittleEndian32(void *Value)
  {
    SwapBytes(Value, 0, 2);
    SwapBytes(Value, 1, 3);
  }

#else

#error Sorry, not a supported endian type.

#endif

//-------------------------------------------------------------------------
// Normalize an assembly-language filename by turning ".s" into ".html" if
// possible, but otherwise simply appending ".html".
char *
NormalizeFilename(char *SourceName)
{
  static char HtmlFilename[1025];
  int n;

  strcpy(HtmlFilename, SourceName);
  n = strlen(HtmlFilename);

  if (!strcmp(&HtmlFilename[n - 2], ".s"))
    n -= 2;

  strcpy(&HtmlFilename[n], ".html");

  return (HtmlFilename);
}

//-------------------------------------------------------------------------
// Create an HTML output file.  Return 0 on success, 1 on failure.  
int
HtmlCreate(char *Filename)
{
  char *HtmlFilename;

  HtmlFilename = NormalizeFilename(Filename);
  HtmlOut = fopen(HtmlFilename, "w");
  if (HtmlOut == NULL)
    {
      printf("Cannot create HTML file \"%s\"\n", HtmlFilename);
      return (1);
    }

  // Write the HTML header.
  fprintf(HtmlOut, "%s",
      "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n"
          "<html>\n"
          "<head>\n"
          "<meta content=\"text/html;charset=ISO-8859-1\" http-equiv=\"Content-Type\">\n"
          "<title>Assembly listing generated by yaYUL</title>\n"

          "<style type=\"text/css\">\n"
          "p.nobreak { white-space:nowrap; }\n"
          "a { text-decoration:none; }\n"
          // "a:visited { COLOR: #000850; }\n"
          "</style>\n"

          "<style type=\"text/css\">\n"
          ".op{\n"
          "font-weight: bold;\n"
          "color: #993300;\n"
          "}\n"
          "</style>\n"

          "<style type=\"text/css\">\n"
          ".dn{\n"
          "color: #009900;\n"
          "}\n"
          "</style>\n"

          "<style type=\"text/css\">\n"
          ".fe{\n"
          "color: #FF0000;\n"
          "}\n"
          "</style>\n"

          "<style type=\"text/css\">\n"
          ".in{\n"
          "color: #FF6600;\n"
          "}\n"
          "</style>\n"

          "<style type=\"text/css\">\n"
          ".ps{\n"
          "color: #336600;\n"
          "}\n"
          "</style>\n"

          "<style type=\"text/css\">\n"
          ".sm{\n"
          "color: #0000FF;\n"
          "}\n"
          "</style>\n"

          "<style type=\"text/css\">\n"
          ".wn{\n"
          "color: #FF9900;\n"
          "}\n"
          "</style>\n"

          "<style type=\"text/css\">\n"
          ".co{\n"
          "font-style: italic;\n"
          "color: #993399;\n"
          "}\n"
          "</style>\n"

          "</head>\n"
          "<body>\n"
      HTML_STYLE_START
      "<h1>Source Code</h1>\n");

  return (0);
}

//-------------------------------------------------------------------------
// Close out the HTML file that is open for output.
void
HtmlClose(void)
{
  if (HtmlOut == NULL)
    return;

  fprintf(HtmlOut, "%s", HTML_STYLE_END "</body>\n</html>\n");
  fclose(HtmlOut);
}

//-------------------------------------------------------------------------
// For processing HTML insertion --- i.e., putting HTML-related stuff into
// the source files so that it can be eventually stuck into the HTML-
// formatted assembly listing.  There are two basic variations: the "<HTML>"
// style and the "##" style.  There is also a default style file which can
// be used (at assembly-time).

static int StyleInitialized = 0;
int StyleOnly = 0;
int inReconstructionComment = 0;
int reconstructionComments = 0;

int
HtmlCheck(int WriteOutput, FILE *InputFile, char *s, int sSize,
    char *CurrentFilename, int *CurrentLineAll, int *CurrentLineInFile)
{
  static int StyleBox = 0, StyleBoxWidth = 75, StyleUser = 0;
  static char StyleUserStart[2049] = "", StyleUserEnd[1025] = "";
  int Width, Pos = 0;
  int i, j;
  char c = 0, *ss;
  extern int inHeader;

  //if (WriteOutput)
  //  printf("HTML -> %s", s);

  // Process default style file at startup.
  if (!StyleInitialized)
    {
      FILE *Defaults;

      StyleInitialized = 1;
      Defaults = fopen("Default.style", "r");
      if (Defaults != NULL)
        {
          Line_t s =
            { 0 };
          StyleOnly = 1;

          while (NULL != fgets(s, sizeof(s) - 1, Defaults))
            HtmlCheck(0, Defaults, s, sizeof(s), "", &i, &j);

          StyleOnly = 0;
          fclose(Defaults);
        }
    }

  if (StyleOnly)
    goto ProcessStyle;
  Retry: Pos = 0;
  c = 0;

  // First, take care of directives to include HTML from a 
  // file.  There are two forms:
  // <HTML "filename">
  // or
  // ### FILE="filename"
  if (!strncmp(s, "<HTML \"", 7))
    Pos = 7;
  else if (!strncmp(s, "### FILE=\"", 10))
    Pos = 10;

  if (Pos)
    {
      FILE *Include;

      if (!WriteOutput || !Html || HtmlOut == NULL)
        return (1);

      for (ss = &s[Pos]; *ss && *ss != '\"'; ss++)
        ;

      if (*ss != '\"')
        return (1);

      *ss = 0;
      Include = fopen(&s[Pos], "r");
      *ss = '\"';
      if (Include == NULL)
        return (1);

      fprintf(HtmlOut, "%s", HTML_STYLE_END);
      while (NULL != fgets(s, sSize - 1, Include))
        fprintf(HtmlOut, "%s", s);

      fprintf(HtmlOut, "%s", HTML_STYLE_START);
      fclose(Include);
      return (1);
    }

  // Take care of the addition of destinations for hyperlinks.
  if (!strncmp(s, "### ANCHOR=", 11))
    {
      if (!WriteOutput || !Html || HtmlOut == NULL)
        return (1);

      for (ss = s; *ss && *ss != '\n'; ss++)
        ;

      *ss = 0;
      fprintf(HtmlOut, "<a name=\"%s\">\n", &s[11]);

      return (1);
    }

  // Now take care of style pragmas.  The allowed forms are
  // ### STYLE=NONE
  // or
  // ### STYLE=BOX n%
  // or
  // ### STYLE=START stuff
  // ### STYLE=START+ stuff
  // ### STYLE=END stuff
  // or
  // ### STYLE=USER
  // The latter just re-enables STYLE=START/STYLE=END styles which
  // may have been defined earlier but then disabled temporarily
  // with STYLE=NONE or STYLE=BOX.  STYLE=START/STYLE=START+/STYLE=END 
  // is a user-defined style, in which you can give
  // both the HTML to initiate the style and the HTML to end 
  // the style to allow returning to the default style.  In other
  // words, when a block of comments in "## htmlstuff" format
  // is encountered, the style-start stuff will be output,
  // followed by all of the htmlstuff in the ## comments, followed
  // by the style-end stuff.  STYLE=START gives the starting commands,
  // but since such commands are sometimes gargantuan, they may not
  // fit conveniently on a single line, so what STYLE=START+ does is
  // to *add* stuff to the end of a previous STYLE=START or 
  // STYLE=START+.
  if (!strncmp(s, "### STYLE=", 10))
    {
      if (!WriteOutput || !Html || HtmlOut == NULL)
        return (1);

      ProcessStyle: ss = &s[10];
      if (!strncmp(ss, "NONE", 4))
        {
          StyleBox = 0;
          StyleUser = 0;
        }
      else if (!strncmp(ss, "BOX ", 4) && sscanf(ss + 4, "%d%c", &i, &c) == 2
          && i >= 1 && i <= 100 && c == '%')
        {
          StyleBox = 1;
          StyleBoxWidth = i;
          StyleUser = 0;
        }
      else if (!strncmp(ss, "USER", 4))
        {
          StyleBox = 0;
          StyleUser = 1;
        }
      else if (!strncmp(ss, "START ", 6))
        {
          StyleBox = 0;
          StyleUser = 1;
          strcpy(StyleUserStart, &ss[6]);
        }
      else if (!strncmp(ss, "START+ ", 7))
        {
          strcat(StyleUserStart, &ss[7]);
        }
      else if (!strncmp(ss, "END ", 4))
        {
          StyleBox = 0;
          StyleUser = 1;
          strcpy(StyleUserEnd, &ss[4]);
        }

      return (1);
    }

  // Now take care of HTML embedded with
  // ## stuff
  // JL 2010-02-17 Don't try to process Page meta-comments.
  // RSB 2010-02-20 ... if --unpound-page is used.  Otherwise,
  // process them normally. 
  //if (WriteOutput)
  //  printf("inHeader=%d match=%d UnpoundPage=%d\n", inHeader, strncmp(s + 3, "Page", 4), UnpoundPage);
  if ((!strncmp(s, "## ", 3) || !strncmp(s, "##\t", 3)) && !inHeader
      && (strncmp(s + 3, "Page", 4) != 0 || !UnpoundPage))
    {
      //if (WriteOutput)
      //  printf("HERE\n");
      if (WriteOutput && inReconstructionComment && reconstructionComments)
        printf ("%s", s);
      // Set proper style and output the line.
      if (WriteOutput && Html && HtmlOut != NULL)
        {
          fprintf(HtmlOut, "%s", HTML_STYLE_END);
          if (StyleBox)
            fprintf(HtmlOut, HTML_TABLE_START, StyleBoxWidth);
          else if (StyleUser)
            fprintf(HtmlOut, "%s", StyleUserStart);
          fprintf(HtmlOut, "%s", &s[3]);
        }

      // Loop on the lines of the insert.
      while (1)
        {
          ss = fgets(s, sSize - 1, InputFile);
          if (ss == NULL)
            break;
          (*CurrentLineAll)++;
          (*CurrentLineInFile)++;
          if (strncmp(s, "## ", 3) && strncmp(s, "##\t", 3))
            break;
          if (WriteOutput && inReconstructionComment && reconstructionComments)
            printf ("%s", s);
          if (WriteOutput && Html && HtmlOut != NULL)
            fprintf(HtmlOut, "%s", &s[3]);
        }

      // Restore default style.
      if (WriteOutput && Html && HtmlOut != NULL)
        {
          if (StyleBox)
            fprintf(HtmlOut, "%s", HTML_TABLE_END);
          else if (StyleUser)
            fprintf(HtmlOut, "%s", StyleUserEnd);
          fprintf(HtmlOut, "%s", HTML_STYLE_START);
        }

      if (ss == NULL)
        return (1);

      goto Retry;
    }

  // Now take care of the <HTML> or <HTMLnn> tags.  However,
  // the ## style described above is preferred.
  if (!strncmp(s, "<HTML>", 6)
      || (2 == sscanf(s, "<HTML%d%c", &Width, &c) && Width > 0 && Width <= 99
          && c == '>'))
    {
      // Turn off default HTML styling.
      if (WriteOutput && Html && HtmlOut != NULL)
        {
          fprintf(HtmlOut, "%s", HTML_STYLE_END);
          if (c == '>')
            fprintf(HtmlOut, HTML_TABLE_START, Width);
        }
      // Loop on the lines of the insert.
      while (1)
        {
          ss = fgets(s, sSize - 1, InputFile);
          if (ss == NULL)
            {
              printf("Premature end-of-file.\n");
              fprintf(stderr, "%s:%d: Premature end-of-file.\n",
                  CurrentFilename, *CurrentLineInFile);
              goto Done;
            }

          (*CurrentLineAll)++;
          (*CurrentLineInFile)++;

          if (!strncmp(s, "</HTML>", 7))
            {
              Done:
              // Turn default HTML styling back on and return
              // to normal source processing.
              if (WriteOutput && Html && HtmlOut != NULL)
                {
                  if (c == '>')
                    fprintf(HtmlOut, "%s", HTML_TABLE_END);
                  fprintf(HtmlOut, "%s", HTML_STYLE_START);
                }
              break;
            }

          if (WriteOutput && Html && HtmlOut != NULL)
            fprintf(HtmlOut, "%s", s);
        }
      return (1);
    }
  return (0);
}

//-------------------------------------------------------------------------
// Normalize a variable, constant name, or line label to a form that can be
// used as an html anchor point.  Since we know that all such names are 
// 8 characters or less, we can simply convert the ASCII characters to 
// 2-digit hexadecimal and end up with 16-character labels or less.  For
// example, "ABCD" -> "41424344".
char *
NormalizeAnchor(char *Name)
{
  static char Normalized[17], *EndPoint = &Normalized[sizeof(Normalized) - 1];
  char *s;

  for (s = Normalized, *s = 0; *Name != 0 && s < EndPoint; s += 2, Name++)
    sprintf(s, "%02X", *Name);

  return (Normalized);
}

//-------------------------------------------------------------------------
// Normalize a string by fixing up the '<' and '&' characters, so that they
// can't have bogus html tags in them.  It handles tabs also, but they can
// only be interpreted relative to the beginning of the input string rather
// than to page position.  If the number of print positions is less than
// PadTo, pad with spaces until it is the right length.
char *
NormalizeStringN(char *Input, int PadTo)
{
  static char Output[2000], *EndPoint = &Output[sizeof(Output) - 1 - 6];
  char *s;
  int Pos = 0;

  for (s = Output, *s = 0; *Input != 0 && s < EndPoint; Input++)
    {
      if (*Input == '<')
        {
          strcpy(s, "&lt;");
          s += 4;
          Pos++;
        }
      else if (*Input == '&')
        {
          strcpy(s, "&amp;");
          s += 5;
          Pos++;
        }
      else if (*Input == '\t')
        {
          int i;

          i = ((Pos + 8) & ~7) - Pos;
          Pos += i;
          for (; i > 0; i--)
            {
              strcpy(s, " ");
              s += 1;
            }

        }
      else
        {
          *s++ = *Input;
          Pos++;
        }
    }

  for (; Pos < PadTo; Pos++)
    {
      strcpy(s, " ");
      s += 1;
    }

  *s = 0;

  return (Output);
}

char *
NormalizeString(char *Input)
{
  return (NormalizeStringN(Input, 0));
}

//-------------------------------------------------------------------------
// Delete the symbol table.
void
ClearSymbols(void)
{
  if (SymbolTable != NULL)
    free(SymbolTable);

  SymbolTable = NULL;
  SymbolTableSize = SymbolTableMax = 0;
}

//-------------------------------------------------------------------------
// Add a symbol to the table.  The newly-added symbol always has the value
// ILLEGAL_SYMBOL_VALUE.  Returns 0 on success, or non-zero on fatal
// error.
int
AddSymbol(const char *Name)
{
  char Namespace = 0;

  // A sanity clause.
  if (strlen(Name) > MAX_LABEL_LENGTH)
    {
      printf("Symbol name \"%s\" is too long.\n", Name);
      return (1);
    }

  // If the symbol table is too small, enlarge it.
  if (SymbolTableSize == SymbolTableMax)
    {
      if (SymbolTable == NULL)
        {
          // This default size comes from the fact that I know there are about
          // 7100 symbols in the Luminary131 symbol table. There are far fewer
          // symbols in yaLEMAP, but that is ok since this isn't much memory
          // anyhow.
          SymbolTableMax = 10000;
          SymbolTable = (Symbol_t *) calloc(SymbolTableMax, sizeof(Symbol_t));
        }
      else
        {
          SymbolTableMax += 1000;
          SymbolTable = (Symbol_t *) realloc(SymbolTable,
              SymbolTableMax * sizeof(Symbol_t));
        }
      if (SymbolTable == NULL)
        {
          printf("Out of memory (3).\n");
          return (1);
        }
    }

  // Now add the symbol.
  SymbolTable[SymbolTableSize].Namespace = Namespace;
  SymbolTable[SymbolTableSize].Value.Invalid = 1;
  strcpy(SymbolTable[SymbolTableSize].Name, Name);
  SymbolTableSize++;

  return (0);
}

//-------------------------------------------------------------------------
// JMS: Assign a symbol a new value. Returns 0 on success. This is used for
// backward compatability to avoid changing lots of existing code. Sets the
// new debugging parameters to their default values.
int
EditSymbol(const char *Name, Address_t *Value)
{
  return EditSymbolNew(Name, Value, SYMBOL_REGISTER, "", 0);
}

//-------------------------------------------------------------------------
// Compare two symbol-table entries, for comparison purposes.  Both the
// Namespace and Name fields are used.
static int
CompareSymbolName(const void *Raw1, const void *Raw2)
{
#define Element1 ((Symbol_t *) Raw1)
#define Element2 ((Symbol_t *) Raw2)
  if (Element1->Namespace < Element2->Namespace)
    return (-1);

  if (Element1->Namespace > Element2->Namespace)
    return (1);

  if (ebcdic && !forceAscii)
    return (strcmpEBCDIC(Element1->Name, Element2->Name));
  else if (honeywell && !forceAscii)
    return (strcmpHoneywell(Element1->Name, Element2->Name));
  else
    return (strcmp(Element1->Name, Element2->Name));
#undef Element1
#undef Element2
}

//-------------------------------------------------------------------------
// Sort the symbol table.  Returns the number of duplicated symbols.
int
SortSymbols(void)
{
  int i, j, ErrorCount = 0;

  qsort(SymbolTable, SymbolTableSize, sizeof(Symbol_t), CompareSymbolName);

  // If a symbol is duplicated (in the same namespace), be remove the
  // duplicates.
  for (i = 1; i < SymbolTableSize;)
    {
      if (SymbolTable[i - 1].Namespace == SymbolTable[i].Namespace
          && !strcmp(SymbolTable[i - 1].Name, SymbolTable[i].Name))
        {
          printf("Symbol \"%s\" (%d) is duplicated.\n", SymbolTable[i].Name,
              SymbolTable[i].Namespace);
          ErrorCount++;

          for (j = i; j < SymbolTableSize; j++)
            SymbolTable[j - 1] = SymbolTable[j];

          SymbolTableSize--;
        }
      else
        i++;
    }

  return (ErrorCount);
}

//-------------------------------------------------------------------------
// Locate a string in the symbol table.  
// Returns a pointer to the symbol-table entry, or NULL if not found.. 
Symbol_t *
GetSymbol(const char *Name)
{
  char Namespace = 0;
  Symbol_t Symbol;

  if (strlen(Name) > MAX_LABEL_LENGTH)
    return (NULL);

  Symbol.Namespace = Namespace;
  strcpy(Symbol.Name, Name);

  return ((Symbol_t *) bsearch(&Symbol, SymbolTable, SymbolTableSize,
      sizeof(Symbol_t), CompareSymbolName));
}

//------------------------------------------------------------------------
// Print the symbol table.
int pageSize = 45;  // GAP page is 3 columns of 45 rows each.
void
PrintSymbolsToFile(FILE *fp)
{
  int i;
  char *status = "";
  Symbol_t **columnizedSymbolTable = NULL, *currentSymbol, *dummySymbol;
  int columnizedSymbolTableSize = 0;
  int currentRow = 0, currentColumn = 0, currentPageOffset = 0;
  char initial, lastInitial = 0, thisPageSize;
  Symbol_t separator;
  int symbolNumber = 0, *symbolNumbers = NULL;

  if (honeywell)
    pageSize = 43;
  thisPageSize = pageSize;
  separator.Type = SYMBOL_SEPARATOR;

  // The SymbolTable[] array, if printed out simplistically, would be row
  // by row, with no page breaks.  However, we want it to print column by
  // column, with page breaks, to allow easier comparison to the original
  // printouts.  Also, we want to eliminate the internal symbols added by
  // yaYUL ($3, $4, etc.) that aren't present in the source code itself.
  // Moreover, we want to add separators wherever the initial character of
  // the symbol name changes.
  // Therefore, we start out by making new array of symbols,
  // columnizedSymbolTable[], in which the elements are rearranged
  // appropriately.  However, the elements of columnizedSymbolTable[] point
  // to the entries in SymbolTable[].  I.e, it's an array of Symbol_t *
  // rather than an array of Symbol_t.
  columnizedSymbolTable = calloc(SymbolTableSize + 256, sizeof(Symbol_t *));
  symbolNumbers = calloc(SymbolTableSize + 256, sizeof(int));
  for (i = 0, currentSymbol = SymbolTable; i < SymbolTableSize;
      i++, currentSymbol++)
    {
      int initialCheck = 1, position;
      // Eliminate internal symbols.
      //fprintf(stderr, "%s\n", currentSymbol->Name);
      initial = currentSymbol->Name[0];
      if (initial == '$')
        {
          if (!strcmp(currentSymbol->Name, "$3")
              || !strcmp(currentSymbol->Name, "$4")
              || !strcmp(currentSymbol->Name, "$5")
              || !strcmp(currentSymbol->Name, "$6")
              || !strcmp(currentSymbol->Name, "$7")
              || !strcmp(currentSymbol->Name, "$16")
              || !strcmp(currentSymbol->Name, "$17")
              || !strcmp(currentSymbol->Name, "$25")
              || !strcmp(currentSymbol->Name, "$5777"))
            continue;
        }
      // The code at saveSymbol is executed either once (normally, to store
      // a symbol) or twice (if the initial character of the symbol name
      // changes, to store a separator record before storing the symbol record.
      // At least for YUL, such separators aren't added if they're the very
      // first entry on a page.
      if (initial != lastInitial && lastInitial != 0)
        {
          lastInitial = initial;
          if (honeywell == 0 || currentRow != 0 || currentColumn != 0)
            {
              dummySymbol = &separator;
              saveSymbol: position = currentPageOffset + currentRow * 3
                  + currentColumn;
              columnizedSymbolTable[position] = dummySymbol;
              symbolNumbers[position] = symbolNumber;
              position++;
              if (position > columnizedSymbolTableSize)
                columnizedSymbolTableSize = position;
              currentRow++;
              if (currentRow >= thisPageSize)
                {
                  currentRow = 0;
                  currentColumn++;
                  if (currentColumn >= 3)
                    {
                      currentColumn = 0;
                      currentPageOffset += pageSize * 3;
                      // The following is intended to adjust the
                      // number of rows on the *last* page of the symbol table,
                      // similarly to how GAP does it.  Unfortunately, it
                      // requires counting the number of changes of the
                      // the leading character of the symbol name remaining,
                      // so that we know how many separators remain.
                      if (SymbolTableSize - i < pageSize * 3)
                        {
                          char l = lastInitial;
                          int numChanges = 0, j;
                          for (j = i + 1; j < SymbolTableSize; j++)
                            {
                              if (SymbolTable[j].Name[0] != l)
                                {
                                  numChanges++;
                                  l = SymbolTable[j].Name[0];
                                }
                            }
                          thisPageSize = (SymbolTableSize + numChanges - i + 1)
                              / 3;
                          if (thisPageSize > pageSize)
                            thisPageSize = pageSize;
                        }
                    }
                }
            }
        }
      if (initialCheck)
        {
          initialCheck = 0;
          lastInitial = currentSymbol->Name[0];
          symbolNumber++;
          dummySymbol = currentSymbol;
          goto saveSymbol;
        }
    }
  //fprintf(stderr, "Here A!\n");

  fprintf(fp, "Symbol Table\n------------\n");
  if (Block1)
    {
      fprintf(fp,
          "(Legend:  I=Invalid, C=Constant, E=Erasable, F=Fixed, ?=Error)\n\n");
    }

  if (HtmlOut != NULL)
    {
      fprintf(HtmlOut, "</pre>\n\n<h1>SymbolTable</h1>\n<pre>\n");
      if (Block1)
        {
          fprintf(fp,
              "<i>(Legend:  I=Invalid, C=Constant, E=Erasable, F=Fixed, ?=Error)</i><br><br>\n");
        }
    }

  //fprintf(stderr, "columnizedSymbolTableSize = %d\n",columnizedSymbolTableSize);
  for (i = 0; i < columnizedSymbolTableSize; i++)
    {
      /*
       if (columnizedSymbolTable[i] == NULL)
       fprintf(stderr, "%d: %s %d\n", i, "", 0);
       else
       fprintf(stderr, "%d: %s %d\n", i, columnizedSymbolTable[i]->Name,
       columnizedSymbolTable[i]->Type);
       */

      if (0 != i && 0 == (i % (pageSize * 3)))
        {
          fprintf(fp, "\n");
          if (HtmlOut != NULL)
            fprintf(HtmlOut, "%s", "<br>\n");
        }

      //if (!(i & 3) && i != 0)
      if (i != 0 && (i % 3) == 0)
        {
          fprintf(fp, "\n");
          if (HtmlOut != NULL)
            fprintf(HtmlOut, "\n");
        }

      if (columnizedSymbolTable[i] == NULL
          || columnizedSymbolTable[i]->Type == SYMBOL_EMPTY)
        {
          fprintf(fp, "                                  ");
          if (HtmlOut != NULL)
            fprintf(HtmlOut, "                                  ");
        }
      else if (columnizedSymbolTable[i]->Type == SYMBOL_SEPARATOR)
        {
          fprintf(fp, "  ==============================  ");
          if (HtmlOut != NULL)
            fprintf(HtmlOut, "================================  ");
        }
      else
        {
          if (columnizedSymbolTable[i]->Value.Invalid)
            status = ",I";
          else if (columnizedSymbolTable[i]->Value.Constant)
            status = ",C";
          else if (columnizedSymbolTable[i]->Value.Erasable)
            status = ",E";
          else if (columnizedSymbolTable[i]->Value.Fixed)
            status = ",F";
          else
            status = ",?";
          fprintf(fp, "%6d%s:   %-*s   ", symbolNumbers[i], status,
          MAX_LABEL_LENGTH, columnizedSymbolTable[i]->Name);
          if (HtmlOut)
            {
              char *normalized;
              int width;

              width = MAX_LABEL_LENGTH;
              normalized = NormalizeString(columnizedSymbolTable[i]->Name);
              if (NULL != strstr(normalized, "&amp;"))
                width += 4;

              if (columnizedSymbolTable[i]->FileName[0])
                {
                  fprintf(HtmlOut,
                      "%06d%s:   <a href=\"%s.html#%s\">%-*s</a>   ",
                      symbolNumbers[i], status,
                      columnizedSymbolTable[i]->FileName,
                      NormalizeAnchor(columnizedSymbolTable[i]->Name), width,
                      normalized);
                }
              else
                {
                  fprintf(HtmlOut, "%06d%s:   %-*s   ", symbolNumbers[i],
                      status, width, normalized);
                }
            }

          AddressPrint(&columnizedSymbolTable[i]->Value);
        }

      //if (3 != (i & 3))
      if (2 != (i % 3))
        {
          fprintf(fp, "\t\t");
          if (HtmlOut != NULL)
            fprintf(HtmlOut, "%s", NormalizeString("\t"));
        }

    }
  //fprintf(stderr, "Here B!\n");

  fprintf(fp, "\n");
  if (HtmlOut != NULL)
    fprintf(HtmlOut, "\n");
}

void
PrintSymbols(void)
{
  PrintSymbolsToFile(stdout);
}

//------------------------------------------------------------------------
// Counts the number of unresolved symbols.
int
UnresolvedSymbols(void)
{
  int i, Ret = 0;

  for (i = 0; i < SymbolTableSize; i++)
    if (SymbolTable[i].Value.Invalid)
      Ret++;

  return (Ret);
}

//------------------------------------------------------------------------
// JMS: Begin additions for output of symbol table to a file for symbolic
// debugging purposes.
//------------------------------------------------------------------------

// JMS: 07.28

// These holds entries for every single compiled line in the source and
// its file and line number. This table is needed to print out the source
// line as we step through code. It is also needed for "break <line #>".
SymbolLine_t *LineTable = NULL;
int LineTableSize = 0, LineTableMax = 0, numSymbolsReassigned = 0;

//------------------------------------------------------------------------
// Assign a symbol a new value including is type, and the file name/line
// number from which it came which is used for debugging purposes. Returns
// 0 upon success, 1 upon failure.
int
EditSymbolNew(const char *Name, Address_t *Value, int Type, char *FileName,
    unsigned int LineNumber)
{
  char Namespace = 0;
  Symbol_t *Symbol;

  //if (!strcmp(Name, "VPRED"))
  //  {
  //    fprintf(stderr, "Here!\n");
  //  }

  // Find out where the symbol is located in the symbol table.
  Symbol = GetSymbol(Name);
  if (Symbol == NULL)
    {
      printf("Implementation error: symbol %d,\"%s\" lost between passes.\n",
          Namespace, Name);
      return (1);
    }

  // This can't happen, but still ...
  if (strcmp(Name, Symbol->Name))
    printf("***** Name mismatch:  %s/%s\n", Name, Symbol->Name);

#if 0
  // Check to see if the symbol is in a namespace that allows it to be
  // reassigned.
  printf("Symbol \"%s\" in namespace %d cannot be reassigned.\n",
      Symbol->Name, Symbol->Namespace);
#endif

  // Reassign the value.
  if (memcmp(&Symbol->Value, Value, sizeof(*Value)))
    numSymbolsReassigned++;
  Symbol->Value = *Value;

  // Assign the symbol type, file name, and line number
  Symbol->Type = Type;
  Symbol->LineNumber = LineNumber;
  strcpy(Symbol->FileName, FileName);

  return (0);
}

//------------------------------------------------------------------------
// Writes the symbol table to a file in binary format. See yaYUL.h for
// more information about the format. Takes the name of the symbol file.

#ifndef O_BINARY
// The O_BINARY flag is needed only in Windows.  If it's not defined,
// it's okay to just make it zero, because it means it's not needed.
#define O_BINARY 0
#endif

void
WriteSymbolsToFile(char *fname)
{
  int i, fd, step;
  SymbolFile_t symfile =
    {
      { 0 } };
  Symbol_t symbol;
  SymbolLine_t Line;

  // Open the symbol table file
  step = 1;
#ifdef MSC_VS
  if ((fd = _sopen_s(&fd, fname, _O_BINARY | _O_WRONLY | _O_CREAT |
              _O_TRUNC, _SH_DENYWR, _S_IREAD | _S_IWRITE)) < 0)
  goto error;
#else
  if ((fd = open(fname, O_BINARY | O_WRONLY | O_CREAT | O_TRUNC, 0666)) < 0)
    goto error;
#endif

  // Write the SymbolFile_t header to the symbol file, filling its
  // members first.
  step = 2;
  if (NULL == getcwd(symfile.SourcePath, MAX_PATH_LENGTH))
    goto error;
  symfile.NumberSymbols = SymbolTableSize;
  symfile.NumberLines = LineTableSize; // JMS: 07.28
  LittleEndian32(&symfile.NumberSymbols);
  LittleEndian32(&symfile.NumberLines);
  step = 3;
  if (write(fd, (void *) &symfile, sizeof(SymbolFile_t)) < 0)
    goto error;

  // Loop and write the symbols to a file
  step = 4;
  for (i = 0; i < SymbolTableSize; i++)
    {
      memcpy(&symbol, (void *) &SymbolTable[i], sizeof(Symbol_t));
      LittleEndian32(&symbol);
      LittleEndian32(&symbol.Value.Value);
      LittleEndian32(&symbol.Type);
      LittleEndian32(&symbol.LineNumber);
      if (write(fd, (void *) &symbol, sizeof(Symbol_t)) < 0)
        goto error;
    }

  // JMS: 07.28
  // Loop and write the symbol lines to a file
  step = 5;
  for (i = 0; i < LineTableSize; i++)
    {
      memcpy(&Line, (void *) &LineTable[i], sizeof(SymbolLine_t));
      LittleEndian32(&Line);
      LittleEndian32(&Line.CodeAddress.Value);
      LittleEndian32(&Line.LineNumber);
      if (write(fd, (void *) &Line, sizeof(SymbolLine_t)) < 0)
        goto error;
    }
  if (0)
    {
      char *s;
      error: ;
      s = strerror(errno);
      printf("\nFile error (symbol-table write, step %d): %s.\n", step, s);
    }
  else
    printf("\nSymbol-table file written.\n");
  close(fd);
}

//-------------------------------------------------------------------------
// Delete the line table.
void
ClearLines(void)
{
  if (LineTable != NULL)
    free(LineTable);

  LineTable = NULL;
  LineTableSize = LineTableMax = 0;
}

//-------------------------------------------------------------------------
// Adds a new program line to the table. Takes the Address_t at which this
// is stored in (fixed) memory, and the file name and line number where it
// is found. Takes the number of words the instruction takes up in memory.
// Returns 0 on success, or non-zero on fatal error.
int
AddLine(Address_t *Address, const char *FileName, int LineNumber)
{
  // A sanity clause.
  if (strlen(FileName) > MAX_FILE_LENGTH)
    {
      printf("File name \"%s\" is too long.\n", FileName);
      return (1);
    }

  // If the line table is too small, enlarge it.
  if (LineTableSize == LineTableMax)
    {
      if (LineTable == NULL)
        {
          // This default size comes from the fact that I know there is 32K
          // of fixed memory in the AGC.
          LineTableMax = 32768;
          LineTable = (SymbolLine_t *) calloc(LineTableMax,
              sizeof(SymbolLine_t));
        }
      else
        {
          LineTableMax += 1000;
          LineTable = (SymbolLine_t *) realloc(LineTable,
              LineTableMax * sizeof(SymbolLine_t));
        }
      if (LineTable == NULL)
        {
          printf("Out of memory (3).\n");
          return (1);
        }
    }

  // Now add the line but adjust for the word inside the instruction.
  LineTable[LineTableSize].CodeAddress = *Address;
  strcpy(LineTable[LineTableSize].FileName, FileName);
  LineTable[LineTableSize].LineNumber = LineNumber;
  LineTableSize++;
  return (0);
}

//-------------------------------------------------------------------------
// Compare function for the line table. We must sort the lines in increasing
// order of physical address. This routine is used for the AGC way of
// addressing memory.
static int
CompareLineAGC(const void *Raw1, const void *Raw2)
{
#define Address1 ((SymbolLine_t *) Raw1)->CodeAddress
#define Address2 ((SymbolLine_t *) Raw2)->CodeAddress

  // It is unclear whether we can ever get erasable addresses here, I
  // don't think so, so we'll just pretend there are fixed address
  // only. The ordering is by 'bank' then 'address', so fixed banks
  // 00 and 01 come before the unbanked 02 and 03 addresses.
  int Bank1, Bank2;

  if (Address1.Banked && Address1.FB >= 020 && Address1.Super)
    Bank1 = Address1.FB + 010;
  else if (Address1.Banked)
    Bank1 = Address1.FB;
  else
    Bank1 = Address1.SReg / 02000;

  if (Address2.Banked && Address2.FB >= 020 && Address2.Super)
    Bank2 = Address2.FB + 010;
  else if (Address2.Banked)
    Bank2 = Address2.FB;
  else
    Bank2 = Address2.SReg / 02000;

  if (Bank1 < Bank2)
    return -1;
  else if (Bank1 > Bank2)
    return 1;
  else if (Address1.SReg < Address2.SReg)
    return -1;
  else if (Address1.SReg > Address2.SReg)
    return 1;
  else
    return 0;

#undef Address1
#undef Address2
}

//-------------------------------------------------------------------------
// Compare function for the line table. We must sort the lines in increasing
// order of physical address. This uses the yaLEMAP way of addressing.
static int
CompareLineAGS(const void *Raw1, const void *Raw2)
{
#define Address1 ((SymbolLine_t *) Raw1)->CodeAddress
#define Address2 ((SymbolLine_t *) Raw2)->CodeAddress

  if (Address1.SReg < Address2.SReg)
    return -1;
  else if (Address1.SReg > Address2.SReg)
    return 1;
  else
    return 0;

#undef Address1
#undef Address2
}

//-------------------------------------------------------------------------
// Compare function for the line table. We must sort the lines in increasing
// order of physical address. This uses the yaASM way of addressing.
static int
CompareLineASM(const void *Raw1, const void *Raw2)
{
#define Address1 ((SymbolLine_t *) Raw1)->CodeAddress
#define Address2 ((SymbolLine_t *) Raw2)->CodeAddress

  if (Address1.SReg < Address2.SReg)
    return -1;
  else if (Address1.SReg > Address2.SReg)
    return 1;
  else if (Address1.Syllable < Address2.Syllable)
    return -1;
  else if (Address1.Syllable > Address2.Syllable)
    return 1;
  else
    return 0;

#undef Address1
#undef Address2
}

//-------------------------------------------------------------------------
// Sort the line table.
void
SortLines(int Type)
{
  int i, j;
  int
  (*Compare)(const void *, const void *);

  // Sort the entries based upon the architecture
  if (Type == SORT_YUL)
    Compare = CompareLineAGC;
  else if (Type == SORT_LEMAP)
    Compare = CompareLineAGS;
  else if (Type == SORT_ASM)
    Compare = CompareLineASM;
  else
    {
      printf("Invalid architecture type given.\n");
      return;
    }

  qsort(LineTable, LineTableSize, sizeof(SymbolLine_t), Compare);

  // Remove duplicates from the line table. I think this is a completely
  // normal situation because multiple passes are made throug the code
  // when compiling.
  printf("Removing the duplicated lines... ");
  for (i = 1; i < LineTableSize;)
    {
      if (!Compare((const void *) &LineTable[i - 1].CodeAddress,
          (const void *) &LineTable[i].CodeAddress))
        {
          AddressPrint(&LineTable[i - 1].CodeAddress);

          for (j = i; j < LineTableSize; j++)
            LineTable[j - 1] = LineTable[j];

          LineTableSize--;
        }
      else
        i++;
    }
  printf("\n");
}

//------------------------------------------------------------------------
// JMS: End additions for output of symbol table
//------------------------------------------------------------------------
