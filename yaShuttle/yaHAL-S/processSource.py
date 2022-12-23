#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       processSource.py
Purpose:        This is parte of a preprocessor for the "modern" HAL/S compiler
                which takes care of things I don't think can be handled
                by the compiler itself (given the BNFC framework for
                developing the compiler).  It invokes the compiler 
                automatically when appropriate, so it's also appropriate to
                call this the compiler.
History:        2022-12-16 RSB  Split off from yaHAL-S-FC.py.
                                
Here are some features of HAL/S I don't think the compiler (if based on a
context-free grammar with free formatting) could handle without preprocessing:

    1.  Special characters in column 1.  Specifically:
            a)  The original comments ('C' in column 1).
            b)  Multiline E / M / S constructs (including tabulation).
            c)  Compiler directives ('D' in column 1).
    2.  The macro statements:
            REPLACE identifier[(identifier)] by "string" ;
        The compiler can parse these lines all right, but could not 
        perform the macro expansions themselves.
    3.  Distinction between identifiers (variables, expressions) that
        are ARITH vs BOOLEAN vs CHARACTER vs STRUCTURE vs EVENTS vs LABELS.
       
Of the possible compiler directives, the preprocessor presently handles only
the following:

    D INCLUDE TEMPLATE nameOfStructureTemplate
    
INCLUDE TEMPLATE relies on an external "library" of structure templates, 
specified by command-line options, which the preprocessor reads at startup 
and updates if it discovers new STRUCTURE statements not already in the library.

"""

import sys

import unEMS
import replaceBy
import reorganizer
from pass1 import tokenizeAndParse, tmpFile, compiler, astPrint, captured
from PALMAT import generatePALMAT, constructPALMAT

# Preprocess and compile a set of source lines, according to the global 
# settings. Return True,ast on success, False,{} on failure.
def processSource(PALMAT, halsSource, metadata, libraryFilename, 
                    structureTemplates, \
                    noCompile=False, xeq=True, lbnf=False, bnf=False, \
                    trace1=False, wine=False, trace2=False):

    # Because whitespace is important in E/M/S constructs and (potentially) in 
    # the positioning our compiler output is going to use for error markers, 
    # let's expand all tabs to spaces.
    def untab(line):
        while "\t" in line:
            tabAt = line.index('\t')
            alignTo = tabSize * ((tabAt + tabSize) // tabSize)
            fmt = "%-" + ("%d" % alignTo) + "s"
            line = fmt % line[:tabAt] + line[tabAt + 1:]
        return line
        
    for i in range(len(halsSource)):
        halsSource[i] = untab(halsSource[i].rstrip())

    # Remove E/M/S multiline constructs. 
    unEMS.unEMS(halsSource, metadata)

    warningCount = unEMS.warningCount
    fatalCount = unEMS.fatalCount

    # Reorganize input lines.
    halsSource, metadata = reorganizer.reorganizer(halsSource, metadata)

    # Take care of REPLACE ... BY "..." macros.
    replaceBy.replaceBy(halsSource, metadata, \
                        libraryFilename, structureTemplates)

    # Output the modified source.  If --no-compile, then simply output to stdout.
    # If not --no-compile, then output to a file called yaHAL_S.tmp.
    if noCompile:
        f = sys.stdout
    else:
        f = open(tmpFile, "w")
    for i in range(len(halsSource)):
        if len(halsSource[i]) > 0 and halsSource[i][:1] != " ":
            print(" /*" + halsSource[i] + "*/", file=f)
        else:
            print(reorganizer.untranslate(halsSource[i]), file=f)
    if not noCompile:
        f.close()

    # Print final summary of preprocessing.
    #print("Files:")
    #for file in files:
    #    print("    ", file)
    if warningCount != 0 or fatalCount != 0:
        for i in range(len(halsSource)):
            if "errors" in metadata[i]:
                print("Line %d:" % (i+1), halsSource[i])
                for error in metadata[i]["errors"]:
                    print("    ", error)
        print(warningCount, "preprocessor warnings")
        print(fatalCount, "preprocessor errors")
        if fatalCount > 0:
            return False, {}

    if noCompile:
        return True, {}
        
    success, ast = tokenizeAndParse([], trace1, wine)
    for error in captured["stderr"]:
        fields = error.split(":", 2)
        if len(fields) > 2 and fields[0].strip() == "error":
            print("Error:" + error[6:])
            fields = fields[1].strip().split(",")
            i = int(fields[0]) - 1
            j = int(fields[1])
            print(reorganizer.untranslate(halsSource[i]))
            print("%*s^" % (j-1, "")) 
        else:
            print(error)
    if success:
        #print("Compiler pass 1 successful.")
        if lbnf or bnf:
            flavor = "LBNF"
            if bnf:
                flavor = "BNF"
            print()
            print("Abstract Syntax Tree (AST) in", flavor)
            print("----------------------------------")
            astPrint(ast, lbnf, bnf)
    else:
        print("Compiler pass 1 failure.")
        return False, ast
        
    # Additional passes ...
    # TBD

    success = generatePALMAT(ast, PALMAT, [], trace2)

    return success, ast
    
