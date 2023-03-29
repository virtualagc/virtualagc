#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       p_Functions.py
Purpose:        Contains all low-level PALMAT-generation functions associated
                with LBNF labels in the grammar for the "modern" HAL/S compiler 
                modernHAL-S-FC.c.
History:        2022-12-21 RSB  Created.

Refer to PALMAT.py for a higher-level explanation.

The idea here is that most of these functions perform some action based on
an LBNF "label" in the grammar, and are named identically to those labels,
except that the labels each have a 2-letter all-cap prefixed which is 
insignificant and is discarded in the function names.  I've had to take
some care to avoid LBNF labels that coincided with Python reserved words or
built-in functionality; in those cases, the LBNF label has simply been
all-cap'd in the grammar.

The functions (which are called by PALMAT.py's generatePALMAT function)
all accept the current PALMAT and state as input and return a pair consisting 
of a boolean (True for success, False for failure) and the new state.  
"""

'''
Here's the basic theory of how assignments work.  (I'm not quite
sure just yet how to handle indexed or structure expressions on
the left of an assignment, so this just covers simple variables
on the left right now.)

All of the identifiers we encounter on the LHS of the equals
sign are stored temporarily in substate["LHS"], which is a list
holding just the names of those identifiers and nothing else.  If
any of those variables have no declaration, they're dutifully
recorded in substate["errors"] instead.

On the RHS of the equals should be an expression.  As we 
recursively-descend through this expression, the significant items
(like operators, variables, and constants) are appended to 
substate["expression"].  When the end of the expression is finally
reached -- which is detected by generatePALMAT() in the PALMAT
module -- everything in substate["expression"] is popped and 
stored in PALMAT["instructions"] in reverse order, as a reverse-polish
style program; i.e., at runtime those RPN instructions will form
a program that operates on an execution stack in the emulator, 
in the end resulting in a single computed value remaining on that 
runtime execution stack.  Finally, everything in substate["LHS"] is 
then popped and store in PALMAT["instructions"] as well, again in 
RPN style.  In the case of these LHS items, the RPN instructions 
they're stored as are not computational in nature, but instead
are instructions to take the top of the stack (without removing it
from the stack) and storing it in a variable.  Finally, 
PALMAT["instructions"] is topped off with a final RPN instruciton
to pop the final value from the runtime execution stack.
'''

import sys
import copy
from palmatAux import addAttribute, findIdentifier, removeAncestors, \
                      notUnmarkedScalars

# This is persistent statelike information, unlike the "state" parameter
# used for functions that propagates only *into* the recursive descent and
# is lost when ascending later.
substate = {
    # Used globally.
    "errors" : [],
    "warnings" : [],
    # Used for DECLARE statements, and cleared when the processing of those
    # statements begins.
    "currentIdentifier" : "",
    "commonAttributes" : {},
    # Used while generating code for expressions, prior to generating code.
    "lhs" : [],
    "lhsSubscripts" : {},
    "expression" : []
}

#-----------------------------------------------------------------------------

expressionComponents = ["expression", "ifClauseBitExp", "relational_exp", 
                        "relational_expOR",
                     "bitExpFactor", "write_arg", "read_arg", "char_spec",
                     "arithExpTerm", "arithExpArithExpPlusTerm",
                     "arithExpArithExpMinusTerm", "arithMinusTerm", 
                     "literalExp", "sub_exp", "subscript",
                     "minorAttributeRepeatedConstant", "minorAttributeStar"]
setExpressionComponents = set(expressionComponents)
doForComponents = ["doGroupHeadFor", "doGroupHeadForWhile", 
                      "doGroupHeadForUntil"]

# Checks for intersection of expressionComponents and a list of components.
def isNotExpressiony(components):
    return setExpressionComponents.isdisjoint(components)

# This function clones a state (as in the parameters of the various functions
# below named according to labels from the LBNF grammar) and updates its 
# "history" in one of several ways, depending on the value of fsType.
fsSet = 1
fsAugment = 2
def fixupState(state, fsType, name=None):
    if name != None:
        ourName = name
    else:
        # This code gets the name of the calling function as a string.
        frame = sys._getframe(1)
        ourName = frame.f_code.co_name
    newState = copy.deepcopy(state)
    if fsType == fsSet:
        newState["history"] = [ourName]
    elif fsType == fsAugment:
        newState["history"] += [ourName]
    return newState

'''
Background:  When processing a STRUCTURE statement, the attributes in the 
identifiers list are built up somewhat recursively.  There is a list used 
in this process that grows and shrinks as processing descends into the hierarchy 
of the structure template or ascends back to higher levels.  This list is:
    substate["currentStructureTemplateDescent"]
This list (for discussion, let's call it just Descent) contains the structure
template fieldnames by which the current point in the processing has been 
reached; i.e., Descent[0] is the level 1 fieldname, Descent[1] is the level 2
fieldname in the template (a child of Descent[1]), and so on.  So for example, 
if we were processing structure template S, and had reached the point where we 
were determining the attributes of S.A.B.C, then 
    Descent = ["A", "B", "C"]

What the findTemplateAttributes functions does is to use the Descent list to 
find the specific attributes dictionary for some field of a structure template.
Upon input, "attributes" is the attributes dictionary for the full structure
template, as taken from the scope's identifiers dictionary.  

Thus in the example given earlier, upon entry "attributes" will be the dictionary
identifiers["^s_S^].  Somewhere that dictionary lie the specific attributes for 
field S.A.B.C.  The function returns the dictionary containing those attributes.  

The parameter "append" can be used to create a structure-template subfield that 
doesn't yet exist.  Descent is use to locate the parent field for the subfield.
The "append" parameter is a 2-tuple or 2-list in which the first element is the
name of the subfield and the second element is its initial attributes.

The functure returns the found (or newly-added) field's attributes, or else
None if the field couldn't be found (or created using "append").
'''
def findTemplateAttributes(attributes, descent, append=None):
    for i in range(len(descent)):
        fieldname = descent[i]
        if "template" not in attributes:
            return None
        template = attributes["template"]
        fieldnameList = template[0]
        attributesList = template[1]
        if fieldname not in fieldnameList:
            return None
        j = fieldnameList.index(fieldname)
        attributes = attributesList[j]
    # At this point, we've found the attributes for the specific fieldname
    # specified by descent[].  Are we supposed to create a subfield in it?
    if append != None:
        if "template" not in attributes:
            # When fields are created without explicit attributes, they are
            # tentatively assigned as "scalar" but could turn out to be 
            # "template", which seems to be what has happened here.
            if "scalar" in attributes and len(attributes) == 1:
                attributes.pop("scalar")
                attributes["template"] = ([], [])
            else:
                return None
        attributes["template"][0].append(append[0])
        attributes["template"][1].append(append[1])
        attributes = attributes["template"][1][-1]
    return attributes

# Print a structure template, given its name and attributes.
def printTemplate(identifier, attributes, indent=0, level=0):
    if identifier[0] == "^":
        identifier = identifier[1:-1]
    else:
        identifier = "%d %s" % (level, identifier)
    print("%*s%s:" % (indent, "", identifier), end="")
    if "template" not in attributes:
        print(" ", attributes)
        return
    print()
    fieldnameList = attributes["template"][0]
    attributesList = attributes["template"][1]
    for i in range(len(fieldnameList)):
        printTemplate(fieldnameList[i], attributesList[i], \
                      indent + 4, level + 1)
    
if False:
    # Test for findTemplateAttributes() and printTemplate() implementing example 
    # T2-STRUCTURE from https://www.ibiblio.org/apollo/hal-s-compiler.html#Data.
    attributes = {"template":([],[])}
    findTemplateAttributes(attributes, [], ["C", {"template":([],[])}])
    findTemplateAttributes(attributes, [], ["D", {"template":([],[])}])
    findTemplateAttributes(attributes, [], ["E", {"vector":3}])
    findTemplateAttributes(attributes, ["C"], ["A", {"scalar":True}])
    findTemplateAttributes(attributes, ["C"], ["B", {"scalar":True}])
    findTemplateAttributes(attributes, ["C"], ["I", {"integer":True}])
    findTemplateAttributes(attributes, ["D"], ["A", {"scalar":True}])
    findTemplateAttributes(attributes, ["D"], ["B", {"scalar":True}])
    findTemplateAttributes(attributes, ["D"], ["I", {"integer":True}])
    print(attributes)
    printTemplate("S", attributes)
    import sys
    sys.exit(1)

# Update attribute for identifier.
def updateCurrentIdentifierAttribute(PALMAT, state, attribute=None, value=True):
    global substate
    if "currentStructureTemplateAttributes" in substate and \
            0 != len(substate["currentStructureTemplateAttributes"]):
        # We come here if we're processing a STRUCTURE statement.
        if attribute != None:
            lastAttributes = substate["currentStructureTemplateAttributes"][-1]
            lastAttributes[attribute] = value
            if "scalar" in lastAttributes and attribute in notUnmarkedScalars:
                lastAttributes.pop("scalar")
            
        # Take care of the identifiers dictionary.
        identifiers = PALMAT["scopes"][state["scopeIndex"]]["identifiers"]
        identifier = substate["currentStructureTemplateIdentifier"]
        #print("**", state["scopeIndex"], identifier, identifiers)
        attributes = identifiers[identifier]
        descent = substate["currentStructureTemplateDescent"]
        specificAttributes = findTemplateAttributes(attributes, descent)
        if specificAttributes == None:
            specificAttributes = findTemplateAttributes( \
                                    attributes, descent[:-1], \
                                    [descent[-1], { }] )
        if attribute == None:
            specificAttributes["scalar"] = True
        else:
            if "scalar" in specificAttributes and attribute in notUnmarkedScalars:
                specificAttributes.pop("scalar")
            specificAttributes[attribute] = value 
        return
    # We come here if we're processing a DECLARE statement.
    history = state["history"]
    if substate["currentIdentifier"] == "":
        if ('declareBody_attributes_declarationList' in history and \
            ('attributes_typeAndMinorAttr' in history or \
             'attributes_arraySpec_typeAndMinorAttr' in history)) or \
                     attribute in ["vector", "matrix", "array"]:
            if attribute != None:
                substate["commonAttributes"][attribute] = value
        return
    scope = PALMAT["scopes"][state["scopeIndex"]]
    identifiers = scope["identifiers"]
    if substate["currentIdentifier"] not in identifiers:
        identifiers[substate["currentIdentifier"]] = { }
        identifiers[substate["currentIdentifier"]] \
                            .update(substate["commonAttributes"])
    if attribute != None:
        identifiers[substate["currentIdentifier"]][attribute] = value

# Remove identifier.  This is not something you can
# do in HAL/S, but there are interpreter commands for it.
# The identifier name is unmangled and not carat-quoted.
def removeIdentifier(PALMAT, macros, scopeIndex, identifier):
    scope = PALMAT["scopes"][scopeIndex]
    macros0 = macros[scopeIndex]
    mangled = identifier
    if identifier in macros0:
        attributes = macros0[identifier]
        if attributes["arguments"] == []:
            mangled = attributes["replacement"]
    carated = "^" + mangled + "^"
    identifiers = scope["identifiers"]
    if carated in identifiers:
        identifiers.pop(carated)
        if identifier in macros0:
            macros0.pop(identifier)
        print("Removed identifier: %s (%s)" % (identifier, mangled))
    else:
        print("Identifier not found: %s (%s)" % (identifier, mangled))

def removeAllIdentifiers(PALMAT, macros, scopeIndex):
    scope = PALMAT["scopes"][scopeIndex]
    macros0 = macros[scopeIndex]
    identifiers = scope["identifiers"]
    forRemoval = []
    for identifier in identifiers:
        attributes = identifiers[identifier]
        if "program" not in attributes and "function" not in attributes and \
                "procedure" not in attributes and "compool" not in attributes:
            forRemoval.append(identifier)
    for identifier in forRemoval:
        identifiers.pop(identifier)
    macroRemovals = []
    for macro in macros0:
        if "^" + macros[macro]["replacement"] + "^" in forRemoval:
            macroRemovals.append(macro)
    for macro in macroRemovals:
        macros0.pop(macro)
   
# This function is called from generatePALMAT() for a string literal.
# Returns only True/False for Success/Failure.
def stringLiteral(PALMAT, state, s):
    global substate
    history = state["history"]
    #-------------------------------------------------------------------------
    # First extract various state info and variations on the string that we'll
    # often use no matter what.
    
    # Recall that string literals will show up in various forms.  All are 
    # surrounded by carats (a la ^...^).  In one form, the literal is an 
    # LBNF label.  Those are prefixed by two capital letters that we'd like
    # removed.  An another, they are identifiers, which we want to use as-is.
    # In another, they are stringified numbers that we want to actually convert
    # to numbers.
    sp = s
    isp = None
    fsp = None
    if s[:1] != "^" and s[:2].isupper():
        s = s[2:]
    elif s[:1] == "^" and s[-1:] == "^":
        sp = s[1:-1]
        try:
            isp = int(sp)
            fsp = isp
        except:
            try:
                fsp = float(sp)
            except:
                pass
    scopeIndex = state["scopeIndex"]
    scopes = PALMAT["scopes"]
    scope = scopes[scopeIndex]
    identifiers = scope["identifiers"]
    instructions = scope["instructions"]
    if len(history) == 0:
        state1 = None
    else:
        state1 = history[-1]
    state2 = history[-2:]
    
    #-------------------------------------------------------------------------
    # Now do various state-machine-dependent stuff with the string (s) or its
    # variations (sp, isp, fsp). 
    if False:
        pass
    elif state1 == "structure_id" and "qual_struct" in history:
        if len(substate["qual"]) == 0:
            iScope, iAttributes = findIdentifier(s, PALMAT, scopeIndex)
            substate["qualScope"] = iScope
            substate["qualInsert"] = -1
        substate["qual"].append(sp[2:])
    elif state1 == "number" and \
            "arraySpec_arrayHead_literalExpOrStar" in history and \
            "structure_stmt" in history:
        attributes = findTemplateAttributes(\
                identifiers[substate["currentStructureTemplateIdentifier"]], \
                substate["currentStructureTemplateDescent"])
        attributes["array"].append(int(sp))
    elif state1 == "number" and \
            "sQdQName_doublyQualNameHead_literalExpOrStar" in history and \
            "currentStructureTemplateDescent" in substate and \
            substate["currentStructureTemplateIdentifier"] in identifiers:
        attributes = findTemplateAttributes(\
                identifiers[substate["currentStructureTemplateIdentifier"]], \
                substate["currentStructureTemplateDescent"])
        if attributes != None:
            if "vector" in attributes:
                width = int(sp)
                attributes["vector"] = width
                substate["currentStructureTemplateAttributes"][-1]["vector"] = width
            elif "matrix" in attributes:
                width = int(sp)
                attributes["matrix"].append(width)
    elif state1 == "structure_id":
        # Start of a STRUCTURE statement.
        if "structure_stmt" in history:
            if "attributes_typeAndMinorAttr" in history:
                # This is a declaration that a field in a structure is itself
                # a substructure.
                updateCurrentIdentifierAttribute(PALMAT, state, \
                                            "structure", sp[2:] + "-STRUCTURE")
            else:
                # This is the name of in an actual definition of a structure 
                # template.
                if s in identifiers:
                    substate["errors"]\
                        .append("Structure-template name (%s) already declared." \
                                % sp)
                    return False
                else:
                    identifiers[s] = { "template": ([], []) }
                    substate["currentStructureTemplateIdentifier"] = s
                    substate["currentStructureTemplateDescent"] = []
                    substate["currentStructureTemplateAttributes"] = []
        else:
            updateCurrentIdentifierAttribute(PALMAT, state, "structure", sp)
    elif "structure_stmt" in history and \
            state1 in ["struct_stmt_head", "struct_stmt_tail",
                       "nameId_structIdentifierToken", "bit_id"]:
        '''
        The variable called "descent" is a hierarchical list of unmangled 
        fieldnames identifying the exact field we're currently processing.  When 
        we descend to the next level, we append a fieldname to the list.  When 
        we remain within a level, we replace the last fieldname in the list.
        When we retreat, we remove the final fieldnames until we get back
        the earlier level we want.
        '''
        if sp.isdigit():
            # Level in a structure statement.
            substate["commonAttributes"] = {}
            substate["currentStructureTemplateLevel"] = int(sp)
        else:
            # Fieldname for the structure statement.
            descent = substate["currentStructureTemplateDescent"]
            dattributes = substate["currentStructureTemplateAttributes"]
            level = substate["currentStructureTemplateLevel"]
            while len(descent) > level:
                descent.pop()
                dattributes.pop()
            if len(descent) == level:
                # We're on an existing level, and can thus add the new field
                # to that level.
                descent[-1] = sp
                dattributes[-1] = {}
                pass
            elif level == len(descent) + 1:
                # The last field added was a substructure, or else the template
                # is completely empty so far, so we now have to
                # add the level for that substructure and add our new field
                # to it.
                descent.append(sp)
                dattributes.append({})
                pass
            else:
                substate["errors"]\
                    .append("Illegal level in structure-template %s: %d %s" % \
                            (sp, level, str(descent)))
                return False
            #print("*C", level)
            #print("*D", descent)
            updateCurrentIdentifierAttribute(PALMAT, state, "scalar")
    elif state1 == "number" and "minorAttributeRepeatedConstant" in history:
        pass
    elif state1 == "number" and "bitSpecBoolean" in history \
            and "structure_stmt" in history:
        substate["currentStructureTemplateAttributes"][-1]["bit"] = isp
        attributes = findTemplateAttributes(\
            identifiers[substate["currentStructureTemplateIdentifier"]], 
            substate["currentStructureTemplateDescent"])
        attributes["bit"] = isp
    elif state1 == "number" and "typeSpecChar" in history \
            and "structure_stmt" in history:
        substate["currentStructureTemplateAttributes"][-1]["character"] = isp
        attributes = findTemplateAttributes(\
            identifiers[substate["currentStructureTemplateIdentifier"]], 
            substate["currentStructureTemplateDescent"])
        attributes["character"] = isp
    elif state2 == ["typeSpecChar", "number"]:
        if "declareBody_attributes_declarationList" in history:
            substate["commonAttributes"]["character"] = isp
        else:
            updateCurrentIdentifierAttribute(PALMAT, state, "character", isp)
    elif "declaration_list" in history and "expression" not in history \
            and "char_spec" not in history and "literalExp" not in history \
            and state1 != "number" and "repeated_constantMark" not in history:
        if s in identifiers:
            print("\tAlready declared:", sp)
            substate["currentIdentifier"] = ""
            return False, state
        substate["currentIdentifier"] = s
        identifiers[s] = { }
        identifiers[s].update(substate["commonAttributes"])
        if s[1:3] == "s_":
            identifiers[s]["structure"] = True
        if "declaration_labelToken_function" in history or \
                "nameId_bitFunctionIdentifierToken" in history or \
                "nameId_charFunctionIdentifierToken" in history or \
                "declaration_labelToken_function_minorAttrList" in history:
            addAttribute(identifiers, s, "function", True)
            addAttribute(identifiers, s, "scope", len(scopes))
            addAttribute(identifiers, s, "forward", True)
            addAttribute(identifiers, s, "parameters", [])
        elif "blockHeadProcedure" in history:
            addAttribute(identifiers, s, "procedure", True)
            addAttribute(identifiers, s, "scope", len(scopes))
            addAttribute(identifiers, s, "forward", True)
            addAttribute(identifiers, s, "parameters", [])
            addAttribute(identifiers, s, "assignments", [])
        return True, state
    elif state1 in ["variable", "bit_id"] and "call_assign_list" in history:
        if "callAssignments" not in substate["commonAttributes"]:
            substate["commonAttributes"]["callAssignments"] = []
        si, attributes = findIdentifier(s, PALMAT, scopeIndex)
        if attributes == None:
            substate["errors"]\
                .append("Variable %s in ASSIGN not found." % s[1:-1])
            #scope["children"].remove(i)
            #identifiers.pop(s)
            #PALMAT["scopes"][i]["parent"] = None
        else:
            substate["commonAttributes"]["callAssignments"].append((si, s[1:-1]))
    elif state1 == "call_key":
        substate["currentIdentifier"] = s
    elif state1 == "parameter":
        identifier = substate["currentIdentifier"]
        if "assign_list" in history:
            identifiers[identifier]["assignments"].append(s[1:-1])
        elif "parameter_list" in history:
            identifiers[identifier]["parameters"].append(s[1:-1])
    elif "function_name" in history or "procedure_name" in history or \
            "blockHeadProgram" in history or "blockHeadCompool" in history:
        for i in scope["children"]:
            if "name" in PALMAT["scopes"][i] and \
                    s == PALMAT["scopes"][i]["name"]:
                substate["warnings"]\
                    .append("Subroutine %s already exists; removing" % s[1:-1])
                scope["children"].remove(i)
                identifiers.pop(s)
                PALMAT["scopes"][i]["parent"] = None
                break
        substate["currentIdentifier"] = s
        if "function_name" in history:
            addAttribute(identifiers, s, "function", True)
            addAttribute(identifiers, s, "parameters", [])
        elif "procedure_name" in history:
            addAttribute(identifiers, s, "procedure", True)
            addAttribute(identifiers, s, "parameters", [])
            addAttribute(identifiers, s, "assignments", [])
        elif "blockHeadProgram" in history:
            addAttribute(identifiers, s, "program", True)
        elif "blockHeadCompool" in history:
            addAttribute(identifiers, s, "compool", True)
        addAttribute(identifiers, s, "scope", len(scopes))
    elif state1 == "label_definition":
        identifiers[s] = { "label" : [scopeIndex, len(instructions)] }
    elif state1 in ["basicStatementExit", "basicStatementRepeat"]:
        substate["labelExitRepeat"] = s
    elif state1 == "basicStatementGoTo":
        si, attributes = findIdentifier(s, PALMAT, scopeIndex)
        if attributes == None:
            substate["errors"].append("Can't find label %s.", sp)
            return False
        else:
            instructions.append({'goto': (si, s)})
    elif state1 == "number" and \
            ("write_key" in history or "read_key" in history):
        substate["LUN"] = sp
    elif state1 in ["forKey", "forKeyTemporary"]:
        if state1 == "forKeyTemporary":
            identifiers[s] = {"integer": True}
    elif state2 == ["bitSpecBoolean", "number"]:
        updateCurrentIdentifierAttribute(PALMAT, state, "bit", isp)
    elif (state2 == ["assignment", "variable"] or \
            history[-3:-1] == ["assignment", "variable"]) and \
                "subscript" not in history:
        # Identifier on LHS of an assignment.
        si, identDict = findIdentifier(s, PALMAT, scopeIndex, True)
        if identDict == None: 
            substate["errors"].append("Assignment to  " + sp + \
                                      " not allowed.")
            removeAncestors(PALMAT, scopeIndex)
            return False
        if "constant" in identDict or "parameter" in identDict:
            substate["errors"]\
                .append("Assignment to constant " + sp \
                        + " not possible.")
            removeAncestors(PALMAT, scopeIndex)
            return False
        substate["lhs"].append((si, sp))
    return True

# Reset the portion of the AST state-machine that handles individual statements.
def resetStatement():
    global substate
    substate["currentIdentifier"] = ""
    substate["commonAttributes"] = {}
    substate["lhs"] = []
    substate["expression"] = []
    substate["qual"] = []
    substate["qualInsert"] = -1
    forRemoval = []
    for key in substate:
        if "currentStructureTemplate" in key:
            forRemoval.append(key)
    for key in forRemoval:
        substate.pop(key)

# Transfer the expression stack to end of the PALMAT instruction list, 
# in reverse order, and clear the expression stack.
def expressionToInstructions(expression, instructions):
    while len(expression) > 0:
        instructions.append(expression.pop())
                    
#-----------------------------------------------------------------------------
# These are lbnfLabels that simply want to be added to the "history" list,
# and nothing else.  It's safe to call augmentHistory() with any lbnfLabel,
# because it just ignores the ones it doesn't like.

augmentationCandidates = [
    "arithConv",
    "arithExpTerm",
    "assignment",
    "assign_list",
    "attributes_typeAndMinorAttr",
    "attributes_arraySpec_typeAndMinorAttr",
    "basicStatementCall",
    "basicStatementDo",
    "basicStatementExit",
    "basicStatementGoTo",
    "basicStatementRepeat",
    "basicStatementWritePhrase",
    "bitConstFalse",
    "bitConstTrue",
    "bitConstString",
    "bit_id",
    "bit_exp",
    "blockHeadCompool",
    "blockHeadFunction",
    "blockHeadProcedure",
    "blockHeadProgram",
    "call_assign_list",
    "call_key",
    "charExpCat",
    "char_spec",
    "declaration_labelToken_function",
    "declaration_labelToken_function_minorAttrList",
    "declaration_labelToken_procedure",
    "declaration_list",
    "declareBody_attributes_declarationList",
    "declareBody_declarationList",
    "expression", 
    "forKey",
    "forKeyTemporary",
    "for_list",
    "for_listDiscrete",
    "func_stmt_body",
    "function_name",
    "ifClauseBitExp",
    "ifClauseRelExp",
    "ifStatement",
    "ifThenElseStatement",
    "label_definition",
    "literalExp",
    "nameId_bitFunctionIdentifierToken",
    "nameId_charFunctionIdentifierToken",
    "nameId_structIdentifierToken",
    "parameter",
    "parameter_list",
    "prePrimaryFunction",
    "procedure_name",
    "qual_struct",
    "read_arg",
    "read_key",
    "relational_exp",
    "relational_expOR",
    "minorAttributeRepeatedConstant",
    "prePrimaryRtlShapingHeadInteger",
    "prePrimaryRtlShapingHeadScalar",
    "prePrimaryRtlShapingHeadVector",
    "prePrimaryRtlShapingHeadMatrix",
    "prePrimaryRtlShapingHeadIntegerSubscript",
    "prePrimaryRtlShapingHeadScalarSubscript",
    "prePrimaryRtlShapingHeadVectorSubscript",
    "prePrimaryRtlShapingHeadMatrixSubscript",
    "repeated_constantMark",
    "sQdQName_doublyQualNameHead_literalExpOrStar",
    "structure_id",
    "struct_stmt_head",
    "struct_stmt_tail",
    "sub_exp",
    "subscript",
    "then",
    "true_part",
    "typeSpecArith",
    "variable",
    "write_arg",
    "write_key",
    ]
def augmentHistory(state, lbnfLabel):
    if lbnfLabel not in augmentationCandidates:
        return state
    newState = copy.deepcopy(state)
    newState["history"].append(lbnfLabel)
    return newState

#----------------------------------------------------------------------------

def declare_statement(PALMAT, state):
    resetStatement()
    return True, state
    
def temporary_stmt(PALMAT, state):
    resetStatement()
    return True, state
    
def structure_stmt(PALMAT, state):
    resetStatement()
    return True, fixupState(state, fsAugment)

def any_statement(PALMAT, state):
    resetStatement()
    return True, state
    
def arithConv_scalar(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "scalar")
    return True, state
    
def arithConv_integer(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "integer")
    return True, state
    
def arithConv_vector(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "vector", 3)
    return True, state
    
def arithConv_matrix(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "matrix", [3, 3])
    return True, state
    
def bitSpecBoolean(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "bit", 1)
    if state["history"][-1] == "attributes_typeAndMinorAttr":
        return True, fixupState(state, fsAugment)
    return True, state
    
def typeSpecChar(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "character", "^?^")
    if state["history"][-1] == "attributes_typeAndMinorAttr":
        return True, fixupState(state, fsAugment)
    return True, state
    
def precSpecDouble(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "double")
    return True, state

def init_or_const_headInitial(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "initial", "^?^")
    return True, state
    
def init_or_const_headConstant(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "constant", "^?^")
    return True, state

def minorAttributeDense(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "dense")
    return True, state

def minorAttributeStatic(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "static")
    return True, state

def minorAttributeAutomatic(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "automatic")
    return True, state

def minorAttributeAligned(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "aligned")
    return True, state

def minorAttributeAccess(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "access")
    return True, state

def minorAttributeLock(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "lock", "^?^")
    return True, state

def minorAttributeRemote(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "remote")
    return True, state

def minorAttributeRigid(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "rigid")
    return True, state

def minorAttributeLatched(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "latched")
    return True, state

def minorAttributeNonHal(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "nonhal", "^?^")
    return True, state

def doublyQualNameHead_vector(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "vector", [])
    return True, fixupState(state, fsAugment)

def doublyQualNameHead_matrix(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "matrix", [])
    return True, state

def doublyQualNameHead_matrix_literalExpOrStar(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "matrix", [])
    return True, fixupState(state, fsAugment)

def arraySpec_arrayHead_literalExpOrStar(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "array", [])
    return True, fixupState(state, fsAugment)

def level(PALMAT, state):
    if len(state["history"]) > 0 and \
            state["history"][-1] in ["bitSpecBoolean", "typeSpecChar", 
                    "sQdQName_doublyQualNameHead_literalExpOrStar"]:
        return True, fixupState(state, fsAugment, "number")
    return True, state

def simple_number(PALMAT, state):
    if state["history"][-1] in ["bitSpecBoolean", "typeSpecChar", 
                    "sQdQName_doublyQualNameHead_literalExpOrStar"]:
        return True, fixupState(state, fsAugment, "number")
    return True, state

def literalStar(PALMAT, state):
    last = state["history"][-1]
    if last == "bitSpecBoolean":
        updateCurrentIdentifierAttribute(PALMAT, state, "bit", "*")
    elif last == "typeSpecChar":
        updateCurrentIdentifierAttribute(PALMAT, state, "character", "*")
    elif last in ["sQdQName_doublyQualNameHead_literalExpOrStar",
                       "doublyQualNameHead_matrix_literalExpOrStar",
                       "arraySpec_arrayHead_literalExpOrStar"]:
        scope = PALMAT["scopes"][state["scopeIndex"]]
        identifiers = scope["identifiers"]
        if substate["currentIdentifier"] == "":
            identifierDict = substate["commonAttributes"]
        elif substate["currentIdentifier"] in identifiers:
            identifierDict = identifiers[substate["currentIdentifier"]]
        else:
            return True, state
        if "vector" in identifierDict:
            identifierDict["vector"] = "*"
        elif "matrix" in identifierDict:
            identifierDict["matrix"].append("*")
        elif "array" in identifierDict:
            identifierDict["array"].append("*")
    return True, state

def number(PALMAT, state):
    return True, fixupState(state, fsAugment, "number")

def compound_number(PALMAT, state):
    return True, fixupState(state, fsAugment, "number")

def char_string(PALMAT, state):
    return True, fixupState(state, fsAugment, "string")

def while_clause(PALMAT, state):
    currentScope = PALMAT["scopes"][state["scopeIndex"]]
    if "isUntil" in substate:
        substate.pop("isUntil")
    else:
        if currentScope["type"] == "do":
            currentScope["type"] = "do while"
    return True, fixupState(state, fsAugment)

def whileKeyUntil(PALMAT, state):
    currentScope = PALMAT["scopes"][state["scopeIndex"]]
    if currentScope["type"] in ["do", "do while"]:
        currentScope["type"] = "do until"
    substate["isUntil"] = True
    return True, state

#-----------------------------------------------------------------------------
# I think this has to go at the end of the module.

objects = globals()

