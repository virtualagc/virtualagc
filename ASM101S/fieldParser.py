#!/usr/bin/env python3
'''
License:    This program is declared by its author, Ronald Burkey, to be the 
            U.S. Public Domain, and may be freely used, modifified, or 
            distributed for any purpose whatever.
Filename:   fieldParser.py
Purpose:    This is the part of the ASM101S assembler for IBM AP-101 
            assembly language that's responsible for most parsing.
Requires:   TatSu (see https://github.com/neogeny/TatSu)
Contact:    info@sandroid.org
Refer to:   https://www.ibiblio.org/apollo/ASM101S.html
History:    2024-09-12 RSB  Began.
            2026-05-26 RSB  Fixed quoted-string value bug in `operandInvocation`
                            rule (i.e., macro named parameters of the form
                            KEY='STRING'.)
            2026-05-28 RSB  Repair for `mnote` rule, allowing ",'...'".
            2026-05-19 RSB  Added rule `orgAll`.
            2026-05-29 RSB  Implemented `ORG` for issue #1333.

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
should be accomplished via the provided `joinOperand` function.

The output is an ordered pair:
    
    A boolean indication of success vs failure
    
    The parse tree, which in the form of a tuple of nested tuples.

As a module, it:

    1.  Imports the modules for all of the defined parsers.  (As a one-time
        setup, the modules should be pre-compiled after any changes to the 
        grammars via `fieldParser.py --generate`.)
    2.  Exposes the function`parserASM` method to the importing program.  
        The parser is used as:
            AST = parserASM(text, rule)
        where `rule` is the name (as a string) of a rule in the `grammar`.
        For example, `parserASM(text, "arithmeticExpression")`.
    3.  Exposes the function `joinOperand` to the importing program.
'''

import tatsu

#=============================================================================
# Consult https://tatsu.readthedocs.io/en/stable/syntax.html for explanations
# of the syntax used for `grammar`.  Note that `grammar` is *not* the grammar
# for the assembly-language as such.  Rather, it is a collection of related
# rules which can be used for parsing specific individual elements of the 
# assembly language in particular contexts.  Therefore, when parsing a 
# substring containing such an element, the particular grammar rule that's 
# desired must be specified when the parser is invoked.
#
# (I suspect that a grammar for the language as a whole *could* be written, if
# the "alternate" form of continuation lines were eliminated and if
# if preprocessing were done to eliminate all continuation lines.  However, this
# is not such a grammar.)

grammar = \
'''
# Regarding @@whitespace, it may not be adequate and may require the parser to
# be called with whitespace=''.  See https://github.com/neogeny/TatSu/issues/337.
# Regarding @@eol_comments, I find that by default, a string beginning with
# '#' is treated by the parser as being empty.  I deduce that @@eol_comments
# is somehow causing this.  The only way to override that seems to be to 
# assign @@eol_comments some pattern which will never be matched.
@@grammar :: asm
@@whitespace :: None
@@parseinfo :: True
@@eol_comments :: /@g@a@r@b@a@g@e@/

#---------------------------------------------------------------------
# Start with a bunch of high-level rules corresponding to entire 
# fields (name, operation, operand) of source-code lines.

# Used by `joinOperand` for eliminating continuation lines in 
# macro prototypes.
operandPrototype0 = 
    | end0+: ( parameter { ',' parameter } / / )
    | end1+: ( parameter { ',' parameter } ',' / / )
    | end2+: ( parameter { ',' parameter } [ ',' [ '&' ] ] ) $
    | end3+: ( / */ ) $
    ;

# Used by `joinOperand` for elimination of continuation lines in 
# macro invocations
operandInvocation0 = 
    | end0+: ( replacement { ',' replacement } / / )
    | end2+: ( replacement { ',' replacement } [ ',' [ "'" /[^']*/ ] ] ) $
    | end3+: ( / */ ) $
    | end4+: ( /[^ ]+/ / */ ) $
    ;

# Operand field of macro prototypes (*after* continuation lines are
# eliminated).
operandPrototype = 
    | pi+: parameter { ',' pi+: parameter } / / 
    | pi+: parameter { ',' pi+: parameter } $
    | $
    ;

# Operand field of macro invocation (*after* continuation lines are
# eliminated).
operandInvocation = [ pi+: replacement { ',' pi+: replacement } ] ;

# Name field for all code outside of macro definitions.
nameCode = 
    | sv+: variable
    | id+: identifier
    ;

# Note the repeated subscripts.  A macro argument that is a sublist can be
# subscripted to any depth -- `&SYSLIST(2,2,3)`, `&COPY(&J,1)` -- which is a
# feature of Assembler H (GC26-3758-3, January 1974, p.13) rather than of
# Assembler F, and is used heavily by the FCOS macro library.  A SETA/SETB/SETC
# array still accepts only one subscript, but that is enforced when the
# variable is evaluated rather than here, since the grammar cannot tell the two
# apart.
nameSet =
    | sv+: sv $
    | sv+: sv '(' exp+: arithmeticExpression { ',' exp+: arithmeticExpression } ')' $
    ;

nameSet0 =
    | sv+: sv '(' exp+: arithmeticExpression { ',' exp+: arithmeticExpression } ')'
    | sv+: sv
    ;

# Name field within macro definitions.
nameMacrodef = 
    | sequenceSymbol $
    | subName { '.' subName } $ 
    ;
subName = 
    | variable
    | identifier
    ;

# Operation field for all contexts. 
operationAll = subOperation { '.' subOperation } $ ;
subOperation = 
    | variable
    | identifier
    ;

# Operand field for an RR instruction.
rrAll = [ R1+: arithmeticExpression ',' ] R2+: arithmeticExpression ( / / | $ ) ;
# R2 of LFXI is an IMMEDIATE, not a register: the generator range-checks it
# against -2 through 13 and encodes r2+2.  Restricting the grammar to a bare
# register or -1/-2 rejected the ordinary way of writing one, an offset within
# a parameter list -- `LFXI R1,TMHALMET-TMHALSRT`.  The literals stay ahead of
# the expression so nothing that parsed before parses differently now.
lfxiAll = [ R1+: register ',' ] R2+: ( '-2' | '-1' | arithmeticExpression ) ( / / | $ ) ;

# Operand field for an RS or SRS instruction.
#
# R1 is an arithmeticExpression rather than a bare register because for the
# branch-on-condition instructions it is not a register at all but a mask,
# and the macro library computes it:  DOPROC generates `BC 07-&CCVAL,...`,
# which reaches the assembler as `BC 07-7,#@LB5`.  `evalInstructionSubfield`
# already evaluates each subfield as an arithmetic expression, so nothing
# downstream had to change.  B2 and X2 stay bare registers, since those really
# are register numbers and widening them invites ambiguity with the D2(B2)
# form.
rsAll =
    | [ R1+: arithmeticExpression ',' ] "=" L2+: lconstant ( / / | $ )
    | [ R1+: arithmeticExpression ',' ] D2+: arithmeticExpression '(' B2+: register ')'  ( / / | $ )
    | [ R1+: arithmeticExpression ',' ] D2+: arithmeticExpression '(' X2+: register ',' B2+: register ')'  ( / / | $ )
    # An OMITTED index, `D2(,B2)`, which System/360 allows wherever `D2(X2,B2)`
    # is written and which four OI301700 modules use -- `LH R0,#@LB39-*-3(,R0)`.
    | [ R1+: arithmeticExpression ',' ] D2+: arithmeticExpression '(' noX+: ',' B2+: register ')'  ( / / | $ )
    | [ R1+: arithmeticExpression ',' ] D2+: arithmeticExpression '(' ')'  ( / / | $ )
    | [ R1+: arithmeticExpression ',' ] D2+: arithmeticExpression  ( / / | $ )
    ;

# Operand field for an RI instruction.
riAll = R2+: register ',' I1+: arithmeticExpression [ "(" ")" ]  ( / / | $ ) ;

# Operand field for an SI instruction.
siAll = 
    | D2+: arithmeticExpression '(' B2+: register '),' I1+: arithmeticExpression  ( / / | $ ) 
    | D2+: arithmeticExpression "," I1+: arithmeticExpression  ( / / | $ ) 
    ;

# Operand field for an MSC instruction.
# CC is the condition code, which only @BC states explicitly; A1 is the
# address or the immediate value; X1 is the index register, whose mere
# PRESENCE sets the M bit of a memory-reference instruction.
mscAll =
    | CC+: arithmeticExpression ',' A1+: arithmeticExpression '(' X1+: arithmeticExpression ')'  ( / / | $ )
    | CC+: arithmeticExpression ',' A1+: arithmeticExpression  ( / / | $ )
    | A1+: arithmeticExpression '(' X1+: arithmeticExpression ')'  ( / / | $ )
    | A1+: arithmeticExpression  ( / / | $ )
    ;

# Operand field for a BCE instruction.  A1 and A2 are named so that the code
# generator can reach them:  depending on the instruction they are an address,
# a displacement and transfer count, or an IUA and a command.
# X1 is the index, which the POO says the assembler recognises as "(1)"
# following a BCE operand and which means indexing by twice the BCE's number.
# It USED to be captured as A2, the same name as the second operand, so an
# indexed operand and a two-operand instruction were indistinguishable and an
# index could be encoded as a displacement.
bceAll =
    | A1+: arithmeticExpression '(' X1+: constant ')'  ( / / | $ )
    | A1+: arithmeticExpression ',' A2+: arithmeticExpression  ( / / | $ )
    | A1+: arithmeticExpression  ( / / | $ )
    ;

# Operand field of an AIF.  Blanks are permitted inside the parentheses --
# they have to be, since AND, OR and NOT are written surrounded by them -- and
# that includes immediately after the '(' and before the ')'.  Rejecting those
# two positions was not a cosmetic matter: a failed AIF parse is reported and
# then execution simply continues without branching, so an AIF that is a loop's
# only exit turns the assembly into an infinite loop.  BTBCEGEN's
#     AIF   ( &ELE  EQ 15).BT106
# did exactly that, and is why FIOMVUPG and its siblings never terminated.
aifAll = '(' / */ exp+: booleanExpression / */ ')' seq+: sequenceSymbol ;

# Operand field of an ORG.
orgAll = 
    | plus: '*+' dec: decimal
    | minus: '*-' dec: decimal
    | here:  '*' ;

#---------------------------------------------------------------------
# Now a bunch of rules used by the rules above, but not usually used
# directly.
    
quotedString = "'" /[^']*/ { "''" /[^']*/ } "'" ;
    
identifier = /(?<![@#$A-Z0-9&])[@#$A-Z][@#$A-Z0-9]*/ ;

# The multiple subscripts are safe here even though `&D(&X,&B)` is
# indistinguishable from a base-index address:  every operand reaches the
# instruction grammars only after `svReplace` has substituted its symbolic
# variables, so no text containing '&' is ever parsed as an instruction.  Only
# AIF, SETA/SETB/SETC and MNOTE are evaluated with their variables intact.
variable =
    | subvar variable
    | subvar '.' variable
    | subvar '(' arithmeticExpression { ',' arithmeticExpression } ')'
    | subvar
    ;
subvar = sv ;

sequenceSymbol = /[.][@#$A-Z][@#$A-Z0-9]*/ ;

constant = 
    # A LEADING PLUS IS ALLOWED, not only a leading minus.  FIOMCNTL writes
    # `@TI +1`, which parsed as nothing at all.  The outer arithmeticExpression
    # consumes an infix '+' before a term is tried, so `A+1` is unaffected.
    | /[-+]?[0-9]+/ 
    | "X'" /[0-9A-F]+/ "'"
    | "B'" /[0-1]+/ "'" 
    | "L'" identifier
    | '*'
    ;
lconstant = 
    | T+: /C/ [ "L" L+: /[0-9]+/ ] "'" C+: ( /[^']*/ { "''" /[^']*/ } ) "'"
    | T+: /X/ [ "L" L+: /[0-9]+/ ] "'" X+: /[0-9A-F]+/ "'"
    | T+: /B/ [ "L" L+: /[0-9]+/ ] "'" B+: /[0-1]+/ "'" 
    | T+: /F/ [ "L" L+: /[0-9]+/ ] [ "S" S+: /-?[0-9]+/ ] "'" F+: floatNumber "'"
    | T+: /H/ [ "L" L+: /[0-9]+/ ] [ "S" S+: /-?[0-9]+/ ] "'" H+: floatNumber "'"
    | T+: /E/ [ "L" L+: /[0-9]+/ ] [ "S" S+: /-?[0-9]+/ ] "'" E+: floatNumber "'"
    | T+: /D/ [ "L" L+: /[0-9]+/ ] [ "S" S+: /-?[0-9]+/ ] "'" D+: floatNumber "'"
    # THE VALUE GOES UNDER ITS OWN KEY.  It used to be captured into `T`, the
    # very key the type letter uses, so `ast["T"]` came back as ["Y", "SYMBOL"]
    # and `ast["Y"]` never existed at all -- the evaluator's `expression[
    # datatype]` then yielded None and every `=Y(...)` in the corpus died as
    # "Symbol None not found".  And the operand is an EXPRESSION, not a bare
    # identifier:  DCICYC writes `=Y(DCIDOUT+508)`, which could not parse.
    | T+: /Y/ [ "L" L+: /[0-9]+/ ] "(" Y+: arithmeticExpression ")"
    | T+: /Z/ [ "L" L+: /[0-9]+/ ] "(" "," A1+: arithmeticExpression "," A2+: arithmeticExpression ")"
    ;

char = 
    | substringExpression 
    | quotedString
    ;
    
substringExpression = quotedString '(' arithmeticExpression ',' arithmeticExpression ')' ;

sdTerm = 
    | /[0-9]+/ 
    | "X'" /[0-9A-F]+/ "'"
    | "B'" /[0-1]+/ "'" 
    | "C" char
    ;

dcOperands = dcOperand { ',' dcOperand } ( / / | $ ) ;
dcOperand = 
    | [ d+: number ] t+: 'C' [ l+: len ] v+: quotedString 
    | [ d+: number ] t+: 'X' [ l+: len ] v+: quotedHexString 
    | [ d+: number ] t+: 'B' [ l+: len ] v+: quotedBinaryString 
    | [ d+: number ] t+: /[FHED]/ [ l+: len ] [ s+: scale ] v+: quotedFloatList 
    | [ d+: number ] t+: /[AY]/ [ l+: len ] v+: addresses 
    | [ d+: number ] t+: 'A'[ l+: len ] h+: quotedHexString
    | [ d+: number ] t+: 'Z' '(' z: identifier [ ',' [ A1+: arithmeticExpression ] [ ',' f: arithmeticExpression ] ] ')'
    # An OMITTED symbol, `Z(,expression,flags)`, the same shape the literal
    # `=Z(,expression,flags)` has always taken.  The symbol to relocate is then
    # the leading identifier of the expression, there being no separate field
    # for it.
    | [ d+: number ] t+: 'Z' '(' ',' A1+: arithmeticExpression [ ',' f: arithmeticExpression ] ')'
    # THE FIRST OPERAND MAY BE AN EXPRESSION, not only a bare symbol.
    # FPMFCLOS writes `DC Z(FPMSVCL+2,FPMSVC21,8)`.  This alternative comes
    # last so that every Z already parsing keeps parsing exactly as it did:
    # the identifier form above is tried first and only a `+` or `-` after the
    # symbol falls through to here.
    | [ d+: number ] t+: 'Z' '(' zx+: arithmeticExpression [ ',' [ A1+: arithmeticExpression ] [ ',' f: arithmeticExpression ] ] ')'
    ;
dsOperands = dsOperand { ',' dsOperand }  ( / / | $ ) ;
dsOperand = 
    | [ d+: number ] t+: 'C' [ l+: len ] [ v+: quotedString ]
    | [ d+: number ] t+: 'X' [ l+: len ] [ v+: quotedHexString ]
    | [ d+: number ] t+: 'B' [ l+: len ] [ v+: quotedBinaryString ]
    | [ d+: number ] t+: /[FHED]/ [ l+: len ] [ s+: scale ] [ v+: quotedFloatList ]
    | [ d+: number ] t+: /[AY]/ [ l+: len ] [ v+: addresses ]
    # `DS Z` reserves the four bytes a ZCON occupies without defining one, and
    # the generator has always handled it -- but there was no Z alternative
    # here at all, so the operand simply would not parse.  The parenthesised
    # part is optional for the same reason it is on every other DS type.
    | [ d+: number ] t+: 'Z' [ '(' z: identifier [ ',' [ arithmeticExpression ] [ ',' f: arithmeticExpression ] ] ')' ]
    ;
addresses = '(' arithmeticExpression { ',' arithmeticExpression } ')' ;
decimal = /[0-9]+/ ;
len = 'L' [ '.' ] [ '+' | '-' ] number ;
scale = 'S' [ '+' | '-' ] number;
exp = 'E' [ '+' | '-' ] number;
number = ( /[0-9]+/ | '(' arithmeticExpression ')' );
# COMMAS ARE COSMETIC SEPARATORS inside a hexadecimal constant.  FAZ2 and
# MMUPURTB write `DC X'A92F0A3C,A2DFA000,0000A35B,A35DA5B2'` and the original
# build assembles the concatenation, sixteen bytes, printing the first eight as
# A92F0A3CA2DFA000.  The generator strips them.
quotedHexString = "'" /[A-F0-9,]+/ "'" ;
quotedBinaryString = "'" /[01]+/ "'" ;
quotedFloatList = "'" floatNumber { ',' floatNumber } "'" ;
floatNumber = 
    | [ /[-+]/ ] /[0-9]+/ [ '.' /[0-9]*/ ] [ 'E' /[-+]?[0-9]+/ ] 
    | [ /[-+]/ ] '.' /[0-9]+/ [ 'E' /[-+]?[0-9]+/ ] 
    ;
quotedFixedList = "'" fixedNumber { ',' fixedNumber } "'" ;
fixedNumber = 
    | [ /[-+]/ ] /[0-9]+/ [ '.' /[0-9]*/ ] 
    | [ /[-+]/ ] '.' /[0-9]+/  
    ;

register = 
    | constant 
    | identifier 
    | variable 
    ;

immediate = 
    | constant
    | identifier
    | variable
    ;

arithmeticExpressionOnly = arithmeticExpression $ ;
arithmeticExpression = term  { ( '+' | '-' ) term } ;
term = factor  { ( '*' | '/' ) factor } ;
factor = 
    | /[NKLSI]'/ variable
    | constant 
    | identifier 
    | variable 
    | '('  arithmeticExpression  ')' 
    | '*'
    ;

booleanExpressionOnly = booleanExpression $ ;
booleanExpression = booleanTerm { / */ 'OR' / */ booleanTerm } ;
booleanTerm = notFactor { / */ 'AND' / */ notFactor } ;
notFactor = [ / */ 'NOT' / */ ] booleanFactor ;
# T' and D' take a `variable` rather than a bare `sv` so that they can be
# applied to a subscripted macro argument -- `T'&SYSLIST(1)`, `D'&SYSLIST(&I,3)`
# -- which MLIB80 does in several places.
booleanFactor =
    | "D'" identifier
    | "D'" variable
    | relationalExpression
    | variable
    | '(' / */ booleanExpression / */ ')'
    | booleanLiteral
    ;
booleanLiteral = '0' | '1' ;
relationalExpression = 
    | arithmeticExpression / */ relOp / */ arithmeticExpression
    | characterExpression / */ relOp / */ characterExpression
    ;
relOp = 'EQ' | 'NE' | 'LT' | 'GT' | 'LE' | 'GE' ;

characterExpressionOnly = characterExpression $ ;
characterExpression =
    | quotedString [ substringNotation ] { [ '.' ] characterExpression }
    | "T'" identifier
    | "T'" variable
    ;
substringNotation = '(' arithmeticExpression ',' arithmeticExpression ')' ;

parameter = 
    | sv '=' /[^, ]*/
    | sv
    ;
    
sv = /&[@#$A-Z][@#$A-Z0-9]*/ ;

list = listItem { ',' listItem } ;
listItem = 
    | '(' list ')'
    | /[^ ,()]*/
    ;

replacement = 
    | identifier "=" "'" /[^']*/ { "''" /[^']*/ } "'"
    | identifier "=" ( /[0-9]+/ | identifier ) "(" ( /[0-9]+/ | identifier ) ")"
    | identifier '=' '(' list ')'
    | identifier '=' /[^, ()]*/
    | char
    | ( /[0-9]+/ | identifier ) "(" ( /[0-9]+/ | identifier ) ")"
    | '(' list ')'
    | /[^, ()]*/
    ;

mnote = 
    | sev+: /[0-9]+/ ',' msg+: quotedString
    | ',' msg+: quotedString
    | com+: '*' ',' msg+: quotedString
    | msg+: quotedString
    ;

# The operand of ENTRY and EXTRN.  It ends at the first blank, after which the
# rest of the statement is a comment -- `EXTRN FSVC0030    GENERATE ALTERNATE
# ENTRY POINT` is a real line from FCMASYNC.  Requiring end-of-input here made
# the whole operand unparsable, which left `properties["ast"]` as None for the
# code generator to trip over later.
identifierList = pidentifier { ',' pidentifier } ( / / | $ ) ;
pidentifier = /[#@$A-Z][#@$A-Z0-9]*/ ;

anything = /.*/ $ ;

# The second and third operands of EQU are the length and type attributes to
# give the symbol, as in MENU12's `#CYCNT EQU *,0+1,0+1`.  They are captured so
# the statement parses; see the EQU case in model101.py for why nothing is done
# with them yet.
#
# The third is a CHARACTER SELF-DEFINING TERM in the sources that matter --
# PDEF writes `EQU 1,1,C'#'` and `EQU 0,0+1025,C'@'` to type a position symbol
# -- and that form is not an arithmeticExpression, so it gets its own
# alternative ahead of one.
equOperand = v+: arithmeticExpression
             [ ',' len+: arithmeticExpression
               [ ',' ( typc+: characterTerm | typ+: arithmeticExpression ) ] ]
             ( / / | $ ) ;
characterTerm = "C'" /[^']*/ "'" ;

# Operand field of SETA, SETB and SETC.  The operand field ends at the first
# blank that is not inside a quoted string, and whatever follows it is a
# comment -- which is why these stop at `( / / | $ )` rather than at `$` as
# the `...Only` rules do.  Requiring end-of-input here made a SETA such as
#    &MSGCNT  SETA  &MSGCNT+1        ARRAY INDEX=INDEX+1
# fail to parse, and `svSet` then returned without assigning anything, so the
# variable silently kept its old value.  In MACSMITH's RTURNTBL that left the
# loop bound at zero and the assembly never terminated.
setaOperand = v+: arithmeticExpression ( / / | $ ) ;
setbOperand = v+: booleanExpression ( / / | $ ) ;
setcOperand = v+: characterExpression ( / / | $ ) ;

expressions = r+: arithmeticExpression { ',' r+: arithmeticExpression }* ( / / | $ ) ;

'''

#=============================================================================

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
fieldParser.py, but not to be saved.  The --generate-only option is like 
--generate, but terminates after generation with no interactive mode.
"""

noInteractive = False
if standAlone:
    import sys
    for parm in sys.argv[1:]:
        if parm == "--generate":
            generateModules = True
        elif parm == "--generate-only":
            generateModules = True
            noInteractive = True
        elif parm == "--local":
            generateLocal = True
        elif parm == "--help":
            print(helpMessage)
            sys.exit(0)
        else:
            print("Unknown parameter %s" % parm)
            sys.exit(1)
    
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
            parser = None
    if generateLocal:
        if name != None:
            print("Generating %s ..." % name)
        parser = tatsu.compile(grammar)

if not standAlone or not generateLocal: 
    if standAlone:
        print("Importing parser ...")
    import parser_asm
    parser = parser_asm.asmParser()

def parserASM(text, rule):
    try:
        ast = parser.parse(text, start=rule, whitespace='')
        return ast
    except:
        return None

#=============================================================================
# Auxiliary functions.

# Forms the merged operand field, taking into account continuation lines.  
# Comments are discarded.  The arguments are:
#    `lines`    A list of source-code lines.
#    `index`    The starting index in `lines` of the macro prototype line.
#    `column`   The column in `lines[index]` at which the operand field starts.
#               If the operand field doesn't start on the first card, then
#               `column` is 71.
#    `proto`    True for macro-prototype lines
#    `invoke`   False for macro-argument lines.
# Returns True,operand,skipCount on success or False,None,skipCount on error.  
# `skipCount` is the number of continuation lines processed.
# Where the operand field of a statement ends: at the first blank that is
# neither inside a quoted string NOR inside parentheses.  Everything after it
# is a comment.
#
# The parentheses matter as much as the quotes.  A conditional-assembly
# expression is full of blanks that are outside any quoted string --
#     AIF   ('&P2' EQ '' OR '&P2' EQ 'OR' OR '&P2' EQ 'AND' OR '        X
#           &P2' EQ 'ORIF').SGLOPR
# -- and stopping at the first of them truncated the operand and then joined
# the continuation card onto the stump, silently producing a different
# condition from the one written.  In STKINS that turned a test for five
# alternatives into a test for two, and the IF macro stopped recognising its
# own condition mnemonics.
def operandFieldEnd(text):
    quoted = False
    depth = 0
    i = 0
    while i < len(text):
        c = text[i]
        if c == "'":
            # A doubled quote inside a string is an escaped quote, not the end.
            if quoted and text[i+1:i+2] == "'":
                i += 2
                continue
            quoted = not quoted
        elif not quoted:
            if c == "(":
                depth += 1
            elif c == ")":
                if depth > 0:
                    depth -= 1
            elif c == " " and depth == 0:
                return i
        i += 1
    return len(text)

def joinOperand(lines, index, column, proto=False, invoke=False):
    continuation = False
    skipCount = -1
    status = True
    done = False
    while continuation or skipCount < 0:
        if index >= len(lines):
            break
        skipCount += 1
        line = lines[index].rstrip("\r\n")
        if "STED  F6,SAVE6" in line: ###DEBUG###TRAP###
            pass
        if done:
            pass
        elif continuation:
            if invoke or proto:
                # These two trim the accumulated operand with the parser, via
                # `endpos` below, so leave them alone.
                operand = operand.rstrip("\r\n") + line[15:71]
            else:
                # Everything else was joined by simple concatenation, which
                # kept the blanks between the end of one card's operand and
                # column 72, so the two cards' operands never actually met.
                #     LCLC  &AA,&BB,                              X
                #           &CC,&DD
                # arrived as "&AA,&BB,<58 blanks>&CC,&DD".  `svDeclare` then
                # took the first blank-delimited token, declared &AA and &BB,
                # complained about the empty field left by the trailing comma,
                # and silently dropped &CC and &DD -- which for a GBLx meant a
                # global quietly became a local when something later assigned
                # to it.  Eight declarations in OI340600's MLIB80 are written
                # this way.
                # A CONTINUATION CONTINUES THE OPERAND ONLY IF THE OPERAND WAS
                # STILL RUNNING -- either it reached the end of the card, or it
                # broke on a comma with more to come.  Otherwise the operand
                # field ended at a blank, the rest of the card is a COMMENT, and
                # what a non-blank column 72 continues is that comment, which
                # generates nothing.  Appending regardless spliced a comment's
                # continuation onto the operand:
                #
                #   ST    R6,TDWARCSM   SAVE RM COMMON SET MASK(BITS 16-31  *
                #         TB         TDWARTOC,FCMMMRMR
                #
                # became `R6,TDWARCSMTB ...` and FCMDSCRM died on an undefined
                # symbol.  The original assembles that ST as a complete 3604 and
                # reads the next card as its own statement.
                _field = operand[:operandFieldEnd(operand)]
                if operandFieldEnd(operand) >= len(operand.rstrip()) \
                        or _field.rstrip().endswith(","):
                    operand = _field + line[15:71].rstrip("\r\n")
        else:
            operand = line[column:71].rstrip("\r\n")
        if len(line) < 72:
            continuation = False
        else:
            continuation = (line[71] != " ")
        index += 1
        if done or not (invoke or proto):
            continue
        try:
            if invoke:
                ret = parserASM(operand, "operandInvocation0")
            elif proto:
                ret = parserASM(operand, "operandPrototype0")
            endpos = ret.parseinfo.endpos
            if "end0" in ret and invoke and endpos > 1 and \
                    operand[endpos-2] == ',':
                operand = operand[:endpos-1]
            elif "end0" in ret:
                done = True
                operand = operand[:endpos-1]
            elif "end1" in ret:
                operand = operand[:endpos-1]
            elif "end2" in ret:
                pass
            elif "end3" in ret:
                operand = ""
            elif "end4" in ret:
                operand = operand.rstrip()
            else:
                status = False
                done = True
        except:
            status = False
            done = True
    return status,operand,skipCount

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

if __name__ == "__main__" and not noInteractive:
    import sys
    import pprint
    
    #-------------------------------------------------------------------------
    # A selection of lines of source code follow, for testing the 
    # `joinOperand` function.
    print("Macro prototype lines -------------------------------------------")
    testLines1 = [ 
        "&NAME    FCW2  &Y,&ENDRF=0,&INCRM=0,&POLRX=0,&POLRY=0,&ANCTL1=0,&ANCTL2*000200AA",
        "               =0,&ANCTL3=0,&ANCTL4=0,&ANCTL5=0                         000300AA"
        ]
    print(joinOperand(testLines1, 0, 15, proto=True))
    testLines2 = [
        "&NAME    FCW3  &E,&V,&SC=0                      75080                   000200AA"
        ]
    print(joinOperand(testLines2, 0, 15, proto=True))
    testLines3 = [
        " FTBEGIN &TID=NO,&STACKX=1,&EQUS=YES,&PDE=YES,&DSTACK=NO,&TYPE=MAIN     000200AA"
        ]
    print(joinOperand(testLines3, 0, 9, proto=True))
    testLines4 = [
        "&NAME    GENERATE &TYPE=,&COPY=,&NPCT=,&NTQE=,&NEQE=,&NIOQE=,&STOR=,   X007900AQ",
        "               &NBRQ=                                                   008000AQ"
        ]
    print(joinOperand(testLines4, 0, 18, proto=True))
    testLines5 = [
        "         IF    &P1,&P2,&P3,&P4,&P5,&P6,&P7,&P8,&P9,&P10,&P11,&P12,&P13,X000200AA",
        "               &P14,&P15,&P16,&P17,&P18,&P19,&P20,&P21,&P22,&P23,&P24,&X000300AA",
        "               P25,&P26,&P27,&P28,&P29,&P30,&P31,&P32,&P33,&P34,&P35,&PX000400AA",
        "               36,&P37,&P38,&P39,&P40,&P41,&P42,&P43,&P44,&P45,&P46,&P4X000500AA",
        "               7,&P48,&P49,&P50,&CC=                                    000600AA"
        ]
    print(joinOperand(testLines5, 0, 15, proto=True))
    testLines6 = [
        "         TFRST                                                          000200AA"
        ]
    print(joinOperand(testLines6, 0, 71, proto=True))
    testLines7 = [
        "&BUSTYP  TCBUS &LST1,&LST2,&LST3,&LST4,&LST5,&LST6,&LST7,&LST8,&LST9,  X000200AA",
        "               &LST10,&LST11,&LST12,&LST13,&LST14,&LST15,&LST16,&LST17,X000300AA",
        "               &LST18,&LST19,&LST20,&LST21,&LST22,&LST23,&LST24,&LST25,X000400AA",
        "               &LST26,&LST27,&LST28,&LST29,&LST30                       000500AA"
        ]
    print(joinOperand(testLines7, 0, 15, proto=True))
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
    print(joinOperand(testLines8, 0, 15, proto=True))
    testLines9 = [
        "         TFPSA &TYPE,&PON=,&POF=,&SR=,&MC=,&PC=,&SVC=,&PC1=,&PC2=,&IM=,X004600AG",
        "               &EI0=,&EI1=,&EI2=,&EI3=,&SI=,&DSR=1,&BSR=1,&PD=YES,     X004700AG",
        "               &TRCPGM=,&TRCBGN=,&TRCEND=                               004800AG"
        ]
    print(joinOperand(testLines9, 0, 15, proto=True))
    testLines10 = [
        "         TFRST                                                         ?000200AA",
        "               &A,&B  THIS IS MY COMMENT                                        "
        ]
    print(joinOperand(testLines10, 0, 71, proto=True))
    
    print("Macro invocation lines ------------------------------------------")
    testLines1A = [
        "         FCW2   ANCTL2=1      DISABLE TRANSLATE MODE                    002600AB"
        ]
    testLines1B = [
        "         FCW2   POLRX=1,POLRY=1,ANCTL5=1,ANCTL4=1,ANCTL1=1              029800AB"
        ]
    print(joinOperand(testLines1A, 0, 16, invoke=True))
    print(joinOperand(testLines1B, 0, 16, invoke=True))
    testLines4A = [
        "         GENERATE COPY=(TFPCT,TFTQE,TFEQE)                              009300AK"
        ]
    testLines4B = [
        "         GENERATE TYPE=CSECT,NPCT=35,NTQE=30,NEQE=25,NBRQ=20,          X048100CE",
        "               STOR=(1,1)                                               048200BW"
        ]
    print(joinOperand(testLines4A, 0, 18, invoke=True))
    print(joinOperand(testLines4B, 0, 18, invoke=True))
    testLines5A = [
        "         IF    (C,R4,EQ,=F'0'),AND,(C,R5,EQ,=F'0') THEN VALUE ZERO      035400AO"
        ]
    print(joinOperand(testLines5A, 0, 15, invoke=True))
    
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
    print(joinOperand(testLines8A, 0, 15, invoke=True))

    #-------------------------------------------------------------------------
    # An interactive mode for inputting arbitrary "operand" fields (confined to
    # a single card) and testing them against the defined operand grammars.
    
    def collapse(var):
        if not isinstance(var, (list, tuple)):
            return var
        ret = []
        for e in var:
            if e == []:
                continue
            ret.append(collapse(e))
        if len(ret) == 1:
            return ret[0]
        return tuple(ret)
    
    def exercise(rule):
        ast = parserASM(line, rule)
        if ast == None:
            print("%s failed" % rule)
            return
        print("%s:" % rule)
        print(ast)
        pprint.pprint(collapse(ast), indent=2, width=20)
    
    print("Interactive input loop ------------------------------------------")
    while True:
        print()
        print("Input a string (empty to quit): ", end="")
        line = input().strip('\n\r')
        if len(line) == 0:
            break
        print("Matching: '%s'" % line)
        exercise("nameCode")
        exercise("nameSet")
        exercise("nameMacrodef")
        exercise("operationAll")
        exercise("rrAll")
        exercise("rsAll")
        exercise("riAll")
        exercise("srsAll")
        exercise("siAll")
        exercise("mscAll")
        exercise("bceAll")
        exercise("operandPrototype0")
        exercise("operandPrototype")
        exercise("operandInvocation0")
        exercise("operandInvocation")
        exercise("quotedString")
        exercise("aifAll")
        exercise("characterExpressionOnly")
        exercise("arithmeticExpressionOnly")
        exercise("booleanExpressionOnly")
        exercise("mnote")
        exercise("identifierList")
        exercise("pidentifier")
        exercise("anything")
        exercise("dcOperands")
        exercise("dsOperands")
        exercise("immediate")
        exercise("constant")
        exercise("equOperand")
        exercise("expressions")
        exercise("floatNumber")
        exercise("quotedFloatList")
        exercise("lfxiAll")
        exercise("orgAll")
        
