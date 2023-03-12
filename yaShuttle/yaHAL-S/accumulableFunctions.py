#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:  None - the author (Ron Burkey) declares this software to
            be in the Public Domain, with no rights reserved.
Filename:   accumulableFunctions.py
Requires:   Python 3.7 or later.
Purpose:    A collection of functions suitable for "accumulating"
            across a HAL/S ARRAY.  This is used for implementing 
            HAL/S functions like MAX, MIN, PROD, and SUM.
References: https://www.ibiblio.org/apollo/hal-s-compiler.html#PALMAT
            [HPG] HAL/S Programmer's Guide.
            [PIH] Programming in HAL/S.
History:    2023-03-07 RSB  Began.
"""

import math
from palmatAux import isArrayQuick, printError, NaN, isNaN

accumulableFunctions = ["MAX", "MIN", "PROD", "SUM"]
fnMAX = accumulableFunctions.index("MAX")
fnMIN = accumulableFunctions.index("MIN")
fnPROD = accumulableFunctions.index("PROD")
fnSUM = accumulableFunctions.index("SUM")

'''
The following function is used to apply a HAL/S built-in "array function"
like MAX, MIN, PROD to an array of integers and/or scalars.  The function
doesn't check the legality of the array, but merely uses the fact that 
the input object is some hierarchy of lists in which the atomic elements
are integers and/or scalars.  The accumulation parameter is a list with a 
single element, namely the "accumulated" value.  the accumulation function 
(MAX, MIN, ...) adjusts that value in place; it acts like a global variable 
throughout the recursion, but a separate invocation of accumulate() with a 
different accumation parameter wouldn't conflict with it.
The accumulation can either be initialized to an appriate value before 
entry (such as 0.0 for SUM or 1.0 for PROD), or it can be set to None (i.e.,
accumulation = [None]), in which case the very first atomic array element
encountered is used.  

The function also returns accumulation[0], or else NaN upon failure.
'''
def accumulate(PALMAT, array, halsFunctionName, source, instruction, \
               initial=True, accumulation=[None]):
    
    def prod(x, y):
        return x * y
    
    def sum(x, y):
        return x + y
    
    if initial:
        accumulation = [None]
    
    try:
        if halsFunctionName == "MAX":
            function = max
        elif halsFunctionName == "MIN":
            function = min
        elif halsFunctionName == "PROD":
            function = prod
        elif halsFunctionName == "SUM":
            function = sum
            
        if isArrayQuick(array):
            for e in array[:-1]:
                if isNaN(accumulate(PALMAT, e, halsFunctionName, source, \
                                    instruction, False, accumulation)):
                    raise Exception("")
        
        elif accumulation[0] == None:
            if array == None:
                raise Exception("")
            accumulation[0] = array
        
        else:
            accumulation[0] = function(accumulation[0], array)
            
    except:
        printError(PALMAT, source, instruction, \
                   "Cannot compute array function " + halsFunctionName)
        return NaN
    
    return accumulation[0]
