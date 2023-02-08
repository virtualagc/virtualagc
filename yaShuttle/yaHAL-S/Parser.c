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


#line 574 "Parser.c"

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
  YYSYMBOL_SHAPING_HEAD = 229,             /* SHAPING_HEAD  */
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
  YYSYMBOL_STATEMENT = 290,                /* STATEMENT  */
  YYSYMBOL_BASIC_STATEMENT = 291,          /* BASIC_STATEMENT  */
  YYSYMBOL_OTHER_STATEMENT = 292,          /* OTHER_STATEMENT  */
  YYSYMBOL_IF_STATEMENT = 293,             /* IF_STATEMENT  */
  YYSYMBOL_IF_CLAUSE = 294,                /* IF_CLAUSE  */
  YYSYMBOL_TRUE_PART = 295,                /* TRUE_PART  */
  YYSYMBOL_IF = 296,                       /* IF  */
  YYSYMBOL_THEN = 297,                     /* THEN  */
  YYSYMBOL_RELATIONAL_EXP = 298,           /* RELATIONAL_EXP  */
  YYSYMBOL_RELATIONAL_FACTOR = 299,        /* RELATIONAL_FACTOR  */
  YYSYMBOL_REL_PRIM = 300,                 /* REL_PRIM  */
  YYSYMBOL_COMPARISON = 301,               /* COMPARISON  */
  YYSYMBOL_ANY_STATEMENT = 302,            /* ANY_STATEMENT  */
  YYSYMBOL_ON_PHRASE = 303,                /* ON_PHRASE  */
  YYSYMBOL_ON_CLAUSE = 304,                /* ON_CLAUSE  */
  YYSYMBOL_LABEL_DEFINITION = 305,         /* LABEL_DEFINITION  */
  YYSYMBOL_CALL_KEY = 306,                 /* CALL_KEY  */
  YYSYMBOL_ASSIGN = 307,                   /* ASSIGN  */
  YYSYMBOL_CALL_ASSIGN_LIST = 308,         /* CALL_ASSIGN_LIST  */
  YYSYMBOL_DO_GROUP_HEAD = 309,            /* DO_GROUP_HEAD  */
  YYSYMBOL_ENDING = 310,                   /* ENDING  */
  YYSYMBOL_READ_KEY = 311,                 /* READ_KEY  */
  YYSYMBOL_WRITE_KEY = 312,                /* WRITE_KEY  */
  YYSYMBOL_READ_PHRASE = 313,              /* READ_PHRASE  */
  YYSYMBOL_WRITE_PHRASE = 314,             /* WRITE_PHRASE  */
  YYSYMBOL_READ_ARG = 315,                 /* READ_ARG  */
  YYSYMBOL_WRITE_ARG = 316,                /* WRITE_ARG  */
  YYSYMBOL_FILE_EXP = 317,                 /* FILE_EXP  */
  YYSYMBOL_FILE_HEAD = 318,                /* FILE_HEAD  */
  YYSYMBOL_IO_CONTROL = 319,               /* IO_CONTROL  */
  YYSYMBOL_WAIT_KEY = 320,                 /* WAIT_KEY  */
  YYSYMBOL_TERMINATOR = 321,               /* TERMINATOR  */
  YYSYMBOL_TERMINATE_LIST = 322,           /* TERMINATE_LIST  */
  YYSYMBOL_SCHEDULE_HEAD = 323,            /* SCHEDULE_HEAD  */
  YYSYMBOL_SCHEDULE_PHRASE = 324,          /* SCHEDULE_PHRASE  */
  YYSYMBOL_SCHEDULE_CONTROL = 325,         /* SCHEDULE_CONTROL  */
  YYSYMBOL_TIMING = 326,                   /* TIMING  */
  YYSYMBOL_REPEAT = 327,                   /* REPEAT  */
  YYSYMBOL_STOPPING = 328,                 /* STOPPING  */
  YYSYMBOL_SIGNAL_CLAUSE = 329,            /* SIGNAL_CLAUSE  */
  YYSYMBOL_PERCENT_MACRO_NAME = 330,       /* PERCENT_MACRO_NAME  */
  YYSYMBOL_PERCENT_MACRO_HEAD = 331,       /* PERCENT_MACRO_HEAD  */
  YYSYMBOL_PERCENT_MACRO_ARG = 332,        /* PERCENT_MACRO_ARG  */
  YYSYMBOL_CASE_ELSE = 333,                /* CASE_ELSE  */
  YYSYMBOL_WHILE_KEY = 334,                /* WHILE_KEY  */
  YYSYMBOL_WHILE_CLAUSE = 335,             /* WHILE_CLAUSE  */
  YYSYMBOL_FOR_LIST = 336,                 /* FOR_LIST  */
  YYSYMBOL_ITERATION_BODY = 337,           /* ITERATION_BODY  */
  YYSYMBOL_ITERATION_CONTROL = 338,        /* ITERATION_CONTROL  */
  YYSYMBOL_FOR_KEY = 339,                  /* FOR_KEY  */
  YYSYMBOL_TEMPORARY_STMT = 340,           /* TEMPORARY_STMT  */
  YYSYMBOL_CONSTANT = 341,                 /* CONSTANT  */
  YYSYMBOL_ARRAY_HEAD = 342,               /* ARRAY_HEAD  */
  YYSYMBOL_MINOR_ATTR_LIST = 343,          /* MINOR_ATTR_LIST  */
  YYSYMBOL_MINOR_ATTRIBUTE = 344,          /* MINOR_ATTRIBUTE  */
  YYSYMBOL_INIT_OR_CONST_HEAD = 345,       /* INIT_OR_CONST_HEAD  */
  YYSYMBOL_REPEATED_CONSTANT = 346,        /* REPEATED_CONSTANT  */
  YYSYMBOL_REPEAT_HEAD = 347,              /* REPEAT_HEAD  */
  YYSYMBOL_NESTED_REPEAT_HEAD = 348,       /* NESTED_REPEAT_HEAD  */
  YYSYMBOL_DCL_LIST_COMMA = 349,           /* DCL_LIST_COMMA  */
  YYSYMBOL_LITERAL_EXP_OR_STAR = 350,      /* LITERAL_EXP_OR_STAR  */
  YYSYMBOL_TYPE_SPEC = 351,                /* TYPE_SPEC  */
  YYSYMBOL_BIT_SPEC = 352,                 /* BIT_SPEC  */
  YYSYMBOL_CHAR_SPEC = 353,                /* CHAR_SPEC  */
  YYSYMBOL_STRUCT_SPEC = 354,              /* STRUCT_SPEC  */
  YYSYMBOL_STRUCT_SPEC_BODY = 355,         /* STRUCT_SPEC_BODY  */
  YYSYMBOL_STRUCT_TEMPLATE = 356,          /* STRUCT_TEMPLATE  */
  YYSYMBOL_STRUCT_SPEC_HEAD = 357,         /* STRUCT_SPEC_HEAD  */
  YYSYMBOL_ARITH_SPEC = 358,               /* ARITH_SPEC  */
  YYSYMBOL_COMPILATION = 359,              /* COMPILATION  */
  YYSYMBOL_BLOCK_DEFINITION = 360,         /* BLOCK_DEFINITION  */
  YYSYMBOL_BLOCK_STMT = 361,               /* BLOCK_STMT  */
  YYSYMBOL_BLOCK_STMT_TOP = 362,           /* BLOCK_STMT_TOP  */
  YYSYMBOL_BLOCK_STMT_HEAD = 363,          /* BLOCK_STMT_HEAD  */
  YYSYMBOL_LABEL_EXTERNAL = 364,           /* LABEL_EXTERNAL  */
  YYSYMBOL_CLOSING = 365,                  /* CLOSING  */
  YYSYMBOL_BLOCK_BODY = 366,               /* BLOCK_BODY  */
  YYSYMBOL_FUNCTION_NAME = 367,            /* FUNCTION_NAME  */
  YYSYMBOL_PROCEDURE_NAME = 368,           /* PROCEDURE_NAME  */
  YYSYMBOL_FUNC_STMT_BODY = 369,           /* FUNC_STMT_BODY  */
  YYSYMBOL_PROC_STMT_BODY = 370,           /* PROC_STMT_BODY  */
  YYSYMBOL_DECLARE_GROUP = 371,            /* DECLARE_GROUP  */
  YYSYMBOL_DECLARE_ELEMENT = 372,          /* DECLARE_ELEMENT  */
  YYSYMBOL_PARAMETER = 373,                /* PARAMETER  */
  YYSYMBOL_PARAMETER_LIST = 374,           /* PARAMETER_LIST  */
  YYSYMBOL_PARAMETER_HEAD = 375,           /* PARAMETER_HEAD  */
  YYSYMBOL_DECLARE_STATEMENT = 376,        /* DECLARE_STATEMENT  */
  YYSYMBOL_ASSIGN_LIST = 377,              /* ASSIGN_LIST  */
  YYSYMBOL_TEXT = 378,                     /* TEXT  */
  YYSYMBOL_REPLACE_STMT = 379,             /* REPLACE_STMT  */
  YYSYMBOL_REPLACE_HEAD = 380,             /* REPLACE_HEAD  */
  YYSYMBOL_ARG_LIST = 381,                 /* ARG_LIST  */
  YYSYMBOL_STRUCTURE_STMT = 382,           /* STRUCTURE_STMT  */
  YYSYMBOL_STRUCT_STMT_HEAD = 383,         /* STRUCT_STMT_HEAD  */
  YYSYMBOL_STRUCT_STMT_TAIL = 384,         /* STRUCT_STMT_TAIL  */
  YYSYMBOL_INLINE_DEFINITION = 385,        /* INLINE_DEFINITION  */
  YYSYMBOL_ARITH_INLINE = 386,             /* ARITH_INLINE  */
  YYSYMBOL_ARITH_INLINE_DEF = 387,         /* ARITH_INLINE_DEF  */
  YYSYMBOL_BIT_INLINE = 388,               /* BIT_INLINE  */
  YYSYMBOL_BIT_INLINE_DEF = 389,           /* BIT_INLINE_DEF  */
  YYSYMBOL_CHAR_INLINE = 390,              /* CHAR_INLINE  */
  YYSYMBOL_CHAR_INLINE_DEF = 391,          /* CHAR_INLINE_DEF  */
  YYSYMBOL_STRUC_INLINE_DEF = 392          /* STRUC_INLINE_DEF  */
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
#define YYFINAL  465
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   8090

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  202
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  191
/* YYNRULES -- Number of rules.  */
#define YYNRULES  621
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  1049

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
       0,   645,   645,   646,   648,   649,   650,   652,   653,   654,
     655,   656,   657,   658,   659,   660,   661,   662,   663,   665,
     666,   667,   668,   669,   671,   672,   673,   675,   677,   678,
     680,   681,   683,   684,   685,   686,   688,   689,   691,   692,
     693,   694,   695,   696,   697,   698,   700,   701,   702,   703,
     704,   706,   707,   709,   711,   713,   714,   715,   716,   718,
     719,   720,   722,   724,   725,   726,   727,   729,   730,   731,
     732,   733,   734,   735,   736,   738,   739,   740,   741,   742,
     743,   744,   746,   747,   749,   751,   753,   755,   756,   757,
     758,   760,   761,   762,   764,   765,   767,   768,   769,   771,
     772,   773,   774,   775,   777,   778,   780,   781,   782,   783,
     784,   785,   786,   787,   789,   790,   791,   792,   793,   794,
     795,   796,   797,   798,   799,   800,   801,   802,   803,   804,
     805,   806,   807,   808,   809,   810,   811,   812,   813,   814,
     815,   816,   817,   818,   819,   820,   821,   822,   823,   824,
     825,   826,   827,   828,   829,   830,   831,   832,   834,   835,
     836,   837,   839,   840,   841,   842,   844,   845,   847,   848,
     850,   851,   852,   853,   854,   856,   857,   859,   860,   861,
     862,   864,   866,   867,   869,   870,   871,   873,   874,   876,
     877,   879,   880,   881,   882,   884,   885,   887,   889,   890,
     892,   893,   894,   895,   896,   897,   898,   899,   900,   901,
     902,   904,   905,   907,   908,   910,   911,   912,   913,   915,
     916,   917,   918,   920,   921,   922,   923,   925,   926,   928,
     929,   930,   931,   932,   934,   935,   936,   937,   939,   941,
     942,   944,   946,   947,   948,   950,   952,   953,   954,   955,
     957,   958,   960,   962,   963,   965,   967,   968,   969,   970,
     971,   973,   974,   975,   976,   978,   979,   981,   982,   983,
     984,   986,   987,   989,   990,   991,   992,   993,   995,   997,
     998,   999,  1001,  1003,  1004,  1005,  1007,  1008,  1009,  1010,
    1011,  1012,  1013,  1015,  1016,  1017,  1018,  1020,  1022,  1024,
    1026,  1027,  1029,  1031,  1032,  1033,  1034,  1036,  1038,  1039,
    1040,  1042,  1043,  1044,  1045,  1046,  1047,  1048,  1049,  1050,
    1051,  1052,  1053,  1054,  1055,  1056,  1057,  1058,  1059,  1060,
    1061,  1062,  1063,  1064,  1065,  1066,  1067,  1068,  1069,  1070,
    1071,  1072,  1073,  1074,  1075,  1076,  1077,  1078,  1079,  1080,
    1081,  1082,  1084,  1085,  1086,  1088,  1089,  1091,  1092,  1094,
    1096,  1098,  1100,  1101,  1103,  1104,  1106,  1107,  1108,  1110,
    1111,  1112,  1113,  1114,  1115,  1116,  1117,  1118,  1119,  1120,
    1121,  1122,  1123,  1124,  1125,  1126,  1127,  1128,  1129,  1130,
    1131,  1132,  1133,  1134,  1135,  1136,  1137,  1138,  1139,  1141,
    1142,  1144,  1145,  1147,  1148,  1149,  1150,  1152,  1154,  1156,
    1158,  1159,  1160,  1161,  1163,  1164,  1165,  1166,  1167,  1168,
    1169,  1170,  1172,  1173,  1174,  1176,  1177,  1179,  1181,  1182,
    1184,  1185,  1187,  1188,  1190,  1191,  1192,  1194,  1196,  1198,
    1199,  1200,  1201,  1202,  1204,  1206,  1207,  1209,  1210,  1212,
    1213,  1214,  1215,  1217,  1218,  1219,  1221,  1222,  1223,  1225,
    1226,  1227,  1229,  1231,  1232,  1234,  1235,  1236,  1238,  1240,
    1241,  1243,  1244,  1246,  1248,  1249,  1251,  1252,  1254,  1255,
    1257,  1258,  1260,  1261,  1263,  1264,  1266,  1268,  1269,  1270,
    1271,  1273,  1274,  1276,  1277,  1279,  1280,  1281,  1282,  1283,
    1284,  1285,  1286,  1287,  1288,  1289,  1290,  1292,  1293,  1294,
    1296,  1297,  1298,  1299,  1300,  1302,  1304,  1305,  1307,  1309,
    1310,  1312,  1313,  1314,  1315,  1316,  1318,  1319,  1321,  1323,
    1325,  1326,  1328,  1330,  1332,  1333,  1334,  1336,  1337,  1338,
    1339,  1340,  1341,  1342,  1343,  1344,  1346,  1347,  1349,  1351,
    1352,  1353,  1354,  1355,  1357,  1358,  1359,  1360,  1361,  1362,
    1363,  1364,  1365,  1367,  1368,  1370,  1371,  1372,  1374,  1375,
    1376,  1378,  1380,  1382,  1383,  1384,  1386,  1387,  1388,  1390,
    1391,  1393,  1394,  1395,  1396,  1398,  1399,  1400,  1401,  1402,
    1403,  1405,  1407,  1408,  1410,  1412,  1414,  1416,  1418,  1419,
    1421,  1422,  1424,  1426,  1427,  1428,  1430,  1432,  1433,  1434,
    1435,  1437,  1438,  1440,  1441,  1443,  1444,  1446,  1448,  1449,
    1451,  1453
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

#define YYPACT_NINF (-836)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-437)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
    6050,   259,  -147,  -836,  -111,   750,  -836,   140,  7614,    61,
     166,   187,  1337,     2,  -836,   249,  -836,   195,   233,   328,
     333,   251,  -111,   287,  2736,   750,   263,   287,   287,  -147,
    -836,  -836,   301,  -836,   351,  -836,  -836,  -836,  -836,  -836,
     360,  -836,  -836,  -836,  -836,  -836,  -836,   396,  -836,  -836,
    1160,   275,   396,   405,   396,  -836,   396,   429,   141,  -836,
     473,   149,  -836,   631,  -836,   456,  -836,  -836,  -836,  -836,
    7016,  7016,  3520,  -836,  7016,    77,  6738,   170,  6328,  5921,
    2344,   224,   242,   461,   480,  4481,   113,   172,    44,   476,
     304,  5900,  7016,  3716,  2151,  -836,  6196,    42,    72,   168,
    1748,    56,  -836,   483,  -836,  -836,  -836,  6196,  -836,  6196,
    -836,  6196,  6196,   478,   181,  -836,  -836,  -836,   396,   495,
    -836,  -836,  -836,   517,  -836,   537,  -836,   539,  -836,  -836,
    -836,  -836,  -836,  -836,   543,   555,   566,  -836,  -836,  -836,
    -836,  -836,  -836,  -836,  -836,   570,  -836,  -836,   510,  -836,
    7802,  1861,   559,   582,  -836,  7899,  -836,   481,   -20,  4825,
    -836,   584,  7765,  -836,  -836,  -836,  -836,  4825,  4893,  -836,
    2932,  1103,  4893,  -836,  -836,  -836,   600,  -836,  -836,  5169,
      38,  -836,  -836,  3520,   607,    43,  5169,  -836,   626,   200,
    -836,   628,   640,   656,   664,   596,  -836,   278,    40,   200,
     200,  -836,   666,   599,   621,  -836,   606,  3912,  -836,  -836,
     471,   -13,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,
    -836,  -836,  -836,  -836,   152,  -836,   695,   152,  -836,  -836,
    -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,
    -147,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,
    -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,
    -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,
    -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,
    -836,  -836,  -836,  -836,  -836,  -836,   711,   732,   735,  -836,
    -836,  -836,  -836,   330,   477,  -836,  5511,  5511,   696,  5340,
     504,  -836,   708,  -836,  -836,  -836,  -836,  -836,   531,   722,
     396,   741,    29,   338,   102,  -836,  5737,  -836,  -836,  -836,
     557,  -836,   754,  -836,  3716,   775,  -836,   102,  -836,   777,
    -836,  -836,  -836,  -836,   780,  -836,  -836,   370,  -836,   357,
    -836,  -836,  1470,  1103,   723,   200,   820,  -836,  -836,  4653,
     561,   787,  -836,   399,  -836,   791,  -836,  -836,  -836,  -836,
    6240,  1160,  -836,  3128,  3716,  1160,   894,  -836,  3716,  -836,
     301,  -836,   729,  7426,  -836,  3520,  1222,    26,   968,  5758,
    1255,   103,   137,    26,   338,  -836,  -836,  -836,  -836,   291,
    -836,  -836,   301,  -836,  -836,  3716,  -836,  -836,   806,   596,
    7614,  -836,  6460,   803,  -836,  -836,   819,   821,   826,   832,
     839,  -836,  -836,  -836,  -836,   262,  -836,  -836,  -836,  1742,
    -836,  2540,  -836,  3716,  5169,  5169,  2019,  5169,   735,   462,
     841,  -836,  -836,   286,  5169,  5169,  5679,   851,   724,  -836,
    -836,   864,    36,    34,  -836,  4108,  -836,  -836,  -836,  -836,
    -836,  -836,  -836,  -836,  -836,  -836,  -836,   551,  -836,  -836,
     586,   882,   893,  5621,  3716,  -836,  -836,  -836,   889,  -836,
     596,   835,  -836,  6606,   904,  6884,    27,  -836,  -836,   908,
    -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,
    -836,  -836,  -836,  1639,   568,   925,  -836,   901,  -836,  -836,
     940,  6884,   943,  6884,   951,  6884,   959,  6884,   396,  -147,
     396,  -836,   750,  -836,  4825,  4825,  4825,  4825,   779,  -836,
    7899,  4893,  -836,  4893,  4893,  -836,  1103,  -836,  -836,  -836,
    -836,   636,   944,  -836,  -836,   651,  -836,   977,  -836,   678,
    -836,  -836,  4893,   840,  -836,  4825,   506,  -111,   461,   983,
      29,    29,  -836,  -836,   986,    52,   997,  -836,  -836,  -836,
    -836,  -836,  -836,   989,  -836,   993,  -836,  -836,   -22,   999,
    1023,  -836,  -111,   837,   287,   697,    64,   245,  1019,  1018,
    1025,  1020,   447,  1026,  -836,  -836,  -836,   200,  -836,  3716,
    3716,  1031,  -836,  -836,  5511,  5511,  4304,  -836,  -836,  5511,
    5511,  5511,  -836,  -836,  -836,  5511,  1033,  -836,  3324,  -836,
    -836,  -836,  3716,  -836,  -836,  5679,  -836,  -836,  -836,  5679,
    5679,  5679,   -13,   -13,  -836,  1030,  -836,   200,  1039,  3716,
    4304,  3716,  7450,  5528,  -836,  1032,   779,  1714,   324,  -836,
    5169,   877,  1046,  1034,  -836,  -836,  -836,  -836,   231,  -836,
    4997,   886,   636,  -836,  -836,  -836,  -836,  -836,  -836,  1047,
     141,  -836,  -836,  1037,   809,   721,  -836,  -836,   370,  -836,
     396,   396,   396,   396,  -836,  -836,  -836,   948,  1038,    76,
    5169,  5169,  5169,  5169,  5169,  5169,  -836,  -836,  5679,  5679,
    5679,  5679,  5679,  5679,  3520,  4304,  4304,  4304,  4304,  4304,
    4304,   162,   162,   162,   162,   162,   162,   -24,   -24,   -24,
     -24,   -24,   -24,  3520,  -836,  3520,  1040,   745,  1160,  -836,
    1041,  7148,  -836,  -836,  5169,  5169,  5169,  5169,  5169,  -836,
    -836,  1043,   373,   761,   767,  1055,    82,   549,  -836,  2041,
     750,  -836,   636,   636,    29,  5169,  -836,  -836,  -836,  5169,
    5169,  4108,   636,    29,  1066,  -836,  1057,  -836,  -836,  -836,
    -836,  -836,  -836,   836,  -836,  -836,  -111,  7294,  -836,  -836,
    -836,  1059,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,
    -836,   850,  -836,  -836,  -836,  1061,  -836,  1062,  -836,  1074,
    -836,  1086,  -836,  -836,   396,  1104,  1106,  1107,  1109,  1110,
    -836,  4893,  4893,   584,  -836,  -836,  -836,  -836,  -836,  1102,
    1112,  1045,  1090,  -836,   528,  -836,  5169,  -836,  5169,  -836,
    -836,  -836,  -836,  -836,  -836,  -836,   857,  -836,  -836,  -836,
    -836,  -836,   396,   -13,   396,  1108,  1117,   863,  -836,  3716,
    -836,  -836,  4304,  -836,   636,  -836,  1114,  -836,  -836,  -836,
    -836,  1111,  1118,  -836,   871,   338,   102,  -836,  5737,   912,
    1121,  -836,   878,   636,  -836,   891,  1123,  1124,   396,  -836,
    -836,   779,   779,  -836,   595,  5169,  -836,   938,  5169,  4997,
     636,  -836,  -836,  5511,  5511,  -836,  3716,  -836,  3716,  3716,
    -836,  -836,  -836,  -836,  -836,  -836,   636,   636,   636,   636,
     636,   636,   102,   102,   102,   102,   102,   102,    85,   477,
     102,   102,   102,   102,   102,   102,  -836,  -836,  -836,  -836,
    -836,  -836,  -836,  -836,   411,  -836,  -836,  -836,  -836,  -836,
     968,   338,  -836,  -836,   211,  -836,   399,   980,  -836,   801,
     842,   861,   869,   900,  -836,  -836,  -836,  -836,  -836,  -836,
    -836,   928,   636,   636,  1862,  -836,  -836,  -836,   960,  -836,
    -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,
    -836,  -836,  -836,  -836,  -836,  -836,   300,   636,  -111,  -836,
    -836,  -836,  1122,   557,  -836,  -836,  2032,   938,  -836,  -836,
    -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,
     617,  -836,   984,  1132,   946,  -836,  -836,  -836,  -836,  -836,
    -836,  -836,  1138,  1160,  1126,  -836,  -836,  -836,  -836,  -836,
    -836,  1160,  5169,  -836,   470,  -836,  1013,  -836,  1128,  -836,
    -836,  -836,  1160,  -836,   399,  -836,  1130,   636,  1144,  1128,
    1135,  5169,  1022,  -836,  -836,   961,  1136,  -836,  -836
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int16 yydefact[] =
{
       0,     0,     0,   318,     0,     0,   446,     0,     0,     0,
       0,     0,     0,     0,   360,     0,   282,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     241,   445,   558,   444,     0,   245,   247,   248,   278,   302,
     249,   246,   252,   105,    27,   104,   286,    67,   287,   291,
       0,     0,   215,     0,   223,   289,   267,     0,     0,   610,
       0,   293,   297,     0,   300,     0,   399,   308,   309,   352,
       0,     0,     0,   537,     0,     0,   563,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   453,     0,     0,
       0,     0,     0,     0,     0,   400,     0,     0,   551,     0,
     559,   561,   539,     0,   541,   310,   607,     0,   608,     0,
     609,     0,     0,     0,     0,   468,   249,   408,   219,     0,
     508,   499,   498,     0,   496,     0,   526,     0,   497,   169,
     525,    20,    32,   505,     0,    35,     0,    21,    22,   501,
     502,    33,   168,   495,    23,    34,    42,    43,    44,    45,
       9,    17,     0,     0,    36,     5,     6,    38,   535,     0,
      29,     2,     7,   534,    40,    41,   532,     0,    26,   493,
       0,     0,    24,   522,   523,   521,     0,   524,   414,     0,
       0,   475,   474,     0,     0,     0,     0,   313,     0,     0,
     614,     0,     0,     0,     0,     0,   507,     0,   402,     0,
       0,   315,     0,   598,     0,   466,     0,     0,    53,    54,
       0,     0,   323,   214,   115,   145,   127,   128,   129,   130,
     132,   131,   133,   236,   243,   116,     0,   277,   106,   134,
     135,   107,   237,   146,   117,   108,   109,   136,   231,   118,
       0,   234,   149,   151,   150,   273,   137,    35,   156,   119,
     157,   120,   114,   213,   280,   235,   121,   233,   232,   110,
     153,   111,   112,   122,   274,   123,   113,   143,   144,   124,
     125,   138,   139,   155,   140,   154,   141,   142,   147,   152,
     275,   230,   126,   148,    34,   250,   247,   248,   246,   238,
      84,    86,    85,     0,    99,    46,     0,     0,    51,    55,
      59,    63,    64,    76,    83,    77,    82,    65,     0,     0,
      87,     0,   100,   187,   189,   191,     0,   200,   201,   202,
       0,   203,   227,   271,     0,     0,   242,   101,   256,     0,
     261,   262,   265,   102,     0,   103,   293,     0,   449,     0,
     465,   467,     0,     0,     0,     0,     0,    68,   159,   175,
       0,     0,   292,     0,   239,     0,   216,   407,   224,   268,
       0,     0,   307,     0,     0,     0,     0,   298,     0,   311,
       0,   355,   308,     0,   356,     0,     0,     0,   189,     0,
       0,     0,     0,     0,   362,   364,   368,   353,   346,     0,
     564,   556,   557,   312,   354,     0,   319,   409,     0,   422,
       0,   420,   563,     0,   421,   326,     0,     0,     0,     0,
       0,   432,   428,   433,   328,   302,   434,   430,   435,     0,
     327,     0,   329,     0,     0,     0,     0,     0,     0,     0,
       0,   337,   447,     0,     0,     0,     0,     0,     0,   341,
     455,     0,   457,   461,   456,     0,   343,   469,   350,   487,
     488,   284,   285,   489,   490,   471,   283,     0,   472,   419,
      99,   510,     0,   514,     0,     1,   538,   540,     0,   542,
     565,     0,   569,   563,     0,     0,   568,   579,   581,     0,
     583,   548,   549,   550,   552,   553,   555,   571,   572,   554,
     592,   574,   560,   573,     0,     0,   562,   576,   577,   543,
       0,     0,     0,     0,     0,     0,     0,     0,    69,     0,
      71,   220,     0,   491,     0,     0,     0,     0,     0,    30,
      14,    12,    10,    15,    18,   594,     0,     4,    39,   536,
     520,   519,     0,   518,     8,     0,   494,     0,   510,     0,
      44,    37,    25,     0,   529,     0,     0,     0,     0,     0,
     476,   477,   417,   415,     0,   480,   479,   314,   438,   617,
     620,   621,   613,     0,   349,     0,   406,   405,   401,     0,
       0,   316,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   253,   244,   254,     0,   266,     0,
       0,     0,   211,   212,     0,     0,     0,    47,    48,     0,
       0,     0,    58,    61,    62,     0,     0,    66,     0,    79,
     324,    88,     0,   197,   196,     0,   195,   198,   199,     0,
       0,     0,     0,     0,   193,     0,   229,     0,     0,     0,
       0,     0,     0,     0,   345,     0,     0,     0,     0,   602,
       0,     0,     0,   170,   161,   160,   178,   184,   182,   176,
       0,   177,   183,   174,   158,   172,   173,   288,   240,     0,
       0,   304,   303,     0,    99,     0,    94,    96,    98,   306,
      73,   217,   225,   269,   301,   305,   359,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   361,   358,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   357,     0,     0,     0,     0,   423,
       0,     0,   424,   325,     0,     0,     0,     0,     0,   429,
     431,     0,     0,     0,     0,     0,     0,     0,   334,     0,
       0,   338,   450,   451,   452,     0,   462,   342,   458,     0,
       0,     0,   463,   464,     0,   470,     0,   515,   545,   509,
     516,   511,   512,     0,   544,   566,     0,     0,   567,   546,
     570,     0,   580,   582,   575,   586,   587,   588,   590,   589,
     585,     0,   595,   578,   611,     0,   615,     0,   618,     0,
     295,     0,    70,    72,   221,     0,     0,     0,     0,     0,
      13,    11,    16,     3,    28,   492,    19,   504,   503,   530,
       0,   418,     0,   484,     0,   416,     0,   478,     0,   317,
     348,   404,   403,   425,   426,   600,     0,   596,   597,    75,
     204,   264,   207,     0,   209,     0,     0,     0,    91,     0,
      49,    50,     0,   276,   259,   260,     0,    52,    56,    57,
      60,     0,     0,    93,     0,   188,   190,   192,     0,     0,
       0,   205,     0,   258,   257,     0,     0,     0,    89,   344,
     603,     0,     0,   606,     0,     0,   427,   166,     0,     0,
     182,   179,   181,     0,     0,   290,     0,   331,     0,     0,
     294,    74,   218,   226,   270,   366,   379,   384,   374,   389,
     394,   369,   381,   386,   376,   391,   396,   371,     0,     0,
     380,   385,   375,   390,   395,   370,   383,   388,   378,   393,
     398,   373,   299,   382,     0,   387,   377,   392,   397,   372,
       0,   363,   365,   347,     0,   410,   412,     0,   486,     0,
       0,     0,     0,     0,   330,   332,   437,   333,   336,   335,
     448,     0,   460,   459,     0,   351,   517,   513,     0,   547,
     593,   591,   612,   616,   619,   296,   222,   527,   528,   500,
      31,   506,   533,   531,   473,   485,   482,   481,     0,   599,
     208,   210,     0,     0,    81,    92,     0,   166,    80,    78,
     194,   228,   206,   263,   281,   279,    90,   604,   605,   339,
       0,   167,     0,     0,     0,   180,   185,   186,    97,    95,
     367,   320,     0,     0,     0,   441,   442,   443,   439,   440,
     454,     0,     0,   601,     0,   272,     0,   340,   171,   162,
     165,   163,     0,   411,   413,   321,     0,   483,     0,     0,
     166,     0,     0,   584,   255,     0,     0,   164,   322
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -836,   758,   998,  -135,  -836,  -104,    13,  -836,  -836,    98,
     635,  -836,   957,  -148,  1071,  1351,  -259,   558,  -836,  -836,
     417,  -836,    37,  -475,   -77,  -836,   -81,  -836,  -358,   277,
     560,     6,  -504,  -836,   747,   865,  -699,  -157,  -836,  -836,
    -836,  -836,  -618,  -836,   427,   565,   381,  -361,  -836,  -378,
    -290,   765,   -61,    47,    33,   173,  -836,   -62,  -835,  -312,
     241,  -836,  -836,    48,  1193,  -836,  -347,   949,  -836,   204,
    -494,  -836,   737,   -58,  -836,     4,   468,  1155,  -329,   -34,
    1415,  -836,   856,  -836,     0,   513,    91,    79,   507,     7,
     -35,  -836,  -836,  -836,  -836,   799,  -163,   475,   482,  -836,
      66,  -836,  -836,   398,  -836,   -74,   158,  -836,  1120,  -836,
    -836,  -836,  -836,   773,   774,   833,  -836,   -50,  -836,  -836,
    -836,  -836,  -836,  -836,  -836,  -836,   757,   812,  -836,  -836,
    -836,  -836,   -73,  1017,  -836,  -836,  -836,  -836,  -836,   743,
    -836,  -133,    20,  1204,  -166,  -836,  -836,  -836,   -83,   -87,
    1195,  1196,    22,  -836,  -836,  -836,  1197,  -836,  -836,  -836,
    -836,  -836,  -836,   684,   622,  -836,  -836,  -836,  -836,  -836,
     739,  -836,   -92,  -836,    88,   714,  -836,   100,  -836,  -836,
     120,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,  -836,
    -836
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
       0,   152,   153,   154,   155,   156,    45,   158,   159,   293,
     161,   162,   294,   295,   296,   297,   298,   299,   605,   300,
     301,   302,   303,   304,   305,   306,   307,   308,   665,   666,
     667,    47,   310,   311,   367,   348,   878,   163,   349,   350,
     649,   650,   651,   652,   312,   313,   314,   615,   616,   619,
     315,   620,   316,   317,   318,   319,   320,   321,   322,   323,
     324,    51,   325,    52,   118,   326,    54,   585,   586,   327,
     328,   329,   330,   331,   332,    56,   333,    57,   455,    58,
     335,    60,   336,    62,   430,    64,    65,   685,    66,    67,
      68,    69,    70,    71,    72,   687,   383,   384,   385,   386,
     472,    74,    75,   473,    77,   495,   937,    78,   722,    79,
      80,    81,    82,   412,   417,    83,    84,   413,    85,    86,
     433,    87,    88,   441,   442,   443,   444,    89,    90,    91,
     457,    92,   183,   184,   185,   556,   817,   186,   404,   458,
     167,   168,   169,   170,   462,   463,   464,   171,   532,   172,
     173,   174,   175,   544,   176,   545,   177,    94,    95,    96,
      97,    98,    99,   768,   475,   100,   101,   492,   496,   476,
     477,   781,   493,   494,   478,   498,   828,   479,   204,   826,
     480,   343,   639,   105,   106,   107,   108,   109,   110,   111,
     112
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      63,   529,   114,   398,   539,   119,   715,   113,   626,   497,
     451,   379,   165,   491,   450,   445,   351,   115,   524,   672,
     551,   157,   713,   206,   337,   119,   624,   206,   206,   453,
     418,   659,   881,   454,   193,   203,   541,   717,   117,   542,
     602,   394,  1003,   799,    39,   411,   522,    48,   438,   613,
     353,   527,   613,     1,   129,     2,   164,   456,   338,   346,
     208,   209,   490,   481,   553,   439,    73,   240,   749,   830,
      63,    63,   337,   821,    63,   482,    63,   372,    63,   353,
     337,   895,   178,   393,   535,    44,   119,   613,   102,   624,
    1010,   337,    63,   337,    63,     8,    63,    48,   388,   613,
     103,   397,   845,   948,   471,   613,   160,    63,   613,    63,
     160,    63,    63,   389,   440,   179,   750,    48,    48,   432,
     104,    48,   379,    48,   452,    48,    48,   592,   449,   868,
     701,   362,   702,   142,   431,   566,   864,   363,    48,    48,
     822,    48,   368,    48,   401,   361,   120,   614,   597,   598,
     614,   180,  1003,  -292,    48,   484,    48,   593,    48,    48,
     466,   870,   423,    22,   707,   362,   708,    39,   922,   362,
     337,   346,   195,    49,    35,   165,   395,  -292,    39,   583,
     549,   483,   467,   337,   157,   614,    29,   187,   536,  1038,
     713,   396,   509,   189,   468,   686,   205,   614,   160,   510,
     340,   341,   567,   614,   485,   547,   614,   578,   638,   637,
     580,   582,   679,   181,   469,   397,   113,   182,   434,   164,
     181,   181,   816,    49,   182,   182,   558,   672,   419,    39,
     486,   837,  1011,    43,    44,   868,   569,   570,   181,   208,
     209,    50,   182,    49,    49,   420,   421,    49,   160,    49,
     831,    49,    49,   160,   854,   196,   397,   579,   581,   487,
     160,  1005,   193,   422,    49,    49,  -436,    49,   435,    49,
     592,   862,   201,   865,    16,   197,   380,   879,   254,   451,
      49,   354,    49,  -436,    49,    49,   672,   703,   704,   705,
     740,    50,   436,   488,   346,   489,   437,   346,   763,   564,
     593,    36,    37,   867,    39,   116,    41,   741,   208,   209,
     447,    50,    50,   198,   379,    50,   625,    50,   713,    50,
      50,   709,   710,   711,   337,   448,   456,   660,   872,  1041,
     857,   660,    50,    50,   199,    50,   590,    50,   394,   200,
    1041,   848,   849,   339,   119,   873,   549,   165,    50,   346,
      50,  1022,    50,    50,    36,    37,   157,   345,   116,    41,
     337,    63,   617,   337,   668,    63,  -299,   394,   337,   445,
     673,   418,   670,    63,   618,   337,   346,   641,   634,   625,
     393,   633,   642,   645,   633,   411,   450,   380,   801,   346,
     802,   164,   346,   452,   945,   668,   997,   998,    76,   290,
     291,   453,    63,   782,   165,   454,   774,    48,    48,   393,
     366,   577,    48,   157,   671,   346,   800,    46,   346,   353,
      48,   337,   509,   732,   838,   344,   625,   357,    23,   761,
     346,   795,   796,   797,   798,   360,   625,    27,   394,    36,
      37,    28,   853,   116,    41,   754,   840,   841,   164,    48,
     868,   847,   661,   378,    43,    44,   669,   693,   833,   700,
     706,   712,   810,   353,   337,   510,    48,    46,   373,   373,
     208,   209,   373,    63,   373,    63,   402,   369,    39,   364,
     393,    42,   868,   738,   424,   208,   209,    46,    46,   362,
     373,    46,    76,    46,   508,    46,    46,   446,   160,   377,
     449,    63,   592,    63,   499,    63,   512,    63,    46,    46,
      48,    46,   672,    46,   208,   209,   603,   604,   223,  -302,
      48,   166,    48,   513,    46,   166,    46,   811,    46,    46,
     165,   908,   593,    49,    49,   608,   609,   232,    49,   157,
     381,   770,   342,   514,   536,   515,    49,   713,    48,   516,
      48,   451,    48,   715,    48,   755,   756,   208,   209,   858,
     812,   517,   536,   241,   378,   653,   654,   770,   990,   770,
     949,   770,   518,   770,   164,    49,   519,   371,   374,   678,
     525,   387,   655,   656,   309,   825,   526,   255,   533,   668,
     337,   160,    49,   528,   208,   209,   846,   548,   456,   459,
     757,    50,    50,   208,   209,   572,    50,   672,   337,   543,
     550,   592,   668,   166,    50,   625,   999,   574,   160,   625,
     625,   625,   580,   580,   836,   208,   209,   813,   552,   668,
     846,   668,   337,   379,   576,   365,    49,   673,  1027,   670,
     416,   593,   366,    50,   208,   209,    49,   557,    49,   559,
     346,   381,   379,   461,   379,   805,   806,   536,    35,   362,
      50,   560,    39,   166,   860,   452,    43,    44,   166,   579,
     581,  1025,   573,   985,    49,   166,    49,   561,    49,    48,
      49,   671,   759,   808,   935,   562,   394,   571,   625,   625,
     625,   625,   625,   625,   337,   846,   846,   846,   846,   846,
     846,   587,   829,   599,    50,   208,   209,   924,   924,   924,
     924,   924,   924,   337,    50,   337,    50,  -251,   936,    39,
    1002,    63,   592,    43,    44,   889,   890,   606,   393,   501,
     538,   503,   394,   505,   507,  1006,  1007,    55,  -276,   886,
     119,   589,    50,   610,    50,   670,    50,   612,    50,   889,
     934,   754,   593,   166,   289,   775,   378,   700,   776,   777,
     627,   778,   779,   644,   780,    48,   946,    63,    48,   208,
     209,   373,   829,   950,   393,   208,   209,    46,    46,   958,
     474,   629,    46,   631,    36,    37,   632,    55,   116,    41,
      46,   500,   657,   502,   347,   504,   506,   658,   355,   356,
     721,   358,   576,   359,   676,    49,  1015,    55,    55,   208,
     209,    55,   718,    55,    48,    55,    55,   208,   209,    46,
     670,   536,   536,   888,   723,   724,   643,   725,    55,    55,
    1026,    55,   726,    55,   592,     1,    46,     2,   727,   337,
     956,   957,   846,   381,    55,   728,    55,  1016,    55,    55,
     208,   209,   739,   736,   960,   961,    61,   745,   625,   746,
    1012,   978,   979,   744,   593,   511,  1017,   889,   984,   208,
     209,   767,   753,    50,  1018,   889,   989,   208,   209,   674,
      46,   671,   889,   992,   628,   747,   337,   758,   337,   668,
      46,    49,    46,   640,    49,   889,   993,   759,   380,   910,
     911,   912,   913,   914,   915,  1019,   352,   671,   208,   209,
     764,    36,    37,   166,    39,   116,    41,   380,    46,   380,
      46,   766,    46,   662,    46,   769,    61,    61,   675,   773,
      61,   490,   352,  1020,    61,   352,   208,   209,    36,    37,
      49,    39,   116,    41,   565,   568,   397,   352,    61,   804,
      61,  1031,    61,   829,   208,   209,   208,   209,  1001,    50,
     670,   784,    50,    61,   786,    61,  1047,    61,    61,   208,
     209,   584,   788,   592,   584,   680,   362,   681,   290,  1033,
     790,   416,   807,   731,  1013,  1014,   223,  1036,  1028,  1029,
     673,  1023,   670,   592,   814,   688,   362,   689,   935,   809,
     856,   818,   671,   593,   823,   232,   166,   815,    50,   693,
     819,    39,   129,  1034,   820,    43,    44,  1039,  1029,   290,
     291,   353,   674,   593,   538,   674,  1013,  1046,   824,   376,
     633,   241,   936,   166,   832,   827,   833,   839,   834,   851,
     591,   859,   429,   831,   861,   835,   577,   875,   576,    46,
     460,   876,   885,   869,   877,   255,   882,   611,   887,   596,
      48,   933,   938,   592,   944,   695,   362,   696,    48,   902,
     903,   904,   905,   906,   907,   378,   947,   954,   955,    48,
     959,    35,   962,   963,    38,    39,   635,   674,    42,    43,
      44,   142,   630,   593,   930,   964,   930,    55,    55,    35,
      36,    37,    55,    39,   116,    41,    42,   965,   972,   967,
      55,   968,   969,   970,   982,   971,   531,   973,   975,   721,
     974,   576,   983,   988,   531,   986,   991,   460,   994,   995,
    1021,   987,   682,   683,   684,    46,   546,  1030,    46,    55,
     376,   596,  1024,   555,  1032,   630,   674,  1035,  1040,  1044,
     538,  1043,   690,   691,   692,  1001,    55,  1048,   720,   771,
     534,   803,   381,   850,   575,   767,  1009,   607,   538,   916,
     917,   918,   919,   920,   921,     1,   588,     2,   576,   334,
     855,   381,   714,   381,    46,   785,    49,   787,   931,   789,
    1042,   791,   729,    53,    49,   730,   663,   932,   403,   748,
      55,   716,   554,   188,    93,    49,   762,   191,   192,   194,
      55,   783,    55,     0,   202,   772,   352,   352,     0,     0,
       0,   352,   697,   698,   699,   596,     0,   334,     0,   352,
     208,   209,     0,     0,     0,   334,     0,     0,    55,     0,
      55,     0,    55,     0,    55,     0,     0,   592,   334,   680,
     362,   681,   674,     0,    50,   792,     0,   793,   352,     0,
       0,     0,    50,    53,    53,     0,     0,    53,     0,    53,
       0,    53,    16,    50,     0,   352,     0,   593,     0,     0,
     592,     0,   695,   362,   696,    53,     0,    53,     0,    53,
      35,   146,   147,    38,   540,   149,   150,   151,     0,    44,
      53,     0,    53,     0,    53,    53,   648,     0,     0,     0,
     593,     0,     0,     0,     0,     0,     0,     0,     0,   352,
      30,   664,     0,     0,     0,   334,     0,   674,     0,   352,
       0,    61,   677,     0,     0,     0,     0,     0,   334,     0,
     596,     0,   630,     0,     0,     0,   674,    35,     0,     0,
      38,    39,   664,     0,    42,    43,    44,    61,   190,    61,
       0,    61,     0,    61,     0,   594,     0,     0,     0,    55,
       0,     0,   674,     0,     0,     0,     0,     0,     0,     0,
       0,   733,   734,     0,   737,     0,   125,   126,   563,     0,
       0,   742,   743,     0,     0,   127,     0,     0,     0,   538,
       0,     0,   752,     0,     0,     0,   682,   683,   684,     0,
       0,   129,     0,     0,     0,    59,     0,   891,   892,   893,
     894,   460,     0,     0,     0,     0,     0,     0,     0,   596,
      46,     0,     0,     0,     0,     0,   132,     0,    46,   697,
     698,   699,   596,   630,   135,     0,   662,   594,  1008,    46,
       0,     0,     0,     0,     0,    55,     0,     0,    55,     0,
       0,     0,     0,     0,     0,     0,     0,   674,     0,     0,
       0,   531,   531,   531,   531,     0,     0,     0,     0,   334,
     141,     0,     0,     0,     0,    59,    59,   382,   352,    59,
     142,     0,   636,    59,     0,     0,     0,     0,     0,   674,
     594,     0,   531,   121,    55,   122,     0,    59,     0,    59,
       0,    59,     0,     0,     0,     0,   145,   124,   334,   334,
       0,     0,    59,   334,    59,     0,    59,    59,    39,     0,
     334,   594,     0,     7,     0,     0,     0,     0,     0,   128,
       0,   966,     0,     0,     0,     0,   664,   460,     0,     0,
     334,     0,     0,   844,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   460,    53,     0,    15,   664,
       0,   133,     0,     0,   352,   134,   334,   352,   334,   980,
       0,   981,     0,     0,   136,     0,   664,   863,   664,     0,
       0,     0,   719,     0,     0,    53,     0,   874,   382,     0,
       0,     0,   594,     0,   139,     0,     0,   880,     0,   140,
       0,     0,     0,     0,     0,   996,     0,   594,     0,   334,
       0,     0,     0,   352,     0,     0,   594,     0,   143,     0,
       0,     0,     0,     0,     0,     0,     0,   896,   897,   898,
     899,   900,   901,     0,     0,   595,   594,     0,     0,     0,
       0,   376,   909,   909,   909,   909,   909,   909,     0,     0,
       0,     0,     0,   765,     0,     0,    53,     0,    53,     0,
     376,     0,   376,     0,   596,   630,   630,   630,   630,   630,
     630,   939,   940,   941,   942,   943,     0,     0,   125,   126,
       0,     0,     0,     0,    53,     0,    53,   127,    53,     0,
      53,     0,   951,     0,     0,   794,   952,   953,   734,     0,
       0,     0,     0,   129,     0,     0,     0,     0,     0,   594,
     130,     0,     0,   883,     0,     0,     0,   595,     0,     0,
       0,     0,     0,     0,     0,   594,   871,     0,   132,     0,
       0,     0,     0,     0,   334,   334,   135,   121,   594,   122,
      55,     0,     0,     0,   490,     0,     0,     1,    55,     2,
       0,   124,     0,   334,     0,     0,     0,   334,     0,    55,
       0,     0,     0,   976,     0,   977,     0,     7,     0,     0,
     595,     0,   141,   128,   334,     0,   334,     0,     0,     0,
     382,     0,   142,     0,     0,     0,   460,   125,   126,   575,
       0,     0,     0,   406,   594,   594,   127,     0,   594,     0,
       0,   595,    15,   594,   594,   133,     0,     0,   145,   134,
       0,     0,   129,   594,     0,     0,   794,     0,   136,   130,
      39,     0,  1000,     0,     0,  1004,   880,     0,     0,     0,
       0,     0,     0,     0,     0,   407,   664,   132,   139,   334,
       0,     0,     0,   140,    16,   135,   334,   334,   334,   334,
     334,   334,     0,     0,   408,     0,     0,     0,   334,   352,
     334,     0,   143,     0,     0,     0,     0,   352,     0,     0,
       0,     0,   595,     0,     0,     0,     0,     0,   352,     0,
      59,   141,     0,     0,   121,     0,   122,   595,   409,     0,
       0,   142,    30,     0,     0,   410,   595,     0,   124,     0,
       0,     0,     0,     0,    53,   594,    59,     0,    59,     0,
      59,   228,    59,     0,     7,     0,   595,   145,   231,    35,
     128,     0,    38,    39,   594,     0,    42,    43,    44,    39,
     235,   236,   523,     0,     0,   594,     0,     0,     0,     0,
       0,   594,     0,     0,     0,     0,     0,     0,     0,    15,
      53,     0,   133,     0,     0,     0,   134,   594,   594,   594,
     594,   594,   594,     0,     0,   136,     0,     0,     0,  1037,
     594,     0,     0,     0,     0,   259,     0,     0,     0,     0,
     261,   262,     0,     0,   334,   139,     0,     0,  1045,   595,
     140,     0,     0,   884,   266,     0,     0,     0,     0,     0,
     594,   594,   594,   594,   594,   595,     0,     0,     0,   143,
       0,     0,   594,   594,   594,   621,     0,     0,   595,     0,
       0,     0,     0,     0,   622,     0,   623,     0,     0,     0,
       0,   334,     0,   334,   334,   213,     0,   594,   594,    35,
      36,    37,   794,    39,   116,    41,    42,    43,    44,     0,
       0,     0,     0,     0,     0,     0,     0,   223,   224,     0,
       0,   594,     0,     0,     0,   594,     0,     0,     0,     0,
       0,     0,     0,     0,   595,   595,   232,     0,   595,   735,
       0,   228,     0,   595,   595,     0,     0,     0,   231,     0,
     228,     0,     0,   595,     0,     0,   238,   231,   594,   382,
     235,   236,   241,     0,     0,     0,   594,     0,     0,   235,
     236,     0,   923,   925,   926,   927,   928,   929,   382,     0,
     382,     0,     0,     0,   253,     0,   255,     0,   257,   258,
       0,     0,     0,     0,     0,     0,     0,   794,     0,     0,
       0,   465,     0,     0,     0,   259,     0,     0,     0,     0,
     261,   262,     0,     0,   259,     0,     1,     0,     2,   261,
     262,     0,     3,     0,   266,     0,     0,     0,     0,    30,
       0,     4,     0,   266,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   281,     0,   595,     0,     0,     0,     0,
       0,     0,   285,     5,     6,     0,    35,   286,    37,     0,
      39,   116,    41,    42,   595,     0,     0,     0,     0,     8,
       0,     0,    38,    39,     9,   595,     0,    43,    44,     0,
       0,   595,    39,     0,     0,    10,    43,    44,     0,    11,
       0,     0,    12,    13,     0,    14,     0,   595,   595,   595,
     595,   595,   595,     0,     0,     0,     0,     0,     0,     0,
     595,     0,     0,    16,     0,     0,     0,     0,     0,     0,
      17,    18,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    19,    20,     0,     0,     0,    21,    22,    23,    24,
     595,   595,   595,   595,   595,    25,    26,    27,     0,     0,
       0,    28,   595,   595,   595,     0,     0,     0,     0,     0,
      29,    30,     0,     0,     0,     0,     0,     0,     0,    31,
       0,     0,     0,     0,     0,     0,     0,   595,   595,    32,
       0,    33,     0,    34,     0,     0,     0,     0,    35,    36,
      37,    38,    39,    40,    41,    42,    43,    44,     0,     0,
     207,   595,   208,   209,     0,   595,     0,     0,     0,   210,
       0,   211,     0,     0,     0,   414,     0,     0,     0,     0,
     213,     0,     0,     0,     0,   214,   215,     0,     0,     0,
       0,   216,   217,   218,   219,   220,   221,   222,   595,     0,
       0,     0,   223,   224,     0,     0,   595,     0,     0,     0,
     225,   226,   227,   228,     0,   406,     0,     0,   229,   230,
     231,   232,     0,     0,     0,   233,   234,     0,     0,     0,
       0,     0,   235,   236,     0,     0,     0,     0,     0,   237,
       0,   238,     0,   239,     0,   240,     0,   241,     0,     0,
       0,   242,     0,   132,   243,     0,   244,   407,   245,     0,
     246,   247,   248,   249,   250,   251,    16,   252,     0,   253,
     254,   255,   256,   257,   258,     0,   408,   259,     0,     0,
     260,     0,   261,   262,     0,     0,     0,   263,     0,     0,
       0,     0,     0,     0,   264,   265,   266,   141,     0,     0,
       0,   267,   268,   269,     0,   270,   271,     0,   272,   273,
     409,   274,     0,     0,    30,   275,     0,   410,   276,   277,
       0,     0,     0,     0,     0,   278,   279,   280,   281,   282,
     283,     0,     0,   284,     0,     0,     0,   285,     0,     0,
       0,    35,   286,   287,    38,   415,    40,   288,    42,    43,
      44,   289,     0,   290,   291,   292,   207,     0,   208,   209,
       0,     0,     0,     0,     0,   210,     0,   211,     0,     0,
       0,     0,     0,     0,     0,     0,   213,     0,     0,     0,
       0,   214,   215,     0,     0,     0,     0,   216,   217,   218,
     219,   220,   221,   222,     0,     0,     0,     0,   223,   224,
       0,     0,     0,     0,     0,     0,   225,   226,   227,   228,
       0,   406,     0,     0,   229,   230,   231,   232,     0,     0,
       0,   233,   234,     0,     0,     0,     0,     0,   235,   236,
       0,     0,     0,     0,     0,   237,     0,   238,     0,   239,
       0,   240,     0,   241,     0,     0,     0,   242,     0,   132,
     243,     0,   244,   407,   245,     0,   246,   247,   248,   249,
     250,   251,    16,   252,     0,   253,   254,   255,   256,   257,
     258,     0,   408,   259,     0,     0,   260,     0,   261,   262,
       0,     0,     0,   263,     0,     0,     0,     0,     0,     0,
     264,   265,   266,   141,     0,     0,     0,   267,   268,   269,
       0,   270,   271,     0,   272,   273,   409,   274,     0,     0,
      30,   275,     0,   410,   276,   277,     0,     0,     0,     0,
       0,   278,   279,   280,   281,   282,   283,     0,     0,   284,
       0,     0,     0,   285,     0,     0,     0,    35,   286,   287,
      38,   415,    40,   288,    42,    43,    44,   289,     0,   290,
     291,   292,   207,     0,   208,   209,     0,     0,     0,     0,
       0,   210,     0,   211,     0,     0,     0,   212,     0,     0,
       0,     0,   213,     0,     0,     0,     0,   214,   215,     0,
       0,     0,     0,   216,   217,   218,   219,   220,   221,   222,
       0,     0,     0,     0,   223,   224,     0,     0,     0,     0,
       0,     0,   225,   226,   227,   228,     0,     0,     0,     0,
     229,   230,   231,   232,     0,     0,     0,   233,   234,     0,
       0,     0,     0,     0,   235,   236,     0,     0,     0,     0,
       0,   237,     0,   238,     0,   239,     0,   240,     0,   241,
       0,     0,     0,   242,     0,   132,   243,     0,   244,     0,
     245,     0,   246,   247,   248,   249,   250,   251,    16,   252,
       0,   253,   254,   255,   256,   257,   258,     0,     0,   259,
       0,     0,   260,     0,   261,   262,     0,     0,     0,   263,
       0,     0,     0,     0,     0,     0,   264,   265,   266,   141,
       0,     0,     0,   267,   268,   269,     0,   270,   271,     0,
     272,   273,     0,   274,     0,     0,    30,   275,     0,     0,
     276,   277,     0,     0,     0,     0,     0,   278,   279,   280,
     281,   282,   283,     0,     0,   284,     0,     0,     0,   285,
       0,     0,     0,    35,   286,   287,    38,    39,    40,   288,
      42,    43,    44,   289,     0,   290,   291,   292,   207,     0,
     208,   209,   537,     0,     0,     0,     0,   210,     0,   211,
       0,     0,     0,     0,     0,     0,     0,     0,   213,     0,
       0,     0,     0,   214,   215,     0,     0,     0,     0,   216,
     217,   218,   219,   220,   221,   222,     0,     0,     0,     0,
     223,   224,     0,     0,     0,     0,     0,     0,   225,   226,
     227,   228,     0,     0,     0,     0,   229,   230,   231,   232,
       0,     0,     0,   233,   234,     0,     0,     0,     0,     0,
     235,   236,     0,     0,     0,     0,     0,   237,     0,   238,
       0,   239,     0,   240,     0,   241,     0,     0,     0,   242,
       0,   132,   243,     0,   244,     0,   245,     0,   246,   247,
     248,   249,   250,   251,    16,   252,     0,   253,   254,   255,
     256,   257,   258,     0,     0,   259,     0,     0,   260,     0,
     261,   262,     0,     0,     0,   263,     0,     0,     0,     0,
       0,     0,   264,   265,   266,   141,     0,     0,     0,   267,
     268,   269,     0,   270,   271,     0,   272,   273,     0,   274,
       0,     0,    30,   275,     0,     0,   276,   277,     0,     0,
       0,     0,     0,   278,   279,   280,   281,   282,   283,     0,
       0,   284,     0,     0,     0,   285,     0,     0,     0,    35,
     286,   287,    38,    39,    40,   288,    42,    43,    44,   289,
       0,   290,   291,   292,   207,     0,   208,   209,     0,     0,
       0,     0,     0,   210,     0,   211,     0,     0,     0,     0,
       0,     0,     0,     0,   213,     0,     0,     0,     0,   214,
     215,     0,     0,     0,     0,   216,   217,   218,   219,   220,
     221,   222,     0,     0,     0,     0,   223,   224,     0,     0,
       0,     0,     0,     0,   225,   226,   227,   228,     0,     0,
       0,     0,   229,   230,   231,   232,     0,     0,     0,   233,
     234,     0,     0,     0,     0,     0,   235,   236,     0,     0,
       0,     0,     0,   237,     0,   238,    11,   239,     0,   240,
       0,   241,     0,     0,     0,   242,     0,   132,   243,     0,
     244,     0,   245,     0,   246,   247,   248,   249,   250,   251,
      16,   252,     0,   253,   254,   255,   256,   257,   258,     0,
       0,   259,     0,     0,   260,     0,   261,   262,     0,     0,
       0,   263,     0,     0,     0,     0,     0,     0,   264,   265,
     266,   141,     0,     0,     0,   267,   268,   269,     0,   270,
     271,     0,   272,   273,     0,   274,     0,     0,    30,   275,
       0,     0,   276,   277,     0,     0,     0,     0,     0,   278,
     279,   280,   281,   282,   283,     0,     0,   284,     0,     0,
       0,   285,     0,     0,     0,    35,   286,   287,    38,    39,
      40,   288,    42,    43,    44,   289,     0,   290,   291,   292,
     207,     0,   208,   209,   852,     0,     0,     0,     0,   210,
       0,   211,     0,     0,     0,     0,     0,     0,     0,     0,
     213,     0,     0,     0,     0,   214,   215,     0,     0,     0,
       0,   216,   217,   218,   219,   220,   221,   222,     0,     0,
       0,     0,   223,   224,     0,     0,     0,     0,     0,     0,
     225,   226,   227,   228,     0,     0,     0,     0,   229,   230,
     231,   232,     0,     0,     0,   233,   234,     0,     0,     0,
       0,     0,   235,   236,     0,     0,     0,     0,     0,   237,
       0,   238,     0,   239,     0,   240,     0,   241,     0,     0,
       0,   242,     0,   132,   243,     0,   244,     0,   245,     0,
     246,   247,   248,   249,   250,   251,    16,   252,     0,   253,
     254,   255,   256,   257,   258,     0,     0,   259,     0,     0,
     260,     0,   261,   262,     0,     0,     0,   263,     0,     0,
       0,     0,     0,     0,   264,   265,   266,   141,     0,     0,
       0,   267,   268,   269,     0,   270,   271,     0,   272,   273,
       0,   274,     0,     0,    30,   275,     0,     0,   276,   277,
       0,     0,     0,     0,     0,   278,   279,   280,   281,   282,
     283,     0,     0,   284,     0,     0,     0,   285,     0,     0,
       0,    35,   286,   287,    38,    39,    40,   288,    42,    43,
      44,   289,     0,   290,   291,   292,   375,     0,   208,   209,
       0,     0,     0,     0,     0,   210,     0,   211,     0,     0,
       0,     0,     0,     0,     0,     0,   213,     0,     0,     0,
       0,   214,   215,     0,     0,     0,     0,   216,   217,   218,
     219,   220,   221,   222,     0,     0,     0,     0,   223,   224,
       0,     0,     0,     0,     0,     0,   225,   226,   227,   228,
       0,     0,     0,     0,   229,   230,   231,   232,     0,     0,
       0,   233,   234,     0,     0,     0,     0,     0,   235,   236,
       0,     0,     0,     0,     0,   237,     0,   238,     0,   239,
       0,   240,     0,   241,     0,     0,     0,   242,     0,   132,
     243,     0,   244,     0,   245,     0,   246,   247,   248,   249,
     250,   251,    16,   252,     0,   253,   254,   255,   256,   257,
     258,     0,     0,   259,     0,     0,   260,     0,   261,   262,
       0,     0,     0,   263,     0,     0,     0,     0,     0,     0,
     264,   265,   266,   141,     0,     0,     0,   267,   268,   269,
       0,   270,   271,     0,   272,   273,     0,   274,     0,     0,
      30,   275,     0,     0,   276,   277,     0,     0,     0,     0,
       0,   278,   279,   280,   281,   282,   283,     0,     0,   284,
       0,     0,     0,   285,     0,     0,     0,    35,   286,   287,
      38,    39,    40,   288,    42,    43,    44,   289,     0,   290,
     291,   292,   207,     0,   208,   209,     0,     0,     0,     0,
       0,   210,     0,   211,     0,     0,     0,     0,     0,     0,
       0,     0,   213,     0,     0,     0,     0,   214,   215,     0,
       0,     0,     0,   216,   217,   218,   219,   220,   221,   222,
       0,     0,     0,     0,   223,   224,     0,     0,     0,     0,
       0,     0,   225,   226,   227,   228,     0,     0,     0,     0,
     229,   230,   231,   232,     0,     0,     0,   233,   234,     0,
       0,     0,     0,     0,   235,   236,     0,     0,     0,     0,
       0,   237,     0,   238,     0,   239,     0,   240,     0,   241,
       0,     0,     0,   242,     0,   132,   243,     0,   244,     0,
     245,     0,   246,   247,   248,   249,   250,   251,    16,   252,
       0,   253,   254,   255,   256,   257,   258,     0,     0,   259,
       0,     0,   260,     0,   261,   262,     0,     0,     0,   263,
       0,     0,     0,     0,     0,     0,   264,   265,   266,   141,
       0,     0,     0,   267,   268,   269,     0,   270,   271,     0,
     272,   273,     0,   274,     0,     0,    30,   275,     0,     0,
     276,   277,     0,     0,     0,     0,     0,   278,   279,   280,
     281,   282,   283,     0,     0,   284,     0,     0,     0,   285,
       0,     0,     0,    35,   286,   287,    38,    39,    40,   288,
      42,    43,    44,   289,     0,   290,   291,   292,   207,     0,
     208,   209,     0,     0,     0,     0,     0,   210,     0,   211,
       0,     0,     0,     0,     0,     0,     0,     0,   213,     0,
       0,     0,     0,   214,   215,     0,     0,     0,     0,   216,
     217,   218,   219,   220,   221,   222,     0,     0,     0,     0,
     223,   224,     0,     0,     0,     0,     0,     0,   225,   226,
     227,   228,     0,     0,     0,     0,   229,   230,   231,   232,
       0,     0,     0,   233,   234,     0,     0,     0,     0,     0,
     235,   236,     0,     0,     0,     0,     0,   237,     0,   238,
       0,   239,     0,     0,     0,   241,     0,     0,     0,   242,
       0,   132,   243,     0,   244,     0,   245,     0,   246,   247,
     248,   249,   250,   251,     0,   252,     0,   253,     0,   255,
     256,   257,   258,     0,     0,   259,     0,     0,   260,     0,
     261,   262,     0,     0,     0,   263,     0,     0,     0,     0,
       0,     0,   264,   265,   266,   141,     0,     0,     0,   267,
     268,   269,     0,   270,   271,     0,   272,   273,     0,   274,
       0,     0,    30,   275,     0,     0,   276,   277,     0,     0,
       0,     0,     0,   278,   279,   280,   281,   282,   283,     0,
       0,   284,     0,     0,     0,   285,     0,     0,     0,    35,
     286,   287,    38,    39,   116,   288,    42,    43,    44,   289,
       0,   290,   291,   292,   751,     0,   208,   209,     0,     0,
       0,     0,     0,   210,     0,   211,     0,     0,     0,     0,
       0,     0,     0,     0,   213,     0,     0,     0,     0,   214,
     215,     0,     0,     0,     0,   216,   217,   218,   219,   220,
     221,   222,     0,     0,     0,     0,   223,   224,     0,     0,
       0,     0,     0,     0,   225,     0,     0,   228,     0,     0,
       0,     0,   229,   230,   231,   232,     0,     0,     0,   233,
     234,     0,     0,     0,     0,     0,   235,   236,     0,     0,
       0,     0,     0,   237,     0,   238,     0,   239,     0,     0,
       0,   241,     0,     0,     0,   242,     0,   132,   243,     0,
     244,     0,     0,     0,   246,   247,   248,   249,   250,   251,
       0,   252,     0,   253,     0,   255,   256,   257,   258,     0,
       0,   259,     0,     0,   260,     0,   261,   262,     0,     0,
       0,   263,     0,     0,     0,     0,     0,     0,     0,   265,
     266,   141,     0,     0,     0,   267,   268,   269,     0,   270,
     271,     0,   272,   273,     0,   274,     0,     0,    30,   275,
       0,     0,   276,   277,     0,     0,     0,     0,     0,   278,
     279,     0,   281,   282,   283,     0,     0,   284,     0,     0,
       0,   285,     0,     0,     0,    35,   286,    37,     0,    39,
     116,   288,    42,    43,    44,     0,     0,   290,   291,   292,
     842,     0,   208,   209,     0,     0,     0,     0,     0,     1,
       0,     2,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   214,   215,     0,     0,     0,
       0,   216,   217,   218,   219,   220,   221,   222,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     225,   226,   227,   228,     0,     0,     0,     0,   229,   230,
     231,     0,     0,     0,     0,   233,   234,     0,     0,     0,
       0,     0,   235,   236,     0,     0,     0,     0,     0,   237,
       0,     0,     0,   239,     0,     0,     0,     0,     0,     0,
       0,   242,     0,   132,   243,     0,   244,     0,   245,     0,
     246,   247,   248,   249,   250,   251,     0,   252,     0,     0,
       0,     0,   256,     0,     0,     0,     0,   259,     0,     0,
     260,     0,   261,   262,     0,     0,     0,   263,     0,     0,
       0,     0,     0,     0,   264,   265,   266,   141,     0,     0,
       0,   267,   268,   269,     0,   270,   271,     0,   272,   273,
       0,   274,     0,     0,     0,   275,     0,     0,   276,   277,
       0,     0,     0,     0,     0,   278,   279,   280,     0,   282,
     283,     0,     0,   284,     0,     0,     0,   425,     0,   208,
     209,     0,     0,   843,    38,    39,     1,   428,     2,    43,
      44,   289,     0,   290,   291,   292,     0,     0,     0,     0,
       0,     0,   214,   215,     0,     0,     0,     0,   216,   217,
     218,   219,   220,   221,   222,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   225,     0,     0,
     228,     0,     0,     0,     0,   229,   230,   231,     0,     0,
       0,     0,   233,   234,     0,     0,     0,     0,     0,   235,
     236,     0,     0,     0,     0,     0,   237,     0,     0,     0,
     239,   426,     0,     0,     0,     0,     0,     0,   242,     0,
     132,   243,     0,   244,     0,     0,     0,   246,   247,   248,
     249,   250,   251,     0,   252,     0,     0,     0,     0,   256,
       0,     0,     0,     0,   259,     0,     0,   260,     0,   261,
     262,     0,     0,     0,   263,     0,     0,     0,     0,     0,
       0,     0,   265,   266,   141,     0,     0,     0,   267,   268,
     269,     0,   270,   271,     0,   272,   273,     0,   274,     0,
       0,     0,   275,     0,     0,   276,   277,     0,     0,     0,
       0,     0,   278,   279,     0,     0,   282,   283,   427,   425,
     284,   208,   209,   646,     0,     0,     0,   647,     1,     0,
       2,     0,    39,     0,   428,     0,    43,    44,     0,     0,
     290,   291,   292,     0,   214,   215,     0,     0,     0,     0,
     216,   217,   218,   219,   220,   221,   222,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   225,
       0,     0,   228,     0,     0,     0,     0,   229,   230,   231,
       0,     0,     0,     0,   233,   234,     0,     0,     0,     0,
       0,   235,   236,     0,     0,     0,     0,     0,   237,     0,
       0,     0,   239,     0,     0,     0,     0,     0,     0,     0,
     242,     0,   132,   243,     0,   244,     0,     0,     0,   246,
     247,   248,   249,   250,   251,     0,   252,     0,     0,     0,
       0,   256,     0,     0,     0,     0,   259,     0,     0,   260,
       0,   261,   262,     0,     0,     0,   263,     0,     0,     0,
       0,     0,     0,     0,   265,   266,   141,     0,     0,     0,
     267,   268,   269,     0,   270,   271,     0,   272,   273,     0,
     274,     0,     0,     0,   275,     0,     0,   276,   277,     0,
       0,     0,     0,     0,   278,   279,     0,     0,   282,   283,
       0,   425,   284,   208,   209,   530,     0,     0,     0,     0,
       1,     0,     2,     0,    39,     0,   428,     0,    43,    44,
       0,     0,   290,   291,   292,     0,   214,   215,     0,     0,
       0,     0,   216,   217,   218,   219,   220,   221,   222,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   225,     0,     0,   228,     0,     0,     0,     0,   229,
     230,   231,     0,     0,     0,     0,   233,   234,     0,     0,
       0,     0,     0,   235,   236,     0,     0,     0,     0,     0,
     237,     0,     0,     0,   239,     0,     0,     0,     0,     0,
       0,     0,   242,     0,   132,   243,   121,   244,   122,     0,
       0,   246,   247,   248,   249,   250,   251,     0,   252,     0,
     124,     0,     0,   256,     0,     0,     0,     0,   259,     0,
       0,   260,     0,   261,   262,     0,     7,     0,   263,     0,
       0,     0,   128,     0,     0,     0,   265,   266,   141,     0,
       0,     0,   267,   268,   269,     0,   270,   271,     0,   272,
     273,     0,   274,     0,     0,     0,   275,     0,     0,   276,
     277,    15,     0,     0,   133,     0,   278,   279,   134,     0,
     282,   283,     0,   425,   284,   208,   209,   136,     0,     0,
       0,   647,     1,     0,     2,     0,    39,     0,   428,     0,
      43,    44,     0,     0,   290,   291,   292,   139,   214,   215,
       0,     0,   140,     0,   216,   217,   218,   219,   220,   221,
     222,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   143,     0,   225,     0,     0,   228,     0,     0,     0,
       0,   229,   230,   231,     0,     0,     0,     0,   233,   234,
       0,     0,     0,     0,     0,   235,   236,     0,     0,     0,
       0,     0,   237,     0,     0,     0,   239,     0,     0,     0,
       0,     0,     0,     0,   242,     0,   132,   243,     0,   244,
       0,     0,     0,   246,   247,   248,   249,   250,   251,     0,
     252,     0,     0,     0,     0,   256,     0,     0,     0,     0,
     259,     0,     0,   260,     0,   261,   262,     0,     0,     0,
     263,     0,     0,     0,     0,     0,     0,     0,   265,   266,
     141,     0,     0,     0,   267,   268,   269,     0,   270,   271,
       0,   272,   273,     0,   274,     0,     0,     0,   275,     0,
       0,   276,   277,     0,     0,     0,     0,     0,   278,   279,
       0,     0,   282,   283,     0,   425,   284,   208,   209,     0,
       0,     0,     0,     0,     1,     0,     2,     0,    39,     0,
     428,     0,    43,    44,     0,     0,   290,   291,   292,     0,
     214,   215,     0,     0,     0,     0,   216,   217,   218,   219,
     220,   221,   222,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   225,     0,     0,   228,     0,
       0,     0,     0,   229,   230,   231,     0,     0,     0,     0,
     233,   234,     0,     0,     0,     0,     0,   235,   236,     0,
       0,     0,     0,     0,   237,     0,     0,     0,   239,     0,
       0,     0,     0,     0,     0,     0,   242,     0,   132,   243,
       0,   244,     0,     0,     0,   246,   247,   248,   249,   250,
     251,     0,   252,     0,     0,     0,     0,   256,     0,     0,
       0,     0,   259,     0,     0,   260,     0,   261,   262,     0,
       0,     0,   263,     0,     0,     0,     0,     0,     0,     0,
     265,   266,   141,     0,     0,     0,   267,   268,   269,     0,
     270,   271,     0,   272,   273,     0,   274,     0,     0,     0,
     275,     0,     0,   276,   277,     0,     0,     0,     0,     0,
     278,   279,     0,     0,   282,   283,   425,     0,   284,     0,
     600,   601,     0,     0,     0,     1,     0,     2,     0,     0,
      39,     0,   428,     0,    43,    44,     0,     0,   290,   291,
     292,   214,   215,     0,     0,     0,     0,   216,   217,   218,
     219,   220,   221,   222,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   225,     0,     0,   228,
       0,     0,     0,     0,   229,   230,   231,     0,     0,     0,
       0,   233,   234,     0,     0,     0,     0,     0,   235,   236,
       0,     0,     0,     0,     0,   237,     0,     0,     0,   239,
       0,     0,     0,     0,     0,     0,     0,   242,     0,   132,
     243,     0,   244,     0,     0,     0,   246,   247,   248,   249,
     250,   251,     0,   252,     0,     0,     0,     0,   256,     0,
       0,     0,     0,   259,     0,     0,   260,     0,   261,   262,
       0,     0,     0,   263,     0,     0,     0,     0,     0,     0,
       0,   265,   266,   141,     0,     0,     0,   267,   268,   269,
       0,   270,   271,     0,   272,   273,     0,   274,     0,     0,
       0,   275,     0,     0,   276,   277,     0,     0,     0,     0,
       0,   278,   279,     0,     0,   282,   283,   425,     0,   284,
       0,     0,     0,     0,     0,     0,     1,     0,     2,     0,
       0,    39,     0,   428,     0,    43,    44,     0,     0,   290,
     291,   292,   214,   215,     0,     0,     0,     0,   216,   217,
     218,   219,   220,   221,   222,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   225,     0,     0,
     228,     0,     0,     0,     0,   229,   230,   231,     0,     0,
       0,     0,   233,   234,     0,     0,     0,   228,     0,   235,
     236,     0,     0,     0,   231,     0,   237,     0,     0,     0,
     239,     0,     0,     0,     0,     0,   235,   236,   242,     0,
     132,   243,     0,   244,     0,     0,     0,   246,   247,   248,
     249,   250,   251,     0,   252,     0,     0,   760,     0,   256,
       0,     0,     0,     0,   259,     0,     1,   260,     2,   261,
     262,     0,     0,     0,   263,     0,     0,     0,     0,     0,
       0,   259,   265,   266,   141,     0,   261,   262,   267,   268,
     269,     0,   270,   271,     0,   272,   273,     0,   274,   223,
     266,     0,   275,     0,     0,   276,   277,     0,   226,     0,
       0,     0,   278,   279,     0,   621,   282,   283,   232,     0,
     284,     0,     0,     0,   622,     0,   623,     0,     0,     0,
       0,     0,    39,     0,   428,   213,    43,    44,   238,     0,
     290,   291,   292,     0,   241,    35,    36,    37,    38,    39,
     116,    41,    42,    43,    44,     0,     0,   223,   224,     0,
       0,     0,     0,    16,     0,     0,     0,     0,   255,     0,
     257,   258,     0,   621,     0,     0,   232,     0,     0,     0,
       0,     0,   622,     0,   623,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   694,     0,   238,     0,     0,     0,
       0,     0,   241,   622,     0,   623,     0,     0,     0,     0,
       0,    30,     0,     0,     0,   223,   224,     0,     0,     0,
       0,     0,     0,     0,   253,   281,   255,     0,   257,   258,
       0,     0,     0,     0,   232,     0,   223,   224,    35,     0,
       0,    38,    39,     0,     0,    42,    43,    44,   289,     0,
     290,   291,   292,     0,   238,   232,     0,     0,     0,     0,
     241,     0,     0,     0,     0,     0,     0,     0,     0,    30,
       0,     0,     0,     0,     0,   238,     0,     0,     0,     0,
       0,   241,     0,   281,   255,     0,   257,   258,     0,     0,
       0,     0,   285,     0,     0,     0,    35,   286,    37,     0,
      39,   116,    41,    42,     0,   255,     0,   257,   258,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    30,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   281,     0,     0,     0,     1,     0,     2,    30,     0,
     285,     0,     0,     0,    35,   286,    37,     0,    39,   116,
      41,    42,   281,     0,     0,     0,     1,     0,     2,     0,
       0,   285,   405,     0,     0,    35,   286,    37,   223,    39,
     116,    41,    42,     0,     0,     0,     0,   226,     0,   228,
       0,     0,     0,     0,     0,     0,   231,   232,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   235,   236,
       0,     0,   406,     0,     0,     0,     0,   238,     0,     0,
       0,     0,     0,   241,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    16,     0,     0,     0,     0,   255,     0,   257,
     258,     0,     0,   259,   407,     0,     0,     0,   261,   262,
       0,     0,     0,    16,     0,     0,     0,     0,     0,     0,
       0,     0,   266,   408,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,     0,     0,     0,     0,     1,     0,     2,     0,     0,
       0,     3,     0,     0,   281,     0,     0,   409,     0,     0,
       4,    30,     0,     0,   410,     0,     0,    35,    36,    37,
      38,    39,   116,    41,    42,    43,    44,   289,     0,   290,
     291,   292,     5,     6,     0,     0,     0,     0,    35,     0,
       0,    38,    39,     7,     0,    42,    43,    44,     8,     0,
       0,     0,     0,     9,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    10,     0,     0,     0,    11,     0,
       0,    12,    13,     0,    14,     0,     0,     0,    15,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    16,     0,     0,     0,     0,     0,     0,    17,
      18,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      19,    20,     0,     0,     0,    21,    22,    23,    24,     0,
       0,     0,     0,     0,    25,    26,    27,     0,     0,     0,
      28,     0,     0,     0,     0,     0,     0,     0,     0,    29,
      30,     1,     0,     2,     0,     0,     0,     3,    31,     0,
       0,     0,     0,     0,     0,     0,     4,     0,    32,     0,
      33,     0,    34,     0,     0,     0,     0,    35,    36,    37,
      38,    39,    40,    41,    42,    43,    44,     0,     5,     6,
       0,     0,     0,     0,     0,     1,   470,     2,     0,     0,
       0,     0,     0,     0,     8,     0,     0,     0,     0,     9,
       0,     0,     0,   471,     0,     0,     0,     0,     0,     0,
      10,     0,     0,     0,    11,     0,     0,    12,    13,     0,
      14,     0,     0,     0,     0,     0,     0,     0,     0,   228,
       0,     0,     0,     0,     0,     0,   231,     0,    16,     0,
       0,     0,     0,     0,     0,    17,    18,     0,   235,   236,
       0,     0,     0,     0,     0,     0,    19,    20,     0,     0,
       0,    21,    22,    23,    24,     0,     0,     0,     0,     0,
      25,    26,    27,     1,     0,     2,    28,     0,     0,     3,
       0,     0,    16,     0,     0,    29,    30,     0,     4,     0,
       0,     0,     0,   259,    31,     0,     0,     0,   261,   262,
       0,     0,     0,     0,    32,     0,    33,     0,    34,     0,
       5,     6,   266,    35,    36,    37,    38,    39,    40,    41,
      42,    43,    44,     0,     0,     0,     0,     0,     0,     0,
      30,     9,     0,     0,   399,     0,     0,     0,     0,     0,
       0,     0,    10,     0,     0,     0,    11,     0,     0,    12,
      13,     0,    14,     0,     0,     0,     0,    35,    36,    37,
      38,    39,   116,    41,    42,    43,    44,     0,     0,     0,
      16,     0,     0,     0,     0,     0,     0,    17,    18,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    19,    20,
       0,     0,     0,    21,     0,    23,    24,     0,     0,     0,
       0,     0,    25,    26,    27,     1,     0,     2,    28,     0,
       0,     3,     0,     0,     0,     0,     0,     0,    30,     0,
       4,     0,     0,     0,     0,   400,    31,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    32,     0,    33,     0,
      34,     0,     5,     6,     0,    35,    36,    37,    38,    39,
      40,    41,    42,    43,    44,     0,     0,     0,     0,     0,
       0,     0,     0,     9,     0,     0,   399,     0,     0,     0,
       0,     0,     0,     0,    10,     0,   390,     0,    11,     0,
       0,     0,    13,     0,    14,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    16,     0,     0,     0,     0,     0,     0,    17,
      18,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      19,    20,     0,     0,     0,    21,     0,    23,    24,     0,
       0,     0,     0,     0,    25,    26,    27,     0,     0,     0,
      28,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,     1,     0,     2,     0,     0,   391,     3,    31,     0,
       0,     0,     0,     0,     0,     0,     4,     0,   392,     0,
      33,     0,    34,     0,     0,     0,     0,    35,    36,    37,
      38,    39,   116,    41,    42,    43,    44,     0,     5,     6,
       0,     0,     0,     0,     0,     0,   470,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     9,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      10,     0,   390,     0,    11,     0,     0,     0,    13,     0,
      14,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    16,     0,
       0,     0,     0,     0,     0,    17,    18,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    19,    20,     0,     0,
       0,    21,     0,    23,    24,     0,     0,     0,     0,     0,
      25,    26,    27,     1,     0,     2,    28,     0,     0,     3,
       0,     0,     0,     0,     0,     0,    30,     0,     4,     0,
       0,     0,   391,     0,    31,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   392,     0,    33,     0,    34,     0,
       5,     6,     0,    35,    36,    37,    38,    39,   116,    41,
      42,    43,    44,     0,     0,     0,     0,     0,     0,     0,
       0,     9,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    10,     0,   390,     0,    11,     0,     0,     0,
      13,     0,    14,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      16,     0,     0,     0,     0,     0,     0,    17,    18,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    19,    20,
       0,     0,     0,    21,     0,    23,    24,     0,     0,     0,
       0,     0,    25,    26,    27,     0,     0,     0,    28,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    30,     1,
       0,     2,     0,     0,   391,     3,    31,     0,     0,     0,
       0,     0,     0,     0,     4,     0,   392,     0,    33,     0,
      34,     0,     0,     0,     0,    35,    36,    37,    38,    39,
     116,    41,    42,    43,    44,     0,     5,     6,     0,     0,
       0,     0,     0,     0,   470,     0,     0,     0,     0,     0,
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
       0,    35,    36,    37,    38,    39,    40,    41,    42,    43,
      44,     0,     0,     0,     0,     0,     0,     0,     0,     9,
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
       0,     0,     0,     0,   370,     0,    33,     0,    34,     0,
       5,     6,     0,    35,    36,    37,    38,    39,    40,    41,
      42,    43,    44,     0,     0,     0,     0,     0,     0,     0,
       0,     9,     0,     0,   399,     0,     0,     0,     0,     0,
       0,     0,    10,     0,     0,     0,    11,     0,     0,     0,
      13,     0,    14,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      16,     0,     0,     0,     0,     0,     0,    17,    18,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    19,    20,
       0,     0,     0,    21,     0,    23,    24,     0,     0,     0,
       0,     0,    25,    26,    27,     0,     0,     0,    28,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    30,     1,
       0,     2,     0,     0,     0,     3,    31,     0,     0,     0,
       0,     0,     0,     0,     4,     0,   370,     0,    33,     0,
      34,     0,     0,     0,     0,    35,    36,    37,    38,    39,
     116,    41,    42,    43,    44,     0,     5,     6,     0,     0,
       0,     0,     0,     0,   470,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     9,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    10,     0,
       0,     0,    11,     0,     0,     0,    13,     0,    14,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    16,     0,     0,     0,
       0,     0,     0,    17,    18,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    19,    20,     0,     0,     0,    21,
       0,    23,    24,     0,     0,     0,     0,     0,    25,    26,
      27,     1,     0,     2,    28,     0,     0,     3,     0,     0,
       0,     0,     0,     0,    30,     0,     4,     0,     0,     0,
       0,     0,    31,     0,     0,     1,     0,     2,     0,     0,
       0,     0,   370,     0,    33,     0,    34,     0,     5,     6,
       0,    35,    36,    37,    38,    39,   116,    41,    42,    43,
      44,     0,     0,     0,     0,     0,     0,     0,     0,     9,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   228,
      10,     0,     0,     0,    11,     0,   231,     0,    13,     0,
      14,     0,     0,     0,     0,     0,     0,     0,   235,   236,
       0,     0,     0,     0,     0,     0,     0,     0,    16,     0,
       0,     0,     0,     0,     0,    17,    18,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    19,    20,     0,     0,
       0,    21,    16,    23,    24,     0,   866,     0,     0,     0,
      25,    26,    27,   259,     0,     0,    28,     0,   261,   262,
       0,     0,     0,     0,     0,     0,    30,     0,     0,     0,
       0,     0,   266,     0,    31,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   370,     0,    33,     0,    34,     0,
      30,     0,     0,    35,    36,    37,    38,    39,   116,    41,
      42,    43,    44,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    35,    36,    37,
      38,    39,   116,    41,    42,    43,    44,   121,     0,   122,
       0,     0,     0,     0,     0,     0,     0,     0,   123,     0,
       0,   124,     0,   125,   126,     0,     0,     0,     0,     0,
       0,     0,   127,     0,     0,     0,     0,     7,     0,     0,
       0,     0,     0,   128,     0,     0,     0,     0,   129,     0,
       0,     0,     0,     0,     0,   130,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   131,     0,     0,     0,     0,
       0,     0,    15,   132,     0,   133,     0,     0,     0,   134,
       0,   135,     0,     0,     0,     0,     0,     0,   136,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   137,
       0,   138,     0,     0,     0,     0,     0,     0,   139,     0,
       0,     0,     0,   140,     0,     0,     0,   141,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   142,     0,     0,
       0,     0,   143,     0,     0,     0,     0,     0,     0,     0,
     144,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   145,     0,     0,     0,     0,   121,     0,
     122,    35,   146,   147,    38,   148,   149,   150,   151,   123,
      44,     0,   124,     0,   125,   126,     0,     0,     0,     0,
       0,     0,     0,   127,     0,     0,     0,     0,     7,     0,
       0,     0,     0,     0,   128,   121,     0,   122,     0,   129,
       0,     0,     0,     0,     0,     0,   130,     0,     0,   124,
       0,   125,   126,     0,     0,     0,   131,     0,     0,     0,
     127,     0,     0,    15,   132,     7,   133,     0,     0,     0,
     134,   128,   135,     0,     0,     0,   129,     0,     0,   136,
       0,     0,     0,   130,     0,     0,     0,     0,     0,     0,
     137,     0,   138,   520,     0,     0,     0,     0,     0,   139,
      15,   132,     0,   133,   140,     0,     0,   134,   141,   135,
       0,     0,     0,     0,     0,     0,   136,     0,   142,     0,
       0,     0,     0,   143,     0,     0,     0,   521,     0,     0,
       0,   144,   121,     0,   122,     0,   139,     0,     0,     0,
       0,   140,     0,     0,   145,   141,   124,     0,   125,   126,
       0,     0,     0,     0,     0,   142,    39,   127,     0,     0,
     143,     0,     7,     0,     0,     0,     0,     0,   128,     0,
       0,     0,     0,   129,     0,     0,     0,     0,     0,     0,
     130,   145,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    39,     0,     0,     0,    15,   132,     0,
     133,     0,     0,     0,   134,     0,   135,     0,     0,     0,
       0,     0,     0,   136,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   139,     0,     0,     0,     0,   140,     0,
       0,     0,   141,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   142,     0,     0,     0,     0,   143,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   145,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      39
};

static const yytype_int16 yycheck[] =
{
       0,   158,     2,    77,   170,     5,   384,     1,   320,   101,
      91,    72,     8,   100,    91,    88,    50,     4,   151,   366,
     183,     8,   383,    23,    24,    25,   316,    27,    28,    91,
      80,   360,   650,    91,    12,    22,   171,   395,     5,   172,
     299,    76,   877,   518,   191,    79,   150,     0,     4,    23,
      50,   155,    23,    15,    74,    17,     8,    91,    25,    19,
       8,     9,     6,    21,    21,    21,     0,    91,    34,     5,
      70,    71,    72,    95,    74,    33,    76,    70,    78,    79,
      80,     5,    21,    76,   167,   196,    86,    23,     0,   379,
       5,    91,    92,    93,    94,    68,    96,    50,    21,    23,
       0,    45,   596,    21,    77,    23,     8,   107,    23,   109,
      12,   111,   112,    36,    70,    54,    82,    70,    71,    86,
       0,    74,   183,    76,    91,    78,    79,    25,    91,   633,
      27,    28,    29,   153,    21,    95,   630,    58,    91,    92,
     162,    94,    63,    96,    78,     4,     6,   121,   296,   297,
     121,    90,   987,     4,   107,    83,   109,    55,   111,   112,
      94,   636,    83,   136,    27,    28,    29,   191,   192,    28,
     170,    19,   170,     0,   187,   171,     6,    28,   191,    27,
     180,   139,    94,   183,   171,   121,   159,    21,   168,  1024,
     551,    21,    11,     6,    94,   169,    23,   121,   100,    18,
      27,    28,   162,   121,   132,   167,   121,   207,   343,   342,
     210,   211,   375,   177,    94,    45,   210,   181,    46,   171,
     177,   177,   170,    50,   181,   181,   189,   574,     4,   191,
      62,   589,    21,   195,   196,   739,   199,   200,   177,     8,
       9,     0,   181,    70,    71,    21,     4,    74,   150,    76,
       5,    78,    79,   155,   612,     6,    45,   210,   211,    91,
     162,   879,   240,    21,    91,    92,     4,    94,    96,    96,
      25,   629,    21,   631,   112,    80,    72,    46,   116,   360,
     107,     6,   109,    21,   111,   112,   633,   184,   185,   186,
       4,    50,   120,   125,    19,   127,   124,    19,   464,    21,
      55,   188,   189,   632,   191,   192,   193,    21,     8,     9,
       6,    70,    71,    80,   375,    74,   316,    76,   679,    78,
      79,   184,   185,   186,   324,    21,   360,   361,     4,  1028,
     620,   365,    91,    92,     6,    94,     6,    96,   373,     6,
    1039,   600,   601,    80,   344,    21,   346,   343,   107,    19,
     109,    51,   111,   112,   188,   189,   343,     6,   192,   193,
     360,   361,    24,   363,   364,   365,     6,   402,   368,   442,
     366,   421,   366,   373,    36,   375,    19,   344,    21,   379,
     373,    11,   345,   346,    11,   419,   463,   183,   521,    19,
     523,   343,    19,   360,    21,   395,   871,   872,     0,   199,
     200,   463,   402,   495,   400,   463,   493,   360,   361,   402,
      11,   207,   365,   400,   366,    19,   520,     0,    19,   419,
     373,   421,    11,   423,   590,   124,   426,    22,   137,   463,
      19,   514,   515,   516,   517,     6,   436,   146,   473,   188,
     189,   150,   608,   192,   193,   445,   594,   595,   400,   402,
     954,   599,   361,    72,   195,   196,   365,   378,    11,   380,
     381,   382,   545,   463,   464,    18,   419,    50,    70,    71,
       8,     9,    74,   473,    76,   475,    78,    21,   191,     6,
     473,   194,   986,    21,     4,     8,     9,    70,    71,    28,
      92,    74,    94,    76,    16,    78,    79,    21,   400,    72,
     463,   501,    25,   503,    21,   505,    11,   507,    91,    92,
     463,    94,   859,    96,     8,     9,    12,    13,    48,     9,
     473,     8,   475,     6,   107,    12,   109,    21,   111,   112,
     526,   694,    55,   360,   361,     4,     5,    67,   365,   526,
      72,   475,    29,     6,   524,     6,   373,   908,   501,     6,
     503,   632,   505,   931,   507,     4,     5,     8,     9,   620,
     547,     6,   542,    93,   183,     4,     5,   501,   858,   503,
      21,   505,     6,   507,   526,   402,     6,    70,    71,   375,
      21,    74,    21,    22,    24,   572,     4,   117,     4,   589,
     590,   493,   419,   112,     8,     9,   596,   180,   632,    92,
      14,   360,   361,     8,     9,     6,   365,   954,   608,     9,
     183,    25,   612,   100,   373,   615,    21,    11,   520,   619,
     620,   621,   622,   623,   587,     8,     9,   548,    21,   629,
     630,   631,   632,   694,   207,     4,   463,   633,    21,   633,
      80,    55,    11,   402,     8,     9,   473,    21,   475,    21,
      19,   183,   713,    93,   715,     4,     5,   637,   187,    28,
     419,    21,   191,   150,   627,   632,   195,   196,   155,   622,
     623,   983,    51,   839,   501,   162,   503,    21,   505,   632,
     507,   633,     4,     5,   718,    21,   721,    21,   688,   689,
     690,   691,   692,   693,   694,   695,   696,   697,   698,   699,
     700,     6,     5,     7,   463,     8,     9,   707,   708,   709,
     710,   711,   712,   713,   473,   715,   475,     6,   718,   191,
     877,   721,    25,   195,   196,     4,     5,    19,   721,   107,
     170,   109,   767,   111,   112,   883,   884,     0,     6,   660,
     740,     6,   501,    21,   503,   739,   505,     6,   507,     4,
       5,   751,    55,   240,   197,   187,   375,   678,   190,   191,
       6,   193,   194,   346,   196,   718,     5,   767,   721,     8,
       9,   373,     5,   740,   767,     8,     9,   360,   361,   766,
      96,     6,   365,     6,   188,   189,     6,    50,   192,   193,
     373,   107,     5,   109,    47,   111,   112,     6,    51,    52,
     402,    54,   375,    56,    75,   632,     5,    70,    71,     8,
       9,    74,     6,    76,   767,    78,    79,     8,     9,   402,
     814,   801,   802,    14,    21,     6,     6,     6,    91,    92,
     987,    94,     6,    96,    25,    15,   419,    17,     6,   839,
       4,     5,   842,   375,   107,     6,   109,     5,   111,   112,
       8,     9,    11,   426,     4,     5,     0,     6,   858,   135,
     934,     4,     5,   436,    55,   118,     5,     4,     5,     8,
       9,   473,   445,   632,     5,     4,     5,     8,     9,   366,
     463,   833,     4,     5,   324,    21,   886,     5,   888,   889,
     473,   718,   475,   170,   721,     4,     5,     4,   694,   695,
     696,   697,   698,   699,   700,     5,    50,   859,     8,     9,
      21,   188,   189,   400,   191,   192,   193,   713,   501,   715,
     503,    86,   505,   363,   507,    21,    70,    71,   368,    21,
      74,     6,    76,     5,    78,    79,     8,     9,   188,   189,
     767,   191,   192,   193,   197,   198,    45,    91,    92,     5,
      94,     5,    96,     5,     8,     9,     8,     9,    20,   718,
     954,    21,   721,   107,    21,   109,     5,   111,   112,     8,
       9,   224,    21,    25,   227,    27,    28,    29,   199,  1013,
      21,   421,     5,   423,     4,     5,    48,  1021,     4,     5,
     986,   978,   986,    25,    11,    27,    28,    29,  1032,   159,
     619,     4,   954,    55,     5,    67,   493,    21,   767,   930,
      21,   191,    74,  1013,    21,   195,   196,     4,     5,   199,
     200,  1021,   509,    55,   464,   512,     4,     5,     5,    72,
      11,    93,  1032,   520,    16,   198,    11,     6,    18,     6,
     293,    11,    85,     5,     5,    19,   842,   170,   621,   632,
      93,     5,     5,    21,    20,   117,   170,   310,    21,   294,
    1013,    21,    21,    25,    21,    27,    28,    29,  1021,   688,
     689,   690,   691,   692,   693,   694,    21,    11,    21,  1032,
      21,   187,    21,    21,   190,   191,   339,   574,   194,   195,
     196,   153,   327,    55,   713,    21,   715,   360,   361,   187,
     188,   189,   365,   191,   192,   193,   194,    21,     6,     5,
     373,     5,     5,     4,     6,     5,   159,     5,    28,   721,
      75,   694,     5,     5,   167,    11,     5,   170,     5,     5,
     170,    20,   184,   185,   186,   718,   179,     5,   721,   402,
     183,   376,    20,   186,     6,   380,   633,    21,    20,     5,
     590,    21,   184,   185,   186,    20,   419,    21,   400,   475,
     162,   526,   694,   605,   207,   767,   889,   302,   608,   701,
     702,   703,   704,   705,   706,    15,   227,    17,   751,    24,
     615,   713,   383,   715,   767,   501,  1013,   503,   713,   505,
    1032,   507,   419,     0,  1021,   421,   363,   715,    78,   442,
     463,   389,   185,    10,     0,  1032,   463,    12,    12,    12,
     473,   497,   475,    -1,    21,   476,   360,   361,    -1,    -1,
      -1,   365,   184,   185,   186,   460,    -1,    72,    -1,   373,
       8,     9,    -1,    -1,    -1,    80,    -1,    -1,   501,    -1,
     503,    -1,   505,    -1,   507,    -1,    -1,    25,    93,    27,
      28,    29,   739,    -1,  1013,   508,    -1,   510,   402,    -1,
      -1,    -1,  1021,    70,    71,    -1,    -1,    74,    -1,    76,
      -1,    78,   112,  1032,    -1,   419,    -1,    55,    -1,    -1,
      25,    -1,    27,    28,    29,    92,    -1,    94,    -1,    96,
     187,   188,   189,   190,   191,   192,   193,   194,    -1,   196,
     107,    -1,   109,    -1,   111,   112,   349,    -1,    -1,    -1,
      55,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   463,
     160,   364,    -1,    -1,    -1,   170,    -1,   814,    -1,   473,
      -1,   475,   375,    -1,    -1,    -1,    -1,    -1,   183,    -1,
     575,    -1,   577,    -1,    -1,    -1,   833,   187,    -1,    -1,
     190,   191,   395,    -1,   194,   195,   196,   501,    21,   503,
      -1,   505,    -1,   507,    -1,   294,    -1,    -1,    -1,   632,
      -1,    -1,   859,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   424,   425,    -1,   427,    -1,    49,    50,   195,    -1,
      -1,   434,   435,    -1,    -1,    58,    -1,    -1,    -1,   839,
      -1,    -1,   445,    -1,    -1,    -1,   184,   185,   186,    -1,
      -1,    74,    -1,    -1,    -1,     0,    -1,   670,   671,   672,
     673,   464,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   664,
    1013,    -1,    -1,    -1,    -1,    -1,    99,    -1,  1021,   184,
     185,   186,   677,   678,   107,    -1,   886,   376,   888,  1032,
      -1,    -1,    -1,    -1,    -1,   718,    -1,    -1,   721,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   954,    -1,    -1,
      -1,   514,   515,   516,   517,    -1,    -1,    -1,    -1,   324,
     143,    -1,    -1,    -1,    -1,    70,    71,    72,   632,    74,
     153,    -1,    22,    78,    -1,    -1,    -1,    -1,    -1,   986,
     429,    -1,   545,    33,   767,    35,    -1,    92,    -1,    94,
      -1,    96,    -1,    -1,    -1,    -1,   179,    47,   363,   364,
      -1,    -1,   107,   368,   109,    -1,   111,   112,   191,    -1,
     375,   460,    -1,    63,    -1,    -1,    -1,    -1,    -1,    69,
      -1,   794,    -1,    -1,    -1,    -1,   589,   590,    -1,    -1,
     395,    -1,    -1,   596,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   608,   373,    -1,    98,   612,
      -1,   101,    -1,    -1,   718,   105,   421,   721,   423,   832,
      -1,   834,    -1,    -1,   114,    -1,   629,   630,   631,    -1,
      -1,    -1,   399,    -1,    -1,   402,    -1,   640,   183,    -1,
      -1,    -1,   531,    -1,   134,    -1,    -1,   650,    -1,   139,
      -1,    -1,    -1,    -1,    -1,   868,    -1,   546,    -1,   464,
      -1,    -1,    -1,   767,    -1,    -1,   555,    -1,   158,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   680,   681,   682,
     683,   684,   685,    -1,    -1,   294,   575,    -1,    -1,    -1,
      -1,   694,   695,   696,   697,   698,   699,   700,    -1,    -1,
      -1,    -1,    -1,   470,    -1,    -1,   473,    -1,   475,    -1,
     713,    -1,   715,    -1,   909,   910,   911,   912,   913,   914,
     915,   724,   725,   726,   727,   728,    -1,    -1,    49,    50,
      -1,    -1,    -1,    -1,   501,    -1,   503,    58,   505,    -1,
     507,    -1,   745,    -1,    -1,   512,   749,   750,   751,    -1,
      -1,    -1,    -1,    74,    -1,    -1,    -1,    -1,    -1,   648,
      81,    -1,    -1,   652,    -1,    -1,    -1,   376,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   664,    22,    -1,    99,    -1,
      -1,    -1,    -1,    -1,   589,   590,   107,    33,   677,    35,
    1013,    -1,    -1,    -1,     6,    -1,    -1,    15,  1021,    17,
      -1,    47,    -1,   608,    -1,    -1,    -1,   612,    -1,  1032,
      -1,    -1,    -1,   816,    -1,   818,    -1,    63,    -1,    -1,
     429,    -1,   143,    69,   629,    -1,   631,    -1,    -1,    -1,
     375,    -1,   153,    -1,    -1,    -1,   839,    49,    50,   842,
      -1,    -1,    -1,    61,   733,   734,    58,    -1,   737,    -1,
      -1,   460,    98,   742,   743,   101,    -1,    -1,   179,   105,
      -1,    -1,    74,   752,    -1,    -1,   633,    -1,   114,    81,
     191,    -1,   875,    -1,    -1,   878,   879,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   103,   889,    99,   134,   694,
      -1,    -1,    -1,   139,   112,   107,   701,   702,   703,   704,
     705,   706,    -1,    -1,   122,    -1,    -1,    -1,   713,  1013,
     715,    -1,   158,    -1,    -1,    -1,    -1,  1021,    -1,    -1,
      -1,    -1,   531,    -1,    -1,    -1,    -1,    -1,  1032,    -1,
     475,   143,    -1,    -1,    33,    -1,    35,   546,   156,    -1,
      -1,   153,   160,    -1,    -1,   163,   555,    -1,    47,    -1,
      -1,    -1,    -1,    -1,   721,   844,   501,    -1,   503,    -1,
     505,    59,   507,    -1,    63,    -1,   575,   179,    66,   187,
      69,    -1,   190,   191,   863,    -1,   194,   195,   196,   191,
      78,    79,    81,    -1,    -1,   874,    -1,    -1,    -1,    -1,
      -1,   880,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    98,
     767,    -1,   101,    -1,    -1,    -1,   105,   896,   897,   898,
     899,   900,   901,    -1,    -1,   114,    -1,    -1,    -1,  1022,
     909,    -1,    -1,    -1,    -1,   123,    -1,    -1,    -1,    -1,
     128,   129,    -1,    -1,   839,   134,    -1,    -1,  1041,   648,
     139,    -1,    -1,   652,   142,    -1,    -1,    -1,    -1,    -1,
     939,   940,   941,   942,   943,   664,    -1,    -1,    -1,   158,
      -1,    -1,   951,   952,   953,     6,    -1,    -1,   677,    -1,
      -1,    -1,    -1,    -1,    15,    -1,    17,    -1,    -1,    -1,
      -1,   886,    -1,   888,   889,    26,    -1,   976,   977,   187,
     188,   189,   859,   191,   192,   193,   194,   195,   196,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    48,    49,    -1,
      -1,  1000,    -1,    -1,    -1,  1004,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   733,   734,    67,    -1,   737,    70,
      -1,    59,    -1,   742,   743,    -1,    -1,    -1,    66,    -1,
      59,    -1,    -1,   752,    -1,    -1,    87,    66,  1037,   694,
      78,    79,    93,    -1,    -1,    -1,  1045,    -1,    -1,    78,
      79,    -1,   707,   708,   709,   710,   711,   712,   713,    -1,
     715,    -1,    -1,    -1,   115,    -1,   117,    -1,   119,   120,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   954,    -1,    -1,
      -1,     0,    -1,    -1,    -1,   123,    -1,    -1,    -1,    -1,
     128,   129,    -1,    -1,   123,    -1,    15,    -1,    17,   128,
     129,    -1,    21,    -1,   142,    -1,    -1,    -1,    -1,   160,
      -1,    30,    -1,   142,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   174,    -1,   844,    -1,    -1,    -1,    -1,
      -1,    -1,   183,    52,    53,    -1,   187,   188,   189,    -1,
     191,   192,   193,   194,   863,    -1,    -1,    -1,    -1,    68,
      -1,    -1,   190,   191,    73,   874,    -1,   195,   196,    -1,
      -1,   880,   191,    -1,    -1,    84,   195,   196,    -1,    88,
      -1,    -1,    91,    92,    -1,    94,    -1,   896,   897,   898,
     899,   900,   901,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     909,    -1,    -1,   112,    -1,    -1,    -1,    -1,    -1,    -1,
     119,   120,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   130,   131,    -1,    -1,    -1,   135,   136,   137,   138,
     939,   940,   941,   942,   943,   144,   145,   146,    -1,    -1,
      -1,   150,   951,   952,   953,    -1,    -1,    -1,    -1,    -1,
     159,   160,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   168,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   976,   977,   178,
      -1,   180,    -1,   182,    -1,    -1,    -1,    -1,   187,   188,
     189,   190,   191,   192,   193,   194,   195,   196,    -1,    -1,
       6,  1000,     8,     9,    -1,  1004,    -1,    -1,    -1,    15,
      -1,    17,    -1,    -1,    -1,    21,    -1,    -1,    -1,    -1,
      26,    -1,    -1,    -1,    -1,    31,    32,    -1,    -1,    -1,
      -1,    37,    38,    39,    40,    41,    42,    43,  1037,    -1,
      -1,    -1,    48,    49,    -1,    -1,  1045,    -1,    -1,    -1,
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
      -1,    -1,    -1,    -1,    -1,    -1,    26,    -1,    -1,    -1,
      -1,    31,    32,    -1,    -1,    -1,    -1,    37,    38,    39,
      40,    41,    42,    43,    -1,    -1,    -1,    -1,    48,    49,
      -1,    -1,    -1,    -1,    -1,    -1,    56,    57,    58,    59,
      -1,    61,    -1,    -1,    64,    65,    66,    67,    -1,    -1,
      -1,    71,    72,    -1,    -1,    -1,    -1,    -1,    78,    79,
      -1,    -1,    -1,    -1,    -1,    85,    -1,    87,    -1,    89,
      -1,    91,    -1,    93,    -1,    -1,    -1,    97,    -1,    99,
     100,    -1,   102,   103,   104,    -1,   106,   107,   108,   109,
     110,   111,   112,   113,    -1,   115,   116,   117,   118,   119,
     120,    -1,   122,   123,    -1,    -1,   126,    -1,   128,   129,
      -1,    -1,    -1,   133,    -1,    -1,    -1,    -1,    -1,    -1,
     140,   141,   142,   143,    -1,    -1,    -1,   147,   148,   149,
      -1,   151,   152,    -1,   154,   155,   156,   157,    -1,    -1,
     160,   161,    -1,   163,   164,   165,    -1,    -1,    -1,    -1,
      -1,   171,   172,   173,   174,   175,   176,    -1,    -1,   179,
      -1,    -1,    -1,   183,    -1,    -1,    -1,   187,   188,   189,
     190,   191,   192,   193,   194,   195,   196,   197,    -1,   199,
     200,   201,     6,    -1,     8,     9,    -1,    -1,    -1,    -1,
      -1,    15,    -1,    17,    -1,    -1,    -1,    21,    -1,    -1,
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
       8,     9,    10,    -1,    -1,    -1,    -1,    15,    -1,    17,
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
      -1,    -1,    -1,    85,    -1,    87,    88,    89,    -1,    91,
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
     200,   201,     6,    -1,     8,     9,    -1,    -1,    -1,    -1,
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
      -1,    89,    -1,    -1,    -1,    93,    -1,    -1,    -1,    97,
      -1,    99,   100,    -1,   102,    -1,   104,    -1,   106,   107,
     108,   109,   110,   111,    -1,   113,    -1,   115,    -1,   117,
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
      -1,    -1,    -1,    -1,    56,    -1,    -1,    59,    -1,    -1,
      -1,    -1,    64,    65,    66,    67,    -1,    -1,    -1,    71,
      72,    -1,    -1,    -1,    -1,    -1,    78,    79,    -1,    -1,
      -1,    -1,    -1,    85,    -1,    87,    -1,    89,    -1,    -1,
      -1,    93,    -1,    -1,    -1,    97,    -1,    99,   100,    -1,
     102,    -1,    -1,    -1,   106,   107,   108,   109,   110,   111,
      -1,   113,    -1,   115,    -1,   117,   118,   119,   120,    -1,
      -1,   123,    -1,    -1,   126,    -1,   128,   129,    -1,    -1,
      -1,   133,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   141,
     142,   143,    -1,    -1,    -1,   147,   148,   149,    -1,   151,
     152,    -1,   154,   155,    -1,   157,    -1,    -1,   160,   161,
      -1,    -1,   164,   165,    -1,    -1,    -1,    -1,    -1,   171,
     172,    -1,   174,   175,   176,    -1,    -1,   179,    -1,    -1,
      -1,   183,    -1,    -1,    -1,   187,   188,   189,    -1,   191,
     192,   193,   194,   195,   196,    -1,    -1,   199,   200,   201,
       6,    -1,     8,     9,    -1,    -1,    -1,    -1,    -1,    15,
      -1,    17,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    31,    32,    -1,    -1,    -1,
      -1,    37,    38,    39,    40,    41,    42,    43,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      56,    57,    58,    59,    -1,    -1,    -1,    -1,    64,    65,
      66,    -1,    -1,    -1,    -1,    71,    72,    -1,    -1,    -1,
      -1,    -1,    78,    79,    -1,    -1,    -1,    -1,    -1,    85,
      -1,    -1,    -1,    89,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    97,    -1,    99,   100,    -1,   102,    -1,   104,    -1,
     106,   107,   108,   109,   110,   111,    -1,   113,    -1,    -1,
      -1,    -1,   118,    -1,    -1,    -1,    -1,   123,    -1,    -1,
     126,    -1,   128,   129,    -1,    -1,    -1,   133,    -1,    -1,
      -1,    -1,    -1,    -1,   140,   141,   142,   143,    -1,    -1,
      -1,   147,   148,   149,    -1,   151,   152,    -1,   154,   155,
      -1,   157,    -1,    -1,    -1,   161,    -1,    -1,   164,   165,
      -1,    -1,    -1,    -1,    -1,   171,   172,   173,    -1,   175,
     176,    -1,    -1,   179,    -1,    -1,    -1,     6,    -1,     8,
       9,    -1,    -1,   189,   190,   191,    15,   193,    17,   195,
     196,   197,    -1,   199,   200,   201,    -1,    -1,    -1,    -1,
      -1,    -1,    31,    32,    -1,    -1,    -1,    -1,    37,    38,
      39,    40,    41,    42,    43,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    56,    -1,    -1,
      59,    -1,    -1,    -1,    -1,    64,    65,    66,    -1,    -1,
      -1,    -1,    71,    72,    -1,    -1,    -1,    -1,    -1,    78,
      79,    -1,    -1,    -1,    -1,    -1,    85,    -1,    -1,    -1,
      89,    90,    -1,    -1,    -1,    -1,    -1,    -1,    97,    -1,
      99,   100,    -1,   102,    -1,    -1,    -1,   106,   107,   108,
     109,   110,   111,    -1,   113,    -1,    -1,    -1,    -1,   118,
      -1,    -1,    -1,    -1,   123,    -1,    -1,   126,    -1,   128,
     129,    -1,    -1,    -1,   133,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   141,   142,   143,    -1,    -1,    -1,   147,   148,
     149,    -1,   151,   152,    -1,   154,   155,    -1,   157,    -1,
      -1,    -1,   161,    -1,    -1,   164,   165,    -1,    -1,    -1,
      -1,    -1,   171,   172,    -1,    -1,   175,   176,   177,     6,
     179,     8,     9,    10,    -1,    -1,    -1,    14,    15,    -1,
      17,    -1,   191,    -1,   193,    -1,   195,   196,    -1,    -1,
     199,   200,   201,    -1,    31,    32,    -1,    -1,    -1,    -1,
      37,    38,    39,    40,    41,    42,    43,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    56,
      -1,    -1,    59,    -1,    -1,    -1,    -1,    64,    65,    66,
      -1,    -1,    -1,    -1,    71,    72,    -1,    -1,    -1,    -1,
      -1,    78,    79,    -1,    -1,    -1,    -1,    -1,    85,    -1,
      -1,    -1,    89,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      97,    -1,    99,   100,    -1,   102,    -1,    -1,    -1,   106,
     107,   108,   109,   110,   111,    -1,   113,    -1,    -1,    -1,
      -1,   118,    -1,    -1,    -1,    -1,   123,    -1,    -1,   126,
      -1,   128,   129,    -1,    -1,    -1,   133,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   141,   142,   143,    -1,    -1,    -1,
     147,   148,   149,    -1,   151,   152,    -1,   154,   155,    -1,
     157,    -1,    -1,    -1,   161,    -1,    -1,   164,   165,    -1,
      -1,    -1,    -1,    -1,   171,   172,    -1,    -1,   175,   176,
      -1,     6,   179,     8,     9,    10,    -1,    -1,    -1,    -1,
      15,    -1,    17,    -1,   191,    -1,   193,    -1,   195,   196,
      -1,    -1,   199,   200,   201,    -1,    31,    32,    -1,    -1,
      -1,    -1,    37,    38,    39,    40,    41,    42,    43,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    56,    -1,    -1,    59,    -1,    -1,    -1,    -1,    64,
      65,    66,    -1,    -1,    -1,    -1,    71,    72,    -1,    -1,
      -1,    -1,    -1,    78,    79,    -1,    -1,    -1,    -1,    -1,
      85,    -1,    -1,    -1,    89,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    97,    -1,    99,   100,    33,   102,    35,    -1,
      -1,   106,   107,   108,   109,   110,   111,    -1,   113,    -1,
      47,    -1,    -1,   118,    -1,    -1,    -1,    -1,   123,    -1,
      -1,   126,    -1,   128,   129,    -1,    63,    -1,   133,    -1,
      -1,    -1,    69,    -1,    -1,    -1,   141,   142,   143,    -1,
      -1,    -1,   147,   148,   149,    -1,   151,   152,    -1,   154,
     155,    -1,   157,    -1,    -1,    -1,   161,    -1,    -1,   164,
     165,    98,    -1,    -1,   101,    -1,   171,   172,   105,    -1,
     175,   176,    -1,     6,   179,     8,     9,   114,    -1,    -1,
      -1,    14,    15,    -1,    17,    -1,   191,    -1,   193,    -1,
     195,   196,    -1,    -1,   199,   200,   201,   134,    31,    32,
      -1,    -1,   139,    -1,    37,    38,    39,    40,    41,    42,
      43,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   158,    -1,    56,    -1,    -1,    59,    -1,    -1,    -1,
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
      -1,    -1,   175,   176,    -1,     6,   179,     8,     9,    -1,
      -1,    -1,    -1,    -1,    15,    -1,    17,    -1,   191,    -1,
     193,    -1,   195,   196,    -1,    -1,   199,   200,   201,    -1,
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
     171,   172,    -1,    -1,   175,   176,     6,    -1,   179,    -1,
      10,    11,    -1,    -1,    -1,    15,    -1,    17,    -1,    -1,
     191,    -1,   193,    -1,   195,   196,    -1,    -1,   199,   200,
     201,    31,    32,    -1,    -1,    -1,    -1,    37,    38,    39,
      40,    41,    42,    43,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    56,    -1,    -1,    59,
      -1,    -1,    -1,    -1,    64,    65,    66,    -1,    -1,    -1,
      -1,    71,    72,    -1,    -1,    -1,    -1,    -1,    78,    79,
      -1,    -1,    -1,    -1,    -1,    85,    -1,    -1,    -1,    89,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    97,    -1,    99,
     100,    -1,   102,    -1,    -1,    -1,   106,   107,   108,   109,
     110,   111,    -1,   113,    -1,    -1,    -1,    -1,   118,    -1,
      -1,    -1,    -1,   123,    -1,    -1,   126,    -1,   128,   129,
      -1,    -1,    -1,   133,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   141,   142,   143,    -1,    -1,    -1,   147,   148,   149,
      -1,   151,   152,    -1,   154,   155,    -1,   157,    -1,    -1,
      -1,   161,    -1,    -1,   164,   165,    -1,    -1,    -1,    -1,
      -1,   171,   172,    -1,    -1,   175,   176,     6,    -1,   179,
      -1,    -1,    -1,    -1,    -1,    -1,    15,    -1,    17,    -1,
      -1,   191,    -1,   193,    -1,   195,   196,    -1,    -1,   199,
     200,   201,    31,    32,    -1,    -1,    -1,    -1,    37,    38,
      39,    40,    41,    42,    43,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    56,    -1,    -1,
      59,    -1,    -1,    -1,    -1,    64,    65,    66,    -1,    -1,
      -1,    -1,    71,    72,    -1,    -1,    -1,    59,    -1,    78,
      79,    -1,    -1,    -1,    66,    -1,    85,    -1,    -1,    -1,
      89,    -1,    -1,    -1,    -1,    -1,    78,    79,    97,    -1,
      99,   100,    -1,   102,    -1,    -1,    -1,   106,   107,   108,
     109,   110,   111,    -1,   113,    -1,    -1,     6,    -1,   118,
      -1,    -1,    -1,    -1,   123,    -1,    15,   126,    17,   128,
     129,    -1,    -1,    -1,   133,    -1,    -1,    -1,    -1,    -1,
      -1,   123,   141,   142,   143,    -1,   128,   129,   147,   148,
     149,    -1,   151,   152,    -1,   154,   155,    -1,   157,    48,
     142,    -1,   161,    -1,    -1,   164,   165,    -1,    57,    -1,
      -1,    -1,   171,   172,    -1,     6,   175,   176,    67,    -1,
     179,    -1,    -1,    -1,    15,    -1,    17,    -1,    -1,    -1,
      -1,    -1,   191,    -1,   193,    26,   195,   196,    87,    -1,
     199,   200,   201,    -1,    93,   187,   188,   189,   190,   191,
     192,   193,   194,   195,   196,    -1,    -1,    48,    49,    -1,
      -1,    -1,    -1,   112,    -1,    -1,    -1,    -1,   117,    -1,
     119,   120,    -1,     6,    -1,    -1,    67,    -1,    -1,    -1,
      -1,    -1,    15,    -1,    17,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,     6,    -1,    87,    -1,    -1,    -1,
      -1,    -1,    93,    15,    -1,    17,    -1,    -1,    -1,    -1,
      -1,   160,    -1,    -1,    -1,    48,    49,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   115,   174,   117,    -1,   119,   120,
      -1,    -1,    -1,    -1,    67,    -1,    48,    49,   187,    -1,
      -1,   190,   191,    -1,    -1,   194,   195,   196,   197,    -1,
     199,   200,   201,    -1,    87,    67,    -1,    -1,    -1,    -1,
      93,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   160,
      -1,    -1,    -1,    -1,    -1,    87,    -1,    -1,    -1,    -1,
      -1,    93,    -1,   174,   117,    -1,   119,   120,    -1,    -1,
      -1,    -1,   183,    -1,    -1,    -1,   187,   188,   189,    -1,
     191,   192,   193,   194,    -1,   117,    -1,   119,   120,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   160,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   174,    -1,    -1,    -1,    15,    -1,    17,   160,    -1,
     183,    -1,    -1,    -1,   187,   188,   189,    -1,   191,   192,
     193,   194,   174,    -1,    -1,    -1,    15,    -1,    17,    -1,
      -1,   183,    21,    -1,    -1,   187,   188,   189,    48,   191,
     192,   193,   194,    -1,    -1,    -1,    -1,    57,    -1,    59,
      -1,    -1,    -1,    -1,    -1,    -1,    66,    67,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    78,    79,
      -1,    -1,    61,    -1,    -1,    -1,    -1,    87,    -1,    -1,
      -1,    -1,    -1,    93,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   112,    -1,    -1,    -1,    -1,   117,    -1,   119,
     120,    -1,    -1,   123,   103,    -1,    -1,    -1,   128,   129,
      -1,    -1,    -1,   112,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   142,   122,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     160,    -1,    -1,    -1,    -1,    15,    -1,    17,    -1,    -1,
      -1,    21,    -1,    -1,   174,    -1,    -1,   156,    -1,    -1,
      30,   160,    -1,    -1,   163,    -1,    -1,   187,   188,   189,
     190,   191,   192,   193,   194,   195,   196,   197,    -1,   199,
     200,   201,    52,    53,    -1,    -1,    -1,    -1,   187,    -1,
      -1,   190,   191,    63,    -1,   194,   195,   196,    68,    -1,
      -1,    -1,    -1,    73,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    84,    -1,    -1,    -1,    88,    -1,
      -1,    91,    92,    -1,    94,    -1,    -1,    -1,    98,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   112,    -1,    -1,    -1,    -1,    -1,    -1,   119,
     120,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     130,   131,    -1,    -1,    -1,   135,   136,   137,   138,    -1,
      -1,    -1,    -1,    -1,   144,   145,   146,    -1,    -1,    -1,
     150,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   159,
     160,    15,    -1,    17,    -1,    -1,    -1,    21,   168,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    30,    -1,   178,    -1,
     180,    -1,   182,    -1,    -1,    -1,    -1,   187,   188,   189,
     190,   191,   192,   193,   194,   195,   196,    -1,    52,    53,
      -1,    -1,    -1,    -1,    -1,    15,    60,    17,    -1,    -1,
      -1,    -1,    -1,    -1,    68,    -1,    -1,    -1,    -1,    73,
      -1,    -1,    -1,    77,    -1,    -1,    -1,    -1,    -1,    -1,
      84,    -1,    -1,    -1,    88,    -1,    -1,    91,    92,    -1,
      94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    59,
      -1,    -1,    -1,    -1,    -1,    -1,    66,    -1,   112,    -1,
      -1,    -1,    -1,    -1,    -1,   119,   120,    -1,    78,    79,
      -1,    -1,    -1,    -1,    -1,    -1,   130,   131,    -1,    -1,
      -1,   135,   136,   137,   138,    -1,    -1,    -1,    -1,    -1,
     144,   145,   146,    15,    -1,    17,   150,    -1,    -1,    21,
      -1,    -1,   112,    -1,    -1,   159,   160,    -1,    30,    -1,
      -1,    -1,    -1,   123,   168,    -1,    -1,    -1,   128,   129,
      -1,    -1,    -1,    -1,   178,    -1,   180,    -1,   182,    -1,
      52,    53,   142,   187,   188,   189,   190,   191,   192,   193,
     194,   195,   196,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     160,    73,    -1,    -1,    76,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    84,    -1,    -1,    -1,    88,    -1,    -1,    91,
      92,    -1,    94,    -1,    -1,    -1,    -1,   187,   188,   189,
     190,   191,   192,   193,   194,   195,   196,    -1,    -1,    -1,
     112,    -1,    -1,    -1,    -1,    -1,    -1,   119,   120,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   130,   131,
      -1,    -1,    -1,   135,    -1,   137,   138,    -1,    -1,    -1,
      -1,    -1,   144,   145,   146,    15,    -1,    17,   150,    -1,
      -1,    21,    -1,    -1,    -1,    -1,    -1,    -1,   160,    -1,
      30,    -1,    -1,    -1,    -1,   167,   168,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   178,    -1,   180,    -1,
     182,    -1,    52,    53,    -1,   187,   188,   189,   190,   191,
     192,   193,   194,   195,   196,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    73,    -1,    -1,    76,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    84,    -1,    86,    -1,    88,    -1,
      -1,    -1,    92,    -1,    94,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   112,    -1,    -1,    -1,    -1,    -1,    -1,   119,
     120,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     130,   131,    -1,    -1,    -1,   135,    -1,   137,   138,    -1,
      -1,    -1,    -1,    -1,   144,   145,   146,    -1,    -1,    -1,
     150,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     160,    15,    -1,    17,    -1,    -1,   166,    21,   168,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    30,    -1,   178,    -1,
     180,    -1,   182,    -1,    -1,    -1,    -1,   187,   188,   189,
     190,   191,   192,   193,   194,   195,   196,    -1,    52,    53,
      -1,    -1,    -1,    -1,    -1,    -1,    60,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    73,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      84,    -1,    86,    -1,    88,    -1,    -1,    -1,    92,    -1,
      94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   112,    -1,
      -1,    -1,    -1,    -1,    -1,   119,   120,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   130,   131,    -1,    -1,
      -1,   135,    -1,   137,   138,    -1,    -1,    -1,    -1,    -1,
     144,   145,   146,    15,    -1,    17,   150,    -1,    -1,    21,
      -1,    -1,    -1,    -1,    -1,    -1,   160,    -1,    30,    -1,
      -1,    -1,   166,    -1,   168,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   178,    -1,   180,    -1,   182,    -1,
      52,    53,    -1,   187,   188,   189,   190,   191,   192,   193,
     194,   195,   196,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    73,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    84,    -1,    86,    -1,    88,    -1,    -1,    -1,
      92,    -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     112,    -1,    -1,    -1,    -1,    -1,    -1,   119,   120,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   130,   131,
      -1,    -1,    -1,   135,    -1,   137,   138,    -1,    -1,    -1,
      -1,    -1,   144,   145,   146,    -1,    -1,    -1,   150,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   160,    15,
      -1,    17,    -1,    -1,   166,    21,   168,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    30,    -1,   178,    -1,   180,    -1,
     182,    -1,    -1,    -1,    -1,   187,   188,   189,   190,   191,
     192,   193,   194,   195,   196,    -1,    52,    53,    -1,    -1,
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
      -1,   187,   188,   189,   190,   191,   192,   193,   194,   195,
     196,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    73,
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
      52,    53,    -1,   187,   188,   189,   190,   191,   192,   193,
     194,   195,   196,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    73,    -1,    -1,    76,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    84,    -1,    -1,    -1,    88,    -1,    -1,    -1,
      92,    -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     112,    -1,    -1,    -1,    -1,    -1,    -1,   119,   120,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   130,   131,
      -1,    -1,    -1,   135,    -1,   137,   138,    -1,    -1,    -1,
      -1,    -1,   144,   145,   146,    -1,    -1,    -1,   150,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   160,    15,
      -1,    17,    -1,    -1,    -1,    21,   168,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    30,    -1,   178,    -1,   180,    -1,
     182,    -1,    -1,    -1,    -1,   187,   188,   189,   190,   191,
     192,   193,   194,   195,   196,    -1,    52,    53,    -1,    -1,
      -1,    -1,    -1,    -1,    60,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    73,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    84,    -1,
      -1,    -1,    88,    -1,    -1,    -1,    92,    -1,    94,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   112,    -1,    -1,    -1,
      -1,    -1,    -1,   119,   120,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   130,   131,    -1,    -1,    -1,   135,
      -1,   137,   138,    -1,    -1,    -1,    -1,    -1,   144,   145,
     146,    15,    -1,    17,   150,    -1,    -1,    21,    -1,    -1,
      -1,    -1,    -1,    -1,   160,    -1,    30,    -1,    -1,    -1,
      -1,    -1,   168,    -1,    -1,    15,    -1,    17,    -1,    -1,
      -1,    -1,   178,    -1,   180,    -1,   182,    -1,    52,    53,
      -1,   187,   188,   189,   190,   191,   192,   193,   194,   195,
     196,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    73,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    59,
      84,    -1,    -1,    -1,    88,    -1,    66,    -1,    92,    -1,
      94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    78,    79,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   112,    -1,
      -1,    -1,    -1,    -1,    -1,   119,   120,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   130,   131,    -1,    -1,
      -1,   135,   112,   137,   138,    -1,   116,    -1,    -1,    -1,
     144,   145,   146,   123,    -1,    -1,   150,    -1,   128,   129,
      -1,    -1,    -1,    -1,    -1,    -1,   160,    -1,    -1,    -1,
      -1,    -1,   142,    -1,   168,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   178,    -1,   180,    -1,   182,    -1,
     160,    -1,    -1,   187,   188,   189,   190,   191,   192,   193,
     194,   195,   196,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   187,   188,   189,
     190,   191,   192,   193,   194,   195,   196,    33,    -1,    35,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    44,    -1,
      -1,    47,    -1,    49,    50,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    58,    -1,    -1,    -1,    -1,    63,    -1,    -1,
      -1,    -1,    -1,    69,    -1,    -1,    -1,    -1,    74,    -1,
      -1,    -1,    -1,    -1,    -1,    81,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    91,    -1,    -1,    -1,    -1,
      -1,    -1,    98,    99,    -1,   101,    -1,    -1,    -1,   105,
      -1,   107,    -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   125,
      -1,   127,    -1,    -1,    -1,    -1,    -1,    -1,   134,    -1,
      -1,    -1,    -1,   139,    -1,    -1,    -1,   143,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   153,    -1,    -1,
      -1,    -1,   158,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     166,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   179,    -1,    -1,    -1,    -1,    33,    -1,
      35,   187,   188,   189,   190,   191,   192,   193,   194,    44,
     196,    -1,    47,    -1,    49,    50,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    58,    -1,    -1,    -1,    -1,    63,    -1,
      -1,    -1,    -1,    -1,    69,    33,    -1,    35,    -1,    74,
      -1,    -1,    -1,    -1,    -1,    -1,    81,    -1,    -1,    47,
      -1,    49,    50,    -1,    -1,    -1,    91,    -1,    -1,    -1,
      58,    -1,    -1,    98,    99,    63,   101,    -1,    -1,    -1,
     105,    69,   107,    -1,    -1,    -1,    74,    -1,    -1,   114,
      -1,    -1,    -1,    81,    -1,    -1,    -1,    -1,    -1,    -1,
     125,    -1,   127,    91,    -1,    -1,    -1,    -1,    -1,   134,
      98,    99,    -1,   101,   139,    -1,    -1,   105,   143,   107,
      -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,   153,    -1,
      -1,    -1,    -1,   158,    -1,    -1,    -1,   125,    -1,    -1,
      -1,   166,    33,    -1,    35,    -1,   134,    -1,    -1,    -1,
      -1,   139,    -1,    -1,   179,   143,    47,    -1,    49,    50,
      -1,    -1,    -1,    -1,    -1,   153,   191,    58,    -1,    -1,
     158,    -1,    63,    -1,    -1,    -1,    -1,    -1,    69,    -1,
      -1,    -1,    -1,    74,    -1,    -1,    -1,    -1,    -1,    -1,
      81,   179,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   191,    -1,    -1,    -1,    98,    99,    -1,
     101,    -1,    -1,    -1,   105,    -1,   107,    -1,    -1,    -1,
      -1,    -1,    -1,   114,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   134,    -1,    -1,    -1,    -1,   139,    -1,
      -1,    -1,   143,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   153,    -1,    -1,    -1,    -1,   158,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   179,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     191
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
     294,   295,   296,   302,   303,   304,   305,   306,   309,   311,
     312,   313,   314,   317,   318,   320,   321,   323,   324,   329,
     330,   331,   333,   345,   359,   360,   361,   362,   363,   364,
     367,   368,   376,   379,   382,   385,   386,   387,   388,   389,
     390,   391,   392,   233,   286,   208,   192,   256,   266,   286,
       6,    33,    35,    44,    47,    49,    50,    58,    69,    74,
      81,    91,    99,   101,   105,   107,   114,   125,   127,   134,
     139,   143,   153,   158,   166,   179,   188,   189,   191,   192,
     193,   194,   203,   204,   205,   206,   207,   208,   209,   210,
     211,   212,   213,   239,   265,   277,   287,   342,   343,   344,
     345,   349,   351,   352,   353,   354,   356,   358,    21,    54,
      90,   177,   181,   334,   335,   336,   339,    21,   266,     6,
      21,   352,   353,   354,   358,   170,     6,    80,    80,     6,
       6,    21,   266,   208,   380,   257,   286,     6,     8,     9,
      15,    17,    21,    26,    31,    32,    37,    38,    39,    40,
      41,    42,    43,    48,    49,    56,    57,    58,    59,    64,
      65,    66,    67,    71,    72,    78,    79,    85,    87,    89,
      91,    93,    97,   100,   102,   104,   106,   107,   108,   109,
     110,   111,   113,   115,   116,   117,   118,   119,   120,   123,
     126,   128,   129,   133,   140,   141,   142,   147,   148,   149,
     151,   152,   154,   155,   157,   161,   164,   165,   171,   172,
     173,   174,   175,   176,   179,   183,   188,   189,   193,   197,
     199,   200,   201,   211,   214,   215,   216,   217,   218,   219,
     221,   222,   223,   224,   225,   226,   227,   228,   229,   232,
     234,   235,   246,   247,   248,   252,   254,   255,   256,   257,
     258,   259,   260,   261,   262,   264,   267,   271,   272,   273,
     274,   275,   276,   278,   279,   282,   284,   286,   256,    80,
     257,   257,   287,   383,   124,     6,    19,   236,   237,   240,
     241,   281,   284,   286,     6,   236,   236,    22,   236,   236,
       6,     4,    28,   289,     6,     4,    11,   236,   289,    21,
     178,   290,   291,   305,   290,     6,   214,   246,   248,   254,
     271,   278,   282,   298,   299,   300,   301,   290,    21,    36,
      86,   166,   178,   291,   292,     6,    21,    45,   307,    76,
     167,   302,   305,   310,   340,    21,    61,   103,   122,   156,
     163,   281,   315,   319,    21,   191,   232,   316,   319,     4,
      21,     4,    21,   289,     4,     6,    90,   177,   193,   214,
     286,    21,   256,   322,    46,    96,   120,   124,     4,    21,
      70,   325,   326,   327,   328,   334,    21,     6,    21,   224,
     226,   228,   256,   259,   275,   280,   281,   332,   341,   290,
     214,   232,   346,   347,   348,     0,   302,   376,   379,   382,
      60,    77,   302,   305,   365,   366,   371,   372,   376,   379,
     382,    21,    33,   139,    83,   132,    62,    91,   125,   127,
       6,   351,   369,   374,   375,   307,   370,   374,   377,    21,
     365,   366,   365,   366,   365,   366,   365,   366,    16,    11,
      18,   236,    11,     6,     6,     6,     6,     6,     6,     6,
      91,   125,   207,    81,   343,    21,     4,   207,   112,   239,
      10,   214,   350,     4,   204,   350,   344,    10,   232,   346,
     191,   205,   343,     9,   355,   357,   214,   167,   222,   286,
     246,   298,    21,    21,   335,   214,   337,    21,   224,    21,
      21,    21,    21,   266,    21,   236,    95,   162,   236,   224,
     224,    21,     6,    51,    11,   214,   246,   271,   286,   255,
     286,   255,   286,    27,   236,   269,   270,     6,   269,     6,
       6,   236,    25,    55,   216,   217,   253,   215,   215,     7,
      10,    11,   218,    12,    13,   220,    19,   237,     4,     5,
      21,   236,     6,    23,   121,   249,   250,    24,    36,   251,
     253,     6,    15,    17,   252,   286,   261,     6,   232,     6,
     253,     6,     6,    11,    21,   236,    22,   343,   205,   384,
     170,   256,   224,     6,   222,   224,    10,    14,   214,   242,
     243,   244,   245,     4,     5,    21,    22,     5,     6,   280,
     281,   288,   232,   317,   214,   230,   231,   232,   286,   288,
     233,   265,   268,   277,   287,   232,    75,   214,   271,   298,
      27,    29,   184,   185,   186,   289,   169,   297,    27,    29,
     184,   185,   186,   289,     6,    27,    29,   184,   185,   186,
     289,    27,    29,   184,   185,   186,   289,    27,    29,   184,
     185,   186,   289,   249,   297,   251,   329,   230,     6,   266,
     203,   305,   310,    21,     6,     6,     6,     6,     6,   315,
     316,   232,   286,   214,   214,    70,   246,   214,    21,    11,
       4,    21,   214,   214,   246,     6,   135,    21,   328,    34,
      82,     6,   214,   246,   286,     4,     5,    14,     5,     4,
       6,   281,   341,   346,    21,   266,    86,   305,   365,    21,
     302,   365,   372,    21,   351,   187,   190,   191,   193,   194,
     196,   373,   374,   377,    21,   365,    21,   365,    21,   365,
      21,   365,   236,   236,   266,   350,   350,   350,   350,   225,
     207,   343,   343,   212,     5,     4,     5,     5,     5,   159,
     350,    21,   208,   289,    11,    21,   170,   338,     4,    21,
      21,    95,   162,     5,     5,   208,   381,   198,   378,     5,
       5,     5,    16,    11,    18,    19,   224,   230,   346,     6,
     215,   215,     6,   189,   214,   272,   286,   215,   218,   218,
     219,     6,    10,   346,   230,   247,   248,   252,   254,    11,
     224,     5,   230,   214,   272,   230,   116,   280,   234,    21,
     225,    22,     4,    21,   214,   170,     5,    20,   238,    46,
     214,   244,   170,   216,   217,     5,   289,    21,    14,     4,
       5,   236,   236,   236,   236,     5,   214,   214,   214,   214,
     214,   214,   248,   248,   248,   248,   248,   248,   298,   214,
     271,   271,   271,   271,   271,   271,   278,   278,   278,   278,
     278,   278,   192,   282,   286,   282,   282,   282,   282,   282,
     248,   299,   300,    21,     5,   281,   286,   308,    21,   214,
     214,   214,   214,   214,    21,    21,     5,    21,    21,    21,
     256,   214,   214,   214,    11,    21,     4,     5,   208,    21,
       4,     5,    21,    21,    21,    21,   236,     5,     5,     5,
       4,     5,     6,     5,    75,    28,   214,   214,     4,     5,
     236,   236,     6,     5,     5,   346,    11,    20,     5,     5,
     252,     5,     5,     5,     5,     5,   236,   225,   225,    21,
     214,    20,   239,   260,   214,   244,   215,   215,   232,   231,
       5,    21,   307,     4,     5,     5,     5,     5,     5,     5,
       5,   170,    51,   208,    20,   261,   239,    21,     4,     5,
       5,     5,     6,   281,   286,    21,   281,   214,   260,     4,
      20,   238,   308,    21,     5,   214,     5,     5,    21
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
     223,   223,   224,   224,   225,   226,   227,   228,   228,   228,
     228,   229,   229,   229,   230,   230,   231,   231,   231,   232,
     232,   232,   232,   232,   233,   233,   234,   234,   234,   234,
     234,   234,   234,   234,   235,   235,   235,   235,   235,   235,
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
     290,   291,   291,   291,   291,   291,   291,   291,   291,   291,
     291,   291,   291,   291,   291,   291,   291,   291,   291,   291,
     291,   291,   291,   291,   291,   291,   291,   291,   291,   291,
     291,   291,   291,   291,   291,   291,   291,   291,   291,   291,
     291,   291,   292,   292,   292,   293,   293,   294,   294,   295,
     296,   297,   298,   298,   299,   299,   300,   300,   300,   301,
     301,   301,   301,   301,   301,   301,   301,   301,   301,   301,
     301,   301,   301,   301,   301,   301,   301,   301,   301,   301,
     301,   301,   301,   301,   301,   301,   301,   301,   301,   302,
     302,   303,   303,   304,   304,   304,   304,   305,   306,   307,
     308,   308,   308,   308,   309,   309,   309,   309,   309,   309,
     309,   309,   310,   310,   310,   311,   311,   312,   313,   313,
     314,   314,   315,   315,   316,   316,   316,   317,   318,   319,
     319,   319,   319,   319,   320,   321,   321,   322,   322,   323,
     323,   323,   323,   324,   324,   324,   325,   325,   325,   326,
     326,   326,   327,   328,   328,   329,   329,   329,   330,   331,
     331,   332,   332,   333,   334,   334,   335,   335,   336,   336,
     337,   337,   338,   338,   339,   339,   340,   341,   341,   341,
     341,   342,   342,   343,   343,   344,   344,   344,   344,   344,
     344,   344,   344,   344,   344,   344,   344,   345,   345,   345,
     346,   346,   346,   346,   346,   347,   348,   348,   349,   350,
     350,   351,   351,   351,   351,   351,   352,   352,   353,   354,
     355,   355,   356,   357,   358,   358,   358,   359,   359,   359,
     359,   359,   359,   359,   359,   359,   360,   360,   361,   362,
     362,   362,   362,   362,   363,   363,   363,   363,   363,   363,
     363,   363,   363,   364,   364,   365,   365,   365,   366,   366,
     366,   367,   368,   369,   369,   369,   370,   370,   370,   371,
     371,   372,   372,   372,   372,   373,   373,   373,   373,   373,
     373,   374,   375,   375,   376,   377,   378,   379,   380,   380,
     381,   381,   382,   383,   383,   383,   384,   385,   385,   385,
     385,   386,   386,   387,   387,   388,   388,   389,   390,   390,
     391,   392
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
       4,     3,     4,     3,     4,     3,     1,     1,     4,     2,
       4,     4,     1,     1,     1,     1,     1,     1,     2,     3,
       4,     3,     4,     3,     1,     3,     1,     3,     1,     1,
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
       1,     3,     1,     3,     3,     3,     3,     1,     1,     1,
       1,     2,     2,     2,     3,     2,     3,     4,     1,     2,
       5,     6,     9,     2,     3,     3,     2,     2,     2,     2,
       4,     4,     4,     4,     3,     4,     4,     2,     3,     5,
       6,     2,     3,     2,     4,     3,     2,     4,     4,     3,
       2,     4,     1,     2,     2,     2,     2,     3,     3,     3,
       1,     1,     1,     3,     1,     3,     3,     4,     1,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     1,
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
       1,     2,     2,     3,     1,     2,     2,     3,     2,     1,
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
#line 645 "HAL_S.y"
                                { (yyval.declare_body_) = make_AAdeclareBody_declarationList((yyvsp[0].declaration_list_)); (yyval.declare_body_)->line_number = (yyloc).first_line; (yyval.declare_body_)->char_number = (yyloc).first_column;  }
#line 4313 "Parser.c"
    break;

  case 3: /* DECLARE_BODY: ATTRIBUTES _SYMB_0 DECLARATION_LIST  */
#line 646 "HAL_S.y"
                                        { (yyval.declare_body_) = make_ABdeclareBody_attributes_declarationList((yyvsp[-2].attributes_), (yyvsp[0].declaration_list_)); (yyval.declare_body_)->line_number = (yyloc).first_line; (yyval.declare_body_)->char_number = (yyloc).first_column;  }
#line 4319 "Parser.c"
    break;

  case 4: /* ATTRIBUTES: ARRAY_SPEC TYPE_AND_MINOR_ATTR  */
#line 648 "HAL_S.y"
                                            { (yyval.attributes_) = make_AAattributes_arraySpec_typeAndMinorAttr((yyvsp[-1].array_spec_), (yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4325 "Parser.c"
    break;

  case 5: /* ATTRIBUTES: ARRAY_SPEC  */
#line 649 "HAL_S.y"
               { (yyval.attributes_) = make_ABattributes_arraySpec((yyvsp[0].array_spec_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4331 "Parser.c"
    break;

  case 6: /* ATTRIBUTES: TYPE_AND_MINOR_ATTR  */
#line 650 "HAL_S.y"
                        { (yyval.attributes_) = make_ACattributes_typeAndMinorAttr((yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4337 "Parser.c"
    break;

  case 7: /* DECLARATION: NAME_ID  */
#line 652 "HAL_S.y"
                      { (yyval.declaration_) = make_AAdeclaration_nameId((yyvsp[0].name_id_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4343 "Parser.c"
    break;

  case 8: /* DECLARATION: NAME_ID ATTRIBUTES  */
#line 653 "HAL_S.y"
                       { (yyval.declaration_) = make_ABdeclaration_nameId_attributes((yyvsp[-1].name_id_), (yyvsp[0].attributes_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4349 "Parser.c"
    break;

  case 9: /* DECLARATION: _SYMB_189  */
#line 654 "HAL_S.y"
              { (yyval.declaration_) = make_ACdeclaration_labelToken((yyvsp[0].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4355 "Parser.c"
    break;

  case 10: /* DECLARATION: _SYMB_189 TYPE_AND_MINOR_ATTR  */
#line 655 "HAL_S.y"
                                  { (yyval.declaration_) = make_ACdeclaration_labelToken_type_minorAttrList((yyvsp[-1].string_), (yyvsp[0].type_and_minor_attr_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4361 "Parser.c"
    break;

  case 11: /* DECLARATION: _SYMB_189 _SYMB_121 MINOR_ATTR_LIST  */
#line 656 "HAL_S.y"
                                        { (yyval.declaration_) = make_ACdeclaration_labelToken_procedure_minorAttrList((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4367 "Parser.c"
    break;

  case 12: /* DECLARATION: _SYMB_189 _SYMB_121  */
#line 657 "HAL_S.y"
                        { (yyval.declaration_) = make_ADdeclaration_labelToken_procedure((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4373 "Parser.c"
    break;

  case 13: /* DECLARATION: _SYMB_189 _SYMB_87 TYPE_AND_MINOR_ATTR  */
#line 658 "HAL_S.y"
                                           { (yyval.declaration_) = make_ACdeclaration_labelToken_function_minorAttrList((yyvsp[-2].string_), (yyvsp[0].type_and_minor_attr_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4379 "Parser.c"
    break;

  case 14: /* DECLARATION: _SYMB_189 _SYMB_87  */
#line 659 "HAL_S.y"
                       { (yyval.declaration_) = make_ADdeclaration_labelToken_function((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4385 "Parser.c"
    break;

  case 15: /* DECLARATION: _SYMB_190 _SYMB_77  */
#line 660 "HAL_S.y"
                       { (yyval.declaration_) = make_AEdeclaration_eventToken_event((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4391 "Parser.c"
    break;

  case 16: /* DECLARATION: _SYMB_190 _SYMB_77 MINOR_ATTR_LIST  */
#line 661 "HAL_S.y"
                                       { (yyval.declaration_) = make_AFdeclaration_eventToken_event_minorAttrList((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4397 "Parser.c"
    break;

  case 17: /* DECLARATION: _SYMB_190  */
#line 662 "HAL_S.y"
              { (yyval.declaration_) = make_AGdeclaration_eventToken((yyvsp[0].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4403 "Parser.c"
    break;

  case 18: /* DECLARATION: _SYMB_190 MINOR_ATTR_LIST  */
#line 663 "HAL_S.y"
                              { (yyval.declaration_) = make_AHdeclaration_eventToken_minorAttrList((yyvsp[-1].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4409 "Parser.c"
    break;

  case 19: /* ARRAY_SPEC: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 665 "HAL_S.y"
                                                    { (yyval.array_spec_) = make_AAarraySpec_arrayHead_literalExpOrStar((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4415 "Parser.c"
    break;

  case 20: /* ARRAY_SPEC: _SYMB_87  */
#line 666 "HAL_S.y"
             { (yyval.array_spec_) = make_ABarraySpec_function(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4421 "Parser.c"
    break;

  case 21: /* ARRAY_SPEC: _SYMB_121  */
#line 667 "HAL_S.y"
              { (yyval.array_spec_) = make_ACarraySpec_procedure(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4427 "Parser.c"
    break;

  case 22: /* ARRAY_SPEC: _SYMB_123  */
#line 668 "HAL_S.y"
              { (yyval.array_spec_) = make_ADarraySpec_program(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4433 "Parser.c"
    break;

  case 23: /* ARRAY_SPEC: _SYMB_162  */
#line 669 "HAL_S.y"
              { (yyval.array_spec_) = make_AEarraySpec_task(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4439 "Parser.c"
    break;

  case 24: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC  */
#line 671 "HAL_S.y"
                                { (yyval.type_and_minor_attr_) = make_AAtypeAndMinorAttr_typeSpec((yyvsp[0].type_spec_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4445 "Parser.c"
    break;

  case 25: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC MINOR_ATTR_LIST  */
#line 672 "HAL_S.y"
                              { (yyval.type_and_minor_attr_) = make_ABtypeAndMinorAttr_typeSpec_minorAttrList((yyvsp[-1].type_spec_), (yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4451 "Parser.c"
    break;

  case 26: /* TYPE_AND_MINOR_ATTR: MINOR_ATTR_LIST  */
#line 673 "HAL_S.y"
                    { (yyval.type_and_minor_attr_) = make_ACtypeAndMinorAttr_minorAttrList((yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4457 "Parser.c"
    break;

  case 27: /* IDENTIFIER: _SYMB_192  */
#line 675 "HAL_S.y"
                       { (yyval.identifier_) = make_AAidentifier((yyvsp[0].string_)); (yyval.identifier_)->line_number = (yyloc).first_line; (yyval.identifier_)->char_number = (yyloc).first_column;  }
#line 4463 "Parser.c"
    break;

  case 28: /* SQ_DQ_NAME: DOUBLY_QUAL_NAME_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 677 "HAL_S.y"
                                                               { (yyval.sq_dq_name_) = make_AAsQdQName_doublyQualNameHead_literalExpOrStar((yyvsp[-2].doubly_qual_name_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 4469 "Parser.c"
    break;

  case 29: /* SQ_DQ_NAME: ARITH_CONV  */
#line 678 "HAL_S.y"
               { (yyval.sq_dq_name_) = make_ABsQdQName_arithConv((yyvsp[0].arith_conv_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 4475 "Parser.c"
    break;

  case 30: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_175 _SYMB_2  */
#line 680 "HAL_S.y"
                                          { (yyval.doubly_qual_name_head_) = make_AAdoublyQualNameHead_vector(); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 4481 "Parser.c"
    break;

  case 31: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_103 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_0  */
#line 681 "HAL_S.y"
                                                  { (yyval.doubly_qual_name_head_) = make_ABdoublyQualNameHead_matrix_literalExpOrStar((yyvsp[-1].literal_exp_or_star_)); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 4487 "Parser.c"
    break;

  case 32: /* ARITH_CONV: _SYMB_95  */
#line 683 "HAL_S.y"
                      { (yyval.arith_conv_) = make_AAarithConv_integer(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4493 "Parser.c"
    break;

  case 33: /* ARITH_CONV: _SYMB_139  */
#line 684 "HAL_S.y"
              { (yyval.arith_conv_) = make_ABarithConv_scalar(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4499 "Parser.c"
    break;

  case 34: /* ARITH_CONV: _SYMB_175  */
#line 685 "HAL_S.y"
              { (yyval.arith_conv_) = make_ACarithConv_vector(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4505 "Parser.c"
    break;

  case 35: /* ARITH_CONV: _SYMB_103  */
#line 686 "HAL_S.y"
              { (yyval.arith_conv_) = make_ADarithConv_matrix(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4511 "Parser.c"
    break;

  case 36: /* DECLARATION_LIST: DECLARATION  */
#line 688 "HAL_S.y"
                               { (yyval.declaration_list_) = make_AAdeclaration_list((yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 4517 "Parser.c"
    break;

  case 37: /* DECLARATION_LIST: DCL_LIST_COMMA DECLARATION  */
#line 689 "HAL_S.y"
                               { (yyval.declaration_list_) = make_ABdeclaration_list((yyvsp[-1].dcl_list_comma_), (yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 4523 "Parser.c"
    break;

  case 38: /* NAME_ID: IDENTIFIER  */
#line 691 "HAL_S.y"
                     { (yyval.name_id_) = make_AAnameId_identifier((yyvsp[0].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4529 "Parser.c"
    break;

  case 39: /* NAME_ID: IDENTIFIER _SYMB_108  */
#line 692 "HAL_S.y"
                         { (yyval.name_id_) = make_ABnameId_identifier_name((yyvsp[-1].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4535 "Parser.c"
    break;

  case 40: /* NAME_ID: BIT_ID  */
#line 693 "HAL_S.y"
           { (yyval.name_id_) = make_ACnameId_bitId((yyvsp[0].bit_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4541 "Parser.c"
    break;

  case 41: /* NAME_ID: CHAR_ID  */
#line 694 "HAL_S.y"
            { (yyval.name_id_) = make_ADnameId_charId((yyvsp[0].char_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4547 "Parser.c"
    break;

  case 42: /* NAME_ID: _SYMB_184  */
#line 695 "HAL_S.y"
              { (yyval.name_id_) = make_AEnameId_bitFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4553 "Parser.c"
    break;

  case 43: /* NAME_ID: _SYMB_185  */
#line 696 "HAL_S.y"
              { (yyval.name_id_) = make_AFnameId_charFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4559 "Parser.c"
    break;

  case 44: /* NAME_ID: _SYMB_187  */
#line 697 "HAL_S.y"
              { (yyval.name_id_) = make_AGnameId_structIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4565 "Parser.c"
    break;

  case 45: /* NAME_ID: _SYMB_188  */
#line 698 "HAL_S.y"
              { (yyval.name_id_) = make_AHnameId_structFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4571 "Parser.c"
    break;

  case 46: /* ARITH_EXP: TERM  */
#line 700 "HAL_S.y"
                 { (yyval.arith_exp_) = make_AAarithExpTerm((yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4577 "Parser.c"
    break;

  case 47: /* ARITH_EXP: PLUS TERM  */
#line 701 "HAL_S.y"
              { (yyval.arith_exp_) = make_ABarithExpPlusTerm((yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4583 "Parser.c"
    break;

  case 48: /* ARITH_EXP: MINUS TERM  */
#line 702 "HAL_S.y"
               { (yyval.arith_exp_) = make_ACarithMinusTerm((yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4589 "Parser.c"
    break;

  case 49: /* ARITH_EXP: ARITH_EXP PLUS TERM  */
#line 703 "HAL_S.y"
                        { (yyval.arith_exp_) = make_ADarithExpArithExpPlusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4595 "Parser.c"
    break;

  case 50: /* ARITH_EXP: ARITH_EXP MINUS TERM  */
#line 704 "HAL_S.y"
                         { (yyval.arith_exp_) = make_AEarithExpArithExpMinusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4601 "Parser.c"
    break;

  case 51: /* TERM: PRODUCT  */
#line 706 "HAL_S.y"
               { (yyval.term_) = make_AAtermNoDivide((yyvsp[0].product_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4607 "Parser.c"
    break;

  case 52: /* TERM: PRODUCT _SYMB_3 TERM  */
#line 707 "HAL_S.y"
                         { (yyval.term_) = make_ABtermDivide((yyvsp[-2].product_), (yyvsp[0].term_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4613 "Parser.c"
    break;

  case 53: /* PLUS: _SYMB_4  */
#line 709 "HAL_S.y"
               { (yyval.plus_) = make_AAplus(); (yyval.plus_)->line_number = (yyloc).first_line; (yyval.plus_)->char_number = (yyloc).first_column;  }
#line 4619 "Parser.c"
    break;

  case 54: /* MINUS: _SYMB_5  */
#line 711 "HAL_S.y"
                { (yyval.minus_) = make_AAminus(); (yyval.minus_)->line_number = (yyloc).first_line; (yyval.minus_)->char_number = (yyloc).first_column;  }
#line 4625 "Parser.c"
    break;

  case 55: /* PRODUCT: FACTOR  */
#line 713 "HAL_S.y"
                 { (yyval.product_) = make_AAproductSingle((yyvsp[0].factor_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4631 "Parser.c"
    break;

  case 56: /* PRODUCT: FACTOR _SYMB_6 PRODUCT  */
#line 714 "HAL_S.y"
                           { (yyval.product_) = make_ABproductCross((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4637 "Parser.c"
    break;

  case 57: /* PRODUCT: FACTOR _SYMB_7 PRODUCT  */
#line 715 "HAL_S.y"
                           { (yyval.product_) = make_ACproductDot((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4643 "Parser.c"
    break;

  case 58: /* PRODUCT: FACTOR PRODUCT  */
#line 716 "HAL_S.y"
                   { (yyval.product_) = make_ADproductMultiplication((yyvsp[-1].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4649 "Parser.c"
    break;

  case 59: /* FACTOR: PRIMARY  */
#line 718 "HAL_S.y"
                 { (yyval.factor_) = make_AAfactor((yyvsp[0].primary_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4655 "Parser.c"
    break;

  case 60: /* FACTOR: PRIMARY EXPONENTIATION FACTOR  */
#line 719 "HAL_S.y"
                                  { (yyval.factor_) = make_ABfactorExponentiation((yyvsp[-2].primary_), (yyvsp[-1].exponentiation_), (yyvsp[0].factor_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4661 "Parser.c"
    break;

  case 61: /* FACTOR: PRIMARY _SYMB_8  */
#line 720 "HAL_S.y"
                    { (yyval.factor_) = make_ABfactorTranspose((yyvsp[-1].primary_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4667 "Parser.c"
    break;

  case 62: /* EXPONENTIATION: _SYMB_9  */
#line 722 "HAL_S.y"
                         { (yyval.exponentiation_) = make_AAexponentiation(); (yyval.exponentiation_)->line_number = (yyloc).first_line; (yyval.exponentiation_)->char_number = (yyloc).first_column;  }
#line 4673 "Parser.c"
    break;

  case 63: /* PRIMARY: ARITH_VAR  */
#line 724 "HAL_S.y"
                    { (yyval.primary_) = make_AAprimary((yyvsp[0].arith_var_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4679 "Parser.c"
    break;

  case 64: /* PRIMARY: PRE_PRIMARY  */
#line 725 "HAL_S.y"
                { (yyval.primary_) = make_ADprimary((yyvsp[0].pre_primary_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4685 "Parser.c"
    break;

  case 65: /* PRIMARY: MODIFIED_ARITH_FUNC  */
#line 726 "HAL_S.y"
                        { (yyval.primary_) = make_ABprimary((yyvsp[0].modified_arith_func_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4691 "Parser.c"
    break;

  case 66: /* PRIMARY: PRE_PRIMARY QUALIFIER  */
#line 727 "HAL_S.y"
                          { (yyval.primary_) = make_AEprimary((yyvsp[-1].pre_primary_), (yyvsp[0].qualifier_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4697 "Parser.c"
    break;

  case 67: /* ARITH_VAR: ARITH_ID  */
#line 729 "HAL_S.y"
                     { (yyval.arith_var_) = make_AAarith_var((yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4703 "Parser.c"
    break;

  case 68: /* ARITH_VAR: ARITH_ID SUBSCRIPT  */
#line 730 "HAL_S.y"
                       { (yyval.arith_var_) = make_ACarith_var((yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4709 "Parser.c"
    break;

  case 69: /* ARITH_VAR: _SYMB_11 ARITH_ID _SYMB_12  */
#line 731 "HAL_S.y"
                               { (yyval.arith_var_) = make_AAarithVarBracketed((yyvsp[-1].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4715 "Parser.c"
    break;

  case 70: /* ARITH_VAR: _SYMB_11 ARITH_ID _SYMB_12 SUBSCRIPT  */
#line 732 "HAL_S.y"
                                         { (yyval.arith_var_) = make_ABarithVarBracketed((yyvsp[-2].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4721 "Parser.c"
    break;

  case 71: /* ARITH_VAR: _SYMB_13 QUAL_STRUCT _SYMB_14  */
#line 733 "HAL_S.y"
                                  { (yyval.arith_var_) = make_AAarithVarBraced((yyvsp[-1].qual_struct_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4727 "Parser.c"
    break;

  case 72: /* ARITH_VAR: _SYMB_13 QUAL_STRUCT _SYMB_14 SUBSCRIPT  */
#line 734 "HAL_S.y"
                                            { (yyval.arith_var_) = make_ABarithVarBraced((yyvsp[-2].qual_struct_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4733 "Parser.c"
    break;

  case 73: /* ARITH_VAR: QUAL_STRUCT _SYMB_7 ARITH_ID  */
#line 735 "HAL_S.y"
                                 { (yyval.arith_var_) = make_ABarith_var((yyvsp[-2].qual_struct_), (yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4739 "Parser.c"
    break;

  case 74: /* ARITH_VAR: QUAL_STRUCT _SYMB_7 ARITH_ID SUBSCRIPT  */
#line 736 "HAL_S.y"
                                           { (yyval.arith_var_) = make_ADarith_var((yyvsp[-3].qual_struct_), (yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4745 "Parser.c"
    break;

  case 75: /* PRE_PRIMARY: _SYMB_2 ARITH_EXP _SYMB_1  */
#line 738 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AApre_primary((yyvsp[-1].arith_exp_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4751 "Parser.c"
    break;

  case 76: /* PRE_PRIMARY: NUMBER  */
#line 739 "HAL_S.y"
           { (yyval.pre_primary_) = make_ABpre_primary((yyvsp[0].number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4757 "Parser.c"
    break;

  case 77: /* PRE_PRIMARY: COMPOUND_NUMBER  */
#line 740 "HAL_S.y"
                    { (yyval.pre_primary_) = make_ACpre_primary((yyvsp[0].compound_number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4763 "Parser.c"
    break;

  case 78: /* PRE_PRIMARY: ARITH_FUNC _SYMB_2 CALL_LIST _SYMB_1  */
#line 741 "HAL_S.y"
                                         { (yyval.pre_primary_) = make_ADprePrimaryRtlFunction((yyvsp[-3].arith_func_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4769 "Parser.c"
    break;

  case 79: /* PRE_PRIMARY: SHAPING_HEAD _SYMB_1  */
#line 742 "HAL_S.y"
                         { (yyval.pre_primary_) = make_ADprePrimaryRtlShaping((yyvsp[-1].shaping_head_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4775 "Parser.c"
    break;

  case 80: /* PRE_PRIMARY: SHAPING_HEAD _SYMB_0 _SYMB_6 _SYMB_1  */
#line 743 "HAL_S.y"
                                         { (yyval.pre_primary_) = make_ADprePrimaryRtlShapingStar((yyvsp[-3].shaping_head_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4781 "Parser.c"
    break;

  case 81: /* PRE_PRIMARY: _SYMB_189 _SYMB_2 CALL_LIST _SYMB_1  */
#line 744 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AEprePrimaryFunction((yyvsp[-3].string_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4787 "Parser.c"
    break;

  case 82: /* NUMBER: SIMPLE_NUMBER  */
#line 746 "HAL_S.y"
                       { (yyval.number_) = make_AAnumber((yyvsp[0].simple_number_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4793 "Parser.c"
    break;

  case 83: /* NUMBER: LEVEL  */
#line 747 "HAL_S.y"
          { (yyval.number_) = make_ABnumber((yyvsp[0].level_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4799 "Parser.c"
    break;

  case 84: /* LEVEL: _SYMB_195  */
#line 749 "HAL_S.y"
                  { (yyval.level_) = make_ZZlevel((yyvsp[0].string_)); (yyval.level_)->line_number = (yyloc).first_line; (yyval.level_)->char_number = (yyloc).first_column;  }
#line 4805 "Parser.c"
    break;

  case 85: /* COMPOUND_NUMBER: _SYMB_197  */
#line 751 "HAL_S.y"
                            { (yyval.compound_number_) = make_CLcompound_number((yyvsp[0].string_)); (yyval.compound_number_)->line_number = (yyloc).first_line; (yyval.compound_number_)->char_number = (yyloc).first_column;  }
#line 4811 "Parser.c"
    break;

  case 86: /* SIMPLE_NUMBER: _SYMB_196  */
#line 753 "HAL_S.y"
                          { (yyval.simple_number_) = make_CKsimple_number((yyvsp[0].string_)); (yyval.simple_number_)->line_number = (yyloc).first_line; (yyval.simple_number_)->char_number = (yyloc).first_column;  }
#line 4817 "Parser.c"
    break;

  case 87: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC  */
#line 755 "HAL_S.y"
                                        { (yyval.modified_arith_func_) = make_AAmodified_arith_func((yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4823 "Parser.c"
    break;

  case 88: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 756 "HAL_S.y"
                                { (yyval.modified_arith_func_) = make_ACmodified_arith_func((yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4829 "Parser.c"
    break;

  case 89: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_7 NO_ARG_ARITH_FUNC  */
#line 757 "HAL_S.y"
                                          { (yyval.modified_arith_func_) = make_ADmodified_arith_func((yyvsp[-2].qual_struct_), (yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4835 "Parser.c"
    break;

  case 90: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_7 NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 758 "HAL_S.y"
                                                    { (yyval.modified_arith_func_) = make_AEmodified_arith_func((yyvsp[-3].qual_struct_), (yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4841 "Parser.c"
    break;

  case 91: /* SHAPING_HEAD: ARITH_CONV _SYMB_2 REPEATED_CONSTANT  */
#line 760 "HAL_S.y"
                                                    { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHead((yyvsp[-2].arith_conv_), (yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 4847 "Parser.c"
    break;

  case 92: /* SHAPING_HEAD: ARITH_CONV SUBSCRIPT _SYMB_2 REPEATED_CONSTANT  */
#line 761 "HAL_S.y"
                                                   { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadSubscript((yyvsp[-3].arith_conv_), (yyvsp[-2].subscript_), (yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 4853 "Parser.c"
    break;

  case 93: /* SHAPING_HEAD: SHAPING_HEAD _SYMB_0 REPEATED_CONSTANT  */
#line 762 "HAL_S.y"
                                           { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadRepeated((yyvsp[-2].shaping_head_), (yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 4859 "Parser.c"
    break;

  case 94: /* CALL_LIST: LIST_EXP  */
#line 764 "HAL_S.y"
                     { (yyval.call_list_) = make_AAcall_list((yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 4865 "Parser.c"
    break;

  case 95: /* CALL_LIST: CALL_LIST _SYMB_0 LIST_EXP  */
#line 765 "HAL_S.y"
                               { (yyval.call_list_) = make_ABcall_list((yyvsp[-2].call_list_), (yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 4871 "Parser.c"
    break;

  case 96: /* LIST_EXP: EXPRESSION  */
#line 767 "HAL_S.y"
                      { (yyval.list_exp_) = make_AAlist_exp((yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4877 "Parser.c"
    break;

  case 97: /* LIST_EXP: ARITH_EXP _SYMB_10 EXPRESSION  */
#line 768 "HAL_S.y"
                                  { (yyval.list_exp_) = make_ABlist_expRepeated((yyvsp[-2].arith_exp_), (yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4883 "Parser.c"
    break;

  case 98: /* LIST_EXP: QUAL_STRUCT  */
#line 769 "HAL_S.y"
                { (yyval.list_exp_) = make_ADlist_exp((yyvsp[0].qual_struct_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4889 "Parser.c"
    break;

  case 99: /* EXPRESSION: ARITH_EXP  */
#line 771 "HAL_S.y"
                       { (yyval.expression_) = make_AAexpression((yyvsp[0].arith_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4895 "Parser.c"
    break;

  case 100: /* EXPRESSION: BIT_EXP  */
#line 772 "HAL_S.y"
            { (yyval.expression_) = make_ABexpression((yyvsp[0].bit_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4901 "Parser.c"
    break;

  case 101: /* EXPRESSION: CHAR_EXP  */
#line 773 "HAL_S.y"
             { (yyval.expression_) = make_ACexpression((yyvsp[0].char_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4907 "Parser.c"
    break;

  case 102: /* EXPRESSION: NAME_EXP  */
#line 774 "HAL_S.y"
             { (yyval.expression_) = make_AEexpression((yyvsp[0].name_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4913 "Parser.c"
    break;

  case 103: /* EXPRESSION: STRUCTURE_EXP  */
#line 775 "HAL_S.y"
                  { (yyval.expression_) = make_ADexpression((yyvsp[0].structure_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4919 "Parser.c"
    break;

  case 104: /* ARITH_ID: IDENTIFIER  */
#line 777 "HAL_S.y"
                      { (yyval.arith_id_) = make_FGarith_id((yyvsp[0].identifier_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 4925 "Parser.c"
    break;

  case 105: /* ARITH_ID: _SYMB_191  */
#line 778 "HAL_S.y"
              { (yyval.arith_id_) = make_FHarith_id((yyvsp[0].string_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 4931 "Parser.c"
    break;

  case 106: /* NO_ARG_ARITH_FUNC: _SYMB_55  */
#line 780 "HAL_S.y"
                             { (yyval.no_arg_arith_func_) = make_ZZclocktime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4937 "Parser.c"
    break;

  case 107: /* NO_ARG_ARITH_FUNC: _SYMB_62  */
#line 781 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZdate(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4943 "Parser.c"
    break;

  case 108: /* NO_ARG_ARITH_FUNC: _SYMB_74  */
#line 782 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZerrgrp(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4949 "Parser.c"
    break;

  case 109: /* NO_ARG_ARITH_FUNC: _SYMB_75  */
#line 783 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZerrnum(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4955 "Parser.c"
    break;

  case 110: /* NO_ARG_ARITH_FUNC: _SYMB_119  */
#line 784 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZprio(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4961 "Parser.c"
    break;

  case 111: /* NO_ARG_ARITH_FUNC: _SYMB_124  */
#line 785 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZrandom(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4967 "Parser.c"
    break;

  case 112: /* NO_ARG_ARITH_FUNC: _SYMB_125  */
#line 786 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZrandomg(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4973 "Parser.c"
    break;

  case 113: /* NO_ARG_ARITH_FUNC: _SYMB_138  */
#line 787 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZruntime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4979 "Parser.c"
    break;

  case 114: /* ARITH_FUNC: _SYMB_109  */
#line 789 "HAL_S.y"
                       { (yyval.arith_func_) = make_ZZnextime(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4985 "Parser.c"
    break;

  case 115: /* ARITH_FUNC: _SYMB_27  */
#line 790 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabs(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4991 "Parser.c"
    break;

  case 116: /* ARITH_FUNC: _SYMB_52  */
#line 791 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZceiling(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4997 "Parser.c"
    break;

  case 117: /* ARITH_FUNC: _SYMB_68  */
#line 792 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdiv(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5003 "Parser.c"
    break;

  case 118: /* ARITH_FUNC: _SYMB_85  */
#line 793 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZfloor(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5009 "Parser.c"
    break;

  case 119: /* ARITH_FUNC: _SYMB_105  */
#line 794 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmidval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5015 "Parser.c"
    break;

  case 120: /* ARITH_FUNC: _SYMB_107  */
#line 795 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5021 "Parser.c"
    break;

  case 121: /* ARITH_FUNC: _SYMB_114  */
#line 796 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZodd(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5027 "Parser.c"
    break;

  case 122: /* ARITH_FUNC: _SYMB_129  */
#line 797 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZremainder(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5033 "Parser.c"
    break;

  case 123: /* ARITH_FUNC: _SYMB_137  */
#line 798 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZround(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5039 "Parser.c"
    break;

  case 124: /* ARITH_FUNC: _SYMB_145  */
#line 799 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsign(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5045 "Parser.c"
    break;

  case 125: /* ARITH_FUNC: _SYMB_147  */
#line 800 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsignum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5051 "Parser.c"
    break;

  case 126: /* ARITH_FUNC: _SYMB_171  */
#line 801 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtruncate(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5057 "Parser.c"
    break;

  case 127: /* ARITH_FUNC: _SYMB_33  */
#line 802 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5063 "Parser.c"
    break;

  case 128: /* ARITH_FUNC: _SYMB_34  */
#line 803 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5069 "Parser.c"
    break;

  case 129: /* ARITH_FUNC: _SYMB_35  */
#line 804 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5075 "Parser.c"
    break;

  case 130: /* ARITH_FUNC: _SYMB_36  */
#line 805 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5081 "Parser.c"
    break;

  case 131: /* ARITH_FUNC: _SYMB_38  */
#line 806 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan2(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5087 "Parser.c"
    break;

  case 132: /* ARITH_FUNC: _SYMB_37  */
#line 807 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5093 "Parser.c"
    break;

  case 133: /* ARITH_FUNC: _SYMB_39  */
#line 808 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5099 "Parser.c"
    break;

  case 134: /* ARITH_FUNC: _SYMB_60  */
#line 809 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5105 "Parser.c"
    break;

  case 135: /* ARITH_FUNC: _SYMB_61  */
#line 810 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5111 "Parser.c"
    break;

  case 136: /* ARITH_FUNC: _SYMB_81  */
#line 811 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZexp(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5117 "Parser.c"
    break;

  case 137: /* ARITH_FUNC: _SYMB_102  */
#line 812 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZlog(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5123 "Parser.c"
    break;

  case 138: /* ARITH_FUNC: _SYMB_148  */
#line 813 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5129 "Parser.c"
    break;

  case 139: /* ARITH_FUNC: _SYMB_150  */
#line 814 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5135 "Parser.c"
    break;

  case 140: /* ARITH_FUNC: _SYMB_153  */
#line 815 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsqrt(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5141 "Parser.c"
    break;

  case 141: /* ARITH_FUNC: _SYMB_160  */
#line 816 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5147 "Parser.c"
    break;

  case 142: /* ARITH_FUNC: _SYMB_161  */
#line 817 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5153 "Parser.c"
    break;

  case 143: /* ARITH_FUNC: _SYMB_143  */
#line 818 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshl(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5159 "Parser.c"
    break;

  case 144: /* ARITH_FUNC: _SYMB_144  */
#line 819 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshr(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5165 "Parser.c"
    break;

  case 145: /* ARITH_FUNC: _SYMB_28  */
#line 820 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5171 "Parser.c"
    break;

  case 146: /* ARITH_FUNC: _SYMB_67  */
#line 821 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdet(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5177 "Parser.c"
    break;

  case 147: /* ARITH_FUNC: _SYMB_167  */
#line 822 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtrace(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5183 "Parser.c"
    break;

  case 148: /* ARITH_FUNC: _SYMB_172  */
#line 823 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZunit(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5189 "Parser.c"
    break;

  case 149: /* ARITH_FUNC: _SYMB_93  */
#line 824 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZindex(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5195 "Parser.c"
    break;

  case 150: /* ARITH_FUNC: _SYMB_98  */
#line 825 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZlength(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5201 "Parser.c"
    break;

  case 151: /* ARITH_FUNC: _SYMB_96  */
#line 826 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZinverse(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5207 "Parser.c"
    break;

  case 152: /* ARITH_FUNC: _SYMB_168  */
#line 827 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtranspose(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5213 "Parser.c"
    break;

  case 153: /* ARITH_FUNC: _SYMB_122  */
#line 828 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZprod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5219 "Parser.c"
    break;

  case 154: /* ARITH_FUNC: _SYMB_157  */
#line 829 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5225 "Parser.c"
    break;

  case 155: /* ARITH_FUNC: _SYMB_151  */
#line 830 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsize(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5231 "Parser.c"
    break;

  case 156: /* ARITH_FUNC: _SYMB_104  */
#line 831 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmax(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5237 "Parser.c"
    break;

  case 157: /* ARITH_FUNC: _SYMB_106  */
#line 832 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5243 "Parser.c"
    break;

  case 158: /* SUBSCRIPT: SUB_HEAD _SYMB_1  */
#line 834 "HAL_S.y"
                             { (yyval.subscript_) = make_AAsubscript((yyvsp[-1].sub_head_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5249 "Parser.c"
    break;

  case 159: /* SUBSCRIPT: QUALIFIER  */
#line 835 "HAL_S.y"
              { (yyval.subscript_) = make_ABsubscript((yyvsp[0].qualifier_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5255 "Parser.c"
    break;

  case 160: /* SUBSCRIPT: _SYMB_15 NUMBER  */
#line 836 "HAL_S.y"
                    { (yyval.subscript_) = make_ACsubscript((yyvsp[0].number_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5261 "Parser.c"
    break;

  case 161: /* SUBSCRIPT: _SYMB_15 ARITH_VAR  */
#line 837 "HAL_S.y"
                       { (yyval.subscript_) = make_ADsubscript((yyvsp[0].arith_var_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5267 "Parser.c"
    break;

  case 162: /* QUALIFIER: _SYMB_15 _SYMB_2 _SYMB_16 PREC_SPEC _SYMB_1  */
#line 839 "HAL_S.y"
                                                        { (yyval.qualifier_) = make_AAqualifier((yyvsp[-1].prec_spec_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5273 "Parser.c"
    break;

  case 163: /* QUALIFIER: _SYMB_15 _SYMB_2 SCALE_HEAD ARITH_EXP _SYMB_1  */
#line 840 "HAL_S.y"
                                                  { (yyval.qualifier_) = make_ABqualifier((yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5279 "Parser.c"
    break;

  case 164: /* QUALIFIER: _SYMB_15 _SYMB_2 _SYMB_16 PREC_SPEC _SYMB_0 SCALE_HEAD ARITH_EXP _SYMB_1  */
#line 841 "HAL_S.y"
                                                                             { (yyval.qualifier_) = make_ACqualifier((yyvsp[-4].prec_spec_), (yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5285 "Parser.c"
    break;

  case 165: /* QUALIFIER: _SYMB_15 _SYMB_2 _SYMB_16 RADIX _SYMB_1  */
#line 842 "HAL_S.y"
                                            { (yyval.qualifier_) = make_ADqualifier((yyvsp[-1].radix_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5291 "Parser.c"
    break;

  case 166: /* SCALE_HEAD: _SYMB_16  */
#line 844 "HAL_S.y"
                      { (yyval.scale_head_) = make_AAscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 5297 "Parser.c"
    break;

  case 167: /* SCALE_HEAD: _SYMB_16 _SYMB_16  */
#line 845 "HAL_S.y"
                      { (yyval.scale_head_) = make_ABscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 5303 "Parser.c"
    break;

  case 168: /* PREC_SPEC: _SYMB_149  */
#line 847 "HAL_S.y"
                      { (yyval.prec_spec_) = make_AAprecSpecSingle(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 5309 "Parser.c"
    break;

  case 169: /* PREC_SPEC: _SYMB_70  */
#line 848 "HAL_S.y"
             { (yyval.prec_spec_) = make_ABprecSpecDouble(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 5315 "Parser.c"
    break;

  case 170: /* SUB_START: _SYMB_15 _SYMB_2  */
#line 850 "HAL_S.y"
                             { (yyval.sub_start_) = make_AAsubStartGroup(); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5321 "Parser.c"
    break;

  case 171: /* SUB_START: _SYMB_15 _SYMB_2 _SYMB_16 PREC_SPEC _SYMB_0  */
#line 851 "HAL_S.y"
                                                { (yyval.sub_start_) = make_ABsubStartPrecSpec((yyvsp[-1].prec_spec_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5327 "Parser.c"
    break;

  case 172: /* SUB_START: SUB_HEAD _SYMB_17  */
#line 852 "HAL_S.y"
                      { (yyval.sub_start_) = make_ACsubStartSemicolon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5333 "Parser.c"
    break;

  case 173: /* SUB_START: SUB_HEAD _SYMB_18  */
#line 853 "HAL_S.y"
                      { (yyval.sub_start_) = make_ADsubStartColon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5339 "Parser.c"
    break;

  case 174: /* SUB_START: SUB_HEAD _SYMB_0  */
#line 854 "HAL_S.y"
                     { (yyval.sub_start_) = make_AEsubStartComma((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5345 "Parser.c"
    break;

  case 175: /* SUB_HEAD: SUB_START  */
#line 856 "HAL_S.y"
                     { (yyval.sub_head_) = make_AAsub_head((yyvsp[0].sub_start_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 5351 "Parser.c"
    break;

  case 176: /* SUB_HEAD: SUB_START SUB  */
#line 857 "HAL_S.y"
                  { (yyval.sub_head_) = make_ABsub_head((yyvsp[-1].sub_start_), (yyvsp[0].sub_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 5357 "Parser.c"
    break;

  case 177: /* SUB: SUB_EXP  */
#line 859 "HAL_S.y"
              { (yyval.sub_) = make_AAsub((yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5363 "Parser.c"
    break;

  case 178: /* SUB: _SYMB_6  */
#line 860 "HAL_S.y"
            { (yyval.sub_) = make_ABsubStar(); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5369 "Parser.c"
    break;

  case 179: /* SUB: SUB_RUN_HEAD SUB_EXP  */
#line 861 "HAL_S.y"
                         { (yyval.sub_) = make_ACsubExp((yyvsp[-1].sub_run_head_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5375 "Parser.c"
    break;

  case 180: /* SUB: ARITH_EXP _SYMB_42 SUB_EXP  */
#line 862 "HAL_S.y"
                               { (yyval.sub_) = make_ADsubAt((yyvsp[-2].arith_exp_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5381 "Parser.c"
    break;

  case 181: /* SUB_RUN_HEAD: SUB_EXP _SYMB_166  */
#line 864 "HAL_S.y"
                                 { (yyval.sub_run_head_) = make_AAsubRunHeadTo((yyvsp[-1].sub_exp_)); (yyval.sub_run_head_)->line_number = (yyloc).first_line; (yyval.sub_run_head_)->char_number = (yyloc).first_column;  }
#line 5387 "Parser.c"
    break;

  case 182: /* SUB_EXP: ARITH_EXP  */
#line 866 "HAL_S.y"
                    { (yyval.sub_exp_) = make_AAsub_exp((yyvsp[0].arith_exp_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 5393 "Parser.c"
    break;

  case 183: /* SUB_EXP: POUND_EXPRESSION  */
#line 867 "HAL_S.y"
                     { (yyval.sub_exp_) = make_ABsub_exp((yyvsp[0].pound_expression_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 5399 "Parser.c"
    break;

  case 184: /* POUND_EXPRESSION: _SYMB_10  */
#line 869 "HAL_S.y"
                            { (yyval.pound_expression_) = make_AApound_expression(); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5405 "Parser.c"
    break;

  case 185: /* POUND_EXPRESSION: POUND_EXPRESSION PLUS TERM  */
#line 870 "HAL_S.y"
                               { (yyval.pound_expression_) = make_ABpound_expression((yyvsp[-2].pound_expression_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5411 "Parser.c"
    break;

  case 186: /* POUND_EXPRESSION: POUND_EXPRESSION MINUS TERM  */
#line 871 "HAL_S.y"
                                { (yyval.pound_expression_) = make_ACpound_expression((yyvsp[-2].pound_expression_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5417 "Parser.c"
    break;

  case 187: /* BIT_EXP: BIT_FACTOR  */
#line 873 "HAL_S.y"
                     { (yyval.bit_exp_) = make_AAbitExpFactor((yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 5423 "Parser.c"
    break;

  case 188: /* BIT_EXP: BIT_EXP OR BIT_FACTOR  */
#line 874 "HAL_S.y"
                          { (yyval.bit_exp_) = make_ABbitExpOR((yyvsp[-2].bit_exp_), (yyvsp[-1].or_), (yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 5429 "Parser.c"
    break;

  case 189: /* BIT_FACTOR: BIT_CAT  */
#line 876 "HAL_S.y"
                     { (yyval.bit_factor_) = make_AAbitFactor((yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 5435 "Parser.c"
    break;

  case 190: /* BIT_FACTOR: BIT_FACTOR AND BIT_CAT  */
#line 877 "HAL_S.y"
                           { (yyval.bit_factor_) = make_ABbitFactorAnd((yyvsp[-2].bit_factor_), (yyvsp[-1].and_), (yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 5441 "Parser.c"
    break;

  case 191: /* BIT_CAT: BIT_PRIM  */
#line 879 "HAL_S.y"
                   { (yyval.bit_cat_) = make_AAbitCatPrim((yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5447 "Parser.c"
    break;

  case 192: /* BIT_CAT: BIT_CAT CAT BIT_PRIM  */
#line 880 "HAL_S.y"
                         { (yyval.bit_cat_) = make_ABbitCatCat((yyvsp[-2].bit_cat_), (yyvsp[-1].cat_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5453 "Parser.c"
    break;

  case 193: /* BIT_CAT: NOT BIT_PRIM  */
#line 881 "HAL_S.y"
                 { (yyval.bit_cat_) = make_ACbitCatNotPrim((yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5459 "Parser.c"
    break;

  case 194: /* BIT_CAT: BIT_CAT CAT NOT BIT_PRIM  */
#line 882 "HAL_S.y"
                             { (yyval.bit_cat_) = make_ADbitCatNotCat((yyvsp[-3].bit_cat_), (yyvsp[-2].cat_), (yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5465 "Parser.c"
    break;

  case 195: /* OR: CHAR_VERTICAL_BAR  */
#line 884 "HAL_S.y"
                       { (yyval.or_) = make_AAOR((yyvsp[0].char_vertical_bar_)); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5471 "Parser.c"
    break;

  case 196: /* OR: _SYMB_117  */
#line 885 "HAL_S.y"
              { (yyval.or_) = make_ABOR(); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5477 "Parser.c"
    break;

  case 197: /* CHAR_VERTICAL_BAR: _SYMB_19  */
#line 887 "HAL_S.y"
                             { (yyval.char_vertical_bar_) = make_CFchar_vertical_bar(); (yyval.char_vertical_bar_)->line_number = (yyloc).first_line; (yyval.char_vertical_bar_)->char_number = (yyloc).first_column;  }
#line 5483 "Parser.c"
    break;

  case 198: /* AND: _SYMB_20  */
#line 889 "HAL_S.y"
               { (yyval.and_) = make_AAAND(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5489 "Parser.c"
    break;

  case 199: /* AND: _SYMB_32  */
#line 890 "HAL_S.y"
             { (yyval.and_) = make_ABAND(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5495 "Parser.c"
    break;

  case 200: /* BIT_PRIM: BIT_VAR  */
#line 892 "HAL_S.y"
                   { (yyval.bit_prim_) = make_AAbitPrimBitVar((yyvsp[0].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5501 "Parser.c"
    break;

  case 201: /* BIT_PRIM: LABEL_VAR  */
#line 893 "HAL_S.y"
              { (yyval.bit_prim_) = make_ABbitPrimLabelVar((yyvsp[0].label_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5507 "Parser.c"
    break;

  case 202: /* BIT_PRIM: EVENT_VAR  */
#line 894 "HAL_S.y"
              { (yyval.bit_prim_) = make_ACbitPrimEventVar((yyvsp[0].event_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5513 "Parser.c"
    break;

  case 203: /* BIT_PRIM: BIT_CONST  */
#line 895 "HAL_S.y"
              { (yyval.bit_prim_) = make_ADbitBitConst((yyvsp[0].bit_const_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5519 "Parser.c"
    break;

  case 204: /* BIT_PRIM: _SYMB_2 BIT_EXP _SYMB_1  */
#line 896 "HAL_S.y"
                            { (yyval.bit_prim_) = make_AEbitPrimBitExp((yyvsp[-1].bit_exp_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5525 "Parser.c"
    break;

  case 205: /* BIT_PRIM: SUBBIT_HEAD EXPRESSION _SYMB_1  */
#line 897 "HAL_S.y"
                                   { (yyval.bit_prim_) = make_AHbitPrimSubbit((yyvsp[-2].subbit_head_), (yyvsp[-1].expression_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5531 "Parser.c"
    break;

  case 206: /* BIT_PRIM: BIT_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 898 "HAL_S.y"
                                            { (yyval.bit_prim_) = make_AIbitPrimFunc((yyvsp[-3].bit_func_head_), (yyvsp[-1].call_list_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5537 "Parser.c"
    break;

  case 207: /* BIT_PRIM: _SYMB_11 BIT_VAR _SYMB_12  */
#line 899 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBracketed((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5543 "Parser.c"
    break;

  case 208: /* BIT_PRIM: _SYMB_11 BIT_VAR _SYMB_12 SUBSCRIPT  */
#line 900 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBracketed((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5549 "Parser.c"
    break;

  case 209: /* BIT_PRIM: _SYMB_13 BIT_VAR _SYMB_14  */
#line 901 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBraced((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5555 "Parser.c"
    break;

  case 210: /* BIT_PRIM: _SYMB_13 BIT_VAR _SYMB_14 SUBSCRIPT  */
#line 902 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBraced((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5561 "Parser.c"
    break;

  case 211: /* CAT: _SYMB_21  */
#line 904 "HAL_S.y"
               { (yyval.cat_) = make_AAcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5567 "Parser.c"
    break;

  case 212: /* CAT: _SYMB_51  */
#line 905 "HAL_S.y"
             { (yyval.cat_) = make_ABcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5573 "Parser.c"
    break;

  case 213: /* NOT: _SYMB_111  */
#line 907 "HAL_S.y"
                { (yyval.not_) = make_ABNOT(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5579 "Parser.c"
    break;

  case 214: /* NOT: _SYMB_22  */
#line 908 "HAL_S.y"
             { (yyval.not_) = make_ADNOT(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5585 "Parser.c"
    break;

  case 215: /* BIT_VAR: BIT_ID  */
#line 910 "HAL_S.y"
                 { (yyval.bit_var_) = make_AAbit_var((yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5591 "Parser.c"
    break;

  case 216: /* BIT_VAR: BIT_ID SUBSCRIPT  */
#line 911 "HAL_S.y"
                     { (yyval.bit_var_) = make_ACbit_var((yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5597 "Parser.c"
    break;

  case 217: /* BIT_VAR: QUAL_STRUCT _SYMB_7 BIT_ID  */
#line 912 "HAL_S.y"
                               { (yyval.bit_var_) = make_ABbit_var((yyvsp[-2].qual_struct_), (yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5603 "Parser.c"
    break;

  case 218: /* BIT_VAR: QUAL_STRUCT _SYMB_7 BIT_ID SUBSCRIPT  */
#line 913 "HAL_S.y"
                                         { (yyval.bit_var_) = make_ADbit_var((yyvsp[-3].qual_struct_), (yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5609 "Parser.c"
    break;

  case 219: /* LABEL_VAR: LABEL  */
#line 915 "HAL_S.y"
                  { (yyval.label_var_) = make_AAlabel_var((yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5615 "Parser.c"
    break;

  case 220: /* LABEL_VAR: LABEL SUBSCRIPT  */
#line 916 "HAL_S.y"
                    { (yyval.label_var_) = make_ABlabel_var((yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5621 "Parser.c"
    break;

  case 221: /* LABEL_VAR: QUAL_STRUCT _SYMB_7 LABEL  */
#line 917 "HAL_S.y"
                              { (yyval.label_var_) = make_AClabel_var((yyvsp[-2].qual_struct_), (yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5627 "Parser.c"
    break;

  case 222: /* LABEL_VAR: QUAL_STRUCT _SYMB_7 LABEL SUBSCRIPT  */
#line 918 "HAL_S.y"
                                        { (yyval.label_var_) = make_ADlabel_var((yyvsp[-3].qual_struct_), (yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5633 "Parser.c"
    break;

  case 223: /* EVENT_VAR: EVENT  */
#line 920 "HAL_S.y"
                  { (yyval.event_var_) = make_AAevent_var((yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5639 "Parser.c"
    break;

  case 224: /* EVENT_VAR: EVENT SUBSCRIPT  */
#line 921 "HAL_S.y"
                    { (yyval.event_var_) = make_ACevent_var((yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5645 "Parser.c"
    break;

  case 225: /* EVENT_VAR: QUAL_STRUCT _SYMB_7 EVENT  */
#line 922 "HAL_S.y"
                              { (yyval.event_var_) = make_ABevent_var((yyvsp[-2].qual_struct_), (yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5651 "Parser.c"
    break;

  case 226: /* EVENT_VAR: QUAL_STRUCT _SYMB_7 EVENT SUBSCRIPT  */
#line 923 "HAL_S.y"
                                        { (yyval.event_var_) = make_ADevent_var((yyvsp[-3].qual_struct_), (yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5657 "Parser.c"
    break;

  case 227: /* BIT_CONST_HEAD: RADIX  */
#line 925 "HAL_S.y"
                       { (yyval.bit_const_head_) = make_AAbit_const_head((yyvsp[0].radix_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5663 "Parser.c"
    break;

  case 228: /* BIT_CONST_HEAD: RADIX _SYMB_2 NUMBER _SYMB_1  */
#line 926 "HAL_S.y"
                                 { (yyval.bit_const_head_) = make_ABbit_const_head((yyvsp[-3].radix_), (yyvsp[-1].number_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5669 "Parser.c"
    break;

  case 229: /* BIT_CONST: BIT_CONST_HEAD CHAR_STRING  */
#line 928 "HAL_S.y"
                                       { (yyval.bit_const_) = make_AAbitConstString((yyvsp[-1].bit_const_head_), (yyvsp[0].char_string_)); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5675 "Parser.c"
    break;

  case 230: /* BIT_CONST: _SYMB_170  */
#line 929 "HAL_S.y"
              { (yyval.bit_const_) = make_ABbitConstTrue(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5681 "Parser.c"
    break;

  case 231: /* BIT_CONST: _SYMB_83  */
#line 930 "HAL_S.y"
             { (yyval.bit_const_) = make_ACbitConstFalse(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5687 "Parser.c"
    break;

  case 232: /* BIT_CONST: _SYMB_116  */
#line 931 "HAL_S.y"
              { (yyval.bit_const_) = make_ADbitConstOn(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5693 "Parser.c"
    break;

  case 233: /* BIT_CONST: _SYMB_115  */
#line 932 "HAL_S.y"
              { (yyval.bit_const_) = make_AEbitConstOff(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5699 "Parser.c"
    break;

  case 234: /* RADIX: _SYMB_89  */
#line 934 "HAL_S.y"
                 { (yyval.radix_) = make_AAradixHEX(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5705 "Parser.c"
    break;

  case 235: /* RADIX: _SYMB_113  */
#line 935 "HAL_S.y"
              { (yyval.radix_) = make_ABradixOCT(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5711 "Parser.c"
    break;

  case 236: /* RADIX: _SYMB_44  */
#line 936 "HAL_S.y"
             { (yyval.radix_) = make_ACradixBIN(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5717 "Parser.c"
    break;

  case 237: /* RADIX: _SYMB_63  */
#line 937 "HAL_S.y"
             { (yyval.radix_) = make_ADradixDEC(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5723 "Parser.c"
    break;

  case 238: /* CHAR_STRING: _SYMB_193  */
#line 939 "HAL_S.y"
                        { (yyval.char_string_) = make_FPchar_string((yyvsp[0].string_)); (yyval.char_string_)->line_number = (yyloc).first_line; (yyval.char_string_)->char_number = (yyloc).first_column;  }
#line 5729 "Parser.c"
    break;

  case 239: /* SUBBIT_HEAD: SUBBIT_KEY _SYMB_2  */
#line 941 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_AAsubbit_head((yyvsp[-1].subbit_key_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5735 "Parser.c"
    break;

  case 240: /* SUBBIT_HEAD: SUBBIT_KEY SUBSCRIPT _SYMB_2  */
#line 942 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_ABsubbit_head((yyvsp[-2].subbit_key_), (yyvsp[-1].subscript_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5741 "Parser.c"
    break;

  case 241: /* SUBBIT_KEY: _SYMB_156  */
#line 944 "HAL_S.y"
                       { (yyval.subbit_key_) = make_AAsubbit_key(); (yyval.subbit_key_)->line_number = (yyloc).first_line; (yyval.subbit_key_)->char_number = (yyloc).first_column;  }
#line 5747 "Parser.c"
    break;

  case 242: /* BIT_FUNC_HEAD: BIT_FUNC  */
#line 946 "HAL_S.y"
                         { (yyval.bit_func_head_) = make_AAbit_func_head((yyvsp[0].bit_func_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5753 "Parser.c"
    break;

  case 243: /* BIT_FUNC_HEAD: _SYMB_45  */
#line 947 "HAL_S.y"
             { (yyval.bit_func_head_) = make_ABbit_func_head(); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5759 "Parser.c"
    break;

  case 244: /* BIT_FUNC_HEAD: _SYMB_45 SUB_OR_QUALIFIER  */
#line 948 "HAL_S.y"
                              { (yyval.bit_func_head_) = make_ACbit_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5765 "Parser.c"
    break;

  case 245: /* BIT_ID: _SYMB_183  */
#line 950 "HAL_S.y"
                   { (yyval.bit_id_) = make_FHbit_id((yyvsp[0].string_)); (yyval.bit_id_)->line_number = (yyloc).first_line; (yyval.bit_id_)->char_number = (yyloc).first_column;  }
#line 5771 "Parser.c"
    break;

  case 246: /* LABEL: _SYMB_189  */
#line 952 "HAL_S.y"
                  { (yyval.label_) = make_FKlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5777 "Parser.c"
    break;

  case 247: /* LABEL: _SYMB_184  */
#line 953 "HAL_S.y"
              { (yyval.label_) = make_FLlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5783 "Parser.c"
    break;

  case 248: /* LABEL: _SYMB_185  */
#line 954 "HAL_S.y"
              { (yyval.label_) = make_FMlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5789 "Parser.c"
    break;

  case 249: /* LABEL: _SYMB_188  */
#line 955 "HAL_S.y"
              { (yyval.label_) = make_FNlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5795 "Parser.c"
    break;

  case 250: /* BIT_FUNC: _SYMB_179  */
#line 957 "HAL_S.y"
                     { (yyval.bit_func_) = make_ZZxor(); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5801 "Parser.c"
    break;

  case 251: /* BIT_FUNC: _SYMB_184  */
#line 958 "HAL_S.y"
              { (yyval.bit_func_) = make_ZZuserBitFunction((yyvsp[0].string_)); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5807 "Parser.c"
    break;

  case 252: /* EVENT: _SYMB_190  */
#line 960 "HAL_S.y"
                  { (yyval.event_) = make_FLevent((yyvsp[0].string_)); (yyval.event_)->line_number = (yyloc).first_line; (yyval.event_)->char_number = (yyloc).first_column;  }
#line 5813 "Parser.c"
    break;

  case 253: /* SUB_OR_QUALIFIER: SUBSCRIPT  */
#line 962 "HAL_S.y"
                             { (yyval.sub_or_qualifier_) = make_AAsub_or_qualifier((yyvsp[0].subscript_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 5819 "Parser.c"
    break;

  case 254: /* SUB_OR_QUALIFIER: BIT_QUALIFIER  */
#line 963 "HAL_S.y"
                  { (yyval.sub_or_qualifier_) = make_ABsub_or_qualifier((yyvsp[0].bit_qualifier_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 5825 "Parser.c"
    break;

  case 255: /* BIT_QUALIFIER: _SYMB_23 _SYMB_15 _SYMB_2 _SYMB_16 RADIX _SYMB_1  */
#line 965 "HAL_S.y"
                                                                 { (yyval.bit_qualifier_) = make_AAbit_qualifier((yyvsp[-1].radix_)); (yyval.bit_qualifier_)->line_number = (yyloc).first_line; (yyval.bit_qualifier_)->char_number = (yyloc).first_column;  }
#line 5831 "Parser.c"
    break;

  case 256: /* CHAR_EXP: CHAR_PRIM  */
#line 967 "HAL_S.y"
                     { (yyval.char_exp_) = make_AAcharExpPrim((yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5837 "Parser.c"
    break;

  case 257: /* CHAR_EXP: CHAR_EXP CAT CHAR_PRIM  */
#line 968 "HAL_S.y"
                           { (yyval.char_exp_) = make_ABcharExpCat((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5843 "Parser.c"
    break;

  case 258: /* CHAR_EXP: CHAR_EXP CAT ARITH_EXP  */
#line 969 "HAL_S.y"
                           { (yyval.char_exp_) = make_ACcharExpCat((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5849 "Parser.c"
    break;

  case 259: /* CHAR_EXP: ARITH_EXP CAT ARITH_EXP  */
#line 970 "HAL_S.y"
                            { (yyval.char_exp_) = make_ADcharExpCat((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5855 "Parser.c"
    break;

  case 260: /* CHAR_EXP: ARITH_EXP CAT CHAR_PRIM  */
#line 971 "HAL_S.y"
                            { (yyval.char_exp_) = make_AEcharExpCat((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5861 "Parser.c"
    break;

  case 261: /* CHAR_PRIM: CHAR_VAR  */
#line 973 "HAL_S.y"
                     { (yyval.char_prim_) = make_AAchar_prim((yyvsp[0].char_var_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5867 "Parser.c"
    break;

  case 262: /* CHAR_PRIM: CHAR_CONST  */
#line 974 "HAL_S.y"
               { (yyval.char_prim_) = make_ABchar_prim((yyvsp[0].char_const_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5873 "Parser.c"
    break;

  case 263: /* CHAR_PRIM: CHAR_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 975 "HAL_S.y"
                                             { (yyval.char_prim_) = make_AEchar_prim((yyvsp[-3].char_func_head_), (yyvsp[-1].call_list_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5879 "Parser.c"
    break;

  case 264: /* CHAR_PRIM: _SYMB_2 CHAR_EXP _SYMB_1  */
#line 976 "HAL_S.y"
                             { (yyval.char_prim_) = make_AFchar_prim((yyvsp[-1].char_exp_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5885 "Parser.c"
    break;

  case 265: /* CHAR_FUNC_HEAD: CHAR_FUNC  */
#line 978 "HAL_S.y"
                           { (yyval.char_func_head_) = make_AAchar_func_head((yyvsp[0].char_func_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 5891 "Parser.c"
    break;

  case 266: /* CHAR_FUNC_HEAD: _SYMB_54 SUB_OR_QUALIFIER  */
#line 979 "HAL_S.y"
                              { (yyval.char_func_head_) = make_ABchar_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 5897 "Parser.c"
    break;

  case 267: /* CHAR_VAR: CHAR_ID  */
#line 981 "HAL_S.y"
                   { (yyval.char_var_) = make_AAchar_var((yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5903 "Parser.c"
    break;

  case 268: /* CHAR_VAR: CHAR_ID SUBSCRIPT  */
#line 982 "HAL_S.y"
                      { (yyval.char_var_) = make_ACchar_var((yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5909 "Parser.c"
    break;

  case 269: /* CHAR_VAR: QUAL_STRUCT _SYMB_7 CHAR_ID  */
#line 983 "HAL_S.y"
                                { (yyval.char_var_) = make_ABchar_var((yyvsp[-2].qual_struct_), (yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5915 "Parser.c"
    break;

  case 270: /* CHAR_VAR: QUAL_STRUCT _SYMB_7 CHAR_ID SUBSCRIPT  */
#line 984 "HAL_S.y"
                                          { (yyval.char_var_) = make_ADchar_var((yyvsp[-3].qual_struct_), (yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5921 "Parser.c"
    break;

  case 271: /* CHAR_CONST: CHAR_STRING  */
#line 986 "HAL_S.y"
                         { (yyval.char_const_) = make_AAchar_const((yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 5927 "Parser.c"
    break;

  case 272: /* CHAR_CONST: _SYMB_53 _SYMB_2 NUMBER _SYMB_1 CHAR_STRING  */
#line 987 "HAL_S.y"
                                                { (yyval.char_const_) = make_ABchar_const((yyvsp[-2].number_), (yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 5933 "Parser.c"
    break;

  case 273: /* CHAR_FUNC: _SYMB_100  */
#line 989 "HAL_S.y"
                      { (yyval.char_func_) = make_ZZljust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5939 "Parser.c"
    break;

  case 274: /* CHAR_FUNC: _SYMB_136  */
#line 990 "HAL_S.y"
              { (yyval.char_func_) = make_ZZrjust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5945 "Parser.c"
    break;

  case 275: /* CHAR_FUNC: _SYMB_169  */
#line 991 "HAL_S.y"
              { (yyval.char_func_) = make_ZZtrim(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5951 "Parser.c"
    break;

  case 276: /* CHAR_FUNC: _SYMB_185  */
#line 992 "HAL_S.y"
              { (yyval.char_func_) = make_ZZuserCharFunction((yyvsp[0].string_)); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5957 "Parser.c"
    break;

  case 277: /* CHAR_FUNC: _SYMB_54  */
#line 993 "HAL_S.y"
             { (yyval.char_func_) = make_AAcharFuncCharacter(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5963 "Parser.c"
    break;

  case 278: /* CHAR_ID: _SYMB_186  */
#line 995 "HAL_S.y"
                    { (yyval.char_id_) = make_FIchar_id((yyvsp[0].string_)); (yyval.char_id_)->line_number = (yyloc).first_line; (yyval.char_id_)->char_number = (yyloc).first_column;  }
#line 5969 "Parser.c"
    break;

  case 279: /* NAME_EXP: NAME_KEY _SYMB_2 NAME_VAR _SYMB_1  */
#line 997 "HAL_S.y"
                                             { (yyval.name_exp_) = make_AAnameExpKeyVar((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5975 "Parser.c"
    break;

  case 280: /* NAME_EXP: _SYMB_112  */
#line 998 "HAL_S.y"
              { (yyval.name_exp_) = make_ABnameExpNull(); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5981 "Parser.c"
    break;

  case 281: /* NAME_EXP: NAME_KEY _SYMB_2 _SYMB_112 _SYMB_1  */
#line 999 "HAL_S.y"
                                       { (yyval.name_exp_) = make_ACnameExpKeyNull((yyvsp[-3].name_key_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5987 "Parser.c"
    break;

  case 282: /* NAME_KEY: _SYMB_108  */
#line 1001 "HAL_S.y"
                     { (yyval.name_key_) = make_AAname_key(); (yyval.name_key_)->line_number = (yyloc).first_line; (yyval.name_key_)->char_number = (yyloc).first_column;  }
#line 5993 "Parser.c"
    break;

  case 283: /* NAME_VAR: VARIABLE  */
#line 1003 "HAL_S.y"
                    { (yyval.name_var_) = make_AAname_var((yyvsp[0].variable_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5999 "Parser.c"
    break;

  case 284: /* NAME_VAR: MODIFIED_ARITH_FUNC  */
#line 1004 "HAL_S.y"
                        { (yyval.name_var_) = make_ACname_var((yyvsp[0].modified_arith_func_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 6005 "Parser.c"
    break;

  case 285: /* NAME_VAR: LABEL_VAR  */
#line 1005 "HAL_S.y"
              { (yyval.name_var_) = make_ABname_var((yyvsp[0].label_var_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 6011 "Parser.c"
    break;

  case 286: /* VARIABLE: ARITH_VAR  */
#line 1007 "HAL_S.y"
                     { (yyval.variable_) = make_AAvariable((yyvsp[0].arith_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6017 "Parser.c"
    break;

  case 287: /* VARIABLE: BIT_VAR  */
#line 1008 "HAL_S.y"
            { (yyval.variable_) = make_ACvariable((yyvsp[0].bit_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6023 "Parser.c"
    break;

  case 288: /* VARIABLE: SUBBIT_HEAD VARIABLE _SYMB_1  */
#line 1009 "HAL_S.y"
                                 { (yyval.variable_) = make_AEvariable((yyvsp[-2].subbit_head_), (yyvsp[-1].variable_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6029 "Parser.c"
    break;

  case 289: /* VARIABLE: CHAR_VAR  */
#line 1010 "HAL_S.y"
             { (yyval.variable_) = make_AFvariable((yyvsp[0].char_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6035 "Parser.c"
    break;

  case 290: /* VARIABLE: NAME_KEY _SYMB_2 NAME_VAR _SYMB_1  */
#line 1011 "HAL_S.y"
                                      { (yyval.variable_) = make_AGvariable((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6041 "Parser.c"
    break;

  case 291: /* VARIABLE: EVENT_VAR  */
#line 1012 "HAL_S.y"
              { (yyval.variable_) = make_ADvariable((yyvsp[0].event_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6047 "Parser.c"
    break;

  case 292: /* VARIABLE: STRUCTURE_VAR  */
#line 1013 "HAL_S.y"
                  { (yyval.variable_) = make_ABvariable((yyvsp[0].structure_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6053 "Parser.c"
    break;

  case 293: /* STRUCTURE_EXP: STRUCTURE_VAR  */
#line 1015 "HAL_S.y"
                              { (yyval.structure_exp_) = make_AAstructure_exp((yyvsp[0].structure_var_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 6059 "Parser.c"
    break;

  case 294: /* STRUCTURE_EXP: STRUCT_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 1016 "HAL_S.y"
                                               { (yyval.structure_exp_) = make_ADstructure_exp((yyvsp[-3].struct_func_head_), (yyvsp[-1].call_list_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 6065 "Parser.c"
    break;

  case 295: /* STRUCTURE_EXP: STRUC_INLINE_DEF CLOSING _SYMB_17  */
#line 1017 "HAL_S.y"
                                      { (yyval.structure_exp_) = make_ACstructure_exp((yyvsp[-2].struc_inline_def_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 6071 "Parser.c"
    break;

  case 296: /* STRUCTURE_EXP: STRUC_INLINE_DEF BLOCK_BODY CLOSING _SYMB_17  */
#line 1018 "HAL_S.y"
                                                 { (yyval.structure_exp_) = make_AEstructure_exp((yyvsp[-3].struc_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 6077 "Parser.c"
    break;

  case 297: /* STRUCT_FUNC_HEAD: STRUCT_FUNC  */
#line 1020 "HAL_S.y"
                               { (yyval.struct_func_head_) = make_AAstruct_func_head((yyvsp[0].struct_func_)); (yyval.struct_func_head_)->line_number = (yyloc).first_line; (yyval.struct_func_head_)->char_number = (yyloc).first_column;  }
#line 6083 "Parser.c"
    break;

  case 298: /* STRUCTURE_VAR: QUAL_STRUCT SUBSCRIPT  */
#line 1022 "HAL_S.y"
                                      { (yyval.structure_var_) = make_AAstructure_var((yyvsp[-1].qual_struct_), (yyvsp[0].subscript_)); (yyval.structure_var_)->line_number = (yyloc).first_line; (yyval.structure_var_)->char_number = (yyloc).first_column;  }
#line 6089 "Parser.c"
    break;

  case 299: /* STRUCT_FUNC: _SYMB_188  */
#line 1024 "HAL_S.y"
                        { (yyval.struct_func_) = make_ZZuserStructFunc((yyvsp[0].string_)); (yyval.struct_func_)->line_number = (yyloc).first_line; (yyval.struct_func_)->char_number = (yyloc).first_column;  }
#line 6095 "Parser.c"
    break;

  case 300: /* QUAL_STRUCT: STRUCTURE_ID  */
#line 1026 "HAL_S.y"
                           { (yyval.qual_struct_) = make_AAqual_struct((yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 6101 "Parser.c"
    break;

  case 301: /* QUAL_STRUCT: QUAL_STRUCT _SYMB_7 STRUCTURE_ID  */
#line 1027 "HAL_S.y"
                                     { (yyval.qual_struct_) = make_ABqual_struct((yyvsp[-2].qual_struct_), (yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 6107 "Parser.c"
    break;

  case 302: /* STRUCTURE_ID: _SYMB_187  */
#line 1029 "HAL_S.y"
                         { (yyval.structure_id_) = make_FJstructure_id((yyvsp[0].string_)); (yyval.structure_id_)->line_number = (yyloc).first_line; (yyval.structure_id_)->char_number = (yyloc).first_column;  }
#line 6113 "Parser.c"
    break;

  case 303: /* ASSIGNMENT: VARIABLE EQUALS EXPRESSION  */
#line 1031 "HAL_S.y"
                                        { (yyval.assignment_) = make_AAassignment((yyvsp[-2].variable_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6119 "Parser.c"
    break;

  case 304: /* ASSIGNMENT: VARIABLE _SYMB_0 ASSIGNMENT  */
#line 1032 "HAL_S.y"
                                { (yyval.assignment_) = make_ABassignment((yyvsp[-2].variable_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6125 "Parser.c"
    break;

  case 305: /* ASSIGNMENT: QUAL_STRUCT EQUALS EXPRESSION  */
#line 1033 "HAL_S.y"
                                  { (yyval.assignment_) = make_ACassignment((yyvsp[-2].qual_struct_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6131 "Parser.c"
    break;

  case 306: /* ASSIGNMENT: QUAL_STRUCT _SYMB_0 ASSIGNMENT  */
#line 1034 "HAL_S.y"
                                   { (yyval.assignment_) = make_ADassignment((yyvsp[-2].qual_struct_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6137 "Parser.c"
    break;

  case 307: /* EQUALS: _SYMB_24  */
#line 1036 "HAL_S.y"
                  { (yyval.equals_) = make_AAequals(); (yyval.equals_)->line_number = (yyloc).first_line; (yyval.equals_)->char_number = (yyloc).first_column;  }
#line 6143 "Parser.c"
    break;

  case 308: /* STATEMENT: BASIC_STATEMENT  */
#line 1038 "HAL_S.y"
                            { (yyval.statement_) = make_AAstatement((yyvsp[0].basic_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6149 "Parser.c"
    break;

  case 309: /* STATEMENT: OTHER_STATEMENT  */
#line 1039 "HAL_S.y"
                    { (yyval.statement_) = make_ABstatement((yyvsp[0].other_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6155 "Parser.c"
    break;

  case 310: /* STATEMENT: INLINE_DEFINITION  */
#line 1040 "HAL_S.y"
                      { (yyval.statement_) = make_AZstatement((yyvsp[0].inline_definition_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6161 "Parser.c"
    break;

  case 311: /* BASIC_STATEMENT: ASSIGNMENT _SYMB_17  */
#line 1042 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_ABbasicStatementAssignment((yyvsp[-1].assignment_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6167 "Parser.c"
    break;

  case 312: /* BASIC_STATEMENT: LABEL_DEFINITION BASIC_STATEMENT  */
#line 1043 "HAL_S.y"
                                     { (yyval.basic_statement_) = make_AAbasic_statement((yyvsp[-1].label_definition_), (yyvsp[0].basic_statement_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6173 "Parser.c"
    break;

  case 313: /* BASIC_STATEMENT: _SYMB_80 _SYMB_17  */
#line 1044 "HAL_S.y"
                      { (yyval.basic_statement_) = make_ACbasicStatementExit(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6179 "Parser.c"
    break;

  case 314: /* BASIC_STATEMENT: _SYMB_80 LABEL _SYMB_17  */
#line 1045 "HAL_S.y"
                            { (yyval.basic_statement_) = make_ADbasicStatementExit((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6185 "Parser.c"
    break;

  case 315: /* BASIC_STATEMENT: _SYMB_131 _SYMB_17  */
#line 1046 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AEbasicStatementRepeat(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6191 "Parser.c"
    break;

  case 316: /* BASIC_STATEMENT: _SYMB_131 LABEL _SYMB_17  */
#line 1047 "HAL_S.y"
                             { (yyval.basic_statement_) = make_AFbasicStatementRepeat((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6197 "Parser.c"
    break;

  case 317: /* BASIC_STATEMENT: _SYMB_88 _SYMB_166 LABEL _SYMB_17  */
#line 1048 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AGbasicStatementGoTo((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6203 "Parser.c"
    break;

  case 318: /* BASIC_STATEMENT: _SYMB_17  */
#line 1049 "HAL_S.y"
             { (yyval.basic_statement_) = make_AHbasicStatementEmpty(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6209 "Parser.c"
    break;

  case 319: /* BASIC_STATEMENT: CALL_KEY _SYMB_17  */
#line 1050 "HAL_S.y"
                      { (yyval.basic_statement_) = make_AIbasicStatementCall((yyvsp[-1].call_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6215 "Parser.c"
    break;

  case 320: /* BASIC_STATEMENT: CALL_KEY _SYMB_2 CALL_LIST _SYMB_1 _SYMB_17  */
#line 1051 "HAL_S.y"
                                                { (yyval.basic_statement_) = make_AJbasicStatementCall((yyvsp[-4].call_key_), (yyvsp[-2].call_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6221 "Parser.c"
    break;

  case 321: /* BASIC_STATEMENT: CALL_KEY ASSIGN _SYMB_2 CALL_ASSIGN_LIST _SYMB_1 _SYMB_17  */
#line 1052 "HAL_S.y"
                                                              { (yyval.basic_statement_) = make_AKbasicStatementCall((yyvsp[-5].call_key_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6227 "Parser.c"
    break;

  case 322: /* BASIC_STATEMENT: CALL_KEY _SYMB_2 CALL_LIST _SYMB_1 ASSIGN _SYMB_2 CALL_ASSIGN_LIST _SYMB_1 _SYMB_17  */
#line 1053 "HAL_S.y"
                                                                                        { (yyval.basic_statement_) = make_ALbasicStatementCall((yyvsp[-8].call_key_), (yyvsp[-6].call_list_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6233 "Parser.c"
    break;

  case 323: /* BASIC_STATEMENT: _SYMB_134 _SYMB_17  */
#line 1054 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AMbasicStatementReturn(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6239 "Parser.c"
    break;

  case 324: /* BASIC_STATEMENT: _SYMB_134 EXPRESSION _SYMB_17  */
#line 1055 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_ANbasicStatementReturn((yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6245 "Parser.c"
    break;

  case 325: /* BASIC_STATEMENT: DO_GROUP_HEAD ENDING _SYMB_17  */
#line 1056 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_AObasicStatementDo((yyvsp[-2].do_group_head_), (yyvsp[-1].ending_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6251 "Parser.c"
    break;

  case 326: /* BASIC_STATEMENT: READ_KEY _SYMB_17  */
#line 1057 "HAL_S.y"
                      { (yyval.basic_statement_) = make_APbasicStatementReadKey((yyvsp[-1].read_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6257 "Parser.c"
    break;

  case 327: /* BASIC_STATEMENT: READ_PHRASE _SYMB_17  */
#line 1058 "HAL_S.y"
                         { (yyval.basic_statement_) = make_AQbasicStatementReadPhrase((yyvsp[-1].read_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6263 "Parser.c"
    break;

  case 328: /* BASIC_STATEMENT: WRITE_KEY _SYMB_17  */
#line 1059 "HAL_S.y"
                       { (yyval.basic_statement_) = make_ARbasicStatementWriteKey((yyvsp[-1].write_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6269 "Parser.c"
    break;

  case 329: /* BASIC_STATEMENT: WRITE_PHRASE _SYMB_17  */
#line 1060 "HAL_S.y"
                          { (yyval.basic_statement_) = make_ASbasicStatementWritePhrase((yyvsp[-1].write_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6275 "Parser.c"
    break;

  case 330: /* BASIC_STATEMENT: FILE_EXP EQUALS EXPRESSION _SYMB_17  */
#line 1061 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_ATbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6281 "Parser.c"
    break;

  case 331: /* BASIC_STATEMENT: VARIABLE EQUALS FILE_EXP _SYMB_17  */
#line 1062 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AUbasicStatementFileExp((yyvsp[-3].variable_), (yyvsp[-2].equals_), (yyvsp[-1].file_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6287 "Parser.c"
    break;

  case 332: /* BASIC_STATEMENT: FILE_EXP EQUALS QUAL_STRUCT _SYMB_17  */
#line 1063 "HAL_S.y"
                                         { (yyval.basic_statement_) = make_AVbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].qual_struct_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6293 "Parser.c"
    break;

  case 333: /* BASIC_STATEMENT: WAIT_KEY _SYMB_86 _SYMB_66 _SYMB_17  */
#line 1064 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_AVbasicStatementWait((yyvsp[-3].wait_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6299 "Parser.c"
    break;

  case 334: /* BASIC_STATEMENT: WAIT_KEY ARITH_EXP _SYMB_17  */
#line 1065 "HAL_S.y"
                                { (yyval.basic_statement_) = make_AWbasicStatementWait((yyvsp[-2].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6305 "Parser.c"
    break;

  case 335: /* BASIC_STATEMENT: WAIT_KEY _SYMB_173 ARITH_EXP _SYMB_17  */
#line 1066 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_AXbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6311 "Parser.c"
    break;

  case 336: /* BASIC_STATEMENT: WAIT_KEY _SYMB_86 BIT_EXP _SYMB_17  */
#line 1067 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_AYbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].bit_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6317 "Parser.c"
    break;

  case 337: /* BASIC_STATEMENT: TERMINATOR _SYMB_17  */
#line 1068 "HAL_S.y"
                        { (yyval.basic_statement_) = make_AZbasicStatementTerminator((yyvsp[-1].terminator_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6323 "Parser.c"
    break;

  case 338: /* BASIC_STATEMENT: TERMINATOR TERMINATE_LIST _SYMB_17  */
#line 1069 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_BAbasicStatementTerminator((yyvsp[-2].terminator_), (yyvsp[-1].terminate_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6329 "Parser.c"
    break;

  case 339: /* BASIC_STATEMENT: _SYMB_174 _SYMB_120 _SYMB_166 ARITH_EXP _SYMB_17  */
#line 1070 "HAL_S.y"
                                                     { (yyval.basic_statement_) = make_BBbasicStatementUpdate((yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6335 "Parser.c"
    break;

  case 340: /* BASIC_STATEMENT: _SYMB_174 _SYMB_120 LABEL_VAR _SYMB_166 ARITH_EXP _SYMB_17  */
#line 1071 "HAL_S.y"
                                                               { (yyval.basic_statement_) = make_BCbasicStatementUpdate((yyvsp[-3].label_var_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6341 "Parser.c"
    break;

  case 341: /* BASIC_STATEMENT: SCHEDULE_PHRASE _SYMB_17  */
#line 1072 "HAL_S.y"
                             { (yyval.basic_statement_) = make_BDbasicStatementSchedule((yyvsp[-1].schedule_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6347 "Parser.c"
    break;

  case 342: /* BASIC_STATEMENT: SCHEDULE_PHRASE SCHEDULE_CONTROL _SYMB_17  */
#line 1073 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BEbasicStatementSchedule((yyvsp[-2].schedule_phrase_), (yyvsp[-1].schedule_control_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6353 "Parser.c"
    break;

  case 343: /* BASIC_STATEMENT: SIGNAL_CLAUSE _SYMB_17  */
#line 1074 "HAL_S.y"
                           { (yyval.basic_statement_) = make_BFbasicStatementSignal((yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6359 "Parser.c"
    break;

  case 344: /* BASIC_STATEMENT: _SYMB_141 _SYMB_76 SUBSCRIPT _SYMB_17  */
#line 1075 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BGbasicStatementSend((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6365 "Parser.c"
    break;

  case 345: /* BASIC_STATEMENT: _SYMB_141 _SYMB_76 _SYMB_17  */
#line 1076 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BHbasicStatementSend(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6371 "Parser.c"
    break;

  case 346: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_17  */
#line 1077 "HAL_S.y"
                       { (yyval.basic_statement_) = make_BHbasicStatementOn((yyvsp[-1].on_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6377 "Parser.c"
    break;

  case 347: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_32 SIGNAL_CLAUSE _SYMB_17  */
#line 1078 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BIbasicStatementOnAndSignal((yyvsp[-3].on_clause_), (yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6383 "Parser.c"
    break;

  case 348: /* BASIC_STATEMENT: _SYMB_115 _SYMB_76 SUBSCRIPT _SYMB_17  */
#line 1079 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BJbasicStatementOff((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6389 "Parser.c"
    break;

  case 349: /* BASIC_STATEMENT: _SYMB_115 _SYMB_76 _SYMB_17  */
#line 1080 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementOff(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6395 "Parser.c"
    break;

  case 350: /* BASIC_STATEMENT: PERCENT_MACRO_NAME _SYMB_17  */
#line 1081 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementPercentMacro((yyvsp[-1].percent_macro_name_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6401 "Parser.c"
    break;

  case 351: /* BASIC_STATEMENT: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_1 _SYMB_17  */
#line 1082 "HAL_S.y"
                                                          { (yyval.basic_statement_) = make_BLbasicStatementPercentMacro((yyvsp[-3].percent_macro_head_), (yyvsp[-2].percent_macro_arg_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6407 "Parser.c"
    break;

  case 352: /* OTHER_STATEMENT: IF_STATEMENT  */
#line 1084 "HAL_S.y"
                               { (yyval.other_statement_) = make_ABotherStatementIf((yyvsp[0].if_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6413 "Parser.c"
    break;

  case 353: /* OTHER_STATEMENT: ON_PHRASE STATEMENT  */
#line 1085 "HAL_S.y"
                        { (yyval.other_statement_) = make_AAotherStatementOn((yyvsp[-1].on_phrase_), (yyvsp[0].statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6419 "Parser.c"
    break;

  case 354: /* OTHER_STATEMENT: LABEL_DEFINITION OTHER_STATEMENT  */
#line 1086 "HAL_S.y"
                                     { (yyval.other_statement_) = make_ACother_statement((yyvsp[-1].label_definition_), (yyvsp[0].other_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6425 "Parser.c"
    break;

  case 355: /* IF_STATEMENT: IF_CLAUSE STATEMENT  */
#line 1088 "HAL_S.y"
                                   { (yyval.if_statement_) = make_AAifStatement((yyvsp[-1].if_clause_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 6431 "Parser.c"
    break;

  case 356: /* IF_STATEMENT: TRUE_PART STATEMENT  */
#line 1089 "HAL_S.y"
                        { (yyval.if_statement_) = make_ABifThenElseStatement((yyvsp[-1].true_part_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 6437 "Parser.c"
    break;

  case 357: /* IF_CLAUSE: IF RELATIONAL_EXP THEN  */
#line 1091 "HAL_S.y"
                                   { (yyval.if_clause_) = make_AAifClauseRelationalExp((yyvsp[-2].if_), (yyvsp[-1].relational_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 6443 "Parser.c"
    break;

  case 358: /* IF_CLAUSE: IF BIT_EXP THEN  */
#line 1092 "HAL_S.y"
                    { (yyval.if_clause_) = make_ABifClauseBitExp((yyvsp[-2].if_), (yyvsp[-1].bit_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 6449 "Parser.c"
    break;

  case 359: /* TRUE_PART: IF_CLAUSE BASIC_STATEMENT _SYMB_71  */
#line 1094 "HAL_S.y"
                                               { (yyval.true_part_) = make_AAtrue_part((yyvsp[-2].if_clause_), (yyvsp[-1].basic_statement_)); (yyval.true_part_)->line_number = (yyloc).first_line; (yyval.true_part_)->char_number = (yyloc).first_column;  }
#line 6455 "Parser.c"
    break;

  case 360: /* IF: _SYMB_90  */
#line 1096 "HAL_S.y"
              { (yyval.if_) = make_AAif(); (yyval.if_)->line_number = (yyloc).first_line; (yyval.if_)->char_number = (yyloc).first_column;  }
#line 6461 "Parser.c"
    break;

  case 361: /* THEN: _SYMB_165  */
#line 1098 "HAL_S.y"
                 { (yyval.then_) = make_AAthen(); (yyval.then_)->line_number = (yyloc).first_line; (yyval.then_)->char_number = (yyloc).first_column;  }
#line 6467 "Parser.c"
    break;

  case 362: /* RELATIONAL_EXP: RELATIONAL_FACTOR  */
#line 1100 "HAL_S.y"
                                   { (yyval.relational_exp_) = make_AArelational_exp((yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 6473 "Parser.c"
    break;

  case 363: /* RELATIONAL_EXP: RELATIONAL_EXP OR RELATIONAL_FACTOR  */
#line 1101 "HAL_S.y"
                                        { (yyval.relational_exp_) = make_ABrelational_expOR((yyvsp[-2].relational_exp_), (yyvsp[-1].or_), (yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 6479 "Parser.c"
    break;

  case 364: /* RELATIONAL_FACTOR: REL_PRIM  */
#line 1103 "HAL_S.y"
                             { (yyval.relational_factor_) = make_AArelational_factor((yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 6485 "Parser.c"
    break;

  case 365: /* RELATIONAL_FACTOR: RELATIONAL_FACTOR AND REL_PRIM  */
#line 1104 "HAL_S.y"
                                   { (yyval.relational_factor_) = make_ABrelational_factorAND((yyvsp[-2].relational_factor_), (yyvsp[-1].and_), (yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 6491 "Parser.c"
    break;

  case 366: /* REL_PRIM: _SYMB_2 RELATIONAL_EXP _SYMB_1  */
#line 1106 "HAL_S.y"
                                          { (yyval.rel_prim_) = make_AArel_prim((yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6497 "Parser.c"
    break;

  case 367: /* REL_PRIM: NOT _SYMB_2 RELATIONAL_EXP _SYMB_1  */
#line 1107 "HAL_S.y"
                                       { (yyval.rel_prim_) = make_ABrel_prim((yyvsp[-3].not_), (yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6503 "Parser.c"
    break;

  case 368: /* REL_PRIM: COMPARISON  */
#line 1108 "HAL_S.y"
               { (yyval.rel_prim_) = make_ACrel_prim((yyvsp[0].comparison_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6509 "Parser.c"
    break;

  case 369: /* COMPARISON: ARITH_EXP EQUALS ARITH_EXP  */
#line 1110 "HAL_S.y"
                                        { (yyval.comparison_) = make_AAcomparisonEQ((yyvsp[-2].arith_exp_), (yyvsp[-1].equals_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6515 "Parser.c"
    break;

  case 370: /* COMPARISON: CHAR_EXP EQUALS CHAR_EXP  */
#line 1111 "HAL_S.y"
                             { (yyval.comparison_) = make_ABcomparisonEQ((yyvsp[-2].char_exp_), (yyvsp[-1].equals_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6521 "Parser.c"
    break;

  case 371: /* COMPARISON: BIT_CAT EQUALS BIT_CAT  */
#line 1112 "HAL_S.y"
                           { (yyval.comparison_) = make_ACcomparisonEQ((yyvsp[-2].bit_cat_), (yyvsp[-1].equals_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6527 "Parser.c"
    break;

  case 372: /* COMPARISON: STRUCTURE_EXP EQUALS STRUCTURE_EXP  */
#line 1113 "HAL_S.y"
                                       { (yyval.comparison_) = make_ADcomparisonEQ((yyvsp[-2].structure_exp_), (yyvsp[-1].equals_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6533 "Parser.c"
    break;

  case 373: /* COMPARISON: NAME_EXP EQUALS NAME_EXP  */
#line 1114 "HAL_S.y"
                             { (yyval.comparison_) = make_AEcomparisonEQ((yyvsp[-2].name_exp_), (yyvsp[-1].equals_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6539 "Parser.c"
    break;

  case 374: /* COMPARISON: ARITH_EXP _SYMB_180 ARITH_EXP  */
#line 1115 "HAL_S.y"
                                  { (yyval.comparison_) = make_AAcomparisonNEQ((yyvsp[-2].arith_exp_), (yyvsp[-1].string_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6545 "Parser.c"
    break;

  case 375: /* COMPARISON: CHAR_EXP _SYMB_180 CHAR_EXP  */
#line 1116 "HAL_S.y"
                                { (yyval.comparison_) = make_ABcomparisonNEQ((yyvsp[-2].char_exp_), (yyvsp[-1].string_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6551 "Parser.c"
    break;

  case 376: /* COMPARISON: BIT_CAT _SYMB_180 BIT_CAT  */
#line 1117 "HAL_S.y"
                              { (yyval.comparison_) = make_ACcomparisonNEQ((yyvsp[-2].bit_cat_), (yyvsp[-1].string_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6557 "Parser.c"
    break;

  case 377: /* COMPARISON: STRUCTURE_EXP _SYMB_180 STRUCTURE_EXP  */
#line 1118 "HAL_S.y"
                                          { (yyval.comparison_) = make_ADcomparisonNEQ((yyvsp[-2].structure_exp_), (yyvsp[-1].string_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6563 "Parser.c"
    break;

  case 378: /* COMPARISON: NAME_EXP _SYMB_180 NAME_EXP  */
#line 1119 "HAL_S.y"
                                { (yyval.comparison_) = make_AEcomparisonNEQ((yyvsp[-2].name_exp_), (yyvsp[-1].string_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6569 "Parser.c"
    break;

  case 379: /* COMPARISON: ARITH_EXP _SYMB_23 ARITH_EXP  */
#line 1120 "HAL_S.y"
                                 { (yyval.comparison_) = make_AAcomparisonLT((yyvsp[-2].arith_exp_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6575 "Parser.c"
    break;

  case 380: /* COMPARISON: CHAR_EXP _SYMB_23 CHAR_EXP  */
#line 1121 "HAL_S.y"
                               { (yyval.comparison_) = make_ABcomparisonLT((yyvsp[-2].char_exp_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6581 "Parser.c"
    break;

  case 381: /* COMPARISON: BIT_CAT _SYMB_23 BIT_CAT  */
#line 1122 "HAL_S.y"
                             { (yyval.comparison_) = make_ACcomparisonLT((yyvsp[-2].bit_cat_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6587 "Parser.c"
    break;

  case 382: /* COMPARISON: STRUCTURE_EXP _SYMB_23 STRUCTURE_EXP  */
#line 1123 "HAL_S.y"
                                         { (yyval.comparison_) = make_ADcomparisonLT((yyvsp[-2].structure_exp_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6593 "Parser.c"
    break;

  case 383: /* COMPARISON: NAME_EXP _SYMB_23 NAME_EXP  */
#line 1124 "HAL_S.y"
                               { (yyval.comparison_) = make_AEcomparisonLT((yyvsp[-2].name_exp_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6599 "Parser.c"
    break;

  case 384: /* COMPARISON: ARITH_EXP _SYMB_25 ARITH_EXP  */
#line 1125 "HAL_S.y"
                                 { (yyval.comparison_) = make_AAcomparisonGT((yyvsp[-2].arith_exp_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6605 "Parser.c"
    break;

  case 385: /* COMPARISON: CHAR_EXP _SYMB_25 CHAR_EXP  */
#line 1126 "HAL_S.y"
                               { (yyval.comparison_) = make_ABcomparisonGT((yyvsp[-2].char_exp_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6611 "Parser.c"
    break;

  case 386: /* COMPARISON: BIT_CAT _SYMB_25 BIT_CAT  */
#line 1127 "HAL_S.y"
                             { (yyval.comparison_) = make_ACcomparisonGT((yyvsp[-2].bit_cat_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6617 "Parser.c"
    break;

  case 387: /* COMPARISON: STRUCTURE_EXP _SYMB_25 STRUCTURE_EXP  */
#line 1128 "HAL_S.y"
                                         { (yyval.comparison_) = make_ADcomparisonGT((yyvsp[-2].structure_exp_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6623 "Parser.c"
    break;

  case 388: /* COMPARISON: NAME_EXP _SYMB_25 NAME_EXP  */
#line 1129 "HAL_S.y"
                               { (yyval.comparison_) = make_AEcomparisonGT((yyvsp[-2].name_exp_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6629 "Parser.c"
    break;

  case 389: /* COMPARISON: ARITH_EXP _SYMB_181 ARITH_EXP  */
#line 1130 "HAL_S.y"
                                  { (yyval.comparison_) = make_AAcomparisonLE((yyvsp[-2].arith_exp_), (yyvsp[-1].string_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6635 "Parser.c"
    break;

  case 390: /* COMPARISON: CHAR_EXP _SYMB_181 CHAR_EXP  */
#line 1131 "HAL_S.y"
                                { (yyval.comparison_) = make_ABcomparisonLE((yyvsp[-2].char_exp_), (yyvsp[-1].string_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6641 "Parser.c"
    break;

  case 391: /* COMPARISON: BIT_CAT _SYMB_181 BIT_CAT  */
#line 1132 "HAL_S.y"
                              { (yyval.comparison_) = make_ACcomparisonLE((yyvsp[-2].bit_cat_), (yyvsp[-1].string_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6647 "Parser.c"
    break;

  case 392: /* COMPARISON: STRUCTURE_EXP _SYMB_181 STRUCTURE_EXP  */
#line 1133 "HAL_S.y"
                                          { (yyval.comparison_) = make_ADcomparisonLE((yyvsp[-2].structure_exp_), (yyvsp[-1].string_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6653 "Parser.c"
    break;

  case 393: /* COMPARISON: NAME_EXP _SYMB_181 NAME_EXP  */
#line 1134 "HAL_S.y"
                                { (yyval.comparison_) = make_AEcomparisonLE((yyvsp[-2].name_exp_), (yyvsp[-1].string_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6659 "Parser.c"
    break;

  case 394: /* COMPARISON: ARITH_EXP _SYMB_182 ARITH_EXP  */
#line 1135 "HAL_S.y"
                                  { (yyval.comparison_) = make_AAcomparisonGE((yyvsp[-2].arith_exp_), (yyvsp[-1].string_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6665 "Parser.c"
    break;

  case 395: /* COMPARISON: CHAR_EXP _SYMB_182 CHAR_EXP  */
#line 1136 "HAL_S.y"
                                { (yyval.comparison_) = make_ABcomparisonGE((yyvsp[-2].char_exp_), (yyvsp[-1].string_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6671 "Parser.c"
    break;

  case 396: /* COMPARISON: BIT_CAT _SYMB_182 BIT_CAT  */
#line 1137 "HAL_S.y"
                              { (yyval.comparison_) = make_ACcomparisonGE((yyvsp[-2].bit_cat_), (yyvsp[-1].string_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6677 "Parser.c"
    break;

  case 397: /* COMPARISON: STRUCTURE_EXP _SYMB_182 STRUCTURE_EXP  */
#line 1138 "HAL_S.y"
                                          { (yyval.comparison_) = make_ADcomparisonGE((yyvsp[-2].structure_exp_), (yyvsp[-1].string_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6683 "Parser.c"
    break;

  case 398: /* COMPARISON: NAME_EXP _SYMB_182 NAME_EXP  */
#line 1139 "HAL_S.y"
                                { (yyval.comparison_) = make_AEcomparisonGE((yyvsp[-2].name_exp_), (yyvsp[-1].string_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6689 "Parser.c"
    break;

  case 399: /* ANY_STATEMENT: STATEMENT  */
#line 1141 "HAL_S.y"
                          { (yyval.any_statement_) = make_AAany_statement((yyvsp[0].statement_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6695 "Parser.c"
    break;

  case 400: /* ANY_STATEMENT: BLOCK_DEFINITION  */
#line 1142 "HAL_S.y"
                     { (yyval.any_statement_) = make_ABany_statement((yyvsp[0].block_definition_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6701 "Parser.c"
    break;

  case 401: /* ON_PHRASE: _SYMB_116 _SYMB_76 SUBSCRIPT  */
#line 1144 "HAL_S.y"
                                         { (yyval.on_phrase_) = make_AAon_phrase((yyvsp[0].subscript_)); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6707 "Parser.c"
    break;

  case 402: /* ON_PHRASE: _SYMB_116 _SYMB_76  */
#line 1145 "HAL_S.y"
                       { (yyval.on_phrase_) = make_ACon_phrase(); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6713 "Parser.c"
    break;

  case 403: /* ON_CLAUSE: _SYMB_116 _SYMB_76 SUBSCRIPT _SYMB_158  */
#line 1147 "HAL_S.y"
                                                   { (yyval.on_clause_) = make_AAon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6719 "Parser.c"
    break;

  case 404: /* ON_CLAUSE: _SYMB_116 _SYMB_76 SUBSCRIPT _SYMB_91  */
#line 1148 "HAL_S.y"
                                          { (yyval.on_clause_) = make_ABon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6725 "Parser.c"
    break;

  case 405: /* ON_CLAUSE: _SYMB_116 _SYMB_76 _SYMB_158  */
#line 1149 "HAL_S.y"
                                 { (yyval.on_clause_) = make_ADon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6731 "Parser.c"
    break;

  case 406: /* ON_CLAUSE: _SYMB_116 _SYMB_76 _SYMB_91  */
#line 1150 "HAL_S.y"
                                { (yyval.on_clause_) = make_AEon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6737 "Parser.c"
    break;

  case 407: /* LABEL_DEFINITION: LABEL _SYMB_18  */
#line 1152 "HAL_S.y"
                                  { (yyval.label_definition_) = make_AAlabel_definition((yyvsp[-1].label_)); (yyval.label_definition_)->line_number = (yyloc).first_line; (yyval.label_definition_)->char_number = (yyloc).first_column;  }
#line 6743 "Parser.c"
    break;

  case 408: /* CALL_KEY: _SYMB_48 LABEL_VAR  */
#line 1154 "HAL_S.y"
                              { (yyval.call_key_) = make_AAcall_key((yyvsp[0].label_var_)); (yyval.call_key_)->line_number = (yyloc).first_line; (yyval.call_key_)->char_number = (yyloc).first_column;  }
#line 6749 "Parser.c"
    break;

  case 409: /* ASSIGN: _SYMB_41  */
#line 1156 "HAL_S.y"
                  { (yyval.assign_) = make_AAassign(); (yyval.assign_)->line_number = (yyloc).first_line; (yyval.assign_)->char_number = (yyloc).first_column;  }
#line 6755 "Parser.c"
    break;

  case 410: /* CALL_ASSIGN_LIST: VARIABLE  */
#line 1158 "HAL_S.y"
                            { (yyval.call_assign_list_) = make_AAcall_assign_list((yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6761 "Parser.c"
    break;

  case 411: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_0 VARIABLE  */
#line 1159 "HAL_S.y"
                                      { (yyval.call_assign_list_) = make_ABcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6767 "Parser.c"
    break;

  case 412: /* CALL_ASSIGN_LIST: QUAL_STRUCT  */
#line 1160 "HAL_S.y"
                { (yyval.call_assign_list_) = make_ACcall_assign_list((yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6773 "Parser.c"
    break;

  case 413: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_0 QUAL_STRUCT  */
#line 1161 "HAL_S.y"
                                         { (yyval.call_assign_list_) = make_ADcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6779 "Parser.c"
    break;

  case 414: /* DO_GROUP_HEAD: _SYMB_69 _SYMB_17  */
#line 1163 "HAL_S.y"
                                  { (yyval.do_group_head_) = make_AAdoGroupHead(); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6785 "Parser.c"
    break;

  case 415: /* DO_GROUP_HEAD: _SYMB_69 FOR_LIST _SYMB_17  */
#line 1164 "HAL_S.y"
                               { (yyval.do_group_head_) = make_ABdoGroupHeadFor((yyvsp[-1].for_list_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6791 "Parser.c"
    break;

  case 416: /* DO_GROUP_HEAD: _SYMB_69 FOR_LIST WHILE_CLAUSE _SYMB_17  */
#line 1165 "HAL_S.y"
                                            { (yyval.do_group_head_) = make_ACdoGroupHeadForWhile((yyvsp[-2].for_list_), (yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6797 "Parser.c"
    break;

  case 417: /* DO_GROUP_HEAD: _SYMB_69 WHILE_CLAUSE _SYMB_17  */
#line 1166 "HAL_S.y"
                                   { (yyval.do_group_head_) = make_ADdoGroupHeadWhile((yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6803 "Parser.c"
    break;

  case 418: /* DO_GROUP_HEAD: _SYMB_69 _SYMB_50 ARITH_EXP _SYMB_17  */
#line 1167 "HAL_S.y"
                                         { (yyval.do_group_head_) = make_AEdoGroupHeadCase((yyvsp[-1].arith_exp_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6809 "Parser.c"
    break;

  case 419: /* DO_GROUP_HEAD: CASE_ELSE STATEMENT  */
#line 1168 "HAL_S.y"
                        { (yyval.do_group_head_) = make_AFdoGroupHeadCaseElse((yyvsp[-1].case_else_), (yyvsp[0].statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6815 "Parser.c"
    break;

  case 420: /* DO_GROUP_HEAD: DO_GROUP_HEAD ANY_STATEMENT  */
#line 1169 "HAL_S.y"
                                { (yyval.do_group_head_) = make_AGdoGroupHeadStatement((yyvsp[-1].do_group_head_), (yyvsp[0].any_statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6821 "Parser.c"
    break;

  case 421: /* DO_GROUP_HEAD: DO_GROUP_HEAD TEMPORARY_STMT  */
#line 1170 "HAL_S.y"
                                 { (yyval.do_group_head_) = make_AHdoGroupHeadTemporaryStatement((yyvsp[-1].do_group_head_), (yyvsp[0].temporary_stmt_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6827 "Parser.c"
    break;

  case 422: /* ENDING: _SYMB_72  */
#line 1172 "HAL_S.y"
                  { (yyval.ending_) = make_AAending(); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6833 "Parser.c"
    break;

  case 423: /* ENDING: _SYMB_72 LABEL  */
#line 1173 "HAL_S.y"
                   { (yyval.ending_) = make_ABending((yyvsp[0].label_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6839 "Parser.c"
    break;

  case 424: /* ENDING: LABEL_DEFINITION ENDING  */
#line 1174 "HAL_S.y"
                            { (yyval.ending_) = make_ACending((yyvsp[-1].label_definition_), (yyvsp[0].ending_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6845 "Parser.c"
    break;

  case 425: /* READ_KEY: _SYMB_126 _SYMB_2 NUMBER _SYMB_1  */
#line 1176 "HAL_S.y"
                                            { (yyval.read_key_) = make_AAread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 6851 "Parser.c"
    break;

  case 426: /* READ_KEY: _SYMB_127 _SYMB_2 NUMBER _SYMB_1  */
#line 1177 "HAL_S.y"
                                     { (yyval.read_key_) = make_ABread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 6857 "Parser.c"
    break;

  case 427: /* WRITE_KEY: _SYMB_178 _SYMB_2 NUMBER _SYMB_1  */
#line 1179 "HAL_S.y"
                                             { (yyval.write_key_) = make_AAwrite_key((yyvsp[-1].number_)); (yyval.write_key_)->line_number = (yyloc).first_line; (yyval.write_key_)->char_number = (yyloc).first_column;  }
#line 6863 "Parser.c"
    break;

  case 428: /* READ_PHRASE: READ_KEY READ_ARG  */
#line 1181 "HAL_S.y"
                                { (yyval.read_phrase_) = make_AAread_phrase((yyvsp[-1].read_key_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 6869 "Parser.c"
    break;

  case 429: /* READ_PHRASE: READ_PHRASE _SYMB_0 READ_ARG  */
#line 1182 "HAL_S.y"
                                 { (yyval.read_phrase_) = make_ABread_phrase((yyvsp[-2].read_phrase_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 6875 "Parser.c"
    break;

  case 430: /* WRITE_PHRASE: WRITE_KEY WRITE_ARG  */
#line 1184 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_AAwrite_phrase((yyvsp[-1].write_key_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 6881 "Parser.c"
    break;

  case 431: /* WRITE_PHRASE: WRITE_PHRASE _SYMB_0 WRITE_ARG  */
#line 1185 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_ABwrite_phrase((yyvsp[-2].write_phrase_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 6887 "Parser.c"
    break;

  case 432: /* READ_ARG: VARIABLE  */
#line 1187 "HAL_S.y"
                    { (yyval.read_arg_) = make_AAread_arg((yyvsp[0].variable_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 6893 "Parser.c"
    break;

  case 433: /* READ_ARG: IO_CONTROL  */
#line 1188 "HAL_S.y"
               { (yyval.read_arg_) = make_ABread_arg((yyvsp[0].io_control_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 6899 "Parser.c"
    break;

  case 434: /* WRITE_ARG: EXPRESSION  */
#line 1190 "HAL_S.y"
                       { (yyval.write_arg_) = make_AAwrite_arg((yyvsp[0].expression_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6905 "Parser.c"
    break;

  case 435: /* WRITE_ARG: IO_CONTROL  */
#line 1191 "HAL_S.y"
               { (yyval.write_arg_) = make_ABwrite_arg((yyvsp[0].io_control_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6911 "Parser.c"
    break;

  case 436: /* WRITE_ARG: _SYMB_187  */
#line 1192 "HAL_S.y"
              { (yyval.write_arg_) = make_ACwrite_arg((yyvsp[0].string_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6917 "Parser.c"
    break;

  case 437: /* FILE_EXP: FILE_HEAD _SYMB_0 ARITH_EXP _SYMB_1  */
#line 1194 "HAL_S.y"
                                               { (yyval.file_exp_) = make_AAfile_exp((yyvsp[-3].file_head_), (yyvsp[-1].arith_exp_)); (yyval.file_exp_)->line_number = (yyloc).first_line; (yyval.file_exp_)->char_number = (yyloc).first_column;  }
#line 6923 "Parser.c"
    break;

  case 438: /* FILE_HEAD: _SYMB_84 _SYMB_2 NUMBER  */
#line 1196 "HAL_S.y"
                                    { (yyval.file_head_) = make_AAfile_head((yyvsp[0].number_)); (yyval.file_head_)->line_number = (yyloc).first_line; (yyval.file_head_)->char_number = (yyloc).first_column;  }
#line 6929 "Parser.c"
    break;

  case 439: /* IO_CONTROL: _SYMB_152 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1198 "HAL_S.y"
                                                 { (yyval.io_control_) = make_AAioControlSkip((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6935 "Parser.c"
    break;

  case 440: /* IO_CONTROL: _SYMB_159 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1199 "HAL_S.y"
                                        { (yyval.io_control_) = make_ABioControlTab((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6941 "Parser.c"
    break;

  case 441: /* IO_CONTROL: _SYMB_57 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1200 "HAL_S.y"
                                       { (yyval.io_control_) = make_ACioControlColumn((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6947 "Parser.c"
    break;

  case 442: /* IO_CONTROL: _SYMB_99 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1201 "HAL_S.y"
                                       { (yyval.io_control_) = make_ADioControlLine((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6953 "Parser.c"
    break;

  case 443: /* IO_CONTROL: _SYMB_118 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1202 "HAL_S.y"
                                        { (yyval.io_control_) = make_AEioControlPage((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6959 "Parser.c"
    break;

  case 444: /* WAIT_KEY: _SYMB_176  */
#line 1204 "HAL_S.y"
                     { (yyval.wait_key_) = make_AAwait_key(); (yyval.wait_key_)->line_number = (yyloc).first_line; (yyval.wait_key_)->char_number = (yyloc).first_column;  }
#line 6965 "Parser.c"
    break;

  case 445: /* TERMINATOR: _SYMB_164  */
#line 1206 "HAL_S.y"
                       { (yyval.terminator_) = make_AAterminatorTerminate(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 6971 "Parser.c"
    break;

  case 446: /* TERMINATOR: _SYMB_49  */
#line 1207 "HAL_S.y"
             { (yyval.terminator_) = make_ABterminatorCancel(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 6977 "Parser.c"
    break;

  case 447: /* TERMINATE_LIST: LABEL_VAR  */
#line 1209 "HAL_S.y"
                           { (yyval.terminate_list_) = make_AAterminate_list((yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 6983 "Parser.c"
    break;

  case 448: /* TERMINATE_LIST: TERMINATE_LIST _SYMB_0 LABEL_VAR  */
#line 1210 "HAL_S.y"
                                     { (yyval.terminate_list_) = make_ABterminate_list((yyvsp[-2].terminate_list_), (yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 6989 "Parser.c"
    break;

  case 449: /* SCHEDULE_HEAD: _SYMB_140 LABEL_VAR  */
#line 1212 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_AAscheduleHeadLabel((yyvsp[0].label_var_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6995 "Parser.c"
    break;

  case 450: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_42 ARITH_EXP  */
#line 1213 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ABscheduleHeadAt((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 7001 "Parser.c"
    break;

  case 451: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_92 ARITH_EXP  */
#line 1214 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ACscheduleHeadIn((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 7007 "Parser.c"
    break;

  case 452: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_116 BIT_EXP  */
#line 1215 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_ADscheduleHeadOn((yyvsp[-2].schedule_head_), (yyvsp[0].bit_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 7013 "Parser.c"
    break;

  case 453: /* SCHEDULE_PHRASE: SCHEDULE_HEAD  */
#line 1217 "HAL_S.y"
                                { (yyval.schedule_phrase_) = make_AAschedule_phrase((yyvsp[0].schedule_head_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 7019 "Parser.c"
    break;

  case 454: /* SCHEDULE_PHRASE: SCHEDULE_HEAD _SYMB_120 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1218 "HAL_S.y"
                                                      { (yyval.schedule_phrase_) = make_ABschedule_phrase((yyvsp[-4].schedule_head_), (yyvsp[-1].arith_exp_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 7025 "Parser.c"
    break;

  case 455: /* SCHEDULE_PHRASE: SCHEDULE_PHRASE _SYMB_66  */
#line 1219 "HAL_S.y"
                             { (yyval.schedule_phrase_) = make_ACschedule_phrase((yyvsp[-1].schedule_phrase_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 7031 "Parser.c"
    break;

  case 456: /* SCHEDULE_CONTROL: STOPPING  */
#line 1221 "HAL_S.y"
                            { (yyval.schedule_control_) = make_AAschedule_control((yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 7037 "Parser.c"
    break;

  case 457: /* SCHEDULE_CONTROL: TIMING  */
#line 1222 "HAL_S.y"
           { (yyval.schedule_control_) = make_ABschedule_control((yyvsp[0].timing_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 7043 "Parser.c"
    break;

  case 458: /* SCHEDULE_CONTROL: TIMING STOPPING  */
#line 1223 "HAL_S.y"
                    { (yyval.schedule_control_) = make_ACschedule_control((yyvsp[-1].timing_), (yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 7049 "Parser.c"
    break;

  case 459: /* TIMING: REPEAT _SYMB_78 ARITH_EXP  */
#line 1225 "HAL_S.y"
                                   { (yyval.timing_) = make_AAtimingEvery((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 7055 "Parser.c"
    break;

  case 460: /* TIMING: REPEAT _SYMB_30 ARITH_EXP  */
#line 1226 "HAL_S.y"
                              { (yyval.timing_) = make_ABtimingAfter((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 7061 "Parser.c"
    break;

  case 461: /* TIMING: REPEAT  */
#line 1227 "HAL_S.y"
           { (yyval.timing_) = make_ACtiming((yyvsp[0].repeat_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 7067 "Parser.c"
    break;

  case 462: /* REPEAT: _SYMB_0 _SYMB_131  */
#line 1229 "HAL_S.y"
                           { (yyval.repeat_) = make_AArepeat(); (yyval.repeat_)->line_number = (yyloc).first_line; (yyval.repeat_)->char_number = (yyloc).first_column;  }
#line 7073 "Parser.c"
    break;

  case 463: /* STOPPING: WHILE_KEY ARITH_EXP  */
#line 1231 "HAL_S.y"
                               { (yyval.stopping_) = make_AAstopping((yyvsp[-1].while_key_), (yyvsp[0].arith_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 7079 "Parser.c"
    break;

  case 464: /* STOPPING: WHILE_KEY BIT_EXP  */
#line 1232 "HAL_S.y"
                      { (yyval.stopping_) = make_ABstopping((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 7085 "Parser.c"
    break;

  case 465: /* SIGNAL_CLAUSE: _SYMB_142 EVENT_VAR  */
#line 1234 "HAL_S.y"
                                    { (yyval.signal_clause_) = make_AAsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 7091 "Parser.c"
    break;

  case 466: /* SIGNAL_CLAUSE: _SYMB_133 EVENT_VAR  */
#line 1235 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ABsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 7097 "Parser.c"
    break;

  case 467: /* SIGNAL_CLAUSE: _SYMB_146 EVENT_VAR  */
#line 1236 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ACsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 7103 "Parser.c"
    break;

  case 468: /* PERCENT_MACRO_NAME: _SYMB_26 IDENTIFIER  */
#line 1238 "HAL_S.y"
                                         { (yyval.percent_macro_name_) = make_FNpercent_macro_name((yyvsp[0].identifier_)); (yyval.percent_macro_name_)->line_number = (yyloc).first_line; (yyval.percent_macro_name_)->char_number = (yyloc).first_column;  }
#line 7109 "Parser.c"
    break;

  case 469: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_NAME _SYMB_2  */
#line 1240 "HAL_S.y"
                                                { (yyval.percent_macro_head_) = make_AApercent_macro_head((yyvsp[-1].percent_macro_name_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 7115 "Parser.c"
    break;

  case 470: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_0  */
#line 1241 "HAL_S.y"
                                                 { (yyval.percent_macro_head_) = make_ABpercent_macro_head((yyvsp[-2].percent_macro_head_), (yyvsp[-1].percent_macro_arg_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 7121 "Parser.c"
    break;

  case 471: /* PERCENT_MACRO_ARG: NAME_VAR  */
#line 1243 "HAL_S.y"
                             { (yyval.percent_macro_arg_) = make_AApercent_macro_arg((yyvsp[0].name_var_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 7127 "Parser.c"
    break;

  case 472: /* PERCENT_MACRO_ARG: CONSTANT  */
#line 1244 "HAL_S.y"
             { (yyval.percent_macro_arg_) = make_ABpercent_macro_arg((yyvsp[0].constant_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 7133 "Parser.c"
    break;

  case 473: /* CASE_ELSE: _SYMB_69 _SYMB_50 ARITH_EXP _SYMB_17 _SYMB_71  */
#line 1246 "HAL_S.y"
                                                          { (yyval.case_else_) = make_AAcase_else((yyvsp[-2].arith_exp_)); (yyval.case_else_)->line_number = (yyloc).first_line; (yyval.case_else_)->char_number = (yyloc).first_column;  }
#line 7139 "Parser.c"
    break;

  case 474: /* WHILE_KEY: _SYMB_177  */
#line 1248 "HAL_S.y"
                      { (yyval.while_key_) = make_AAwhileKeyWhile(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 7145 "Parser.c"
    break;

  case 475: /* WHILE_KEY: _SYMB_173  */
#line 1249 "HAL_S.y"
              { (yyval.while_key_) = make_ABwhileKeyUntil(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 7151 "Parser.c"
    break;

  case 476: /* WHILE_CLAUSE: WHILE_KEY BIT_EXP  */
#line 1251 "HAL_S.y"
                                 { (yyval.while_clause_) = make_AAwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 7157 "Parser.c"
    break;

  case 477: /* WHILE_CLAUSE: WHILE_KEY RELATIONAL_EXP  */
#line 1252 "HAL_S.y"
                             { (yyval.while_clause_) = make_ABwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].relational_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 7163 "Parser.c"
    break;

  case 478: /* FOR_LIST: FOR_KEY ARITH_EXP ITERATION_CONTROL  */
#line 1254 "HAL_S.y"
                                               { (yyval.for_list_) = make_AAfor_list((yyvsp[-2].for_key_), (yyvsp[-1].arith_exp_), (yyvsp[0].iteration_control_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 7169 "Parser.c"
    break;

  case 479: /* FOR_LIST: FOR_KEY ITERATION_BODY  */
#line 1255 "HAL_S.y"
                           { (yyval.for_list_) = make_ABfor_list((yyvsp[-1].for_key_), (yyvsp[0].iteration_body_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 7175 "Parser.c"
    break;

  case 480: /* ITERATION_BODY: ARITH_EXP  */
#line 1257 "HAL_S.y"
                           { (yyval.iteration_body_) = make_AAiteration_body((yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 7181 "Parser.c"
    break;

  case 481: /* ITERATION_BODY: ITERATION_BODY _SYMB_0 ARITH_EXP  */
#line 1258 "HAL_S.y"
                                     { (yyval.iteration_body_) = make_ABiteration_body((yyvsp[-2].iteration_body_), (yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 7187 "Parser.c"
    break;

  case 482: /* ITERATION_CONTROL: _SYMB_166 ARITH_EXP  */
#line 1260 "HAL_S.y"
                                        { (yyval.iteration_control_) = make_AAiteration_controlTo((yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 7193 "Parser.c"
    break;

  case 483: /* ITERATION_CONTROL: _SYMB_166 ARITH_EXP _SYMB_47 ARITH_EXP  */
#line 1261 "HAL_S.y"
                                           { (yyval.iteration_control_) = make_ABiteration_controlToBy((yyvsp[-2].arith_exp_), (yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 7199 "Parser.c"
    break;

  case 484: /* FOR_KEY: _SYMB_86 ARITH_VAR EQUALS  */
#line 1263 "HAL_S.y"
                                    { (yyval.for_key_) = make_AAforKey((yyvsp[-1].arith_var_), (yyvsp[0].equals_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 7205 "Parser.c"
    break;

  case 485: /* FOR_KEY: _SYMB_86 _SYMB_163 IDENTIFIER _SYMB_24  */
#line 1264 "HAL_S.y"
                                           { (yyval.for_key_) = make_ABforKeyTemporary((yyvsp[-1].identifier_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 7211 "Parser.c"
    break;

  case 486: /* TEMPORARY_STMT: _SYMB_163 DECLARE_BODY _SYMB_17  */
#line 1266 "HAL_S.y"
                                                 { (yyval.temporary_stmt_) = make_AAtemporary_stmt((yyvsp[-1].declare_body_)); (yyval.temporary_stmt_)->line_number = (yyloc).first_line; (yyval.temporary_stmt_)->char_number = (yyloc).first_column;  }
#line 7217 "Parser.c"
    break;

  case 487: /* CONSTANT: NUMBER  */
#line 1268 "HAL_S.y"
                  { (yyval.constant_) = make_AAconstant((yyvsp[0].number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 7223 "Parser.c"
    break;

  case 488: /* CONSTANT: COMPOUND_NUMBER  */
#line 1269 "HAL_S.y"
                    { (yyval.constant_) = make_ABconstant((yyvsp[0].compound_number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 7229 "Parser.c"
    break;

  case 489: /* CONSTANT: BIT_CONST  */
#line 1270 "HAL_S.y"
              { (yyval.constant_) = make_ACconstant((yyvsp[0].bit_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 7235 "Parser.c"
    break;

  case 490: /* CONSTANT: CHAR_CONST  */
#line 1271 "HAL_S.y"
               { (yyval.constant_) = make_ADconstant((yyvsp[0].char_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 7241 "Parser.c"
    break;

  case 491: /* ARRAY_HEAD: _SYMB_40 _SYMB_2  */
#line 1273 "HAL_S.y"
                              { (yyval.array_head_) = make_AAarray_head(); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 7247 "Parser.c"
    break;

  case 492: /* ARRAY_HEAD: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_0  */
#line 1274 "HAL_S.y"
                                           { (yyval.array_head_) = make_ABarray_head((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 7253 "Parser.c"
    break;

  case 493: /* MINOR_ATTR_LIST: MINOR_ATTRIBUTE  */
#line 1276 "HAL_S.y"
                                  { (yyval.minor_attr_list_) = make_AAminor_attr_list((yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 7259 "Parser.c"
    break;

  case 494: /* MINOR_ATTR_LIST: MINOR_ATTR_LIST MINOR_ATTRIBUTE  */
#line 1277 "HAL_S.y"
                                    { (yyval.minor_attr_list_) = make_ABminor_attr_list((yyvsp[-1].minor_attr_list_), (yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 7265 "Parser.c"
    break;

  case 495: /* MINOR_ATTRIBUTE: _SYMB_154  */
#line 1279 "HAL_S.y"
                            { (yyval.minor_attribute_) = make_AAminorAttributeStatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7271 "Parser.c"
    break;

  case 496: /* MINOR_ATTRIBUTE: _SYMB_43  */
#line 1280 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ABminorAttributeAutomatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7277 "Parser.c"
    break;

  case 497: /* MINOR_ATTRIBUTE: _SYMB_65  */
#line 1281 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ACminorAttributeDense(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7283 "Parser.c"
    break;

  case 498: /* MINOR_ATTRIBUTE: _SYMB_31  */
#line 1282 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ADminorAttributeAligned(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7289 "Parser.c"
    break;

  case 499: /* MINOR_ATTRIBUTE: _SYMB_29  */
#line 1283 "HAL_S.y"
             { (yyval.minor_attribute_) = make_AEminorAttributeAccess(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7295 "Parser.c"
    break;

  case 500: /* MINOR_ATTRIBUTE: _SYMB_101 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1284 "HAL_S.y"
                                                  { (yyval.minor_attribute_) = make_AFminorAttributeLock((yyvsp[-1].literal_exp_or_star_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7301 "Parser.c"
    break;

  case 501: /* MINOR_ATTRIBUTE: _SYMB_130  */
#line 1285 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AGminorAttributeRemote(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7307 "Parser.c"
    break;

  case 502: /* MINOR_ATTRIBUTE: _SYMB_135  */
#line 1286 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AHminorAttributeRigid(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7313 "Parser.c"
    break;

  case 503: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_1  */
#line 1287 "HAL_S.y"
                                                 { (yyval.minor_attribute_) = make_AIminorAttributeRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7319 "Parser.c"
    break;

  case 504: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD _SYMB_6 _SYMB_1  */
#line 1288 "HAL_S.y"
                                       { (yyval.minor_attribute_) = make_AJminorAttributeStar((yyvsp[-2].init_or_const_head_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7325 "Parser.c"
    break;

  case 505: /* MINOR_ATTRIBUTE: _SYMB_97  */
#line 1289 "HAL_S.y"
             { (yyval.minor_attribute_) = make_AKminorAttributeLatched(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7331 "Parser.c"
    break;

  case 506: /* MINOR_ATTRIBUTE: _SYMB_110 _SYMB_2 LEVEL _SYMB_1  */
#line 1290 "HAL_S.y"
                                    { (yyval.minor_attribute_) = make_ALminorAttributeNonHal((yyvsp[-1].level_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7337 "Parser.c"
    break;

  case 507: /* INIT_OR_CONST_HEAD: _SYMB_94 _SYMB_2  */
#line 1292 "HAL_S.y"
                                      { (yyval.init_or_const_head_) = make_AAinit_or_const_headInitial(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7343 "Parser.c"
    break;

  case 508: /* INIT_OR_CONST_HEAD: _SYMB_59 _SYMB_2  */
#line 1293 "HAL_S.y"
                     { (yyval.init_or_const_head_) = make_ABinit_or_const_headConstant(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7349 "Parser.c"
    break;

  case 509: /* INIT_OR_CONST_HEAD: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_0  */
#line 1294 "HAL_S.y"
                                                 { (yyval.init_or_const_head_) = make_ACinit_or_const_headRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7355 "Parser.c"
    break;

  case 510: /* REPEATED_CONSTANT: EXPRESSION  */
#line 1296 "HAL_S.y"
                               { (yyval.repeated_constant_) = make_AArepeated_constant((yyvsp[0].expression_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7361 "Parser.c"
    break;

  case 511: /* REPEATED_CONSTANT: REPEAT_HEAD VARIABLE  */
#line 1297 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ABrepeated_constantMark((yyvsp[-1].repeat_head_), (yyvsp[0].variable_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7367 "Parser.c"
    break;

  case 512: /* REPEATED_CONSTANT: REPEAT_HEAD CONSTANT  */
#line 1298 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ACrepeated_constantMark((yyvsp[-1].repeat_head_), (yyvsp[0].constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7373 "Parser.c"
    break;

  case 513: /* REPEATED_CONSTANT: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_1  */
#line 1299 "HAL_S.y"
                                                 { (yyval.repeated_constant_) = make_ADrepeated_constantMark((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7379 "Parser.c"
    break;

  case 514: /* REPEATED_CONSTANT: REPEAT_HEAD  */
#line 1300 "HAL_S.y"
                { (yyval.repeated_constant_) = make_AErepeated_constantMark((yyvsp[0].repeat_head_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7385 "Parser.c"
    break;

  case 515: /* REPEAT_HEAD: ARITH_EXP _SYMB_10  */
#line 1302 "HAL_S.y"
                                 { (yyval.repeat_head_) = make_AArepeat_head((yyvsp[-1].arith_exp_)); (yyval.repeat_head_)->line_number = (yyloc).first_line; (yyval.repeat_head_)->char_number = (yyloc).first_column;  }
#line 7391 "Parser.c"
    break;

  case 516: /* NESTED_REPEAT_HEAD: REPEAT_HEAD _SYMB_2  */
#line 1304 "HAL_S.y"
                                         { (yyval.nested_repeat_head_) = make_AAnested_repeat_head((yyvsp[-1].repeat_head_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 7397 "Parser.c"
    break;

  case 517: /* NESTED_REPEAT_HEAD: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_0  */
#line 1305 "HAL_S.y"
                                                 { (yyval.nested_repeat_head_) = make_ABnested_repeat_head((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 7403 "Parser.c"
    break;

  case 518: /* DCL_LIST_COMMA: DECLARATION_LIST _SYMB_0  */
#line 1307 "HAL_S.y"
                                          { (yyval.dcl_list_comma_) = make_AAdcl_list_comma((yyvsp[-1].declaration_list_)); (yyval.dcl_list_comma_)->line_number = (yyloc).first_line; (yyval.dcl_list_comma_)->char_number = (yyloc).first_column;  }
#line 7409 "Parser.c"
    break;

  case 519: /* LITERAL_EXP_OR_STAR: ARITH_EXP  */
#line 1309 "HAL_S.y"
                                { (yyval.literal_exp_or_star_) = make_AAliteralExp((yyvsp[0].arith_exp_)); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7415 "Parser.c"
    break;

  case 520: /* LITERAL_EXP_OR_STAR: _SYMB_6  */
#line 1310 "HAL_S.y"
            { (yyval.literal_exp_or_star_) = make_ABliteralStar(); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7421 "Parser.c"
    break;

  case 521: /* TYPE_SPEC: STRUCT_SPEC  */
#line 1312 "HAL_S.y"
                        { (yyval.type_spec_) = make_AAtypeSpecStruct((yyvsp[0].struct_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7427 "Parser.c"
    break;

  case 522: /* TYPE_SPEC: BIT_SPEC  */
#line 1313 "HAL_S.y"
             { (yyval.type_spec_) = make_ABtypeSpecBit((yyvsp[0].bit_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7433 "Parser.c"
    break;

  case 523: /* TYPE_SPEC: CHAR_SPEC  */
#line 1314 "HAL_S.y"
              { (yyval.type_spec_) = make_ACtypeSpecChar((yyvsp[0].char_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7439 "Parser.c"
    break;

  case 524: /* TYPE_SPEC: ARITH_SPEC  */
#line 1315 "HAL_S.y"
               { (yyval.type_spec_) = make_ADtypeSpecArith((yyvsp[0].arith_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7445 "Parser.c"
    break;

  case 525: /* TYPE_SPEC: _SYMB_77  */
#line 1316 "HAL_S.y"
             { (yyval.type_spec_) = make_AEtypeSpecEvent(); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7451 "Parser.c"
    break;

  case 526: /* BIT_SPEC: _SYMB_46  */
#line 1318 "HAL_S.y"
                    { (yyval.bit_spec_) = make_AAbitSpecBoolean(); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7457 "Parser.c"
    break;

  case 527: /* BIT_SPEC: _SYMB_45 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1319 "HAL_S.y"
                                                 { (yyval.bit_spec_) = make_ABbitSpecBoolean((yyvsp[-1].literal_exp_or_star_)); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7463 "Parser.c"
    break;

  case 528: /* CHAR_SPEC: _SYMB_54 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1321 "HAL_S.y"
                                                         { (yyval.char_spec_) = make_AAchar_spec((yyvsp[-1].literal_exp_or_star_)); (yyval.char_spec_)->line_number = (yyloc).first_line; (yyval.char_spec_)->char_number = (yyloc).first_column;  }
#line 7469 "Parser.c"
    break;

  case 529: /* STRUCT_SPEC: STRUCT_TEMPLATE STRUCT_SPEC_BODY  */
#line 1323 "HAL_S.y"
                                               { (yyval.struct_spec_) = make_AAstruct_spec((yyvsp[-1].struct_template_), (yyvsp[0].struct_spec_body_)); (yyval.struct_spec_)->line_number = (yyloc).first_line; (yyval.struct_spec_)->char_number = (yyloc).first_column;  }
#line 7475 "Parser.c"
    break;

  case 530: /* STRUCT_SPEC_BODY: _SYMB_5 _SYMB_155  */
#line 1325 "HAL_S.y"
                                     { (yyval.struct_spec_body_) = make_AAstruct_spec_body(); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7481 "Parser.c"
    break;

  case 531: /* STRUCT_SPEC_BODY: STRUCT_SPEC_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1326 "HAL_S.y"
                                                 { (yyval.struct_spec_body_) = make_ABstruct_spec_body((yyvsp[-2].struct_spec_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7487 "Parser.c"
    break;

  case 532: /* STRUCT_TEMPLATE: STRUCTURE_ID  */
#line 1328 "HAL_S.y"
                               { (yyval.struct_template_) = make_FMstruct_template((yyvsp[0].structure_id_)); (yyval.struct_template_)->line_number = (yyloc).first_line; (yyval.struct_template_)->char_number = (yyloc).first_column;  }
#line 7493 "Parser.c"
    break;

  case 533: /* STRUCT_SPEC_HEAD: _SYMB_5 _SYMB_155 _SYMB_2  */
#line 1330 "HAL_S.y"
                                             { (yyval.struct_spec_head_) = make_AAstruct_spec_head(); (yyval.struct_spec_head_)->line_number = (yyloc).first_line; (yyval.struct_spec_head_)->char_number = (yyloc).first_column;  }
#line 7499 "Parser.c"
    break;

  case 534: /* ARITH_SPEC: PREC_SPEC  */
#line 1332 "HAL_S.y"
                       { (yyval.arith_spec_) = make_AAarith_spec((yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7505 "Parser.c"
    break;

  case 535: /* ARITH_SPEC: SQ_DQ_NAME  */
#line 1333 "HAL_S.y"
               { (yyval.arith_spec_) = make_ABarith_spec((yyvsp[0].sq_dq_name_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7511 "Parser.c"
    break;

  case 536: /* ARITH_SPEC: SQ_DQ_NAME PREC_SPEC  */
#line 1334 "HAL_S.y"
                         { (yyval.arith_spec_) = make_ACarith_spec((yyvsp[-1].sq_dq_name_), (yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7517 "Parser.c"
    break;

  case 537: /* COMPILATION: ANY_STATEMENT  */
#line 1336 "HAL_S.y"
                            { (yyval.compilation_) = make_AAcompilation((yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7523 "Parser.c"
    break;

  case 538: /* COMPILATION: COMPILATION ANY_STATEMENT  */
#line 1337 "HAL_S.y"
                              { (yyval.compilation_) = make_ABcompilation((yyvsp[-1].compilation_), (yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7529 "Parser.c"
    break;

  case 539: /* COMPILATION: DECLARE_STATEMENT  */
#line 1338 "HAL_S.y"
                      { (yyval.compilation_) = make_ACcompilation((yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7535 "Parser.c"
    break;

  case 540: /* COMPILATION: COMPILATION DECLARE_STATEMENT  */
#line 1339 "HAL_S.y"
                                  { (yyval.compilation_) = make_ADcompilation((yyvsp[-1].compilation_), (yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7541 "Parser.c"
    break;

  case 541: /* COMPILATION: STRUCTURE_STMT  */
#line 1340 "HAL_S.y"
                   { (yyval.compilation_) = make_AEcompilation((yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7547 "Parser.c"
    break;

  case 542: /* COMPILATION: COMPILATION STRUCTURE_STMT  */
#line 1341 "HAL_S.y"
                               { (yyval.compilation_) = make_AFcompilation((yyvsp[-1].compilation_), (yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7553 "Parser.c"
    break;

  case 543: /* COMPILATION: REPLACE_STMT _SYMB_17  */
#line 1342 "HAL_S.y"
                          { (yyval.compilation_) = make_AGcompilation((yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7559 "Parser.c"
    break;

  case 544: /* COMPILATION: COMPILATION REPLACE_STMT _SYMB_17  */
#line 1343 "HAL_S.y"
                                      { (yyval.compilation_) = make_AHcompilation((yyvsp[-2].compilation_), (yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7565 "Parser.c"
    break;

  case 545: /* COMPILATION: INIT_OR_CONST_HEAD EXPRESSION _SYMB_1  */
#line 1344 "HAL_S.y"
                                          { (yyval.compilation_) = make_AZcompilationInitOrConst((yyvsp[-2].init_or_const_head_), (yyvsp[-1].expression_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7571 "Parser.c"
    break;

  case 546: /* BLOCK_DEFINITION: BLOCK_STMT CLOSING _SYMB_17  */
#line 1346 "HAL_S.y"
                                               { (yyval.block_definition_) = make_AAblock_definition((yyvsp[-2].block_stmt_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7577 "Parser.c"
    break;

  case 547: /* BLOCK_DEFINITION: BLOCK_STMT BLOCK_BODY CLOSING _SYMB_17  */
#line 1347 "HAL_S.y"
                                           { (yyval.block_definition_) = make_ABblock_definition((yyvsp[-3].block_stmt_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7583 "Parser.c"
    break;

  case 548: /* BLOCK_STMT: BLOCK_STMT_TOP _SYMB_17  */
#line 1349 "HAL_S.y"
                                     { (yyval.block_stmt_) = make_AAblock_stmt((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_)->line_number = (yyloc).first_line; (yyval.block_stmt_)->char_number = (yyloc).first_column;  }
#line 7589 "Parser.c"
    break;

  case 549: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_29  */
#line 1351 "HAL_S.y"
                                         { (yyval.block_stmt_top_) = make_AAblockTopAccess((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7595 "Parser.c"
    break;

  case 550: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_135  */
#line 1352 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ABblockTopRigid((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7601 "Parser.c"
    break;

  case 551: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD  */
#line 1353 "HAL_S.y"
                    { (yyval.block_stmt_top_) = make_ACblockTopHead((yyvsp[0].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7607 "Parser.c"
    break;

  case 552: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_79  */
#line 1354 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ADblockTopExclusive((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7613 "Parser.c"
    break;

  case 553: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_128  */
#line 1355 "HAL_S.y"
                              { (yyval.block_stmt_top_) = make_AEblockTopReentrant((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7619 "Parser.c"
    break;

  case 554: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_123  */
#line 1357 "HAL_S.y"
                                           { (yyval.block_stmt_head_) = make_AAblockHeadProgram((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7625 "Parser.c"
    break;

  case 555: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_58  */
#line 1358 "HAL_S.y"
                            { (yyval.block_stmt_head_) = make_ABblockHeadCompool((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7631 "Parser.c"
    break;

  case 556: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_162  */
#line 1359 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ACblockHeadTask((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7637 "Parser.c"
    break;

  case 557: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_174  */
#line 1360 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ADblockHeadUpdate((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7643 "Parser.c"
    break;

  case 558: /* BLOCK_STMT_HEAD: _SYMB_174  */
#line 1361 "HAL_S.y"
              { (yyval.block_stmt_head_) = make_AEblockHeadUpdate(); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7649 "Parser.c"
    break;

  case 559: /* BLOCK_STMT_HEAD: FUNCTION_NAME  */
#line 1362 "HAL_S.y"
                  { (yyval.block_stmt_head_) = make_AFblockHeadFunction((yyvsp[0].function_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7655 "Parser.c"
    break;

  case 560: /* BLOCK_STMT_HEAD: FUNCTION_NAME FUNC_STMT_BODY  */
#line 1363 "HAL_S.y"
                                 { (yyval.block_stmt_head_) = make_AGblockHeadFunction((yyvsp[-1].function_name_), (yyvsp[0].func_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7661 "Parser.c"
    break;

  case 561: /* BLOCK_STMT_HEAD: PROCEDURE_NAME  */
#line 1364 "HAL_S.y"
                   { (yyval.block_stmt_head_) = make_AHblockHeadProcedure((yyvsp[0].procedure_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7667 "Parser.c"
    break;

  case 562: /* BLOCK_STMT_HEAD: PROCEDURE_NAME PROC_STMT_BODY  */
#line 1365 "HAL_S.y"
                                  { (yyval.block_stmt_head_) = make_AIblockHeadProcedure((yyvsp[-1].procedure_name_), (yyvsp[0].proc_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7673 "Parser.c"
    break;

  case 563: /* LABEL_EXTERNAL: LABEL_DEFINITION  */
#line 1367 "HAL_S.y"
                                  { (yyval.label_external_) = make_AAlabel_external((yyvsp[0].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7679 "Parser.c"
    break;

  case 564: /* LABEL_EXTERNAL: LABEL_DEFINITION _SYMB_82  */
#line 1368 "HAL_S.y"
                              { (yyval.label_external_) = make_ABlabel_external((yyvsp[-1].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7685 "Parser.c"
    break;

  case 565: /* CLOSING: _SYMB_56  */
#line 1370 "HAL_S.y"
                   { (yyval.closing_) = make_AAclosing(); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7691 "Parser.c"
    break;

  case 566: /* CLOSING: _SYMB_56 LABEL  */
#line 1371 "HAL_S.y"
                   { (yyval.closing_) = make_ABclosing((yyvsp[0].label_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7697 "Parser.c"
    break;

  case 567: /* CLOSING: LABEL_DEFINITION CLOSING  */
#line 1372 "HAL_S.y"
                             { (yyval.closing_) = make_ACclosing((yyvsp[-1].label_definition_), (yyvsp[0].closing_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7703 "Parser.c"
    break;

  case 568: /* BLOCK_BODY: DECLARE_GROUP  */
#line 1374 "HAL_S.y"
                           { (yyval.block_body_) = make_ABblock_body((yyvsp[0].declare_group_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7709 "Parser.c"
    break;

  case 569: /* BLOCK_BODY: ANY_STATEMENT  */
#line 1375 "HAL_S.y"
                  { (yyval.block_body_) = make_ADblock_body((yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7715 "Parser.c"
    break;

  case 570: /* BLOCK_BODY: BLOCK_BODY ANY_STATEMENT  */
#line 1376 "HAL_S.y"
                             { (yyval.block_body_) = make_ACblock_body((yyvsp[-1].block_body_), (yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7721 "Parser.c"
    break;

  case 571: /* FUNCTION_NAME: LABEL_EXTERNAL _SYMB_87  */
#line 1378 "HAL_S.y"
                                        { (yyval.function_name_) = make_AAfunction_name((yyvsp[-1].label_external_)); (yyval.function_name_)->line_number = (yyloc).first_line; (yyval.function_name_)->char_number = (yyloc).first_column;  }
#line 7727 "Parser.c"
    break;

  case 572: /* PROCEDURE_NAME: LABEL_EXTERNAL _SYMB_121  */
#line 1380 "HAL_S.y"
                                          { (yyval.procedure_name_) = make_AAprocedure_name((yyvsp[-1].label_external_)); (yyval.procedure_name_)->line_number = (yyloc).first_line; (yyval.procedure_name_)->char_number = (yyloc).first_column;  }
#line 7733 "Parser.c"
    break;

  case 573: /* FUNC_STMT_BODY: PARAMETER_LIST  */
#line 1382 "HAL_S.y"
                                { (yyval.func_stmt_body_) = make_AAfunc_stmt_body((yyvsp[0].parameter_list_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7739 "Parser.c"
    break;

  case 574: /* FUNC_STMT_BODY: TYPE_SPEC  */
#line 1383 "HAL_S.y"
              { (yyval.func_stmt_body_) = make_ABfunc_stmt_body((yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7745 "Parser.c"
    break;

  case 575: /* FUNC_STMT_BODY: PARAMETER_LIST TYPE_SPEC  */
#line 1384 "HAL_S.y"
                             { (yyval.func_stmt_body_) = make_ACfunc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7751 "Parser.c"
    break;

  case 576: /* PROC_STMT_BODY: PARAMETER_LIST  */
#line 1386 "HAL_S.y"
                                { (yyval.proc_stmt_body_) = make_AAproc_stmt_body((yyvsp[0].parameter_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7757 "Parser.c"
    break;

  case 577: /* PROC_STMT_BODY: ASSIGN_LIST  */
#line 1387 "HAL_S.y"
                { (yyval.proc_stmt_body_) = make_ABproc_stmt_body((yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7763 "Parser.c"
    break;

  case 578: /* PROC_STMT_BODY: PARAMETER_LIST ASSIGN_LIST  */
#line 1388 "HAL_S.y"
                               { (yyval.proc_stmt_body_) = make_ACproc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7769 "Parser.c"
    break;

  case 579: /* DECLARE_GROUP: DECLARE_ELEMENT  */
#line 1390 "HAL_S.y"
                                { (yyval.declare_group_) = make_AAdeclare_group((yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7775 "Parser.c"
    break;

  case 580: /* DECLARE_GROUP: DECLARE_GROUP DECLARE_ELEMENT  */
#line 1391 "HAL_S.y"
                                  { (yyval.declare_group_) = make_ABdeclare_group((yyvsp[-1].declare_group_), (yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7781 "Parser.c"
    break;

  case 581: /* DECLARE_ELEMENT: DECLARE_STATEMENT  */
#line 1393 "HAL_S.y"
                                    { (yyval.declare_element_) = make_AAdeclareElementDeclare((yyvsp[0].declare_statement_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7787 "Parser.c"
    break;

  case 582: /* DECLARE_ELEMENT: REPLACE_STMT _SYMB_17  */
#line 1394 "HAL_S.y"
                          { (yyval.declare_element_) = make_ABdeclareElementReplace((yyvsp[-1].replace_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7793 "Parser.c"
    break;

  case 583: /* DECLARE_ELEMENT: STRUCTURE_STMT  */
#line 1395 "HAL_S.y"
                   { (yyval.declare_element_) = make_ACdeclareElementStructure((yyvsp[0].structure_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7799 "Parser.c"
    break;

  case 584: /* DECLARE_ELEMENT: _SYMB_73 _SYMB_82 IDENTIFIER _SYMB_166 VARIABLE _SYMB_17  */
#line 1396 "HAL_S.y"
                                                             { (yyval.declare_element_) = make_ADdeclareElementEquate((yyvsp[-3].identifier_), (yyvsp[-1].variable_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7805 "Parser.c"
    break;

  case 585: /* PARAMETER: _SYMB_192  */
#line 1398 "HAL_S.y"
                      { (yyval.parameter_) = make_AAparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7811 "Parser.c"
    break;

  case 586: /* PARAMETER: _SYMB_183  */
#line 1399 "HAL_S.y"
              { (yyval.parameter_) = make_ABparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7817 "Parser.c"
    break;

  case 587: /* PARAMETER: _SYMB_186  */
#line 1400 "HAL_S.y"
              { (yyval.parameter_) = make_ACparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7823 "Parser.c"
    break;

  case 588: /* PARAMETER: _SYMB_187  */
#line 1401 "HAL_S.y"
              { (yyval.parameter_) = make_ADparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7829 "Parser.c"
    break;

  case 589: /* PARAMETER: _SYMB_190  */
#line 1402 "HAL_S.y"
              { (yyval.parameter_) = make_AEparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7835 "Parser.c"
    break;

  case 590: /* PARAMETER: _SYMB_189  */
#line 1403 "HAL_S.y"
              { (yyval.parameter_) = make_AFparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7841 "Parser.c"
    break;

  case 591: /* PARAMETER_LIST: PARAMETER_HEAD PARAMETER _SYMB_1  */
#line 1405 "HAL_S.y"
                                                  { (yyval.parameter_list_) = make_AAparameter_list((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_list_)->line_number = (yyloc).first_line; (yyval.parameter_list_)->char_number = (yyloc).first_column;  }
#line 7847 "Parser.c"
    break;

  case 592: /* PARAMETER_HEAD: _SYMB_2  */
#line 1407 "HAL_S.y"
                         { (yyval.parameter_head_) = make_AAparameter_head(); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 7853 "Parser.c"
    break;

  case 593: /* PARAMETER_HEAD: PARAMETER_HEAD PARAMETER _SYMB_0  */
#line 1408 "HAL_S.y"
                                     { (yyval.parameter_head_) = make_ABparameter_head((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 7859 "Parser.c"
    break;

  case 594: /* DECLARE_STATEMENT: _SYMB_64 DECLARE_BODY _SYMB_17  */
#line 1410 "HAL_S.y"
                                                   { (yyval.declare_statement_) = make_AAdeclare_statement((yyvsp[-1].declare_body_)); (yyval.declare_statement_)->line_number = (yyloc).first_line; (yyval.declare_statement_)->char_number = (yyloc).first_column;  }
#line 7865 "Parser.c"
    break;

  case 595: /* ASSIGN_LIST: ASSIGN PARAMETER_LIST  */
#line 1412 "HAL_S.y"
                                    { (yyval.assign_list_) = make_AAassign_list((yyvsp[-1].assign_), (yyvsp[0].parameter_list_)); (yyval.assign_list_)->line_number = (yyloc).first_line; (yyval.assign_list_)->char_number = (yyloc).first_column;  }
#line 7871 "Parser.c"
    break;

  case 596: /* TEXT: _SYMB_194  */
#line 1414 "HAL_S.y"
                 { (yyval.text_) = make_FQtext((yyvsp[0].string_)); (yyval.text_)->line_number = (yyloc).first_line; (yyval.text_)->char_number = (yyloc).first_column;  }
#line 7877 "Parser.c"
    break;

  case 597: /* REPLACE_STMT: _SYMB_132 REPLACE_HEAD _SYMB_47 TEXT  */
#line 1416 "HAL_S.y"
                                                    { (yyval.replace_stmt_) = make_AAreplace_stmt((yyvsp[-2].replace_head_), (yyvsp[0].text_)); (yyval.replace_stmt_)->line_number = (yyloc).first_line; (yyval.replace_stmt_)->char_number = (yyloc).first_column;  }
#line 7883 "Parser.c"
    break;

  case 598: /* REPLACE_HEAD: IDENTIFIER  */
#line 1418 "HAL_S.y"
                          { (yyval.replace_head_) = make_AAreplace_head((yyvsp[0].identifier_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 7889 "Parser.c"
    break;

  case 599: /* REPLACE_HEAD: IDENTIFIER _SYMB_2 ARG_LIST _SYMB_1  */
#line 1419 "HAL_S.y"
                                        { (yyval.replace_head_) = make_ABreplace_head((yyvsp[-3].identifier_), (yyvsp[-1].arg_list_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 7895 "Parser.c"
    break;

  case 600: /* ARG_LIST: IDENTIFIER  */
#line 1421 "HAL_S.y"
                      { (yyval.arg_list_) = make_AAarg_list((yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 7901 "Parser.c"
    break;

  case 601: /* ARG_LIST: ARG_LIST _SYMB_0 IDENTIFIER  */
#line 1422 "HAL_S.y"
                                { (yyval.arg_list_) = make_ABarg_list((yyvsp[-2].arg_list_), (yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 7907 "Parser.c"
    break;

  case 602: /* STRUCTURE_STMT: _SYMB_155 STRUCT_STMT_HEAD STRUCT_STMT_TAIL  */
#line 1424 "HAL_S.y"
                                                             { (yyval.structure_stmt_) = make_AAstructure_stmt((yyvsp[-1].struct_stmt_head_), (yyvsp[0].struct_stmt_tail_)); (yyval.structure_stmt_)->line_number = (yyloc).first_line; (yyval.structure_stmt_)->char_number = (yyloc).first_column;  }
#line 7913 "Parser.c"
    break;

  case 603: /* STRUCT_STMT_HEAD: STRUCTURE_ID _SYMB_18 LEVEL  */
#line 1426 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_AAstruct_stmt_head((yyvsp[-2].structure_id_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7919 "Parser.c"
    break;

  case 604: /* STRUCT_STMT_HEAD: STRUCTURE_ID MINOR_ATTR_LIST _SYMB_18 LEVEL  */
#line 1427 "HAL_S.y"
                                                { (yyval.struct_stmt_head_) = make_ABstruct_stmt_head((yyvsp[-3].structure_id_), (yyvsp[-2].minor_attr_list_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7925 "Parser.c"
    break;

  case 605: /* STRUCT_STMT_HEAD: STRUCT_STMT_HEAD DECLARATION _SYMB_0 LEVEL  */
#line 1428 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_ACstruct_stmt_head((yyvsp[-3].struct_stmt_head_), (yyvsp[-2].declaration_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7931 "Parser.c"
    break;

  case 606: /* STRUCT_STMT_TAIL: DECLARATION _SYMB_17  */
#line 1430 "HAL_S.y"
                                        { (yyval.struct_stmt_tail_) = make_AAstruct_stmt_tail((yyvsp[-1].declaration_)); (yyval.struct_stmt_tail_)->line_number = (yyloc).first_line; (yyval.struct_stmt_tail_)->char_number = (yyloc).first_column;  }
#line 7937 "Parser.c"
    break;

  case 607: /* INLINE_DEFINITION: ARITH_INLINE  */
#line 1432 "HAL_S.y"
                                 { (yyval.inline_definition_) = make_AAinline_definition((yyvsp[0].arith_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7943 "Parser.c"
    break;

  case 608: /* INLINE_DEFINITION: BIT_INLINE  */
#line 1433 "HAL_S.y"
               { (yyval.inline_definition_) = make_ABinline_definition((yyvsp[0].bit_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7949 "Parser.c"
    break;

  case 609: /* INLINE_DEFINITION: CHAR_INLINE  */
#line 1434 "HAL_S.y"
                { (yyval.inline_definition_) = make_ACinline_definition((yyvsp[0].char_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7955 "Parser.c"
    break;

  case 610: /* INLINE_DEFINITION: STRUCTURE_EXP  */
#line 1435 "HAL_S.y"
                  { (yyval.inline_definition_) = make_ADinline_definition((yyvsp[0].structure_exp_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7961 "Parser.c"
    break;

  case 611: /* ARITH_INLINE: ARITH_INLINE_DEF CLOSING _SYMB_17  */
#line 1437 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_ACprimary((yyvsp[-2].arith_inline_def_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 7967 "Parser.c"
    break;

  case 612: /* ARITH_INLINE: ARITH_INLINE_DEF BLOCK_BODY CLOSING _SYMB_17  */
#line 1438 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_AZprimary((yyvsp[-3].arith_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 7973 "Parser.c"
    break;

  case 613: /* ARITH_INLINE_DEF: _SYMB_87 ARITH_SPEC _SYMB_17  */
#line 1440 "HAL_S.y"
                                                { (yyval.arith_inline_def_) = make_AAarith_inline_def((yyvsp[-1].arith_spec_)); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 7979 "Parser.c"
    break;

  case 614: /* ARITH_INLINE_DEF: _SYMB_87 _SYMB_17  */
#line 1441 "HAL_S.y"
                      { (yyval.arith_inline_def_) = make_ABarith_inline_def(); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 7985 "Parser.c"
    break;

  case 615: /* BIT_INLINE: BIT_INLINE_DEF CLOSING _SYMB_17  */
#line 1443 "HAL_S.y"
                                             { (yyval.bit_inline_) = make_AGbit_prim((yyvsp[-2].bit_inline_def_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 7991 "Parser.c"
    break;

  case 616: /* BIT_INLINE: BIT_INLINE_DEF BLOCK_BODY CLOSING _SYMB_17  */
#line 1444 "HAL_S.y"
                                               { (yyval.bit_inline_) = make_AZbit_prim((yyvsp[-3].bit_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 7997 "Parser.c"
    break;

  case 617: /* BIT_INLINE_DEF: _SYMB_87 BIT_SPEC _SYMB_17  */
#line 1446 "HAL_S.y"
                                            { (yyval.bit_inline_def_) = make_AAbit_inline_def((yyvsp[-1].bit_spec_)); (yyval.bit_inline_def_)->line_number = (yyloc).first_line; (yyval.bit_inline_def_)->char_number = (yyloc).first_column;  }
#line 8003 "Parser.c"
    break;

  case 618: /* CHAR_INLINE: CHAR_INLINE_DEF CLOSING _SYMB_17  */
#line 1448 "HAL_S.y"
                                               { (yyval.char_inline_) = make_ADchar_prim((yyvsp[-2].char_inline_def_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 8009 "Parser.c"
    break;

  case 619: /* CHAR_INLINE: CHAR_INLINE_DEF BLOCK_BODY CLOSING _SYMB_17  */
#line 1449 "HAL_S.y"
                                                { (yyval.char_inline_) = make_AZchar_prim((yyvsp[-3].char_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 8015 "Parser.c"
    break;

  case 620: /* CHAR_INLINE_DEF: _SYMB_87 CHAR_SPEC _SYMB_17  */
#line 1451 "HAL_S.y"
                                              { (yyval.char_inline_def_) = make_AAchar_inline_def((yyvsp[-1].char_spec_)); (yyval.char_inline_def_)->line_number = (yyloc).first_line; (yyval.char_inline_def_)->char_number = (yyloc).first_column;  }
#line 8021 "Parser.c"
    break;

  case 621: /* STRUC_INLINE_DEF: _SYMB_87 STRUCT_SPEC _SYMB_17  */
#line 1453 "HAL_S.y"
                                                 { (yyval.struc_inline_def_) = make_AAstruc_inline_def((yyvsp[-1].struct_spec_)); (yyval.struc_inline_def_)->line_number = (yyloc).first_line; (yyval.struc_inline_def_)->char_number = (yyloc).first_column;  }
#line 8027 "Parser.c"
    break;


#line 8031 "Parser.c"

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

#line 1456 "HAL_S.y"

void yyerror(const char *str)
{
  extern char *HAL_Stext;
  fprintf(stderr,"error: %d,%d: %s at %s\n",
  HAL_Slloc.first_line, HAL_Slloc.first_column, str, HAL_Stext);
}

