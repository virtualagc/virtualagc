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
#define YYFINAL  467
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   7789

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  202
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  192
/* YYNRULES -- Number of rules.  */
#define YYNRULES  602
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  998

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
     657,   658,   659,   660,   661,   662,   663,   664,   665,   667,
     668,   669,   670,   671,   673,   674,   675,   677,   679,   680,
     682,   683,   685,   686,   687,   688,   690,   691,   693,   694,
     695,   696,   697,   698,   699,   700,   702,   703,   704,   705,
     706,   708,   709,   711,   713,   715,   716,   717,   718,   720,
     721,   722,   724,   726,   727,   728,   729,   731,   732,   733,
     734,   735,   736,   737,   738,   740,   741,   742,   743,   744,
     746,   747,   749,   751,   753,   755,   756,   757,   758,   760,
     761,   763,   764,   766,   767,   768,   770,   771,   772,   773,
     774,   776,   777,   779,   780,   781,   782,   783,   784,   785,
     786,   788,   789,   790,   791,   792,   793,   794,   795,   796,
     797,   798,   799,   800,   801,   802,   803,   804,   805,   806,
     807,   808,   809,   810,   811,   812,   813,   814,   815,   816,
     817,   818,   819,   820,   821,   822,   823,   824,   825,   826,
     827,   828,   829,   830,   831,   832,   833,   834,   836,   837,
     838,   839,   841,   842,   843,   844,   846,   847,   849,   850,
     852,   853,   854,   855,   856,   858,   859,   861,   862,   863,
     864,   866,   868,   869,   871,   872,   873,   875,   876,   878,
     879,   881,   882,   883,   884,   886,   887,   889,   891,   892,
     894,   895,   896,   897,   898,   899,   900,   901,   902,   903,
     904,   906,   907,   909,   910,   912,   913,   914,   915,   917,
     918,   919,   920,   922,   923,   924,   925,   927,   928,   930,
     931,   932,   933,   934,   936,   937,   938,   939,   941,   943,
     944,   946,   948,   949,   950,   952,   954,   955,   956,   957,
     959,   960,   962,   964,   965,   967,   969,   970,   971,   972,
     973,   975,   976,   977,   978,   980,   981,   983,   984,   985,
     986,   988,   989,   991,   992,   993,   994,   995,   997,   999,
    1000,  1001,  1003,  1005,  1006,  1007,  1009,  1010,  1011,  1012,
    1013,  1014,  1015,  1017,  1018,  1019,  1020,  1022,  1024,  1026,
    1028,  1029,  1031,  1033,  1034,  1035,  1036,  1038,  1040,  1041,
    1043,  1044,  1046,  1048,  1050,  1052,  1053,  1055,  1056,  1058,
    1059,  1060,  1062,  1063,  1064,  1065,  1066,  1068,  1069,  1070,
    1071,  1072,  1073,  1075,  1076,  1077,  1079,  1080,  1081,  1082,
    1083,  1084,  1085,  1086,  1087,  1088,  1089,  1090,  1091,  1092,
    1093,  1094,  1095,  1096,  1097,  1098,  1099,  1100,  1101,  1102,
    1103,  1104,  1105,  1106,  1107,  1108,  1109,  1110,  1111,  1112,
    1113,  1114,  1115,  1116,  1117,  1118,  1119,  1121,  1122,  1123,
    1125,  1126,  1128,  1129,  1131,  1132,  1133,  1134,  1136,  1138,
    1140,  1142,  1143,  1144,  1145,  1147,  1148,  1149,  1150,  1151,
    1152,  1153,  1154,  1156,  1157,  1158,  1160,  1161,  1163,  1165,
    1166,  1168,  1169,  1171,  1172,  1174,  1175,  1176,  1178,  1180,
    1182,  1183,  1184,  1185,  1186,  1188,  1190,  1191,  1193,  1194,
    1196,  1197,  1198,  1199,  1201,  1202,  1203,  1205,  1206,  1207,
    1209,  1210,  1211,  1213,  1215,  1216,  1218,  1219,  1220,  1222,
    1224,  1225,  1227,  1228,  1230,  1232,  1233,  1235,  1236,  1238,
    1239,  1241,  1242,  1244,  1245,  1247,  1248,  1250,  1252,  1253,
    1254,  1255,  1257,  1258,  1260,  1261,  1263,  1264,  1265,  1266,
    1267,  1268,  1269,  1270,  1271,  1272,  1273,  1274,  1276,  1277,
    1278,  1280,  1281,  1282,  1283,  1284,  1286,  1288,  1289,  1291,
    1293,  1294,  1296,  1297,  1298,  1299,  1300,  1302,  1303,  1305,
    1307,  1309,  1310,  1312,  1314,  1316,  1317,  1318,  1320,  1321,
    1322,  1323,  1324,  1325,  1326,  1327,  1328,  1330,  1331,  1333,
    1335,  1336,  1337,  1338,  1339,  1341,  1342,  1343,  1344,  1345,
    1346,  1347,  1348,  1349,  1351,  1352,  1354,  1355,  1356,  1358,
    1359,  1360,  1362,  1364,  1366,  1367,  1368,  1370,  1371,  1372,
    1374,  1375,  1377,  1378,  1379,  1380,  1382,  1383,  1384,  1385,
    1386,  1387,  1389,  1391,  1392,  1394,  1396,  1398,  1400,  1402,
    1403,  1405,  1406,  1408,  1410,  1411,  1412,  1414,  1416,  1417,
    1418,  1419,  1421,  1422,  1424,  1425,  1427,  1428,  1430,  1432,
    1433,  1435,  1437
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

#define YYPACT_NINF (-792)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-418)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
    5749,    18,  -106,  -792,  -101,   613,  -792,   118,  7313,   113,
      78,   233,  1266,   -20,  -792,   277,  -792,    93,   209,   293,
     341,   144,  -101,   126,  2580,   613,   273,   126,   126,  -106,
    -792,  -792,   307,  -792,   434,  -792,  -792,  -792,  -792,  -792,
     467,  -792,  -792,  -792,  -792,  -792,  -792,   442,  -792,  -792,
    1107,   262,   442,   491,   442,  -792,   442,   509,   133,  -792,
     512,   177,  -792,   754,  -792,   508,  -792,  6715,  6715,  3168,
    -792,  -792,  -792,  -792,  6715,   119,  6437,   396,  6027,  1790,
    2188,   324,   385,   535,   574,  4129,    38,   260,   123,   548,
     188,  5599,  6715,  3364,  1997,  -792,  5895,    95,   109,   357,
     942,    60,  -792,   559,  -792,  -792,  -792,  5895,  -792,  5895,
    -792,  5895,  5895,   567,   616,  -792,  -792,  -792,   442,   597,
    -792,  -792,  -792,   605,  -792,   610,  -792,   618,  -792,  -792,
    -792,  -792,  -792,  -792,   631,   634,   650,  -792,  -792,  -792,
    -792,  -792,  -792,  -792,  -792,   668,  -792,  -792,   640,  -792,
    7501,  1789,   658,   654,  -792,  7598,  -792,   579,    10,  4473,
    -792,   682,  7464,  -792,  -792,  -792,  -792,  4473,  1941,  -792,
    2776,   705,  1941,  -792,  -792,  -792,   688,  -792,  -792,  4817,
      58,  -792,  -792,  3168,   684,   121,  4817,  -792,   686,   294,
    -792,   691,   700,   706,   708,   414,  -792,   377,    94,   294,
     294,  -792,   721,   734,   701,  -792,   743,  3560,  -792,  -792,
     522,   239,  -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,
    -792,  -792,  -792,  -792,   213,  -792,   775,   213,  -792,  -792,
    -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,
    -106,  -792,  -792,   777,  -792,  -792,  -792,  -792,   779,  -792,
    -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,
    -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,   786,  -792,
    -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,
    -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,   790,   808,
     810,  -792,  -792,  -792,  -792,   442,   587,  -792,  5159,  5159,
     761,  4988,   690,  -792,   816,  -792,  -792,  -792,  -792,  -792,
     823,   788,   442,  -792,    67,   237,   183,  -792,  5406,  -792,
    -792,  -792,   625,  -792,   849,  -792,  3364,   852,  -792,   183,
    -792,   857,  -792,  -792,  -792,  -792,   871,  -792,  -792,   388,
    -792,   382,  -792,  -792,  1741,   705,   474,   294,   290,  -792,
    -792,  4301,   563,   863,  -792,   506,  -792,   873,  -792,  -792,
    -792,  -792,  5939,  1107,  -792,  2972,  3364,  1107,   652,  -792,
    3364,  -792,   307,  -792,   815,  7125,  -792,  3168,   124,    81,
    1047,  5516,  1047,    36,    36,    81,   237,  -792,  -792,  -792,
    -792,   386,  -792,  -792,   307,  -792,  -792,  3364,  -792,  -792,
     897,   414,  7313,  -792,  6159,   864,  -792,  -792,   901,   919,
     925,   933,   935,  -792,  -792,  -792,  -792,   416,  -792,  -792,
    -792,  1839,  -792,  2384,  -792,  3364,  4817,  4817,  5327,  4817,
     810,   425,   923,  -792,  -792,   428,  4817,  4817,  5385,   945,
     834,  -792,  -792,   955,   315,    84,  -792,  3756,  -792,  -792,
    -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,   733,
    -792,  -792,   449,   975,   978,  5269,  3364,  -792,  -792,  -792,
     966,  -792,   414,   902,  -792,  6305,   968,  6583,   235,  -792,
    -792,   972,  -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,
    -792,  -792,  -792,  -792,  -792,   831,   938,   984,  -792,   952,
    -792,  -792,   977,  6583,   980,  6583,   982,  6583,   983,  6583,
     442,  -106,   442,  -792,   613,  -792,  4473,  4473,  4473,  4473,
     806,  -792,  7598,  1941,  -792,  1941,  1941,  -792,   705,  -792,
    -792,  -792,  -792,   725,   997,  -792,  -792,   756,  -792,  1001,
    -792,   758,  -792,  -792,  1941,   853,  -792,  4473,   565,  -101,
     535,  1000,    67,    67,  -792,  -792,   987,    63,  1009,  -792,
    -792,  -792,  -792,  -792,  -792,   993,  -792,   994,  -792,  -792,
      53,  1014,  1015,  -792,  -101,   826,   126,   550,    77,   267,
    1010,  1016,  1022,  1007,   637,  1018,  -792,  -792,  -792,   294,
    -792,  3364,  -792,  -792,  -792,  5159,  5159,  3952,  -792,  -792,
    5159,  5159,  5159,  -792,  -792,  -792,  5159,  1033,  -792,  3364,
    -792,  -792,  -792,  -792,  5385,  -792,  -792,  -792,  5385,  5385,
    5385,   239,   239,  -792,  1024,  -792,   294,  1035,  3364,  3952,
    3364,  7149,  1545,  -792,  1023,   806,  4541,   455,  -792,  4817,
     876,  1038,  1027,  -792,  -792,  -792,  -792,   322,  -792,  4645,
     878,   725,  -792,  -792,  -792,  -792,  -792,  -792,  1045,   133,
    -792,  -792,  1030,   562,   772,  -792,  -792,   388,  -792,   442,
     442,   442,   442,  -792,  -792,  -792,   928,  1029,    96,  -792,
    -792,  -792,  -792,  -792,  -792,  4817,  -792,  -792,  5385,  3168,
    3952,   429,   -14,  3168,  -792,  3168,  1031,   785,  1107,  -792,
    1039,  6847,  -792,  -792,  4817,  4817,  4817,  4817,  4817,  -792,
    -792,  1040,   480,   741,   762,  1041,    66,   592,  -792,  1453,
     613,  -792,   725,   725,    67,  4817,  -792,  -792,  -792,  4817,
    4817,  3756,   725,    67,  1048,  -792,  1042,  -792,  -792,  -792,
    -792,  -792,  -792,   803,  -792,  -792,  -101,  6993,  -792,  -792,
    -792,  1043,  -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,
    -792,   820,  -792,  -792,  -792,  1044,  -792,  1046,  -792,  1049,
    -792,  1052,  -792,  -792,   442,  1064,  1066,  1072,  1074,  1075,
    -792,  1941,  1941,   682,  -792,  -792,  -792,  -792,  -792,  1073,
    1082,  1013,  1061,  -792,   276,  -792,  4817,  -792,  4817,  -792,
    -792,  -792,  -792,  -792,  -792,  -792,   846,  -792,  -792,  -792,
    -792,  -792,   442,   239,   442,  1084,  1086,   856,  -792,  -792,
    3952,  -792,   725,  -792,  1087,  -792,  -792,  -792,  -792,  1079,
     912,   237,   183,  -792,  5406,  1050,  1088,  -792,   954,   725,
    -792,   956,  1098,  1099,   442,  -792,  -792,   806,   806,  -792,
     643,  4817,  -792,  1173,  4817,  4645,   725,  -792,  -792,  5159,
    5159,  -792,  3364,  -792,  3364,  3364,  -792,  -792,  -792,  -792,
    -792,  -792,   725,   183,   167,   587,   183,  -792,  -792,  -792,
     528,  1047,   237,  -792,  -792,   333,  -792,   506,   959,  -792,
     770,   848,   862,   879,   905,  -792,  -792,  -792,  -792,  -792,
    -792,  -792,   913,   725,   725,  5176,  -792,  -792,  -792,   940,
    -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,
    -792,  -792,  -792,  -792,  -792,  -792,  -792,   192,   725,  -101,
    -792,  -792,  -792,  1085,   625,  -792,  1332,  1173,  -792,  -792,
    -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,   675,
    -792,   963,  1103,   918,  -792,  -792,  -792,  -792,  -792,  -792,
    -792,  1105,  1107,  1094,  -792,  -792,  -792,  -792,  -792,  -792,
    1107,  4817,  -792,    69,  -792,   967,  -792,  1100,  -792,  -792,
    -792,  1107,  -792,   506,  -792,  1095,   725,  1113,  1100,  1106,
    4817,   981,  -792,  -792,   941,  1115,  -792,  -792
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int16 yydefact[] =
{
       0,     0,     0,   343,     0,     0,   427,     0,     0,     0,
       0,     0,     0,     0,   313,     0,   282,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     241,   426,   539,   425,     0,   245,   247,   248,   278,   302,
     249,   246,   252,   102,    27,   101,   286,    67,   287,   291,
       0,     0,   215,     0,   223,   289,   267,     0,     0,   591,
       0,   293,   297,     0,   300,     0,   377,     0,     0,     0,
     380,   333,   334,   518,     0,     0,   544,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   434,     0,     0,
       0,     0,     0,     0,     0,   381,     0,     0,   532,     0,
     540,   542,   520,     0,   522,   335,   588,     0,   589,     0,
     590,     0,     0,     0,     0,   449,   249,   389,   219,     0,
     489,   480,   479,     0,   477,     0,   507,     0,   478,   169,
     506,    20,    32,   486,     0,    35,     0,    21,    22,   482,
     483,    33,   168,   476,    23,    34,    42,    43,    44,    45,
       9,    17,     0,     0,    36,     5,     6,    38,   516,     0,
      29,     2,     7,   515,    40,    41,   513,     0,    26,   474,
       0,     0,    24,   503,   504,   502,     0,   505,   395,     0,
       0,   456,   455,     0,     0,     0,     0,   338,     0,     0,
     595,     0,     0,     0,     0,     0,   488,     0,   383,     0,
       0,   340,     0,   579,     0,   447,     0,     0,    53,    54,
       0,     0,   348,   214,   112,   142,   124,   125,   126,   127,
     129,   128,   130,   236,   243,   113,     0,   277,   103,   131,
     132,   104,   237,   143,   114,   105,   106,   133,   231,   115,
       0,   234,   147,    32,   149,   148,   273,   134,    35,   154,
     116,   155,   117,   111,   213,   280,   235,   118,   233,   232,
     107,   151,   108,   109,   119,   274,   120,   110,    33,   140,
     141,   121,   122,   135,   136,   153,   137,   152,   138,   139,
     144,   150,   275,   230,   123,   145,    34,   250,   247,   248,
     246,   238,    82,    84,    83,     0,    96,    46,     0,     0,
      51,    55,    59,    63,    64,    76,    81,    77,    80,    65,
       0,     0,    85,    89,    97,   187,   189,   191,     0,   200,
     201,   202,     0,   203,   227,   271,     0,     0,   242,    98,
     256,     0,   261,   262,   265,    99,     0,   100,   293,     0,
     430,     0,   446,   448,     0,     0,     0,     0,     0,    68,
     159,   175,     0,     0,   292,     0,   239,     0,   216,   388,
     224,   268,     0,     0,   307,     0,     0,     0,     0,   298,
       0,   336,     0,   308,   333,     0,   309,     0,     0,     0,
     189,     0,     0,     0,     0,     0,   315,   317,   321,   378,
     371,     0,   545,   537,   538,   337,   379,     0,   344,   390,
       0,   403,     0,   401,   544,     0,   402,   351,     0,     0,
       0,     0,     0,   413,   409,   414,   353,   302,   415,   411,
     416,     0,   352,     0,   354,     0,     0,     0,     0,     0,
       0,     0,     0,   362,   428,     0,     0,     0,     0,     0,
       0,   366,   436,     0,   438,   442,   437,     0,   368,   450,
     375,   468,   469,   284,   285,   470,   471,   452,   283,     0,
     453,   400,    96,   491,     0,   495,     0,     1,   519,   521,
       0,   523,   546,     0,   550,   544,     0,     0,   549,   560,
     562,     0,   564,   529,   530,   531,   533,   534,   536,   552,
     553,   535,   573,   555,   541,   554,     0,     0,   543,   557,
     558,   524,     0,     0,     0,     0,     0,     0,     0,     0,
      69,     0,    71,   220,     0,   472,     0,     0,     0,     0,
       0,    30,    14,    12,    10,    15,    18,   575,     0,     4,
      39,   517,   501,   500,     0,   499,     8,     0,   475,     0,
     491,     0,    44,    37,    25,     0,   510,     0,     0,     0,
       0,     0,   457,   458,   398,   396,     0,   461,   460,   339,
     419,   598,   601,   602,   594,     0,   374,     0,   387,   386,
     382,     0,     0,   341,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   253,   244,   254,     0,
     266,     0,    90,   211,   212,     0,     0,     0,    47,    48,
       0,     0,     0,    58,    61,    62,     0,     0,    66,     0,
     349,    86,   197,   196,     0,   195,   198,   199,     0,     0,
       0,     0,     0,   193,     0,   229,     0,     0,     0,     0,
       0,     0,     0,   370,     0,     0,     0,     0,   583,     0,
       0,     0,   170,   161,   160,   178,   184,   182,   176,     0,
     177,   183,   174,   158,   172,   173,   288,   240,     0,     0,
     304,   303,     0,    96,     0,    91,    93,    95,   306,    73,
     217,   225,   269,   301,   305,   312,     0,     0,     0,   329,
     330,   328,   331,   332,   327,     0,   314,   311,     0,     0,
       0,     0,     0,     0,   310,     0,     0,     0,     0,   404,
       0,     0,   405,   350,     0,     0,     0,     0,     0,   410,
     412,     0,     0,     0,     0,     0,     0,     0,   359,     0,
       0,   363,   431,   432,   433,     0,   443,   367,   439,     0,
       0,     0,   444,   445,     0,   451,     0,   496,   526,   490,
     497,   492,   493,     0,   525,   547,     0,     0,   548,   527,
     551,     0,   561,   563,   556,   567,   568,   569,   571,   570,
     566,     0,   576,   559,   592,     0,   596,     0,   599,     0,
     295,     0,    70,    72,   221,     0,     0,     0,     0,     0,
      13,    11,    16,     3,    28,   473,    19,   485,   484,   511,
       0,   399,     0,   465,     0,   397,     0,   459,     0,   342,
     373,   385,   384,   406,   407,   581,     0,   577,   578,    75,
     204,   264,   207,     0,   209,     0,     0,     0,    49,    50,
       0,   276,   259,   260,     0,    52,    56,    57,    60,     0,
       0,   188,   190,   192,     0,     0,     0,   205,     0,   258,
     257,     0,     0,     0,    87,   369,   584,     0,     0,   587,
       0,     0,   408,   166,     0,     0,   182,   179,   181,     0,
       0,   290,     0,   356,     0,     0,   294,    74,   218,   226,
     270,   319,   322,   324,     0,     0,   323,   326,   299,   325,
       0,     0,   316,   318,   372,     0,   391,   393,     0,   467,
       0,     0,     0,     0,     0,   355,   357,   418,   358,   361,
     360,   429,     0,   441,   440,     0,   376,   498,   494,     0,
     528,   574,   572,   593,   597,   600,   296,   222,   508,   509,
     481,    31,   487,   514,   512,   454,   466,   463,   462,     0,
     580,   208,   210,     0,     0,    79,     0,   166,    78,   194,
     228,   206,   263,   281,   279,    88,   585,   586,   364,     0,
     167,     0,     0,     0,   180,   185,   186,    94,    92,   320,
     345,     0,     0,     0,   422,   423,   424,   420,   421,   435,
       0,     0,   582,     0,   272,     0,   365,   171,   162,   165,
     163,     0,   392,   394,   346,     0,   464,     0,     0,   166,
       0,     0,   565,   255,     0,     0,   164,   347
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -792,   717,   965,  -122,  -792,  -111,    98,  -792,  -792,   378,
     614,  -792,   859,  -261,   969,  1169,  -259,   537,  -792,  -792,
     470,  -792,   683,  -490,   -74,  -792,   -80,  -792,  -354,   279,
     -10,     6,  -584,  -792,  1131,   842,  -637,  -149,  -792,  -792,
    -792,  -792,  -603,  -792,    41,   533,    -8,  -377,  -792,  -380,
    -300,  -117,   -54,    47,    83,   168,  -792,   -65,  -791,  -319,
     632,  -792,  -792,    14,  1096,  -792,  -348,   924,  -792,   -36,
    -499,  -792,   885,   -60,  -792,    -7,    62,  1076,  -304,   -38,
    1275,  -792,   719,  -792,     0,   364,   225,   -23,  -792,  -792,
    -792,  -792,   765,  -173,   459,   458,  -792,  -328,   368,   -31,
     -25,   314,  -792,  -792,   219,  -792,   -73,   173,  -792,  1077,
    -792,  -792,  -792,  -792,   736,   737,   794,  -792,   -59,  -792,
    -792,  -792,  -792,  -792,  -792,  -792,  -792,   718,   774,  -792,
    -792,  -792,  -792,   -56,   976,  -792,  -792,  -792,  -792,  -792,
     702,  -792,  -138,   -46,  1166,  -151,  -792,  -792,  -792,   -64,
     -71,  1161,  1163,    45,  -792,  -792,  -792,  1164,  -792,  -792,
    -792,  -792,  -792,  -792,   399,   729,  -792,  -792,  -792,  -792,
    -792,   703,  -792,   -85,  -792,   157,   680,  -792,   184,  -792,
    -792,   197,  -792,  -792,  -792,  -792,  -792,  -792,  -792,  -792,
    -792,  -792
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
       0,   152,   153,   154,   155,   156,    45,   158,   159,   295,
     161,   162,   296,   297,   298,   299,   300,   301,   606,   302,
     303,   304,   305,   306,   307,   308,   309,   310,   664,   665,
     666,    47,   312,   313,   369,   350,   854,   163,   351,   352,
     648,   649,   650,   651,   314,   315,   316,   614,   615,   618,
     317,   597,   318,   319,   320,   321,   322,   323,   324,   325,
     326,    51,   327,    52,   118,   328,    54,   587,   588,   329,
     330,   331,    55,   333,   334,    56,   335,    57,   457,    58,
     337,    60,   338,    62,   432,    64,    65,   684,    66,    67,
      68,    69,   687,   385,   386,   387,   388,   685,    70,    71,
      72,   474,    74,    75,   475,    77,   497,   888,    78,   702,
      79,    80,    81,    82,   414,   419,    83,    84,   415,    85,
      86,   435,    87,    88,   443,   444,   445,   446,    89,    90,
      91,   459,    92,   183,   184,   185,   558,   797,   186,   406,
     460,   167,   168,   169,   170,   464,   465,   466,   171,   534,
     172,   173,   174,   175,   546,   176,   547,   177,    94,    95,
      96,    97,    98,    99,   748,   477,   100,   101,   494,   498,
     478,   479,   761,   495,   496,   480,   500,   808,   481,   204,
     806,   482,   345,   638,   105,   106,   107,   108,   109,   110,
     111,   112
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      63,   165,   114,   625,   400,   119,   695,   113,   693,   531,
     553,   453,   353,   526,   311,   381,   499,   452,   623,   541,
     671,   420,   164,   206,   339,   119,   455,   206,   206,   493,
     779,   456,   447,   382,   544,   365,   374,   598,   599,   524,
     370,   413,   603,   697,   529,   395,   857,    48,   844,   543,
     355,   396,   688,   458,   690,   691,   692,   193,   658,   433,
     425,   380,   952,   679,   364,   680,   492,    63,    63,   339,
     418,   208,   209,     1,    63,     2,    63,   240,    63,   355,
     339,   623,   810,   463,   129,    39,   119,   899,   117,   612,
     612,   339,    63,   339,    63,    44,    63,    48,   823,   187,
     612,   871,   115,   537,   612,   399,   157,    63,   340,    63,
     379,    63,    63,   348,    48,    48,   483,   223,   729,   612,
     203,    48,   538,    48,   120,    48,    48,   440,   484,   381,
     840,   383,   208,   209,   178,   844,   232,   363,    48,    48,
     390,    48,   555,    48,   441,   846,   952,   382,   801,   593,
     195,   679,   364,   680,    48,   391,    48,   102,    48,    48,
     540,   364,   241,   142,   165,   201,   730,   179,    49,   434,
     339,   579,   959,   197,   454,   380,   693,    39,   878,   594,
     551,  -292,   987,   339,   103,   164,   256,   613,   613,   568,
     612,   205,   486,   442,   449,   342,   343,   104,   613,   619,
     208,   209,   613,   180,   678,  -292,   636,   580,   593,   450,
     582,   584,   629,    43,    44,   802,   113,   613,    49,    76,
     681,   682,   683,   637,   552,   549,    36,    37,   671,    39,
     116,    41,   348,   796,   485,    49,    49,   817,   594,   189,
     585,   487,    49,   971,    49,   383,    49,    49,   578,    39,
     686,   469,   954,    43,    44,   830,   569,   581,   583,    49,
      49,   616,    49,   619,    49,   629,    36,    37,   356,   157,
     116,    41,   811,   617,   838,    49,   841,    49,   470,    49,
      49,   348,   453,   196,   671,   193,   375,   375,   613,   198,
     181,   471,   593,   375,   182,   375,   642,   404,   181,   199,
     181,   693,   182,     8,   182,     1,   436,     2,   681,   682,
     683,   375,   473,    76,    73,   743,   627,    39,   624,   833,
      42,   844,   594,   381,   458,   659,   339,   843,   421,   659,
     208,   209,    36,    37,   818,   819,   116,    41,   165,   825,
     990,   677,   826,   827,   395,   422,   119,   200,   551,   690,
     396,   990,   844,   341,   960,   661,   437,   946,   947,   164,
     674,   672,   339,    63,   420,   339,   667,    63,   855,   380,
     339,    22,   166,   395,   669,    63,   166,   339,   399,   396,
     438,   624,   670,   413,   439,   781,   160,   782,   447,   423,
     160,   452,   403,   344,    29,   165,   348,   667,   566,   632,
     455,   348,   397,   633,    63,   456,   424,   348,   468,    48,
      48,   780,   762,   418,    48,   711,   164,   398,   578,   488,
    -417,   355,    48,   339,   754,   712,    35,   741,   624,   640,
      39,   346,   720,   208,   209,   373,   376,  -417,   624,   383,
     347,   399,   389,   157,   395,   454,   718,   734,   489,   721,
     396,    48,   775,   776,   777,   778,   540,   208,   209,   848,
     461,   348,   629,   737,   166,   355,   339,    39,    48,   716,
      46,    43,    44,  -299,   593,    63,   849,    63,   160,   724,
     538,    39,   490,   790,   491,    43,    44,   671,   733,   292,
     293,   632,   181,   292,   293,   476,   182,   693,   538,   348,
     157,   896,   695,    63,   594,    63,   502,    63,   504,    63,
     506,   508,    48,   359,   166,   362,   874,   368,   366,   166,
      46,   165,    48,    23,    48,   348,   166,   793,   160,   371,
      49,    49,    27,   160,   939,    49,    28,    46,    46,   511,
     160,    16,   164,    49,    46,   255,    46,   348,    46,    46,
      48,   453,    48,   688,    48,   809,    48,   671,   208,   209,
     629,    46,    46,   364,    46,   834,    46,   652,   653,   448,
     208,   209,    49,   208,   209,   593,   864,    46,   426,    46,
     501,    46,    46,   510,   654,   655,   791,   593,   660,    49,
     538,   667,   668,   458,   375,   208,   209,   824,   955,   956,
     208,   209,    36,    37,   166,   594,   116,    41,   514,   667,
     832,   515,   593,   900,   624,   974,   516,   594,   624,   624,
     624,   582,   582,   701,   517,   672,   157,   511,   667,   824,
     667,   339,    50,    49,   512,   381,   862,   518,   669,   381,
     519,   381,   594,    49,   639,    49,   670,   792,   813,  -302,
     550,   208,   209,   382,   876,   512,   520,   382,   528,   382,
     886,   578,    36,    37,   948,    39,   116,    41,   581,   583,
     395,    49,   805,    49,   521,    49,   396,    49,    48,   527,
     873,   380,    50,   208,   209,   881,   535,   881,   624,   339,
     824,   530,   880,   339,   747,   339,   976,   545,   887,    50,
      50,    63,   604,   605,   951,   554,    50,   559,    50,    35,
      50,    50,   561,    39,   454,   619,   395,    43,    44,    61,
     119,   562,   396,    50,    50,   669,    50,   563,    50,   564,
     578,   734,   673,   208,   209,   538,   538,   735,   736,    50,
     574,    50,   573,    50,    50,    48,   897,    63,    48,   208,
     209,   383,   575,   877,   576,   383,   619,   383,   367,   629,
     785,   786,   739,   788,   619,   368,   166,   809,   600,   354,
     208,   209,   578,   348,   451,   964,   865,   866,   208,   209,
     160,   589,   364,  -156,   579,  -146,    61,    61,   975,   865,
     885,   750,  -157,    61,    48,   354,  -251,    61,   354,    49,
     669,    36,    37,   901,    39,   116,    41,   907,   908,   610,
     354,    61,   961,    61,  -276,    61,   591,   750,   643,   750,
     824,   750,   291,   750,   911,   912,    61,   670,    61,   609,
      61,    61,    46,    46,   624,   607,   503,    46,   505,    35,
     507,   509,    38,    39,   909,    46,    42,    43,    44,   670,
     929,   930,   661,   965,   957,   626,   208,   209,   628,   166,
     865,   935,   339,   630,   339,   667,    49,   966,   656,    49,
     208,   209,   560,   160,    46,   673,   751,   631,   673,   657,
     125,   126,   571,   572,   967,   703,   166,   208,   209,   127,
     675,    46,    35,   146,   147,    38,   542,   149,   150,   151,
     160,    44,   765,   698,   767,   129,   769,   704,   771,   332,
     968,   669,   130,   208,   209,    49,   865,   938,   969,   670,
     701,   208,   209,   980,   982,   705,   208,   209,   378,   672,
     132,   706,   985,   809,   719,    46,   208,   209,   135,   707,
     673,   708,   669,   886,   431,    46,   996,    46,   492,   208,
     209,   725,   462,   593,   332,   679,   364,   680,   865,   941,
     865,   942,   983,   962,   963,   332,   747,   977,   978,   726,
     355,   988,   978,    46,   141,    46,   727,    46,   332,    46,
     738,   887,   739,   594,   142,   962,   995,   744,   746,   749,
     492,   125,   126,   753,    50,    50,   673,   399,   764,    50,
     127,   766,   784,   768,   770,   292,   787,    50,   795,    48,
     145,   794,   789,   798,   799,   800,   129,    48,   533,   803,
     804,   632,    39,   130,   807,   814,   533,   972,    48,   462,
     641,   644,   812,   813,   811,   835,    50,   815,   548,   829,
     837,   132,   378,   852,   845,   557,   851,   853,   858,   135,
     861,   863,   884,    50,   593,   332,   679,   364,   680,   905,
     889,   895,   898,   906,   910,   913,   577,   914,   332,   918,
     915,   919,   593,   916,   679,   364,   680,   920,   921,   923,
     922,   354,   354,   673,   594,   141,   354,   924,   925,   926,
     933,   934,   332,   940,   354,   142,    53,    50,   936,   937,
     336,    46,   594,   943,   944,   973,   188,    50,   979,    50,
     970,   981,   681,   682,   683,   984,   992,   202,   993,   700,
     989,   145,     1,   354,     2,   755,   950,   536,   756,   757,
      49,   758,   759,    39,   760,    50,   997,    50,    49,    50,
     354,    50,   783,   828,   958,   336,   608,   831,   451,    49,
     694,   590,   882,   883,   991,   405,   336,   709,   673,   662,
     710,   556,   728,    53,    53,   696,    93,   742,    46,   336,
      53,    46,    53,   191,    53,   192,   194,   673,   349,   763,
       0,   752,   357,   358,   354,   360,     0,   361,    53,     0,
      53,     0,    53,   950,   354,     0,    61,     0,     0,   673,
       0,     0,     0,    53,     0,    53,     0,    53,    53,     0,
     647,   332,     0,   681,   682,   683,     0,    46,     0,    16,
       0,   223,    61,     0,    61,   663,    61,     0,    61,     0,
       0,   681,   682,   683,     0,     0,   676,    35,    36,    37,
     232,    39,   116,    41,    42,     0,   336,   129,     0,   513,
     332,   332,     0,     0,     0,   332,   663,     0,     0,   336,
       0,     0,   332,    50,     0,   595,   241,    30,     0,   673,
       0,     0,   816,     0,     0,    59,     0,     0,     0,     0,
       0,     0,   332,     0,     0,   713,   714,   190,   717,     0,
     256,   565,     0,     0,    35,   722,   723,    38,    39,     0,
     673,    42,    43,    44,     0,     0,   732,     0,   332,   836,
     332,     0,     0,     0,     0,   125,   126,     0,     0,     0,
       0,     0,     0,     0,   127,   462,   142,     0,   567,   570,
      50,     0,     0,    50,     0,     0,     0,     0,     0,     0,
     129,     0,    59,    59,   384,     0,     0,   595,     0,    59,
     354,   332,     0,    59,     0,   586,     0,     0,   586,     0,
       0,     0,     0,     0,     0,   132,     0,    59,     0,    59,
       0,    59,     0,   135,     0,   533,   533,   533,   533,    50,
       0,     0,    59,     0,    59,     0,    59,    59,     0,     0,
       0,   228,     0,     0,     0,     0,     0,     0,   231,     0,
     595,     0,   336,     0,     0,     0,   533,     0,     0,   141,
     235,   236,     0,     0,     0,     0,     0,   354,     0,   142,
     354,     0,     0,     0,     0,     0,   592,     0,     0,     0,
       0,   595,    46,     0,     0,     0,     0,     0,     0,     0,
      46,   336,   336,   611,     0,   145,   336,     0,     0,     0,
     663,    46,     0,   336,     0,   260,   822,    39,   384,     0,
     262,   263,     0,     0,     0,   596,   354,     0,   663,     0,
       0,    53,   634,   336,   267,     0,   332,     0,     0,     0,
       0,     0,   332,     0,     0,     0,     0,   663,   839,   663,
       0,     0,     0,     0,   332,     0,     0,   699,   850,   336,
      53,   336,   595,     0,     0,     0,     0,     0,   856,     0,
       0,     0,   228,   332,   332,   332,     0,   595,     0,   231,
       0,     0,    38,    39,     0,     0,   595,    43,    44,     0,
       0,   235,   236,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   336,     0,   872,     0,   595,   596,   378,   875,
       0,     0,   378,     0,   378,     0,     0,     0,     0,     0,
       0,     0,     0,   890,   891,   892,   893,   894,   745,     0,
       0,    53,     0,    53,   332,   332,   260,     0,   332,     0,
     332,   262,   263,     0,   902,     0,     0,     0,   903,   904,
     714,     0,     0,     0,    50,   267,     0,     0,     0,    53,
     596,    53,    50,    53,   228,    53,     0,     0,     0,     0,
     774,   231,     0,    50,     0,     0,   595,     0,     0,     0,
     859,     0,     0,   235,   236,     0,     0,     0,     0,     0,
       0,   596,   595,     0,     0,     0,     0,     0,     0,     0,
       0,   772,     0,   773,    39,   595,     0,     0,    43,    44,
       0,     0,   384,     0,     0,   927,     0,   928,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   336,   260,     0,
       0,     0,     0,   262,   263,     0,     0,     0,     0,   577,
       0,   354,   595,   595,     0,   336,   595,   267,     0,   354,
       0,   595,   595,     0,     0,     0,     0,     0,     0,     0,
     354,   595,   596,     0,   336,   332,   336,     0,     0,     0,
     949,     0,     0,   953,   856,     0,     0,   596,     0,     0,
       0,     0,     0,     0,   663,     0,   596,     0,   774,     0,
       0,     0,    35,    36,    37,    38,    39,   116,    41,    42,
      43,    44,     0,     0,     0,     0,   596,   332,     0,   332,
     332,     0,    59,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   635,     0,   336,     0,   336,     0,   336,
       0,   336,     0,     0,   121,     0,   122,     0,    59,     0,
      59,     0,    59,     0,    59,     0,     0,     0,   124,     0,
       0,   595,     0,     0,     0,     0,     0,    53,     0,     0,
     867,   868,   869,   870,     7,     1,     0,     2,   595,     0,
     128,   407,     0,     0,     0,     0,   596,     0,     0,   595,
     860,     0,   121,     0,   122,   595,     0,     0,     0,     0,
     986,     0,   596,     0,     0,     0,   124,     0,     0,    15,
       0,   595,   133,    53,   595,   596,   134,     0,     0,   994,
       0,   408,     7,     0,     1,   136,     2,     0,   128,   595,
     595,   595,   595,   595,     0,     0,     0,     0,     0,     0,
     525,   595,   595,   595,     0,   139,     0,     0,     0,     0,
     140,     0,   596,   596,     0,     0,   596,    15,     0,     0,
     133,   596,   596,   409,   134,     0,   595,   595,     0,   143,
     408,   596,    16,   136,     0,   917,     0,     0,     0,     0,
       0,     0,   410,     0,     0,     0,     0,     0,   595,     0,
       0,     0,   595,   139,     0,     0,     0,     0,   140,     0,
       0,   774,     0,     0,     0,     0,     0,     0,   336,     0,
     336,   336,   409,   931,     0,   932,   411,   143,     0,     0,
      30,    16,     0,   412,     0,   595,     0,     0,     0,     0,
       0,   410,     0,   595,   384,     0,     0,   879,   384,     0,
     384,     0,     0,     0,   121,   945,   122,    35,     0,     0,
      38,    39,     0,     0,    42,    43,    44,     0,   124,     0,
       0,   596,     0,     0,     0,   411,     0,   467,     0,    30,
       0,   774,   412,     0,     7,     0,     0,     0,   596,     0,
     128,     0,     1,     0,     2,     0,     0,     0,     3,   596,
       0,     0,     0,     0,     0,   596,    35,     4,     0,    38,
      39,     0,     0,    42,    43,    44,     0,     0,     0,    15,
       0,   596,   133,     0,   596,     0,   134,     0,     0,     5,
       6,     0,     0,     0,     0,   136,     0,     0,     0,   596,
     596,   596,   596,   596,     0,     8,     0,     0,     0,     0,
       9,   596,   596,   596,     0,   139,     0,     0,     0,     0,
     140,    10,     0,     0,     0,    11,     0,     0,    12,    13,
       0,    14,     0,     0,     0,     0,   596,   596,     0,   143,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    16,
       0,     0,     0,     0,     0,     0,    17,    18,   596,     0,
       0,     0,   596,     0,     0,     0,     0,    19,    20,     0,
       0,     0,    21,    22,    23,    24,     0,     0,     0,     0,
       0,    25,    26,    27,     0,     0,     0,    28,     0,     0,
       0,     0,     0,     0,     0,   596,    29,    30,     0,     0,
       0,     0,     0,   596,     0,    31,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    32,     0,    33,     0,    34,
       0,     0,     0,     0,    35,    36,    37,    38,    39,    40,
      41,    42,    43,    44,   207,     0,   208,   209,     0,     0,
       0,     0,     0,   210,     0,   211,     0,     0,     0,   416,
       0,     0,     0,     0,   213,     0,     0,     0,     0,   214,
     215,     0,     0,     0,     0,   216,   217,   218,   219,   220,
     221,   222,     0,     0,     0,     0,   223,   224,     0,     0,
       0,     0,     0,     0,   225,   226,   227,   228,     0,   408,
       0,     0,   229,   230,   231,   232,     0,     0,     0,   233,
     234,     0,     0,     0,     0,     0,   235,   236,     0,     0,
       0,     0,     0,   237,     0,   238,     0,   239,     0,   240,
       0,   241,     0,     0,     0,   242,     0,   243,   244,     0,
     245,   409,   246,     0,   247,   248,   249,   250,   251,   252,
      16,   253,     0,   254,   255,   256,   257,   258,   259,     0,
     410,   260,     0,     0,   261,     0,   262,   263,     0,     0,
       0,   264,     0,     0,     0,     0,     0,     0,   265,   266,
     267,   268,     0,     0,     0,   269,   270,   271,     0,   272,
     273,     0,   274,   275,   411,   276,     0,     0,    30,   277,
       0,   412,   278,   279,     0,     0,     0,     0,     0,   280,
     281,   282,   283,   284,   285,     0,     0,   286,     0,     0,
       0,   287,     0,     0,     0,    35,   288,   289,    38,   417,
      40,   290,    42,    43,    44,   291,     0,   292,   293,   294,
     207,     0,   208,   209,     0,     0,     0,     0,     0,   210,
       0,   211,     0,     0,     0,     0,     0,     0,     0,     0,
     213,     0,     0,     0,     0,   214,   215,     0,     0,     0,
       0,   216,   217,   218,   219,   220,   221,   222,     0,     0,
       0,     0,   223,   224,     0,     0,     0,     0,     0,     0,
     225,   226,   227,   228,     0,   408,     0,     0,   229,   230,
     231,   232,     0,     0,     0,   233,   234,     0,     0,     0,
       0,     0,   235,   236,     0,     0,     0,     0,     0,   237,
       0,   238,     0,   239,     0,   240,     0,   241,     0,     0,
       0,   242,     0,   243,   244,     0,   245,   409,   246,     0,
     247,   248,   249,   250,   251,   252,    16,   253,     0,   254,
     255,   256,   257,   258,   259,     0,   410,   260,     0,     0,
     261,     0,   262,   263,     0,     0,     0,   264,     0,     0,
       0,     0,     0,     0,   265,   266,   267,   268,     0,     0,
       0,   269,   270,   271,     0,   272,   273,     0,   274,   275,
     411,   276,     0,     0,    30,   277,     0,   412,   278,   279,
       0,     0,     0,     0,     0,   280,   281,   282,   283,   284,
     285,     0,     0,   286,     0,     0,     0,   287,     0,     0,
       0,    35,   288,   289,    38,   417,    40,   290,    42,    43,
      44,   291,     0,   292,   293,   294,   207,     0,   208,   209,
       0,     0,     0,     0,     0,   210,     0,   211,     0,     0,
       0,   212,     0,     0,     0,     0,   213,     0,     0,     0,
       0,   214,   215,     0,     0,     0,     0,   216,   217,   218,
     219,   220,   221,   222,     0,     0,     0,     0,   223,   224,
       0,     0,     0,     0,     0,     0,   225,   226,   227,   228,
       0,     0,     0,     0,   229,   230,   231,   232,     0,     0,
       0,   233,   234,     0,     0,     0,     0,     0,   235,   236,
       0,     0,     0,     0,     0,   237,     0,   238,     0,   239,
       0,   240,     0,   241,     0,     0,     0,   242,     0,   243,
     244,     0,   245,     0,   246,     0,   247,   248,   249,   250,
     251,   252,    16,   253,     0,   254,   255,   256,   257,   258,
     259,     0,     0,   260,     0,     0,   261,     0,   262,   263,
       0,     0,     0,   264,     0,     0,     0,     0,     0,     0,
     265,   266,   267,   268,     0,     0,     0,   269,   270,   271,
       0,   272,   273,     0,   274,   275,     0,   276,     0,     0,
      30,   277,     0,     0,   278,   279,     0,     0,     0,     0,
       0,   280,   281,   282,   283,   284,   285,     0,     0,   286,
       0,     0,     0,   287,     0,     0,     0,    35,   288,   289,
      38,    39,    40,   290,    42,    43,    44,   291,     0,   292,
     293,   294,   207,     0,   208,   209,   539,     0,     0,     0,
       0,   210,     0,   211,     0,     0,     0,     0,     0,     0,
       0,     0,   213,     0,     0,     0,     0,   214,   215,     0,
       0,     0,     0,   216,   217,   218,   219,   220,   221,   222,
       0,     0,     0,     0,   223,   224,     0,     0,     0,     0,
       0,     0,   225,   226,   227,   228,     0,     0,     0,     0,
     229,   230,   231,   232,     0,     0,     0,   233,   234,     0,
       0,     0,     0,     0,   235,   236,     0,     0,     0,     0,
       0,   237,     0,   238,     0,   239,     0,   240,     0,   241,
       0,     0,     0,   242,     0,   243,   244,     0,   245,     0,
     246,     0,   247,   248,   249,   250,   251,   252,    16,   253,
       0,   254,   255,   256,   257,   258,   259,     0,     0,   260,
       0,     0,   261,     0,   262,   263,     0,     0,     0,   264,
       0,     0,     0,     0,     0,     0,   265,   266,   267,   268,
       0,     0,     0,   269,   270,   271,     0,   272,   273,     0,
     274,   275,     0,   276,     0,     0,    30,   277,     0,     0,
     278,   279,     0,     0,     0,     0,     0,   280,   281,   282,
     283,   284,   285,     0,     0,   286,     0,     0,     0,   287,
       0,     0,     0,    35,   288,   289,    38,    39,    40,   290,
      42,    43,    44,   291,     0,   292,   293,   294,   207,     0,
     208,   209,     0,     0,     0,     0,     0,   210,     0,   211,
       0,     0,     0,     0,     0,     0,     0,     0,   213,     0,
       0,     0,     0,   214,   215,     0,     0,     0,     0,   216,
     217,   218,   219,   220,   221,   222,     0,     0,     0,     0,
     223,   224,     0,     0,     0,     0,     0,     0,   225,   226,
     227,   228,     0,     0,     0,     0,   229,   230,   231,   232,
       0,     0,     0,   233,   234,     0,     0,     0,     0,     0,
     235,   236,     0,     0,     0,     0,     0,   237,     0,   238,
      11,   239,     0,   240,     0,   241,     0,     0,     0,   242,
       0,   243,   244,     0,   245,     0,   246,     0,   247,   248,
     249,   250,   251,   252,    16,   253,     0,   254,   255,   256,
     257,   258,   259,     0,     0,   260,     0,     0,   261,     0,
     262,   263,     0,     0,     0,   264,     0,     0,     0,     0,
       0,     0,   265,   266,   267,   268,     0,     0,     0,   269,
     270,   271,     0,   272,   273,     0,   274,   275,     0,   276,
       0,     0,    30,   277,     0,     0,   278,   279,     0,     0,
       0,     0,     0,   280,   281,   282,   283,   284,   285,     0,
       0,   286,     0,     0,     0,   287,     0,     0,     0,    35,
     288,   289,    38,    39,    40,   290,    42,    43,    44,   291,
       0,   292,   293,   294,   377,     0,   208,   209,     0,     0,
       0,     0,     0,   210,     0,   211,     0,     0,     0,     0,
       0,     0,     0,     0,   213,     0,     0,     0,     0,   214,
     215,     0,     0,     0,     0,   216,   217,   218,   219,   220,
     221,   222,     0,     0,     0,     0,   223,   224,     0,     0,
       0,     0,     0,     0,   225,   226,   227,   228,     0,     0,
       0,     0,   229,   230,   231,   232,     0,     0,     0,   233,
     234,     0,     0,     0,     0,     0,   235,   236,     0,     0,
       0,     0,     0,   237,     0,   238,     0,   239,     0,   240,
       0,   241,     0,     0,     0,   242,     0,   243,   244,     0,
     245,     0,   246,     0,   247,   248,   249,   250,   251,   252,
      16,   253,     0,   254,   255,   256,   257,   258,   259,     0,
       0,   260,     0,     0,   261,     0,   262,   263,     0,     0,
       0,   264,     0,     0,     0,     0,     0,     0,   265,   266,
     267,   268,     0,     0,     0,   269,   270,   271,     0,   272,
     273,     0,   274,   275,     0,   276,     0,     0,    30,   277,
       0,     0,   278,   279,     0,     0,     0,     0,     0,   280,
     281,   282,   283,   284,   285,     0,     0,   286,     0,     0,
       0,   287,     0,     0,     0,    35,   288,   289,    38,    39,
      40,   290,    42,    43,    44,   291,     0,   292,   293,   294,
     207,     0,   208,   209,     0,     0,     0,     0,     0,   210,
       0,   211,     0,     0,     0,     0,     0,     0,     0,     0,
     213,     0,     0,     0,     0,   214,   215,     0,     0,     0,
       0,   216,   217,   218,   219,   220,   221,   222,     0,     0,
       0,     0,   223,   224,     0,     0,     0,     0,     0,     0,
     225,   226,   227,   228,     0,     0,     0,     0,   229,   230,
     231,   232,     0,     0,     0,   233,   234,     0,     0,     0,
       0,     0,   235,   236,     0,     0,     0,     0,     0,   237,
       0,   238,     0,   239,     0,   240,     0,   241,     0,     0,
       0,   242,     0,   243,   244,     0,   245,     0,   246,     0,
     247,   248,   249,   250,   251,   252,    16,   253,     0,   254,
     255,   256,   257,   258,   259,     0,     0,   260,     0,     0,
     261,     0,   262,   263,     0,     0,     0,   264,     0,     0,
       0,     0,     0,     0,   265,   266,   267,   268,     0,     0,
       0,   269,   270,   271,     0,   272,   273,     0,   274,   275,
       0,   276,     0,     0,    30,   277,     0,     0,   278,   279,
       0,     0,     0,     0,     0,   280,   281,   282,   283,   284,
     285,     0,     0,   286,     0,     0,     0,   287,     0,     0,
       0,    35,   288,   289,    38,    39,    40,   290,    42,    43,
      44,   291,     0,   292,   293,   294,   207,     0,   208,   209,
       0,     0,     0,     0,     0,   210,     0,   211,     0,     0,
       0,     0,     0,     0,     0,     0,   213,     0,     0,     0,
       0,   214,   215,     0,     0,     0,     0,   216,   217,   218,
     219,   220,   221,   222,     0,     0,     0,     0,   223,   224,
       0,     0,     0,     0,     0,     0,   225,   226,   227,   228,
       0,     0,     0,     0,   229,   230,   231,   232,     0,     0,
       0,   233,   234,     0,     0,     0,     0,     0,   235,   236,
       0,     0,     0,     0,     0,   237,     0,   238,     0,   239,
       0,     0,     0,   241,     0,     0,     0,   242,     0,   243,
     244,     0,   245,     0,   246,     0,   247,   248,   249,   250,
     251,   252,     0,   253,     0,   254,     0,   256,   257,   258,
     259,     0,     0,   260,     0,     0,   261,     0,   262,   263,
       0,     0,     0,   264,     0,     0,     0,     0,     0,     0,
     265,   266,   267,   268,     0,     0,     0,   269,   270,   271,
       0,   272,   273,     0,   274,   275,     0,   276,     0,     0,
      30,   277,     0,     0,   278,   279,     0,     0,     0,     0,
       0,   280,   281,   282,   283,   284,   285,     0,     0,   286,
       0,     0,     0,   287,     0,     0,     0,    35,   288,   289,
      38,    39,   116,   290,    42,    43,    44,   291,     0,   292,
     293,   294,   731,     0,   208,   209,     0,     0,     0,     0,
       0,   210,     0,   211,     0,     0,     0,     0,     0,     0,
       0,     0,   213,     0,     0,     0,     0,   214,   215,     0,
       0,     0,     0,   216,   217,   218,   219,   220,   221,   222,
       0,     0,     0,     0,   223,   224,     0,     0,     0,     0,
       0,     0,   225,     0,     0,   228,     0,     0,     0,     0,
     229,   230,   231,   232,     0,     0,     0,   233,   234,     0,
       0,     0,     0,     0,   235,   236,     0,     0,     0,     0,
       0,   237,     0,   238,     0,   239,     0,     0,     0,   241,
       0,     0,     0,   242,     0,   243,   244,     0,   245,     0,
       0,     0,   247,   248,   249,   250,   251,   252,     0,   253,
       0,   254,     0,   256,   257,   258,   259,     0,     0,   260,
       0,     0,   261,     0,   262,   263,     0,     0,     0,   264,
       0,     0,     0,     0,     0,     0,     0,   266,   267,   268,
       0,     0,     0,   269,   270,   271,     0,   272,   273,     0,
     274,   275,     0,   276,     0,     0,    30,   277,     0,     0,
     278,   279,     0,     0,     0,     0,     0,   280,   281,     0,
     283,   284,   285,     0,     0,   286,     0,     0,     0,   287,
       0,     0,     0,    35,   288,    37,     0,    39,   116,   290,
      42,    43,    44,     0,     0,   292,   293,   294,   820,     0,
     208,   209,     0,     0,     0,     0,     0,     1,     0,     2,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   214,   215,     0,     0,     0,     0,   216,
     217,   218,   219,   220,   221,   222,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   225,   226,
     227,   228,     0,     0,     0,     0,   229,   230,   231,     0,
       0,     0,     0,   233,   234,     0,     0,     0,     0,     0,
     235,   236,     0,     0,     0,     0,     0,   237,     0,     0,
       0,   239,     0,     0,     0,     0,     0,     0,     0,   242,
       0,   243,   244,     0,   245,     0,   246,     0,   247,   248,
     249,   250,   251,   252,     0,   253,     0,     0,     0,     0,
     257,     0,     0,     0,     0,   260,     0,     0,   261,     0,
     262,   263,     0,     0,     0,   264,     0,     0,     0,     0,
       0,     0,   265,   266,   267,   268,     0,     0,     0,   269,
     270,   271,     0,   272,   273,     0,   274,   275,     0,   276,
       0,     0,     0,   277,     0,     0,   278,   279,     0,     0,
       0,     0,     0,   280,   281,   282,     0,   284,   285,     0,
       0,   286,     0,     0,     0,   427,     0,   208,   209,     0,
       0,   821,    38,    39,     1,   430,     2,    43,    44,   291,
       0,   292,   293,   294,     0,     0,     0,     0,     0,     0,
     214,   215,     0,     0,     0,     0,   216,   217,   218,   219,
     220,   221,   222,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   225,     0,     0,   228,     0,
       0,     0,     0,   229,   230,   231,     0,     0,     0,     0,
     233,   234,     0,     0,     0,     0,     0,   235,   236,     0,
       0,     0,     0,     0,   237,     0,     0,     0,   239,   428,
       0,     0,     0,     0,     0,     0,   242,     0,   243,   244,
       0,   245,     0,     0,     0,   247,   248,   249,   250,   251,
     252,     0,   253,     0,     0,     0,     0,   257,     0,     0,
       0,     0,   260,     0,     0,   261,     0,   262,   263,     0,
       0,     0,   264,     0,     0,     0,     0,     0,     0,     0,
     266,   267,   268,     0,     0,     0,   269,   270,   271,     0,
     272,   273,     0,   274,   275,     0,   276,     0,     0,     0,
     277,     0,     0,   278,   279,     0,     0,     0,     0,     0,
     280,   281,     0,     0,   284,   285,   429,   427,   286,   208,
     209,   645,     0,     0,     0,   646,     1,     0,     2,     0,
      39,     0,   430,     0,    43,    44,     0,     0,   292,   293,
     294,     0,   214,   215,     0,     0,     0,     0,   216,   217,
     218,   219,   220,   221,   222,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   225,     0,     0,
     228,     0,     0,     0,     0,   229,   230,   231,     0,     0,
       0,     0,   233,   234,     0,     0,     0,     0,     0,   235,
     236,     0,     0,     0,     0,     0,   237,     0,     0,     0,
     239,     0,     0,     0,     0,     0,     0,     0,   242,     0,
     243,   244,     0,   245,     0,     0,     0,   247,   248,   249,
     250,   251,   252,     0,   253,     0,     0,     0,     0,   257,
       0,     0,     0,     0,   260,     0,     0,   261,     0,   262,
     263,     0,     0,     0,   264,     0,     0,     0,     0,     0,
       0,     0,   266,   267,   268,     0,     0,     0,   269,   270,
     271,     0,   272,   273,     0,   274,   275,     0,   276,     0,
       0,     0,   277,     0,     0,   278,   279,     0,     0,     0,
       0,     0,   280,   281,     0,     0,   284,   285,     0,   427,
     286,   208,   209,   532,     0,     0,     0,     0,     1,     0,
       2,     0,    39,     0,   430,     0,    43,    44,     0,     0,
     292,   293,   294,     0,   214,   215,     0,     0,     0,     0,
     216,   217,   218,   219,   220,   221,   222,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   225,
       0,     0,   228,     0,     0,     0,     0,   229,   230,   231,
       0,     0,     0,     0,   233,   234,     0,     0,     0,     0,
       0,   235,   236,     0,     0,     0,     0,     0,   237,     0,
       0,     0,   239,   847,     0,     0,     0,     0,     0,     0,
     242,     0,   243,   244,   121,   245,   122,     0,     0,   247,
     248,   249,   250,   251,   252,     0,   253,     0,   124,     0,
       0,   257,     0,     0,     0,     0,   260,     0,     0,   261,
       0,   262,   263,     0,     7,     0,   264,     0,     0,     0,
     128,     0,     0,     0,   266,   267,   268,     0,     0,     0,
     269,   270,   271,     0,   272,   273,     0,   274,   275,     0,
     276,     0,     0,     0,   277,     0,     0,   278,   279,    15,
       0,     0,   133,     0,   280,   281,   134,     0,   284,   285,
       0,   427,   286,   208,   209,   136,     0,     0,     0,   646,
       1,     0,     2,     0,    39,     0,   430,     0,    43,    44,
       0,     0,   292,   293,   294,   139,   214,   215,     0,     0,
     140,     0,   216,   217,   218,   219,   220,   221,   222,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   143,
       0,   225,     0,     0,   228,     0,     0,     0,     0,   229,
     230,   231,     0,     0,     0,     0,   233,   234,     0,     0,
       0,     0,     0,   235,   236,     0,     0,     0,     0,     0,
     237,     0,     0,     0,   239,     0,     0,     0,     0,     0,
       0,     0,   242,     0,   243,   244,     0,   245,     0,     0,
       0,   247,   248,   249,   250,   251,   252,     0,   253,     0,
       0,     0,     0,   257,     0,     0,     0,     0,   260,     0,
       0,   261,     0,   262,   263,     0,     0,     0,   264,     0,
       0,     0,     0,     0,     0,     0,   266,   267,   268,     0,
       0,     0,   269,   270,   271,     0,   272,   273,     0,   274,
     275,     0,   276,     0,     0,     0,   277,     0,     0,   278,
     279,     0,     0,     0,     0,     0,   280,   281,     0,     0,
     284,   285,     0,   427,   286,   208,   209,     0,     0,     0,
       0,     0,     1,     0,     2,     0,    39,     0,   430,     0,
      43,    44,     0,     0,   292,   293,   294,     0,   214,   215,
       0,     0,     0,     0,   216,   217,   218,   219,   220,   221,
     222,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   225,     0,     0,   228,     0,     0,     0,
       0,   229,   230,   231,     0,     0,     0,     0,   233,   234,
       0,     0,     0,     0,     0,   235,   236,     0,     0,     0,
       0,     0,   237,     0,     0,     0,   239,     0,     0,     0,
       0,     0,     0,     0,   242,     0,   243,   244,     0,   245,
       0,     0,     0,   247,   248,   249,   250,   251,   252,     0,
     253,     0,     0,     0,     0,   257,     0,     0,     0,     0,
     260,     0,     0,   261,     0,   262,   263,     0,     0,     0,
     264,     0,     0,     0,     0,     0,     0,     0,   266,   267,
     268,     0,     0,     0,   269,   270,   271,     0,   272,   273,
       0,   274,   275,     0,   276,     0,     0,     0,   277,     0,
       0,   278,   279,     0,     0,     0,     0,     0,   280,   281,
       0,     0,   284,   285,   427,     0,   286,     0,   601,   602,
       0,     0,     0,     1,     0,     2,     0,     0,    39,     0,
     430,     0,    43,    44,     0,     0,   292,   293,   294,   214,
     215,     0,     0,     0,     0,   216,   217,   218,   219,   220,
     221,   222,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   225,     0,     0,   228,     0,     0,
       0,     0,   229,   230,   231,     0,     0,     0,     0,   233,
     234,     0,     0,     0,     0,     0,   235,   236,     0,     0,
       0,     0,     0,   237,     0,     0,     0,   239,     0,     0,
       0,     0,     0,     0,     0,   242,     0,   243,   244,     0,
     245,     0,     0,     0,   247,   248,   249,   250,   251,   252,
       0,   253,     0,     0,     0,     0,   257,     0,     0,     0,
       0,   260,     0,     0,   261,     0,   262,   263,     0,     0,
       0,   264,     0,     0,     0,     0,     0,     0,     0,   266,
     267,   268,     0,     0,     0,   269,   270,   271,     0,   272,
     273,     0,   274,   275,     0,   276,     0,     0,     0,   277,
       0,     0,   278,   279,     0,     0,     0,     0,     0,   280,
     281,     0,     0,   284,   285,   427,     0,   286,     0,     0,
       0,     0,     0,     0,     1,     0,     2,     0,     0,    39,
       0,   430,     0,    43,    44,     0,     0,   292,   293,   294,
     214,   215,     0,     0,     0,     0,   216,   217,   218,   219,
     220,   221,   222,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   225,     0,     0,   228,     0,
       0,     0,     0,   229,   230,   231,     0,     0,     0,     0,
     233,   234,     0,     0,     0,   228,     0,   235,   236,     0,
       0,     0,   231,     0,   237,     0,     0,     0,   239,     0,
       0,     0,     0,     0,   235,   236,   242,     0,   243,   244,
       0,   245,     0,     0,     0,   247,   248,   249,   250,   251,
     252,     0,   253,     0,     0,   740,     0,   257,     0,     0,
       0,     0,   260,     0,     1,   261,     2,   262,   263,     0,
       0,     0,   264,     0,     0,     0,     0,     0,     0,   260,
     266,   267,   268,     0,   262,   263,   269,   270,   271,     0,
     272,   273,     0,   274,   275,     0,   276,   223,   267,     0,
     277,     0,     0,   278,   279,     0,   226,     0,     0,     0,
     280,   281,     0,   620,   284,   285,   232,     0,   286,     0,
       0,     0,   621,     0,   622,     0,     0,     0,     0,     0,
      39,     0,   430,   213,    43,    44,   238,     0,   292,   293,
     294,     0,   241,    35,    36,    37,     0,    39,   116,    41,
      42,    43,    44,     0,     0,   223,   224,     0,     0,     0,
       0,    16,     0,     0,     0,     0,   256,     0,   258,   259,
       0,   620,     0,     0,   232,     0,     0,   715,     0,     0,
     621,     0,   622,     0,     0,     0,     0,     0,     0,     0,
       0,   213,   620,     0,   238,     0,     0,     0,     0,     0,
     241,   621,     0,   622,     0,     0,     0,     0,     0,    30,
       0,     0,     0,   223,   224,     0,     0,     0,     0,     0,
       0,     0,   254,   283,   256,     0,   258,   259,     0,     0,
       0,     0,   232,     0,   223,   224,    35,     0,     0,    38,
      39,     0,     0,    42,    43,    44,   291,     0,   292,   293,
     294,     0,   238,   232,     0,     0,     0,     0,   241,     0,
       0,     0,     0,     0,     0,     0,     0,    30,     0,     0,
       0,     0,     0,   238,     0,     0,     0,     0,     0,   241,
     254,   283,   256,     0,   258,   259,     0,     0,     0,     0,
     287,     0,     0,     0,    35,   288,    37,     0,    39,   116,
      41,    42,   689,   256,     0,   258,   259,     0,     0,     0,
       0,   621,     0,   622,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    30,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   283,
       0,     0,     0,     0,   223,   224,    30,     0,   287,     0,
       0,     0,    35,   288,    37,     0,    39,   116,    41,    42,
     283,     0,     0,   232,     0,     0,     0,     0,     0,   287,
       0,     0,     0,    35,   288,    37,     0,    39,   116,    41,
      42,     0,     0,   238,     0,     0,     0,     0,     0,   241,
       0,     0,     0,     0,     1,     0,     2,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   256,     0,   258,   259,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   223,     0,     0,
       0,     0,     0,     0,     0,     0,   226,     0,   228,     0,
       0,     0,     0,     0,     0,   231,   232,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    30,   235,   236,     0,
       0,     0,     0,     0,     0,     0,   238,     0,     0,     0,
     283,     0,   241,     0,     0,     0,     0,     0,     0,   287,
       0,     0,     0,    35,   288,    37,     0,    39,   116,    41,
      42,    16,     0,     0,     0,     0,   256,     0,   258,   259,
       0,     0,   260,     0,     0,     0,     0,   262,   263,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   267,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    30,
       0,     0,     0,     0,     1,     0,     2,     0,     0,     0,
       3,     0,     0,   283,     0,     0,     0,     0,     0,     4,
       0,     0,     0,     0,     0,     0,    35,    36,    37,    38,
      39,   116,    41,    42,    43,    44,   291,     0,   292,   293,
     294,     5,     6,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     7,     0,     0,     0,     0,     8,     0,     0,
       0,     0,     9,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    10,     0,     0,     0,    11,     0,     0,
      12,    13,     0,    14,     0,     0,     0,    15,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    16,     0,     0,     0,     0,     0,     0,    17,    18,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    19,
      20,     0,     0,     0,    21,    22,    23,    24,     0,     0,
       0,     0,     0,    25,    26,    27,     0,     0,     0,    28,
       0,     0,     0,     0,     0,     0,     0,     0,    29,    30,
       1,     0,     2,     0,     0,     0,     3,    31,     0,     0,
       0,     0,     0,     0,     0,     4,     0,    32,     0,    33,
       0,    34,     0,     0,     0,     0,    35,    36,    37,    38,
      39,    40,    41,    42,    43,    44,     0,     5,     6,     0,
       0,     0,     0,     0,     1,   472,     2,     0,     0,     0,
       0,     0,     0,     8,     0,     0,     0,     0,     9,     0,
       0,     0,   473,     0,     0,     0,     0,     0,     0,    10,
       0,     0,     0,    11,     0,     0,    12,    13,     0,    14,
       0,     0,     0,     0,     0,     0,     0,     0,   228,     0,
       0,     0,     0,     0,     0,   231,     0,    16,     0,     0,
       0,     0,     0,     0,    17,    18,     0,   235,   236,     0,
       0,     0,     0,     0,     0,    19,    20,     0,     0,     0,
      21,    22,    23,    24,     0,     0,     0,     0,     0,    25,
      26,    27,     1,     0,     2,    28,     0,     0,     3,     0,
       0,    16,     0,     0,    29,    30,     0,     4,     0,     0,
       0,     0,   260,    31,     0,     0,     0,   262,   263,     0,
       0,     0,     0,    32,     0,    33,     0,    34,     0,     5,
       6,   267,    35,    36,    37,    38,    39,    40,    41,    42,
      43,    44,     0,     0,     0,     0,     0,     0,     0,    30,
       9,     0,     0,   401,     0,     0,     0,     0,     0,     0,
       0,    10,     0,     0,     0,    11,     0,     0,    12,    13,
       0,    14,     0,     0,     0,     0,    35,    36,    37,    38,
      39,   116,    41,    42,    43,    44,     0,     0,     0,    16,
       0,     0,     0,     0,     0,     0,    17,    18,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    19,    20,     0,
       0,     0,    21,     0,    23,    24,     0,     0,     0,     0,
       0,    25,    26,    27,     1,     0,     2,    28,     0,     0,
       3,     0,     0,     0,     0,     0,     0,    30,     0,     4,
       0,     0,     0,     0,   402,    31,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    32,     0,    33,     0,    34,
       0,     5,     6,     0,    35,    36,    37,    38,    39,    40,
      41,    42,    43,    44,     0,     0,     0,     0,     0,     0,
       0,     0,     9,     0,     0,   401,     0,     0,     0,     0,
       0,     0,     0,    10,     0,   392,     0,    11,     0,     0,
       0,    13,     0,    14,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    16,     0,     0,     0,     0,     0,     0,    17,    18,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    19,
      20,     0,     0,     0,    21,     0,    23,    24,     0,     0,
       0,     0,     0,    25,    26,    27,     0,     0,     0,    28,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    30,
       1,     0,     2,     0,     0,   393,     3,    31,     0,     0,
       0,     0,     0,     0,     0,     4,     0,   394,     0,    33,
       0,    34,     0,     0,     0,     0,    35,    36,    37,    38,
      39,   116,    41,    42,    43,    44,     0,     5,     6,     0,
       0,     0,     0,     0,     0,   472,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     9,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    10,
       0,   392,     0,    11,     0,     0,     0,    13,     0,    14,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    16,     0,     0,
       0,     0,     0,     0,    17,    18,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    19,    20,     0,     0,     0,
      21,     0,    23,    24,     0,     0,     0,     0,     0,    25,
      26,    27,     1,     0,     2,    28,     0,     0,     3,     0,
       0,     0,     0,     0,     0,    30,     0,     4,     0,     0,
       0,   393,     0,    31,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   394,     0,    33,     0,    34,     0,     5,
       6,     0,    35,    36,    37,    38,    39,   116,    41,    42,
      43,    44,     0,     0,     0,     0,     0,     0,     0,     0,
       9,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    10,     0,   392,     0,    11,     0,     0,     0,    13,
       0,    14,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    16,
       0,     0,     0,     0,     0,     0,    17,    18,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    19,    20,     0,
       0,     0,    21,     0,    23,    24,     0,     0,     0,     0,
       0,    25,    26,    27,     0,     0,     0,    28,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    30,     1,     0,
       2,     0,     0,   393,     3,    31,     0,     0,     0,     0,
       0,     0,     0,     4,     0,   394,     0,    33,     0,    34,
       0,     0,     0,     0,    35,    36,    37,    38,    39,   116,
      41,    42,    43,    44,     0,     5,     6,     0,     0,     0,
       0,     0,     0,   472,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     9,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    10,     0,     0,
       0,    11,     0,     0,    12,    13,     0,    14,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    16,     0,     0,     0,     0,
       0,     0,    17,    18,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    19,    20,     0,     0,     0,    21,     0,
      23,    24,     0,     0,     0,     0,     0,    25,    26,    27,
       1,     0,     2,    28,     0,     0,     3,     0,     0,     0,
       0,     0,     0,    30,     0,     4,     0,     0,     0,     0,
       0,    31,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    32,     0,    33,     0,    34,     0,     5,     6,     0,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
       0,     0,     0,     0,     0,     0,     0,     0,     9,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    10,
       0,     0,     0,    11,     0,     0,    12,    13,     0,    14,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    16,     0,     0,
       0,     0,     0,     0,    17,    18,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    19,    20,     0,     0,     0,
      21,     0,    23,    24,     0,     0,     0,     0,     0,    25,
      26,    27,     1,     0,     2,    28,     0,     0,     3,     0,
       0,     0,     0,     0,     0,    30,     0,     4,     0,     0,
       0,     0,     0,    31,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   372,     0,    33,     0,    34,     0,     5,
       6,     0,    35,    36,    37,    38,    39,    40,    41,    42,
      43,    44,     0,     0,     0,     0,     0,     0,     0,     0,
       9,     0,     0,   401,     0,     0,     0,     0,     0,     0,
       0,    10,     0,     0,     0,    11,     0,     0,     0,    13,
       0,    14,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    16,
       0,     0,     0,     0,     0,     0,    17,    18,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    19,    20,     0,
       0,     0,    21,     0,    23,    24,     0,     0,     0,     0,
       0,    25,    26,    27,     0,     0,     0,    28,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    30,     1,     0,
       2,     0,     0,     0,     3,    31,     0,     0,     0,     0,
       0,     0,     0,     4,     0,   372,     0,    33,     0,    34,
       0,     0,     0,     0,    35,    36,    37,    38,    39,   116,
      41,    42,    43,    44,     0,     5,     6,     0,     0,     0,
       0,     0,     0,   472,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     9,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    10,     0,     0,
       0,    11,     0,     0,     0,    13,     0,    14,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    16,     0,     0,     0,     0,
       0,     0,    17,    18,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    19,    20,     0,     0,     0,    21,     0,
      23,    24,     0,     0,     0,     0,     0,    25,    26,    27,
       1,     0,     2,    28,     0,     0,     3,     0,     0,     0,
       0,     0,     0,    30,     0,     4,     0,     0,     0,     0,
       0,    31,     0,     0,     1,     0,     2,     0,     0,     0,
       0,   372,     0,    33,     0,    34,     0,     5,     6,     0,
      35,    36,    37,    38,    39,   116,    41,    42,    43,    44,
       0,     0,     0,     0,     0,     0,     0,     0,     9,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   228,    10,
       0,     0,     0,    11,     0,   231,     0,    13,     0,    14,
       0,     0,     0,     0,     0,     0,     0,   235,   236,     0,
       0,     0,     0,     0,     0,     0,     0,    16,     0,     0,
       0,     0,     0,     0,    17,    18,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    19,    20,     0,     0,     0,
      21,    16,    23,    24,     0,   842,     0,     0,     0,    25,
      26,    27,   260,     0,     0,    28,     0,   262,   263,     0,
       0,     0,     0,     0,     0,    30,     0,     0,     0,     0,
       0,   267,     0,    31,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   372,     0,    33,     0,    34,     0,    30,
       0,     0,    35,    36,    37,    38,    39,   116,    41,    42,
      43,    44,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    35,    36,    37,    38,
      39,   116,    41,    42,    43,    44,   121,     0,   122,     0,
       0,     0,     0,     0,     0,     0,     0,   123,     0,     0,
     124,     0,   125,   126,     0,     0,     0,     0,     0,     0,
       0,   127,     0,     0,     0,     0,     7,     0,     0,     0,
       0,     0,   128,     0,     0,     0,     0,   129,     0,     0,
       0,     0,     0,     0,   130,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   131,     0,     0,     0,     0,     0,
       0,    15,   132,     0,   133,     0,     0,     0,   134,     0,
     135,     0,     0,     0,     0,     0,     0,   136,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   137,     0,
     138,     0,     0,     0,     0,     0,     0,   139,     0,     0,
       0,     0,   140,     0,     0,     0,   141,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   142,     0,     0,     0,
       0,   143,     0,     0,     0,     0,     0,     0,     0,   144,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   145,     0,     0,     0,     0,   121,     0,   122,
      35,   146,   147,    38,   148,   149,   150,   151,   123,    44,
       0,   124,     0,   125,   126,     0,     0,     0,     0,     0,
       0,     0,   127,     0,     0,     0,     0,     7,     0,     0,
       0,     0,     0,   128,   121,     0,   122,     0,   129,     0,
       0,     0,     0,     0,     0,   130,     0,     0,   124,     0,
     125,   126,     0,     0,     0,   131,     0,     0,     0,   127,
       0,     0,    15,   132,     7,   133,     0,     0,     0,   134,
     128,   135,     0,     0,     0,   129,     0,     0,   136,     0,
       0,     0,   130,     0,     0,     0,     0,     0,     0,   137,
       0,   138,   522,     0,     0,     0,     0,     0,   139,    15,
     132,     0,   133,   140,     0,     0,   134,   141,   135,     0,
       0,     0,     0,     0,     0,   136,     0,   142,     0,     0,
       0,     0,   143,     0,     0,     0,   523,     0,     0,     0,
     144,   121,     0,   122,     0,   139,     0,     0,     0,     0,
     140,     0,     0,   145,   141,   124,     0,   125,   126,     0,
       0,     0,     0,     0,   142,    39,   127,     0,     0,   143,
       0,     7,     0,     0,     0,     0,     0,   128,     0,     0,
       0,     0,   129,     0,     0,     0,     0,     0,     0,   130,
     145,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    39,     0,     0,     0,    15,   132,     0,   133,
       0,     0,     0,   134,     0,   135,     0,     0,     0,     0,
       0,     0,   136,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   139,     0,     0,     0,     0,   140,     0,     0,
       0,   141,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   142,     0,     0,     0,     0,   143,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   145,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    39
};

static const yytype_int16 yycheck[] =
{
       0,     8,     2,   322,    77,     5,   386,     1,   385,   158,
     183,    91,    50,   151,    24,    69,   101,    91,   318,   170,
     368,    80,     8,    23,    24,    25,    91,    27,    28,   100,
     520,    91,    88,    69,   172,    58,    67,   298,   299,   150,
      63,    79,   301,   397,   155,    76,   649,     0,   632,   171,
      50,    76,   380,    91,   382,   383,   384,    12,   362,    21,
      83,    69,   853,    27,    28,    29,     6,    67,    68,    69,
      80,     8,     9,    15,    74,    17,    76,    91,    78,    79,
      80,   381,     5,    93,    74,   191,    86,    21,     5,    23,
      23,    91,    92,    93,    94,   196,    96,    50,   597,    21,
      23,     5,     4,   167,    23,    45,     8,   107,    25,   109,
      69,   111,   112,    19,    67,    68,    21,    48,    34,    23,
      22,    74,   168,    76,     6,    78,    79,     4,    33,   183,
     629,    69,     8,     9,    21,   719,    67,     4,    91,    92,
      21,    94,    21,    96,    21,   635,   937,   183,    95,    25,
     170,    27,    28,    29,   107,    36,   109,     0,   111,   112,
     170,    28,    93,   153,   171,    21,    82,    54,     0,    86,
     170,   207,     5,    80,    91,   183,   553,   191,   192,    55,
     180,     4,   973,   183,     0,   171,   117,   121,   121,    95,
      23,    23,    83,    70,     6,    27,    28,     0,   121,   316,
       8,     9,   121,    90,   377,    28,   344,   207,    25,    21,
     210,   211,   329,   195,   196,   162,   210,   121,    50,     0,
     184,   185,   186,   345,   183,   167,   188,   189,   576,   191,
     192,   193,    19,   170,   139,    67,    68,   591,    55,     6,
      27,   132,    74,    51,    76,   183,    78,    79,   207,   191,
     169,    94,   855,   195,   196,   609,   162,   210,   211,    91,
      92,    24,    94,   380,    96,   382,   188,   189,     6,   171,
     192,   193,     5,    36,   628,   107,   630,   109,    94,   111,
     112,    19,   362,     6,   632,   240,    67,    68,   121,    80,
     177,    94,    25,    74,   181,    76,     6,    78,   177,     6,
     177,   678,   181,    68,   181,    15,    46,    17,   184,   185,
     186,    92,    77,    94,     0,   466,   326,   191,   318,   619,
     194,   905,    55,   377,   362,   363,   326,   631,     4,   367,
       8,     9,   188,   189,   595,   596,   192,   193,   345,   600,
     977,   377,   601,   602,   375,    21,   346,     6,   348,   677,
     375,   988,   936,    80,    21,   365,    96,   847,   848,   345,
     370,   368,   362,   363,   423,   365,   366,   367,    46,   377,
     370,   136,     8,   404,   368,   375,    12,   377,    45,   404,
     120,   381,   368,   421,   124,   523,     8,   525,   444,     4,
      12,   465,    78,    29,   159,   402,    19,   397,    21,    11,
     465,    19,     6,    21,   404,   465,    21,    19,    94,   362,
     363,   522,   497,   423,   367,   425,   402,    21,   377,    62,
       4,   421,   375,   423,   495,   425,   187,   465,   428,   346,
     191,   124,     4,     8,     9,    67,    68,    21,   438,   377,
       6,    45,    74,   345,   475,   362,    21,   447,    91,    21,
     475,   404,   516,   517,   518,   519,   466,     8,     9,     4,
      92,    19,   579,    14,   100,   465,   466,   191,   421,   428,
       0,   195,   196,     6,    25,   475,    21,   477,   100,   438,
     526,   191,   125,   547,   127,   195,   196,   835,   447,   199,
     200,    11,   177,   199,   200,    96,   181,   874,   544,    19,
     402,    21,   882,   503,    55,   505,   107,   507,   109,   509,
     111,   112,   465,    22,   150,     6,   689,    11,     6,   155,
      50,   528,   475,   137,   477,    19,   162,   550,   150,    21,
     362,   363,   146,   155,   834,   367,   150,    67,    68,    11,
     162,   112,   528,   375,    74,   116,    76,    19,    78,    79,
     503,   631,   505,   881,   507,     5,   509,   905,     8,     9,
     677,    91,    92,    28,    94,   619,    96,     4,     5,    21,
       8,     9,   404,     8,     9,    25,    14,   107,     4,   109,
      21,   111,   112,    16,    21,    22,    21,    25,   363,   421,
     636,   591,   367,   631,   375,     8,     9,   597,   859,   860,
       8,     9,   188,   189,   240,    55,   192,   193,    11,   609,
     618,     6,    25,    21,   614,   934,     6,    55,   618,   619,
     620,   621,   622,   404,     6,   632,   528,    11,   628,   629,
     630,   631,     0,   465,    18,   689,   659,     6,   632,   693,
       6,   695,    55,   475,   170,   477,   632,   549,    11,     9,
     180,     8,     9,   689,   690,    18,     6,   693,     4,   695,
     698,   620,   188,   189,    21,   191,   192,   193,   621,   622,
     701,   503,   574,   505,     6,   507,   701,   509,   631,    21,
     688,   689,    50,     8,     9,   693,     4,   695,   688,   689,
     690,   112,   692,   693,   475,   695,    21,     9,   698,    67,
      68,   701,    12,    13,   853,    21,    74,    21,    76,   187,
      78,    79,    21,   191,   631,   832,   747,   195,   196,     0,
     720,    21,   747,    91,    92,   719,    94,    21,    96,    21,
     689,   731,   368,     8,     9,   781,   782,     4,     5,   107,
       6,   109,    21,   111,   112,   698,     5,   747,   701,     8,
       9,   689,    51,   691,    11,   693,   873,   695,     4,   876,
       4,     5,     4,     5,   881,    11,   402,     5,     7,    50,
       8,     9,   731,    19,    91,     5,     4,     5,     8,     9,
     402,     6,    28,     6,   820,     6,    67,    68,   937,     4,
       5,   477,     6,    74,   747,    76,     6,    78,    79,   631,
     794,   188,   189,   720,   191,   192,   193,     4,     5,    21,
      91,    92,   885,    94,     6,    96,     6,   503,   348,   505,
     820,   507,   197,   509,     4,     5,   107,   813,   109,     6,
     111,   112,   362,   363,   834,    19,   107,   367,   109,   187,
     111,   112,   190,   191,   746,   375,   194,   195,   196,   835,
       4,     5,   862,     5,   864,     6,     8,     9,     6,   495,
       4,     5,   862,     6,   864,   865,   698,     5,     5,   701,
       8,     9,   189,   495,   404,   511,   477,     6,   514,     6,
      49,    50,   199,   200,     5,    21,   522,     8,     9,    58,
      75,   421,   187,   188,   189,   190,   191,   192,   193,   194,
     522,   196,   503,     6,   505,    74,   507,     6,   509,    24,
       5,   905,    81,     8,     9,   747,     4,     5,     5,   905,
     701,     8,     9,     5,   962,     6,     8,     9,    69,   936,
      99,     6,   970,     5,    11,   465,     8,     9,   107,     6,
     576,     6,   936,   981,    85,   475,     5,   477,     6,     8,
       9,     6,    93,    25,    69,    27,    28,    29,     4,     5,
       4,     5,   962,     4,     5,    80,   747,     4,     5,   135,
     970,     4,     5,   503,   143,   505,    21,   507,    93,   509,
       5,   981,     4,    55,   153,     4,     5,    21,    86,    21,
       6,    49,    50,    21,   362,   363,   632,    45,    21,   367,
      58,    21,     5,    21,    21,   199,     5,   375,    21,   962,
     179,    11,   159,     4,    21,    21,    74,   970,   159,     5,
       5,    11,   191,    81,   198,    18,   167,   929,   981,   170,
     347,   348,    16,    11,     5,    11,   404,    19,   179,     6,
       5,    99,   183,     5,    21,   186,   170,    20,   170,   107,
       5,    21,    21,   421,    25,   170,    27,    28,    29,    11,
      21,    21,    21,    21,    21,    21,   207,    21,   183,     5,
      21,     5,    25,    21,    27,    28,    29,     5,     4,     6,
       5,   362,   363,   719,    55,   143,   367,     5,    75,    28,
       6,     5,   207,     5,   375,   153,     0,   465,    11,    20,
      24,   631,    55,     5,     5,    20,    10,   475,     5,   477,
     170,     6,   184,   185,   186,    21,    21,    21,     5,   402,
      20,   179,    15,   404,    17,   187,    20,   162,   190,   191,
     962,   193,   194,   191,   196,   503,    21,   505,   970,   507,
     421,   509,   528,   606,   865,    69,   304,   614,   465,   981,
     385,   227,   693,   695,   981,    78,    80,   421,   794,   365,
     423,   185,   444,    67,    68,   391,     0,   465,   698,    93,
      74,   701,    76,    12,    78,    12,    12,   813,    47,   499,
      -1,   478,    51,    52,   465,    54,    -1,    56,    92,    -1,
      94,    -1,    96,    20,   475,    -1,   477,    -1,    -1,   835,
      -1,    -1,    -1,   107,    -1,   109,    -1,   111,   112,    -1,
     351,   326,    -1,   184,   185,   186,    -1,   747,    -1,   112,
      -1,    48,   503,    -1,   505,   366,   507,    -1,   509,    -1,
      -1,   184,   185,   186,    -1,    -1,   377,   187,   188,   189,
      67,   191,   192,   193,   194,    -1,   170,    74,    -1,   118,
     365,   366,    -1,    -1,    -1,   370,   397,    -1,    -1,   183,
      -1,    -1,   377,   631,    -1,   296,    93,   160,    -1,   905,
      -1,    -1,   589,    -1,    -1,     0,    -1,    -1,    -1,    -1,
      -1,    -1,   397,    -1,    -1,   426,   427,    21,   429,    -1,
     117,   195,    -1,    -1,   187,   436,   437,   190,   191,    -1,
     936,   194,   195,   196,    -1,    -1,   447,    -1,   423,   626,
     425,    -1,    -1,    -1,    -1,    49,    50,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    58,   466,   153,    -1,   197,   198,
     698,    -1,    -1,   701,    -1,    -1,    -1,    -1,    -1,    -1,
      74,    -1,    67,    68,    69,    -1,    -1,   378,    -1,    74,
     631,   466,    -1,    78,    -1,   224,    -1,    -1,   227,    -1,
      -1,    -1,    -1,    -1,    -1,    99,    -1,    92,    -1,    94,
      -1,    96,    -1,   107,    -1,   516,   517,   518,   519,   747,
      -1,    -1,   107,    -1,   109,    -1,   111,   112,    -1,    -1,
      -1,    59,    -1,    -1,    -1,    -1,    -1,    -1,    66,    -1,
     431,    -1,   326,    -1,    -1,    -1,   547,    -1,    -1,   143,
      78,    79,    -1,    -1,    -1,    -1,    -1,   698,    -1,   153,
     701,    -1,    -1,    -1,    -1,    -1,   295,    -1,    -1,    -1,
      -1,   462,   962,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     970,   365,   366,   312,    -1,   179,   370,    -1,    -1,    -1,
     591,   981,    -1,   377,    -1,   123,   597,   191,   183,    -1,
     128,   129,    -1,    -1,    -1,   296,   747,    -1,   609,    -1,
      -1,   375,   341,   397,   142,    -1,   591,    -1,    -1,    -1,
      -1,    -1,   597,    -1,    -1,    -1,    -1,   628,   629,   630,
      -1,    -1,    -1,    -1,   609,    -1,    -1,   401,   639,   423,
     404,   425,   533,    -1,    -1,    -1,    -1,    -1,   649,    -1,
      -1,    -1,    59,   628,   629,   630,    -1,   548,    -1,    66,
      -1,    -1,   190,   191,    -1,    -1,   557,   195,   196,    -1,
      -1,    78,    79,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   466,    -1,   685,    -1,   577,   378,   689,   690,
      -1,    -1,   693,    -1,   695,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   704,   705,   706,   707,   708,   472,    -1,
      -1,   475,    -1,   477,   689,   690,   123,    -1,   693,    -1,
     695,   128,   129,    -1,   725,    -1,    -1,    -1,   729,   730,
     731,    -1,    -1,    -1,   962,   142,    -1,    -1,    -1,   503,
     431,   505,   970,   507,    59,   509,    -1,    -1,    -1,    -1,
     514,    66,    -1,   981,    -1,    -1,   647,    -1,    -1,    -1,
     651,    -1,    -1,    78,    79,    -1,    -1,    -1,    -1,    -1,
      -1,   462,   663,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   510,    -1,   512,   191,   676,    -1,    -1,   195,   196,
      -1,    -1,   377,    -1,    -1,   796,    -1,   798,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   591,   123,    -1,
      -1,    -1,    -1,   128,   129,    -1,    -1,    -1,    -1,   820,
      -1,   962,   713,   714,    -1,   609,   717,   142,    -1,   970,
      -1,   722,   723,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     981,   732,   533,    -1,   628,   820,   630,    -1,    -1,    -1,
     851,    -1,    -1,   854,   855,    -1,    -1,   548,    -1,    -1,
      -1,    -1,    -1,    -1,   865,    -1,   557,    -1,   632,    -1,
      -1,    -1,   187,   188,   189,   190,   191,   192,   193,   194,
     195,   196,    -1,    -1,    -1,    -1,   577,   862,    -1,   864,
     865,    -1,   477,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    22,    -1,   689,    -1,   691,    -1,   693,
      -1,   695,    -1,    -1,    33,    -1,    35,    -1,   503,    -1,
     505,    -1,   507,    -1,   509,    -1,    -1,    -1,    47,    -1,
      -1,   822,    -1,    -1,    -1,    -1,    -1,   701,    -1,    -1,
     669,   670,   671,   672,    63,    15,    -1,    17,   839,    -1,
      69,    21,    -1,    -1,    -1,    -1,   647,    -1,    -1,   850,
     651,    -1,    33,    -1,    35,   856,    -1,    -1,    -1,    -1,
     971,    -1,   663,    -1,    -1,    -1,    47,    -1,    -1,    98,
      -1,   872,   101,   747,   875,   676,   105,    -1,    -1,   990,
      -1,    61,    63,    -1,    15,   114,    17,    -1,    69,   890,
     891,   892,   893,   894,    -1,    -1,    -1,    -1,    -1,    -1,
      81,   902,   903,   904,    -1,   134,    -1,    -1,    -1,    -1,
     139,    -1,   713,   714,    -1,    -1,   717,    98,    -1,    -1,
     101,   722,   723,   103,   105,    -1,   927,   928,    -1,   158,
      61,   732,   112,   114,    -1,   774,    -1,    -1,    -1,    -1,
      -1,    -1,   122,    -1,    -1,    -1,    -1,    -1,   949,    -1,
      -1,    -1,   953,   134,    -1,    -1,    -1,    -1,   139,    -1,
      -1,   835,    -1,    -1,    -1,    -1,    -1,    -1,   862,    -1,
     864,   865,   103,   812,    -1,   814,   156,   158,    -1,    -1,
     160,   112,    -1,   163,    -1,   986,    -1,    -1,    -1,    -1,
      -1,   122,    -1,   994,   689,    -1,    -1,   692,   693,    -1,
     695,    -1,    -1,    -1,    33,   844,    35,   187,    -1,    -1,
     190,   191,    -1,    -1,   194,   195,   196,    -1,    47,    -1,
      -1,   822,    -1,    -1,    -1,   156,    -1,     0,    -1,   160,
      -1,   905,   163,    -1,    63,    -1,    -1,    -1,   839,    -1,
      69,    -1,    15,    -1,    17,    -1,    -1,    -1,    21,   850,
      -1,    -1,    -1,    -1,    -1,   856,   187,    30,    -1,   190,
     191,    -1,    -1,   194,   195,   196,    -1,    -1,    -1,    98,
      -1,   872,   101,    -1,   875,    -1,   105,    -1,    -1,    52,
      53,    -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,   890,
     891,   892,   893,   894,    -1,    68,    -1,    -1,    -1,    -1,
      73,   902,   903,   904,    -1,   134,    -1,    -1,    -1,    -1,
     139,    84,    -1,    -1,    -1,    88,    -1,    -1,    91,    92,
      -1,    94,    -1,    -1,    -1,    -1,   927,   928,    -1,   158,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   112,
      -1,    -1,    -1,    -1,    -1,    -1,   119,   120,   949,    -1,
      -1,    -1,   953,    -1,    -1,    -1,    -1,   130,   131,    -1,
      -1,    -1,   135,   136,   137,   138,    -1,    -1,    -1,    -1,
      -1,   144,   145,   146,    -1,    -1,    -1,   150,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   986,   159,   160,    -1,    -1,
      -1,    -1,    -1,   994,    -1,   168,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   178,    -1,   180,    -1,   182,
      -1,    -1,    -1,    -1,   187,   188,   189,   190,   191,   192,
     193,   194,   195,   196,     6,    -1,     8,     9,    -1,    -1,
      -1,    -1,    -1,    15,    -1,    17,    -1,    -1,    -1,    21,
      -1,    -1,    -1,    -1,    26,    -1,    -1,    -1,    -1,    31,
      32,    -1,    -1,    -1,    -1,    37,    38,    39,    40,    41,
      42,    43,    -1,    -1,    -1,    -1,    48,    49,    -1,    -1,
      -1,    -1,    -1,    -1,    56,    57,    58,    59,    -1,    61,
      -1,    -1,    64,    65,    66,    67,    -1,    -1,    -1,    71,
      72,    -1,    -1,    -1,    -1,    -1,    78,    79,    -1,    -1,
      -1,    -1,    -1,    85,    -1,    87,    -1,    89,    -1,    91,
      -1,    93,    -1,    -1,    -1,    97,    -1,    99,   100,    -1,
     102,   103,   104,    -1,   106,   107,   108,   109,   110,   111,
     112,   113,    -1,   115,   116,   117,   118,   119,   120,    -1,
     122,   123,    -1,    -1,   126,    -1,   128,   129,    -1,    -1,
      -1,   133,    -1,    -1,    -1,    -1,    -1,    -1,   140,   141,
     142,   143,    -1,    -1,    -1,   147,   148,   149,    -1,   151,
     152,    -1,   154,   155,   156,   157,    -1,    -1,   160,   161,
      -1,   163,   164,   165,    -1,    -1,    -1,    -1,    -1,   171,
     172,   173,   174,   175,   176,    -1,    -1,   179,    -1,    -1,
      -1,   183,    -1,    -1,    -1,   187,   188,   189,   190,   191,
     192,   193,   194,   195,   196,   197,    -1,   199,   200,   201,
       6,    -1,     8,     9,    -1,    -1,    -1,    -1,    -1,    15,
      -1,    17,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      26,    -1,    -1,    -1,    -1,    31,    32,    -1,    -1,    -1,
      -1,    37,    38,    39,    40,    41,    42,    43,    -1,    -1,
      -1,    -1,    48,    49,    -1,    -1,    -1,    -1,    -1,    -1,
      56,    57,    58,    59,    -1,    61,    -1,    -1,    64,    65,
      66,    67,    -1,    -1,    -1,    71,    72,    -1,    -1,    -1,
      -1,    -1,    78,    79,    -1,    -1,    -1,    -1,    -1,    85,
      -1,    87,    -1,    89,    -1,    91,    -1,    93,    -1,    -1,
      -1,    97,    -1,    99,   100,    -1,   102,   103,   104,    -1,
     106,   107,   108,   109,   110,   111,   112,   113,    -1,   115,
     116,   117,   118,   119,   120,    -1,   122,   123,    -1,    -1,
     126,    -1,   128,   129,    -1,    -1,    -1,   133,    -1,    -1,
      -1,    -1,    -1,    -1,   140,   141,   142,   143,    -1,    -1,
      -1,   147,   148,   149,    -1,   151,   152,    -1,   154,   155,
     156,   157,    -1,    -1,   160,   161,    -1,   163,   164,   165,
      -1,    -1,    -1,    -1,    -1,   171,   172,   173,   174,   175,
     176,    -1,    -1,   179,    -1,    -1,    -1,   183,    -1,    -1,
      -1,   187,   188,   189,   190,   191,   192,   193,   194,   195,
     196,   197,    -1,   199,   200,   201,     6,    -1,     8,     9,
      -1,    -1,    -1,    -1,    -1,    15,    -1,    17,    -1,    -1,
      -1,    21,    -1,    -1,    -1,    -1,    26,    -1,    -1,    -1,
      -1,    31,    32,    -1,    -1,    -1,    -1,    37,    38,    39,
      40,    41,    42,    43,    -1,    -1,    -1,    -1,    48,    49,
      -1,    -1,    -1,    -1,    -1,    -1,    56,    57,    58,    59,
      -1,    -1,    -1,    -1,    64,    65,    66,    67,    -1,    -1,
      -1,    71,    72,    -1,    -1,    -1,    -1,    -1,    78,    79,
      -1,    -1,    -1,    -1,    -1,    85,    -1,    87,    -1,    89,
      -1,    91,    -1,    93,    -1,    -1,    -1,    97,    -1,    99,
     100,    -1,   102,    -1,   104,    -1,   106,   107,   108,   109,
     110,   111,   112,   113,    -1,   115,   116,   117,   118,   119,
     120,    -1,    -1,   123,    -1,    -1,   126,    -1,   128,   129,
      -1,    -1,    -1,   133,    -1,    -1,    -1,    -1,    -1,    -1,
     140,   141,   142,   143,    -1,    -1,    -1,   147,   148,   149,
      -1,   151,   152,    -1,   154,   155,    -1,   157,    -1,    -1,
     160,   161,    -1,    -1,   164,   165,    -1,    -1,    -1,    -1,
      -1,   171,   172,   173,   174,   175,   176,    -1,    -1,   179,
      -1,    -1,    -1,   183,    -1,    -1,    -1,   187,   188,   189,
     190,   191,   192,   193,   194,   195,   196,   197,    -1,   199,
     200,   201,     6,    -1,     8,     9,    10,    -1,    -1,    -1,
      -1,    15,    -1,    17,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    26,    -1,    -1,    -1,    -1,    31,    32,    -1,
      -1,    -1,    -1,    37,    38,    39,    40,    41,    42,    43,
      -1,    -1,    -1,    -1,    48,    49,    -1,    -1,    -1,    -1,
      -1,    -1,    56,    57,    58,    59,    -1,    -1,    -1,    -1,
      64,    65,    66,    67,    -1,    -1,    -1,    71,    72,    -1,
      -1,    -1,    -1,    -1,    78,    79,    -1,    -1,    -1,    -1,
      -1,    85,    -1,    87,    -1,    89,    -1,    91,    -1,    93,
      -1,    -1,    -1,    97,    -1,    99,   100,    -1,   102,    -1,
     104,    -1,   106,   107,   108,   109,   110,   111,   112,   113,
      -1,   115,   116,   117,   118,   119,   120,    -1,    -1,   123,
      -1,    -1,   126,    -1,   128,   129,    -1,    -1,    -1,   133,
      -1,    -1,    -1,    -1,    -1,    -1,   140,   141,   142,   143,
      -1,    -1,    -1,   147,   148,   149,    -1,   151,   152,    -1,
     154,   155,    -1,   157,    -1,    -1,   160,   161,    -1,    -1,
     164,   165,    -1,    -1,    -1,    -1,    -1,   171,   172,   173,
     174,   175,   176,    -1,    -1,   179,    -1,    -1,    -1,   183,
      -1,    -1,    -1,   187,   188,   189,   190,   191,   192,   193,
     194,   195,   196,   197,    -1,   199,   200,   201,     6,    -1,
       8,     9,    -1,    -1,    -1,    -1,    -1,    15,    -1,    17,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    26,    -1,
      -1,    -1,    -1,    31,    32,    -1,    -1,    -1,    -1,    37,
      38,    39,    40,    41,    42,    43,    -1,    -1,    -1,    -1,
      48,    49,    -1,    -1,    -1,    -1,    -1,    -1,    56,    57,
      58,    59,    -1,    -1,    -1,    -1,    64,    65,    66,    67,
      -1,    -1,    -1,    71,    72,    -1,    -1,    -1,    -1,    -1,
      78,    79,    -1,    -1,    -1,    -1,    -1,    85,    -1,    87,
      88,    89,    -1,    91,    -1,    93,    -1,    -1,    -1,    97,
      -1,    99,   100,    -1,   102,    -1,   104,    -1,   106,   107,
     108,   109,   110,   111,   112,   113,    -1,   115,   116,   117,
     118,   119,   120,    -1,    -1,   123,    -1,    -1,   126,    -1,
     128,   129,    -1,    -1,    -1,   133,    -1,    -1,    -1,    -1,
      -1,    -1,   140,   141,   142,   143,    -1,    -1,    -1,   147,
     148,   149,    -1,   151,   152,    -1,   154,   155,    -1,   157,
      -1,    -1,   160,   161,    -1,    -1,   164,   165,    -1,    -1,
      -1,    -1,    -1,   171,   172,   173,   174,   175,   176,    -1,
      -1,   179,    -1,    -1,    -1,   183,    -1,    -1,    -1,   187,
     188,   189,   190,   191,   192,   193,   194,   195,   196,   197,
      -1,   199,   200,   201,     6,    -1,     8,     9,    -1,    -1,
      -1,    -1,    -1,    15,    -1,    17,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    26,    -1,    -1,    -1,    -1,    31,
      32,    -1,    -1,    -1,    -1,    37,    38,    39,    40,    41,
      42,    43,    -1,    -1,    -1,    -1,    48,    49,    -1,    -1,
      -1,    -1,    -1,    -1,    56,    57,    58,    59,    -1,    -1,
      -1,    -1,    64,    65,    66,    67,    -1,    -1,    -1,    71,
      72,    -1,    -1,    -1,    -1,    -1,    78,    79,    -1,    -1,
      -1,    -1,    -1,    85,    -1,    87,    -1,    89,    -1,    91,
      -1,    93,    -1,    -1,    -1,    97,    -1,    99,   100,    -1,
     102,    -1,   104,    -1,   106,   107,   108,   109,   110,   111,
     112,   113,    -1,   115,   116,   117,   118,   119,   120,    -1,
      -1,   123,    -1,    -1,   126,    -1,   128,   129,    -1,    -1,
      -1,   133,    -1,    -1,    -1,    -1,    -1,    -1,   140,   141,
     142,   143,    -1,    -1,    -1,   147,   148,   149,    -1,   151,
     152,    -1,   154,   155,    -1,   157,    -1,    -1,   160,   161,
      -1,    -1,   164,   165,    -1,    -1,    -1,    -1,    -1,   171,
     172,   173,   174,   175,   176,    -1,    -1,   179,    -1,    -1,
      -1,   183,    -1,    -1,    -1,   187,   188,   189,   190,   191,
     192,   193,   194,   195,   196,   197,    -1,   199,   200,   201,
       6,    -1,     8,     9,    -1,    -1,    -1,    -1,    -1,    15,
      -1,    17,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      26,    -1,    -1,    -1,    -1,    31,    32,    -1,    -1,    -1,
      -1,    37,    38,    39,    40,    41,    42,    43,    -1,    -1,
      -1,    -1,    48,    49,    -1,    -1,    -1,    -1,    -1,    -1,
      56,    57,    58,    59,    -1,    -1,    -1,    -1,    64,    65,
      66,    67,    -1,    -1,    -1,    71,    72,    -1,    -1,    -1,
      -1,    -1,    78,    79,    -1,    -1,    -1,    -1,    -1,    85,
      -1,    87,    -1,    89,    -1,    91,    -1,    93,    -1,    -1,
      -1,    97,    -1,    99,   100,    -1,   102,    -1,   104,    -1,
     106,   107,   108,   109,   110,   111,   112,   113,    -1,   115,
     116,   117,   118,   119,   120,    -1,    -1,   123,    -1,    -1,
     126,    -1,   128,   129,    -1,    -1,    -1,   133,    -1,    -1,
      -1,    -1,    -1,    -1,   140,   141,   142,   143,    -1,    -1,
      -1,   147,   148,   149,    -1,   151,   152,    -1,   154,   155,
      -1,   157,    -1,    -1,   160,   161,    -1,    -1,   164,   165,
      -1,    -1,    -1,    -1,    -1,   171,   172,   173,   174,   175,
     176,    -1,    -1,   179,    -1,    -1,    -1,   183,    -1,    -1,
      -1,   187,   188,   189,   190,   191,   192,   193,   194,   195,
     196,   197,    -1,   199,   200,   201,     6,    -1,     8,     9,
      -1,    -1,    -1,    -1,    -1,    15,    -1,    17,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    26,    -1,    -1,    -1,
      -1,    31,    32,    -1,    -1,    -1,    -1,    37,    38,    39,
      40,    41,    42,    43,    -1,    -1,    -1,    -1,    48,    49,
      -1,    -1,    -1,    -1,    -1,    -1,    56,    57,    58,    59,
      -1,    -1,    -1,    -1,    64,    65,    66,    67,    -1,    -1,
      -1,    71,    72,    -1,    -1,    -1,    -1,    -1,    78,    79,
      -1,    -1,    -1,    -1,    -1,    85,    -1,    87,    -1,    89,
      -1,    -1,    -1,    93,    -1,    -1,    -1,    97,    -1,    99,
     100,    -1,   102,    -1,   104,    -1,   106,   107,   108,   109,
     110,   111,    -1,   113,    -1,   115,    -1,   117,   118,   119,
     120,    -1,    -1,   123,    -1,    -1,   126,    -1,   128,   129,
      -1,    -1,    -1,   133,    -1,    -1,    -1,    -1,    -1,    -1,
     140,   141,   142,   143,    -1,    -1,    -1,   147,   148,   149,
      -1,   151,   152,    -1,   154,   155,    -1,   157,    -1,    -1,
     160,   161,    -1,    -1,   164,   165,    -1,    -1,    -1,    -1,
      -1,   171,   172,   173,   174,   175,   176,    -1,    -1,   179,
      -1,    -1,    -1,   183,    -1,    -1,    -1,   187,   188,   189,
     190,   191,   192,   193,   194,   195,   196,   197,    -1,   199,
     200,   201,     6,    -1,     8,     9,    -1,    -1,    -1,    -1,
      -1,    15,    -1,    17,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    26,    -1,    -1,    -1,    -1,    31,    32,    -1,
      -1,    -1,    -1,    37,    38,    39,    40,    41,    42,    43,
      -1,    -1,    -1,    -1,    48,    49,    -1,    -1,    -1,    -1,
      -1,    -1,    56,    -1,    -1,    59,    -1,    -1,    -1,    -1,
      64,    65,    66,    67,    -1,    -1,    -1,    71,    72,    -1,
      -1,    -1,    -1,    -1,    78,    79,    -1,    -1,    -1,    -1,
      -1,    85,    -1,    87,    -1,    89,    -1,    -1,    -1,    93,
      -1,    -1,    -1,    97,    -1,    99,   100,    -1,   102,    -1,
      -1,    -1,   106,   107,   108,   109,   110,   111,    -1,   113,
      -1,   115,    -1,   117,   118,   119,   120,    -1,    -1,   123,
      -1,    -1,   126,    -1,   128,   129,    -1,    -1,    -1,   133,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   141,   142,   143,
      -1,    -1,    -1,   147,   148,   149,    -1,   151,   152,    -1,
     154,   155,    -1,   157,    -1,    -1,   160,   161,    -1,    -1,
     164,   165,    -1,    -1,    -1,    -1,    -1,   171,   172,    -1,
     174,   175,   176,    -1,    -1,   179,    -1,    -1,    -1,   183,
      -1,    -1,    -1,   187,   188,   189,    -1,   191,   192,   193,
     194,   195,   196,    -1,    -1,   199,   200,   201,     6,    -1,
       8,     9,    -1,    -1,    -1,    -1,    -1,    15,    -1,    17,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    31,    32,    -1,    -1,    -1,    -1,    37,
      38,    39,    40,    41,    42,    43,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    56,    57,
      58,    59,    -1,    -1,    -1,    -1,    64,    65,    66,    -1,
      -1,    -1,    -1,    71,    72,    -1,    -1,    -1,    -1,    -1,
      78,    79,    -1,    -1,    -1,    -1,    -1,    85,    -1,    -1,
      -1,    89,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    97,
      -1,    99,   100,    -1,   102,    -1,   104,    -1,   106,   107,
     108,   109,   110,   111,    -1,   113,    -1,    -1,    -1,    -1,
     118,    -1,    -1,    -1,    -1,   123,    -1,    -1,   126,    -1,
     128,   129,    -1,    -1,    -1,   133,    -1,    -1,    -1,    -1,
      -1,    -1,   140,   141,   142,   143,    -1,    -1,    -1,   147,
     148,   149,    -1,   151,   152,    -1,   154,   155,    -1,   157,
      -1,    -1,    -1,   161,    -1,    -1,   164,   165,    -1,    -1,
      -1,    -1,    -1,   171,   172,   173,    -1,   175,   176,    -1,
      -1,   179,    -1,    -1,    -1,     6,    -1,     8,     9,    -1,
      -1,   189,   190,   191,    15,   193,    17,   195,   196,   197,
      -1,   199,   200,   201,    -1,    -1,    -1,    -1,    -1,    -1,
      31,    32,    -1,    -1,    -1,    -1,    37,    38,    39,    40,
      41,    42,    43,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    56,    -1,    -1,    59,    -1,
      -1,    -1,    -1,    64,    65,    66,    -1,    -1,    -1,    -1,
      71,    72,    -1,    -1,    -1,    -1,    -1,    78,    79,    -1,
      -1,    -1,    -1,    -1,    85,    -1,    -1,    -1,    89,    90,
      -1,    -1,    -1,    -1,    -1,    -1,    97,    -1,    99,   100,
      -1,   102,    -1,    -1,    -1,   106,   107,   108,   109,   110,
     111,    -1,   113,    -1,    -1,    -1,    -1,   118,    -1,    -1,
      -1,    -1,   123,    -1,    -1,   126,    -1,   128,   129,    -1,
      -1,    -1,   133,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     141,   142,   143,    -1,    -1,    -1,   147,   148,   149,    -1,
     151,   152,    -1,   154,   155,    -1,   157,    -1,    -1,    -1,
     161,    -1,    -1,   164,   165,    -1,    -1,    -1,    -1,    -1,
     171,   172,    -1,    -1,   175,   176,   177,     6,   179,     8,
       9,    10,    -1,    -1,    -1,    14,    15,    -1,    17,    -1,
     191,    -1,   193,    -1,   195,   196,    -1,    -1,   199,   200,
     201,    -1,    31,    32,    -1,    -1,    -1,    -1,    37,    38,
      39,    40,    41,    42,    43,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    56,    -1,    -1,
      59,    -1,    -1,    -1,    -1,    64,    65,    66,    -1,    -1,
      -1,    -1,    71,    72,    -1,    -1,    -1,    -1,    -1,    78,
      79,    -1,    -1,    -1,    -1,    -1,    85,    -1,    -1,    -1,
      89,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    97,    -1,
      99,   100,    -1,   102,    -1,    -1,    -1,   106,   107,   108,
     109,   110,   111,    -1,   113,    -1,    -1,    -1,    -1,   118,
      -1,    -1,    -1,    -1,   123,    -1,    -1,   126,    -1,   128,
     129,    -1,    -1,    -1,   133,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   141,   142,   143,    -1,    -1,    -1,   147,   148,
     149,    -1,   151,   152,    -1,   154,   155,    -1,   157,    -1,
      -1,    -1,   161,    -1,    -1,   164,   165,    -1,    -1,    -1,
      -1,    -1,   171,   172,    -1,    -1,   175,   176,    -1,     6,
     179,     8,     9,    10,    -1,    -1,    -1,    -1,    15,    -1,
      17,    -1,   191,    -1,   193,    -1,   195,   196,    -1,    -1,
     199,   200,   201,    -1,    31,    32,    -1,    -1,    -1,    -1,
      37,    38,    39,    40,    41,    42,    43,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    56,
      -1,    -1,    59,    -1,    -1,    -1,    -1,    64,    65,    66,
      -1,    -1,    -1,    -1,    71,    72,    -1,    -1,    -1,    -1,
      -1,    78,    79,    -1,    -1,    -1,    -1,    -1,    85,    -1,
      -1,    -1,    89,    22,    -1,    -1,    -1,    -1,    -1,    -1,
      97,    -1,    99,   100,    33,   102,    35,    -1,    -1,   106,
     107,   108,   109,   110,   111,    -1,   113,    -1,    47,    -1,
      -1,   118,    -1,    -1,    -1,    -1,   123,    -1,    -1,   126,
      -1,   128,   129,    -1,    63,    -1,   133,    -1,    -1,    -1,
      69,    -1,    -1,    -1,   141,   142,   143,    -1,    -1,    -1,
     147,   148,   149,    -1,   151,   152,    -1,   154,   155,    -1,
     157,    -1,    -1,    -1,   161,    -1,    -1,   164,   165,    98,
      -1,    -1,   101,    -1,   171,   172,   105,    -1,   175,   176,
      -1,     6,   179,     8,     9,   114,    -1,    -1,    -1,    14,
      15,    -1,    17,    -1,   191,    -1,   193,    -1,   195,   196,
      -1,    -1,   199,   200,   201,   134,    31,    32,    -1,    -1,
     139,    -1,    37,    38,    39,    40,    41,    42,    43,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   158,
      -1,    56,    -1,    -1,    59,    -1,    -1,    -1,    -1,    64,
      65,    66,    -1,    -1,    -1,    -1,    71,    72,    -1,    -1,
      -1,    -1,    -1,    78,    79,    -1,    -1,    -1,    -1,    -1,
      85,    -1,    -1,    -1,    89,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    97,    -1,    99,   100,    -1,   102,    -1,    -1,
      -1,   106,   107,   108,   109,   110,   111,    -1,   113,    -1,
      -1,    -1,    -1,   118,    -1,    -1,    -1,    -1,   123,    -1,
      -1,   126,    -1,   128,   129,    -1,    -1,    -1,   133,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   141,   142,   143,    -1,
      -1,    -1,   147,   148,   149,    -1,   151,   152,    -1,   154,
     155,    -1,   157,    -1,    -1,    -1,   161,    -1,    -1,   164,
     165,    -1,    -1,    -1,    -1,    -1,   171,   172,    -1,    -1,
     175,   176,    -1,     6,   179,     8,     9,    -1,    -1,    -1,
      -1,    -1,    15,    -1,    17,    -1,   191,    -1,   193,    -1,
     195,   196,    -1,    -1,   199,   200,   201,    -1,    31,    32,
      -1,    -1,    -1,    -1,    37,    38,    39,    40,    41,    42,
      43,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    56,    -1,    -1,    59,    -1,    -1,    -1,
      -1,    64,    65,    66,    -1,    -1,    -1,    -1,    71,    72,
      -1,    -1,    -1,    -1,    -1,    78,    79,    -1,    -1,    -1,
      -1,    -1,    85,    -1,    -1,    -1,    89,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    97,    -1,    99,   100,    -1,   102,
      -1,    -1,    -1,   106,   107,   108,   109,   110,   111,    -1,
     113,    -1,    -1,    -1,    -1,   118,    -1,    -1,    -1,    -1,
     123,    -1,    -1,   126,    -1,   128,   129,    -1,    -1,    -1,
     133,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   141,   142,
     143,    -1,    -1,    -1,   147,   148,   149,    -1,   151,   152,
      -1,   154,   155,    -1,   157,    -1,    -1,    -1,   161,    -1,
      -1,   164,   165,    -1,    -1,    -1,    -1,    -1,   171,   172,
      -1,    -1,   175,   176,     6,    -1,   179,    -1,    10,    11,
      -1,    -1,    -1,    15,    -1,    17,    -1,    -1,   191,    -1,
     193,    -1,   195,   196,    -1,    -1,   199,   200,   201,    31,
      32,    -1,    -1,    -1,    -1,    37,    38,    39,    40,    41,
      42,    43,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    56,    -1,    -1,    59,    -1,    -1,
      -1,    -1,    64,    65,    66,    -1,    -1,    -1,    -1,    71,
      72,    -1,    -1,    -1,    -1,    -1,    78,    79,    -1,    -1,
      -1,    -1,    -1,    85,    -1,    -1,    -1,    89,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    97,    -1,    99,   100,    -1,
     102,    -1,    -1,    -1,   106,   107,   108,   109,   110,   111,
      -1,   113,    -1,    -1,    -1,    -1,   118,    -1,    -1,    -1,
      -1,   123,    -1,    -1,   126,    -1,   128,   129,    -1,    -1,
      -1,   133,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   141,
     142,   143,    -1,    -1,    -1,   147,   148,   149,    -1,   151,
     152,    -1,   154,   155,    -1,   157,    -1,    -1,    -1,   161,
      -1,    -1,   164,   165,    -1,    -1,    -1,    -1,    -1,   171,
     172,    -1,    -1,   175,   176,     6,    -1,   179,    -1,    -1,
      -1,    -1,    -1,    -1,    15,    -1,    17,    -1,    -1,   191,
      -1,   193,    -1,   195,   196,    -1,    -1,   199,   200,   201,
      31,    32,    -1,    -1,    -1,    -1,    37,    38,    39,    40,
      41,    42,    43,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    56,    -1,    -1,    59,    -1,
      -1,    -1,    -1,    64,    65,    66,    -1,    -1,    -1,    -1,
      71,    72,    -1,    -1,    -1,    59,    -1,    78,    79,    -1,
      -1,    -1,    66,    -1,    85,    -1,    -1,    -1,    89,    -1,
      -1,    -1,    -1,    -1,    78,    79,    97,    -1,    99,   100,
      -1,   102,    -1,    -1,    -1,   106,   107,   108,   109,   110,
     111,    -1,   113,    -1,    -1,     6,    -1,   118,    -1,    -1,
      -1,    -1,   123,    -1,    15,   126,    17,   128,   129,    -1,
      -1,    -1,   133,    -1,    -1,    -1,    -1,    -1,    -1,   123,
     141,   142,   143,    -1,   128,   129,   147,   148,   149,    -1,
     151,   152,    -1,   154,   155,    -1,   157,    48,   142,    -1,
     161,    -1,    -1,   164,   165,    -1,    57,    -1,    -1,    -1,
     171,   172,    -1,     6,   175,   176,    67,    -1,   179,    -1,
      -1,    -1,    15,    -1,    17,    -1,    -1,    -1,    -1,    -1,
     191,    -1,   193,    26,   195,   196,    87,    -1,   199,   200,
     201,    -1,    93,   187,   188,   189,    -1,   191,   192,   193,
     194,   195,   196,    -1,    -1,    48,    49,    -1,    -1,    -1,
      -1,   112,    -1,    -1,    -1,    -1,   117,    -1,   119,   120,
      -1,     6,    -1,    -1,    67,    -1,    -1,    70,    -1,    -1,
      15,    -1,    17,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    26,     6,    -1,    87,    -1,    -1,    -1,    -1,    -1,
      93,    15,    -1,    17,    -1,    -1,    -1,    -1,    -1,   160,
      -1,    -1,    -1,    48,    49,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   115,   174,   117,    -1,   119,   120,    -1,    -1,
      -1,    -1,    67,    -1,    48,    49,   187,    -1,    -1,   190,
     191,    -1,    -1,   194,   195,   196,   197,    -1,   199,   200,
     201,    -1,    87,    67,    -1,    -1,    -1,    -1,    93,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   160,    -1,    -1,
      -1,    -1,    -1,    87,    -1,    -1,    -1,    -1,    -1,    93,
     115,   174,   117,    -1,   119,   120,    -1,    -1,    -1,    -1,
     183,    -1,    -1,    -1,   187,   188,   189,    -1,   191,   192,
     193,   194,     6,   117,    -1,   119,   120,    -1,    -1,    -1,
      -1,    15,    -1,    17,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   160,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   174,
      -1,    -1,    -1,    -1,    48,    49,   160,    -1,   183,    -1,
      -1,    -1,   187,   188,   189,    -1,   191,   192,   193,   194,
     174,    -1,    -1,    67,    -1,    -1,    -1,    -1,    -1,   183,
      -1,    -1,    -1,   187,   188,   189,    -1,   191,   192,   193,
     194,    -1,    -1,    87,    -1,    -1,    -1,    -1,    -1,    93,
      -1,    -1,    -1,    -1,    15,    -1,    17,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   117,    -1,   119,   120,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    48,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    57,    -1,    59,    -1,
      -1,    -1,    -1,    -1,    -1,    66,    67,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   160,    78,    79,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    87,    -1,    -1,    -1,
     174,    -1,    93,    -1,    -1,    -1,    -1,    -1,    -1,   183,
      -1,    -1,    -1,   187,   188,   189,    -1,   191,   192,   193,
     194,   112,    -1,    -1,    -1,    -1,   117,    -1,   119,   120,
      -1,    -1,   123,    -1,    -1,    -1,    -1,   128,   129,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   142,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   160,
      -1,    -1,    -1,    -1,    15,    -1,    17,    -1,    -1,    -1,
      21,    -1,    -1,   174,    -1,    -1,    -1,    -1,    -1,    30,
      -1,    -1,    -1,    -1,    -1,    -1,   187,   188,   189,   190,
     191,   192,   193,   194,   195,   196,   197,    -1,   199,   200,
     201,    52,    53,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    63,    -1,    -1,    -1,    -1,    68,    -1,    -1,
      -1,    -1,    73,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    84,    -1,    -1,    -1,    88,    -1,    -1,
      91,    92,    -1,    94,    -1,    -1,    -1,    98,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   112,    -1,    -1,    -1,    -1,    -1,    -1,   119,   120,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   130,
     131,    -1,    -1,    -1,   135,   136,   137,   138,    -1,    -1,
      -1,    -1,    -1,   144,   145,   146,    -1,    -1,    -1,   150,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   159,   160,
      15,    -1,    17,    -1,    -1,    -1,    21,   168,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    30,    -1,   178,    -1,   180,
      -1,   182,    -1,    -1,    -1,    -1,   187,   188,   189,   190,
     191,   192,   193,   194,   195,   196,    -1,    52,    53,    -1,
      -1,    -1,    -1,    -1,    15,    60,    17,    -1,    -1,    -1,
      -1,    -1,    -1,    68,    -1,    -1,    -1,    -1,    73,    -1,
      -1,    -1,    77,    -1,    -1,    -1,    -1,    -1,    -1,    84,
      -1,    -1,    -1,    88,    -1,    -1,    91,    92,    -1,    94,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    59,    -1,
      -1,    -1,    -1,    -1,    -1,    66,    -1,   112,    -1,    -1,
      -1,    -1,    -1,    -1,   119,   120,    -1,    78,    79,    -1,
      -1,    -1,    -1,    -1,    -1,   130,   131,    -1,    -1,    -1,
     135,   136,   137,   138,    -1,    -1,    -1,    -1,    -1,   144,
     145,   146,    15,    -1,    17,   150,    -1,    -1,    21,    -1,
      -1,   112,    -1,    -1,   159,   160,    -1,    30,    -1,    -1,
      -1,    -1,   123,   168,    -1,    -1,    -1,   128,   129,    -1,
      -1,    -1,    -1,   178,    -1,   180,    -1,   182,    -1,    52,
      53,   142,   187,   188,   189,   190,   191,   192,   193,   194,
     195,   196,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   160,
      73,    -1,    -1,    76,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    84,    -1,    -1,    -1,    88,    -1,    -1,    91,    92,
      -1,    94,    -1,    -1,    -1,    -1,   187,   188,   189,   190,
     191,   192,   193,   194,   195,   196,    -1,    -1,    -1,   112,
      -1,    -1,    -1,    -1,    -1,    -1,   119,   120,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   130,   131,    -1,
      -1,    -1,   135,    -1,   137,   138,    -1,    -1,    -1,    -1,
      -1,   144,   145,   146,    15,    -1,    17,   150,    -1,    -1,
      21,    -1,    -1,    -1,    -1,    -1,    -1,   160,    -1,    30,
      -1,    -1,    -1,    -1,   167,   168,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   178,    -1,   180,    -1,   182,
      -1,    52,    53,    -1,   187,   188,   189,   190,   191,   192,
     193,   194,   195,   196,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    73,    -1,    -1,    76,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    84,    -1,    86,    -1,    88,    -1,    -1,
      -1,    92,    -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   112,    -1,    -1,    -1,    -1,    -1,    -1,   119,   120,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   130,
     131,    -1,    -1,    -1,   135,    -1,   137,   138,    -1,    -1,
      -1,    -1,    -1,   144,   145,   146,    -1,    -1,    -1,   150,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   160,
      15,    -1,    17,    -1,    -1,   166,    21,   168,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    30,    -1,   178,    -1,   180,
      -1,   182,    -1,    -1,    -1,    -1,   187,   188,   189,   190,
     191,   192,   193,   194,   195,   196,    -1,    52,    53,    -1,
      -1,    -1,    -1,    -1,    -1,    60,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    73,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    84,
      -1,    86,    -1,    88,    -1,    -1,    -1,    92,    -1,    94,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   112,    -1,    -1,
      -1,    -1,    -1,    -1,   119,   120,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   130,   131,    -1,    -1,    -1,
     135,    -1,   137,   138,    -1,    -1,    -1,    -1,    -1,   144,
     145,   146,    15,    -1,    17,   150,    -1,    -1,    21,    -1,
      -1,    -1,    -1,    -1,    -1,   160,    -1,    30,    -1,    -1,
      -1,   166,    -1,   168,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   178,    -1,   180,    -1,   182,    -1,    52,
      53,    -1,   187,   188,   189,   190,   191,   192,   193,   194,
     195,   196,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      73,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    84,    -1,    86,    -1,    88,    -1,    -1,    -1,    92,
      -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   112,
      -1,    -1,    -1,    -1,    -1,    -1,   119,   120,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   130,   131,    -1,
      -1,    -1,   135,    -1,   137,   138,    -1,    -1,    -1,    -1,
      -1,   144,   145,   146,    -1,    -1,    -1,   150,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   160,    15,    -1,
      17,    -1,    -1,   166,    21,   168,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    30,    -1,   178,    -1,   180,    -1,   182,
      -1,    -1,    -1,    -1,   187,   188,   189,   190,   191,   192,
     193,   194,   195,   196,    -1,    52,    53,    -1,    -1,    -1,
      -1,    -1,    -1,    60,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    73,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    84,    -1,    -1,
      -1,    88,    -1,    -1,    91,    92,    -1,    94,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   112,    -1,    -1,    -1,    -1,
      -1,    -1,   119,   120,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   130,   131,    -1,    -1,    -1,   135,    -1,
     137,   138,    -1,    -1,    -1,    -1,    -1,   144,   145,   146,
      15,    -1,    17,   150,    -1,    -1,    21,    -1,    -1,    -1,
      -1,    -1,    -1,   160,    -1,    30,    -1,    -1,    -1,    -1,
      -1,   168,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   178,    -1,   180,    -1,   182,    -1,    52,    53,    -1,
     187,   188,   189,   190,   191,   192,   193,   194,   195,   196,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    73,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    84,
      -1,    -1,    -1,    88,    -1,    -1,    91,    92,    -1,    94,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   112,    -1,    -1,
      -1,    -1,    -1,    -1,   119,   120,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   130,   131,    -1,    -1,    -1,
     135,    -1,   137,   138,    -1,    -1,    -1,    -1,    -1,   144,
     145,   146,    15,    -1,    17,   150,    -1,    -1,    21,    -1,
      -1,    -1,    -1,    -1,    -1,   160,    -1,    30,    -1,    -1,
      -1,    -1,    -1,   168,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   178,    -1,   180,    -1,   182,    -1,    52,
      53,    -1,   187,   188,   189,   190,   191,   192,   193,   194,
     195,   196,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      73,    -1,    -1,    76,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    84,    -1,    -1,    -1,    88,    -1,    -1,    -1,    92,
      -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   112,
      -1,    -1,    -1,    -1,    -1,    -1,   119,   120,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   130,   131,    -1,
      -1,    -1,   135,    -1,   137,   138,    -1,    -1,    -1,    -1,
      -1,   144,   145,   146,    -1,    -1,    -1,   150,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   160,    15,    -1,
      17,    -1,    -1,    -1,    21,   168,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    30,    -1,   178,    -1,   180,    -1,   182,
      -1,    -1,    -1,    -1,   187,   188,   189,   190,   191,   192,
     193,   194,   195,   196,    -1,    52,    53,    -1,    -1,    -1,
      -1,    -1,    -1,    60,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    73,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    84,    -1,    -1,
      -1,    88,    -1,    -1,    -1,    92,    -1,    94,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   112,    -1,    -1,    -1,    -1,
      -1,    -1,   119,   120,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   130,   131,    -1,    -1,    -1,   135,    -1,
     137,   138,    -1,    -1,    -1,    -1,    -1,   144,   145,   146,
      15,    -1,    17,   150,    -1,    -1,    21,    -1,    -1,    -1,
      -1,    -1,    -1,   160,    -1,    30,    -1,    -1,    -1,    -1,
      -1,   168,    -1,    -1,    15,    -1,    17,    -1,    -1,    -1,
      -1,   178,    -1,   180,    -1,   182,    -1,    52,    53,    -1,
     187,   188,   189,   190,   191,   192,   193,   194,   195,   196,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    73,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    59,    84,
      -1,    -1,    -1,    88,    -1,    66,    -1,    92,    -1,    94,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    78,    79,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   112,    -1,    -1,
      -1,    -1,    -1,    -1,   119,   120,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   130,   131,    -1,    -1,    -1,
     135,   112,   137,   138,    -1,   116,    -1,    -1,    -1,   144,
     145,   146,   123,    -1,    -1,   150,    -1,   128,   129,    -1,
      -1,    -1,    -1,    -1,    -1,   160,    -1,    -1,    -1,    -1,
      -1,   142,    -1,   168,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   178,    -1,   180,    -1,   182,    -1,   160,
      -1,    -1,   187,   188,   189,   190,   191,   192,   193,   194,
     195,   196,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   187,   188,   189,   190,
     191,   192,   193,   194,   195,   196,    33,    -1,    35,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    44,    -1,    -1,
      47,    -1,    49,    50,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    58,    -1,    -1,    -1,    -1,    63,    -1,    -1,    -1,
      -1,    -1,    69,    -1,    -1,    -1,    -1,    74,    -1,    -1,
      -1,    -1,    -1,    -1,    81,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    91,    -1,    -1,    -1,    -1,    -1,
      -1,    98,    99,    -1,   101,    -1,    -1,    -1,   105,    -1,
     107,    -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   125,    -1,
     127,    -1,    -1,    -1,    -1,    -1,    -1,   134,    -1,    -1,
      -1,    -1,   139,    -1,    -1,    -1,   143,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   153,    -1,    -1,    -1,
      -1,   158,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   166,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   179,    -1,    -1,    -1,    -1,    33,    -1,    35,
     187,   188,   189,   190,   191,   192,   193,   194,    44,   196,
      -1,    47,    -1,    49,    50,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    58,    -1,    -1,    -1,    -1,    63,    -1,    -1,
      -1,    -1,    -1,    69,    33,    -1,    35,    -1,    74,    -1,
      -1,    -1,    -1,    -1,    -1,    81,    -1,    -1,    47,    -1,
      49,    50,    -1,    -1,    -1,    91,    -1,    -1,    -1,    58,
      -1,    -1,    98,    99,    63,   101,    -1,    -1,    -1,   105,
      69,   107,    -1,    -1,    -1,    74,    -1,    -1,   114,    -1,
      -1,    -1,    81,    -1,    -1,    -1,    -1,    -1,    -1,   125,
      -1,   127,    91,    -1,    -1,    -1,    -1,    -1,   134,    98,
      99,    -1,   101,   139,    -1,    -1,   105,   143,   107,    -1,
      -1,    -1,    -1,    -1,    -1,   114,    -1,   153,    -1,    -1,
      -1,    -1,   158,    -1,    -1,    -1,   125,    -1,    -1,    -1,
     166,    33,    -1,    35,    -1,   134,    -1,    -1,    -1,    -1,
     139,    -1,    -1,   179,   143,    47,    -1,    49,    50,    -1,
      -1,    -1,    -1,    -1,   153,   191,    58,    -1,    -1,   158,
      -1,    63,    -1,    -1,    -1,    -1,    -1,    69,    -1,    -1,
      -1,    -1,    74,    -1,    -1,    -1,    -1,    -1,    -1,    81,
     179,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   191,    -1,    -1,    -1,    98,    99,    -1,   101,
      -1,    -1,    -1,   105,    -1,   107,    -1,    -1,    -1,    -1,
      -1,    -1,   114,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   134,    -1,    -1,    -1,    -1,   139,    -1,    -1,
      -1,   143,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   153,    -1,    -1,    -1,    -1,   158,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   179,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   191
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int16 yystos[] =
{
       0,    15,    17,    21,    30,    52,    53,    63,    68,    73,
      84,    88,    91,    92,    94,    98,   112,   119,   120,   130,
     131,   135,   136,   137,   138,   144,   145,   146,   150,   159,
     160,   168,   178,   180,   182,   187,   188,   189,   190,   191,
     192,   193,   194,   195,   196,   208,   222,   233,   255,   257,
     262,   263,   265,   266,   268,   274,   277,   279,   281,   282,
     283,   284,   285,   286,   287,   288,   290,   291,   292,   293,
     300,   301,   302,   303,   304,   305,   306,   307,   310,   312,
     313,   314,   315,   318,   319,   321,   322,   324,   325,   330,
     331,   332,   334,   346,   360,   361,   362,   363,   364,   365,
     368,   369,   377,   380,   383,   386,   387,   388,   389,   390,
     391,   392,   393,   233,   286,   208,   192,   256,   266,   286,
       6,    33,    35,    44,    47,    49,    50,    58,    69,    74,
      81,    91,    99,   101,   105,   107,   114,   125,   127,   134,
     139,   143,   153,   158,   166,   179,   188,   189,   191,   192,
     193,   194,   203,   204,   205,   206,   207,   208,   209,   210,
     211,   212,   213,   239,   265,   277,   287,   343,   344,   345,
     346,   350,   352,   353,   354,   355,   357,   359,    21,    54,
      90,   177,   181,   335,   336,   337,   340,    21,   266,     6,
      21,   353,   354,   355,   359,   170,     6,    80,    80,     6,
       6,    21,   266,   208,   381,   257,   286,     6,     8,     9,
      15,    17,    21,    26,    31,    32,    37,    38,    39,    40,
      41,    42,    43,    48,    49,    56,    57,    58,    59,    64,
      65,    66,    67,    71,    72,    78,    79,    85,    87,    89,
      91,    93,    97,    99,   100,   102,   104,   106,   107,   108,
     109,   110,   111,   113,   115,   116,   117,   118,   119,   120,
     123,   126,   128,   129,   133,   140,   141,   142,   143,   147,
     148,   149,   151,   152,   154,   155,   157,   161,   164,   165,
     171,   172,   173,   174,   175,   176,   179,   183,   188,   189,
     193,   197,   199,   200,   201,   211,   214,   215,   216,   217,
     218,   219,   221,   222,   223,   224,   225,   226,   227,   228,
     229,   232,   234,   235,   246,   247,   248,   252,   254,   255,
     256,   257,   258,   259,   260,   261,   262,   264,   267,   271,
     272,   273,   274,   275,   276,   278,   279,   282,   284,   286,
     256,    80,   257,   257,   287,   384,   124,     6,    19,   236,
     237,   240,   241,   281,   284,   286,     6,   236,   236,    22,
     236,   236,     6,     4,    28,   289,     6,     4,    11,   236,
     289,    21,   178,   300,   301,   306,   300,     6,   214,   246,
     248,   254,   271,   278,   282,   295,   296,   297,   298,   300,
      21,    36,    86,   166,   178,   301,   302,     6,    21,    45,
     308,    76,   167,   303,   306,   311,   341,    21,    61,   103,
     122,   156,   163,   281,   316,   320,    21,   191,   232,   317,
     320,     4,    21,     4,    21,   289,     4,     6,    90,   177,
     193,   214,   286,    21,   256,   323,    46,    96,   120,   124,
       4,    21,    70,   326,   327,   328,   329,   335,    21,     6,
      21,   224,   226,   228,   256,   259,   275,   280,   281,   333,
     342,   300,   214,   232,   347,   348,   349,     0,   303,   377,
     380,   383,    60,    77,   303,   306,   366,   367,   372,   373,
     377,   380,   383,    21,    33,   139,    83,   132,    62,    91,
     125,   127,     6,   352,   370,   375,   376,   308,   371,   375,
     378,    21,   366,   367,   366,   367,   366,   367,   366,   367,
      16,    11,    18,   236,    11,     6,     6,     6,     6,     6,
       6,     6,    91,   125,   207,    81,   344,    21,     4,   207,
     112,   239,    10,   214,   351,     4,   204,   351,   345,    10,
     232,   347,   191,   205,   344,     9,   356,   358,   214,   167,
     222,   286,   246,   295,    21,    21,   336,   214,   338,    21,
     224,    21,    21,    21,    21,   266,    21,   236,    95,   162,
     236,   224,   224,    21,     6,    51,    11,   214,   246,   271,
     286,   255,   286,   255,   286,    27,   236,   269,   270,     6,
     269,     6,   236,    25,    55,   216,   217,   253,   215,   215,
       7,    10,    11,   218,    12,    13,   220,    19,   237,     6,
      21,   236,    23,   121,   249,   250,    24,    36,   251,   253,
       6,    15,    17,   252,   286,   261,     6,   232,     6,   253,
       6,     6,    11,    21,   236,    22,   344,   205,   385,   170,
     256,   224,     6,   222,   224,    10,    14,   214,   242,   243,
     244,   245,     4,     5,    21,    22,     5,     6,   280,   281,
     288,   232,   318,   214,   230,   231,   232,   286,   288,   233,
     265,   268,   277,   287,   232,    75,   214,   271,   295,    27,
      29,   184,   185,   186,   289,   299,   169,   294,   299,     6,
     299,   299,   299,   249,   294,   251,   330,   230,     6,   266,
     203,   306,   311,    21,     6,     6,     6,     6,     6,   316,
     317,   232,   286,   214,   214,    70,   246,   214,    21,    11,
       4,    21,   214,   214,   246,     6,   135,    21,   329,    34,
      82,     6,   214,   246,   286,     4,     5,    14,     5,     4,
       6,   281,   342,   347,    21,   266,    86,   306,   366,    21,
     303,   366,   373,    21,   352,   187,   190,   191,   193,   194,
     196,   374,   375,   378,    21,   366,    21,   366,    21,   366,
      21,   366,   236,   236,   266,   351,   351,   351,   351,   225,
     207,   344,   344,   212,     5,     4,     5,     5,     5,   159,
     351,    21,   208,   289,    11,    21,   170,   339,     4,    21,
      21,    95,   162,     5,     5,   208,   382,   198,   379,     5,
       5,     5,    16,    11,    18,    19,   224,   230,   215,   215,
       6,   189,   214,   272,   286,   215,   218,   218,   219,     6,
     230,   247,   248,   252,   254,    11,   224,     5,   230,   214,
     272,   230,   116,   280,   234,    21,   225,    22,     4,    21,
     214,   170,     5,    20,   238,    46,   214,   244,   170,   216,
     217,     5,   289,    21,    14,     4,     5,   236,   236,   236,
     236,     5,   214,   248,   295,   214,   271,   278,   192,   282,
     286,   248,   296,   297,    21,     5,   281,   286,   309,    21,
     214,   214,   214,   214,   214,    21,    21,     5,    21,    21,
      21,   256,   214,   214,   214,    11,    21,     4,     5,   208,
      21,     4,     5,    21,    21,    21,    21,   236,     5,     5,
       5,     4,     5,     6,     5,    75,    28,   214,   214,     4,
       5,   236,   236,     6,     5,     5,    11,    20,     5,   252,
       5,     5,     5,     5,     5,   236,   225,   225,    21,   214,
      20,   239,   260,   214,   244,   215,   215,   232,   231,     5,
      21,   308,     4,     5,     5,     5,     5,     5,     5,     5,
     170,    51,   208,    20,   261,   239,    21,     4,     5,     5,
       5,     6,   281,   286,    21,   281,   214,   260,     4,    20,
     238,   309,    21,     5,   214,     5,     5,    21
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int16 yyr1[] =
{
       0,   202,   203,   203,   204,   204,   204,   205,   205,   205,
     205,   205,   205,   205,   205,   205,   205,   205,   205,   206,
     206,   206,   206,   206,   207,   207,   207,   208,   209,   209,
     210,   210,   211,   211,   211,   211,   212,   212,   213,   213,
     213,   213,   213,   213,   213,   213,   214,   214,   214,   214,
     214,   215,   215,   216,   217,   218,   218,   218,   218,   219,
     219,   219,   220,   221,   221,   221,   221,   222,   222,   222,
     222,   222,   222,   222,   222,   223,   223,   223,   223,   223,
     224,   224,   225,   226,   227,   228,   228,   228,   228,   229,
     229,   230,   230,   231,   231,   231,   232,   232,   232,   232,
     232,   233,   233,   234,   234,   234,   234,   234,   234,   234,
     234,   235,   235,   235,   235,   235,   235,   235,   235,   235,
     235,   235,   235,   235,   235,   235,   235,   235,   235,   235,
     235,   235,   235,   235,   235,   235,   235,   235,   235,   235,
     235,   235,   235,   235,   235,   235,   235,   235,   235,   235,
     235,   235,   235,   235,   235,   235,   235,   235,   236,   236,
     236,   236,   237,   237,   237,   237,   238,   238,   239,   239,
     240,   240,   240,   240,   240,   241,   241,   242,   242,   242,
     242,   243,   244,   244,   245,   245,   245,   246,   246,   247,
     247,   248,   248,   248,   248,   249,   249,   250,   251,   251,
     252,   252,   252,   252,   252,   252,   252,   252,   252,   252,
     252,   253,   253,   254,   254,   255,   255,   255,   255,   256,
     256,   256,   256,   257,   257,   257,   257,   258,   258,   259,
     259,   259,   259,   259,   260,   260,   260,   260,   261,   262,
     262,   263,   264,   264,   264,   265,   266,   266,   266,   266,
     267,   267,   268,   269,   269,   270,   271,   271,   271,   271,
     271,   272,   272,   272,   272,   273,   273,   274,   274,   274,
     274,   275,   275,   276,   276,   276,   276,   276,   277,   278,
     278,   278,   279,   280,   280,   280,   281,   281,   281,   281,
     281,   281,   281,   282,   282,   282,   282,   283,   284,   285,
     286,   286,   287,   288,   288,   288,   288,   289,   290,   290,
     291,   291,   292,   293,   294,   295,   295,   296,   296,   297,
     297,   297,   298,   298,   298,   298,   298,   299,   299,   299,
     299,   299,   299,   300,   300,   300,   301,   301,   301,   301,
     301,   301,   301,   301,   301,   301,   301,   301,   301,   301,
     301,   301,   301,   301,   301,   301,   301,   301,   301,   301,
     301,   301,   301,   301,   301,   301,   301,   301,   301,   301,
     301,   301,   301,   301,   301,   301,   301,   302,   302,   302,
     303,   303,   304,   304,   305,   305,   305,   305,   306,   307,
     308,   309,   309,   309,   309,   310,   310,   310,   310,   310,
     310,   310,   310,   311,   311,   311,   312,   312,   313,   314,
     314,   315,   315,   316,   316,   317,   317,   317,   318,   319,
     320,   320,   320,   320,   320,   321,   322,   322,   323,   323,
     324,   324,   324,   324,   325,   325,   325,   326,   326,   326,
     327,   327,   327,   328,   329,   329,   330,   330,   330,   331,
     332,   332,   333,   333,   334,   335,   335,   336,   336,   337,
     337,   338,   338,   339,   339,   340,   340,   341,   342,   342,
     342,   342,   343,   343,   344,   344,   345,   345,   345,   345,
     345,   345,   345,   345,   345,   345,   345,   345,   346,   346,
     346,   347,   347,   347,   347,   347,   348,   349,   349,   350,
     351,   351,   352,   352,   352,   352,   352,   353,   353,   354,
     355,   356,   356,   357,   358,   359,   359,   359,   360,   360,
     360,   360,   360,   360,   360,   360,   360,   361,   361,   362,
     363,   363,   363,   363,   363,   364,   364,   364,   364,   364,
     364,   364,   364,   364,   365,   365,   366,   366,   366,   367,
     367,   367,   368,   369,   370,   370,   370,   371,   371,   371,
     372,   372,   373,   373,   373,   373,   374,   374,   374,   374,
     374,   374,   375,   376,   376,   377,   378,   379,   380,   381,
     381,   382,   382,   383,   384,   384,   384,   385,   386,   386,
     386,   386,   387,   387,   388,   388,   389,   389,   390,   391,
     391,   392,   393
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     1,     3,     2,     1,     1,     1,     2,     1,
       2,     3,     2,     3,     2,     2,     3,     1,     2,     3,
       1,     1,     1,     1,     1,     2,     1,     1,     3,     1,
       2,     4,     1,     1,     1,     1,     1,     2,     1,     2,
       1,     1,     1,     1,     1,     1,     1,     2,     2,     3,
       3,     1,     3,     1,     1,     1,     3,     3,     2,     1,
       3,     2,     1,     1,     1,     1,     2,     1,     2,     3,
       4,     3,     4,     3,     4,     3,     1,     1,     4,     4,
       1,     1,     1,     1,     1,     1,     2,     3,     4,     1,
       2,     1,     3,     1,     3,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     2,     1,
       2,     2,     5,     5,     8,     5,     1,     2,     1,     1,
       2,     5,     2,     2,     2,     1,     2,     1,     1,     2,
       3,     2,     1,     1,     1,     3,     3,     1,     3,     1,
       3,     1,     3,     2,     4,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     3,     3,     4,     3,     4,     3,
       4,     1,     1,     1,     1,     1,     2,     3,     4,     1,
       2,     3,     4,     1,     2,     3,     4,     1,     4,     2,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     2,
       3,     1,     1,     1,     2,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     6,     1,     3,     3,     3,
       3,     1,     1,     4,     3,     1,     2,     1,     2,     3,
       4,     1,     5,     1,     1,     1,     1,     1,     1,     4,
       1,     4,     1,     1,     1,     1,     1,     1,     3,     1,
       4,     1,     1,     1,     4,     3,     4,     1,     2,     1,
       1,     3,     1,     3,     3,     3,     3,     1,     2,     2,
       3,     3,     3,     1,     1,     1,     3,     1,     3,     3,
       4,     1,     3,     3,     3,     3,     3,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     2,     2,     2,     3,
       2,     3,     4,     1,     2,     5,     6,     9,     2,     3,
       3,     2,     2,     2,     2,     4,     4,     4,     4,     3,
       4,     4,     2,     3,     5,     6,     2,     3,     2,     4,
       3,     2,     4,     4,     3,     2,     4,     1,     2,     2,
       1,     1,     3,     2,     4,     4,     3,     3,     2,     2,
       1,     1,     3,     1,     3,     2,     3,     4,     3,     4,
       2,     2,     2,     1,     2,     2,     4,     4,     4,     2,
       3,     2,     3,     1,     1,     1,     1,     1,     4,     3,
       4,     4,     4,     4,     4,     1,     1,     1,     1,     3,
       2,     3,     3,     3,     1,     5,     2,     1,     1,     2,
       3,     3,     1,     2,     2,     2,     2,     2,     2,     2,
       2,     3,     1,     1,     5,     1,     1,     2,     2,     3,
       2,     1,     3,     2,     4,     3,     4,     3,     1,     1,
       1,     1,     2,     3,     1,     2,     1,     1,     1,     1,
       1,     4,     1,     1,     3,     3,     1,     4,     2,     2,
       3,     1,     2,     2,     3,     1,     2,     2,     3,     2,
       1,     1,     1,     1,     1,     1,     1,     1,     4,     4,
       2,     2,     3,     1,     3,     1,     1,     2,     1,     2,
       1,     2,     1,     2,     2,     3,     3,     3,     4,     2,
       2,     2,     1,     2,     2,     2,     2,     2,     2,     1,
       1,     2,     1,     2,     1,     2,     1,     2,     2,     1,
       1,     2,     2,     2,     1,     1,     2,     1,     1,     2,
       1,     2,     1,     2,     1,     6,     1,     1,     1,     1,
       1,     1,     3,     1,     3,     3,     2,     1,     4,     1,
       4,     1,     3,     3,     3,     4,     4,     2,     1,     1,
       1,     1,     3,     4,     3,     2,     3,     4,     3,     3,
       4,     3,     3
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
#line 4232 "Parser.c"
    break;

  case 3: /* DECLARE_BODY: ATTRIBUTES _SYMB_0 DECLARATION_LIST  */
#line 648 "HAL_S.y"
                                        { (yyval.declare_body_) = make_ABdeclareBody_attributes_declarationList((yyvsp[-2].attributes_), (yyvsp[0].declaration_list_)); (yyval.declare_body_)->line_number = (yyloc).first_line; (yyval.declare_body_)->char_number = (yyloc).first_column;  }
#line 4238 "Parser.c"
    break;

  case 4: /* ATTRIBUTES: ARRAY_SPEC TYPE_AND_MINOR_ATTR  */
#line 650 "HAL_S.y"
                                            { (yyval.attributes_) = make_AAattributes_arraySpec_typeAndMinorAttr((yyvsp[-1].array_spec_), (yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4244 "Parser.c"
    break;

  case 5: /* ATTRIBUTES: ARRAY_SPEC  */
#line 651 "HAL_S.y"
               { (yyval.attributes_) = make_ABattributes_arraySpec((yyvsp[0].array_spec_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4250 "Parser.c"
    break;

  case 6: /* ATTRIBUTES: TYPE_AND_MINOR_ATTR  */
#line 652 "HAL_S.y"
                        { (yyval.attributes_) = make_ACattributes_typeAndMinorAttr((yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4256 "Parser.c"
    break;

  case 7: /* DECLARATION: NAME_ID  */
#line 654 "HAL_S.y"
                      { (yyval.declaration_) = make_AAdeclaration_nameId((yyvsp[0].name_id_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4262 "Parser.c"
    break;

  case 8: /* DECLARATION: NAME_ID ATTRIBUTES  */
#line 655 "HAL_S.y"
                       { (yyval.declaration_) = make_ABdeclaration_nameId_attributes((yyvsp[-1].name_id_), (yyvsp[0].attributes_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4268 "Parser.c"
    break;

  case 9: /* DECLARATION: _SYMB_189  */
#line 656 "HAL_S.y"
              { (yyval.declaration_) = make_ACdeclaration_labelToken((yyvsp[0].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4274 "Parser.c"
    break;

  case 10: /* DECLARATION: _SYMB_189 TYPE_AND_MINOR_ATTR  */
#line 657 "HAL_S.y"
                                  { (yyval.declaration_) = make_ACdeclaration_labelToken_type_minorAttrList((yyvsp[-1].string_), (yyvsp[0].type_and_minor_attr_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4280 "Parser.c"
    break;

  case 11: /* DECLARATION: _SYMB_189 _SYMB_121 MINOR_ATTR_LIST  */
#line 658 "HAL_S.y"
                                        { (yyval.declaration_) = make_ACdeclaration_labelToken_procedure_minorAttrList((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4286 "Parser.c"
    break;

  case 12: /* DECLARATION: _SYMB_189 _SYMB_121  */
#line 659 "HAL_S.y"
                        { (yyval.declaration_) = make_ADdeclaration_labelToken_procedure((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4292 "Parser.c"
    break;

  case 13: /* DECLARATION: _SYMB_189 _SYMB_87 TYPE_AND_MINOR_ATTR  */
#line 660 "HAL_S.y"
                                           { (yyval.declaration_) = make_ACdeclaration_labelToken_function_minorAttrList((yyvsp[-2].string_), (yyvsp[0].type_and_minor_attr_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4298 "Parser.c"
    break;

  case 14: /* DECLARATION: _SYMB_189 _SYMB_87  */
#line 661 "HAL_S.y"
                       { (yyval.declaration_) = make_ADdeclaration_labelToken_function((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4304 "Parser.c"
    break;

  case 15: /* DECLARATION: _SYMB_190 _SYMB_77  */
#line 662 "HAL_S.y"
                       { (yyval.declaration_) = make_AEdeclaration_eventToken_event((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4310 "Parser.c"
    break;

  case 16: /* DECLARATION: _SYMB_190 _SYMB_77 MINOR_ATTR_LIST  */
#line 663 "HAL_S.y"
                                       { (yyval.declaration_) = make_AFdeclaration_eventToken_event_minorAttrList((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4316 "Parser.c"
    break;

  case 17: /* DECLARATION: _SYMB_190  */
#line 664 "HAL_S.y"
              { (yyval.declaration_) = make_AGdeclaration_eventToken((yyvsp[0].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4322 "Parser.c"
    break;

  case 18: /* DECLARATION: _SYMB_190 MINOR_ATTR_LIST  */
#line 665 "HAL_S.y"
                              { (yyval.declaration_) = make_AHdeclaration_eventToken_minorAttrList((yyvsp[-1].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4328 "Parser.c"
    break;

  case 19: /* ARRAY_SPEC: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 667 "HAL_S.y"
                                                    { (yyval.array_spec_) = make_AAarraySpec_arrayHead_literalExpOrStar((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4334 "Parser.c"
    break;

  case 20: /* ARRAY_SPEC: _SYMB_87  */
#line 668 "HAL_S.y"
             { (yyval.array_spec_) = make_ABarraySpec_function(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4340 "Parser.c"
    break;

  case 21: /* ARRAY_SPEC: _SYMB_121  */
#line 669 "HAL_S.y"
              { (yyval.array_spec_) = make_ACarraySpec_procedure(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4346 "Parser.c"
    break;

  case 22: /* ARRAY_SPEC: _SYMB_123  */
#line 670 "HAL_S.y"
              { (yyval.array_spec_) = make_ADarraySpec_program(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4352 "Parser.c"
    break;

  case 23: /* ARRAY_SPEC: _SYMB_162  */
#line 671 "HAL_S.y"
              { (yyval.array_spec_) = make_AEarraySpec_task(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4358 "Parser.c"
    break;

  case 24: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC  */
#line 673 "HAL_S.y"
                                { (yyval.type_and_minor_attr_) = make_AAtypeAndMinorAttr_typeSpec((yyvsp[0].type_spec_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4364 "Parser.c"
    break;

  case 25: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC MINOR_ATTR_LIST  */
#line 674 "HAL_S.y"
                              { (yyval.type_and_minor_attr_) = make_ABtypeAndMinorAttr_typeSpec_minorAttrList((yyvsp[-1].type_spec_), (yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4370 "Parser.c"
    break;

  case 26: /* TYPE_AND_MINOR_ATTR: MINOR_ATTR_LIST  */
#line 675 "HAL_S.y"
                    { (yyval.type_and_minor_attr_) = make_ACtypeAndMinorAttr_minorAttrList((yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4376 "Parser.c"
    break;

  case 27: /* IDENTIFIER: _SYMB_192  */
#line 677 "HAL_S.y"
                       { (yyval.identifier_) = make_AAidentifier((yyvsp[0].string_)); (yyval.identifier_)->line_number = (yyloc).first_line; (yyval.identifier_)->char_number = (yyloc).first_column;  }
#line 4382 "Parser.c"
    break;

  case 28: /* SQ_DQ_NAME: DOUBLY_QUAL_NAME_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 679 "HAL_S.y"
                                                               { (yyval.sq_dq_name_) = make_AAsQdQName_doublyQualNameHead_literalExpOrStar((yyvsp[-2].doubly_qual_name_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 4388 "Parser.c"
    break;

  case 29: /* SQ_DQ_NAME: ARITH_CONV  */
#line 680 "HAL_S.y"
               { (yyval.sq_dq_name_) = make_ABsQdQName_arithConv((yyvsp[0].arith_conv_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 4394 "Parser.c"
    break;

  case 30: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_175 _SYMB_2  */
#line 682 "HAL_S.y"
                                          { (yyval.doubly_qual_name_head_) = make_AAdoublyQualNameHead_vector(); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 4400 "Parser.c"
    break;

  case 31: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_103 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_0  */
#line 683 "HAL_S.y"
                                                  { (yyval.doubly_qual_name_head_) = make_ABdoublyQualNameHead_matrix_literalExpOrStar((yyvsp[-1].literal_exp_or_star_)); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 4406 "Parser.c"
    break;

  case 32: /* ARITH_CONV: _SYMB_95  */
#line 685 "HAL_S.y"
                      { (yyval.arith_conv_) = make_AAarithConv_integer(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4412 "Parser.c"
    break;

  case 33: /* ARITH_CONV: _SYMB_139  */
#line 686 "HAL_S.y"
              { (yyval.arith_conv_) = make_ABarithConv_scalar(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4418 "Parser.c"
    break;

  case 34: /* ARITH_CONV: _SYMB_175  */
#line 687 "HAL_S.y"
              { (yyval.arith_conv_) = make_ACarithConv_vector(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4424 "Parser.c"
    break;

  case 35: /* ARITH_CONV: _SYMB_103  */
#line 688 "HAL_S.y"
              { (yyval.arith_conv_) = make_ADarithConv_matrix(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4430 "Parser.c"
    break;

  case 36: /* DECLARATION_LIST: DECLARATION  */
#line 690 "HAL_S.y"
                               { (yyval.declaration_list_) = make_AAdeclaration_list((yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 4436 "Parser.c"
    break;

  case 37: /* DECLARATION_LIST: DCL_LIST_COMMA DECLARATION  */
#line 691 "HAL_S.y"
                               { (yyval.declaration_list_) = make_ABdeclaration_list((yyvsp[-1].dcl_list_comma_), (yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 4442 "Parser.c"
    break;

  case 38: /* NAME_ID: IDENTIFIER  */
#line 693 "HAL_S.y"
                     { (yyval.name_id_) = make_AAnameId_identifier((yyvsp[0].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4448 "Parser.c"
    break;

  case 39: /* NAME_ID: IDENTIFIER _SYMB_108  */
#line 694 "HAL_S.y"
                         { (yyval.name_id_) = make_ABnameId_identifier_name((yyvsp[-1].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4454 "Parser.c"
    break;

  case 40: /* NAME_ID: BIT_ID  */
#line 695 "HAL_S.y"
           { (yyval.name_id_) = make_ACnameId_bitId((yyvsp[0].bit_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4460 "Parser.c"
    break;

  case 41: /* NAME_ID: CHAR_ID  */
#line 696 "HAL_S.y"
            { (yyval.name_id_) = make_ADnameId_charId((yyvsp[0].char_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4466 "Parser.c"
    break;

  case 42: /* NAME_ID: _SYMB_184  */
#line 697 "HAL_S.y"
              { (yyval.name_id_) = make_AEnameId_bitFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4472 "Parser.c"
    break;

  case 43: /* NAME_ID: _SYMB_185  */
#line 698 "HAL_S.y"
              { (yyval.name_id_) = make_AFnameId_charFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4478 "Parser.c"
    break;

  case 44: /* NAME_ID: _SYMB_187  */
#line 699 "HAL_S.y"
              { (yyval.name_id_) = make_AGnameId_structIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4484 "Parser.c"
    break;

  case 45: /* NAME_ID: _SYMB_188  */
#line 700 "HAL_S.y"
              { (yyval.name_id_) = make_AHnameId_structFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4490 "Parser.c"
    break;

  case 46: /* ARITH_EXP: TERM  */
#line 702 "HAL_S.y"
                 { (yyval.arith_exp_) = make_AAarithExpTerm((yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4496 "Parser.c"
    break;

  case 47: /* ARITH_EXP: PLUS TERM  */
#line 703 "HAL_S.y"
              { (yyval.arith_exp_) = make_ABarithExpPlusTerm((yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4502 "Parser.c"
    break;

  case 48: /* ARITH_EXP: MINUS TERM  */
#line 704 "HAL_S.y"
               { (yyval.arith_exp_) = make_ACarithMinusTerm((yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4508 "Parser.c"
    break;

  case 49: /* ARITH_EXP: ARITH_EXP PLUS TERM  */
#line 705 "HAL_S.y"
                        { (yyval.arith_exp_) = make_ADarithExpArithExpPlusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4514 "Parser.c"
    break;

  case 50: /* ARITH_EXP: ARITH_EXP MINUS TERM  */
#line 706 "HAL_S.y"
                         { (yyval.arith_exp_) = make_AEarithExpArithExpMinusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4520 "Parser.c"
    break;

  case 51: /* TERM: PRODUCT  */
#line 708 "HAL_S.y"
               { (yyval.term_) = make_AAtermNoDivide((yyvsp[0].product_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4526 "Parser.c"
    break;

  case 52: /* TERM: PRODUCT _SYMB_3 TERM  */
#line 709 "HAL_S.y"
                         { (yyval.term_) = make_ABtermDivide((yyvsp[-2].product_), (yyvsp[0].term_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4532 "Parser.c"
    break;

  case 53: /* PLUS: _SYMB_4  */
#line 711 "HAL_S.y"
               { (yyval.plus_) = make_AAplus(); (yyval.plus_)->line_number = (yyloc).first_line; (yyval.plus_)->char_number = (yyloc).first_column;  }
#line 4538 "Parser.c"
    break;

  case 54: /* MINUS: _SYMB_5  */
#line 713 "HAL_S.y"
                { (yyval.minus_) = make_AAminus(); (yyval.minus_)->line_number = (yyloc).first_line; (yyval.minus_)->char_number = (yyloc).first_column;  }
#line 4544 "Parser.c"
    break;

  case 55: /* PRODUCT: FACTOR  */
#line 715 "HAL_S.y"
                 { (yyval.product_) = make_AAproductSingle((yyvsp[0].factor_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4550 "Parser.c"
    break;

  case 56: /* PRODUCT: FACTOR _SYMB_6 PRODUCT  */
#line 716 "HAL_S.y"
                           { (yyval.product_) = make_ABproductCross((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4556 "Parser.c"
    break;

  case 57: /* PRODUCT: FACTOR _SYMB_7 PRODUCT  */
#line 717 "HAL_S.y"
                           { (yyval.product_) = make_ACproductDot((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4562 "Parser.c"
    break;

  case 58: /* PRODUCT: FACTOR PRODUCT  */
#line 718 "HAL_S.y"
                   { (yyval.product_) = make_ADproductMultiplication((yyvsp[-1].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4568 "Parser.c"
    break;

  case 59: /* FACTOR: PRIMARY  */
#line 720 "HAL_S.y"
                 { (yyval.factor_) = make_AAfactor((yyvsp[0].primary_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4574 "Parser.c"
    break;

  case 60: /* FACTOR: PRIMARY EXPONENTIATION FACTOR  */
#line 721 "HAL_S.y"
                                  { (yyval.factor_) = make_ABfactorExponentiation((yyvsp[-2].primary_), (yyvsp[-1].exponentiation_), (yyvsp[0].factor_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4580 "Parser.c"
    break;

  case 61: /* FACTOR: PRIMARY _SYMB_8  */
#line 722 "HAL_S.y"
                    { (yyval.factor_) = make_ABfactorTranspose((yyvsp[-1].primary_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4586 "Parser.c"
    break;

  case 62: /* EXPONENTIATION: _SYMB_9  */
#line 724 "HAL_S.y"
                         { (yyval.exponentiation_) = make_AAexponentiation(); (yyval.exponentiation_)->line_number = (yyloc).first_line; (yyval.exponentiation_)->char_number = (yyloc).first_column;  }
#line 4592 "Parser.c"
    break;

  case 63: /* PRIMARY: ARITH_VAR  */
#line 726 "HAL_S.y"
                    { (yyval.primary_) = make_AAprimary((yyvsp[0].arith_var_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4598 "Parser.c"
    break;

  case 64: /* PRIMARY: PRE_PRIMARY  */
#line 727 "HAL_S.y"
                { (yyval.primary_) = make_ADprimary((yyvsp[0].pre_primary_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4604 "Parser.c"
    break;

  case 65: /* PRIMARY: MODIFIED_ARITH_FUNC  */
#line 728 "HAL_S.y"
                        { (yyval.primary_) = make_ABprimary((yyvsp[0].modified_arith_func_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4610 "Parser.c"
    break;

  case 66: /* PRIMARY: PRE_PRIMARY QUALIFIER  */
#line 729 "HAL_S.y"
                          { (yyval.primary_) = make_AEprimary((yyvsp[-1].pre_primary_), (yyvsp[0].qualifier_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4616 "Parser.c"
    break;

  case 67: /* ARITH_VAR: ARITH_ID  */
#line 731 "HAL_S.y"
                     { (yyval.arith_var_) = make_AAarith_var((yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4622 "Parser.c"
    break;

  case 68: /* ARITH_VAR: ARITH_ID SUBSCRIPT  */
#line 732 "HAL_S.y"
                       { (yyval.arith_var_) = make_ACarith_var((yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4628 "Parser.c"
    break;

  case 69: /* ARITH_VAR: _SYMB_11 ARITH_ID _SYMB_12  */
#line 733 "HAL_S.y"
                               { (yyval.arith_var_) = make_AAarithVarBracketed((yyvsp[-1].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4634 "Parser.c"
    break;

  case 70: /* ARITH_VAR: _SYMB_11 ARITH_ID _SYMB_12 SUBSCRIPT  */
#line 734 "HAL_S.y"
                                         { (yyval.arith_var_) = make_ABarithVarBracketed((yyvsp[-2].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4640 "Parser.c"
    break;

  case 71: /* ARITH_VAR: _SYMB_13 QUAL_STRUCT _SYMB_14  */
#line 735 "HAL_S.y"
                                  { (yyval.arith_var_) = make_AAarithVarBraced((yyvsp[-1].qual_struct_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4646 "Parser.c"
    break;

  case 72: /* ARITH_VAR: _SYMB_13 QUAL_STRUCT _SYMB_14 SUBSCRIPT  */
#line 736 "HAL_S.y"
                                            { (yyval.arith_var_) = make_ABarithVarBraced((yyvsp[-2].qual_struct_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4652 "Parser.c"
    break;

  case 73: /* ARITH_VAR: QUAL_STRUCT _SYMB_7 ARITH_ID  */
#line 737 "HAL_S.y"
                                 { (yyval.arith_var_) = make_ABarith_var((yyvsp[-2].qual_struct_), (yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4658 "Parser.c"
    break;

  case 74: /* ARITH_VAR: QUAL_STRUCT _SYMB_7 ARITH_ID SUBSCRIPT  */
#line 738 "HAL_S.y"
                                           { (yyval.arith_var_) = make_ADarith_var((yyvsp[-3].qual_struct_), (yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4664 "Parser.c"
    break;

  case 75: /* PRE_PRIMARY: _SYMB_2 ARITH_EXP _SYMB_1  */
#line 740 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AApre_primary((yyvsp[-1].arith_exp_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4670 "Parser.c"
    break;

  case 76: /* PRE_PRIMARY: NUMBER  */
#line 741 "HAL_S.y"
           { (yyval.pre_primary_) = make_ABpre_primary((yyvsp[0].number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4676 "Parser.c"
    break;

  case 77: /* PRE_PRIMARY: COMPOUND_NUMBER  */
#line 742 "HAL_S.y"
                    { (yyval.pre_primary_) = make_ACpre_primary((yyvsp[0].compound_number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4682 "Parser.c"
    break;

  case 78: /* PRE_PRIMARY: ARITH_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 743 "HAL_S.y"
                                              { (yyval.pre_primary_) = make_ADprePrimaryRtlFunction((yyvsp[-3].arith_func_head_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4688 "Parser.c"
    break;

  case 79: /* PRE_PRIMARY: _SYMB_189 _SYMB_2 CALL_LIST _SYMB_1  */
#line 744 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AEprePrimaryFunction((yyvsp[-3].string_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4694 "Parser.c"
    break;

  case 80: /* NUMBER: SIMPLE_NUMBER  */
#line 746 "HAL_S.y"
                       { (yyval.number_) = make_AAnumber((yyvsp[0].simple_number_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4700 "Parser.c"
    break;

  case 81: /* NUMBER: LEVEL  */
#line 747 "HAL_S.y"
          { (yyval.number_) = make_ABnumber((yyvsp[0].level_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4706 "Parser.c"
    break;

  case 82: /* LEVEL: _SYMB_195  */
#line 749 "HAL_S.y"
                  { (yyval.level_) = make_ZZlevel((yyvsp[0].string_)); (yyval.level_)->line_number = (yyloc).first_line; (yyval.level_)->char_number = (yyloc).first_column;  }
#line 4712 "Parser.c"
    break;

  case 83: /* COMPOUND_NUMBER: _SYMB_197  */
#line 751 "HAL_S.y"
                            { (yyval.compound_number_) = make_CLcompound_number((yyvsp[0].string_)); (yyval.compound_number_)->line_number = (yyloc).first_line; (yyval.compound_number_)->char_number = (yyloc).first_column;  }
#line 4718 "Parser.c"
    break;

  case 84: /* SIMPLE_NUMBER: _SYMB_196  */
#line 753 "HAL_S.y"
                          { (yyval.simple_number_) = make_CKsimple_number((yyvsp[0].string_)); (yyval.simple_number_)->line_number = (yyloc).first_line; (yyval.simple_number_)->char_number = (yyloc).first_column;  }
#line 4724 "Parser.c"
    break;

  case 85: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC  */
#line 755 "HAL_S.y"
                                        { (yyval.modified_arith_func_) = make_AAmodified_arith_func((yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4730 "Parser.c"
    break;

  case 86: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 756 "HAL_S.y"
                                { (yyval.modified_arith_func_) = make_ACmodified_arith_func((yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4736 "Parser.c"
    break;

  case 87: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_7 NO_ARG_ARITH_FUNC  */
#line 757 "HAL_S.y"
                                          { (yyval.modified_arith_func_) = make_ADmodified_arith_func((yyvsp[-2].qual_struct_), (yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4742 "Parser.c"
    break;

  case 88: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_7 NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 758 "HAL_S.y"
                                                    { (yyval.modified_arith_func_) = make_AEmodified_arith_func((yyvsp[-3].qual_struct_), (yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4748 "Parser.c"
    break;

  case 89: /* ARITH_FUNC_HEAD: ARITH_FUNC  */
#line 760 "HAL_S.y"
                             { (yyval.arith_func_head_) = make_AAarith_func_head((yyvsp[0].arith_func_)); (yyval.arith_func_head_)->line_number = (yyloc).first_line; (yyval.arith_func_head_)->char_number = (yyloc).first_column;  }
#line 4754 "Parser.c"
    break;

  case 90: /* ARITH_FUNC_HEAD: ARITH_CONV SUBSCRIPT  */
#line 761 "HAL_S.y"
                         { (yyval.arith_func_head_) = make_ABarith_func_head((yyvsp[-1].arith_conv_), (yyvsp[0].subscript_)); (yyval.arith_func_head_)->line_number = (yyloc).first_line; (yyval.arith_func_head_)->char_number = (yyloc).first_column;  }
#line 4760 "Parser.c"
    break;

  case 91: /* CALL_LIST: LIST_EXP  */
#line 763 "HAL_S.y"
                     { (yyval.call_list_) = make_AAcall_list((yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 4766 "Parser.c"
    break;

  case 92: /* CALL_LIST: CALL_LIST _SYMB_0 LIST_EXP  */
#line 764 "HAL_S.y"
                               { (yyval.call_list_) = make_ABcall_list((yyvsp[-2].call_list_), (yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 4772 "Parser.c"
    break;

  case 93: /* LIST_EXP: EXPRESSION  */
#line 766 "HAL_S.y"
                      { (yyval.list_exp_) = make_AAlist_exp((yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4778 "Parser.c"
    break;

  case 94: /* LIST_EXP: ARITH_EXP _SYMB_10 EXPRESSION  */
#line 767 "HAL_S.y"
                                  { (yyval.list_exp_) = make_ABlist_exp((yyvsp[-2].arith_exp_), (yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4784 "Parser.c"
    break;

  case 95: /* LIST_EXP: QUAL_STRUCT  */
#line 768 "HAL_S.y"
                { (yyval.list_exp_) = make_ADlist_exp((yyvsp[0].qual_struct_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4790 "Parser.c"
    break;

  case 96: /* EXPRESSION: ARITH_EXP  */
#line 770 "HAL_S.y"
                       { (yyval.expression_) = make_AAexpression((yyvsp[0].arith_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4796 "Parser.c"
    break;

  case 97: /* EXPRESSION: BIT_EXP  */
#line 771 "HAL_S.y"
            { (yyval.expression_) = make_ABexpression((yyvsp[0].bit_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4802 "Parser.c"
    break;

  case 98: /* EXPRESSION: CHAR_EXP  */
#line 772 "HAL_S.y"
             { (yyval.expression_) = make_ACexpression((yyvsp[0].char_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4808 "Parser.c"
    break;

  case 99: /* EXPRESSION: NAME_EXP  */
#line 773 "HAL_S.y"
             { (yyval.expression_) = make_AEexpression((yyvsp[0].name_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4814 "Parser.c"
    break;

  case 100: /* EXPRESSION: STRUCTURE_EXP  */
#line 774 "HAL_S.y"
                  { (yyval.expression_) = make_ADexpression((yyvsp[0].structure_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4820 "Parser.c"
    break;

  case 101: /* ARITH_ID: IDENTIFIER  */
#line 776 "HAL_S.y"
                      { (yyval.arith_id_) = make_FGarith_id((yyvsp[0].identifier_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 4826 "Parser.c"
    break;

  case 102: /* ARITH_ID: _SYMB_191  */
#line 777 "HAL_S.y"
              { (yyval.arith_id_) = make_FHarith_id((yyvsp[0].string_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 4832 "Parser.c"
    break;

  case 103: /* NO_ARG_ARITH_FUNC: _SYMB_55  */
#line 779 "HAL_S.y"
                             { (yyval.no_arg_arith_func_) = make_ZZclocktime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4838 "Parser.c"
    break;

  case 104: /* NO_ARG_ARITH_FUNC: _SYMB_62  */
#line 780 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZdate(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4844 "Parser.c"
    break;

  case 105: /* NO_ARG_ARITH_FUNC: _SYMB_74  */
#line 781 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZerrgrp(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4850 "Parser.c"
    break;

  case 106: /* NO_ARG_ARITH_FUNC: _SYMB_75  */
#line 782 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZerrnum(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4856 "Parser.c"
    break;

  case 107: /* NO_ARG_ARITH_FUNC: _SYMB_119  */
#line 783 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZprio(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4862 "Parser.c"
    break;

  case 108: /* NO_ARG_ARITH_FUNC: _SYMB_124  */
#line 784 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZrandom(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4868 "Parser.c"
    break;

  case 109: /* NO_ARG_ARITH_FUNC: _SYMB_125  */
#line 785 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZrandomg(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4874 "Parser.c"
    break;

  case 110: /* NO_ARG_ARITH_FUNC: _SYMB_138  */
#line 786 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZruntime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4880 "Parser.c"
    break;

  case 111: /* ARITH_FUNC: _SYMB_109  */
#line 788 "HAL_S.y"
                       { (yyval.arith_func_) = make_ZZnextime(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4886 "Parser.c"
    break;

  case 112: /* ARITH_FUNC: _SYMB_27  */
#line 789 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabs(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4892 "Parser.c"
    break;

  case 113: /* ARITH_FUNC: _SYMB_52  */
#line 790 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZceiling(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4898 "Parser.c"
    break;

  case 114: /* ARITH_FUNC: _SYMB_68  */
#line 791 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdiv(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4904 "Parser.c"
    break;

  case 115: /* ARITH_FUNC: _SYMB_85  */
#line 792 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZfloor(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4910 "Parser.c"
    break;

  case 116: /* ARITH_FUNC: _SYMB_105  */
#line 793 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmidval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4916 "Parser.c"
    break;

  case 117: /* ARITH_FUNC: _SYMB_107  */
#line 794 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4922 "Parser.c"
    break;

  case 118: /* ARITH_FUNC: _SYMB_114  */
#line 795 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZodd(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4928 "Parser.c"
    break;

  case 119: /* ARITH_FUNC: _SYMB_129  */
#line 796 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZremainder(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4934 "Parser.c"
    break;

  case 120: /* ARITH_FUNC: _SYMB_137  */
#line 797 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZround(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4940 "Parser.c"
    break;

  case 121: /* ARITH_FUNC: _SYMB_145  */
#line 798 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsign(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4946 "Parser.c"
    break;

  case 122: /* ARITH_FUNC: _SYMB_147  */
#line 799 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsignum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4952 "Parser.c"
    break;

  case 123: /* ARITH_FUNC: _SYMB_171  */
#line 800 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtruncate(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4958 "Parser.c"
    break;

  case 124: /* ARITH_FUNC: _SYMB_33  */
#line 801 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4964 "Parser.c"
    break;

  case 125: /* ARITH_FUNC: _SYMB_34  */
#line 802 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4970 "Parser.c"
    break;

  case 126: /* ARITH_FUNC: _SYMB_35  */
#line 803 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4976 "Parser.c"
    break;

  case 127: /* ARITH_FUNC: _SYMB_36  */
#line 804 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4982 "Parser.c"
    break;

  case 128: /* ARITH_FUNC: _SYMB_38  */
#line 805 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan2(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4988 "Parser.c"
    break;

  case 129: /* ARITH_FUNC: _SYMB_37  */
#line 806 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4994 "Parser.c"
    break;

  case 130: /* ARITH_FUNC: _SYMB_39  */
#line 807 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5000 "Parser.c"
    break;

  case 131: /* ARITH_FUNC: _SYMB_60  */
#line 808 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5006 "Parser.c"
    break;

  case 132: /* ARITH_FUNC: _SYMB_61  */
#line 809 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5012 "Parser.c"
    break;

  case 133: /* ARITH_FUNC: _SYMB_81  */
#line 810 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZexp(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5018 "Parser.c"
    break;

  case 134: /* ARITH_FUNC: _SYMB_102  */
#line 811 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZlog(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5024 "Parser.c"
    break;

  case 135: /* ARITH_FUNC: _SYMB_148  */
#line 812 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5030 "Parser.c"
    break;

  case 136: /* ARITH_FUNC: _SYMB_150  */
#line 813 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5036 "Parser.c"
    break;

  case 137: /* ARITH_FUNC: _SYMB_153  */
#line 814 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsqrt(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5042 "Parser.c"
    break;

  case 138: /* ARITH_FUNC: _SYMB_160  */
#line 815 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5048 "Parser.c"
    break;

  case 139: /* ARITH_FUNC: _SYMB_161  */
#line 816 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5054 "Parser.c"
    break;

  case 140: /* ARITH_FUNC: _SYMB_143  */
#line 817 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshl(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5060 "Parser.c"
    break;

  case 141: /* ARITH_FUNC: _SYMB_144  */
#line 818 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshr(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5066 "Parser.c"
    break;

  case 142: /* ARITH_FUNC: _SYMB_28  */
#line 819 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5072 "Parser.c"
    break;

  case 143: /* ARITH_FUNC: _SYMB_67  */
#line 820 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdet(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5078 "Parser.c"
    break;

  case 144: /* ARITH_FUNC: _SYMB_167  */
#line 821 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtrace(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5084 "Parser.c"
    break;

  case 145: /* ARITH_FUNC: _SYMB_172  */
#line 822 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZunit(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5090 "Parser.c"
    break;

  case 146: /* ARITH_FUNC: _SYMB_103  */
#line 823 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmatrix(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5096 "Parser.c"
    break;

  case 147: /* ARITH_FUNC: _SYMB_93  */
#line 824 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZindex(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5102 "Parser.c"
    break;

  case 148: /* ARITH_FUNC: _SYMB_98  */
#line 825 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZlength(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5108 "Parser.c"
    break;

  case 149: /* ARITH_FUNC: _SYMB_96  */
#line 826 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZinverse(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5114 "Parser.c"
    break;

  case 150: /* ARITH_FUNC: _SYMB_168  */
#line 827 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtranspose(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5120 "Parser.c"
    break;

  case 151: /* ARITH_FUNC: _SYMB_122  */
#line 828 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZprod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5126 "Parser.c"
    break;

  case 152: /* ARITH_FUNC: _SYMB_157  */
#line 829 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5132 "Parser.c"
    break;

  case 153: /* ARITH_FUNC: _SYMB_151  */
#line 830 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsize(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5138 "Parser.c"
    break;

  case 154: /* ARITH_FUNC: _SYMB_104  */
#line 831 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmax(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5144 "Parser.c"
    break;

  case 155: /* ARITH_FUNC: _SYMB_106  */
#line 832 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5150 "Parser.c"
    break;

  case 156: /* ARITH_FUNC: _SYMB_95  */
#line 833 "HAL_S.y"
             { (yyval.arith_func_) = make_AAarithFuncInteger(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5156 "Parser.c"
    break;

  case 157: /* ARITH_FUNC: _SYMB_139  */
#line 834 "HAL_S.y"
              { (yyval.arith_func_) = make_AAarithFuncScalar(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5162 "Parser.c"
    break;

  case 158: /* SUBSCRIPT: SUB_HEAD _SYMB_1  */
#line 836 "HAL_S.y"
                             { (yyval.subscript_) = make_AAsubscript((yyvsp[-1].sub_head_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5168 "Parser.c"
    break;

  case 159: /* SUBSCRIPT: QUALIFIER  */
#line 837 "HAL_S.y"
              { (yyval.subscript_) = make_ABsubscript((yyvsp[0].qualifier_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5174 "Parser.c"
    break;

  case 160: /* SUBSCRIPT: _SYMB_15 NUMBER  */
#line 838 "HAL_S.y"
                    { (yyval.subscript_) = make_ACsubscript((yyvsp[0].number_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5180 "Parser.c"
    break;

  case 161: /* SUBSCRIPT: _SYMB_15 ARITH_VAR  */
#line 839 "HAL_S.y"
                       { (yyval.subscript_) = make_ADsubscript((yyvsp[0].arith_var_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5186 "Parser.c"
    break;

  case 162: /* QUALIFIER: _SYMB_15 _SYMB_2 _SYMB_16 PREC_SPEC _SYMB_1  */
#line 841 "HAL_S.y"
                                                        { (yyval.qualifier_) = make_AAqualifier((yyvsp[-1].prec_spec_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5192 "Parser.c"
    break;

  case 163: /* QUALIFIER: _SYMB_15 _SYMB_2 SCALE_HEAD ARITH_EXP _SYMB_1  */
#line 842 "HAL_S.y"
                                                  { (yyval.qualifier_) = make_ABqualifier((yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5198 "Parser.c"
    break;

  case 164: /* QUALIFIER: _SYMB_15 _SYMB_2 _SYMB_16 PREC_SPEC _SYMB_0 SCALE_HEAD ARITH_EXP _SYMB_1  */
#line 843 "HAL_S.y"
                                                                             { (yyval.qualifier_) = make_ACqualifier((yyvsp[-4].prec_spec_), (yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5204 "Parser.c"
    break;

  case 165: /* QUALIFIER: _SYMB_15 _SYMB_2 _SYMB_16 RADIX _SYMB_1  */
#line 844 "HAL_S.y"
                                            { (yyval.qualifier_) = make_ADqualifier((yyvsp[-1].radix_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5210 "Parser.c"
    break;

  case 166: /* SCALE_HEAD: _SYMB_16  */
#line 846 "HAL_S.y"
                      { (yyval.scale_head_) = make_AAscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 5216 "Parser.c"
    break;

  case 167: /* SCALE_HEAD: _SYMB_16 _SYMB_16  */
#line 847 "HAL_S.y"
                      { (yyval.scale_head_) = make_ABscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 5222 "Parser.c"
    break;

  case 168: /* PREC_SPEC: _SYMB_149  */
#line 849 "HAL_S.y"
                      { (yyval.prec_spec_) = make_AAprecSpecSingle(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 5228 "Parser.c"
    break;

  case 169: /* PREC_SPEC: _SYMB_70  */
#line 850 "HAL_S.y"
             { (yyval.prec_spec_) = make_ABprecSpecDouble(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 5234 "Parser.c"
    break;

  case 170: /* SUB_START: _SYMB_15 _SYMB_2  */
#line 852 "HAL_S.y"
                             { (yyval.sub_start_) = make_AAsubStartGroup(); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5240 "Parser.c"
    break;

  case 171: /* SUB_START: _SYMB_15 _SYMB_2 _SYMB_16 PREC_SPEC _SYMB_0  */
#line 853 "HAL_S.y"
                                                { (yyval.sub_start_) = make_ABsubStartPrecSpec((yyvsp[-1].prec_spec_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5246 "Parser.c"
    break;

  case 172: /* SUB_START: SUB_HEAD _SYMB_17  */
#line 854 "HAL_S.y"
                      { (yyval.sub_start_) = make_ACsubStartSemicolon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5252 "Parser.c"
    break;

  case 173: /* SUB_START: SUB_HEAD _SYMB_18  */
#line 855 "HAL_S.y"
                      { (yyval.sub_start_) = make_ADsubStartColon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5258 "Parser.c"
    break;

  case 174: /* SUB_START: SUB_HEAD _SYMB_0  */
#line 856 "HAL_S.y"
                     { (yyval.sub_start_) = make_AEsubStartComma((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5264 "Parser.c"
    break;

  case 175: /* SUB_HEAD: SUB_START  */
#line 858 "HAL_S.y"
                     { (yyval.sub_head_) = make_AAsub_head((yyvsp[0].sub_start_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 5270 "Parser.c"
    break;

  case 176: /* SUB_HEAD: SUB_START SUB  */
#line 859 "HAL_S.y"
                  { (yyval.sub_head_) = make_ABsub_head((yyvsp[-1].sub_start_), (yyvsp[0].sub_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 5276 "Parser.c"
    break;

  case 177: /* SUB: SUB_EXP  */
#line 861 "HAL_S.y"
              { (yyval.sub_) = make_AAsub((yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5282 "Parser.c"
    break;

  case 178: /* SUB: _SYMB_6  */
#line 862 "HAL_S.y"
            { (yyval.sub_) = make_ABsubStar(); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5288 "Parser.c"
    break;

  case 179: /* SUB: SUB_RUN_HEAD SUB_EXP  */
#line 863 "HAL_S.y"
                         { (yyval.sub_) = make_ACsubExp((yyvsp[-1].sub_run_head_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5294 "Parser.c"
    break;

  case 180: /* SUB: ARITH_EXP _SYMB_42 SUB_EXP  */
#line 864 "HAL_S.y"
                               { (yyval.sub_) = make_ADsubAt((yyvsp[-2].arith_exp_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5300 "Parser.c"
    break;

  case 181: /* SUB_RUN_HEAD: SUB_EXP _SYMB_166  */
#line 866 "HAL_S.y"
                                 { (yyval.sub_run_head_) = make_AAsubRunHeadTo((yyvsp[-1].sub_exp_)); (yyval.sub_run_head_)->line_number = (yyloc).first_line; (yyval.sub_run_head_)->char_number = (yyloc).first_column;  }
#line 5306 "Parser.c"
    break;

  case 182: /* SUB_EXP: ARITH_EXP  */
#line 868 "HAL_S.y"
                    { (yyval.sub_exp_) = make_AAsub_exp((yyvsp[0].arith_exp_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 5312 "Parser.c"
    break;

  case 183: /* SUB_EXP: POUND_EXPRESSION  */
#line 869 "HAL_S.y"
                     { (yyval.sub_exp_) = make_ABsub_exp((yyvsp[0].pound_expression_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 5318 "Parser.c"
    break;

  case 184: /* POUND_EXPRESSION: _SYMB_10  */
#line 871 "HAL_S.y"
                            { (yyval.pound_expression_) = make_AApound_expression(); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5324 "Parser.c"
    break;

  case 185: /* POUND_EXPRESSION: POUND_EXPRESSION PLUS TERM  */
#line 872 "HAL_S.y"
                               { (yyval.pound_expression_) = make_ABpound_expression((yyvsp[-2].pound_expression_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5330 "Parser.c"
    break;

  case 186: /* POUND_EXPRESSION: POUND_EXPRESSION MINUS TERM  */
#line 873 "HAL_S.y"
                                { (yyval.pound_expression_) = make_ACpound_expression((yyvsp[-2].pound_expression_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5336 "Parser.c"
    break;

  case 187: /* BIT_EXP: BIT_FACTOR  */
#line 875 "HAL_S.y"
                     { (yyval.bit_exp_) = make_AAbitExpFactor((yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 5342 "Parser.c"
    break;

  case 188: /* BIT_EXP: BIT_EXP OR BIT_FACTOR  */
#line 876 "HAL_S.y"
                          { (yyval.bit_exp_) = make_ABbitExpOR((yyvsp[-2].bit_exp_), (yyvsp[-1].or_), (yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 5348 "Parser.c"
    break;

  case 189: /* BIT_FACTOR: BIT_CAT  */
#line 878 "HAL_S.y"
                     { (yyval.bit_factor_) = make_AAbitFactor((yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 5354 "Parser.c"
    break;

  case 190: /* BIT_FACTOR: BIT_FACTOR AND BIT_CAT  */
#line 879 "HAL_S.y"
                           { (yyval.bit_factor_) = make_ABbitFactorAnd((yyvsp[-2].bit_factor_), (yyvsp[-1].and_), (yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 5360 "Parser.c"
    break;

  case 191: /* BIT_CAT: BIT_PRIM  */
#line 881 "HAL_S.y"
                   { (yyval.bit_cat_) = make_AAbitCatPrim((yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5366 "Parser.c"
    break;

  case 192: /* BIT_CAT: BIT_CAT CAT BIT_PRIM  */
#line 882 "HAL_S.y"
                         { (yyval.bit_cat_) = make_ABbitCatCat((yyvsp[-2].bit_cat_), (yyvsp[-1].cat_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5372 "Parser.c"
    break;

  case 193: /* BIT_CAT: NOT BIT_PRIM  */
#line 883 "HAL_S.y"
                 { (yyval.bit_cat_) = make_ACbitCatNotPrim((yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5378 "Parser.c"
    break;

  case 194: /* BIT_CAT: BIT_CAT CAT NOT BIT_PRIM  */
#line 884 "HAL_S.y"
                             { (yyval.bit_cat_) = make_ADbitCatNotCat((yyvsp[-3].bit_cat_), (yyvsp[-2].cat_), (yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5384 "Parser.c"
    break;

  case 195: /* OR: CHAR_VERTICAL_BAR  */
#line 886 "HAL_S.y"
                       { (yyval.or_) = make_AAOR((yyvsp[0].char_vertical_bar_)); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5390 "Parser.c"
    break;

  case 196: /* OR: _SYMB_117  */
#line 887 "HAL_S.y"
              { (yyval.or_) = make_ABOR(); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5396 "Parser.c"
    break;

  case 197: /* CHAR_VERTICAL_BAR: _SYMB_19  */
#line 889 "HAL_S.y"
                             { (yyval.char_vertical_bar_) = make_CFchar_vertical_bar(); (yyval.char_vertical_bar_)->line_number = (yyloc).first_line; (yyval.char_vertical_bar_)->char_number = (yyloc).first_column;  }
#line 5402 "Parser.c"
    break;

  case 198: /* AND: _SYMB_20  */
#line 891 "HAL_S.y"
               { (yyval.and_) = make_AAAND(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5408 "Parser.c"
    break;

  case 199: /* AND: _SYMB_32  */
#line 892 "HAL_S.y"
             { (yyval.and_) = make_ABAND(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5414 "Parser.c"
    break;

  case 200: /* BIT_PRIM: BIT_VAR  */
#line 894 "HAL_S.y"
                   { (yyval.bit_prim_) = make_AAbitPrimBitVar((yyvsp[0].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5420 "Parser.c"
    break;

  case 201: /* BIT_PRIM: LABEL_VAR  */
#line 895 "HAL_S.y"
              { (yyval.bit_prim_) = make_ABbitPrimLabelVar((yyvsp[0].label_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5426 "Parser.c"
    break;

  case 202: /* BIT_PRIM: EVENT_VAR  */
#line 896 "HAL_S.y"
              { (yyval.bit_prim_) = make_ACbitPrimEventVar((yyvsp[0].event_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5432 "Parser.c"
    break;

  case 203: /* BIT_PRIM: BIT_CONST  */
#line 897 "HAL_S.y"
              { (yyval.bit_prim_) = make_ADbitBitConst((yyvsp[0].bit_const_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5438 "Parser.c"
    break;

  case 204: /* BIT_PRIM: _SYMB_2 BIT_EXP _SYMB_1  */
#line 898 "HAL_S.y"
                            { (yyval.bit_prim_) = make_AEbitPrimBitExp((yyvsp[-1].bit_exp_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5444 "Parser.c"
    break;

  case 205: /* BIT_PRIM: SUBBIT_HEAD EXPRESSION _SYMB_1  */
#line 899 "HAL_S.y"
                                   { (yyval.bit_prim_) = make_AHbitPrimSubbit((yyvsp[-2].subbit_head_), (yyvsp[-1].expression_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5450 "Parser.c"
    break;

  case 206: /* BIT_PRIM: BIT_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 900 "HAL_S.y"
                                            { (yyval.bit_prim_) = make_AIbitPrimFunc((yyvsp[-3].bit_func_head_), (yyvsp[-1].call_list_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5456 "Parser.c"
    break;

  case 207: /* BIT_PRIM: _SYMB_11 BIT_VAR _SYMB_12  */
#line 901 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBracketed((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5462 "Parser.c"
    break;

  case 208: /* BIT_PRIM: _SYMB_11 BIT_VAR _SYMB_12 SUBSCRIPT  */
#line 902 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBracketed((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5468 "Parser.c"
    break;

  case 209: /* BIT_PRIM: _SYMB_13 BIT_VAR _SYMB_14  */
#line 903 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBraced((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5474 "Parser.c"
    break;

  case 210: /* BIT_PRIM: _SYMB_13 BIT_VAR _SYMB_14 SUBSCRIPT  */
#line 904 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBraced((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5480 "Parser.c"
    break;

  case 211: /* CAT: _SYMB_21  */
#line 906 "HAL_S.y"
               { (yyval.cat_) = make_AAcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5486 "Parser.c"
    break;

  case 212: /* CAT: _SYMB_51  */
#line 907 "HAL_S.y"
             { (yyval.cat_) = make_ABcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5492 "Parser.c"
    break;

  case 213: /* NOT: _SYMB_111  */
#line 909 "HAL_S.y"
                { (yyval.not_) = make_ABNOT(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5498 "Parser.c"
    break;

  case 214: /* NOT: _SYMB_22  */
#line 910 "HAL_S.y"
             { (yyval.not_) = make_ADNOT(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5504 "Parser.c"
    break;

  case 215: /* BIT_VAR: BIT_ID  */
#line 912 "HAL_S.y"
                 { (yyval.bit_var_) = make_AAbit_var((yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5510 "Parser.c"
    break;

  case 216: /* BIT_VAR: BIT_ID SUBSCRIPT  */
#line 913 "HAL_S.y"
                     { (yyval.bit_var_) = make_ACbit_var((yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5516 "Parser.c"
    break;

  case 217: /* BIT_VAR: QUAL_STRUCT _SYMB_7 BIT_ID  */
#line 914 "HAL_S.y"
                               { (yyval.bit_var_) = make_ABbit_var((yyvsp[-2].qual_struct_), (yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5522 "Parser.c"
    break;

  case 218: /* BIT_VAR: QUAL_STRUCT _SYMB_7 BIT_ID SUBSCRIPT  */
#line 915 "HAL_S.y"
                                         { (yyval.bit_var_) = make_ADbit_var((yyvsp[-3].qual_struct_), (yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5528 "Parser.c"
    break;

  case 219: /* LABEL_VAR: LABEL  */
#line 917 "HAL_S.y"
                  { (yyval.label_var_) = make_AAlabel_var((yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5534 "Parser.c"
    break;

  case 220: /* LABEL_VAR: LABEL SUBSCRIPT  */
#line 918 "HAL_S.y"
                    { (yyval.label_var_) = make_ABlabel_var((yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5540 "Parser.c"
    break;

  case 221: /* LABEL_VAR: QUAL_STRUCT _SYMB_7 LABEL  */
#line 919 "HAL_S.y"
                              { (yyval.label_var_) = make_AClabel_var((yyvsp[-2].qual_struct_), (yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5546 "Parser.c"
    break;

  case 222: /* LABEL_VAR: QUAL_STRUCT _SYMB_7 LABEL SUBSCRIPT  */
#line 920 "HAL_S.y"
                                        { (yyval.label_var_) = make_ADlabel_var((yyvsp[-3].qual_struct_), (yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5552 "Parser.c"
    break;

  case 223: /* EVENT_VAR: EVENT  */
#line 922 "HAL_S.y"
                  { (yyval.event_var_) = make_AAevent_var((yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5558 "Parser.c"
    break;

  case 224: /* EVENT_VAR: EVENT SUBSCRIPT  */
#line 923 "HAL_S.y"
                    { (yyval.event_var_) = make_ACevent_var((yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5564 "Parser.c"
    break;

  case 225: /* EVENT_VAR: QUAL_STRUCT _SYMB_7 EVENT  */
#line 924 "HAL_S.y"
                              { (yyval.event_var_) = make_ABevent_var((yyvsp[-2].qual_struct_), (yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5570 "Parser.c"
    break;

  case 226: /* EVENT_VAR: QUAL_STRUCT _SYMB_7 EVENT SUBSCRIPT  */
#line 925 "HAL_S.y"
                                        { (yyval.event_var_) = make_ADevent_var((yyvsp[-3].qual_struct_), (yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5576 "Parser.c"
    break;

  case 227: /* BIT_CONST_HEAD: RADIX  */
#line 927 "HAL_S.y"
                       { (yyval.bit_const_head_) = make_AAbit_const_head((yyvsp[0].radix_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5582 "Parser.c"
    break;

  case 228: /* BIT_CONST_HEAD: RADIX _SYMB_2 NUMBER _SYMB_1  */
#line 928 "HAL_S.y"
                                 { (yyval.bit_const_head_) = make_ABbit_const_head((yyvsp[-3].radix_), (yyvsp[-1].number_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5588 "Parser.c"
    break;

  case 229: /* BIT_CONST: BIT_CONST_HEAD CHAR_STRING  */
#line 930 "HAL_S.y"
                                       { (yyval.bit_const_) = make_AAbitConstString((yyvsp[-1].bit_const_head_), (yyvsp[0].char_string_)); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5594 "Parser.c"
    break;

  case 230: /* BIT_CONST: _SYMB_170  */
#line 931 "HAL_S.y"
              { (yyval.bit_const_) = make_ABbitConstTrue(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5600 "Parser.c"
    break;

  case 231: /* BIT_CONST: _SYMB_83  */
#line 932 "HAL_S.y"
             { (yyval.bit_const_) = make_ACbitConstFalse(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5606 "Parser.c"
    break;

  case 232: /* BIT_CONST: _SYMB_116  */
#line 933 "HAL_S.y"
              { (yyval.bit_const_) = make_ADbitConstOn(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5612 "Parser.c"
    break;

  case 233: /* BIT_CONST: _SYMB_115  */
#line 934 "HAL_S.y"
              { (yyval.bit_const_) = make_AEbitConstOff(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5618 "Parser.c"
    break;

  case 234: /* RADIX: _SYMB_89  */
#line 936 "HAL_S.y"
                 { (yyval.radix_) = make_AAradixHEX(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5624 "Parser.c"
    break;

  case 235: /* RADIX: _SYMB_113  */
#line 937 "HAL_S.y"
              { (yyval.radix_) = make_ABradixOCT(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5630 "Parser.c"
    break;

  case 236: /* RADIX: _SYMB_44  */
#line 938 "HAL_S.y"
             { (yyval.radix_) = make_ACradixBIN(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5636 "Parser.c"
    break;

  case 237: /* RADIX: _SYMB_63  */
#line 939 "HAL_S.y"
             { (yyval.radix_) = make_ADradixDEC(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5642 "Parser.c"
    break;

  case 238: /* CHAR_STRING: _SYMB_193  */
#line 941 "HAL_S.y"
                        { (yyval.char_string_) = make_FPchar_string((yyvsp[0].string_)); (yyval.char_string_)->line_number = (yyloc).first_line; (yyval.char_string_)->char_number = (yyloc).first_column;  }
#line 5648 "Parser.c"
    break;

  case 239: /* SUBBIT_HEAD: SUBBIT_KEY _SYMB_2  */
#line 943 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_AAsubbit_head((yyvsp[-1].subbit_key_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5654 "Parser.c"
    break;

  case 240: /* SUBBIT_HEAD: SUBBIT_KEY SUBSCRIPT _SYMB_2  */
#line 944 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_ABsubbit_head((yyvsp[-2].subbit_key_), (yyvsp[-1].subscript_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5660 "Parser.c"
    break;

  case 241: /* SUBBIT_KEY: _SYMB_156  */
#line 946 "HAL_S.y"
                       { (yyval.subbit_key_) = make_AAsubbit_key(); (yyval.subbit_key_)->line_number = (yyloc).first_line; (yyval.subbit_key_)->char_number = (yyloc).first_column;  }
#line 5666 "Parser.c"
    break;

  case 242: /* BIT_FUNC_HEAD: BIT_FUNC  */
#line 948 "HAL_S.y"
                         { (yyval.bit_func_head_) = make_AAbit_func_head((yyvsp[0].bit_func_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5672 "Parser.c"
    break;

  case 243: /* BIT_FUNC_HEAD: _SYMB_45  */
#line 949 "HAL_S.y"
             { (yyval.bit_func_head_) = make_ABbit_func_head(); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5678 "Parser.c"
    break;

  case 244: /* BIT_FUNC_HEAD: _SYMB_45 SUB_OR_QUALIFIER  */
#line 950 "HAL_S.y"
                              { (yyval.bit_func_head_) = make_ACbit_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5684 "Parser.c"
    break;

  case 245: /* BIT_ID: _SYMB_183  */
#line 952 "HAL_S.y"
                   { (yyval.bit_id_) = make_FHbit_id((yyvsp[0].string_)); (yyval.bit_id_)->line_number = (yyloc).first_line; (yyval.bit_id_)->char_number = (yyloc).first_column;  }
#line 5690 "Parser.c"
    break;

  case 246: /* LABEL: _SYMB_189  */
#line 954 "HAL_S.y"
                  { (yyval.label_) = make_FKlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5696 "Parser.c"
    break;

  case 247: /* LABEL: _SYMB_184  */
#line 955 "HAL_S.y"
              { (yyval.label_) = make_FLlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5702 "Parser.c"
    break;

  case 248: /* LABEL: _SYMB_185  */
#line 956 "HAL_S.y"
              { (yyval.label_) = make_FMlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5708 "Parser.c"
    break;

  case 249: /* LABEL: _SYMB_188  */
#line 957 "HAL_S.y"
              { (yyval.label_) = make_FNlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5714 "Parser.c"
    break;

  case 250: /* BIT_FUNC: _SYMB_179  */
#line 959 "HAL_S.y"
                     { (yyval.bit_func_) = make_ZZxor(); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5720 "Parser.c"
    break;

  case 251: /* BIT_FUNC: _SYMB_184  */
#line 960 "HAL_S.y"
              { (yyval.bit_func_) = make_ZZuserBitFunction((yyvsp[0].string_)); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5726 "Parser.c"
    break;

  case 252: /* EVENT: _SYMB_190  */
#line 962 "HAL_S.y"
                  { (yyval.event_) = make_FLevent((yyvsp[0].string_)); (yyval.event_)->line_number = (yyloc).first_line; (yyval.event_)->char_number = (yyloc).first_column;  }
#line 5732 "Parser.c"
    break;

  case 253: /* SUB_OR_QUALIFIER: SUBSCRIPT  */
#line 964 "HAL_S.y"
                             { (yyval.sub_or_qualifier_) = make_AAsub_or_qualifier((yyvsp[0].subscript_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 5738 "Parser.c"
    break;

  case 254: /* SUB_OR_QUALIFIER: BIT_QUALIFIER  */
#line 965 "HAL_S.y"
                  { (yyval.sub_or_qualifier_) = make_ABsub_or_qualifier((yyvsp[0].bit_qualifier_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 5744 "Parser.c"
    break;

  case 255: /* BIT_QUALIFIER: _SYMB_23 _SYMB_15 _SYMB_2 _SYMB_16 RADIX _SYMB_1  */
#line 967 "HAL_S.y"
                                                                 { (yyval.bit_qualifier_) = make_AAbit_qualifier((yyvsp[-1].radix_)); (yyval.bit_qualifier_)->line_number = (yyloc).first_line; (yyval.bit_qualifier_)->char_number = (yyloc).first_column;  }
#line 5750 "Parser.c"
    break;

  case 256: /* CHAR_EXP: CHAR_PRIM  */
#line 969 "HAL_S.y"
                     { (yyval.char_exp_) = make_AAcharExpPrim((yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5756 "Parser.c"
    break;

  case 257: /* CHAR_EXP: CHAR_EXP CAT CHAR_PRIM  */
#line 970 "HAL_S.y"
                           { (yyval.char_exp_) = make_ABcharExpCat((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5762 "Parser.c"
    break;

  case 258: /* CHAR_EXP: CHAR_EXP CAT ARITH_EXP  */
#line 971 "HAL_S.y"
                           { (yyval.char_exp_) = make_ACcharExpCat((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5768 "Parser.c"
    break;

  case 259: /* CHAR_EXP: ARITH_EXP CAT ARITH_EXP  */
#line 972 "HAL_S.y"
                            { (yyval.char_exp_) = make_ADcharExpCat((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5774 "Parser.c"
    break;

  case 260: /* CHAR_EXP: ARITH_EXP CAT CHAR_PRIM  */
#line 973 "HAL_S.y"
                            { (yyval.char_exp_) = make_AEcharExpCat((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5780 "Parser.c"
    break;

  case 261: /* CHAR_PRIM: CHAR_VAR  */
#line 975 "HAL_S.y"
                     { (yyval.char_prim_) = make_AAchar_prim((yyvsp[0].char_var_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5786 "Parser.c"
    break;

  case 262: /* CHAR_PRIM: CHAR_CONST  */
#line 976 "HAL_S.y"
               { (yyval.char_prim_) = make_ABchar_prim((yyvsp[0].char_const_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5792 "Parser.c"
    break;

  case 263: /* CHAR_PRIM: CHAR_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 977 "HAL_S.y"
                                             { (yyval.char_prim_) = make_AEchar_prim((yyvsp[-3].char_func_head_), (yyvsp[-1].call_list_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5798 "Parser.c"
    break;

  case 264: /* CHAR_PRIM: _SYMB_2 CHAR_EXP _SYMB_1  */
#line 978 "HAL_S.y"
                             { (yyval.char_prim_) = make_AFchar_prim((yyvsp[-1].char_exp_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5804 "Parser.c"
    break;

  case 265: /* CHAR_FUNC_HEAD: CHAR_FUNC  */
#line 980 "HAL_S.y"
                           { (yyval.char_func_head_) = make_AAchar_func_head((yyvsp[0].char_func_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 5810 "Parser.c"
    break;

  case 266: /* CHAR_FUNC_HEAD: _SYMB_54 SUB_OR_QUALIFIER  */
#line 981 "HAL_S.y"
                              { (yyval.char_func_head_) = make_ABchar_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 5816 "Parser.c"
    break;

  case 267: /* CHAR_VAR: CHAR_ID  */
#line 983 "HAL_S.y"
                   { (yyval.char_var_) = make_AAchar_var((yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5822 "Parser.c"
    break;

  case 268: /* CHAR_VAR: CHAR_ID SUBSCRIPT  */
#line 984 "HAL_S.y"
                      { (yyval.char_var_) = make_ACchar_var((yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5828 "Parser.c"
    break;

  case 269: /* CHAR_VAR: QUAL_STRUCT _SYMB_7 CHAR_ID  */
#line 985 "HAL_S.y"
                                { (yyval.char_var_) = make_ABchar_var((yyvsp[-2].qual_struct_), (yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5834 "Parser.c"
    break;

  case 270: /* CHAR_VAR: QUAL_STRUCT _SYMB_7 CHAR_ID SUBSCRIPT  */
#line 986 "HAL_S.y"
                                          { (yyval.char_var_) = make_ADchar_var((yyvsp[-3].qual_struct_), (yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5840 "Parser.c"
    break;

  case 271: /* CHAR_CONST: CHAR_STRING  */
#line 988 "HAL_S.y"
                         { (yyval.char_const_) = make_AAchar_const((yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 5846 "Parser.c"
    break;

  case 272: /* CHAR_CONST: _SYMB_53 _SYMB_2 NUMBER _SYMB_1 CHAR_STRING  */
#line 989 "HAL_S.y"
                                                { (yyval.char_const_) = make_ABchar_const((yyvsp[-2].number_), (yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 5852 "Parser.c"
    break;

  case 273: /* CHAR_FUNC: _SYMB_100  */
#line 991 "HAL_S.y"
                      { (yyval.char_func_) = make_ZZljust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5858 "Parser.c"
    break;

  case 274: /* CHAR_FUNC: _SYMB_136  */
#line 992 "HAL_S.y"
              { (yyval.char_func_) = make_ZZrjust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5864 "Parser.c"
    break;

  case 275: /* CHAR_FUNC: _SYMB_169  */
#line 993 "HAL_S.y"
              { (yyval.char_func_) = make_ZZtrim(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5870 "Parser.c"
    break;

  case 276: /* CHAR_FUNC: _SYMB_185  */
#line 994 "HAL_S.y"
              { (yyval.char_func_) = make_ZZuserCharFunction((yyvsp[0].string_)); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5876 "Parser.c"
    break;

  case 277: /* CHAR_FUNC: _SYMB_54  */
#line 995 "HAL_S.y"
             { (yyval.char_func_) = make_AAcharFuncCharacter(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5882 "Parser.c"
    break;

  case 278: /* CHAR_ID: _SYMB_186  */
#line 997 "HAL_S.y"
                    { (yyval.char_id_) = make_FIchar_id((yyvsp[0].string_)); (yyval.char_id_)->line_number = (yyloc).first_line; (yyval.char_id_)->char_number = (yyloc).first_column;  }
#line 5888 "Parser.c"
    break;

  case 279: /* NAME_EXP: NAME_KEY _SYMB_2 NAME_VAR _SYMB_1  */
#line 999 "HAL_S.y"
                                             { (yyval.name_exp_) = make_AAnameExpKeyVar((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5894 "Parser.c"
    break;

  case 280: /* NAME_EXP: _SYMB_112  */
#line 1000 "HAL_S.y"
              { (yyval.name_exp_) = make_ABnameExpNull(); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5900 "Parser.c"
    break;

  case 281: /* NAME_EXP: NAME_KEY _SYMB_2 _SYMB_112 _SYMB_1  */
#line 1001 "HAL_S.y"
                                       { (yyval.name_exp_) = make_ACnameExpKeyNull((yyvsp[-3].name_key_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5906 "Parser.c"
    break;

  case 282: /* NAME_KEY: _SYMB_108  */
#line 1003 "HAL_S.y"
                     { (yyval.name_key_) = make_AAname_key(); (yyval.name_key_)->line_number = (yyloc).first_line; (yyval.name_key_)->char_number = (yyloc).first_column;  }
#line 5912 "Parser.c"
    break;

  case 283: /* NAME_VAR: VARIABLE  */
#line 1005 "HAL_S.y"
                    { (yyval.name_var_) = make_AAname_var((yyvsp[0].variable_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5918 "Parser.c"
    break;

  case 284: /* NAME_VAR: MODIFIED_ARITH_FUNC  */
#line 1006 "HAL_S.y"
                        { (yyval.name_var_) = make_ACname_var((yyvsp[0].modified_arith_func_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5924 "Parser.c"
    break;

  case 285: /* NAME_VAR: LABEL_VAR  */
#line 1007 "HAL_S.y"
              { (yyval.name_var_) = make_ABname_var((yyvsp[0].label_var_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5930 "Parser.c"
    break;

  case 286: /* VARIABLE: ARITH_VAR  */
#line 1009 "HAL_S.y"
                     { (yyval.variable_) = make_AAvariable((yyvsp[0].arith_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5936 "Parser.c"
    break;

  case 287: /* VARIABLE: BIT_VAR  */
#line 1010 "HAL_S.y"
            { (yyval.variable_) = make_ACvariable((yyvsp[0].bit_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5942 "Parser.c"
    break;

  case 288: /* VARIABLE: SUBBIT_HEAD VARIABLE _SYMB_1  */
#line 1011 "HAL_S.y"
                                 { (yyval.variable_) = make_AEvariable((yyvsp[-2].subbit_head_), (yyvsp[-1].variable_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5948 "Parser.c"
    break;

  case 289: /* VARIABLE: CHAR_VAR  */
#line 1012 "HAL_S.y"
             { (yyval.variable_) = make_AFvariable((yyvsp[0].char_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5954 "Parser.c"
    break;

  case 290: /* VARIABLE: NAME_KEY _SYMB_2 NAME_VAR _SYMB_1  */
#line 1013 "HAL_S.y"
                                      { (yyval.variable_) = make_AGvariable((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5960 "Parser.c"
    break;

  case 291: /* VARIABLE: EVENT_VAR  */
#line 1014 "HAL_S.y"
              { (yyval.variable_) = make_ADvariable((yyvsp[0].event_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5966 "Parser.c"
    break;

  case 292: /* VARIABLE: STRUCTURE_VAR  */
#line 1015 "HAL_S.y"
                  { (yyval.variable_) = make_ABvariable((yyvsp[0].structure_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5972 "Parser.c"
    break;

  case 293: /* STRUCTURE_EXP: STRUCTURE_VAR  */
#line 1017 "HAL_S.y"
                              { (yyval.structure_exp_) = make_AAstructure_exp((yyvsp[0].structure_var_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5978 "Parser.c"
    break;

  case 294: /* STRUCTURE_EXP: STRUCT_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 1018 "HAL_S.y"
                                               { (yyval.structure_exp_) = make_ADstructure_exp((yyvsp[-3].struct_func_head_), (yyvsp[-1].call_list_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5984 "Parser.c"
    break;

  case 295: /* STRUCTURE_EXP: STRUC_INLINE_DEF CLOSING _SYMB_17  */
#line 1019 "HAL_S.y"
                                      { (yyval.structure_exp_) = make_ACstructure_exp((yyvsp[-2].struc_inline_def_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5990 "Parser.c"
    break;

  case 296: /* STRUCTURE_EXP: STRUC_INLINE_DEF BLOCK_BODY CLOSING _SYMB_17  */
#line 1020 "HAL_S.y"
                                                 { (yyval.structure_exp_) = make_AEstructure_exp((yyvsp[-3].struc_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5996 "Parser.c"
    break;

  case 297: /* STRUCT_FUNC_HEAD: STRUCT_FUNC  */
#line 1022 "HAL_S.y"
                               { (yyval.struct_func_head_) = make_AAstruct_func_head((yyvsp[0].struct_func_)); (yyval.struct_func_head_)->line_number = (yyloc).first_line; (yyval.struct_func_head_)->char_number = (yyloc).first_column;  }
#line 6002 "Parser.c"
    break;

  case 298: /* STRUCTURE_VAR: QUAL_STRUCT SUBSCRIPT  */
#line 1024 "HAL_S.y"
                                      { (yyval.structure_var_) = make_AAstructure_var((yyvsp[-1].qual_struct_), (yyvsp[0].subscript_)); (yyval.structure_var_)->line_number = (yyloc).first_line; (yyval.structure_var_)->char_number = (yyloc).first_column;  }
#line 6008 "Parser.c"
    break;

  case 299: /* STRUCT_FUNC: _SYMB_188  */
#line 1026 "HAL_S.y"
                        { (yyval.struct_func_) = make_ZZuserStructFunc((yyvsp[0].string_)); (yyval.struct_func_)->line_number = (yyloc).first_line; (yyval.struct_func_)->char_number = (yyloc).first_column;  }
#line 6014 "Parser.c"
    break;

  case 300: /* QUAL_STRUCT: STRUCTURE_ID  */
#line 1028 "HAL_S.y"
                           { (yyval.qual_struct_) = make_AAqual_struct((yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 6020 "Parser.c"
    break;

  case 301: /* QUAL_STRUCT: QUAL_STRUCT _SYMB_7 STRUCTURE_ID  */
#line 1029 "HAL_S.y"
                                     { (yyval.qual_struct_) = make_ABqual_struct((yyvsp[-2].qual_struct_), (yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 6026 "Parser.c"
    break;

  case 302: /* STRUCTURE_ID: _SYMB_187  */
#line 1031 "HAL_S.y"
                         { (yyval.structure_id_) = make_FJstructure_id((yyvsp[0].string_)); (yyval.structure_id_)->line_number = (yyloc).first_line; (yyval.structure_id_)->char_number = (yyloc).first_column;  }
#line 6032 "Parser.c"
    break;

  case 303: /* ASSIGNMENT: VARIABLE EQUALS EXPRESSION  */
#line 1033 "HAL_S.y"
                                        { (yyval.assignment_) = make_AAassignment((yyvsp[-2].variable_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6038 "Parser.c"
    break;

  case 304: /* ASSIGNMENT: VARIABLE _SYMB_0 ASSIGNMENT  */
#line 1034 "HAL_S.y"
                                { (yyval.assignment_) = make_ABassignment((yyvsp[-2].variable_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6044 "Parser.c"
    break;

  case 305: /* ASSIGNMENT: QUAL_STRUCT EQUALS EXPRESSION  */
#line 1035 "HAL_S.y"
                                  { (yyval.assignment_) = make_ACassignment((yyvsp[-2].qual_struct_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6050 "Parser.c"
    break;

  case 306: /* ASSIGNMENT: QUAL_STRUCT _SYMB_0 ASSIGNMENT  */
#line 1036 "HAL_S.y"
                                   { (yyval.assignment_) = make_ADassignment((yyvsp[-2].qual_struct_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6056 "Parser.c"
    break;

  case 307: /* EQUALS: _SYMB_24  */
#line 1038 "HAL_S.y"
                  { (yyval.equals_) = make_AAequals(); (yyval.equals_)->line_number = (yyloc).first_line; (yyval.equals_)->char_number = (yyloc).first_column;  }
#line 6062 "Parser.c"
    break;

  case 308: /* IF_STATEMENT: IF_CLAUSE STATEMENT  */
#line 1040 "HAL_S.y"
                                   { (yyval.if_statement_) = make_AAifStatement((yyvsp[-1].if_clause_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 6068 "Parser.c"
    break;

  case 309: /* IF_STATEMENT: TRUE_PART STATEMENT  */
#line 1041 "HAL_S.y"
                        { (yyval.if_statement_) = make_ABifThenElseStatement((yyvsp[-1].true_part_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 6074 "Parser.c"
    break;

  case 310: /* IF_CLAUSE: IF RELATIONAL_EXP THEN  */
#line 1043 "HAL_S.y"
                                   { (yyval.if_clause_) = make_AAifClauseRelationalExp((yyvsp[-2].if_), (yyvsp[-1].relational_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 6080 "Parser.c"
    break;

  case 311: /* IF_CLAUSE: IF BIT_EXP THEN  */
#line 1044 "HAL_S.y"
                    { (yyval.if_clause_) = make_ABifClauseBitExp((yyvsp[-2].if_), (yyvsp[-1].bit_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 6086 "Parser.c"
    break;

  case 312: /* TRUE_PART: IF_CLAUSE BASIC_STATEMENT _SYMB_71  */
#line 1046 "HAL_S.y"
                                               { (yyval.true_part_) = make_AAtrue_part((yyvsp[-2].if_clause_), (yyvsp[-1].basic_statement_)); (yyval.true_part_)->line_number = (yyloc).first_line; (yyval.true_part_)->char_number = (yyloc).first_column;  }
#line 6092 "Parser.c"
    break;

  case 313: /* IF: _SYMB_90  */
#line 1048 "HAL_S.y"
              { (yyval.if_) = make_AAif(); (yyval.if_)->line_number = (yyloc).first_line; (yyval.if_)->char_number = (yyloc).first_column;  }
#line 6098 "Parser.c"
    break;

  case 314: /* THEN: _SYMB_165  */
#line 1050 "HAL_S.y"
                 { (yyval.then_) = make_AAthen(); (yyval.then_)->line_number = (yyloc).first_line; (yyval.then_)->char_number = (yyloc).first_column;  }
#line 6104 "Parser.c"
    break;

  case 315: /* RELATIONAL_EXP: RELATIONAL_FACTOR  */
#line 1052 "HAL_S.y"
                                   { (yyval.relational_exp_) = make_AArelational_exp((yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 6110 "Parser.c"
    break;

  case 316: /* RELATIONAL_EXP: RELATIONAL_EXP OR RELATIONAL_FACTOR  */
#line 1053 "HAL_S.y"
                                        { (yyval.relational_exp_) = make_ABrelational_exp((yyvsp[-2].relational_exp_), (yyvsp[-1].or_), (yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 6116 "Parser.c"
    break;

  case 317: /* RELATIONAL_FACTOR: REL_PRIM  */
#line 1055 "HAL_S.y"
                             { (yyval.relational_factor_) = make_AArelational_factor((yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 6122 "Parser.c"
    break;

  case 318: /* RELATIONAL_FACTOR: RELATIONAL_FACTOR AND REL_PRIM  */
#line 1056 "HAL_S.y"
                                   { (yyval.relational_factor_) = make_ABrelational_factor((yyvsp[-2].relational_factor_), (yyvsp[-1].and_), (yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 6128 "Parser.c"
    break;

  case 319: /* REL_PRIM: _SYMB_2 RELATIONAL_EXP _SYMB_1  */
#line 1058 "HAL_S.y"
                                          { (yyval.rel_prim_) = make_AArel_prim((yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6134 "Parser.c"
    break;

  case 320: /* REL_PRIM: NOT _SYMB_2 RELATIONAL_EXP _SYMB_1  */
#line 1059 "HAL_S.y"
                                       { (yyval.rel_prim_) = make_ABrel_prim((yyvsp[-3].not_), (yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6140 "Parser.c"
    break;

  case 321: /* REL_PRIM: COMPARISON  */
#line 1060 "HAL_S.y"
               { (yyval.rel_prim_) = make_ACrel_prim((yyvsp[0].comparison_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6146 "Parser.c"
    break;

  case 322: /* COMPARISON: ARITH_EXP RELATIONAL_OP ARITH_EXP  */
#line 1062 "HAL_S.y"
                                               { (yyval.comparison_) = make_AAcomparison((yyvsp[-2].arith_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6152 "Parser.c"
    break;

  case 323: /* COMPARISON: CHAR_EXP RELATIONAL_OP CHAR_EXP  */
#line 1063 "HAL_S.y"
                                    { (yyval.comparison_) = make_ABcomparison((yyvsp[-2].char_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6158 "Parser.c"
    break;

  case 324: /* COMPARISON: BIT_CAT RELATIONAL_OP BIT_CAT  */
#line 1064 "HAL_S.y"
                                  { (yyval.comparison_) = make_ACcomparison((yyvsp[-2].bit_cat_), (yyvsp[-1].relational_op_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6164 "Parser.c"
    break;

  case 325: /* COMPARISON: STRUCTURE_EXP RELATIONAL_OP STRUCTURE_EXP  */
#line 1065 "HAL_S.y"
                                              { (yyval.comparison_) = make_ADcomparison((yyvsp[-2].structure_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6170 "Parser.c"
    break;

  case 326: /* COMPARISON: NAME_EXP RELATIONAL_OP NAME_EXP  */
#line 1066 "HAL_S.y"
                                    { (yyval.comparison_) = make_AEcomparison((yyvsp[-2].name_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6176 "Parser.c"
    break;

  case 327: /* RELATIONAL_OP: EQUALS  */
#line 1068 "HAL_S.y"
                       { (yyval.relational_op_) = make_AArelationalOpEQ((yyvsp[0].equals_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6182 "Parser.c"
    break;

  case 328: /* RELATIONAL_OP: _SYMB_180  */
#line 1069 "HAL_S.y"
              { (yyval.relational_op_) = make_ABrelationalOpNEQ((yyvsp[0].string_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6188 "Parser.c"
    break;

  case 329: /* RELATIONAL_OP: _SYMB_23  */
#line 1070 "HAL_S.y"
             { (yyval.relational_op_) = make_ACrelationalOpLT(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6194 "Parser.c"
    break;

  case 330: /* RELATIONAL_OP: _SYMB_25  */
#line 1071 "HAL_S.y"
             { (yyval.relational_op_) = make_ADrelationalOpGT(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6200 "Parser.c"
    break;

  case 331: /* RELATIONAL_OP: _SYMB_181  */
#line 1072 "HAL_S.y"
              { (yyval.relational_op_) = make_AErelationalOpLE((yyvsp[0].string_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6206 "Parser.c"
    break;

  case 332: /* RELATIONAL_OP: _SYMB_182  */
#line 1073 "HAL_S.y"
              { (yyval.relational_op_) = make_AFrelationalOpGE((yyvsp[0].string_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6212 "Parser.c"
    break;

  case 333: /* STATEMENT: BASIC_STATEMENT  */
#line 1075 "HAL_S.y"
                            { (yyval.statement_) = make_AAstatement((yyvsp[0].basic_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6218 "Parser.c"
    break;

  case 334: /* STATEMENT: OTHER_STATEMENT  */
#line 1076 "HAL_S.y"
                    { (yyval.statement_) = make_ABstatement((yyvsp[0].other_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6224 "Parser.c"
    break;

  case 335: /* STATEMENT: INLINE_DEFINITION  */
#line 1077 "HAL_S.y"
                      { (yyval.statement_) = make_AZstatement((yyvsp[0].inline_definition_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6230 "Parser.c"
    break;

  case 336: /* BASIC_STATEMENT: ASSIGNMENT _SYMB_17  */
#line 1079 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_ABbasicStatementAssignment((yyvsp[-1].assignment_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6236 "Parser.c"
    break;

  case 337: /* BASIC_STATEMENT: LABEL_DEFINITION BASIC_STATEMENT  */
#line 1080 "HAL_S.y"
                                     { (yyval.basic_statement_) = make_AAbasic_statement((yyvsp[-1].label_definition_), (yyvsp[0].basic_statement_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6242 "Parser.c"
    break;

  case 338: /* BASIC_STATEMENT: _SYMB_80 _SYMB_17  */
#line 1081 "HAL_S.y"
                      { (yyval.basic_statement_) = make_ACbasicStatementExit(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6248 "Parser.c"
    break;

  case 339: /* BASIC_STATEMENT: _SYMB_80 LABEL _SYMB_17  */
#line 1082 "HAL_S.y"
                            { (yyval.basic_statement_) = make_ADbasicStatementExit((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6254 "Parser.c"
    break;

  case 340: /* BASIC_STATEMENT: _SYMB_131 _SYMB_17  */
#line 1083 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AEbasicStatementRepeat(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6260 "Parser.c"
    break;

  case 341: /* BASIC_STATEMENT: _SYMB_131 LABEL _SYMB_17  */
#line 1084 "HAL_S.y"
                             { (yyval.basic_statement_) = make_AFbasicStatementRepeat((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6266 "Parser.c"
    break;

  case 342: /* BASIC_STATEMENT: _SYMB_88 _SYMB_166 LABEL _SYMB_17  */
#line 1085 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AGbasicStatementGoTo((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6272 "Parser.c"
    break;

  case 343: /* BASIC_STATEMENT: _SYMB_17  */
#line 1086 "HAL_S.y"
             { (yyval.basic_statement_) = make_AHbasicStatementEmpty(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6278 "Parser.c"
    break;

  case 344: /* BASIC_STATEMENT: CALL_KEY _SYMB_17  */
#line 1087 "HAL_S.y"
                      { (yyval.basic_statement_) = make_AIbasicStatementCall((yyvsp[-1].call_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6284 "Parser.c"
    break;

  case 345: /* BASIC_STATEMENT: CALL_KEY _SYMB_2 CALL_LIST _SYMB_1 _SYMB_17  */
#line 1088 "HAL_S.y"
                                                { (yyval.basic_statement_) = make_AJbasicStatementCall((yyvsp[-4].call_key_), (yyvsp[-2].call_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6290 "Parser.c"
    break;

  case 346: /* BASIC_STATEMENT: CALL_KEY ASSIGN _SYMB_2 CALL_ASSIGN_LIST _SYMB_1 _SYMB_17  */
#line 1089 "HAL_S.y"
                                                              { (yyval.basic_statement_) = make_AKbasicStatementCall((yyvsp[-5].call_key_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6296 "Parser.c"
    break;

  case 347: /* BASIC_STATEMENT: CALL_KEY _SYMB_2 CALL_LIST _SYMB_1 ASSIGN _SYMB_2 CALL_ASSIGN_LIST _SYMB_1 _SYMB_17  */
#line 1090 "HAL_S.y"
                                                                                        { (yyval.basic_statement_) = make_ALbasicStatementCall((yyvsp[-8].call_key_), (yyvsp[-6].call_list_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6302 "Parser.c"
    break;

  case 348: /* BASIC_STATEMENT: _SYMB_134 _SYMB_17  */
#line 1091 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AMbasicStatementReturn(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6308 "Parser.c"
    break;

  case 349: /* BASIC_STATEMENT: _SYMB_134 EXPRESSION _SYMB_17  */
#line 1092 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_ANbasicStatementReturn((yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6314 "Parser.c"
    break;

  case 350: /* BASIC_STATEMENT: DO_GROUP_HEAD ENDING _SYMB_17  */
#line 1093 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_AObasicStatementDo((yyvsp[-2].do_group_head_), (yyvsp[-1].ending_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6320 "Parser.c"
    break;

  case 351: /* BASIC_STATEMENT: READ_KEY _SYMB_17  */
#line 1094 "HAL_S.y"
                      { (yyval.basic_statement_) = make_APbasicStatementReadKey((yyvsp[-1].read_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6326 "Parser.c"
    break;

  case 352: /* BASIC_STATEMENT: READ_PHRASE _SYMB_17  */
#line 1095 "HAL_S.y"
                         { (yyval.basic_statement_) = make_AQbasicStatementReadPhrase((yyvsp[-1].read_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6332 "Parser.c"
    break;

  case 353: /* BASIC_STATEMENT: WRITE_KEY _SYMB_17  */
#line 1096 "HAL_S.y"
                       { (yyval.basic_statement_) = make_ARbasicStatementWriteKey((yyvsp[-1].write_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6338 "Parser.c"
    break;

  case 354: /* BASIC_STATEMENT: WRITE_PHRASE _SYMB_17  */
#line 1097 "HAL_S.y"
                          { (yyval.basic_statement_) = make_ASbasicStatementWritePhrase((yyvsp[-1].write_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6344 "Parser.c"
    break;

  case 355: /* BASIC_STATEMENT: FILE_EXP EQUALS EXPRESSION _SYMB_17  */
#line 1098 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_ATbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6350 "Parser.c"
    break;

  case 356: /* BASIC_STATEMENT: VARIABLE EQUALS FILE_EXP _SYMB_17  */
#line 1099 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AUbasicStatementFileExp((yyvsp[-3].variable_), (yyvsp[-2].equals_), (yyvsp[-1].file_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6356 "Parser.c"
    break;

  case 357: /* BASIC_STATEMENT: FILE_EXP EQUALS QUAL_STRUCT _SYMB_17  */
#line 1100 "HAL_S.y"
                                         { (yyval.basic_statement_) = make_AVbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].qual_struct_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6362 "Parser.c"
    break;

  case 358: /* BASIC_STATEMENT: WAIT_KEY _SYMB_86 _SYMB_66 _SYMB_17  */
#line 1101 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_AVbasicStatementWait((yyvsp[-3].wait_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6368 "Parser.c"
    break;

  case 359: /* BASIC_STATEMENT: WAIT_KEY ARITH_EXP _SYMB_17  */
#line 1102 "HAL_S.y"
                                { (yyval.basic_statement_) = make_AWbasicStatementWait((yyvsp[-2].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6374 "Parser.c"
    break;

  case 360: /* BASIC_STATEMENT: WAIT_KEY _SYMB_173 ARITH_EXP _SYMB_17  */
#line 1103 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_AXbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6380 "Parser.c"
    break;

  case 361: /* BASIC_STATEMENT: WAIT_KEY _SYMB_86 BIT_EXP _SYMB_17  */
#line 1104 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_AYbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].bit_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6386 "Parser.c"
    break;

  case 362: /* BASIC_STATEMENT: TERMINATOR _SYMB_17  */
#line 1105 "HAL_S.y"
                        { (yyval.basic_statement_) = make_AZbasicStatementTerminator((yyvsp[-1].terminator_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6392 "Parser.c"
    break;

  case 363: /* BASIC_STATEMENT: TERMINATOR TERMINATE_LIST _SYMB_17  */
#line 1106 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_BAbasicStatementTerminator((yyvsp[-2].terminator_), (yyvsp[-1].terminate_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6398 "Parser.c"
    break;

  case 364: /* BASIC_STATEMENT: _SYMB_174 _SYMB_120 _SYMB_166 ARITH_EXP _SYMB_17  */
#line 1107 "HAL_S.y"
                                                     { (yyval.basic_statement_) = make_BBbasicStatementUpdate((yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6404 "Parser.c"
    break;

  case 365: /* BASIC_STATEMENT: _SYMB_174 _SYMB_120 LABEL_VAR _SYMB_166 ARITH_EXP _SYMB_17  */
#line 1108 "HAL_S.y"
                                                               { (yyval.basic_statement_) = make_BCbasicStatementUpdate((yyvsp[-3].label_var_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6410 "Parser.c"
    break;

  case 366: /* BASIC_STATEMENT: SCHEDULE_PHRASE _SYMB_17  */
#line 1109 "HAL_S.y"
                             { (yyval.basic_statement_) = make_BDbasicStatementSchedule((yyvsp[-1].schedule_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6416 "Parser.c"
    break;

  case 367: /* BASIC_STATEMENT: SCHEDULE_PHRASE SCHEDULE_CONTROL _SYMB_17  */
#line 1110 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BEbasicStatementSchedule((yyvsp[-2].schedule_phrase_), (yyvsp[-1].schedule_control_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6422 "Parser.c"
    break;

  case 368: /* BASIC_STATEMENT: SIGNAL_CLAUSE _SYMB_17  */
#line 1111 "HAL_S.y"
                           { (yyval.basic_statement_) = make_BFbasicStatementSignal((yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6428 "Parser.c"
    break;

  case 369: /* BASIC_STATEMENT: _SYMB_141 _SYMB_76 SUBSCRIPT _SYMB_17  */
#line 1112 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BGbasicStatementSend((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6434 "Parser.c"
    break;

  case 370: /* BASIC_STATEMENT: _SYMB_141 _SYMB_76 _SYMB_17  */
#line 1113 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BHbasicStatementSend(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6440 "Parser.c"
    break;

  case 371: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_17  */
#line 1114 "HAL_S.y"
                       { (yyval.basic_statement_) = make_BHbasicStatementOn((yyvsp[-1].on_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6446 "Parser.c"
    break;

  case 372: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_32 SIGNAL_CLAUSE _SYMB_17  */
#line 1115 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BIbasicStatementOnAndSignal((yyvsp[-3].on_clause_), (yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6452 "Parser.c"
    break;

  case 373: /* BASIC_STATEMENT: _SYMB_115 _SYMB_76 SUBSCRIPT _SYMB_17  */
#line 1116 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BJbasicStatementOff((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6458 "Parser.c"
    break;

  case 374: /* BASIC_STATEMENT: _SYMB_115 _SYMB_76 _SYMB_17  */
#line 1117 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementOff(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6464 "Parser.c"
    break;

  case 375: /* BASIC_STATEMENT: PERCENT_MACRO_NAME _SYMB_17  */
#line 1118 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementPercentMacro((yyvsp[-1].percent_macro_name_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6470 "Parser.c"
    break;

  case 376: /* BASIC_STATEMENT: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_1 _SYMB_17  */
#line 1119 "HAL_S.y"
                                                          { (yyval.basic_statement_) = make_BLbasicStatementPercentMacro((yyvsp[-3].percent_macro_head_), (yyvsp[-2].percent_macro_arg_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6476 "Parser.c"
    break;

  case 377: /* OTHER_STATEMENT: IF_STATEMENT  */
#line 1121 "HAL_S.y"
                               { (yyval.other_statement_) = make_ABotherStatementIf((yyvsp[0].if_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6482 "Parser.c"
    break;

  case 378: /* OTHER_STATEMENT: ON_PHRASE STATEMENT  */
#line 1122 "HAL_S.y"
                        { (yyval.other_statement_) = make_AAotherStatementOn((yyvsp[-1].on_phrase_), (yyvsp[0].statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6488 "Parser.c"
    break;

  case 379: /* OTHER_STATEMENT: LABEL_DEFINITION OTHER_STATEMENT  */
#line 1123 "HAL_S.y"
                                     { (yyval.other_statement_) = make_ACother_statement((yyvsp[-1].label_definition_), (yyvsp[0].other_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6494 "Parser.c"
    break;

  case 380: /* ANY_STATEMENT: STATEMENT  */
#line 1125 "HAL_S.y"
                          { (yyval.any_statement_) = make_AAany_statement((yyvsp[0].statement_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6500 "Parser.c"
    break;

  case 381: /* ANY_STATEMENT: BLOCK_DEFINITION  */
#line 1126 "HAL_S.y"
                     { (yyval.any_statement_) = make_ABany_statement((yyvsp[0].block_definition_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6506 "Parser.c"
    break;

  case 382: /* ON_PHRASE: _SYMB_116 _SYMB_76 SUBSCRIPT  */
#line 1128 "HAL_S.y"
                                         { (yyval.on_phrase_) = make_AAon_phrase((yyvsp[0].subscript_)); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6512 "Parser.c"
    break;

  case 383: /* ON_PHRASE: _SYMB_116 _SYMB_76  */
#line 1129 "HAL_S.y"
                       { (yyval.on_phrase_) = make_ACon_phrase(); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6518 "Parser.c"
    break;

  case 384: /* ON_CLAUSE: _SYMB_116 _SYMB_76 SUBSCRIPT _SYMB_158  */
#line 1131 "HAL_S.y"
                                                   { (yyval.on_clause_) = make_AAon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6524 "Parser.c"
    break;

  case 385: /* ON_CLAUSE: _SYMB_116 _SYMB_76 SUBSCRIPT _SYMB_91  */
#line 1132 "HAL_S.y"
                                          { (yyval.on_clause_) = make_ABon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6530 "Parser.c"
    break;

  case 386: /* ON_CLAUSE: _SYMB_116 _SYMB_76 _SYMB_158  */
#line 1133 "HAL_S.y"
                                 { (yyval.on_clause_) = make_ADon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6536 "Parser.c"
    break;

  case 387: /* ON_CLAUSE: _SYMB_116 _SYMB_76 _SYMB_91  */
#line 1134 "HAL_S.y"
                                { (yyval.on_clause_) = make_AEon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6542 "Parser.c"
    break;

  case 388: /* LABEL_DEFINITION: LABEL _SYMB_18  */
#line 1136 "HAL_S.y"
                                  { (yyval.label_definition_) = make_AAlabel_definition((yyvsp[-1].label_)); (yyval.label_definition_)->line_number = (yyloc).first_line; (yyval.label_definition_)->char_number = (yyloc).first_column;  }
#line 6548 "Parser.c"
    break;

  case 389: /* CALL_KEY: _SYMB_48 LABEL_VAR  */
#line 1138 "HAL_S.y"
                              { (yyval.call_key_) = make_AAcall_key((yyvsp[0].label_var_)); (yyval.call_key_)->line_number = (yyloc).first_line; (yyval.call_key_)->char_number = (yyloc).first_column;  }
#line 6554 "Parser.c"
    break;

  case 390: /* ASSIGN: _SYMB_41  */
#line 1140 "HAL_S.y"
                  { (yyval.assign_) = make_AAassign(); (yyval.assign_)->line_number = (yyloc).first_line; (yyval.assign_)->char_number = (yyloc).first_column;  }
#line 6560 "Parser.c"
    break;

  case 391: /* CALL_ASSIGN_LIST: VARIABLE  */
#line 1142 "HAL_S.y"
                            { (yyval.call_assign_list_) = make_AAcall_assign_list((yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6566 "Parser.c"
    break;

  case 392: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_0 VARIABLE  */
#line 1143 "HAL_S.y"
                                      { (yyval.call_assign_list_) = make_ABcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6572 "Parser.c"
    break;

  case 393: /* CALL_ASSIGN_LIST: QUAL_STRUCT  */
#line 1144 "HAL_S.y"
                { (yyval.call_assign_list_) = make_ACcall_assign_list((yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6578 "Parser.c"
    break;

  case 394: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_0 QUAL_STRUCT  */
#line 1145 "HAL_S.y"
                                         { (yyval.call_assign_list_) = make_ADcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6584 "Parser.c"
    break;

  case 395: /* DO_GROUP_HEAD: _SYMB_69 _SYMB_17  */
#line 1147 "HAL_S.y"
                                  { (yyval.do_group_head_) = make_AAdoGroupHead(); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6590 "Parser.c"
    break;

  case 396: /* DO_GROUP_HEAD: _SYMB_69 FOR_LIST _SYMB_17  */
#line 1148 "HAL_S.y"
                               { (yyval.do_group_head_) = make_ABdoGroupHeadFor((yyvsp[-1].for_list_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6596 "Parser.c"
    break;

  case 397: /* DO_GROUP_HEAD: _SYMB_69 FOR_LIST WHILE_CLAUSE _SYMB_17  */
#line 1149 "HAL_S.y"
                                            { (yyval.do_group_head_) = make_ACdoGroupHeadForWhile((yyvsp[-2].for_list_), (yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6602 "Parser.c"
    break;

  case 398: /* DO_GROUP_HEAD: _SYMB_69 WHILE_CLAUSE _SYMB_17  */
#line 1150 "HAL_S.y"
                                   { (yyval.do_group_head_) = make_ADdoGroupHeadWhile((yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6608 "Parser.c"
    break;

  case 399: /* DO_GROUP_HEAD: _SYMB_69 _SYMB_50 ARITH_EXP _SYMB_17  */
#line 1151 "HAL_S.y"
                                         { (yyval.do_group_head_) = make_AEdoGroupHeadCase((yyvsp[-1].arith_exp_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6614 "Parser.c"
    break;

  case 400: /* DO_GROUP_HEAD: CASE_ELSE STATEMENT  */
#line 1152 "HAL_S.y"
                        { (yyval.do_group_head_) = make_AFdoGroupHeadCaseElse((yyvsp[-1].case_else_), (yyvsp[0].statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6620 "Parser.c"
    break;

  case 401: /* DO_GROUP_HEAD: DO_GROUP_HEAD ANY_STATEMENT  */
#line 1153 "HAL_S.y"
                                { (yyval.do_group_head_) = make_AGdoGroupHeadStatement((yyvsp[-1].do_group_head_), (yyvsp[0].any_statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6626 "Parser.c"
    break;

  case 402: /* DO_GROUP_HEAD: DO_GROUP_HEAD TEMPORARY_STMT  */
#line 1154 "HAL_S.y"
                                 { (yyval.do_group_head_) = make_AHdoGroupHeadTemporaryStatement((yyvsp[-1].do_group_head_), (yyvsp[0].temporary_stmt_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6632 "Parser.c"
    break;

  case 403: /* ENDING: _SYMB_72  */
#line 1156 "HAL_S.y"
                  { (yyval.ending_) = make_AAending(); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6638 "Parser.c"
    break;

  case 404: /* ENDING: _SYMB_72 LABEL  */
#line 1157 "HAL_S.y"
                   { (yyval.ending_) = make_ABending((yyvsp[0].label_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6644 "Parser.c"
    break;

  case 405: /* ENDING: LABEL_DEFINITION ENDING  */
#line 1158 "HAL_S.y"
                            { (yyval.ending_) = make_ACending((yyvsp[-1].label_definition_), (yyvsp[0].ending_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6650 "Parser.c"
    break;

  case 406: /* READ_KEY: _SYMB_126 _SYMB_2 NUMBER _SYMB_1  */
#line 1160 "HAL_S.y"
                                            { (yyval.read_key_) = make_AAread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 6656 "Parser.c"
    break;

  case 407: /* READ_KEY: _SYMB_127 _SYMB_2 NUMBER _SYMB_1  */
#line 1161 "HAL_S.y"
                                     { (yyval.read_key_) = make_ABread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 6662 "Parser.c"
    break;

  case 408: /* WRITE_KEY: _SYMB_178 _SYMB_2 NUMBER _SYMB_1  */
#line 1163 "HAL_S.y"
                                             { (yyval.write_key_) = make_AAwrite_key((yyvsp[-1].number_)); (yyval.write_key_)->line_number = (yyloc).first_line; (yyval.write_key_)->char_number = (yyloc).first_column;  }
#line 6668 "Parser.c"
    break;

  case 409: /* READ_PHRASE: READ_KEY READ_ARG  */
#line 1165 "HAL_S.y"
                                { (yyval.read_phrase_) = make_AAread_phrase((yyvsp[-1].read_key_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 6674 "Parser.c"
    break;

  case 410: /* READ_PHRASE: READ_PHRASE _SYMB_0 READ_ARG  */
#line 1166 "HAL_S.y"
                                 { (yyval.read_phrase_) = make_ABread_phrase((yyvsp[-2].read_phrase_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 6680 "Parser.c"
    break;

  case 411: /* WRITE_PHRASE: WRITE_KEY WRITE_ARG  */
#line 1168 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_AAwrite_phrase((yyvsp[-1].write_key_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 6686 "Parser.c"
    break;

  case 412: /* WRITE_PHRASE: WRITE_PHRASE _SYMB_0 WRITE_ARG  */
#line 1169 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_ABwrite_phrase((yyvsp[-2].write_phrase_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 6692 "Parser.c"
    break;

  case 413: /* READ_ARG: VARIABLE  */
#line 1171 "HAL_S.y"
                    { (yyval.read_arg_) = make_AAread_arg((yyvsp[0].variable_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 6698 "Parser.c"
    break;

  case 414: /* READ_ARG: IO_CONTROL  */
#line 1172 "HAL_S.y"
               { (yyval.read_arg_) = make_ABread_arg((yyvsp[0].io_control_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 6704 "Parser.c"
    break;

  case 415: /* WRITE_ARG: EXPRESSION  */
#line 1174 "HAL_S.y"
                       { (yyval.write_arg_) = make_AAwrite_arg((yyvsp[0].expression_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6710 "Parser.c"
    break;

  case 416: /* WRITE_ARG: IO_CONTROL  */
#line 1175 "HAL_S.y"
               { (yyval.write_arg_) = make_ABwrite_arg((yyvsp[0].io_control_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6716 "Parser.c"
    break;

  case 417: /* WRITE_ARG: _SYMB_187  */
#line 1176 "HAL_S.y"
              { (yyval.write_arg_) = make_ACwrite_arg((yyvsp[0].string_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6722 "Parser.c"
    break;

  case 418: /* FILE_EXP: FILE_HEAD _SYMB_0 ARITH_EXP _SYMB_1  */
#line 1178 "HAL_S.y"
                                               { (yyval.file_exp_) = make_AAfile_exp((yyvsp[-3].file_head_), (yyvsp[-1].arith_exp_)); (yyval.file_exp_)->line_number = (yyloc).first_line; (yyval.file_exp_)->char_number = (yyloc).first_column;  }
#line 6728 "Parser.c"
    break;

  case 419: /* FILE_HEAD: _SYMB_84 _SYMB_2 NUMBER  */
#line 1180 "HAL_S.y"
                                    { (yyval.file_head_) = make_AAfile_head((yyvsp[0].number_)); (yyval.file_head_)->line_number = (yyloc).first_line; (yyval.file_head_)->char_number = (yyloc).first_column;  }
#line 6734 "Parser.c"
    break;

  case 420: /* IO_CONTROL: _SYMB_152 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1182 "HAL_S.y"
                                                 { (yyval.io_control_) = make_AAioControlSkip((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6740 "Parser.c"
    break;

  case 421: /* IO_CONTROL: _SYMB_159 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1183 "HAL_S.y"
                                        { (yyval.io_control_) = make_ABioControlTab((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6746 "Parser.c"
    break;

  case 422: /* IO_CONTROL: _SYMB_57 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1184 "HAL_S.y"
                                       { (yyval.io_control_) = make_ACioControlColumn((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6752 "Parser.c"
    break;

  case 423: /* IO_CONTROL: _SYMB_99 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1185 "HAL_S.y"
                                       { (yyval.io_control_) = make_ADioControlLine((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6758 "Parser.c"
    break;

  case 424: /* IO_CONTROL: _SYMB_118 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1186 "HAL_S.y"
                                        { (yyval.io_control_) = make_AEioControlPage((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6764 "Parser.c"
    break;

  case 425: /* WAIT_KEY: _SYMB_176  */
#line 1188 "HAL_S.y"
                     { (yyval.wait_key_) = make_AAwait_key(); (yyval.wait_key_)->line_number = (yyloc).first_line; (yyval.wait_key_)->char_number = (yyloc).first_column;  }
#line 6770 "Parser.c"
    break;

  case 426: /* TERMINATOR: _SYMB_164  */
#line 1190 "HAL_S.y"
                       { (yyval.terminator_) = make_AAterminatorTerminate(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 6776 "Parser.c"
    break;

  case 427: /* TERMINATOR: _SYMB_49  */
#line 1191 "HAL_S.y"
             { (yyval.terminator_) = make_ABterminatorCancel(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 6782 "Parser.c"
    break;

  case 428: /* TERMINATE_LIST: LABEL_VAR  */
#line 1193 "HAL_S.y"
                           { (yyval.terminate_list_) = make_AAterminate_list((yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 6788 "Parser.c"
    break;

  case 429: /* TERMINATE_LIST: TERMINATE_LIST _SYMB_0 LABEL_VAR  */
#line 1194 "HAL_S.y"
                                     { (yyval.terminate_list_) = make_ABterminate_list((yyvsp[-2].terminate_list_), (yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 6794 "Parser.c"
    break;

  case 430: /* SCHEDULE_HEAD: _SYMB_140 LABEL_VAR  */
#line 1196 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_AAscheduleHeadLabel((yyvsp[0].label_var_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6800 "Parser.c"
    break;

  case 431: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_42 ARITH_EXP  */
#line 1197 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ABscheduleHeadAt((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6806 "Parser.c"
    break;

  case 432: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_92 ARITH_EXP  */
#line 1198 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ACscheduleHeadIn((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6812 "Parser.c"
    break;

  case 433: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_116 BIT_EXP  */
#line 1199 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_ADscheduleHeadOn((yyvsp[-2].schedule_head_), (yyvsp[0].bit_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6818 "Parser.c"
    break;

  case 434: /* SCHEDULE_PHRASE: SCHEDULE_HEAD  */
#line 1201 "HAL_S.y"
                                { (yyval.schedule_phrase_) = make_AAschedule_phrase((yyvsp[0].schedule_head_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6824 "Parser.c"
    break;

  case 435: /* SCHEDULE_PHRASE: SCHEDULE_HEAD _SYMB_120 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1202 "HAL_S.y"
                                                      { (yyval.schedule_phrase_) = make_ABschedule_phrase((yyvsp[-4].schedule_head_), (yyvsp[-1].arith_exp_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6830 "Parser.c"
    break;

  case 436: /* SCHEDULE_PHRASE: SCHEDULE_PHRASE _SYMB_66  */
#line 1203 "HAL_S.y"
                             { (yyval.schedule_phrase_) = make_ACschedule_phrase((yyvsp[-1].schedule_phrase_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6836 "Parser.c"
    break;

  case 437: /* SCHEDULE_CONTROL: STOPPING  */
#line 1205 "HAL_S.y"
                            { (yyval.schedule_control_) = make_AAschedule_control((yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6842 "Parser.c"
    break;

  case 438: /* SCHEDULE_CONTROL: TIMING  */
#line 1206 "HAL_S.y"
           { (yyval.schedule_control_) = make_ABschedule_control((yyvsp[0].timing_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6848 "Parser.c"
    break;

  case 439: /* SCHEDULE_CONTROL: TIMING STOPPING  */
#line 1207 "HAL_S.y"
                    { (yyval.schedule_control_) = make_ACschedule_control((yyvsp[-1].timing_), (yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6854 "Parser.c"
    break;

  case 440: /* TIMING: REPEAT _SYMB_78 ARITH_EXP  */
#line 1209 "HAL_S.y"
                                   { (yyval.timing_) = make_AAtimingEvery((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6860 "Parser.c"
    break;

  case 441: /* TIMING: REPEAT _SYMB_30 ARITH_EXP  */
#line 1210 "HAL_S.y"
                              { (yyval.timing_) = make_ABtimingAfter((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6866 "Parser.c"
    break;

  case 442: /* TIMING: REPEAT  */
#line 1211 "HAL_S.y"
           { (yyval.timing_) = make_ACtiming((yyvsp[0].repeat_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6872 "Parser.c"
    break;

  case 443: /* REPEAT: _SYMB_0 _SYMB_131  */
#line 1213 "HAL_S.y"
                           { (yyval.repeat_) = make_AArepeat(); (yyval.repeat_)->line_number = (yyloc).first_line; (yyval.repeat_)->char_number = (yyloc).first_column;  }
#line 6878 "Parser.c"
    break;

  case 444: /* STOPPING: WHILE_KEY ARITH_EXP  */
#line 1215 "HAL_S.y"
                               { (yyval.stopping_) = make_AAstopping((yyvsp[-1].while_key_), (yyvsp[0].arith_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 6884 "Parser.c"
    break;

  case 445: /* STOPPING: WHILE_KEY BIT_EXP  */
#line 1216 "HAL_S.y"
                      { (yyval.stopping_) = make_ABstopping((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 6890 "Parser.c"
    break;

  case 446: /* SIGNAL_CLAUSE: _SYMB_142 EVENT_VAR  */
#line 1218 "HAL_S.y"
                                    { (yyval.signal_clause_) = make_AAsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6896 "Parser.c"
    break;

  case 447: /* SIGNAL_CLAUSE: _SYMB_133 EVENT_VAR  */
#line 1219 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ABsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6902 "Parser.c"
    break;

  case 448: /* SIGNAL_CLAUSE: _SYMB_146 EVENT_VAR  */
#line 1220 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ACsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6908 "Parser.c"
    break;

  case 449: /* PERCENT_MACRO_NAME: _SYMB_26 IDENTIFIER  */
#line 1222 "HAL_S.y"
                                         { (yyval.percent_macro_name_) = make_FNpercent_macro_name((yyvsp[0].identifier_)); (yyval.percent_macro_name_)->line_number = (yyloc).first_line; (yyval.percent_macro_name_)->char_number = (yyloc).first_column;  }
#line 6914 "Parser.c"
    break;

  case 450: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_NAME _SYMB_2  */
#line 1224 "HAL_S.y"
                                                { (yyval.percent_macro_head_) = make_AApercent_macro_head((yyvsp[-1].percent_macro_name_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 6920 "Parser.c"
    break;

  case 451: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_0  */
#line 1225 "HAL_S.y"
                                                 { (yyval.percent_macro_head_) = make_ABpercent_macro_head((yyvsp[-2].percent_macro_head_), (yyvsp[-1].percent_macro_arg_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 6926 "Parser.c"
    break;

  case 452: /* PERCENT_MACRO_ARG: NAME_VAR  */
#line 1227 "HAL_S.y"
                             { (yyval.percent_macro_arg_) = make_AApercent_macro_arg((yyvsp[0].name_var_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 6932 "Parser.c"
    break;

  case 453: /* PERCENT_MACRO_ARG: CONSTANT  */
#line 1228 "HAL_S.y"
             { (yyval.percent_macro_arg_) = make_ABpercent_macro_arg((yyvsp[0].constant_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 6938 "Parser.c"
    break;

  case 454: /* CASE_ELSE: _SYMB_69 _SYMB_50 ARITH_EXP _SYMB_17 _SYMB_71  */
#line 1230 "HAL_S.y"
                                                          { (yyval.case_else_) = make_AAcase_else((yyvsp[-2].arith_exp_)); (yyval.case_else_)->line_number = (yyloc).first_line; (yyval.case_else_)->char_number = (yyloc).first_column;  }
#line 6944 "Parser.c"
    break;

  case 455: /* WHILE_KEY: _SYMB_177  */
#line 1232 "HAL_S.y"
                      { (yyval.while_key_) = make_AAwhileKeyWhile(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 6950 "Parser.c"
    break;

  case 456: /* WHILE_KEY: _SYMB_173  */
#line 1233 "HAL_S.y"
              { (yyval.while_key_) = make_ABwhileKeyUntil(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 6956 "Parser.c"
    break;

  case 457: /* WHILE_CLAUSE: WHILE_KEY BIT_EXP  */
#line 1235 "HAL_S.y"
                                 { (yyval.while_clause_) = make_AAwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 6962 "Parser.c"
    break;

  case 458: /* WHILE_CLAUSE: WHILE_KEY RELATIONAL_EXP  */
#line 1236 "HAL_S.y"
                             { (yyval.while_clause_) = make_ABwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].relational_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 6968 "Parser.c"
    break;

  case 459: /* FOR_LIST: FOR_KEY ARITH_EXP ITERATION_CONTROL  */
#line 1238 "HAL_S.y"
                                               { (yyval.for_list_) = make_AAfor_list((yyvsp[-2].for_key_), (yyvsp[-1].arith_exp_), (yyvsp[0].iteration_control_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 6974 "Parser.c"
    break;

  case 460: /* FOR_LIST: FOR_KEY ITERATION_BODY  */
#line 1239 "HAL_S.y"
                           { (yyval.for_list_) = make_ABfor_list((yyvsp[-1].for_key_), (yyvsp[0].iteration_body_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 6980 "Parser.c"
    break;

  case 461: /* ITERATION_BODY: ARITH_EXP  */
#line 1241 "HAL_S.y"
                           { (yyval.iteration_body_) = make_AAiteration_body((yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 6986 "Parser.c"
    break;

  case 462: /* ITERATION_BODY: ITERATION_BODY _SYMB_0 ARITH_EXP  */
#line 1242 "HAL_S.y"
                                     { (yyval.iteration_body_) = make_ABiteration_body((yyvsp[-2].iteration_body_), (yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 6992 "Parser.c"
    break;

  case 463: /* ITERATION_CONTROL: _SYMB_166 ARITH_EXP  */
#line 1244 "HAL_S.y"
                                        { (yyval.iteration_control_) = make_AAiteration_controlTo((yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 6998 "Parser.c"
    break;

  case 464: /* ITERATION_CONTROL: _SYMB_166 ARITH_EXP _SYMB_47 ARITH_EXP  */
#line 1245 "HAL_S.y"
                                           { (yyval.iteration_control_) = make_ABiteration_controlToBy((yyvsp[-2].arith_exp_), (yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 7004 "Parser.c"
    break;

  case 465: /* FOR_KEY: _SYMB_86 ARITH_VAR EQUALS  */
#line 1247 "HAL_S.y"
                                    { (yyval.for_key_) = make_AAforKey((yyvsp[-1].arith_var_), (yyvsp[0].equals_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 7010 "Parser.c"
    break;

  case 466: /* FOR_KEY: _SYMB_86 _SYMB_163 IDENTIFIER _SYMB_24  */
#line 1248 "HAL_S.y"
                                           { (yyval.for_key_) = make_ABforKeyTemporary((yyvsp[-1].identifier_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 7016 "Parser.c"
    break;

  case 467: /* TEMPORARY_STMT: _SYMB_163 DECLARE_BODY _SYMB_17  */
#line 1250 "HAL_S.y"
                                                 { (yyval.temporary_stmt_) = make_AAtemporary_stmt((yyvsp[-1].declare_body_)); (yyval.temporary_stmt_)->line_number = (yyloc).first_line; (yyval.temporary_stmt_)->char_number = (yyloc).first_column;  }
#line 7022 "Parser.c"
    break;

  case 468: /* CONSTANT: NUMBER  */
#line 1252 "HAL_S.y"
                  { (yyval.constant_) = make_AAconstant((yyvsp[0].number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 7028 "Parser.c"
    break;

  case 469: /* CONSTANT: COMPOUND_NUMBER  */
#line 1253 "HAL_S.y"
                    { (yyval.constant_) = make_ABconstant((yyvsp[0].compound_number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 7034 "Parser.c"
    break;

  case 470: /* CONSTANT: BIT_CONST  */
#line 1254 "HAL_S.y"
              { (yyval.constant_) = make_ACconstant((yyvsp[0].bit_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 7040 "Parser.c"
    break;

  case 471: /* CONSTANT: CHAR_CONST  */
#line 1255 "HAL_S.y"
               { (yyval.constant_) = make_ADconstant((yyvsp[0].char_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 7046 "Parser.c"
    break;

  case 472: /* ARRAY_HEAD: _SYMB_40 _SYMB_2  */
#line 1257 "HAL_S.y"
                              { (yyval.array_head_) = make_AAarray_head(); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 7052 "Parser.c"
    break;

  case 473: /* ARRAY_HEAD: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_0  */
#line 1258 "HAL_S.y"
                                           { (yyval.array_head_) = make_ABarray_head((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 7058 "Parser.c"
    break;

  case 474: /* MINOR_ATTR_LIST: MINOR_ATTRIBUTE  */
#line 1260 "HAL_S.y"
                                  { (yyval.minor_attr_list_) = make_AAminor_attr_list((yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 7064 "Parser.c"
    break;

  case 475: /* MINOR_ATTR_LIST: MINOR_ATTR_LIST MINOR_ATTRIBUTE  */
#line 1261 "HAL_S.y"
                                    { (yyval.minor_attr_list_) = make_ABminor_attr_list((yyvsp[-1].minor_attr_list_), (yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 7070 "Parser.c"
    break;

  case 476: /* MINOR_ATTRIBUTE: _SYMB_154  */
#line 1263 "HAL_S.y"
                            { (yyval.minor_attribute_) = make_AAminorAttributeStatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7076 "Parser.c"
    break;

  case 477: /* MINOR_ATTRIBUTE: _SYMB_43  */
#line 1264 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ABminorAttributeAutomatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7082 "Parser.c"
    break;

  case 478: /* MINOR_ATTRIBUTE: _SYMB_65  */
#line 1265 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ACminorAttributeDense(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7088 "Parser.c"
    break;

  case 479: /* MINOR_ATTRIBUTE: _SYMB_31  */
#line 1266 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ADminorAttributeAligned(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7094 "Parser.c"
    break;

  case 480: /* MINOR_ATTRIBUTE: _SYMB_29  */
#line 1267 "HAL_S.y"
             { (yyval.minor_attribute_) = make_AEminorAttributeAccess(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7100 "Parser.c"
    break;

  case 481: /* MINOR_ATTRIBUTE: _SYMB_101 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1268 "HAL_S.y"
                                                  { (yyval.minor_attribute_) = make_AFminorAttributeLock((yyvsp[-1].literal_exp_or_star_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7106 "Parser.c"
    break;

  case 482: /* MINOR_ATTRIBUTE: _SYMB_130  */
#line 1269 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AGminorAttributeRemote(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7112 "Parser.c"
    break;

  case 483: /* MINOR_ATTRIBUTE: _SYMB_135  */
#line 1270 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AHminorAttributeRigid(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7118 "Parser.c"
    break;

  case 484: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_1  */
#line 1271 "HAL_S.y"
                                                 { (yyval.minor_attribute_) = make_AIminorAttributeRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7124 "Parser.c"
    break;

  case 485: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD _SYMB_6 _SYMB_1  */
#line 1272 "HAL_S.y"
                                       { (yyval.minor_attribute_) = make_AJminorAttributeStar((yyvsp[-2].init_or_const_head_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7130 "Parser.c"
    break;

  case 486: /* MINOR_ATTRIBUTE: _SYMB_97  */
#line 1273 "HAL_S.y"
             { (yyval.minor_attribute_) = make_AKminorAttributeLatched(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7136 "Parser.c"
    break;

  case 487: /* MINOR_ATTRIBUTE: _SYMB_110 _SYMB_2 LEVEL _SYMB_1  */
#line 1274 "HAL_S.y"
                                    { (yyval.minor_attribute_) = make_ALminorAttributeNonHal((yyvsp[-1].level_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7142 "Parser.c"
    break;

  case 488: /* INIT_OR_CONST_HEAD: _SYMB_94 _SYMB_2  */
#line 1276 "HAL_S.y"
                                      { (yyval.init_or_const_head_) = make_AAinit_or_const_headInitial(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7148 "Parser.c"
    break;

  case 489: /* INIT_OR_CONST_HEAD: _SYMB_59 _SYMB_2  */
#line 1277 "HAL_S.y"
                     { (yyval.init_or_const_head_) = make_ABinit_or_const_headConstant(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7154 "Parser.c"
    break;

  case 490: /* INIT_OR_CONST_HEAD: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_0  */
#line 1278 "HAL_S.y"
                                                 { (yyval.init_or_const_head_) = make_ACinit_or_const_headRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7160 "Parser.c"
    break;

  case 491: /* REPEATED_CONSTANT: EXPRESSION  */
#line 1280 "HAL_S.y"
                               { (yyval.repeated_constant_) = make_AArepeated_constant((yyvsp[0].expression_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7166 "Parser.c"
    break;

  case 492: /* REPEATED_CONSTANT: REPEAT_HEAD VARIABLE  */
#line 1281 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ABrepeated_constant((yyvsp[-1].repeat_head_), (yyvsp[0].variable_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7172 "Parser.c"
    break;

  case 493: /* REPEATED_CONSTANT: REPEAT_HEAD CONSTANT  */
#line 1282 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ACrepeated_constant((yyvsp[-1].repeat_head_), (yyvsp[0].constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7178 "Parser.c"
    break;

  case 494: /* REPEATED_CONSTANT: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_1  */
#line 1283 "HAL_S.y"
                                                 { (yyval.repeated_constant_) = make_ADrepeated_constant((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7184 "Parser.c"
    break;

  case 495: /* REPEATED_CONSTANT: REPEAT_HEAD  */
#line 1284 "HAL_S.y"
                { (yyval.repeated_constant_) = make_AErepeated_constant((yyvsp[0].repeat_head_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7190 "Parser.c"
    break;

  case 496: /* REPEAT_HEAD: ARITH_EXP _SYMB_10  */
#line 1286 "HAL_S.y"
                                 { (yyval.repeat_head_) = make_AArepeat_head((yyvsp[-1].arith_exp_)); (yyval.repeat_head_)->line_number = (yyloc).first_line; (yyval.repeat_head_)->char_number = (yyloc).first_column;  }
#line 7196 "Parser.c"
    break;

  case 497: /* NESTED_REPEAT_HEAD: REPEAT_HEAD _SYMB_2  */
#line 1288 "HAL_S.y"
                                         { (yyval.nested_repeat_head_) = make_AAnested_repeat_head((yyvsp[-1].repeat_head_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 7202 "Parser.c"
    break;

  case 498: /* NESTED_REPEAT_HEAD: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_0  */
#line 1289 "HAL_S.y"
                                                 { (yyval.nested_repeat_head_) = make_ABnested_repeat_head((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 7208 "Parser.c"
    break;

  case 499: /* DCL_LIST_COMMA: DECLARATION_LIST _SYMB_0  */
#line 1291 "HAL_S.y"
                                          { (yyval.dcl_list_comma_) = make_AAdcl_list_comma((yyvsp[-1].declaration_list_)); (yyval.dcl_list_comma_)->line_number = (yyloc).first_line; (yyval.dcl_list_comma_)->char_number = (yyloc).first_column;  }
#line 7214 "Parser.c"
    break;

  case 500: /* LITERAL_EXP_OR_STAR: ARITH_EXP  */
#line 1293 "HAL_S.y"
                                { (yyval.literal_exp_or_star_) = make_AAliteralExp((yyvsp[0].arith_exp_)); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7220 "Parser.c"
    break;

  case 501: /* LITERAL_EXP_OR_STAR: _SYMB_6  */
#line 1294 "HAL_S.y"
            { (yyval.literal_exp_or_star_) = make_ABliteralStar(); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7226 "Parser.c"
    break;

  case 502: /* TYPE_SPEC: STRUCT_SPEC  */
#line 1296 "HAL_S.y"
                        { (yyval.type_spec_) = make_AAtypeSpecStruct((yyvsp[0].struct_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7232 "Parser.c"
    break;

  case 503: /* TYPE_SPEC: BIT_SPEC  */
#line 1297 "HAL_S.y"
             { (yyval.type_spec_) = make_ABtypeSpecBit((yyvsp[0].bit_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7238 "Parser.c"
    break;

  case 504: /* TYPE_SPEC: CHAR_SPEC  */
#line 1298 "HAL_S.y"
              { (yyval.type_spec_) = make_ACtypeSpecChar((yyvsp[0].char_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7244 "Parser.c"
    break;

  case 505: /* TYPE_SPEC: ARITH_SPEC  */
#line 1299 "HAL_S.y"
               { (yyval.type_spec_) = make_ADtypeSpecArith((yyvsp[0].arith_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7250 "Parser.c"
    break;

  case 506: /* TYPE_SPEC: _SYMB_77  */
#line 1300 "HAL_S.y"
             { (yyval.type_spec_) = make_AEtypeSpecEvent(); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7256 "Parser.c"
    break;

  case 507: /* BIT_SPEC: _SYMB_46  */
#line 1302 "HAL_S.y"
                    { (yyval.bit_spec_) = make_AAbitSpecBoolean(); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7262 "Parser.c"
    break;

  case 508: /* BIT_SPEC: _SYMB_45 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1303 "HAL_S.y"
                                                 { (yyval.bit_spec_) = make_ABbitSpecBoolean((yyvsp[-1].literal_exp_or_star_)); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7268 "Parser.c"
    break;

  case 509: /* CHAR_SPEC: _SYMB_54 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1305 "HAL_S.y"
                                                         { (yyval.char_spec_) = make_AAchar_spec((yyvsp[-1].literal_exp_or_star_)); (yyval.char_spec_)->line_number = (yyloc).first_line; (yyval.char_spec_)->char_number = (yyloc).first_column;  }
#line 7274 "Parser.c"
    break;

  case 510: /* STRUCT_SPEC: STRUCT_TEMPLATE STRUCT_SPEC_BODY  */
#line 1307 "HAL_S.y"
                                               { (yyval.struct_spec_) = make_AAstruct_spec((yyvsp[-1].struct_template_), (yyvsp[0].struct_spec_body_)); (yyval.struct_spec_)->line_number = (yyloc).first_line; (yyval.struct_spec_)->char_number = (yyloc).first_column;  }
#line 7280 "Parser.c"
    break;

  case 511: /* STRUCT_SPEC_BODY: _SYMB_5 _SYMB_155  */
#line 1309 "HAL_S.y"
                                     { (yyval.struct_spec_body_) = make_AAstruct_spec_body(); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7286 "Parser.c"
    break;

  case 512: /* STRUCT_SPEC_BODY: STRUCT_SPEC_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1310 "HAL_S.y"
                                                 { (yyval.struct_spec_body_) = make_ABstruct_spec_body((yyvsp[-2].struct_spec_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7292 "Parser.c"
    break;

  case 513: /* STRUCT_TEMPLATE: STRUCTURE_ID  */
#line 1312 "HAL_S.y"
                               { (yyval.struct_template_) = make_FMstruct_template((yyvsp[0].structure_id_)); (yyval.struct_template_)->line_number = (yyloc).first_line; (yyval.struct_template_)->char_number = (yyloc).first_column;  }
#line 7298 "Parser.c"
    break;

  case 514: /* STRUCT_SPEC_HEAD: _SYMB_5 _SYMB_155 _SYMB_2  */
#line 1314 "HAL_S.y"
                                             { (yyval.struct_spec_head_) = make_AAstruct_spec_head(); (yyval.struct_spec_head_)->line_number = (yyloc).first_line; (yyval.struct_spec_head_)->char_number = (yyloc).first_column;  }
#line 7304 "Parser.c"
    break;

  case 515: /* ARITH_SPEC: PREC_SPEC  */
#line 1316 "HAL_S.y"
                       { (yyval.arith_spec_) = make_AAarith_spec((yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7310 "Parser.c"
    break;

  case 516: /* ARITH_SPEC: SQ_DQ_NAME  */
#line 1317 "HAL_S.y"
               { (yyval.arith_spec_) = make_ABarith_spec((yyvsp[0].sq_dq_name_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7316 "Parser.c"
    break;

  case 517: /* ARITH_SPEC: SQ_DQ_NAME PREC_SPEC  */
#line 1318 "HAL_S.y"
                         { (yyval.arith_spec_) = make_ACarith_spec((yyvsp[-1].sq_dq_name_), (yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7322 "Parser.c"
    break;

  case 518: /* COMPILATION: ANY_STATEMENT  */
#line 1320 "HAL_S.y"
                            { (yyval.compilation_) = make_AAcompilation((yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7328 "Parser.c"
    break;

  case 519: /* COMPILATION: COMPILATION ANY_STATEMENT  */
#line 1321 "HAL_S.y"
                              { (yyval.compilation_) = make_ABcompilation((yyvsp[-1].compilation_), (yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7334 "Parser.c"
    break;

  case 520: /* COMPILATION: DECLARE_STATEMENT  */
#line 1322 "HAL_S.y"
                      { (yyval.compilation_) = make_ACcompilation((yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7340 "Parser.c"
    break;

  case 521: /* COMPILATION: COMPILATION DECLARE_STATEMENT  */
#line 1323 "HAL_S.y"
                                  { (yyval.compilation_) = make_ADcompilation((yyvsp[-1].compilation_), (yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7346 "Parser.c"
    break;

  case 522: /* COMPILATION: STRUCTURE_STMT  */
#line 1324 "HAL_S.y"
                   { (yyval.compilation_) = make_AEcompilation((yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7352 "Parser.c"
    break;

  case 523: /* COMPILATION: COMPILATION STRUCTURE_STMT  */
#line 1325 "HAL_S.y"
                               { (yyval.compilation_) = make_AFcompilation((yyvsp[-1].compilation_), (yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7358 "Parser.c"
    break;

  case 524: /* COMPILATION: REPLACE_STMT _SYMB_17  */
#line 1326 "HAL_S.y"
                          { (yyval.compilation_) = make_AGcompilation((yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7364 "Parser.c"
    break;

  case 525: /* COMPILATION: COMPILATION REPLACE_STMT _SYMB_17  */
#line 1327 "HAL_S.y"
                                      { (yyval.compilation_) = make_AHcompilation((yyvsp[-2].compilation_), (yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7370 "Parser.c"
    break;

  case 526: /* COMPILATION: INIT_OR_CONST_HEAD EXPRESSION _SYMB_1  */
#line 1328 "HAL_S.y"
                                          { (yyval.compilation_) = make_AZcompilationInitOrConst((yyvsp[-2].init_or_const_head_), (yyvsp[-1].expression_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7376 "Parser.c"
    break;

  case 527: /* BLOCK_DEFINITION: BLOCK_STMT CLOSING _SYMB_17  */
#line 1330 "HAL_S.y"
                                               { (yyval.block_definition_) = make_AAblock_definition((yyvsp[-2].block_stmt_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7382 "Parser.c"
    break;

  case 528: /* BLOCK_DEFINITION: BLOCK_STMT BLOCK_BODY CLOSING _SYMB_17  */
#line 1331 "HAL_S.y"
                                           { (yyval.block_definition_) = make_ABblock_definition((yyvsp[-3].block_stmt_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7388 "Parser.c"
    break;

  case 529: /* BLOCK_STMT: BLOCK_STMT_TOP _SYMB_17  */
#line 1333 "HAL_S.y"
                                     { (yyval.block_stmt_) = make_AAblock_stmt((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_)->line_number = (yyloc).first_line; (yyval.block_stmt_)->char_number = (yyloc).first_column;  }
#line 7394 "Parser.c"
    break;

  case 530: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_29  */
#line 1335 "HAL_S.y"
                                         { (yyval.block_stmt_top_) = make_AAblockTopAccess((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7400 "Parser.c"
    break;

  case 531: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_135  */
#line 1336 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ABblockTopRigid((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7406 "Parser.c"
    break;

  case 532: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD  */
#line 1337 "HAL_S.y"
                    { (yyval.block_stmt_top_) = make_ACblockTopHead((yyvsp[0].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7412 "Parser.c"
    break;

  case 533: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_79  */
#line 1338 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ADblockTopExclusive((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7418 "Parser.c"
    break;

  case 534: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_128  */
#line 1339 "HAL_S.y"
                              { (yyval.block_stmt_top_) = make_AEblockTopReentrant((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7424 "Parser.c"
    break;

  case 535: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_123  */
#line 1341 "HAL_S.y"
                                           { (yyval.block_stmt_head_) = make_AAblockHeadProgram((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7430 "Parser.c"
    break;

  case 536: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_58  */
#line 1342 "HAL_S.y"
                            { (yyval.block_stmt_head_) = make_ABblockHeadCompool((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7436 "Parser.c"
    break;

  case 537: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_162  */
#line 1343 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ACblockHeadTask((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7442 "Parser.c"
    break;

  case 538: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_174  */
#line 1344 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ADblockHeadUpdate((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7448 "Parser.c"
    break;

  case 539: /* BLOCK_STMT_HEAD: _SYMB_174  */
#line 1345 "HAL_S.y"
              { (yyval.block_stmt_head_) = make_AEblockHeadUpdate(); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7454 "Parser.c"
    break;

  case 540: /* BLOCK_STMT_HEAD: FUNCTION_NAME  */
#line 1346 "HAL_S.y"
                  { (yyval.block_stmt_head_) = make_AFblockHeadFunction((yyvsp[0].function_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7460 "Parser.c"
    break;

  case 541: /* BLOCK_STMT_HEAD: FUNCTION_NAME FUNC_STMT_BODY  */
#line 1347 "HAL_S.y"
                                 { (yyval.block_stmt_head_) = make_AGblockHeadFunction((yyvsp[-1].function_name_), (yyvsp[0].func_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7466 "Parser.c"
    break;

  case 542: /* BLOCK_STMT_HEAD: PROCEDURE_NAME  */
#line 1348 "HAL_S.y"
                   { (yyval.block_stmt_head_) = make_AHblockHeadProcedure((yyvsp[0].procedure_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7472 "Parser.c"
    break;

  case 543: /* BLOCK_STMT_HEAD: PROCEDURE_NAME PROC_STMT_BODY  */
#line 1349 "HAL_S.y"
                                  { (yyval.block_stmt_head_) = make_AIblockHeadProcedure((yyvsp[-1].procedure_name_), (yyvsp[0].proc_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7478 "Parser.c"
    break;

  case 544: /* LABEL_EXTERNAL: LABEL_DEFINITION  */
#line 1351 "HAL_S.y"
                                  { (yyval.label_external_) = make_AAlabel_external((yyvsp[0].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7484 "Parser.c"
    break;

  case 545: /* LABEL_EXTERNAL: LABEL_DEFINITION _SYMB_82  */
#line 1352 "HAL_S.y"
                              { (yyval.label_external_) = make_ABlabel_external((yyvsp[-1].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7490 "Parser.c"
    break;

  case 546: /* CLOSING: _SYMB_56  */
#line 1354 "HAL_S.y"
                   { (yyval.closing_) = make_AAclosing(); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7496 "Parser.c"
    break;

  case 547: /* CLOSING: _SYMB_56 LABEL  */
#line 1355 "HAL_S.y"
                   { (yyval.closing_) = make_ABclosing((yyvsp[0].label_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7502 "Parser.c"
    break;

  case 548: /* CLOSING: LABEL_DEFINITION CLOSING  */
#line 1356 "HAL_S.y"
                             { (yyval.closing_) = make_ACclosing((yyvsp[-1].label_definition_), (yyvsp[0].closing_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7508 "Parser.c"
    break;

  case 549: /* BLOCK_BODY: DECLARE_GROUP  */
#line 1358 "HAL_S.y"
                           { (yyval.block_body_) = make_ABblock_body((yyvsp[0].declare_group_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7514 "Parser.c"
    break;

  case 550: /* BLOCK_BODY: ANY_STATEMENT  */
#line 1359 "HAL_S.y"
                  { (yyval.block_body_) = make_ADblock_body((yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7520 "Parser.c"
    break;

  case 551: /* BLOCK_BODY: BLOCK_BODY ANY_STATEMENT  */
#line 1360 "HAL_S.y"
                             { (yyval.block_body_) = make_ACblock_body((yyvsp[-1].block_body_), (yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7526 "Parser.c"
    break;

  case 552: /* FUNCTION_NAME: LABEL_EXTERNAL _SYMB_87  */
#line 1362 "HAL_S.y"
                                        { (yyval.function_name_) = make_AAfunction_name((yyvsp[-1].label_external_)); (yyval.function_name_)->line_number = (yyloc).first_line; (yyval.function_name_)->char_number = (yyloc).first_column;  }
#line 7532 "Parser.c"
    break;

  case 553: /* PROCEDURE_NAME: LABEL_EXTERNAL _SYMB_121  */
#line 1364 "HAL_S.y"
                                          { (yyval.procedure_name_) = make_AAprocedure_name((yyvsp[-1].label_external_)); (yyval.procedure_name_)->line_number = (yyloc).first_line; (yyval.procedure_name_)->char_number = (yyloc).first_column;  }
#line 7538 "Parser.c"
    break;

  case 554: /* FUNC_STMT_BODY: PARAMETER_LIST  */
#line 1366 "HAL_S.y"
                                { (yyval.func_stmt_body_) = make_AAfunc_stmt_body((yyvsp[0].parameter_list_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7544 "Parser.c"
    break;

  case 555: /* FUNC_STMT_BODY: TYPE_SPEC  */
#line 1367 "HAL_S.y"
              { (yyval.func_stmt_body_) = make_ABfunc_stmt_body((yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7550 "Parser.c"
    break;

  case 556: /* FUNC_STMT_BODY: PARAMETER_LIST TYPE_SPEC  */
#line 1368 "HAL_S.y"
                             { (yyval.func_stmt_body_) = make_ACfunc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7556 "Parser.c"
    break;

  case 557: /* PROC_STMT_BODY: PARAMETER_LIST  */
#line 1370 "HAL_S.y"
                                { (yyval.proc_stmt_body_) = make_AAproc_stmt_body((yyvsp[0].parameter_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7562 "Parser.c"
    break;

  case 558: /* PROC_STMT_BODY: ASSIGN_LIST  */
#line 1371 "HAL_S.y"
                { (yyval.proc_stmt_body_) = make_ABproc_stmt_body((yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7568 "Parser.c"
    break;

  case 559: /* PROC_STMT_BODY: PARAMETER_LIST ASSIGN_LIST  */
#line 1372 "HAL_S.y"
                               { (yyval.proc_stmt_body_) = make_ACproc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7574 "Parser.c"
    break;

  case 560: /* DECLARE_GROUP: DECLARE_ELEMENT  */
#line 1374 "HAL_S.y"
                                { (yyval.declare_group_) = make_AAdeclare_group((yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7580 "Parser.c"
    break;

  case 561: /* DECLARE_GROUP: DECLARE_GROUP DECLARE_ELEMENT  */
#line 1375 "HAL_S.y"
                                  { (yyval.declare_group_) = make_ABdeclare_group((yyvsp[-1].declare_group_), (yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7586 "Parser.c"
    break;

  case 562: /* DECLARE_ELEMENT: DECLARE_STATEMENT  */
#line 1377 "HAL_S.y"
                                    { (yyval.declare_element_) = make_AAdeclareElementDeclare((yyvsp[0].declare_statement_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7592 "Parser.c"
    break;

  case 563: /* DECLARE_ELEMENT: REPLACE_STMT _SYMB_17  */
#line 1378 "HAL_S.y"
                          { (yyval.declare_element_) = make_ABdeclareElementReplace((yyvsp[-1].replace_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7598 "Parser.c"
    break;

  case 564: /* DECLARE_ELEMENT: STRUCTURE_STMT  */
#line 1379 "HAL_S.y"
                   { (yyval.declare_element_) = make_ACdeclareElementStructure((yyvsp[0].structure_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7604 "Parser.c"
    break;

  case 565: /* DECLARE_ELEMENT: _SYMB_73 _SYMB_82 IDENTIFIER _SYMB_166 VARIABLE _SYMB_17  */
#line 1380 "HAL_S.y"
                                                             { (yyval.declare_element_) = make_ADdeclareElementEquate((yyvsp[-3].identifier_), (yyvsp[-1].variable_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7610 "Parser.c"
    break;

  case 566: /* PARAMETER: _SYMB_192  */
#line 1382 "HAL_S.y"
                      { (yyval.parameter_) = make_AAparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7616 "Parser.c"
    break;

  case 567: /* PARAMETER: _SYMB_183  */
#line 1383 "HAL_S.y"
              { (yyval.parameter_) = make_ABparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7622 "Parser.c"
    break;

  case 568: /* PARAMETER: _SYMB_186  */
#line 1384 "HAL_S.y"
              { (yyval.parameter_) = make_ACparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7628 "Parser.c"
    break;

  case 569: /* PARAMETER: _SYMB_187  */
#line 1385 "HAL_S.y"
              { (yyval.parameter_) = make_ADparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7634 "Parser.c"
    break;

  case 570: /* PARAMETER: _SYMB_190  */
#line 1386 "HAL_S.y"
              { (yyval.parameter_) = make_AEparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7640 "Parser.c"
    break;

  case 571: /* PARAMETER: _SYMB_189  */
#line 1387 "HAL_S.y"
              { (yyval.parameter_) = make_AFparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7646 "Parser.c"
    break;

  case 572: /* PARAMETER_LIST: PARAMETER_HEAD PARAMETER _SYMB_1  */
#line 1389 "HAL_S.y"
                                                  { (yyval.parameter_list_) = make_AAparameter_list((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_list_)->line_number = (yyloc).first_line; (yyval.parameter_list_)->char_number = (yyloc).first_column;  }
#line 7652 "Parser.c"
    break;

  case 573: /* PARAMETER_HEAD: _SYMB_2  */
#line 1391 "HAL_S.y"
                         { (yyval.parameter_head_) = make_AAparameter_head(); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 7658 "Parser.c"
    break;

  case 574: /* PARAMETER_HEAD: PARAMETER_HEAD PARAMETER _SYMB_0  */
#line 1392 "HAL_S.y"
                                     { (yyval.parameter_head_) = make_ABparameter_head((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 7664 "Parser.c"
    break;

  case 575: /* DECLARE_STATEMENT: _SYMB_64 DECLARE_BODY _SYMB_17  */
#line 1394 "HAL_S.y"
                                                   { (yyval.declare_statement_) = make_AAdeclare_statement((yyvsp[-1].declare_body_)); (yyval.declare_statement_)->line_number = (yyloc).first_line; (yyval.declare_statement_)->char_number = (yyloc).first_column;  }
#line 7670 "Parser.c"
    break;

  case 576: /* ASSIGN_LIST: ASSIGN PARAMETER_LIST  */
#line 1396 "HAL_S.y"
                                    { (yyval.assign_list_) = make_AAassign_list((yyvsp[-1].assign_), (yyvsp[0].parameter_list_)); (yyval.assign_list_)->line_number = (yyloc).first_line; (yyval.assign_list_)->char_number = (yyloc).first_column;  }
#line 7676 "Parser.c"
    break;

  case 577: /* TEXT: _SYMB_194  */
#line 1398 "HAL_S.y"
                 { (yyval.text_) = make_FQtext((yyvsp[0].string_)); (yyval.text_)->line_number = (yyloc).first_line; (yyval.text_)->char_number = (yyloc).first_column;  }
#line 7682 "Parser.c"
    break;

  case 578: /* REPLACE_STMT: _SYMB_132 REPLACE_HEAD _SYMB_47 TEXT  */
#line 1400 "HAL_S.y"
                                                    { (yyval.replace_stmt_) = make_AAreplace_stmt((yyvsp[-2].replace_head_), (yyvsp[0].text_)); (yyval.replace_stmt_)->line_number = (yyloc).first_line; (yyval.replace_stmt_)->char_number = (yyloc).first_column;  }
#line 7688 "Parser.c"
    break;

  case 579: /* REPLACE_HEAD: IDENTIFIER  */
#line 1402 "HAL_S.y"
                          { (yyval.replace_head_) = make_AAreplace_head((yyvsp[0].identifier_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 7694 "Parser.c"
    break;

  case 580: /* REPLACE_HEAD: IDENTIFIER _SYMB_2 ARG_LIST _SYMB_1  */
#line 1403 "HAL_S.y"
                                        { (yyval.replace_head_) = make_ABreplace_head((yyvsp[-3].identifier_), (yyvsp[-1].arg_list_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 7700 "Parser.c"
    break;

  case 581: /* ARG_LIST: IDENTIFIER  */
#line 1405 "HAL_S.y"
                      { (yyval.arg_list_) = make_AAarg_list((yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 7706 "Parser.c"
    break;

  case 582: /* ARG_LIST: ARG_LIST _SYMB_0 IDENTIFIER  */
#line 1406 "HAL_S.y"
                                { (yyval.arg_list_) = make_ABarg_list((yyvsp[-2].arg_list_), (yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 7712 "Parser.c"
    break;

  case 583: /* STRUCTURE_STMT: _SYMB_155 STRUCT_STMT_HEAD STRUCT_STMT_TAIL  */
#line 1408 "HAL_S.y"
                                                             { (yyval.structure_stmt_) = make_AAstructure_stmt((yyvsp[-1].struct_stmt_head_), (yyvsp[0].struct_stmt_tail_)); (yyval.structure_stmt_)->line_number = (yyloc).first_line; (yyval.structure_stmt_)->char_number = (yyloc).first_column;  }
#line 7718 "Parser.c"
    break;

  case 584: /* STRUCT_STMT_HEAD: STRUCTURE_ID _SYMB_18 LEVEL  */
#line 1410 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_AAstruct_stmt_head((yyvsp[-2].structure_id_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7724 "Parser.c"
    break;

  case 585: /* STRUCT_STMT_HEAD: STRUCTURE_ID MINOR_ATTR_LIST _SYMB_18 LEVEL  */
#line 1411 "HAL_S.y"
                                                { (yyval.struct_stmt_head_) = make_ABstruct_stmt_head((yyvsp[-3].structure_id_), (yyvsp[-2].minor_attr_list_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7730 "Parser.c"
    break;

  case 586: /* STRUCT_STMT_HEAD: STRUCT_STMT_HEAD DECLARATION _SYMB_0 LEVEL  */
#line 1412 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_ACstruct_stmt_head((yyvsp[-3].struct_stmt_head_), (yyvsp[-2].declaration_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7736 "Parser.c"
    break;

  case 587: /* STRUCT_STMT_TAIL: DECLARATION _SYMB_17  */
#line 1414 "HAL_S.y"
                                        { (yyval.struct_stmt_tail_) = make_AAstruct_stmt_tail((yyvsp[-1].declaration_)); (yyval.struct_stmt_tail_)->line_number = (yyloc).first_line; (yyval.struct_stmt_tail_)->char_number = (yyloc).first_column;  }
#line 7742 "Parser.c"
    break;

  case 588: /* INLINE_DEFINITION: ARITH_INLINE  */
#line 1416 "HAL_S.y"
                                 { (yyval.inline_definition_) = make_AAinline_definition((yyvsp[0].arith_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7748 "Parser.c"
    break;

  case 589: /* INLINE_DEFINITION: BIT_INLINE  */
#line 1417 "HAL_S.y"
               { (yyval.inline_definition_) = make_ABinline_definition((yyvsp[0].bit_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7754 "Parser.c"
    break;

  case 590: /* INLINE_DEFINITION: CHAR_INLINE  */
#line 1418 "HAL_S.y"
                { (yyval.inline_definition_) = make_ACinline_definition((yyvsp[0].char_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7760 "Parser.c"
    break;

  case 591: /* INLINE_DEFINITION: STRUCTURE_EXP  */
#line 1419 "HAL_S.y"
                  { (yyval.inline_definition_) = make_ADinline_definition((yyvsp[0].structure_exp_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7766 "Parser.c"
    break;

  case 592: /* ARITH_INLINE: ARITH_INLINE_DEF CLOSING _SYMB_17  */
#line 1421 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_ACprimary((yyvsp[-2].arith_inline_def_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 7772 "Parser.c"
    break;

  case 593: /* ARITH_INLINE: ARITH_INLINE_DEF BLOCK_BODY CLOSING _SYMB_17  */
#line 1422 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_AZprimary((yyvsp[-3].arith_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 7778 "Parser.c"
    break;

  case 594: /* ARITH_INLINE_DEF: _SYMB_87 ARITH_SPEC _SYMB_17  */
#line 1424 "HAL_S.y"
                                                { (yyval.arith_inline_def_) = make_AAarith_inline_def((yyvsp[-1].arith_spec_)); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 7784 "Parser.c"
    break;

  case 595: /* ARITH_INLINE_DEF: _SYMB_87 _SYMB_17  */
#line 1425 "HAL_S.y"
                      { (yyval.arith_inline_def_) = make_ABarith_inline_def(); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 7790 "Parser.c"
    break;

  case 596: /* BIT_INLINE: BIT_INLINE_DEF CLOSING _SYMB_17  */
#line 1427 "HAL_S.y"
                                             { (yyval.bit_inline_) = make_AGbit_prim((yyvsp[-2].bit_inline_def_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 7796 "Parser.c"
    break;

  case 597: /* BIT_INLINE: BIT_INLINE_DEF BLOCK_BODY CLOSING _SYMB_17  */
#line 1428 "HAL_S.y"
                                               { (yyval.bit_inline_) = make_AZbit_prim((yyvsp[-3].bit_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 7802 "Parser.c"
    break;

  case 598: /* BIT_INLINE_DEF: _SYMB_87 BIT_SPEC _SYMB_17  */
#line 1430 "HAL_S.y"
                                            { (yyval.bit_inline_def_) = make_AAbit_inline_def((yyvsp[-1].bit_spec_)); (yyval.bit_inline_def_)->line_number = (yyloc).first_line; (yyval.bit_inline_def_)->char_number = (yyloc).first_column;  }
#line 7808 "Parser.c"
    break;

  case 599: /* CHAR_INLINE: CHAR_INLINE_DEF CLOSING _SYMB_17  */
#line 1432 "HAL_S.y"
                                               { (yyval.char_inline_) = make_ADchar_prim((yyvsp[-2].char_inline_def_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 7814 "Parser.c"
    break;

  case 600: /* CHAR_INLINE: CHAR_INLINE_DEF BLOCK_BODY CLOSING _SYMB_17  */
#line 1433 "HAL_S.y"
                                                { (yyval.char_inline_) = make_AZchar_prim((yyvsp[-3].char_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 7820 "Parser.c"
    break;

  case 601: /* CHAR_INLINE_DEF: _SYMB_87 CHAR_SPEC _SYMB_17  */
#line 1435 "HAL_S.y"
                                              { (yyval.char_inline_def_) = make_AAchar_inline_def((yyvsp[-1].char_spec_)); (yyval.char_inline_def_)->line_number = (yyloc).first_line; (yyval.char_inline_def_)->char_number = (yyloc).first_column;  }
#line 7826 "Parser.c"
    break;

  case 602: /* STRUC_INLINE_DEF: _SYMB_87 STRUCT_SPEC _SYMB_17  */
#line 1437 "HAL_S.y"
                                                 { (yyval.struc_inline_def_) = make_AAstruc_inline_def((yyvsp[-1].struct_spec_)); (yyval.struc_inline_def_)->line_number = (yyloc).first_line; (yyval.struc_inline_def_)->char_number = (yyloc).first_column;  }
#line 7832 "Parser.c"
    break;


#line 7836 "Parser.c"

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

#line 1440 "HAL_S.y"

void yyerror(const char *str)
{
  extern char *HAL_Stext;
  fprintf(stderr,"error: %d,%d: %s at %s\n",
  HAL_Slloc.first_line, HAL_Slloc.first_column, str, HAL_Stext);
}

