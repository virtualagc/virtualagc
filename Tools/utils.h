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
 *  Filename:	utils.h
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

#include <stdint.h>

// Convert an AGC-format signed integer to native format.
int convertAgcToNative(uint16_t n);

// This function takes two signed integers in AGC format, adds them, and returns
// the sum (also in AGC format).  If there's overflow or underflow, the 
// carry is added in also.  This is done because that's the goofy way the
// AGC checksum is created.
uint16_t addAgc(uint16_t n1, uint16_t n2);

// Check the supplied checksum.
void check(int verbose, int line, int checked, uint16_t banknum, uint16_t checksum);

// Get the bank number for a specified offset.
int getBank(int count);

