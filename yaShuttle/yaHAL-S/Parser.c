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
    _SYMB_198 = 457,               /* _SYMB_198  */
    _SYMB_199 = 458,               /* _SYMB_199  */
    _SYMB_200 = 459                /* _SYMB_200  */
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
  SHAPING_HEAD shaping_head_;
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
  STATEMENT statement_;
  BASIC_STATEMENT basic_statement_;
  OTHER_STATEMENT other_statement_;
  IF_STATEMENT if_statement_;
  IF_CLAUSE if_clause_;
  TRUE_PART true_part_;
  IF if_;
  THEN then_;
  RELATIONAL_EXP relational_exp_;
  RELATIONAL_FACTOR relational_factor_;
  REL_PRIM rel_prim_;
  COMPARISON comparison_;
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


#line 577 "Parser.c"

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
  YYSYMBOL__SYMB_199 = 203,                /* _SYMB_199  */
  YYSYMBOL__SYMB_200 = 204,                /* _SYMB_200  */
  YYSYMBOL_YYACCEPT = 205,                 /* $accept  */
  YYSYMBOL_DECLARE_BODY = 206,             /* DECLARE_BODY  */
  YYSYMBOL_ATTRIBUTES = 207,               /* ATTRIBUTES  */
  YYSYMBOL_DECLARATION = 208,              /* DECLARATION  */
  YYSYMBOL_ARRAY_SPEC = 209,               /* ARRAY_SPEC  */
  YYSYMBOL_TYPE_AND_MINOR_ATTR = 210,      /* TYPE_AND_MINOR_ATTR  */
  YYSYMBOL_IDENTIFIER = 211,               /* IDENTIFIER  */
  YYSYMBOL_SQ_DQ_NAME = 212,               /* SQ_DQ_NAME  */
  YYSYMBOL_DOUBLY_QUAL_NAME_HEAD = 213,    /* DOUBLY_QUAL_NAME_HEAD  */
  YYSYMBOL_ARITH_CONV = 214,               /* ARITH_CONV  */
  YYSYMBOL_DECLARATION_LIST = 215,         /* DECLARATION_LIST  */
  YYSYMBOL_NAME_ID = 216,                  /* NAME_ID  */
  YYSYMBOL_ARITH_EXP = 217,                /* ARITH_EXP  */
  YYSYMBOL_TERM = 218,                     /* TERM  */
  YYSYMBOL_PLUS = 219,                     /* PLUS  */
  YYSYMBOL_MINUS = 220,                    /* MINUS  */
  YYSYMBOL_PRODUCT = 221,                  /* PRODUCT  */
  YYSYMBOL_FACTOR = 222,                   /* FACTOR  */
  YYSYMBOL_EXPONENTIATION = 223,           /* EXPONENTIATION  */
  YYSYMBOL_PRIMARY = 224,                  /* PRIMARY  */
  YYSYMBOL_ARITH_VAR = 225,                /* ARITH_VAR  */
  YYSYMBOL_PRE_PRIMARY = 226,              /* PRE_PRIMARY  */
  YYSYMBOL_NUMBER = 227,                   /* NUMBER  */
  YYSYMBOL_LEVEL = 228,                    /* LEVEL  */
  YYSYMBOL_COMPOUND_NUMBER = 229,          /* COMPOUND_NUMBER  */
  YYSYMBOL_SIMPLE_NUMBER = 230,            /* SIMPLE_NUMBER  */
  YYSYMBOL_MODIFIED_ARITH_FUNC = 231,      /* MODIFIED_ARITH_FUNC  */
  YYSYMBOL_SHAPING_HEAD = 232,             /* SHAPING_HEAD  */
  YYSYMBOL_CALL_LIST = 233,                /* CALL_LIST  */
  YYSYMBOL_LIST_EXP = 234,                 /* LIST_EXP  */
  YYSYMBOL_EXPRESSION = 235,               /* EXPRESSION  */
  YYSYMBOL_ARITH_ID = 236,                 /* ARITH_ID  */
  YYSYMBOL_NO_ARG_ARITH_FUNC = 237,        /* NO_ARG_ARITH_FUNC  */
  YYSYMBOL_ARITH_FUNC = 238,               /* ARITH_FUNC  */
  YYSYMBOL_SUBSCRIPT = 239,                /* SUBSCRIPT  */
  YYSYMBOL_QUALIFIER = 240,                /* QUALIFIER  */
  YYSYMBOL_SCALE_HEAD = 241,               /* SCALE_HEAD  */
  YYSYMBOL_PREC_SPEC = 242,                /* PREC_SPEC  */
  YYSYMBOL_SUB_START = 243,                /* SUB_START  */
  YYSYMBOL_SUB_HEAD = 244,                 /* SUB_HEAD  */
  YYSYMBOL_SUB = 245,                      /* SUB  */
  YYSYMBOL_SUB_RUN_HEAD = 246,             /* SUB_RUN_HEAD  */
  YYSYMBOL_SUB_EXP = 247,                  /* SUB_EXP  */
  YYSYMBOL_POUND_EXPRESSION = 248,         /* POUND_EXPRESSION  */
  YYSYMBOL_BIT_EXP = 249,                  /* BIT_EXP  */
  YYSYMBOL_BIT_FACTOR = 250,               /* BIT_FACTOR  */
  YYSYMBOL_BIT_CAT = 251,                  /* BIT_CAT  */
  YYSYMBOL_OR = 252,                       /* OR  */
  YYSYMBOL_CHAR_VERTICAL_BAR = 253,        /* CHAR_VERTICAL_BAR  */
  YYSYMBOL_AND = 254,                      /* AND  */
  YYSYMBOL_BIT_PRIM = 255,                 /* BIT_PRIM  */
  YYSYMBOL_CAT = 256,                      /* CAT  */
  YYSYMBOL_NOT = 257,                      /* NOT  */
  YYSYMBOL_BIT_VAR = 258,                  /* BIT_VAR  */
  YYSYMBOL_LABEL_VAR = 259,                /* LABEL_VAR  */
  YYSYMBOL_EVENT_VAR = 260,                /* EVENT_VAR  */
  YYSYMBOL_BIT_CONST_HEAD = 261,           /* BIT_CONST_HEAD  */
  YYSYMBOL_BIT_CONST = 262,                /* BIT_CONST  */
  YYSYMBOL_RADIX = 263,                    /* RADIX  */
  YYSYMBOL_CHAR_STRING = 264,              /* CHAR_STRING  */
  YYSYMBOL_SUBBIT_HEAD = 265,              /* SUBBIT_HEAD  */
  YYSYMBOL_SUBBIT_KEY = 266,               /* SUBBIT_KEY  */
  YYSYMBOL_BIT_FUNC_HEAD = 267,            /* BIT_FUNC_HEAD  */
  YYSYMBOL_BIT_ID = 268,                   /* BIT_ID  */
  YYSYMBOL_LABEL = 269,                    /* LABEL  */
  YYSYMBOL_BIT_FUNC = 270,                 /* BIT_FUNC  */
  YYSYMBOL_EVENT = 271,                    /* EVENT  */
  YYSYMBOL_SUB_OR_QUALIFIER = 272,         /* SUB_OR_QUALIFIER  */
  YYSYMBOL_BIT_QUALIFIER = 273,            /* BIT_QUALIFIER  */
  YYSYMBOL_CHAR_EXP = 274,                 /* CHAR_EXP  */
  YYSYMBOL_CHAR_PRIM = 275,                /* CHAR_PRIM  */
  YYSYMBOL_CHAR_FUNC_HEAD = 276,           /* CHAR_FUNC_HEAD  */
  YYSYMBOL_CHAR_VAR = 277,                 /* CHAR_VAR  */
  YYSYMBOL_CHAR_CONST = 278,               /* CHAR_CONST  */
  YYSYMBOL_CHAR_FUNC = 279,                /* CHAR_FUNC  */
  YYSYMBOL_CHAR_ID = 280,                  /* CHAR_ID  */
  YYSYMBOL_NAME_EXP = 281,                 /* NAME_EXP  */
  YYSYMBOL_NAME_KEY = 282,                 /* NAME_KEY  */
  YYSYMBOL_NAME_VAR = 283,                 /* NAME_VAR  */
  YYSYMBOL_VARIABLE = 284,                 /* VARIABLE  */
  YYSYMBOL_STRUCTURE_EXP = 285,            /* STRUCTURE_EXP  */
  YYSYMBOL_STRUCT_FUNC_HEAD = 286,         /* STRUCT_FUNC_HEAD  */
  YYSYMBOL_STRUCTURE_VAR = 287,            /* STRUCTURE_VAR  */
  YYSYMBOL_STRUCT_FUNC = 288,              /* STRUCT_FUNC  */
  YYSYMBOL_QUAL_STRUCT = 289,              /* QUAL_STRUCT  */
  YYSYMBOL_STRUCTURE_ID = 290,             /* STRUCTURE_ID  */
  YYSYMBOL_ASSIGNMENT = 291,               /* ASSIGNMENT  */
  YYSYMBOL_EQUALS = 292,                   /* EQUALS  */
  YYSYMBOL_STATEMENT = 293,                /* STATEMENT  */
  YYSYMBOL_BASIC_STATEMENT = 294,          /* BASIC_STATEMENT  */
  YYSYMBOL_OTHER_STATEMENT = 295,          /* OTHER_STATEMENT  */
  YYSYMBOL_IF_STATEMENT = 296,             /* IF_STATEMENT  */
  YYSYMBOL_IF_CLAUSE = 297,                /* IF_CLAUSE  */
  YYSYMBOL_TRUE_PART = 298,                /* TRUE_PART  */
  YYSYMBOL_IF = 299,                       /* IF  */
  YYSYMBOL_THEN = 300,                     /* THEN  */
  YYSYMBOL_RELATIONAL_EXP = 301,           /* RELATIONAL_EXP  */
  YYSYMBOL_RELATIONAL_FACTOR = 302,        /* RELATIONAL_FACTOR  */
  YYSYMBOL_REL_PRIM = 303,                 /* REL_PRIM  */
  YYSYMBOL_COMPARISON = 304,               /* COMPARISON  */
  YYSYMBOL_ANY_STATEMENT = 305,            /* ANY_STATEMENT  */
  YYSYMBOL_ON_PHRASE = 306,                /* ON_PHRASE  */
  YYSYMBOL_ON_CLAUSE = 307,                /* ON_CLAUSE  */
  YYSYMBOL_LABEL_DEFINITION = 308,         /* LABEL_DEFINITION  */
  YYSYMBOL_CALL_KEY = 309,                 /* CALL_KEY  */
  YYSYMBOL_ASSIGN = 310,                   /* ASSIGN  */
  YYSYMBOL_CALL_ASSIGN_LIST = 311,         /* CALL_ASSIGN_LIST  */
  YYSYMBOL_DO_GROUP_HEAD = 312,            /* DO_GROUP_HEAD  */
  YYSYMBOL_ENDING = 313,                   /* ENDING  */
  YYSYMBOL_READ_KEY = 314,                 /* READ_KEY  */
  YYSYMBOL_WRITE_KEY = 315,                /* WRITE_KEY  */
  YYSYMBOL_READ_PHRASE = 316,              /* READ_PHRASE  */
  YYSYMBOL_WRITE_PHRASE = 317,             /* WRITE_PHRASE  */
  YYSYMBOL_READ_ARG = 318,                 /* READ_ARG  */
  YYSYMBOL_WRITE_ARG = 319,                /* WRITE_ARG  */
  YYSYMBOL_FILE_EXP = 320,                 /* FILE_EXP  */
  YYSYMBOL_FILE_HEAD = 321,                /* FILE_HEAD  */
  YYSYMBOL_IO_CONTROL = 322,               /* IO_CONTROL  */
  YYSYMBOL_WAIT_KEY = 323,                 /* WAIT_KEY  */
  YYSYMBOL_TERMINATOR = 324,               /* TERMINATOR  */
  YYSYMBOL_TERMINATE_LIST = 325,           /* TERMINATE_LIST  */
  YYSYMBOL_SCHEDULE_HEAD = 326,            /* SCHEDULE_HEAD  */
  YYSYMBOL_SCHEDULE_PHRASE = 327,          /* SCHEDULE_PHRASE  */
  YYSYMBOL_SCHEDULE_CONTROL = 328,         /* SCHEDULE_CONTROL  */
  YYSYMBOL_TIMING = 329,                   /* TIMING  */
  YYSYMBOL_REPEAT = 330,                   /* REPEAT  */
  YYSYMBOL_STOPPING = 331,                 /* STOPPING  */
  YYSYMBOL_SIGNAL_CLAUSE = 332,            /* SIGNAL_CLAUSE  */
  YYSYMBOL_PERCENT_MACRO_NAME = 333,       /* PERCENT_MACRO_NAME  */
  YYSYMBOL_PERCENT_MACRO_HEAD = 334,       /* PERCENT_MACRO_HEAD  */
  YYSYMBOL_PERCENT_MACRO_ARG = 335,        /* PERCENT_MACRO_ARG  */
  YYSYMBOL_CASE_ELSE = 336,                /* CASE_ELSE  */
  YYSYMBOL_WHILE_KEY = 337,                /* WHILE_KEY  */
  YYSYMBOL_WHILE_CLAUSE = 338,             /* WHILE_CLAUSE  */
  YYSYMBOL_FOR_LIST = 339,                 /* FOR_LIST  */
  YYSYMBOL_ITERATION_BODY = 340,           /* ITERATION_BODY  */
  YYSYMBOL_ITERATION_CONTROL = 341,        /* ITERATION_CONTROL  */
  YYSYMBOL_FOR_KEY = 342,                  /* FOR_KEY  */
  YYSYMBOL_TEMPORARY_STMT = 343,           /* TEMPORARY_STMT  */
  YYSYMBOL_CONSTANT = 344,                 /* CONSTANT  */
  YYSYMBOL_ARRAY_HEAD = 345,               /* ARRAY_HEAD  */
  YYSYMBOL_MINOR_ATTR_LIST = 346,          /* MINOR_ATTR_LIST  */
  YYSYMBOL_MINOR_ATTRIBUTE = 347,          /* MINOR_ATTRIBUTE  */
  YYSYMBOL_INIT_OR_CONST_HEAD = 348,       /* INIT_OR_CONST_HEAD  */
  YYSYMBOL_REPEATED_CONSTANT = 349,        /* REPEATED_CONSTANT  */
  YYSYMBOL_REPEAT_HEAD = 350,              /* REPEAT_HEAD  */
  YYSYMBOL_NESTED_REPEAT_HEAD = 351,       /* NESTED_REPEAT_HEAD  */
  YYSYMBOL_DCL_LIST_COMMA = 352,           /* DCL_LIST_COMMA  */
  YYSYMBOL_LITERAL_EXP_OR_STAR = 353,      /* LITERAL_EXP_OR_STAR  */
  YYSYMBOL_TYPE_SPEC = 354,                /* TYPE_SPEC  */
  YYSYMBOL_BIT_SPEC = 355,                 /* BIT_SPEC  */
  YYSYMBOL_CHAR_SPEC = 356,                /* CHAR_SPEC  */
  YYSYMBOL_STRUCT_SPEC = 357,              /* STRUCT_SPEC  */
  YYSYMBOL_STRUCT_SPEC_BODY = 358,         /* STRUCT_SPEC_BODY  */
  YYSYMBOL_STRUCT_TEMPLATE = 359,          /* STRUCT_TEMPLATE  */
  YYSYMBOL_STRUCT_SPEC_HEAD = 360,         /* STRUCT_SPEC_HEAD  */
  YYSYMBOL_ARITH_SPEC = 361,               /* ARITH_SPEC  */
  YYSYMBOL_COMPILATION = 362,              /* COMPILATION  */
  YYSYMBOL_BLOCK_DEFINITION = 363,         /* BLOCK_DEFINITION  */
  YYSYMBOL_BLOCK_STMT = 364,               /* BLOCK_STMT  */
  YYSYMBOL_BLOCK_STMT_TOP = 365,           /* BLOCK_STMT_TOP  */
  YYSYMBOL_BLOCK_STMT_HEAD = 366,          /* BLOCK_STMT_HEAD  */
  YYSYMBOL_LABEL_EXTERNAL = 367,           /* LABEL_EXTERNAL  */
  YYSYMBOL_CLOSING = 368,                  /* CLOSING  */
  YYSYMBOL_BLOCK_BODY = 369,               /* BLOCK_BODY  */
  YYSYMBOL_FUNCTION_NAME = 370,            /* FUNCTION_NAME  */
  YYSYMBOL_PROCEDURE_NAME = 371,           /* PROCEDURE_NAME  */
  YYSYMBOL_FUNC_STMT_BODY = 372,           /* FUNC_STMT_BODY  */
  YYSYMBOL_PROC_STMT_BODY = 373,           /* PROC_STMT_BODY  */
  YYSYMBOL_DECLARE_GROUP = 374,            /* DECLARE_GROUP  */
  YYSYMBOL_DECLARE_ELEMENT = 375,          /* DECLARE_ELEMENT  */
  YYSYMBOL_PARAMETER = 376,                /* PARAMETER  */
  YYSYMBOL_PARAMETER_LIST = 377,           /* PARAMETER_LIST  */
  YYSYMBOL_PARAMETER_HEAD = 378,           /* PARAMETER_HEAD  */
  YYSYMBOL_DECLARE_STATEMENT = 379,        /* DECLARE_STATEMENT  */
  YYSYMBOL_ASSIGN_LIST = 380,              /* ASSIGN_LIST  */
  YYSYMBOL_TEXT = 381,                     /* TEXT  */
  YYSYMBOL_REPLACE_STMT = 382,             /* REPLACE_STMT  */
  YYSYMBOL_REPLACE_HEAD = 383,             /* REPLACE_HEAD  */
  YYSYMBOL_ARG_LIST = 384,                 /* ARG_LIST  */
  YYSYMBOL_STRUCTURE_STMT = 385,           /* STRUCTURE_STMT  */
  YYSYMBOL_STRUCT_STMT_HEAD = 386,         /* STRUCT_STMT_HEAD  */
  YYSYMBOL_STRUCT_STMT_TAIL = 387,         /* STRUCT_STMT_TAIL  */
  YYSYMBOL_INLINE_DEFINITION = 388,        /* INLINE_DEFINITION  */
  YYSYMBOL_ARITH_INLINE = 389,             /* ARITH_INLINE  */
  YYSYMBOL_ARITH_INLINE_DEF = 390,         /* ARITH_INLINE_DEF  */
  YYSYMBOL_BIT_INLINE = 391,               /* BIT_INLINE  */
  YYSYMBOL_BIT_INLINE_DEF = 392,           /* BIT_INLINE_DEF  */
  YYSYMBOL_CHAR_INLINE = 393,              /* CHAR_INLINE  */
  YYSYMBOL_CHAR_INLINE_DEF = 394,          /* CHAR_INLINE_DEF  */
  YYSYMBOL_STRUC_INLINE_DEF = 395          /* STRUC_INLINE_DEF  */
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
#define YYLAST   8223

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  205
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  191
/* YYNRULES -- Number of rules.  */
#define YYNRULES  630
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  1077

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   459


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
     195,   196,   197,   198,   199,   200,   201,   202,   203,   204
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,   648,   648,   649,   651,   652,   653,   655,   656,   657,
     658,   659,   660,   661,   662,   663,   664,   665,   666,   668,
     669,   670,   671,   672,   674,   675,   676,   678,   680,   681,
     683,   684,   686,   687,   688,   689,   691,   692,   694,   695,
     696,   697,   698,   699,   700,   701,   703,   704,   705,   706,
     707,   709,   710,   712,   714,   716,   717,   718,   719,   721,
     722,   723,   725,   727,   728,   729,   730,   732,   733,   734,
     735,   736,   737,   738,   739,   741,   742,   743,   744,   745,
     746,   747,   748,   749,   751,   752,   754,   756,   758,   760,
     761,   762,   763,   765,   766,   767,   768,   769,   770,   771,
     772,   773,   775,   776,   778,   779,   780,   782,   783,   784,
     785,   786,   788,   789,   791,   792,   793,   794,   795,   796,
     797,   798,   800,   801,   802,   803,   804,   805,   806,   807,
     808,   809,   810,   811,   812,   813,   814,   815,   816,   817,
     818,   819,   820,   821,   822,   823,   824,   825,   826,   827,
     828,   829,   830,   831,   832,   833,   834,   835,   836,   837,
     838,   839,   840,   841,   842,   843,   845,   846,   847,   848,
     850,   851,   852,   853,   855,   856,   858,   859,   861,   862,
     863,   864,   865,   867,   868,   870,   871,   872,   873,   875,
     877,   878,   880,   881,   882,   884,   885,   887,   888,   890,
     891,   892,   893,   895,   896,   898,   900,   901,   903,   904,
     905,   906,   907,   908,   909,   910,   911,   912,   913,   914,
     916,   917,   919,   920,   922,   923,   924,   925,   927,   928,
     929,   930,   932,   933,   934,   935,   937,   938,   940,   941,
     942,   943,   944,   946,   947,   948,   949,   951,   953,   954,
     956,   958,   959,   960,   962,   964,   965,   966,   967,   969,
     970,   972,   974,   975,   977,   979,   980,   981,   982,   983,
     985,   986,   987,   988,   990,   991,   993,   994,   995,   996,
     998,   999,  1001,  1002,  1003,  1004,  1005,  1007,  1009,  1010,
    1011,  1013,  1015,  1016,  1017,  1019,  1020,  1021,  1022,  1023,
    1024,  1025,  1027,  1028,  1029,  1030,  1032,  1034,  1036,  1038,
    1039,  1041,  1043,  1044,  1045,  1046,  1048,  1050,  1051,  1052,
    1054,  1055,  1056,  1057,  1058,  1059,  1060,  1061,  1062,  1063,
    1064,  1065,  1066,  1067,  1068,  1069,  1070,  1071,  1072,  1073,
    1074,  1075,  1076,  1077,  1078,  1079,  1080,  1081,  1082,  1083,
    1084,  1085,  1086,  1087,  1088,  1089,  1090,  1091,  1092,  1093,
    1094,  1096,  1097,  1098,  1100,  1101,  1103,  1104,  1106,  1108,
    1110,  1112,  1113,  1115,  1116,  1118,  1119,  1120,  1122,  1123,
    1124,  1125,  1126,  1127,  1128,  1129,  1130,  1131,  1132,  1133,
    1134,  1135,  1136,  1137,  1138,  1139,  1140,  1141,  1142,  1143,
    1144,  1145,  1146,  1147,  1148,  1149,  1150,  1151,  1153,  1154,
    1156,  1157,  1159,  1160,  1161,  1162,  1164,  1166,  1168,  1170,
    1171,  1172,  1173,  1175,  1176,  1177,  1178,  1179,  1180,  1181,
    1182,  1184,  1185,  1186,  1188,  1189,  1191,  1193,  1194,  1196,
    1197,  1199,  1200,  1202,  1203,  1204,  1206,  1208,  1210,  1211,
    1212,  1213,  1214,  1216,  1218,  1219,  1221,  1222,  1224,  1225,
    1226,  1227,  1229,  1230,  1231,  1233,  1234,  1235,  1237,  1238,
    1239,  1241,  1243,  1244,  1246,  1247,  1248,  1250,  1252,  1253,
    1255,  1256,  1258,  1260,  1261,  1263,  1264,  1266,  1267,  1269,
    1270,  1272,  1273,  1275,  1276,  1278,  1280,  1281,  1282,  1283,
    1285,  1286,  1288,  1289,  1291,  1292,  1293,  1294,  1295,  1296,
    1297,  1298,  1299,  1300,  1301,  1302,  1304,  1305,  1306,  1308,
    1309,  1310,  1311,  1312,  1314,  1316,  1317,  1319,  1321,  1322,
    1324,  1325,  1326,  1327,  1328,  1330,  1331,  1333,  1335,  1337,
    1338,  1340,  1342,  1344,  1345,  1346,  1348,  1349,  1350,  1351,
    1352,  1353,  1354,  1355,  1356,  1358,  1359,  1361,  1363,  1364,
    1365,  1366,  1367,  1369,  1370,  1371,  1372,  1373,  1374,  1375,
    1376,  1377,  1379,  1380,  1382,  1383,  1384,  1386,  1387,  1388,
    1390,  1392,  1394,  1395,  1396,  1398,  1399,  1400,  1402,  1403,
    1405,  1406,  1407,  1408,  1410,  1411,  1412,  1413,  1414,  1415,
    1417,  1419,  1420,  1422,  1424,  1426,  1428,  1430,  1431,  1433,
    1434,  1436,  1438,  1439,  1440,  1442,  1444,  1445,  1446,  1447,
    1449,  1450,  1452,  1453,  1455,  1456,  1458,  1460,  1461,  1463,
    1465
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
  "_SYMB_197", "_SYMB_198", "_SYMB_199", "_SYMB_200", "$accept",
  "DECLARE_BODY", "ATTRIBUTES", "DECLARATION", "ARRAY_SPEC",
  "TYPE_AND_MINOR_ATTR", "IDENTIFIER", "SQ_DQ_NAME",
  "DOUBLY_QUAL_NAME_HEAD", "ARITH_CONV", "DECLARATION_LIST", "NAME_ID",
  "ARITH_EXP", "TERM", "PLUS", "MINUS", "PRODUCT", "FACTOR",
  "EXPONENTIATION", "PRIMARY", "ARITH_VAR", "PRE_PRIMARY", "NUMBER",
  "LEVEL", "COMPOUND_NUMBER", "SIMPLE_NUMBER", "MODIFIED_ARITH_FUNC",
  "SHAPING_HEAD", "CALL_LIST", "LIST_EXP", "EXPRESSION", "ARITH_ID",
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
  "STATEMENT", "BASIC_STATEMENT", "OTHER_STATEMENT", "IF_STATEMENT",
  "IF_CLAUSE", "TRUE_PART", "IF", "THEN", "RELATIONAL_EXP",
  "RELATIONAL_FACTOR", "REL_PRIM", "COMPARISON", "ANY_STATEMENT",
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

#define YYPACT_NINF (-993)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-446)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
    6391,   362,  -139,  -993,   -13,   474,  -993,   224,  7956,    56,
      98,   262,  1471,   145,  -993,   273,  -993,   244,   260,   278,
     370,   141,   -13,   203,  3207,   474,   290,   203,   203,  -139,
    -993,  -993,   285,  -993,   435,  -993,  -993,  -993,  -993,  -993,
     452,  -993,  -993,  -993,  -993,  -993,  -993,   464,  -993,  -993,
     340,   186,   464,   471,   464,  -993,   464,   502,   133,  -993,
     512,   168,  -993,   284,  -993,   492,  -993,  -993,  -993,  -993,
    7376,  7376,  4003,  -993,  7376,   179,  7090,   241,  6672,    41,
    2809,   238,   270,   497,   523,  4973,    31,   225,   101,   528,
     144,  6201,  7376,  4202,  2615,  -993,  6540,   114,     1,   182,
     955,    75,  -993,   550,  -993,  -993,  -993,  6540,  -993,  6540,
    -993,  6540,  6540,   571,   377,  -993,  -993,  -993,   464,   587,
    -993,  -993,  -993,   600,  -993,   610,  -993,   632,  -993,  -993,
    -993,  -993,  -993,  -993,   640,   643,   646,  -993,  -993,  -993,
    -993,  -993,  -993,  -993,  -993,   648,  -993,  -993,   650,  -993,
    6400,  2370,   652,   663,  -993,  2155,  -993,   578,    55,  5321,
    -993,   693,  8029,  -993,  -993,  -993,  -993,  5321,  1968,  -993,
    3406,  1368,  1968,  -993,  -993,  -993,   707,  -993,  -993,  5669,
     204,  -993,  -993,  4003,   706,    64,  5669,  -993,   717,   387,
    -993,   723,   729,   742,   756,   683,  -993,   109,    29,   387,
     387,  -993,   761,   736,   755,  -993,   813,  4401,  -993,  -993,
     482,   402,  -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,
    -993,  -993,  -993,  -993,   335,  -993,   825,   335,  -993,  -993,
    -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,
    -139,  -993,  -993,   440,  -993,  -993,  -993,  -993,   484,  -993,
    -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,
    -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,   504,  -993,
    -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,
    -993,  -993,  -993,  -993,  -993,  -993,   547,  -993,   829,   841,
     846,   859,   861,   863,  -993,  -993,  -993,  -993,   267,  -993,
    6021,  6021,   866,  5847,   753,  -993,   862,  -993,  -993,  -993,
    -993,  -993,   780,   864,   464,   894,    81,   311,   120,  -993,
    6142,  -993,  -993,  -993,   709,  -993,   901,  -993,  4202,   908,
    -993,   120,  -993,   910,  -993,  -993,  -993,  -993,   912,  -993,
    -993,   432,  -993,   442,  -993,  -993,  2318,  1368,   280,   387,
     293,  -993,  -993,  5147,   524,   915,  -993,   531,  -993,   922,
    -993,  -993,  -993,  -993,  2371,   340,  -993,  3605,  4202,   340,
     420,  -993,  4202,  -993,   285,  -993,   880,  7789,  -993,  4003,
    1074,    77,   821,  6188,  1139,   602,   869,    77,   311,  -993,
    -993,  -993,  -993,   332,  -993,  -993,   285,  -993,  -993,  4202,
    -993,  -993,   941,   683,  7956,  -993,  6804,   935,  -993,  -993,
     953,   954,   956,   970,   974,  -993,  -993,  -993,  -993,   276,
    -993,  -993,  -993,  1479,  -993,  3008,  -993,  4202,  5669,  5669,
    2200,  5669,   863,   365,   971,  -993,  -993,   298,  5669,  5669,
    2430,   979,   852,  -993,  -993,   968,   446,    82,  -993,  4600,
    -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,
    -993,   789,  -993,  -993,   639,   990,   994,  1698,  4202,  -993,
    -993,  -993,   985,  -993,   683,   914,  -993,  6958,   991,  7244,
      59,  -993,  -993,   995,  -993,  -993,  -993,  -993,  -993,  -993,
    -993,  -993,  -993,  -993,  -993,  -993,  -993,  1078,   558,  1012,
    -993,   988,  -993,  -993,  1019,  7244,  1032,  7244,  1038,  7244,
    1053,  7244,   464,  -139,   464,  -993,   474,  -993,  5321,  5321,
    5321,  5321,   877,  -993,  2155,  1968,  -993,  1968,  1968,  -993,
    1368,  -993,  -993,  -993,  -993,   787,  1088,  -993,  -993,   810,
    -993,  1095,  -993,   824,  -993,  -993,  1968,   947,  -993,  5321,
     527,   -13,   497,  1103,    81,    81,  -993,  -993,  1102,    58,
    1128,  -993,  -993,  -993,  -993,  -993,  -993,  1119,  -993,  1124,
    -993,  -993,    19,  1137,  1138,  -993,   -13,   946,   203,   507,
      85,   169,  1143,  1142,  1144,  1145,   570,  1141,  -993,  -993,
    -993,   387,  -993,  4202,  1156,  4202,  1159,  4202,  1165,  4202,
    1166,  4202,  4202,  4202,  4202,  -993,  -993,  6021,  6021,  4799,
    -993,  -993,  6021,  6021,  6021,  -993,  -993,  -993,  6021,  1167,
    -993,  3804,  -993,  -993,  -993,  4202,  -993,  -993,  2430,  -993,
    -993,  -993,  2430,  2430,  2430,   402,   402,  -993,  1163,  -993,
     387,  1171,  4202,  4799,  4202,  1340,  6584,  -993,  1157,   877,
    2686,   309,  -993,  5669,  1009,  1175,  1162,  -993,  -993,  -993,
    -993,   292,  -993,  5495,  1013,   787,  -993,  -993,  -993,  -993,
    -993,  -993,  1179,   133,  -993,  -993,  1168,   721,   840,  -993,
    -993,   432,  -993,   464,   464,   464,   464,  -993,  -993,  -993,
    1018,  1023,   108,  5669,  5669,  5669,  5669,  5669,  5669,  -993,
    -993,  2430,  2430,  2430,  2430,  2430,  2430,  4003,  4799,  4799,
    4799,  4799,  4799,  4799,   583,   583,   583,   583,   583,   583,
     -18,   -18,   -18,   -18,   -18,   -18,  4003,  -993,  4003,  1170,
     887,   340,  -993,  1172,  7508,  -993,  -993,  5669,  5669,  5669,
    5669,  5669,  -993,  -993,  1174,   564,   710,   885,  1176,    78,
     559,  -993,  1122,   474,  -993,   787,   787,    81,  5669,  -993,
    -993,  -993,  5669,  5669,  4600,   787,    81,  1181,  -993,  1178,
    -993,  -993,  -993,  -993,  -993,  -993,   921,  -993,  -993,   -13,
    7657,  -993,  -993,  -993,  1182,  -993,  -993,  -993,  -993,  -993,
    -993,  -993,  -993,  -993,   933,  -993,  -993,  -993,  1183,  -993,
    1187,  -993,  1188,  -993,  1192,  -993,  -993,   464,  1191,  1197,
    1211,  1213,  1214,  -993,  1968,  1968,   693,  -993,  -993,  -993,
    -993,  -993,  1180,  1215,  1112,  1190,  -993,   300,  -993,  5669,
    -993,  5669,  -993,  -993,  -993,  -993,  -993,  -993,  -993,   967,
    -993,  -993,  -993,  -993,  -993,   464,   402,   464,  1216,  1218,
    -993,  4202,  -993,  4202,  -993,  4202,  -993,  4202,   987,  1016,
    1033,  1059,  -993,  -993,  4799,  -993,   787,  -993,  1217,  -993,
    -993,  -993,  -993,  1205,  1222,  -993,  1080,   311,   120,  -993,
    6142,   608,  1224,  -993,  1082,   787,  -993,  1100,  1225,  1227,
     464,  -993,  -993,   877,   877,  -993,   561,  5669,  -993,   666,
    5669,  5495,   787,  -993,  -993,  6021,  6021,  -993,  4202,  -993,
    4202,  4202,  -993,  -993,  -993,  -993,  -993,  -993,   787,   787,
     787,   787,   787,   787,   120,   120,   120,   120,   120,   120,
     129,   267,   120,   120,   120,   120,   120,   120,  -993,  -993,
    -993,  -993,  -993,  -993,  -993,  -993,   532,  -993,  -993,  -993,
    -993,  -993,   821,   311,  -993,  -993,   158,  -993,   531,  1115,
    -993,   897,   931,   936,   944,   969,  -993,  -993,  -993,  -993,
    -993,  -993,  -993,  1067,   787,   787,  2572,  -993,  -993,  -993,
    1063,  -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,
    -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,   413,   787,
     -13,  -993,  -993,  -993,  1219,   709,  -993,  -993,  -993,  -993,
    -993,  -993,  -993,  -993,  1533,   666,  -993,  -993,  -993,  -993,
    -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,   642,  -993,
    1117,  1229,  1072,  -993,  -993,  -993,  -993,  -993,  -993,  -993,
    1232,   340,  1221,  -993,  -993,  -993,  -993,  -993,  -993,   340,
    5669,  -993,   188,  -993,  1121,  -993,  1220,  -993,  -993,  -993,
     340,  -993,   531,  -993,  1223,   787,  1230,  1220,  1226,  5669,
    1134,  -993,  -993,  1086,  1234,  -993,  -993
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int16 yydefact[] =
{
       0,     0,     0,   327,     0,     0,   455,     0,     0,     0,
       0,     0,     0,     0,   369,     0,   291,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     250,   454,   567,   453,     0,   254,   256,   257,   287,   311,
     258,   255,   261,   113,    27,   112,   295,    67,   296,   300,
       0,     0,   224,     0,   232,   298,   276,     0,     0,   619,
       0,   302,   306,     0,   309,     0,   408,   317,   318,   361,
       0,     0,     0,   546,     0,     0,   572,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   462,     0,     0,
       0,     0,     0,     0,     0,   409,     0,     0,   560,     0,
     568,   570,   548,     0,   550,   319,   616,     0,   617,     0,
     618,     0,     0,     0,     0,   477,   258,   417,   228,     0,
     517,   508,   507,     0,   505,     0,   535,     0,   506,   177,
     534,    20,    32,   514,     0,    35,     0,    21,    22,   510,
     511,    33,   176,   504,    23,    34,    42,    43,    44,    45,
       9,    17,     0,     0,    36,     5,     6,    38,   544,     0,
      29,     2,     7,   543,    40,    41,   541,     0,    26,   502,
       0,     0,    24,   531,   532,   530,     0,   533,   423,     0,
       0,   484,   483,     0,     0,     0,     0,   322,     0,     0,
     623,     0,     0,     0,     0,     0,   516,     0,   411,     0,
       0,   324,     0,   607,     0,   475,     0,     0,    53,    54,
       0,     0,   332,   223,   123,   153,   135,   136,   137,   138,
     140,   139,   141,   245,   252,   124,     0,   286,   114,   142,
     143,   115,   246,   154,   125,   116,   117,   144,   240,   126,
       0,   243,   157,     0,   159,   158,   282,   145,     0,   164,
     127,   165,   128,   122,   222,   289,   244,   129,   242,   241,
     118,   161,   119,   120,   130,   283,   131,   121,     0,   151,
     152,   132,   133,   146,   147,   163,   148,   162,   149,   150,
     155,   160,   284,   239,   134,   156,     0,   259,     0,     0,
       0,   256,   257,   255,   247,    86,    88,    87,   107,    46,
       0,     0,    51,    55,    59,    63,    64,    76,    85,    77,
      84,    65,     0,     0,    89,     0,   108,   195,   197,   199,
       0,   208,   209,   210,     0,   211,   236,   280,     0,     0,
     251,   109,   265,     0,   270,   271,   274,   110,     0,   111,
     302,     0,   458,     0,   474,   476,     0,     0,     0,     0,
       0,    68,   167,   183,     0,     0,   301,     0,   248,     0,
     225,   416,   233,   277,     0,     0,   316,     0,     0,     0,
       0,   307,     0,   320,     0,   364,   317,     0,   365,     0,
       0,     0,   197,     0,     0,     0,     0,     0,   371,   373,
     377,   362,   355,     0,   573,   565,   566,   321,   363,     0,
     328,   418,     0,   431,     0,   429,   572,     0,   430,   335,
       0,     0,     0,     0,     0,   441,   437,   442,   337,   311,
     443,   439,   444,     0,   336,     0,   338,     0,     0,     0,
       0,     0,     0,     0,     0,   346,   456,     0,     0,     0,
       0,     0,     0,   350,   464,     0,   466,   470,   465,     0,
     352,   478,   359,   496,   497,   293,   294,   498,   499,   480,
     292,     0,   481,   428,   107,   519,     0,   523,     0,     1,
     547,   549,     0,   551,   574,     0,   578,   572,     0,     0,
     577,   588,   590,     0,   592,   557,   558,   559,   561,   562,
     564,   580,   581,   563,   601,   583,   569,   582,     0,     0,
     571,   585,   586,   552,     0,     0,     0,     0,     0,     0,
       0,     0,    69,     0,    71,   229,     0,   500,     0,     0,
       0,     0,     0,    30,    14,    12,    10,    15,    18,   603,
       0,     4,    39,   545,   529,   528,     0,   527,     8,     0,
     503,     0,   519,     0,    44,    37,    25,     0,   538,     0,
       0,     0,     0,     0,   485,   486,   426,   424,     0,   489,
     488,   323,   447,   626,   629,   630,   622,     0,   358,     0,
     415,   414,   410,     0,     0,   325,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   262,   253,
     263,     0,   275,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   220,   221,     0,     0,     0,
      47,    48,     0,     0,     0,    58,    61,    62,     0,     0,
      66,     0,    81,   333,    90,     0,   205,   204,     0,   203,
     206,   207,     0,     0,     0,     0,     0,   201,     0,   238,
       0,     0,     0,     0,     0,     0,     0,   354,     0,     0,
       0,     0,   611,     0,     0,     0,   178,   169,   168,   186,
     192,   190,   184,     0,   185,   191,   182,   166,   180,   181,
     297,   249,     0,     0,   313,   312,     0,   107,     0,   102,
     104,   106,   315,    73,   226,   234,   278,   310,   314,   368,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   370,
     367,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   366,     0,     0,
       0,     0,   432,     0,     0,   433,   334,     0,     0,     0,
       0,     0,   438,   440,     0,     0,     0,     0,     0,     0,
       0,   343,     0,     0,   347,   459,   460,   461,     0,   471,
     351,   467,     0,     0,     0,   472,   473,     0,   479,     0,
     524,   554,   518,   525,   520,   521,     0,   553,   575,     0,
       0,   576,   555,   579,     0,   589,   591,   584,   595,   596,
     597,   599,   598,   594,     0,   604,   587,   620,     0,   624,
       0,   627,     0,   304,     0,    70,    72,   230,     0,     0,
       0,     0,     0,    13,    11,    16,     3,    28,   501,    19,
     513,   512,   539,     0,   427,     0,   493,     0,   425,     0,
     487,     0,   326,   357,   413,   412,   434,   435,   609,     0,
     605,   606,    75,   212,   273,   216,     0,   218,     0,     0,
      93,     0,    96,     0,    94,     0,    95,     0,     0,     0,
       0,     0,    49,    50,     0,   285,   268,   269,     0,    52,
      56,    57,    60,     0,     0,   101,     0,   196,   198,   200,
       0,     0,     0,   213,     0,   267,   266,     0,     0,     0,
      91,   353,   612,     0,     0,   615,     0,     0,   436,   174,
       0,     0,   190,   187,   189,     0,     0,   299,     0,   340,
       0,     0,   303,    74,   227,   235,   279,   375,   388,   393,
     383,   398,   403,   378,   390,   395,   385,   400,   405,   380,
       0,     0,   389,   394,   384,   399,   404,   379,   392,   397,
     387,   402,   407,   382,   308,   391,     0,   396,   386,   401,
     406,   381,     0,   372,   374,   356,     0,   419,   421,     0,
     495,     0,     0,     0,     0,     0,   339,   341,   446,   342,
     345,   344,   457,     0,   469,   468,     0,   360,   526,   522,
       0,   556,   602,   600,   621,   625,   628,   305,   231,   536,
     537,   509,    31,   515,   542,   540,   482,   494,   491,   490,
       0,   608,   217,   219,     0,     0,    97,   100,    98,    99,
     215,    79,    80,    83,     0,   174,    82,    78,   202,   237,
     214,   272,   290,   288,    92,   613,   614,   348,     0,   175,
       0,     0,     0,   188,   193,   194,   105,   103,   376,   329,
       0,     0,     0,   450,   451,   452,   448,   449,   463,     0,
       0,   610,     0,   281,     0,   349,   179,   170,   173,   171,
       0,   420,   422,   330,     0,   492,     0,     0,   174,     0,
       0,   593,   264,     0,     0,   172,   331
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -993,   839,  1085,  -131,  -993,  -104,    61,  -993,  -993,  -993,
     718,  -993,  1281,  -266,  1381,  1620,  -261,   635,  -993,  -993,
     747,  -993,   -32,  -462,   -62,  -993,   -81,  -993,  -338,   349,
     951,    10,  -610,  -993,  1439,   959,  -992,  -154,  -993,  -993,
    -993,  -993,  -632,  -993,   -23,   638,   364,  -367,  -993,  -380,
    -294,    -2,   -28,    47,    -4,   410,  -993,   -54,  -801,  -318,
     792,  -993,  -993,    14,  1315,  -993,  -361,  1040,  -993,    60,
    -503,  -993,   872,   -48,  -993,    11,    94,   923,  -347,   -38,
    1956,  -993,  1039,  -993,     0,   161,   367,     5,   374,   -63,
     -43,  -993,  -993,  -993,  -993,   881,  -167,   544,   545,  -993,
     115,  -993,  -993,   178,  -993,   -74,   214,  -993,  1198,  -993,
    -993,  -993,  -993,   854,   850,   913,  -993,   -66,  -993,  -993,
    -993,  -993,  -993,  -993,  -993,  -993,   835,   889,  -993,  -993,
    -993,  -993,   -50,  1098,  -993,  -993,  -993,  -993,  -993,   817,
    -993,  -133,  -153,  1285,   -21,  -993,  -993,  -993,   -64,   -55,
    1274,  1277,    20,  -993,  -993,  -993,  1278,  -993,  -993,  -993,
    -993,  -993,  -993,   858,   649,  -993,  -993,  -993,  -993,  -993,
     811,  -993,   -71,  -993,    54,   793,  -993,    57,  -993,  -993,
      95,  -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,  -993,
    -993
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
       0,   152,   153,   154,   155,   156,    45,   158,   159,   160,
     161,   162,   464,   299,   300,   301,   302,   303,   618,   304,
     305,   306,   307,   308,   309,   310,   311,   312,   678,   679,
     542,    47,   314,   315,   371,   352,   900,   163,   353,   354,
     662,   663,   664,   665,   316,   317,   318,   628,   629,   632,
     319,   633,   320,   321,   322,   323,   324,   325,   326,   327,
     328,    51,   329,    52,   118,   330,    54,   589,   590,   331,
     332,   333,   334,   335,   336,    56,   337,   338,   459,    58,
     339,    60,   340,    62,   434,    64,    65,   698,    66,    67,
      68,    69,    70,    71,    72,   700,   387,   388,   389,   390,
     476,    74,    75,   477,    77,   499,   959,    78,   735,    79,
      80,    81,    82,   416,   421,    83,    84,   417,    85,    86,
     437,    87,    88,   445,   446,   447,   448,    89,    90,    91,
     461,    92,   183,   184,   185,   560,   830,   186,   408,   462,
     167,   168,   169,   170,   466,   467,   468,   171,   536,   172,
     173,   174,   175,   548,   176,   549,   177,    94,    95,    96,
      97,    98,    99,   781,   479,   100,   101,   496,   500,   480,
     481,   794,   497,   498,   482,   502,   841,   483,   204,   839,
     484,   347,   652,   105,   106,   107,   108,   109,   110,   111,
     112
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      63,   117,   114,   402,   533,   119,   639,   376,   728,   685,
     455,   113,   355,   397,   422,   540,   555,   672,   528,   165,
     726,   342,   164,   206,   341,   119,   637,   206,   206,   454,
     501,   903,   193,   398,   610,   611,   890,   457,   449,   546,
     545,   415,   615,   458,   383,   495,   526,    48,   350,   381,
     357,   531,   435,   460,   102,    39,     1,   103,     2,   453,
     812,   730,   409,   367,  1069,   115,   208,   209,   372,   157,
      63,    63,   341,   240,    63,  1069,    63,   178,    63,   357,
     341,   494,   436,   203,   488,   557,   119,   456,   427,   637,
     843,   341,    63,   341,    63,   104,    63,    48,  1031,   970,
     626,   626,   410,   539,   626,   442,   867,    63,   626,    63,
     179,    63,    63,   917,   834,    73,   762,    48,    48,   187,
     401,    48,   443,    48,   570,    48,    48,     8,   350,   129,
     568,   626,   384,   489,  1038,   485,   475,   365,    48,    48,
     886,    48,   890,    48,   411,   605,   180,   486,   471,   543,
     451,   472,   626,    16,    48,   383,    48,   562,    48,    48,
     554,   366,   201,   412,   763,   452,   385,   573,   574,   166,
     341,   444,  -301,   166,   844,   606,    39,   944,    76,  1039,
     553,   835,   165,   341,   580,   164,    44,   892,   726,   473,
     346,   571,   358,   405,   605,    22,  -301,   413,   627,   627,
     392,    30,   627,   401,   414,   350,   627,   582,   142,   470,
     584,   586,   692,   650,  1031,   393,   651,   685,    29,     1,
     113,     2,    36,    37,   606,    39,   116,    41,   829,   627,
     120,    35,   157,   181,    38,    39,   223,   182,    42,    43,
      44,   181,   423,   384,   490,   182,   699,   399,   377,   377,
     627,  1066,   377,   487,   377,   232,   406,   583,   585,   424,
     193,   166,   400,   858,   859,   860,   861,   581,   189,  1033,
     377,   438,    76,   491,   425,   208,   209,   385,   181,   196,
    -445,   241,   182,   455,   199,   685,   401,   876,   369,    36,
      37,   426,   605,   116,    41,   370,   609,  -445,   889,   656,
     208,   209,   753,   350,   884,   256,   887,   492,     1,   493,
       2,   166,   366,   894,   397,   195,   166,   655,   658,   754,
     638,   439,   606,   166,   197,   726,   460,   673,   341,   643,
     895,   673,    36,    37,   398,   630,   116,    41,   901,   879,
     198,   862,   863,   397,   654,   440,   869,   631,   119,   441,
     553,   383,   870,   871,   350,     1,   580,     2,   165,   422,
     456,   164,   587,   398,   341,    63,   890,   341,   681,    63,
     343,   551,   341,   208,   209,   540,   200,    63,   609,   341,
     683,   686,   643,   638,   684,   415,   751,   706,   513,   713,
     719,   725,   814,   540,   815,   514,   449,    39,    39,   681,
      42,   166,    43,    44,   890,   454,    63,   749,   157,   348,
      49,    48,    48,   457,   397,   165,    48,   757,   164,   458,
     813,   208,   209,   357,    48,   341,   766,   745,   795,   774,
     638,  1025,  1026,   205,   398,   453,   382,   344,   345,   691,
     638,   349,   787,   646,   375,   378,   593,   776,   391,   767,
     653,   350,    16,    48,   808,   809,   810,   811,  -308,   350,
      49,   350,   609,   647,  1050,   157,   463,   357,   341,    23,
      48,    36,    37,   385,    39,   116,    41,    63,    27,    63,
      49,    49,    28,   350,    49,   823,    49,    39,    49,    49,
     595,    43,    44,   361,    39,   295,   296,   540,    43,    44,
      30,    49,    49,   350,    49,    63,    49,    63,   364,    63,
     597,    63,   842,   373,    48,   208,   209,    49,   368,    49,
     685,    49,    49,   350,    48,   366,    48,   428,   666,   667,
      35,   687,   605,    38,    39,   208,   209,    42,    43,    44,
     930,   165,   370,   513,   164,   668,   669,   382,   824,   450,
     350,   350,    48,   599,    48,   377,    48,   826,    48,   849,
      43,    44,   606,   726,   455,   166,   350,   208,   209,   208,
     209,   503,   850,   728,   852,   646,   854,   609,   856,   643,
     971,   846,  1027,   350,   734,   967,  1018,   512,   514,   295,
     296,   157,    35,   341,   783,   341,    39,   341,   516,   341,
     875,   681,   681,   681,   681,   880,   517,   460,   882,   868,
      35,   580,   825,    38,    39,   685,   518,    42,    43,    44,
     783,   341,   783,   181,   783,   681,   783,   182,   638,   714,
     366,   715,   638,   638,   638,   584,   584,   838,   519,  1034,
    1035,   456,   681,   868,   681,   341,   520,   208,   209,   521,
     208,   209,   522,   770,   523,   780,   683,   686,   166,  -311,
     684,   540,   540,  1055,   605,    36,    37,   530,    39,   116,
      41,   397,    35,   529,   687,   609,    39,   687,   908,   383,
      43,    44,   583,   585,   580,   166,  1029,  1053,   609,   643,
     532,   398,    48,   957,   606,    16,   713,   537,   383,   255,
     383,   638,   638,   638,   638,   638,   638,   341,   868,   868,
     868,   868,   868,   868,   223,   968,   547,   397,   208,   209,
     946,   946,   946,   946,   946,   946,   341,   556,   341,   208,
     209,   958,   674,   232,    63,   910,   682,   398,   561,   687,
     129,   580,   576,   382,   563,  1030,   605,    46,   788,   972,
     564,   789,   790,   119,   791,   792,   505,   793,   507,   241,
     509,   511,   683,   565,   767,   616,   617,   384,   932,   933,
     934,   935,   936,   937,    49,    49,   606,   566,    48,    49,
      63,    48,   575,   256,   621,   622,   384,    49,   384,   716,
     717,   718,    50,   768,   769,   208,   209,    46,    35,    36,
      37,   385,    39,   116,    41,    42,   577,   687,   938,   939,
     940,   941,   942,   943,   818,   819,    49,    46,    46,   142,
     385,    46,   385,    46,   578,    46,    46,    48,   772,   821,
    1006,   591,  1007,    49,  1008,   601,  1009,   683,    46,    46,
     980,    46,    50,    46,   911,   912,   605,   602,   701,   366,
     702,   341,   603,   341,    46,   341,    46,   341,    46,    46,
     684,  1054,    50,    50,   868,  -260,    50,  -285,    50,   604,
      50,    50,    55,   612,    36,    37,   606,    49,   116,    41,
     638,   619,  1040,    50,    50,   623,    50,    49,    50,    49,
     842,   911,   956,   208,   209,   684,   720,   366,   721,    50,
     625,    50,  1043,    50,    50,   208,   209,   640,   341,   294,
     341,   681,   734,   687,   642,    49,   644,    49,   645,    49,
     670,    49,    55,    57,   581,   978,   979,   552,   671,   609,
     643,   643,   643,   643,   643,   643,  1044,   982,   983,   208,
     209,  1045,    55,    55,   208,   209,    55,   731,    55,  1046,
      55,    55,   208,   209,   478,   689,   736,   706,   780,   737,
     738,   494,   739,    55,    55,   504,    55,   506,    55,   508,
     510,  1000,  1001,    57,  1047,   313,   740,   208,   209,    55,
     741,    55,   752,    55,    55,   758,   683,   759,   687,   760,
     684,   911,  1010,    57,    57,   771,   878,    57,   772,    57,
     779,    57,    57,  1061,   125,   126,   777,   687,   703,   704,
     705,  1064,   782,   127,    57,    57,   786,    57,   494,    57,
     911,  1011,   957,   842,   683,   686,   208,   209,   844,   129,
      57,   420,    57,   401,    57,    57,   130,   911,  1012,    61,
     797,  1062,   687,   605,   465,   693,   366,   694,   605,   357,
     708,   366,   709,   799,   132,    49,   722,   723,   724,   801,
     958,  1051,   135,   911,  1013,   924,   925,   926,   927,   928,
     929,   382,  1048,   606,   803,   208,   209,  1059,   606,   295,
     208,   209,   208,   209,   911,  1017,   911,  1020,    48,   356,
     952,  1075,   952,   817,   208,   209,    48,   657,   141,   605,
     820,   693,   366,   694,   911,  1021,   822,    48,   142,    61,
      61,    46,    46,    61,   827,   356,    46,    61,   356,  1041,
    1042,  1056,  1057,   828,    46,  1067,  1057,   125,   126,   606,
     356,    61,   831,    61,   145,    61,   127,   687,  1041,  1074,
     832,    49,   836,   837,    49,   833,    61,   840,    61,    39,
      61,    61,   129,    46,   646,   846,    50,    50,   845,   130,
     848,    50,   851,   847,   605,   853,   708,   366,   709,    50,
      46,   855,   857,   873,   881,   687,   883,   132,   891,   897,
     898,   228,   899,   904,   907,   135,   994,   996,   231,   909,
      49,   955,   976,   960,   606,   966,   989,   969,    50,   977,
     235,   236,   990,   981,   984,   695,   696,   697,   985,   986,
     710,   711,   712,   987,    46,    50,   991,   992,   997,   993,
     995,   141,  1004,  1005,    46,  1015,    46,  1016,  1014,  1019,
    1022,   142,  1023,  1049,  1058,  1072,    55,    55,  1060,  1052,
    1068,    55,  1063,   733,  1071,   260,  1029,   538,   816,    55,
     262,   263,    46,   872,    46,  1076,    46,   145,    46,    50,
    1037,   695,   696,   697,   267,   620,   877,   592,   727,    50,
     953,    50,    39,   954,  1070,   743,   407,   742,    55,   641,
     676,   761,   729,   558,   775,    93,   191,    57,    57,   192,
     194,   785,    57,     0,   796,    55,     0,    50,     0,    50,
      57,    50,     0,    50,     0,   298,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    53,    39,     0,   675,   680,
      43,    44,     0,   688,     0,   188,   710,   711,   712,    57,
       0,     0,     0,     0,     0,     0,   202,   784,     0,    55,
       0,     0,     0,     0,     0,     0,    57,     0,     0,    55,
     680,    55,     0,   380,     0,     1,     0,     2,     0,     0,
       0,   298,     0,   798,     0,   800,   433,   802,     0,   804,
       0,     0,     0,     0,     0,     0,   420,    55,   744,    55,
       0,    55,     0,    55,     0,    53,    53,     0,     0,    53,
      57,    53,    46,    53,     0,     0,     0,     0,     0,   228,
      57,     0,    57,   356,   356,     0,   231,    53,   356,    53,
       0,    53,     0,     0,     0,     0,   356,     0,   235,   236,
       0,     0,    53,     0,    53,     0,    53,    53,    57,     0,
      57,     0,    57,     0,    57,     0,     0,    50,     0,     0,
     535,     0,     0,     0,     0,   356,     0,     0,   535,     0,
       0,    49,    16,     0,     0,     0,   888,     0,     0,    49,
     550,     0,   356,   260,   380,     0,     0,   559,   262,   263,
      49,     0,     0,     0,     0,     0,     0,     0,    46,     0,
       0,    46,   267,     0,     0,     0,   351,     0,   579,     0,
     359,   360,   190,   362,     1,   363,     2,     0,     0,     0,
      30,     0,     0,     0,     0,     0,   356,     0,     0,     0,
     567,     0,     0,     0,     0,     0,   356,    55,    61,     0,
     125,   126,     0,    50,     0,     0,    50,    46,     0,   127,
      35,    36,    37,    38,    39,   116,    41,    42,    43,    44,
     410,     0,     0,     0,    61,   129,    61,     0,    61,     0,
      61,     0,   680,   680,   680,   680,     0,   515,    35,   146,
     147,    38,   544,   149,   150,   151,     0,    44,    57,     0,
     132,     0,    50,     0,     0,     0,   680,     0,   135,     0,
       0,     0,   411,     0,     0,     0,     0,     0,     0,     0,
       0,    16,   228,   680,     0,   680,     0,     0,     0,   231,
       0,   412,     0,    55,     0,     0,    55,     0,     0,   298,
       0,   235,   236,     0,   141,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   142,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   661,   413,   569,   572,     0,    30,
       0,     0,   414,     0,     0,     0,     0,     0,   298,   677,
     145,     0,    55,   298,    57,     0,   260,    57,     0,     0,
     690,   262,   263,   588,     0,    39,   588,     0,     0,    35,
       0,     0,    38,    39,     0,   267,    42,    43,    44,   607,
     677,     0,   594,     0,   356,     0,     0,   596,     0,     0,
       0,     0,    53,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    57,   773,     0,   298,   598,   298,   746,
     747,     0,   750,     1,     0,     2,     0,     0,   732,   755,
     756,    53,     0,     0,     0,   600,    38,    39,     0,     0,
     765,    43,    44,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   223,     0,     0,     0,
       0,     0,     0,   624,     0,   226,     0,     0,     0,     0,
       0,   607,     0,     0,     0,   232,     0,     0,     0,     0,
     356,     0,     0,   356,     0,     0,     0,     0,     0,     0,
       0,     0,   648,     0,     0,   238,     0,     0,    46,   778,
       0,   241,    53,     0,    53,     0,    46,     0,     0,   535,
     535,   535,   535,     0,     0,     0,     0,    46,     0,     0,
      16,     0,     0,     0,   607,   256,     0,   258,   259,   356,
      53,     0,    53,     0,    53,     0,    53,     0,     0,     0,
     535,   807,     0,    50,     0,     0,     0,     0,     0,     0,
       0,    50,     0,     0,     0,   607,     0,     0,     0,     0,
       0,     0,    50,     0,     0,     0,     0,     0,    30,   675,
       0,  1036,   680,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   283,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   677,   677,   677,   677,     0,     0,    35,     0,
     866,    38,    39,     0,     0,    42,    43,    44,   294,     0,
     295,   296,   297,     0,     0,     0,   677,     0,     0,     0,
       0,     0,     0,    55,     0,     0,   607,     0,   608,     0,
       0,    55,     0,   677,   885,   677,     0,     0,     0,     0,
       0,   607,    55,     0,   896,     0,     0,     0,     0,     0,
     607,     0,     0,     0,   902,     0,     0,     0,     0,     0,
       0,   805,     0,   806,     0,     0,    59,     0,     0,     0,
     607,   807,     0,     0,    57,     0,     0,     0,     0,     0,
       0,     0,    57,     0,   918,   919,   920,   921,   922,   923,
       0,     0,     0,    57,     0,     0,     0,     0,   380,   931,
     931,   931,   931,   931,   931,     0,     0,     0,     0,     0,
     608,   121,     0,   122,     0,     0,     0,   380,     0,   380,
       0,     0,     0,     0,     0,   124,     0,     0,   961,   962,
     963,   964,   965,     0,     0,     0,    59,    59,   386,     0,
      59,     7,     0,     0,    59,     0,     0,   128,     0,   973,
       0,     0,   607,   974,   975,   747,   905,     0,    59,    53,
      59,     0,    59,   608,     0,     0,     0,     0,   607,     0,
       0,     0,     0,    59,     0,    59,    15,    59,    59,   133,
       0,   607,     0,   134,     0,     0,     0,     0,     0,     0,
     356,     0,   136,     0,   608,     0,     0,     0,   356,     0,
       0,     0,     0,     0,     0,    53,     0,     0,     0,   356,
       0,     0,   139,     0,     0,     0,     0,   140,     0,     0,
     998,     0,   999,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   913,   914,   915,   916,   143,   607,   607,     0,
       0,   607,     0,     0,     0,     0,   607,   607,     0,   386,
       0,     0,     0,     0,     0,   579,   607,     0,     0,     0,
       0,     0,     0,     0,     0,   608,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     608,     0,     0,     0,     0,     0,     0,     0,  1028,   608,
       0,  1032,   902,     0,     0,     0,     0,     0,   121,   298,
     122,   298,   677,     0,     0,     0,   807,     0,     0,   608,
       0,     0,   124,     0,   125,   126,   634,     0,     0,     0,
       0,     0,     0,   127,     0,   635,     0,   636,     7,     0,
       0,     0,     0,     0,   128,     0,   213,     0,     0,   129,
       0,     0,     0,     0,     0,     0,   130,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   988,   607,   223,   224,
       0,     0,     0,    15,   132,     0,   133,     0,     0,     0,
     134,     0,   135,     0,     0,     0,   607,   232,     0,   136,
     748,     0,     0,     0,     0,     0,     0,   607,     0,     0,
       0,   608,     0,   607,  1002,   906,  1003,   238,     0,   139,
       0,   807,     0,   241,   140,     0,     0,   608,   141,   607,
     607,   607,   607,   607,   607,     0,     0,     0,   142,     0,
     608,     0,   607,   143,     0,   254,     0,   256,     0,   258,
     259,     0,     0,     0,     0,     0,     0,     0,     0,  1024,
       0,  1065,     0,     0,   145,   386,     0,     0,     0,     0,
     649,     0,   607,   607,   607,   607,   607,     0,     0,    39,
    1073,   121,     0,   122,   607,   607,   607,     0,     0,     0,
      30,     0,     0,     0,     0,   124,   608,   608,     0,     0,
     608,     0,     0,     0,   283,   608,   608,     0,     0,   607,
     607,     7,     0,   287,   288,   608,     1,   128,     2,     0,
      35,   291,    37,     0,    39,   116,    41,    42,     0,     0,
       0,     0,     0,   121,     0,   122,     0,     0,     0,   607,
       0,     0,     0,   607,     0,     0,    15,   124,     0,   133,
       0,     0,     0,   134,     0,     0,     0,     0,     0,     0,
     228,     0,   136,     7,     0,    59,   634,   231,     0,   128,
       0,     0,     0,     0,     0,   635,   607,   636,     0,   235,
     236,   527,   139,     0,   607,     0,   213,   140,     0,     0,
       0,    59,     0,    59,     0,    59,     0,    59,    15,     0,
       0,   133,     0,     0,     0,   134,   143,     0,   223,   224,
       0,     0,     0,    16,   136,     0,   608,     0,     0,     0,
       0,     0,     0,     0,   260,     0,     0,   232,     0,   262,
     263,     0,     0,     0,   139,   608,     0,     0,     0,   140,
       0,     0,     0,   267,     0,     0,   608,   238,     0,     0,
       0,     0,   608,   241,     0,     0,     0,     0,   143,     0,
       0,    30,     0,     0,     0,     0,     0,     0,   608,   608,
     608,   608,   608,   608,     0,   254,     0,   256,     0,   258,
     259,   608,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    35,    36,    37,    38,    39,   116,    41,    42,    43,
      44,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   608,   608,   608,   608,   608,     0,     0,     0,     0,
      30,     0,     0,   608,   608,   608,     0,     0,     0,     0,
       0,     0,     0,     0,   283,     0,     0,     0,     0,     0,
       0,     0,     0,   287,   288,   469,     0,     0,   608,   608,
      35,   291,    37,     0,    39,   116,    41,    42,     0,     0,
       1,   228,     2,     0,     0,     0,     3,     0,   231,     0,
       0,     0,     0,     0,     0,     4,     0,     0,   608,     0,
     235,   236,   608,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   386,     0,     0,     0,     5,     6,     0,
       0,     0,     0,     0,     0,     0,   945,   947,   948,   949,
     950,   951,   386,     8,   386,   608,     0,     0,     9,     0,
       0,     0,     0,   608,     0,   260,     0,     0,     0,    10,
     262,   263,     0,    11,     0,     0,    12,    13,   893,    14,
       0,     0,     0,     0,   267,     0,     0,     0,     0,   121,
       0,   122,     0,     0,     0,     0,     0,    16,     0,     0,
       0,     0,     0,   124,    17,    18,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    19,    20,     0,     0,     7,
      21,    22,    23,    24,     0,   128,     0,     0,     0,    25,
      26,    27,    35,    36,    37,    28,    39,   116,    41,    42,
      43,    44,     0,     0,    29,    30,     0,     0,     0,     0,
       0,     0,     0,    31,    15,     0,     0,   133,     0,     0,
       0,   134,     0,    32,     0,    33,     0,    34,     0,     0,
     136,     0,     0,     0,     0,    35,    36,    37,    38,    39,
      40,    41,    42,    43,    44,   207,     0,   208,   209,     0,
     139,     0,     0,     0,   210,   140,   211,     0,     0,     0,
     418,     0,     0,     0,     0,   213,     0,     0,     0,     0,
     214,   215,     0,     0,   143,     0,   216,   217,   218,   219,
     220,   221,   222,     0,     0,     0,     0,   223,   224,     0,
       0,     0,     0,     0,     0,   225,   226,   227,   228,     0,
     410,     0,     0,   229,   230,   231,   232,     0,     0,     0,
     233,   234,     0,     0,     0,     0,     0,   235,   236,     0,
       0,     0,     0,     0,   237,     0,   238,     0,   239,     0,
     240,     0,   241,     0,     0,     0,   242,     0,   243,   244,
       0,   245,   411,   246,     0,   247,   248,   249,   250,   251,
     252,    16,   253,     0,   254,   255,   256,   257,   258,   259,
       0,   412,   260,     0,     0,   261,     0,   262,   263,     0,
       0,     0,   264,     0,     0,     0,     0,     0,     0,   265,
     266,   267,   268,     0,     0,     0,   269,   270,   271,     0,
     272,   273,     0,   274,   275,   413,   276,     0,     0,    30,
     277,     0,   414,   278,   279,     0,     0,     0,     0,     0,
     280,   281,   282,   283,   284,   285,     0,     0,   286,     0,
       0,     0,   287,   288,   289,   290,     0,     0,     0,    35,
     291,   292,    38,   419,    40,   293,    42,    43,    44,   294,
       0,   295,   296,   297,   207,     0,   208,   209,     0,     0,
       0,     0,     0,   210,     0,   211,     0,     0,     0,     0,
       0,     0,     0,     0,   213,     0,     0,     0,     0,   214,
     215,     0,     0,     0,     0,   216,   217,   218,   219,   220,
     221,   222,     0,     0,     0,     0,   223,   224,     0,     0,
       0,     0,     0,     0,   225,   226,   227,   228,     0,   410,
       0,     0,   229,   230,   231,   232,     0,     0,     0,   233,
     234,     0,     0,     0,     0,     0,   235,   236,     0,     0,
       0,     0,     0,   237,     0,   238,     0,   239,     0,   240,
       0,   241,     0,     0,     0,   242,     0,   243,   244,     0,
     245,   411,   246,     0,   247,   248,   249,   250,   251,   252,
      16,   253,     0,   254,   255,   256,   257,   258,   259,     0,
     412,   260,     0,     0,   261,     0,   262,   263,     0,     0,
       0,   264,     0,     0,     0,     0,     0,     0,   265,   266,
     267,   268,     0,     0,     0,   269,   270,   271,     0,   272,
     273,     0,   274,   275,   413,   276,     0,     0,    30,   277,
       0,   414,   278,   279,     0,     0,     0,     0,     0,   280,
     281,   282,   283,   284,   285,     0,     0,   286,     0,     0,
       0,   287,   288,   289,   290,     0,     0,     0,    35,   291,
     292,    38,   419,    40,   293,    42,    43,    44,   294,     0,
     295,   296,   297,   207,     0,   208,   209,     0,     0,     0,
       0,     0,   210,     0,   211,     0,     0,     0,   212,     0,
       0,     0,     0,   213,     0,     0,     0,     0,   214,   215,
       0,     0,     0,     0,   216,   217,   218,   219,   220,   221,
     222,     0,     0,     0,     0,   223,   224,     0,     0,     0,
       0,     0,     0,   225,   226,   227,   228,     0,     0,     0,
       0,   229,   230,   231,   232,     0,     0,     0,   233,   234,
       0,     0,     0,     0,     0,   235,   236,     0,     0,     0,
       0,     0,   237,     0,   238,     0,   239,     0,   240,     0,
     241,     0,     0,     0,   242,     0,   243,   244,     0,   245,
       0,   246,     0,   247,   248,   249,   250,   251,   252,    16,
     253,     0,   254,   255,   256,   257,   258,   259,     0,     0,
     260,     0,     0,   261,     0,   262,   263,     0,     0,     0,
     264,     0,     0,     0,     0,     0,     0,   265,   266,   267,
     268,     0,     0,     0,   269,   270,   271,     0,   272,   273,
       0,   274,   275,     0,   276,     0,     0,    30,   277,     0,
       0,   278,   279,     0,     0,     0,     0,     0,   280,   281,
     282,   283,   284,   285,     0,     0,   286,     0,     0,     0,
     287,   288,   289,   290,     0,     0,     0,    35,   291,   292,
      38,    39,    40,   293,    42,    43,    44,   294,     0,   295,
     296,   297,   207,     0,   208,   209,   541,     0,     0,     0,
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
     288,   289,   290,     0,     0,     0,    35,   291,   292,    38,
      39,    40,   293,    42,    43,    44,   294,     0,   295,   296,
     297,   207,     0,   208,   209,     0,     0,     0,     0,     0,
     210,     0,   211,     0,     0,     0,     0,     0,     0,     0,
       0,   213,     0,     0,     0,     0,   214,   215,     0,     0,
       0,     0,   216,   217,   218,   219,   220,   221,   222,     0,
       0,     0,     0,   223,   224,     0,     0,     0,     0,     0,
       0,   225,   226,   227,   228,     0,     0,     0,     0,   229,
     230,   231,   232,     0,     0,     0,   233,   234,     0,     0,
       0,     0,     0,   235,   236,     0,     0,     0,     0,     0,
     237,     0,   238,    11,   239,     0,   240,     0,   241,     0,
       0,     0,   242,     0,   243,   244,     0,   245,     0,   246,
       0,   247,   248,   249,   250,   251,   252,    16,   253,     0,
     254,   255,   256,   257,   258,   259,     0,     0,   260,     0,
       0,   261,     0,   262,   263,     0,     0,     0,   264,     0,
       0,     0,     0,     0,     0,   265,   266,   267,   268,     0,
       0,     0,   269,   270,   271,     0,   272,   273,     0,   274,
     275,     0,   276,     0,     0,    30,   277,     0,     0,   278,
     279,     0,     0,     0,     0,     0,   280,   281,   282,   283,
     284,   285,     0,     0,   286,     0,     0,     0,   287,   288,
     289,   290,     0,     0,     0,    35,   291,   292,    38,    39,
      40,   293,    42,    43,    44,   294,     0,   295,   296,   297,
     207,     0,   208,   209,   874,     0,     0,     0,     0,   210,
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
     285,     0,     0,   286,     0,     0,     0,   287,   288,   289,
     290,     0,     0,     0,    35,   291,   292,    38,    39,    40,
     293,    42,    43,    44,   294,     0,   295,   296,   297,   379,
       0,   208,   209,     0,     0,     0,     0,     0,   210,     0,
     211,     0,     0,     0,     0,     0,     0,     0,     0,   213,
       0,     0,     0,     0,   214,   215,     0,     0,     0,     0,
     216,   217,   218,   219,   220,   221,   222,     0,     0,     0,
       0,   223,   224,     0,     0,     0,     0,     0,     0,   225,
     226,   227,   228,     0,     0,     0,     0,   229,   230,   231,
     232,     0,     0,     0,   233,   234,     0,     0,     0,     0,
       0,   235,   236,     0,     0,     0,     0,     0,   237,     0,
     238,     0,   239,     0,   240,     0,   241,     0,     0,     0,
     242,     0,   243,   244,     0,   245,     0,   246,     0,   247,
     248,   249,   250,   251,   252,    16,   253,     0,   254,   255,
     256,   257,   258,   259,     0,     0,   260,     0,     0,   261,
       0,   262,   263,     0,     0,     0,   264,     0,     0,     0,
       0,     0,     0,   265,   266,   267,   268,     0,     0,     0,
     269,   270,   271,     0,   272,   273,     0,   274,   275,     0,
     276,     0,     0,    30,   277,     0,     0,   278,   279,     0,
       0,     0,     0,     0,   280,   281,   282,   283,   284,   285,
       0,     0,   286,     0,     0,     0,   287,   288,   289,   290,
       0,     0,     0,    35,   291,   292,    38,    39,    40,   293,
      42,    43,    44,   294,     0,   295,   296,   297,   207,     0,
     208,   209,     0,     0,     0,     0,     0,   210,     0,   211,
       0,     0,     0,     0,     0,     0,     0,     0,   213,     0,
       0,     0,     0,   214,   215,     0,     0,     0,     0,   216,
     217,   218,   219,   220,   221,   222,     0,     0,     0,     0,
     223,   224,     0,     0,     0,     0,     0,     0,   225,   226,
     227,   228,     0,     0,     0,     0,   229,   230,   231,   232,
       0,     0,     0,   233,   234,     0,     0,     0,     0,     0,
     235,   236,     0,     0,     0,     0,     0,   237,     0,   238,
       0,   239,     0,   240,     0,   241,     0,     0,     0,   242,
       0,   243,   244,     0,   245,     0,   246,     0,   247,   248,
     249,   250,   251,   252,    16,   253,     0,   254,   255,   256,
     257,   258,   259,     0,     0,   260,     0,     0,   261,     0,
     262,   263,     0,     0,     0,   264,     0,     0,     0,     0,
       0,     0,   265,   266,   267,   268,     0,     0,     0,   269,
     270,   271,     0,   272,   273,     0,   274,   275,     0,   276,
       0,     0,    30,   277,     0,     0,   278,   279,     0,     0,
       0,     0,     0,   280,   281,   282,   283,   284,   285,     0,
       0,   286,     0,     0,     0,   287,   288,   289,   290,     0,
       0,     0,    35,   291,   292,    38,    39,    40,   293,    42,
      43,    44,   294,     0,   295,   296,   297,   207,     0,   208,
     209,     0,     0,     0,     0,     0,   210,     0,   211,     0,
       0,     0,     0,     0,     0,     0,     0,   213,     0,     0,
       0,     0,   214,   215,     0,     0,     0,     0,   216,   217,
     218,   219,   220,   221,   222,     0,     0,     0,     0,   223,
     224,     0,     0,     0,     0,     0,     0,   225,   226,   227,
     228,     0,     0,     0,     0,   229,   230,   231,   232,     0,
       0,     0,   233,   234,     0,     0,     0,     0,     0,   235,
     236,     0,     0,     0,     0,     0,   237,     0,   238,     0,
     239,     0,     0,     0,   241,     0,     0,     0,   242,     0,
     243,   244,     0,   245,     0,   246,     0,   247,   248,   249,
     250,   251,   252,     0,   253,     0,   254,     0,   256,   257,
     258,   259,     0,     0,   260,     0,     0,   261,     0,   262,
     263,     0,     0,     0,   264,     0,     0,     0,     0,     0,
       0,   265,   266,   267,   268,     0,     0,     0,   269,   270,
     271,     0,   272,   273,     0,   274,   275,     0,   276,     0,
       0,    30,   277,     0,     0,   278,   279,     0,     0,     0,
       0,     0,   280,   281,   282,   283,   284,   285,     0,     0,
     286,     0,     0,     0,   287,   288,   289,   290,     0,     0,
       0,    35,   291,   292,    38,    39,   116,   293,    42,    43,
      44,   294,     0,   295,   296,   297,   764,     0,   208,   209,
       0,     0,     0,     0,     0,   210,     0,   211,     0,     0,
       0,     0,     0,     0,     0,     0,   213,     0,     0,     0,
       0,   214,   215,     0,     0,     0,     0,   216,   217,   218,
     219,   220,   221,   222,     0,     0,     0,     0,   223,   224,
       0,     0,     0,     0,     0,     0,   225,     0,     0,   228,
       0,     0,     0,     0,   229,   230,   231,   232,     0,     0,
       0,   233,   234,     0,     0,     0,     0,     0,   235,   236,
       0,     0,     0,     0,     0,   237,     0,   238,     0,   239,
       0,     0,     0,   241,     0,     0,     0,   242,     0,   243,
     244,     0,   245,     0,     0,     0,   247,   248,   249,   250,
     251,   252,     0,   253,     0,   254,     0,   256,   257,   258,
     259,     0,     0,   260,     0,     0,   261,     0,   262,   263,
       0,     0,     0,   264,     0,     0,     0,     0,     0,     0,
       0,   266,   267,   268,     0,     0,     0,   269,   270,   271,
       0,   272,   273,     0,   274,   275,     0,   276,     0,     0,
      30,   277,     0,     0,   278,   279,     0,     0,     0,     0,
       0,   280,   281,     0,   283,   284,   285,     0,     0,   286,
       0,     0,     0,   287,   288,   289,   290,     0,     0,     0,
      35,   291,    37,     0,    39,   116,   293,    42,    43,    44,
       0,     0,   295,   296,   297,   864,     0,   208,   209,     0,
       0,     0,     0,     0,     1,     0,     2,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     214,   215,     0,     0,     0,     0,   216,   217,   218,   219,
     220,   221,   222,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   225,   226,   227,   228,     0,
       0,     0,     0,   229,   230,   231,     0,     0,     0,     0,
     233,   234,     0,     0,     0,     0,     0,   235,   236,     0,
       0,     0,     0,     0,   237,     0,     0,     0,   239,     0,
       0,     0,     0,     0,     0,     0,   242,     0,   243,   244,
       0,   245,     0,   246,     0,   247,   248,   249,   250,   251,
     252,     0,   253,     0,     0,     0,     0,   257,     0,     0,
       0,     0,   260,     0,     0,   261,     0,   262,   263,     0,
       0,     0,   264,     0,     0,     0,     0,     0,     0,   265,
     266,   267,   268,     0,     0,     0,   269,   270,   271,     0,
     272,   273,     0,   274,   275,     0,   276,     0,     0,     0,
     277,     0,     0,   278,   279,     0,     0,     0,     0,     0,
     280,   281,   282,     0,   284,   285,     0,     0,   286,   429,
       0,   208,   209,     0,   289,   290,     0,     0,     1,     0,
       2,   865,    38,    39,     0,   432,     0,    43,    44,   294,
       0,   295,   296,   297,   214,   215,     0,     0,     0,     0,
     216,   217,   218,   219,   220,   221,   222,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   225,
       0,     0,   228,     0,     0,     0,     0,   229,   230,   231,
       0,     0,     0,     0,   233,   234,     0,     0,     0,     0,
       0,   235,   236,     0,     0,     0,     0,     0,   237,     0,
       0,     0,   239,   430,     0,     0,     0,     0,     0,     0,
     242,     0,   243,   244,     0,   245,     0,     0,     0,   247,
     248,   249,   250,   251,   252,     0,   253,     0,     0,     0,
       0,   257,     0,     0,     0,     0,   260,     0,     0,   261,
       0,   262,   263,     0,     0,     0,   264,     0,     0,     0,
       0,     0,     0,     0,   266,   267,   268,     0,     0,     0,
     269,   270,   271,     0,   272,   273,     0,   274,   275,     0,
     276,     0,     0,     0,   277,     0,     0,   278,   279,     0,
       0,     0,     0,     0,   280,   281,     0,     0,   284,   285,
     431,     0,   286,   429,     0,   208,   209,   659,   289,   290,
       0,   660,     1,     0,     2,     0,     0,    39,     0,   432,
       0,    43,    44,     0,     0,   295,   296,   297,   214,   215,
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
       0,     0,   284,   285,     0,     0,   286,   429,     0,   208,
     209,   534,   289,   290,     0,     0,     1,     0,     2,     0,
       0,    39,     0,   432,     0,    43,    44,     0,     0,   295,
     296,   297,   214,   215,     0,     0,     0,     0,   216,   217,
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
       0,     0,   280,   281,     0,     0,   284,   285,     0,     0,
     286,   429,     0,   208,   209,     0,   289,   290,     0,   660,
       1,     0,     2,     0,     0,    39,     0,   432,     0,    43,
      44,     0,     0,   295,   296,   297,   214,   215,     0,     0,
       0,     0,   216,   217,   218,   219,   220,   221,   222,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
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
     284,   285,     0,     0,   286,   429,     0,   208,   209,     0,
     289,   290,     0,     0,     1,     0,     2,     0,     0,    39,
       0,   432,     0,    43,    44,     0,     0,   295,   296,   297,
     214,   215,     0,     0,     0,     0,   216,   217,   218,   219,
     220,   221,   222,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   225,     0,     0,   228,     0,
       0,     0,     0,   229,   230,   231,     0,     0,     0,     0,
     233,   234,     0,     0,     0,     0,     0,   235,   236,     0,
       0,     0,     0,     0,   237,     0,     0,     0,   239,     0,
       0,     0,     0,     0,     0,     0,   242,     0,   243,   244,
       0,   245,     0,     0,     0,   247,   248,   249,   250,   251,
     252,     0,   253,     0,     0,     0,     0,   257,     0,     0,
       0,     0,   260,     0,     0,   261,     0,   262,   263,     0,
       0,     0,   264,     0,     0,     0,     0,     0,     0,     0,
     266,   267,   268,     0,     0,     0,   269,   270,   271,     0,
     272,   273,     0,   274,   275,     0,   276,     0,     0,     0,
     277,     0,     0,   278,   279,     0,     0,     0,     0,     0,
     280,   281,     0,     0,   284,   285,     0,     0,   286,     0,
       0,     0,     0,   429,   289,   290,     0,   613,   614,     0,
       0,     0,     1,    39,     2,   432,     0,    43,    44,     0,
       0,   295,   296,   297,     0,     0,     0,     0,   214,   215,
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
       0,     0,   284,   285,     0,     0,   286,   429,     0,     0,
       0,     0,   289,   290,     0,     0,     1,     0,     2,     0,
       0,    39,     0,   432,     0,    43,    44,     0,     0,   295,
     296,   297,   214,   215,     0,     0,     0,     0,   216,   217,
     218,   219,   220,   221,   222,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   225,     0,     0,
     228,     0,     0,     0,     0,   229,   230,   231,     0,     0,
       0,     0,   233,   234,     0,     0,     0,     0,     0,   235,
     236,     0,     0,     0,     0,     0,   237,     0,     0,     0,
     239,     0,     0,     0,     0,     0,     0,     0,   242,     0,
     243,   244,     0,   245,     0,     0,     0,   247,   248,   249,
     250,   251,   252,     0,   253,     0,     0,     0,     0,   257,
       0,     0,     0,     0,   260,     0,     0,   261,   634,   262,
     263,     0,     0,     0,   264,     0,     0,   635,     0,   636,
       0,     0,   266,   267,   268,     0,     0,     0,   269,   270,
     271,     0,   272,   273,     0,   274,   275,     0,   276,     0,
       0,     0,   277,     0,     0,   278,   279,     0,     0,     0,
     223,   224,   280,   281,   707,     0,   284,   285,     0,     0,
     286,     0,     0,   635,     0,   636,   289,   290,     0,   232,
       0,     0,     0,     0,     0,    39,     1,   432,     2,    43,
      44,     0,     0,   295,   296,   297,     0,     0,     0,   238,
       0,     0,     0,     0,     0,   241,   223,   224,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   223,
       0,     0,     0,     0,     0,   232,     0,     0,   226,   256,
     228,   258,   259,     0,     0,     0,     0,   231,   232,     0,
       0,     0,     0,     0,     0,   238,     0,     0,     0,   235,
     236,   241,     0,     0,     0,     0,     0,     0,   238,     0,
       0,     0,     0,     0,   241,     0,     0,     0,     0,     0,
       0,     0,    30,     0,     0,   256,     0,   258,   259,     0,
       0,     0,     0,    16,     0,     0,   283,     0,   256,     0,
     258,   259,     0,     0,   260,   287,   288,     0,     0,   262,
     263,     0,    35,   291,    37,     0,    39,   116,    41,    42,
       0,     0,     0,   267,     0,     0,     0,     0,    30,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    30,   283,     0,     0,     0,     0,     0,     0,     0,
       0,   287,   288,     0,     0,   283,     0,     0,    35,   291,
      37,     0,    39,   116,    41,    42,     0,     0,     0,     0,
       0,    35,    36,    37,    38,    39,   116,    41,    42,    43,
      44,   294,     0,   295,   296,   297,     1,     0,     2,     0,
       0,     0,     3,     0,     0,     0,     0,     0,     0,     0,
       0,     4,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   121,     0,   122,     0,     0,     0,     0,
       0,     0,     0,     5,     6,     0,     0,   124,     0,   125,
     126,     0,     0,     0,     7,     0,     0,     0,   127,     8,
       0,     0,     0,     7,     9,     0,     0,     0,     0,   128,
       0,     0,     0,     0,   129,    10,     0,     0,     0,    11,
       0,   130,    12,    13,     0,    14,     0,     0,     0,    15,
       0,   524,     0,     0,     0,     0,     0,     0,    15,   132,
       0,   133,     0,    16,     0,   134,     0,   135,     0,     0,
      17,    18,     0,     0,   136,     0,     0,     0,     0,     0,
       0,    19,    20,     0,     0,   525,    21,    22,    23,    24,
       0,     0,     0,     0,   139,    25,    26,    27,     0,   140,
       0,    28,     0,   141,     0,     0,     0,     0,     0,     0,
      29,    30,     0,   142,     0,     1,     0,     2,   143,    31,
       0,     3,     0,     0,     0,     0,     0,     0,     0,    32,
       4,    33,     0,    34,     0,     0,     0,     0,     0,   145,
       0,    35,    36,    37,    38,    39,    40,    41,    42,    43,
      44,     0,     5,     6,    39,     0,     0,     0,     0,     0,
     474,     0,     0,     0,     0,     0,     0,     0,     8,     0,
       0,     0,     0,     9,     0,     0,     0,   475,     0,     0,
       0,     0,     0,     0,    10,     0,     0,     0,    11,     0,
       0,    12,    13,     0,    14,     0,     0,     0,     0,     0,
       0,     0,     0,   228,     0,     0,     0,     0,     0,     0,
     231,     0,    16,     0,     0,     0,     0,     0,     0,    17,
      18,     0,   235,   236,     0,     0,     0,     0,     0,     0,
      19,    20,     0,     0,     0,    21,    22,    23,    24,     0,
       0,     0,     0,     0,    25,    26,    27,     1,     0,     2,
      28,     0,     0,     3,     0,     0,     0,     0,     0,    29,
      30,     0,     4,     0,     0,     0,     0,   260,    31,     0,
       0,     0,   262,   263,     0,     0,     0,     0,    32,     0,
      33,     0,    34,     0,     5,     6,   267,     0,     0,     0,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
       0,     0,     0,     0,     0,     9,     0,     0,   403,     0,
       0,     0,     0,     0,     0,     0,    10,     0,     0,     0,
      11,     0,     0,    12,    13,     0,    14,     0,     0,     0,
       0,     0,     0,     0,    35,    36,    37,    38,    39,   116,
      41,    42,    43,    44,    16,     0,     0,     0,     0,     0,
       0,    17,    18,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    19,    20,     0,     0,     0,    21,     0,    23,
      24,     0,     0,     0,     0,     0,    25,    26,    27,     1,
       0,     2,    28,     0,     0,     3,     0,     0,     0,     0,
       0,     0,    30,     0,     4,     0,     0,     0,     0,   404,
      31,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      32,     0,    33,     0,    34,     0,     5,     6,     0,     0,
       0,     0,    35,    36,    37,    38,    39,    40,    41,    42,
      43,    44,     0,     0,     0,     0,     0,     9,     0,     0,
     403,     0,     0,     0,     0,     0,     0,     0,    10,     0,
     394,     0,    11,     0,     0,     0,    13,     0,    14,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    16,     0,     0,     0,
       0,     0,     0,    17,    18,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    19,    20,     0,     0,     0,    21,
       0,    23,    24,     0,     0,     0,     0,     0,    25,    26,
      27,     0,     0,     0,    28,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    30,     0,     0,     0,     0,     0,
     395,     0,    31,     1,     0,     2,     0,     0,     0,     3,
       0,     0,   396,     0,    33,     0,    34,     0,     4,     0,
       0,     0,     0,     0,    35,    36,    37,    38,    39,   116,
      41,    42,    43,    44,     0,     0,     0,     0,     0,     0,
       5,     6,     0,     0,     0,     0,     0,     0,   474,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     9,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    10,     0,   394,     0,    11,     0,     0,     0,
      13,     0,    14,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      16,     0,     0,     0,     0,     0,     0,    17,    18,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    19,    20,
       0,     0,     0,    21,     0,    23,    24,     0,     0,     0,
       0,     0,    25,    26,    27,     1,     0,     2,    28,     0,
       0,     3,     0,     0,     0,     0,     0,     0,    30,     0,
       4,     0,     0,     0,   395,     0,    31,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   396,     0,    33,     0,
      34,     0,     5,     6,     0,     0,     0,     0,    35,    36,
      37,    38,    39,   116,    41,    42,    43,    44,     0,     0,
       0,     0,     0,     9,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    10,     0,   394,     0,    11,     0,
       0,     0,    13,     0,    14,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    16,     0,     0,     0,     0,     0,     0,    17,
      18,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      19,    20,     0,     0,     0,    21,     0,    23,    24,     0,
       0,     0,     0,     0,    25,    26,    27,     0,     0,     0,
      28,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,     0,     0,     0,     0,     0,   395,     0,    31,     1,
       0,     2,     0,     0,     0,     3,     0,     0,   396,     0,
      33,     0,    34,     0,     4,     0,     0,     0,     0,     0,
      35,    36,    37,    38,    39,   116,    41,    42,    43,    44,
       0,     0,     0,     0,     0,     0,     5,     6,     0,     0,
       0,     0,     0,     0,   474,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     9,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    10,     0,
       0,     0,    11,     0,     0,    12,    13,     0,    14,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    16,     0,     0,     0,
       0,     0,     0,    17,    18,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    19,    20,     0,     0,     0,    21,
       0,    23,    24,     0,     0,     0,     0,     0,    25,    26,
      27,     1,     0,     2,    28,     0,     0,     3,     0,     0,
       0,     0,     0,     0,    30,     0,     4,     0,     0,     0,
       0,     0,    31,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    32,     0,    33,     0,    34,     0,     5,     6,
       0,     0,     0,     0,    35,    36,    37,    38,    39,    40,
      41,    42,    43,    44,     0,     0,     0,     0,     0,     9,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      10,     0,     0,     0,    11,     0,     0,    12,    13,     0,
      14,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    16,     0,
       0,     0,     0,     0,     0,    17,    18,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    19,    20,     0,     0,
       0,    21,     0,    23,    24,     0,     0,     0,     0,     0,
      25,    26,    27,     1,     0,     2,    28,     0,     0,     3,
       0,     0,     0,     0,     0,     0,    30,     0,     4,     0,
       0,     0,     0,     0,    31,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   374,     0,    33,     0,    34,     0,
       5,     6,     0,     0,     0,     0,    35,    36,    37,    38,
      39,    40,    41,    42,    43,    44,     0,     0,     0,     0,
       0,     9,     0,     0,   403,     0,     0,     0,     0,     0,
       0,     0,    10,     0,     0,     0,    11,     0,     0,     0,
      13,     0,    14,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      16,     0,     0,     0,     0,     0,     0,    17,    18,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    19,    20,
       0,     0,     0,    21,     0,    23,    24,     0,     0,     0,
       0,     0,    25,    26,    27,     0,     0,     0,    28,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    30,     0,
       0,     0,     1,     0,     2,     0,    31,     0,     3,     0,
       0,     0,     0,     0,     0,     0,   374,     4,    33,     0,
      34,     0,     0,     0,     0,     0,     0,     0,    35,    36,
      37,    38,    39,   116,    41,    42,    43,    44,     0,     5,
       6,     0,     0,     0,     0,     0,     0,   474,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       9,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    10,     0,     0,     0,    11,     0,     0,     0,    13,
       0,    14,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    16,
       0,     0,     0,     0,     0,     0,    17,    18,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    19,    20,     0,
       0,     0,    21,     0,    23,    24,     0,     0,     0,     0,
       0,    25,    26,    27,     1,     0,     2,    28,     0,     0,
       3,     0,     0,     0,     0,     0,     0,    30,     0,     4,
       0,     0,     0,     0,     0,    31,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   374,     0,    33,     0,    34,
       0,     5,     6,     0,     0,     0,     0,    35,    36,    37,
      38,    39,   116,    41,    42,    43,    44,     0,     0,     0,
       0,     0,     9,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    10,     0,     0,     0,    11,     0,     0,
       0,    13,     0,    14,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    16,     0,     0,     0,     0,     0,     0,    17,    18,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    19,
      20,     0,     0,     0,    21,     0,    23,    24,     0,     0,
       0,     0,     0,    25,    26,    27,     0,     0,     0,    28,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    30,
       0,     0,     0,     0,     0,     0,     0,    31,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   374,     0,    33,
       0,    34,     0,     0,     0,     0,     0,     0,     0,    35,
      36,    37,    38,    39,   116,    41,    42,    43,    44,   121,
       0,   122,     0,     0,     0,     0,     0,     0,     0,     0,
     123,     0,     0,   124,     0,   125,   126,     0,     0,     0,
       0,     0,     0,     0,   127,     0,     0,     0,     0,     7,
       0,     0,     0,     0,     0,   128,     0,     0,     0,     0,
     129,     0,     0,     0,     0,     0,     0,   130,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   131,     0,     0,
       0,     0,     0,     0,    15,   132,     0,   133,     0,     0,
       0,   134,   121,   135,   122,     0,     0,     0,     0,     0,
     136,     0,     0,   123,     0,     0,   124,     0,   125,   126,
       0,   137,     0,   138,     0,     0,     0,   127,     0,     0,
     139,     0,     7,     0,     0,   140,     0,     0,   128,   141,
       0,     0,     0,   129,     0,     0,     0,     0,     0,   142,
     130,     0,     0,     0,   143,     0,     0,     0,     0,     0,
     131,     0,   144,     0,     0,     0,     0,    15,   132,     0,
     133,     0,     0,     0,   134,   145,   135,     0,     0,     0,
       0,     0,     0,   136,     0,     0,    35,   146,   147,    38,
     148,   149,   150,   151,   137,    44,   138,     0,     0,     0,
       0,     0,     0,   139,     0,     0,     0,     0,   140,     0,
       0,     0,   141,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   142,     0,     0,     0,     0,   143,     0,     0,
       0,     0,     0,     0,     0,   144,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   145,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    39
};

static const yytype_int16 yycheck[] =
{
       0,     5,     2,    77,   158,     5,   324,    70,   388,   370,
      91,     1,    50,    76,    80,   168,   183,   364,   151,     8,
     387,    25,     8,    23,    24,    25,   320,    27,    28,    91,
     101,   663,    12,    76,   300,   301,   646,    91,    88,   172,
     171,    79,   303,    91,    72,   100,   150,     0,    19,    72,
      50,   155,    21,    91,     0,   194,    15,     0,    17,    91,
     522,   399,    21,    58,  1056,     4,     8,     9,    63,     8,
      70,    71,    72,    91,    74,  1067,    76,    21,    78,    79,
      80,     6,    86,    22,    83,    21,    86,    91,    83,   383,
       5,    91,    92,    93,    94,     0,    96,    50,   899,    21,
      23,    23,    61,   167,    23,     4,   609,   107,    23,   109,
      54,   111,   112,     5,    95,     0,    34,    70,    71,    21,
      45,    74,    21,    76,    95,    78,    79,    68,    19,    74,
      21,    23,    72,   132,     5,    21,    77,     4,    91,    92,
     643,    94,   752,    96,   103,    25,    90,    33,    94,   170,
       6,    94,    23,   112,   107,   183,   109,   189,   111,   112,
     183,    28,    21,   122,    82,    21,    72,   199,   200,     8,
     170,    70,     4,    12,     5,    55,   194,   195,     0,    21,
     180,   162,   171,   183,   207,   171,   199,   649,   555,    94,
      29,   162,     6,    78,    25,   136,    28,   156,   121,   121,
      21,   160,   121,    45,   163,    19,   121,   207,   153,    94,
     210,   211,   379,   346,  1015,    36,   347,   578,   159,    15,
     210,    17,   191,   192,    55,   194,   195,   196,   170,   121,
       6,   190,   171,   177,   193,   194,    48,   181,   197,   198,
     199,   177,     4,   183,    62,   181,   169,     6,    70,    71,
     121,  1052,    74,   139,    76,    67,    78,   210,   211,    21,
     240,   100,    21,   601,   602,   603,   604,   207,     6,   901,
      92,    46,    94,    91,     4,     8,     9,   183,   177,     6,
       4,    93,   181,   364,     6,   646,    45,   625,     4,   191,
     192,    21,    25,   195,   196,    11,   298,    21,   645,     6,
       8,     9,     4,    19,   642,   117,   644,   125,    15,   127,
      17,   150,    28,     4,   377,   170,   155,   349,   350,    21,
     320,    96,    55,   162,    80,   692,   364,   365,   328,   331,
      21,   369,   191,   192,   377,    24,   195,   196,    46,   633,
      80,   607,   608,   406,   348,   120,   612,    36,   348,   124,
     350,   379,   613,   614,    19,    15,   379,    17,   347,   425,
     364,   347,    27,   406,   364,   365,   976,   367,   368,   369,
      80,   167,   372,     8,     9,   528,     6,   377,   380,   379,
     370,   370,   384,   383,   370,   423,    21,   382,    11,   384,
     385,   386,   525,   546,   527,    18,   446,   194,   194,   399,
     197,   240,   198,   199,  1014,   467,   406,   430,   347,   124,
       0,   364,   365,   467,   477,   404,   369,   440,   404,   467,
     524,     8,     9,   423,   377,   425,   449,   427,   499,   467,
     430,   893,   894,    23,   477,   467,    72,    27,    28,   379,
     440,     6,   497,    11,    70,    71,     6,   468,    74,   449,
     170,    19,   112,   406,   518,   519,   520,   521,     6,    19,
      50,    19,   464,    21,    51,   404,    92,   467,   468,   137,
     423,   191,   192,   379,   194,   195,   196,   477,   146,   479,
      70,    71,   150,    19,    74,   549,    76,   194,    78,    79,
       6,   198,   199,    22,   194,   202,   203,   650,   198,   199,
     160,    91,    92,    19,    94,   505,    96,   507,     6,   509,
       6,   511,     5,    21,   467,     8,     9,   107,     6,   109,
     881,   111,   112,    19,   477,    28,   479,     4,     4,     5,
     190,   370,    25,   193,   194,     8,     9,   197,   198,   199,
     707,   530,    11,    11,   530,    21,    22,   183,    21,    21,
      19,    19,   505,     6,   507,   377,   509,   552,   511,   591,
     198,   199,    55,   930,   645,   404,    19,     8,     9,     8,
       9,    21,   593,   953,   595,    11,   597,   579,   599,   581,
      21,    11,    21,    19,   406,    21,   880,    16,    18,   202,
     203,   530,   190,   593,   479,   595,   194,   597,    11,   599,
     621,   601,   602,   603,   604,   633,     6,   645,   640,   609,
     190,   634,   551,   193,   194,   976,     6,   197,   198,   199,
     505,   621,   507,   177,   509,   625,   511,   181,   628,    27,
      28,    29,   632,   633,   634,   635,   636,   576,     6,   905,
     906,   645,   642,   643,   644,   645,     6,     8,     9,     6,
       8,     9,     6,    14,     6,   477,   646,   646,   497,     9,
     646,   814,   815,    21,    25,   191,   192,     4,   194,   195,
     196,   734,   190,    21,   513,   677,   194,   516,   673,   707,
     198,   199,   635,   636,   707,   524,    20,  1005,   690,   691,
     112,   734,   645,   731,    55,   112,   691,     4,   726,   116,
     728,   701,   702,   703,   704,   705,   706,   707,   708,   709,
     710,   711,   712,   713,    48,     5,     9,   780,     8,     9,
     720,   721,   722,   723,   724,   725,   726,    21,   728,     8,
       9,   731,   365,    67,   734,    14,   369,   780,    21,   578,
      74,   764,     6,   379,    21,   899,    25,     0,   190,   753,
      21,   193,   194,   753,   196,   197,   107,   199,   109,    93,
     111,   112,   752,    21,   764,    12,    13,   707,   708,   709,
     710,   711,   712,   713,   364,   365,    55,    21,   731,   369,
     780,   734,    21,   117,     4,     5,   726,   377,   728,   187,
     188,   189,     0,     4,     5,     8,     9,    50,   190,   191,
     192,   707,   194,   195,   196,   197,    51,   646,   714,   715,
     716,   717,   718,   719,     4,     5,   406,    70,    71,   153,
     726,    74,   728,    76,    11,    78,    79,   780,     4,     5,
     851,     6,   853,   423,   855,     6,   857,   827,    91,    92,
     779,    94,    50,    96,     4,     5,    25,     6,    27,    28,
      29,   851,     6,   853,   107,   855,   109,   857,   111,   112,
     846,  1015,    70,    71,   864,     6,    74,     6,    76,     6,
      78,    79,     0,     7,   191,   192,    55,   467,   195,   196,
     880,    19,   956,    91,    92,    21,    94,   477,    96,   479,
       5,     4,     5,     8,     9,   881,    27,    28,    29,   107,
       6,   109,     5,   111,   112,     8,     9,     6,   908,   200,
     910,   911,   734,   752,     6,   505,     6,   507,     6,   509,
       5,   511,    50,     0,   864,     4,     5,   180,     6,   931,
     932,   933,   934,   935,   936,   937,     5,     4,     5,     8,
       9,     5,    70,    71,     8,     9,    74,     6,    76,     5,
      78,    79,     8,     9,    96,    75,    21,   952,   780,     6,
       6,     6,     6,    91,    92,   107,    94,   109,    96,   111,
     112,     4,     5,    50,     5,    24,     6,     8,     9,   107,
       6,   109,    11,   111,   112,     6,   976,   135,   827,    21,
     976,     4,     5,    70,    71,     5,   632,    74,     4,    76,
      86,    78,    79,  1041,    49,    50,    21,   846,   187,   188,
     189,  1049,    21,    58,    91,    92,    21,    94,     6,    96,
       4,     5,  1060,     5,  1014,  1014,     8,     9,     5,    74,
     107,    80,   109,    45,   111,   112,    81,     4,     5,     0,
      21,  1041,   881,    25,    93,    27,    28,    29,    25,  1049,
      27,    28,    29,    21,    99,   645,   187,   188,   189,    21,
    1060,  1000,   107,     4,     5,   701,   702,   703,   704,   705,
     706,   707,     5,    55,    21,     8,     9,     5,    55,   202,
       8,     9,     8,     9,     4,     5,     4,     5,  1041,    50,
     726,     5,   728,     5,     8,     9,  1049,   350,   143,    25,
       5,    27,    28,    29,     4,     5,   159,  1060,   153,    70,
      71,   364,   365,    74,    11,    76,   369,    78,    79,     4,
       5,     4,     5,    21,   377,     4,     5,    49,    50,    55,
      91,    92,     4,    94,   179,    96,    58,   976,     4,     5,
      21,   731,     5,     5,   734,    21,   107,   201,   109,   194,
     111,   112,    74,   406,    11,    11,   364,   365,    16,    81,
      19,   369,     6,    18,    25,     6,    27,    28,    29,   377,
     423,     6,     6,     6,    11,  1014,     5,    99,    21,   170,
       5,    59,    20,   170,     5,   107,     6,    75,    66,    21,
     780,    21,    11,    21,    55,    21,     5,    21,   406,    21,
      78,    79,     5,    21,    21,   187,   188,   189,    21,    21,
     187,   188,   189,    21,   467,   423,     5,     4,    28,     5,
       5,   143,     6,     5,   477,    20,   479,     5,    11,     5,
       5,   153,     5,   170,     5,     5,   364,   365,     6,    20,
      20,   369,    21,   404,    21,   123,    20,   162,   530,   377,
     128,   129,   505,   618,   507,    21,   509,   179,   511,   467,
     911,   187,   188,   189,   142,   306,   628,   227,   387,   477,
     726,   479,   194,   728,  1060,   425,    78,   423,   406,   328,
     367,   446,   393,   185,   467,     0,    12,   364,   365,    12,
      12,   480,   369,    -1,   501,   423,    -1,   505,    -1,   507,
     377,   509,    -1,   511,    -1,    24,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,     0,   194,    -1,   367,   368,
     198,   199,    -1,   372,    -1,    10,   187,   188,   189,   406,
      -1,    -1,    -1,    -1,    -1,    -1,    21,   479,    -1,   467,
      -1,    -1,    -1,    -1,    -1,    -1,   423,    -1,    -1,   477,
     399,   479,    -1,    72,    -1,    15,    -1,    17,    -1,    -1,
      -1,    80,    -1,   505,    -1,   507,    85,   509,    -1,   511,
      -1,    -1,    -1,    -1,    -1,    -1,   425,   505,   427,   507,
      -1,   509,    -1,   511,    -1,    70,    71,    -1,    -1,    74,
     467,    76,   645,    78,    -1,    -1,    -1,    -1,    -1,    59,
     477,    -1,   479,   364,   365,    -1,    66,    92,   369,    94,
      -1,    96,    -1,    -1,    -1,    -1,   377,    -1,    78,    79,
      -1,    -1,   107,    -1,   109,    -1,   111,   112,   505,    -1,
     507,    -1,   509,    -1,   511,    -1,    -1,   645,    -1,    -1,
     159,    -1,    -1,    -1,    -1,   406,    -1,    -1,   167,    -1,
      -1,  1041,   112,    -1,    -1,    -1,   116,    -1,    -1,  1049,
     179,    -1,   423,   123,   183,    -1,    -1,   186,   128,   129,
    1060,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   731,    -1,
      -1,   734,   142,    -1,    -1,    -1,    47,    -1,   207,    -1,
      51,    52,    21,    54,    15,    56,    17,    -1,    -1,    -1,
     160,    -1,    -1,    -1,    -1,    -1,   467,    -1,    -1,    -1,
     195,    -1,    -1,    -1,    -1,    -1,   477,   645,   479,    -1,
      49,    50,    -1,   731,    -1,    -1,   734,   780,    -1,    58,
     190,   191,   192,   193,   194,   195,   196,   197,   198,   199,
      61,    -1,    -1,    -1,   505,    74,   507,    -1,   509,    -1,
     511,    -1,   601,   602,   603,   604,    -1,   118,   190,   191,
     192,   193,   194,   195,   196,   197,    -1,   199,   645,    -1,
      99,    -1,   780,    -1,    -1,    -1,   625,    -1,   107,    -1,
      -1,    -1,   103,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   112,    59,   642,    -1,   644,    -1,    -1,    -1,    66,
      -1,   122,    -1,   731,    -1,    -1,   734,    -1,    -1,   328,
      -1,    78,    79,    -1,   143,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   153,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   353,   156,   197,   198,    -1,   160,
      -1,    -1,   163,    -1,    -1,    -1,    -1,    -1,   367,   368,
     179,    -1,   780,   372,   731,    -1,   123,   734,    -1,    -1,
     379,   128,   129,   224,    -1,   194,   227,    -1,    -1,   190,
      -1,    -1,   193,   194,    -1,   142,   197,   198,   199,   298,
     399,    -1,   243,    -1,   645,    -1,    -1,   248,    -1,    -1,
      -1,    -1,   377,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   780,     6,    -1,   425,   268,   427,   428,
     429,    -1,   431,    15,    -1,    17,    -1,    -1,   403,   438,
     439,   406,    -1,    -1,    -1,   286,   193,   194,    -1,    -1,
     449,   198,   199,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    48,    -1,    -1,    -1,
      -1,    -1,    -1,   314,    -1,    57,    -1,    -1,    -1,    -1,
      -1,   380,    -1,    -1,    -1,    67,    -1,    -1,    -1,    -1,
     731,    -1,    -1,   734,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   343,    -1,    -1,    87,    -1,    -1,  1041,   474,
      -1,    93,   477,    -1,   479,    -1,  1049,    -1,    -1,   518,
     519,   520,   521,    -1,    -1,    -1,    -1,  1060,    -1,    -1,
     112,    -1,    -1,    -1,   433,   117,    -1,   119,   120,   780,
     505,    -1,   507,    -1,   509,    -1,   511,    -1,    -1,    -1,
     549,   516,    -1,  1041,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,  1049,    -1,    -1,    -1,   464,    -1,    -1,    -1,    -1,
      -1,    -1,  1060,    -1,    -1,    -1,    -1,    -1,   160,   908,
      -1,   910,   911,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   174,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   601,   602,   603,   604,    -1,    -1,   190,    -1,
     609,   193,   194,    -1,    -1,   197,   198,   199,   200,    -1,
     202,   203,   204,    -1,    -1,    -1,   625,    -1,    -1,    -1,
      -1,    -1,    -1,  1041,    -1,    -1,   535,    -1,   298,    -1,
      -1,  1049,    -1,   642,   643,   644,    -1,    -1,    -1,    -1,
      -1,   550,  1060,    -1,   653,    -1,    -1,    -1,    -1,    -1,
     559,    -1,    -1,    -1,   663,    -1,    -1,    -1,    -1,    -1,
      -1,   512,    -1,   514,    -1,    -1,     0,    -1,    -1,    -1,
     579,   646,    -1,    -1,  1041,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,  1049,    -1,   693,   694,   695,   696,   697,   698,
      -1,    -1,    -1,  1060,    -1,    -1,    -1,    -1,   707,   708,
     709,   710,   711,   712,   713,    -1,    -1,    -1,    -1,    -1,
     380,    33,    -1,    35,    -1,    -1,    -1,   726,    -1,   728,
      -1,    -1,    -1,    -1,    -1,    47,    -1,    -1,   737,   738,
     739,   740,   741,    -1,    -1,    -1,    70,    71,    72,    -1,
      74,    63,    -1,    -1,    78,    -1,    -1,    69,    -1,   758,
      -1,    -1,   661,   762,   763,   764,   665,    -1,    92,   734,
      94,    -1,    96,   433,    -1,    -1,    -1,    -1,   677,    -1,
      -1,    -1,    -1,   107,    -1,   109,    98,   111,   112,   101,
      -1,   690,    -1,   105,    -1,    -1,    -1,    -1,    -1,    -1,
    1041,    -1,   114,    -1,   464,    -1,    -1,    -1,  1049,    -1,
      -1,    -1,    -1,    -1,    -1,   780,    -1,    -1,    -1,  1060,
      -1,    -1,   134,    -1,    -1,    -1,    -1,   139,    -1,    -1,
     829,    -1,   831,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   683,   684,   685,   686,   158,   746,   747,    -1,
      -1,   750,    -1,    -1,    -1,    -1,   755,   756,    -1,   183,
      -1,    -1,    -1,    -1,    -1,   864,   765,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   535,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     550,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   897,   559,
      -1,   900,   901,    -1,    -1,    -1,    -1,    -1,    33,   908,
      35,   910,   911,    -1,    -1,    -1,   881,    -1,    -1,   579,
      -1,    -1,    47,    -1,    49,    50,     6,    -1,    -1,    -1,
      -1,    -1,    -1,    58,    -1,    15,    -1,    17,    63,    -1,
      -1,    -1,    -1,    -1,    69,    -1,    26,    -1,    -1,    74,
      -1,    -1,    -1,    -1,    -1,    -1,    81,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   807,   866,    48,    49,
      -1,    -1,    -1,    98,    99,    -1,   101,    -1,    -1,    -1,
     105,    -1,   107,    -1,    -1,    -1,   885,    67,    -1,   114,
      70,    -1,    -1,    -1,    -1,    -1,    -1,   896,    -1,    -1,
      -1,   661,    -1,   902,   845,   665,   847,    87,    -1,   134,
      -1,   976,    -1,    93,   139,    -1,    -1,   677,   143,   918,
     919,   920,   921,   922,   923,    -1,    -1,    -1,   153,    -1,
     690,    -1,   931,   158,    -1,   115,    -1,   117,    -1,   119,
     120,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   890,
      -1,  1050,    -1,    -1,   179,   379,    -1,    -1,    -1,    -1,
      22,    -1,   961,   962,   963,   964,   965,    -1,    -1,   194,
    1069,    33,    -1,    35,   973,   974,   975,    -1,    -1,    -1,
     160,    -1,    -1,    -1,    -1,    47,   746,   747,    -1,    -1,
     750,    -1,    -1,    -1,   174,   755,   756,    -1,    -1,   998,
     999,    63,    -1,   183,   184,   765,    15,    69,    17,    -1,
     190,   191,   192,    -1,   194,   195,   196,   197,    -1,    -1,
      -1,    -1,    -1,    33,    -1,    35,    -1,    -1,    -1,  1028,
      -1,    -1,    -1,  1032,    -1,    -1,    98,    47,    -1,   101,
      -1,    -1,    -1,   105,    -1,    -1,    -1,    -1,    -1,    -1,
      59,    -1,   114,    63,    -1,   479,     6,    66,    -1,    69,
      -1,    -1,    -1,    -1,    -1,    15,  1065,    17,    -1,    78,
      79,    81,   134,    -1,  1073,    -1,    26,   139,    -1,    -1,
      -1,   505,    -1,   507,    -1,   509,    -1,   511,    98,    -1,
      -1,   101,    -1,    -1,    -1,   105,   158,    -1,    48,    49,
      -1,    -1,    -1,   112,   114,    -1,   866,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   123,    -1,    -1,    67,    -1,   128,
     129,    -1,    -1,    -1,   134,   885,    -1,    -1,    -1,   139,
      -1,    -1,    -1,   142,    -1,    -1,   896,    87,    -1,    -1,
      -1,    -1,   902,    93,    -1,    -1,    -1,    -1,   158,    -1,
      -1,   160,    -1,    -1,    -1,    -1,    -1,    -1,   918,   919,
     920,   921,   922,   923,    -1,   115,    -1,   117,    -1,   119,
     120,   931,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   190,   191,   192,   193,   194,   195,   196,   197,   198,
     199,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   961,   962,   963,   964,   965,    -1,    -1,    -1,    -1,
     160,    -1,    -1,   973,   974,   975,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   174,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   183,   184,     0,    -1,    -1,   998,   999,
     190,   191,   192,    -1,   194,   195,   196,   197,    -1,    -1,
      15,    59,    17,    -1,    -1,    -1,    21,    -1,    66,    -1,
      -1,    -1,    -1,    -1,    -1,    30,    -1,    -1,  1028,    -1,
      78,    79,  1032,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   707,    -1,    -1,    -1,    52,    53,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   720,   721,   722,   723,
     724,   725,   726,    68,   728,  1065,    -1,    -1,    73,    -1,
      -1,    -1,    -1,  1073,    -1,   123,    -1,    -1,    -1,    84,
     128,   129,    -1,    88,    -1,    -1,    91,    92,    22,    94,
      -1,    -1,    -1,    -1,   142,    -1,    -1,    -1,    -1,    33,
      -1,    35,    -1,    -1,    -1,    -1,    -1,   112,    -1,    -1,
      -1,    -1,    -1,    47,   119,   120,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   130,   131,    -1,    -1,    63,
     135,   136,   137,   138,    -1,    69,    -1,    -1,    -1,   144,
     145,   146,   190,   191,   192,   150,   194,   195,   196,   197,
     198,   199,    -1,    -1,   159,   160,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   168,    98,    -1,    -1,   101,    -1,    -1,
      -1,   105,    -1,   178,    -1,   180,    -1,   182,    -1,    -1,
     114,    -1,    -1,    -1,    -1,   190,   191,   192,   193,   194,
     195,   196,   197,   198,   199,     6,    -1,     8,     9,    -1,
     134,    -1,    -1,    -1,    15,   139,    17,    -1,    -1,    -1,
      21,    -1,    -1,    -1,    -1,    26,    -1,    -1,    -1,    -1,
      31,    32,    -1,    -1,   158,    -1,    37,    38,    39,    40,
      41,    42,    43,    -1,    -1,    -1,    -1,    48,    49,    -1,
      -1,    -1,    -1,    -1,    -1,    56,    57,    58,    59,    -1,
      61,    -1,    -1,    64,    65,    66,    67,    -1,    -1,    -1,
      71,    72,    -1,    -1,    -1,    -1,    -1,    78,    79,    -1,
      -1,    -1,    -1,    -1,    85,    -1,    87,    -1,    89,    -1,
      91,    -1,    93,    -1,    -1,    -1,    97,    -1,    99,   100,
      -1,   102,   103,   104,    -1,   106,   107,   108,   109,   110,
     111,   112,   113,    -1,   115,   116,   117,   118,   119,   120,
      -1,   122,   123,    -1,    -1,   126,    -1,   128,   129,    -1,
      -1,    -1,   133,    -1,    -1,    -1,    -1,    -1,    -1,   140,
     141,   142,   143,    -1,    -1,    -1,   147,   148,   149,    -1,
     151,   152,    -1,   154,   155,   156,   157,    -1,    -1,   160,
     161,    -1,   163,   164,   165,    -1,    -1,    -1,    -1,    -1,
     171,   172,   173,   174,   175,   176,    -1,    -1,   179,    -1,
      -1,    -1,   183,   184,   185,   186,    -1,    -1,    -1,   190,
     191,   192,   193,   194,   195,   196,   197,   198,   199,   200,
      -1,   202,   203,   204,     6,    -1,     8,     9,    -1,    -1,
      -1,    -1,    -1,    15,    -1,    17,    -1,    -1,    -1,    -1,
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
      -1,   183,   184,   185,   186,    -1,    -1,    -1,   190,   191,
     192,   193,   194,   195,   196,   197,   198,   199,   200,    -1,
     202,   203,   204,     6,    -1,     8,     9,    -1,    -1,    -1,
      -1,    -1,    15,    -1,    17,    -1,    -1,    -1,    21,    -1,
      -1,    -1,    -1,    26,    -1,    -1,    -1,    -1,    31,    32,
      -1,    -1,    -1,    -1,    37,    38,    39,    40,    41,    42,
      43,    -1,    -1,    -1,    -1,    48,    49,    -1,    -1,    -1,
      -1,    -1,    -1,    56,    57,    58,    59,    -1,    -1,    -1,
      -1,    64,    65,    66,    67,    -1,    -1,    -1,    71,    72,
      -1,    -1,    -1,    -1,    -1,    78,    79,    -1,    -1,    -1,
      -1,    -1,    85,    -1,    87,    -1,    89,    -1,    91,    -1,
      93,    -1,    -1,    -1,    97,    -1,    99,   100,    -1,   102,
      -1,   104,    -1,   106,   107,   108,   109,   110,   111,   112,
     113,    -1,   115,   116,   117,   118,   119,   120,    -1,    -1,
     123,    -1,    -1,   126,    -1,   128,   129,    -1,    -1,    -1,
     133,    -1,    -1,    -1,    -1,    -1,    -1,   140,   141,   142,
     143,    -1,    -1,    -1,   147,   148,   149,    -1,   151,   152,
      -1,   154,   155,    -1,   157,    -1,    -1,   160,   161,    -1,
      -1,   164,   165,    -1,    -1,    -1,    -1,    -1,   171,   172,
     173,   174,   175,   176,    -1,    -1,   179,    -1,    -1,    -1,
     183,   184,   185,   186,    -1,    -1,    -1,   190,   191,   192,
     193,   194,   195,   196,   197,   198,   199,   200,    -1,   202,
     203,   204,     6,    -1,     8,     9,    10,    -1,    -1,    -1,
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
     184,   185,   186,    -1,    -1,    -1,   190,   191,   192,   193,
     194,   195,   196,   197,   198,   199,   200,    -1,   202,   203,
     204,     6,    -1,     8,     9,    -1,    -1,    -1,    -1,    -1,
      15,    -1,    17,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    26,    -1,    -1,    -1,    -1,    31,    32,    -1,    -1,
      -1,    -1,    37,    38,    39,    40,    41,    42,    43,    -1,
      -1,    -1,    -1,    48,    49,    -1,    -1,    -1,    -1,    -1,
      -1,    56,    57,    58,    59,    -1,    -1,    -1,    -1,    64,
      65,    66,    67,    -1,    -1,    -1,    71,    72,    -1,    -1,
      -1,    -1,    -1,    78,    79,    -1,    -1,    -1,    -1,    -1,
      85,    -1,    87,    88,    89,    -1,    91,    -1,    93,    -1,
      -1,    -1,    97,    -1,    99,   100,    -1,   102,    -1,   104,
      -1,   106,   107,   108,   109,   110,   111,   112,   113,    -1,
     115,   116,   117,   118,   119,   120,    -1,    -1,   123,    -1,
      -1,   126,    -1,   128,   129,    -1,    -1,    -1,   133,    -1,
      -1,    -1,    -1,    -1,    -1,   140,   141,   142,   143,    -1,
      -1,    -1,   147,   148,   149,    -1,   151,   152,    -1,   154,
     155,    -1,   157,    -1,    -1,   160,   161,    -1,    -1,   164,
     165,    -1,    -1,    -1,    -1,    -1,   171,   172,   173,   174,
     175,   176,    -1,    -1,   179,    -1,    -1,    -1,   183,   184,
     185,   186,    -1,    -1,    -1,   190,   191,   192,   193,   194,
     195,   196,   197,   198,   199,   200,    -1,   202,   203,   204,
       6,    -1,     8,     9,    10,    -1,    -1,    -1,    -1,    15,
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
     176,    -1,    -1,   179,    -1,    -1,    -1,   183,   184,   185,
     186,    -1,    -1,    -1,   190,   191,   192,   193,   194,   195,
     196,   197,   198,   199,   200,    -1,   202,   203,   204,     6,
      -1,     8,     9,    -1,    -1,    -1,    -1,    -1,    15,    -1,
      17,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    26,
      -1,    -1,    -1,    -1,    31,    32,    -1,    -1,    -1,    -1,
      37,    38,    39,    40,    41,    42,    43,    -1,    -1,    -1,
      -1,    48,    49,    -1,    -1,    -1,    -1,    -1,    -1,    56,
      57,    58,    59,    -1,    -1,    -1,    -1,    64,    65,    66,
      67,    -1,    -1,    -1,    71,    72,    -1,    -1,    -1,    -1,
      -1,    78,    79,    -1,    -1,    -1,    -1,    -1,    85,    -1,
      87,    -1,    89,    -1,    91,    -1,    93,    -1,    -1,    -1,
      97,    -1,    99,   100,    -1,   102,    -1,   104,    -1,   106,
     107,   108,   109,   110,   111,   112,   113,    -1,   115,   116,
     117,   118,   119,   120,    -1,    -1,   123,    -1,    -1,   126,
      -1,   128,   129,    -1,    -1,    -1,   133,    -1,    -1,    -1,
      -1,    -1,    -1,   140,   141,   142,   143,    -1,    -1,    -1,
     147,   148,   149,    -1,   151,   152,    -1,   154,   155,    -1,
     157,    -1,    -1,   160,   161,    -1,    -1,   164,   165,    -1,
      -1,    -1,    -1,    -1,   171,   172,   173,   174,   175,   176,
      -1,    -1,   179,    -1,    -1,    -1,   183,   184,   185,   186,
      -1,    -1,    -1,   190,   191,   192,   193,   194,   195,   196,
     197,   198,   199,   200,    -1,   202,   203,   204,     6,    -1,
       8,     9,    -1,    -1,    -1,    -1,    -1,    15,    -1,    17,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    26,    -1,
      -1,    -1,    -1,    31,    32,    -1,    -1,    -1,    -1,    37,
      38,    39,    40,    41,    42,    43,    -1,    -1,    -1,    -1,
      48,    49,    -1,    -1,    -1,    -1,    -1,    -1,    56,    57,
      58,    59,    -1,    -1,    -1,    -1,    64,    65,    66,    67,
      -1,    -1,    -1,    71,    72,    -1,    -1,    -1,    -1,    -1,
      78,    79,    -1,    -1,    -1,    -1,    -1,    85,    -1,    87,
      -1,    89,    -1,    91,    -1,    93,    -1,    -1,    -1,    97,
      -1,    99,   100,    -1,   102,    -1,   104,    -1,   106,   107,
     108,   109,   110,   111,   112,   113,    -1,   115,   116,   117,
     118,   119,   120,    -1,    -1,   123,    -1,    -1,   126,    -1,
     128,   129,    -1,    -1,    -1,   133,    -1,    -1,    -1,    -1,
      -1,    -1,   140,   141,   142,   143,    -1,    -1,    -1,   147,
     148,   149,    -1,   151,   152,    -1,   154,   155,    -1,   157,
      -1,    -1,   160,   161,    -1,    -1,   164,   165,    -1,    -1,
      -1,    -1,    -1,   171,   172,   173,   174,   175,   176,    -1,
      -1,   179,    -1,    -1,    -1,   183,   184,   185,   186,    -1,
      -1,    -1,   190,   191,   192,   193,   194,   195,   196,   197,
     198,   199,   200,    -1,   202,   203,   204,     6,    -1,     8,
       9,    -1,    -1,    -1,    -1,    -1,    15,    -1,    17,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    26,    -1,    -1,
      -1,    -1,    31,    32,    -1,    -1,    -1,    -1,    37,    38,
      39,    40,    41,    42,    43,    -1,    -1,    -1,    -1,    48,
      49,    -1,    -1,    -1,    -1,    -1,    -1,    56,    57,    58,
      59,    -1,    -1,    -1,    -1,    64,    65,    66,    67,    -1,
      -1,    -1,    71,    72,    -1,    -1,    -1,    -1,    -1,    78,
      79,    -1,    -1,    -1,    -1,    -1,    85,    -1,    87,    -1,
      89,    -1,    -1,    -1,    93,    -1,    -1,    -1,    97,    -1,
      99,   100,    -1,   102,    -1,   104,    -1,   106,   107,   108,
     109,   110,   111,    -1,   113,    -1,   115,    -1,   117,   118,
     119,   120,    -1,    -1,   123,    -1,    -1,   126,    -1,   128,
     129,    -1,    -1,    -1,   133,    -1,    -1,    -1,    -1,    -1,
      -1,   140,   141,   142,   143,    -1,    -1,    -1,   147,   148,
     149,    -1,   151,   152,    -1,   154,   155,    -1,   157,    -1,
      -1,   160,   161,    -1,    -1,   164,   165,    -1,    -1,    -1,
      -1,    -1,   171,   172,   173,   174,   175,   176,    -1,    -1,
     179,    -1,    -1,    -1,   183,   184,   185,   186,    -1,    -1,
      -1,   190,   191,   192,   193,   194,   195,   196,   197,   198,
     199,   200,    -1,   202,   203,   204,     6,    -1,     8,     9,
      -1,    -1,    -1,    -1,    -1,    15,    -1,    17,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    26,    -1,    -1,    -1,
      -1,    31,    32,    -1,    -1,    -1,    -1,    37,    38,    39,
      40,    41,    42,    43,    -1,    -1,    -1,    -1,    48,    49,
      -1,    -1,    -1,    -1,    -1,    -1,    56,    -1,    -1,    59,
      -1,    -1,    -1,    -1,    64,    65,    66,    67,    -1,    -1,
      -1,    71,    72,    -1,    -1,    -1,    -1,    -1,    78,    79,
      -1,    -1,    -1,    -1,    -1,    85,    -1,    87,    -1,    89,
      -1,    -1,    -1,    93,    -1,    -1,    -1,    97,    -1,    99,
     100,    -1,   102,    -1,    -1,    -1,   106,   107,   108,   109,
     110,   111,    -1,   113,    -1,   115,    -1,   117,   118,   119,
     120,    -1,    -1,   123,    -1,    -1,   126,    -1,   128,   129,
      -1,    -1,    -1,   133,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   141,   142,   143,    -1,    -1,    -1,   147,   148,   149,
      -1,   151,   152,    -1,   154,   155,    -1,   157,    -1,    -1,
     160,   161,    -1,    -1,   164,   165,    -1,    -1,    -1,    -1,
      -1,   171,   172,    -1,   174,   175,   176,    -1,    -1,   179,
      -1,    -1,    -1,   183,   184,   185,   186,    -1,    -1,    -1,
     190,   191,   192,    -1,   194,   195,   196,   197,   198,   199,
      -1,    -1,   202,   203,   204,     6,    -1,     8,     9,    -1,
      -1,    -1,    -1,    -1,    15,    -1,    17,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      31,    32,    -1,    -1,    -1,    -1,    37,    38,    39,    40,
      41,    42,    43,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    56,    57,    58,    59,    -1,
      -1,    -1,    -1,    64,    65,    66,    -1,    -1,    -1,    -1,
      71,    72,    -1,    -1,    -1,    -1,    -1,    78,    79,    -1,
      -1,    -1,    -1,    -1,    85,    -1,    -1,    -1,    89,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    97,    -1,    99,   100,
      -1,   102,    -1,   104,    -1,   106,   107,   108,   109,   110,
     111,    -1,   113,    -1,    -1,    -1,    -1,   118,    -1,    -1,
      -1,    -1,   123,    -1,    -1,   126,    -1,   128,   129,    -1,
      -1,    -1,   133,    -1,    -1,    -1,    -1,    -1,    -1,   140,
     141,   142,   143,    -1,    -1,    -1,   147,   148,   149,    -1,
     151,   152,    -1,   154,   155,    -1,   157,    -1,    -1,    -1,
     161,    -1,    -1,   164,   165,    -1,    -1,    -1,    -1,    -1,
     171,   172,   173,    -1,   175,   176,    -1,    -1,   179,     6,
      -1,     8,     9,    -1,   185,   186,    -1,    -1,    15,    -1,
      17,   192,   193,   194,    -1,   196,    -1,   198,   199,   200,
      -1,   202,   203,   204,    31,    32,    -1,    -1,    -1,    -1,
      37,    38,    39,    40,    41,    42,    43,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    56,
      -1,    -1,    59,    -1,    -1,    -1,    -1,    64,    65,    66,
      -1,    -1,    -1,    -1,    71,    72,    -1,    -1,    -1,    -1,
      -1,    78,    79,    -1,    -1,    -1,    -1,    -1,    85,    -1,
      -1,    -1,    89,    90,    -1,    -1,    -1,    -1,    -1,    -1,
      97,    -1,    99,   100,    -1,   102,    -1,    -1,    -1,   106,
     107,   108,   109,   110,   111,    -1,   113,    -1,    -1,    -1,
      -1,   118,    -1,    -1,    -1,    -1,   123,    -1,    -1,   126,
      -1,   128,   129,    -1,    -1,    -1,   133,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   141,   142,   143,    -1,    -1,    -1,
     147,   148,   149,    -1,   151,   152,    -1,   154,   155,    -1,
     157,    -1,    -1,    -1,   161,    -1,    -1,   164,   165,    -1,
      -1,    -1,    -1,    -1,   171,   172,    -1,    -1,   175,   176,
     177,    -1,   179,     6,    -1,     8,     9,    10,   185,   186,
      -1,    14,    15,    -1,    17,    -1,    -1,   194,    -1,   196,
      -1,   198,   199,    -1,    -1,   202,   203,   204,    31,    32,
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
      -1,    -1,   175,   176,    -1,    -1,   179,     6,    -1,     8,
       9,    10,   185,   186,    -1,    -1,    15,    -1,    17,    -1,
      -1,   194,    -1,   196,    -1,   198,   199,    -1,    -1,   202,
     203,   204,    31,    32,    -1,    -1,    -1,    -1,    37,    38,
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
      -1,    -1,   171,   172,    -1,    -1,   175,   176,    -1,    -1,
     179,     6,    -1,     8,     9,    -1,   185,   186,    -1,    14,
      15,    -1,    17,    -1,    -1,   194,    -1,   196,    -1,   198,
     199,    -1,    -1,   202,   203,   204,    31,    32,    -1,    -1,
      -1,    -1,    37,    38,    39,    40,    41,    42,    43,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
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
     175,   176,    -1,    -1,   179,     6,    -1,     8,     9,    -1,
     185,   186,    -1,    -1,    15,    -1,    17,    -1,    -1,   194,
      -1,   196,    -1,   198,   199,    -1,    -1,   202,   203,   204,
      31,    32,    -1,    -1,    -1,    -1,    37,    38,    39,    40,
      41,    42,    43,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    56,    -1,    -1,    59,    -1,
      -1,    -1,    -1,    64,    65,    66,    -1,    -1,    -1,    -1,
      71,    72,    -1,    -1,    -1,    -1,    -1,    78,    79,    -1,
      -1,    -1,    -1,    -1,    85,    -1,    -1,    -1,    89,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    97,    -1,    99,   100,
      -1,   102,    -1,    -1,    -1,   106,   107,   108,   109,   110,
     111,    -1,   113,    -1,    -1,    -1,    -1,   118,    -1,    -1,
      -1,    -1,   123,    -1,    -1,   126,    -1,   128,   129,    -1,
      -1,    -1,   133,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     141,   142,   143,    -1,    -1,    -1,   147,   148,   149,    -1,
     151,   152,    -1,   154,   155,    -1,   157,    -1,    -1,    -1,
     161,    -1,    -1,   164,   165,    -1,    -1,    -1,    -1,    -1,
     171,   172,    -1,    -1,   175,   176,    -1,    -1,   179,    -1,
      -1,    -1,    -1,     6,   185,   186,    -1,    10,    11,    -1,
      -1,    -1,    15,   194,    17,   196,    -1,   198,   199,    -1,
      -1,   202,   203,   204,    -1,    -1,    -1,    -1,    31,    32,
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
      -1,    -1,   175,   176,    -1,    -1,   179,     6,    -1,    -1,
      -1,    -1,   185,   186,    -1,    -1,    15,    -1,    17,    -1,
      -1,   194,    -1,   196,    -1,   198,   199,    -1,    -1,   202,
     203,   204,    31,    32,    -1,    -1,    -1,    -1,    37,    38,
      39,    40,    41,    42,    43,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    56,    -1,    -1,
      59,    -1,    -1,    -1,    -1,    64,    65,    66,    -1,    -1,
      -1,    -1,    71,    72,    -1,    -1,    -1,    -1,    -1,    78,
      79,    -1,    -1,    -1,    -1,    -1,    85,    -1,    -1,    -1,
      89,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    97,    -1,
      99,   100,    -1,   102,    -1,    -1,    -1,   106,   107,   108,
     109,   110,   111,    -1,   113,    -1,    -1,    -1,    -1,   118,
      -1,    -1,    -1,    -1,   123,    -1,    -1,   126,     6,   128,
     129,    -1,    -1,    -1,   133,    -1,    -1,    15,    -1,    17,
      -1,    -1,   141,   142,   143,    -1,    -1,    -1,   147,   148,
     149,    -1,   151,   152,    -1,   154,   155,    -1,   157,    -1,
      -1,    -1,   161,    -1,    -1,   164,   165,    -1,    -1,    -1,
      48,    49,   171,   172,     6,    -1,   175,   176,    -1,    -1,
     179,    -1,    -1,    15,    -1,    17,   185,   186,    -1,    67,
      -1,    -1,    -1,    -1,    -1,   194,    15,   196,    17,   198,
     199,    -1,    -1,   202,   203,   204,    -1,    -1,    -1,    87,
      -1,    -1,    -1,    -1,    -1,    93,    48,    49,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    48,
      -1,    -1,    -1,    -1,    -1,    67,    -1,    -1,    57,   117,
      59,   119,   120,    -1,    -1,    -1,    -1,    66,    67,    -1,
      -1,    -1,    -1,    -1,    -1,    87,    -1,    -1,    -1,    78,
      79,    93,    -1,    -1,    -1,    -1,    -1,    -1,    87,    -1,
      -1,    -1,    -1,    -1,    93,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   160,    -1,    -1,   117,    -1,   119,   120,    -1,
      -1,    -1,    -1,   112,    -1,    -1,   174,    -1,   117,    -1,
     119,   120,    -1,    -1,   123,   183,   184,    -1,    -1,   128,
     129,    -1,   190,   191,   192,    -1,   194,   195,   196,   197,
      -1,    -1,    -1,   142,    -1,    -1,    -1,    -1,   160,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   160,   174,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   183,   184,    -1,    -1,   174,    -1,    -1,   190,   191,
     192,    -1,   194,   195,   196,   197,    -1,    -1,    -1,    -1,
      -1,   190,   191,   192,   193,   194,   195,   196,   197,   198,
     199,   200,    -1,   202,   203,   204,    15,    -1,    17,    -1,
      -1,    -1,    21,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    30,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    33,    -1,    35,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    52,    53,    -1,    -1,    47,    -1,    49,
      50,    -1,    -1,    -1,    63,    -1,    -1,    -1,    58,    68,
      -1,    -1,    -1,    63,    73,    -1,    -1,    -1,    -1,    69,
      -1,    -1,    -1,    -1,    74,    84,    -1,    -1,    -1,    88,
      -1,    81,    91,    92,    -1,    94,    -1,    -1,    -1,    98,
      -1,    91,    -1,    -1,    -1,    -1,    -1,    -1,    98,    99,
      -1,   101,    -1,   112,    -1,   105,    -1,   107,    -1,    -1,
     119,   120,    -1,    -1,   114,    -1,    -1,    -1,    -1,    -1,
      -1,   130,   131,    -1,    -1,   125,   135,   136,   137,   138,
      -1,    -1,    -1,    -1,   134,   144,   145,   146,    -1,   139,
      -1,   150,    -1,   143,    -1,    -1,    -1,    -1,    -1,    -1,
     159,   160,    -1,   153,    -1,    15,    -1,    17,   158,   168,
      -1,    21,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   178,
      30,   180,    -1,   182,    -1,    -1,    -1,    -1,    -1,   179,
      -1,   190,   191,   192,   193,   194,   195,   196,   197,   198,
     199,    -1,    52,    53,   194,    -1,    -1,    -1,    -1,    -1,
      60,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    68,    -1,
      -1,    -1,    -1,    73,    -1,    -1,    -1,    77,    -1,    -1,
      -1,    -1,    -1,    -1,    84,    -1,    -1,    -1,    88,    -1,
      -1,    91,    92,    -1,    94,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    59,    -1,    -1,    -1,    -1,    -1,    -1,
      66,    -1,   112,    -1,    -1,    -1,    -1,    -1,    -1,   119,
     120,    -1,    78,    79,    -1,    -1,    -1,    -1,    -1,    -1,
     130,   131,    -1,    -1,    -1,   135,   136,   137,   138,    -1,
      -1,    -1,    -1,    -1,   144,   145,   146,    15,    -1,    17,
     150,    -1,    -1,    21,    -1,    -1,    -1,    -1,    -1,   159,
     160,    -1,    30,    -1,    -1,    -1,    -1,   123,   168,    -1,
      -1,    -1,   128,   129,    -1,    -1,    -1,    -1,   178,    -1,
     180,    -1,   182,    -1,    52,    53,   142,    -1,    -1,    -1,
     190,   191,   192,   193,   194,   195,   196,   197,   198,   199,
      -1,    -1,    -1,    -1,    -1,    73,    -1,    -1,    76,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    84,    -1,    -1,    -1,
      88,    -1,    -1,    91,    92,    -1,    94,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   190,   191,   192,   193,   194,   195,
     196,   197,   198,   199,   112,    -1,    -1,    -1,    -1,    -1,
      -1,   119,   120,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   130,   131,    -1,    -1,    -1,   135,    -1,   137,
     138,    -1,    -1,    -1,    -1,    -1,   144,   145,   146,    15,
      -1,    17,   150,    -1,    -1,    21,    -1,    -1,    -1,    -1,
      -1,    -1,   160,    -1,    30,    -1,    -1,    -1,    -1,   167,
     168,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     178,    -1,   180,    -1,   182,    -1,    52,    53,    -1,    -1,
      -1,    -1,   190,   191,   192,   193,   194,   195,   196,   197,
     198,   199,    -1,    -1,    -1,    -1,    -1,    73,    -1,    -1,
      76,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    84,    -1,
      86,    -1,    88,    -1,    -1,    -1,    92,    -1,    94,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   112,    -1,    -1,    -1,
      -1,    -1,    -1,   119,   120,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   130,   131,    -1,    -1,    -1,   135,
      -1,   137,   138,    -1,    -1,    -1,    -1,    -1,   144,   145,
     146,    -1,    -1,    -1,   150,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   160,    -1,    -1,    -1,    -1,    -1,
     166,    -1,   168,    15,    -1,    17,    -1,    -1,    -1,    21,
      -1,    -1,   178,    -1,   180,    -1,   182,    -1,    30,    -1,
      -1,    -1,    -1,    -1,   190,   191,   192,   193,   194,   195,
     196,   197,   198,   199,    -1,    -1,    -1,    -1,    -1,    -1,
      52,    53,    -1,    -1,    -1,    -1,    -1,    -1,    60,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    73,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    84,    -1,    86,    -1,    88,    -1,    -1,    -1,
      92,    -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     112,    -1,    -1,    -1,    -1,    -1,    -1,   119,   120,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   130,   131,
      -1,    -1,    -1,   135,    -1,   137,   138,    -1,    -1,    -1,
      -1,    -1,   144,   145,   146,    15,    -1,    17,   150,    -1,
      -1,    21,    -1,    -1,    -1,    -1,    -1,    -1,   160,    -1,
      30,    -1,    -1,    -1,   166,    -1,   168,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   178,    -1,   180,    -1,
     182,    -1,    52,    53,    -1,    -1,    -1,    -1,   190,   191,
     192,   193,   194,   195,   196,   197,   198,   199,    -1,    -1,
      -1,    -1,    -1,    73,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    84,    -1,    86,    -1,    88,    -1,
      -1,    -1,    92,    -1,    94,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   112,    -1,    -1,    -1,    -1,    -1,    -1,   119,
     120,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     130,   131,    -1,    -1,    -1,   135,    -1,   137,   138,    -1,
      -1,    -1,    -1,    -1,   144,   145,   146,    -1,    -1,    -1,
     150,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     160,    -1,    -1,    -1,    -1,    -1,   166,    -1,   168,    15,
      -1,    17,    -1,    -1,    -1,    21,    -1,    -1,   178,    -1,
     180,    -1,   182,    -1,    30,    -1,    -1,    -1,    -1,    -1,
     190,   191,   192,   193,   194,   195,   196,   197,   198,   199,
      -1,    -1,    -1,    -1,    -1,    -1,    52,    53,    -1,    -1,
      -1,    -1,    -1,    -1,    60,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    73,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    84,    -1,
      -1,    -1,    88,    -1,    -1,    91,    92,    -1,    94,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   112,    -1,    -1,    -1,
      -1,    -1,    -1,   119,   120,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   130,   131,    -1,    -1,    -1,   135,
      -1,   137,   138,    -1,    -1,    -1,    -1,    -1,   144,   145,
     146,    15,    -1,    17,   150,    -1,    -1,    21,    -1,    -1,
      -1,    -1,    -1,    -1,   160,    -1,    30,    -1,    -1,    -1,
      -1,    -1,   168,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   178,    -1,   180,    -1,   182,    -1,    52,    53,
      -1,    -1,    -1,    -1,   190,   191,   192,   193,   194,   195,
     196,   197,   198,   199,    -1,    -1,    -1,    -1,    -1,    73,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      84,    -1,    -1,    -1,    88,    -1,    -1,    91,    92,    -1,
      94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   112,    -1,
      -1,    -1,    -1,    -1,    -1,   119,   120,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   130,   131,    -1,    -1,
      -1,   135,    -1,   137,   138,    -1,    -1,    -1,    -1,    -1,
     144,   145,   146,    15,    -1,    17,   150,    -1,    -1,    21,
      -1,    -1,    -1,    -1,    -1,    -1,   160,    -1,    30,    -1,
      -1,    -1,    -1,    -1,   168,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   178,    -1,   180,    -1,   182,    -1,
      52,    53,    -1,    -1,    -1,    -1,   190,   191,   192,   193,
     194,   195,   196,   197,   198,   199,    -1,    -1,    -1,    -1,
      -1,    73,    -1,    -1,    76,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    84,    -1,    -1,    -1,    88,    -1,    -1,    -1,
      92,    -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     112,    -1,    -1,    -1,    -1,    -1,    -1,   119,   120,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   130,   131,
      -1,    -1,    -1,   135,    -1,   137,   138,    -1,    -1,    -1,
      -1,    -1,   144,   145,   146,    -1,    -1,    -1,   150,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   160,    -1,
      -1,    -1,    15,    -1,    17,    -1,   168,    -1,    21,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   178,    30,   180,    -1,
     182,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   190,   191,
     192,   193,   194,   195,   196,   197,   198,   199,    -1,    52,
      53,    -1,    -1,    -1,    -1,    -1,    -1,    60,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      73,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    84,    -1,    -1,    -1,    88,    -1,    -1,    -1,    92,
      -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   112,
      -1,    -1,    -1,    -1,    -1,    -1,   119,   120,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   130,   131,    -1,
      -1,    -1,   135,    -1,   137,   138,    -1,    -1,    -1,    -1,
      -1,   144,   145,   146,    15,    -1,    17,   150,    -1,    -1,
      21,    -1,    -1,    -1,    -1,    -1,    -1,   160,    -1,    30,
      -1,    -1,    -1,    -1,    -1,   168,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   178,    -1,   180,    -1,   182,
      -1,    52,    53,    -1,    -1,    -1,    -1,   190,   191,   192,
     193,   194,   195,   196,   197,   198,   199,    -1,    -1,    -1,
      -1,    -1,    73,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    84,    -1,    -1,    -1,    88,    -1,    -1,
      -1,    92,    -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   112,    -1,    -1,    -1,    -1,    -1,    -1,   119,   120,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   130,
     131,    -1,    -1,    -1,   135,    -1,   137,   138,    -1,    -1,
      -1,    -1,    -1,   144,   145,   146,    -1,    -1,    -1,   150,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   160,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   168,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   178,    -1,   180,
      -1,   182,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   190,
     191,   192,   193,   194,   195,   196,   197,   198,   199,    33,
      -1,    35,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      44,    -1,    -1,    47,    -1,    49,    50,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    58,    -1,    -1,    -1,    -1,    63,
      -1,    -1,    -1,    -1,    -1,    69,    -1,    -1,    -1,    -1,
      74,    -1,    -1,    -1,    -1,    -1,    -1,    81,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    91,    -1,    -1,
      -1,    -1,    -1,    -1,    98,    99,    -1,   101,    -1,    -1,
      -1,   105,    33,   107,    35,    -1,    -1,    -1,    -1,    -1,
     114,    -1,    -1,    44,    -1,    -1,    47,    -1,    49,    50,
      -1,   125,    -1,   127,    -1,    -1,    -1,    58,    -1,    -1,
     134,    -1,    63,    -1,    -1,   139,    -1,    -1,    69,   143,
      -1,    -1,    -1,    74,    -1,    -1,    -1,    -1,    -1,   153,
      81,    -1,    -1,    -1,   158,    -1,    -1,    -1,    -1,    -1,
      91,    -1,   166,    -1,    -1,    -1,    -1,    98,    99,    -1,
     101,    -1,    -1,    -1,   105,   179,   107,    -1,    -1,    -1,
      -1,    -1,    -1,   114,    -1,    -1,   190,   191,   192,   193,
     194,   195,   196,   197,   125,   199,   127,    -1,    -1,    -1,
      -1,    -1,    -1,   134,    -1,    -1,    -1,    -1,   139,    -1,
      -1,    -1,   143,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   153,    -1,    -1,    -1,    -1,   158,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   166,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   179,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   194
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int16 yystos[] =
{
       0,    15,    17,    21,    30,    52,    53,    63,    68,    73,
      84,    88,    91,    92,    94,    98,   112,   119,   120,   130,
     131,   135,   136,   137,   138,   144,   145,   146,   150,   159,
     160,   168,   178,   180,   182,   190,   191,   192,   193,   194,
     195,   196,   197,   198,   199,   211,   225,   236,   258,   260,
     265,   266,   268,   269,   271,   277,   280,   282,   284,   285,
     286,   287,   288,   289,   290,   291,   293,   294,   295,   296,
     297,   298,   299,   305,   306,   307,   308,   309,   312,   314,
     315,   316,   317,   320,   321,   323,   324,   326,   327,   332,
     333,   334,   336,   348,   362,   363,   364,   365,   366,   367,
     370,   371,   379,   382,   385,   388,   389,   390,   391,   392,
     393,   394,   395,   236,   289,   211,   195,   259,   269,   289,
       6,    33,    35,    44,    47,    49,    50,    58,    69,    74,
      81,    91,    99,   101,   105,   107,   114,   125,   127,   134,
     139,   143,   153,   158,   166,   179,   191,   192,   194,   195,
     196,   197,   206,   207,   208,   209,   210,   211,   212,   213,
     214,   215,   216,   242,   268,   280,   290,   345,   346,   347,
     348,   352,   354,   355,   356,   357,   359,   361,    21,    54,
      90,   177,   181,   337,   338,   339,   342,    21,   269,     6,
      21,   355,   356,   357,   361,   170,     6,    80,    80,     6,
       6,    21,   269,   211,   383,   260,   289,     6,     8,     9,
      15,    17,    21,    26,    31,    32,    37,    38,    39,    40,
      41,    42,    43,    48,    49,    56,    57,    58,    59,    64,
      65,    66,    67,    71,    72,    78,    79,    85,    87,    89,
      91,    93,    97,    99,   100,   102,   104,   106,   107,   108,
     109,   110,   111,   113,   115,   116,   117,   118,   119,   120,
     123,   126,   128,   129,   133,   140,   141,   142,   143,   147,
     148,   149,   151,   152,   154,   155,   157,   161,   164,   165,
     171,   172,   173,   174,   175,   176,   179,   183,   184,   185,
     186,   191,   192,   196,   200,   202,   203,   204,   217,   218,
     219,   220,   221,   222,   224,   225,   226,   227,   228,   229,
     230,   231,   232,   235,   237,   238,   249,   250,   251,   255,
     257,   258,   259,   260,   261,   262,   263,   264,   265,   267,
     270,   274,   275,   276,   277,   278,   279,   281,   282,   285,
     287,   289,   259,    80,   260,   260,   290,   386,   124,     6,
      19,   239,   240,   243,   244,   284,   287,   289,     6,   239,
     239,    22,   239,   239,     6,     4,    28,   292,     6,     4,
      11,   239,   292,    21,   178,   293,   294,   308,   293,     6,
     217,   249,   251,   257,   274,   281,   285,   301,   302,   303,
     304,   293,    21,    36,    86,   166,   178,   294,   295,     6,
      21,    45,   310,    76,   167,   305,   308,   313,   343,    21,
      61,   103,   122,   156,   163,   284,   318,   322,    21,   194,
     235,   319,   322,     4,    21,     4,    21,   292,     4,     6,
      90,   177,   196,   217,   289,    21,   259,   325,    46,    96,
     120,   124,     4,    21,    70,   328,   329,   330,   331,   337,
      21,     6,    21,   227,   229,   231,   259,   262,   278,   283,
     284,   335,   344,   293,   217,   235,   349,   350,   351,     0,
     305,   379,   382,   385,    60,    77,   305,   308,   368,   369,
     374,   375,   379,   382,   385,    21,    33,   139,    83,   132,
      62,    91,   125,   127,     6,   354,   372,   377,   378,   310,
     373,   377,   380,    21,   368,   369,   368,   369,   368,   369,
     368,   369,    16,    11,    18,   239,    11,     6,     6,     6,
       6,     6,     6,     6,    91,   125,   210,    81,   346,    21,
       4,   210,   112,   242,    10,   217,   353,     4,   207,   353,
     347,    10,   235,   349,   194,   208,   346,     9,   358,   360,
     217,   167,   225,   289,   249,   301,    21,    21,   338,   217,
     340,    21,   227,    21,    21,    21,    21,   269,    21,   239,
      95,   162,   239,   227,   227,    21,     6,    51,    11,   217,
     249,   274,   289,   258,   289,   258,   289,    27,   239,   272,
     273,     6,   272,     6,   239,     6,   239,     6,   239,     6,
     239,     6,     6,     6,     6,    25,    55,   219,   220,   256,
     218,   218,     7,    10,    11,   221,    12,    13,   223,    19,
     240,     4,     5,    21,   239,     6,    23,   121,   252,   253,
      24,    36,   254,   256,     6,    15,    17,   255,   289,   264,
       6,   235,     6,   256,     6,     6,    11,    21,   239,    22,
     346,   208,   387,   170,   259,   227,     6,   225,   227,    10,
      14,   217,   245,   246,   247,   248,     4,     5,    21,    22,
       5,     6,   283,   284,   291,   235,   320,   217,   233,   234,
     235,   289,   291,   236,   268,   271,   280,   290,   235,    75,
     217,   274,   301,    27,    29,   187,   188,   189,   292,   169,
     300,    27,    29,   187,   188,   189,   292,     6,    27,    29,
     187,   188,   189,   292,    27,    29,   187,   188,   189,   292,
      27,    29,   187,   188,   189,   292,   252,   300,   254,   332,
     233,     6,   269,   206,   308,   313,    21,     6,     6,     6,
       6,     6,   318,   319,   235,   289,   217,   217,    70,   249,
     217,    21,    11,     4,    21,   217,   217,   249,     6,   135,
      21,   331,    34,    82,     6,   217,   249,   289,     4,     5,
      14,     5,     4,     6,   284,   344,   349,    21,   269,    86,
     308,   368,    21,   305,   368,   375,    21,   354,   190,   193,
     194,   196,   197,   199,   376,   377,   380,    21,   368,    21,
     368,    21,   368,    21,   368,   239,   239,   269,   353,   353,
     353,   353,   228,   210,   346,   346,   215,     5,     4,     5,
       5,     5,   159,   353,    21,   211,   292,    11,    21,   170,
     341,     4,    21,    21,    95,   162,     5,     5,   211,   384,
     201,   381,     5,     5,     5,    16,    11,    18,    19,   227,
     349,     6,   349,     6,   349,     6,   349,     6,   233,   233,
     233,   233,   218,   218,     6,   192,   217,   275,   289,   218,
     221,   221,   222,     6,    10,   349,   233,   250,   251,   255,
     257,    11,   227,     5,   233,   217,   275,   233,   116,   283,
     237,    21,   228,    22,     4,    21,   217,   170,     5,    20,
     241,    46,   217,   247,   170,   219,   220,     5,   292,    21,
      14,     4,     5,   239,   239,   239,   239,     5,   217,   217,
     217,   217,   217,   217,   251,   251,   251,   251,   251,   251,
     301,   217,   274,   274,   274,   274,   274,   274,   281,   281,
     281,   281,   281,   281,   195,   285,   289,   285,   285,   285,
     285,   285,   251,   302,   303,    21,     5,   284,   289,   311,
      21,   217,   217,   217,   217,   217,    21,    21,     5,    21,
      21,    21,   259,   217,   217,   217,    11,    21,     4,     5,
     211,    21,     4,     5,    21,    21,    21,    21,   239,     5,
       5,     5,     4,     5,     6,     5,    75,    28,   217,   217,
       4,     5,   239,   239,     6,     5,   349,   349,   349,   349,
       5,     5,     5,     5,    11,    20,     5,     5,   255,     5,
       5,     5,     5,     5,   239,   228,   228,    21,   217,    20,
     242,   263,   217,   247,   218,   218,   235,   234,     5,    21,
     310,     4,     5,     5,     5,     5,     5,     5,     5,   170,
      51,   211,    20,   264,   242,    21,     4,     5,     5,     5,
       6,   284,   289,    21,   284,   217,   263,     4,    20,   241,
     311,    21,     5,   217,     5,     5,    21
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int16 yyr1[] =
{
       0,   205,   206,   206,   207,   207,   207,   208,   208,   208,
     208,   208,   208,   208,   208,   208,   208,   208,   208,   209,
     209,   209,   209,   209,   210,   210,   210,   211,   212,   212,
     213,   213,   214,   214,   214,   214,   215,   215,   216,   216,
     216,   216,   216,   216,   216,   216,   217,   217,   217,   217,
     217,   218,   218,   219,   220,   221,   221,   221,   221,   222,
     222,   222,   223,   224,   224,   224,   224,   225,   225,   225,
     225,   225,   225,   225,   225,   226,   226,   226,   226,   226,
     226,   226,   226,   226,   227,   227,   228,   229,   230,   231,
     231,   231,   231,   232,   232,   232,   232,   232,   232,   232,
     232,   232,   233,   233,   234,   234,   234,   235,   235,   235,
     235,   235,   236,   236,   237,   237,   237,   237,   237,   237,
     237,   237,   238,   238,   238,   238,   238,   238,   238,   238,
     238,   238,   238,   238,   238,   238,   238,   238,   238,   238,
     238,   238,   238,   238,   238,   238,   238,   238,   238,   238,
     238,   238,   238,   238,   238,   238,   238,   238,   238,   238,
     238,   238,   238,   238,   238,   238,   239,   239,   239,   239,
     240,   240,   240,   240,   241,   241,   242,   242,   243,   243,
     243,   243,   243,   244,   244,   245,   245,   245,   245,   246,
     247,   247,   248,   248,   248,   249,   249,   250,   250,   251,
     251,   251,   251,   252,   252,   253,   254,   254,   255,   255,
     255,   255,   255,   255,   255,   255,   255,   255,   255,   255,
     256,   256,   257,   257,   258,   258,   258,   258,   259,   259,
     259,   259,   260,   260,   260,   260,   261,   261,   262,   262,
     262,   262,   262,   263,   263,   263,   263,   264,   265,   265,
     266,   267,   267,   267,   268,   269,   269,   269,   269,   270,
     270,   271,   272,   272,   273,   274,   274,   274,   274,   274,
     275,   275,   275,   275,   276,   276,   277,   277,   277,   277,
     278,   278,   279,   279,   279,   279,   279,   280,   281,   281,
     281,   282,   283,   283,   283,   284,   284,   284,   284,   284,
     284,   284,   285,   285,   285,   285,   286,   287,   288,   289,
     289,   290,   291,   291,   291,   291,   292,   293,   293,   293,
     294,   294,   294,   294,   294,   294,   294,   294,   294,   294,
     294,   294,   294,   294,   294,   294,   294,   294,   294,   294,
     294,   294,   294,   294,   294,   294,   294,   294,   294,   294,
     294,   294,   294,   294,   294,   294,   294,   294,   294,   294,
     294,   295,   295,   295,   296,   296,   297,   297,   298,   299,
     300,   301,   301,   302,   302,   303,   303,   303,   304,   304,
     304,   304,   304,   304,   304,   304,   304,   304,   304,   304,
     304,   304,   304,   304,   304,   304,   304,   304,   304,   304,
     304,   304,   304,   304,   304,   304,   304,   304,   305,   305,
     306,   306,   307,   307,   307,   307,   308,   309,   310,   311,
     311,   311,   311,   312,   312,   312,   312,   312,   312,   312,
     312,   313,   313,   313,   314,   314,   315,   316,   316,   317,
     317,   318,   318,   319,   319,   319,   320,   321,   322,   322,
     322,   322,   322,   323,   324,   324,   325,   325,   326,   326,
     326,   326,   327,   327,   327,   328,   328,   328,   329,   329,
     329,   330,   331,   331,   332,   332,   332,   333,   334,   334,
     335,   335,   336,   337,   337,   338,   338,   339,   339,   340,
     340,   341,   341,   342,   342,   343,   344,   344,   344,   344,
     345,   345,   346,   346,   347,   347,   347,   347,   347,   347,
     347,   347,   347,   347,   347,   347,   348,   348,   348,   349,
     349,   349,   349,   349,   350,   351,   351,   352,   353,   353,
     354,   354,   354,   354,   354,   355,   355,   356,   357,   358,
     358,   359,   360,   361,   361,   361,   362,   362,   362,   362,
     362,   362,   362,   362,   362,   363,   363,   364,   365,   365,
     365,   365,   365,   366,   366,   366,   366,   366,   366,   366,
     366,   366,   367,   367,   368,   368,   368,   369,   369,   369,
     370,   371,   372,   372,   372,   373,   373,   373,   374,   374,
     375,   375,   375,   375,   376,   376,   376,   376,   376,   376,
     377,   378,   378,   379,   380,   381,   382,   383,   383,   384,
     384,   385,   386,   386,   386,   387,   388,   388,   388,   388,
     389,   389,   390,   390,   391,   391,   392,   393,   393,   394,
     395
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
       4,     2,     4,     4,     1,     1,     1,     1,     1,     1,
       2,     3,     4,     3,     3,     3,     3,     4,     4,     4,
       4,     3,     1,     3,     1,     3,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     2,     1,     2,     2,
       5,     5,     8,     5,     1,     2,     1,     1,     2,     5,
       2,     2,     2,     1,     2,     1,     1,     2,     3,     2,
       1,     1,     1,     3,     3,     1,     3,     1,     3,     1,
       3,     2,     4,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     3,     3,     4,     4,     3,     4,     3,     4,
       1,     1,     1,     1,     1,     2,     3,     4,     1,     2,
       3,     4,     1,     2,     3,     4,     1,     4,     2,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     2,     3,
       1,     1,     1,     2,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     6,     1,     3,     3,     3,     3,
       1,     1,     4,     3,     1,     2,     1,     2,     3,     4,
       1,     5,     1,     1,     1,     1,     1,     1,     4,     1,
       4,     1,     1,     1,     1,     1,     1,     3,     1,     4,
       1,     1,     1,     4,     3,     4,     1,     2,     1,     1,
       3,     1,     3,     3,     3,     3,     1,     1,     1,     1,
       2,     2,     2,     3,     2,     3,     4,     1,     2,     5,
       6,     9,     2,     3,     3,     2,     2,     2,     2,     4,
       4,     4,     4,     3,     4,     4,     2,     3,     5,     6,
       2,     3,     2,     4,     3,     2,     4,     4,     3,     2,
       4,     1,     2,     2,     2,     2,     3,     3,     3,     1,
       1,     1,     3,     1,     3,     3,     4,     1,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     1,     1,
       3,     2,     4,     4,     3,     3,     2,     2,     1,     1,
       3,     1,     3,     2,     3,     4,     3,     4,     2,     2,
       2,     1,     2,     2,     4,     4,     4,     2,     3,     2,
       3,     1,     1,     1,     1,     1,     4,     3,     4,     4,
       4,     4,     4,     1,     1,     1,     1,     3,     2,     3,
       3,     3,     1,     5,     2,     1,     1,     2,     3,     3,
       1,     2,     2,     2,     2,     2,     2,     2,     2,     3,
       1,     1,     5,     1,     1,     2,     2,     3,     2,     1,
       3,     2,     4,     3,     4,     3,     1,     1,     1,     1,
       2,     3,     1,     2,     1,     1,     1,     1,     1,     4,
       1,     1,     3,     3,     1,     4,     2,     2,     3,     1,
       2,     2,     3,     1,     2,     2,     3,     2,     1,     1,
       1,     1,     1,     1,     1,     1,     4,     4,     2,     2,
       3,     1,     3,     1,     1,     2,     1,     2,     1,     2,
       1,     2,     2,     3,     3,     3,     4,     2,     2,     2,
       1,     2,     2,     2,     2,     2,     2,     1,     1,     2,
       1,     2,     1,     2,     1,     2,     2,     1,     1,     2,
       2,     2,     1,     1,     2,     1,     1,     2,     1,     2,
       1,     2,     1,     6,     1,     1,     1,     1,     1,     1,
       3,     1,     3,     3,     2,     1,     4,     1,     4,     1,
       3,     3,     3,     4,     4,     2,     1,     1,     1,     1,
       3,     4,     3,     2,     3,     4,     3,     3,     4,     3,
       3
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
#line 4358 "Parser.c"
    break;

  case 3: /* DECLARE_BODY: ATTRIBUTES _SYMB_0 DECLARATION_LIST  */
#line 649 "HAL_S.y"
                                        { (yyval.declare_body_) = make_ABdeclareBody_attributes_declarationList((yyvsp[-2].attributes_), (yyvsp[0].declaration_list_)); (yyval.declare_body_)->line_number = (yyloc).first_line; (yyval.declare_body_)->char_number = (yyloc).first_column;  }
#line 4364 "Parser.c"
    break;

  case 4: /* ATTRIBUTES: ARRAY_SPEC TYPE_AND_MINOR_ATTR  */
#line 651 "HAL_S.y"
                                            { (yyval.attributes_) = make_AAattributes_arraySpec_typeAndMinorAttr((yyvsp[-1].array_spec_), (yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4370 "Parser.c"
    break;

  case 5: /* ATTRIBUTES: ARRAY_SPEC  */
#line 652 "HAL_S.y"
               { (yyval.attributes_) = make_ABattributes_arraySpec((yyvsp[0].array_spec_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4376 "Parser.c"
    break;

  case 6: /* ATTRIBUTES: TYPE_AND_MINOR_ATTR  */
#line 653 "HAL_S.y"
                        { (yyval.attributes_) = make_ACattributes_typeAndMinorAttr((yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4382 "Parser.c"
    break;

  case 7: /* DECLARATION: NAME_ID  */
#line 655 "HAL_S.y"
                      { (yyval.declaration_) = make_AAdeclaration_nameId((yyvsp[0].name_id_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4388 "Parser.c"
    break;

  case 8: /* DECLARATION: NAME_ID ATTRIBUTES  */
#line 656 "HAL_S.y"
                       { (yyval.declaration_) = make_ABdeclaration_nameId_attributes((yyvsp[-1].name_id_), (yyvsp[0].attributes_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4394 "Parser.c"
    break;

  case 9: /* DECLARATION: _SYMB_192  */
#line 657 "HAL_S.y"
              { (yyval.declaration_) = make_ACdeclaration_labelToken((yyvsp[0].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4400 "Parser.c"
    break;

  case 10: /* DECLARATION: _SYMB_192 TYPE_AND_MINOR_ATTR  */
#line 658 "HAL_S.y"
                                  { (yyval.declaration_) = make_ACdeclaration_labelToken_type_minorAttrList((yyvsp[-1].string_), (yyvsp[0].type_and_minor_attr_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4406 "Parser.c"
    break;

  case 11: /* DECLARATION: _SYMB_192 _SYMB_121 MINOR_ATTR_LIST  */
#line 659 "HAL_S.y"
                                        { (yyval.declaration_) = make_ACdeclaration_labelToken_procedure_minorAttrList((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4412 "Parser.c"
    break;

  case 12: /* DECLARATION: _SYMB_192 _SYMB_121  */
#line 660 "HAL_S.y"
                        { (yyval.declaration_) = make_ADdeclaration_labelToken_procedure((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4418 "Parser.c"
    break;

  case 13: /* DECLARATION: _SYMB_192 _SYMB_87 TYPE_AND_MINOR_ATTR  */
#line 661 "HAL_S.y"
                                           { (yyval.declaration_) = make_ACdeclaration_labelToken_function_minorAttrList((yyvsp[-2].string_), (yyvsp[0].type_and_minor_attr_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4424 "Parser.c"
    break;

  case 14: /* DECLARATION: _SYMB_192 _SYMB_87  */
#line 662 "HAL_S.y"
                       { (yyval.declaration_) = make_ADdeclaration_labelToken_function((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4430 "Parser.c"
    break;

  case 15: /* DECLARATION: _SYMB_193 _SYMB_77  */
#line 663 "HAL_S.y"
                       { (yyval.declaration_) = make_AEdeclaration_eventToken_event((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4436 "Parser.c"
    break;

  case 16: /* DECLARATION: _SYMB_193 _SYMB_77 MINOR_ATTR_LIST  */
#line 664 "HAL_S.y"
                                       { (yyval.declaration_) = make_AFdeclaration_eventToken_event_minorAttrList((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4442 "Parser.c"
    break;

  case 17: /* DECLARATION: _SYMB_193  */
#line 665 "HAL_S.y"
              { (yyval.declaration_) = make_AGdeclaration_eventToken((yyvsp[0].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4448 "Parser.c"
    break;

  case 18: /* DECLARATION: _SYMB_193 MINOR_ATTR_LIST  */
#line 666 "HAL_S.y"
                              { (yyval.declaration_) = make_AHdeclaration_eventToken_minorAttrList((yyvsp[-1].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4454 "Parser.c"
    break;

  case 19: /* ARRAY_SPEC: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 668 "HAL_S.y"
                                                    { (yyval.array_spec_) = make_AAarraySpec_arrayHead_literalExpOrStar((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4460 "Parser.c"
    break;

  case 20: /* ARRAY_SPEC: _SYMB_87  */
#line 669 "HAL_S.y"
             { (yyval.array_spec_) = make_ABarraySpec_function(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4466 "Parser.c"
    break;

  case 21: /* ARRAY_SPEC: _SYMB_121  */
#line 670 "HAL_S.y"
              { (yyval.array_spec_) = make_ACarraySpec_procedure(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4472 "Parser.c"
    break;

  case 22: /* ARRAY_SPEC: _SYMB_123  */
#line 671 "HAL_S.y"
              { (yyval.array_spec_) = make_ADarraySpec_program(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4478 "Parser.c"
    break;

  case 23: /* ARRAY_SPEC: _SYMB_162  */
#line 672 "HAL_S.y"
              { (yyval.array_spec_) = make_AEarraySpec_task(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4484 "Parser.c"
    break;

  case 24: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC  */
#line 674 "HAL_S.y"
                                { (yyval.type_and_minor_attr_) = make_AAtypeAndMinorAttr_typeSpec((yyvsp[0].type_spec_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4490 "Parser.c"
    break;

  case 25: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC MINOR_ATTR_LIST  */
#line 675 "HAL_S.y"
                              { (yyval.type_and_minor_attr_) = make_ABtypeAndMinorAttr_typeSpec_minorAttrList((yyvsp[-1].type_spec_), (yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4496 "Parser.c"
    break;

  case 26: /* TYPE_AND_MINOR_ATTR: MINOR_ATTR_LIST  */
#line 676 "HAL_S.y"
                    { (yyval.type_and_minor_attr_) = make_ACtypeAndMinorAttr_minorAttrList((yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4502 "Parser.c"
    break;

  case 27: /* IDENTIFIER: _SYMB_195  */
#line 678 "HAL_S.y"
                       { (yyval.identifier_) = make_AAidentifier((yyvsp[0].string_)); (yyval.identifier_)->line_number = (yyloc).first_line; (yyval.identifier_)->char_number = (yyloc).first_column;  }
#line 4508 "Parser.c"
    break;

  case 28: /* SQ_DQ_NAME: DOUBLY_QUAL_NAME_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 680 "HAL_S.y"
                                                               { (yyval.sq_dq_name_) = make_AAsQdQName_doublyQualNameHead_literalExpOrStar((yyvsp[-2].doubly_qual_name_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 4514 "Parser.c"
    break;

  case 29: /* SQ_DQ_NAME: ARITH_CONV  */
#line 681 "HAL_S.y"
               { (yyval.sq_dq_name_) = make_ABsQdQName_arithConv((yyvsp[0].arith_conv_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 4520 "Parser.c"
    break;

  case 30: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_175 _SYMB_2  */
#line 683 "HAL_S.y"
                                          { (yyval.doubly_qual_name_head_) = make_AAdoublyQualNameHead_vector(); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 4526 "Parser.c"
    break;

  case 31: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_103 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_0  */
#line 684 "HAL_S.y"
                                                  { (yyval.doubly_qual_name_head_) = make_ABdoublyQualNameHead_matrix_literalExpOrStar((yyvsp[-1].literal_exp_or_star_)); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 4532 "Parser.c"
    break;

  case 32: /* ARITH_CONV: _SYMB_95  */
#line 686 "HAL_S.y"
                      { (yyval.arith_conv_) = make_AAarithConv_integer(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4538 "Parser.c"
    break;

  case 33: /* ARITH_CONV: _SYMB_139  */
#line 687 "HAL_S.y"
              { (yyval.arith_conv_) = make_ABarithConv_scalar(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4544 "Parser.c"
    break;

  case 34: /* ARITH_CONV: _SYMB_175  */
#line 688 "HAL_S.y"
              { (yyval.arith_conv_) = make_ACarithConv_vector(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4550 "Parser.c"
    break;

  case 35: /* ARITH_CONV: _SYMB_103  */
#line 689 "HAL_S.y"
              { (yyval.arith_conv_) = make_ADarithConv_matrix(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4556 "Parser.c"
    break;

  case 36: /* DECLARATION_LIST: DECLARATION  */
#line 691 "HAL_S.y"
                               { (yyval.declaration_list_) = make_AAdeclaration_list((yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 4562 "Parser.c"
    break;

  case 37: /* DECLARATION_LIST: DCL_LIST_COMMA DECLARATION  */
#line 692 "HAL_S.y"
                               { (yyval.declaration_list_) = make_ABdeclaration_list((yyvsp[-1].dcl_list_comma_), (yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 4568 "Parser.c"
    break;

  case 38: /* NAME_ID: IDENTIFIER  */
#line 694 "HAL_S.y"
                     { (yyval.name_id_) = make_AAnameId_identifier((yyvsp[0].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4574 "Parser.c"
    break;

  case 39: /* NAME_ID: IDENTIFIER _SYMB_108  */
#line 695 "HAL_S.y"
                         { (yyval.name_id_) = make_ABnameId_identifier_name((yyvsp[-1].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4580 "Parser.c"
    break;

  case 40: /* NAME_ID: BIT_ID  */
#line 696 "HAL_S.y"
           { (yyval.name_id_) = make_ACnameId_bitId((yyvsp[0].bit_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4586 "Parser.c"
    break;

  case 41: /* NAME_ID: CHAR_ID  */
#line 697 "HAL_S.y"
            { (yyval.name_id_) = make_ADnameId_charId((yyvsp[0].char_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4592 "Parser.c"
    break;

  case 42: /* NAME_ID: _SYMB_187  */
#line 698 "HAL_S.y"
              { (yyval.name_id_) = make_AEnameId_bitFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4598 "Parser.c"
    break;

  case 43: /* NAME_ID: _SYMB_188  */
#line 699 "HAL_S.y"
              { (yyval.name_id_) = make_AFnameId_charFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4604 "Parser.c"
    break;

  case 44: /* NAME_ID: _SYMB_190  */
#line 700 "HAL_S.y"
              { (yyval.name_id_) = make_AGnameId_structIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4610 "Parser.c"
    break;

  case 45: /* NAME_ID: _SYMB_191  */
#line 701 "HAL_S.y"
              { (yyval.name_id_) = make_AHnameId_structFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4616 "Parser.c"
    break;

  case 46: /* ARITH_EXP: TERM  */
#line 703 "HAL_S.y"
                 { (yyval.arith_exp_) = make_AAarithExpTerm((yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4622 "Parser.c"
    break;

  case 47: /* ARITH_EXP: PLUS TERM  */
#line 704 "HAL_S.y"
              { (yyval.arith_exp_) = make_ABarithExpPlusTerm((yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4628 "Parser.c"
    break;

  case 48: /* ARITH_EXP: MINUS TERM  */
#line 705 "HAL_S.y"
               { (yyval.arith_exp_) = make_ACarithMinusTerm((yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4634 "Parser.c"
    break;

  case 49: /* ARITH_EXP: ARITH_EXP PLUS TERM  */
#line 706 "HAL_S.y"
                        { (yyval.arith_exp_) = make_ADarithExpArithExpPlusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4640 "Parser.c"
    break;

  case 50: /* ARITH_EXP: ARITH_EXP MINUS TERM  */
#line 707 "HAL_S.y"
                         { (yyval.arith_exp_) = make_AEarithExpArithExpMinusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4646 "Parser.c"
    break;

  case 51: /* TERM: PRODUCT  */
#line 709 "HAL_S.y"
               { (yyval.term_) = make_AAtermNoDivide((yyvsp[0].product_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4652 "Parser.c"
    break;

  case 52: /* TERM: PRODUCT _SYMB_3 TERM  */
#line 710 "HAL_S.y"
                         { (yyval.term_) = make_ABtermDivide((yyvsp[-2].product_), (yyvsp[0].term_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4658 "Parser.c"
    break;

  case 53: /* PLUS: _SYMB_4  */
#line 712 "HAL_S.y"
               { (yyval.plus_) = make_AAplus(); (yyval.plus_)->line_number = (yyloc).first_line; (yyval.plus_)->char_number = (yyloc).first_column;  }
#line 4664 "Parser.c"
    break;

  case 54: /* MINUS: _SYMB_5  */
#line 714 "HAL_S.y"
                { (yyval.minus_) = make_AAminus(); (yyval.minus_)->line_number = (yyloc).first_line; (yyval.minus_)->char_number = (yyloc).first_column;  }
#line 4670 "Parser.c"
    break;

  case 55: /* PRODUCT: FACTOR  */
#line 716 "HAL_S.y"
                 { (yyval.product_) = make_AAproductSingle((yyvsp[0].factor_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4676 "Parser.c"
    break;

  case 56: /* PRODUCT: FACTOR _SYMB_6 PRODUCT  */
#line 717 "HAL_S.y"
                           { (yyval.product_) = make_ABproductCross((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4682 "Parser.c"
    break;

  case 57: /* PRODUCT: FACTOR _SYMB_7 PRODUCT  */
#line 718 "HAL_S.y"
                           { (yyval.product_) = make_ACproductDot((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4688 "Parser.c"
    break;

  case 58: /* PRODUCT: FACTOR PRODUCT  */
#line 719 "HAL_S.y"
                   { (yyval.product_) = make_ADproductMultiplication((yyvsp[-1].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4694 "Parser.c"
    break;

  case 59: /* FACTOR: PRIMARY  */
#line 721 "HAL_S.y"
                 { (yyval.factor_) = make_AAfactor((yyvsp[0].primary_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4700 "Parser.c"
    break;

  case 60: /* FACTOR: PRIMARY EXPONENTIATION FACTOR  */
#line 722 "HAL_S.y"
                                  { (yyval.factor_) = make_ABfactorExponentiation((yyvsp[-2].primary_), (yyvsp[-1].exponentiation_), (yyvsp[0].factor_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4706 "Parser.c"
    break;

  case 61: /* FACTOR: PRIMARY _SYMB_8  */
#line 723 "HAL_S.y"
                    { (yyval.factor_) = make_ABfactorTranspose((yyvsp[-1].primary_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4712 "Parser.c"
    break;

  case 62: /* EXPONENTIATION: _SYMB_9  */
#line 725 "HAL_S.y"
                         { (yyval.exponentiation_) = make_AAexponentiation(); (yyval.exponentiation_)->line_number = (yyloc).first_line; (yyval.exponentiation_)->char_number = (yyloc).first_column;  }
#line 4718 "Parser.c"
    break;

  case 63: /* PRIMARY: ARITH_VAR  */
#line 727 "HAL_S.y"
                    { (yyval.primary_) = make_AAprimary((yyvsp[0].arith_var_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4724 "Parser.c"
    break;

  case 64: /* PRIMARY: PRE_PRIMARY  */
#line 728 "HAL_S.y"
                { (yyval.primary_) = make_ADprimary((yyvsp[0].pre_primary_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4730 "Parser.c"
    break;

  case 65: /* PRIMARY: MODIFIED_ARITH_FUNC  */
#line 729 "HAL_S.y"
                        { (yyval.primary_) = make_ABprimary((yyvsp[0].modified_arith_func_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4736 "Parser.c"
    break;

  case 66: /* PRIMARY: PRE_PRIMARY QUALIFIER  */
#line 730 "HAL_S.y"
                          { (yyval.primary_) = make_AEprimary((yyvsp[-1].pre_primary_), (yyvsp[0].qualifier_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4742 "Parser.c"
    break;

  case 67: /* ARITH_VAR: ARITH_ID  */
#line 732 "HAL_S.y"
                     { (yyval.arith_var_) = make_AAarith_var((yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4748 "Parser.c"
    break;

  case 68: /* ARITH_VAR: ARITH_ID SUBSCRIPT  */
#line 733 "HAL_S.y"
                       { (yyval.arith_var_) = make_ACarith_var((yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4754 "Parser.c"
    break;

  case 69: /* ARITH_VAR: _SYMB_11 ARITH_ID _SYMB_12  */
#line 734 "HAL_S.y"
                               { (yyval.arith_var_) = make_AAarithVarBracketed((yyvsp[-1].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4760 "Parser.c"
    break;

  case 70: /* ARITH_VAR: _SYMB_11 ARITH_ID _SYMB_12 SUBSCRIPT  */
#line 735 "HAL_S.y"
                                         { (yyval.arith_var_) = make_ABarithVarBracketed((yyvsp[-2].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4766 "Parser.c"
    break;

  case 71: /* ARITH_VAR: _SYMB_13 QUAL_STRUCT _SYMB_14  */
#line 736 "HAL_S.y"
                                  { (yyval.arith_var_) = make_AAarithVarBraced((yyvsp[-1].qual_struct_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4772 "Parser.c"
    break;

  case 72: /* ARITH_VAR: _SYMB_13 QUAL_STRUCT _SYMB_14 SUBSCRIPT  */
#line 737 "HAL_S.y"
                                            { (yyval.arith_var_) = make_ABarithVarBraced((yyvsp[-2].qual_struct_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4778 "Parser.c"
    break;

  case 73: /* ARITH_VAR: QUAL_STRUCT _SYMB_7 ARITH_ID  */
#line 738 "HAL_S.y"
                                 { (yyval.arith_var_) = make_ABarith_var((yyvsp[-2].qual_struct_), (yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4784 "Parser.c"
    break;

  case 74: /* ARITH_VAR: QUAL_STRUCT _SYMB_7 ARITH_ID SUBSCRIPT  */
#line 739 "HAL_S.y"
                                           { (yyval.arith_var_) = make_ADarith_var((yyvsp[-3].qual_struct_), (yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4790 "Parser.c"
    break;

  case 75: /* PRE_PRIMARY: _SYMB_2 ARITH_EXP _SYMB_1  */
#line 741 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AApre_primary((yyvsp[-1].arith_exp_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4796 "Parser.c"
    break;

  case 76: /* PRE_PRIMARY: NUMBER  */
#line 742 "HAL_S.y"
           { (yyval.pre_primary_) = make_ABpre_primary((yyvsp[0].number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4802 "Parser.c"
    break;

  case 77: /* PRE_PRIMARY: COMPOUND_NUMBER  */
#line 743 "HAL_S.y"
                    { (yyval.pre_primary_) = make_ACpre_primary((yyvsp[0].compound_number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4808 "Parser.c"
    break;

  case 78: /* PRE_PRIMARY: ARITH_FUNC _SYMB_2 CALL_LIST _SYMB_1  */
#line 744 "HAL_S.y"
                                         { (yyval.pre_primary_) = make_ADprePrimaryRtlFunction((yyvsp[-3].arith_func_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4814 "Parser.c"
    break;

  case 79: /* PRE_PRIMARY: _SYMB_181 _SYMB_2 CALL_LIST _SYMB_1  */
#line 745 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_ADprePrimaryTypeof((yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4820 "Parser.c"
    break;

  case 80: /* PRE_PRIMARY: _SYMB_182 _SYMB_2 CALL_LIST _SYMB_1  */
#line 746 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_ADprePrimaryTypeofv((yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4826 "Parser.c"
    break;

  case 81: /* PRE_PRIMARY: SHAPING_HEAD _SYMB_1  */
#line 747 "HAL_S.y"
                         { (yyval.pre_primary_) = make_ADprePrimaryRtlShaping((yyvsp[-1].shaping_head_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4832 "Parser.c"
    break;

  case 82: /* PRE_PRIMARY: SHAPING_HEAD _SYMB_0 _SYMB_6 _SYMB_1  */
#line 748 "HAL_S.y"
                                         { (yyval.pre_primary_) = make_ADprePrimaryRtlShapingStar((yyvsp[-3].shaping_head_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4838 "Parser.c"
    break;

  case 83: /* PRE_PRIMARY: _SYMB_192 _SYMB_2 CALL_LIST _SYMB_1  */
#line 749 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AEprePrimaryFunction((yyvsp[-3].string_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4844 "Parser.c"
    break;

  case 84: /* NUMBER: SIMPLE_NUMBER  */
#line 751 "HAL_S.y"
                       { (yyval.number_) = make_AAnumber((yyvsp[0].simple_number_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4850 "Parser.c"
    break;

  case 85: /* NUMBER: LEVEL  */
#line 752 "HAL_S.y"
          { (yyval.number_) = make_ABnumber((yyvsp[0].level_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4856 "Parser.c"
    break;

  case 86: /* LEVEL: _SYMB_198  */
#line 754 "HAL_S.y"
                  { (yyval.level_) = make_ZZlevel((yyvsp[0].string_)); (yyval.level_)->line_number = (yyloc).first_line; (yyval.level_)->char_number = (yyloc).first_column;  }
#line 4862 "Parser.c"
    break;

  case 87: /* COMPOUND_NUMBER: _SYMB_200  */
#line 756 "HAL_S.y"
                            { (yyval.compound_number_) = make_CLcompound_number((yyvsp[0].string_)); (yyval.compound_number_)->line_number = (yyloc).first_line; (yyval.compound_number_)->char_number = (yyloc).first_column;  }
#line 4868 "Parser.c"
    break;

  case 88: /* SIMPLE_NUMBER: _SYMB_199  */
#line 758 "HAL_S.y"
                          { (yyval.simple_number_) = make_CKsimple_number((yyvsp[0].string_)); (yyval.simple_number_)->line_number = (yyloc).first_line; (yyval.simple_number_)->char_number = (yyloc).first_column;  }
#line 4874 "Parser.c"
    break;

  case 89: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC  */
#line 760 "HAL_S.y"
                                        { (yyval.modified_arith_func_) = make_AAmodified_arith_func((yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4880 "Parser.c"
    break;

  case 90: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 761 "HAL_S.y"
                                { (yyval.modified_arith_func_) = make_ACmodified_arith_func((yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4886 "Parser.c"
    break;

  case 91: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_7 NO_ARG_ARITH_FUNC  */
#line 762 "HAL_S.y"
                                          { (yyval.modified_arith_func_) = make_ADmodified_arith_func((yyvsp[-2].qual_struct_), (yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4892 "Parser.c"
    break;

  case 92: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_7 NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 763 "HAL_S.y"
                                                    { (yyval.modified_arith_func_) = make_AEmodified_arith_func((yyvsp[-3].qual_struct_), (yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4898 "Parser.c"
    break;

  case 93: /* SHAPING_HEAD: _SYMB_95 _SYMB_2 REPEATED_CONSTANT  */
#line 765 "HAL_S.y"
                                                  { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadInteger((yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 4904 "Parser.c"
    break;

  case 94: /* SHAPING_HEAD: _SYMB_139 _SYMB_2 REPEATED_CONSTANT  */
#line 766 "HAL_S.y"
                                        { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadScalar((yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 4910 "Parser.c"
    break;

  case 95: /* SHAPING_HEAD: _SYMB_175 _SYMB_2 REPEATED_CONSTANT  */
#line 767 "HAL_S.y"
                                        { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadVector((yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 4916 "Parser.c"
    break;

  case 96: /* SHAPING_HEAD: _SYMB_103 _SYMB_2 REPEATED_CONSTANT  */
#line 768 "HAL_S.y"
                                        { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadMatrix((yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 4922 "Parser.c"
    break;

  case 97: /* SHAPING_HEAD: _SYMB_95 SUBSCRIPT _SYMB_2 REPEATED_CONSTANT  */
#line 769 "HAL_S.y"
                                                 { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadIntegerSubscript((yyvsp[-2].subscript_), (yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 4928 "Parser.c"
    break;

  case 98: /* SHAPING_HEAD: _SYMB_139 SUBSCRIPT _SYMB_2 REPEATED_CONSTANT  */
#line 770 "HAL_S.y"
                                                  { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadScalarSubscript((yyvsp[-2].subscript_), (yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 4934 "Parser.c"
    break;

  case 99: /* SHAPING_HEAD: _SYMB_175 SUBSCRIPT _SYMB_2 REPEATED_CONSTANT  */
#line 771 "HAL_S.y"
                                                  { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadVectorSubscript((yyvsp[-2].subscript_), (yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 4940 "Parser.c"
    break;

  case 100: /* SHAPING_HEAD: _SYMB_103 SUBSCRIPT _SYMB_2 REPEATED_CONSTANT  */
#line 772 "HAL_S.y"
                                                  { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadMatrixSubscript((yyvsp[-2].subscript_), (yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 4946 "Parser.c"
    break;

  case 101: /* SHAPING_HEAD: SHAPING_HEAD _SYMB_0 REPEATED_CONSTANT  */
#line 773 "HAL_S.y"
                                           { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadRepeated((yyvsp[-2].shaping_head_), (yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 4952 "Parser.c"
    break;

  case 102: /* CALL_LIST: LIST_EXP  */
#line 775 "HAL_S.y"
                     { (yyval.call_list_) = make_AAcall_list((yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 4958 "Parser.c"
    break;

  case 103: /* CALL_LIST: CALL_LIST _SYMB_0 LIST_EXP  */
#line 776 "HAL_S.y"
                               { (yyval.call_list_) = make_ABcall_list((yyvsp[-2].call_list_), (yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 4964 "Parser.c"
    break;

  case 104: /* LIST_EXP: EXPRESSION  */
#line 778 "HAL_S.y"
                      { (yyval.list_exp_) = make_AAlist_exp((yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4970 "Parser.c"
    break;

  case 105: /* LIST_EXP: ARITH_EXP _SYMB_10 EXPRESSION  */
#line 779 "HAL_S.y"
                                  { (yyval.list_exp_) = make_ABlist_expRepeated((yyvsp[-2].arith_exp_), (yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4976 "Parser.c"
    break;

  case 106: /* LIST_EXP: QUAL_STRUCT  */
#line 780 "HAL_S.y"
                { (yyval.list_exp_) = make_ADlist_exp((yyvsp[0].qual_struct_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4982 "Parser.c"
    break;

  case 107: /* EXPRESSION: ARITH_EXP  */
#line 782 "HAL_S.y"
                       { (yyval.expression_) = make_AAexpression((yyvsp[0].arith_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4988 "Parser.c"
    break;

  case 108: /* EXPRESSION: BIT_EXP  */
#line 783 "HAL_S.y"
            { (yyval.expression_) = make_ABexpression((yyvsp[0].bit_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4994 "Parser.c"
    break;

  case 109: /* EXPRESSION: CHAR_EXP  */
#line 784 "HAL_S.y"
             { (yyval.expression_) = make_ACexpression((yyvsp[0].char_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 5000 "Parser.c"
    break;

  case 110: /* EXPRESSION: NAME_EXP  */
#line 785 "HAL_S.y"
             { (yyval.expression_) = make_AEexpression((yyvsp[0].name_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 5006 "Parser.c"
    break;

  case 111: /* EXPRESSION: STRUCTURE_EXP  */
#line 786 "HAL_S.y"
                  { (yyval.expression_) = make_ADexpression((yyvsp[0].structure_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 5012 "Parser.c"
    break;

  case 112: /* ARITH_ID: IDENTIFIER  */
#line 788 "HAL_S.y"
                      { (yyval.arith_id_) = make_FGarith_id((yyvsp[0].identifier_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 5018 "Parser.c"
    break;

  case 113: /* ARITH_ID: _SYMB_194  */
#line 789 "HAL_S.y"
              { (yyval.arith_id_) = make_FHarith_id((yyvsp[0].string_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 5024 "Parser.c"
    break;

  case 114: /* NO_ARG_ARITH_FUNC: _SYMB_55  */
#line 791 "HAL_S.y"
                             { (yyval.no_arg_arith_func_) = make_ZZclocktime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 5030 "Parser.c"
    break;

  case 115: /* NO_ARG_ARITH_FUNC: _SYMB_62  */
#line 792 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZdate(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 5036 "Parser.c"
    break;

  case 116: /* NO_ARG_ARITH_FUNC: _SYMB_74  */
#line 793 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZerrgrp(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 5042 "Parser.c"
    break;

  case 117: /* NO_ARG_ARITH_FUNC: _SYMB_75  */
#line 794 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZerrnum(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 5048 "Parser.c"
    break;

  case 118: /* NO_ARG_ARITH_FUNC: _SYMB_119  */
#line 795 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZprio(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 5054 "Parser.c"
    break;

  case 119: /* NO_ARG_ARITH_FUNC: _SYMB_124  */
#line 796 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZrandom(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 5060 "Parser.c"
    break;

  case 120: /* NO_ARG_ARITH_FUNC: _SYMB_125  */
#line 797 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZrandomg(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 5066 "Parser.c"
    break;

  case 121: /* NO_ARG_ARITH_FUNC: _SYMB_138  */
#line 798 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZruntime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 5072 "Parser.c"
    break;

  case 122: /* ARITH_FUNC: _SYMB_109  */
#line 800 "HAL_S.y"
                       { (yyval.arith_func_) = make_ZZnextime(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5078 "Parser.c"
    break;

  case 123: /* ARITH_FUNC: _SYMB_27  */
#line 801 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabs(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5084 "Parser.c"
    break;

  case 124: /* ARITH_FUNC: _SYMB_52  */
#line 802 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZceiling(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5090 "Parser.c"
    break;

  case 125: /* ARITH_FUNC: _SYMB_68  */
#line 803 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdiv(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5096 "Parser.c"
    break;

  case 126: /* ARITH_FUNC: _SYMB_85  */
#line 804 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZfloor(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5102 "Parser.c"
    break;

  case 127: /* ARITH_FUNC: _SYMB_105  */
#line 805 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmidval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5108 "Parser.c"
    break;

  case 128: /* ARITH_FUNC: _SYMB_107  */
#line 806 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5114 "Parser.c"
    break;

  case 129: /* ARITH_FUNC: _SYMB_114  */
#line 807 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZodd(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5120 "Parser.c"
    break;

  case 130: /* ARITH_FUNC: _SYMB_129  */
#line 808 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZremainder(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5126 "Parser.c"
    break;

  case 131: /* ARITH_FUNC: _SYMB_137  */
#line 809 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZround(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5132 "Parser.c"
    break;

  case 132: /* ARITH_FUNC: _SYMB_145  */
#line 810 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsign(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5138 "Parser.c"
    break;

  case 133: /* ARITH_FUNC: _SYMB_147  */
#line 811 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsignum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5144 "Parser.c"
    break;

  case 134: /* ARITH_FUNC: _SYMB_171  */
#line 812 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtruncate(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5150 "Parser.c"
    break;

  case 135: /* ARITH_FUNC: _SYMB_33  */
#line 813 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5156 "Parser.c"
    break;

  case 136: /* ARITH_FUNC: _SYMB_34  */
#line 814 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5162 "Parser.c"
    break;

  case 137: /* ARITH_FUNC: _SYMB_35  */
#line 815 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5168 "Parser.c"
    break;

  case 138: /* ARITH_FUNC: _SYMB_36  */
#line 816 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5174 "Parser.c"
    break;

  case 139: /* ARITH_FUNC: _SYMB_38  */
#line 817 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan2(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5180 "Parser.c"
    break;

  case 140: /* ARITH_FUNC: _SYMB_37  */
#line 818 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5186 "Parser.c"
    break;

  case 141: /* ARITH_FUNC: _SYMB_39  */
#line 819 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5192 "Parser.c"
    break;

  case 142: /* ARITH_FUNC: _SYMB_60  */
#line 820 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5198 "Parser.c"
    break;

  case 143: /* ARITH_FUNC: _SYMB_61  */
#line 821 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5204 "Parser.c"
    break;

  case 144: /* ARITH_FUNC: _SYMB_81  */
#line 822 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZexp(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5210 "Parser.c"
    break;

  case 145: /* ARITH_FUNC: _SYMB_102  */
#line 823 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZlog(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5216 "Parser.c"
    break;

  case 146: /* ARITH_FUNC: _SYMB_148  */
#line 824 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5222 "Parser.c"
    break;

  case 147: /* ARITH_FUNC: _SYMB_150  */
#line 825 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5228 "Parser.c"
    break;

  case 148: /* ARITH_FUNC: _SYMB_153  */
#line 826 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsqrt(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5234 "Parser.c"
    break;

  case 149: /* ARITH_FUNC: _SYMB_160  */
#line 827 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5240 "Parser.c"
    break;

  case 150: /* ARITH_FUNC: _SYMB_161  */
#line 828 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5246 "Parser.c"
    break;

  case 151: /* ARITH_FUNC: _SYMB_143  */
#line 829 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshl(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5252 "Parser.c"
    break;

  case 152: /* ARITH_FUNC: _SYMB_144  */
#line 830 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshr(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5258 "Parser.c"
    break;

  case 153: /* ARITH_FUNC: _SYMB_28  */
#line 831 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5264 "Parser.c"
    break;

  case 154: /* ARITH_FUNC: _SYMB_67  */
#line 832 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdet(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5270 "Parser.c"
    break;

  case 155: /* ARITH_FUNC: _SYMB_167  */
#line 833 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtrace(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5276 "Parser.c"
    break;

  case 156: /* ARITH_FUNC: _SYMB_172  */
#line 834 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZunit(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5282 "Parser.c"
    break;

  case 157: /* ARITH_FUNC: _SYMB_93  */
#line 835 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZindex(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5288 "Parser.c"
    break;

  case 158: /* ARITH_FUNC: _SYMB_98  */
#line 836 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZlength(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5294 "Parser.c"
    break;

  case 159: /* ARITH_FUNC: _SYMB_96  */
#line 837 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZinverse(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5300 "Parser.c"
    break;

  case 160: /* ARITH_FUNC: _SYMB_168  */
#line 838 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtranspose(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5306 "Parser.c"
    break;

  case 161: /* ARITH_FUNC: _SYMB_122  */
#line 839 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZprod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5312 "Parser.c"
    break;

  case 162: /* ARITH_FUNC: _SYMB_157  */
#line 840 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5318 "Parser.c"
    break;

  case 163: /* ARITH_FUNC: _SYMB_151  */
#line 841 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsize(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5324 "Parser.c"
    break;

  case 164: /* ARITH_FUNC: _SYMB_104  */
#line 842 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmax(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5330 "Parser.c"
    break;

  case 165: /* ARITH_FUNC: _SYMB_106  */
#line 843 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5336 "Parser.c"
    break;

  case 166: /* SUBSCRIPT: SUB_HEAD _SYMB_1  */
#line 845 "HAL_S.y"
                             { (yyval.subscript_) = make_AAsubscript((yyvsp[-1].sub_head_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5342 "Parser.c"
    break;

  case 167: /* SUBSCRIPT: QUALIFIER  */
#line 846 "HAL_S.y"
              { (yyval.subscript_) = make_ABsubscript((yyvsp[0].qualifier_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5348 "Parser.c"
    break;

  case 168: /* SUBSCRIPT: _SYMB_15 NUMBER  */
#line 847 "HAL_S.y"
                    { (yyval.subscript_) = make_ACsubscript((yyvsp[0].number_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5354 "Parser.c"
    break;

  case 169: /* SUBSCRIPT: _SYMB_15 ARITH_VAR  */
#line 848 "HAL_S.y"
                       { (yyval.subscript_) = make_ADsubscript((yyvsp[0].arith_var_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5360 "Parser.c"
    break;

  case 170: /* QUALIFIER: _SYMB_15 _SYMB_2 _SYMB_16 PREC_SPEC _SYMB_1  */
#line 850 "HAL_S.y"
                                                        { (yyval.qualifier_) = make_AAqualifier((yyvsp[-1].prec_spec_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5366 "Parser.c"
    break;

  case 171: /* QUALIFIER: _SYMB_15 _SYMB_2 SCALE_HEAD ARITH_EXP _SYMB_1  */
#line 851 "HAL_S.y"
                                                  { (yyval.qualifier_) = make_ABqualifier((yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5372 "Parser.c"
    break;

  case 172: /* QUALIFIER: _SYMB_15 _SYMB_2 _SYMB_16 PREC_SPEC _SYMB_0 SCALE_HEAD ARITH_EXP _SYMB_1  */
#line 852 "HAL_S.y"
                                                                             { (yyval.qualifier_) = make_ACqualifier((yyvsp[-4].prec_spec_), (yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5378 "Parser.c"
    break;

  case 173: /* QUALIFIER: _SYMB_15 _SYMB_2 _SYMB_16 RADIX _SYMB_1  */
#line 853 "HAL_S.y"
                                            { (yyval.qualifier_) = make_ADqualifier((yyvsp[-1].radix_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5384 "Parser.c"
    break;

  case 174: /* SCALE_HEAD: _SYMB_16  */
#line 855 "HAL_S.y"
                      { (yyval.scale_head_) = make_AAscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 5390 "Parser.c"
    break;

  case 175: /* SCALE_HEAD: _SYMB_16 _SYMB_16  */
#line 856 "HAL_S.y"
                      { (yyval.scale_head_) = make_ABscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 5396 "Parser.c"
    break;

  case 176: /* PREC_SPEC: _SYMB_149  */
#line 858 "HAL_S.y"
                      { (yyval.prec_spec_) = make_AAprecSpecSingle(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 5402 "Parser.c"
    break;

  case 177: /* PREC_SPEC: _SYMB_70  */
#line 859 "HAL_S.y"
             { (yyval.prec_spec_) = make_ABprecSpecDouble(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 5408 "Parser.c"
    break;

  case 178: /* SUB_START: _SYMB_15 _SYMB_2  */
#line 861 "HAL_S.y"
                             { (yyval.sub_start_) = make_AAsubStartGroup(); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5414 "Parser.c"
    break;

  case 179: /* SUB_START: _SYMB_15 _SYMB_2 _SYMB_16 PREC_SPEC _SYMB_0  */
#line 862 "HAL_S.y"
                                                { (yyval.sub_start_) = make_ABsubStartPrecSpec((yyvsp[-1].prec_spec_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5420 "Parser.c"
    break;

  case 180: /* SUB_START: SUB_HEAD _SYMB_17  */
#line 863 "HAL_S.y"
                      { (yyval.sub_start_) = make_ACsubStartSemicolon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5426 "Parser.c"
    break;

  case 181: /* SUB_START: SUB_HEAD _SYMB_18  */
#line 864 "HAL_S.y"
                      { (yyval.sub_start_) = make_ADsubStartColon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5432 "Parser.c"
    break;

  case 182: /* SUB_START: SUB_HEAD _SYMB_0  */
#line 865 "HAL_S.y"
                     { (yyval.sub_start_) = make_AEsubStartComma((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5438 "Parser.c"
    break;

  case 183: /* SUB_HEAD: SUB_START  */
#line 867 "HAL_S.y"
                     { (yyval.sub_head_) = make_AAsub_head((yyvsp[0].sub_start_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 5444 "Parser.c"
    break;

  case 184: /* SUB_HEAD: SUB_START SUB  */
#line 868 "HAL_S.y"
                  { (yyval.sub_head_) = make_ABsub_head((yyvsp[-1].sub_start_), (yyvsp[0].sub_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 5450 "Parser.c"
    break;

  case 185: /* SUB: SUB_EXP  */
#line 870 "HAL_S.y"
              { (yyval.sub_) = make_AAsub((yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5456 "Parser.c"
    break;

  case 186: /* SUB: _SYMB_6  */
#line 871 "HAL_S.y"
            { (yyval.sub_) = make_ABsubStar(); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5462 "Parser.c"
    break;

  case 187: /* SUB: SUB_RUN_HEAD SUB_EXP  */
#line 872 "HAL_S.y"
                         { (yyval.sub_) = make_ACsubExp((yyvsp[-1].sub_run_head_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5468 "Parser.c"
    break;

  case 188: /* SUB: ARITH_EXP _SYMB_42 SUB_EXP  */
#line 873 "HAL_S.y"
                               { (yyval.sub_) = make_ADsubAt((yyvsp[-2].arith_exp_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5474 "Parser.c"
    break;

  case 189: /* SUB_RUN_HEAD: SUB_EXP _SYMB_166  */
#line 875 "HAL_S.y"
                                 { (yyval.sub_run_head_) = make_AAsubRunHeadTo((yyvsp[-1].sub_exp_)); (yyval.sub_run_head_)->line_number = (yyloc).first_line; (yyval.sub_run_head_)->char_number = (yyloc).first_column;  }
#line 5480 "Parser.c"
    break;

  case 190: /* SUB_EXP: ARITH_EXP  */
#line 877 "HAL_S.y"
                    { (yyval.sub_exp_) = make_AAsub_exp((yyvsp[0].arith_exp_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 5486 "Parser.c"
    break;

  case 191: /* SUB_EXP: POUND_EXPRESSION  */
#line 878 "HAL_S.y"
                     { (yyval.sub_exp_) = make_ABsub_exp((yyvsp[0].pound_expression_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 5492 "Parser.c"
    break;

  case 192: /* POUND_EXPRESSION: _SYMB_10  */
#line 880 "HAL_S.y"
                            { (yyval.pound_expression_) = make_AApound_expression(); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5498 "Parser.c"
    break;

  case 193: /* POUND_EXPRESSION: POUND_EXPRESSION PLUS TERM  */
#line 881 "HAL_S.y"
                               { (yyval.pound_expression_) = make_ABpound_expression((yyvsp[-2].pound_expression_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5504 "Parser.c"
    break;

  case 194: /* POUND_EXPRESSION: POUND_EXPRESSION MINUS TERM  */
#line 882 "HAL_S.y"
                                { (yyval.pound_expression_) = make_ACpound_expression((yyvsp[-2].pound_expression_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5510 "Parser.c"
    break;

  case 195: /* BIT_EXP: BIT_FACTOR  */
#line 884 "HAL_S.y"
                     { (yyval.bit_exp_) = make_AAbitExpFactor((yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 5516 "Parser.c"
    break;

  case 196: /* BIT_EXP: BIT_EXP OR BIT_FACTOR  */
#line 885 "HAL_S.y"
                          { (yyval.bit_exp_) = make_ABbitExpOR((yyvsp[-2].bit_exp_), (yyvsp[-1].or_), (yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 5522 "Parser.c"
    break;

  case 197: /* BIT_FACTOR: BIT_CAT  */
#line 887 "HAL_S.y"
                     { (yyval.bit_factor_) = make_AAbitFactor((yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 5528 "Parser.c"
    break;

  case 198: /* BIT_FACTOR: BIT_FACTOR AND BIT_CAT  */
#line 888 "HAL_S.y"
                           { (yyval.bit_factor_) = make_ABbitFactorAnd((yyvsp[-2].bit_factor_), (yyvsp[-1].and_), (yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 5534 "Parser.c"
    break;

  case 199: /* BIT_CAT: BIT_PRIM  */
#line 890 "HAL_S.y"
                   { (yyval.bit_cat_) = make_AAbitCatPrim((yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5540 "Parser.c"
    break;

  case 200: /* BIT_CAT: BIT_CAT CAT BIT_PRIM  */
#line 891 "HAL_S.y"
                         { (yyval.bit_cat_) = make_ABbitCatCat((yyvsp[-2].bit_cat_), (yyvsp[-1].cat_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5546 "Parser.c"
    break;

  case 201: /* BIT_CAT: NOT BIT_PRIM  */
#line 892 "HAL_S.y"
                 { (yyval.bit_cat_) = make_ACbitCatNotPrim((yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5552 "Parser.c"
    break;

  case 202: /* BIT_CAT: BIT_CAT CAT NOT BIT_PRIM  */
#line 893 "HAL_S.y"
                             { (yyval.bit_cat_) = make_ADbitCatNotCat((yyvsp[-3].bit_cat_), (yyvsp[-2].cat_), (yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5558 "Parser.c"
    break;

  case 203: /* OR: CHAR_VERTICAL_BAR  */
#line 895 "HAL_S.y"
                       { (yyval.or_) = make_AAOR((yyvsp[0].char_vertical_bar_)); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5564 "Parser.c"
    break;

  case 204: /* OR: _SYMB_117  */
#line 896 "HAL_S.y"
              { (yyval.or_) = make_ABOR(); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5570 "Parser.c"
    break;

  case 205: /* CHAR_VERTICAL_BAR: _SYMB_19  */
#line 898 "HAL_S.y"
                             { (yyval.char_vertical_bar_) = make_CFchar_vertical_bar(); (yyval.char_vertical_bar_)->line_number = (yyloc).first_line; (yyval.char_vertical_bar_)->char_number = (yyloc).first_column;  }
#line 5576 "Parser.c"
    break;

  case 206: /* AND: _SYMB_20  */
#line 900 "HAL_S.y"
               { (yyval.and_) = make_AAAND(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5582 "Parser.c"
    break;

  case 207: /* AND: _SYMB_32  */
#line 901 "HAL_S.y"
             { (yyval.and_) = make_ABAND(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5588 "Parser.c"
    break;

  case 208: /* BIT_PRIM: BIT_VAR  */
#line 903 "HAL_S.y"
                   { (yyval.bit_prim_) = make_AAbitPrimBitVar((yyvsp[0].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5594 "Parser.c"
    break;

  case 209: /* BIT_PRIM: LABEL_VAR  */
#line 904 "HAL_S.y"
              { (yyval.bit_prim_) = make_ABbitPrimLabelVar((yyvsp[0].label_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5600 "Parser.c"
    break;

  case 210: /* BIT_PRIM: EVENT_VAR  */
#line 905 "HAL_S.y"
              { (yyval.bit_prim_) = make_ACbitPrimEventVar((yyvsp[0].event_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5606 "Parser.c"
    break;

  case 211: /* BIT_PRIM: BIT_CONST  */
#line 906 "HAL_S.y"
              { (yyval.bit_prim_) = make_ADbitBitConst((yyvsp[0].bit_const_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5612 "Parser.c"
    break;

  case 212: /* BIT_PRIM: _SYMB_2 BIT_EXP _SYMB_1  */
#line 907 "HAL_S.y"
                            { (yyval.bit_prim_) = make_AEbitPrimBitExp((yyvsp[-1].bit_exp_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5618 "Parser.c"
    break;

  case 213: /* BIT_PRIM: SUBBIT_HEAD EXPRESSION _SYMB_1  */
#line 908 "HAL_S.y"
                                   { (yyval.bit_prim_) = make_AHbitPrimSubbit((yyvsp[-2].subbit_head_), (yyvsp[-1].expression_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5624 "Parser.c"
    break;

  case 214: /* BIT_PRIM: BIT_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 909 "HAL_S.y"
                                            { (yyval.bit_prim_) = make_AIbitPrimFunc((yyvsp[-3].bit_func_head_), (yyvsp[-1].call_list_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5630 "Parser.c"
    break;

  case 215: /* BIT_PRIM: _SYMB_180 _SYMB_2 CALL_LIST _SYMB_1  */
#line 910 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_AIbitPrimInitialized((yyvsp[-1].call_list_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5636 "Parser.c"
    break;

  case 216: /* BIT_PRIM: _SYMB_11 BIT_VAR _SYMB_12  */
#line 911 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBracketed((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5642 "Parser.c"
    break;

  case 217: /* BIT_PRIM: _SYMB_11 BIT_VAR _SYMB_12 SUBSCRIPT  */
#line 912 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBracketed((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5648 "Parser.c"
    break;

  case 218: /* BIT_PRIM: _SYMB_13 BIT_VAR _SYMB_14  */
#line 913 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBraced((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5654 "Parser.c"
    break;

  case 219: /* BIT_PRIM: _SYMB_13 BIT_VAR _SYMB_14 SUBSCRIPT  */
#line 914 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBraced((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5660 "Parser.c"
    break;

  case 220: /* CAT: _SYMB_21  */
#line 916 "HAL_S.y"
               { (yyval.cat_) = make_AAcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5666 "Parser.c"
    break;

  case 221: /* CAT: _SYMB_51  */
#line 917 "HAL_S.y"
             { (yyval.cat_) = make_ABcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5672 "Parser.c"
    break;

  case 222: /* NOT: _SYMB_111  */
#line 919 "HAL_S.y"
                { (yyval.not_) = make_ABNOT(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5678 "Parser.c"
    break;

  case 223: /* NOT: _SYMB_22  */
#line 920 "HAL_S.y"
             { (yyval.not_) = make_ADNOT(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5684 "Parser.c"
    break;

  case 224: /* BIT_VAR: BIT_ID  */
#line 922 "HAL_S.y"
                 { (yyval.bit_var_) = make_AAbit_var((yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5690 "Parser.c"
    break;

  case 225: /* BIT_VAR: BIT_ID SUBSCRIPT  */
#line 923 "HAL_S.y"
                     { (yyval.bit_var_) = make_ACbit_var((yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5696 "Parser.c"
    break;

  case 226: /* BIT_VAR: QUAL_STRUCT _SYMB_7 BIT_ID  */
#line 924 "HAL_S.y"
                               { (yyval.bit_var_) = make_ABbit_var((yyvsp[-2].qual_struct_), (yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5702 "Parser.c"
    break;

  case 227: /* BIT_VAR: QUAL_STRUCT _SYMB_7 BIT_ID SUBSCRIPT  */
#line 925 "HAL_S.y"
                                         { (yyval.bit_var_) = make_ADbit_var((yyvsp[-3].qual_struct_), (yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5708 "Parser.c"
    break;

  case 228: /* LABEL_VAR: LABEL  */
#line 927 "HAL_S.y"
                  { (yyval.label_var_) = make_AAlabel_var((yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5714 "Parser.c"
    break;

  case 229: /* LABEL_VAR: LABEL SUBSCRIPT  */
#line 928 "HAL_S.y"
                    { (yyval.label_var_) = make_ABlabel_var((yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5720 "Parser.c"
    break;

  case 230: /* LABEL_VAR: QUAL_STRUCT _SYMB_7 LABEL  */
#line 929 "HAL_S.y"
                              { (yyval.label_var_) = make_AClabel_var((yyvsp[-2].qual_struct_), (yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5726 "Parser.c"
    break;

  case 231: /* LABEL_VAR: QUAL_STRUCT _SYMB_7 LABEL SUBSCRIPT  */
#line 930 "HAL_S.y"
                                        { (yyval.label_var_) = make_ADlabel_var((yyvsp[-3].qual_struct_), (yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5732 "Parser.c"
    break;

  case 232: /* EVENT_VAR: EVENT  */
#line 932 "HAL_S.y"
                  { (yyval.event_var_) = make_AAevent_var((yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5738 "Parser.c"
    break;

  case 233: /* EVENT_VAR: EVENT SUBSCRIPT  */
#line 933 "HAL_S.y"
                    { (yyval.event_var_) = make_ACevent_var((yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5744 "Parser.c"
    break;

  case 234: /* EVENT_VAR: QUAL_STRUCT _SYMB_7 EVENT  */
#line 934 "HAL_S.y"
                              { (yyval.event_var_) = make_ABevent_var((yyvsp[-2].qual_struct_), (yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5750 "Parser.c"
    break;

  case 235: /* EVENT_VAR: QUAL_STRUCT _SYMB_7 EVENT SUBSCRIPT  */
#line 935 "HAL_S.y"
                                        { (yyval.event_var_) = make_ADevent_var((yyvsp[-3].qual_struct_), (yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5756 "Parser.c"
    break;

  case 236: /* BIT_CONST_HEAD: RADIX  */
#line 937 "HAL_S.y"
                       { (yyval.bit_const_head_) = make_AAbit_const_head((yyvsp[0].radix_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5762 "Parser.c"
    break;

  case 237: /* BIT_CONST_HEAD: RADIX _SYMB_2 NUMBER _SYMB_1  */
#line 938 "HAL_S.y"
                                 { (yyval.bit_const_head_) = make_ABbit_const_head((yyvsp[-3].radix_), (yyvsp[-1].number_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5768 "Parser.c"
    break;

  case 238: /* BIT_CONST: BIT_CONST_HEAD CHAR_STRING  */
#line 940 "HAL_S.y"
                                       { (yyval.bit_const_) = make_AAbitConstString((yyvsp[-1].bit_const_head_), (yyvsp[0].char_string_)); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5774 "Parser.c"
    break;

  case 239: /* BIT_CONST: _SYMB_170  */
#line 941 "HAL_S.y"
              { (yyval.bit_const_) = make_ABbitConstTrue(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5780 "Parser.c"
    break;

  case 240: /* BIT_CONST: _SYMB_83  */
#line 942 "HAL_S.y"
             { (yyval.bit_const_) = make_ACbitConstFalse(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5786 "Parser.c"
    break;

  case 241: /* BIT_CONST: _SYMB_116  */
#line 943 "HAL_S.y"
              { (yyval.bit_const_) = make_ADbitConstOn(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5792 "Parser.c"
    break;

  case 242: /* BIT_CONST: _SYMB_115  */
#line 944 "HAL_S.y"
              { (yyval.bit_const_) = make_AEbitConstOff(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5798 "Parser.c"
    break;

  case 243: /* RADIX: _SYMB_89  */
#line 946 "HAL_S.y"
                 { (yyval.radix_) = make_AAradixHEX(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5804 "Parser.c"
    break;

  case 244: /* RADIX: _SYMB_113  */
#line 947 "HAL_S.y"
              { (yyval.radix_) = make_ABradixOCT(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5810 "Parser.c"
    break;

  case 245: /* RADIX: _SYMB_44  */
#line 948 "HAL_S.y"
             { (yyval.radix_) = make_ACradixBIN(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5816 "Parser.c"
    break;

  case 246: /* RADIX: _SYMB_63  */
#line 949 "HAL_S.y"
             { (yyval.radix_) = make_ADradixDEC(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5822 "Parser.c"
    break;

  case 247: /* CHAR_STRING: _SYMB_196  */
#line 951 "HAL_S.y"
                        { (yyval.char_string_) = make_FPchar_string((yyvsp[0].string_)); (yyval.char_string_)->line_number = (yyloc).first_line; (yyval.char_string_)->char_number = (yyloc).first_column;  }
#line 5828 "Parser.c"
    break;

  case 248: /* SUBBIT_HEAD: SUBBIT_KEY _SYMB_2  */
#line 953 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_AAsubbit_head((yyvsp[-1].subbit_key_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5834 "Parser.c"
    break;

  case 249: /* SUBBIT_HEAD: SUBBIT_KEY SUBSCRIPT _SYMB_2  */
#line 954 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_ABsubbit_head((yyvsp[-2].subbit_key_), (yyvsp[-1].subscript_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5840 "Parser.c"
    break;

  case 250: /* SUBBIT_KEY: _SYMB_156  */
#line 956 "HAL_S.y"
                       { (yyval.subbit_key_) = make_AAsubbit_key(); (yyval.subbit_key_)->line_number = (yyloc).first_line; (yyval.subbit_key_)->char_number = (yyloc).first_column;  }
#line 5846 "Parser.c"
    break;

  case 251: /* BIT_FUNC_HEAD: BIT_FUNC  */
#line 958 "HAL_S.y"
                         { (yyval.bit_func_head_) = make_AAbit_func_head((yyvsp[0].bit_func_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5852 "Parser.c"
    break;

  case 252: /* BIT_FUNC_HEAD: _SYMB_45  */
#line 959 "HAL_S.y"
             { (yyval.bit_func_head_) = make_ABbit_func_head(); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5858 "Parser.c"
    break;

  case 253: /* BIT_FUNC_HEAD: _SYMB_45 SUB_OR_QUALIFIER  */
#line 960 "HAL_S.y"
                              { (yyval.bit_func_head_) = make_ACbit_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5864 "Parser.c"
    break;

  case 254: /* BIT_ID: _SYMB_186  */
#line 962 "HAL_S.y"
                   { (yyval.bit_id_) = make_FHbit_id((yyvsp[0].string_)); (yyval.bit_id_)->line_number = (yyloc).first_line; (yyval.bit_id_)->char_number = (yyloc).first_column;  }
#line 5870 "Parser.c"
    break;

  case 255: /* LABEL: _SYMB_192  */
#line 964 "HAL_S.y"
                  { (yyval.label_) = make_FKlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5876 "Parser.c"
    break;

  case 256: /* LABEL: _SYMB_187  */
#line 965 "HAL_S.y"
              { (yyval.label_) = make_FLlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5882 "Parser.c"
    break;

  case 257: /* LABEL: _SYMB_188  */
#line 966 "HAL_S.y"
              { (yyval.label_) = make_FMlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5888 "Parser.c"
    break;

  case 258: /* LABEL: _SYMB_191  */
#line 967 "HAL_S.y"
              { (yyval.label_) = make_FNlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5894 "Parser.c"
    break;

  case 259: /* BIT_FUNC: _SYMB_179  */
#line 969 "HAL_S.y"
                     { (yyval.bit_func_) = make_ZZxor(); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5900 "Parser.c"
    break;

  case 260: /* BIT_FUNC: _SYMB_187  */
#line 970 "HAL_S.y"
              { (yyval.bit_func_) = make_ZZuserBitFunction((yyvsp[0].string_)); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5906 "Parser.c"
    break;

  case 261: /* EVENT: _SYMB_193  */
#line 972 "HAL_S.y"
                  { (yyval.event_) = make_FLevent((yyvsp[0].string_)); (yyval.event_)->line_number = (yyloc).first_line; (yyval.event_)->char_number = (yyloc).first_column;  }
#line 5912 "Parser.c"
    break;

  case 262: /* SUB_OR_QUALIFIER: SUBSCRIPT  */
#line 974 "HAL_S.y"
                             { (yyval.sub_or_qualifier_) = make_AAsub_or_qualifier((yyvsp[0].subscript_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 5918 "Parser.c"
    break;

  case 263: /* SUB_OR_QUALIFIER: BIT_QUALIFIER  */
#line 975 "HAL_S.y"
                  { (yyval.sub_or_qualifier_) = make_ABsub_or_qualifier((yyvsp[0].bit_qualifier_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 5924 "Parser.c"
    break;

  case 264: /* BIT_QUALIFIER: _SYMB_23 _SYMB_15 _SYMB_2 _SYMB_16 RADIX _SYMB_1  */
#line 977 "HAL_S.y"
                                                                 { (yyval.bit_qualifier_) = make_AAbit_qualifier((yyvsp[-1].radix_)); (yyval.bit_qualifier_)->line_number = (yyloc).first_line; (yyval.bit_qualifier_)->char_number = (yyloc).first_column;  }
#line 5930 "Parser.c"
    break;

  case 265: /* CHAR_EXP: CHAR_PRIM  */
#line 979 "HAL_S.y"
                     { (yyval.char_exp_) = make_AAcharExpPrim((yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5936 "Parser.c"
    break;

  case 266: /* CHAR_EXP: CHAR_EXP CAT CHAR_PRIM  */
#line 980 "HAL_S.y"
                           { (yyval.char_exp_) = make_ABcharExpCat((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5942 "Parser.c"
    break;

  case 267: /* CHAR_EXP: CHAR_EXP CAT ARITH_EXP  */
#line 981 "HAL_S.y"
                           { (yyval.char_exp_) = make_ACcharExpCat((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5948 "Parser.c"
    break;

  case 268: /* CHAR_EXP: ARITH_EXP CAT ARITH_EXP  */
#line 982 "HAL_S.y"
                            { (yyval.char_exp_) = make_ADcharExpCat((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5954 "Parser.c"
    break;

  case 269: /* CHAR_EXP: ARITH_EXP CAT CHAR_PRIM  */
#line 983 "HAL_S.y"
                            { (yyval.char_exp_) = make_AEcharExpCat((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5960 "Parser.c"
    break;

  case 270: /* CHAR_PRIM: CHAR_VAR  */
#line 985 "HAL_S.y"
                     { (yyval.char_prim_) = make_AAchar_prim((yyvsp[0].char_var_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5966 "Parser.c"
    break;

  case 271: /* CHAR_PRIM: CHAR_CONST  */
#line 986 "HAL_S.y"
               { (yyval.char_prim_) = make_ABchar_prim((yyvsp[0].char_const_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5972 "Parser.c"
    break;

  case 272: /* CHAR_PRIM: CHAR_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 987 "HAL_S.y"
                                             { (yyval.char_prim_) = make_AEchar_prim((yyvsp[-3].char_func_head_), (yyvsp[-1].call_list_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5978 "Parser.c"
    break;

  case 273: /* CHAR_PRIM: _SYMB_2 CHAR_EXP _SYMB_1  */
#line 988 "HAL_S.y"
                             { (yyval.char_prim_) = make_AFchar_prim((yyvsp[-1].char_exp_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5984 "Parser.c"
    break;

  case 274: /* CHAR_FUNC_HEAD: CHAR_FUNC  */
#line 990 "HAL_S.y"
                           { (yyval.char_func_head_) = make_AAchar_func_head((yyvsp[0].char_func_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 5990 "Parser.c"
    break;

  case 275: /* CHAR_FUNC_HEAD: _SYMB_54 SUB_OR_QUALIFIER  */
#line 991 "HAL_S.y"
                              { (yyval.char_func_head_) = make_ABchar_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 5996 "Parser.c"
    break;

  case 276: /* CHAR_VAR: CHAR_ID  */
#line 993 "HAL_S.y"
                   { (yyval.char_var_) = make_AAchar_var((yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 6002 "Parser.c"
    break;

  case 277: /* CHAR_VAR: CHAR_ID SUBSCRIPT  */
#line 994 "HAL_S.y"
                      { (yyval.char_var_) = make_ACchar_var((yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 6008 "Parser.c"
    break;

  case 278: /* CHAR_VAR: QUAL_STRUCT _SYMB_7 CHAR_ID  */
#line 995 "HAL_S.y"
                                { (yyval.char_var_) = make_ABchar_var((yyvsp[-2].qual_struct_), (yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 6014 "Parser.c"
    break;

  case 279: /* CHAR_VAR: QUAL_STRUCT _SYMB_7 CHAR_ID SUBSCRIPT  */
#line 996 "HAL_S.y"
                                          { (yyval.char_var_) = make_ADchar_var((yyvsp[-3].qual_struct_), (yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 6020 "Parser.c"
    break;

  case 280: /* CHAR_CONST: CHAR_STRING  */
#line 998 "HAL_S.y"
                         { (yyval.char_const_) = make_AAchar_const((yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 6026 "Parser.c"
    break;

  case 281: /* CHAR_CONST: _SYMB_53 _SYMB_2 NUMBER _SYMB_1 CHAR_STRING  */
#line 999 "HAL_S.y"
                                                { (yyval.char_const_) = make_ABchar_const((yyvsp[-2].number_), (yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 6032 "Parser.c"
    break;

  case 282: /* CHAR_FUNC: _SYMB_100  */
#line 1001 "HAL_S.y"
                      { (yyval.char_func_) = make_ZZljust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 6038 "Parser.c"
    break;

  case 283: /* CHAR_FUNC: _SYMB_136  */
#line 1002 "HAL_S.y"
              { (yyval.char_func_) = make_ZZrjust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 6044 "Parser.c"
    break;

  case 284: /* CHAR_FUNC: _SYMB_169  */
#line 1003 "HAL_S.y"
              { (yyval.char_func_) = make_ZZtrim(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 6050 "Parser.c"
    break;

  case 285: /* CHAR_FUNC: _SYMB_188  */
#line 1004 "HAL_S.y"
              { (yyval.char_func_) = make_ZZuserCharFunction((yyvsp[0].string_)); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 6056 "Parser.c"
    break;

  case 286: /* CHAR_FUNC: _SYMB_54  */
#line 1005 "HAL_S.y"
             { (yyval.char_func_) = make_AAcharFuncCharacter(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 6062 "Parser.c"
    break;

  case 287: /* CHAR_ID: _SYMB_189  */
#line 1007 "HAL_S.y"
                    { (yyval.char_id_) = make_FIchar_id((yyvsp[0].string_)); (yyval.char_id_)->line_number = (yyloc).first_line; (yyval.char_id_)->char_number = (yyloc).first_column;  }
#line 6068 "Parser.c"
    break;

  case 288: /* NAME_EXP: NAME_KEY _SYMB_2 NAME_VAR _SYMB_1  */
#line 1009 "HAL_S.y"
                                             { (yyval.name_exp_) = make_AAnameExpKeyVar((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 6074 "Parser.c"
    break;

  case 289: /* NAME_EXP: _SYMB_112  */
#line 1010 "HAL_S.y"
              { (yyval.name_exp_) = make_ABnameExpNull(); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 6080 "Parser.c"
    break;

  case 290: /* NAME_EXP: NAME_KEY _SYMB_2 _SYMB_112 _SYMB_1  */
#line 1011 "HAL_S.y"
                                       { (yyval.name_exp_) = make_ACnameExpKeyNull((yyvsp[-3].name_key_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 6086 "Parser.c"
    break;

  case 291: /* NAME_KEY: _SYMB_108  */
#line 1013 "HAL_S.y"
                     { (yyval.name_key_) = make_AAname_key(); (yyval.name_key_)->line_number = (yyloc).first_line; (yyval.name_key_)->char_number = (yyloc).first_column;  }
#line 6092 "Parser.c"
    break;

  case 292: /* NAME_VAR: VARIABLE  */
#line 1015 "HAL_S.y"
                    { (yyval.name_var_) = make_AAname_var((yyvsp[0].variable_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 6098 "Parser.c"
    break;

  case 293: /* NAME_VAR: MODIFIED_ARITH_FUNC  */
#line 1016 "HAL_S.y"
                        { (yyval.name_var_) = make_ACname_var((yyvsp[0].modified_arith_func_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 6104 "Parser.c"
    break;

  case 294: /* NAME_VAR: LABEL_VAR  */
#line 1017 "HAL_S.y"
              { (yyval.name_var_) = make_ABname_var((yyvsp[0].label_var_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 6110 "Parser.c"
    break;

  case 295: /* VARIABLE: ARITH_VAR  */
#line 1019 "HAL_S.y"
                     { (yyval.variable_) = make_AAvariable((yyvsp[0].arith_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6116 "Parser.c"
    break;

  case 296: /* VARIABLE: BIT_VAR  */
#line 1020 "HAL_S.y"
            { (yyval.variable_) = make_ACvariable((yyvsp[0].bit_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6122 "Parser.c"
    break;

  case 297: /* VARIABLE: SUBBIT_HEAD VARIABLE _SYMB_1  */
#line 1021 "HAL_S.y"
                                 { (yyval.variable_) = make_AEvariable((yyvsp[-2].subbit_head_), (yyvsp[-1].variable_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6128 "Parser.c"
    break;

  case 298: /* VARIABLE: CHAR_VAR  */
#line 1022 "HAL_S.y"
             { (yyval.variable_) = make_AFvariable((yyvsp[0].char_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6134 "Parser.c"
    break;

  case 299: /* VARIABLE: NAME_KEY _SYMB_2 NAME_VAR _SYMB_1  */
#line 1023 "HAL_S.y"
                                      { (yyval.variable_) = make_AGvariable((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6140 "Parser.c"
    break;

  case 300: /* VARIABLE: EVENT_VAR  */
#line 1024 "HAL_S.y"
              { (yyval.variable_) = make_ADvariable((yyvsp[0].event_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6146 "Parser.c"
    break;

  case 301: /* VARIABLE: STRUCTURE_VAR  */
#line 1025 "HAL_S.y"
                  { (yyval.variable_) = make_ABvariable((yyvsp[0].structure_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6152 "Parser.c"
    break;

  case 302: /* STRUCTURE_EXP: STRUCTURE_VAR  */
#line 1027 "HAL_S.y"
                              { (yyval.structure_exp_) = make_AAstructure_exp((yyvsp[0].structure_var_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 6158 "Parser.c"
    break;

  case 303: /* STRUCTURE_EXP: STRUCT_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 1028 "HAL_S.y"
                                               { (yyval.structure_exp_) = make_ADstructure_exp((yyvsp[-3].struct_func_head_), (yyvsp[-1].call_list_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 6164 "Parser.c"
    break;

  case 304: /* STRUCTURE_EXP: STRUC_INLINE_DEF CLOSING _SYMB_17  */
#line 1029 "HAL_S.y"
                                      { (yyval.structure_exp_) = make_ACstructure_exp((yyvsp[-2].struc_inline_def_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 6170 "Parser.c"
    break;

  case 305: /* STRUCTURE_EXP: STRUC_INLINE_DEF BLOCK_BODY CLOSING _SYMB_17  */
#line 1030 "HAL_S.y"
                                                 { (yyval.structure_exp_) = make_AEstructure_exp((yyvsp[-3].struc_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 6176 "Parser.c"
    break;

  case 306: /* STRUCT_FUNC_HEAD: STRUCT_FUNC  */
#line 1032 "HAL_S.y"
                               { (yyval.struct_func_head_) = make_AAstruct_func_head((yyvsp[0].struct_func_)); (yyval.struct_func_head_)->line_number = (yyloc).first_line; (yyval.struct_func_head_)->char_number = (yyloc).first_column;  }
#line 6182 "Parser.c"
    break;

  case 307: /* STRUCTURE_VAR: QUAL_STRUCT SUBSCRIPT  */
#line 1034 "HAL_S.y"
                                      { (yyval.structure_var_) = make_AAstructure_var((yyvsp[-1].qual_struct_), (yyvsp[0].subscript_)); (yyval.structure_var_)->line_number = (yyloc).first_line; (yyval.structure_var_)->char_number = (yyloc).first_column;  }
#line 6188 "Parser.c"
    break;

  case 308: /* STRUCT_FUNC: _SYMB_191  */
#line 1036 "HAL_S.y"
                        { (yyval.struct_func_) = make_ZZuserStructFunc((yyvsp[0].string_)); (yyval.struct_func_)->line_number = (yyloc).first_line; (yyval.struct_func_)->char_number = (yyloc).first_column;  }
#line 6194 "Parser.c"
    break;

  case 309: /* QUAL_STRUCT: STRUCTURE_ID  */
#line 1038 "HAL_S.y"
                           { (yyval.qual_struct_) = make_AAqual_struct((yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 6200 "Parser.c"
    break;

  case 310: /* QUAL_STRUCT: QUAL_STRUCT _SYMB_7 STRUCTURE_ID  */
#line 1039 "HAL_S.y"
                                     { (yyval.qual_struct_) = make_ABqual_struct((yyvsp[-2].qual_struct_), (yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 6206 "Parser.c"
    break;

  case 311: /* STRUCTURE_ID: _SYMB_190  */
#line 1041 "HAL_S.y"
                         { (yyval.structure_id_) = make_FJstructure_id((yyvsp[0].string_)); (yyval.structure_id_)->line_number = (yyloc).first_line; (yyval.structure_id_)->char_number = (yyloc).first_column;  }
#line 6212 "Parser.c"
    break;

  case 312: /* ASSIGNMENT: VARIABLE EQUALS EXPRESSION  */
#line 1043 "HAL_S.y"
                                        { (yyval.assignment_) = make_AAassignment((yyvsp[-2].variable_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6218 "Parser.c"
    break;

  case 313: /* ASSIGNMENT: VARIABLE _SYMB_0 ASSIGNMENT  */
#line 1044 "HAL_S.y"
                                { (yyval.assignment_) = make_ABassignment((yyvsp[-2].variable_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6224 "Parser.c"
    break;

  case 314: /* ASSIGNMENT: QUAL_STRUCT EQUALS EXPRESSION  */
#line 1045 "HAL_S.y"
                                  { (yyval.assignment_) = make_ACassignment((yyvsp[-2].qual_struct_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6230 "Parser.c"
    break;

  case 315: /* ASSIGNMENT: QUAL_STRUCT _SYMB_0 ASSIGNMENT  */
#line 1046 "HAL_S.y"
                                   { (yyval.assignment_) = make_ADassignment((yyvsp[-2].qual_struct_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6236 "Parser.c"
    break;

  case 316: /* EQUALS: _SYMB_24  */
#line 1048 "HAL_S.y"
                  { (yyval.equals_) = make_AAequals(); (yyval.equals_)->line_number = (yyloc).first_line; (yyval.equals_)->char_number = (yyloc).first_column;  }
#line 6242 "Parser.c"
    break;

  case 317: /* STATEMENT: BASIC_STATEMENT  */
#line 1050 "HAL_S.y"
                            { (yyval.statement_) = make_AAstatement((yyvsp[0].basic_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6248 "Parser.c"
    break;

  case 318: /* STATEMENT: OTHER_STATEMENT  */
#line 1051 "HAL_S.y"
                    { (yyval.statement_) = make_ABstatement((yyvsp[0].other_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6254 "Parser.c"
    break;

  case 319: /* STATEMENT: INLINE_DEFINITION  */
#line 1052 "HAL_S.y"
                      { (yyval.statement_) = make_AZstatement((yyvsp[0].inline_definition_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6260 "Parser.c"
    break;

  case 320: /* BASIC_STATEMENT: ASSIGNMENT _SYMB_17  */
#line 1054 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_ABbasicStatementAssignment((yyvsp[-1].assignment_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6266 "Parser.c"
    break;

  case 321: /* BASIC_STATEMENT: LABEL_DEFINITION BASIC_STATEMENT  */
#line 1055 "HAL_S.y"
                                     { (yyval.basic_statement_) = make_AAbasic_statement((yyvsp[-1].label_definition_), (yyvsp[0].basic_statement_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6272 "Parser.c"
    break;

  case 322: /* BASIC_STATEMENT: _SYMB_80 _SYMB_17  */
#line 1056 "HAL_S.y"
                      { (yyval.basic_statement_) = make_ACbasicStatementExit(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6278 "Parser.c"
    break;

  case 323: /* BASIC_STATEMENT: _SYMB_80 LABEL _SYMB_17  */
#line 1057 "HAL_S.y"
                            { (yyval.basic_statement_) = make_ADbasicStatementExit((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6284 "Parser.c"
    break;

  case 324: /* BASIC_STATEMENT: _SYMB_131 _SYMB_17  */
#line 1058 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AEbasicStatementRepeat(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6290 "Parser.c"
    break;

  case 325: /* BASIC_STATEMENT: _SYMB_131 LABEL _SYMB_17  */
#line 1059 "HAL_S.y"
                             { (yyval.basic_statement_) = make_AFbasicStatementRepeat((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6296 "Parser.c"
    break;

  case 326: /* BASIC_STATEMENT: _SYMB_88 _SYMB_166 LABEL _SYMB_17  */
#line 1060 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AGbasicStatementGoTo((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6302 "Parser.c"
    break;

  case 327: /* BASIC_STATEMENT: _SYMB_17  */
#line 1061 "HAL_S.y"
             { (yyval.basic_statement_) = make_AHbasicStatementEmpty(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6308 "Parser.c"
    break;

  case 328: /* BASIC_STATEMENT: CALL_KEY _SYMB_17  */
#line 1062 "HAL_S.y"
                      { (yyval.basic_statement_) = make_AIbasicStatementCall((yyvsp[-1].call_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6314 "Parser.c"
    break;

  case 329: /* BASIC_STATEMENT: CALL_KEY _SYMB_2 CALL_LIST _SYMB_1 _SYMB_17  */
#line 1063 "HAL_S.y"
                                                { (yyval.basic_statement_) = make_AJbasicStatementCall((yyvsp[-4].call_key_), (yyvsp[-2].call_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6320 "Parser.c"
    break;

  case 330: /* BASIC_STATEMENT: CALL_KEY ASSIGN _SYMB_2 CALL_ASSIGN_LIST _SYMB_1 _SYMB_17  */
#line 1064 "HAL_S.y"
                                                              { (yyval.basic_statement_) = make_AKbasicStatementCall((yyvsp[-5].call_key_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6326 "Parser.c"
    break;

  case 331: /* BASIC_STATEMENT: CALL_KEY _SYMB_2 CALL_LIST _SYMB_1 ASSIGN _SYMB_2 CALL_ASSIGN_LIST _SYMB_1 _SYMB_17  */
#line 1065 "HAL_S.y"
                                                                                        { (yyval.basic_statement_) = make_ALbasicStatementCall((yyvsp[-8].call_key_), (yyvsp[-6].call_list_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6332 "Parser.c"
    break;

  case 332: /* BASIC_STATEMENT: _SYMB_134 _SYMB_17  */
#line 1066 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AMbasicStatementReturn(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6338 "Parser.c"
    break;

  case 333: /* BASIC_STATEMENT: _SYMB_134 EXPRESSION _SYMB_17  */
#line 1067 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_ANbasicStatementReturn((yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6344 "Parser.c"
    break;

  case 334: /* BASIC_STATEMENT: DO_GROUP_HEAD ENDING _SYMB_17  */
#line 1068 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_AObasicStatementDo((yyvsp[-2].do_group_head_), (yyvsp[-1].ending_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6350 "Parser.c"
    break;

  case 335: /* BASIC_STATEMENT: READ_KEY _SYMB_17  */
#line 1069 "HAL_S.y"
                      { (yyval.basic_statement_) = make_APbasicStatementReadKey((yyvsp[-1].read_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6356 "Parser.c"
    break;

  case 336: /* BASIC_STATEMENT: READ_PHRASE _SYMB_17  */
#line 1070 "HAL_S.y"
                         { (yyval.basic_statement_) = make_AQbasicStatementReadPhrase((yyvsp[-1].read_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6362 "Parser.c"
    break;

  case 337: /* BASIC_STATEMENT: WRITE_KEY _SYMB_17  */
#line 1071 "HAL_S.y"
                       { (yyval.basic_statement_) = make_ARbasicStatementWriteKey((yyvsp[-1].write_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6368 "Parser.c"
    break;

  case 338: /* BASIC_STATEMENT: WRITE_PHRASE _SYMB_17  */
#line 1072 "HAL_S.y"
                          { (yyval.basic_statement_) = make_ASbasicStatementWritePhrase((yyvsp[-1].write_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6374 "Parser.c"
    break;

  case 339: /* BASIC_STATEMENT: FILE_EXP EQUALS EXPRESSION _SYMB_17  */
#line 1073 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_ATbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6380 "Parser.c"
    break;

  case 340: /* BASIC_STATEMENT: VARIABLE EQUALS FILE_EXP _SYMB_17  */
#line 1074 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AUbasicStatementFileExp((yyvsp[-3].variable_), (yyvsp[-2].equals_), (yyvsp[-1].file_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6386 "Parser.c"
    break;

  case 341: /* BASIC_STATEMENT: FILE_EXP EQUALS QUAL_STRUCT _SYMB_17  */
#line 1075 "HAL_S.y"
                                         { (yyval.basic_statement_) = make_AVbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].qual_struct_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6392 "Parser.c"
    break;

  case 342: /* BASIC_STATEMENT: WAIT_KEY _SYMB_86 _SYMB_66 _SYMB_17  */
#line 1076 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_AVbasicStatementWait((yyvsp[-3].wait_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6398 "Parser.c"
    break;

  case 343: /* BASIC_STATEMENT: WAIT_KEY ARITH_EXP _SYMB_17  */
#line 1077 "HAL_S.y"
                                { (yyval.basic_statement_) = make_AWbasicStatementWait((yyvsp[-2].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6404 "Parser.c"
    break;

  case 344: /* BASIC_STATEMENT: WAIT_KEY _SYMB_173 ARITH_EXP _SYMB_17  */
#line 1078 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_AXbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6410 "Parser.c"
    break;

  case 345: /* BASIC_STATEMENT: WAIT_KEY _SYMB_86 BIT_EXP _SYMB_17  */
#line 1079 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_AYbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].bit_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6416 "Parser.c"
    break;

  case 346: /* BASIC_STATEMENT: TERMINATOR _SYMB_17  */
#line 1080 "HAL_S.y"
                        { (yyval.basic_statement_) = make_AZbasicStatementTerminator((yyvsp[-1].terminator_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6422 "Parser.c"
    break;

  case 347: /* BASIC_STATEMENT: TERMINATOR TERMINATE_LIST _SYMB_17  */
#line 1081 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_BAbasicStatementTerminator((yyvsp[-2].terminator_), (yyvsp[-1].terminate_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6428 "Parser.c"
    break;

  case 348: /* BASIC_STATEMENT: _SYMB_174 _SYMB_120 _SYMB_166 ARITH_EXP _SYMB_17  */
#line 1082 "HAL_S.y"
                                                     { (yyval.basic_statement_) = make_BBbasicStatementUpdate((yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6434 "Parser.c"
    break;

  case 349: /* BASIC_STATEMENT: _SYMB_174 _SYMB_120 LABEL_VAR _SYMB_166 ARITH_EXP _SYMB_17  */
#line 1083 "HAL_S.y"
                                                               { (yyval.basic_statement_) = make_BCbasicStatementUpdate((yyvsp[-3].label_var_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6440 "Parser.c"
    break;

  case 350: /* BASIC_STATEMENT: SCHEDULE_PHRASE _SYMB_17  */
#line 1084 "HAL_S.y"
                             { (yyval.basic_statement_) = make_BDbasicStatementSchedule((yyvsp[-1].schedule_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6446 "Parser.c"
    break;

  case 351: /* BASIC_STATEMENT: SCHEDULE_PHRASE SCHEDULE_CONTROL _SYMB_17  */
#line 1085 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BEbasicStatementSchedule((yyvsp[-2].schedule_phrase_), (yyvsp[-1].schedule_control_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6452 "Parser.c"
    break;

  case 352: /* BASIC_STATEMENT: SIGNAL_CLAUSE _SYMB_17  */
#line 1086 "HAL_S.y"
                           { (yyval.basic_statement_) = make_BFbasicStatementSignal((yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6458 "Parser.c"
    break;

  case 353: /* BASIC_STATEMENT: _SYMB_141 _SYMB_76 SUBSCRIPT _SYMB_17  */
#line 1087 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BGbasicStatementSend((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6464 "Parser.c"
    break;

  case 354: /* BASIC_STATEMENT: _SYMB_141 _SYMB_76 _SYMB_17  */
#line 1088 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BHbasicStatementSend(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6470 "Parser.c"
    break;

  case 355: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_17  */
#line 1089 "HAL_S.y"
                       { (yyval.basic_statement_) = make_BHbasicStatementOn((yyvsp[-1].on_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6476 "Parser.c"
    break;

  case 356: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_32 SIGNAL_CLAUSE _SYMB_17  */
#line 1090 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BIbasicStatementOnAndSignal((yyvsp[-3].on_clause_), (yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6482 "Parser.c"
    break;

  case 357: /* BASIC_STATEMENT: _SYMB_115 _SYMB_76 SUBSCRIPT _SYMB_17  */
#line 1091 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BJbasicStatementOff((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6488 "Parser.c"
    break;

  case 358: /* BASIC_STATEMENT: _SYMB_115 _SYMB_76 _SYMB_17  */
#line 1092 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementOff(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6494 "Parser.c"
    break;

  case 359: /* BASIC_STATEMENT: PERCENT_MACRO_NAME _SYMB_17  */
#line 1093 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementPercentMacro((yyvsp[-1].percent_macro_name_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6500 "Parser.c"
    break;

  case 360: /* BASIC_STATEMENT: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_1 _SYMB_17  */
#line 1094 "HAL_S.y"
                                                          { (yyval.basic_statement_) = make_BLbasicStatementPercentMacro((yyvsp[-3].percent_macro_head_), (yyvsp[-2].percent_macro_arg_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6506 "Parser.c"
    break;

  case 361: /* OTHER_STATEMENT: IF_STATEMENT  */
#line 1096 "HAL_S.y"
                               { (yyval.other_statement_) = make_ABotherStatementIf((yyvsp[0].if_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6512 "Parser.c"
    break;

  case 362: /* OTHER_STATEMENT: ON_PHRASE STATEMENT  */
#line 1097 "HAL_S.y"
                        { (yyval.other_statement_) = make_AAotherStatementOn((yyvsp[-1].on_phrase_), (yyvsp[0].statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6518 "Parser.c"
    break;

  case 363: /* OTHER_STATEMENT: LABEL_DEFINITION OTHER_STATEMENT  */
#line 1098 "HAL_S.y"
                                     { (yyval.other_statement_) = make_ACother_statement((yyvsp[-1].label_definition_), (yyvsp[0].other_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6524 "Parser.c"
    break;

  case 364: /* IF_STATEMENT: IF_CLAUSE STATEMENT  */
#line 1100 "HAL_S.y"
                                   { (yyval.if_statement_) = make_AAifStatement((yyvsp[-1].if_clause_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 6530 "Parser.c"
    break;

  case 365: /* IF_STATEMENT: TRUE_PART STATEMENT  */
#line 1101 "HAL_S.y"
                        { (yyval.if_statement_) = make_ABifThenElseStatement((yyvsp[-1].true_part_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 6536 "Parser.c"
    break;

  case 366: /* IF_CLAUSE: IF RELATIONAL_EXP THEN  */
#line 1103 "HAL_S.y"
                                   { (yyval.if_clause_) = make_AAifClauseRelationalExp((yyvsp[-2].if_), (yyvsp[-1].relational_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 6542 "Parser.c"
    break;

  case 367: /* IF_CLAUSE: IF BIT_EXP THEN  */
#line 1104 "HAL_S.y"
                    { (yyval.if_clause_) = make_ABifClauseBitExp((yyvsp[-2].if_), (yyvsp[-1].bit_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 6548 "Parser.c"
    break;

  case 368: /* TRUE_PART: IF_CLAUSE BASIC_STATEMENT _SYMB_71  */
#line 1106 "HAL_S.y"
                                               { (yyval.true_part_) = make_AAtrue_part((yyvsp[-2].if_clause_), (yyvsp[-1].basic_statement_)); (yyval.true_part_)->line_number = (yyloc).first_line; (yyval.true_part_)->char_number = (yyloc).first_column;  }
#line 6554 "Parser.c"
    break;

  case 369: /* IF: _SYMB_90  */
#line 1108 "HAL_S.y"
              { (yyval.if_) = make_AAif(); (yyval.if_)->line_number = (yyloc).first_line; (yyval.if_)->char_number = (yyloc).first_column;  }
#line 6560 "Parser.c"
    break;

  case 370: /* THEN: _SYMB_165  */
#line 1110 "HAL_S.y"
                 { (yyval.then_) = make_AAthen(); (yyval.then_)->line_number = (yyloc).first_line; (yyval.then_)->char_number = (yyloc).first_column;  }
#line 6566 "Parser.c"
    break;

  case 371: /* RELATIONAL_EXP: RELATIONAL_FACTOR  */
#line 1112 "HAL_S.y"
                                   { (yyval.relational_exp_) = make_AArelational_exp((yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 6572 "Parser.c"
    break;

  case 372: /* RELATIONAL_EXP: RELATIONAL_EXP OR RELATIONAL_FACTOR  */
#line 1113 "HAL_S.y"
                                        { (yyval.relational_exp_) = make_ABrelational_expOR((yyvsp[-2].relational_exp_), (yyvsp[-1].or_), (yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 6578 "Parser.c"
    break;

  case 373: /* RELATIONAL_FACTOR: REL_PRIM  */
#line 1115 "HAL_S.y"
                             { (yyval.relational_factor_) = make_AArelational_factor((yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 6584 "Parser.c"
    break;

  case 374: /* RELATIONAL_FACTOR: RELATIONAL_FACTOR AND REL_PRIM  */
#line 1116 "HAL_S.y"
                                   { (yyval.relational_factor_) = make_ABrelational_factorAND((yyvsp[-2].relational_factor_), (yyvsp[-1].and_), (yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 6590 "Parser.c"
    break;

  case 375: /* REL_PRIM: _SYMB_2 RELATIONAL_EXP _SYMB_1  */
#line 1118 "HAL_S.y"
                                          { (yyval.rel_prim_) = make_AArel_prim((yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6596 "Parser.c"
    break;

  case 376: /* REL_PRIM: NOT _SYMB_2 RELATIONAL_EXP _SYMB_1  */
#line 1119 "HAL_S.y"
                                       { (yyval.rel_prim_) = make_ABrel_prim((yyvsp[-3].not_), (yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6602 "Parser.c"
    break;

  case 377: /* REL_PRIM: COMPARISON  */
#line 1120 "HAL_S.y"
               { (yyval.rel_prim_) = make_ACrel_prim((yyvsp[0].comparison_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6608 "Parser.c"
    break;

  case 378: /* COMPARISON: ARITH_EXP EQUALS ARITH_EXP  */
#line 1122 "HAL_S.y"
                                        { (yyval.comparison_) = make_AAcomparisonEQ((yyvsp[-2].arith_exp_), (yyvsp[-1].equals_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6614 "Parser.c"
    break;

  case 379: /* COMPARISON: CHAR_EXP EQUALS CHAR_EXP  */
#line 1123 "HAL_S.y"
                             { (yyval.comparison_) = make_ABcomparisonEQ((yyvsp[-2].char_exp_), (yyvsp[-1].equals_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6620 "Parser.c"
    break;

  case 380: /* COMPARISON: BIT_CAT EQUALS BIT_CAT  */
#line 1124 "HAL_S.y"
                           { (yyval.comparison_) = make_ACcomparisonEQ((yyvsp[-2].bit_cat_), (yyvsp[-1].equals_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6626 "Parser.c"
    break;

  case 381: /* COMPARISON: STRUCTURE_EXP EQUALS STRUCTURE_EXP  */
#line 1125 "HAL_S.y"
                                       { (yyval.comparison_) = make_ADcomparisonEQ((yyvsp[-2].structure_exp_), (yyvsp[-1].equals_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6632 "Parser.c"
    break;

  case 382: /* COMPARISON: NAME_EXP EQUALS NAME_EXP  */
#line 1126 "HAL_S.y"
                             { (yyval.comparison_) = make_AEcomparisonEQ((yyvsp[-2].name_exp_), (yyvsp[-1].equals_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6638 "Parser.c"
    break;

  case 383: /* COMPARISON: ARITH_EXP _SYMB_183 ARITH_EXP  */
#line 1127 "HAL_S.y"
                                  { (yyval.comparison_) = make_AAcomparisonNEQ((yyvsp[-2].arith_exp_), (yyvsp[-1].string_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6644 "Parser.c"
    break;

  case 384: /* COMPARISON: CHAR_EXP _SYMB_183 CHAR_EXP  */
#line 1128 "HAL_S.y"
                                { (yyval.comparison_) = make_ABcomparisonNEQ((yyvsp[-2].char_exp_), (yyvsp[-1].string_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6650 "Parser.c"
    break;

  case 385: /* COMPARISON: BIT_CAT _SYMB_183 BIT_CAT  */
#line 1129 "HAL_S.y"
                              { (yyval.comparison_) = make_ACcomparisonNEQ((yyvsp[-2].bit_cat_), (yyvsp[-1].string_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6656 "Parser.c"
    break;

  case 386: /* COMPARISON: STRUCTURE_EXP _SYMB_183 STRUCTURE_EXP  */
#line 1130 "HAL_S.y"
                                          { (yyval.comparison_) = make_ADcomparisonNEQ((yyvsp[-2].structure_exp_), (yyvsp[-1].string_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6662 "Parser.c"
    break;

  case 387: /* COMPARISON: NAME_EXP _SYMB_183 NAME_EXP  */
#line 1131 "HAL_S.y"
                                { (yyval.comparison_) = make_AEcomparisonNEQ((yyvsp[-2].name_exp_), (yyvsp[-1].string_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6668 "Parser.c"
    break;

  case 388: /* COMPARISON: ARITH_EXP _SYMB_23 ARITH_EXP  */
#line 1132 "HAL_S.y"
                                 { (yyval.comparison_) = make_AAcomparisonLT((yyvsp[-2].arith_exp_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6674 "Parser.c"
    break;

  case 389: /* COMPARISON: CHAR_EXP _SYMB_23 CHAR_EXP  */
#line 1133 "HAL_S.y"
                               { (yyval.comparison_) = make_ABcomparisonLT((yyvsp[-2].char_exp_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6680 "Parser.c"
    break;

  case 390: /* COMPARISON: BIT_CAT _SYMB_23 BIT_CAT  */
#line 1134 "HAL_S.y"
                             { (yyval.comparison_) = make_ACcomparisonLT((yyvsp[-2].bit_cat_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6686 "Parser.c"
    break;

  case 391: /* COMPARISON: STRUCTURE_EXP _SYMB_23 STRUCTURE_EXP  */
#line 1135 "HAL_S.y"
                                         { (yyval.comparison_) = make_ADcomparisonLT((yyvsp[-2].structure_exp_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6692 "Parser.c"
    break;

  case 392: /* COMPARISON: NAME_EXP _SYMB_23 NAME_EXP  */
#line 1136 "HAL_S.y"
                               { (yyval.comparison_) = make_AEcomparisonLT((yyvsp[-2].name_exp_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6698 "Parser.c"
    break;

  case 393: /* COMPARISON: ARITH_EXP _SYMB_25 ARITH_EXP  */
#line 1137 "HAL_S.y"
                                 { (yyval.comparison_) = make_AAcomparisonGT((yyvsp[-2].arith_exp_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6704 "Parser.c"
    break;

  case 394: /* COMPARISON: CHAR_EXP _SYMB_25 CHAR_EXP  */
#line 1138 "HAL_S.y"
                               { (yyval.comparison_) = make_ABcomparisonGT((yyvsp[-2].char_exp_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6710 "Parser.c"
    break;

  case 395: /* COMPARISON: BIT_CAT _SYMB_25 BIT_CAT  */
#line 1139 "HAL_S.y"
                             { (yyval.comparison_) = make_ACcomparisonGT((yyvsp[-2].bit_cat_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6716 "Parser.c"
    break;

  case 396: /* COMPARISON: STRUCTURE_EXP _SYMB_25 STRUCTURE_EXP  */
#line 1140 "HAL_S.y"
                                         { (yyval.comparison_) = make_ADcomparisonGT((yyvsp[-2].structure_exp_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6722 "Parser.c"
    break;

  case 397: /* COMPARISON: NAME_EXP _SYMB_25 NAME_EXP  */
#line 1141 "HAL_S.y"
                               { (yyval.comparison_) = make_AEcomparisonGT((yyvsp[-2].name_exp_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6728 "Parser.c"
    break;

  case 398: /* COMPARISON: ARITH_EXP _SYMB_184 ARITH_EXP  */
#line 1142 "HAL_S.y"
                                  { (yyval.comparison_) = make_AAcomparisonLE((yyvsp[-2].arith_exp_), (yyvsp[-1].string_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6734 "Parser.c"
    break;

  case 399: /* COMPARISON: CHAR_EXP _SYMB_184 CHAR_EXP  */
#line 1143 "HAL_S.y"
                                { (yyval.comparison_) = make_ABcomparisonLE((yyvsp[-2].char_exp_), (yyvsp[-1].string_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6740 "Parser.c"
    break;

  case 400: /* COMPARISON: BIT_CAT _SYMB_184 BIT_CAT  */
#line 1144 "HAL_S.y"
                              { (yyval.comparison_) = make_ACcomparisonLE((yyvsp[-2].bit_cat_), (yyvsp[-1].string_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6746 "Parser.c"
    break;

  case 401: /* COMPARISON: STRUCTURE_EXP _SYMB_184 STRUCTURE_EXP  */
#line 1145 "HAL_S.y"
                                          { (yyval.comparison_) = make_ADcomparisonLE((yyvsp[-2].structure_exp_), (yyvsp[-1].string_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6752 "Parser.c"
    break;

  case 402: /* COMPARISON: NAME_EXP _SYMB_184 NAME_EXP  */
#line 1146 "HAL_S.y"
                                { (yyval.comparison_) = make_AEcomparisonLE((yyvsp[-2].name_exp_), (yyvsp[-1].string_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6758 "Parser.c"
    break;

  case 403: /* COMPARISON: ARITH_EXP _SYMB_185 ARITH_EXP  */
#line 1147 "HAL_S.y"
                                  { (yyval.comparison_) = make_AAcomparisonGE((yyvsp[-2].arith_exp_), (yyvsp[-1].string_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6764 "Parser.c"
    break;

  case 404: /* COMPARISON: CHAR_EXP _SYMB_185 CHAR_EXP  */
#line 1148 "HAL_S.y"
                                { (yyval.comparison_) = make_ABcomparisonGE((yyvsp[-2].char_exp_), (yyvsp[-1].string_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6770 "Parser.c"
    break;

  case 405: /* COMPARISON: BIT_CAT _SYMB_185 BIT_CAT  */
#line 1149 "HAL_S.y"
                              { (yyval.comparison_) = make_ACcomparisonGE((yyvsp[-2].bit_cat_), (yyvsp[-1].string_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6776 "Parser.c"
    break;

  case 406: /* COMPARISON: STRUCTURE_EXP _SYMB_185 STRUCTURE_EXP  */
#line 1150 "HAL_S.y"
                                          { (yyval.comparison_) = make_ADcomparisonGE((yyvsp[-2].structure_exp_), (yyvsp[-1].string_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6782 "Parser.c"
    break;

  case 407: /* COMPARISON: NAME_EXP _SYMB_185 NAME_EXP  */
#line 1151 "HAL_S.y"
                                { (yyval.comparison_) = make_AEcomparisonGE((yyvsp[-2].name_exp_), (yyvsp[-1].string_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6788 "Parser.c"
    break;

  case 408: /* ANY_STATEMENT: STATEMENT  */
#line 1153 "HAL_S.y"
                          { (yyval.any_statement_) = make_AAany_statement((yyvsp[0].statement_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6794 "Parser.c"
    break;

  case 409: /* ANY_STATEMENT: BLOCK_DEFINITION  */
#line 1154 "HAL_S.y"
                     { (yyval.any_statement_) = make_ABany_statement((yyvsp[0].block_definition_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6800 "Parser.c"
    break;

  case 410: /* ON_PHRASE: _SYMB_116 _SYMB_76 SUBSCRIPT  */
#line 1156 "HAL_S.y"
                                         { (yyval.on_phrase_) = make_AAon_phrase((yyvsp[0].subscript_)); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6806 "Parser.c"
    break;

  case 411: /* ON_PHRASE: _SYMB_116 _SYMB_76  */
#line 1157 "HAL_S.y"
                       { (yyval.on_phrase_) = make_ACon_phrase(); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6812 "Parser.c"
    break;

  case 412: /* ON_CLAUSE: _SYMB_116 _SYMB_76 SUBSCRIPT _SYMB_158  */
#line 1159 "HAL_S.y"
                                                   { (yyval.on_clause_) = make_AAon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6818 "Parser.c"
    break;

  case 413: /* ON_CLAUSE: _SYMB_116 _SYMB_76 SUBSCRIPT _SYMB_91  */
#line 1160 "HAL_S.y"
                                          { (yyval.on_clause_) = make_ABon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6824 "Parser.c"
    break;

  case 414: /* ON_CLAUSE: _SYMB_116 _SYMB_76 _SYMB_158  */
#line 1161 "HAL_S.y"
                                 { (yyval.on_clause_) = make_ADon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6830 "Parser.c"
    break;

  case 415: /* ON_CLAUSE: _SYMB_116 _SYMB_76 _SYMB_91  */
#line 1162 "HAL_S.y"
                                { (yyval.on_clause_) = make_AEon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6836 "Parser.c"
    break;

  case 416: /* LABEL_DEFINITION: LABEL _SYMB_18  */
#line 1164 "HAL_S.y"
                                  { (yyval.label_definition_) = make_AAlabel_definition((yyvsp[-1].label_)); (yyval.label_definition_)->line_number = (yyloc).first_line; (yyval.label_definition_)->char_number = (yyloc).first_column;  }
#line 6842 "Parser.c"
    break;

  case 417: /* CALL_KEY: _SYMB_48 LABEL_VAR  */
#line 1166 "HAL_S.y"
                              { (yyval.call_key_) = make_AAcall_key((yyvsp[0].label_var_)); (yyval.call_key_)->line_number = (yyloc).first_line; (yyval.call_key_)->char_number = (yyloc).first_column;  }
#line 6848 "Parser.c"
    break;

  case 418: /* ASSIGN: _SYMB_41  */
#line 1168 "HAL_S.y"
                  { (yyval.assign_) = make_AAassign(); (yyval.assign_)->line_number = (yyloc).first_line; (yyval.assign_)->char_number = (yyloc).first_column;  }
#line 6854 "Parser.c"
    break;

  case 419: /* CALL_ASSIGN_LIST: VARIABLE  */
#line 1170 "HAL_S.y"
                            { (yyval.call_assign_list_) = make_AAcall_assign_list((yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6860 "Parser.c"
    break;

  case 420: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_0 VARIABLE  */
#line 1171 "HAL_S.y"
                                      { (yyval.call_assign_list_) = make_ABcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6866 "Parser.c"
    break;

  case 421: /* CALL_ASSIGN_LIST: QUAL_STRUCT  */
#line 1172 "HAL_S.y"
                { (yyval.call_assign_list_) = make_ACcall_assign_list((yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6872 "Parser.c"
    break;

  case 422: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_0 QUAL_STRUCT  */
#line 1173 "HAL_S.y"
                                         { (yyval.call_assign_list_) = make_ADcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6878 "Parser.c"
    break;

  case 423: /* DO_GROUP_HEAD: _SYMB_69 _SYMB_17  */
#line 1175 "HAL_S.y"
                                  { (yyval.do_group_head_) = make_AAdoGroupHead(); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6884 "Parser.c"
    break;

  case 424: /* DO_GROUP_HEAD: _SYMB_69 FOR_LIST _SYMB_17  */
#line 1176 "HAL_S.y"
                               { (yyval.do_group_head_) = make_ABdoGroupHeadFor((yyvsp[-1].for_list_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6890 "Parser.c"
    break;

  case 425: /* DO_GROUP_HEAD: _SYMB_69 FOR_LIST WHILE_CLAUSE _SYMB_17  */
#line 1177 "HAL_S.y"
                                            { (yyval.do_group_head_) = make_ACdoGroupHeadForWhile((yyvsp[-2].for_list_), (yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6896 "Parser.c"
    break;

  case 426: /* DO_GROUP_HEAD: _SYMB_69 WHILE_CLAUSE _SYMB_17  */
#line 1178 "HAL_S.y"
                                   { (yyval.do_group_head_) = make_ADdoGroupHeadWhile((yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6902 "Parser.c"
    break;

  case 427: /* DO_GROUP_HEAD: _SYMB_69 _SYMB_50 ARITH_EXP _SYMB_17  */
#line 1179 "HAL_S.y"
                                         { (yyval.do_group_head_) = make_AEdoGroupHeadCase((yyvsp[-1].arith_exp_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6908 "Parser.c"
    break;

  case 428: /* DO_GROUP_HEAD: CASE_ELSE STATEMENT  */
#line 1180 "HAL_S.y"
                        { (yyval.do_group_head_) = make_AFdoGroupHeadCaseElse((yyvsp[-1].case_else_), (yyvsp[0].statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6914 "Parser.c"
    break;

  case 429: /* DO_GROUP_HEAD: DO_GROUP_HEAD ANY_STATEMENT  */
#line 1181 "HAL_S.y"
                                { (yyval.do_group_head_) = make_AGdoGroupHeadStatement((yyvsp[-1].do_group_head_), (yyvsp[0].any_statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6920 "Parser.c"
    break;

  case 430: /* DO_GROUP_HEAD: DO_GROUP_HEAD TEMPORARY_STMT  */
#line 1182 "HAL_S.y"
                                 { (yyval.do_group_head_) = make_AHdoGroupHeadTemporaryStatement((yyvsp[-1].do_group_head_), (yyvsp[0].temporary_stmt_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6926 "Parser.c"
    break;

  case 431: /* ENDING: _SYMB_72  */
#line 1184 "HAL_S.y"
                  { (yyval.ending_) = make_AAending(); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6932 "Parser.c"
    break;

  case 432: /* ENDING: _SYMB_72 LABEL  */
#line 1185 "HAL_S.y"
                   { (yyval.ending_) = make_ABending((yyvsp[0].label_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6938 "Parser.c"
    break;

  case 433: /* ENDING: LABEL_DEFINITION ENDING  */
#line 1186 "HAL_S.y"
                            { (yyval.ending_) = make_ACending((yyvsp[-1].label_definition_), (yyvsp[0].ending_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6944 "Parser.c"
    break;

  case 434: /* READ_KEY: _SYMB_126 _SYMB_2 NUMBER _SYMB_1  */
#line 1188 "HAL_S.y"
                                            { (yyval.read_key_) = make_AAread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 6950 "Parser.c"
    break;

  case 435: /* READ_KEY: _SYMB_127 _SYMB_2 NUMBER _SYMB_1  */
#line 1189 "HAL_S.y"
                                     { (yyval.read_key_) = make_ABread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 6956 "Parser.c"
    break;

  case 436: /* WRITE_KEY: _SYMB_178 _SYMB_2 NUMBER _SYMB_1  */
#line 1191 "HAL_S.y"
                                             { (yyval.write_key_) = make_AAwrite_key((yyvsp[-1].number_)); (yyval.write_key_)->line_number = (yyloc).first_line; (yyval.write_key_)->char_number = (yyloc).first_column;  }
#line 6962 "Parser.c"
    break;

  case 437: /* READ_PHRASE: READ_KEY READ_ARG  */
#line 1193 "HAL_S.y"
                                { (yyval.read_phrase_) = make_AAread_phrase((yyvsp[-1].read_key_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 6968 "Parser.c"
    break;

  case 438: /* READ_PHRASE: READ_PHRASE _SYMB_0 READ_ARG  */
#line 1194 "HAL_S.y"
                                 { (yyval.read_phrase_) = make_ABread_phrase((yyvsp[-2].read_phrase_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 6974 "Parser.c"
    break;

  case 439: /* WRITE_PHRASE: WRITE_KEY WRITE_ARG  */
#line 1196 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_AAwrite_phrase((yyvsp[-1].write_key_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 6980 "Parser.c"
    break;

  case 440: /* WRITE_PHRASE: WRITE_PHRASE _SYMB_0 WRITE_ARG  */
#line 1197 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_ABwrite_phrase((yyvsp[-2].write_phrase_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 6986 "Parser.c"
    break;

  case 441: /* READ_ARG: VARIABLE  */
#line 1199 "HAL_S.y"
                    { (yyval.read_arg_) = make_AAread_arg((yyvsp[0].variable_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 6992 "Parser.c"
    break;

  case 442: /* READ_ARG: IO_CONTROL  */
#line 1200 "HAL_S.y"
               { (yyval.read_arg_) = make_ABread_arg((yyvsp[0].io_control_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 6998 "Parser.c"
    break;

  case 443: /* WRITE_ARG: EXPRESSION  */
#line 1202 "HAL_S.y"
                       { (yyval.write_arg_) = make_AAwrite_arg((yyvsp[0].expression_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 7004 "Parser.c"
    break;

  case 444: /* WRITE_ARG: IO_CONTROL  */
#line 1203 "HAL_S.y"
               { (yyval.write_arg_) = make_ABwrite_arg((yyvsp[0].io_control_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 7010 "Parser.c"
    break;

  case 445: /* WRITE_ARG: _SYMB_190  */
#line 1204 "HAL_S.y"
              { (yyval.write_arg_) = make_ACwrite_arg((yyvsp[0].string_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 7016 "Parser.c"
    break;

  case 446: /* FILE_EXP: FILE_HEAD _SYMB_0 ARITH_EXP _SYMB_1  */
#line 1206 "HAL_S.y"
                                               { (yyval.file_exp_) = make_AAfile_exp((yyvsp[-3].file_head_), (yyvsp[-1].arith_exp_)); (yyval.file_exp_)->line_number = (yyloc).first_line; (yyval.file_exp_)->char_number = (yyloc).first_column;  }
#line 7022 "Parser.c"
    break;

  case 447: /* FILE_HEAD: _SYMB_84 _SYMB_2 NUMBER  */
#line 1208 "HAL_S.y"
                                    { (yyval.file_head_) = make_AAfile_head((yyvsp[0].number_)); (yyval.file_head_)->line_number = (yyloc).first_line; (yyval.file_head_)->char_number = (yyloc).first_column;  }
#line 7028 "Parser.c"
    break;

  case 448: /* IO_CONTROL: _SYMB_152 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1210 "HAL_S.y"
                                                 { (yyval.io_control_) = make_AAioControlSkip((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 7034 "Parser.c"
    break;

  case 449: /* IO_CONTROL: _SYMB_159 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1211 "HAL_S.y"
                                        { (yyval.io_control_) = make_ABioControlTab((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 7040 "Parser.c"
    break;

  case 450: /* IO_CONTROL: _SYMB_57 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1212 "HAL_S.y"
                                       { (yyval.io_control_) = make_ACioControlColumn((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 7046 "Parser.c"
    break;

  case 451: /* IO_CONTROL: _SYMB_99 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1213 "HAL_S.y"
                                       { (yyval.io_control_) = make_ADioControlLine((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 7052 "Parser.c"
    break;

  case 452: /* IO_CONTROL: _SYMB_118 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1214 "HAL_S.y"
                                        { (yyval.io_control_) = make_AEioControlPage((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 7058 "Parser.c"
    break;

  case 453: /* WAIT_KEY: _SYMB_176  */
#line 1216 "HAL_S.y"
                     { (yyval.wait_key_) = make_AAwait_key(); (yyval.wait_key_)->line_number = (yyloc).first_line; (yyval.wait_key_)->char_number = (yyloc).first_column;  }
#line 7064 "Parser.c"
    break;

  case 454: /* TERMINATOR: _SYMB_164  */
#line 1218 "HAL_S.y"
                       { (yyval.terminator_) = make_AAterminatorTerminate(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 7070 "Parser.c"
    break;

  case 455: /* TERMINATOR: _SYMB_49  */
#line 1219 "HAL_S.y"
             { (yyval.terminator_) = make_ABterminatorCancel(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 7076 "Parser.c"
    break;

  case 456: /* TERMINATE_LIST: LABEL_VAR  */
#line 1221 "HAL_S.y"
                           { (yyval.terminate_list_) = make_AAterminate_list((yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 7082 "Parser.c"
    break;

  case 457: /* TERMINATE_LIST: TERMINATE_LIST _SYMB_0 LABEL_VAR  */
#line 1222 "HAL_S.y"
                                     { (yyval.terminate_list_) = make_ABterminate_list((yyvsp[-2].terminate_list_), (yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 7088 "Parser.c"
    break;

  case 458: /* SCHEDULE_HEAD: _SYMB_140 LABEL_VAR  */
#line 1224 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_AAscheduleHeadLabel((yyvsp[0].label_var_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 7094 "Parser.c"
    break;

  case 459: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_42 ARITH_EXP  */
#line 1225 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ABscheduleHeadAt((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 7100 "Parser.c"
    break;

  case 460: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_92 ARITH_EXP  */
#line 1226 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ACscheduleHeadIn((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 7106 "Parser.c"
    break;

  case 461: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_116 BIT_EXP  */
#line 1227 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_ADscheduleHeadOn((yyvsp[-2].schedule_head_), (yyvsp[0].bit_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 7112 "Parser.c"
    break;

  case 462: /* SCHEDULE_PHRASE: SCHEDULE_HEAD  */
#line 1229 "HAL_S.y"
                                { (yyval.schedule_phrase_) = make_AAschedule_phrase((yyvsp[0].schedule_head_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 7118 "Parser.c"
    break;

  case 463: /* SCHEDULE_PHRASE: SCHEDULE_HEAD _SYMB_120 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1230 "HAL_S.y"
                                                      { (yyval.schedule_phrase_) = make_ABschedule_phrase((yyvsp[-4].schedule_head_), (yyvsp[-1].arith_exp_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 7124 "Parser.c"
    break;

  case 464: /* SCHEDULE_PHRASE: SCHEDULE_PHRASE _SYMB_66  */
#line 1231 "HAL_S.y"
                             { (yyval.schedule_phrase_) = make_ACschedule_phrase((yyvsp[-1].schedule_phrase_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 7130 "Parser.c"
    break;

  case 465: /* SCHEDULE_CONTROL: STOPPING  */
#line 1233 "HAL_S.y"
                            { (yyval.schedule_control_) = make_AAschedule_control((yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 7136 "Parser.c"
    break;

  case 466: /* SCHEDULE_CONTROL: TIMING  */
#line 1234 "HAL_S.y"
           { (yyval.schedule_control_) = make_ABschedule_control((yyvsp[0].timing_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 7142 "Parser.c"
    break;

  case 467: /* SCHEDULE_CONTROL: TIMING STOPPING  */
#line 1235 "HAL_S.y"
                    { (yyval.schedule_control_) = make_ACschedule_control((yyvsp[-1].timing_), (yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 7148 "Parser.c"
    break;

  case 468: /* TIMING: REPEAT _SYMB_78 ARITH_EXP  */
#line 1237 "HAL_S.y"
                                   { (yyval.timing_) = make_AAtimingEvery((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 7154 "Parser.c"
    break;

  case 469: /* TIMING: REPEAT _SYMB_30 ARITH_EXP  */
#line 1238 "HAL_S.y"
                              { (yyval.timing_) = make_ABtimingAfter((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 7160 "Parser.c"
    break;

  case 470: /* TIMING: REPEAT  */
#line 1239 "HAL_S.y"
           { (yyval.timing_) = make_ACtiming((yyvsp[0].repeat_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 7166 "Parser.c"
    break;

  case 471: /* REPEAT: _SYMB_0 _SYMB_131  */
#line 1241 "HAL_S.y"
                           { (yyval.repeat_) = make_AArepeat(); (yyval.repeat_)->line_number = (yyloc).first_line; (yyval.repeat_)->char_number = (yyloc).first_column;  }
#line 7172 "Parser.c"
    break;

  case 472: /* STOPPING: WHILE_KEY ARITH_EXP  */
#line 1243 "HAL_S.y"
                               { (yyval.stopping_) = make_AAstopping((yyvsp[-1].while_key_), (yyvsp[0].arith_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 7178 "Parser.c"
    break;

  case 473: /* STOPPING: WHILE_KEY BIT_EXP  */
#line 1244 "HAL_S.y"
                      { (yyval.stopping_) = make_ABstopping((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 7184 "Parser.c"
    break;

  case 474: /* SIGNAL_CLAUSE: _SYMB_142 EVENT_VAR  */
#line 1246 "HAL_S.y"
                                    { (yyval.signal_clause_) = make_AAsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 7190 "Parser.c"
    break;

  case 475: /* SIGNAL_CLAUSE: _SYMB_133 EVENT_VAR  */
#line 1247 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ABsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 7196 "Parser.c"
    break;

  case 476: /* SIGNAL_CLAUSE: _SYMB_146 EVENT_VAR  */
#line 1248 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ACsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 7202 "Parser.c"
    break;

  case 477: /* PERCENT_MACRO_NAME: _SYMB_26 IDENTIFIER  */
#line 1250 "HAL_S.y"
                                         { (yyval.percent_macro_name_) = make_FNpercent_macro_name((yyvsp[0].identifier_)); (yyval.percent_macro_name_)->line_number = (yyloc).first_line; (yyval.percent_macro_name_)->char_number = (yyloc).first_column;  }
#line 7208 "Parser.c"
    break;

  case 478: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_NAME _SYMB_2  */
#line 1252 "HAL_S.y"
                                                { (yyval.percent_macro_head_) = make_AApercent_macro_head((yyvsp[-1].percent_macro_name_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 7214 "Parser.c"
    break;

  case 479: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_0  */
#line 1253 "HAL_S.y"
                                                 { (yyval.percent_macro_head_) = make_ABpercent_macro_head((yyvsp[-2].percent_macro_head_), (yyvsp[-1].percent_macro_arg_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 7220 "Parser.c"
    break;

  case 480: /* PERCENT_MACRO_ARG: NAME_VAR  */
#line 1255 "HAL_S.y"
                             { (yyval.percent_macro_arg_) = make_AApercent_macro_arg((yyvsp[0].name_var_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 7226 "Parser.c"
    break;

  case 481: /* PERCENT_MACRO_ARG: CONSTANT  */
#line 1256 "HAL_S.y"
             { (yyval.percent_macro_arg_) = make_ABpercent_macro_arg((yyvsp[0].constant_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 7232 "Parser.c"
    break;

  case 482: /* CASE_ELSE: _SYMB_69 _SYMB_50 ARITH_EXP _SYMB_17 _SYMB_71  */
#line 1258 "HAL_S.y"
                                                          { (yyval.case_else_) = make_AAcase_else((yyvsp[-2].arith_exp_)); (yyval.case_else_)->line_number = (yyloc).first_line; (yyval.case_else_)->char_number = (yyloc).first_column;  }
#line 7238 "Parser.c"
    break;

  case 483: /* WHILE_KEY: _SYMB_177  */
#line 1260 "HAL_S.y"
                      { (yyval.while_key_) = make_AAwhileKeyWhile(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 7244 "Parser.c"
    break;

  case 484: /* WHILE_KEY: _SYMB_173  */
#line 1261 "HAL_S.y"
              { (yyval.while_key_) = make_ABwhileKeyUntil(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 7250 "Parser.c"
    break;

  case 485: /* WHILE_CLAUSE: WHILE_KEY BIT_EXP  */
#line 1263 "HAL_S.y"
                                 { (yyval.while_clause_) = make_AAwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 7256 "Parser.c"
    break;

  case 486: /* WHILE_CLAUSE: WHILE_KEY RELATIONAL_EXP  */
#line 1264 "HAL_S.y"
                             { (yyval.while_clause_) = make_ABwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].relational_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 7262 "Parser.c"
    break;

  case 487: /* FOR_LIST: FOR_KEY ARITH_EXP ITERATION_CONTROL  */
#line 1266 "HAL_S.y"
                                               { (yyval.for_list_) = make_AAfor_list((yyvsp[-2].for_key_), (yyvsp[-1].arith_exp_), (yyvsp[0].iteration_control_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 7268 "Parser.c"
    break;

  case 488: /* FOR_LIST: FOR_KEY ITERATION_BODY  */
#line 1267 "HAL_S.y"
                           { (yyval.for_list_) = make_ABfor_list((yyvsp[-1].for_key_), (yyvsp[0].iteration_body_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 7274 "Parser.c"
    break;

  case 489: /* ITERATION_BODY: ARITH_EXP  */
#line 1269 "HAL_S.y"
                           { (yyval.iteration_body_) = make_AAiteration_body((yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 7280 "Parser.c"
    break;

  case 490: /* ITERATION_BODY: ITERATION_BODY _SYMB_0 ARITH_EXP  */
#line 1270 "HAL_S.y"
                                     { (yyval.iteration_body_) = make_ABiteration_body((yyvsp[-2].iteration_body_), (yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 7286 "Parser.c"
    break;

  case 491: /* ITERATION_CONTROL: _SYMB_166 ARITH_EXP  */
#line 1272 "HAL_S.y"
                                        { (yyval.iteration_control_) = make_AAiteration_controlTo((yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 7292 "Parser.c"
    break;

  case 492: /* ITERATION_CONTROL: _SYMB_166 ARITH_EXP _SYMB_47 ARITH_EXP  */
#line 1273 "HAL_S.y"
                                           { (yyval.iteration_control_) = make_ABiteration_controlToBy((yyvsp[-2].arith_exp_), (yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 7298 "Parser.c"
    break;

  case 493: /* FOR_KEY: _SYMB_86 ARITH_VAR EQUALS  */
#line 1275 "HAL_S.y"
                                    { (yyval.for_key_) = make_AAforKey((yyvsp[-1].arith_var_), (yyvsp[0].equals_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 7304 "Parser.c"
    break;

  case 494: /* FOR_KEY: _SYMB_86 _SYMB_163 IDENTIFIER _SYMB_24  */
#line 1276 "HAL_S.y"
                                           { (yyval.for_key_) = make_ABforKeyTemporary((yyvsp[-1].identifier_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 7310 "Parser.c"
    break;

  case 495: /* TEMPORARY_STMT: _SYMB_163 DECLARE_BODY _SYMB_17  */
#line 1278 "HAL_S.y"
                                                 { (yyval.temporary_stmt_) = make_AAtemporary_stmt((yyvsp[-1].declare_body_)); (yyval.temporary_stmt_)->line_number = (yyloc).first_line; (yyval.temporary_stmt_)->char_number = (yyloc).first_column;  }
#line 7316 "Parser.c"
    break;

  case 496: /* CONSTANT: NUMBER  */
#line 1280 "HAL_S.y"
                  { (yyval.constant_) = make_AAconstant((yyvsp[0].number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 7322 "Parser.c"
    break;

  case 497: /* CONSTANT: COMPOUND_NUMBER  */
#line 1281 "HAL_S.y"
                    { (yyval.constant_) = make_ABconstant((yyvsp[0].compound_number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 7328 "Parser.c"
    break;

  case 498: /* CONSTANT: BIT_CONST  */
#line 1282 "HAL_S.y"
              { (yyval.constant_) = make_ACconstant((yyvsp[0].bit_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 7334 "Parser.c"
    break;

  case 499: /* CONSTANT: CHAR_CONST  */
#line 1283 "HAL_S.y"
               { (yyval.constant_) = make_ADconstant((yyvsp[0].char_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 7340 "Parser.c"
    break;

  case 500: /* ARRAY_HEAD: _SYMB_40 _SYMB_2  */
#line 1285 "HAL_S.y"
                              { (yyval.array_head_) = make_AAarray_head(); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 7346 "Parser.c"
    break;

  case 501: /* ARRAY_HEAD: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_0  */
#line 1286 "HAL_S.y"
                                           { (yyval.array_head_) = make_ABarray_head((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 7352 "Parser.c"
    break;

  case 502: /* MINOR_ATTR_LIST: MINOR_ATTRIBUTE  */
#line 1288 "HAL_S.y"
                                  { (yyval.minor_attr_list_) = make_AAminor_attr_list((yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 7358 "Parser.c"
    break;

  case 503: /* MINOR_ATTR_LIST: MINOR_ATTR_LIST MINOR_ATTRIBUTE  */
#line 1289 "HAL_S.y"
                                    { (yyval.minor_attr_list_) = make_ABminor_attr_list((yyvsp[-1].minor_attr_list_), (yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 7364 "Parser.c"
    break;

  case 504: /* MINOR_ATTRIBUTE: _SYMB_154  */
#line 1291 "HAL_S.y"
                            { (yyval.minor_attribute_) = make_AAminorAttributeStatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7370 "Parser.c"
    break;

  case 505: /* MINOR_ATTRIBUTE: _SYMB_43  */
#line 1292 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ABminorAttributeAutomatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7376 "Parser.c"
    break;

  case 506: /* MINOR_ATTRIBUTE: _SYMB_65  */
#line 1293 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ACminorAttributeDense(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7382 "Parser.c"
    break;

  case 507: /* MINOR_ATTRIBUTE: _SYMB_31  */
#line 1294 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ADminorAttributeAligned(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7388 "Parser.c"
    break;

  case 508: /* MINOR_ATTRIBUTE: _SYMB_29  */
#line 1295 "HAL_S.y"
             { (yyval.minor_attribute_) = make_AEminorAttributeAccess(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7394 "Parser.c"
    break;

  case 509: /* MINOR_ATTRIBUTE: _SYMB_101 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1296 "HAL_S.y"
                                                  { (yyval.minor_attribute_) = make_AFminorAttributeLock((yyvsp[-1].literal_exp_or_star_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7400 "Parser.c"
    break;

  case 510: /* MINOR_ATTRIBUTE: _SYMB_130  */
#line 1297 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AGminorAttributeRemote(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7406 "Parser.c"
    break;

  case 511: /* MINOR_ATTRIBUTE: _SYMB_135  */
#line 1298 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AHminorAttributeRigid(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7412 "Parser.c"
    break;

  case 512: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_1  */
#line 1299 "HAL_S.y"
                                                 { (yyval.minor_attribute_) = make_AIminorAttributeRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7418 "Parser.c"
    break;

  case 513: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD _SYMB_6 _SYMB_1  */
#line 1300 "HAL_S.y"
                                       { (yyval.minor_attribute_) = make_AJminorAttributeStar((yyvsp[-2].init_or_const_head_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7424 "Parser.c"
    break;

  case 514: /* MINOR_ATTRIBUTE: _SYMB_97  */
#line 1301 "HAL_S.y"
             { (yyval.minor_attribute_) = make_AKminorAttributeLatched(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7430 "Parser.c"
    break;

  case 515: /* MINOR_ATTRIBUTE: _SYMB_110 _SYMB_2 LEVEL _SYMB_1  */
#line 1302 "HAL_S.y"
                                    { (yyval.minor_attribute_) = make_ALminorAttributeNonHal((yyvsp[-1].level_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7436 "Parser.c"
    break;

  case 516: /* INIT_OR_CONST_HEAD: _SYMB_94 _SYMB_2  */
#line 1304 "HAL_S.y"
                                      { (yyval.init_or_const_head_) = make_AAinit_or_const_headInitial(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7442 "Parser.c"
    break;

  case 517: /* INIT_OR_CONST_HEAD: _SYMB_59 _SYMB_2  */
#line 1305 "HAL_S.y"
                     { (yyval.init_or_const_head_) = make_ABinit_or_const_headConstant(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7448 "Parser.c"
    break;

  case 518: /* INIT_OR_CONST_HEAD: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_0  */
#line 1306 "HAL_S.y"
                                                 { (yyval.init_or_const_head_) = make_ACinit_or_const_headRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7454 "Parser.c"
    break;

  case 519: /* REPEATED_CONSTANT: EXPRESSION  */
#line 1308 "HAL_S.y"
                               { (yyval.repeated_constant_) = make_AArepeated_constant((yyvsp[0].expression_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7460 "Parser.c"
    break;

  case 520: /* REPEATED_CONSTANT: REPEAT_HEAD VARIABLE  */
#line 1309 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ABrepeated_constantMark((yyvsp[-1].repeat_head_), (yyvsp[0].variable_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7466 "Parser.c"
    break;

  case 521: /* REPEATED_CONSTANT: REPEAT_HEAD CONSTANT  */
#line 1310 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ACrepeated_constantMark((yyvsp[-1].repeat_head_), (yyvsp[0].constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7472 "Parser.c"
    break;

  case 522: /* REPEATED_CONSTANT: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_1  */
#line 1311 "HAL_S.y"
                                                 { (yyval.repeated_constant_) = make_ADrepeated_constantMark((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7478 "Parser.c"
    break;

  case 523: /* REPEATED_CONSTANT: REPEAT_HEAD  */
#line 1312 "HAL_S.y"
                { (yyval.repeated_constant_) = make_AErepeated_constantMark((yyvsp[0].repeat_head_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7484 "Parser.c"
    break;

  case 524: /* REPEAT_HEAD: ARITH_EXP _SYMB_10  */
#line 1314 "HAL_S.y"
                                 { (yyval.repeat_head_) = make_AArepeat_head((yyvsp[-1].arith_exp_)); (yyval.repeat_head_)->line_number = (yyloc).first_line; (yyval.repeat_head_)->char_number = (yyloc).first_column;  }
#line 7490 "Parser.c"
    break;

  case 525: /* NESTED_REPEAT_HEAD: REPEAT_HEAD _SYMB_2  */
#line 1316 "HAL_S.y"
                                         { (yyval.nested_repeat_head_) = make_AAnested_repeat_head((yyvsp[-1].repeat_head_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 7496 "Parser.c"
    break;

  case 526: /* NESTED_REPEAT_HEAD: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_0  */
#line 1317 "HAL_S.y"
                                                 { (yyval.nested_repeat_head_) = make_ABnested_repeat_head((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 7502 "Parser.c"
    break;

  case 527: /* DCL_LIST_COMMA: DECLARATION_LIST _SYMB_0  */
#line 1319 "HAL_S.y"
                                          { (yyval.dcl_list_comma_) = make_AAdcl_list_comma((yyvsp[-1].declaration_list_)); (yyval.dcl_list_comma_)->line_number = (yyloc).first_line; (yyval.dcl_list_comma_)->char_number = (yyloc).first_column;  }
#line 7508 "Parser.c"
    break;

  case 528: /* LITERAL_EXP_OR_STAR: ARITH_EXP  */
#line 1321 "HAL_S.y"
                                { (yyval.literal_exp_or_star_) = make_AAliteralExp((yyvsp[0].arith_exp_)); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7514 "Parser.c"
    break;

  case 529: /* LITERAL_EXP_OR_STAR: _SYMB_6  */
#line 1322 "HAL_S.y"
            { (yyval.literal_exp_or_star_) = make_ABliteralStar(); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7520 "Parser.c"
    break;

  case 530: /* TYPE_SPEC: STRUCT_SPEC  */
#line 1324 "HAL_S.y"
                        { (yyval.type_spec_) = make_AAtypeSpecStruct((yyvsp[0].struct_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7526 "Parser.c"
    break;

  case 531: /* TYPE_SPEC: BIT_SPEC  */
#line 1325 "HAL_S.y"
             { (yyval.type_spec_) = make_ABtypeSpecBit((yyvsp[0].bit_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7532 "Parser.c"
    break;

  case 532: /* TYPE_SPEC: CHAR_SPEC  */
#line 1326 "HAL_S.y"
              { (yyval.type_spec_) = make_ACtypeSpecChar((yyvsp[0].char_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7538 "Parser.c"
    break;

  case 533: /* TYPE_SPEC: ARITH_SPEC  */
#line 1327 "HAL_S.y"
               { (yyval.type_spec_) = make_ADtypeSpecArith((yyvsp[0].arith_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7544 "Parser.c"
    break;

  case 534: /* TYPE_SPEC: _SYMB_77  */
#line 1328 "HAL_S.y"
             { (yyval.type_spec_) = make_AEtypeSpecEvent(); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7550 "Parser.c"
    break;

  case 535: /* BIT_SPEC: _SYMB_46  */
#line 1330 "HAL_S.y"
                    { (yyval.bit_spec_) = make_AAbitSpecBoolean(); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7556 "Parser.c"
    break;

  case 536: /* BIT_SPEC: _SYMB_45 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1331 "HAL_S.y"
                                                 { (yyval.bit_spec_) = make_ABbitSpecBoolean((yyvsp[-1].literal_exp_or_star_)); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7562 "Parser.c"
    break;

  case 537: /* CHAR_SPEC: _SYMB_54 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1333 "HAL_S.y"
                                                         { (yyval.char_spec_) = make_AAchar_spec((yyvsp[-1].literal_exp_or_star_)); (yyval.char_spec_)->line_number = (yyloc).first_line; (yyval.char_spec_)->char_number = (yyloc).first_column;  }
#line 7568 "Parser.c"
    break;

  case 538: /* STRUCT_SPEC: STRUCT_TEMPLATE STRUCT_SPEC_BODY  */
#line 1335 "HAL_S.y"
                                               { (yyval.struct_spec_) = make_AAstruct_spec((yyvsp[-1].struct_template_), (yyvsp[0].struct_spec_body_)); (yyval.struct_spec_)->line_number = (yyloc).first_line; (yyval.struct_spec_)->char_number = (yyloc).first_column;  }
#line 7574 "Parser.c"
    break;

  case 539: /* STRUCT_SPEC_BODY: _SYMB_5 _SYMB_155  */
#line 1337 "HAL_S.y"
                                     { (yyval.struct_spec_body_) = make_AAstruct_spec_body(); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7580 "Parser.c"
    break;

  case 540: /* STRUCT_SPEC_BODY: STRUCT_SPEC_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1338 "HAL_S.y"
                                                 { (yyval.struct_spec_body_) = make_ABstruct_spec_body((yyvsp[-2].struct_spec_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7586 "Parser.c"
    break;

  case 541: /* STRUCT_TEMPLATE: STRUCTURE_ID  */
#line 1340 "HAL_S.y"
                               { (yyval.struct_template_) = make_FMstruct_template((yyvsp[0].structure_id_)); (yyval.struct_template_)->line_number = (yyloc).first_line; (yyval.struct_template_)->char_number = (yyloc).first_column;  }
#line 7592 "Parser.c"
    break;

  case 542: /* STRUCT_SPEC_HEAD: _SYMB_5 _SYMB_155 _SYMB_2  */
#line 1342 "HAL_S.y"
                                             { (yyval.struct_spec_head_) = make_AAstruct_spec_head(); (yyval.struct_spec_head_)->line_number = (yyloc).first_line; (yyval.struct_spec_head_)->char_number = (yyloc).first_column;  }
#line 7598 "Parser.c"
    break;

  case 543: /* ARITH_SPEC: PREC_SPEC  */
#line 1344 "HAL_S.y"
                       { (yyval.arith_spec_) = make_AAarith_spec((yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7604 "Parser.c"
    break;

  case 544: /* ARITH_SPEC: SQ_DQ_NAME  */
#line 1345 "HAL_S.y"
               { (yyval.arith_spec_) = make_ABarith_spec((yyvsp[0].sq_dq_name_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7610 "Parser.c"
    break;

  case 545: /* ARITH_SPEC: SQ_DQ_NAME PREC_SPEC  */
#line 1346 "HAL_S.y"
                         { (yyval.arith_spec_) = make_ACarith_spec((yyvsp[-1].sq_dq_name_), (yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7616 "Parser.c"
    break;

  case 546: /* COMPILATION: ANY_STATEMENT  */
#line 1348 "HAL_S.y"
                            { (yyval.compilation_) = make_AAcompilation((yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7622 "Parser.c"
    break;

  case 547: /* COMPILATION: COMPILATION ANY_STATEMENT  */
#line 1349 "HAL_S.y"
                              { (yyval.compilation_) = make_ABcompilation((yyvsp[-1].compilation_), (yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7628 "Parser.c"
    break;

  case 548: /* COMPILATION: DECLARE_STATEMENT  */
#line 1350 "HAL_S.y"
                      { (yyval.compilation_) = make_ACcompilation((yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7634 "Parser.c"
    break;

  case 549: /* COMPILATION: COMPILATION DECLARE_STATEMENT  */
#line 1351 "HAL_S.y"
                                  { (yyval.compilation_) = make_ADcompilation((yyvsp[-1].compilation_), (yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7640 "Parser.c"
    break;

  case 550: /* COMPILATION: STRUCTURE_STMT  */
#line 1352 "HAL_S.y"
                   { (yyval.compilation_) = make_AEcompilation((yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7646 "Parser.c"
    break;

  case 551: /* COMPILATION: COMPILATION STRUCTURE_STMT  */
#line 1353 "HAL_S.y"
                               { (yyval.compilation_) = make_AFcompilation((yyvsp[-1].compilation_), (yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7652 "Parser.c"
    break;

  case 552: /* COMPILATION: REPLACE_STMT _SYMB_17  */
#line 1354 "HAL_S.y"
                          { (yyval.compilation_) = make_AGcompilation((yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7658 "Parser.c"
    break;

  case 553: /* COMPILATION: COMPILATION REPLACE_STMT _SYMB_17  */
#line 1355 "HAL_S.y"
                                      { (yyval.compilation_) = make_AHcompilation((yyvsp[-2].compilation_), (yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7664 "Parser.c"
    break;

  case 554: /* COMPILATION: INIT_OR_CONST_HEAD EXPRESSION _SYMB_1  */
#line 1356 "HAL_S.y"
                                          { (yyval.compilation_) = make_AZcompilationInitOrConst((yyvsp[-2].init_or_const_head_), (yyvsp[-1].expression_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7670 "Parser.c"
    break;

  case 555: /* BLOCK_DEFINITION: BLOCK_STMT CLOSING _SYMB_17  */
#line 1358 "HAL_S.y"
                                               { (yyval.block_definition_) = make_AAblock_definition((yyvsp[-2].block_stmt_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7676 "Parser.c"
    break;

  case 556: /* BLOCK_DEFINITION: BLOCK_STMT BLOCK_BODY CLOSING _SYMB_17  */
#line 1359 "HAL_S.y"
                                           { (yyval.block_definition_) = make_ABblock_definition((yyvsp[-3].block_stmt_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7682 "Parser.c"
    break;

  case 557: /* BLOCK_STMT: BLOCK_STMT_TOP _SYMB_17  */
#line 1361 "HAL_S.y"
                                     { (yyval.block_stmt_) = make_AAblock_stmt((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_)->line_number = (yyloc).first_line; (yyval.block_stmt_)->char_number = (yyloc).first_column;  }
#line 7688 "Parser.c"
    break;

  case 558: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_29  */
#line 1363 "HAL_S.y"
                                         { (yyval.block_stmt_top_) = make_AAblockTopAccess((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7694 "Parser.c"
    break;

  case 559: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_135  */
#line 1364 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ABblockTopRigid((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7700 "Parser.c"
    break;

  case 560: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD  */
#line 1365 "HAL_S.y"
                    { (yyval.block_stmt_top_) = make_ACblockTopHead((yyvsp[0].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7706 "Parser.c"
    break;

  case 561: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_79  */
#line 1366 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ADblockTopExclusive((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7712 "Parser.c"
    break;

  case 562: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_128  */
#line 1367 "HAL_S.y"
                              { (yyval.block_stmt_top_) = make_AEblockTopReentrant((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7718 "Parser.c"
    break;

  case 563: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_123  */
#line 1369 "HAL_S.y"
                                           { (yyval.block_stmt_head_) = make_AAblockHeadProgram((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7724 "Parser.c"
    break;

  case 564: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_58  */
#line 1370 "HAL_S.y"
                            { (yyval.block_stmt_head_) = make_ABblockHeadCompool((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7730 "Parser.c"
    break;

  case 565: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_162  */
#line 1371 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ACblockHeadTask((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7736 "Parser.c"
    break;

  case 566: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_174  */
#line 1372 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ADblockHeadUpdate((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7742 "Parser.c"
    break;

  case 567: /* BLOCK_STMT_HEAD: _SYMB_174  */
#line 1373 "HAL_S.y"
              { (yyval.block_stmt_head_) = make_AEblockHeadUpdate(); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7748 "Parser.c"
    break;

  case 568: /* BLOCK_STMT_HEAD: FUNCTION_NAME  */
#line 1374 "HAL_S.y"
                  { (yyval.block_stmt_head_) = make_AFblockHeadFunction((yyvsp[0].function_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7754 "Parser.c"
    break;

  case 569: /* BLOCK_STMT_HEAD: FUNCTION_NAME FUNC_STMT_BODY  */
#line 1375 "HAL_S.y"
                                 { (yyval.block_stmt_head_) = make_AGblockHeadFunction((yyvsp[-1].function_name_), (yyvsp[0].func_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7760 "Parser.c"
    break;

  case 570: /* BLOCK_STMT_HEAD: PROCEDURE_NAME  */
#line 1376 "HAL_S.y"
                   { (yyval.block_stmt_head_) = make_AHblockHeadProcedure((yyvsp[0].procedure_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7766 "Parser.c"
    break;

  case 571: /* BLOCK_STMT_HEAD: PROCEDURE_NAME PROC_STMT_BODY  */
#line 1377 "HAL_S.y"
                                  { (yyval.block_stmt_head_) = make_AIblockHeadProcedure((yyvsp[-1].procedure_name_), (yyvsp[0].proc_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7772 "Parser.c"
    break;

  case 572: /* LABEL_EXTERNAL: LABEL_DEFINITION  */
#line 1379 "HAL_S.y"
                                  { (yyval.label_external_) = make_AAlabel_external((yyvsp[0].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7778 "Parser.c"
    break;

  case 573: /* LABEL_EXTERNAL: LABEL_DEFINITION _SYMB_82  */
#line 1380 "HAL_S.y"
                              { (yyval.label_external_) = make_ABlabel_external((yyvsp[-1].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7784 "Parser.c"
    break;

  case 574: /* CLOSING: _SYMB_56  */
#line 1382 "HAL_S.y"
                   { (yyval.closing_) = make_AAclosing(); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7790 "Parser.c"
    break;

  case 575: /* CLOSING: _SYMB_56 LABEL  */
#line 1383 "HAL_S.y"
                   { (yyval.closing_) = make_ABclosing((yyvsp[0].label_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7796 "Parser.c"
    break;

  case 576: /* CLOSING: LABEL_DEFINITION CLOSING  */
#line 1384 "HAL_S.y"
                             { (yyval.closing_) = make_ACclosing((yyvsp[-1].label_definition_), (yyvsp[0].closing_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7802 "Parser.c"
    break;

  case 577: /* BLOCK_BODY: DECLARE_GROUP  */
#line 1386 "HAL_S.y"
                           { (yyval.block_body_) = make_ABblock_body((yyvsp[0].declare_group_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7808 "Parser.c"
    break;

  case 578: /* BLOCK_BODY: ANY_STATEMENT  */
#line 1387 "HAL_S.y"
                  { (yyval.block_body_) = make_ADblock_body((yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7814 "Parser.c"
    break;

  case 579: /* BLOCK_BODY: BLOCK_BODY ANY_STATEMENT  */
#line 1388 "HAL_S.y"
                             { (yyval.block_body_) = make_ACblock_body((yyvsp[-1].block_body_), (yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7820 "Parser.c"
    break;

  case 580: /* FUNCTION_NAME: LABEL_EXTERNAL _SYMB_87  */
#line 1390 "HAL_S.y"
                                        { (yyval.function_name_) = make_AAfunction_name((yyvsp[-1].label_external_)); (yyval.function_name_)->line_number = (yyloc).first_line; (yyval.function_name_)->char_number = (yyloc).first_column;  }
#line 7826 "Parser.c"
    break;

  case 581: /* PROCEDURE_NAME: LABEL_EXTERNAL _SYMB_121  */
#line 1392 "HAL_S.y"
                                          { (yyval.procedure_name_) = make_AAprocedure_name((yyvsp[-1].label_external_)); (yyval.procedure_name_)->line_number = (yyloc).first_line; (yyval.procedure_name_)->char_number = (yyloc).first_column;  }
#line 7832 "Parser.c"
    break;

  case 582: /* FUNC_STMT_BODY: PARAMETER_LIST  */
#line 1394 "HAL_S.y"
                                { (yyval.func_stmt_body_) = make_AAfunc_stmt_body((yyvsp[0].parameter_list_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7838 "Parser.c"
    break;

  case 583: /* FUNC_STMT_BODY: TYPE_SPEC  */
#line 1395 "HAL_S.y"
              { (yyval.func_stmt_body_) = make_ABfunc_stmt_body((yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7844 "Parser.c"
    break;

  case 584: /* FUNC_STMT_BODY: PARAMETER_LIST TYPE_SPEC  */
#line 1396 "HAL_S.y"
                             { (yyval.func_stmt_body_) = make_ACfunc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7850 "Parser.c"
    break;

  case 585: /* PROC_STMT_BODY: PARAMETER_LIST  */
#line 1398 "HAL_S.y"
                                { (yyval.proc_stmt_body_) = make_AAproc_stmt_body((yyvsp[0].parameter_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7856 "Parser.c"
    break;

  case 586: /* PROC_STMT_BODY: ASSIGN_LIST  */
#line 1399 "HAL_S.y"
                { (yyval.proc_stmt_body_) = make_ABproc_stmt_body((yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7862 "Parser.c"
    break;

  case 587: /* PROC_STMT_BODY: PARAMETER_LIST ASSIGN_LIST  */
#line 1400 "HAL_S.y"
                               { (yyval.proc_stmt_body_) = make_ACproc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7868 "Parser.c"
    break;

  case 588: /* DECLARE_GROUP: DECLARE_ELEMENT  */
#line 1402 "HAL_S.y"
                                { (yyval.declare_group_) = make_AAdeclare_group((yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7874 "Parser.c"
    break;

  case 589: /* DECLARE_GROUP: DECLARE_GROUP DECLARE_ELEMENT  */
#line 1403 "HAL_S.y"
                                  { (yyval.declare_group_) = make_ABdeclare_group((yyvsp[-1].declare_group_), (yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7880 "Parser.c"
    break;

  case 590: /* DECLARE_ELEMENT: DECLARE_STATEMENT  */
#line 1405 "HAL_S.y"
                                    { (yyval.declare_element_) = make_AAdeclareElementDeclare((yyvsp[0].declare_statement_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7886 "Parser.c"
    break;

  case 591: /* DECLARE_ELEMENT: REPLACE_STMT _SYMB_17  */
#line 1406 "HAL_S.y"
                          { (yyval.declare_element_) = make_ABdeclareElementReplace((yyvsp[-1].replace_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7892 "Parser.c"
    break;

  case 592: /* DECLARE_ELEMENT: STRUCTURE_STMT  */
#line 1407 "HAL_S.y"
                   { (yyval.declare_element_) = make_ACdeclareElementStructure((yyvsp[0].structure_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7898 "Parser.c"
    break;

  case 593: /* DECLARE_ELEMENT: _SYMB_73 _SYMB_82 IDENTIFIER _SYMB_166 VARIABLE _SYMB_17  */
#line 1408 "HAL_S.y"
                                                             { (yyval.declare_element_) = make_ADdeclareElementEquate((yyvsp[-3].identifier_), (yyvsp[-1].variable_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7904 "Parser.c"
    break;

  case 594: /* PARAMETER: _SYMB_195  */
#line 1410 "HAL_S.y"
                      { (yyval.parameter_) = make_AAparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7910 "Parser.c"
    break;

  case 595: /* PARAMETER: _SYMB_186  */
#line 1411 "HAL_S.y"
              { (yyval.parameter_) = make_ABparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7916 "Parser.c"
    break;

  case 596: /* PARAMETER: _SYMB_189  */
#line 1412 "HAL_S.y"
              { (yyval.parameter_) = make_ACparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7922 "Parser.c"
    break;

  case 597: /* PARAMETER: _SYMB_190  */
#line 1413 "HAL_S.y"
              { (yyval.parameter_) = make_ADparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7928 "Parser.c"
    break;

  case 598: /* PARAMETER: _SYMB_193  */
#line 1414 "HAL_S.y"
              { (yyval.parameter_) = make_AEparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7934 "Parser.c"
    break;

  case 599: /* PARAMETER: _SYMB_192  */
#line 1415 "HAL_S.y"
              { (yyval.parameter_) = make_AFparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7940 "Parser.c"
    break;

  case 600: /* PARAMETER_LIST: PARAMETER_HEAD PARAMETER _SYMB_1  */
#line 1417 "HAL_S.y"
                                                  { (yyval.parameter_list_) = make_AAparameter_list((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_list_)->line_number = (yyloc).first_line; (yyval.parameter_list_)->char_number = (yyloc).first_column;  }
#line 7946 "Parser.c"
    break;

  case 601: /* PARAMETER_HEAD: _SYMB_2  */
#line 1419 "HAL_S.y"
                         { (yyval.parameter_head_) = make_AAparameter_head(); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 7952 "Parser.c"
    break;

  case 602: /* PARAMETER_HEAD: PARAMETER_HEAD PARAMETER _SYMB_0  */
#line 1420 "HAL_S.y"
                                     { (yyval.parameter_head_) = make_ABparameter_head((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 7958 "Parser.c"
    break;

  case 603: /* DECLARE_STATEMENT: _SYMB_64 DECLARE_BODY _SYMB_17  */
#line 1422 "HAL_S.y"
                                                   { (yyval.declare_statement_) = make_AAdeclare_statement((yyvsp[-1].declare_body_)); (yyval.declare_statement_)->line_number = (yyloc).first_line; (yyval.declare_statement_)->char_number = (yyloc).first_column;  }
#line 7964 "Parser.c"
    break;

  case 604: /* ASSIGN_LIST: ASSIGN PARAMETER_LIST  */
#line 1424 "HAL_S.y"
                                    { (yyval.assign_list_) = make_AAassign_list((yyvsp[-1].assign_), (yyvsp[0].parameter_list_)); (yyval.assign_list_)->line_number = (yyloc).first_line; (yyval.assign_list_)->char_number = (yyloc).first_column;  }
#line 7970 "Parser.c"
    break;

  case 605: /* TEXT: _SYMB_197  */
#line 1426 "HAL_S.y"
                 { (yyval.text_) = make_FQtext((yyvsp[0].string_)); (yyval.text_)->line_number = (yyloc).first_line; (yyval.text_)->char_number = (yyloc).first_column;  }
#line 7976 "Parser.c"
    break;

  case 606: /* REPLACE_STMT: _SYMB_132 REPLACE_HEAD _SYMB_47 TEXT  */
#line 1428 "HAL_S.y"
                                                    { (yyval.replace_stmt_) = make_AAreplace_stmt((yyvsp[-2].replace_head_), (yyvsp[0].text_)); (yyval.replace_stmt_)->line_number = (yyloc).first_line; (yyval.replace_stmt_)->char_number = (yyloc).first_column;  }
#line 7982 "Parser.c"
    break;

  case 607: /* REPLACE_HEAD: IDENTIFIER  */
#line 1430 "HAL_S.y"
                          { (yyval.replace_head_) = make_AAreplace_head((yyvsp[0].identifier_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 7988 "Parser.c"
    break;

  case 608: /* REPLACE_HEAD: IDENTIFIER _SYMB_2 ARG_LIST _SYMB_1  */
#line 1431 "HAL_S.y"
                                        { (yyval.replace_head_) = make_ABreplace_head((yyvsp[-3].identifier_), (yyvsp[-1].arg_list_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 7994 "Parser.c"
    break;

  case 609: /* ARG_LIST: IDENTIFIER  */
#line 1433 "HAL_S.y"
                      { (yyval.arg_list_) = make_AAarg_list((yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 8000 "Parser.c"
    break;

  case 610: /* ARG_LIST: ARG_LIST _SYMB_0 IDENTIFIER  */
#line 1434 "HAL_S.y"
                                { (yyval.arg_list_) = make_ABarg_list((yyvsp[-2].arg_list_), (yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 8006 "Parser.c"
    break;

  case 611: /* STRUCTURE_STMT: _SYMB_155 STRUCT_STMT_HEAD STRUCT_STMT_TAIL  */
#line 1436 "HAL_S.y"
                                                             { (yyval.structure_stmt_) = make_AAstructure_stmt((yyvsp[-1].struct_stmt_head_), (yyvsp[0].struct_stmt_tail_)); (yyval.structure_stmt_)->line_number = (yyloc).first_line; (yyval.structure_stmt_)->char_number = (yyloc).first_column;  }
#line 8012 "Parser.c"
    break;

  case 612: /* STRUCT_STMT_HEAD: STRUCTURE_ID _SYMB_18 LEVEL  */
#line 1438 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_AAstruct_stmt_head((yyvsp[-2].structure_id_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 8018 "Parser.c"
    break;

  case 613: /* STRUCT_STMT_HEAD: STRUCTURE_ID MINOR_ATTR_LIST _SYMB_18 LEVEL  */
#line 1439 "HAL_S.y"
                                                { (yyval.struct_stmt_head_) = make_ABstruct_stmt_head((yyvsp[-3].structure_id_), (yyvsp[-2].minor_attr_list_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 8024 "Parser.c"
    break;

  case 614: /* STRUCT_STMT_HEAD: STRUCT_STMT_HEAD DECLARATION _SYMB_0 LEVEL  */
#line 1440 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_ACstruct_stmt_head((yyvsp[-3].struct_stmt_head_), (yyvsp[-2].declaration_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 8030 "Parser.c"
    break;

  case 615: /* STRUCT_STMT_TAIL: DECLARATION _SYMB_17  */
#line 1442 "HAL_S.y"
                                        { (yyval.struct_stmt_tail_) = make_AAstruct_stmt_tail((yyvsp[-1].declaration_)); (yyval.struct_stmt_tail_)->line_number = (yyloc).first_line; (yyval.struct_stmt_tail_)->char_number = (yyloc).first_column;  }
#line 8036 "Parser.c"
    break;

  case 616: /* INLINE_DEFINITION: ARITH_INLINE  */
#line 1444 "HAL_S.y"
                                 { (yyval.inline_definition_) = make_AAinline_definition((yyvsp[0].arith_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 8042 "Parser.c"
    break;

  case 617: /* INLINE_DEFINITION: BIT_INLINE  */
#line 1445 "HAL_S.y"
               { (yyval.inline_definition_) = make_ABinline_definition((yyvsp[0].bit_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 8048 "Parser.c"
    break;

  case 618: /* INLINE_DEFINITION: CHAR_INLINE  */
#line 1446 "HAL_S.y"
                { (yyval.inline_definition_) = make_ACinline_definition((yyvsp[0].char_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 8054 "Parser.c"
    break;

  case 619: /* INLINE_DEFINITION: STRUCTURE_EXP  */
#line 1447 "HAL_S.y"
                  { (yyval.inline_definition_) = make_ADinline_definition((yyvsp[0].structure_exp_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 8060 "Parser.c"
    break;

  case 620: /* ARITH_INLINE: ARITH_INLINE_DEF CLOSING _SYMB_17  */
#line 1449 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_ACprimary((yyvsp[-2].arith_inline_def_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 8066 "Parser.c"
    break;

  case 621: /* ARITH_INLINE: ARITH_INLINE_DEF BLOCK_BODY CLOSING _SYMB_17  */
#line 1450 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_AZprimary((yyvsp[-3].arith_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 8072 "Parser.c"
    break;

  case 622: /* ARITH_INLINE_DEF: _SYMB_87 ARITH_SPEC _SYMB_17  */
#line 1452 "HAL_S.y"
                                                { (yyval.arith_inline_def_) = make_AAarith_inline_def((yyvsp[-1].arith_spec_)); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 8078 "Parser.c"
    break;

  case 623: /* ARITH_INLINE_DEF: _SYMB_87 _SYMB_17  */
#line 1453 "HAL_S.y"
                      { (yyval.arith_inline_def_) = make_ABarith_inline_def(); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 8084 "Parser.c"
    break;

  case 624: /* BIT_INLINE: BIT_INLINE_DEF CLOSING _SYMB_17  */
#line 1455 "HAL_S.y"
                                             { (yyval.bit_inline_) = make_AGbit_prim((yyvsp[-2].bit_inline_def_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 8090 "Parser.c"
    break;

  case 625: /* BIT_INLINE: BIT_INLINE_DEF BLOCK_BODY CLOSING _SYMB_17  */
#line 1456 "HAL_S.y"
                                               { (yyval.bit_inline_) = make_AZbit_prim((yyvsp[-3].bit_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 8096 "Parser.c"
    break;

  case 626: /* BIT_INLINE_DEF: _SYMB_87 BIT_SPEC _SYMB_17  */
#line 1458 "HAL_S.y"
                                            { (yyval.bit_inline_def_) = make_AAbit_inline_def((yyvsp[-1].bit_spec_)); (yyval.bit_inline_def_)->line_number = (yyloc).first_line; (yyval.bit_inline_def_)->char_number = (yyloc).first_column;  }
#line 8102 "Parser.c"
    break;

  case 627: /* CHAR_INLINE: CHAR_INLINE_DEF CLOSING _SYMB_17  */
#line 1460 "HAL_S.y"
                                               { (yyval.char_inline_) = make_ADchar_prim((yyvsp[-2].char_inline_def_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 8108 "Parser.c"
    break;

  case 628: /* CHAR_INLINE: CHAR_INLINE_DEF BLOCK_BODY CLOSING _SYMB_17  */
#line 1461 "HAL_S.y"
                                                { (yyval.char_inline_) = make_AZchar_prim((yyvsp[-3].char_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 8114 "Parser.c"
    break;

  case 629: /* CHAR_INLINE_DEF: _SYMB_87 CHAR_SPEC _SYMB_17  */
#line 1463 "HAL_S.y"
                                              { (yyval.char_inline_def_) = make_AAchar_inline_def((yyvsp[-1].char_spec_)); (yyval.char_inline_def_)->line_number = (yyloc).first_line; (yyval.char_inline_def_)->char_number = (yyloc).first_column;  }
#line 8120 "Parser.c"
    break;

  case 630: /* STRUC_INLINE_DEF: _SYMB_87 STRUCT_SPEC _SYMB_17  */
#line 1465 "HAL_S.y"
                                                 { (yyval.struc_inline_def_) = make_AAstruc_inline_def((yyvsp[-1].struct_spec_)); (yyval.struc_inline_def_)->line_number = (yyloc).first_line; (yyval.struc_inline_def_)->char_number = (yyloc).first_column;  }
#line 8126 "Parser.c"
    break;


#line 8130 "Parser.c"

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

#line 1468 "HAL_S.y"

void yyerror(const char *str)
{
  extern char *HAL_Stext;
  fprintf(stderr,"error: %d,%d: %s at %s\n",
  HAL_Slloc.first_line, HAL_Slloc.first_column, str, HAL_Stext);
}

