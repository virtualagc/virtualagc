#!/usr/bin/env python3
'''
License:    This program is declared by its author, Ronald Burkey, to be the 
            U.S. Public Domain, and may be freely used, modifified, or 
            distributed for any purpose whatever.
Filename:   fieldParser.py
Purpose:    This is part of the ASM101S assembler for IBM AP-101 
            assembly language.
Requires:   TatSu (see https://github.com/neogeny/TatSu)
Contact:    info@sandroid.org
Refer to:   https://www.ibiblio.org/apollo/ASM101S.html
History:    2024-09-12 RSB  Began.

There is a stand-alone mode that can be used for testing and certain setups
(search for `standAlone`), but mainly this file is a module to be imported into 
ASM101S.  As a module, it provides parsing for either the name field, the
operation field, or most-importantly, the operand field of an assembly-language
statement.  It does *not* parse a statement into these individual fields, nor
does it perform any actions on the basis of that parsing, other than giving a 
representation of the parse tree.  The entire field to be parsed (and nothing
else!) is expected to be provided as input.  In particular, for operand fields,
all continuation cards should be merged to provide a single operand string
without embedded spaces other than those in quoted strings or as required in
expressions.  This merging process is simple in almost all cases, but in the
case of macro-prototype lines or macro-invocation lines it's very hard and 
should be accomplished via the provided `joinOperandMacro` function.

The output is an ordered pair:
    
    A boolean indication of success vs failure
    
    The parse tree, which in the form of a tuple of nested tuples.

As a module, it:

    1.  Imports the modules for all of the defined parsers.  (As a one-time
        setup, the modules should be pre-compiled after any changes to the 
        grammars via `fieldParser.py --generate`.)
    2.  Exposes the parsers to the importing program as the functions:
                `parserBceAll`                Operand of a BCE instruction.
                `parserMscAll`                Operand of an MSC instruction.
                `parserNameCode`              Any name field outside of a macro.
                `parserNameMacrodef`          Name field in a macro definition.
                `parserOperationAll`          Any operation field.
                `parserOperandInvocation`     Operand of a macro definition.
                `parserOperandInvocation0`    Called by `joinOperandMacro`
                `parserOperandPrototype`      Operand of a macro prototype
                `parserOperandPrototype0`     Called by `joinOperandMacro`
                `parserRiAll`                 Operand of an RI instruction
                `parserRrAll`                 Operand of an RR instruction
                `parserRsAll`                 Operand of an RS instruction
                `parserSiAll`                 Operand of an SI instruction
                `parserSrsAll`                Operand of an SRS instruction
    3.  Exposes the function `joinOperandMacro` to the importing program.
        
Due to bugs at the present writing (2024-09-15), though probably fixed soon 
afterward (see https://github.com/neogeny/TatSu/issues/337), the parsers should
always be called via `parserXXXXX(fieldToBeParsed, whitespace='')`.
'''

import tatsu

standAlone = (__name__ == "__main__")
generateLocal = False
generateModules = False

helpMessage ="""
Stand-alone mode for `fieldParser` module, which provides parsers for various
grammars used by ASM101S.

Usage:
    fieldParser.py [OPTIONS]

By default, the parsers are imported from various Python source-code files with
names such as parser_XXXXX.py.  This behavior is modified by the OPTIONS.  The
--generate option causes the parser_XXXXX.py to be created (or overwritten)
before being imported.  The --local option causes the parser_XXXXX.py files to
be ignored completely, and for the parsers instead to be generated and used by
fieldParser.py, but not to be saved.
"""

if standAlone:
    import sys
    for parm in sys.argv[1:]:
        if parm == "--generate":
            generateModules = True
        elif parm == "--local":
            generateLocal = True
        elif parm == "--help":
            print(helpMessage)
            sys.exit(0)
        else:
            print("Unknown parameter %s" % parm)
            sys.exit(1)
    
    # Compile a grammar for local use here or else convert it to Python 
    # module for (perhaps) quicker startup in ASM101S.  In the former case it
    # returns the generated parser class, while in the latter case it returns None,
    # and the calling code is expected to import the module.
    def compile(grammar):
        name = None
        lines = grammar.split('\n')
        for line in lines:
            if "@@grammar" in line:
                fields = line.split("::")
                name = fields[1].strip().lower()
                break
        if generateModules:
            if name != None:
                moduleName = "parser_" + name
                print("Generating %s ..." % moduleName)
                source = tatsu.to_python_sourcecode(grammar)
                f = open(moduleName + ".py", "wt")
                f.write(source)
                f.close()
                return None
        if generateLocal:
            if name != None:
                print("Generating %s ..." % name)
            return tatsu.compile(grammar)
    
    #=============================================================================
    # Consult https://tatsu.readthedocs.io/en/stable/syntax.html for explanations
    # of the syntax used for describing grammars.
    # Here are various generic rules I use later in multiple grammars used in 
    # more-specific contexts.  Note in general that *all* of the grammars defined
    # within are whitespace-sensitive, i.e. they do not ignore whitespace unless
    # explicitly made to do so.
    
    IDENTIFIER = '''
        identifier = /[@#$A-Z][@#$A-Z0-9]*/ ;
    '''
    
    VARIABLE = '''
        variable = /&[@#$A-Z][@#$A-Z0-9]*/ ;
    '''
    
    SEQUENCE_SYMBOL = '''
        sequenceSymbol = /[.][@#$A-Z][@#$A-Z0-9]*/ ;
    '''
    
    CONSTANT = '''
        constant = 
            | /[0-9]+/ 
            | "X'" /[0-9A-F]+/ "'"
            | "B'" /[0-1]+/ "'" 
            | "L'" identifier
            ;
    '''
    
    SDTERM = '''
        sdTerm = 
            | /[0-9]+/ 
            | "X'" /[0-9A-F]+/ "'"
            | "B'" /[0-1]+/ "'" 
            | "C'" /[^']*/ { "''" /[^']*/ } "'"
            ;
    '''
    
    DC_CONSTANT = '''
        dcConstant = 
            | [ number ] [ scale ] [ exp ] /[CXB]/ [ len ] char 
            | [ number ] [ scale ] [ exp ] /[FHEDLPZ]/ [ len ] data 
            | [ number ] [ scale ] [ exp ] /[AYSQV]/ [ len ] addresses 
            ;
        char = "'" /[^']*/ { "''" /[^']*/ } "'"
        data = "'" element { ',' element } "'" ;
        element = /[^,]+/
        addresses = '(' arithmeticExpression { ',' arithmeticExpression } ')' ;
        len = 'L' [ '.' ] [ '+' | '-' ] number ;
        scale = 'S' [ '+' | '-' ] number;
        exp = 'E' [ '+' | '-' ] number;
        number = ( /[0-9]+/ | '(' arithmeticExpression ')' );
    '''
    
    REGISTER = '''
        register = 
            | identifier 
            | variable 
            | constant 
            ;
    '''
    
    IMMEDIATE = '''
        immediate = 
            | identifier
            | variable
            | constant
            ;
    '''
    
    ARITHMETIC_EXPRESSION = '''
        arithmeticExpression = term  { ( '+' | '-' ) term } ;
        term = factor  { ( '*' | '/' ) factor } ;
        factor = 
            | constant 
            | identifier 
            | variable 
            | '('  arithmeticExpression  ')' 
            | '*'
            ;
    ''' + VARIABLE + IDENTIFIER + CONSTANT
    
    #=============================================================================
    # Definitions of the grammars for the various fields (name, operation, operand)
    # for the various contexts (macro prototype, macro invocation, etc.)  I've
    # named them somewhat systematically in the form FIELDTYPE_CONTEXT.  Each
    # of the grammars are individually compiled for subsequent use in parsing. See
    # https://archive.org/details/bitsavers_ibm360asmGLanguageRel21197201_10219231/page/11.
    
    # Name field for all code outside of macro definitions.
    NAME_CODE = '''
        @@grammar :: nameCode
        @@whitespace :: None
        name = subName { '.' subName } $ ;
        subName = 
            | variable '(' arithmeticExpression ')'
            | variable
            | identifier
            ;
    ''' + ARITHMETIC_EXPRESSION
    
    # Name field within macro definitions.  It's that same as `NAME_CODE`, except
    # that it allows so-called "sequence symbols" as well.
    NAME_MACRODEF = '''
        @@grammar :: nameMacrodef
        @@whitespace :: None
        name = 
            | sequenceSymbol $
            | subName { '.' subName } $ 
            ;
        subName = 
            | variable '(' arithmeticExpression ')'
            | variable
            | identifier
            ;
    ''' + ARITHMETIC_EXPRESSION + SEQUENCE_SYMBOL
    
    # Operation field for all contexts.  At the moment, it's actually identical
    # to `NAME_CODE`, but with the rule names `name` and `subName` changed to 
    # `operation` and `subOperation.
    OPERATION_ALL = '''
        @@grammar :: operationAll
        @@whitespace :: None
        operation = subOperation { '.' subOperation } $ ;
        subOperation = 
            | variable '(' arithmeticExpression ')'
            | variable
            | identifier
            ;
    ''' + ARITHMETIC_EXPRESSION
    
    # Operand field for an RR instruction.
    RR_ALL = '''
        @@grammar :: rrAll
        @@whitespace :: None
        operand = register ',' register $ ;
    ''' + REGISTER + IDENTIFIER + VARIABLE + CONSTANT
    
    # Operand field for an RS instruction.
    RS_ALL = '''
        @@grammar :: rsAll
        @@whitespace :: None
        operand = 
            | register ',' arithmeticExpression '(' register ')' $ 
            | register ',' arithmeticExpression '(' register ',' register ')' $
            ;
    ''' + ARITHMETIC_EXPRESSION + REGISTER
    
    # Operand field for an RI instruction.
    RI_ALL = '''
        @@grammar :: riAll
        @@whitespace :: None
        operand = register ',' immediate $ ;
    ''' + IMMEDIATE + REGISTER + IDENTIFIER + VARIABLE + CONSTANT
    
    # Operand field for an SRS instruction.
    SRS_ALL = '''
        @@grammar :: srsAll
        @@whitespace :: None
        operand = register ',' immediate $ ;
    ''' + IMMEDIATE + REGISTER + IDENTIFIER + VARIABLE + CONSTANT
    
    # Operand field for an SI instruction.
    SI_ALL = '''
        @@grammar :: siAll
        @@whitespace :: None
        operand = arithmeticExpression '(' register '),' immediate $ ;
    ''' + ARITHMETIC_EXPRESSION + IMMEDIATE + REGISTER
    
    # Operand field for an MSC instruction.
    MSC_ALL = '''
        @@grammar :: mscAll
        @@whitespace :: None
        operand = 
            | constant ',' identifier '(' constant ')' $
            | constant ',' identifier $
            | arithmeticExpression '(' constant ')' $ 
            | arithmeticExpression $
            ;
    ''' + ARITHMETIC_EXPRESSION
    
    # Operand field for an BCE instruction.
    BCE_ALL = '''
        @@grammar :: bceAll
        @@whitespace :: None
        operand = 
            | arithmeticExpression '(' constant ')' $ 
            | arithmeticExpression ',' arithmeticExpression $
            | arithmeticExpression $
            ;
    ''' + ARITHMETIC_EXPRESSION
    
    # Operand for macro prototypes.
    PARAMETER = '''
        parameter = 
            | variable '=' /[^, ]*/
            | variable
            ;
    ''' + VARIABLE
    OPERAND_PROTOTYPE = '''
        @@grammar :: operandPrototype
        @@whitespace :: None
        operand = 
            | parameter { ',' parameter } / / 
            | parameter { ',' parameter } $
            | $
            ;
    ''' + PARAMETER
    # Operand for initial parsing of macro prototype cards *before* all continuation
    # lines have been joined into one long string.  It's used only for the
    # purpose of determining how to deal with continuation lines in macro 
    # prototypes.  (After continuation lines have been properly handled to create a 
    # single merged string, then the final parsing is done using the 
    # OPERAND_PROTOTYPE rule.)  This is a trickier rule than any of those rules 
    # above.  It covers 4 possibilities, each of which implies a different manner 
    # of merging the next continuation lines.  Merging requires knowledge of how 
    # much of the input string was parsed.  The use of `@@parseinfo` and `endX+:` 
    # in the rule causes a the output to be a dictionary (instead of an
    # AST) which gives us 2 important data:  which specific subpattern was matched
    # and how much of the input string was used up in doing so.
    OPERAND_PROTOTYPE_0 = '''
        @@grammar :: operandPrototype0
        @@whitespace :: None
        operand = 
            | end0+: ( parameter { ',' parameter } / / )
            | end1+: ( parameter { ',' parameter } ',' / / )
            | end2+: ( parameter { ',' parameter } [ ',' [ '&' ] ] ) $
            | end3+: ( / */ ) $
            ;
    ''' + PARAMETER
    
    # Here we have the equivalents to OPERAND_PROTOTYPExx but for macro invocations
    # rather than macro prototypes.  The allowed formats for items used as 
    # replacement parameters are unknown, and I've simply taken a wild stab:
    # any quoted string (with the usual provision for duplicated single-quotes)
    # or any string at all not containing commas or spaces.
    # Unfortunately, this stuff has a big problem with grouped arguments like
    #        ( ... )
    # in that it's extremely likely for these to be continued across cards,
    # and there's no way to parse an incomplete item as anything meaningful.
    # Consequently, detection of that condition is extremely crude.
    LIST = '''
        list = listItem { ',' listItem } ;
        listItem = 
            | '(' list ')'
            | /[^ ,()]*/
            ;
    '''
    REPLACEMENT = '''
        replacement = 
            | identifier "=" "'" /[^']*/ { "''" /[^;]*/ } "'"
            | identifier '=' '(' list ')'
            | identifier '=' /[^, ()]*/
            | "'" /[^']*/ { "''" /[^;]*/ } "'"
            | '(' list ')'
            | /[^, ()]*/
            ;
    ''' + IDENTIFIER + LIST
    OPERAND_INVOCATION = '''
        @@grammar :: operandInvocation
        @@whitespace :: None
        operand = [ replacement { ',' replacement } ] ;
    ''' + REPLACEMENT
    OPERAND_INVOCATION_0 = '''
        @@grammar :: operandInvocation0
        @@whitespace :: None
        operand = 
            | end0+: ( replacement { ',' replacement } / / )
            | end2+: ( replacement { ',' replacement } [ ',' [ "'" /[^']*/ ] ] ) $
            | end3+: ( / */ ) $
            | end4+: ( /[^ ]+/ / */ ) $
            ;
    ''' + REPLACEMENT

    # Create parsers from the grammars.
    
    parserBceAll = compile(BCE_ALL)
    parserMscAll = compile(MSC_ALL)
    parserNameCode = compile(NAME_CODE)
    parserNameMacrodef = compile(NAME_MACRODEF)
    parserOperationAll = compile(OPERATION_ALL)
    parserOperandInvocation = compile(OPERAND_INVOCATION)
    parserOperandInvocation0 = compile(OPERAND_INVOCATION_0)
    parserOperandPrototype = compile(OPERAND_PROTOTYPE)
    parserOperandPrototype0 = compile(OPERAND_PROTOTYPE_0)
    parserRiAll = compile(RI_ALL)
    parserRrAll = compile(RR_ALL)
    parserRsAll = compile(RS_ALL)
    parserSiAll = compile(SI_ALL)
    parserSrsAll = compile(SRS_ALL)

if not standAlone or not generateLocal: 
    if standAlone:
        print("Importing parsers ...")
    import parser_bceall
    parserBceAll = parser_bceall.bceAllParser()
    import parser_mscall
    parserMscAll = parser_mscall.mscAllParser()
    import parser_namecode
    parserNameCode = parser_namecode.nameCodeParser()
    import parser_namemacrodef
    parserNameMacrodef = parser_namemacrodef.nameMacrodefParser()
    import parser_operandinvocation0
    parserOperandInvocation0 = parser_operandinvocation0.operandInvocation0Parser()
    import parser_operandinvocation
    parserOperandInvocation = parser_operandinvocation.operandInvocationParser()
    import parser_operandprototype0
    parserOperandPrototype0 = parser_operandprototype0.operandPrototype0Parser()
    import parser_operandprototype
    parserOperandPrototype = parser_operandprototype.operandPrototypeParser()
    import parser_operationall
    parserOperationAll = parser_operationall.operationAllParser()
    import parser_riall
    parserRiAll = parser_riall.riAllParser()
    import parser_rrall
    parserRrAll = parser_rrall.rrAllParser()
    import parser_rsall
    parserRsAll = parser_rsall.rsAllParser()
    import parser_siall
    parserSiAll = parser_siall.siAllParser()
    import parser_srsall
    parserSrsAll = parser_srsall.srsAllParser()

#=============================================================================
# Auxiliary functions.

# Forms the merged operand field of a macro prototype or macro invocation 
# lines, taking into account continuation lines.  The arguments are:
#    `lines`    A list of source-code lines.
#    `index`    The starting index in `lines` of the macro prototype line.
#    `column`   The column in `lines[index]` at which the operand field starts.
#               If the operand field doesn't start on the first card, then
#               `column` is 71.
#    `invoke`   False for macro prototype lines, True for macro invocation lines.
# Returns True,operand on success or False,None on error.  Comments are 
# discarded.
def joinOperandMacro(lines, index, column, invoke=False):
    continuation = False
    while True:
        if index >= len(lines):
            return False,None
        line = lines[index]
        if continuation:
            operand = operand + line[15:71]
        else:
            operand = line[column:71]
        continuation = (line[71] != " ")
        index += 1
        try:
            if invoke:
                ret = parserOperandInvocation0.parse(operand, parseinfo=True, whitespace='')
            else:
                ret = parserOperandPrototype0.parse(operand, parseinfo=True, whitespace='')
            endpos = ret.parseinfo.endpos
            if "end0" in ret and invoke and endpos > 1 and \
                    operand[endpos-2] == ',':
                operand = operand[:endpos-1]
            elif "end0" in ret:
                return True,operand[:endpos-1]
            elif "end1" in ret:
                operand = operand[:endpos-1]
            elif "end2" in ret:
                pass
            elif "end3" in ret:
                operand = ""
            elif "end4" in ret:
                operand = operand.rstrip()
            else:
                return False,None
        except:
            return False,None
        if not continuation:
            return True,operand

#=============================================================================
# Some test code.  The test program does two things.
#
# First, it parses various hard-coded sequences of punchcards.  These 
# datasets are all taken from actual FSW source code.  Some are for the 
# prototype lines of macro definitions, others are invocations of those same 
# macros.
#
# Second, there's an interactive mode in which the user can enter arbitrary
# strings.  The program runs the strings through the parsers of every defined
# grammar, and prints the results.
#
# An auxiliary usage (orthogonal to what's mentioned above) is to run it with
# the --generate command-line switch to pre-compile the parsers for all of the
# grammars as Python modules that can be `import`ed later by ASM101S.

if __name__ == "__main__":
    import sys
    import pprint
    
    #-------------------------------------------------------------------------
    # A selection of lines of source code follow, for testing the 
    # `joinOperandMacro` function.
    print("Macro prototype lines -------------------------------------------")
    testLines1 = [ 
        "&NAME    FCW2  &Y,&ENDRF=0,&INCRM=0,&POLRX=0,&POLRY=0,&ANCTL1=0,&ANCTL2*000200AA",
        "               =0,&ANCTL3=0,&ANCTL4=0,&ANCTL5=0                         000300AA"
        ]
    print(joinOperandMacro(testLines1, 0, 15))
    testLines2 = [
        "&NAME    FCW3  &E,&V,&SC=0                      75080                   000200AA"
        ]
    print(joinOperandMacro(testLines2, 0, 15))
    testLines3 = [
        " FTBEGIN &TID=NO,&STACKX=1,&EQUS=YES,&PDE=YES,&DSTACK=NO,&TYPE=MAIN     000200AA"
        ]
    print(joinOperandMacro(testLines3, 0, 9))
    testLines4 = [
        "&NAME    GENERATE &TYPE=,&COPY=,&NPCT=,&NTQE=,&NEQE=,&NIOQE=,&STOR=,   X007900AQ",
        "               &NBRQ=                                                   008000AQ"
        ]
    print(joinOperandMacro(testLines4, 0, 18))
    testLines5 = [
        "         IF    &P1,&P2,&P3,&P4,&P5,&P6,&P7,&P8,&P9,&P10,&P11,&P12,&P13,X000200AA",
        "               &P14,&P15,&P16,&P17,&P18,&P19,&P20,&P21,&P22,&P23,&P24,&X000300AA",
        "               P25,&P26,&P27,&P28,&P29,&P30,&P31,&P32,&P33,&P34,&P35,&PX000400AA",
        "               36,&P37,&P38,&P39,&P40,&P41,&P42,&P43,&P44,&P45,&P46,&P4X000500AA",
        "               7,&P48,&P49,&P50,&CC=                                    000600AA"
        ]
    print(joinOperandMacro(testLines5, 0, 15))
    testLines6 = [
        "         TFRST                                                          000200AA"
        ]
    print(joinOperandMacro(testLines6, 0, 71))
    testLines7 = [
        "&BUSTYP  TCBUS &LST1,&LST2,&LST3,&LST4,&LST5,&LST6,&LST7,&LST8,&LST9,  X000200AA",
        "               &LST10,&LST11,&LST12,&LST13,&LST14,&LST15,&LST16,&LST17,X000300AA",
        "               &LST18,&LST19,&LST20,&LST21,&LST22,&LST23,&LST24,&LST25,X000400AA",
        "               &LST26,&LST27,&LST28,&LST29,&LST30                       000500AA"
        ]
    print(joinOperandMacro(testLines7, 0, 15))
    testLines8 = [
        "         TFBCD &FCMLST=,&PLMLST=,                                      X000200AH",
        "               &DEVID01,&DEVID02,&DEVID03,&DEVID04,&DEVID05,           X000300AH",
        "               &DEVID06,&DEVID07,&DEVID08,&DEVID09,&DEVID10,           X000400AH",
        "               &DEVID11,&DEVID12,&DEVID13,&DEVID14,&DEVID15,           X000500AH",
        "               &DEVID16,&DEVID17,&DEVID18,&DEVID19,&DEVID20,           X000600AH",
        "               &DEVID21,&DEVID22,&DEVID23,&DEVID24,&DEVID25,           X000700AH",
        "               &DEVID26,&DEVID27,&DEVID28,&DEVID29,&DEVID30,           X000800AH",
        "               &DEVID31,&DEVID32,&DEVID33,&DEVID34,&DEVID35,           X000900AH",
        "               &DEVID36,&DEVID37,&DEVID38,&DEVID39,&DEVID40,           X001000AH",
        "               &DEVID41,&DEVID42,&DEVID43,&DEVID44,&DEVID45,           X001100AH",
        "               &DEVID46,&DEVID47,&DEVID48,&DEVID49,&DEVID50,           X001200AH",
        "               &DEVID51,&DEVID52,&DEVID53,&DEVID54,&DEVID55,           X001300AH",
        "               &DEVID56,&DEVID57,&DEVID58,&DEVID59,&DEVID60,           X001400AH",
        "               &DEVID61,&DEVID62,&DEVID63,&DEVID64,&DEVID65,           X001500AH",
        "               &DEVID66,&DEVID67,&DEVID68,&DEVID69,&DEVID70,           X001600AH",
        "               &DEVID71,&DEVID72,&DEVID73,&DEVID74,&DEVID75,           X001700AH",
        "               &DEVID76,&DEVID77,&DEVID78,&DEVID79,&DEVID80,           X001800AH",
        "               &DEVID81,&DEVID82,&DEVID83,&DEVID84,&DEVID85,           X001900AH",
        "               &DEVID86,&DEVID87,&DEVID88,&DEVID89,&DEVID90,           X002000AH",
        "               &DEVID91,&DEVID92,&DEVID93,&DEVID94,&DEVID95,           X002100AH",
        "               &DEVID96,&DEVID97,&DEVIC98,&DEVID99,&DEVIDA0,           X002200AH",
        "               &DEVIDA1,&DEVIDA2,&DEVIDA3,&DEVIDA4,&DEVIDA5,           X002300AH",
        "               &DEVIDA6,&DEVIDA7,&DEVIDA8,&DEVIDA9,&DEVIDB0,           X002400AH",
        "               &DEVIDB1,&DEVIDB2,&DEVIDB3,&DEVIDB4,&DEVIDB5,           X002500AH",
        "               &DEVIDB6,&DEVIDB7,&DEVIDB8,&DEVIDB9,&DEVIDC0             002600AH"
        ]
    print(joinOperandMacro(testLines8, 0, 15))
    testLines9 = [
        "         TFPSA &TYPE,&PON=,&POF=,&SR=,&MC=,&PC=,&SVC=,&PC1=,&PC2=,&IM=,X004600AG",
        "               &EI0=,&EI1=,&EI2=,&EI3=,&SI=,&DSR=1,&BSR=1,&PD=YES,     X004700AG",
        "               &TRCPGM=,&TRCBGN=,&TRCEND=                               004800AG"
        ]
    print(joinOperandMacro(testLines9, 0, 15))
    testLines10 = [
        "         TFRST                                                         ?000200AA",
        "               &A,&B  THIS IS MY COMMENT                                        "
        ]
    print(joinOperandMacro(testLines10, 0, 71))
    
    print("Macro invocation lines ------------------------------------------")
    testLines1A = [
        "         FCW2   ANCTL2=1      DISABLE TRANSLATE MODE                    002600AB"
        ]
    testLines1B = [
        "         FCW2   POLRX=1,POLRY=1,ANCTL5=1,ANCTL4=1,ANCTL1=1              029800AB"
        ]
    print(joinOperandMacro(testLines1A, 0, 16, True))
    print(joinOperandMacro(testLines1B, 0, 16, True))
    testLines4A = [
        "         GENERATE COPY=(TFPCT,TFTQE,TFEQE)                              009300AK"
        ]
    testLines4B = [
        "         GENERATE TYPE=CSECT,NPCT=35,NTQE=30,NEQE=25,NBRQ=20,          X048100CE",
        "               STOR=(1,1)                                               048200BW"
        ]
    print(joinOperandMacro(testLines4A, 0, 18, True))
    print(joinOperandMacro(testLines4B, 0, 18, True))
    testLines5A = [
        "         IF    (C,R4,EQ,=F'0'),AND,(C,R5,EQ,=F'0') THEN VALUE ZERO      035400AO"
        ]
    print(joinOperandMacro(testLines5A, 0, 15, True))
    
    testLines8A = [
        "         TFBCD FCMLST=(FCMODT,FCPCTAB-FCMODT,FCMODEND-FCPCTAB,         X113700CN",
        "               FCMODDEV,29),                                           X113750CN",
        "               PLMLST=(PLMODT,0,PLMODEND-PLPCTAB,PLMODDEV,13),         X113800CN",
        "               (1,,46,FIOIPRPC),                                       *113900BE",
        "               (2),                                                    *113950BJ",
        "               (3,(1,2,3,4,5),291,FIOICCPC),                           *114000BE",
        "               (4,(10,11),,20),                                        *114050BE",
        "               (5,6,,1),                                               *114100BA",
        "               (6,7,,1),                                               *114200BA",
        "               (7,8,,1),                                               *114300BA",
        "               (8,9,,1),                                               *114400BA",
        "               (9,(20,21,22,23),,2),                                   *114500BA",
        "               (10,24,,3),                                             *114600BA",
        "               (11,(18,19)),                                           *114700BA",
        "               (12,(14,15,16,17,20,21,22,23),30,FIOFCBPC),             *114800BE",
        "               (13,(14,15,16,17,20,21,22,23),348,11),                  *115000BV",
        "               (14,(14,15,16,17,20,21,22,23),855,18),                  *115200BK",
        "               (15,(14,15,16,17,20,21,22,23),355,12),                  *115300BV",
        "               (16,(14,15,16,17,20,21,22,23),173,21),                  *115500CI",
        "               (17,(20,21,22),103,14),                                 *115700BE",
        "               (18,(20,21,22),45,FIOIMUWP),                            *115800BK",
        "               (19,20,19,4),                                           *115900BK",
        "               (20,21,19,4),                                           *116000BK",
        "               (21,22,19,4),                                           *116100BK",
        "               (22,(20,21,22),47,4),                                   *116200BE",
        "               (23,(20,21,22,23),32,FIOCWWRP),                         *116300BE",
        "               (24,(20,22),141,13),                                    *116400BE",
        "               (25,(14,15,16,17),59,FIOFAOPC),                         *116500BE",
        "               (26,(14,15,16,17,20,21,22,23),206,19),                  *116600BE",
        "               (27,20,,5),                                             *116700BA",
        "               (28,21,,5),                                             *116800BA",
        "               (29,22,,5),                                             *116900BA",
        "               (30,23,,5),                                             *117000BA",
        "               (31,14,,5),                                             *117100BA",
        "               (32,15,,5),                                             *117200BA",
        "               (33,16,,5),                                             *117300BA",
        "               (34,17,,5),                                             *117400BA",
        "               (35,(14,15,16,17),,5),                                  *117500BA",
        "               (36,(20,21,22,23),,5),                                  *117600BA",
        "               (37,(14,15,16,17,20,21,22,23),24,FIOHD2PC),             *117700BK",
        "               (38,(20,21,23),32,24),                                  *117800BU",
        "               (39,,21,23),                                            *117810CH",
        "               (40,(14,15,16,17),1161,FIOG9OPC),                       *117820CX",
        "               (41,,,26),                                              *117825CC",
        "               (42,,,25),                                              *117830CB",
        "               (43,(10,11),29,FIOPFBPC),                               *117900BE",
        "               (44,10,20,FIOPF1PC),                                    *118000BK",
        "               (45,11,37,FIOPF1PC),                                    *118100BK",
        "               (46,10,,5),                                             *118200BA",
        "               (47,11,,5),                                             *118300BA",
        "               (48,(10,11),,6),                                        *118500BJ",
        "               (49,10,,7),                                             *118700BJ",
        "               (50,11,,7),                                             *118800BJ",
        "               (51,(10,11),,16),                                       *118810BJ",
        "               (52,(10,11),,17),                                       *118815BJ",
        "               (53,(10,11),,16),                                       *118820BJ",
        "               (54,(10,11),,16),                                       *118825BJ",
        "               (55,(10,11),,16),                                       *118830BJ",
        "               (56,(10,11),,16),                                       *118835BJ",
        "               (57,(10,11),,16),                                       *118840BJ",
        "               (58,(10,11),,16),                                       *118845BJ",
        "               (59,(10,11),,22),                                       *118880BJ",
        "               (60,10,,10),                                            *118890BJ",
        "               (61,12,,8),                                             *118900BJ",
        "               (62,12,,5),                                             *119000BJ",
        "               (63,12,570,15),                                         *119100CH",
        "               (64,12,,5),                                             *119200BJ",
        "               (65,12,233,9),                                          *119300BX",
        "               (66,12,229,FIOMCIWP),                                   *119310BX",
        "               (67,12,,5),                                             *119311BJ",
        "               (68,(10,11),,5),                                        *119400CL",
        "               (69,(10,11),,5),                                        *119500CL",
        "               (70,(14,20),,5),                                        *119600CL",
        "               (71,(15,21),,5),                                        *119700CL",
        "               (72,(16,22),,5),                                        *119800CL",
        "               (73,(17,23),,5),                                        *119900CL",
        "               (74,(14,20),,5),                                        *120000CL",
        "               (75,(15,21),,5),                                        *120100CL",
        "               (76,(16,22),,5),                                        *120200CL",
        "               (77,(17,23),,5),                                        *120300CL",
        "               (78,(21),162,FIOGPSOP),                                 *120400CW",
        "               (79,(20,21,22),109,27),                                 *120500CN",
        "               (80,(14,15,16,17),,5)                                    120700BJ"
        ]
    print(joinOperandMacro(testLines8A, 0, 15, True))

    #-------------------------------------------------------------------------
    # An interactive mode for inputting arbitrary "operand" fields (confined to
    # a single card) and testing them against the defined operand grammars.
    
    def exercise(rule, parser):
        try:
            ast = parser.parse(line, whitespace='')
            print("%s:" % rule)
            print(ast)
            pprint.pprint(ast, indent=2, width=20)
        except:
            print("%s failed" % rule)
    
    print("Interactive input loop ------------------------------------------")
    while True:
        print("Input a string (empty to quit): ", end="")
        line = input().strip('\n\r')
        if len(line) == 0:
            break
        print("Matching: '%s'" % line)
        exercise("NAME_CODE", parserNameCode)
        exercise("NAME_MACRODEF", parserNameMacrodef)
        exercise("OPERATION_ALL", parserOperationAll)
        exercise("RR_ALL", parserRrAll)
        exercise("RS_ALL", parserRsAll)
        exercise("RI_ALL", parserRiAll)
        exercise("SRS_ALL", parserSrsAll)
        exercise("SI_ALL", parserSiAll)
        exercise("MSC_ALL", parserMscAll)
        exercise("BCE_ALL", parserBceAll)
        exercise("OPERAND_PROTOTYPE_0", parserOperandPrototype0)
        exercise("OPERAND_PROTOTYPE", parserOperandPrototype)
        exercise("OPERAND_INVOCATION_0", parserOperandInvocation0)
        exercise("OPERAND_INVOCATION", parserOperandInvocation)
