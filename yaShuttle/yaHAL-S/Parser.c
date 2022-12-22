/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output, and Bison version.  */
#define YYBISON 30802

/* Bison version string.  */
#define YYBISON_VERSION "3.8.2"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1


/* Substitute the variable and function names.  */
#define yyparse         HAL_Sparse
#define yylex           HAL_Slex
#define yyerror         HAL_Serror
#define yydebug         HAL_Sdebug
#define yynerrs         HAL_Snerrs
#define yylval          HAL_Slval
#define yychar          HAL_Schar
#define yylloc          HAL_Slloc

/* First part of user prologue.  */
#line 3 "HAL_S.y"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "Absyn.h"
typedef struct HAL_S_buffer_state *YY_BUFFER_STATE;
YY_BUFFER_STATE HAL_S_scan_string(const char *str);
void HAL_S_delete_buffer(YY_BUFFER_STATE buf);
extern int yyparse(void);
extern int yylex(void);
extern int HAL_S_init_lexer(FILE * inp);
extern void yyerror(const char *str);

COMPILATION YY_RESULT_COMPILATION_ = 0;

COMPILATION pCOMPILATION(FILE *inp)
{
  HAL_S_init_lexer(inp);
  int result = yyparse();
  if (result)
  { /* Failure */
    return 0;
  }
  else
  { /* Success */
    return YY_RESULT_COMPILATION_;
  }
}
COMPILATION psCOMPILATION(const char *str)
{
  YY_BUFFER_STATE buf;
  HAL_S_init_lexer(0);
  buf = HAL_S_scan_string(str);
  int result = yyparse();
  HAL_S_delete_buffer(buf);
  if (result)
  { /* Failure */
    return 0;
  }
  else
  { /* Success */
    return YY_RESULT_COMPILATION_;
  }
}




#line 128 "Parser.c"

# ifndef YY_CAST
#  ifdef __cplusplus
#   define YY_CAST(Type, Val) static_cast<Type> (Val)
#   define YY_REINTERPRET_CAST(Type, Val) reinterpret_cast<Type> (Val)
#  else
#   define YY_CAST(Type, Val) ((Type) (Val))
#   define YY_REINTERPRET_CAST(Type, Val) ((Type) (Val))
#  endif
# endif
# ifndef YY_NULLPTR
#  if defined __cplusplus
#   if 201103L <= __cplusplus
#    define YY_NULLPTR nullptr
#   else
#    define YY_NULLPTR 0
#   endif
#  else
#   define YY_NULLPTR ((void*)0)
#  endif
# endif


/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int HAL_Sdebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    _ERROR_ = 258,                 /* _ERROR_  */
    _SYMB_0 = 259,                 /* _SYMB_0  */
    _SYMB_1 = 260,                 /* _SYMB_1  */
    _SYMB_2 = 261,                 /* _SYMB_2  */
    _SYMB_3 = 262,                 /* _SYMB_3  */
    _SYMB_4 = 263,                 /* _SYMB_4  */
    _SYMB_5 = 264,                 /* _SYMB_5  */
    _SYMB_6 = 265,                 /* _SYMB_6  */
    _SYMB_7 = 266,                 /* _SYMB_7  */
    _SYMB_8 = 267,                 /* _SYMB_8  */
    _SYMB_9 = 268,                 /* _SYMB_9  */
    _SYMB_10 = 269,                /* _SYMB_10  */
    _SYMB_11 = 270,                /* _SYMB_11  */
    _SYMB_12 = 271,                /* _SYMB_12  */
    _SYMB_13 = 272,                /* _SYMB_13  */
    _SYMB_14 = 273,                /* _SYMB_14  */
    _SYMB_15 = 274,                /* _SYMB_15  */
    _SYMB_16 = 275,                /* _SYMB_16  */
    _SYMB_17 = 276,                /* _SYMB_17  */
    _SYMB_18 = 277,                /* _SYMB_18  */
    _SYMB_19 = 278,                /* _SYMB_19  */
    _SYMB_20 = 279,                /* _SYMB_20  */
    _SYMB_21 = 280,                /* _SYMB_21  */
    _SYMB_22 = 281,                /* _SYMB_22  */
    _SYMB_23 = 282,                /* _SYMB_23  */
    _SYMB_24 = 283,                /* _SYMB_24  */
    _SYMB_25 = 284,                /* _SYMB_25  */
    _SYMB_26 = 285,                /* _SYMB_26  */
    _SYMB_27 = 286,                /* _SYMB_27  */
    _SYMB_28 = 287,                /* _SYMB_28  */
    _SYMB_29 = 288,                /* _SYMB_29  */
    _SYMB_30 = 289,                /* _SYMB_30  */
    _SYMB_31 = 290,                /* _SYMB_31  */
    _SYMB_32 = 291,                /* _SYMB_32  */
    _SYMB_33 = 292,                /* _SYMB_33  */
    _SYMB_34 = 293,                /* _SYMB_34  */
    _SYMB_35 = 294,                /* _SYMB_35  */
    _SYMB_36 = 295,                /* _SYMB_36  */
    _SYMB_37 = 296,                /* _SYMB_37  */
    _SYMB_38 = 297,                /* _SYMB_38  */
    _SYMB_39 = 298,                /* _SYMB_39  */
    _SYMB_40 = 299,                /* _SYMB_40  */
    _SYMB_41 = 300,                /* _SYMB_41  */
    _SYMB_42 = 301,                /* _SYMB_42  */
    _SYMB_43 = 302,                /* _SYMB_43  */
    _SYMB_44 = 303,                /* _SYMB_44  */
    _SYMB_45 = 304,                /* _SYMB_45  */
    _SYMB_46 = 305,                /* _SYMB_46  */
    _SYMB_47 = 306,                /* _SYMB_47  */
    _SYMB_48 = 307,                /* _SYMB_48  */
    _SYMB_49 = 308,                /* _SYMB_49  */
    _SYMB_50 = 309,                /* _SYMB_50  */
    _SYMB_51 = 310,                /* _SYMB_51  */
    _SYMB_52 = 311,                /* _SYMB_52  */
    _SYMB_53 = 312,                /* _SYMB_53  */
    _SYMB_54 = 313,                /* _SYMB_54  */
    _SYMB_55 = 314,                /* _SYMB_55  */
    _SYMB_56 = 315,                /* _SYMB_56  */
    _SYMB_57 = 316,                /* _SYMB_57  */
    _SYMB_58 = 317,                /* _SYMB_58  */
    _SYMB_59 = 318,                /* _SYMB_59  */
    _SYMB_60 = 319,                /* _SYMB_60  */
    _SYMB_61 = 320,                /* _SYMB_61  */
    _SYMB_62 = 321,                /* _SYMB_62  */
    _SYMB_63 = 322,                /* _SYMB_63  */
    _SYMB_64 = 323,                /* _SYMB_64  */
    _SYMB_65 = 324,                /* _SYMB_65  */
    _SYMB_66 = 325,                /* _SYMB_66  */
    _SYMB_67 = 326,                /* _SYMB_67  */
    _SYMB_68 = 327,                /* _SYMB_68  */
    _SYMB_69 = 328,                /* _SYMB_69  */
    _SYMB_70 = 329,                /* _SYMB_70  */
    _SYMB_71 = 330,                /* _SYMB_71  */
    _SYMB_72 = 331,                /* _SYMB_72  */
    _SYMB_73 = 332,                /* _SYMB_73  */
    _SYMB_74 = 333,                /* _SYMB_74  */
    _SYMB_75 = 334,                /* _SYMB_75  */
    _SYMB_76 = 335,                /* _SYMB_76  */
    _SYMB_77 = 336,                /* _SYMB_77  */
    _SYMB_78 = 337,                /* _SYMB_78  */
    _SYMB_79 = 338,                /* _SYMB_79  */
    _SYMB_80 = 339,                /* _SYMB_80  */
    _SYMB_81 = 340,                /* _SYMB_81  */
    _SYMB_82 = 341,                /* _SYMB_82  */
    _SYMB_83 = 342,                /* _SYMB_83  */
    _SYMB_84 = 343,                /* _SYMB_84  */
    _SYMB_85 = 344,                /* _SYMB_85  */
    _SYMB_86 = 345,                /* _SYMB_86  */
    _SYMB_87 = 346,                /* _SYMB_87  */
    _SYMB_88 = 347,                /* _SYMB_88  */
    _SYMB_89 = 348,                /* _SYMB_89  */
    _SYMB_90 = 349,                /* _SYMB_90  */
    _SYMB_91 = 350,                /* _SYMB_91  */
    _SYMB_92 = 351,                /* _SYMB_92  */
    _SYMB_93 = 352,                /* _SYMB_93  */
    _SYMB_94 = 353,                /* _SYMB_94  */
    _SYMB_95 = 354,                /* _SYMB_95  */
    _SYMB_96 = 355,                /* _SYMB_96  */
    _SYMB_97 = 356,                /* _SYMB_97  */
    _SYMB_98 = 357,                /* _SYMB_98  */
    _SYMB_99 = 358,                /* _SYMB_99  */
    _SYMB_100 = 359,               /* _SYMB_100  */
    _SYMB_101 = 360,               /* _SYMB_101  */
    _SYMB_102 = 361,               /* _SYMB_102  */
    _SYMB_103 = 362,               /* _SYMB_103  */
    _SYMB_104 = 363,               /* _SYMB_104  */
    _SYMB_105 = 364,               /* _SYMB_105  */
    _SYMB_106 = 365,               /* _SYMB_106  */
    _SYMB_107 = 366,               /* _SYMB_107  */
    _SYMB_108 = 367,               /* _SYMB_108  */
    _SYMB_109 = 368,               /* _SYMB_109  */
    _SYMB_110 = 369,               /* _SYMB_110  */
    _SYMB_111 = 370,               /* _SYMB_111  */
    _SYMB_112 = 371,               /* _SYMB_112  */
    _SYMB_113 = 372,               /* _SYMB_113  */
    _SYMB_114 = 373,               /* _SYMB_114  */
    _SYMB_115 = 374,               /* _SYMB_115  */
    _SYMB_116 = 375,               /* _SYMB_116  */
    _SYMB_117 = 376,               /* _SYMB_117  */
    _SYMB_118 = 377,               /* _SYMB_118  */
    _SYMB_119 = 378,               /* _SYMB_119  */
    _SYMB_120 = 379,               /* _SYMB_120  */
    _SYMB_121 = 380,               /* _SYMB_121  */
    _SYMB_122 = 381,               /* _SYMB_122  */
    _SYMB_123 = 382,               /* _SYMB_123  */
    _SYMB_124 = 383,               /* _SYMB_124  */
    _SYMB_125 = 384,               /* _SYMB_125  */
    _SYMB_126 = 385,               /* _SYMB_126  */
    _SYMB_127 = 386,               /* _SYMB_127  */
    _SYMB_128 = 387,               /* _SYMB_128  */
    _SYMB_129 = 388,               /* _SYMB_129  */
    _SYMB_130 = 389,               /* _SYMB_130  */
    _SYMB_131 = 390,               /* _SYMB_131  */
    _SYMB_132 = 391,               /* _SYMB_132  */
    _SYMB_133 = 392,               /* _SYMB_133  */
    _SYMB_134 = 393,               /* _SYMB_134  */
    _SYMB_135 = 394,               /* _SYMB_135  */
    _SYMB_136 = 395,               /* _SYMB_136  */
    _SYMB_137 = 396,               /* _SYMB_137  */
    _SYMB_138 = 397,               /* _SYMB_138  */
    _SYMB_139 = 398,               /* _SYMB_139  */
    _SYMB_140 = 399,               /* _SYMB_140  */
    _SYMB_141 = 400,               /* _SYMB_141  */
    _SYMB_142 = 401,               /* _SYMB_142  */
    _SYMB_143 = 402,               /* _SYMB_143  */
    _SYMB_144 = 403,               /* _SYMB_144  */
    _SYMB_145 = 404,               /* _SYMB_145  */
    _SYMB_146 = 405,               /* _SYMB_146  */
    _SYMB_147 = 406,               /* _SYMB_147  */
    _SYMB_148 = 407,               /* _SYMB_148  */
    _SYMB_149 = 408,               /* _SYMB_149  */
    _SYMB_150 = 409,               /* _SYMB_150  */
    _SYMB_151 = 410,               /* _SYMB_151  */
    _SYMB_152 = 411,               /* _SYMB_152  */
    _SYMB_153 = 412,               /* _SYMB_153  */
    _SYMB_154 = 413,               /* _SYMB_154  */
    _SYMB_155 = 414,               /* _SYMB_155  */
    _SYMB_156 = 415,               /* _SYMB_156  */
    _SYMB_157 = 416,               /* _SYMB_157  */
    _SYMB_158 = 417,               /* _SYMB_158  */
    _SYMB_159 = 418,               /* _SYMB_159  */
    _SYMB_160 = 419,               /* _SYMB_160  */
    _SYMB_161 = 420,               /* _SYMB_161  */
    _SYMB_162 = 421,               /* _SYMB_162  */
    _SYMB_163 = 422,               /* _SYMB_163  */
    _SYMB_164 = 423,               /* _SYMB_164  */
    _SYMB_165 = 424,               /* _SYMB_165  */
    _SYMB_166 = 425,               /* _SYMB_166  */
    _SYMB_167 = 426,               /* _SYMB_167  */
    _SYMB_168 = 427,               /* _SYMB_168  */
    _SYMB_169 = 428,               /* _SYMB_169  */
    _SYMB_170 = 429,               /* _SYMB_170  */
    _SYMB_171 = 430,               /* _SYMB_171  */
    _SYMB_172 = 431,               /* _SYMB_172  */
    _SYMB_173 = 432,               /* _SYMB_173  */
    _SYMB_174 = 433,               /* _SYMB_174  */
    _SYMB_175 = 434,               /* _SYMB_175  */
    _SYMB_176 = 435,               /* _SYMB_176  */
    _SYMB_177 = 436,               /* _SYMB_177  */
    _SYMB_178 = 437,               /* _SYMB_178  */
    _SYMB_179 = 438,               /* _SYMB_179  */
    _SYMB_180 = 439,               /* _SYMB_180  */
    _SYMB_181 = 440,               /* _SYMB_181  */
    _SYMB_182 = 441,               /* _SYMB_182  */
    _SYMB_183 = 442,               /* _SYMB_183  */
    _SYMB_184 = 443,               /* _SYMB_184  */
    _SYMB_185 = 444,               /* _SYMB_185  */
    _SYMB_186 = 445,               /* _SYMB_186  */
    _SYMB_187 = 446,               /* _SYMB_187  */
    _SYMB_188 = 447,               /* _SYMB_188  */
    _SYMB_189 = 448,               /* _SYMB_189  */
    _SYMB_190 = 449,               /* _SYMB_190  */
    _SYMB_191 = 450,               /* _SYMB_191  */
    _SYMB_192 = 451,               /* _SYMB_192  */
    _SYMB_193 = 452,               /* _SYMB_193  */
    _SYMB_194 = 453,               /* _SYMB_194  */
    _SYMB_195 = 454                /* _SYMB_195  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 53 "HAL_S.y"

  int int_;
  char char_;
  double double_;
  char* string_;
  DECLARE_BODY declare_body_;
  ATTRIBUTES attributes_;
  DECLARATION declaration_;
  ARRAY_SPEC array_spec_;
  TYPE_AND_MINOR_ATTR type_and_minor_attr_;
  IDENTIFIER identifier_;
  SQ_DQ_NAME sq_dq_name_;
  DOUBLY_QUAL_NAME_HEAD doubly_qual_name_head_;
  ARITH_CONV arith_conv_;
  DECLARATION_LIST declaration_list_;
  NAME_ID name_id_;
  ARITH_EXP arith_exp_;
  TERM term_;
  PLUS plus_;
  MINUS minus_;
  PRODUCT product_;
  FACTOR factor_;
  EXPONENTIATION exponentiation_;
  PRIMARY primary_;
  ARITH_VAR arith_var_;
  PRE_PRIMARY pre_primary_;
  NUMBER number_;
  LEVEL level_;
  COMPOUND_NUMBER compound_number_;
  SIMPLE_NUMBER simple_number_;
  MODIFIED_ARITH_FUNC modified_arith_func_;
  ARITH_FUNC_HEAD arith_func_head_;
  CALL_LIST call_list_;
  LIST_EXP list_exp_;
  EXPRESSION expression_;
  ARITH_ID arith_id_;
  NO_ARG_ARITH_FUNC no_arg_arith_func_;
  ARITH_FUNC arith_func_;
  SUBSCRIPT subscript_;
  QUALIFIER qualifier_;
  SCALE_HEAD scale_head_;
  PREC_SPEC prec_spec_;
  SUB_START sub_start_;
  SUB_HEAD sub_head_;
  SUB sub_;
  SUB_RUN_HEAD sub_run_head_;
  SUB_EXP sub_exp_;
  POUND_EXPRESSION pound_expression_;
  BIT_EXP bit_exp_;
  BIT_FACTOR bit_factor_;
  BIT_CAT bit_cat_;
  OR or_;
  CHAR_VERTICAL_BAR char_vertical_bar_;
  AND and_;
  BIT_PRIM bit_prim_;
  CAT cat_;
  NOT not_;
  BIT_VAR bit_var_;
  LABEL_VAR label_var_;
  EVENT_VAR event_var_;
  BIT_CONST_HEAD bit_const_head_;
  BIT_CONST bit_const_;
  RADIX radix_;
  CHAR_STRING char_string_;
  SUBBIT_HEAD subbit_head_;
  SUBBIT_KEY subbit_key_;
  BIT_FUNC_HEAD bit_func_head_;
  BIT_ID bit_id_;
  LABEL label_;
  BIT_FUNC bit_func_;
  EVENT event_;
  SUB_OR_QUALIFIER sub_or_qualifier_;
  BIT_QUALIFIER bit_qualifier_;
  CHAR_EXP char_exp_;
  CHAR_PRIM char_prim_;
  CHAR_FUNC_HEAD char_func_head_;
  CHAR_VAR char_var_;
  CHAR_CONST char_const_;
  CHAR_FUNC char_func_;
  CHAR_ID char_id_;
  NAME_EXP name_exp_;
  NAME_KEY name_key_;
  NAME_VAR name_var_;
  VARIABLE variable_;
  STRUCTURE_EXP structure_exp_;
  STRUCT_FUNC_HEAD struct_func_head_;
  STRUCTURE_VAR structure_var_;
  STRUCT_FUNC struct_func_;
  QUAL_STRUCT qual_struct_;
  STRUCTURE_ID structure_id_;
  ASSIGNMENT assignment_;
  EQUALS equals_;
  IF_STATEMENT if_statement_;
  IF_CLAUSE if_clause_;
  TRUE_PART true_part_;
  IF if_;
  THEN then_;
  RELATIONAL_EXP relational_exp_;
  RELATIONAL_FACTOR relational_factor_;
  REL_PRIM rel_prim_;
  COMPARISON comparison_;
  RELATIONAL_OP relational_op_;
  STATEMENT statement_;
  BASIC_STATEMENT basic_statement_;
  OTHER_STATEMENT other_statement_;
  ANY_STATEMENT any_statement_;
  ON_PHRASE on_phrase_;
  ON_CLAUSE on_clause_;
  LABEL_DEFINITION label_definition_;
  CALL_KEY call_key_;
  ASSIGN assign_;
  CALL_ASSIGN_LIST call_assign_list_;
  DO_GROUP_HEAD do_group_head_;
  ENDING ending_;
  READ_KEY read_key_;
  WRITE_KEY write_key_;
  READ_PHRASE read_phrase_;
  WRITE_PHRASE write_phrase_;
  READ_ARG read_arg_;
  WRITE_ARG write_arg_;
  FILE_EXP file_exp_;
  FILE_HEAD file_head_;
  IO_CONTROL io_control_;
  WAIT_KEY wait_key_;
  TERMINATOR terminator_;
  TERMINATE_LIST terminate_list_;
  SCHEDULE_HEAD schedule_head_;
  SCHEDULE_PHRASE schedule_phrase_;
  SCHEDULE_CONTROL schedule_control_;
  TIMING timing_;
  REPEAT repeat_;
  STOPPING stopping_;
  SIGNAL_CLAUSE signal_clause_;
  PERCENT_MACRO_NAME percent_macro_name_;
  PERCENT_MACRO_HEAD percent_macro_head_;
  PERCENT_MACRO_ARG percent_macro_arg_;
  CASE_ELSE case_else_;
  WHILE_KEY while_key_;
  WHILE_CLAUSE while_clause_;
  FOR_LIST for_list_;
  ITERATION_BODY iteration_body_;
  ITERATION_CONTROL iteration_control_;
  FOR_KEY for_key_;
  TEMPORARY_STMT temporary_stmt_;
  CONSTANT constant_;
  ARRAY_HEAD array_head_;
  MINOR_ATTR_LIST minor_attr_list_;
  MINOR_ATTRIBUTE minor_attribute_;
  INIT_OR_CONST_HEAD init_or_const_head_;
  REPEATED_CONSTANT repeated_constant_;
  REPEAT_HEAD repeat_head_;
  NESTED_REPEAT_HEAD nested_repeat_head_;
  DCL_LIST_COMMA dcl_list_comma_;
  LITERAL_EXP_OR_STAR literal_exp_or_star_;
  TYPE_SPEC type_spec_;
  BIT_SPEC bit_spec_;
  CHAR_SPEC char_spec_;
  STRUCT_SPEC struct_spec_;
  STRUCT_SPEC_BODY struct_spec_body_;
  STRUCT_TEMPLATE struct_template_;
  STRUCT_SPEC_HEAD struct_spec_head_;
  ARITH_SPEC arith_spec_;
  COMPILATION compilation_;
  BLOCK_DEFINITION block_definition_;
  BLOCK_STMT block_stmt_;
  BLOCK_STMT_TOP block_stmt_top_;
  BLOCK_STMT_HEAD block_stmt_head_;
  LABEL_EXTERNAL label_external_;
  CLOSING closing_;
  BLOCK_BODY block_body_;
  FUNCTION_NAME function_name_;
  PROCEDURE_NAME procedure_name_;
  FUNC_STMT_BODY func_stmt_body_;
  PROC_STMT_BODY proc_stmt_body_;
  DECLARE_GROUP declare_group_;
  DECLARE_ELEMENT declare_element_;
  PARAMETER parameter_;
  PARAMETER_LIST parameter_list_;
  PARAMETER_HEAD parameter_head_;
  DECLARE_STATEMENT declare_statement_;
  ASSIGN_LIST assign_list_;
  TEXT text_;
  REPLACE_STMT replace_stmt_;
  REPLACE_HEAD replace_head_;
  ARG_LIST arg_list_;
  STRUCTURE_STMT structure_stmt_;
  STRUCT_STMT_HEAD struct_stmt_head_;
  STRUCT_STMT_TAIL struct_stmt_tail_;
  INLINE_DEFINITION inline_definition_;
  ARITH_INLINE arith_inline_;
  ARITH_INLINE_DEF arith_inline_def_;
  BIT_INLINE bit_inline_;
  BIT_INLINE_DEF bit_inline_def_;
  CHAR_INLINE char_inline_;
  CHAR_INLINE_DEF char_inline_def_;
  STRUC_INLINE_DEF struc_inline_def_;


#line 573 "Parser.c"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif

/* Location type.  */
#if ! defined YYLTYPE && ! defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE YYLTYPE;
struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
};
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif


extern YYSTYPE HAL_Slval;
extern YYLTYPE HAL_Slloc;

int HAL_Sparse (void);



/* Symbol kind.  */
enum yysymbol_kind_t
{
  YYSYMBOL_YYEMPTY = -2,
  YYSYMBOL_YYEOF = 0,                      /* "end of file"  */
  YYSYMBOL_YYerror = 1,                    /* error  */
  YYSYMBOL_YYUNDEF = 2,                    /* "invalid token"  */
  YYSYMBOL__ERROR_ = 3,                    /* _ERROR_  */
  YYSYMBOL__SYMB_0 = 4,                    /* _SYMB_0  */
  YYSYMBOL__SYMB_1 = 5,                    /* _SYMB_1  */
  YYSYMBOL__SYMB_2 = 6,                    /* _SYMB_2  */
  YYSYMBOL__SYMB_3 = 7,                    /* _SYMB_3  */
  YYSYMBOL__SYMB_4 = 8,                    /* _SYMB_4  */
  YYSYMBOL__SYMB_5 = 9,                    /* _SYMB_5  */
  YYSYMBOL__SYMB_6 = 10,                   /* _SYMB_6  */
  YYSYMBOL__SYMB_7 = 11,                   /* _SYMB_7  */
  YYSYMBOL__SYMB_8 = 12,                   /* _SYMB_8  */
  YYSYMBOL__SYMB_9 = 13,                   /* _SYMB_9  */
  YYSYMBOL__SYMB_10 = 14,                  /* _SYMB_10  */
  YYSYMBOL__SYMB_11 = 15,                  /* _SYMB_11  */
  YYSYMBOL__SYMB_12 = 16,                  /* _SYMB_12  */
  YYSYMBOL__SYMB_13 = 17,                  /* _SYMB_13  */
  YYSYMBOL__SYMB_14 = 18,                  /* _SYMB_14  */
  YYSYMBOL__SYMB_15 = 19,                  /* _SYMB_15  */
  YYSYMBOL__SYMB_16 = 20,                  /* _SYMB_16  */
  YYSYMBOL__SYMB_17 = 21,                  /* _SYMB_17  */
  YYSYMBOL__SYMB_18 = 22,                  /* _SYMB_18  */
  YYSYMBOL__SYMB_19 = 23,                  /* _SYMB_19  */
  YYSYMBOL__SYMB_20 = 24,                  /* _SYMB_20  */
  YYSYMBOL__SYMB_21 = 25,                  /* _SYMB_21  */
  YYSYMBOL__SYMB_22 = 26,                  /* _SYMB_22  */
  YYSYMBOL__SYMB_23 = 27,                  /* _SYMB_23  */
  YYSYMBOL__SYMB_24 = 28,                  /* _SYMB_24  */
  YYSYMBOL__SYMB_25 = 29,                  /* _SYMB_25  */
  YYSYMBOL__SYMB_26 = 30,                  /* _SYMB_26  */
  YYSYMBOL__SYMB_27 = 31,                  /* _SYMB_27  */
  YYSYMBOL__SYMB_28 = 32,                  /* _SYMB_28  */
  YYSYMBOL__SYMB_29 = 33,                  /* _SYMB_29  */
  YYSYMBOL__SYMB_30 = 34,                  /* _SYMB_30  */
  YYSYMBOL__SYMB_31 = 35,                  /* _SYMB_31  */
  YYSYMBOL__SYMB_32 = 36,                  /* _SYMB_32  */
  YYSYMBOL__SYMB_33 = 37,                  /* _SYMB_33  */
  YYSYMBOL__SYMB_34 = 38,                  /* _SYMB_34  */
  YYSYMBOL__SYMB_35 = 39,                  /* _SYMB_35  */
  YYSYMBOL__SYMB_36 = 40,                  /* _SYMB_36  */
  YYSYMBOL__SYMB_37 = 41,                  /* _SYMB_37  */
  YYSYMBOL__SYMB_38 = 42,                  /* _SYMB_38  */
  YYSYMBOL__SYMB_39 = 43,                  /* _SYMB_39  */
  YYSYMBOL__SYMB_40 = 44,                  /* _SYMB_40  */
  YYSYMBOL__SYMB_41 = 45,                  /* _SYMB_41  */
  YYSYMBOL__SYMB_42 = 46,                  /* _SYMB_42  */
  YYSYMBOL__SYMB_43 = 47,                  /* _SYMB_43  */
  YYSYMBOL__SYMB_44 = 48,                  /* _SYMB_44  */
  YYSYMBOL__SYMB_45 = 49,                  /* _SYMB_45  */
  YYSYMBOL__SYMB_46 = 50,                  /* _SYMB_46  */
  YYSYMBOL__SYMB_47 = 51,                  /* _SYMB_47  */
  YYSYMBOL__SYMB_48 = 52,                  /* _SYMB_48  */
  YYSYMBOL__SYMB_49 = 53,                  /* _SYMB_49  */
  YYSYMBOL__SYMB_50 = 54,                  /* _SYMB_50  */
  YYSYMBOL__SYMB_51 = 55,                  /* _SYMB_51  */
  YYSYMBOL__SYMB_52 = 56,                  /* _SYMB_52  */
  YYSYMBOL__SYMB_53 = 57,                  /* _SYMB_53  */
  YYSYMBOL__SYMB_54 = 58,                  /* _SYMB_54  */
  YYSYMBOL__SYMB_55 = 59,                  /* _SYMB_55  */
  YYSYMBOL__SYMB_56 = 60,                  /* _SYMB_56  */
  YYSYMBOL__SYMB_57 = 61,                  /* _SYMB_57  */
  YYSYMBOL__SYMB_58 = 62,                  /* _SYMB_58  */
  YYSYMBOL__SYMB_59 = 63,                  /* _SYMB_59  */
  YYSYMBOL__SYMB_60 = 64,                  /* _SYMB_60  */
  YYSYMBOL__SYMB_61 = 65,                  /* _SYMB_61  */
  YYSYMBOL__SYMB_62 = 66,                  /* _SYMB_62  */
  YYSYMBOL__SYMB_63 = 67,                  /* _SYMB_63  */
  YYSYMBOL__SYMB_64 = 68,                  /* _SYMB_64  */
  YYSYMBOL__SYMB_65 = 69,                  /* _SYMB_65  */
  YYSYMBOL__SYMB_66 = 70,                  /* _SYMB_66  */
  YYSYMBOL__SYMB_67 = 71,                  /* _SYMB_67  */
  YYSYMBOL__SYMB_68 = 72,                  /* _SYMB_68  */
  YYSYMBOL__SYMB_69 = 73,                  /* _SYMB_69  */
  YYSYMBOL__SYMB_70 = 74,                  /* _SYMB_70  */
  YYSYMBOL__SYMB_71 = 75,                  /* _SYMB_71  */
  YYSYMBOL__SYMB_72 = 76,                  /* _SYMB_72  */
  YYSYMBOL__SYMB_73 = 77,                  /* _SYMB_73  */
  YYSYMBOL__SYMB_74 = 78,                  /* _SYMB_74  */
  YYSYMBOL__SYMB_75 = 79,                  /* _SYMB_75  */
  YYSYMBOL__SYMB_76 = 80,                  /* _SYMB_76  */
  YYSYMBOL__SYMB_77 = 81,                  /* _SYMB_77  */
  YYSYMBOL__SYMB_78 = 82,                  /* _SYMB_78  */
  YYSYMBOL__SYMB_79 = 83,                  /* _SYMB_79  */
  YYSYMBOL__SYMB_80 = 84,                  /* _SYMB_80  */
  YYSYMBOL__SYMB_81 = 85,                  /* _SYMB_81  */
  YYSYMBOL__SYMB_82 = 86,                  /* _SYMB_82  */
  YYSYMBOL__SYMB_83 = 87,                  /* _SYMB_83  */
  YYSYMBOL__SYMB_84 = 88,                  /* _SYMB_84  */
  YYSYMBOL__SYMB_85 = 89,                  /* _SYMB_85  */
  YYSYMBOL__SYMB_86 = 90,                  /* _SYMB_86  */
  YYSYMBOL__SYMB_87 = 91,                  /* _SYMB_87  */
  YYSYMBOL__SYMB_88 = 92,                  /* _SYMB_88  */
  YYSYMBOL__SYMB_89 = 93,                  /* _SYMB_89  */
  YYSYMBOL__SYMB_90 = 94,                  /* _SYMB_90  */
  YYSYMBOL__SYMB_91 = 95,                  /* _SYMB_91  */
  YYSYMBOL__SYMB_92 = 96,                  /* _SYMB_92  */
  YYSYMBOL__SYMB_93 = 97,                  /* _SYMB_93  */
  YYSYMBOL__SYMB_94 = 98,                  /* _SYMB_94  */
  YYSYMBOL__SYMB_95 = 99,                  /* _SYMB_95  */
  YYSYMBOL__SYMB_96 = 100,                 /* _SYMB_96  */
  YYSYMBOL__SYMB_97 = 101,                 /* _SYMB_97  */
  YYSYMBOL__SYMB_98 = 102,                 /* _SYMB_98  */
  YYSYMBOL__SYMB_99 = 103,                 /* _SYMB_99  */
  YYSYMBOL__SYMB_100 = 104,                /* _SYMB_100  */
  YYSYMBOL__SYMB_101 = 105,                /* _SYMB_101  */
  YYSYMBOL__SYMB_102 = 106,                /* _SYMB_102  */
  YYSYMBOL__SYMB_103 = 107,                /* _SYMB_103  */
  YYSYMBOL__SYMB_104 = 108,                /* _SYMB_104  */
  YYSYMBOL__SYMB_105 = 109,                /* _SYMB_105  */
  YYSYMBOL__SYMB_106 = 110,                /* _SYMB_106  */
  YYSYMBOL__SYMB_107 = 111,                /* _SYMB_107  */
  YYSYMBOL__SYMB_108 = 112,                /* _SYMB_108  */
  YYSYMBOL__SYMB_109 = 113,                /* _SYMB_109  */
  YYSYMBOL__SYMB_110 = 114,                /* _SYMB_110  */
  YYSYMBOL__SYMB_111 = 115,                /* _SYMB_111  */
  YYSYMBOL__SYMB_112 = 116,                /* _SYMB_112  */
  YYSYMBOL__SYMB_113 = 117,                /* _SYMB_113  */
  YYSYMBOL__SYMB_114 = 118,                /* _SYMB_114  */
  YYSYMBOL__SYMB_115 = 119,                /* _SYMB_115  */
  YYSYMBOL__SYMB_116 = 120,                /* _SYMB_116  */
  YYSYMBOL__SYMB_117 = 121,                /* _SYMB_117  */
  YYSYMBOL__SYMB_118 = 122,                /* _SYMB_118  */
  YYSYMBOL__SYMB_119 = 123,                /* _SYMB_119  */
  YYSYMBOL__SYMB_120 = 124,                /* _SYMB_120  */
  YYSYMBOL__SYMB_121 = 125,                /* _SYMB_121  */
  YYSYMBOL__SYMB_122 = 126,                /* _SYMB_122  */
  YYSYMBOL__SYMB_123 = 127,                /* _SYMB_123  */
  YYSYMBOL__SYMB_124 = 128,                /* _SYMB_124  */
  YYSYMBOL__SYMB_125 = 129,                /* _SYMB_125  */
  YYSYMBOL__SYMB_126 = 130,                /* _SYMB_126  */
  YYSYMBOL__SYMB_127 = 131,                /* _SYMB_127  */
  YYSYMBOL__SYMB_128 = 132,                /* _SYMB_128  */
  YYSYMBOL__SYMB_129 = 133,                /* _SYMB_129  */
  YYSYMBOL__SYMB_130 = 134,                /* _SYMB_130  */
  YYSYMBOL__SYMB_131 = 135,                /* _SYMB_131  */
  YYSYMBOL__SYMB_132 = 136,                /* _SYMB_132  */
  YYSYMBOL__SYMB_133 = 137,                /* _SYMB_133  */
  YYSYMBOL__SYMB_134 = 138,                /* _SYMB_134  */
  YYSYMBOL__SYMB_135 = 139,                /* _SYMB_135  */
  YYSYMBOL__SYMB_136 = 140,                /* _SYMB_136  */
  YYSYMBOL__SYMB_137 = 141,                /* _SYMB_137  */
  YYSYMBOL__SYMB_138 = 142,                /* _SYMB_138  */
  YYSYMBOL__SYMB_139 = 143,                /* _SYMB_139  */
  YYSYMBOL__SYMB_140 = 144,                /* _SYMB_140  */
  YYSYMBOL__SYMB_141 = 145,                /* _SYMB_141  */
  YYSYMBOL__SYMB_142 = 146,                /* _SYMB_142  */
  YYSYMBOL__SYMB_143 = 147,                /* _SYMB_143  */
  YYSYMBOL__SYMB_144 = 148,                /* _SYMB_144  */
  YYSYMBOL__SYMB_145 = 149,                /* _SYMB_145  */
  YYSYMBOL__SYMB_146 = 150,                /* _SYMB_146  */
  YYSYMBOL__SYMB_147 = 151,                /* _SYMB_147  */
  YYSYMBOL__SYMB_148 = 152,                /* _SYMB_148  */
  YYSYMBOL__SYMB_149 = 153,                /* _SYMB_149  */
  YYSYMBOL__SYMB_150 = 154,                /* _SYMB_150  */
  YYSYMBOL__SYMB_151 = 155,                /* _SYMB_151  */
  YYSYMBOL__SYMB_152 = 156,                /* _SYMB_152  */
  YYSYMBOL__SYMB_153 = 157,                /* _SYMB_153  */
  YYSYMBOL__SYMB_154 = 158,                /* _SYMB_154  */
  YYSYMBOL__SYMB_155 = 159,                /* _SYMB_155  */
  YYSYMBOL__SYMB_156 = 160,                /* _SYMB_156  */
  YYSYMBOL__SYMB_157 = 161,                /* _SYMB_157  */
  YYSYMBOL__SYMB_158 = 162,                /* _SYMB_158  */
  YYSYMBOL__SYMB_159 = 163,                /* _SYMB_159  */
  YYSYMBOL__SYMB_160 = 164,                /* _SYMB_160  */
  YYSYMBOL__SYMB_161 = 165,                /* _SYMB_161  */
  YYSYMBOL__SYMB_162 = 166,                /* _SYMB_162  */
  YYSYMBOL__SYMB_163 = 167,                /* _SYMB_163  */
  YYSYMBOL__SYMB_164 = 168,                /* _SYMB_164  */
  YYSYMBOL__SYMB_165 = 169,                /* _SYMB_165  */
  YYSYMBOL__SYMB_166 = 170,                /* _SYMB_166  */
  YYSYMBOL__SYMB_167 = 171,                /* _SYMB_167  */
  YYSYMBOL__SYMB_168 = 172,                /* _SYMB_168  */
  YYSYMBOL__SYMB_169 = 173,                /* _SYMB_169  */
  YYSYMBOL__SYMB_170 = 174,                /* _SYMB_170  */
  YYSYMBOL__SYMB_171 = 175,                /* _SYMB_171  */
  YYSYMBOL__SYMB_172 = 176,                /* _SYMB_172  */
  YYSYMBOL__SYMB_173 = 177,                /* _SYMB_173  */
  YYSYMBOL__SYMB_174 = 178,                /* _SYMB_174  */
  YYSYMBOL__SYMB_175 = 179,                /* _SYMB_175  */
  YYSYMBOL__SYMB_176 = 180,                /* _SYMB_176  */
  YYSYMBOL__SYMB_177 = 181,                /* _SYMB_177  */
  YYSYMBOL__SYMB_178 = 182,                /* _SYMB_178  */
  YYSYMBOL__SYMB_179 = 183,                /* _SYMB_179  */
  YYSYMBOL__SYMB_180 = 184,                /* _SYMB_180  */
  YYSYMBOL__SYMB_181 = 185,                /* _SYMB_181  */
  YYSYMBOL__SYMB_182 = 186,                /* _SYMB_182  */
  YYSYMBOL__SYMB_183 = 187,                /* _SYMB_183  */
  YYSYMBOL__SYMB_184 = 188,                /* _SYMB_184  */
  YYSYMBOL__SYMB_185 = 189,                /* _SYMB_185  */
  YYSYMBOL__SYMB_186 = 190,                /* _SYMB_186  */
  YYSYMBOL__SYMB_187 = 191,                /* _SYMB_187  */
  YYSYMBOL__SYMB_188 = 192,                /* _SYMB_188  */
  YYSYMBOL__SYMB_189 = 193,                /* _SYMB_189  */
  YYSYMBOL__SYMB_190 = 194,                /* _SYMB_190  */
  YYSYMBOL__SYMB_191 = 195,                /* _SYMB_191  */
  YYSYMBOL__SYMB_192 = 196,                /* _SYMB_192  */
  YYSYMBOL__SYMB_193 = 197,                /* _SYMB_193  */
  YYSYMBOL__SYMB_194 = 198,                /* _SYMB_194  */
  YYSYMBOL__SYMB_195 = 199,                /* _SYMB_195  */
  YYSYMBOL_YYACCEPT = 200,                 /* $accept  */
  YYSYMBOL_DECLARE_BODY = 201,             /* DECLARE_BODY  */
  YYSYMBOL_ATTRIBUTES = 202,               /* ATTRIBUTES  */
  YYSYMBOL_DECLARATION = 203,              /* DECLARATION  */
  YYSYMBOL_ARRAY_SPEC = 204,               /* ARRAY_SPEC  */
  YYSYMBOL_TYPE_AND_MINOR_ATTR = 205,      /* TYPE_AND_MINOR_ATTR  */
  YYSYMBOL_IDENTIFIER = 206,               /* IDENTIFIER  */
  YYSYMBOL_SQ_DQ_NAME = 207,               /* SQ_DQ_NAME  */
  YYSYMBOL_DOUBLY_QUAL_NAME_HEAD = 208,    /* DOUBLY_QUAL_NAME_HEAD  */
  YYSYMBOL_ARITH_CONV = 209,               /* ARITH_CONV  */
  YYSYMBOL_DECLARATION_LIST = 210,         /* DECLARATION_LIST  */
  YYSYMBOL_NAME_ID = 211,                  /* NAME_ID  */
  YYSYMBOL_ARITH_EXP = 212,                /* ARITH_EXP  */
  YYSYMBOL_TERM = 213,                     /* TERM  */
  YYSYMBOL_PLUS = 214,                     /* PLUS  */
  YYSYMBOL_MINUS = 215,                    /* MINUS  */
  YYSYMBOL_PRODUCT = 216,                  /* PRODUCT  */
  YYSYMBOL_FACTOR = 217,                   /* FACTOR  */
  YYSYMBOL_EXPONENTIATION = 218,           /* EXPONENTIATION  */
  YYSYMBOL_PRIMARY = 219,                  /* PRIMARY  */
  YYSYMBOL_ARITH_VAR = 220,                /* ARITH_VAR  */
  YYSYMBOL_PRE_PRIMARY = 221,              /* PRE_PRIMARY  */
  YYSYMBOL_NUMBER = 222,                   /* NUMBER  */
  YYSYMBOL_LEVEL = 223,                    /* LEVEL  */
  YYSYMBOL_COMPOUND_NUMBER = 224,          /* COMPOUND_NUMBER  */
  YYSYMBOL_SIMPLE_NUMBER = 225,            /* SIMPLE_NUMBER  */
  YYSYMBOL_MODIFIED_ARITH_FUNC = 226,      /* MODIFIED_ARITH_FUNC  */
  YYSYMBOL_ARITH_FUNC_HEAD = 227,          /* ARITH_FUNC_HEAD  */
  YYSYMBOL_CALL_LIST = 228,                /* CALL_LIST  */
  YYSYMBOL_LIST_EXP = 229,                 /* LIST_EXP  */
  YYSYMBOL_EXPRESSION = 230,               /* EXPRESSION  */
  YYSYMBOL_ARITH_ID = 231,                 /* ARITH_ID  */
  YYSYMBOL_NO_ARG_ARITH_FUNC = 232,        /* NO_ARG_ARITH_FUNC  */
  YYSYMBOL_ARITH_FUNC = 233,               /* ARITH_FUNC  */
  YYSYMBOL_SUBSCRIPT = 234,                /* SUBSCRIPT  */
  YYSYMBOL_QUALIFIER = 235,                /* QUALIFIER  */
  YYSYMBOL_SCALE_HEAD = 236,               /* SCALE_HEAD  */
  YYSYMBOL_PREC_SPEC = 237,                /* PREC_SPEC  */
  YYSYMBOL_SUB_START = 238,                /* SUB_START  */
  YYSYMBOL_SUB_HEAD = 239,                 /* SUB_HEAD  */
  YYSYMBOL_SUB = 240,                      /* SUB  */
  YYSYMBOL_SUB_RUN_HEAD = 241,             /* SUB_RUN_HEAD  */
  YYSYMBOL_SUB_EXP = 242,                  /* SUB_EXP  */
  YYSYMBOL_POUND_EXPRESSION = 243,         /* POUND_EXPRESSION  */
  YYSYMBOL_BIT_EXP = 244,                  /* BIT_EXP  */
  YYSYMBOL_BIT_FACTOR = 245,               /* BIT_FACTOR  */
  YYSYMBOL_BIT_CAT = 246,                  /* BIT_CAT  */
  YYSYMBOL_OR = 247,                       /* OR  */
  YYSYMBOL_CHAR_VERTICAL_BAR = 248,        /* CHAR_VERTICAL_BAR  */
  YYSYMBOL_AND = 249,                      /* AND  */
  YYSYMBOL_BIT_PRIM = 250,                 /* BIT_PRIM  */
  YYSYMBOL_CAT = 251,                      /* CAT  */
  YYSYMBOL_NOT = 252,                      /* NOT  */
  YYSYMBOL_BIT_VAR = 253,                  /* BIT_VAR  */
  YYSYMBOL_LABEL_VAR = 254,                /* LABEL_VAR  */
  YYSYMBOL_EVENT_VAR = 255,                /* EVENT_VAR  */
  YYSYMBOL_BIT_CONST_HEAD = 256,           /* BIT_CONST_HEAD  */
  YYSYMBOL_BIT_CONST = 257,                /* BIT_CONST  */
  YYSYMBOL_RADIX = 258,                    /* RADIX  */
  YYSYMBOL_CHAR_STRING = 259,              /* CHAR_STRING  */
  YYSYMBOL_SUBBIT_HEAD = 260,              /* SUBBIT_HEAD  */
  YYSYMBOL_SUBBIT_KEY = 261,               /* SUBBIT_KEY  */
  YYSYMBOL_BIT_FUNC_HEAD = 262,            /* BIT_FUNC_HEAD  */
  YYSYMBOL_BIT_ID = 263,                   /* BIT_ID  */
  YYSYMBOL_LABEL = 264,                    /* LABEL  */
  YYSYMBOL_BIT_FUNC = 265,                 /* BIT_FUNC  */
  YYSYMBOL_EVENT = 266,                    /* EVENT  */
  YYSYMBOL_SUB_OR_QUALIFIER = 267,         /* SUB_OR_QUALIFIER  */
  YYSYMBOL_BIT_QUALIFIER = 268,            /* BIT_QUALIFIER  */
  YYSYMBOL_CHAR_EXP = 269,                 /* CHAR_EXP  */
  YYSYMBOL_CHAR_PRIM = 270,                /* CHAR_PRIM  */
  YYSYMBOL_CHAR_FUNC_HEAD = 271,           /* CHAR_FUNC_HEAD  */
  YYSYMBOL_CHAR_VAR = 272,                 /* CHAR_VAR  */
  YYSYMBOL_CHAR_CONST = 273,               /* CHAR_CONST  */
  YYSYMBOL_CHAR_FUNC = 274,                /* CHAR_FUNC  */
  YYSYMBOL_CHAR_ID = 275,                  /* CHAR_ID  */
  YYSYMBOL_NAME_EXP = 276,                 /* NAME_EXP  */
  YYSYMBOL_NAME_KEY = 277,                 /* NAME_KEY  */
  YYSYMBOL_NAME_VAR = 278,                 /* NAME_VAR  */
  YYSYMBOL_VARIABLE = 279,                 /* VARIABLE  */
  YYSYMBOL_STRUCTURE_EXP = 280,            /* STRUCTURE_EXP  */
  YYSYMBOL_STRUCT_FUNC_HEAD = 281,         /* STRUCT_FUNC_HEAD  */
  YYSYMBOL_STRUCTURE_VAR = 282,            /* STRUCTURE_VAR  */
  YYSYMBOL_STRUCT_FUNC = 283,              /* STRUCT_FUNC  */
  YYSYMBOL_QUAL_STRUCT = 284,              /* QUAL_STRUCT  */
  YYSYMBOL_STRUCTURE_ID = 285,             /* STRUCTURE_ID  */
  YYSYMBOL_ASSIGNMENT = 286,               /* ASSIGNMENT  */
  YYSYMBOL_EQUALS = 287,                   /* EQUALS  */
  YYSYMBOL_IF_STATEMENT = 288,             /* IF_STATEMENT  */
  YYSYMBOL_IF_CLAUSE = 289,                /* IF_CLAUSE  */
  YYSYMBOL_TRUE_PART = 290,                /* TRUE_PART  */
  YYSYMBOL_IF = 291,                       /* IF  */
  YYSYMBOL_THEN = 292,                     /* THEN  */
  YYSYMBOL_RELATIONAL_EXP = 293,           /* RELATIONAL_EXP  */
  YYSYMBOL_RELATIONAL_FACTOR = 294,        /* RELATIONAL_FACTOR  */
  YYSYMBOL_REL_PRIM = 295,                 /* REL_PRIM  */
  YYSYMBOL_COMPARISON = 296,               /* COMPARISON  */
  YYSYMBOL_RELATIONAL_OP = 297,            /* RELATIONAL_OP  */
  YYSYMBOL_STATEMENT = 298,                /* STATEMENT  */
  YYSYMBOL_BASIC_STATEMENT = 299,          /* BASIC_STATEMENT  */
  YYSYMBOL_OTHER_STATEMENT = 300,          /* OTHER_STATEMENT  */
  YYSYMBOL_ANY_STATEMENT = 301,            /* ANY_STATEMENT  */
  YYSYMBOL_ON_PHRASE = 302,                /* ON_PHRASE  */
  YYSYMBOL_ON_CLAUSE = 303,                /* ON_CLAUSE  */
  YYSYMBOL_LABEL_DEFINITION = 304,         /* LABEL_DEFINITION  */
  YYSYMBOL_CALL_KEY = 305,                 /* CALL_KEY  */
  YYSYMBOL_ASSIGN = 306,                   /* ASSIGN  */
  YYSYMBOL_CALL_ASSIGN_LIST = 307,         /* CALL_ASSIGN_LIST  */
  YYSYMBOL_DO_GROUP_HEAD = 308,            /* DO_GROUP_HEAD  */
  YYSYMBOL_ENDING = 309,                   /* ENDING  */
  YYSYMBOL_READ_KEY = 310,                 /* READ_KEY  */
  YYSYMBOL_WRITE_KEY = 311,                /* WRITE_KEY  */
  YYSYMBOL_READ_PHRASE = 312,              /* READ_PHRASE  */
  YYSYMBOL_WRITE_PHRASE = 313,             /* WRITE_PHRASE  */
  YYSYMBOL_READ_ARG = 314,                 /* READ_ARG  */
  YYSYMBOL_WRITE_ARG = 315,                /* WRITE_ARG  */
  YYSYMBOL_FILE_EXP = 316,                 /* FILE_EXP  */
  YYSYMBOL_FILE_HEAD = 317,                /* FILE_HEAD  */
  YYSYMBOL_IO_CONTROL = 318,               /* IO_CONTROL  */
  YYSYMBOL_WAIT_KEY = 319,                 /* WAIT_KEY  */
  YYSYMBOL_TERMINATOR = 320,               /* TERMINATOR  */
  YYSYMBOL_TERMINATE_LIST = 321,           /* TERMINATE_LIST  */
  YYSYMBOL_SCHEDULE_HEAD = 322,            /* SCHEDULE_HEAD  */
  YYSYMBOL_SCHEDULE_PHRASE = 323,          /* SCHEDULE_PHRASE  */
  YYSYMBOL_SCHEDULE_CONTROL = 324,         /* SCHEDULE_CONTROL  */
  YYSYMBOL_TIMING = 325,                   /* TIMING  */
  YYSYMBOL_REPEAT = 326,                   /* REPEAT  */
  YYSYMBOL_STOPPING = 327,                 /* STOPPING  */
  YYSYMBOL_SIGNAL_CLAUSE = 328,            /* SIGNAL_CLAUSE  */
  YYSYMBOL_PERCENT_MACRO_NAME = 329,       /* PERCENT_MACRO_NAME  */
  YYSYMBOL_PERCENT_MACRO_HEAD = 330,       /* PERCENT_MACRO_HEAD  */
  YYSYMBOL_PERCENT_MACRO_ARG = 331,        /* PERCENT_MACRO_ARG  */
  YYSYMBOL_CASE_ELSE = 332,                /* CASE_ELSE  */
  YYSYMBOL_WHILE_KEY = 333,                /* WHILE_KEY  */
  YYSYMBOL_WHILE_CLAUSE = 334,             /* WHILE_CLAUSE  */
  YYSYMBOL_FOR_LIST = 335,                 /* FOR_LIST  */
  YYSYMBOL_ITERATION_BODY = 336,           /* ITERATION_BODY  */
  YYSYMBOL_ITERATION_CONTROL = 337,        /* ITERATION_CONTROL  */
  YYSYMBOL_FOR_KEY = 338,                  /* FOR_KEY  */
  YYSYMBOL_TEMPORARY_STMT = 339,           /* TEMPORARY_STMT  */
  YYSYMBOL_CONSTANT = 340,                 /* CONSTANT  */
  YYSYMBOL_ARRAY_HEAD = 341,               /* ARRAY_HEAD  */
  YYSYMBOL_MINOR_ATTR_LIST = 342,          /* MINOR_ATTR_LIST  */
  YYSYMBOL_MINOR_ATTRIBUTE = 343,          /* MINOR_ATTRIBUTE  */
  YYSYMBOL_INIT_OR_CONST_HEAD = 344,       /* INIT_OR_CONST_HEAD  */
  YYSYMBOL_REPEATED_CONSTANT = 345,        /* REPEATED_CONSTANT  */
  YYSYMBOL_REPEAT_HEAD = 346,              /* REPEAT_HEAD  */
  YYSYMBOL_NESTED_REPEAT_HEAD = 347,       /* NESTED_REPEAT_HEAD  */
  YYSYMBOL_DCL_LIST_COMMA = 348,           /* DCL_LIST_COMMA  */
  YYSYMBOL_LITERAL_EXP_OR_STAR = 349,      /* LITERAL_EXP_OR_STAR  */
  YYSYMBOL_TYPE_SPEC = 350,                /* TYPE_SPEC  */
  YYSYMBOL_BIT_SPEC = 351,                 /* BIT_SPEC  */
  YYSYMBOL_CHAR_SPEC = 352,                /* CHAR_SPEC  */
  YYSYMBOL_STRUCT_SPEC = 353,              /* STRUCT_SPEC  */
  YYSYMBOL_STRUCT_SPEC_BODY = 354,         /* STRUCT_SPEC_BODY  */
  YYSYMBOL_STRUCT_TEMPLATE = 355,          /* STRUCT_TEMPLATE  */
  YYSYMBOL_STRUCT_SPEC_HEAD = 356,         /* STRUCT_SPEC_HEAD  */
  YYSYMBOL_ARITH_SPEC = 357,               /* ARITH_SPEC  */
  YYSYMBOL_COMPILATION = 358,              /* COMPILATION  */
  YYSYMBOL_BLOCK_DEFINITION = 359,         /* BLOCK_DEFINITION  */
  YYSYMBOL_BLOCK_STMT = 360,               /* BLOCK_STMT  */
  YYSYMBOL_BLOCK_STMT_TOP = 361,           /* BLOCK_STMT_TOP  */
  YYSYMBOL_BLOCK_STMT_HEAD = 362,          /* BLOCK_STMT_HEAD  */
  YYSYMBOL_LABEL_EXTERNAL = 363,           /* LABEL_EXTERNAL  */
  YYSYMBOL_CLOSING = 364,                  /* CLOSING  */
  YYSYMBOL_BLOCK_BODY = 365,               /* BLOCK_BODY  */
  YYSYMBOL_FUNCTION_NAME = 366,            /* FUNCTION_NAME  */
  YYSYMBOL_PROCEDURE_NAME = 367,           /* PROCEDURE_NAME  */
  YYSYMBOL_FUNC_STMT_BODY = 368,           /* FUNC_STMT_BODY  */
  YYSYMBOL_PROC_STMT_BODY = 369,           /* PROC_STMT_BODY  */
  YYSYMBOL_DECLARE_GROUP = 370,            /* DECLARE_GROUP  */
  YYSYMBOL_DECLARE_ELEMENT = 371,          /* DECLARE_ELEMENT  */
  YYSYMBOL_PARAMETER = 372,                /* PARAMETER  */
  YYSYMBOL_PARAMETER_LIST = 373,           /* PARAMETER_LIST  */
  YYSYMBOL_PARAMETER_HEAD = 374,           /* PARAMETER_HEAD  */
  YYSYMBOL_DECLARE_STATEMENT = 375,        /* DECLARE_STATEMENT  */
  YYSYMBOL_ASSIGN_LIST = 376,              /* ASSIGN_LIST  */
  YYSYMBOL_TEXT = 377,                     /* TEXT  */
  YYSYMBOL_REPLACE_STMT = 378,             /* REPLACE_STMT  */
  YYSYMBOL_REPLACE_HEAD = 379,             /* REPLACE_HEAD  */
  YYSYMBOL_ARG_LIST = 380,                 /* ARG_LIST  */
  YYSYMBOL_STRUCTURE_STMT = 381,           /* STRUCTURE_STMT  */
  YYSYMBOL_STRUCT_STMT_HEAD = 382,         /* STRUCT_STMT_HEAD  */
  YYSYMBOL_STRUCT_STMT_TAIL = 383,         /* STRUCT_STMT_TAIL  */
  YYSYMBOL_INLINE_DEFINITION = 384,        /* INLINE_DEFINITION  */
  YYSYMBOL_ARITH_INLINE = 385,             /* ARITH_INLINE  */
  YYSYMBOL_ARITH_INLINE_DEF = 386,         /* ARITH_INLINE_DEF  */
  YYSYMBOL_BIT_INLINE = 387,               /* BIT_INLINE  */
  YYSYMBOL_BIT_INLINE_DEF = 388,           /* BIT_INLINE_DEF  */
  YYSYMBOL_CHAR_INLINE = 389,              /* CHAR_INLINE  */
  YYSYMBOL_CHAR_INLINE_DEF = 390,          /* CHAR_INLINE_DEF  */
  YYSYMBOL_STRUC_INLINE_DEF = 391          /* STRUC_INLINE_DEF  */
};
typedef enum yysymbol_kind_t yysymbol_kind_t;




#ifdef short
# undef short
#endif

/* On compilers that do not define __PTRDIFF_MAX__ etc., make sure
   <limits.h> and (if available) <stdint.h> are included
   so that the code can choose integer types of a good width.  */

#ifndef __PTRDIFF_MAX__
# include <limits.h> /* INFRINGES ON USER NAME SPACE */
# if defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stdint.h> /* INFRINGES ON USER NAME SPACE */
#  define YY_STDINT_H
# endif
#endif

/* Narrow types that promote to a signed type and that can represent a
   signed or unsigned integer of at least N bits.  In tables they can
   save space and decrease cache pressure.  Promoting to a signed type
   helps avoid bugs in integer arithmetic.  */

#ifdef __INT_LEAST8_MAX__
typedef __INT_LEAST8_TYPE__ yytype_int8;
#elif defined YY_STDINT_H
typedef int_least8_t yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef __INT_LEAST16_MAX__
typedef __INT_LEAST16_TYPE__ yytype_int16;
#elif defined YY_STDINT_H
typedef int_least16_t yytype_int16;
#else
typedef short yytype_int16;
#endif

/* Work around bug in HP-UX 11.23, which defines these macros
   incorrectly for preprocessor constants.  This workaround can likely
   be removed in 2023, as HPE has promised support for HP-UX 11.23
   (aka HP-UX 11i v2) only through the end of 2022; see Table 2 of
   <https://h20195.www2.hpe.com/V2/getpdf.aspx/4AA4-7673ENW.pdf>.  */
#ifdef __hpux
# undef UINT_LEAST8_MAX
# undef UINT_LEAST16_MAX
# define UINT_LEAST8_MAX 255
# define UINT_LEAST16_MAX 65535
#endif

#if defined __UINT_LEAST8_MAX__ && __UINT_LEAST8_MAX__ <= __INT_MAX__
typedef __UINT_LEAST8_TYPE__ yytype_uint8;
#elif (!defined __UINT_LEAST8_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST8_MAX <= INT_MAX)
typedef uint_least8_t yytype_uint8;
#elif !defined __UINT_LEAST8_MAX__ && UCHAR_MAX <= INT_MAX
typedef unsigned char yytype_uint8;
#else
typedef short yytype_uint8;
#endif

#if defined __UINT_LEAST16_MAX__ && __UINT_LEAST16_MAX__ <= __INT_MAX__
typedef __UINT_LEAST16_TYPE__ yytype_uint16;
#elif (!defined __UINT_LEAST16_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST16_MAX <= INT_MAX)
typedef uint_least16_t yytype_uint16;
#elif !defined __UINT_LEAST16_MAX__ && USHRT_MAX <= INT_MAX
typedef unsigned short yytype_uint16;
#else
typedef int yytype_uint16;
#endif

#ifndef YYPTRDIFF_T
# if defined __PTRDIFF_TYPE__ && defined __PTRDIFF_MAX__
#  define YYPTRDIFF_T __PTRDIFF_TYPE__
#  define YYPTRDIFF_MAXIMUM __PTRDIFF_MAX__
# elif defined PTRDIFF_MAX
#  ifndef ptrdiff_t
#   include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  endif
#  define YYPTRDIFF_T ptrdiff_t
#  define YYPTRDIFF_MAXIMUM PTRDIFF_MAX
# else
#  define YYPTRDIFF_T long
#  define YYPTRDIFF_MAXIMUM LONG_MAX
# endif
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned
# endif
#endif

#define YYSIZE_MAXIMUM                                  \
  YY_CAST (YYPTRDIFF_T,                                 \
           (YYPTRDIFF_MAXIMUM < YY_CAST (YYSIZE_T, -1)  \
            ? YYPTRDIFF_MAXIMUM                         \
            : YY_CAST (YYSIZE_T, -1)))

#define YYSIZEOF(X) YY_CAST (YYPTRDIFF_T, sizeof (X))


/* Stored state numbers (used for stacks). */
typedef yytype_int16 yy_state_t;

/* State numbers in computations.  */
typedef int yy_state_fast_t;

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif


#ifndef YY_ATTRIBUTE_PURE
# if defined __GNUC__ && 2 < __GNUC__ + (96 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define YY_ATTRIBUTE_PURE
# endif
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# if defined __GNUC__ && 2 < __GNUC__ + (7 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_UNUSED __attribute__ ((__unused__))
# else
#  define YY_ATTRIBUTE_UNUSED
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YY_USE(E) ((void) (E))
#else
# define YY_USE(E) /* empty */
#endif

/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
#if defined __GNUC__ && ! defined __ICC && 406 <= __GNUC__ * 100 + __GNUC_MINOR__
# if __GNUC__ * 100 + __GNUC_MINOR__ < 407
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")
# else
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")              \
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# endif
# define YY_IGNORE_MAYBE_UNINITIALIZED_END      \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif

#if defined __cplusplus && defined __GNUC__ && ! defined __ICC && 6 <= __GNUC__
# define YY_IGNORE_USELESS_CAST_BEGIN                          \
    _Pragma ("GCC diagnostic push")                            \
    _Pragma ("GCC diagnostic ignored \"-Wuseless-cast\"")
# define YY_IGNORE_USELESS_CAST_END            \
    _Pragma ("GCC diagnostic pop")
#endif
#ifndef YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_END
#endif


#define YY_ASSERT(E) ((void) (0 && (E)))

#if !defined yyoverflow

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* !defined yyoverflow */

#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL \
             && defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yy_state_t yyss_alloc;
  YYSTYPE yyvs_alloc;
  YYLTYPE yyls_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (YYSIZEOF (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (YYSIZEOF (yy_state_t) + YYSIZEOF (YYSTYPE) \
             + YYSIZEOF (YYLTYPE)) \
      + 2 * YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYPTRDIFF_T yynewbytes;                                         \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * YYSIZEOF (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / YYSIZEOF (*yyptr);                        \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, YY_CAST (YYSIZE_T, (Count)) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYPTRDIFF_T yyi;                      \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  459
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   7322

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  200
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  192
/* YYNRULES -- Number of rules.  */
#define YYNRULES  598
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  994

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   454


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX)                                \
  (0 <= (YYX) && (YYX) <= YYMAXUTOK                     \
   ? YY_CAST (yysymbol_kind_t, yytranslate[YYX])        \
   : YYSYMBOL_YYUNDEF)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      65,    66,    67,    68,    69,    70,    71,    72,    73,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    87,    88,    89,    90,    91,    92,    93,    94,
      95,    96,    97,    98,    99,   100,   101,   102,   103,   104,
     105,   106,   107,   108,   109,   110,   111,   112,   113,   114,
     115,   116,   117,   118,   119,   120,   121,   122,   123,   124,
     125,   126,   127,   128,   129,   130,   131,   132,   133,   134,
     135,   136,   137,   138,   139,   140,   141,   142,   143,   144,
     145,   146,   147,   148,   149,   150,   151,   152,   153,   154,
     155,   156,   157,   158,   159,   160,   161,   162,   163,   164,
     165,   166,   167,   168,   169,   170,   171,   172,   173,   174,
     175,   176,   177,   178,   179,   180,   181,   182,   183,   184,
     185,   186,   187,   188,   189,   190,   191,   192,   193,   194,
     195,   196,   197,   198,   199
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,   645,   645,   646,   648,   649,   650,   652,   653,   654,
     655,   656,   657,   658,   659,   661,   662,   663,   664,   665,
     667,   668,   669,   671,   673,   674,   676,   677,   679,   680,
     681,   682,   684,   685,   687,   688,   689,   690,   691,   692,
     693,   694,   696,   697,   698,   699,   700,   702,   703,   705,
     707,   709,   710,   711,   712,   714,   715,   717,   719,   720,
     721,   722,   724,   725,   726,   727,   728,   729,   730,   731,
     733,   734,   735,   736,   737,   739,   740,   742,   744,   746,
     748,   749,   750,   751,   753,   754,   756,   757,   759,   760,
     761,   763,   764,   765,   766,   767,   769,   770,   772,   773,
     774,   775,   776,   777,   779,   780,   781,   782,   783,   784,
     785,   786,   787,   788,   789,   790,   791,   792,   793,   794,
     795,   796,   797,   798,   799,   800,   801,   802,   803,   804,
     805,   806,   807,   808,   809,   810,   811,   812,   813,   814,
     815,   816,   817,   818,   819,   820,   821,   822,   823,   824,
     825,   827,   828,   829,   830,   832,   833,   834,   835,   837,
     838,   840,   841,   843,   844,   845,   846,   847,   849,   850,
     852,   853,   854,   855,   857,   859,   860,   862,   863,   864,
     866,   867,   869,   870,   872,   873,   874,   875,   877,   878,
     880,   882,   883,   885,   886,   887,   888,   889,   890,   891,
     892,   893,   894,   895,   897,   898,   900,   901,   902,   903,
     905,   906,   907,   908,   910,   911,   912,   913,   915,   916,
     917,   918,   920,   921,   923,   924,   925,   926,   927,   929,
     930,   931,   932,   934,   936,   937,   939,   941,   942,   943,
     945,   947,   948,   949,   950,   952,   953,   955,   957,   958,
     960,   962,   963,   964,   965,   966,   968,   969,   970,   971,
     973,   974,   976,   977,   978,   979,   981,   982,   984,   985,
     986,   987,   988,   990,   992,   993,   994,   996,   998,   999,
    1000,  1002,  1003,  1004,  1005,  1006,  1007,  1008,  1010,  1011,
    1012,  1013,  1015,  1017,  1019,  1021,  1022,  1024,  1026,  1027,
    1028,  1029,  1031,  1033,  1034,  1036,  1037,  1039,  1041,  1043,
    1045,  1046,  1048,  1049,  1051,  1052,  1053,  1055,  1056,  1057,
    1058,  1059,  1061,  1062,  1063,  1064,  1065,  1066,  1067,  1068,
    1070,  1071,  1072,  1074,  1075,  1076,  1077,  1078,  1079,  1080,
    1081,  1082,  1083,  1084,  1085,  1086,  1087,  1088,  1089,  1090,
    1091,  1092,  1093,  1094,  1095,  1096,  1097,  1098,  1099,  1100,
    1101,  1102,  1103,  1104,  1105,  1106,  1107,  1108,  1109,  1110,
    1111,  1112,  1113,  1114,  1116,  1117,  1118,  1120,  1121,  1123,
    1124,  1126,  1127,  1128,  1129,  1131,  1133,  1135,  1137,  1138,
    1139,  1140,  1142,  1143,  1144,  1145,  1146,  1147,  1148,  1149,
    1151,  1152,  1153,  1155,  1156,  1158,  1160,  1161,  1163,  1164,
    1166,  1167,  1169,  1170,  1171,  1173,  1175,  1177,  1178,  1179,
    1180,  1181,  1183,  1185,  1186,  1188,  1189,  1191,  1192,  1193,
    1194,  1196,  1197,  1198,  1200,  1201,  1202,  1204,  1205,  1206,
    1208,  1210,  1211,  1213,  1214,  1215,  1217,  1219,  1220,  1222,
    1223,  1225,  1227,  1228,  1230,  1231,  1233,  1234,  1236,  1237,
    1239,  1240,  1242,  1243,  1245,  1247,  1248,  1249,  1250,  1252,
    1253,  1255,  1256,  1258,  1259,  1260,  1261,  1262,  1263,  1264,
    1265,  1266,  1267,  1268,  1269,  1271,  1272,  1273,  1275,  1276,
    1277,  1278,  1279,  1281,  1283,  1284,  1286,  1288,  1289,  1291,
    1292,  1293,  1294,  1295,  1297,  1298,  1300,  1302,  1304,  1305,
    1307,  1309,  1311,  1312,  1313,  1315,  1316,  1317,  1318,  1319,
    1320,  1321,  1322,  1324,  1325,  1327,  1329,  1330,  1331,  1332,
    1333,  1335,  1336,  1337,  1338,  1339,  1340,  1341,  1342,  1343,
    1345,  1346,  1348,  1349,  1350,  1352,  1353,  1354,  1356,  1358,
    1360,  1361,  1362,  1364,  1365,  1366,  1368,  1369,  1371,  1372,
    1373,  1374,  1376,  1377,  1378,  1379,  1380,  1381,  1383,  1385,
    1386,  1388,  1390,  1392,  1394,  1396,  1397,  1399,  1400,  1402,
    1404,  1405,  1406,  1408,  1410,  1411,  1412,  1413,  1415,  1416,
    1418,  1419,  1421,  1422,  1424,  1426,  1427,  1429,  1431
};
#endif

/** Accessing symbol of state STATE.  */
#define YY_ACCESSING_SYMBOL(State) YY_CAST (yysymbol_kind_t, yystos[State])

#if YYDEBUG || 0
/* The user-facing name of the symbol whose (internal) number is
   YYSYMBOL.  No bounds checking.  */
static const char *yysymbol_name (yysymbol_kind_t yysymbol) YY_ATTRIBUTE_UNUSED;

/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "\"end of file\"", "error", "\"invalid token\"", "_ERROR_", "_SYMB_0",
  "_SYMB_1", "_SYMB_2", "_SYMB_3", "_SYMB_4", "_SYMB_5", "_SYMB_6",
  "_SYMB_7", "_SYMB_8", "_SYMB_9", "_SYMB_10", "_SYMB_11", "_SYMB_12",
  "_SYMB_13", "_SYMB_14", "_SYMB_15", "_SYMB_16", "_SYMB_17", "_SYMB_18",
  "_SYMB_19", "_SYMB_20", "_SYMB_21", "_SYMB_22", "_SYMB_23", "_SYMB_24",
  "_SYMB_25", "_SYMB_26", "_SYMB_27", "_SYMB_28", "_SYMB_29", "_SYMB_30",
  "_SYMB_31", "_SYMB_32", "_SYMB_33", "_SYMB_34", "_SYMB_35", "_SYMB_36",
  "_SYMB_37", "_SYMB_38", "_SYMB_39", "_SYMB_40", "_SYMB_41", "_SYMB_42",
  "_SYMB_43", "_SYMB_44", "_SYMB_45", "_SYMB_46", "_SYMB_47", "_SYMB_48",
  "_SYMB_49", "_SYMB_50", "_SYMB_51", "_SYMB_52", "_SYMB_53", "_SYMB_54",
  "_SYMB_55", "_SYMB_56", "_SYMB_57", "_SYMB_58", "_SYMB_59", "_SYMB_60",
  "_SYMB_61", "_SYMB_62", "_SYMB_63", "_SYMB_64", "_SYMB_65", "_SYMB_66",
  "_SYMB_67", "_SYMB_68", "_SYMB_69", "_SYMB_70", "_SYMB_71", "_SYMB_72",
  "_SYMB_73", "_SYMB_74", "_SYMB_75", "_SYMB_76", "_SYMB_77", "_SYMB_78",
  "_SYMB_79", "_SYMB_80", "_SYMB_81", "_SYMB_82", "_SYMB_83", "_SYMB_84",
  "_SYMB_85", "_SYMB_86", "_SYMB_87", "_SYMB_88", "_SYMB_89", "_SYMB_90",
  "_SYMB_91", "_SYMB_92", "_SYMB_93", "_SYMB_94", "_SYMB_95", "_SYMB_96",
  "_SYMB_97", "_SYMB_98", "_SYMB_99", "_SYMB_100", "_SYMB_101",
  "_SYMB_102", "_SYMB_103", "_SYMB_104", "_SYMB_105", "_SYMB_106",
  "_SYMB_107", "_SYMB_108", "_SYMB_109", "_SYMB_110", "_SYMB_111",
  "_SYMB_112", "_SYMB_113", "_SYMB_114", "_SYMB_115", "_SYMB_116",
  "_SYMB_117", "_SYMB_118", "_SYMB_119", "_SYMB_120", "_SYMB_121",
  "_SYMB_122", "_SYMB_123", "_SYMB_124", "_SYMB_125", "_SYMB_126",
  "_SYMB_127", "_SYMB_128", "_SYMB_129", "_SYMB_130", "_SYMB_131",
  "_SYMB_132", "_SYMB_133", "_SYMB_134", "_SYMB_135", "_SYMB_136",
  "_SYMB_137", "_SYMB_138", "_SYMB_139", "_SYMB_140", "_SYMB_141",
  "_SYMB_142", "_SYMB_143", "_SYMB_144", "_SYMB_145", "_SYMB_146",
  "_SYMB_147", "_SYMB_148", "_SYMB_149", "_SYMB_150", "_SYMB_151",
  "_SYMB_152", "_SYMB_153", "_SYMB_154", "_SYMB_155", "_SYMB_156",
  "_SYMB_157", "_SYMB_158", "_SYMB_159", "_SYMB_160", "_SYMB_161",
  "_SYMB_162", "_SYMB_163", "_SYMB_164", "_SYMB_165", "_SYMB_166",
  "_SYMB_167", "_SYMB_168", "_SYMB_169", "_SYMB_170", "_SYMB_171",
  "_SYMB_172", "_SYMB_173", "_SYMB_174", "_SYMB_175", "_SYMB_176",
  "_SYMB_177", "_SYMB_178", "_SYMB_179", "_SYMB_180", "_SYMB_181",
  "_SYMB_182", "_SYMB_183", "_SYMB_184", "_SYMB_185", "_SYMB_186",
  "_SYMB_187", "_SYMB_188", "_SYMB_189", "_SYMB_190", "_SYMB_191",
  "_SYMB_192", "_SYMB_193", "_SYMB_194", "_SYMB_195", "$accept",
  "DECLARE_BODY", "ATTRIBUTES", "DECLARATION", "ARRAY_SPEC",
  "TYPE_AND_MINOR_ATTR", "IDENTIFIER", "SQ_DQ_NAME",
  "DOUBLY_QUAL_NAME_HEAD", "ARITH_CONV", "DECLARATION_LIST", "NAME_ID",
  "ARITH_EXP", "TERM", "PLUS", "MINUS", "PRODUCT", "FACTOR",
  "EXPONENTIATION", "PRIMARY", "ARITH_VAR", "PRE_PRIMARY", "NUMBER",
  "LEVEL", "COMPOUND_NUMBER", "SIMPLE_NUMBER", "MODIFIED_ARITH_FUNC",
  "ARITH_FUNC_HEAD", "CALL_LIST", "LIST_EXP", "EXPRESSION", "ARITH_ID",
  "NO_ARG_ARITH_FUNC", "ARITH_FUNC", "SUBSCRIPT", "QUALIFIER",
  "SCALE_HEAD", "PREC_SPEC", "SUB_START", "SUB_HEAD", "SUB",
  "SUB_RUN_HEAD", "SUB_EXP", "POUND_EXPRESSION", "BIT_EXP", "BIT_FACTOR",
  "BIT_CAT", "OR", "CHAR_VERTICAL_BAR", "AND", "BIT_PRIM", "CAT", "NOT",
  "BIT_VAR", "LABEL_VAR", "EVENT_VAR", "BIT_CONST_HEAD", "BIT_CONST",
  "RADIX", "CHAR_STRING", "SUBBIT_HEAD", "SUBBIT_KEY", "BIT_FUNC_HEAD",
  "BIT_ID", "LABEL", "BIT_FUNC", "EVENT", "SUB_OR_QUALIFIER",
  "BIT_QUALIFIER", "CHAR_EXP", "CHAR_PRIM", "CHAR_FUNC_HEAD", "CHAR_VAR",
  "CHAR_CONST", "CHAR_FUNC", "CHAR_ID", "NAME_EXP", "NAME_KEY", "NAME_VAR",
  "VARIABLE", "STRUCTURE_EXP", "STRUCT_FUNC_HEAD", "STRUCTURE_VAR",
  "STRUCT_FUNC", "QUAL_STRUCT", "STRUCTURE_ID", "ASSIGNMENT", "EQUALS",
  "IF_STATEMENT", "IF_CLAUSE", "TRUE_PART", "IF", "THEN", "RELATIONAL_EXP",
  "RELATIONAL_FACTOR", "REL_PRIM", "COMPARISON", "RELATIONAL_OP",
  "STATEMENT", "BASIC_STATEMENT", "OTHER_STATEMENT", "ANY_STATEMENT",
  "ON_PHRASE", "ON_CLAUSE", "LABEL_DEFINITION", "CALL_KEY", "ASSIGN",
  "CALL_ASSIGN_LIST", "DO_GROUP_HEAD", "ENDING", "READ_KEY", "WRITE_KEY",
  "READ_PHRASE", "WRITE_PHRASE", "READ_ARG", "WRITE_ARG", "FILE_EXP",
  "FILE_HEAD", "IO_CONTROL", "WAIT_KEY", "TERMINATOR", "TERMINATE_LIST",
  "SCHEDULE_HEAD", "SCHEDULE_PHRASE", "SCHEDULE_CONTROL", "TIMING",
  "REPEAT", "STOPPING", "SIGNAL_CLAUSE", "PERCENT_MACRO_NAME",
  "PERCENT_MACRO_HEAD", "PERCENT_MACRO_ARG", "CASE_ELSE", "WHILE_KEY",
  "WHILE_CLAUSE", "FOR_LIST", "ITERATION_BODY", "ITERATION_CONTROL",
  "FOR_KEY", "TEMPORARY_STMT", "CONSTANT", "ARRAY_HEAD", "MINOR_ATTR_LIST",
  "MINOR_ATTRIBUTE", "INIT_OR_CONST_HEAD", "REPEATED_CONSTANT",
  "REPEAT_HEAD", "NESTED_REPEAT_HEAD", "DCL_LIST_COMMA",
  "LITERAL_EXP_OR_STAR", "TYPE_SPEC", "BIT_SPEC", "CHAR_SPEC",
  "STRUCT_SPEC", "STRUCT_SPEC_BODY", "STRUCT_TEMPLATE", "STRUCT_SPEC_HEAD",
  "ARITH_SPEC", "COMPILATION", "BLOCK_DEFINITION", "BLOCK_STMT",
  "BLOCK_STMT_TOP", "BLOCK_STMT_HEAD", "LABEL_EXTERNAL", "CLOSING",
  "BLOCK_BODY", "FUNCTION_NAME", "PROCEDURE_NAME", "FUNC_STMT_BODY",
  "PROC_STMT_BODY", "DECLARE_GROUP", "DECLARE_ELEMENT", "PARAMETER",
  "PARAMETER_LIST", "PARAMETER_HEAD", "DECLARE_STATEMENT", "ASSIGN_LIST",
  "TEXT", "REPLACE_STMT", "REPLACE_HEAD", "ARG_LIST", "STRUCTURE_STMT",
  "STRUCT_STMT_HEAD", "STRUCT_STMT_TAIL", "INLINE_DEFINITION",
  "ARITH_INLINE", "ARITH_INLINE_DEF", "BIT_INLINE", "BIT_INLINE_DEF",
  "CHAR_INLINE", "CHAR_INLINE_DEF", "STRUC_INLINE_DEF", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-782)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-415)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
    5824,   435,  -125,  -782,   -67,   410,  -782,  6963,    90,    42,
     159,  1214,    56,  -782,  -782,   167,   192,   276,   297,   190,
     -67,    59,  2537,   410,   246,    59,    59,  -125,  -782,  -782,
     182,  -782,   332,  -782,  -782,  -782,  -782,  -782,   362,  -782,
    -782,  -782,  -782,  -782,  -782,   368,  -782,  -782,  1050,   369,
     368,   393,   368,  -782,   368,   417,   162,  -782,   423,   221,
    -782,   622,  -782,   414,  -782,  6501,  6501,  3119,  -782,  -782,
    -782,  -782,  6501,   301,  6259,   173,  5966,   912,  2149,   306,
     389,   422,   442,  4071,   638,   290,    79,   458,   179,  5536,
    6501,  1960,  -782,  5682,    80,    69,   219,   979,   174,  -782,
     468,  -782,  -782,  -782,  5682,  -782,  5682,  -782,  5682,  5682,
     478,   338,  -782,  -782,  -782,   368,   472,  -782,  -782,   496,
    -782,   502,  -782,   517,   525,  -782,  -782,  -782,  -782,   534,
    -782,  -782,   539,   546,   556,  -782,  -782,  -782,  -782,  -782,
    -782,  -782,  -782,   562,  -782,  -782,   569,  -782,   475,  4156,
     565,   603,  -782,  7133,  -782,   507,    -4,  4441,  -782,   633,
    7063,  -782,  -782,  -782,  -782,  4441,  4247,  -782,  2731,  1627,
    4247,  -782,  -782,  -782,   634,  -782,  -782,  4811,   416,  -782,
    -782,  3119,   628,    41,  4811,  -782,   641,   505,  -782,   647,
     660,   665,   671,   624,   408,    52,   505,   505,  -782,   687,
     648,   655,  -782,   702,  3507,  -782,  -782,   673,   345,  -782,
    -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,
    -782,  -782,  -782,   104,  -782,   721,   104,  -782,  -782,  -782,
    -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,  -125,  -782,
    -782,   723,  -782,  -782,  -782,  -782,   725,  -782,  -782,  -782,
    -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,
    -782,  -782,  -782,  -782,  -782,   741,  -782,  -782,  -782,  -782,
    -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,
    -782,  -782,  -782,  -782,  -782,   743,   745,   757,  -782,  -782,
    -782,  -782,   368,   229,  -782,  5147,  5147,   770,  4979,   771,
    -782,   780,  -782,  -782,  -782,  -782,  -782,   787,   798,   368,
    -782,    49,   312,   101,  -782,  5424,  -782,  -782,  -782,   605,
    -782,   816,  -782,  3313,   824,  -782,   101,  -782,   826,  -782,
    -782,  -782,  -782,   829,  -782,  -782,   379,  -782,   670,  -782,
    -782,  1704,  1627,   575,   505,   722,  -782,  -782,  4265,   337,
     832,  -782,   443,  -782,   839,  -782,  -782,  -782,  -782,  6804,
    1050,  -782,  2925,  3313,  1050,   866,  -782,  3313,  -782,   182,
    -782,   772,  6794,  -782,  3119,  4095,    66,   869,  5502,   869,
    1232,  1232,    66,   312,  -782,  -782,  -782,  -782,   286,  -782,
    -782,   182,  -782,  -782,  3313,  -782,  -782,   842,   624,  6963,
    -782,  6052,   835,  -782,  -782,   846,   857,   865,   867,   872,
    -782,  -782,  -782,  -782,   395,  -782,  -782,  -782,  1168,  -782,
    2343,  -782,  3313,  4811,  4811,  5342,  4811,   757,   476,   881,
    -782,  -782,   455,  4811,  4811,  5376,   882,   769,  -782,  -782,
     887,   471,    44,  -782,  3701,  -782,  -782,  -782,  -782,  -782,
    -782,  -782,  -782,  -782,  -782,  -782,   711,  -782,  -782,  -782,
    -782,  -782,   892,  -782,   624,   834,  -782,  6173,   915,  6380,
     129,  -782,  -782,   930,  -782,  -782,  -782,  -782,  -782,  -782,
    -782,  -782,  -782,  -782,  -782,  -782,  -782,  1506,   927,   941,
    -782,   909,  -782,  -782,   933,  6380,   939,  6380,   949,  6380,
     961,  6380,   368,  -125,   368,  -782,   410,  -782,  4441,  4441,
    -782,  -782,  4441,  4441,   783,  -782,  4247,  4247,  4247,  -782,
    1627,  -782,  -782,  -782,  -782,   713,   977,  -782,  -782,   736,
    -782,   978,   272,  -782,   752,  5292,  3313,  -782,  -782,  4247,
     828,  -782,  4441,   541,   -67,   422,   973,    49,    49,  -782,
    -782,   971,    94,   988,  -782,  -782,  -782,  -782,  -782,  -782,
     975,  -782,   976,  -782,  -782,    -5,   989,   994,  -782,   -67,
     797,    59,   463,    63,   102,   992,   985,   993,   991,   385,
     997,  -782,  -782,  -782,   505,  -782,  3313,  -782,  -782,  -782,
    5147,  5147,  3895,  -782,  -782,  5147,  5147,  5147,  -782,  -782,
    5147,  1000,  -782,  3313,  -782,  -782,  -782,  -782,  5376,  -782,
    -782,  -782,  5376,  5376,  5376,   345,   345,  -782,   998,  -782,
     505,  1005,  3313,  3895,  3313,  1524,  1606,  -782,   999,   783,
    1814,   456,  -782,  4811,   840,  1007,  1002,  -782,  -782,  -782,
    -782,   285,  -782,  4635,   851,   713,  -782,  -782,  -782,  -782,
    -782,  -782,  1018,   162,  -782,  -782,  1008,   530,   754,  -782,
    -782,   379,  -782,   368,   368,   368,   368,  -782,  -782,  -782,
    1499,  1913,   140,  -782,  -782,  -782,  -782,   590,  -782,  4811,
    -782,  -782,  5376,  3119,  3895,   542,   -13,  3119,  -782,  3119,
    1009,   768,  1050,  -782,  1010,  6587,  -782,  -782,  4811,  4811,
    4811,  4811,  4811,  -782,  -782,  1013,   194,   568,   668,  1014,
      95,   547,  -782,  1239,   410,  -782,   713,   713,    49,  4811,
    -782,  -782,  -782,  4811,  4811,  3701,   713,    49,  1016,  -782,
    1015,  -782,  -782,   -67,  6708,  -782,  -782,  -782,  1021,  -782,
    -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,   775,  -782,
    -782,  -782,  1023,  -782,  1024,  -782,  1025,  -782,  1026,  -782,
    -782,   368,  1020,  1042,  1044,  1049,  1047,  4247,  4247,   633,
    -782,  -782,  -782,  -782,   863,  -782,  -782,  -782,  -782,  -782,
     784,  1057,  1065,   996,  1043,  -782,   263,  -782,  4811,  -782,
    4811,  -782,  -782,  -782,  -782,  -782,  -782,  -782,   855,  -782,
    -782,  -782,  -782,  -782,   368,   345,   368,  1069,  1066,   871,
    -782,  -782,  3895,  -782,   713,  -782,  1067,  -782,  -782,  -782,
    -782,  1058,   913,   312,   101,  -782,  5424,  1094,  1076,  -782,
     920,   713,  -782,   935,  1077,  1078,   368,  -782,  -782,   783,
     783,  -782,   563,  4811,  -782,   814,  4811,  4635,   713,  -782,
    -782,  5147,  5147,  -782,  3313,  -782,  3313,  3313,  -782,  -782,
    -782,  -782,  -782,  -782,  -782,  -782,  -782,   713,   101,   141,
     229,   101,  -782,  -782,  -782,   487,   869,   312,  -782,  -782,
     100,  -782,   443,   960,  -782,   691,   715,   808,   838,   877,
    -782,  -782,  -782,  -782,  -782,  -782,  -782,   905,   713,   713,
    1941,  -782,   914,  -782,  -782,  -782,  -782,  -782,  -782,  -782,
    -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,
    -782,  -782,  -782,   133,   713,   -67,  -782,  -782,  -782,  1068,
     605,  -782,  1208,   814,  -782,  -782,  -782,  -782,  -782,  -782,
    -782,  -782,  -782,  -782,  -782,   571,  -782,   967,  1081,   940,
    -782,  -782,  -782,  -782,  -782,  -782,  -782,  1085,  1050,  1072,
    -782,  -782,  -782,  -782,  -782,  -782,  1050,  4811,  -782,   225,
    -782,   969,  -782,  1074,  -782,  -782,  -782,  1050,  -782,   443,
    -782,  1079,   713,  1093,  1074,  1089,  4811,   974,  -782,  -782,
     947,  1090,  -782,  -782
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int16 yydefact[] =
{
       0,     0,     0,   340,     0,     0,   424,     0,     0,     0,
       0,     0,     0,   308,   277,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   236,   423,
     535,   422,     0,   240,   242,   243,   273,   297,   244,   241,
     247,    97,    23,    96,   281,    62,   282,   286,     0,     0,
     210,     0,   218,   284,   262,     0,     0,   587,     0,   288,
     292,     0,   295,     0,   374,     0,     0,     0,   377,   330,
     331,   515,     0,     0,   540,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   431,     0,     0,     0,     0,
       0,     0,   378,     0,     0,   528,     0,   536,   538,   517,
       0,   519,   332,   584,     0,   585,     0,   586,     0,     0,
       0,     0,   446,   244,   386,   214,     0,   477,   476,     0,
     474,     0,   504,     0,     0,   475,   162,   503,    16,     0,
      28,   483,     0,    31,     0,    17,    18,   479,   480,    29,
     161,   473,    19,    30,    38,    39,    40,    41,     0,    13,
       0,     0,    32,     5,     6,    34,   513,     0,    25,     2,
       7,   512,    36,    37,   510,     0,    22,   471,     0,     0,
      20,   500,   501,   499,     0,   502,   392,     0,     0,   453,
     452,     0,     0,     0,     0,   335,     0,     0,   591,     0,
       0,     0,     0,     0,     0,   380,     0,     0,   337,     0,
     575,     0,   444,     0,     0,    49,    50,     0,     0,   345,
     206,   208,   209,   105,   135,   117,   118,   119,   120,   122,
     121,   123,   231,   238,   106,     0,   272,    98,   124,   125,
      99,   232,   136,   107,   100,   126,   226,   108,     0,   229,
     140,    28,   142,   141,   268,   127,    31,   147,   109,   148,
     110,   104,   207,   275,   230,   111,   228,   227,   101,   144,
     102,   112,   269,   113,   103,    29,   133,   134,   114,   115,
     128,   129,   146,   130,   145,   131,   132,   137,   143,   270,
     225,   116,   138,    30,   245,   242,   243,   241,   233,    77,
      79,    78,     0,    91,    42,     0,     0,    47,    51,    55,
      58,    59,    71,    76,    72,    75,    60,     0,     0,    80,
      84,    92,   180,   182,   184,     0,   193,   194,   195,     0,
     196,   222,   266,     0,     0,   237,    93,   251,     0,   256,
     257,   260,    94,     0,    95,   288,     0,   427,     0,   443,
     445,     0,     0,     0,     0,     0,    63,   152,   168,     0,
       0,   287,     0,   234,     0,   211,   385,   219,   263,     0,
       0,   302,     0,     0,     0,     0,   293,     0,   333,     0,
     303,   330,     0,   304,     0,     0,     0,   182,     0,     0,
       0,     0,     0,   310,   312,   316,   375,   368,     0,   541,
     533,   534,   334,   376,     0,   341,   387,     0,   400,     0,
     398,   540,     0,   399,   348,     0,     0,     0,     0,     0,
     410,   406,   411,   350,   297,   412,   408,   413,     0,   349,
       0,   351,     0,     0,     0,     0,     0,     0,     0,     0,
     359,   425,     0,     0,     0,     0,     0,     0,   363,   433,
       0,   435,   439,   434,     0,   365,   447,   372,   465,   466,
     279,   280,   467,   468,   449,   278,     0,   450,   397,     1,
     516,   518,     0,   520,   542,     0,   546,   540,     0,     0,
     545,   556,   558,     0,   560,   525,   526,   527,   529,   530,
     532,   548,   549,   531,   569,   551,   537,   550,     0,     0,
     539,   553,   554,   521,     0,     0,     0,     0,     0,     0,
       0,     0,    64,     0,    66,   215,     0,   469,     0,     0,
     486,   485,     0,     0,     0,    26,    10,    11,    14,   571,
       0,     4,    35,   514,   498,   497,     0,   496,     8,     0,
     472,     0,    91,   488,     0,   492,     0,    40,    33,    21,
       0,   507,     0,     0,     0,     0,     0,   454,   455,   395,
     393,     0,   458,   457,   336,   416,   594,   597,   598,   590,
       0,   371,     0,   384,   383,   379,     0,     0,   338,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   248,   239,   249,     0,   261,     0,    85,   204,   205,
       0,     0,     0,    43,    44,     0,     0,     0,    54,    57,
       0,     0,    61,     0,   346,    81,   190,   189,     0,   188,
     191,   192,     0,     0,     0,     0,     0,   186,     0,   224,
       0,     0,     0,     0,     0,     0,     0,   367,     0,     0,
       0,     0,   579,     0,     0,     0,   163,   154,   153,   171,
     177,   175,   169,     0,   170,   176,   167,   151,   165,   166,
     283,   235,     0,     0,   299,   298,     0,    91,     0,    86,
      88,    90,   301,    68,   212,   220,   264,   296,   300,   307,
       0,     0,     0,   324,   325,   326,   327,     0,   322,     0,
     309,   306,     0,     0,     0,     0,     0,     0,   305,     0,
       0,     0,     0,   401,     0,     0,   402,   347,     0,     0,
       0,     0,     0,   407,   409,     0,     0,     0,     0,     0,
       0,     0,   356,     0,     0,   360,   428,   429,   430,     0,
     440,   364,   436,     0,     0,     0,   441,   442,     0,   448,
       0,   522,   543,     0,     0,   544,   523,   547,     0,   557,
     559,   552,   563,   564,   565,   567,   566,   562,     0,   572,
     555,   588,     0,   592,     0,   595,     0,   290,     0,    65,
      67,   216,     0,     0,     0,     0,     0,     9,    12,     3,
      24,   470,    15,   482,     0,   487,   481,   494,   489,   490,
       0,   508,     0,   396,     0,   462,     0,   394,     0,   456,
       0,   339,   370,   382,   381,   403,   404,   577,     0,   573,
     574,    70,   197,   259,   200,     0,   202,     0,     0,     0,
      45,    46,     0,   271,   254,   255,     0,    48,    52,    53,
      56,     0,     0,   181,   183,   185,     0,     0,     0,   198,
       0,   253,   252,     0,     0,     0,    82,   366,   580,     0,
       0,   583,     0,     0,   405,   159,     0,     0,   175,   172,
     174,     0,     0,   285,     0,   353,     0,     0,   289,    69,
     213,   221,   265,   314,   328,   329,   323,   317,   319,     0,
       0,   318,   321,   294,   320,     0,     0,   311,   313,   369,
       0,   388,   390,     0,   464,     0,     0,     0,     0,     0,
     352,   354,   415,   355,   358,   357,   426,     0,   438,   437,
       0,   373,     0,   524,   570,   568,   589,   593,   596,   291,
     217,   505,   506,   478,    27,   484,   493,   495,   491,   511,
     509,   451,   463,   460,   459,     0,   576,   201,   203,     0,
       0,    74,     0,   159,    73,   187,   223,   199,   258,   276,
     274,    83,   581,   582,   361,     0,   160,     0,     0,     0,
     173,   178,   179,    89,    87,   315,   342,     0,     0,     0,
     419,   420,   421,   417,   418,   432,     0,     0,   578,     0,
     267,     0,   362,   164,   155,   158,   156,     0,   389,   391,
     343,     0,   461,     0,     0,   159,     0,     0,   561,   250,
       0,     0,   157,   344
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -782,   710,   951,  -111,  -782,   964,    37,  -782,  -782,    87,
     606,  -782,   786,  -286,  1012,  1120,  -212,   528,  -782,  -782,
     373,  -782,   -26,  -486,   -65,   351,   -88,  -782,  -334,   273,
      33,     6,  -599,  -782,  1122,   831,  -781,  -148,  -782,  -782,
    -782,  -782,  -591,  -782,   572,   521,    -8,  -350,  -782,  -366,
    -299,   -27,   331,    47,    46,   169,  -782,   -46,  -758,  -313,
     678,  -782,  -782,    75,  1048,  -782,  -347,   910,  -782,   -37,
    -353,  -782,  1017,   -43,  -782,     5,   116,   567,  -314,   -35,
    1390,  -782,   730,  -782,     0,     4,   305,   -42,  -782,  -782,
    -782,  -782,   755,  -177,   453,   454,  -782,  -344,   241,   -36,
     -40,   382,  -782,  -782,   226,  -782,   -72,   165,  -782,  1075,
    -782,  -782,  -782,  -782,   726,   735,   788,  -782,   -29,  -782,
    -782,  -782,  -782,  -782,  -782,  -782,  -782,   717,   773,  -782,
    -782,  -782,  -782,   -33,   980,  -782,  -782,  -782,  -782,  -782,
     627,  -782,   -74,  -126,  -782,   629,  -782,  -782,  -782,    51,
     -77,  1155,  1158,    45,  -782,  -782,  -782,  1167,  -782,  -782,
    -782,  -782,  -782,  -782,    25,   409,  -782,  -782,  -782,  -782,
    -782,   718,  -782,   -48,  -782,    97,   690,  -782,   105,  -782,
    -782,   139,  -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,
    -782,  -782
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
       0,   150,   151,   152,   153,   154,    43,   156,   157,   292,
     159,   160,   293,   294,   295,   296,   297,   298,   600,   299,
     300,   301,   302,   303,   304,   305,   306,   307,   658,   659,
     660,    45,   309,   310,   366,   347,   846,   161,   348,   349,
     642,   643,   644,   645,   311,   312,   313,   608,   609,   612,
     314,   592,   315,   316,   317,   318,   319,   320,   321,   322,
     323,    49,   324,    50,   115,   325,    52,   582,   583,   326,
     327,   328,    53,   330,   331,    54,   332,    55,   454,    56,
     334,    58,   335,    60,   429,    62,    63,   678,    64,    65,
      66,    67,   681,   382,   383,   384,   385,   679,    68,    69,
      70,   466,    72,    73,   467,    75,   489,   883,    76,   696,
      77,    78,    79,    80,   411,   416,    81,    82,   412,    83,
      84,   432,    85,    86,   440,   441,   442,   443,    87,    88,
      89,   456,    90,   181,   182,   183,   553,   789,   184,   403,
     457,   165,   166,   167,   168,   534,   535,   536,   169,   526,
     170,   171,   172,   173,   541,   174,   542,   175,    91,    92,
      93,    94,    95,    96,   735,   469,    97,    98,   486,   490,
     470,   471,   748,   487,   488,   472,   492,   800,   473,   201,
     798,   474,   342,   632,   102,   103,   104,   105,   106,   107,
     108,   109
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      61,   450,   111,   397,   548,   116,   619,   110,   523,   593,
     594,   164,   163,   350,   362,   164,   617,   689,   665,   367,
     485,   203,   336,   116,   449,   203,   203,   836,   766,   371,
     379,   341,   687,   682,   393,   684,   685,   686,   392,   422,
     530,   112,   410,   452,   155,   652,   453,    46,   352,   417,
     491,   114,   849,   444,   455,   308,   191,   200,   538,   377,
     691,   550,   185,   448,    37,    61,    61,   336,   802,   337,
     345,   606,    61,   126,    61,   518,    61,   352,   336,   617,
     238,   723,   162,   437,   116,   606,   598,   948,   606,   336,
      61,    61,   793,    61,   158,    46,   539,    99,   158,   438,
     475,   164,   205,   206,    61,   100,    61,   803,    61,    61,
     176,   415,    46,    46,   836,   894,   476,   606,   468,    46,
     956,    46,   345,    46,    46,   588,   588,    42,   724,   494,
     431,   496,   580,   498,   500,   451,    46,    46,    46,   101,
      46,   205,   206,   838,   379,   863,   955,   177,   396,   563,
     140,    46,   439,    46,   478,    46,    46,   164,   794,   589,
     589,   555,   606,   606,   164,   187,   360,   574,   336,    47,
     566,   567,   607,   377,   163,   948,    37,   873,   546,   394,
     484,   336,   178,   380,   158,   446,   607,   967,   461,   607,
     202,   361,   986,   395,   339,   340,   462,   672,   687,   447,
       7,   533,   479,   986,   575,   626,   155,   577,   579,   465,
     198,   983,   345,   110,   891,   564,   529,    47,   607,   179,
     477,   396,   396,   180,   665,  -287,    74,   193,    34,    35,
     463,   631,   113,    39,    47,    47,   680,   205,   206,   815,
     158,    47,   164,    47,   162,    47,    47,   158,    37,   194,
    -287,    40,   809,   588,   576,   578,   950,   179,    47,    47,
      47,   180,    47,   607,   607,   788,    20,   630,   179,   822,
     832,   450,   180,    47,   195,    47,   222,    47,    47,   665,
     205,   206,   196,   191,   480,   774,   613,   589,   830,    27,
     833,   372,   372,   205,   206,   231,   588,   380,   372,   623,
     372,   836,   401,   197,   810,   811,   370,   373,   343,   817,
     418,   835,   481,   386,   825,   618,   372,    74,   635,   638,
     239,   387,   687,   336,   455,   653,   419,   684,   338,   653,
     589,   458,   393,   836,   847,   610,   392,   671,   344,   433,
     388,   646,   647,   116,   254,   546,   482,   163,   483,   503,
     613,   611,   623,   942,   943,   504,   621,   648,   649,   336,
      61,   393,   336,   661,    61,   392,   377,   336,  -294,   667,
     666,   663,    61,    44,   336,   353,    34,    35,   618,   155,
     113,    39,    71,   410,   818,   819,   345,   345,   434,   634,
     626,   417,   530,   420,   661,   655,   805,   345,   378,  -414,
     668,    61,   504,   164,   163,   451,    46,    46,   444,   421,
     741,    46,   435,   530,   356,  -414,   436,   162,   352,    46,
     336,    44,   706,   359,    21,   618,   345,   393,   561,   363,
       1,   392,     2,    25,   368,   618,   155,    26,    44,    44,
     664,   749,   767,   768,   728,    44,   423,    44,    46,    44,
      44,   361,    37,   415,   365,   705,    41,    42,   400,   714,
     840,   345,    44,    44,    44,    46,    44,    61,   801,    61,
     449,   205,   206,   460,   162,   715,   841,    44,   445,    44,
     665,    44,    44,   506,   205,   206,   158,   588,   493,   452,
     380,   164,   453,   502,   738,    61,   712,    61,   503,    61,
     778,    61,   507,   785,   530,   345,   869,   667,   508,   448,
     667,   689,   378,   495,    46,   497,    46,   499,   501,   687,
     752,   589,   754,   509,   756,   163,   758,   935,    47,    47,
      33,   510,   682,    47,    37,   352,   336,   450,   205,   206,
     511,    47,    46,   856,    46,   512,    46,   623,    46,   205,
     206,   545,   513,   665,   588,   205,   206,   155,   808,   762,
     763,   783,   514,   764,   765,   951,   952,   895,   515,   533,
      47,   205,   206,   892,   158,   667,   205,   206,  -297,   205,
     206,   784,    46,   944,   544,   519,   661,    47,   589,   333,
     455,   972,   816,   782,   828,   162,    34,    35,   372,    37,
     113,    39,   516,   661,   824,    37,   797,   520,   618,    41,
      42,   854,   618,   618,   618,   577,   577,   970,   864,   361,
     865,   522,   661,   816,   661,   336,   364,   695,    41,    42,
     667,   666,   663,   365,   333,   866,    47,   527,    47,   376,
     345,   530,   530,   540,   623,   333,   379,   871,   549,   179,
     379,   361,   379,   180,   569,   393,    14,   881,   430,   392,
     253,   554,   576,   578,    47,   654,    47,   556,    47,   662,
      47,   451,    46,   801,   868,   377,   205,   206,    48,   876,
     557,   876,   618,   336,   816,   558,   875,   336,   345,   336,
     627,   559,   882,   734,   393,    61,   960,   947,   392,   205,
     206,   664,   289,   290,    47,   378,   677,   568,   677,   570,
     677,   677,   677,   571,   116,   729,   730,   667,   637,   663,
     961,   205,   206,   205,   206,   728,    48,   584,   636,  -149,
      59,  -139,    44,    44,    61,   333,     1,    44,     2,    46,
     771,   772,    46,    48,    48,    44,   633,  -150,   333,  -246,
      48,  -271,    48,   547,    48,    48,   775,   776,   857,   858,
     896,    34,    35,   586,    37,   113,    39,    48,    48,    48,
     902,    48,   857,   880,    44,   574,   573,   595,   351,   904,
     905,    46,    48,   599,    48,   971,    48,    48,   917,   918,
     667,    44,   663,   603,    47,    59,    59,   613,   601,   380,
     288,   872,    59,   380,   351,   380,    59,   351,   957,   667,
      34,    35,   816,   962,   113,    39,   205,   206,   604,   351,
      59,    59,   620,    59,    34,    35,   618,    37,   113,    39,
     622,   667,   624,   946,    59,   625,    59,   650,    59,    59,
      44,   613,    44,   963,   623,   651,   205,   206,   692,   613,
     669,   737,   698,   375,   336,   697,   336,   661,    33,   925,
     926,    47,    37,   699,    47,   222,    41,    42,    44,   428,
      44,   700,    44,   701,    44,   857,   931,   737,   702,   737,
     664,   737,   964,   737,   231,   205,   206,   655,   719,   953,
     333,   126,   713,   588,   210,   211,   212,   673,   361,   674,
     675,   676,   664,    47,   667,   720,   663,   721,    44,   239,
     965,    37,   731,   205,   206,    41,    42,   857,   934,   289,
     290,   695,   733,   978,   857,   937,     1,   589,     2,   333,
     333,   981,   404,   254,   333,   736,   667,   666,   663,   857,
     938,   333,   881,   525,   826,   976,   573,   484,   205,   206,
     740,   525,   992,   751,   532,   205,   206,   396,   979,   753,
     734,   333,   968,   543,   958,   959,   352,   375,   140,   755,
     552,   973,   974,   984,   974,   664,   405,   882,   958,   991,
     289,   757,   770,   773,   786,   484,   252,   333,   781,   333,
     572,   787,   790,   799,   795,   791,   792,   710,    44,   796,
     804,   677,   677,   626,   805,    46,   821,   718,   806,   827,
     829,   843,   844,    46,   378,   807,   727,   406,   378,   837,
     378,   845,   850,   853,    46,   911,    14,   900,   855,   879,
     884,   121,   122,   890,   893,   901,   407,    48,    48,   329,
     123,   903,    48,   906,   907,   908,   909,   912,    51,   913,
      48,    33,   915,   914,    36,    37,   126,   186,    40,    41,
      42,   290,   127,   919,     1,    44,     2,   199,    44,   408,
     920,   930,   922,    28,   921,   929,   409,   933,   932,    48,
     130,   936,   939,   940,   329,   966,   975,   969,   133,   351,
     351,   977,   980,   985,   351,   329,    48,    33,   989,   988,
      36,    37,   351,   333,    40,    41,    42,    44,   946,   694,
     993,   528,   742,    51,    51,   743,   744,   521,   745,   746,
      51,   747,    51,   139,    51,   916,   769,    47,   820,   823,
     954,   351,   602,   140,   641,    47,   585,   688,    51,    51,
     877,    51,   987,   878,   703,    48,    47,    48,   351,   657,
     656,   402,    51,   333,    51,   704,    51,    51,   722,   143,
     670,   690,   779,   551,    14,   780,   189,   346,    37,   190,
     333,   354,   355,    48,   357,    48,   358,    48,   192,    48,
     657,   750,     1,     0,     2,   329,   573,     0,   739,   333,
       0,   333,     0,     0,     0,     0,     0,   351,   329,    59,
       0,     0,     0,     0,     0,     0,     0,   677,     0,   707,
     708,    28,   711,    48,     0,     0,     0,     0,     0,   716,
     717,   329,     0,     0,     0,    59,     0,    59,     0,    59,
     726,    59,   405,     0,   188,    33,     0,   505,    36,    37,
       0,   560,    40,    41,    42,     0,     0,     0,     0,     0,
     333,     0,   333,     0,   333,   573,   333,   210,   211,   212,
     673,   361,   674,   675,   676,   351,   121,   122,     0,     0,
     227,     0,     0,   406,     0,   123,     0,   230,     0,    33,
      34,    35,    14,    37,   113,    39,    40,     0,     0,   234,
       0,   126,   407,     0,   525,   525,     0,   573,   525,   525,
       0,   227,     0,    48,     0,   590,     0,     0,   230,     0,
       0,     0,     0,     0,     0,   130,   562,   565,     0,     0,
     234,     0,   532,   133,     0,   408,     0,     0,   525,    28,
       0,    44,   409,   258,     0,     0,     0,     0,   260,    44,
     329,     0,     0,     0,     0,   581,     0,     0,   581,   252,
      44,   264,     0,    33,     0,   351,    36,    37,   139,     0,
      40,    41,    42,     0,   258,     0,     0,     0,   140,   260,
      48,     0,   657,    48,     0,     0,     0,     0,   814,   329,
     329,     0,   264,     0,   329,     0,     0,   590,     0,   657,
      57,   329,     0,     0,   143,     0,    36,    37,     0,     0,
       0,    41,    42,    37,     0,     0,     0,     0,   657,   831,
     657,   329,    48,   591,   587,     0,     0,     0,     0,   842,
      51,   333,   351,   333,   333,   351,     0,     0,    37,   848,
       0,   605,    41,    42,     0,     0,     0,   329,     0,   329,
     590,     0,     0,     0,     0,     0,   693,     0,     0,    51,
       0,     0,     0,     0,     0,    57,    57,   381,     0,     0,
     628,     0,    57,     0,   351,   867,    57,     0,     0,   375,
     870,     0,     0,   375,     0,   375,     0,     0,     0,     0,
      57,    57,     0,    57,   885,   886,   887,   888,   889,     0,
       0,     0,     0,     0,    57,   591,    57,     0,    57,    57,
       0,     0,     0,     0,   801,   897,     0,   205,   206,   898,
     899,   708,   732,     0,     0,    51,     0,    51,     0,     0,
       0,     0,     0,   588,   210,   211,   212,   673,   361,   674,
     675,   676,     0,     0,     0,     0,     0,   590,     1,     0,
       2,     0,     0,    51,   590,    51,     0,    51,   591,    51,
       0,     0,     0,   329,   761,   590,     0,   589,   121,   122,
       0,     0,     0,     0,   590,     0,     0,   123,     0,     0,
       0,   381,     0,     0,   923,     0,   924,     0,     0,     0,
       0,     0,     0,   126,   590,     0,   227,     0,     0,   127,
       0,     0,     0,   230,     0,     0,     0,     0,   572,     0,
       0,     0,     0,   329,     0,   234,     0,   130,     0,   329,
       0,     0,     0,     0,     0,   133,   252,     0,     0,     0,
     329,     0,     0,     0,   759,     0,   760,     0,     0,   945,
       0,     0,   949,   848,     0,     0,    48,     0,    14,   329,
     329,   329,   834,   657,    48,   591,     0,     0,     0,   258,
     139,     0,   591,   590,   260,    48,     0,   851,     0,     0,
     140,     0,     0,   591,     0,     0,     0,   264,   227,   590,
       0,     0,   591,     0,   761,   230,     0,     0,     0,     0,
       0,     0,   590,     0,     0,    28,   143,   234,   351,     0,
       0,     0,   591,     0,     0,    37,   351,     0,     0,     0,
     329,   329,     0,     0,   329,     0,   329,   351,     0,    33,
      34,    35,    36,    37,   113,    39,    40,    41,    42,   590,
     590,     0,     0,   590,     0,   629,     0,     0,   590,   590,
       0,   258,     0,     0,     0,     0,   260,     0,   590,     0,
     117,     0,   118,    51,     0,     0,     0,     0,     0,   264,
       0,     0,     0,   982,   120,     0,     0,     0,     0,     0,
       0,   591,     0,     0,   381,   852,     0,     0,     0,     0,
     124,     0,   990,     0,     0,     0,   125,   591,     0,     0,
       0,     0,    51,     0,     0,   859,   860,   861,   862,     0,
     591,    33,    34,    35,    36,    37,   113,    39,    40,    41,
      42,     0,     0,     0,   129,     0,     0,   131,     0,     0,
       0,   132,    33,   144,   145,    36,   537,   147,   148,   149,
     134,    42,     0,     0,     0,     0,   590,   591,   591,   329,
       0,   591,     0,     0,     0,   839,   591,   591,     0,   137,
       0,     0,     0,   590,   138,     0,   591,     0,     0,     0,
     117,     0,   118,     0,   590,     0,     0,     0,     0,    57,
     590,     0,     0,   141,   120,     0,     0,     0,     0,     0,
       0,   329,     0,   329,   329,   761,     0,     0,     0,   590,
     124,     0,   590,   910,     0,    57,   125,    57,     0,    57,
       0,    57,     0,     0,     0,     0,     0,   590,   590,   590,
     590,   590,     0,     0,     0,     0,     0,     0,     0,   590,
     590,   590,     0,     0,   129,     0,     0,   131,   803,     0,
       0,   132,     0,     0,     0,     0,   927,     0,   928,     0,
     134,     0,     0,     0,   591,   590,   590,   588,   210,   211,
     212,   673,   361,   674,   675,   676,     0,     0,   761,   137,
       0,   591,     0,     0,   138,     0,     0,   590,   941,     0,
     459,   590,   591,     0,     0,     0,     0,     0,   591,     0,
       0,   589,     0,   141,     1,     0,     2,     0,     0,     0,
       3,     0,     0,     0,     0,     0,     0,   591,     0,     0,
     591,     0,     0,     4,   590,     0,     0,     0,     0,     0,
       0,     0,   590,   227,     0,   591,   591,   591,   591,   591,
     230,     0,     0,     0,     0,     5,     6,   591,   591,   591,
       0,     0,   234,     0,     0,     0,     0,     0,     0,     0,
     252,     7,     0,     0,     0,     0,     8,     0,     0,     0,
       0,     0,     0,   591,   591,     0,     9,     0,     0,     0,
      10,     0,     0,    11,    12,     0,    13,     0,     0,     0,
       0,     0,     0,     0,     0,   591,   258,     0,     0,   591,
       0,   260,     0,   381,    14,     0,   874,   381,     0,   381,
       0,    15,    16,     0,   264,     0,     0,     0,     0,     0,
       0,    17,    18,     0,     0,     0,    19,    20,    21,    22,
       0,     0,   591,     0,     0,    23,    24,    25,     0,     0,
     591,    26,     0,     0,     0,     0,     0,     0,     0,     0,
      27,    28,     0,     0,     0,     0,    33,    34,    35,    29,
      37,   113,    39,    40,    41,    42,     0,     0,     0,    30,
       0,    31,     0,    32,     0,    33,    34,    35,    36,    37,
      38,    39,    40,    41,    42,   204,     0,   205,   206,     0,
       0,     0,     0,   207,     0,   208,     0,     0,     0,   413,
       0,     0,     0,     0,   210,   211,   212,     0,     0,     0,
       0,     0,     0,   213,   214,     0,     0,     0,     0,   215,
     216,   217,   218,   219,   220,   221,     0,     0,     0,     0,
     222,   223,     0,     0,     0,     0,     0,     0,   224,   225,
     226,   227,     0,   405,     0,     0,   228,   229,   230,   231,
       0,     0,     0,   232,   233,     0,     0,     0,     0,     0,
     234,     0,     0,     0,     0,     0,   235,     0,   236,     0,
     237,     0,   238,     0,   239,     0,     0,     0,   240,     0,
     241,   242,     0,   243,   406,   244,     0,   245,   246,   247,
     248,   249,   250,    14,   251,     0,   252,   253,   254,   255,
     256,   257,     0,   407,   258,     0,     0,   259,     0,   260,
       0,     0,     0,   261,     0,     0,     0,     0,     0,     0,
     262,   263,   264,   265,     0,     0,     0,   266,   267,   268,
       0,   269,   270,     0,   271,   272,   408,   273,     0,     0,
      28,   274,     0,   409,   275,   276,     0,     0,     0,     0,
       0,   277,   278,   279,   280,   281,   282,     0,     0,   283,
       0,     0,     0,   284,    33,   285,   286,    36,   414,    38,
     287,    40,    41,    42,   288,     0,   289,   290,   291,   204,
       0,   205,   206,     0,     0,     0,     0,   207,     0,   208,
       0,     0,     0,     0,     0,     0,     0,     0,   210,   211,
     212,     0,     0,     0,     0,     0,     0,   213,   214,     0,
       0,     0,     0,   215,   216,   217,   218,   219,   220,   221,
       0,     0,     0,     0,   222,   223,     0,     0,     0,     0,
       0,     0,   224,   225,   226,   227,     0,   405,     0,     0,
     228,   229,   230,   231,     0,     0,     0,   232,   233,     0,
       0,     0,     0,     0,   234,     0,     0,     0,     0,     0,
     235,     0,   236,     0,   237,     0,   238,     0,   239,     0,
       0,     0,   240,     0,   241,   242,     0,   243,   406,   244,
       0,   245,   246,   247,   248,   249,   250,    14,   251,     0,
     252,   253,   254,   255,   256,   257,     0,   407,   258,     0,
       0,   259,     0,   260,     0,     0,     0,   261,     0,     0,
       0,     0,     0,     0,   262,   263,   264,   265,     0,     0,
       0,   266,   267,   268,     0,   269,   270,     0,   271,   272,
     408,   273,     0,     0,    28,   274,     0,   409,   275,   276,
       0,     0,     0,     0,     0,   277,   278,   279,   280,   281,
     282,     0,     0,   283,     0,     0,     0,   284,    33,   285,
     286,    36,   414,    38,   287,    40,    41,    42,   288,     0,
     289,   290,   291,   204,     0,   205,   206,     0,     0,     0,
       0,   207,     0,   208,     0,     0,     0,   209,     0,     0,
       0,     0,   210,   211,   212,     0,     0,     0,     0,     0,
       0,   213,   214,     0,     0,     0,     0,   215,   216,   217,
     218,   219,   220,   221,     0,     0,     0,     0,   222,   223,
       0,     0,     0,     0,     0,     0,   224,   225,   226,   227,
       0,     0,     0,     0,   228,   229,   230,   231,     0,     0,
       0,   232,   233,     0,     0,     0,     0,     0,   234,     0,
       0,     0,     0,     0,   235,     0,   236,     0,   237,     0,
     238,     0,   239,     0,     0,     0,   240,     0,   241,   242,
       0,   243,     0,   244,     0,   245,   246,   247,   248,   249,
     250,    14,   251,     0,   252,   253,   254,   255,   256,   257,
       0,     0,   258,     0,     0,   259,     0,   260,     0,     0,
       0,   261,     0,     0,     0,     0,     0,     0,   262,   263,
     264,   265,     0,     0,     0,   266,   267,   268,     0,   269,
     270,     0,   271,   272,     0,   273,     0,     0,    28,   274,
       0,     0,   275,   276,     0,     0,     0,     0,     0,   277,
     278,   279,   280,   281,   282,     0,     0,   283,     0,     0,
       0,   284,    33,   285,   286,    36,    37,    38,   287,    40,
      41,    42,   288,     0,   289,   290,   291,   204,     0,   205,
     206,   531,     0,     0,     0,   207,     0,   208,     0,     0,
       0,     0,     0,     0,     0,     0,   210,   211,   212,     0,
       0,     0,     0,     0,     0,   213,   214,     0,     0,     0,
       0,   215,   216,   217,   218,   219,   220,   221,     0,     0,
       0,     0,   222,   223,     0,     0,     0,     0,     0,     0,
     224,   225,   226,   227,     0,     0,     0,     0,   228,   229,
     230,   231,     0,     0,     0,   232,   233,     0,     0,     0,
       0,     0,   234,     0,     0,     0,     0,     0,   235,     0,
     236,     0,   237,     0,   238,     0,   239,     0,     0,     0,
     240,     0,   241,   242,     0,   243,     0,   244,     0,   245,
     246,   247,   248,   249,   250,    14,   251,     0,   252,   253,
     254,   255,   256,   257,     0,     0,   258,     0,     0,   259,
       0,   260,     0,     0,     0,   261,     0,     0,     0,     0,
       0,     0,   262,   263,   264,   265,     0,     0,     0,   266,
     267,   268,     0,   269,   270,     0,   271,   272,     0,   273,
       0,     0,    28,   274,     0,     0,   275,   276,     0,     0,
       0,     0,     0,   277,   278,   279,   280,   281,   282,     0,
       0,   283,     0,     0,     0,   284,    33,   285,   286,    36,
      37,    38,   287,    40,    41,    42,   288,     0,   289,   290,
     291,   204,     0,   205,   206,     0,     0,     0,     0,   207,
       0,   208,     0,     0,     0,     0,     0,     0,     0,     0,
     210,   211,   212,     0,     0,     0,     0,     0,     0,   213,
     214,     0,     0,     0,     0,   215,   216,   217,   218,   219,
     220,   221,     0,     0,     0,     0,   222,   223,     0,     0,
       0,     0,     0,     0,   224,   225,   226,   227,     0,     0,
       0,     0,   228,   229,   230,   231,     0,     0,     0,   232,
     233,     0,     0,     0,     0,     0,   234,     0,     0,     0,
       0,     0,   235,     0,   236,    10,   237,     0,   238,     0,
     239,     0,     0,     0,   240,     0,   241,   242,     0,   243,
       0,   244,     0,   245,   246,   247,   248,   249,   250,    14,
     251,     0,   252,   253,   254,   255,   256,   257,     0,     0,
     258,     0,     0,   259,     0,   260,     0,     0,     0,   261,
       0,     0,     0,     0,     0,     0,   262,   263,   264,   265,
       0,     0,     0,   266,   267,   268,     0,   269,   270,     0,
     271,   272,     0,   273,     0,     0,    28,   274,     0,     0,
     275,   276,     0,     0,     0,     0,     0,   277,   278,   279,
     280,   281,   282,     0,     0,   283,     0,     0,     0,   284,
      33,   285,   286,    36,    37,    38,   287,    40,    41,    42,
     288,     0,   289,   290,   291,   374,     0,   205,   206,     0,
       0,     0,     0,   207,     0,   208,     0,     0,     0,     0,
       0,     0,     0,     0,   210,   211,   212,     0,     0,     0,
       0,     0,     0,   213,   214,     0,     0,     0,     0,   215,
     216,   217,   218,   219,   220,   221,     0,     0,     0,     0,
     222,   223,     0,     0,     0,     0,     0,     0,   224,   225,
     226,   227,     0,     0,     0,     0,   228,   229,   230,   231,
       0,     0,     0,   232,   233,     0,     0,     0,     0,     0,
     234,     0,     0,     0,     0,     0,   235,     0,   236,     0,
     237,     0,   238,     0,   239,     0,     0,     0,   240,     0,
     241,   242,     0,   243,     0,   244,     0,   245,   246,   247,
     248,   249,   250,    14,   251,     0,   252,   253,   254,   255,
     256,   257,     0,     0,   258,     0,     0,   259,     0,   260,
       0,     0,     0,   261,     0,     0,     0,     0,     0,     0,
     262,   263,   264,   265,     0,     0,     0,   266,   267,   268,
       0,   269,   270,     0,   271,   272,     0,   273,     0,     0,
      28,   274,     0,     0,   275,   276,     0,     0,     0,     0,
       0,   277,   278,   279,   280,   281,   282,     0,     0,   283,
       0,     0,     0,   284,    33,   285,   286,    36,    37,    38,
     287,    40,    41,    42,   288,     0,   289,   290,   291,   204,
       0,   205,   206,     0,     0,     0,     0,   207,     0,   208,
       0,     0,     0,     0,     0,     0,     0,     0,   210,   211,
     212,     0,     0,     0,     0,     0,     0,   213,   214,     0,
       0,     0,     0,   215,   216,   217,   218,   219,   220,   221,
       0,     0,     0,     0,   222,   223,     0,     0,     0,     0,
       0,     0,   224,   225,   226,   227,     0,     0,     0,     0,
     228,   229,   230,   231,     0,     0,     0,   232,   233,     0,
       0,     0,     0,     0,   234,     0,     0,     0,     0,     0,
     235,     0,   236,     0,   237,     0,   238,     0,   239,     0,
       0,     0,   240,     0,   241,   242,     0,   243,     0,   244,
       0,   245,   246,   247,   248,   249,   250,    14,   251,     0,
     252,   253,   254,   255,   256,   257,     0,     0,   258,     0,
       0,   259,     0,   260,     0,     0,     0,   261,     0,     0,
       0,     0,     0,     0,   262,   263,   264,   265,     0,     0,
       0,   266,   267,   268,     0,   269,   270,     0,   271,   272,
       0,   273,     0,     0,    28,   274,     0,     0,   275,   276,
       0,     0,     0,     0,     0,   277,   278,   279,   280,   281,
     282,     0,     0,   283,     0,     0,     0,   284,    33,   285,
     286,    36,    37,    38,   287,    40,    41,    42,   288,     0,
     289,   290,   291,   204,     0,   205,   206,     0,     0,     0,
       0,   207,     0,   208,     0,     0,     0,     0,     0,     0,
       0,     0,   210,   211,   212,     0,     0,     0,     0,     0,
       0,   213,   214,     0,     0,     0,     0,   215,   216,   217,
     218,   219,   220,   221,     0,     0,     0,     0,   222,   223,
       0,     0,     0,     0,     0,     0,   224,   225,   226,   227,
       0,     0,     0,     0,   228,   229,   230,   231,     0,     0,
       0,   232,   233,     0,     0,     0,     0,     0,   234,     0,
       0,     0,     0,     0,   235,     0,   236,     0,   237,     0,
       0,     0,   239,     0,     0,     0,   240,     0,   241,   242,
       0,   243,     0,   244,     0,   245,   246,   247,   248,   249,
     250,     0,   251,     0,   252,     0,   254,   255,   256,   257,
       0,     0,   258,     0,     0,   259,     0,   260,     0,     0,
       0,   261,     0,     0,     0,     0,     0,     0,   262,   263,
     264,   265,     0,     0,     0,   266,   267,   268,     0,   269,
     270,     0,   271,   272,     0,   273,     0,     0,    28,   274,
       0,     0,   275,   276,     0,     0,     0,     0,     0,   277,
     278,   279,   280,   281,   282,     0,     0,   283,     0,     0,
       0,   284,    33,   285,   286,    36,    37,   113,   287,    40,
      41,    42,   288,     0,   289,   290,   291,   725,     0,   205,
     206,     0,     0,     0,     0,   207,     0,   208,     0,     0,
       0,     0,     0,     0,     0,     0,   210,   211,   212,     0,
       0,     0,     0,     0,     0,   213,   214,     0,     0,     0,
       0,   215,   216,   217,   218,   219,   220,   221,     0,     0,
       0,     0,   222,   223,     0,     0,     0,     0,     0,     0,
     224,     0,     0,   227,     0,     0,     0,     0,   228,   229,
     230,   231,     0,     0,     0,   232,   233,     0,     0,     0,
       0,     0,   234,     0,     0,     0,     0,     0,   235,     0,
     236,     0,   237,     0,     0,     0,   239,     0,     0,     0,
     240,     0,   241,   242,     0,   243,     0,     0,     0,   245,
     246,   247,   248,   249,   250,     0,   251,     0,   252,     0,
     254,   255,   256,   257,     0,     0,   258,     0,     0,   259,
       0,   260,     0,     0,     0,   261,     0,     0,     0,     0,
       0,     0,     0,   263,   264,   265,     0,     0,     0,   266,
     267,   268,     0,   269,   270,     0,   271,   272,     0,   273,
       0,     0,    28,   274,     0,     0,   275,   276,     0,     0,
       0,     0,     0,   277,   278,     0,   280,   281,   282,     0,
       0,   283,     0,     0,     0,   284,    33,   285,    35,     0,
      37,   113,   287,    40,    41,    42,     0,     0,   289,   290,
     291,   812,     0,   205,   206,     0,     0,     0,     0,     1,
       0,     2,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   213,
     214,     0,     0,     0,     0,   215,   216,   217,   218,   219,
     220,   221,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   224,   225,   226,   227,     0,     0,
       0,     0,   228,   229,   230,     0,     0,     0,     0,   232,
     233,     0,     0,     0,     0,     0,   234,     0,     0,     0,
       0,     0,   235,     0,     0,     0,   237,     0,     0,     0,
       0,     0,     0,     0,   240,     0,   241,   242,     0,   243,
       0,   244,     0,   245,   246,   247,   248,   249,   250,     0,
     251,     0,     0,     0,     0,   255,     0,     0,     0,     0,
     258,     0,     0,   259,     0,   260,     0,     0,     0,   261,
       0,     0,     0,     0,     0,     0,   262,   263,   264,   265,
       0,     0,     0,   266,   267,   268,     0,   269,   270,     0,
     271,   272,     0,   273,     0,     0,     0,   274,     0,     0,
     275,   276,     0,     0,     0,     0,     0,   277,   278,   279,
       0,   281,   282,     0,     0,   283,     0,   424,     0,   205,
     206,     0,   813,    36,    37,     1,   427,     2,    41,    42,
     288,     0,   289,   290,   291,     0,     0,     0,     0,     0,
       0,     0,     0,   205,   206,   213,   214,     0,     0,     0,
       0,   215,   216,   217,   218,   219,   220,   221,     0,   588,
     210,   211,   212,   673,   361,   674,   675,   676,     0,     0,
     224,     0,     0,   227,     0,     0,     0,     0,   228,   229,
     230,     0,     0,     0,     0,   232,   233,     0,     0,     0,
       0,     0,   234,   589,     0,     0,     0,     0,   235,     0,
       0,     0,   237,   425,     0,     0,     0,     0,     0,     0,
     240,     0,   241,   242,     0,   243,     0,     0,     0,   245,
     246,   247,   248,   249,   250,     0,   251,     0,     0,     0,
       0,   255,   117,     0,   118,     0,   258,     0,     0,   259,
       0,   260,     0,     0,     0,   261,   120,     0,     0,     0,
       0,     0,   252,   263,   264,   265,     0,     0,     0,   266,
     267,   268,   124,   269,   270,     0,   271,   272,   125,   273,
       0,     0,     0,   274,     0,     0,   275,   276,     0,   517,
       0,     0,     0,   277,   278,     0,     0,   281,   282,   426,
       0,   283,     0,     0,     0,     0,   129,     0,     0,   131,
      37,     0,   427,   132,    41,    42,     0,     0,   289,   290,
     291,   424,   134,   205,   206,   639,     0,     0,   640,     1,
       0,     2,     0,   117,     0,   118,     0,     0,     0,     0,
       0,   137,     0,     0,     0,     0,   138,   120,     0,   213,
     214,     0,     0,     0,     0,   215,   216,   217,   218,   219,
     220,   221,     0,   124,     0,   141,     0,     0,     0,   125,
       0,     0,     0,     0,   224,     0,     0,   227,     0,     0,
       0,     0,   228,   229,   230,     0,     0,     0,     0,   232,
     233,     0,     0,     0,     0,     0,   234,   129,     0,     0,
     131,     0,   235,     0,   132,     0,   237,     0,     0,     0,
       0,     0,     0,   134,   240,     0,   241,   242,     0,   243,
       0,     0,     0,   245,   246,   247,   248,   249,   250,     0,
     251,     0,   137,     0,     0,   255,     0,   138,     0,     0,
     258,     0,     0,   259,     0,   260,     0,     0,     0,   261,
       0,     0,     0,     0,     0,     0,   141,   263,   264,   265,
       0,     0,     0,   266,   267,   268,     0,   269,   270,     0,
     271,   272,     0,   273,     0,     0,     0,   274,     0,     0,
     275,   276,     0,     0,     0,     0,     0,   277,   278,     0,
       0,   281,   282,     0,     0,   283,     0,   424,     0,   205,
     206,   524,     0,     0,    37,     1,   427,     2,    41,    42,
       0,     0,   289,   290,   291,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   213,   214,     0,     0,     0,
       0,   215,   216,   217,   218,   219,   220,   221,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     224,     0,     0,   227,     0,     0,     0,     0,   228,   229,
     230,     0,     0,     0,     0,   232,   233,     0,     0,     0,
       0,     0,   234,     0,     0,     0,     0,     0,   235,     0,
       0,     0,   237,     0,     0,     0,     0,     0,     0,     0,
     240,     0,   241,   242,     0,   243,     0,     0,     0,   245,
     246,   247,   248,   249,   250,     0,   251,     0,     0,     0,
       0,   255,     0,     0,     0,     0,   258,     0,     0,   259,
       0,   260,     0,     0,     0,   261,     0,     0,     0,     0,
       0,     0,     0,   263,   264,   265,     0,     0,     0,   266,
     267,   268,     0,   269,   270,     0,   271,   272,     0,   273,
       0,     0,     0,   274,     0,     0,   275,   276,     0,     0,
       0,     0,     0,   277,   278,     0,     0,   281,   282,     0,
       0,   283,     0,     0,     0,     0,     0,     0,     0,     0,
      37,     0,   427,     0,    41,    42,     0,     0,   289,   290,
     291,   424,     0,   205,   206,     0,     0,     0,   640,     1,
       0,     2,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   213,
     214,     0,     0,     0,     0,   215,   216,   217,   218,   219,
     220,   221,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   224,     0,     0,   227,     0,     0,
       0,     0,   228,   229,   230,     0,     0,     0,     0,   232,
     233,     0,     0,     0,     0,     0,   234,     0,     0,     0,
       0,     0,   235,     0,     0,     0,   237,     0,     0,     0,
       0,     0,     0,     0,   240,     0,   241,   242,     0,   243,
       0,     0,     0,   245,   246,   247,   248,   249,   250,     0,
     251,     0,     0,     0,     0,   255,     0,     0,     0,     0,
     258,     0,     0,   259,     0,   260,     0,     0,     0,   261,
       0,     0,     0,     0,     0,     0,     0,   263,   264,   265,
       0,     0,     0,   266,   267,   268,     0,   269,   270,     0,
     271,   272,     0,   273,     0,     0,     0,   274,     0,     0,
     275,   276,     0,     0,     0,     0,     0,   277,   278,     0,
       0,   281,   282,     0,     0,   283,     0,   424,     0,   205,
     206,     0,     0,     0,    37,     1,   427,     2,    41,    42,
       0,     0,   289,   290,   291,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   213,   214,     0,     0,     0,
       0,   215,   216,   217,   218,   219,   220,   221,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     224,     0,     0,   227,     0,     0,     0,     0,   228,   229,
     230,     0,     0,     0,     0,   232,   233,     0,     0,     0,
       0,     0,   234,     0,     0,     0,     0,     0,   235,     0,
       0,     0,   237,     0,     0,     0,     0,     0,     0,     0,
     240,     0,   241,   242,     0,   243,     0,     0,     0,   245,
     246,   247,   248,   249,   250,     0,   251,     0,     0,     0,
       0,   255,     0,     0,     0,     0,   258,     0,     0,   259,
       0,   260,     0,     0,     0,   261,     0,     0,     0,     0,
       0,     0,     0,   263,   264,   265,     0,     0,     0,   266,
     267,   268,     0,   269,   270,     0,   271,   272,     0,   273,
       0,     0,     0,   274,     0,     0,   275,   276,     0,     0,
       0,     0,     0,   277,   278,   424,     0,   281,   282,   596,
     597,   283,     0,     1,     0,     2,     0,     0,     0,     0,
      37,     0,   427,     0,    41,    42,     0,     0,   289,   290,
     291,     0,     0,   213,   214,     0,     0,     0,     0,   215,
     216,   217,   218,   219,   220,   221,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   224,     0,
       0,   227,     0,     0,     0,     0,   228,   229,   230,     0,
       0,     0,     0,   232,   233,     0,     0,     0,     0,     0,
     234,     0,     0,     0,     0,     0,   235,     0,     0,     0,
     237,     0,     0,     0,     0,     0,     0,     0,   240,     0,
     241,   242,     0,   243,     0,     0,     0,   245,   246,   247,
     248,   249,   250,     0,   251,     0,     0,     0,     0,   255,
       0,     0,     0,     0,   258,     0,     0,   259,     0,   260,
       0,     0,     0,   261,     0,     0,     0,     0,     0,     0,
       0,   263,   264,   265,     0,     0,     0,   266,   267,   268,
       0,   269,   270,     0,   271,   272,     0,   273,     0,     0,
       0,   274,     0,     0,   275,   276,     0,     0,     0,     0,
       0,   277,   278,   424,     0,   281,   282,     0,     0,   283,
       0,     1,     0,     2,     0,     0,     0,     0,    37,     0,
     427,     0,    41,    42,     0,     0,   289,   290,   291,     0,
       0,   213,   214,     0,     0,     0,     0,   215,   216,   217,
     218,   219,   220,   221,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   224,     0,     0,   227,
       0,     0,     0,     0,   228,   229,   230,     0,     0,     0,
       0,   232,   233,     0,     0,     0,     0,     0,   234,     0,
       0,     0,     0,     0,   235,     0,     0,     0,   237,     0,
       0,     0,     0,     0,     0,     0,   240,     0,   241,   242,
       0,   243,     0,     0,     0,   245,   246,   247,   248,   249,
     250,     0,   251,     0,     0,     0,     0,   255,     0,     0,
       0,     0,   258,     0,     0,   259,     0,   260,     0,     0,
       0,   261,     0,     0,     0,     0,     0,     0,     0,   263,
     264,   265,     0,     0,     0,   266,   267,   268,   777,   269,
     270,     0,   271,   272,     0,   273,     1,     0,     2,   274,
       0,     0,   275,   276,     0,     0,     0,     0,     0,   277,
     278,     0,     0,   281,   282,     0,     0,   283,     0,     0,
       0,     0,     0,     0,     0,     0,    37,     0,   427,     0,
      41,    42,     0,   222,   289,   290,   291,     0,   614,     0,
       0,     0,   225,     0,     0,     0,   615,     0,   616,     0,
       0,     0,   231,     0,     0,     0,     0,   210,   211,   212,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   236,   614,     0,     0,     0,     0,   239,     0,     0,
     615,     0,   616,   222,   223,     0,     0,     0,     0,     0,
       0,   210,   211,   212,     0,     0,    14,     0,     0,     0,
       0,   254,   231,   256,   257,   709,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   222,   223,     0,
     614,   236,     0,     0,     0,     0,     0,   239,   615,     0,
     616,     0,     0,     0,     0,     0,   231,     0,     0,     0,
       0,     0,     0,    28,     0,     0,     0,     0,     0,   252,
       0,   254,     0,   256,   257,   236,     0,   280,     0,     0,
       0,   239,     0,     0,     0,   222,   223,    33,     0,     0,
      36,    37,     0,     0,    40,    41,    42,   288,     0,   289,
     290,   291,     0,   252,   231,   254,     0,   256,   257,     0,
       0,     0,     0,    28,     0,     0,     0,     0,   683,     0,
       0,     0,     0,   236,     0,     0,   615,   280,   616,   239,
       0,     0,     0,     0,     0,     0,   284,    33,   285,    35,
       0,    37,   113,    39,    40,     0,     0,    28,     0,     0,
       0,     0,     0,   254,     0,   256,   257,     0,     0,     0,
       1,   280,     2,   222,   223,     0,     0,     0,     0,     0,
     284,    33,   285,    35,     0,    37,   113,    39,    40,     0,
       0,     0,   231,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    28,     0,   222,     0,     0,
       0,   236,     0,     0,     0,     0,   225,   239,   227,   280,
       0,     0,     0,     0,     0,   230,   231,     0,   284,    33,
     285,    35,     0,    37,   113,    39,    40,   234,     0,     0,
       0,   254,     0,   256,   257,   236,     0,     0,     0,     0,
       0,   239,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      14,     0,     0,     0,     0,   254,     0,   256,   257,     0,
       0,   258,     0,    28,     0,     0,   260,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   280,     0,   264,
       0,     0,     0,     0,     0,     0,   284,    33,   285,    35,
       0,    37,   113,    39,    40,     0,     1,    28,     2,     0,
       0,     0,     3,     0,     0,     0,     0,     0,     0,     0,
       0,   280,     0,     0,     0,     4,     0,     0,     0,     0,
       0,    33,    34,    35,    36,    37,   113,    39,    40,    41,
      42,   288,     0,   289,   290,   291,     0,     5,     6,     0,
       0,     0,     0,     0,     0,   464,     0,     0,     0,     0,
       0,     0,     0,     7,     0,     0,     0,     0,     8,     0,
       0,     0,   465,     0,     0,     0,     0,     0,     9,     0,
       0,     0,    10,     0,     0,    11,    12,     0,    13,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    14,     0,     0,     0,
       0,     0,     0,    15,    16,     0,     0,     0,     0,     0,
       0,     0,     0,    17,    18,     0,     0,     0,    19,    20,
      21,    22,     0,     0,     0,     0,     0,    23,    24,    25,
       0,     0,     0,    26,     0,     0,     0,     0,     1,     0,
       2,     0,    27,    28,     3,     0,     0,     0,     0,     0,
       0,    29,     0,     0,     0,     0,     0,     4,     0,     0,
       0,    30,     0,    31,     0,    32,     0,    33,    34,    35,
      36,    37,    38,    39,    40,    41,    42,     0,     0,     5,
       6,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     7,     0,     0,     0,     0,
       8,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       9,     0,     0,     0,    10,     0,     0,    11,    12,     0,
      13,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    14,     0,
       0,     0,     0,     0,     0,    15,    16,     0,     0,     0,
       0,     0,     0,     0,     0,    17,    18,     0,     0,     0,
      19,    20,    21,    22,     0,     0,     0,     0,     0,    23,
      24,    25,     0,     0,     0,    26,     0,     0,     0,     0,
       1,     0,     2,     0,    27,    28,     3,     0,     0,     0,
       0,     0,     0,    29,     0,     0,     0,     0,     0,     4,
       0,     0,     0,    30,     0,    31,     0,    32,     0,    33,
      34,    35,    36,    37,    38,    39,    40,    41,    42,     0,
       0,     5,     6,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     8,     0,     0,   398,     0,     0,     0,     0,
       0,     0,     9,     0,     0,     0,    10,     0,     0,    11,
      12,     0,    13,     0,     0,     0,     1,     0,     2,     0,
       0,     0,     3,     0,     0,     0,     0,     0,     0,     0,
      14,     0,     0,     0,     0,     4,     0,    15,    16,     0,
       0,     0,     0,     0,     0,     0,     0,    17,    18,     0,
       0,     0,    19,     0,    21,    22,     0,     5,     6,     0,
       0,    23,    24,    25,     0,     0,     0,    26,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    28,     8,     0,
       0,   398,     0,     0,   399,    29,     0,     0,     9,     0,
     389,     0,    10,     0,     0,    30,    12,    31,    13,    32,
       0,    33,    34,    35,    36,    37,    38,    39,    40,    41,
      42,     0,     0,     0,     0,     0,    14,     0,     0,     0,
       0,     0,     0,    15,    16,     0,     0,     0,     0,     0,
       0,     0,     0,    17,    18,     0,     0,     1,    19,     2,
      21,    22,     0,     3,     0,     0,     0,    23,    24,    25,
       0,     0,     0,    26,     0,     0,     4,     0,     0,     0,
       0,     0,     0,    28,     0,     0,     0,     0,     0,   390,
       0,    29,     0,     0,     0,     0,     0,     0,     5,     6,
       0,   391,     0,    31,     0,    32,   464,    33,    34,    35,
      36,    37,   113,    39,    40,    41,    42,     0,     0,     8,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     9,
       0,   389,     0,    10,     0,     0,     0,    12,     0,    13,
       0,     0,     0,     1,     0,     2,     0,     0,     0,     3,
       0,     0,     0,     0,     0,     0,     0,    14,     0,     0,
       0,     0,     4,     0,    15,    16,     0,     0,     0,     0,
       0,     0,     0,     0,    17,    18,     0,     0,     0,    19,
       0,    21,    22,     0,     5,     6,     0,     0,    23,    24,
      25,     0,     0,     0,    26,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    28,     8,     0,     0,     0,     0,
     390,     0,    29,     0,     0,     9,     0,   389,     0,    10,
       0,     0,   391,    12,    31,    13,    32,     0,    33,    34,
      35,    36,    37,   113,    39,    40,    41,    42,     0,     0,
       0,     0,     0,    14,     0,     0,     0,     0,     0,     0,
      15,    16,     0,     0,     0,     0,     0,     0,     0,     0,
      17,    18,     0,     0,     1,    19,     2,    21,    22,     0,
       3,     0,     0,     0,    23,    24,    25,     0,     0,     0,
      26,     0,     0,     4,     0,     0,     0,     0,     0,     0,
      28,     0,     0,     0,     0,     0,   390,     0,    29,     0,
       0,     0,     0,     0,     0,     5,     6,     0,   391,     0,
      31,     0,    32,   464,    33,    34,    35,    36,    37,   113,
      39,    40,    41,    42,     0,     0,     8,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     9,     0,     0,     0,
      10,     0,     0,    11,    12,     0,    13,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    14,     0,     0,     0,     0,     0,
       0,    15,    16,     0,     0,     0,     0,     0,     0,     0,
       0,    17,    18,     0,     0,     1,    19,     2,    21,    22,
       0,     3,     0,     0,     0,    23,    24,    25,     0,     0,
       0,    26,     0,     0,     4,     0,     0,     0,     0,     0,
       0,    28,     0,     0,     0,     0,     0,     0,     0,    29,
       0,     0,     0,     0,     0,     0,     5,     6,     0,    30,
       0,    31,     0,    32,     0,    33,    34,    35,    36,    37,
      38,    39,    40,    41,    42,     0,     0,     8,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     9,     0,     0,
       0,    10,     0,     0,    11,    12,     0,    13,     0,     0,
       0,     1,     0,     2,     0,     0,     0,     3,     0,     0,
       0,     0,     0,     0,     0,    14,     0,     0,     0,     0,
       4,     0,    15,    16,     0,     0,     0,     0,     0,     0,
       0,     0,    17,    18,     0,     0,     0,    19,     0,    21,
      22,     0,     5,     6,     0,     0,    23,    24,    25,     0,
       0,     0,    26,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    28,     8,     0,     0,   398,     0,     0,     0,
      29,     0,     0,     9,     0,     0,     0,    10,     0,     0,
     369,    12,    31,    13,    32,     0,    33,    34,    35,    36,
      37,    38,    39,    40,    41,    42,     0,     0,     0,     0,
       0,    14,     0,     0,     0,     0,     0,     0,    15,    16,
       0,     0,     0,     0,     0,     0,     0,     0,    17,    18,
       0,     0,     1,    19,     2,    21,    22,     0,     3,     0,
       0,     0,    23,    24,    25,     0,     0,     0,    26,     0,
       0,     4,     0,     0,     0,     0,     0,     0,    28,     0,
       0,     0,     0,     0,     0,     0,    29,     0,     0,     0,
       0,     0,     0,     5,     6,     0,   369,     0,    31,     0,
      32,   464,    33,    34,    35,    36,    37,   113,    39,    40,
      41,    42,     0,     0,     8,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     9,     0,     0,     0,    10,     0,
       0,     0,    12,     0,    13,     0,     0,     0,     1,     0,
       2,     0,     0,     0,     3,     0,     0,     0,     1,     0,
       2,     0,    14,     0,     0,     0,     0,     4,     0,    15,
      16,     0,     0,     0,     0,     0,     0,     0,     0,    17,
      18,     0,     0,     0,    19,     0,    21,    22,     0,     5,
       6,     0,     0,    23,    24,    25,     0,     0,     0,    26,
       0,     0,     0,     0,     0,     0,   227,     0,     0,    28,
       8,     0,     0,   230,     0,     0,     0,    29,     0,     0,
       9,     0,     0,     0,    10,   234,     0,   369,    12,    31,
      13,    32,     0,    33,    34,    35,    36,    37,   113,    39,
      40,    41,    42,     0,     0,     0,     0,     0,    14,     0,
       0,     0,     0,     0,     0,    15,    16,     0,    14,     0,
       0,     0,     0,     0,     0,    17,    18,     0,     0,   258,
      19,     0,    21,    22,   260,     0,     0,     0,     0,    23,
      24,    25,     0,     0,     0,    26,     0,   264,     0,     0,
       0,     0,     0,     0,     0,    28,     0,     0,     0,     0,
       0,     0,     0,    29,     0,    28,     0,     0,     0,     0,
       0,     0,     0,   369,     0,    31,     0,    32,     0,    33,
      34,    35,    36,    37,   113,    39,    40,    41,    42,    33,
      34,    35,    36,    37,   113,    39,    40,    41,    42,   117,
       0,   118,     0,     0,     0,     0,     0,     0,     0,     0,
     119,     0,     0,   120,     0,   121,   122,     0,     0,     0,
       0,     0,     0,     0,   123,     0,     0,     0,     0,   124,
       0,     0,     0,     0,     0,   125,     0,     0,     0,     0,
     126,     0,     0,     0,     0,     0,   127,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   128,     0,     0,     0,
       0,     0,     0,   129,   130,     0,   131,     0,     0,     0,
     132,     0,   133,     0,     0,     0,     0,     0,     0,   134,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     135,     0,   136,     0,     0,     0,     0,     0,   137,   117,
       0,   118,     0,   138,     0,     0,     0,   139,     0,     0,
     119,     0,     0,   120,     0,   121,   122,   140,     0,     0,
       0,     0,   141,     0,   123,     0,     0,     0,     0,   124,
     142,     0,     0,     0,     0,   125,     0,     0,     0,     0,
     126,     0,     0,   143,     0,     0,   127,     0,    33,   144,
     145,    36,   146,   147,   148,   149,   128,    42,     0,     0,
       0,     0,     0,   129,   130,     0,   131,     0,     0,   117,
     132,   118,   133,     0,     0,     0,     0,     0,     0,   134,
       0,     0,     0,   120,     0,   121,   122,     0,     0,     0,
     135,     0,   136,     0,   123,     0,     0,     0,   137,   124,
       0,     0,     0,   138,     0,   125,     0,   139,     0,     0,
     126,     0,     0,     0,     0,     0,   127,   140,     0,     0,
       0,     0,   141,     0,     0,     0,     0,     0,     0,     0,
     142,     0,     0,   129,   130,     0,   131,     0,     0,     0,
     132,     0,   133,   143,     0,     0,     0,     0,     0,   134,
       0,     0,    37,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   137,     0,
       0,     0,     0,   138,     0,     0,     0,   139,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   140,     0,     0,
       0,     0,   141,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   143,     0,     0,     0,     0,     0,     0,
       0,     0,    37
};

static const yytype_int16 yycheck[] =
{
       0,    89,     2,    75,   181,     5,   319,     1,   156,   295,
     296,     7,     7,    48,    56,    11,   315,   383,   365,    61,
      97,    21,    22,    23,    89,    25,    26,   626,   514,    65,
      67,    27,   382,   377,    74,   379,   380,   381,    74,    81,
     166,     4,    77,    89,     7,   359,    89,     0,    48,    78,
      98,     5,   643,    86,    89,    22,    11,    20,   169,    67,
     394,    20,    20,    89,   189,    65,    66,    67,     5,    23,
      18,    22,    72,    77,    74,   149,    76,    77,    78,   378,
      93,    37,     7,     4,    84,    22,   298,   845,    22,    89,
      90,    91,    97,    93,     7,    48,   170,     0,    11,    20,
      20,    97,     8,     9,   104,     0,   106,     5,   108,   109,
      20,    78,    65,    66,   713,    20,    36,    22,    93,    72,
      20,    74,    18,    76,    77,    24,    24,   194,    84,   104,
      84,   106,    28,   108,   109,    89,    89,    90,    91,     0,
      93,     8,     9,   629,   181,     5,     5,    57,    48,    97,
     154,   104,    73,   106,    85,   108,   109,   153,   163,    58,
      58,   187,    22,    22,   160,     6,     4,   204,   168,     0,
     196,   197,   123,   181,   169,   933,   189,   190,   178,     6,
       6,   181,    92,    67,    97,     6,   123,    54,    91,   123,
      21,    29,   973,    20,    25,    26,    91,   374,   548,    20,
      71,   168,   133,   984,   204,    11,   169,   207,   208,    80,
      20,   969,    18,   207,    20,   163,   165,    48,   123,   178,
     140,    48,    48,   182,   571,     4,     0,   171,   186,   187,
      91,   342,   190,   191,    65,    66,   170,     8,     9,   592,
     153,    72,   238,    74,   169,    76,    77,   160,   189,    82,
      29,   192,   586,    24,   207,   208,   847,   178,    89,    90,
      91,   182,    93,   123,   123,   171,   137,   341,   178,   603,
     623,   359,   182,   104,    82,   106,    51,   108,   109,   626,
       8,     9,     6,   238,    65,    13,   313,    58,   622,   160,
     624,    65,    66,     8,     9,    70,    24,   181,    72,   326,
      74,   900,    76,     6,   590,   591,    65,    66,   126,   595,
       4,   625,    93,    72,   613,   315,    90,    91,   344,   345,
      95,    20,   672,   323,   359,   360,    20,   671,    82,   364,
      58,    90,   372,   932,    49,    23,   372,   374,     6,    49,
      39,     4,     5,   343,   119,   345,   127,   342,   129,    11,
     377,    39,   379,   839,   840,    17,   323,    20,    21,   359,
     360,   401,   362,   363,   364,   401,   374,   367,     6,   365,
     365,   365,   372,     0,   374,     6,   186,   187,   378,   342,
     190,   191,     0,   418,   596,   597,    18,    18,    98,   343,
      11,   420,   518,     4,   394,   362,    11,    18,    67,     4,
     367,   401,    17,   399,   399,   359,   359,   360,   441,    20,
     487,   364,   122,   539,    21,    20,   126,   342,   418,   372,
     420,    48,   422,     6,   138,   425,    18,   467,    20,     6,
      14,   467,    16,   147,    20,   435,   399,   151,    65,    66,
     365,   489,   516,   517,   444,    72,     4,    74,   401,    76,
      77,    29,   189,   420,    11,   422,   193,   194,    76,     4,
       4,    18,    89,    90,    91,   418,    93,   467,     5,   469,
     535,     8,     9,    91,   399,    20,    20,   104,    20,   106,
     827,   108,   109,    11,     8,     9,   399,    24,    20,   535,
     374,   487,   535,    15,   469,   495,    20,   497,    11,   499,
     535,   501,     6,   545,   630,    18,   683,   503,     6,   535,
     506,   877,   181,   104,   467,   106,   469,   108,   109,   869,
     495,    58,   497,     6,   499,   520,   501,   826,   359,   360,
     185,     6,   876,   364,   189,   535,   536,   625,     8,     9,
       6,   372,   495,    13,   497,     6,   499,   574,   501,     8,
       9,   178,     6,   900,    24,     8,     9,   520,   584,   508,
     509,    20,     6,   512,   513,   851,   852,    20,     6,   536,
     401,     8,     9,     5,   487,   571,     8,     9,     9,     8,
       9,   544,   535,    20,   168,    20,   586,   418,    58,    22,
     625,    20,   592,   542,   620,   520,   186,   187,   372,   189,
     190,   191,   127,   603,   612,   189,   569,     4,   608,   193,
     194,   653,   612,   613,   614,   615,   616,   930,    28,    29,
      30,   114,   622,   623,   624,   625,     4,   401,   193,   194,
     626,   626,   626,    11,    67,   677,   467,     4,   469,    67,
      18,   767,   768,     9,   671,    78,   683,   684,    20,   178,
     687,    29,   689,   182,     6,   695,   114,   692,    20,   695,
     118,    20,   615,   616,   495,   360,   497,    20,   499,   364,
     501,   625,   625,     5,   682,   683,     8,     9,     0,   687,
      20,   689,   682,   683,   684,    20,   686,   687,    18,   689,
      20,    20,   692,   467,   734,   695,     5,   845,   734,     8,
       9,   626,   197,   198,   535,   374,   375,    20,   377,    54,
     379,   380,   381,    11,   714,     4,     5,   713,   345,   713,
       5,     8,     9,     8,     9,   725,    48,     6,     6,     6,
       0,     6,   359,   360,   734,   168,    14,   364,    16,   692,
       4,     5,   695,    65,    66,   372,   171,     6,   181,     6,
      72,     6,    74,   181,    76,    77,     4,     5,     4,     5,
     714,   186,   187,     6,   189,   190,   191,    89,    90,    91,
     733,    93,     4,     5,   401,   812,   204,     7,    48,     4,
       5,   734,   104,    12,   106,   933,   108,   109,     4,     5,
     786,   418,   786,     6,   625,    65,    66,   824,    18,   683,
     195,   685,    72,   687,    74,   689,    76,    77,   880,   805,
     186,   187,   812,     5,   190,   191,     8,     9,    20,    89,
      90,    91,     6,    93,   186,   187,   826,   189,   190,   191,
       6,   827,     6,    19,   104,     6,   106,     5,   108,   109,
     467,   868,   469,     5,   871,     6,     8,     9,     6,   876,
      78,   469,     6,    67,   854,    20,   856,   857,   185,     4,
       5,   692,   189,     6,   695,    51,   193,   194,   495,    83,
     497,     6,   499,     6,   501,     4,     5,   495,     6,   497,
     805,   499,     5,   501,    70,     8,     9,   854,     6,   856,
     323,    77,    11,    24,    25,    26,    27,    28,    29,    30,
      31,    32,   827,   734,   900,   136,   900,    20,   535,    95,
       5,   189,    20,     8,     9,   193,   194,     4,     5,   197,
     198,   695,    88,   958,     4,     5,    14,    58,    16,   362,
     363,   966,    20,   119,   367,    20,   932,   932,   932,     4,
       5,   374,   977,   157,   613,     5,   374,     6,     8,     9,
      20,   165,     5,    20,   168,     8,     9,    48,   958,    20,
     734,   394,   925,   177,     4,     5,   966,   181,   154,    20,
     184,     4,     5,     4,     5,   900,    64,   977,     4,     5,
     197,    20,     5,     5,    11,     6,   117,   420,   160,   422,
     204,    20,     4,   196,     5,    20,    20,   425,   625,     5,
      15,   670,   671,    11,    11,   958,     6,   435,    17,    11,
       5,   171,     5,   966,   683,    18,   444,   105,   687,    20,
     689,    19,   171,     5,   977,     5,   114,    11,    20,    20,
      20,    52,    53,    20,    20,    20,   124,   359,   360,    22,
      61,    20,   364,    20,    20,    20,    20,     5,     0,     5,
     372,   185,     5,     4,   188,   189,    77,     9,   192,   193,
     194,   198,    83,     6,    14,   692,    16,    19,   695,   157,
       5,     5,    29,   161,    78,     6,   164,    19,    11,   401,
     101,     5,     5,     5,    67,   171,     5,    19,   109,   359,
     360,     6,    20,    19,   364,    78,   418,   185,     5,    20,
     188,   189,   372,   536,   192,   193,   194,   734,    19,   399,
      20,   160,   185,    65,    66,   188,   189,   153,   191,   192,
      72,   194,    74,   144,    76,   774,   520,   958,   600,   608,
     857,   401,   301,   154,   348,   966,   226,   382,    90,    91,
     687,    93,   977,   689,   418,   467,   977,   469,   418,   363,
     362,    76,   104,   586,   106,   420,   108,   109,   441,   180,
     374,   388,   535,   183,   114,   536,    11,    45,   189,    11,
     603,    49,    50,   495,    52,   497,    54,   499,    11,   501,
     394,   491,    14,    -1,    16,   168,   614,    -1,   470,   622,
      -1,   624,    -1,    -1,    -1,    -1,    -1,   467,   181,   469,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   876,    -1,   423,
     424,   161,   426,   535,    -1,    -1,    -1,    -1,    -1,   433,
     434,   204,    -1,    -1,    -1,   495,    -1,   497,    -1,   499,
     444,   501,    64,    -1,    20,   185,    -1,   115,   188,   189,
      -1,   193,   192,   193,   194,    -1,    -1,    -1,    -1,    -1,
     683,    -1,   685,    -1,   687,   683,   689,    25,    26,    27,
      28,    29,    30,    31,    32,   535,    52,    53,    -1,    -1,
      62,    -1,    -1,   105,    -1,    61,    -1,    69,    -1,   185,
     186,   187,   114,   189,   190,   191,   192,    -1,    -1,    81,
      -1,    77,   124,    -1,   508,   509,    -1,   725,   512,   513,
      -1,    62,    -1,   625,    -1,   293,    -1,    -1,    69,    -1,
      -1,    -1,    -1,    -1,    -1,   101,   194,   195,    -1,    -1,
      81,    -1,   536,   109,    -1,   157,    -1,    -1,   542,   161,
      -1,   958,   164,   125,    -1,    -1,    -1,    -1,   130,   966,
     323,    -1,    -1,    -1,    -1,   223,    -1,    -1,   226,   117,
     977,   143,    -1,   185,    -1,   625,   188,   189,   144,    -1,
     192,   193,   194,    -1,   125,    -1,    -1,    -1,   154,   130,
     692,    -1,   586,   695,    -1,    -1,    -1,    -1,   592,   362,
     363,    -1,   143,    -1,   367,    -1,    -1,   375,    -1,   603,
       0,   374,    -1,    -1,   180,    -1,   188,   189,    -1,    -1,
      -1,   193,   194,   189,    -1,    -1,    -1,    -1,   622,   623,
     624,   394,   734,   293,   292,    -1,    -1,    -1,    -1,   633,
     372,   854,   692,   856,   857,   695,    -1,    -1,   189,   643,
      -1,   309,   193,   194,    -1,    -1,    -1,   420,    -1,   422,
     428,    -1,    -1,    -1,    -1,    -1,   398,    -1,    -1,   401,
      -1,    -1,    -1,    -1,    -1,    65,    66,    67,    -1,    -1,
     338,    -1,    72,    -1,   734,   679,    76,    -1,    -1,   683,
     684,    -1,    -1,   687,    -1,   689,    -1,    -1,    -1,    -1,
      90,    91,    -1,    93,   698,   699,   700,   701,   702,    -1,
      -1,    -1,    -1,    -1,   104,   375,   106,    -1,   108,   109,
      -1,    -1,    -1,    -1,     5,   719,    -1,     8,     9,   723,
     724,   725,   464,    -1,    -1,   467,    -1,   469,    -1,    -1,
      -1,    -1,    -1,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    -1,    -1,    -1,    -1,    -1,   525,    14,    -1,
      16,    -1,    -1,   495,   532,   497,    -1,   499,   428,   501,
      -1,    -1,    -1,   536,   506,   543,    -1,    58,    52,    53,
      -1,    -1,    -1,    -1,   552,    -1,    -1,    61,    -1,    -1,
      -1,   181,    -1,    -1,   788,    -1,   790,    -1,    -1,    -1,
      -1,    -1,    -1,    77,   572,    -1,    62,    -1,    -1,    83,
      -1,    -1,    -1,    69,    -1,    -1,    -1,    -1,   812,    -1,
      -1,    -1,    -1,   586,    -1,    81,    -1,   101,    -1,   592,
      -1,    -1,    -1,    -1,    -1,   109,   117,    -1,    -1,    -1,
     603,    -1,    -1,    -1,   502,    -1,   504,    -1,    -1,   843,
      -1,    -1,   846,   847,    -1,    -1,   958,    -1,   114,   622,
     623,   624,   118,   857,   966,   525,    -1,    -1,    -1,   125,
     144,    -1,   532,   641,   130,   977,    -1,   645,    -1,    -1,
     154,    -1,    -1,   543,    -1,    -1,    -1,   143,    62,   657,
      -1,    -1,   552,    -1,   626,    69,    -1,    -1,    -1,    -1,
      -1,    -1,   670,    -1,    -1,   161,   180,    81,   958,    -1,
      -1,    -1,   572,    -1,    -1,   189,   966,    -1,    -1,    -1,
     683,   684,    -1,    -1,   687,    -1,   689,   977,    -1,   185,
     186,   187,   188,   189,   190,   191,   192,   193,   194,   707,
     708,    -1,    -1,   711,    -1,    21,    -1,    -1,   716,   717,
      -1,   125,    -1,    -1,    -1,    -1,   130,    -1,   726,    -1,
      36,    -1,    38,   695,    -1,    -1,    -1,    -1,    -1,   143,
      -1,    -1,    -1,   967,    50,    -1,    -1,    -1,    -1,    -1,
      -1,   641,    -1,    -1,   374,   645,    -1,    -1,    -1,    -1,
      66,    -1,   986,    -1,    -1,    -1,    72,   657,    -1,    -1,
      -1,    -1,   734,    -1,    -1,   663,   664,   665,   666,    -1,
     670,   185,   186,   187,   188,   189,   190,   191,   192,   193,
     194,    -1,    -1,    -1,   100,    -1,    -1,   103,    -1,    -1,
      -1,   107,   185,   186,   187,   188,   189,   190,   191,   192,
     116,   194,    -1,    -1,    -1,    -1,   814,   707,   708,   812,
      -1,   711,    -1,    -1,    -1,    21,   716,   717,    -1,   135,
      -1,    -1,    -1,   831,   140,    -1,   726,    -1,    -1,    -1,
      36,    -1,    38,    -1,   842,    -1,    -1,    -1,    -1,   469,
     848,    -1,    -1,   159,    50,    -1,    -1,    -1,    -1,    -1,
      -1,   854,    -1,   856,   857,   827,    -1,    -1,    -1,   867,
      66,    -1,   870,   761,    -1,   495,    72,   497,    -1,   499,
      -1,   501,    -1,    -1,    -1,    -1,    -1,   885,   886,   887,
     888,   889,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   897,
     898,   899,    -1,    -1,   100,    -1,    -1,   103,     5,    -1,
      -1,   107,    -1,    -1,    -1,    -1,   804,    -1,   806,    -1,
     116,    -1,    -1,    -1,   814,   923,   924,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    -1,    -1,   900,   135,
      -1,   831,    -1,    -1,   140,    -1,    -1,   945,   836,    -1,
       0,   949,   842,    -1,    -1,    -1,    -1,    -1,   848,    -1,
      -1,    58,    -1,   159,    14,    -1,    16,    -1,    -1,    -1,
      20,    -1,    -1,    -1,    -1,    -1,    -1,   867,    -1,    -1,
     870,    -1,    -1,    33,   982,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   990,    62,    -1,   885,   886,   887,   888,   889,
      69,    -1,    -1,    -1,    -1,    55,    56,   897,   898,   899,
      -1,    -1,    81,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     117,    71,    -1,    -1,    -1,    -1,    76,    -1,    -1,    -1,
      -1,    -1,    -1,   923,   924,    -1,    86,    -1,    -1,    -1,
      90,    -1,    -1,    93,    94,    -1,    96,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   945,   125,    -1,    -1,   949,
      -1,   130,    -1,   683,   114,    -1,   686,   687,    -1,   689,
      -1,   121,   122,    -1,   143,    -1,    -1,    -1,    -1,    -1,
      -1,   131,   132,    -1,    -1,    -1,   136,   137,   138,   139,
      -1,    -1,   982,    -1,    -1,   145,   146,   147,    -1,    -1,
     990,   151,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     160,   161,    -1,    -1,    -1,    -1,   185,   186,   187,   169,
     189,   190,   191,   192,   193,   194,    -1,    -1,    -1,   179,
      -1,   181,    -1,   183,    -1,   185,   186,   187,   188,   189,
     190,   191,   192,   193,   194,     6,    -1,     8,     9,    -1,
      -1,    -1,    -1,    14,    -1,    16,    -1,    -1,    -1,    20,
      -1,    -1,    -1,    -1,    25,    26,    27,    -1,    -1,    -1,
      -1,    -1,    -1,    34,    35,    -1,    -1,    -1,    -1,    40,
      41,    42,    43,    44,    45,    46,    -1,    -1,    -1,    -1,
      51,    52,    -1,    -1,    -1,    -1,    -1,    -1,    59,    60,
      61,    62,    -1,    64,    -1,    -1,    67,    68,    69,    70,
      -1,    -1,    -1,    74,    75,    -1,    -1,    -1,    -1,    -1,
      81,    -1,    -1,    -1,    -1,    -1,    87,    -1,    89,    -1,
      91,    -1,    93,    -1,    95,    -1,    -1,    -1,    99,    -1,
     101,   102,    -1,   104,   105,   106,    -1,   108,   109,   110,
     111,   112,   113,   114,   115,    -1,   117,   118,   119,   120,
     121,   122,    -1,   124,   125,    -1,    -1,   128,    -1,   130,
      -1,    -1,    -1,   134,    -1,    -1,    -1,    -1,    -1,    -1,
     141,   142,   143,   144,    -1,    -1,    -1,   148,   149,   150,
      -1,   152,   153,    -1,   155,   156,   157,   158,    -1,    -1,
     161,   162,    -1,   164,   165,   166,    -1,    -1,    -1,    -1,
      -1,   172,   173,   174,   175,   176,   177,    -1,    -1,   180,
      -1,    -1,    -1,   184,   185,   186,   187,   188,   189,   190,
     191,   192,   193,   194,   195,    -1,   197,   198,   199,     6,
      -1,     8,     9,    -1,    -1,    -1,    -1,    14,    -1,    16,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    25,    26,
      27,    -1,    -1,    -1,    -1,    -1,    -1,    34,    35,    -1,
      -1,    -1,    -1,    40,    41,    42,    43,    44,    45,    46,
      -1,    -1,    -1,    -1,    51,    52,    -1,    -1,    -1,    -1,
      -1,    -1,    59,    60,    61,    62,    -1,    64,    -1,    -1,
      67,    68,    69,    70,    -1,    -1,    -1,    74,    75,    -1,
      -1,    -1,    -1,    -1,    81,    -1,    -1,    -1,    -1,    -1,
      87,    -1,    89,    -1,    91,    -1,    93,    -1,    95,    -1,
      -1,    -1,    99,    -1,   101,   102,    -1,   104,   105,   106,
      -1,   108,   109,   110,   111,   112,   113,   114,   115,    -1,
     117,   118,   119,   120,   121,   122,    -1,   124,   125,    -1,
      -1,   128,    -1,   130,    -1,    -1,    -1,   134,    -1,    -1,
      -1,    -1,    -1,    -1,   141,   142,   143,   144,    -1,    -1,
      -1,   148,   149,   150,    -1,   152,   153,    -1,   155,   156,
     157,   158,    -1,    -1,   161,   162,    -1,   164,   165,   166,
      -1,    -1,    -1,    -1,    -1,   172,   173,   174,   175,   176,
     177,    -1,    -1,   180,    -1,    -1,    -1,   184,   185,   186,
     187,   188,   189,   190,   191,   192,   193,   194,   195,    -1,
     197,   198,   199,     6,    -1,     8,     9,    -1,    -1,    -1,
      -1,    14,    -1,    16,    -1,    -1,    -1,    20,    -1,    -1,
      -1,    -1,    25,    26,    27,    -1,    -1,    -1,    -1,    -1,
      -1,    34,    35,    -1,    -1,    -1,    -1,    40,    41,    42,
      43,    44,    45,    46,    -1,    -1,    -1,    -1,    51,    52,
      -1,    -1,    -1,    -1,    -1,    -1,    59,    60,    61,    62,
      -1,    -1,    -1,    -1,    67,    68,    69,    70,    -1,    -1,
      -1,    74,    75,    -1,    -1,    -1,    -1,    -1,    81,    -1,
      -1,    -1,    -1,    -1,    87,    -1,    89,    -1,    91,    -1,
      93,    -1,    95,    -1,    -1,    -1,    99,    -1,   101,   102,
      -1,   104,    -1,   106,    -1,   108,   109,   110,   111,   112,
     113,   114,   115,    -1,   117,   118,   119,   120,   121,   122,
      -1,    -1,   125,    -1,    -1,   128,    -1,   130,    -1,    -1,
      -1,   134,    -1,    -1,    -1,    -1,    -1,    -1,   141,   142,
     143,   144,    -1,    -1,    -1,   148,   149,   150,    -1,   152,
     153,    -1,   155,   156,    -1,   158,    -1,    -1,   161,   162,
      -1,    -1,   165,   166,    -1,    -1,    -1,    -1,    -1,   172,
     173,   174,   175,   176,   177,    -1,    -1,   180,    -1,    -1,
      -1,   184,   185,   186,   187,   188,   189,   190,   191,   192,
     193,   194,   195,    -1,   197,   198,   199,     6,    -1,     8,
       9,    10,    -1,    -1,    -1,    14,    -1,    16,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    25,    26,    27,    -1,
      -1,    -1,    -1,    -1,    -1,    34,    35,    -1,    -1,    -1,
      -1,    40,    41,    42,    43,    44,    45,    46,    -1,    -1,
      -1,    -1,    51,    52,    -1,    -1,    -1,    -1,    -1,    -1,
      59,    60,    61,    62,    -1,    -1,    -1,    -1,    67,    68,
      69,    70,    -1,    -1,    -1,    74,    75,    -1,    -1,    -1,
      -1,    -1,    81,    -1,    -1,    -1,    -1,    -1,    87,    -1,
      89,    -1,    91,    -1,    93,    -1,    95,    -1,    -1,    -1,
      99,    -1,   101,   102,    -1,   104,    -1,   106,    -1,   108,
     109,   110,   111,   112,   113,   114,   115,    -1,   117,   118,
     119,   120,   121,   122,    -1,    -1,   125,    -1,    -1,   128,
      -1,   130,    -1,    -1,    -1,   134,    -1,    -1,    -1,    -1,
      -1,    -1,   141,   142,   143,   144,    -1,    -1,    -1,   148,
     149,   150,    -1,   152,   153,    -1,   155,   156,    -1,   158,
      -1,    -1,   161,   162,    -1,    -1,   165,   166,    -1,    -1,
      -1,    -1,    -1,   172,   173,   174,   175,   176,   177,    -1,
      -1,   180,    -1,    -1,    -1,   184,   185,   186,   187,   188,
     189,   190,   191,   192,   193,   194,   195,    -1,   197,   198,
     199,     6,    -1,     8,     9,    -1,    -1,    -1,    -1,    14,
      -1,    16,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      25,    26,    27,    -1,    -1,    -1,    -1,    -1,    -1,    34,
      35,    -1,    -1,    -1,    -1,    40,    41,    42,    43,    44,
      45,    46,    -1,    -1,    -1,    -1,    51,    52,    -1,    -1,
      -1,    -1,    -1,    -1,    59,    60,    61,    62,    -1,    -1,
      -1,    -1,    67,    68,    69,    70,    -1,    -1,    -1,    74,
      75,    -1,    -1,    -1,    -1,    -1,    81,    -1,    -1,    -1,
      -1,    -1,    87,    -1,    89,    90,    91,    -1,    93,    -1,
      95,    -1,    -1,    -1,    99,    -1,   101,   102,    -1,   104,
      -1,   106,    -1,   108,   109,   110,   111,   112,   113,   114,
     115,    -1,   117,   118,   119,   120,   121,   122,    -1,    -1,
     125,    -1,    -1,   128,    -1,   130,    -1,    -1,    -1,   134,
      -1,    -1,    -1,    -1,    -1,    -1,   141,   142,   143,   144,
      -1,    -1,    -1,   148,   149,   150,    -1,   152,   153,    -1,
     155,   156,    -1,   158,    -1,    -1,   161,   162,    -1,    -1,
     165,   166,    -1,    -1,    -1,    -1,    -1,   172,   173,   174,
     175,   176,   177,    -1,    -1,   180,    -1,    -1,    -1,   184,
     185,   186,   187,   188,   189,   190,   191,   192,   193,   194,
     195,    -1,   197,   198,   199,     6,    -1,     8,     9,    -1,
      -1,    -1,    -1,    14,    -1,    16,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    25,    26,    27,    -1,    -1,    -1,
      -1,    -1,    -1,    34,    35,    -1,    -1,    -1,    -1,    40,
      41,    42,    43,    44,    45,    46,    -1,    -1,    -1,    -1,
      51,    52,    -1,    -1,    -1,    -1,    -1,    -1,    59,    60,
      61,    62,    -1,    -1,    -1,    -1,    67,    68,    69,    70,
      -1,    -1,    -1,    74,    75,    -1,    -1,    -1,    -1,    -1,
      81,    -1,    -1,    -1,    -1,    -1,    87,    -1,    89,    -1,
      91,    -1,    93,    -1,    95,    -1,    -1,    -1,    99,    -1,
     101,   102,    -1,   104,    -1,   106,    -1,   108,   109,   110,
     111,   112,   113,   114,   115,    -1,   117,   118,   119,   120,
     121,   122,    -1,    -1,   125,    -1,    -1,   128,    -1,   130,
      -1,    -1,    -1,   134,    -1,    -1,    -1,    -1,    -1,    -1,
     141,   142,   143,   144,    -1,    -1,    -1,   148,   149,   150,
      -1,   152,   153,    -1,   155,   156,    -1,   158,    -1,    -1,
     161,   162,    -1,    -1,   165,   166,    -1,    -1,    -1,    -1,
      -1,   172,   173,   174,   175,   176,   177,    -1,    -1,   180,
      -1,    -1,    -1,   184,   185,   186,   187,   188,   189,   190,
     191,   192,   193,   194,   195,    -1,   197,   198,   199,     6,
      -1,     8,     9,    -1,    -1,    -1,    -1,    14,    -1,    16,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    25,    26,
      27,    -1,    -1,    -1,    -1,    -1,    -1,    34,    35,    -1,
      -1,    -1,    -1,    40,    41,    42,    43,    44,    45,    46,
      -1,    -1,    -1,    -1,    51,    52,    -1,    -1,    -1,    -1,
      -1,    -1,    59,    60,    61,    62,    -1,    -1,    -1,    -1,
      67,    68,    69,    70,    -1,    -1,    -1,    74,    75,    -1,
      -1,    -1,    -1,    -1,    81,    -1,    -1,    -1,    -1,    -1,
      87,    -1,    89,    -1,    91,    -1,    93,    -1,    95,    -1,
      -1,    -1,    99,    -1,   101,   102,    -1,   104,    -1,   106,
      -1,   108,   109,   110,   111,   112,   113,   114,   115,    -1,
     117,   118,   119,   120,   121,   122,    -1,    -1,   125,    -1,
      -1,   128,    -1,   130,    -1,    -1,    -1,   134,    -1,    -1,
      -1,    -1,    -1,    -1,   141,   142,   143,   144,    -1,    -1,
      -1,   148,   149,   150,    -1,   152,   153,    -1,   155,   156,
      -1,   158,    -1,    -1,   161,   162,    -1,    -1,   165,   166,
      -1,    -1,    -1,    -1,    -1,   172,   173,   174,   175,   176,
     177,    -1,    -1,   180,    -1,    -1,    -1,   184,   185,   186,
     187,   188,   189,   190,   191,   192,   193,   194,   195,    -1,
     197,   198,   199,     6,    -1,     8,     9,    -1,    -1,    -1,
      -1,    14,    -1,    16,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    25,    26,    27,    -1,    -1,    -1,    -1,    -1,
      -1,    34,    35,    -1,    -1,    -1,    -1,    40,    41,    42,
      43,    44,    45,    46,    -1,    -1,    -1,    -1,    51,    52,
      -1,    -1,    -1,    -1,    -1,    -1,    59,    60,    61,    62,
      -1,    -1,    -1,    -1,    67,    68,    69,    70,    -1,    -1,
      -1,    74,    75,    -1,    -1,    -1,    -1,    -1,    81,    -1,
      -1,    -1,    -1,    -1,    87,    -1,    89,    -1,    91,    -1,
      -1,    -1,    95,    -1,    -1,    -1,    99,    -1,   101,   102,
      -1,   104,    -1,   106,    -1,   108,   109,   110,   111,   112,
     113,    -1,   115,    -1,   117,    -1,   119,   120,   121,   122,
      -1,    -1,   125,    -1,    -1,   128,    -1,   130,    -1,    -1,
      -1,   134,    -1,    -1,    -1,    -1,    -1,    -1,   141,   142,
     143,   144,    -1,    -1,    -1,   148,   149,   150,    -1,   152,
     153,    -1,   155,   156,    -1,   158,    -1,    -1,   161,   162,
      -1,    -1,   165,   166,    -1,    -1,    -1,    -1,    -1,   172,
     173,   174,   175,   176,   177,    -1,    -1,   180,    -1,    -1,
      -1,   184,   185,   186,   187,   188,   189,   190,   191,   192,
     193,   194,   195,    -1,   197,   198,   199,     6,    -1,     8,
       9,    -1,    -1,    -1,    -1,    14,    -1,    16,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    25,    26,    27,    -1,
      -1,    -1,    -1,    -1,    -1,    34,    35,    -1,    -1,    -1,
      -1,    40,    41,    42,    43,    44,    45,    46,    -1,    -1,
      -1,    -1,    51,    52,    -1,    -1,    -1,    -1,    -1,    -1,
      59,    -1,    -1,    62,    -1,    -1,    -1,    -1,    67,    68,
      69,    70,    -1,    -1,    -1,    74,    75,    -1,    -1,    -1,
      -1,    -1,    81,    -1,    -1,    -1,    -1,    -1,    87,    -1,
      89,    -1,    91,    -1,    -1,    -1,    95,    -1,    -1,    -1,
      99,    -1,   101,   102,    -1,   104,    -1,    -1,    -1,   108,
     109,   110,   111,   112,   113,    -1,   115,    -1,   117,    -1,
     119,   120,   121,   122,    -1,    -1,   125,    -1,    -1,   128,
      -1,   130,    -1,    -1,    -1,   134,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   142,   143,   144,    -1,    -1,    -1,   148,
     149,   150,    -1,   152,   153,    -1,   155,   156,    -1,   158,
      -1,    -1,   161,   162,    -1,    -1,   165,   166,    -1,    -1,
      -1,    -1,    -1,   172,   173,    -1,   175,   176,   177,    -1,
      -1,   180,    -1,    -1,    -1,   184,   185,   186,   187,    -1,
     189,   190,   191,   192,   193,   194,    -1,    -1,   197,   198,
     199,     6,    -1,     8,     9,    -1,    -1,    -1,    -1,    14,
      -1,    16,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    34,
      35,    -1,    -1,    -1,    -1,    40,    41,    42,    43,    44,
      45,    46,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    59,    60,    61,    62,    -1,    -1,
      -1,    -1,    67,    68,    69,    -1,    -1,    -1,    -1,    74,
      75,    -1,    -1,    -1,    -1,    -1,    81,    -1,    -1,    -1,
      -1,    -1,    87,    -1,    -1,    -1,    91,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    99,    -1,   101,   102,    -1,   104,
      -1,   106,    -1,   108,   109,   110,   111,   112,   113,    -1,
     115,    -1,    -1,    -1,    -1,   120,    -1,    -1,    -1,    -1,
     125,    -1,    -1,   128,    -1,   130,    -1,    -1,    -1,   134,
      -1,    -1,    -1,    -1,    -1,    -1,   141,   142,   143,   144,
      -1,    -1,    -1,   148,   149,   150,    -1,   152,   153,    -1,
     155,   156,    -1,   158,    -1,    -1,    -1,   162,    -1,    -1,
     165,   166,    -1,    -1,    -1,    -1,    -1,   172,   173,   174,
      -1,   176,   177,    -1,    -1,   180,    -1,     6,    -1,     8,
       9,    -1,   187,   188,   189,    14,   191,    16,   193,   194,
     195,    -1,   197,   198,   199,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,     8,     9,    34,    35,    -1,    -1,    -1,
      -1,    40,    41,    42,    43,    44,    45,    46,    -1,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    -1,    -1,
      59,    -1,    -1,    62,    -1,    -1,    -1,    -1,    67,    68,
      69,    -1,    -1,    -1,    -1,    74,    75,    -1,    -1,    -1,
      -1,    -1,    81,    58,    -1,    -1,    -1,    -1,    87,    -1,
      -1,    -1,    91,    92,    -1,    -1,    -1,    -1,    -1,    -1,
      99,    -1,   101,   102,    -1,   104,    -1,    -1,    -1,   108,
     109,   110,   111,   112,   113,    -1,   115,    -1,    -1,    -1,
      -1,   120,    36,    -1,    38,    -1,   125,    -1,    -1,   128,
      -1,   130,    -1,    -1,    -1,   134,    50,    -1,    -1,    -1,
      -1,    -1,   117,   142,   143,   144,    -1,    -1,    -1,   148,
     149,   150,    66,   152,   153,    -1,   155,   156,    72,   158,
      -1,    -1,    -1,   162,    -1,    -1,   165,   166,    -1,    83,
      -1,    -1,    -1,   172,   173,    -1,    -1,   176,   177,   178,
      -1,   180,    -1,    -1,    -1,    -1,   100,    -1,    -1,   103,
     189,    -1,   191,   107,   193,   194,    -1,    -1,   197,   198,
     199,     6,   116,     8,     9,    10,    -1,    -1,    13,    14,
      -1,    16,    -1,    36,    -1,    38,    -1,    -1,    -1,    -1,
      -1,   135,    -1,    -1,    -1,    -1,   140,    50,    -1,    34,
      35,    -1,    -1,    -1,    -1,    40,    41,    42,    43,    44,
      45,    46,    -1,    66,    -1,   159,    -1,    -1,    -1,    72,
      -1,    -1,    -1,    -1,    59,    -1,    -1,    62,    -1,    -1,
      -1,    -1,    67,    68,    69,    -1,    -1,    -1,    -1,    74,
      75,    -1,    -1,    -1,    -1,    -1,    81,   100,    -1,    -1,
     103,    -1,    87,    -1,   107,    -1,    91,    -1,    -1,    -1,
      -1,    -1,    -1,   116,    99,    -1,   101,   102,    -1,   104,
      -1,    -1,    -1,   108,   109,   110,   111,   112,   113,    -1,
     115,    -1,   135,    -1,    -1,   120,    -1,   140,    -1,    -1,
     125,    -1,    -1,   128,    -1,   130,    -1,    -1,    -1,   134,
      -1,    -1,    -1,    -1,    -1,    -1,   159,   142,   143,   144,
      -1,    -1,    -1,   148,   149,   150,    -1,   152,   153,    -1,
     155,   156,    -1,   158,    -1,    -1,    -1,   162,    -1,    -1,
     165,   166,    -1,    -1,    -1,    -1,    -1,   172,   173,    -1,
      -1,   176,   177,    -1,    -1,   180,    -1,     6,    -1,     8,
       9,    10,    -1,    -1,   189,    14,   191,    16,   193,   194,
      -1,    -1,   197,   198,   199,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    34,    35,    -1,    -1,    -1,
      -1,    40,    41,    42,    43,    44,    45,    46,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      59,    -1,    -1,    62,    -1,    -1,    -1,    -1,    67,    68,
      69,    -1,    -1,    -1,    -1,    74,    75,    -1,    -1,    -1,
      -1,    -1,    81,    -1,    -1,    -1,    -1,    -1,    87,    -1,
      -1,    -1,    91,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      99,    -1,   101,   102,    -1,   104,    -1,    -1,    -1,   108,
     109,   110,   111,   112,   113,    -1,   115,    -1,    -1,    -1,
      -1,   120,    -1,    -1,    -1,    -1,   125,    -1,    -1,   128,
      -1,   130,    -1,    -1,    -1,   134,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   142,   143,   144,    -1,    -1,    -1,   148,
     149,   150,    -1,   152,   153,    -1,   155,   156,    -1,   158,
      -1,    -1,    -1,   162,    -1,    -1,   165,   166,    -1,    -1,
      -1,    -1,    -1,   172,   173,    -1,    -1,   176,   177,    -1,
      -1,   180,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     189,    -1,   191,    -1,   193,   194,    -1,    -1,   197,   198,
     199,     6,    -1,     8,     9,    -1,    -1,    -1,    13,    14,
      -1,    16,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    34,
      35,    -1,    -1,    -1,    -1,    40,    41,    42,    43,    44,
      45,    46,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    59,    -1,    -1,    62,    -1,    -1,
      -1,    -1,    67,    68,    69,    -1,    -1,    -1,    -1,    74,
      75,    -1,    -1,    -1,    -1,    -1,    81,    -1,    -1,    -1,
      -1,    -1,    87,    -1,    -1,    -1,    91,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    99,    -1,   101,   102,    -1,   104,
      -1,    -1,    -1,   108,   109,   110,   111,   112,   113,    -1,
     115,    -1,    -1,    -1,    -1,   120,    -1,    -1,    -1,    -1,
     125,    -1,    -1,   128,    -1,   130,    -1,    -1,    -1,   134,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   142,   143,   144,
      -1,    -1,    -1,   148,   149,   150,    -1,   152,   153,    -1,
     155,   156,    -1,   158,    -1,    -1,    -1,   162,    -1,    -1,
     165,   166,    -1,    -1,    -1,    -1,    -1,   172,   173,    -1,
      -1,   176,   177,    -1,    -1,   180,    -1,     6,    -1,     8,
       9,    -1,    -1,    -1,   189,    14,   191,    16,   193,   194,
      -1,    -1,   197,   198,   199,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    34,    35,    -1,    -1,    -1,
      -1,    40,    41,    42,    43,    44,    45,    46,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      59,    -1,    -1,    62,    -1,    -1,    -1,    -1,    67,    68,
      69,    -1,    -1,    -1,    -1,    74,    75,    -1,    -1,    -1,
      -1,    -1,    81,    -1,    -1,    -1,    -1,    -1,    87,    -1,
      -1,    -1,    91,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      99,    -1,   101,   102,    -1,   104,    -1,    -1,    -1,   108,
     109,   110,   111,   112,   113,    -1,   115,    -1,    -1,    -1,
      -1,   120,    -1,    -1,    -1,    -1,   125,    -1,    -1,   128,
      -1,   130,    -1,    -1,    -1,   134,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   142,   143,   144,    -1,    -1,    -1,   148,
     149,   150,    -1,   152,   153,    -1,   155,   156,    -1,   158,
      -1,    -1,    -1,   162,    -1,    -1,   165,   166,    -1,    -1,
      -1,    -1,    -1,   172,   173,     6,    -1,   176,   177,    10,
      11,   180,    -1,    14,    -1,    16,    -1,    -1,    -1,    -1,
     189,    -1,   191,    -1,   193,   194,    -1,    -1,   197,   198,
     199,    -1,    -1,    34,    35,    -1,    -1,    -1,    -1,    40,
      41,    42,    43,    44,    45,    46,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    59,    -1,
      -1,    62,    -1,    -1,    -1,    -1,    67,    68,    69,    -1,
      -1,    -1,    -1,    74,    75,    -1,    -1,    -1,    -1,    -1,
      81,    -1,    -1,    -1,    -1,    -1,    87,    -1,    -1,    -1,
      91,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    99,    -1,
     101,   102,    -1,   104,    -1,    -1,    -1,   108,   109,   110,
     111,   112,   113,    -1,   115,    -1,    -1,    -1,    -1,   120,
      -1,    -1,    -1,    -1,   125,    -1,    -1,   128,    -1,   130,
      -1,    -1,    -1,   134,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   142,   143,   144,    -1,    -1,    -1,   148,   149,   150,
      -1,   152,   153,    -1,   155,   156,    -1,   158,    -1,    -1,
      -1,   162,    -1,    -1,   165,   166,    -1,    -1,    -1,    -1,
      -1,   172,   173,     6,    -1,   176,   177,    -1,    -1,   180,
      -1,    14,    -1,    16,    -1,    -1,    -1,    -1,   189,    -1,
     191,    -1,   193,   194,    -1,    -1,   197,   198,   199,    -1,
      -1,    34,    35,    -1,    -1,    -1,    -1,    40,    41,    42,
      43,    44,    45,    46,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    59,    -1,    -1,    62,
      -1,    -1,    -1,    -1,    67,    68,    69,    -1,    -1,    -1,
      -1,    74,    75,    -1,    -1,    -1,    -1,    -1,    81,    -1,
      -1,    -1,    -1,    -1,    87,    -1,    -1,    -1,    91,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    99,    -1,   101,   102,
      -1,   104,    -1,    -1,    -1,   108,   109,   110,   111,   112,
     113,    -1,   115,    -1,    -1,    -1,    -1,   120,    -1,    -1,
      -1,    -1,   125,    -1,    -1,   128,    -1,   130,    -1,    -1,
      -1,   134,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   142,
     143,   144,    -1,    -1,    -1,   148,   149,   150,     6,   152,
     153,    -1,   155,   156,    -1,   158,    14,    -1,    16,   162,
      -1,    -1,   165,   166,    -1,    -1,    -1,    -1,    -1,   172,
     173,    -1,    -1,   176,   177,    -1,    -1,   180,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   189,    -1,   191,    -1,
     193,   194,    -1,    51,   197,   198,   199,    -1,     6,    -1,
      -1,    -1,    60,    -1,    -1,    -1,    14,    -1,    16,    -1,
      -1,    -1,    70,    -1,    -1,    -1,    -1,    25,    26,    27,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    89,     6,    -1,    -1,    -1,    -1,    95,    -1,    -1,
      14,    -1,    16,    51,    52,    -1,    -1,    -1,    -1,    -1,
      -1,    25,    26,    27,    -1,    -1,   114,    -1,    -1,    -1,
      -1,   119,    70,   121,   122,    73,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    51,    52,    -1,
       6,    89,    -1,    -1,    -1,    -1,    -1,    95,    14,    -1,
      16,    -1,    -1,    -1,    -1,    -1,    70,    -1,    -1,    -1,
      -1,    -1,    -1,   161,    -1,    -1,    -1,    -1,    -1,   117,
      -1,   119,    -1,   121,   122,    89,    -1,   175,    -1,    -1,
      -1,    95,    -1,    -1,    -1,    51,    52,   185,    -1,    -1,
     188,   189,    -1,    -1,   192,   193,   194,   195,    -1,   197,
     198,   199,    -1,   117,    70,   119,    -1,   121,   122,    -1,
      -1,    -1,    -1,   161,    -1,    -1,    -1,    -1,     6,    -1,
      -1,    -1,    -1,    89,    -1,    -1,    14,   175,    16,    95,
      -1,    -1,    -1,    -1,    -1,    -1,   184,   185,   186,   187,
      -1,   189,   190,   191,   192,    -1,    -1,   161,    -1,    -1,
      -1,    -1,    -1,   119,    -1,   121,   122,    -1,    -1,    -1,
      14,   175,    16,    51,    52,    -1,    -1,    -1,    -1,    -1,
     184,   185,   186,   187,    -1,   189,   190,   191,   192,    -1,
      -1,    -1,    70,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   161,    -1,    51,    -1,    -1,
      -1,    89,    -1,    -1,    -1,    -1,    60,    95,    62,   175,
      -1,    -1,    -1,    -1,    -1,    69,    70,    -1,   184,   185,
     186,   187,    -1,   189,   190,   191,   192,    81,    -1,    -1,
      -1,   119,    -1,   121,   122,    89,    -1,    -1,    -1,    -1,
      -1,    95,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     114,    -1,    -1,    -1,    -1,   119,    -1,   121,   122,    -1,
      -1,   125,    -1,   161,    -1,    -1,   130,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   175,    -1,   143,
      -1,    -1,    -1,    -1,    -1,    -1,   184,   185,   186,   187,
      -1,   189,   190,   191,   192,    -1,    14,   161,    16,    -1,
      -1,    -1,    20,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   175,    -1,    -1,    -1,    33,    -1,    -1,    -1,    -1,
      -1,   185,   186,   187,   188,   189,   190,   191,   192,   193,
     194,   195,    -1,   197,   198,   199,    -1,    55,    56,    -1,
      -1,    -1,    -1,    -1,    -1,    63,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    71,    -1,    -1,    -1,    -1,    76,    -1,
      -1,    -1,    80,    -1,    -1,    -1,    -1,    -1,    86,    -1,
      -1,    -1,    90,    -1,    -1,    93,    94,    -1,    96,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,
      -1,    -1,    -1,   121,   122,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   131,   132,    -1,    -1,    -1,   136,   137,
     138,   139,    -1,    -1,    -1,    -1,    -1,   145,   146,   147,
      -1,    -1,    -1,   151,    -1,    -1,    -1,    -1,    14,    -1,
      16,    -1,   160,   161,    20,    -1,    -1,    -1,    -1,    -1,
      -1,   169,    -1,    -1,    -1,    -1,    -1,    33,    -1,    -1,
      -1,   179,    -1,   181,    -1,   183,    -1,   185,   186,   187,
     188,   189,   190,   191,   192,   193,   194,    -1,    -1,    55,
      56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    71,    -1,    -1,    -1,    -1,
      76,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      86,    -1,    -1,    -1,    90,    -1,    -1,    93,    94,    -1,
      96,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,
      -1,    -1,    -1,    -1,    -1,   121,   122,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   131,   132,    -1,    -1,    -1,
     136,   137,   138,   139,    -1,    -1,    -1,    -1,    -1,   145,
     146,   147,    -1,    -1,    -1,   151,    -1,    -1,    -1,    -1,
      14,    -1,    16,    -1,   160,   161,    20,    -1,    -1,    -1,
      -1,    -1,    -1,   169,    -1,    -1,    -1,    -1,    -1,    33,
      -1,    -1,    -1,   179,    -1,   181,    -1,   183,    -1,   185,
     186,   187,   188,   189,   190,   191,   192,   193,   194,    -1,
      -1,    55,    56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    76,    -1,    -1,    79,    -1,    -1,    -1,    -1,
      -1,    -1,    86,    -1,    -1,    -1,    90,    -1,    -1,    93,
      94,    -1,    96,    -1,    -1,    -1,    14,    -1,    16,    -1,
      -1,    -1,    20,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     114,    -1,    -1,    -1,    -1,    33,    -1,   121,   122,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   131,   132,    -1,
      -1,    -1,   136,    -1,   138,   139,    -1,    55,    56,    -1,
      -1,   145,   146,   147,    -1,    -1,    -1,   151,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   161,    76,    -1,
      -1,    79,    -1,    -1,   168,   169,    -1,    -1,    86,    -1,
      88,    -1,    90,    -1,    -1,   179,    94,   181,    96,   183,
      -1,   185,   186,   187,   188,   189,   190,   191,   192,   193,
     194,    -1,    -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,
      -1,    -1,    -1,   121,   122,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   131,   132,    -1,    -1,    14,   136,    16,
     138,   139,    -1,    20,    -1,    -1,    -1,   145,   146,   147,
      -1,    -1,    -1,   151,    -1,    -1,    33,    -1,    -1,    -1,
      -1,    -1,    -1,   161,    -1,    -1,    -1,    -1,    -1,   167,
      -1,   169,    -1,    -1,    -1,    -1,    -1,    -1,    55,    56,
      -1,   179,    -1,   181,    -1,   183,    63,   185,   186,   187,
     188,   189,   190,   191,   192,   193,   194,    -1,    -1,    76,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    86,
      -1,    88,    -1,    90,    -1,    -1,    -1,    94,    -1,    96,
      -1,    -1,    -1,    14,    -1,    16,    -1,    -1,    -1,    20,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,    -1,
      -1,    -1,    33,    -1,   121,   122,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   131,   132,    -1,    -1,    -1,   136,
      -1,   138,   139,    -1,    55,    56,    -1,    -1,   145,   146,
     147,    -1,    -1,    -1,   151,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   161,    76,    -1,    -1,    -1,    -1,
     167,    -1,   169,    -1,    -1,    86,    -1,    88,    -1,    90,
      -1,    -1,   179,    94,   181,    96,   183,    -1,   185,   186,
     187,   188,   189,   190,   191,   192,   193,   194,    -1,    -1,
      -1,    -1,    -1,   114,    -1,    -1,    -1,    -1,    -1,    -1,
     121,   122,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     131,   132,    -1,    -1,    14,   136,    16,   138,   139,    -1,
      20,    -1,    -1,    -1,   145,   146,   147,    -1,    -1,    -1,
     151,    -1,    -1,    33,    -1,    -1,    -1,    -1,    -1,    -1,
     161,    -1,    -1,    -1,    -1,    -1,   167,    -1,   169,    -1,
      -1,    -1,    -1,    -1,    -1,    55,    56,    -1,   179,    -1,
     181,    -1,   183,    63,   185,   186,   187,   188,   189,   190,
     191,   192,   193,   194,    -1,    -1,    76,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    86,    -1,    -1,    -1,
      90,    -1,    -1,    93,    94,    -1,    96,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,    -1,    -1,
      -1,   121,   122,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   131,   132,    -1,    -1,    14,   136,    16,   138,   139,
      -1,    20,    -1,    -1,    -1,   145,   146,   147,    -1,    -1,
      -1,   151,    -1,    -1,    33,    -1,    -1,    -1,    -1,    -1,
      -1,   161,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   169,
      -1,    -1,    -1,    -1,    -1,    -1,    55,    56,    -1,   179,
      -1,   181,    -1,   183,    -1,   185,   186,   187,   188,   189,
     190,   191,   192,   193,   194,    -1,    -1,    76,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    86,    -1,    -1,
      -1,    90,    -1,    -1,    93,    94,    -1,    96,    -1,    -1,
      -1,    14,    -1,    16,    -1,    -1,    -1,    20,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,    -1,
      33,    -1,   121,   122,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   131,   132,    -1,    -1,    -1,   136,    -1,   138,
     139,    -1,    55,    56,    -1,    -1,   145,   146,   147,    -1,
      -1,    -1,   151,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   161,    76,    -1,    -1,    79,    -1,    -1,    -1,
     169,    -1,    -1,    86,    -1,    -1,    -1,    90,    -1,    -1,
     179,    94,   181,    96,   183,    -1,   185,   186,   187,   188,
     189,   190,   191,   192,   193,   194,    -1,    -1,    -1,    -1,
      -1,   114,    -1,    -1,    -1,    -1,    -1,    -1,   121,   122,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   131,   132,
      -1,    -1,    14,   136,    16,   138,   139,    -1,    20,    -1,
      -1,    -1,   145,   146,   147,    -1,    -1,    -1,   151,    -1,
      -1,    33,    -1,    -1,    -1,    -1,    -1,    -1,   161,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   169,    -1,    -1,    -1,
      -1,    -1,    -1,    55,    56,    -1,   179,    -1,   181,    -1,
     183,    63,   185,   186,   187,   188,   189,   190,   191,   192,
     193,   194,    -1,    -1,    76,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    86,    -1,    -1,    -1,    90,    -1,
      -1,    -1,    94,    -1,    96,    -1,    -1,    -1,    14,    -1,
      16,    -1,    -1,    -1,    20,    -1,    -1,    -1,    14,    -1,
      16,    -1,   114,    -1,    -1,    -1,    -1,    33,    -1,   121,
     122,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   131,
     132,    -1,    -1,    -1,   136,    -1,   138,   139,    -1,    55,
      56,    -1,    -1,   145,   146,   147,    -1,    -1,    -1,   151,
      -1,    -1,    -1,    -1,    -1,    -1,    62,    -1,    -1,   161,
      76,    -1,    -1,    69,    -1,    -1,    -1,   169,    -1,    -1,
      86,    -1,    -1,    -1,    90,    81,    -1,   179,    94,   181,
      96,   183,    -1,   185,   186,   187,   188,   189,   190,   191,
     192,   193,   194,    -1,    -1,    -1,    -1,    -1,   114,    -1,
      -1,    -1,    -1,    -1,    -1,   121,   122,    -1,   114,    -1,
      -1,    -1,    -1,    -1,    -1,   131,   132,    -1,    -1,   125,
     136,    -1,   138,   139,   130,    -1,    -1,    -1,    -1,   145,
     146,   147,    -1,    -1,    -1,   151,    -1,   143,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   161,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   169,    -1,   161,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   179,    -1,   181,    -1,   183,    -1,   185,
     186,   187,   188,   189,   190,   191,   192,   193,   194,   185,
     186,   187,   188,   189,   190,   191,   192,   193,   194,    36,
      -1,    38,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      47,    -1,    -1,    50,    -1,    52,    53,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    61,    -1,    -1,    -1,    -1,    66,
      -1,    -1,    -1,    -1,    -1,    72,    -1,    -1,    -1,    -1,
      77,    -1,    -1,    -1,    -1,    -1,    83,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    93,    -1,    -1,    -1,
      -1,    -1,    -1,   100,   101,    -1,   103,    -1,    -1,    -1,
     107,    -1,   109,    -1,    -1,    -1,    -1,    -1,    -1,   116,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     127,    -1,   129,    -1,    -1,    -1,    -1,    -1,   135,    36,
      -1,    38,    -1,   140,    -1,    -1,    -1,   144,    -1,    -1,
      47,    -1,    -1,    50,    -1,    52,    53,   154,    -1,    -1,
      -1,    -1,   159,    -1,    61,    -1,    -1,    -1,    -1,    66,
     167,    -1,    -1,    -1,    -1,    72,    -1,    -1,    -1,    -1,
      77,    -1,    -1,   180,    -1,    -1,    83,    -1,   185,   186,
     187,   188,   189,   190,   191,   192,    93,   194,    -1,    -1,
      -1,    -1,    -1,   100,   101,    -1,   103,    -1,    -1,    36,
     107,    38,   109,    -1,    -1,    -1,    -1,    -1,    -1,   116,
      -1,    -1,    -1,    50,    -1,    52,    53,    -1,    -1,    -1,
     127,    -1,   129,    -1,    61,    -1,    -1,    -1,   135,    66,
      -1,    -1,    -1,   140,    -1,    72,    -1,   144,    -1,    -1,
      77,    -1,    -1,    -1,    -1,    -1,    83,   154,    -1,    -1,
      -1,    -1,   159,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     167,    -1,    -1,   100,   101,    -1,   103,    -1,    -1,    -1,
     107,    -1,   109,   180,    -1,    -1,    -1,    -1,    -1,   116,
      -1,    -1,   189,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   135,    -1,
      -1,    -1,    -1,   140,    -1,    -1,    -1,   144,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   154,    -1,    -1,
      -1,    -1,   159,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   180,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   189
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int16 yystos[] =
{
       0,    14,    16,    20,    33,    55,    56,    71,    76,    86,
      90,    93,    94,    96,   114,   121,   122,   131,   132,   136,
     137,   138,   139,   145,   146,   147,   151,   160,   161,   169,
     179,   181,   183,   185,   186,   187,   188,   189,   190,   191,
     192,   193,   194,   206,   220,   231,   253,   255,   260,   261,
     263,   264,   266,   272,   275,   277,   279,   280,   281,   282,
     283,   284,   285,   286,   288,   289,   290,   291,   298,   299,
     300,   301,   302,   303,   304,   305,   308,   310,   311,   312,
     313,   316,   317,   319,   320,   322,   323,   328,   329,   330,
     332,   358,   359,   360,   361,   362,   363,   366,   367,   375,
     378,   381,   384,   385,   386,   387,   388,   389,   390,   391,
     231,   284,   206,   190,   254,   264,   284,    36,    38,    47,
      50,    52,    53,    61,    66,    72,    77,    83,    93,   100,
     101,   103,   107,   109,   116,   127,   129,   135,   140,   144,
     154,   159,   167,   180,   186,   187,   189,   190,   191,   192,
     201,   202,   203,   204,   205,   206,   207,   208,   209,   210,
     211,   237,   263,   275,   285,   341,   342,   343,   344,   348,
     350,   351,   352,   353,   355,   357,    20,    57,    92,   178,
     182,   333,   334,   335,   338,    20,   264,     6,    20,   351,
     352,   353,   357,   171,    82,    82,     6,     6,    20,   264,
     206,   379,   255,   284,     6,     8,     9,    14,    16,    20,
      25,    26,    27,    34,    35,    40,    41,    42,    43,    44,
      45,    46,    51,    52,    59,    60,    61,    62,    67,    68,
      69,    70,    74,    75,    81,    87,    89,    91,    93,    95,
      99,   101,   102,   104,   106,   108,   109,   110,   111,   112,
     113,   115,   117,   118,   119,   120,   121,   122,   125,   128,
     130,   134,   141,   142,   143,   144,   148,   149,   150,   152,
     153,   155,   156,   158,   162,   165,   166,   172,   173,   174,
     175,   176,   177,   180,   184,   186,   187,   191,   195,   197,
     198,   199,   209,   212,   213,   214,   215,   216,   217,   219,
     220,   221,   222,   223,   224,   225,   226,   227,   230,   232,
     233,   244,   245,   246,   250,   252,   253,   254,   255,   256,
     257,   258,   259,   260,   262,   265,   269,   270,   271,   272,
     273,   274,   276,   277,   280,   282,   284,   254,    82,   255,
     255,   285,   382,   126,     6,    18,   234,   235,   238,   239,
     279,   282,   284,     6,   234,   234,    21,   234,   234,     6,
       4,    29,   287,     6,     4,    11,   234,   287,    20,   179,
     298,   299,   304,   298,     6,   212,   244,   246,   252,   269,
     276,   280,   293,   294,   295,   296,   298,    20,    39,    88,
     167,   179,   299,   300,     6,    20,    48,   306,    79,   168,
     301,   304,   309,   339,    20,    64,   105,   124,   157,   164,
     279,   314,   318,    20,   189,   230,   315,   318,     4,    20,
       4,    20,   287,     4,     6,    92,   178,   191,   212,   284,
      20,   254,   321,    49,    98,   122,   126,     4,    20,    73,
     324,   325,   326,   327,   333,    20,     6,    20,   222,   224,
     226,   254,   257,   273,   278,   279,   331,   340,   298,     0,
     301,   375,   378,   381,    63,    80,   301,   304,   364,   365,
     370,   371,   375,   378,   381,    20,    36,   140,    85,   133,
      65,    93,   127,   129,     6,   350,   368,   373,   374,   306,
     369,   373,   376,    20,   364,   365,   364,   365,   364,   365,
     364,   365,    15,    11,    17,   234,    11,     6,     6,     6,
       6,     6,     6,     6,     6,     6,   127,    83,   342,    20,
       4,   205,   114,   237,    10,   212,   349,     4,   202,   349,
     343,    10,   212,   230,   345,   346,   347,   189,   203,   342,
       9,   354,   356,   212,   168,   220,   284,   244,   293,    20,
      20,   334,   212,   336,    20,   222,    20,    20,    20,    20,
     264,    20,   234,    97,   163,   234,   222,   222,    20,     6,
      54,    11,   212,   244,   269,   284,   253,   284,   253,   284,
      28,   234,   267,   268,     6,   267,     6,   234,    24,    58,
     214,   215,   251,   213,   213,     7,    10,    11,   216,    12,
     218,    18,   235,     6,    20,   234,    22,   123,   247,   248,
      23,    39,   249,   251,     6,    14,    16,   250,   284,   259,
       6,   230,     6,   251,     6,     6,    11,    20,   234,    21,
     342,   203,   383,   171,   254,   222,     6,   220,   222,    10,
      13,   212,   240,   241,   242,   243,     4,     5,    20,    21,
       5,     6,   278,   279,   286,   230,   316,   212,   228,   229,
     230,   284,   286,   231,   263,   266,   275,   285,   230,    78,
     212,   269,   293,    28,    30,    31,    32,   252,   287,   297,
     170,   292,   297,     6,   297,   297,   297,   247,   292,   249,
     328,   228,     6,   264,   201,   304,   309,    20,     6,     6,
       6,     6,     6,   314,   315,   230,   284,   212,   212,    73,
     244,   212,    20,    11,     4,    20,   212,   212,   244,     6,
     136,    20,   327,    37,    84,     6,   212,   244,   284,     4,
       5,    20,   264,    88,   304,   364,    20,   301,   364,   371,
      20,   350,   185,   188,   189,   191,   192,   194,   372,   373,
     376,    20,   364,    20,   364,    20,   364,    20,   364,   234,
     234,   264,   349,   349,   349,   349,   223,   342,   342,   210,
       5,     4,     5,     5,    13,     4,     5,     6,   279,   340,
     345,   160,   349,    20,   206,   287,    11,    20,   171,   337,
       4,    20,    20,    97,   163,     5,     5,   206,   380,   196,
     377,     5,     5,     5,    15,    11,    17,    18,   222,   228,
     213,   213,     6,   187,   212,   270,   284,   213,   216,   216,
     217,     6,   228,   245,   246,   250,   252,    11,   222,     5,
     228,   212,   270,   228,   118,   278,   232,    20,   223,    21,
       4,    20,   212,   171,     5,    19,   236,    49,   212,   242,
     171,   214,   215,     5,   287,    20,    13,     4,     5,   234,
     234,   234,   234,     5,    28,    30,   287,   212,   246,   293,
     212,   269,   276,   190,   280,   284,   246,   294,   295,    20,
       5,   279,   284,   307,    20,   212,   212,   212,   212,   212,
      20,    20,     5,    20,    20,    20,   254,   212,   212,   212,
      11,    20,   206,    20,     4,     5,    20,    20,    20,    20,
     234,     5,     5,     5,     4,     5,   225,     4,     5,     6,
       5,    78,    29,   212,   212,     4,     5,   234,   234,     6,
       5,     5,    11,    19,     5,   250,     5,     5,     5,     5,
       5,   234,   223,   223,    20,   212,    19,   237,   258,   212,
     242,   213,   213,   230,   229,     5,    20,   306,     4,     5,
       5,     5,     5,     5,     5,     5,   171,    54,   206,    19,
     259,   237,    20,     4,     5,     5,     5,     6,   279,   284,
      20,   279,   212,   258,     4,    19,   236,   307,    20,     5,
     212,     5,     5,    20
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int16 yyr1[] =
{
       0,   200,   201,   201,   202,   202,   202,   203,   203,   203,
     203,   203,   203,   203,   203,   204,   204,   204,   204,   204,
     205,   205,   205,   206,   207,   207,   208,   208,   209,   209,
     209,   209,   210,   210,   211,   211,   211,   211,   211,   211,
     211,   211,   212,   212,   212,   212,   212,   213,   213,   214,
     215,   216,   216,   216,   216,   217,   217,   218,   219,   219,
     219,   219,   220,   220,   220,   220,   220,   220,   220,   220,
     221,   221,   221,   221,   221,   222,   222,   223,   224,   225,
     226,   226,   226,   226,   227,   227,   228,   228,   229,   229,
     229,   230,   230,   230,   230,   230,   231,   231,   232,   232,
     232,   232,   232,   232,   233,   233,   233,   233,   233,   233,
     233,   233,   233,   233,   233,   233,   233,   233,   233,   233,
     233,   233,   233,   233,   233,   233,   233,   233,   233,   233,
     233,   233,   233,   233,   233,   233,   233,   233,   233,   233,
     233,   233,   233,   233,   233,   233,   233,   233,   233,   233,
     233,   234,   234,   234,   234,   235,   235,   235,   235,   236,
     236,   237,   237,   238,   238,   238,   238,   238,   239,   239,
     240,   240,   240,   240,   241,   242,   242,   243,   243,   243,
     244,   244,   245,   245,   246,   246,   246,   246,   247,   247,
     248,   249,   249,   250,   250,   250,   250,   250,   250,   250,
     250,   250,   250,   250,   251,   251,   252,   252,   252,   252,
     253,   253,   253,   253,   254,   254,   254,   254,   255,   255,
     255,   255,   256,   256,   257,   257,   257,   257,   257,   258,
     258,   258,   258,   259,   260,   260,   261,   262,   262,   262,
     263,   264,   264,   264,   264,   265,   265,   266,   267,   267,
     268,   269,   269,   269,   269,   269,   270,   270,   270,   270,
     271,   271,   272,   272,   272,   272,   273,   273,   274,   274,
     274,   274,   274,   275,   276,   276,   276,   277,   278,   278,
     278,   279,   279,   279,   279,   279,   279,   279,   280,   280,
     280,   280,   281,   282,   283,   284,   284,   285,   286,   286,
     286,   286,   287,   288,   288,   289,   289,   290,   291,   292,
     293,   293,   294,   294,   295,   295,   295,   296,   296,   296,
     296,   296,   297,   297,   297,   297,   297,   297,   297,   297,
     298,   298,   298,   299,   299,   299,   299,   299,   299,   299,
     299,   299,   299,   299,   299,   299,   299,   299,   299,   299,
     299,   299,   299,   299,   299,   299,   299,   299,   299,   299,
     299,   299,   299,   299,   299,   299,   299,   299,   299,   299,
     299,   299,   299,   299,   300,   300,   300,   301,   301,   302,
     302,   303,   303,   303,   303,   304,   305,   306,   307,   307,
     307,   307,   308,   308,   308,   308,   308,   308,   308,   308,
     309,   309,   309,   310,   310,   311,   312,   312,   313,   313,
     314,   314,   315,   315,   315,   316,   317,   318,   318,   318,
     318,   318,   319,   320,   320,   321,   321,   322,   322,   322,
     322,   323,   323,   323,   324,   324,   324,   325,   325,   325,
     326,   327,   327,   328,   328,   328,   329,   330,   330,   331,
     331,   332,   333,   333,   334,   334,   335,   335,   336,   336,
     337,   337,   338,   338,   339,   340,   340,   340,   340,   341,
     341,   342,   342,   343,   343,   343,   343,   343,   343,   343,
     343,   343,   343,   343,   343,   344,   344,   344,   345,   345,
     345,   345,   345,   346,   347,   347,   348,   349,   349,   350,
     350,   350,   350,   350,   351,   351,   352,   353,   354,   354,
     355,   356,   357,   357,   357,   358,   358,   358,   358,   358,
     358,   358,   358,   359,   359,   360,   361,   361,   361,   361,
     361,   362,   362,   362,   362,   362,   362,   362,   362,   362,
     363,   363,   364,   364,   364,   365,   365,   365,   366,   367,
     368,   368,   368,   369,   369,   369,   370,   370,   371,   371,
     371,   371,   372,   372,   372,   372,   372,   372,   373,   374,
     374,   375,   376,   377,   378,   379,   379,   380,   380,   381,
     382,   382,   382,   383,   384,   384,   384,   384,   385,   385,
     386,   386,   387,   387,   388,   389,   389,   390,   391
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     1,     3,     2,     1,     1,     1,     2,     3,
       2,     2,     3,     1,     2,     3,     1,     1,     1,     1,
       1,     2,     1,     1,     3,     1,     2,     4,     1,     1,
       1,     1,     1,     2,     1,     2,     1,     1,     1,     1,
       1,     1,     1,     2,     2,     3,     3,     1,     3,     1,
       1,     1,     3,     3,     2,     1,     3,     1,     1,     1,
       1,     2,     1,     2,     3,     4,     3,     4,     3,     4,
       3,     1,     1,     4,     4,     1,     1,     1,     1,     1,
       1,     2,     3,     4,     1,     2,     1,     3,     1,     3,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     2,     1,     2,     2,     5,     5,     8,     5,     1,
       2,     1,     1,     2,     5,     2,     2,     2,     1,     2,
       1,     1,     2,     3,     2,     1,     1,     1,     3,     3,
       1,     3,     1,     3,     1,     3,     2,     4,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     3,     3,     4,
       3,     4,     3,     4,     1,     1,     1,     1,     1,     1,
       1,     2,     3,     4,     1,     2,     3,     4,     1,     2,
       3,     4,     1,     4,     2,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     2,     3,     1,     1,     1,     2,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       6,     1,     3,     3,     3,     3,     1,     1,     4,     3,
       1,     2,     1,     2,     3,     4,     1,     5,     1,     1,
       1,     1,     1,     1,     4,     1,     4,     1,     1,     1,
       1,     1,     1,     3,     1,     4,     1,     1,     1,     4,
       3,     4,     1,     2,     1,     1,     3,     1,     3,     3,
       3,     3,     1,     2,     2,     3,     3,     3,     1,     1,
       1,     3,     1,     3,     3,     4,     1,     3,     3,     3,
       3,     3,     1,     2,     1,     1,     1,     1,     2,     2,
       1,     1,     1,     2,     2,     2,     3,     2,     3,     4,
       1,     2,     5,     6,     9,     2,     3,     3,     2,     2,
       2,     2,     4,     4,     4,     4,     3,     4,     4,     2,
       3,     5,     6,     2,     3,     2,     4,     3,     2,     4,
       4,     3,     2,     4,     1,     2,     2,     1,     1,     3,
       2,     4,     4,     3,     3,     2,     2,     1,     1,     3,
       1,     3,     2,     3,     4,     3,     4,     2,     2,     2,
       1,     2,     2,     4,     4,     4,     2,     3,     2,     3,
       1,     1,     1,     1,     1,     4,     3,     4,     4,     4,
       4,     4,     1,     1,     1,     1,     3,     2,     3,     3,
       3,     1,     5,     2,     1,     1,     2,     3,     3,     1,
       2,     2,     2,     2,     2,     2,     2,     2,     3,     1,
       1,     5,     1,     1,     2,     2,     3,     2,     1,     3,
       2,     4,     3,     4,     3,     1,     1,     1,     1,     2,
       3,     1,     2,     1,     1,     1,     1,     1,     4,     1,
       1,     3,     3,     1,     4,     2,     2,     3,     1,     2,
       2,     3,     1,     3,     2,     3,     2,     1,     1,     1,
       1,     1,     1,     1,     1,     4,     4,     2,     2,     3,
       1,     3,     1,     1,     2,     1,     2,     1,     2,     1,
       2,     2,     3,     3,     4,     2,     2,     2,     1,     2,
       2,     2,     2,     2,     2,     1,     1,     2,     1,     2,
       1,     2,     1,     2,     2,     1,     1,     2,     2,     2,
       1,     1,     2,     1,     1,     2,     1,     2,     1,     2,
       1,     6,     1,     1,     1,     1,     1,     1,     3,     1,
       3,     3,     2,     1,     4,     1,     4,     1,     3,     3,
       3,     4,     4,     2,     1,     1,     1,     1,     3,     4,
       3,     2,     3,     4,     3,     3,     4,     3,     3
};


enum { YYENOMEM = -2 };

#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab
#define YYNOMEM         goto yyexhaustedlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                    \
  do                                                              \
    if (yychar == YYEMPTY)                                        \
      {                                                           \
        yychar = (Token);                                         \
        yylval = (Value);                                         \
        YYPOPSTACK (yylen);                                       \
        yystate = *yyssp;                                         \
        goto yybackup;                                            \
      }                                                           \
    else                                                          \
      {                                                           \
        yyerror (YY_("syntax error: cannot back up")); \
        YYERROR;                                                  \
      }                                                           \
  while (0)

/* Backward compatibility with an undocumented macro.
   Use YYerror or YYUNDEF. */
#define YYERRCODE YYUNDEF

/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)                                \
    do                                                                  \
      if (N)                                                            \
        {                                                               \
          (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;        \
          (Current).first_column = YYRHSLOC (Rhs, 1).first_column;      \
          (Current).last_line    = YYRHSLOC (Rhs, N).last_line;         \
          (Current).last_column  = YYRHSLOC (Rhs, N).last_column;       \
        }                                                               \
      else                                                              \
        {                                                               \
          (Current).first_line   = (Current).last_line   =              \
            YYRHSLOC (Rhs, 0).last_line;                                \
          (Current).first_column = (Current).last_column =              \
            YYRHSLOC (Rhs, 0).last_column;                              \
        }                                                               \
    while (0)
#endif

#define YYRHSLOC(Rhs, K) ((Rhs)[K])


/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)


/* YYLOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

# ifndef YYLOCATION_PRINT

#  if defined YY_LOCATION_PRINT

   /* Temporary convenience wrapper in case some people defined the
      undocumented and private YY_LOCATION_PRINT macros.  */
#   define YYLOCATION_PRINT(File, Loc)  YY_LOCATION_PRINT(File, *(Loc))

#  elif defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL

/* Print *YYLOCP on YYO.  Private, do not rely on its existence. */

YY_ATTRIBUTE_UNUSED
static int
yy_location_print_ (FILE *yyo, YYLTYPE const * const yylocp)
{
  int res = 0;
  int end_col = 0 != yylocp->last_column ? yylocp->last_column - 1 : 0;
  if (0 <= yylocp->first_line)
    {
      res += YYFPRINTF (yyo, "%d", yylocp->first_line);
      if (0 <= yylocp->first_column)
        res += YYFPRINTF (yyo, ".%d", yylocp->first_column);
    }
  if (0 <= yylocp->last_line)
    {
      if (yylocp->first_line < yylocp->last_line)
        {
          res += YYFPRINTF (yyo, "-%d", yylocp->last_line);
          if (0 <= end_col)
            res += YYFPRINTF (yyo, ".%d", end_col);
        }
      else if (0 <= end_col && yylocp->first_column < end_col)
        res += YYFPRINTF (yyo, "-%d", end_col);
    }
  return res;
}

#   define YYLOCATION_PRINT  yy_location_print_

    /* Temporary convenience wrapper in case some people defined the
       undocumented and private YY_LOCATION_PRINT macros.  */
#   define YY_LOCATION_PRINT(File, Loc)  YYLOCATION_PRINT(File, &(Loc))

#  else

#   define YYLOCATION_PRINT(File, Loc) ((void) 0)
    /* Temporary convenience wrapper in case some people defined the
       undocumented and private YY_LOCATION_PRINT macros.  */
#   define YY_LOCATION_PRINT  YYLOCATION_PRINT

#  endif
# endif /* !defined YYLOCATION_PRINT */


# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Kind, Value, Location); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo,
                       yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep, YYLTYPE const * const yylocationp)
{
  FILE *yyoutput = yyo;
  YY_USE (yyoutput);
  YY_USE (yylocationp);
  if (!yyvaluep)
    return;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/*---------------------------.
| Print this symbol on YYO.  |
`---------------------------*/

static void
yy_symbol_print (FILE *yyo,
                 yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep, YYLTYPE const * const yylocationp)
{
  YYFPRINTF (yyo, "%s %s (",
             yykind < YYNTOKENS ? "token" : "nterm", yysymbol_name (yykind));

  YYLOCATION_PRINT (yyo, yylocationp);
  YYFPRINTF (yyo, ": ");
  yy_symbol_value_print (yyo, yykind, yyvaluep, yylocationp);
  YYFPRINTF (yyo, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yy_state_t *yybottom, yy_state_t *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yy_state_t *yyssp, YYSTYPE *yyvsp, YYLTYPE *yylsp,
                 int yyrule)
{
  int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %d):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       YY_ACCESSING_SYMBOL (+yyssp[yyi + 1 - yynrhs]),
                       &yyvsp[(yyi + 1) - (yynrhs)],
                       &(yylsp[(yyi + 1) - (yynrhs)]));
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, yylsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args) ((void) 0)
# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif






/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg,
            yysymbol_kind_t yykind, YYSTYPE *yyvaluep, YYLTYPE *yylocationp)
{
  YY_USE (yyvaluep);
  YY_USE (yylocationp);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yykind, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/* Lookahead token kind.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Location data for the lookahead symbol.  */
YYLTYPE yylloc
# if defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL
  = { 1, 1, 1, 1 }
# endif
;
/* Number of syntax errors so far.  */
int yynerrs;




/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    yy_state_fast_t yystate = 0;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus = 0;

    /* Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* Their size.  */
    YYPTRDIFF_T yystacksize = YYINITDEPTH;

    /* The state stack: array, bottom, top.  */
    yy_state_t yyssa[YYINITDEPTH];
    yy_state_t *yyss = yyssa;
    yy_state_t *yyssp = yyss;

    /* The semantic value stack: array, bottom, top.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs = yyvsa;
    YYSTYPE *yyvsp = yyvs;

    /* The location stack: array, bottom, top.  */
    YYLTYPE yylsa[YYINITDEPTH];
    YYLTYPE *yyls = yylsa;
    YYLTYPE *yylsp = yyls;

  int yyn;
  /* The return value of yyparse.  */
  int yyresult;
  /* Lookahead symbol kind.  */
  yysymbol_kind_t yytoken = YYSYMBOL_YYEMPTY;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;
  YYLTYPE yyloc;

  /* The locations where the error started and ended.  */
  YYLTYPE yyerror_range[3];



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N), yylsp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yychar = YYEMPTY; /* Cause a token to be read.  */

  yylsp[0] = yylloc;
  goto yysetstate;


/*------------------------------------------------------------.
| yynewstate -- push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;


/*--------------------------------------------------------------------.
| yysetstate -- set current state (the top of the stack) to yystate.  |
`--------------------------------------------------------------------*/
yysetstate:
  YYDPRINTF ((stderr, "Entering state %d\n", yystate));
  YY_ASSERT (0 <= yystate && yystate < YYNSTATES);
  YY_IGNORE_USELESS_CAST_BEGIN
  *yyssp = YY_CAST (yy_state_t, yystate);
  YY_IGNORE_USELESS_CAST_END
  YY_STACK_PRINT (yyss, yyssp);

  if (yyss + yystacksize - 1 <= yyssp)
#if !defined yyoverflow && !defined YYSTACK_RELOCATE
    YYNOMEM;
#else
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYPTRDIFF_T yysize = yyssp - yyss + 1;

# if defined yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        yy_state_t *yyss1 = yyss;
        YYSTYPE *yyvs1 = yyvs;
        YYLTYPE *yyls1 = yyls;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * YYSIZEOF (*yyssp),
                    &yyvs1, yysize * YYSIZEOF (*yyvsp),
                    &yyls1, yysize * YYSIZEOF (*yylsp),
                    &yystacksize);
        yyss = yyss1;
        yyvs = yyvs1;
        yyls = yyls1;
      }
# else /* defined YYSTACK_RELOCATE */
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        YYNOMEM;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yy_state_t *yyss1 = yyss;
        union yyalloc *yyptr =
          YY_CAST (union yyalloc *,
                   YYSTACK_ALLOC (YY_CAST (YYSIZE_T, YYSTACK_BYTES (yystacksize))));
        if (! yyptr)
          YYNOMEM;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
        YYSTACK_RELOCATE (yyls_alloc, yyls);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;
      yylsp = yyls + yysize - 1;

      YY_IGNORE_USELESS_CAST_BEGIN
      YYDPRINTF ((stderr, "Stack size increased to %ld\n",
                  YY_CAST (long, yystacksize)));
      YY_IGNORE_USELESS_CAST_END

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }
#endif /* !defined yyoverflow && !defined YYSTACK_RELOCATE */


  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;


/*-----------.
| yybackup.  |
`-----------*/
yybackup:
  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either empty, or end-of-input, or a valid lookahead.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token\n"));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = YYEOF;
      yytoken = YYSYMBOL_YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else if (yychar == YYerror)
    {
      /* The scanner already issued an error message, process directly
         to error recovery.  But do not keep the error token as
         lookahead, it is too special and may lead us to an endless
         loop in error recovery. */
      yychar = YYUNDEF;
      yytoken = YYSYMBOL_YYerror;
      yyerror_range[1] = yylloc;
      goto yyerrlab1;
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);
  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END
  *++yylsp = yylloc;

  /* Discard the shifted token.  */
  yychar = YYEMPTY;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];

  /* Default location. */
  YYLLOC_DEFAULT (yyloc, (yylsp - yylen), yylen);
  yyerror_range[1] = yyloc;
  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
  case 2: /* DECLARE_BODY: DECLARATION_LIST  */
#line 645 "HAL_S.y"
                                { (yyval.declare_body_) = make_AAdeclareBody_declarationList((yyvsp[0].declaration_list_)); (yyval.declare_body_)->line_number = (yyloc).first_line; (yyval.declare_body_)->char_number = (yyloc).first_column;  }
#line 4133 "Parser.c"
    break;

  case 3: /* DECLARE_BODY: ATTRIBUTES _SYMB_0 DECLARATION_LIST  */
#line 646 "HAL_S.y"
                                        { (yyval.declare_body_) = make_ABdeclareBody_attributes_declarationList((yyvsp[-2].attributes_), (yyvsp[0].declaration_list_)); (yyval.declare_body_)->line_number = (yyloc).first_line; (yyval.declare_body_)->char_number = (yyloc).first_column;  }
#line 4139 "Parser.c"
    break;

  case 4: /* ATTRIBUTES: ARRAY_SPEC TYPE_AND_MINOR_ATTR  */
#line 648 "HAL_S.y"
                                            { (yyval.attributes_) = make_AAattributes_arraySpec_typeAndMinorAttr((yyvsp[-1].array_spec_), (yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4145 "Parser.c"
    break;

  case 5: /* ATTRIBUTES: ARRAY_SPEC  */
#line 649 "HAL_S.y"
               { (yyval.attributes_) = make_ABattributes_arraySpec((yyvsp[0].array_spec_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4151 "Parser.c"
    break;

  case 6: /* ATTRIBUTES: TYPE_AND_MINOR_ATTR  */
#line 650 "HAL_S.y"
                        { (yyval.attributes_) = make_ACattributes_typeAndMinorAttr((yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4157 "Parser.c"
    break;

  case 7: /* DECLARATION: NAME_ID  */
#line 652 "HAL_S.y"
                      { (yyval.declaration_) = make_AAdeclaration_nameId((yyvsp[0].name_id_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4163 "Parser.c"
    break;

  case 8: /* DECLARATION: NAME_ID ATTRIBUTES  */
#line 653 "HAL_S.y"
                       { (yyval.declaration_) = make_ABdeclaration_nameId_attributes((yyvsp[-1].name_id_), (yyvsp[0].attributes_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4169 "Parser.c"
    break;

  case 9: /* DECLARATION: _SYMB_187 _SYMB_123 MINOR_ATTR_LIST  */
#line 654 "HAL_S.y"
                                        { (yyval.declaration_) = make_ACdeclaration_labelToken_procedure_minorAttrList((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4175 "Parser.c"
    break;

  case 10: /* DECLARATION: _SYMB_187 _SYMB_123  */
#line 655 "HAL_S.y"
                        { (yyval.declaration_) = make_ADdeclaration_labelToken_procedure((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4181 "Parser.c"
    break;

  case 11: /* DECLARATION: _SYMB_188 _SYMB_79  */
#line 656 "HAL_S.y"
                       { (yyval.declaration_) = make_AEdeclaration_eventToken_event((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4187 "Parser.c"
    break;

  case 12: /* DECLARATION: _SYMB_188 _SYMB_79 MINOR_ATTR_LIST  */
#line 657 "HAL_S.y"
                                       { (yyval.declaration_) = make_AFdeclaration_eventToken_event_minorAttrList((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4193 "Parser.c"
    break;

  case 13: /* DECLARATION: _SYMB_188  */
#line 658 "HAL_S.y"
              { (yyval.declaration_) = make_AGdeclaration_eventToken((yyvsp[0].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4199 "Parser.c"
    break;

  case 14: /* DECLARATION: _SYMB_188 MINOR_ATTR_LIST  */
#line 659 "HAL_S.y"
                              { (yyval.declaration_) = make_AHdeclaration_eventToken_minorAttrList((yyvsp[-1].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4205 "Parser.c"
    break;

  case 15: /* ARRAY_SPEC: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 661 "HAL_S.y"
                                                    { (yyval.array_spec_) = make_AAarraySpec_arrayHead_literalExpOrStar((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4211 "Parser.c"
    break;

  case 16: /* ARRAY_SPEC: _SYMB_89  */
#line 662 "HAL_S.y"
             { (yyval.array_spec_) = make_ABarraySpec_function(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4217 "Parser.c"
    break;

  case 17: /* ARRAY_SPEC: _SYMB_123  */
#line 663 "HAL_S.y"
              { (yyval.array_spec_) = make_ACarraySpec_procedure(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4223 "Parser.c"
    break;

  case 18: /* ARRAY_SPEC: _SYMB_125  */
#line 664 "HAL_S.y"
              { (yyval.array_spec_) = make_ADarraySpec_program(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4229 "Parser.c"
    break;

  case 19: /* ARRAY_SPEC: _SYMB_163  */
#line 665 "HAL_S.y"
              { (yyval.array_spec_) = make_AEarraySpec_task(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4235 "Parser.c"
    break;

  case 20: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC  */
#line 667 "HAL_S.y"
                                { (yyval.type_and_minor_attr_) = make_AAtypeAndMinorAttr_typeSpec((yyvsp[0].type_spec_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4241 "Parser.c"
    break;

  case 21: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC MINOR_ATTR_LIST  */
#line 668 "HAL_S.y"
                              { (yyval.type_and_minor_attr_) = make_ABtypeAndMinorAttr_typeSpec_minorAttrList((yyvsp[-1].type_spec_), (yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4247 "Parser.c"
    break;

  case 22: /* TYPE_AND_MINOR_ATTR: MINOR_ATTR_LIST  */
#line 669 "HAL_S.y"
                    { (yyval.type_and_minor_attr_) = make_ACtypeAndMinorAttr_minorAttrList((yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4253 "Parser.c"
    break;

  case 23: /* IDENTIFIER: _SYMB_190  */
#line 671 "HAL_S.y"
                       { (yyval.identifier_) = make_AAidentifier((yyvsp[0].string_)); (yyval.identifier_)->line_number = (yyloc).first_line; (yyval.identifier_)->char_number = (yyloc).first_column;  }
#line 4259 "Parser.c"
    break;

  case 24: /* SQ_DQ_NAME: DOUBLY_QUAL_NAME_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 673 "HAL_S.y"
                                                               { (yyval.sq_dq_name_) = make_AAsQdQName_doublyQualNameHead_literalExpOrStar((yyvsp[-2].doubly_qual_name_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 4265 "Parser.c"
    break;

  case 25: /* SQ_DQ_NAME: ARITH_CONV  */
#line 674 "HAL_S.y"
               { (yyval.sq_dq_name_) = make_ABsQdQName_arithConv((yyvsp[0].arith_conv_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 4271 "Parser.c"
    break;

  case 26: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_176 _SYMB_2  */
#line 676 "HAL_S.y"
                                          { (yyval.doubly_qual_name_head_) = make_AAdoublyQualNameHead_vector(); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 4277 "Parser.c"
    break;

  case 27: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_105 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_0  */
#line 677 "HAL_S.y"
                                                  { (yyval.doubly_qual_name_head_) = make_ABdoublyQualNameHead_matrix_literalExpOrStar((yyvsp[-1].literal_exp_or_star_)); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 4283 "Parser.c"
    break;

  case 28: /* ARITH_CONV: _SYMB_97  */
#line 679 "HAL_S.y"
                      { (yyval.arith_conv_) = make_AAarithConv_integer(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4289 "Parser.c"
    break;

  case 29: /* ARITH_CONV: _SYMB_140  */
#line 680 "HAL_S.y"
              { (yyval.arith_conv_) = make_ABarithConv_scalar(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4295 "Parser.c"
    break;

  case 30: /* ARITH_CONV: _SYMB_176  */
#line 681 "HAL_S.y"
              { (yyval.arith_conv_) = make_ACarithConv_vector(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4301 "Parser.c"
    break;

  case 31: /* ARITH_CONV: _SYMB_105  */
#line 682 "HAL_S.y"
              { (yyval.arith_conv_) = make_ADarithConv_matrix(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4307 "Parser.c"
    break;

  case 32: /* DECLARATION_LIST: DECLARATION  */
#line 684 "HAL_S.y"
                               { (yyval.declaration_list_) = make_AAdeclaration_list((yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 4313 "Parser.c"
    break;

  case 33: /* DECLARATION_LIST: DCL_LIST_COMMA DECLARATION  */
#line 685 "HAL_S.y"
                               { (yyval.declaration_list_) = make_ABdeclaration_list((yyvsp[-1].dcl_list_comma_), (yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 4319 "Parser.c"
    break;

  case 34: /* NAME_ID: IDENTIFIER  */
#line 687 "HAL_S.y"
                     { (yyval.name_id_) = make_AAnameId_identifier((yyvsp[0].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4325 "Parser.c"
    break;

  case 35: /* NAME_ID: IDENTIFIER _SYMB_110  */
#line 688 "HAL_S.y"
                         { (yyval.name_id_) = make_ABnameId_identifier_name((yyvsp[-1].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4331 "Parser.c"
    break;

  case 36: /* NAME_ID: BIT_ID  */
#line 689 "HAL_S.y"
           { (yyval.name_id_) = make_ACnameId_bitId((yyvsp[0].bit_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4337 "Parser.c"
    break;

  case 37: /* NAME_ID: CHAR_ID  */
#line 690 "HAL_S.y"
            { (yyval.name_id_) = make_ADnameId_charId((yyvsp[0].char_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4343 "Parser.c"
    break;

  case 38: /* NAME_ID: _SYMB_182  */
#line 691 "HAL_S.y"
              { (yyval.name_id_) = make_AEnameId_bitFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4349 "Parser.c"
    break;

  case 39: /* NAME_ID: _SYMB_183  */
#line 692 "HAL_S.y"
              { (yyval.name_id_) = make_AFnameId_charFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4355 "Parser.c"
    break;

  case 40: /* NAME_ID: _SYMB_185  */
#line 693 "HAL_S.y"
              { (yyval.name_id_) = make_AGnameId_structIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4361 "Parser.c"
    break;

  case 41: /* NAME_ID: _SYMB_186  */
#line 694 "HAL_S.y"
              { (yyval.name_id_) = make_AHnameId_structFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4367 "Parser.c"
    break;

  case 42: /* ARITH_EXP: TERM  */
#line 696 "HAL_S.y"
                 { (yyval.arith_exp_) = make_AAarithExpTerm((yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4373 "Parser.c"
    break;

  case 43: /* ARITH_EXP: PLUS TERM  */
#line 697 "HAL_S.y"
              { (yyval.arith_exp_) = make_ABarithExpPlusTerm((yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4379 "Parser.c"
    break;

  case 44: /* ARITH_EXP: MINUS TERM  */
#line 698 "HAL_S.y"
               { (yyval.arith_exp_) = make_ACarithMinusTerm((yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4385 "Parser.c"
    break;

  case 45: /* ARITH_EXP: ARITH_EXP PLUS TERM  */
#line 699 "HAL_S.y"
                        { (yyval.arith_exp_) = make_ADarithExpArithExpPlusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4391 "Parser.c"
    break;

  case 46: /* ARITH_EXP: ARITH_EXP MINUS TERM  */
#line 700 "HAL_S.y"
                         { (yyval.arith_exp_) = make_AEarithExpArithExpMinusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4397 "Parser.c"
    break;

  case 47: /* TERM: PRODUCT  */
#line 702 "HAL_S.y"
               { (yyval.term_) = make_AAtermNoDivide((yyvsp[0].product_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4403 "Parser.c"
    break;

  case 48: /* TERM: PRODUCT _SYMB_3 TERM  */
#line 703 "HAL_S.y"
                         { (yyval.term_) = make_ABtermDivide((yyvsp[-2].product_), (yyvsp[0].term_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4409 "Parser.c"
    break;

  case 49: /* PLUS: _SYMB_4  */
#line 705 "HAL_S.y"
               { (yyval.plus_) = make_AAplus(); (yyval.plus_)->line_number = (yyloc).first_line; (yyval.plus_)->char_number = (yyloc).first_column;  }
#line 4415 "Parser.c"
    break;

  case 50: /* MINUS: _SYMB_5  */
#line 707 "HAL_S.y"
                { (yyval.minus_) = make_AAminus(); (yyval.minus_)->line_number = (yyloc).first_line; (yyval.minus_)->char_number = (yyloc).first_column;  }
#line 4421 "Parser.c"
    break;

  case 51: /* PRODUCT: FACTOR  */
#line 709 "HAL_S.y"
                 { (yyval.product_) = make_AAproductSingle((yyvsp[0].factor_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4427 "Parser.c"
    break;

  case 52: /* PRODUCT: FACTOR _SYMB_6 PRODUCT  */
#line 710 "HAL_S.y"
                           { (yyval.product_) = make_ABproductCross((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4433 "Parser.c"
    break;

  case 53: /* PRODUCT: FACTOR _SYMB_7 PRODUCT  */
#line 711 "HAL_S.y"
                           { (yyval.product_) = make_ACproductDot((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4439 "Parser.c"
    break;

  case 54: /* PRODUCT: FACTOR PRODUCT  */
#line 712 "HAL_S.y"
                   { (yyval.product_) = make_ADproductMultiplication((yyvsp[-1].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4445 "Parser.c"
    break;

  case 55: /* FACTOR: PRIMARY  */
#line 714 "HAL_S.y"
                 { (yyval.factor_) = make_AAfactor((yyvsp[0].primary_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4451 "Parser.c"
    break;

  case 56: /* FACTOR: PRIMARY EXPONENTIATION FACTOR  */
#line 715 "HAL_S.y"
                                  { (yyval.factor_) = make_ABfactorExponentiation((yyvsp[-2].primary_), (yyvsp[-1].exponentiation_), (yyvsp[0].factor_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4457 "Parser.c"
    break;

  case 57: /* EXPONENTIATION: _SYMB_8  */
#line 717 "HAL_S.y"
                         { (yyval.exponentiation_) = make_AAexponentiation(); (yyval.exponentiation_)->line_number = (yyloc).first_line; (yyval.exponentiation_)->char_number = (yyloc).first_column;  }
#line 4463 "Parser.c"
    break;

  case 58: /* PRIMARY: ARITH_VAR  */
#line 719 "HAL_S.y"
                    { (yyval.primary_) = make_AAprimary((yyvsp[0].arith_var_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4469 "Parser.c"
    break;

  case 59: /* PRIMARY: PRE_PRIMARY  */
#line 720 "HAL_S.y"
                { (yyval.primary_) = make_ADprimary((yyvsp[0].pre_primary_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4475 "Parser.c"
    break;

  case 60: /* PRIMARY: MODIFIED_ARITH_FUNC  */
#line 721 "HAL_S.y"
                        { (yyval.primary_) = make_ABprimary((yyvsp[0].modified_arith_func_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4481 "Parser.c"
    break;

  case 61: /* PRIMARY: PRE_PRIMARY QUALIFIER  */
#line 722 "HAL_S.y"
                          { (yyval.primary_) = make_AEprimary((yyvsp[-1].pre_primary_), (yyvsp[0].qualifier_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4487 "Parser.c"
    break;

  case 62: /* ARITH_VAR: ARITH_ID  */
#line 724 "HAL_S.y"
                     { (yyval.arith_var_) = make_AAarith_var((yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4493 "Parser.c"
    break;

  case 63: /* ARITH_VAR: ARITH_ID SUBSCRIPT  */
#line 725 "HAL_S.y"
                       { (yyval.arith_var_) = make_ACarith_var((yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4499 "Parser.c"
    break;

  case 64: /* ARITH_VAR: _SYMB_10 ARITH_ID _SYMB_11  */
#line 726 "HAL_S.y"
                               { (yyval.arith_var_) = make_AAarithVarBracketed((yyvsp[-1].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4505 "Parser.c"
    break;

  case 65: /* ARITH_VAR: _SYMB_10 ARITH_ID _SYMB_11 SUBSCRIPT  */
#line 727 "HAL_S.y"
                                         { (yyval.arith_var_) = make_ABarithVarBracketed((yyvsp[-2].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4511 "Parser.c"
    break;

  case 66: /* ARITH_VAR: _SYMB_12 QUAL_STRUCT _SYMB_13  */
#line 728 "HAL_S.y"
                                  { (yyval.arith_var_) = make_AAarithVarBraced((yyvsp[-1].qual_struct_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4517 "Parser.c"
    break;

  case 67: /* ARITH_VAR: _SYMB_12 QUAL_STRUCT _SYMB_13 SUBSCRIPT  */
#line 729 "HAL_S.y"
                                            { (yyval.arith_var_) = make_ABarithVarBraced((yyvsp[-2].qual_struct_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4523 "Parser.c"
    break;

  case 68: /* ARITH_VAR: QUAL_STRUCT _SYMB_7 ARITH_ID  */
#line 730 "HAL_S.y"
                                 { (yyval.arith_var_) = make_ABarith_var((yyvsp[-2].qual_struct_), (yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4529 "Parser.c"
    break;

  case 69: /* ARITH_VAR: QUAL_STRUCT _SYMB_7 ARITH_ID SUBSCRIPT  */
#line 731 "HAL_S.y"
                                           { (yyval.arith_var_) = make_ADarith_var((yyvsp[-3].qual_struct_), (yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4535 "Parser.c"
    break;

  case 70: /* PRE_PRIMARY: _SYMB_2 ARITH_EXP _SYMB_1  */
#line 733 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AApre_primary((yyvsp[-1].arith_exp_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4541 "Parser.c"
    break;

  case 71: /* PRE_PRIMARY: NUMBER  */
#line 734 "HAL_S.y"
           { (yyval.pre_primary_) = make_ABpre_primary((yyvsp[0].number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4547 "Parser.c"
    break;

  case 72: /* PRE_PRIMARY: COMPOUND_NUMBER  */
#line 735 "HAL_S.y"
                    { (yyval.pre_primary_) = make_ACpre_primary((yyvsp[0].compound_number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4553 "Parser.c"
    break;

  case 73: /* PRE_PRIMARY: ARITH_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 736 "HAL_S.y"
                                              { (yyval.pre_primary_) = make_ADprePrimaryRtlFunction((yyvsp[-3].arith_func_head_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4559 "Parser.c"
    break;

  case 74: /* PRE_PRIMARY: _SYMB_187 _SYMB_2 CALL_LIST _SYMB_1  */
#line 737 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AEprePrimaryFunction((yyvsp[-3].string_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4565 "Parser.c"
    break;

  case 75: /* NUMBER: SIMPLE_NUMBER  */
#line 739 "HAL_S.y"
                       { (yyval.number_) = make_AAnumber((yyvsp[0].simple_number_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4571 "Parser.c"
    break;

  case 76: /* NUMBER: LEVEL  */
#line 740 "HAL_S.y"
          { (yyval.number_) = make_ABnumber((yyvsp[0].level_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4577 "Parser.c"
    break;

  case 77: /* LEVEL: _SYMB_193  */
#line 742 "HAL_S.y"
                  { (yyval.level_) = make_ZZlevel((yyvsp[0].string_)); (yyval.level_)->line_number = (yyloc).first_line; (yyval.level_)->char_number = (yyloc).first_column;  }
#line 4583 "Parser.c"
    break;

  case 78: /* COMPOUND_NUMBER: _SYMB_195  */
#line 744 "HAL_S.y"
                            { (yyval.compound_number_) = make_CLcompound_number((yyvsp[0].string_)); (yyval.compound_number_)->line_number = (yyloc).first_line; (yyval.compound_number_)->char_number = (yyloc).first_column;  }
#line 4589 "Parser.c"
    break;

  case 79: /* SIMPLE_NUMBER: _SYMB_194  */
#line 746 "HAL_S.y"
                          { (yyval.simple_number_) = make_CKsimple_number((yyvsp[0].string_)); (yyval.simple_number_)->line_number = (yyloc).first_line; (yyval.simple_number_)->char_number = (yyloc).first_column;  }
#line 4595 "Parser.c"
    break;

  case 80: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC  */
#line 748 "HAL_S.y"
                                        { (yyval.modified_arith_func_) = make_AAmodified_arith_func((yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4601 "Parser.c"
    break;

  case 81: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 749 "HAL_S.y"
                                { (yyval.modified_arith_func_) = make_ACmodified_arith_func((yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4607 "Parser.c"
    break;

  case 82: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_7 NO_ARG_ARITH_FUNC  */
#line 750 "HAL_S.y"
                                          { (yyval.modified_arith_func_) = make_ADmodified_arith_func((yyvsp[-2].qual_struct_), (yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4613 "Parser.c"
    break;

  case 83: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_7 NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 751 "HAL_S.y"
                                                    { (yyval.modified_arith_func_) = make_AEmodified_arith_func((yyvsp[-3].qual_struct_), (yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4619 "Parser.c"
    break;

  case 84: /* ARITH_FUNC_HEAD: ARITH_FUNC  */
#line 753 "HAL_S.y"
                             { (yyval.arith_func_head_) = make_AAarith_func_head((yyvsp[0].arith_func_)); (yyval.arith_func_head_)->line_number = (yyloc).first_line; (yyval.arith_func_head_)->char_number = (yyloc).first_column;  }
#line 4625 "Parser.c"
    break;

  case 85: /* ARITH_FUNC_HEAD: ARITH_CONV SUBSCRIPT  */
#line 754 "HAL_S.y"
                         { (yyval.arith_func_head_) = make_ABarith_func_head((yyvsp[-1].arith_conv_), (yyvsp[0].subscript_)); (yyval.arith_func_head_)->line_number = (yyloc).first_line; (yyval.arith_func_head_)->char_number = (yyloc).first_column;  }
#line 4631 "Parser.c"
    break;

  case 86: /* CALL_LIST: LIST_EXP  */
#line 756 "HAL_S.y"
                     { (yyval.call_list_) = make_AAcall_list((yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 4637 "Parser.c"
    break;

  case 87: /* CALL_LIST: CALL_LIST _SYMB_0 LIST_EXP  */
#line 757 "HAL_S.y"
                               { (yyval.call_list_) = make_ABcall_list((yyvsp[-2].call_list_), (yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 4643 "Parser.c"
    break;

  case 88: /* LIST_EXP: EXPRESSION  */
#line 759 "HAL_S.y"
                      { (yyval.list_exp_) = make_AAlist_exp((yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4649 "Parser.c"
    break;

  case 89: /* LIST_EXP: ARITH_EXP _SYMB_9 EXPRESSION  */
#line 760 "HAL_S.y"
                                 { (yyval.list_exp_) = make_ABlist_exp((yyvsp[-2].arith_exp_), (yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4655 "Parser.c"
    break;

  case 90: /* LIST_EXP: QUAL_STRUCT  */
#line 761 "HAL_S.y"
                { (yyval.list_exp_) = make_ADlist_exp((yyvsp[0].qual_struct_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4661 "Parser.c"
    break;

  case 91: /* EXPRESSION: ARITH_EXP  */
#line 763 "HAL_S.y"
                       { (yyval.expression_) = make_AAexpression((yyvsp[0].arith_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4667 "Parser.c"
    break;

  case 92: /* EXPRESSION: BIT_EXP  */
#line 764 "HAL_S.y"
            { (yyval.expression_) = make_ABexpression((yyvsp[0].bit_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4673 "Parser.c"
    break;

  case 93: /* EXPRESSION: CHAR_EXP  */
#line 765 "HAL_S.y"
             { (yyval.expression_) = make_ACexpression((yyvsp[0].char_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4679 "Parser.c"
    break;

  case 94: /* EXPRESSION: NAME_EXP  */
#line 766 "HAL_S.y"
             { (yyval.expression_) = make_AEexpression((yyvsp[0].name_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4685 "Parser.c"
    break;

  case 95: /* EXPRESSION: STRUCTURE_EXP  */
#line 767 "HAL_S.y"
                  { (yyval.expression_) = make_ADexpression((yyvsp[0].structure_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4691 "Parser.c"
    break;

  case 96: /* ARITH_ID: IDENTIFIER  */
#line 769 "HAL_S.y"
                      { (yyval.arith_id_) = make_FGarith_id((yyvsp[0].identifier_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 4697 "Parser.c"
    break;

  case 97: /* ARITH_ID: _SYMB_189  */
#line 770 "HAL_S.y"
              { (yyval.arith_id_) = make_FHarith_id((yyvsp[0].string_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 4703 "Parser.c"
    break;

  case 98: /* NO_ARG_ARITH_FUNC: _SYMB_58  */
#line 772 "HAL_S.y"
                             { (yyval.no_arg_arith_func_) = make_ZZclocktime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4709 "Parser.c"
    break;

  case 99: /* NO_ARG_ARITH_FUNC: _SYMB_65  */
#line 773 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZdate(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4715 "Parser.c"
    break;

  case 100: /* NO_ARG_ARITH_FUNC: _SYMB_77  */
#line 774 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZerrgrp(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4721 "Parser.c"
    break;

  case 101: /* NO_ARG_ARITH_FUNC: _SYMB_121  */
#line 775 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZprio(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4727 "Parser.c"
    break;

  case 102: /* NO_ARG_ARITH_FUNC: _SYMB_126  */
#line 776 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZrandom(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4733 "Parser.c"
    break;

  case 103: /* NO_ARG_ARITH_FUNC: _SYMB_139  */
#line 777 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZruntime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4739 "Parser.c"
    break;

  case 104: /* ARITH_FUNC: _SYMB_111  */
#line 779 "HAL_S.y"
                       { (yyval.arith_func_) = make_ZZnexttime(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4745 "Parser.c"
    break;

  case 105: /* ARITH_FUNC: _SYMB_30  */
#line 780 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabs(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4751 "Parser.c"
    break;

  case 106: /* ARITH_FUNC: _SYMB_55  */
#line 781 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZceiling(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4757 "Parser.c"
    break;

  case 107: /* ARITH_FUNC: _SYMB_71  */
#line 782 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdiv(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4763 "Parser.c"
    break;

  case 108: /* ARITH_FUNC: _SYMB_87  */
#line 783 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZfloor(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4769 "Parser.c"
    break;

  case 109: /* ARITH_FUNC: _SYMB_107  */
#line 784 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmidval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4775 "Parser.c"
    break;

  case 110: /* ARITH_FUNC: _SYMB_109  */
#line 785 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4781 "Parser.c"
    break;

  case 111: /* ARITH_FUNC: _SYMB_116  */
#line 786 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZodd(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4787 "Parser.c"
    break;

  case 112: /* ARITH_FUNC: _SYMB_130  */
#line 787 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZremainder(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4793 "Parser.c"
    break;

  case 113: /* ARITH_FUNC: _SYMB_138  */
#line 788 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZround(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4799 "Parser.c"
    break;

  case 114: /* ARITH_FUNC: _SYMB_146  */
#line 789 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsign(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4805 "Parser.c"
    break;

  case 115: /* ARITH_FUNC: _SYMB_148  */
#line 790 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsignum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4811 "Parser.c"
    break;

  case 116: /* ARITH_FUNC: _SYMB_172  */
#line 791 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtruncate(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4817 "Parser.c"
    break;

  case 117: /* ARITH_FUNC: _SYMB_36  */
#line 792 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4823 "Parser.c"
    break;

  case 118: /* ARITH_FUNC: _SYMB_37  */
#line 793 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4829 "Parser.c"
    break;

  case 119: /* ARITH_FUNC: _SYMB_38  */
#line 794 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4835 "Parser.c"
    break;

  case 120: /* ARITH_FUNC: _SYMB_39  */
#line 795 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4841 "Parser.c"
    break;

  case 121: /* ARITH_FUNC: _SYMB_41  */
#line 796 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan2(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4847 "Parser.c"
    break;

  case 122: /* ARITH_FUNC: _SYMB_40  */
#line 797 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4853 "Parser.c"
    break;

  case 123: /* ARITH_FUNC: _SYMB_42  */
#line 798 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4859 "Parser.c"
    break;

  case 124: /* ARITH_FUNC: _SYMB_63  */
#line 799 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4865 "Parser.c"
    break;

  case 125: /* ARITH_FUNC: _SYMB_64  */
#line 800 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4871 "Parser.c"
    break;

  case 126: /* ARITH_FUNC: _SYMB_83  */
#line 801 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZexp(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4877 "Parser.c"
    break;

  case 127: /* ARITH_FUNC: _SYMB_104  */
#line 802 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZlog(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4883 "Parser.c"
    break;

  case 128: /* ARITH_FUNC: _SYMB_149  */
#line 803 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4889 "Parser.c"
    break;

  case 129: /* ARITH_FUNC: _SYMB_151  */
#line 804 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4895 "Parser.c"
    break;

  case 130: /* ARITH_FUNC: _SYMB_154  */
#line 805 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsqrt(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4901 "Parser.c"
    break;

  case 131: /* ARITH_FUNC: _SYMB_161  */
#line 806 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4907 "Parser.c"
    break;

  case 132: /* ARITH_FUNC: _SYMB_162  */
#line 807 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4913 "Parser.c"
    break;

  case 133: /* ARITH_FUNC: _SYMB_144  */
#line 808 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshl(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4919 "Parser.c"
    break;

  case 134: /* ARITH_FUNC: _SYMB_145  */
#line 809 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshr(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4925 "Parser.c"
    break;

  case 135: /* ARITH_FUNC: _SYMB_31  */
#line 810 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4931 "Parser.c"
    break;

  case 136: /* ARITH_FUNC: _SYMB_70  */
#line 811 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdet(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4937 "Parser.c"
    break;

  case 137: /* ARITH_FUNC: _SYMB_168  */
#line 812 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtrace(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4943 "Parser.c"
    break;

  case 138: /* ARITH_FUNC: _SYMB_173  */
#line 813 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZunit(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4949 "Parser.c"
    break;

  case 139: /* ARITH_FUNC: _SYMB_105  */
#line 814 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmatrix(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4955 "Parser.c"
    break;

  case 140: /* ARITH_FUNC: _SYMB_95  */
#line 815 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZindex(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4961 "Parser.c"
    break;

  case 141: /* ARITH_FUNC: _SYMB_100  */
#line 816 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZlength(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4967 "Parser.c"
    break;

  case 142: /* ARITH_FUNC: _SYMB_98  */
#line 817 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZinverse(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4973 "Parser.c"
    break;

  case 143: /* ARITH_FUNC: _SYMB_169  */
#line 818 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtranspose(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4979 "Parser.c"
    break;

  case 144: /* ARITH_FUNC: _SYMB_124  */
#line 819 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZprod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4985 "Parser.c"
    break;

  case 145: /* ARITH_FUNC: _SYMB_158  */
#line 820 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4991 "Parser.c"
    break;

  case 146: /* ARITH_FUNC: _SYMB_152  */
#line 821 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsize(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4997 "Parser.c"
    break;

  case 147: /* ARITH_FUNC: _SYMB_106  */
#line 822 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmax(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5003 "Parser.c"
    break;

  case 148: /* ARITH_FUNC: _SYMB_108  */
#line 823 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5009 "Parser.c"
    break;

  case 149: /* ARITH_FUNC: _SYMB_97  */
#line 824 "HAL_S.y"
             { (yyval.arith_func_) = make_AAarithFuncInteger(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5015 "Parser.c"
    break;

  case 150: /* ARITH_FUNC: _SYMB_140  */
#line 825 "HAL_S.y"
              { (yyval.arith_func_) = make_AAarithFuncScalar(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5021 "Parser.c"
    break;

  case 151: /* SUBSCRIPT: SUB_HEAD _SYMB_1  */
#line 827 "HAL_S.y"
                             { (yyval.subscript_) = make_AAsubscript((yyvsp[-1].sub_head_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5027 "Parser.c"
    break;

  case 152: /* SUBSCRIPT: QUALIFIER  */
#line 828 "HAL_S.y"
              { (yyval.subscript_) = make_ABsubscript((yyvsp[0].qualifier_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5033 "Parser.c"
    break;

  case 153: /* SUBSCRIPT: _SYMB_14 NUMBER  */
#line 829 "HAL_S.y"
                    { (yyval.subscript_) = make_ACsubscript((yyvsp[0].number_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5039 "Parser.c"
    break;

  case 154: /* SUBSCRIPT: _SYMB_14 ARITH_VAR  */
#line 830 "HAL_S.y"
                       { (yyval.subscript_) = make_ADsubscript((yyvsp[0].arith_var_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5045 "Parser.c"
    break;

  case 155: /* QUALIFIER: _SYMB_14 _SYMB_2 _SYMB_15 PREC_SPEC _SYMB_1  */
#line 832 "HAL_S.y"
                                                        { (yyval.qualifier_) = make_AAqualifier((yyvsp[-1].prec_spec_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5051 "Parser.c"
    break;

  case 156: /* QUALIFIER: _SYMB_14 _SYMB_2 SCALE_HEAD ARITH_EXP _SYMB_1  */
#line 833 "HAL_S.y"
                                                  { (yyval.qualifier_) = make_ABqualifier((yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5057 "Parser.c"
    break;

  case 157: /* QUALIFIER: _SYMB_14 _SYMB_2 _SYMB_15 PREC_SPEC _SYMB_0 SCALE_HEAD ARITH_EXP _SYMB_1  */
#line 834 "HAL_S.y"
                                                                             { (yyval.qualifier_) = make_ACqualifier((yyvsp[-4].prec_spec_), (yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5063 "Parser.c"
    break;

  case 158: /* QUALIFIER: _SYMB_14 _SYMB_2 _SYMB_15 RADIX _SYMB_1  */
#line 835 "HAL_S.y"
                                            { (yyval.qualifier_) = make_ADqualifier((yyvsp[-1].radix_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5069 "Parser.c"
    break;

  case 159: /* SCALE_HEAD: _SYMB_15  */
#line 837 "HAL_S.y"
                      { (yyval.scale_head_) = make_AAscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 5075 "Parser.c"
    break;

  case 160: /* SCALE_HEAD: _SYMB_15 _SYMB_15  */
#line 838 "HAL_S.y"
                      { (yyval.scale_head_) = make_ABscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 5081 "Parser.c"
    break;

  case 161: /* PREC_SPEC: _SYMB_150  */
#line 840 "HAL_S.y"
                      { (yyval.prec_spec_) = make_AAprecSpecSingle(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 5087 "Parser.c"
    break;

  case 162: /* PREC_SPEC: _SYMB_73  */
#line 841 "HAL_S.y"
             { (yyval.prec_spec_) = make_ABprecSpecDouble(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 5093 "Parser.c"
    break;

  case 163: /* SUB_START: _SYMB_14 _SYMB_2  */
#line 843 "HAL_S.y"
                             { (yyval.sub_start_) = make_AAsubStartGroup(); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5099 "Parser.c"
    break;

  case 164: /* SUB_START: _SYMB_14 _SYMB_2 _SYMB_15 PREC_SPEC _SYMB_0  */
#line 844 "HAL_S.y"
                                                { (yyval.sub_start_) = make_ABsubStartPrecSpec((yyvsp[-1].prec_spec_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5105 "Parser.c"
    break;

  case 165: /* SUB_START: SUB_HEAD _SYMB_16  */
#line 845 "HAL_S.y"
                      { (yyval.sub_start_) = make_ACsubStartSemicolon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5111 "Parser.c"
    break;

  case 166: /* SUB_START: SUB_HEAD _SYMB_17  */
#line 846 "HAL_S.y"
                      { (yyval.sub_start_) = make_ADsubStartColon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5117 "Parser.c"
    break;

  case 167: /* SUB_START: SUB_HEAD _SYMB_0  */
#line 847 "HAL_S.y"
                     { (yyval.sub_start_) = make_AEsubStartComma((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5123 "Parser.c"
    break;

  case 168: /* SUB_HEAD: SUB_START  */
#line 849 "HAL_S.y"
                     { (yyval.sub_head_) = make_AAsub_head((yyvsp[0].sub_start_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 5129 "Parser.c"
    break;

  case 169: /* SUB_HEAD: SUB_START SUB  */
#line 850 "HAL_S.y"
                  { (yyval.sub_head_) = make_ABsub_head((yyvsp[-1].sub_start_), (yyvsp[0].sub_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 5135 "Parser.c"
    break;

  case 170: /* SUB: SUB_EXP  */
#line 852 "HAL_S.y"
              { (yyval.sub_) = make_AAsub((yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5141 "Parser.c"
    break;

  case 171: /* SUB: _SYMB_6  */
#line 853 "HAL_S.y"
            { (yyval.sub_) = make_ABsubStar(); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5147 "Parser.c"
    break;

  case 172: /* SUB: SUB_RUN_HEAD SUB_EXP  */
#line 854 "HAL_S.y"
                         { (yyval.sub_) = make_ACsubExp((yyvsp[-1].sub_run_head_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5153 "Parser.c"
    break;

  case 173: /* SUB: ARITH_EXP _SYMB_45 SUB_EXP  */
#line 855 "HAL_S.y"
                               { (yyval.sub_) = make_ADsubAt((yyvsp[-2].arith_exp_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5159 "Parser.c"
    break;

  case 174: /* SUB_RUN_HEAD: SUB_EXP _SYMB_167  */
#line 857 "HAL_S.y"
                                 { (yyval.sub_run_head_) = make_AAsubRunHeadTo((yyvsp[-1].sub_exp_)); (yyval.sub_run_head_)->line_number = (yyloc).first_line; (yyval.sub_run_head_)->char_number = (yyloc).first_column;  }
#line 5165 "Parser.c"
    break;

  case 175: /* SUB_EXP: ARITH_EXP  */
#line 859 "HAL_S.y"
                    { (yyval.sub_exp_) = make_AAsub_exp((yyvsp[0].arith_exp_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 5171 "Parser.c"
    break;

  case 176: /* SUB_EXP: POUND_EXPRESSION  */
#line 860 "HAL_S.y"
                     { (yyval.sub_exp_) = make_ABsub_exp((yyvsp[0].pound_expression_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 5177 "Parser.c"
    break;

  case 177: /* POUND_EXPRESSION: _SYMB_9  */
#line 862 "HAL_S.y"
                           { (yyval.pound_expression_) = make_AApound_expression(); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5183 "Parser.c"
    break;

  case 178: /* POUND_EXPRESSION: POUND_EXPRESSION PLUS TERM  */
#line 863 "HAL_S.y"
                               { (yyval.pound_expression_) = make_ABpound_expression((yyvsp[-2].pound_expression_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5189 "Parser.c"
    break;

  case 179: /* POUND_EXPRESSION: POUND_EXPRESSION MINUS TERM  */
#line 864 "HAL_S.y"
                                { (yyval.pound_expression_) = make_ACpound_expression((yyvsp[-2].pound_expression_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5195 "Parser.c"
    break;

  case 180: /* BIT_EXP: BIT_FACTOR  */
#line 866 "HAL_S.y"
                     { (yyval.bit_exp_) = make_AAbit_exp((yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 5201 "Parser.c"
    break;

  case 181: /* BIT_EXP: BIT_EXP OR BIT_FACTOR  */
#line 867 "HAL_S.y"
                          { (yyval.bit_exp_) = make_ABbit_exp((yyvsp[-2].bit_exp_), (yyvsp[-1].or_), (yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 5207 "Parser.c"
    break;

  case 182: /* BIT_FACTOR: BIT_CAT  */
#line 869 "HAL_S.y"
                     { (yyval.bit_factor_) = make_AAbit_factor((yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 5213 "Parser.c"
    break;

  case 183: /* BIT_FACTOR: BIT_FACTOR AND BIT_CAT  */
#line 870 "HAL_S.y"
                           { (yyval.bit_factor_) = make_ABbit_factor((yyvsp[-2].bit_factor_), (yyvsp[-1].and_), (yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 5219 "Parser.c"
    break;

  case 184: /* BIT_CAT: BIT_PRIM  */
#line 872 "HAL_S.y"
                   { (yyval.bit_cat_) = make_AAbit_cat((yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5225 "Parser.c"
    break;

  case 185: /* BIT_CAT: BIT_CAT CAT BIT_PRIM  */
#line 873 "HAL_S.y"
                         { (yyval.bit_cat_) = make_ABbit_cat((yyvsp[-2].bit_cat_), (yyvsp[-1].cat_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5231 "Parser.c"
    break;

  case 186: /* BIT_CAT: NOT BIT_PRIM  */
#line 874 "HAL_S.y"
                 { (yyval.bit_cat_) = make_ACbit_cat((yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5237 "Parser.c"
    break;

  case 187: /* BIT_CAT: BIT_CAT CAT NOT BIT_PRIM  */
#line 875 "HAL_S.y"
                             { (yyval.bit_cat_) = make_ADbit_cat((yyvsp[-3].bit_cat_), (yyvsp[-2].cat_), (yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5243 "Parser.c"
    break;

  case 188: /* OR: CHAR_VERTICAL_BAR  */
#line 877 "HAL_S.y"
                       { (yyval.or_) = make_AAor((yyvsp[0].char_vertical_bar_)); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5249 "Parser.c"
    break;

  case 189: /* OR: _SYMB_119  */
#line 878 "HAL_S.y"
              { (yyval.or_) = make_ABor(); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5255 "Parser.c"
    break;

  case 190: /* CHAR_VERTICAL_BAR: _SYMB_18  */
#line 880 "HAL_S.y"
                             { (yyval.char_vertical_bar_) = make_CFchar_vertical_bar(); (yyval.char_vertical_bar_)->line_number = (yyloc).first_line; (yyval.char_vertical_bar_)->char_number = (yyloc).first_column;  }
#line 5261 "Parser.c"
    break;

  case 191: /* AND: _SYMB_19  */
#line 882 "HAL_S.y"
               { (yyval.and_) = make_AAand(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5267 "Parser.c"
    break;

  case 192: /* AND: _SYMB_35  */
#line 883 "HAL_S.y"
             { (yyval.and_) = make_ABand(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5273 "Parser.c"
    break;

  case 193: /* BIT_PRIM: BIT_VAR  */
#line 885 "HAL_S.y"
                   { (yyval.bit_prim_) = make_AAbitPrimBitVar((yyvsp[0].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5279 "Parser.c"
    break;

  case 194: /* BIT_PRIM: LABEL_VAR  */
#line 886 "HAL_S.y"
              { (yyval.bit_prim_) = make_ABbitPrimLabelVar((yyvsp[0].label_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5285 "Parser.c"
    break;

  case 195: /* BIT_PRIM: EVENT_VAR  */
#line 887 "HAL_S.y"
              { (yyval.bit_prim_) = make_ACbitPrimEventVar((yyvsp[0].event_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5291 "Parser.c"
    break;

  case 196: /* BIT_PRIM: BIT_CONST  */
#line 888 "HAL_S.y"
              { (yyval.bit_prim_) = make_ADbitBitConst((yyvsp[0].bit_const_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5297 "Parser.c"
    break;

  case 197: /* BIT_PRIM: _SYMB_2 BIT_EXP _SYMB_1  */
#line 889 "HAL_S.y"
                            { (yyval.bit_prim_) = make_AEbitPrimBitExp((yyvsp[-1].bit_exp_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5303 "Parser.c"
    break;

  case 198: /* BIT_PRIM: SUBBIT_HEAD EXPRESSION _SYMB_1  */
#line 890 "HAL_S.y"
                                   { (yyval.bit_prim_) = make_AHbitPrimSubbit((yyvsp[-2].subbit_head_), (yyvsp[-1].expression_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5309 "Parser.c"
    break;

  case 199: /* BIT_PRIM: BIT_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 891 "HAL_S.y"
                                            { (yyval.bit_prim_) = make_AIbitPrimFunc((yyvsp[-3].bit_func_head_), (yyvsp[-1].call_list_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5315 "Parser.c"
    break;

  case 200: /* BIT_PRIM: _SYMB_10 BIT_VAR _SYMB_11  */
#line 892 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBracketed((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5321 "Parser.c"
    break;

  case 201: /* BIT_PRIM: _SYMB_10 BIT_VAR _SYMB_11 SUBSCRIPT  */
#line 893 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBracketed((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5327 "Parser.c"
    break;

  case 202: /* BIT_PRIM: _SYMB_12 BIT_VAR _SYMB_13  */
#line 894 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBraced((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5333 "Parser.c"
    break;

  case 203: /* BIT_PRIM: _SYMB_12 BIT_VAR _SYMB_13 SUBSCRIPT  */
#line 895 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBraced((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5339 "Parser.c"
    break;

  case 204: /* CAT: _SYMB_20  */
#line 897 "HAL_S.y"
               { (yyval.cat_) = make_AAcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5345 "Parser.c"
    break;

  case 205: /* CAT: _SYMB_54  */
#line 898 "HAL_S.y"
             { (yyval.cat_) = make_ABcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5351 "Parser.c"
    break;

  case 206: /* NOT: _SYMB_21  */
#line 900 "HAL_S.y"
               { (yyval.not_) = make_AAnot(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5357 "Parser.c"
    break;

  case 207: /* NOT: _SYMB_113  */
#line 901 "HAL_S.y"
              { (yyval.not_) = make_ABnot(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5363 "Parser.c"
    break;

  case 208: /* NOT: _SYMB_22  */
#line 902 "HAL_S.y"
             { (yyval.not_) = make_ACnot(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5369 "Parser.c"
    break;

  case 209: /* NOT: _SYMB_23  */
#line 903 "HAL_S.y"
             { (yyval.not_) = make_ADnot(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5375 "Parser.c"
    break;

  case 210: /* BIT_VAR: BIT_ID  */
#line 905 "HAL_S.y"
                 { (yyval.bit_var_) = make_AAbit_var((yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5381 "Parser.c"
    break;

  case 211: /* BIT_VAR: BIT_ID SUBSCRIPT  */
#line 906 "HAL_S.y"
                     { (yyval.bit_var_) = make_ACbit_var((yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5387 "Parser.c"
    break;

  case 212: /* BIT_VAR: QUAL_STRUCT _SYMB_7 BIT_ID  */
#line 907 "HAL_S.y"
                               { (yyval.bit_var_) = make_ABbit_var((yyvsp[-2].qual_struct_), (yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5393 "Parser.c"
    break;

  case 213: /* BIT_VAR: QUAL_STRUCT _SYMB_7 BIT_ID SUBSCRIPT  */
#line 908 "HAL_S.y"
                                         { (yyval.bit_var_) = make_ADbit_var((yyvsp[-3].qual_struct_), (yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5399 "Parser.c"
    break;

  case 214: /* LABEL_VAR: LABEL  */
#line 910 "HAL_S.y"
                  { (yyval.label_var_) = make_AAlabel_var((yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5405 "Parser.c"
    break;

  case 215: /* LABEL_VAR: LABEL SUBSCRIPT  */
#line 911 "HAL_S.y"
                    { (yyval.label_var_) = make_ABlabel_var((yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5411 "Parser.c"
    break;

  case 216: /* LABEL_VAR: QUAL_STRUCT _SYMB_7 LABEL  */
#line 912 "HAL_S.y"
                              { (yyval.label_var_) = make_AClabel_var((yyvsp[-2].qual_struct_), (yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5417 "Parser.c"
    break;

  case 217: /* LABEL_VAR: QUAL_STRUCT _SYMB_7 LABEL SUBSCRIPT  */
#line 913 "HAL_S.y"
                                        { (yyval.label_var_) = make_ADlabel_var((yyvsp[-3].qual_struct_), (yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5423 "Parser.c"
    break;

  case 218: /* EVENT_VAR: EVENT  */
#line 915 "HAL_S.y"
                  { (yyval.event_var_) = make_AAevent_var((yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5429 "Parser.c"
    break;

  case 219: /* EVENT_VAR: EVENT SUBSCRIPT  */
#line 916 "HAL_S.y"
                    { (yyval.event_var_) = make_ACevent_var((yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5435 "Parser.c"
    break;

  case 220: /* EVENT_VAR: QUAL_STRUCT _SYMB_7 EVENT  */
#line 917 "HAL_S.y"
                              { (yyval.event_var_) = make_ABevent_var((yyvsp[-2].qual_struct_), (yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5441 "Parser.c"
    break;

  case 221: /* EVENT_VAR: QUAL_STRUCT _SYMB_7 EVENT SUBSCRIPT  */
#line 918 "HAL_S.y"
                                        { (yyval.event_var_) = make_ADevent_var((yyvsp[-3].qual_struct_), (yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5447 "Parser.c"
    break;

  case 222: /* BIT_CONST_HEAD: RADIX  */
#line 920 "HAL_S.y"
                       { (yyval.bit_const_head_) = make_AAbit_const_head((yyvsp[0].radix_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5453 "Parser.c"
    break;

  case 223: /* BIT_CONST_HEAD: RADIX _SYMB_2 NUMBER _SYMB_1  */
#line 921 "HAL_S.y"
                                 { (yyval.bit_const_head_) = make_ABbit_const_head((yyvsp[-3].radix_), (yyvsp[-1].number_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5459 "Parser.c"
    break;

  case 224: /* BIT_CONST: BIT_CONST_HEAD CHAR_STRING  */
#line 923 "HAL_S.y"
                                       { (yyval.bit_const_) = make_AAbitConstString((yyvsp[-1].bit_const_head_), (yyvsp[0].char_string_)); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5465 "Parser.c"
    break;

  case 225: /* BIT_CONST: _SYMB_171  */
#line 924 "HAL_S.y"
              { (yyval.bit_const_) = make_ABbitConstTrue(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5471 "Parser.c"
    break;

  case 226: /* BIT_CONST: _SYMB_85  */
#line 925 "HAL_S.y"
             { (yyval.bit_const_) = make_ACbitConstFalse(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5477 "Parser.c"
    break;

  case 227: /* BIT_CONST: _SYMB_118  */
#line 926 "HAL_S.y"
              { (yyval.bit_const_) = make_ADbitConstOn(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5483 "Parser.c"
    break;

  case 228: /* BIT_CONST: _SYMB_117  */
#line 927 "HAL_S.y"
              { (yyval.bit_const_) = make_AEbitConstOff(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5489 "Parser.c"
    break;

  case 229: /* RADIX: _SYMB_91  */
#line 929 "HAL_S.y"
                 { (yyval.radix_) = make_AAradixHEX(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5495 "Parser.c"
    break;

  case 230: /* RADIX: _SYMB_115  */
#line 930 "HAL_S.y"
              { (yyval.radix_) = make_ABradixOCT(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5501 "Parser.c"
    break;

  case 231: /* RADIX: _SYMB_47  */
#line 931 "HAL_S.y"
             { (yyval.radix_) = make_ACradixBIN(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5507 "Parser.c"
    break;

  case 232: /* RADIX: _SYMB_66  */
#line 932 "HAL_S.y"
             { (yyval.radix_) = make_ADradixDEC(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5513 "Parser.c"
    break;

  case 233: /* CHAR_STRING: _SYMB_191  */
#line 934 "HAL_S.y"
                        { (yyval.char_string_) = make_FPchar_string((yyvsp[0].string_)); (yyval.char_string_)->line_number = (yyloc).first_line; (yyval.char_string_)->char_number = (yyloc).first_column;  }
#line 5519 "Parser.c"
    break;

  case 234: /* SUBBIT_HEAD: SUBBIT_KEY _SYMB_2  */
#line 936 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_AAsubbit_head((yyvsp[-1].subbit_key_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5525 "Parser.c"
    break;

  case 235: /* SUBBIT_HEAD: SUBBIT_KEY SUBSCRIPT _SYMB_2  */
#line 937 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_ABsubbit_head((yyvsp[-2].subbit_key_), (yyvsp[-1].subscript_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5531 "Parser.c"
    break;

  case 236: /* SUBBIT_KEY: _SYMB_157  */
#line 939 "HAL_S.y"
                       { (yyval.subbit_key_) = make_AAsubbit_key(); (yyval.subbit_key_)->line_number = (yyloc).first_line; (yyval.subbit_key_)->char_number = (yyloc).first_column;  }
#line 5537 "Parser.c"
    break;

  case 237: /* BIT_FUNC_HEAD: BIT_FUNC  */
#line 941 "HAL_S.y"
                         { (yyval.bit_func_head_) = make_AAbit_func_head((yyvsp[0].bit_func_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5543 "Parser.c"
    break;

  case 238: /* BIT_FUNC_HEAD: _SYMB_48  */
#line 942 "HAL_S.y"
             { (yyval.bit_func_head_) = make_ABbit_func_head(); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5549 "Parser.c"
    break;

  case 239: /* BIT_FUNC_HEAD: _SYMB_48 SUB_OR_QUALIFIER  */
#line 943 "HAL_S.y"
                              { (yyval.bit_func_head_) = make_ACbit_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5555 "Parser.c"
    break;

  case 240: /* BIT_ID: _SYMB_181  */
#line 945 "HAL_S.y"
                   { (yyval.bit_id_) = make_FHbit_id((yyvsp[0].string_)); (yyval.bit_id_)->line_number = (yyloc).first_line; (yyval.bit_id_)->char_number = (yyloc).first_column;  }
#line 5561 "Parser.c"
    break;

  case 241: /* LABEL: _SYMB_187  */
#line 947 "HAL_S.y"
                  { (yyval.label_) = make_FKlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5567 "Parser.c"
    break;

  case 242: /* LABEL: _SYMB_182  */
#line 948 "HAL_S.y"
              { (yyval.label_) = make_FLlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5573 "Parser.c"
    break;

  case 243: /* LABEL: _SYMB_183  */
#line 949 "HAL_S.y"
              { (yyval.label_) = make_FMlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5579 "Parser.c"
    break;

  case 244: /* LABEL: _SYMB_186  */
#line 950 "HAL_S.y"
              { (yyval.label_) = make_FNlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5585 "Parser.c"
    break;

  case 245: /* BIT_FUNC: _SYMB_180  */
#line 952 "HAL_S.y"
                     { (yyval.bit_func_) = make_ZZxor(); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5591 "Parser.c"
    break;

  case 246: /* BIT_FUNC: _SYMB_182  */
#line 953 "HAL_S.y"
              { (yyval.bit_func_) = make_ZZuserBitFunction((yyvsp[0].string_)); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5597 "Parser.c"
    break;

  case 247: /* EVENT: _SYMB_188  */
#line 955 "HAL_S.y"
                  { (yyval.event_) = make_FLevent((yyvsp[0].string_)); (yyval.event_)->line_number = (yyloc).first_line; (yyval.event_)->char_number = (yyloc).first_column;  }
#line 5603 "Parser.c"
    break;

  case 248: /* SUB_OR_QUALIFIER: SUBSCRIPT  */
#line 957 "HAL_S.y"
                             { (yyval.sub_or_qualifier_) = make_AAsub_or_qualifier((yyvsp[0].subscript_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 5609 "Parser.c"
    break;

  case 249: /* SUB_OR_QUALIFIER: BIT_QUALIFIER  */
#line 958 "HAL_S.y"
                  { (yyval.sub_or_qualifier_) = make_ABsub_or_qualifier((yyvsp[0].bit_qualifier_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 5615 "Parser.c"
    break;

  case 250: /* BIT_QUALIFIER: _SYMB_24 _SYMB_14 _SYMB_2 _SYMB_15 RADIX _SYMB_1  */
#line 960 "HAL_S.y"
                                                                 { (yyval.bit_qualifier_) = make_AAbit_qualifier((yyvsp[-1].radix_)); (yyval.bit_qualifier_)->line_number = (yyloc).first_line; (yyval.bit_qualifier_)->char_number = (yyloc).first_column;  }
#line 5621 "Parser.c"
    break;

  case 251: /* CHAR_EXP: CHAR_PRIM  */
#line 962 "HAL_S.y"
                     { (yyval.char_exp_) = make_AAchar_exp((yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5627 "Parser.c"
    break;

  case 252: /* CHAR_EXP: CHAR_EXP CAT CHAR_PRIM  */
#line 963 "HAL_S.y"
                           { (yyval.char_exp_) = make_ABchar_exp((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5633 "Parser.c"
    break;

  case 253: /* CHAR_EXP: CHAR_EXP CAT ARITH_EXP  */
#line 964 "HAL_S.y"
                           { (yyval.char_exp_) = make_ACchar_exp((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5639 "Parser.c"
    break;

  case 254: /* CHAR_EXP: ARITH_EXP CAT ARITH_EXP  */
#line 965 "HAL_S.y"
                            { (yyval.char_exp_) = make_ADchar_exp((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5645 "Parser.c"
    break;

  case 255: /* CHAR_EXP: ARITH_EXP CAT CHAR_PRIM  */
#line 966 "HAL_S.y"
                            { (yyval.char_exp_) = make_AEchar_exp((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5651 "Parser.c"
    break;

  case 256: /* CHAR_PRIM: CHAR_VAR  */
#line 968 "HAL_S.y"
                     { (yyval.char_prim_) = make_AAchar_prim((yyvsp[0].char_var_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5657 "Parser.c"
    break;

  case 257: /* CHAR_PRIM: CHAR_CONST  */
#line 969 "HAL_S.y"
               { (yyval.char_prim_) = make_ABchar_prim((yyvsp[0].char_const_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5663 "Parser.c"
    break;

  case 258: /* CHAR_PRIM: CHAR_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 970 "HAL_S.y"
                                             { (yyval.char_prim_) = make_AEchar_prim((yyvsp[-3].char_func_head_), (yyvsp[-1].call_list_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5669 "Parser.c"
    break;

  case 259: /* CHAR_PRIM: _SYMB_2 CHAR_EXP _SYMB_1  */
#line 971 "HAL_S.y"
                             { (yyval.char_prim_) = make_AFchar_prim((yyvsp[-1].char_exp_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5675 "Parser.c"
    break;

  case 260: /* CHAR_FUNC_HEAD: CHAR_FUNC  */
#line 973 "HAL_S.y"
                           { (yyval.char_func_head_) = make_AAchar_func_head((yyvsp[0].char_func_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 5681 "Parser.c"
    break;

  case 261: /* CHAR_FUNC_HEAD: _SYMB_57 SUB_OR_QUALIFIER  */
#line 974 "HAL_S.y"
                              { (yyval.char_func_head_) = make_ABchar_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 5687 "Parser.c"
    break;

  case 262: /* CHAR_VAR: CHAR_ID  */
#line 976 "HAL_S.y"
                   { (yyval.char_var_) = make_AAchar_var((yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5693 "Parser.c"
    break;

  case 263: /* CHAR_VAR: CHAR_ID SUBSCRIPT  */
#line 977 "HAL_S.y"
                      { (yyval.char_var_) = make_ACchar_var((yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5699 "Parser.c"
    break;

  case 264: /* CHAR_VAR: QUAL_STRUCT _SYMB_7 CHAR_ID  */
#line 978 "HAL_S.y"
                                { (yyval.char_var_) = make_ABchar_var((yyvsp[-2].qual_struct_), (yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5705 "Parser.c"
    break;

  case 265: /* CHAR_VAR: QUAL_STRUCT _SYMB_7 CHAR_ID SUBSCRIPT  */
#line 979 "HAL_S.y"
                                          { (yyval.char_var_) = make_ADchar_var((yyvsp[-3].qual_struct_), (yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5711 "Parser.c"
    break;

  case 266: /* CHAR_CONST: CHAR_STRING  */
#line 981 "HAL_S.y"
                         { (yyval.char_const_) = make_AAchar_const((yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 5717 "Parser.c"
    break;

  case 267: /* CHAR_CONST: _SYMB_56 _SYMB_2 NUMBER _SYMB_1 CHAR_STRING  */
#line 982 "HAL_S.y"
                                                { (yyval.char_const_) = make_ABchar_const((yyvsp[-2].number_), (yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 5723 "Parser.c"
    break;

  case 268: /* CHAR_FUNC: _SYMB_102  */
#line 984 "HAL_S.y"
                      { (yyval.char_func_) = make_ZZljust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5729 "Parser.c"
    break;

  case 269: /* CHAR_FUNC: _SYMB_137  */
#line 985 "HAL_S.y"
              { (yyval.char_func_) = make_ZZrjust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5735 "Parser.c"
    break;

  case 270: /* CHAR_FUNC: _SYMB_170  */
#line 986 "HAL_S.y"
              { (yyval.char_func_) = make_ZZtrim(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5741 "Parser.c"
    break;

  case 271: /* CHAR_FUNC: _SYMB_183  */
#line 987 "HAL_S.y"
              { (yyval.char_func_) = make_ZZuserCharFunction((yyvsp[0].string_)); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5747 "Parser.c"
    break;

  case 272: /* CHAR_FUNC: _SYMB_57  */
#line 988 "HAL_S.y"
             { (yyval.char_func_) = make_AAcharFuncCharacter(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5753 "Parser.c"
    break;

  case 273: /* CHAR_ID: _SYMB_184  */
#line 990 "HAL_S.y"
                    { (yyval.char_id_) = make_FIchar_id((yyvsp[0].string_)); (yyval.char_id_)->line_number = (yyloc).first_line; (yyval.char_id_)->char_number = (yyloc).first_column;  }
#line 5759 "Parser.c"
    break;

  case 274: /* NAME_EXP: NAME_KEY _SYMB_2 NAME_VAR _SYMB_1  */
#line 992 "HAL_S.y"
                                             { (yyval.name_exp_) = make_AAnameExpKeyVar((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5765 "Parser.c"
    break;

  case 275: /* NAME_EXP: _SYMB_114  */
#line 993 "HAL_S.y"
              { (yyval.name_exp_) = make_ABnameExpNull(); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5771 "Parser.c"
    break;

  case 276: /* NAME_EXP: NAME_KEY _SYMB_2 _SYMB_114 _SYMB_1  */
#line 994 "HAL_S.y"
                                       { (yyval.name_exp_) = make_ACnameExpKeyNull((yyvsp[-3].name_key_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5777 "Parser.c"
    break;

  case 277: /* NAME_KEY: _SYMB_110  */
#line 996 "HAL_S.y"
                     { (yyval.name_key_) = make_AAname_key(); (yyval.name_key_)->line_number = (yyloc).first_line; (yyval.name_key_)->char_number = (yyloc).first_column;  }
#line 5783 "Parser.c"
    break;

  case 278: /* NAME_VAR: VARIABLE  */
#line 998 "HAL_S.y"
                    { (yyval.name_var_) = make_AAname_var((yyvsp[0].variable_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5789 "Parser.c"
    break;

  case 279: /* NAME_VAR: MODIFIED_ARITH_FUNC  */
#line 999 "HAL_S.y"
                        { (yyval.name_var_) = make_ACname_var((yyvsp[0].modified_arith_func_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5795 "Parser.c"
    break;

  case 280: /* NAME_VAR: LABEL_VAR  */
#line 1000 "HAL_S.y"
              { (yyval.name_var_) = make_ABname_var((yyvsp[0].label_var_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5801 "Parser.c"
    break;

  case 281: /* VARIABLE: ARITH_VAR  */
#line 1002 "HAL_S.y"
                     { (yyval.variable_) = make_AAvariable((yyvsp[0].arith_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5807 "Parser.c"
    break;

  case 282: /* VARIABLE: BIT_VAR  */
#line 1003 "HAL_S.y"
            { (yyval.variable_) = make_ACvariable((yyvsp[0].bit_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5813 "Parser.c"
    break;

  case 283: /* VARIABLE: SUBBIT_HEAD VARIABLE _SYMB_1  */
#line 1004 "HAL_S.y"
                                 { (yyval.variable_) = make_AEvariable((yyvsp[-2].subbit_head_), (yyvsp[-1].variable_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5819 "Parser.c"
    break;

  case 284: /* VARIABLE: CHAR_VAR  */
#line 1005 "HAL_S.y"
             { (yyval.variable_) = make_AFvariable((yyvsp[0].char_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5825 "Parser.c"
    break;

  case 285: /* VARIABLE: NAME_KEY _SYMB_2 NAME_VAR _SYMB_1  */
#line 1006 "HAL_S.y"
                                      { (yyval.variable_) = make_AGvariable((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5831 "Parser.c"
    break;

  case 286: /* VARIABLE: EVENT_VAR  */
#line 1007 "HAL_S.y"
              { (yyval.variable_) = make_ADvariable((yyvsp[0].event_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5837 "Parser.c"
    break;

  case 287: /* VARIABLE: STRUCTURE_VAR  */
#line 1008 "HAL_S.y"
                  { (yyval.variable_) = make_ABvariable((yyvsp[0].structure_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5843 "Parser.c"
    break;

  case 288: /* STRUCTURE_EXP: STRUCTURE_VAR  */
#line 1010 "HAL_S.y"
                              { (yyval.structure_exp_) = make_AAstructure_exp((yyvsp[0].structure_var_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5849 "Parser.c"
    break;

  case 289: /* STRUCTURE_EXP: STRUCT_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 1011 "HAL_S.y"
                                               { (yyval.structure_exp_) = make_ADstructure_exp((yyvsp[-3].struct_func_head_), (yyvsp[-1].call_list_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5855 "Parser.c"
    break;

  case 290: /* STRUCTURE_EXP: STRUC_INLINE_DEF CLOSING _SYMB_16  */
#line 1012 "HAL_S.y"
                                      { (yyval.structure_exp_) = make_ACstructure_exp((yyvsp[-2].struc_inline_def_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5861 "Parser.c"
    break;

  case 291: /* STRUCTURE_EXP: STRUC_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1013 "HAL_S.y"
                                                 { (yyval.structure_exp_) = make_AEstructure_exp((yyvsp[-3].struc_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5867 "Parser.c"
    break;

  case 292: /* STRUCT_FUNC_HEAD: STRUCT_FUNC  */
#line 1015 "HAL_S.y"
                               { (yyval.struct_func_head_) = make_AAstruct_func_head((yyvsp[0].struct_func_)); (yyval.struct_func_head_)->line_number = (yyloc).first_line; (yyval.struct_func_head_)->char_number = (yyloc).first_column;  }
#line 5873 "Parser.c"
    break;

  case 293: /* STRUCTURE_VAR: QUAL_STRUCT SUBSCRIPT  */
#line 1017 "HAL_S.y"
                                      { (yyval.structure_var_) = make_AAstructure_var((yyvsp[-1].qual_struct_), (yyvsp[0].subscript_)); (yyval.structure_var_)->line_number = (yyloc).first_line; (yyval.structure_var_)->char_number = (yyloc).first_column;  }
#line 5879 "Parser.c"
    break;

  case 294: /* STRUCT_FUNC: _SYMB_186  */
#line 1019 "HAL_S.y"
                        { (yyval.struct_func_) = make_ZZuserStructFunc((yyvsp[0].string_)); (yyval.struct_func_)->line_number = (yyloc).first_line; (yyval.struct_func_)->char_number = (yyloc).first_column;  }
#line 5885 "Parser.c"
    break;

  case 295: /* QUAL_STRUCT: STRUCTURE_ID  */
#line 1021 "HAL_S.y"
                           { (yyval.qual_struct_) = make_AAqual_struct((yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 5891 "Parser.c"
    break;

  case 296: /* QUAL_STRUCT: QUAL_STRUCT _SYMB_7 STRUCTURE_ID  */
#line 1022 "HAL_S.y"
                                     { (yyval.qual_struct_) = make_ABqual_struct((yyvsp[-2].qual_struct_), (yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 5897 "Parser.c"
    break;

  case 297: /* STRUCTURE_ID: _SYMB_185  */
#line 1024 "HAL_S.y"
                         { (yyval.structure_id_) = make_FJstructure_id((yyvsp[0].string_)); (yyval.structure_id_)->line_number = (yyloc).first_line; (yyval.structure_id_)->char_number = (yyloc).first_column;  }
#line 5903 "Parser.c"
    break;

  case 298: /* ASSIGNMENT: VARIABLE EQUALS EXPRESSION  */
#line 1026 "HAL_S.y"
                                        { (yyval.assignment_) = make_AAassignment((yyvsp[-2].variable_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5909 "Parser.c"
    break;

  case 299: /* ASSIGNMENT: VARIABLE _SYMB_0 ASSIGNMENT  */
#line 1027 "HAL_S.y"
                                { (yyval.assignment_) = make_ABassignment((yyvsp[-2].variable_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5915 "Parser.c"
    break;

  case 300: /* ASSIGNMENT: QUAL_STRUCT EQUALS EXPRESSION  */
#line 1028 "HAL_S.y"
                                  { (yyval.assignment_) = make_ACassignment((yyvsp[-2].qual_struct_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5921 "Parser.c"
    break;

  case 301: /* ASSIGNMENT: QUAL_STRUCT _SYMB_0 ASSIGNMENT  */
#line 1029 "HAL_S.y"
                                   { (yyval.assignment_) = make_ADassignment((yyvsp[-2].qual_struct_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5927 "Parser.c"
    break;

  case 302: /* EQUALS: _SYMB_25  */
#line 1031 "HAL_S.y"
                  { (yyval.equals_) = make_AAequals(); (yyval.equals_)->line_number = (yyloc).first_line; (yyval.equals_)->char_number = (yyloc).first_column;  }
#line 5933 "Parser.c"
    break;

  case 303: /* IF_STATEMENT: IF_CLAUSE STATEMENT  */
#line 1033 "HAL_S.y"
                                   { (yyval.if_statement_) = make_AAifStatement((yyvsp[-1].if_clause_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 5939 "Parser.c"
    break;

  case 304: /* IF_STATEMENT: TRUE_PART STATEMENT  */
#line 1034 "HAL_S.y"
                        { (yyval.if_statement_) = make_ABifThenElseStatement((yyvsp[-1].true_part_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 5945 "Parser.c"
    break;

  case 305: /* IF_CLAUSE: IF RELATIONAL_EXP THEN  */
#line 1036 "HAL_S.y"
                                   { (yyval.if_clause_) = make_AAif_clause((yyvsp[-2].if_), (yyvsp[-1].relational_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 5951 "Parser.c"
    break;

  case 306: /* IF_CLAUSE: IF BIT_EXP THEN  */
#line 1037 "HAL_S.y"
                    { (yyval.if_clause_) = make_ABif_clause((yyvsp[-2].if_), (yyvsp[-1].bit_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 5957 "Parser.c"
    break;

  case 307: /* TRUE_PART: IF_CLAUSE BASIC_STATEMENT _SYMB_74  */
#line 1039 "HAL_S.y"
                                               { (yyval.true_part_) = make_AAtrue_part((yyvsp[-2].if_clause_), (yyvsp[-1].basic_statement_)); (yyval.true_part_)->line_number = (yyloc).first_line; (yyval.true_part_)->char_number = (yyloc).first_column;  }
#line 5963 "Parser.c"
    break;

  case 308: /* IF: _SYMB_92  */
#line 1041 "HAL_S.y"
              { (yyval.if_) = make_AAif(); (yyval.if_)->line_number = (yyloc).first_line; (yyval.if_)->char_number = (yyloc).first_column;  }
#line 5969 "Parser.c"
    break;

  case 309: /* THEN: _SYMB_166  */
#line 1043 "HAL_S.y"
                 { (yyval.then_) = make_AAthen(); (yyval.then_)->line_number = (yyloc).first_line; (yyval.then_)->char_number = (yyloc).first_column;  }
#line 5975 "Parser.c"
    break;

  case 310: /* RELATIONAL_EXP: RELATIONAL_FACTOR  */
#line 1045 "HAL_S.y"
                                   { (yyval.relational_exp_) = make_AArelational_exp((yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 5981 "Parser.c"
    break;

  case 311: /* RELATIONAL_EXP: RELATIONAL_EXP OR RELATIONAL_FACTOR  */
#line 1046 "HAL_S.y"
                                        { (yyval.relational_exp_) = make_ABrelational_exp((yyvsp[-2].relational_exp_), (yyvsp[-1].or_), (yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 5987 "Parser.c"
    break;

  case 312: /* RELATIONAL_FACTOR: REL_PRIM  */
#line 1048 "HAL_S.y"
                             { (yyval.relational_factor_) = make_AArelational_factor((yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 5993 "Parser.c"
    break;

  case 313: /* RELATIONAL_FACTOR: RELATIONAL_FACTOR AND REL_PRIM  */
#line 1049 "HAL_S.y"
                                   { (yyval.relational_factor_) = make_ABrelational_factor((yyvsp[-2].relational_factor_), (yyvsp[-1].and_), (yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 5999 "Parser.c"
    break;

  case 314: /* REL_PRIM: _SYMB_2 RELATIONAL_EXP _SYMB_1  */
#line 1051 "HAL_S.y"
                                          { (yyval.rel_prim_) = make_AArel_prim((yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6005 "Parser.c"
    break;

  case 315: /* REL_PRIM: NOT _SYMB_2 RELATIONAL_EXP _SYMB_1  */
#line 1052 "HAL_S.y"
                                       { (yyval.rel_prim_) = make_ABrel_prim((yyvsp[-3].not_), (yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6011 "Parser.c"
    break;

  case 316: /* REL_PRIM: COMPARISON  */
#line 1053 "HAL_S.y"
               { (yyval.rel_prim_) = make_ACrel_prim((yyvsp[0].comparison_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6017 "Parser.c"
    break;

  case 317: /* COMPARISON: ARITH_EXP RELATIONAL_OP ARITH_EXP  */
#line 1055 "HAL_S.y"
                                               { (yyval.comparison_) = make_AAcomparison((yyvsp[-2].arith_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6023 "Parser.c"
    break;

  case 318: /* COMPARISON: CHAR_EXP RELATIONAL_OP CHAR_EXP  */
#line 1056 "HAL_S.y"
                                    { (yyval.comparison_) = make_ABcomparison((yyvsp[-2].char_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6029 "Parser.c"
    break;

  case 319: /* COMPARISON: BIT_CAT RELATIONAL_OP BIT_CAT  */
#line 1057 "HAL_S.y"
                                  { (yyval.comparison_) = make_ACcomparison((yyvsp[-2].bit_cat_), (yyvsp[-1].relational_op_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6035 "Parser.c"
    break;

  case 320: /* COMPARISON: STRUCTURE_EXP RELATIONAL_OP STRUCTURE_EXP  */
#line 1058 "HAL_S.y"
                                              { (yyval.comparison_) = make_ADcomparison((yyvsp[-2].structure_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6041 "Parser.c"
    break;

  case 321: /* COMPARISON: NAME_EXP RELATIONAL_OP NAME_EXP  */
#line 1059 "HAL_S.y"
                                    { (yyval.comparison_) = make_AEcomparison((yyvsp[-2].name_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6047 "Parser.c"
    break;

  case 322: /* RELATIONAL_OP: EQUALS  */
#line 1061 "HAL_S.y"
                       { (yyval.relational_op_) = make_AArelationalOpEQ((yyvsp[0].equals_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6053 "Parser.c"
    break;

  case 323: /* RELATIONAL_OP: NOT EQUALS  */
#line 1062 "HAL_S.y"
               { (yyval.relational_op_) = make_ABrelationalOpNEQ((yyvsp[-1].not_), (yyvsp[0].equals_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6059 "Parser.c"
    break;

  case 324: /* RELATIONAL_OP: _SYMB_24  */
#line 1063 "HAL_S.y"
             { (yyval.relational_op_) = make_ACrelationalOpLT(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6065 "Parser.c"
    break;

  case 325: /* RELATIONAL_OP: _SYMB_26  */
#line 1064 "HAL_S.y"
             { (yyval.relational_op_) = make_ADrelationalOpGT(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6071 "Parser.c"
    break;

  case 326: /* RELATIONAL_OP: _SYMB_27  */
#line 1065 "HAL_S.y"
             { (yyval.relational_op_) = make_AErelationalOpLE(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6077 "Parser.c"
    break;

  case 327: /* RELATIONAL_OP: _SYMB_28  */
#line 1066 "HAL_S.y"
             { (yyval.relational_op_) = make_AFrelationalOpGE(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6083 "Parser.c"
    break;

  case 328: /* RELATIONAL_OP: NOT _SYMB_24  */
#line 1067 "HAL_S.y"
                 { (yyval.relational_op_) = make_AGrelationalOpNLT((yyvsp[-1].not_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6089 "Parser.c"
    break;

  case 329: /* RELATIONAL_OP: NOT _SYMB_26  */
#line 1068 "HAL_S.y"
                 { (yyval.relational_op_) = make_AHrelationalOpNGT((yyvsp[-1].not_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6095 "Parser.c"
    break;

  case 330: /* STATEMENT: BASIC_STATEMENT  */
#line 1070 "HAL_S.y"
                            { (yyval.statement_) = make_AAstatement((yyvsp[0].basic_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6101 "Parser.c"
    break;

  case 331: /* STATEMENT: OTHER_STATEMENT  */
#line 1071 "HAL_S.y"
                    { (yyval.statement_) = make_ABstatement((yyvsp[0].other_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6107 "Parser.c"
    break;

  case 332: /* STATEMENT: INLINE_DEFINITION  */
#line 1072 "HAL_S.y"
                      { (yyval.statement_) = make_AZstatement((yyvsp[0].inline_definition_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6113 "Parser.c"
    break;

  case 333: /* BASIC_STATEMENT: ASSIGNMENT _SYMB_16  */
#line 1074 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_ABbasicStatementAssignment((yyvsp[-1].assignment_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6119 "Parser.c"
    break;

  case 334: /* BASIC_STATEMENT: LABEL_DEFINITION BASIC_STATEMENT  */
#line 1075 "HAL_S.y"
                                     { (yyval.basic_statement_) = make_AAbasic_statement((yyvsp[-1].label_definition_), (yyvsp[0].basic_statement_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6125 "Parser.c"
    break;

  case 335: /* BASIC_STATEMENT: _SYMB_82 _SYMB_16  */
#line 1076 "HAL_S.y"
                      { (yyval.basic_statement_) = make_ACbasicStatementExit(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6131 "Parser.c"
    break;

  case 336: /* BASIC_STATEMENT: _SYMB_82 LABEL _SYMB_16  */
#line 1077 "HAL_S.y"
                            { (yyval.basic_statement_) = make_ADbasicStatementExit((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6137 "Parser.c"
    break;

  case 337: /* BASIC_STATEMENT: _SYMB_132 _SYMB_16  */
#line 1078 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AEbasicStatementRepeat(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6143 "Parser.c"
    break;

  case 338: /* BASIC_STATEMENT: _SYMB_132 LABEL _SYMB_16  */
#line 1079 "HAL_S.y"
                             { (yyval.basic_statement_) = make_AFbasicStatementRepeat((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6149 "Parser.c"
    break;

  case 339: /* BASIC_STATEMENT: _SYMB_90 _SYMB_167 LABEL _SYMB_16  */
#line 1080 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AGbasicStatementGoTo((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6155 "Parser.c"
    break;

  case 340: /* BASIC_STATEMENT: _SYMB_16  */
#line 1081 "HAL_S.y"
             { (yyval.basic_statement_) = make_AHbasicStatementEmpty(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6161 "Parser.c"
    break;

  case 341: /* BASIC_STATEMENT: CALL_KEY _SYMB_16  */
#line 1082 "HAL_S.y"
                      { (yyval.basic_statement_) = make_AIbasicStatementCall((yyvsp[-1].call_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6167 "Parser.c"
    break;

  case 342: /* BASIC_STATEMENT: CALL_KEY _SYMB_2 CALL_LIST _SYMB_1 _SYMB_16  */
#line 1083 "HAL_S.y"
                                                { (yyval.basic_statement_) = make_AJbasicStatementCall((yyvsp[-4].call_key_), (yyvsp[-2].call_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6173 "Parser.c"
    break;

  case 343: /* BASIC_STATEMENT: CALL_KEY ASSIGN _SYMB_2 CALL_ASSIGN_LIST _SYMB_1 _SYMB_16  */
#line 1084 "HAL_S.y"
                                                              { (yyval.basic_statement_) = make_AKbasicStatementCall((yyvsp[-5].call_key_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6179 "Parser.c"
    break;

  case 344: /* BASIC_STATEMENT: CALL_KEY _SYMB_2 CALL_LIST _SYMB_1 ASSIGN _SYMB_2 CALL_ASSIGN_LIST _SYMB_1 _SYMB_16  */
#line 1085 "HAL_S.y"
                                                                                        { (yyval.basic_statement_) = make_ALbasicStatementCall((yyvsp[-8].call_key_), (yyvsp[-6].call_list_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6185 "Parser.c"
    break;

  case 345: /* BASIC_STATEMENT: _SYMB_135 _SYMB_16  */
#line 1086 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AMbasicStatementReturn(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6191 "Parser.c"
    break;

  case 346: /* BASIC_STATEMENT: _SYMB_135 EXPRESSION _SYMB_16  */
#line 1087 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_ANbasicStatementReturn((yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6197 "Parser.c"
    break;

  case 347: /* BASIC_STATEMENT: DO_GROUP_HEAD ENDING _SYMB_16  */
#line 1088 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_AObasicStatementDo((yyvsp[-2].do_group_head_), (yyvsp[-1].ending_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6203 "Parser.c"
    break;

  case 348: /* BASIC_STATEMENT: READ_KEY _SYMB_16  */
#line 1089 "HAL_S.y"
                      { (yyval.basic_statement_) = make_APbasicStatementReadKey((yyvsp[-1].read_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6209 "Parser.c"
    break;

  case 349: /* BASIC_STATEMENT: READ_PHRASE _SYMB_16  */
#line 1090 "HAL_S.y"
                         { (yyval.basic_statement_) = make_AQbasicStatementReadPhrase((yyvsp[-1].read_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6215 "Parser.c"
    break;

  case 350: /* BASIC_STATEMENT: WRITE_KEY _SYMB_16  */
#line 1091 "HAL_S.y"
                       { (yyval.basic_statement_) = make_ARbasicStatementWriteKey((yyvsp[-1].write_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6221 "Parser.c"
    break;

  case 351: /* BASIC_STATEMENT: WRITE_PHRASE _SYMB_16  */
#line 1092 "HAL_S.y"
                          { (yyval.basic_statement_) = make_ASbasicStatementWritePhrase((yyvsp[-1].write_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6227 "Parser.c"
    break;

  case 352: /* BASIC_STATEMENT: FILE_EXP EQUALS EXPRESSION _SYMB_16  */
#line 1093 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_ATbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6233 "Parser.c"
    break;

  case 353: /* BASIC_STATEMENT: VARIABLE EQUALS FILE_EXP _SYMB_16  */
#line 1094 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AUbasicStatementFileExp((yyvsp[-3].variable_), (yyvsp[-2].equals_), (yyvsp[-1].file_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6239 "Parser.c"
    break;

  case 354: /* BASIC_STATEMENT: FILE_EXP EQUALS QUAL_STRUCT _SYMB_16  */
#line 1095 "HAL_S.y"
                                         { (yyval.basic_statement_) = make_AVbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].qual_struct_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6245 "Parser.c"
    break;

  case 355: /* BASIC_STATEMENT: WAIT_KEY _SYMB_88 _SYMB_69 _SYMB_16  */
#line 1096 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_AVbasicStatementWait((yyvsp[-3].wait_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6251 "Parser.c"
    break;

  case 356: /* BASIC_STATEMENT: WAIT_KEY ARITH_EXP _SYMB_16  */
#line 1097 "HAL_S.y"
                                { (yyval.basic_statement_) = make_AWbasicStatementWait((yyvsp[-2].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6257 "Parser.c"
    break;

  case 357: /* BASIC_STATEMENT: WAIT_KEY _SYMB_174 ARITH_EXP _SYMB_16  */
#line 1098 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_AXbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6263 "Parser.c"
    break;

  case 358: /* BASIC_STATEMENT: WAIT_KEY _SYMB_88 BIT_EXP _SYMB_16  */
#line 1099 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_AYbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].bit_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6269 "Parser.c"
    break;

  case 359: /* BASIC_STATEMENT: TERMINATOR _SYMB_16  */
#line 1100 "HAL_S.y"
                        { (yyval.basic_statement_) = make_AZbasicStatementTerminator((yyvsp[-1].terminator_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6275 "Parser.c"
    break;

  case 360: /* BASIC_STATEMENT: TERMINATOR TERMINATE_LIST _SYMB_16  */
#line 1101 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_BAbasicStatementTerminator((yyvsp[-2].terminator_), (yyvsp[-1].terminate_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6281 "Parser.c"
    break;

  case 361: /* BASIC_STATEMENT: _SYMB_175 _SYMB_122 _SYMB_167 ARITH_EXP _SYMB_16  */
#line 1102 "HAL_S.y"
                                                     { (yyval.basic_statement_) = make_BBbasicStatementUpdate((yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6287 "Parser.c"
    break;

  case 362: /* BASIC_STATEMENT: _SYMB_175 _SYMB_122 LABEL_VAR _SYMB_167 ARITH_EXP _SYMB_16  */
#line 1103 "HAL_S.y"
                                                               { (yyval.basic_statement_) = make_BCbasicStatementUpdate((yyvsp[-3].label_var_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6293 "Parser.c"
    break;

  case 363: /* BASIC_STATEMENT: SCHEDULE_PHRASE _SYMB_16  */
#line 1104 "HAL_S.y"
                             { (yyval.basic_statement_) = make_BDbasicStatementSchedule((yyvsp[-1].schedule_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6299 "Parser.c"
    break;

  case 364: /* BASIC_STATEMENT: SCHEDULE_PHRASE SCHEDULE_CONTROL _SYMB_16  */
#line 1105 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BEbasicStatementSchedule((yyvsp[-2].schedule_phrase_), (yyvsp[-1].schedule_control_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6305 "Parser.c"
    break;

  case 365: /* BASIC_STATEMENT: SIGNAL_CLAUSE _SYMB_16  */
#line 1106 "HAL_S.y"
                           { (yyval.basic_statement_) = make_BFbasicStatementSignal((yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6311 "Parser.c"
    break;

  case 366: /* BASIC_STATEMENT: _SYMB_142 _SYMB_78 SUBSCRIPT _SYMB_16  */
#line 1107 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BGbasicStatementSend((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6317 "Parser.c"
    break;

  case 367: /* BASIC_STATEMENT: _SYMB_142 _SYMB_78 _SYMB_16  */
#line 1108 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BHbasicStatementSend(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6323 "Parser.c"
    break;

  case 368: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_16  */
#line 1109 "HAL_S.y"
                       { (yyval.basic_statement_) = make_BHbasicStatementOn((yyvsp[-1].on_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6329 "Parser.c"
    break;

  case 369: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_35 SIGNAL_CLAUSE _SYMB_16  */
#line 1110 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BIbasicStatementOnAndSignal((yyvsp[-3].on_clause_), (yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6335 "Parser.c"
    break;

  case 370: /* BASIC_STATEMENT: _SYMB_117 _SYMB_78 SUBSCRIPT _SYMB_16  */
#line 1111 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BJbasicStatementOff((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6341 "Parser.c"
    break;

  case 371: /* BASIC_STATEMENT: _SYMB_117 _SYMB_78 _SYMB_16  */
#line 1112 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementOff(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6347 "Parser.c"
    break;

  case 372: /* BASIC_STATEMENT: PERCENT_MACRO_NAME _SYMB_16  */
#line 1113 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementPercentMacro((yyvsp[-1].percent_macro_name_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6353 "Parser.c"
    break;

  case 373: /* BASIC_STATEMENT: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_1 _SYMB_16  */
#line 1114 "HAL_S.y"
                                                          { (yyval.basic_statement_) = make_BLbasicStatementPercentMacro((yyvsp[-3].percent_macro_head_), (yyvsp[-2].percent_macro_arg_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6359 "Parser.c"
    break;

  case 374: /* OTHER_STATEMENT: IF_STATEMENT  */
#line 1116 "HAL_S.y"
                               { (yyval.other_statement_) = make_ABotherStatementIf((yyvsp[0].if_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6365 "Parser.c"
    break;

  case 375: /* OTHER_STATEMENT: ON_PHRASE STATEMENT  */
#line 1117 "HAL_S.y"
                        { (yyval.other_statement_) = make_AAotherStatementOn((yyvsp[-1].on_phrase_), (yyvsp[0].statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6371 "Parser.c"
    break;

  case 376: /* OTHER_STATEMENT: LABEL_DEFINITION OTHER_STATEMENT  */
#line 1118 "HAL_S.y"
                                     { (yyval.other_statement_) = make_ACother_statement((yyvsp[-1].label_definition_), (yyvsp[0].other_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6377 "Parser.c"
    break;

  case 377: /* ANY_STATEMENT: STATEMENT  */
#line 1120 "HAL_S.y"
                          { (yyval.any_statement_) = make_AAany_statement((yyvsp[0].statement_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6383 "Parser.c"
    break;

  case 378: /* ANY_STATEMENT: BLOCK_DEFINITION  */
#line 1121 "HAL_S.y"
                     { (yyval.any_statement_) = make_ABany_statement((yyvsp[0].block_definition_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6389 "Parser.c"
    break;

  case 379: /* ON_PHRASE: _SYMB_118 _SYMB_78 SUBSCRIPT  */
#line 1123 "HAL_S.y"
                                         { (yyval.on_phrase_) = make_AAon_phrase((yyvsp[0].subscript_)); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6395 "Parser.c"
    break;

  case 380: /* ON_PHRASE: _SYMB_118 _SYMB_78  */
#line 1124 "HAL_S.y"
                       { (yyval.on_phrase_) = make_ACon_phrase(); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6401 "Parser.c"
    break;

  case 381: /* ON_CLAUSE: _SYMB_118 _SYMB_78 SUBSCRIPT _SYMB_159  */
#line 1126 "HAL_S.y"
                                                   { (yyval.on_clause_) = make_AAon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6407 "Parser.c"
    break;

  case 382: /* ON_CLAUSE: _SYMB_118 _SYMB_78 SUBSCRIPT _SYMB_93  */
#line 1127 "HAL_S.y"
                                          { (yyval.on_clause_) = make_ABon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6413 "Parser.c"
    break;

  case 383: /* ON_CLAUSE: _SYMB_118 _SYMB_78 _SYMB_159  */
#line 1128 "HAL_S.y"
                                 { (yyval.on_clause_) = make_ADon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6419 "Parser.c"
    break;

  case 384: /* ON_CLAUSE: _SYMB_118 _SYMB_78 _SYMB_93  */
#line 1129 "HAL_S.y"
                                { (yyval.on_clause_) = make_AEon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6425 "Parser.c"
    break;

  case 385: /* LABEL_DEFINITION: LABEL _SYMB_17  */
#line 1131 "HAL_S.y"
                                  { (yyval.label_definition_) = make_AAlabel_definition((yyvsp[-1].label_)); (yyval.label_definition_)->line_number = (yyloc).first_line; (yyval.label_definition_)->char_number = (yyloc).first_column;  }
#line 6431 "Parser.c"
    break;

  case 386: /* CALL_KEY: _SYMB_51 LABEL_VAR  */
#line 1133 "HAL_S.y"
                              { (yyval.call_key_) = make_AAcall_key((yyvsp[0].label_var_)); (yyval.call_key_)->line_number = (yyloc).first_line; (yyval.call_key_)->char_number = (yyloc).first_column;  }
#line 6437 "Parser.c"
    break;

  case 387: /* ASSIGN: _SYMB_44  */
#line 1135 "HAL_S.y"
                  { (yyval.assign_) = make_AAassign(); (yyval.assign_)->line_number = (yyloc).first_line; (yyval.assign_)->char_number = (yyloc).first_column;  }
#line 6443 "Parser.c"
    break;

  case 388: /* CALL_ASSIGN_LIST: VARIABLE  */
#line 1137 "HAL_S.y"
                            { (yyval.call_assign_list_) = make_AAcall_assign_list((yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6449 "Parser.c"
    break;

  case 389: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_0 VARIABLE  */
#line 1138 "HAL_S.y"
                                      { (yyval.call_assign_list_) = make_ABcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6455 "Parser.c"
    break;

  case 390: /* CALL_ASSIGN_LIST: QUAL_STRUCT  */
#line 1139 "HAL_S.y"
                { (yyval.call_assign_list_) = make_ACcall_assign_list((yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6461 "Parser.c"
    break;

  case 391: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_0 QUAL_STRUCT  */
#line 1140 "HAL_S.y"
                                         { (yyval.call_assign_list_) = make_ADcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6467 "Parser.c"
    break;

  case 392: /* DO_GROUP_HEAD: _SYMB_72 _SYMB_16  */
#line 1142 "HAL_S.y"
                                  { (yyval.do_group_head_) = make_AAdoGroupHead(); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6473 "Parser.c"
    break;

  case 393: /* DO_GROUP_HEAD: _SYMB_72 FOR_LIST _SYMB_16  */
#line 1143 "HAL_S.y"
                               { (yyval.do_group_head_) = make_ABdoGroupHeadFor((yyvsp[-1].for_list_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6479 "Parser.c"
    break;

  case 394: /* DO_GROUP_HEAD: _SYMB_72 FOR_LIST WHILE_CLAUSE _SYMB_16  */
#line 1144 "HAL_S.y"
                                            { (yyval.do_group_head_) = make_ACdoGroupHeadForWhile((yyvsp[-2].for_list_), (yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6485 "Parser.c"
    break;

  case 395: /* DO_GROUP_HEAD: _SYMB_72 WHILE_CLAUSE _SYMB_16  */
#line 1145 "HAL_S.y"
                                   { (yyval.do_group_head_) = make_ADdoGroupHeadWhile((yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6491 "Parser.c"
    break;

  case 396: /* DO_GROUP_HEAD: _SYMB_72 _SYMB_53 ARITH_EXP _SYMB_16  */
#line 1146 "HAL_S.y"
                                         { (yyval.do_group_head_) = make_AEdoGroupHeadCase((yyvsp[-1].arith_exp_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6497 "Parser.c"
    break;

  case 397: /* DO_GROUP_HEAD: CASE_ELSE STATEMENT  */
#line 1147 "HAL_S.y"
                        { (yyval.do_group_head_) = make_AFdoGroupHeadCaseElse((yyvsp[-1].case_else_), (yyvsp[0].statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6503 "Parser.c"
    break;

  case 398: /* DO_GROUP_HEAD: DO_GROUP_HEAD ANY_STATEMENT  */
#line 1148 "HAL_S.y"
                                { (yyval.do_group_head_) = make_AGdoGroupHeadStatement((yyvsp[-1].do_group_head_), (yyvsp[0].any_statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6509 "Parser.c"
    break;

  case 399: /* DO_GROUP_HEAD: DO_GROUP_HEAD TEMPORARY_STMT  */
#line 1149 "HAL_S.y"
                                 { (yyval.do_group_head_) = make_AHdoGroupHeadTemporaryStatement((yyvsp[-1].do_group_head_), (yyvsp[0].temporary_stmt_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6515 "Parser.c"
    break;

  case 400: /* ENDING: _SYMB_75  */
#line 1151 "HAL_S.y"
                  { (yyval.ending_) = make_AAending(); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6521 "Parser.c"
    break;

  case 401: /* ENDING: _SYMB_75 LABEL  */
#line 1152 "HAL_S.y"
                   { (yyval.ending_) = make_ABending((yyvsp[0].label_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6527 "Parser.c"
    break;

  case 402: /* ENDING: LABEL_DEFINITION ENDING  */
#line 1153 "HAL_S.y"
                            { (yyval.ending_) = make_ACending((yyvsp[-1].label_definition_), (yyvsp[0].ending_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6533 "Parser.c"
    break;

  case 403: /* READ_KEY: _SYMB_127 _SYMB_2 NUMBER _SYMB_1  */
#line 1155 "HAL_S.y"
                                            { (yyval.read_key_) = make_AAread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 6539 "Parser.c"
    break;

  case 404: /* READ_KEY: _SYMB_128 _SYMB_2 NUMBER _SYMB_1  */
#line 1156 "HAL_S.y"
                                     { (yyval.read_key_) = make_ABread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 6545 "Parser.c"
    break;

  case 405: /* WRITE_KEY: _SYMB_179 _SYMB_2 NUMBER _SYMB_1  */
#line 1158 "HAL_S.y"
                                             { (yyval.write_key_) = make_AAwrite_key((yyvsp[-1].number_)); (yyval.write_key_)->line_number = (yyloc).first_line; (yyval.write_key_)->char_number = (yyloc).first_column;  }
#line 6551 "Parser.c"
    break;

  case 406: /* READ_PHRASE: READ_KEY READ_ARG  */
#line 1160 "HAL_S.y"
                                { (yyval.read_phrase_) = make_AAread_phrase((yyvsp[-1].read_key_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 6557 "Parser.c"
    break;

  case 407: /* READ_PHRASE: READ_PHRASE _SYMB_0 READ_ARG  */
#line 1161 "HAL_S.y"
                                 { (yyval.read_phrase_) = make_ABread_phrase((yyvsp[-2].read_phrase_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 6563 "Parser.c"
    break;

  case 408: /* WRITE_PHRASE: WRITE_KEY WRITE_ARG  */
#line 1163 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_AAwrite_phrase((yyvsp[-1].write_key_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 6569 "Parser.c"
    break;

  case 409: /* WRITE_PHRASE: WRITE_PHRASE _SYMB_0 WRITE_ARG  */
#line 1164 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_ABwrite_phrase((yyvsp[-2].write_phrase_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 6575 "Parser.c"
    break;

  case 410: /* READ_ARG: VARIABLE  */
#line 1166 "HAL_S.y"
                    { (yyval.read_arg_) = make_AAread_arg((yyvsp[0].variable_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 6581 "Parser.c"
    break;

  case 411: /* READ_ARG: IO_CONTROL  */
#line 1167 "HAL_S.y"
               { (yyval.read_arg_) = make_ABread_arg((yyvsp[0].io_control_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 6587 "Parser.c"
    break;

  case 412: /* WRITE_ARG: EXPRESSION  */
#line 1169 "HAL_S.y"
                       { (yyval.write_arg_) = make_AAwrite_arg((yyvsp[0].expression_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6593 "Parser.c"
    break;

  case 413: /* WRITE_ARG: IO_CONTROL  */
#line 1170 "HAL_S.y"
               { (yyval.write_arg_) = make_ABwrite_arg((yyvsp[0].io_control_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6599 "Parser.c"
    break;

  case 414: /* WRITE_ARG: _SYMB_185  */
#line 1171 "HAL_S.y"
              { (yyval.write_arg_) = make_ACwrite_arg((yyvsp[0].string_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6605 "Parser.c"
    break;

  case 415: /* FILE_EXP: FILE_HEAD _SYMB_0 ARITH_EXP _SYMB_1  */
#line 1173 "HAL_S.y"
                                               { (yyval.file_exp_) = make_AAfile_exp((yyvsp[-3].file_head_), (yyvsp[-1].arith_exp_)); (yyval.file_exp_)->line_number = (yyloc).first_line; (yyval.file_exp_)->char_number = (yyloc).first_column;  }
#line 6611 "Parser.c"
    break;

  case 416: /* FILE_HEAD: _SYMB_86 _SYMB_2 NUMBER  */
#line 1175 "HAL_S.y"
                                    { (yyval.file_head_) = make_AAfile_head((yyvsp[0].number_)); (yyval.file_head_)->line_number = (yyloc).first_line; (yyval.file_head_)->char_number = (yyloc).first_column;  }
#line 6617 "Parser.c"
    break;

  case 417: /* IO_CONTROL: _SYMB_153 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1177 "HAL_S.y"
                                                 { (yyval.io_control_) = make_AAioControlSkip((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6623 "Parser.c"
    break;

  case 418: /* IO_CONTROL: _SYMB_160 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1178 "HAL_S.y"
                                        { (yyval.io_control_) = make_ABioControlTab((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6629 "Parser.c"
    break;

  case 419: /* IO_CONTROL: _SYMB_60 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1179 "HAL_S.y"
                                       { (yyval.io_control_) = make_ACioControlColumn((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6635 "Parser.c"
    break;

  case 420: /* IO_CONTROL: _SYMB_101 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1180 "HAL_S.y"
                                        { (yyval.io_control_) = make_ADioControlLine((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6641 "Parser.c"
    break;

  case 421: /* IO_CONTROL: _SYMB_120 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1181 "HAL_S.y"
                                        { (yyval.io_control_) = make_AEioControlPage((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6647 "Parser.c"
    break;

  case 422: /* WAIT_KEY: _SYMB_177  */
#line 1183 "HAL_S.y"
                     { (yyval.wait_key_) = make_AAwait_key(); (yyval.wait_key_)->line_number = (yyloc).first_line; (yyval.wait_key_)->char_number = (yyloc).first_column;  }
#line 6653 "Parser.c"
    break;

  case 423: /* TERMINATOR: _SYMB_165  */
#line 1185 "HAL_S.y"
                       { (yyval.terminator_) = make_AAterminatorTerminate(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 6659 "Parser.c"
    break;

  case 424: /* TERMINATOR: _SYMB_52  */
#line 1186 "HAL_S.y"
             { (yyval.terminator_) = make_ABterminatorCancel(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 6665 "Parser.c"
    break;

  case 425: /* TERMINATE_LIST: LABEL_VAR  */
#line 1188 "HAL_S.y"
                           { (yyval.terminate_list_) = make_AAterminate_list((yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 6671 "Parser.c"
    break;

  case 426: /* TERMINATE_LIST: TERMINATE_LIST _SYMB_0 LABEL_VAR  */
#line 1189 "HAL_S.y"
                                     { (yyval.terminate_list_) = make_ABterminate_list((yyvsp[-2].terminate_list_), (yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 6677 "Parser.c"
    break;

  case 427: /* SCHEDULE_HEAD: _SYMB_141 LABEL_VAR  */
#line 1191 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_AAscheduleHeadLabel((yyvsp[0].label_var_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6683 "Parser.c"
    break;

  case 428: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_45 ARITH_EXP  */
#line 1192 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ABscheduleHeadAt((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6689 "Parser.c"
    break;

  case 429: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_94 ARITH_EXP  */
#line 1193 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ACscheduleHeadIn((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6695 "Parser.c"
    break;

  case 430: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_118 BIT_EXP  */
#line 1194 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_ADscheduleHeadOn((yyvsp[-2].schedule_head_), (yyvsp[0].bit_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6701 "Parser.c"
    break;

  case 431: /* SCHEDULE_PHRASE: SCHEDULE_HEAD  */
#line 1196 "HAL_S.y"
                                { (yyval.schedule_phrase_) = make_AAschedule_phrase((yyvsp[0].schedule_head_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6707 "Parser.c"
    break;

  case 432: /* SCHEDULE_PHRASE: SCHEDULE_HEAD _SYMB_122 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1197 "HAL_S.y"
                                                      { (yyval.schedule_phrase_) = make_ABschedule_phrase((yyvsp[-4].schedule_head_), (yyvsp[-1].arith_exp_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6713 "Parser.c"
    break;

  case 433: /* SCHEDULE_PHRASE: SCHEDULE_PHRASE _SYMB_69  */
#line 1198 "HAL_S.y"
                             { (yyval.schedule_phrase_) = make_ACschedule_phrase((yyvsp[-1].schedule_phrase_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6719 "Parser.c"
    break;

  case 434: /* SCHEDULE_CONTROL: STOPPING  */
#line 1200 "HAL_S.y"
                            { (yyval.schedule_control_) = make_AAschedule_control((yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6725 "Parser.c"
    break;

  case 435: /* SCHEDULE_CONTROL: TIMING  */
#line 1201 "HAL_S.y"
           { (yyval.schedule_control_) = make_ABschedule_control((yyvsp[0].timing_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6731 "Parser.c"
    break;

  case 436: /* SCHEDULE_CONTROL: TIMING STOPPING  */
#line 1202 "HAL_S.y"
                    { (yyval.schedule_control_) = make_ACschedule_control((yyvsp[-1].timing_), (yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6737 "Parser.c"
    break;

  case 437: /* TIMING: REPEAT _SYMB_80 ARITH_EXP  */
#line 1204 "HAL_S.y"
                                   { (yyval.timing_) = make_AAtimingEvery((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6743 "Parser.c"
    break;

  case 438: /* TIMING: REPEAT _SYMB_33 ARITH_EXP  */
#line 1205 "HAL_S.y"
                              { (yyval.timing_) = make_ABtimingAfter((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6749 "Parser.c"
    break;

  case 439: /* TIMING: REPEAT  */
#line 1206 "HAL_S.y"
           { (yyval.timing_) = make_ACtiming((yyvsp[0].repeat_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6755 "Parser.c"
    break;

  case 440: /* REPEAT: _SYMB_0 _SYMB_132  */
#line 1208 "HAL_S.y"
                           { (yyval.repeat_) = make_AArepeat(); (yyval.repeat_)->line_number = (yyloc).first_line; (yyval.repeat_)->char_number = (yyloc).first_column;  }
#line 6761 "Parser.c"
    break;

  case 441: /* STOPPING: WHILE_KEY ARITH_EXP  */
#line 1210 "HAL_S.y"
                               { (yyval.stopping_) = make_AAstopping((yyvsp[-1].while_key_), (yyvsp[0].arith_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 6767 "Parser.c"
    break;

  case 442: /* STOPPING: WHILE_KEY BIT_EXP  */
#line 1211 "HAL_S.y"
                      { (yyval.stopping_) = make_ABstopping((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 6773 "Parser.c"
    break;

  case 443: /* SIGNAL_CLAUSE: _SYMB_143 EVENT_VAR  */
#line 1213 "HAL_S.y"
                                    { (yyval.signal_clause_) = make_AAsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6779 "Parser.c"
    break;

  case 444: /* SIGNAL_CLAUSE: _SYMB_134 EVENT_VAR  */
#line 1214 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ABsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6785 "Parser.c"
    break;

  case 445: /* SIGNAL_CLAUSE: _SYMB_147 EVENT_VAR  */
#line 1215 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ACsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6791 "Parser.c"
    break;

  case 446: /* PERCENT_MACRO_NAME: _SYMB_29 IDENTIFIER  */
#line 1217 "HAL_S.y"
                                         { (yyval.percent_macro_name_) = make_FNpercent_macro_name((yyvsp[0].identifier_)); (yyval.percent_macro_name_)->line_number = (yyloc).first_line; (yyval.percent_macro_name_)->char_number = (yyloc).first_column;  }
#line 6797 "Parser.c"
    break;

  case 447: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_NAME _SYMB_2  */
#line 1219 "HAL_S.y"
                                                { (yyval.percent_macro_head_) = make_AApercent_macro_head((yyvsp[-1].percent_macro_name_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 6803 "Parser.c"
    break;

  case 448: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_0  */
#line 1220 "HAL_S.y"
                                                 { (yyval.percent_macro_head_) = make_ABpercent_macro_head((yyvsp[-2].percent_macro_head_), (yyvsp[-1].percent_macro_arg_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 6809 "Parser.c"
    break;

  case 449: /* PERCENT_MACRO_ARG: NAME_VAR  */
#line 1222 "HAL_S.y"
                             { (yyval.percent_macro_arg_) = make_AApercent_macro_arg((yyvsp[0].name_var_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 6815 "Parser.c"
    break;

  case 450: /* PERCENT_MACRO_ARG: CONSTANT  */
#line 1223 "HAL_S.y"
             { (yyval.percent_macro_arg_) = make_ABpercent_macro_arg((yyvsp[0].constant_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 6821 "Parser.c"
    break;

  case 451: /* CASE_ELSE: _SYMB_72 _SYMB_53 ARITH_EXP _SYMB_16 _SYMB_74  */
#line 1225 "HAL_S.y"
                                                          { (yyval.case_else_) = make_AAcase_else((yyvsp[-2].arith_exp_)); (yyval.case_else_)->line_number = (yyloc).first_line; (yyval.case_else_)->char_number = (yyloc).first_column;  }
#line 6827 "Parser.c"
    break;

  case 452: /* WHILE_KEY: _SYMB_178  */
#line 1227 "HAL_S.y"
                      { (yyval.while_key_) = make_AAwhileKeyWhile(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 6833 "Parser.c"
    break;

  case 453: /* WHILE_KEY: _SYMB_174  */
#line 1228 "HAL_S.y"
              { (yyval.while_key_) = make_ABwhileKeyUntil(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 6839 "Parser.c"
    break;

  case 454: /* WHILE_CLAUSE: WHILE_KEY BIT_EXP  */
#line 1230 "HAL_S.y"
                                 { (yyval.while_clause_) = make_AAwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 6845 "Parser.c"
    break;

  case 455: /* WHILE_CLAUSE: WHILE_KEY RELATIONAL_EXP  */
#line 1231 "HAL_S.y"
                             { (yyval.while_clause_) = make_ABwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].relational_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 6851 "Parser.c"
    break;

  case 456: /* FOR_LIST: FOR_KEY ARITH_EXP ITERATION_CONTROL  */
#line 1233 "HAL_S.y"
                                               { (yyval.for_list_) = make_AAfor_list((yyvsp[-2].for_key_), (yyvsp[-1].arith_exp_), (yyvsp[0].iteration_control_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 6857 "Parser.c"
    break;

  case 457: /* FOR_LIST: FOR_KEY ITERATION_BODY  */
#line 1234 "HAL_S.y"
                           { (yyval.for_list_) = make_ABfor_list((yyvsp[-1].for_key_), (yyvsp[0].iteration_body_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 6863 "Parser.c"
    break;

  case 458: /* ITERATION_BODY: ARITH_EXP  */
#line 1236 "HAL_S.y"
                           { (yyval.iteration_body_) = make_AAiteration_body((yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 6869 "Parser.c"
    break;

  case 459: /* ITERATION_BODY: ITERATION_BODY _SYMB_0 ARITH_EXP  */
#line 1237 "HAL_S.y"
                                     { (yyval.iteration_body_) = make_ABiteration_body((yyvsp[-2].iteration_body_), (yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 6875 "Parser.c"
    break;

  case 460: /* ITERATION_CONTROL: _SYMB_167 ARITH_EXP  */
#line 1239 "HAL_S.y"
                                        { (yyval.iteration_control_) = make_AAiteration_controlTo((yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 6881 "Parser.c"
    break;

  case 461: /* ITERATION_CONTROL: _SYMB_167 ARITH_EXP _SYMB_50 ARITH_EXP  */
#line 1240 "HAL_S.y"
                                           { (yyval.iteration_control_) = make_ABiteration_controlToBy((yyvsp[-2].arith_exp_), (yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 6887 "Parser.c"
    break;

  case 462: /* FOR_KEY: _SYMB_88 ARITH_VAR EQUALS  */
#line 1242 "HAL_S.y"
                                    { (yyval.for_key_) = make_AAforKey((yyvsp[-1].arith_var_), (yyvsp[0].equals_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 6893 "Parser.c"
    break;

  case 463: /* FOR_KEY: _SYMB_88 _SYMB_164 IDENTIFIER _SYMB_25  */
#line 1243 "HAL_S.y"
                                           { (yyval.for_key_) = make_ABforKeyTemporary((yyvsp[-1].identifier_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 6899 "Parser.c"
    break;

  case 464: /* TEMPORARY_STMT: _SYMB_164 DECLARE_BODY _SYMB_16  */
#line 1245 "HAL_S.y"
                                                 { (yyval.temporary_stmt_) = make_AAtemporary_stmt((yyvsp[-1].declare_body_)); (yyval.temporary_stmt_)->line_number = (yyloc).first_line; (yyval.temporary_stmt_)->char_number = (yyloc).first_column;  }
#line 6905 "Parser.c"
    break;

  case 465: /* CONSTANT: NUMBER  */
#line 1247 "HAL_S.y"
                  { (yyval.constant_) = make_AAconstant((yyvsp[0].number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6911 "Parser.c"
    break;

  case 466: /* CONSTANT: COMPOUND_NUMBER  */
#line 1248 "HAL_S.y"
                    { (yyval.constant_) = make_ABconstant((yyvsp[0].compound_number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6917 "Parser.c"
    break;

  case 467: /* CONSTANT: BIT_CONST  */
#line 1249 "HAL_S.y"
              { (yyval.constant_) = make_ACconstant((yyvsp[0].bit_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6923 "Parser.c"
    break;

  case 468: /* CONSTANT: CHAR_CONST  */
#line 1250 "HAL_S.y"
               { (yyval.constant_) = make_ADconstant((yyvsp[0].char_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6929 "Parser.c"
    break;

  case 469: /* ARRAY_HEAD: _SYMB_43 _SYMB_2  */
#line 1252 "HAL_S.y"
                              { (yyval.array_head_) = make_AAarray_head(); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 6935 "Parser.c"
    break;

  case 470: /* ARRAY_HEAD: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_0  */
#line 1253 "HAL_S.y"
                                           { (yyval.array_head_) = make_ABarray_head((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 6941 "Parser.c"
    break;

  case 471: /* MINOR_ATTR_LIST: MINOR_ATTRIBUTE  */
#line 1255 "HAL_S.y"
                                  { (yyval.minor_attr_list_) = make_AAminor_attr_list((yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 6947 "Parser.c"
    break;

  case 472: /* MINOR_ATTR_LIST: MINOR_ATTR_LIST MINOR_ATTRIBUTE  */
#line 1256 "HAL_S.y"
                                    { (yyval.minor_attr_list_) = make_ABminor_attr_list((yyvsp[-1].minor_attr_list_), (yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 6953 "Parser.c"
    break;

  case 473: /* MINOR_ATTRIBUTE: _SYMB_155  */
#line 1258 "HAL_S.y"
                            { (yyval.minor_attribute_) = make_AAminorAttributeStatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 6959 "Parser.c"
    break;

  case 474: /* MINOR_ATTRIBUTE: _SYMB_46  */
#line 1259 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ABminorAttributeAutomatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 6965 "Parser.c"
    break;

  case 475: /* MINOR_ATTRIBUTE: _SYMB_68  */
#line 1260 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ACminorAttributeDense(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 6971 "Parser.c"
    break;

  case 476: /* MINOR_ATTRIBUTE: _SYMB_34  */
#line 1261 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ADminorAttributeAligned(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 6977 "Parser.c"
    break;

  case 477: /* MINOR_ATTRIBUTE: _SYMB_32  */
#line 1262 "HAL_S.y"
             { (yyval.minor_attribute_) = make_AEminorAttributeAccess(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 6983 "Parser.c"
    break;

  case 478: /* MINOR_ATTRIBUTE: _SYMB_103 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1263 "HAL_S.y"
                                                  { (yyval.minor_attribute_) = make_AFminorAttributeLock((yyvsp[-1].literal_exp_or_star_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 6989 "Parser.c"
    break;

  case 479: /* MINOR_ATTRIBUTE: _SYMB_131  */
#line 1264 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AGminorAttributeRemote(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 6995 "Parser.c"
    break;

  case 480: /* MINOR_ATTRIBUTE: _SYMB_136  */
#line 1265 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AHminorAttributeRigid(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7001 "Parser.c"
    break;

  case 481: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_1  */
#line 1266 "HAL_S.y"
                                                 { (yyval.minor_attribute_) = make_AIminorAttributeRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7007 "Parser.c"
    break;

  case 482: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD _SYMB_6 _SYMB_1  */
#line 1267 "HAL_S.y"
                                       { (yyval.minor_attribute_) = make_AJminorAttributeStar((yyvsp[-2].init_or_const_head_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7013 "Parser.c"
    break;

  case 483: /* MINOR_ATTRIBUTE: _SYMB_99  */
#line 1268 "HAL_S.y"
             { (yyval.minor_attribute_) = make_AKminorAttributeLatched(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7019 "Parser.c"
    break;

  case 484: /* MINOR_ATTRIBUTE: _SYMB_112 _SYMB_2 LEVEL _SYMB_1  */
#line 1269 "HAL_S.y"
                                    { (yyval.minor_attribute_) = make_ALminorAttributeNonHal((yyvsp[-1].level_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7025 "Parser.c"
    break;

  case 485: /* INIT_OR_CONST_HEAD: _SYMB_96 _SYMB_2  */
#line 1271 "HAL_S.y"
                                      { (yyval.init_or_const_head_) = make_AAinit_or_const_headInitial(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7031 "Parser.c"
    break;

  case 486: /* INIT_OR_CONST_HEAD: _SYMB_62 _SYMB_2  */
#line 1272 "HAL_S.y"
                     { (yyval.init_or_const_head_) = make_ABinit_or_const_headConstant(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7037 "Parser.c"
    break;

  case 487: /* INIT_OR_CONST_HEAD: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_0  */
#line 1273 "HAL_S.y"
                                                 { (yyval.init_or_const_head_) = make_ACinit_or_const_headRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7043 "Parser.c"
    break;

  case 488: /* REPEATED_CONSTANT: EXPRESSION  */
#line 1275 "HAL_S.y"
                               { (yyval.repeated_constant_) = make_AArepeated_constant((yyvsp[0].expression_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7049 "Parser.c"
    break;

  case 489: /* REPEATED_CONSTANT: REPEAT_HEAD VARIABLE  */
#line 1276 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ABrepeated_constant((yyvsp[-1].repeat_head_), (yyvsp[0].variable_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7055 "Parser.c"
    break;

  case 490: /* REPEATED_CONSTANT: REPEAT_HEAD CONSTANT  */
#line 1277 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ACrepeated_constant((yyvsp[-1].repeat_head_), (yyvsp[0].constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7061 "Parser.c"
    break;

  case 491: /* REPEATED_CONSTANT: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_1  */
#line 1278 "HAL_S.y"
                                                 { (yyval.repeated_constant_) = make_ADrepeated_constant((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7067 "Parser.c"
    break;

  case 492: /* REPEATED_CONSTANT: REPEAT_HEAD  */
#line 1279 "HAL_S.y"
                { (yyval.repeated_constant_) = make_AErepeated_constant((yyvsp[0].repeat_head_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7073 "Parser.c"
    break;

  case 493: /* REPEAT_HEAD: ARITH_EXP _SYMB_9 SIMPLE_NUMBER  */
#line 1281 "HAL_S.y"
                                              { (yyval.repeat_head_) = make_AArepeat_head((yyvsp[-2].arith_exp_), (yyvsp[0].simple_number_)); (yyval.repeat_head_)->line_number = (yyloc).first_line; (yyval.repeat_head_)->char_number = (yyloc).first_column;  }
#line 7079 "Parser.c"
    break;

  case 494: /* NESTED_REPEAT_HEAD: REPEAT_HEAD _SYMB_2  */
#line 1283 "HAL_S.y"
                                         { (yyval.nested_repeat_head_) = make_AAnested_repeat_head((yyvsp[-1].repeat_head_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 7085 "Parser.c"
    break;

  case 495: /* NESTED_REPEAT_HEAD: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_0  */
#line 1284 "HAL_S.y"
                                                 { (yyval.nested_repeat_head_) = make_ABnested_repeat_head((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 7091 "Parser.c"
    break;

  case 496: /* DCL_LIST_COMMA: DECLARATION_LIST _SYMB_0  */
#line 1286 "HAL_S.y"
                                          { (yyval.dcl_list_comma_) = make_AAdcl_list_comma((yyvsp[-1].declaration_list_)); (yyval.dcl_list_comma_)->line_number = (yyloc).first_line; (yyval.dcl_list_comma_)->char_number = (yyloc).first_column;  }
#line 7097 "Parser.c"
    break;

  case 497: /* LITERAL_EXP_OR_STAR: ARITH_EXP  */
#line 1288 "HAL_S.y"
                                { (yyval.literal_exp_or_star_) = make_AAliteralExp((yyvsp[0].arith_exp_)); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7103 "Parser.c"
    break;

  case 498: /* LITERAL_EXP_OR_STAR: _SYMB_6  */
#line 1289 "HAL_S.y"
            { (yyval.literal_exp_or_star_) = make_ABliteralStar(); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7109 "Parser.c"
    break;

  case 499: /* TYPE_SPEC: STRUCT_SPEC  */
#line 1291 "HAL_S.y"
                        { (yyval.type_spec_) = make_AAtypeSpecStruct((yyvsp[0].struct_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7115 "Parser.c"
    break;

  case 500: /* TYPE_SPEC: BIT_SPEC  */
#line 1292 "HAL_S.y"
             { (yyval.type_spec_) = make_ABtypeSpecBit((yyvsp[0].bit_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7121 "Parser.c"
    break;

  case 501: /* TYPE_SPEC: CHAR_SPEC  */
#line 1293 "HAL_S.y"
              { (yyval.type_spec_) = make_ACtypeSpecChar((yyvsp[0].char_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7127 "Parser.c"
    break;

  case 502: /* TYPE_SPEC: ARITH_SPEC  */
#line 1294 "HAL_S.y"
               { (yyval.type_spec_) = make_ADtypeSpecArith((yyvsp[0].arith_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7133 "Parser.c"
    break;

  case 503: /* TYPE_SPEC: _SYMB_79  */
#line 1295 "HAL_S.y"
             { (yyval.type_spec_) = make_AEtypeSpecEvent(); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7139 "Parser.c"
    break;

  case 504: /* BIT_SPEC: _SYMB_49  */
#line 1297 "HAL_S.y"
                    { (yyval.bit_spec_) = make_AAbitSpecBoolean(); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7145 "Parser.c"
    break;

  case 505: /* BIT_SPEC: _SYMB_48 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1298 "HAL_S.y"
                                                 { (yyval.bit_spec_) = make_ABbitSpecBoolean((yyvsp[-1].literal_exp_or_star_)); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7151 "Parser.c"
    break;

  case 506: /* CHAR_SPEC: _SYMB_57 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1300 "HAL_S.y"
                                                         { (yyval.char_spec_) = make_AAchar_spec((yyvsp[-1].literal_exp_or_star_)); (yyval.char_spec_)->line_number = (yyloc).first_line; (yyval.char_spec_)->char_number = (yyloc).first_column;  }
#line 7157 "Parser.c"
    break;

  case 507: /* STRUCT_SPEC: STRUCT_TEMPLATE STRUCT_SPEC_BODY  */
#line 1302 "HAL_S.y"
                                               { (yyval.struct_spec_) = make_AAstruct_spec((yyvsp[-1].struct_template_), (yyvsp[0].struct_spec_body_)); (yyval.struct_spec_)->line_number = (yyloc).first_line; (yyval.struct_spec_)->char_number = (yyloc).first_column;  }
#line 7163 "Parser.c"
    break;

  case 508: /* STRUCT_SPEC_BODY: _SYMB_5 _SYMB_156  */
#line 1304 "HAL_S.y"
                                     { (yyval.struct_spec_body_) = make_AAstruct_spec_body(); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7169 "Parser.c"
    break;

  case 509: /* STRUCT_SPEC_BODY: STRUCT_SPEC_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1305 "HAL_S.y"
                                                 { (yyval.struct_spec_body_) = make_ABstruct_spec_body((yyvsp[-2].struct_spec_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7175 "Parser.c"
    break;

  case 510: /* STRUCT_TEMPLATE: STRUCTURE_ID  */
#line 1307 "HAL_S.y"
                               { (yyval.struct_template_) = make_FMstruct_template((yyvsp[0].structure_id_)); (yyval.struct_template_)->line_number = (yyloc).first_line; (yyval.struct_template_)->char_number = (yyloc).first_column;  }
#line 7181 "Parser.c"
    break;

  case 511: /* STRUCT_SPEC_HEAD: _SYMB_5 _SYMB_156 _SYMB_2  */
#line 1309 "HAL_S.y"
                                             { (yyval.struct_spec_head_) = make_AAstruct_spec_head(); (yyval.struct_spec_head_)->line_number = (yyloc).first_line; (yyval.struct_spec_head_)->char_number = (yyloc).first_column;  }
#line 7187 "Parser.c"
    break;

  case 512: /* ARITH_SPEC: PREC_SPEC  */
#line 1311 "HAL_S.y"
                       { (yyval.arith_spec_) = make_AAarith_spec((yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7193 "Parser.c"
    break;

  case 513: /* ARITH_SPEC: SQ_DQ_NAME  */
#line 1312 "HAL_S.y"
               { (yyval.arith_spec_) = make_ABarith_spec((yyvsp[0].sq_dq_name_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7199 "Parser.c"
    break;

  case 514: /* ARITH_SPEC: SQ_DQ_NAME PREC_SPEC  */
#line 1313 "HAL_S.y"
                         { (yyval.arith_spec_) = make_ACarith_spec((yyvsp[-1].sq_dq_name_), (yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7205 "Parser.c"
    break;

  case 515: /* COMPILATION: ANY_STATEMENT  */
#line 1315 "HAL_S.y"
                            { (yyval.compilation_) = make_AAcompilation((yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7211 "Parser.c"
    break;

  case 516: /* COMPILATION: COMPILATION ANY_STATEMENT  */
#line 1316 "HAL_S.y"
                              { (yyval.compilation_) = make_ABcompilation((yyvsp[-1].compilation_), (yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7217 "Parser.c"
    break;

  case 517: /* COMPILATION: DECLARE_STATEMENT  */
#line 1317 "HAL_S.y"
                      { (yyval.compilation_) = make_ACcompilation((yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7223 "Parser.c"
    break;

  case 518: /* COMPILATION: COMPILATION DECLARE_STATEMENT  */
#line 1318 "HAL_S.y"
                                  { (yyval.compilation_) = make_ADcompilation((yyvsp[-1].compilation_), (yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7229 "Parser.c"
    break;

  case 519: /* COMPILATION: STRUCTURE_STMT  */
#line 1319 "HAL_S.y"
                   { (yyval.compilation_) = make_AEcompilation((yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7235 "Parser.c"
    break;

  case 520: /* COMPILATION: COMPILATION STRUCTURE_STMT  */
#line 1320 "HAL_S.y"
                               { (yyval.compilation_) = make_AFcompilation((yyvsp[-1].compilation_), (yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7241 "Parser.c"
    break;

  case 521: /* COMPILATION: REPLACE_STMT _SYMB_16  */
#line 1321 "HAL_S.y"
                          { (yyval.compilation_) = make_AGcompilation((yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7247 "Parser.c"
    break;

  case 522: /* COMPILATION: COMPILATION REPLACE_STMT _SYMB_16  */
#line 1322 "HAL_S.y"
                                      { (yyval.compilation_) = make_AHcompilation((yyvsp[-2].compilation_), (yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7253 "Parser.c"
    break;

  case 523: /* BLOCK_DEFINITION: BLOCK_STMT CLOSING _SYMB_16  */
#line 1324 "HAL_S.y"
                                               { (yyval.block_definition_) = make_AAblock_definition((yyvsp[-2].block_stmt_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7259 "Parser.c"
    break;

  case 524: /* BLOCK_DEFINITION: BLOCK_STMT BLOCK_BODY CLOSING _SYMB_16  */
#line 1325 "HAL_S.y"
                                           { (yyval.block_definition_) = make_ABblock_definition((yyvsp[-3].block_stmt_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7265 "Parser.c"
    break;

  case 525: /* BLOCK_STMT: BLOCK_STMT_TOP _SYMB_16  */
#line 1327 "HAL_S.y"
                                     { (yyval.block_stmt_) = make_AAblock_stmt((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_)->line_number = (yyloc).first_line; (yyval.block_stmt_)->char_number = (yyloc).first_column;  }
#line 7271 "Parser.c"
    break;

  case 526: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_32  */
#line 1329 "HAL_S.y"
                                         { (yyval.block_stmt_top_) = make_AAblockTopAccess((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7277 "Parser.c"
    break;

  case 527: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_136  */
#line 1330 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ABblockTopRigid((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7283 "Parser.c"
    break;

  case 528: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD  */
#line 1331 "HAL_S.y"
                    { (yyval.block_stmt_top_) = make_ACblockTopHead((yyvsp[0].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7289 "Parser.c"
    break;

  case 529: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_81  */
#line 1332 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ADblockTopExclusive((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7295 "Parser.c"
    break;

  case 530: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_129  */
#line 1333 "HAL_S.y"
                              { (yyval.block_stmt_top_) = make_AEblockTopReentrant((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7301 "Parser.c"
    break;

  case 531: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_125  */
#line 1335 "HAL_S.y"
                                           { (yyval.block_stmt_head_) = make_AAblockHeadProgram((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7307 "Parser.c"
    break;

  case 532: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_61  */
#line 1336 "HAL_S.y"
                            { (yyval.block_stmt_head_) = make_ABblockHeadCompool((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7313 "Parser.c"
    break;

  case 533: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_163  */
#line 1337 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ACblockHeadTask((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7319 "Parser.c"
    break;

  case 534: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_175  */
#line 1338 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ADblockHeadUpdate((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7325 "Parser.c"
    break;

  case 535: /* BLOCK_STMT_HEAD: _SYMB_175  */
#line 1339 "HAL_S.y"
              { (yyval.block_stmt_head_) = make_AEblockHeadUpdate(); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7331 "Parser.c"
    break;

  case 536: /* BLOCK_STMT_HEAD: FUNCTION_NAME  */
#line 1340 "HAL_S.y"
                  { (yyval.block_stmt_head_) = make_AFblockHeadFunction((yyvsp[0].function_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7337 "Parser.c"
    break;

  case 537: /* BLOCK_STMT_HEAD: FUNCTION_NAME FUNC_STMT_BODY  */
#line 1341 "HAL_S.y"
                                 { (yyval.block_stmt_head_) = make_AGblockHeadFunction((yyvsp[-1].function_name_), (yyvsp[0].func_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7343 "Parser.c"
    break;

  case 538: /* BLOCK_STMT_HEAD: PROCEDURE_NAME  */
#line 1342 "HAL_S.y"
                   { (yyval.block_stmt_head_) = make_AHblockHeadProcedure((yyvsp[0].procedure_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7349 "Parser.c"
    break;

  case 539: /* BLOCK_STMT_HEAD: PROCEDURE_NAME PROC_STMT_BODY  */
#line 1343 "HAL_S.y"
                                  { (yyval.block_stmt_head_) = make_AIblockHeadProcedure((yyvsp[-1].procedure_name_), (yyvsp[0].proc_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7355 "Parser.c"
    break;

  case 540: /* LABEL_EXTERNAL: LABEL_DEFINITION  */
#line 1345 "HAL_S.y"
                                  { (yyval.label_external_) = make_AAlabel_external((yyvsp[0].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7361 "Parser.c"
    break;

  case 541: /* LABEL_EXTERNAL: LABEL_DEFINITION _SYMB_84  */
#line 1346 "HAL_S.y"
                              { (yyval.label_external_) = make_ABlabel_external((yyvsp[-1].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7367 "Parser.c"
    break;

  case 542: /* CLOSING: _SYMB_59  */
#line 1348 "HAL_S.y"
                   { (yyval.closing_) = make_AAclosing(); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7373 "Parser.c"
    break;

  case 543: /* CLOSING: _SYMB_59 LABEL  */
#line 1349 "HAL_S.y"
                   { (yyval.closing_) = make_ABclosing((yyvsp[0].label_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7379 "Parser.c"
    break;

  case 544: /* CLOSING: LABEL_DEFINITION CLOSING  */
#line 1350 "HAL_S.y"
                             { (yyval.closing_) = make_ACclosing((yyvsp[-1].label_definition_), (yyvsp[0].closing_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7385 "Parser.c"
    break;

  case 545: /* BLOCK_BODY: DECLARE_GROUP  */
#line 1352 "HAL_S.y"
                           { (yyval.block_body_) = make_ABblock_body((yyvsp[0].declare_group_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7391 "Parser.c"
    break;

  case 546: /* BLOCK_BODY: ANY_STATEMENT  */
#line 1353 "HAL_S.y"
                  { (yyval.block_body_) = make_ADblock_body((yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7397 "Parser.c"
    break;

  case 547: /* BLOCK_BODY: BLOCK_BODY ANY_STATEMENT  */
#line 1354 "HAL_S.y"
                             { (yyval.block_body_) = make_ACblock_body((yyvsp[-1].block_body_), (yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7403 "Parser.c"
    break;

  case 548: /* FUNCTION_NAME: LABEL_EXTERNAL _SYMB_89  */
#line 1356 "HAL_S.y"
                                        { (yyval.function_name_) = make_AAfunction_name((yyvsp[-1].label_external_)); (yyval.function_name_)->line_number = (yyloc).first_line; (yyval.function_name_)->char_number = (yyloc).first_column;  }
#line 7409 "Parser.c"
    break;

  case 549: /* PROCEDURE_NAME: LABEL_EXTERNAL _SYMB_123  */
#line 1358 "HAL_S.y"
                                          { (yyval.procedure_name_) = make_AAprocedure_name((yyvsp[-1].label_external_)); (yyval.procedure_name_)->line_number = (yyloc).first_line; (yyval.procedure_name_)->char_number = (yyloc).first_column;  }
#line 7415 "Parser.c"
    break;

  case 550: /* FUNC_STMT_BODY: PARAMETER_LIST  */
#line 1360 "HAL_S.y"
                                { (yyval.func_stmt_body_) = make_AAfunc_stmt_body((yyvsp[0].parameter_list_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7421 "Parser.c"
    break;

  case 551: /* FUNC_STMT_BODY: TYPE_SPEC  */
#line 1361 "HAL_S.y"
              { (yyval.func_stmt_body_) = make_ABfunc_stmt_body((yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7427 "Parser.c"
    break;

  case 552: /* FUNC_STMT_BODY: PARAMETER_LIST TYPE_SPEC  */
#line 1362 "HAL_S.y"
                             { (yyval.func_stmt_body_) = make_ACfunc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7433 "Parser.c"
    break;

  case 553: /* PROC_STMT_BODY: PARAMETER_LIST  */
#line 1364 "HAL_S.y"
                                { (yyval.proc_stmt_body_) = make_AAproc_stmt_body((yyvsp[0].parameter_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7439 "Parser.c"
    break;

  case 554: /* PROC_STMT_BODY: ASSIGN_LIST  */
#line 1365 "HAL_S.y"
                { (yyval.proc_stmt_body_) = make_ABproc_stmt_body((yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7445 "Parser.c"
    break;

  case 555: /* PROC_STMT_BODY: PARAMETER_LIST ASSIGN_LIST  */
#line 1366 "HAL_S.y"
                               { (yyval.proc_stmt_body_) = make_ACproc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7451 "Parser.c"
    break;

  case 556: /* DECLARE_GROUP: DECLARE_ELEMENT  */
#line 1368 "HAL_S.y"
                                { (yyval.declare_group_) = make_AAdeclare_group((yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7457 "Parser.c"
    break;

  case 557: /* DECLARE_GROUP: DECLARE_GROUP DECLARE_ELEMENT  */
#line 1369 "HAL_S.y"
                                  { (yyval.declare_group_) = make_ABdeclare_group((yyvsp[-1].declare_group_), (yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7463 "Parser.c"
    break;

  case 558: /* DECLARE_ELEMENT: DECLARE_STATEMENT  */
#line 1371 "HAL_S.y"
                                    { (yyval.declare_element_) = make_AAdeclareElementDeclare((yyvsp[0].declare_statement_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7469 "Parser.c"
    break;

  case 559: /* DECLARE_ELEMENT: REPLACE_STMT _SYMB_16  */
#line 1372 "HAL_S.y"
                          { (yyval.declare_element_) = make_ABdeclareElementReplace((yyvsp[-1].replace_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7475 "Parser.c"
    break;

  case 560: /* DECLARE_ELEMENT: STRUCTURE_STMT  */
#line 1373 "HAL_S.y"
                   { (yyval.declare_element_) = make_ACdeclareElementStructure((yyvsp[0].structure_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7481 "Parser.c"
    break;

  case 561: /* DECLARE_ELEMENT: _SYMB_76 _SYMB_84 IDENTIFIER _SYMB_167 VARIABLE _SYMB_16  */
#line 1374 "HAL_S.y"
                                                             { (yyval.declare_element_) = make_ADdeclareElementEquate((yyvsp[-3].identifier_), (yyvsp[-1].variable_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7487 "Parser.c"
    break;

  case 562: /* PARAMETER: _SYMB_190  */
#line 1376 "HAL_S.y"
                      { (yyval.parameter_) = make_AAparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7493 "Parser.c"
    break;

  case 563: /* PARAMETER: _SYMB_181  */
#line 1377 "HAL_S.y"
              { (yyval.parameter_) = make_ABparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7499 "Parser.c"
    break;

  case 564: /* PARAMETER: _SYMB_184  */
#line 1378 "HAL_S.y"
              { (yyval.parameter_) = make_ACparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7505 "Parser.c"
    break;

  case 565: /* PARAMETER: _SYMB_185  */
#line 1379 "HAL_S.y"
              { (yyval.parameter_) = make_ADparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7511 "Parser.c"
    break;

  case 566: /* PARAMETER: _SYMB_188  */
#line 1380 "HAL_S.y"
              { (yyval.parameter_) = make_AEparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7517 "Parser.c"
    break;

  case 567: /* PARAMETER: _SYMB_187  */
#line 1381 "HAL_S.y"
              { (yyval.parameter_) = make_AFparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7523 "Parser.c"
    break;

  case 568: /* PARAMETER_LIST: PARAMETER_HEAD PARAMETER _SYMB_1  */
#line 1383 "HAL_S.y"
                                                  { (yyval.parameter_list_) = make_AAparameter_list((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_list_)->line_number = (yyloc).first_line; (yyval.parameter_list_)->char_number = (yyloc).first_column;  }
#line 7529 "Parser.c"
    break;

  case 569: /* PARAMETER_HEAD: _SYMB_2  */
#line 1385 "HAL_S.y"
                         { (yyval.parameter_head_) = make_AAparameter_head(); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 7535 "Parser.c"
    break;

  case 570: /* PARAMETER_HEAD: PARAMETER_HEAD PARAMETER _SYMB_0  */
#line 1386 "HAL_S.y"
                                     { (yyval.parameter_head_) = make_ABparameter_head((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 7541 "Parser.c"
    break;

  case 571: /* DECLARE_STATEMENT: _SYMB_67 DECLARE_BODY _SYMB_16  */
#line 1388 "HAL_S.y"
                                                   { (yyval.declare_statement_) = make_AAdeclare_statement((yyvsp[-1].declare_body_)); (yyval.declare_statement_)->line_number = (yyloc).first_line; (yyval.declare_statement_)->char_number = (yyloc).first_column;  }
#line 7547 "Parser.c"
    break;

  case 572: /* ASSIGN_LIST: ASSIGN PARAMETER_LIST  */
#line 1390 "HAL_S.y"
                                    { (yyval.assign_list_) = make_AAassign_list((yyvsp[-1].assign_), (yyvsp[0].parameter_list_)); (yyval.assign_list_)->line_number = (yyloc).first_line; (yyval.assign_list_)->char_number = (yyloc).first_column;  }
#line 7553 "Parser.c"
    break;

  case 573: /* TEXT: _SYMB_192  */
#line 1392 "HAL_S.y"
                 { (yyval.text_) = make_FQtext((yyvsp[0].string_)); (yyval.text_)->line_number = (yyloc).first_line; (yyval.text_)->char_number = (yyloc).first_column;  }
#line 7559 "Parser.c"
    break;

  case 574: /* REPLACE_STMT: _SYMB_133 REPLACE_HEAD _SYMB_50 TEXT  */
#line 1394 "HAL_S.y"
                                                    { (yyval.replace_stmt_) = make_AAreplace_stmt((yyvsp[-2].replace_head_), (yyvsp[0].text_)); (yyval.replace_stmt_)->line_number = (yyloc).first_line; (yyval.replace_stmt_)->char_number = (yyloc).first_column;  }
#line 7565 "Parser.c"
    break;

  case 575: /* REPLACE_HEAD: IDENTIFIER  */
#line 1396 "HAL_S.y"
                          { (yyval.replace_head_) = make_AAreplace_head((yyvsp[0].identifier_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 7571 "Parser.c"
    break;

  case 576: /* REPLACE_HEAD: IDENTIFIER _SYMB_2 ARG_LIST _SYMB_1  */
#line 1397 "HAL_S.y"
                                        { (yyval.replace_head_) = make_ABreplace_head((yyvsp[-3].identifier_), (yyvsp[-1].arg_list_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 7577 "Parser.c"
    break;

  case 577: /* ARG_LIST: IDENTIFIER  */
#line 1399 "HAL_S.y"
                      { (yyval.arg_list_) = make_AAarg_list((yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 7583 "Parser.c"
    break;

  case 578: /* ARG_LIST: ARG_LIST _SYMB_0 IDENTIFIER  */
#line 1400 "HAL_S.y"
                                { (yyval.arg_list_) = make_ABarg_list((yyvsp[-2].arg_list_), (yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 7589 "Parser.c"
    break;

  case 579: /* STRUCTURE_STMT: _SYMB_156 STRUCT_STMT_HEAD STRUCT_STMT_TAIL  */
#line 1402 "HAL_S.y"
                                                             { (yyval.structure_stmt_) = make_AAstructure_stmt((yyvsp[-1].struct_stmt_head_), (yyvsp[0].struct_stmt_tail_)); (yyval.structure_stmt_)->line_number = (yyloc).first_line; (yyval.structure_stmt_)->char_number = (yyloc).first_column;  }
#line 7595 "Parser.c"
    break;

  case 580: /* STRUCT_STMT_HEAD: STRUCTURE_ID _SYMB_17 LEVEL  */
#line 1404 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_AAstruct_stmt_head((yyvsp[-2].structure_id_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7601 "Parser.c"
    break;

  case 581: /* STRUCT_STMT_HEAD: STRUCTURE_ID MINOR_ATTR_LIST _SYMB_17 LEVEL  */
#line 1405 "HAL_S.y"
                                                { (yyval.struct_stmt_head_) = make_ABstruct_stmt_head((yyvsp[-3].structure_id_), (yyvsp[-2].minor_attr_list_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7607 "Parser.c"
    break;

  case 582: /* STRUCT_STMT_HEAD: STRUCT_STMT_HEAD DECLARATION _SYMB_0 LEVEL  */
#line 1406 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_ACstruct_stmt_head((yyvsp[-3].struct_stmt_head_), (yyvsp[-2].declaration_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7613 "Parser.c"
    break;

  case 583: /* STRUCT_STMT_TAIL: DECLARATION _SYMB_16  */
#line 1408 "HAL_S.y"
                                        { (yyval.struct_stmt_tail_) = make_AAstruct_stmt_tail((yyvsp[-1].declaration_)); (yyval.struct_stmt_tail_)->line_number = (yyloc).first_line; (yyval.struct_stmt_tail_)->char_number = (yyloc).first_column;  }
#line 7619 "Parser.c"
    break;

  case 584: /* INLINE_DEFINITION: ARITH_INLINE  */
#line 1410 "HAL_S.y"
                                 { (yyval.inline_definition_) = make_AAinline_definition((yyvsp[0].arith_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7625 "Parser.c"
    break;

  case 585: /* INLINE_DEFINITION: BIT_INLINE  */
#line 1411 "HAL_S.y"
               { (yyval.inline_definition_) = make_ABinline_definition((yyvsp[0].bit_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7631 "Parser.c"
    break;

  case 586: /* INLINE_DEFINITION: CHAR_INLINE  */
#line 1412 "HAL_S.y"
                { (yyval.inline_definition_) = make_ACinline_definition((yyvsp[0].char_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7637 "Parser.c"
    break;

  case 587: /* INLINE_DEFINITION: STRUCTURE_EXP  */
#line 1413 "HAL_S.y"
                  { (yyval.inline_definition_) = make_ADinline_definition((yyvsp[0].structure_exp_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7643 "Parser.c"
    break;

  case 588: /* ARITH_INLINE: ARITH_INLINE_DEF CLOSING _SYMB_16  */
#line 1415 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_ACprimary((yyvsp[-2].arith_inline_def_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 7649 "Parser.c"
    break;

  case 589: /* ARITH_INLINE: ARITH_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1416 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_AZprimary((yyvsp[-3].arith_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 7655 "Parser.c"
    break;

  case 590: /* ARITH_INLINE_DEF: _SYMB_89 ARITH_SPEC _SYMB_16  */
#line 1418 "HAL_S.y"
                                                { (yyval.arith_inline_def_) = make_AAarith_inline_def((yyvsp[-1].arith_spec_)); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 7661 "Parser.c"
    break;

  case 591: /* ARITH_INLINE_DEF: _SYMB_89 _SYMB_16  */
#line 1419 "HAL_S.y"
                      { (yyval.arith_inline_def_) = make_ABarith_inline_def(); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 7667 "Parser.c"
    break;

  case 592: /* BIT_INLINE: BIT_INLINE_DEF CLOSING _SYMB_16  */
#line 1421 "HAL_S.y"
                                             { (yyval.bit_inline_) = make_AGbit_prim((yyvsp[-2].bit_inline_def_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 7673 "Parser.c"
    break;

  case 593: /* BIT_INLINE: BIT_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1422 "HAL_S.y"
                                               { (yyval.bit_inline_) = make_AZbit_prim((yyvsp[-3].bit_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 7679 "Parser.c"
    break;

  case 594: /* BIT_INLINE_DEF: _SYMB_89 BIT_SPEC _SYMB_16  */
#line 1424 "HAL_S.y"
                                            { (yyval.bit_inline_def_) = make_AAbit_inline_def((yyvsp[-1].bit_spec_)); (yyval.bit_inline_def_)->line_number = (yyloc).first_line; (yyval.bit_inline_def_)->char_number = (yyloc).first_column;  }
#line 7685 "Parser.c"
    break;

  case 595: /* CHAR_INLINE: CHAR_INLINE_DEF CLOSING _SYMB_16  */
#line 1426 "HAL_S.y"
                                               { (yyval.char_inline_) = make_ADchar_prim((yyvsp[-2].char_inline_def_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 7691 "Parser.c"
    break;

  case 596: /* CHAR_INLINE: CHAR_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1427 "HAL_S.y"
                                                { (yyval.char_inline_) = make_AZchar_prim((yyvsp[-3].char_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 7697 "Parser.c"
    break;

  case 597: /* CHAR_INLINE_DEF: _SYMB_89 CHAR_SPEC _SYMB_16  */
#line 1429 "HAL_S.y"
                                              { (yyval.char_inline_def_) = make_AAchar_inline_def((yyvsp[-1].char_spec_)); (yyval.char_inline_def_)->line_number = (yyloc).first_line; (yyval.char_inline_def_)->char_number = (yyloc).first_column;  }
#line 7703 "Parser.c"
    break;

  case 598: /* STRUC_INLINE_DEF: _SYMB_89 STRUCT_SPEC _SYMB_16  */
#line 1431 "HAL_S.y"
                                                 { (yyval.struc_inline_def_) = make_AAstruc_inline_def((yyvsp[-1].struct_spec_)); (yyval.struc_inline_def_)->line_number = (yyloc).first_line; (yyval.struc_inline_def_)->char_number = (yyloc).first_column;  }
#line 7709 "Parser.c"
    break;


#line 7713 "Parser.c"

      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", YY_CAST (yysymbol_kind_t, yyr1[yyn]), &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;

  *++yyvsp = yyval;
  *++yylsp = yyloc;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */
  {
    const int yylhs = yyr1[yyn] - YYNTOKENS;
    const int yyi = yypgoto[yylhs] + *yyssp;
    yystate = (0 <= yyi && yyi <= YYLAST && yycheck[yyi] == *yyssp
               ? yytable[yyi]
               : yydefgoto[yylhs]);
  }

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYSYMBOL_YYEMPTY : YYTRANSLATE (yychar);
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
      yyerror (YY_("syntax error"));
    }

  yyerror_range[1] = yylloc;
  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval, &yylloc);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:
  /* Pacify compilers when the user code never invokes YYERROR and the
     label yyerrorlab therefore never appears in user code.  */
  if (0)
    YYERROR;
  ++yynerrs;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  /* Pop stack until we find a state that shifts the error token.  */
  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYSYMBOL_YYerror;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYSYMBOL_YYerror)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;

      yyerror_range[1] = *yylsp;
      yydestruct ("Error: popping",
                  YY_ACCESSING_SYMBOL (yystate), yyvsp, yylsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  yyerror_range[2] = yylloc;
  ++yylsp;
  YYLLOC_DEFAULT (*yylsp, yyerror_range, 2);

  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", YY_ACCESSING_SYMBOL (yyn), yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturnlab;


/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturnlab;


/*-----------------------------------------------------------.
| yyexhaustedlab -- YYNOMEM (memory exhaustion) comes here.  |
`-----------------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  goto yyreturnlab;


/*----------------------------------------------------------.
| yyreturnlab -- parsing is finished, clean up and return.  |
`----------------------------------------------------------*/
yyreturnlab:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval, &yylloc);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  YY_ACCESSING_SYMBOL (+*yyssp), yyvsp, yylsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif

  return yyresult;
}

#line 1434 "HAL_S.y"

void yyerror(const char *str)
{
  extern char *HAL_Stext;
  fprintf(stderr,"error: %d,%d: %s at %s\n",
  HAL_Slloc.first_line, HAL_Slloc.first_column, str, HAL_Stext);
}

