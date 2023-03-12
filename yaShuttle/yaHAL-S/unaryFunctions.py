#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:  None - the author (Ron Burkey) declares this software to
            be in the Public Domain, with no rights reserved.
Filename:   unaryFunctions.py
Requires:   Python 3.7 or later.
Purpose:    A collection of functions suitable for use with the unaryOperation()
            function of the palmatAux.py module.  These are mostly RTL functions
            but HAL/S's negation operator (-) is included too.
References: https://www.ibiblio.org/apollo/hal-s-compiler.html#PALMAT
            [HPG] HAL/S Programmer's Guide.
            [PIH] Programming in HAL/S.
History:    2023-03-07 RSB  Began.

What follows is a bunch of functions used with the unaryOperation() function.
The idea is that if you want to perform an "arrayed operation" -- i.e., you
have an array and want to perform the same action on each entry in the 
array -- then you call unaryOperation() which handles the array'ing, along
with some additional function that handles the details of the specific 
operation on any one entry of the array.  The latter are the functions 
collected here.  They all share the characteristic that they return the
result of the operation (including possibly the value Python None for 
indeterminate results due to uninitialized inputs), or else NaN on error.
"""

import math
import copy
from palmatAux import *

#-----------------------------------------------------------------------
# But first, here are some utility functions the unary functions need.

'''
Compute determinant of a square matrix.  I have *not* researched optimal
methods.  This is simply the one that stuck in my mind from schooldays.
'''
def determinant(m):
    n = len(m)
    if n == 1:
        return m[0][0]
    d = 0.0
    s = 1
    for i in range(n):
        bottom = copy.deepcopy(m[1:])
        for row in bottom:
            row.pop(i)
        d += s * m[0][i] * determinant(bottom)
        s = -s
    return d

'''
Compute the inverse of a matrix.  There are innumerable methods for doing 
this, all of them accompanied by disclaimers as to why that particular method
is incredible for some specific kind of matrix, and all other methods are
horrible; and in the usual unhelpful web style, still other statements of the
form "are you sure you really want to invert that matrix anyway ... stupid!"
Of course, I haven't the slightest idea what the properties of the matrices 
that are going to be inverted are, nor however stupid it may be, any means
whatever of bypassing inversion. That being the case, here is simple Gaussian 
elimination with no frills whatever.  Returns either the inverse, or else
None if m isn't completely initialized, or NaN if singular.
'''
def matrixInverse(m):
    if not isCompletelyInitialized(m):
        return None
    # Augment m by attaching an identity matrix to the right.
    n = len(m)
    n2 = n + n
    a = []
    for i in range(n):
        addition = [0]*n
        addition[i] = 1
        a.append(m[i] + addition)
    # Reduce so that the left-hand side of the augmented matrix is in
    # upper-triangular form.
    for col in range(n):
        # At this step. only row = col and downard are considered.
        # First I find the row in this section with the largest element
        # in the column, and move it upward to row = col.
        maxElement = abs(a[col][col])
        maxRow = col
        for row in range(col + 1, n):
            e = abs(a[col][row])
            if e > maxElement:
                maxElement = e
                maxRow = row
        if maxElement == 0: # The matrix must be singular.
            return NaN
        if maxRow != col:
            a[col],a[maxRow] = a[maxRow],a[col]
        # Now we can subtract multiples of a[col) from all the rows below it
        # to make the elements in that column 0. 
        for row in range(col + 1, n):
            scale = a[row][col] / a[col][col]
            if scale == 0:
                continue
            #a[row][col] = 0
            for i in range(col, n2):
                a[row][i] -= scale * a[col][i]
    # Now reduce the upper triangle.
    for col in range(1, n):
        for row in range(col):
            scale = a[row][col] / a[col][col]
            if scale == 0:
                continue
            a[row][col] = 0
            for i in range(col + 1, n2):
                a[row][i] -= scale * a[col][i]
    # Finally, scale each row so that the diagonals on the left-hand side are
    # all 1, and pick off the left=hand side of the augmented matrix, since it's
    # the inverse.
    for row in range(n):
        e = a[row][row]
        a[row] = a[row][n:]
        for i in range(n):
            a[row][i] /= e
    return a

#----------------------------------------------------------------------
# The unary functions themselves follow:

# A unary-minus operator. See p. 7-2 of [HPG].
def unaryMinus(PALMAT, operand):
    result = NaN
    if operand == None:
        result = None
    elif isinstance(operand, (int, float)):
        result = -operand
    elif isVector(operand):
        result = []
        for v in operand:
            if v == None:
                result.append(None)
            else:
                result.append(-v)
    elif isMatrix(operand):
        result = []
        for r in operand:
            row = []
            for v in r:
                if v == None:
                    row.append(None)
                else:
                    row.append(-v)
            result.append(row)
    return result

def unaryABS(PALMAT, operand):
    try:
        return abs(operand)
    except:
        return NaN

def unaryCEILING(PALMAT, operand):
    try:
        return math.ceil(operand)
    except:
        return NaN

def unaryFLOOR(PALMAT, operand):
    try:
        return math.floor(operand)
    except:
        return NaN

def unaryODD(PALMAT, operand):
    try:
        operand = hround(operand)
        if (operand & 1) == 0:
            return hFALSE
        else:
            return hTRUE
    except:
        return NaN

def unaryROUND(PALMAT, operand):
    try:
        return hround(operand)
    except:
        return NaN

def unarySIGN(PALMAT, operand):
    try:
        if operand >= 0:
            return 1
        else:
            return -1
    except:
        return NaN

def unarySIGNUM(PALMAT, operand):
    try:
        if operand > 0:
            return 1
        elif operand < 0:
            return -1
        else:
            return 0
    except:
        return NaN

def unaryTRUNCATE(PALMAT, operand):
    try:
        if operand >= 0:
            return math.floor(operand)
        else:
            return math.ceil(operand)
    except:
        return NaN

def unaryARCCOS(PALMAT, operand):
    try:
        return math.acos(operand)
    except:
        return NaN

def unaryARCCOSH(PALMAT, operand):
    try:
        return math.acosh(operand)
    except:
        return NaN

def unaryARCSIN(PALMAT, operand):
    try:
        return math.asin(operand)
    except:
        return NaN

def unaryARCSINH(PALMAT, operand):
    try:
        return math.asinh(operand)
    except:
        return NaN

def unaryARCTAN(PALMAT, operand):
    try:
        return math.atan(operand)
    except:
        return NaN

def unaryARCTANH(PALMAT, operand):
    try:
        return math.atanh(operand)
    except:
        return NaN

def unaryCOS(PALMAT, operand):
    try:
        return math.cos(operand)
    except:
        return NaN

def unaryCOSH(PALMAT, operand):
    try:
        return math.cosh(operand)
    except:
        return NaN

def unaryEXP(PALMAT, operand):
    try:
        return math.exp(operand)
    except:
        return NaN

def unaryLOG(PALMAT, operand):
    try:
        return math.log(operand)
    except:
        return NaN

def unarySIN(PALMAT, operand):
    try:
        return math.sin(operand)
    except:
        return NaN

def unarySINH(PALMAT, operand):
    try:
        return math.sinh(operand)
    except:
        return NaN

def unarySQRT(PALMAT, operand):
    try:
        return math.sqrt(operand)
    except:
        return NaN

def unaryTAN(PALMAT, operand):
    try:
        return math.tan(operand)
    except:
        return NaN

def unaryTANH(PALMAT, operand):
    try:
        return math.tanh(operand)
    except:
        return NaN

def unaryABVAL(PALMAT, vector):
    try:
        sum = 0.0
        for v in vector:
            sum += v * v
        return math.sqrt(sum)
    except:
        return NaN

def unaryDET(PALMAT, matrix):
    try:
        if not isMatrix(matrix) or len(matrix) != len(matrix[0]):
            return NaN
        return determinant(matrix)
    except:
        return NaN

def unaryINVERSE(PALMAT, matrix):
    try:
        if not isMatrix(matrix) or len(matrix) != len(matrix[0]):
            return NaN
        inverse = matrixInverse(matrix)
        if inverse == None:
            return NaN
        return inverse
    except:
        return NaN

def unaryTRACE(PALMAT, matrix):
    try:
        if not isMatrix(matrix) or len(matrix) != len(matrix[0]):
            return NaN
        sum = 0.0
        for i in range(len(matrix)):
            sum += matrix[i][i]
        return sum
    except:
        return NaN

def unaryTRANSPOSE(PALMAT, matrix):
    try:
        if not isMatrix(matrix, False):
            return NaN
        numRows = len(matrix)
        numCols = len(matrix[0])
        transposed = []
        for i in range(numCols):
            transposed.append([0]*numRows)
        for i in range(numCols):
            for j in range(numRows):
                transposed[i][j] = matrix[j][i]
        return transposed
    except:
        return NaN

def unaryUNIT(PALMAT, vector):
    try:
        sum = 0.0
        for v in vector:
            sum += v * v
        length = math.sqrt(sum)
        result = []
        for i in range(len(vector)):
            result.append(vector[i] / length)
        return result
    except:
        return NaN

#----------------------------------------------------------------------
# Finally, one function that can be used to access any arrayable RTL
# function with a single operand.  I.e., any of the functions above
# except unaryMINUS() (which is for the "-" operator rather than an
# RTL function.  

# Built-ins with a single argument can mostly (all?) be 
# treated the same way.  Each entry in unaryRTL is a 2-list
# consisting of the function to be used with unaryOperation()
# and the error message on failure.  Actually, the 2nd entry
# of the list is optional, since the default message is 
# usually good enough.
unaryRTL = {
    "ABS": [unaryABS],
    "CEILING": [unaryCEILING],
    "FLOOR": [unaryFLOOR],
    "ODD": [unaryODD],
    "ROUND": [unaryROUND],
    "SIGN": [unarySIGN],
    "SIGNUM": [unarySIGNUM],
    "ARCCOS": [unaryARCCOS, "ARCCOS requires |argument\ <= 1"],
    "ARCCOSH": [unaryARCCOSH, "ARCCOSH requires |argument| >= 1"],
    "ARCSIN": [unaryARCSIN, "ARCSIN requires |argument| <= 1"],
    "ARCSINH": [unaryARCSINH, "ARCSINH requires |argument| >= 1"],
    "ARCTAN": [unaryARCTAN],
    "ARCTANH": [unaryARCTANH],
    "COS": [unaryCOS],
    "COSH": [unaryCOSH],
    "EXP": [unaryEXP],
    "LOG": [unaryLOG],
    "SIN": [unarySIN],
    "SINH": [unarySINH],
    "SQRT": [unarySQRT],
    "TAN": [unaryTAN],
    "TANH": [unaryTANH],
    "TRUNCATE": [unaryTRUNCATE, "TRUNCATE requires a numeric argument"],
    "ABVAL": [unaryABVAL, "ABVAL requires a VECTOR argument"],
    "DET": [unaryDET, "DET requires a square MATRIX argument"],
    "INVERSE": [unaryINVERSE, "INVERSE requires a non-singular square MATRIX argument"],
    "TRACE": [unaryTRACE, "TRACE requires a square MATRIX argument"],
    "TRANSPOSE": [unaryTRANSPOSE, "TRANSPOSE requires a MATRIX argument"],
    "UNIT": [unaryUNIT, "UNIT requires a non-zero VECTOR argument"],
    "Negation": [unaryMinus], # Not actually RTL function; rather U- operator
    }

# Returns either the operation result (could be None) or NaN on failure.
def arrayableUnaryRTL(PALMAT, halsFunctionName, operand, source, instruction):
    entry = unaryRTL[halsFunctionName]
    result = unaryOperation(PALMAT, entry[0], operand)
    if isNaN(result):
        if len(entry) < 2:
            printError(PALMAT, source, instruction, \
                       halsFunctionName + "requires a numeric argument")
        else:
            printError(PALMAT, source, instruction, entry[1])
        return NaN
    return result
