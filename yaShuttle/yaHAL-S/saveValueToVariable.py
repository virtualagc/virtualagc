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
History:    2023-02-18 RSB  Began.  This is essentially a complete, improved
                            replacement for the assignment code previously in
                            executePALMAT.py, but extended to handle lots of
                            cases that were impossible or very problematic in
                            the older code, such as partition slices and more
                            automatic type conversion.  Still does not handle
                            STRUCTUREs, but hopefully they can be added.
"""

from palmatAux import *

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

# In a composite datatype (VECTOR, MATRIX, ARRAY, ARRAY VECTOR, ARRAY MATRIX),
# perform a conversion on a leaf.  Basically these are all of the HAL/S 
# datatypes, other than bit-strings, implemented as Python lists in the
# HAL/S->PALMAT compiler.  The conversion is in-place.  Returns True
# on success, False on failure.  Note that there's no checking that the input
# (composite) is actually a list type.
def convertComposite(composite, datatype, datalength):
    for i in range(len(composite)):
        value = composite[i]
        if isinstance(value, list) and not isBitArray(value):
            if convertComposite(value, datatype, datalength) == False:
                return False
        else:
            composite[i] = convertSimple(value, datatype, datalength)
            if composite[i] == False:
                return False
    return True

# The function assigns a simple value to a subscripted composite variable.  
# It has already been checked that the geometries are compatible.  The only
# unusual paramter is indices, which is a list (over dimensions) of lists
# (of the indices to be used in the variable at that dimension).  
# The assignment is done directly in the attributes, leaving untouched any
# indices not in the indices list.  Returns True on success, False on failure.
def assignSimpleSubscripted(value, valueInAttributes, indices, \
                            datatype, datalength):
    if value == None: # Don't change anything!
        return True
    # Note that since value is not composite and the geometries have already
    # been checked, then we must have len(indices[i])== 1 for each i.
    index = indices[0][0] - 1;  # Recall HAL/S indexes from 1, Python from 0.
    if len(indices) == 1:
        converted = convertSimple(value, datatype, datalength)
        if converted == False:
            return False
        valueInAttributes[index] = converted
        return True
    return assignSimpleSubscripted(value, valueInAttributes[index], \
                                        indices[1:], datatype, datalength)

# Same as assignSimpleSubscripted(), but when the value (and hence the 
# variable after subscripting) is composite.  The principal difficulty, as 
# noted in the comments below, is working around cases where one side of the
# assignment has a dimensionality of (say) [1, 2, 1, 1, 3], while the other 
# side has a dimensionality of (say) with [2, 1, 3, 1].  Both are ultimately
# 2x3 objects, but looping through them is very different.
def assignCompositeSubscripted(value, valueInAttributes, indices, \
                               datatype, datalength):
    # TBD
    return False

'''
------------------------------------------------------------------------------
Assignment of a value to a variable, possibly subscripted.
Returns True on success, False on failure.  The inputs are:
    source      The list [filenumber, linenumber, columnnumber] cross 
                referencing this instruction to the source code.
    value       The value that's supposed to be assigned to the variable.
                This value must have geometric and datatype characteristics
                consistent with the portion of the target variable picked out
                by the subscripts (if any).
    identifier  The identifier (mangled if appropriate, but not 
                carat-quoted) associated with the variable to
                which we want to assign the value.
    attributes  The attributes of the variable, already 
                looked up for us.  (We don't actually need the actual 
                identifier any longer, except for creating error messages.)
    subscripts  The subscripts to be applied to the target variable.  Note
                that some of the subscripts may represent slicing.
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
    if isArray:
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
                "Implementation error, value of unsupported datatype " + \
                "cannot be assigned to variable %s"\
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
    # I'm not sure how to cleanly fit the case of no subscripts into an 
    # implementation of the most-general case, so handle it explicitly now.
    if len(subscripts) == 0:
        # Are the geometries of the variable and value the same?
        if isArray != isArray2 or \
                primaryDimensions != primaryDimensions2 or \
                secondaryDimensions != secondaryDimensions2:
            printError(source, "", \
                "Incompatible geometries in assignment of variable %s" \
                % identifier)
            return False
        '''
        First we have the absolutely simplest case:  a simple value being
        assigned to a non-subscripted variable of a simple datatype.
        '''
        if len(primaryDimensions) == 0:
            converted = convertSimple(value, datatype, datalength)
            if converted == False:
                printError(source, "", \
                    "Incompatible datatypes in assignment of variable %s: %s" \
                    % (identifier, str(value)))
                return False
            attributes["value"] = converted
            return True
        '''
        Here's the next-to-simplest case: A composite value being assigned to
        an unsubscripted composite variable of the same geometry (both array 
        geometry, if any, and vector/matrix geometry, if any).  It's more 
        complex than the simple-to-simple assignment we just did, because the 
        leaf elements being assigned may require conversions of different types.
        We use a recursive function to descend to all of the leaves.
        '''
        composite = copy.deepcopy(value)
        if convertComposite(composite, datatype, datalength) == False:
            printError(source, "", \
                "Incompatible datatypes in assignment of composite variable %s"\
                % (identifier))
            return False
        attributes["value"] = composite
        return True
    '''
    ---------------------------------------------------------------------------
    So now we have the case of a subscripted variable having a value assigned
    to it ... with the possibility of some of the subscripts representing slices
    instead of individual values.  Thus there may be some very-complex 
    geometries indeed.  Fortunately, the full geometry of the value is known,
    and we only need to determine the geometry of the variable as subscripted.
    Let's first form a structure that for every dimension of the subscripted 
    variable tells us all of the indices are involved.
    '''
    dimensionsOfVariable = primaryDimensions + secondaryDimensions
    dimensionsOfValue = primaryDimensions2 + secondaryDimensions2
    indicesAllowed = []
    for i in range(len(subscripts)):
        subscript = subscripts[i]
        width = dimensionsOfVariable[i]
        if subscript == {"fill"}:
            indicesAllowed.append(list(range(1, width+1)))
        elif isinstance(subscript, int):
            indicesAllowed.append([unpound(subscript, width)])
        elif isinstance(subscript, float):
            indicesAllowed.append([unpound(hround(subscript), width)])
        elif isinstance(subscript, list): # AT
            s1 = unpound(subscript[1], width)
            indicesAllowed.append(list(range(s1, s1 + subscript[0])))
        elif isinstance(subscript, tuple): # TO
            indicesAllowed.append(list(range(unpound(subscript[0], width), \
                                             unpound(subscript[1], width)+1)))
        else:
            printError(source, "", \
                       "Implementation error, unknown subscript type.")
            return False
    for i in range(len(indicesAllowed)): # Double-check
        indices = indicesAllowed[i]
        if indices[0] < 1 or indices[-1] > dimensionsOfVariable[i]:
            printError(source, "", "Subscript(s) out of range.")
            return False
    for i in range(len(subscripts), len(dimensionsOfVariable)):
        indicesAllowed.append(list(range(1, dimensionsOfVariable[i] + 1)))
    # Finally, the geometry of the subscripted variable:
    dimensionsOfSubscriptedVariable = []
    for i in indicesAllowed:
        if isinstance(i, list):
            dimensionsOfSubscriptedVariable.append(len(i))
    '''
    The following is a test for compatibility of geometries on the RHS and 
    LHS of the assignment.  It's not as straightforward as it may initially
    seem, because we can have cases like an LHS with a geometry of 
    [1, 2, 1, 1, 3] and RHS with [2, 1, 3, 1] ... which are really both just
    2x3 arrays or matrices, but not obviously so.  So we have to weed out the 
    1's in the dimensional arrays before comparing the RHS and LHS geometries.
    '''
    dSV = []
    for d in dimensionsOfSubscriptedVariable:
        if d != 1:
            dSV.append(d)
    dV = []
    for d in dimensionsOfValue:
        if d != 1:
            dV.append(d)
    if dSV != dV:
        printError(source, "", \
            "Geometry mismatch in assignment of %s%s: %s != %s" % \
            (identifier, str(subscripts), dimensionsOfSubscriptedVariable,
             dimensionsOfValue))
        return False
    '''
    As for the actual assignment itself, there are two cases.  If value is 
    not itself a composite, vs if both the LHS and RHS are composites.
    We have to handle those separately, simply because I didn't see how to 
    write just a single elegant implementation of both.
    '''
    if len(dimensionsOfValue) == 0:
        if False == assignSimpleSubscripted(value, attributes["value"], \
                                            indicesAllowed, 
                                            datatype, datalength):
            printError(source, "", \
                "Conversion error in assignement of %s%s" % \
                (identifier, subscripts))
            return False
    else:
        if False == assignCompositeSubscripted(value, attributes["value"], \
                                               indicesAllowed, 
                                               datatype, datalength):
            printError(source, "", \
                "Conversion error in assignement of %s%s" % \
                (identifier, subscripts))
            return False
    
    return True
