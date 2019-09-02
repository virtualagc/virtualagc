#!/usr/bin/python3
# Copyright 2019 Ronald S. Burkey <info@sandroid.org>
#
# This file is part of yaAGC. 
#
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# Filename:    	ibm360math.py
# Purpose:     	The original LVDC assembler ran on an IBM 360 family computer,
#		and as a result did any computations involving assembler 
#		non-integer constants using IBM 360 single-precision floating
#		point.  Unfortunately, IBM 360 single-precision floating point
#		had slightly less bits of precision than LVDC binary integer
#		representations had, so there was often an error in the 
#		least-significant bit of such constants.  This is tough to
#		reproduce using a modern floating-point format supported by 
#		Python, so I'm trying to get around that by creating an (albeit
#		inefficient) library of IBM 360 compatible math routines, and
#		doing the computations for the modern LVDC assembler using
#		the 360-compatible library rather than Python's built-in arithmetic.
# Reference:   	http://www.ibibio.org/apollo/LVDC.html
#		http://www.edwardbosworth.com/My3121Textbook_HTM/MyText3121_Ch17_V02.htm
# Mods:        	2019-09-02 RSB  Began.

# IBM 360 floating point numbers are based on the representation +/- Nx(16^E), where
# -64 <= E <= 63 and 1/16 <= N < 1.  The format in which I store an IBM floating-point 
# number is a dictionary like so:
#	{
#		"negative" ..., 	# True if negative, False if non-negative
#		"exponent" : ... ,	# -64 to 63, though I don't actually enforce this.
#		"digits" : ...		# N, multiplied by 2^24 and converted to an integer.
#	}
# A special case that doesn't fit the pattern above:
trueZero = { "negative": False, "exponent": 0, "digits": 0 }

# Convert a python float to an IBM 360 float.  Returns False if the input value is too big.
# If too small, it's simply transparently converted to true zero.  Yes, the code is inefficient.  
# It's designed to be as obviously correct as possible rather than as efficient as possible.  
# The assembler only needs to use it a few dozen times anyway, so it hardly matters.
def floatToIbm(value):
	ibmValue = trueZero.copy()
	if value == 0:
		return ibmValue
	if value < 0:
		ibmValue["negative"] = True
		value = -value
	while value < 0.0625:
		ibmValue["exponent"] -= 1
		value *= 16
		if ibmValue["exponent"] < -64:
			return trueZero.copy()
	while value >= 1.0:
		ibmValue["exponent"] += 1
		value /= 16.0
		if ibmValue["exponent"] > 63:
			return False
	value = round(value * pow(2.0, 24))
	ibmValue["digits"] = value
	return ibmValue

# Convert an IBM 360 float to a python float. 
def ibmToFloat(ibmValue):
	value = ibmValue["digits"]
	value = value * pow(16.0, -6 + ibmValue["exponent"])
	if ibmValue["negative"]:
		value = -value
	if (float(value)).is_integer():
		value = int(value)
	return value

# Multiply two IBM floats and returns an IBM float.  Returns false upon failure.
def ibmMultiply(ibmValue1, ibmValue2):
	negative = ibmValue1["negative"] != ibmValue2["negative"]
	exponent = ibmValue1["exponent"] + ibmValue2["exponent"]
	value = round(ibmValue1["digits"] * ibmValue2["digits"] * pow(16.0, -6))
	if value == 0:
		return trueZero.copy()
	while (value & 0xF00000) == 0:
		exponent -= 1
		value = value << 4
		if exponent < -64:
			return trueZero.copy()
	if exponent > 63:
		return False
	return { "negative": negative, "exponent": exponent, "digits": value }

# Divide two IBM floats and returns an IBM float.  Returns false upon failure.
def ibmDivide(ibmValueNumerator, ibmValueDenominator):
	if ibmValueDenominator["digits"] == 0:
		return False
	negative = ibmValueNumerator["negative"] != ibmValueDenominator["negative"]
	exponent = ibmValueNumerator["exponent"] - ibmValueDenominator["exponent"]
	value = round((ibmValueNumerator["digits"] << 24) / ibmValueDenominator["digits"])
	while (value & ~0xFFFFFF) != 0:
		value = round(value / 16.0)
		exponent += 1
		if exponent > 63:
			return False
	while (value & 0xF00000) == 0:
		if value == 0:
			return trueZero.copy()
		value = value << 4
		exponent -= 1
		if exponent < -64:
			return trueZero.copy()
	return { "negative": negative, "exponent": exponent, "digits": value }

# Adds (or subtracts if the parameter "subtract" is True) two IBM floats and
# returns an IBM float.  Returns false upon failure.
def ibmAdd(ibmValue1, ibmValue2, subtract = False):
	# Make the input parameters easier to access, and make sure we 
	# don't accidentally change any of them in the calling code.
	negative1 = ibmValue1["negative"]
	exponent1 = ibmValue1["exponent"]
	digits1 = ibmValue1["digits"]
	negative2 = ibmValue2["negative"]
	exponent2 = ibmValue2["exponent"]
	digits2 = ibmValue2["digits"]
	# Manipulate the inputs so that both have the same sign.
	if negative1 != negative2:
		negative2 = not negative2
		subtract = not subtract
	# Realign the input value with the lower exponent (if there is one)
	# so that both have the same exponent.  The adjusted value will no
	# longer be normalized, but we'll be able to add or subtract
	# it with the other on an apples-to-apples basis.
	delta = exponent1 - exponent2
	if delta > 0:
		digits2 = round(digits2 / pow(16.0, delta))
		exponent2 += delta
	elif delta < 0:
		delta = -delta
		digits1 = round(digits1 / pow(16.0, delta))
		exponent1 += delta
	# Now do the actual arithmetic.  Recall that the two terms now
	# have the same sign.  Therefore, addition will always be the 
	# correct sign and will either be scaled properly or else will 
	# have overflowed.  Similarly, subtraction cannot overflow, but
	# can underflow to negative, and may need to be rescaled upward.
	negative = negative1
	exponent = exponent1
	if subtract:
		digits = digits1 - digits2
		if digits == 0:
			return trueZero.copy()
		if digits < 0:
			negative = not negative
			digits = -digits
		while (digits & 0xF00000) == 0:
			digits = digits << 4
			exponent -= 1
			if exponent < -64:
				return trueZero.copy()
	else:
		digits = digits1 + digits2
		if digits > 0xFFFFFF:
			digits = digits >> 4
			exponent += 1
	if exponent > 63:
		return False
	return { "negative": negative, "exponent": exponent, "digits": digits }
	
# Some test code.
if False:
	import sys
	floats = [ 7780.976, 6570774, 123456, -5432.1, 0.901236, -0.3271234, 0.000031415768, -0.0000000000087649837 ]
	ibmfloats = []
	for v in floats:
		ibmfloats.append(floatToIbm(v))
		v2 = ibmToFloat(ibmfloats[-1])
		print("%g -> (%s, %d, %08o) -> %g" % (v, ibmfloats[-1]["negative"], ibmfloats[-1]["exponent"], ibmfloats[-1]["digits"], v2))
	for n1 in range(len(floats)):
		for n2 in range(len(floats)):
			v1 = floats[n1]
			v2 = floats[n2]
			vi1 = ibmfloats[n1]
			vi2 = ibmfloats[n2]
			
			vv = floats[n1] + floats[n2]
			vvi = ibmToFloat(ibmAdd(vi1, vi2))
			print("%g + %g = %g %g" % (v1, v2, vv, vvi))
			vv = floats[n1] - floats[n2]
			vvi = ibmToFloat(ibmAdd(vi1, vi2, True))
			print("%g - %g = %g %g" % (v1, v2, vv, vvi))
			vv = floats[n1] * floats[n2]
			vvi = ibmToFloat(ibmMultiply(vi1, vi2))
			print("%g * %g = %g %g" % (v1, v2, vv, vvi))
			vv = floats[n1] / floats[n2]
			vvi = ibmToFloat(ibmDivide(vi1, vi2))
			print("%g / %g = %g %g" % (v1, v2, vv, vvi))

