#!/usr/bin/env python3
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or 
            modified for any purpose whatever without licensing.
Filename:   xtokenize.py
Purpose:    This tokenizes a pseudo-statement for XCOM-I.py.
Requires:   Python 3.6 or later.
Reference:  http://www.ibibio.org/apollo/Shuttle.html
Mods:       2024-03-21 RSB  Began

Unfortunately, I don't know that it's written anywhere how tokens of XPL/I may
differ from those of XPL.  I'l follow the description of McKeeman et al 
(i.e., XPL) for as long as I can, and then make ad hoc changes based on what
I find in HAL/S-FC source code.

Note that pseudo-statements are devoid of inline comments, but may include
XPL/I directives of the form
    /?...?/
These directives are left unparsed.
'''

# See p. 132 of McKeeman et al.
breakCharacters = ['_', '@', '#', '$'] 
reservedWords = {"BIT", "BY", "CALL", "CASE", "CHARACTER", "DO",
                     "DECLARE", "ELSE", "END", "EOF", "FIXED", "GO",
                     "GOTO", "IF", "INITIAL", "LABEL", "LITERALLY", "MOD",
                     "PROCEDURE", "RETURN", "THEN", "TO", "WHILE",
                     "COMMON"}
# See pp. 140-142 of McKeeman et al.  For `builtIns`, the key values are
# the number of parameters accepted by the function; if the number of parameters
# is variable, then the value is a tuple of the allowed numbers of parameters.
builtIns = {
    "ADDR": 1, 
    "BYTE": (1, 2), 
    "CLOCK_TRAP": 2, 
    "COMPACTIFY": 0, 
    "COREBYTE": 1, 
    "COREWORD": 1, 
    "DATE": 0, 
    "DATE_OF_GENERATION": 0, 
    "DESCRIPTOR": 1, 
    "EXIT": 0, 
    "FILE": 2, 
    "FREEBASE": 0, 
    "FREELIMIT": 0, 
    "FREEPOINT": 0, 
    "INLINE": (3, 4, 5), 
    "INPUT": (0, 1), 
    "INTERRUPT_TRAP": 2, 
    "LENGTH": 1, 
    "MONITOR": 2, 
    "MONITOR_LINK": 0, 
    "NDESCRIPT": 0, 
    "OUTPUT": (0, 1), 
    "SHL": 2, 
    "SHR": 2,
    "SUBSTR": (2, 3), 
    "TIME": 0, 
    "TIME_OF_GENERATION": 0, 
    "TRACE": 0, 
    "UNTRACE": 0
    }
# See p. 138 of McKeeman et al.  These are just the leading (non-alpha) 
# characters of (potentially multi-character) operator names.
operatorLeadins = {"|", "&", "~", "=", "<", ">", "+", "-", "*", "/", "."}
operatorPairs = {"~=", "~<", "~>", "<=", ">=", "||"}

# Returns a list of tokens, empty if the pseudoStatement isn't parsable
# (such as being of the form /?...?/).  Two types of error conditions are
# reported: a token type of "unrecognized" and token type of "string" with
# an attribute of "unterminated".
digits = {
    "x": set(['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C',
          'D', 'E', 'F']),
    "d": set(['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']),
    "o": set(['0', '1', '2', '3', '4', '5', '6', '7']),
    "q": set(['0', '1', '2', '3']),
    "b": set(['0', '1'])}
def xtokenize(pseudoStatement):
    tokens = []
    if pseudoStatement[:2] in ["/?", "/%"]:
        return tokens
    # Loop on the characters of the pseudoStatement.
    i = 0
    while i < len(pseudoStatement):
        c = pseudoStatement[i]
        i += 1
        if c == " ":
            pass
        # Various punctuation.
        elif c in [";", "(", ")", ",", ":"]:
            tokens.append(c)
        # Is this a number?
        elif c.isdigit():
            # Is it 0x..., 0b..., 0o..., or 0q... number in some non-10 radix?
            if c == '0' and i + 1 < len(pseudoStatement) and \
                    pseudoStatement[i] in ["x", "b", "o", "q"]:
                radixDigits = digits[pseudoStatement[i]]
                i += 1
            else: # No, base 10.
                radixDigits = digits["d"]
                i -= 1
            j = i
            while j < len(pseudoStatement) and \
                    pseudoStatement[j] in radixDigits:
                j += 1
            tokens.append({"number" : \
                           int(pseudoStatement[i : j], len(radixDigits))})
            i = j
        # Is this the start of an identifier (or symilar symbolically)?
        elif c.isalpha() or c in breakCharacters:
            j = i
            while j < len(pseudoStatement) and \
                    (pseudoStatement[j].isalnum() or \
                     pseudoStatement[j] in breakCharacters or \
                     pseudoStatement[j] == "."):
                j += 1
            if pseudoStatement[j - 1] == ".":
                j -= 1
            identifier = pseudoStatement[i - 1 : j].upper()
            i = j
            if identifier == "MOD":
                tokens.append({"operator": "mod"})
            elif identifier in reservedWords:
                tokens.append({"reserved": identifier})
            elif identifier in builtIns:
                tokens.append({"builtin": identifier})
            else:
                tokens.append({"identifier": identifier})
        # Is this the start of a quoted string?  Recall that quoted strings
        # will have been preprocessed so as not to contain single-quote 
        # characters.
        elif c == "'":
            j = i
            while j < len(pseudoStatement) and pseudoStatement[j] != "'":
                j += 1
            if j >= len(pseudoStatement):
                tokens.append({"string": pseudoStatement[i : j], 
                               "unterminated": True})
            else:
                tokens.append({"string": pseudoStatement[i : j]})
                j += 1
            i = j
        # Is this the start of an operator?  Recall that the logical-not 
        # character will have been replaced by '~' prior to calling xtokenize.
        elif c in operatorLeadins:
            # Check the multi-character possibilities.
            pair = pseudoStatement[i - 1 : i + 1]
            if pair in operatorPairs:
                tokens.append({"operator": pair})
                i += 1
            else:
                tokens.append({"operator": c})
        else:
            tokens.append({"unrecognized": c})
    return tokens
