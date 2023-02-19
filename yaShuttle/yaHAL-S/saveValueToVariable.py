#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:  None - the author (Ron Burkey) declares this software to
            be in the Public Domain, with no rights reserved.
Filename:   saveValueToVariable.py
Purpose:    Module for inclusion in the executePALMAT module of the preliminary
            implementation of the HAL/S compiler.  This module is used for 
            assigning a value to a variable, possibly with subscripts, and the
            automatic datatype conversions needed as a part of that.
References: [HPG] HAL/S Programmer's Guide.
            [PIH] Programming in HAL/S.
History:    2023-02-18 RSB  Began.
"""

from palmatAux import formBitArray, parseBitArray, hround, fpFormat, \
                      formatNumberAsString, isBitArray, stringifiedToFloat

'''
-------------------------------------------------------------------------------
This function converts "simple" values (None, INTEGER, SCALAR, BIT, CHARACTER) 
between datatypes.  The converted value is just returned from the function.
The value None is interpreted as "do not change", and is simply passed through
as-is.  Returns False on failure.

As far as the arguments are concerned:
    value       The "simple" value to convert.
    datatype    The desired datatype of the converted value ("integer", ...).
    datalength  If datatype is "bit" or "character", then the declared maximum
                bit-string or character-string length of the converted value.
                Otherwise ignored.
'''
def convertSimple(value, datatype, datalength):
    if value == None:
        return None
    elif isinstance(value, int):
        if datatype == "integer":
            return value
        elif datatype == "scalar":
            return float(value)
        elif datatype == "bit":
            return formBitArray(value, datalength)
        elif datatype == "character":
            s = formatNumberAsString(value)
            if len(s) > datalength:
                return False
            return s
    elif isinstance(value, float):
        if datatype == "integer":
            return hround(value)
        elif datatype == "scalar":
            return value
        elif datatype == "bit":
            # HAL/S doesn't allow SCALAR -> BIT(...).  I do.
            return formBitArray(hround(value), datalength)
        elif datatype == "character":
            s = formatNumberAsString(value)
            if len(s) > datalength:
                return False
            return s
    elif isinstance(value, str):
        try:
            if datatype == "integer":
                return hround(stringifiedToFloat(value))
            elif datatype == "scalar":
                return stringifiedToFloat(value)
            elif datatype == "character":
                return value[:datalength]
            elif datatype == "bit":
                # From [HPG] Appendix A, to be convertable to a bit-string, a
                # a character-string must consist of 1's, 0's, and
                # blanks, but not *all* blanks.
                value = int(value.replace(" ", ""), 2)
                return formBitArray(value, datalength)
        except:
            return False
    elif isBitArray(value):
        value, dummy = parseBitArray(value)
        if datatype == "integer":
            return value
        elif datatype == "scalar":
            return float(value)
        elif datatype == "bit":
            return formBitArray(value, datalength)
        elif datatype == "character":
            # HAL/S does not allow this conversion.  I do.
            s = bin(value)[2:]
            if len(s) > datalength:
                return False
            return s
    return False

'''
# Some tests for convertSimple(). 
testValues = [None, 1, 2.0, [3, 5, "b"], "4", "5.0B2E-7", "1110010"]
testDatatypes = ["integer", "scalar", "bit", "character"]
testDatalengths = [0, 0, 7, 25]
for i in range(len(testValues)):
    value = testValues[i]
    print(value, ":")
    for j in range(len(testDatatypes)):
        converted = convertSimple(value, testDatatypes[j], testDatalengths[j])
        print("\t->\t", converted, testDatatypes[j], testDatalengths[j])
import sys
sys.exit(1)
'''

'''
------------------------------------------------------------------------------
Returns True on success, False on failure.  The inputs are:
    source        The list [filenumber, linenumber, columnnumber] cross 
                  referencing this instruction to the source code.
    value         The value that's supposed to be assigned to the variable.
                  This value must have geometric and datatype characteristics
                  consistent with the portion of the target variable picked out
                  by the subscripts (if any).
    identifier    The identifier (mangled if appropriate, but not 
                  carat-quoted) associated with the variable to
                  which we want to assign the value.
    attributes    The attributes of the identifier of the variable, already 
                  looked up for us.  (We don't actually need the actual 
                  identifier any longer, except for creating error messages.)
    subscripts    The subscripts to be applied to the target variable.
'''
def saveValueToVariable(source, value, identifier, attributes, subscripts=[]):
    '''
    First determine the relevant characteristics of the target variable
    to which the given value is supposed to be assigned.
        isArray                 True if is an array, false otherwise.
        primaryDimensions       ARRAY dimensions (if variable is an ARRAY), 
                                or VECTOR/MATRIX dimensions otherwise (variable
                                is a VECTOR or MATRIX).
        secondaryDimensions     If variable is ARRAY(...) VECTOR or 
                                ARRAY(...), the VECTOR/MATRIX dimensions.
        fullDimensions          Concatenation of primaryDimensions and 
                                secondaryDimensions.
        datatype                Datatype of the target variable as subscripted
                                to fullDimensions.  In other words, integer, 
                                scalar, bit, or character.
        datalength              Max size of bit or character string, or -1
                                if datatype is neither bit nor character.
    '''
    isArray = "array" in attributes;
    primaryDimensions = []
    secondaryDimensions = []
    datatype = ""
    datalength = -1
    if "vector" in attributes:
        primaryDimensions = [attributes["vector"]]
    elif "matrix" in attributes:
        primaryDimensions = attributes["matrix"]
    if isARRAY:
        secondaryDimensions = primaryDimensions
        primaryDimensions = attributes["array"]
    if "bit" in attributes:
        datatype = "bit"
        datalength = attributes["bit"]
    elif "character" in attributes:
        datatype = "character"
        datalength = attributes["character"]
    elif "integer" in attributes:
        datatype = "integer"
    elif "scalar" in attributes or "vector" in attributes \
            or "matrix" in attributes:
        datatype = "scalar"
    else:
        printError(source, "", \
            "Assignments of this datatype (to variable %s) not yet implemented"\
            % identifier)
        return False
    '''
    Now determine the relevant macro characteristics of the value to store.
    These are the variables, but the descriptions are the same as the 
    similarly-named items above.
             isArray2
             primaryDimensions2
             secondaryDimensions2
             fullDimensions2
             datatype2
             datalength2
    '''
    isArray2 = False
    primaryDimensions2 = []
    secondaryDimensions2 = []
    dimensions = primaryDimensions2
    datatype2 = ""
    datalength2 = -1
    if isArrayQuick(value):
        # If the value is an ARRAY, this step quickly determines what the 
        # ARRAY dimensions must be, but without checking that that it actually
        # is an ARRAY.
        dummy = value
        while isArrayQuick(dummy):
            dimensions.append(len(dummy)-1)
            dummy = dummy[0]
        # Now check that the value really is an ARRAY with these dimensions ...
        # geometrically at least.  There's no check that the array's elements
        # all have the same (or compatible) datatypes.
        if not isArrayGeometry(value, dimensions):
            printError(source, "", \
                "Implementation error, value of unsupported datatype cannot be assigned to variable %s"\
                % identifier)
            return False
        isArray2 = True
        dimensions = secondaryDimensions2
    if value == None:
        datatype2 = "unassigned"
    elif isVector(value):
        datatype2 = "scalar"
        dimensions.append(len(value))
    elif isMatrix(value):
        datatype2 = "scalar"
        dimensions.append(len(value))
        dimensions.append(len(value[0]))
    elif isBitArray(value):
        datatype2 = "bit"
        dummy, datalength2 = parseBitArray(value)
    elif isinstance(value, str):
        datatype2 = "character"
        datalength2 = len(value)
    elif isinstance(value, int):
        datatype2 = "integer"
    elif isinstance(value, float):
        datatype2 = "scalar"
    else:
        printError(source, "", \
                   "Not a presently-assignable datatype for variable %s." \
                   % identifier)
        return False
    #--------------------------------------------------------------------------
    # Determine compatibility of composite-type geometries and subscripts.
    # I.e., we want to make sure that every element of the (subscripted) LHS
    # corresponds to a an object of the corresponding geometry (including 
    # ARRAY vs VECTOR/MATRIX) on the RHS.
    fullDimensions = primaryDimensions + secondaryDimensions
    fullDimensions2 = primaryDimensions2 + secondaryDimensions2
    for i in range(len(subscripts)):
        if subscripts[i] < 1 or subscripts[i] > fullDimensions[i]:
            printError(source, "", "Subscript out of range in LHS variable.")
            return False
    fullAssignment = False # Assigns full object to full object
    halfAssignment = False # Assigns value to an array element.
    leafAssignment = False # Assigns value to an element of an array element.
    if len(subscripts) == 0 and isArray == isArray2 and \
            primaryDimensions == primaryDimensions2 and \
            secondaryDimensions == secondaryDimensions2:
        fullAssignment = True
    elif len(subscripts) != 0 and len(subscripts) == len(primaryDimensions) \
            and not isArray2 and secondaryDimensions == primaryDimensions2 \
            and len(secondaryDimensions2) == 0:
        halfAssignment = True
    elif len(subscripts) != 0 and len(subscripts) == len(fullDimensions) and \
            len(fullDimensions2) == 0:
        leafAssignment = True
    else:
        printError(source, "", "Geometry mismatch in assignment.")
        return False
    #--------------------------------------------------------------------------
    # At this point the geometries of the assignments and assignees are 
    # known to be compatible. 
    
    return True
