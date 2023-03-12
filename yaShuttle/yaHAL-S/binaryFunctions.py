#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:  None - the author (Ron Burkey) declares this software to
            be in the Public Domain, with no rights reserved.
Filename:   binaryFunctions.py
Requires:   Python 3.7 or later.
Purpose:    A collection of functions suitable for use with the binaryOperation()
            function of the palmatAux.py module.  These are RTL functions
            and binary operators for the most part.
References: https://www.ibiblio.org/apollo/hal-s-compiler.html#PALMAT
            [HPG] HAL/S Programmer's Guide.
            [PIH] Programming in HAL/S.
History:    2023-03-08 RSB  Split off from executePALMAT.

What follows is a bunch of functions used with the binaryOperation() function.
The idea is that if you want to perform an "arrayed operation" -- i.e., you
have an array and want to perform the same action on each entry in the 
array -- then you call binaryOperation() which handles the array'ing, along
with some additional function that handles the details of the specific 
operation on any one entry of the array.  The latter are the functions 
collected here.  They all share the characteristic that they return the
result of the operation (including possibly the value Python None for 
indeterminate results due to uninitialized inputs), or else NaN on error.
"""

import math
import copy
from palmatAux import *
from unaryFunctions import matrixInverse

def identityMatrix(n):
    result = []
    for i in range(n):
        row = [0.0]*n
        row[i] = 1.0
        result.append(row)
    return result

# A building block for functions used with used with binaryOperation().  
# The idea is that you give it the following information:
#    Two operands (not ARRAY and not STRUCTURE) for the operation.
#    The operator type, in the form "+", "-", "/", etc.
#    A dictionary of allowed operand datatype pairs.
# For the dictionary, the keys are the operand1 datatype: one of the following:
# "numeric" (meaning either an integer or a scalar), "vector", or "matrix".
# The keys are lists of the allowed operand2 datatype vs operand1.  The possible
# entries in the lists are:
#    "integer"
#    "numeric" (integer or scalar)
#    "vector"  (No restriction on width)
#    "vector!" (Dimensional compatibility with operand1 for linear algebra)
#    "vector3" (Same as "vector!" but with a width of exactly 3)
#    "matrix"  (Implies dimensions identical to operand1 if operand1 is "matrix")
#    "matrix!" (Implies dimensional compatibility for linear algebra)
def compatibleArithmetic(PALMAT, operand1, operand2, opType, compatibility):
    
    # Elementary arithmetic on operands which are simple numbers.
    def elementary(operand1, operand2, op=opType):
        if op == "+":
            return operand1 + operand2
        if op == "-":
            return operand1 - operand2
        if op == "/":
            if operand2 == 0:
                return NaN
            return operand1 / operand2
        if op == "":
            return operand1 * operand2
        if op == "**":
            if operand1 == 0 and operand2 == 0:
                return NaN
            return operand1 ** operand2
        if op == "DIV":
            operand1 = hround(operand1)
            operand2 = hround(operand2)
            if operand2 == 0:
                return NaN
            value = abs(operand1) // abs(operand2)
            if operand1 * operand2 < 0:
                value = -value
            return value
        if op == "MOD":
            if operand2 == 0:
                return NaN
            value = operand1 % operand2
            if operand2 < 0:
                value -= operand2
            return value
        if op == "REMAINDER":
            operand1 = hround(operand1)
            operand2 = hround(operand2)
            if operand2 == 0:
                return NaN
            value = operand1 % operand2 
            if value != 0 and operand1 * operand2 < 0:
                value -= operand2
            return value
        if op == "ARCTAN2":
            return math.atan2(operand1, operand2)
        return NaN
    
        # Assumes the inner dimensions match and all entries are initialized (!= None)
    def matrixMultiply(a, b):
        numRows = len(a)
        numCols = len(b[0])
        numInner = len(b) # == len(a[0])
        result = []
        for i in range(numRows):
            row = []
            for j in range(numCols):
                s = 0
                for k in range(numInner):
                    r = elementary(a[i][k], b[k][j], "")
                    if isNaN(r):
                        return NaN
                    if r == None:
                        s = None
                        break
                    s += r
                row.append(s)
            result.append(row)
        return result
    
    if operand1 == None or operand2 == None:
        return None # Uninitialized value.
    
    # Check compatibility of operands.  First, find out what the compability
    # requirements for operand1 are:
    if isinstance(operand1, (int, float)) and "numeric" in compatibility:
        c1 = "numeric"
        compatibleWith = compatibility["numeric"]
        dimensions1 = []
    elif isVector(operand1) and "vector" in compatibility:
        c1 = "vector"
        compatibleWith = compatibility["vector"]
        dimensions1 = [len(operand1)]
    elif isMatrix(operand1) and "matrix" in compatibility:
        c1 = "matrix"
        compatibleWith = compatibility["matrix"]
        dimensions1 = [len(operand1), len(operand1[0])]
    else:
        return NaN
    
    # Find out if operand2 is compatible with operand1:
    dimensions2 = None
    for c2 in compatibleWith:
        if c2 == "integer" and isinstance(operand2, int):
            dimensions2 = []
            break
        elif c2 == "numeric" and isinstance(operand2, (int, float)):
            dimensions2 = []
            break
        elif    (c2 == "vector" and isVector(operand2)) or \
                (c2 == "vector!" and isVector(operand2) \
                    and dimensions1[-1] == len(operand2)) or \
                (c2 == "vector3" and isVector(operand2) \
                    and dimensions1[-1] == len(operand2) and len(operand2) == 3):
            dimensions2 = [len(operand2)]
            break
        elif    (c2 == "matrix" and isMatrix(operand2) and ( \
                    dimensions1 == [] or \
                    dimensions1 == [len(operand2), len(operand2[0])])) or \
                (c2 == "matrix!" and isMatrix(operand2) and \
                    dimensions1[-1] == len(operand2)):
            dimensions2 = [len(operand2), len(operand2[0])]
            break
    if dimensions2 == None:
        return NaN
        
    # We now have only compatible operands.  c1 and c2 tell us the operand
    # types, while dimensions1 and dimensions2 tell us the geometries.  Let's
    # perform the operation.
    result = NaN
    if c1 == "numeric" and c2 == "numeric":
        result = elementary(operand1, operand2)
    elif c1 == "numeric" and c2 == "vector":
        result = []
        for e in operand2:
            r = elementary(operand1, e)
            if isNaN(r):
                return NaN
            result.append(r)
    elif c1 == "vector" and c2 == "numeric":
        result = []
        for e in operand1:
            r = elementary(e, operand2)
            if isNaN(r):
                return NaN
            result.append(r)
    elif c1 == "numeric" and c2 == "matrix":
        result = []
        for oRow in operand2:
            row = []
            for e in oRow:
                r = elementary(operand1, e)
                if isNaN(r):
                    return NaN
                row.append(r)
            result.append(row)
    elif c1 == "matrix" and c2 == "numeric":
        result = []
        for oRow in operand1:
            row = []
            for e in oRow:
                r = elementary(e, operand2)
                if isNaN(r):
                    return NaN
                row.append(r)
            result.append(row)
    elif c1 == "vector" and c2 == "vector" and opType == "":
        result = []
        for i in range(dimensions1[0]):
            row = []
            for j in range(dimensions2[0]):
                r = elementary(operand1[i], operand2[j])
                if isNaN(r):
                    return NaN
                row.append(r)
            result.append(row)
    elif c1 == "vector" and c2 == "vector!" and opType == ".":
        result = 0
        for i in range(dimensions1[0]):
            r = elementary(operand1[i], operand2[i], "")
            if isNaN(r):
                return NaN
            if r == None:
                result = None
                break
            result += r
    elif c1 == "vector" and c2 == "vector3" and opType == "*":
        result = []
        index0 = 0
        index1 = 1
        index2 = 2
        for i in range(3):
            r = elementary(operand1[index1], operand2[index2], "")
            if isNaN(r):
                return NaN
            if r == None:
                result.append(None)
            else:
                result.append(r - elementary(operand1[index2], operand2[index1], ""))
            index0, index1, index2 = index1, index2, index0
    elif c1 == "vector" and c2 == "vector!":
        result = []
        for i in range(dimensions1[0]):
            r = elementary(operand1[i], operand2[i])
            if isNaN(r):
                return NaN
            result.append(r)
    elif c1 == "matrix" and c2 == "matrix!" and opType == "":
        result = matrixMultiply(operand1, operand2)
    elif c1 == "vector" and c2 == "matrix!" and opType == "":
        result = []
        for i in range(dimensions2[1]):
            sum = 0
            for j in range(dimensions1[0]):
                r = elementary(operand1[j], operand2[j][i])
                if isNaN(r):
                    return NaN
                if r == None:
                    sum = None
                    break
                sum += r
            result.append(sum)
    elif c1 == "matrix" and c2 == "vector!" and opType == "":
        result = []
        for i in range(dimensions1[0]):
            sum = 0
            for j in range(dimensions1[1]):
                r = elementary(operand1[i][j], operand2[j])
                if isNaN(r):
                    return NaN
                if r == None:
                    sum = None
                    break
                sum += r
            result.append(sum)
    elif c1 == "matrix" and c2 == "integer" and opType == "**":
        if dimensions1[0] != dimensions1[1]:
            result = NaN
        elif operand2 >= 1:
            result = copy.deepcopy(operand1)
            while operand2 > 1:
                operand2 -= 1
                result = matrixMultiply(result, operand1)
                if isNaN(result):
                    break
        elif not isCompletelyInitialized(operand1):
            return uninitializedComposite([], dimensions1)
        elif operand2 == 0:
            result = identityMatrix(dimensions1[0])
        elif operand2 <= -1:
            result = matrixInverse(operand1)
            if operand2 < -1:
                inverse = copy.deepcopy(inverse)
            while operand2 < -1:
                operand2 += 1
                result = matrixMultiply(result, inverse)
                if isNaN(result):
                    return NaN
    elif c1 == "matrix" and c2 == "matrix":
        result = []
        for i in range(dimensions1[0]):
            row = []
            for j in range(dimensions1[1]):
                r = elementary(operand1[i][j], operand2[i][j])
                if isNaN(r):
                    return NaN
                row.append(r)
            result.append(row)
    else:
        printError(PALMAT, source, instruction, 
            "Implementation error, cannot handle this combination of operands.")
        return None
    
    # All done!
    return result

def simpleAddition(PALMAT, operand1, operand2):
    return compatibleArithmetic(PALMAT, operand1, operand2, "+", {
        "numeric": ["numeric"], 
        "vector": ["vector!"], 
        "matrix": ["matrix"]})

def simpleSubtraction(PALMAT, operand1, operand2):
    return compatibleArithmetic(PALMAT, operand1, operand2, "-", {
        "numeric": ["numeric"], "vector": ["vector!"], "matrix": ["matrix"]})

# A binary-division operator for use with binaryOperation().  
# Returns NaN on error.
def simpleDivision(PALMAT, operand1, operand2):
    return compatibleArithmetic(PALMAT, operand1, operand2, "/", {
        "numeric": ["numeric"], 
        "vector": ["numeric"], 
        "matrix": ["numeric"]})

# A binary-multiplication operator for use with binaryOperation().  
# Returns NaN on error.
def simpleMultiplication(PALMAT, operand1, operand2):
    return compatibleArithmetic(PALMAT, operand1, operand2, "", {
        "numeric": ["numeric", "vector", "matrix"], 
        "vector": ["numeric", "vector", "matrix!"], 
        "matrix": ["numeric", "vector!", "matrix!"]} )

# A binary-multiplication operator for use with binaryOperation().  
# Returns NaN on error.
def simpleDot(PALMAT, operand1, operand2):
    return compatibleArithmetic(PALMAT, operand1, operand2, ".", \
                                {"vector": ["vector!"]} )

# A binary-multiplication operator for use with binaryOperation().  
# Returns NaN on error.
def simpleCross(PALMAT, operand1, operand2):
    return compatibleArithmetic(PALMAT, operand1, operand2, "*", \
                                {"vector": ["vector3"]} )
    
# A binary-multiplication operator for use with binaryOperation().  
# Returns NaN on error.
def simpleExponentiation(PALMAT, operand1, operand2):
    return compatibleArithmetic(PALMAT, operand1, operand2, "**", \
                            {"numeric": ["numeric"], "matrix": ["integer"]})

def simpleDIV(PALMAT, operand1, operand2):
    return compatibleArithmetic(PALMAT, operand1, operand2, "DIV", \
                                {"numeric": ["numeric"]})

def simpleMOD(PALMAT, operand1, operand2):
    return compatibleArithmetic(PALMAT, operand1, operand2, "MOD", \
                                {"numeric": ["numeric"]})

def simpleREMAINDER(PALMAT, operand1, operand2):
    return compatibleArithmetic(PALMAT, operand1, operand2, "REMAINDER", \
                                {"numeric": ["numeric"]})

def simpleARCTAN2(PALMAT, operand1, operand2):
    return compatibleArithmetic(PALMAT, operand1, operand2, "ARCTAN2", \
                                {"numeric": ["numeric"]})


# Operator names or built-in function names associated with the operation.
binaryRTL = {
    "+": [simpleAddition], 
    "-": [simpleSubtraction], 
    "": [simpleMultiplication], 
    "/": [simpleDivision], 
    "**": [simpleExponentiation], 
    ".": [simpleDot], 
    "*": [simpleCross],
    "DIV": [simpleDIV, "The divisor must be a non-zero number"],
    "MOD": [simpleMOD, "The divisor must be a non-zero number"],
    "REMAINDER": [simpleREMAINDER, "The divisor must be a non-zero number"],
    "ARCTAN2": [simpleARCTAN2],
    }

# Returns either the operation result (could be None) or NaN on failure.
def arrayableBinaryRTL(PALMAT, halsFunctionName, operand1, operand2, \
                       source, instruction):
    entry = binaryRTL[halsFunctionName]
    result = binaryOperation(PALMAT, entry[0], operand1, operand2)
    if isNaN(result):
        if len(entry) < 2:
            printError(PALMAT, source, instruction, \
                       "Incompatible operands for " + halsFunctionName)
        else:
            printError(PALMAT, source, instruction, entry[1])
        return NaN
    return result
