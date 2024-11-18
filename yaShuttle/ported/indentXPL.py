#!/usr/bin/env python3
'''
The notion behind this program is that it takes XPL source code, and properly 
indents it in a way convenient for a Python port.

It's a very crude tool.  Keywords DO and PROCEDURE increment indenting 
while the keyword END reduces the indenting.

The first step is crude analysis to find:
    Identifiers
    Comments
    Single-quoted strings
    Double-quoted strings
    Special characters.
'''

import sys
import re
import inspect

f = sys.stdin
fix = False
for parm in sys.argv[1:]:
    if parm.startswith("--file="):
        f = open(parm[7:], "r")
    elif parm == "--fix":
        fix = True
    elif parm == "--help":
        print("Crude conversion of a HAL/S-FC compiler source-code")
        print("file in XPL to Python.  Should be run from the folder")
        print("in which the Python files will go, even though the ")
        print("output is on stdout, because the program will read")
        print("g.py and HALINCL/COMMON.py to determine some")
        print("substitutions.  IMPORTANT: indentXPL.py must be in")
        print("this same directory as the Python files being created.")
        print()
        print("Usage:")
        print("    indentXPL [OPTIONS]")
        print("--file=F    The XPL file to convert.")
        print("--fix       Applies a lot more heuristic fixes.")
        print("--sanity    Check array limits in g.py.")
        print("--help      Print this help message.")
    elif parm == "--sanity":
        pass
    else:
        print("Unknown parameter:", parm, file=sys.stderr)

#----------------------------------------------------------------------
# First, read files like g.py, HALINCL/COMMON.py, etc., which contain
# some commonly-used namespaces, and analyze them to find out what
# variables (or functions masquerading as variables) reside in those
# namespaces.  We'll let Python do the actual parsing for us.
import g as g
#import HALINCL.COMMON as h

arrayVariables = []
simpleVariables = []
noArgFunctions = []
argFunctions = []
for d in sorted(g.__dict__):
    if not d.replace("#", 'P').replace("@", "A").replace("$", "D").isupper():
        continue
    v = g.__dict__[d]
    if isinstance(v, (int, float, str)):
        simpleVariables.append(d)
    elif isinstance(v, (list, tuple)):
        arrayVariables.append(d)
    elif callable(v):
        numParms = len(inspect.signature(v).parameters)
        if numParms == 0:
            noArgFunctions.append(d)
        else:
            argFunctions.append(d)
#----------------------------------------------------------------------

'''
Now, read the entire source file, reformat it, and store it in
bufferedDataset[].  The idea is to correctly handle everything so that 
functionally-identical XPL is created ... except for the following couple of
things.

I don't handle leading or trailing spaces on lines in such a way that 
they're preserved in comments or quoted strings that extend over more than one 
line.  Fortunately, it's a case that seldom occurs.  Nevertheless, if the 
reformatted code is used, those quotes or comments may need to be corrected
manually.

Quotes and quoted strings are also mangled (temporarily) in such a way as to
prevent some regular-expression replacements optionally performed later fail
within the quotes or comments.  For example, if I replace "IF" by "if" 
everywhere, I don't want to worry about that happening in quotes or comments.
The mangling is undone before any output occurs.  The mangling is crude:  Any
upper-case letters (say, X) are converted to @x.  If the letter @ itself 
appears, it's converted to @@.
'''


def mangle(s):
    mangled = ""
    for c in s:
        if (c.isalpha() and c.isupper()) or c == "@":
            mangled = mangled + "@" + c.lower()
        else:
            mangled = mangled + c
    return mangled


def unmangle(s):
    unmangled = ""
    i = 0
    while i < len(s):
        c = s[i]
        if c == "@":
            i += 1
            unmangled = unmangled + s[i].upper()
        else:
            unmangled = unmangled + c
        i += 1
    return unmangled


inComment = False
inSingleQuote = False
escapeSingle = False
inDoubleQuote = False
escapeDouble = False
inIdentifier = False
identifier = ""
indentationLevel = 0
indentation = ""
pendingIndentation = 0
bufferedLine = ""
first = False
bufferedDataset = []
lineCount = 0
gotoTargets = []

if fix:
    print("#!/usr/bin/env python3")

def printBuffer():
    global indentationLevel, indentation, pendingIndentation, bufferedLine
    global bufferedDataset
    if len(bufferedLine) > 0:
        bufferedDataset.append("%s%s" % (indentation, bufferedLine))
    bufferedLine = ""
    if pendingIndentation != None:
        indentationLevel = pendingIndentation
        pendingIndentation = None
        indentation = " " * (4 * indentationLevel)


printBuffer()

for rawLine in f:
    line = rawLine.rstrip("\n").replace("¬", "~").replace("¢", "`")[:80].strip()
    if fix:
        # File header.
        if lineCount == 0:
            if rawLine[:2] == "/*" or rawLine[:3] == " /*":
                print('"""')
                lineCount = 1
                continue
        elif lineCount == 1:
            if rawLine[:2] == "*/" or rawLine[:3] == " */":
                print('"""')
                print()
                lineCount = 2
                print("from xplBuiltins import *")
                print("import g")
                print("import HALINCL.CERRDECL as d")
                print("import HALINCL.COMMON as h")
                print("from ERROR import ERROR")
                print()
            else:
                line = rawLine[:80].rstrip()
                if line[:1] == " ":
                    line = line[1:]
                print(line)
            continue
        line = re.sub(r" */\* *[CD]R[0-9]+ *\*/ *", " ", line)
        line = re.sub(r" */\* *[CD]R[0-9]+ *, *[CD]R[0-9]+ *\*/ *", " ", line)
        line = re.sub(r"/\* *[CD]R[0-9]+ *[-]* *", "/*", line)
        line = re.sub(r'"([0-9A-F]+)"', "0x\\1", line)
    if inIdentifier:
        # Take care of the case in which the preceding line ended with an
        # identifier.
        if identifier in ["PROCEDURE", "DO", "BASED"]:
            indentationLevel += 1
        elif identifier == "END" and indentationLevel > 0:
            indentationLevel -= 1
        indentation = " " * (4 * indentationLevel)
        inIdentifier = False
        identifier = ""
    for i in range(len(line)):
        if i > 0:
            c0 = line[i - 1]
        else:
            c0 = None
        c = line[i]
        if i + 1 < len(line):
            c1 = line[i + 1]
        else:
            c1 = None
        retry = True
        while retry:
            retry = False
            if inComment:
                bufferedLine = bufferedLine + mangle(c)
                if c == "/" and c0 == "*":
                    inComment = False
            elif inSingleQuote:
                if not first:
                    if c == "'":
                        escapeSingle = not escapeSingle
                    elif escapeSingle:
                        inSingleQuote = False
                        escapeSingle = False
                        retry = True
                        continue
                first = False
                bufferedLine = bufferedLine + mangle(c)
            elif inDoubleQuote:
                if not first:
                    if c == '"':
                        escapeDouble = not escapeDouble
                    elif escapeDouble:
                        inDoubleQuote = False
                        escapeDouble = False
                        retry = True
                        continue
                first = False
                bufferedLine = bufferedLine + mangle(c)
            elif inIdentifier:
                if c.isalnum() or c in ["_", "@", "#", "$"]:
                    c = c.replace("@", "a").replace("#", "p").replace("$", "d")
                    identifier = identifier + c
                    bufferedLine = bufferedLine + c
                else:
                    if identifier in ["PROCEDURE", "DO", "BASED"]:
                        pendingIndentation = indentationLevel + 1
                    elif identifier in ["END"]:
                        if bufferedLine.startswith(identifier):
                            if indentationLevel > 0:
                                indentationLevel -= 1
                                indentation = " " * (4 * indentationLevel)
                        elif indentationLevel > 0:
                            pendingIndentation = indentationLevel - 1
                    inIdentifier = False
                    identifier = ""
                    retry = True
                    continue
            else:
                if c == "/" and c1 == "*":
                    inComment = True
                    retry = True
                    continue
                elif c == "'":
                    inSingleQuote = True
                    first = True
                    retry = True
                    continue
                elif c == '"':
                    inDoubleQuote = True
                    first = True
                    retry = True
                    continue
                elif c.isalpha() or c in ["_", "@", "#", "$"]:
                    inIdentifier = True
                    retry = True
                    continue
                if c != " " or len(bufferedLine) > 0:
                    bufferedLine = bufferedLine + c
                if c == ";":
                    printBuffer()
    if len(bufferedLine) > 0:
        printBuffer()

# Optionally, perform any of the kinds of fixups that I normally perform via
# regular-expression substitutions when porting the XPL to Python, such as 
# converting "IF" to "if", "^=" to "!=", etc.
if fix:
    inDECLARE = False
    inOUTPUT = False
    for i in range(len(bufferedDataset)):
        line = bufferedDataset[i]
        line = re.sub(r"\bIF\b", "if", line)
        line = re.sub(r"\bELSE *if\b", "elif", line)
        line = re.sub(r"\bELSE\b", "else:", line)
        line = re.sub(r" *THEN\b", ":", line)
        line = re.sub(r"\bRETURN\b", "return", line)
        line = re.sub(r" *\|\| *", " + ", line)
        line = re.sub(r"\^=", "!=", line)
        line = re.sub(r"\^<", ">=", line)
        line = re.sub(r"\^>", "<=", line)
        line = re.sub(r"\bCALL +", "", line)
        line = re.sub(r"\bERROR *\( *CLASS_", "ERROR(d.CLASS_", line)
        line = re.sub(r"\bERRORS *\( *CLASS_", "ERRORS(d.CLASS_", line)
        line = re.sub(r"\bEND *; *$", "#END", line)
        line = re.sub(r"\bEND *;", "'''END;'''", line)
        line = re.sub(r"\bDO +FOREVER *;", "while True:", line)
        line = re.sub(r"\bDO *; *$", "#DO", line)
        line = re.sub(r"\bDO *;", "'''DO;'''", line)
        line = re.sub(r"\bDO +WHILE +([^;]+);", "while \\1:", line)
        line = re.sub(r"\bDO +WHILE", "while", line)
        line = re.sub(r"\bDO +([^=]+) *= *(.*) +TO +([^;]+) *;", \
                      "for \\1 in range(\\2, \\3 + 1):", line)
        line = re.sub(r"^( *)(END +[A-Zp][A-Z0-9_p]* *;)", "\\1# \\2", line)
        line = re.sub(r"^( *)([A-Zp][A-Z0-9_p]*) *: *PROCEDURE *\(([^)]*)\).*", \
                      "\\1def \\2(\\3):", line)
        line = re.sub(r"^( *)([A-Zp][A-Z0-9_p]*) *: *PROCEDURE[^ (]*[A-Zp]", \
                      "\\1def \\2():", line)
        if i > 0 and "PROCEDURE" in line and ":" in bufferedDataset[i - 1]:
            #print(bufferedDataset[i-1], line, file=sys.stderr)
            new = bufferedDataset[i - 1] + " " + line
            if ")" in new:
                new = re.sub(r"\).*", ")", new)
            else:
                new = re.sub(r"PROCEDURE", "PROCEDURE()", new)
            spaces = re.sub(r"^( *).*", "\\1", new)
            identifier = re.sub(r"^ *([A-Zp][A-Z0-9_p]*) *:.*$", "\\1", new)
            if len(identifier) > 0:
                args = re.sub(r".*PROCEDURE *\(([^)]*)\).*", "\\1", new)
                #bufferedDataset[i - 1] = spaces + "#" + new
                bufferedDataset[i - 1] = ""
                line = spaces + "def " + identifier + "(" + args + "):"
        if "DECLARE" in line:
            line = re.sub(r"\b(DECLARE .*)", "#\\1", line)
            inDECLARE = (line[-1:] != ";")
        elif inDECLARE:
            line = re.sub(r"^( *)(.*)", "\\1#\\2", line)
            inDECLARE = (line[-1:] != ";")
        if "GO TO" in line:
            gotoTarget = re.sub(r".* GO +TO +([A-Z_0-9]+).*", "\\1", line)
            if gotoTarget not in gotoTargets:
                gotoTargets.append(gotoTarget)
                #print(re.sub(r".* GO +TO +([A-Z_0-9]+)", "goto_\\1 = False", line))
            line = re.sub(r"\bGO +TO +([A-Z_0-9]+)", 'goto = "\\1"', line)
        if "def" not in line:
            # Note that this won't correctly account for local variables of the 
            # same name as globals, so those have to be fixed up separately.
            for var in arrayVariables:
                if var in line:
                    line = re.sub("\\b" + var + " *\\(([^)]+) *\)",  \
                                  "g." + var + "[\\1]", line)
            for var in simpleVariables:
                if var in line:
                    line = re.sub("\\b" + var + "\\b", "g." + var, line)
            for var in argFunctions:
                if var in line:
                    line = re.sub("\\b" + var + "\\b", "g." + var, line)
            for var in noArgFunctions:
                if var in line:
                    line = re.sub("\\b(?<!END )" + var + "(?! *:)\\b", "g." + var + "()", line)
        for j in range(5):
            line = re.sub(r"^( *(if|elif|while) .*[^!><=])=([^=].*:)", "\\1==\\3", line)
                
        bufferedDataset[i] = line
    # Another pass:
    if len(gotoTargets) > 0:
        gotoTargetPattern = " (" + "|".join(gotoTargets) + ") *:"
        for i in range(len(bufferedDataset)):
            line = bufferedDataset[i]
            line = re.sub(gotoTargetPattern, ' if goto == "\\1": goto = None', line)
            bufferedDataset[i] = line

# Finally, unmangle and print out the fixed-up code.  Besides unmangling, 
# convert end-of-line comments by replacing "/*" with "#
for line in bufferedDataset:
    if fix and "/*" in line:
        i = line.index("/*")
        if "*/" not in line[i:]:
            line = line[:i] + "#" + line[i+2:]
        else:
            j = line[i:].index("*/")
            if line[i:][j+2:].strip() == "":
                line = line[:i] + "#" + line[i+2:i+j].rstrip()
    print(unmangle(line))
    
