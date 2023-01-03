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
    _SYMB_197 = 456                /* _SYMB_197  */
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


#line 575 "Parser.c"

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
  YYSYMBOL_YYACCEPT = 202,                 /* $accept  */
  YYSYMBOL_DECLARE_BODY = 203,             /* DECLARE_BODY  */
  YYSYMBOL_ATTRIBUTES = 204,               /* ATTRIBUTES  */
  YYSYMBOL_DECLARATION = 205,              /* DECLARATION  */
  YYSYMBOL_ARRAY_SPEC = 206,               /* ARRAY_SPEC  */
  YYSYMBOL_TYPE_AND_MINOR_ATTR = 207,      /* TYPE_AND_MINOR_ATTR  */
  YYSYMBOL_IDENTIFIER = 208,               /* IDENTIFIER  */
  YYSYMBOL_SQ_DQ_NAME = 209,               /* SQ_DQ_NAME  */
  YYSYMBOL_DOUBLY_QUAL_NAME_HEAD = 210,    /* DOUBLY_QUAL_NAME_HEAD  */
  YYSYMBOL_ARITH_CONV = 211,               /* ARITH_CONV  */
  YYSYMBOL_DECLARATION_LIST = 212,         /* DECLARATION_LIST  */
  YYSYMBOL_NAME_ID = 213,                  /* NAME_ID  */
  YYSYMBOL_ARITH_EXP = 214,                /* ARITH_EXP  */
  YYSYMBOL_TERM = 215,                     /* TERM  */
  YYSYMBOL_PLUS = 216,                     /* PLUS  */
  YYSYMBOL_MINUS = 217,                    /* MINUS  */
  YYSYMBOL_PRODUCT = 218,                  /* PRODUCT  */
  YYSYMBOL_FACTOR = 219,                   /* FACTOR  */
  YYSYMBOL_EXPONENTIATION = 220,           /* EXPONENTIATION  */
  YYSYMBOL_PRIMARY = 221,                  /* PRIMARY  */
  YYSYMBOL_ARITH_VAR = 222,                /* ARITH_VAR  */
  YYSYMBOL_PRE_PRIMARY = 223,              /* PRE_PRIMARY  */
  YYSYMBOL_NUMBER = 224,                   /* NUMBER  */
  YYSYMBOL_LEVEL = 225,                    /* LEVEL  */
  YYSYMBOL_COMPOUND_NUMBER = 226,          /* COMPOUND_NUMBER  */
  YYSYMBOL_SIMPLE_NUMBER = 227,            /* SIMPLE_NUMBER  */
  YYSYMBOL_MODIFIED_ARITH_FUNC = 228,      /* MODIFIED_ARITH_FUNC  */
  YYSYMBOL_ARITH_FUNC_HEAD = 229,          /* ARITH_FUNC_HEAD  */
  YYSYMBOL_CALL_LIST = 230,                /* CALL_LIST  */
  YYSYMBOL_LIST_EXP = 231,                 /* LIST_EXP  */
  YYSYMBOL_EXPRESSION = 232,               /* EXPRESSION  */
  YYSYMBOL_ARITH_ID = 233,                 /* ARITH_ID  */
  YYSYMBOL_NO_ARG_ARITH_FUNC = 234,        /* NO_ARG_ARITH_FUNC  */
  YYSYMBOL_ARITH_FUNC = 235,               /* ARITH_FUNC  */
  YYSYMBOL_SUBSCRIPT = 236,                /* SUBSCRIPT  */
  YYSYMBOL_QUALIFIER = 237,                /* QUALIFIER  */
  YYSYMBOL_SCALE_HEAD = 238,               /* SCALE_HEAD  */
  YYSYMBOL_PREC_SPEC = 239,                /* PREC_SPEC  */
  YYSYMBOL_SUB_START = 240,                /* SUB_START  */
  YYSYMBOL_SUB_HEAD = 241,                 /* SUB_HEAD  */
  YYSYMBOL_SUB = 242,                      /* SUB  */
  YYSYMBOL_SUB_RUN_HEAD = 243,             /* SUB_RUN_HEAD  */
  YYSYMBOL_SUB_EXP = 244,                  /* SUB_EXP  */
  YYSYMBOL_POUND_EXPRESSION = 245,         /* POUND_EXPRESSION  */
  YYSYMBOL_BIT_EXP = 246,                  /* BIT_EXP  */
  YYSYMBOL_BIT_FACTOR = 247,               /* BIT_FACTOR  */
  YYSYMBOL_BIT_CAT = 248,                  /* BIT_CAT  */
  YYSYMBOL_OR = 249,                       /* OR  */
  YYSYMBOL_CHAR_VERTICAL_BAR = 250,        /* CHAR_VERTICAL_BAR  */
  YYSYMBOL_AND = 251,                      /* AND  */
  YYSYMBOL_BIT_PRIM = 252,                 /* BIT_PRIM  */
  YYSYMBOL_CAT = 253,                      /* CAT  */
  YYSYMBOL_NOT = 254,                      /* NOT  */
  YYSYMBOL_BIT_VAR = 255,                  /* BIT_VAR  */
  YYSYMBOL_LABEL_VAR = 256,                /* LABEL_VAR  */
  YYSYMBOL_EVENT_VAR = 257,                /* EVENT_VAR  */
  YYSYMBOL_BIT_CONST_HEAD = 258,           /* BIT_CONST_HEAD  */
  YYSYMBOL_BIT_CONST = 259,                /* BIT_CONST  */
  YYSYMBOL_RADIX = 260,                    /* RADIX  */
  YYSYMBOL_CHAR_STRING = 261,              /* CHAR_STRING  */
  YYSYMBOL_SUBBIT_HEAD = 262,              /* SUBBIT_HEAD  */
  YYSYMBOL_SUBBIT_KEY = 263,               /* SUBBIT_KEY  */
  YYSYMBOL_BIT_FUNC_HEAD = 264,            /* BIT_FUNC_HEAD  */
  YYSYMBOL_BIT_ID = 265,                   /* BIT_ID  */
  YYSYMBOL_LABEL = 266,                    /* LABEL  */
  YYSYMBOL_BIT_FUNC = 267,                 /* BIT_FUNC  */
  YYSYMBOL_EVENT = 268,                    /* EVENT  */
  YYSYMBOL_SUB_OR_QUALIFIER = 269,         /* SUB_OR_QUALIFIER  */
  YYSYMBOL_BIT_QUALIFIER = 270,            /* BIT_QUALIFIER  */
  YYSYMBOL_CHAR_EXP = 271,                 /* CHAR_EXP  */
  YYSYMBOL_CHAR_PRIM = 272,                /* CHAR_PRIM  */
  YYSYMBOL_CHAR_FUNC_HEAD = 273,           /* CHAR_FUNC_HEAD  */
  YYSYMBOL_CHAR_VAR = 274,                 /* CHAR_VAR  */
  YYSYMBOL_CHAR_CONST = 275,               /* CHAR_CONST  */
  YYSYMBOL_CHAR_FUNC = 276,                /* CHAR_FUNC  */
  YYSYMBOL_CHAR_ID = 277,                  /* CHAR_ID  */
  YYSYMBOL_NAME_EXP = 278,                 /* NAME_EXP  */
  YYSYMBOL_NAME_KEY = 279,                 /* NAME_KEY  */
  YYSYMBOL_NAME_VAR = 280,                 /* NAME_VAR  */
  YYSYMBOL_VARIABLE = 281,                 /* VARIABLE  */
  YYSYMBOL_STRUCTURE_EXP = 282,            /* STRUCTURE_EXP  */
  YYSYMBOL_STRUCT_FUNC_HEAD = 283,         /* STRUCT_FUNC_HEAD  */
  YYSYMBOL_STRUCTURE_VAR = 284,            /* STRUCTURE_VAR  */
  YYSYMBOL_STRUCT_FUNC = 285,              /* STRUCT_FUNC  */
  YYSYMBOL_QUAL_STRUCT = 286,              /* QUAL_STRUCT  */
  YYSYMBOL_STRUCTURE_ID = 287,             /* STRUCTURE_ID  */
  YYSYMBOL_ASSIGNMENT = 288,               /* ASSIGNMENT  */
  YYSYMBOL_EQUALS = 289,                   /* EQUALS  */
  YYSYMBOL_IF_STATEMENT = 290,             /* IF_STATEMENT  */
  YYSYMBOL_IF_CLAUSE = 291,                /* IF_CLAUSE  */
  YYSYMBOL_TRUE_PART = 292,                /* TRUE_PART  */
  YYSYMBOL_IF = 293,                       /* IF  */
  YYSYMBOL_THEN = 294,                     /* THEN  */
  YYSYMBOL_RELATIONAL_EXP = 295,           /* RELATIONAL_EXP  */
  YYSYMBOL_RELATIONAL_FACTOR = 296,        /* RELATIONAL_FACTOR  */
  YYSYMBOL_REL_PRIM = 297,                 /* REL_PRIM  */
  YYSYMBOL_COMPARISON = 298,               /* COMPARISON  */
  YYSYMBOL_RELATIONAL_OP = 299,            /* RELATIONAL_OP  */
  YYSYMBOL_STATEMENT = 300,                /* STATEMENT  */
  YYSYMBOL_BASIC_STATEMENT = 301,          /* BASIC_STATEMENT  */
  YYSYMBOL_OTHER_STATEMENT = 302,          /* OTHER_STATEMENT  */
  YYSYMBOL_ANY_STATEMENT = 303,            /* ANY_STATEMENT  */
  YYSYMBOL_ON_PHRASE = 304,                /* ON_PHRASE  */
  YYSYMBOL_ON_CLAUSE = 305,                /* ON_CLAUSE  */
  YYSYMBOL_LABEL_DEFINITION = 306,         /* LABEL_DEFINITION  */
  YYSYMBOL_CALL_KEY = 307,                 /* CALL_KEY  */
  YYSYMBOL_ASSIGN = 308,                   /* ASSIGN  */
  YYSYMBOL_CALL_ASSIGN_LIST = 309,         /* CALL_ASSIGN_LIST  */
  YYSYMBOL_DO_GROUP_HEAD = 310,            /* DO_GROUP_HEAD  */
  YYSYMBOL_ENDING = 311,                   /* ENDING  */
  YYSYMBOL_READ_KEY = 312,                 /* READ_KEY  */
  YYSYMBOL_WRITE_KEY = 313,                /* WRITE_KEY  */
  YYSYMBOL_READ_PHRASE = 314,              /* READ_PHRASE  */
  YYSYMBOL_WRITE_PHRASE = 315,             /* WRITE_PHRASE  */
  YYSYMBOL_READ_ARG = 316,                 /* READ_ARG  */
  YYSYMBOL_WRITE_ARG = 317,                /* WRITE_ARG  */
  YYSYMBOL_FILE_EXP = 318,                 /* FILE_EXP  */
  YYSYMBOL_FILE_HEAD = 319,                /* FILE_HEAD  */
  YYSYMBOL_IO_CONTROL = 320,               /* IO_CONTROL  */
  YYSYMBOL_WAIT_KEY = 321,                 /* WAIT_KEY  */
  YYSYMBOL_TERMINATOR = 322,               /* TERMINATOR  */
  YYSYMBOL_TERMINATE_LIST = 323,           /* TERMINATE_LIST  */
  YYSYMBOL_SCHEDULE_HEAD = 324,            /* SCHEDULE_HEAD  */
  YYSYMBOL_SCHEDULE_PHRASE = 325,          /* SCHEDULE_PHRASE  */
  YYSYMBOL_SCHEDULE_CONTROL = 326,         /* SCHEDULE_CONTROL  */
  YYSYMBOL_TIMING = 327,                   /* TIMING  */
  YYSYMBOL_REPEAT = 328,                   /* REPEAT  */
  YYSYMBOL_STOPPING = 329,                 /* STOPPING  */
  YYSYMBOL_SIGNAL_CLAUSE = 330,            /* SIGNAL_CLAUSE  */
  YYSYMBOL_PERCENT_MACRO_NAME = 331,       /* PERCENT_MACRO_NAME  */
  YYSYMBOL_PERCENT_MACRO_HEAD = 332,       /* PERCENT_MACRO_HEAD  */
  YYSYMBOL_PERCENT_MACRO_ARG = 333,        /* PERCENT_MACRO_ARG  */
  YYSYMBOL_CASE_ELSE = 334,                /* CASE_ELSE  */
  YYSYMBOL_WHILE_KEY = 335,                /* WHILE_KEY  */
  YYSYMBOL_WHILE_CLAUSE = 336,             /* WHILE_CLAUSE  */
  YYSYMBOL_FOR_LIST = 337,                 /* FOR_LIST  */
  YYSYMBOL_ITERATION_BODY = 338,           /* ITERATION_BODY  */
  YYSYMBOL_ITERATION_CONTROL = 339,        /* ITERATION_CONTROL  */
  YYSYMBOL_FOR_KEY = 340,                  /* FOR_KEY  */
  YYSYMBOL_TEMPORARY_STMT = 341,           /* TEMPORARY_STMT  */
  YYSYMBOL_CONSTANT = 342,                 /* CONSTANT  */
  YYSYMBOL_ARRAY_HEAD = 343,               /* ARRAY_HEAD  */
  YYSYMBOL_MINOR_ATTR_LIST = 344,          /* MINOR_ATTR_LIST  */
  YYSYMBOL_MINOR_ATTRIBUTE = 345,          /* MINOR_ATTRIBUTE  */
  YYSYMBOL_INIT_OR_CONST_HEAD = 346,       /* INIT_OR_CONST_HEAD  */
  YYSYMBOL_REPEATED_CONSTANT = 347,        /* REPEATED_CONSTANT  */
  YYSYMBOL_REPEAT_HEAD = 348,              /* REPEAT_HEAD  */
  YYSYMBOL_NESTED_REPEAT_HEAD = 349,       /* NESTED_REPEAT_HEAD  */
  YYSYMBOL_DCL_LIST_COMMA = 350,           /* DCL_LIST_COMMA  */
  YYSYMBOL_LITERAL_EXP_OR_STAR = 351,      /* LITERAL_EXP_OR_STAR  */
  YYSYMBOL_TYPE_SPEC = 352,                /* TYPE_SPEC  */
  YYSYMBOL_BIT_SPEC = 353,                 /* BIT_SPEC  */
  YYSYMBOL_CHAR_SPEC = 354,                /* CHAR_SPEC  */
  YYSYMBOL_STRUCT_SPEC = 355,              /* STRUCT_SPEC  */
  YYSYMBOL_STRUCT_SPEC_BODY = 356,         /* STRUCT_SPEC_BODY  */
  YYSYMBOL_STRUCT_TEMPLATE = 357,          /* STRUCT_TEMPLATE  */
  YYSYMBOL_STRUCT_SPEC_HEAD = 358,         /* STRUCT_SPEC_HEAD  */
  YYSYMBOL_ARITH_SPEC = 359,               /* ARITH_SPEC  */
  YYSYMBOL_COMPILATION = 360,              /* COMPILATION  */
  YYSYMBOL_BLOCK_DEFINITION = 361,         /* BLOCK_DEFINITION  */
  YYSYMBOL_BLOCK_STMT = 362,               /* BLOCK_STMT  */
  YYSYMBOL_BLOCK_STMT_TOP = 363,           /* BLOCK_STMT_TOP  */
  YYSYMBOL_BLOCK_STMT_HEAD = 364,          /* BLOCK_STMT_HEAD  */
  YYSYMBOL_LABEL_EXTERNAL = 365,           /* LABEL_EXTERNAL  */
  YYSYMBOL_CLOSING = 366,                  /* CLOSING  */
  YYSYMBOL_BLOCK_BODY = 367,               /* BLOCK_BODY  */
  YYSYMBOL_FUNCTION_NAME = 368,            /* FUNCTION_NAME  */
  YYSYMBOL_PROCEDURE_NAME = 369,           /* PROCEDURE_NAME  */
  YYSYMBOL_FUNC_STMT_BODY = 370,           /* FUNC_STMT_BODY  */
  YYSYMBOL_PROC_STMT_BODY = 371,           /* PROC_STMT_BODY  */
  YYSYMBOL_DECLARE_GROUP = 372,            /* DECLARE_GROUP  */
  YYSYMBOL_DECLARE_ELEMENT = 373,          /* DECLARE_ELEMENT  */
  YYSYMBOL_PARAMETER = 374,                /* PARAMETER  */
  YYSYMBOL_PARAMETER_LIST = 375,           /* PARAMETER_LIST  */
  YYSYMBOL_PARAMETER_HEAD = 376,           /* PARAMETER_HEAD  */
  YYSYMBOL_DECLARE_STATEMENT = 377,        /* DECLARE_STATEMENT  */
  YYSYMBOL_ASSIGN_LIST = 378,              /* ASSIGN_LIST  */
  YYSYMBOL_TEXT = 379,                     /* TEXT  */
  YYSYMBOL_REPLACE_STMT = 380,             /* REPLACE_STMT  */
  YYSYMBOL_REPLACE_HEAD = 381,             /* REPLACE_HEAD  */
  YYSYMBOL_ARG_LIST = 382,                 /* ARG_LIST  */
  YYSYMBOL_STRUCTURE_STMT = 383,           /* STRUCTURE_STMT  */
  YYSYMBOL_STRUCT_STMT_HEAD = 384,         /* STRUCT_STMT_HEAD  */
  YYSYMBOL_STRUCT_STMT_TAIL = 385,         /* STRUCT_STMT_TAIL  */
  YYSYMBOL_INLINE_DEFINITION = 386,        /* INLINE_DEFINITION  */
  YYSYMBOL_ARITH_INLINE = 387,             /* ARITH_INLINE  */
  YYSYMBOL_ARITH_INLINE_DEF = 388,         /* ARITH_INLINE_DEF  */
  YYSYMBOL_BIT_INLINE = 389,               /* BIT_INLINE  */
  YYSYMBOL_BIT_INLINE_DEF = 390,           /* BIT_INLINE_DEF  */
  YYSYMBOL_CHAR_INLINE = 391,              /* CHAR_INLINE  */
  YYSYMBOL_CHAR_INLINE_DEF = 392,          /* CHAR_INLINE_DEF  */
  YYSYMBOL_STRUC_INLINE_DEF = 393          /* STRUC_INLINE_DEF  */
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
#define YYLAST   7479

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  202
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  192
/* YYNRULES -- Number of rules.  */
#define YYNRULES  601
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  1000

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   456


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
     195,   196,   197,   198,   199,   200,   201
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,   647,   647,   648,   650,   651,   652,   654,   655,   656,
     657,   658,   659,   660,   661,   663,   664,   665,   666,   667,
     669,   670,   671,   673,   675,   676,   678,   679,   681,   682,
     683,   684,   686,   687,   689,   690,   691,   692,   693,   694,
     695,   696,   698,   699,   700,   701,   702,   704,   705,   707,
     709,   711,   712,   713,   714,   716,   717,   719,   721,   722,
     723,   724,   726,   727,   728,   729,   730,   731,   732,   733,
     735,   736,   737,   738,   739,   741,   742,   744,   746,   748,
     750,   751,   752,   753,   755,   756,   758,   759,   761,   762,
     763,   765,   766,   767,   768,   769,   771,   772,   774,   775,
     776,   777,   778,   779,   780,   781,   783,   784,   785,   786,
     787,   788,   789,   790,   791,   792,   793,   794,   795,   796,
     797,   798,   799,   800,   801,   802,   803,   804,   805,   806,
     807,   808,   809,   810,   811,   812,   813,   814,   815,   816,
     817,   818,   819,   820,   821,   822,   823,   824,   825,   826,
     827,   828,   829,   831,   832,   833,   834,   836,   837,   838,
     839,   841,   842,   844,   845,   847,   848,   849,   850,   851,
     853,   854,   856,   857,   858,   859,   861,   863,   864,   866,
     867,   868,   870,   871,   873,   874,   876,   877,   878,   879,
     881,   882,   884,   886,   887,   889,   890,   891,   892,   893,
     894,   895,   896,   897,   898,   899,   901,   902,   904,   905,
     906,   907,   909,   910,   911,   912,   914,   915,   916,   917,
     919,   920,   921,   922,   924,   925,   927,   928,   929,   930,
     931,   933,   934,   935,   936,   938,   940,   941,   943,   945,
     946,   947,   949,   951,   952,   953,   954,   956,   957,   959,
     961,   962,   964,   966,   967,   968,   969,   970,   972,   973,
     974,   975,   977,   978,   980,   981,   982,   983,   985,   986,
     988,   989,   990,   991,   992,   994,   996,   997,   998,  1000,
    1002,  1003,  1004,  1006,  1007,  1008,  1009,  1010,  1011,  1012,
    1014,  1015,  1016,  1017,  1019,  1021,  1023,  1025,  1026,  1028,
    1030,  1031,  1032,  1033,  1035,  1037,  1038,  1040,  1041,  1043,
    1045,  1047,  1049,  1050,  1052,  1053,  1055,  1056,  1057,  1059,
    1060,  1061,  1062,  1063,  1065,  1066,  1067,  1068,  1069,  1070,
    1071,  1072,  1074,  1075,  1076,  1078,  1079,  1080,  1081,  1082,
    1083,  1084,  1085,  1086,  1087,  1088,  1089,  1090,  1091,  1092,
    1093,  1094,  1095,  1096,  1097,  1098,  1099,  1100,  1101,  1102,
    1103,  1104,  1105,  1106,  1107,  1108,  1109,  1110,  1111,  1112,
    1113,  1114,  1115,  1116,  1117,  1118,  1120,  1121,  1122,  1124,
    1125,  1127,  1128,  1130,  1131,  1132,  1133,  1135,  1137,  1139,
    1141,  1142,  1143,  1144,  1146,  1147,  1148,  1149,  1150,  1151,
    1152,  1153,  1155,  1156,  1157,  1159,  1160,  1162,  1164,  1165,
    1167,  1168,  1170,  1171,  1173,  1174,  1175,  1177,  1179,  1181,
    1182,  1183,  1184,  1185,  1187,  1189,  1190,  1192,  1193,  1195,
    1196,  1197,  1198,  1200,  1201,  1202,  1204,  1205,  1206,  1208,
    1209,  1210,  1212,  1214,  1215,  1217,  1218,  1219,  1221,  1223,
    1224,  1226,  1227,  1229,  1231,  1232,  1234,  1235,  1237,  1238,
    1240,  1241,  1243,  1244,  1246,  1247,  1249,  1251,  1252,  1253,
    1254,  1256,  1257,  1259,  1260,  1262,  1263,  1264,  1265,  1266,
    1267,  1268,  1269,  1270,  1271,  1272,  1273,  1275,  1276,  1277,
    1279,  1280,  1281,  1282,  1283,  1285,  1287,  1288,  1290,  1292,
    1293,  1295,  1296,  1297,  1298,  1299,  1301,  1302,  1304,  1306,
    1308,  1309,  1311,  1313,  1315,  1316,  1317,  1319,  1320,  1321,
    1322,  1323,  1324,  1325,  1326,  1327,  1329,  1330,  1332,  1334,
    1335,  1336,  1337,  1338,  1340,  1341,  1342,  1343,  1344,  1345,
    1346,  1347,  1348,  1350,  1351,  1353,  1354,  1355,  1357,  1358,
    1359,  1361,  1363,  1365,  1366,  1367,  1369,  1370,  1371,  1373,
    1374,  1376,  1377,  1378,  1379,  1381,  1382,  1383,  1384,  1385,
    1386,  1388,  1390,  1391,  1393,  1395,  1397,  1399,  1401,  1402,
    1404,  1405,  1407,  1409,  1410,  1411,  1413,  1415,  1416,  1417,
    1418,  1420,  1421,  1423,  1424,  1426,  1427,  1429,  1431,  1432,
    1434,  1436
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
  "_SYMB_197", "$accept", "DECLARE_BODY", "ATTRIBUTES", "DECLARATION",
  "ARRAY_SPEC", "TYPE_AND_MINOR_ATTR", "IDENTIFIER", "SQ_DQ_NAME",
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

#define YYPACT_NINF (-798)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-417)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
    5650,   294,    10,  -798,   -68,   713,  -798,   114,  7103,   111,
     528,   200,  1054,    71,  -798,   281,  -798,   250,   275,   290,
     303,   637,   -68,   263,  2518,   713,   280,   263,   263,    10,
    -798,  -798,   287,  -798,   384,  -798,  -798,  -798,  -798,  -798,
     395,  -798,  -798,  -798,  -798,  -798,  -798,   448,  -798,  -798,
     900,   104,   448,   435,   448,  -798,   448,   463,   242,  -798,
     469,   315,  -798,   492,  -798,   477,  -798,  6501,  6501,  3106,
    -798,  -798,  -798,  -798,  6501,   135,  6281,   283,  5938,  1097,
    2126,   235,   332,   475,   508,  4068,   578,   141,    51,   505,
     253,  5502,  6501,  3302,  1935,  -798,  5794,    81,    -1,   227,
    1290,   112,  -798,   510,  -798,  -798,  -798,  5794,  -798,  5794,
    -798,  5794,  5794,   513,   178,  -798,  -798,  -798,   448,   524,
    -798,  -798,  -798,   575,  -798,   580,  -798,   590,  -798,  -798,
    -798,  -798,  -798,  -798,   595,   598,   606,  -798,  -798,  -798,
    -798,  -798,  -798,  -798,  -798,   609,  -798,  -798,   613,  -798,
     498,  4620,   612,   636,  -798,  7288,  -798,   520,     5,  4442,
    -798,   641,  7251,  -798,  -798,  -798,  -798,  4442,  1702,  -798,
    2714,   983,  1702,  -798,  -798,  -798,   643,  -798,  -798,  4816,
     131,  -798,  -798,  3106,   627,    40,  4816,  -798,   634,    53,
    -798,   646,   659,   662,   664,   562,  -798,   423,    48,    53,
      53,  -798,   666,   684,   639,  -798,   691,  3498,  -798,  -798,
     772,    83,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,
    -798,  -798,  -798,  -798,  -798,  -798,   375,  -798,   689,   375,
    -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,
    -798,  -798,    10,  -798,  -798,   700,  -798,  -798,  -798,  -798,
     702,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,
    -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,
     712,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,
    -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,
     727,   733,   735,  -798,  -798,  -798,  -798,   448,   329,  -798,
    5156,  5156,   706,  4986,   740,  -798,   745,  -798,  -798,  -798,
    -798,  -798,   752,   757,   448,  -798,    24,   274,   126,  -798,
    1364,  -798,  -798,  -798,   592,  -798,   766,  -798,  3302,   788,
    -798,   126,  -798,   795,  -798,  -798,  -798,  -798,   806,  -798,
    -798,    72,  -798,   464,  -798,  -798,  1568,   983,   378,    53,
     876,  -798,  -798,  4264,   638,   809,  -798,   415,  -798,   810,
    -798,  -798,  -798,  -798,  6942,   900,  -798,  2910,  3302,   900,
     751,  -798,  3302,  -798,   287,  -798,   753,  6844,  -798,  3106,
    5628,    55,  4093,  1860,  4093,   961,   961,    55,   274,  -798,
    -798,  -798,  -798,   299,  -798,  -798,   287,  -798,  -798,  3302,
    -798,  -798,   817,   562,  7103,  -798,  6061,   816,  -798,  -798,
     832,   835,   851,   855,   862,  -798,  -798,  -798,  -798,   341,
    -798,  -798,  -798,  1434,  -798,  2322,  -798,  3302,  4816,  4816,
    5354,  4816,   735,   351,   883,  -798,  -798,   385,  4816,  4816,
    5388,   890,   771,  -798,  -798,   891,   343,    92,  -798,  3694,
    -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,
    -798,   532,  -798,  -798,   450,   908,   915,  5303,  3302,  -798,
    -798,  -798,   903,  -798,   562,   839,  -798,  6171,   923,  6391,
     123,  -798,  -798,   929,  -798,  -798,  -798,  -798,  -798,  -798,
    -798,  -798,  -798,  -798,  -798,  -798,  -798,  1604,   731,   947,
    -798,   909,  -798,  -798,   945,  6391,   953,  6391,   964,  6391,
     982,  6391,   448,    10,   448,  -798,   713,  -798,  4442,  4442,
    4442,  4442,   767,  -798,  1702,  1702,  1702,  -798,   983,  -798,
    -798,  -798,  -798,   585,   992,  -798,  -798,   602,  -798,  1002,
    -798,   656,  -798,  -798,  1702,   847,  -798,  4442,   486,   -68,
     475,  1012,    24,    24,  -798,  -798,   996,    56,  1021,  -798,
    -798,  -798,  -798,  -798,  -798,  1007,  -798,  1009,  -798,  -798,
       2,  1026,  1034,  -798,   -68,   842,   263,   157,    67,   293,
    1030,  1028,  1036,  1031,   324,  1032,  -798,  -798,  -798,    53,
    -798,  3302,  -798,  -798,  -798,  5156,  5156,  3890,  -798,  -798,
    5156,  5156,  5156,  -798,  -798,  5156,  1039,  -798,  3302,  -798,
    -798,  -798,  -798,  5388,  -798,  -798,  -798,  5388,  5388,  5388,
      83,    83,  -798,  1038,  -798,    53,  1046,  3302,  3890,  3302,
    6932,  1709,  -798,  1033,   767,  1611,   388,  -798,  4816,   882,
    1051,  1041,  -798,  -798,  -798,  -798,   177,  -798,  4638,   885,
     585,  -798,  -798,  -798,  -798,  -798,  -798,  1059,   242,  -798,
    -798,  1045,   507,   668,  -798,  -798,    72,  -798,   448,   448,
     448,   448,  -798,  -798,  -798,  5582,  3887,    76,  -798,  -798,
    -798,  -798,   707,  -798,  4816,  -798,  -798,  5388,  3106,  3890,
     438,    41,  3106,  -798,  3106,  1048,   744,   900,  -798,  1049,
    6624,  -798,  -798,  4816,  4816,  4816,  4816,  4816,  -798,  -798,
    1050,   411,   555,   756,  1053,    84,   570,  -798,  1085,   713,
    -798,   585,   585,    24,  4816,  -798,  -798,  -798,  4816,  4816,
    3694,   585,    24,  1069,  -798,  1061,   886,  -798,  -798,  -798,
    -798,  -798,   770,  -798,  -798,   -68,  6734,  -798,  -798,  -798,
    1063,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,
     804,  -798,  -798,  -798,  1064,  -798,  1068,  -798,  1079,  -798,
    1080,  -798,  -798,   448,  1096,  1098,  1099,  1108,  1109,  1702,
    1702,   641,  -798,  -798,  -798,  -798,  -798,  1110,  1113,  1024,
    1090,  -798,   596,  -798,  4816,  -798,  4816,  -798,  -798,  -798,
    -798,  -798,  -798,  -798,   823,  -798,  -798,  -798,  -798,  -798,
     448,    83,   448,  1114,  1118,   829,  -798,  -798,  3890,  -798,
     585,  -798,  1116,  -798,  -798,  -798,  -798,  1124,   846,   274,
     126,  -798,  1364,  1117,  1119,  -798,   860,   585,  -798,   866,
    1127,  1139,   448,  -798,  -798,   767,   767,  -798,   594,  4816,
    -798,   856,  4816,  4638,   585,  -798,  -798,  5156,  5156,  -798,
    3302,  -798,  3302,  3302,  -798,  -798,  -798,  -798,  -798,  -798,
    -798,  -798,  -798,   585,   126,    97,   329,   126,  -798,  -798,
    -798,   433,  4093,   274,  -798,  -798,    85,  -798,   415,   884,
    -798,   844,   868,   926,   946,   970,  -798,  -798,  -798,  -798,
    -798,  -798,  -798,   972,   585,   585,  4126,  -798,  -798,  -798,
    -798,   956,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,
    -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,   163,
     585,   -68,  -798,  -798,  -798,  1129,   592,  -798,  1370,   856,
    -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,
    -798,   630,  -798,   965,  1141,  1005,  -798,  -798,  -798,  -798,
    -798,  -798,  -798,  1143,   900,  1130,  -798,  -798,  -798,  -798,
    -798,  -798,   900,  4816,  -798,    79,  -798,  1000,  -798,  1134,
    -798,  -798,  -798,   900,  -798,   415,  -798,  1135,   585,  1154,
    1134,  1144,  4816,  1016,  -798,  -798,  1027,  1142,  -798,  -798
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int16 yydefact[] =
{
       0,     0,     0,   342,     0,     0,   426,     0,     0,     0,
       0,     0,     0,     0,   310,     0,   279,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     238,   425,   538,   424,     0,   242,   244,   245,   275,   299,
     246,   243,   249,    97,    23,    96,   283,    62,   284,   288,
       0,     0,   212,     0,   220,   286,   264,     0,     0,   590,
       0,   290,   294,     0,   297,     0,   376,     0,     0,     0,
     379,   332,   333,   517,     0,     0,   543,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   433,     0,     0,
       0,     0,     0,     0,     0,   380,     0,     0,   531,     0,
     539,   541,   519,     0,   521,   334,   587,     0,   588,     0,
     589,     0,     0,     0,     0,   448,   246,   388,   216,     0,
     488,   479,   478,     0,   476,     0,   506,     0,   477,   164,
     505,    16,    28,   485,     0,    31,     0,    17,    18,   481,
     482,    29,   163,   475,    19,    30,    38,    39,    40,    41,
       0,    13,     0,     0,    32,     5,     6,    34,   515,     0,
      25,     2,     7,   514,    36,    37,   512,     0,    22,   473,
       0,     0,    20,   502,   503,   501,     0,   504,   394,     0,
       0,   455,   454,     0,     0,     0,     0,   337,     0,     0,
     594,     0,     0,     0,     0,     0,   487,     0,   382,     0,
       0,   339,     0,   578,     0,   446,     0,     0,    49,    50,
       0,     0,   347,   208,   210,   211,   107,   137,   119,   120,
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
     290,     0,   429,     0,   445,   447,     0,     0,     0,     0,
       0,    63,   154,   170,     0,     0,   289,     0,   236,     0,
     213,   387,   221,   265,     0,     0,   304,     0,     0,     0,
       0,   295,     0,   335,     0,   305,   332,     0,   306,     0,
       0,     0,   184,     0,     0,     0,     0,     0,   312,   314,
     318,   377,   370,     0,   544,   536,   537,   336,   378,     0,
     343,   389,     0,   402,     0,   400,   543,     0,   401,   350,
       0,     0,     0,     0,     0,   412,   408,   413,   352,   299,
     414,   410,   415,     0,   351,     0,   353,     0,     0,     0,
       0,     0,     0,     0,     0,   361,   427,     0,     0,     0,
       0,     0,     0,   365,   435,     0,   437,   441,   436,     0,
     367,   449,   374,   467,   468,   281,   282,   469,   470,   451,
     280,     0,   452,   399,    91,   490,     0,   494,     0,     1,
     518,   520,     0,   522,   545,     0,   549,   543,     0,     0,
     548,   559,   561,     0,   563,   528,   529,   530,   532,   533,
     535,   551,   552,   534,   572,   554,   540,   553,     0,     0,
     542,   556,   557,   523,     0,     0,     0,     0,     0,     0,
       0,     0,    64,     0,    66,   217,     0,   471,     0,     0,
       0,     0,     0,    26,    10,    11,    14,   574,     0,     4,
      35,   516,   500,   499,     0,   498,     8,     0,   474,     0,
     490,     0,    40,    33,    21,     0,   509,     0,     0,     0,
       0,     0,   456,   457,   397,   395,     0,   460,   459,   338,
     418,   597,   600,   601,   593,     0,   373,     0,   386,   385,
     381,     0,     0,   340,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   250,   241,   251,     0,
     263,     0,    85,   206,   207,     0,     0,     0,    43,    44,
       0,     0,     0,    54,    57,     0,     0,    61,     0,   348,
      81,   192,   191,     0,   190,   193,   194,     0,     0,     0,
       0,     0,   188,     0,   226,     0,     0,     0,     0,     0,
       0,     0,   369,     0,     0,     0,     0,   582,     0,     0,
       0,   165,   156,   155,   173,   179,   177,   171,     0,   172,
     178,   169,   153,   167,   168,   285,   237,     0,     0,   301,
     300,     0,    91,     0,    86,    88,    90,   303,    68,   214,
     222,   266,   298,   302,   309,     0,     0,     0,   326,   327,
     328,   329,     0,   324,     0,   311,   308,     0,     0,     0,
       0,     0,     0,   307,     0,     0,     0,     0,   403,     0,
       0,   404,   349,     0,     0,     0,     0,     0,   409,   411,
       0,     0,     0,     0,     0,     0,     0,   358,     0,     0,
     362,   430,   431,   432,     0,   442,   366,   438,     0,     0,
       0,   443,   444,     0,   450,     0,     0,   525,   489,   496,
     491,   492,     0,   524,   546,     0,     0,   547,   526,   550,
       0,   560,   562,   555,   566,   567,   568,   570,   569,   565,
       0,   575,   558,   591,     0,   595,     0,   598,     0,   292,
       0,    65,    67,   218,     0,     0,     0,     0,     0,     9,
      12,     3,    24,   472,    15,   484,   483,   510,     0,   398,
       0,   464,     0,   396,     0,   458,     0,   341,   372,   384,
     383,   405,   406,   580,     0,   576,   577,    70,   199,   261,
     202,     0,   204,     0,     0,     0,    45,    46,     0,   273,
     256,   257,     0,    48,    52,    53,    56,     0,     0,   183,
     185,   187,     0,     0,     0,   200,     0,   255,   254,     0,
       0,     0,    82,   368,   583,     0,     0,   586,     0,     0,
     407,   161,     0,     0,   177,   174,   176,     0,     0,   287,
       0,   355,     0,     0,   291,    69,   215,   223,   267,   316,
     330,   331,   325,   319,   321,     0,     0,   320,   323,   296,
     322,     0,     0,   313,   315,   371,     0,   390,   392,     0,
     466,     0,     0,     0,     0,     0,   354,   356,   417,   357,
     360,   359,   428,     0,   440,   439,     0,   375,   495,   497,
     493,     0,   527,   573,   571,   592,   596,   599,   293,   219,
     507,   508,   480,    27,   486,   513,   511,   453,   465,   462,
     461,     0,   579,   203,   205,     0,     0,    74,     0,   161,
      73,   189,   225,   201,   260,   278,   276,    83,   584,   585,
     363,     0,   162,     0,     0,     0,   175,   180,   181,    89,
      87,   317,   344,     0,     0,     0,   421,   422,   423,   419,
     420,   434,     0,     0,   581,     0,   269,     0,   364,   166,
     157,   160,   158,     0,   391,   393,   345,     0,   463,     0,
       0,   161,     0,     0,   564,   252,     0,     0,   159,   346
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -798,   761,  1018,  -117,  -798,  1014,    31,  -798,  -798,    87,
     653,  -798,   815,  -284,   977,  1105,  -277,   577,  -798,  -798,
     306,  -798,   143,  -409,   -72,   449,   -80,  -798,  -341,   321,
     -18,     6,  -591,  -798,  1074,   881,  -797,  -155,  -798,  -798,
    -798,  -798,  -597,  -798,    15,   576,    94,  -375,  -798,  -370,
    -310,   -77,   203,    47,   213,   169,  -798,   -71,  -763,  -320,
     631,  -798,  -798,    34,   950,  -798,  -362,   959,  -798,    68,
    -455,  -798,   710,   -48,  -798,    95,   -39,   531,  -316,   -35,
    1252,  -798,   728,  -798,     0,   128,   207,   -49,  -798,  -798,
    -798,  -798,   803,  -170,   499,   502,  -798,  -353,   226,   -31,
     -15,    38,  -798,  -798,   780,  -798,   -76,   210,  -798,  1120,
    -798,  -798,  -798,  -798,   774,   776,   837,  -798,   -59,  -798,
    -798,  -798,  -798,  -798,  -798,  -798,  -798,   760,   820,  -798,
    -798,  -798,  -798,   -25,  1017,  -798,  -798,  -798,  -798,  -798,
     732,  -798,   -64,  -116,  1208,  -129,  -798,  -798,  -798,    21,
     -63,  1197,  1203,    37,  -798,  -798,  -798,  1206,  -798,  -798,
    -798,  -798,  -798,  -798,   376,   369,  -798,  -798,  -798,  -798,
    -798,   746,  -798,   -79,  -798,    57,   719,  -798,    59,  -798,
    -798,    70,  -798,  -798,  -798,  -798,  -798,  -798,  -798,  -798,
    -798,  -798
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
      72,   476,    74,    75,   477,    77,   499,   889,    78,   701,
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
      63,   402,   114,   531,   624,   119,   313,   113,   670,   367,
     622,   455,   692,   553,   372,   355,   598,   599,   694,   454,
     457,   422,   501,   206,   341,   119,   603,   206,   206,   687,
     385,   689,   690,   691,   427,   115,   376,   495,    73,   157,
     842,   541,   164,   458,   415,   397,   611,    48,   657,   193,
     357,   855,   538,   203,   543,   442,   460,   102,   696,   103,
     555,   398,   420,   449,   208,   209,   350,    63,    63,   341,
     104,   443,   808,   622,    63,   465,    63,   611,    63,   357,
     341,   869,   129,   631,   381,   488,   119,   526,   954,   611,
     350,   341,    63,   341,    63,   160,    63,    48,   611,   160,
     799,   485,   961,   165,   900,   962,   611,    63,   544,    63,
     358,    63,    63,   778,    48,    48,   405,   486,   494,   611,
     120,    48,   350,    48,   444,    48,    48,   842,    44,   728,
     225,   178,   470,   401,   489,   242,   166,   384,    48,    48,
     166,    48,   821,    48,   385,     1,   568,     2,   612,   234,
     593,   471,   540,   472,    48,   392,    48,   346,    48,    48,
     401,   142,   807,   382,   473,   208,   209,   800,   179,    49,
     341,   208,   209,   838,   393,   243,   954,   729,   692,   612,
     551,   593,   992,   341,   594,   208,   209,   160,   537,   513,
     438,   612,   205,   992,     8,   514,   344,   345,   552,   258,
     612,    39,   157,   475,   180,   164,   189,   580,   612,   677,
     582,   584,   989,   569,   670,   594,   113,   973,   117,    49,
     181,   612,   578,   487,   182,   844,   853,   685,   166,   794,
     636,   181,    39,   879,   453,   182,    49,    49,   342,   423,
     439,   618,   160,    49,   195,    49,   365,    49,    49,   160,
     815,   384,   294,   295,   628,   424,   956,   581,   583,   451,
      49,    49,    22,    49,   440,    49,   165,   828,   441,   670,
      35,   366,   383,   452,    39,   579,    49,   382,    49,   193,
      49,    49,   635,   166,   455,    29,   836,   196,   839,   399,
     166,   181,   490,   375,   378,   182,   199,   615,   809,   436,
     391,   549,   692,   400,   456,   618,    46,   628,   831,   200,
     626,   816,   817,   616,   841,   842,   823,   593,   463,  -289,
     623,   491,    39,   689,   824,   825,    43,    44,   341,   460,
     658,   401,   560,   197,   658,   811,   425,   208,   209,   742,
     385,   514,   571,   572,  -289,  -416,   397,   842,   119,   660,
     551,   594,   426,   593,   673,   492,    46,   493,   198,   208,
     209,  -416,   398,   343,   341,    63,   422,   341,   666,    63,
     166,   717,   341,    46,    46,   397,   668,    63,   157,   341,
      46,   164,    46,   623,    46,    46,   383,   594,   415,   719,
     349,   398,   846,   350,   578,   454,   457,    46,    46,   666,
      46,  -296,    46,   585,   669,   720,    63,   420,   847,   710,
     538,    48,    48,    46,   348,    46,    48,    46,    46,   458,
     761,   449,   631,   357,    48,   341,   370,   711,   538,   350,
     623,   897,   740,   350,   753,   157,   948,   949,   164,    23,
     623,   350,   165,   566,   513,   715,   397,   676,    27,   733,
     540,   350,    28,    48,    39,   723,   361,    42,   208,   209,
     779,   780,   398,   736,   732,   671,   350,   357,   341,   364,
      48,   670,   478,   382,   593,   368,   505,    63,   507,    63,
     509,   511,   350,   504,   632,   506,   550,   508,   510,    43,
      44,   160,   640,   643,   208,   209,   369,   373,   672,   165,
     692,   791,   628,   370,   366,    63,   789,    63,   594,    63,
     350,    63,   428,   694,    48,   208,   209,   749,   875,   538,
     862,   366,   941,   181,    48,   450,    48,   182,   512,   687,
     503,   593,   166,    49,    49,   516,   734,   735,    49,   774,
     775,   776,   777,   749,   670,   749,    49,   749,   187,   749,
     455,   638,    48,    16,    48,   338,    48,   257,    48,   157,
     898,   639,   164,   208,   209,   594,    36,    37,   788,    39,
     116,    41,   659,   957,   958,    49,   667,   456,   208,   209,
     790,   517,   383,   682,   160,   682,   518,   682,   682,   682,
     901,   666,    49,   208,   209,   460,   519,   822,   435,   628,
     338,   520,   208,   209,   521,   803,   783,   784,   666,   860,
     453,   338,   522,   623,   950,   523,   976,   623,   623,   623,
     582,   582,  -299,   165,   338,   166,   524,   666,   822,   666,
     341,    50,   527,   872,   578,   530,    49,   668,   208,   209,
     528,   672,   651,   652,   672,   535,    49,   554,    49,   385,
     978,   878,   545,   385,   559,   385,   642,   201,   653,   654,
     738,   786,   887,   538,   538,   669,   561,   581,   583,   397,
      46,    46,   863,   864,    49,    46,    49,    48,    49,   562,
      49,    50,   563,    46,   564,   398,   573,   623,   341,   822,
     574,   881,   341,   575,   341,   589,   953,   888,    50,    50,
      63,   338,   576,   578,   672,    50,  -151,    50,  -141,    50,
      50,   830,    46,   600,   338,   397,    36,    37,  -152,   119,
     116,    41,    50,    50,   668,    50,   671,    50,    61,    46,
     733,   398,   814,  -248,   334,   870,   366,   871,    50,  -273,
      50,   591,    50,    50,    48,   578,    63,    48,   863,   886,
      36,    37,   604,   618,   116,    41,   384,   877,   608,   672,
     384,   807,   384,   606,   208,   209,    36,    37,   834,    39,
     116,    41,   625,    46,   909,   910,   911,   609,   356,   334,
      76,   874,   382,    46,   977,    46,   882,    39,   882,   293,
     334,    43,    44,    48,   627,    61,    61,   618,   668,    49,
     628,   629,    61,   334,   356,   618,    61,   356,   913,   914,
     963,    46,   630,    46,   655,    46,   656,    46,   822,   356,
      61,   832,    61,   697,    61,    36,    37,   931,   932,   116,
      41,   674,   623,   863,   937,    61,   702,    61,   703,    61,
      61,   704,   660,   456,   959,   669,   672,   377,   377,   966,
     863,   940,   208,   209,   377,   750,   377,   705,   406,   338,
     341,   706,   341,   666,   863,   943,    49,   669,   707,    49,
     863,   944,   377,   967,    76,   952,   208,   209,   682,   682,
     334,   764,   641,   766,   380,   768,   579,   770,   964,   965,
       1,   383,     2,   334,   718,   383,   724,   383,   338,   338,
     433,    36,    37,   338,    39,   116,    41,   225,   464,   725,
     338,   726,   668,   737,     1,    49,     2,   334,   754,   738,
     672,   755,   756,   743,   757,   758,   234,   759,   745,   984,
     338,   968,   902,   129,   208,   209,    46,   987,    35,   672,
     669,    38,    39,   748,   668,    42,    43,    44,   887,   752,
      53,   969,   243,   494,   208,   209,   338,   401,   338,    35,
     188,   672,   974,    39,   985,   763,   294,    43,    44,   979,
     980,   202,   357,   765,   533,   970,   258,   971,   208,   209,
     208,   209,   533,   888,   767,   464,   213,   214,   215,   678,
     366,   679,   680,   681,   548,    50,    50,   782,   380,   338,
      50,   557,   769,    46,   990,   980,    46,   785,    50,   787,
     982,    48,   142,   208,   209,    16,   793,    53,    53,    48,
     964,   997,   577,   792,    53,   796,    53,   797,    53,   798,
      48,   801,   998,   671,   672,   208,   209,    50,   334,   802,
     805,   631,    53,   810,    53,   827,    53,   811,   812,   833,
     813,   835,    46,   843,    50,   849,   850,    53,   856,    53,
     851,    53,    53,    30,   859,   861,   672,    39,   885,   890,
     896,    43,    44,   899,   190,   294,   295,   334,   334,   256,
     906,   907,   334,   912,   915,   682,   295,    35,   916,   334,
      38,    39,   356,   356,    42,    43,    44,   356,    50,   917,
     918,   920,   927,   921,   922,   356,   125,   126,    50,   334,
      50,     1,   923,     2,   924,   127,   925,   409,   926,   928,
     935,   351,   338,   936,   942,   359,   360,   938,   362,   972,
     363,   129,   945,    49,   356,   334,    50,   334,    50,   338,
      50,    49,    50,   939,   946,   565,   981,   230,   975,   983,
     986,   356,    49,   991,   233,   994,   132,   377,   338,   995,
     338,   410,   999,   952,   135,   699,   237,   238,   646,   529,
      35,   146,   147,    38,   542,   149,   150,   151,   334,    44,
     536,   781,   826,   662,   960,   908,   700,   607,   590,   829,
     693,   883,   515,   993,   675,   356,   884,   708,   407,   741,
     141,   709,   556,   411,   661,   356,   727,    61,    93,   191,
     142,   262,    16,   695,   662,   192,   264,   265,   194,   338,
     762,   338,   412,   338,     0,   338,   751,     0,     0,     0,
     269,     0,     0,    61,     0,    61,   145,    61,     0,    61,
       0,     0,     0,   712,   713,    39,   716,     0,     0,     0,
       0,     0,    59,   721,   722,     0,   413,   746,     0,     0,
      30,    50,     0,   414,   731,     0,     0,     0,     0,     0,
      46,   567,   570,     0,     0,   595,    39,     0,    46,     0,
      43,    44,     0,   464,    35,     0,     0,    38,    39,    46,
       0,    42,    43,    44,     0,     0,   494,     0,     0,     0,
     586,   334,     0,   586,    35,    36,    37,   334,    39,   116,
      41,    42,     0,     0,     0,     0,     0,     0,   334,    59,
      59,   386,     0,     0,     0,     0,    59,    53,    50,     0,
      59,    50,     0,   533,   533,   533,   533,   334,   334,   334,
       0,     0,   125,   126,    59,     0,    59,     0,    59,     0,
       0,   127,     0,   698,     0,     0,    53,   595,   356,    59,
       0,    59,   533,    59,    59,     0,     0,   129,     0,     0,
     619,   592,     0,     0,   130,     0,     0,    50,   620,     0,
     621,     0,     0,     0,     0,     0,     0,     0,   610,     0,
       0,   338,   132,   338,   338,     0,     0,     0,   334,   334,
     135,     0,   334,   596,   334,     0,   662,     0,     0,     0,
     595,     0,   820,     0,     0,   225,   226,   633,     0,     0,
       0,     0,     0,   662,   744,   356,     0,    53,   356,    53,
       0,     0,   230,     0,   234,   386,   141,     0,     0,   233,
       0,   595,   662,   837,   662,     0,   142,     0,     1,     0,
       2,   237,   238,   848,   240,    53,     0,    53,     0,    53,
     243,    53,     0,   854,     0,     0,   773,     0,     0,     0,
       0,     0,   145,     0,   356,     0,     0,     0,     0,     0,
     700,    39,     0,     0,   258,   596,   260,   261,     0,     0,
       0,     0,     0,     0,     0,     0,   262,     0,   410,   873,
       0,   264,   265,   380,   876,     0,     0,   380,     0,   380,
     595,     0,     0,     0,     0,   269,     0,     0,   891,   892,
     893,   894,   895,     0,     0,   595,   746,    30,   334,     0,
       0,     0,     0,     0,   595,     0,     0,     0,   596,   903,
     411,   285,     0,   904,   905,   713,     0,     0,     0,    16,
     289,    35,   290,    37,   595,    39,   116,    41,    42,   412,
      38,    39,     0,     0,     0,    43,    44,     0,     0,   596,
     334,     0,   334,   334,     0,     0,     0,     0,     0,     0,
       0,   773,     0,     0,     0,     0,   771,     0,   772,   634,
       0,     0,     0,   413,     0,    50,     0,    30,     0,     0,
     414,     0,     0,    50,   121,     0,   122,     0,     0,   929,
       0,   930,     0,     0,    50,     0,     0,     0,   124,     0,
       0,    35,     0,   595,    38,    39,     0,   857,    42,    43,
      44,   386,   845,   577,     7,     0,     0,     0,   596,   595,
     128,     0,     0,     0,     0,     0,     0,   121,     0,   122,
      53,     0,   595,   596,     0,     0,   125,   126,     0,     0,
       0,   124,   596,     0,   951,   127,     0,   955,   854,    15,
       0,     0,   133,     0,     0,     0,   134,     7,   662,     0,
       0,   129,   596,   128,     0,   136,     0,     0,   130,   595,
     595,     0,   356,   595,     0,     0,    53,     0,   595,   595,
     356,     0,     0,     0,     0,   139,   132,     0,   595,     0,
     140,   356,    15,     0,   135,   133,     0,     0,     0,   134,
       0,     0,     0,     0,     0,     0,     0,     0,   136,   143,
       0,    59,     0,     0,     0,     0,     0,     0,   121,     0,
     122,     0,   865,   866,   867,   868,     0,     0,   139,     0,
     141,   596,   124,   140,     0,   858,     0,    59,     0,    59,
     142,    59,     0,    59,     0,     0,     0,   596,     7,     0,
       0,   230,   143,     0,   128,     0,     0,     0,   233,     0,
     596,     0,     0,   773,     0,     0,   145,     0,   988,     0,
     237,   238,     0,     0,     0,    39,     0,   595,     0,     0,
       0,     0,     0,    15,     0,     0,   133,   996,     0,     0,
     134,     0,     0,     0,   595,     0,     0,   596,   596,   136,
       0,   596,     0,     0,     0,   595,   596,   596,     0,     0,
       0,   595,     0,     0,     0,   262,   596,     0,     0,   139,
     264,   265,     0,     0,   140,     0,     0,   919,     0,     0,
     595,     0,     0,   595,   269,     0,   773,     0,     0,     0,
       0,     0,     0,   143,     0,     0,   688,     0,   595,   595,
     595,   595,   595,     0,   620,     0,   621,     0,     0,     0,
     595,   595,   595,     0,   933,     0,   934,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    35,    36,    37,    38,
      39,   116,    41,    42,    43,    44,   595,   595,     0,     0,
       0,   225,   226,     0,     0,     0,   947,     0,     0,     0,
       0,     0,     0,     0,     0,   596,     0,     0,   595,     0,
     234,     0,   595,     0,     0,   469,     0,     0,     0,     0,
     386,     0,   596,   880,   386,     0,   386,     0,     0,     1,
     240,     2,     0,   596,     0,     3,   243,     0,     0,   596,
       0,     0,     0,     0,     0,   595,     0,     0,     4,     0,
       0,     0,     0,   595,     0,     0,     0,     0,   596,     0,
     258,   596,   260,   261,     0,     0,     0,     0,     0,     0,
       5,     6,     0,     0,     0,     0,   596,   596,   596,   596,
     596,     0,     0,     0,     0,     0,     8,     0,   596,   596,
     596,     9,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    10,    30,     0,     0,    11,     0,     0,    12,
      13,     0,    14,     0,   596,   596,     0,   285,     0,     0,
       0,     0,     0,     0,     0,     0,   289,    35,   290,    37,
      16,    39,   116,    41,    42,     0,   596,    17,    18,     0,
     596,     0,     0,     0,     0,     0,     0,     0,    19,    20,
       0,     0,     0,    21,    22,    23,    24,     0,     0,     0,
       0,     0,    25,    26,    27,     0,     0,     0,    28,     0,
       0,     0,     0,   596,     0,     0,     0,    29,    30,     0,
       0,   596,     0,     0,     0,     0,    31,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    32,     0,    33,     0,
      34,     0,    35,    36,    37,    38,    39,    40,    41,    42,
      43,    44,   207,     0,   208,   209,     0,     0,     0,     0,
     210,     0,   211,     0,     0,     0,   418,     0,     0,     0,
       0,   213,   214,   215,     0,     0,     0,     0,     0,     0,
     216,   217,     0,     0,     0,     0,   218,   219,   220,   221,
     222,   223,   224,     0,     0,     0,     0,   225,   226,     0,
       0,     0,     0,     0,     0,   227,   228,   229,   230,     0,
     410,     0,     0,   231,   232,   233,   234,     0,     0,     0,
     235,   236,     0,     0,     0,     0,     0,   237,   238,     0,
       0,     0,     0,     0,   239,     0,   240,     0,   241,     0,
     242,     0,   243,     0,     0,     0,   244,     0,   245,   246,
       0,   247,   411,   248,     0,   249,   250,   251,   252,   253,
     254,    16,   255,     0,   256,   257,   258,   259,   260,   261,
       0,   412,   262,     0,     0,   263,     0,   264,   265,     0,
       0,     0,   266,     0,     0,     0,     0,     0,     0,   267,
     268,   269,   270,     0,     0,     0,   271,   272,   273,     0,
     274,   275,     0,   276,   277,   413,   278,     0,     0,    30,
     279,     0,   414,   280,   281,     0,     0,     0,     0,     0,
     282,   283,   284,   285,   286,   287,     0,     0,   288,     0,
       0,     0,   289,    35,   290,   291,    38,   419,    40,   292,
      42,    43,    44,   293,     0,   294,   295,   296,   207,     0,
     208,   209,     0,     0,     0,     0,   210,     0,   211,     0,
       0,     0,     0,     0,     0,     0,     0,   213,   214,   215,
       0,     0,     0,     0,     0,     0,   216,   217,     0,     0,
       0,     0,   218,   219,   220,   221,   222,   223,   224,     0,
       0,     0,     0,   225,   226,     0,     0,     0,     0,     0,
       0,   227,   228,   229,   230,     0,   410,     0,     0,   231,
     232,   233,   234,     0,     0,     0,   235,   236,     0,     0,
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
     286,   287,     0,     0,   288,     0,     0,     0,   289,    35,
     290,   291,    38,   419,    40,   292,    42,    43,    44,   293,
       0,   294,   295,   296,   207,     0,   208,   209,     0,     0,
       0,     0,   210,     0,   211,     0,     0,     0,   212,     0,
       0,     0,     0,   213,   214,   215,     0,     0,     0,     0,
       0,     0,   216,   217,     0,     0,     0,     0,   218,   219,
     220,   221,   222,   223,   224,     0,     0,     0,     0,   225,
     226,     0,     0,     0,     0,     0,     0,   227,   228,   229,
     230,     0,     0,     0,     0,   231,   232,   233,   234,     0,
       0,     0,   235,   236,     0,     0,     0,     0,     0,   237,
     238,     0,     0,     0,     0,     0,   239,     0,   240,     0,
     241,     0,   242,     0,   243,     0,     0,     0,   244,     0,
     245,   246,     0,   247,     0,   248,     0,   249,   250,   251,
     252,   253,   254,    16,   255,     0,   256,   257,   258,   259,
     260,   261,     0,     0,   262,     0,     0,   263,     0,   264,
     265,     0,     0,     0,   266,     0,     0,     0,     0,     0,
       0,   267,   268,   269,   270,     0,     0,     0,   271,   272,
     273,     0,   274,   275,     0,   276,   277,     0,   278,     0,
       0,    30,   279,     0,     0,   280,   281,     0,     0,     0,
       0,     0,   282,   283,   284,   285,   286,   287,     0,     0,
     288,     0,     0,     0,   289,    35,   290,   291,    38,    39,
      40,   292,    42,    43,    44,   293,     0,   294,   295,   296,
     207,     0,   208,   209,   539,     0,     0,     0,   210,     0,
     211,     0,     0,     0,     0,     0,     0,     0,     0,   213,
     214,   215,     0,     0,     0,     0,     0,     0,   216,   217,
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
     289,    35,   290,   291,    38,    39,    40,   292,    42,    43,
      44,   293,     0,   294,   295,   296,   207,     0,   208,   209,
       0,     0,     0,     0,   210,     0,   211,     0,     0,     0,
       0,     0,     0,     0,     0,   213,   214,   215,     0,     0,
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
       0,     0,   288,     0,     0,     0,   289,    35,   290,   291,
      38,    39,    40,   292,    42,    43,    44,   293,     0,   294,
     295,   296,   379,     0,   208,   209,     0,     0,     0,     0,
     210,     0,   211,     0,     0,     0,     0,     0,     0,     0,
       0,   213,   214,   215,     0,     0,     0,     0,     0,     0,
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
       0,     0,   289,    35,   290,   291,    38,    39,    40,   292,
      42,    43,    44,   293,     0,   294,   295,   296,   207,     0,
     208,   209,     0,     0,     0,     0,   210,     0,   211,     0,
       0,     0,     0,     0,     0,     0,     0,   213,   214,   215,
       0,     0,     0,     0,     0,     0,   216,   217,     0,     0,
       0,     0,   218,   219,   220,   221,   222,   223,   224,     0,
       0,     0,     0,   225,   226,     0,     0,     0,     0,     0,
       0,   227,   228,   229,   230,     0,     0,     0,     0,   231,
     232,   233,   234,     0,     0,     0,   235,   236,     0,     0,
       0,     0,     0,   237,   238,     0,     0,     0,     0,     0,
     239,     0,   240,     0,   241,     0,   242,     0,   243,     0,
       0,     0,   244,     0,   245,   246,     0,   247,     0,   248,
       0,   249,   250,   251,   252,   253,   254,    16,   255,     0,
     256,   257,   258,   259,   260,   261,     0,     0,   262,     0,
       0,   263,     0,   264,   265,     0,     0,     0,   266,     0,
       0,     0,     0,     0,     0,   267,   268,   269,   270,     0,
       0,     0,   271,   272,   273,     0,   274,   275,     0,   276,
     277,     0,   278,     0,     0,    30,   279,     0,     0,   280,
     281,     0,     0,     0,     0,     0,   282,   283,   284,   285,
     286,   287,     0,     0,   288,     0,     0,     0,   289,    35,
     290,   291,    38,    39,    40,   292,    42,    43,    44,   293,
       0,   294,   295,   296,   207,     0,   208,   209,     0,     0,
       0,     0,   210,     0,   211,     0,     0,     0,     0,     0,
       0,     0,     0,   213,   214,   215,     0,     0,     0,     0,
       0,     0,   216,   217,     0,     0,     0,     0,   218,   219,
     220,   221,   222,   223,   224,     0,     0,     0,     0,   225,
     226,     0,     0,     0,     0,     0,     0,   227,   228,   229,
     230,     0,     0,     0,     0,   231,   232,   233,   234,     0,
       0,     0,   235,   236,     0,     0,     0,     0,     0,   237,
     238,     0,     0,     0,     0,     0,   239,     0,   240,     0,
     241,     0,     0,     0,   243,     0,     0,     0,   244,     0,
     245,   246,     0,   247,     0,   248,     0,   249,   250,   251,
     252,   253,   254,     0,   255,     0,   256,     0,   258,   259,
     260,   261,     0,     0,   262,     0,     0,   263,     0,   264,
     265,     0,     0,     0,   266,     0,     0,     0,     0,     0,
       0,   267,   268,   269,   270,     0,     0,     0,   271,   272,
     273,     0,   274,   275,     0,   276,   277,     0,   278,     0,
       0,    30,   279,     0,     0,   280,   281,     0,     0,     0,
       0,     0,   282,   283,   284,   285,   286,   287,     0,     0,
     288,     0,     0,     0,   289,    35,   290,   291,    38,    39,
     116,   292,    42,    43,    44,   293,     0,   294,   295,   296,
     730,     0,   208,   209,     0,     0,     0,     0,   210,     0,
     211,     0,     0,     0,     0,     0,     0,     0,     0,   213,
     214,   215,     0,     0,     0,     0,     0,     0,   216,   217,
       0,     0,     0,     0,   218,   219,   220,   221,   222,   223,
     224,     0,     0,     0,     0,   225,   226,     0,     0,     0,
       0,     0,     0,   227,     0,     0,   230,     0,     0,     0,
       0,   231,   232,   233,   234,     0,     0,     0,   235,   236,
       0,     0,     0,     0,     0,   237,   238,     0,     0,     0,
       0,     0,   239,     0,   240,     0,   241,     0,     0,     0,
     243,     0,     0,     0,   244,     0,   245,   246,     0,   247,
       0,     0,     0,   249,   250,   251,   252,   253,   254,     0,
     255,     0,   256,     0,   258,   259,   260,   261,     0,     0,
     262,     0,     0,   263,     0,   264,   265,     0,     0,     0,
     266,     0,     0,     0,     0,     0,     0,     0,   268,   269,
     270,     0,     0,     0,   271,   272,   273,     0,   274,   275,
       0,   276,   277,     0,   278,     0,     0,    30,   279,     0,
       0,   280,   281,     0,     0,     0,     0,     0,   282,   283,
       0,   285,   286,   287,     0,     0,   288,     0,     0,     0,
     289,    35,   290,    37,     0,    39,   116,   292,    42,    43,
      44,     0,   809,   294,   295,   296,   818,     0,   208,   209,
       0,     0,     0,     0,     1,     0,     2,     0,     0,     0,
       0,   593,   213,   214,   215,   678,   366,   679,   680,   681,
       0,     0,     0,     0,   216,   217,     0,     0,     0,     0,
     218,   219,   220,   221,   222,   223,   224,     0,     0,     0,
       0,     0,     0,     0,     0,   594,     0,     0,     0,   227,
     228,   229,   230,     0,     0,     0,     0,   231,   232,   233,
       0,     0,     0,     0,   235,   236,     0,     0,     0,     0,
       0,   237,   238,     0,     0,     0,     0,     0,   239,     0,
       0,     0,   241,     0,     0,     0,     0,     0,     0,     0,
     244,     0,   245,   246,     0,   247,     0,   248,     0,   249,
     250,   251,   252,   253,   254,   256,   255,     0,     0,     0,
       0,   259,     0,     0,     0,     0,   262,     0,     0,   263,
       0,   264,   265,     0,     0,     0,   266,     0,     0,     0,
       0,     0,     0,   267,   268,   269,   270,     0,     0,     0,
     271,   272,   273,     0,   274,   275,     0,   276,   277,     0,
     278,     0,     0,     0,   279,     0,     0,   280,   281,     0,
       0,     0,     0,     0,   282,   283,   284,     0,   286,   287,
       0,     0,   288,     0,   429,     0,   208,   209,     0,   819,
      38,    39,     1,   432,     2,    43,    44,   293,     0,   294,
     295,   296,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   216,   217,     0,     0,     0,     0,   218,   219,
     220,   221,   222,   223,   224,     0,     0,   593,   213,   214,
     215,   678,   366,   679,   680,   681,     0,   227,     0,     0,
     230,     0,     0,     0,     0,   231,   232,   233,     0,     0,
       0,     0,   235,   236,     0,     0,     0,     0,     0,   237,
     238,   594,     0,     0,     0,     0,   239,     0,     0,     0,
     241,   430,     0,     0,     0,     0,     0,     0,   244,     0,
     245,   246,     0,   247,     0,     0,     0,   249,   250,   251,
     252,   253,   254,     0,   255,     0,     0,     0,   230,   259,
       0,     0,     0,     0,   262,   233,     0,   263,     0,   264,
     265,     0,     0,     0,   266,     0,     0,   237,   238,     0,
       0,   256,   268,   269,   270,     0,     0,     0,   271,   272,
     273,     0,   274,   275,     0,   276,   277,     0,   278,     0,
       0,     0,   279,     0,     0,   280,   281,     0,     0,     0,
       0,     0,   282,   283,     0,     0,   286,   287,   431,     0,
     288,     0,   262,     0,     0,     0,     0,   264,   265,    39,
       0,   432,     0,    43,    44,     0,     0,   294,   295,   296,
     429,   269,   208,   209,   644,     0,     0,   645,     1,     0,
       2,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   216,   217,
       0,     0,     0,     0,   218,   219,   220,   221,   222,   223,
     224,     0,     0,    35,    36,    37,     0,    39,   116,    41,
      42,    43,    44,   227,     0,     0,   230,     0,     0,     0,
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
       0,     0,   286,   287,     0,     0,   288,     0,   429,     0,
     208,   209,   532,     0,     0,    39,     1,   432,     2,    43,
      44,     0,     0,   294,   295,   296,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   216,   217,     0,     0,
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
     286,   287,     0,     0,   288,     0,     0,     0,     0,     0,
       0,     0,     0,    39,     0,   432,     0,    43,    44,     0,
       0,   294,   295,   296,   429,     0,   208,   209,     0,     0,
       0,   645,     1,     0,     2,     0,   121,     0,   122,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     124,     0,   216,   217,     0,     0,     0,     0,   218,   219,
     220,   221,   222,   223,   224,     0,     7,     0,     0,     0,
       0,     0,   128,     0,     0,     0,     0,   227,     0,     0,
     230,     0,     0,     0,   525,   231,   232,   233,     0,     0,
       0,     0,   235,   236,     0,     0,     0,     0,     0,   237,
     238,    15,     0,     0,   133,     0,   239,     0,   134,     0,
     241,     0,     0,     0,     0,     0,     0,   136,   244,     0,
     245,   246,     0,   247,     0,     0,     0,   249,   250,   251,
     252,   253,   254,     0,   255,     0,     0,   139,     0,   259,
       0,     0,   140,     0,   262,     0,     0,   263,     0,   264,
     265,     0,     0,     0,   266,     0,     0,     0,     0,     0,
       0,   143,   268,   269,   270,     0,     0,     0,   271,   272,
     273,     0,   274,   275,     0,   276,   277,     0,   278,     0,
       0,     0,   279,     0,     0,   280,   281,     0,     0,     0,
       0,     0,   282,   283,     0,     0,   286,   287,     0,     0,
     288,     0,   429,     0,   208,   209,     0,     0,     0,    39,
       1,   432,     2,    43,    44,     0,     0,   294,   295,   296,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     216,   217,     0,     0,     0,     0,   218,   219,   220,   221,
     222,   223,   224,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   227,     0,     0,   230,     0,
       0,     0,     0,   231,   232,   233,     0,     0,     0,     0,
     235,   236,     0,     0,     0,     0,     0,   237,   238,     0,
       0,     0,     0,     0,   239,     0,     0,     0,   241,     0,
       0,     0,     0,     0,     0,     0,   244,     0,   245,   246,
       0,   247,     0,     0,     0,   249,   250,   251,   252,   253,
     254,     0,   255,     0,     0,     0,     0,   259,     0,     0,
       0,     0,   262,     0,     0,   263,     0,   264,   265,     0,
       0,     0,   266,     0,     0,     0,     0,     0,     0,     0,
     268,   269,   270,     0,     0,     0,   271,   272,   273,     0,
     274,   275,     0,   276,   277,     0,   278,     0,     0,     0,
     279,     0,     0,   280,   281,     0,     0,     0,     0,     0,
     282,   283,   429,     0,   286,   287,   601,   602,   288,     0,
       1,     0,     2,     0,     0,     0,     0,    39,     0,   432,
       0,    43,    44,     0,     0,   294,   295,   296,     0,     0,
     216,   217,     0,     0,     0,     0,   218,   219,   220,   221,
     222,   223,   224,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   227,     0,     0,   230,     0,
       0,     0,     0,   231,   232,   233,     0,     0,     0,     0,
     235,   236,     0,     0,     0,     0,     0,   237,   238,     0,
       0,     0,     0,     0,   239,     0,     0,     0,   241,     0,
       0,     0,     0,     0,     0,     0,   244,     0,   245,   246,
       0,   247,     0,     0,     0,   249,   250,   251,   252,   253,
     254,     0,   255,     0,     0,     0,     0,   259,     0,     0,
       0,     0,   262,     0,     0,   263,     0,   264,   265,     0,
       0,     0,   266,     0,     0,     0,     0,     0,     0,     0,
     268,   269,   270,     0,     0,     0,   271,   272,   273,     0,
     274,   275,     0,   276,   277,     0,   278,     0,     0,     0,
     279,     0,     0,   280,   281,     0,     0,     0,     0,     0,
     282,   283,   429,     0,   286,   287,     0,     0,   288,     0,
       1,     0,     2,     0,     0,     0,     0,    39,     0,   432,
       0,    43,    44,     0,     0,   294,   295,   296,     0,     0,
     216,   217,     0,     0,     0,     0,   218,   219,   220,   221,
     222,   223,   224,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   227,     0,     0,   230,     0,
       0,     0,     0,   231,   232,   233,     0,     0,     0,     0,
     235,   236,     0,     0,     0,     0,     0,   237,   238,     0,
       0,     0,     0,     0,   239,     0,     0,     0,   241,     0,
       0,     0,     0,     0,     0,     0,   244,     0,   245,   246,
       0,   247,     0,     0,     0,   249,   250,   251,   252,   253,
     254,     0,   255,     0,     0,     0,     0,   259,     0,     0,
       0,     0,   262,     0,     0,   263,     0,   264,   265,     0,
       0,     0,   266,     0,     0,     0,     0,     0,     0,     0,
     268,   269,   270,     0,     0,     0,   271,   272,   273,   739,
     274,   275,     0,   276,   277,     0,   278,     1,     0,     2,
     279,     0,     0,   280,   281,     0,     0,     0,     0,     0,
     282,   283,     0,     0,   286,   287,     0,     0,   288,     0,
       0,     0,     0,     0,     0,     0,     0,    39,     0,   432,
       0,    43,    44,     0,   225,   294,   295,   296,     0,     0,
     619,     0,     0,   228,     0,     0,     0,     0,   620,     0,
     621,     0,     0,   234,     0,     0,     0,     0,     0,   213,
     214,   215,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   240,   619,     0,     0,     0,     0,   243,
       0,     0,   620,     0,   621,   225,   226,     0,     0,     0,
       0,     0,     0,   213,   214,   215,     0,     0,    16,     0,
       0,     0,     0,   258,   234,   260,   261,   714,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   225,
     226,     0,     0,     0,   240,     0,     0,     0,     0,     0,
     243,     0,     0,     0,     0,     0,     0,     0,   234,     0,
       0,     0,     0,     0,     0,     0,    30,     0,     0,     0,
       0,     0,   256,     0,   258,     0,   260,   261,   240,     0,
     285,     0,     0,     0,   243,     0,     0,     0,     0,     0,
      35,     0,     0,    38,    39,     0,     0,    42,    43,    44,
     293,     0,   294,   295,   296,     0,   256,     0,   258,     0,
     260,   261,     0,     0,     0,     0,     1,    30,     2,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   285,     0,     0,     0,     0,     0,     0,     0,     0,
     289,    35,   290,    37,     0,    39,   116,    41,    42,     0,
       0,    30,     0,   225,     0,     0,     0,     0,     0,     0,
       0,     0,   228,     0,   230,   285,     0,     0,     0,     0,
       0,   233,   234,     0,   289,    35,   290,    37,     0,    39,
     116,    41,    42,   237,   238,     0,     0,   807,     0,     0,
     208,   209,   240,     0,     0,     0,     0,     0,   243,     0,
       0,     0,     0,     0,     0,     0,   593,   213,   214,   215,
     678,   366,   679,   680,   681,     0,     0,    16,     0,     0,
       0,     0,   258,     0,   260,   261,     0,     0,   262,     0,
       0,     0,     0,   264,   265,     0,   208,   209,     0,     0,
     594,     0,     0,     0,     0,     0,     0,   269,     0,     0,
       0,     0,   593,   213,   214,   215,   678,   366,   679,   680,
     681,     0,     0,     0,     1,    30,     2,     0,     0,     0,
       3,     0,     0,     0,     0,     0,     0,     0,     0,   285,
       0,     0,     0,     4,     0,     0,   594,     0,     0,    35,
      36,    37,    38,    39,   116,    41,    42,    43,    44,   293,
     256,   294,   295,   296,     0,     5,     6,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     7,     0,     0,     0,
       0,     8,     0,     0,     0,     0,     9,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    10,     0,     0,
       0,    11,     0,     0,    12,    13,   256,    14,     0,     0,
       0,    15,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    16,     0,     0,     0,     0,
       0,     0,    17,    18,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    19,    20,     0,     0,     0,    21,    22,
      23,    24,     0,     0,     0,     0,     0,    25,    26,    27,
       0,     0,     0,    28,     0,     0,     0,     0,     1,     0,
       2,     0,    29,    30,     3,     0,     0,     0,     0,     0,
       0,    31,     0,     0,     0,     0,     0,     4,     0,     0,
       0,    32,     0,    33,     0,    34,     0,    35,    36,    37,
      38,    39,    40,    41,    42,    43,    44,     0,     0,     5,
       6,     0,     0,     0,     0,     0,     0,   474,     0,     0,
       0,     0,     0,     0,     0,     8,     0,     0,     0,     0,
       9,     0,     0,     0,   475,     0,     0,     0,     0,     0,
       0,    10,     0,     0,     0,    11,     0,     0,    12,    13,
       0,    14,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    16,
       0,     0,     0,     0,     0,     0,    17,    18,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    19,    20,     0,
       0,     0,    21,    22,    23,    24,     0,     0,     0,     0,
       0,    25,    26,    27,     0,     0,     0,    28,     0,     0,
       0,     0,     1,     0,     2,     0,    29,    30,     3,     0,
       0,     0,     0,     0,     0,    31,     0,     0,     0,     0,
       0,     4,     0,     0,     0,    32,     0,    33,     0,    34,
       0,    35,    36,    37,    38,    39,    40,    41,    42,    43,
      44,     0,     0,     5,     6,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     9,     0,     0,   403,     0,     0,
       0,     0,     0,     0,     0,    10,     0,     0,     0,    11,
       0,     0,    12,    13,     0,    14,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    16,     0,     0,     0,     0,     0,     0,
      17,    18,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    19,    20,     0,     0,     1,    21,     2,    23,    24,
       0,     3,     0,     0,     0,    25,    26,    27,     0,     0,
       0,    28,     0,     0,     4,     0,     0,     0,     0,     0,
       0,    30,     0,     0,     0,     0,     0,     0,   404,    31,
       0,     0,     0,     0,     0,     0,     5,     6,     0,    32,
       0,    33,     0,    34,     0,    35,    36,    37,    38,    39,
      40,    41,    42,    43,    44,     0,     0,     9,     0,     0,
     403,     0,     0,     0,     0,     0,     0,     0,    10,     0,
     394,     0,    11,     0,     0,     0,    13,     0,    14,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    16,     0,     0,     0,
       0,     0,     0,    17,    18,     1,     0,     2,     0,     0,
       0,     3,     0,     0,    19,    20,     0,     0,     0,    21,
       0,    23,    24,     0,     4,     0,     0,     0,    25,    26,
      27,     0,     0,     0,    28,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    30,     0,     5,     6,     0,     0,
     395,     0,    31,     0,   474,     0,     0,     0,     0,     0,
       0,     0,   396,     0,    33,     0,    34,     9,    35,    36,
      37,    38,    39,   116,    41,    42,    43,    44,    10,     0,
     394,     0,    11,     0,     0,     0,    13,     0,    14,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    16,     0,     0,     0,
       0,     0,     0,    17,    18,     1,     0,     2,     0,     0,
       0,     3,     0,     0,    19,    20,     0,     0,     0,    21,
       0,    23,    24,     0,     4,     0,     0,     0,    25,    26,
      27,     0,     0,     0,    28,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    30,     0,     5,     6,     0,     0,
     395,     0,    31,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   396,     0,    33,     0,    34,     9,    35,    36,
      37,    38,    39,   116,    41,    42,    43,    44,    10,     0,
     394,     0,    11,     0,     0,     0,    13,     0,    14,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    16,     0,     0,     0,
       0,     0,     0,    17,    18,     1,     0,     2,     0,     0,
       0,     3,     0,     0,    19,    20,     0,     0,     0,    21,
       0,    23,    24,     0,     4,     0,     0,     0,    25,    26,
      27,     0,     0,     0,    28,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    30,     0,     5,     6,     0,     0,
     395,     0,    31,     0,   474,     0,     0,     0,     0,     0,
       0,     0,   396,     0,    33,     0,    34,     9,    35,    36,
      37,    38,    39,   116,    41,    42,    43,    44,    10,     0,
       0,     0,    11,     0,     0,    12,    13,     0,    14,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    16,     0,     0,     0,
       0,     0,     0,    17,    18,     1,     0,     2,     0,     0,
       0,     3,     0,     0,    19,    20,     0,     0,     0,    21,
       0,    23,    24,     0,     4,     0,     0,     0,    25,    26,
      27,     0,     0,     0,    28,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    30,     0,     5,     6,     0,     0,
       0,     0,    31,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    32,     0,    33,     0,    34,     9,    35,    36,
      37,    38,    39,    40,    41,    42,    43,    44,    10,     0,
       0,     0,    11,     0,     0,    12,    13,     0,    14,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    16,     0,     0,     0,
       0,     0,     0,    17,    18,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    19,    20,     0,     0,     1,    21,
       2,    23,    24,     0,     3,     0,     0,     0,    25,    26,
      27,     0,     0,     0,    28,     0,     0,     4,     0,     0,
       0,     0,     0,     0,    30,     0,     0,     0,     0,     0,
       0,     0,    31,     0,     0,     0,     0,     0,     0,     5,
       6,     0,   374,     0,    33,     0,    34,     0,    35,    36,
      37,    38,    39,    40,    41,    42,    43,    44,     0,     0,
       9,     0,     0,   403,     0,     0,     0,     0,     0,     0,
       0,    10,     0,     0,     0,    11,     0,     0,     0,    13,
       0,    14,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    16,
       0,     0,     0,     0,     0,     0,    17,    18,     1,     0,
       2,     0,     0,     0,     3,     0,     0,    19,    20,     0,
       0,     0,    21,     0,    23,    24,     0,     4,     0,     0,
       0,    25,    26,    27,     0,     0,     0,    28,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    30,     0,     5,
       6,     0,     0,     0,     0,    31,     0,   474,     0,     0,
       0,     0,     0,     0,     0,   374,     0,    33,     0,    34,
       9,    35,    36,    37,    38,    39,   116,    41,    42,    43,
      44,    10,     0,     0,     0,    11,     0,     0,     0,    13,
       0,    14,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    16,
       0,     0,     0,     0,     0,     0,    17,    18,     1,     0,
       2,     0,     0,     0,     3,     0,     0,    19,    20,     0,
       0,     0,    21,     0,    23,    24,     0,     4,     0,     0,
       0,    25,    26,    27,     0,     0,     0,    28,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    30,     0,     5,
       6,     0,     0,     0,     0,    31,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   374,     0,    33,     0,    34,
       9,    35,    36,    37,    38,    39,   116,    41,    42,    43,
      44,    10,     0,     0,     0,    11,     0,     0,     0,    13,
       0,    14,     0,     0,     0,     0,     1,     0,     2,     0,
       0,     0,     0,     0,     0,     0,     1,     0,     2,    16,
       0,     0,     0,     0,     0,     0,    17,    18,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    19,    20,     0,
       0,     0,    21,     0,    23,    24,     0,     0,     0,     0,
       0,    25,    26,    27,   230,     0,     0,    28,     0,     0,
       0,   233,     0,     0,   230,     0,     0,    30,     0,     0,
       0,   233,     0,   237,   238,    31,     0,     0,     0,     0,
       0,     0,     0,   237,   238,   374,     0,    33,     0,    34,
       0,    35,    36,    37,    38,    39,   116,    41,    42,    43,
      44,     0,     0,     0,     0,     0,     0,    16,     0,     0,
       0,   840,     0,     0,     0,     0,     0,    16,   262,     0,
       0,     0,     0,   264,   265,     0,     0,     0,   262,     0,
       0,     0,     0,   264,   265,     0,     0,   269,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   269,     0,     0,
       0,     0,     0,     0,     0,    30,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    30,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    35,
      36,    37,    38,    39,   116,    41,    42,    43,    44,    35,
      36,    37,    38,    39,   116,    41,    42,    43,    44,   121,
       0,   122,     0,     0,     0,     0,     0,     0,     0,     0,
     123,     0,     0,   124,     0,   125,   126,     0,     0,     0,
       0,     0,     0,     0,   127,     0,     0,     0,     0,     7,
       0,     0,     0,     0,     0,   128,     0,     0,     0,     0,
     129,     0,     0,     0,     0,     0,     0,   130,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   131,     0,     0,
       0,     0,     0,     0,    15,   132,     0,   133,     0,     0,
       0,   134,     0,   135,     0,     0,     0,     0,     0,     0,
     136,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   137,     0,   138,     0,     0,     0,     0,     0,     0,
     139,     0,     0,     0,     0,   140,     0,     0,     0,   141,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   142,
       0,     0,     0,     0,   143,     0,     0,     0,     0,     0,
       0,     0,   144,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   145,     0,   121,     0,   122,
      35,   146,   147,    38,   148,   149,   150,   151,   123,    44,
       0,   124,     0,   125,   126,     0,     0,     0,     0,     0,
       0,     0,   127,     0,     0,     0,     0,     7,     0,     0,
       0,     0,     0,   128,   121,     0,   122,     0,   129,     0,
       0,     0,     0,     0,     0,   130,     0,     0,   124,     0,
     125,   126,     0,     0,     0,   131,     0,     0,     0,   127,
       0,     0,    15,   132,     7,   133,     0,     0,     0,   134,
     128,   135,     0,     0,     0,   129,     0,     0,   136,     0,
       0,     0,   130,     0,     0,     0,     0,     0,     0,   137,
       0,   138,     0,     0,     0,     0,     0,     0,   139,    15,
     132,     0,   133,   140,     0,     0,   134,   141,   135,     0,
       0,     0,     0,     0,     0,   136,     0,   142,     0,     0,
       0,     0,   143,     0,     0,     0,     0,     0,     0,     0,
     144,     0,     0,     0,     0,   139,     0,     0,     0,     0,
     140,     0,     0,   145,   141,     0,     0,     0,     0,     0,
       0,     0,    39,     0,   142,     0,     0,     0,     0,   143,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     145,     0,     0,     0,     0,     0,     0,     0,     0,    39
};

static const yytype_int16 yycheck[] =
{
       0,    77,     2,   158,   324,     5,    24,     1,   370,    58,
     320,    91,   387,   183,    63,    50,   300,   301,   388,    91,
      91,    80,   101,    23,    24,    25,   303,    27,    28,   382,
      69,   384,   385,   386,    83,     4,    67,   100,     0,     8,
     631,   170,     8,    91,    79,    76,    22,     0,   364,    12,
      50,   648,   168,    22,   171,     4,    91,     0,   399,     0,
      20,    76,    80,    88,     8,     9,    18,    67,    68,    69,
       0,    20,     5,   383,    74,    93,    76,    22,    78,    79,
      80,     5,    77,    11,    69,    86,    86,   151,   851,    22,
      18,    91,    92,    93,    94,     8,    96,    50,    22,    12,
      98,    20,     5,     8,    20,    20,    22,   107,   172,   109,
       6,   111,   112,   522,    67,    68,    78,    36,     6,    22,
       6,    74,    18,    76,    73,    78,    79,   718,   196,    37,
      51,    20,    94,    48,   135,    94,     8,    69,    91,    92,
      12,    94,   597,    96,   183,    14,    98,    16,   124,    70,
      24,    94,   170,    94,   107,    20,   109,    29,   111,   112,
      48,   156,     5,    69,    94,     8,     9,   165,    57,     0,
     170,     8,     9,   628,    39,    96,   939,    85,   553,   124,
     180,    24,   979,   183,    58,     8,     9,   100,   167,    11,
      49,   124,    23,   990,    71,    17,    27,    28,   183,   120,
     124,   191,   171,    80,    93,   171,     6,   207,   124,   379,
     210,   211,   975,   165,   576,    58,   210,    54,     5,    50,
     180,   124,   207,   142,   184,   634,    49,   172,   100,   173,
     347,   180,   191,   192,    91,   184,    67,    68,    25,     4,
      99,   318,   155,    74,   173,    76,     4,    78,    79,   162,
     591,   183,   199,   200,   331,    20,   853,   210,   211,     6,
      91,    92,   139,    94,   123,    96,   171,   608,   127,   631,
     187,    29,    69,    20,   191,   207,   107,   183,   109,   242,
     111,   112,   346,   155,   364,   162,   627,     6,   629,     6,
     162,   180,    65,    67,    68,   184,     6,    23,     5,    86,
      74,   170,   677,    20,    91,   382,     0,   384,   618,     6,
     328,   595,   596,    39,   630,   906,   600,    24,    92,     4,
     320,    94,   191,   676,   601,   602,   195,   196,   328,   364,
     365,    48,   189,    83,   369,    11,     4,     8,     9,   468,
     379,    17,   199,   200,    29,     4,   377,   938,   348,   367,
     350,    58,    20,    24,   372,   128,    50,   130,    83,     8,
       9,    20,   377,    83,   364,   365,   425,   367,   368,   369,
     242,    20,   372,    67,    68,   406,   370,   377,   347,   379,
      74,   347,    76,   383,    78,    79,   183,    58,   423,     4,
       6,   406,     4,    18,   379,   467,   467,    91,    92,   399,
      94,     6,    96,    28,   370,    20,   406,   425,    20,   427,
     526,   364,   365,   107,   127,   109,   369,   111,   112,   467,
     499,   446,    11,   423,   377,   425,    11,   427,   544,    18,
     430,    20,   467,    18,   497,   404,   845,   846,   404,   140,
     440,    18,   347,    20,    11,   430,   477,   379,   149,   449,
     468,    18,   153,   406,   191,   440,    21,   194,     8,     9,
     524,   525,   477,    13,   449,   370,    18,   467,   468,     6,
     423,   833,    96,   379,    24,     6,   107,   477,   109,   479,
     111,   112,    18,   107,    20,   109,   180,   111,   112,   195,
     196,   404,   349,   350,     8,     9,     4,    20,   370,   404,
     875,   550,   579,    11,    29,   505,    20,   507,    58,   509,
      18,   511,     4,   883,   467,     8,     9,   479,   688,   635,
      13,    29,   832,   180,   477,    20,   479,   184,    15,   882,
      20,    24,   404,   364,   365,    11,     4,     5,   369,   518,
     519,   520,   521,   505,   906,   507,   377,   509,    20,   511,
     630,   173,   505,   115,   507,    24,   509,   119,   511,   528,
       5,   348,   528,     8,     9,    58,   188,   189,   547,   191,
     192,   193,   365,   857,   858,   406,   369,   364,     8,     9,
     549,     6,   379,   380,   497,   382,     6,   384,   385,   386,
      20,   591,   423,     8,     9,   630,     6,   597,    20,   676,
      69,     6,     8,     9,     6,   574,     4,     5,   608,   658,
     467,    80,     6,   613,    20,     6,   936,   617,   618,   619,
     620,   621,     9,   528,    93,   497,   128,   627,   628,   629,
     630,     0,    20,   682,   619,   115,   467,   631,     8,     9,
       4,   513,     4,     5,   516,     4,   477,    20,   479,   688,
      20,   690,     9,   692,    20,   694,   350,    20,    20,    21,
       4,     5,   697,   779,   780,   631,    20,   620,   621,   700,
     364,   365,     4,     5,   505,   369,   507,   630,   509,    20,
     511,    50,    20,   377,    20,   700,    20,   687,   688,   689,
       6,   691,   692,    54,   694,     6,   851,   697,    67,    68,
     700,   170,    11,   688,   576,    74,     6,    76,     6,    78,
      79,   617,   406,     7,   183,   746,   188,   189,     6,   719,
     192,   193,    91,    92,   718,    94,   631,    96,     0,   423,
     730,   746,   589,     6,    24,    28,    29,    30,   107,     6,
     109,     6,   111,   112,   697,   730,   746,   700,     4,     5,
     188,   189,    12,   830,   192,   193,   688,   689,     6,   631,
     692,     5,   694,    18,     8,     9,   188,   189,   625,   191,
     192,   193,     6,   467,     4,     5,   745,    20,    50,    69,
       0,   687,   688,   477,   939,   479,   692,   191,   694,   197,
      80,   195,   196,   746,     6,    67,    68,   874,   792,   630,
     877,     6,    74,    93,    76,   882,    78,    79,     4,     5,
     886,   505,     6,   507,     5,   509,     6,   511,   818,    91,
      92,   618,    94,     6,    96,   188,   189,     4,     5,   192,
     193,    78,   832,     4,     5,   107,    20,   109,     6,   111,
     112,     6,   860,   630,   862,   811,   718,    67,    68,     5,
       4,     5,     8,     9,    74,   479,    76,     6,    78,   328,
     860,     6,   862,   863,     4,     5,   697,   833,     6,   700,
       4,     5,    92,     5,    94,    19,     8,     9,   675,   676,
     170,   505,     6,   507,    69,   509,   818,   511,     4,     5,
      14,   688,    16,   183,    11,   692,     6,   694,   367,   368,
      85,   188,   189,   372,   191,   192,   193,    51,    93,   138,
     379,    20,   906,     5,    14,   746,    16,   207,   187,     4,
     792,   190,   191,    20,   193,   194,    70,   196,    89,   964,
     399,     5,   719,    77,     8,     9,   630,   972,   187,   811,
     906,   190,   191,    20,   938,   194,   195,   196,   983,    20,
       0,     5,    96,     6,     8,     9,   425,    48,   427,   187,
      10,   833,   931,   191,   964,    20,   199,   195,   196,     4,
       5,    21,   972,    20,   159,     5,   120,     5,     8,     9,
       8,     9,   167,   983,    20,   170,    25,    26,    27,    28,
      29,    30,    31,    32,   179,   364,   365,     5,   183,   468,
     369,   186,    20,   697,     4,     5,   700,     5,   377,   162,
       5,   964,   156,     8,     9,   115,    20,    67,    68,   972,
       4,     5,   207,    11,    74,     4,    76,    20,    78,    20,
     983,     5,     5,   938,   906,     8,     9,   406,   328,     5,
     198,    11,    92,    15,    94,     6,    96,    11,    17,    11,
      18,     5,   746,    20,   423,   173,     5,   107,   173,   109,
      19,   111,   112,   163,     5,    20,   938,   191,    20,    20,
      20,   195,   196,    20,    20,   199,   200,   367,   368,   118,
      11,    20,   372,    20,    20,   882,   200,   187,    20,   379,
     190,   191,   364,   365,   194,   195,   196,   369,   467,    20,
      20,     5,    78,     5,     5,   377,    52,    53,   477,   399,
     479,    14,     4,    16,     5,    61,     6,    20,     5,    29,
       6,    47,   591,     5,     5,    51,    52,    11,    54,   173,
      56,    77,     5,   964,   406,   425,   505,   427,   507,   608,
     509,   972,   511,    19,     5,   195,     5,    62,    19,     6,
      20,   423,   983,    19,    69,    20,   102,   377,   627,     5,
     629,    64,    20,    19,   110,   404,    81,    82,   353,   155,
     187,   188,   189,   190,   191,   192,   193,   194,   468,   196,
     162,   528,   605,   368,   863,   736,   406,   306,   229,   613,
     387,   692,   118,   983,   379,   467,   694,   423,    78,   467,
     146,   425,   185,   106,   367,   477,   446,   479,     0,    12,
     156,   126,   115,   393,   399,    12,   131,   132,    12,   688,
     501,   690,   125,   692,    -1,   694,   480,    -1,    -1,    -1,
     145,    -1,    -1,   505,    -1,   507,   182,   509,    -1,   511,
      -1,    -1,    -1,   428,   429,   191,   431,    -1,    -1,    -1,
      -1,    -1,     0,   438,   439,    -1,   159,   477,    -1,    -1,
     163,   630,    -1,   166,   449,    -1,    -1,    -1,    -1,    -1,
     964,   197,   198,    -1,    -1,   298,   191,    -1,   972,    -1,
     195,   196,    -1,   468,   187,    -1,    -1,   190,   191,   983,
      -1,   194,   195,   196,    -1,    -1,     6,    -1,    -1,    -1,
     226,   591,    -1,   229,   187,   188,   189,   597,   191,   192,
     193,   194,    -1,    -1,    -1,    -1,    -1,    -1,   608,    67,
      68,    69,    -1,    -1,    -1,    -1,    74,   377,   697,    -1,
      78,   700,    -1,   518,   519,   520,   521,   627,   628,   629,
      -1,    -1,    52,    53,    92,    -1,    94,    -1,    96,    -1,
      -1,    61,    -1,   403,    -1,    -1,   406,   380,   630,   107,
      -1,   109,   547,   111,   112,    -1,    -1,    77,    -1,    -1,
       6,   297,    -1,    -1,    84,    -1,    -1,   746,    14,    -1,
      16,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   314,    -1,
      -1,   860,   102,   862,   863,    -1,    -1,    -1,   688,   689,
     110,    -1,   692,   298,   694,    -1,   591,    -1,    -1,    -1,
     433,    -1,   597,    -1,    -1,    51,    52,   343,    -1,    -1,
      -1,    -1,    -1,   608,   474,   697,    -1,   477,   700,   479,
      -1,    -1,    62,    -1,    70,   183,   146,    -1,    -1,    69,
      -1,   464,   627,   628,   629,    -1,   156,    -1,    14,    -1,
      16,    81,    82,   638,    90,   505,    -1,   507,    -1,   509,
      96,   511,    -1,   648,    -1,    -1,   516,    -1,    -1,    -1,
      -1,    -1,   182,    -1,   746,    -1,    -1,    -1,    -1,    -1,
     700,   191,    -1,    -1,   120,   380,   122,   123,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   126,    -1,    64,   684,
      -1,   131,   132,   688,   689,    -1,    -1,   692,    -1,   694,
     533,    -1,    -1,    -1,    -1,   145,    -1,    -1,   703,   704,
     705,   706,   707,    -1,    -1,   548,   746,   163,   818,    -1,
      -1,    -1,    -1,    -1,   557,    -1,    -1,    -1,   433,   724,
     106,   177,    -1,   728,   729,   730,    -1,    -1,    -1,   115,
     186,   187,   188,   189,   577,   191,   192,   193,   194,   125,
     190,   191,    -1,    -1,    -1,   195,   196,    -1,    -1,   464,
     860,    -1,   862,   863,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   631,    -1,    -1,    -1,    -1,   512,    -1,   514,    21,
      -1,    -1,    -1,   159,    -1,   964,    -1,   163,    -1,    -1,
     166,    -1,    -1,   972,    36,    -1,    38,    -1,    -1,   794,
      -1,   796,    -1,    -1,   983,    -1,    -1,    -1,    50,    -1,
      -1,   187,    -1,   646,   190,   191,    -1,   650,   194,   195,
     196,   379,    21,   818,    66,    -1,    -1,    -1,   533,   662,
      72,    -1,    -1,    -1,    -1,    -1,    -1,    36,    -1,    38,
     700,    -1,   675,   548,    -1,    -1,    52,    53,    -1,    -1,
      -1,    50,   557,    -1,   849,    61,    -1,   852,   853,   101,
      -1,    -1,   104,    -1,    -1,    -1,   108,    66,   863,    -1,
      -1,    77,   577,    72,    -1,   117,    -1,    -1,    84,   712,
     713,    -1,   964,   716,    -1,    -1,   746,    -1,   721,   722,
     972,    -1,    -1,    -1,    -1,   137,   102,    -1,   731,    -1,
     142,   983,   101,    -1,   110,   104,    -1,    -1,    -1,   108,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   117,   161,
      -1,   479,    -1,    -1,    -1,    -1,    -1,    -1,    36,    -1,
      38,    -1,   668,   669,   670,   671,    -1,    -1,   137,    -1,
     146,   646,    50,   142,    -1,   650,    -1,   505,    -1,   507,
     156,   509,    -1,   511,    -1,    -1,    -1,   662,    66,    -1,
      -1,    62,   161,    -1,    72,    -1,    -1,    -1,    69,    -1,
     675,    -1,    -1,   833,    -1,    -1,   182,    -1,   973,    -1,
      81,    82,    -1,    -1,    -1,   191,    -1,   820,    -1,    -1,
      -1,    -1,    -1,   101,    -1,    -1,   104,   992,    -1,    -1,
     108,    -1,    -1,    -1,   837,    -1,    -1,   712,   713,   117,
      -1,   716,    -1,    -1,    -1,   848,   721,   722,    -1,    -1,
      -1,   854,    -1,    -1,    -1,   126,   731,    -1,    -1,   137,
     131,   132,    -1,    -1,   142,    -1,    -1,   773,    -1,    -1,
     873,    -1,    -1,   876,   145,    -1,   906,    -1,    -1,    -1,
      -1,    -1,    -1,   161,    -1,    -1,     6,    -1,   891,   892,
     893,   894,   895,    -1,    14,    -1,    16,    -1,    -1,    -1,
     903,   904,   905,    -1,   810,    -1,   812,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   187,   188,   189,   190,
     191,   192,   193,   194,   195,   196,   929,   930,    -1,    -1,
      -1,    51,    52,    -1,    -1,    -1,   842,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   820,    -1,    -1,   951,    -1,
      70,    -1,   955,    -1,    -1,     0,    -1,    -1,    -1,    -1,
     688,    -1,   837,   691,   692,    -1,   694,    -1,    -1,    14,
      90,    16,    -1,   848,    -1,    20,    96,    -1,    -1,   854,
      -1,    -1,    -1,    -1,    -1,   988,    -1,    -1,    33,    -1,
      -1,    -1,    -1,   996,    -1,    -1,    -1,    -1,   873,    -1,
     120,   876,   122,   123,    -1,    -1,    -1,    -1,    -1,    -1,
      55,    56,    -1,    -1,    -1,    -1,   891,   892,   893,   894,
     895,    -1,    -1,    -1,    -1,    -1,    71,    -1,   903,   904,
     905,    76,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    87,   163,    -1,    -1,    91,    -1,    -1,    94,
      95,    -1,    97,    -1,   929,   930,    -1,   177,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   186,   187,   188,   189,
     115,   191,   192,   193,   194,    -1,   951,   122,   123,    -1,
     955,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   133,   134,
      -1,    -1,    -1,   138,   139,   140,   141,    -1,    -1,    -1,
      -1,    -1,   147,   148,   149,    -1,    -1,    -1,   153,    -1,
      -1,    -1,    -1,   988,    -1,    -1,    -1,   162,   163,    -1,
      -1,   996,    -1,    -1,    -1,    -1,   171,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   181,    -1,   183,    -1,
     185,    -1,   187,   188,   189,   190,   191,   192,   193,   194,
     195,   196,     6,    -1,     8,     9,    -1,    -1,    -1,    -1,
      14,    -1,    16,    -1,    -1,    -1,    20,    -1,    -1,    -1,
      -1,    25,    26,    27,    -1,    -1,    -1,    -1,    -1,    -1,
      34,    35,    -1,    -1,    -1,    -1,    40,    41,    42,    43,
      44,    45,    46,    -1,    -1,    -1,    -1,    51,    52,    -1,
      -1,    -1,    -1,    -1,    -1,    59,    60,    61,    62,    -1,
      64,    -1,    -1,    67,    68,    69,    70,    -1,    -1,    -1,
      74,    75,    -1,    -1,    -1,    -1,    -1,    81,    82,    -1,
      -1,    -1,    -1,    -1,    88,    -1,    90,    -1,    92,    -1,
      94,    -1,    96,    -1,    -1,    -1,   100,    -1,   102,   103,
      -1,   105,   106,   107,    -1,   109,   110,   111,   112,   113,
     114,   115,   116,    -1,   118,   119,   120,   121,   122,   123,
      -1,   125,   126,    -1,    -1,   129,    -1,   131,   132,    -1,
      -1,    -1,   136,    -1,    -1,    -1,    -1,    -1,    -1,   143,
     144,   145,   146,    -1,    -1,    -1,   150,   151,   152,    -1,
     154,   155,    -1,   157,   158,   159,   160,    -1,    -1,   163,
     164,    -1,   166,   167,   168,    -1,    -1,    -1,    -1,    -1,
     174,   175,   176,   177,   178,   179,    -1,    -1,   182,    -1,
      -1,    -1,   186,   187,   188,   189,   190,   191,   192,   193,
     194,   195,   196,   197,    -1,   199,   200,   201,     6,    -1,
       8,     9,    -1,    -1,    -1,    -1,    14,    -1,    16,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    25,    26,    27,
      -1,    -1,    -1,    -1,    -1,    -1,    34,    35,    -1,    -1,
      -1,    -1,    40,    41,    42,    43,    44,    45,    46,    -1,
      -1,    -1,    -1,    51,    52,    -1,    -1,    -1,    -1,    -1,
      -1,    59,    60,    61,    62,    -1,    64,    -1,    -1,    67,
      68,    69,    70,    -1,    -1,    -1,    74,    75,    -1,    -1,
      -1,    -1,    -1,    81,    82,    -1,    -1,    -1,    -1,    -1,
      88,    -1,    90,    -1,    92,    -1,    94,    -1,    96,    -1,
      -1,    -1,   100,    -1,   102,   103,    -1,   105,   106,   107,
      -1,   109,   110,   111,   112,   113,   114,   115,   116,    -1,
     118,   119,   120,   121,   122,   123,    -1,   125,   126,    -1,
      -1,   129,    -1,   131,   132,    -1,    -1,    -1,   136,    -1,
      -1,    -1,    -1,    -1,    -1,   143,   144,   145,   146,    -1,
      -1,    -1,   150,   151,   152,    -1,   154,   155,    -1,   157,
     158,   159,   160,    -1,    -1,   163,   164,    -1,   166,   167,
     168,    -1,    -1,    -1,    -1,    -1,   174,   175,   176,   177,
     178,   179,    -1,    -1,   182,    -1,    -1,    -1,   186,   187,
     188,   189,   190,   191,   192,   193,   194,   195,   196,   197,
      -1,   199,   200,   201,     6,    -1,     8,     9,    -1,    -1,
      -1,    -1,    14,    -1,    16,    -1,    -1,    -1,    20,    -1,
      -1,    -1,    -1,    25,    26,    27,    -1,    -1,    -1,    -1,
      -1,    -1,    34,    35,    -1,    -1,    -1,    -1,    40,    41,
      42,    43,    44,    45,    46,    -1,    -1,    -1,    -1,    51,
      52,    -1,    -1,    -1,    -1,    -1,    -1,    59,    60,    61,
      62,    -1,    -1,    -1,    -1,    67,    68,    69,    70,    -1,
      -1,    -1,    74,    75,    -1,    -1,    -1,    -1,    -1,    81,
      82,    -1,    -1,    -1,    -1,    -1,    88,    -1,    90,    -1,
      92,    -1,    94,    -1,    96,    -1,    -1,    -1,   100,    -1,
     102,   103,    -1,   105,    -1,   107,    -1,   109,   110,   111,
     112,   113,   114,   115,   116,    -1,   118,   119,   120,   121,
     122,   123,    -1,    -1,   126,    -1,    -1,   129,    -1,   131,
     132,    -1,    -1,    -1,   136,    -1,    -1,    -1,    -1,    -1,
      -1,   143,   144,   145,   146,    -1,    -1,    -1,   150,   151,
     152,    -1,   154,   155,    -1,   157,   158,    -1,   160,    -1,
      -1,   163,   164,    -1,    -1,   167,   168,    -1,    -1,    -1,
      -1,    -1,   174,   175,   176,   177,   178,   179,    -1,    -1,
     182,    -1,    -1,    -1,   186,   187,   188,   189,   190,   191,
     192,   193,   194,   195,   196,   197,    -1,   199,   200,   201,
       6,    -1,     8,     9,    10,    -1,    -1,    -1,    14,    -1,
      16,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    25,
      26,    27,    -1,    -1,    -1,    -1,    -1,    -1,    34,    35,
      -1,    -1,    -1,    -1,    40,    41,    42,    43,    44,    45,
      46,    -1,    -1,    -1,    -1,    51,    52,    -1,    -1,    -1,
      -1,    -1,    -1,    59,    60,    61,    62,    -1,    -1,    -1,
      -1,    67,    68,    69,    70,    -1,    -1,    -1,    74,    75,
      -1,    -1,    -1,    -1,    -1,    81,    82,    -1,    -1,    -1,
      -1,    -1,    88,    -1,    90,    -1,    92,    -1,    94,    -1,
      96,    -1,    -1,    -1,   100,    -1,   102,   103,    -1,   105,
      -1,   107,    -1,   109,   110,   111,   112,   113,   114,   115,
     116,    -1,   118,   119,   120,   121,   122,   123,    -1,    -1,
     126,    -1,    -1,   129,    -1,   131,   132,    -1,    -1,    -1,
     136,    -1,    -1,    -1,    -1,    -1,    -1,   143,   144,   145,
     146,    -1,    -1,    -1,   150,   151,   152,    -1,   154,   155,
      -1,   157,   158,    -1,   160,    -1,    -1,   163,   164,    -1,
      -1,   167,   168,    -1,    -1,    -1,    -1,    -1,   174,   175,
     176,   177,   178,   179,    -1,    -1,   182,    -1,    -1,    -1,
     186,   187,   188,   189,   190,   191,   192,   193,   194,   195,
     196,   197,    -1,   199,   200,   201,     6,    -1,     8,     9,
      -1,    -1,    -1,    -1,    14,    -1,    16,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    25,    26,    27,    -1,    -1,
      -1,    -1,    -1,    -1,    34,    35,    -1,    -1,    -1,    -1,
      40,    41,    42,    43,    44,    45,    46,    -1,    -1,    -1,
      -1,    51,    52,    -1,    -1,    -1,    -1,    -1,    -1,    59,
      60,    61,    62,    -1,    -1,    -1,    -1,    67,    68,    69,
      70,    -1,    -1,    -1,    74,    75,    -1,    -1,    -1,    -1,
      -1,    81,    82,    -1,    -1,    -1,    -1,    -1,    88,    -1,
      90,    91,    92,    -1,    94,    -1,    96,    -1,    -1,    -1,
     100,    -1,   102,   103,    -1,   105,    -1,   107,    -1,   109,
     110,   111,   112,   113,   114,   115,   116,    -1,   118,   119,
     120,   121,   122,   123,    -1,    -1,   126,    -1,    -1,   129,
      -1,   131,   132,    -1,    -1,    -1,   136,    -1,    -1,    -1,
      -1,    -1,    -1,   143,   144,   145,   146,    -1,    -1,    -1,
     150,   151,   152,    -1,   154,   155,    -1,   157,   158,    -1,
     160,    -1,    -1,   163,   164,    -1,    -1,   167,   168,    -1,
      -1,    -1,    -1,    -1,   174,   175,   176,   177,   178,   179,
      -1,    -1,   182,    -1,    -1,    -1,   186,   187,   188,   189,
     190,   191,   192,   193,   194,   195,   196,   197,    -1,   199,
     200,   201,     6,    -1,     8,     9,    -1,    -1,    -1,    -1,
      14,    -1,    16,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    25,    26,    27,    -1,    -1,    -1,    -1,    -1,    -1,
      34,    35,    -1,    -1,    -1,    -1,    40,    41,    42,    43,
      44,    45,    46,    -1,    -1,    -1,    -1,    51,    52,    -1,
      -1,    -1,    -1,    -1,    -1,    59,    60,    61,    62,    -1,
      -1,    -1,    -1,    67,    68,    69,    70,    -1,    -1,    -1,
      74,    75,    -1,    -1,    -1,    -1,    -1,    81,    82,    -1,
      -1,    -1,    -1,    -1,    88,    -1,    90,    -1,    92,    -1,
      94,    -1,    96,    -1,    -1,    -1,   100,    -1,   102,   103,
      -1,   105,    -1,   107,    -1,   109,   110,   111,   112,   113,
     114,   115,   116,    -1,   118,   119,   120,   121,   122,   123,
      -1,    -1,   126,    -1,    -1,   129,    -1,   131,   132,    -1,
      -1,    -1,   136,    -1,    -1,    -1,    -1,    -1,    -1,   143,
     144,   145,   146,    -1,    -1,    -1,   150,   151,   152,    -1,
     154,   155,    -1,   157,   158,    -1,   160,    -1,    -1,   163,
     164,    -1,    -1,   167,   168,    -1,    -1,    -1,    -1,    -1,
     174,   175,   176,   177,   178,   179,    -1,    -1,   182,    -1,
      -1,    -1,   186,   187,   188,   189,   190,   191,   192,   193,
     194,   195,   196,   197,    -1,   199,   200,   201,     6,    -1,
       8,     9,    -1,    -1,    -1,    -1,    14,    -1,    16,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    25,    26,    27,
      -1,    -1,    -1,    -1,    -1,    -1,    34,    35,    -1,    -1,
      -1,    -1,    40,    41,    42,    43,    44,    45,    46,    -1,
      -1,    -1,    -1,    51,    52,    -1,    -1,    -1,    -1,    -1,
      -1,    59,    60,    61,    62,    -1,    -1,    -1,    -1,    67,
      68,    69,    70,    -1,    -1,    -1,    74,    75,    -1,    -1,
      -1,    -1,    -1,    81,    82,    -1,    -1,    -1,    -1,    -1,
      88,    -1,    90,    -1,    92,    -1,    94,    -1,    96,    -1,
      -1,    -1,   100,    -1,   102,   103,    -1,   105,    -1,   107,
      -1,   109,   110,   111,   112,   113,   114,   115,   116,    -1,
     118,   119,   120,   121,   122,   123,    -1,    -1,   126,    -1,
      -1,   129,    -1,   131,   132,    -1,    -1,    -1,   136,    -1,
      -1,    -1,    -1,    -1,    -1,   143,   144,   145,   146,    -1,
      -1,    -1,   150,   151,   152,    -1,   154,   155,    -1,   157,
     158,    -1,   160,    -1,    -1,   163,   164,    -1,    -1,   167,
     168,    -1,    -1,    -1,    -1,    -1,   174,   175,   176,   177,
     178,   179,    -1,    -1,   182,    -1,    -1,    -1,   186,   187,
     188,   189,   190,   191,   192,   193,   194,   195,   196,   197,
      -1,   199,   200,   201,     6,    -1,     8,     9,    -1,    -1,
      -1,    -1,    14,    -1,    16,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    25,    26,    27,    -1,    -1,    -1,    -1,
      -1,    -1,    34,    35,    -1,    -1,    -1,    -1,    40,    41,
      42,    43,    44,    45,    46,    -1,    -1,    -1,    -1,    51,
      52,    -1,    -1,    -1,    -1,    -1,    -1,    59,    60,    61,
      62,    -1,    -1,    -1,    -1,    67,    68,    69,    70,    -1,
      -1,    -1,    74,    75,    -1,    -1,    -1,    -1,    -1,    81,
      82,    -1,    -1,    -1,    -1,    -1,    88,    -1,    90,    -1,
      92,    -1,    -1,    -1,    96,    -1,    -1,    -1,   100,    -1,
     102,   103,    -1,   105,    -1,   107,    -1,   109,   110,   111,
     112,   113,   114,    -1,   116,    -1,   118,    -1,   120,   121,
     122,   123,    -1,    -1,   126,    -1,    -1,   129,    -1,   131,
     132,    -1,    -1,    -1,   136,    -1,    -1,    -1,    -1,    -1,
      -1,   143,   144,   145,   146,    -1,    -1,    -1,   150,   151,
     152,    -1,   154,   155,    -1,   157,   158,    -1,   160,    -1,
      -1,   163,   164,    -1,    -1,   167,   168,    -1,    -1,    -1,
      -1,    -1,   174,   175,   176,   177,   178,   179,    -1,    -1,
     182,    -1,    -1,    -1,   186,   187,   188,   189,   190,   191,
     192,   193,   194,   195,   196,   197,    -1,   199,   200,   201,
       6,    -1,     8,     9,    -1,    -1,    -1,    -1,    14,    -1,
      16,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    25,
      26,    27,    -1,    -1,    -1,    -1,    -1,    -1,    34,    35,
      -1,    -1,    -1,    -1,    40,    41,    42,    43,    44,    45,
      46,    -1,    -1,    -1,    -1,    51,    52,    -1,    -1,    -1,
      -1,    -1,    -1,    59,    -1,    -1,    62,    -1,    -1,    -1,
      -1,    67,    68,    69,    70,    -1,    -1,    -1,    74,    75,
      -1,    -1,    -1,    -1,    -1,    81,    82,    -1,    -1,    -1,
      -1,    -1,    88,    -1,    90,    -1,    92,    -1,    -1,    -1,
      96,    -1,    -1,    -1,   100,    -1,   102,   103,    -1,   105,
      -1,    -1,    -1,   109,   110,   111,   112,   113,   114,    -1,
     116,    -1,   118,    -1,   120,   121,   122,   123,    -1,    -1,
     126,    -1,    -1,   129,    -1,   131,   132,    -1,    -1,    -1,
     136,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   144,   145,
     146,    -1,    -1,    -1,   150,   151,   152,    -1,   154,   155,
      -1,   157,   158,    -1,   160,    -1,    -1,   163,   164,    -1,
      -1,   167,   168,    -1,    -1,    -1,    -1,    -1,   174,   175,
      -1,   177,   178,   179,    -1,    -1,   182,    -1,    -1,    -1,
     186,   187,   188,   189,    -1,   191,   192,   193,   194,   195,
     196,    -1,     5,   199,   200,   201,     6,    -1,     8,     9,
      -1,    -1,    -1,    -1,    14,    -1,    16,    -1,    -1,    -1,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      -1,    -1,    -1,    -1,    34,    35,    -1,    -1,    -1,    -1,
      40,    41,    42,    43,    44,    45,    46,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    58,    -1,    -1,    -1,    59,
      60,    61,    62,    -1,    -1,    -1,    -1,    67,    68,    69,
      -1,    -1,    -1,    -1,    74,    75,    -1,    -1,    -1,    -1,
      -1,    81,    82,    -1,    -1,    -1,    -1,    -1,    88,    -1,
      -1,    -1,    92,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     100,    -1,   102,   103,    -1,   105,    -1,   107,    -1,   109,
     110,   111,   112,   113,   114,   118,   116,    -1,    -1,    -1,
      -1,   121,    -1,    -1,    -1,    -1,   126,    -1,    -1,   129,
      -1,   131,   132,    -1,    -1,    -1,   136,    -1,    -1,    -1,
      -1,    -1,    -1,   143,   144,   145,   146,    -1,    -1,    -1,
     150,   151,   152,    -1,   154,   155,    -1,   157,   158,    -1,
     160,    -1,    -1,    -1,   164,    -1,    -1,   167,   168,    -1,
      -1,    -1,    -1,    -1,   174,   175,   176,    -1,   178,   179,
      -1,    -1,   182,    -1,     6,    -1,     8,     9,    -1,   189,
     190,   191,    14,   193,    16,   195,   196,   197,    -1,   199,
     200,   201,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    34,    35,    -1,    -1,    -1,    -1,    40,    41,
      42,    43,    44,    45,    46,    -1,    -1,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    -1,    59,    -1,    -1,
      62,    -1,    -1,    -1,    -1,    67,    68,    69,    -1,    -1,
      -1,    -1,    74,    75,    -1,    -1,    -1,    -1,    -1,    81,
      82,    58,    -1,    -1,    -1,    -1,    88,    -1,    -1,    -1,
      92,    93,    -1,    -1,    -1,    -1,    -1,    -1,   100,    -1,
     102,   103,    -1,   105,    -1,    -1,    -1,   109,   110,   111,
     112,   113,   114,    -1,   116,    -1,    -1,    -1,    62,   121,
      -1,    -1,    -1,    -1,   126,    69,    -1,   129,    -1,   131,
     132,    -1,    -1,    -1,   136,    -1,    -1,    81,    82,    -1,
      -1,   118,   144,   145,   146,    -1,    -1,    -1,   150,   151,
     152,    -1,   154,   155,    -1,   157,   158,    -1,   160,    -1,
      -1,    -1,   164,    -1,    -1,   167,   168,    -1,    -1,    -1,
      -1,    -1,   174,   175,    -1,    -1,   178,   179,   180,    -1,
     182,    -1,   126,    -1,    -1,    -1,    -1,   131,   132,   191,
      -1,   193,    -1,   195,   196,    -1,    -1,   199,   200,   201,
       6,   145,     8,     9,    10,    -1,    -1,    13,    14,    -1,
      16,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    34,    35,
      -1,    -1,    -1,    -1,    40,    41,    42,    43,    44,    45,
      46,    -1,    -1,   187,   188,   189,    -1,   191,   192,   193,
     194,   195,   196,    59,    -1,    -1,    62,    -1,    -1,    -1,
      -1,    67,    68,    69,    -1,    -1,    -1,    -1,    74,    75,
      -1,    -1,    -1,    -1,    -1,    81,    82,    -1,    -1,    -1,
      -1,    -1,    88,    -1,    -1,    -1,    92,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   100,    -1,   102,   103,    -1,   105,
      -1,    -1,    -1,   109,   110,   111,   112,   113,   114,    -1,
     116,    -1,    -1,    -1,    -1,   121,    -1,    -1,    -1,    -1,
     126,    -1,    -1,   129,    -1,   131,   132,    -1,    -1,    -1,
     136,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   144,   145,
     146,    -1,    -1,    -1,   150,   151,   152,    -1,   154,   155,
      -1,   157,   158,    -1,   160,    -1,    -1,    -1,   164,    -1,
      -1,   167,   168,    -1,    -1,    -1,    -1,    -1,   174,   175,
      -1,    -1,   178,   179,    -1,    -1,   182,    -1,     6,    -1,
       8,     9,    10,    -1,    -1,   191,    14,   193,    16,   195,
     196,    -1,    -1,   199,   200,   201,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    34,    35,    -1,    -1,
      -1,    -1,    40,    41,    42,    43,    44,    45,    46,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    59,    -1,    -1,    62,    -1,    -1,    -1,    -1,    67,
      68,    69,    -1,    -1,    -1,    -1,    74,    75,    -1,    -1,
      -1,    -1,    -1,    81,    82,    -1,    -1,    -1,    -1,    -1,
      88,    -1,    -1,    -1,    92,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   100,    -1,   102,   103,    -1,   105,    -1,    -1,
      -1,   109,   110,   111,   112,   113,   114,    -1,   116,    -1,
      -1,    -1,    -1,   121,    -1,    -1,    -1,    -1,   126,    -1,
      -1,   129,    -1,   131,   132,    -1,    -1,    -1,   136,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   144,   145,   146,    -1,
      -1,    -1,   150,   151,   152,    -1,   154,   155,    -1,   157,
     158,    -1,   160,    -1,    -1,    -1,   164,    -1,    -1,   167,
     168,    -1,    -1,    -1,    -1,    -1,   174,   175,    -1,    -1,
     178,   179,    -1,    -1,   182,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   191,    -1,   193,    -1,   195,   196,    -1,
      -1,   199,   200,   201,     6,    -1,     8,     9,    -1,    -1,
      -1,    13,    14,    -1,    16,    -1,    36,    -1,    38,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      50,    -1,    34,    35,    -1,    -1,    -1,    -1,    40,    41,
      42,    43,    44,    45,    46,    -1,    66,    -1,    -1,    -1,
      -1,    -1,    72,    -1,    -1,    -1,    -1,    59,    -1,    -1,
      62,    -1,    -1,    -1,    84,    67,    68,    69,    -1,    -1,
      -1,    -1,    74,    75,    -1,    -1,    -1,    -1,    -1,    81,
      82,   101,    -1,    -1,   104,    -1,    88,    -1,   108,    -1,
      92,    -1,    -1,    -1,    -1,    -1,    -1,   117,   100,    -1,
     102,   103,    -1,   105,    -1,    -1,    -1,   109,   110,   111,
     112,   113,   114,    -1,   116,    -1,    -1,   137,    -1,   121,
      -1,    -1,   142,    -1,   126,    -1,    -1,   129,    -1,   131,
     132,    -1,    -1,    -1,   136,    -1,    -1,    -1,    -1,    -1,
      -1,   161,   144,   145,   146,    -1,    -1,    -1,   150,   151,
     152,    -1,   154,   155,    -1,   157,   158,    -1,   160,    -1,
      -1,    -1,   164,    -1,    -1,   167,   168,    -1,    -1,    -1,
      -1,    -1,   174,   175,    -1,    -1,   178,   179,    -1,    -1,
     182,    -1,     6,    -1,     8,     9,    -1,    -1,    -1,   191,
      14,   193,    16,   195,   196,    -1,    -1,   199,   200,   201,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      34,    35,    -1,    -1,    -1,    -1,    40,    41,    42,    43,
      44,    45,    46,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    59,    -1,    -1,    62,    -1,
      -1,    -1,    -1,    67,    68,    69,    -1,    -1,    -1,    -1,
      74,    75,    -1,    -1,    -1,    -1,    -1,    81,    82,    -1,
      -1,    -1,    -1,    -1,    88,    -1,    -1,    -1,    92,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   100,    -1,   102,   103,
      -1,   105,    -1,    -1,    -1,   109,   110,   111,   112,   113,
     114,    -1,   116,    -1,    -1,    -1,    -1,   121,    -1,    -1,
      -1,    -1,   126,    -1,    -1,   129,    -1,   131,   132,    -1,
      -1,    -1,   136,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     144,   145,   146,    -1,    -1,    -1,   150,   151,   152,    -1,
     154,   155,    -1,   157,   158,    -1,   160,    -1,    -1,    -1,
     164,    -1,    -1,   167,   168,    -1,    -1,    -1,    -1,    -1,
     174,   175,     6,    -1,   178,   179,    10,    11,   182,    -1,
      14,    -1,    16,    -1,    -1,    -1,    -1,   191,    -1,   193,
      -1,   195,   196,    -1,    -1,   199,   200,   201,    -1,    -1,
      34,    35,    -1,    -1,    -1,    -1,    40,    41,    42,    43,
      44,    45,    46,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    59,    -1,    -1,    62,    -1,
      -1,    -1,    -1,    67,    68,    69,    -1,    -1,    -1,    -1,
      74,    75,    -1,    -1,    -1,    -1,    -1,    81,    82,    -1,
      -1,    -1,    -1,    -1,    88,    -1,    -1,    -1,    92,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   100,    -1,   102,   103,
      -1,   105,    -1,    -1,    -1,   109,   110,   111,   112,   113,
     114,    -1,   116,    -1,    -1,    -1,    -1,   121,    -1,    -1,
      -1,    -1,   126,    -1,    -1,   129,    -1,   131,   132,    -1,
      -1,    -1,   136,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     144,   145,   146,    -1,    -1,    -1,   150,   151,   152,    -1,
     154,   155,    -1,   157,   158,    -1,   160,    -1,    -1,    -1,
     164,    -1,    -1,   167,   168,    -1,    -1,    -1,    -1,    -1,
     174,   175,     6,    -1,   178,   179,    -1,    -1,   182,    -1,
      14,    -1,    16,    -1,    -1,    -1,    -1,   191,    -1,   193,
      -1,   195,   196,    -1,    -1,   199,   200,   201,    -1,    -1,
      34,    35,    -1,    -1,    -1,    -1,    40,    41,    42,    43,
      44,    45,    46,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    59,    -1,    -1,    62,    -1,
      -1,    -1,    -1,    67,    68,    69,    -1,    -1,    -1,    -1,
      74,    75,    -1,    -1,    -1,    -1,    -1,    81,    82,    -1,
      -1,    -1,    -1,    -1,    88,    -1,    -1,    -1,    92,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   100,    -1,   102,   103,
      -1,   105,    -1,    -1,    -1,   109,   110,   111,   112,   113,
     114,    -1,   116,    -1,    -1,    -1,    -1,   121,    -1,    -1,
      -1,    -1,   126,    -1,    -1,   129,    -1,   131,   132,    -1,
      -1,    -1,   136,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     144,   145,   146,    -1,    -1,    -1,   150,   151,   152,     6,
     154,   155,    -1,   157,   158,    -1,   160,    14,    -1,    16,
     164,    -1,    -1,   167,   168,    -1,    -1,    -1,    -1,    -1,
     174,   175,    -1,    -1,   178,   179,    -1,    -1,   182,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   191,    -1,   193,
      -1,   195,   196,    -1,    51,   199,   200,   201,    -1,    -1,
       6,    -1,    -1,    60,    -1,    -1,    -1,    -1,    14,    -1,
      16,    -1,    -1,    70,    -1,    -1,    -1,    -1,    -1,    25,
      26,    27,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    90,     6,    -1,    -1,    -1,    -1,    96,
      -1,    -1,    14,    -1,    16,    51,    52,    -1,    -1,    -1,
      -1,    -1,    -1,    25,    26,    27,    -1,    -1,   115,    -1,
      -1,    -1,    -1,   120,    70,   122,   123,    73,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    51,
      52,    -1,    -1,    -1,    90,    -1,    -1,    -1,    -1,    -1,
      96,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   163,    -1,    -1,    -1,
      -1,    -1,   118,    -1,   120,    -1,   122,   123,    90,    -1,
     177,    -1,    -1,    -1,    96,    -1,    -1,    -1,    -1,    -1,
     187,    -1,    -1,   190,   191,    -1,    -1,   194,   195,   196,
     197,    -1,   199,   200,   201,    -1,   118,    -1,   120,    -1,
     122,   123,    -1,    -1,    -1,    -1,    14,   163,    16,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   177,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     186,   187,   188,   189,    -1,   191,   192,   193,   194,    -1,
      -1,   163,    -1,    51,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    60,    -1,    62,   177,    -1,    -1,    -1,    -1,
      -1,    69,    70,    -1,   186,   187,   188,   189,    -1,   191,
     192,   193,   194,    81,    82,    -1,    -1,     5,    -1,    -1,
       8,     9,    90,    -1,    -1,    -1,    -1,    -1,    96,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    -1,    -1,   115,    -1,    -1,
      -1,    -1,   120,    -1,   122,   123,    -1,    -1,   126,    -1,
      -1,    -1,    -1,   131,   132,    -1,     8,     9,    -1,    -1,
      58,    -1,    -1,    -1,    -1,    -1,    -1,   145,    -1,    -1,
      -1,    -1,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    -1,    -1,    -1,    14,   163,    16,    -1,    -1,    -1,
      20,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   177,
      -1,    -1,    -1,    33,    -1,    -1,    58,    -1,    -1,   187,
     188,   189,   190,   191,   192,   193,   194,   195,   196,   197,
     118,   199,   200,   201,    -1,    55,    56,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    66,    -1,    -1,    -1,
      -1,    71,    -1,    -1,    -1,    -1,    76,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    87,    -1,    -1,
      -1,    91,    -1,    -1,    94,    95,   118,    97,    -1,    -1,
      -1,   101,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,    -1,
      -1,    -1,   122,   123,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   133,   134,    -1,    -1,    -1,   138,   139,
     140,   141,    -1,    -1,    -1,    -1,    -1,   147,   148,   149,
      -1,    -1,    -1,   153,    -1,    -1,    -1,    -1,    14,    -1,
      16,    -1,   162,   163,    20,    -1,    -1,    -1,    -1,    -1,
      -1,   171,    -1,    -1,    -1,    -1,    -1,    33,    -1,    -1,
      -1,   181,    -1,   183,    -1,   185,    -1,   187,   188,   189,
     190,   191,   192,   193,   194,   195,   196,    -1,    -1,    55,
      56,    -1,    -1,    -1,    -1,    -1,    -1,    63,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    71,    -1,    -1,    -1,    -1,
      76,    -1,    -1,    -1,    80,    -1,    -1,    -1,    -1,    -1,
      -1,    87,    -1,    -1,    -1,    91,    -1,    -1,    94,    95,
      -1,    97,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   115,
      -1,    -1,    -1,    -1,    -1,    -1,   122,   123,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   133,   134,    -1,
      -1,    -1,   138,   139,   140,   141,    -1,    -1,    -1,    -1,
      -1,   147,   148,   149,    -1,    -1,    -1,   153,    -1,    -1,
      -1,    -1,    14,    -1,    16,    -1,   162,   163,    20,    -1,
      -1,    -1,    -1,    -1,    -1,   171,    -1,    -1,    -1,    -1,
      -1,    33,    -1,    -1,    -1,   181,    -1,   183,    -1,   185,
      -1,   187,   188,   189,   190,   191,   192,   193,   194,   195,
     196,    -1,    -1,    55,    56,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    76,    -1,    -1,    79,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    87,    -1,    -1,    -1,    91,
      -1,    -1,    94,    95,    -1,    97,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   115,    -1,    -1,    -1,    -1,    -1,    -1,
     122,   123,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   133,   134,    -1,    -1,    14,   138,    16,   140,   141,
      -1,    20,    -1,    -1,    -1,   147,   148,   149,    -1,    -1,
      -1,   153,    -1,    -1,    33,    -1,    -1,    -1,    -1,    -1,
      -1,   163,    -1,    -1,    -1,    -1,    -1,    -1,   170,   171,
      -1,    -1,    -1,    -1,    -1,    -1,    55,    56,    -1,   181,
      -1,   183,    -1,   185,    -1,   187,   188,   189,   190,   191,
     192,   193,   194,   195,   196,    -1,    -1,    76,    -1,    -1,
      79,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    87,    -1,
      89,    -1,    91,    -1,    -1,    -1,    95,    -1,    97,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,
      -1,    -1,    -1,   122,   123,    14,    -1,    16,    -1,    -1,
      -1,    20,    -1,    -1,   133,   134,    -1,    -1,    -1,   138,
      -1,   140,   141,    -1,    33,    -1,    -1,    -1,   147,   148,
     149,    -1,    -1,    -1,   153,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   163,    -1,    55,    56,    -1,    -1,
     169,    -1,   171,    -1,    63,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   181,    -1,   183,    -1,   185,    76,   187,   188,
     189,   190,   191,   192,   193,   194,   195,   196,    87,    -1,
      89,    -1,    91,    -1,    -1,    -1,    95,    -1,    97,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,
      -1,    -1,    -1,   122,   123,    14,    -1,    16,    -1,    -1,
      -1,    20,    -1,    -1,   133,   134,    -1,    -1,    -1,   138,
      -1,   140,   141,    -1,    33,    -1,    -1,    -1,   147,   148,
     149,    -1,    -1,    -1,   153,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   163,    -1,    55,    56,    -1,    -1,
     169,    -1,   171,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   181,    -1,   183,    -1,   185,    76,   187,   188,
     189,   190,   191,   192,   193,   194,   195,   196,    87,    -1,
      89,    -1,    91,    -1,    -1,    -1,    95,    -1,    97,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,
      -1,    -1,    -1,   122,   123,    14,    -1,    16,    -1,    -1,
      -1,    20,    -1,    -1,   133,   134,    -1,    -1,    -1,   138,
      -1,   140,   141,    -1,    33,    -1,    -1,    -1,   147,   148,
     149,    -1,    -1,    -1,   153,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   163,    -1,    55,    56,    -1,    -1,
     169,    -1,   171,    -1,    63,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   181,    -1,   183,    -1,   185,    76,   187,   188,
     189,   190,   191,   192,   193,   194,   195,   196,    87,    -1,
      -1,    -1,    91,    -1,    -1,    94,    95,    -1,    97,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,
      -1,    -1,    -1,   122,   123,    14,    -1,    16,    -1,    -1,
      -1,    20,    -1,    -1,   133,   134,    -1,    -1,    -1,   138,
      -1,   140,   141,    -1,    33,    -1,    -1,    -1,   147,   148,
     149,    -1,    -1,    -1,   153,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   163,    -1,    55,    56,    -1,    -1,
      -1,    -1,   171,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   181,    -1,   183,    -1,   185,    76,   187,   188,
     189,   190,   191,   192,   193,   194,   195,   196,    87,    -1,
      -1,    -1,    91,    -1,    -1,    94,    95,    -1,    97,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,
      -1,    -1,    -1,   122,   123,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   133,   134,    -1,    -1,    14,   138,
      16,   140,   141,    -1,    20,    -1,    -1,    -1,   147,   148,
     149,    -1,    -1,    -1,   153,    -1,    -1,    33,    -1,    -1,
      -1,    -1,    -1,    -1,   163,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   171,    -1,    -1,    -1,    -1,    -1,    -1,    55,
      56,    -1,   181,    -1,   183,    -1,   185,    -1,   187,   188,
     189,   190,   191,   192,   193,   194,   195,   196,    -1,    -1,
      76,    -1,    -1,    79,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    87,    -1,    -1,    -1,    91,    -1,    -1,    -1,    95,
      -1,    97,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   115,
      -1,    -1,    -1,    -1,    -1,    -1,   122,   123,    14,    -1,
      16,    -1,    -1,    -1,    20,    -1,    -1,   133,   134,    -1,
      -1,    -1,   138,    -1,   140,   141,    -1,    33,    -1,    -1,
      -1,   147,   148,   149,    -1,    -1,    -1,   153,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   163,    -1,    55,
      56,    -1,    -1,    -1,    -1,   171,    -1,    63,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   181,    -1,   183,    -1,   185,
      76,   187,   188,   189,   190,   191,   192,   193,   194,   195,
     196,    87,    -1,    -1,    -1,    91,    -1,    -1,    -1,    95,
      -1,    97,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   115,
      -1,    -1,    -1,    -1,    -1,    -1,   122,   123,    14,    -1,
      16,    -1,    -1,    -1,    20,    -1,    -1,   133,   134,    -1,
      -1,    -1,   138,    -1,   140,   141,    -1,    33,    -1,    -1,
      -1,   147,   148,   149,    -1,    -1,    -1,   153,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   163,    -1,    55,
      56,    -1,    -1,    -1,    -1,   171,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   181,    -1,   183,    -1,   185,
      76,   187,   188,   189,   190,   191,   192,   193,   194,   195,
     196,    87,    -1,    -1,    -1,    91,    -1,    -1,    -1,    95,
      -1,    97,    -1,    -1,    -1,    -1,    14,    -1,    16,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    14,    -1,    16,   115,
      -1,    -1,    -1,    -1,    -1,    -1,   122,   123,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   133,   134,    -1,
      -1,    -1,   138,    -1,   140,   141,    -1,    -1,    -1,    -1,
      -1,   147,   148,   149,    62,    -1,    -1,   153,    -1,    -1,
      -1,    69,    -1,    -1,    62,    -1,    -1,   163,    -1,    -1,
      -1,    69,    -1,    81,    82,   171,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    81,    82,   181,    -1,   183,    -1,   185,
      -1,   187,   188,   189,   190,   191,   192,   193,   194,   195,
     196,    -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,    -1,
      -1,   119,    -1,    -1,    -1,    -1,    -1,   115,   126,    -1,
      -1,    -1,    -1,   131,   132,    -1,    -1,    -1,   126,    -1,
      -1,    -1,    -1,   131,   132,    -1,    -1,   145,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   145,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   163,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   163,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   187,
     188,   189,   190,   191,   192,   193,   194,   195,   196,   187,
     188,   189,   190,   191,   192,   193,   194,   195,   196,    36,
      -1,    38,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      47,    -1,    -1,    50,    -1,    52,    53,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    61,    -1,    -1,    -1,    -1,    66,
      -1,    -1,    -1,    -1,    -1,    72,    -1,    -1,    -1,    -1,
      77,    -1,    -1,    -1,    -1,    -1,    -1,    84,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    94,    -1,    -1,
      -1,    -1,    -1,    -1,   101,   102,    -1,   104,    -1,    -1,
      -1,   108,    -1,   110,    -1,    -1,    -1,    -1,    -1,    -1,
     117,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   128,    -1,   130,    -1,    -1,    -1,    -1,    -1,    -1,
     137,    -1,    -1,    -1,    -1,   142,    -1,    -1,    -1,   146,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   156,
      -1,    -1,    -1,    -1,   161,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   169,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   182,    -1,    36,    -1,    38,
     187,   188,   189,   190,   191,   192,   193,   194,    47,   196,
      -1,    50,    -1,    52,    53,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    61,    -1,    -1,    -1,    -1,    66,    -1,    -1,
      -1,    -1,    -1,    72,    36,    -1,    38,    -1,    77,    -1,
      -1,    -1,    -1,    -1,    -1,    84,    -1,    -1,    50,    -1,
      52,    53,    -1,    -1,    -1,    94,    -1,    -1,    -1,    61,
      -1,    -1,   101,   102,    66,   104,    -1,    -1,    -1,   108,
      72,   110,    -1,    -1,    -1,    77,    -1,    -1,   117,    -1,
      -1,    -1,    84,    -1,    -1,    -1,    -1,    -1,    -1,   128,
      -1,   130,    -1,    -1,    -1,    -1,    -1,    -1,   137,   101,
     102,    -1,   104,   142,    -1,    -1,   108,   146,   110,    -1,
      -1,    -1,    -1,    -1,    -1,   117,    -1,   156,    -1,    -1,
      -1,    -1,   161,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     169,    -1,    -1,    -1,    -1,   137,    -1,    -1,    -1,    -1,
     142,    -1,    -1,   182,   146,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   191,    -1,   156,    -1,    -1,    -1,    -1,   161,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     182,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   191
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int16 yystos[] =
{
       0,    14,    16,    20,    33,    55,    56,    66,    71,    76,
      87,    91,    94,    95,    97,   101,   115,   122,   123,   133,
     134,   138,   139,   140,   141,   147,   148,   149,   153,   162,
     163,   171,   181,   183,   185,   187,   188,   189,   190,   191,
     192,   193,   194,   195,   196,   208,   222,   233,   255,   257,
     262,   263,   265,   266,   268,   274,   277,   279,   281,   282,
     283,   284,   285,   286,   287,   288,   290,   291,   292,   293,
     300,   301,   302,   303,   304,   305,   306,   307,   310,   312,
     313,   314,   315,   318,   319,   321,   322,   324,   325,   330,
     331,   332,   334,   346,   360,   361,   362,   363,   364,   365,
     368,   369,   377,   380,   383,   386,   387,   388,   389,   390,
     391,   392,   393,   233,   286,   208,   192,   256,   266,   286,
       6,    36,    38,    47,    50,    52,    53,    61,    72,    77,
      84,    94,   102,   104,   108,   110,   117,   128,   130,   137,
     142,   146,   156,   161,   169,   182,   188,   189,   191,   192,
     193,   194,   203,   204,   205,   206,   207,   208,   209,   210,
     211,   212,   213,   239,   265,   277,   287,   343,   344,   345,
     346,   350,   352,   353,   354,   355,   357,   359,    20,    57,
      93,   180,   184,   335,   336,   337,   340,    20,   266,     6,
      20,   353,   354,   355,   359,   173,     6,    83,    83,     6,
       6,    20,   266,   208,   381,   257,   286,     6,     8,     9,
      14,    16,    20,    25,    26,    27,    34,    35,    40,    41,
      42,    43,    44,    45,    46,    51,    52,    59,    60,    61,
      62,    67,    68,    69,    70,    74,    75,    81,    82,    88,
      90,    92,    94,    96,   100,   102,   103,   105,   107,   109,
     110,   111,   112,   113,   114,   116,   118,   119,   120,   121,
     122,   123,   126,   129,   131,   132,   136,   143,   144,   145,
     146,   150,   151,   152,   154,   155,   157,   158,   160,   164,
     167,   168,   174,   175,   176,   177,   178,   179,   182,   186,
     188,   189,   193,   197,   199,   200,   201,   211,   214,   215,
     216,   217,   218,   219,   221,   222,   223,   224,   225,   226,
     227,   228,   229,   232,   234,   235,   246,   247,   248,   252,
     254,   255,   256,   257,   258,   259,   260,   261,   262,   264,
     267,   271,   272,   273,   274,   275,   276,   278,   279,   282,
     284,   286,   256,    83,   257,   257,   287,   384,   127,     6,
      18,   236,   237,   240,   241,   281,   284,   286,     6,   236,
     236,    21,   236,   236,     6,     4,    29,   289,     6,     4,
      11,   236,   289,    20,   181,   300,   301,   306,   300,     6,
     214,   246,   248,   254,   271,   278,   282,   295,   296,   297,
     298,   300,    20,    39,    89,   169,   181,   301,   302,     6,
      20,    48,   308,    79,   170,   303,   306,   311,   341,    20,
      64,   106,   125,   159,   166,   281,   316,   320,    20,   191,
     232,   317,   320,     4,    20,     4,    20,   289,     4,     6,
      93,   180,   193,   214,   286,    20,   256,   323,    49,    99,
     123,   127,     4,    20,    73,   326,   327,   328,   329,   335,
      20,     6,    20,   224,   226,   228,   256,   259,   275,   280,
     281,   333,   342,   300,   214,   232,   347,   348,   349,     0,
     303,   377,   380,   383,    63,    80,   303,   306,   366,   367,
     372,   373,   377,   380,   383,    20,    36,   142,    86,   135,
      65,    94,   128,   130,     6,   352,   370,   375,   376,   308,
     371,   375,   378,    20,   366,   367,   366,   367,   366,   367,
     366,   367,    15,    11,    17,   236,    11,     6,     6,     6,
       6,     6,     6,     6,   128,    84,   344,    20,     4,   207,
     115,   239,    10,   214,   351,     4,   204,   351,   345,    10,
     232,   347,   191,   205,   344,     9,   356,   358,   214,   170,
     222,   286,   246,   295,    20,    20,   336,   214,   338,    20,
     224,    20,    20,    20,    20,   266,    20,   236,    98,   165,
     236,   224,   224,    20,     6,    54,    11,   214,   246,   271,
     286,   255,   286,   255,   286,    28,   236,   269,   270,     6,
     269,     6,   236,    24,    58,   216,   217,   253,   215,   215,
       7,    10,    11,   218,    12,   220,    18,   237,     6,    20,
     236,    22,   124,   249,   250,    23,    39,   251,   253,     6,
      14,    16,   252,   286,   261,     6,   232,     6,   253,     6,
       6,    11,    20,   236,    21,   344,   205,   385,   173,   256,
     224,     6,   222,   224,    10,    13,   214,   242,   243,   244,
     245,     4,     5,    20,    21,     5,     6,   280,   281,   288,
     232,   318,   214,   230,   231,   232,   286,   288,   233,   265,
     268,   277,   287,   232,    78,   214,   271,   295,    28,    30,
      31,    32,   254,   289,   299,   172,   294,   299,     6,   299,
     299,   299,   249,   294,   251,   330,   230,     6,   266,   203,
     306,   311,    20,     6,     6,     6,     6,     6,   316,   317,
     232,   286,   214,   214,    73,   246,   214,    20,    11,     4,
      20,   214,   214,   246,     6,   138,    20,   329,    37,    85,
       6,   214,   246,   286,     4,     5,    13,     5,     4,     6,
     281,   342,   347,    20,   266,    89,   306,   366,    20,   303,
     366,   373,    20,   352,   187,   190,   191,   193,   194,   196,
     374,   375,   378,    20,   366,    20,   366,    20,   366,    20,
     366,   236,   236,   266,   351,   351,   351,   351,   225,   344,
     344,   212,     5,     4,     5,     5,     5,   162,   351,    20,
     208,   289,    11,    20,   173,   339,     4,    20,    20,    98,
     165,     5,     5,   208,   382,   198,   379,     5,     5,     5,
      15,    11,    17,    18,   224,   230,   215,   215,     6,   189,
     214,   272,   286,   215,   218,   218,   219,     6,   230,   247,
     248,   252,   254,    11,   224,     5,   230,   214,   272,   230,
     119,   280,   234,    20,   225,    21,     4,    20,   214,   173,
       5,    19,   238,    49,   214,   244,   173,   216,   217,     5,
     289,    20,    13,     4,     5,   236,   236,   236,   236,     5,
      28,    30,   289,   214,   248,   295,   214,   271,   278,   192,
     282,   286,   248,   296,   297,    20,     5,   281,   286,   309,
      20,   214,   214,   214,   214,   214,    20,    20,     5,    20,
      20,    20,   256,   214,   214,   214,    11,    20,   227,     4,
       5,   208,    20,     4,     5,    20,    20,    20,    20,   236,
       5,     5,     5,     4,     5,     6,     5,    78,    29,   214,
     214,     4,     5,   236,   236,     6,     5,     5,    11,    19,
       5,   252,     5,     5,     5,     5,     5,   236,   225,   225,
      20,   214,    19,   239,   260,   214,   244,   215,   215,   232,
     231,     5,    20,   308,     4,     5,     5,     5,     5,     5,
       5,     5,   173,    54,   208,    19,   261,   239,    20,     4,
       5,     5,     5,     6,   281,   286,    20,   281,   214,   260,
       4,    19,   238,   309,    20,     5,   214,     5,     5,    20
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int16 yyr1[] =
{
       0,   202,   203,   203,   204,   204,   204,   205,   205,   205,
     205,   205,   205,   205,   205,   206,   206,   206,   206,   206,
     207,   207,   207,   208,   209,   209,   210,   210,   211,   211,
     211,   211,   212,   212,   213,   213,   213,   213,   213,   213,
     213,   213,   214,   214,   214,   214,   214,   215,   215,   216,
     217,   218,   218,   218,   218,   219,   219,   220,   221,   221,
     221,   221,   222,   222,   222,   222,   222,   222,   222,   222,
     223,   223,   223,   223,   223,   224,   224,   225,   226,   227,
     228,   228,   228,   228,   229,   229,   230,   230,   231,   231,
     231,   232,   232,   232,   232,   232,   233,   233,   234,   234,
     234,   234,   234,   234,   234,   234,   235,   235,   235,   235,
     235,   235,   235,   235,   235,   235,   235,   235,   235,   235,
     235,   235,   235,   235,   235,   235,   235,   235,   235,   235,
     235,   235,   235,   235,   235,   235,   235,   235,   235,   235,
     235,   235,   235,   235,   235,   235,   235,   235,   235,   235,
     235,   235,   235,   236,   236,   236,   236,   237,   237,   237,
     237,   238,   238,   239,   239,   240,   240,   240,   240,   240,
     241,   241,   242,   242,   242,   242,   243,   244,   244,   245,
     245,   245,   246,   246,   247,   247,   248,   248,   248,   248,
     249,   249,   250,   251,   251,   252,   252,   252,   252,   252,
     252,   252,   252,   252,   252,   252,   253,   253,   254,   254,
     254,   254,   255,   255,   255,   255,   256,   256,   256,   256,
     257,   257,   257,   257,   258,   258,   259,   259,   259,   259,
     259,   260,   260,   260,   260,   261,   262,   262,   263,   264,
     264,   264,   265,   266,   266,   266,   266,   267,   267,   268,
     269,   269,   270,   271,   271,   271,   271,   271,   272,   272,
     272,   272,   273,   273,   274,   274,   274,   274,   275,   275,
     276,   276,   276,   276,   276,   277,   278,   278,   278,   279,
     280,   280,   280,   281,   281,   281,   281,   281,   281,   281,
     282,   282,   282,   282,   283,   284,   285,   286,   286,   287,
     288,   288,   288,   288,   289,   290,   290,   291,   291,   292,
     293,   294,   295,   295,   296,   296,   297,   297,   297,   298,
     298,   298,   298,   298,   299,   299,   299,   299,   299,   299,
     299,   299,   300,   300,   300,   301,   301,   301,   301,   301,
     301,   301,   301,   301,   301,   301,   301,   301,   301,   301,
     301,   301,   301,   301,   301,   301,   301,   301,   301,   301,
     301,   301,   301,   301,   301,   301,   301,   301,   301,   301,
     301,   301,   301,   301,   301,   301,   302,   302,   302,   303,
     303,   304,   304,   305,   305,   305,   305,   306,   307,   308,
     309,   309,   309,   309,   310,   310,   310,   310,   310,   310,
     310,   310,   311,   311,   311,   312,   312,   313,   314,   314,
     315,   315,   316,   316,   317,   317,   317,   318,   319,   320,
     320,   320,   320,   320,   321,   322,   322,   323,   323,   324,
     324,   324,   324,   325,   325,   325,   326,   326,   326,   327,
     327,   327,   328,   329,   329,   330,   330,   330,   331,   332,
     332,   333,   333,   334,   335,   335,   336,   336,   337,   337,
     338,   338,   339,   339,   340,   340,   341,   342,   342,   342,
     342,   343,   343,   344,   344,   345,   345,   345,   345,   345,
     345,   345,   345,   345,   345,   345,   345,   346,   346,   346,
     347,   347,   347,   347,   347,   348,   349,   349,   350,   351,
     351,   352,   352,   352,   352,   352,   353,   353,   354,   355,
     356,   356,   357,   358,   359,   359,   359,   360,   360,   360,
     360,   360,   360,   360,   360,   360,   361,   361,   362,   363,
     363,   363,   363,   363,   364,   364,   364,   364,   364,   364,
     364,   364,   364,   365,   365,   366,   366,   366,   367,   367,
     367,   368,   369,   370,   370,   370,   371,   371,   371,   372,
     372,   373,   373,   373,   373,   374,   374,   374,   374,   374,
     374,   375,   376,   376,   377,   378,   379,   380,   381,   381,
     382,   382,   383,   384,   384,   384,   385,   386,   386,   386,
     386,   387,   387,   388,   388,   389,   389,   390,   391,   391,
     392,   393
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
       3,     3,     3,     3,     1,     2,     1,     1,     1,     1,
       2,     2,     1,     1,     1,     2,     2,     2,     3,     2,
       3,     4,     1,     2,     5,     6,     9,     2,     3,     3,
       2,     2,     2,     2,     4,     4,     4,     4,     3,     4,
       4,     2,     3,     5,     6,     2,     3,     2,     4,     3,
       2,     4,     4,     3,     2,     4,     1,     2,     2,     1,
       1,     3,     2,     4,     4,     3,     3,     2,     2,     1,
       1,     3,     1,     3,     2,     3,     4,     3,     4,     2,
       2,     2,     1,     2,     2,     4,     4,     4,     2,     3,
       2,     3,     1,     1,     1,     1,     1,     4,     3,     4,
       4,     4,     4,     4,     1,     1,     1,     1,     3,     2,
       3,     3,     3,     1,     5,     2,     1,     1,     2,     3,
       3,     1,     2,     2,     2,     2,     2,     2,     2,     2,
       3,     1,     1,     5,     1,     1,     2,     2,     3,     2,
       1,     3,     2,     4,     3,     4,     3,     1,     1,     1,
       1,     2,     3,     1,     2,     1,     1,     1,     1,     1,
       4,     1,     1,     3,     3,     1,     4,     2,     2,     3,
       1,     2,     2,     3,     1,     3,     2,     3,     2,     1,
       1,     1,     1,     1,     1,     1,     1,     4,     4,     2,
       2,     3,     1,     3,     1,     1,     2,     1,     2,     1,
       2,     1,     2,     2,     3,     3,     3,     4,     2,     2,
       2,     1,     2,     2,     2,     2,     2,     2,     1,     1,
       2,     1,     2,     1,     2,     1,     2,     2,     1,     1,
       2,     2,     2,     1,     1,     2,     1,     1,     2,     1,
       2,     1,     2,     1,     6,     1,     1,     1,     1,     1,
       1,     3,     1,     3,     3,     2,     1,     4,     1,     4,
       1,     3,     3,     3,     4,     4,     2,     1,     1,     1,
       1,     3,     4,     3,     2,     3,     4,     3,     3,     4,
       3,     3
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
#line 647 "HAL_S.y"
                                { (yyval.declare_body_) = make_AAdeclareBody_declarationList((yyvsp[0].declaration_list_)); (yyval.declare_body_)->line_number = (yyloc).first_line; (yyval.declare_body_)->char_number = (yyloc).first_column;  }
#line 4170 "Parser.c"
    break;

  case 3: /* DECLARE_BODY: ATTRIBUTES _SYMB_0 DECLARATION_LIST  */
#line 648 "HAL_S.y"
                                        { (yyval.declare_body_) = make_ABdeclareBody_attributes_declarationList((yyvsp[-2].attributes_), (yyvsp[0].declaration_list_)); (yyval.declare_body_)->line_number = (yyloc).first_line; (yyval.declare_body_)->char_number = (yyloc).first_column;  }
#line 4176 "Parser.c"
    break;

  case 4: /* ATTRIBUTES: ARRAY_SPEC TYPE_AND_MINOR_ATTR  */
#line 650 "HAL_S.y"
                                            { (yyval.attributes_) = make_AAattributes_arraySpec_typeAndMinorAttr((yyvsp[-1].array_spec_), (yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4182 "Parser.c"
    break;

  case 5: /* ATTRIBUTES: ARRAY_SPEC  */
#line 651 "HAL_S.y"
               { (yyval.attributes_) = make_ABattributes_arraySpec((yyvsp[0].array_spec_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4188 "Parser.c"
    break;

  case 6: /* ATTRIBUTES: TYPE_AND_MINOR_ATTR  */
#line 652 "HAL_S.y"
                        { (yyval.attributes_) = make_ACattributes_typeAndMinorAttr((yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4194 "Parser.c"
    break;

  case 7: /* DECLARATION: NAME_ID  */
#line 654 "HAL_S.y"
                      { (yyval.declaration_) = make_AAdeclaration_nameId((yyvsp[0].name_id_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4200 "Parser.c"
    break;

  case 8: /* DECLARATION: NAME_ID ATTRIBUTES  */
#line 655 "HAL_S.y"
                       { (yyval.declaration_) = make_ABdeclaration_nameId_attributes((yyvsp[-1].name_id_), (yyvsp[0].attributes_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4206 "Parser.c"
    break;

  case 9: /* DECLARATION: _SYMB_189 _SYMB_124 MINOR_ATTR_LIST  */
#line 656 "HAL_S.y"
                                        { (yyval.declaration_) = make_ACdeclaration_labelToken_procedure_minorAttrList((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4212 "Parser.c"
    break;

  case 10: /* DECLARATION: _SYMB_189 _SYMB_124  */
#line 657 "HAL_S.y"
                        { (yyval.declaration_) = make_ADdeclaration_labelToken_procedure((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4218 "Parser.c"
    break;

  case 11: /* DECLARATION: _SYMB_190 _SYMB_80  */
#line 658 "HAL_S.y"
                       { (yyval.declaration_) = make_AEdeclaration_eventToken_event((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4224 "Parser.c"
    break;

  case 12: /* DECLARATION: _SYMB_190 _SYMB_80 MINOR_ATTR_LIST  */
#line 659 "HAL_S.y"
                                       { (yyval.declaration_) = make_AFdeclaration_eventToken_event_minorAttrList((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4230 "Parser.c"
    break;

  case 13: /* DECLARATION: _SYMB_190  */
#line 660 "HAL_S.y"
              { (yyval.declaration_) = make_AGdeclaration_eventToken((yyvsp[0].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4236 "Parser.c"
    break;

  case 14: /* DECLARATION: _SYMB_190 MINOR_ATTR_LIST  */
#line 661 "HAL_S.y"
                              { (yyval.declaration_) = make_AHdeclaration_eventToken_minorAttrList((yyvsp[-1].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4242 "Parser.c"
    break;

  case 15: /* ARRAY_SPEC: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 663 "HAL_S.y"
                                                    { (yyval.array_spec_) = make_AAarraySpec_arrayHead_literalExpOrStar((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4248 "Parser.c"
    break;

  case 16: /* ARRAY_SPEC: _SYMB_90  */
#line 664 "HAL_S.y"
             { (yyval.array_spec_) = make_ABarraySpec_function(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4254 "Parser.c"
    break;

  case 17: /* ARRAY_SPEC: _SYMB_124  */
#line 665 "HAL_S.y"
              { (yyval.array_spec_) = make_ACarraySpec_procedure(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4260 "Parser.c"
    break;

  case 18: /* ARRAY_SPEC: _SYMB_126  */
#line 666 "HAL_S.y"
              { (yyval.array_spec_) = make_ADarraySpec_program(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4266 "Parser.c"
    break;

  case 19: /* ARRAY_SPEC: _SYMB_165  */
#line 667 "HAL_S.y"
              { (yyval.array_spec_) = make_AEarraySpec_task(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4272 "Parser.c"
    break;

  case 20: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC  */
#line 669 "HAL_S.y"
                                { (yyval.type_and_minor_attr_) = make_AAtypeAndMinorAttr_typeSpec((yyvsp[0].type_spec_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4278 "Parser.c"
    break;

  case 21: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC MINOR_ATTR_LIST  */
#line 670 "HAL_S.y"
                              { (yyval.type_and_minor_attr_) = make_ABtypeAndMinorAttr_typeSpec_minorAttrList((yyvsp[-1].type_spec_), (yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4284 "Parser.c"
    break;

  case 22: /* TYPE_AND_MINOR_ATTR: MINOR_ATTR_LIST  */
#line 671 "HAL_S.y"
                    { (yyval.type_and_minor_attr_) = make_ACtypeAndMinorAttr_minorAttrList((yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4290 "Parser.c"
    break;

  case 23: /* IDENTIFIER: _SYMB_192  */
#line 673 "HAL_S.y"
                       { (yyval.identifier_) = make_AAidentifier((yyvsp[0].string_)); (yyval.identifier_)->line_number = (yyloc).first_line; (yyval.identifier_)->char_number = (yyloc).first_column;  }
#line 4296 "Parser.c"
    break;

  case 24: /* SQ_DQ_NAME: DOUBLY_QUAL_NAME_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 675 "HAL_S.y"
                                                               { (yyval.sq_dq_name_) = make_AAsQdQName_doublyQualNameHead_literalExpOrStar((yyvsp[-2].doubly_qual_name_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 4302 "Parser.c"
    break;

  case 25: /* SQ_DQ_NAME: ARITH_CONV  */
#line 676 "HAL_S.y"
               { (yyval.sq_dq_name_) = make_ABsQdQName_arithConv((yyvsp[0].arith_conv_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 4308 "Parser.c"
    break;

  case 26: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_178 _SYMB_2  */
#line 678 "HAL_S.y"
                                          { (yyval.doubly_qual_name_head_) = make_AAdoublyQualNameHead_vector(); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 4314 "Parser.c"
    break;

  case 27: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_106 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_0  */
#line 679 "HAL_S.y"
                                                  { (yyval.doubly_qual_name_head_) = make_ABdoublyQualNameHead_matrix_literalExpOrStar((yyvsp[-1].literal_exp_or_star_)); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 4320 "Parser.c"
    break;

  case 28: /* ARITH_CONV: _SYMB_98  */
#line 681 "HAL_S.y"
                      { (yyval.arith_conv_) = make_AAarithConv_integer(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4326 "Parser.c"
    break;

  case 29: /* ARITH_CONV: _SYMB_142  */
#line 682 "HAL_S.y"
              { (yyval.arith_conv_) = make_ABarithConv_scalar(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4332 "Parser.c"
    break;

  case 30: /* ARITH_CONV: _SYMB_178  */
#line 683 "HAL_S.y"
              { (yyval.arith_conv_) = make_ACarithConv_vector(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4338 "Parser.c"
    break;

  case 31: /* ARITH_CONV: _SYMB_106  */
#line 684 "HAL_S.y"
              { (yyval.arith_conv_) = make_ADarithConv_matrix(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4344 "Parser.c"
    break;

  case 32: /* DECLARATION_LIST: DECLARATION  */
#line 686 "HAL_S.y"
                               { (yyval.declaration_list_) = make_AAdeclaration_list((yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 4350 "Parser.c"
    break;

  case 33: /* DECLARATION_LIST: DCL_LIST_COMMA DECLARATION  */
#line 687 "HAL_S.y"
                               { (yyval.declaration_list_) = make_ABdeclaration_list((yyvsp[-1].dcl_list_comma_), (yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 4356 "Parser.c"
    break;

  case 34: /* NAME_ID: IDENTIFIER  */
#line 689 "HAL_S.y"
                     { (yyval.name_id_) = make_AAnameId_identifier((yyvsp[0].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4362 "Parser.c"
    break;

  case 35: /* NAME_ID: IDENTIFIER _SYMB_111  */
#line 690 "HAL_S.y"
                         { (yyval.name_id_) = make_ABnameId_identifier_name((yyvsp[-1].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4368 "Parser.c"
    break;

  case 36: /* NAME_ID: BIT_ID  */
#line 691 "HAL_S.y"
           { (yyval.name_id_) = make_ACnameId_bitId((yyvsp[0].bit_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4374 "Parser.c"
    break;

  case 37: /* NAME_ID: CHAR_ID  */
#line 692 "HAL_S.y"
            { (yyval.name_id_) = make_ADnameId_charId((yyvsp[0].char_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4380 "Parser.c"
    break;

  case 38: /* NAME_ID: _SYMB_184  */
#line 693 "HAL_S.y"
              { (yyval.name_id_) = make_AEnameId_bitFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4386 "Parser.c"
    break;

  case 39: /* NAME_ID: _SYMB_185  */
#line 694 "HAL_S.y"
              { (yyval.name_id_) = make_AFnameId_charFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4392 "Parser.c"
    break;

  case 40: /* NAME_ID: _SYMB_187  */
#line 695 "HAL_S.y"
              { (yyval.name_id_) = make_AGnameId_structIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4398 "Parser.c"
    break;

  case 41: /* NAME_ID: _SYMB_188  */
#line 696 "HAL_S.y"
              { (yyval.name_id_) = make_AHnameId_structFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4404 "Parser.c"
    break;

  case 42: /* ARITH_EXP: TERM  */
#line 698 "HAL_S.y"
                 { (yyval.arith_exp_) = make_AAarithExpTerm((yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4410 "Parser.c"
    break;

  case 43: /* ARITH_EXP: PLUS TERM  */
#line 699 "HAL_S.y"
              { (yyval.arith_exp_) = make_ABarithExpPlusTerm((yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4416 "Parser.c"
    break;

  case 44: /* ARITH_EXP: MINUS TERM  */
#line 700 "HAL_S.y"
               { (yyval.arith_exp_) = make_ACarithMinusTerm((yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4422 "Parser.c"
    break;

  case 45: /* ARITH_EXP: ARITH_EXP PLUS TERM  */
#line 701 "HAL_S.y"
                        { (yyval.arith_exp_) = make_ADarithExpArithExpPlusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4428 "Parser.c"
    break;

  case 46: /* ARITH_EXP: ARITH_EXP MINUS TERM  */
#line 702 "HAL_S.y"
                         { (yyval.arith_exp_) = make_AEarithExpArithExpMinusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4434 "Parser.c"
    break;

  case 47: /* TERM: PRODUCT  */
#line 704 "HAL_S.y"
               { (yyval.term_) = make_AAtermNoDivide((yyvsp[0].product_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4440 "Parser.c"
    break;

  case 48: /* TERM: PRODUCT _SYMB_3 TERM  */
#line 705 "HAL_S.y"
                         { (yyval.term_) = make_ABtermDivide((yyvsp[-2].product_), (yyvsp[0].term_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4446 "Parser.c"
    break;

  case 49: /* PLUS: _SYMB_4  */
#line 707 "HAL_S.y"
               { (yyval.plus_) = make_AAplus(); (yyval.plus_)->line_number = (yyloc).first_line; (yyval.plus_)->char_number = (yyloc).first_column;  }
#line 4452 "Parser.c"
    break;

  case 50: /* MINUS: _SYMB_5  */
#line 709 "HAL_S.y"
                { (yyval.minus_) = make_AAminus(); (yyval.minus_)->line_number = (yyloc).first_line; (yyval.minus_)->char_number = (yyloc).first_column;  }
#line 4458 "Parser.c"
    break;

  case 51: /* PRODUCT: FACTOR  */
#line 711 "HAL_S.y"
                 { (yyval.product_) = make_AAproductSingle((yyvsp[0].factor_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4464 "Parser.c"
    break;

  case 52: /* PRODUCT: FACTOR _SYMB_6 PRODUCT  */
#line 712 "HAL_S.y"
                           { (yyval.product_) = make_ABproductCross((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4470 "Parser.c"
    break;

  case 53: /* PRODUCT: FACTOR _SYMB_7 PRODUCT  */
#line 713 "HAL_S.y"
                           { (yyval.product_) = make_ACproductDot((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4476 "Parser.c"
    break;

  case 54: /* PRODUCT: FACTOR PRODUCT  */
#line 714 "HAL_S.y"
                   { (yyval.product_) = make_ADproductMultiplication((yyvsp[-1].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4482 "Parser.c"
    break;

  case 55: /* FACTOR: PRIMARY  */
#line 716 "HAL_S.y"
                 { (yyval.factor_) = make_AAfactor((yyvsp[0].primary_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4488 "Parser.c"
    break;

  case 56: /* FACTOR: PRIMARY EXPONENTIATION FACTOR  */
#line 717 "HAL_S.y"
                                  { (yyval.factor_) = make_ABfactorExponentiation((yyvsp[-2].primary_), (yyvsp[-1].exponentiation_), (yyvsp[0].factor_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4494 "Parser.c"
    break;

  case 57: /* EXPONENTIATION: _SYMB_8  */
#line 719 "HAL_S.y"
                         { (yyval.exponentiation_) = make_AAexponentiation(); (yyval.exponentiation_)->line_number = (yyloc).first_line; (yyval.exponentiation_)->char_number = (yyloc).first_column;  }
#line 4500 "Parser.c"
    break;

  case 58: /* PRIMARY: ARITH_VAR  */
#line 721 "HAL_S.y"
                    { (yyval.primary_) = make_AAprimary((yyvsp[0].arith_var_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4506 "Parser.c"
    break;

  case 59: /* PRIMARY: PRE_PRIMARY  */
#line 722 "HAL_S.y"
                { (yyval.primary_) = make_ADprimary((yyvsp[0].pre_primary_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4512 "Parser.c"
    break;

  case 60: /* PRIMARY: MODIFIED_ARITH_FUNC  */
#line 723 "HAL_S.y"
                        { (yyval.primary_) = make_ABprimary((yyvsp[0].modified_arith_func_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4518 "Parser.c"
    break;

  case 61: /* PRIMARY: PRE_PRIMARY QUALIFIER  */
#line 724 "HAL_S.y"
                          { (yyval.primary_) = make_AEprimary((yyvsp[-1].pre_primary_), (yyvsp[0].qualifier_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4524 "Parser.c"
    break;

  case 62: /* ARITH_VAR: ARITH_ID  */
#line 726 "HAL_S.y"
                     { (yyval.arith_var_) = make_AAarith_var((yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4530 "Parser.c"
    break;

  case 63: /* ARITH_VAR: ARITH_ID SUBSCRIPT  */
#line 727 "HAL_S.y"
                       { (yyval.arith_var_) = make_ACarith_var((yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4536 "Parser.c"
    break;

  case 64: /* ARITH_VAR: _SYMB_10 ARITH_ID _SYMB_11  */
#line 728 "HAL_S.y"
                               { (yyval.arith_var_) = make_AAarithVarBracketed((yyvsp[-1].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4542 "Parser.c"
    break;

  case 65: /* ARITH_VAR: _SYMB_10 ARITH_ID _SYMB_11 SUBSCRIPT  */
#line 729 "HAL_S.y"
                                         { (yyval.arith_var_) = make_ABarithVarBracketed((yyvsp[-2].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4548 "Parser.c"
    break;

  case 66: /* ARITH_VAR: _SYMB_12 QUAL_STRUCT _SYMB_13  */
#line 730 "HAL_S.y"
                                  { (yyval.arith_var_) = make_AAarithVarBraced((yyvsp[-1].qual_struct_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4554 "Parser.c"
    break;

  case 67: /* ARITH_VAR: _SYMB_12 QUAL_STRUCT _SYMB_13 SUBSCRIPT  */
#line 731 "HAL_S.y"
                                            { (yyval.arith_var_) = make_ABarithVarBraced((yyvsp[-2].qual_struct_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4560 "Parser.c"
    break;

  case 68: /* ARITH_VAR: QUAL_STRUCT _SYMB_7 ARITH_ID  */
#line 732 "HAL_S.y"
                                 { (yyval.arith_var_) = make_ABarith_var((yyvsp[-2].qual_struct_), (yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4566 "Parser.c"
    break;

  case 69: /* ARITH_VAR: QUAL_STRUCT _SYMB_7 ARITH_ID SUBSCRIPT  */
#line 733 "HAL_S.y"
                                           { (yyval.arith_var_) = make_ADarith_var((yyvsp[-3].qual_struct_), (yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4572 "Parser.c"
    break;

  case 70: /* PRE_PRIMARY: _SYMB_2 ARITH_EXP _SYMB_1  */
#line 735 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AApre_primary((yyvsp[-1].arith_exp_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4578 "Parser.c"
    break;

  case 71: /* PRE_PRIMARY: NUMBER  */
#line 736 "HAL_S.y"
           { (yyval.pre_primary_) = make_ABpre_primary((yyvsp[0].number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4584 "Parser.c"
    break;

  case 72: /* PRE_PRIMARY: COMPOUND_NUMBER  */
#line 737 "HAL_S.y"
                    { (yyval.pre_primary_) = make_ACpre_primary((yyvsp[0].compound_number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4590 "Parser.c"
    break;

  case 73: /* PRE_PRIMARY: ARITH_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 738 "HAL_S.y"
                                              { (yyval.pre_primary_) = make_ADprePrimaryRtlFunction((yyvsp[-3].arith_func_head_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4596 "Parser.c"
    break;

  case 74: /* PRE_PRIMARY: _SYMB_189 _SYMB_2 CALL_LIST _SYMB_1  */
#line 739 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AEprePrimaryFunction((yyvsp[-3].string_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4602 "Parser.c"
    break;

  case 75: /* NUMBER: SIMPLE_NUMBER  */
#line 741 "HAL_S.y"
                       { (yyval.number_) = make_AAnumber((yyvsp[0].simple_number_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4608 "Parser.c"
    break;

  case 76: /* NUMBER: LEVEL  */
#line 742 "HAL_S.y"
          { (yyval.number_) = make_ABnumber((yyvsp[0].level_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4614 "Parser.c"
    break;

  case 77: /* LEVEL: _SYMB_195  */
#line 744 "HAL_S.y"
                  { (yyval.level_) = make_ZZlevel((yyvsp[0].string_)); (yyval.level_)->line_number = (yyloc).first_line; (yyval.level_)->char_number = (yyloc).first_column;  }
#line 4620 "Parser.c"
    break;

  case 78: /* COMPOUND_NUMBER: _SYMB_197  */
#line 746 "HAL_S.y"
                            { (yyval.compound_number_) = make_CLcompound_number((yyvsp[0].string_)); (yyval.compound_number_)->line_number = (yyloc).first_line; (yyval.compound_number_)->char_number = (yyloc).first_column;  }
#line 4626 "Parser.c"
    break;

  case 79: /* SIMPLE_NUMBER: _SYMB_196  */
#line 748 "HAL_S.y"
                          { (yyval.simple_number_) = make_CKsimple_number((yyvsp[0].string_)); (yyval.simple_number_)->line_number = (yyloc).first_line; (yyval.simple_number_)->char_number = (yyloc).first_column;  }
#line 4632 "Parser.c"
    break;

  case 80: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC  */
#line 750 "HAL_S.y"
                                        { (yyval.modified_arith_func_) = make_AAmodified_arith_func((yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4638 "Parser.c"
    break;

  case 81: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 751 "HAL_S.y"
                                { (yyval.modified_arith_func_) = make_ACmodified_arith_func((yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4644 "Parser.c"
    break;

  case 82: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_7 NO_ARG_ARITH_FUNC  */
#line 752 "HAL_S.y"
                                          { (yyval.modified_arith_func_) = make_ADmodified_arith_func((yyvsp[-2].qual_struct_), (yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4650 "Parser.c"
    break;

  case 83: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_7 NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 753 "HAL_S.y"
                                                    { (yyval.modified_arith_func_) = make_AEmodified_arith_func((yyvsp[-3].qual_struct_), (yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4656 "Parser.c"
    break;

  case 84: /* ARITH_FUNC_HEAD: ARITH_FUNC  */
#line 755 "HAL_S.y"
                             { (yyval.arith_func_head_) = make_AAarith_func_head((yyvsp[0].arith_func_)); (yyval.arith_func_head_)->line_number = (yyloc).first_line; (yyval.arith_func_head_)->char_number = (yyloc).first_column;  }
#line 4662 "Parser.c"
    break;

  case 85: /* ARITH_FUNC_HEAD: ARITH_CONV SUBSCRIPT  */
#line 756 "HAL_S.y"
                         { (yyval.arith_func_head_) = make_ABarith_func_head((yyvsp[-1].arith_conv_), (yyvsp[0].subscript_)); (yyval.arith_func_head_)->line_number = (yyloc).first_line; (yyval.arith_func_head_)->char_number = (yyloc).first_column;  }
#line 4668 "Parser.c"
    break;

  case 86: /* CALL_LIST: LIST_EXP  */
#line 758 "HAL_S.y"
                     { (yyval.call_list_) = make_AAcall_list((yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 4674 "Parser.c"
    break;

  case 87: /* CALL_LIST: CALL_LIST _SYMB_0 LIST_EXP  */
#line 759 "HAL_S.y"
                               { (yyval.call_list_) = make_ABcall_list((yyvsp[-2].call_list_), (yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 4680 "Parser.c"
    break;

  case 88: /* LIST_EXP: EXPRESSION  */
#line 761 "HAL_S.y"
                      { (yyval.list_exp_) = make_AAlist_exp((yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4686 "Parser.c"
    break;

  case 89: /* LIST_EXP: ARITH_EXP _SYMB_9 EXPRESSION  */
#line 762 "HAL_S.y"
                                 { (yyval.list_exp_) = make_ABlist_exp((yyvsp[-2].arith_exp_), (yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4692 "Parser.c"
    break;

  case 90: /* LIST_EXP: QUAL_STRUCT  */
#line 763 "HAL_S.y"
                { (yyval.list_exp_) = make_ADlist_exp((yyvsp[0].qual_struct_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4698 "Parser.c"
    break;

  case 91: /* EXPRESSION: ARITH_EXP  */
#line 765 "HAL_S.y"
                       { (yyval.expression_) = make_AAexpression((yyvsp[0].arith_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4704 "Parser.c"
    break;

  case 92: /* EXPRESSION: BIT_EXP  */
#line 766 "HAL_S.y"
            { (yyval.expression_) = make_ABexpression((yyvsp[0].bit_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4710 "Parser.c"
    break;

  case 93: /* EXPRESSION: CHAR_EXP  */
#line 767 "HAL_S.y"
             { (yyval.expression_) = make_ACexpression((yyvsp[0].char_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4716 "Parser.c"
    break;

  case 94: /* EXPRESSION: NAME_EXP  */
#line 768 "HAL_S.y"
             { (yyval.expression_) = make_AEexpression((yyvsp[0].name_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4722 "Parser.c"
    break;

  case 95: /* EXPRESSION: STRUCTURE_EXP  */
#line 769 "HAL_S.y"
                  { (yyval.expression_) = make_ADexpression((yyvsp[0].structure_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4728 "Parser.c"
    break;

  case 96: /* ARITH_ID: IDENTIFIER  */
#line 771 "HAL_S.y"
                      { (yyval.arith_id_) = make_FGarith_id((yyvsp[0].identifier_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 4734 "Parser.c"
    break;

  case 97: /* ARITH_ID: _SYMB_191  */
#line 772 "HAL_S.y"
              { (yyval.arith_id_) = make_FHarith_id((yyvsp[0].string_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 4740 "Parser.c"
    break;

  case 98: /* NO_ARG_ARITH_FUNC: _SYMB_58  */
#line 774 "HAL_S.y"
                             { (yyval.no_arg_arith_func_) = make_ZZclocktime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4746 "Parser.c"
    break;

  case 99: /* NO_ARG_ARITH_FUNC: _SYMB_65  */
#line 775 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZdate(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4752 "Parser.c"
    break;

  case 100: /* NO_ARG_ARITH_FUNC: _SYMB_77  */
#line 776 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZerrgrp(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4758 "Parser.c"
    break;

  case 101: /* NO_ARG_ARITH_FUNC: _SYMB_78  */
#line 777 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZerrnum(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4764 "Parser.c"
    break;

  case 102: /* NO_ARG_ARITH_FUNC: _SYMB_122  */
#line 778 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZprio(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4770 "Parser.c"
    break;

  case 103: /* NO_ARG_ARITH_FUNC: _SYMB_127  */
#line 779 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZrandom(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4776 "Parser.c"
    break;

  case 104: /* NO_ARG_ARITH_FUNC: _SYMB_128  */
#line 780 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZrandomg(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4782 "Parser.c"
    break;

  case 105: /* NO_ARG_ARITH_FUNC: _SYMB_141  */
#line 781 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZruntime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4788 "Parser.c"
    break;

  case 106: /* ARITH_FUNC: _SYMB_112  */
#line 783 "HAL_S.y"
                       { (yyval.arith_func_) = make_ZZnextime(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4794 "Parser.c"
    break;

  case 107: /* ARITH_FUNC: _SYMB_30  */
#line 784 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabs(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4800 "Parser.c"
    break;

  case 108: /* ARITH_FUNC: _SYMB_55  */
#line 785 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZceiling(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4806 "Parser.c"
    break;

  case 109: /* ARITH_FUNC: _SYMB_71  */
#line 786 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdiv(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4812 "Parser.c"
    break;

  case 110: /* ARITH_FUNC: _SYMB_88  */
#line 787 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZfloor(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4818 "Parser.c"
    break;

  case 111: /* ARITH_FUNC: _SYMB_108  */
#line 788 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmidval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4824 "Parser.c"
    break;

  case 112: /* ARITH_FUNC: _SYMB_110  */
#line 789 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4830 "Parser.c"
    break;

  case 113: /* ARITH_FUNC: _SYMB_117  */
#line 790 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZodd(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4836 "Parser.c"
    break;

  case 114: /* ARITH_FUNC: _SYMB_132  */
#line 791 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZremainder(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4842 "Parser.c"
    break;

  case 115: /* ARITH_FUNC: _SYMB_140  */
#line 792 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZround(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4848 "Parser.c"
    break;

  case 116: /* ARITH_FUNC: _SYMB_148  */
#line 793 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsign(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4854 "Parser.c"
    break;

  case 117: /* ARITH_FUNC: _SYMB_150  */
#line 794 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsignum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4860 "Parser.c"
    break;

  case 118: /* ARITH_FUNC: _SYMB_174  */
#line 795 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtruncate(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4866 "Parser.c"
    break;

  case 119: /* ARITH_FUNC: _SYMB_36  */
#line 796 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4872 "Parser.c"
    break;

  case 120: /* ARITH_FUNC: _SYMB_37  */
#line 797 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4878 "Parser.c"
    break;

  case 121: /* ARITH_FUNC: _SYMB_38  */
#line 798 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4884 "Parser.c"
    break;

  case 122: /* ARITH_FUNC: _SYMB_39  */
#line 799 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4890 "Parser.c"
    break;

  case 123: /* ARITH_FUNC: _SYMB_41  */
#line 800 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan2(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4896 "Parser.c"
    break;

  case 124: /* ARITH_FUNC: _SYMB_40  */
#line 801 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4902 "Parser.c"
    break;

  case 125: /* ARITH_FUNC: _SYMB_42  */
#line 802 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4908 "Parser.c"
    break;

  case 126: /* ARITH_FUNC: _SYMB_63  */
#line 803 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4914 "Parser.c"
    break;

  case 127: /* ARITH_FUNC: _SYMB_64  */
#line 804 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4920 "Parser.c"
    break;

  case 128: /* ARITH_FUNC: _SYMB_84  */
#line 805 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZexp(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4926 "Parser.c"
    break;

  case 129: /* ARITH_FUNC: _SYMB_105  */
#line 806 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZlog(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4932 "Parser.c"
    break;

  case 130: /* ARITH_FUNC: _SYMB_151  */
#line 807 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4938 "Parser.c"
    break;

  case 131: /* ARITH_FUNC: _SYMB_153  */
#line 808 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4944 "Parser.c"
    break;

  case 132: /* ARITH_FUNC: _SYMB_156  */
#line 809 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsqrt(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4950 "Parser.c"
    break;

  case 133: /* ARITH_FUNC: _SYMB_163  */
#line 810 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4956 "Parser.c"
    break;

  case 134: /* ARITH_FUNC: _SYMB_164  */
#line 811 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4962 "Parser.c"
    break;

  case 135: /* ARITH_FUNC: _SYMB_146  */
#line 812 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshl(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4968 "Parser.c"
    break;

  case 136: /* ARITH_FUNC: _SYMB_147  */
#line 813 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshr(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4974 "Parser.c"
    break;

  case 137: /* ARITH_FUNC: _SYMB_31  */
#line 814 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4980 "Parser.c"
    break;

  case 138: /* ARITH_FUNC: _SYMB_70  */
#line 815 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdet(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4986 "Parser.c"
    break;

  case 139: /* ARITH_FUNC: _SYMB_170  */
#line 816 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtrace(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4992 "Parser.c"
    break;

  case 140: /* ARITH_FUNC: _SYMB_175  */
#line 817 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZunit(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4998 "Parser.c"
    break;

  case 141: /* ARITH_FUNC: _SYMB_106  */
#line 818 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmatrix(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5004 "Parser.c"
    break;

  case 142: /* ARITH_FUNC: _SYMB_96  */
#line 819 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZindex(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5010 "Parser.c"
    break;

  case 143: /* ARITH_FUNC: _SYMB_101  */
#line 820 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZlength(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5016 "Parser.c"
    break;

  case 144: /* ARITH_FUNC: _SYMB_99  */
#line 821 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZinverse(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5022 "Parser.c"
    break;

  case 145: /* ARITH_FUNC: _SYMB_171  */
#line 822 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtranspose(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5028 "Parser.c"
    break;

  case 146: /* ARITH_FUNC: _SYMB_125  */
#line 823 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZprod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5034 "Parser.c"
    break;

  case 147: /* ARITH_FUNC: _SYMB_160  */
#line 824 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5040 "Parser.c"
    break;

  case 148: /* ARITH_FUNC: _SYMB_154  */
#line 825 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsize(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5046 "Parser.c"
    break;

  case 149: /* ARITH_FUNC: _SYMB_107  */
#line 826 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmax(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5052 "Parser.c"
    break;

  case 150: /* ARITH_FUNC: _SYMB_109  */
#line 827 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5058 "Parser.c"
    break;

  case 151: /* ARITH_FUNC: _SYMB_98  */
#line 828 "HAL_S.y"
             { (yyval.arith_func_) = make_AAarithFuncInteger(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5064 "Parser.c"
    break;

  case 152: /* ARITH_FUNC: _SYMB_142  */
#line 829 "HAL_S.y"
              { (yyval.arith_func_) = make_AAarithFuncScalar(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5070 "Parser.c"
    break;

  case 153: /* SUBSCRIPT: SUB_HEAD _SYMB_1  */
#line 831 "HAL_S.y"
                             { (yyval.subscript_) = make_AAsubscript((yyvsp[-1].sub_head_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5076 "Parser.c"
    break;

  case 154: /* SUBSCRIPT: QUALIFIER  */
#line 832 "HAL_S.y"
              { (yyval.subscript_) = make_ABsubscript((yyvsp[0].qualifier_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5082 "Parser.c"
    break;

  case 155: /* SUBSCRIPT: _SYMB_14 NUMBER  */
#line 833 "HAL_S.y"
                    { (yyval.subscript_) = make_ACsubscript((yyvsp[0].number_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5088 "Parser.c"
    break;

  case 156: /* SUBSCRIPT: _SYMB_14 ARITH_VAR  */
#line 834 "HAL_S.y"
                       { (yyval.subscript_) = make_ADsubscript((yyvsp[0].arith_var_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5094 "Parser.c"
    break;

  case 157: /* QUALIFIER: _SYMB_14 _SYMB_2 _SYMB_15 PREC_SPEC _SYMB_1  */
#line 836 "HAL_S.y"
                                                        { (yyval.qualifier_) = make_AAqualifier((yyvsp[-1].prec_spec_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5100 "Parser.c"
    break;

  case 158: /* QUALIFIER: _SYMB_14 _SYMB_2 SCALE_HEAD ARITH_EXP _SYMB_1  */
#line 837 "HAL_S.y"
                                                  { (yyval.qualifier_) = make_ABqualifier((yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5106 "Parser.c"
    break;

  case 159: /* QUALIFIER: _SYMB_14 _SYMB_2 _SYMB_15 PREC_SPEC _SYMB_0 SCALE_HEAD ARITH_EXP _SYMB_1  */
#line 838 "HAL_S.y"
                                                                             { (yyval.qualifier_) = make_ACqualifier((yyvsp[-4].prec_spec_), (yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5112 "Parser.c"
    break;

  case 160: /* QUALIFIER: _SYMB_14 _SYMB_2 _SYMB_15 RADIX _SYMB_1  */
#line 839 "HAL_S.y"
                                            { (yyval.qualifier_) = make_ADqualifier((yyvsp[-1].radix_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5118 "Parser.c"
    break;

  case 161: /* SCALE_HEAD: _SYMB_15  */
#line 841 "HAL_S.y"
                      { (yyval.scale_head_) = make_AAscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 5124 "Parser.c"
    break;

  case 162: /* SCALE_HEAD: _SYMB_15 _SYMB_15  */
#line 842 "HAL_S.y"
                      { (yyval.scale_head_) = make_ABscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 5130 "Parser.c"
    break;

  case 163: /* PREC_SPEC: _SYMB_152  */
#line 844 "HAL_S.y"
                      { (yyval.prec_spec_) = make_AAprecSpecSingle(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 5136 "Parser.c"
    break;

  case 164: /* PREC_SPEC: _SYMB_73  */
#line 845 "HAL_S.y"
             { (yyval.prec_spec_) = make_ABprecSpecDouble(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 5142 "Parser.c"
    break;

  case 165: /* SUB_START: _SYMB_14 _SYMB_2  */
#line 847 "HAL_S.y"
                             { (yyval.sub_start_) = make_AAsubStartGroup(); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5148 "Parser.c"
    break;

  case 166: /* SUB_START: _SYMB_14 _SYMB_2 _SYMB_15 PREC_SPEC _SYMB_0  */
#line 848 "HAL_S.y"
                                                { (yyval.sub_start_) = make_ABsubStartPrecSpec((yyvsp[-1].prec_spec_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5154 "Parser.c"
    break;

  case 167: /* SUB_START: SUB_HEAD _SYMB_16  */
#line 849 "HAL_S.y"
                      { (yyval.sub_start_) = make_ACsubStartSemicolon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5160 "Parser.c"
    break;

  case 168: /* SUB_START: SUB_HEAD _SYMB_17  */
#line 850 "HAL_S.y"
                      { (yyval.sub_start_) = make_ADsubStartColon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5166 "Parser.c"
    break;

  case 169: /* SUB_START: SUB_HEAD _SYMB_0  */
#line 851 "HAL_S.y"
                     { (yyval.sub_start_) = make_AEsubStartComma((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5172 "Parser.c"
    break;

  case 170: /* SUB_HEAD: SUB_START  */
#line 853 "HAL_S.y"
                     { (yyval.sub_head_) = make_AAsub_head((yyvsp[0].sub_start_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 5178 "Parser.c"
    break;

  case 171: /* SUB_HEAD: SUB_START SUB  */
#line 854 "HAL_S.y"
                  { (yyval.sub_head_) = make_ABsub_head((yyvsp[-1].sub_start_), (yyvsp[0].sub_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 5184 "Parser.c"
    break;

  case 172: /* SUB: SUB_EXP  */
#line 856 "HAL_S.y"
              { (yyval.sub_) = make_AAsub((yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5190 "Parser.c"
    break;

  case 173: /* SUB: _SYMB_6  */
#line 857 "HAL_S.y"
            { (yyval.sub_) = make_ABsubStar(); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5196 "Parser.c"
    break;

  case 174: /* SUB: SUB_RUN_HEAD SUB_EXP  */
#line 858 "HAL_S.y"
                         { (yyval.sub_) = make_ACsubExp((yyvsp[-1].sub_run_head_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5202 "Parser.c"
    break;

  case 175: /* SUB: ARITH_EXP _SYMB_45 SUB_EXP  */
#line 859 "HAL_S.y"
                               { (yyval.sub_) = make_ADsubAt((yyvsp[-2].arith_exp_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5208 "Parser.c"
    break;

  case 176: /* SUB_RUN_HEAD: SUB_EXP _SYMB_169  */
#line 861 "HAL_S.y"
                                 { (yyval.sub_run_head_) = make_AAsubRunHeadTo((yyvsp[-1].sub_exp_)); (yyval.sub_run_head_)->line_number = (yyloc).first_line; (yyval.sub_run_head_)->char_number = (yyloc).first_column;  }
#line 5214 "Parser.c"
    break;

  case 177: /* SUB_EXP: ARITH_EXP  */
#line 863 "HAL_S.y"
                    { (yyval.sub_exp_) = make_AAsub_exp((yyvsp[0].arith_exp_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 5220 "Parser.c"
    break;

  case 178: /* SUB_EXP: POUND_EXPRESSION  */
#line 864 "HAL_S.y"
                     { (yyval.sub_exp_) = make_ABsub_exp((yyvsp[0].pound_expression_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 5226 "Parser.c"
    break;

  case 179: /* POUND_EXPRESSION: _SYMB_9  */
#line 866 "HAL_S.y"
                           { (yyval.pound_expression_) = make_AApound_expression(); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5232 "Parser.c"
    break;

  case 180: /* POUND_EXPRESSION: POUND_EXPRESSION PLUS TERM  */
#line 867 "HAL_S.y"
                               { (yyval.pound_expression_) = make_ABpound_expression((yyvsp[-2].pound_expression_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5238 "Parser.c"
    break;

  case 181: /* POUND_EXPRESSION: POUND_EXPRESSION MINUS TERM  */
#line 868 "HAL_S.y"
                                { (yyval.pound_expression_) = make_ACpound_expression((yyvsp[-2].pound_expression_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5244 "Parser.c"
    break;

  case 182: /* BIT_EXP: BIT_FACTOR  */
#line 870 "HAL_S.y"
                     { (yyval.bit_exp_) = make_AAbit_exp((yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 5250 "Parser.c"
    break;

  case 183: /* BIT_EXP: BIT_EXP OR BIT_FACTOR  */
#line 871 "HAL_S.y"
                          { (yyval.bit_exp_) = make_ABbit_exp((yyvsp[-2].bit_exp_), (yyvsp[-1].or_), (yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 5256 "Parser.c"
    break;

  case 184: /* BIT_FACTOR: BIT_CAT  */
#line 873 "HAL_S.y"
                     { (yyval.bit_factor_) = make_AAbit_factor((yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 5262 "Parser.c"
    break;

  case 185: /* BIT_FACTOR: BIT_FACTOR AND BIT_CAT  */
#line 874 "HAL_S.y"
                           { (yyval.bit_factor_) = make_ABbit_factor((yyvsp[-2].bit_factor_), (yyvsp[-1].and_), (yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 5268 "Parser.c"
    break;

  case 186: /* BIT_CAT: BIT_PRIM  */
#line 876 "HAL_S.y"
                   { (yyval.bit_cat_) = make_AAbit_cat((yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5274 "Parser.c"
    break;

  case 187: /* BIT_CAT: BIT_CAT CAT BIT_PRIM  */
#line 877 "HAL_S.y"
                         { (yyval.bit_cat_) = make_ABbit_cat((yyvsp[-2].bit_cat_), (yyvsp[-1].cat_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5280 "Parser.c"
    break;

  case 188: /* BIT_CAT: NOT BIT_PRIM  */
#line 878 "HAL_S.y"
                 { (yyval.bit_cat_) = make_ACbit_cat((yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5286 "Parser.c"
    break;

  case 189: /* BIT_CAT: BIT_CAT CAT NOT BIT_PRIM  */
#line 879 "HAL_S.y"
                             { (yyval.bit_cat_) = make_ADbit_cat((yyvsp[-3].bit_cat_), (yyvsp[-2].cat_), (yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5292 "Parser.c"
    break;

  case 190: /* OR: CHAR_VERTICAL_BAR  */
#line 881 "HAL_S.y"
                       { (yyval.or_) = make_AAor((yyvsp[0].char_vertical_bar_)); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5298 "Parser.c"
    break;

  case 191: /* OR: _SYMB_120  */
#line 882 "HAL_S.y"
              { (yyval.or_) = make_ABor(); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5304 "Parser.c"
    break;

  case 192: /* CHAR_VERTICAL_BAR: _SYMB_18  */
#line 884 "HAL_S.y"
                             { (yyval.char_vertical_bar_) = make_CFchar_vertical_bar(); (yyval.char_vertical_bar_)->line_number = (yyloc).first_line; (yyval.char_vertical_bar_)->char_number = (yyloc).first_column;  }
#line 5310 "Parser.c"
    break;

  case 193: /* AND: _SYMB_19  */
#line 886 "HAL_S.y"
               { (yyval.and_) = make_AAand(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5316 "Parser.c"
    break;

  case 194: /* AND: _SYMB_35  */
#line 887 "HAL_S.y"
             { (yyval.and_) = make_ABand(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5322 "Parser.c"
    break;

  case 195: /* BIT_PRIM: BIT_VAR  */
#line 889 "HAL_S.y"
                   { (yyval.bit_prim_) = make_AAbitPrimBitVar((yyvsp[0].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5328 "Parser.c"
    break;

  case 196: /* BIT_PRIM: LABEL_VAR  */
#line 890 "HAL_S.y"
              { (yyval.bit_prim_) = make_ABbitPrimLabelVar((yyvsp[0].label_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5334 "Parser.c"
    break;

  case 197: /* BIT_PRIM: EVENT_VAR  */
#line 891 "HAL_S.y"
              { (yyval.bit_prim_) = make_ACbitPrimEventVar((yyvsp[0].event_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5340 "Parser.c"
    break;

  case 198: /* BIT_PRIM: BIT_CONST  */
#line 892 "HAL_S.y"
              { (yyval.bit_prim_) = make_ADbitBitConst((yyvsp[0].bit_const_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5346 "Parser.c"
    break;

  case 199: /* BIT_PRIM: _SYMB_2 BIT_EXP _SYMB_1  */
#line 893 "HAL_S.y"
                            { (yyval.bit_prim_) = make_AEbitPrimBitExp((yyvsp[-1].bit_exp_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5352 "Parser.c"
    break;

  case 200: /* BIT_PRIM: SUBBIT_HEAD EXPRESSION _SYMB_1  */
#line 894 "HAL_S.y"
                                   { (yyval.bit_prim_) = make_AHbitPrimSubbit((yyvsp[-2].subbit_head_), (yyvsp[-1].expression_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5358 "Parser.c"
    break;

  case 201: /* BIT_PRIM: BIT_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 895 "HAL_S.y"
                                            { (yyval.bit_prim_) = make_AIbitPrimFunc((yyvsp[-3].bit_func_head_), (yyvsp[-1].call_list_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5364 "Parser.c"
    break;

  case 202: /* BIT_PRIM: _SYMB_10 BIT_VAR _SYMB_11  */
#line 896 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBracketed((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5370 "Parser.c"
    break;

  case 203: /* BIT_PRIM: _SYMB_10 BIT_VAR _SYMB_11 SUBSCRIPT  */
#line 897 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBracketed((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5376 "Parser.c"
    break;

  case 204: /* BIT_PRIM: _SYMB_12 BIT_VAR _SYMB_13  */
#line 898 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBraced((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5382 "Parser.c"
    break;

  case 205: /* BIT_PRIM: _SYMB_12 BIT_VAR _SYMB_13 SUBSCRIPT  */
#line 899 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBraced((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5388 "Parser.c"
    break;

  case 206: /* CAT: _SYMB_20  */
#line 901 "HAL_S.y"
               { (yyval.cat_) = make_AAcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5394 "Parser.c"
    break;

  case 207: /* CAT: _SYMB_54  */
#line 902 "HAL_S.y"
             { (yyval.cat_) = make_ABcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5400 "Parser.c"
    break;

  case 208: /* NOT: _SYMB_21  */
#line 904 "HAL_S.y"
               { (yyval.not_) = make_AAnot(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5406 "Parser.c"
    break;

  case 209: /* NOT: _SYMB_114  */
#line 905 "HAL_S.y"
              { (yyval.not_) = make_ABnot(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5412 "Parser.c"
    break;

  case 210: /* NOT: _SYMB_22  */
#line 906 "HAL_S.y"
             { (yyval.not_) = make_ACnot(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5418 "Parser.c"
    break;

  case 211: /* NOT: _SYMB_23  */
#line 907 "HAL_S.y"
             { (yyval.not_) = make_ADnot(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5424 "Parser.c"
    break;

  case 212: /* BIT_VAR: BIT_ID  */
#line 909 "HAL_S.y"
                 { (yyval.bit_var_) = make_AAbit_var((yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5430 "Parser.c"
    break;

  case 213: /* BIT_VAR: BIT_ID SUBSCRIPT  */
#line 910 "HAL_S.y"
                     { (yyval.bit_var_) = make_ACbit_var((yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5436 "Parser.c"
    break;

  case 214: /* BIT_VAR: QUAL_STRUCT _SYMB_7 BIT_ID  */
#line 911 "HAL_S.y"
                               { (yyval.bit_var_) = make_ABbit_var((yyvsp[-2].qual_struct_), (yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5442 "Parser.c"
    break;

  case 215: /* BIT_VAR: QUAL_STRUCT _SYMB_7 BIT_ID SUBSCRIPT  */
#line 912 "HAL_S.y"
                                         { (yyval.bit_var_) = make_ADbit_var((yyvsp[-3].qual_struct_), (yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5448 "Parser.c"
    break;

  case 216: /* LABEL_VAR: LABEL  */
#line 914 "HAL_S.y"
                  { (yyval.label_var_) = make_AAlabel_var((yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5454 "Parser.c"
    break;

  case 217: /* LABEL_VAR: LABEL SUBSCRIPT  */
#line 915 "HAL_S.y"
                    { (yyval.label_var_) = make_ABlabel_var((yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5460 "Parser.c"
    break;

  case 218: /* LABEL_VAR: QUAL_STRUCT _SYMB_7 LABEL  */
#line 916 "HAL_S.y"
                              { (yyval.label_var_) = make_AClabel_var((yyvsp[-2].qual_struct_), (yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5466 "Parser.c"
    break;

  case 219: /* LABEL_VAR: QUAL_STRUCT _SYMB_7 LABEL SUBSCRIPT  */
#line 917 "HAL_S.y"
                                        { (yyval.label_var_) = make_ADlabel_var((yyvsp[-3].qual_struct_), (yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5472 "Parser.c"
    break;

  case 220: /* EVENT_VAR: EVENT  */
#line 919 "HAL_S.y"
                  { (yyval.event_var_) = make_AAevent_var((yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5478 "Parser.c"
    break;

  case 221: /* EVENT_VAR: EVENT SUBSCRIPT  */
#line 920 "HAL_S.y"
                    { (yyval.event_var_) = make_ACevent_var((yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5484 "Parser.c"
    break;

  case 222: /* EVENT_VAR: QUAL_STRUCT _SYMB_7 EVENT  */
#line 921 "HAL_S.y"
                              { (yyval.event_var_) = make_ABevent_var((yyvsp[-2].qual_struct_), (yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5490 "Parser.c"
    break;

  case 223: /* EVENT_VAR: QUAL_STRUCT _SYMB_7 EVENT SUBSCRIPT  */
#line 922 "HAL_S.y"
                                        { (yyval.event_var_) = make_ADevent_var((yyvsp[-3].qual_struct_), (yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5496 "Parser.c"
    break;

  case 224: /* BIT_CONST_HEAD: RADIX  */
#line 924 "HAL_S.y"
                       { (yyval.bit_const_head_) = make_AAbit_const_head((yyvsp[0].radix_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5502 "Parser.c"
    break;

  case 225: /* BIT_CONST_HEAD: RADIX _SYMB_2 NUMBER _SYMB_1  */
#line 925 "HAL_S.y"
                                 { (yyval.bit_const_head_) = make_ABbit_const_head((yyvsp[-3].radix_), (yyvsp[-1].number_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5508 "Parser.c"
    break;

  case 226: /* BIT_CONST: BIT_CONST_HEAD CHAR_STRING  */
#line 927 "HAL_S.y"
                                       { (yyval.bit_const_) = make_AAbitConstString((yyvsp[-1].bit_const_head_), (yyvsp[0].char_string_)); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5514 "Parser.c"
    break;

  case 227: /* BIT_CONST: _SYMB_173  */
#line 928 "HAL_S.y"
              { (yyval.bit_const_) = make_ABbitConstTrue(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5520 "Parser.c"
    break;

  case 228: /* BIT_CONST: _SYMB_86  */
#line 929 "HAL_S.y"
             { (yyval.bit_const_) = make_ACbitConstFalse(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5526 "Parser.c"
    break;

  case 229: /* BIT_CONST: _SYMB_119  */
#line 930 "HAL_S.y"
              { (yyval.bit_const_) = make_ADbitConstOn(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5532 "Parser.c"
    break;

  case 230: /* BIT_CONST: _SYMB_118  */
#line 931 "HAL_S.y"
              { (yyval.bit_const_) = make_AEbitConstOff(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5538 "Parser.c"
    break;

  case 231: /* RADIX: _SYMB_92  */
#line 933 "HAL_S.y"
                 { (yyval.radix_) = make_AAradixHEX(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5544 "Parser.c"
    break;

  case 232: /* RADIX: _SYMB_116  */
#line 934 "HAL_S.y"
              { (yyval.radix_) = make_ABradixOCT(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5550 "Parser.c"
    break;

  case 233: /* RADIX: _SYMB_47  */
#line 935 "HAL_S.y"
             { (yyval.radix_) = make_ACradixBIN(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5556 "Parser.c"
    break;

  case 234: /* RADIX: _SYMB_66  */
#line 936 "HAL_S.y"
             { (yyval.radix_) = make_ADradixDEC(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5562 "Parser.c"
    break;

  case 235: /* CHAR_STRING: _SYMB_193  */
#line 938 "HAL_S.y"
                        { (yyval.char_string_) = make_FPchar_string((yyvsp[0].string_)); (yyval.char_string_)->line_number = (yyloc).first_line; (yyval.char_string_)->char_number = (yyloc).first_column;  }
#line 5568 "Parser.c"
    break;

  case 236: /* SUBBIT_HEAD: SUBBIT_KEY _SYMB_2  */
#line 940 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_AAsubbit_head((yyvsp[-1].subbit_key_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5574 "Parser.c"
    break;

  case 237: /* SUBBIT_HEAD: SUBBIT_KEY SUBSCRIPT _SYMB_2  */
#line 941 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_ABsubbit_head((yyvsp[-2].subbit_key_), (yyvsp[-1].subscript_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5580 "Parser.c"
    break;

  case 238: /* SUBBIT_KEY: _SYMB_159  */
#line 943 "HAL_S.y"
                       { (yyval.subbit_key_) = make_AAsubbit_key(); (yyval.subbit_key_)->line_number = (yyloc).first_line; (yyval.subbit_key_)->char_number = (yyloc).first_column;  }
#line 5586 "Parser.c"
    break;

  case 239: /* BIT_FUNC_HEAD: BIT_FUNC  */
#line 945 "HAL_S.y"
                         { (yyval.bit_func_head_) = make_AAbit_func_head((yyvsp[0].bit_func_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5592 "Parser.c"
    break;

  case 240: /* BIT_FUNC_HEAD: _SYMB_48  */
#line 946 "HAL_S.y"
             { (yyval.bit_func_head_) = make_ABbit_func_head(); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5598 "Parser.c"
    break;

  case 241: /* BIT_FUNC_HEAD: _SYMB_48 SUB_OR_QUALIFIER  */
#line 947 "HAL_S.y"
                              { (yyval.bit_func_head_) = make_ACbit_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5604 "Parser.c"
    break;

  case 242: /* BIT_ID: _SYMB_183  */
#line 949 "HAL_S.y"
                   { (yyval.bit_id_) = make_FHbit_id((yyvsp[0].string_)); (yyval.bit_id_)->line_number = (yyloc).first_line; (yyval.bit_id_)->char_number = (yyloc).first_column;  }
#line 5610 "Parser.c"
    break;

  case 243: /* LABEL: _SYMB_189  */
#line 951 "HAL_S.y"
                  { (yyval.label_) = make_FKlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5616 "Parser.c"
    break;

  case 244: /* LABEL: _SYMB_184  */
#line 952 "HAL_S.y"
              { (yyval.label_) = make_FLlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5622 "Parser.c"
    break;

  case 245: /* LABEL: _SYMB_185  */
#line 953 "HAL_S.y"
              { (yyval.label_) = make_FMlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5628 "Parser.c"
    break;

  case 246: /* LABEL: _SYMB_188  */
#line 954 "HAL_S.y"
              { (yyval.label_) = make_FNlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5634 "Parser.c"
    break;

  case 247: /* BIT_FUNC: _SYMB_182  */
#line 956 "HAL_S.y"
                     { (yyval.bit_func_) = make_ZZxor(); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5640 "Parser.c"
    break;

  case 248: /* BIT_FUNC: _SYMB_184  */
#line 957 "HAL_S.y"
              { (yyval.bit_func_) = make_ZZuserBitFunction((yyvsp[0].string_)); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5646 "Parser.c"
    break;

  case 249: /* EVENT: _SYMB_190  */
#line 959 "HAL_S.y"
                  { (yyval.event_) = make_FLevent((yyvsp[0].string_)); (yyval.event_)->line_number = (yyloc).first_line; (yyval.event_)->char_number = (yyloc).first_column;  }
#line 5652 "Parser.c"
    break;

  case 250: /* SUB_OR_QUALIFIER: SUBSCRIPT  */
#line 961 "HAL_S.y"
                             { (yyval.sub_or_qualifier_) = make_AAsub_or_qualifier((yyvsp[0].subscript_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 5658 "Parser.c"
    break;

  case 251: /* SUB_OR_QUALIFIER: BIT_QUALIFIER  */
#line 962 "HAL_S.y"
                  { (yyval.sub_or_qualifier_) = make_ABsub_or_qualifier((yyvsp[0].bit_qualifier_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 5664 "Parser.c"
    break;

  case 252: /* BIT_QUALIFIER: _SYMB_24 _SYMB_14 _SYMB_2 _SYMB_15 RADIX _SYMB_1  */
#line 964 "HAL_S.y"
                                                                 { (yyval.bit_qualifier_) = make_AAbit_qualifier((yyvsp[-1].radix_)); (yyval.bit_qualifier_)->line_number = (yyloc).first_line; (yyval.bit_qualifier_)->char_number = (yyloc).first_column;  }
#line 5670 "Parser.c"
    break;

  case 253: /* CHAR_EXP: CHAR_PRIM  */
#line 966 "HAL_S.y"
                     { (yyval.char_exp_) = make_AAcharExpPrim((yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5676 "Parser.c"
    break;

  case 254: /* CHAR_EXP: CHAR_EXP CAT CHAR_PRIM  */
#line 967 "HAL_S.y"
                           { (yyval.char_exp_) = make_ABcharExpCat((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5682 "Parser.c"
    break;

  case 255: /* CHAR_EXP: CHAR_EXP CAT ARITH_EXP  */
#line 968 "HAL_S.y"
                           { (yyval.char_exp_) = make_ACcharExpCat((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5688 "Parser.c"
    break;

  case 256: /* CHAR_EXP: ARITH_EXP CAT ARITH_EXP  */
#line 969 "HAL_S.y"
                            { (yyval.char_exp_) = make_ADcharExpCat((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5694 "Parser.c"
    break;

  case 257: /* CHAR_EXP: ARITH_EXP CAT CHAR_PRIM  */
#line 970 "HAL_S.y"
                            { (yyval.char_exp_) = make_AEcharExpCat((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5700 "Parser.c"
    break;

  case 258: /* CHAR_PRIM: CHAR_VAR  */
#line 972 "HAL_S.y"
                     { (yyval.char_prim_) = make_AAchar_prim((yyvsp[0].char_var_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5706 "Parser.c"
    break;

  case 259: /* CHAR_PRIM: CHAR_CONST  */
#line 973 "HAL_S.y"
               { (yyval.char_prim_) = make_ABchar_prim((yyvsp[0].char_const_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5712 "Parser.c"
    break;

  case 260: /* CHAR_PRIM: CHAR_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 974 "HAL_S.y"
                                             { (yyval.char_prim_) = make_AEchar_prim((yyvsp[-3].char_func_head_), (yyvsp[-1].call_list_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5718 "Parser.c"
    break;

  case 261: /* CHAR_PRIM: _SYMB_2 CHAR_EXP _SYMB_1  */
#line 975 "HAL_S.y"
                             { (yyval.char_prim_) = make_AFchar_prim((yyvsp[-1].char_exp_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5724 "Parser.c"
    break;

  case 262: /* CHAR_FUNC_HEAD: CHAR_FUNC  */
#line 977 "HAL_S.y"
                           { (yyval.char_func_head_) = make_AAchar_func_head((yyvsp[0].char_func_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 5730 "Parser.c"
    break;

  case 263: /* CHAR_FUNC_HEAD: _SYMB_57 SUB_OR_QUALIFIER  */
#line 978 "HAL_S.y"
                              { (yyval.char_func_head_) = make_ABchar_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 5736 "Parser.c"
    break;

  case 264: /* CHAR_VAR: CHAR_ID  */
#line 980 "HAL_S.y"
                   { (yyval.char_var_) = make_AAchar_var((yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5742 "Parser.c"
    break;

  case 265: /* CHAR_VAR: CHAR_ID SUBSCRIPT  */
#line 981 "HAL_S.y"
                      { (yyval.char_var_) = make_ACchar_var((yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5748 "Parser.c"
    break;

  case 266: /* CHAR_VAR: QUAL_STRUCT _SYMB_7 CHAR_ID  */
#line 982 "HAL_S.y"
                                { (yyval.char_var_) = make_ABchar_var((yyvsp[-2].qual_struct_), (yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5754 "Parser.c"
    break;

  case 267: /* CHAR_VAR: QUAL_STRUCT _SYMB_7 CHAR_ID SUBSCRIPT  */
#line 983 "HAL_S.y"
                                          { (yyval.char_var_) = make_ADchar_var((yyvsp[-3].qual_struct_), (yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5760 "Parser.c"
    break;

  case 268: /* CHAR_CONST: CHAR_STRING  */
#line 985 "HAL_S.y"
                         { (yyval.char_const_) = make_AAchar_const((yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 5766 "Parser.c"
    break;

  case 269: /* CHAR_CONST: _SYMB_56 _SYMB_2 NUMBER _SYMB_1 CHAR_STRING  */
#line 986 "HAL_S.y"
                                                { (yyval.char_const_) = make_ABchar_const((yyvsp[-2].number_), (yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 5772 "Parser.c"
    break;

  case 270: /* CHAR_FUNC: _SYMB_103  */
#line 988 "HAL_S.y"
                      { (yyval.char_func_) = make_ZZljust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5778 "Parser.c"
    break;

  case 271: /* CHAR_FUNC: _SYMB_139  */
#line 989 "HAL_S.y"
              { (yyval.char_func_) = make_ZZrjust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5784 "Parser.c"
    break;

  case 272: /* CHAR_FUNC: _SYMB_172  */
#line 990 "HAL_S.y"
              { (yyval.char_func_) = make_ZZtrim(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5790 "Parser.c"
    break;

  case 273: /* CHAR_FUNC: _SYMB_185  */
#line 991 "HAL_S.y"
              { (yyval.char_func_) = make_ZZuserCharFunction((yyvsp[0].string_)); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5796 "Parser.c"
    break;

  case 274: /* CHAR_FUNC: _SYMB_57  */
#line 992 "HAL_S.y"
             { (yyval.char_func_) = make_AAcharFuncCharacter(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5802 "Parser.c"
    break;

  case 275: /* CHAR_ID: _SYMB_186  */
#line 994 "HAL_S.y"
                    { (yyval.char_id_) = make_FIchar_id((yyvsp[0].string_)); (yyval.char_id_)->line_number = (yyloc).first_line; (yyval.char_id_)->char_number = (yyloc).first_column;  }
#line 5808 "Parser.c"
    break;

  case 276: /* NAME_EXP: NAME_KEY _SYMB_2 NAME_VAR _SYMB_1  */
#line 996 "HAL_S.y"
                                             { (yyval.name_exp_) = make_AAnameExpKeyVar((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5814 "Parser.c"
    break;

  case 277: /* NAME_EXP: _SYMB_115  */
#line 997 "HAL_S.y"
              { (yyval.name_exp_) = make_ABnameExpNull(); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5820 "Parser.c"
    break;

  case 278: /* NAME_EXP: NAME_KEY _SYMB_2 _SYMB_115 _SYMB_1  */
#line 998 "HAL_S.y"
                                       { (yyval.name_exp_) = make_ACnameExpKeyNull((yyvsp[-3].name_key_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5826 "Parser.c"
    break;

  case 279: /* NAME_KEY: _SYMB_111  */
#line 1000 "HAL_S.y"
                     { (yyval.name_key_) = make_AAname_key(); (yyval.name_key_)->line_number = (yyloc).first_line; (yyval.name_key_)->char_number = (yyloc).first_column;  }
#line 5832 "Parser.c"
    break;

  case 280: /* NAME_VAR: VARIABLE  */
#line 1002 "HAL_S.y"
                    { (yyval.name_var_) = make_AAname_var((yyvsp[0].variable_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5838 "Parser.c"
    break;

  case 281: /* NAME_VAR: MODIFIED_ARITH_FUNC  */
#line 1003 "HAL_S.y"
                        { (yyval.name_var_) = make_ACname_var((yyvsp[0].modified_arith_func_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5844 "Parser.c"
    break;

  case 282: /* NAME_VAR: LABEL_VAR  */
#line 1004 "HAL_S.y"
              { (yyval.name_var_) = make_ABname_var((yyvsp[0].label_var_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5850 "Parser.c"
    break;

  case 283: /* VARIABLE: ARITH_VAR  */
#line 1006 "HAL_S.y"
                     { (yyval.variable_) = make_AAvariable((yyvsp[0].arith_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5856 "Parser.c"
    break;

  case 284: /* VARIABLE: BIT_VAR  */
#line 1007 "HAL_S.y"
            { (yyval.variable_) = make_ACvariable((yyvsp[0].bit_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5862 "Parser.c"
    break;

  case 285: /* VARIABLE: SUBBIT_HEAD VARIABLE _SYMB_1  */
#line 1008 "HAL_S.y"
                                 { (yyval.variable_) = make_AEvariable((yyvsp[-2].subbit_head_), (yyvsp[-1].variable_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5868 "Parser.c"
    break;

  case 286: /* VARIABLE: CHAR_VAR  */
#line 1009 "HAL_S.y"
             { (yyval.variable_) = make_AFvariable((yyvsp[0].char_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5874 "Parser.c"
    break;

  case 287: /* VARIABLE: NAME_KEY _SYMB_2 NAME_VAR _SYMB_1  */
#line 1010 "HAL_S.y"
                                      { (yyval.variable_) = make_AGvariable((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5880 "Parser.c"
    break;

  case 288: /* VARIABLE: EVENT_VAR  */
#line 1011 "HAL_S.y"
              { (yyval.variable_) = make_ADvariable((yyvsp[0].event_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5886 "Parser.c"
    break;

  case 289: /* VARIABLE: STRUCTURE_VAR  */
#line 1012 "HAL_S.y"
                  { (yyval.variable_) = make_ABvariable((yyvsp[0].structure_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5892 "Parser.c"
    break;

  case 290: /* STRUCTURE_EXP: STRUCTURE_VAR  */
#line 1014 "HAL_S.y"
                              { (yyval.structure_exp_) = make_AAstructure_exp((yyvsp[0].structure_var_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5898 "Parser.c"
    break;

  case 291: /* STRUCTURE_EXP: STRUCT_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 1015 "HAL_S.y"
                                               { (yyval.structure_exp_) = make_ADstructure_exp((yyvsp[-3].struct_func_head_), (yyvsp[-1].call_list_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5904 "Parser.c"
    break;

  case 292: /* STRUCTURE_EXP: STRUC_INLINE_DEF CLOSING _SYMB_16  */
#line 1016 "HAL_S.y"
                                      { (yyval.structure_exp_) = make_ACstructure_exp((yyvsp[-2].struc_inline_def_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5910 "Parser.c"
    break;

  case 293: /* STRUCTURE_EXP: STRUC_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1017 "HAL_S.y"
                                                 { (yyval.structure_exp_) = make_AEstructure_exp((yyvsp[-3].struc_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5916 "Parser.c"
    break;

  case 294: /* STRUCT_FUNC_HEAD: STRUCT_FUNC  */
#line 1019 "HAL_S.y"
                               { (yyval.struct_func_head_) = make_AAstruct_func_head((yyvsp[0].struct_func_)); (yyval.struct_func_head_)->line_number = (yyloc).first_line; (yyval.struct_func_head_)->char_number = (yyloc).first_column;  }
#line 5922 "Parser.c"
    break;

  case 295: /* STRUCTURE_VAR: QUAL_STRUCT SUBSCRIPT  */
#line 1021 "HAL_S.y"
                                      { (yyval.structure_var_) = make_AAstructure_var((yyvsp[-1].qual_struct_), (yyvsp[0].subscript_)); (yyval.structure_var_)->line_number = (yyloc).first_line; (yyval.structure_var_)->char_number = (yyloc).first_column;  }
#line 5928 "Parser.c"
    break;

  case 296: /* STRUCT_FUNC: _SYMB_188  */
#line 1023 "HAL_S.y"
                        { (yyval.struct_func_) = make_ZZuserStructFunc((yyvsp[0].string_)); (yyval.struct_func_)->line_number = (yyloc).first_line; (yyval.struct_func_)->char_number = (yyloc).first_column;  }
#line 5934 "Parser.c"
    break;

  case 297: /* QUAL_STRUCT: STRUCTURE_ID  */
#line 1025 "HAL_S.y"
                           { (yyval.qual_struct_) = make_AAqual_struct((yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 5940 "Parser.c"
    break;

  case 298: /* QUAL_STRUCT: QUAL_STRUCT _SYMB_7 STRUCTURE_ID  */
#line 1026 "HAL_S.y"
                                     { (yyval.qual_struct_) = make_ABqual_struct((yyvsp[-2].qual_struct_), (yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 5946 "Parser.c"
    break;

  case 299: /* STRUCTURE_ID: _SYMB_187  */
#line 1028 "HAL_S.y"
                         { (yyval.structure_id_) = make_FJstructure_id((yyvsp[0].string_)); (yyval.structure_id_)->line_number = (yyloc).first_line; (yyval.structure_id_)->char_number = (yyloc).first_column;  }
#line 5952 "Parser.c"
    break;

  case 300: /* ASSIGNMENT: VARIABLE EQUALS EXPRESSION  */
#line 1030 "HAL_S.y"
                                        { (yyval.assignment_) = make_AAassignment((yyvsp[-2].variable_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5958 "Parser.c"
    break;

  case 301: /* ASSIGNMENT: VARIABLE _SYMB_0 ASSIGNMENT  */
#line 1031 "HAL_S.y"
                                { (yyval.assignment_) = make_ABassignment((yyvsp[-2].variable_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5964 "Parser.c"
    break;

  case 302: /* ASSIGNMENT: QUAL_STRUCT EQUALS EXPRESSION  */
#line 1032 "HAL_S.y"
                                  { (yyval.assignment_) = make_ACassignment((yyvsp[-2].qual_struct_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5970 "Parser.c"
    break;

  case 303: /* ASSIGNMENT: QUAL_STRUCT _SYMB_0 ASSIGNMENT  */
#line 1033 "HAL_S.y"
                                   { (yyval.assignment_) = make_ADassignment((yyvsp[-2].qual_struct_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5976 "Parser.c"
    break;

  case 304: /* EQUALS: _SYMB_25  */
#line 1035 "HAL_S.y"
                  { (yyval.equals_) = make_AAequals(); (yyval.equals_)->line_number = (yyloc).first_line; (yyval.equals_)->char_number = (yyloc).first_column;  }
#line 5982 "Parser.c"
    break;

  case 305: /* IF_STATEMENT: IF_CLAUSE STATEMENT  */
#line 1037 "HAL_S.y"
                                   { (yyval.if_statement_) = make_AAifStatement((yyvsp[-1].if_clause_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 5988 "Parser.c"
    break;

  case 306: /* IF_STATEMENT: TRUE_PART STATEMENT  */
#line 1038 "HAL_S.y"
                        { (yyval.if_statement_) = make_ABifThenElseStatement((yyvsp[-1].true_part_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 5994 "Parser.c"
    break;

  case 307: /* IF_CLAUSE: IF RELATIONAL_EXP THEN  */
#line 1040 "HAL_S.y"
                                   { (yyval.if_clause_) = make_AAif_clause((yyvsp[-2].if_), (yyvsp[-1].relational_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 6000 "Parser.c"
    break;

  case 308: /* IF_CLAUSE: IF BIT_EXP THEN  */
#line 1041 "HAL_S.y"
                    { (yyval.if_clause_) = make_ABif_clause((yyvsp[-2].if_), (yyvsp[-1].bit_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 6006 "Parser.c"
    break;

  case 309: /* TRUE_PART: IF_CLAUSE BASIC_STATEMENT _SYMB_74  */
#line 1043 "HAL_S.y"
                                               { (yyval.true_part_) = make_AAtrue_part((yyvsp[-2].if_clause_), (yyvsp[-1].basic_statement_)); (yyval.true_part_)->line_number = (yyloc).first_line; (yyval.true_part_)->char_number = (yyloc).first_column;  }
#line 6012 "Parser.c"
    break;

  case 310: /* IF: _SYMB_93  */
#line 1045 "HAL_S.y"
              { (yyval.if_) = make_AAif(); (yyval.if_)->line_number = (yyloc).first_line; (yyval.if_)->char_number = (yyloc).first_column;  }
#line 6018 "Parser.c"
    break;

  case 311: /* THEN: _SYMB_168  */
#line 1047 "HAL_S.y"
                 { (yyval.then_) = make_AAthen(); (yyval.then_)->line_number = (yyloc).first_line; (yyval.then_)->char_number = (yyloc).first_column;  }
#line 6024 "Parser.c"
    break;

  case 312: /* RELATIONAL_EXP: RELATIONAL_FACTOR  */
#line 1049 "HAL_S.y"
                                   { (yyval.relational_exp_) = make_AArelational_exp((yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 6030 "Parser.c"
    break;

  case 313: /* RELATIONAL_EXP: RELATIONAL_EXP OR RELATIONAL_FACTOR  */
#line 1050 "HAL_S.y"
                                        { (yyval.relational_exp_) = make_ABrelational_exp((yyvsp[-2].relational_exp_), (yyvsp[-1].or_), (yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 6036 "Parser.c"
    break;

  case 314: /* RELATIONAL_FACTOR: REL_PRIM  */
#line 1052 "HAL_S.y"
                             { (yyval.relational_factor_) = make_AArelational_factor((yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 6042 "Parser.c"
    break;

  case 315: /* RELATIONAL_FACTOR: RELATIONAL_FACTOR AND REL_PRIM  */
#line 1053 "HAL_S.y"
                                   { (yyval.relational_factor_) = make_ABrelational_factor((yyvsp[-2].relational_factor_), (yyvsp[-1].and_), (yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 6048 "Parser.c"
    break;

  case 316: /* REL_PRIM: _SYMB_2 RELATIONAL_EXP _SYMB_1  */
#line 1055 "HAL_S.y"
                                          { (yyval.rel_prim_) = make_AArel_prim((yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6054 "Parser.c"
    break;

  case 317: /* REL_PRIM: NOT _SYMB_2 RELATIONAL_EXP _SYMB_1  */
#line 1056 "HAL_S.y"
                                       { (yyval.rel_prim_) = make_ABrel_prim((yyvsp[-3].not_), (yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6060 "Parser.c"
    break;

  case 318: /* REL_PRIM: COMPARISON  */
#line 1057 "HAL_S.y"
               { (yyval.rel_prim_) = make_ACrel_prim((yyvsp[0].comparison_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6066 "Parser.c"
    break;

  case 319: /* COMPARISON: ARITH_EXP RELATIONAL_OP ARITH_EXP  */
#line 1059 "HAL_S.y"
                                               { (yyval.comparison_) = make_AAcomparison((yyvsp[-2].arith_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6072 "Parser.c"
    break;

  case 320: /* COMPARISON: CHAR_EXP RELATIONAL_OP CHAR_EXP  */
#line 1060 "HAL_S.y"
                                    { (yyval.comparison_) = make_ABcomparison((yyvsp[-2].char_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6078 "Parser.c"
    break;

  case 321: /* COMPARISON: BIT_CAT RELATIONAL_OP BIT_CAT  */
#line 1061 "HAL_S.y"
                                  { (yyval.comparison_) = make_ACcomparison((yyvsp[-2].bit_cat_), (yyvsp[-1].relational_op_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6084 "Parser.c"
    break;

  case 322: /* COMPARISON: STRUCTURE_EXP RELATIONAL_OP STRUCTURE_EXP  */
#line 1062 "HAL_S.y"
                                              { (yyval.comparison_) = make_ADcomparison((yyvsp[-2].structure_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6090 "Parser.c"
    break;

  case 323: /* COMPARISON: NAME_EXP RELATIONAL_OP NAME_EXP  */
#line 1063 "HAL_S.y"
                                    { (yyval.comparison_) = make_AEcomparison((yyvsp[-2].name_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6096 "Parser.c"
    break;

  case 324: /* RELATIONAL_OP: EQUALS  */
#line 1065 "HAL_S.y"
                       { (yyval.relational_op_) = make_AArelationalOpEQ((yyvsp[0].equals_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6102 "Parser.c"
    break;

  case 325: /* RELATIONAL_OP: NOT EQUALS  */
#line 1066 "HAL_S.y"
               { (yyval.relational_op_) = make_ABrelationalOpNEQ((yyvsp[-1].not_), (yyvsp[0].equals_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6108 "Parser.c"
    break;

  case 326: /* RELATIONAL_OP: _SYMB_24  */
#line 1067 "HAL_S.y"
             { (yyval.relational_op_) = make_ACrelationalOpLT(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6114 "Parser.c"
    break;

  case 327: /* RELATIONAL_OP: _SYMB_26  */
#line 1068 "HAL_S.y"
             { (yyval.relational_op_) = make_ADrelationalOpGT(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6120 "Parser.c"
    break;

  case 328: /* RELATIONAL_OP: _SYMB_27  */
#line 1069 "HAL_S.y"
             { (yyval.relational_op_) = make_AErelationalOpLE(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6126 "Parser.c"
    break;

  case 329: /* RELATIONAL_OP: _SYMB_28  */
#line 1070 "HAL_S.y"
             { (yyval.relational_op_) = make_AFrelationalOpGE(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6132 "Parser.c"
    break;

  case 330: /* RELATIONAL_OP: NOT _SYMB_24  */
#line 1071 "HAL_S.y"
                 { (yyval.relational_op_) = make_AGrelationalOpNLT((yyvsp[-1].not_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6138 "Parser.c"
    break;

  case 331: /* RELATIONAL_OP: NOT _SYMB_26  */
#line 1072 "HAL_S.y"
                 { (yyval.relational_op_) = make_AHrelationalOpNGT((yyvsp[-1].not_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6144 "Parser.c"
    break;

  case 332: /* STATEMENT: BASIC_STATEMENT  */
#line 1074 "HAL_S.y"
                            { (yyval.statement_) = make_AAstatement((yyvsp[0].basic_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6150 "Parser.c"
    break;

  case 333: /* STATEMENT: OTHER_STATEMENT  */
#line 1075 "HAL_S.y"
                    { (yyval.statement_) = make_ABstatement((yyvsp[0].other_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6156 "Parser.c"
    break;

  case 334: /* STATEMENT: INLINE_DEFINITION  */
#line 1076 "HAL_S.y"
                      { (yyval.statement_) = make_AZstatement((yyvsp[0].inline_definition_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6162 "Parser.c"
    break;

  case 335: /* BASIC_STATEMENT: ASSIGNMENT _SYMB_16  */
#line 1078 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_ABbasicStatementAssignment((yyvsp[-1].assignment_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6168 "Parser.c"
    break;

  case 336: /* BASIC_STATEMENT: LABEL_DEFINITION BASIC_STATEMENT  */
#line 1079 "HAL_S.y"
                                     { (yyval.basic_statement_) = make_AAbasic_statement((yyvsp[-1].label_definition_), (yyvsp[0].basic_statement_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6174 "Parser.c"
    break;

  case 337: /* BASIC_STATEMENT: _SYMB_83 _SYMB_16  */
#line 1080 "HAL_S.y"
                      { (yyval.basic_statement_) = make_ACbasicStatementExit(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6180 "Parser.c"
    break;

  case 338: /* BASIC_STATEMENT: _SYMB_83 LABEL _SYMB_16  */
#line 1081 "HAL_S.y"
                            { (yyval.basic_statement_) = make_ADbasicStatementExit((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6186 "Parser.c"
    break;

  case 339: /* BASIC_STATEMENT: _SYMB_134 _SYMB_16  */
#line 1082 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AEbasicStatementRepeat(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6192 "Parser.c"
    break;

  case 340: /* BASIC_STATEMENT: _SYMB_134 LABEL _SYMB_16  */
#line 1083 "HAL_S.y"
                             { (yyval.basic_statement_) = make_AFbasicStatementRepeat((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6198 "Parser.c"
    break;

  case 341: /* BASIC_STATEMENT: _SYMB_91 _SYMB_169 LABEL _SYMB_16  */
#line 1084 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AGbasicStatementGoTo((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6204 "Parser.c"
    break;

  case 342: /* BASIC_STATEMENT: _SYMB_16  */
#line 1085 "HAL_S.y"
             { (yyval.basic_statement_) = make_AHbasicStatementEmpty(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6210 "Parser.c"
    break;

  case 343: /* BASIC_STATEMENT: CALL_KEY _SYMB_16  */
#line 1086 "HAL_S.y"
                      { (yyval.basic_statement_) = make_AIbasicStatementCall((yyvsp[-1].call_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6216 "Parser.c"
    break;

  case 344: /* BASIC_STATEMENT: CALL_KEY _SYMB_2 CALL_LIST _SYMB_1 _SYMB_16  */
#line 1087 "HAL_S.y"
                                                { (yyval.basic_statement_) = make_AJbasicStatementCall((yyvsp[-4].call_key_), (yyvsp[-2].call_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6222 "Parser.c"
    break;

  case 345: /* BASIC_STATEMENT: CALL_KEY ASSIGN _SYMB_2 CALL_ASSIGN_LIST _SYMB_1 _SYMB_16  */
#line 1088 "HAL_S.y"
                                                              { (yyval.basic_statement_) = make_AKbasicStatementCall((yyvsp[-5].call_key_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6228 "Parser.c"
    break;

  case 346: /* BASIC_STATEMENT: CALL_KEY _SYMB_2 CALL_LIST _SYMB_1 ASSIGN _SYMB_2 CALL_ASSIGN_LIST _SYMB_1 _SYMB_16  */
#line 1089 "HAL_S.y"
                                                                                        { (yyval.basic_statement_) = make_ALbasicStatementCall((yyvsp[-8].call_key_), (yyvsp[-6].call_list_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6234 "Parser.c"
    break;

  case 347: /* BASIC_STATEMENT: _SYMB_137 _SYMB_16  */
#line 1090 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AMbasicStatementReturn(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6240 "Parser.c"
    break;

  case 348: /* BASIC_STATEMENT: _SYMB_137 EXPRESSION _SYMB_16  */
#line 1091 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_ANbasicStatementReturn((yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6246 "Parser.c"
    break;

  case 349: /* BASIC_STATEMENT: DO_GROUP_HEAD ENDING _SYMB_16  */
#line 1092 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_AObasicStatementDo((yyvsp[-2].do_group_head_), (yyvsp[-1].ending_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6252 "Parser.c"
    break;

  case 350: /* BASIC_STATEMENT: READ_KEY _SYMB_16  */
#line 1093 "HAL_S.y"
                      { (yyval.basic_statement_) = make_APbasicStatementReadKey((yyvsp[-1].read_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6258 "Parser.c"
    break;

  case 351: /* BASIC_STATEMENT: READ_PHRASE _SYMB_16  */
#line 1094 "HAL_S.y"
                         { (yyval.basic_statement_) = make_AQbasicStatementReadPhrase((yyvsp[-1].read_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6264 "Parser.c"
    break;

  case 352: /* BASIC_STATEMENT: WRITE_KEY _SYMB_16  */
#line 1095 "HAL_S.y"
                       { (yyval.basic_statement_) = make_ARbasicStatementWriteKey((yyvsp[-1].write_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6270 "Parser.c"
    break;

  case 353: /* BASIC_STATEMENT: WRITE_PHRASE _SYMB_16  */
#line 1096 "HAL_S.y"
                          { (yyval.basic_statement_) = make_ASbasicStatementWritePhrase((yyvsp[-1].write_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6276 "Parser.c"
    break;

  case 354: /* BASIC_STATEMENT: FILE_EXP EQUALS EXPRESSION _SYMB_16  */
#line 1097 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_ATbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6282 "Parser.c"
    break;

  case 355: /* BASIC_STATEMENT: VARIABLE EQUALS FILE_EXP _SYMB_16  */
#line 1098 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AUbasicStatementFileExp((yyvsp[-3].variable_), (yyvsp[-2].equals_), (yyvsp[-1].file_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6288 "Parser.c"
    break;

  case 356: /* BASIC_STATEMENT: FILE_EXP EQUALS QUAL_STRUCT _SYMB_16  */
#line 1099 "HAL_S.y"
                                         { (yyval.basic_statement_) = make_AVbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].qual_struct_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6294 "Parser.c"
    break;

  case 357: /* BASIC_STATEMENT: WAIT_KEY _SYMB_89 _SYMB_69 _SYMB_16  */
#line 1100 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_AVbasicStatementWait((yyvsp[-3].wait_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6300 "Parser.c"
    break;

  case 358: /* BASIC_STATEMENT: WAIT_KEY ARITH_EXP _SYMB_16  */
#line 1101 "HAL_S.y"
                                { (yyval.basic_statement_) = make_AWbasicStatementWait((yyvsp[-2].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6306 "Parser.c"
    break;

  case 359: /* BASIC_STATEMENT: WAIT_KEY _SYMB_176 ARITH_EXP _SYMB_16  */
#line 1102 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_AXbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6312 "Parser.c"
    break;

  case 360: /* BASIC_STATEMENT: WAIT_KEY _SYMB_89 BIT_EXP _SYMB_16  */
#line 1103 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_AYbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].bit_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6318 "Parser.c"
    break;

  case 361: /* BASIC_STATEMENT: TERMINATOR _SYMB_16  */
#line 1104 "HAL_S.y"
                        { (yyval.basic_statement_) = make_AZbasicStatementTerminator((yyvsp[-1].terminator_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6324 "Parser.c"
    break;

  case 362: /* BASIC_STATEMENT: TERMINATOR TERMINATE_LIST _SYMB_16  */
#line 1105 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_BAbasicStatementTerminator((yyvsp[-2].terminator_), (yyvsp[-1].terminate_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6330 "Parser.c"
    break;

  case 363: /* BASIC_STATEMENT: _SYMB_177 _SYMB_123 _SYMB_169 ARITH_EXP _SYMB_16  */
#line 1106 "HAL_S.y"
                                                     { (yyval.basic_statement_) = make_BBbasicStatementUpdate((yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6336 "Parser.c"
    break;

  case 364: /* BASIC_STATEMENT: _SYMB_177 _SYMB_123 LABEL_VAR _SYMB_169 ARITH_EXP _SYMB_16  */
#line 1107 "HAL_S.y"
                                                               { (yyval.basic_statement_) = make_BCbasicStatementUpdate((yyvsp[-3].label_var_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6342 "Parser.c"
    break;

  case 365: /* BASIC_STATEMENT: SCHEDULE_PHRASE _SYMB_16  */
#line 1108 "HAL_S.y"
                             { (yyval.basic_statement_) = make_BDbasicStatementSchedule((yyvsp[-1].schedule_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6348 "Parser.c"
    break;

  case 366: /* BASIC_STATEMENT: SCHEDULE_PHRASE SCHEDULE_CONTROL _SYMB_16  */
#line 1109 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BEbasicStatementSchedule((yyvsp[-2].schedule_phrase_), (yyvsp[-1].schedule_control_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6354 "Parser.c"
    break;

  case 367: /* BASIC_STATEMENT: SIGNAL_CLAUSE _SYMB_16  */
#line 1110 "HAL_S.y"
                           { (yyval.basic_statement_) = make_BFbasicStatementSignal((yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6360 "Parser.c"
    break;

  case 368: /* BASIC_STATEMENT: _SYMB_144 _SYMB_79 SUBSCRIPT _SYMB_16  */
#line 1111 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BGbasicStatementSend((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6366 "Parser.c"
    break;

  case 369: /* BASIC_STATEMENT: _SYMB_144 _SYMB_79 _SYMB_16  */
#line 1112 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BHbasicStatementSend(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6372 "Parser.c"
    break;

  case 370: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_16  */
#line 1113 "HAL_S.y"
                       { (yyval.basic_statement_) = make_BHbasicStatementOn((yyvsp[-1].on_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6378 "Parser.c"
    break;

  case 371: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_35 SIGNAL_CLAUSE _SYMB_16  */
#line 1114 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BIbasicStatementOnAndSignal((yyvsp[-3].on_clause_), (yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6384 "Parser.c"
    break;

  case 372: /* BASIC_STATEMENT: _SYMB_118 _SYMB_79 SUBSCRIPT _SYMB_16  */
#line 1115 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BJbasicStatementOff((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6390 "Parser.c"
    break;

  case 373: /* BASIC_STATEMENT: _SYMB_118 _SYMB_79 _SYMB_16  */
#line 1116 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementOff(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6396 "Parser.c"
    break;

  case 374: /* BASIC_STATEMENT: PERCENT_MACRO_NAME _SYMB_16  */
#line 1117 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementPercentMacro((yyvsp[-1].percent_macro_name_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6402 "Parser.c"
    break;

  case 375: /* BASIC_STATEMENT: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_1 _SYMB_16  */
#line 1118 "HAL_S.y"
                                                          { (yyval.basic_statement_) = make_BLbasicStatementPercentMacro((yyvsp[-3].percent_macro_head_), (yyvsp[-2].percent_macro_arg_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6408 "Parser.c"
    break;

  case 376: /* OTHER_STATEMENT: IF_STATEMENT  */
#line 1120 "HAL_S.y"
                               { (yyval.other_statement_) = make_ABotherStatementIf((yyvsp[0].if_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6414 "Parser.c"
    break;

  case 377: /* OTHER_STATEMENT: ON_PHRASE STATEMENT  */
#line 1121 "HAL_S.y"
                        { (yyval.other_statement_) = make_AAotherStatementOn((yyvsp[-1].on_phrase_), (yyvsp[0].statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6420 "Parser.c"
    break;

  case 378: /* OTHER_STATEMENT: LABEL_DEFINITION OTHER_STATEMENT  */
#line 1122 "HAL_S.y"
                                     { (yyval.other_statement_) = make_ACother_statement((yyvsp[-1].label_definition_), (yyvsp[0].other_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6426 "Parser.c"
    break;

  case 379: /* ANY_STATEMENT: STATEMENT  */
#line 1124 "HAL_S.y"
                          { (yyval.any_statement_) = make_AAany_statement((yyvsp[0].statement_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6432 "Parser.c"
    break;

  case 380: /* ANY_STATEMENT: BLOCK_DEFINITION  */
#line 1125 "HAL_S.y"
                     { (yyval.any_statement_) = make_ABany_statement((yyvsp[0].block_definition_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6438 "Parser.c"
    break;

  case 381: /* ON_PHRASE: _SYMB_119 _SYMB_79 SUBSCRIPT  */
#line 1127 "HAL_S.y"
                                         { (yyval.on_phrase_) = make_AAon_phrase((yyvsp[0].subscript_)); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6444 "Parser.c"
    break;

  case 382: /* ON_PHRASE: _SYMB_119 _SYMB_79  */
#line 1128 "HAL_S.y"
                       { (yyval.on_phrase_) = make_ACon_phrase(); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6450 "Parser.c"
    break;

  case 383: /* ON_CLAUSE: _SYMB_119 _SYMB_79 SUBSCRIPT _SYMB_161  */
#line 1130 "HAL_S.y"
                                                   { (yyval.on_clause_) = make_AAon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6456 "Parser.c"
    break;

  case 384: /* ON_CLAUSE: _SYMB_119 _SYMB_79 SUBSCRIPT _SYMB_94  */
#line 1131 "HAL_S.y"
                                          { (yyval.on_clause_) = make_ABon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6462 "Parser.c"
    break;

  case 385: /* ON_CLAUSE: _SYMB_119 _SYMB_79 _SYMB_161  */
#line 1132 "HAL_S.y"
                                 { (yyval.on_clause_) = make_ADon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6468 "Parser.c"
    break;

  case 386: /* ON_CLAUSE: _SYMB_119 _SYMB_79 _SYMB_94  */
#line 1133 "HAL_S.y"
                                { (yyval.on_clause_) = make_AEon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6474 "Parser.c"
    break;

  case 387: /* LABEL_DEFINITION: LABEL _SYMB_17  */
#line 1135 "HAL_S.y"
                                  { (yyval.label_definition_) = make_AAlabel_definition((yyvsp[-1].label_)); (yyval.label_definition_)->line_number = (yyloc).first_line; (yyval.label_definition_)->char_number = (yyloc).first_column;  }
#line 6480 "Parser.c"
    break;

  case 388: /* CALL_KEY: _SYMB_51 LABEL_VAR  */
#line 1137 "HAL_S.y"
                              { (yyval.call_key_) = make_AAcall_key((yyvsp[0].label_var_)); (yyval.call_key_)->line_number = (yyloc).first_line; (yyval.call_key_)->char_number = (yyloc).first_column;  }
#line 6486 "Parser.c"
    break;

  case 389: /* ASSIGN: _SYMB_44  */
#line 1139 "HAL_S.y"
                  { (yyval.assign_) = make_AAassign(); (yyval.assign_)->line_number = (yyloc).first_line; (yyval.assign_)->char_number = (yyloc).first_column;  }
#line 6492 "Parser.c"
    break;

  case 390: /* CALL_ASSIGN_LIST: VARIABLE  */
#line 1141 "HAL_S.y"
                            { (yyval.call_assign_list_) = make_AAcall_assign_list((yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6498 "Parser.c"
    break;

  case 391: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_0 VARIABLE  */
#line 1142 "HAL_S.y"
                                      { (yyval.call_assign_list_) = make_ABcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6504 "Parser.c"
    break;

  case 392: /* CALL_ASSIGN_LIST: QUAL_STRUCT  */
#line 1143 "HAL_S.y"
                { (yyval.call_assign_list_) = make_ACcall_assign_list((yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6510 "Parser.c"
    break;

  case 393: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_0 QUAL_STRUCT  */
#line 1144 "HAL_S.y"
                                         { (yyval.call_assign_list_) = make_ADcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6516 "Parser.c"
    break;

  case 394: /* DO_GROUP_HEAD: _SYMB_72 _SYMB_16  */
#line 1146 "HAL_S.y"
                                  { (yyval.do_group_head_) = make_AAdoGroupHead(); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6522 "Parser.c"
    break;

  case 395: /* DO_GROUP_HEAD: _SYMB_72 FOR_LIST _SYMB_16  */
#line 1147 "HAL_S.y"
                               { (yyval.do_group_head_) = make_ABdoGroupHeadFor((yyvsp[-1].for_list_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6528 "Parser.c"
    break;

  case 396: /* DO_GROUP_HEAD: _SYMB_72 FOR_LIST WHILE_CLAUSE _SYMB_16  */
#line 1148 "HAL_S.y"
                                            { (yyval.do_group_head_) = make_ACdoGroupHeadForWhile((yyvsp[-2].for_list_), (yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6534 "Parser.c"
    break;

  case 397: /* DO_GROUP_HEAD: _SYMB_72 WHILE_CLAUSE _SYMB_16  */
#line 1149 "HAL_S.y"
                                   { (yyval.do_group_head_) = make_ADdoGroupHeadWhile((yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6540 "Parser.c"
    break;

  case 398: /* DO_GROUP_HEAD: _SYMB_72 _SYMB_53 ARITH_EXP _SYMB_16  */
#line 1150 "HAL_S.y"
                                         { (yyval.do_group_head_) = make_AEdoGroupHeadCase((yyvsp[-1].arith_exp_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6546 "Parser.c"
    break;

  case 399: /* DO_GROUP_HEAD: CASE_ELSE STATEMENT  */
#line 1151 "HAL_S.y"
                        { (yyval.do_group_head_) = make_AFdoGroupHeadCaseElse((yyvsp[-1].case_else_), (yyvsp[0].statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6552 "Parser.c"
    break;

  case 400: /* DO_GROUP_HEAD: DO_GROUP_HEAD ANY_STATEMENT  */
#line 1152 "HAL_S.y"
                                { (yyval.do_group_head_) = make_AGdoGroupHeadStatement((yyvsp[-1].do_group_head_), (yyvsp[0].any_statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6558 "Parser.c"
    break;

  case 401: /* DO_GROUP_HEAD: DO_GROUP_HEAD TEMPORARY_STMT  */
#line 1153 "HAL_S.y"
                                 { (yyval.do_group_head_) = make_AHdoGroupHeadTemporaryStatement((yyvsp[-1].do_group_head_), (yyvsp[0].temporary_stmt_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6564 "Parser.c"
    break;

  case 402: /* ENDING: _SYMB_75  */
#line 1155 "HAL_S.y"
                  { (yyval.ending_) = make_AAending(); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6570 "Parser.c"
    break;

  case 403: /* ENDING: _SYMB_75 LABEL  */
#line 1156 "HAL_S.y"
                   { (yyval.ending_) = make_ABending((yyvsp[0].label_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6576 "Parser.c"
    break;

  case 404: /* ENDING: LABEL_DEFINITION ENDING  */
#line 1157 "HAL_S.y"
                            { (yyval.ending_) = make_ACending((yyvsp[-1].label_definition_), (yyvsp[0].ending_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6582 "Parser.c"
    break;

  case 405: /* READ_KEY: _SYMB_129 _SYMB_2 NUMBER _SYMB_1  */
#line 1159 "HAL_S.y"
                                            { (yyval.read_key_) = make_AAread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 6588 "Parser.c"
    break;

  case 406: /* READ_KEY: _SYMB_130 _SYMB_2 NUMBER _SYMB_1  */
#line 1160 "HAL_S.y"
                                     { (yyval.read_key_) = make_ABread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 6594 "Parser.c"
    break;

  case 407: /* WRITE_KEY: _SYMB_181 _SYMB_2 NUMBER _SYMB_1  */
#line 1162 "HAL_S.y"
                                             { (yyval.write_key_) = make_AAwrite_key((yyvsp[-1].number_)); (yyval.write_key_)->line_number = (yyloc).first_line; (yyval.write_key_)->char_number = (yyloc).first_column;  }
#line 6600 "Parser.c"
    break;

  case 408: /* READ_PHRASE: READ_KEY READ_ARG  */
#line 1164 "HAL_S.y"
                                { (yyval.read_phrase_) = make_AAread_phrase((yyvsp[-1].read_key_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 6606 "Parser.c"
    break;

  case 409: /* READ_PHRASE: READ_PHRASE _SYMB_0 READ_ARG  */
#line 1165 "HAL_S.y"
                                 { (yyval.read_phrase_) = make_ABread_phrase((yyvsp[-2].read_phrase_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 6612 "Parser.c"
    break;

  case 410: /* WRITE_PHRASE: WRITE_KEY WRITE_ARG  */
#line 1167 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_AAwrite_phrase((yyvsp[-1].write_key_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 6618 "Parser.c"
    break;

  case 411: /* WRITE_PHRASE: WRITE_PHRASE _SYMB_0 WRITE_ARG  */
#line 1168 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_ABwrite_phrase((yyvsp[-2].write_phrase_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 6624 "Parser.c"
    break;

  case 412: /* READ_ARG: VARIABLE  */
#line 1170 "HAL_S.y"
                    { (yyval.read_arg_) = make_AAread_arg((yyvsp[0].variable_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 6630 "Parser.c"
    break;

  case 413: /* READ_ARG: IO_CONTROL  */
#line 1171 "HAL_S.y"
               { (yyval.read_arg_) = make_ABread_arg((yyvsp[0].io_control_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 6636 "Parser.c"
    break;

  case 414: /* WRITE_ARG: EXPRESSION  */
#line 1173 "HAL_S.y"
                       { (yyval.write_arg_) = make_AAwrite_arg((yyvsp[0].expression_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6642 "Parser.c"
    break;

  case 415: /* WRITE_ARG: IO_CONTROL  */
#line 1174 "HAL_S.y"
               { (yyval.write_arg_) = make_ABwrite_arg((yyvsp[0].io_control_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6648 "Parser.c"
    break;

  case 416: /* WRITE_ARG: _SYMB_187  */
#line 1175 "HAL_S.y"
              { (yyval.write_arg_) = make_ACwrite_arg((yyvsp[0].string_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6654 "Parser.c"
    break;

  case 417: /* FILE_EXP: FILE_HEAD _SYMB_0 ARITH_EXP _SYMB_1  */
#line 1177 "HAL_S.y"
                                               { (yyval.file_exp_) = make_AAfile_exp((yyvsp[-3].file_head_), (yyvsp[-1].arith_exp_)); (yyval.file_exp_)->line_number = (yyloc).first_line; (yyval.file_exp_)->char_number = (yyloc).first_column;  }
#line 6660 "Parser.c"
    break;

  case 418: /* FILE_HEAD: _SYMB_87 _SYMB_2 NUMBER  */
#line 1179 "HAL_S.y"
                                    { (yyval.file_head_) = make_AAfile_head((yyvsp[0].number_)); (yyval.file_head_)->line_number = (yyloc).first_line; (yyval.file_head_)->char_number = (yyloc).first_column;  }
#line 6666 "Parser.c"
    break;

  case 419: /* IO_CONTROL: _SYMB_155 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1181 "HAL_S.y"
                                                 { (yyval.io_control_) = make_AAioControlSkip((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6672 "Parser.c"
    break;

  case 420: /* IO_CONTROL: _SYMB_162 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1182 "HAL_S.y"
                                        { (yyval.io_control_) = make_ABioControlTab((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6678 "Parser.c"
    break;

  case 421: /* IO_CONTROL: _SYMB_60 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1183 "HAL_S.y"
                                       { (yyval.io_control_) = make_ACioControlColumn((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6684 "Parser.c"
    break;

  case 422: /* IO_CONTROL: _SYMB_102 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1184 "HAL_S.y"
                                        { (yyval.io_control_) = make_ADioControlLine((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6690 "Parser.c"
    break;

  case 423: /* IO_CONTROL: _SYMB_121 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1185 "HAL_S.y"
                                        { (yyval.io_control_) = make_AEioControlPage((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6696 "Parser.c"
    break;

  case 424: /* WAIT_KEY: _SYMB_179  */
#line 1187 "HAL_S.y"
                     { (yyval.wait_key_) = make_AAwait_key(); (yyval.wait_key_)->line_number = (yyloc).first_line; (yyval.wait_key_)->char_number = (yyloc).first_column;  }
#line 6702 "Parser.c"
    break;

  case 425: /* TERMINATOR: _SYMB_167  */
#line 1189 "HAL_S.y"
                       { (yyval.terminator_) = make_AAterminatorTerminate(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 6708 "Parser.c"
    break;

  case 426: /* TERMINATOR: _SYMB_52  */
#line 1190 "HAL_S.y"
             { (yyval.terminator_) = make_ABterminatorCancel(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 6714 "Parser.c"
    break;

  case 427: /* TERMINATE_LIST: LABEL_VAR  */
#line 1192 "HAL_S.y"
                           { (yyval.terminate_list_) = make_AAterminate_list((yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 6720 "Parser.c"
    break;

  case 428: /* TERMINATE_LIST: TERMINATE_LIST _SYMB_0 LABEL_VAR  */
#line 1193 "HAL_S.y"
                                     { (yyval.terminate_list_) = make_ABterminate_list((yyvsp[-2].terminate_list_), (yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 6726 "Parser.c"
    break;

  case 429: /* SCHEDULE_HEAD: _SYMB_143 LABEL_VAR  */
#line 1195 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_AAscheduleHeadLabel((yyvsp[0].label_var_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6732 "Parser.c"
    break;

  case 430: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_45 ARITH_EXP  */
#line 1196 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ABscheduleHeadAt((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6738 "Parser.c"
    break;

  case 431: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_95 ARITH_EXP  */
#line 1197 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ACscheduleHeadIn((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6744 "Parser.c"
    break;

  case 432: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_119 BIT_EXP  */
#line 1198 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_ADscheduleHeadOn((yyvsp[-2].schedule_head_), (yyvsp[0].bit_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6750 "Parser.c"
    break;

  case 433: /* SCHEDULE_PHRASE: SCHEDULE_HEAD  */
#line 1200 "HAL_S.y"
                                { (yyval.schedule_phrase_) = make_AAschedule_phrase((yyvsp[0].schedule_head_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6756 "Parser.c"
    break;

  case 434: /* SCHEDULE_PHRASE: SCHEDULE_HEAD _SYMB_123 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1201 "HAL_S.y"
                                                      { (yyval.schedule_phrase_) = make_ABschedule_phrase((yyvsp[-4].schedule_head_), (yyvsp[-1].arith_exp_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6762 "Parser.c"
    break;

  case 435: /* SCHEDULE_PHRASE: SCHEDULE_PHRASE _SYMB_69  */
#line 1202 "HAL_S.y"
                             { (yyval.schedule_phrase_) = make_ACschedule_phrase((yyvsp[-1].schedule_phrase_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6768 "Parser.c"
    break;

  case 436: /* SCHEDULE_CONTROL: STOPPING  */
#line 1204 "HAL_S.y"
                            { (yyval.schedule_control_) = make_AAschedule_control((yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6774 "Parser.c"
    break;

  case 437: /* SCHEDULE_CONTROL: TIMING  */
#line 1205 "HAL_S.y"
           { (yyval.schedule_control_) = make_ABschedule_control((yyvsp[0].timing_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6780 "Parser.c"
    break;

  case 438: /* SCHEDULE_CONTROL: TIMING STOPPING  */
#line 1206 "HAL_S.y"
                    { (yyval.schedule_control_) = make_ACschedule_control((yyvsp[-1].timing_), (yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6786 "Parser.c"
    break;

  case 439: /* TIMING: REPEAT _SYMB_81 ARITH_EXP  */
#line 1208 "HAL_S.y"
                                   { (yyval.timing_) = make_AAtimingEvery((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6792 "Parser.c"
    break;

  case 440: /* TIMING: REPEAT _SYMB_33 ARITH_EXP  */
#line 1209 "HAL_S.y"
                              { (yyval.timing_) = make_ABtimingAfter((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6798 "Parser.c"
    break;

  case 441: /* TIMING: REPEAT  */
#line 1210 "HAL_S.y"
           { (yyval.timing_) = make_ACtiming((yyvsp[0].repeat_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6804 "Parser.c"
    break;

  case 442: /* REPEAT: _SYMB_0 _SYMB_134  */
#line 1212 "HAL_S.y"
                           { (yyval.repeat_) = make_AArepeat(); (yyval.repeat_)->line_number = (yyloc).first_line; (yyval.repeat_)->char_number = (yyloc).first_column;  }
#line 6810 "Parser.c"
    break;

  case 443: /* STOPPING: WHILE_KEY ARITH_EXP  */
#line 1214 "HAL_S.y"
                               { (yyval.stopping_) = make_AAstopping((yyvsp[-1].while_key_), (yyvsp[0].arith_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 6816 "Parser.c"
    break;

  case 444: /* STOPPING: WHILE_KEY BIT_EXP  */
#line 1215 "HAL_S.y"
                      { (yyval.stopping_) = make_ABstopping((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 6822 "Parser.c"
    break;

  case 445: /* SIGNAL_CLAUSE: _SYMB_145 EVENT_VAR  */
#line 1217 "HAL_S.y"
                                    { (yyval.signal_clause_) = make_AAsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6828 "Parser.c"
    break;

  case 446: /* SIGNAL_CLAUSE: _SYMB_136 EVENT_VAR  */
#line 1218 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ABsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6834 "Parser.c"
    break;

  case 447: /* SIGNAL_CLAUSE: _SYMB_149 EVENT_VAR  */
#line 1219 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ACsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6840 "Parser.c"
    break;

  case 448: /* PERCENT_MACRO_NAME: _SYMB_29 IDENTIFIER  */
#line 1221 "HAL_S.y"
                                         { (yyval.percent_macro_name_) = make_FNpercent_macro_name((yyvsp[0].identifier_)); (yyval.percent_macro_name_)->line_number = (yyloc).first_line; (yyval.percent_macro_name_)->char_number = (yyloc).first_column;  }
#line 6846 "Parser.c"
    break;

  case 449: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_NAME _SYMB_2  */
#line 1223 "HAL_S.y"
                                                { (yyval.percent_macro_head_) = make_AApercent_macro_head((yyvsp[-1].percent_macro_name_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 6852 "Parser.c"
    break;

  case 450: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_0  */
#line 1224 "HAL_S.y"
                                                 { (yyval.percent_macro_head_) = make_ABpercent_macro_head((yyvsp[-2].percent_macro_head_), (yyvsp[-1].percent_macro_arg_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 6858 "Parser.c"
    break;

  case 451: /* PERCENT_MACRO_ARG: NAME_VAR  */
#line 1226 "HAL_S.y"
                             { (yyval.percent_macro_arg_) = make_AApercent_macro_arg((yyvsp[0].name_var_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 6864 "Parser.c"
    break;

  case 452: /* PERCENT_MACRO_ARG: CONSTANT  */
#line 1227 "HAL_S.y"
             { (yyval.percent_macro_arg_) = make_ABpercent_macro_arg((yyvsp[0].constant_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 6870 "Parser.c"
    break;

  case 453: /* CASE_ELSE: _SYMB_72 _SYMB_53 ARITH_EXP _SYMB_16 _SYMB_74  */
#line 1229 "HAL_S.y"
                                                          { (yyval.case_else_) = make_AAcase_else((yyvsp[-2].arith_exp_)); (yyval.case_else_)->line_number = (yyloc).first_line; (yyval.case_else_)->char_number = (yyloc).first_column;  }
#line 6876 "Parser.c"
    break;

  case 454: /* WHILE_KEY: _SYMB_180  */
#line 1231 "HAL_S.y"
                      { (yyval.while_key_) = make_AAwhileKeyWhile(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 6882 "Parser.c"
    break;

  case 455: /* WHILE_KEY: _SYMB_176  */
#line 1232 "HAL_S.y"
              { (yyval.while_key_) = make_ABwhileKeyUntil(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 6888 "Parser.c"
    break;

  case 456: /* WHILE_CLAUSE: WHILE_KEY BIT_EXP  */
#line 1234 "HAL_S.y"
                                 { (yyval.while_clause_) = make_AAwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 6894 "Parser.c"
    break;

  case 457: /* WHILE_CLAUSE: WHILE_KEY RELATIONAL_EXP  */
#line 1235 "HAL_S.y"
                             { (yyval.while_clause_) = make_ABwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].relational_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 6900 "Parser.c"
    break;

  case 458: /* FOR_LIST: FOR_KEY ARITH_EXP ITERATION_CONTROL  */
#line 1237 "HAL_S.y"
                                               { (yyval.for_list_) = make_AAfor_list((yyvsp[-2].for_key_), (yyvsp[-1].arith_exp_), (yyvsp[0].iteration_control_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 6906 "Parser.c"
    break;

  case 459: /* FOR_LIST: FOR_KEY ITERATION_BODY  */
#line 1238 "HAL_S.y"
                           { (yyval.for_list_) = make_ABfor_list((yyvsp[-1].for_key_), (yyvsp[0].iteration_body_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 6912 "Parser.c"
    break;

  case 460: /* ITERATION_BODY: ARITH_EXP  */
#line 1240 "HAL_S.y"
                           { (yyval.iteration_body_) = make_AAiteration_body((yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 6918 "Parser.c"
    break;

  case 461: /* ITERATION_BODY: ITERATION_BODY _SYMB_0 ARITH_EXP  */
#line 1241 "HAL_S.y"
                                     { (yyval.iteration_body_) = make_ABiteration_body((yyvsp[-2].iteration_body_), (yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 6924 "Parser.c"
    break;

  case 462: /* ITERATION_CONTROL: _SYMB_169 ARITH_EXP  */
#line 1243 "HAL_S.y"
                                        { (yyval.iteration_control_) = make_AAiteration_controlTo((yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 6930 "Parser.c"
    break;

  case 463: /* ITERATION_CONTROL: _SYMB_169 ARITH_EXP _SYMB_50 ARITH_EXP  */
#line 1244 "HAL_S.y"
                                           { (yyval.iteration_control_) = make_ABiteration_controlToBy((yyvsp[-2].arith_exp_), (yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 6936 "Parser.c"
    break;

  case 464: /* FOR_KEY: _SYMB_89 ARITH_VAR EQUALS  */
#line 1246 "HAL_S.y"
                                    { (yyval.for_key_) = make_AAforKey((yyvsp[-1].arith_var_), (yyvsp[0].equals_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 6942 "Parser.c"
    break;

  case 465: /* FOR_KEY: _SYMB_89 _SYMB_166 IDENTIFIER _SYMB_25  */
#line 1247 "HAL_S.y"
                                           { (yyval.for_key_) = make_ABforKeyTemporary((yyvsp[-1].identifier_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 6948 "Parser.c"
    break;

  case 466: /* TEMPORARY_STMT: _SYMB_166 DECLARE_BODY _SYMB_16  */
#line 1249 "HAL_S.y"
                                                 { (yyval.temporary_stmt_) = make_AAtemporary_stmt((yyvsp[-1].declare_body_)); (yyval.temporary_stmt_)->line_number = (yyloc).first_line; (yyval.temporary_stmt_)->char_number = (yyloc).first_column;  }
#line 6954 "Parser.c"
    break;

  case 467: /* CONSTANT: NUMBER  */
#line 1251 "HAL_S.y"
                  { (yyval.constant_) = make_AAconstant((yyvsp[0].number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6960 "Parser.c"
    break;

  case 468: /* CONSTANT: COMPOUND_NUMBER  */
#line 1252 "HAL_S.y"
                    { (yyval.constant_) = make_ABconstant((yyvsp[0].compound_number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6966 "Parser.c"
    break;

  case 469: /* CONSTANT: BIT_CONST  */
#line 1253 "HAL_S.y"
              { (yyval.constant_) = make_ACconstant((yyvsp[0].bit_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6972 "Parser.c"
    break;

  case 470: /* CONSTANT: CHAR_CONST  */
#line 1254 "HAL_S.y"
               { (yyval.constant_) = make_ADconstant((yyvsp[0].char_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6978 "Parser.c"
    break;

  case 471: /* ARRAY_HEAD: _SYMB_43 _SYMB_2  */
#line 1256 "HAL_S.y"
                              { (yyval.array_head_) = make_AAarray_head(); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 6984 "Parser.c"
    break;

  case 472: /* ARRAY_HEAD: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_0  */
#line 1257 "HAL_S.y"
                                           { (yyval.array_head_) = make_ABarray_head((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 6990 "Parser.c"
    break;

  case 473: /* MINOR_ATTR_LIST: MINOR_ATTRIBUTE  */
#line 1259 "HAL_S.y"
                                  { (yyval.minor_attr_list_) = make_AAminor_attr_list((yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 6996 "Parser.c"
    break;

  case 474: /* MINOR_ATTR_LIST: MINOR_ATTR_LIST MINOR_ATTRIBUTE  */
#line 1260 "HAL_S.y"
                                    { (yyval.minor_attr_list_) = make_ABminor_attr_list((yyvsp[-1].minor_attr_list_), (yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 7002 "Parser.c"
    break;

  case 475: /* MINOR_ATTRIBUTE: _SYMB_157  */
#line 1262 "HAL_S.y"
                            { (yyval.minor_attribute_) = make_AAminorAttributeStatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7008 "Parser.c"
    break;

  case 476: /* MINOR_ATTRIBUTE: _SYMB_46  */
#line 1263 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ABminorAttributeAutomatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7014 "Parser.c"
    break;

  case 477: /* MINOR_ATTRIBUTE: _SYMB_68  */
#line 1264 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ACminorAttributeDense(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7020 "Parser.c"
    break;

  case 478: /* MINOR_ATTRIBUTE: _SYMB_34  */
#line 1265 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ADminorAttributeAligned(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7026 "Parser.c"
    break;

  case 479: /* MINOR_ATTRIBUTE: _SYMB_32  */
#line 1266 "HAL_S.y"
             { (yyval.minor_attribute_) = make_AEminorAttributeAccess(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7032 "Parser.c"
    break;

  case 480: /* MINOR_ATTRIBUTE: _SYMB_104 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1267 "HAL_S.y"
                                                  { (yyval.minor_attribute_) = make_AFminorAttributeLock((yyvsp[-1].literal_exp_or_star_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7038 "Parser.c"
    break;

  case 481: /* MINOR_ATTRIBUTE: _SYMB_133  */
#line 1268 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AGminorAttributeRemote(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7044 "Parser.c"
    break;

  case 482: /* MINOR_ATTRIBUTE: _SYMB_138  */
#line 1269 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AHminorAttributeRigid(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7050 "Parser.c"
    break;

  case 483: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_1  */
#line 1270 "HAL_S.y"
                                                 { (yyval.minor_attribute_) = make_AIminorAttributeRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7056 "Parser.c"
    break;

  case 484: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD _SYMB_6 _SYMB_1  */
#line 1271 "HAL_S.y"
                                       { (yyval.minor_attribute_) = make_AJminorAttributeStar((yyvsp[-2].init_or_const_head_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7062 "Parser.c"
    break;

  case 485: /* MINOR_ATTRIBUTE: _SYMB_100  */
#line 1272 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AKminorAttributeLatched(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7068 "Parser.c"
    break;

  case 486: /* MINOR_ATTRIBUTE: _SYMB_113 _SYMB_2 LEVEL _SYMB_1  */
#line 1273 "HAL_S.y"
                                    { (yyval.minor_attribute_) = make_ALminorAttributeNonHal((yyvsp[-1].level_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7074 "Parser.c"
    break;

  case 487: /* INIT_OR_CONST_HEAD: _SYMB_97 _SYMB_2  */
#line 1275 "HAL_S.y"
                                      { (yyval.init_or_const_head_) = make_AAinit_or_const_headInitial(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7080 "Parser.c"
    break;

  case 488: /* INIT_OR_CONST_HEAD: _SYMB_62 _SYMB_2  */
#line 1276 "HAL_S.y"
                     { (yyval.init_or_const_head_) = make_ABinit_or_const_headConstant(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7086 "Parser.c"
    break;

  case 489: /* INIT_OR_CONST_HEAD: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_0  */
#line 1277 "HAL_S.y"
                                                 { (yyval.init_or_const_head_) = make_ACinit_or_const_headRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7092 "Parser.c"
    break;

  case 490: /* REPEATED_CONSTANT: EXPRESSION  */
#line 1279 "HAL_S.y"
                               { (yyval.repeated_constant_) = make_AArepeated_constant((yyvsp[0].expression_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7098 "Parser.c"
    break;

  case 491: /* REPEATED_CONSTANT: REPEAT_HEAD VARIABLE  */
#line 1280 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ABrepeated_constant((yyvsp[-1].repeat_head_), (yyvsp[0].variable_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7104 "Parser.c"
    break;

  case 492: /* REPEATED_CONSTANT: REPEAT_HEAD CONSTANT  */
#line 1281 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ACrepeated_constant((yyvsp[-1].repeat_head_), (yyvsp[0].constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7110 "Parser.c"
    break;

  case 493: /* REPEATED_CONSTANT: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_1  */
#line 1282 "HAL_S.y"
                                                 { (yyval.repeated_constant_) = make_ADrepeated_constant((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7116 "Parser.c"
    break;

  case 494: /* REPEATED_CONSTANT: REPEAT_HEAD  */
#line 1283 "HAL_S.y"
                { (yyval.repeated_constant_) = make_AErepeated_constant((yyvsp[0].repeat_head_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7122 "Parser.c"
    break;

  case 495: /* REPEAT_HEAD: ARITH_EXP _SYMB_9 SIMPLE_NUMBER  */
#line 1285 "HAL_S.y"
                                              { (yyval.repeat_head_) = make_AArepeat_head((yyvsp[-2].arith_exp_), (yyvsp[0].simple_number_)); (yyval.repeat_head_)->line_number = (yyloc).first_line; (yyval.repeat_head_)->char_number = (yyloc).first_column;  }
#line 7128 "Parser.c"
    break;

  case 496: /* NESTED_REPEAT_HEAD: REPEAT_HEAD _SYMB_2  */
#line 1287 "HAL_S.y"
                                         { (yyval.nested_repeat_head_) = make_AAnested_repeat_head((yyvsp[-1].repeat_head_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 7134 "Parser.c"
    break;

  case 497: /* NESTED_REPEAT_HEAD: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_0  */
#line 1288 "HAL_S.y"
                                                 { (yyval.nested_repeat_head_) = make_ABnested_repeat_head((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 7140 "Parser.c"
    break;

  case 498: /* DCL_LIST_COMMA: DECLARATION_LIST _SYMB_0  */
#line 1290 "HAL_S.y"
                                          { (yyval.dcl_list_comma_) = make_AAdcl_list_comma((yyvsp[-1].declaration_list_)); (yyval.dcl_list_comma_)->line_number = (yyloc).first_line; (yyval.dcl_list_comma_)->char_number = (yyloc).first_column;  }
#line 7146 "Parser.c"
    break;

  case 499: /* LITERAL_EXP_OR_STAR: ARITH_EXP  */
#line 1292 "HAL_S.y"
                                { (yyval.literal_exp_or_star_) = make_AAliteralExp((yyvsp[0].arith_exp_)); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7152 "Parser.c"
    break;

  case 500: /* LITERAL_EXP_OR_STAR: _SYMB_6  */
#line 1293 "HAL_S.y"
            { (yyval.literal_exp_or_star_) = make_ABliteralStar(); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7158 "Parser.c"
    break;

  case 501: /* TYPE_SPEC: STRUCT_SPEC  */
#line 1295 "HAL_S.y"
                        { (yyval.type_spec_) = make_AAtypeSpecStruct((yyvsp[0].struct_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7164 "Parser.c"
    break;

  case 502: /* TYPE_SPEC: BIT_SPEC  */
#line 1296 "HAL_S.y"
             { (yyval.type_spec_) = make_ABtypeSpecBit((yyvsp[0].bit_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7170 "Parser.c"
    break;

  case 503: /* TYPE_SPEC: CHAR_SPEC  */
#line 1297 "HAL_S.y"
              { (yyval.type_spec_) = make_ACtypeSpecChar((yyvsp[0].char_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7176 "Parser.c"
    break;

  case 504: /* TYPE_SPEC: ARITH_SPEC  */
#line 1298 "HAL_S.y"
               { (yyval.type_spec_) = make_ADtypeSpecArith((yyvsp[0].arith_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7182 "Parser.c"
    break;

  case 505: /* TYPE_SPEC: _SYMB_80  */
#line 1299 "HAL_S.y"
             { (yyval.type_spec_) = make_AEtypeSpecEvent(); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7188 "Parser.c"
    break;

  case 506: /* BIT_SPEC: _SYMB_49  */
#line 1301 "HAL_S.y"
                    { (yyval.bit_spec_) = make_AAbitSpecBoolean(); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7194 "Parser.c"
    break;

  case 507: /* BIT_SPEC: _SYMB_48 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1302 "HAL_S.y"
                                                 { (yyval.bit_spec_) = make_ABbitSpecBoolean((yyvsp[-1].literal_exp_or_star_)); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7200 "Parser.c"
    break;

  case 508: /* CHAR_SPEC: _SYMB_57 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1304 "HAL_S.y"
                                                         { (yyval.char_spec_) = make_AAchar_spec((yyvsp[-1].literal_exp_or_star_)); (yyval.char_spec_)->line_number = (yyloc).first_line; (yyval.char_spec_)->char_number = (yyloc).first_column;  }
#line 7206 "Parser.c"
    break;

  case 509: /* STRUCT_SPEC: STRUCT_TEMPLATE STRUCT_SPEC_BODY  */
#line 1306 "HAL_S.y"
                                               { (yyval.struct_spec_) = make_AAstruct_spec((yyvsp[-1].struct_template_), (yyvsp[0].struct_spec_body_)); (yyval.struct_spec_)->line_number = (yyloc).first_line; (yyval.struct_spec_)->char_number = (yyloc).first_column;  }
#line 7212 "Parser.c"
    break;

  case 510: /* STRUCT_SPEC_BODY: _SYMB_5 _SYMB_158  */
#line 1308 "HAL_S.y"
                                     { (yyval.struct_spec_body_) = make_AAstruct_spec_body(); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7218 "Parser.c"
    break;

  case 511: /* STRUCT_SPEC_BODY: STRUCT_SPEC_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1309 "HAL_S.y"
                                                 { (yyval.struct_spec_body_) = make_ABstruct_spec_body((yyvsp[-2].struct_spec_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7224 "Parser.c"
    break;

  case 512: /* STRUCT_TEMPLATE: STRUCTURE_ID  */
#line 1311 "HAL_S.y"
                               { (yyval.struct_template_) = make_FMstruct_template((yyvsp[0].structure_id_)); (yyval.struct_template_)->line_number = (yyloc).first_line; (yyval.struct_template_)->char_number = (yyloc).first_column;  }
#line 7230 "Parser.c"
    break;

  case 513: /* STRUCT_SPEC_HEAD: _SYMB_5 _SYMB_158 _SYMB_2  */
#line 1313 "HAL_S.y"
                                             { (yyval.struct_spec_head_) = make_AAstruct_spec_head(); (yyval.struct_spec_head_)->line_number = (yyloc).first_line; (yyval.struct_spec_head_)->char_number = (yyloc).first_column;  }
#line 7236 "Parser.c"
    break;

  case 514: /* ARITH_SPEC: PREC_SPEC  */
#line 1315 "HAL_S.y"
                       { (yyval.arith_spec_) = make_AAarith_spec((yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7242 "Parser.c"
    break;

  case 515: /* ARITH_SPEC: SQ_DQ_NAME  */
#line 1316 "HAL_S.y"
               { (yyval.arith_spec_) = make_ABarith_spec((yyvsp[0].sq_dq_name_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7248 "Parser.c"
    break;

  case 516: /* ARITH_SPEC: SQ_DQ_NAME PREC_SPEC  */
#line 1317 "HAL_S.y"
                         { (yyval.arith_spec_) = make_ACarith_spec((yyvsp[-1].sq_dq_name_), (yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7254 "Parser.c"
    break;

  case 517: /* COMPILATION: ANY_STATEMENT  */
#line 1319 "HAL_S.y"
                            { (yyval.compilation_) = make_AAcompilation((yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7260 "Parser.c"
    break;

  case 518: /* COMPILATION: COMPILATION ANY_STATEMENT  */
#line 1320 "HAL_S.y"
                              { (yyval.compilation_) = make_ABcompilation((yyvsp[-1].compilation_), (yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7266 "Parser.c"
    break;

  case 519: /* COMPILATION: DECLARE_STATEMENT  */
#line 1321 "HAL_S.y"
                      { (yyval.compilation_) = make_ACcompilation((yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7272 "Parser.c"
    break;

  case 520: /* COMPILATION: COMPILATION DECLARE_STATEMENT  */
#line 1322 "HAL_S.y"
                                  { (yyval.compilation_) = make_ADcompilation((yyvsp[-1].compilation_), (yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7278 "Parser.c"
    break;

  case 521: /* COMPILATION: STRUCTURE_STMT  */
#line 1323 "HAL_S.y"
                   { (yyval.compilation_) = make_AEcompilation((yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7284 "Parser.c"
    break;

  case 522: /* COMPILATION: COMPILATION STRUCTURE_STMT  */
#line 1324 "HAL_S.y"
                               { (yyval.compilation_) = make_AFcompilation((yyvsp[-1].compilation_), (yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7290 "Parser.c"
    break;

  case 523: /* COMPILATION: REPLACE_STMT _SYMB_16  */
#line 1325 "HAL_S.y"
                          { (yyval.compilation_) = make_AGcompilation((yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7296 "Parser.c"
    break;

  case 524: /* COMPILATION: COMPILATION REPLACE_STMT _SYMB_16  */
#line 1326 "HAL_S.y"
                                      { (yyval.compilation_) = make_AHcompilation((yyvsp[-2].compilation_), (yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7302 "Parser.c"
    break;

  case 525: /* COMPILATION: INIT_OR_CONST_HEAD EXPRESSION _SYMB_1  */
#line 1327 "HAL_S.y"
                                          { (yyval.compilation_) = make_AZcompilationInitOrConst((yyvsp[-2].init_or_const_head_), (yyvsp[-1].expression_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7308 "Parser.c"
    break;

  case 526: /* BLOCK_DEFINITION: BLOCK_STMT CLOSING _SYMB_16  */
#line 1329 "HAL_S.y"
                                               { (yyval.block_definition_) = make_AAblock_definition((yyvsp[-2].block_stmt_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7314 "Parser.c"
    break;

  case 527: /* BLOCK_DEFINITION: BLOCK_STMT BLOCK_BODY CLOSING _SYMB_16  */
#line 1330 "HAL_S.y"
                                           { (yyval.block_definition_) = make_ABblock_definition((yyvsp[-3].block_stmt_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7320 "Parser.c"
    break;

  case 528: /* BLOCK_STMT: BLOCK_STMT_TOP _SYMB_16  */
#line 1332 "HAL_S.y"
                                     { (yyval.block_stmt_) = make_AAblock_stmt((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_)->line_number = (yyloc).first_line; (yyval.block_stmt_)->char_number = (yyloc).first_column;  }
#line 7326 "Parser.c"
    break;

  case 529: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_32  */
#line 1334 "HAL_S.y"
                                         { (yyval.block_stmt_top_) = make_AAblockTopAccess((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7332 "Parser.c"
    break;

  case 530: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_138  */
#line 1335 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ABblockTopRigid((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7338 "Parser.c"
    break;

  case 531: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD  */
#line 1336 "HAL_S.y"
                    { (yyval.block_stmt_top_) = make_ACblockTopHead((yyvsp[0].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7344 "Parser.c"
    break;

  case 532: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_82  */
#line 1337 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ADblockTopExclusive((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7350 "Parser.c"
    break;

  case 533: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_131  */
#line 1338 "HAL_S.y"
                              { (yyval.block_stmt_top_) = make_AEblockTopReentrant((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7356 "Parser.c"
    break;

  case 534: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_126  */
#line 1340 "HAL_S.y"
                                           { (yyval.block_stmt_head_) = make_AAblockHeadProgram((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7362 "Parser.c"
    break;

  case 535: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_61  */
#line 1341 "HAL_S.y"
                            { (yyval.block_stmt_head_) = make_ABblockHeadCompool((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7368 "Parser.c"
    break;

  case 536: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_165  */
#line 1342 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ACblockHeadTask((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7374 "Parser.c"
    break;

  case 537: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_177  */
#line 1343 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ADblockHeadUpdate((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7380 "Parser.c"
    break;

  case 538: /* BLOCK_STMT_HEAD: _SYMB_177  */
#line 1344 "HAL_S.y"
              { (yyval.block_stmt_head_) = make_AEblockHeadUpdate(); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7386 "Parser.c"
    break;

  case 539: /* BLOCK_STMT_HEAD: FUNCTION_NAME  */
#line 1345 "HAL_S.y"
                  { (yyval.block_stmt_head_) = make_AFblockHeadFunction((yyvsp[0].function_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7392 "Parser.c"
    break;

  case 540: /* BLOCK_STMT_HEAD: FUNCTION_NAME FUNC_STMT_BODY  */
#line 1346 "HAL_S.y"
                                 { (yyval.block_stmt_head_) = make_AGblockHeadFunction((yyvsp[-1].function_name_), (yyvsp[0].func_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7398 "Parser.c"
    break;

  case 541: /* BLOCK_STMT_HEAD: PROCEDURE_NAME  */
#line 1347 "HAL_S.y"
                   { (yyval.block_stmt_head_) = make_AHblockHeadProcedure((yyvsp[0].procedure_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7404 "Parser.c"
    break;

  case 542: /* BLOCK_STMT_HEAD: PROCEDURE_NAME PROC_STMT_BODY  */
#line 1348 "HAL_S.y"
                                  { (yyval.block_stmt_head_) = make_AIblockHeadProcedure((yyvsp[-1].procedure_name_), (yyvsp[0].proc_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7410 "Parser.c"
    break;

  case 543: /* LABEL_EXTERNAL: LABEL_DEFINITION  */
#line 1350 "HAL_S.y"
                                  { (yyval.label_external_) = make_AAlabel_external((yyvsp[0].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7416 "Parser.c"
    break;

  case 544: /* LABEL_EXTERNAL: LABEL_DEFINITION _SYMB_85  */
#line 1351 "HAL_S.y"
                              { (yyval.label_external_) = make_ABlabel_external((yyvsp[-1].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7422 "Parser.c"
    break;

  case 545: /* CLOSING: _SYMB_59  */
#line 1353 "HAL_S.y"
                   { (yyval.closing_) = make_AAclosing(); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7428 "Parser.c"
    break;

  case 546: /* CLOSING: _SYMB_59 LABEL  */
#line 1354 "HAL_S.y"
                   { (yyval.closing_) = make_ABclosing((yyvsp[0].label_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7434 "Parser.c"
    break;

  case 547: /* CLOSING: LABEL_DEFINITION CLOSING  */
#line 1355 "HAL_S.y"
                             { (yyval.closing_) = make_ACclosing((yyvsp[-1].label_definition_), (yyvsp[0].closing_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7440 "Parser.c"
    break;

  case 548: /* BLOCK_BODY: DECLARE_GROUP  */
#line 1357 "HAL_S.y"
                           { (yyval.block_body_) = make_ABblock_body((yyvsp[0].declare_group_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7446 "Parser.c"
    break;

  case 549: /* BLOCK_BODY: ANY_STATEMENT  */
#line 1358 "HAL_S.y"
                  { (yyval.block_body_) = make_ADblock_body((yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7452 "Parser.c"
    break;

  case 550: /* BLOCK_BODY: BLOCK_BODY ANY_STATEMENT  */
#line 1359 "HAL_S.y"
                             { (yyval.block_body_) = make_ACblock_body((yyvsp[-1].block_body_), (yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7458 "Parser.c"
    break;

  case 551: /* FUNCTION_NAME: LABEL_EXTERNAL _SYMB_90  */
#line 1361 "HAL_S.y"
                                        { (yyval.function_name_) = make_AAfunction_name((yyvsp[-1].label_external_)); (yyval.function_name_)->line_number = (yyloc).first_line; (yyval.function_name_)->char_number = (yyloc).first_column;  }
#line 7464 "Parser.c"
    break;

  case 552: /* PROCEDURE_NAME: LABEL_EXTERNAL _SYMB_124  */
#line 1363 "HAL_S.y"
                                          { (yyval.procedure_name_) = make_AAprocedure_name((yyvsp[-1].label_external_)); (yyval.procedure_name_)->line_number = (yyloc).first_line; (yyval.procedure_name_)->char_number = (yyloc).first_column;  }
#line 7470 "Parser.c"
    break;

  case 553: /* FUNC_STMT_BODY: PARAMETER_LIST  */
#line 1365 "HAL_S.y"
                                { (yyval.func_stmt_body_) = make_AAfunc_stmt_body((yyvsp[0].parameter_list_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7476 "Parser.c"
    break;

  case 554: /* FUNC_STMT_BODY: TYPE_SPEC  */
#line 1366 "HAL_S.y"
              { (yyval.func_stmt_body_) = make_ABfunc_stmt_body((yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7482 "Parser.c"
    break;

  case 555: /* FUNC_STMT_BODY: PARAMETER_LIST TYPE_SPEC  */
#line 1367 "HAL_S.y"
                             { (yyval.func_stmt_body_) = make_ACfunc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7488 "Parser.c"
    break;

  case 556: /* PROC_STMT_BODY: PARAMETER_LIST  */
#line 1369 "HAL_S.y"
                                { (yyval.proc_stmt_body_) = make_AAproc_stmt_body((yyvsp[0].parameter_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7494 "Parser.c"
    break;

  case 557: /* PROC_STMT_BODY: ASSIGN_LIST  */
#line 1370 "HAL_S.y"
                { (yyval.proc_stmt_body_) = make_ABproc_stmt_body((yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7500 "Parser.c"
    break;

  case 558: /* PROC_STMT_BODY: PARAMETER_LIST ASSIGN_LIST  */
#line 1371 "HAL_S.y"
                               { (yyval.proc_stmt_body_) = make_ACproc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7506 "Parser.c"
    break;

  case 559: /* DECLARE_GROUP: DECLARE_ELEMENT  */
#line 1373 "HAL_S.y"
                                { (yyval.declare_group_) = make_AAdeclare_group((yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7512 "Parser.c"
    break;

  case 560: /* DECLARE_GROUP: DECLARE_GROUP DECLARE_ELEMENT  */
#line 1374 "HAL_S.y"
                                  { (yyval.declare_group_) = make_ABdeclare_group((yyvsp[-1].declare_group_), (yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7518 "Parser.c"
    break;

  case 561: /* DECLARE_ELEMENT: DECLARE_STATEMENT  */
#line 1376 "HAL_S.y"
                                    { (yyval.declare_element_) = make_AAdeclareElementDeclare((yyvsp[0].declare_statement_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7524 "Parser.c"
    break;

  case 562: /* DECLARE_ELEMENT: REPLACE_STMT _SYMB_16  */
#line 1377 "HAL_S.y"
                          { (yyval.declare_element_) = make_ABdeclareElementReplace((yyvsp[-1].replace_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7530 "Parser.c"
    break;

  case 563: /* DECLARE_ELEMENT: STRUCTURE_STMT  */
#line 1378 "HAL_S.y"
                   { (yyval.declare_element_) = make_ACdeclareElementStructure((yyvsp[0].structure_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7536 "Parser.c"
    break;

  case 564: /* DECLARE_ELEMENT: _SYMB_76 _SYMB_85 IDENTIFIER _SYMB_169 VARIABLE _SYMB_16  */
#line 1379 "HAL_S.y"
                                                             { (yyval.declare_element_) = make_ADdeclareElementEquate((yyvsp[-3].identifier_), (yyvsp[-1].variable_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7542 "Parser.c"
    break;

  case 565: /* PARAMETER: _SYMB_192  */
#line 1381 "HAL_S.y"
                      { (yyval.parameter_) = make_AAparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7548 "Parser.c"
    break;

  case 566: /* PARAMETER: _SYMB_183  */
#line 1382 "HAL_S.y"
              { (yyval.parameter_) = make_ABparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7554 "Parser.c"
    break;

  case 567: /* PARAMETER: _SYMB_186  */
#line 1383 "HAL_S.y"
              { (yyval.parameter_) = make_ACparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7560 "Parser.c"
    break;

  case 568: /* PARAMETER: _SYMB_187  */
#line 1384 "HAL_S.y"
              { (yyval.parameter_) = make_ADparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7566 "Parser.c"
    break;

  case 569: /* PARAMETER: _SYMB_190  */
#line 1385 "HAL_S.y"
              { (yyval.parameter_) = make_AEparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7572 "Parser.c"
    break;

  case 570: /* PARAMETER: _SYMB_189  */
#line 1386 "HAL_S.y"
              { (yyval.parameter_) = make_AFparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7578 "Parser.c"
    break;

  case 571: /* PARAMETER_LIST: PARAMETER_HEAD PARAMETER _SYMB_1  */
#line 1388 "HAL_S.y"
                                                  { (yyval.parameter_list_) = make_AAparameter_list((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_list_)->line_number = (yyloc).first_line; (yyval.parameter_list_)->char_number = (yyloc).first_column;  }
#line 7584 "Parser.c"
    break;

  case 572: /* PARAMETER_HEAD: _SYMB_2  */
#line 1390 "HAL_S.y"
                         { (yyval.parameter_head_) = make_AAparameter_head(); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 7590 "Parser.c"
    break;

  case 573: /* PARAMETER_HEAD: PARAMETER_HEAD PARAMETER _SYMB_0  */
#line 1391 "HAL_S.y"
                                     { (yyval.parameter_head_) = make_ABparameter_head((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 7596 "Parser.c"
    break;

  case 574: /* DECLARE_STATEMENT: _SYMB_67 DECLARE_BODY _SYMB_16  */
#line 1393 "HAL_S.y"
                                                   { (yyval.declare_statement_) = make_AAdeclare_statement((yyvsp[-1].declare_body_)); (yyval.declare_statement_)->line_number = (yyloc).first_line; (yyval.declare_statement_)->char_number = (yyloc).first_column;  }
#line 7602 "Parser.c"
    break;

  case 575: /* ASSIGN_LIST: ASSIGN PARAMETER_LIST  */
#line 1395 "HAL_S.y"
                                    { (yyval.assign_list_) = make_AAassign_list((yyvsp[-1].assign_), (yyvsp[0].parameter_list_)); (yyval.assign_list_)->line_number = (yyloc).first_line; (yyval.assign_list_)->char_number = (yyloc).first_column;  }
#line 7608 "Parser.c"
    break;

  case 576: /* TEXT: _SYMB_194  */
#line 1397 "HAL_S.y"
                 { (yyval.text_) = make_FQtext((yyvsp[0].string_)); (yyval.text_)->line_number = (yyloc).first_line; (yyval.text_)->char_number = (yyloc).first_column;  }
#line 7614 "Parser.c"
    break;

  case 577: /* REPLACE_STMT: _SYMB_135 REPLACE_HEAD _SYMB_50 TEXT  */
#line 1399 "HAL_S.y"
                                                    { (yyval.replace_stmt_) = make_AAreplace_stmt((yyvsp[-2].replace_head_), (yyvsp[0].text_)); (yyval.replace_stmt_)->line_number = (yyloc).first_line; (yyval.replace_stmt_)->char_number = (yyloc).first_column;  }
#line 7620 "Parser.c"
    break;

  case 578: /* REPLACE_HEAD: IDENTIFIER  */
#line 1401 "HAL_S.y"
                          { (yyval.replace_head_) = make_AAreplace_head((yyvsp[0].identifier_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 7626 "Parser.c"
    break;

  case 579: /* REPLACE_HEAD: IDENTIFIER _SYMB_2 ARG_LIST _SYMB_1  */
#line 1402 "HAL_S.y"
                                        { (yyval.replace_head_) = make_ABreplace_head((yyvsp[-3].identifier_), (yyvsp[-1].arg_list_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 7632 "Parser.c"
    break;

  case 580: /* ARG_LIST: IDENTIFIER  */
#line 1404 "HAL_S.y"
                      { (yyval.arg_list_) = make_AAarg_list((yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 7638 "Parser.c"
    break;

  case 581: /* ARG_LIST: ARG_LIST _SYMB_0 IDENTIFIER  */
#line 1405 "HAL_S.y"
                                { (yyval.arg_list_) = make_ABarg_list((yyvsp[-2].arg_list_), (yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 7644 "Parser.c"
    break;

  case 582: /* STRUCTURE_STMT: _SYMB_158 STRUCT_STMT_HEAD STRUCT_STMT_TAIL  */
#line 1407 "HAL_S.y"
                                                             { (yyval.structure_stmt_) = make_AAstructure_stmt((yyvsp[-1].struct_stmt_head_), (yyvsp[0].struct_stmt_tail_)); (yyval.structure_stmt_)->line_number = (yyloc).first_line; (yyval.structure_stmt_)->char_number = (yyloc).first_column;  }
#line 7650 "Parser.c"
    break;

  case 583: /* STRUCT_STMT_HEAD: STRUCTURE_ID _SYMB_17 LEVEL  */
#line 1409 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_AAstruct_stmt_head((yyvsp[-2].structure_id_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7656 "Parser.c"
    break;

  case 584: /* STRUCT_STMT_HEAD: STRUCTURE_ID MINOR_ATTR_LIST _SYMB_17 LEVEL  */
#line 1410 "HAL_S.y"
                                                { (yyval.struct_stmt_head_) = make_ABstruct_stmt_head((yyvsp[-3].structure_id_), (yyvsp[-2].minor_attr_list_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7662 "Parser.c"
    break;

  case 585: /* STRUCT_STMT_HEAD: STRUCT_STMT_HEAD DECLARATION _SYMB_0 LEVEL  */
#line 1411 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_ACstruct_stmt_head((yyvsp[-3].struct_stmt_head_), (yyvsp[-2].declaration_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7668 "Parser.c"
    break;

  case 586: /* STRUCT_STMT_TAIL: DECLARATION _SYMB_16  */
#line 1413 "HAL_S.y"
                                        { (yyval.struct_stmt_tail_) = make_AAstruct_stmt_tail((yyvsp[-1].declaration_)); (yyval.struct_stmt_tail_)->line_number = (yyloc).first_line; (yyval.struct_stmt_tail_)->char_number = (yyloc).first_column;  }
#line 7674 "Parser.c"
    break;

  case 587: /* INLINE_DEFINITION: ARITH_INLINE  */
#line 1415 "HAL_S.y"
                                 { (yyval.inline_definition_) = make_AAinline_definition((yyvsp[0].arith_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7680 "Parser.c"
    break;

  case 588: /* INLINE_DEFINITION: BIT_INLINE  */
#line 1416 "HAL_S.y"
               { (yyval.inline_definition_) = make_ABinline_definition((yyvsp[0].bit_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7686 "Parser.c"
    break;

  case 589: /* INLINE_DEFINITION: CHAR_INLINE  */
#line 1417 "HAL_S.y"
                { (yyval.inline_definition_) = make_ACinline_definition((yyvsp[0].char_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7692 "Parser.c"
    break;

  case 590: /* INLINE_DEFINITION: STRUCTURE_EXP  */
#line 1418 "HAL_S.y"
                  { (yyval.inline_definition_) = make_ADinline_definition((yyvsp[0].structure_exp_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7698 "Parser.c"
    break;

  case 591: /* ARITH_INLINE: ARITH_INLINE_DEF CLOSING _SYMB_16  */
#line 1420 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_ACprimary((yyvsp[-2].arith_inline_def_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 7704 "Parser.c"
    break;

  case 592: /* ARITH_INLINE: ARITH_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1421 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_AZprimary((yyvsp[-3].arith_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 7710 "Parser.c"
    break;

  case 593: /* ARITH_INLINE_DEF: _SYMB_90 ARITH_SPEC _SYMB_16  */
#line 1423 "HAL_S.y"
                                                { (yyval.arith_inline_def_) = make_AAarith_inline_def((yyvsp[-1].arith_spec_)); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 7716 "Parser.c"
    break;

  case 594: /* ARITH_INLINE_DEF: _SYMB_90 _SYMB_16  */
#line 1424 "HAL_S.y"
                      { (yyval.arith_inline_def_) = make_ABarith_inline_def(); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 7722 "Parser.c"
    break;

  case 595: /* BIT_INLINE: BIT_INLINE_DEF CLOSING _SYMB_16  */
#line 1426 "HAL_S.y"
                                             { (yyval.bit_inline_) = make_AGbit_prim((yyvsp[-2].bit_inline_def_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 7728 "Parser.c"
    break;

  case 596: /* BIT_INLINE: BIT_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1427 "HAL_S.y"
                                               { (yyval.bit_inline_) = make_AZbit_prim((yyvsp[-3].bit_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 7734 "Parser.c"
    break;

  case 597: /* BIT_INLINE_DEF: _SYMB_90 BIT_SPEC _SYMB_16  */
#line 1429 "HAL_S.y"
                                            { (yyval.bit_inline_def_) = make_AAbit_inline_def((yyvsp[-1].bit_spec_)); (yyval.bit_inline_def_)->line_number = (yyloc).first_line; (yyval.bit_inline_def_)->char_number = (yyloc).first_column;  }
#line 7740 "Parser.c"
    break;

  case 598: /* CHAR_INLINE: CHAR_INLINE_DEF CLOSING _SYMB_16  */
#line 1431 "HAL_S.y"
                                               { (yyval.char_inline_) = make_ADchar_prim((yyvsp[-2].char_inline_def_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 7746 "Parser.c"
    break;

  case 599: /* CHAR_INLINE: CHAR_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1432 "HAL_S.y"
                                                { (yyval.char_inline_) = make_AZchar_prim((yyvsp[-3].char_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 7752 "Parser.c"
    break;

  case 600: /* CHAR_INLINE_DEF: _SYMB_90 CHAR_SPEC _SYMB_16  */
#line 1434 "HAL_S.y"
                                              { (yyval.char_inline_def_) = make_AAchar_inline_def((yyvsp[-1].char_spec_)); (yyval.char_inline_def_)->line_number = (yyloc).first_line; (yyval.char_inline_def_)->char_number = (yyloc).first_column;  }
#line 7758 "Parser.c"
    break;

  case 601: /* STRUC_INLINE_DEF: _SYMB_90 STRUCT_SPEC _SYMB_16  */
#line 1436 "HAL_S.y"
                                                 { (yyval.struc_inline_def_) = make_AAstruc_inline_def((yyvsp[-1].struct_spec_)); (yyval.struc_inline_def_)->line_number = (yyloc).first_line; (yyval.struc_inline_def_)->char_number = (yyloc).first_column;  }
#line 7764 "Parser.c"
    break;


#line 7768 "Parser.c"

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

#line 1439 "HAL_S.y"

void yyerror(const char *str)
{
  extern char *HAL_Stext;
  fprintf(stderr,"error: %d,%d: %s at %s\n",
  HAL_Slloc.first_line, HAL_Slloc.first_column, str, HAL_Stext);
}

