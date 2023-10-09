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

f = sys.stdin
fix = False
for parm in sys.argv[1:]:
    if parm.startswith("--file="):
        f = open(parm[7:], "r")
    elif parm == "--fix":
        fix = True
    else:
        print("Unknown parameter:", parm, file=sys.stderr)

#-----------------------------------------------------------------------------
# The following are lists of various categories of global objects found in g.py

noArgFunctions = ("EJECT_PAGE", "DOUBLE_SPACE", "NOSPACE")

argFunctions = (
"ARRAY_SUB_COUNT",
"ATOMS",
"BI_XREF_CELL",
"BLOCK_SRN_DATA",
"COMSUB_END",
"DATE_OF_COMPILATION",
"DWN_CLS",
"DWN_ERR",
"DWN_STMT",
"DWN_UNKN",
"DWN_VER",
"EXTENT",
"FIRST_FREE",
"FIRST_STMT",
"FL_NO",
"INCLUDE_LIST_HEAD",
"LIT1",
"LIT2",
"LIT3",
"LIT_CHAR",
"LIT_CHAR_AD",
"LIT_CHAR_USED",
"LIT_TOP",
"MACRO_BYTES",
"MACRO_TEXT",
"NDECSY",
"OPTIONS_CODE",
"OUTER_REF",
"OUTER_REF_FLAGS",
"PATCHSAVE",
"STMT_DATA_HEAD",
"STMT_NUM",
"STRUCTURE_SUB_COUNT",
"SUB_COUNT",
"SYT_ADDR",
"SYT_ARRAY",
"SYT_CLASS",
"SYT_FLAGS",
"SYT_FLAGS2",
"SYT_HASHLINK",
"SYT_LINK1",
"SYT_LINK2",
"SYT_NAME",
"SYT_NEST",
"SYT_PTR",
"SYT_SCOPE",
"SYT_SORT",
"SYT_TYPE",
"SYT_XREF",
"TIME_OF_COMPILATION",
"TOGGLE",
"VAR_LENGTH",
"XMADD",
"XMSUB",
"XREF",
"XREF_INDEX",
"XSET"
    )

arrayVariables = (
"ARRAYNESS_STACK",
"BASE_PARM_LEVEL",
"BI_ARG",
"BI_FLAGS",
"BI_INDEX",
"BI_INDX",
"BI_INFO",
"BI_LOC",
"BI_NAME",
"BI_XREF",
"BLOCK_MODE",
"BLOCK_SYTREF",
"C",
"CARD_TYPE",
"CASE_STACK",
"CLOCK",
"CONTROL",
"CURRENT_ARRAYNESS",
"DO_CHAIN",
"DO_INX",
"DO_LOC",
"DO_PARSE",
"DW",
"ERROR_PTR",
"EXT_P",
"FACTORED_S_ARRAY",
"FCN_ARG",
"FCN_LOC",
"FCN_MODE",
"FIRST_TIME",
"FIRST_TIME_PARM",
"FIXF",
"FIXL",
"FIXV",
"GRAMMAR_FLAGS",
"IC_FORM",
"IC_LEN",
"IC_LOC",
"IC_TYPE",
"IC_VAL",
"IFDO_FLAG",
"INCL_SRN",
"INDENT_STACK",
"INIT_AFCBAREA",
"INIT_APGAREA",
"INPUT_REC",
"INX",
"LINK_SORT",
"LOC_P",
"LOOK_STACK",
"LRECL",
"MACRO_CALL_PARM_TABLE",
"MACRO_EXPAN_STACK",
"MACRO_TEXTS",
"MAC_XREF",
"M_BLANK_COUNT",
"M_CENT",
"M_P",
"M_PRINT",
"M_TOKENS",
"NEST_STACK",
"NUM_OF_PARM",
"OUTER_REF_PTR",
"OUTER_REF_TABLE",
"OVER_PUNCH_TYPE",
"PARM_REPLACE_PTR",
"PARM_STACK_PTR",
"PARSE_STACK",
"PATCH_TEXT_LIMIT",
"P_CENT",
"pCON",
"pDESC",
"pPRO",
"PROCMARK_STACK",
"PROGRAM_LAYOUT",
"PSEUDO_FORM",
"PSEUDO_LENGTH",
"PSEUDO_TYPE",
"PTR",
"pVALS",
"RVL",
"RVL_STACK1",
"RVL_STACK2",
"S_ARRAY",
"SAVE_BCD",
"SAVE_ERROR_MESSAGE",
"SAVE_GROUP",
"SAVE_PATCH",
"SAVE_SEVERITY",
"SAVE_STACK_DUMP",
"SCOPEp_STACK",
"SRN",
"SRN_BLOCK_RECORD",
"SRN_COUNT",
"STAB2_STACK",
"STAB_STACK",
"STACK_PTR",
"STATE_STACK",
"STMT_STACK",
"SYT_HASHSTART",
"TEXT_LIMIT",
"TOKEN_FLAGS",
"VAL_P",
"VAR",
"VAR_ARRAYNESS",
"VOCAB_INDEX"
    )

# Here's a list of all simple (i.e., non-arrayed) variables I find in g.py.
simpleVariables = (
"ACCESS_FLAG",
"ACCESS_FOUND",
"ADDED",
"ADDING",
"ADDR_PRESENT",
"ALDENSE_FLAGS",
"ALIGNED_FLAG",
"ANY_TYPE",
"ARITH_FUNC_TOKEN",
"ARITH_TOKEN",
"ARRAY_DIM_LIM",
"ARRAY_FLAG",
"ARRAYNESS_FLAG",
"ASIZE",
"AS_PTR",
"AS_PTR_MAX",
"ASSIGN_ARG_LIST",
"ASSIGN_CONTEXT",
"ASSIGN_PARM",
"ATOMp_FAULT",
"ATOMp_LIM",
"ATTR_BEGIN_FLAG",
"ATTR_FOUND",
"ATTRIBUTES",
"ATTRIBUTES2",
"ATTR_INDENT",
"ATTR_LOC",
"ATTR_MASK",
"AUTO_FLAG",
"AUTSTAT_FLAGS",
"BCD",
"BCD_PTR",
"BEGINP",
"BI_FUNC_FLAG",
"BI_LIMIT",
"BIT_FUNC_TOKEN",
"BIT_LENGTH",
"BIT_LENGTH_LIM",
"BIT_NDX",
"BIT_TOKEN",
"BIT_TYPE",
"BLANK_COUNT",
"BUILDING_TEMPLATE",
"CALLED_LABEL",
"CARD_COUNT",
"CASE_LEVEL",
"CASE_LEVEL_LIM",
"CHARACTER_STRING",
"CHAR_FUNC_TOKEN",
"CHAR_LENGTH",
"CHAR_LENGTH_LIM",
"CHAR_NDX",
"CHAR_TOKEN",
"CHAR_TYPE",
"CLASS",
"CLOSE_BCD",
"CMPL_MODE",
"COMMA",
"COMMENT_COUNT",
"COMMENTING",
"COMPARE_SOURCE",
"COMPILING",
"COMPOOL_LABEL",
"CONCATENATE",
"CONSTANT_FLAG",
"CONTEXT",
"CPD_NUMBER",
"CROSS",
"CROSS_COUNT",
"CROSS_TOKEN",
"CUR_CARD",
"CUR_IC_BLK",
"CURLBLK",
"CURRENT_ATOM",
"CURRENT_CARD",
"CURRENT_SCOPE",
"CURRENT_SRN",
"DATE_OF_GENERATION",
"DECLARE_CONTEXT",
"DECLARE_TOKEN",
"DEFAULT_ATTR",
"DEFAULT_TYPE",
"DEF_BIT_LENGTH",
"DEF_CHAR_LENGTH",
"DEFINED_LABEL",
"DEF_MAT_LENGTH",
"DEF_VEC_LENGTH",
"DELAY_CONTEXT_CHECK",
"DELETED",
"DELETING",
"DENSE_FLAG",
"DEVICE_LIMIT",
"DO_INIT",
"DO_LEVEL",
"DO_LEVEL_LIM",
"DOLLAR",
"DONT_SET_WAIT",
"DOT",
"DOT_COUNT",
"DO_TOKEN",
"DOT_TOKEN",
"DOUBLE",
"DOUBLE_FLAG",
"DOUBLELIT",
"DUMMY_FLAG",
"DUPL_FLAG",
"DW_AD",
"ELSE_FLAG",
"ELSEIF_PTR",
"END_FLAG",
"END_GROUP",
"END_OF_INPUT",
"ENDSCOPE_FLAG",
"EOFILE",
"EQUATE_CONTEXT",
"EQUATE_IMPLIED",
"EQUATE_LABEL",
"EQUATE_TOKEN",
"ERRLIM",
"ERROR_COUNT",
"EVENT_TOKEN",
"EVENT_TYPE",
"EVIL_FLAG",
"EXCLUSIVE_FLAG",
"EXPONENT",
"EXPONENTIATE",
"EXPONENT_LEVEL",
"EXP_OVERFLOW",
"EXPRESSION_CONTEXT",
"EXP_TYPE",
"EXT_ARRAY_PTR",
"EXTERNAL_FLAG",
"EXTERNALIZE",
"EXTERNAL_MODE",
"FACTOR",
"FACTORED_ATTRIBUTES",
"FACTORED_ATTRIBUTES2",
"FACTORED_ATTR_MASK",
"FACTORED_BIT_LENGTH",
"FACTORED_CHAR_LENGTH",
"FACTORED_CLASS",
"FACTORED_IC_FND",
"FACTORED_IC_PTR",
"FACTORED_MAT_LENGTH",
"FACTORED_N_DIM",
"FACTORED_NONHAL",
"FACTORED_STRUC_DIM",
"FACTORED_STRUC_PTR",
"FACTORED_TYPE",
"FACTORED_VEC_LENGTH",
"FACTOR_FOUND",
"FACTORING",
"FACTOR_LIM",
"FALSE",
"FCN_LV",
"FCN_LV_MAX",
"FIRST_CARD",
"FIX_DIM",
"FIXING",
"FOUND_CENT",
"FREEPOINT",
"FUNC_CLASS",
"FUNC_FLAG",
"FUNC_MODE",
"GRAMMAR_FLAGS_UNFLOW",
"GROUP_NEEDED",
"HALMAT_BLOCK",
"HALMAT_CRAP",
"HALMAT_FILE",
"HALMAT_OK",
"HALMAT_RELOCATE_FLAG",
"HMAT_OPT",
"HOST_BIT_LENGTH_LIM",
"I",
"IC_FILE",
"IC_FND",
"IC_LIM",
"IC_LINE",
"IC_MAX",
"IC_ORG",
"IC_PTR",
"ICQ",
"IC_SIZ",
"IC_SIZE",
"IDENT_COUNT",
"ID_LIMIT",
"ID_LOC",
"ID_TOKEN",
"IF_FLAG",
"IF_TOKEN",
"ILL_EQUATE_ATTR",
"ILL_INIT_ATTR",
"ILL_LATCHED_ATTR",
"ILL_MINOR_STRUC",
"ILL_NAME_ATTR",
"ILL_TEMPL_ATTR",
"ILL_TEMPORARY_ATTR",
"IMP_DECL",
"IMPLICIT_T",
"IMPLIED_TYPE",
"IMPLIED_UPDATE_LABEL",
"IMPL_T_FLAG",
"INACTIVE_FLAG",
"INCL_LOG_MSG",
"INCL_SRN_MARK",
"INCLUDE_CHAR",
"INCLUDE_COMPRESSED",
"INCLUDE_COUNT",
"INCLUDED_REMOTE",
"INCLUDE_END",
"INCLUDE_LIST",
"INCLUDE_LIST2",
"INCLUDE_MSG",
"INCLUDE_OFFSET",
"INCLUDE_OPENED",
"INCLUDE_STMT",
"INCLUDING",
"INCREMENT_DOWN_STMT",
"IND_CALL_LAB",
"INDENT_INCR",
"INDENT_LEVEL",
"IND_LINK",
"INFORMATION",
"INIT_CONST",
"INIT_EMISSION",
"INIT_FLAG",
"INITIAL_INCLUDE_RECORD",
"INLINE_FLAG",
"INLINE_INDENT",
"INLINE_INDENT_RESET",
"INLINE_LABEL",
"INLINE_LEVEL",
"INLINE_MODE",
"INLINE_STMT_RESET",
"INP_OR_CONST",
"INPUT_DEV",
"INPUT_PARM",
"INT_NDX",
"INT_TYPE",
"IORS_TYPE",
"J",
"K",
"KIN",
"L",
"LABEL_CLASS",
"LABEL_COUNT",
"LABEL_DEFINITION",
"LABEL_FLAG",
"LABEL_IMPLIED",
"LAB_TOKEN",
"LAST",
"LAST_SPACE",
"LAST_STAB_CELL_PTR",
"LAST_WRITE",
"LATCHED_FLAG",
"LEFT_BRACE_FLAG",
"LEFT_BRACKET_FLAG",
"LEFT_PAREN",
"LEVEL",
"LINE_LIM",
"LINE_MAX",
"LIST_EXP_LIM",
"LIST_INCLUDE",
"LISTING2",
"LISTING2_COUNT",
"LIT_BUF_SIZE",
"LIT_CHAR_SIZE",
"LITFILE",
"LITLIM",
"LITMAX",
"LITORG",
"LIT_PTR",
"LIT_TOP_MAX",
"LOCK_FLAG",
"LOCK_LIM",
"LOOK",
"LOOKED_RECORD_AHEAD",
"LOOKUP_ONLY",
"LSIZE",
"MAC_CTR",
"MAC_NUM",
"MACRO_ADDR",
"MACRO_ARG_COUNT",
"MACRO_ARG_FLAG",
"MACRO_CELL_LIM",
"MACRO_EXPAN_LEVEL",
"MACRO_EXPAN_LIMIT",
"MACRO_FOUND",
"MACRO_NAME",
"MACRO_POINT",
"MACRO_TEXT_LIM",
"MAIN_SCOPE",
"MAJ_STRUC",
"MAT_DIM_LIM",
"MAT_LENGTH",
"MATRIX_COUNT",
"MATRIXP",
"MATRIX_PASSED",
"MAT_TYPE",
"MAXNEST",
"MAX_PARAMETER",
"MAX_PTR_TOP",
"MAX_SEVERITY",
"MAXSP",
"MAX_STRING_SIZE",
"MAX_STRUC_LEVEL",
"MEMBER",
"MEMORY_FAILURE",
"MISC_NAME_FLAG",
"MORE",
"MOVEABLE",
"MOVE_ELSE",
"MP",
"MPP1",
"MTX_NDX",
"NAME_BIT",
"NAME_FLAG",
"NAME_HASH",
"NAME_IMPLIED",
"NAME_PSEUDOS",
"NAMING",
"N_DIM",
"N_DIM_LIM",
"N_DIM_LIM_PLUS_1",
"NEST",
"NEST_LEVEL",
"NEST_LIM",
"NEW_LEVEL",
"NEW_MEL",
"NEXT",
"NEXT_CC",
"NEXT_CHAR",
"NEXT_CHAR_RVL",
"NEXTIME_LOC",
"NEXT_SUB",
"NO_ARG_ARITH_FUNC",
"NO_ARG_BIT_FUNC",
"NO_ARG_CHAR_FUNC",
"NO_ARG_STRUCT_FUNC",
"NO_LOOK_AHEAD_DONE",
"NO_MORE_PATCH",
"NO_MORE_SOURCE",
"NONBLANK_FOUND",
"NO_NEW_XREF",
"NONHAL",
"NONHAL_FLAG",
"NOT_ASSIGNED_FLAG",
"NSY",
"NT",
"NT_PLUS_1",
"NUMBER",
"NUM_ELEMENTS",
"NUM_EL_MAX",
"NUM_FL_NO",
"NUM_STACKS",
"OLD_LEVEL",
"OLD_MEL",
"OLD_MP",
"OLD_PEL",
"OLD_PR_PTR",
"OLD_TOPS",
"ONE_BYTE",
"ON_ERROR_PTR",
"OUTER_REF_INDEX",
"OUTER_REF_LIM",
"OUTER_REF_MAX",
"OUT_PREV_ERROR",
"OUTPUT_STACK_MAX",
"OUTPUT_WRITER_DISASTER",
"OVER_PUNCH",
"OVER_PUNCH_SIZE",
"PAD1",
"PAD2",
"PAGE",
"PAGE_THROWN",
"PARM_CONTEXT",
"PARM_COUNT",
"PARM_EXPAN_LEVEL",
"PARM_EXPAN_LIMIT",
"PARM_FIELD",
"PARM_FLAGS",
"PARMS_PRESENT",
"PARMS_WATCH",
"PARTIAL_PARSE",
"PASS",
"PAT_CARD",
"PATCH_CARD",
"PATCH_COUNT",
"PATCH_INCL_HEAD",
"PATCH_SRN",
"PCCOPY_INDEX",
"PC_LIMIT",
"PC_STMT_TYPE_BASE",
"PERCENT_MACRO",
"PERIOD",
"PHASE1_FREESIZE",
"PLUS",
"pOPTIONS_CODE",
"PP",
"PPTEMP",
"PREV_ELINE",
"PREV_STMT_NUM",
"PRINT_FLAG",
"PRINT_FLAG_OFF",
"PRINT_INCL_HEAD",
"PRINT_INCL_TAIL",
"PRINTING_ENABLED",
"PROC_LABEL",
"PROCMARK",
"PROC_MODE",
"PROG_LABEL",
"PROG_MODE",
"PROGRAM_ID",
"PROGRAM_LAYOUT_INDEX",
"PROGRAM_LAYOUT_LIM",
"PTR_MAX",
"PTR_TOP",
"QUALIFICATION",
"READ_ACCESS_FLAG",
"RECOVERING",
"REDUCTIONS",
"REENTRANT_FLAG",
"REFER_LOC",
"REF_ID_LOC",
"REGULAR_PROCMARK",
"REL_OP",
"REMOTE_FLAG",
"REPLACE_PARM_CONTEXT",
"REPLACE_TEXT",
"REPLACE_TEXT_PTR",
"REPLACE_TOKEN",
"REPLACING",
"REPL_ARG_CLASS",
"REPL_CLASS",
"REPL_CONTEXT",
"RESERVED_LIMIT",
"RESERVED_WORD",
"RESTORE",
"REV_CAT",
"RIGHT_BRACE_FLAG",
"RIGHT_BRACKET_FLAG",
"RIGID_FLAG",
"RSIZE",
"RT_PAREN",
"S",
"SANITY_CHECK",
"SAVE1",
"SAVE2",
"SAVE_ARRAYNESS_FLAG",
"SAVE_BCD_MAX",
"SAVE_BLANK_COUNT",
"SAVE_CARD",
"SAVE_DO_LEVEL",
"SAVE_ERROR_LIM",
"SAVE_INDENT_LEVEL",
"SAVE_NEXT_CHAR",
"SAVE_OVER_PUNCH",
"SAVE_PE",
"SAVE_SCOPE",
"SAVE_SRN1",
"SAVE_SRN2",
"SAVE_SRN_COUNT1",
"SAVE_SRN_COUNT2",
"SBIT_NDX",
"SCALAR_COUNT",
"SCALARP",
"SCALAR_TYPE",
"SCAN_COUNT",
"SCLR_NDX",
"SDF_INCL_FLAG",
"SDF_INCL_LIST",
"SDF_INCL_OFF",
"SD_FLAGS",
"SDF_OPEN",
"SDL_OPTION",
"SEMI_COLON",
"SEVERITY",
"SIMULATING",
"SINGLE_FLAG",
"SM_FLAGS",
"SMRK_FLAG",
"SOME_BCD",
"SP",
"SQUEEZING",
"SREF_OPTION",
"SRN_COUNT_MARK",
"SRN_FLAG",
"SRN_MARK",
"SRN_PRESENT",
"STAB2_MARK",
"STAB2_STACKTOP",
"STAB_MARK",
"STAB_STACKLIM",
"STAB_STACKTOP",
"STACK_DUMPED",
"STACK_DUMP_MAX",
"STACK_DUMP_PTR",
"STACKSIZE",
"STARRED_DIMS",
"STARS",
"START_POINT",
"STATE",
"STATEMENT_SEVERITY",
"STATIC_FLAG",
"STMT_END_FLAG",
"STMT_END_PTR",
"STMT_LABEL",
"STMT_PTR",
"STMT_TYPE",
"STRING_MASK",
"STRING_OVERFLOW",
"STRUC_DIM",
"STRUC_PTR",
"STRUC_SIZE",
"STRUCT_FUNC_TOKEN",
"STRUC_TOKEN",
"STRUCT_TEMPLATE",
"STRUCTURE_WORD",
"SUB_END_PTR",
"SUBHEADING",
"SUBSCRIPT_LEVEL",
"SUB_SEEN",
"SUB_START_TOKEN",
"SUPPRESS_THIS_TOKEN_ONLY",
"SYSIN_COMPRESSED",
"SYT_HASHSIZE",
"SYT_INDEX",
"SYT_MAX",
"SYTSIZE",
"TASK_LABEL",
"TASK_MODE",
"TEMP",
"TEMP1",
"TEMP2",
"TEMP3",
"TEMP_INDEX",
"TEMPLATE_CLASS",
"TEMPLATE_IMPLIED",
"TEMPL_NAME",
"TEMPORARY",
"TEMPORARY_FLAG",
"TEMPORARY_IMPLIED",
"TEMP_STRING",
"TEMP_SYN",
"TERMP",
"TIME_OF_GENERATION",
"T_INDEX",
"TOKEN",
"TOKEN_FLAGS_UNFLOW",
"TOO_MANY_ERRORS",
"TOO_MANY_LINES",
"TOP_OF_PARM_STACK",
"TPL_FLAG",
"TPL_FUNC_CLASS",
"TPL_LAB_CLASS",
"TPL_LRECL",
"TPL_NAME",
"TPL_REMOTE",
"TPL_VERSION",
"TRUE",
"TYPE",
"UNMOVEABLE",
"UNSPEC_LABEL",
"UPDATE_BLOCK_LEVEL",
"UPDATE_INPUT_DEV",
"UPDATE_MODE",
"UPDATING",
"VALUE",
"VAR_CLASS",
"VBAR",
"VEC_LENGTH",
"VEC_LENGTH_LIM",
"VEC_NDX",
"VECTOR_COUNT",
"VECTORP",
"VEC_TYPE",
"WAIT",
"X1",
"X8",
"XADLP",
"XAFOR",
"XAST",
"XASZ",
"XBAND",
"XBCAT",
"XBFNC",
"XBNOT",
"XBOR",
"XBRA",
"XBTRU",
"XCANC",
"XCAND",
"XCCAT",
"XCDEF",
"XCFOR",
"XCLBL",
"XCLOS",
"XCNOT",
"XCO_D",
"XCO_N",
"XCOR",
"XCSZ",
"XCTST",
"XDCAS",
"XDFOR",
"XDLPE",
"XDSMP",
"XDSUB",
"XDTST",
"XECAS",
"XEDCL",
"XEFOR",
"XEINT",
"XELRI",
"XERON",
"XERSE",
"XESMP",
"XETRI",
"XETST",
"XEXTN",
"XFBRA",
"XFCAL",
"XFDEF",
"XFILE",
"XICLS",
"XIDEF",
"XIDLP",
"XIFHD",
"XIMD",
"XIMRK",
"XINL",
"XITOS",
"XLBL",
"XLFNC",
"XLIT",
"XMDEF",
"XMINV",
"XMMPR",
"XMSPR",
"XMTRA",
"XMVPR",
"XNASN",
"XNINT",
"XOFF",
"XPCAL",
"XPDEF",
"XPMAR",
"XPMHD",
"XPMIN",
"XPRIO",
"XREF_ASSIGN",
"XREF_FULL",
"XREF_LIM",
"XREF_MASK",
"XREF_REF",
"XREF_SUBSCR",
"XRTRN",
"XSCHD",
"XSEXP",
"XSFAR",
"XSFND",
"XSFST",
"XSGNL",
"XSIEX",
"XSLRI",
"XSMRK",
"XSTOI",
"XSTRI",
"XSYT",
"XTDCL",
"XTDEF",
"XTERM",
"XTINT",
"XTSUB",
"XUDEF",
"XVAC",
"XVCRS",
"XVDOT",
"XVMPR",
"XVSPR",
"XVVPR",
"XWAIT",
"XXPT",
"XXREC",
"XXXAR",
"XXXND",
"XXXST",
    )

#-----------------------------------------------------------------------------

'''
First, read the entire source file, reformat it, and store it in
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

for line in f:
    line = line.rstrip("\n").replace("¬", "~").replace("¢", "`")[:80].strip()
    if fix:
        line = re.sub(r" */\* *[CD]R[0-9]+ *\*/ *", " ", line)
        line = re.sub(r" */\* *[CD]R[0-9]+ *, *[CD]R[0-9]+ *\*/ *", " ", line)
        line = re.sub(r"/\* *[CD]R[0-9]+ *", "/*", line)
        line = re.sub(r'"([0-9A-F]+)"', "0x\\1", line)
    if inIdentifier:
        # Take care of the case in which the preceding line ended with an
        # identifier.
        if identifier in ["PROCEDURE", "DO"]:
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
                    if identifier in ["PROCEDURE", "DO"]:
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
    for i in range(len(bufferedDataset)):
        line = bufferedDataset[i]
        line = re.sub(r"\bIF\b", "if", line)
        line = re.sub(r"\bELSE *if\b", "elif", line)
        line = re.sub(r"\bELSE\b", "else:", line)
        line = re.sub(r" *THEN\b", ":", line)
        line = re.sub(r"\bRETURN\b", "return", line)
        line = re.sub(r" *\|\| *", " + ", line)
        line = re.sub(r"\^=", "!=", line)
        line = re.sub(r"\bCALL *", "", line)
        line = re.sub(r"\bERROR *\( *CLASS_", "ERROR(d.CLASS_", line)
        line = re.sub(r"\bERRORS *\( *CLASS_", "ERRORS(d.CLASS_", line)
        # Note that this won't correctly account for local variables of the 
        # same name as globals, so those have to be fixed up separately.
        for var in simpleVariables + argFunctions:
            if var in line:
                line = re.sub("\\b" + var + "\\b", "g." + var, line)
        for var in noArgFunctions:
            if var in line:
                line = re.sub("\\b" + var + "\\b", "g." + var + "()", line)
        for var in arrayVariables:
            if var in line:
                line = re.sub("\\b" + var + " *\\(([^)]+) *\)",  \
                              "g." + var + "[\\1]", \
                              line)
                
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
    
