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
    _SYMB_200 = 459,               /* _SYMB_200  */
    _SYMB_201 = 460                /* _SYMB_201  */
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


#line 578 "Parser.c"

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
  YYSYMBOL__SYMB_201 = 205,                /* _SYMB_201  */
  YYSYMBOL_YYACCEPT = 206,                 /* $accept  */
  YYSYMBOL_DECLARE_BODY = 207,             /* DECLARE_BODY  */
  YYSYMBOL_ATTRIBUTES = 208,               /* ATTRIBUTES  */
  YYSYMBOL_DECLARATION = 209,              /* DECLARATION  */
  YYSYMBOL_ARRAY_SPEC = 210,               /* ARRAY_SPEC  */
  YYSYMBOL_TYPE_AND_MINOR_ATTR = 211,      /* TYPE_AND_MINOR_ATTR  */
  YYSYMBOL_IDENTIFIER = 212,               /* IDENTIFIER  */
  YYSYMBOL_SQ_DQ_NAME = 213,               /* SQ_DQ_NAME  */
  YYSYMBOL_DOUBLY_QUAL_NAME_HEAD = 214,    /* DOUBLY_QUAL_NAME_HEAD  */
  YYSYMBOL_ARITH_CONV = 215,               /* ARITH_CONV  */
  YYSYMBOL_DECLARATION_LIST = 216,         /* DECLARATION_LIST  */
  YYSYMBOL_NAME_ID = 217,                  /* NAME_ID  */
  YYSYMBOL_ARITH_EXP = 218,                /* ARITH_EXP  */
  YYSYMBOL_TERM = 219,                     /* TERM  */
  YYSYMBOL_PLUS = 220,                     /* PLUS  */
  YYSYMBOL_MINUS = 221,                    /* MINUS  */
  YYSYMBOL_PRODUCT = 222,                  /* PRODUCT  */
  YYSYMBOL_FACTOR = 223,                   /* FACTOR  */
  YYSYMBOL_EXPONENTIATION = 224,           /* EXPONENTIATION  */
  YYSYMBOL_PRIMARY = 225,                  /* PRIMARY  */
  YYSYMBOL_ARITH_VAR = 226,                /* ARITH_VAR  */
  YYSYMBOL_PRE_PRIMARY = 227,              /* PRE_PRIMARY  */
  YYSYMBOL_NUMBER = 228,                   /* NUMBER  */
  YYSYMBOL_LEVEL = 229,                    /* LEVEL  */
  YYSYMBOL_COMPOUND_NUMBER = 230,          /* COMPOUND_NUMBER  */
  YYSYMBOL_SIMPLE_NUMBER = 231,            /* SIMPLE_NUMBER  */
  YYSYMBOL_MODIFIED_ARITH_FUNC = 232,      /* MODIFIED_ARITH_FUNC  */
  YYSYMBOL_SHAPING_HEAD = 233,             /* SHAPING_HEAD  */
  YYSYMBOL_CALL_LIST = 234,                /* CALL_LIST  */
  YYSYMBOL_LIST_EXP = 235,                 /* LIST_EXP  */
  YYSYMBOL_EXPRESSION = 236,               /* EXPRESSION  */
  YYSYMBOL_ARITH_ID = 237,                 /* ARITH_ID  */
  YYSYMBOL_NO_ARG_ARITH_FUNC = 238,        /* NO_ARG_ARITH_FUNC  */
  YYSYMBOL_ARITH_FUNC = 239,               /* ARITH_FUNC  */
  YYSYMBOL_SUBSCRIPT = 240,                /* SUBSCRIPT  */
  YYSYMBOL_QUALIFIER = 241,                /* QUALIFIER  */
  YYSYMBOL_SCALE_HEAD = 242,               /* SCALE_HEAD  */
  YYSYMBOL_PREC_SPEC = 243,                /* PREC_SPEC  */
  YYSYMBOL_SUB_START = 244,                /* SUB_START  */
  YYSYMBOL_SUB_HEAD = 245,                 /* SUB_HEAD  */
  YYSYMBOL_SUB = 246,                      /* SUB  */
  YYSYMBOL_SUB_RUN_HEAD = 247,             /* SUB_RUN_HEAD  */
  YYSYMBOL_SUB_EXP = 248,                  /* SUB_EXP  */
  YYSYMBOL_POUND_EXPRESSION = 249,         /* POUND_EXPRESSION  */
  YYSYMBOL_BIT_EXP = 250,                  /* BIT_EXP  */
  YYSYMBOL_BIT_FACTOR = 251,               /* BIT_FACTOR  */
  YYSYMBOL_BIT_CAT = 252,                  /* BIT_CAT  */
  YYSYMBOL_OR = 253,                       /* OR  */
  YYSYMBOL_CHAR_VERTICAL_BAR = 254,        /* CHAR_VERTICAL_BAR  */
  YYSYMBOL_AND = 255,                      /* AND  */
  YYSYMBOL_BIT_PRIM = 256,                 /* BIT_PRIM  */
  YYSYMBOL_CAT = 257,                      /* CAT  */
  YYSYMBOL_NOT = 258,                      /* NOT  */
  YYSYMBOL_BIT_VAR = 259,                  /* BIT_VAR  */
  YYSYMBOL_LABEL_VAR = 260,                /* LABEL_VAR  */
  YYSYMBOL_EVENT_VAR = 261,                /* EVENT_VAR  */
  YYSYMBOL_BIT_CONST_HEAD = 262,           /* BIT_CONST_HEAD  */
  YYSYMBOL_BIT_CONST = 263,                /* BIT_CONST  */
  YYSYMBOL_RADIX = 264,                    /* RADIX  */
  YYSYMBOL_CHAR_STRING = 265,              /* CHAR_STRING  */
  YYSYMBOL_SUBBIT_HEAD = 266,              /* SUBBIT_HEAD  */
  YYSYMBOL_SUBBIT_KEY = 267,               /* SUBBIT_KEY  */
  YYSYMBOL_BIT_FUNC_HEAD = 268,            /* BIT_FUNC_HEAD  */
  YYSYMBOL_BIT_ID = 269,                   /* BIT_ID  */
  YYSYMBOL_LABEL = 270,                    /* LABEL  */
  YYSYMBOL_BIT_FUNC = 271,                 /* BIT_FUNC  */
  YYSYMBOL_EVENT = 272,                    /* EVENT  */
  YYSYMBOL_SUB_OR_QUALIFIER = 273,         /* SUB_OR_QUALIFIER  */
  YYSYMBOL_BIT_QUALIFIER = 274,            /* BIT_QUALIFIER  */
  YYSYMBOL_CHAR_EXP = 275,                 /* CHAR_EXP  */
  YYSYMBOL_CHAR_PRIM = 276,                /* CHAR_PRIM  */
  YYSYMBOL_CHAR_FUNC_HEAD = 277,           /* CHAR_FUNC_HEAD  */
  YYSYMBOL_CHAR_VAR = 278,                 /* CHAR_VAR  */
  YYSYMBOL_CHAR_CONST = 279,               /* CHAR_CONST  */
  YYSYMBOL_CHAR_FUNC = 280,                /* CHAR_FUNC  */
  YYSYMBOL_CHAR_ID = 281,                  /* CHAR_ID  */
  YYSYMBOL_NAME_EXP = 282,                 /* NAME_EXP  */
  YYSYMBOL_NAME_KEY = 283,                 /* NAME_KEY  */
  YYSYMBOL_NAME_VAR = 284,                 /* NAME_VAR  */
  YYSYMBOL_VARIABLE = 285,                 /* VARIABLE  */
  YYSYMBOL_STRUCTURE_EXP = 286,            /* STRUCTURE_EXP  */
  YYSYMBOL_STRUCT_FUNC_HEAD = 287,         /* STRUCT_FUNC_HEAD  */
  YYSYMBOL_STRUCTURE_VAR = 288,            /* STRUCTURE_VAR  */
  YYSYMBOL_STRUCT_FUNC = 289,              /* STRUCT_FUNC  */
  YYSYMBOL_QUAL_STRUCT = 290,              /* QUAL_STRUCT  */
  YYSYMBOL_STRUCTURE_ID = 291,             /* STRUCTURE_ID  */
  YYSYMBOL_ASSIGNMENT = 292,               /* ASSIGNMENT  */
  YYSYMBOL_EQUALS = 293,                   /* EQUALS  */
  YYSYMBOL_STATEMENT = 294,                /* STATEMENT  */
  YYSYMBOL_BASIC_STATEMENT = 295,          /* BASIC_STATEMENT  */
  YYSYMBOL_OTHER_STATEMENT = 296,          /* OTHER_STATEMENT  */
  YYSYMBOL_IF_STATEMENT = 297,             /* IF_STATEMENT  */
  YYSYMBOL_IF_CLAUSE = 298,                /* IF_CLAUSE  */
  YYSYMBOL_TRUE_PART = 299,                /* TRUE_PART  */
  YYSYMBOL_IF = 300,                       /* IF  */
  YYSYMBOL_THEN = 301,                     /* THEN  */
  YYSYMBOL_RELATIONAL_EXP = 302,           /* RELATIONAL_EXP  */
  YYSYMBOL_RELATIONAL_FACTOR = 303,        /* RELATIONAL_FACTOR  */
  YYSYMBOL_REL_PRIM = 304,                 /* REL_PRIM  */
  YYSYMBOL_COMPARISON = 305,               /* COMPARISON  */
  YYSYMBOL_ANY_STATEMENT = 306,            /* ANY_STATEMENT  */
  YYSYMBOL_ON_PHRASE = 307,                /* ON_PHRASE  */
  YYSYMBOL_ON_CLAUSE = 308,                /* ON_CLAUSE  */
  YYSYMBOL_LABEL_DEFINITION = 309,         /* LABEL_DEFINITION  */
  YYSYMBOL_CALL_KEY = 310,                 /* CALL_KEY  */
  YYSYMBOL_ASSIGN = 311,                   /* ASSIGN  */
  YYSYMBOL_CALL_ASSIGN_LIST = 312,         /* CALL_ASSIGN_LIST  */
  YYSYMBOL_DO_GROUP_HEAD = 313,            /* DO_GROUP_HEAD  */
  YYSYMBOL_ENDING = 314,                   /* ENDING  */
  YYSYMBOL_READ_KEY = 315,                 /* READ_KEY  */
  YYSYMBOL_WRITE_KEY = 316,                /* WRITE_KEY  */
  YYSYMBOL_READ_PHRASE = 317,              /* READ_PHRASE  */
  YYSYMBOL_WRITE_PHRASE = 318,             /* WRITE_PHRASE  */
  YYSYMBOL_READ_ARG = 319,                 /* READ_ARG  */
  YYSYMBOL_WRITE_ARG = 320,                /* WRITE_ARG  */
  YYSYMBOL_FILE_EXP = 321,                 /* FILE_EXP  */
  YYSYMBOL_FILE_HEAD = 322,                /* FILE_HEAD  */
  YYSYMBOL_IO_CONTROL = 323,               /* IO_CONTROL  */
  YYSYMBOL_WAIT_KEY = 324,                 /* WAIT_KEY  */
  YYSYMBOL_TERMINATOR = 325,               /* TERMINATOR  */
  YYSYMBOL_TERMINATE_LIST = 326,           /* TERMINATE_LIST  */
  YYSYMBOL_SCHEDULE_HEAD = 327,            /* SCHEDULE_HEAD  */
  YYSYMBOL_SCHEDULE_PHRASE = 328,          /* SCHEDULE_PHRASE  */
  YYSYMBOL_SCHEDULE_CONTROL = 329,         /* SCHEDULE_CONTROL  */
  YYSYMBOL_TIMING = 330,                   /* TIMING  */
  YYSYMBOL_REPEAT = 331,                   /* REPEAT  */
  YYSYMBOL_STOPPING = 332,                 /* STOPPING  */
  YYSYMBOL_SIGNAL_CLAUSE = 333,            /* SIGNAL_CLAUSE  */
  YYSYMBOL_PERCENT_MACRO_NAME = 334,       /* PERCENT_MACRO_NAME  */
  YYSYMBOL_PERCENT_MACRO_HEAD = 335,       /* PERCENT_MACRO_HEAD  */
  YYSYMBOL_PERCENT_MACRO_ARG = 336,        /* PERCENT_MACRO_ARG  */
  YYSYMBOL_CASE_ELSE = 337,                /* CASE_ELSE  */
  YYSYMBOL_WHILE_KEY = 338,                /* WHILE_KEY  */
  YYSYMBOL_WHILE_CLAUSE = 339,             /* WHILE_CLAUSE  */
  YYSYMBOL_FOR_LIST = 340,                 /* FOR_LIST  */
  YYSYMBOL_ITERATION_BODY = 341,           /* ITERATION_BODY  */
  YYSYMBOL_ITERATION_CONTROL = 342,        /* ITERATION_CONTROL  */
  YYSYMBOL_FOR_KEY = 343,                  /* FOR_KEY  */
  YYSYMBOL_TEMPORARY_STMT = 344,           /* TEMPORARY_STMT  */
  YYSYMBOL_CONSTANT = 345,                 /* CONSTANT  */
  YYSYMBOL_ARRAY_HEAD = 346,               /* ARRAY_HEAD  */
  YYSYMBOL_MINOR_ATTR_LIST = 347,          /* MINOR_ATTR_LIST  */
  YYSYMBOL_MINOR_ATTRIBUTE = 348,          /* MINOR_ATTRIBUTE  */
  YYSYMBOL_INIT_OR_CONST_HEAD = 349,       /* INIT_OR_CONST_HEAD  */
  YYSYMBOL_REPEATED_CONSTANT = 350,        /* REPEATED_CONSTANT  */
  YYSYMBOL_REPEAT_HEAD = 351,              /* REPEAT_HEAD  */
  YYSYMBOL_NESTED_REPEAT_HEAD = 352,       /* NESTED_REPEAT_HEAD  */
  YYSYMBOL_DCL_LIST_COMMA = 353,           /* DCL_LIST_COMMA  */
  YYSYMBOL_LITERAL_EXP_OR_STAR = 354,      /* LITERAL_EXP_OR_STAR  */
  YYSYMBOL_TYPE_SPEC = 355,                /* TYPE_SPEC  */
  YYSYMBOL_BIT_SPEC = 356,                 /* BIT_SPEC  */
  YYSYMBOL_CHAR_SPEC = 357,                /* CHAR_SPEC  */
  YYSYMBOL_STRUCT_SPEC = 358,              /* STRUCT_SPEC  */
  YYSYMBOL_STRUCT_SPEC_BODY = 359,         /* STRUCT_SPEC_BODY  */
  YYSYMBOL_STRUCT_TEMPLATE = 360,          /* STRUCT_TEMPLATE  */
  YYSYMBOL_STRUCT_SPEC_HEAD = 361,         /* STRUCT_SPEC_HEAD  */
  YYSYMBOL_ARITH_SPEC = 362,               /* ARITH_SPEC  */
  YYSYMBOL_COMPILATION = 363,              /* COMPILATION  */
  YYSYMBOL_BLOCK_DEFINITION = 364,         /* BLOCK_DEFINITION  */
  YYSYMBOL_BLOCK_STMT = 365,               /* BLOCK_STMT  */
  YYSYMBOL_BLOCK_STMT_TOP = 366,           /* BLOCK_STMT_TOP  */
  YYSYMBOL_BLOCK_STMT_HEAD = 367,          /* BLOCK_STMT_HEAD  */
  YYSYMBOL_LABEL_EXTERNAL = 368,           /* LABEL_EXTERNAL  */
  YYSYMBOL_CLOSING = 369,                  /* CLOSING  */
  YYSYMBOL_BLOCK_BODY = 370,               /* BLOCK_BODY  */
  YYSYMBOL_FUNCTION_NAME = 371,            /* FUNCTION_NAME  */
  YYSYMBOL_PROCEDURE_NAME = 372,           /* PROCEDURE_NAME  */
  YYSYMBOL_FUNC_STMT_BODY = 373,           /* FUNC_STMT_BODY  */
  YYSYMBOL_PROC_STMT_BODY = 374,           /* PROC_STMT_BODY  */
  YYSYMBOL_DECLARE_GROUP = 375,            /* DECLARE_GROUP  */
  YYSYMBOL_DECLARE_ELEMENT = 376,          /* DECLARE_ELEMENT  */
  YYSYMBOL_PARAMETER = 377,                /* PARAMETER  */
  YYSYMBOL_PARAMETER_LIST = 378,           /* PARAMETER_LIST  */
  YYSYMBOL_PARAMETER_HEAD = 379,           /* PARAMETER_HEAD  */
  YYSYMBOL_DECLARE_STATEMENT = 380,        /* DECLARE_STATEMENT  */
  YYSYMBOL_ASSIGN_LIST = 381,              /* ASSIGN_LIST  */
  YYSYMBOL_TEXT = 382,                     /* TEXT  */
  YYSYMBOL_REPLACE_STMT = 383,             /* REPLACE_STMT  */
  YYSYMBOL_REPLACE_HEAD = 384,             /* REPLACE_HEAD  */
  YYSYMBOL_ARG_LIST = 385,                 /* ARG_LIST  */
  YYSYMBOL_STRUCTURE_STMT = 386,           /* STRUCTURE_STMT  */
  YYSYMBOL_STRUCT_STMT_HEAD = 387,         /* STRUCT_STMT_HEAD  */
  YYSYMBOL_STRUCT_STMT_TAIL = 388,         /* STRUCT_STMT_TAIL  */
  YYSYMBOL_INLINE_DEFINITION = 389,        /* INLINE_DEFINITION  */
  YYSYMBOL_ARITH_INLINE = 390,             /* ARITH_INLINE  */
  YYSYMBOL_ARITH_INLINE_DEF = 391,         /* ARITH_INLINE_DEF  */
  YYSYMBOL_BIT_INLINE = 392,               /* BIT_INLINE  */
  YYSYMBOL_BIT_INLINE_DEF = 393,           /* BIT_INLINE_DEF  */
  YYSYMBOL_CHAR_INLINE = 394,              /* CHAR_INLINE  */
  YYSYMBOL_CHAR_INLINE_DEF = 395,          /* CHAR_INLINE_DEF  */
  YYSYMBOL_STRUC_INLINE_DEF = 396          /* STRUC_INLINE_DEF  */
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
#define YYFINAL  473
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   8564

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  206
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  191
/* YYNRULES -- Number of rules.  */
#define YYNRULES  636
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  1087

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   460


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
     195,   196,   197,   198,   199,   200,   201,   202,   203,   204,
     205
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,   649,   649,   650,   652,   653,   654,   656,   657,   658,
     659,   660,   661,   662,   663,   664,   665,   666,   667,   668,
     669,   671,   672,   673,   674,   675,   677,   678,   679,   681,
     683,   684,   686,   687,   689,   690,   691,   692,   694,   695,
     697,   698,   699,   700,   701,   702,   703,   704,   706,   707,
     708,   709,   710,   712,   713,   715,   717,   719,   720,   721,
     722,   724,   725,   726,   728,   730,   731,   732,   733,   735,
     736,   737,   738,   739,   740,   741,   742,   744,   745,   746,
     747,   748,   749,   750,   751,   752,   754,   755,   757,   759,
     761,   763,   764,   765,   766,   768,   769,   770,   771,   772,
     773,   774,   775,   776,   778,   779,   781,   782,   783,   785,
     786,   787,   788,   789,   791,   792,   794,   795,   796,   797,
     798,   799,   800,   801,   802,   804,   805,   806,   807,   808,
     809,   810,   811,   812,   813,   814,   815,   816,   817,   818,
     819,   820,   821,   822,   823,   824,   825,   826,   827,   828,
     829,   830,   831,   832,   833,   834,   835,   836,   837,   838,
     839,   840,   841,   842,   843,   844,   845,   846,   847,   849,
     850,   851,   852,   854,   855,   856,   857,   859,   860,   862,
     863,   865,   866,   867,   868,   869,   871,   872,   874,   875,
     876,   877,   879,   881,   882,   884,   885,   886,   888,   889,
     891,   892,   894,   895,   896,   897,   899,   900,   902,   904,
     905,   907,   908,   909,   910,   911,   912,   913,   914,   915,
     916,   917,   918,   920,   921,   923,   924,   926,   927,   928,
     929,   931,   932,   933,   934,   936,   937,   938,   939,   941,
     942,   944,   945,   946,   947,   948,   950,   951,   952,   953,
     955,   957,   958,   960,   962,   963,   964,   966,   968,   969,
     970,   971,   973,   974,   976,   978,   979,   981,   983,   984,
     985,   986,   987,   989,   990,   991,   992,   994,   995,   997,
     998,   999,  1000,  1002,  1003,  1005,  1006,  1007,  1008,  1009,
    1011,  1013,  1014,  1015,  1017,  1019,  1020,  1021,  1023,  1024,
    1025,  1026,  1027,  1028,  1029,  1031,  1032,  1033,  1034,  1036,
    1038,  1040,  1042,  1043,  1045,  1047,  1048,  1049,  1050,  1052,
    1054,  1055,  1056,  1058,  1059,  1060,  1061,  1062,  1063,  1064,
    1065,  1066,  1067,  1068,  1069,  1070,  1071,  1072,  1073,  1074,
    1075,  1076,  1077,  1078,  1079,  1080,  1081,  1082,  1083,  1084,
    1085,  1086,  1087,  1088,  1089,  1090,  1091,  1092,  1093,  1094,
    1095,  1096,  1097,  1098,  1100,  1101,  1102,  1104,  1105,  1107,
    1108,  1110,  1112,  1114,  1116,  1117,  1119,  1120,  1122,  1123,
    1124,  1126,  1127,  1128,  1129,  1130,  1131,  1132,  1133,  1134,
    1135,  1136,  1137,  1138,  1139,  1140,  1141,  1142,  1143,  1144,
    1145,  1146,  1147,  1148,  1149,  1150,  1151,  1152,  1153,  1154,
    1155,  1157,  1158,  1160,  1161,  1163,  1164,  1165,  1166,  1168,
    1170,  1172,  1174,  1175,  1176,  1177,  1179,  1180,  1181,  1182,
    1183,  1184,  1185,  1186,  1188,  1189,  1190,  1192,  1193,  1195,
    1197,  1198,  1200,  1201,  1203,  1204,  1206,  1207,  1208,  1210,
    1212,  1214,  1215,  1216,  1217,  1218,  1220,  1222,  1223,  1225,
    1226,  1228,  1229,  1230,  1231,  1233,  1234,  1235,  1237,  1238,
    1239,  1241,  1242,  1243,  1245,  1247,  1248,  1250,  1251,  1252,
    1254,  1256,  1257,  1259,  1260,  1262,  1264,  1265,  1267,  1268,
    1270,  1271,  1273,  1274,  1276,  1277,  1279,  1280,  1282,  1284,
    1285,  1286,  1287,  1289,  1290,  1292,  1293,  1295,  1296,  1297,
    1298,  1299,  1300,  1301,  1302,  1303,  1304,  1305,  1306,  1308,
    1309,  1310,  1312,  1313,  1314,  1315,  1316,  1318,  1320,  1321,
    1323,  1325,  1326,  1328,  1329,  1330,  1331,  1332,  1334,  1335,
    1337,  1339,  1341,  1342,  1344,  1346,  1348,  1349,  1350,  1352,
    1353,  1354,  1355,  1356,  1357,  1358,  1359,  1360,  1362,  1363,
    1365,  1367,  1368,  1369,  1370,  1371,  1373,  1374,  1375,  1376,
    1377,  1378,  1379,  1380,  1381,  1383,  1384,  1386,  1387,  1388,
    1389,  1391,  1392,  1393,  1395,  1396,  1397,  1399,  1401,  1402,
    1403,  1405,  1406,  1407,  1409,  1410,  1412,  1413,  1414,  1415,
    1417,  1418,  1419,  1420,  1421,  1422,  1424,  1426,  1427,  1429,
    1431,  1433,  1435,  1437,  1438,  1440,  1441,  1443,  1445,  1446,
    1447,  1449,  1451,  1452,  1453,  1454,  1456,  1457,  1459,  1460,
    1462,  1463,  1465,  1467,  1468,  1470,  1472
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
  "_SYMB_197", "_SYMB_198", "_SYMB_199", "_SYMB_200", "_SYMB_201",
  "$accept", "DECLARE_BODY", "ATTRIBUTES", "DECLARATION", "ARRAY_SPEC",
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

#define YYPACT_NINF (-779)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-449)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
    6358,    91,  -142,  -779,  -141,   836,  -779,   137,  8048,    57,
      77,   173,  1993,    53,  -779,   249,  -779,   250,   290,   394,
     406,   117,  -141,   151,  2888,   836,   335,   151,   151,  -142,
    -779,  -779,   297,  -779,   427,   433,  -779,  -779,  -779,  -779,
    -779,   464,  -779,  -779,  -779,  -779,  -779,  -779,   472,  -779,
    -779,   918,   116,   472,   457,   472,  -779,   472,   490,   148,
    -779,   501,   268,  -779,   325,  -779,   495,  -779,  -779,  -779,
    -779,  7343,  7343,  3688,  -779,  7343,   299,  7211,   187,  6639,
    1228,  2488,   174,   220,   494,   533,  4688,    33,   197,    37,
     551,   321,  6204,  7343,  3888,  2293,  -779,  6507,    55,   -16,
     316,   962,   100,  -779,   561,  -779,  -779,  -779,  6507,  -779,
    6507,  -779,  6507,  6507,   571,   531,  -779,  -779,  -779,   472,
     573,  -779,  -779,  -779,   590,  -779,   599,  -779,   623,  -779,
    -779,  -779,  -779,  -779,  -779,   628,   630,   637,  -779,  -779,
    -779,  -779,  -779,  -779,  -779,  -779,   639,   560,  -779,  -779,
     644,  -779,  8287,  2027,   652,   672,  -779,  8369,  -779,   574,
      16,  5088,  -779,   677,  8214,  -779,  -779,  -779,  -779,  5088,
    2197,  -779,  3088,  1652,  2197,  -779,  -779,  -779,   686,  -779,
    -779,  5488,    68,  -779,  -779,  3688,   670,   106,  5488,  -779,
     680,   191,  -779,   704,   724,   726,   734,   435,  -779,   431,
      45,   191,   191,  -779,   746,   767,   725,  -779,   769,  4088,
    -779,  -779,   570,  -109,  -779,  -779,  -779,  -779,  -779,  -779,
    -779,  -779,  -779,  -779,  -779,  -779,   466,  -779,   772,   466,
    -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,
    -779,  -779,  -142,  -779,  -779,   227,  -779,  -779,  -779,  -779,
     279,  -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,
    -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,
     450,  -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,
    -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,   502,  -779,
     783,   785,   787,  -779,   793,   795,   798,  -779,  -779,  -779,
    -779,   459,  -779,  5841,  5841,   807,  5665,   598,  -779,   802,
    -779,  -779,  -779,  -779,  -779,   683,   796,   472,   828,    78,
     328,   143,  -779,  6033,  -779,  -779,  -779,   643,  -779,   832,
    -779,  3888,   834,  -779,   143,  -779,   850,  -779,  -779,  -779,
    -779,   855,  -779,  -779,   336,  -779,   519,  -779,  -779,  1570,
    1652,   682,   191,     5,   108,  -779,  -779,  4888,   496,   858,
    -779,   512,  -779,   859,  -779,  -779,  -779,  -779,  7880,   918,
    -779,  3288,  3888,   918,   710,  -779,  3888,  -779,   297,  -779,
     792,  7756,  -779,  3688,  1136,    27,  1250,  6062,  1255,    90,
     277,    27,   328,  -779,  -779,  -779,  -779,   397,  -779,  -779,
     297,  -779,  -779,  3888,  -779,  -779,   863,   435,  8048,  -779,
    6771,   861,  -779,  -779,   882,   901,   907,   909,   911,  -779,
    -779,  -779,  -779,   235,  -779,  -779,  -779,  1810,  -779,  2688,
    -779,  3888,  5488,  5488,  1574,  5488,   798,   440,   881,  -779,
    -779,   320,  5488,  5488,  6004,   913,   790,  -779,  -779,   934,
     420,   105,  -779,  4288,  -779,  -779,  -779,  -779,  -779,  -779,
    -779,  -779,  -779,  -779,  -779,   702,  -779,  -779,   478,   923,
     958,  2018,  3888,  -779,  -779,  -779,   943,  -779,   829,   884,
    -779,  6925,   946,  7079,   180,  -779,  -779,   951,  -779,  -779,
    -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,
    -779,  1366,   806,   968,  -779,   935,  -779,  -779,   964,  7079,
     969,  7079,   974,  7079,   981,  7079,   472,  -142,   472,  -779,
     836,  -779,  5088,  5088,  5088,  5088,   804,  -779,  8369,  8369,
    2197,  -779,  2197,  2197,  -779,  1652,  -779,  -779,  -779,  -779,
     731,  1000,  -779,  -779,   808,  -779,  1004,  -779,   854,  -779,
    -779,  2197,   864,  -779,  5088,   548,  -141,   494,  1030,    78,
      78,  -779,  -779,   994,   145,  1052,  -779,  -779,  -779,  -779,
    -779,  -779,  1028,  -779,  1039,  -779,  -779,   -32,  1063,  1068,
    -779,  -141,   873,   151,   449,    79,   240,  1066,  1074,  1086,
    1061,   543,  1076,  -779,  -779,  -779,   191,  -779,  3888,  1093,
    3888,  1108,  3888,  1114,  3888,  1115,  3888,  3888,  3888,  3888,
    -779,  -779,  5841,  5841,  4488,  -779,  -779,  5841,  5841,  5841,
    -779,  -779,  -779,  5841,  1116,  -779,  3488,  -779,  -779,  -779,
    3888,  -779,  -779,  6004,  -779,  -779,  -779,  6004,  6004,  6004,
    -109,  -109,  -779,  1092,  -779,   191,  1119,  3888,  4488,  3888,
    7780,  5976,  -779,  1104,   804,  2228,   324,  -779,  5488,   957,
    1124,  1041,  -779,  1117,  -779,  -779,  -779,  -779,   272,  -779,
    5288,   965,   731,  -779,  -779,  -779,  -779,  -779,  -779,  1129,
     148,  -779,  -779,  1118,   480,   867,  -779,  -779,   336,  -779,
     472,   472,   472,   472,  -779,  -779,  -779,  1243,   470,   128,
    5488,  5488,  5488,  5488,  5488,  5488,  -779,  -779,  6004,  6004,
    6004,  6004,  6004,  6004,  3688,  4488,  4488,  4488,  4488,  4488,
    4488,   487,   487,   487,   487,   487,   487,   -21,   -21,   -21,
     -21,   -21,   -21,  3688,  -779,  3688,  1125,   898,   918,  -779,
    1126,  7475,  -779,  -779,  5488,  5488,  5488,  5488,  5488,  -779,
    -779,  1127,   491,   569,   749,  1128,    82,   604,  -779,  4620,
     836,  -779,   731,   731,    78,  5488,  -779,  -779,  -779,  5488,
    5488,  4288,   731,    78,  1140,  -779,  1132,  -779,  -779,  -779,
    -779,  -779,  -779,   919,  -779,  -779,  -779,  -141,  7624,  -779,
    -779,  -779,  1134,  -779,  -779,  -779,  -779,  -779,  -779,  -779,
    -779,  -779,   955,  -779,  -779,  -779,  1135,  -779,  1137,  -779,
    1138,  -779,  1141,  -779,  -779,   472,  1133,  1161,  1162,  1165,
    1167,  -779,  -779,  2197,  2197,   677,  -779,  -779,  -779,  -779,
    -779,  1168,  1171,  1065,  1145,  -779,   597,  -779,  5488,  -779,
    5488,  -779,  -779,  -779,  -779,  -779,  -779,  -779,   972,  -779,
    -779,  -779,  -779,  -779,   472,  -109,   472,  1172,  1176,  -779,
    3888,  -779,  3888,  -779,  3888,  -779,  3888,   988,  1009,  1067,
    1078,  -779,  -779,  4488,  -779,   731,  -779,  1166,  -779,  -779,
    -779,  -779,  1163,  1180,  -779,  1080,   328,   143,  -779,  6033,
     754,  1184,  -779,  1082,   731,  -779,  1084,  1185,  1188,   472,
    -779,  -779,   804,   804,  -779,   684,  5488,  -779,  -779,   568,
    5488,  5288,   731,  -779,  -779,  5841,  5841,  -779,  3888,  -779,
    3888,  3888,  -779,  -779,  -779,  -779,  -779,  -779,   731,   731,
     731,   731,   731,   731,   143,   143,   143,   143,   143,   143,
     150,   459,   143,   143,   143,   143,   143,   143,  -779,  -779,
    -779,  -779,  -779,  -779,  -779,  -779,   540,  -779,  -779,  -779,
    -779,  -779,  1250,   328,  -779,  -779,   305,  -779,   512,  1089,
    -779,   777,   840,   876,   931,   933,  -779,  -779,  -779,  -779,
    -779,  -779,  -779,  1029,   731,   731,  6161,  -779,  -779,  -779,
    1025,  -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,
    -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,   141,   731,
    -141,  -779,  -779,  -779,  1177,   643,  -779,  -779,  -779,  -779,
    -779,  -779,  -779,  -779,  1456,   568,  -779,  -779,  -779,  -779,
    -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,   728,  -779,
    1097,  1191,  1037,  -779,  -779,  -779,  -779,  -779,  -779,  -779,
    1192,   918,  1178,  -779,  -779,  -779,  -779,  -779,  -779,   918,
    5488,  -779,   292,  -779,  1102,  -779,  1181,  -779,  -779,  -779,
     918,  -779,   512,  -779,  1182,   731,  1200,  1181,  1189,  5488,
    1106,  -779,  -779,  1045,  1194,  -779,  -779
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int16 yydefact[] =
{
       0,     0,     0,   330,     0,     0,   458,     0,     0,     0,
       0,     0,     0,     0,   372,     0,   294,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     253,   457,   570,   456,     0,     0,   257,   259,   260,   290,
     314,   261,   258,   264,   115,    29,   114,   298,    69,   299,
     303,     0,     0,   227,     0,   235,   301,   279,     0,     0,
     625,     0,   305,   309,     0,   312,     0,   411,   320,   321,
     364,     0,     0,     0,   549,     0,     0,   575,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   465,     0,
       0,     0,     0,     0,     0,     0,   412,     0,     0,   563,
       0,   571,   573,   551,     0,   553,   322,   622,     0,   623,
       0,   624,     0,     0,     0,     0,   480,   261,   420,   231,
       0,   520,   511,   510,     0,   508,     0,   538,     0,   509,
     180,   537,    22,    34,   517,     0,    37,     0,    23,    24,
     513,   514,    35,   179,   507,    25,    36,     0,    44,    45,
      46,    47,     9,    19,     0,     0,    38,     5,     6,    40,
     547,     0,    31,     2,     7,   546,    42,    43,   544,     0,
      28,   505,     0,     0,    26,   534,   535,   533,     0,   536,
     426,     0,     0,   487,   486,     0,     0,     0,     0,   325,
       0,     0,   629,     0,     0,     0,     0,     0,   519,     0,
     414,     0,     0,   327,     0,   613,     0,   478,     0,     0,
      55,    56,     0,     0,   335,   226,   126,   156,   138,   139,
     140,   141,   143,   142,   144,   248,   255,   127,     0,   289,
     117,   145,   146,   118,   249,   157,   128,   119,   120,   147,
     243,   129,     0,   246,   160,     0,   162,   161,   285,   148,
       0,   167,   130,   168,   131,   125,   225,   292,   247,   132,
     245,   244,   121,   164,   122,   123,   133,   286,   134,   124,
       0,   154,   155,   135,   136,   149,   150,   166,   151,   165,
     152,   153,   158,   163,   287,   242,   137,   159,     0,   262,
       0,     0,     0,   116,   259,   260,   258,   250,    88,    90,
      89,   109,    48,     0,     0,    53,    57,    61,    65,    66,
      78,    87,    79,    86,    67,     0,     0,    91,     0,   110,
     198,   200,   202,     0,   211,   212,   213,     0,   214,   239,
     283,     0,     0,   254,   111,   268,     0,   273,   274,   277,
     112,     0,   113,   305,     0,   461,     0,   477,   479,     0,
       0,     0,     0,     0,     0,    70,   170,   186,     0,     0,
     304,     0,   251,     0,   228,   419,   236,   280,     0,     0,
     319,     0,     0,     0,     0,   310,     0,   323,     0,   367,
     320,     0,   368,     0,     0,     0,   200,     0,     0,     0,
       0,     0,   374,   376,   380,   365,   358,     0,   576,   568,
     569,   324,   366,     0,   331,   421,     0,   434,     0,   432,
     575,     0,   433,   338,     0,     0,     0,     0,     0,   444,
     440,   445,   340,   314,   446,   442,   447,     0,   339,     0,
     341,     0,     0,     0,     0,     0,     0,     0,     0,   349,
     459,     0,     0,     0,     0,     0,     0,   353,   467,     0,
     469,   473,   468,     0,   355,   481,   362,   499,   500,   296,
     297,   501,   502,   483,   295,     0,   484,   431,   109,   522,
       0,   526,     0,     1,   550,   552,     0,   554,   577,     0,
     582,   575,     0,     0,   581,   594,   596,     0,   598,   560,
     561,   562,   564,   565,   567,   584,   587,   566,   607,   589,
     572,   588,     0,     0,   574,   591,   592,   555,     0,     0,
       0,     0,     0,     0,     0,     0,    71,     0,    73,   232,
       0,   503,     0,     0,     0,     0,     0,    32,    16,    15,
      12,    10,    17,    20,   609,     0,     4,    41,   548,   532,
     531,     0,   530,     8,     0,   506,     0,   522,     0,    46,
      39,    27,     0,   541,     0,     0,     0,     0,     0,   488,
     489,   429,   427,     0,   492,   491,   326,   450,   632,   635,
     636,   628,     0,   361,     0,   418,   417,   413,     0,     0,
     328,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   265,   256,   266,     0,   278,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     223,   224,     0,     0,     0,    49,    50,     0,     0,     0,
      60,    63,    64,     0,     0,    68,     0,    83,   336,    92,
       0,   208,   207,     0,   206,   209,   210,     0,     0,     0,
       0,     0,   204,     0,   241,     0,     0,     0,     0,     0,
       0,     0,   357,     0,     0,     0,     0,   617,     0,     0,
       0,     0,   585,   181,   172,   171,   189,   195,   193,   187,
       0,   188,   194,   185,   169,   183,   184,   300,   252,     0,
       0,   316,   315,     0,   109,     0,   104,   106,   108,   318,
      75,   229,   237,   281,   313,   317,   371,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   373,   370,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   369,     0,     0,     0,     0,   435,
       0,     0,   436,   337,     0,     0,     0,     0,     0,   441,
     443,     0,     0,     0,     0,     0,     0,     0,   346,     0,
       0,   350,   462,   463,   464,     0,   474,   354,   470,     0,
       0,     0,   475,   476,     0,   482,     0,   527,   557,   521,
     528,   523,   524,     0,   556,   579,   578,     0,     0,   580,
     558,   583,     0,   595,   597,   590,   601,   602,   603,   605,
     604,   600,     0,   610,   593,   626,     0,   630,     0,   633,
       0,   307,     0,    72,    74,   233,     0,     0,     0,     0,
       0,    14,    13,    11,    18,     3,    30,   504,    21,   516,
     515,   542,     0,   430,     0,   496,     0,   428,     0,   490,
       0,   329,   360,   416,   415,   437,   438,   615,     0,   611,
     612,    77,   215,   276,   219,     0,   221,     0,     0,    95,
       0,    98,     0,    96,     0,    97,     0,     0,     0,     0,
       0,    51,    52,     0,   288,   271,   272,     0,    54,    58,
      59,    62,     0,     0,   103,     0,   199,   201,   203,     0,
       0,     0,   216,     0,   270,   269,     0,     0,     0,    93,
     356,   618,     0,     0,   621,     0,     0,   439,   586,   177,
       0,     0,   193,   190,   192,     0,     0,   302,     0,   343,
       0,     0,   306,    76,   230,   238,   282,   378,   391,   396,
     386,   401,   406,   381,   393,   398,   388,   403,   408,   383,
       0,     0,   392,   397,   387,   402,   407,   382,   395,   400,
     390,   405,   410,   385,   311,   394,     0,   399,   389,   404,
     409,   384,     0,   375,   377,   359,     0,   422,   424,     0,
     498,     0,     0,     0,     0,     0,   342,   344,   449,   345,
     348,   347,   460,     0,   472,   471,     0,   363,   529,   525,
       0,   559,   608,   606,   627,   631,   634,   308,   234,   539,
     540,   512,    33,   518,   545,   543,   485,   497,   494,   493,
       0,   614,   220,   222,     0,     0,    99,   102,   100,   101,
     218,    81,    82,    85,     0,   177,    84,    80,   205,   240,
     217,   275,   293,   291,    94,   619,   620,   351,     0,   178,
       0,     0,     0,   191,   196,   197,   107,   105,   379,   332,
       0,     0,     0,   453,   454,   455,   451,   452,   466,     0,
       0,   616,     0,   284,     0,   352,   182,   173,   176,   174,
       0,   423,   425,   333,     0,   495,     0,     0,   177,     0,
       0,   599,   267,     0,     0,   175,   334
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -779,   805,  1048,  -134,  -779,  -105,    38,  -779,  -779,  -779,
     681,  -779,  1183,  -238,  1274,  1296,  -262,   594,  -779,  -779,
     473,  -779,   856,  -464,   -66,  -779,   -79,  -779,  -355,   298,
     799,     3,  -582,  -779,  1294,   914,  -615,  -157,  -779,  -779,
    -779,  -779,  -635,  -779,   -18,   585,    97,  -377,  -779,  -384,
    -313,   542,    42,    49,    12,   109,  -779,   -63,  -778,  -321,
     671,  -779,  -779,    32,  1266,  -779,  -363,   991,  -779,   -51,
    -417,  -779,   723,   -58,  -779,    -7,   341,   819,  -350,   -35,
    1727,  -779,   886,  -779,     0,   979,   287,   -28,   318,   -62,
     -44,  -779,  -779,  -779,  -779,   831,  -173,   492,   489,  -779,
     460,  -779,  -779,   165,  -779,   -71,   157,  -779,  1152,  -779,
    -779,  -779,  -779,   810,   812,   862,  -779,   -43,  -779,  -779,
    -779,  -779,  -779,  -779,  -779,  -779,   794,   838,  -779,  -779,
    -779,  -779,   -59,  1055,  -779,  -779,  -779,  -779,  -779,   776,
    -779,   -85,  -149,  1253,    -9,  -779,  -779,  -779,  -126,   -69,
    1238,  1245,     8,  -779,  -779,  -779,  1246,  -779,  -779,  -779,
    -779,  -779,  -779,   189,   716,  -779,  -779,  -779,  -779,  -779,
     778,  -779,   -83,  -779,    61,   755,  -779,   164,  -779,  -779,
     171,  -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,  -779,
    -779
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
       0,   154,   155,   156,   157,   158,    46,   160,   161,   162,
     163,   164,   468,   302,   303,   304,   305,   306,   623,   307,
     308,   309,   310,   311,   312,   313,   314,   315,   685,   686,
     547,    48,   317,   318,   375,   356,   910,   165,   357,   358,
     669,   670,   671,   672,   319,   320,   321,   633,   634,   637,
     322,   638,   323,   324,   325,   326,   327,   328,   329,   330,
     331,    52,   332,    53,   119,   333,    55,   594,   595,   334,
     335,   336,   337,   338,   339,    57,   340,   341,   463,    59,
     342,    61,   343,    63,   438,    65,    66,   705,    67,    68,
      69,    70,    71,    72,    73,   707,   391,   392,   393,   394,
     480,    75,    76,   481,    78,   503,   969,    79,   742,    80,
      81,    82,    83,   420,   425,    84,    85,   421,    86,    87,
     441,    88,    89,   449,   450,   451,   452,    90,    91,    92,
     465,    93,   185,   186,   187,   565,   839,   188,   412,   466,
     169,   170,   171,   172,   470,   471,   472,   173,   541,   174,
     175,   176,   177,   553,   178,   554,   179,    95,    96,    97,
      98,    99,   100,   789,   483,   101,   102,   500,   504,   484,
     485,   802,   501,   502,   486,   506,   850,   487,   206,   848,
     488,   350,   657,   106,   107,   108,   109,   110,   111,   112,
     113
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      64,   167,   115,   538,   114,   120,   644,   406,   735,   380,
     642,   692,   560,   459,   733,   401,   359,   118,   679,   505,
     195,   545,   388,   208,   344,   120,   458,   208,   208,   461,
     453,   371,   499,   402,   462,   913,   376,   345,   426,   550,
     166,   446,   116,   544,   620,   419,   159,   531,   737,    49,
     631,   361,   536,    40,   439,   385,   431,   464,   447,    45,
     205,   103,   820,   843,   354,   615,   616,   492,   533,   899,
     242,    64,    64,   344,   642,    64,   489,    64,   180,    64,
     361,   344,    36,     1,   852,     2,    40,   120,   490,   551,
     130,   661,   344,    64,   344,    64,   662,    64,   189,   440,
      49,   631,   631,   980,   460,   631,   498,   448,    64,    50,
      64,   181,    64,    64,   663,   387,   493,   721,   370,   722,
      49,    49,   362,     1,    49,     2,    49,   562,    49,    49,
     844,  1041,   207,   927,   388,   354,   347,   348,   203,   769,
     575,    49,    49,   121,    49,   405,    49,   182,   632,   210,
     211,   631,   369,   210,   211,  1048,   475,    49,   586,    49,
      50,    49,    49,   548,   104,    77,   167,   559,   610,   143,
     386,   105,   344,   631,    40,   954,   370,   899,   427,   191,
      50,    50,   558,   733,    50,   344,    50,   770,    50,    50,
     901,   585,  1060,   403,   491,   428,   706,   876,   611,   632,
     632,    50,    50,   632,    50,   166,    50,   576,   404,   587,
     699,   159,   589,   591,   183,   114,   656,    50,   184,    50,
     692,    50,    50,   197,   429,    37,    38,   387,    40,   117,
      42,   895,   405,   598,   183,   556,   381,   381,   184,  -448,
     381,   430,   381,   442,   410,   853,   354,  1041,     8,   632,
     195,   867,   868,   869,   870,   198,  -448,   479,   381,   476,
      77,   588,   590,    40,   655,   610,   477,    44,    45,    37,
      38,   632,  -304,   117,    42,   885,  1043,   723,   724,   725,
     210,   211,   386,   183,  1076,   600,   482,   184,   692,   459,
      44,    45,   893,   443,   896,   611,  -304,   508,   354,   510,
     898,   512,   514,    40,   727,   370,   728,    44,    45,    37,
      38,   298,   299,   117,    42,   838,    22,   444,   911,   401,
     396,   445,   733,   643,   760,   888,  1049,   455,   903,   373,
     199,   344,   698,   464,   680,   397,   374,   402,   680,    29,
     225,   761,   456,   167,   354,   904,    40,   651,   401,    43,
     405,   120,   635,   370,   558,   354,   879,   880,   713,   234,
     720,   726,   732,   659,   636,   585,   402,   693,   344,    64,
     200,   344,   688,    64,   871,   872,   344,   690,   494,   878,
     460,    64,   166,   344,   545,   243,   426,   643,   159,   379,
     382,   453,   419,   395,   298,   299,   816,   817,   818,   819,
     201,   167,   545,   688,   899,   458,   691,   495,   461,   258,
      64,   467,   202,   462,   389,   346,   756,    49,    49,   401,
     803,   351,    49,   821,   822,   387,   764,   361,   832,   344,
      49,   752,   795,   352,   643,   773,   781,   402,  1035,  1036,
     166,   496,   899,   497,   643,   823,   159,   824,   210,   211,
     354,  1079,   573,   774,   851,   353,   602,   210,   211,    49,
      74,   758,  1079,   783,   729,   730,   731,   210,   211,   354,
    -311,   361,   344,    47,   610,   853,    49,    50,    50,   365,
     386,    64,    50,    64,   610,   354,   210,   211,   210,   211,
      50,   354,   777,   592,   920,   610,   368,   715,   370,   716,
     673,   674,   651,   610,   611,   610,   545,   372,   604,    64,
     354,    64,   977,    64,   611,    64,   377,   675,   676,    50,
      49,   354,   370,   374,    47,   611,   389,   692,   167,   835,
      49,   354,    49,   611,    23,   611,    50,   432,   354,   409,
     652,   940,   517,    27,    47,    47,   381,    28,    47,   518,
      47,   517,    47,    47,   855,   474,   210,   211,    49,   354,
      49,   518,    49,   733,    49,    47,    47,   166,    47,   833,
      47,   459,   454,   159,   978,   741,  1028,   210,   211,   735,
      50,    47,   507,    47,   520,    47,    47,   516,  1039,   859,
      50,   861,    50,   863,   834,   865,   521,   183,   344,    16,
     344,   184,   344,   257,   344,   522,   688,   688,   688,   688,
     621,   622,   210,   211,   877,   464,   225,   884,    50,   847,
      50,   585,    50,   692,    50,   981,   344,    37,    38,   523,
     688,   117,    42,   643,   524,   234,   525,   643,   643,   643,
     589,   589,   130,   526,   693,   527,   788,   688,   877,   688,
     344,   528,   918,  -314,   690,   557,   681,   717,   718,   719,
     689,   243,   460,   388,   942,   943,   944,   945,   946,   947,
     720,    51,   792,   534,   545,   545,   535,  1044,  1045,   401,
     889,   542,   388,   691,   388,   258,   537,   626,   627,   588,
     590,   561,   210,   211,  1063,   552,   585,   402,   806,    49,
     808,   566,   810,   967,   812,  1037,   775,   776,   643,   643,
     643,   643,   643,   643,   344,   877,   877,   877,   877,   877,
     877,   143,    51,    56,   389,   568,   401,   956,   956,   956,
     956,   956,   956,   344,   887,   344,   210,   211,   968,   210,
     211,    64,    51,    51,   402,   569,    51,   570,    51,  1065,
      51,    51,  1040,   585,   851,   571,   387,   210,   211,    50,
     120,    36,   690,    51,    51,    40,    51,   580,    51,    44,
      45,   774,   982,   581,    56,   387,   582,   387,   596,    51,
     583,    51,  1053,    51,    51,   210,   211,    49,    64,   606,
      49,   607,    40,   608,    56,    56,    44,    45,    56,  -263,
      56,  -288,    56,    56,   609,   934,   935,   936,   937,   938,
     939,   386,   827,   828,   617,    56,    56,   628,    56,    58,
      56,   624,   586,   316,   509,   990,   511,   664,   513,   515,
     962,    56,   962,    56,   630,    56,    56,    49,   645,   690,
     647,    47,    47,   614,   297,  1054,    47,    50,   210,   211,
      50,  1016,   658,  1017,    47,  1018,   649,  1019,   779,   830,
     344,   650,   344,   677,   344,   678,   344,   696,  1064,   738,
      58,   921,   922,   877,    37,    38,   648,    40,   117,    42,
     424,  1055,   743,    47,   210,   211,    62,   691,   744,   643,
      58,    58,   759,   469,    58,  1050,    58,    50,    58,    58,
      47,    36,   921,   966,    39,    40,   741,   745,    43,    44,
      45,    58,    58,   746,    58,   747,    58,   748,   344,   765,
     344,   688,   691,   988,   989,   766,   614,    58,   778,    58,
     648,    58,    58,     1,   713,     2,  1056,   360,  1057,   210,
     211,   210,   211,   791,    47,    36,    37,    38,   457,    40,
     117,    42,    43,   788,    47,   767,    47,    62,    62,   992,
     993,    62,   779,   360,   784,    62,   360,   790,   498,   791,
     787,   791,   794,   791,   498,   791,  1010,  1011,   360,    62,
     405,    62,    47,    62,    47,   805,    47,   168,    47,   690,
     807,   168,   921,  1020,    62,   809,    62,   796,    62,    62,
     797,   798,   811,   799,   800,   826,   801,   298,   349,   829,
     614,   126,   127,   921,  1021,   837,  1071,   693,   691,   785,
     128,    37,    38,   831,  1074,   117,    42,   690,    37,    38,
      16,    40,   117,    42,  1058,   967,   130,   210,   211,    51,
      51,   836,  1069,   131,    51,   210,   211,   567,  1061,   841,
    1085,  1072,    51,   210,   211,   389,   840,   578,   579,   361,
     842,   133,   948,   949,   950,   951,   952,   953,   845,   136,
     968,   921,  1022,   846,   389,   849,   389,   651,    30,   856,
     168,    51,   921,  1023,   921,  1027,   921,  1030,   921,  1031,
     854,    56,    56,  1051,  1052,   857,    56,   855,    51,   860,
      49,  1066,  1067,   890,    56,   142,  1077,  1067,    49,    36,
    1051,  1084,    39,    40,   862,   143,    43,    44,    45,    49,
     864,   866,   882,    47,   892,   900,   614,   906,   648,   907,
     646,   168,   908,    56,   917,   914,   168,   909,   999,   919,
    1006,   146,    51,   168,   210,   211,   965,   970,   976,   979,
      56,   986,    51,   987,    51,   991,   994,    40,   995,   996,
      50,   610,   997,   700,   370,   701,  1000,  1001,    50,  1002,
     682,   687,  1003,  1007,  1004,   695,  1005,  1024,  1014,    50,
      51,  1015,    51,  1025,    51,  1026,    51,    58,    58,  1029,
    1032,   611,    58,  1033,    56,  1059,  1068,  1062,  1070,  1073,
      58,  1078,   687,  1081,    56,  1082,    56,   301,   660,  1039,
     665,    47,   543,   740,    47,  1086,   825,   881,   886,  1047,
     597,   168,   734,   625,   964,   963,   614,  1080,   424,    58,
     751,   411,    56,   683,    56,   736,    56,   749,    56,   614,
     648,   750,   563,     1,   768,     2,    58,   782,   851,   413,
     193,   210,   211,    94,   360,   360,   384,   194,   196,   360,
     804,    47,   793,     0,   301,     0,    54,   360,   610,   437,
     700,   370,   701,     0,     0,   610,   190,   708,   370,   709,
     610,     0,   715,   370,   716,     0,     0,   204,     0,   414,
      58,     0,     0,     0,     0,     0,   360,     0,   611,     0,
      58,     0,    58,     0,     0,   611,     0,     0,     0,     0,
     611,     0,     0,   360,     0,     0,     0,     0,     0,     0,
       0,    51,     0,   702,   703,   704,     0,   457,    58,     0,
      58,   415,    58,     0,    58,     0,     0,    54,    54,     0,
      16,    54,   355,    54,   540,    54,   363,   364,     0,   366,
     416,   367,   540,   694,     0,     0,     0,   360,     0,    54,
       0,    54,     0,    54,   555,     0,     0,   360,   384,    62,
       0,   564,     0,    56,    54,     0,    54,     0,    54,    54,
       0,     0,     0,     0,   417,     0,     0,   168,    30,     0,
       0,   418,   584,     0,     0,    62,     0,    62,     0,    62,
       0,    62,     0,     0,     0,   687,   687,   687,   687,    51,
       0,     0,    51,   519,     0,   126,   127,     0,     0,    36,
       0,     0,    39,    40,   128,     0,    43,    44,    45,   687,
     702,   703,   704,     0,     0,     0,     0,   710,   711,   712,
     130,     0,   717,   718,   719,     0,   687,   131,   687,     0,
       0,     0,   858,     0,     0,     0,     0,     0,     0,    51,
       0,    56,     0,   572,    56,   133,     0,     0,     0,    58,
       0,     0,     0,   136,     0,     0,     0,     0,     0,     0,
     168,     0,     0,   614,   648,   648,   648,   648,   648,   648,
       0,     0,     0,   574,   577,     0,   694,     0,     0,   694,
       0,   891,     0,     0,     0,     0,     0,   168,   168,   142,
       0,    56,     0,     0,   301,   230,     0,     0,     0,   143,
     593,     0,   233,   593,    47,     0,     0,     0,     0,     0,
       0,     0,    47,     0,   237,   238,   360,     0,     0,   599,
     668,     0,     0,    47,   601,   146,     0,     0,     0,     0,
       0,     0,     0,     0,   301,   684,     0,    58,     0,   301,
      58,    40,   694,     0,   603,     0,   697,     0,     0,     0,
       0,     0,     0,     0,     0,   612,     0,     0,     0,   262,
     639,     0,   605,     0,   264,   265,   684,     0,     0,   640,
       0,   641,   654,     0,     0,     0,     0,   613,   269,     0,
     215,     0,     0,   122,     0,   123,     0,    58,     0,     0,
       0,   629,   301,     0,   301,   753,   754,   125,   757,     0,
       0,     0,   225,   226,   360,   762,   763,   360,     0,     0,
     694,     0,     0,     7,     0,     0,   772,     0,     0,   129,
     653,   234,     0,     0,   755,     0,   293,    54,     0,     0,
      39,    40,     0,     0,     0,    44,    45,     0,   612,     0,
       0,   240,     0,     0,     0,     0,     0,   243,    15,     0,
       0,   134,     0,   739,   360,   135,    54,     0,     0,     0,
     613,     0,     0,     0,   137,     0,     0,     0,     0,   256,
       0,   258,     0,   260,   261,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   140,   540,   540,   540,   540,   141,
       0,   612,     0,     0,     0,     0,     0,   682,     0,  1046,
     687,     0,    51,     0,     0,     0,     0,    60,   144,     0,
      51,     0,     0,   613,    30,     0,     0,   540,   694,     0,
       0,    51,   612,     0,   786,     0,     0,    54,   285,    54,
       0,     0,     0,     0,     0,     0,     0,   289,   290,     0,
       0,     0,     0,     0,   613,    36,   294,    38,     0,    40,
     117,    42,    43,     0,    56,    54,     0,    54,     0,    54,
       0,    54,    56,     0,     0,     0,   815,     0,     0,   684,
     684,   684,   684,    56,     0,     0,     0,   875,    60,    60,
     390,     0,    60,     0,     0,     0,    60,     0,     0,     0,
     813,     0,   814,   684,   612,   694,     0,     0,     0,     0,
      60,     0,    60,     0,    60,     1,     0,     2,     0,   612,
     684,   894,   684,     0,   694,    60,   613,    60,   612,    60,
      60,   905,   147,    36,   148,   149,    39,   549,   151,   152,
     153,   613,    45,   912,     0,     0,     0,     0,   612,     0,
     613,     0,     0,     0,     0,     0,     0,     0,     0,   694,
      58,   414,     0,     0,     0,     0,     0,     0,    58,     0,
     613,     0,     0,   928,   929,   930,   931,   932,   933,    58,
       0,     0,     0,     0,     0,     0,     0,   384,   941,   941,
     941,   941,   941,   941,     0,     0,     0,     0,     0,     0,
       0,     0,   390,   415,     0,     0,   384,   815,   384,     0,
       0,     0,    16,     0,     0,     0,     0,   971,   972,   973,
     974,   975,   416,     0,     0,     0,     0,   360,     0,     0,
       0,     0,   612,     0,     0,   360,   915,     0,   983,     0,
       0,     0,   984,   985,   754,     0,   360,     0,   612,     0,
       0,     0,     0,     0,   613,   694,   417,     0,   916,     0,
      30,   612,     0,   418,     0,     0,     0,     0,     0,     0,
     613,     0,     0,     0,   923,   924,   925,   926,     0,     0,
       0,     0,     0,   613,     0,     0,     0,     0,     0,     0,
       0,    36,     0,   694,    39,    40,     0,    54,    43,    44,
      45,     0,     0,     0,   192,     0,     0,     0,     0,     0,
       0,  1008,     0,  1009,   780,     0,     0,   612,   612,     0,
       0,   612,     0,     1,     0,     2,   612,   612,     0,     0,
       0,     0,   126,   127,     0,     0,   612,     0,     0,   613,
     613,   128,     0,   613,    54,     0,   584,     0,   613,   613,
     122,     0,   123,     0,     0,     0,   225,   130,   613,     0,
       0,     0,     0,     0,   125,   228,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   234,     0,     0,     0,  1038,
       7,     0,   133,  1042,   912,     0,   129,     0,     0,     0,
     136,   301,     0,   301,   684,   240,     0,     0,   532,   998,
     390,   243,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    15,     0,     0,   134,     0,
      16,     0,   135,     0,     0,   258,   142,   260,   261,     0,
       0,   137,     0,     0,     0,     0,   143,     0,  1012,   612,
    1013,     0,     0,     0,     0,     0,   815,     0,     0,     0,
       0,   140,     0,     0,     0,     0,   141,     0,   612,     0,
       0,   613,   146,     0,     0,     0,     0,     0,    30,   612,
       0,     0,     0,     0,     0,   144,   612,     0,    40,     0,
     613,     0,   285,  1034,     0,     0,     0,     0,     0,     0,
       0,   613,   612,   612,   612,   612,   612,   612,   613,    36,
      60,     0,    39,    40,     0,   612,    43,    44,    45,   297,
       0,   298,   299,   300,   613,   613,   613,   613,   613,   613,
     122,     0,   123,     0,     0,     0,    60,   613,    60,     0,
      60,     0,    60,  1075,   125,   612,   612,   612,   612,   612,
     902,     0,   815,     0,     0,     0,     0,   612,   612,   612,
       7,   122,  1083,   123,     0,     0,   129,   613,   613,   613,
     613,   613,     0,     0,     0,   125,     0,     0,     0,   613,
     613,   613,   612,   612,     0,     0,     0,     0,     0,     0,
       0,     7,     0,   473,     0,    15,     0,   129,   134,     0,
       0,     0,   135,     0,   613,   613,     0,     0,     1,     0,
       2,   137,   612,     0,     3,     0,   612,     0,     0,     0,
       0,     0,     0,     4,     0,     0,    15,     0,     0,   134,
       0,   140,     0,   135,   613,     0,   141,     0,   613,     0,
       0,     0,   137,     0,     0,     5,     6,     0,     0,   612,
       0,     0,     0,     0,     0,   144,     0,   612,     0,     0,
       0,     8,   140,     0,     0,     0,     9,   141,     0,     0,
       0,   613,     0,     0,     0,     0,     0,    10,     0,   613,
       0,    11,     0,     0,    12,    13,   144,    14,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    16,     0,     0,     0,     0,
       0,     0,    17,    18,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    19,    20,     0,     0,     0,    21,    22,
      23,    24,     0,     0,     0,     0,     0,    25,    26,    27,
       0,   390,     0,    28,     0,     0,     0,     0,     0,     0,
       0,     0,    29,    30,   955,   957,   958,   959,   960,   961,
     390,    31,   390,     0,     0,     0,     0,     0,     0,     0,
       0,    32,     0,    33,     0,    34,     0,     0,     0,     0,
       0,     0,     0,    35,    36,    37,    38,    39,    40,    41,
      42,    43,    44,    45,   209,     0,   210,   211,     0,     0,
       0,     0,     0,   212,     0,   213,     0,     0,     0,   422,
       0,     0,     0,     0,   215,     0,     0,     0,     0,   216,
     217,     0,     0,     0,     0,   218,   219,   220,   221,   222,
     223,   224,     0,     0,     0,     0,   225,   226,     0,     0,
       0,     0,     0,     0,   227,   228,   229,   230,     0,   414,
       0,     0,   231,   232,   233,   234,     0,     0,     0,   235,
     236,     0,     0,     0,     0,     0,   237,   238,     0,     0,
       0,     0,     0,   239,     0,   240,     0,   241,     0,   242,
       0,   243,     0,     0,     0,   244,     0,   245,   246,     0,
     247,   415,   248,     0,   249,   250,   251,   252,   253,   254,
      16,   255,     0,   256,   257,   258,   259,   260,   261,     0,
     416,   262,     0,     0,   263,     0,   264,   265,     0,     0,
       0,   266,     0,     0,     0,     0,     0,     0,   267,   268,
     269,   270,     0,     0,     0,   271,   272,   273,     0,   274,
     275,     0,   276,   277,   417,   278,     0,     0,    30,   279,
       0,   418,   280,   281,     0,     0,     0,     0,     0,   282,
     283,   284,   285,   286,   287,     0,     0,   288,     0,     0,
       0,   289,   290,   291,   292,     0,     0,     0,   293,    36,
     294,   295,    39,   423,    41,   296,    43,    44,    45,   297,
       0,   298,   299,   300,   209,     0,   210,   211,     0,     0,
       0,     0,     0,   212,     0,   213,     0,     0,     0,     0,
       0,     0,     0,     0,   215,     0,     0,     0,     0,   216,
     217,     0,     0,     0,     0,   218,   219,   220,   221,   222,
     223,   224,     0,     0,     0,     0,   225,   226,     0,     0,
       0,     0,     0,     0,   227,   228,   229,   230,     0,   414,
       0,     0,   231,   232,   233,   234,     0,     0,     0,   235,
     236,     0,     0,     0,     0,     0,   237,   238,     0,     0,
       0,     0,     0,   239,     0,   240,     0,   241,     0,   242,
       0,   243,     0,     0,     0,   244,     0,   245,   246,     0,
     247,   415,   248,     0,   249,   250,   251,   252,   253,   254,
      16,   255,     0,   256,   257,   258,   259,   260,   261,     0,
     416,   262,     0,     0,   263,     0,   264,   265,     0,     0,
       0,   266,     0,     0,     0,     0,     0,     0,   267,   268,
     269,   270,     0,     0,     0,   271,   272,   273,     0,   274,
     275,     0,   276,   277,   417,   278,     0,     0,    30,   279,
       0,   418,   280,   281,     0,     0,     0,     0,     0,   282,
     283,   284,   285,   286,   287,     0,     0,   288,     0,     0,
       0,   289,   290,   291,   292,     0,     0,     0,   293,    36,
     294,   295,    39,   423,    41,   296,    43,    44,    45,   297,
       0,   298,   299,   300,   209,     0,   210,   211,     0,     0,
       0,     0,     0,   212,     0,   213,     0,     0,     0,   214,
       0,     0,     0,     0,   215,     0,     0,     0,     0,   216,
     217,     0,     0,     0,     0,   218,   219,   220,   221,   222,
     223,   224,     0,     0,     0,     0,   225,   226,     0,     0,
       0,     0,     0,     0,   227,   228,   229,   230,     0,     0,
       0,     0,   231,   232,   233,   234,     0,     0,     0,   235,
     236,     0,     0,     0,     0,     0,   237,   238,     0,     0,
       0,     0,     0,   239,     0,   240,     0,   241,     0,   242,
       0,   243,     0,     0,     0,   244,     0,   245,   246,     0,
     247,     0,   248,     0,   249,   250,   251,   252,   253,   254,
      16,   255,     0,   256,   257,   258,   259,   260,   261,     0,
       0,   262,     0,     0,   263,     0,   264,   265,     0,     0,
       0,   266,     0,     0,     0,     0,     0,     0,   267,   268,
     269,   270,     0,     0,     0,   271,   272,   273,     0,   274,
     275,     0,   276,   277,     0,   278,     0,     0,    30,   279,
       0,     0,   280,   281,     0,     0,     0,     0,     0,   282,
     283,   284,   285,   286,   287,     0,     0,   288,     0,     0,
       0,   289,   290,   291,   292,     0,     0,     0,   293,    36,
     294,   295,    39,    40,    41,   296,    43,    44,    45,   297,
       0,   298,   299,   300,   209,     0,   210,   211,   546,     0,
       0,     0,     0,   212,     0,   213,     0,     0,     0,     0,
       0,     0,     0,     0,   215,     0,     0,     0,     0,   216,
     217,     0,     0,     0,     0,   218,   219,   220,   221,   222,
     223,   224,     0,     0,     0,     0,   225,   226,     0,     0,
       0,     0,     0,     0,   227,   228,   229,   230,     0,     0,
       0,     0,   231,   232,   233,   234,     0,     0,     0,   235,
     236,     0,     0,     0,     0,     0,   237,   238,     0,     0,
       0,     0,     0,   239,     0,   240,     0,   241,     0,   242,
       0,   243,     0,     0,     0,   244,     0,   245,   246,     0,
     247,     0,   248,     0,   249,   250,   251,   252,   253,   254,
      16,   255,     0,   256,   257,   258,   259,   260,   261,     0,
       0,   262,     0,     0,   263,     0,   264,   265,     0,     0,
       0,   266,     0,     0,     0,     0,     0,     0,   267,   268,
     269,   270,     0,     0,     0,   271,   272,   273,     0,   274,
     275,     0,   276,   277,     0,   278,     0,     0,    30,   279,
       0,     0,   280,   281,     0,     0,     0,     0,     0,   282,
     283,   284,   285,   286,   287,     0,     0,   288,     0,     0,
       0,   289,   290,   291,   292,     0,     0,     0,   293,    36,
     294,   295,    39,    40,    41,   296,    43,    44,    45,   297,
       0,   298,   299,   300,   209,     0,   210,   211,     0,     0,
       0,     0,     0,   212,     0,   213,     0,     0,     0,     0,
       0,     0,     0,     0,   215,     0,     0,     0,     0,   216,
     217,     0,     0,     0,     0,   218,   219,   220,   221,   222,
     223,   224,     0,     0,     0,     0,   225,   226,     0,     0,
       0,     0,     0,     0,   227,   228,   229,   230,     0,     0,
       0,     0,   231,   232,   233,   234,     0,     0,     0,   235,
     236,     0,     0,     0,     0,     0,   237,   238,     0,     0,
       0,     0,     0,   239,     0,   240,    11,   241,     0,   242,
       0,   243,     0,     0,     0,   244,     0,   245,   246,     0,
     247,     0,   248,     0,   249,   250,   251,   252,   253,   254,
      16,   255,     0,   256,   257,   258,   259,   260,   261,     0,
       0,   262,     0,     0,   263,     0,   264,   265,     0,     0,
       0,   266,     0,     0,     0,     0,     0,     0,   267,   268,
     269,   270,     0,     0,     0,   271,   272,   273,     0,   274,
     275,     0,   276,   277,     0,   278,     0,     0,    30,   279,
       0,     0,   280,   281,     0,     0,     0,     0,     0,   282,
     283,   284,   285,   286,   287,     0,     0,   288,     0,     0,
       0,   289,   290,   291,   292,     0,     0,     0,   293,    36,
     294,   295,    39,    40,    41,   296,    43,    44,    45,   297,
       0,   298,   299,   300,   209,     0,   210,   211,   883,     0,
       0,     0,     0,   212,     0,   213,     0,     0,     0,     0,
       0,     0,     0,     0,   215,     0,     0,     0,     0,   216,
     217,     0,     0,     0,     0,   218,   219,   220,   221,   222,
     223,   224,     0,     0,     0,     0,   225,   226,     0,     0,
       0,     0,     0,     0,   227,   228,   229,   230,     0,     0,
       0,     0,   231,   232,   233,   234,     0,     0,     0,   235,
     236,     0,     0,     0,     0,     0,   237,   238,     0,     0,
       0,     0,     0,   239,     0,   240,     0,   241,     0,   242,
       0,   243,     0,     0,     0,   244,     0,   245,   246,     0,
     247,     0,   248,     0,   249,   250,   251,   252,   253,   254,
      16,   255,     0,   256,   257,   258,   259,   260,   261,     0,
       0,   262,     0,     0,   263,     0,   264,   265,     0,     0,
       0,   266,     0,     0,     0,     0,     0,     0,   267,   268,
     269,   270,     0,     0,     0,   271,   272,   273,     0,   274,
     275,     0,   276,   277,     0,   278,     0,     0,    30,   279,
       0,     0,   280,   281,     0,     0,     0,     0,     0,   282,
     283,   284,   285,   286,   287,     0,     0,   288,     0,     0,
       0,   289,   290,   291,   292,     0,     0,     0,   293,    36,
     294,   295,    39,    40,    41,   296,    43,    44,    45,   297,
       0,   298,   299,   300,   383,     0,   210,   211,     0,     0,
       0,     0,     0,   212,     0,   213,     0,     0,     0,     0,
       0,     0,     0,     0,   215,     0,     0,     0,     0,   216,
     217,     0,     0,     0,     0,   218,   219,   220,   221,   222,
     223,   224,     0,     0,     0,     0,   225,   226,     0,     0,
       0,     0,     0,     0,   227,   228,   229,   230,     0,     0,
       0,     0,   231,   232,   233,   234,     0,     0,     0,   235,
     236,     0,     0,     0,     0,     0,   237,   238,     0,     0,
       0,     0,     0,   239,     0,   240,     0,   241,     0,   242,
       0,   243,     0,     0,     0,   244,     0,   245,   246,     0,
     247,     0,   248,     0,   249,   250,   251,   252,   253,   254,
      16,   255,     0,   256,   257,   258,   259,   260,   261,     0,
       0,   262,     0,     0,   263,     0,   264,   265,     0,     0,
       0,   266,     0,     0,     0,     0,     0,     0,   267,   268,
     269,   270,     0,     0,     0,   271,   272,   273,     0,   274,
     275,     0,   276,   277,     0,   278,     0,     0,    30,   279,
       0,     0,   280,   281,     0,     0,     0,     0,     0,   282,
     283,   284,   285,   286,   287,     0,     0,   288,     0,     0,
       0,   289,   290,   291,   292,     0,     0,     0,   293,    36,
     294,   295,    39,    40,    41,   296,    43,    44,    45,   297,
       0,   298,   299,   300,   209,     0,   210,   211,     0,     0,
       0,     0,     0,   212,     0,   213,     0,     0,     0,     0,
       0,     0,     0,     0,   215,     0,     0,     0,     0,   216,
     217,     0,     0,     0,     0,   218,   219,   220,   221,   222,
     223,   224,     0,     0,     0,     0,   225,   226,     0,     0,
       0,     0,     0,     0,   227,   228,   229,   230,     0,     0,
       0,     0,   231,   232,   233,   234,     0,     0,     0,   235,
     236,     0,     0,     0,     0,     0,   237,   238,     0,     0,
       0,     0,     0,   239,     0,   240,     0,   241,     0,   242,
       0,   243,     0,     0,     0,   244,     0,   245,   246,     0,
     247,     0,   248,     0,   249,   250,   251,   252,   253,   254,
      16,   255,     0,   256,   257,   258,   259,   260,   261,     0,
       0,   262,     0,     0,   263,     0,   264,   265,     0,     0,
       0,   266,     0,     0,     0,     0,     0,     0,   267,   268,
     269,   270,     0,     0,     0,   271,   272,   273,     0,   274,
     275,     0,   276,   277,     0,   278,     0,     0,    30,   279,
       0,     0,   280,   281,     0,     0,     0,     0,     0,   282,
     283,   284,   285,   286,   287,     0,     0,   288,     0,     0,
       0,   289,   290,   291,   292,     0,     0,     0,   293,    36,
     294,   295,    39,    40,    41,   296,    43,    44,    45,   297,
       0,   298,   299,   300,   209,     0,   210,   211,     0,     0,
       0,     0,     0,   212,     0,   213,     0,     0,     0,     0,
       0,     0,     0,     0,   215,     0,     0,     0,     0,   216,
     217,     0,     0,     0,     0,   218,   219,   220,   221,   222,
     223,   224,     0,     0,     0,     0,   225,   226,     0,     0,
       0,     0,     0,     0,   227,   228,   229,   230,     0,     0,
       0,     0,   231,   232,   233,   234,     0,     0,     0,   235,
     236,     0,     0,     0,     0,     0,   237,   238,     0,     0,
       0,     0,     0,   239,     0,   240,     0,   241,     0,     0,
       0,   243,     0,     0,     0,   244,     0,   245,   246,     0,
     247,     0,   248,     0,   249,   250,   251,   252,   253,   254,
       0,   255,     0,   256,     0,   258,   259,   260,   261,     0,
       0,   262,     0,     0,   263,     0,   264,   265,     0,     0,
       0,   266,     0,     0,     0,     0,     0,     0,   267,   268,
     269,   270,     0,     0,     0,   271,   272,   273,     0,   274,
     275,     0,   276,   277,     0,   278,     0,     0,    30,   279,
       0,     0,   280,   281,     0,     0,     0,     0,     0,   282,
     283,   284,   285,   286,   287,     0,     0,   288,     0,     0,
       0,   289,   290,   291,   292,     0,     0,     0,   293,    36,
     294,   295,    39,    40,   117,   296,    43,    44,    45,   297,
       0,   298,   299,   300,   771,     0,   210,   211,     0,     0,
       0,     0,     0,   212,     0,   213,     0,     0,     0,     0,
       0,     0,     0,     0,   215,     0,     0,     0,     0,   216,
     217,     0,     0,     0,     0,   218,   219,   220,   221,   222,
     223,   224,     0,     0,     0,     0,   225,   226,     0,     0,
       0,     0,     0,     0,   227,     0,     0,   230,     0,     0,
       0,     0,   231,   232,   233,   234,     0,     0,     0,   235,
     236,     0,     0,     0,     0,     0,   237,   238,     0,     0,
       0,     0,     0,   239,     0,   240,     0,   241,     0,     0,
       0,   243,     0,     0,     0,   244,     0,   245,   246,     0,
     247,     0,     0,     0,   249,   250,   251,   252,   253,   254,
       0,   255,     0,   256,     0,   258,   259,   260,   261,     0,
       0,   262,     0,     0,   263,     0,   264,   265,     0,     0,
       0,   266,     0,     0,     0,     0,     0,     0,     0,   268,
     269,   270,     0,     0,     0,   271,   272,   273,     0,   274,
     275,     0,   276,   277,     0,   278,     0,     0,    30,   279,
       0,     0,   280,   281,     0,     0,     0,     0,     0,   282,
     283,     0,   285,   286,   287,     0,     0,   288,     0,     0,
       0,   289,   290,   291,   292,     0,     0,     0,   293,    36,
     294,    38,     0,    40,   117,   296,    43,    44,    45,     0,
       0,   298,   299,   300,   873,     0,   210,   211,     0,     0,
       0,     0,     0,     1,     0,     2,     0,     0,     0,     0,
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
     283,   284,     0,   286,   287,     0,     0,   288,     0,     0,
       0,     0,     0,   291,   292,     0,     0,     0,   293,   230,
       0,   874,    39,    40,     0,   436,   233,    44,    45,   297,
       0,   298,   299,   300,   433,     0,   210,   211,   237,   238,
       0,     0,     0,     1,     0,     2,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   216,
     217,     0,     0,     0,     0,   218,   219,   220,   221,   222,
     223,   224,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   262,   227,     0,     0,   230,   264,   265,
       0,     0,   231,   232,   233,     0,     0,     0,     0,   235,
     236,     0,   269,     0,     0,     0,   237,   238,     0,     0,
       0,     0,     0,   239,     0,     0,     0,   241,   434,     0,
       0,     0,     0,     0,     0,   244,     0,   245,   246,     0,
     247,     0,     0,     0,   249,   250,   251,   252,   253,   254,
       0,   255,     0,     0,     0,     0,   259,     0,     0,     0,
     293,   262,     0,     0,   263,    40,   264,   265,     0,    44,
      45,   266,     0,     0,     0,     0,     0,     0,     0,   268,
     269,   270,     0,     0,     0,   271,   272,   273,     0,   274,
     275,     0,   276,   277,     0,   278,     0,     0,     0,   279,
       0,     0,   280,   281,     0,     0,     0,     0,     0,   282,
     283,     0,     0,   286,   287,   435,     0,   288,     0,     0,
       0,     0,     0,   291,   292,     0,     0,     0,   293,     0,
       0,     0,     0,    40,     0,   436,     0,    44,    45,     0,
       0,   298,   299,   300,   433,     0,   210,   211,   666,     0,
       0,     0,   667,     1,     0,     2,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   216,
     217,     0,     0,     0,     0,   218,   219,   220,   221,   222,
     223,   224,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   227,     0,     0,   230,     0,     0,
       0,     0,   231,   232,   233,     0,     0,     0,     0,   235,
     236,     0,     0,     0,     0,     0,   237,   238,     0,     0,
       0,     0,     0,   239,     0,     0,     0,   241,     0,     0,
       0,     0,     0,     0,     0,   244,     0,   245,   246,     0,
     247,     0,     0,     0,   249,   250,   251,   252,   253,   254,
       0,   255,     0,     0,     0,     0,   259,     0,     0,     0,
       0,   262,     0,     0,   263,     0,   264,   265,     0,     0,
       0,   266,     0,     0,     0,     0,     0,     0,     0,   268,
     269,   270,     0,     0,     0,   271,   272,   273,     0,   274,
     275,     0,   276,   277,     0,   278,     0,     0,     0,   279,
       0,     0,   280,   281,     0,     0,     0,     0,     0,   282,
     283,     0,     0,   286,   287,     0,     0,   288,     0,     0,
       0,     0,     0,   291,   292,     0,     0,     0,   293,     0,
       0,     0,     0,    40,     0,   436,     0,    44,    45,     0,
       0,   298,   299,   300,   433,     0,   210,   211,   539,     0,
       0,     0,     0,     1,     0,     2,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   216,
     217,     0,     0,     0,     0,   218,   219,   220,   221,   222,
     223,   224,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   227,     0,     0,   230,     0,     0,
       0,     0,   231,   232,   233,     0,     0,     0,     0,   235,
     236,     0,     0,     0,     0,     0,   237,   238,     0,     0,
       0,     0,     0,   239,     0,     0,     0,   241,     0,     0,
       0,     0,     0,     0,     0,   244,     0,   245,   246,     0,
     247,     0,     0,     0,   249,   250,   251,   252,   253,   254,
       0,   255,     0,     0,     0,     0,   259,     0,     0,     0,
       0,   262,     0,     0,   263,     0,   264,   265,     0,     0,
       0,   266,     0,     0,     0,     0,     0,     0,     0,   268,
     269,   270,     0,     0,     0,   271,   272,   273,     0,   274,
     275,     0,   276,   277,     0,   278,     0,     0,     0,   279,
       0,     0,   280,   281,     0,     0,     0,     0,     0,   282,
     283,     0,     0,   286,   287,     0,     0,   288,     0,     0,
       0,     0,     0,   291,   292,     0,     0,     0,   293,     0,
       0,     0,     0,    40,     0,   436,     0,    44,    45,     0,
       0,   298,   299,   300,   433,     0,   210,   211,     0,     0,
       0,     0,   667,     1,     0,     2,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   216,
     217,     0,     0,     0,     0,   218,   219,   220,   221,   222,
     223,   224,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   227,     0,     0,   230,     0,     0,
       0,     0,   231,   232,   233,     0,     0,     0,     0,   235,
     236,     0,     0,     0,     0,     0,   237,   238,     0,     0,
       0,     0,     0,   239,     0,     0,     0,   241,     0,     0,
       0,     0,     0,     0,     0,   244,     0,   245,   246,     0,
     247,     0,     0,     0,   249,   250,   251,   252,   253,   254,
       0,   255,     0,     0,     0,     0,   259,     0,     0,     0,
       0,   262,     0,     0,   263,     0,   264,   265,     0,     0,
       0,   266,     0,     0,     0,     0,     0,     0,     0,   268,
     269,   270,     0,     0,     0,   271,   272,   273,     0,   274,
     275,     0,   276,   277,     0,   278,     0,     0,     0,   279,
       0,     0,   280,   281,     0,     0,     0,     0,     0,   282,
     283,     0,     0,   286,   287,     0,     0,   288,     0,     0,
       0,     0,     0,   291,   292,     0,     0,     0,   293,     0,
       0,     0,     0,    40,     0,   436,     0,    44,    45,     0,
       0,   298,   299,   300,   433,     0,   210,   211,     0,     0,
       0,     0,     0,     1,     0,     2,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   216,
     217,     0,     0,     0,     0,   218,   219,   220,   221,   222,
     223,   224,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   227,     0,     0,   230,     0,     0,
       0,     0,   231,   232,   233,     0,     0,     0,     0,   235,
     236,     0,     0,     0,     0,     0,   237,   238,     0,     0,
       0,     0,     0,   239,     0,     0,     0,   241,     0,     0,
       0,     0,     0,     0,     0,   244,     0,   245,   246,     0,
     247,     0,     0,     0,   249,   250,   251,   252,   253,   254,
       0,   255,     0,     0,     0,     0,   259,     0,     0,     0,
       0,   262,     0,     0,   263,     0,   264,   265,     0,     0,
       0,   266,     0,     0,     0,     0,     0,     0,     0,   268,
     269,   270,     0,     0,     0,   271,   272,   273,     0,   274,
     275,     0,   276,   277,     0,   278,     0,     0,     0,   279,
       0,     0,   280,   281,     0,     0,     0,     0,     0,   282,
     283,     0,     0,   286,   287,     0,     0,   288,     0,     0,
       0,   433,     0,   291,   292,   618,   619,     0,   293,     0,
       1,     0,     2,    40,     0,   436,     0,    44,    45,     0,
       0,   298,   299,   300,     0,     0,   216,   217,     0,     0,
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
     286,   287,     0,     0,   288,     0,     0,   433,     0,     0,
     291,   292,     0,     0,     0,   293,     1,     0,     2,     0,
      40,     0,   436,     0,    44,    45,     0,     0,   298,   299,
     300,     0,   216,   217,     0,     0,     0,     0,   218,   219,
     220,   221,   222,   223,   224,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   227,     0,     0,
     230,     0,     0,     0,     0,   231,   232,   233,     0,     0,
       0,     0,   235,   236,     0,     0,     0,     0,     0,   237,
     238,     0,     0,     0,     0,     0,   239,     0,     0,     0,
     241,     0,     0,     0,     0,     0,     0,     0,   244,     0,
     245,   246,     0,   247,     0,     0,     0,   249,   250,   251,
     252,   253,   254,     0,   255,     0,     0,     0,     0,   259,
       0,     0,     0,     0,   262,     0,     0,   263,     0,   264,
     265,     0,     0,     0,   266,     0,     0,     0,     0,     0,
       0,     0,   268,   269,   270,     0,     0,     0,   271,   272,
     273,     0,   274,   275,     0,   276,   277,     0,   278,     0,
       0,     0,   279,     0,     0,   280,   281,     0,     0,     0,
     639,     0,   282,   283,     0,     0,   286,   287,     0,   640,
     288,   641,     0,     0,     0,     0,   291,   292,     0,     0,
     215,   293,     0,     0,     0,   230,    40,     0,   436,   639,
      44,    45,   233,     0,   298,   299,   300,     0,   640,     0,
     641,     0,   225,   226,   237,   238,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   714,     0,
       0,   234,     0,     0,     0,     0,     0,   640,     0,   641,
       0,   225,   226,     0,     0,     0,     0,     0,     0,     0,
       0,   240,     0,     0,     0,     0,     0,   243,     0,   262,
     234,     0,     0,     0,   264,   265,     0,     0,     0,     0,
     225,   226,     0,     0,     0,     0,     0,     0,   269,   256,
     240,   258,     0,   260,   261,     0,   243,     0,     0,   234,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   240,
     258,     0,   260,   261,     0,   243,     0,     0,     0,     0,
       0,     0,     0,     0,    30,     0,   293,    36,    37,    38,
      39,    40,   117,    42,    43,    44,    45,     0,   285,   258,
       0,   260,   261,     0,     0,     0,     0,   289,   290,     0,
       0,     0,     0,    30,     0,    36,   294,    38,     0,    40,
     117,    42,    43,     0,     0,     0,     0,   285,     0,     0,
       0,     0,     0,     0,     0,     0,   289,   290,     0,     1,
     230,     2,    30,     0,    36,   294,    38,   233,    40,   117,
      42,    43,     0,     0,     0,     0,   285,     0,     0,   237,
     238,     0,     0,     0,     0,   289,   290,     0,     0,     0,
       0,     0,   225,    36,   294,    38,     0,    40,   117,    42,
      43,   228,     0,   230,     0,     0,     0,     0,     0,     0,
     233,   234,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   237,   238,   262,     0,     0,     0,     0,   264,
     265,   240,     0,     0,     0,     0,     0,   243,     0,     0,
       0,     0,     0,   269,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    16,     0,     0,     0,
       0,   258,     0,   260,   261,     0,     0,   262,     0,     0,
       0,     0,   264,   265,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   269,     0,     0,     0,
       0,   293,    36,    37,    38,     0,    40,   117,    42,    43,
      44,    45,     0,     0,    30,     0,     0,     0,     0,     0,
       0,     0,     0,     1,     0,     2,     0,     0,   285,     3,
       0,     0,     0,     0,     0,     0,     0,     0,     4,     0,
       0,     0,     0,     0,   293,    36,    37,    38,    39,    40,
     117,    42,    43,    44,    45,   297,     0,   298,   299,   300,
       5,     6,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     7,     0,     0,     0,     0,     8,     0,     0,     0,
       0,     9,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    10,     0,     0,     0,    11,     0,     0,    12,
      13,     0,    14,     0,     0,     0,    15,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      16,     0,     0,     0,     0,     0,     0,    17,    18,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    19,    20,
       0,     0,     0,    21,    22,    23,    24,     0,     0,     0,
       0,     0,    25,    26,    27,     0,     0,     0,    28,     0,
       0,     0,     0,     0,     0,     0,     0,    29,    30,     0,
       0,     0,     1,     0,     2,     0,    31,     0,     3,     0,
       0,     0,     0,     0,     0,     0,    32,     4,    33,     0,
      34,     0,     0,     0,     0,     0,     0,     0,    35,    36,
      37,    38,    39,    40,    41,    42,    43,    44,    45,     5,
       6,     0,     0,     0,     0,     0,     0,   478,     0,     0,
       0,     0,     0,     0,     0,     8,     0,     0,     0,     0,
       9,     0,     0,     0,   479,     0,     0,     0,     0,     0,
       0,    10,     0,     0,     0,    11,     0,     0,    12,    13,
       0,    14,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    16,
       0,     0,     0,     0,     0,     0,    17,    18,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    19,    20,     0,
       0,     0,    21,    22,    23,    24,     0,     0,     0,     0,
       0,    25,    26,    27,     1,     0,     2,    28,     0,     0,
       3,     0,     0,     0,     0,     0,    29,    30,     0,     4,
       0,     0,     0,     0,     0,    31,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    32,     0,    33,     0,    34,
       0,     5,     6,     0,     0,     0,     0,    35,    36,    37,
      38,    39,    40,    41,    42,    43,    44,    45,     0,     0,
       0,     0,     9,     0,     0,   407,     0,     0,     0,     0,
       0,     0,     0,    10,     0,     0,     0,    11,     0,     0,
      12,    13,     0,    14,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    16,     0,     0,     0,     0,     0,     0,    17,    18,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    19,
      20,     0,     0,     0,    21,     0,    23,    24,     0,     0,
       0,     0,     0,    25,    26,    27,     1,     0,     2,    28,
       0,     0,     3,     0,     0,     0,     0,     0,     0,    30,
       0,     4,     0,     0,     0,     0,   408,    31,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    32,     0,    33,
       0,    34,     0,     5,     6,     0,     0,     0,     0,    35,
      36,    37,    38,    39,    40,    41,    42,    43,    44,    45,
       0,     0,     0,     0,     9,     0,     0,   407,     0,     0,
       0,     0,     0,     0,     0,    10,     0,   398,     0,    11,
       0,     0,     0,    13,     0,    14,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    16,     0,     0,     0,     0,     0,     0,
      17,    18,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    19,    20,     0,     0,     0,    21,     0,    23,    24,
       0,     0,     0,     0,     0,    25,    26,    27,     0,     0,
       0,    28,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    30,     0,     0,     0,     0,     0,   399,     0,    31,
       1,     0,     2,     0,     0,     0,     3,     0,     0,   400,
       0,    33,     0,    34,     0,     4,     0,     0,     0,     0,
       0,     0,    36,    37,    38,    39,    40,   117,    42,    43,
      44,    45,     0,     0,     0,     0,     0,     5,     6,     0,
       0,     0,     0,     0,     0,   478,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     9,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    10,
       0,   398,     0,    11,     0,     0,     0,    13,     0,    14,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    16,     0,     0,
       0,     0,     0,     0,    17,    18,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    19,    20,     0,     0,     0,
      21,     0,    23,    24,     0,     0,     0,     0,     0,    25,
      26,    27,     0,     0,     0,    28,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    30,     0,     0,     0,     0,
       0,   399,     0,    31,     1,     0,     2,     0,     0,     0,
       3,     0,     0,   400,     0,    33,     0,    34,     0,     4,
       0,     0,     0,     0,     0,     0,    36,    37,    38,    39,
      40,   117,    42,    43,    44,    45,     0,     0,     0,     0,
       0,     5,     6,     0,     0,     0,     0,     0,     0,   478,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     9,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    10,     0,     0,     0,    11,     0,     0,
      12,    13,     0,    14,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    16,     0,     0,     0,     0,     0,     0,    17,    18,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    19,
      20,     0,     0,     0,    21,     0,    23,    24,     0,     0,
       0,     0,     0,    25,    26,    27,     1,     0,     2,    28,
       0,     0,     3,     0,     0,     0,     0,     0,     0,    30,
       0,     4,     0,     0,     0,     0,     0,    31,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    32,     0,    33,
       0,    34,     0,     5,     6,     0,     0,     0,     0,    35,
      36,    37,    38,    39,    40,    41,    42,    43,    44,    45,
       0,     0,     0,     0,     9,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    10,     0,   398,     0,    11,
       0,     0,     0,    13,     0,    14,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    16,     0,     0,     0,     0,     0,     0,
      17,    18,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    19,    20,     0,     0,     0,    21,     0,    23,    24,
       0,     0,     0,     0,     0,    25,    26,    27,     1,     0,
       2,    28,     0,     0,     3,     0,     0,     0,     0,     0,
       0,    30,     0,     4,     0,     0,     0,   399,     0,    31,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   400,
       0,    33,     0,    34,     0,     5,     6,     0,     0,     0,
       0,     0,    36,    37,    38,    39,    40,   117,    42,    43,
      44,    45,     0,     0,     0,     0,     9,     0,     0,     0,
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
       0,   378,     0,    33,     0,    34,     0,     5,     6,     0,
       0,     0,     0,     0,    36,    37,    38,    39,    40,    41,
      42,    43,    44,    45,     0,     0,     0,     0,     9,     0,
       0,   407,     0,     0,     0,     0,     0,     0,     0,    10,
       0,     0,     0,    11,     0,     0,     0,    13,     0,    14,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    16,     0,     0,
       0,     0,     0,     0,    17,    18,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    19,    20,     0,     0,     0,
      21,     0,    23,    24,     0,     0,     0,     0,     0,    25,
      26,    27,     0,     0,     0,    28,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    30,     0,     0,     0,     1,
       0,     2,     0,    31,     0,     3,     0,     0,     0,     0,
       0,     0,     0,   378,     4,    33,     0,    34,     0,     0,
       0,     0,     0,     0,     0,     0,    36,    37,    38,    39,
      40,   117,    42,    43,    44,    45,     5,     6,     0,     0,
       0,     0,     0,     0,   478,     0,     0,     0,     0,     0,
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
       0,     0,   378,     0,    33,     0,    34,     0,     5,     6,
       0,     0,     0,     0,     0,    36,    37,    38,    39,    40,
     117,    42,    43,    44,    45,     0,     0,     0,     0,     9,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   230,
      10,     0,     0,     0,    11,     0,   233,     0,    13,     0,
      14,     0,     0,     0,     0,     0,     0,     0,   237,   238,
       0,     0,     0,     0,     0,     0,     0,     0,    16,     0,
       0,     0,     0,     0,     0,    17,    18,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    19,    20,     0,     0,
       0,    21,    16,    23,    24,     1,   897,     2,     0,     0,
      25,    26,    27,   262,     0,     0,    28,     0,   264,   265,
       0,     0,     0,     0,     0,     0,    30,     0,     0,     0,
       0,     0,   269,     0,    31,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   378,     0,    33,     0,    34,   230,
      30,     0,     0,     0,     0,     0,   233,    36,    37,    38,
      39,    40,   117,    42,    43,    44,    45,     0,   237,   238,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     293,    36,    37,    38,    39,    40,   117,    42,    43,    44,
      45,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    16,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   262,     0,     0,     0,     0,   264,   265,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   269,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     293,    36,    37,    38,    39,    40,   117,    42,    43,    44,
      45,   122,     0,   123,     0,     0,     0,     0,     0,     0,
       0,     0,   124,     0,     0,   125,     0,   126,   127,     0,
       0,     0,     0,     0,     0,     0,   128,     0,     0,     0,
       0,     7,     0,     0,     0,     0,     0,   129,     0,     0,
       0,     0,   130,     0,     0,     0,     0,     0,     0,   131,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   132,
       0,     0,     0,     0,     0,     0,    15,   133,     0,   134,
       0,     0,     0,   135,     0,   136,     0,     0,     0,     0,
       0,     0,   137,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   138,     0,   139,     0,     0,     0,     0,
       0,     0,   140,     0,     0,     0,     0,   141,     0,     0,
       0,   142,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   143,     0,     0,     0,     0,   144,     0,     0,     0,
       0,     0,     0,     0,   145,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   146,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   147,    36,
     148,   149,    39,   150,   151,   152,   153,   122,    45,   123,
       0,     0,     0,     0,     0,     0,     0,     0,   124,     0,
       0,   125,     0,   126,   127,     0,     0,     0,     0,     0,
       0,     0,   128,     0,     0,     0,     0,     7,     0,     0,
       0,     0,     0,   129,     0,     0,     0,     0,   130,     0,
       0,     0,     0,     0,     0,   131,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   132,     0,     0,     0,     0,
       0,     0,    15,   133,     0,   134,     0,     0,     0,   135,
     122,   136,   123,     0,     0,     0,     0,     0,   137,     0,
       0,     0,     0,     0,   125,     0,   126,   127,     0,   138,
       0,   139,     0,     0,     0,   128,     0,     0,   140,     0,
       7,     0,     0,   141,     0,     0,   129,   142,     0,     0,
       0,   130,     0,     0,     0,     0,     0,   143,   131,     0,
       0,     0,   144,     0,     0,     0,     0,     0,   529,     0,
     145,     0,     0,     0,     0,    15,   133,     0,   134,     0,
       0,     0,   135,   146,   136,     0,     0,     0,     0,     0,
       0,   137,   122,     0,   123,     0,     0,     0,     0,    40,
       0,     0,   530,     0,     0,     0,   125,     0,   126,   127,
       0,   140,     0,     0,     0,     0,   141,   128,     0,     0,
     142,     0,     7,     0,     0,     0,     0,     0,   129,     0,
     143,     0,     0,   130,     0,   144,     0,     0,     0,     0,
     131,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   146,    15,   133,     0,
     134,     0,     0,     0,   135,     0,   136,     0,     0,     0,
       0,     0,    40,   137,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   140,     0,     0,     0,     0,   141,     0,
       0,     0,   142,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   143,     0,     0,     0,     0,   144,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   146,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    40
};

static const yytype_int16 yycheck[] =
{
       0,     8,     2,   160,     1,     5,   327,    78,   392,    71,
     323,   374,   185,    92,   391,    77,    51,     5,   368,   102,
      12,   170,    73,    23,    24,    25,    92,    27,    28,    92,
      89,    59,   101,    77,    92,   670,    64,    25,    81,   173,
       8,     4,     4,   169,   306,    80,     8,   152,   403,     0,
      23,    51,   157,   195,    21,    73,    84,    92,    21,   200,
      22,     0,   526,    95,    19,   303,   304,    83,   153,   651,
      91,    71,    72,    73,   387,    75,    21,    77,    21,    79,
      80,    81,   191,    15,     5,    17,   195,    87,    33,   174,
      74,    86,    92,    93,    94,    95,    91,    97,    21,    87,
      51,    23,    23,    21,    92,    23,     6,    70,   108,     0,
     110,    54,   112,   113,     6,    73,   132,    27,    28,    29,
      71,    72,     6,    15,    75,    17,    77,    21,    79,    80,
     162,   909,    23,     5,   185,    19,    27,    28,    21,    34,
      95,    92,    93,     6,    95,    45,    97,    90,   121,     8,
       9,    23,     4,     8,     9,     5,    95,   108,   209,   110,
      51,   112,   113,   172,     0,     0,   173,   185,    25,   153,
      73,     0,   172,    23,   195,   196,    28,   759,     4,     6,
      71,    72,   182,   560,    75,   185,    77,    82,    79,    80,
     654,   209,    51,     6,   139,    21,   169,   614,    55,   121,
     121,    92,    93,   121,    95,   173,    97,   162,    21,   209,
     383,   173,   212,   213,   177,   212,   350,   108,   181,   110,
     583,   112,   113,   170,     4,   192,   193,   185,   195,   196,
     197,   648,    45,     6,   177,   167,    71,    72,   181,     4,
      75,    21,    77,    46,    79,     5,    19,  1025,    68,   121,
     242,   606,   607,   608,   609,     6,    21,    77,    93,    95,
      95,   212,   213,   195,   349,    25,    95,   199,   200,   192,
     193,   121,     4,   196,   197,   630,   911,   187,   188,   189,
       8,     9,   185,   177,  1062,     6,    97,   181,   651,   368,
     199,   200,   647,    96,   649,    55,    28,   108,    19,   110,
     650,   112,   113,   195,    27,    28,    29,   199,   200,   192,
     193,   203,   204,   196,   197,   170,   136,   120,    46,   381,
      21,   124,   699,   323,     4,   638,    21,     6,     4,     4,
      80,   331,   383,   368,   369,    36,    11,   381,   373,   159,
      48,    21,    21,   350,    19,    21,   195,    11,   410,   198,
      45,   351,    24,    28,   354,    19,   618,   619,   386,    67,
     388,   389,   390,   351,    36,   383,   410,   374,   368,   369,
      80,   371,   372,   373,   612,   613,   376,   374,    62,   617,
     368,   381,   350,   383,   533,    93,   429,   387,   350,    71,
      72,   450,   427,    75,   203,   204,   522,   523,   524,   525,
       6,   408,   551,   403,   986,   471,   374,    91,   471,   117,
     410,    93,     6,   471,    73,    80,   434,   368,   369,   481,
     503,   124,   373,   528,   529,   383,   444,   427,   554,   429,
     381,   431,   501,     6,   434,   453,   471,   481,   902,   903,
     408,   125,  1024,   127,   444,   530,   408,   532,     8,     9,
      19,  1066,    21,   453,     5,    22,     6,     8,     9,   410,
       0,    21,  1077,   472,   187,   188,   189,     8,     9,    19,
       6,   471,   472,     0,    25,     5,   427,   368,   369,    22,
     383,   481,   373,   483,    25,    19,     8,     9,     8,     9,
     381,    19,    14,    27,    14,    25,     6,    27,    28,    29,
       4,     5,    11,    25,    55,    25,   655,     6,     6,   509,
      19,   511,    21,   513,    55,   515,    21,    21,    22,   410,
     471,    19,    28,    11,    51,    55,   185,   890,   535,   557,
     481,    19,   483,    55,   137,    55,   427,     4,    19,    79,
      21,   714,    11,   146,    71,    72,   381,   150,    75,    18,
      77,    11,    79,    80,    11,    95,     8,     9,   509,    19,
     511,    18,   513,   940,   515,    92,    93,   535,    95,    21,
      97,   650,    21,   535,     5,   410,   889,     8,     9,   963,
     471,   108,    21,   110,    11,   112,   113,    16,    20,   598,
     481,   600,   483,   602,   556,   604,     6,   177,   598,   112,
     600,   181,   602,   116,   604,     6,   606,   607,   608,   609,
      12,    13,     8,     9,   614,   650,    48,   626,   509,   581,
     511,   639,   513,   986,   515,    21,   626,   192,   193,     6,
     630,   196,   197,   633,     6,    67,     6,   637,   638,   639,
     640,   641,    74,     6,   651,     6,   481,   647,   648,   649,
     650,    91,   680,     9,   651,   182,   369,   187,   188,   189,
     373,    93,   650,   714,   715,   716,   717,   718,   719,   720,
     698,     0,   483,    21,   823,   824,     4,   915,   916,   741,
     638,     4,   733,   651,   735,   117,   112,     4,     5,   640,
     641,    21,     8,     9,  1015,     9,   714,   741,   509,   650,
     511,    21,   513,   738,   515,    21,     4,     5,   708,   709,
     710,   711,   712,   713,   714,   715,   716,   717,   718,   719,
     720,   153,    51,     0,   383,    21,   788,   727,   728,   729,
     730,   731,   732,   733,   637,   735,     8,     9,   738,     8,
       9,   741,    71,    72,   788,    21,    75,    21,    77,    21,
      79,    80,   909,   771,     5,    21,   714,     8,     9,   650,
     760,   191,   759,    92,    93,   195,    95,    21,    97,   199,
     200,   771,   760,     6,    51,   733,    51,   735,     6,   108,
      11,   110,     5,   112,   113,     8,     9,   738,   788,     6,
     741,     6,   195,     6,    71,    72,   199,   200,    75,     6,
      77,     6,    79,    80,     6,   708,   709,   710,   711,   712,
     713,   714,     4,     5,     7,    92,    93,    21,    95,     0,
      97,    19,   873,    24,   108,   787,   110,   354,   112,   113,
     733,   108,   735,   110,     6,   112,   113,   788,     6,   836,
       6,   368,   369,   301,   201,     5,   373,   738,     8,     9,
     741,   860,   170,   862,   381,   864,     6,   866,     4,     5,
     860,     6,   862,     5,   864,     6,   866,    75,  1025,     6,
      51,     4,     5,   873,   192,   193,   334,   195,   196,   197,
      81,     5,    21,   410,     8,     9,     0,   855,     6,   889,
      71,    72,    11,    94,    75,   966,    77,   788,    79,    80,
     427,   191,     4,     5,   194,   195,   741,     6,   198,   199,
     200,    92,    93,     6,    95,     6,    97,     6,   918,     6,
     920,   921,   890,     4,     5,   135,   384,   108,     5,   110,
     388,   112,   113,    15,   962,    17,     5,    51,     5,     8,
       9,     8,     9,   483,   471,   191,   192,   193,    92,   195,
     196,   197,   198,   788,   481,    21,   483,    71,    72,     4,
       5,    75,     4,    77,    21,    79,    80,    21,     6,   509,
      86,   511,    21,   513,     6,   515,     4,     5,    92,    93,
      45,    95,   509,    97,   511,    21,   513,     8,   515,   986,
      21,    12,     4,     5,   108,    21,   110,   191,   112,   113,
     194,   195,    21,   197,   198,     5,   200,   203,    29,     5,
     468,    49,    50,     4,     5,    21,  1051,  1024,   986,   190,
      58,   192,   193,   159,  1059,   196,   197,  1024,   192,   193,
     112,   195,   196,   197,     5,  1070,    74,     8,     9,   368,
     369,    11,     5,    81,   373,     8,     9,   191,  1010,    21,
       5,  1051,   381,     8,     9,   714,     4,   201,   202,  1059,
      21,    99,   721,   722,   723,   724,   725,   726,     5,   107,
    1070,     4,     5,     5,   733,   202,   735,    11,   160,    18,
     101,   410,     4,     5,     4,     5,     4,     5,     4,     5,
      16,   368,   369,     4,     5,    19,   373,    11,   427,     6,
    1051,     4,     5,    11,   381,   143,     4,     5,  1059,   191,
       4,     5,   194,   195,     6,   153,   198,   199,   200,  1070,
       6,     6,     6,   650,     5,    21,   584,   170,   586,     5,
     331,   152,    91,   410,     5,   170,   157,    20,     5,    21,
      75,   179,   471,   164,     8,     9,    21,    21,    21,    21,
     427,    11,   481,    21,   483,    21,    21,   195,    21,    21,
    1051,    25,    21,    27,    28,    29,     5,     5,  1059,     4,
     371,   372,     5,    28,     6,   376,     5,    11,     6,  1070,
     509,     5,   511,    20,   513,     5,   515,   368,   369,     5,
       5,    55,   373,     5,   471,   170,     5,    20,     6,    21,
     381,    20,   403,    21,   481,     5,   483,    24,   352,    20,
     354,   738,   164,   408,   741,    21,   535,   623,   633,   921,
     229,   242,   391,   309,   735,   733,   684,  1070,   429,   410,
     431,    79,   509,   371,   511,   397,   513,   427,   515,   697,
     698,   429,   187,    15,   450,    17,   427,   471,     5,    21,
      12,     8,     9,     0,   368,   369,    73,    12,    12,   373,
     505,   788,   484,    -1,    81,    -1,     0,   381,    25,    86,
      27,    28,    29,    -1,    -1,    25,    10,    27,    28,    29,
      25,    -1,    27,    28,    29,    -1,    -1,    21,    -1,    61,
     471,    -1,    -1,    -1,    -1,    -1,   410,    -1,    55,    -1,
     481,    -1,   483,    -1,    -1,    55,    -1,    -1,    -1,    -1,
      55,    -1,    -1,   427,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   650,    -1,   187,   188,   189,    -1,   471,   509,    -1,
     511,   103,   513,    -1,   515,    -1,    -1,    71,    72,    -1,
     112,    75,    48,    77,   161,    79,    52,    53,    -1,    55,
     122,    57,   169,   374,    -1,    -1,    -1,   471,    -1,    93,
      -1,    95,    -1,    97,   181,    -1,    -1,   481,   185,   483,
      -1,   188,    -1,   650,   108,    -1,   110,    -1,   112,   113,
      -1,    -1,    -1,    -1,   156,    -1,    -1,   408,   160,    -1,
      -1,   163,   209,    -1,    -1,   509,    -1,   511,    -1,   513,
      -1,   515,    -1,    -1,    -1,   606,   607,   608,   609,   738,
      -1,    -1,   741,   119,    -1,    49,    50,    -1,    -1,   191,
      -1,    -1,   194,   195,    58,    -1,   198,   199,   200,   630,
     187,   188,   189,    -1,    -1,    -1,    -1,   187,   188,   189,
      74,    -1,   187,   188,   189,    -1,   647,    81,   649,    -1,
      -1,    -1,   596,    -1,    -1,    -1,    -1,    -1,    -1,   788,
      -1,   738,    -1,   197,   741,    99,    -1,    -1,    -1,   650,
      -1,    -1,    -1,   107,    -1,    -1,    -1,    -1,    -1,    -1,
     501,    -1,    -1,   941,   942,   943,   944,   945,   946,   947,
      -1,    -1,    -1,   199,   200,    -1,   517,    -1,    -1,   520,
      -1,   645,    -1,    -1,    -1,    -1,    -1,   528,   529,   143,
      -1,   788,    -1,    -1,   331,    59,    -1,    -1,    -1,   153,
     226,    -1,    66,   229,  1051,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,  1059,    -1,    78,    79,   650,    -1,    -1,   245,
     357,    -1,    -1,  1070,   250,   179,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   371,   372,    -1,   738,    -1,   376,
     741,   195,   583,    -1,   270,    -1,   383,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   301,    -1,    -1,    -1,   123,
       6,    -1,   288,    -1,   128,   129,   403,    -1,    -1,    15,
      -1,    17,    22,    -1,    -1,    -1,    -1,   301,   142,    -1,
      26,    -1,    -1,    33,    -1,    35,    -1,   788,    -1,    -1,
      -1,   317,   429,    -1,   431,   432,   433,    47,   435,    -1,
      -1,    -1,    48,    49,   738,   442,   443,   741,    -1,    -1,
     651,    -1,    -1,    63,    -1,    -1,   453,    -1,    -1,    69,
     346,    67,    -1,    -1,    70,    -1,   190,   381,    -1,    -1,
     194,   195,    -1,    -1,    -1,   199,   200,    -1,   384,    -1,
      -1,    87,    -1,    -1,    -1,    -1,    -1,    93,    98,    -1,
      -1,   101,    -1,   407,   788,   105,   410,    -1,    -1,    -1,
     384,    -1,    -1,    -1,   114,    -1,    -1,    -1,    -1,   115,
      -1,   117,    -1,   119,   120,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   134,   522,   523,   524,   525,   139,
      -1,   437,    -1,    -1,    -1,    -1,    -1,   918,    -1,   920,
     921,    -1,  1051,    -1,    -1,    -1,    -1,     0,   158,    -1,
    1059,    -1,    -1,   437,   160,    -1,    -1,   554,   759,    -1,
      -1,  1070,   468,    -1,   478,    -1,    -1,   481,   174,   483,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   183,   184,    -1,
      -1,    -1,    -1,    -1,   468,   191,   192,   193,    -1,   195,
     196,   197,   198,    -1,  1051,   509,    -1,   511,    -1,   513,
      -1,   515,  1059,    -1,    -1,    -1,   520,    -1,    -1,   606,
     607,   608,   609,  1070,    -1,    -1,    -1,   614,    71,    72,
      73,    -1,    75,    -1,    -1,    -1,    79,    -1,    -1,    -1,
     516,    -1,   518,   630,   540,   836,    -1,    -1,    -1,    -1,
      93,    -1,    95,    -1,    97,    15,    -1,    17,    -1,   555,
     647,   648,   649,    -1,   855,   108,   540,   110,   564,   112,
     113,   658,   190,   191,   192,   193,   194,   195,   196,   197,
     198,   555,   200,   670,    -1,    -1,    -1,    -1,   584,    -1,
     564,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   890,
    1051,    61,    -1,    -1,    -1,    -1,    -1,    -1,  1059,    -1,
     584,    -1,    -1,   700,   701,   702,   703,   704,   705,  1070,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   714,   715,   716,
     717,   718,   719,   720,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   185,   103,    -1,    -1,   733,   651,   735,    -1,
      -1,    -1,   112,    -1,    -1,    -1,    -1,   744,   745,   746,
     747,   748,   122,    -1,    -1,    -1,    -1,  1051,    -1,    -1,
      -1,    -1,   668,    -1,    -1,  1059,   672,    -1,   765,    -1,
      -1,    -1,   769,   770,   771,    -1,  1070,    -1,   684,    -1,
      -1,    -1,    -1,    -1,   668,   986,   156,    -1,   672,    -1,
     160,   697,    -1,   163,    -1,    -1,    -1,    -1,    -1,    -1,
     684,    -1,    -1,    -1,   690,   691,   692,   693,    -1,    -1,
      -1,    -1,    -1,   697,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   191,    -1,  1024,   194,   195,    -1,   741,   198,   199,
     200,    -1,    -1,    -1,    21,    -1,    -1,    -1,    -1,    -1,
      -1,   838,    -1,   840,     6,    -1,    -1,   753,   754,    -1,
      -1,   757,    -1,    15,    -1,    17,   762,   763,    -1,    -1,
      -1,    -1,    49,    50,    -1,    -1,   772,    -1,    -1,   753,
     754,    58,    -1,   757,   788,    -1,   873,    -1,   762,   763,
      33,    -1,    35,    -1,    -1,    -1,    48,    74,   772,    -1,
      -1,    -1,    -1,    -1,    47,    57,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    67,    -1,    -1,    -1,   906,
      63,    -1,    99,   910,   911,    -1,    69,    -1,    -1,    -1,
     107,   918,    -1,   920,   921,    87,    -1,    -1,    81,   815,
     383,    93,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    98,    -1,    -1,   101,    -1,
     112,    -1,   105,    -1,    -1,   117,   143,   119,   120,    -1,
      -1,   114,    -1,    -1,    -1,    -1,   153,    -1,   854,   875,
     856,    -1,    -1,    -1,    -1,    -1,   890,    -1,    -1,    -1,
      -1,   134,    -1,    -1,    -1,    -1,   139,    -1,   894,    -1,
      -1,   875,   179,    -1,    -1,    -1,    -1,    -1,   160,   905,
      -1,    -1,    -1,    -1,    -1,   158,   912,    -1,   195,    -1,
     894,    -1,   174,   899,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   905,   928,   929,   930,   931,   932,   933,   912,   191,
     483,    -1,   194,   195,    -1,   941,   198,   199,   200,   201,
      -1,   203,   204,   205,   928,   929,   930,   931,   932,   933,
      33,    -1,    35,    -1,    -1,    -1,   509,   941,   511,    -1,
     513,    -1,   515,  1060,    47,   971,   972,   973,   974,   975,
      22,    -1,   986,    -1,    -1,    -1,    -1,   983,   984,   985,
      63,    33,  1079,    35,    -1,    -1,    69,   971,   972,   973,
     974,   975,    -1,    -1,    -1,    47,    -1,    -1,    -1,   983,
     984,   985,  1008,  1009,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    63,    -1,     0,    -1,    98,    -1,    69,   101,    -1,
      -1,    -1,   105,    -1,  1008,  1009,    -1,    -1,    15,    -1,
      17,   114,  1038,    -1,    21,    -1,  1042,    -1,    -1,    -1,
      -1,    -1,    -1,    30,    -1,    -1,    98,    -1,    -1,   101,
      -1,   134,    -1,   105,  1038,    -1,   139,    -1,  1042,    -1,
      -1,    -1,   114,    -1,    -1,    52,    53,    -1,    -1,  1075,
      -1,    -1,    -1,    -1,    -1,   158,    -1,  1083,    -1,    -1,
      -1,    68,   134,    -1,    -1,    -1,    73,   139,    -1,    -1,
      -1,  1075,    -1,    -1,    -1,    -1,    -1,    84,    -1,  1083,
      -1,    88,    -1,    -1,    91,    92,   158,    94,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   112,    -1,    -1,    -1,    -1,
      -1,    -1,   119,   120,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   130,   131,    -1,    -1,    -1,   135,   136,
     137,   138,    -1,    -1,    -1,    -1,    -1,   144,   145,   146,
      -1,   714,    -1,   150,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   159,   160,   727,   728,   729,   730,   731,   732,
     733,   168,   735,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   178,    -1,   180,    -1,   182,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   190,   191,   192,   193,   194,   195,   196,
     197,   198,   199,   200,     6,    -1,     8,     9,    -1,    -1,
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
      -1,   183,   184,   185,   186,    -1,    -1,    -1,   190,   191,
     192,   193,   194,   195,   196,   197,   198,   199,   200,   201,
      -1,   203,   204,   205,     6,    -1,     8,     9,    -1,    -1,
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
     192,   193,   194,   195,   196,   197,   198,   199,   200,   201,
      -1,   203,   204,   205,     6,    -1,     8,     9,    -1,    -1,
      -1,    -1,    -1,    15,    -1,    17,    -1,    -1,    -1,    21,
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
      -1,   183,   184,   185,   186,    -1,    -1,    -1,   190,   191,
     192,   193,   194,   195,   196,   197,   198,   199,   200,   201,
      -1,   203,   204,   205,     6,    -1,     8,     9,    10,    -1,
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
      -1,   183,   184,   185,   186,    -1,    -1,    -1,   190,   191,
     192,   193,   194,   195,   196,   197,   198,   199,   200,   201,
      -1,   203,   204,   205,     6,    -1,     8,     9,    -1,    -1,
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
      -1,   183,   184,   185,   186,    -1,    -1,    -1,   190,   191,
     192,   193,   194,   195,   196,   197,   198,   199,   200,   201,
      -1,   203,   204,   205,     6,    -1,     8,     9,    10,    -1,
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
      -1,   183,   184,   185,   186,    -1,    -1,    -1,   190,   191,
     192,   193,   194,   195,   196,   197,   198,   199,   200,   201,
      -1,   203,   204,   205,     6,    -1,     8,     9,    -1,    -1,
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
      -1,   183,   184,   185,   186,    -1,    -1,    -1,   190,   191,
     192,   193,   194,   195,   196,   197,   198,   199,   200,   201,
      -1,   203,   204,   205,     6,    -1,     8,     9,    -1,    -1,
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
      -1,   183,   184,   185,   186,    -1,    -1,    -1,   190,   191,
     192,   193,   194,   195,   196,   197,   198,   199,   200,   201,
      -1,   203,   204,   205,     6,    -1,     8,     9,    -1,    -1,
      -1,    -1,    -1,    15,    -1,    17,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    26,    -1,    -1,    -1,    -1,    31,
      32,    -1,    -1,    -1,    -1,    37,    38,    39,    40,    41,
      42,    43,    -1,    -1,    -1,    -1,    48,    49,    -1,    -1,
      -1,    -1,    -1,    -1,    56,    57,    58,    59,    -1,    -1,
      -1,    -1,    64,    65,    66,    67,    -1,    -1,    -1,    71,
      72,    -1,    -1,    -1,    -1,    -1,    78,    79,    -1,    -1,
      -1,    -1,    -1,    85,    -1,    87,    -1,    89,    -1,    -1,
      -1,    93,    -1,    -1,    -1,    97,    -1,    99,   100,    -1,
     102,    -1,   104,    -1,   106,   107,   108,   109,   110,   111,
      -1,   113,    -1,   115,    -1,   117,   118,   119,   120,    -1,
      -1,   123,    -1,    -1,   126,    -1,   128,   129,    -1,    -1,
      -1,   133,    -1,    -1,    -1,    -1,    -1,    -1,   140,   141,
     142,   143,    -1,    -1,    -1,   147,   148,   149,    -1,   151,
     152,    -1,   154,   155,    -1,   157,    -1,    -1,   160,   161,
      -1,    -1,   164,   165,    -1,    -1,    -1,    -1,    -1,   171,
     172,   173,   174,   175,   176,    -1,    -1,   179,    -1,    -1,
      -1,   183,   184,   185,   186,    -1,    -1,    -1,   190,   191,
     192,   193,   194,   195,   196,   197,   198,   199,   200,   201,
      -1,   203,   204,   205,     6,    -1,     8,     9,    -1,    -1,
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
      -1,   183,   184,   185,   186,    -1,    -1,    -1,   190,   191,
     192,   193,    -1,   195,   196,   197,   198,   199,   200,    -1,
      -1,   203,   204,   205,     6,    -1,     8,     9,    -1,    -1,
      -1,    -1,    -1,    15,    -1,    17,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    31,
      32,    -1,    -1,    -1,    -1,    37,    38,    39,    40,    41,
      42,    43,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    56,    57,    58,    59,    -1,    -1,
      -1,    -1,    64,    65,    66,    -1,    -1,    -1,    -1,    71,
      72,    -1,    -1,    -1,    -1,    -1,    78,    79,    -1,    -1,
      -1,    -1,    -1,    85,    -1,    -1,    -1,    89,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    97,    -1,    99,   100,    -1,
     102,    -1,   104,    -1,   106,   107,   108,   109,   110,   111,
      -1,   113,    -1,    -1,    -1,    -1,   118,    -1,    -1,    -1,
      -1,   123,    -1,    -1,   126,    -1,   128,   129,    -1,    -1,
      -1,   133,    -1,    -1,    -1,    -1,    -1,    -1,   140,   141,
     142,   143,    -1,    -1,    -1,   147,   148,   149,    -1,   151,
     152,    -1,   154,   155,    -1,   157,    -1,    -1,    -1,   161,
      -1,    -1,   164,   165,    -1,    -1,    -1,    -1,    -1,   171,
     172,   173,    -1,   175,   176,    -1,    -1,   179,    -1,    -1,
      -1,    -1,    -1,   185,   186,    -1,    -1,    -1,   190,    59,
      -1,   193,   194,   195,    -1,   197,    66,   199,   200,   201,
      -1,   203,   204,   205,     6,    -1,     8,     9,    78,    79,
      -1,    -1,    -1,    15,    -1,    17,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    31,
      32,    -1,    -1,    -1,    -1,    37,    38,    39,    40,    41,
      42,    43,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   123,    56,    -1,    -1,    59,   128,   129,
      -1,    -1,    64,    65,    66,    -1,    -1,    -1,    -1,    71,
      72,    -1,   142,    -1,    -1,    -1,    78,    79,    -1,    -1,
      -1,    -1,    -1,    85,    -1,    -1,    -1,    89,    90,    -1,
      -1,    -1,    -1,    -1,    -1,    97,    -1,    99,   100,    -1,
     102,    -1,    -1,    -1,   106,   107,   108,   109,   110,   111,
      -1,   113,    -1,    -1,    -1,    -1,   118,    -1,    -1,    -1,
     190,   123,    -1,    -1,   126,   195,   128,   129,    -1,   199,
     200,   133,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   141,
     142,   143,    -1,    -1,    -1,   147,   148,   149,    -1,   151,
     152,    -1,   154,   155,    -1,   157,    -1,    -1,    -1,   161,
      -1,    -1,   164,   165,    -1,    -1,    -1,    -1,    -1,   171,
     172,    -1,    -1,   175,   176,   177,    -1,   179,    -1,    -1,
      -1,    -1,    -1,   185,   186,    -1,    -1,    -1,   190,    -1,
      -1,    -1,    -1,   195,    -1,   197,    -1,   199,   200,    -1,
      -1,   203,   204,   205,     6,    -1,     8,     9,    10,    -1,
      -1,    -1,    14,    15,    -1,    17,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    31,
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
     172,    -1,    -1,   175,   176,    -1,    -1,   179,    -1,    -1,
      -1,    -1,    -1,   185,   186,    -1,    -1,    -1,   190,    -1,
      -1,    -1,    -1,   195,    -1,   197,    -1,   199,   200,    -1,
      -1,   203,   204,   205,     6,    -1,     8,     9,    10,    -1,
      -1,    -1,    -1,    15,    -1,    17,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    31,
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
     172,    -1,    -1,   175,   176,    -1,    -1,   179,    -1,    -1,
      -1,    -1,    -1,   185,   186,    -1,    -1,    -1,   190,    -1,
      -1,    -1,    -1,   195,    -1,   197,    -1,   199,   200,    -1,
      -1,   203,   204,   205,     6,    -1,     8,     9,    -1,    -1,
      -1,    -1,    14,    15,    -1,    17,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    31,
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
     172,    -1,    -1,   175,   176,    -1,    -1,   179,    -1,    -1,
      -1,    -1,    -1,   185,   186,    -1,    -1,    -1,   190,    -1,
      -1,    -1,    -1,   195,    -1,   197,    -1,   199,   200,    -1,
      -1,   203,   204,   205,     6,    -1,     8,     9,    -1,    -1,
      -1,    -1,    -1,    15,    -1,    17,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    31,
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
     172,    -1,    -1,   175,   176,    -1,    -1,   179,    -1,    -1,
      -1,     6,    -1,   185,   186,    10,    11,    -1,   190,    -1,
      15,    -1,    17,   195,    -1,   197,    -1,   199,   200,    -1,
      -1,   203,   204,   205,    -1,    -1,    31,    32,    -1,    -1,
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
     175,   176,    -1,    -1,   179,    -1,    -1,     6,    -1,    -1,
     185,   186,    -1,    -1,    -1,   190,    15,    -1,    17,    -1,
     195,    -1,   197,    -1,   199,   200,    -1,    -1,   203,   204,
     205,    -1,    31,    32,    -1,    -1,    -1,    -1,    37,    38,
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
       6,    -1,   171,   172,    -1,    -1,   175,   176,    -1,    15,
     179,    17,    -1,    -1,    -1,    -1,   185,   186,    -1,    -1,
      26,   190,    -1,    -1,    -1,    59,   195,    -1,   197,     6,
     199,   200,    66,    -1,   203,   204,   205,    -1,    15,    -1,
      17,    -1,    48,    49,    78,    79,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,     6,    -1,
      -1,    67,    -1,    -1,    -1,    -1,    -1,    15,    -1,    17,
      -1,    48,    49,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    87,    -1,    -1,    -1,    -1,    -1,    93,    -1,   123,
      67,    -1,    -1,    -1,   128,   129,    -1,    -1,    -1,    -1,
      48,    49,    -1,    -1,    -1,    -1,    -1,    -1,   142,   115,
      87,   117,    -1,   119,   120,    -1,    93,    -1,    -1,    67,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    87,
     117,    -1,   119,   120,    -1,    93,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   160,    -1,   190,   191,   192,   193,
     194,   195,   196,   197,   198,   199,   200,    -1,   174,   117,
      -1,   119,   120,    -1,    -1,    -1,    -1,   183,   184,    -1,
      -1,    -1,    -1,   160,    -1,   191,   192,   193,    -1,   195,
     196,   197,   198,    -1,    -1,    -1,    -1,   174,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   183,   184,    -1,    15,
      59,    17,   160,    -1,   191,   192,   193,    66,   195,   196,
     197,   198,    -1,    -1,    -1,    -1,   174,    -1,    -1,    78,
      79,    -1,    -1,    -1,    -1,   183,   184,    -1,    -1,    -1,
      -1,    -1,    48,   191,   192,   193,    -1,   195,   196,   197,
     198,    57,    -1,    59,    -1,    -1,    -1,    -1,    -1,    -1,
      66,    67,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    78,    79,   123,    -1,    -1,    -1,    -1,   128,
     129,    87,    -1,    -1,    -1,    -1,    -1,    93,    -1,    -1,
      -1,    -1,    -1,   142,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   112,    -1,    -1,    -1,
      -1,   117,    -1,   119,   120,    -1,    -1,   123,    -1,    -1,
      -1,    -1,   128,   129,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   142,    -1,    -1,    -1,
      -1,   190,   191,   192,   193,    -1,   195,   196,   197,   198,
     199,   200,    -1,    -1,   160,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    15,    -1,    17,    -1,    -1,   174,    21,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    30,    -1,
      -1,    -1,    -1,    -1,   190,   191,   192,   193,   194,   195,
     196,   197,   198,   199,   200,   201,    -1,   203,   204,   205,
      52,    53,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    63,    -1,    -1,    -1,    -1,    68,    -1,    -1,    -1,
      -1,    73,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    84,    -1,    -1,    -1,    88,    -1,    -1,    91,
      92,    -1,    94,    -1,    -1,    -1,    98,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     112,    -1,    -1,    -1,    -1,    -1,    -1,   119,   120,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   130,   131,
      -1,    -1,    -1,   135,   136,   137,   138,    -1,    -1,    -1,
      -1,    -1,   144,   145,   146,    -1,    -1,    -1,   150,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   159,   160,    -1,
      -1,    -1,    15,    -1,    17,    -1,   168,    -1,    21,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   178,    30,   180,    -1,
     182,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   190,   191,
     192,   193,   194,   195,   196,   197,   198,   199,   200,    52,
      53,    -1,    -1,    -1,    -1,    -1,    -1,    60,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    68,    -1,    -1,    -1,    -1,
      73,    -1,    -1,    -1,    77,    -1,    -1,    -1,    -1,    -1,
      -1,    84,    -1,    -1,    -1,    88,    -1,    -1,    91,    92,
      -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   112,
      -1,    -1,    -1,    -1,    -1,    -1,   119,   120,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   130,   131,    -1,
      -1,    -1,   135,   136,   137,   138,    -1,    -1,    -1,    -1,
      -1,   144,   145,   146,    15,    -1,    17,   150,    -1,    -1,
      21,    -1,    -1,    -1,    -1,    -1,   159,   160,    -1,    30,
      -1,    -1,    -1,    -1,    -1,   168,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   178,    -1,   180,    -1,   182,
      -1,    52,    53,    -1,    -1,    -1,    -1,   190,   191,   192,
     193,   194,   195,   196,   197,   198,   199,   200,    -1,    -1,
      -1,    -1,    73,    -1,    -1,    76,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    84,    -1,    -1,    -1,    88,    -1,    -1,
      91,    92,    -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   112,    -1,    -1,    -1,    -1,    -1,    -1,   119,   120,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   130,
     131,    -1,    -1,    -1,   135,    -1,   137,   138,    -1,    -1,
      -1,    -1,    -1,   144,   145,   146,    15,    -1,    17,   150,
      -1,    -1,    21,    -1,    -1,    -1,    -1,    -1,    -1,   160,
      -1,    30,    -1,    -1,    -1,    -1,   167,   168,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   178,    -1,   180,
      -1,   182,    -1,    52,    53,    -1,    -1,    -1,    -1,   190,
     191,   192,   193,   194,   195,   196,   197,   198,   199,   200,
      -1,    -1,    -1,    -1,    73,    -1,    -1,    76,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    84,    -1,    86,    -1,    88,
      -1,    -1,    -1,    92,    -1,    94,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   112,    -1,    -1,    -1,    -1,    -1,    -1,
     119,   120,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   130,   131,    -1,    -1,    -1,   135,    -1,   137,   138,
      -1,    -1,    -1,    -1,    -1,   144,   145,   146,    -1,    -1,
      -1,   150,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   160,    -1,    -1,    -1,    -1,    -1,   166,    -1,   168,
      15,    -1,    17,    -1,    -1,    -1,    21,    -1,    -1,   178,
      -1,   180,    -1,   182,    -1,    30,    -1,    -1,    -1,    -1,
      -1,    -1,   191,   192,   193,   194,   195,   196,   197,   198,
     199,   200,    -1,    -1,    -1,    -1,    -1,    52,    53,    -1,
      -1,    -1,    -1,    -1,    -1,    60,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    73,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    84,
      -1,    86,    -1,    88,    -1,    -1,    -1,    92,    -1,    94,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   112,    -1,    -1,
      -1,    -1,    -1,    -1,   119,   120,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   130,   131,    -1,    -1,    -1,
     135,    -1,   137,   138,    -1,    -1,    -1,    -1,    -1,   144,
     145,   146,    -1,    -1,    -1,   150,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   160,    -1,    -1,    -1,    -1,
      -1,   166,    -1,   168,    15,    -1,    17,    -1,    -1,    -1,
      21,    -1,    -1,   178,    -1,   180,    -1,   182,    -1,    30,
      -1,    -1,    -1,    -1,    -1,    -1,   191,   192,   193,   194,
     195,   196,   197,   198,   199,   200,    -1,    -1,    -1,    -1,
      -1,    52,    53,    -1,    -1,    -1,    -1,    -1,    -1,    60,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    73,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    84,    -1,    -1,    -1,    88,    -1,    -1,
      91,    92,    -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   112,    -1,    -1,    -1,    -1,    -1,    -1,   119,   120,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   130,
     131,    -1,    -1,    -1,   135,    -1,   137,   138,    -1,    -1,
      -1,    -1,    -1,   144,   145,   146,    15,    -1,    17,   150,
      -1,    -1,    21,    -1,    -1,    -1,    -1,    -1,    -1,   160,
      -1,    30,    -1,    -1,    -1,    -1,    -1,   168,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   178,    -1,   180,
      -1,   182,    -1,    52,    53,    -1,    -1,    -1,    -1,   190,
     191,   192,   193,   194,   195,   196,   197,   198,   199,   200,
      -1,    -1,    -1,    -1,    73,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    84,    -1,    86,    -1,    88,
      -1,    -1,    -1,    92,    -1,    94,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   112,    -1,    -1,    -1,    -1,    -1,    -1,
     119,   120,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   130,   131,    -1,    -1,    -1,   135,    -1,   137,   138,
      -1,    -1,    -1,    -1,    -1,   144,   145,   146,    15,    -1,
      17,   150,    -1,    -1,    21,    -1,    -1,    -1,    -1,    -1,
      -1,   160,    -1,    30,    -1,    -1,    -1,   166,    -1,   168,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   178,
      -1,   180,    -1,   182,    -1,    52,    53,    -1,    -1,    -1,
      -1,    -1,   191,   192,   193,   194,   195,   196,   197,   198,
     199,   200,    -1,    -1,    -1,    -1,    73,    -1,    -1,    -1,
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
      -1,    -1,    -1,    -1,   191,   192,   193,   194,   195,   196,
     197,   198,   199,   200,    -1,    -1,    -1,    -1,    73,    -1,
      -1,    76,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    84,
      -1,    -1,    -1,    88,    -1,    -1,    -1,    92,    -1,    94,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   112,    -1,    -1,
      -1,    -1,    -1,    -1,   119,   120,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   130,   131,    -1,    -1,    -1,
     135,    -1,   137,   138,    -1,    -1,    -1,    -1,    -1,   144,
     145,   146,    -1,    -1,    -1,   150,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   160,    -1,    -1,    -1,    15,
      -1,    17,    -1,   168,    -1,    21,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   178,    30,   180,    -1,   182,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   191,   192,   193,   194,
     195,   196,   197,   198,   199,   200,    52,    53,    -1,    -1,
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
      -1,    -1,    -1,    -1,    -1,   191,   192,   193,   194,   195,
     196,   197,   198,   199,   200,    -1,    -1,    -1,    -1,    73,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    59,
      84,    -1,    -1,    -1,    88,    -1,    66,    -1,    92,    -1,
      94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    78,    79,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   112,    -1,
      -1,    -1,    -1,    -1,    -1,   119,   120,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   130,   131,    -1,    -1,
      -1,   135,   112,   137,   138,    15,   116,    17,    -1,    -1,
     144,   145,   146,   123,    -1,    -1,   150,    -1,   128,   129,
      -1,    -1,    -1,    -1,    -1,    -1,   160,    -1,    -1,    -1,
      -1,    -1,   142,    -1,   168,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   178,    -1,   180,    -1,   182,    59,
     160,    -1,    -1,    -1,    -1,    -1,    66,   191,   192,   193,
     194,   195,   196,   197,   198,   199,   200,    -1,    78,    79,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     190,   191,   192,   193,   194,   195,   196,   197,   198,   199,
     200,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   112,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   123,    -1,    -1,    -1,    -1,   128,   129,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   142,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     160,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     190,   191,   192,   193,   194,   195,   196,   197,   198,   199,
     200,    33,    -1,    35,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    44,    -1,    -1,    47,    -1,    49,    50,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    58,    -1,    -1,    -1,
      -1,    63,    -1,    -1,    -1,    -1,    -1,    69,    -1,    -1,
      -1,    -1,    74,    -1,    -1,    -1,    -1,    -1,    -1,    81,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    91,
      -1,    -1,    -1,    -1,    -1,    -1,    98,    99,    -1,   101,
      -1,    -1,    -1,   105,    -1,   107,    -1,    -1,    -1,    -1,
      -1,    -1,   114,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   125,    -1,   127,    -1,    -1,    -1,    -1,
      -1,    -1,   134,    -1,    -1,    -1,    -1,   139,    -1,    -1,
      -1,   143,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   153,    -1,    -1,    -1,    -1,   158,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   166,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   179,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   190,   191,
     192,   193,   194,   195,   196,   197,   198,    33,   200,    35,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    44,    -1,
      -1,    47,    -1,    49,    50,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    58,    -1,    -1,    -1,    -1,    63,    -1,    -1,
      -1,    -1,    -1,    69,    -1,    -1,    -1,    -1,    74,    -1,
      -1,    -1,    -1,    -1,    -1,    81,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    91,    -1,    -1,    -1,    -1,
      -1,    -1,    98,    99,    -1,   101,    -1,    -1,    -1,   105,
      33,   107,    35,    -1,    -1,    -1,    -1,    -1,   114,    -1,
      -1,    -1,    -1,    -1,    47,    -1,    49,    50,    -1,   125,
      -1,   127,    -1,    -1,    -1,    58,    -1,    -1,   134,    -1,
      63,    -1,    -1,   139,    -1,    -1,    69,   143,    -1,    -1,
      -1,    74,    -1,    -1,    -1,    -1,    -1,   153,    81,    -1,
      -1,    -1,   158,    -1,    -1,    -1,    -1,    -1,    91,    -1,
     166,    -1,    -1,    -1,    -1,    98,    99,    -1,   101,    -1,
      -1,    -1,   105,   179,   107,    -1,    -1,    -1,    -1,    -1,
      -1,   114,    33,    -1,    35,    -1,    -1,    -1,    -1,   195,
      -1,    -1,   125,    -1,    -1,    -1,    47,    -1,    49,    50,
      -1,   134,    -1,    -1,    -1,    -1,   139,    58,    -1,    -1,
     143,    -1,    63,    -1,    -1,    -1,    -1,    -1,    69,    -1,
     153,    -1,    -1,    74,    -1,   158,    -1,    -1,    -1,    -1,
      81,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   179,    98,    99,    -1,
     101,    -1,    -1,    -1,   105,    -1,   107,    -1,    -1,    -1,
      -1,    -1,   195,   114,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   134,    -1,    -1,    -1,    -1,   139,    -1,
      -1,    -1,   143,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   153,    -1,    -1,    -1,    -1,   158,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   179,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   195
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int16 yystos[] =
{
       0,    15,    17,    21,    30,    52,    53,    63,    68,    73,
      84,    88,    91,    92,    94,    98,   112,   119,   120,   130,
     131,   135,   136,   137,   138,   144,   145,   146,   150,   159,
     160,   168,   178,   180,   182,   190,   191,   192,   193,   194,
     195,   196,   197,   198,   199,   200,   212,   226,   237,   259,
     261,   266,   267,   269,   270,   272,   278,   281,   283,   285,
     286,   287,   288,   289,   290,   291,   292,   294,   295,   296,
     297,   298,   299,   300,   306,   307,   308,   309,   310,   313,
     315,   316,   317,   318,   321,   322,   324,   325,   327,   328,
     333,   334,   335,   337,   349,   363,   364,   365,   366,   367,
     368,   371,   372,   380,   383,   386,   389,   390,   391,   392,
     393,   394,   395,   396,   237,   290,   212,   196,   260,   270,
     290,     6,    33,    35,    44,    47,    49,    50,    58,    69,
      74,    81,    91,    99,   101,   105,   107,   114,   125,   127,
     134,   139,   143,   153,   158,   166,   179,   190,   192,   193,
     195,   196,   197,   198,   207,   208,   209,   210,   211,   212,
     213,   214,   215,   216,   217,   243,   269,   281,   291,   346,
     347,   348,   349,   353,   355,   356,   357,   358,   360,   362,
      21,    54,    90,   177,   181,   338,   339,   340,   343,    21,
     270,     6,    21,   356,   357,   358,   362,   170,     6,    80,
      80,     6,     6,    21,   270,   212,   384,   261,   290,     6,
       8,     9,    15,    17,    21,    26,    31,    32,    37,    38,
      39,    40,    41,    42,    43,    48,    49,    56,    57,    58,
      59,    64,    65,    66,    67,    71,    72,    78,    79,    85,
      87,    89,    91,    93,    97,    99,   100,   102,   104,   106,
     107,   108,   109,   110,   111,   113,   115,   116,   117,   118,
     119,   120,   123,   126,   128,   129,   133,   140,   141,   142,
     143,   147,   148,   149,   151,   152,   154,   155,   157,   161,
     164,   165,   171,   172,   173,   174,   175,   176,   179,   183,
     184,   185,   186,   190,   192,   193,   197,   201,   203,   204,
     205,   218,   219,   220,   221,   222,   223,   225,   226,   227,
     228,   229,   230,   231,   232,   233,   236,   238,   239,   250,
     251,   252,   256,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   268,   271,   275,   276,   277,   278,   279,   280,
     282,   283,   286,   288,   290,   260,    80,   261,   261,   291,
     387,   124,     6,    22,    19,   240,   241,   244,   245,   285,
     288,   290,     6,   240,   240,    22,   240,   240,     6,     4,
      28,   293,     6,     4,    11,   240,   293,    21,   178,   294,
     295,   309,   294,     6,   218,   250,   252,   258,   275,   282,
     286,   302,   303,   304,   305,   294,    21,    36,    86,   166,
     178,   295,   296,     6,    21,    45,   311,    76,   167,   306,
     309,   314,   344,    21,    61,   103,   122,   156,   163,   285,
     319,   323,    21,   195,   236,   320,   323,     4,    21,     4,
      21,   293,     4,     6,    90,   177,   197,   218,   290,    21,
     260,   326,    46,    96,   120,   124,     4,    21,    70,   329,
     330,   331,   332,   338,    21,     6,    21,   228,   230,   232,
     260,   263,   279,   284,   285,   336,   345,   294,   218,   236,
     350,   351,   352,     0,   306,   380,   383,   386,    60,    77,
     306,   309,   369,   370,   375,   376,   380,   383,   386,    21,
      33,   139,    83,   132,    62,    91,   125,   127,     6,   355,
     373,   378,   379,   311,   374,   378,   381,    21,   369,   370,
     369,   370,   369,   370,   369,   370,    16,    11,    18,   240,
      11,     6,     6,     6,     6,     6,     6,     6,    91,    91,
     125,   211,    81,   347,    21,     4,   211,   112,   243,    10,
     218,   354,     4,   208,   354,   348,    10,   236,   350,   195,
     209,   347,     9,   359,   361,   218,   167,   226,   290,   250,
     302,    21,    21,   339,   218,   341,    21,   228,    21,    21,
      21,    21,   270,    21,   240,    95,   162,   240,   228,   228,
      21,     6,    51,    11,   218,   250,   275,   290,   259,   290,
     259,   290,    27,   240,   273,   274,     6,   273,     6,   240,
       6,   240,     6,   240,     6,   240,     6,     6,     6,     6,
      25,    55,   220,   221,   257,   219,   219,     7,    10,    11,
     222,    12,    13,   224,    19,   241,     4,     5,    21,   240,
       6,    23,   121,   253,   254,    24,    36,   255,   257,     6,
      15,    17,   256,   290,   265,     6,   236,     6,   257,     6,
       6,    11,    21,   240,    22,   347,   209,   388,   170,   260,
     228,    86,    91,     6,   226,   228,    10,    14,   218,   246,
     247,   248,   249,     4,     5,    21,    22,     5,     6,   284,
     285,   292,   236,   321,   218,   234,   235,   236,   290,   292,
     237,   269,   272,   281,   291,   236,    75,   218,   275,   302,
      27,    29,   187,   188,   189,   293,   169,   301,    27,    29,
     187,   188,   189,   293,     6,    27,    29,   187,   188,   189,
     293,    27,    29,   187,   188,   189,   293,    27,    29,   187,
     188,   189,   293,   253,   301,   255,   333,   234,     6,   270,
     207,   309,   314,    21,     6,     6,     6,     6,     6,   319,
     320,   236,   290,   218,   218,    70,   250,   218,    21,    11,
       4,    21,   218,   218,   250,     6,   135,    21,   332,    34,
      82,     6,   218,   250,   290,     4,     5,    14,     5,     4,
       6,   285,   345,   350,    21,   190,   270,    86,   309,   369,
      21,   306,   369,   376,    21,   355,   191,   194,   195,   197,
     198,   200,   377,   378,   381,    21,   369,    21,   369,    21,
     369,    21,   369,   240,   240,   270,   354,   354,   354,   354,
     229,   211,   211,   347,   347,   216,     5,     4,     5,     5,
       5,   159,   354,    21,   212,   293,    11,    21,   170,   342,
       4,    21,    21,    95,   162,     5,     5,   212,   385,   202,
     382,     5,     5,     5,    16,    11,    18,    19,   228,   350,
       6,   350,     6,   350,     6,   350,     6,   234,   234,   234,
     234,   219,   219,     6,   193,   218,   276,   290,   219,   222,
     222,   223,     6,    10,   350,   234,   251,   252,   256,   258,
      11,   228,     5,   234,   218,   276,   234,   116,   284,   238,
      21,   229,    22,     4,    21,   218,   170,     5,    91,    20,
     242,    46,   218,   248,   170,   220,   221,     5,   293,    21,
      14,     4,     5,   240,   240,   240,   240,     5,   218,   218,
     218,   218,   218,   218,   252,   252,   252,   252,   252,   252,
     302,   218,   275,   275,   275,   275,   275,   275,   282,   282,
     282,   282,   282,   282,   196,   286,   290,   286,   286,   286,
     286,   286,   252,   303,   304,    21,     5,   285,   290,   312,
      21,   218,   218,   218,   218,   218,    21,    21,     5,    21,
      21,    21,   260,   218,   218,   218,    11,    21,     4,     5,
     212,    21,     4,     5,    21,    21,    21,    21,   240,     5,
       5,     5,     4,     5,     6,     5,    75,    28,   218,   218,
       4,     5,   240,   240,     6,     5,   350,   350,   350,   350,
       5,     5,     5,     5,    11,    20,     5,     5,   256,     5,
       5,     5,     5,     5,   240,   229,   229,    21,   218,    20,
     243,   264,   218,   248,   219,   219,   236,   235,     5,    21,
     311,     4,     5,     5,     5,     5,     5,     5,     5,   170,
      51,   212,    20,   265,   243,    21,     4,     5,     5,     5,
       6,   285,   290,    21,   285,   218,   264,     4,    20,   242,
     312,    21,     5,   218,     5,     5,    21
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int16 yyr1[] =
{
       0,   206,   207,   207,   208,   208,   208,   209,   209,   209,
     209,   209,   209,   209,   209,   209,   209,   209,   209,   209,
     209,   210,   210,   210,   210,   210,   211,   211,   211,   212,
     213,   213,   214,   214,   215,   215,   215,   215,   216,   216,
     217,   217,   217,   217,   217,   217,   217,   217,   218,   218,
     218,   218,   218,   219,   219,   220,   221,   222,   222,   222,
     222,   223,   223,   223,   224,   225,   225,   225,   225,   226,
     226,   226,   226,   226,   226,   226,   226,   227,   227,   227,
     227,   227,   227,   227,   227,   227,   228,   228,   229,   230,
     231,   232,   232,   232,   232,   233,   233,   233,   233,   233,
     233,   233,   233,   233,   234,   234,   235,   235,   235,   236,
     236,   236,   236,   236,   237,   237,   238,   238,   238,   238,
     238,   238,   238,   238,   238,   239,   239,   239,   239,   239,
     239,   239,   239,   239,   239,   239,   239,   239,   239,   239,
     239,   239,   239,   239,   239,   239,   239,   239,   239,   239,
     239,   239,   239,   239,   239,   239,   239,   239,   239,   239,
     239,   239,   239,   239,   239,   239,   239,   239,   239,   240,
     240,   240,   240,   241,   241,   241,   241,   242,   242,   243,
     243,   244,   244,   244,   244,   244,   245,   245,   246,   246,
     246,   246,   247,   248,   248,   249,   249,   249,   250,   250,
     251,   251,   252,   252,   252,   252,   253,   253,   254,   255,
     255,   256,   256,   256,   256,   256,   256,   256,   256,   256,
     256,   256,   256,   257,   257,   258,   258,   259,   259,   259,
     259,   260,   260,   260,   260,   261,   261,   261,   261,   262,
     262,   263,   263,   263,   263,   263,   264,   264,   264,   264,
     265,   266,   266,   267,   268,   268,   268,   269,   270,   270,
     270,   270,   271,   271,   272,   273,   273,   274,   275,   275,
     275,   275,   275,   276,   276,   276,   276,   277,   277,   278,
     278,   278,   278,   279,   279,   280,   280,   280,   280,   280,
     281,   282,   282,   282,   283,   284,   284,   284,   285,   285,
     285,   285,   285,   285,   285,   286,   286,   286,   286,   287,
     288,   289,   290,   290,   291,   292,   292,   292,   292,   293,
     294,   294,   294,   295,   295,   295,   295,   295,   295,   295,
     295,   295,   295,   295,   295,   295,   295,   295,   295,   295,
     295,   295,   295,   295,   295,   295,   295,   295,   295,   295,
     295,   295,   295,   295,   295,   295,   295,   295,   295,   295,
     295,   295,   295,   295,   296,   296,   296,   297,   297,   298,
     298,   299,   300,   301,   302,   302,   303,   303,   304,   304,
     304,   305,   305,   305,   305,   305,   305,   305,   305,   305,
     305,   305,   305,   305,   305,   305,   305,   305,   305,   305,
     305,   305,   305,   305,   305,   305,   305,   305,   305,   305,
     305,   306,   306,   307,   307,   308,   308,   308,   308,   309,
     310,   311,   312,   312,   312,   312,   313,   313,   313,   313,
     313,   313,   313,   313,   314,   314,   314,   315,   315,   316,
     317,   317,   318,   318,   319,   319,   320,   320,   320,   321,
     322,   323,   323,   323,   323,   323,   324,   325,   325,   326,
     326,   327,   327,   327,   327,   328,   328,   328,   329,   329,
     329,   330,   330,   330,   331,   332,   332,   333,   333,   333,
     334,   335,   335,   336,   336,   337,   338,   338,   339,   339,
     340,   340,   341,   341,   342,   342,   343,   343,   344,   345,
     345,   345,   345,   346,   346,   347,   347,   348,   348,   348,
     348,   348,   348,   348,   348,   348,   348,   348,   348,   349,
     349,   349,   350,   350,   350,   350,   350,   351,   352,   352,
     353,   354,   354,   355,   355,   355,   355,   355,   356,   356,
     357,   358,   359,   359,   360,   361,   362,   362,   362,   363,
     363,   363,   363,   363,   363,   363,   363,   363,   364,   364,
     365,   366,   366,   366,   366,   366,   367,   367,   367,   367,
     367,   367,   367,   367,   367,   368,   368,   369,   369,   369,
     369,   370,   370,   370,   371,   371,   371,   372,   373,   373,
     373,   374,   374,   374,   375,   375,   376,   376,   376,   376,
     377,   377,   377,   377,   377,   377,   378,   379,   379,   380,
     381,   382,   383,   384,   384,   385,   385,   386,   387,   387,
     387,   388,   389,   389,   389,   389,   390,   390,   391,   391,
     392,   392,   393,   394,   394,   395,   396
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     1,     3,     2,     1,     1,     1,     2,     1,
       2,     3,     2,     3,     3,     2,     2,     2,     3,     1,
       2,     3,     1,     1,     1,     1,     1,     2,     1,     1,
       3,     1,     2,     4,     1,     1,     1,     1,     1,     2,
       1,     2,     1,     1,     1,     1,     1,     1,     1,     2,
       2,     3,     3,     1,     3,     1,     1,     1,     3,     3,
       2,     1,     3,     2,     1,     1,     1,     1,     2,     1,
       2,     3,     4,     3,     4,     3,     4,     3,     1,     1,
       4,     4,     4,     2,     4,     4,     1,     1,     1,     1,
       1,     1,     2,     3,     4,     3,     3,     3,     3,     4,
       4,     4,     4,     3,     1,     3,     1,     3,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     2,
       1,     2,     2,     5,     5,     8,     5,     1,     2,     1,
       1,     2,     5,     2,     2,     2,     1,     2,     1,     1,
       2,     3,     2,     1,     1,     1,     3,     3,     1,     3,
       1,     3,     1,     3,     2,     4,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     3,     3,     4,     4,     3,
       4,     3,     4,     1,     1,     1,     1,     1,     2,     3,
       4,     1,     2,     3,     4,     1,     2,     3,     4,     1,
       4,     2,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     2,     3,     1,     1,     1,     2,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     6,     1,     3,
       3,     3,     3,     1,     1,     4,     3,     1,     2,     1,
       2,     3,     4,     1,     5,     1,     1,     1,     1,     1,
       1,     4,     1,     4,     1,     1,     1,     1,     1,     1,
       3,     1,     4,     1,     1,     1,     4,     3,     4,     1,
       2,     1,     1,     3,     1,     3,     3,     3,     3,     1,
       1,     1,     1,     2,     2,     2,     3,     2,     3,     4,
       1,     2,     5,     6,     9,     2,     3,     3,     2,     2,
       2,     2,     4,     4,     4,     4,     3,     4,     4,     2,
       3,     5,     6,     2,     3,     2,     4,     3,     2,     4,
       4,     3,     2,     4,     1,     2,     2,     2,     2,     3,
       3,     3,     1,     1,     1,     3,     1,     3,     3,     4,
       1,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     1,     1,     3,     2,     4,     4,     3,     3,     2,
       2,     1,     1,     3,     1,     3,     2,     3,     4,     3,
       4,     2,     2,     2,     1,     2,     2,     4,     4,     4,
       2,     3,     2,     3,     1,     1,     1,     1,     1,     4,
       3,     4,     4,     4,     4,     4,     1,     1,     1,     1,
       3,     2,     3,     3,     3,     1,     5,     2,     1,     1,
       2,     3,     3,     1,     2,     2,     2,     2,     2,     2,
       2,     2,     3,     1,     1,     5,     1,     1,     2,     2,
       3,     2,     1,     3,     2,     4,     3,     4,     3,     1,
       1,     1,     1,     2,     3,     1,     2,     1,     1,     1,
       1,     1,     4,     1,     1,     3,     3,     1,     4,     2,
       2,     3,     1,     2,     2,     3,     1,     2,     2,     3,
       2,     1,     1,     1,     1,     1,     1,     1,     1,     4,
       4,     2,     2,     3,     1,     3,     1,     1,     2,     1,
       2,     1,     2,     1,     2,     2,     3,     3,     3,     4,
       2,     2,     2,     1,     2,     2,     2,     2,     2,     2,
       1,     1,     2,     1,     2,     1,     2,     1,     2,     2,
       2,     1,     1,     2,     2,     3,     4,     2,     1,     1,
       2,     1,     1,     2,     1,     2,     1,     2,     1,     6,
       1,     1,     1,     1,     1,     1,     3,     1,     3,     3,
       2,     1,     4,     1,     4,     1,     3,     3,     3,     4,
       4,     2,     1,     1,     1,     1,     3,     4,     3,     2,
       3,     4,     3,     3,     4,     3,     3
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
#line 649 "HAL_S.y"
                                { (yyval.declare_body_) = make_AAdeclareBody_declarationList((yyvsp[0].declaration_list_)); (yyval.declare_body_)->line_number = (yyloc).first_line; (yyval.declare_body_)->char_number = (yyloc).first_column;  }
#line 4432 "Parser.c"
    break;

  case 3: /* DECLARE_BODY: ATTRIBUTES _SYMB_0 DECLARATION_LIST  */
#line 650 "HAL_S.y"
                                        { (yyval.declare_body_) = make_ABdeclareBody_attributes_declarationList((yyvsp[-2].attributes_), (yyvsp[0].declaration_list_)); (yyval.declare_body_)->line_number = (yyloc).first_line; (yyval.declare_body_)->char_number = (yyloc).first_column;  }
#line 4438 "Parser.c"
    break;

  case 4: /* ATTRIBUTES: ARRAY_SPEC TYPE_AND_MINOR_ATTR  */
#line 652 "HAL_S.y"
                                            { (yyval.attributes_) = make_AAattributes_arraySpec_typeAndMinorAttr((yyvsp[-1].array_spec_), (yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4444 "Parser.c"
    break;

  case 5: /* ATTRIBUTES: ARRAY_SPEC  */
#line 653 "HAL_S.y"
               { (yyval.attributes_) = make_ABattributes_arraySpec((yyvsp[0].array_spec_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4450 "Parser.c"
    break;

  case 6: /* ATTRIBUTES: TYPE_AND_MINOR_ATTR  */
#line 654 "HAL_S.y"
                        { (yyval.attributes_) = make_ACattributes_typeAndMinorAttr((yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4456 "Parser.c"
    break;

  case 7: /* DECLARATION: NAME_ID  */
#line 656 "HAL_S.y"
                      { (yyval.declaration_) = make_AAdeclaration_nameId((yyvsp[0].name_id_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4462 "Parser.c"
    break;

  case 8: /* DECLARATION: NAME_ID ATTRIBUTES  */
#line 657 "HAL_S.y"
                       { (yyval.declaration_) = make_ABdeclaration_nameId_attributes((yyvsp[-1].name_id_), (yyvsp[0].attributes_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4468 "Parser.c"
    break;

  case 9: /* DECLARATION: _SYMB_193  */
#line 658 "HAL_S.y"
              { (yyval.declaration_) = make_ACdeclaration_labelToken((yyvsp[0].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4474 "Parser.c"
    break;

  case 10: /* DECLARATION: _SYMB_193 TYPE_AND_MINOR_ATTR  */
#line 659 "HAL_S.y"
                                  { (yyval.declaration_) = make_ACdeclaration_labelToken_type_minorAttrList((yyvsp[-1].string_), (yyvsp[0].type_and_minor_attr_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4480 "Parser.c"
    break;

  case 11: /* DECLARATION: _SYMB_193 _SYMB_121 MINOR_ATTR_LIST  */
#line 660 "HAL_S.y"
                                        { (yyval.declaration_) = make_ACdeclaration_labelToken_procedure_minorAttrList((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4486 "Parser.c"
    break;

  case 12: /* DECLARATION: _SYMB_193 _SYMB_121  */
#line 661 "HAL_S.y"
                        { (yyval.declaration_) = make_ADdeclaration_labelToken_procedure((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4492 "Parser.c"
    break;

  case 13: /* DECLARATION: _SYMB_193 _SYMB_87 TYPE_AND_MINOR_ATTR  */
#line 662 "HAL_S.y"
                                           { (yyval.declaration_) = make_ACdeclaration_labelToken_function_minorAttrList((yyvsp[-2].string_), (yyvsp[0].type_and_minor_attr_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4498 "Parser.c"
    break;

  case 14: /* DECLARATION: _SYMB_186 _SYMB_87 TYPE_AND_MINOR_ATTR  */
#line 663 "HAL_S.y"
                                           { (yyval.declaration_) = make_ADdeclaration_labelToken_function_minorAttrList((yyvsp[-2].string_), (yyvsp[0].type_and_minor_attr_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4504 "Parser.c"
    break;

  case 15: /* DECLARATION: _SYMB_193 _SYMB_87  */
#line 664 "HAL_S.y"
                       { (yyval.declaration_) = make_ADdeclaration_labelToken_function((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4510 "Parser.c"
    break;

  case 16: /* DECLARATION: _SYMB_186 _SYMB_87  */
#line 665 "HAL_S.y"
                       { (yyval.declaration_) = make_AEdeclaration_labelToken_function((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4516 "Parser.c"
    break;

  case 17: /* DECLARATION: _SYMB_194 _SYMB_77  */
#line 666 "HAL_S.y"
                       { (yyval.declaration_) = make_AEdeclaration_eventToken_event((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4522 "Parser.c"
    break;

  case 18: /* DECLARATION: _SYMB_194 _SYMB_77 MINOR_ATTR_LIST  */
#line 667 "HAL_S.y"
                                       { (yyval.declaration_) = make_AFdeclaration_eventToken_event_minorAttrList((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4528 "Parser.c"
    break;

  case 19: /* DECLARATION: _SYMB_194  */
#line 668 "HAL_S.y"
              { (yyval.declaration_) = make_AGdeclaration_eventToken((yyvsp[0].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4534 "Parser.c"
    break;

  case 20: /* DECLARATION: _SYMB_194 MINOR_ATTR_LIST  */
#line 669 "HAL_S.y"
                              { (yyval.declaration_) = make_AHdeclaration_eventToken_minorAttrList((yyvsp[-1].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4540 "Parser.c"
    break;

  case 21: /* ARRAY_SPEC: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 671 "HAL_S.y"
                                                    { (yyval.array_spec_) = make_AAarraySpec_arrayHead_literalExpOrStar((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4546 "Parser.c"
    break;

  case 22: /* ARRAY_SPEC: _SYMB_87  */
#line 672 "HAL_S.y"
             { (yyval.array_spec_) = make_ABarraySpec_function(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4552 "Parser.c"
    break;

  case 23: /* ARRAY_SPEC: _SYMB_121  */
#line 673 "HAL_S.y"
              { (yyval.array_spec_) = make_ACarraySpec_procedure(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4558 "Parser.c"
    break;

  case 24: /* ARRAY_SPEC: _SYMB_123  */
#line 674 "HAL_S.y"
              { (yyval.array_spec_) = make_ADarraySpec_program(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4564 "Parser.c"
    break;

  case 25: /* ARRAY_SPEC: _SYMB_162  */
#line 675 "HAL_S.y"
              { (yyval.array_spec_) = make_AEarraySpec_task(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4570 "Parser.c"
    break;

  case 26: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC  */
#line 677 "HAL_S.y"
                                { (yyval.type_and_minor_attr_) = make_AAtypeAndMinorAttr_typeSpec((yyvsp[0].type_spec_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4576 "Parser.c"
    break;

  case 27: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC MINOR_ATTR_LIST  */
#line 678 "HAL_S.y"
                              { (yyval.type_and_minor_attr_) = make_ABtypeAndMinorAttr_typeSpec_minorAttrList((yyvsp[-1].type_spec_), (yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4582 "Parser.c"
    break;

  case 28: /* TYPE_AND_MINOR_ATTR: MINOR_ATTR_LIST  */
#line 679 "HAL_S.y"
                    { (yyval.type_and_minor_attr_) = make_ACtypeAndMinorAttr_minorAttrList((yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4588 "Parser.c"
    break;

  case 29: /* IDENTIFIER: _SYMB_196  */
#line 681 "HAL_S.y"
                       { (yyval.identifier_) = make_AAidentifier((yyvsp[0].string_)); (yyval.identifier_)->line_number = (yyloc).first_line; (yyval.identifier_)->char_number = (yyloc).first_column;  }
#line 4594 "Parser.c"
    break;

  case 30: /* SQ_DQ_NAME: DOUBLY_QUAL_NAME_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 683 "HAL_S.y"
                                                               { (yyval.sq_dq_name_) = make_AAsQdQName_doublyQualNameHead_literalExpOrStar((yyvsp[-2].doubly_qual_name_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 4600 "Parser.c"
    break;

  case 31: /* SQ_DQ_NAME: ARITH_CONV  */
#line 684 "HAL_S.y"
               { (yyval.sq_dq_name_) = make_ABsQdQName_arithConv((yyvsp[0].arith_conv_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 4606 "Parser.c"
    break;

  case 32: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_175 _SYMB_2  */
#line 686 "HAL_S.y"
                                          { (yyval.doubly_qual_name_head_) = make_AAdoublyQualNameHead_vector(); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 4612 "Parser.c"
    break;

  case 33: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_103 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_0  */
#line 687 "HAL_S.y"
                                                  { (yyval.doubly_qual_name_head_) = make_ABdoublyQualNameHead_matrix_literalExpOrStar((yyvsp[-1].literal_exp_or_star_)); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 4618 "Parser.c"
    break;

  case 34: /* ARITH_CONV: _SYMB_95  */
#line 689 "HAL_S.y"
                      { (yyval.arith_conv_) = make_AAarithConv_integer(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4624 "Parser.c"
    break;

  case 35: /* ARITH_CONV: _SYMB_139  */
#line 690 "HAL_S.y"
              { (yyval.arith_conv_) = make_ABarithConv_scalar(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4630 "Parser.c"
    break;

  case 36: /* ARITH_CONV: _SYMB_175  */
#line 691 "HAL_S.y"
              { (yyval.arith_conv_) = make_ACarithConv_vector(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4636 "Parser.c"
    break;

  case 37: /* ARITH_CONV: _SYMB_103  */
#line 692 "HAL_S.y"
              { (yyval.arith_conv_) = make_ADarithConv_matrix(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4642 "Parser.c"
    break;

  case 38: /* DECLARATION_LIST: DECLARATION  */
#line 694 "HAL_S.y"
                               { (yyval.declaration_list_) = make_AAdeclaration_list((yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 4648 "Parser.c"
    break;

  case 39: /* DECLARATION_LIST: DCL_LIST_COMMA DECLARATION  */
#line 695 "HAL_S.y"
                               { (yyval.declaration_list_) = make_ABdeclaration_list((yyvsp[-1].dcl_list_comma_), (yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 4654 "Parser.c"
    break;

  case 40: /* NAME_ID: IDENTIFIER  */
#line 697 "HAL_S.y"
                     { (yyval.name_id_) = make_AAnameId_identifier((yyvsp[0].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4660 "Parser.c"
    break;

  case 41: /* NAME_ID: IDENTIFIER _SYMB_108  */
#line 698 "HAL_S.y"
                         { (yyval.name_id_) = make_ABnameId_identifier_name((yyvsp[-1].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4666 "Parser.c"
    break;

  case 42: /* NAME_ID: BIT_ID  */
#line 699 "HAL_S.y"
           { (yyval.name_id_) = make_ACnameId_bitId((yyvsp[0].bit_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4672 "Parser.c"
    break;

  case 43: /* NAME_ID: CHAR_ID  */
#line 700 "HAL_S.y"
            { (yyval.name_id_) = make_ADnameId_charId((yyvsp[0].char_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4678 "Parser.c"
    break;

  case 44: /* NAME_ID: _SYMB_188  */
#line 701 "HAL_S.y"
              { (yyval.name_id_) = make_AEnameId_bitFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4684 "Parser.c"
    break;

  case 45: /* NAME_ID: _SYMB_189  */
#line 702 "HAL_S.y"
              { (yyval.name_id_) = make_AFnameId_charFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4690 "Parser.c"
    break;

  case 46: /* NAME_ID: _SYMB_191  */
#line 703 "HAL_S.y"
              { (yyval.name_id_) = make_AGnameId_structIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4696 "Parser.c"
    break;

  case 47: /* NAME_ID: _SYMB_192  */
#line 704 "HAL_S.y"
              { (yyval.name_id_) = make_AHnameId_structFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4702 "Parser.c"
    break;

  case 48: /* ARITH_EXP: TERM  */
#line 706 "HAL_S.y"
                 { (yyval.arith_exp_) = make_AAarithExpTerm((yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4708 "Parser.c"
    break;

  case 49: /* ARITH_EXP: PLUS TERM  */
#line 707 "HAL_S.y"
              { (yyval.arith_exp_) = make_ABarithExpPlusTerm((yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4714 "Parser.c"
    break;

  case 50: /* ARITH_EXP: MINUS TERM  */
#line 708 "HAL_S.y"
               { (yyval.arith_exp_) = make_ACarithMinusTerm((yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4720 "Parser.c"
    break;

  case 51: /* ARITH_EXP: ARITH_EXP PLUS TERM  */
#line 709 "HAL_S.y"
                        { (yyval.arith_exp_) = make_ADarithExpArithExpPlusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4726 "Parser.c"
    break;

  case 52: /* ARITH_EXP: ARITH_EXP MINUS TERM  */
#line 710 "HAL_S.y"
                         { (yyval.arith_exp_) = make_AEarithExpArithExpMinusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4732 "Parser.c"
    break;

  case 53: /* TERM: PRODUCT  */
#line 712 "HAL_S.y"
               { (yyval.term_) = make_AAtermNoDivide((yyvsp[0].product_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4738 "Parser.c"
    break;

  case 54: /* TERM: PRODUCT _SYMB_3 TERM  */
#line 713 "HAL_S.y"
                         { (yyval.term_) = make_ABtermDivide((yyvsp[-2].product_), (yyvsp[0].term_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4744 "Parser.c"
    break;

  case 55: /* PLUS: _SYMB_4  */
#line 715 "HAL_S.y"
               { (yyval.plus_) = make_AAplus(); (yyval.plus_)->line_number = (yyloc).first_line; (yyval.plus_)->char_number = (yyloc).first_column;  }
#line 4750 "Parser.c"
    break;

  case 56: /* MINUS: _SYMB_5  */
#line 717 "HAL_S.y"
                { (yyval.minus_) = make_AAminus(); (yyval.minus_)->line_number = (yyloc).first_line; (yyval.minus_)->char_number = (yyloc).first_column;  }
#line 4756 "Parser.c"
    break;

  case 57: /* PRODUCT: FACTOR  */
#line 719 "HAL_S.y"
                 { (yyval.product_) = make_AAproductSingle((yyvsp[0].factor_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4762 "Parser.c"
    break;

  case 58: /* PRODUCT: FACTOR _SYMB_6 PRODUCT  */
#line 720 "HAL_S.y"
                           { (yyval.product_) = make_ABproductCross((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4768 "Parser.c"
    break;

  case 59: /* PRODUCT: FACTOR _SYMB_7 PRODUCT  */
#line 721 "HAL_S.y"
                           { (yyval.product_) = make_ACproductDot((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4774 "Parser.c"
    break;

  case 60: /* PRODUCT: FACTOR PRODUCT  */
#line 722 "HAL_S.y"
                   { (yyval.product_) = make_ADproductMultiplication((yyvsp[-1].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4780 "Parser.c"
    break;

  case 61: /* FACTOR: PRIMARY  */
#line 724 "HAL_S.y"
                 { (yyval.factor_) = make_AAfactor((yyvsp[0].primary_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4786 "Parser.c"
    break;

  case 62: /* FACTOR: PRIMARY EXPONENTIATION FACTOR  */
#line 725 "HAL_S.y"
                                  { (yyval.factor_) = make_ABfactorExponentiation((yyvsp[-2].primary_), (yyvsp[-1].exponentiation_), (yyvsp[0].factor_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4792 "Parser.c"
    break;

  case 63: /* FACTOR: PRIMARY _SYMB_8  */
#line 726 "HAL_S.y"
                    { (yyval.factor_) = make_ABfactorTranspose((yyvsp[-1].primary_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4798 "Parser.c"
    break;

  case 64: /* EXPONENTIATION: _SYMB_9  */
#line 728 "HAL_S.y"
                         { (yyval.exponentiation_) = make_AAexponentiation(); (yyval.exponentiation_)->line_number = (yyloc).first_line; (yyval.exponentiation_)->char_number = (yyloc).first_column;  }
#line 4804 "Parser.c"
    break;

  case 65: /* PRIMARY: ARITH_VAR  */
#line 730 "HAL_S.y"
                    { (yyval.primary_) = make_AAprimary((yyvsp[0].arith_var_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4810 "Parser.c"
    break;

  case 66: /* PRIMARY: PRE_PRIMARY  */
#line 731 "HAL_S.y"
                { (yyval.primary_) = make_ADprimary((yyvsp[0].pre_primary_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4816 "Parser.c"
    break;

  case 67: /* PRIMARY: MODIFIED_ARITH_FUNC  */
#line 732 "HAL_S.y"
                        { (yyval.primary_) = make_ABprimary((yyvsp[0].modified_arith_func_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4822 "Parser.c"
    break;

  case 68: /* PRIMARY: PRE_PRIMARY QUALIFIER  */
#line 733 "HAL_S.y"
                          { (yyval.primary_) = make_AEprimary((yyvsp[-1].pre_primary_), (yyvsp[0].qualifier_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4828 "Parser.c"
    break;

  case 69: /* ARITH_VAR: ARITH_ID  */
#line 735 "HAL_S.y"
                     { (yyval.arith_var_) = make_AAarith_var((yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4834 "Parser.c"
    break;

  case 70: /* ARITH_VAR: ARITH_ID SUBSCRIPT  */
#line 736 "HAL_S.y"
                       { (yyval.arith_var_) = make_ACarith_var((yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4840 "Parser.c"
    break;

  case 71: /* ARITH_VAR: _SYMB_11 ARITH_ID _SYMB_12  */
#line 737 "HAL_S.y"
                               { (yyval.arith_var_) = make_AAarithVarBracketed((yyvsp[-1].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4846 "Parser.c"
    break;

  case 72: /* ARITH_VAR: _SYMB_11 ARITH_ID _SYMB_12 SUBSCRIPT  */
#line 738 "HAL_S.y"
                                         { (yyval.arith_var_) = make_ABarithVarBracketed((yyvsp[-2].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4852 "Parser.c"
    break;

  case 73: /* ARITH_VAR: _SYMB_13 QUAL_STRUCT _SYMB_14  */
#line 739 "HAL_S.y"
                                  { (yyval.arith_var_) = make_AAarithVarBraced((yyvsp[-1].qual_struct_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4858 "Parser.c"
    break;

  case 74: /* ARITH_VAR: _SYMB_13 QUAL_STRUCT _SYMB_14 SUBSCRIPT  */
#line 740 "HAL_S.y"
                                            { (yyval.arith_var_) = make_ABarithVarBraced((yyvsp[-2].qual_struct_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4864 "Parser.c"
    break;

  case 75: /* ARITH_VAR: QUAL_STRUCT _SYMB_7 ARITH_ID  */
#line 741 "HAL_S.y"
                                 { (yyval.arith_var_) = make_ABarith_var((yyvsp[-2].qual_struct_), (yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4870 "Parser.c"
    break;

  case 76: /* ARITH_VAR: QUAL_STRUCT _SYMB_7 ARITH_ID SUBSCRIPT  */
#line 742 "HAL_S.y"
                                           { (yyval.arith_var_) = make_ADarith_var((yyvsp[-3].qual_struct_), (yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4876 "Parser.c"
    break;

  case 77: /* PRE_PRIMARY: _SYMB_2 ARITH_EXP _SYMB_1  */
#line 744 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AApre_primary((yyvsp[-1].arith_exp_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4882 "Parser.c"
    break;

  case 78: /* PRE_PRIMARY: NUMBER  */
#line 745 "HAL_S.y"
           { (yyval.pre_primary_) = make_ABpre_primary((yyvsp[0].number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4888 "Parser.c"
    break;

  case 79: /* PRE_PRIMARY: COMPOUND_NUMBER  */
#line 746 "HAL_S.y"
                    { (yyval.pre_primary_) = make_ACpre_primary((yyvsp[0].compound_number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4894 "Parser.c"
    break;

  case 80: /* PRE_PRIMARY: ARITH_FUNC _SYMB_2 CALL_LIST _SYMB_1  */
#line 747 "HAL_S.y"
                                         { (yyval.pre_primary_) = make_ADprePrimaryRtlFunction((yyvsp[-3].arith_func_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4900 "Parser.c"
    break;

  case 81: /* PRE_PRIMARY: _SYMB_181 _SYMB_2 CALL_LIST _SYMB_1  */
#line 748 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_ADprePrimaryTypeof((yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4906 "Parser.c"
    break;

  case 82: /* PRE_PRIMARY: _SYMB_182 _SYMB_2 CALL_LIST _SYMB_1  */
#line 749 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_ADprePrimaryTypeofv((yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4912 "Parser.c"
    break;

  case 83: /* PRE_PRIMARY: SHAPING_HEAD _SYMB_1  */
#line 750 "HAL_S.y"
                         { (yyval.pre_primary_) = make_ADprePrimaryRtlShaping((yyvsp[-1].shaping_head_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4918 "Parser.c"
    break;

  case 84: /* PRE_PRIMARY: SHAPING_HEAD _SYMB_0 _SYMB_6 _SYMB_1  */
#line 751 "HAL_S.y"
                                         { (yyval.pre_primary_) = make_ADprePrimaryRtlShapingStar((yyvsp[-3].shaping_head_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4924 "Parser.c"
    break;

  case 85: /* PRE_PRIMARY: _SYMB_193 _SYMB_2 CALL_LIST _SYMB_1  */
#line 752 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AEprePrimaryFunction((yyvsp[-3].string_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4930 "Parser.c"
    break;

  case 86: /* NUMBER: SIMPLE_NUMBER  */
#line 754 "HAL_S.y"
                       { (yyval.number_) = make_AAnumber((yyvsp[0].simple_number_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4936 "Parser.c"
    break;

  case 87: /* NUMBER: LEVEL  */
#line 755 "HAL_S.y"
          { (yyval.number_) = make_ABnumber((yyvsp[0].level_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4942 "Parser.c"
    break;

  case 88: /* LEVEL: _SYMB_199  */
#line 757 "HAL_S.y"
                  { (yyval.level_) = make_ZZlevel((yyvsp[0].string_)); (yyval.level_)->line_number = (yyloc).first_line; (yyval.level_)->char_number = (yyloc).first_column;  }
#line 4948 "Parser.c"
    break;

  case 89: /* COMPOUND_NUMBER: _SYMB_201  */
#line 759 "HAL_S.y"
                            { (yyval.compound_number_) = make_CLcompound_number((yyvsp[0].string_)); (yyval.compound_number_)->line_number = (yyloc).first_line; (yyval.compound_number_)->char_number = (yyloc).first_column;  }
#line 4954 "Parser.c"
    break;

  case 90: /* SIMPLE_NUMBER: _SYMB_200  */
#line 761 "HAL_S.y"
                          { (yyval.simple_number_) = make_CKsimple_number((yyvsp[0].string_)); (yyval.simple_number_)->line_number = (yyloc).first_line; (yyval.simple_number_)->char_number = (yyloc).first_column;  }
#line 4960 "Parser.c"
    break;

  case 91: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC  */
#line 763 "HAL_S.y"
                                        { (yyval.modified_arith_func_) = make_AAmodified_arith_func((yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4966 "Parser.c"
    break;

  case 92: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 764 "HAL_S.y"
                                { (yyval.modified_arith_func_) = make_ACmodified_arith_func((yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4972 "Parser.c"
    break;

  case 93: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_7 NO_ARG_ARITH_FUNC  */
#line 765 "HAL_S.y"
                                          { (yyval.modified_arith_func_) = make_ADmodified_arith_func((yyvsp[-2].qual_struct_), (yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4978 "Parser.c"
    break;

  case 94: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_7 NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 766 "HAL_S.y"
                                                    { (yyval.modified_arith_func_) = make_AEmodified_arith_func((yyvsp[-3].qual_struct_), (yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4984 "Parser.c"
    break;

  case 95: /* SHAPING_HEAD: _SYMB_95 _SYMB_2 REPEATED_CONSTANT  */
#line 768 "HAL_S.y"
                                                  { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadInteger((yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 4990 "Parser.c"
    break;

  case 96: /* SHAPING_HEAD: _SYMB_139 _SYMB_2 REPEATED_CONSTANT  */
#line 769 "HAL_S.y"
                                        { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadScalar((yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 4996 "Parser.c"
    break;

  case 97: /* SHAPING_HEAD: _SYMB_175 _SYMB_2 REPEATED_CONSTANT  */
#line 770 "HAL_S.y"
                                        { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadVector((yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 5002 "Parser.c"
    break;

  case 98: /* SHAPING_HEAD: _SYMB_103 _SYMB_2 REPEATED_CONSTANT  */
#line 771 "HAL_S.y"
                                        { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadMatrix((yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 5008 "Parser.c"
    break;

  case 99: /* SHAPING_HEAD: _SYMB_95 SUBSCRIPT _SYMB_2 REPEATED_CONSTANT  */
#line 772 "HAL_S.y"
                                                 { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadIntegerSubscript((yyvsp[-2].subscript_), (yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 5014 "Parser.c"
    break;

  case 100: /* SHAPING_HEAD: _SYMB_139 SUBSCRIPT _SYMB_2 REPEATED_CONSTANT  */
#line 773 "HAL_S.y"
                                                  { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadScalarSubscript((yyvsp[-2].subscript_), (yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 5020 "Parser.c"
    break;

  case 101: /* SHAPING_HEAD: _SYMB_175 SUBSCRIPT _SYMB_2 REPEATED_CONSTANT  */
#line 774 "HAL_S.y"
                                                  { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadVectorSubscript((yyvsp[-2].subscript_), (yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 5026 "Parser.c"
    break;

  case 102: /* SHAPING_HEAD: _SYMB_103 SUBSCRIPT _SYMB_2 REPEATED_CONSTANT  */
#line 775 "HAL_S.y"
                                                  { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadMatrixSubscript((yyvsp[-2].subscript_), (yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 5032 "Parser.c"
    break;

  case 103: /* SHAPING_HEAD: SHAPING_HEAD _SYMB_0 REPEATED_CONSTANT  */
#line 776 "HAL_S.y"
                                           { (yyval.shaping_head_) = make_ADprePrimaryRtlShapingHeadRepeated((yyvsp[-2].shaping_head_), (yyvsp[0].repeated_constant_)); (yyval.shaping_head_)->line_number = (yyloc).first_line; (yyval.shaping_head_)->char_number = (yyloc).first_column;  }
#line 5038 "Parser.c"
    break;

  case 104: /* CALL_LIST: LIST_EXP  */
#line 778 "HAL_S.y"
                     { (yyval.call_list_) = make_AAcall_list((yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 5044 "Parser.c"
    break;

  case 105: /* CALL_LIST: CALL_LIST _SYMB_0 LIST_EXP  */
#line 779 "HAL_S.y"
                               { (yyval.call_list_) = make_ABcall_list((yyvsp[-2].call_list_), (yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 5050 "Parser.c"
    break;

  case 106: /* LIST_EXP: EXPRESSION  */
#line 781 "HAL_S.y"
                      { (yyval.list_exp_) = make_AAlist_exp((yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 5056 "Parser.c"
    break;

  case 107: /* LIST_EXP: ARITH_EXP _SYMB_10 EXPRESSION  */
#line 782 "HAL_S.y"
                                  { (yyval.list_exp_) = make_ABlist_expRepeated((yyvsp[-2].arith_exp_), (yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 5062 "Parser.c"
    break;

  case 108: /* LIST_EXP: QUAL_STRUCT  */
#line 783 "HAL_S.y"
                { (yyval.list_exp_) = make_ADlist_exp((yyvsp[0].qual_struct_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 5068 "Parser.c"
    break;

  case 109: /* EXPRESSION: ARITH_EXP  */
#line 785 "HAL_S.y"
                       { (yyval.expression_) = make_AAexpression((yyvsp[0].arith_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 5074 "Parser.c"
    break;

  case 110: /* EXPRESSION: BIT_EXP  */
#line 786 "HAL_S.y"
            { (yyval.expression_) = make_ABexpression((yyvsp[0].bit_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 5080 "Parser.c"
    break;

  case 111: /* EXPRESSION: CHAR_EXP  */
#line 787 "HAL_S.y"
             { (yyval.expression_) = make_ACexpression((yyvsp[0].char_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 5086 "Parser.c"
    break;

  case 112: /* EXPRESSION: NAME_EXP  */
#line 788 "HAL_S.y"
             { (yyval.expression_) = make_AEexpression((yyvsp[0].name_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 5092 "Parser.c"
    break;

  case 113: /* EXPRESSION: STRUCTURE_EXP  */
#line 789 "HAL_S.y"
                  { (yyval.expression_) = make_ADexpression((yyvsp[0].structure_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 5098 "Parser.c"
    break;

  case 114: /* ARITH_ID: IDENTIFIER  */
#line 791 "HAL_S.y"
                      { (yyval.arith_id_) = make_FGarith_id((yyvsp[0].identifier_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 5104 "Parser.c"
    break;

  case 115: /* ARITH_ID: _SYMB_195  */
#line 792 "HAL_S.y"
              { (yyval.arith_id_) = make_FHarith_id((yyvsp[0].string_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 5110 "Parser.c"
    break;

  case 116: /* NO_ARG_ARITH_FUNC: _SYMB_186  */
#line 794 "HAL_S.y"
                              { (yyval.no_arg_arith_func_) = make_ZZnoArgumentUserFunction((yyvsp[0].string_)); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 5116 "Parser.c"
    break;

  case 117: /* NO_ARG_ARITH_FUNC: _SYMB_55  */
#line 795 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZclocktime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 5122 "Parser.c"
    break;

  case 118: /* NO_ARG_ARITH_FUNC: _SYMB_62  */
#line 796 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZdate(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 5128 "Parser.c"
    break;

  case 119: /* NO_ARG_ARITH_FUNC: _SYMB_74  */
#line 797 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZerrgrp(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 5134 "Parser.c"
    break;

  case 120: /* NO_ARG_ARITH_FUNC: _SYMB_75  */
#line 798 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZerrnum(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 5140 "Parser.c"
    break;

  case 121: /* NO_ARG_ARITH_FUNC: _SYMB_119  */
#line 799 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZprio(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 5146 "Parser.c"
    break;

  case 122: /* NO_ARG_ARITH_FUNC: _SYMB_124  */
#line 800 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZrandom(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 5152 "Parser.c"
    break;

  case 123: /* NO_ARG_ARITH_FUNC: _SYMB_125  */
#line 801 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZrandomg(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 5158 "Parser.c"
    break;

  case 124: /* NO_ARG_ARITH_FUNC: _SYMB_138  */
#line 802 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZruntime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 5164 "Parser.c"
    break;

  case 125: /* ARITH_FUNC: _SYMB_109  */
#line 804 "HAL_S.y"
                       { (yyval.arith_func_) = make_ZZnextime(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5170 "Parser.c"
    break;

  case 126: /* ARITH_FUNC: _SYMB_27  */
#line 805 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabs(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5176 "Parser.c"
    break;

  case 127: /* ARITH_FUNC: _SYMB_52  */
#line 806 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZceiling(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5182 "Parser.c"
    break;

  case 128: /* ARITH_FUNC: _SYMB_68  */
#line 807 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdiv(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5188 "Parser.c"
    break;

  case 129: /* ARITH_FUNC: _SYMB_85  */
#line 808 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZfloor(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5194 "Parser.c"
    break;

  case 130: /* ARITH_FUNC: _SYMB_105  */
#line 809 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmidval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5200 "Parser.c"
    break;

  case 131: /* ARITH_FUNC: _SYMB_107  */
#line 810 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5206 "Parser.c"
    break;

  case 132: /* ARITH_FUNC: _SYMB_114  */
#line 811 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZodd(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5212 "Parser.c"
    break;

  case 133: /* ARITH_FUNC: _SYMB_129  */
#line 812 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZremainder(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5218 "Parser.c"
    break;

  case 134: /* ARITH_FUNC: _SYMB_137  */
#line 813 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZround(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5224 "Parser.c"
    break;

  case 135: /* ARITH_FUNC: _SYMB_145  */
#line 814 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsign(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5230 "Parser.c"
    break;

  case 136: /* ARITH_FUNC: _SYMB_147  */
#line 815 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsignum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5236 "Parser.c"
    break;

  case 137: /* ARITH_FUNC: _SYMB_171  */
#line 816 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtruncate(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5242 "Parser.c"
    break;

  case 138: /* ARITH_FUNC: _SYMB_33  */
#line 817 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5248 "Parser.c"
    break;

  case 139: /* ARITH_FUNC: _SYMB_34  */
#line 818 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5254 "Parser.c"
    break;

  case 140: /* ARITH_FUNC: _SYMB_35  */
#line 819 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5260 "Parser.c"
    break;

  case 141: /* ARITH_FUNC: _SYMB_36  */
#line 820 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5266 "Parser.c"
    break;

  case 142: /* ARITH_FUNC: _SYMB_38  */
#line 821 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan2(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5272 "Parser.c"
    break;

  case 143: /* ARITH_FUNC: _SYMB_37  */
#line 822 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5278 "Parser.c"
    break;

  case 144: /* ARITH_FUNC: _SYMB_39  */
#line 823 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5284 "Parser.c"
    break;

  case 145: /* ARITH_FUNC: _SYMB_60  */
#line 824 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5290 "Parser.c"
    break;

  case 146: /* ARITH_FUNC: _SYMB_61  */
#line 825 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5296 "Parser.c"
    break;

  case 147: /* ARITH_FUNC: _SYMB_81  */
#line 826 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZexp(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5302 "Parser.c"
    break;

  case 148: /* ARITH_FUNC: _SYMB_102  */
#line 827 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZlog(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5308 "Parser.c"
    break;

  case 149: /* ARITH_FUNC: _SYMB_148  */
#line 828 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5314 "Parser.c"
    break;

  case 150: /* ARITH_FUNC: _SYMB_150  */
#line 829 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5320 "Parser.c"
    break;

  case 151: /* ARITH_FUNC: _SYMB_153  */
#line 830 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsqrt(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5326 "Parser.c"
    break;

  case 152: /* ARITH_FUNC: _SYMB_160  */
#line 831 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5332 "Parser.c"
    break;

  case 153: /* ARITH_FUNC: _SYMB_161  */
#line 832 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5338 "Parser.c"
    break;

  case 154: /* ARITH_FUNC: _SYMB_143  */
#line 833 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshl(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5344 "Parser.c"
    break;

  case 155: /* ARITH_FUNC: _SYMB_144  */
#line 834 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshr(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5350 "Parser.c"
    break;

  case 156: /* ARITH_FUNC: _SYMB_28  */
#line 835 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5356 "Parser.c"
    break;

  case 157: /* ARITH_FUNC: _SYMB_67  */
#line 836 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdet(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5362 "Parser.c"
    break;

  case 158: /* ARITH_FUNC: _SYMB_167  */
#line 837 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtrace(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5368 "Parser.c"
    break;

  case 159: /* ARITH_FUNC: _SYMB_172  */
#line 838 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZunit(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5374 "Parser.c"
    break;

  case 160: /* ARITH_FUNC: _SYMB_93  */
#line 839 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZindex(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5380 "Parser.c"
    break;

  case 161: /* ARITH_FUNC: _SYMB_98  */
#line 840 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZlength(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5386 "Parser.c"
    break;

  case 162: /* ARITH_FUNC: _SYMB_96  */
#line 841 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZinverse(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5392 "Parser.c"
    break;

  case 163: /* ARITH_FUNC: _SYMB_168  */
#line 842 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtranspose(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5398 "Parser.c"
    break;

  case 164: /* ARITH_FUNC: _SYMB_122  */
#line 843 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZprod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5404 "Parser.c"
    break;

  case 165: /* ARITH_FUNC: _SYMB_157  */
#line 844 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5410 "Parser.c"
    break;

  case 166: /* ARITH_FUNC: _SYMB_151  */
#line 845 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsize(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5416 "Parser.c"
    break;

  case 167: /* ARITH_FUNC: _SYMB_104  */
#line 846 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmax(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5422 "Parser.c"
    break;

  case 168: /* ARITH_FUNC: _SYMB_106  */
#line 847 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5428 "Parser.c"
    break;

  case 169: /* SUBSCRIPT: SUB_HEAD _SYMB_1  */
#line 849 "HAL_S.y"
                             { (yyval.subscript_) = make_AAsubscript((yyvsp[-1].sub_head_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5434 "Parser.c"
    break;

  case 170: /* SUBSCRIPT: QUALIFIER  */
#line 850 "HAL_S.y"
              { (yyval.subscript_) = make_ABsubscript((yyvsp[0].qualifier_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5440 "Parser.c"
    break;

  case 171: /* SUBSCRIPT: _SYMB_15 NUMBER  */
#line 851 "HAL_S.y"
                    { (yyval.subscript_) = make_ACsubscript((yyvsp[0].number_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5446 "Parser.c"
    break;

  case 172: /* SUBSCRIPT: _SYMB_15 ARITH_VAR  */
#line 852 "HAL_S.y"
                       { (yyval.subscript_) = make_ADsubscript((yyvsp[0].arith_var_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5452 "Parser.c"
    break;

  case 173: /* QUALIFIER: _SYMB_15 _SYMB_2 _SYMB_16 PREC_SPEC _SYMB_1  */
#line 854 "HAL_S.y"
                                                        { (yyval.qualifier_) = make_AAqualifier((yyvsp[-1].prec_spec_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5458 "Parser.c"
    break;

  case 174: /* QUALIFIER: _SYMB_15 _SYMB_2 SCALE_HEAD ARITH_EXP _SYMB_1  */
#line 855 "HAL_S.y"
                                                  { (yyval.qualifier_) = make_ABqualifier((yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5464 "Parser.c"
    break;

  case 175: /* QUALIFIER: _SYMB_15 _SYMB_2 _SYMB_16 PREC_SPEC _SYMB_0 SCALE_HEAD ARITH_EXP _SYMB_1  */
#line 856 "HAL_S.y"
                                                                             { (yyval.qualifier_) = make_ACqualifier((yyvsp[-4].prec_spec_), (yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5470 "Parser.c"
    break;

  case 176: /* QUALIFIER: _SYMB_15 _SYMB_2 _SYMB_16 RADIX _SYMB_1  */
#line 857 "HAL_S.y"
                                            { (yyval.qualifier_) = make_ADqualifier((yyvsp[-1].radix_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5476 "Parser.c"
    break;

  case 177: /* SCALE_HEAD: _SYMB_16  */
#line 859 "HAL_S.y"
                      { (yyval.scale_head_) = make_AAscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 5482 "Parser.c"
    break;

  case 178: /* SCALE_HEAD: _SYMB_16 _SYMB_16  */
#line 860 "HAL_S.y"
                      { (yyval.scale_head_) = make_ABscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 5488 "Parser.c"
    break;

  case 179: /* PREC_SPEC: _SYMB_149  */
#line 862 "HAL_S.y"
                      { (yyval.prec_spec_) = make_AAprecSpecSingle(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 5494 "Parser.c"
    break;

  case 180: /* PREC_SPEC: _SYMB_70  */
#line 863 "HAL_S.y"
             { (yyval.prec_spec_) = make_ABprecSpecDouble(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 5500 "Parser.c"
    break;

  case 181: /* SUB_START: _SYMB_15 _SYMB_2  */
#line 865 "HAL_S.y"
                             { (yyval.sub_start_) = make_AAsubStartGroup(); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5506 "Parser.c"
    break;

  case 182: /* SUB_START: _SYMB_15 _SYMB_2 _SYMB_16 PREC_SPEC _SYMB_0  */
#line 866 "HAL_S.y"
                                                { (yyval.sub_start_) = make_ABsubStartPrecSpec((yyvsp[-1].prec_spec_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5512 "Parser.c"
    break;

  case 183: /* SUB_START: SUB_HEAD _SYMB_17  */
#line 867 "HAL_S.y"
                      { (yyval.sub_start_) = make_ACsubStartSemicolon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5518 "Parser.c"
    break;

  case 184: /* SUB_START: SUB_HEAD _SYMB_18  */
#line 868 "HAL_S.y"
                      { (yyval.sub_start_) = make_ADsubStartColon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5524 "Parser.c"
    break;

  case 185: /* SUB_START: SUB_HEAD _SYMB_0  */
#line 869 "HAL_S.y"
                     { (yyval.sub_start_) = make_AEsubStartComma((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5530 "Parser.c"
    break;

  case 186: /* SUB_HEAD: SUB_START  */
#line 871 "HAL_S.y"
                     { (yyval.sub_head_) = make_AAsub_head((yyvsp[0].sub_start_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 5536 "Parser.c"
    break;

  case 187: /* SUB_HEAD: SUB_START SUB  */
#line 872 "HAL_S.y"
                  { (yyval.sub_head_) = make_ABsub_head((yyvsp[-1].sub_start_), (yyvsp[0].sub_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 5542 "Parser.c"
    break;

  case 188: /* SUB: SUB_EXP  */
#line 874 "HAL_S.y"
              { (yyval.sub_) = make_AAsub((yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5548 "Parser.c"
    break;

  case 189: /* SUB: _SYMB_6  */
#line 875 "HAL_S.y"
            { (yyval.sub_) = make_ABsubStar(); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5554 "Parser.c"
    break;

  case 190: /* SUB: SUB_RUN_HEAD SUB_EXP  */
#line 876 "HAL_S.y"
                         { (yyval.sub_) = make_ACsubExp((yyvsp[-1].sub_run_head_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5560 "Parser.c"
    break;

  case 191: /* SUB: ARITH_EXP _SYMB_42 SUB_EXP  */
#line 877 "HAL_S.y"
                               { (yyval.sub_) = make_ADsubAt((yyvsp[-2].arith_exp_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5566 "Parser.c"
    break;

  case 192: /* SUB_RUN_HEAD: SUB_EXP _SYMB_166  */
#line 879 "HAL_S.y"
                                 { (yyval.sub_run_head_) = make_AAsubRunHeadTo((yyvsp[-1].sub_exp_)); (yyval.sub_run_head_)->line_number = (yyloc).first_line; (yyval.sub_run_head_)->char_number = (yyloc).first_column;  }
#line 5572 "Parser.c"
    break;

  case 193: /* SUB_EXP: ARITH_EXP  */
#line 881 "HAL_S.y"
                    { (yyval.sub_exp_) = make_AAsub_exp((yyvsp[0].arith_exp_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 5578 "Parser.c"
    break;

  case 194: /* SUB_EXP: POUND_EXPRESSION  */
#line 882 "HAL_S.y"
                     { (yyval.sub_exp_) = make_ABsub_exp((yyvsp[0].pound_expression_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 5584 "Parser.c"
    break;

  case 195: /* POUND_EXPRESSION: _SYMB_10  */
#line 884 "HAL_S.y"
                            { (yyval.pound_expression_) = make_AApound_expression(); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5590 "Parser.c"
    break;

  case 196: /* POUND_EXPRESSION: POUND_EXPRESSION PLUS TERM  */
#line 885 "HAL_S.y"
                               { (yyval.pound_expression_) = make_ABpound_expressionPlusTerm((yyvsp[-2].pound_expression_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5596 "Parser.c"
    break;

  case 197: /* POUND_EXPRESSION: POUND_EXPRESSION MINUS TERM  */
#line 886 "HAL_S.y"
                                { (yyval.pound_expression_) = make_ACpound_expressionMinusTerm((yyvsp[-2].pound_expression_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5602 "Parser.c"
    break;

  case 198: /* BIT_EXP: BIT_FACTOR  */
#line 888 "HAL_S.y"
                     { (yyval.bit_exp_) = make_AAbitExpFactor((yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 5608 "Parser.c"
    break;

  case 199: /* BIT_EXP: BIT_EXP OR BIT_FACTOR  */
#line 889 "HAL_S.y"
                          { (yyval.bit_exp_) = make_ABbitExpOR((yyvsp[-2].bit_exp_), (yyvsp[-1].or_), (yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 5614 "Parser.c"
    break;

  case 200: /* BIT_FACTOR: BIT_CAT  */
#line 891 "HAL_S.y"
                     { (yyval.bit_factor_) = make_AAbitFactor((yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 5620 "Parser.c"
    break;

  case 201: /* BIT_FACTOR: BIT_FACTOR AND BIT_CAT  */
#line 892 "HAL_S.y"
                           { (yyval.bit_factor_) = make_ABbitFactorAnd((yyvsp[-2].bit_factor_), (yyvsp[-1].and_), (yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 5626 "Parser.c"
    break;

  case 202: /* BIT_CAT: BIT_PRIM  */
#line 894 "HAL_S.y"
                   { (yyval.bit_cat_) = make_AAbitCatPrim((yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5632 "Parser.c"
    break;

  case 203: /* BIT_CAT: BIT_CAT CAT BIT_PRIM  */
#line 895 "HAL_S.y"
                         { (yyval.bit_cat_) = make_ABbitCatCat((yyvsp[-2].bit_cat_), (yyvsp[-1].cat_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5638 "Parser.c"
    break;

  case 204: /* BIT_CAT: NOT BIT_PRIM  */
#line 896 "HAL_S.y"
                 { (yyval.bit_cat_) = make_ACbitCatNotPrim((yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5644 "Parser.c"
    break;

  case 205: /* BIT_CAT: BIT_CAT CAT NOT BIT_PRIM  */
#line 897 "HAL_S.y"
                             { (yyval.bit_cat_) = make_ADbitCatNotCat((yyvsp[-3].bit_cat_), (yyvsp[-2].cat_), (yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5650 "Parser.c"
    break;

  case 206: /* OR: CHAR_VERTICAL_BAR  */
#line 899 "HAL_S.y"
                       { (yyval.or_) = make_AAOR((yyvsp[0].char_vertical_bar_)); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5656 "Parser.c"
    break;

  case 207: /* OR: _SYMB_117  */
#line 900 "HAL_S.y"
              { (yyval.or_) = make_ABOR(); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5662 "Parser.c"
    break;

  case 208: /* CHAR_VERTICAL_BAR: _SYMB_19  */
#line 902 "HAL_S.y"
                             { (yyval.char_vertical_bar_) = make_CFchar_vertical_bar(); (yyval.char_vertical_bar_)->line_number = (yyloc).first_line; (yyval.char_vertical_bar_)->char_number = (yyloc).first_column;  }
#line 5668 "Parser.c"
    break;

  case 209: /* AND: _SYMB_20  */
#line 904 "HAL_S.y"
               { (yyval.and_) = make_AAAND(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5674 "Parser.c"
    break;

  case 210: /* AND: _SYMB_32  */
#line 905 "HAL_S.y"
             { (yyval.and_) = make_ABAND(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5680 "Parser.c"
    break;

  case 211: /* BIT_PRIM: BIT_VAR  */
#line 907 "HAL_S.y"
                   { (yyval.bit_prim_) = make_AAbitPrimBitVar((yyvsp[0].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5686 "Parser.c"
    break;

  case 212: /* BIT_PRIM: LABEL_VAR  */
#line 908 "HAL_S.y"
              { (yyval.bit_prim_) = make_ABbitPrimLabelVar((yyvsp[0].label_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5692 "Parser.c"
    break;

  case 213: /* BIT_PRIM: EVENT_VAR  */
#line 909 "HAL_S.y"
              { (yyval.bit_prim_) = make_ACbitPrimEventVar((yyvsp[0].event_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5698 "Parser.c"
    break;

  case 214: /* BIT_PRIM: BIT_CONST  */
#line 910 "HAL_S.y"
              { (yyval.bit_prim_) = make_ADbitBitConst((yyvsp[0].bit_const_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5704 "Parser.c"
    break;

  case 215: /* BIT_PRIM: _SYMB_2 BIT_EXP _SYMB_1  */
#line 911 "HAL_S.y"
                            { (yyval.bit_prim_) = make_AEbitPrimBitExp((yyvsp[-1].bit_exp_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5710 "Parser.c"
    break;

  case 216: /* BIT_PRIM: SUBBIT_HEAD EXPRESSION _SYMB_1  */
#line 912 "HAL_S.y"
                                   { (yyval.bit_prim_) = make_AHbitPrimSubbit((yyvsp[-2].subbit_head_), (yyvsp[-1].expression_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5716 "Parser.c"
    break;

  case 217: /* BIT_PRIM: BIT_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 913 "HAL_S.y"
                                            { (yyval.bit_prim_) = make_AIbitPrimFunc((yyvsp[-3].bit_func_head_), (yyvsp[-1].call_list_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5722 "Parser.c"
    break;

  case 218: /* BIT_PRIM: _SYMB_180 _SYMB_2 CALL_LIST _SYMB_1  */
#line 914 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_AIbitPrimInitialized((yyvsp[-1].call_list_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5728 "Parser.c"
    break;

  case 219: /* BIT_PRIM: _SYMB_11 BIT_VAR _SYMB_12  */
#line 915 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBracketed((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5734 "Parser.c"
    break;

  case 220: /* BIT_PRIM: _SYMB_11 BIT_VAR _SYMB_12 SUBSCRIPT  */
#line 916 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBracketed((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5740 "Parser.c"
    break;

  case 221: /* BIT_PRIM: _SYMB_13 BIT_VAR _SYMB_14  */
#line 917 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBraced((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5746 "Parser.c"
    break;

  case 222: /* BIT_PRIM: _SYMB_13 BIT_VAR _SYMB_14 SUBSCRIPT  */
#line 918 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBraced((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5752 "Parser.c"
    break;

  case 223: /* CAT: _SYMB_21  */
#line 920 "HAL_S.y"
               { (yyval.cat_) = make_AAcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5758 "Parser.c"
    break;

  case 224: /* CAT: _SYMB_51  */
#line 921 "HAL_S.y"
             { (yyval.cat_) = make_ABcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5764 "Parser.c"
    break;

  case 225: /* NOT: _SYMB_111  */
#line 923 "HAL_S.y"
                { (yyval.not_) = make_ABNOT(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5770 "Parser.c"
    break;

  case 226: /* NOT: _SYMB_22  */
#line 924 "HAL_S.y"
             { (yyval.not_) = make_ADNOT(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5776 "Parser.c"
    break;

  case 227: /* BIT_VAR: BIT_ID  */
#line 926 "HAL_S.y"
                 { (yyval.bit_var_) = make_AAbit_var((yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5782 "Parser.c"
    break;

  case 228: /* BIT_VAR: BIT_ID SUBSCRIPT  */
#line 927 "HAL_S.y"
                     { (yyval.bit_var_) = make_ACbit_var((yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5788 "Parser.c"
    break;

  case 229: /* BIT_VAR: QUAL_STRUCT _SYMB_7 BIT_ID  */
#line 928 "HAL_S.y"
                               { (yyval.bit_var_) = make_ABbit_var((yyvsp[-2].qual_struct_), (yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5794 "Parser.c"
    break;

  case 230: /* BIT_VAR: QUAL_STRUCT _SYMB_7 BIT_ID SUBSCRIPT  */
#line 929 "HAL_S.y"
                                         { (yyval.bit_var_) = make_ADbit_var((yyvsp[-3].qual_struct_), (yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5800 "Parser.c"
    break;

  case 231: /* LABEL_VAR: LABEL  */
#line 931 "HAL_S.y"
                  { (yyval.label_var_) = make_AAlabel_var((yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5806 "Parser.c"
    break;

  case 232: /* LABEL_VAR: LABEL SUBSCRIPT  */
#line 932 "HAL_S.y"
                    { (yyval.label_var_) = make_ABlabel_var((yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5812 "Parser.c"
    break;

  case 233: /* LABEL_VAR: QUAL_STRUCT _SYMB_7 LABEL  */
#line 933 "HAL_S.y"
                              { (yyval.label_var_) = make_AClabel_var((yyvsp[-2].qual_struct_), (yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5818 "Parser.c"
    break;

  case 234: /* LABEL_VAR: QUAL_STRUCT _SYMB_7 LABEL SUBSCRIPT  */
#line 934 "HAL_S.y"
                                        { (yyval.label_var_) = make_ADlabel_var((yyvsp[-3].qual_struct_), (yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5824 "Parser.c"
    break;

  case 235: /* EVENT_VAR: EVENT  */
#line 936 "HAL_S.y"
                  { (yyval.event_var_) = make_AAevent_var((yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5830 "Parser.c"
    break;

  case 236: /* EVENT_VAR: EVENT SUBSCRIPT  */
#line 937 "HAL_S.y"
                    { (yyval.event_var_) = make_ACevent_var((yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5836 "Parser.c"
    break;

  case 237: /* EVENT_VAR: QUAL_STRUCT _SYMB_7 EVENT  */
#line 938 "HAL_S.y"
                              { (yyval.event_var_) = make_ABevent_var((yyvsp[-2].qual_struct_), (yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5842 "Parser.c"
    break;

  case 238: /* EVENT_VAR: QUAL_STRUCT _SYMB_7 EVENT SUBSCRIPT  */
#line 939 "HAL_S.y"
                                        { (yyval.event_var_) = make_ADevent_var((yyvsp[-3].qual_struct_), (yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5848 "Parser.c"
    break;

  case 239: /* BIT_CONST_HEAD: RADIX  */
#line 941 "HAL_S.y"
                       { (yyval.bit_const_head_) = make_AAbit_const_head((yyvsp[0].radix_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5854 "Parser.c"
    break;

  case 240: /* BIT_CONST_HEAD: RADIX _SYMB_2 NUMBER _SYMB_1  */
#line 942 "HAL_S.y"
                                 { (yyval.bit_const_head_) = make_ABbit_const_head((yyvsp[-3].radix_), (yyvsp[-1].number_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5860 "Parser.c"
    break;

  case 241: /* BIT_CONST: BIT_CONST_HEAD CHAR_STRING  */
#line 944 "HAL_S.y"
                                       { (yyval.bit_const_) = make_AAbitConstString((yyvsp[-1].bit_const_head_), (yyvsp[0].char_string_)); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5866 "Parser.c"
    break;

  case 242: /* BIT_CONST: _SYMB_170  */
#line 945 "HAL_S.y"
              { (yyval.bit_const_) = make_ABbitConstTrue(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5872 "Parser.c"
    break;

  case 243: /* BIT_CONST: _SYMB_83  */
#line 946 "HAL_S.y"
             { (yyval.bit_const_) = make_ACbitConstFalse(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5878 "Parser.c"
    break;

  case 244: /* BIT_CONST: _SYMB_116  */
#line 947 "HAL_S.y"
              { (yyval.bit_const_) = make_ADbitConstOn(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5884 "Parser.c"
    break;

  case 245: /* BIT_CONST: _SYMB_115  */
#line 948 "HAL_S.y"
              { (yyval.bit_const_) = make_AEbitConstOff(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5890 "Parser.c"
    break;

  case 246: /* RADIX: _SYMB_89  */
#line 950 "HAL_S.y"
                 { (yyval.radix_) = make_AAradixHEX(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5896 "Parser.c"
    break;

  case 247: /* RADIX: _SYMB_113  */
#line 951 "HAL_S.y"
              { (yyval.radix_) = make_ABradixOCT(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5902 "Parser.c"
    break;

  case 248: /* RADIX: _SYMB_44  */
#line 952 "HAL_S.y"
             { (yyval.radix_) = make_ACradixBIN(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5908 "Parser.c"
    break;

  case 249: /* RADIX: _SYMB_63  */
#line 953 "HAL_S.y"
             { (yyval.radix_) = make_ADradixDEC(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5914 "Parser.c"
    break;

  case 250: /* CHAR_STRING: _SYMB_197  */
#line 955 "HAL_S.y"
                        { (yyval.char_string_) = make_FPchar_string((yyvsp[0].string_)); (yyval.char_string_)->line_number = (yyloc).first_line; (yyval.char_string_)->char_number = (yyloc).first_column;  }
#line 5920 "Parser.c"
    break;

  case 251: /* SUBBIT_HEAD: SUBBIT_KEY _SYMB_2  */
#line 957 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_AAsubbit_head((yyvsp[-1].subbit_key_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5926 "Parser.c"
    break;

  case 252: /* SUBBIT_HEAD: SUBBIT_KEY SUBSCRIPT _SYMB_2  */
#line 958 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_ABsubbit_head((yyvsp[-2].subbit_key_), (yyvsp[-1].subscript_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5932 "Parser.c"
    break;

  case 253: /* SUBBIT_KEY: _SYMB_156  */
#line 960 "HAL_S.y"
                       { (yyval.subbit_key_) = make_AAsubbit_key(); (yyval.subbit_key_)->line_number = (yyloc).first_line; (yyval.subbit_key_)->char_number = (yyloc).first_column;  }
#line 5938 "Parser.c"
    break;

  case 254: /* BIT_FUNC_HEAD: BIT_FUNC  */
#line 962 "HAL_S.y"
                         { (yyval.bit_func_head_) = make_AAbit_func_head((yyvsp[0].bit_func_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5944 "Parser.c"
    break;

  case 255: /* BIT_FUNC_HEAD: _SYMB_45  */
#line 963 "HAL_S.y"
             { (yyval.bit_func_head_) = make_ABbit_func_head(); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5950 "Parser.c"
    break;

  case 256: /* BIT_FUNC_HEAD: _SYMB_45 SUB_OR_QUALIFIER  */
#line 964 "HAL_S.y"
                              { (yyval.bit_func_head_) = make_ACbit_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5956 "Parser.c"
    break;

  case 257: /* BIT_ID: _SYMB_187  */
#line 966 "HAL_S.y"
                   { (yyval.bit_id_) = make_FHbit_id((yyvsp[0].string_)); (yyval.bit_id_)->line_number = (yyloc).first_line; (yyval.bit_id_)->char_number = (yyloc).first_column;  }
#line 5962 "Parser.c"
    break;

  case 258: /* LABEL: _SYMB_193  */
#line 968 "HAL_S.y"
                  { (yyval.label_) = make_FKlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5968 "Parser.c"
    break;

  case 259: /* LABEL: _SYMB_188  */
#line 969 "HAL_S.y"
              { (yyval.label_) = make_FLlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5974 "Parser.c"
    break;

  case 260: /* LABEL: _SYMB_189  */
#line 970 "HAL_S.y"
              { (yyval.label_) = make_FMlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5980 "Parser.c"
    break;

  case 261: /* LABEL: _SYMB_192  */
#line 971 "HAL_S.y"
              { (yyval.label_) = make_FNlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5986 "Parser.c"
    break;

  case 262: /* BIT_FUNC: _SYMB_179  */
#line 973 "HAL_S.y"
                     { (yyval.bit_func_) = make_ZZxor(); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5992 "Parser.c"
    break;

  case 263: /* BIT_FUNC: _SYMB_188  */
#line 974 "HAL_S.y"
              { (yyval.bit_func_) = make_ZZuserBitFunction((yyvsp[0].string_)); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5998 "Parser.c"
    break;

  case 264: /* EVENT: _SYMB_194  */
#line 976 "HAL_S.y"
                  { (yyval.event_) = make_FLevent((yyvsp[0].string_)); (yyval.event_)->line_number = (yyloc).first_line; (yyval.event_)->char_number = (yyloc).first_column;  }
#line 6004 "Parser.c"
    break;

  case 265: /* SUB_OR_QUALIFIER: SUBSCRIPT  */
#line 978 "HAL_S.y"
                             { (yyval.sub_or_qualifier_) = make_AAsub_or_qualifier((yyvsp[0].subscript_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 6010 "Parser.c"
    break;

  case 266: /* SUB_OR_QUALIFIER: BIT_QUALIFIER  */
#line 979 "HAL_S.y"
                  { (yyval.sub_or_qualifier_) = make_ABsub_or_qualifier((yyvsp[0].bit_qualifier_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 6016 "Parser.c"
    break;

  case 267: /* BIT_QUALIFIER: _SYMB_23 _SYMB_15 _SYMB_2 _SYMB_16 RADIX _SYMB_1  */
#line 981 "HAL_S.y"
                                                                 { (yyval.bit_qualifier_) = make_AAbit_qualifier((yyvsp[-1].radix_)); (yyval.bit_qualifier_)->line_number = (yyloc).first_line; (yyval.bit_qualifier_)->char_number = (yyloc).first_column;  }
#line 6022 "Parser.c"
    break;

  case 268: /* CHAR_EXP: CHAR_PRIM  */
#line 983 "HAL_S.y"
                     { (yyval.char_exp_) = make_AAcharExpPrim((yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 6028 "Parser.c"
    break;

  case 269: /* CHAR_EXP: CHAR_EXP CAT CHAR_PRIM  */
#line 984 "HAL_S.y"
                           { (yyval.char_exp_) = make_ABcharExpCat((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 6034 "Parser.c"
    break;

  case 270: /* CHAR_EXP: CHAR_EXP CAT ARITH_EXP  */
#line 985 "HAL_S.y"
                           { (yyval.char_exp_) = make_ACcharExpCat((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 6040 "Parser.c"
    break;

  case 271: /* CHAR_EXP: ARITH_EXP CAT ARITH_EXP  */
#line 986 "HAL_S.y"
                            { (yyval.char_exp_) = make_ADcharExpCat((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 6046 "Parser.c"
    break;

  case 272: /* CHAR_EXP: ARITH_EXP CAT CHAR_PRIM  */
#line 987 "HAL_S.y"
                            { (yyval.char_exp_) = make_AEcharExpCat((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 6052 "Parser.c"
    break;

  case 273: /* CHAR_PRIM: CHAR_VAR  */
#line 989 "HAL_S.y"
                     { (yyval.char_prim_) = make_AAchar_prim((yyvsp[0].char_var_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 6058 "Parser.c"
    break;

  case 274: /* CHAR_PRIM: CHAR_CONST  */
#line 990 "HAL_S.y"
               { (yyval.char_prim_) = make_ABchar_prim((yyvsp[0].char_const_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 6064 "Parser.c"
    break;

  case 275: /* CHAR_PRIM: CHAR_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 991 "HAL_S.y"
                                             { (yyval.char_prim_) = make_AEchar_prim((yyvsp[-3].char_func_head_), (yyvsp[-1].call_list_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 6070 "Parser.c"
    break;

  case 276: /* CHAR_PRIM: _SYMB_2 CHAR_EXP _SYMB_1  */
#line 992 "HAL_S.y"
                             { (yyval.char_prim_) = make_AFchar_prim((yyvsp[-1].char_exp_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 6076 "Parser.c"
    break;

  case 277: /* CHAR_FUNC_HEAD: CHAR_FUNC  */
#line 994 "HAL_S.y"
                           { (yyval.char_func_head_) = make_AAchar_func_head((yyvsp[0].char_func_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 6082 "Parser.c"
    break;

  case 278: /* CHAR_FUNC_HEAD: _SYMB_54 SUB_OR_QUALIFIER  */
#line 995 "HAL_S.y"
                              { (yyval.char_func_head_) = make_ABchar_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 6088 "Parser.c"
    break;

  case 279: /* CHAR_VAR: CHAR_ID  */
#line 997 "HAL_S.y"
                   { (yyval.char_var_) = make_AAchar_var((yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 6094 "Parser.c"
    break;

  case 280: /* CHAR_VAR: CHAR_ID SUBSCRIPT  */
#line 998 "HAL_S.y"
                      { (yyval.char_var_) = make_ACchar_var((yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 6100 "Parser.c"
    break;

  case 281: /* CHAR_VAR: QUAL_STRUCT _SYMB_7 CHAR_ID  */
#line 999 "HAL_S.y"
                                { (yyval.char_var_) = make_ABchar_var((yyvsp[-2].qual_struct_), (yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 6106 "Parser.c"
    break;

  case 282: /* CHAR_VAR: QUAL_STRUCT _SYMB_7 CHAR_ID SUBSCRIPT  */
#line 1000 "HAL_S.y"
                                          { (yyval.char_var_) = make_ADchar_var((yyvsp[-3].qual_struct_), (yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 6112 "Parser.c"
    break;

  case 283: /* CHAR_CONST: CHAR_STRING  */
#line 1002 "HAL_S.y"
                         { (yyval.char_const_) = make_AAchar_const((yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 6118 "Parser.c"
    break;

  case 284: /* CHAR_CONST: _SYMB_53 _SYMB_2 NUMBER _SYMB_1 CHAR_STRING  */
#line 1003 "HAL_S.y"
                                                { (yyval.char_const_) = make_ABchar_const((yyvsp[-2].number_), (yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 6124 "Parser.c"
    break;

  case 285: /* CHAR_FUNC: _SYMB_100  */
#line 1005 "HAL_S.y"
                      { (yyval.char_func_) = make_ZZljust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 6130 "Parser.c"
    break;

  case 286: /* CHAR_FUNC: _SYMB_136  */
#line 1006 "HAL_S.y"
              { (yyval.char_func_) = make_ZZrjust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 6136 "Parser.c"
    break;

  case 287: /* CHAR_FUNC: _SYMB_169  */
#line 1007 "HAL_S.y"
              { (yyval.char_func_) = make_ZZtrim(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 6142 "Parser.c"
    break;

  case 288: /* CHAR_FUNC: _SYMB_189  */
#line 1008 "HAL_S.y"
              { (yyval.char_func_) = make_ZZuserCharFunction((yyvsp[0].string_)); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 6148 "Parser.c"
    break;

  case 289: /* CHAR_FUNC: _SYMB_54  */
#line 1009 "HAL_S.y"
             { (yyval.char_func_) = make_AAcharFuncCharacter(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 6154 "Parser.c"
    break;

  case 290: /* CHAR_ID: _SYMB_190  */
#line 1011 "HAL_S.y"
                    { (yyval.char_id_) = make_FIchar_id((yyvsp[0].string_)); (yyval.char_id_)->line_number = (yyloc).first_line; (yyval.char_id_)->char_number = (yyloc).first_column;  }
#line 6160 "Parser.c"
    break;

  case 291: /* NAME_EXP: NAME_KEY _SYMB_2 NAME_VAR _SYMB_1  */
#line 1013 "HAL_S.y"
                                             { (yyval.name_exp_) = make_AAnameExpKeyVar((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 6166 "Parser.c"
    break;

  case 292: /* NAME_EXP: _SYMB_112  */
#line 1014 "HAL_S.y"
              { (yyval.name_exp_) = make_ABnameExpNull(); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 6172 "Parser.c"
    break;

  case 293: /* NAME_EXP: NAME_KEY _SYMB_2 _SYMB_112 _SYMB_1  */
#line 1015 "HAL_S.y"
                                       { (yyval.name_exp_) = make_ACnameExpKeyNull((yyvsp[-3].name_key_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 6178 "Parser.c"
    break;

  case 294: /* NAME_KEY: _SYMB_108  */
#line 1017 "HAL_S.y"
                     { (yyval.name_key_) = make_AAname_key(); (yyval.name_key_)->line_number = (yyloc).first_line; (yyval.name_key_)->char_number = (yyloc).first_column;  }
#line 6184 "Parser.c"
    break;

  case 295: /* NAME_VAR: VARIABLE  */
#line 1019 "HAL_S.y"
                    { (yyval.name_var_) = make_AAname_var((yyvsp[0].variable_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 6190 "Parser.c"
    break;

  case 296: /* NAME_VAR: MODIFIED_ARITH_FUNC  */
#line 1020 "HAL_S.y"
                        { (yyval.name_var_) = make_ACname_var((yyvsp[0].modified_arith_func_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 6196 "Parser.c"
    break;

  case 297: /* NAME_VAR: LABEL_VAR  */
#line 1021 "HAL_S.y"
              { (yyval.name_var_) = make_ABname_var((yyvsp[0].label_var_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 6202 "Parser.c"
    break;

  case 298: /* VARIABLE: ARITH_VAR  */
#line 1023 "HAL_S.y"
                     { (yyval.variable_) = make_AAvariable((yyvsp[0].arith_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6208 "Parser.c"
    break;

  case 299: /* VARIABLE: BIT_VAR  */
#line 1024 "HAL_S.y"
            { (yyval.variable_) = make_ACvariable((yyvsp[0].bit_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6214 "Parser.c"
    break;

  case 300: /* VARIABLE: SUBBIT_HEAD VARIABLE _SYMB_1  */
#line 1025 "HAL_S.y"
                                 { (yyval.variable_) = make_AEvariable((yyvsp[-2].subbit_head_), (yyvsp[-1].variable_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6220 "Parser.c"
    break;

  case 301: /* VARIABLE: CHAR_VAR  */
#line 1026 "HAL_S.y"
             { (yyval.variable_) = make_AFvariable((yyvsp[0].char_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6226 "Parser.c"
    break;

  case 302: /* VARIABLE: NAME_KEY _SYMB_2 NAME_VAR _SYMB_1  */
#line 1027 "HAL_S.y"
                                      { (yyval.variable_) = make_AGvariable((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6232 "Parser.c"
    break;

  case 303: /* VARIABLE: EVENT_VAR  */
#line 1028 "HAL_S.y"
              { (yyval.variable_) = make_ADvariable((yyvsp[0].event_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6238 "Parser.c"
    break;

  case 304: /* VARIABLE: STRUCTURE_VAR  */
#line 1029 "HAL_S.y"
                  { (yyval.variable_) = make_ABvariable((yyvsp[0].structure_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 6244 "Parser.c"
    break;

  case 305: /* STRUCTURE_EXP: STRUCTURE_VAR  */
#line 1031 "HAL_S.y"
                              { (yyval.structure_exp_) = make_AAstructure_exp((yyvsp[0].structure_var_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 6250 "Parser.c"
    break;

  case 306: /* STRUCTURE_EXP: STRUCT_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 1032 "HAL_S.y"
                                               { (yyval.structure_exp_) = make_ADstructure_exp((yyvsp[-3].struct_func_head_), (yyvsp[-1].call_list_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 6256 "Parser.c"
    break;

  case 307: /* STRUCTURE_EXP: STRUC_INLINE_DEF CLOSING _SYMB_17  */
#line 1033 "HAL_S.y"
                                      { (yyval.structure_exp_) = make_ACstructure_exp((yyvsp[-2].struc_inline_def_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 6262 "Parser.c"
    break;

  case 308: /* STRUCTURE_EXP: STRUC_INLINE_DEF BLOCK_BODY CLOSING _SYMB_17  */
#line 1034 "HAL_S.y"
                                                 { (yyval.structure_exp_) = make_AEstructure_exp((yyvsp[-3].struc_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 6268 "Parser.c"
    break;

  case 309: /* STRUCT_FUNC_HEAD: STRUCT_FUNC  */
#line 1036 "HAL_S.y"
                               { (yyval.struct_func_head_) = make_AAstruct_func_head((yyvsp[0].struct_func_)); (yyval.struct_func_head_)->line_number = (yyloc).first_line; (yyval.struct_func_head_)->char_number = (yyloc).first_column;  }
#line 6274 "Parser.c"
    break;

  case 310: /* STRUCTURE_VAR: QUAL_STRUCT SUBSCRIPT  */
#line 1038 "HAL_S.y"
                                      { (yyval.structure_var_) = make_AAstructure_var((yyvsp[-1].qual_struct_), (yyvsp[0].subscript_)); (yyval.structure_var_)->line_number = (yyloc).first_line; (yyval.structure_var_)->char_number = (yyloc).first_column;  }
#line 6280 "Parser.c"
    break;

  case 311: /* STRUCT_FUNC: _SYMB_192  */
#line 1040 "HAL_S.y"
                        { (yyval.struct_func_) = make_ZZuserStructFunc((yyvsp[0].string_)); (yyval.struct_func_)->line_number = (yyloc).first_line; (yyval.struct_func_)->char_number = (yyloc).first_column;  }
#line 6286 "Parser.c"
    break;

  case 312: /* QUAL_STRUCT: STRUCTURE_ID  */
#line 1042 "HAL_S.y"
                           { (yyval.qual_struct_) = make_AAqual_struct((yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 6292 "Parser.c"
    break;

  case 313: /* QUAL_STRUCT: QUAL_STRUCT _SYMB_7 STRUCTURE_ID  */
#line 1043 "HAL_S.y"
                                     { (yyval.qual_struct_) = make_ABqual_struct((yyvsp[-2].qual_struct_), (yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 6298 "Parser.c"
    break;

  case 314: /* STRUCTURE_ID: _SYMB_191  */
#line 1045 "HAL_S.y"
                         { (yyval.structure_id_) = make_FJstructure_id((yyvsp[0].string_)); (yyval.structure_id_)->line_number = (yyloc).first_line; (yyval.structure_id_)->char_number = (yyloc).first_column;  }
#line 6304 "Parser.c"
    break;

  case 315: /* ASSIGNMENT: VARIABLE EQUALS EXPRESSION  */
#line 1047 "HAL_S.y"
                                        { (yyval.assignment_) = make_AAassignment((yyvsp[-2].variable_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6310 "Parser.c"
    break;

  case 316: /* ASSIGNMENT: VARIABLE _SYMB_0 ASSIGNMENT  */
#line 1048 "HAL_S.y"
                                { (yyval.assignment_) = make_ABassignment((yyvsp[-2].variable_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6316 "Parser.c"
    break;

  case 317: /* ASSIGNMENT: QUAL_STRUCT EQUALS EXPRESSION  */
#line 1049 "HAL_S.y"
                                  { (yyval.assignment_) = make_ACassignment((yyvsp[-2].qual_struct_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6322 "Parser.c"
    break;

  case 318: /* ASSIGNMENT: QUAL_STRUCT _SYMB_0 ASSIGNMENT  */
#line 1050 "HAL_S.y"
                                   { (yyval.assignment_) = make_ADassignment((yyvsp[-2].qual_struct_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 6328 "Parser.c"
    break;

  case 319: /* EQUALS: _SYMB_24  */
#line 1052 "HAL_S.y"
                  { (yyval.equals_) = make_AAequals(); (yyval.equals_)->line_number = (yyloc).first_line; (yyval.equals_)->char_number = (yyloc).first_column;  }
#line 6334 "Parser.c"
    break;

  case 320: /* STATEMENT: BASIC_STATEMENT  */
#line 1054 "HAL_S.y"
                            { (yyval.statement_) = make_AAstatement((yyvsp[0].basic_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6340 "Parser.c"
    break;

  case 321: /* STATEMENT: OTHER_STATEMENT  */
#line 1055 "HAL_S.y"
                    { (yyval.statement_) = make_ABstatement((yyvsp[0].other_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6346 "Parser.c"
    break;

  case 322: /* STATEMENT: INLINE_DEFINITION  */
#line 1056 "HAL_S.y"
                      { (yyval.statement_) = make_AZstatement((yyvsp[0].inline_definition_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6352 "Parser.c"
    break;

  case 323: /* BASIC_STATEMENT: ASSIGNMENT _SYMB_17  */
#line 1058 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_ABbasicStatementAssignment((yyvsp[-1].assignment_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6358 "Parser.c"
    break;

  case 324: /* BASIC_STATEMENT: LABEL_DEFINITION BASIC_STATEMENT  */
#line 1059 "HAL_S.y"
                                     { (yyval.basic_statement_) = make_AAbasic_statement((yyvsp[-1].label_definition_), (yyvsp[0].basic_statement_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6364 "Parser.c"
    break;

  case 325: /* BASIC_STATEMENT: _SYMB_80 _SYMB_17  */
#line 1060 "HAL_S.y"
                      { (yyval.basic_statement_) = make_ACbasicStatementExit(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6370 "Parser.c"
    break;

  case 326: /* BASIC_STATEMENT: _SYMB_80 LABEL _SYMB_17  */
#line 1061 "HAL_S.y"
                            { (yyval.basic_statement_) = make_ADbasicStatementExit((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6376 "Parser.c"
    break;

  case 327: /* BASIC_STATEMENT: _SYMB_131 _SYMB_17  */
#line 1062 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AEbasicStatementRepeat(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6382 "Parser.c"
    break;

  case 328: /* BASIC_STATEMENT: _SYMB_131 LABEL _SYMB_17  */
#line 1063 "HAL_S.y"
                             { (yyval.basic_statement_) = make_AFbasicStatementRepeat((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6388 "Parser.c"
    break;

  case 329: /* BASIC_STATEMENT: _SYMB_88 _SYMB_166 LABEL _SYMB_17  */
#line 1064 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AGbasicStatementGoTo((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6394 "Parser.c"
    break;

  case 330: /* BASIC_STATEMENT: _SYMB_17  */
#line 1065 "HAL_S.y"
             { (yyval.basic_statement_) = make_AHbasicStatementEmpty(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6400 "Parser.c"
    break;

  case 331: /* BASIC_STATEMENT: CALL_KEY _SYMB_17  */
#line 1066 "HAL_S.y"
                      { (yyval.basic_statement_) = make_AIbasicStatementCall((yyvsp[-1].call_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6406 "Parser.c"
    break;

  case 332: /* BASIC_STATEMENT: CALL_KEY _SYMB_2 CALL_LIST _SYMB_1 _SYMB_17  */
#line 1067 "HAL_S.y"
                                                { (yyval.basic_statement_) = make_AJbasicStatementCall((yyvsp[-4].call_key_), (yyvsp[-2].call_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6412 "Parser.c"
    break;

  case 333: /* BASIC_STATEMENT: CALL_KEY ASSIGN _SYMB_2 CALL_ASSIGN_LIST _SYMB_1 _SYMB_17  */
#line 1068 "HAL_S.y"
                                                              { (yyval.basic_statement_) = make_AKbasicStatementCall((yyvsp[-5].call_key_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6418 "Parser.c"
    break;

  case 334: /* BASIC_STATEMENT: CALL_KEY _SYMB_2 CALL_LIST _SYMB_1 ASSIGN _SYMB_2 CALL_ASSIGN_LIST _SYMB_1 _SYMB_17  */
#line 1069 "HAL_S.y"
                                                                                        { (yyval.basic_statement_) = make_ALbasicStatementCall((yyvsp[-8].call_key_), (yyvsp[-6].call_list_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6424 "Parser.c"
    break;

  case 335: /* BASIC_STATEMENT: _SYMB_134 _SYMB_17  */
#line 1070 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AMbasicStatementReturn(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6430 "Parser.c"
    break;

  case 336: /* BASIC_STATEMENT: _SYMB_134 EXPRESSION _SYMB_17  */
#line 1071 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_ANbasicStatementReturn((yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6436 "Parser.c"
    break;

  case 337: /* BASIC_STATEMENT: DO_GROUP_HEAD ENDING _SYMB_17  */
#line 1072 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_AObasicStatementDo((yyvsp[-2].do_group_head_), (yyvsp[-1].ending_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6442 "Parser.c"
    break;

  case 338: /* BASIC_STATEMENT: READ_KEY _SYMB_17  */
#line 1073 "HAL_S.y"
                      { (yyval.basic_statement_) = make_APbasicStatementReadKey((yyvsp[-1].read_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6448 "Parser.c"
    break;

  case 339: /* BASIC_STATEMENT: READ_PHRASE _SYMB_17  */
#line 1074 "HAL_S.y"
                         { (yyval.basic_statement_) = make_AQbasicStatementReadPhrase((yyvsp[-1].read_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6454 "Parser.c"
    break;

  case 340: /* BASIC_STATEMENT: WRITE_KEY _SYMB_17  */
#line 1075 "HAL_S.y"
                       { (yyval.basic_statement_) = make_ARbasicStatementWriteKey((yyvsp[-1].write_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6460 "Parser.c"
    break;

  case 341: /* BASIC_STATEMENT: WRITE_PHRASE _SYMB_17  */
#line 1076 "HAL_S.y"
                          { (yyval.basic_statement_) = make_ASbasicStatementWritePhrase((yyvsp[-1].write_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6466 "Parser.c"
    break;

  case 342: /* BASIC_STATEMENT: FILE_EXP EQUALS EXPRESSION _SYMB_17  */
#line 1077 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_ATbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6472 "Parser.c"
    break;

  case 343: /* BASIC_STATEMENT: VARIABLE EQUALS FILE_EXP _SYMB_17  */
#line 1078 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AUbasicStatementFileExp((yyvsp[-3].variable_), (yyvsp[-2].equals_), (yyvsp[-1].file_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6478 "Parser.c"
    break;

  case 344: /* BASIC_STATEMENT: FILE_EXP EQUALS QUAL_STRUCT _SYMB_17  */
#line 1079 "HAL_S.y"
                                         { (yyval.basic_statement_) = make_AVbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].qual_struct_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6484 "Parser.c"
    break;

  case 345: /* BASIC_STATEMENT: WAIT_KEY _SYMB_86 _SYMB_66 _SYMB_17  */
#line 1080 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_AVbasicStatementWait((yyvsp[-3].wait_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6490 "Parser.c"
    break;

  case 346: /* BASIC_STATEMENT: WAIT_KEY ARITH_EXP _SYMB_17  */
#line 1081 "HAL_S.y"
                                { (yyval.basic_statement_) = make_AWbasicStatementWait((yyvsp[-2].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6496 "Parser.c"
    break;

  case 347: /* BASIC_STATEMENT: WAIT_KEY _SYMB_173 ARITH_EXP _SYMB_17  */
#line 1082 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_AXbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6502 "Parser.c"
    break;

  case 348: /* BASIC_STATEMENT: WAIT_KEY _SYMB_86 BIT_EXP _SYMB_17  */
#line 1083 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_AYbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].bit_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6508 "Parser.c"
    break;

  case 349: /* BASIC_STATEMENT: TERMINATOR _SYMB_17  */
#line 1084 "HAL_S.y"
                        { (yyval.basic_statement_) = make_AZbasicStatementTerminator((yyvsp[-1].terminator_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6514 "Parser.c"
    break;

  case 350: /* BASIC_STATEMENT: TERMINATOR TERMINATE_LIST _SYMB_17  */
#line 1085 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_BAbasicStatementTerminator((yyvsp[-2].terminator_), (yyvsp[-1].terminate_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6520 "Parser.c"
    break;

  case 351: /* BASIC_STATEMENT: _SYMB_174 _SYMB_120 _SYMB_166 ARITH_EXP _SYMB_17  */
#line 1086 "HAL_S.y"
                                                     { (yyval.basic_statement_) = make_BBbasicStatementUpdate((yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6526 "Parser.c"
    break;

  case 352: /* BASIC_STATEMENT: _SYMB_174 _SYMB_120 LABEL_VAR _SYMB_166 ARITH_EXP _SYMB_17  */
#line 1087 "HAL_S.y"
                                                               { (yyval.basic_statement_) = make_BCbasicStatementUpdate((yyvsp[-3].label_var_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6532 "Parser.c"
    break;

  case 353: /* BASIC_STATEMENT: SCHEDULE_PHRASE _SYMB_17  */
#line 1088 "HAL_S.y"
                             { (yyval.basic_statement_) = make_BDbasicStatementSchedule((yyvsp[-1].schedule_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6538 "Parser.c"
    break;

  case 354: /* BASIC_STATEMENT: SCHEDULE_PHRASE SCHEDULE_CONTROL _SYMB_17  */
#line 1089 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BEbasicStatementSchedule((yyvsp[-2].schedule_phrase_), (yyvsp[-1].schedule_control_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6544 "Parser.c"
    break;

  case 355: /* BASIC_STATEMENT: SIGNAL_CLAUSE _SYMB_17  */
#line 1090 "HAL_S.y"
                           { (yyval.basic_statement_) = make_BFbasicStatementSignal((yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6550 "Parser.c"
    break;

  case 356: /* BASIC_STATEMENT: _SYMB_141 _SYMB_76 SUBSCRIPT _SYMB_17  */
#line 1091 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BGbasicStatementSend((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6556 "Parser.c"
    break;

  case 357: /* BASIC_STATEMENT: _SYMB_141 _SYMB_76 _SYMB_17  */
#line 1092 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BHbasicStatementSend(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6562 "Parser.c"
    break;

  case 358: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_17  */
#line 1093 "HAL_S.y"
                       { (yyval.basic_statement_) = make_BHbasicStatementOn((yyvsp[-1].on_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6568 "Parser.c"
    break;

  case 359: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_32 SIGNAL_CLAUSE _SYMB_17  */
#line 1094 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BIbasicStatementOnAndSignal((yyvsp[-3].on_clause_), (yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6574 "Parser.c"
    break;

  case 360: /* BASIC_STATEMENT: _SYMB_115 _SYMB_76 SUBSCRIPT _SYMB_17  */
#line 1095 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BJbasicStatementOff((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6580 "Parser.c"
    break;

  case 361: /* BASIC_STATEMENT: _SYMB_115 _SYMB_76 _SYMB_17  */
#line 1096 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementOff(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6586 "Parser.c"
    break;

  case 362: /* BASIC_STATEMENT: PERCENT_MACRO_NAME _SYMB_17  */
#line 1097 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementPercentMacro((yyvsp[-1].percent_macro_name_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6592 "Parser.c"
    break;

  case 363: /* BASIC_STATEMENT: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_1 _SYMB_17  */
#line 1098 "HAL_S.y"
                                                          { (yyval.basic_statement_) = make_BLbasicStatementPercentMacro((yyvsp[-3].percent_macro_head_), (yyvsp[-2].percent_macro_arg_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6598 "Parser.c"
    break;

  case 364: /* OTHER_STATEMENT: IF_STATEMENT  */
#line 1100 "HAL_S.y"
                               { (yyval.other_statement_) = make_ABotherStatementIf((yyvsp[0].if_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6604 "Parser.c"
    break;

  case 365: /* OTHER_STATEMENT: ON_PHRASE STATEMENT  */
#line 1101 "HAL_S.y"
                        { (yyval.other_statement_) = make_AAotherStatementOn((yyvsp[-1].on_phrase_), (yyvsp[0].statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6610 "Parser.c"
    break;

  case 366: /* OTHER_STATEMENT: LABEL_DEFINITION OTHER_STATEMENT  */
#line 1102 "HAL_S.y"
                                     { (yyval.other_statement_) = make_ACother_statement((yyvsp[-1].label_definition_), (yyvsp[0].other_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6616 "Parser.c"
    break;

  case 367: /* IF_STATEMENT: IF_CLAUSE STATEMENT  */
#line 1104 "HAL_S.y"
                                   { (yyval.if_statement_) = make_AAifStatement((yyvsp[-1].if_clause_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 6622 "Parser.c"
    break;

  case 368: /* IF_STATEMENT: TRUE_PART STATEMENT  */
#line 1105 "HAL_S.y"
                        { (yyval.if_statement_) = make_ABifThenElseStatement((yyvsp[-1].true_part_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 6628 "Parser.c"
    break;

  case 369: /* IF_CLAUSE: IF RELATIONAL_EXP THEN  */
#line 1107 "HAL_S.y"
                                   { (yyval.if_clause_) = make_AAifClauseRelationalExp((yyvsp[-2].if_), (yyvsp[-1].relational_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 6634 "Parser.c"
    break;

  case 370: /* IF_CLAUSE: IF BIT_EXP THEN  */
#line 1108 "HAL_S.y"
                    { (yyval.if_clause_) = make_ABifClauseBitExp((yyvsp[-2].if_), (yyvsp[-1].bit_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 6640 "Parser.c"
    break;

  case 371: /* TRUE_PART: IF_CLAUSE BASIC_STATEMENT _SYMB_71  */
#line 1110 "HAL_S.y"
                                               { (yyval.true_part_) = make_AAtrue_part((yyvsp[-2].if_clause_), (yyvsp[-1].basic_statement_)); (yyval.true_part_)->line_number = (yyloc).first_line; (yyval.true_part_)->char_number = (yyloc).first_column;  }
#line 6646 "Parser.c"
    break;

  case 372: /* IF: _SYMB_90  */
#line 1112 "HAL_S.y"
              { (yyval.if_) = make_AAif(); (yyval.if_)->line_number = (yyloc).first_line; (yyval.if_)->char_number = (yyloc).first_column;  }
#line 6652 "Parser.c"
    break;

  case 373: /* THEN: _SYMB_165  */
#line 1114 "HAL_S.y"
                 { (yyval.then_) = make_AAthen(); (yyval.then_)->line_number = (yyloc).first_line; (yyval.then_)->char_number = (yyloc).first_column;  }
#line 6658 "Parser.c"
    break;

  case 374: /* RELATIONAL_EXP: RELATIONAL_FACTOR  */
#line 1116 "HAL_S.y"
                                   { (yyval.relational_exp_) = make_AArelational_exp((yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 6664 "Parser.c"
    break;

  case 375: /* RELATIONAL_EXP: RELATIONAL_EXP OR RELATIONAL_FACTOR  */
#line 1117 "HAL_S.y"
                                        { (yyval.relational_exp_) = make_ABrelational_expOR((yyvsp[-2].relational_exp_), (yyvsp[-1].or_), (yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 6670 "Parser.c"
    break;

  case 376: /* RELATIONAL_FACTOR: REL_PRIM  */
#line 1119 "HAL_S.y"
                             { (yyval.relational_factor_) = make_AArelational_factor((yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 6676 "Parser.c"
    break;

  case 377: /* RELATIONAL_FACTOR: RELATIONAL_FACTOR AND REL_PRIM  */
#line 1120 "HAL_S.y"
                                   { (yyval.relational_factor_) = make_ABrelational_factorAND((yyvsp[-2].relational_factor_), (yyvsp[-1].and_), (yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 6682 "Parser.c"
    break;

  case 378: /* REL_PRIM: _SYMB_2 RELATIONAL_EXP _SYMB_1  */
#line 1122 "HAL_S.y"
                                          { (yyval.rel_prim_) = make_AArel_prim((yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6688 "Parser.c"
    break;

  case 379: /* REL_PRIM: NOT _SYMB_2 RELATIONAL_EXP _SYMB_1  */
#line 1123 "HAL_S.y"
                                       { (yyval.rel_prim_) = make_ABrel_prim((yyvsp[-3].not_), (yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6694 "Parser.c"
    break;

  case 380: /* REL_PRIM: COMPARISON  */
#line 1124 "HAL_S.y"
               { (yyval.rel_prim_) = make_ACrel_prim((yyvsp[0].comparison_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6700 "Parser.c"
    break;

  case 381: /* COMPARISON: ARITH_EXP EQUALS ARITH_EXP  */
#line 1126 "HAL_S.y"
                                        { (yyval.comparison_) = make_AAcomparisonEQ((yyvsp[-2].arith_exp_), (yyvsp[-1].equals_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6706 "Parser.c"
    break;

  case 382: /* COMPARISON: CHAR_EXP EQUALS CHAR_EXP  */
#line 1127 "HAL_S.y"
                             { (yyval.comparison_) = make_ABcomparisonEQ((yyvsp[-2].char_exp_), (yyvsp[-1].equals_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6712 "Parser.c"
    break;

  case 383: /* COMPARISON: BIT_CAT EQUALS BIT_CAT  */
#line 1128 "HAL_S.y"
                           { (yyval.comparison_) = make_ACcomparisonEQ((yyvsp[-2].bit_cat_), (yyvsp[-1].equals_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6718 "Parser.c"
    break;

  case 384: /* COMPARISON: STRUCTURE_EXP EQUALS STRUCTURE_EXP  */
#line 1129 "HAL_S.y"
                                       { (yyval.comparison_) = make_ADcomparisonEQ((yyvsp[-2].structure_exp_), (yyvsp[-1].equals_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6724 "Parser.c"
    break;

  case 385: /* COMPARISON: NAME_EXP EQUALS NAME_EXP  */
#line 1130 "HAL_S.y"
                             { (yyval.comparison_) = make_AEcomparisonEQ((yyvsp[-2].name_exp_), (yyvsp[-1].equals_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6730 "Parser.c"
    break;

  case 386: /* COMPARISON: ARITH_EXP _SYMB_183 ARITH_EXP  */
#line 1131 "HAL_S.y"
                                  { (yyval.comparison_) = make_AAcomparisonNEQ((yyvsp[-2].arith_exp_), (yyvsp[-1].string_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6736 "Parser.c"
    break;

  case 387: /* COMPARISON: CHAR_EXP _SYMB_183 CHAR_EXP  */
#line 1132 "HAL_S.y"
                                { (yyval.comparison_) = make_ABcomparisonNEQ((yyvsp[-2].char_exp_), (yyvsp[-1].string_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6742 "Parser.c"
    break;

  case 388: /* COMPARISON: BIT_CAT _SYMB_183 BIT_CAT  */
#line 1133 "HAL_S.y"
                              { (yyval.comparison_) = make_ACcomparisonNEQ((yyvsp[-2].bit_cat_), (yyvsp[-1].string_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6748 "Parser.c"
    break;

  case 389: /* COMPARISON: STRUCTURE_EXP _SYMB_183 STRUCTURE_EXP  */
#line 1134 "HAL_S.y"
                                          { (yyval.comparison_) = make_ADcomparisonNEQ((yyvsp[-2].structure_exp_), (yyvsp[-1].string_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6754 "Parser.c"
    break;

  case 390: /* COMPARISON: NAME_EXP _SYMB_183 NAME_EXP  */
#line 1135 "HAL_S.y"
                                { (yyval.comparison_) = make_AEcomparisonNEQ((yyvsp[-2].name_exp_), (yyvsp[-1].string_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6760 "Parser.c"
    break;

  case 391: /* COMPARISON: ARITH_EXP _SYMB_23 ARITH_EXP  */
#line 1136 "HAL_S.y"
                                 { (yyval.comparison_) = make_AAcomparisonLT((yyvsp[-2].arith_exp_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6766 "Parser.c"
    break;

  case 392: /* COMPARISON: CHAR_EXP _SYMB_23 CHAR_EXP  */
#line 1137 "HAL_S.y"
                               { (yyval.comparison_) = make_ABcomparisonLT((yyvsp[-2].char_exp_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6772 "Parser.c"
    break;

  case 393: /* COMPARISON: BIT_CAT _SYMB_23 BIT_CAT  */
#line 1138 "HAL_S.y"
                             { (yyval.comparison_) = make_ACcomparisonLT((yyvsp[-2].bit_cat_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6778 "Parser.c"
    break;

  case 394: /* COMPARISON: STRUCTURE_EXP _SYMB_23 STRUCTURE_EXP  */
#line 1139 "HAL_S.y"
                                         { (yyval.comparison_) = make_ADcomparisonLT((yyvsp[-2].structure_exp_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6784 "Parser.c"
    break;

  case 395: /* COMPARISON: NAME_EXP _SYMB_23 NAME_EXP  */
#line 1140 "HAL_S.y"
                               { (yyval.comparison_) = make_AEcomparisonLT((yyvsp[-2].name_exp_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6790 "Parser.c"
    break;

  case 396: /* COMPARISON: ARITH_EXP _SYMB_25 ARITH_EXP  */
#line 1141 "HAL_S.y"
                                 { (yyval.comparison_) = make_AAcomparisonGT((yyvsp[-2].arith_exp_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6796 "Parser.c"
    break;

  case 397: /* COMPARISON: CHAR_EXP _SYMB_25 CHAR_EXP  */
#line 1142 "HAL_S.y"
                               { (yyval.comparison_) = make_ABcomparisonGT((yyvsp[-2].char_exp_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6802 "Parser.c"
    break;

  case 398: /* COMPARISON: BIT_CAT _SYMB_25 BIT_CAT  */
#line 1143 "HAL_S.y"
                             { (yyval.comparison_) = make_ACcomparisonGT((yyvsp[-2].bit_cat_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6808 "Parser.c"
    break;

  case 399: /* COMPARISON: STRUCTURE_EXP _SYMB_25 STRUCTURE_EXP  */
#line 1144 "HAL_S.y"
                                         { (yyval.comparison_) = make_ADcomparisonGT((yyvsp[-2].structure_exp_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6814 "Parser.c"
    break;

  case 400: /* COMPARISON: NAME_EXP _SYMB_25 NAME_EXP  */
#line 1145 "HAL_S.y"
                               { (yyval.comparison_) = make_AEcomparisonGT((yyvsp[-2].name_exp_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6820 "Parser.c"
    break;

  case 401: /* COMPARISON: ARITH_EXP _SYMB_184 ARITH_EXP  */
#line 1146 "HAL_S.y"
                                  { (yyval.comparison_) = make_AAcomparisonLE((yyvsp[-2].arith_exp_), (yyvsp[-1].string_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6826 "Parser.c"
    break;

  case 402: /* COMPARISON: CHAR_EXP _SYMB_184 CHAR_EXP  */
#line 1147 "HAL_S.y"
                                { (yyval.comparison_) = make_ABcomparisonLE((yyvsp[-2].char_exp_), (yyvsp[-1].string_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6832 "Parser.c"
    break;

  case 403: /* COMPARISON: BIT_CAT _SYMB_184 BIT_CAT  */
#line 1148 "HAL_S.y"
                              { (yyval.comparison_) = make_ACcomparisonLE((yyvsp[-2].bit_cat_), (yyvsp[-1].string_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6838 "Parser.c"
    break;

  case 404: /* COMPARISON: STRUCTURE_EXP _SYMB_184 STRUCTURE_EXP  */
#line 1149 "HAL_S.y"
                                          { (yyval.comparison_) = make_ADcomparisonLE((yyvsp[-2].structure_exp_), (yyvsp[-1].string_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6844 "Parser.c"
    break;

  case 405: /* COMPARISON: NAME_EXP _SYMB_184 NAME_EXP  */
#line 1150 "HAL_S.y"
                                { (yyval.comparison_) = make_AEcomparisonLE((yyvsp[-2].name_exp_), (yyvsp[-1].string_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6850 "Parser.c"
    break;

  case 406: /* COMPARISON: ARITH_EXP _SYMB_185 ARITH_EXP  */
#line 1151 "HAL_S.y"
                                  { (yyval.comparison_) = make_AAcomparisonGE((yyvsp[-2].arith_exp_), (yyvsp[-1].string_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6856 "Parser.c"
    break;

  case 407: /* COMPARISON: CHAR_EXP _SYMB_185 CHAR_EXP  */
#line 1152 "HAL_S.y"
                                { (yyval.comparison_) = make_ABcomparisonGE((yyvsp[-2].char_exp_), (yyvsp[-1].string_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6862 "Parser.c"
    break;

  case 408: /* COMPARISON: BIT_CAT _SYMB_185 BIT_CAT  */
#line 1153 "HAL_S.y"
                              { (yyval.comparison_) = make_ACcomparisonGE((yyvsp[-2].bit_cat_), (yyvsp[-1].string_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6868 "Parser.c"
    break;

  case 409: /* COMPARISON: STRUCTURE_EXP _SYMB_185 STRUCTURE_EXP  */
#line 1154 "HAL_S.y"
                                          { (yyval.comparison_) = make_ADcomparisonGE((yyvsp[-2].structure_exp_), (yyvsp[-1].string_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6874 "Parser.c"
    break;

  case 410: /* COMPARISON: NAME_EXP _SYMB_185 NAME_EXP  */
#line 1155 "HAL_S.y"
                                { (yyval.comparison_) = make_AEcomparisonGE((yyvsp[-2].name_exp_), (yyvsp[-1].string_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6880 "Parser.c"
    break;

  case 411: /* ANY_STATEMENT: STATEMENT  */
#line 1157 "HAL_S.y"
                          { (yyval.any_statement_) = make_AAany_statement((yyvsp[0].statement_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6886 "Parser.c"
    break;

  case 412: /* ANY_STATEMENT: BLOCK_DEFINITION  */
#line 1158 "HAL_S.y"
                     { (yyval.any_statement_) = make_ABany_statement((yyvsp[0].block_definition_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6892 "Parser.c"
    break;

  case 413: /* ON_PHRASE: _SYMB_116 _SYMB_76 SUBSCRIPT  */
#line 1160 "HAL_S.y"
                                         { (yyval.on_phrase_) = make_AAon_phrase((yyvsp[0].subscript_)); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6898 "Parser.c"
    break;

  case 414: /* ON_PHRASE: _SYMB_116 _SYMB_76  */
#line 1161 "HAL_S.y"
                       { (yyval.on_phrase_) = make_ACon_phrase(); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6904 "Parser.c"
    break;

  case 415: /* ON_CLAUSE: _SYMB_116 _SYMB_76 SUBSCRIPT _SYMB_158  */
#line 1163 "HAL_S.y"
                                                   { (yyval.on_clause_) = make_AAon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6910 "Parser.c"
    break;

  case 416: /* ON_CLAUSE: _SYMB_116 _SYMB_76 SUBSCRIPT _SYMB_91  */
#line 1164 "HAL_S.y"
                                          { (yyval.on_clause_) = make_ABon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6916 "Parser.c"
    break;

  case 417: /* ON_CLAUSE: _SYMB_116 _SYMB_76 _SYMB_158  */
#line 1165 "HAL_S.y"
                                 { (yyval.on_clause_) = make_ADon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6922 "Parser.c"
    break;

  case 418: /* ON_CLAUSE: _SYMB_116 _SYMB_76 _SYMB_91  */
#line 1166 "HAL_S.y"
                                { (yyval.on_clause_) = make_AEon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6928 "Parser.c"
    break;

  case 419: /* LABEL_DEFINITION: LABEL _SYMB_18  */
#line 1168 "HAL_S.y"
                                  { (yyval.label_definition_) = make_AAlabel_definition((yyvsp[-1].label_)); (yyval.label_definition_)->line_number = (yyloc).first_line; (yyval.label_definition_)->char_number = (yyloc).first_column;  }
#line 6934 "Parser.c"
    break;

  case 420: /* CALL_KEY: _SYMB_48 LABEL_VAR  */
#line 1170 "HAL_S.y"
                              { (yyval.call_key_) = make_AAcall_key((yyvsp[0].label_var_)); (yyval.call_key_)->line_number = (yyloc).first_line; (yyval.call_key_)->char_number = (yyloc).first_column;  }
#line 6940 "Parser.c"
    break;

  case 421: /* ASSIGN: _SYMB_41  */
#line 1172 "HAL_S.y"
                  { (yyval.assign_) = make_AAassign(); (yyval.assign_)->line_number = (yyloc).first_line; (yyval.assign_)->char_number = (yyloc).first_column;  }
#line 6946 "Parser.c"
    break;

  case 422: /* CALL_ASSIGN_LIST: VARIABLE  */
#line 1174 "HAL_S.y"
                            { (yyval.call_assign_list_) = make_AAcall_assign_list((yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6952 "Parser.c"
    break;

  case 423: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_0 VARIABLE  */
#line 1175 "HAL_S.y"
                                      { (yyval.call_assign_list_) = make_ABcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6958 "Parser.c"
    break;

  case 424: /* CALL_ASSIGN_LIST: QUAL_STRUCT  */
#line 1176 "HAL_S.y"
                { (yyval.call_assign_list_) = make_ACcall_assign_list((yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6964 "Parser.c"
    break;

  case 425: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_0 QUAL_STRUCT  */
#line 1177 "HAL_S.y"
                                         { (yyval.call_assign_list_) = make_ADcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6970 "Parser.c"
    break;

  case 426: /* DO_GROUP_HEAD: _SYMB_69 _SYMB_17  */
#line 1179 "HAL_S.y"
                                  { (yyval.do_group_head_) = make_AAdoGroupHead(); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6976 "Parser.c"
    break;

  case 427: /* DO_GROUP_HEAD: _SYMB_69 FOR_LIST _SYMB_17  */
#line 1180 "HAL_S.y"
                               { (yyval.do_group_head_) = make_ABdoGroupHeadFor((yyvsp[-1].for_list_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6982 "Parser.c"
    break;

  case 428: /* DO_GROUP_HEAD: _SYMB_69 FOR_LIST WHILE_CLAUSE _SYMB_17  */
#line 1181 "HAL_S.y"
                                            { (yyval.do_group_head_) = make_ACdoGroupHeadForWhile((yyvsp[-2].for_list_), (yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6988 "Parser.c"
    break;

  case 429: /* DO_GROUP_HEAD: _SYMB_69 WHILE_CLAUSE _SYMB_17  */
#line 1182 "HAL_S.y"
                                   { (yyval.do_group_head_) = make_ADdoGroupHeadWhile((yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6994 "Parser.c"
    break;

  case 430: /* DO_GROUP_HEAD: _SYMB_69 _SYMB_50 ARITH_EXP _SYMB_17  */
#line 1183 "HAL_S.y"
                                         { (yyval.do_group_head_) = make_AEdoGroupHeadCase((yyvsp[-1].arith_exp_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 7000 "Parser.c"
    break;

  case 431: /* DO_GROUP_HEAD: CASE_ELSE STATEMENT  */
#line 1184 "HAL_S.y"
                        { (yyval.do_group_head_) = make_AFdoGroupHeadCaseElse((yyvsp[-1].case_else_), (yyvsp[0].statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 7006 "Parser.c"
    break;

  case 432: /* DO_GROUP_HEAD: DO_GROUP_HEAD ANY_STATEMENT  */
#line 1185 "HAL_S.y"
                                { (yyval.do_group_head_) = make_AGdoGroupHeadStatement((yyvsp[-1].do_group_head_), (yyvsp[0].any_statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 7012 "Parser.c"
    break;

  case 433: /* DO_GROUP_HEAD: DO_GROUP_HEAD TEMPORARY_STMT  */
#line 1186 "HAL_S.y"
                                 { (yyval.do_group_head_) = make_AHdoGroupHeadTemporaryStatement((yyvsp[-1].do_group_head_), (yyvsp[0].temporary_stmt_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 7018 "Parser.c"
    break;

  case 434: /* ENDING: _SYMB_72  */
#line 1188 "HAL_S.y"
                  { (yyval.ending_) = make_AAending(); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 7024 "Parser.c"
    break;

  case 435: /* ENDING: _SYMB_72 LABEL  */
#line 1189 "HAL_S.y"
                   { (yyval.ending_) = make_ABending((yyvsp[0].label_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 7030 "Parser.c"
    break;

  case 436: /* ENDING: LABEL_DEFINITION ENDING  */
#line 1190 "HAL_S.y"
                            { (yyval.ending_) = make_ACending((yyvsp[-1].label_definition_), (yyvsp[0].ending_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 7036 "Parser.c"
    break;

  case 437: /* READ_KEY: _SYMB_126 _SYMB_2 NUMBER _SYMB_1  */
#line 1192 "HAL_S.y"
                                            { (yyval.read_key_) = make_AAread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 7042 "Parser.c"
    break;

  case 438: /* READ_KEY: _SYMB_127 _SYMB_2 NUMBER _SYMB_1  */
#line 1193 "HAL_S.y"
                                     { (yyval.read_key_) = make_ABread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 7048 "Parser.c"
    break;

  case 439: /* WRITE_KEY: _SYMB_178 _SYMB_2 NUMBER _SYMB_1  */
#line 1195 "HAL_S.y"
                                             { (yyval.write_key_) = make_AAwrite_key((yyvsp[-1].number_)); (yyval.write_key_)->line_number = (yyloc).first_line; (yyval.write_key_)->char_number = (yyloc).first_column;  }
#line 7054 "Parser.c"
    break;

  case 440: /* READ_PHRASE: READ_KEY READ_ARG  */
#line 1197 "HAL_S.y"
                                { (yyval.read_phrase_) = make_AAread_phrase((yyvsp[-1].read_key_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 7060 "Parser.c"
    break;

  case 441: /* READ_PHRASE: READ_PHRASE _SYMB_0 READ_ARG  */
#line 1198 "HAL_S.y"
                                 { (yyval.read_phrase_) = make_ABread_phrase((yyvsp[-2].read_phrase_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 7066 "Parser.c"
    break;

  case 442: /* WRITE_PHRASE: WRITE_KEY WRITE_ARG  */
#line 1200 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_AAwrite_phrase((yyvsp[-1].write_key_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 7072 "Parser.c"
    break;

  case 443: /* WRITE_PHRASE: WRITE_PHRASE _SYMB_0 WRITE_ARG  */
#line 1201 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_ABwrite_phrase((yyvsp[-2].write_phrase_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 7078 "Parser.c"
    break;

  case 444: /* READ_ARG: VARIABLE  */
#line 1203 "HAL_S.y"
                    { (yyval.read_arg_) = make_AAread_arg((yyvsp[0].variable_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 7084 "Parser.c"
    break;

  case 445: /* READ_ARG: IO_CONTROL  */
#line 1204 "HAL_S.y"
               { (yyval.read_arg_) = make_ABread_arg((yyvsp[0].io_control_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 7090 "Parser.c"
    break;

  case 446: /* WRITE_ARG: EXPRESSION  */
#line 1206 "HAL_S.y"
                       { (yyval.write_arg_) = make_AAwrite_arg((yyvsp[0].expression_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 7096 "Parser.c"
    break;

  case 447: /* WRITE_ARG: IO_CONTROL  */
#line 1207 "HAL_S.y"
               { (yyval.write_arg_) = make_ABwrite_arg((yyvsp[0].io_control_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 7102 "Parser.c"
    break;

  case 448: /* WRITE_ARG: _SYMB_191  */
#line 1208 "HAL_S.y"
              { (yyval.write_arg_) = make_ACwrite_arg((yyvsp[0].string_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 7108 "Parser.c"
    break;

  case 449: /* FILE_EXP: FILE_HEAD _SYMB_0 ARITH_EXP _SYMB_1  */
#line 1210 "HAL_S.y"
                                               { (yyval.file_exp_) = make_AAfile_exp((yyvsp[-3].file_head_), (yyvsp[-1].arith_exp_)); (yyval.file_exp_)->line_number = (yyloc).first_line; (yyval.file_exp_)->char_number = (yyloc).first_column;  }
#line 7114 "Parser.c"
    break;

  case 450: /* FILE_HEAD: _SYMB_84 _SYMB_2 NUMBER  */
#line 1212 "HAL_S.y"
                                    { (yyval.file_head_) = make_AAfile_head((yyvsp[0].number_)); (yyval.file_head_)->line_number = (yyloc).first_line; (yyval.file_head_)->char_number = (yyloc).first_column;  }
#line 7120 "Parser.c"
    break;

  case 451: /* IO_CONTROL: _SYMB_152 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1214 "HAL_S.y"
                                                 { (yyval.io_control_) = make_AAioControlSkip((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 7126 "Parser.c"
    break;

  case 452: /* IO_CONTROL: _SYMB_159 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1215 "HAL_S.y"
                                        { (yyval.io_control_) = make_ABioControlTab((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 7132 "Parser.c"
    break;

  case 453: /* IO_CONTROL: _SYMB_57 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1216 "HAL_S.y"
                                       { (yyval.io_control_) = make_ACioControlColumn((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 7138 "Parser.c"
    break;

  case 454: /* IO_CONTROL: _SYMB_99 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1217 "HAL_S.y"
                                       { (yyval.io_control_) = make_ADioControlLine((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 7144 "Parser.c"
    break;

  case 455: /* IO_CONTROL: _SYMB_118 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1218 "HAL_S.y"
                                        { (yyval.io_control_) = make_AEioControlPage((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 7150 "Parser.c"
    break;

  case 456: /* WAIT_KEY: _SYMB_176  */
#line 1220 "HAL_S.y"
                     { (yyval.wait_key_) = make_AAwait_key(); (yyval.wait_key_)->line_number = (yyloc).first_line; (yyval.wait_key_)->char_number = (yyloc).first_column;  }
#line 7156 "Parser.c"
    break;

  case 457: /* TERMINATOR: _SYMB_164  */
#line 1222 "HAL_S.y"
                       { (yyval.terminator_) = make_AAterminatorTerminate(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 7162 "Parser.c"
    break;

  case 458: /* TERMINATOR: _SYMB_49  */
#line 1223 "HAL_S.y"
             { (yyval.terminator_) = make_ABterminatorCancel(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 7168 "Parser.c"
    break;

  case 459: /* TERMINATE_LIST: LABEL_VAR  */
#line 1225 "HAL_S.y"
                           { (yyval.terminate_list_) = make_AAterminate_list((yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 7174 "Parser.c"
    break;

  case 460: /* TERMINATE_LIST: TERMINATE_LIST _SYMB_0 LABEL_VAR  */
#line 1226 "HAL_S.y"
                                     { (yyval.terminate_list_) = make_ABterminate_list((yyvsp[-2].terminate_list_), (yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 7180 "Parser.c"
    break;

  case 461: /* SCHEDULE_HEAD: _SYMB_140 LABEL_VAR  */
#line 1228 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_AAscheduleHeadLabel((yyvsp[0].label_var_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 7186 "Parser.c"
    break;

  case 462: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_42 ARITH_EXP  */
#line 1229 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ABscheduleHeadAt((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 7192 "Parser.c"
    break;

  case 463: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_92 ARITH_EXP  */
#line 1230 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ACscheduleHeadIn((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 7198 "Parser.c"
    break;

  case 464: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_116 BIT_EXP  */
#line 1231 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_ADscheduleHeadOn((yyvsp[-2].schedule_head_), (yyvsp[0].bit_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 7204 "Parser.c"
    break;

  case 465: /* SCHEDULE_PHRASE: SCHEDULE_HEAD  */
#line 1233 "HAL_S.y"
                                { (yyval.schedule_phrase_) = make_AAschedule_phrase((yyvsp[0].schedule_head_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 7210 "Parser.c"
    break;

  case 466: /* SCHEDULE_PHRASE: SCHEDULE_HEAD _SYMB_120 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1234 "HAL_S.y"
                                                      { (yyval.schedule_phrase_) = make_ABschedule_phrase((yyvsp[-4].schedule_head_), (yyvsp[-1].arith_exp_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 7216 "Parser.c"
    break;

  case 467: /* SCHEDULE_PHRASE: SCHEDULE_PHRASE _SYMB_66  */
#line 1235 "HAL_S.y"
                             { (yyval.schedule_phrase_) = make_ACschedule_phrase((yyvsp[-1].schedule_phrase_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 7222 "Parser.c"
    break;

  case 468: /* SCHEDULE_CONTROL: STOPPING  */
#line 1237 "HAL_S.y"
                            { (yyval.schedule_control_) = make_AAschedule_control((yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 7228 "Parser.c"
    break;

  case 469: /* SCHEDULE_CONTROL: TIMING  */
#line 1238 "HAL_S.y"
           { (yyval.schedule_control_) = make_ABschedule_control((yyvsp[0].timing_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 7234 "Parser.c"
    break;

  case 470: /* SCHEDULE_CONTROL: TIMING STOPPING  */
#line 1239 "HAL_S.y"
                    { (yyval.schedule_control_) = make_ACschedule_control((yyvsp[-1].timing_), (yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 7240 "Parser.c"
    break;

  case 471: /* TIMING: REPEAT _SYMB_78 ARITH_EXP  */
#line 1241 "HAL_S.y"
                                   { (yyval.timing_) = make_AAtimingEvery((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 7246 "Parser.c"
    break;

  case 472: /* TIMING: REPEAT _SYMB_30 ARITH_EXP  */
#line 1242 "HAL_S.y"
                              { (yyval.timing_) = make_ABtimingAfter((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 7252 "Parser.c"
    break;

  case 473: /* TIMING: REPEAT  */
#line 1243 "HAL_S.y"
           { (yyval.timing_) = make_ACtiming((yyvsp[0].repeat_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 7258 "Parser.c"
    break;

  case 474: /* REPEAT: _SYMB_0 _SYMB_131  */
#line 1245 "HAL_S.y"
                           { (yyval.repeat_) = make_AArepeat(); (yyval.repeat_)->line_number = (yyloc).first_line; (yyval.repeat_)->char_number = (yyloc).first_column;  }
#line 7264 "Parser.c"
    break;

  case 475: /* STOPPING: WHILE_KEY ARITH_EXP  */
#line 1247 "HAL_S.y"
                               { (yyval.stopping_) = make_AAstopping((yyvsp[-1].while_key_), (yyvsp[0].arith_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 7270 "Parser.c"
    break;

  case 476: /* STOPPING: WHILE_KEY BIT_EXP  */
#line 1248 "HAL_S.y"
                      { (yyval.stopping_) = make_ABstopping((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 7276 "Parser.c"
    break;

  case 477: /* SIGNAL_CLAUSE: _SYMB_142 EVENT_VAR  */
#line 1250 "HAL_S.y"
                                    { (yyval.signal_clause_) = make_AAsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 7282 "Parser.c"
    break;

  case 478: /* SIGNAL_CLAUSE: _SYMB_133 EVENT_VAR  */
#line 1251 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ABsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 7288 "Parser.c"
    break;

  case 479: /* SIGNAL_CLAUSE: _SYMB_146 EVENT_VAR  */
#line 1252 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ACsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 7294 "Parser.c"
    break;

  case 480: /* PERCENT_MACRO_NAME: _SYMB_26 IDENTIFIER  */
#line 1254 "HAL_S.y"
                                         { (yyval.percent_macro_name_) = make_FNpercent_macro_name((yyvsp[0].identifier_)); (yyval.percent_macro_name_)->line_number = (yyloc).first_line; (yyval.percent_macro_name_)->char_number = (yyloc).first_column;  }
#line 7300 "Parser.c"
    break;

  case 481: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_NAME _SYMB_2  */
#line 1256 "HAL_S.y"
                                                { (yyval.percent_macro_head_) = make_AApercent_macro_head((yyvsp[-1].percent_macro_name_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 7306 "Parser.c"
    break;

  case 482: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_0  */
#line 1257 "HAL_S.y"
                                                 { (yyval.percent_macro_head_) = make_ABpercent_macro_head((yyvsp[-2].percent_macro_head_), (yyvsp[-1].percent_macro_arg_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 7312 "Parser.c"
    break;

  case 483: /* PERCENT_MACRO_ARG: NAME_VAR  */
#line 1259 "HAL_S.y"
                             { (yyval.percent_macro_arg_) = make_AApercent_macro_arg((yyvsp[0].name_var_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 7318 "Parser.c"
    break;

  case 484: /* PERCENT_MACRO_ARG: CONSTANT  */
#line 1260 "HAL_S.y"
             { (yyval.percent_macro_arg_) = make_ABpercent_macro_arg((yyvsp[0].constant_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 7324 "Parser.c"
    break;

  case 485: /* CASE_ELSE: _SYMB_69 _SYMB_50 ARITH_EXP _SYMB_17 _SYMB_71  */
#line 1262 "HAL_S.y"
                                                          { (yyval.case_else_) = make_AAcase_else((yyvsp[-2].arith_exp_)); (yyval.case_else_)->line_number = (yyloc).first_line; (yyval.case_else_)->char_number = (yyloc).first_column;  }
#line 7330 "Parser.c"
    break;

  case 486: /* WHILE_KEY: _SYMB_177  */
#line 1264 "HAL_S.y"
                      { (yyval.while_key_) = make_AAwhileKeyWhile(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 7336 "Parser.c"
    break;

  case 487: /* WHILE_KEY: _SYMB_173  */
#line 1265 "HAL_S.y"
              { (yyval.while_key_) = make_ABwhileKeyUntil(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 7342 "Parser.c"
    break;

  case 488: /* WHILE_CLAUSE: WHILE_KEY BIT_EXP  */
#line 1267 "HAL_S.y"
                                 { (yyval.while_clause_) = make_AAwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 7348 "Parser.c"
    break;

  case 489: /* WHILE_CLAUSE: WHILE_KEY RELATIONAL_EXP  */
#line 1268 "HAL_S.y"
                             { (yyval.while_clause_) = make_ABwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].relational_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 7354 "Parser.c"
    break;

  case 490: /* FOR_LIST: FOR_KEY ARITH_EXP ITERATION_CONTROL  */
#line 1270 "HAL_S.y"
                                               { (yyval.for_list_) = make_AAfor_list((yyvsp[-2].for_key_), (yyvsp[-1].arith_exp_), (yyvsp[0].iteration_control_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 7360 "Parser.c"
    break;

  case 491: /* FOR_LIST: FOR_KEY ITERATION_BODY  */
#line 1271 "HAL_S.y"
                           { (yyval.for_list_) = make_ABfor_listDiscrete((yyvsp[-1].for_key_), (yyvsp[0].iteration_body_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 7366 "Parser.c"
    break;

  case 492: /* ITERATION_BODY: ARITH_EXP  */
#line 1273 "HAL_S.y"
                           { (yyval.iteration_body_) = make_AAiteration_body((yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 7372 "Parser.c"
    break;

  case 493: /* ITERATION_BODY: ITERATION_BODY _SYMB_0 ARITH_EXP  */
#line 1274 "HAL_S.y"
                                     { (yyval.iteration_body_) = make_ABiteration_body((yyvsp[-2].iteration_body_), (yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 7378 "Parser.c"
    break;

  case 494: /* ITERATION_CONTROL: _SYMB_166 ARITH_EXP  */
#line 1276 "HAL_S.y"
                                        { (yyval.iteration_control_) = make_AAiteration_controlTo((yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 7384 "Parser.c"
    break;

  case 495: /* ITERATION_CONTROL: _SYMB_166 ARITH_EXP _SYMB_47 ARITH_EXP  */
#line 1277 "HAL_S.y"
                                           { (yyval.iteration_control_) = make_ABiteration_controlToBy((yyvsp[-2].arith_exp_), (yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 7390 "Parser.c"
    break;

  case 496: /* FOR_KEY: _SYMB_86 ARITH_VAR EQUALS  */
#line 1279 "HAL_S.y"
                                    { (yyval.for_key_) = make_AAforKey((yyvsp[-1].arith_var_), (yyvsp[0].equals_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 7396 "Parser.c"
    break;

  case 497: /* FOR_KEY: _SYMB_86 _SYMB_163 IDENTIFIER _SYMB_24  */
#line 1280 "HAL_S.y"
                                           { (yyval.for_key_) = make_ABforKeyTemporary((yyvsp[-1].identifier_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 7402 "Parser.c"
    break;

  case 498: /* TEMPORARY_STMT: _SYMB_163 DECLARE_BODY _SYMB_17  */
#line 1282 "HAL_S.y"
                                                 { (yyval.temporary_stmt_) = make_AAtemporary_stmt((yyvsp[-1].declare_body_)); (yyval.temporary_stmt_)->line_number = (yyloc).first_line; (yyval.temporary_stmt_)->char_number = (yyloc).first_column;  }
#line 7408 "Parser.c"
    break;

  case 499: /* CONSTANT: NUMBER  */
#line 1284 "HAL_S.y"
                  { (yyval.constant_) = make_AAconstant((yyvsp[0].number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 7414 "Parser.c"
    break;

  case 500: /* CONSTANT: COMPOUND_NUMBER  */
#line 1285 "HAL_S.y"
                    { (yyval.constant_) = make_ABconstant((yyvsp[0].compound_number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 7420 "Parser.c"
    break;

  case 501: /* CONSTANT: BIT_CONST  */
#line 1286 "HAL_S.y"
              { (yyval.constant_) = make_ACconstant((yyvsp[0].bit_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 7426 "Parser.c"
    break;

  case 502: /* CONSTANT: CHAR_CONST  */
#line 1287 "HAL_S.y"
               { (yyval.constant_) = make_ADconstant((yyvsp[0].char_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 7432 "Parser.c"
    break;

  case 503: /* ARRAY_HEAD: _SYMB_40 _SYMB_2  */
#line 1289 "HAL_S.y"
                              { (yyval.array_head_) = make_AAarray_head(); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 7438 "Parser.c"
    break;

  case 504: /* ARRAY_HEAD: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_0  */
#line 1290 "HAL_S.y"
                                           { (yyval.array_head_) = make_ABarray_head((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 7444 "Parser.c"
    break;

  case 505: /* MINOR_ATTR_LIST: MINOR_ATTRIBUTE  */
#line 1292 "HAL_S.y"
                                  { (yyval.minor_attr_list_) = make_AAminor_attr_list((yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 7450 "Parser.c"
    break;

  case 506: /* MINOR_ATTR_LIST: MINOR_ATTR_LIST MINOR_ATTRIBUTE  */
#line 1293 "HAL_S.y"
                                    { (yyval.minor_attr_list_) = make_ABminor_attr_list((yyvsp[-1].minor_attr_list_), (yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 7456 "Parser.c"
    break;

  case 507: /* MINOR_ATTRIBUTE: _SYMB_154  */
#line 1295 "HAL_S.y"
                            { (yyval.minor_attribute_) = make_AAminorAttributeStatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7462 "Parser.c"
    break;

  case 508: /* MINOR_ATTRIBUTE: _SYMB_43  */
#line 1296 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ABminorAttributeAutomatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7468 "Parser.c"
    break;

  case 509: /* MINOR_ATTRIBUTE: _SYMB_65  */
#line 1297 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ACminorAttributeDense(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7474 "Parser.c"
    break;

  case 510: /* MINOR_ATTRIBUTE: _SYMB_31  */
#line 1298 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ADminorAttributeAligned(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7480 "Parser.c"
    break;

  case 511: /* MINOR_ATTRIBUTE: _SYMB_29  */
#line 1299 "HAL_S.y"
             { (yyval.minor_attribute_) = make_AEminorAttributeAccess(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7486 "Parser.c"
    break;

  case 512: /* MINOR_ATTRIBUTE: _SYMB_101 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1300 "HAL_S.y"
                                                  { (yyval.minor_attribute_) = make_AFminorAttributeLock((yyvsp[-1].literal_exp_or_star_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7492 "Parser.c"
    break;

  case 513: /* MINOR_ATTRIBUTE: _SYMB_130  */
#line 1301 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AGminorAttributeRemote(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7498 "Parser.c"
    break;

  case 514: /* MINOR_ATTRIBUTE: _SYMB_135  */
#line 1302 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AHminorAttributeRigid(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7504 "Parser.c"
    break;

  case 515: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_1  */
#line 1303 "HAL_S.y"
                                                 { (yyval.minor_attribute_) = make_AIminorAttributeRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7510 "Parser.c"
    break;

  case 516: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD _SYMB_6 _SYMB_1  */
#line 1304 "HAL_S.y"
                                       { (yyval.minor_attribute_) = make_AJminorAttributeStar((yyvsp[-2].init_or_const_head_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7516 "Parser.c"
    break;

  case 517: /* MINOR_ATTRIBUTE: _SYMB_97  */
#line 1305 "HAL_S.y"
             { (yyval.minor_attribute_) = make_AKminorAttributeLatched(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7522 "Parser.c"
    break;

  case 518: /* MINOR_ATTRIBUTE: _SYMB_110 _SYMB_2 LEVEL _SYMB_1  */
#line 1306 "HAL_S.y"
                                    { (yyval.minor_attribute_) = make_ALminorAttributeNonHal((yyvsp[-1].level_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7528 "Parser.c"
    break;

  case 519: /* INIT_OR_CONST_HEAD: _SYMB_94 _SYMB_2  */
#line 1308 "HAL_S.y"
                                      { (yyval.init_or_const_head_) = make_AAinit_or_const_headInitial(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7534 "Parser.c"
    break;

  case 520: /* INIT_OR_CONST_HEAD: _SYMB_59 _SYMB_2  */
#line 1309 "HAL_S.y"
                     { (yyval.init_or_const_head_) = make_ABinit_or_const_headConstant(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7540 "Parser.c"
    break;

  case 521: /* INIT_OR_CONST_HEAD: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_0  */
#line 1310 "HAL_S.y"
                                                 { (yyval.init_or_const_head_) = make_ACinit_or_const_headRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7546 "Parser.c"
    break;

  case 522: /* REPEATED_CONSTANT: EXPRESSION  */
#line 1312 "HAL_S.y"
                               { (yyval.repeated_constant_) = make_AArepeated_constant((yyvsp[0].expression_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7552 "Parser.c"
    break;

  case 523: /* REPEATED_CONSTANT: REPEAT_HEAD VARIABLE  */
#line 1313 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ABrepeated_constantMark((yyvsp[-1].repeat_head_), (yyvsp[0].variable_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7558 "Parser.c"
    break;

  case 524: /* REPEATED_CONSTANT: REPEAT_HEAD CONSTANT  */
#line 1314 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ACrepeated_constantMark((yyvsp[-1].repeat_head_), (yyvsp[0].constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7564 "Parser.c"
    break;

  case 525: /* REPEATED_CONSTANT: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_1  */
#line 1315 "HAL_S.y"
                                                 { (yyval.repeated_constant_) = make_ADrepeated_constantMark((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7570 "Parser.c"
    break;

  case 526: /* REPEATED_CONSTANT: REPEAT_HEAD  */
#line 1316 "HAL_S.y"
                { (yyval.repeated_constant_) = make_AErepeated_constantMark((yyvsp[0].repeat_head_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7576 "Parser.c"
    break;

  case 527: /* REPEAT_HEAD: ARITH_EXP _SYMB_10  */
#line 1318 "HAL_S.y"
                                 { (yyval.repeat_head_) = make_AArepeat_head((yyvsp[-1].arith_exp_)); (yyval.repeat_head_)->line_number = (yyloc).first_line; (yyval.repeat_head_)->char_number = (yyloc).first_column;  }
#line 7582 "Parser.c"
    break;

  case 528: /* NESTED_REPEAT_HEAD: REPEAT_HEAD _SYMB_2  */
#line 1320 "HAL_S.y"
                                         { (yyval.nested_repeat_head_) = make_AAnested_repeat_head((yyvsp[-1].repeat_head_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 7588 "Parser.c"
    break;

  case 529: /* NESTED_REPEAT_HEAD: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_0  */
#line 1321 "HAL_S.y"
                                                 { (yyval.nested_repeat_head_) = make_ABnested_repeat_head((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 7594 "Parser.c"
    break;

  case 530: /* DCL_LIST_COMMA: DECLARATION_LIST _SYMB_0  */
#line 1323 "HAL_S.y"
                                          { (yyval.dcl_list_comma_) = make_AAdcl_list_comma((yyvsp[-1].declaration_list_)); (yyval.dcl_list_comma_)->line_number = (yyloc).first_line; (yyval.dcl_list_comma_)->char_number = (yyloc).first_column;  }
#line 7600 "Parser.c"
    break;

  case 531: /* LITERAL_EXP_OR_STAR: ARITH_EXP  */
#line 1325 "HAL_S.y"
                                { (yyval.literal_exp_or_star_) = make_AAliteralExp((yyvsp[0].arith_exp_)); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7606 "Parser.c"
    break;

  case 532: /* LITERAL_EXP_OR_STAR: _SYMB_6  */
#line 1326 "HAL_S.y"
            { (yyval.literal_exp_or_star_) = make_ABliteralStar(); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7612 "Parser.c"
    break;

  case 533: /* TYPE_SPEC: STRUCT_SPEC  */
#line 1328 "HAL_S.y"
                        { (yyval.type_spec_) = make_AAtypeSpecStruct((yyvsp[0].struct_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7618 "Parser.c"
    break;

  case 534: /* TYPE_SPEC: BIT_SPEC  */
#line 1329 "HAL_S.y"
             { (yyval.type_spec_) = make_ABtypeSpecBit((yyvsp[0].bit_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7624 "Parser.c"
    break;

  case 535: /* TYPE_SPEC: CHAR_SPEC  */
#line 1330 "HAL_S.y"
              { (yyval.type_spec_) = make_ACtypeSpecChar((yyvsp[0].char_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7630 "Parser.c"
    break;

  case 536: /* TYPE_SPEC: ARITH_SPEC  */
#line 1331 "HAL_S.y"
               { (yyval.type_spec_) = make_ADtypeSpecArith((yyvsp[0].arith_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7636 "Parser.c"
    break;

  case 537: /* TYPE_SPEC: _SYMB_77  */
#line 1332 "HAL_S.y"
             { (yyval.type_spec_) = make_AEtypeSpecEvent(); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7642 "Parser.c"
    break;

  case 538: /* BIT_SPEC: _SYMB_46  */
#line 1334 "HAL_S.y"
                    { (yyval.bit_spec_) = make_AAbitSpecBoolean(); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7648 "Parser.c"
    break;

  case 539: /* BIT_SPEC: _SYMB_45 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1335 "HAL_S.y"
                                                 { (yyval.bit_spec_) = make_ABbitSpecBoolean((yyvsp[-1].literal_exp_or_star_)); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7654 "Parser.c"
    break;

  case 540: /* CHAR_SPEC: _SYMB_54 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1337 "HAL_S.y"
                                                         { (yyval.char_spec_) = make_AAchar_spec((yyvsp[-1].literal_exp_or_star_)); (yyval.char_spec_)->line_number = (yyloc).first_line; (yyval.char_spec_)->char_number = (yyloc).first_column;  }
#line 7660 "Parser.c"
    break;

  case 541: /* STRUCT_SPEC: STRUCT_TEMPLATE STRUCT_SPEC_BODY  */
#line 1339 "HAL_S.y"
                                               { (yyval.struct_spec_) = make_AAstruct_spec((yyvsp[-1].struct_template_), (yyvsp[0].struct_spec_body_)); (yyval.struct_spec_)->line_number = (yyloc).first_line; (yyval.struct_spec_)->char_number = (yyloc).first_column;  }
#line 7666 "Parser.c"
    break;

  case 542: /* STRUCT_SPEC_BODY: _SYMB_5 _SYMB_155  */
#line 1341 "HAL_S.y"
                                     { (yyval.struct_spec_body_) = make_AAstruct_spec_body(); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7672 "Parser.c"
    break;

  case 543: /* STRUCT_SPEC_BODY: STRUCT_SPEC_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1342 "HAL_S.y"
                                                 { (yyval.struct_spec_body_) = make_ABstruct_spec_body((yyvsp[-2].struct_spec_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7678 "Parser.c"
    break;

  case 544: /* STRUCT_TEMPLATE: STRUCTURE_ID  */
#line 1344 "HAL_S.y"
                               { (yyval.struct_template_) = make_FMstruct_template((yyvsp[0].structure_id_)); (yyval.struct_template_)->line_number = (yyloc).first_line; (yyval.struct_template_)->char_number = (yyloc).first_column;  }
#line 7684 "Parser.c"
    break;

  case 545: /* STRUCT_SPEC_HEAD: _SYMB_5 _SYMB_155 _SYMB_2  */
#line 1346 "HAL_S.y"
                                             { (yyval.struct_spec_head_) = make_AAstruct_spec_head(); (yyval.struct_spec_head_)->line_number = (yyloc).first_line; (yyval.struct_spec_head_)->char_number = (yyloc).first_column;  }
#line 7690 "Parser.c"
    break;

  case 546: /* ARITH_SPEC: PREC_SPEC  */
#line 1348 "HAL_S.y"
                       { (yyval.arith_spec_) = make_AAarith_spec((yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7696 "Parser.c"
    break;

  case 547: /* ARITH_SPEC: SQ_DQ_NAME  */
#line 1349 "HAL_S.y"
               { (yyval.arith_spec_) = make_ABarith_spec((yyvsp[0].sq_dq_name_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7702 "Parser.c"
    break;

  case 548: /* ARITH_SPEC: SQ_DQ_NAME PREC_SPEC  */
#line 1350 "HAL_S.y"
                         { (yyval.arith_spec_) = make_ACarith_spec((yyvsp[-1].sq_dq_name_), (yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7708 "Parser.c"
    break;

  case 549: /* COMPILATION: ANY_STATEMENT  */
#line 1352 "HAL_S.y"
                            { (yyval.compilation_) = make_AAcompilation((yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7714 "Parser.c"
    break;

  case 550: /* COMPILATION: COMPILATION ANY_STATEMENT  */
#line 1353 "HAL_S.y"
                              { (yyval.compilation_) = make_ABcompilation((yyvsp[-1].compilation_), (yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7720 "Parser.c"
    break;

  case 551: /* COMPILATION: DECLARE_STATEMENT  */
#line 1354 "HAL_S.y"
                      { (yyval.compilation_) = make_ACcompilation((yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7726 "Parser.c"
    break;

  case 552: /* COMPILATION: COMPILATION DECLARE_STATEMENT  */
#line 1355 "HAL_S.y"
                                  { (yyval.compilation_) = make_ADcompilation((yyvsp[-1].compilation_), (yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7732 "Parser.c"
    break;

  case 553: /* COMPILATION: STRUCTURE_STMT  */
#line 1356 "HAL_S.y"
                   { (yyval.compilation_) = make_AEcompilation((yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7738 "Parser.c"
    break;

  case 554: /* COMPILATION: COMPILATION STRUCTURE_STMT  */
#line 1357 "HAL_S.y"
                               { (yyval.compilation_) = make_AFcompilation((yyvsp[-1].compilation_), (yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7744 "Parser.c"
    break;

  case 555: /* COMPILATION: REPLACE_STMT _SYMB_17  */
#line 1358 "HAL_S.y"
                          { (yyval.compilation_) = make_AGcompilation((yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7750 "Parser.c"
    break;

  case 556: /* COMPILATION: COMPILATION REPLACE_STMT _SYMB_17  */
#line 1359 "HAL_S.y"
                                      { (yyval.compilation_) = make_AHcompilation((yyvsp[-2].compilation_), (yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7756 "Parser.c"
    break;

  case 557: /* COMPILATION: INIT_OR_CONST_HEAD EXPRESSION _SYMB_1  */
#line 1360 "HAL_S.y"
                                          { (yyval.compilation_) = make_AZcompilationInitOrConst((yyvsp[-2].init_or_const_head_), (yyvsp[-1].expression_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7762 "Parser.c"
    break;

  case 558: /* BLOCK_DEFINITION: BLOCK_STMT CLOSING _SYMB_17  */
#line 1362 "HAL_S.y"
                                               { (yyval.block_definition_) = make_AAblock_definition((yyvsp[-2].block_stmt_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7768 "Parser.c"
    break;

  case 559: /* BLOCK_DEFINITION: BLOCK_STMT BLOCK_BODY CLOSING _SYMB_17  */
#line 1363 "HAL_S.y"
                                           { (yyval.block_definition_) = make_ABblock_definition((yyvsp[-3].block_stmt_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7774 "Parser.c"
    break;

  case 560: /* BLOCK_STMT: BLOCK_STMT_TOP _SYMB_17  */
#line 1365 "HAL_S.y"
                                     { (yyval.block_stmt_) = make_AAblock_stmt((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_)->line_number = (yyloc).first_line; (yyval.block_stmt_)->char_number = (yyloc).first_column;  }
#line 7780 "Parser.c"
    break;

  case 561: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_29  */
#line 1367 "HAL_S.y"
                                         { (yyval.block_stmt_top_) = make_AAblockTopAccess((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7786 "Parser.c"
    break;

  case 562: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_135  */
#line 1368 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ABblockTopRigid((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7792 "Parser.c"
    break;

  case 563: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD  */
#line 1369 "HAL_S.y"
                    { (yyval.block_stmt_top_) = make_ACblockTopHead((yyvsp[0].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7798 "Parser.c"
    break;

  case 564: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_79  */
#line 1370 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ADblockTopExclusive((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7804 "Parser.c"
    break;

  case 565: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_128  */
#line 1371 "HAL_S.y"
                              { (yyval.block_stmt_top_) = make_AEblockTopReentrant((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7810 "Parser.c"
    break;

  case 566: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_123  */
#line 1373 "HAL_S.y"
                                           { (yyval.block_stmt_head_) = make_AAblockHeadProgram((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7816 "Parser.c"
    break;

  case 567: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_58  */
#line 1374 "HAL_S.y"
                            { (yyval.block_stmt_head_) = make_ABblockHeadCompool((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7822 "Parser.c"
    break;

  case 568: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_162  */
#line 1375 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ACblockHeadTask((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7828 "Parser.c"
    break;

  case 569: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_174  */
#line 1376 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ADblockHeadUpdate((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7834 "Parser.c"
    break;

  case 570: /* BLOCK_STMT_HEAD: _SYMB_174  */
#line 1377 "HAL_S.y"
              { (yyval.block_stmt_head_) = make_AEblockHeadUpdate(); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7840 "Parser.c"
    break;

  case 571: /* BLOCK_STMT_HEAD: FUNCTION_NAME  */
#line 1378 "HAL_S.y"
                  { (yyval.block_stmt_head_) = make_AFblockHeadFunction((yyvsp[0].function_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7846 "Parser.c"
    break;

  case 572: /* BLOCK_STMT_HEAD: FUNCTION_NAME FUNC_STMT_BODY  */
#line 1379 "HAL_S.y"
                                 { (yyval.block_stmt_head_) = make_AGblockHeadFunction((yyvsp[-1].function_name_), (yyvsp[0].func_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7852 "Parser.c"
    break;

  case 573: /* BLOCK_STMT_HEAD: PROCEDURE_NAME  */
#line 1380 "HAL_S.y"
                   { (yyval.block_stmt_head_) = make_AHblockHeadProcedure((yyvsp[0].procedure_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7858 "Parser.c"
    break;

  case 574: /* BLOCK_STMT_HEAD: PROCEDURE_NAME PROC_STMT_BODY  */
#line 1381 "HAL_S.y"
                                  { (yyval.block_stmt_head_) = make_AIblockHeadProcedure((yyvsp[-1].procedure_name_), (yyvsp[0].proc_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7864 "Parser.c"
    break;

  case 575: /* LABEL_EXTERNAL: LABEL_DEFINITION  */
#line 1383 "HAL_S.y"
                                  { (yyval.label_external_) = make_AAlabel_external((yyvsp[0].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7870 "Parser.c"
    break;

  case 576: /* LABEL_EXTERNAL: LABEL_DEFINITION _SYMB_82  */
#line 1384 "HAL_S.y"
                              { (yyval.label_external_) = make_ABlabel_external((yyvsp[-1].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7876 "Parser.c"
    break;

  case 577: /* CLOSING: _SYMB_56  */
#line 1386 "HAL_S.y"
                   { (yyval.closing_) = make_AAclosing(); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7882 "Parser.c"
    break;

  case 578: /* CLOSING: _SYMB_56 LABEL  */
#line 1387 "HAL_S.y"
                   { (yyval.closing_) = make_ABclosing((yyvsp[0].label_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7888 "Parser.c"
    break;

  case 579: /* CLOSING: _SYMB_56 _SYMB_186  */
#line 1388 "HAL_S.y"
                       { (yyval.closing_) = make_ADclosing((yyvsp[0].string_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7894 "Parser.c"
    break;

  case 580: /* CLOSING: LABEL_DEFINITION CLOSING  */
#line 1389 "HAL_S.y"
                             { (yyval.closing_) = make_ACclosing((yyvsp[-1].label_definition_), (yyvsp[0].closing_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7900 "Parser.c"
    break;

  case 581: /* BLOCK_BODY: DECLARE_GROUP  */
#line 1391 "HAL_S.y"
                           { (yyval.block_body_) = make_ABblock_body((yyvsp[0].declare_group_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7906 "Parser.c"
    break;

  case 582: /* BLOCK_BODY: ANY_STATEMENT  */
#line 1392 "HAL_S.y"
                  { (yyval.block_body_) = make_ADblock_body((yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7912 "Parser.c"
    break;

  case 583: /* BLOCK_BODY: BLOCK_BODY ANY_STATEMENT  */
#line 1393 "HAL_S.y"
                             { (yyval.block_body_) = make_ACblock_body((yyvsp[-1].block_body_), (yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7918 "Parser.c"
    break;

  case 584: /* FUNCTION_NAME: LABEL_EXTERNAL _SYMB_87  */
#line 1395 "HAL_S.y"
                                        { (yyval.function_name_) = make_AAfunction_name((yyvsp[-1].label_external_)); (yyval.function_name_)->line_number = (yyloc).first_line; (yyval.function_name_)->char_number = (yyloc).first_column;  }
#line 7924 "Parser.c"
    break;

  case 585: /* FUNCTION_NAME: _SYMB_186 _SYMB_18 _SYMB_87  */
#line 1396 "HAL_S.y"
                                { (yyval.function_name_) = make_ABfunction_name((yyvsp[-2].string_)); (yyval.function_name_)->line_number = (yyloc).first_line; (yyval.function_name_)->char_number = (yyloc).first_column;  }
#line 7930 "Parser.c"
    break;

  case 586: /* FUNCTION_NAME: _SYMB_186 _SYMB_18 _SYMB_82 _SYMB_87  */
#line 1397 "HAL_S.y"
                                         { (yyval.function_name_) = make_ACfunction_name((yyvsp[-3].string_)); (yyval.function_name_)->line_number = (yyloc).first_line; (yyval.function_name_)->char_number = (yyloc).first_column;  }
#line 7936 "Parser.c"
    break;

  case 587: /* PROCEDURE_NAME: LABEL_EXTERNAL _SYMB_121  */
#line 1399 "HAL_S.y"
                                          { (yyval.procedure_name_) = make_AAprocedure_name((yyvsp[-1].label_external_)); (yyval.procedure_name_)->line_number = (yyloc).first_line; (yyval.procedure_name_)->char_number = (yyloc).first_column;  }
#line 7942 "Parser.c"
    break;

  case 588: /* FUNC_STMT_BODY: PARAMETER_LIST  */
#line 1401 "HAL_S.y"
                                { (yyval.func_stmt_body_) = make_AAfunc_stmt_body((yyvsp[0].parameter_list_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7948 "Parser.c"
    break;

  case 589: /* FUNC_STMT_BODY: TYPE_SPEC  */
#line 1402 "HAL_S.y"
              { (yyval.func_stmt_body_) = make_ABfunc_stmt_body((yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7954 "Parser.c"
    break;

  case 590: /* FUNC_STMT_BODY: PARAMETER_LIST TYPE_SPEC  */
#line 1403 "HAL_S.y"
                             { (yyval.func_stmt_body_) = make_ACfunc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7960 "Parser.c"
    break;

  case 591: /* PROC_STMT_BODY: PARAMETER_LIST  */
#line 1405 "HAL_S.y"
                                { (yyval.proc_stmt_body_) = make_AAproc_stmt_body((yyvsp[0].parameter_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7966 "Parser.c"
    break;

  case 592: /* PROC_STMT_BODY: ASSIGN_LIST  */
#line 1406 "HAL_S.y"
                { (yyval.proc_stmt_body_) = make_ABproc_stmt_body((yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7972 "Parser.c"
    break;

  case 593: /* PROC_STMT_BODY: PARAMETER_LIST ASSIGN_LIST  */
#line 1407 "HAL_S.y"
                               { (yyval.proc_stmt_body_) = make_ACproc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7978 "Parser.c"
    break;

  case 594: /* DECLARE_GROUP: DECLARE_ELEMENT  */
#line 1409 "HAL_S.y"
                                { (yyval.declare_group_) = make_AAdeclare_group((yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7984 "Parser.c"
    break;

  case 595: /* DECLARE_GROUP: DECLARE_GROUP DECLARE_ELEMENT  */
#line 1410 "HAL_S.y"
                                  { (yyval.declare_group_) = make_ABdeclare_group((yyvsp[-1].declare_group_), (yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7990 "Parser.c"
    break;

  case 596: /* DECLARE_ELEMENT: DECLARE_STATEMENT  */
#line 1412 "HAL_S.y"
                                    { (yyval.declare_element_) = make_AAdeclareElementDeclare((yyvsp[0].declare_statement_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7996 "Parser.c"
    break;

  case 597: /* DECLARE_ELEMENT: REPLACE_STMT _SYMB_17  */
#line 1413 "HAL_S.y"
                          { (yyval.declare_element_) = make_ABdeclareElementReplace((yyvsp[-1].replace_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 8002 "Parser.c"
    break;

  case 598: /* DECLARE_ELEMENT: STRUCTURE_STMT  */
#line 1414 "HAL_S.y"
                   { (yyval.declare_element_) = make_ACdeclareElementStructure((yyvsp[0].structure_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 8008 "Parser.c"
    break;

  case 599: /* DECLARE_ELEMENT: _SYMB_73 _SYMB_82 IDENTIFIER _SYMB_166 VARIABLE _SYMB_17  */
#line 1415 "HAL_S.y"
                                                             { (yyval.declare_element_) = make_ADdeclareElementEquate((yyvsp[-3].identifier_), (yyvsp[-1].variable_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 8014 "Parser.c"
    break;

  case 600: /* PARAMETER: _SYMB_196  */
#line 1417 "HAL_S.y"
                      { (yyval.parameter_) = make_AAparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 8020 "Parser.c"
    break;

  case 601: /* PARAMETER: _SYMB_187  */
#line 1418 "HAL_S.y"
              { (yyval.parameter_) = make_ABparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 8026 "Parser.c"
    break;

  case 602: /* PARAMETER: _SYMB_190  */
#line 1419 "HAL_S.y"
              { (yyval.parameter_) = make_ACparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 8032 "Parser.c"
    break;

  case 603: /* PARAMETER: _SYMB_191  */
#line 1420 "HAL_S.y"
              { (yyval.parameter_) = make_ADparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 8038 "Parser.c"
    break;

  case 604: /* PARAMETER: _SYMB_194  */
#line 1421 "HAL_S.y"
              { (yyval.parameter_) = make_AEparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 8044 "Parser.c"
    break;

  case 605: /* PARAMETER: _SYMB_193  */
#line 1422 "HAL_S.y"
              { (yyval.parameter_) = make_AFparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 8050 "Parser.c"
    break;

  case 606: /* PARAMETER_LIST: PARAMETER_HEAD PARAMETER _SYMB_1  */
#line 1424 "HAL_S.y"
                                                  { (yyval.parameter_list_) = make_AAparameter_list((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_list_)->line_number = (yyloc).first_line; (yyval.parameter_list_)->char_number = (yyloc).first_column;  }
#line 8056 "Parser.c"
    break;

  case 607: /* PARAMETER_HEAD: _SYMB_2  */
#line 1426 "HAL_S.y"
                         { (yyval.parameter_head_) = make_AAparameter_head(); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 8062 "Parser.c"
    break;

  case 608: /* PARAMETER_HEAD: PARAMETER_HEAD PARAMETER _SYMB_0  */
#line 1427 "HAL_S.y"
                                     { (yyval.parameter_head_) = make_ABparameter_head((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 8068 "Parser.c"
    break;

  case 609: /* DECLARE_STATEMENT: _SYMB_64 DECLARE_BODY _SYMB_17  */
#line 1429 "HAL_S.y"
                                                   { (yyval.declare_statement_) = make_AAdeclare_statement((yyvsp[-1].declare_body_)); (yyval.declare_statement_)->line_number = (yyloc).first_line; (yyval.declare_statement_)->char_number = (yyloc).first_column;  }
#line 8074 "Parser.c"
    break;

  case 610: /* ASSIGN_LIST: ASSIGN PARAMETER_LIST  */
#line 1431 "HAL_S.y"
                                    { (yyval.assign_list_) = make_AAassign_list((yyvsp[-1].assign_), (yyvsp[0].parameter_list_)); (yyval.assign_list_)->line_number = (yyloc).first_line; (yyval.assign_list_)->char_number = (yyloc).first_column;  }
#line 8080 "Parser.c"
    break;

  case 611: /* TEXT: _SYMB_198  */
#line 1433 "HAL_S.y"
                 { (yyval.text_) = make_FQtext((yyvsp[0].string_)); (yyval.text_)->line_number = (yyloc).first_line; (yyval.text_)->char_number = (yyloc).first_column;  }
#line 8086 "Parser.c"
    break;

  case 612: /* REPLACE_STMT: _SYMB_132 REPLACE_HEAD _SYMB_47 TEXT  */
#line 1435 "HAL_S.y"
                                                    { (yyval.replace_stmt_) = make_AAreplace_stmt((yyvsp[-2].replace_head_), (yyvsp[0].text_)); (yyval.replace_stmt_)->line_number = (yyloc).first_line; (yyval.replace_stmt_)->char_number = (yyloc).first_column;  }
#line 8092 "Parser.c"
    break;

  case 613: /* REPLACE_HEAD: IDENTIFIER  */
#line 1437 "HAL_S.y"
                          { (yyval.replace_head_) = make_AAreplace_head((yyvsp[0].identifier_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 8098 "Parser.c"
    break;

  case 614: /* REPLACE_HEAD: IDENTIFIER _SYMB_2 ARG_LIST _SYMB_1  */
#line 1438 "HAL_S.y"
                                        { (yyval.replace_head_) = make_ABreplace_head((yyvsp[-3].identifier_), (yyvsp[-1].arg_list_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 8104 "Parser.c"
    break;

  case 615: /* ARG_LIST: IDENTIFIER  */
#line 1440 "HAL_S.y"
                      { (yyval.arg_list_) = make_AAarg_list((yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 8110 "Parser.c"
    break;

  case 616: /* ARG_LIST: ARG_LIST _SYMB_0 IDENTIFIER  */
#line 1441 "HAL_S.y"
                                { (yyval.arg_list_) = make_ABarg_list((yyvsp[-2].arg_list_), (yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 8116 "Parser.c"
    break;

  case 617: /* STRUCTURE_STMT: _SYMB_155 STRUCT_STMT_HEAD STRUCT_STMT_TAIL  */
#line 1443 "HAL_S.y"
                                                             { (yyval.structure_stmt_) = make_AAstructure_stmt((yyvsp[-1].struct_stmt_head_), (yyvsp[0].struct_stmt_tail_)); (yyval.structure_stmt_)->line_number = (yyloc).first_line; (yyval.structure_stmt_)->char_number = (yyloc).first_column;  }
#line 8122 "Parser.c"
    break;

  case 618: /* STRUCT_STMT_HEAD: STRUCTURE_ID _SYMB_18 LEVEL  */
#line 1445 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_AAstruct_stmt_head((yyvsp[-2].structure_id_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 8128 "Parser.c"
    break;

  case 619: /* STRUCT_STMT_HEAD: STRUCTURE_ID MINOR_ATTR_LIST _SYMB_18 LEVEL  */
#line 1446 "HAL_S.y"
                                                { (yyval.struct_stmt_head_) = make_ABstruct_stmt_head((yyvsp[-3].structure_id_), (yyvsp[-2].minor_attr_list_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 8134 "Parser.c"
    break;

  case 620: /* STRUCT_STMT_HEAD: STRUCT_STMT_HEAD DECLARATION _SYMB_0 LEVEL  */
#line 1447 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_ACstruct_stmt_head((yyvsp[-3].struct_stmt_head_), (yyvsp[-2].declaration_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 8140 "Parser.c"
    break;

  case 621: /* STRUCT_STMT_TAIL: DECLARATION _SYMB_17  */
#line 1449 "HAL_S.y"
                                        { (yyval.struct_stmt_tail_) = make_AAstruct_stmt_tail((yyvsp[-1].declaration_)); (yyval.struct_stmt_tail_)->line_number = (yyloc).first_line; (yyval.struct_stmt_tail_)->char_number = (yyloc).first_column;  }
#line 8146 "Parser.c"
    break;

  case 622: /* INLINE_DEFINITION: ARITH_INLINE  */
#line 1451 "HAL_S.y"
                                 { (yyval.inline_definition_) = make_AAinline_definition((yyvsp[0].arith_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 8152 "Parser.c"
    break;

  case 623: /* INLINE_DEFINITION: BIT_INLINE  */
#line 1452 "HAL_S.y"
               { (yyval.inline_definition_) = make_ABinline_definition((yyvsp[0].bit_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 8158 "Parser.c"
    break;

  case 624: /* INLINE_DEFINITION: CHAR_INLINE  */
#line 1453 "HAL_S.y"
                { (yyval.inline_definition_) = make_ACinline_definition((yyvsp[0].char_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 8164 "Parser.c"
    break;

  case 625: /* INLINE_DEFINITION: STRUCTURE_EXP  */
#line 1454 "HAL_S.y"
                  { (yyval.inline_definition_) = make_ADinline_definition((yyvsp[0].structure_exp_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 8170 "Parser.c"
    break;

  case 626: /* ARITH_INLINE: ARITH_INLINE_DEF CLOSING _SYMB_17  */
#line 1456 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_ACprimary((yyvsp[-2].arith_inline_def_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 8176 "Parser.c"
    break;

  case 627: /* ARITH_INLINE: ARITH_INLINE_DEF BLOCK_BODY CLOSING _SYMB_17  */
#line 1457 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_AZprimary((yyvsp[-3].arith_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 8182 "Parser.c"
    break;

  case 628: /* ARITH_INLINE_DEF: _SYMB_87 ARITH_SPEC _SYMB_17  */
#line 1459 "HAL_S.y"
                                                { (yyval.arith_inline_def_) = make_AAarith_inline_def((yyvsp[-1].arith_spec_)); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 8188 "Parser.c"
    break;

  case 629: /* ARITH_INLINE_DEF: _SYMB_87 _SYMB_17  */
#line 1460 "HAL_S.y"
                      { (yyval.arith_inline_def_) = make_ABarith_inline_def(); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 8194 "Parser.c"
    break;

  case 630: /* BIT_INLINE: BIT_INLINE_DEF CLOSING _SYMB_17  */
#line 1462 "HAL_S.y"
                                             { (yyval.bit_inline_) = make_AGbit_prim((yyvsp[-2].bit_inline_def_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 8200 "Parser.c"
    break;

  case 631: /* BIT_INLINE: BIT_INLINE_DEF BLOCK_BODY CLOSING _SYMB_17  */
#line 1463 "HAL_S.y"
                                               { (yyval.bit_inline_) = make_AZbit_prim((yyvsp[-3].bit_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 8206 "Parser.c"
    break;

  case 632: /* BIT_INLINE_DEF: _SYMB_87 BIT_SPEC _SYMB_17  */
#line 1465 "HAL_S.y"
                                            { (yyval.bit_inline_def_) = make_AAbit_inline_def((yyvsp[-1].bit_spec_)); (yyval.bit_inline_def_)->line_number = (yyloc).first_line; (yyval.bit_inline_def_)->char_number = (yyloc).first_column;  }
#line 8212 "Parser.c"
    break;

  case 633: /* CHAR_INLINE: CHAR_INLINE_DEF CLOSING _SYMB_17  */
#line 1467 "HAL_S.y"
                                               { (yyval.char_inline_) = make_ADchar_prim((yyvsp[-2].char_inline_def_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 8218 "Parser.c"
    break;

  case 634: /* CHAR_INLINE: CHAR_INLINE_DEF BLOCK_BODY CLOSING _SYMB_17  */
#line 1468 "HAL_S.y"
                                                { (yyval.char_inline_) = make_AZchar_prim((yyvsp[-3].char_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 8224 "Parser.c"
    break;

  case 635: /* CHAR_INLINE_DEF: _SYMB_87 CHAR_SPEC _SYMB_17  */
#line 1470 "HAL_S.y"
                                              { (yyval.char_inline_def_) = make_AAchar_inline_def((yyvsp[-1].char_spec_)); (yyval.char_inline_def_)->line_number = (yyloc).first_line; (yyval.char_inline_def_)->char_number = (yyloc).first_column;  }
#line 8230 "Parser.c"
    break;

  case 636: /* STRUC_INLINE_DEF: _SYMB_87 STRUCT_SPEC _SYMB_17  */
#line 1472 "HAL_S.y"
                                                 { (yyval.struc_inline_def_) = make_AAstruc_inline_def((yyvsp[-1].struct_spec_)); (yyval.struc_inline_def_)->line_number = (yyloc).first_line; (yyval.struc_inline_def_)->char_number = (yyloc).first_column;  }
#line 8236 "Parser.c"
    break;


#line 8240 "Parser.c"

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

#line 1475 "HAL_S.y"

void yyerror(const char *str)
{
  extern char *HAL_Stext;
  fprintf(stderr,"error: %d,%d: %s at %s\n",
  HAL_Slloc.first_line, HAL_Slloc.first_column, str, HAL_Stext);
}

