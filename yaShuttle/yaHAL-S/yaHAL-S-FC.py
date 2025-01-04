#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       yaHAL-S-FC.py
Purpose:        This is a preprocessor for the "modern" HAL/S compiler
                which takes care of things I don't think can be handled
                by the compiler itself (given the BNFC framework for
                developing the compiler).  It invokes the compiler 
                automatically when appropriate, so it's also appropriate to
                call this the compiler.
History:        2022-11-07 RSB  Created. 
                2022-11-09 RSB  Change emphasis (and filename) from 
                                compiler to preprocessor.
                2022-11-17 RSB  Began trying to account for 
                                    REPLACE ... by "..." ;
                                statements.
                2022-11-18 RSB  Moved replaceBy into separate module
                                for continued development.
                2022-11-21 RSB  Began adding identifier type prefixes.
                                Removed #-comments.
                2022-11-22 RSB  Added --full.
                2022-11-30 RSB  Eliminated the bracket-removal code, expecting
                                the LBNF to handle it.
                2022-12-09 RSB  Added --library option.
                2022-12-10 RSB  Added --no-compile.
                2022-12-11 RSB  The next evolution of yaHAL-preprocessor.py.
                2022-12-16 RSB  Began implementing interpreter.
                2025-01-04 RSB  Some corrections to --help.
                                
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

#import unEMS
#import replaceBy
#import reorganizer
#from pass1 import tokenizeAndParse, tmpFile, compiler, astPrint, captured
from processSource import processSource
from palmatAux import constructPALMAT, astSourceFile
from pass1 import parms
from optimizePALMAT import optimizePALMAT

#Parse the command-line arguments.
tabSize = 8
halsSource = []
metadata = []
files = []
noCompile = False
lbnf = False
bnf = False
trace = False
interactive = False
colorize = False
noexec = False
ansiWrapper = True
for param in sys.argv[1:]:
    if param == "--help":
        print("""
        This is a preprocessor+compiler+interpreter for HAL/S code. 
        
        Usage:
            yaHAL-S-FC.py [OPTIONS] INPUT1.hal [INPUT2.hal [...]]
        
        The OPTIONS are: 
        
        --tab=N         Tab size in source files; assumed to be 8.  No allowance
                        is made for different tab sizes in different source 
                        files, so let's just hope that never happens!  Probably 
                        the Shuttle source has no tabs anyway since it was 
                        supplied on punchcards, but it's certainly possible to 
                        accidentally end up with tabs if source is edited in 
                        modern editors.
        --no-compile    Merely output preprocessed source, and do not attempt
                        to invoke the compiler.
        --library=F     Specifies the filename of the library of structure
                        templates.  By default, "yaHAL-default.templates".
                        This option can be used multiple times, but any new
                        structure templates encountered during preprocessing
                        will only be added to the final library file specified.
                        This option must precede the HAL/S source filenames.
        --compiler=F    Name of compiler's phase 1.  The default is
                        %s.
        --lbnf, --bnf   Display the abstract syntax trees (AST) in LBNF or
                        in BNF.  Default is not to display the ASTs.
        --trace         Enable tracing for compiler front-end parser.
        --interactive   Normally, the HAL/S source-code comes from a file or
                        files specified on the command line.  However, in 
                        interactive mode, HAL/S statements are entered from
                        the keyboard and executed one at a time as they are
                        entered.
        --colorize      Used only with --interactive.  If present, it is
                        equivalent to the interpreter command COLORIZE RED, 
                        whereas the default is NOCOLORIZE.
        --no-wrapper    Changes the way colorization works which is sometimes
                        useful in Windows.
        --noexec        Used only with --interactive.  If present, it does
                        not execute source code input interactively, 
                        although it processes it normally in all other
                        ways.
        """ % parms["compiler"])
        '''
        Here are some former OPTIONS I've at least temporarily discontinued
        because they weren't thought out well.  --no-library is now the 
        default, and --library isn't functional.
        --no-library    Do not try to load or update a template library.
        --library=F     Specifies the filename of the library of structure
                        templates.  By default, "yaHAL-default.templates".
                        This option can be used multiple times, but any new
                        structure templates encountered during preprocessing
                        will only be added to the final library file specified.
                        This option must precede the HAL/S source filenames.
       '''
        sys.exit(0)
    elif param == "--interactive":
        interactive = True
    elif param == "--colorize":
        colorize = True
    elif param == "--no-wrapper":
        ansiWrapper = False
    elif param == "--noexec":
        noexec = True
    elif param[:6] == "--tab=":
        tabSize = int(param[6:])
    elif param == "--no-compile":
        noCompile = True
    elif param == "--lbnf":
        lbnf = True
        bnf = False
    elif param == "--bnf":
        bnf = True
        lbnf = False
    elif param[:11] == "--compiler=":
        parms["compiler"] = param[11:]
    elif param == "--trace":
        trace = True
    elif param == "--no-library":
        print("Note: The --no-library option is no longer of use.")
    elif param[:10] == "--library=":
        print("Note: The --library option is no longer of use.")
    elif param[:1] == "-":
        print("Unknown parameter:", param)
        sys.exit(1)
    else:
        fileIndex = astSourceFile(PALMAT, param)
        start = len(halsSource)
        halsFile = open(param, "r")
        halsSource += halsFile.readlines()
        halsFile.close()
        if len(halsSource) == start:
            continue
        for i in range(len(metadata), len(halsSource)):
            m = { "file": fileIndex, "lineNumber" : i + 1 } # Lines numbered from 1.
            if halsSource[i][:1] == "C":
                m["comment"] = True
            metadata.append(m)

# Interpret or compile.
if not interactive:
    PALMAT = constructPALMAT()
    PALMAT["sourceFiles"] = files
    processSource(PALMAT, halsSource, metadata, noCompile, lbnf, bnf, trace)
    optimizePALMAT(PALMAT)
else:
    from interpreterLoop import interpreterLoop
    interpreterLoop(colorize, not noexec, lbnf, bnf, ansiWrapper)

