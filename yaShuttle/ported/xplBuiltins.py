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
from time import time_ns
from datetime import datetime
from decimal import Decimal, ROUND_HALF_UP
import json
import math
import ebcdic

sourceFile = None # Use stdin by default for HAL/S source-code file.
for parm in sys.argv[1:]:
    if parm.startswith("--hal="):
        sourceFile = parm[6:]

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
#        "file":   The associated Python file object,
#        "open":   Boolean (True if open, False if closed),
#        "blob":   If an input file, the entire contents as a list of strings.
#                  If an output file, just None, since output is written 
#                  directly to the file without any buffering.
#        "pds":    If an input file the file contents as a dictionary.
#                  If an output file, just None, since output is written 
#                  directly to the file without any buffering.
#        "random": The file contents as a list of fixed-length Python bytearray
#                  objects.  "Random" files are treated as input/output, and
#                  their contents are both buffered and written to the 
#                  associated file.
#        "reclen": The record length (in bytes) for "random" files.
#        "mem":    For a "pds", the member name last found by MONITOR(2);
#                  not used for a "blob",
#        "ptr":    The index of the last line returned by an INPUT();
#                  for a "blob" it's the index within the file as a whole,
#                  while for a "pds" it's the index within the member,
#        "was":    Set of PDS keys from most-recent read or write to file.
#    }
# The keys "blob", "pds", and "random" are mutually exclusive; one and only one
# of them is present.  For a "pds" dictionary, the dictionary keys are  
# "member names", each of which is precisely 8 characters long (including 
# padding by spaces on the right).  The value associated with a member key is 
# the entire contents of that member as a list of strings.
#
# NOTE: It took me a good long time to figure this out, but the
# input and output "devices" which are accessed via the INPUT and OUTPUT
# statements are *separate* from the random-access files accessed by READ
# and WRITE statements.  What really puzzled me was that device 2 is used for
# outputting LISTING2, whereas file 2 is used for inputting and outputting to
# the LITFILE.  But finally I did figure it out, fortunately.  If you look at
# sample JCL, you'll see that all of these have separate DD cards defining
# them.  We simply open 6 random-access files called "HAL-S-FC.file1" through
# "HAL-S-FC.file2" and then wash our hands of the matter.

# The entries of the files[] array are 3-lists of the open random-access file 
# pointer, the record size, and the current file size (in bytes).
files = [None]
for i in range(1, 7):
    f = open("FILE%d.bin" % i, "w+b")
    f.seek(2, 0)
    files.append([f, 7200, f.tell()])

inputDevices = [None]*10
outputDevices = [None]*10

# Open the files that we need, other than output files 0 and 1 (whose behavior
# is hard-coded separately), and buffer their contents where appropriate.
if sourceFile == None: # HAL/S source code.
    f = sys.stdin
else:    # Debugging
    f = open(sourceFile, "r")
dummy = f.readlines() # Source code.
for i in range(len(dummy)):
    dummy[i] = dummy[i].rstrip('\n\r').replace("¬","~")\
                        .replace("^","~").replace("¢","`").expandtabs(8)\
                        .ljust(80)
inputDevices[0] = {
    "file": f,
    "open": True,
    "ptr":  -1,
    "blob":  dummy
    }
f = open("LISTING2.hal", "w") # Secondary output listing
outputDevices[2] = {
    "file": f,
    "open": True,
    "blob": []
    }
f = open("ERRORLIB.json", "r") # File of error message types.
dummy = json.load(f)
inputDevices[5] = {
    "file": f,
    "open": True,
    "ptr":  -1,
    "mem":  "",
    "pds":  dummy,
    "was":  set(dummy.keys())
    }
inputDevices[6] = { # File of module access rights.
    "file": None,
    "open": False,
    "ptr":  -1,
    "mem":  "",
    "pds":  {},
    "was":  set()
    }
f = open("SOURCECO.txt", "w") # Source-comparision output.
outputDevices[9] = {
    "file": f,
    "open": True,
    "blob": []
    }

def SHL(a, b):
    return a << b


def SHR(a, b):
    return a >> b

# Some of the MONITOR calls are listed beginning on PDF p. 826 of the "HAL/S-FC
# & HAL/S-360 Compiler System Program Description" (IR-182-1).  Note that the
# only function numbers actually appearing in the source code are:
#    0-10, 12, 13, 15-18, 21-23, 31-32
# The latter two aren't mentioned in the documentation.
compilerStartTime = time_ns()
dwArea = None
compilationReturnBits = 0
namePassedToCompiler = ""
def MONITOR(function, arg2=None, arg3=None):
    global inputDevices, outputDevices, dwArea, compilationReturnBits, \
            namePassedToCompiler, files
    
    def error(msg=''):
        if len(msg) > 0:
            msg = '(' + msg + ') '
        print("Error %sin MONITOR(%s,%s,%s)" % \
              (msg, str(function), str(arg2), str(arg3)), file=sys.stderr)
        sys.exit(1)
    
    def close(n):
        global outputDevices
        device = outputDevices[n]
        if isinstance(device, list) and "open" in device and device["open"]: 
            device["file"].close()
            device["open"] = False
        else:
            print("\nTrying to close device %d, which is not open" % n)
    
    if function == 0: 
        n = arg2
        close(n)
        
    elif function == 1:
        n = arg2
        member = arg3
        msg = ''
        try:
            msg = "no file"
            device = outputDevices[n]
            file = device["file"]
            msg = "not PDS"
            pds = device["pds"]
            msg = "other"
            was = device["was"]
            if member in was:
                returnValue = 1
            else:
                returnValue = 0
            was.clear()
            was[0:0] = pds.keys()
            file.seek(0)
            j = json.dump(pds, file)
            file.truncate()
            close(n)
            return returnValue
        except: 
            error(msg)
    
    elif function == 2:
        n = arg2
        member = arg3
        msg = ''
        try:
            msg = "not PDS"
            if member in inputDevices[n]["pds"]:
                inputDevices[n]["mem"] = member
                inputDevices[n]["ptr"] = -1
                return 0
            '''
            if n in (4, 7):
                if member in inputDevices[6]["pds"]:
                    inputDevices[6]["mem"] = member
                    return 0
            '''
            return 1
        except:
            error(msg)
        
    elif function == 3: 
        n = arg2
        close(n)
    
    elif function == 4:
        # Change block size of a random-access file.
        files[arg2][1] = arg3
    
    elif function == 5:
        # This is modified from the documented form of MONITOR(5,ADDR(DW))
        # into MONITOR(5,DW,n), where DW is a Python list and n is an index
        # into it.  The problem with the original form is that it gives us
        # an element of a list and we're expected later (in MONITOR 9 and 10)
        # to have access to the array elements that there's no reasonable way
        # to have in Python.
        dwArea = (arg2, arg3)
    
    elif function == 6:
        # This won't be right of the based variable is anything other than 
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
    
    elif function == 7:
        array = arg2
        n = arg3
        try:
            while n > 0:
                array.pop(-1)
        except:
            error()
    
    elif function == 8:
        error()
    
    elif function == 9:
        if dwArea == None:
            print("\nNo MONITOR(5) prior to MONITOR(9)", file=sys.stderr)
            exit(1)
        op = arg2
        try:
            if op == 1:
                dwArea[0][dwArea[1]] = dwArea[0][dwArea[1]] + dwArea[0][dwArea[1]+1]
            elif op == 2:
                dwArea[0][dwArea[1]] = dwArea[0][dwArea[1]] - dwArea[0][dwArea[1]+1]
            elif op == 3:
                dwArea[0][dwArea[1]] = dwArea[0][dwArea[1]] * dwArea[0][dwArea[1]+1]
            elif op == 4:
                dwArea[0][dwArea[1]] = dwArea[0][dwArea[1]] / dwArea[0][dwArea[1]+1]
            elif op == 5:
                dwArea[0][dwArea[1]] = pow(dwArea[0][dwArea[1]], dwArea[0][dwArea[1]+1])
            # Unfortunately, the documentation doesn't specify the angular 
            # units.
            elif op == 6:
                dwArea[0][dwArea[1]] = math.sin(dwArea[0][dwArea[1]])
            elif op == 7:
                dwArea[0][dwArea[1]] = math.cos(dwArea[0][dwArea[1]])
            elif op == 8:
                dwArea[0][dwArea[1]] = math.tan(dwArea[0][dwArea[1]])
            elif op == 9:
                dwArea[0][dwArea[1]] = math.exp(dwArea[0][dwArea[1]])
            elif op == 10:
                dwArea[0][dwArea[1]] = math.log(dwArea[0][dwArea[1]])
            elif op == 11:
                dwArea[0][dwArea[1]] = math.sqrt(dwArea[0][dwArea[1]])
            else:
                return 1
            return 0
        except:
            return 1
    
    elif function == 10:
        if dwArea == None:
            print("\nNo MONITOR(5) prior to MONITOR(10)", file=sys.stderr)
            exit(1)
        s = arg2
        try:
            dwArea[0][dwArea[1]] = float(s)
            return 0
        except:
            return 1
    
    elif function == 12:
        return "%g" % dwArea[0][dwArea[1]]
    
    elif function == 13:
        # Unneeded
        return 0
    
    elif function == 15:
        # The documented explanation is sheerest gobbledygook.  I think perhaps
        # it's saying that the so-called template library maintains a revision
        # code for each structure template stored in it, and that this function
        # can be used to retrieve that revision code.  All of which is as
        # meaningless to us as it can possibly be.  I return a nonsense value.
        return 32*65536 + 0
        
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
        
    elif function == 17:
        namePassedToCompiler = arg2
        
    elif function == 18:
        return (time_ns() - compilerStartTime) // 10000000
    
    elif function == 21:
        return 1000000000
        
    elif function == 22:
        pass
        
    elif function == 23:
        return "REL32V0   "
    
    elif function == 31:
        # This appears to be related somehow to control of virtual memory,
        # something of which we have no need.
        pass
        
    elif function == 32: # Returns the 'storage increment', whatever that may be.
        return 16384

'''
The following function replaces the XPL constructs
    OUTPUT(fileNumber) = string
    OUTPUT = string                which is shorthand for OUTPUT(0)=string.
Interpretations:
    fileNumber 0    The assembly listing, on stdout
    fileNumber 1    Same as 0, but the leading character of string is used for 
                    carriage control.
    fileNumber 2    Unformatted source listing (LISTING2).
    fileNumber 3    HALMAT object-file.
    fileNumber 4    For punching duplicate card deck (Pass 4)
    fileNumber 5    SDF (Simulation Data File), a PDS
    fileNumber 6    Structure-template library, a PDS
    fileNumber 8    TBD
    fileNumber 9    Patch from one source version to another, a PDS.
The carriage-control characters mentioned above (for fileNumber 1) may be
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
lineCount = 0
linesPerPage = 59 # Should get this from LINECT parameter.
def OUTPUT(fileNumber, string):
    global headingLine, subHeadingLine, pageCount, lineCount
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
            lineCount = linesPerPage
        elif ansi == 'H':
            headingLine = string[1:]
            return
        elif ansi == '2':
            subHeadingLine = string[1:]
            return
        queue.append(string[1:])
        for i in range(len(queue)):
            if lineCount == 0 or lineCount >= linesPerPage:
                if pageCount > 0:
                    print('\n\f', end='')
                pageCount += 1
                lineCount = 0
                if len(headingLine) > 0:
                    print(headingLine)
                    lineCount += 1
                if len(subHeadingLine) > 0:
                    print(subHeadingLine)
                    lineCount += 1
                if lineCount > 0:
                    print()
                    lineCount += 1
            if i < len(queue) - 1:
                print(queue[i])
            else:
                print(queue[i], end='')
    elif fileNumber == 6:
        pass
    elif fileNumber == 8:
        pass
    elif fileNumber in [2, 9]:
        if outputDevices[fileNumber]["open"] and \
                "blob" in outputDevices[fileNumber]:
            f.write(string + '\n')
            f.flush()

'''
    fileNumber 0,1  stdin, presumably the source code.
    fileNumber 4    Apparently, includable source consists of members of a
                    PDS, and this device number is attached to such a PDS.
    fileNumber 5    Error library (a PDS).
    fileNumber 6    An access-control PDS, providing acceptable language subsets
    fileNumber 7    For reading in structure templates from PDS.
    
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
    try:
        file = inputDevices[fileNumber]
        index = file['ptr'] + 1
        if 'blob' in file:
            data = file['blob']
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

# The value parameter, if any, must be a byte array of the proper length for
# the device.  Similarly for the return value.  
def FILE(fileNumber, recordNumber, value=None):
    global files
    if fileNumber < 1 or fileNumber >= len(files):
        return None
    f = files[fileNumber][0]
    reclen = files[fileNumber][1]
    size = files[fileNumber][2]
    desiredSize = recordNumber * reclen + reclen
    if value == None:
        # Input
        if desiredSize > size:
            return bytearray([0]*reclen)
        f.seek(recordNumber * reclen, 0)
        return bytearray(f.read(reclen))
    # Output
    if size < desiredSize:
        f.seek(0,2)
        f.write(bytearray([0] * (desiredSize - size)))
        size = desiredSize
        files[fileNumber][2] = size
    f.seek(recordNumber * reclen)
    if len(value) < reclen:
        value = value + bytearray([0] * (reclen - len(value)))
    elif len(value) > reclen:
        value = value[:reclen]
    f.write(value)

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

def SUBSTR(de, ne, ne2=None):
    if ne2 == None:
        return de[ne:]
    return de[ne : ne+ne2]

def STRING(s):
    return str(s)

def LENGTH(s):
    return len(s)

def LEFT_PAD(s, n):
    return s.rjust(n, ' ')

def PAD(s, n):
    if isinstance(s, int):
        s = str(s)
    return s.ljust(n, ' ')

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
    if value == None:
        try:
            c = s[index]
            if c == '`': # Replacement for cent sign
                return 0x4A
            elif c == '~': # Replacement for logical-not sign
                return 0x5F
            elif c == '\x04': # Replacement for EOF.
                return 0xFE
            else: # Everything else.
                return c.encode('cp1140')[0] # Get EBCDIC byte code.
        except:
            return 0
    if value == 0x4A: # Replacement for cent sign.
        c = '`'
    elif value == 0x5F: # Replacement for logical-not sign.
        c = '~' 
    elif value == 0xFE: # Replacement for EOF.
        c = '\x04'
    else: # Everything else.
        c = bytearray([value]).decode('cp1140')
    return s[:index] + c + s[index+1:]

    dummy[i] = dummy[i].rstrip('\n\r').replace("¬","~")\
                        .replace("^","~").replace("¢","`").expandtabs(8)\
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

