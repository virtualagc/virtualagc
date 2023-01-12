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
from interpreterLoop import interpreterLoop
from palmatAux import constructPALMAT

#Parse the command-line arguments.
tabSize = 8
halsSource = []
metadata = []
files = []
noLibrary = False
libraryFilename = "yaHAL-default.templates"
structureTemplates = {}
noCompile = False
lbnf = False
bnf = False
trace = False
interactive = False
colorize = False
noexec = False
for param in ["--library="+libraryFilename] + sys.argv[1:]:
    if param == "--help":
        print("""
        This is a preprocessor+compiler for HAL/S code. The principal 
        functionality is preprocessing, and the compiler is simply invoked as
        an external program. The preprocessing is necessary because the external
        compiler is valid only for a context-free grammar, and the official
        HAL/S grammar is not context-free.  The preprocessor produces valid 
        HAL/S code but mangled in such a way that it can be parsed by a 
        context-free grammar.
        
        Usage:
            yaHAL-S-FC.py [OPTIONS] [SOURCE1.hal [SOURCE2.hal [...]]] >SOURCE.hal
        
        The OPTIONS are: 
        
        --tab=N         Tab size in source files; assumed to be 8.  No allowance
                        is made for different tab sizes in different source 
                        files, so let's just hope that never happens!  Probably 
                        the Shuttle source has no tabs anyway since it was 
                        supplied on
                        punchcards, but it's certainly possible to accidentally
                        end up with tabs if source is edited in modern editors.
        --no-library    Do not try to load or update a template library.
        --library=F     Specifies the filename of the library of structure
                        templates.  By default, "yaHAL-default.templates".
                        This option can be used multiple times, but any new
                        structure templates encountered during preprocessing
                        will only be added to the final library file specified.
                        This option must precede the HAL/S source filenames.
        --no-compile    Merely output preprocessed source, and do not attempt
                        to invoke the compiler.
        --compiler=F    Name of compiler's phase 1 (default %s).
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
        --noexec        Used only with --interactive.  If present, it does
                        not execute source code input interactively, 
                        although it processes it normally in all other
                        ways.
        """ % compiler)
        sys.exit(0)
    elif param == "--interactive":
        interactive = True
    elif param == "--colorize":
        colorize = True
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
        compiler = param[11:]
    elif param == "--trace":
        trace = True
    elif param == "--no-library":
        noLibrary = True
        structureTemplates = {}
        libraryFilename = None
        print("Note: Disabling template-library file, if any.")
    elif param[:10] == "--library=":
        libraryFilename = param[10:].strip()
        #print("Here", libraryFilename)
        # Read the structure-template library file.  This is just a text file
        # in which each line is a HAL/S STRUCTURE statement.
        try:
            f = open(libraryFilename, "r")
            for line in f:
                fields = line.split()
                identifier = fields[1]
                if identifier[-1:] == ":":
                    identifier = identifier[:-1]
                if identifier in structureTemplates:
                    print("Overwriting structure-template", identifier, \
                            file=sys.stderr)
                structureTemplates[identifier] = line.strip()
            f.close()
            #print(structureTemplates)
        except:
            print("Note: Structure-template library not found.", file=sys.stderr)
    elif param[:1] == "-":
        print("Unknown parameter:", param)
        sys.exit(1)
    else:
        files.append(param)
        start = len(halsSource)
        halsFile = open(param, "r")
        halsSource += halsFile.readlines()
        halsFile.close()
        if len(halsSource) == start:
            continue
        first = True
        for i in range(len(metadata), len(halsSource)):
            m = {}
            if first:
                m["file"] = param
                first = False
            if halsSource[i][:1] == "C":
                m["comment"] = True
            elif halsSource[i][:1] == "D":
                m["directive"] = True
                # If this is an INCLUDE TEMPLATE directive, then replace the
                # input line by the requested library template and append
                # the original line to the end of it as an inline comment.
                fields = halsSource[i].split()
                if len(fields) >= 4 and fields[1] == "INCLUDE" and \
                        fields[2] == "TEMPLATE":
                    templateName = fields[3]
                    if templateName in structureTemplates:
                        halsSource[i] = " " + structureTemplates[templateName] \
                            + "\t/*" + halsSource[i].strip()+ " */"
                    else:
                        m["errors"] = ["Structure template " + templateName + \
                            " requested by compiler directive not in libary."]
            metadata.append(m)

# Interpret or compile.
if not interactive:
    PALMAT = constructPALMAT()
    processSource(PALMAT, halsSource, metadata, libraryFilename, 
                    structureTemplates,
                    noCompile, lbnf, bnf, trace)
else:
    interpreterLoop(libraryFilename, structureTemplates, colorize, \
                    not noexec, lbnf, bnf)

