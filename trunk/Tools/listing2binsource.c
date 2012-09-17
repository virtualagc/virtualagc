/*
 *
 * Copyright 2010 Ronald S. Burkey <info@sandroid.org>
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
 * Filename:     listing2binsource.c
 *
 * Purpose:      This program assists in creating an executable
 *               binary from AGC programs like Luminary or Colossus.
 *               Unlike yaYUL (which processes the assembly language
 *               to product an executable) or Oct2Bin (which processes
 *               an octal listing to produce an executable),
 *               listing2binsource processes octal codes from the columns
 *               in an assembly listing which are parallel to the
 *               assembly language.  This is helpful for a listing
 *               like the Colossus 237 assembly listing obtained
 *               from Fred Martin in which the octal-listing section
 *               is missing completely, and yet we still need an
 *               executable obtained separately from yaYUL in order
 *               to cross-check the data entry of the assembly language.
 *
 * Contact:      Ron Burkey <info@sandroid.org>
 *
 * Website:      http://www.ibiblio.org/apollo/index.html
 *
 * Mods:         2010-12-11 RSB    Began.
 *               2010-12-19 RSB    Added the synonyms :.& for
 *                                 the commands c, p, and a.
 *               2010-12-23 RSB    Now allow comments, prefixed
 *                                 with #.
 *               2010-12-25 RSB    Allow '+' in place of 'a' or
 *                                 '&', because Dragon
 *                                 NaturallySpeaking 11 no longer
 *                                 allows me to use '&' the way
 *                                 DNS 8 did.  Sigh ....
 *               2012-09-17 JL     Tidy up.
 *
 * For listing2binsource.c, the octal codes are provided in an input file
 * created by moving through the assembly-language portion of the
 * assembly listing page by page and line by line.  The octal codes
 * are 5-digit octal numbers delimited either by commas or newlines
 * (whichever seems convenient at the time).  Interspersed with lines
 * containing octal codes are lines of one of the following forms:
 *
 * pN          (N being a 1-4 digit page number from the assembly listing)
 * aNNNN       (NNNN being a 4-digit octal number indicating the
 *             CPU location counter for the next section of octal codes)
 * aNN,NNNN    (Same, but with banked address NN,NNNN instead)
 * cNNNN       (The address of the preceding octal code)
 * cNN,NNNN    (Same, but with a banked address NN,NNNN instead)
 *
 * The following synonyms are also accepted:
 *   :    in place of     c
 *   .    in place of     p
 *   &    in place of     a
 *   +    in place of     a
 *
 * These synonyms can be remembered easily since "colon", "period"
 * (or "point"), or "and" or "add" (or "ampersand")  begin with the
 * same letter as the commands they're replacing.  The synonyms are
 * very convenient when dictating the octal listing using
 * Dragon NaturallySpeaking in "numbers" mode, since with these
 * synonyms (and the words "comma" and "newline") *all* of the
 * data-entry can be dictated without needing to use the keyboard
 * for anything other than corrections.
 *
 * The pN, cNNNN, and cNN,NNNN codes would not be necessary *if*
 * data entry is perfectly accurate, but are pragmatically necessary
 * for debugging data entry because they allow listing2binsource to
 * determine that the correct number of octal codes have been entered
 * for any given address range, and all warning messages to be printed
 * that localize such mismatches to the page.  It does not allow any
 * determination that the octal codes are *correct*, of course.
 * (Without an octal listing appearing in the assembly listing, the
 * memory-bank checksums are unknown.  They can be computed by
 * listing2binsource, but cannot be checked by listing2binsource.)  Thus,
 * while pN, cNNNN, and cNN,NNNN are optional, listing2binsource will
 * print warning messages wherever such a message would be useful
 * but is not found.  In particular:
 *
 *   - It is expected that pN lines appear in the order p1, p2, p3, ...
 *     pLAST throughout the input file, without any missing pages.  (If
 *     there are no octal codes on a page, its pN should appear anyway.)
 *
 *   - A cNNNN or cNN,NNNN should appear before every pN (except for
 *     the first page or if the preceding page contained no octal codes).
 *
 *   - A cNNNN or cNN,NNNN should appear before every aNNNN or aNN,NNNN
 *    (except those immediately preceded by a pN).
 *
 * Whitespace (including completely blank lines) is ignored by
 * listing2binsource, as are commas at the ends of lines.
 *
 * The input file is read on stdin, and a file capable of being used
 * as input to Oct2Bin is written on stdout.  printError and warning messages
 * are written to stderr.  The return value is zero on success, and
 * is non-zero if there were any warnings or errors.
 *
 */

#include <stdio.h>
#include <inttypes.h>
#include <string.h>

enum {
    UNASSIGNED = 0x8000,
    CORRUPTED,
    OVERWRITTEN
};

#define NUM_BANKS 044
#define WORDS_PER_BANK 02000
#define BANK_OFFSET 02000

static char inputLine[16384];
static int16_t rope[NUM_BANKS][WORDS_PER_BANK];

static int printError(int page, int line, char *message)
{
    fprintf(stderr, "Error (p%d, line %d): %s\n", page, line, message);
    return (1);
}

int main(void)
{
    int i, j;
    char c;
    int retval = 0;
    int line = 0;
    int inputLength;
    char *s, *ss;
    int currentPage = 0;
    int bank = -1, offset = -1;
    char lastLineType = 'c';
    int count = 0, page = 2000;
    FILE *fout;

    // Initialize the rope with the special value UNASSIGNED,
    // which can't occur in the 15-bit input.  UNASSIGNED will be
    // automatically converted to 00000 when the rope is saved
    // later, but will be a good internal marker for us that
    // a given word hasn't been assigned a value.
    for (i = 0; i < NUM_BANKS; i++)
        for (j = 0; j < WORDS_PER_BANK; j++)
            rope[i][j] = UNASSIGNED;

    // Now read the input file.
    while (fgets(inputLine, sizeof(inputLine), stdin) != NULL) {
        line++;

        // Eliminate spaces, newlines, comments.
        for (s = ss = inputLine; *s; s++) {
            if (*s == '\n' || *s == '\r' || *s == '#')
                break;
            if (*s == ' ')
                continue; // Ignore all spaces.
            *ss++ = *s;
        }

        // Ignore completely empty lines.
        if (ss == inputLine)
            continue;

        // Make sure there's exactly one ',' at the end of the line
        // by appending ',' and then reducing all multiple commas at
        // the end of line to a single comma.
        *ss++ = ',';
        for (; ss >= &inputLine[1] && ss[-1] == ',' && ss[-2] == ','; ss--)
            ;

        inputLength = ss - inputLine;
        *ss = 0;

        // Translate some command synonyms:
        switch (inputLine[0]) {
        case ':':
            inputLine[0] = 'c';
            break;
        case '.':
            inputLine[0] = 'p';
            break;
        case '&':
            inputLine[0] = 'a';
            break;
        case '+':
            inputLine[0] = 'a';
            break;
        }

        // Now that the input lines have been completely normalized,
        // we can begin parsing them.
        if (inputLine[0] == 'p') {
            s = strstr(inputLine, ",");
            if ((s == &inputLine[inputLength - 1]) && (sscanf(inputLine, "p%d%c", &i, &c) == 2) && (c == ',')) {
                if (i != currentPage + 1)
                    retval = printError(currentPage, line, "Page-number out of sequence.");
                if (lastLineType != 'c' && lastLineType != 'p' && lastLineType != 'a')
                    retval = printError(currentPage, line, "Missing address-check.");
                currentPage = i;
            } else
                retval = printError(currentPage, line, "Ill-formed page line.");
        } else if (inputLine[0] == 'c' || inputLine[0] == 'a') {
            s = strstr(inputLine, ",");

            if (s[1] != 0)
                s = strstr(s + 1, ",");

            if ((s == &inputLine[inputLength - 1]) && (sscanf(&inputLine[1], "%o,%o%c", &i, &j, &c) == 3) && (c == ',')) {
ProcessAorC:
                if (i < 0 || i >= NUM_BANKS || j < BANK_OFFSET || j > BANK_OFFSET + WORDS_PER_BANK)
                    retval = printError(currentPage, line, "Address out of range.");

                j -= BANK_OFFSET;
                if (inputLine[0] == 'a') {
                    if (lastLineType != 'c' && lastLineType != 'p')
                        retval = printError(currentPage, line, "Missing address-check.");
                    bank = i;
                    offset = j;
                } else {
                    // inputLine[0] == 'c'
                    if (bank != i || offset != j + 1)
                        retval = printError(currentPage, line, "Address-check mismatch.");
                }
            }
            else if ((s == &inputLine[inputLength - 1]) && (sscanf(&inputLine[1], "%o%c", &j, &c) == 2) && (c == ',')) {
                if (j >= 04000 && j <= 05777) {
                    i = 0;
                    j -= 02000;
                } else if (j >= 06000 && j <= 07777) {
                    i = 1;
                    j -= 04000;
                }
                else
                    i = -1;
                goto ProcessAorC;
            }

            else
                retval = printError(currentPage, line, "Ill-formed address or check line.");
        } else {
            // Must be octal codes.
            if (bank < 0 || bank >= NUM_BANKS || offset < 0 || offset >= WORDS_PER_BANK)
                retval = printError(currentPage, line, "Missing address assignment.");

            // Parse each field on the line.  Recall that the line ends with
            // a comma, so we can just search until there are no more commas.
            for (s = inputLine; (ss = strstr(s, ",")) != NULL && ss < &inputLine[inputLength]; s = ss + 1) {
                if (ss - s != 5) {
                    i = CORRUPTED;
                    retval = printError(currentPage, line, "Non 5-digit octal field.");
                } else if (sscanf(s, "%o%c", &i, &c) != 2 || (c != ',' && c != ' ' && c != '\t')) {
                    i = CORRUPTED;
                    retval = printError(currentPage, line, "Junk characters in octal field.");
                }

                if (rope[bank][offset] >= 00000 && rope[bank][offset <= 077777]) {
                    i = OVERWRITTEN;
                    retval = printError(currentPage, line, "Memory overwrite.");
                }

                if (retval == 0)
                    rope[bank][offset] = i;
                offset++;
            }
        }
        lastLineType = inputLine[0];
    }

    // Write the output.  This code was swiped and slightly altered from oct2bin.
    if (retval == 0) {
        fout = stdout;
        fprintf(fout, "; Copyright: Public domain\n");
        fprintf(fout, "; Filename:  XXXX.binsource\n");
        fprintf(fout, "; Purpose:   XXXX\n");
        fprintf(fout, "; Contact:   info@sandroid.org\n");
        fprintf(fout, "; Mods:      XXXX-XX-XX XXX    Auto-generated by listing2binsource.\n");
        fprintf(fout, ";            XXXX-XX-XX XXX    XXXX\n");
        fprintf(fout, ";\n");
        fprintf(fout, "; Note that the \"page numbers\" shown below are completely fictitious.");
        // The \n missing from the line above is supplied below.

        // Read and write data.
        for (i = 0; i < NUM_BANKS; i++)
            for (j = 0; j < WORDS_PER_BANK; j++) {
                int value;
                value = rope[(i < 4) ? (i ^ 2) : i][j];

                if (value > 077777 || value < 0)
                    value = 0;

                if (0 == (count % 8))
                    fprintf(fout, "\n");

                if (0 == (count % 32))
                    fprintf(fout, "\n");

                if (0 == (count % 256)) {
                    char pageString[33], bankString[33];
                    if (page <= 0)
                        pageString[0] = 0;
                    else
                        sprintf(pageString, " p. %d,", page++);
                    if (count < 2048)
                        sprintf(bankString, " %o", 04000 + count);
                    else
                        sprintf(bankString, " %02o,%04o", ((i < 4) ? (i ^ 2) : i),
                                02000 + (count % 1024));
                    fprintf(fout, ";%s%s\n", pageString, bankString);
                }

                if ((count % 1024) == 0)
                    fprintf(fout, "BANK=%o\n", ((i < 4) ? (i ^ 2) : i));

                fprintf(fout, "%05o ", value);
                count++;
            }
    }

    return (retval);
}
