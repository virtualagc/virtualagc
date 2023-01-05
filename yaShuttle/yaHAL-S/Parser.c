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
    _SYMB_195 = 454,               /* _SYMB_195  */
    _SYMB_196 = 455,               /* _SYMB_196  */
    _SYMB_197 = 456,               /* _SYMB_197  */
    _SYMB_198 = 457                /* _SYMB_198  */
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


#line 576 "Parser.c"

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
  YYSYMBOL__SYMB_196 = 200,                /* _SYMB_196  */
  YYSYMBOL__SYMB_197 = 201,                /* _SYMB_197  */
  YYSYMBOL__SYMB_198 = 202,                /* _SYMB_198  */
  YYSYMBOL_YYACCEPT = 203,                 /* $accept  */
  YYSYMBOL_DECLARE_BODY = 204,             /* DECLARE_BODY  */
  YYSYMBOL_ATTRIBUTES = 205,               /* ATTRIBUTES  */
  YYSYMBOL_DECLARATION = 206,              /* DECLARATION  */
  YYSYMBOL_ARRAY_SPEC = 207,               /* ARRAY_SPEC  */
  YYSYMBOL_TYPE_AND_MINOR_ATTR = 208,      /* TYPE_AND_MINOR_ATTR  */
  YYSYMBOL_IDENTIFIER = 209,               /* IDENTIFIER  */
  YYSYMBOL_SQ_DQ_NAME = 210,               /* SQ_DQ_NAME  */
  YYSYMBOL_DOUBLY_QUAL_NAME_HEAD = 211,    /* DOUBLY_QUAL_NAME_HEAD  */
  YYSYMBOL_ARITH_CONV = 212,               /* ARITH_CONV  */
  YYSYMBOL_DECLARATION_LIST = 213,         /* DECLARATION_LIST  */
  YYSYMBOL_NAME_ID = 214,                  /* NAME_ID  */
  YYSYMBOL_ARITH_EXP = 215,                /* ARITH_EXP  */
  YYSYMBOL_TERM = 216,                     /* TERM  */
  YYSYMBOL_PLUS = 217,                     /* PLUS  */
  YYSYMBOL_MINUS = 218,                    /* MINUS  */
  YYSYMBOL_PRODUCT = 219,                  /* PRODUCT  */
  YYSYMBOL_FACTOR = 220,                   /* FACTOR  */
  YYSYMBOL_EXPONENTIATION = 221,           /* EXPONENTIATION  */
  YYSYMBOL_PRIMARY = 222,                  /* PRIMARY  */
  YYSYMBOL_ARITH_VAR = 223,                /* ARITH_VAR  */
  YYSYMBOL_PRE_PRIMARY = 224,              /* PRE_PRIMARY  */
  YYSYMBOL_NUMBER = 225,                   /* NUMBER  */
  YYSYMBOL_LEVEL = 226,                    /* LEVEL  */
  YYSYMBOL_COMPOUND_NUMBER = 227,          /* COMPOUND_NUMBER  */
  YYSYMBOL_SIMPLE_NUMBER = 228,            /* SIMPLE_NUMBER  */
  YYSYMBOL_MODIFIED_ARITH_FUNC = 229,      /* MODIFIED_ARITH_FUNC  */
  YYSYMBOL_ARITH_FUNC_HEAD = 230,          /* ARITH_FUNC_HEAD  */
  YYSYMBOL_CALL_LIST = 231,                /* CALL_LIST  */
  YYSYMBOL_LIST_EXP = 232,                 /* LIST_EXP  */
  YYSYMBOL_EXPRESSION = 233,               /* EXPRESSION  */
  YYSYMBOL_ARITH_ID = 234,                 /* ARITH_ID  */
  YYSYMBOL_NO_ARG_ARITH_FUNC = 235,        /* NO_ARG_ARITH_FUNC  */
  YYSYMBOL_ARITH_FUNC = 236,               /* ARITH_FUNC  */
  YYSYMBOL_SUBSCRIPT = 237,                /* SUBSCRIPT  */
  YYSYMBOL_QUALIFIER = 238,                /* QUALIFIER  */
  YYSYMBOL_SCALE_HEAD = 239,               /* SCALE_HEAD  */
  YYSYMBOL_PREC_SPEC = 240,                /* PREC_SPEC  */
  YYSYMBOL_SUB_START = 241,                /* SUB_START  */
  YYSYMBOL_SUB_HEAD = 242,                 /* SUB_HEAD  */
  YYSYMBOL_SUB = 243,                      /* SUB  */
  YYSYMBOL_SUB_RUN_HEAD = 244,             /* SUB_RUN_HEAD  */
  YYSYMBOL_SUB_EXP = 245,                  /* SUB_EXP  */
  YYSYMBOL_POUND_EXPRESSION = 246,         /* POUND_EXPRESSION  */
  YYSYMBOL_BIT_EXP = 247,                  /* BIT_EXP  */
  YYSYMBOL_BIT_FACTOR = 248,               /* BIT_FACTOR  */
  YYSYMBOL_BIT_CAT = 249,                  /* BIT_CAT  */
  YYSYMBOL_OR = 250,                       /* OR  */
  YYSYMBOL_CHAR_VERTICAL_BAR = 251,        /* CHAR_VERTICAL_BAR  */
  YYSYMBOL_AND = 252,                      /* AND  */
  YYSYMBOL_BIT_PRIM = 253,                 /* BIT_PRIM  */
  YYSYMBOL_CAT = 254,                      /* CAT  */
  YYSYMBOL_NOT = 255,                      /* NOT  */
  YYSYMBOL_BIT_VAR = 256,                  /* BIT_VAR  */
  YYSYMBOL_LABEL_VAR = 257,                /* LABEL_VAR  */
  YYSYMBOL_EVENT_VAR = 258,                /* EVENT_VAR  */
  YYSYMBOL_BIT_CONST_HEAD = 259,           /* BIT_CONST_HEAD  */
  YYSYMBOL_BIT_CONST = 260,                /* BIT_CONST  */
  YYSYMBOL_RADIX = 261,                    /* RADIX  */
  YYSYMBOL_CHAR_STRING = 262,              /* CHAR_STRING  */
  YYSYMBOL_SUBBIT_HEAD = 263,              /* SUBBIT_HEAD  */
  YYSYMBOL_SUBBIT_KEY = 264,               /* SUBBIT_KEY  */
  YYSYMBOL_BIT_FUNC_HEAD = 265,            /* BIT_FUNC_HEAD  */
  YYSYMBOL_BIT_ID = 266,                   /* BIT_ID  */
  YYSYMBOL_LABEL = 267,                    /* LABEL  */
  YYSYMBOL_BIT_FUNC = 268,                 /* BIT_FUNC  */
  YYSYMBOL_EVENT = 269,                    /* EVENT  */
  YYSYMBOL_SUB_OR_QUALIFIER = 270,         /* SUB_OR_QUALIFIER  */
  YYSYMBOL_BIT_QUALIFIER = 271,            /* BIT_QUALIFIER  */
  YYSYMBOL_CHAR_EXP = 272,                 /* CHAR_EXP  */
  YYSYMBOL_CHAR_PRIM = 273,                /* CHAR_PRIM  */
  YYSYMBOL_CHAR_FUNC_HEAD = 274,           /* CHAR_FUNC_HEAD  */
  YYSYMBOL_CHAR_VAR = 275,                 /* CHAR_VAR  */
  YYSYMBOL_CHAR_CONST = 276,               /* CHAR_CONST  */
  YYSYMBOL_CHAR_FUNC = 277,                /* CHAR_FUNC  */
  YYSYMBOL_CHAR_ID = 278,                  /* CHAR_ID  */
  YYSYMBOL_NAME_EXP = 279,                 /* NAME_EXP  */
  YYSYMBOL_NAME_KEY = 280,                 /* NAME_KEY  */
  YYSYMBOL_NAME_VAR = 281,                 /* NAME_VAR  */
  YYSYMBOL_VARIABLE = 282,                 /* VARIABLE  */
  YYSYMBOL_STRUCTURE_EXP = 283,            /* STRUCTURE_EXP  */
  YYSYMBOL_STRUCT_FUNC_HEAD = 284,         /* STRUCT_FUNC_HEAD  */
  YYSYMBOL_STRUCTURE_VAR = 285,            /* STRUCTURE_VAR  */
  YYSYMBOL_STRUCT_FUNC = 286,              /* STRUCT_FUNC  */
  YYSYMBOL_QUAL_STRUCT = 287,              /* QUAL_STRUCT  */
  YYSYMBOL_STRUCTURE_ID = 288,             /* STRUCTURE_ID  */
  YYSYMBOL_ASSIGNMENT = 289,               /* ASSIGNMENT  */
  YYSYMBOL_EQUALS = 290,                   /* EQUALS  */
  YYSYMBOL_IF_STATEMENT = 291,             /* IF_STATEMENT  */
  YYSYMBOL_IF_CLAUSE = 292,                /* IF_CLAUSE  */
  YYSYMBOL_TRUE_PART = 293,                /* TRUE_PART  */
  YYSYMBOL_IF = 294,                       /* IF  */
  YYSYMBOL_THEN = 295,                     /* THEN  */
  YYSYMBOL_RELATIONAL_EXP = 296,           /* RELATIONAL_EXP  */
  YYSYMBOL_RELATIONAL_FACTOR = 297,        /* RELATIONAL_FACTOR  */
  YYSYMBOL_REL_PRIM = 298,                 /* REL_PRIM  */
  YYSYMBOL_COMPARISON = 299,               /* COMPARISON  */
  YYSYMBOL_RELATIONAL_OP = 300,            /* RELATIONAL_OP  */
  YYSYMBOL_STATEMENT = 301,                /* STATEMENT  */
  YYSYMBOL_BASIC_STATEMENT = 302,          /* BASIC_STATEMENT  */
  YYSYMBOL_OTHER_STATEMENT = 303,          /* OTHER_STATEMENT  */
  YYSYMBOL_ANY_STATEMENT = 304,            /* ANY_STATEMENT  */
  YYSYMBOL_ON_PHRASE = 305,                /* ON_PHRASE  */
  YYSYMBOL_ON_CLAUSE = 306,                /* ON_CLAUSE  */
  YYSYMBOL_LABEL_DEFINITION = 307,         /* LABEL_DEFINITION  */
  YYSYMBOL_CALL_KEY = 308,                 /* CALL_KEY  */
  YYSYMBOL_ASSIGN = 309,                   /* ASSIGN  */
  YYSYMBOL_CALL_ASSIGN_LIST = 310,         /* CALL_ASSIGN_LIST  */
  YYSYMBOL_DO_GROUP_HEAD = 311,            /* DO_GROUP_HEAD  */
  YYSYMBOL_ENDING = 312,                   /* ENDING  */
  YYSYMBOL_READ_KEY = 313,                 /* READ_KEY  */
  YYSYMBOL_WRITE_KEY = 314,                /* WRITE_KEY  */
  YYSYMBOL_READ_PHRASE = 315,              /* READ_PHRASE  */
  YYSYMBOL_WRITE_PHRASE = 316,             /* WRITE_PHRASE  */
  YYSYMBOL_READ_ARG = 317,                 /* READ_ARG  */
  YYSYMBOL_WRITE_ARG = 318,                /* WRITE_ARG  */
  YYSYMBOL_FILE_EXP = 319,                 /* FILE_EXP  */
  YYSYMBOL_FILE_HEAD = 320,                /* FILE_HEAD  */
  YYSYMBOL_IO_CONTROL = 321,               /* IO_CONTROL  */
  YYSYMBOL_WAIT_KEY = 322,                 /* WAIT_KEY  */
  YYSYMBOL_TERMINATOR = 323,               /* TERMINATOR  */
  YYSYMBOL_TERMINATE_LIST = 324,           /* TERMINATE_LIST  */
  YYSYMBOL_SCHEDULE_HEAD = 325,            /* SCHEDULE_HEAD  */
  YYSYMBOL_SCHEDULE_PHRASE = 326,          /* SCHEDULE_PHRASE  */
  YYSYMBOL_SCHEDULE_CONTROL = 327,         /* SCHEDULE_CONTROL  */
  YYSYMBOL_TIMING = 328,                   /* TIMING  */
  YYSYMBOL_REPEAT = 329,                   /* REPEAT  */
  YYSYMBOL_STOPPING = 330,                 /* STOPPING  */
  YYSYMBOL_SIGNAL_CLAUSE = 331,            /* SIGNAL_CLAUSE  */
  YYSYMBOL_PERCENT_MACRO_NAME = 332,       /* PERCENT_MACRO_NAME  */
  YYSYMBOL_PERCENT_MACRO_HEAD = 333,       /* PERCENT_MACRO_HEAD  */
  YYSYMBOL_PERCENT_MACRO_ARG = 334,        /* PERCENT_MACRO_ARG  */
  YYSYMBOL_CASE_ELSE = 335,                /* CASE_ELSE  */
  YYSYMBOL_WHILE_KEY = 336,                /* WHILE_KEY  */
  YYSYMBOL_WHILE_CLAUSE = 337,             /* WHILE_CLAUSE  */
  YYSYMBOL_FOR_LIST = 338,                 /* FOR_LIST  */
  YYSYMBOL_ITERATION_BODY = 339,           /* ITERATION_BODY  */
  YYSYMBOL_ITERATION_CONTROL = 340,        /* ITERATION_CONTROL  */
  YYSYMBOL_FOR_KEY = 341,                  /* FOR_KEY  */
  YYSYMBOL_TEMPORARY_STMT = 342,           /* TEMPORARY_STMT  */
  YYSYMBOL_CONSTANT = 343,                 /* CONSTANT  */
  YYSYMBOL_ARRAY_HEAD = 344,               /* ARRAY_HEAD  */
  YYSYMBOL_MINOR_ATTR_LIST = 345,          /* MINOR_ATTR_LIST  */
  YYSYMBOL_MINOR_ATTRIBUTE = 346,          /* MINOR_ATTRIBUTE  */
  YYSYMBOL_INIT_OR_CONST_HEAD = 347,       /* INIT_OR_CONST_HEAD  */
  YYSYMBOL_REPEATED_CONSTANT = 348,        /* REPEATED_CONSTANT  */
  YYSYMBOL_REPEAT_HEAD = 349,              /* REPEAT_HEAD  */
  YYSYMBOL_NESTED_REPEAT_HEAD = 350,       /* NESTED_REPEAT_HEAD  */
  YYSYMBOL_DCL_LIST_COMMA = 351,           /* DCL_LIST_COMMA  */
  YYSYMBOL_LITERAL_EXP_OR_STAR = 352,      /* LITERAL_EXP_OR_STAR  */
  YYSYMBOL_TYPE_SPEC = 353,                /* TYPE_SPEC  */
  YYSYMBOL_BIT_SPEC = 354,                 /* BIT_SPEC  */
  YYSYMBOL_CHAR_SPEC = 355,                /* CHAR_SPEC  */
  YYSYMBOL_STRUCT_SPEC = 356,              /* STRUCT_SPEC  */
  YYSYMBOL_STRUCT_SPEC_BODY = 357,         /* STRUCT_SPEC_BODY  */
  YYSYMBOL_STRUCT_TEMPLATE = 358,          /* STRUCT_TEMPLATE  */
  YYSYMBOL_STRUCT_SPEC_HEAD = 359,         /* STRUCT_SPEC_HEAD  */
  YYSYMBOL_ARITH_SPEC = 360,               /* ARITH_SPEC  */
  YYSYMBOL_COMPILATION = 361,              /* COMPILATION  */
  YYSYMBOL_BLOCK_DEFINITION = 362,         /* BLOCK_DEFINITION  */
  YYSYMBOL_BLOCK_STMT = 363,               /* BLOCK_STMT  */
  YYSYMBOL_BLOCK_STMT_TOP = 364,           /* BLOCK_STMT_TOP  */
  YYSYMBOL_BLOCK_STMT_HEAD = 365,          /* BLOCK_STMT_HEAD  */
  YYSYMBOL_LABEL_EXTERNAL = 366,           /* LABEL_EXTERNAL  */
  YYSYMBOL_CLOSING = 367,                  /* CLOSING  */
  YYSYMBOL_BLOCK_BODY = 368,               /* BLOCK_BODY  */
  YYSYMBOL_FUNCTION_NAME = 369,            /* FUNCTION_NAME  */
  YYSYMBOL_PROCEDURE_NAME = 370,           /* PROCEDURE_NAME  */
  YYSYMBOL_FUNC_STMT_BODY = 371,           /* FUNC_STMT_BODY  */
  YYSYMBOL_PROC_STMT_BODY = 372,           /* PROC_STMT_BODY  */
  YYSYMBOL_DECLARE_GROUP = 373,            /* DECLARE_GROUP  */
  YYSYMBOL_DECLARE_ELEMENT = 374,          /* DECLARE_ELEMENT  */
  YYSYMBOL_PARAMETER = 375,                /* PARAMETER  */
  YYSYMBOL_PARAMETER_LIST = 376,           /* PARAMETER_LIST  */
  YYSYMBOL_PARAMETER_HEAD = 377,           /* PARAMETER_HEAD  */
  YYSYMBOL_DECLARE_STATEMENT = 378,        /* DECLARE_STATEMENT  */
  YYSYMBOL_ASSIGN_LIST = 379,              /* ASSIGN_LIST  */
  YYSYMBOL_TEXT = 380,                     /* TEXT  */
  YYSYMBOL_REPLACE_STMT = 381,             /* REPLACE_STMT  */
  YYSYMBOL_REPLACE_HEAD = 382,             /* REPLACE_HEAD  */
  YYSYMBOL_ARG_LIST = 383,                 /* ARG_LIST  */
  YYSYMBOL_STRUCTURE_STMT = 384,           /* STRUCTURE_STMT  */
  YYSYMBOL_STRUCT_STMT_HEAD = 385,         /* STRUCT_STMT_HEAD  */
  YYSYMBOL_STRUCT_STMT_TAIL = 386,         /* STRUCT_STMT_TAIL  */
  YYSYMBOL_INLINE_DEFINITION = 387,        /* INLINE_DEFINITION  */
  YYSYMBOL_ARITH_INLINE = 388,             /* ARITH_INLINE  */
  YYSYMBOL_ARITH_INLINE_DEF = 389,         /* ARITH_INLINE_DEF  */
  YYSYMBOL_BIT_INLINE = 390,               /* BIT_INLINE  */
  YYSYMBOL_BIT_INLINE_DEF = 391,           /* BIT_INLINE_DEF  */
  YYSYMBOL_CHAR_INLINE = 392,              /* CHAR_INLINE  */
  YYSYMBOL_CHAR_INLINE_DEF = 393,          /* CHAR_INLINE_DEF  */
  YYSYMBOL_STRUC_INLINE_DEF = 394          /* STRUC_INLINE_DEF  */
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
#define YYFINAL  469
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   7718

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  203
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  192
/* YYNRULES -- Number of rules.  */
#define YYNRULES  599
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  997

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   457


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
     195,   196,   197,   198,   199,   200,   201,   202
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,   648,   648,   649,   651,   652,   653,   655,   656,   657,
     658,   659,   660,   661,   662,   664,   665,   666,   667,   668,
     670,   671,   672,   674,   676,   677,   679,   680,   682,   683,
     684,   685,   687,   688,   690,   691,   692,   693,   694,   695,
     696,   697,   699,   700,   701,   702,   703,   705,   706,   708,
     710,   712,   713,   714,   715,   717,   718,   720,   722,   723,
     724,   725,   727,   728,   729,   730,   731,   732,   733,   734,
     736,   737,   738,   739,   740,   742,   743,   745,   747,   749,
     751,   752,   753,   754,   756,   757,   759,   760,   762,   763,
     764,   766,   767,   768,   769,   770,   772,   773,   775,   776,
     777,   778,   779,   780,   781,   782,   784,   785,   786,   787,
     788,   789,   790,   791,   792,   793,   794,   795,   796,   797,
     798,   799,   800,   801,   802,   803,   804,   805,   806,   807,
     808,   809,   810,   811,   812,   813,   814,   815,   816,   817,
     818,   819,   820,   821,   822,   823,   824,   825,   826,   827,
     828,   829,   830,   832,   833,   834,   835,   837,   838,   839,
     840,   842,   843,   845,   846,   848,   849,   850,   851,   852,
     854,   855,   857,   858,   859,   860,   862,   864,   865,   867,
     868,   869,   871,   872,   874,   875,   877,   878,   879,   880,
     882,   883,   885,   887,   888,   890,   891,   892,   893,   894,
     895,   896,   897,   898,   899,   900,   902,   903,   905,   906,
     907,   908,   910,   911,   912,   913,   915,   916,   917,   918,
     920,   921,   922,   923,   925,   926,   928,   929,   930,   931,
     932,   934,   935,   936,   937,   939,   941,   942,   944,   946,
     947,   948,   950,   952,   953,   954,   955,   957,   958,   960,
     962,   963,   965,   967,   968,   969,   970,   971,   973,   974,
     975,   976,   978,   979,   981,   982,   983,   984,   986,   987,
     989,   990,   991,   992,   993,   995,   997,   998,   999,  1001,
    1003,  1004,  1005,  1007,  1008,  1009,  1010,  1011,  1012,  1013,
    1015,  1016,  1017,  1018,  1020,  1022,  1024,  1026,  1027,  1029,
    1031,  1032,  1033,  1034,  1036,  1038,  1039,  1041,  1042,  1044,
    1046,  1048,  1050,  1051,  1053,  1054,  1056,  1057,  1058,  1060,
    1061,  1062,  1063,  1064,  1066,  1067,  1068,  1069,  1070,  1071,
    1073,  1074,  1075,  1077,  1078,  1079,  1080,  1081,  1082,  1083,
    1084,  1085,  1086,  1087,  1088,  1089,  1090,  1091,  1092,  1093,
    1094,  1095,  1096,  1097,  1098,  1099,  1100,  1101,  1102,  1103,
    1104,  1105,  1106,  1107,  1108,  1109,  1110,  1111,  1112,  1113,
    1114,  1115,  1116,  1117,  1119,  1120,  1121,  1123,  1124,  1126,
    1127,  1129,  1130,  1131,  1132,  1134,  1136,  1138,  1140,  1141,
    1142,  1143,  1145,  1146,  1147,  1148,  1149,  1150,  1151,  1152,
    1154,  1155,  1156,  1158,  1159,  1161,  1163,  1164,  1166,  1167,
    1169,  1170,  1172,  1173,  1174,  1176,  1178,  1180,  1181,  1182,
    1183,  1184,  1186,  1188,  1189,  1191,  1192,  1194,  1195,  1196,
    1197,  1199,  1200,  1201,  1203,  1204,  1205,  1207,  1208,  1209,
    1211,  1213,  1214,  1216,  1217,  1218,  1220,  1222,  1223,  1225,
    1226,  1228,  1230,  1231,  1233,  1234,  1236,  1237,  1239,  1240,
    1242,  1243,  1245,  1246,  1248,  1250,  1251,  1252,  1253,  1255,
    1256,  1258,  1259,  1261,  1262,  1263,  1264,  1265,  1266,  1267,
    1268,  1269,  1270,  1271,  1272,  1274,  1275,  1276,  1278,  1279,
    1280,  1281,  1282,  1284,  1286,  1287,  1289,  1291,  1292,  1294,
    1295,  1296,  1297,  1298,  1300,  1301,  1303,  1305,  1307,  1308,
    1310,  1312,  1314,  1315,  1316,  1318,  1319,  1320,  1321,  1322,
    1323,  1324,  1325,  1326,  1328,  1329,  1331,  1333,  1334,  1335,
    1336,  1337,  1339,  1340,  1341,  1342,  1343,  1344,  1345,  1346,
    1347,  1349,  1350,  1352,  1353,  1354,  1356,  1357,  1358,  1360,
    1362,  1364,  1365,  1366,  1368,  1369,  1370,  1372,  1373,  1375,
    1376,  1377,  1378,  1380,  1381,  1382,  1383,  1384,  1385,  1387,
    1389,  1390,  1392,  1394,  1396,  1398,  1400,  1401,  1403,  1404,
    1406,  1408,  1409,  1410,  1412,  1414,  1415,  1416,  1417,  1419,
    1420,  1422,  1423,  1425,  1426,  1428,  1430,  1431,  1433,  1435
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
  "_SYMB_192", "_SYMB_193", "_SYMB_194", "_SYMB_195", "_SYMB_196",
  "_SYMB_197", "_SYMB_198", "$accept", "DECLARE_BODY", "ATTRIBUTES",
  "DECLARATION", "ARRAY_SPEC", "TYPE_AND_MINOR_ATTR", "IDENTIFIER",
  "SQ_DQ_NAME", "DOUBLY_QUAL_NAME_HEAD", "ARITH_CONV", "DECLARATION_LIST",
  "NAME_ID", "ARITH_EXP", "TERM", "PLUS", "MINUS", "PRODUCT", "FACTOR",
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

#define YYPACT_NINF (-801)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-415)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
    5760,   286,  -120,  -801,   -78,   714,  -801,   140,  7338,    93,
      45,   149,   904,    10,  -801,   243,  -801,   205,   218,   303,
     327,   416,   -78,    99,  2688,   714,   231,    99,    99,  -120,
    -801,  -801,   236,  -801,   337,  -801,  -801,  -801,  -801,  -801,
     360,  -801,  -801,  -801,  -801,  -801,  -801,   403,  -801,  -801,
     752,    48,   403,   357,   403,  -801,   403,   425,   172,  -801,
     484,   186,  -801,   537,  -801,   490,  -801,  6759,  6759,  3279,
    -801,  -801,  -801,  -801,  6759,   148,  6500,   458,  6062,  1360,
    2294,   183,   281,   510,   538,  4240,   267,   131,    86,   527,
     212,  5610,  6759,  3476,  2102,  -801,  5911,    55,    11,   389,
     830,   168,  -801,   529,  -801,  -801,  -801,  5911,  -801,  5911,
    -801,  5911,  5911,   567,   346,  -801,  -801,  -801,   403,   578,
    -801,  -801,  -801,   588,  -801,   593,  -801,   595,  -801,  -801,
    -801,  -801,  -801,  -801,   601,   632,   636,  -801,  -801,  -801,
    -801,  -801,  -801,  -801,  -801,   651,  -801,  -801,   652,  -801,
     540,  2078,   666,   665,  -801,  7526,  -801,   577,   -26,  4586,
    -801,   694,  7489,  -801,  -801,  -801,  -801,  4586,  2210,  -801,
    2885,   909,  2210,  -801,  -801,  -801,   693,  -801,  -801,  4932,
     121,  -801,  -801,  3279,   687,    43,  4932,  -801,   689,   318,
    -801,   691,   698,   702,   706,   763,  -801,   445,   104,   318,
     318,  -801,   715,   708,   685,  -801,   737,  3673,  -801,  -801,
     641,   234,  -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,
    -801,  -801,  -801,  -801,  -801,  -801,   264,  -801,   733,   264,
    -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,
    -801,  -801,  -120,  -801,  -801,   746,  -801,  -801,  -801,  -801,
     748,  -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,
    -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,
     756,  -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,
    -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,
     759,   761,   765,  -801,  -801,  -801,  -801,   403,   246,  -801,
    5276,  5276,   762,  5104,   770,  -801,   766,  -801,  -801,  -801,
    -801,  -801,   771,   788,   403,  -801,    95,   207,   170,  -801,
    1250,  -801,  -801,  -801,   592,  -801,   790,  -801,  3476,   804,
    -801,   170,  -801,   813,  -801,  -801,  -801,  -801,   815,  -801,
    -801,   171,  -801,   475,  -801,  -801,  1724,   909,   705,   318,
     833,  -801,  -801,  4413,   774,   818,  -801,   331,  -801,   835,
    -801,  -801,  -801,  -801,  7174,   752,  -801,  3082,  3476,   752,
     955,  -801,  3476,  -801,   236,  -801,   772,  7131,  -801,  3279,
    1202,   107,  1012,  1715,  1012,   417,   417,   107,   207,  -801,
    -801,  -801,  -801,   361,  -801,  -801,   236,  -801,  -801,  3476,
    -801,  -801,   845,   763,  7338,  -801,  6208,   836,  -801,  -801,
     847,   855,   858,   873,   876,  -801,  -801,  -801,  -801,   284,
    -801,  -801,  -801,  1509,  -801,  2491,  -801,  3476,  4932,  4932,
    5455,  4932,   765,   493,   817,  -801,  -801,   307,  4932,  4932,
    5492,   878,   750,  -801,  -801,   872,   276,    69,  -801,  3870,
    -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,
    -801,   523,  -801,  -801,   479,   891,   896,  1949,  3476,  -801,
    -801,  -801,   894,  -801,   763,   844,  -801,  6354,   915,  6646,
     277,  -801,  -801,   919,  -801,  -801,  -801,  -801,  -801,  -801,
    -801,  -801,  -801,  -801,  -801,  -801,  -801,  1548,   728,   927,
    -801,   900,  -801,  -801,   922,  6646,   930,  6646,   938,  6646,
     940,  6646,   403,  -120,   403,  -801,   714,  -801,  4586,  4586,
    4586,  4586,   764,  -801,  2210,  2210,  2210,  -801,   909,  -801,
    -801,  -801,  -801,   571,   963,  -801,  -801,   610,  -801,   967,
    -801,   618,  -801,  -801,  2210,   821,  -801,  4586,   551,   -78,
     510,   972,    95,    95,  -801,  -801,   968,    49,   986,  -801,
    -801,  -801,  -801,  -801,  -801,   982,  -801,   985,  -801,  -801,
      68,  1002,  1004,  -801,   -78,   812,    99,   822,    66,   269,
    1006,  1008,  1013,  1011,   375,  1001,  -801,  -801,  -801,   318,
    -801,  3476,  -801,  -801,  -801,  5276,  5276,  4067,  -801,  -801,
    5276,  5276,  5276,  -801,  -801,  5276,  1031,  -801,  3476,  -801,
    -801,  -801,  -801,  5492,  -801,  -801,  -801,  5492,  5492,  5492,
     234,   234,  -801,  1020,  -801,   318,  1039,  3476,  4067,  3476,
    5407,  5930,  -801,  1033,   764,  1945,   465,  -801,  4932,   888,
    1062,  1050,  -801,  -801,  -801,  -801,   323,  -801,  4759,   903,
     571,  -801,  -801,  -801,  -801,  -801,  -801,  1071,   172,  -801,
    -801,  1061,   560,   646,  -801,  -801,   171,  -801,   403,   403,
     403,   403,  -801,  -801,  -801,  1083,   137,   111,  -801,  -801,
    -801,  -801,  -801,  -801,  4932,  -801,  -801,  5492,  3279,  4067,
     444,   -30,  3279,  -801,  3279,  1063,   659,   752,  -801,  1065,
    6905,  -801,  -801,  4932,  4932,  4932,  4932,  4932,  -801,  -801,
    1066,   525,   850,   866,  1067,   151,   623,  -801,  1814,   714,
    -801,   571,   571,    95,  4932,  -801,  -801,  -801,  4932,  4932,
    3870,   571,    95,  1078,  -801,  1073,   907,  -801,  -801,  -801,
    -801,  -801,   677,  -801,  -801,   -78,  7018,  -801,  -801,  -801,
    1089,  -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,
     716,  -801,  -801,  -801,  1090,  -801,  1094,  -801,  1095,  -801,
    1097,  -801,  -801,   403,  1116,  1118,  1119,  1091,  1120,  2210,
    2210,   694,  -801,  -801,  -801,  -801,  -801,  1114,  1122,  1053,
    1102,  -801,   448,  -801,  4932,  -801,  4932,  -801,  -801,  -801,
    -801,  -801,  -801,  -801,   796,  -801,  -801,  -801,  -801,  -801,
     403,   234,   403,  1126,  1128,   886,  -801,  -801,  4067,  -801,
     571,  -801,  1123,  -801,  -801,  -801,  -801,  1121,   906,   207,
     170,  -801,  1250,  1115,  1136,  -801,   913,   571,  -801,   924,
    1139,  1140,   403,  -801,  -801,   764,   764,  -801,   664,  4932,
    -801,   902,  4932,  4759,   571,  -801,  -801,  5276,  5276,  -801,
    3476,  -801,  3476,  3476,  -801,  -801,  -801,  -801,  -801,  -801,
     571,   170,   129,   246,   170,  -801,  -801,  -801,   385,  1012,
     207,  -801,  -801,    85,  -801,   331,  1046,  -801,   957,   977,
     984,   990,   992,  -801,  -801,  -801,  -801,  -801,  -801,  -801,
    1030,   571,   571,  6082,  -801,  -801,  -801,  -801,   991,  -801,
    -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,
    -801,  -801,  -801,  -801,  -801,  -801,   288,   571,   -78,  -801,
    -801,  -801,  1129,   592,  -801,  1235,   902,  -801,  -801,  -801,
    -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,   794,  -801,
    1058,  1150,  1038,  -801,  -801,  -801,  -801,  -801,  -801,  -801,
    1151,   752,  1143,  -801,  -801,  -801,  -801,  -801,  -801,   752,
    4932,  -801,   426,  -801,  1060,  -801,  1145,  -801,  -801,  -801,
     752,  -801,   331,  -801,  1146,   571,  1160,  1145,  1148,  4932,
    1075,  -801,  -801,  1052,  1149,  -801,  -801
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int16 yydefact[] =
{
       0,     0,     0,   340,     0,     0,   424,     0,     0,     0,
       0,     0,     0,     0,   310,     0,   279,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     238,   423,   536,   422,     0,   242,   244,   245,   275,   299,
     246,   243,   249,    97,    23,    96,   283,    62,   284,   288,
       0,     0,   212,     0,   220,   286,   264,     0,     0,   588,
       0,   290,   294,     0,   297,     0,   374,     0,     0,     0,
     377,   330,   331,   515,     0,     0,   541,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   431,     0,     0,
       0,     0,     0,     0,     0,   378,     0,     0,   529,     0,
     537,   539,   517,     0,   519,   332,   585,     0,   586,     0,
     587,     0,     0,     0,     0,   446,   246,   386,   216,     0,
     486,   477,   476,     0,   474,     0,   504,     0,   475,   164,
     503,    16,    28,   483,     0,    31,     0,    17,    18,   479,
     480,    29,   163,   473,    19,    30,    38,    39,    40,    41,
       0,    13,     0,     0,    32,     5,     6,    34,   513,     0,
      25,     2,     7,   512,    36,    37,   510,     0,    22,   471,
       0,     0,    20,   500,   501,   499,     0,   502,   392,     0,
       0,   453,   452,     0,     0,     0,     0,   335,     0,     0,
     592,     0,     0,     0,     0,     0,   485,     0,   380,     0,
       0,   337,     0,   576,     0,   444,     0,     0,    49,    50,
       0,     0,   345,   208,   210,   211,   107,   137,   119,   120,
     121,   122,   124,   123,   125,   233,   240,   108,     0,   274,
      98,   126,   127,    99,   234,   138,   109,   100,   101,   128,
     228,   110,     0,   231,   142,    28,   144,   143,   270,   129,
      31,   149,   111,   150,   112,   106,   209,   277,   232,   113,
     230,   229,   102,   146,   103,   104,   114,   271,   115,   105,
      29,   135,   136,   116,   117,   130,   131,   148,   132,   147,
     133,   134,   139,   145,   272,   227,   118,   140,    30,   247,
     244,   245,   243,   235,    77,    79,    78,     0,    91,    42,
       0,     0,    47,    51,    55,    58,    59,    71,    76,    72,
      75,    60,     0,     0,    80,    84,    92,   182,   184,   186,
       0,   195,   196,   197,     0,   198,   224,   268,     0,     0,
     239,    93,   253,     0,   258,   259,   262,    94,     0,    95,
     290,     0,   427,     0,   443,   445,     0,     0,     0,     0,
       0,    63,   154,   170,     0,     0,   289,     0,   236,     0,
     213,   385,   221,   265,     0,     0,   304,     0,     0,     0,
       0,   295,     0,   333,     0,   305,   330,     0,   306,     0,
       0,     0,   184,     0,     0,     0,     0,     0,   312,   314,
     318,   375,   368,     0,   542,   534,   535,   334,   376,     0,
     341,   387,     0,   400,     0,   398,   541,     0,   399,   348,
       0,     0,     0,     0,     0,   410,   406,   411,   350,   299,
     412,   408,   413,     0,   349,     0,   351,     0,     0,     0,
       0,     0,     0,     0,     0,   359,   425,     0,     0,     0,
       0,     0,     0,   363,   433,     0,   435,   439,   434,     0,
     365,   447,   372,   465,   466,   281,   282,   467,   468,   449,
     280,     0,   450,   397,    91,   488,     0,   492,     0,     1,
     516,   518,     0,   520,   543,     0,   547,   541,     0,     0,
     546,   557,   559,     0,   561,   526,   527,   528,   530,   531,
     533,   549,   550,   532,   570,   552,   538,   551,     0,     0,
     540,   554,   555,   521,     0,     0,     0,     0,     0,     0,
       0,     0,    64,     0,    66,   217,     0,   469,     0,     0,
       0,     0,     0,    26,    10,    11,    14,   572,     0,     4,
      35,   514,   498,   497,     0,   496,     8,     0,   472,     0,
     488,     0,    40,    33,    21,     0,   507,     0,     0,     0,
       0,     0,   454,   455,   395,   393,     0,   458,   457,   336,
     416,   595,   598,   599,   591,     0,   371,     0,   384,   383,
     379,     0,     0,   338,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   250,   241,   251,     0,
     263,     0,    85,   206,   207,     0,     0,     0,    43,    44,
       0,     0,     0,    54,    57,     0,     0,    61,     0,   346,
      81,   192,   191,     0,   190,   193,   194,     0,     0,     0,
       0,     0,   188,     0,   226,     0,     0,     0,     0,     0,
       0,     0,   367,     0,     0,     0,     0,   580,     0,     0,
       0,   165,   156,   155,   173,   179,   177,   171,     0,   172,
     178,   169,   153,   167,   168,   285,   237,     0,     0,   301,
     300,     0,    91,     0,    86,    88,    90,   303,    68,   214,
     222,   266,   298,   302,   309,     0,     0,     0,   326,   327,
     325,   328,   329,   324,     0,   311,   308,     0,     0,     0,
       0,     0,     0,   307,     0,     0,     0,     0,   401,     0,
       0,   402,   347,     0,     0,     0,     0,     0,   407,   409,
       0,     0,     0,     0,     0,     0,     0,   356,     0,     0,
     360,   428,   429,   430,     0,   440,   364,   436,     0,     0,
       0,   441,   442,     0,   448,     0,     0,   523,   487,   494,
     489,   490,     0,   522,   544,     0,     0,   545,   524,   548,
       0,   558,   560,   553,   564,   565,   566,   568,   567,   563,
       0,   573,   556,   589,     0,   593,     0,   596,     0,   292,
       0,    65,    67,   218,     0,     0,     0,     0,     0,     9,
      12,     3,    24,   470,    15,   482,   481,   508,     0,   396,
       0,   462,     0,   394,     0,   456,     0,   339,   370,   382,
     381,   403,   404,   578,     0,   574,   575,    70,   199,   261,
     202,     0,   204,     0,     0,     0,    45,    46,     0,   273,
     256,   257,     0,    48,    52,    53,    56,     0,     0,   183,
     185,   187,     0,     0,     0,   200,     0,   255,   254,     0,
       0,     0,    82,   366,   581,     0,     0,   584,     0,     0,
     405,   161,     0,     0,   177,   174,   176,     0,     0,   287,
       0,   353,     0,     0,   291,    69,   215,   223,   267,   316,
     319,   321,     0,     0,   320,   323,   296,   322,     0,     0,
     313,   315,   369,     0,   388,   390,     0,   464,     0,     0,
       0,     0,     0,   352,   354,   415,   355,   358,   357,   426,
       0,   438,   437,     0,   373,   493,   495,   491,     0,   525,
     571,   569,   590,   594,   597,   293,   219,   505,   506,   478,
      27,   484,   511,   509,   451,   463,   460,   459,     0,   577,
     203,   205,     0,     0,    74,     0,   161,    73,   189,   225,
     201,   260,   278,   276,    83,   582,   583,   361,     0,   162,
       0,     0,     0,   175,   180,   181,    89,    87,   317,   342,
       0,     0,     0,   419,   420,   421,   417,   418,   432,     0,
       0,   579,     0,   269,     0,   362,   166,   157,   160,   158,
       0,   389,   391,   343,     0,   461,     0,     0,   161,     0,
       0,   562,   252,     0,     0,   159,   344
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -801,   767,  1015,  -123,  -801,  1018,     4,  -801,  -801,   329,
     647,  -801,   808,  -281,  1086,  1205,  -248,   573,  -801,  -801,
     306,  -801,     9,  -412,   -77,   447,   -80,  -801,  -329,   321,
     -20,     6,  -600,  -801,  1019,   875,  -734,  -148,  -801,  -801,
    -801,  -801,  -603,  -801,    76,   572,   -34,  -341,  -801,  -351,
    -302,  -178,   -53,    47,    -4,   169,  -801,   -58,  -800,  -321,
     649,  -801,  -801,    34,   776,  -801,  -336,   959,  -801,    16,
    -437,  -801,   952,   -48,  -801,   119,    63,  1025,  -323,   -35,
    1494,  -801,   713,  -801,     0,    24,   216,     1,  -801,  -801,
    -801,  -801,   799,  -166,   497,   499,  -801,  -283,   519,   -15,
     -67,   227,  -801,  -801,   496,  -801,   -71,   211,  -801,  1124,
    -801,  -801,  -801,  -801,   777,   769,   834,  -801,   -50,  -801,
    -801,  -801,  -801,  -801,  -801,  -801,  -801,   757,   811,  -801,
    -801,  -801,  -801,   -59,  1021,  -801,  -801,  -801,  -801,  -801,
     738,  -801,   -74,  -155,  1209,  -130,  -801,  -801,  -801,   -47,
     -62,  1200,  1201,    27,  -801,  -801,  -801,  1203,  -801,  -801,
    -801,  -801,  -801,  -801,   663,   332,  -801,  -801,  -801,  -801,
    -801,   734,  -801,   -79,  -801,    83,   718,  -801,   108,  -801,
    -801,   147,  -801,  -801,  -801,  -801,  -801,  -801,  -801,  -801,
    -801,  -801
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
       0,   152,   153,   154,   155,   156,    45,   158,   159,   297,
     161,   162,   298,   299,   300,   301,   302,   303,   605,   304,
     305,   306,   307,   308,   309,   310,   311,   312,   663,   664,
     665,    47,   314,   315,   371,   352,   852,   163,   353,   354,
     647,   648,   649,   650,   316,   317,   318,   613,   614,   617,
     319,   597,   320,   321,   322,   323,   324,   325,   326,   327,
     328,    51,   329,    52,   118,   330,    54,   587,   588,   331,
     332,   333,    55,   335,   336,    56,   337,    57,   459,    58,
     339,    60,   340,    62,   434,    64,    65,   683,    66,    67,
      68,    69,   686,   387,   388,   389,   390,   684,    70,    71,
      72,   476,    74,    75,   477,    77,   499,   886,    78,   701,
      79,    80,    81,    82,   416,   421,    83,    84,   417,    85,
      86,   437,    87,    88,   445,   446,   447,   448,    89,    90,
      91,   461,    92,   183,   184,   185,   558,   795,   186,   408,
     462,   167,   168,   169,   170,   466,   467,   468,   171,   534,
     172,   173,   174,   175,   546,   176,   547,   177,    94,    95,
      96,    97,    98,    99,   747,   479,   100,   101,   496,   500,
     480,   481,   760,   497,   498,   482,   502,   806,   483,   204,
     804,   484,   347,   637,   105,   106,   107,   108,   109,   110,
     111,   112
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      63,   117,   114,   624,   313,   119,   402,   113,   115,   398,
     531,   455,   157,   538,   454,   355,   383,   553,   622,   598,
     599,   342,   501,   206,   341,   119,   203,   206,   206,   449,
     422,   842,   166,   457,   670,   382,   166,   694,   495,   193,
     541,   657,   164,   458,   415,   855,   692,    48,   543,   129,
     357,   951,   376,   346,   358,   603,   460,   208,   209,   367,
     420,   397,   242,   555,   372,   187,   350,    63,    63,   341,
     696,   808,    39,   465,    63,   485,    63,   526,    63,   357,
     341,   622,   436,   102,   427,   384,   119,   456,   611,   486,
     442,   341,    63,   341,    63,   488,    63,    48,   544,   687,
     453,   689,   690,   691,   728,   959,   443,    63,   103,    63,
     778,    63,    63,   178,    48,    48,   869,   611,   842,    44,
     537,    48,   350,    48,   166,    48,    48,   165,   142,   611,
     383,   401,   385,   611,   958,     1,   951,     2,    48,    48,
     618,    48,   809,    48,   489,   381,   120,   104,   179,   382,
     540,   611,   729,   628,    48,   189,    48,   444,    48,    48,
     821,   593,    39,   876,   799,   678,   366,   679,   392,    49,
     341,   897,   986,   611,   494,   157,   365,   471,   438,   166,
     551,   195,   631,   341,   180,   393,   166,   423,   612,   350,
    -289,   838,   205,   594,   593,   487,   344,   345,   560,   384,
     568,   366,   472,   424,   618,   164,   628,   580,   571,   572,
     582,   584,   692,   677,   401,  -289,   113,   612,   451,    49,
     794,   181,   844,   579,   636,   182,   594,    73,   439,   612,
     615,   800,   452,   612,    36,    37,    49,    49,   116,    41,
     670,   473,   989,    49,   616,    49,   385,    49,    49,   196,
     953,   612,   440,   989,   208,   209,   441,   581,   583,   552,
      49,    49,   815,    49,   181,    49,   166,   569,   182,   193,
     593,   181,   635,   612,   809,   182,    49,   685,    49,   828,
      49,    49,   350,   578,   455,   425,   197,   435,  -414,   549,
     165,    39,   585,   593,    42,   670,   208,   209,   836,   198,
     839,   426,   594,   842,  -414,   405,    46,   841,   626,   199,
     398,   719,   343,    39,   816,   817,   831,    43,    44,   823,
     623,   470,   680,   681,   682,   594,   383,   720,   341,   460,
     658,   208,   209,   200,   658,   842,   692,   160,   742,   398,
     970,   160,   370,   349,   639,   382,     8,   660,   119,   350,
     551,   157,   673,   824,   825,   475,    46,   513,   640,   643,
     456,   348,   397,   514,   341,    63,  -296,   341,   666,    63,
     853,   538,   341,    46,    46,   422,   668,    63,   361,   341,
      46,   164,    46,   623,    46,    46,   811,   449,   415,   538,
     454,   397,   514,   689,   672,   676,   513,    46,    46,   666,
      46,   628,    46,   350,   669,   420,    63,   710,   157,   457,
     398,    48,    48,    46,    22,    46,    48,    46,    46,   458,
     761,   350,    35,   357,    48,   341,    39,   711,   166,   160,
     623,   364,   740,   945,   946,   753,   201,    29,   164,   505,
     623,   507,   385,   509,   511,   678,   366,   679,   540,   733,
     779,   780,   490,    48,   181,   578,    36,    37,   182,    39,
     116,    41,   397,   350,   399,   566,   165,   357,   341,   846,
      48,   774,   775,   776,   777,   225,   453,    63,   400,    63,
     538,   491,    43,    44,   160,   847,   550,   208,   209,   671,
     368,   160,   736,   350,   234,   632,    76,   670,   628,    23,
     788,   208,   209,   593,   401,    63,   715,    63,    27,    63,
     373,    63,    28,   717,    48,   492,   723,   493,   294,   295,
     243,   166,   872,   165,    48,   732,    48,   734,   735,   694,
     938,   692,   157,    49,    49,   594,   631,   672,    49,   366,
     672,   369,   428,   350,   258,   894,    49,   450,   370,   503,
     455,   791,    48,   790,    48,   350,    48,    16,    48,   208,
     209,   257,   164,   377,   377,   832,   366,   670,   208,   209,
     377,   789,   377,   862,   406,    49,   954,   955,   803,   208,
     209,   659,   512,   830,   593,   667,   375,   378,   377,   516,
      76,   666,    49,   391,   517,   460,   687,   822,   814,   518,
     672,   519,   680,   681,   682,    36,    37,   520,   666,   116,
      41,   463,   973,   623,   783,   784,   594,   623,   623,   623,
     582,   582,   738,   786,   538,   538,   456,   666,   822,   666,
     341,   208,   209,   398,   834,   383,    49,   668,   521,   383,
      39,   383,   522,   898,    43,    44,    49,   165,    49,    50,
     863,   864,   618,   871,   382,   672,   642,   523,   879,   860,
     879,  -299,   884,   863,   883,   669,   524,   581,   583,   528,
      46,    46,   208,   209,    49,    46,    49,    48,    49,   398,
      49,   906,   907,    46,   947,   397,   527,   623,   341,   822,
     530,   878,   341,   618,   341,   578,   628,   885,   535,    50,
      63,   618,   545,   950,   384,   874,   749,   554,   384,   559,
     384,   561,    46,    61,   574,   899,    50,    50,   562,   119,
     910,   911,   563,    50,   668,    50,   564,    50,    50,    46,
     733,   397,   749,   160,   749,   573,   749,   575,   749,   589,
      50,    50,   672,    50,    48,    50,    63,    48,   576,   908,
     671,   385,  -151,   875,  -141,   385,    50,   385,    50,   478,
      50,    50,  -152,   356,   578,  -248,     1,  -273,     2,   600,
     504,   591,   506,    46,   508,   510,    53,   608,   651,   652,
      61,    61,   604,    46,   606,    46,   188,    61,   974,   356,
     293,    61,   356,    48,   653,   654,   625,   202,   668,    49,
     928,   929,   208,   209,   356,    61,   578,    61,   609,    61,
     627,    46,   960,    46,   975,    46,   672,    46,   822,   629,
      61,   630,    61,   655,    61,    61,   160,   807,   718,    35,
     208,   209,   623,    39,   579,   672,   494,    43,    44,   641,
     660,   656,   956,    53,    53,   669,   593,     1,   674,     2,
      53,   697,    53,   703,    53,   895,   702,   672,   208,   209,
     341,   704,   341,   666,   705,    16,    49,   669,    53,    49,
      53,   807,    53,   377,   208,   209,   638,   380,   594,   706,
     125,   126,   707,    53,   724,    53,   725,    53,    53,   127,
     863,   934,   726,   433,    36,    37,   737,    39,   116,    41,
     738,   464,   700,    36,    37,   129,    39,   116,    41,   668,
     863,   937,   130,    30,   743,    49,   754,   863,   940,   755,
     756,   949,   757,   758,   190,   759,   981,   672,   863,   941,
     132,   745,   971,   494,   984,   748,    46,   669,   135,   752,
      35,   668,   763,    38,    39,   884,   401,    42,    43,    44,
     765,   225,    36,    37,   125,   126,   116,    41,   767,   672,
     769,   982,   963,   127,   294,   208,   209,   533,   782,   357,
     234,   565,   785,   746,   141,   533,   334,   129,   464,   129,
     885,   787,   964,   792,   142,   208,   209,   548,   793,   965,
     796,   380,   208,   209,   557,   966,   243,   967,   208,   209,
     208,   209,   797,    46,   132,   798,    46,   801,    48,   802,
     145,   805,   135,    50,    50,   577,    48,   631,    50,   813,
     258,   334,    39,   810,   811,    39,    50,    48,   812,    43,
      44,   833,   334,   294,   295,   968,   593,   827,   208,   209,
     678,   366,   679,   979,   835,   334,   208,   209,   141,   338,
     961,   962,    46,   843,   671,    50,   142,   995,   142,   849,
     208,   209,   976,   977,   987,   977,   351,   850,   594,   851,
     359,   360,    50,   362,   856,   363,   859,   356,   356,   961,
     994,   861,   356,   882,   145,   887,   893,   896,   807,   903,
     356,   208,   209,   904,   338,   920,    39,    35,   146,   147,
      38,   542,   149,   150,   151,   338,    44,   593,   295,   909,
     912,   678,   366,   679,   913,   914,    50,   915,   338,   356,
     922,   917,   334,   918,   919,   921,    50,   923,    50,   924,
      49,   925,   932,   933,   935,   334,   356,   515,    49,   594,
     936,   939,   750,    35,   942,   943,    38,    39,   972,    49,
      42,    43,    44,    53,    50,   978,    50,   980,    50,   334,
      50,   646,   969,   983,   988,   992,   991,   949,   764,   996,
     766,   699,   768,   529,   770,   781,   662,   536,   826,   698,
     356,   607,    53,   905,   957,   829,   693,   675,   590,   880,
     356,   990,    61,   881,   709,   338,   700,   680,   681,   682,
     708,   661,   407,   727,   695,   741,   556,   662,   338,    93,
     208,   209,   191,   192,   751,   194,   567,   570,    61,   762,
      61,     0,    61,     0,    61,     0,   593,     0,     0,     0,
     678,   366,   679,     0,     0,     0,   712,   713,     0,   716,
       0,     0,   746,     0,     0,   586,   721,   722,   586,     0,
     744,     0,     0,    53,     0,    53,   619,   731,   594,     0,
       0,     0,     0,     0,   620,     0,   621,    46,   680,   681,
     682,     0,     0,     0,     0,    46,   464,     0,     0,    50,
     334,    53,     0,    53,     0,    53,    46,    53,     0,     0,
       0,     0,   773,     0,     0,   230,     0,     0,     0,   225,
     226,     0,   233,    35,    36,    37,     0,    39,   116,    41,
      42,     0,     0,     0,   237,   238,   592,     0,   234,   334,
     334,     0,     0,     0,   334,     0,   533,   533,   533,   533,
       0,   334,     0,   610,     0,     0,     0,     0,   240,     0,
       0,     0,     0,   356,   243,     0,    50,     0,     0,    50,
       0,   334,     0,   338,     0,   533,     0,     0,     0,   262,
       0,     0,   633,     0,   264,   265,     0,     0,   258,     0,
     260,   261,     0,     0,     1,     0,     2,   334,   269,   334,
     409,     0,     0,     0,   595,     0,     0,   680,   681,   682,
       0,     0,   338,   338,     0,    50,     0,   338,     0,   662,
       0,     0,     0,     0,   338,   820,     0,   773,     0,     0,
     356,    30,     0,   356,     0,     0,   662,     0,     0,     0,
     334,     0,   410,     0,   338,   285,    38,    39,     0,     0,
       0,    43,    44,     0,   289,   662,   837,   662,    35,   290,
      37,     0,    39,   116,    41,    42,   848,     0,     0,     0,
     338,     0,   338,     0,     0,     0,   854,     0,     0,   356,
       0,     0,     0,     0,   411,     0,   595,     0,     0,     0,
       0,     0,     0,    16,     0,     0,    53,     0,     0,     0,
       0,     0,     0,   412,     0,     0,     0,     0,     0,     0,
       0,     0,   870,   338,    59,     0,   380,   873,     0,     0,
     380,     0,   380,   596,     0,     0,     0,     0,     0,     0,
       0,   888,   889,   890,   891,   892,     0,   413,     0,   595,
       0,    30,    53,     1,   414,     2,     0,     0,     0,     0,
       0,   771,   900,   772,     0,     0,   901,   902,   713,     0,
       0,     0,     0,   334,     0,     0,     0,     0,    35,   334,
     595,    38,    39,     0,     0,    42,    43,    44,     0,     0,
     334,    59,    59,   386,     0,     0,     0,     0,    59,     0,
       0,   410,    59,     0,     0,     0,     0,     0,     0,   334,
     334,   334,     0,     0,     0,   596,    59,     0,    59,     0,
      59,     0,     0,     0,     0,     0,     0,     0,   125,   126,
       0,    59,   926,    59,   927,    59,    59,   127,     0,   773,
      50,     0,     0,   411,     0,     0,   338,     0,    50,   595,
       0,     0,    16,   129,     0,     0,   577,     0,     0,    50,
     130,     0,   412,   338,   595,     0,     0,     0,   596,     0,
     334,   334,     0,   595,   334,     0,   334,     0,   132,     0,
       0,     0,   338,     0,   338,     0,   135,   948,     0,     0,
     952,   854,     0,   595,     0,     0,   413,     0,     0,   596,
      30,   662,     0,   414,   356,     0,     0,   386,     0,   773,
       0,     0,   356,     0,     0,     0,     0,   865,   866,   867,
     868,     0,   141,   356,     0,     0,     0,    35,     0,     0,
      38,    39,   142,     0,    42,    43,    44,     0,     0,     0,
       0,     0,     0,   338,     0,   338,     0,   338,     0,   338,
       0,   688,     0,     0,     0,     0,     0,     0,   145,   620,
       0,   621,   595,     0,     0,     0,   857,     0,   596,     0,
      39,     0,     0,     0,     0,   634,     0,     0,   595,     0,
       0,     0,     0,   596,     0,     0,     0,     0,   121,     0,
     122,   595,   596,     0,   225,   226,     0,     0,     0,     0,
     334,     0,   124,     0,     0,     0,     0,     0,   985,     0,
       0,     0,   596,   234,     0,     0,     0,     0,     7,     0,
       0,     0,   916,     0,   128,     0,     0,   993,   595,   595,
       0,     0,   595,   240,     0,     0,     0,   595,   595,   243,
       0,     0,   334,     0,   334,   334,     0,   595,     0,     0,
       0,     0,     0,    15,     0,     0,   133,     0,     0,   930,
     134,   931,     0,   258,     0,   260,   261,     0,     0,   136,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   596,     0,     0,     0,   858,     0,     0,     0,   139,
       0,   944,     0,     0,   140,     0,     0,   596,     0,     0,
       0,     0,     0,   386,   230,     0,    30,     0,     0,     0,
     596,   233,     0,   143,     0,   338,     0,   338,   338,     0,
     285,     0,     0,   237,   238,     0,     0,     0,     0,   289,
       0,     0,     0,    35,   290,    37,   595,    39,   116,    41,
      42,     0,     0,     0,     0,     0,     0,   596,   596,     0,
       0,   596,     0,   595,     0,     0,   596,   596,     0,     0,
       0,     0,     0,     0,   595,     0,   596,     0,   262,     0,
     595,     0,     0,   264,   265,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   739,   595,   269,     0,   595,
       0,     0,     0,     1,     0,     2,   845,     0,     0,     0,
       0,     0,     0,    59,   595,   595,   595,   595,   595,   121,
       0,   122,     0,     0,     0,     0,   595,   595,   595,     0,
       0,     0,     0,   124,     0,     0,     0,     0,   225,    59,
       0,    59,     0,    59,     0,    59,    39,   228,     0,     7,
      43,    44,   595,   595,     0,   128,     0,   234,     0,     0,
       0,     0,     0,     0,     0,   596,     0,     0,     0,     0,
       0,     0,     0,     0,   595,     0,     0,   240,   595,     0,
       0,     0,   596,   243,    15,     0,     0,   133,     0,     0,
       0,   134,     0,   596,     0,     0,     0,     0,     0,   596,
     136,     0,    16,     0,     0,     0,     0,   258,     0,   260,
     261,   595,     0,     0,     0,   596,     0,     0,   596,   595,
     139,     0,     0,     0,     0,   140,     0,     0,     0,     0,
       0,     0,     0,   596,   596,   596,   596,   596,     0,     0,
       0,     0,   469,     0,   143,   596,   596,   596,     0,     0,
      30,     0,   121,     0,   122,     0,     1,     0,     2,     0,
       0,     0,     3,     0,   285,     0,   124,     0,     0,     0,
       0,   596,   596,     4,     0,     0,     0,    35,     0,     0,
      38,    39,     7,     0,    42,    43,    44,   293,   128,   294,
     295,   296,     0,   596,     0,     5,     6,   596,     0,     0,
     525,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     8,     0,     0,     0,     0,     9,    15,     0,     0,
     133,     0,   386,     0,   134,   877,   386,    10,   386,     0,
     596,    11,     0,   136,    12,    13,     0,    14,   596,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   139,     0,    16,     0,     0,   140,     0,
       0,     0,    17,    18,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    19,    20,     0,     0,   143,    21,    22,
      23,    24,     0,     0,   121,     0,   122,    25,    26,    27,
       0,     0,     0,    28,     0,     0,     0,     0,   124,     0,
       0,     0,    29,    30,     0,     0,     0,     0,     0,     0,
       0,    31,     0,     0,     7,     0,     0,     0,     0,     0,
     128,    32,     0,    33,     0,    34,     0,     0,     0,     0,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
     207,     0,   208,   209,     0,     0,     0,     0,   210,    15,
     211,     0,   133,     0,   418,     0,   134,     0,     0,   213,
     214,   215,     0,     0,     0,   136,   216,   217,     0,     0,
       0,     0,   218,   219,   220,   221,   222,   223,   224,     0,
       0,     0,     0,   225,   226,   139,     0,     0,     0,     0,
     140,   227,   228,   229,   230,     0,   410,     0,     0,   231,
     232,   233,   234,     0,     0,     0,   235,   236,     0,   143,
       0,     0,     0,   237,   238,     0,     0,     0,     0,     0,
     239,     0,   240,     0,   241,     0,   242,     0,   243,     0,
       0,     0,   244,     0,   245,   246,     0,   247,   411,   248,
       0,   249,   250,   251,   252,   253,   254,    16,   255,     0,
     256,   257,   258,   259,   260,   261,     0,   412,   262,     0,
       0,   263,     0,   264,   265,     0,     0,     0,   266,     0,
       0,     0,     0,     0,     0,   267,   268,   269,   270,     0,
       0,     0,   271,   272,   273,     0,   274,   275,     0,   276,
     277,   413,   278,     0,     0,    30,   279,     0,   414,   280,
     281,     0,     0,     0,     0,     0,   282,   283,   284,   285,
     286,   287,     0,     0,   288,     0,     0,     0,   289,     0,
       0,     0,    35,   290,   291,    38,   419,    40,   292,    42,
      43,    44,   293,     0,   294,   295,   296,   207,     0,   208,
     209,     0,     0,     0,     0,   210,     0,   211,     0,     0,
       0,     0,     0,     0,     0,     0,   213,   214,   215,     0,
       0,     0,     0,   216,   217,     0,     0,     0,     0,   218,
     219,   220,   221,   222,   223,   224,     0,     0,     0,     0,
     225,   226,     0,     0,     0,     0,     0,     0,   227,   228,
     229,   230,     0,   410,     0,     0,   231,   232,   233,   234,
       0,     0,     0,   235,   236,     0,     0,     0,     0,     0,
     237,   238,     0,     0,     0,     0,     0,   239,     0,   240,
       0,   241,     0,   242,     0,   243,     0,     0,     0,   244,
       0,   245,   246,     0,   247,   411,   248,     0,   249,   250,
     251,   252,   253,   254,    16,   255,     0,   256,   257,   258,
     259,   260,   261,     0,   412,   262,     0,     0,   263,     0,
     264,   265,     0,     0,     0,   266,     0,     0,     0,     0,
       0,     0,   267,   268,   269,   270,     0,     0,     0,   271,
     272,   273,     0,   274,   275,     0,   276,   277,   413,   278,
       0,     0,    30,   279,     0,   414,   280,   281,     0,     0,
       0,     0,     0,   282,   283,   284,   285,   286,   287,     0,
       0,   288,     0,     0,     0,   289,     0,     0,     0,    35,
     290,   291,    38,   419,    40,   292,    42,    43,    44,   293,
       0,   294,   295,   296,   207,     0,   208,   209,     0,     0,
       0,     0,   210,     0,   211,     0,     0,     0,   212,     0,
       0,     0,     0,   213,   214,   215,     0,     0,     0,     0,
     216,   217,     0,     0,     0,     0,   218,   219,   220,   221,
     222,   223,   224,     0,     0,     0,     0,   225,   226,     0,
       0,     0,     0,     0,     0,   227,   228,   229,   230,     0,
       0,     0,     0,   231,   232,   233,   234,     0,     0,     0,
     235,   236,     0,     0,     0,     0,     0,   237,   238,     0,
       0,     0,     0,     0,   239,     0,   240,     0,   241,     0,
     242,     0,   243,     0,     0,     0,   244,     0,   245,   246,
       0,   247,     0,   248,     0,   249,   250,   251,   252,   253,
     254,    16,   255,     0,   256,   257,   258,   259,   260,   261,
       0,     0,   262,     0,     0,   263,     0,   264,   265,     0,
       0,     0,   266,     0,     0,     0,     0,     0,     0,   267,
     268,   269,   270,     0,     0,     0,   271,   272,   273,     0,
     274,   275,     0,   276,   277,     0,   278,     0,     0,    30,
     279,     0,     0,   280,   281,     0,     0,     0,     0,     0,
     282,   283,   284,   285,   286,   287,     0,     0,   288,     0,
       0,     0,   289,     0,     0,     0,    35,   290,   291,    38,
      39,    40,   292,    42,    43,    44,   293,     0,   294,   295,
     296,   207,     0,   208,   209,   539,     0,     0,     0,   210,
       0,   211,     0,     0,     0,     0,     0,     0,     0,     0,
     213,   214,   215,     0,     0,     0,     0,   216,   217,     0,
       0,     0,     0,   218,   219,   220,   221,   222,   223,   224,
       0,     0,     0,     0,   225,   226,     0,     0,     0,     0,
       0,     0,   227,   228,   229,   230,     0,     0,     0,     0,
     231,   232,   233,   234,     0,     0,     0,   235,   236,     0,
       0,     0,     0,     0,   237,   238,     0,     0,     0,     0,
       0,   239,     0,   240,     0,   241,     0,   242,     0,   243,
       0,     0,     0,   244,     0,   245,   246,     0,   247,     0,
     248,     0,   249,   250,   251,   252,   253,   254,    16,   255,
       0,   256,   257,   258,   259,   260,   261,     0,     0,   262,
       0,     0,   263,     0,   264,   265,     0,     0,     0,   266,
       0,     0,     0,     0,     0,     0,   267,   268,   269,   270,
       0,     0,     0,   271,   272,   273,     0,   274,   275,     0,
     276,   277,     0,   278,     0,     0,    30,   279,     0,     0,
     280,   281,     0,     0,     0,     0,     0,   282,   283,   284,
     285,   286,   287,     0,     0,   288,     0,     0,     0,   289,
       0,     0,     0,    35,   290,   291,    38,    39,    40,   292,
      42,    43,    44,   293,     0,   294,   295,   296,   207,     0,
     208,   209,     0,     0,     0,     0,   210,     0,   211,     0,
       0,     0,     0,     0,     0,     0,     0,   213,   214,   215,
       0,     0,     0,     0,   216,   217,     0,     0,     0,     0,
     218,   219,   220,   221,   222,   223,   224,     0,     0,     0,
       0,   225,   226,     0,     0,     0,     0,     0,     0,   227,
     228,   229,   230,     0,     0,     0,     0,   231,   232,   233,
     234,     0,     0,     0,   235,   236,     0,     0,     0,     0,
       0,   237,   238,     0,     0,     0,     0,     0,   239,     0,
     240,    11,   241,     0,   242,     0,   243,     0,     0,     0,
     244,     0,   245,   246,     0,   247,     0,   248,     0,   249,
     250,   251,   252,   253,   254,    16,   255,     0,   256,   257,
     258,   259,   260,   261,     0,     0,   262,     0,     0,   263,
       0,   264,   265,     0,     0,     0,   266,     0,     0,     0,
       0,     0,     0,   267,   268,   269,   270,     0,     0,     0,
     271,   272,   273,     0,   274,   275,     0,   276,   277,     0,
     278,     0,     0,    30,   279,     0,     0,   280,   281,     0,
       0,     0,     0,     0,   282,   283,   284,   285,   286,   287,
       0,     0,   288,     0,     0,     0,   289,     0,     0,     0,
      35,   290,   291,    38,    39,    40,   292,    42,    43,    44,
     293,     0,   294,   295,   296,   379,     0,   208,   209,     0,
       0,     0,     0,   210,     0,   211,     0,     0,     0,     0,
       0,     0,     0,     0,   213,   214,   215,     0,     0,     0,
       0,   216,   217,     0,     0,     0,     0,   218,   219,   220,
     221,   222,   223,   224,     0,     0,     0,     0,   225,   226,
       0,     0,     0,     0,     0,     0,   227,   228,   229,   230,
       0,     0,     0,     0,   231,   232,   233,   234,     0,     0,
       0,   235,   236,     0,     0,     0,     0,     0,   237,   238,
       0,     0,     0,     0,     0,   239,     0,   240,     0,   241,
       0,   242,     0,   243,     0,     0,     0,   244,     0,   245,
     246,     0,   247,     0,   248,     0,   249,   250,   251,   252,
     253,   254,    16,   255,     0,   256,   257,   258,   259,   260,
     261,     0,     0,   262,     0,     0,   263,     0,   264,   265,
       0,     0,     0,   266,     0,     0,     0,     0,     0,     0,
     267,   268,   269,   270,     0,     0,     0,   271,   272,   273,
       0,   274,   275,     0,   276,   277,     0,   278,     0,     0,
      30,   279,     0,     0,   280,   281,     0,     0,     0,     0,
       0,   282,   283,   284,   285,   286,   287,     0,     0,   288,
       0,     0,     0,   289,     0,     0,     0,    35,   290,   291,
      38,    39,    40,   292,    42,    43,    44,   293,     0,   294,
     295,   296,   207,     0,   208,   209,     0,     0,     0,     0,
     210,     0,   211,     0,     0,     0,     0,     0,     0,     0,
       0,   213,   214,   215,     0,     0,     0,     0,   216,   217,
       0,     0,     0,     0,   218,   219,   220,   221,   222,   223,
     224,     0,     0,     0,     0,   225,   226,     0,     0,     0,
       0,     0,     0,   227,   228,   229,   230,     0,     0,     0,
       0,   231,   232,   233,   234,     0,     0,     0,   235,   236,
       0,     0,     0,     0,     0,   237,   238,     0,     0,     0,
       0,     0,   239,     0,   240,     0,   241,     0,   242,     0,
     243,     0,     0,     0,   244,     0,   245,   246,     0,   247,
       0,   248,     0,   249,   250,   251,   252,   253,   254,    16,
     255,     0,   256,   257,   258,   259,   260,   261,     0,     0,
     262,     0,     0,   263,     0,   264,   265,     0,     0,     0,
     266,     0,     0,     0,     0,     0,     0,   267,   268,   269,
     270,     0,     0,     0,   271,   272,   273,     0,   274,   275,
       0,   276,   277,     0,   278,     0,     0,    30,   279,     0,
       0,   280,   281,     0,     0,     0,     0,     0,   282,   283,
     284,   285,   286,   287,     0,     0,   288,     0,     0,     0,
     289,     0,     0,     0,    35,   290,   291,    38,    39,    40,
     292,    42,    43,    44,   293,     0,   294,   295,   296,   207,
       0,   208,   209,     0,     0,     0,     0,   210,     0,   211,
       0,     0,     0,     0,     0,     0,     0,     0,   213,   214,
     215,     0,     0,     0,     0,   216,   217,     0,     0,     0,
       0,   218,   219,   220,   221,   222,   223,   224,     0,     0,
       0,     0,   225,   226,     0,     0,     0,     0,     0,     0,
     227,   228,   229,   230,     0,     0,     0,     0,   231,   232,
     233,   234,     0,     0,     0,   235,   236,     0,     0,     0,
       0,     0,   237,   238,     0,     0,     0,     0,     0,   239,
       0,   240,     0,   241,     0,     0,     0,   243,     0,     0,
       0,   244,     0,   245,   246,     0,   247,     0,   248,     0,
     249,   250,   251,   252,   253,   254,     0,   255,     0,   256,
       0,   258,   259,   260,   261,     0,     0,   262,     0,     0,
     263,     0,   264,   265,     0,     0,     0,   266,     0,     0,
       0,     0,     0,     0,   267,   268,   269,   270,     0,     0,
       0,   271,   272,   273,     0,   274,   275,     0,   276,   277,
       0,   278,     0,     0,    30,   279,     0,     0,   280,   281,
       0,     0,     0,     0,     0,   282,   283,   284,   285,   286,
     287,     0,     0,   288,     0,     0,     0,   289,     0,     0,
       0,    35,   290,   291,    38,    39,   116,   292,    42,    43,
      44,   293,     0,   294,   295,   296,   730,     0,   208,   209,
       0,     0,     0,     0,   210,     0,   211,     0,     0,     0,
       0,     0,     0,     0,     0,   213,   214,   215,     0,     0,
       0,     0,   216,   217,     0,     0,     0,     0,   218,   219,
     220,   221,   222,   223,   224,     0,     0,     0,     0,   225,
     226,     0,     0,     0,     0,     0,     0,   227,     0,     0,
     230,     0,     0,     0,     0,   231,   232,   233,   234,     0,
       0,     0,   235,   236,     0,     0,     0,     0,     0,   237,
     238,     0,     0,     0,     0,     0,   239,     0,   240,     0,
     241,     0,     0,     0,   243,     0,     0,     0,   244,     0,
     245,   246,     0,   247,     0,     0,     0,   249,   250,   251,
     252,   253,   254,     0,   255,     0,   256,     0,   258,   259,
     260,   261,     0,     0,   262,     0,     0,   263,     0,   264,
     265,     0,     0,     0,   266,     0,     0,     0,     0,     0,
       0,     0,   268,   269,   270,     0,     0,     0,   271,   272,
     273,     0,   274,   275,     0,   276,   277,     0,   278,     0,
       0,    30,   279,     0,     0,   280,   281,     0,     0,     0,
       0,     0,   282,   283,     0,   285,   286,   287,     0,     0,
     288,     0,     0,     0,   289,     0,     0,     0,    35,   290,
      37,     0,    39,   116,   292,    42,    43,    44,     0,     0,
     294,   295,   296,   818,     0,   208,   209,     0,     0,     0,
       0,     1,     0,     2,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   216,
     217,     0,     0,     0,     0,   218,   219,   220,   221,   222,
     223,   224,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   227,   228,   229,   230,     0,     0,
       0,     0,   231,   232,   233,     0,     0,     0,     0,   235,
     236,     0,     0,     0,     0,     0,   237,   238,     0,     0,
       0,     0,     0,   239,     0,     0,     0,   241,     0,     0,
       0,     0,     0,     0,     0,   244,     0,   245,   246,     0,
     247,     0,   248,     0,   249,   250,   251,   252,   253,   254,
       0,   255,     0,     0,     0,     0,   259,     0,     0,     0,
       0,   262,     0,     0,   263,     0,   264,   265,     0,     0,
       0,   266,     0,     0,     0,     0,     0,     0,   267,   268,
     269,   270,     0,     0,     0,   271,   272,   273,     0,   274,
     275,     0,   276,   277,     0,   278,     0,     0,     0,   279,
       0,     0,   280,   281,     0,     0,     0,     0,     0,   282,
     283,   284,     0,   286,   287,     0,   429,   288,   208,   209,
       0,     0,     0,     0,     1,     0,     2,   819,    38,    39,
       0,   432,     0,    43,    44,   293,     0,   294,   295,   296,
       0,     0,   216,   217,     0,     0,     0,     0,   218,   219,
     220,   221,   222,   223,   224,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   227,     0,     0,
     230,     0,     0,     0,     0,   231,   232,   233,     0,     0,
       0,     0,   235,   236,     0,     0,     0,     0,     0,   237,
     238,     0,     0,     0,     0,     0,   239,     0,     0,     0,
     241,   430,     0,     0,     0,     0,     0,     0,   244,     0,
     245,   246,     0,   247,     0,     0,     0,   249,   250,   251,
     252,   253,   254,     0,   255,     0,     0,     0,     0,   259,
       0,     0,     0,     0,   262,     0,     0,   263,     0,   264,
     265,     0,     0,     0,   266,     0,     0,     0,     0,     0,
       0,     0,   268,   269,   270,     0,     0,     0,   271,   272,
     273,     0,   274,   275,     0,   276,   277,     0,   278,     0,
       0,     0,   279,     0,     0,   280,   281,     0,     0,     0,
       0,     0,   282,   283,     0,     0,   286,   287,   431,   429,
     288,   208,   209,   644,     0,     0,   645,     1,     0,     2,
       0,     0,    39,     0,   432,     0,    43,    44,     0,     0,
     294,   295,   296,     0,     0,   216,   217,     0,     0,     0,
       0,   218,   219,   220,   221,   222,   223,   224,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     227,     0,     0,   230,     0,     0,     0,     0,   231,   232,
     233,     0,     0,     0,     0,   235,   236,     0,     0,     0,
       0,     0,   237,   238,     0,     0,     0,     0,     0,   239,
       0,     0,     0,   241,     0,     0,     0,     0,     0,     0,
       0,   244,     0,   245,   246,     0,   247,     0,     0,     0,
     249,   250,   251,   252,   253,   254,     0,   255,     0,     0,
       0,     0,   259,     0,     0,     0,     0,   262,     0,     0,
     263,     0,   264,   265,     0,     0,     0,   266,     0,     0,
       0,     0,     0,     0,     0,   268,   269,   270,     0,     0,
       0,   271,   272,   273,     0,   274,   275,     0,   276,   277,
       0,   278,     0,     0,     0,   279,     0,     0,   280,   281,
       0,     0,     0,     0,     0,   282,   283,     0,     0,   286,
     287,     0,   429,   288,   208,   209,   532,     0,     0,     0,
       1,     0,     2,     0,     0,    39,     0,   432,     0,    43,
      44,     0,     0,   294,   295,   296,     0,     0,   216,   217,
       0,     0,     0,     0,   218,   219,   220,   221,   222,   223,
     224,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   227,     0,     0,   230,     0,     0,     0,
       0,   231,   232,   233,     0,     0,     0,     0,   235,   236,
       0,     0,     0,     0,     0,   237,   238,     0,     0,     0,
       0,     0,   239,     0,     0,     0,   241,     0,     0,     0,
       0,     0,     0,     0,   244,     0,   245,   246,     0,   247,
       0,     0,     0,   249,   250,   251,   252,   253,   254,     0,
     255,     0,     0,     0,     0,   259,     0,     0,     0,     0,
     262,     0,     0,   263,     0,   264,   265,     0,     0,     0,
     266,     0,     0,     0,     0,     0,     0,     0,   268,   269,
     270,     0,     0,     0,   271,   272,   273,     0,   274,   275,
       0,   276,   277,     0,   278,     0,     0,     0,   279,     0,
       0,   280,   281,     0,     0,     0,     0,     0,   282,   283,
       0,     0,   286,   287,     0,   429,   288,   208,   209,     0,
       0,     0,   645,     1,     0,     2,     0,     0,    39,     0,
     432,     0,    43,    44,     0,     0,   294,   295,   296,     0,
       0,   216,   217,     0,     0,     0,     0,   218,   219,   220,
     221,   222,   223,   224,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   227,     0,     0,   230,
       0,     0,     0,     0,   231,   232,   233,     0,     0,     0,
       0,   235,   236,     0,     0,     0,     0,     0,   237,   238,
       0,     0,     0,     0,     0,   239,     0,     0,     0,   241,
       0,     0,     0,     0,     0,     0,     0,   244,     0,   245,
     246,     0,   247,     0,     0,     0,   249,   250,   251,   252,
     253,   254,     0,   255,     0,     0,     0,     0,   259,     0,
       0,     0,     0,   262,     0,     0,   263,     0,   264,   265,
       0,     0,     0,   266,     0,     0,     0,     0,     0,     0,
       0,   268,   269,   270,     0,     0,     0,   271,   272,   273,
       0,   274,   275,     0,   276,   277,     0,   278,     0,     0,
       0,   279,     0,     0,   280,   281,     0,     0,     0,     0,
       0,   282,   283,     0,     0,   286,   287,     0,   429,   288,
     208,   209,     0,     0,     0,     0,     1,     0,     2,     0,
       0,    39,     0,   432,     0,    43,    44,     0,     0,   294,
     295,   296,     0,     0,   216,   217,     0,     0,     0,     0,
     218,   219,   220,   221,   222,   223,   224,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   227,
       0,     0,   230,     0,     0,     0,     0,   231,   232,   233,
       0,     0,     0,     0,   235,   236,     0,     0,     0,     0,
       0,   237,   238,     0,     0,     0,     0,     0,   239,     0,
       0,     0,   241,     0,     0,     0,     0,     0,     0,     0,
     244,     0,   245,   246,     0,   247,     0,     0,     0,   249,
     250,   251,   252,   253,   254,     0,   255,     0,     0,     0,
       0,   259,     0,     0,     0,     0,   262,     0,     0,   263,
       0,   264,   265,     0,     0,     0,   266,     0,     0,     0,
       0,     0,     0,     0,   268,   269,   270,     0,     0,     0,
     271,   272,   273,     0,   274,   275,     0,   276,   277,     0,
     278,     0,     0,     0,   279,     0,     0,   280,   281,     0,
       0,     0,     0,     0,   282,   283,     0,     0,   286,   287,
     429,     0,   288,     0,   601,   602,     0,     0,     1,     0,
       2,     0,     0,     0,    39,     0,   432,     0,    43,    44,
       0,     0,   294,   295,   296,     0,   216,   217,     0,     0,
       0,     0,   218,   219,   220,   221,   222,   223,   224,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   227,     0,     0,   230,     0,     0,     0,     0,   231,
     232,   233,     0,     0,     0,     0,   235,   236,     0,     0,
       0,     0,     0,   237,   238,     0,     0,     0,     0,     0,
     239,     0,     0,     0,   241,     0,     0,     0,     0,     0,
       0,     0,   244,     0,   245,   246,     0,   247,     0,     0,
       0,   249,   250,   251,   252,   253,   254,     0,   255,     0,
       0,     0,     0,   259,     0,     0,     0,     0,   262,     0,
       0,   263,     0,   264,   265,     0,     0,     0,   266,     0,
       0,     0,     0,     0,     0,     0,   268,   269,   270,     0,
       0,     0,   271,   272,   273,     0,   274,   275,     0,   276,
     277,     0,   278,     0,     0,     0,   279,     0,     0,   280,
     281,     0,     0,     0,     0,     0,   282,   283,     0,     0,
     286,   287,   429,     0,   288,     0,     0,     0,     0,     0,
       1,     0,     2,     0,     0,     0,    39,     0,   432,     0,
      43,    44,     0,     0,   294,   295,   296,     0,   216,   217,
       0,     0,     0,     0,   218,   219,   220,   221,   222,   223,
     224,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   227,     0,     0,   230,     0,     0,     0,
       0,   231,   232,   233,     0,     0,     0,     0,   235,   236,
       0,     0,     0,     0,     0,   237,   238,     0,     0,     0,
       0,     0,   239,     0,     0,     0,   241,     0,     0,     0,
       0,     0,     0,     0,   244,     0,   245,   246,     0,   247,
       0,     0,     0,   249,   250,   251,   252,   253,   254,     0,
     255,     0,     0,     0,     0,   259,     0,     0,     0,     0,
     262,     0,     0,   263,     0,   264,   265,     0,     0,     0,
     266,     0,     0,     0,     0,     0,     0,     0,   268,   269,
     270,     1,     0,     2,   271,   272,   273,     0,   274,   275,
       0,   276,   277,     0,   278,     0,     0,     0,   279,     0,
       0,   280,   281,     0,     0,     0,     0,     0,   282,   283,
       0,     0,   286,   287,     0,     0,   288,     0,     0,     0,
       0,   619,     0,     0,     0,     0,     0,   230,    39,   620,
     432,   621,    43,    44,   233,     0,   294,   295,   296,     0,
     213,   214,   215,     0,     0,     0,   237,   238,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   619,     0,
       0,     0,     0,     0,   225,   226,   620,     0,   621,     0,
       0,     0,     0,     0,     0,     0,     0,   213,   214,   215,
      16,     0,     0,   234,   840,     0,   714,     0,     0,     0,
       0,   262,     0,     0,     0,     0,   264,   265,     0,     0,
       0,   225,   226,   240,     0,     0,     0,     0,     0,   243,
     269,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     234,     0,     0,     0,     0,     0,     0,     0,    30,     0,
       0,   256,     0,   258,     0,   260,   261,     0,     0,     0,
     240,     0,     0,     0,     0,     0,   243,     0,     0,     0,
       0,     0,     0,     0,     0,    35,    36,    37,    38,    39,
     116,    41,    42,    43,    44,     0,     0,     0,   256,     0,
     258,     0,   260,   261,     0,     0,    30,     0,     0,     0,
       0,     0,     0,     0,     1,     0,     2,     0,     0,     0,
     285,     0,     0,     0,     0,     0,     0,     0,     0,   289,
       0,     0,     0,    35,   290,    37,     0,    39,   116,    41,
      42,     0,     0,    30,     0,     0,     0,     0,     0,   225,
       0,     0,     0,     0,     0,     0,     0,   285,   228,     0,
     230,     0,     0,     0,     0,     0,   289,   233,   234,     0,
      35,   290,    37,     0,    39,   116,    41,    42,     0,   237,
     238,     0,     0,     0,     0,     0,     0,     0,   240,     0,
       0,     0,     0,     0,   243,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    16,     0,     0,     0,     0,   258,     0,
     260,   261,     0,     0,   262,     0,     0,     0,     0,   264,
     265,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   269,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    30,     0,     0,     1,     0,     2,     0,     0,     0,
       3,     0,     0,     0,     0,   285,     0,     0,     0,     0,
       0,     4,     0,     0,     0,     0,     0,     0,    35,    36,
      37,    38,    39,   116,    41,    42,    43,    44,   293,     0,
     294,   295,   296,     5,     6,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     7,     0,     0,     0,     0,     8,
       0,     0,     0,     0,     9,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    10,     0,     0,     0,    11,
       0,     0,    12,    13,     0,    14,     0,     0,     0,    15,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    16,     0,     0,     0,     0,     0,     0,
      17,    18,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    19,    20,     0,     0,     0,    21,    22,    23,    24,
       0,     0,     0,     0,     0,    25,    26,    27,     0,     0,
       0,    28,     0,     0,     0,     0,     0,     0,     0,     0,
      29,    30,     0,     0,     0,     1,     0,     2,     0,    31,
       0,     3,     0,     0,     0,     0,     0,     0,     0,    32,
       0,    33,     4,    34,     0,     0,     0,     0,    35,    36,
      37,    38,    39,    40,    41,    42,    43,    44,     0,     0,
       0,     0,     0,     0,     5,     6,     0,     0,     0,     0,
       0,     0,   474,     0,     0,     0,     0,     0,     0,     0,
       8,     0,     0,     0,     0,     9,     0,     0,     0,   475,
     230,     0,     0,     0,     0,     0,    10,   233,     0,     0,
      11,     0,     0,    12,    13,     0,    14,     0,     0,   237,
     238,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    16,     0,     0,     0,     0,     0,
       0,    17,    18,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    19,    20,     0,     0,     0,    21,    22,    23,
      24,     0,     0,     0,   262,     0,    25,    26,    27,   264,
     265,     0,    28,     0,     0,     0,     0,     0,     0,     0,
       0,    29,    30,   269,     0,     0,     1,     0,     2,     0,
      31,     0,     3,     0,     0,     0,     0,     0,     0,     0,
      32,     0,    33,     4,    34,     0,     0,     0,     0,    35,
      36,    37,    38,    39,    40,    41,    42,    43,    44,     0,
       0,     0,     0,     0,     0,     5,     6,     0,    35,    36,
      37,    38,    39,   116,    41,    42,    43,    44,     0,     0,
       0,     0,     0,     0,     0,     0,     9,     0,     0,   403,
       0,     0,   230,     0,     0,     0,     0,    10,     0,   233,
       0,    11,     0,     0,    12,    13,     0,    14,     0,     0,
       0,   237,   238,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    16,     0,     0,     0,     0,
       0,     0,    17,    18,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    19,    20,     0,     0,     0,    21,     0,
      23,    24,     0,     0,     0,     0,   262,    25,    26,    27,
       0,   264,   265,    28,     0,     0,     0,     0,     0,     0,
       0,     0,     1,    30,     2,   269,     0,     0,     3,     0,
     404,    31,     0,     0,     0,     0,     0,     0,     0,     4,
       0,    32,     0,    33,     0,    34,     0,     0,     0,     0,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
       0,     5,     6,     0,     0,     0,     0,     0,     0,     0,
      35,    36,    37,     0,    39,   116,    41,    42,    43,    44,
       0,     0,     9,     0,     0,   403,     0,     0,     0,     0,
       0,     0,     0,    10,     0,   394,     0,    11,     0,     0,
       0,    13,     0,    14,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    16,     0,     0,     0,     0,     0,     0,    17,    18,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    19,
      20,     0,     0,     0,    21,     0,    23,    24,     0,     0,
       0,     0,     0,    25,    26,    27,     0,     0,     0,    28,
       0,     0,     0,     0,     0,     0,     0,     0,     1,    30,
       2,     0,     0,     0,     3,   395,     0,    31,     0,     0,
       0,     0,     0,     0,     0,     4,     0,   396,     0,    33,
       0,    34,     0,     0,     0,     0,    35,    36,    37,    38,
      39,   116,    41,    42,    43,    44,     0,     5,     6,     0,
       0,     0,     0,     0,     0,   474,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     9,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    10,
       0,   394,     0,    11,     0,     0,     0,    13,     0,    14,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    16,     0,     0,
       0,     0,     0,     0,    17,    18,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    19,    20,     0,     0,     0,
      21,     0,    23,    24,     0,     0,     0,     0,     0,    25,
      26,    27,     0,     0,     0,    28,     0,     0,     0,     0,
       0,     0,     0,     0,     1,    30,     2,     0,     0,     0,
       3,   395,     0,    31,     0,     0,     0,     0,     0,     0,
       0,     4,     0,   396,     0,    33,     0,    34,     0,     0,
       0,     0,    35,    36,    37,    38,    39,   116,    41,    42,
      43,    44,     0,     5,     6,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     9,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    10,     0,   394,     0,    11,
       0,     0,     0,    13,     0,    14,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    16,     0,     0,     0,     0,     0,     0,
      17,    18,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    19,    20,     0,     0,     0,    21,     0,    23,    24,
       0,     0,     0,     0,     0,    25,    26,    27,     0,     0,
       0,    28,     0,     0,     0,     0,     0,     0,     0,     0,
       1,    30,     2,     0,     0,     0,     3,   395,     0,    31,
       0,     0,     0,     0,     0,     0,     0,     4,     0,   396,
       0,    33,     0,    34,     0,     0,     0,     0,    35,    36,
      37,    38,    39,   116,    41,    42,    43,    44,     0,     5,
       6,     0,     0,     0,     0,     0,     0,   474,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       9,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    10,     0,     0,     0,    11,     0,     0,    12,    13,
       0,    14,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    16,
       0,     0,     0,     0,     0,     0,    17,    18,     0,     0,
       0,     0,     0,     1,     0,     2,     0,    19,    20,     3,
       0,     0,    21,     0,    23,    24,     0,     0,     0,     0,
       4,    25,    26,    27,     0,     0,     0,    28,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    30,     0,     0,
       0,     0,     5,     6,     0,    31,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    32,     0,    33,     0,    34,
       0,     0,     0,     9,    35,    36,    37,    38,    39,    40,
      41,    42,    43,    44,    10,     0,     0,     0,    11,     0,
       0,    12,    13,     0,    14,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    16,     0,     0,     0,     0,     0,     0,    17,
      18,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      19,    20,     0,     0,     0,    21,     0,    23,    24,     0,
       0,     0,     0,     0,    25,    26,    27,     0,     0,     0,
      28,     0,     0,     0,     0,     0,     0,     0,     0,     1,
      30,     2,     0,     0,     0,     3,     0,     0,    31,     0,
       0,     0,     0,     0,     0,     0,     4,     0,   374,     0,
      33,     0,    34,     0,     0,     0,     0,    35,    36,    37,
      38,    39,    40,    41,    42,    43,    44,     0,     5,     6,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     9,
       0,     0,   403,     0,     0,     0,     0,     0,     0,     0,
      10,     0,     0,     0,    11,     0,     0,     0,    13,     0,
      14,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    16,     0,
       0,     0,     0,     0,     0,    17,    18,     0,     0,     0,
       0,     0,     1,     0,     2,     0,    19,    20,     3,     0,
       0,    21,     0,    23,    24,     0,     0,     0,     0,     4,
      25,    26,    27,     0,     0,     0,    28,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    30,     0,     0,     0,
       0,     5,     6,     0,    31,     0,     0,     0,     0,   474,
       0,     0,     0,     0,   374,     0,    33,     0,    34,     0,
       0,     0,     9,    35,    36,    37,    38,    39,   116,    41,
      42,    43,    44,    10,     0,     0,     0,    11,     0,     0,
       0,    13,     0,    14,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    16,     0,     0,     0,     0,     0,     0,    17,    18,
       0,     0,     0,     0,     0,     1,     0,     2,     0,    19,
      20,     3,     0,     0,    21,     0,    23,    24,     0,     0,
       0,     0,     4,    25,    26,    27,     0,     0,     0,    28,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    30,
       0,     0,     0,     0,     5,     6,     0,    31,     1,     0,
       2,     0,     0,     0,     0,     0,     0,   374,     0,    33,
       0,    34,     0,     0,     0,     9,    35,    36,    37,    38,
      39,   116,    41,    42,    43,    44,    10,     0,     0,     0,
      11,     0,     0,     0,    13,     0,    14,     0,     0,     0,
       0,     0,     0,     0,   230,     0,     0,     0,     0,     0,
       0,   233,     0,     0,    16,     0,     0,     0,     0,     0,
       0,    17,    18,   237,   238,     0,     0,     0,     0,     0,
       0,     0,    19,    20,     0,     0,     0,    21,     0,    23,
      24,     0,     0,     0,     0,     0,    25,    26,    27,     0,
       0,     0,    28,     0,     0,     0,     0,    16,     0,     0,
       0,     0,    30,     0,     0,     0,     0,     0,   262,     0,
      31,     0,     0,   264,   265,     0,     0,     0,     0,     0,
     374,     0,    33,     0,    34,     0,     0,   269,     0,    35,
      36,    37,    38,    39,   116,    41,    42,    43,    44,     0,
       0,     0,     0,     0,     0,    30,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    35,    36,    37,    38,    39,   116,    41,    42,
      43,    44,   121,     0,   122,     0,     0,     0,     0,     0,
       0,     0,     0,   123,     0,     0,   124,     0,   125,   126,
       0,     0,     0,     0,     0,     0,     0,   127,     0,     0,
       0,     0,     7,     0,     0,     0,     0,     0,   128,     0,
       0,     0,     0,   129,     0,     0,     0,     0,     0,     0,
     130,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     131,     0,     0,     0,     0,     0,     0,    15,   132,     0,
     133,     0,     0,     0,   134,     0,   135,     0,     0,     0,
       0,     0,     0,   136,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   137,     0,   138,     0,     0,     0,
       0,     0,     0,   139,     0,     0,     0,     0,   140,     0,
       0,     0,   141,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   142,     0,     0,     0,     0,   143,     0,     0,
       0,     0,     0,     0,     0,   144,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   145,     0,
       0,     0,     0,   121,     0,   122,    35,   146,   147,    38,
     148,   149,   150,   151,   123,    44,     0,   124,     0,   125,
     126,     0,     0,     0,     0,     0,     0,     0,   127,     0,
       0,     0,     0,     7,     0,     0,     0,     0,     0,   128,
     121,     0,   122,     0,   129,     0,     0,     0,     0,     0,
       0,   130,     0,     0,   124,     0,   125,   126,     0,     0,
       0,   131,     0,     0,     0,   127,     0,     0,    15,   132,
       7,   133,     0,     0,     0,   134,   128,   135,     0,     0,
       0,   129,     0,     0,   136,     0,     0,     0,   130,     0,
       0,     0,     0,     0,     0,   137,     0,   138,     0,     0,
       0,     0,     0,     0,   139,    15,   132,     0,   133,   140,
       0,     0,   134,   141,   135,     0,     0,     0,     0,     0,
       0,   136,     0,   142,     0,     0,     0,     0,   143,     0,
       0,     0,     0,     0,     0,     0,   144,     0,     0,     0,
       0,   139,     0,     0,     0,     0,   140,     0,     0,   145,
     141,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     142,    39,     0,     0,     0,   143,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   145,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    39
};

static const yytype_int16 yycheck[] =
{
       0,     5,     2,   324,    24,     5,    77,     1,     4,    76,
     158,    91,     8,   168,    91,    50,    69,   183,   320,   300,
     301,    25,   101,    23,    24,    25,    22,    27,    28,    88,
      80,   631,     8,    91,   370,    69,    12,   388,   100,    12,
     170,   364,     8,    91,    79,   648,   387,     0,   171,    75,
      50,   851,    67,    29,     6,   303,    91,     8,     9,    58,
      80,    76,    92,    20,    63,    20,    18,    67,    68,    69,
     399,     5,   192,    93,    74,    20,    76,   151,    78,    79,
      80,   383,    86,     0,    83,    69,    86,    91,    22,    34,
       4,    91,    92,    93,    94,    84,    96,    50,   172,   382,
      91,   384,   385,   386,    35,    20,    20,   107,     0,   109,
     522,   111,   112,    20,    67,    68,     5,    22,   718,   197,
     167,    74,    18,    76,   100,    78,    79,     8,   154,    22,
     183,    46,    69,    22,     5,    14,   936,    16,    91,    92,
     318,    94,     5,    96,   133,    69,     6,     0,    55,   183,
     170,    22,    83,   331,   107,     6,   109,    71,   111,   112,
     597,    24,   192,   193,    96,    28,    29,    30,    20,     0,
     170,    20,   972,    22,     6,   171,     4,    94,    47,   155,
     180,   171,    11,   183,    91,    37,   162,     4,   122,    18,
       4,   628,    23,    56,    24,   140,    27,    28,   189,   183,
      96,    29,    94,    20,   382,   171,   384,   207,   199,   200,
     210,   211,   553,   379,    46,    29,   210,   122,     6,    50,
     171,   178,   634,   207,   347,   182,    56,     0,    97,   122,
      23,   163,    20,   122,   189,   190,    67,    68,   193,   194,
     576,    94,   976,    74,    37,    76,   183,    78,    79,     6,
     853,   122,   121,   987,     8,     9,   125,   210,   211,   183,
      91,    92,   591,    94,   178,    96,   242,   163,   182,   242,
      24,   178,   346,   122,     5,   182,   107,   170,   109,   608,
     111,   112,    18,   207,   364,     4,    81,    20,     4,   168,
     171,   192,    28,    24,   195,   631,     8,     9,   627,    81,
     629,    20,    56,   903,    20,    78,     0,   630,   328,     6,
     377,     4,    81,   192,   595,   596,   618,   196,   197,   600,
     320,    94,   185,   186,   187,    56,   379,    20,   328,   364,
     365,     8,     9,     6,   369,   935,   677,     8,   468,   406,
      52,    12,    11,     6,   348,   379,    69,   367,   348,    18,
     350,   347,   372,   601,   602,    78,    50,    11,   349,   350,
     364,   125,   377,    17,   364,   365,     6,   367,   368,   369,
      47,   526,   372,    67,    68,   425,   370,   377,    21,   379,
      74,   347,    76,   383,    78,    79,    11,   446,   423,   544,
     467,   406,    17,   676,   370,   379,    11,    91,    92,   399,
      94,   579,    96,    18,   370,   425,   406,   427,   404,   467,
     477,   364,   365,   107,   137,   109,   369,   111,   112,   467,
     499,    18,   188,   423,   377,   425,   192,   427,   404,   100,
     430,     6,   467,   845,   846,   497,    20,   160,   404,   107,
     440,   109,   379,   111,   112,    28,    29,    30,   468,   449,
     524,   525,    63,   406,   178,   379,   189,   190,   182,   192,
     193,   194,   477,    18,     6,    20,   347,   467,   468,     4,
     423,   518,   519,   520,   521,    49,   467,   477,    20,   479,
     635,    92,   196,   197,   155,    20,   180,     8,     9,   370,
       6,   162,    13,    18,    68,    20,     0,   833,   676,   138,
     547,     8,     9,    24,    46,   505,   430,   507,   147,   509,
      20,   511,   151,    20,   467,   126,   440,   128,   200,   201,
      94,   497,   688,   404,   477,   449,   479,     4,     5,   880,
     832,   872,   528,   364,   365,    56,    11,   513,   369,    29,
     516,     4,     4,    18,   118,    20,   377,    20,    11,    20,
     630,   550,   505,   549,   507,    18,   509,   113,   511,     8,
       9,   117,   528,    67,    68,   618,    29,   903,     8,     9,
      74,    20,    76,    13,    78,   406,   857,   858,   574,     8,
       9,   365,    15,   617,    24,   369,    67,    68,    92,    11,
      94,   591,   423,    74,     6,   630,   879,   597,   589,     6,
     576,     6,   185,   186,   187,   189,   190,     6,   608,   193,
     194,    92,   933,   613,     4,     5,    56,   617,   618,   619,
     620,   621,     4,     5,   779,   780,   630,   627,   628,   629,
     630,     8,     9,   700,   625,   688,   467,   631,     6,   692,
     192,   694,     6,    20,   196,   197,   477,   528,   479,     0,
       4,     5,   830,   687,   688,   631,   350,     6,   692,   658,
     694,     9,   697,     4,     5,   631,   126,   620,   621,     4,
     364,   365,     8,     9,   505,   369,   507,   630,   509,   746,
     511,     4,     5,   377,    20,   700,    20,   687,   688,   689,
     113,   691,   692,   871,   694,   619,   874,   697,     4,    50,
     700,   879,     9,   851,   688,   689,   479,    20,   692,    20,
     694,    20,   406,     0,     6,   719,    67,    68,    20,   719,
       4,     5,    20,    74,   718,    76,    20,    78,    79,   423,
     730,   746,   505,   404,   507,    20,   509,    52,   511,     6,
      91,    92,   718,    94,   697,    96,   746,   700,    11,   745,
     631,   688,     6,   690,     6,   692,   107,   694,   109,    96,
     111,   112,     6,    50,   688,     6,    14,     6,    16,     7,
     107,     6,   109,   467,   111,   112,     0,     6,     4,     5,
      67,    68,    12,   477,    18,   479,    10,    74,   936,    76,
     198,    78,    79,   746,    20,    21,     6,    21,   792,   630,
       4,     5,     8,     9,    91,    92,   730,    94,    20,    96,
       6,   505,   883,   507,    20,   509,   792,   511,   818,     6,
     107,     6,   109,     5,   111,   112,   497,     5,    11,   188,
       8,     9,   832,   192,   818,   811,     6,   196,   197,     6,
     860,     6,   862,    67,    68,   811,    24,    14,    76,    16,
      74,     6,    76,     6,    78,     5,    20,   833,     8,     9,
     860,     6,   862,   863,     6,   113,   697,   833,    92,   700,
      94,     5,    96,   377,     8,     9,   171,    69,    56,     6,
      50,    51,     6,   107,     6,   109,   136,   111,   112,    59,
       4,     5,    20,    85,   189,   190,     5,   192,   193,   194,
       4,    93,   406,   189,   190,    75,   192,   193,   194,   903,
       4,     5,    82,   161,    20,   746,   188,     4,     5,   191,
     192,    19,   194,   195,    20,   197,   961,   903,     4,     5,
     100,    87,   928,     6,   969,    20,   630,   903,   108,    20,
     188,   935,    20,   191,   192,   980,    46,   195,   196,   197,
      20,    49,   189,   190,    50,    51,   193,   194,    20,   935,
      20,   961,     5,    59,   200,     8,     9,   159,     5,   969,
      68,   195,     5,   477,   144,   167,    24,    75,   170,    75,
     980,   160,     5,    11,   154,     8,     9,   179,    20,     5,
       4,   183,     8,     9,   186,     5,    94,     5,     8,     9,
       8,     9,    20,   697,   100,    20,   700,     5,   961,     5,
     180,   199,   108,   364,   365,   207,   969,    11,   369,    18,
     118,    69,   192,    15,    11,   192,   377,   980,    17,   196,
     197,    11,    80,   200,   201,     5,    24,     6,     8,     9,
      28,    29,    30,     5,     5,    93,     8,     9,   144,    24,
       4,     5,   746,    20,   935,   406,   154,     5,   154,   171,
       8,     9,     4,     5,     4,     5,    47,     5,    56,    19,
      51,    52,   423,    54,   171,    56,     5,   364,   365,     4,
       5,    20,   369,    20,   180,    20,    20,    20,     5,    11,
     377,     8,     9,    20,    69,     4,   192,   188,   189,   190,
     191,   192,   193,   194,   195,    80,   197,    24,   201,    20,
      20,    28,    29,    30,    20,    20,   467,    20,    93,   406,
       6,     5,   170,     5,     5,     5,   477,     5,   479,    76,
     961,    29,     6,     5,    11,   183,   423,   118,   969,    56,
      19,     5,   479,   188,     5,     5,   191,   192,    19,   980,
     195,   196,   197,   377,   505,     5,   507,     6,   509,   207,
     511,   353,   171,    20,    19,     5,    20,    19,   505,    20,
     507,   404,   509,   155,   511,   528,   368,   162,   605,   403,
     467,   306,   406,   736,   863,   613,   387,   379,   229,   692,
     477,   980,   479,   694,   425,   170,   700,   185,   186,   187,
     423,   367,    78,   446,   393,   467,   185,   399,   183,     0,
       8,     9,    12,    12,   480,    12,   197,   198,   505,   501,
     507,    -1,   509,    -1,   511,    -1,    24,    -1,    -1,    -1,
      28,    29,    30,    -1,    -1,    -1,   428,   429,    -1,   431,
      -1,    -1,   746,    -1,    -1,   226,   438,   439,   229,    -1,
     474,    -1,    -1,   477,    -1,   479,     6,   449,    56,    -1,
      -1,    -1,    -1,    -1,    14,    -1,    16,   961,   185,   186,
     187,    -1,    -1,    -1,    -1,   969,   468,    -1,    -1,   630,
     328,   505,    -1,   507,    -1,   509,   980,   511,    -1,    -1,
      -1,    -1,   516,    -1,    -1,    60,    -1,    -1,    -1,    49,
      50,    -1,    67,   188,   189,   190,    -1,   192,   193,   194,
     195,    -1,    -1,    -1,    79,    80,   297,    -1,    68,   367,
     368,    -1,    -1,    -1,   372,    -1,   518,   519,   520,   521,
      -1,   379,    -1,   314,    -1,    -1,    -1,    -1,    88,    -1,
      -1,    -1,    -1,   630,    94,    -1,   697,    -1,    -1,   700,
      -1,   399,    -1,   328,    -1,   547,    -1,    -1,    -1,   124,
      -1,    -1,   343,    -1,   129,   130,    -1,    -1,   118,    -1,
     120,   121,    -1,    -1,    14,    -1,    16,   425,   143,   427,
      20,    -1,    -1,    -1,   298,    -1,    -1,   185,   186,   187,
      -1,    -1,   367,   368,    -1,   746,    -1,   372,    -1,   591,
      -1,    -1,    -1,    -1,   379,   597,    -1,   631,    -1,    -1,
     697,   161,    -1,   700,    -1,    -1,   608,    -1,    -1,    -1,
     468,    -1,    62,    -1,   399,   175,   191,   192,    -1,    -1,
      -1,   196,   197,    -1,   184,   627,   628,   629,   188,   189,
     190,    -1,   192,   193,   194,   195,   638,    -1,    -1,    -1,
     425,    -1,   427,    -1,    -1,    -1,   648,    -1,    -1,   746,
      -1,    -1,    -1,    -1,   104,    -1,   380,    -1,    -1,    -1,
      -1,    -1,    -1,   113,    -1,    -1,   700,    -1,    -1,    -1,
      -1,    -1,    -1,   123,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   684,   468,     0,    -1,   688,   689,    -1,    -1,
     692,    -1,   694,   298,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   703,   704,   705,   706,   707,    -1,   157,    -1,   433,
      -1,   161,   746,    14,   164,    16,    -1,    -1,    -1,    -1,
      -1,   512,   724,   514,    -1,    -1,   728,   729,   730,    -1,
      -1,    -1,    -1,   591,    -1,    -1,    -1,    -1,   188,   597,
     464,   191,   192,    -1,    -1,   195,   196,   197,    -1,    -1,
     608,    67,    68,    69,    -1,    -1,    -1,    -1,    74,    -1,
      -1,    62,    78,    -1,    -1,    -1,    -1,    -1,    -1,   627,
     628,   629,    -1,    -1,    -1,   380,    92,    -1,    94,    -1,
      96,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    50,    51,
      -1,   107,   794,   109,   796,   111,   112,    59,    -1,   833,
     961,    -1,    -1,   104,    -1,    -1,   591,    -1,   969,   533,
      -1,    -1,   113,    75,    -1,    -1,   818,    -1,    -1,   980,
      82,    -1,   123,   608,   548,    -1,    -1,    -1,   433,    -1,
     688,   689,    -1,   557,   692,    -1,   694,    -1,   100,    -1,
      -1,    -1,   627,    -1,   629,    -1,   108,   849,    -1,    -1,
     852,   853,    -1,   577,    -1,    -1,   157,    -1,    -1,   464,
     161,   863,    -1,   164,   961,    -1,    -1,   183,    -1,   903,
      -1,    -1,   969,    -1,    -1,    -1,    -1,   668,   669,   670,
     671,    -1,   144,   980,    -1,    -1,    -1,   188,    -1,    -1,
     191,   192,   154,    -1,   195,   196,   197,    -1,    -1,    -1,
      -1,    -1,    -1,   688,    -1,   690,    -1,   692,    -1,   694,
      -1,     6,    -1,    -1,    -1,    -1,    -1,    -1,   180,    14,
      -1,    16,   646,    -1,    -1,    -1,   650,    -1,   533,    -1,
     192,    -1,    -1,    -1,    -1,    21,    -1,    -1,   662,    -1,
      -1,    -1,    -1,   548,    -1,    -1,    -1,    -1,    34,    -1,
      36,   675,   557,    -1,    49,    50,    -1,    -1,    -1,    -1,
     818,    -1,    48,    -1,    -1,    -1,    -1,    -1,   970,    -1,
      -1,    -1,   577,    68,    -1,    -1,    -1,    -1,    64,    -1,
      -1,    -1,   773,    -1,    70,    -1,    -1,   989,   712,   713,
      -1,    -1,   716,    88,    -1,    -1,    -1,   721,   722,    94,
      -1,    -1,   860,    -1,   862,   863,    -1,   731,    -1,    -1,
      -1,    -1,    -1,    99,    -1,    -1,   102,    -1,    -1,   810,
     106,   812,    -1,   118,    -1,   120,   121,    -1,    -1,   115,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   646,    -1,    -1,    -1,   650,    -1,    -1,    -1,   135,
      -1,   842,    -1,    -1,   140,    -1,    -1,   662,    -1,    -1,
      -1,    -1,    -1,   379,    60,    -1,   161,    -1,    -1,    -1,
     675,    67,    -1,   159,    -1,   860,    -1,   862,   863,    -1,
     175,    -1,    -1,    79,    80,    -1,    -1,    -1,    -1,   184,
      -1,    -1,    -1,   188,   189,   190,   820,   192,   193,   194,
     195,    -1,    -1,    -1,    -1,    -1,    -1,   712,   713,    -1,
      -1,   716,    -1,   837,    -1,    -1,   721,   722,    -1,    -1,
      -1,    -1,    -1,    -1,   848,    -1,   731,    -1,   124,    -1,
     854,    -1,    -1,   129,   130,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,     6,   870,   143,    -1,   873,
      -1,    -1,    -1,    14,    -1,    16,    21,    -1,    -1,    -1,
      -1,    -1,    -1,   479,   888,   889,   890,   891,   892,    34,
      -1,    36,    -1,    -1,    -1,    -1,   900,   901,   902,    -1,
      -1,    -1,    -1,    48,    -1,    -1,    -1,    -1,    49,   505,
      -1,   507,    -1,   509,    -1,   511,   192,    58,    -1,    64,
     196,   197,   926,   927,    -1,    70,    -1,    68,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   820,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   948,    -1,    -1,    88,   952,    -1,
      -1,    -1,   837,    94,    99,    -1,    -1,   102,    -1,    -1,
      -1,   106,    -1,   848,    -1,    -1,    -1,    -1,    -1,   854,
     115,    -1,   113,    -1,    -1,    -1,    -1,   118,    -1,   120,
     121,   985,    -1,    -1,    -1,   870,    -1,    -1,   873,   993,
     135,    -1,    -1,    -1,    -1,   140,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   888,   889,   890,   891,   892,    -1,    -1,
      -1,    -1,     0,    -1,   159,   900,   901,   902,    -1,    -1,
     161,    -1,    34,    -1,    36,    -1,    14,    -1,    16,    -1,
      -1,    -1,    20,    -1,   175,    -1,    48,    -1,    -1,    -1,
      -1,   926,   927,    31,    -1,    -1,    -1,   188,    -1,    -1,
     191,   192,    64,    -1,   195,   196,   197,   198,    70,   200,
     201,   202,    -1,   948,    -1,    53,    54,   952,    -1,    -1,
      82,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    69,    -1,    -1,    -1,    -1,    74,    99,    -1,    -1,
     102,    -1,   688,    -1,   106,   691,   692,    85,   694,    -1,
     985,    89,    -1,   115,    92,    93,    -1,    95,   993,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   135,    -1,   113,    -1,    -1,   140,    -1,
      -1,    -1,   120,   121,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   131,   132,    -1,    -1,   159,   136,   137,
     138,   139,    -1,    -1,    34,    -1,    36,   145,   146,   147,
      -1,    -1,    -1,   151,    -1,    -1,    -1,    -1,    48,    -1,
      -1,    -1,   160,   161,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   169,    -1,    -1,    64,    -1,    -1,    -1,    -1,    -1,
      70,   179,    -1,   181,    -1,   183,    -1,    -1,    -1,    -1,
     188,   189,   190,   191,   192,   193,   194,   195,   196,   197,
       6,    -1,     8,     9,    -1,    -1,    -1,    -1,    14,    99,
      16,    -1,   102,    -1,    20,    -1,   106,    -1,    -1,    25,
      26,    27,    -1,    -1,    -1,   115,    32,    33,    -1,    -1,
      -1,    -1,    38,    39,    40,    41,    42,    43,    44,    -1,
      -1,    -1,    -1,    49,    50,   135,    -1,    -1,    -1,    -1,
     140,    57,    58,    59,    60,    -1,    62,    -1,    -1,    65,
      66,    67,    68,    -1,    -1,    -1,    72,    73,    -1,   159,
      -1,    -1,    -1,    79,    80,    -1,    -1,    -1,    -1,    -1,
      86,    -1,    88,    -1,    90,    -1,    92,    -1,    94,    -1,
      -1,    -1,    98,    -1,   100,   101,    -1,   103,   104,   105,
      -1,   107,   108,   109,   110,   111,   112,   113,   114,    -1,
     116,   117,   118,   119,   120,   121,    -1,   123,   124,    -1,
      -1,   127,    -1,   129,   130,    -1,    -1,    -1,   134,    -1,
      -1,    -1,    -1,    -1,    -1,   141,   142,   143,   144,    -1,
      -1,    -1,   148,   149,   150,    -1,   152,   153,    -1,   155,
     156,   157,   158,    -1,    -1,   161,   162,    -1,   164,   165,
     166,    -1,    -1,    -1,    -1,    -1,   172,   173,   174,   175,
     176,   177,    -1,    -1,   180,    -1,    -1,    -1,   184,    -1,
      -1,    -1,   188,   189,   190,   191,   192,   193,   194,   195,
     196,   197,   198,    -1,   200,   201,   202,     6,    -1,     8,
       9,    -1,    -1,    -1,    -1,    14,    -1,    16,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    25,    26,    27,    -1,
      -1,    -1,    -1,    32,    33,    -1,    -1,    -1,    -1,    38,
      39,    40,    41,    42,    43,    44,    -1,    -1,    -1,    -1,
      49,    50,    -1,    -1,    -1,    -1,    -1,    -1,    57,    58,
      59,    60,    -1,    62,    -1,    -1,    65,    66,    67,    68,
      -1,    -1,    -1,    72,    73,    -1,    -1,    -1,    -1,    -1,
      79,    80,    -1,    -1,    -1,    -1,    -1,    86,    -1,    88,
      -1,    90,    -1,    92,    -1,    94,    -1,    -1,    -1,    98,
      -1,   100,   101,    -1,   103,   104,   105,    -1,   107,   108,
     109,   110,   111,   112,   113,   114,    -1,   116,   117,   118,
     119,   120,   121,    -1,   123,   124,    -1,    -1,   127,    -1,
     129,   130,    -1,    -1,    -1,   134,    -1,    -1,    -1,    -1,
      -1,    -1,   141,   142,   143,   144,    -1,    -1,    -1,   148,
     149,   150,    -1,   152,   153,    -1,   155,   156,   157,   158,
      -1,    -1,   161,   162,    -1,   164,   165,   166,    -1,    -1,
      -1,    -1,    -1,   172,   173,   174,   175,   176,   177,    -1,
      -1,   180,    -1,    -1,    -1,   184,    -1,    -1,    -1,   188,
     189,   190,   191,   192,   193,   194,   195,   196,   197,   198,
      -1,   200,   201,   202,     6,    -1,     8,     9,    -1,    -1,
      -1,    -1,    14,    -1,    16,    -1,    -1,    -1,    20,    -1,
      -1,    -1,    -1,    25,    26,    27,    -1,    -1,    -1,    -1,
      32,    33,    -1,    -1,    -1,    -1,    38,    39,    40,    41,
      42,    43,    44,    -1,    -1,    -1,    -1,    49,    50,    -1,
      -1,    -1,    -1,    -1,    -1,    57,    58,    59,    60,    -1,
      -1,    -1,    -1,    65,    66,    67,    68,    -1,    -1,    -1,
      72,    73,    -1,    -1,    -1,    -1,    -1,    79,    80,    -1,
      -1,    -1,    -1,    -1,    86,    -1,    88,    -1,    90,    -1,
      92,    -1,    94,    -1,    -1,    -1,    98,    -1,   100,   101,
      -1,   103,    -1,   105,    -1,   107,   108,   109,   110,   111,
     112,   113,   114,    -1,   116,   117,   118,   119,   120,   121,
      -1,    -1,   124,    -1,    -1,   127,    -1,   129,   130,    -1,
      -1,    -1,   134,    -1,    -1,    -1,    -1,    -1,    -1,   141,
     142,   143,   144,    -1,    -1,    -1,   148,   149,   150,    -1,
     152,   153,    -1,   155,   156,    -1,   158,    -1,    -1,   161,
     162,    -1,    -1,   165,   166,    -1,    -1,    -1,    -1,    -1,
     172,   173,   174,   175,   176,   177,    -1,    -1,   180,    -1,
      -1,    -1,   184,    -1,    -1,    -1,   188,   189,   190,   191,
     192,   193,   194,   195,   196,   197,   198,    -1,   200,   201,
     202,     6,    -1,     8,     9,    10,    -1,    -1,    -1,    14,
      -1,    16,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      25,    26,    27,    -1,    -1,    -1,    -1,    32,    33,    -1,
      -1,    -1,    -1,    38,    39,    40,    41,    42,    43,    44,
      -1,    -1,    -1,    -1,    49,    50,    -1,    -1,    -1,    -1,
      -1,    -1,    57,    58,    59,    60,    -1,    -1,    -1,    -1,
      65,    66,    67,    68,    -1,    -1,    -1,    72,    73,    -1,
      -1,    -1,    -1,    -1,    79,    80,    -1,    -1,    -1,    -1,
      -1,    86,    -1,    88,    -1,    90,    -1,    92,    -1,    94,
      -1,    -1,    -1,    98,    -1,   100,   101,    -1,   103,    -1,
     105,    -1,   107,   108,   109,   110,   111,   112,   113,   114,
      -1,   116,   117,   118,   119,   120,   121,    -1,    -1,   124,
      -1,    -1,   127,    -1,   129,   130,    -1,    -1,    -1,   134,
      -1,    -1,    -1,    -1,    -1,    -1,   141,   142,   143,   144,
      -1,    -1,    -1,   148,   149,   150,    -1,   152,   153,    -1,
     155,   156,    -1,   158,    -1,    -1,   161,   162,    -1,    -1,
     165,   166,    -1,    -1,    -1,    -1,    -1,   172,   173,   174,
     175,   176,   177,    -1,    -1,   180,    -1,    -1,    -1,   184,
      -1,    -1,    -1,   188,   189,   190,   191,   192,   193,   194,
     195,   196,   197,   198,    -1,   200,   201,   202,     6,    -1,
       8,     9,    -1,    -1,    -1,    -1,    14,    -1,    16,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    25,    26,    27,
      -1,    -1,    -1,    -1,    32,    33,    -1,    -1,    -1,    -1,
      38,    39,    40,    41,    42,    43,    44,    -1,    -1,    -1,
      -1,    49,    50,    -1,    -1,    -1,    -1,    -1,    -1,    57,
      58,    59,    60,    -1,    -1,    -1,    -1,    65,    66,    67,
      68,    -1,    -1,    -1,    72,    73,    -1,    -1,    -1,    -1,
      -1,    79,    80,    -1,    -1,    -1,    -1,    -1,    86,    -1,
      88,    89,    90,    -1,    92,    -1,    94,    -1,    -1,    -1,
      98,    -1,   100,   101,    -1,   103,    -1,   105,    -1,   107,
     108,   109,   110,   111,   112,   113,   114,    -1,   116,   117,
     118,   119,   120,   121,    -1,    -1,   124,    -1,    -1,   127,
      -1,   129,   130,    -1,    -1,    -1,   134,    -1,    -1,    -1,
      -1,    -1,    -1,   141,   142,   143,   144,    -1,    -1,    -1,
     148,   149,   150,    -1,   152,   153,    -1,   155,   156,    -1,
     158,    -1,    -1,   161,   162,    -1,    -1,   165,   166,    -1,
      -1,    -1,    -1,    -1,   172,   173,   174,   175,   176,   177,
      -1,    -1,   180,    -1,    -1,    -1,   184,    -1,    -1,    -1,
     188,   189,   190,   191,   192,   193,   194,   195,   196,   197,
     198,    -1,   200,   201,   202,     6,    -1,     8,     9,    -1,
      -1,    -1,    -1,    14,    -1,    16,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    25,    26,    27,    -1,    -1,    -1,
      -1,    32,    33,    -1,    -1,    -1,    -1,    38,    39,    40,
      41,    42,    43,    44,    -1,    -1,    -1,    -1,    49,    50,
      -1,    -1,    -1,    -1,    -1,    -1,    57,    58,    59,    60,
      -1,    -1,    -1,    -1,    65,    66,    67,    68,    -1,    -1,
      -1,    72,    73,    -1,    -1,    -1,    -1,    -1,    79,    80,
      -1,    -1,    -1,    -1,    -1,    86,    -1,    88,    -1,    90,
      -1,    92,    -1,    94,    -1,    -1,    -1,    98,    -1,   100,
     101,    -1,   103,    -1,   105,    -1,   107,   108,   109,   110,
     111,   112,   113,   114,    -1,   116,   117,   118,   119,   120,
     121,    -1,    -1,   124,    -1,    -1,   127,    -1,   129,   130,
      -1,    -1,    -1,   134,    -1,    -1,    -1,    -1,    -1,    -1,
     141,   142,   143,   144,    -1,    -1,    -1,   148,   149,   150,
      -1,   152,   153,    -1,   155,   156,    -1,   158,    -1,    -1,
     161,   162,    -1,    -1,   165,   166,    -1,    -1,    -1,    -1,
      -1,   172,   173,   174,   175,   176,   177,    -1,    -1,   180,
      -1,    -1,    -1,   184,    -1,    -1,    -1,   188,   189,   190,
     191,   192,   193,   194,   195,   196,   197,   198,    -1,   200,
     201,   202,     6,    -1,     8,     9,    -1,    -1,    -1,    -1,
      14,    -1,    16,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    25,    26,    27,    -1,    -1,    -1,    -1,    32,    33,
      -1,    -1,    -1,    -1,    38,    39,    40,    41,    42,    43,
      44,    -1,    -1,    -1,    -1,    49,    50,    -1,    -1,    -1,
      -1,    -1,    -1,    57,    58,    59,    60,    -1,    -1,    -1,
      -1,    65,    66,    67,    68,    -1,    -1,    -1,    72,    73,
      -1,    -1,    -1,    -1,    -1,    79,    80,    -1,    -1,    -1,
      -1,    -1,    86,    -1,    88,    -1,    90,    -1,    92,    -1,
      94,    -1,    -1,    -1,    98,    -1,   100,   101,    -1,   103,
      -1,   105,    -1,   107,   108,   109,   110,   111,   112,   113,
     114,    -1,   116,   117,   118,   119,   120,   121,    -1,    -1,
     124,    -1,    -1,   127,    -1,   129,   130,    -1,    -1,    -1,
     134,    -1,    -1,    -1,    -1,    -1,    -1,   141,   142,   143,
     144,    -1,    -1,    -1,   148,   149,   150,    -1,   152,   153,
      -1,   155,   156,    -1,   158,    -1,    -1,   161,   162,    -1,
      -1,   165,   166,    -1,    -1,    -1,    -1,    -1,   172,   173,
     174,   175,   176,   177,    -1,    -1,   180,    -1,    -1,    -1,
     184,    -1,    -1,    -1,   188,   189,   190,   191,   192,   193,
     194,   195,   196,   197,   198,    -1,   200,   201,   202,     6,
      -1,     8,     9,    -1,    -1,    -1,    -1,    14,    -1,    16,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    25,    26,
      27,    -1,    -1,    -1,    -1,    32,    33,    -1,    -1,    -1,
      -1,    38,    39,    40,    41,    42,    43,    44,    -1,    -1,
      -1,    -1,    49,    50,    -1,    -1,    -1,    -1,    -1,    -1,
      57,    58,    59,    60,    -1,    -1,    -1,    -1,    65,    66,
      67,    68,    -1,    -1,    -1,    72,    73,    -1,    -1,    -1,
      -1,    -1,    79,    80,    -1,    -1,    -1,    -1,    -1,    86,
      -1,    88,    -1,    90,    -1,    -1,    -1,    94,    -1,    -1,
      -1,    98,    -1,   100,   101,    -1,   103,    -1,   105,    -1,
     107,   108,   109,   110,   111,   112,    -1,   114,    -1,   116,
      -1,   118,   119,   120,   121,    -1,    -1,   124,    -1,    -1,
     127,    -1,   129,   130,    -1,    -1,    -1,   134,    -1,    -1,
      -1,    -1,    -1,    -1,   141,   142,   143,   144,    -1,    -1,
      -1,   148,   149,   150,    -1,   152,   153,    -1,   155,   156,
      -1,   158,    -1,    -1,   161,   162,    -1,    -1,   165,   166,
      -1,    -1,    -1,    -1,    -1,   172,   173,   174,   175,   176,
     177,    -1,    -1,   180,    -1,    -1,    -1,   184,    -1,    -1,
      -1,   188,   189,   190,   191,   192,   193,   194,   195,   196,
     197,   198,    -1,   200,   201,   202,     6,    -1,     8,     9,
      -1,    -1,    -1,    -1,    14,    -1,    16,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    25,    26,    27,    -1,    -1,
      -1,    -1,    32,    33,    -1,    -1,    -1,    -1,    38,    39,
      40,    41,    42,    43,    44,    -1,    -1,    -1,    -1,    49,
      50,    -1,    -1,    -1,    -1,    -1,    -1,    57,    -1,    -1,
      60,    -1,    -1,    -1,    -1,    65,    66,    67,    68,    -1,
      -1,    -1,    72,    73,    -1,    -1,    -1,    -1,    -1,    79,
      80,    -1,    -1,    -1,    -1,    -1,    86,    -1,    88,    -1,
      90,    -1,    -1,    -1,    94,    -1,    -1,    -1,    98,    -1,
     100,   101,    -1,   103,    -1,    -1,    -1,   107,   108,   109,
     110,   111,   112,    -1,   114,    -1,   116,    -1,   118,   119,
     120,   121,    -1,    -1,   124,    -1,    -1,   127,    -1,   129,
     130,    -1,    -1,    -1,   134,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   142,   143,   144,    -1,    -1,    -1,   148,   149,
     150,    -1,   152,   153,    -1,   155,   156,    -1,   158,    -1,
      -1,   161,   162,    -1,    -1,   165,   166,    -1,    -1,    -1,
      -1,    -1,   172,   173,    -1,   175,   176,   177,    -1,    -1,
     180,    -1,    -1,    -1,   184,    -1,    -1,    -1,   188,   189,
     190,    -1,   192,   193,   194,   195,   196,   197,    -1,    -1,
     200,   201,   202,     6,    -1,     8,     9,    -1,    -1,    -1,
      -1,    14,    -1,    16,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    32,
      33,    -1,    -1,    -1,    -1,    38,    39,    40,    41,    42,
      43,    44,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    57,    58,    59,    60,    -1,    -1,
      -1,    -1,    65,    66,    67,    -1,    -1,    -1,    -1,    72,
      73,    -1,    -1,    -1,    -1,    -1,    79,    80,    -1,    -1,
      -1,    -1,    -1,    86,    -1,    -1,    -1,    90,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    98,    -1,   100,   101,    -1,
     103,    -1,   105,    -1,   107,   108,   109,   110,   111,   112,
      -1,   114,    -1,    -1,    -1,    -1,   119,    -1,    -1,    -1,
      -1,   124,    -1,    -1,   127,    -1,   129,   130,    -1,    -1,
      -1,   134,    -1,    -1,    -1,    -1,    -1,    -1,   141,   142,
     143,   144,    -1,    -1,    -1,   148,   149,   150,    -1,   152,
     153,    -1,   155,   156,    -1,   158,    -1,    -1,    -1,   162,
      -1,    -1,   165,   166,    -1,    -1,    -1,    -1,    -1,   172,
     173,   174,    -1,   176,   177,    -1,     6,   180,     8,     9,
      -1,    -1,    -1,    -1,    14,    -1,    16,   190,   191,   192,
      -1,   194,    -1,   196,   197,   198,    -1,   200,   201,   202,
      -1,    -1,    32,    33,    -1,    -1,    -1,    -1,    38,    39,
      40,    41,    42,    43,    44,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    57,    -1,    -1,
      60,    -1,    -1,    -1,    -1,    65,    66,    67,    -1,    -1,
      -1,    -1,    72,    73,    -1,    -1,    -1,    -1,    -1,    79,
      80,    -1,    -1,    -1,    -1,    -1,    86,    -1,    -1,    -1,
      90,    91,    -1,    -1,    -1,    -1,    -1,    -1,    98,    -1,
     100,   101,    -1,   103,    -1,    -1,    -1,   107,   108,   109,
     110,   111,   112,    -1,   114,    -1,    -1,    -1,    -1,   119,
      -1,    -1,    -1,    -1,   124,    -1,    -1,   127,    -1,   129,
     130,    -1,    -1,    -1,   134,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   142,   143,   144,    -1,    -1,    -1,   148,   149,
     150,    -1,   152,   153,    -1,   155,   156,    -1,   158,    -1,
      -1,    -1,   162,    -1,    -1,   165,   166,    -1,    -1,    -1,
      -1,    -1,   172,   173,    -1,    -1,   176,   177,   178,     6,
     180,     8,     9,    10,    -1,    -1,    13,    14,    -1,    16,
      -1,    -1,   192,    -1,   194,    -1,   196,   197,    -1,    -1,
     200,   201,   202,    -1,    -1,    32,    33,    -1,    -1,    -1,
      -1,    38,    39,    40,    41,    42,    43,    44,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      57,    -1,    -1,    60,    -1,    -1,    -1,    -1,    65,    66,
      67,    -1,    -1,    -1,    -1,    72,    73,    -1,    -1,    -1,
      -1,    -1,    79,    80,    -1,    -1,    -1,    -1,    -1,    86,
      -1,    -1,    -1,    90,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    98,    -1,   100,   101,    -1,   103,    -1,    -1,    -1,
     107,   108,   109,   110,   111,   112,    -1,   114,    -1,    -1,
      -1,    -1,   119,    -1,    -1,    -1,    -1,   124,    -1,    -1,
     127,    -1,   129,   130,    -1,    -1,    -1,   134,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   142,   143,   144,    -1,    -1,
      -1,   148,   149,   150,    -1,   152,   153,    -1,   155,   156,
      -1,   158,    -1,    -1,    -1,   162,    -1,    -1,   165,   166,
      -1,    -1,    -1,    -1,    -1,   172,   173,    -1,    -1,   176,
     177,    -1,     6,   180,     8,     9,    10,    -1,    -1,    -1,
      14,    -1,    16,    -1,    -1,   192,    -1,   194,    -1,   196,
     197,    -1,    -1,   200,   201,   202,    -1,    -1,    32,    33,
      -1,    -1,    -1,    -1,    38,    39,    40,    41,    42,    43,
      44,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    57,    -1,    -1,    60,    -1,    -1,    -1,
      -1,    65,    66,    67,    -1,    -1,    -1,    -1,    72,    73,
      -1,    -1,    -1,    -1,    -1,    79,    80,    -1,    -1,    -1,
      -1,    -1,    86,    -1,    -1,    -1,    90,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    98,    -1,   100,   101,    -1,   103,
      -1,    -1,    -1,   107,   108,   109,   110,   111,   112,    -1,
     114,    -1,    -1,    -1,    -1,   119,    -1,    -1,    -1,    -1,
     124,    -1,    -1,   127,    -1,   129,   130,    -1,    -1,    -1,
     134,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   142,   143,
     144,    -1,    -1,    -1,   148,   149,   150,    -1,   152,   153,
      -1,   155,   156,    -1,   158,    -1,    -1,    -1,   162,    -1,
      -1,   165,   166,    -1,    -1,    -1,    -1,    -1,   172,   173,
      -1,    -1,   176,   177,    -1,     6,   180,     8,     9,    -1,
      -1,    -1,    13,    14,    -1,    16,    -1,    -1,   192,    -1,
     194,    -1,   196,   197,    -1,    -1,   200,   201,   202,    -1,
      -1,    32,    33,    -1,    -1,    -1,    -1,    38,    39,    40,
      41,    42,    43,    44,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    57,    -1,    -1,    60,
      -1,    -1,    -1,    -1,    65,    66,    67,    -1,    -1,    -1,
      -1,    72,    73,    -1,    -1,    -1,    -1,    -1,    79,    80,
      -1,    -1,    -1,    -1,    -1,    86,    -1,    -1,    -1,    90,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    98,    -1,   100,
     101,    -1,   103,    -1,    -1,    -1,   107,   108,   109,   110,
     111,   112,    -1,   114,    -1,    -1,    -1,    -1,   119,    -1,
      -1,    -1,    -1,   124,    -1,    -1,   127,    -1,   129,   130,
      -1,    -1,    -1,   134,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   142,   143,   144,    -1,    -1,    -1,   148,   149,   150,
      -1,   152,   153,    -1,   155,   156,    -1,   158,    -1,    -1,
      -1,   162,    -1,    -1,   165,   166,    -1,    -1,    -1,    -1,
      -1,   172,   173,    -1,    -1,   176,   177,    -1,     6,   180,
       8,     9,    -1,    -1,    -1,    -1,    14,    -1,    16,    -1,
      -1,   192,    -1,   194,    -1,   196,   197,    -1,    -1,   200,
     201,   202,    -1,    -1,    32,    33,    -1,    -1,    -1,    -1,
      38,    39,    40,    41,    42,    43,    44,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    57,
      -1,    -1,    60,    -1,    -1,    -1,    -1,    65,    66,    67,
      -1,    -1,    -1,    -1,    72,    73,    -1,    -1,    -1,    -1,
      -1,    79,    80,    -1,    -1,    -1,    -1,    -1,    86,    -1,
      -1,    -1,    90,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      98,    -1,   100,   101,    -1,   103,    -1,    -1,    -1,   107,
     108,   109,   110,   111,   112,    -1,   114,    -1,    -1,    -1,
      -1,   119,    -1,    -1,    -1,    -1,   124,    -1,    -1,   127,
      -1,   129,   130,    -1,    -1,    -1,   134,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   142,   143,   144,    -1,    -1,    -1,
     148,   149,   150,    -1,   152,   153,    -1,   155,   156,    -1,
     158,    -1,    -1,    -1,   162,    -1,    -1,   165,   166,    -1,
      -1,    -1,    -1,    -1,   172,   173,    -1,    -1,   176,   177,
       6,    -1,   180,    -1,    10,    11,    -1,    -1,    14,    -1,
      16,    -1,    -1,    -1,   192,    -1,   194,    -1,   196,   197,
      -1,    -1,   200,   201,   202,    -1,    32,    33,    -1,    -1,
      -1,    -1,    38,    39,    40,    41,    42,    43,    44,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    57,    -1,    -1,    60,    -1,    -1,    -1,    -1,    65,
      66,    67,    -1,    -1,    -1,    -1,    72,    73,    -1,    -1,
      -1,    -1,    -1,    79,    80,    -1,    -1,    -1,    -1,    -1,
      86,    -1,    -1,    -1,    90,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    98,    -1,   100,   101,    -1,   103,    -1,    -1,
      -1,   107,   108,   109,   110,   111,   112,    -1,   114,    -1,
      -1,    -1,    -1,   119,    -1,    -1,    -1,    -1,   124,    -1,
      -1,   127,    -1,   129,   130,    -1,    -1,    -1,   134,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   142,   143,   144,    -1,
      -1,    -1,   148,   149,   150,    -1,   152,   153,    -1,   155,
     156,    -1,   158,    -1,    -1,    -1,   162,    -1,    -1,   165,
     166,    -1,    -1,    -1,    -1,    -1,   172,   173,    -1,    -1,
     176,   177,     6,    -1,   180,    -1,    -1,    -1,    -1,    -1,
      14,    -1,    16,    -1,    -1,    -1,   192,    -1,   194,    -1,
     196,   197,    -1,    -1,   200,   201,   202,    -1,    32,    33,
      -1,    -1,    -1,    -1,    38,    39,    40,    41,    42,    43,
      44,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    57,    -1,    -1,    60,    -1,    -1,    -1,
      -1,    65,    66,    67,    -1,    -1,    -1,    -1,    72,    73,
      -1,    -1,    -1,    -1,    -1,    79,    80,    -1,    -1,    -1,
      -1,    -1,    86,    -1,    -1,    -1,    90,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    98,    -1,   100,   101,    -1,   103,
      -1,    -1,    -1,   107,   108,   109,   110,   111,   112,    -1,
     114,    -1,    -1,    -1,    -1,   119,    -1,    -1,    -1,    -1,
     124,    -1,    -1,   127,    -1,   129,   130,    -1,    -1,    -1,
     134,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   142,   143,
     144,    14,    -1,    16,   148,   149,   150,    -1,   152,   153,
      -1,   155,   156,    -1,   158,    -1,    -1,    -1,   162,    -1,
      -1,   165,   166,    -1,    -1,    -1,    -1,    -1,   172,   173,
      -1,    -1,   176,   177,    -1,    -1,   180,    -1,    -1,    -1,
      -1,     6,    -1,    -1,    -1,    -1,    -1,    60,   192,    14,
     194,    16,   196,   197,    67,    -1,   200,   201,   202,    -1,
      25,    26,    27,    -1,    -1,    -1,    79,    80,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,     6,    -1,
      -1,    -1,    -1,    -1,    49,    50,    14,    -1,    16,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    25,    26,    27,
     113,    -1,    -1,    68,   117,    -1,    71,    -1,    -1,    -1,
      -1,   124,    -1,    -1,    -1,    -1,   129,   130,    -1,    -1,
      -1,    49,    50,    88,    -1,    -1,    -1,    -1,    -1,    94,
     143,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      68,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   161,    -1,
      -1,   116,    -1,   118,    -1,   120,   121,    -1,    -1,    -1,
      88,    -1,    -1,    -1,    -1,    -1,    94,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   188,   189,   190,   191,   192,
     193,   194,   195,   196,   197,    -1,    -1,    -1,   116,    -1,
     118,    -1,   120,   121,    -1,    -1,   161,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    14,    -1,    16,    -1,    -1,    -1,
     175,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   184,
      -1,    -1,    -1,   188,   189,   190,    -1,   192,   193,   194,
     195,    -1,    -1,   161,    -1,    -1,    -1,    -1,    -1,    49,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   175,    58,    -1,
      60,    -1,    -1,    -1,    -1,    -1,   184,    67,    68,    -1,
     188,   189,   190,    -1,   192,   193,   194,   195,    -1,    79,
      80,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    88,    -1,
      -1,    -1,    -1,    -1,    94,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   113,    -1,    -1,    -1,    -1,   118,    -1,
     120,   121,    -1,    -1,   124,    -1,    -1,    -1,    -1,   129,
     130,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   143,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   161,    -1,    -1,    14,    -1,    16,    -1,    -1,    -1,
      20,    -1,    -1,    -1,    -1,   175,    -1,    -1,    -1,    -1,
      -1,    31,    -1,    -1,    -1,    -1,    -1,    -1,   188,   189,
     190,   191,   192,   193,   194,   195,   196,   197,   198,    -1,
     200,   201,   202,    53,    54,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    64,    -1,    -1,    -1,    -1,    69,
      -1,    -1,    -1,    -1,    74,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    85,    -1,    -1,    -1,    89,
      -1,    -1,    92,    93,    -1,    95,    -1,    -1,    -1,    99,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   113,    -1,    -1,    -1,    -1,    -1,    -1,
     120,   121,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   131,   132,    -1,    -1,    -1,   136,   137,   138,   139,
      -1,    -1,    -1,    -1,    -1,   145,   146,   147,    -1,    -1,
      -1,   151,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     160,   161,    -1,    -1,    -1,    14,    -1,    16,    -1,   169,
      -1,    20,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   179,
      -1,   181,    31,   183,    -1,    -1,    -1,    -1,   188,   189,
     190,   191,   192,   193,   194,   195,   196,   197,    -1,    -1,
      -1,    -1,    -1,    -1,    53,    54,    -1,    -1,    -1,    -1,
      -1,    -1,    61,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      69,    -1,    -1,    -1,    -1,    74,    -1,    -1,    -1,    78,
      60,    -1,    -1,    -1,    -1,    -1,    85,    67,    -1,    -1,
      89,    -1,    -1,    92,    93,    -1,    95,    -1,    -1,    79,
      80,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   113,    -1,    -1,    -1,    -1,    -1,
      -1,   120,   121,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   131,   132,    -1,    -1,    -1,   136,   137,   138,
     139,    -1,    -1,    -1,   124,    -1,   145,   146,   147,   129,
     130,    -1,   151,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   160,   161,   143,    -1,    -1,    14,    -1,    16,    -1,
     169,    -1,    20,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     179,    -1,   181,    31,   183,    -1,    -1,    -1,    -1,   188,
     189,   190,   191,   192,   193,   194,   195,   196,   197,    -1,
      -1,    -1,    -1,    -1,    -1,    53,    54,    -1,   188,   189,
     190,   191,   192,   193,   194,   195,   196,   197,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    74,    -1,    -1,    77,
      -1,    -1,    60,    -1,    -1,    -1,    -1,    85,    -1,    67,
      -1,    89,    -1,    -1,    92,    93,    -1,    95,    -1,    -1,
      -1,    79,    80,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   113,    -1,    -1,    -1,    -1,
      -1,    -1,   120,   121,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   131,   132,    -1,    -1,    -1,   136,    -1,
     138,   139,    -1,    -1,    -1,    -1,   124,   145,   146,   147,
      -1,   129,   130,   151,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    14,   161,    16,   143,    -1,    -1,    20,    -1,
     168,   169,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    31,
      -1,   179,    -1,   181,    -1,   183,    -1,    -1,    -1,    -1,
     188,   189,   190,   191,   192,   193,   194,   195,   196,   197,
      -1,    53,    54,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     188,   189,   190,    -1,   192,   193,   194,   195,   196,   197,
      -1,    -1,    74,    -1,    -1,    77,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    85,    -1,    87,    -1,    89,    -1,    -1,
      -1,    93,    -1,    95,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   113,    -1,    -1,    -1,    -1,    -1,    -1,   120,   121,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   131,
     132,    -1,    -1,    -1,   136,    -1,   138,   139,    -1,    -1,
      -1,    -1,    -1,   145,   146,   147,    -1,    -1,    -1,   151,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    14,   161,
      16,    -1,    -1,    -1,    20,   167,    -1,   169,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    31,    -1,   179,    -1,   181,
      -1,   183,    -1,    -1,    -1,    -1,   188,   189,   190,   191,
     192,   193,   194,   195,   196,   197,    -1,    53,    54,    -1,
      -1,    -1,    -1,    -1,    -1,    61,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    74,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    85,
      -1,    87,    -1,    89,    -1,    -1,    -1,    93,    -1,    95,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   113,    -1,    -1,
      -1,    -1,    -1,    -1,   120,   121,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   131,   132,    -1,    -1,    -1,
     136,    -1,   138,   139,    -1,    -1,    -1,    -1,    -1,   145,
     146,   147,    -1,    -1,    -1,   151,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    14,   161,    16,    -1,    -1,    -1,
      20,   167,    -1,   169,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    31,    -1,   179,    -1,   181,    -1,   183,    -1,    -1,
      -1,    -1,   188,   189,   190,   191,   192,   193,   194,   195,
     196,   197,    -1,    53,    54,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    74,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    85,    -1,    87,    -1,    89,
      -1,    -1,    -1,    93,    -1,    95,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   113,    -1,    -1,    -1,    -1,    -1,    -1,
     120,   121,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   131,   132,    -1,    -1,    -1,   136,    -1,   138,   139,
      -1,    -1,    -1,    -1,    -1,   145,   146,   147,    -1,    -1,
      -1,   151,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      14,   161,    16,    -1,    -1,    -1,    20,   167,    -1,   169,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    31,    -1,   179,
      -1,   181,    -1,   183,    -1,    -1,    -1,    -1,   188,   189,
     190,   191,   192,   193,   194,   195,   196,   197,    -1,    53,
      54,    -1,    -1,    -1,    -1,    -1,    -1,    61,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      74,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    85,    -1,    -1,    -1,    89,    -1,    -1,    92,    93,
      -1,    95,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   113,
      -1,    -1,    -1,    -1,    -1,    -1,   120,   121,    -1,    -1,
      -1,    -1,    -1,    14,    -1,    16,    -1,   131,   132,    20,
      -1,    -1,   136,    -1,   138,   139,    -1,    -1,    -1,    -1,
      31,   145,   146,   147,    -1,    -1,    -1,   151,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   161,    -1,    -1,
      -1,    -1,    53,    54,    -1,   169,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   179,    -1,   181,    -1,   183,
      -1,    -1,    -1,    74,   188,   189,   190,   191,   192,   193,
     194,   195,   196,   197,    85,    -1,    -1,    -1,    89,    -1,
      -1,    92,    93,    -1,    95,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   113,    -1,    -1,    -1,    -1,    -1,    -1,   120,
     121,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     131,   132,    -1,    -1,    -1,   136,    -1,   138,   139,    -1,
      -1,    -1,    -1,    -1,   145,   146,   147,    -1,    -1,    -1,
     151,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    14,
     161,    16,    -1,    -1,    -1,    20,    -1,    -1,   169,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    31,    -1,   179,    -1,
     181,    -1,   183,    -1,    -1,    -1,    -1,   188,   189,   190,
     191,   192,   193,   194,   195,   196,   197,    -1,    53,    54,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    74,
      -1,    -1,    77,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      85,    -1,    -1,    -1,    89,    -1,    -1,    -1,    93,    -1,
      95,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   113,    -1,
      -1,    -1,    -1,    -1,    -1,   120,   121,    -1,    -1,    -1,
      -1,    -1,    14,    -1,    16,    -1,   131,   132,    20,    -1,
      -1,   136,    -1,   138,   139,    -1,    -1,    -1,    -1,    31,
     145,   146,   147,    -1,    -1,    -1,   151,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   161,    -1,    -1,    -1,
      -1,    53,    54,    -1,   169,    -1,    -1,    -1,    -1,    61,
      -1,    -1,    -1,    -1,   179,    -1,   181,    -1,   183,    -1,
      -1,    -1,    74,   188,   189,   190,   191,   192,   193,   194,
     195,   196,   197,    85,    -1,    -1,    -1,    89,    -1,    -1,
      -1,    93,    -1,    95,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   113,    -1,    -1,    -1,    -1,    -1,    -1,   120,   121,
      -1,    -1,    -1,    -1,    -1,    14,    -1,    16,    -1,   131,
     132,    20,    -1,    -1,   136,    -1,   138,   139,    -1,    -1,
      -1,    -1,    31,   145,   146,   147,    -1,    -1,    -1,   151,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   161,
      -1,    -1,    -1,    -1,    53,    54,    -1,   169,    14,    -1,
      16,    -1,    -1,    -1,    -1,    -1,    -1,   179,    -1,   181,
      -1,   183,    -1,    -1,    -1,    74,   188,   189,   190,   191,
     192,   193,   194,   195,   196,   197,    85,    -1,    -1,    -1,
      89,    -1,    -1,    -1,    93,    -1,    95,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    60,    -1,    -1,    -1,    -1,    -1,
      -1,    67,    -1,    -1,   113,    -1,    -1,    -1,    -1,    -1,
      -1,   120,   121,    79,    80,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   131,   132,    -1,    -1,    -1,   136,    -1,   138,
     139,    -1,    -1,    -1,    -1,    -1,   145,   146,   147,    -1,
      -1,    -1,   151,    -1,    -1,    -1,    -1,   113,    -1,    -1,
      -1,    -1,   161,    -1,    -1,    -1,    -1,    -1,   124,    -1,
     169,    -1,    -1,   129,   130,    -1,    -1,    -1,    -1,    -1,
     179,    -1,   181,    -1,   183,    -1,    -1,   143,    -1,   188,
     189,   190,   191,   192,   193,   194,   195,   196,   197,    -1,
      -1,    -1,    -1,    -1,    -1,   161,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   188,   189,   190,   191,   192,   193,   194,   195,
     196,   197,    34,    -1,    36,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    45,    -1,    -1,    48,    -1,    50,    51,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    59,    -1,    -1,
      -1,    -1,    64,    -1,    -1,    -1,    -1,    -1,    70,    -1,
      -1,    -1,    -1,    75,    -1,    -1,    -1,    -1,    -1,    -1,
      82,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      92,    -1,    -1,    -1,    -1,    -1,    -1,    99,   100,    -1,
     102,    -1,    -1,    -1,   106,    -1,   108,    -1,    -1,    -1,
      -1,    -1,    -1,   115,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   126,    -1,   128,    -1,    -1,    -1,
      -1,    -1,    -1,   135,    -1,    -1,    -1,    -1,   140,    -1,
      -1,    -1,   144,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   154,    -1,    -1,    -1,    -1,   159,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   167,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   180,    -1,
      -1,    -1,    -1,    34,    -1,    36,   188,   189,   190,   191,
     192,   193,   194,   195,    45,   197,    -1,    48,    -1,    50,
      51,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    59,    -1,
      -1,    -1,    -1,    64,    -1,    -1,    -1,    -1,    -1,    70,
      34,    -1,    36,    -1,    75,    -1,    -1,    -1,    -1,    -1,
      -1,    82,    -1,    -1,    48,    -1,    50,    51,    -1,    -1,
      -1,    92,    -1,    -1,    -1,    59,    -1,    -1,    99,   100,
      64,   102,    -1,    -1,    -1,   106,    70,   108,    -1,    -1,
      -1,    75,    -1,    -1,   115,    -1,    -1,    -1,    82,    -1,
      -1,    -1,    -1,    -1,    -1,   126,    -1,   128,    -1,    -1,
      -1,    -1,    -1,    -1,   135,    99,   100,    -1,   102,   140,
      -1,    -1,   106,   144,   108,    -1,    -1,    -1,    -1,    -1,
      -1,   115,    -1,   154,    -1,    -1,    -1,    -1,   159,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   167,    -1,    -1,    -1,
      -1,   135,    -1,    -1,    -1,    -1,   140,    -1,    -1,   180,
     144,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     154,   192,    -1,    -1,    -1,   159,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   180,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   192
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int16 yystos[] =
{
       0,    14,    16,    20,    31,    53,    54,    64,    69,    74,
      85,    89,    92,    93,    95,    99,   113,   120,   121,   131,
     132,   136,   137,   138,   139,   145,   146,   147,   151,   160,
     161,   169,   179,   181,   183,   188,   189,   190,   191,   192,
     193,   194,   195,   196,   197,   209,   223,   234,   256,   258,
     263,   264,   266,   267,   269,   275,   278,   280,   282,   283,
     284,   285,   286,   287,   288,   289,   291,   292,   293,   294,
     301,   302,   303,   304,   305,   306,   307,   308,   311,   313,
     314,   315,   316,   319,   320,   322,   323,   325,   326,   331,
     332,   333,   335,   347,   361,   362,   363,   364,   365,   366,
     369,   370,   378,   381,   384,   387,   388,   389,   390,   391,
     392,   393,   394,   234,   287,   209,   193,   257,   267,   287,
       6,    34,    36,    45,    48,    50,    51,    59,    70,    75,
      82,    92,   100,   102,   106,   108,   115,   126,   128,   135,
     140,   144,   154,   159,   167,   180,   189,   190,   192,   193,
     194,   195,   204,   205,   206,   207,   208,   209,   210,   211,
     212,   213,   214,   240,   266,   278,   288,   344,   345,   346,
     347,   351,   353,   354,   355,   356,   358,   360,    20,    55,
      91,   178,   182,   336,   337,   338,   341,    20,   267,     6,
      20,   354,   355,   356,   360,   171,     6,    81,    81,     6,
       6,    20,   267,   209,   382,   258,   287,     6,     8,     9,
      14,    16,    20,    25,    26,    27,    32,    33,    38,    39,
      40,    41,    42,    43,    44,    49,    50,    57,    58,    59,
      60,    65,    66,    67,    68,    72,    73,    79,    80,    86,
      88,    90,    92,    94,    98,   100,   101,   103,   105,   107,
     108,   109,   110,   111,   112,   114,   116,   117,   118,   119,
     120,   121,   124,   127,   129,   130,   134,   141,   142,   143,
     144,   148,   149,   150,   152,   153,   155,   156,   158,   162,
     165,   166,   172,   173,   174,   175,   176,   177,   180,   184,
     189,   190,   194,   198,   200,   201,   202,   212,   215,   216,
     217,   218,   219,   220,   222,   223,   224,   225,   226,   227,
     228,   229,   230,   233,   235,   236,   247,   248,   249,   253,
     255,   256,   257,   258,   259,   260,   261,   262,   263,   265,
     268,   272,   273,   274,   275,   276,   277,   279,   280,   283,
     285,   287,   257,    81,   258,   258,   288,   385,   125,     6,
      18,   237,   238,   241,   242,   282,   285,   287,     6,   237,
     237,    21,   237,   237,     6,     4,    29,   290,     6,     4,
      11,   237,   290,    20,   179,   301,   302,   307,   301,     6,
     215,   247,   249,   255,   272,   279,   283,   296,   297,   298,
     299,   301,    20,    37,    87,   167,   179,   302,   303,     6,
      20,    46,   309,    77,   168,   304,   307,   312,   342,    20,
      62,   104,   123,   157,   164,   282,   317,   321,    20,   192,
     233,   318,   321,     4,    20,     4,    20,   290,     4,     6,
      91,   178,   194,   215,   287,    20,   257,   324,    47,    97,
     121,   125,     4,    20,    71,   327,   328,   329,   330,   336,
      20,     6,    20,   225,   227,   229,   257,   260,   276,   281,
     282,   334,   343,   301,   215,   233,   348,   349,   350,     0,
     304,   378,   381,   384,    61,    78,   304,   307,   367,   368,
     373,   374,   378,   381,   384,    20,    34,   140,    84,   133,
      63,    92,   126,   128,     6,   353,   371,   376,   377,   309,
     372,   376,   379,    20,   367,   368,   367,   368,   367,   368,
     367,   368,    15,    11,    17,   237,    11,     6,     6,     6,
       6,     6,     6,     6,   126,    82,   345,    20,     4,   208,
     113,   240,    10,   215,   352,     4,   205,   352,   346,    10,
     233,   348,   192,   206,   345,     9,   357,   359,   215,   168,
     223,   287,   247,   296,    20,    20,   337,   215,   339,    20,
     225,    20,    20,    20,    20,   267,    20,   237,    96,   163,
     237,   225,   225,    20,     6,    52,    11,   215,   247,   272,
     287,   256,   287,   256,   287,    28,   237,   270,   271,     6,
     270,     6,   237,    24,    56,   217,   218,   254,   216,   216,
       7,    10,    11,   219,    12,   221,    18,   238,     6,    20,
     237,    22,   122,   250,   251,    23,    37,   252,   254,     6,
      14,    16,   253,   287,   262,     6,   233,     6,   254,     6,
       6,    11,    20,   237,    21,   345,   206,   386,   171,   257,
     225,     6,   223,   225,    10,    13,   215,   243,   244,   245,
     246,     4,     5,    20,    21,     5,     6,   281,   282,   289,
     233,   319,   215,   231,   232,   233,   287,   289,   234,   266,
     269,   278,   288,   233,    76,   215,   272,   296,    28,    30,
     185,   186,   187,   290,   300,   170,   295,   300,     6,   300,
     300,   300,   250,   295,   252,   331,   231,     6,   267,   204,
     307,   312,    20,     6,     6,     6,     6,     6,   317,   318,
     233,   287,   215,   215,    71,   247,   215,    20,    11,     4,
      20,   215,   215,   247,     6,   136,    20,   330,    35,    83,
       6,   215,   247,   287,     4,     5,    13,     5,     4,     6,
     282,   343,   348,    20,   267,    87,   307,   367,    20,   304,
     367,   374,    20,   353,   188,   191,   192,   194,   195,   197,
     375,   376,   379,    20,   367,    20,   367,    20,   367,    20,
     367,   237,   237,   267,   352,   352,   352,   352,   226,   345,
     345,   213,     5,     4,     5,     5,     5,   160,   352,    20,
     209,   290,    11,    20,   171,   340,     4,    20,    20,    96,
     163,     5,     5,   209,   383,   199,   380,     5,     5,     5,
      15,    11,    17,    18,   225,   231,   216,   216,     6,   190,
     215,   273,   287,   216,   219,   219,   220,     6,   231,   248,
     249,   253,   255,    11,   225,     5,   231,   215,   273,   231,
     117,   281,   235,    20,   226,    21,     4,    20,   215,   171,
       5,    19,   239,    47,   215,   245,   171,   217,   218,     5,
     290,    20,    13,     4,     5,   237,   237,   237,   237,     5,
     215,   249,   296,   215,   272,   279,   193,   283,   287,   249,
     297,   298,    20,     5,   282,   287,   310,    20,   215,   215,
     215,   215,   215,    20,    20,     5,    20,    20,    20,   257,
     215,   215,   215,    11,    20,   228,     4,     5,   209,    20,
       4,     5,    20,    20,    20,    20,   237,     5,     5,     5,
       4,     5,     6,     5,    76,    29,   215,   215,     4,     5,
     237,   237,     6,     5,     5,    11,    19,     5,   253,     5,
       5,     5,     5,     5,   237,   226,   226,    20,   215,    19,
     240,   261,   215,   245,   216,   216,   233,   232,     5,    20,
     309,     4,     5,     5,     5,     5,     5,     5,     5,   171,
      52,   209,    19,   262,   240,    20,     4,     5,     5,     5,
       6,   282,   287,    20,   282,   215,   261,     4,    19,   239,
     310,    20,     5,   215,     5,     5,    20
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int16 yyr1[] =
{
       0,   203,   204,   204,   205,   205,   205,   206,   206,   206,
     206,   206,   206,   206,   206,   207,   207,   207,   207,   207,
     208,   208,   208,   209,   210,   210,   211,   211,   212,   212,
     212,   212,   213,   213,   214,   214,   214,   214,   214,   214,
     214,   214,   215,   215,   215,   215,   215,   216,   216,   217,
     218,   219,   219,   219,   219,   220,   220,   221,   222,   222,
     222,   222,   223,   223,   223,   223,   223,   223,   223,   223,
     224,   224,   224,   224,   224,   225,   225,   226,   227,   228,
     229,   229,   229,   229,   230,   230,   231,   231,   232,   232,
     232,   233,   233,   233,   233,   233,   234,   234,   235,   235,
     235,   235,   235,   235,   235,   235,   236,   236,   236,   236,
     236,   236,   236,   236,   236,   236,   236,   236,   236,   236,
     236,   236,   236,   236,   236,   236,   236,   236,   236,   236,
     236,   236,   236,   236,   236,   236,   236,   236,   236,   236,
     236,   236,   236,   236,   236,   236,   236,   236,   236,   236,
     236,   236,   236,   237,   237,   237,   237,   238,   238,   238,
     238,   239,   239,   240,   240,   241,   241,   241,   241,   241,
     242,   242,   243,   243,   243,   243,   244,   245,   245,   246,
     246,   246,   247,   247,   248,   248,   249,   249,   249,   249,
     250,   250,   251,   252,   252,   253,   253,   253,   253,   253,
     253,   253,   253,   253,   253,   253,   254,   254,   255,   255,
     255,   255,   256,   256,   256,   256,   257,   257,   257,   257,
     258,   258,   258,   258,   259,   259,   260,   260,   260,   260,
     260,   261,   261,   261,   261,   262,   263,   263,   264,   265,
     265,   265,   266,   267,   267,   267,   267,   268,   268,   269,
     270,   270,   271,   272,   272,   272,   272,   272,   273,   273,
     273,   273,   274,   274,   275,   275,   275,   275,   276,   276,
     277,   277,   277,   277,   277,   278,   279,   279,   279,   280,
     281,   281,   281,   282,   282,   282,   282,   282,   282,   282,
     283,   283,   283,   283,   284,   285,   286,   287,   287,   288,
     289,   289,   289,   289,   290,   291,   291,   292,   292,   293,
     294,   295,   296,   296,   297,   297,   298,   298,   298,   299,
     299,   299,   299,   299,   300,   300,   300,   300,   300,   300,
     301,   301,   301,   302,   302,   302,   302,   302,   302,   302,
     302,   302,   302,   302,   302,   302,   302,   302,   302,   302,
     302,   302,   302,   302,   302,   302,   302,   302,   302,   302,
     302,   302,   302,   302,   302,   302,   302,   302,   302,   302,
     302,   302,   302,   302,   303,   303,   303,   304,   304,   305,
     305,   306,   306,   306,   306,   307,   308,   309,   310,   310,
     310,   310,   311,   311,   311,   311,   311,   311,   311,   311,
     312,   312,   312,   313,   313,   314,   315,   315,   316,   316,
     317,   317,   318,   318,   318,   319,   320,   321,   321,   321,
     321,   321,   322,   323,   323,   324,   324,   325,   325,   325,
     325,   326,   326,   326,   327,   327,   327,   328,   328,   328,
     329,   330,   330,   331,   331,   331,   332,   333,   333,   334,
     334,   335,   336,   336,   337,   337,   338,   338,   339,   339,
     340,   340,   341,   341,   342,   343,   343,   343,   343,   344,
     344,   345,   345,   346,   346,   346,   346,   346,   346,   346,
     346,   346,   346,   346,   346,   347,   347,   347,   348,   348,
     348,   348,   348,   349,   350,   350,   351,   352,   352,   353,
     353,   353,   353,   353,   354,   354,   355,   356,   357,   357,
     358,   359,   360,   360,   360,   361,   361,   361,   361,   361,
     361,   361,   361,   361,   362,   362,   363,   364,   364,   364,
     364,   364,   365,   365,   365,   365,   365,   365,   365,   365,
     365,   366,   366,   367,   367,   367,   368,   368,   368,   369,
     370,   371,   371,   371,   372,   372,   372,   373,   373,   374,
     374,   374,   374,   375,   375,   375,   375,   375,   375,   376,
     377,   377,   378,   379,   380,   381,   382,   382,   383,   383,
     384,   385,   385,   385,   386,   387,   387,   387,   387,   388,
     388,   389,   389,   390,   390,   391,   392,   392,   393,   394
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
       1,     1,     1,     2,     1,     2,     2,     5,     5,     8,
       5,     1,     2,     1,     1,     2,     5,     2,     2,     2,
       1,     2,     1,     1,     2,     3,     2,     1,     1,     1,
       3,     3,     1,     3,     1,     3,     1,     3,     2,     4,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     3,
       3,     4,     3,     4,     3,     4,     1,     1,     1,     1,
       1,     1,     1,     2,     3,     4,     1,     2,     3,     4,
       1,     2,     3,     4,     1,     4,     2,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     2,     3,     1,     1,
       1,     2,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     6,     1,     3,     3,     3,     3,     1,     1,
       4,     3,     1,     2,     1,     2,     3,     4,     1,     5,
       1,     1,     1,     1,     1,     1,     4,     1,     4,     1,
       1,     1,     1,     1,     1,     3,     1,     4,     1,     1,
       1,     4,     3,     4,     1,     2,     1,     1,     3,     1,
       3,     3,     3,     3,     1,     2,     2,     3,     3,     3,
       1,     1,     1,     3,     1,     3,     3,     4,     1,     3,
       3,     3,     3,     3,     1,     1,     1,     1,     1,     1,
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
       2,     2,     3,     3,     3,     4,     2,     2,     2,     1,
       2,     2,     2,     2,     2,     2,     1,     1,     2,     1,
       2,     1,     2,     1,     2,     2,     1,     1,     2,     2,
       2,     1,     1,     2,     1,     1,     2,     1,     2,     1,
       2,     1,     6,     1,     1,     1,     1,     1,     1,     3,
       1,     3,     3,     2,     1,     4,     1,     4,     1,     3,
       3,     3,     4,     4,     2,     1,     1,     1,     1,     3,
       4,     3,     2,     3,     4,     3,     3,     4,     3,     3
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
#line 648 "HAL_S.y"
                                { (yyval.declare_body_) = make_AAdeclareBody_declarationList((yyvsp[0].declaration_list_)); (yyval.declare_body_)->line_number = (yyloc).first_line; (yyval.declare_body_)->char_number = (yyloc).first_column;  }
#line 4217 "Parser.c"
    break;

  case 3: /* DECLARE_BODY: ATTRIBUTES _SYMB_0 DECLARATION_LIST  */
#line 649 "HAL_S.y"
                                        { (yyval.declare_body_) = make_ABdeclareBody_attributes_declarationList((yyvsp[-2].attributes_), (yyvsp[0].declaration_list_)); (yyval.declare_body_)->line_number = (yyloc).first_line; (yyval.declare_body_)->char_number = (yyloc).first_column;  }
#line 4223 "Parser.c"
    break;

  case 4: /* ATTRIBUTES: ARRAY_SPEC TYPE_AND_MINOR_ATTR  */
#line 651 "HAL_S.y"
                                            { (yyval.attributes_) = make_AAattributes_arraySpec_typeAndMinorAttr((yyvsp[-1].array_spec_), (yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4229 "Parser.c"
    break;

  case 5: /* ATTRIBUTES: ARRAY_SPEC  */
#line 652 "HAL_S.y"
               { (yyval.attributes_) = make_ABattributes_arraySpec((yyvsp[0].array_spec_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4235 "Parser.c"
    break;

  case 6: /* ATTRIBUTES: TYPE_AND_MINOR_ATTR  */
#line 653 "HAL_S.y"
                        { (yyval.attributes_) = make_ACattributes_typeAndMinorAttr((yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4241 "Parser.c"
    break;

  case 7: /* DECLARATION: NAME_ID  */
#line 655 "HAL_S.y"
                      { (yyval.declaration_) = make_AAdeclaration_nameId((yyvsp[0].name_id_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4247 "Parser.c"
    break;

  case 8: /* DECLARATION: NAME_ID ATTRIBUTES  */
#line 656 "HAL_S.y"
                       { (yyval.declaration_) = make_ABdeclaration_nameId_attributes((yyvsp[-1].name_id_), (yyvsp[0].attributes_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4253 "Parser.c"
    break;

  case 9: /* DECLARATION: _SYMB_190 _SYMB_122 MINOR_ATTR_LIST  */
#line 657 "HAL_S.y"
                                        { (yyval.declaration_) = make_ACdeclaration_labelToken_procedure_minorAttrList((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4259 "Parser.c"
    break;

  case 10: /* DECLARATION: _SYMB_190 _SYMB_122  */
#line 658 "HAL_S.y"
                        { (yyval.declaration_) = make_ADdeclaration_labelToken_procedure((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4265 "Parser.c"
    break;

  case 11: /* DECLARATION: _SYMB_191 _SYMB_78  */
#line 659 "HAL_S.y"
                       { (yyval.declaration_) = make_AEdeclaration_eventToken_event((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4271 "Parser.c"
    break;

  case 12: /* DECLARATION: _SYMB_191 _SYMB_78 MINOR_ATTR_LIST  */
#line 660 "HAL_S.y"
                                       { (yyval.declaration_) = make_AFdeclaration_eventToken_event_minorAttrList((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4277 "Parser.c"
    break;

  case 13: /* DECLARATION: _SYMB_191  */
#line 661 "HAL_S.y"
              { (yyval.declaration_) = make_AGdeclaration_eventToken((yyvsp[0].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4283 "Parser.c"
    break;

  case 14: /* DECLARATION: _SYMB_191 MINOR_ATTR_LIST  */
#line 662 "HAL_S.y"
                              { (yyval.declaration_) = make_AHdeclaration_eventToken_minorAttrList((yyvsp[-1].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4289 "Parser.c"
    break;

  case 15: /* ARRAY_SPEC: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 664 "HAL_S.y"
                                                    { (yyval.array_spec_) = make_AAarraySpec_arrayHead_literalExpOrStar((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4295 "Parser.c"
    break;

  case 16: /* ARRAY_SPEC: _SYMB_88  */
#line 665 "HAL_S.y"
             { (yyval.array_spec_) = make_ABarraySpec_function(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4301 "Parser.c"
    break;

  case 17: /* ARRAY_SPEC: _SYMB_122  */
#line 666 "HAL_S.y"
              { (yyval.array_spec_) = make_ACarraySpec_procedure(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4307 "Parser.c"
    break;

  case 18: /* ARRAY_SPEC: _SYMB_124  */
#line 667 "HAL_S.y"
              { (yyval.array_spec_) = make_ADarraySpec_program(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4313 "Parser.c"
    break;

  case 19: /* ARRAY_SPEC: _SYMB_163  */
#line 668 "HAL_S.y"
              { (yyval.array_spec_) = make_AEarraySpec_task(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4319 "Parser.c"
    break;

  case 20: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC  */
#line 670 "HAL_S.y"
                                { (yyval.type_and_minor_attr_) = make_AAtypeAndMinorAttr_typeSpec((yyvsp[0].type_spec_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4325 "Parser.c"
    break;

  case 21: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC MINOR_ATTR_LIST  */
#line 671 "HAL_S.y"
                              { (yyval.type_and_minor_attr_) = make_ABtypeAndMinorAttr_typeSpec_minorAttrList((yyvsp[-1].type_spec_), (yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4331 "Parser.c"
    break;

  case 22: /* TYPE_AND_MINOR_ATTR: MINOR_ATTR_LIST  */
#line 672 "HAL_S.y"
                    { (yyval.type_and_minor_attr_) = make_ACtypeAndMinorAttr_minorAttrList((yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4337 "Parser.c"
    break;

  case 23: /* IDENTIFIER: _SYMB_193  */
#line 674 "HAL_S.y"
                       { (yyval.identifier_) = make_AAidentifier((yyvsp[0].string_)); (yyval.identifier_)->line_number = (yyloc).first_line; (yyval.identifier_)->char_number = (yyloc).first_column;  }
#line 4343 "Parser.c"
    break;

  case 24: /* SQ_DQ_NAME: DOUBLY_QUAL_NAME_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 676 "HAL_S.y"
                                                               { (yyval.sq_dq_name_) = make_AAsQdQName_doublyQualNameHead_literalExpOrStar((yyvsp[-2].doubly_qual_name_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 4349 "Parser.c"
    break;

  case 25: /* SQ_DQ_NAME: ARITH_CONV  */
#line 677 "HAL_S.y"
               { (yyval.sq_dq_name_) = make_ABsQdQName_arithConv((yyvsp[0].arith_conv_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 4355 "Parser.c"
    break;

  case 26: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_176 _SYMB_2  */
#line 679 "HAL_S.y"
                                          { (yyval.doubly_qual_name_head_) = make_AAdoublyQualNameHead_vector(); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 4361 "Parser.c"
    break;

  case 27: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_104 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_0  */
#line 680 "HAL_S.y"
                                                  { (yyval.doubly_qual_name_head_) = make_ABdoublyQualNameHead_matrix_literalExpOrStar((yyvsp[-1].literal_exp_or_star_)); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 4367 "Parser.c"
    break;

  case 28: /* ARITH_CONV: _SYMB_96  */
#line 682 "HAL_S.y"
                      { (yyval.arith_conv_) = make_AAarithConv_integer(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4373 "Parser.c"
    break;

  case 29: /* ARITH_CONV: _SYMB_140  */
#line 683 "HAL_S.y"
              { (yyval.arith_conv_) = make_ABarithConv_scalar(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4379 "Parser.c"
    break;

  case 30: /* ARITH_CONV: _SYMB_176  */
#line 684 "HAL_S.y"
              { (yyval.arith_conv_) = make_ACarithConv_vector(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4385 "Parser.c"
    break;

  case 31: /* ARITH_CONV: _SYMB_104  */
#line 685 "HAL_S.y"
              { (yyval.arith_conv_) = make_ADarithConv_matrix(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4391 "Parser.c"
    break;

  case 32: /* DECLARATION_LIST: DECLARATION  */
#line 687 "HAL_S.y"
                               { (yyval.declaration_list_) = make_AAdeclaration_list((yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 4397 "Parser.c"
    break;

  case 33: /* DECLARATION_LIST: DCL_LIST_COMMA DECLARATION  */
#line 688 "HAL_S.y"
                               { (yyval.declaration_list_) = make_ABdeclaration_list((yyvsp[-1].dcl_list_comma_), (yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 4403 "Parser.c"
    break;

  case 34: /* NAME_ID: IDENTIFIER  */
#line 690 "HAL_S.y"
                     { (yyval.name_id_) = make_AAnameId_identifier((yyvsp[0].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4409 "Parser.c"
    break;

  case 35: /* NAME_ID: IDENTIFIER _SYMB_109  */
#line 691 "HAL_S.y"
                         { (yyval.name_id_) = make_ABnameId_identifier_name((yyvsp[-1].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4415 "Parser.c"
    break;

  case 36: /* NAME_ID: BIT_ID  */
#line 692 "HAL_S.y"
           { (yyval.name_id_) = make_ACnameId_bitId((yyvsp[0].bit_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4421 "Parser.c"
    break;

  case 37: /* NAME_ID: CHAR_ID  */
#line 693 "HAL_S.y"
            { (yyval.name_id_) = make_ADnameId_charId((yyvsp[0].char_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4427 "Parser.c"
    break;

  case 38: /* NAME_ID: _SYMB_185  */
#line 694 "HAL_S.y"
              { (yyval.name_id_) = make_AEnameId_bitFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4433 "Parser.c"
    break;

  case 39: /* NAME_ID: _SYMB_186  */
#line 695 "HAL_S.y"
              { (yyval.name_id_) = make_AFnameId_charFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4439 "Parser.c"
    break;

  case 40: /* NAME_ID: _SYMB_188  */
#line 696 "HAL_S.y"
              { (yyval.name_id_) = make_AGnameId_structIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4445 "Parser.c"
    break;

  case 41: /* NAME_ID: _SYMB_189  */
#line 697 "HAL_S.y"
              { (yyval.name_id_) = make_AHnameId_structFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4451 "Parser.c"
    break;

  case 42: /* ARITH_EXP: TERM  */
#line 699 "HAL_S.y"
                 { (yyval.arith_exp_) = make_AAarithExpTerm((yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4457 "Parser.c"
    break;

  case 43: /* ARITH_EXP: PLUS TERM  */
#line 700 "HAL_S.y"
              { (yyval.arith_exp_) = make_ABarithExpPlusTerm((yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4463 "Parser.c"
    break;

  case 44: /* ARITH_EXP: MINUS TERM  */
#line 701 "HAL_S.y"
               { (yyval.arith_exp_) = make_ACarithMinusTerm((yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4469 "Parser.c"
    break;

  case 45: /* ARITH_EXP: ARITH_EXP PLUS TERM  */
#line 702 "HAL_S.y"
                        { (yyval.arith_exp_) = make_ADarithExpArithExpPlusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4475 "Parser.c"
    break;

  case 46: /* ARITH_EXP: ARITH_EXP MINUS TERM  */
#line 703 "HAL_S.y"
                         { (yyval.arith_exp_) = make_AEarithExpArithExpMinusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4481 "Parser.c"
    break;

  case 47: /* TERM: PRODUCT  */
#line 705 "HAL_S.y"
               { (yyval.term_) = make_AAtermNoDivide((yyvsp[0].product_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4487 "Parser.c"
    break;

  case 48: /* TERM: PRODUCT _SYMB_3 TERM  */
#line 706 "HAL_S.y"
                         { (yyval.term_) = make_ABtermDivide((yyvsp[-2].product_), (yyvsp[0].term_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4493 "Parser.c"
    break;

  case 49: /* PLUS: _SYMB_4  */
#line 708 "HAL_S.y"
               { (yyval.plus_) = make_AAplus(); (yyval.plus_)->line_number = (yyloc).first_line; (yyval.plus_)->char_number = (yyloc).first_column;  }
#line 4499 "Parser.c"
    break;

  case 50: /* MINUS: _SYMB_5  */
#line 710 "HAL_S.y"
                { (yyval.minus_) = make_AAminus(); (yyval.minus_)->line_number = (yyloc).first_line; (yyval.minus_)->char_number = (yyloc).first_column;  }
#line 4505 "Parser.c"
    break;

  case 51: /* PRODUCT: FACTOR  */
#line 712 "HAL_S.y"
                 { (yyval.product_) = make_AAproductSingle((yyvsp[0].factor_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4511 "Parser.c"
    break;

  case 52: /* PRODUCT: FACTOR _SYMB_6 PRODUCT  */
#line 713 "HAL_S.y"
                           { (yyval.product_) = make_ABproductCross((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4517 "Parser.c"
    break;

  case 53: /* PRODUCT: FACTOR _SYMB_7 PRODUCT  */
#line 714 "HAL_S.y"
                           { (yyval.product_) = make_ACproductDot((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4523 "Parser.c"
    break;

  case 54: /* PRODUCT: FACTOR PRODUCT  */
#line 715 "HAL_S.y"
                   { (yyval.product_) = make_ADproductMultiplication((yyvsp[-1].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4529 "Parser.c"
    break;

  case 55: /* FACTOR: PRIMARY  */
#line 717 "HAL_S.y"
                 { (yyval.factor_) = make_AAfactor((yyvsp[0].primary_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4535 "Parser.c"
    break;

  case 56: /* FACTOR: PRIMARY EXPONENTIATION FACTOR  */
#line 718 "HAL_S.y"
                                  { (yyval.factor_) = make_ABfactorExponentiation((yyvsp[-2].primary_), (yyvsp[-1].exponentiation_), (yyvsp[0].factor_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4541 "Parser.c"
    break;

  case 57: /* EXPONENTIATION: _SYMB_8  */
#line 720 "HAL_S.y"
                         { (yyval.exponentiation_) = make_AAexponentiation(); (yyval.exponentiation_)->line_number = (yyloc).first_line; (yyval.exponentiation_)->char_number = (yyloc).first_column;  }
#line 4547 "Parser.c"
    break;

  case 58: /* PRIMARY: ARITH_VAR  */
#line 722 "HAL_S.y"
                    { (yyval.primary_) = make_AAprimary((yyvsp[0].arith_var_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4553 "Parser.c"
    break;

  case 59: /* PRIMARY: PRE_PRIMARY  */
#line 723 "HAL_S.y"
                { (yyval.primary_) = make_ADprimary((yyvsp[0].pre_primary_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4559 "Parser.c"
    break;

  case 60: /* PRIMARY: MODIFIED_ARITH_FUNC  */
#line 724 "HAL_S.y"
                        { (yyval.primary_) = make_ABprimary((yyvsp[0].modified_arith_func_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4565 "Parser.c"
    break;

  case 61: /* PRIMARY: PRE_PRIMARY QUALIFIER  */
#line 725 "HAL_S.y"
                          { (yyval.primary_) = make_AEprimary((yyvsp[-1].pre_primary_), (yyvsp[0].qualifier_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4571 "Parser.c"
    break;

  case 62: /* ARITH_VAR: ARITH_ID  */
#line 727 "HAL_S.y"
                     { (yyval.arith_var_) = make_AAarith_var((yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4577 "Parser.c"
    break;

  case 63: /* ARITH_VAR: ARITH_ID SUBSCRIPT  */
#line 728 "HAL_S.y"
                       { (yyval.arith_var_) = make_ACarith_var((yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4583 "Parser.c"
    break;

  case 64: /* ARITH_VAR: _SYMB_10 ARITH_ID _SYMB_11  */
#line 729 "HAL_S.y"
                               { (yyval.arith_var_) = make_AAarithVarBracketed((yyvsp[-1].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4589 "Parser.c"
    break;

  case 65: /* ARITH_VAR: _SYMB_10 ARITH_ID _SYMB_11 SUBSCRIPT  */
#line 730 "HAL_S.y"
                                         { (yyval.arith_var_) = make_ABarithVarBracketed((yyvsp[-2].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4595 "Parser.c"
    break;

  case 66: /* ARITH_VAR: _SYMB_12 QUAL_STRUCT _SYMB_13  */
#line 731 "HAL_S.y"
                                  { (yyval.arith_var_) = make_AAarithVarBraced((yyvsp[-1].qual_struct_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4601 "Parser.c"
    break;

  case 67: /* ARITH_VAR: _SYMB_12 QUAL_STRUCT _SYMB_13 SUBSCRIPT  */
#line 732 "HAL_S.y"
                                            { (yyval.arith_var_) = make_ABarithVarBraced((yyvsp[-2].qual_struct_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4607 "Parser.c"
    break;

  case 68: /* ARITH_VAR: QUAL_STRUCT _SYMB_7 ARITH_ID  */
#line 733 "HAL_S.y"
                                 { (yyval.arith_var_) = make_ABarith_var((yyvsp[-2].qual_struct_), (yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4613 "Parser.c"
    break;

  case 69: /* ARITH_VAR: QUAL_STRUCT _SYMB_7 ARITH_ID SUBSCRIPT  */
#line 734 "HAL_S.y"
                                           { (yyval.arith_var_) = make_ADarith_var((yyvsp[-3].qual_struct_), (yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4619 "Parser.c"
    break;

  case 70: /* PRE_PRIMARY: _SYMB_2 ARITH_EXP _SYMB_1  */
#line 736 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AApre_primary((yyvsp[-1].arith_exp_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4625 "Parser.c"
    break;

  case 71: /* PRE_PRIMARY: NUMBER  */
#line 737 "HAL_S.y"
           { (yyval.pre_primary_) = make_ABpre_primary((yyvsp[0].number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4631 "Parser.c"
    break;

  case 72: /* PRE_PRIMARY: COMPOUND_NUMBER  */
#line 738 "HAL_S.y"
                    { (yyval.pre_primary_) = make_ACpre_primary((yyvsp[0].compound_number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4637 "Parser.c"
    break;

  case 73: /* PRE_PRIMARY: ARITH_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 739 "HAL_S.y"
                                              { (yyval.pre_primary_) = make_ADprePrimaryRtlFunction((yyvsp[-3].arith_func_head_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4643 "Parser.c"
    break;

  case 74: /* PRE_PRIMARY: _SYMB_190 _SYMB_2 CALL_LIST _SYMB_1  */
#line 740 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AEprePrimaryFunction((yyvsp[-3].string_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4649 "Parser.c"
    break;

  case 75: /* NUMBER: SIMPLE_NUMBER  */
#line 742 "HAL_S.y"
                       { (yyval.number_) = make_AAnumber((yyvsp[0].simple_number_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4655 "Parser.c"
    break;

  case 76: /* NUMBER: LEVEL  */
#line 743 "HAL_S.y"
          { (yyval.number_) = make_ABnumber((yyvsp[0].level_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4661 "Parser.c"
    break;

  case 77: /* LEVEL: _SYMB_196  */
#line 745 "HAL_S.y"
                  { (yyval.level_) = make_ZZlevel((yyvsp[0].string_)); (yyval.level_)->line_number = (yyloc).first_line; (yyval.level_)->char_number = (yyloc).first_column;  }
#line 4667 "Parser.c"
    break;

  case 78: /* COMPOUND_NUMBER: _SYMB_198  */
#line 747 "HAL_S.y"
                            { (yyval.compound_number_) = make_CLcompound_number((yyvsp[0].string_)); (yyval.compound_number_)->line_number = (yyloc).first_line; (yyval.compound_number_)->char_number = (yyloc).first_column;  }
#line 4673 "Parser.c"
    break;

  case 79: /* SIMPLE_NUMBER: _SYMB_197  */
#line 749 "HAL_S.y"
                          { (yyval.simple_number_) = make_CKsimple_number((yyvsp[0].string_)); (yyval.simple_number_)->line_number = (yyloc).first_line; (yyval.simple_number_)->char_number = (yyloc).first_column;  }
#line 4679 "Parser.c"
    break;

  case 80: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC  */
#line 751 "HAL_S.y"
                                        { (yyval.modified_arith_func_) = make_AAmodified_arith_func((yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4685 "Parser.c"
    break;

  case 81: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 752 "HAL_S.y"
                                { (yyval.modified_arith_func_) = make_ACmodified_arith_func((yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4691 "Parser.c"
    break;

  case 82: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_7 NO_ARG_ARITH_FUNC  */
#line 753 "HAL_S.y"
                                          { (yyval.modified_arith_func_) = make_ADmodified_arith_func((yyvsp[-2].qual_struct_), (yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4697 "Parser.c"
    break;

  case 83: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_7 NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 754 "HAL_S.y"
                                                    { (yyval.modified_arith_func_) = make_AEmodified_arith_func((yyvsp[-3].qual_struct_), (yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4703 "Parser.c"
    break;

  case 84: /* ARITH_FUNC_HEAD: ARITH_FUNC  */
#line 756 "HAL_S.y"
                             { (yyval.arith_func_head_) = make_AAarith_func_head((yyvsp[0].arith_func_)); (yyval.arith_func_head_)->line_number = (yyloc).first_line; (yyval.arith_func_head_)->char_number = (yyloc).first_column;  }
#line 4709 "Parser.c"
    break;

  case 85: /* ARITH_FUNC_HEAD: ARITH_CONV SUBSCRIPT  */
#line 757 "HAL_S.y"
                         { (yyval.arith_func_head_) = make_ABarith_func_head((yyvsp[-1].arith_conv_), (yyvsp[0].subscript_)); (yyval.arith_func_head_)->line_number = (yyloc).first_line; (yyval.arith_func_head_)->char_number = (yyloc).first_column;  }
#line 4715 "Parser.c"
    break;

  case 86: /* CALL_LIST: LIST_EXP  */
#line 759 "HAL_S.y"
                     { (yyval.call_list_) = make_AAcall_list((yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 4721 "Parser.c"
    break;

  case 87: /* CALL_LIST: CALL_LIST _SYMB_0 LIST_EXP  */
#line 760 "HAL_S.y"
                               { (yyval.call_list_) = make_ABcall_list((yyvsp[-2].call_list_), (yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 4727 "Parser.c"
    break;

  case 88: /* LIST_EXP: EXPRESSION  */
#line 762 "HAL_S.y"
                      { (yyval.list_exp_) = make_AAlist_exp((yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4733 "Parser.c"
    break;

  case 89: /* LIST_EXP: ARITH_EXP _SYMB_9 EXPRESSION  */
#line 763 "HAL_S.y"
                                 { (yyval.list_exp_) = make_ABlist_exp((yyvsp[-2].arith_exp_), (yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4739 "Parser.c"
    break;

  case 90: /* LIST_EXP: QUAL_STRUCT  */
#line 764 "HAL_S.y"
                { (yyval.list_exp_) = make_ADlist_exp((yyvsp[0].qual_struct_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4745 "Parser.c"
    break;

  case 91: /* EXPRESSION: ARITH_EXP  */
#line 766 "HAL_S.y"
                       { (yyval.expression_) = make_AAexpression((yyvsp[0].arith_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4751 "Parser.c"
    break;

  case 92: /* EXPRESSION: BIT_EXP  */
#line 767 "HAL_S.y"
            { (yyval.expression_) = make_ABexpression((yyvsp[0].bit_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4757 "Parser.c"
    break;

  case 93: /* EXPRESSION: CHAR_EXP  */
#line 768 "HAL_S.y"
             { (yyval.expression_) = make_ACexpression((yyvsp[0].char_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4763 "Parser.c"
    break;

  case 94: /* EXPRESSION: NAME_EXP  */
#line 769 "HAL_S.y"
             { (yyval.expression_) = make_AEexpression((yyvsp[0].name_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4769 "Parser.c"
    break;

  case 95: /* EXPRESSION: STRUCTURE_EXP  */
#line 770 "HAL_S.y"
                  { (yyval.expression_) = make_ADexpression((yyvsp[0].structure_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4775 "Parser.c"
    break;

  case 96: /* ARITH_ID: IDENTIFIER  */
#line 772 "HAL_S.y"
                      { (yyval.arith_id_) = make_FGarith_id((yyvsp[0].identifier_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 4781 "Parser.c"
    break;

  case 97: /* ARITH_ID: _SYMB_192  */
#line 773 "HAL_S.y"
              { (yyval.arith_id_) = make_FHarith_id((yyvsp[0].string_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 4787 "Parser.c"
    break;

  case 98: /* NO_ARG_ARITH_FUNC: _SYMB_56  */
#line 775 "HAL_S.y"
                             { (yyval.no_arg_arith_func_) = make_ZZclocktime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4793 "Parser.c"
    break;

  case 99: /* NO_ARG_ARITH_FUNC: _SYMB_63  */
#line 776 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZdate(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4799 "Parser.c"
    break;

  case 100: /* NO_ARG_ARITH_FUNC: _SYMB_75  */
#line 777 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZerrgrp(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4805 "Parser.c"
    break;

  case 101: /* NO_ARG_ARITH_FUNC: _SYMB_76  */
#line 778 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZerrnum(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4811 "Parser.c"
    break;

  case 102: /* NO_ARG_ARITH_FUNC: _SYMB_120  */
#line 779 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZprio(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4817 "Parser.c"
    break;

  case 103: /* NO_ARG_ARITH_FUNC: _SYMB_125  */
#line 780 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZrandom(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4823 "Parser.c"
    break;

  case 104: /* NO_ARG_ARITH_FUNC: _SYMB_126  */
#line 781 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZrandomg(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4829 "Parser.c"
    break;

  case 105: /* NO_ARG_ARITH_FUNC: _SYMB_139  */
#line 782 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZruntime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4835 "Parser.c"
    break;

  case 106: /* ARITH_FUNC: _SYMB_110  */
#line 784 "HAL_S.y"
                       { (yyval.arith_func_) = make_ZZnextime(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4841 "Parser.c"
    break;

  case 107: /* ARITH_FUNC: _SYMB_28  */
#line 785 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabs(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4847 "Parser.c"
    break;

  case 108: /* ARITH_FUNC: _SYMB_53  */
#line 786 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZceiling(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4853 "Parser.c"
    break;

  case 109: /* ARITH_FUNC: _SYMB_69  */
#line 787 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdiv(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4859 "Parser.c"
    break;

  case 110: /* ARITH_FUNC: _SYMB_86  */
#line 788 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZfloor(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4865 "Parser.c"
    break;

  case 111: /* ARITH_FUNC: _SYMB_106  */
#line 789 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmidval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4871 "Parser.c"
    break;

  case 112: /* ARITH_FUNC: _SYMB_108  */
#line 790 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4877 "Parser.c"
    break;

  case 113: /* ARITH_FUNC: _SYMB_115  */
#line 791 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZodd(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4883 "Parser.c"
    break;

  case 114: /* ARITH_FUNC: _SYMB_130  */
#line 792 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZremainder(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4889 "Parser.c"
    break;

  case 115: /* ARITH_FUNC: _SYMB_138  */
#line 793 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZround(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4895 "Parser.c"
    break;

  case 116: /* ARITH_FUNC: _SYMB_146  */
#line 794 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsign(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4901 "Parser.c"
    break;

  case 117: /* ARITH_FUNC: _SYMB_148  */
#line 795 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsignum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4907 "Parser.c"
    break;

  case 118: /* ARITH_FUNC: _SYMB_172  */
#line 796 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtruncate(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4913 "Parser.c"
    break;

  case 119: /* ARITH_FUNC: _SYMB_34  */
#line 797 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4919 "Parser.c"
    break;

  case 120: /* ARITH_FUNC: _SYMB_35  */
#line 798 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4925 "Parser.c"
    break;

  case 121: /* ARITH_FUNC: _SYMB_36  */
#line 799 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4931 "Parser.c"
    break;

  case 122: /* ARITH_FUNC: _SYMB_37  */
#line 800 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4937 "Parser.c"
    break;

  case 123: /* ARITH_FUNC: _SYMB_39  */
#line 801 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan2(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4943 "Parser.c"
    break;

  case 124: /* ARITH_FUNC: _SYMB_38  */
#line 802 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4949 "Parser.c"
    break;

  case 125: /* ARITH_FUNC: _SYMB_40  */
#line 803 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4955 "Parser.c"
    break;

  case 126: /* ARITH_FUNC: _SYMB_61  */
#line 804 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4961 "Parser.c"
    break;

  case 127: /* ARITH_FUNC: _SYMB_62  */
#line 805 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4967 "Parser.c"
    break;

  case 128: /* ARITH_FUNC: _SYMB_82  */
#line 806 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZexp(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4973 "Parser.c"
    break;

  case 129: /* ARITH_FUNC: _SYMB_103  */
#line 807 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZlog(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4979 "Parser.c"
    break;

  case 130: /* ARITH_FUNC: _SYMB_149  */
#line 808 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4985 "Parser.c"
    break;

  case 131: /* ARITH_FUNC: _SYMB_151  */
#line 809 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4991 "Parser.c"
    break;

  case 132: /* ARITH_FUNC: _SYMB_154  */
#line 810 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsqrt(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4997 "Parser.c"
    break;

  case 133: /* ARITH_FUNC: _SYMB_161  */
#line 811 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5003 "Parser.c"
    break;

  case 134: /* ARITH_FUNC: _SYMB_162  */
#line 812 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5009 "Parser.c"
    break;

  case 135: /* ARITH_FUNC: _SYMB_144  */
#line 813 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshl(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5015 "Parser.c"
    break;

  case 136: /* ARITH_FUNC: _SYMB_145  */
#line 814 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshr(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5021 "Parser.c"
    break;

  case 137: /* ARITH_FUNC: _SYMB_29  */
#line 815 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5027 "Parser.c"
    break;

  case 138: /* ARITH_FUNC: _SYMB_68  */
#line 816 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdet(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5033 "Parser.c"
    break;

  case 139: /* ARITH_FUNC: _SYMB_168  */
#line 817 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtrace(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5039 "Parser.c"
    break;

  case 140: /* ARITH_FUNC: _SYMB_173  */
#line 818 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZunit(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5045 "Parser.c"
    break;

  case 141: /* ARITH_FUNC: _SYMB_104  */
#line 819 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmatrix(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5051 "Parser.c"
    break;

  case 142: /* ARITH_FUNC: _SYMB_94  */
#line 820 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZindex(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5057 "Parser.c"
    break;

  case 143: /* ARITH_FUNC: _SYMB_99  */
#line 821 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZlength(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5063 "Parser.c"
    break;

  case 144: /* ARITH_FUNC: _SYMB_97  */
#line 822 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZinverse(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5069 "Parser.c"
    break;

  case 145: /* ARITH_FUNC: _SYMB_169  */
#line 823 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtranspose(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5075 "Parser.c"
    break;

  case 146: /* ARITH_FUNC: _SYMB_123  */
#line 824 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZprod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5081 "Parser.c"
    break;

  case 147: /* ARITH_FUNC: _SYMB_158  */
#line 825 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5087 "Parser.c"
    break;

  case 148: /* ARITH_FUNC: _SYMB_152  */
#line 826 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsize(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5093 "Parser.c"
    break;

  case 149: /* ARITH_FUNC: _SYMB_105  */
#line 827 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmax(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5099 "Parser.c"
    break;

  case 150: /* ARITH_FUNC: _SYMB_107  */
#line 828 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5105 "Parser.c"
    break;

  case 151: /* ARITH_FUNC: _SYMB_96  */
#line 829 "HAL_S.y"
             { (yyval.arith_func_) = make_AAarithFuncInteger(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5111 "Parser.c"
    break;

  case 152: /* ARITH_FUNC: _SYMB_140  */
#line 830 "HAL_S.y"
              { (yyval.arith_func_) = make_AAarithFuncScalar(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5117 "Parser.c"
    break;

  case 153: /* SUBSCRIPT: SUB_HEAD _SYMB_1  */
#line 832 "HAL_S.y"
                             { (yyval.subscript_) = make_AAsubscript((yyvsp[-1].sub_head_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5123 "Parser.c"
    break;

  case 154: /* SUBSCRIPT: QUALIFIER  */
#line 833 "HAL_S.y"
              { (yyval.subscript_) = make_ABsubscript((yyvsp[0].qualifier_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5129 "Parser.c"
    break;

  case 155: /* SUBSCRIPT: _SYMB_14 NUMBER  */
#line 834 "HAL_S.y"
                    { (yyval.subscript_) = make_ACsubscript((yyvsp[0].number_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5135 "Parser.c"
    break;

  case 156: /* SUBSCRIPT: _SYMB_14 ARITH_VAR  */
#line 835 "HAL_S.y"
                       { (yyval.subscript_) = make_ADsubscript((yyvsp[0].arith_var_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5141 "Parser.c"
    break;

  case 157: /* QUALIFIER: _SYMB_14 _SYMB_2 _SYMB_15 PREC_SPEC _SYMB_1  */
#line 837 "HAL_S.y"
                                                        { (yyval.qualifier_) = make_AAqualifier((yyvsp[-1].prec_spec_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5147 "Parser.c"
    break;

  case 158: /* QUALIFIER: _SYMB_14 _SYMB_2 SCALE_HEAD ARITH_EXP _SYMB_1  */
#line 838 "HAL_S.y"
                                                  { (yyval.qualifier_) = make_ABqualifier((yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5153 "Parser.c"
    break;

  case 159: /* QUALIFIER: _SYMB_14 _SYMB_2 _SYMB_15 PREC_SPEC _SYMB_0 SCALE_HEAD ARITH_EXP _SYMB_1  */
#line 839 "HAL_S.y"
                                                                             { (yyval.qualifier_) = make_ACqualifier((yyvsp[-4].prec_spec_), (yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5159 "Parser.c"
    break;

  case 160: /* QUALIFIER: _SYMB_14 _SYMB_2 _SYMB_15 RADIX _SYMB_1  */
#line 840 "HAL_S.y"
                                            { (yyval.qualifier_) = make_ADqualifier((yyvsp[-1].radix_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5165 "Parser.c"
    break;

  case 161: /* SCALE_HEAD: _SYMB_15  */
#line 842 "HAL_S.y"
                      { (yyval.scale_head_) = make_AAscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 5171 "Parser.c"
    break;

  case 162: /* SCALE_HEAD: _SYMB_15 _SYMB_15  */
#line 843 "HAL_S.y"
                      { (yyval.scale_head_) = make_ABscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 5177 "Parser.c"
    break;

  case 163: /* PREC_SPEC: _SYMB_150  */
#line 845 "HAL_S.y"
                      { (yyval.prec_spec_) = make_AAprecSpecSingle(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 5183 "Parser.c"
    break;

  case 164: /* PREC_SPEC: _SYMB_71  */
#line 846 "HAL_S.y"
             { (yyval.prec_spec_) = make_ABprecSpecDouble(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 5189 "Parser.c"
    break;

  case 165: /* SUB_START: _SYMB_14 _SYMB_2  */
#line 848 "HAL_S.y"
                             { (yyval.sub_start_) = make_AAsubStartGroup(); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5195 "Parser.c"
    break;

  case 166: /* SUB_START: _SYMB_14 _SYMB_2 _SYMB_15 PREC_SPEC _SYMB_0  */
#line 849 "HAL_S.y"
                                                { (yyval.sub_start_) = make_ABsubStartPrecSpec((yyvsp[-1].prec_spec_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5201 "Parser.c"
    break;

  case 167: /* SUB_START: SUB_HEAD _SYMB_16  */
#line 850 "HAL_S.y"
                      { (yyval.sub_start_) = make_ACsubStartSemicolon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5207 "Parser.c"
    break;

  case 168: /* SUB_START: SUB_HEAD _SYMB_17  */
#line 851 "HAL_S.y"
                      { (yyval.sub_start_) = make_ADsubStartColon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5213 "Parser.c"
    break;

  case 169: /* SUB_START: SUB_HEAD _SYMB_0  */
#line 852 "HAL_S.y"
                     { (yyval.sub_start_) = make_AEsubStartComma((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5219 "Parser.c"
    break;

  case 170: /* SUB_HEAD: SUB_START  */
#line 854 "HAL_S.y"
                     { (yyval.sub_head_) = make_AAsub_head((yyvsp[0].sub_start_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 5225 "Parser.c"
    break;

  case 171: /* SUB_HEAD: SUB_START SUB  */
#line 855 "HAL_S.y"
                  { (yyval.sub_head_) = make_ABsub_head((yyvsp[-1].sub_start_), (yyvsp[0].sub_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 5231 "Parser.c"
    break;

  case 172: /* SUB: SUB_EXP  */
#line 857 "HAL_S.y"
              { (yyval.sub_) = make_AAsub((yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5237 "Parser.c"
    break;

  case 173: /* SUB: _SYMB_6  */
#line 858 "HAL_S.y"
            { (yyval.sub_) = make_ABsubStar(); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5243 "Parser.c"
    break;

  case 174: /* SUB: SUB_RUN_HEAD SUB_EXP  */
#line 859 "HAL_S.y"
                         { (yyval.sub_) = make_ACsubExp((yyvsp[-1].sub_run_head_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5249 "Parser.c"
    break;

  case 175: /* SUB: ARITH_EXP _SYMB_43 SUB_EXP  */
#line 860 "HAL_S.y"
                               { (yyval.sub_) = make_ADsubAt((yyvsp[-2].arith_exp_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5255 "Parser.c"
    break;

  case 176: /* SUB_RUN_HEAD: SUB_EXP _SYMB_167  */
#line 862 "HAL_S.y"
                                 { (yyval.sub_run_head_) = make_AAsubRunHeadTo((yyvsp[-1].sub_exp_)); (yyval.sub_run_head_)->line_number = (yyloc).first_line; (yyval.sub_run_head_)->char_number = (yyloc).first_column;  }
#line 5261 "Parser.c"
    break;

  case 177: /* SUB_EXP: ARITH_EXP  */
#line 864 "HAL_S.y"
                    { (yyval.sub_exp_) = make_AAsub_exp((yyvsp[0].arith_exp_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 5267 "Parser.c"
    break;

  case 178: /* SUB_EXP: POUND_EXPRESSION  */
#line 865 "HAL_S.y"
                     { (yyval.sub_exp_) = make_ABsub_exp((yyvsp[0].pound_expression_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 5273 "Parser.c"
    break;

  case 179: /* POUND_EXPRESSION: _SYMB_9  */
#line 867 "HAL_S.y"
                           { (yyval.pound_expression_) = make_AApound_expression(); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5279 "Parser.c"
    break;

  case 180: /* POUND_EXPRESSION: POUND_EXPRESSION PLUS TERM  */
#line 868 "HAL_S.y"
                               { (yyval.pound_expression_) = make_ABpound_expression((yyvsp[-2].pound_expression_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5285 "Parser.c"
    break;

  case 181: /* POUND_EXPRESSION: POUND_EXPRESSION MINUS TERM  */
#line 869 "HAL_S.y"
                                { (yyval.pound_expression_) = make_ACpound_expression((yyvsp[-2].pound_expression_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5291 "Parser.c"
    break;

  case 182: /* BIT_EXP: BIT_FACTOR  */
#line 871 "HAL_S.y"
                     { (yyval.bit_exp_) = make_AAbitExpFactor((yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 5297 "Parser.c"
    break;

  case 183: /* BIT_EXP: BIT_EXP OR BIT_FACTOR  */
#line 872 "HAL_S.y"
                          { (yyval.bit_exp_) = make_ABbitExpOR((yyvsp[-2].bit_exp_), (yyvsp[-1].or_), (yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 5303 "Parser.c"
    break;

  case 184: /* BIT_FACTOR: BIT_CAT  */
#line 874 "HAL_S.y"
                     { (yyval.bit_factor_) = make_AAbitFactor((yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 5309 "Parser.c"
    break;

  case 185: /* BIT_FACTOR: BIT_FACTOR AND BIT_CAT  */
#line 875 "HAL_S.y"
                           { (yyval.bit_factor_) = make_ABbitFactorAnd((yyvsp[-2].bit_factor_), (yyvsp[-1].and_), (yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 5315 "Parser.c"
    break;

  case 186: /* BIT_CAT: BIT_PRIM  */
#line 877 "HAL_S.y"
                   { (yyval.bit_cat_) = make_AAbitCatPrim((yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5321 "Parser.c"
    break;

  case 187: /* BIT_CAT: BIT_CAT CAT BIT_PRIM  */
#line 878 "HAL_S.y"
                         { (yyval.bit_cat_) = make_ABbitCatCat((yyvsp[-2].bit_cat_), (yyvsp[-1].cat_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5327 "Parser.c"
    break;

  case 188: /* BIT_CAT: NOT BIT_PRIM  */
#line 879 "HAL_S.y"
                 { (yyval.bit_cat_) = make_ACbitCatNotPrim((yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5333 "Parser.c"
    break;

  case 189: /* BIT_CAT: BIT_CAT CAT NOT BIT_PRIM  */
#line 880 "HAL_S.y"
                             { (yyval.bit_cat_) = make_ADbitCatNotCat((yyvsp[-3].bit_cat_), (yyvsp[-2].cat_), (yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5339 "Parser.c"
    break;

  case 190: /* OR: CHAR_VERTICAL_BAR  */
#line 882 "HAL_S.y"
                       { (yyval.or_) = make_AAOR((yyvsp[0].char_vertical_bar_)); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5345 "Parser.c"
    break;

  case 191: /* OR: _SYMB_118  */
#line 883 "HAL_S.y"
              { (yyval.or_) = make_ABOR(); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5351 "Parser.c"
    break;

  case 192: /* CHAR_VERTICAL_BAR: _SYMB_18  */
#line 885 "HAL_S.y"
                             { (yyval.char_vertical_bar_) = make_CFchar_vertical_bar(); (yyval.char_vertical_bar_)->line_number = (yyloc).first_line; (yyval.char_vertical_bar_)->char_number = (yyloc).first_column;  }
#line 5357 "Parser.c"
    break;

  case 193: /* AND: _SYMB_19  */
#line 887 "HAL_S.y"
               { (yyval.and_) = make_AAAND(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5363 "Parser.c"
    break;

  case 194: /* AND: _SYMB_33  */
#line 888 "HAL_S.y"
             { (yyval.and_) = make_ABAND(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5369 "Parser.c"
    break;

  case 195: /* BIT_PRIM: BIT_VAR  */
#line 890 "HAL_S.y"
                   { (yyval.bit_prim_) = make_AAbitPrimBitVar((yyvsp[0].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5375 "Parser.c"
    break;

  case 196: /* BIT_PRIM: LABEL_VAR  */
#line 891 "HAL_S.y"
              { (yyval.bit_prim_) = make_ABbitPrimLabelVar((yyvsp[0].label_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5381 "Parser.c"
    break;

  case 197: /* BIT_PRIM: EVENT_VAR  */
#line 892 "HAL_S.y"
              { (yyval.bit_prim_) = make_ACbitPrimEventVar((yyvsp[0].event_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5387 "Parser.c"
    break;

  case 198: /* BIT_PRIM: BIT_CONST  */
#line 893 "HAL_S.y"
              { (yyval.bit_prim_) = make_ADbitBitConst((yyvsp[0].bit_const_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5393 "Parser.c"
    break;

  case 199: /* BIT_PRIM: _SYMB_2 BIT_EXP _SYMB_1  */
#line 894 "HAL_S.y"
                            { (yyval.bit_prim_) = make_AEbitPrimBitExp((yyvsp[-1].bit_exp_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5399 "Parser.c"
    break;

  case 200: /* BIT_PRIM: SUBBIT_HEAD EXPRESSION _SYMB_1  */
#line 895 "HAL_S.y"
                                   { (yyval.bit_prim_) = make_AHbitPrimSubbit((yyvsp[-2].subbit_head_), (yyvsp[-1].expression_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5405 "Parser.c"
    break;

  case 201: /* BIT_PRIM: BIT_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 896 "HAL_S.y"
                                            { (yyval.bit_prim_) = make_AIbitPrimFunc((yyvsp[-3].bit_func_head_), (yyvsp[-1].call_list_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5411 "Parser.c"
    break;

  case 202: /* BIT_PRIM: _SYMB_10 BIT_VAR _SYMB_11  */
#line 897 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBracketed((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5417 "Parser.c"
    break;

  case 203: /* BIT_PRIM: _SYMB_10 BIT_VAR _SYMB_11 SUBSCRIPT  */
#line 898 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBracketed((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5423 "Parser.c"
    break;

  case 204: /* BIT_PRIM: _SYMB_12 BIT_VAR _SYMB_13  */
#line 899 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBraced((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5429 "Parser.c"
    break;

  case 205: /* BIT_PRIM: _SYMB_12 BIT_VAR _SYMB_13 SUBSCRIPT  */
#line 900 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBraced((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5435 "Parser.c"
    break;

  case 206: /* CAT: _SYMB_20  */
#line 902 "HAL_S.y"
               { (yyval.cat_) = make_AAcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5441 "Parser.c"
    break;

  case 207: /* CAT: _SYMB_52  */
#line 903 "HAL_S.y"
             { (yyval.cat_) = make_ABcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5447 "Parser.c"
    break;

  case 208: /* NOT: _SYMB_21  */
#line 905 "HAL_S.y"
               { (yyval.not_) = make_AANOT(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5453 "Parser.c"
    break;

  case 209: /* NOT: _SYMB_112  */
#line 906 "HAL_S.y"
              { (yyval.not_) = make_ABNOT(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5459 "Parser.c"
    break;

  case 210: /* NOT: _SYMB_22  */
#line 907 "HAL_S.y"
             { (yyval.not_) = make_ACNOT(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5465 "Parser.c"
    break;

  case 211: /* NOT: _SYMB_23  */
#line 908 "HAL_S.y"
             { (yyval.not_) = make_ADNOT(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5471 "Parser.c"
    break;

  case 212: /* BIT_VAR: BIT_ID  */
#line 910 "HAL_S.y"
                 { (yyval.bit_var_) = make_AAbit_var((yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5477 "Parser.c"
    break;

  case 213: /* BIT_VAR: BIT_ID SUBSCRIPT  */
#line 911 "HAL_S.y"
                     { (yyval.bit_var_) = make_ACbit_var((yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5483 "Parser.c"
    break;

  case 214: /* BIT_VAR: QUAL_STRUCT _SYMB_7 BIT_ID  */
#line 912 "HAL_S.y"
                               { (yyval.bit_var_) = make_ABbit_var((yyvsp[-2].qual_struct_), (yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5489 "Parser.c"
    break;

  case 215: /* BIT_VAR: QUAL_STRUCT _SYMB_7 BIT_ID SUBSCRIPT  */
#line 913 "HAL_S.y"
                                         { (yyval.bit_var_) = make_ADbit_var((yyvsp[-3].qual_struct_), (yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5495 "Parser.c"
    break;

  case 216: /* LABEL_VAR: LABEL  */
#line 915 "HAL_S.y"
                  { (yyval.label_var_) = make_AAlabel_var((yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5501 "Parser.c"
    break;

  case 217: /* LABEL_VAR: LABEL SUBSCRIPT  */
#line 916 "HAL_S.y"
                    { (yyval.label_var_) = make_ABlabel_var((yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5507 "Parser.c"
    break;

  case 218: /* LABEL_VAR: QUAL_STRUCT _SYMB_7 LABEL  */
#line 917 "HAL_S.y"
                              { (yyval.label_var_) = make_AClabel_var((yyvsp[-2].qual_struct_), (yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5513 "Parser.c"
    break;

  case 219: /* LABEL_VAR: QUAL_STRUCT _SYMB_7 LABEL SUBSCRIPT  */
#line 918 "HAL_S.y"
                                        { (yyval.label_var_) = make_ADlabel_var((yyvsp[-3].qual_struct_), (yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5519 "Parser.c"
    break;

  case 220: /* EVENT_VAR: EVENT  */
#line 920 "HAL_S.y"
                  { (yyval.event_var_) = make_AAevent_var((yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5525 "Parser.c"
    break;

  case 221: /* EVENT_VAR: EVENT SUBSCRIPT  */
#line 921 "HAL_S.y"
                    { (yyval.event_var_) = make_ACevent_var((yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5531 "Parser.c"
    break;

  case 222: /* EVENT_VAR: QUAL_STRUCT _SYMB_7 EVENT  */
#line 922 "HAL_S.y"
                              { (yyval.event_var_) = make_ABevent_var((yyvsp[-2].qual_struct_), (yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5537 "Parser.c"
    break;

  case 223: /* EVENT_VAR: QUAL_STRUCT _SYMB_7 EVENT SUBSCRIPT  */
#line 923 "HAL_S.y"
                                        { (yyval.event_var_) = make_ADevent_var((yyvsp[-3].qual_struct_), (yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5543 "Parser.c"
    break;

  case 224: /* BIT_CONST_HEAD: RADIX  */
#line 925 "HAL_S.y"
                       { (yyval.bit_const_head_) = make_AAbit_const_head((yyvsp[0].radix_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5549 "Parser.c"
    break;

  case 225: /* BIT_CONST_HEAD: RADIX _SYMB_2 NUMBER _SYMB_1  */
#line 926 "HAL_S.y"
                                 { (yyval.bit_const_head_) = make_ABbit_const_head((yyvsp[-3].radix_), (yyvsp[-1].number_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5555 "Parser.c"
    break;

  case 226: /* BIT_CONST: BIT_CONST_HEAD CHAR_STRING  */
#line 928 "HAL_S.y"
                                       { (yyval.bit_const_) = make_AAbitConstString((yyvsp[-1].bit_const_head_), (yyvsp[0].char_string_)); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5561 "Parser.c"
    break;

  case 227: /* BIT_CONST: _SYMB_171  */
#line 929 "HAL_S.y"
              { (yyval.bit_const_) = make_ABbitConstTrue(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5567 "Parser.c"
    break;

  case 228: /* BIT_CONST: _SYMB_84  */
#line 930 "HAL_S.y"
             { (yyval.bit_const_) = make_ACbitConstFalse(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5573 "Parser.c"
    break;

  case 229: /* BIT_CONST: _SYMB_117  */
#line 931 "HAL_S.y"
              { (yyval.bit_const_) = make_ADbitConstOn(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5579 "Parser.c"
    break;

  case 230: /* BIT_CONST: _SYMB_116  */
#line 932 "HAL_S.y"
              { (yyval.bit_const_) = make_AEbitConstOff(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5585 "Parser.c"
    break;

  case 231: /* RADIX: _SYMB_90  */
#line 934 "HAL_S.y"
                 { (yyval.radix_) = make_AAradixHEX(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5591 "Parser.c"
    break;

  case 232: /* RADIX: _SYMB_114  */
#line 935 "HAL_S.y"
              { (yyval.radix_) = make_ABradixOCT(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5597 "Parser.c"
    break;

  case 233: /* RADIX: _SYMB_45  */
#line 936 "HAL_S.y"
             { (yyval.radix_) = make_ACradixBIN(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5603 "Parser.c"
    break;

  case 234: /* RADIX: _SYMB_64  */
#line 937 "HAL_S.y"
             { (yyval.radix_) = make_ADradixDEC(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5609 "Parser.c"
    break;

  case 235: /* CHAR_STRING: _SYMB_194  */
#line 939 "HAL_S.y"
                        { (yyval.char_string_) = make_FPchar_string((yyvsp[0].string_)); (yyval.char_string_)->line_number = (yyloc).first_line; (yyval.char_string_)->char_number = (yyloc).first_column;  }
#line 5615 "Parser.c"
    break;

  case 236: /* SUBBIT_HEAD: SUBBIT_KEY _SYMB_2  */
#line 941 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_AAsubbit_head((yyvsp[-1].subbit_key_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5621 "Parser.c"
    break;

  case 237: /* SUBBIT_HEAD: SUBBIT_KEY SUBSCRIPT _SYMB_2  */
#line 942 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_ABsubbit_head((yyvsp[-2].subbit_key_), (yyvsp[-1].subscript_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5627 "Parser.c"
    break;

  case 238: /* SUBBIT_KEY: _SYMB_157  */
#line 944 "HAL_S.y"
                       { (yyval.subbit_key_) = make_AAsubbit_key(); (yyval.subbit_key_)->line_number = (yyloc).first_line; (yyval.subbit_key_)->char_number = (yyloc).first_column;  }
#line 5633 "Parser.c"
    break;

  case 239: /* BIT_FUNC_HEAD: BIT_FUNC  */
#line 946 "HAL_S.y"
                         { (yyval.bit_func_head_) = make_AAbit_func_head((yyvsp[0].bit_func_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5639 "Parser.c"
    break;

  case 240: /* BIT_FUNC_HEAD: _SYMB_46  */
#line 947 "HAL_S.y"
             { (yyval.bit_func_head_) = make_ABbit_func_head(); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5645 "Parser.c"
    break;

  case 241: /* BIT_FUNC_HEAD: _SYMB_46 SUB_OR_QUALIFIER  */
#line 948 "HAL_S.y"
                              { (yyval.bit_func_head_) = make_ACbit_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5651 "Parser.c"
    break;

  case 242: /* BIT_ID: _SYMB_184  */
#line 950 "HAL_S.y"
                   { (yyval.bit_id_) = make_FHbit_id((yyvsp[0].string_)); (yyval.bit_id_)->line_number = (yyloc).first_line; (yyval.bit_id_)->char_number = (yyloc).first_column;  }
#line 5657 "Parser.c"
    break;

  case 243: /* LABEL: _SYMB_190  */
#line 952 "HAL_S.y"
                  { (yyval.label_) = make_FKlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5663 "Parser.c"
    break;

  case 244: /* LABEL: _SYMB_185  */
#line 953 "HAL_S.y"
              { (yyval.label_) = make_FLlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5669 "Parser.c"
    break;

  case 245: /* LABEL: _SYMB_186  */
#line 954 "HAL_S.y"
              { (yyval.label_) = make_FMlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5675 "Parser.c"
    break;

  case 246: /* LABEL: _SYMB_189  */
#line 955 "HAL_S.y"
              { (yyval.label_) = make_FNlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5681 "Parser.c"
    break;

  case 247: /* BIT_FUNC: _SYMB_180  */
#line 957 "HAL_S.y"
                     { (yyval.bit_func_) = make_ZZxor(); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5687 "Parser.c"
    break;

  case 248: /* BIT_FUNC: _SYMB_185  */
#line 958 "HAL_S.y"
              { (yyval.bit_func_) = make_ZZuserBitFunction((yyvsp[0].string_)); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5693 "Parser.c"
    break;

  case 249: /* EVENT: _SYMB_191  */
#line 960 "HAL_S.y"
                  { (yyval.event_) = make_FLevent((yyvsp[0].string_)); (yyval.event_)->line_number = (yyloc).first_line; (yyval.event_)->char_number = (yyloc).first_column;  }
#line 5699 "Parser.c"
    break;

  case 250: /* SUB_OR_QUALIFIER: SUBSCRIPT  */
#line 962 "HAL_S.y"
                             { (yyval.sub_or_qualifier_) = make_AAsub_or_qualifier((yyvsp[0].subscript_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 5705 "Parser.c"
    break;

  case 251: /* SUB_OR_QUALIFIER: BIT_QUALIFIER  */
#line 963 "HAL_S.y"
                  { (yyval.sub_or_qualifier_) = make_ABsub_or_qualifier((yyvsp[0].bit_qualifier_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 5711 "Parser.c"
    break;

  case 252: /* BIT_QUALIFIER: _SYMB_24 _SYMB_14 _SYMB_2 _SYMB_15 RADIX _SYMB_1  */
#line 965 "HAL_S.y"
                                                                 { (yyval.bit_qualifier_) = make_AAbit_qualifier((yyvsp[-1].radix_)); (yyval.bit_qualifier_)->line_number = (yyloc).first_line; (yyval.bit_qualifier_)->char_number = (yyloc).first_column;  }
#line 5717 "Parser.c"
    break;

  case 253: /* CHAR_EXP: CHAR_PRIM  */
#line 967 "HAL_S.y"
                     { (yyval.char_exp_) = make_AAcharExpPrim((yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5723 "Parser.c"
    break;

  case 254: /* CHAR_EXP: CHAR_EXP CAT CHAR_PRIM  */
#line 968 "HAL_S.y"
                           { (yyval.char_exp_) = make_ABcharExpCat((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5729 "Parser.c"
    break;

  case 255: /* CHAR_EXP: CHAR_EXP CAT ARITH_EXP  */
#line 969 "HAL_S.y"
                           { (yyval.char_exp_) = make_ACcharExpCat((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5735 "Parser.c"
    break;

  case 256: /* CHAR_EXP: ARITH_EXP CAT ARITH_EXP  */
#line 970 "HAL_S.y"
                            { (yyval.char_exp_) = make_ADcharExpCat((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5741 "Parser.c"
    break;

  case 257: /* CHAR_EXP: ARITH_EXP CAT CHAR_PRIM  */
#line 971 "HAL_S.y"
                            { (yyval.char_exp_) = make_AEcharExpCat((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5747 "Parser.c"
    break;

  case 258: /* CHAR_PRIM: CHAR_VAR  */
#line 973 "HAL_S.y"
                     { (yyval.char_prim_) = make_AAchar_prim((yyvsp[0].char_var_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5753 "Parser.c"
    break;

  case 259: /* CHAR_PRIM: CHAR_CONST  */
#line 974 "HAL_S.y"
               { (yyval.char_prim_) = make_ABchar_prim((yyvsp[0].char_const_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5759 "Parser.c"
    break;

  case 260: /* CHAR_PRIM: CHAR_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 975 "HAL_S.y"
                                             { (yyval.char_prim_) = make_AEchar_prim((yyvsp[-3].char_func_head_), (yyvsp[-1].call_list_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5765 "Parser.c"
    break;

  case 261: /* CHAR_PRIM: _SYMB_2 CHAR_EXP _SYMB_1  */
#line 976 "HAL_S.y"
                             { (yyval.char_prim_) = make_AFchar_prim((yyvsp[-1].char_exp_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5771 "Parser.c"
    break;

  case 262: /* CHAR_FUNC_HEAD: CHAR_FUNC  */
#line 978 "HAL_S.y"
                           { (yyval.char_func_head_) = make_AAchar_func_head((yyvsp[0].char_func_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 5777 "Parser.c"
    break;

  case 263: /* CHAR_FUNC_HEAD: _SYMB_55 SUB_OR_QUALIFIER  */
#line 979 "HAL_S.y"
                              { (yyval.char_func_head_) = make_ABchar_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 5783 "Parser.c"
    break;

  case 264: /* CHAR_VAR: CHAR_ID  */
#line 981 "HAL_S.y"
                   { (yyval.char_var_) = make_AAchar_var((yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5789 "Parser.c"
    break;

  case 265: /* CHAR_VAR: CHAR_ID SUBSCRIPT  */
#line 982 "HAL_S.y"
                      { (yyval.char_var_) = make_ACchar_var((yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5795 "Parser.c"
    break;

  case 266: /* CHAR_VAR: QUAL_STRUCT _SYMB_7 CHAR_ID  */
#line 983 "HAL_S.y"
                                { (yyval.char_var_) = make_ABchar_var((yyvsp[-2].qual_struct_), (yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5801 "Parser.c"
    break;

  case 267: /* CHAR_VAR: QUAL_STRUCT _SYMB_7 CHAR_ID SUBSCRIPT  */
#line 984 "HAL_S.y"
                                          { (yyval.char_var_) = make_ADchar_var((yyvsp[-3].qual_struct_), (yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5807 "Parser.c"
    break;

  case 268: /* CHAR_CONST: CHAR_STRING  */
#line 986 "HAL_S.y"
                         { (yyval.char_const_) = make_AAchar_const((yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 5813 "Parser.c"
    break;

  case 269: /* CHAR_CONST: _SYMB_54 _SYMB_2 NUMBER _SYMB_1 CHAR_STRING  */
#line 987 "HAL_S.y"
                                                { (yyval.char_const_) = make_ABchar_const((yyvsp[-2].number_), (yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 5819 "Parser.c"
    break;

  case 270: /* CHAR_FUNC: _SYMB_101  */
#line 989 "HAL_S.y"
                      { (yyval.char_func_) = make_ZZljust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5825 "Parser.c"
    break;

  case 271: /* CHAR_FUNC: _SYMB_137  */
#line 990 "HAL_S.y"
              { (yyval.char_func_) = make_ZZrjust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5831 "Parser.c"
    break;

  case 272: /* CHAR_FUNC: _SYMB_170  */
#line 991 "HAL_S.y"
              { (yyval.char_func_) = make_ZZtrim(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5837 "Parser.c"
    break;

  case 273: /* CHAR_FUNC: _SYMB_186  */
#line 992 "HAL_S.y"
              { (yyval.char_func_) = make_ZZuserCharFunction((yyvsp[0].string_)); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5843 "Parser.c"
    break;

  case 274: /* CHAR_FUNC: _SYMB_55  */
#line 993 "HAL_S.y"
             { (yyval.char_func_) = make_AAcharFuncCharacter(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5849 "Parser.c"
    break;

  case 275: /* CHAR_ID: _SYMB_187  */
#line 995 "HAL_S.y"
                    { (yyval.char_id_) = make_FIchar_id((yyvsp[0].string_)); (yyval.char_id_)->line_number = (yyloc).first_line; (yyval.char_id_)->char_number = (yyloc).first_column;  }
#line 5855 "Parser.c"
    break;

  case 276: /* NAME_EXP: NAME_KEY _SYMB_2 NAME_VAR _SYMB_1  */
#line 997 "HAL_S.y"
                                             { (yyval.name_exp_) = make_AAnameExpKeyVar((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5861 "Parser.c"
    break;

  case 277: /* NAME_EXP: _SYMB_113  */
#line 998 "HAL_S.y"
              { (yyval.name_exp_) = make_ABnameExpNull(); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5867 "Parser.c"
    break;

  case 278: /* NAME_EXP: NAME_KEY _SYMB_2 _SYMB_113 _SYMB_1  */
#line 999 "HAL_S.y"
                                       { (yyval.name_exp_) = make_ACnameExpKeyNull((yyvsp[-3].name_key_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5873 "Parser.c"
    break;

  case 279: /* NAME_KEY: _SYMB_109  */
#line 1001 "HAL_S.y"
                     { (yyval.name_key_) = make_AAname_key(); (yyval.name_key_)->line_number = (yyloc).first_line; (yyval.name_key_)->char_number = (yyloc).first_column;  }
#line 5879 "Parser.c"
    break;

  case 280: /* NAME_VAR: VARIABLE  */
#line 1003 "HAL_S.y"
                    { (yyval.name_var_) = make_AAname_var((yyvsp[0].variable_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5885 "Parser.c"
    break;

  case 281: /* NAME_VAR: MODIFIED_ARITH_FUNC  */
#line 1004 "HAL_S.y"
                        { (yyval.name_var_) = make_ACname_var((yyvsp[0].modified_arith_func_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5891 "Parser.c"
    break;

  case 282: /* NAME_VAR: LABEL_VAR  */
#line 1005 "HAL_S.y"
              { (yyval.name_var_) = make_ABname_var((yyvsp[0].label_var_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5897 "Parser.c"
    break;

  case 283: /* VARIABLE: ARITH_VAR  */
#line 1007 "HAL_S.y"
                     { (yyval.variable_) = make_AAvariable((yyvsp[0].arith_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5903 "Parser.c"
    break;

  case 284: /* VARIABLE: BIT_VAR  */
#line 1008 "HAL_S.y"
            { (yyval.variable_) = make_ACvariable((yyvsp[0].bit_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5909 "Parser.c"
    break;

  case 285: /* VARIABLE: SUBBIT_HEAD VARIABLE _SYMB_1  */
#line 1009 "HAL_S.y"
                                 { (yyval.variable_) = make_AEvariable((yyvsp[-2].subbit_head_), (yyvsp[-1].variable_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5915 "Parser.c"
    break;

  case 286: /* VARIABLE: CHAR_VAR  */
#line 1010 "HAL_S.y"
             { (yyval.variable_) = make_AFvariable((yyvsp[0].char_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5921 "Parser.c"
    break;

  case 287: /* VARIABLE: NAME_KEY _SYMB_2 NAME_VAR _SYMB_1  */
#line 1011 "HAL_S.y"
                                      { (yyval.variable_) = make_AGvariable((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5927 "Parser.c"
    break;

  case 288: /* VARIABLE: EVENT_VAR  */
#line 1012 "HAL_S.y"
              { (yyval.variable_) = make_ADvariable((yyvsp[0].event_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5933 "Parser.c"
    break;

  case 289: /* VARIABLE: STRUCTURE_VAR  */
#line 1013 "HAL_S.y"
                  { (yyval.variable_) = make_ABvariable((yyvsp[0].structure_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5939 "Parser.c"
    break;

  case 290: /* STRUCTURE_EXP: STRUCTURE_VAR  */
#line 1015 "HAL_S.y"
                              { (yyval.structure_exp_) = make_AAstructure_exp((yyvsp[0].structure_var_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5945 "Parser.c"
    break;

  case 291: /* STRUCTURE_EXP: STRUCT_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 1016 "HAL_S.y"
                                               { (yyval.structure_exp_) = make_ADstructure_exp((yyvsp[-3].struct_func_head_), (yyvsp[-1].call_list_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5951 "Parser.c"
    break;

  case 292: /* STRUCTURE_EXP: STRUC_INLINE_DEF CLOSING _SYMB_16  */
#line 1017 "HAL_S.y"
                                      { (yyval.structure_exp_) = make_ACstructure_exp((yyvsp[-2].struc_inline_def_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5957 "Parser.c"
    break;

  case 293: /* STRUCTURE_EXP: STRUC_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1018 "HAL_S.y"
                                                 { (yyval.structure_exp_) = make_AEstructure_exp((yyvsp[-3].struc_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5963 "Parser.c"
    break;

  case 294: /* STRUCT_FUNC_HEAD: STRUCT_FUNC  */
#line 1020 "HAL_S.y"
                               { (yyval.struct_func_head_) = make_AAstruct_func_head((yyvsp[0].struct_func_)); (yyval.struct_func_head_)->line_number = (yyloc).first_line; (yyval.struct_func_head_)->char_number = (yyloc).first_column;  }
#line 5969 "Parser.c"
    break;

  case 295: /* STRUCTURE_VAR: QUAL_STRUCT SUBSCRIPT  */
#line 1022 "HAL_S.y"
                                      { (yyval.structure_var_) = make_AAstructure_var((yyvsp[-1].qual_struct_), (yyvsp[0].subscript_)); (yyval.structure_var_)->line_number = (yyloc).first_line; (yyval.structure_var_)->char_number = (yyloc).first_column;  }
#line 5975 "Parser.c"
    break;

  case 296: /* STRUCT_FUNC: _SYMB_189  */
#line 1024 "HAL_S.y"
                        { (yyval.struct_func_) = make_ZZuserStructFunc((yyvsp[0].string_)); (yyval.struct_func_)->line_number = (yyloc).first_line; (yyval.struct_func_)->char_number = (yyloc).first_column;  }
#line 5981 "Parser.c"
    break;

  case 297: /* QUAL_STRUCT: STRUCTURE_ID  */
#line 1026 "HAL_S.y"
                           { (yyval.qual_struct_) = make_AAqual_struct((yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 5987 "Parser.c"
    break;

  case 298: /* QUAL_STRUCT: QUAL_STRUCT _SYMB_7 STRUCTURE_ID  */
#line 1027 "HAL_S.y"
                                     { (yyval.qual_struct_) = make_ABqual_struct((yyvsp[-2].qual_struct_), (yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 5993 "Parser.c"
    break;

  case 299: /* STRUCTURE_ID: _SYMB_188  */
#line 1029 "HAL_S.y"
                         { (yyval.structure_id_) = make_FJstructure_id((yyvsp[0].string_)); (yyval.structure_id_)->line_number = (yyloc).first_line; (yyval.structure_id_)->char_number = (yyloc).first_column;  }
#line 5999 "Parser.c"
    break;

  case 300: /* ASSIGNMENT: VARIABLE EQUALS EXPRESSION  */
#line 1031 "HAL_S.y"
                                        { (yyval.assignment_) = make_AAassignment((yyvsp[-2].variable_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6005 "Parser.c"
    break;

  case 301: /* ASSIGNMENT: VARIABLE _SYMB_0 ASSIGNMENT  */
#line 1032 "HAL_S.y"
                                { (yyval.assignment_) = make_ABassignment((yyvsp[-2].variable_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6011 "Parser.c"
    break;

  case 302: /* ASSIGNMENT: QUAL_STRUCT EQUALS EXPRESSION  */
#line 1033 "HAL_S.y"
                                  { (yyval.assignment_) = make_ACassignment((yyvsp[-2].qual_struct_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6017 "Parser.c"
    break;

  case 303: /* ASSIGNMENT: QUAL_STRUCT _SYMB_0 ASSIGNMENT  */
#line 1034 "HAL_S.y"
                                   { (yyval.assignment_) = make_ADassignment((yyvsp[-2].qual_struct_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6023 "Parser.c"
    break;

  case 304: /* EQUALS: _SYMB_25  */
#line 1036 "HAL_S.y"
                  { (yyval.equals_) = make_AAequals(); (yyval.equals_)->line_number = (yyloc).first_line; (yyval.equals_)->char_number = (yyloc).first_column;  }
#line 6029 "Parser.c"
    break;

  case 305: /* IF_STATEMENT: IF_CLAUSE STATEMENT  */
#line 1038 "HAL_S.y"
                                   { (yyval.if_statement_) = make_AAifStatement((yyvsp[-1].if_clause_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 6035 "Parser.c"
    break;

  case 306: /* IF_STATEMENT: TRUE_PART STATEMENT  */
#line 1039 "HAL_S.y"
                        { (yyval.if_statement_) = make_ABifThenElseStatement((yyvsp[-1].true_part_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 6041 "Parser.c"
    break;

  case 307: /* IF_CLAUSE: IF RELATIONAL_EXP THEN  */
#line 1041 "HAL_S.y"
                                   { (yyval.if_clause_) = make_AAifClauseRelationalExp((yyvsp[-2].if_), (yyvsp[-1].relational_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 6047 "Parser.c"
    break;

  case 308: /* IF_CLAUSE: IF BIT_EXP THEN  */
#line 1042 "HAL_S.y"
                    { (yyval.if_clause_) = make_ABifClauseBitExp((yyvsp[-2].if_), (yyvsp[-1].bit_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 6053 "Parser.c"
    break;

  case 309: /* TRUE_PART: IF_CLAUSE BASIC_STATEMENT _SYMB_72  */
#line 1044 "HAL_S.y"
                                               { (yyval.true_part_) = make_AAtrue_part((yyvsp[-2].if_clause_), (yyvsp[-1].basic_statement_)); (yyval.true_part_)->line_number = (yyloc).first_line; (yyval.true_part_)->char_number = (yyloc).first_column;  }
#line 6059 "Parser.c"
    break;

  case 310: /* IF: _SYMB_91  */
#line 1046 "HAL_S.y"
              { (yyval.if_) = make_AAif(); (yyval.if_)->line_number = (yyloc).first_line; (yyval.if_)->char_number = (yyloc).first_column;  }
#line 6065 "Parser.c"
    break;

  case 311: /* THEN: _SYMB_166  */
#line 1048 "HAL_S.y"
                 { (yyval.then_) = make_AAthen(); (yyval.then_)->line_number = (yyloc).first_line; (yyval.then_)->char_number = (yyloc).first_column;  }
#line 6071 "Parser.c"
    break;

  case 312: /* RELATIONAL_EXP: RELATIONAL_FACTOR  */
#line 1050 "HAL_S.y"
                                   { (yyval.relational_exp_) = make_AArelational_exp((yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 6077 "Parser.c"
    break;

  case 313: /* RELATIONAL_EXP: RELATIONAL_EXP OR RELATIONAL_FACTOR  */
#line 1051 "HAL_S.y"
                                        { (yyval.relational_exp_) = make_ABrelational_exp((yyvsp[-2].relational_exp_), (yyvsp[-1].or_), (yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 6083 "Parser.c"
    break;

  case 314: /* RELATIONAL_FACTOR: REL_PRIM  */
#line 1053 "HAL_S.y"
                             { (yyval.relational_factor_) = make_AArelational_factor((yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 6089 "Parser.c"
    break;

  case 315: /* RELATIONAL_FACTOR: RELATIONAL_FACTOR AND REL_PRIM  */
#line 1054 "HAL_S.y"
                                   { (yyval.relational_factor_) = make_ABrelational_factor((yyvsp[-2].relational_factor_), (yyvsp[-1].and_), (yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 6095 "Parser.c"
    break;

  case 316: /* REL_PRIM: _SYMB_2 RELATIONAL_EXP _SYMB_1  */
#line 1056 "HAL_S.y"
                                          { (yyval.rel_prim_) = make_AArel_prim((yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6101 "Parser.c"
    break;

  case 317: /* REL_PRIM: NOT _SYMB_2 RELATIONAL_EXP _SYMB_1  */
#line 1057 "HAL_S.y"
                                       { (yyval.rel_prim_) = make_ABrel_prim((yyvsp[-3].not_), (yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6107 "Parser.c"
    break;

  case 318: /* REL_PRIM: COMPARISON  */
#line 1058 "HAL_S.y"
               { (yyval.rel_prim_) = make_ACrel_prim((yyvsp[0].comparison_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6113 "Parser.c"
    break;

  case 319: /* COMPARISON: ARITH_EXP RELATIONAL_OP ARITH_EXP  */
#line 1060 "HAL_S.y"
                                               { (yyval.comparison_) = make_AAcomparison((yyvsp[-2].arith_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6119 "Parser.c"
    break;

  case 320: /* COMPARISON: CHAR_EXP RELATIONAL_OP CHAR_EXP  */
#line 1061 "HAL_S.y"
                                    { (yyval.comparison_) = make_ABcomparison((yyvsp[-2].char_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6125 "Parser.c"
    break;

  case 321: /* COMPARISON: BIT_CAT RELATIONAL_OP BIT_CAT  */
#line 1062 "HAL_S.y"
                                  { (yyval.comparison_) = make_ACcomparison((yyvsp[-2].bit_cat_), (yyvsp[-1].relational_op_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6131 "Parser.c"
    break;

  case 322: /* COMPARISON: STRUCTURE_EXP RELATIONAL_OP STRUCTURE_EXP  */
#line 1063 "HAL_S.y"
                                              { (yyval.comparison_) = make_ADcomparison((yyvsp[-2].structure_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6137 "Parser.c"
    break;

  case 323: /* COMPARISON: NAME_EXP RELATIONAL_OP NAME_EXP  */
#line 1064 "HAL_S.y"
                                    { (yyval.comparison_) = make_AEcomparison((yyvsp[-2].name_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6143 "Parser.c"
    break;

  case 324: /* RELATIONAL_OP: EQUALS  */
#line 1066 "HAL_S.y"
                       { (yyval.relational_op_) = make_AArelationalOpEQ((yyvsp[0].equals_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6149 "Parser.c"
    break;

  case 325: /* RELATIONAL_OP: _SYMB_181  */
#line 1067 "HAL_S.y"
              { (yyval.relational_op_) = make_ABrelationalOpNEQ((yyvsp[0].string_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6155 "Parser.c"
    break;

  case 326: /* RELATIONAL_OP: _SYMB_24  */
#line 1068 "HAL_S.y"
             { (yyval.relational_op_) = make_ACrelationalOpLT(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6161 "Parser.c"
    break;

  case 327: /* RELATIONAL_OP: _SYMB_26  */
#line 1069 "HAL_S.y"
             { (yyval.relational_op_) = make_ADrelationalOpGT(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6167 "Parser.c"
    break;

  case 328: /* RELATIONAL_OP: _SYMB_182  */
#line 1070 "HAL_S.y"
              { (yyval.relational_op_) = make_AErelationalOpLE((yyvsp[0].string_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6173 "Parser.c"
    break;

  case 329: /* RELATIONAL_OP: _SYMB_183  */
#line 1071 "HAL_S.y"
              { (yyval.relational_op_) = make_AFrelationalOpGE((yyvsp[0].string_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6179 "Parser.c"
    break;

  case 330: /* STATEMENT: BASIC_STATEMENT  */
#line 1073 "HAL_S.y"
                            { (yyval.statement_) = make_AAstatement((yyvsp[0].basic_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6185 "Parser.c"
    break;

  case 331: /* STATEMENT: OTHER_STATEMENT  */
#line 1074 "HAL_S.y"
                    { (yyval.statement_) = make_ABstatement((yyvsp[0].other_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6191 "Parser.c"
    break;

  case 332: /* STATEMENT: INLINE_DEFINITION  */
#line 1075 "HAL_S.y"
                      { (yyval.statement_) = make_AZstatement((yyvsp[0].inline_definition_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6197 "Parser.c"
    break;

  case 333: /* BASIC_STATEMENT: ASSIGNMENT _SYMB_16  */
#line 1077 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_ABbasicStatementAssignment((yyvsp[-1].assignment_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6203 "Parser.c"
    break;

  case 334: /* BASIC_STATEMENT: LABEL_DEFINITION BASIC_STATEMENT  */
#line 1078 "HAL_S.y"
                                     { (yyval.basic_statement_) = make_AAbasic_statement((yyvsp[-1].label_definition_), (yyvsp[0].basic_statement_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6209 "Parser.c"
    break;

  case 335: /* BASIC_STATEMENT: _SYMB_81 _SYMB_16  */
#line 1079 "HAL_S.y"
                      { (yyval.basic_statement_) = make_ACbasicStatementExit(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6215 "Parser.c"
    break;

  case 336: /* BASIC_STATEMENT: _SYMB_81 LABEL _SYMB_16  */
#line 1080 "HAL_S.y"
                            { (yyval.basic_statement_) = make_ADbasicStatementExit((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6221 "Parser.c"
    break;

  case 337: /* BASIC_STATEMENT: _SYMB_132 _SYMB_16  */
#line 1081 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AEbasicStatementRepeat(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6227 "Parser.c"
    break;

  case 338: /* BASIC_STATEMENT: _SYMB_132 LABEL _SYMB_16  */
#line 1082 "HAL_S.y"
                             { (yyval.basic_statement_) = make_AFbasicStatementRepeat((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6233 "Parser.c"
    break;

  case 339: /* BASIC_STATEMENT: _SYMB_89 _SYMB_167 LABEL _SYMB_16  */
#line 1083 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AGbasicStatementGoTo((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6239 "Parser.c"
    break;

  case 340: /* BASIC_STATEMENT: _SYMB_16  */
#line 1084 "HAL_S.y"
             { (yyval.basic_statement_) = make_AHbasicStatementEmpty(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6245 "Parser.c"
    break;

  case 341: /* BASIC_STATEMENT: CALL_KEY _SYMB_16  */
#line 1085 "HAL_S.y"
                      { (yyval.basic_statement_) = make_AIbasicStatementCall((yyvsp[-1].call_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6251 "Parser.c"
    break;

  case 342: /* BASIC_STATEMENT: CALL_KEY _SYMB_2 CALL_LIST _SYMB_1 _SYMB_16  */
#line 1086 "HAL_S.y"
                                                { (yyval.basic_statement_) = make_AJbasicStatementCall((yyvsp[-4].call_key_), (yyvsp[-2].call_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6257 "Parser.c"
    break;

  case 343: /* BASIC_STATEMENT: CALL_KEY ASSIGN _SYMB_2 CALL_ASSIGN_LIST _SYMB_1 _SYMB_16  */
#line 1087 "HAL_S.y"
                                                              { (yyval.basic_statement_) = make_AKbasicStatementCall((yyvsp[-5].call_key_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6263 "Parser.c"
    break;

  case 344: /* BASIC_STATEMENT: CALL_KEY _SYMB_2 CALL_LIST _SYMB_1 ASSIGN _SYMB_2 CALL_ASSIGN_LIST _SYMB_1 _SYMB_16  */
#line 1088 "HAL_S.y"
                                                                                        { (yyval.basic_statement_) = make_ALbasicStatementCall((yyvsp[-8].call_key_), (yyvsp[-6].call_list_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6269 "Parser.c"
    break;

  case 345: /* BASIC_STATEMENT: _SYMB_135 _SYMB_16  */
#line 1089 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AMbasicStatementReturn(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6275 "Parser.c"
    break;

  case 346: /* BASIC_STATEMENT: _SYMB_135 EXPRESSION _SYMB_16  */
#line 1090 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_ANbasicStatementReturn((yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6281 "Parser.c"
    break;

  case 347: /* BASIC_STATEMENT: DO_GROUP_HEAD ENDING _SYMB_16  */
#line 1091 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_AObasicStatementDo((yyvsp[-2].do_group_head_), (yyvsp[-1].ending_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6287 "Parser.c"
    break;

  case 348: /* BASIC_STATEMENT: READ_KEY _SYMB_16  */
#line 1092 "HAL_S.y"
                      { (yyval.basic_statement_) = make_APbasicStatementReadKey((yyvsp[-1].read_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6293 "Parser.c"
    break;

  case 349: /* BASIC_STATEMENT: READ_PHRASE _SYMB_16  */
#line 1093 "HAL_S.y"
                         { (yyval.basic_statement_) = make_AQbasicStatementReadPhrase((yyvsp[-1].read_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6299 "Parser.c"
    break;

  case 350: /* BASIC_STATEMENT: WRITE_KEY _SYMB_16  */
#line 1094 "HAL_S.y"
                       { (yyval.basic_statement_) = make_ARbasicStatementWriteKey((yyvsp[-1].write_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6305 "Parser.c"
    break;

  case 351: /* BASIC_STATEMENT: WRITE_PHRASE _SYMB_16  */
#line 1095 "HAL_S.y"
                          { (yyval.basic_statement_) = make_ASbasicStatementWritePhrase((yyvsp[-1].write_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6311 "Parser.c"
    break;

  case 352: /* BASIC_STATEMENT: FILE_EXP EQUALS EXPRESSION _SYMB_16  */
#line 1096 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_ATbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6317 "Parser.c"
    break;

  case 353: /* BASIC_STATEMENT: VARIABLE EQUALS FILE_EXP _SYMB_16  */
#line 1097 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AUbasicStatementFileExp((yyvsp[-3].variable_), (yyvsp[-2].equals_), (yyvsp[-1].file_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6323 "Parser.c"
    break;

  case 354: /* BASIC_STATEMENT: FILE_EXP EQUALS QUAL_STRUCT _SYMB_16  */
#line 1098 "HAL_S.y"
                                         { (yyval.basic_statement_) = make_AVbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].qual_struct_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6329 "Parser.c"
    break;

  case 355: /* BASIC_STATEMENT: WAIT_KEY _SYMB_87 _SYMB_67 _SYMB_16  */
#line 1099 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_AVbasicStatementWait((yyvsp[-3].wait_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6335 "Parser.c"
    break;

  case 356: /* BASIC_STATEMENT: WAIT_KEY ARITH_EXP _SYMB_16  */
#line 1100 "HAL_S.y"
                                { (yyval.basic_statement_) = make_AWbasicStatementWait((yyvsp[-2].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6341 "Parser.c"
    break;

  case 357: /* BASIC_STATEMENT: WAIT_KEY _SYMB_174 ARITH_EXP _SYMB_16  */
#line 1101 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_AXbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6347 "Parser.c"
    break;

  case 358: /* BASIC_STATEMENT: WAIT_KEY _SYMB_87 BIT_EXP _SYMB_16  */
#line 1102 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_AYbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].bit_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6353 "Parser.c"
    break;

  case 359: /* BASIC_STATEMENT: TERMINATOR _SYMB_16  */
#line 1103 "HAL_S.y"
                        { (yyval.basic_statement_) = make_AZbasicStatementTerminator((yyvsp[-1].terminator_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6359 "Parser.c"
    break;

  case 360: /* BASIC_STATEMENT: TERMINATOR TERMINATE_LIST _SYMB_16  */
#line 1104 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_BAbasicStatementTerminator((yyvsp[-2].terminator_), (yyvsp[-1].terminate_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6365 "Parser.c"
    break;

  case 361: /* BASIC_STATEMENT: _SYMB_175 _SYMB_121 _SYMB_167 ARITH_EXP _SYMB_16  */
#line 1105 "HAL_S.y"
                                                     { (yyval.basic_statement_) = make_BBbasicStatementUpdate((yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6371 "Parser.c"
    break;

  case 362: /* BASIC_STATEMENT: _SYMB_175 _SYMB_121 LABEL_VAR _SYMB_167 ARITH_EXP _SYMB_16  */
#line 1106 "HAL_S.y"
                                                               { (yyval.basic_statement_) = make_BCbasicStatementUpdate((yyvsp[-3].label_var_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6377 "Parser.c"
    break;

  case 363: /* BASIC_STATEMENT: SCHEDULE_PHRASE _SYMB_16  */
#line 1107 "HAL_S.y"
                             { (yyval.basic_statement_) = make_BDbasicStatementSchedule((yyvsp[-1].schedule_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6383 "Parser.c"
    break;

  case 364: /* BASIC_STATEMENT: SCHEDULE_PHRASE SCHEDULE_CONTROL _SYMB_16  */
#line 1108 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BEbasicStatementSchedule((yyvsp[-2].schedule_phrase_), (yyvsp[-1].schedule_control_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6389 "Parser.c"
    break;

  case 365: /* BASIC_STATEMENT: SIGNAL_CLAUSE _SYMB_16  */
#line 1109 "HAL_S.y"
                           { (yyval.basic_statement_) = make_BFbasicStatementSignal((yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6395 "Parser.c"
    break;

  case 366: /* BASIC_STATEMENT: _SYMB_142 _SYMB_77 SUBSCRIPT _SYMB_16  */
#line 1110 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BGbasicStatementSend((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6401 "Parser.c"
    break;

  case 367: /* BASIC_STATEMENT: _SYMB_142 _SYMB_77 _SYMB_16  */
#line 1111 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BHbasicStatementSend(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6407 "Parser.c"
    break;

  case 368: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_16  */
#line 1112 "HAL_S.y"
                       { (yyval.basic_statement_) = make_BHbasicStatementOn((yyvsp[-1].on_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6413 "Parser.c"
    break;

  case 369: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_33 SIGNAL_CLAUSE _SYMB_16  */
#line 1113 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BIbasicStatementOnAndSignal((yyvsp[-3].on_clause_), (yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6419 "Parser.c"
    break;

  case 370: /* BASIC_STATEMENT: _SYMB_116 _SYMB_77 SUBSCRIPT _SYMB_16  */
#line 1114 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BJbasicStatementOff((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6425 "Parser.c"
    break;

  case 371: /* BASIC_STATEMENT: _SYMB_116 _SYMB_77 _SYMB_16  */
#line 1115 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementOff(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6431 "Parser.c"
    break;

  case 372: /* BASIC_STATEMENT: PERCENT_MACRO_NAME _SYMB_16  */
#line 1116 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementPercentMacro((yyvsp[-1].percent_macro_name_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6437 "Parser.c"
    break;

  case 373: /* BASIC_STATEMENT: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_1 _SYMB_16  */
#line 1117 "HAL_S.y"
                                                          { (yyval.basic_statement_) = make_BLbasicStatementPercentMacro((yyvsp[-3].percent_macro_head_), (yyvsp[-2].percent_macro_arg_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6443 "Parser.c"
    break;

  case 374: /* OTHER_STATEMENT: IF_STATEMENT  */
#line 1119 "HAL_S.y"
                               { (yyval.other_statement_) = make_ABotherStatementIf((yyvsp[0].if_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6449 "Parser.c"
    break;

  case 375: /* OTHER_STATEMENT: ON_PHRASE STATEMENT  */
#line 1120 "HAL_S.y"
                        { (yyval.other_statement_) = make_AAotherStatementOn((yyvsp[-1].on_phrase_), (yyvsp[0].statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6455 "Parser.c"
    break;

  case 376: /* OTHER_STATEMENT: LABEL_DEFINITION OTHER_STATEMENT  */
#line 1121 "HAL_S.y"
                                     { (yyval.other_statement_) = make_ACother_statement((yyvsp[-1].label_definition_), (yyvsp[0].other_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6461 "Parser.c"
    break;

  case 377: /* ANY_STATEMENT: STATEMENT  */
#line 1123 "HAL_S.y"
                          { (yyval.any_statement_) = make_AAany_statement((yyvsp[0].statement_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6467 "Parser.c"
    break;

  case 378: /* ANY_STATEMENT: BLOCK_DEFINITION  */
#line 1124 "HAL_S.y"
                     { (yyval.any_statement_) = make_ABany_statement((yyvsp[0].block_definition_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6473 "Parser.c"
    break;

  case 379: /* ON_PHRASE: _SYMB_117 _SYMB_77 SUBSCRIPT  */
#line 1126 "HAL_S.y"
                                         { (yyval.on_phrase_) = make_AAon_phrase((yyvsp[0].subscript_)); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6479 "Parser.c"
    break;

  case 380: /* ON_PHRASE: _SYMB_117 _SYMB_77  */
#line 1127 "HAL_S.y"
                       { (yyval.on_phrase_) = make_ACon_phrase(); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6485 "Parser.c"
    break;

  case 381: /* ON_CLAUSE: _SYMB_117 _SYMB_77 SUBSCRIPT _SYMB_159  */
#line 1129 "HAL_S.y"
                                                   { (yyval.on_clause_) = make_AAon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6491 "Parser.c"
    break;

  case 382: /* ON_CLAUSE: _SYMB_117 _SYMB_77 SUBSCRIPT _SYMB_92  */
#line 1130 "HAL_S.y"
                                          { (yyval.on_clause_) = make_ABon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6497 "Parser.c"
    break;

  case 383: /* ON_CLAUSE: _SYMB_117 _SYMB_77 _SYMB_159  */
#line 1131 "HAL_S.y"
                                 { (yyval.on_clause_) = make_ADon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6503 "Parser.c"
    break;

  case 384: /* ON_CLAUSE: _SYMB_117 _SYMB_77 _SYMB_92  */
#line 1132 "HAL_S.y"
                                { (yyval.on_clause_) = make_AEon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6509 "Parser.c"
    break;

  case 385: /* LABEL_DEFINITION: LABEL _SYMB_17  */
#line 1134 "HAL_S.y"
                                  { (yyval.label_definition_) = make_AAlabel_definition((yyvsp[-1].label_)); (yyval.label_definition_)->line_number = (yyloc).first_line; (yyval.label_definition_)->char_number = (yyloc).first_column;  }
#line 6515 "Parser.c"
    break;

  case 386: /* CALL_KEY: _SYMB_49 LABEL_VAR  */
#line 1136 "HAL_S.y"
                              { (yyval.call_key_) = make_AAcall_key((yyvsp[0].label_var_)); (yyval.call_key_)->line_number = (yyloc).first_line; (yyval.call_key_)->char_number = (yyloc).first_column;  }
#line 6521 "Parser.c"
    break;

  case 387: /* ASSIGN: _SYMB_42  */
#line 1138 "HAL_S.y"
                  { (yyval.assign_) = make_AAassign(); (yyval.assign_)->line_number = (yyloc).first_line; (yyval.assign_)->char_number = (yyloc).first_column;  }
#line 6527 "Parser.c"
    break;

  case 388: /* CALL_ASSIGN_LIST: VARIABLE  */
#line 1140 "HAL_S.y"
                            { (yyval.call_assign_list_) = make_AAcall_assign_list((yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6533 "Parser.c"
    break;

  case 389: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_0 VARIABLE  */
#line 1141 "HAL_S.y"
                                      { (yyval.call_assign_list_) = make_ABcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6539 "Parser.c"
    break;

  case 390: /* CALL_ASSIGN_LIST: QUAL_STRUCT  */
#line 1142 "HAL_S.y"
                { (yyval.call_assign_list_) = make_ACcall_assign_list((yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6545 "Parser.c"
    break;

  case 391: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_0 QUAL_STRUCT  */
#line 1143 "HAL_S.y"
                                         { (yyval.call_assign_list_) = make_ADcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6551 "Parser.c"
    break;

  case 392: /* DO_GROUP_HEAD: _SYMB_70 _SYMB_16  */
#line 1145 "HAL_S.y"
                                  { (yyval.do_group_head_) = make_AAdoGroupHead(); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6557 "Parser.c"
    break;

  case 393: /* DO_GROUP_HEAD: _SYMB_70 FOR_LIST _SYMB_16  */
#line 1146 "HAL_S.y"
                               { (yyval.do_group_head_) = make_ABdoGroupHeadFor((yyvsp[-1].for_list_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6563 "Parser.c"
    break;

  case 394: /* DO_GROUP_HEAD: _SYMB_70 FOR_LIST WHILE_CLAUSE _SYMB_16  */
#line 1147 "HAL_S.y"
                                            { (yyval.do_group_head_) = make_ACdoGroupHeadForWhile((yyvsp[-2].for_list_), (yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6569 "Parser.c"
    break;

  case 395: /* DO_GROUP_HEAD: _SYMB_70 WHILE_CLAUSE _SYMB_16  */
#line 1148 "HAL_S.y"
                                   { (yyval.do_group_head_) = make_ADdoGroupHeadWhile((yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6575 "Parser.c"
    break;

  case 396: /* DO_GROUP_HEAD: _SYMB_70 _SYMB_51 ARITH_EXP _SYMB_16  */
#line 1149 "HAL_S.y"
                                         { (yyval.do_group_head_) = make_AEdoGroupHeadCase((yyvsp[-1].arith_exp_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6581 "Parser.c"
    break;

  case 397: /* DO_GROUP_HEAD: CASE_ELSE STATEMENT  */
#line 1150 "HAL_S.y"
                        { (yyval.do_group_head_) = make_AFdoGroupHeadCaseElse((yyvsp[-1].case_else_), (yyvsp[0].statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6587 "Parser.c"
    break;

  case 398: /* DO_GROUP_HEAD: DO_GROUP_HEAD ANY_STATEMENT  */
#line 1151 "HAL_S.y"
                                { (yyval.do_group_head_) = make_AGdoGroupHeadStatement((yyvsp[-1].do_group_head_), (yyvsp[0].any_statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6593 "Parser.c"
    break;

  case 399: /* DO_GROUP_HEAD: DO_GROUP_HEAD TEMPORARY_STMT  */
#line 1152 "HAL_S.y"
                                 { (yyval.do_group_head_) = make_AHdoGroupHeadTemporaryStatement((yyvsp[-1].do_group_head_), (yyvsp[0].temporary_stmt_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6599 "Parser.c"
    break;

  case 400: /* ENDING: _SYMB_73  */
#line 1154 "HAL_S.y"
                  { (yyval.ending_) = make_AAending(); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6605 "Parser.c"
    break;

  case 401: /* ENDING: _SYMB_73 LABEL  */
#line 1155 "HAL_S.y"
                   { (yyval.ending_) = make_ABending((yyvsp[0].label_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6611 "Parser.c"
    break;

  case 402: /* ENDING: LABEL_DEFINITION ENDING  */
#line 1156 "HAL_S.y"
                            { (yyval.ending_) = make_ACending((yyvsp[-1].label_definition_), (yyvsp[0].ending_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6617 "Parser.c"
    break;

  case 403: /* READ_KEY: _SYMB_127 _SYMB_2 NUMBER _SYMB_1  */
#line 1158 "HAL_S.y"
                                            { (yyval.read_key_) = make_AAread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 6623 "Parser.c"
    break;

  case 404: /* READ_KEY: _SYMB_128 _SYMB_2 NUMBER _SYMB_1  */
#line 1159 "HAL_S.y"
                                     { (yyval.read_key_) = make_ABread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 6629 "Parser.c"
    break;

  case 405: /* WRITE_KEY: _SYMB_179 _SYMB_2 NUMBER _SYMB_1  */
#line 1161 "HAL_S.y"
                                             { (yyval.write_key_) = make_AAwrite_key((yyvsp[-1].number_)); (yyval.write_key_)->line_number = (yyloc).first_line; (yyval.write_key_)->char_number = (yyloc).first_column;  }
#line 6635 "Parser.c"
    break;

  case 406: /* READ_PHRASE: READ_KEY READ_ARG  */
#line 1163 "HAL_S.y"
                                { (yyval.read_phrase_) = make_AAread_phrase((yyvsp[-1].read_key_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 6641 "Parser.c"
    break;

  case 407: /* READ_PHRASE: READ_PHRASE _SYMB_0 READ_ARG  */
#line 1164 "HAL_S.y"
                                 { (yyval.read_phrase_) = make_ABread_phrase((yyvsp[-2].read_phrase_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 6647 "Parser.c"
    break;

  case 408: /* WRITE_PHRASE: WRITE_KEY WRITE_ARG  */
#line 1166 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_AAwrite_phrase((yyvsp[-1].write_key_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 6653 "Parser.c"
    break;

  case 409: /* WRITE_PHRASE: WRITE_PHRASE _SYMB_0 WRITE_ARG  */
#line 1167 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_ABwrite_phrase((yyvsp[-2].write_phrase_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 6659 "Parser.c"
    break;

  case 410: /* READ_ARG: VARIABLE  */
#line 1169 "HAL_S.y"
                    { (yyval.read_arg_) = make_AAread_arg((yyvsp[0].variable_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 6665 "Parser.c"
    break;

  case 411: /* READ_ARG: IO_CONTROL  */
#line 1170 "HAL_S.y"
               { (yyval.read_arg_) = make_ABread_arg((yyvsp[0].io_control_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 6671 "Parser.c"
    break;

  case 412: /* WRITE_ARG: EXPRESSION  */
#line 1172 "HAL_S.y"
                       { (yyval.write_arg_) = make_AAwrite_arg((yyvsp[0].expression_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6677 "Parser.c"
    break;

  case 413: /* WRITE_ARG: IO_CONTROL  */
#line 1173 "HAL_S.y"
               { (yyval.write_arg_) = make_ABwrite_arg((yyvsp[0].io_control_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6683 "Parser.c"
    break;

  case 414: /* WRITE_ARG: _SYMB_188  */
#line 1174 "HAL_S.y"
              { (yyval.write_arg_) = make_ACwrite_arg((yyvsp[0].string_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6689 "Parser.c"
    break;

  case 415: /* FILE_EXP: FILE_HEAD _SYMB_0 ARITH_EXP _SYMB_1  */
#line 1176 "HAL_S.y"
                                               { (yyval.file_exp_) = make_AAfile_exp((yyvsp[-3].file_head_), (yyvsp[-1].arith_exp_)); (yyval.file_exp_)->line_number = (yyloc).first_line; (yyval.file_exp_)->char_number = (yyloc).first_column;  }
#line 6695 "Parser.c"
    break;

  case 416: /* FILE_HEAD: _SYMB_85 _SYMB_2 NUMBER  */
#line 1178 "HAL_S.y"
                                    { (yyval.file_head_) = make_AAfile_head((yyvsp[0].number_)); (yyval.file_head_)->line_number = (yyloc).first_line; (yyval.file_head_)->char_number = (yyloc).first_column;  }
#line 6701 "Parser.c"
    break;

  case 417: /* IO_CONTROL: _SYMB_153 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1180 "HAL_S.y"
                                                 { (yyval.io_control_) = make_AAioControlSkip((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6707 "Parser.c"
    break;

  case 418: /* IO_CONTROL: _SYMB_160 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1181 "HAL_S.y"
                                        { (yyval.io_control_) = make_ABioControlTab((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6713 "Parser.c"
    break;

  case 419: /* IO_CONTROL: _SYMB_58 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1182 "HAL_S.y"
                                       { (yyval.io_control_) = make_ACioControlColumn((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6719 "Parser.c"
    break;

  case 420: /* IO_CONTROL: _SYMB_100 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1183 "HAL_S.y"
                                        { (yyval.io_control_) = make_ADioControlLine((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6725 "Parser.c"
    break;

  case 421: /* IO_CONTROL: _SYMB_119 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1184 "HAL_S.y"
                                        { (yyval.io_control_) = make_AEioControlPage((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6731 "Parser.c"
    break;

  case 422: /* WAIT_KEY: _SYMB_177  */
#line 1186 "HAL_S.y"
                     { (yyval.wait_key_) = make_AAwait_key(); (yyval.wait_key_)->line_number = (yyloc).first_line; (yyval.wait_key_)->char_number = (yyloc).first_column;  }
#line 6737 "Parser.c"
    break;

  case 423: /* TERMINATOR: _SYMB_165  */
#line 1188 "HAL_S.y"
                       { (yyval.terminator_) = make_AAterminatorTerminate(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 6743 "Parser.c"
    break;

  case 424: /* TERMINATOR: _SYMB_50  */
#line 1189 "HAL_S.y"
             { (yyval.terminator_) = make_ABterminatorCancel(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 6749 "Parser.c"
    break;

  case 425: /* TERMINATE_LIST: LABEL_VAR  */
#line 1191 "HAL_S.y"
                           { (yyval.terminate_list_) = make_AAterminate_list((yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 6755 "Parser.c"
    break;

  case 426: /* TERMINATE_LIST: TERMINATE_LIST _SYMB_0 LABEL_VAR  */
#line 1192 "HAL_S.y"
                                     { (yyval.terminate_list_) = make_ABterminate_list((yyvsp[-2].terminate_list_), (yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 6761 "Parser.c"
    break;

  case 427: /* SCHEDULE_HEAD: _SYMB_141 LABEL_VAR  */
#line 1194 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_AAscheduleHeadLabel((yyvsp[0].label_var_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6767 "Parser.c"
    break;

  case 428: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_43 ARITH_EXP  */
#line 1195 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ABscheduleHeadAt((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6773 "Parser.c"
    break;

  case 429: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_93 ARITH_EXP  */
#line 1196 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ACscheduleHeadIn((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6779 "Parser.c"
    break;

  case 430: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_117 BIT_EXP  */
#line 1197 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_ADscheduleHeadOn((yyvsp[-2].schedule_head_), (yyvsp[0].bit_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6785 "Parser.c"
    break;

  case 431: /* SCHEDULE_PHRASE: SCHEDULE_HEAD  */
#line 1199 "HAL_S.y"
                                { (yyval.schedule_phrase_) = make_AAschedule_phrase((yyvsp[0].schedule_head_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6791 "Parser.c"
    break;

  case 432: /* SCHEDULE_PHRASE: SCHEDULE_HEAD _SYMB_121 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1200 "HAL_S.y"
                                                      { (yyval.schedule_phrase_) = make_ABschedule_phrase((yyvsp[-4].schedule_head_), (yyvsp[-1].arith_exp_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6797 "Parser.c"
    break;

  case 433: /* SCHEDULE_PHRASE: SCHEDULE_PHRASE _SYMB_67  */
#line 1201 "HAL_S.y"
                             { (yyval.schedule_phrase_) = make_ACschedule_phrase((yyvsp[-1].schedule_phrase_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6803 "Parser.c"
    break;

  case 434: /* SCHEDULE_CONTROL: STOPPING  */
#line 1203 "HAL_S.y"
                            { (yyval.schedule_control_) = make_AAschedule_control((yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6809 "Parser.c"
    break;

  case 435: /* SCHEDULE_CONTROL: TIMING  */
#line 1204 "HAL_S.y"
           { (yyval.schedule_control_) = make_ABschedule_control((yyvsp[0].timing_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6815 "Parser.c"
    break;

  case 436: /* SCHEDULE_CONTROL: TIMING STOPPING  */
#line 1205 "HAL_S.y"
                    { (yyval.schedule_control_) = make_ACschedule_control((yyvsp[-1].timing_), (yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6821 "Parser.c"
    break;

  case 437: /* TIMING: REPEAT _SYMB_79 ARITH_EXP  */
#line 1207 "HAL_S.y"
                                   { (yyval.timing_) = make_AAtimingEvery((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6827 "Parser.c"
    break;

  case 438: /* TIMING: REPEAT _SYMB_31 ARITH_EXP  */
#line 1208 "HAL_S.y"
                              { (yyval.timing_) = make_ABtimingAfter((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6833 "Parser.c"
    break;

  case 439: /* TIMING: REPEAT  */
#line 1209 "HAL_S.y"
           { (yyval.timing_) = make_ACtiming((yyvsp[0].repeat_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6839 "Parser.c"
    break;

  case 440: /* REPEAT: _SYMB_0 _SYMB_132  */
#line 1211 "HAL_S.y"
                           { (yyval.repeat_) = make_AArepeat(); (yyval.repeat_)->line_number = (yyloc).first_line; (yyval.repeat_)->char_number = (yyloc).first_column;  }
#line 6845 "Parser.c"
    break;

  case 441: /* STOPPING: WHILE_KEY ARITH_EXP  */
#line 1213 "HAL_S.y"
                               { (yyval.stopping_) = make_AAstopping((yyvsp[-1].while_key_), (yyvsp[0].arith_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 6851 "Parser.c"
    break;

  case 442: /* STOPPING: WHILE_KEY BIT_EXP  */
#line 1214 "HAL_S.y"
                      { (yyval.stopping_) = make_ABstopping((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 6857 "Parser.c"
    break;

  case 443: /* SIGNAL_CLAUSE: _SYMB_143 EVENT_VAR  */
#line 1216 "HAL_S.y"
                                    { (yyval.signal_clause_) = make_AAsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6863 "Parser.c"
    break;

  case 444: /* SIGNAL_CLAUSE: _SYMB_134 EVENT_VAR  */
#line 1217 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ABsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6869 "Parser.c"
    break;

  case 445: /* SIGNAL_CLAUSE: _SYMB_147 EVENT_VAR  */
#line 1218 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ACsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6875 "Parser.c"
    break;

  case 446: /* PERCENT_MACRO_NAME: _SYMB_27 IDENTIFIER  */
#line 1220 "HAL_S.y"
                                         { (yyval.percent_macro_name_) = make_FNpercent_macro_name((yyvsp[0].identifier_)); (yyval.percent_macro_name_)->line_number = (yyloc).first_line; (yyval.percent_macro_name_)->char_number = (yyloc).first_column;  }
#line 6881 "Parser.c"
    break;

  case 447: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_NAME _SYMB_2  */
#line 1222 "HAL_S.y"
                                                { (yyval.percent_macro_head_) = make_AApercent_macro_head((yyvsp[-1].percent_macro_name_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 6887 "Parser.c"
    break;

  case 448: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_0  */
#line 1223 "HAL_S.y"
                                                 { (yyval.percent_macro_head_) = make_ABpercent_macro_head((yyvsp[-2].percent_macro_head_), (yyvsp[-1].percent_macro_arg_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 6893 "Parser.c"
    break;

  case 449: /* PERCENT_MACRO_ARG: NAME_VAR  */
#line 1225 "HAL_S.y"
                             { (yyval.percent_macro_arg_) = make_AApercent_macro_arg((yyvsp[0].name_var_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 6899 "Parser.c"
    break;

  case 450: /* PERCENT_MACRO_ARG: CONSTANT  */
#line 1226 "HAL_S.y"
             { (yyval.percent_macro_arg_) = make_ABpercent_macro_arg((yyvsp[0].constant_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 6905 "Parser.c"
    break;

  case 451: /* CASE_ELSE: _SYMB_70 _SYMB_51 ARITH_EXP _SYMB_16 _SYMB_72  */
#line 1228 "HAL_S.y"
                                                          { (yyval.case_else_) = make_AAcase_else((yyvsp[-2].arith_exp_)); (yyval.case_else_)->line_number = (yyloc).first_line; (yyval.case_else_)->char_number = (yyloc).first_column;  }
#line 6911 "Parser.c"
    break;

  case 452: /* WHILE_KEY: _SYMB_178  */
#line 1230 "HAL_S.y"
                      { (yyval.while_key_) = make_AAwhileKeyWhile(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 6917 "Parser.c"
    break;

  case 453: /* WHILE_KEY: _SYMB_174  */
#line 1231 "HAL_S.y"
              { (yyval.while_key_) = make_ABwhileKeyUntil(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 6923 "Parser.c"
    break;

  case 454: /* WHILE_CLAUSE: WHILE_KEY BIT_EXP  */
#line 1233 "HAL_S.y"
                                 { (yyval.while_clause_) = make_AAwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 6929 "Parser.c"
    break;

  case 455: /* WHILE_CLAUSE: WHILE_KEY RELATIONAL_EXP  */
#line 1234 "HAL_S.y"
                             { (yyval.while_clause_) = make_ABwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].relational_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 6935 "Parser.c"
    break;

  case 456: /* FOR_LIST: FOR_KEY ARITH_EXP ITERATION_CONTROL  */
#line 1236 "HAL_S.y"
                                               { (yyval.for_list_) = make_AAfor_list((yyvsp[-2].for_key_), (yyvsp[-1].arith_exp_), (yyvsp[0].iteration_control_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 6941 "Parser.c"
    break;

  case 457: /* FOR_LIST: FOR_KEY ITERATION_BODY  */
#line 1237 "HAL_S.y"
                           { (yyval.for_list_) = make_ABfor_list((yyvsp[-1].for_key_), (yyvsp[0].iteration_body_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 6947 "Parser.c"
    break;

  case 458: /* ITERATION_BODY: ARITH_EXP  */
#line 1239 "HAL_S.y"
                           { (yyval.iteration_body_) = make_AAiteration_body((yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 6953 "Parser.c"
    break;

  case 459: /* ITERATION_BODY: ITERATION_BODY _SYMB_0 ARITH_EXP  */
#line 1240 "HAL_S.y"
                                     { (yyval.iteration_body_) = make_ABiteration_body((yyvsp[-2].iteration_body_), (yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 6959 "Parser.c"
    break;

  case 460: /* ITERATION_CONTROL: _SYMB_167 ARITH_EXP  */
#line 1242 "HAL_S.y"
                                        { (yyval.iteration_control_) = make_AAiteration_controlTo((yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 6965 "Parser.c"
    break;

  case 461: /* ITERATION_CONTROL: _SYMB_167 ARITH_EXP _SYMB_48 ARITH_EXP  */
#line 1243 "HAL_S.y"
                                           { (yyval.iteration_control_) = make_ABiteration_controlToBy((yyvsp[-2].arith_exp_), (yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 6971 "Parser.c"
    break;

  case 462: /* FOR_KEY: _SYMB_87 ARITH_VAR EQUALS  */
#line 1245 "HAL_S.y"
                                    { (yyval.for_key_) = make_AAforKey((yyvsp[-1].arith_var_), (yyvsp[0].equals_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 6977 "Parser.c"
    break;

  case 463: /* FOR_KEY: _SYMB_87 _SYMB_164 IDENTIFIER _SYMB_25  */
#line 1246 "HAL_S.y"
                                           { (yyval.for_key_) = make_ABforKeyTemporary((yyvsp[-1].identifier_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 6983 "Parser.c"
    break;

  case 464: /* TEMPORARY_STMT: _SYMB_164 DECLARE_BODY _SYMB_16  */
#line 1248 "HAL_S.y"
                                                 { (yyval.temporary_stmt_) = make_AAtemporary_stmt((yyvsp[-1].declare_body_)); (yyval.temporary_stmt_)->line_number = (yyloc).first_line; (yyval.temporary_stmt_)->char_number = (yyloc).first_column;  }
#line 6989 "Parser.c"
    break;

  case 465: /* CONSTANT: NUMBER  */
#line 1250 "HAL_S.y"
                  { (yyval.constant_) = make_AAconstant((yyvsp[0].number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6995 "Parser.c"
    break;

  case 466: /* CONSTANT: COMPOUND_NUMBER  */
#line 1251 "HAL_S.y"
                    { (yyval.constant_) = make_ABconstant((yyvsp[0].compound_number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 7001 "Parser.c"
    break;

  case 467: /* CONSTANT: BIT_CONST  */
#line 1252 "HAL_S.y"
              { (yyval.constant_) = make_ACconstant((yyvsp[0].bit_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 7007 "Parser.c"
    break;

  case 468: /* CONSTANT: CHAR_CONST  */
#line 1253 "HAL_S.y"
               { (yyval.constant_) = make_ADconstant((yyvsp[0].char_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 7013 "Parser.c"
    break;

  case 469: /* ARRAY_HEAD: _SYMB_41 _SYMB_2  */
#line 1255 "HAL_S.y"
                              { (yyval.array_head_) = make_AAarray_head(); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 7019 "Parser.c"
    break;

  case 470: /* ARRAY_HEAD: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_0  */
#line 1256 "HAL_S.y"
                                           { (yyval.array_head_) = make_ABarray_head((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 7025 "Parser.c"
    break;

  case 471: /* MINOR_ATTR_LIST: MINOR_ATTRIBUTE  */
#line 1258 "HAL_S.y"
                                  { (yyval.minor_attr_list_) = make_AAminor_attr_list((yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 7031 "Parser.c"
    break;

  case 472: /* MINOR_ATTR_LIST: MINOR_ATTR_LIST MINOR_ATTRIBUTE  */
#line 1259 "HAL_S.y"
                                    { (yyval.minor_attr_list_) = make_ABminor_attr_list((yyvsp[-1].minor_attr_list_), (yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 7037 "Parser.c"
    break;

  case 473: /* MINOR_ATTRIBUTE: _SYMB_155  */
#line 1261 "HAL_S.y"
                            { (yyval.minor_attribute_) = make_AAminorAttributeStatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7043 "Parser.c"
    break;

  case 474: /* MINOR_ATTRIBUTE: _SYMB_44  */
#line 1262 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ABminorAttributeAutomatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7049 "Parser.c"
    break;

  case 475: /* MINOR_ATTRIBUTE: _SYMB_66  */
#line 1263 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ACminorAttributeDense(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7055 "Parser.c"
    break;

  case 476: /* MINOR_ATTRIBUTE: _SYMB_32  */
#line 1264 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ADminorAttributeAligned(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7061 "Parser.c"
    break;

  case 477: /* MINOR_ATTRIBUTE: _SYMB_30  */
#line 1265 "HAL_S.y"
             { (yyval.minor_attribute_) = make_AEminorAttributeAccess(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7067 "Parser.c"
    break;

  case 478: /* MINOR_ATTRIBUTE: _SYMB_102 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1266 "HAL_S.y"
                                                  { (yyval.minor_attribute_) = make_AFminorAttributeLock((yyvsp[-1].literal_exp_or_star_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7073 "Parser.c"
    break;

  case 479: /* MINOR_ATTRIBUTE: _SYMB_131  */
#line 1267 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AGminorAttributeRemote(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7079 "Parser.c"
    break;

  case 480: /* MINOR_ATTRIBUTE: _SYMB_136  */
#line 1268 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AHminorAttributeRigid(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7085 "Parser.c"
    break;

  case 481: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_1  */
#line 1269 "HAL_S.y"
                                                 { (yyval.minor_attribute_) = make_AIminorAttributeRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7091 "Parser.c"
    break;

  case 482: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD _SYMB_6 _SYMB_1  */
#line 1270 "HAL_S.y"
                                       { (yyval.minor_attribute_) = make_AJminorAttributeStar((yyvsp[-2].init_or_const_head_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7097 "Parser.c"
    break;

  case 483: /* MINOR_ATTRIBUTE: _SYMB_98  */
#line 1271 "HAL_S.y"
             { (yyval.minor_attribute_) = make_AKminorAttributeLatched(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7103 "Parser.c"
    break;

  case 484: /* MINOR_ATTRIBUTE: _SYMB_111 _SYMB_2 LEVEL _SYMB_1  */
#line 1272 "HAL_S.y"
                                    { (yyval.minor_attribute_) = make_ALminorAttributeNonHal((yyvsp[-1].level_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7109 "Parser.c"
    break;

  case 485: /* INIT_OR_CONST_HEAD: _SYMB_95 _SYMB_2  */
#line 1274 "HAL_S.y"
                                      { (yyval.init_or_const_head_) = make_AAinit_or_const_headInitial(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7115 "Parser.c"
    break;

  case 486: /* INIT_OR_CONST_HEAD: _SYMB_60 _SYMB_2  */
#line 1275 "HAL_S.y"
                     { (yyval.init_or_const_head_) = make_ABinit_or_const_headConstant(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7121 "Parser.c"
    break;

  case 487: /* INIT_OR_CONST_HEAD: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_0  */
#line 1276 "HAL_S.y"
                                                 { (yyval.init_or_const_head_) = make_ACinit_or_const_headRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7127 "Parser.c"
    break;

  case 488: /* REPEATED_CONSTANT: EXPRESSION  */
#line 1278 "HAL_S.y"
                               { (yyval.repeated_constant_) = make_AArepeated_constant((yyvsp[0].expression_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7133 "Parser.c"
    break;

  case 489: /* REPEATED_CONSTANT: REPEAT_HEAD VARIABLE  */
#line 1279 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ABrepeated_constant((yyvsp[-1].repeat_head_), (yyvsp[0].variable_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7139 "Parser.c"
    break;

  case 490: /* REPEATED_CONSTANT: REPEAT_HEAD CONSTANT  */
#line 1280 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ACrepeated_constant((yyvsp[-1].repeat_head_), (yyvsp[0].constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7145 "Parser.c"
    break;

  case 491: /* REPEATED_CONSTANT: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_1  */
#line 1281 "HAL_S.y"
                                                 { (yyval.repeated_constant_) = make_ADrepeated_constant((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7151 "Parser.c"
    break;

  case 492: /* REPEATED_CONSTANT: REPEAT_HEAD  */
#line 1282 "HAL_S.y"
                { (yyval.repeated_constant_) = make_AErepeated_constant((yyvsp[0].repeat_head_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7157 "Parser.c"
    break;

  case 493: /* REPEAT_HEAD: ARITH_EXP _SYMB_9 SIMPLE_NUMBER  */
#line 1284 "HAL_S.y"
                                              { (yyval.repeat_head_) = make_AArepeat_head((yyvsp[-2].arith_exp_), (yyvsp[0].simple_number_)); (yyval.repeat_head_)->line_number = (yyloc).first_line; (yyval.repeat_head_)->char_number = (yyloc).first_column;  }
#line 7163 "Parser.c"
    break;

  case 494: /* NESTED_REPEAT_HEAD: REPEAT_HEAD _SYMB_2  */
#line 1286 "HAL_S.y"
                                         { (yyval.nested_repeat_head_) = make_AAnested_repeat_head((yyvsp[-1].repeat_head_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 7169 "Parser.c"
    break;

  case 495: /* NESTED_REPEAT_HEAD: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_0  */
#line 1287 "HAL_S.y"
                                                 { (yyval.nested_repeat_head_) = make_ABnested_repeat_head((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 7175 "Parser.c"
    break;

  case 496: /* DCL_LIST_COMMA: DECLARATION_LIST _SYMB_0  */
#line 1289 "HAL_S.y"
                                          { (yyval.dcl_list_comma_) = make_AAdcl_list_comma((yyvsp[-1].declaration_list_)); (yyval.dcl_list_comma_)->line_number = (yyloc).first_line; (yyval.dcl_list_comma_)->char_number = (yyloc).first_column;  }
#line 7181 "Parser.c"
    break;

  case 497: /* LITERAL_EXP_OR_STAR: ARITH_EXP  */
#line 1291 "HAL_S.y"
                                { (yyval.literal_exp_or_star_) = make_AAliteralExp((yyvsp[0].arith_exp_)); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7187 "Parser.c"
    break;

  case 498: /* LITERAL_EXP_OR_STAR: _SYMB_6  */
#line 1292 "HAL_S.y"
            { (yyval.literal_exp_or_star_) = make_ABliteralStar(); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7193 "Parser.c"
    break;

  case 499: /* TYPE_SPEC: STRUCT_SPEC  */
#line 1294 "HAL_S.y"
                        { (yyval.type_spec_) = make_AAtypeSpecStruct((yyvsp[0].struct_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7199 "Parser.c"
    break;

  case 500: /* TYPE_SPEC: BIT_SPEC  */
#line 1295 "HAL_S.y"
             { (yyval.type_spec_) = make_ABtypeSpecBit((yyvsp[0].bit_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7205 "Parser.c"
    break;

  case 501: /* TYPE_SPEC: CHAR_SPEC  */
#line 1296 "HAL_S.y"
              { (yyval.type_spec_) = make_ACtypeSpecChar((yyvsp[0].char_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7211 "Parser.c"
    break;

  case 502: /* TYPE_SPEC: ARITH_SPEC  */
#line 1297 "HAL_S.y"
               { (yyval.type_spec_) = make_ADtypeSpecArith((yyvsp[0].arith_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7217 "Parser.c"
    break;

  case 503: /* TYPE_SPEC: _SYMB_78  */
#line 1298 "HAL_S.y"
             { (yyval.type_spec_) = make_AEtypeSpecEvent(); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7223 "Parser.c"
    break;

  case 504: /* BIT_SPEC: _SYMB_47  */
#line 1300 "HAL_S.y"
                    { (yyval.bit_spec_) = make_AAbitSpecBoolean(); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7229 "Parser.c"
    break;

  case 505: /* BIT_SPEC: _SYMB_46 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1301 "HAL_S.y"
                                                 { (yyval.bit_spec_) = make_ABbitSpecBoolean((yyvsp[-1].literal_exp_or_star_)); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7235 "Parser.c"
    break;

  case 506: /* CHAR_SPEC: _SYMB_55 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1303 "HAL_S.y"
                                                         { (yyval.char_spec_) = make_AAchar_spec((yyvsp[-1].literal_exp_or_star_)); (yyval.char_spec_)->line_number = (yyloc).first_line; (yyval.char_spec_)->char_number = (yyloc).first_column;  }
#line 7241 "Parser.c"
    break;

  case 507: /* STRUCT_SPEC: STRUCT_TEMPLATE STRUCT_SPEC_BODY  */
#line 1305 "HAL_S.y"
                                               { (yyval.struct_spec_) = make_AAstruct_spec((yyvsp[-1].struct_template_), (yyvsp[0].struct_spec_body_)); (yyval.struct_spec_)->line_number = (yyloc).first_line; (yyval.struct_spec_)->char_number = (yyloc).first_column;  }
#line 7247 "Parser.c"
    break;

  case 508: /* STRUCT_SPEC_BODY: _SYMB_5 _SYMB_156  */
#line 1307 "HAL_S.y"
                                     { (yyval.struct_spec_body_) = make_AAstruct_spec_body(); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7253 "Parser.c"
    break;

  case 509: /* STRUCT_SPEC_BODY: STRUCT_SPEC_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1308 "HAL_S.y"
                                                 { (yyval.struct_spec_body_) = make_ABstruct_spec_body((yyvsp[-2].struct_spec_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7259 "Parser.c"
    break;

  case 510: /* STRUCT_TEMPLATE: STRUCTURE_ID  */
#line 1310 "HAL_S.y"
                               { (yyval.struct_template_) = make_FMstruct_template((yyvsp[0].structure_id_)); (yyval.struct_template_)->line_number = (yyloc).first_line; (yyval.struct_template_)->char_number = (yyloc).first_column;  }
#line 7265 "Parser.c"
    break;

  case 511: /* STRUCT_SPEC_HEAD: _SYMB_5 _SYMB_156 _SYMB_2  */
#line 1312 "HAL_S.y"
                                             { (yyval.struct_spec_head_) = make_AAstruct_spec_head(); (yyval.struct_spec_head_)->line_number = (yyloc).first_line; (yyval.struct_spec_head_)->char_number = (yyloc).first_column;  }
#line 7271 "Parser.c"
    break;

  case 512: /* ARITH_SPEC: PREC_SPEC  */
#line 1314 "HAL_S.y"
                       { (yyval.arith_spec_) = make_AAarith_spec((yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7277 "Parser.c"
    break;

  case 513: /* ARITH_SPEC: SQ_DQ_NAME  */
#line 1315 "HAL_S.y"
               { (yyval.arith_spec_) = make_ABarith_spec((yyvsp[0].sq_dq_name_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7283 "Parser.c"
    break;

  case 514: /* ARITH_SPEC: SQ_DQ_NAME PREC_SPEC  */
#line 1316 "HAL_S.y"
                         { (yyval.arith_spec_) = make_ACarith_spec((yyvsp[-1].sq_dq_name_), (yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7289 "Parser.c"
    break;

  case 515: /* COMPILATION: ANY_STATEMENT  */
#line 1318 "HAL_S.y"
                            { (yyval.compilation_) = make_AAcompilation((yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7295 "Parser.c"
    break;

  case 516: /* COMPILATION: COMPILATION ANY_STATEMENT  */
#line 1319 "HAL_S.y"
                              { (yyval.compilation_) = make_ABcompilation((yyvsp[-1].compilation_), (yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7301 "Parser.c"
    break;

  case 517: /* COMPILATION: DECLARE_STATEMENT  */
#line 1320 "HAL_S.y"
                      { (yyval.compilation_) = make_ACcompilation((yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7307 "Parser.c"
    break;

  case 518: /* COMPILATION: COMPILATION DECLARE_STATEMENT  */
#line 1321 "HAL_S.y"
                                  { (yyval.compilation_) = make_ADcompilation((yyvsp[-1].compilation_), (yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7313 "Parser.c"
    break;

  case 519: /* COMPILATION: STRUCTURE_STMT  */
#line 1322 "HAL_S.y"
                   { (yyval.compilation_) = make_AEcompilation((yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7319 "Parser.c"
    break;

  case 520: /* COMPILATION: COMPILATION STRUCTURE_STMT  */
#line 1323 "HAL_S.y"
                               { (yyval.compilation_) = make_AFcompilation((yyvsp[-1].compilation_), (yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7325 "Parser.c"
    break;

  case 521: /* COMPILATION: REPLACE_STMT _SYMB_16  */
#line 1324 "HAL_S.y"
                          { (yyval.compilation_) = make_AGcompilation((yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7331 "Parser.c"
    break;

  case 522: /* COMPILATION: COMPILATION REPLACE_STMT _SYMB_16  */
#line 1325 "HAL_S.y"
                                      { (yyval.compilation_) = make_AHcompilation((yyvsp[-2].compilation_), (yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7337 "Parser.c"
    break;

  case 523: /* COMPILATION: INIT_OR_CONST_HEAD EXPRESSION _SYMB_1  */
#line 1326 "HAL_S.y"
                                          { (yyval.compilation_) = make_AZcompilationInitOrConst((yyvsp[-2].init_or_const_head_), (yyvsp[-1].expression_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7343 "Parser.c"
    break;

  case 524: /* BLOCK_DEFINITION: BLOCK_STMT CLOSING _SYMB_16  */
#line 1328 "HAL_S.y"
                                               { (yyval.block_definition_) = make_AAblock_definition((yyvsp[-2].block_stmt_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7349 "Parser.c"
    break;

  case 525: /* BLOCK_DEFINITION: BLOCK_STMT BLOCK_BODY CLOSING _SYMB_16  */
#line 1329 "HAL_S.y"
                                           { (yyval.block_definition_) = make_ABblock_definition((yyvsp[-3].block_stmt_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7355 "Parser.c"
    break;

  case 526: /* BLOCK_STMT: BLOCK_STMT_TOP _SYMB_16  */
#line 1331 "HAL_S.y"
                                     { (yyval.block_stmt_) = make_AAblock_stmt((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_)->line_number = (yyloc).first_line; (yyval.block_stmt_)->char_number = (yyloc).first_column;  }
#line 7361 "Parser.c"
    break;

  case 527: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_30  */
#line 1333 "HAL_S.y"
                                         { (yyval.block_stmt_top_) = make_AAblockTopAccess((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7367 "Parser.c"
    break;

  case 528: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_136  */
#line 1334 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ABblockTopRigid((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7373 "Parser.c"
    break;

  case 529: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD  */
#line 1335 "HAL_S.y"
                    { (yyval.block_stmt_top_) = make_ACblockTopHead((yyvsp[0].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7379 "Parser.c"
    break;

  case 530: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_80  */
#line 1336 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ADblockTopExclusive((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7385 "Parser.c"
    break;

  case 531: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_129  */
#line 1337 "HAL_S.y"
                              { (yyval.block_stmt_top_) = make_AEblockTopReentrant((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7391 "Parser.c"
    break;

  case 532: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_124  */
#line 1339 "HAL_S.y"
                                           { (yyval.block_stmt_head_) = make_AAblockHeadProgram((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7397 "Parser.c"
    break;

  case 533: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_59  */
#line 1340 "HAL_S.y"
                            { (yyval.block_stmt_head_) = make_ABblockHeadCompool((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7403 "Parser.c"
    break;

  case 534: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_163  */
#line 1341 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ACblockHeadTask((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7409 "Parser.c"
    break;

  case 535: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_175  */
#line 1342 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ADblockHeadUpdate((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7415 "Parser.c"
    break;

  case 536: /* BLOCK_STMT_HEAD: _SYMB_175  */
#line 1343 "HAL_S.y"
              { (yyval.block_stmt_head_) = make_AEblockHeadUpdate(); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7421 "Parser.c"
    break;

  case 537: /* BLOCK_STMT_HEAD: FUNCTION_NAME  */
#line 1344 "HAL_S.y"
                  { (yyval.block_stmt_head_) = make_AFblockHeadFunction((yyvsp[0].function_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7427 "Parser.c"
    break;

  case 538: /* BLOCK_STMT_HEAD: FUNCTION_NAME FUNC_STMT_BODY  */
#line 1345 "HAL_S.y"
                                 { (yyval.block_stmt_head_) = make_AGblockHeadFunction((yyvsp[-1].function_name_), (yyvsp[0].func_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7433 "Parser.c"
    break;

  case 539: /* BLOCK_STMT_HEAD: PROCEDURE_NAME  */
#line 1346 "HAL_S.y"
                   { (yyval.block_stmt_head_) = make_AHblockHeadProcedure((yyvsp[0].procedure_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7439 "Parser.c"
    break;

  case 540: /* BLOCK_STMT_HEAD: PROCEDURE_NAME PROC_STMT_BODY  */
#line 1347 "HAL_S.y"
                                  { (yyval.block_stmt_head_) = make_AIblockHeadProcedure((yyvsp[-1].procedure_name_), (yyvsp[0].proc_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7445 "Parser.c"
    break;

  case 541: /* LABEL_EXTERNAL: LABEL_DEFINITION  */
#line 1349 "HAL_S.y"
                                  { (yyval.label_external_) = make_AAlabel_external((yyvsp[0].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7451 "Parser.c"
    break;

  case 542: /* LABEL_EXTERNAL: LABEL_DEFINITION _SYMB_83  */
#line 1350 "HAL_S.y"
                              { (yyval.label_external_) = make_ABlabel_external((yyvsp[-1].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7457 "Parser.c"
    break;

  case 543: /* CLOSING: _SYMB_57  */
#line 1352 "HAL_S.y"
                   { (yyval.closing_) = make_AAclosing(); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7463 "Parser.c"
    break;

  case 544: /* CLOSING: _SYMB_57 LABEL  */
#line 1353 "HAL_S.y"
                   { (yyval.closing_) = make_ABclosing((yyvsp[0].label_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7469 "Parser.c"
    break;

  case 545: /* CLOSING: LABEL_DEFINITION CLOSING  */
#line 1354 "HAL_S.y"
                             { (yyval.closing_) = make_ACclosing((yyvsp[-1].label_definition_), (yyvsp[0].closing_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7475 "Parser.c"
    break;

  case 546: /* BLOCK_BODY: DECLARE_GROUP  */
#line 1356 "HAL_S.y"
                           { (yyval.block_body_) = make_ABblock_body((yyvsp[0].declare_group_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7481 "Parser.c"
    break;

  case 547: /* BLOCK_BODY: ANY_STATEMENT  */
#line 1357 "HAL_S.y"
                  { (yyval.block_body_) = make_ADblock_body((yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7487 "Parser.c"
    break;

  case 548: /* BLOCK_BODY: BLOCK_BODY ANY_STATEMENT  */
#line 1358 "HAL_S.y"
                             { (yyval.block_body_) = make_ACblock_body((yyvsp[-1].block_body_), (yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7493 "Parser.c"
    break;

  case 549: /* FUNCTION_NAME: LABEL_EXTERNAL _SYMB_88  */
#line 1360 "HAL_S.y"
                                        { (yyval.function_name_) = make_AAfunction_name((yyvsp[-1].label_external_)); (yyval.function_name_)->line_number = (yyloc).first_line; (yyval.function_name_)->char_number = (yyloc).first_column;  }
#line 7499 "Parser.c"
    break;

  case 550: /* PROCEDURE_NAME: LABEL_EXTERNAL _SYMB_122  */
#line 1362 "HAL_S.y"
                                          { (yyval.procedure_name_) = make_AAprocedure_name((yyvsp[-1].label_external_)); (yyval.procedure_name_)->line_number = (yyloc).first_line; (yyval.procedure_name_)->char_number = (yyloc).first_column;  }
#line 7505 "Parser.c"
    break;

  case 551: /* FUNC_STMT_BODY: PARAMETER_LIST  */
#line 1364 "HAL_S.y"
                                { (yyval.func_stmt_body_) = make_AAfunc_stmt_body((yyvsp[0].parameter_list_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7511 "Parser.c"
    break;

  case 552: /* FUNC_STMT_BODY: TYPE_SPEC  */
#line 1365 "HAL_S.y"
              { (yyval.func_stmt_body_) = make_ABfunc_stmt_body((yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7517 "Parser.c"
    break;

  case 553: /* FUNC_STMT_BODY: PARAMETER_LIST TYPE_SPEC  */
#line 1366 "HAL_S.y"
                             { (yyval.func_stmt_body_) = make_ACfunc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7523 "Parser.c"
    break;

  case 554: /* PROC_STMT_BODY: PARAMETER_LIST  */
#line 1368 "HAL_S.y"
                                { (yyval.proc_stmt_body_) = make_AAproc_stmt_body((yyvsp[0].parameter_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7529 "Parser.c"
    break;

  case 555: /* PROC_STMT_BODY: ASSIGN_LIST  */
#line 1369 "HAL_S.y"
                { (yyval.proc_stmt_body_) = make_ABproc_stmt_body((yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7535 "Parser.c"
    break;

  case 556: /* PROC_STMT_BODY: PARAMETER_LIST ASSIGN_LIST  */
#line 1370 "HAL_S.y"
                               { (yyval.proc_stmt_body_) = make_ACproc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7541 "Parser.c"
    break;

  case 557: /* DECLARE_GROUP: DECLARE_ELEMENT  */
#line 1372 "HAL_S.y"
                                { (yyval.declare_group_) = make_AAdeclare_group((yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7547 "Parser.c"
    break;

  case 558: /* DECLARE_GROUP: DECLARE_GROUP DECLARE_ELEMENT  */
#line 1373 "HAL_S.y"
                                  { (yyval.declare_group_) = make_ABdeclare_group((yyvsp[-1].declare_group_), (yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7553 "Parser.c"
    break;

  case 559: /* DECLARE_ELEMENT: DECLARE_STATEMENT  */
#line 1375 "HAL_S.y"
                                    { (yyval.declare_element_) = make_AAdeclareElementDeclare((yyvsp[0].declare_statement_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7559 "Parser.c"
    break;

  case 560: /* DECLARE_ELEMENT: REPLACE_STMT _SYMB_16  */
#line 1376 "HAL_S.y"
                          { (yyval.declare_element_) = make_ABdeclareElementReplace((yyvsp[-1].replace_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7565 "Parser.c"
    break;

  case 561: /* DECLARE_ELEMENT: STRUCTURE_STMT  */
#line 1377 "HAL_S.y"
                   { (yyval.declare_element_) = make_ACdeclareElementStructure((yyvsp[0].structure_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7571 "Parser.c"
    break;

  case 562: /* DECLARE_ELEMENT: _SYMB_74 _SYMB_83 IDENTIFIER _SYMB_167 VARIABLE _SYMB_16  */
#line 1378 "HAL_S.y"
                                                             { (yyval.declare_element_) = make_ADdeclareElementEquate((yyvsp[-3].identifier_), (yyvsp[-1].variable_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7577 "Parser.c"
    break;

  case 563: /* PARAMETER: _SYMB_193  */
#line 1380 "HAL_S.y"
                      { (yyval.parameter_) = make_AAparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7583 "Parser.c"
    break;

  case 564: /* PARAMETER: _SYMB_184  */
#line 1381 "HAL_S.y"
              { (yyval.parameter_) = make_ABparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7589 "Parser.c"
    break;

  case 565: /* PARAMETER: _SYMB_187  */
#line 1382 "HAL_S.y"
              { (yyval.parameter_) = make_ACparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7595 "Parser.c"
    break;

  case 566: /* PARAMETER: _SYMB_188  */
#line 1383 "HAL_S.y"
              { (yyval.parameter_) = make_ADparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7601 "Parser.c"
    break;

  case 567: /* PARAMETER: _SYMB_191  */
#line 1384 "HAL_S.y"
              { (yyval.parameter_) = make_AEparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7607 "Parser.c"
    break;

  case 568: /* PARAMETER: _SYMB_190  */
#line 1385 "HAL_S.y"
              { (yyval.parameter_) = make_AFparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7613 "Parser.c"
    break;

  case 569: /* PARAMETER_LIST: PARAMETER_HEAD PARAMETER _SYMB_1  */
#line 1387 "HAL_S.y"
                                                  { (yyval.parameter_list_) = make_AAparameter_list((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_list_)->line_number = (yyloc).first_line; (yyval.parameter_list_)->char_number = (yyloc).first_column;  }
#line 7619 "Parser.c"
    break;

  case 570: /* PARAMETER_HEAD: _SYMB_2  */
#line 1389 "HAL_S.y"
                         { (yyval.parameter_head_) = make_AAparameter_head(); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 7625 "Parser.c"
    break;

  case 571: /* PARAMETER_HEAD: PARAMETER_HEAD PARAMETER _SYMB_0  */
#line 1390 "HAL_S.y"
                                     { (yyval.parameter_head_) = make_ABparameter_head((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 7631 "Parser.c"
    break;

  case 572: /* DECLARE_STATEMENT: _SYMB_65 DECLARE_BODY _SYMB_16  */
#line 1392 "HAL_S.y"
                                                   { (yyval.declare_statement_) = make_AAdeclare_statement((yyvsp[-1].declare_body_)); (yyval.declare_statement_)->line_number = (yyloc).first_line; (yyval.declare_statement_)->char_number = (yyloc).first_column;  }
#line 7637 "Parser.c"
    break;

  case 573: /* ASSIGN_LIST: ASSIGN PARAMETER_LIST  */
#line 1394 "HAL_S.y"
                                    { (yyval.assign_list_) = make_AAassign_list((yyvsp[-1].assign_), (yyvsp[0].parameter_list_)); (yyval.assign_list_)->line_number = (yyloc).first_line; (yyval.assign_list_)->char_number = (yyloc).first_column;  }
#line 7643 "Parser.c"
    break;

  case 574: /* TEXT: _SYMB_195  */
#line 1396 "HAL_S.y"
                 { (yyval.text_) = make_FQtext((yyvsp[0].string_)); (yyval.text_)->line_number = (yyloc).first_line; (yyval.text_)->char_number = (yyloc).first_column;  }
#line 7649 "Parser.c"
    break;

  case 575: /* REPLACE_STMT: _SYMB_133 REPLACE_HEAD _SYMB_48 TEXT  */
#line 1398 "HAL_S.y"
                                                    { (yyval.replace_stmt_) = make_AAreplace_stmt((yyvsp[-2].replace_head_), (yyvsp[0].text_)); (yyval.replace_stmt_)->line_number = (yyloc).first_line; (yyval.replace_stmt_)->char_number = (yyloc).first_column;  }
#line 7655 "Parser.c"
    break;

  case 576: /* REPLACE_HEAD: IDENTIFIER  */
#line 1400 "HAL_S.y"
                          { (yyval.replace_head_) = make_AAreplace_head((yyvsp[0].identifier_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 7661 "Parser.c"
    break;

  case 577: /* REPLACE_HEAD: IDENTIFIER _SYMB_2 ARG_LIST _SYMB_1  */
#line 1401 "HAL_S.y"
                                        { (yyval.replace_head_) = make_ABreplace_head((yyvsp[-3].identifier_), (yyvsp[-1].arg_list_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 7667 "Parser.c"
    break;

  case 578: /* ARG_LIST: IDENTIFIER  */
#line 1403 "HAL_S.y"
                      { (yyval.arg_list_) = make_AAarg_list((yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 7673 "Parser.c"
    break;

  case 579: /* ARG_LIST: ARG_LIST _SYMB_0 IDENTIFIER  */
#line 1404 "HAL_S.y"
                                { (yyval.arg_list_) = make_ABarg_list((yyvsp[-2].arg_list_), (yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 7679 "Parser.c"
    break;

  case 580: /* STRUCTURE_STMT: _SYMB_156 STRUCT_STMT_HEAD STRUCT_STMT_TAIL  */
#line 1406 "HAL_S.y"
                                                             { (yyval.structure_stmt_) = make_AAstructure_stmt((yyvsp[-1].struct_stmt_head_), (yyvsp[0].struct_stmt_tail_)); (yyval.structure_stmt_)->line_number = (yyloc).first_line; (yyval.structure_stmt_)->char_number = (yyloc).first_column;  }
#line 7685 "Parser.c"
    break;

  case 581: /* STRUCT_STMT_HEAD: STRUCTURE_ID _SYMB_17 LEVEL  */
#line 1408 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_AAstruct_stmt_head((yyvsp[-2].structure_id_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7691 "Parser.c"
    break;

  case 582: /* STRUCT_STMT_HEAD: STRUCTURE_ID MINOR_ATTR_LIST _SYMB_17 LEVEL  */
#line 1409 "HAL_S.y"
                                                { (yyval.struct_stmt_head_) = make_ABstruct_stmt_head((yyvsp[-3].structure_id_), (yyvsp[-2].minor_attr_list_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7697 "Parser.c"
    break;

  case 583: /* STRUCT_STMT_HEAD: STRUCT_STMT_HEAD DECLARATION _SYMB_0 LEVEL  */
#line 1410 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_ACstruct_stmt_head((yyvsp[-3].struct_stmt_head_), (yyvsp[-2].declaration_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7703 "Parser.c"
    break;

  case 584: /* STRUCT_STMT_TAIL: DECLARATION _SYMB_16  */
#line 1412 "HAL_S.y"
                                        { (yyval.struct_stmt_tail_) = make_AAstruct_stmt_tail((yyvsp[-1].declaration_)); (yyval.struct_stmt_tail_)->line_number = (yyloc).first_line; (yyval.struct_stmt_tail_)->char_number = (yyloc).first_column;  }
#line 7709 "Parser.c"
    break;

  case 585: /* INLINE_DEFINITION: ARITH_INLINE  */
#line 1414 "HAL_S.y"
                                 { (yyval.inline_definition_) = make_AAinline_definition((yyvsp[0].arith_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7715 "Parser.c"
    break;

  case 586: /* INLINE_DEFINITION: BIT_INLINE  */
#line 1415 "HAL_S.y"
               { (yyval.inline_definition_) = make_ABinline_definition((yyvsp[0].bit_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7721 "Parser.c"
    break;

  case 587: /* INLINE_DEFINITION: CHAR_INLINE  */
#line 1416 "HAL_S.y"
                { (yyval.inline_definition_) = make_ACinline_definition((yyvsp[0].char_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7727 "Parser.c"
    break;

  case 588: /* INLINE_DEFINITION: STRUCTURE_EXP  */
#line 1417 "HAL_S.y"
                  { (yyval.inline_definition_) = make_ADinline_definition((yyvsp[0].structure_exp_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7733 "Parser.c"
    break;

  case 589: /* ARITH_INLINE: ARITH_INLINE_DEF CLOSING _SYMB_16  */
#line 1419 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_ACprimary((yyvsp[-2].arith_inline_def_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 7739 "Parser.c"
    break;

  case 590: /* ARITH_INLINE: ARITH_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1420 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_AZprimary((yyvsp[-3].arith_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 7745 "Parser.c"
    break;

  case 591: /* ARITH_INLINE_DEF: _SYMB_88 ARITH_SPEC _SYMB_16  */
#line 1422 "HAL_S.y"
                                                { (yyval.arith_inline_def_) = make_AAarith_inline_def((yyvsp[-1].arith_spec_)); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 7751 "Parser.c"
    break;

  case 592: /* ARITH_INLINE_DEF: _SYMB_88 _SYMB_16  */
#line 1423 "HAL_S.y"
                      { (yyval.arith_inline_def_) = make_ABarith_inline_def(); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 7757 "Parser.c"
    break;

  case 593: /* BIT_INLINE: BIT_INLINE_DEF CLOSING _SYMB_16  */
#line 1425 "HAL_S.y"
                                             { (yyval.bit_inline_) = make_AGbit_prim((yyvsp[-2].bit_inline_def_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 7763 "Parser.c"
    break;

  case 594: /* BIT_INLINE: BIT_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1426 "HAL_S.y"
                                               { (yyval.bit_inline_) = make_AZbit_prim((yyvsp[-3].bit_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 7769 "Parser.c"
    break;

  case 595: /* BIT_INLINE_DEF: _SYMB_88 BIT_SPEC _SYMB_16  */
#line 1428 "HAL_S.y"
                                            { (yyval.bit_inline_def_) = make_AAbit_inline_def((yyvsp[-1].bit_spec_)); (yyval.bit_inline_def_)->line_number = (yyloc).first_line; (yyval.bit_inline_def_)->char_number = (yyloc).first_column;  }
#line 7775 "Parser.c"
    break;

  case 596: /* CHAR_INLINE: CHAR_INLINE_DEF CLOSING _SYMB_16  */
#line 1430 "HAL_S.y"
                                               { (yyval.char_inline_) = make_ADchar_prim((yyvsp[-2].char_inline_def_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 7781 "Parser.c"
    break;

  case 597: /* CHAR_INLINE: CHAR_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1431 "HAL_S.y"
                                                { (yyval.char_inline_) = make_AZchar_prim((yyvsp[-3].char_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 7787 "Parser.c"
    break;

  case 598: /* CHAR_INLINE_DEF: _SYMB_88 CHAR_SPEC _SYMB_16  */
#line 1433 "HAL_S.y"
                                              { (yyval.char_inline_def_) = make_AAchar_inline_def((yyvsp[-1].char_spec_)); (yyval.char_inline_def_)->line_number = (yyloc).first_line; (yyval.char_inline_def_)->char_number = (yyloc).first_column;  }
#line 7793 "Parser.c"
    break;

  case 599: /* STRUC_INLINE_DEF: _SYMB_88 STRUCT_SPEC _SYMB_16  */
#line 1435 "HAL_S.y"
                                                 { (yyval.struc_inline_def_) = make_AAstruc_inline_def((yyvsp[-1].struct_spec_)); (yyval.struc_inline_def_)->line_number = (yyloc).first_line; (yyval.struc_inline_def_)->char_number = (yyloc).first_column;  }
#line 7799 "Parser.c"
    break;


#line 7803 "Parser.c"

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

#line 1438 "HAL_S.y"

void yyerror(const char *str)
{
  extern char *HAL_Stext;
  fprintf(stderr,"error: %d,%d: %s at %s\n",
  HAL_Slloc.first_line, HAL_Slloc.first_column, str, HAL_Stext);
}

