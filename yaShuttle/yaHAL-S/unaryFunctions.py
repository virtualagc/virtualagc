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
def unaryMinus(operand):
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

def unaryABS(operand):
    try:
        return abs(operand)
    except:
        return NaN

def unaryCEILING(operand):
    try:
        return math.ceil(operand)
    except:
        return NaN

def unaryFLOOR(operand):
    try:
        return math.floor(operand)
    except:
        return NaN

def unaryODD(operand):
    try:
        operand = hround(operand)
        if (operand & 1) == 0:
            return hFALSE
        else:
            return hTRUE
    except:
        return NaN

def unaryROUND(operand):
    try:
        return hround(operand)
    except:
        return NaN

def unarySIGN(operand):
    try:
        if operand >= 0:
            return 1
        else:
            return -1
    except:
        return NaN

def unarySIGNUM(operand):
    try:
        if operand > 0:
            return 1
        elif operand < 0:
            return -1
        else:
            return 0
    except:
        return NaN

def unaryTRUNCATE(operand):
    try:
        if operand >= 0:
            return math.floor(operand)
        else:
            return math.ceil(operand)
    except:
        return NaN

def unaryARCCOS(operand):
    try:
        return math.acos(operand)
    except:
        return NaN

def unaryARCCOSH(operand):
    try:
        return math.acosh(operand)
    except:
        return NaN

def unaryARCSIN(operand):
    try:
        return math.asin(operand)
    except:
        return NaN

def unaryARCSINH(operand):
    try:
        return math.asinh(operand)
    except:
        return NaN

def unaryARCTAN(operand):
    try:
        return math.atan(operand)
    except:
        return NaN

def unaryARCTANH(operand):
    try:
        return math.atanh(operand)
    except:
        return NaN

def unaryCOS(operand):
    try:
        return math.cos(operand)
    except:
        return NaN

def unaryCOSH(operand):
    try:
        return math.cosh(operand)
    except:
        return NaN

def unaryEXP(operand):
    try:
        return math.exp(operand)
    except:
        return NaN

def unaryLOG(operand):
    try:
        return math.log(operand)
    except:
        return NaN

def unarySIN(operand):
    try:
        return math.sin(operand)
    except:
        return NaN

def unarySINH(operand):
    try:
        return math.sinh(operand)
    except:
        return NaN

def unarySQRT(operand):
    try:
        return math.sqrt(operand)
    except:
        return NaN

def unaryTAN(operand):
    try:
        return math.tan(operand)
    except:
        return NaN

def unaryTANH(operand):
    try:
        return math.tanh(operand)
    except:
        return NaN

def unaryABVAL(vector):
    try:
        sum = 0.0
        for v in vector:
            sum += v * v
        return math.sqrt(sum)
    except:
        return NaN

def unaryDET(matrix):
    try:
        if not isMatrix(matrix) or len(matrix) != len(matrix[0]):
            return NaN
        return determinant(matrix)
    except:
        return NaN

def unaryINVERSE(matrix):
    try:
        if not isMatrix(matrix) or len(matrix) != len(matrix[0]):
            return NaN
        inverse = matrixInverse(matrix)
        if inverse == None:
            return NaN
        return inverse
    except:
        return NaN

def unaryTRACE(matrix):
    try:
        if not isMatrix(matrix) or len(matrix) != len(matrix[0]):
            return NaN
        sum = 0.0
        for i in range(len(matrix)):
            sum += matrix[i][i]
        return sum
    except:
        return NaN

def unaryTRANSPOSE(matrix):
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

def unaryUNIT(vector):
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

