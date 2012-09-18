/*
 *  Copyright 2003-2006,2009 Ronald S. Burkey <info@sandroid.org>
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
 *  Filename:	utils.c
 *
 *  Purpose:	A small utilities library for use by various AGC tools.
 *
 *  Contact:	Jim Lawton <jim DOT lawton AT gmail DOT com>
 *
 *  Website:	http://www.ibiblio.org/apollo/index.html
 *
 *  History:	2012-09-18 JL   Created.
 *
 */

//#define VERSION(x) #x

#include <stdio.h>
#include <ctype.h>
#include <stdint.h>
#include <string.h>

extern int errorCount;

// Convert an AGC-format 15-bit 1's-complement signed integer to native format.
int convertAgcToNative(uint16_t n)
{
    int i;

    i = n;
    if ((n & 040000) != 0)
        i = -(077777 & ~i);

    return (i);
}

// Convert a native format integer to AGC-format 15-bit 1's-complement signed integer.
uint16_t convertNativeToAgc(int n)
{
    uint16_t i;
    int tmp = n;

    i = (uint16_t)(abs(n) & 077777);

    if (n < 0)
        i |= 040000;

    return (i);
}

// This function takes two signed integers in AGC format (15-bit, 1's complement,
// signed), adds them, and returns the sum (also in AGC format).  If there is
// overflow or underflow, the carry is added in also. This is done because that's
// the way the AGC checksum is created.
uint16_t addAgc(uint16_t n1, uint16_t n2)
{
    int i1, i2, sum;

    // Convert from AGC 1's-complement format to the native integer format of this CPU.
    i1 = convertAgcToNative(n1);
    i2 = convertAgcToNative(n2);

    // Add 'em up.
    sum = i1 + i2;

    // Account for carry or underflow.
    if (sum > 16383) {
        sum -= 16384;
        sum++;
    } else if (sum < -16383) {
        sum += 16384;
        sum--;
    }

    // The following condition can't occur, but I'll check for it anyway.
    if (sum > 16383 || sum < -16383)
        fprintf(stderr, "Error: arithmetic overflow.\n");

    // Convert back to 1's-complement and return.
    if (sum >= 0)
        return (sum);

    return (077777 & ~(-sum));
}

// Check the supplied checksum.
void check(int verbose, int line, int checked, uint16_t banknum, uint16_t checksum)
{
    if (!checked) {
        if (checksum == banknum)  {
            if (verbose)
                printf("Checksum for bank %02o matches (positive, %05o).\n", banknum, banknum);
        } else if (checksum == (077777 & ~banknum)) {
            if (verbose)
                printf("Checksum for bank %02o matches (negative, %05o).\n", banknum, 077777 & ~banknum);
        } else {
            errorCount++;
            fprintf(stderr, "Error: line %5d, checksum (%05o) for bank %02o does not match expected (%05o or %05o).\n",
                    line, checksum, banknum, banknum, 077777 & ~banknum);
        }
    }	    
}

// Generate the bugger word for a supplied bank code. Try to compute
// a positive bugger word if possible, otherwise compute a negative one
// (due to the limitations of 1's complement arithmetic).
//
// Returns the generated bugger word.
uint16_t generateBuggerWord(int verbose, int bank, int length, int16_t *code)
{
    uint16_t checksum = 0, bugger = 0;
    int i = 0;

    // Iterate over the bank and calculate the bugger word.
    for (i = 0; i < length; i++) {
        checksum = addAgc(checksum, code[i]);
    }

    if ((checksum & 040000) == 0) {
        bugger = addAgc(bank, 077777 & ~checksum);
        if (verbose)
            printf("Checksum for bank %02o is %05o, MSB=0, bugger word is %05o.\n", bank, checksum, bugger);
    } else {
        bugger = addAgc(077777 & ~bank, 077777 & ~checksum);
        if (verbose)
            printf("Checksum for bank %02o is %05o, MSB=1, bugger word is %05o.\n", bank, checksum, bugger);
    }

    return (bugger);
}

// Get the bank number for a specified offset.
int getBank(int count)
{
    int retval = count / 1024;

    if (retval < 2)
        retval += 2;
    else if (retval < 4)
        retval -= 2;

    return (retval);
}

