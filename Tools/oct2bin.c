/*
 *  Copyright 2003-2006,2009,2016 Ronald S. Burkey <info@sandroid.org>
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
 *  Filename:	oct2bin.c
 *
 *  Purpose:	For the purpose of validating yaYUL, Luminary131, and
 *  		Colossus249 the binary from the Luminary131 and Colussus249
 *		source-code listings is checked against the yaYUL-produced
 *		binary produced from the source-code in those listings.
 *		This checking is most-easily done by the computer, which
 *		implies that the Luminary/Colossus source AND the
 *		Luminary/Colossus binary must separately be entered into
 *		the computer.  (Of course, once the binaries are entered
 *		they can also be used directly with yaAGC, whether or not
 *		yaYUL or the Luminary/Colossus sources are correct.)
 *		But entering binary data directly into the computer is not
 *		very convenient (particularly when it is originally listed
 *		in octal 15-bit format), so an intermediate ASCII format
 *		is used.  Then, a program (namely this one, oct2bin) is used
 *		to convert the intermediate file to binary.
 *
 *  Contact:	Ron Burkey <info@sandroid.org>
 *
 *  Website:	http://www.ibiblio.org/apollo/index.html
 *
 *  Mode:	08/24/03 RSB	Began.
 *  		08/31/03 RSB	Added some additional checks for the kind of
 *				garbage produced by OCR.
 *		09/07/03 RSB	Made error messages a little cleaner.
 *		08/12/04 RSB	Added NVER.
 *		04/30/05 RSB	Unused variable removed.
 *		05/14/05 RSB	Corrected website references
 *		01/02/06 RSB	Now allow commas to appear as delimiters.
 *				This is done because I find it convenient
 *				when entering data using Dragon
 *				NaturallySpeaking 8.
 *		05/20/09 RSB	Added the --invert command-line switch.
 *				With this switch, the program reverses the
 *				normal process, taking a binary file and
 *				turning it into a textual file.  Such a
 *				file is helpful in proofing when converting
 *				a set of page images to source-code files,
 *				since when you assemble the source-code files
 *				so-created the result usually won't be what
 *				it's supposed to, and at some point you have
 *				to compare the binary created by yaYUL against
 *				the binary in the page images.  Also added
 *				the --page switch.
 *		11/22/10 RSB    Added the CHECKWORDS=Count variable to
 *                              supplement the existing BANK=BankNumber
 *                              variable.  CHECKWORDS is the number of words
 *                              participating in the checksum, including the
 *                              bugger word.  It defaults to 02000, which is
 *                              the number of words in a bank.  This is
 *                              normally okay, since any unuused words
 *                              following the bugger word are zero.  But with
 *                              Solarium 055, some banks have data stored
 *                              *after* the bugger word, and shouldn't
 *                              participate in the checksum.  The CHECKWORDS
 *                              variable is used when necessary to compensate
 *                              for that funky fact.  It must *follow* the
 *                              BANK variable when it's used.  Also, I added the
 *                              NUMBANKS variable, which should precede any
 *                              bank and give the total number of banks.
 *                              Defaults to 044.  Both of the new variables
 *                              are in octal.
 *              2012-09-18 JL   Tidy up for Colossus237. Split common code
 *                              out to a separate utilities module.
 *              2016-08-01 RSB  Now initialize banknum to 0.  I don't know
 *                              if it's right --- probably unnecessary.
 *              2016-08-25 RSB  Added --block1 for use with --invert.  (Not
 *                              needed otherwise.)  Fixed the command-line
 *                              parsing, which no longer accepted --invert.
 *            	2016-10-01 RSB	Added PARITY=.  It now also creates a file
 *            			oct2bin.proofing, which is just like the input
 *            			file but with parity stripped off, which is
 *            			helpful for proofing.
 *            	2016-10-13 RSB  Updated error messages to make it easier to
 *            	                localize problems.
 *              2016-10-21 RSB  Now pads the output file appropriately for
 *                              either Block 1 or Block 2.
 *              2016-11-24 RSB	Previously, the page numbers reported in the
 *              		error message were 100% dependent on the comments.
 *              		Now they also include an estimate from the number
 *              		of lines of octals already read.
 *              2016-12-16 RSB	Added --no-checksums (for Retread 44).
 *              2017-01-31 MAS	Added --parity for generating parity bits for
 *              		emitted words, and support for @ to denote
 *              		unused words in the assembly.
 *              2017-02-01 MAS	Disabled parity checking for unused words.
 *
 *  The format of the file is simple.  Each line just consists of 8 fields,
 *  delimited by whitespace.  Each field consists of 5 octal digits.  Blank
 *  lines and lines beginning with ';' are ignored.
 *
 *  The checksum of any given bank is equal to the sum of all of the words
 *  in the bank, including the so-called "bugger" word, which follows all of the
 *  valid data.  The sum is supposed to be equal to the bank number.  Filler
 *  words of 0 should be added after the bugger word, so that the banks never
 *  end prematurely
 *
 *  Oct2Bin internally attempts to compute the checksum, thus providing an
 *  additional check on the data.  To account for this, the data for each bank
 *  should be preceded by a line that reads
 *  	BANK=BankNumber
 *
 *  The input is on stdin. Status messages are on stdout. The binary is written
 *  to a file called oct2bin.bin.
 *
 *  If the command-line switch --invert is used, then the input should be a binary
 *  file called oct2bin.bin, and the output will be a text file named oct2bin.binsource.
 *  When --invert is used, the switch --page=N can be used to select a starting page
 *  number for the binary listing, so as to create something that corresponds to the
 *  set of page images.
 */

//#define VERSION(x) #x
#include <stdio.h>
#include <ctype.h>
#include <stdint.h>
#include <string.h>
#include "utils.h"

int errorCount = 0;

static uint16_t checksum = 0;
static int numBanks = 044;

// Decompile a binary file to text.  We don't bother to check the bugger codes.
int
decompile(int page)
{
  unsigned char b[2];
  int value, count = 0;
  FILE *fin, *fout;

#ifdef WIN32
  fin = fopen("oct2Bin.bin", "rb");
#else
  fin = fopen("oct2bin.bin", "r");
#endif
  if (fin == NULL)
    {
      printf("Error: input file oct2bin.bin does not exist.\n");
      return (1);
    }

  fout = fopen("oct2bin.binsource", "w");
  if (fout == NULL)
    {
      fclose(fin);
      printf("Error: cannot create output file oct2bin.binsource.\n");
      return (1);
    }

  // Write a template file header that can be manually edited later.
  fprintf(fout, "; Copyright: Public domain\n");
  fprintf(fout, "; Filename:  XXXX.binsource\n");
  fprintf(fout, "; Purpose:   XXXX\n");
  fprintf(fout, "; Contact:   info@sandroid.org\n");
  fprintf(fout, "; Mods:      XXXX-XX-XX XXX    Auto-generated by oct2bin.\n");
  fprintf(fout, ";            XXXX-XX-XX XXX    XXXX");

  // Read and write data.
  while (fread(b, 2, 1, fin) == 1)
    {
      value = (b[0] << 7) | (b[1] >> 1);

      if ((count % 8) == 0)
        fprintf(fout, "\n");

      if ((count % 32) == 0)
        fprintf(fout, "\n");

      if ((count % 256) == 0)
        {
          char pageString[33], bankString[33];

          if (page <= 0)
            pageString[0] = 0;
          else
            sprintf(pageString, " p. %d,", page++);

          if (count < 04000)
            sprintf(bankString, " %o", (Block1 ? 02000 : 04000) + count);
          else
            sprintf(bankString, " %02o,%04o", getBank(count),
                (Block1 ? 06000 : 02000) + (count % 1024));

          fprintf(fout, ";%s%s\n", pageString, bankString);
        }

      if ((count % 02000) == 0)
        fprintf(fout, "BANK=%o\n", getBank(count));

      fprintf(fout, "%05o ", value);
      count++;
    }

  fclose(fin);
  fclose(fout);

  return (0);
}

int
main(int argc, char *argv[])
{
  FILE *outfile, *proofFile;
  int dummy, data[8], line, checked = 1, octLine = 0, octPage, octOffset, firstPage = -1, unused[8];
  uint16_t dummy16, banknum = 0;
  int count, checkWords = 0;
  char s[129], *ss;
  int i, j, invert = 0, page = 0, verbose = 0, useParity = 0, noChecksums = 0, parity = 0;
  int currentPage = 0;

  // Parse the command-line switches.
  Block1 = 0;
  for (i = 1; i < argc; i++)
    {
      if (!strcmp(argv[i], "--invert") || !strcmp(argv[i], "-i"))
        invert = 1;
      else if (!strcmp(argv[i], "--verbose") || !strcmp(argv[i], "-v"))
        verbose = 1;
      else if (sscanf(argv[i], "--page=%d", &j) == 1)
        page = j;
      else if (!strcmp(argv[i], "--block1"))
        Block1 = 1;
      else if (!strcmp(argv[i], "--no-checksums"))
        noChecksums = 1;
      else if (!strcmp(argv[i], "--parity"))
        parity = 1;
      else
        {
          fprintf(stderr, "Error: Unknown command-line switch \"%s\"\n",
              argv[i]);
          return (1);
        }
    }

  if (verbose)
    {
      printf("(c)2003-2005,2010,2016 Ronald S. Burkey, ver " NVER ", built " __DATE__ "\n");
      printf(
          "Refer to http://www.ibiblio.org/apollo/index.html for more information.\n");
    }

  if (invert)
    return (decompile(page));

  outfile = fopen("oct2bin.bin", "wb");
  if (outfile == NULL)
    {
      errorCount++;
      fprintf(stderr, "Error: Cannot create the output file oct2bin.bin.\nl");
      return (1);
    }
  proofFile = fopen("oct2bin.proof", "wb");
  if (proofFile == NULL)
    {
      errorCount++;
      fprintf(stderr,
          "Error: Cannot create the proofing file oct2bin.proof.\n");
      return (1);
    }

  s[sizeof(s) - 1] = 0;
  line = 0;

  while (fgets(s, sizeof(s) - 1, stdin) != NULL)
    {
      line++;
      if (s[0] == ';' || s[0] == '\n')
        goto proofIt;
      if (sscanf(s, "NUMBANKS=%o", &dummy) == 1)
        {
          numBanks = dummy;
          goto proofIt;
        }

      if (sscanf(s, "BANK=%o", &dummy) == 1)
        {
	  if (!noChecksums)
	    check(verbose, line, checked, banknum, checksum);
          banknum = dummy;
          checksum = 0;
          if ((ftell(outfile) & 03777) != 0)
            {
              errorCount++;
              fprintf(stderr,
                  "Bank %o, page %d, line %d: Bank is not aligned properly.\n",
                  banknum, currentPage, line);
            }
          checked = 0;
          checkWords = 02000;
          goto proofIt;
        }

      if (sscanf(s, "CHECKWORDS=%o", &dummy) == 1)
        {
          checkWords = dummy;
          if (checkWords == 0)
            checksum = banknum;
          goto proofIt;
        }

      if (sscanf(s, "BUGGER=%o", &dummy) == 1)
        {
          dummy16 = dummy;
          putc(dummy16 >> 8, outfile);
          putc(dummy16 & 255, outfile);
          checksum = addAgc(checksum, dummy16);
          if (!noChecksums)
            check(verbose, line, checked, banknum, checksum);
          checked = 1;
          goto proofIt;
        }

      if (sscanf(s, "PARITY=%o", &dummy) == 1)
        {
          useParity = (dummy != 0);
          // Since the parity digit is stripped from the proofing file,
          // we don't add the PARITY=whatever to it, since that makes
          // the proofing file itself a valid input file for oct2bin.
          continue;
        }

      if (1 == sscanf(s, "%d", &dummy))
	{
	  octLine++;
	  octPage = (octLine + 31) / 32;
	  octOffset = octLine - 32 * (octPage - 1);
	  octPage += firstPage - 1;
	}


      // Check for certain garbage conditions.
      for (ss = s; *ss; ss++)
        {
          if (*ss == ',')	// 01/02/06 RSB.  Remove comma delimiters.
            *ss = ' ';
          else if (!isspace(*ss) && (*ss != '@') && (*ss < '0' || *ss > '7'))
            {
              errorCount++;
              fprintf(stderr,
                  "Bank %o, page %d(%d:%d), line %d: Illegal digit \'%c\'.\n", banknum,
                  currentPage, octPage, octOffset, line, *ss);
            }
        }

      for (ss = s, i = 0;; i++)
        {
          for (; isspace(*ss); ss++)
            ;
          if (*ss == 0)
            break;
          for (j = 0; *ss && !isspace(*ss); ss++, j++)
            ;
          if (j == 1 && *(ss-1) == '@' && i < 8)
            {
              // A lone @ means the word is unused. Mark it so and replace it with
              // a 0 so parsing won't choke on it.
              unused[i] = 1;
              *(ss-1) = '0';
            }
          else if (j != (useParity ? 6 : 5))
            {
              errorCount++;
              fprintf(stderr,
                  "Bank %o, page %d(%d:%d), line %d: Field is not correct width.\n",
                  banknum, currentPage, octPage, octOffset, line);
            }
          else
            unused[i] = 0;
        }

      if (i > 8)
        {
          errorCount++;
          fprintf(stderr, "Bank %o, page %d(%d:%d), line %d: Too many fields.\n",
              banknum, currentPage, octPage, octOffset, line);
        }

      // Now, parse like the wind!
      count = sscanf(s, "%o%o%o%o%o%o%o%o", &data[0], &data[1], &data[2],
          &data[3], &data[4], &data[5], &data[6], &data[7]);
      for (dummy = 0; dummy < count; dummy++)
        {
          // If PARITY=1, then the data is going to be 6 octal digits, of which
          // the least-significant digit is the parity and must be stripped
          // off.
          if (useParity && !unused[dummy])
            {
              int parity = data[dummy] & 07;
              data[dummy] = (data[dummy] >> 3);
              if (parity != 0 && parity != 1)
                {
                  fprintf(
                  stderr,
                      "Bank %o, page %d(%d:%d), line %d: The parity field is neither 0 nor 1 at %05o %o.\n",
                      banknum, currentPage, octPage, octOffset, line, data[dummy], parity);
                }
              else
                {
                  int word;
                  word = data[dummy] | (parity << 15);
                  // word is now 16 bits, contains both the parity bit and the data.
                  word ^= (word >> 8);
                  word ^= (word >> 4);
                  word ^= (word >> 2);
                  word ^= (word >> 1);
                  word &= 1;
                  if (word != 1)
                    {
                      fprintf(stderr,
                          "Bank %o, page %d(%d:%d), line %d: Parity error at %05o %o\n",
                          banknum, currentPage, octPage, octOffset, line, data[dummy], parity);
                    }
                }
            }
          // Note that the data is 15-bits which has been input right-aligned
          // (aligned at bit 0) but must be output left-aligned (aligned at
          // bit 1).
          dummy16 = data[dummy] << 1;
          if (parity && !unused[dummy])
            {
              // If parity bits have been requested, add parity bits only to
              // words that are not marked as unused.
              int16_t word = dummy16;
              word ^= (dummy16 >> 8);
              word ^= (word >> 4);
              word ^= (word >> 2);
              word ^= (word >> 1);
              word ^= 1;
              dummy16 |= (word & 1);
            }
          putc(dummy16 >> 8, outfile);
          putc(dummy16 & 255, outfile);
          if (checkWords > 0)
            {
              // Normally, checkWords will always be >=0, unless
              // CHECKWORDS=something variable assignment was made for
              // the bank.
              checksum = addAgc(checksum, dummy16 >> 1);
              checkWords--;
            }
          fprintf(proofFile, "%s%05o", ((dummy == 0) ? "" : " "), data[dummy]);
        }
      fprintf(proofFile, "\n");
      if (0)
        {
          proofIt: ;
          if (s[0] == ';')
            {
              char *ss;
              int j;
              for (ss = &s[1]; *ss == ' ' || *ss == '\t'; ss++)
                ;
              if (1 == sscanf(ss, "Page%d", &j) || 1 == sscanf(ss, "page%d", &j)
                  || 1 == sscanf(ss, "PAGE%d", &j)
                  || 1 == sscanf(ss, "p.%d", &j))
        	{
        	  currentPage = j;
        	  if (firstPage < 0)
        	    firstPage = j;
        	}
            }
          fprintf(proofFile, "%s", s);
        }
    }

  if (!noChecksums)
    check(verbose, line, checked, banknum, checksum);
  // Pad file to proper length (or else diffs will eventually fail).
  i = (Block1 ? 034 : 044) * 02000 * 2;
  while (ftell(outfile) < i)
    if (0 != putc(0, outfile) || 0 != putc(0, outfile))
        break;
  if (ftell(outfile) < i)
    {
      errorCount++;
      fprintf(
      stderr,
          "Error: The core-rope image is not at least %o (octal) banks (2 * 02000 * 0%o bytes) long.\n",
          numBanks, numBanks);
    }

  fclose(outfile);
  fclose(proofFile);

  if (errorCount == 0)
    {
      if (verbose)
        printf("No errors were detected.\n");
    }
  else
    {
      fprintf(stderr, "%d error%s detected.\n", errorCount,
          errorCount == 1 ? " was" : "s were");
    }

  return (errorCount);
}
