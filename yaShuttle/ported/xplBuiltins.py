#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   xplBuiltins.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  It contains what might be thought of as the
            global variables accessible by all other source files.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-07 RSB  Split the former g.py into two files, this one
                            (xplBuiltins.py) containing just functions, and g.py
                            (which continues to contain all of the variables
                            and constants).
'''

import sys
import os
import pathlib
from time import time_ns
from datetime import datetime
from decimal import Decimal, ROUND_HALF_UP
import json
import math
import ebcdic

# This is the root directory for imports.
scriptFolder = os.path.dirname(__file__)  # Requires / at the end.
scriptParentFolder = str(pathlib.Path(scriptFolder).parent.absolute())

outUTF8 = ("--utf8" in sys.argv[1:])


# Python's native round() function uses a silly method (in the sense that it is
# unlike the expectation of every programmer who ever lived) called 'banker's
# rounding', wherein half-integers sometimes round up and sometimes
# round down.  Good for bankers, I suppose, because rounding errors tend to
# sum to zero, but no help whatever for us.  Instead, hround() rounds
# half-integers upward.  Returns None on error.
def hround(x):
    try:
        i = int(Decimal(x).to_integral_value(rounding=ROUND_HALF_UP))
    except:
        # x wasn't a number.
        return None
    return i

'''
The following stuff is for converting back and forth from Python
numerical values to System/360 double-precision (64-bit) floating 
point.

The IBM documentation I've seen for the floating-point format
is pure garbage.  Fortunately, wikipedia ("IBM hexadecimal 
floating-point") explains it very simply.  Here's what it looks 
like in terms of 8 groups of 8 bits each:
    SEEEEEEE FFFFFFFF FFFFFFFF ... FFFFFFFF
where S is the sign, E is the exponent, and F is the fraction.
Single precision (32-bit) is the same, but with only 3 F-groups. 
The exponent is a power of 16, biased by 64, and thus represents
16**-64 through 16**63. The fraction is an unsigned number, of
which the leftmost bit represents 1/2, the next bit represents
1/4, and so on. 

As a special case, 0 is encoded as all zeroes.

E.g., the 64-bit hexadecimal pair 0x42640000 0x00000000 parses as:
    S = 0 (i.e., positive)
    Exponent = 16**(0x42-0x40) = 16**2 = 2**8.
    Fraction = 0.0110 0100 ...
or in total, 1100100 (binary), or 100 decimal.
'''
twoTo56 = 2 ** 56
twoTo52 = 2 ** 52


# Convert a Python integer or float to IBM double-precision float.  
# Returns as a pair (msw,lsw), each of which are 32-bit integers,
# or (0xff000000,0x00000000) on error.
def toFloatIBM(x):
    d = float(x)
    if d == 0:
        return 0x00000000, 0x00000000
    # Make x positive but preserve the sign as a bit flag.
    if d < 0:
        s = 1
        d = -d
    else:
        s = 0
    # Shift left by 24 bits.
    d *= twoTo56
    # Find the exponent (biased by 64) as a power of 16:
    e = 64
    while d < twoTo52:
        e -= 1
        d *= 16
    while d >= twoTo56:
        e += 1
        d /= 16
    if e < 0:
        e = 0
    if e > 127:
        return 0xff000000, 0x00000000
    # x should now be in the right range, so lets just turn it into an integer.
    f = hround(d)
    # Convert to a more-significant and less-significant 32-word:
    msw = (s << 31) | (e << 24) | (f >> 32)
    lsw = f & 0xffffffff
    return msw, lsw


# Inverse of toFloatIBM(): Converts more-significant and less-significant 
# 32-bit words of an IBM DP float to a Python float.
def fromFloatIBM(msw, lsw):
    s = (msw >> 31) & 1
    e = ((msw >> 24) & 0x7f) - 64
    f = ((msw & 0x00ffffff) << 32) | (lsw & 0xffffffff)
    x = f * (16 ** e) / twoTo56
    if s != 0:
        x = -x
    return x

'''
# Test of the IBM float conversions.  Note that aside from showing that
# toFloatIBM() and fromFloatIBM() are inverses, it also reproduces the 
# known value 100 -> 0x42640000,0x00000000.
for s in range(-1, 2, 2):
    for e in range(-10, 11):
        x = s * 10 ** e
        msw, lsw = toFloatIBM(x)
        y = fromFloatIBM(msw, lsw)
        print(x, "0x%08x,0x%08x" % (msw, lsw), y)
'''

#------------------------------------------------------------------------------
# Here's some stuff intended to functionally replace some of XPL's 'implicitly
# declared' functions and variables while retaining roughly the same syntax.

# Here's are lists of all open "devices", by their "device number". If the 
# device isn't open, then the entry in the inputDevices[] and/or outputDevices[] 
# array(s) is a Python None.  Note that the behavior of output devices 0 and 1
# (both stdout) are hard-coded in the OUTPUT function and bypass the 
# inputDevices[] list entirely.
#
# When there is Python file associated with the device, the value will be a
# Python dictionary structured as follows:
#    {
#        "file":     The associated Python file object,
#        "open":     Boolean (True if open, False if closed),
#        "pds":      For PDS datasets only.  If "pds" isn't present, then the 
#                    file is a flat sequential dataset.  The value is the
#                    entire contents of the file (whether input or output)
#                    as a Python dictionary whose keys are the member names
#                    (each exactly 8 characters, right padded with spaces) and
#                    whose values are Python lists of strings.
#        "buf":      For a sequential file (either input or output), the 
#                    entire contents of the file, buffered as a list of strings.
#                    For a PDS file, the entire contents of the currently
#                    selected member, buffered as a list of strings.  In the
#                    case of a PDS *output* file, the buffer will not be 
#                    physically written to the file until an appropriate call
#                    to MONITOR(1, ...) occurs.
#        "mem":      For a PDS file, the member name last found by 
#                    MONITOR(2).  Not used for a flat sequential file.
#        "ptr":      The index of the last line returned by an INPUT();
#                    for a "buf" it's the index within the file as a whole,
#                    while for a "pds" it's the index within the member,
#    }
# For "pds", the dictionary keys are "member names", each of which is 
# precisely 8 characters long (including padding by spaces on the right).  
# The value associated with a member key is the entire contents of that member 
# as a list of strings.

maxDevices = 10
inputDevices = [None] * maxDevices
outputDevices = [None] * maxDevices


def openGenericInputDevice(name, isPDS=False, rw=False):
    if rw:
        mode = "r+"
    else:
        mode = "r"
    try:
        f = open(name, mode)
    except:
        f = open(scriptParentFolder + "/" + name, mode)
    inputDevice = {
        "file": f,
        "open": True,
        "ptr":-1,
        "buf": []
        }
    if isPDS:
        inputDevice["pds"] = json.load(f)
        inputDevice["mem"] = ""
    return inputDevice

    
def openGenericOutputDevice(name, isPDS=False):
    outputDevice = {
        "file": open(scriptParentFolder + "/" + name, "w"),
        "open": True,
        "ptr":-1,
        "buf": []
        }
    if isPDS:
        outputDevice["pds"] = {}
    return outputDevice

if "--help" not in sys.argv:
    # Note that while textual-data files (the "buf" and "pds" files from above)
    # are handled by the INPUT(...)/OUTPUT(...) mechanism, random-access files
    # are handled by the entirely-different FILE() method. Thus random-access files
    # do not appear in inputDevices[] and outputDevices[] above, but rather in
    # files[] below.  And although all are accessed by "file number", with the 
    # file numbers overlapping all three of these cases, the individual files of
    # the same file-number differ essentially entirely.  The entries of the files[] 
    # array are 3-lists of the open random-access file pointer, the record size, 
    # and the current file size (in bytes).
    files = [None]
    for i in range(1, 7):
        f = open(scriptParentFolder + "/FILE%d.bin" % i, "w+b")
        f.seek(2, 0)
        files.append([f, 7200, f.tell()])
    
def SHL(a, b):
    return a << b


def SHR(a, b):
    return a >> b


# Some of the MONITOR calls are listed beginning on PDF p. 826 of the "HAL/S-FC
# & HAL/S-360 Compiler System Program Description" (IR-182-1).  Note that the
# only function numbers actually appearing in the source code are:
#    0-10, 12, 13, 15-18, 21-23, 31-32
# The latter two aren't mentioned in the documentation.  On the other hand,
# the file MONITOR.ASM contains the code (unfortunately in IBM Basic Assembly
# Language, BAL) that handles all calls to MONITOR(), beginning at line 2644.
# Unfortunately, the BAL code is rather opaque to those of us who understand
# neither BAL nor the runtime environment provided by the these old IBM 
# computers.  There are some comments in the BAL code, however, which may
# provide a little more insight than provided by the non-comments in the 
# IR-182.1, so I've brought those comments over into the code below.
compilerStartTime = time_ns()
dwArea = None
compilationReturnBits = 0
namePassedToCompiler = ""

redirections = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]  # For MONITOR(8).


def MONITOR(function, arg2=None, arg3=None):
    global inputDevices, outputDevices, dwArea, compilationReturnBits, \
            namePassedToCompiler, files, redirections
    
    def error(msg=''):
        if len(msg) > 0:
            msg = '(' + msg + ') '
        print("\nError %sin MONITOR(%s,%s,%s)" % \
              (msg, str(function), str(arg2), str(arg3)), file=sys.stderr)
        sys.exit(1)
    
    def close(n):
        global outputDevices
        device = outputDevices[n]
        if isinstance(device, list) and "open" in device and device["open"]: 
            device["file"].close()
            device["open"] = False
        else:
            # print("\nTrying to close device %d, which is not open" % n)
            pass
    
    # Close an OUTPUT file.
    if function == 0: 
        n = arg2
        close(n)
    
    # Stow function.
    elif function == 1:
        n = arg2
        member = arg3
        device = outputDevices[n]
        if device == None or not device["open"]:
            error("not open")
        if "pds" not in device:
            error("not PDS")
        file = device["file"]
        pds = device["pds"]
        if member in pds:
            returnValue = 1
        else:
            returnValue = 0
        pds[member] = device["buf"]
        device["buf"] = []
        file.seek(0)
        j = json.dump(pds, file, indent=4)
        file.flush()
        file.truncate()
        file.flush()
        return returnValue
    
    # FIND-prepare for PDS INPUT.
    elif function == 2:
        redirect = redirections[arg2]
        temporary = redirect & 0x80000000
        n = redirect & 0x7FFFFFFF
        member = arg3
        if temporary:
            file = outputDevices[n]
        else:
            file = inputDevices[n]
        if "pds" not in file:
            error("not PDS")
        if member in file["pds"]:
            file["mem"] = member
            file["ptr"] = -1
            return 0
        return 1
    
    # Close an INPUT file.
    elif function == 3: 
        redirect = redirections[arg2]
        temporary = redirect & 0x8000000
        n = redirect & 0x7FFFFFFF
        redirections[arg2] = arg2
        if temporary:
            return
        close(n)
    
    # Change FILE blocking.
    elif function == 4:
        # Change block size of a random-access file.
        files[arg2][1] = arg3
    
    # Set up for floating point package.
    elif function == 5:
        # arg2 must be an array of 32-bit integers.
        dwArea = arg2
    
    # GETMAIN for pointer variable.
    elif function == 6:
        # This won't be right if the based variable is anything other than 
        # FIXED ... say if it's strings or multiple fields.  But it does add
        # at least as many array elements as needed.  Any other errors will 
        # have to be caught downstream, since there's simply not enough info
        # supplied to take care of it here.
        array = arg2
        n = arg3
        try:
            while len(array) < n:
                array.append(0)
            return 0
        except:
            error()
    
    # FREEMAIN pointer variable storage
    elif function == 7:
        array = arg2
        n = arg3
        try:
            while n > 0:
                array.pop(-1)
        except:
            error()
    
    # Set PDS DDNAME.
    elif function == 8:
        # Function 8 is not covered by any documentation available to me.
        # (Well, IR-182-1 says it's "not used" and will cause an ABEND.)
        # At any rate, I'm guessing somewhat.
        fileno = arg2
        filenum = arg3
        if fileno < 1 or fileno >= maxDevices or \
                filenum < 1 or (filenum & 0x7FFFFFFF) >= maxDevices:
            error("Illegal FILENO or FILENUM in MONITOR(8)")
        redirections[fileno] = filenum
    
    # Compile-time eval of floating point
    elif function == 9:
        '''
        This is a bit confusing, so let me try to summarize my understanding of
        it.  There are no built-in floating-point operations in XPL nor 
        (apparently) in the 360 CPU, so they're handled in a roundabout way via
        the MONITOR(5,...) and MONITOR(9,...) calls.  MONITOR(5) sets ups a 
        working array in which to hold floating-point operands and results.
        The values are stored in IBM DP floating-point format, each of which
        requires 2 32-bit words, 1 for the most-significant part and 1 for the 
        less-significant part.  The first two entries in the working area
        specified by MONITOR(5) comprise operand0 (and the result), while the 
        second two entries comprise operand1 (if needed). 
        '''
        if dwArea == None:
            print("\nNo MONITOR(5) prior to MONITOR(9)", file=sys.stderr)
            exit(1)
        op = arg2
        try:
            # Get operands from the defined working area, and convert them
            # from IBM floating point to Python floats.
            value0 = fromFloatIBM(dwArea[0], dwArea[1])
            value1 = fromFloatIBM(dwArea[2], dwArea[3])
            # Perform the binary operations.
            if op == 1:
                value0 += value1
            elif op == 2:
                value0 -= value1
            elif op == 3:
                value0 *= value1
            elif op == 4:
                value0 /= value1
            elif op == 5:
                value0 = pow(value0, value1)
            # Or perform the unary operations, which are all trig functions.
            # Unfortunately, the documentation doesn't specify the angular 
            # units.  I assume they're radians.
            elif op == 6:
                value0 = math.sin(value0)
            elif op == 7:
                value0 = math.cos(value0)
            elif op == 8:
                value0 = math.tan(value0)
            elif op == 9:
                value0 = math.exp(value0)
            elif op == 10:
                value0 = math.log(value0)
            elif op == 11:
                value0 = math.sqrt(value0)
            else:
                return 1
            # Convert the result back to IBM floats, and store in working area.
            dwArea[0], dwArea[1] = toFloatIBM(value0)
            return 0
        except:
            return 1
    
    # Character to floating-point conversion.
    elif function == 10:
        if dwArea == None:
            print("\nNo MONITOR(5) prior to MONITOR(10)", file=sys.stderr)
            exit(1)
        s = arg2
        try:
            dwArea[0], dwArea[1] = toFloatIBM(float(s))
            return 0
        except:
            return 1
    
    # Not supported
    elif function == 11:
        error("Call to MONITOR(11)")
    
    # Floating-point to character conversion.
    elif function == 12:
        p = arg2  # 0 for SP, 8 for DP
        value = fromFloatIBM(dwArea[0], dwArea[1])
        '''
        The "standard" HAL format for floating-point numbers is described on 
        p. 8-3 of "Programming in HAL/S", though unfortunately the number of
        significant digits provided for SP vs DP is not specified and is simply
        said to be implementation dependent.  To summarize the format:
            0.0:        Printed as " 0.0" (notice the leading space.
            Positive:   Printed as " d.ddd...E±ee"
            Negative:   Printed as "-d.ddd...E±ee"
        Given that 2**24 = 16777216 (8 digits) and 2**56 = 72057594037927936
        (17 digits), it should be the case that SP and DP are *fully* accurate
        only to 7 digits and 16 digits respectively.  Moreover, there is always
        exactly 1 digit (non-zero) to the left of the decimal point.  Therefore,
        for SP and DP, it would be reasonable to have 6 and 15 digits to the
        right of the decimal point respectively. (See also yaHAL-S/palmatAux.py.)
        '''
        if value == 0.0:
            return " 0.0"
        if p == 0:
            fpFormat = "%+2.6e"
        else:
            fpFormat = "%+2.15e"
        value = fpFormat % value
        if value[:1] == "+":
            value = " " + value[1:]
        value = value.replace("e", "E")
        return value
    
    # For options passing.
    elif function == 13:
        # Unneeded
        return 0
    
    # For SDF handling.
    elif function == 14:
        # TBD
        pass
    
    # PDS member revision level ind & cat number.
    elif function == 15:
        # The documentation (section 13.3 of IR-182-1) isn't entirely
        # clear to me.  The way the calling software uses the returned
        # value implies to me that while the return is a 32-bit
        # integer, its upper halfword is treated as a string
        # consisting of a two EBCDIC characters, while the lower
        # halfword is treated as a short integer.  However,
        # I still don't understand where the data is supposed to 
        # come from.
        return 0xF0F10000
    
    # Incorporate flags into return code.
    elif function == 16:
        try:
            orFlag = 0x80 & arg2
            code = 0x7F & arg2
            if orFlag:
                compilationReturnBits |= code
            else:
                compilationReturnBits = code
        except:
            error()
    
    # Set compilation characteristic name
    elif function == 17:
        namePassedToCompiler = arg2
    
    # Get current task elapsed time
    elif function == 18:
        return (time_ns() - compilerStartTime) // 10000000
    
    # GETMAIN a list of areas
    elif function == 19:
        # TBD
        pass
    
    # FREEMAIN a list of areas
    elif function == 20:
        # TBD
        pass
    
    # Determine how much core is left
    elif function == 21:
        return 1000000000
    
    # Calls to the SDF access package.
    elif function == 22:
        pass
    
    # Return program identification.
    elif function == 23:
        return "REL32V0   "
    
    # Read a block of a load module.
    elif function == 24:
        # TBD
        pass
    
    # Read a mass-memory load block.
    elif function == 25:
        # TBD
        pass
    
    # Read a MAF (memory analysis file) block
    elif function == 26:
        # TBD
        pass
    
    # Write a MAF block
    elif function == 27:
        # TBD
        pass
    
    # Link to dump analysis service routine
    elif function == 28:
        # TBD
        pass
    
    # Return current page number
    elif function == 29:
        # TBD
        return 0
    
    # Return JFCB as string
    elif function == 30:
        # TBD
        pass
    
    # Virtual-memory lookahead service.
    elif function == 31:
        pass
    
    # Find out subpool minimum size.  (Actually, MONITOR.ASM says "monimum".
    # I assume that's an error, but perhaps it's correct and just too witty for
    # me to understand.)
    elif function == 32:  # Returns the 'storage increment', whatever that may be.
        return 16384
    
    # Find out FILE max REC# and BLKSIZ.
    elif function == 33:
        pass
    
'''
The following function replaces the XPL constructs
    OUTPUT(fileNumber) = string
    OUTPUT = string      , which is shorthand for OUTPUT(0)=string.
The carriage-control characters for fileNumber 1 may be
the so-called ANSI control characters:
    '_'    Single space the line and print
    '0'    Double space the line and print
    '-'    Triple space the line and print
    '+'    Do not space the line and print (but does return carriage to left!)
    '1'    Form feed
    'H'    Heading line.
    '2'    Subheading line.
    ...    Others
'''
headingLine = ''
subHeadingLine = ''
pageCount = 0
LINE_COUNT = 0
linesPerPage = 59  # Should get this from LINECT parameter.


def OUTPUT(fileNumber, string):
    global headingLine, subHeadingLine, pageCount, LINE_COUNT
    if fileNumber > 1:
        file = outputDevices[fileNumber]
        if file == None:
            print("\nOUTPUT to nonexistent device %d" % fileNumber, \
                  file=sys.stderr)
            return
        if not file["open"]:
            print("\nOUTPUT to closed device %d" % fileNumber, \
                  file=sys.stderr)
            return
        file["buf"].append(string)
        if "pds" not in file:
            f = file["file"]
            if outUTF8:
                string = string.replace("`", "¢").replace("~", "¬")
            f.write(string + '\n')
            f.flush()
        return
    if fileNumber == 0:
        string = ' ' + string
        fileNumber = 1
    if fileNumber == 1:
        ansi = string[:1]
        queue = []
        if ansi == ' ': 
            queue.append('')
        elif ansi == '0': 
            queue.append('')
            queue.append('')
        elif ansi == '-':
            queue.append('')
            queue.append('')
            queue.append('')
        elif ansi == '+':
            # This would overstrike the line.  I.e., it's like a carriage return
            # without a line feed.  But I have no actual way to do that, so we 
            # need to advance to the next line.
            queue.append('')
            pass
        elif ansi == '1':
            LINE_COUNT = linesPerPage
        elif ansi == 'H':
            headingLine = string[1:]
            return
        elif ansi == '2':
            subHeadingLine = string[1:]
            return
        if outUTF8:
            queue.append(string[1:].replace("`", "¢").replace("~", "¬"))
        else:
            queue.append(string[1:])
        for i in range(len(queue)):
            if LINE_COUNT == 0 or LINE_COUNT >= linesPerPage:
                if pageCount > 0:
                    print('\n\f', end='')
                pageCount += 1
                LINE_COUNT = 0
                if len(headingLine) > 0:
                    print(headingLine + ("     PAGE %d" % pageCount))
                    LINE_COUNT += 1
                else:
                    print("PAGE %d" % pageCount)
                if len(subHeadingLine) > 0:
                    print(subHeadingLine)
                    LINE_COUNT += 1
                if LINE_COUNT > 0:
                    print()
                    LINE_COUNT += 1
            if i < len(queue) - 1:
                print(queue[i])
            else:
                print(queue[i], end='')

'''
    fileNumber 0,1  stdin, presumably the source code.
    fileNumber 4    Apparently, includable source consists of members of a
                    PDS, and this device number is attached to such a PDS.
    fileNumber 5    Error library (a PDS).
    fileNumber 6    An access-control PDS, providing acceptable language subsets
    fileNumber 7    For reading in structure templates from PDS.

There are cases for certain PDS files where output is both written to the 
file and read back from it as well.  In those cases ... TBD.

The available documentation doesn't tell us what INPUT() is supposed to return
at the end-of-file or end-of-member, though the XPL code I've looked at 
indicates the following:

    End of PDS member           A zero-length string.  E.g., INTERPRE sets
                                a flag called EOF_FLAG upon encountering such a
                                string.
    
    End of sequential file      A zero-length string.  At least, that's what
                                I see in the READ_CARD procedure, which is 
                                what reads the HAL/S source-code files.  
                                However, it's possible for a sequential file to
                                contain zero-length strings other than at the
                                end, so at least for device 0 (source code),
                                I replace zero-length strings by strings which
                                contain a single blank

'''
asciiEOT = 0x04


def INPUT(fileNumber):
    fileNumber = redirections[fileNumber]
    temporary = fileNumber & 0x80000000
    fileNumber &= 0x7FFFFFFF
    try:
        if temporary:
            file = outputDevices[fileNumber]
        else:
            file = inputDevices[fileNumber]
        index = file['ptr'] + 1
        if "pds" not in file:
            data = file['buf']
        else:
            mem = file["mem"]
            data = file['pds'][mem]
        if index < len(data):
            file['ptr'] = index
            line = data[index]
            if len(line) == 0:
                line = ' '
            return line[:]
        else:
            return ''
    except:
        return None


# This function either reads a block from a random-access file, or else 
# writes one.  In either case, that data is a bytearray object.  Unfortunately,
# the original XPL used FILE() in one of two forms that give us some 
# problems duplicating the function in Python:
#    FILE(...) = array        # For output
#    array = FILE(...)        # For input
# Realize that in the latter form, we want to overwrite the array in place,
# so just returning the input data as a bytearray isn't going to do that.  
# Our workaround is to call the FILE() function in either of two forms, 
# recognizing the types of the parameters to distinguish between the
# input vs output cases:
#    FILE(fileNumber, recordNumber, array)    # For output
#    FILE(array, fileNumber, recordNumber)    # For input.
# In either case, array must be a bytearray of length equal to reclen, where
# reclen is the record length specified in files[fileNumber] when the file
# was opened, but no check is performed for that or any other error condition.
def FILE(arg1, arg2, arg3):
    global files
    
    if isinstance(arg1, bytearray):
        isInput = True
        inputArray = arg1
        fileNumber = arg2
        recordNumber = arg3
    else:
        isInput = False
        fileNumber = arg1
        recordNumber = arg2
        outputArray = arg3
    
    f = files[fileNumber][0]
    reclen = files[fileNumber][1]
    size = files[fileNumber][2]
    f.seek(recordNumber * reclen, 0)
    if isInput:
        data = bytearray(f.read(reclen))
        for i in range(reclen):
            try:
                inputArray[i] = data[i]
            except:
                print("Incomplete record %d (<%d bytes) from file %s" \
                      % (recordNumber, reclen, f.name), 
                      file = sys.stderr)
                sys.exit(1)
        return
    f.write(outputArray)
    if f.tell() > size:
        files[fileNumber][2] = f.tell()

# For XPL's DATE and TIME 'variables'.  DATE = (1000*(year-1900))+DayOfTheYear,
# while TIME=NumberOfCentisecondsSinceMidnight.  The timezone isn't specified
# by the definitions (as far as I know), so we just maintain consistency between
# the DATE and TIME, and use whatever TZ is the default.


def DATE():
    timetuple = datetime.now().timetuple()
    return 1000 * (timetuple.tm_year - 1900) + timetuple.tm_yday


def TIME():
    now = datetime.now()
    return  now.hour * 360000 + \
            now.minute * 6000 + \
            now.second * 100 + \
            now.microsecond // 10000


# From the way SUBSTR() is used in the LITDUMP module, it's clear
# that if ne2 is specified, then the function always returns exactly
# ne2 characters, padded with blanks if past the end of the input 
# string.  I.e., ne2 is *not* the max number of characters to return.
# However, from the behavior in TRUNCATE() of the SYTDUMP module, it
# does appear if the string is shorter when ne < 0, though it's 
# unclear exactly what the behavior is supposed to be then.
def SUBSTR(de, ne, ne2=None):
    if ne < 0:
        return ""
    if ne2 == None:
        return de[ne:]
    return "%-*s" % (ne2, de[ne: ne + ne2])

'''
Originally I thought that STRING() should work just like Python str().  
However, I now realize that what it's intended to do is
to receive a "pointer" like those appearing in LIT2, and to return
the string object associated with that pointer.  The "pointers" in 
LIT2 are 32-bit numbers of the (hex) form:
        TTPPPPPP
where TT is the length-1 of the string and PPPPPP is the "address" of
the string.  Which would be fine if these pointers really all came
from LIT2, because then the string data would always be in the 
LIT_CHAR[] array, so we could just use the offset into the LIT_CHAR[]
array as the address.  

(It turns out that the STRING() function is actually documented, on 
p. 13-4 of IR-182-1, and it's indeed what I said it was just now.)

Unfortunately, those are not the only places the input "pointers" come
from.  I find the following:
    Entries from LIT2[]
    Values provided by MONITOR(23)
    Values computed from (mask << 24) | ADDR(...)
    Entries from VOCAB_INDEX[]
    Entries from CON[]
    Entries from TYPE2[]
    Entries from VALS[]
We consequently have to get this whole chain of stuff working in the
same way, in spite of the fact that there are no absolute addresses
available in this port of the compiler.

Here's the way I've decided to work it.  If STRING() receives a string
as argument, it simply returns it.  However, if it receives a number
as an argument, then it's treated as TTPPPPPP, and the hintArray to which
PPPPPP applies must also be given to it as the array parameter.
If array[PPPPPP] is itself a string, then that's returned.  Finally,
if array[PPPPPP:] consists of numbers, then those are assumed to be
EBCDIC and LL of them are converted to characters and the return value
is the join of all of those characters.
'''


def STRING(s, hintArray=None):
    if isinstance(s, str):
        return str(s)
    length = ((s >> 24) & 0xFF) + 1
    index = s & 0xFFFFFF
    if isinstance(hintArray[index], str):
        return hintArray[index]
    string = ""
    for i in range(length):
        string = BYTE(string, len(string), hintArray[index + i])
    return string;


def LENGTH(s):
    return len(s)


def LEFT_PAD(s, n):
    return s.rjust(n, ' ')

'''
# Replaced by function of same name in HALINCL/COMROUT.
def PAD(s, n):
    if isinstance(s, int):
        s = str(s)
    return s.ljust(n, ' ')
'''


def MIN(a, b):
    return min(a, b)


def MAX(a, b):
    return max(a, b)

# For BYTE() and STRING_GT(), the ebcdic module is used to interconvert between
# strings and EBCDIC bytearrays.

# If s is a string (in our case, always encoded as ASCII), i an integer, and
# b a byte-code, then BYTE() has the following usages:
#    BYTE(s)                Returns byte-value of s[0].
#    BYTE(s,i)              Returns byte-value of s[i].
#    BYTE(s,i,b)            Sets byte-value of s[i] to b.
# Even though our strings are always encoded as ASCII, the byte-values 
# we associate with the individual characters are always EBCDIC.  We 
# therefore have to convert freely back and forth between EBCDIC and ASCII.
# The documentation doesn't recognize the possibility that the string s is 
# empty, and thus doesn't say what is supposed to be returned in that case.
# However, this does sometimes occur.


def BYTE(s, index=0, value=None):
    if not isinstance(s, str):
        print("Implementation error: BYTE called with non-string argument:", \
              s, file=sys.stderr)
        if False:
            0 / 0  # Just my way of triggering an error for the debugger.
        sys.exit(1)
    if value == None:
        try:
            c = s[index]
            if c == '`':  # Replacement for cent sign
                return 0x4A
            elif c == '~':  # Replacement for logical-not sign
                return 0x5F
            elif c == '\x04':  # Replacement for EOF.
                return 0xFE
            else:  # Everything else.
                return c.encode('cp1140')[0]  # Get EBCDIC byte code.
        except:
            return 0
    if value == 0x4A:  # Replacement for cent sign.
        c = '`'
    elif value == 0x5F:  # Replacement for logical-not sign.
        c = '~' 
    elif value == 0xFE:  # Replacement for EOF.
        c = '\x04'
    else:  # Everything else.
        c = bytearray([value]).decode('cp1140')
    return s[:index] + c + s[index + 1:]

    dummy[i] = dummy[i].rstrip('\n\r').replace("¬", "~")\
                        .replace("^", "~").replace("¢", "`").expandtabs(8)\
                        .ljust(80)


# STRING_GT() is completely undocumented, as far as I know.  I'm going to 
# assume it's a string-comparison operation.  As to whether the particular
# collation sequence is significant or not ...
def STRING_GT(s1, s2):
    return s1.encode('cp1140') > s2.encode('cp1140')


# The following is supposed to give the address in memory of the variable that's
# it's parameter.  Of course, that's specific to the IBM implementation, and
# (perhaps) utterly meaningless to us, so at least for now I'm simply providing
# it as a dummy.  Each "variable" is simply assigned a unique number, from 0
# upward.  This assumes that the variables are simple ... i.e., not arrays.
ADDResses = []


def ADDR(variable):
    global ADDResses
    if variable not in ADDResses:
        ADDResses.append(variable)
    return ADDResses.index(variable)
    
    return 0


# Inserts inline BAL instructions.  Obviously less than useless to us.  
# I'm not sure what to do with it.
def INLINE(arg1=None, arg2=None, arg3=None, arg4=None, arg5=None, \
           arg6=None, arg7=None, arg8=None, arg9=None, arg10=None):
    return


def EXIT():
    sys.exit(1)

'''
I have data stored in arrays of class instances which I want to save
as JSON, and to be able to restore it later from the JSON.  The
following works in Python 3, though I have suspicions about whether or 
not it's good practice that may be allowed in Python 4 (if such a thing
will ever exist).
'''


def saveClassArray(classArray, filename):
    a = []
    for entry in classArray:
        a.append(entry.__dict__)
    f = open(scriptParentFolder + "/" + filename, "w")
    json.dump(a, f, indent=4)
    f.close()


def loadClassArray(classType, filename):
    f = open(scriptParentFolder + "/" + filename, "r")
    j = json.load(f)
    f.close()
    a = []
    for entry in j:
        c = classType()
        c.__dict__ = entry
        a.append(c)
    return a

        
