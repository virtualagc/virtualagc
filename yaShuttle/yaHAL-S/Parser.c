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
    _SYMB_196 = 455                /* _SYMB_196  */
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
  YYSYMBOL_YYACCEPT = 201,                 /* $accept  */
  YYSYMBOL_DECLARE_BODY = 202,             /* DECLARE_BODY  */
  YYSYMBOL_ATTRIBUTES = 203,               /* ATTRIBUTES  */
  YYSYMBOL_DECLARATION = 204,              /* DECLARATION  */
  YYSYMBOL_ARRAY_SPEC = 205,               /* ARRAY_SPEC  */
  YYSYMBOL_TYPE_AND_MINOR_ATTR = 206,      /* TYPE_AND_MINOR_ATTR  */
  YYSYMBOL_IDENTIFIER = 207,               /* IDENTIFIER  */
  YYSYMBOL_SQ_DQ_NAME = 208,               /* SQ_DQ_NAME  */
  YYSYMBOL_DOUBLY_QUAL_NAME_HEAD = 209,    /* DOUBLY_QUAL_NAME_HEAD  */
  YYSYMBOL_ARITH_CONV = 210,               /* ARITH_CONV  */
  YYSYMBOL_DECLARATION_LIST = 211,         /* DECLARATION_LIST  */
  YYSYMBOL_NAME_ID = 212,                  /* NAME_ID  */
  YYSYMBOL_ARITH_EXP = 213,                /* ARITH_EXP  */
  YYSYMBOL_TERM = 214,                     /* TERM  */
  YYSYMBOL_PLUS = 215,                     /* PLUS  */
  YYSYMBOL_MINUS = 216,                    /* MINUS  */
  YYSYMBOL_PRODUCT = 217,                  /* PRODUCT  */
  YYSYMBOL_FACTOR = 218,                   /* FACTOR  */
  YYSYMBOL_EXPONENTIATION = 219,           /* EXPONENTIATION  */
  YYSYMBOL_PRIMARY = 220,                  /* PRIMARY  */
  YYSYMBOL_ARITH_VAR = 221,                /* ARITH_VAR  */
  YYSYMBOL_PRE_PRIMARY = 222,              /* PRE_PRIMARY  */
  YYSYMBOL_NUMBER = 223,                   /* NUMBER  */
  YYSYMBOL_LEVEL = 224,                    /* LEVEL  */
  YYSYMBOL_COMPOUND_NUMBER = 225,          /* COMPOUND_NUMBER  */
  YYSYMBOL_SIMPLE_NUMBER = 226,            /* SIMPLE_NUMBER  */
  YYSYMBOL_MODIFIED_ARITH_FUNC = 227,      /* MODIFIED_ARITH_FUNC  */
  YYSYMBOL_ARITH_FUNC_HEAD = 228,          /* ARITH_FUNC_HEAD  */
  YYSYMBOL_CALL_LIST = 229,                /* CALL_LIST  */
  YYSYMBOL_LIST_EXP = 230,                 /* LIST_EXP  */
  YYSYMBOL_EXPRESSION = 231,               /* EXPRESSION  */
  YYSYMBOL_ARITH_ID = 232,                 /* ARITH_ID  */
  YYSYMBOL_NO_ARG_ARITH_FUNC = 233,        /* NO_ARG_ARITH_FUNC  */
  YYSYMBOL_ARITH_FUNC = 234,               /* ARITH_FUNC  */
  YYSYMBOL_SUBSCRIPT = 235,                /* SUBSCRIPT  */
  YYSYMBOL_QUALIFIER = 236,                /* QUALIFIER  */
  YYSYMBOL_SCALE_HEAD = 237,               /* SCALE_HEAD  */
  YYSYMBOL_PREC_SPEC = 238,                /* PREC_SPEC  */
  YYSYMBOL_SUB_START = 239,                /* SUB_START  */
  YYSYMBOL_SUB_HEAD = 240,                 /* SUB_HEAD  */
  YYSYMBOL_SUB = 241,                      /* SUB  */
  YYSYMBOL_SUB_RUN_HEAD = 242,             /* SUB_RUN_HEAD  */
  YYSYMBOL_SUB_EXP = 243,                  /* SUB_EXP  */
  YYSYMBOL_POUND_EXPRESSION = 244,         /* POUND_EXPRESSION  */
  YYSYMBOL_BIT_EXP = 245,                  /* BIT_EXP  */
  YYSYMBOL_BIT_FACTOR = 246,               /* BIT_FACTOR  */
  YYSYMBOL_BIT_CAT = 247,                  /* BIT_CAT  */
  YYSYMBOL_OR = 248,                       /* OR  */
  YYSYMBOL_CHAR_VERTICAL_BAR = 249,        /* CHAR_VERTICAL_BAR  */
  YYSYMBOL_AND = 250,                      /* AND  */
  YYSYMBOL_BIT_PRIM = 251,                 /* BIT_PRIM  */
  YYSYMBOL_CAT = 252,                      /* CAT  */
  YYSYMBOL_NOT = 253,                      /* NOT  */
  YYSYMBOL_BIT_VAR = 254,                  /* BIT_VAR  */
  YYSYMBOL_LABEL_VAR = 255,                /* LABEL_VAR  */
  YYSYMBOL_EVENT_VAR = 256,                /* EVENT_VAR  */
  YYSYMBOL_BIT_CONST_HEAD = 257,           /* BIT_CONST_HEAD  */
  YYSYMBOL_BIT_CONST = 258,                /* BIT_CONST  */
  YYSYMBOL_RADIX = 259,                    /* RADIX  */
  YYSYMBOL_CHAR_STRING = 260,              /* CHAR_STRING  */
  YYSYMBOL_SUBBIT_HEAD = 261,              /* SUBBIT_HEAD  */
  YYSYMBOL_SUBBIT_KEY = 262,               /* SUBBIT_KEY  */
  YYSYMBOL_BIT_FUNC_HEAD = 263,            /* BIT_FUNC_HEAD  */
  YYSYMBOL_BIT_ID = 264,                   /* BIT_ID  */
  YYSYMBOL_LABEL = 265,                    /* LABEL  */
  YYSYMBOL_BIT_FUNC = 266,                 /* BIT_FUNC  */
  YYSYMBOL_EVENT = 267,                    /* EVENT  */
  YYSYMBOL_SUB_OR_QUALIFIER = 268,         /* SUB_OR_QUALIFIER  */
  YYSYMBOL_BIT_QUALIFIER = 269,            /* BIT_QUALIFIER  */
  YYSYMBOL_CHAR_EXP = 270,                 /* CHAR_EXP  */
  YYSYMBOL_CHAR_PRIM = 271,                /* CHAR_PRIM  */
  YYSYMBOL_CHAR_FUNC_HEAD = 272,           /* CHAR_FUNC_HEAD  */
  YYSYMBOL_CHAR_VAR = 273,                 /* CHAR_VAR  */
  YYSYMBOL_CHAR_CONST = 274,               /* CHAR_CONST  */
  YYSYMBOL_CHAR_FUNC = 275,                /* CHAR_FUNC  */
  YYSYMBOL_CHAR_ID = 276,                  /* CHAR_ID  */
  YYSYMBOL_NAME_EXP = 277,                 /* NAME_EXP  */
  YYSYMBOL_NAME_KEY = 278,                 /* NAME_KEY  */
  YYSYMBOL_NAME_VAR = 279,                 /* NAME_VAR  */
  YYSYMBOL_VARIABLE = 280,                 /* VARIABLE  */
  YYSYMBOL_STRUCTURE_EXP = 281,            /* STRUCTURE_EXP  */
  YYSYMBOL_STRUCT_FUNC_HEAD = 282,         /* STRUCT_FUNC_HEAD  */
  YYSYMBOL_STRUCTURE_VAR = 283,            /* STRUCTURE_VAR  */
  YYSYMBOL_STRUCT_FUNC = 284,              /* STRUCT_FUNC  */
  YYSYMBOL_QUAL_STRUCT = 285,              /* QUAL_STRUCT  */
  YYSYMBOL_STRUCTURE_ID = 286,             /* STRUCTURE_ID  */
  YYSYMBOL_ASSIGNMENT = 287,               /* ASSIGNMENT  */
  YYSYMBOL_EQUALS = 288,                   /* EQUALS  */
  YYSYMBOL_IF_STATEMENT = 289,             /* IF_STATEMENT  */
  YYSYMBOL_IF_CLAUSE = 290,                /* IF_CLAUSE  */
  YYSYMBOL_TRUE_PART = 291,                /* TRUE_PART  */
  YYSYMBOL_IF = 292,                       /* IF  */
  YYSYMBOL_THEN = 293,                     /* THEN  */
  YYSYMBOL_RELATIONAL_EXP = 294,           /* RELATIONAL_EXP  */
  YYSYMBOL_RELATIONAL_FACTOR = 295,        /* RELATIONAL_FACTOR  */
  YYSYMBOL_REL_PRIM = 296,                 /* REL_PRIM  */
  YYSYMBOL_COMPARISON = 297,               /* COMPARISON  */
  YYSYMBOL_RELATIONAL_OP = 298,            /* RELATIONAL_OP  */
  YYSYMBOL_STATEMENT = 299,                /* STATEMENT  */
  YYSYMBOL_BASIC_STATEMENT = 300,          /* BASIC_STATEMENT  */
  YYSYMBOL_OTHER_STATEMENT = 301,          /* OTHER_STATEMENT  */
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
#define YYFINAL  467
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   7593

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  201
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  192
/* YYNRULES -- Number of rules.  */
#define YYNRULES  597
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  995

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   455


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
     195,   196,   197,   198,   199,   200
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,   646,   646,   647,   649,   650,   651,   653,   654,   655,
     656,   657,   658,   659,   660,   662,   663,   664,   665,   666,
     668,   669,   670,   672,   674,   675,   677,   678,   680,   681,
     682,   683,   685,   686,   688,   689,   690,   691,   692,   693,
     694,   695,   697,   698,   699,   700,   701,   703,   704,   706,
     708,   710,   711,   712,   713,   715,   716,   718,   720,   721,
     722,   723,   725,   726,   727,   728,   729,   730,   731,   732,
     734,   735,   736,   737,   738,   740,   741,   743,   745,   747,
     749,   750,   751,   752,   754,   755,   757,   758,   760,   761,
     762,   764,   765,   766,   767,   768,   770,   771,   773,   774,
     775,   776,   777,   778,   779,   780,   782,   783,   784,   785,
     786,   787,   788,   789,   790,   791,   792,   793,   794,   795,
     796,   797,   798,   799,   800,   801,   802,   803,   804,   805,
     806,   807,   808,   809,   810,   811,   812,   813,   814,   815,
     816,   817,   818,   819,   820,   821,   822,   823,   824,   825,
     826,   827,   828,   830,   831,   832,   833,   835,   836,   837,
     838,   840,   841,   843,   844,   846,   847,   848,   849,   850,
     852,   853,   855,   856,   857,   858,   860,   862,   863,   865,
     866,   867,   869,   870,   872,   873,   875,   876,   877,   878,
     880,   881,   883,   885,   886,   888,   889,   890,   891,   892,
     893,   894,   895,   896,   897,   898,   900,   901,   903,   904,
     906,   907,   908,   909,   911,   912,   913,   914,   916,   917,
     918,   919,   921,   922,   924,   925,   926,   927,   928,   930,
     931,   932,   933,   935,   937,   938,   940,   942,   943,   944,
     946,   948,   949,   950,   951,   953,   954,   956,   958,   959,
     961,   963,   964,   965,   966,   967,   969,   970,   971,   972,
     974,   975,   977,   978,   979,   980,   982,   983,   985,   986,
     987,   988,   989,   991,   993,   994,   995,   997,   999,  1000,
    1001,  1003,  1004,  1005,  1006,  1007,  1008,  1009,  1011,  1012,
    1013,  1014,  1016,  1018,  1020,  1022,  1023,  1025,  1027,  1028,
    1029,  1030,  1032,  1034,  1035,  1037,  1038,  1040,  1042,  1044,
    1046,  1047,  1049,  1050,  1052,  1053,  1054,  1056,  1057,  1058,
    1059,  1060,  1062,  1063,  1064,  1065,  1066,  1067,  1069,  1070,
    1071,  1073,  1074,  1075,  1076,  1077,  1078,  1079,  1080,  1081,
    1082,  1083,  1084,  1085,  1086,  1087,  1088,  1089,  1090,  1091,
    1092,  1093,  1094,  1095,  1096,  1097,  1098,  1099,  1100,  1101,
    1102,  1103,  1104,  1105,  1106,  1107,  1108,  1109,  1110,  1111,
    1112,  1113,  1115,  1116,  1117,  1119,  1120,  1122,  1123,  1125,
    1126,  1127,  1128,  1130,  1132,  1134,  1136,  1137,  1138,  1139,
    1141,  1142,  1143,  1144,  1145,  1146,  1147,  1148,  1150,  1151,
    1152,  1154,  1155,  1157,  1159,  1160,  1162,  1163,  1165,  1166,
    1168,  1169,  1170,  1172,  1174,  1176,  1177,  1178,  1179,  1180,
    1182,  1184,  1185,  1187,  1188,  1190,  1191,  1192,  1193,  1195,
    1196,  1197,  1199,  1200,  1201,  1203,  1204,  1205,  1207,  1209,
    1210,  1212,  1213,  1214,  1216,  1218,  1219,  1221,  1222,  1224,
    1226,  1227,  1229,  1230,  1232,  1233,  1235,  1236,  1238,  1239,
    1241,  1242,  1244,  1246,  1247,  1248,  1249,  1251,  1252,  1254,
    1255,  1257,  1258,  1259,  1260,  1261,  1262,  1263,  1264,  1265,
    1266,  1267,  1268,  1270,  1271,  1272,  1274,  1275,  1276,  1277,
    1278,  1280,  1282,  1283,  1285,  1287,  1288,  1290,  1291,  1292,
    1293,  1294,  1296,  1297,  1299,  1301,  1303,  1304,  1306,  1308,
    1310,  1311,  1312,  1314,  1315,  1316,  1317,  1318,  1319,  1320,
    1321,  1322,  1324,  1325,  1327,  1329,  1330,  1331,  1332,  1333,
    1335,  1336,  1337,  1338,  1339,  1340,  1341,  1342,  1343,  1345,
    1346,  1348,  1349,  1350,  1352,  1353,  1354,  1356,  1358,  1360,
    1361,  1362,  1364,  1365,  1366,  1368,  1369,  1371,  1372,  1373,
    1374,  1376,  1377,  1378,  1379,  1380,  1381,  1383,  1385,  1386,
    1388,  1390,  1392,  1394,  1396,  1397,  1399,  1400,  1402,  1404,
    1405,  1406,  1408,  1410,  1411,  1412,  1413,  1415,  1416,  1418,
    1419,  1421,  1422,  1424,  1426,  1427,  1429,  1431
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
  "$accept", "DECLARE_BODY", "ATTRIBUTES", "DECLARATION", "ARRAY_SPEC",
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

#define YYPACT_NINF (-810)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-413)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
    5651,     7,   -56,  -810,    39,   641,  -810,   233,  7215,   161,
     168,   250,  1242,   145,  -810,   343,  -810,   188,   304,   387,
     409,   302,    39,   335,  2581,   641,   356,   335,   335,   -56,
    -810,  -810,   353,  -810,   493,  -810,  -810,  -810,  -810,  -810,
     498,  -810,  -810,  -810,  -810,  -810,  -810,   488,  -810,  -810,
     874,   329,   488,   490,   488,  -810,   488,   510,   237,  -810,
     528,   269,  -810,   402,  -810,   527,  -810,  6617,  6617,  3166,
    -810,  -810,  -810,  -810,  6617,   351,  6339,   344,  5929,  1465,
    2191,   127,   295,   522,   556,  4117,   129,   360,   126,   535,
     131,  5501,  6617,  3361,  2001,  -810,  5797,    70,    17,   114,
     798,   122,  -810,   543,  -810,  -810,  -810,  5797,  -810,  5797,
    -810,  5797,  5797,   550,   467,  -810,  -810,  -810,   488,   573,
    -810,  -810,  -810,   580,  -810,   590,  -810,   615,  -810,  -810,
    -810,  -810,  -810,  -810,   618,   630,   644,  -810,  -810,  -810,
    -810,  -810,  -810,  -810,  -810,   646,  -810,  -810,   592,  -810,
     523,  1241,   638,   657,  -810,  7403,  -810,   557,    72,  4459,
    -810,   667,  7366,  -810,  -810,  -810,  -810,  4459,  1912,  -810,
    2776,   729,  1912,  -810,  -810,  -810,   673,  -810,  -810,  4801,
      59,  -810,  -810,  3166,   674,   109,  4801,  -810,   684,   159,
    -810,   709,   712,   716,   718,   626,  -810,   364,    90,   159,
     159,  -810,   720,   749,   710,  -810,   753,  3556,  -810,  -810,
     655,   281,  -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,
    -810,  -810,  -810,  -810,   194,  -810,   770,   194,  -810,  -810,
    -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,
     -56,  -810,  -810,   780,  -810,  -810,  -810,  -810,   794,  -810,
    -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,
    -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,   797,  -810,
    -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,
    -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,   800,   820,
     833,  -810,  -810,  -810,  -810,   488,   220,  -810,  5133,  5133,
     814,  4967,   839,  -810,   841,  -810,  -810,  -810,  -810,  -810,
     856,   845,   488,  -810,    43,   395,    86,  -810,  5334,  -810,
    -810,  -810,   676,  -810,   863,  -810,  3361,   868,  -810,    86,
    -810,   873,  -810,  -810,  -810,  -810,   885,  -810,  -810,   144,
    -810,   434,  -810,  -810,  5518,   729,   597,   159,   297,  -810,
    -810,  4288,   477,   890,  -810,   264,  -810,   891,  -810,  -810,
    -810,  -810,  5841,   874,  -810,  2971,  3361,   874,   687,  -810,
    3361,  -810,   353,  -810,   836,  7027,  -810,  3166,  1064,    65,
    1085,  5383,  1085,   531,   531,    65,   395,  -810,  -810,  -810,
    -810,   296,  -810,  -810,   353,  -810,  -810,  3361,  -810,  -810,
     917,   626,  7215,  -810,  6061,   915,  -810,  -810,   935,   937,
     940,   947,   958,  -810,  -810,  -810,  -810,   438,  -810,  -810,
    -810,  1586,  -810,  2386,  -810,  3361,  4801,  4801,  1846,  4801,
     833,   521,   966,  -810,  -810,   460,  4801,  4801,  5299,   976,
     835,  -810,  -810,   964,   508,    71,  -810,  3751,  -810,  -810,
    -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,   572,
    -810,  -810,   579,   991,   994,  5243,  3361,  -810,  -810,  -810,
     981,  -810,   626,   923,  -810,  6207,   987,  6485,    68,  -810,
    -810,   992,  -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,
    -810,  -810,  -810,  -810,  -810,  1166,   713,  1005,  -810,   971,
    -810,  -810,   993,  6485,   997,  6485,  1001,  6485,  1002,  6485,
     488,   -56,   488,  -810,   641,  -810,  4459,  4459,  4459,  4459,
     821,  -810,  1912,  1912,  1912,  -810,   729,  -810,  -810,  -810,
    -810,   633,  1019,  -810,  -810,   675,  -810,  1022,  -810,   708,
    -810,  -810,  1912,   870,  -810,  4459,   585,    39,   522,  1018,
      43,    43,  -810,  -810,  1010,    73,  1028,  -810,  -810,  -810,
    -810,  -810,  -810,  1011,  -810,  1015,  -810,  -810,    30,  1032,
    1034,  -810,    39,   843,   335,   464,    98,   247,  1030,  1029,
    1031,  1026,   504,  1037,  -810,  -810,  -810,   159,  -810,  3361,
    -810,  -810,  -810,  5133,  5133,  3946,  -810,  -810,  5133,  5133,
    5133,  -810,  -810,  5133,  1041,  -810,  3361,  -810,  -810,  -810,
    -810,  5299,  -810,  -810,  -810,  5299,  5299,  5299,   281,   281,
    -810,  1045,  -810,   159,  1043,  3361,  3946,  3361,  7051,  1731,
    -810,  1039,   821,  6030,   482,  -810,  4801,   883,  1052,  1042,
    -810,  -810,  -810,  -810,   178,  -810,  4630,   893,   633,  -810,
    -810,  -810,  -810,  -810,  -810,  1070,   237,  -810,  -810,  1056,
     694,   742,  -810,  -810,   144,  -810,   488,   488,   488,   488,
    -810,  -810,  -810,  1145,  1075,   111,  -810,  -810,  -810,  -810,
    -810,  -810,  4801,  -810,  -810,  5299,  3166,  3946,   595,   -19,
    3166,  -810,  3166,  1062,   766,   874,  -810,  1065,  6749,  -810,
    -810,  4801,  4801,  4801,  4801,  4801,  -810,  -810,  1066,   551,
     534,   605,  1069,    97,   640,  -810,  1627,   641,  -810,   633,
     633,    43,  4801,  -810,  -810,  -810,  4801,  4801,  3751,   633,
      43,  1084,  -810,  1076,   906,  -810,  -810,  -810,  -810,  -810,
     768,  -810,  -810,    39,  6895,  -810,  -810,  -810,  1080,  -810,
    -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,   807,  -810,
    -810,  -810,  1087,  -810,  1090,  -810,  1094,  -810,  1104,  -810,
    -810,   488,  1121,  1122,  1125,  1127,  1129,  1912,  1912,   667,
    -810,  -810,  -810,  -810,  -810,  1126,  1133,  1067,  1113,  -810,
     559,  -810,  4801,  -810,  4801,  -810,  -810,  -810,  -810,  -810,
    -810,  -810,   815,  -810,  -810,  -810,  -810,  -810,   488,   281,
     488,  1136,  1138,   831,  -810,  -810,  3946,  -810,   633,  -810,
    1135,  -810,  -810,  -810,  -810,  1130,   882,   395,    86,  -810,
    5334,   929,  1139,  -810,   933,   633,  -810,   944,  1146,  1150,
     488,  -810,  -810,   821,   821,  -810,   647,  4801,  -810,   604,
    4801,  4630,   633,  -810,  -810,  5133,  5133,  -810,  3361,  -810,
    3361,  3361,  -810,  -810,  -810,  -810,  -810,  -810,   633,    86,
     177,   220,    86,  -810,  -810,  -810,   445,  1085,   395,  -810,
    -810,   242,  -810,   264,   953,  -810,   884,   922,   924,   946,
     957,  -810,  -810,  -810,  -810,  -810,  -810,  -810,   963,   633,
     633,  5318,  -810,  -810,  -810,  -810,   995,  -810,  -810,  -810,
    -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,
    -810,  -810,  -810,  -810,   279,   633,    39,  -810,  -810,  -810,
    1137,   676,  -810,  1388,   604,  -810,  -810,  -810,  -810,  -810,
    -810,  -810,  -810,  -810,  -810,  -810,   691,  -810,   969,  1157,
     982,  -810,  -810,  -810,  -810,  -810,  -810,  -810,  1162,   874,
    1154,  -810,  -810,  -810,  -810,  -810,  -810,   874,  4801,  -810,
     143,  -810,   975,  -810,  1151,  -810,  -810,  -810,   874,  -810,
     264,  -810,  1156,   633,  1173,  1151,  1158,  4801,   999,  -810,
    -810,   984,  1159,  -810,  -810
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int16 yydefact[] =
{
       0,     0,     0,   338,     0,     0,   422,     0,     0,     0,
       0,     0,     0,     0,   308,     0,   277,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     236,   421,   534,   420,     0,   240,   242,   243,   273,   297,
     244,   241,   247,    97,    23,    96,   281,    62,   282,   286,
       0,     0,   210,     0,   218,   284,   262,     0,     0,   586,
       0,   288,   292,     0,   295,     0,   372,     0,     0,     0,
     375,   328,   329,   513,     0,     0,   539,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   429,     0,     0,
       0,     0,     0,     0,     0,   376,     0,     0,   527,     0,
     535,   537,   515,     0,   517,   330,   583,     0,   584,     0,
     585,     0,     0,     0,     0,   444,   244,   384,   214,     0,
     484,   475,   474,     0,   472,     0,   502,     0,   473,   164,
     501,    16,    28,   481,     0,    31,     0,    17,    18,   477,
     478,    29,   163,   471,    19,    30,    38,    39,    40,    41,
       0,    13,     0,     0,    32,     5,     6,    34,   511,     0,
      25,     2,     7,   510,    36,    37,   508,     0,    22,   469,
       0,     0,    20,   498,   499,   497,     0,   500,   390,     0,
       0,   451,   450,     0,     0,     0,     0,   333,     0,     0,
     590,     0,     0,     0,     0,     0,   483,     0,   378,     0,
       0,   335,     0,   574,     0,   442,     0,     0,    49,    50,
       0,     0,   343,   209,   107,   137,   119,   120,   121,   122,
     124,   123,   125,   231,   238,   108,     0,   272,    98,   126,
     127,    99,   232,   138,   109,   100,   101,   128,   226,   110,
       0,   229,   142,    28,   144,   143,   268,   129,    31,   149,
     111,   150,   112,   106,   208,   275,   230,   113,   228,   227,
     102,   146,   103,   104,   114,   269,   115,   105,    29,   135,
     136,   116,   117,   130,   131,   148,   132,   147,   133,   134,
     139,   145,   270,   225,   118,   140,    30,   245,   242,   243,
     241,   233,    77,    79,    78,     0,    91,    42,     0,     0,
      47,    51,    55,    58,    59,    71,    76,    72,    75,    60,
       0,     0,    80,    84,    92,   182,   184,   186,     0,   195,
     196,   197,     0,   198,   222,   266,     0,     0,   237,    93,
     251,     0,   256,   257,   260,    94,     0,    95,   288,     0,
     425,     0,   441,   443,     0,     0,     0,     0,     0,    63,
     154,   170,     0,     0,   287,     0,   234,     0,   211,   383,
     219,   263,     0,     0,   302,     0,     0,     0,     0,   293,
       0,   331,     0,   303,   328,     0,   304,     0,     0,     0,
     184,     0,     0,     0,     0,     0,   310,   312,   316,   373,
     366,     0,   540,   532,   533,   332,   374,     0,   339,   385,
       0,   398,     0,   396,   539,     0,   397,   346,     0,     0,
       0,     0,     0,   408,   404,   409,   348,   297,   410,   406,
     411,     0,   347,     0,   349,     0,     0,     0,     0,     0,
       0,     0,     0,   357,   423,     0,     0,     0,     0,     0,
       0,   361,   431,     0,   433,   437,   432,     0,   363,   445,
     370,   463,   464,   279,   280,   465,   466,   447,   278,     0,
     448,   395,    91,   486,     0,   490,     0,     1,   514,   516,
       0,   518,   541,     0,   545,   539,     0,     0,   544,   555,
     557,     0,   559,   524,   525,   526,   528,   529,   531,   547,
     548,   530,   568,   550,   536,   549,     0,     0,   538,   552,
     553,   519,     0,     0,     0,     0,     0,     0,     0,     0,
      64,     0,    66,   215,     0,   467,     0,     0,     0,     0,
       0,    26,    10,    11,    14,   570,     0,     4,    35,   512,
     496,   495,     0,   494,     8,     0,   470,     0,   486,     0,
      40,    33,    21,     0,   505,     0,     0,     0,     0,     0,
     452,   453,   393,   391,     0,   456,   455,   334,   414,   593,
     596,   597,   589,     0,   369,     0,   382,   381,   377,     0,
       0,   336,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   248,   239,   249,     0,   261,     0,
      85,   206,   207,     0,     0,     0,    43,    44,     0,     0,
       0,    54,    57,     0,     0,    61,     0,   344,    81,   192,
     191,     0,   190,   193,   194,     0,     0,     0,     0,     0,
     188,     0,   224,     0,     0,     0,     0,     0,     0,     0,
     365,     0,     0,     0,     0,   578,     0,     0,     0,   165,
     156,   155,   173,   179,   177,   171,     0,   172,   178,   169,
     153,   167,   168,   283,   235,     0,     0,   299,   298,     0,
      91,     0,    86,    88,    90,   301,    68,   212,   220,   264,
     296,   300,   307,     0,     0,     0,   324,   325,   323,   326,
     327,   322,     0,   309,   306,     0,     0,     0,     0,     0,
       0,   305,     0,     0,     0,     0,   399,     0,     0,   400,
     345,     0,     0,     0,     0,     0,   405,   407,     0,     0,
       0,     0,     0,     0,     0,   354,     0,     0,   358,   426,
     427,   428,     0,   438,   362,   434,     0,     0,     0,   439,
     440,     0,   446,     0,     0,   521,   485,   492,   487,   488,
       0,   520,   542,     0,     0,   543,   522,   546,     0,   556,
     558,   551,   562,   563,   564,   566,   565,   561,     0,   571,
     554,   587,     0,   591,     0,   594,     0,   290,     0,    65,
      67,   216,     0,     0,     0,     0,     0,     9,    12,     3,
      24,   468,    15,   480,   479,   506,     0,   394,     0,   460,
       0,   392,     0,   454,     0,   337,   368,   380,   379,   401,
     402,   576,     0,   572,   573,    70,   199,   259,   202,     0,
     204,     0,     0,     0,    45,    46,     0,   271,   254,   255,
       0,    48,    52,    53,    56,     0,     0,   183,   185,   187,
       0,     0,     0,   200,     0,   253,   252,     0,     0,     0,
      82,   364,   579,     0,     0,   582,     0,     0,   403,   161,
       0,     0,   177,   174,   176,     0,     0,   285,     0,   351,
       0,     0,   289,    69,   213,   221,   265,   314,   317,   319,
       0,     0,   318,   321,   294,   320,     0,     0,   311,   313,
     367,     0,   386,   388,     0,   462,     0,     0,     0,     0,
       0,   350,   352,   413,   353,   356,   355,   424,     0,   436,
     435,     0,   371,   491,   493,   489,     0,   523,   569,   567,
     588,   592,   595,   291,   217,   503,   504,   476,    27,   482,
     509,   507,   449,   461,   458,   457,     0,   575,   203,   205,
       0,     0,    74,     0,   161,    73,   189,   223,   201,   258,
     276,   274,    83,   580,   581,   359,     0,   162,     0,     0,
       0,   175,   180,   181,    89,    87,   315,   340,     0,     0,
       0,   417,   418,   419,   415,   416,   430,     0,     0,   577,
       0,   267,     0,   360,   166,   157,   160,   158,     0,   387,
     389,   341,     0,   459,     0,     0,   161,     0,     0,   560,
     250,     0,     0,   159,   342
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -810,   778,  1023,  -115,  -810,  1036,    35,  -810,  -810,     5,
     658,  -810,   816,  -289,  1009,  1172,  -257,   578,  -810,  -810,
     216,  -810,   261,  -490,   -49,   453,   -83,  -810,  -334,   328,
       8,    11,  -516,  -810,  1027,   894,  -809,  -152,  -810,  -810,
    -810,  -810,  -582,  -810,    15,   584,   -47,  -324,  -810,  -365,
    -292,   128,   208,    47,    41,   169,  -810,   -46,  -777,  -319,
     683,  -810,  -810,    44,   942,  -810,  -361,   970,  -810,   -33,
    -473,  -810,   901,   -29,  -810,    -7,    49,   700,  -328,   -31,
    1297,  -810,   731,  -810,     0,     6,   367,   -25,  -810,  -810,
    -810,  -810,   817,  -172,   511,   512,  -810,  -329,   507,   -36,
     -35,    95,  -810,  -810,   459,  -810,   -73,   222,  -810,  1131,
    -810,  -810,  -810,  -810,   784,   787,   842,  -810,   -21,  -810,
    -810,  -810,  -810,  -810,  -810,  -810,  -810,   767,   825,  -810,
    -810,  -810,  -810,   -72,  1033,  -810,  -810,  -810,  -810,  -810,
     747,  -810,   -74,  -148,  1217,  -133,  -810,  -810,  -810,  -118,
     -71,  1207,  1208,    58,  -810,  -810,  -810,  1209,  -810,  -810,
    -810,  -810,  -810,  -810,   656,   745,  -810,  -810,  -810,  -810,
    -810,   744,  -810,   -86,  -810,    83,   727,  -810,    85,  -810,
    -810,   100,  -810,  -810,  -810,  -810,  -810,  -810,  -810,  -810,
    -810,  -810
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
       0,   152,   153,   154,   155,   156,    45,   158,   159,   295,
     161,   162,   296,   297,   298,   299,   300,   301,   603,   302,
     303,   304,   305,   306,   307,   308,   309,   310,   661,   662,
     663,    47,   312,   313,   369,   350,   850,   163,   351,   352,
     645,   646,   647,   648,   314,   315,   316,   611,   612,   615,
     317,   595,   318,   319,   320,   321,   322,   323,   324,   325,
     326,    51,   327,    52,   118,   328,    54,   585,   586,   329,
     330,   331,    55,   333,   334,    56,   335,    57,   457,    58,
     337,    60,   338,    62,   432,    64,    65,   681,    66,    67,
      68,    69,   684,   385,   386,   387,   388,   682,    70,    71,
      72,   474,    74,    75,   475,    77,   497,   884,    78,   699,
      79,    80,    81,    82,   414,   419,    83,    84,   415,    85,
      86,   435,    87,    88,   443,   444,   445,   446,    89,    90,
      91,   459,    92,   183,   184,   185,   556,   793,   186,   406,
     460,   167,   168,   169,   170,   464,   465,   466,   171,   532,
     172,   173,   174,   175,   544,   176,   545,   177,    94,    95,
      96,    97,    98,    99,   745,   477,   100,   101,   494,   498,
     478,   479,   758,   495,   496,   480,   500,   804,   481,   204,
     802,   482,   345,   635,   105,   106,   107,   108,   109,   110,
     111,   112
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      63,   165,   114,   622,   400,   119,   529,   668,   453,   596,
     597,   551,   113,   160,   166,   499,   447,   160,   166,   353,
     536,   692,   380,   206,   339,   119,   620,   206,   206,   493,
     776,   374,   311,   365,   655,   344,   382,   539,   370,   115,
     395,   396,   452,   157,   601,   455,   117,    48,   413,   535,
     355,   685,   164,   687,   688,   689,   541,   203,   425,   420,
     458,   690,   456,   694,   853,   609,   340,    63,    63,   339,
     193,   240,   949,     1,    63,     2,    63,   524,    63,   355,
     339,   208,   209,   102,   379,   103,   119,   609,   418,   620,
     483,   339,    63,   339,    63,    73,    63,    48,   542,   486,
     104,   463,   484,   806,   726,   160,   166,    63,   348,    63,
     591,    63,    63,   840,    48,    48,   867,   895,   383,   609,
     609,    48,   819,    48,   797,    48,    48,   434,   492,   553,
     440,   421,   454,   609,    39,     8,   380,   449,    48,    48,
     592,    48,   842,    48,   473,   129,   441,   422,   487,   433,
     382,   450,   727,   836,    48,   629,    48,   949,    48,    48,
     160,   166,   348,   610,   165,   987,   399,   160,   166,    49,
     339,    39,   874,   403,   577,   488,   987,   469,   538,   470,
     549,   178,   956,   339,   566,   610,   208,   209,   187,   468,
     223,   798,   205,   984,   471,   442,   342,   343,   550,   609,
     840,    43,    44,    22,   489,   675,   157,   578,   485,   232,
     580,   582,   348,   668,   179,   164,    46,   610,   610,    49,
     583,   113,   576,   851,   142,   547,    29,   690,   208,   209,
     634,   610,   383,   683,    44,   241,    49,    49,   490,   120,
     491,   363,   792,    49,   591,    49,   166,    49,    49,    39,
     180,   567,   807,    43,    44,   813,   189,   579,   581,   256,
      49,    49,   957,    49,   364,    49,    46,   197,   668,   951,
     633,   591,   826,  -287,   592,   368,    49,   381,    49,   453,
      49,    49,   348,    46,    46,   181,   399,   208,   209,   182,
      46,   834,    46,   837,    46,    46,  -287,   610,   193,   423,
     839,   592,   181,   639,   814,   815,   182,    46,    46,   821,
      46,     1,    46,     2,   195,   424,    36,    37,   621,    39,
     116,    41,   201,    46,   829,    46,   339,    46,    46,   968,
     380,   458,   656,   740,   624,   356,   656,   181,   165,   395,
     396,   182,   822,   823,   674,   687,   119,   348,   549,   196,
     397,   690,   451,   943,   944,    36,    37,   292,   293,   116,
      41,   669,   339,    63,   398,   339,   664,    63,   395,   396,
     339,   390,   447,   658,   670,    63,   536,   339,   671,   666,
     157,   621,   348,   198,   564,   840,   391,   637,   399,   164,
     413,   381,   576,   199,   536,   165,   548,   664,   772,   773,
     774,   775,   420,   454,    63,   436,   367,   160,   166,    48,
      48,   759,   667,   368,    48,   200,   452,   840,   613,   455,
     348,   355,    48,   339,   751,   709,   383,   786,   621,   364,
     614,   418,    23,   708,   738,   341,   456,   157,   621,   395,
     396,    27,  -412,   713,   616,    28,   164,   731,   777,   778,
     558,    48,   348,   721,   630,   437,   511,   626,  -412,    76,
     569,   570,   730,   348,   717,   355,   339,    35,    48,   805,
     668,    39,   208,   209,   538,    63,   346,    63,   511,   438,
     718,   649,   650,   439,   512,   536,   844,    39,   591,    36,
      37,    43,    44,   116,    41,   292,   293,   651,   652,   347,
     160,   166,   845,    63,  -294,    63,   348,    63,   616,    63,
     626,   359,    48,   692,   870,   809,   362,   670,   592,   165,
     670,   512,    48,   789,    48,    39,   375,   375,    42,   208,
     209,    49,    49,   375,   366,   375,    49,   404,   936,   893,
     668,   715,   208,   209,    49,   453,   690,   371,   685,   364,
      48,   375,    48,    76,    48,   448,    48,   676,   364,   677,
     426,   157,   629,   501,   640,   510,   952,   953,   828,   348,
     164,   892,   747,    49,   373,   376,   732,   733,    46,    46,
     670,   389,   788,    46,   514,   381,   515,   208,   209,   664,
      49,    46,   734,   208,   209,   820,   516,   458,   747,   461,
     747,  -297,   747,   591,   747,   787,   664,   801,   638,   641,
     805,   621,   971,   208,   209,   621,   621,   621,   580,   580,
      46,   517,   669,   947,   518,   664,   820,   664,   339,   536,
     536,   858,   576,   592,    49,   670,   519,    46,   869,   380,
     666,   208,   209,   877,    49,   877,    49,   522,   208,   209,
     520,   223,   521,   382,   872,   208,   209,   382,   525,   382,
     896,   526,   395,   396,   882,   579,   581,   945,   528,   454,
     232,   533,    49,   667,    49,    48,    49,   129,    49,   781,
     782,    46,   543,    50,   181,   621,   339,   820,   182,   876,
     339,    46,   339,    46,   552,   883,   241,   948,    63,   208,
     209,   576,   208,   209,   557,   626,    16,   860,   395,   396,
     255,   973,   736,   784,   678,   679,   680,   119,   591,    46,
     256,    46,   670,    46,   336,    46,   451,   666,   731,   559,
     657,    61,   560,    50,   665,   383,   561,   873,   562,   383,
     571,   383,    48,   576,    63,    48,   861,   862,   592,    39,
      50,    50,   476,    43,    44,   572,   142,    50,   897,    50,
     573,    50,    50,   502,   574,   504,   636,   506,   508,   336,
     861,   881,   904,   905,    50,    50,   587,    50,   906,    50,
     336,   354,   972,   577,    36,    37,  -151,    39,   116,    41,
      50,    48,    50,   336,    50,    50,   670,    49,    61,    61,
    -141,   666,   626,  -152,   492,    61,  -246,   354,   958,    61,
     354,   908,   909,    36,    37,   670,   820,   116,    41,   926,
     927,   598,   354,    61,   830,    61,  -271,    61,    36,    37,
     621,    39,   116,    41,   375,   861,   932,   670,    61,   589,
      61,    35,    61,    61,    46,    39,   125,   126,   812,    43,
      44,   602,   503,   667,   505,   127,   507,   509,   339,   604,
     339,   664,   606,   698,    49,   607,   658,    49,   954,   623,
     336,   129,   291,    35,   625,   667,    38,    39,   130,   627,
      42,    43,    44,   336,   832,   378,   861,   935,     1,   961,
       2,   628,   208,   209,   381,   653,   132,   654,   381,   752,
     381,   431,   753,   754,   135,   755,   756,   670,   757,   462,
     672,    46,   666,    49,    46,    35,   146,   147,    38,   540,
     149,   150,   151,   695,    44,   332,   669,   962,   979,   963,
     208,   209,   208,   209,   744,   700,   982,   861,   938,   670,
     141,   701,    53,   702,   666,   667,   703,   882,   861,   939,
     142,   964,   188,   704,   208,   209,   616,   959,   960,   980,
      46,   969,   965,   202,   705,   208,   209,   355,   966,   723,
     332,   208,   209,   974,   975,   531,   145,   716,   883,   985,
     975,   332,   722,   531,   724,    16,   462,   977,    39,   993,
     208,   209,   208,   209,   332,   546,   735,   616,   736,   378,
     626,   741,   555,   959,   992,   616,    48,   746,   743,    53,
      53,   492,   750,   761,    48,   399,    53,   763,    53,   292,
      53,   765,   767,   575,   780,    48,   336,   783,   785,   790,
     791,   795,   794,    30,    53,   796,    53,   799,    53,   800,
     803,   629,   809,   810,   808,    50,    50,   825,   833,    53,
      50,    53,   847,    53,    53,   811,   831,   848,    50,   841,
      35,   849,   854,    38,    39,   336,   336,    42,    43,    44,
     336,   332,   208,   209,   349,   857,   859,   336,   357,   358,
     807,   360,   880,   361,   332,   885,   891,    50,   591,   894,
     676,   364,   677,   354,   354,   901,   902,   336,   354,   591,
     907,   676,   364,   677,    50,   293,   354,   910,   332,   591,
     911,   676,   364,   677,   912,    35,    36,    37,   592,    39,
     116,    41,    42,   336,   913,   336,   915,   916,    49,   592,
     917,   918,   920,   748,   919,   354,    49,   563,   921,   592,
     923,   922,   930,   931,   937,   513,   933,    49,    50,   934,
     805,   940,   354,   208,   209,   941,   970,   698,    50,   762,
      50,   764,   976,   766,   967,   768,   336,   644,   978,   591,
     986,   676,   364,   677,   981,    46,   989,   947,   990,   994,
     697,   824,   660,    46,   779,   534,    50,   903,    50,   955,
      50,   527,    50,   673,    46,   827,   354,   588,   605,   592,
     988,   878,   691,   744,   879,   706,   354,   659,    61,   405,
     707,   725,   739,   660,   125,   126,   693,    93,   554,   191,
     192,   194,   749,   127,   565,   568,   760,   332,     0,     0,
       0,     0,     0,     0,    61,     0,    61,     0,    61,   129,
      61,     0,   710,   711,     0,   714,   130,   678,   679,   680,
       0,   584,   719,   720,   584,     0,     0,     0,   678,   679,
     680,     0,   190,   729,   132,     0,   332,   332,   678,   679,
     680,   332,   135,   121,     0,   122,     0,     0,   332,     0,
       0,     0,   462,     0,     0,     0,     0,   124,     0,   336,
     125,   126,     0,     0,     0,     0,     0,    59,   332,   127,
       0,     0,     0,     7,     0,   593,   336,     0,   141,   128,
       0,    50,     0,     0,     0,   129,     0,    53,   142,     0,
       0,   523,   590,     0,   332,   336,   332,   336,   678,   679,
     680,     0,   531,   531,   531,   531,     0,     0,    15,   608,
     132,   133,     0,   696,   145,   134,    53,     0,   135,     0,
       0,     0,     0,     0,   136,     0,    39,     0,     0,   354,
       0,   531,     0,     0,    59,    59,   384,   332,   631,     0,
       0,    59,     0,     0,   139,    59,     0,     0,    50,   140,
       0,    50,     0,     0,   141,     0,   336,   593,   336,    59,
     336,    59,   336,    59,   142,     0,     0,     0,   143,     0,
       0,     0,     0,     0,    59,   660,    59,     0,    59,    59,
       0,   818,     0,     0,   742,     0,     0,    53,     0,    53,
     145,     0,   660,     0,     0,     0,   354,    50,     0,   354,
       0,     0,    39,     0,     0,     0,     0,     0,     0,     0,
     593,   660,   835,   660,     0,    53,   228,    53,     0,    53,
       0,    53,   846,   231,     0,     0,   771,     0,     0,     0,
       0,     0,   852,     0,     0,   235,   236,     0,   594,     0,
       0,   593,     0,     0,     0,   354,     0,     0,     0,     1,
     384,     2,     0,     0,     0,   407,     0,     0,     0,     0,
     332,     0,     0,     0,     0,     0,   332,     0,   868,     0,
       0,     0,   378,   871,     0,     0,   378,   332,   378,     0,
     260,     0,     0,     0,     0,   262,   263,   886,   887,   888,
     889,   890,     0,     0,     0,   408,   332,   332,   332,   267,
       0,     0,     0,     0,     0,     0,     0,   769,   898,   770,
     593,     0,   899,   900,   711,     0,     0,     0,     0,     0,
     594,     0,     0,     0,     0,   593,     0,     0,   336,     0,
     336,   336,     0,     0,   593,     0,     0,   409,     0,     0,
       0,   771,     0,     0,     0,     0,    16,    38,    39,     0,
       0,     0,    43,    44,   593,     0,   410,   332,   332,     0,
       0,   332,     0,   332,     0,     0,     0,     0,     0,     0,
       1,     0,     2,   594,     0,     0,     0,     0,   924,     0,
     925,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     411,     0,     0,     0,    30,     0,     0,   412,     0,     0,
       0,     0,   575,     0,   594,     0,     0,     0,     0,     0,
      53,     0,    50,     0,     0,     0,   408,     0,     0,     0,
      50,    35,     0,   593,    38,    39,     0,   855,    42,    43,
      44,    50,     0,   946,     0,     0,   950,   852,     0,   593,
       0,     0,     0,     0,   384,     0,     0,   660,     0,     0,
       0,     0,   593,     0,     0,   228,    53,     0,   409,     0,
     354,     0,   231,   863,   864,   865,   866,    16,   354,     0,
       0,     0,     0,   594,   235,   236,     0,   410,     0,   354,
       0,     0,     0,     0,     0,     0,     0,   332,   594,   593,
     593,     0,     0,   593,     0,     0,     0,   594,   593,   593,
       0,     0,     0,     0,     0,     0,     0,     0,   593,     0,
       0,   411,     0,     0,     0,    30,     0,   594,   412,   260,
       0,     0,     0,     0,   262,   263,     0,     0,     0,   332,
       0,   332,   332,     0,     0,     0,     0,     0,   267,     0,
       0,     0,    35,   771,    59,    38,    39,     0,     0,    42,
      43,    44,     0,     0,   983,     0,     0,     0,     0,   228,
       0,     0,     0,     0,     0,     0,   231,     0,   914,     0,
      59,     0,    59,   991,    59,     0,    59,     0,   235,   236,
       0,     0,     0,     0,     0,     0,   594,    39,     0,     0,
     856,    43,    44,     0,     0,     0,     0,   593,     0,     0,
       0,     0,   594,     0,     0,   928,     0,   929,     0,     0,
       0,     0,     0,   771,   593,   594,     0,     0,     0,     0,
       0,     0,   617,   260,     0,   593,     0,     0,   262,   263,
     618,   593,   619,     0,     0,     0,     0,   942,     0,     0,
       0,   213,   267,     0,     0,     0,     0,   593,     0,     0,
     593,     0,   594,   594,     0,     0,   594,     0,     0,     0,
       0,   594,   594,   223,   224,   593,   593,   593,   593,   593,
       0,   594,     0,     0,     0,     0,     0,   593,   593,   593,
       0,     0,   232,     0,     0,   712,     0,    35,    36,    37,
      38,    39,   116,    41,    42,    43,    44,     0,     0,     0,
       0,     0,   238,   593,   593,     0,     0,     0,   241,     0,
       0,     0,     0,     0,   121,     0,   122,     0,     0,     0,
       0,     0,     0,     0,     0,   593,     0,     0,   124,   593,
     254,     0,   256,     0,   258,   259,     0,     0,     0,     0,
       0,     0,     0,     0,     7,     0,     0,     0,     0,     0,
     128,     0,     0,   384,     0,     0,   875,   384,     0,   384,
     594,     0,   593,     0,     0,     0,     0,     0,     0,     0,
     593,   467,     0,     0,     0,    30,     0,   594,     0,    15,
       0,     0,   133,     0,     0,     1,   134,     2,   594,   283,
       0,     3,     0,     0,   594,   136,     0,     0,   287,     0,
       4,     0,    35,   288,    37,     0,    39,   116,    41,    42,
     594,     0,     0,   594,     0,   139,     0,     0,     0,     0,
     140,     0,     5,     6,     0,     0,     0,     0,   594,   594,
     594,   594,   594,     0,     0,     0,     0,     0,     8,   143,
     594,   594,   594,     9,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    10,     0,     0,     0,    11,     0,
       0,    12,    13,     0,    14,     0,   594,   594,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    16,     0,     0,     0,     0,     0,   594,    17,
      18,     0,   594,     0,     0,     0,     0,     0,     0,     0,
      19,    20,     0,     0,     0,    21,    22,    23,    24,     0,
       0,     0,     0,     0,    25,    26,    27,     0,     0,     0,
      28,     0,     0,     0,     0,   594,     0,     0,     0,    29,
      30,     0,     0,   594,     0,     0,     0,     0,    31,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    32,     0,
      33,     0,    34,     0,     0,     0,     0,    35,    36,    37,
      38,    39,    40,    41,    42,    43,    44,   207,     0,   208,
     209,     0,     0,     0,     0,   210,     0,   211,     0,     0,
       0,   416,     0,     0,     0,     0,   213,     0,     0,     0,
       0,   214,   215,     0,     0,     0,     0,   216,   217,   218,
     219,   220,   221,   222,     0,     0,     0,     0,   223,   224,
       0,     0,     0,     0,     0,     0,   225,   226,   227,   228,
       0,   408,     0,     0,   229,   230,   231,   232,     0,     0,
       0,   233,   234,     0,     0,     0,     0,     0,   235,   236,
       0,     0,     0,     0,     0,   237,     0,   238,     0,   239,
       0,   240,     0,   241,     0,     0,     0,   242,     0,   243,
     244,     0,   245,   409,   246,     0,   247,   248,   249,   250,
     251,   252,    16,   253,     0,   254,   255,   256,   257,   258,
     259,     0,   410,   260,     0,     0,   261,     0,   262,   263,
       0,     0,     0,   264,     0,     0,     0,     0,     0,     0,
     265,   266,   267,   268,     0,     0,     0,   269,   270,   271,
       0,   272,   273,     0,   274,   275,   411,   276,     0,     0,
      30,   277,     0,   412,   278,   279,     0,     0,     0,     0,
       0,   280,   281,   282,   283,   284,   285,     0,     0,   286,
       0,     0,     0,   287,     0,     0,     0,    35,   288,   289,
      38,   417,    40,   290,    42,    43,    44,   291,     0,   292,
     293,   294,   207,     0,   208,   209,     0,     0,     0,     0,
     210,     0,   211,     0,     0,     0,     0,     0,     0,     0,
       0,   213,     0,     0,     0,     0,   214,   215,     0,     0,
       0,     0,   216,   217,   218,   219,   220,   221,   222,     0,
       0,     0,     0,   223,   224,     0,     0,     0,     0,     0,
       0,   225,   226,   227,   228,     0,   408,     0,     0,   229,
     230,   231,   232,     0,     0,     0,   233,   234,     0,     0,
       0,     0,     0,   235,   236,     0,     0,     0,     0,     0,
     237,     0,   238,     0,   239,     0,   240,     0,   241,     0,
       0,     0,   242,     0,   243,   244,     0,   245,   409,   246,
       0,   247,   248,   249,   250,   251,   252,    16,   253,     0,
     254,   255,   256,   257,   258,   259,     0,   410,   260,     0,
       0,   261,     0,   262,   263,     0,     0,     0,   264,     0,
       0,     0,     0,     0,     0,   265,   266,   267,   268,     0,
       0,     0,   269,   270,   271,     0,   272,   273,     0,   274,
     275,   411,   276,     0,     0,    30,   277,     0,   412,   278,
     279,     0,     0,     0,     0,     0,   280,   281,   282,   283,
     284,   285,     0,     0,   286,     0,     0,     0,   287,     0,
       0,     0,    35,   288,   289,    38,   417,    40,   290,    42,
      43,    44,   291,     0,   292,   293,   294,   207,     0,   208,
     209,     0,     0,     0,     0,   210,     0,   211,     0,     0,
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
     293,   294,   207,     0,   208,   209,   537,     0,     0,     0,
     210,     0,   211,     0,     0,     0,     0,     0,     0,     0,
       0,   213,     0,     0,     0,     0,   214,   215,     0,     0,
       0,     0,   216,   217,   218,   219,   220,   221,   222,     0,
       0,     0,     0,   223,   224,     0,     0,     0,     0,     0,
       0,   225,   226,   227,   228,     0,     0,     0,     0,   229,
     230,   231,   232,     0,     0,     0,   233,   234,     0,     0,
       0,     0,     0,   235,   236,     0,     0,     0,     0,     0,
     237,     0,   238,     0,   239,     0,   240,     0,   241,     0,
       0,     0,   242,     0,   243,   244,     0,   245,     0,   246,
       0,   247,   248,   249,   250,   251,   252,    16,   253,     0,
     254,   255,   256,   257,   258,   259,     0,     0,   260,     0,
       0,   261,     0,   262,   263,     0,     0,     0,   264,     0,
       0,     0,     0,     0,     0,   265,   266,   267,   268,     0,
       0,     0,   269,   270,   271,     0,   272,   273,     0,   274,
     275,     0,   276,     0,     0,    30,   277,     0,     0,   278,
     279,     0,     0,     0,     0,     0,   280,   281,   282,   283,
     284,   285,     0,     0,   286,     0,     0,     0,   287,     0,
       0,     0,    35,   288,   289,    38,    39,    40,   290,    42,
      43,    44,   291,     0,   292,   293,   294,   207,     0,   208,
     209,     0,     0,     0,     0,   210,     0,   211,     0,     0,
       0,     0,     0,     0,     0,     0,   213,     0,     0,     0,
       0,   214,   215,     0,     0,     0,     0,   216,   217,   218,
     219,   220,   221,   222,     0,     0,     0,     0,   223,   224,
       0,     0,     0,     0,     0,     0,   225,   226,   227,   228,
       0,     0,     0,     0,   229,   230,   231,   232,     0,     0,
       0,   233,   234,     0,     0,     0,     0,     0,   235,   236,
       0,     0,     0,     0,     0,   237,     0,   238,    11,   239,
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
     293,   294,   377,     0,   208,   209,     0,     0,     0,     0,
     210,     0,   211,     0,     0,     0,     0,     0,     0,     0,
       0,   213,     0,     0,     0,     0,   214,   215,     0,     0,
       0,     0,   216,   217,   218,   219,   220,   221,   222,     0,
       0,     0,     0,   223,   224,     0,     0,     0,     0,     0,
       0,   225,   226,   227,   228,     0,     0,     0,     0,   229,
     230,   231,   232,     0,     0,     0,   233,   234,     0,     0,
       0,     0,     0,   235,   236,     0,     0,     0,     0,     0,
     237,     0,   238,     0,   239,     0,   240,     0,   241,     0,
       0,     0,   242,     0,   243,   244,     0,   245,     0,   246,
       0,   247,   248,   249,   250,   251,   252,    16,   253,     0,
     254,   255,   256,   257,   258,   259,     0,     0,   260,     0,
       0,   261,     0,   262,   263,     0,     0,     0,   264,     0,
       0,     0,     0,     0,     0,   265,   266,   267,   268,     0,
       0,     0,   269,   270,   271,     0,   272,   273,     0,   274,
     275,     0,   276,     0,     0,    30,   277,     0,     0,   278,
     279,     0,     0,     0,     0,     0,   280,   281,   282,   283,
     284,   285,     0,     0,   286,     0,     0,     0,   287,     0,
       0,     0,    35,   288,   289,    38,    39,    40,   290,    42,
      43,    44,   291,     0,   292,   293,   294,   207,     0,   208,
     209,     0,     0,     0,     0,   210,     0,   211,     0,     0,
       0,     0,     0,     0,     0,     0,   213,     0,     0,     0,
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
     293,   294,   207,     0,   208,   209,     0,     0,     0,     0,
     210,     0,   211,     0,     0,     0,     0,     0,     0,     0,
       0,   213,     0,     0,     0,     0,   214,   215,     0,     0,
       0,     0,   216,   217,   218,   219,   220,   221,   222,     0,
       0,     0,     0,   223,   224,     0,     0,     0,     0,     0,
       0,   225,   226,   227,   228,     0,     0,     0,     0,   229,
     230,   231,   232,     0,     0,     0,   233,   234,     0,     0,
       0,     0,     0,   235,   236,     0,     0,     0,     0,     0,
     237,     0,   238,     0,   239,     0,     0,     0,   241,     0,
       0,     0,   242,     0,   243,   244,     0,   245,     0,   246,
       0,   247,   248,   249,   250,   251,   252,     0,   253,     0,
     254,     0,   256,   257,   258,   259,     0,     0,   260,     0,
       0,   261,     0,   262,   263,     0,     0,     0,   264,     0,
       0,     0,     0,     0,     0,   265,   266,   267,   268,     0,
       0,     0,   269,   270,   271,     0,   272,   273,     0,   274,
     275,     0,   276,     0,     0,    30,   277,     0,     0,   278,
     279,     0,     0,     0,     0,     0,   280,   281,   282,   283,
     284,   285,     0,     0,   286,     0,     0,     0,   287,     0,
       0,     0,    35,   288,   289,    38,    39,   116,   290,    42,
      43,    44,   291,     0,   292,   293,   294,   728,     0,   208,
     209,     0,     0,     0,     0,   210,     0,   211,     0,     0,
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
       0,     0,     0,   287,     0,     0,     0,    35,   288,    37,
       0,    39,   116,   290,    42,    43,    44,     0,     0,   292,
     293,   294,   816,     0,   208,   209,     0,     0,     0,     0,
       1,     0,     2,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   214,   215,     0,     0,
       0,     0,   216,   217,   218,   219,   220,   221,   222,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   225,   226,   227,   228,     0,     0,     0,     0,   229,
     230,   231,     0,     0,     0,     0,   233,   234,     0,     0,
       0,     0,     0,   235,   236,     0,     0,     0,     0,     0,
     237,     0,     0,     0,   239,     0,     0,     0,     0,     0,
       0,     0,   242,     0,   243,   244,     0,   245,     0,   246,
       0,   247,   248,   249,   250,   251,   252,     0,   253,     0,
       0,     0,     0,   257,     0,     0,     0,     0,   260,     0,
       0,   261,     0,   262,   263,     0,     0,     0,   264,     0,
       0,     0,     0,     0,     0,   265,   266,   267,   268,     0,
       0,     0,   269,   270,   271,     0,   272,   273,     0,   274,
     275,     0,   276,     0,     0,     0,   277,     0,     0,   278,
     279,     0,     0,     0,     0,     0,   280,   281,   282,     0,
     284,   285,     0,   427,   286,   208,   209,     0,     0,     0,
       0,     1,     0,     2,   817,    38,    39,     0,   430,     0,
      43,    44,   291,     0,   292,   293,   294,   214,   215,     0,
       0,     0,     0,   216,   217,   218,   219,   220,   221,   222,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   225,     0,     0,   228,     0,     0,     0,     0,
     229,   230,   231,     0,     0,     0,     0,   233,   234,     0,
       0,     0,     0,     0,   235,   236,     0,     0,     0,     0,
       0,   237,     0,     0,     0,   239,   428,     0,     0,     0,
       0,     0,     0,   242,     0,   243,   244,     0,   245,     0,
       0,     0,   247,   248,   249,   250,   251,   252,     0,   253,
       0,     0,     0,     0,   257,     0,     0,     0,     0,   260,
       0,     0,   261,     0,   262,   263,     0,     0,     0,   264,
       0,     0,     0,     0,     0,     0,     0,   266,   267,   268,
       0,     0,     0,   269,   270,   271,     0,   272,   273,     0,
     274,   275,     0,   276,     0,     0,     0,   277,     0,     0,
     278,   279,     0,     0,     0,     0,     0,   280,   281,     0,
       0,   284,   285,   429,   427,   286,   208,   209,   642,     0,
       0,   643,     1,     0,     2,     0,     0,    39,     0,   430,
       0,    43,    44,     0,     0,   292,   293,   294,   214,   215,
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
       0,     0,   284,   285,     0,   427,   286,   208,   209,   530,
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
     281,     0,     0,   284,   285,     0,   427,   286,   208,   209,
       0,     0,     0,   643,     1,     0,     2,     0,     0,    39,
       0,   430,     0,    43,    44,     0,     0,   292,   293,   294,
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
     280,   281,     0,     0,   284,   285,     0,   427,   286,   208,
     209,     0,     0,     0,     0,     1,     0,     2,     0,     0,
      39,     0,   430,     0,    43,    44,     0,     0,   292,   293,
     294,   214,   215,     0,     0,     0,     0,   216,   217,   218,
     219,   220,   221,   222,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   225,     0,     0,   228,
       0,     0,     0,     0,   229,   230,   231,     0,     0,     0,
       0,   233,   234,     0,     0,     0,     0,     0,   235,   236,
       0,     0,     0,     0,     0,   237,     0,     0,     0,   239,
       0,     0,     0,     0,     0,     0,     0,   242,     0,   243,
     244,     0,   245,     0,     0,     0,   247,   248,   249,   250,
     251,   252,     0,   253,     0,     0,     0,     0,   257,     0,
       0,     0,     0,   260,     0,     0,   261,     0,   262,   263,
       0,     0,     0,   264,     0,     0,     0,     0,     0,     0,
       0,   266,   267,   268,     0,     0,     0,   269,   270,   271,
       0,   272,   273,     0,   274,   275,     0,   276,     0,     0,
       0,   277,     0,     0,   278,   279,     0,     0,     0,     0,
       0,   280,   281,   427,     0,   284,   285,   599,   600,   286,
       0,     1,     0,     2,     0,     0,     0,     0,     0,     0,
       0,    39,     0,   430,     0,    43,    44,   214,   215,   292,
     293,   294,     0,   216,   217,   218,   219,   220,   221,   222,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   225,     0,     0,   228,     0,     0,     0,     0,
     229,   230,   231,     0,     0,     0,     0,   233,   234,     0,
       0,     0,     0,     0,   235,   236,     0,     0,     0,     0,
       0,   237,     0,     0,     0,   239,     0,     0,     0,     0,
       0,     0,     0,   242,     0,   243,   244,     0,   245,     0,
       0,     0,   247,   248,   249,   250,   251,   252,     0,   253,
       0,     0,     0,     0,   257,     0,     0,     0,     0,   260,
       0,     0,   261,     0,   262,   263,     0,     0,     0,   264,
       0,     0,     0,     0,     0,     0,     0,   266,   267,   268,
       0,     0,     0,   269,   270,   271,     0,   272,   273,     0,
     274,   275,     0,   276,     0,     0,     0,   277,     0,     0,
     278,   279,     0,     0,     0,     0,     0,   280,   281,   427,
       0,   284,   285,     0,     0,   286,     0,     1,     0,     2,
       0,     0,     0,     0,     0,     0,     0,    39,     0,   430,
       0,    43,    44,   214,   215,   292,   293,   294,     0,   216,
     217,   218,   219,   220,   221,   222,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   225,     0,
       0,   228,     0,     0,     0,     0,   229,   230,   231,     0,
       0,     0,     0,   233,   234,     0,     0,     0,     0,     0,
     235,   236,     0,     0,     0,     0,     0,   237,     0,     0,
       0,   239,     0,     0,     0,     0,     0,     0,     0,   242,
       0,   243,   244,     0,   245,     0,     0,     0,   247,   248,
     249,   250,   251,   252,     0,   253,     0,     0,     0,   737,
     257,     0,     0,     0,     0,   260,     0,     1,   261,     2,
     262,   263,     0,     0,     0,   264,     0,     0,     0,     0,
       0,     0,     0,   266,   267,   268,     0,     0,     0,   269,
     270,   271,     0,   272,   273,     0,   274,   275,     0,   276,
     223,     0,     0,   277,     0,     0,   278,   279,     0,   226,
       0,     0,     0,   280,   281,   617,     0,   284,   285,   232,
       0,   286,     0,   618,     0,   619,     0,     0,     0,     0,
       0,     0,     0,    39,   213,   430,     0,    43,    44,   238,
       0,   292,   293,   294,     0,   241,     0,     0,     0,     0,
     617,     0,     0,     0,     0,     0,   223,   224,   618,     0,
     619,     0,     0,     0,    16,     0,     0,     0,     0,   256,
       0,   258,   259,     0,     0,   232,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   228,     0,     0,     0,
       0,   223,   224,   231,     0,   238,     0,     0,     0,   686,
       0,   241,     0,     0,     0,   235,   236,   618,     0,   619,
     232,     0,    30,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   254,     0,   256,   283,   258,   259,     0,
     238,     0,     0,     0,     0,     0,   241,     0,     0,    35,
     223,   224,    38,    39,     0,     0,    42,    43,    44,   291,
     260,   292,   293,   294,     0,   262,   263,     0,     0,   232,
     256,     0,   258,   259,     0,     0,     0,     0,    30,   267,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   238,
       0,     0,   283,     0,     0,   241,     0,     0,     0,     0,
       0,   287,     0,     0,     0,    35,   288,    37,     0,    39,
     116,    41,    42,    30,     0,     0,     0,     0,     0,   256,
       0,   258,   259,     0,    35,    36,    37,   283,    39,   116,
      41,    42,    43,    44,     0,     1,   287,     2,     0,     0,
      35,   288,    37,     0,    39,   116,    41,    42,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   632,
       0,     0,    30,     0,     0,     0,     0,     0,   223,     0,
     121,     0,   122,     0,     0,     0,   283,   226,     0,   228,
       0,     0,     0,     0,   124,   287,   231,   232,     0,    35,
     288,    37,     0,    39,   116,    41,    42,     0,   235,   236,
       7,     0,     0,     0,     0,     0,   128,   238,     0,     0,
       0,     0,     0,   241,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    16,     0,     0,    15,     0,   256,   133,   258,
     259,     0,   134,   260,     0,     0,     0,     0,   262,   263,
       0,   136,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   267,     0,     0,     0,     0,     0,     0,     0,
       0,   139,     0,     0,     0,     0,   140,     0,     0,     0,
      30,     0,     0,     0,     0,     1,     0,     2,     0,     0,
       0,     3,     0,     0,   283,   143,     0,     0,     0,     0,
       4,     0,     0,     0,     0,     0,     0,    35,    36,    37,
      38,    39,   116,    41,    42,    43,    44,   291,     0,   292,
     293,   294,     5,     6,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     7,     0,     0,     0,     0,     8,     0,
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
       0,     0,     0,     0,     0,     1,   472,     2,     0,     0,
       0,     0,     0,     0,     8,     0,     0,     0,     0,     9,
       0,     0,     0,   473,     0,     0,     0,     0,     0,     0,
      10,     0,     0,     0,    11,     0,     0,    12,    13,     0,
      14,     0,     0,     0,     0,     0,     0,     0,     0,   228,
       0,     0,     0,     0,     0,     0,   231,     0,    16,     0,
       0,     0,     0,     0,     0,    17,    18,     0,   235,   236,
       0,     0,     0,     0,     0,     0,    19,    20,     0,     0,
       0,    21,    22,    23,    24,     0,     0,     0,     0,     0,
      25,    26,    27,     1,     0,     2,    28,     0,     0,     3,
       0,     0,    16,     0,     0,    29,    30,     0,     4,     0,
       0,     0,     0,   260,    31,     0,     0,     0,   262,   263,
       0,     0,     0,     0,    32,     0,    33,     0,    34,     0,
       5,     6,   267,    35,    36,    37,    38,    39,    40,    41,
      42,    43,    44,     0,     0,     0,     0,     0,     0,     0,
      30,     9,     0,     0,   401,     0,     0,     0,     0,     0,
       0,     0,    10,     0,     0,     0,    11,     0,     0,    12,
      13,     0,    14,     0,     0,     0,     0,    35,    36,    37,
      38,    39,   116,    41,    42,    43,    44,     0,     0,     0,
      16,     0,     0,     0,     0,     0,     0,    17,    18,     0,
       0,   843,     0,     0,     0,     0,     0,     0,    19,    20,
       0,     0,   121,    21,   122,    23,    24,     0,     0,     0,
       0,     0,    25,    26,    27,     1,   124,     2,    28,     0,
       0,     3,     0,     0,     0,     0,     0,     0,    30,     0,
       4,     0,     7,     0,     0,   402,    31,     0,   128,     0,
       0,     0,     0,     0,     0,     0,    32,     0,    33,     0,
      34,     0,     5,     6,     0,    35,    36,    37,    38,    39,
      40,    41,    42,    43,    44,     0,     0,    15,     0,     0,
     133,     0,     0,     9,   134,     0,   401,     0,     0,     0,
       0,     0,     0,   136,    10,     0,   392,     0,    11,     0,
       0,     0,    13,     0,    14,     0,     0,     0,     0,     0,
       0,     0,     0,   139,     0,     0,     0,     0,   140,     0,
       0,     0,    16,     0,     0,     0,     0,     0,     0,    17,
      18,     0,     0,     0,     0,     0,     0,   143,     0,     0,
      19,    20,     0,     0,     0,    21,     0,    23,    24,     0,
       0,     0,     0,     0,    25,    26,    27,     0,     0,     0,
      28,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,     1,     0,     2,     0,     0,   393,     3,    31,     0,
       0,     0,     0,     0,     0,     0,     4,     0,   394,     0,
      33,     0,    34,     0,     0,     0,     0,    35,    36,    37,
      38,    39,   116,    41,    42,    43,    44,     0,     5,     6,
       0,     0,     0,     0,     0,     0,   472,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     9,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      10,     0,   392,     0,    11,     0,     0,     0,    13,     0,
      14,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    16,     0,
       0,     0,     0,     0,     0,    17,    18,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    19,    20,     0,     0,
       0,    21,     0,    23,    24,     0,     0,     0,     0,     0,
      25,    26,    27,     1,     0,     2,    28,     0,     0,     3,
       0,     0,     0,     0,     0,     0,    30,     0,     4,     0,
       0,     0,   393,     0,    31,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   394,     0,    33,     0,    34,     0,
       5,     6,     0,    35,    36,    37,    38,    39,   116,    41,
      42,    43,    44,     0,     0,     0,     0,     0,     0,     0,
       0,     9,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    10,     0,   392,     0,    11,     0,     0,     0,
      13,     0,    14,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      16,     0,     0,     0,     0,     0,     0,    17,    18,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    19,    20,
       0,     0,     0,    21,     0,    23,    24,     0,     0,     0,
       0,     0,    25,    26,    27,     0,     0,     0,    28,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    30,     1,
       0,     2,     0,     0,   393,     3,    31,     0,     0,     0,
       0,     0,     0,     0,     4,     0,   394,     0,    33,     0,
      34,     0,     0,     0,     0,    35,    36,    37,    38,    39,
     116,    41,    42,    43,    44,     0,     5,     6,     0,     0,
       0,     0,     0,     0,   472,     0,     0,     0,     0,     0,
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
       0,     0,     0,     0,   372,     0,    33,     0,    34,     0,
       5,     6,     0,    35,    36,    37,    38,    39,    40,    41,
      42,    43,    44,     0,     0,     0,     0,     0,     0,     0,
       0,     9,     0,     0,   401,     0,     0,     0,     0,     0,
       0,     0,    10,     0,     0,     0,    11,     0,     0,     0,
      13,     0,    14,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      16,     0,     0,     0,     0,     0,     0,    17,    18,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    19,    20,
       0,     0,     0,    21,     0,    23,    24,     0,     0,     0,
       0,     0,    25,    26,    27,     0,     0,     0,    28,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    30,     1,
       0,     2,     0,     0,     0,     3,    31,     0,     0,     0,
       0,     0,     0,     0,     4,     0,   372,     0,    33,     0,
      34,     0,     0,     0,     0,    35,    36,    37,    38,    39,
     116,    41,    42,    43,    44,     0,     5,     6,     0,     0,
       0,     0,     0,     0,   472,     0,     0,     0,     0,     0,
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
       0,     0,   372,     0,    33,     0,    34,     0,     5,     6,
       0,    35,    36,    37,    38,    39,   116,    41,    42,    43,
      44,     0,     0,     0,     0,     0,     0,     0,     0,     9,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   228,
      10,     0,     0,     0,    11,     0,   231,     0,    13,     0,
      14,     0,     0,     0,     0,     0,     0,     0,   235,   236,
       0,     0,     0,     0,     0,     0,     0,     0,    16,     0,
       0,     0,     0,     0,     0,    17,    18,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    19,    20,     0,     0,
       0,    21,    16,    23,    24,     0,   838,     0,     0,     0,
      25,    26,    27,   260,     0,     0,    28,     0,   262,   263,
       0,     0,     0,     0,     0,     0,    30,     0,     0,     0,
       0,     0,   267,     0,    31,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   372,     0,    33,     0,    34,     0,
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
     137,     0,   138,     0,     0,     0,     0,     0,     0,   139,
      15,   132,     0,   133,   140,     0,     0,   134,   141,   135,
       0,     0,     0,     0,     0,     0,   136,     0,   142,     0,
       0,     0,     0,   143,     0,     0,     0,     0,     0,     0,
       0,   144,     0,     0,     0,     0,   139,     0,     0,     0,
       0,   140,     0,     0,   145,   141,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   142,    39,     0,     0,     0,
     143,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   145,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    39
};

static const yytype_int16 yycheck[] =
{
       0,     8,     2,   322,    77,     5,   158,   368,    91,   298,
     299,   183,     1,     8,     8,   101,    88,    12,    12,    50,
     168,   386,    69,    23,    24,    25,   318,    27,    28,   100,
     520,    67,    24,    58,   362,    29,    69,   170,    63,     4,
      76,    76,    91,     8,   301,    91,     5,     0,    79,   167,
      50,   380,     8,   382,   383,   384,   171,    22,    83,    80,
      91,   385,    91,   397,   646,    22,    25,    67,    68,    69,
      12,    90,   849,    14,    74,    16,    76,   151,    78,    79,
      80,     8,     9,     0,    69,     0,    86,    22,    80,   381,
      20,    91,    92,    93,    94,     0,    96,    50,   172,    82,
       0,    93,    32,     5,    33,   100,   100,   107,    18,   109,
      24,   111,   112,   629,    67,    68,     5,    20,    69,    22,
      22,    74,   595,    76,    94,    78,    79,    86,     6,    20,
       4,     4,    91,    22,   190,    67,   183,     6,    91,    92,
      54,    94,   632,    96,    76,    73,    20,    20,   131,    20,
     183,    20,    81,   626,   107,    11,   109,   934,   111,   112,
     155,   155,    18,   120,   171,   974,    44,   162,   162,     0,
     170,   190,   191,    78,   207,    61,   985,    94,   170,    94,
     180,    20,     5,   183,    94,   120,     8,     9,    20,    94,
      47,   161,    23,   970,    94,    69,    27,    28,   183,    22,
     716,   194,   195,   135,    90,   377,   171,   207,   138,    66,
     210,   211,    18,   574,    53,   171,     0,   120,   120,    50,
      26,   210,   207,    45,   152,   166,   158,   551,     8,     9,
     345,   120,   183,   168,   195,    92,    67,    68,   124,     6,
     126,     4,   169,    74,    24,    76,   240,    78,    79,   190,
      89,   161,     5,   194,   195,   589,     6,   210,   211,   116,
      91,    92,    20,    94,    27,    96,    50,    79,   629,   851,
     344,    24,   606,     4,    54,    11,   107,    69,   109,   362,
     111,   112,    18,    67,    68,   176,    44,     8,     9,   180,
      74,   625,    76,   627,    78,    79,    27,   120,   240,     4,
     628,    54,   176,     6,   593,   594,   180,    91,    92,   598,
      94,    14,    96,    16,   169,    20,   187,   188,   318,   190,
     191,   192,    20,   107,   616,   109,   326,   111,   112,    50,
     377,   362,   363,   466,   326,     6,   367,   176,   345,   375,
     375,   180,   599,   600,   377,   674,   346,    18,   348,     6,
       6,   675,    91,   843,   844,   187,   188,   198,   199,   191,
     192,   368,   362,   363,    20,   365,   366,   367,   404,   404,
     370,    20,   444,   365,   368,   375,   524,   377,   370,   368,
     345,   381,    18,    79,    20,   901,    35,   346,    44,   345,
     421,   183,   377,     6,   542,   402,   180,   397,   516,   517,
     518,   519,   423,   362,   404,    45,     4,   402,   402,   362,
     363,   497,   368,    11,   367,     6,   465,   933,    23,   465,
      18,   421,   375,   423,   495,   425,   377,   545,   428,    27,
      35,   423,   136,   425,   465,    79,   465,   402,   438,   475,
     475,   145,     4,   428,   316,   149,   402,   447,   522,   523,
     189,   404,    18,   438,    20,    95,    11,   329,    20,     0,
     199,   200,   447,    18,     4,   465,   466,   186,   421,     5,
     831,   190,     8,     9,   466,   475,   123,   477,    11,   119,
      20,     4,     5,   123,    17,   633,     4,   190,    24,   187,
     188,   194,   195,   191,   192,   198,   199,    20,    21,     6,
     495,   495,    20,   503,     6,   505,    18,   507,   380,   509,
     382,    21,   465,   878,   686,    11,     6,   511,    54,   526,
     514,    17,   475,   548,   477,   190,    67,    68,   193,     8,
       9,   362,   363,    74,     6,    76,   367,    78,   830,     5,
     901,    20,     8,     9,   375,   628,   870,    20,   877,    27,
     503,    92,   505,    94,   507,    20,   509,    26,    27,    28,
       4,   526,    11,    20,   348,    15,   855,   856,   615,    18,
     526,    20,   477,   404,    67,    68,     4,     5,   362,   363,
     574,    74,   547,   367,    11,   377,     6,     8,     9,   589,
     421,   375,    13,     8,     9,   595,     6,   628,   503,    92,
     505,     9,   507,    24,   509,    20,   606,   572,   347,   348,
       5,   611,   931,     8,     9,   615,   616,   617,   618,   619,
     404,     6,   629,    19,     6,   625,   626,   627,   628,   777,
     778,   656,   617,    54,   465,   629,     6,   421,   685,   686,
     629,     8,     9,   690,   475,   692,   477,   124,     8,     9,
       6,    47,     6,   686,   687,     8,     9,   690,    20,   692,
      20,     4,   698,   698,   695,   618,   619,    20,   111,   628,
      66,     4,   503,   629,   505,   628,   507,    73,   509,     4,
       5,   465,     9,     0,   176,   685,   686,   687,   180,   689,
     690,   475,   692,   477,    20,   695,    92,   849,   698,     8,
       9,   686,     8,     9,    20,   577,   111,    13,   744,   744,
     115,    20,     4,     5,   183,   184,   185,   717,    24,   503,
     116,   505,   716,   507,    24,   509,   465,   716,   728,    20,
     363,     0,    20,    50,   367,   686,    20,   688,    20,   690,
      20,   692,   695,   728,   744,   698,     4,     5,    54,   190,
      67,    68,    96,   194,   195,     6,   152,    74,   717,    76,
      50,    78,    79,   107,    11,   109,   169,   111,   112,    69,
       4,     5,     4,     5,    91,    92,     6,    94,   743,    96,
      80,    50,   934,   816,   187,   188,     6,   190,   191,   192,
     107,   744,   109,    93,   111,   112,   790,   628,    67,    68,
       6,   790,   674,     6,     6,    74,     6,    76,   881,    78,
      79,     4,     5,   187,   188,   809,   816,   191,   192,     4,
       5,     7,    91,    92,   616,    94,     6,    96,   187,   188,
     830,   190,   191,   192,   375,     4,     5,   831,   107,     6,
     109,   186,   111,   112,   628,   190,    48,    49,   587,   194,
     195,    12,   107,   809,   109,    57,   111,   112,   858,    18,
     860,   861,     6,   404,   695,    20,   858,   698,   860,     6,
     170,    73,   196,   186,     6,   831,   189,   190,    80,     6,
     193,   194,   195,   183,   623,    69,     4,     5,    14,     5,
      16,     6,     8,     9,   686,     5,    98,     6,   690,   186,
     692,    85,   189,   190,   106,   192,   193,   901,   195,    93,
      74,   695,   901,   744,   698,   186,   187,   188,   189,   190,
     191,   192,   193,     6,   195,    24,   933,     5,   959,     5,
       8,     9,     8,     9,   475,    20,   967,     4,     5,   933,
     142,     6,     0,     6,   933,   901,     6,   978,     4,     5,
     152,     5,    10,     6,     8,     9,   828,     4,     5,   959,
     744,   926,     5,    21,     6,     8,     9,   967,     5,   134,
      69,     8,     9,     4,     5,   159,   178,    11,   978,     4,
       5,    80,     6,   167,    20,   111,   170,     5,   190,     5,
       8,     9,     8,     9,    93,   179,     5,   869,     4,   183,
     872,    20,   186,     4,     5,   877,   959,    20,    85,    67,
      68,     6,    20,    20,   967,    44,    74,    20,    76,   198,
      78,    20,    20,   207,     5,   978,   326,     5,   158,    11,
      20,    20,     4,   159,    92,    20,    94,     5,    96,     5,
     197,    11,    11,    17,    15,   362,   363,     6,     5,   107,
     367,   109,   169,   111,   112,    18,    11,     5,   375,    20,
     186,    19,   169,   189,   190,   365,   366,   193,   194,   195,
     370,   170,     8,     9,    47,     5,    20,   377,    51,    52,
       5,    54,    20,    56,   183,    20,    20,   404,    24,    20,
      26,    27,    28,   362,   363,    11,    20,   397,   367,    24,
      20,    26,    27,    28,   421,   199,   375,    20,   207,    24,
      20,    26,    27,    28,    20,   186,   187,   188,    54,   190,
     191,   192,   193,   423,    20,   425,     5,     5,   959,    54,
       5,     4,     6,   477,     5,   404,   967,   195,     5,    54,
      27,    74,     6,     5,     5,   118,    11,   978,   465,    19,
       5,     5,   421,     8,     9,     5,    19,   698,   475,   503,
     477,   505,     5,   507,   169,   509,   466,   351,     6,    24,
      19,    26,    27,    28,    20,   959,    20,    19,     5,    20,
     402,   603,   366,   967,   526,   162,   503,   734,   505,   861,
     507,   155,   509,   377,   978,   611,   465,   227,   304,    54,
     978,   690,   385,   744,   692,   421,   475,   365,   477,    78,
     423,   444,   465,   397,    48,    49,   391,     0,   185,    12,
      12,    12,   478,    57,   197,   198,   499,   326,    -1,    -1,
      -1,    -1,    -1,    -1,   503,    -1,   505,    -1,   507,    73,
     509,    -1,   426,   427,    -1,   429,    80,   183,   184,   185,
      -1,   224,   436,   437,   227,    -1,    -1,    -1,   183,   184,
     185,    -1,    20,   447,    98,    -1,   365,   366,   183,   184,
     185,   370,   106,    32,    -1,    34,    -1,    -1,   377,    -1,
      -1,    -1,   466,    -1,    -1,    -1,    -1,    46,    -1,   589,
      48,    49,    -1,    -1,    -1,    -1,    -1,     0,   397,    57,
      -1,    -1,    -1,    62,    -1,   296,   606,    -1,   142,    68,
      -1,   628,    -1,    -1,    -1,    73,    -1,   375,   152,    -1,
      -1,    80,   295,    -1,   423,   625,   425,   627,   183,   184,
     185,    -1,   516,   517,   518,   519,    -1,    -1,    97,   312,
      98,   100,    -1,   401,   178,   104,   404,    -1,   106,    -1,
      -1,    -1,    -1,    -1,   113,    -1,   190,    -1,    -1,   628,
      -1,   545,    -1,    -1,    67,    68,    69,   466,   341,    -1,
      -1,    74,    -1,    -1,   133,    78,    -1,    -1,   695,   138,
      -1,   698,    -1,    -1,   142,    -1,   686,   378,   688,    92,
     690,    94,   692,    96,   152,    -1,    -1,    -1,   157,    -1,
      -1,    -1,    -1,    -1,   107,   589,   109,    -1,   111,   112,
      -1,   595,    -1,    -1,   472,    -1,    -1,   475,    -1,   477,
     178,    -1,   606,    -1,    -1,    -1,   695,   744,    -1,   698,
      -1,    -1,   190,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     431,   625,   626,   627,    -1,   503,    58,   505,    -1,   507,
      -1,   509,   636,    65,    -1,    -1,   514,    -1,    -1,    -1,
      -1,    -1,   646,    -1,    -1,    77,    78,    -1,   296,    -1,
      -1,   462,    -1,    -1,    -1,   744,    -1,    -1,    -1,    14,
     183,    16,    -1,    -1,    -1,    20,    -1,    -1,    -1,    -1,
     589,    -1,    -1,    -1,    -1,    -1,   595,    -1,   682,    -1,
      -1,    -1,   686,   687,    -1,    -1,   690,   606,   692,    -1,
     122,    -1,    -1,    -1,    -1,   127,   128,   701,   702,   703,
     704,   705,    -1,    -1,    -1,    60,   625,   626,   627,   141,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   510,   722,   512,
     531,    -1,   726,   727,   728,    -1,    -1,    -1,    -1,    -1,
     378,    -1,    -1,    -1,    -1,   546,    -1,    -1,   858,    -1,
     860,   861,    -1,    -1,   555,    -1,    -1,   102,    -1,    -1,
      -1,   629,    -1,    -1,    -1,    -1,   111,   189,   190,    -1,
      -1,    -1,   194,   195,   575,    -1,   121,   686,   687,    -1,
      -1,   690,    -1,   692,    -1,    -1,    -1,    -1,    -1,    -1,
      14,    -1,    16,   431,    -1,    -1,    -1,    -1,   792,    -1,
     794,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     155,    -1,    -1,    -1,   159,    -1,    -1,   162,    -1,    -1,
      -1,    -1,   816,    -1,   462,    -1,    -1,    -1,    -1,    -1,
     698,    -1,   959,    -1,    -1,    -1,    60,    -1,    -1,    -1,
     967,   186,    -1,   644,   189,   190,    -1,   648,   193,   194,
     195,   978,    -1,   847,    -1,    -1,   850,   851,    -1,   660,
      -1,    -1,    -1,    -1,   377,    -1,    -1,   861,    -1,    -1,
      -1,    -1,   673,    -1,    -1,    58,   744,    -1,   102,    -1,
     959,    -1,    65,   666,   667,   668,   669,   111,   967,    -1,
      -1,    -1,    -1,   531,    77,    78,    -1,   121,    -1,   978,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   816,   546,   710,
     711,    -1,    -1,   714,    -1,    -1,    -1,   555,   719,   720,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   729,    -1,
      -1,   155,    -1,    -1,    -1,   159,    -1,   575,   162,   122,
      -1,    -1,    -1,    -1,   127,   128,    -1,    -1,    -1,   858,
      -1,   860,   861,    -1,    -1,    -1,    -1,    -1,   141,    -1,
      -1,    -1,   186,   831,   477,   189,   190,    -1,    -1,   193,
     194,   195,    -1,    -1,   968,    -1,    -1,    -1,    -1,    58,
      -1,    -1,    -1,    -1,    -1,    -1,    65,    -1,   771,    -1,
     503,    -1,   505,   987,   507,    -1,   509,    -1,    77,    78,
      -1,    -1,    -1,    -1,    -1,    -1,   644,   190,    -1,    -1,
     648,   194,   195,    -1,    -1,    -1,    -1,   818,    -1,    -1,
      -1,    -1,   660,    -1,    -1,   808,    -1,   810,    -1,    -1,
      -1,    -1,    -1,   901,   835,   673,    -1,    -1,    -1,    -1,
      -1,    -1,     6,   122,    -1,   846,    -1,    -1,   127,   128,
      14,   852,    16,    -1,    -1,    -1,    -1,   840,    -1,    -1,
      -1,    25,   141,    -1,    -1,    -1,    -1,   868,    -1,    -1,
     871,    -1,   710,   711,    -1,    -1,   714,    -1,    -1,    -1,
      -1,   719,   720,    47,    48,   886,   887,   888,   889,   890,
      -1,   729,    -1,    -1,    -1,    -1,    -1,   898,   899,   900,
      -1,    -1,    66,    -1,    -1,    69,    -1,   186,   187,   188,
     189,   190,   191,   192,   193,   194,   195,    -1,    -1,    -1,
      -1,    -1,    86,   924,   925,    -1,    -1,    -1,    92,    -1,
      -1,    -1,    -1,    -1,    32,    -1,    34,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   946,    -1,    -1,    46,   950,
     114,    -1,   116,    -1,   118,   119,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    62,    -1,    -1,    -1,    -1,    -1,
      68,    -1,    -1,   686,    -1,    -1,   689,   690,    -1,   692,
     818,    -1,   983,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     991,     0,    -1,    -1,    -1,   159,    -1,   835,    -1,    97,
      -1,    -1,   100,    -1,    -1,    14,   104,    16,   846,   173,
      -1,    20,    -1,    -1,   852,   113,    -1,    -1,   182,    -1,
      29,    -1,   186,   187,   188,    -1,   190,   191,   192,   193,
     868,    -1,    -1,   871,    -1,   133,    -1,    -1,    -1,    -1,
     138,    -1,    51,    52,    -1,    -1,    -1,    -1,   886,   887,
     888,   889,   890,    -1,    -1,    -1,    -1,    -1,    67,   157,
     898,   899,   900,    72,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    83,    -1,    -1,    -1,    87,    -1,
      -1,    90,    91,    -1,    93,    -1,   924,   925,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   111,    -1,    -1,    -1,    -1,    -1,   946,   118,
     119,    -1,   950,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     129,   130,    -1,    -1,    -1,   134,   135,   136,   137,    -1,
      -1,    -1,    -1,    -1,   143,   144,   145,    -1,    -1,    -1,
     149,    -1,    -1,    -1,    -1,   983,    -1,    -1,    -1,   158,
     159,    -1,    -1,   991,    -1,    -1,    -1,    -1,   167,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   177,    -1,
     179,    -1,   181,    -1,    -1,    -1,    -1,   186,   187,   188,
     189,   190,   191,   192,   193,   194,   195,     6,    -1,     8,
       9,    -1,    -1,    -1,    -1,    14,    -1,    16,    -1,    -1,
      -1,    20,    -1,    -1,    -1,    -1,    25,    -1,    -1,    -1,
      -1,    30,    31,    -1,    -1,    -1,    -1,    36,    37,    38,
      39,    40,    41,    42,    -1,    -1,    -1,    -1,    47,    48,
      -1,    -1,    -1,    -1,    -1,    -1,    55,    56,    57,    58,
      -1,    60,    -1,    -1,    63,    64,    65,    66,    -1,    -1,
      -1,    70,    71,    -1,    -1,    -1,    -1,    -1,    77,    78,
      -1,    -1,    -1,    -1,    -1,    84,    -1,    86,    -1,    88,
      -1,    90,    -1,    92,    -1,    -1,    -1,    96,    -1,    98,
      99,    -1,   101,   102,   103,    -1,   105,   106,   107,   108,
     109,   110,   111,   112,    -1,   114,   115,   116,   117,   118,
     119,    -1,   121,   122,    -1,    -1,   125,    -1,   127,   128,
      -1,    -1,    -1,   132,    -1,    -1,    -1,    -1,    -1,    -1,
     139,   140,   141,   142,    -1,    -1,    -1,   146,   147,   148,
      -1,   150,   151,    -1,   153,   154,   155,   156,    -1,    -1,
     159,   160,    -1,   162,   163,   164,    -1,    -1,    -1,    -1,
      -1,   170,   171,   172,   173,   174,   175,    -1,    -1,   178,
      -1,    -1,    -1,   182,    -1,    -1,    -1,   186,   187,   188,
     189,   190,   191,   192,   193,   194,   195,   196,    -1,   198,
     199,   200,     6,    -1,     8,     9,    -1,    -1,    -1,    -1,
      14,    -1,    16,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    25,    -1,    -1,    -1,    -1,    30,    31,    -1,    -1,
      -1,    -1,    36,    37,    38,    39,    40,    41,    42,    -1,
      -1,    -1,    -1,    47,    48,    -1,    -1,    -1,    -1,    -1,
      -1,    55,    56,    57,    58,    -1,    60,    -1,    -1,    63,
      64,    65,    66,    -1,    -1,    -1,    70,    71,    -1,    -1,
      -1,    -1,    -1,    77,    78,    -1,    -1,    -1,    -1,    -1,
      84,    -1,    86,    -1,    88,    -1,    90,    -1,    92,    -1,
      -1,    -1,    96,    -1,    98,    99,    -1,   101,   102,   103,
      -1,   105,   106,   107,   108,   109,   110,   111,   112,    -1,
     114,   115,   116,   117,   118,   119,    -1,   121,   122,    -1,
      -1,   125,    -1,   127,   128,    -1,    -1,    -1,   132,    -1,
      -1,    -1,    -1,    -1,    -1,   139,   140,   141,   142,    -1,
      -1,    -1,   146,   147,   148,    -1,   150,   151,    -1,   153,
     154,   155,   156,    -1,    -1,   159,   160,    -1,   162,   163,
     164,    -1,    -1,    -1,    -1,    -1,   170,   171,   172,   173,
     174,   175,    -1,    -1,   178,    -1,    -1,    -1,   182,    -1,
      -1,    -1,   186,   187,   188,   189,   190,   191,   192,   193,
     194,   195,   196,    -1,   198,   199,   200,     6,    -1,     8,
       9,    -1,    -1,    -1,    -1,    14,    -1,    16,    -1,    -1,
      -1,    20,    -1,    -1,    -1,    -1,    25,    -1,    -1,    -1,
      -1,    30,    31,    -1,    -1,    -1,    -1,    36,    37,    38,
      39,    40,    41,    42,    -1,    -1,    -1,    -1,    47,    48,
      -1,    -1,    -1,    -1,    -1,    -1,    55,    56,    57,    58,
      -1,    -1,    -1,    -1,    63,    64,    65,    66,    -1,    -1,
      -1,    70,    71,    -1,    -1,    -1,    -1,    -1,    77,    78,
      -1,    -1,    -1,    -1,    -1,    84,    -1,    86,    -1,    88,
      -1,    90,    -1,    92,    -1,    -1,    -1,    96,    -1,    98,
      99,    -1,   101,    -1,   103,    -1,   105,   106,   107,   108,
     109,   110,   111,   112,    -1,   114,   115,   116,   117,   118,
     119,    -1,    -1,   122,    -1,    -1,   125,    -1,   127,   128,
      -1,    -1,    -1,   132,    -1,    -1,    -1,    -1,    -1,    -1,
     139,   140,   141,   142,    -1,    -1,    -1,   146,   147,   148,
      -1,   150,   151,    -1,   153,   154,    -1,   156,    -1,    -1,
     159,   160,    -1,    -1,   163,   164,    -1,    -1,    -1,    -1,
      -1,   170,   171,   172,   173,   174,   175,    -1,    -1,   178,
      -1,    -1,    -1,   182,    -1,    -1,    -1,   186,   187,   188,
     189,   190,   191,   192,   193,   194,   195,   196,    -1,   198,
     199,   200,     6,    -1,     8,     9,    10,    -1,    -1,    -1,
      14,    -1,    16,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    25,    -1,    -1,    -1,    -1,    30,    31,    -1,    -1,
      -1,    -1,    36,    37,    38,    39,    40,    41,    42,    -1,
      -1,    -1,    -1,    47,    48,    -1,    -1,    -1,    -1,    -1,
      -1,    55,    56,    57,    58,    -1,    -1,    -1,    -1,    63,
      64,    65,    66,    -1,    -1,    -1,    70,    71,    -1,    -1,
      -1,    -1,    -1,    77,    78,    -1,    -1,    -1,    -1,    -1,
      84,    -1,    86,    -1,    88,    -1,    90,    -1,    92,    -1,
      -1,    -1,    96,    -1,    98,    99,    -1,   101,    -1,   103,
      -1,   105,   106,   107,   108,   109,   110,   111,   112,    -1,
     114,   115,   116,   117,   118,   119,    -1,    -1,   122,    -1,
      -1,   125,    -1,   127,   128,    -1,    -1,    -1,   132,    -1,
      -1,    -1,    -1,    -1,    -1,   139,   140,   141,   142,    -1,
      -1,    -1,   146,   147,   148,    -1,   150,   151,    -1,   153,
     154,    -1,   156,    -1,    -1,   159,   160,    -1,    -1,   163,
     164,    -1,    -1,    -1,    -1,    -1,   170,   171,   172,   173,
     174,   175,    -1,    -1,   178,    -1,    -1,    -1,   182,    -1,
      -1,    -1,   186,   187,   188,   189,   190,   191,   192,   193,
     194,   195,   196,    -1,   198,   199,   200,     6,    -1,     8,
       9,    -1,    -1,    -1,    -1,    14,    -1,    16,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    25,    -1,    -1,    -1,
      -1,    30,    31,    -1,    -1,    -1,    -1,    36,    37,    38,
      39,    40,    41,    42,    -1,    -1,    -1,    -1,    47,    48,
      -1,    -1,    -1,    -1,    -1,    -1,    55,    56,    57,    58,
      -1,    -1,    -1,    -1,    63,    64,    65,    66,    -1,    -1,
      -1,    70,    71,    -1,    -1,    -1,    -1,    -1,    77,    78,
      -1,    -1,    -1,    -1,    -1,    84,    -1,    86,    87,    88,
      -1,    90,    -1,    92,    -1,    -1,    -1,    96,    -1,    98,
      99,    -1,   101,    -1,   103,    -1,   105,   106,   107,   108,
     109,   110,   111,   112,    -1,   114,   115,   116,   117,   118,
     119,    -1,    -1,   122,    -1,    -1,   125,    -1,   127,   128,
      -1,    -1,    -1,   132,    -1,    -1,    -1,    -1,    -1,    -1,
     139,   140,   141,   142,    -1,    -1,    -1,   146,   147,   148,
      -1,   150,   151,    -1,   153,   154,    -1,   156,    -1,    -1,
     159,   160,    -1,    -1,   163,   164,    -1,    -1,    -1,    -1,
      -1,   170,   171,   172,   173,   174,   175,    -1,    -1,   178,
      -1,    -1,    -1,   182,    -1,    -1,    -1,   186,   187,   188,
     189,   190,   191,   192,   193,   194,   195,   196,    -1,   198,
     199,   200,     6,    -1,     8,     9,    -1,    -1,    -1,    -1,
      14,    -1,    16,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    25,    -1,    -1,    -1,    -1,    30,    31,    -1,    -1,
      -1,    -1,    36,    37,    38,    39,    40,    41,    42,    -1,
      -1,    -1,    -1,    47,    48,    -1,    -1,    -1,    -1,    -1,
      -1,    55,    56,    57,    58,    -1,    -1,    -1,    -1,    63,
      64,    65,    66,    -1,    -1,    -1,    70,    71,    -1,    -1,
      -1,    -1,    -1,    77,    78,    -1,    -1,    -1,    -1,    -1,
      84,    -1,    86,    -1,    88,    -1,    90,    -1,    92,    -1,
      -1,    -1,    96,    -1,    98,    99,    -1,   101,    -1,   103,
      -1,   105,   106,   107,   108,   109,   110,   111,   112,    -1,
     114,   115,   116,   117,   118,   119,    -1,    -1,   122,    -1,
      -1,   125,    -1,   127,   128,    -1,    -1,    -1,   132,    -1,
      -1,    -1,    -1,    -1,    -1,   139,   140,   141,   142,    -1,
      -1,    -1,   146,   147,   148,    -1,   150,   151,    -1,   153,
     154,    -1,   156,    -1,    -1,   159,   160,    -1,    -1,   163,
     164,    -1,    -1,    -1,    -1,    -1,   170,   171,   172,   173,
     174,   175,    -1,    -1,   178,    -1,    -1,    -1,   182,    -1,
      -1,    -1,   186,   187,   188,   189,   190,   191,   192,   193,
     194,   195,   196,    -1,   198,   199,   200,     6,    -1,     8,
       9,    -1,    -1,    -1,    -1,    14,    -1,    16,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    25,    -1,    -1,    -1,
      -1,    30,    31,    -1,    -1,    -1,    -1,    36,    37,    38,
      39,    40,    41,    42,    -1,    -1,    -1,    -1,    47,    48,
      -1,    -1,    -1,    -1,    -1,    -1,    55,    56,    57,    58,
      -1,    -1,    -1,    -1,    63,    64,    65,    66,    -1,    -1,
      -1,    70,    71,    -1,    -1,    -1,    -1,    -1,    77,    78,
      -1,    -1,    -1,    -1,    -1,    84,    -1,    86,    -1,    88,
      -1,    90,    -1,    92,    -1,    -1,    -1,    96,    -1,    98,
      99,    -1,   101,    -1,   103,    -1,   105,   106,   107,   108,
     109,   110,   111,   112,    -1,   114,   115,   116,   117,   118,
     119,    -1,    -1,   122,    -1,    -1,   125,    -1,   127,   128,
      -1,    -1,    -1,   132,    -1,    -1,    -1,    -1,    -1,    -1,
     139,   140,   141,   142,    -1,    -1,    -1,   146,   147,   148,
      -1,   150,   151,    -1,   153,   154,    -1,   156,    -1,    -1,
     159,   160,    -1,    -1,   163,   164,    -1,    -1,    -1,    -1,
      -1,   170,   171,   172,   173,   174,   175,    -1,    -1,   178,
      -1,    -1,    -1,   182,    -1,    -1,    -1,   186,   187,   188,
     189,   190,   191,   192,   193,   194,   195,   196,    -1,   198,
     199,   200,     6,    -1,     8,     9,    -1,    -1,    -1,    -1,
      14,    -1,    16,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    25,    -1,    -1,    -1,    -1,    30,    31,    -1,    -1,
      -1,    -1,    36,    37,    38,    39,    40,    41,    42,    -1,
      -1,    -1,    -1,    47,    48,    -1,    -1,    -1,    -1,    -1,
      -1,    55,    56,    57,    58,    -1,    -1,    -1,    -1,    63,
      64,    65,    66,    -1,    -1,    -1,    70,    71,    -1,    -1,
      -1,    -1,    -1,    77,    78,    -1,    -1,    -1,    -1,    -1,
      84,    -1,    86,    -1,    88,    -1,    -1,    -1,    92,    -1,
      -1,    -1,    96,    -1,    98,    99,    -1,   101,    -1,   103,
      -1,   105,   106,   107,   108,   109,   110,    -1,   112,    -1,
     114,    -1,   116,   117,   118,   119,    -1,    -1,   122,    -1,
      -1,   125,    -1,   127,   128,    -1,    -1,    -1,   132,    -1,
      -1,    -1,    -1,    -1,    -1,   139,   140,   141,   142,    -1,
      -1,    -1,   146,   147,   148,    -1,   150,   151,    -1,   153,
     154,    -1,   156,    -1,    -1,   159,   160,    -1,    -1,   163,
     164,    -1,    -1,    -1,    -1,    -1,   170,   171,   172,   173,
     174,   175,    -1,    -1,   178,    -1,    -1,    -1,   182,    -1,
      -1,    -1,   186,   187,   188,   189,   190,   191,   192,   193,
     194,   195,   196,    -1,   198,   199,   200,     6,    -1,     8,
       9,    -1,    -1,    -1,    -1,    14,    -1,    16,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    25,    -1,    -1,    -1,
      -1,    30,    31,    -1,    -1,    -1,    -1,    36,    37,    38,
      39,    40,    41,    42,    -1,    -1,    -1,    -1,    47,    48,
      -1,    -1,    -1,    -1,    -1,    -1,    55,    -1,    -1,    58,
      -1,    -1,    -1,    -1,    63,    64,    65,    66,    -1,    -1,
      -1,    70,    71,    -1,    -1,    -1,    -1,    -1,    77,    78,
      -1,    -1,    -1,    -1,    -1,    84,    -1,    86,    -1,    88,
      -1,    -1,    -1,    92,    -1,    -1,    -1,    96,    -1,    98,
      99,    -1,   101,    -1,    -1,    -1,   105,   106,   107,   108,
     109,   110,    -1,   112,    -1,   114,    -1,   116,   117,   118,
     119,    -1,    -1,   122,    -1,    -1,   125,    -1,   127,   128,
      -1,    -1,    -1,   132,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   140,   141,   142,    -1,    -1,    -1,   146,   147,   148,
      -1,   150,   151,    -1,   153,   154,    -1,   156,    -1,    -1,
     159,   160,    -1,    -1,   163,   164,    -1,    -1,    -1,    -1,
      -1,   170,   171,    -1,   173,   174,   175,    -1,    -1,   178,
      -1,    -1,    -1,   182,    -1,    -1,    -1,   186,   187,   188,
      -1,   190,   191,   192,   193,   194,   195,    -1,    -1,   198,
     199,   200,     6,    -1,     8,     9,    -1,    -1,    -1,    -1,
      14,    -1,    16,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    30,    31,    -1,    -1,
      -1,    -1,    36,    37,    38,    39,    40,    41,    42,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    55,    56,    57,    58,    -1,    -1,    -1,    -1,    63,
      64,    65,    -1,    -1,    -1,    -1,    70,    71,    -1,    -1,
      -1,    -1,    -1,    77,    78,    -1,    -1,    -1,    -1,    -1,
      84,    -1,    -1,    -1,    88,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    96,    -1,    98,    99,    -1,   101,    -1,   103,
      -1,   105,   106,   107,   108,   109,   110,    -1,   112,    -1,
      -1,    -1,    -1,   117,    -1,    -1,    -1,    -1,   122,    -1,
      -1,   125,    -1,   127,   128,    -1,    -1,    -1,   132,    -1,
      -1,    -1,    -1,    -1,    -1,   139,   140,   141,   142,    -1,
      -1,    -1,   146,   147,   148,    -1,   150,   151,    -1,   153,
     154,    -1,   156,    -1,    -1,    -1,   160,    -1,    -1,   163,
     164,    -1,    -1,    -1,    -1,    -1,   170,   171,   172,    -1,
     174,   175,    -1,     6,   178,     8,     9,    -1,    -1,    -1,
      -1,    14,    -1,    16,   188,   189,   190,    -1,   192,    -1,
     194,   195,   196,    -1,   198,   199,   200,    30,    31,    -1,
      -1,    -1,    -1,    36,    37,    38,    39,    40,    41,    42,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    55,    -1,    -1,    58,    -1,    -1,    -1,    -1,
      63,    64,    65,    -1,    -1,    -1,    -1,    70,    71,    -1,
      -1,    -1,    -1,    -1,    77,    78,    -1,    -1,    -1,    -1,
      -1,    84,    -1,    -1,    -1,    88,    89,    -1,    -1,    -1,
      -1,    -1,    -1,    96,    -1,    98,    99,    -1,   101,    -1,
      -1,    -1,   105,   106,   107,   108,   109,   110,    -1,   112,
      -1,    -1,    -1,    -1,   117,    -1,    -1,    -1,    -1,   122,
      -1,    -1,   125,    -1,   127,   128,    -1,    -1,    -1,   132,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   140,   141,   142,
      -1,    -1,    -1,   146,   147,   148,    -1,   150,   151,    -1,
     153,   154,    -1,   156,    -1,    -1,    -1,   160,    -1,    -1,
     163,   164,    -1,    -1,    -1,    -1,    -1,   170,   171,    -1,
      -1,   174,   175,   176,     6,   178,     8,     9,    10,    -1,
      -1,    13,    14,    -1,    16,    -1,    -1,   190,    -1,   192,
      -1,   194,   195,    -1,    -1,   198,   199,   200,    30,    31,
      -1,    -1,    -1,    -1,    36,    37,    38,    39,    40,    41,
      42,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    55,    -1,    -1,    58,    -1,    -1,    -1,
      -1,    63,    64,    65,    -1,    -1,    -1,    -1,    70,    71,
      -1,    -1,    -1,    -1,    -1,    77,    78,    -1,    -1,    -1,
      -1,    -1,    84,    -1,    -1,    -1,    88,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    96,    -1,    98,    99,    -1,   101,
      -1,    -1,    -1,   105,   106,   107,   108,   109,   110,    -1,
     112,    -1,    -1,    -1,    -1,   117,    -1,    -1,    -1,    -1,
     122,    -1,    -1,   125,    -1,   127,   128,    -1,    -1,    -1,
     132,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   140,   141,
     142,    -1,    -1,    -1,   146,   147,   148,    -1,   150,   151,
      -1,   153,   154,    -1,   156,    -1,    -1,    -1,   160,    -1,
      -1,   163,   164,    -1,    -1,    -1,    -1,    -1,   170,   171,
      -1,    -1,   174,   175,    -1,     6,   178,     8,     9,    10,
      -1,    -1,    -1,    14,    -1,    16,    -1,    -1,   190,    -1,
     192,    -1,   194,   195,    -1,    -1,   198,   199,   200,    30,
      31,    -1,    -1,    -1,    -1,    36,    37,    38,    39,    40,
      41,    42,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    55,    -1,    -1,    58,    -1,    -1,
      -1,    -1,    63,    64,    65,    -1,    -1,    -1,    -1,    70,
      71,    -1,    -1,    -1,    -1,    -1,    77,    78,    -1,    -1,
      -1,    -1,    -1,    84,    -1,    -1,    -1,    88,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    96,    -1,    98,    99,    -1,
     101,    -1,    -1,    -1,   105,   106,   107,   108,   109,   110,
      -1,   112,    -1,    -1,    -1,    -1,   117,    -1,    -1,    -1,
      -1,   122,    -1,    -1,   125,    -1,   127,   128,    -1,    -1,
      -1,   132,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   140,
     141,   142,    -1,    -1,    -1,   146,   147,   148,    -1,   150,
     151,    -1,   153,   154,    -1,   156,    -1,    -1,    -1,   160,
      -1,    -1,   163,   164,    -1,    -1,    -1,    -1,    -1,   170,
     171,    -1,    -1,   174,   175,    -1,     6,   178,     8,     9,
      -1,    -1,    -1,    13,    14,    -1,    16,    -1,    -1,   190,
      -1,   192,    -1,   194,   195,    -1,    -1,   198,   199,   200,
      30,    31,    -1,    -1,    -1,    -1,    36,    37,    38,    39,
      40,    41,    42,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    55,    -1,    -1,    58,    -1,
      -1,    -1,    -1,    63,    64,    65,    -1,    -1,    -1,    -1,
      70,    71,    -1,    -1,    -1,    -1,    -1,    77,    78,    -1,
      -1,    -1,    -1,    -1,    84,    -1,    -1,    -1,    88,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    96,    -1,    98,    99,
      -1,   101,    -1,    -1,    -1,   105,   106,   107,   108,   109,
     110,    -1,   112,    -1,    -1,    -1,    -1,   117,    -1,    -1,
      -1,    -1,   122,    -1,    -1,   125,    -1,   127,   128,    -1,
      -1,    -1,   132,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     140,   141,   142,    -1,    -1,    -1,   146,   147,   148,    -1,
     150,   151,    -1,   153,   154,    -1,   156,    -1,    -1,    -1,
     160,    -1,    -1,   163,   164,    -1,    -1,    -1,    -1,    -1,
     170,   171,    -1,    -1,   174,   175,    -1,     6,   178,     8,
       9,    -1,    -1,    -1,    -1,    14,    -1,    16,    -1,    -1,
     190,    -1,   192,    -1,   194,   195,    -1,    -1,   198,   199,
     200,    30,    31,    -1,    -1,    -1,    -1,    36,    37,    38,
      39,    40,    41,    42,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    55,    -1,    -1,    58,
      -1,    -1,    -1,    -1,    63,    64,    65,    -1,    -1,    -1,
      -1,    70,    71,    -1,    -1,    -1,    -1,    -1,    77,    78,
      -1,    -1,    -1,    -1,    -1,    84,    -1,    -1,    -1,    88,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    96,    -1,    98,
      99,    -1,   101,    -1,    -1,    -1,   105,   106,   107,   108,
     109,   110,    -1,   112,    -1,    -1,    -1,    -1,   117,    -1,
      -1,    -1,    -1,   122,    -1,    -1,   125,    -1,   127,   128,
      -1,    -1,    -1,   132,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   140,   141,   142,    -1,    -1,    -1,   146,   147,   148,
      -1,   150,   151,    -1,   153,   154,    -1,   156,    -1,    -1,
      -1,   160,    -1,    -1,   163,   164,    -1,    -1,    -1,    -1,
      -1,   170,   171,     6,    -1,   174,   175,    10,    11,   178,
      -1,    14,    -1,    16,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   190,    -1,   192,    -1,   194,   195,    30,    31,   198,
     199,   200,    -1,    36,    37,    38,    39,    40,    41,    42,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    55,    -1,    -1,    58,    -1,    -1,    -1,    -1,
      63,    64,    65,    -1,    -1,    -1,    -1,    70,    71,    -1,
      -1,    -1,    -1,    -1,    77,    78,    -1,    -1,    -1,    -1,
      -1,    84,    -1,    -1,    -1,    88,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    96,    -1,    98,    99,    -1,   101,    -1,
      -1,    -1,   105,   106,   107,   108,   109,   110,    -1,   112,
      -1,    -1,    -1,    -1,   117,    -1,    -1,    -1,    -1,   122,
      -1,    -1,   125,    -1,   127,   128,    -1,    -1,    -1,   132,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   140,   141,   142,
      -1,    -1,    -1,   146,   147,   148,    -1,   150,   151,    -1,
     153,   154,    -1,   156,    -1,    -1,    -1,   160,    -1,    -1,
     163,   164,    -1,    -1,    -1,    -1,    -1,   170,   171,     6,
      -1,   174,   175,    -1,    -1,   178,    -1,    14,    -1,    16,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   190,    -1,   192,
      -1,   194,   195,    30,    31,   198,   199,   200,    -1,    36,
      37,    38,    39,    40,    41,    42,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    55,    -1,
      -1,    58,    -1,    -1,    -1,    -1,    63,    64,    65,    -1,
      -1,    -1,    -1,    70,    71,    -1,    -1,    -1,    -1,    -1,
      77,    78,    -1,    -1,    -1,    -1,    -1,    84,    -1,    -1,
      -1,    88,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    96,
      -1,    98,    99,    -1,   101,    -1,    -1,    -1,   105,   106,
     107,   108,   109,   110,    -1,   112,    -1,    -1,    -1,     6,
     117,    -1,    -1,    -1,    -1,   122,    -1,    14,   125,    16,
     127,   128,    -1,    -1,    -1,   132,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   140,   141,   142,    -1,    -1,    -1,   146,
     147,   148,    -1,   150,   151,    -1,   153,   154,    -1,   156,
      47,    -1,    -1,   160,    -1,    -1,   163,   164,    -1,    56,
      -1,    -1,    -1,   170,   171,     6,    -1,   174,   175,    66,
      -1,   178,    -1,    14,    -1,    16,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   190,    25,   192,    -1,   194,   195,    86,
      -1,   198,   199,   200,    -1,    92,    -1,    -1,    -1,    -1,
       6,    -1,    -1,    -1,    -1,    -1,    47,    48,    14,    -1,
      16,    -1,    -1,    -1,   111,    -1,    -1,    -1,    -1,   116,
      -1,   118,   119,    -1,    -1,    66,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    58,    -1,    -1,    -1,
      -1,    47,    48,    65,    -1,    86,    -1,    -1,    -1,     6,
      -1,    92,    -1,    -1,    -1,    77,    78,    14,    -1,    16,
      66,    -1,   159,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   114,    -1,   116,   173,   118,   119,    -1,
      86,    -1,    -1,    -1,    -1,    -1,    92,    -1,    -1,   186,
      47,    48,   189,   190,    -1,    -1,   193,   194,   195,   196,
     122,   198,   199,   200,    -1,   127,   128,    -1,    -1,    66,
     116,    -1,   118,   119,    -1,    -1,    -1,    -1,   159,   141,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    86,
      -1,    -1,   173,    -1,    -1,    92,    -1,    -1,    -1,    -1,
      -1,   182,    -1,    -1,    -1,   186,   187,   188,    -1,   190,
     191,   192,   193,   159,    -1,    -1,    -1,    -1,    -1,   116,
      -1,   118,   119,    -1,   186,   187,   188,   173,   190,   191,
     192,   193,   194,   195,    -1,    14,   182,    16,    -1,    -1,
     186,   187,   188,    -1,   190,   191,   192,   193,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    21,
      -1,    -1,   159,    -1,    -1,    -1,    -1,    -1,    47,    -1,
      32,    -1,    34,    -1,    -1,    -1,   173,    56,    -1,    58,
      -1,    -1,    -1,    -1,    46,   182,    65,    66,    -1,   186,
     187,   188,    -1,   190,   191,   192,   193,    -1,    77,    78,
      62,    -1,    -1,    -1,    -1,    -1,    68,    86,    -1,    -1,
      -1,    -1,    -1,    92,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   111,    -1,    -1,    97,    -1,   116,   100,   118,
     119,    -1,   104,   122,    -1,    -1,    -1,    -1,   127,   128,
      -1,   113,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   141,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   133,    -1,    -1,    -1,    -1,   138,    -1,    -1,    -1,
     159,    -1,    -1,    -1,    -1,    14,    -1,    16,    -1,    -1,
      -1,    20,    -1,    -1,   173,   157,    -1,    -1,    -1,    -1,
      29,    -1,    -1,    -1,    -1,    -1,    -1,   186,   187,   188,
     189,   190,   191,   192,   193,   194,   195,   196,    -1,   198,
     199,   200,    51,    52,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    62,    -1,    -1,    -1,    -1,    67,    -1,
      -1,    -1,    -1,    72,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    83,    -1,    -1,    -1,    87,    -1,
      -1,    90,    91,    -1,    93,    -1,    -1,    -1,    97,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   111,    -1,    -1,    -1,    -1,    -1,    -1,   118,
     119,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     129,   130,    -1,    -1,    -1,   134,   135,   136,   137,    -1,
      -1,    -1,    -1,    -1,   143,   144,   145,    -1,    -1,    -1,
     149,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   158,
     159,    14,    -1,    16,    -1,    -1,    -1,    20,   167,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    29,    -1,   177,    -1,
     179,    -1,   181,    -1,    -1,    -1,    -1,   186,   187,   188,
     189,   190,   191,   192,   193,   194,   195,    -1,    51,    52,
      -1,    -1,    -1,    -1,    -1,    14,    59,    16,    -1,    -1,
      -1,    -1,    -1,    -1,    67,    -1,    -1,    -1,    -1,    72,
      -1,    -1,    -1,    76,    -1,    -1,    -1,    -1,    -1,    -1,
      83,    -1,    -1,    -1,    87,    -1,    -1,    90,    91,    -1,
      93,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    58,
      -1,    -1,    -1,    -1,    -1,    -1,    65,    -1,   111,    -1,
      -1,    -1,    -1,    -1,    -1,   118,   119,    -1,    77,    78,
      -1,    -1,    -1,    -1,    -1,    -1,   129,   130,    -1,    -1,
      -1,   134,   135,   136,   137,    -1,    -1,    -1,    -1,    -1,
     143,   144,   145,    14,    -1,    16,   149,    -1,    -1,    20,
      -1,    -1,   111,    -1,    -1,   158,   159,    -1,    29,    -1,
      -1,    -1,    -1,   122,   167,    -1,    -1,    -1,   127,   128,
      -1,    -1,    -1,    -1,   177,    -1,   179,    -1,   181,    -1,
      51,    52,   141,   186,   187,   188,   189,   190,   191,   192,
     193,   194,   195,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     159,    72,    -1,    -1,    75,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    83,    -1,    -1,    -1,    87,    -1,    -1,    90,
      91,    -1,    93,    -1,    -1,    -1,    -1,   186,   187,   188,
     189,   190,   191,   192,   193,   194,   195,    -1,    -1,    -1,
     111,    -1,    -1,    -1,    -1,    -1,    -1,   118,   119,    -1,
      -1,    21,    -1,    -1,    -1,    -1,    -1,    -1,   129,   130,
      -1,    -1,    32,   134,    34,   136,   137,    -1,    -1,    -1,
      -1,    -1,   143,   144,   145,    14,    46,    16,   149,    -1,
      -1,    20,    -1,    -1,    -1,    -1,    -1,    -1,   159,    -1,
      29,    -1,    62,    -1,    -1,   166,   167,    -1,    68,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   177,    -1,   179,    -1,
     181,    -1,    51,    52,    -1,   186,   187,   188,   189,   190,
     191,   192,   193,   194,   195,    -1,    -1,    97,    -1,    -1,
     100,    -1,    -1,    72,   104,    -1,    75,    -1,    -1,    -1,
      -1,    -1,    -1,   113,    83,    -1,    85,    -1,    87,    -1,
      -1,    -1,    91,    -1,    93,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   133,    -1,    -1,    -1,    -1,   138,    -1,
      -1,    -1,   111,    -1,    -1,    -1,    -1,    -1,    -1,   118,
     119,    -1,    -1,    -1,    -1,    -1,    -1,   157,    -1,    -1,
     129,   130,    -1,    -1,    -1,   134,    -1,   136,   137,    -1,
      -1,    -1,    -1,    -1,   143,   144,   145,    -1,    -1,    -1,
     149,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     159,    14,    -1,    16,    -1,    -1,   165,    20,   167,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    29,    -1,   177,    -1,
     179,    -1,   181,    -1,    -1,    -1,    -1,   186,   187,   188,
     189,   190,   191,   192,   193,   194,   195,    -1,    51,    52,
      -1,    -1,    -1,    -1,    -1,    -1,    59,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    72,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      83,    -1,    85,    -1,    87,    -1,    -1,    -1,    91,    -1,
      93,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   111,    -1,
      -1,    -1,    -1,    -1,    -1,   118,   119,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   129,   130,    -1,    -1,
      -1,   134,    -1,   136,   137,    -1,    -1,    -1,    -1,    -1,
     143,   144,   145,    14,    -1,    16,   149,    -1,    -1,    20,
      -1,    -1,    -1,    -1,    -1,    -1,   159,    -1,    29,    -1,
      -1,    -1,   165,    -1,   167,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   177,    -1,   179,    -1,   181,    -1,
      51,    52,    -1,   186,   187,   188,   189,   190,   191,   192,
     193,   194,   195,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    72,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    83,    -1,    85,    -1,    87,    -1,    -1,    -1,
      91,    -1,    93,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     111,    -1,    -1,    -1,    -1,    -1,    -1,   118,   119,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   129,   130,
      -1,    -1,    -1,   134,    -1,   136,   137,    -1,    -1,    -1,
      -1,    -1,   143,   144,   145,    -1,    -1,    -1,   149,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   159,    14,
      -1,    16,    -1,    -1,   165,    20,   167,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    29,    -1,   177,    -1,   179,    -1,
     181,    -1,    -1,    -1,    -1,   186,   187,   188,   189,   190,
     191,   192,   193,   194,   195,    -1,    51,    52,    -1,    -1,
      -1,    -1,    -1,    -1,    59,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    72,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    83,    -1,
      -1,    -1,    87,    -1,    -1,    90,    91,    -1,    93,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   111,    -1,    -1,    -1,
      -1,    -1,    -1,   118,   119,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   129,   130,    -1,    -1,    -1,   134,
      -1,   136,   137,    -1,    -1,    -1,    -1,    -1,   143,   144,
     145,    14,    -1,    16,   149,    -1,    -1,    20,    -1,    -1,
      -1,    -1,    -1,    -1,   159,    -1,    29,    -1,    -1,    -1,
      -1,    -1,   167,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   177,    -1,   179,    -1,   181,    -1,    51,    52,
      -1,   186,   187,   188,   189,   190,   191,   192,   193,   194,
     195,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    72,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      83,    -1,    -1,    -1,    87,    -1,    -1,    90,    91,    -1,
      93,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   111,    -1,
      -1,    -1,    -1,    -1,    -1,   118,   119,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   129,   130,    -1,    -1,
      -1,   134,    -1,   136,   137,    -1,    -1,    -1,    -1,    -1,
     143,   144,   145,    14,    -1,    16,   149,    -1,    -1,    20,
      -1,    -1,    -1,    -1,    -1,    -1,   159,    -1,    29,    -1,
      -1,    -1,    -1,    -1,   167,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   177,    -1,   179,    -1,   181,    -1,
      51,    52,    -1,   186,   187,   188,   189,   190,   191,   192,
     193,   194,   195,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    72,    -1,    -1,    75,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    83,    -1,    -1,    -1,    87,    -1,    -1,    -1,
      91,    -1,    93,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     111,    -1,    -1,    -1,    -1,    -1,    -1,   118,   119,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   129,   130,
      -1,    -1,    -1,   134,    -1,   136,   137,    -1,    -1,    -1,
      -1,    -1,   143,   144,   145,    -1,    -1,    -1,   149,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   159,    14,
      -1,    16,    -1,    -1,    -1,    20,   167,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    29,    -1,   177,    -1,   179,    -1,
     181,    -1,    -1,    -1,    -1,   186,   187,   188,   189,   190,
     191,   192,   193,   194,   195,    -1,    51,    52,    -1,    -1,
      -1,    -1,    -1,    -1,    59,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    72,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    83,    -1,
      -1,    -1,    87,    -1,    -1,    -1,    91,    -1,    93,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   111,    -1,    -1,    -1,
      -1,    -1,    -1,   118,   119,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   129,   130,    -1,    -1,    -1,   134,
      -1,   136,   137,    -1,    -1,    -1,    -1,    -1,   143,   144,
     145,    14,    -1,    16,   149,    -1,    -1,    20,    -1,    -1,
      -1,    -1,    -1,    -1,   159,    -1,    29,    -1,    -1,    -1,
      -1,    -1,   167,    -1,    -1,    14,    -1,    16,    -1,    -1,
      -1,    -1,   177,    -1,   179,    -1,   181,    -1,    51,    52,
      -1,   186,   187,   188,   189,   190,   191,   192,   193,   194,
     195,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    72,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    58,
      83,    -1,    -1,    -1,    87,    -1,    65,    -1,    91,    -1,
      93,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    77,    78,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   111,    -1,
      -1,    -1,    -1,    -1,    -1,   118,   119,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   129,   130,    -1,    -1,
      -1,   134,   111,   136,   137,    -1,   115,    -1,    -1,    -1,
     143,   144,   145,   122,    -1,    -1,   149,    -1,   127,   128,
      -1,    -1,    -1,    -1,    -1,    -1,   159,    -1,    -1,    -1,
      -1,    -1,   141,    -1,   167,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   177,    -1,   179,    -1,   181,    -1,
     159,    -1,    -1,   186,   187,   188,   189,   190,   191,   192,
     193,   194,   195,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   186,   187,   188,
     189,   190,   191,   192,   193,   194,   195,    32,    -1,    34,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    43,    -1,
      -1,    46,    -1,    48,    49,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    57,    -1,    -1,    -1,    -1,    62,    -1,    -1,
      -1,    -1,    -1,    68,    -1,    -1,    -1,    -1,    73,    -1,
      -1,    -1,    -1,    -1,    -1,    80,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    90,    -1,    -1,    -1,    -1,
      -1,    -1,    97,    98,    -1,   100,    -1,    -1,    -1,   104,
      -1,   106,    -1,    -1,    -1,    -1,    -1,    -1,   113,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   124,
      -1,   126,    -1,    -1,    -1,    -1,    -1,    -1,   133,    -1,
      -1,    -1,    -1,   138,    -1,    -1,    -1,   142,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   152,    -1,    -1,
      -1,    -1,   157,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     165,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   178,    -1,    -1,    -1,    -1,    32,    -1,
      34,   186,   187,   188,   189,   190,   191,   192,   193,    43,
     195,    -1,    46,    -1,    48,    49,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    57,    -1,    -1,    -1,    -1,    62,    -1,
      -1,    -1,    -1,    -1,    68,    32,    -1,    34,    -1,    73,
      -1,    -1,    -1,    -1,    -1,    -1,    80,    -1,    -1,    46,
      -1,    48,    49,    -1,    -1,    -1,    90,    -1,    -1,    -1,
      57,    -1,    -1,    97,    98,    62,   100,    -1,    -1,    -1,
     104,    68,   106,    -1,    -1,    -1,    73,    -1,    -1,   113,
      -1,    -1,    -1,    80,    -1,    -1,    -1,    -1,    -1,    -1,
     124,    -1,   126,    -1,    -1,    -1,    -1,    -1,    -1,   133,
      97,    98,    -1,   100,   138,    -1,    -1,   104,   142,   106,
      -1,    -1,    -1,    -1,    -1,    -1,   113,    -1,   152,    -1,
      -1,    -1,    -1,   157,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   165,    -1,    -1,    -1,    -1,   133,    -1,    -1,    -1,
      -1,   138,    -1,    -1,   178,   142,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   152,   190,    -1,    -1,    -1,
     157,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   178,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   190
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int16 yystos[] =
{
       0,    14,    16,    20,    29,    51,    52,    62,    67,    72,
      83,    87,    90,    91,    93,    97,   111,   118,   119,   129,
     130,   134,   135,   136,   137,   143,   144,   145,   149,   158,
     159,   167,   177,   179,   181,   186,   187,   188,   189,   190,
     191,   192,   193,   194,   195,   207,   221,   232,   254,   256,
     261,   262,   264,   265,   267,   273,   276,   278,   280,   281,
     282,   283,   284,   285,   286,   287,   289,   290,   291,   292,
     299,   300,   301,   302,   303,   304,   305,   306,   309,   311,
     312,   313,   314,   317,   318,   320,   321,   323,   324,   329,
     330,   331,   333,   345,   359,   360,   361,   362,   363,   364,
     367,   368,   376,   379,   382,   385,   386,   387,   388,   389,
     390,   391,   392,   232,   285,   207,   191,   255,   265,   285,
       6,    32,    34,    43,    46,    48,    49,    57,    68,    73,
      80,    90,    98,   100,   104,   106,   113,   124,   126,   133,
     138,   142,   152,   157,   165,   178,   187,   188,   190,   191,
     192,   193,   202,   203,   204,   205,   206,   207,   208,   209,
     210,   211,   212,   238,   264,   276,   286,   342,   343,   344,
     345,   349,   351,   352,   353,   354,   356,   358,    20,    53,
      89,   176,   180,   334,   335,   336,   339,    20,   265,     6,
      20,   352,   353,   354,   358,   169,     6,    79,    79,     6,
       6,    20,   265,   207,   380,   256,   285,     6,     8,     9,
      14,    16,    20,    25,    30,    31,    36,    37,    38,    39,
      40,    41,    42,    47,    48,    55,    56,    57,    58,    63,
      64,    65,    66,    70,    71,    77,    78,    84,    86,    88,
      90,    92,    96,    98,    99,   101,   103,   105,   106,   107,
     108,   109,   110,   112,   114,   115,   116,   117,   118,   119,
     122,   125,   127,   128,   132,   139,   140,   141,   142,   146,
     147,   148,   150,   151,   153,   154,   156,   160,   163,   164,
     170,   171,   172,   173,   174,   175,   178,   182,   187,   188,
     192,   196,   198,   199,   200,   210,   213,   214,   215,   216,
     217,   218,   220,   221,   222,   223,   224,   225,   226,   227,
     228,   231,   233,   234,   245,   246,   247,   251,   253,   254,
     255,   256,   257,   258,   259,   260,   261,   263,   266,   270,
     271,   272,   273,   274,   275,   277,   278,   281,   283,   285,
     255,    79,   256,   256,   286,   383,   123,     6,    18,   235,
     236,   239,   240,   280,   283,   285,     6,   235,   235,    21,
     235,   235,     6,     4,    27,   288,     6,     4,    11,   235,
     288,    20,   177,   299,   300,   305,   299,     6,   213,   245,
     247,   253,   270,   277,   281,   294,   295,   296,   297,   299,
      20,    35,    85,   165,   177,   300,   301,     6,    20,    44,
     307,    75,   166,   302,   305,   310,   340,    20,    60,   102,
     121,   155,   162,   280,   315,   319,    20,   190,   231,   316,
     319,     4,    20,     4,    20,   288,     4,     6,    89,   176,
     192,   213,   285,    20,   255,   322,    45,    95,   119,   123,
       4,    20,    69,   325,   326,   327,   328,   334,    20,     6,
      20,   223,   225,   227,   255,   258,   274,   279,   280,   332,
     341,   299,   213,   231,   346,   347,   348,     0,   302,   376,
     379,   382,    59,    76,   302,   305,   365,   366,   371,   372,
     376,   379,   382,    20,    32,   138,    82,   131,    61,    90,
     124,   126,     6,   351,   369,   374,   375,   307,   370,   374,
     377,    20,   365,   366,   365,   366,   365,   366,   365,   366,
      15,    11,    17,   235,    11,     6,     6,     6,     6,     6,
       6,     6,   124,    80,   343,    20,     4,   206,   111,   238,
      10,   213,   350,     4,   203,   350,   344,    10,   231,   346,
     190,   204,   343,     9,   355,   357,   213,   166,   221,   285,
     245,   294,    20,    20,   335,   213,   337,    20,   223,    20,
      20,    20,    20,   265,    20,   235,    94,   161,   235,   223,
     223,    20,     6,    50,    11,   213,   245,   270,   285,   254,
     285,   254,   285,    26,   235,   268,   269,     6,   268,     6,
     235,    24,    54,   215,   216,   252,   214,   214,     7,    10,
      11,   217,    12,   219,    18,   236,     6,    20,   235,    22,
     120,   248,   249,    23,    35,   250,   252,     6,    14,    16,
     251,   285,   260,     6,   231,     6,   252,     6,     6,    11,
      20,   235,    21,   343,   204,   384,   169,   255,   223,     6,
     221,   223,    10,    13,   213,   241,   242,   243,   244,     4,
       5,    20,    21,     5,     6,   279,   280,   287,   231,   317,
     213,   229,   230,   231,   285,   287,   232,   264,   267,   276,
     286,   231,    74,   213,   270,   294,    26,    28,   183,   184,
     185,   288,   298,   168,   293,   298,     6,   298,   298,   298,
     248,   293,   250,   329,   229,     6,   265,   202,   305,   310,
      20,     6,     6,     6,     6,     6,   315,   316,   231,   285,
     213,   213,    69,   245,   213,    20,    11,     4,    20,   213,
     213,   245,     6,   134,    20,   328,    33,    81,     6,   213,
     245,   285,     4,     5,    13,     5,     4,     6,   280,   341,
     346,    20,   265,    85,   305,   365,    20,   302,   365,   372,
      20,   351,   186,   189,   190,   192,   193,   195,   373,   374,
     377,    20,   365,    20,   365,    20,   365,    20,   365,   235,
     235,   265,   350,   350,   350,   350,   224,   343,   343,   211,
       5,     4,     5,     5,     5,   158,   350,    20,   207,   288,
      11,    20,   169,   338,     4,    20,    20,    94,   161,     5,
       5,   207,   381,   197,   378,     5,     5,     5,    15,    11,
      17,    18,   223,   229,   214,   214,     6,   188,   213,   271,
     285,   214,   217,   217,   218,     6,   229,   246,   247,   251,
     253,    11,   223,     5,   229,   213,   271,   229,   115,   279,
     233,    20,   224,    21,     4,    20,   213,   169,     5,    19,
     237,    45,   213,   243,   169,   215,   216,     5,   288,    20,
      13,     4,     5,   235,   235,   235,   235,     5,   213,   247,
     294,   213,   270,   277,   191,   281,   285,   247,   295,   296,
      20,     5,   280,   285,   308,    20,   213,   213,   213,   213,
     213,    20,    20,     5,    20,    20,    20,   255,   213,   213,
     213,    11,    20,   226,     4,     5,   207,    20,     4,     5,
      20,    20,    20,    20,   235,     5,     5,     5,     4,     5,
       6,     5,    74,    27,   213,   213,     4,     5,   235,   235,
       6,     5,     5,    11,    19,     5,   251,     5,     5,     5,
       5,     5,   235,   224,   224,    20,   213,    19,   238,   259,
     213,   243,   214,   214,   231,   230,     5,    20,   307,     4,
       5,     5,     5,     5,     5,     5,     5,   169,    50,   207,
      19,   260,   238,    20,     4,     5,     5,     5,     6,   280,
     285,    20,   280,   213,   259,     4,    19,   237,   308,    20,
       5,   213,     5,     5,    20
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int16 yyr1[] =
{
       0,   201,   202,   202,   203,   203,   203,   204,   204,   204,
     204,   204,   204,   204,   204,   205,   205,   205,   205,   205,
     206,   206,   206,   207,   208,   208,   209,   209,   210,   210,
     210,   210,   211,   211,   212,   212,   212,   212,   212,   212,
     212,   212,   213,   213,   213,   213,   213,   214,   214,   215,
     216,   217,   217,   217,   217,   218,   218,   219,   220,   220,
     220,   220,   221,   221,   221,   221,   221,   221,   221,   221,
     222,   222,   222,   222,   222,   223,   223,   224,   225,   226,
     227,   227,   227,   227,   228,   228,   229,   229,   230,   230,
     230,   231,   231,   231,   231,   231,   232,   232,   233,   233,
     233,   233,   233,   233,   233,   233,   234,   234,   234,   234,
     234,   234,   234,   234,   234,   234,   234,   234,   234,   234,
     234,   234,   234,   234,   234,   234,   234,   234,   234,   234,
     234,   234,   234,   234,   234,   234,   234,   234,   234,   234,
     234,   234,   234,   234,   234,   234,   234,   234,   234,   234,
     234,   234,   234,   235,   235,   235,   235,   236,   236,   236,
     236,   237,   237,   238,   238,   239,   239,   239,   239,   239,
     240,   240,   241,   241,   241,   241,   242,   243,   243,   244,
     244,   244,   245,   245,   246,   246,   247,   247,   247,   247,
     248,   248,   249,   250,   250,   251,   251,   251,   251,   251,
     251,   251,   251,   251,   251,   251,   252,   252,   253,   253,
     254,   254,   254,   254,   255,   255,   255,   255,   256,   256,
     256,   256,   257,   257,   258,   258,   258,   258,   258,   259,
     259,   259,   259,   260,   261,   261,   262,   263,   263,   263,
     264,   265,   265,   265,   265,   266,   266,   267,   268,   268,
     269,   270,   270,   270,   270,   270,   271,   271,   271,   271,
     272,   272,   273,   273,   273,   273,   274,   274,   275,   275,
     275,   275,   275,   276,   277,   277,   277,   278,   279,   279,
     279,   280,   280,   280,   280,   280,   280,   280,   281,   281,
     281,   281,   282,   283,   284,   285,   285,   286,   287,   287,
     287,   287,   288,   289,   289,   290,   290,   291,   292,   293,
     294,   294,   295,   295,   296,   296,   296,   297,   297,   297,
     297,   297,   298,   298,   298,   298,   298,   298,   299,   299,
     299,   300,   300,   300,   300,   300,   300,   300,   300,   300,
     300,   300,   300,   300,   300,   300,   300,   300,   300,   300,
     300,   300,   300,   300,   300,   300,   300,   300,   300,   300,
     300,   300,   300,   300,   300,   300,   300,   300,   300,   300,
     300,   300,   301,   301,   301,   302,   302,   303,   303,   304,
     304,   304,   304,   305,   306,   307,   308,   308,   308,   308,
     309,   309,   309,   309,   309,   309,   309,   309,   310,   310,
     310,   311,   311,   312,   313,   313,   314,   314,   315,   315,
     316,   316,   316,   317,   318,   319,   319,   319,   319,   319,
     320,   321,   321,   322,   322,   323,   323,   323,   323,   324,
     324,   324,   325,   325,   325,   326,   326,   326,   327,   328,
     328,   329,   329,   329,   330,   331,   331,   332,   332,   333,
     334,   334,   335,   335,   336,   336,   337,   337,   338,   338,
     339,   339,   340,   341,   341,   341,   341,   342,   342,   343,
     343,   344,   344,   344,   344,   344,   344,   344,   344,   344,
     344,   344,   344,   345,   345,   345,   346,   346,   346,   346,
     346,   347,   348,   348,   349,   350,   350,   351,   351,   351,
     351,   351,   352,   352,   353,   354,   355,   355,   356,   357,
     358,   358,   358,   359,   359,   359,   359,   359,   359,   359,
     359,   359,   360,   360,   361,   362,   362,   362,   362,   362,
     363,   363,   363,   363,   363,   363,   363,   363,   363,   364,
     364,   365,   365,   365,   366,   366,   366,   367,   368,   369,
     369,   369,   370,   370,   370,   371,   371,   372,   372,   372,
     372,   373,   373,   373,   373,   373,   373,   374,   375,   375,
     376,   377,   378,   379,   380,   380,   381,   381,   382,   383,
     383,   383,   384,   385,   385,   385,   385,   386,   386,   387,
     387,   388,   388,   389,   390,   390,   391,   392
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
       3,     3,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     2,     2,     2,     3,     2,     3,     4,     1,     2,
       5,     6,     9,     2,     3,     3,     2,     2,     2,     2,
       4,     4,     4,     4,     3,     4,     4,     2,     3,     5,
       6,     2,     3,     2,     4,     3,     2,     4,     4,     3,
       2,     4,     1,     2,     2,     1,     1,     3,     2,     4,
       4,     3,     3,     2,     2,     1,     1,     3,     1,     3,
       2,     3,     4,     3,     4,     2,     2,     2,     1,     2,
       2,     4,     4,     4,     2,     3,     2,     3,     1,     1,
       1,     1,     1,     4,     3,     4,     4,     4,     4,     4,
       1,     1,     1,     1,     3,     2,     3,     3,     3,     1,
       5,     2,     1,     1,     2,     3,     3,     1,     2,     2,
       2,     2,     2,     2,     2,     2,     3,     1,     1,     5,
       1,     1,     2,     2,     3,     2,     1,     3,     2,     4,
       3,     4,     3,     1,     1,     1,     1,     2,     3,     1,
       2,     1,     1,     1,     1,     1,     4,     1,     1,     3,
       3,     1,     4,     2,     2,     3,     1,     2,     2,     3,
       1,     3,     2,     3,     2,     1,     1,     1,     1,     1,
       1,     1,     1,     4,     4,     2,     2,     3,     1,     3,
       1,     1,     2,     1,     2,     1,     2,     1,     2,     2,
       3,     3,     3,     4,     2,     2,     2,     1,     2,     2,
       2,     2,     2,     2,     1,     1,     2,     1,     2,     1,
       2,     1,     2,     2,     1,     1,     2,     2,     2,     1,
       1,     2,     1,     1,     2,     1,     2,     1,     2,     1,
       6,     1,     1,     1,     1,     1,     1,     3,     1,     3,
       3,     2,     1,     4,     1,     4,     1,     3,     3,     3,
       4,     4,     2,     1,     1,     1,     1,     3,     4,     3,
       2,     3,     4,     3,     3,     4,     3,     3
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
#line 646 "HAL_S.y"
                                { (yyval.declare_body_) = make_AAdeclareBody_declarationList((yyvsp[0].declaration_list_)); (yyval.declare_body_)->line_number = (yyloc).first_line; (yyval.declare_body_)->char_number = (yyloc).first_column;  }
#line 4189 "Parser.c"
    break;

  case 3: /* DECLARE_BODY: ATTRIBUTES _SYMB_0 DECLARATION_LIST  */
#line 647 "HAL_S.y"
                                        { (yyval.declare_body_) = make_ABdeclareBody_attributes_declarationList((yyvsp[-2].attributes_), (yyvsp[0].declaration_list_)); (yyval.declare_body_)->line_number = (yyloc).first_line; (yyval.declare_body_)->char_number = (yyloc).first_column;  }
#line 4195 "Parser.c"
    break;

  case 4: /* ATTRIBUTES: ARRAY_SPEC TYPE_AND_MINOR_ATTR  */
#line 649 "HAL_S.y"
                                            { (yyval.attributes_) = make_AAattributes_arraySpec_typeAndMinorAttr((yyvsp[-1].array_spec_), (yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4201 "Parser.c"
    break;

  case 5: /* ATTRIBUTES: ARRAY_SPEC  */
#line 650 "HAL_S.y"
               { (yyval.attributes_) = make_ABattributes_arraySpec((yyvsp[0].array_spec_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4207 "Parser.c"
    break;

  case 6: /* ATTRIBUTES: TYPE_AND_MINOR_ATTR  */
#line 651 "HAL_S.y"
                        { (yyval.attributes_) = make_ACattributes_typeAndMinorAttr((yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4213 "Parser.c"
    break;

  case 7: /* DECLARATION: NAME_ID  */
#line 653 "HAL_S.y"
                      { (yyval.declaration_) = make_AAdeclaration_nameId((yyvsp[0].name_id_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4219 "Parser.c"
    break;

  case 8: /* DECLARATION: NAME_ID ATTRIBUTES  */
#line 654 "HAL_S.y"
                       { (yyval.declaration_) = make_ABdeclaration_nameId_attributes((yyvsp[-1].name_id_), (yyvsp[0].attributes_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4225 "Parser.c"
    break;

  case 9: /* DECLARATION: _SYMB_188 _SYMB_120 MINOR_ATTR_LIST  */
#line 655 "HAL_S.y"
                                        { (yyval.declaration_) = make_ACdeclaration_labelToken_procedure_minorAttrList((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4231 "Parser.c"
    break;

  case 10: /* DECLARATION: _SYMB_188 _SYMB_120  */
#line 656 "HAL_S.y"
                        { (yyval.declaration_) = make_ADdeclaration_labelToken_procedure((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4237 "Parser.c"
    break;

  case 11: /* DECLARATION: _SYMB_189 _SYMB_76  */
#line 657 "HAL_S.y"
                       { (yyval.declaration_) = make_AEdeclaration_eventToken_event((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4243 "Parser.c"
    break;

  case 12: /* DECLARATION: _SYMB_189 _SYMB_76 MINOR_ATTR_LIST  */
#line 658 "HAL_S.y"
                                       { (yyval.declaration_) = make_AFdeclaration_eventToken_event_minorAttrList((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4249 "Parser.c"
    break;

  case 13: /* DECLARATION: _SYMB_189  */
#line 659 "HAL_S.y"
              { (yyval.declaration_) = make_AGdeclaration_eventToken((yyvsp[0].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4255 "Parser.c"
    break;

  case 14: /* DECLARATION: _SYMB_189 MINOR_ATTR_LIST  */
#line 660 "HAL_S.y"
                              { (yyval.declaration_) = make_AHdeclaration_eventToken_minorAttrList((yyvsp[-1].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4261 "Parser.c"
    break;

  case 15: /* ARRAY_SPEC: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 662 "HAL_S.y"
                                                    { (yyval.array_spec_) = make_AAarraySpec_arrayHead_literalExpOrStar((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4267 "Parser.c"
    break;

  case 16: /* ARRAY_SPEC: _SYMB_86  */
#line 663 "HAL_S.y"
             { (yyval.array_spec_) = make_ABarraySpec_function(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4273 "Parser.c"
    break;

  case 17: /* ARRAY_SPEC: _SYMB_120  */
#line 664 "HAL_S.y"
              { (yyval.array_spec_) = make_ACarraySpec_procedure(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4279 "Parser.c"
    break;

  case 18: /* ARRAY_SPEC: _SYMB_122  */
#line 665 "HAL_S.y"
              { (yyval.array_spec_) = make_ADarraySpec_program(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4285 "Parser.c"
    break;

  case 19: /* ARRAY_SPEC: _SYMB_161  */
#line 666 "HAL_S.y"
              { (yyval.array_spec_) = make_AEarraySpec_task(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4291 "Parser.c"
    break;

  case 20: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC  */
#line 668 "HAL_S.y"
                                { (yyval.type_and_minor_attr_) = make_AAtypeAndMinorAttr_typeSpec((yyvsp[0].type_spec_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4297 "Parser.c"
    break;

  case 21: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC MINOR_ATTR_LIST  */
#line 669 "HAL_S.y"
                              { (yyval.type_and_minor_attr_) = make_ABtypeAndMinorAttr_typeSpec_minorAttrList((yyvsp[-1].type_spec_), (yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4303 "Parser.c"
    break;

  case 22: /* TYPE_AND_MINOR_ATTR: MINOR_ATTR_LIST  */
#line 670 "HAL_S.y"
                    { (yyval.type_and_minor_attr_) = make_ACtypeAndMinorAttr_minorAttrList((yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4309 "Parser.c"
    break;

  case 23: /* IDENTIFIER: _SYMB_191  */
#line 672 "HAL_S.y"
                       { (yyval.identifier_) = make_AAidentifier((yyvsp[0].string_)); (yyval.identifier_)->line_number = (yyloc).first_line; (yyval.identifier_)->char_number = (yyloc).first_column;  }
#line 4315 "Parser.c"
    break;

  case 24: /* SQ_DQ_NAME: DOUBLY_QUAL_NAME_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 674 "HAL_S.y"
                                                               { (yyval.sq_dq_name_) = make_AAsQdQName_doublyQualNameHead_literalExpOrStar((yyvsp[-2].doubly_qual_name_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 4321 "Parser.c"
    break;

  case 25: /* SQ_DQ_NAME: ARITH_CONV  */
#line 675 "HAL_S.y"
               { (yyval.sq_dq_name_) = make_ABsQdQName_arithConv((yyvsp[0].arith_conv_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 4327 "Parser.c"
    break;

  case 26: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_174 _SYMB_2  */
#line 677 "HAL_S.y"
                                          { (yyval.doubly_qual_name_head_) = make_AAdoublyQualNameHead_vector(); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 4333 "Parser.c"
    break;

  case 27: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_102 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_0  */
#line 678 "HAL_S.y"
                                                  { (yyval.doubly_qual_name_head_) = make_ABdoublyQualNameHead_matrix_literalExpOrStar((yyvsp[-1].literal_exp_or_star_)); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 4339 "Parser.c"
    break;

  case 28: /* ARITH_CONV: _SYMB_94  */
#line 680 "HAL_S.y"
                      { (yyval.arith_conv_) = make_AAarithConv_integer(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4345 "Parser.c"
    break;

  case 29: /* ARITH_CONV: _SYMB_138  */
#line 681 "HAL_S.y"
              { (yyval.arith_conv_) = make_ABarithConv_scalar(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4351 "Parser.c"
    break;

  case 30: /* ARITH_CONV: _SYMB_174  */
#line 682 "HAL_S.y"
              { (yyval.arith_conv_) = make_ACarithConv_vector(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4357 "Parser.c"
    break;

  case 31: /* ARITH_CONV: _SYMB_102  */
#line 683 "HAL_S.y"
              { (yyval.arith_conv_) = make_ADarithConv_matrix(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4363 "Parser.c"
    break;

  case 32: /* DECLARATION_LIST: DECLARATION  */
#line 685 "HAL_S.y"
                               { (yyval.declaration_list_) = make_AAdeclaration_list((yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 4369 "Parser.c"
    break;

  case 33: /* DECLARATION_LIST: DCL_LIST_COMMA DECLARATION  */
#line 686 "HAL_S.y"
                               { (yyval.declaration_list_) = make_ABdeclaration_list((yyvsp[-1].dcl_list_comma_), (yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 4375 "Parser.c"
    break;

  case 34: /* NAME_ID: IDENTIFIER  */
#line 688 "HAL_S.y"
                     { (yyval.name_id_) = make_AAnameId_identifier((yyvsp[0].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4381 "Parser.c"
    break;

  case 35: /* NAME_ID: IDENTIFIER _SYMB_107  */
#line 689 "HAL_S.y"
                         { (yyval.name_id_) = make_ABnameId_identifier_name((yyvsp[-1].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4387 "Parser.c"
    break;

  case 36: /* NAME_ID: BIT_ID  */
#line 690 "HAL_S.y"
           { (yyval.name_id_) = make_ACnameId_bitId((yyvsp[0].bit_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4393 "Parser.c"
    break;

  case 37: /* NAME_ID: CHAR_ID  */
#line 691 "HAL_S.y"
            { (yyval.name_id_) = make_ADnameId_charId((yyvsp[0].char_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4399 "Parser.c"
    break;

  case 38: /* NAME_ID: _SYMB_183  */
#line 692 "HAL_S.y"
              { (yyval.name_id_) = make_AEnameId_bitFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4405 "Parser.c"
    break;

  case 39: /* NAME_ID: _SYMB_184  */
#line 693 "HAL_S.y"
              { (yyval.name_id_) = make_AFnameId_charFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4411 "Parser.c"
    break;

  case 40: /* NAME_ID: _SYMB_186  */
#line 694 "HAL_S.y"
              { (yyval.name_id_) = make_AGnameId_structIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4417 "Parser.c"
    break;

  case 41: /* NAME_ID: _SYMB_187  */
#line 695 "HAL_S.y"
              { (yyval.name_id_) = make_AHnameId_structFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4423 "Parser.c"
    break;

  case 42: /* ARITH_EXP: TERM  */
#line 697 "HAL_S.y"
                 { (yyval.arith_exp_) = make_AAarithExpTerm((yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4429 "Parser.c"
    break;

  case 43: /* ARITH_EXP: PLUS TERM  */
#line 698 "HAL_S.y"
              { (yyval.arith_exp_) = make_ABarithExpPlusTerm((yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4435 "Parser.c"
    break;

  case 44: /* ARITH_EXP: MINUS TERM  */
#line 699 "HAL_S.y"
               { (yyval.arith_exp_) = make_ACarithMinusTerm((yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4441 "Parser.c"
    break;

  case 45: /* ARITH_EXP: ARITH_EXP PLUS TERM  */
#line 700 "HAL_S.y"
                        { (yyval.arith_exp_) = make_ADarithExpArithExpPlusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4447 "Parser.c"
    break;

  case 46: /* ARITH_EXP: ARITH_EXP MINUS TERM  */
#line 701 "HAL_S.y"
                         { (yyval.arith_exp_) = make_AEarithExpArithExpMinusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4453 "Parser.c"
    break;

  case 47: /* TERM: PRODUCT  */
#line 703 "HAL_S.y"
               { (yyval.term_) = make_AAtermNoDivide((yyvsp[0].product_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4459 "Parser.c"
    break;

  case 48: /* TERM: PRODUCT _SYMB_3 TERM  */
#line 704 "HAL_S.y"
                         { (yyval.term_) = make_ABtermDivide((yyvsp[-2].product_), (yyvsp[0].term_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4465 "Parser.c"
    break;

  case 49: /* PLUS: _SYMB_4  */
#line 706 "HAL_S.y"
               { (yyval.plus_) = make_AAplus(); (yyval.plus_)->line_number = (yyloc).first_line; (yyval.plus_)->char_number = (yyloc).first_column;  }
#line 4471 "Parser.c"
    break;

  case 50: /* MINUS: _SYMB_5  */
#line 708 "HAL_S.y"
                { (yyval.minus_) = make_AAminus(); (yyval.minus_)->line_number = (yyloc).first_line; (yyval.minus_)->char_number = (yyloc).first_column;  }
#line 4477 "Parser.c"
    break;

  case 51: /* PRODUCT: FACTOR  */
#line 710 "HAL_S.y"
                 { (yyval.product_) = make_AAproductSingle((yyvsp[0].factor_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4483 "Parser.c"
    break;

  case 52: /* PRODUCT: FACTOR _SYMB_6 PRODUCT  */
#line 711 "HAL_S.y"
                           { (yyval.product_) = make_ABproductCross((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4489 "Parser.c"
    break;

  case 53: /* PRODUCT: FACTOR _SYMB_7 PRODUCT  */
#line 712 "HAL_S.y"
                           { (yyval.product_) = make_ACproductDot((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4495 "Parser.c"
    break;

  case 54: /* PRODUCT: FACTOR PRODUCT  */
#line 713 "HAL_S.y"
                   { (yyval.product_) = make_ADproductMultiplication((yyvsp[-1].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4501 "Parser.c"
    break;

  case 55: /* FACTOR: PRIMARY  */
#line 715 "HAL_S.y"
                 { (yyval.factor_) = make_AAfactor((yyvsp[0].primary_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4507 "Parser.c"
    break;

  case 56: /* FACTOR: PRIMARY EXPONENTIATION FACTOR  */
#line 716 "HAL_S.y"
                                  { (yyval.factor_) = make_ABfactorExponentiation((yyvsp[-2].primary_), (yyvsp[-1].exponentiation_), (yyvsp[0].factor_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4513 "Parser.c"
    break;

  case 57: /* EXPONENTIATION: _SYMB_8  */
#line 718 "HAL_S.y"
                         { (yyval.exponentiation_) = make_AAexponentiation(); (yyval.exponentiation_)->line_number = (yyloc).first_line; (yyval.exponentiation_)->char_number = (yyloc).first_column;  }
#line 4519 "Parser.c"
    break;

  case 58: /* PRIMARY: ARITH_VAR  */
#line 720 "HAL_S.y"
                    { (yyval.primary_) = make_AAprimary((yyvsp[0].arith_var_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4525 "Parser.c"
    break;

  case 59: /* PRIMARY: PRE_PRIMARY  */
#line 721 "HAL_S.y"
                { (yyval.primary_) = make_ADprimary((yyvsp[0].pre_primary_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4531 "Parser.c"
    break;

  case 60: /* PRIMARY: MODIFIED_ARITH_FUNC  */
#line 722 "HAL_S.y"
                        { (yyval.primary_) = make_ABprimary((yyvsp[0].modified_arith_func_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4537 "Parser.c"
    break;

  case 61: /* PRIMARY: PRE_PRIMARY QUALIFIER  */
#line 723 "HAL_S.y"
                          { (yyval.primary_) = make_AEprimary((yyvsp[-1].pre_primary_), (yyvsp[0].qualifier_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4543 "Parser.c"
    break;

  case 62: /* ARITH_VAR: ARITH_ID  */
#line 725 "HAL_S.y"
                     { (yyval.arith_var_) = make_AAarith_var((yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4549 "Parser.c"
    break;

  case 63: /* ARITH_VAR: ARITH_ID SUBSCRIPT  */
#line 726 "HAL_S.y"
                       { (yyval.arith_var_) = make_ACarith_var((yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4555 "Parser.c"
    break;

  case 64: /* ARITH_VAR: _SYMB_10 ARITH_ID _SYMB_11  */
#line 727 "HAL_S.y"
                               { (yyval.arith_var_) = make_AAarithVarBracketed((yyvsp[-1].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4561 "Parser.c"
    break;

  case 65: /* ARITH_VAR: _SYMB_10 ARITH_ID _SYMB_11 SUBSCRIPT  */
#line 728 "HAL_S.y"
                                         { (yyval.arith_var_) = make_ABarithVarBracketed((yyvsp[-2].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4567 "Parser.c"
    break;

  case 66: /* ARITH_VAR: _SYMB_12 QUAL_STRUCT _SYMB_13  */
#line 729 "HAL_S.y"
                                  { (yyval.arith_var_) = make_AAarithVarBraced((yyvsp[-1].qual_struct_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4573 "Parser.c"
    break;

  case 67: /* ARITH_VAR: _SYMB_12 QUAL_STRUCT _SYMB_13 SUBSCRIPT  */
#line 730 "HAL_S.y"
                                            { (yyval.arith_var_) = make_ABarithVarBraced((yyvsp[-2].qual_struct_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4579 "Parser.c"
    break;

  case 68: /* ARITH_VAR: QUAL_STRUCT _SYMB_7 ARITH_ID  */
#line 731 "HAL_S.y"
                                 { (yyval.arith_var_) = make_ABarith_var((yyvsp[-2].qual_struct_), (yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4585 "Parser.c"
    break;

  case 69: /* ARITH_VAR: QUAL_STRUCT _SYMB_7 ARITH_ID SUBSCRIPT  */
#line 732 "HAL_S.y"
                                           { (yyval.arith_var_) = make_ADarith_var((yyvsp[-3].qual_struct_), (yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4591 "Parser.c"
    break;

  case 70: /* PRE_PRIMARY: _SYMB_2 ARITH_EXP _SYMB_1  */
#line 734 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AApre_primary((yyvsp[-1].arith_exp_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4597 "Parser.c"
    break;

  case 71: /* PRE_PRIMARY: NUMBER  */
#line 735 "HAL_S.y"
           { (yyval.pre_primary_) = make_ABpre_primary((yyvsp[0].number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4603 "Parser.c"
    break;

  case 72: /* PRE_PRIMARY: COMPOUND_NUMBER  */
#line 736 "HAL_S.y"
                    { (yyval.pre_primary_) = make_ACpre_primary((yyvsp[0].compound_number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4609 "Parser.c"
    break;

  case 73: /* PRE_PRIMARY: ARITH_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 737 "HAL_S.y"
                                              { (yyval.pre_primary_) = make_ADprePrimaryRtlFunction((yyvsp[-3].arith_func_head_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4615 "Parser.c"
    break;

  case 74: /* PRE_PRIMARY: _SYMB_188 _SYMB_2 CALL_LIST _SYMB_1  */
#line 738 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AEprePrimaryFunction((yyvsp[-3].string_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4621 "Parser.c"
    break;

  case 75: /* NUMBER: SIMPLE_NUMBER  */
#line 740 "HAL_S.y"
                       { (yyval.number_) = make_AAnumber((yyvsp[0].simple_number_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4627 "Parser.c"
    break;

  case 76: /* NUMBER: LEVEL  */
#line 741 "HAL_S.y"
          { (yyval.number_) = make_ABnumber((yyvsp[0].level_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4633 "Parser.c"
    break;

  case 77: /* LEVEL: _SYMB_194  */
#line 743 "HAL_S.y"
                  { (yyval.level_) = make_ZZlevel((yyvsp[0].string_)); (yyval.level_)->line_number = (yyloc).first_line; (yyval.level_)->char_number = (yyloc).first_column;  }
#line 4639 "Parser.c"
    break;

  case 78: /* COMPOUND_NUMBER: _SYMB_196  */
#line 745 "HAL_S.y"
                            { (yyval.compound_number_) = make_CLcompound_number((yyvsp[0].string_)); (yyval.compound_number_)->line_number = (yyloc).first_line; (yyval.compound_number_)->char_number = (yyloc).first_column;  }
#line 4645 "Parser.c"
    break;

  case 79: /* SIMPLE_NUMBER: _SYMB_195  */
#line 747 "HAL_S.y"
                          { (yyval.simple_number_) = make_CKsimple_number((yyvsp[0].string_)); (yyval.simple_number_)->line_number = (yyloc).first_line; (yyval.simple_number_)->char_number = (yyloc).first_column;  }
#line 4651 "Parser.c"
    break;

  case 80: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC  */
#line 749 "HAL_S.y"
                                        { (yyval.modified_arith_func_) = make_AAmodified_arith_func((yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4657 "Parser.c"
    break;

  case 81: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 750 "HAL_S.y"
                                { (yyval.modified_arith_func_) = make_ACmodified_arith_func((yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4663 "Parser.c"
    break;

  case 82: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_7 NO_ARG_ARITH_FUNC  */
#line 751 "HAL_S.y"
                                          { (yyval.modified_arith_func_) = make_ADmodified_arith_func((yyvsp[-2].qual_struct_), (yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4669 "Parser.c"
    break;

  case 83: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_7 NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 752 "HAL_S.y"
                                                    { (yyval.modified_arith_func_) = make_AEmodified_arith_func((yyvsp[-3].qual_struct_), (yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4675 "Parser.c"
    break;

  case 84: /* ARITH_FUNC_HEAD: ARITH_FUNC  */
#line 754 "HAL_S.y"
                             { (yyval.arith_func_head_) = make_AAarith_func_head((yyvsp[0].arith_func_)); (yyval.arith_func_head_)->line_number = (yyloc).first_line; (yyval.arith_func_head_)->char_number = (yyloc).first_column;  }
#line 4681 "Parser.c"
    break;

  case 85: /* ARITH_FUNC_HEAD: ARITH_CONV SUBSCRIPT  */
#line 755 "HAL_S.y"
                         { (yyval.arith_func_head_) = make_ABarith_func_head((yyvsp[-1].arith_conv_), (yyvsp[0].subscript_)); (yyval.arith_func_head_)->line_number = (yyloc).first_line; (yyval.arith_func_head_)->char_number = (yyloc).first_column;  }
#line 4687 "Parser.c"
    break;

  case 86: /* CALL_LIST: LIST_EXP  */
#line 757 "HAL_S.y"
                     { (yyval.call_list_) = make_AAcall_list((yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 4693 "Parser.c"
    break;

  case 87: /* CALL_LIST: CALL_LIST _SYMB_0 LIST_EXP  */
#line 758 "HAL_S.y"
                               { (yyval.call_list_) = make_ABcall_list((yyvsp[-2].call_list_), (yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 4699 "Parser.c"
    break;

  case 88: /* LIST_EXP: EXPRESSION  */
#line 760 "HAL_S.y"
                      { (yyval.list_exp_) = make_AAlist_exp((yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4705 "Parser.c"
    break;

  case 89: /* LIST_EXP: ARITH_EXP _SYMB_9 EXPRESSION  */
#line 761 "HAL_S.y"
                                 { (yyval.list_exp_) = make_ABlist_exp((yyvsp[-2].arith_exp_), (yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4711 "Parser.c"
    break;

  case 90: /* LIST_EXP: QUAL_STRUCT  */
#line 762 "HAL_S.y"
                { (yyval.list_exp_) = make_ADlist_exp((yyvsp[0].qual_struct_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4717 "Parser.c"
    break;

  case 91: /* EXPRESSION: ARITH_EXP  */
#line 764 "HAL_S.y"
                       { (yyval.expression_) = make_AAexpression((yyvsp[0].arith_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4723 "Parser.c"
    break;

  case 92: /* EXPRESSION: BIT_EXP  */
#line 765 "HAL_S.y"
            { (yyval.expression_) = make_ABexpression((yyvsp[0].bit_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4729 "Parser.c"
    break;

  case 93: /* EXPRESSION: CHAR_EXP  */
#line 766 "HAL_S.y"
             { (yyval.expression_) = make_ACexpression((yyvsp[0].char_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4735 "Parser.c"
    break;

  case 94: /* EXPRESSION: NAME_EXP  */
#line 767 "HAL_S.y"
             { (yyval.expression_) = make_AEexpression((yyvsp[0].name_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4741 "Parser.c"
    break;

  case 95: /* EXPRESSION: STRUCTURE_EXP  */
#line 768 "HAL_S.y"
                  { (yyval.expression_) = make_ADexpression((yyvsp[0].structure_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4747 "Parser.c"
    break;

  case 96: /* ARITH_ID: IDENTIFIER  */
#line 770 "HAL_S.y"
                      { (yyval.arith_id_) = make_FGarith_id((yyvsp[0].identifier_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 4753 "Parser.c"
    break;

  case 97: /* ARITH_ID: _SYMB_190  */
#line 771 "HAL_S.y"
              { (yyval.arith_id_) = make_FHarith_id((yyvsp[0].string_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 4759 "Parser.c"
    break;

  case 98: /* NO_ARG_ARITH_FUNC: _SYMB_54  */
#line 773 "HAL_S.y"
                             { (yyval.no_arg_arith_func_) = make_ZZclocktime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4765 "Parser.c"
    break;

  case 99: /* NO_ARG_ARITH_FUNC: _SYMB_61  */
#line 774 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZdate(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4771 "Parser.c"
    break;

  case 100: /* NO_ARG_ARITH_FUNC: _SYMB_73  */
#line 775 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZerrgrp(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4777 "Parser.c"
    break;

  case 101: /* NO_ARG_ARITH_FUNC: _SYMB_74  */
#line 776 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZerrnum(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4783 "Parser.c"
    break;

  case 102: /* NO_ARG_ARITH_FUNC: _SYMB_118  */
#line 777 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZprio(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4789 "Parser.c"
    break;

  case 103: /* NO_ARG_ARITH_FUNC: _SYMB_123  */
#line 778 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZrandom(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4795 "Parser.c"
    break;

  case 104: /* NO_ARG_ARITH_FUNC: _SYMB_124  */
#line 779 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZrandomg(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4801 "Parser.c"
    break;

  case 105: /* NO_ARG_ARITH_FUNC: _SYMB_137  */
#line 780 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZruntime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4807 "Parser.c"
    break;

  case 106: /* ARITH_FUNC: _SYMB_108  */
#line 782 "HAL_S.y"
                       { (yyval.arith_func_) = make_ZZnextime(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4813 "Parser.c"
    break;

  case 107: /* ARITH_FUNC: _SYMB_26  */
#line 783 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabs(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4819 "Parser.c"
    break;

  case 108: /* ARITH_FUNC: _SYMB_51  */
#line 784 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZceiling(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4825 "Parser.c"
    break;

  case 109: /* ARITH_FUNC: _SYMB_67  */
#line 785 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdiv(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4831 "Parser.c"
    break;

  case 110: /* ARITH_FUNC: _SYMB_84  */
#line 786 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZfloor(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4837 "Parser.c"
    break;

  case 111: /* ARITH_FUNC: _SYMB_104  */
#line 787 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmidval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4843 "Parser.c"
    break;

  case 112: /* ARITH_FUNC: _SYMB_106  */
#line 788 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4849 "Parser.c"
    break;

  case 113: /* ARITH_FUNC: _SYMB_113  */
#line 789 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZodd(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4855 "Parser.c"
    break;

  case 114: /* ARITH_FUNC: _SYMB_128  */
#line 790 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZremainder(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4861 "Parser.c"
    break;

  case 115: /* ARITH_FUNC: _SYMB_136  */
#line 791 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZround(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4867 "Parser.c"
    break;

  case 116: /* ARITH_FUNC: _SYMB_144  */
#line 792 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsign(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4873 "Parser.c"
    break;

  case 117: /* ARITH_FUNC: _SYMB_146  */
#line 793 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsignum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4879 "Parser.c"
    break;

  case 118: /* ARITH_FUNC: _SYMB_170  */
#line 794 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtruncate(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4885 "Parser.c"
    break;

  case 119: /* ARITH_FUNC: _SYMB_32  */
#line 795 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4891 "Parser.c"
    break;

  case 120: /* ARITH_FUNC: _SYMB_33  */
#line 796 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4897 "Parser.c"
    break;

  case 121: /* ARITH_FUNC: _SYMB_34  */
#line 797 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4903 "Parser.c"
    break;

  case 122: /* ARITH_FUNC: _SYMB_35  */
#line 798 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4909 "Parser.c"
    break;

  case 123: /* ARITH_FUNC: _SYMB_37  */
#line 799 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan2(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4915 "Parser.c"
    break;

  case 124: /* ARITH_FUNC: _SYMB_36  */
#line 800 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4921 "Parser.c"
    break;

  case 125: /* ARITH_FUNC: _SYMB_38  */
#line 801 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4927 "Parser.c"
    break;

  case 126: /* ARITH_FUNC: _SYMB_59  */
#line 802 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4933 "Parser.c"
    break;

  case 127: /* ARITH_FUNC: _SYMB_60  */
#line 803 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4939 "Parser.c"
    break;

  case 128: /* ARITH_FUNC: _SYMB_80  */
#line 804 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZexp(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4945 "Parser.c"
    break;

  case 129: /* ARITH_FUNC: _SYMB_101  */
#line 805 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZlog(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4951 "Parser.c"
    break;

  case 130: /* ARITH_FUNC: _SYMB_147  */
#line 806 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4957 "Parser.c"
    break;

  case 131: /* ARITH_FUNC: _SYMB_149  */
#line 807 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4963 "Parser.c"
    break;

  case 132: /* ARITH_FUNC: _SYMB_152  */
#line 808 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsqrt(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4969 "Parser.c"
    break;

  case 133: /* ARITH_FUNC: _SYMB_159  */
#line 809 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4975 "Parser.c"
    break;

  case 134: /* ARITH_FUNC: _SYMB_160  */
#line 810 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4981 "Parser.c"
    break;

  case 135: /* ARITH_FUNC: _SYMB_142  */
#line 811 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshl(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4987 "Parser.c"
    break;

  case 136: /* ARITH_FUNC: _SYMB_143  */
#line 812 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshr(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4993 "Parser.c"
    break;

  case 137: /* ARITH_FUNC: _SYMB_27  */
#line 813 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4999 "Parser.c"
    break;

  case 138: /* ARITH_FUNC: _SYMB_66  */
#line 814 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdet(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5005 "Parser.c"
    break;

  case 139: /* ARITH_FUNC: _SYMB_166  */
#line 815 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtrace(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5011 "Parser.c"
    break;

  case 140: /* ARITH_FUNC: _SYMB_171  */
#line 816 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZunit(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5017 "Parser.c"
    break;

  case 141: /* ARITH_FUNC: _SYMB_102  */
#line 817 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmatrix(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5023 "Parser.c"
    break;

  case 142: /* ARITH_FUNC: _SYMB_92  */
#line 818 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZindex(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5029 "Parser.c"
    break;

  case 143: /* ARITH_FUNC: _SYMB_97  */
#line 819 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZlength(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5035 "Parser.c"
    break;

  case 144: /* ARITH_FUNC: _SYMB_95  */
#line 820 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZinverse(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5041 "Parser.c"
    break;

  case 145: /* ARITH_FUNC: _SYMB_167  */
#line 821 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtranspose(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5047 "Parser.c"
    break;

  case 146: /* ARITH_FUNC: _SYMB_121  */
#line 822 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZprod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5053 "Parser.c"
    break;

  case 147: /* ARITH_FUNC: _SYMB_156  */
#line 823 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5059 "Parser.c"
    break;

  case 148: /* ARITH_FUNC: _SYMB_150  */
#line 824 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsize(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5065 "Parser.c"
    break;

  case 149: /* ARITH_FUNC: _SYMB_103  */
#line 825 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmax(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5071 "Parser.c"
    break;

  case 150: /* ARITH_FUNC: _SYMB_105  */
#line 826 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5077 "Parser.c"
    break;

  case 151: /* ARITH_FUNC: _SYMB_94  */
#line 827 "HAL_S.y"
             { (yyval.arith_func_) = make_AAarithFuncInteger(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5083 "Parser.c"
    break;

  case 152: /* ARITH_FUNC: _SYMB_138  */
#line 828 "HAL_S.y"
              { (yyval.arith_func_) = make_AAarithFuncScalar(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5089 "Parser.c"
    break;

  case 153: /* SUBSCRIPT: SUB_HEAD _SYMB_1  */
#line 830 "HAL_S.y"
                             { (yyval.subscript_) = make_AAsubscript((yyvsp[-1].sub_head_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5095 "Parser.c"
    break;

  case 154: /* SUBSCRIPT: QUALIFIER  */
#line 831 "HAL_S.y"
              { (yyval.subscript_) = make_ABsubscript((yyvsp[0].qualifier_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5101 "Parser.c"
    break;

  case 155: /* SUBSCRIPT: _SYMB_14 NUMBER  */
#line 832 "HAL_S.y"
                    { (yyval.subscript_) = make_ACsubscript((yyvsp[0].number_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5107 "Parser.c"
    break;

  case 156: /* SUBSCRIPT: _SYMB_14 ARITH_VAR  */
#line 833 "HAL_S.y"
                       { (yyval.subscript_) = make_ADsubscript((yyvsp[0].arith_var_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5113 "Parser.c"
    break;

  case 157: /* QUALIFIER: _SYMB_14 _SYMB_2 _SYMB_15 PREC_SPEC _SYMB_1  */
#line 835 "HAL_S.y"
                                                        { (yyval.qualifier_) = make_AAqualifier((yyvsp[-1].prec_spec_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5119 "Parser.c"
    break;

  case 158: /* QUALIFIER: _SYMB_14 _SYMB_2 SCALE_HEAD ARITH_EXP _SYMB_1  */
#line 836 "HAL_S.y"
                                                  { (yyval.qualifier_) = make_ABqualifier((yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5125 "Parser.c"
    break;

  case 159: /* QUALIFIER: _SYMB_14 _SYMB_2 _SYMB_15 PREC_SPEC _SYMB_0 SCALE_HEAD ARITH_EXP _SYMB_1  */
#line 837 "HAL_S.y"
                                                                             { (yyval.qualifier_) = make_ACqualifier((yyvsp[-4].prec_spec_), (yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5131 "Parser.c"
    break;

  case 160: /* QUALIFIER: _SYMB_14 _SYMB_2 _SYMB_15 RADIX _SYMB_1  */
#line 838 "HAL_S.y"
                                            { (yyval.qualifier_) = make_ADqualifier((yyvsp[-1].radix_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5137 "Parser.c"
    break;

  case 161: /* SCALE_HEAD: _SYMB_15  */
#line 840 "HAL_S.y"
                      { (yyval.scale_head_) = make_AAscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 5143 "Parser.c"
    break;

  case 162: /* SCALE_HEAD: _SYMB_15 _SYMB_15  */
#line 841 "HAL_S.y"
                      { (yyval.scale_head_) = make_ABscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 5149 "Parser.c"
    break;

  case 163: /* PREC_SPEC: _SYMB_148  */
#line 843 "HAL_S.y"
                      { (yyval.prec_spec_) = make_AAprecSpecSingle(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 5155 "Parser.c"
    break;

  case 164: /* PREC_SPEC: _SYMB_69  */
#line 844 "HAL_S.y"
             { (yyval.prec_spec_) = make_ABprecSpecDouble(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 5161 "Parser.c"
    break;

  case 165: /* SUB_START: _SYMB_14 _SYMB_2  */
#line 846 "HAL_S.y"
                             { (yyval.sub_start_) = make_AAsubStartGroup(); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5167 "Parser.c"
    break;

  case 166: /* SUB_START: _SYMB_14 _SYMB_2 _SYMB_15 PREC_SPEC _SYMB_0  */
#line 847 "HAL_S.y"
                                                { (yyval.sub_start_) = make_ABsubStartPrecSpec((yyvsp[-1].prec_spec_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5173 "Parser.c"
    break;

  case 167: /* SUB_START: SUB_HEAD _SYMB_16  */
#line 848 "HAL_S.y"
                      { (yyval.sub_start_) = make_ACsubStartSemicolon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5179 "Parser.c"
    break;

  case 168: /* SUB_START: SUB_HEAD _SYMB_17  */
#line 849 "HAL_S.y"
                      { (yyval.sub_start_) = make_ADsubStartColon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5185 "Parser.c"
    break;

  case 169: /* SUB_START: SUB_HEAD _SYMB_0  */
#line 850 "HAL_S.y"
                     { (yyval.sub_start_) = make_AEsubStartComma((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5191 "Parser.c"
    break;

  case 170: /* SUB_HEAD: SUB_START  */
#line 852 "HAL_S.y"
                     { (yyval.sub_head_) = make_AAsub_head((yyvsp[0].sub_start_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 5197 "Parser.c"
    break;

  case 171: /* SUB_HEAD: SUB_START SUB  */
#line 853 "HAL_S.y"
                  { (yyval.sub_head_) = make_ABsub_head((yyvsp[-1].sub_start_), (yyvsp[0].sub_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 5203 "Parser.c"
    break;

  case 172: /* SUB: SUB_EXP  */
#line 855 "HAL_S.y"
              { (yyval.sub_) = make_AAsub((yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5209 "Parser.c"
    break;

  case 173: /* SUB: _SYMB_6  */
#line 856 "HAL_S.y"
            { (yyval.sub_) = make_ABsubStar(); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5215 "Parser.c"
    break;

  case 174: /* SUB: SUB_RUN_HEAD SUB_EXP  */
#line 857 "HAL_S.y"
                         { (yyval.sub_) = make_ACsubExp((yyvsp[-1].sub_run_head_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5221 "Parser.c"
    break;

  case 175: /* SUB: ARITH_EXP _SYMB_41 SUB_EXP  */
#line 858 "HAL_S.y"
                               { (yyval.sub_) = make_ADsubAt((yyvsp[-2].arith_exp_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5227 "Parser.c"
    break;

  case 176: /* SUB_RUN_HEAD: SUB_EXP _SYMB_165  */
#line 860 "HAL_S.y"
                                 { (yyval.sub_run_head_) = make_AAsubRunHeadTo((yyvsp[-1].sub_exp_)); (yyval.sub_run_head_)->line_number = (yyloc).first_line; (yyval.sub_run_head_)->char_number = (yyloc).first_column;  }
#line 5233 "Parser.c"
    break;

  case 177: /* SUB_EXP: ARITH_EXP  */
#line 862 "HAL_S.y"
                    { (yyval.sub_exp_) = make_AAsub_exp((yyvsp[0].arith_exp_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 5239 "Parser.c"
    break;

  case 178: /* SUB_EXP: POUND_EXPRESSION  */
#line 863 "HAL_S.y"
                     { (yyval.sub_exp_) = make_ABsub_exp((yyvsp[0].pound_expression_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 5245 "Parser.c"
    break;

  case 179: /* POUND_EXPRESSION: _SYMB_9  */
#line 865 "HAL_S.y"
                           { (yyval.pound_expression_) = make_AApound_expression(); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5251 "Parser.c"
    break;

  case 180: /* POUND_EXPRESSION: POUND_EXPRESSION PLUS TERM  */
#line 866 "HAL_S.y"
                               { (yyval.pound_expression_) = make_ABpound_expression((yyvsp[-2].pound_expression_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5257 "Parser.c"
    break;

  case 181: /* POUND_EXPRESSION: POUND_EXPRESSION MINUS TERM  */
#line 867 "HAL_S.y"
                                { (yyval.pound_expression_) = make_ACpound_expression((yyvsp[-2].pound_expression_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5263 "Parser.c"
    break;

  case 182: /* BIT_EXP: BIT_FACTOR  */
#line 869 "HAL_S.y"
                     { (yyval.bit_exp_) = make_AAbitExpFactor((yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 5269 "Parser.c"
    break;

  case 183: /* BIT_EXP: BIT_EXP OR BIT_FACTOR  */
#line 870 "HAL_S.y"
                          { (yyval.bit_exp_) = make_ABbitExpOR((yyvsp[-2].bit_exp_), (yyvsp[-1].or_), (yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 5275 "Parser.c"
    break;

  case 184: /* BIT_FACTOR: BIT_CAT  */
#line 872 "HAL_S.y"
                     { (yyval.bit_factor_) = make_AAbitFactor((yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 5281 "Parser.c"
    break;

  case 185: /* BIT_FACTOR: BIT_FACTOR AND BIT_CAT  */
#line 873 "HAL_S.y"
                           { (yyval.bit_factor_) = make_ABbitFactorAnd((yyvsp[-2].bit_factor_), (yyvsp[-1].and_), (yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 5287 "Parser.c"
    break;

  case 186: /* BIT_CAT: BIT_PRIM  */
#line 875 "HAL_S.y"
                   { (yyval.bit_cat_) = make_AAbitCatPrim((yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5293 "Parser.c"
    break;

  case 187: /* BIT_CAT: BIT_CAT CAT BIT_PRIM  */
#line 876 "HAL_S.y"
                         { (yyval.bit_cat_) = make_ABbitCatCat((yyvsp[-2].bit_cat_), (yyvsp[-1].cat_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5299 "Parser.c"
    break;

  case 188: /* BIT_CAT: NOT BIT_PRIM  */
#line 877 "HAL_S.y"
                 { (yyval.bit_cat_) = make_ACbitCatNotPrim((yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5305 "Parser.c"
    break;

  case 189: /* BIT_CAT: BIT_CAT CAT NOT BIT_PRIM  */
#line 878 "HAL_S.y"
                             { (yyval.bit_cat_) = make_ADbitCatNotCat((yyvsp[-3].bit_cat_), (yyvsp[-2].cat_), (yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5311 "Parser.c"
    break;

  case 190: /* OR: CHAR_VERTICAL_BAR  */
#line 880 "HAL_S.y"
                       { (yyval.or_) = make_AAOR((yyvsp[0].char_vertical_bar_)); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5317 "Parser.c"
    break;

  case 191: /* OR: _SYMB_116  */
#line 881 "HAL_S.y"
              { (yyval.or_) = make_ABOR(); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5323 "Parser.c"
    break;

  case 192: /* CHAR_VERTICAL_BAR: _SYMB_18  */
#line 883 "HAL_S.y"
                             { (yyval.char_vertical_bar_) = make_CFchar_vertical_bar(); (yyval.char_vertical_bar_)->line_number = (yyloc).first_line; (yyval.char_vertical_bar_)->char_number = (yyloc).first_column;  }
#line 5329 "Parser.c"
    break;

  case 193: /* AND: _SYMB_19  */
#line 885 "HAL_S.y"
               { (yyval.and_) = make_AAAND(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5335 "Parser.c"
    break;

  case 194: /* AND: _SYMB_31  */
#line 886 "HAL_S.y"
             { (yyval.and_) = make_ABAND(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5341 "Parser.c"
    break;

  case 195: /* BIT_PRIM: BIT_VAR  */
#line 888 "HAL_S.y"
                   { (yyval.bit_prim_) = make_AAbitPrimBitVar((yyvsp[0].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5347 "Parser.c"
    break;

  case 196: /* BIT_PRIM: LABEL_VAR  */
#line 889 "HAL_S.y"
              { (yyval.bit_prim_) = make_ABbitPrimLabelVar((yyvsp[0].label_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5353 "Parser.c"
    break;

  case 197: /* BIT_PRIM: EVENT_VAR  */
#line 890 "HAL_S.y"
              { (yyval.bit_prim_) = make_ACbitPrimEventVar((yyvsp[0].event_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5359 "Parser.c"
    break;

  case 198: /* BIT_PRIM: BIT_CONST  */
#line 891 "HAL_S.y"
              { (yyval.bit_prim_) = make_ADbitBitConst((yyvsp[0].bit_const_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5365 "Parser.c"
    break;

  case 199: /* BIT_PRIM: _SYMB_2 BIT_EXP _SYMB_1  */
#line 892 "HAL_S.y"
                            { (yyval.bit_prim_) = make_AEbitPrimBitExp((yyvsp[-1].bit_exp_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5371 "Parser.c"
    break;

  case 200: /* BIT_PRIM: SUBBIT_HEAD EXPRESSION _SYMB_1  */
#line 893 "HAL_S.y"
                                   { (yyval.bit_prim_) = make_AHbitPrimSubbit((yyvsp[-2].subbit_head_), (yyvsp[-1].expression_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5377 "Parser.c"
    break;

  case 201: /* BIT_PRIM: BIT_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 894 "HAL_S.y"
                                            { (yyval.bit_prim_) = make_AIbitPrimFunc((yyvsp[-3].bit_func_head_), (yyvsp[-1].call_list_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5383 "Parser.c"
    break;

  case 202: /* BIT_PRIM: _SYMB_10 BIT_VAR _SYMB_11  */
#line 895 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBracketed((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5389 "Parser.c"
    break;

  case 203: /* BIT_PRIM: _SYMB_10 BIT_VAR _SYMB_11 SUBSCRIPT  */
#line 896 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBracketed((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5395 "Parser.c"
    break;

  case 204: /* BIT_PRIM: _SYMB_12 BIT_VAR _SYMB_13  */
#line 897 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBraced((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5401 "Parser.c"
    break;

  case 205: /* BIT_PRIM: _SYMB_12 BIT_VAR _SYMB_13 SUBSCRIPT  */
#line 898 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBraced((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5407 "Parser.c"
    break;

  case 206: /* CAT: _SYMB_20  */
#line 900 "HAL_S.y"
               { (yyval.cat_) = make_AAcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5413 "Parser.c"
    break;

  case 207: /* CAT: _SYMB_50  */
#line 901 "HAL_S.y"
             { (yyval.cat_) = make_ABcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5419 "Parser.c"
    break;

  case 208: /* NOT: _SYMB_110  */
#line 903 "HAL_S.y"
                { (yyval.not_) = make_ABNOT(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5425 "Parser.c"
    break;

  case 209: /* NOT: _SYMB_21  */
#line 904 "HAL_S.y"
             { (yyval.not_) = make_ADNOT(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5431 "Parser.c"
    break;

  case 210: /* BIT_VAR: BIT_ID  */
#line 906 "HAL_S.y"
                 { (yyval.bit_var_) = make_AAbit_var((yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5437 "Parser.c"
    break;

  case 211: /* BIT_VAR: BIT_ID SUBSCRIPT  */
#line 907 "HAL_S.y"
                     { (yyval.bit_var_) = make_ACbit_var((yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5443 "Parser.c"
    break;

  case 212: /* BIT_VAR: QUAL_STRUCT _SYMB_7 BIT_ID  */
#line 908 "HAL_S.y"
                               { (yyval.bit_var_) = make_ABbit_var((yyvsp[-2].qual_struct_), (yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5449 "Parser.c"
    break;

  case 213: /* BIT_VAR: QUAL_STRUCT _SYMB_7 BIT_ID SUBSCRIPT  */
#line 909 "HAL_S.y"
                                         { (yyval.bit_var_) = make_ADbit_var((yyvsp[-3].qual_struct_), (yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5455 "Parser.c"
    break;

  case 214: /* LABEL_VAR: LABEL  */
#line 911 "HAL_S.y"
                  { (yyval.label_var_) = make_AAlabel_var((yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5461 "Parser.c"
    break;

  case 215: /* LABEL_VAR: LABEL SUBSCRIPT  */
#line 912 "HAL_S.y"
                    { (yyval.label_var_) = make_ABlabel_var((yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5467 "Parser.c"
    break;

  case 216: /* LABEL_VAR: QUAL_STRUCT _SYMB_7 LABEL  */
#line 913 "HAL_S.y"
                              { (yyval.label_var_) = make_AClabel_var((yyvsp[-2].qual_struct_), (yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5473 "Parser.c"
    break;

  case 217: /* LABEL_VAR: QUAL_STRUCT _SYMB_7 LABEL SUBSCRIPT  */
#line 914 "HAL_S.y"
                                        { (yyval.label_var_) = make_ADlabel_var((yyvsp[-3].qual_struct_), (yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5479 "Parser.c"
    break;

  case 218: /* EVENT_VAR: EVENT  */
#line 916 "HAL_S.y"
                  { (yyval.event_var_) = make_AAevent_var((yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5485 "Parser.c"
    break;

  case 219: /* EVENT_VAR: EVENT SUBSCRIPT  */
#line 917 "HAL_S.y"
                    { (yyval.event_var_) = make_ACevent_var((yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5491 "Parser.c"
    break;

  case 220: /* EVENT_VAR: QUAL_STRUCT _SYMB_7 EVENT  */
#line 918 "HAL_S.y"
                              { (yyval.event_var_) = make_ABevent_var((yyvsp[-2].qual_struct_), (yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5497 "Parser.c"
    break;

  case 221: /* EVENT_VAR: QUAL_STRUCT _SYMB_7 EVENT SUBSCRIPT  */
#line 919 "HAL_S.y"
                                        { (yyval.event_var_) = make_ADevent_var((yyvsp[-3].qual_struct_), (yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5503 "Parser.c"
    break;

  case 222: /* BIT_CONST_HEAD: RADIX  */
#line 921 "HAL_S.y"
                       { (yyval.bit_const_head_) = make_AAbit_const_head((yyvsp[0].radix_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5509 "Parser.c"
    break;

  case 223: /* BIT_CONST_HEAD: RADIX _SYMB_2 NUMBER _SYMB_1  */
#line 922 "HAL_S.y"
                                 { (yyval.bit_const_head_) = make_ABbit_const_head((yyvsp[-3].radix_), (yyvsp[-1].number_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5515 "Parser.c"
    break;

  case 224: /* BIT_CONST: BIT_CONST_HEAD CHAR_STRING  */
#line 924 "HAL_S.y"
                                       { (yyval.bit_const_) = make_AAbitConstString((yyvsp[-1].bit_const_head_), (yyvsp[0].char_string_)); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5521 "Parser.c"
    break;

  case 225: /* BIT_CONST: _SYMB_169  */
#line 925 "HAL_S.y"
              { (yyval.bit_const_) = make_ABbitConstTrue(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5527 "Parser.c"
    break;

  case 226: /* BIT_CONST: _SYMB_82  */
#line 926 "HAL_S.y"
             { (yyval.bit_const_) = make_ACbitConstFalse(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5533 "Parser.c"
    break;

  case 227: /* BIT_CONST: _SYMB_115  */
#line 927 "HAL_S.y"
              { (yyval.bit_const_) = make_ADbitConstOn(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5539 "Parser.c"
    break;

  case 228: /* BIT_CONST: _SYMB_114  */
#line 928 "HAL_S.y"
              { (yyval.bit_const_) = make_AEbitConstOff(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5545 "Parser.c"
    break;

  case 229: /* RADIX: _SYMB_88  */
#line 930 "HAL_S.y"
                 { (yyval.radix_) = make_AAradixHEX(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5551 "Parser.c"
    break;

  case 230: /* RADIX: _SYMB_112  */
#line 931 "HAL_S.y"
              { (yyval.radix_) = make_ABradixOCT(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5557 "Parser.c"
    break;

  case 231: /* RADIX: _SYMB_43  */
#line 932 "HAL_S.y"
             { (yyval.radix_) = make_ACradixBIN(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5563 "Parser.c"
    break;

  case 232: /* RADIX: _SYMB_62  */
#line 933 "HAL_S.y"
             { (yyval.radix_) = make_ADradixDEC(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5569 "Parser.c"
    break;

  case 233: /* CHAR_STRING: _SYMB_192  */
#line 935 "HAL_S.y"
                        { (yyval.char_string_) = make_FPchar_string((yyvsp[0].string_)); (yyval.char_string_)->line_number = (yyloc).first_line; (yyval.char_string_)->char_number = (yyloc).first_column;  }
#line 5575 "Parser.c"
    break;

  case 234: /* SUBBIT_HEAD: SUBBIT_KEY _SYMB_2  */
#line 937 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_AAsubbit_head((yyvsp[-1].subbit_key_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5581 "Parser.c"
    break;

  case 235: /* SUBBIT_HEAD: SUBBIT_KEY SUBSCRIPT _SYMB_2  */
#line 938 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_ABsubbit_head((yyvsp[-2].subbit_key_), (yyvsp[-1].subscript_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5587 "Parser.c"
    break;

  case 236: /* SUBBIT_KEY: _SYMB_155  */
#line 940 "HAL_S.y"
                       { (yyval.subbit_key_) = make_AAsubbit_key(); (yyval.subbit_key_)->line_number = (yyloc).first_line; (yyval.subbit_key_)->char_number = (yyloc).first_column;  }
#line 5593 "Parser.c"
    break;

  case 237: /* BIT_FUNC_HEAD: BIT_FUNC  */
#line 942 "HAL_S.y"
                         { (yyval.bit_func_head_) = make_AAbit_func_head((yyvsp[0].bit_func_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5599 "Parser.c"
    break;

  case 238: /* BIT_FUNC_HEAD: _SYMB_44  */
#line 943 "HAL_S.y"
             { (yyval.bit_func_head_) = make_ABbit_func_head(); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5605 "Parser.c"
    break;

  case 239: /* BIT_FUNC_HEAD: _SYMB_44 SUB_OR_QUALIFIER  */
#line 944 "HAL_S.y"
                              { (yyval.bit_func_head_) = make_ACbit_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5611 "Parser.c"
    break;

  case 240: /* BIT_ID: _SYMB_182  */
#line 946 "HAL_S.y"
                   { (yyval.bit_id_) = make_FHbit_id((yyvsp[0].string_)); (yyval.bit_id_)->line_number = (yyloc).first_line; (yyval.bit_id_)->char_number = (yyloc).first_column;  }
#line 5617 "Parser.c"
    break;

  case 241: /* LABEL: _SYMB_188  */
#line 948 "HAL_S.y"
                  { (yyval.label_) = make_FKlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5623 "Parser.c"
    break;

  case 242: /* LABEL: _SYMB_183  */
#line 949 "HAL_S.y"
              { (yyval.label_) = make_FLlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5629 "Parser.c"
    break;

  case 243: /* LABEL: _SYMB_184  */
#line 950 "HAL_S.y"
              { (yyval.label_) = make_FMlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5635 "Parser.c"
    break;

  case 244: /* LABEL: _SYMB_187  */
#line 951 "HAL_S.y"
              { (yyval.label_) = make_FNlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5641 "Parser.c"
    break;

  case 245: /* BIT_FUNC: _SYMB_178  */
#line 953 "HAL_S.y"
                     { (yyval.bit_func_) = make_ZZxor(); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5647 "Parser.c"
    break;

  case 246: /* BIT_FUNC: _SYMB_183  */
#line 954 "HAL_S.y"
              { (yyval.bit_func_) = make_ZZuserBitFunction((yyvsp[0].string_)); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5653 "Parser.c"
    break;

  case 247: /* EVENT: _SYMB_189  */
#line 956 "HAL_S.y"
                  { (yyval.event_) = make_FLevent((yyvsp[0].string_)); (yyval.event_)->line_number = (yyloc).first_line; (yyval.event_)->char_number = (yyloc).first_column;  }
#line 5659 "Parser.c"
    break;

  case 248: /* SUB_OR_QUALIFIER: SUBSCRIPT  */
#line 958 "HAL_S.y"
                             { (yyval.sub_or_qualifier_) = make_AAsub_or_qualifier((yyvsp[0].subscript_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 5665 "Parser.c"
    break;

  case 249: /* SUB_OR_QUALIFIER: BIT_QUALIFIER  */
#line 959 "HAL_S.y"
                  { (yyval.sub_or_qualifier_) = make_ABsub_or_qualifier((yyvsp[0].bit_qualifier_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 5671 "Parser.c"
    break;

  case 250: /* BIT_QUALIFIER: _SYMB_22 _SYMB_14 _SYMB_2 _SYMB_15 RADIX _SYMB_1  */
#line 961 "HAL_S.y"
                                                                 { (yyval.bit_qualifier_) = make_AAbit_qualifier((yyvsp[-1].radix_)); (yyval.bit_qualifier_)->line_number = (yyloc).first_line; (yyval.bit_qualifier_)->char_number = (yyloc).first_column;  }
#line 5677 "Parser.c"
    break;

  case 251: /* CHAR_EXP: CHAR_PRIM  */
#line 963 "HAL_S.y"
                     { (yyval.char_exp_) = make_AAcharExpPrim((yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5683 "Parser.c"
    break;

  case 252: /* CHAR_EXP: CHAR_EXP CAT CHAR_PRIM  */
#line 964 "HAL_S.y"
                           { (yyval.char_exp_) = make_ABcharExpCat((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5689 "Parser.c"
    break;

  case 253: /* CHAR_EXP: CHAR_EXP CAT ARITH_EXP  */
#line 965 "HAL_S.y"
                           { (yyval.char_exp_) = make_ACcharExpCat((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5695 "Parser.c"
    break;

  case 254: /* CHAR_EXP: ARITH_EXP CAT ARITH_EXP  */
#line 966 "HAL_S.y"
                            { (yyval.char_exp_) = make_ADcharExpCat((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5701 "Parser.c"
    break;

  case 255: /* CHAR_EXP: ARITH_EXP CAT CHAR_PRIM  */
#line 967 "HAL_S.y"
                            { (yyval.char_exp_) = make_AEcharExpCat((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5707 "Parser.c"
    break;

  case 256: /* CHAR_PRIM: CHAR_VAR  */
#line 969 "HAL_S.y"
                     { (yyval.char_prim_) = make_AAchar_prim((yyvsp[0].char_var_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5713 "Parser.c"
    break;

  case 257: /* CHAR_PRIM: CHAR_CONST  */
#line 970 "HAL_S.y"
               { (yyval.char_prim_) = make_ABchar_prim((yyvsp[0].char_const_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5719 "Parser.c"
    break;

  case 258: /* CHAR_PRIM: CHAR_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 971 "HAL_S.y"
                                             { (yyval.char_prim_) = make_AEchar_prim((yyvsp[-3].char_func_head_), (yyvsp[-1].call_list_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5725 "Parser.c"
    break;

  case 259: /* CHAR_PRIM: _SYMB_2 CHAR_EXP _SYMB_1  */
#line 972 "HAL_S.y"
                             { (yyval.char_prim_) = make_AFchar_prim((yyvsp[-1].char_exp_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5731 "Parser.c"
    break;

  case 260: /* CHAR_FUNC_HEAD: CHAR_FUNC  */
#line 974 "HAL_S.y"
                           { (yyval.char_func_head_) = make_AAchar_func_head((yyvsp[0].char_func_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 5737 "Parser.c"
    break;

  case 261: /* CHAR_FUNC_HEAD: _SYMB_53 SUB_OR_QUALIFIER  */
#line 975 "HAL_S.y"
                              { (yyval.char_func_head_) = make_ABchar_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 5743 "Parser.c"
    break;

  case 262: /* CHAR_VAR: CHAR_ID  */
#line 977 "HAL_S.y"
                   { (yyval.char_var_) = make_AAchar_var((yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5749 "Parser.c"
    break;

  case 263: /* CHAR_VAR: CHAR_ID SUBSCRIPT  */
#line 978 "HAL_S.y"
                      { (yyval.char_var_) = make_ACchar_var((yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5755 "Parser.c"
    break;

  case 264: /* CHAR_VAR: QUAL_STRUCT _SYMB_7 CHAR_ID  */
#line 979 "HAL_S.y"
                                { (yyval.char_var_) = make_ABchar_var((yyvsp[-2].qual_struct_), (yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5761 "Parser.c"
    break;

  case 265: /* CHAR_VAR: QUAL_STRUCT _SYMB_7 CHAR_ID SUBSCRIPT  */
#line 980 "HAL_S.y"
                                          { (yyval.char_var_) = make_ADchar_var((yyvsp[-3].qual_struct_), (yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5767 "Parser.c"
    break;

  case 266: /* CHAR_CONST: CHAR_STRING  */
#line 982 "HAL_S.y"
                         { (yyval.char_const_) = make_AAchar_const((yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 5773 "Parser.c"
    break;

  case 267: /* CHAR_CONST: _SYMB_52 _SYMB_2 NUMBER _SYMB_1 CHAR_STRING  */
#line 983 "HAL_S.y"
                                                { (yyval.char_const_) = make_ABchar_const((yyvsp[-2].number_), (yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 5779 "Parser.c"
    break;

  case 268: /* CHAR_FUNC: _SYMB_99  */
#line 985 "HAL_S.y"
                     { (yyval.char_func_) = make_ZZljust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5785 "Parser.c"
    break;

  case 269: /* CHAR_FUNC: _SYMB_135  */
#line 986 "HAL_S.y"
              { (yyval.char_func_) = make_ZZrjust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5791 "Parser.c"
    break;

  case 270: /* CHAR_FUNC: _SYMB_168  */
#line 987 "HAL_S.y"
              { (yyval.char_func_) = make_ZZtrim(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5797 "Parser.c"
    break;

  case 271: /* CHAR_FUNC: _SYMB_184  */
#line 988 "HAL_S.y"
              { (yyval.char_func_) = make_ZZuserCharFunction((yyvsp[0].string_)); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5803 "Parser.c"
    break;

  case 272: /* CHAR_FUNC: _SYMB_53  */
#line 989 "HAL_S.y"
             { (yyval.char_func_) = make_AAcharFuncCharacter(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5809 "Parser.c"
    break;

  case 273: /* CHAR_ID: _SYMB_185  */
#line 991 "HAL_S.y"
                    { (yyval.char_id_) = make_FIchar_id((yyvsp[0].string_)); (yyval.char_id_)->line_number = (yyloc).first_line; (yyval.char_id_)->char_number = (yyloc).first_column;  }
#line 5815 "Parser.c"
    break;

  case 274: /* NAME_EXP: NAME_KEY _SYMB_2 NAME_VAR _SYMB_1  */
#line 993 "HAL_S.y"
                                             { (yyval.name_exp_) = make_AAnameExpKeyVar((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5821 "Parser.c"
    break;

  case 275: /* NAME_EXP: _SYMB_111  */
#line 994 "HAL_S.y"
              { (yyval.name_exp_) = make_ABnameExpNull(); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5827 "Parser.c"
    break;

  case 276: /* NAME_EXP: NAME_KEY _SYMB_2 _SYMB_111 _SYMB_1  */
#line 995 "HAL_S.y"
                                       { (yyval.name_exp_) = make_ACnameExpKeyNull((yyvsp[-3].name_key_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5833 "Parser.c"
    break;

  case 277: /* NAME_KEY: _SYMB_107  */
#line 997 "HAL_S.y"
                     { (yyval.name_key_) = make_AAname_key(); (yyval.name_key_)->line_number = (yyloc).first_line; (yyval.name_key_)->char_number = (yyloc).first_column;  }
#line 5839 "Parser.c"
    break;

  case 278: /* NAME_VAR: VARIABLE  */
#line 999 "HAL_S.y"
                    { (yyval.name_var_) = make_AAname_var((yyvsp[0].variable_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5845 "Parser.c"
    break;

  case 279: /* NAME_VAR: MODIFIED_ARITH_FUNC  */
#line 1000 "HAL_S.y"
                        { (yyval.name_var_) = make_ACname_var((yyvsp[0].modified_arith_func_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5851 "Parser.c"
    break;

  case 280: /* NAME_VAR: LABEL_VAR  */
#line 1001 "HAL_S.y"
              { (yyval.name_var_) = make_ABname_var((yyvsp[0].label_var_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5857 "Parser.c"
    break;

  case 281: /* VARIABLE: ARITH_VAR  */
#line 1003 "HAL_S.y"
                     { (yyval.variable_) = make_AAvariable((yyvsp[0].arith_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5863 "Parser.c"
    break;

  case 282: /* VARIABLE: BIT_VAR  */
#line 1004 "HAL_S.y"
            { (yyval.variable_) = make_ACvariable((yyvsp[0].bit_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5869 "Parser.c"
    break;

  case 283: /* VARIABLE: SUBBIT_HEAD VARIABLE _SYMB_1  */
#line 1005 "HAL_S.y"
                                 { (yyval.variable_) = make_AEvariable((yyvsp[-2].subbit_head_), (yyvsp[-1].variable_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5875 "Parser.c"
    break;

  case 284: /* VARIABLE: CHAR_VAR  */
#line 1006 "HAL_S.y"
             { (yyval.variable_) = make_AFvariable((yyvsp[0].char_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5881 "Parser.c"
    break;

  case 285: /* VARIABLE: NAME_KEY _SYMB_2 NAME_VAR _SYMB_1  */
#line 1007 "HAL_S.y"
                                      { (yyval.variable_) = make_AGvariable((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5887 "Parser.c"
    break;

  case 286: /* VARIABLE: EVENT_VAR  */
#line 1008 "HAL_S.y"
              { (yyval.variable_) = make_ADvariable((yyvsp[0].event_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5893 "Parser.c"
    break;

  case 287: /* VARIABLE: STRUCTURE_VAR  */
#line 1009 "HAL_S.y"
                  { (yyval.variable_) = make_ABvariable((yyvsp[0].structure_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5899 "Parser.c"
    break;

  case 288: /* STRUCTURE_EXP: STRUCTURE_VAR  */
#line 1011 "HAL_S.y"
                              { (yyval.structure_exp_) = make_AAstructure_exp((yyvsp[0].structure_var_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5905 "Parser.c"
    break;

  case 289: /* STRUCTURE_EXP: STRUCT_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 1012 "HAL_S.y"
                                               { (yyval.structure_exp_) = make_ADstructure_exp((yyvsp[-3].struct_func_head_), (yyvsp[-1].call_list_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5911 "Parser.c"
    break;

  case 290: /* STRUCTURE_EXP: STRUC_INLINE_DEF CLOSING _SYMB_16  */
#line 1013 "HAL_S.y"
                                      { (yyval.structure_exp_) = make_ACstructure_exp((yyvsp[-2].struc_inline_def_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5917 "Parser.c"
    break;

  case 291: /* STRUCTURE_EXP: STRUC_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1014 "HAL_S.y"
                                                 { (yyval.structure_exp_) = make_AEstructure_exp((yyvsp[-3].struc_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5923 "Parser.c"
    break;

  case 292: /* STRUCT_FUNC_HEAD: STRUCT_FUNC  */
#line 1016 "HAL_S.y"
                               { (yyval.struct_func_head_) = make_AAstruct_func_head((yyvsp[0].struct_func_)); (yyval.struct_func_head_)->line_number = (yyloc).first_line; (yyval.struct_func_head_)->char_number = (yyloc).first_column;  }
#line 5929 "Parser.c"
    break;

  case 293: /* STRUCTURE_VAR: QUAL_STRUCT SUBSCRIPT  */
#line 1018 "HAL_S.y"
                                      { (yyval.structure_var_) = make_AAstructure_var((yyvsp[-1].qual_struct_), (yyvsp[0].subscript_)); (yyval.structure_var_)->line_number = (yyloc).first_line; (yyval.structure_var_)->char_number = (yyloc).first_column;  }
#line 5935 "Parser.c"
    break;

  case 294: /* STRUCT_FUNC: _SYMB_187  */
#line 1020 "HAL_S.y"
                        { (yyval.struct_func_) = make_ZZuserStructFunc((yyvsp[0].string_)); (yyval.struct_func_)->line_number = (yyloc).first_line; (yyval.struct_func_)->char_number = (yyloc).first_column;  }
#line 5941 "Parser.c"
    break;

  case 295: /* QUAL_STRUCT: STRUCTURE_ID  */
#line 1022 "HAL_S.y"
                           { (yyval.qual_struct_) = make_AAqual_struct((yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 5947 "Parser.c"
    break;

  case 296: /* QUAL_STRUCT: QUAL_STRUCT _SYMB_7 STRUCTURE_ID  */
#line 1023 "HAL_S.y"
                                     { (yyval.qual_struct_) = make_ABqual_struct((yyvsp[-2].qual_struct_), (yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 5953 "Parser.c"
    break;

  case 297: /* STRUCTURE_ID: _SYMB_186  */
#line 1025 "HAL_S.y"
                         { (yyval.structure_id_) = make_FJstructure_id((yyvsp[0].string_)); (yyval.structure_id_)->line_number = (yyloc).first_line; (yyval.structure_id_)->char_number = (yyloc).first_column;  }
#line 5959 "Parser.c"
    break;

  case 298: /* ASSIGNMENT: VARIABLE EQUALS EXPRESSION  */
#line 1027 "HAL_S.y"
                                        { (yyval.assignment_) = make_AAassignment((yyvsp[-2].variable_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5965 "Parser.c"
    break;

  case 299: /* ASSIGNMENT: VARIABLE _SYMB_0 ASSIGNMENT  */
#line 1028 "HAL_S.y"
                                { (yyval.assignment_) = make_ABassignment((yyvsp[-2].variable_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5971 "Parser.c"
    break;

  case 300: /* ASSIGNMENT: QUAL_STRUCT EQUALS EXPRESSION  */
#line 1029 "HAL_S.y"
                                  { (yyval.assignment_) = make_ACassignment((yyvsp[-2].qual_struct_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5977 "Parser.c"
    break;

  case 301: /* ASSIGNMENT: QUAL_STRUCT _SYMB_0 ASSIGNMENT  */
#line 1030 "HAL_S.y"
                                   { (yyval.assignment_) = make_ADassignment((yyvsp[-2].qual_struct_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5983 "Parser.c"
    break;

  case 302: /* EQUALS: _SYMB_23  */
#line 1032 "HAL_S.y"
                  { (yyval.equals_) = make_AAequals(); (yyval.equals_)->line_number = (yyloc).first_line; (yyval.equals_)->char_number = (yyloc).first_column;  }
#line 5989 "Parser.c"
    break;

  case 303: /* IF_STATEMENT: IF_CLAUSE STATEMENT  */
#line 1034 "HAL_S.y"
                                   { (yyval.if_statement_) = make_AAifStatement((yyvsp[-1].if_clause_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 5995 "Parser.c"
    break;

  case 304: /* IF_STATEMENT: TRUE_PART STATEMENT  */
#line 1035 "HAL_S.y"
                        { (yyval.if_statement_) = make_ABifThenElseStatement((yyvsp[-1].true_part_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 6001 "Parser.c"
    break;

  case 305: /* IF_CLAUSE: IF RELATIONAL_EXP THEN  */
#line 1037 "HAL_S.y"
                                   { (yyval.if_clause_) = make_AAifClauseRelationalExp((yyvsp[-2].if_), (yyvsp[-1].relational_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 6007 "Parser.c"
    break;

  case 306: /* IF_CLAUSE: IF BIT_EXP THEN  */
#line 1038 "HAL_S.y"
                    { (yyval.if_clause_) = make_ABifClauseBitExp((yyvsp[-2].if_), (yyvsp[-1].bit_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 6013 "Parser.c"
    break;

  case 307: /* TRUE_PART: IF_CLAUSE BASIC_STATEMENT _SYMB_70  */
#line 1040 "HAL_S.y"
                                               { (yyval.true_part_) = make_AAtrue_part((yyvsp[-2].if_clause_), (yyvsp[-1].basic_statement_)); (yyval.true_part_)->line_number = (yyloc).first_line; (yyval.true_part_)->char_number = (yyloc).first_column;  }
#line 6019 "Parser.c"
    break;

  case 308: /* IF: _SYMB_89  */
#line 1042 "HAL_S.y"
              { (yyval.if_) = make_AAif(); (yyval.if_)->line_number = (yyloc).first_line; (yyval.if_)->char_number = (yyloc).first_column;  }
#line 6025 "Parser.c"
    break;

  case 309: /* THEN: _SYMB_164  */
#line 1044 "HAL_S.y"
                 { (yyval.then_) = make_AAthen(); (yyval.then_)->line_number = (yyloc).first_line; (yyval.then_)->char_number = (yyloc).first_column;  }
#line 6031 "Parser.c"
    break;

  case 310: /* RELATIONAL_EXP: RELATIONAL_FACTOR  */
#line 1046 "HAL_S.y"
                                   { (yyval.relational_exp_) = make_AArelational_exp((yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 6037 "Parser.c"
    break;

  case 311: /* RELATIONAL_EXP: RELATIONAL_EXP OR RELATIONAL_FACTOR  */
#line 1047 "HAL_S.y"
                                        { (yyval.relational_exp_) = make_ABrelational_exp((yyvsp[-2].relational_exp_), (yyvsp[-1].or_), (yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 6043 "Parser.c"
    break;

  case 312: /* RELATIONAL_FACTOR: REL_PRIM  */
#line 1049 "HAL_S.y"
                             { (yyval.relational_factor_) = make_AArelational_factor((yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 6049 "Parser.c"
    break;

  case 313: /* RELATIONAL_FACTOR: RELATIONAL_FACTOR AND REL_PRIM  */
#line 1050 "HAL_S.y"
                                   { (yyval.relational_factor_) = make_ABrelational_factor((yyvsp[-2].relational_factor_), (yyvsp[-1].and_), (yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 6055 "Parser.c"
    break;

  case 314: /* REL_PRIM: _SYMB_2 RELATIONAL_EXP _SYMB_1  */
#line 1052 "HAL_S.y"
                                          { (yyval.rel_prim_) = make_AArel_prim((yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6061 "Parser.c"
    break;

  case 315: /* REL_PRIM: NOT _SYMB_2 RELATIONAL_EXP _SYMB_1  */
#line 1053 "HAL_S.y"
                                       { (yyval.rel_prim_) = make_ABrel_prim((yyvsp[-3].not_), (yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6067 "Parser.c"
    break;

  case 316: /* REL_PRIM: COMPARISON  */
#line 1054 "HAL_S.y"
               { (yyval.rel_prim_) = make_ACrel_prim((yyvsp[0].comparison_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6073 "Parser.c"
    break;

  case 317: /* COMPARISON: ARITH_EXP RELATIONAL_OP ARITH_EXP  */
#line 1056 "HAL_S.y"
                                               { (yyval.comparison_) = make_AAcomparison((yyvsp[-2].arith_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6079 "Parser.c"
    break;

  case 318: /* COMPARISON: CHAR_EXP RELATIONAL_OP CHAR_EXP  */
#line 1057 "HAL_S.y"
                                    { (yyval.comparison_) = make_ABcomparison((yyvsp[-2].char_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6085 "Parser.c"
    break;

  case 319: /* COMPARISON: BIT_CAT RELATIONAL_OP BIT_CAT  */
#line 1058 "HAL_S.y"
                                  { (yyval.comparison_) = make_ACcomparison((yyvsp[-2].bit_cat_), (yyvsp[-1].relational_op_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6091 "Parser.c"
    break;

  case 320: /* COMPARISON: STRUCTURE_EXP RELATIONAL_OP STRUCTURE_EXP  */
#line 1059 "HAL_S.y"
                                              { (yyval.comparison_) = make_ADcomparison((yyvsp[-2].structure_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6097 "Parser.c"
    break;

  case 321: /* COMPARISON: NAME_EXP RELATIONAL_OP NAME_EXP  */
#line 1060 "HAL_S.y"
                                    { (yyval.comparison_) = make_AEcomparison((yyvsp[-2].name_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6103 "Parser.c"
    break;

  case 322: /* RELATIONAL_OP: EQUALS  */
#line 1062 "HAL_S.y"
                       { (yyval.relational_op_) = make_AArelationalOpEQ((yyvsp[0].equals_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6109 "Parser.c"
    break;

  case 323: /* RELATIONAL_OP: _SYMB_179  */
#line 1063 "HAL_S.y"
              { (yyval.relational_op_) = make_ABrelationalOpNEQ((yyvsp[0].string_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6115 "Parser.c"
    break;

  case 324: /* RELATIONAL_OP: _SYMB_22  */
#line 1064 "HAL_S.y"
             { (yyval.relational_op_) = make_ACrelationalOpLT(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6121 "Parser.c"
    break;

  case 325: /* RELATIONAL_OP: _SYMB_24  */
#line 1065 "HAL_S.y"
             { (yyval.relational_op_) = make_ADrelationalOpGT(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6127 "Parser.c"
    break;

  case 326: /* RELATIONAL_OP: _SYMB_180  */
#line 1066 "HAL_S.y"
              { (yyval.relational_op_) = make_AErelationalOpLE((yyvsp[0].string_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6133 "Parser.c"
    break;

  case 327: /* RELATIONAL_OP: _SYMB_181  */
#line 1067 "HAL_S.y"
              { (yyval.relational_op_) = make_AFrelationalOpGE((yyvsp[0].string_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6139 "Parser.c"
    break;

  case 328: /* STATEMENT: BASIC_STATEMENT  */
#line 1069 "HAL_S.y"
                            { (yyval.statement_) = make_AAstatement((yyvsp[0].basic_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6145 "Parser.c"
    break;

  case 329: /* STATEMENT: OTHER_STATEMENT  */
#line 1070 "HAL_S.y"
                    { (yyval.statement_) = make_ABstatement((yyvsp[0].other_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6151 "Parser.c"
    break;

  case 330: /* STATEMENT: INLINE_DEFINITION  */
#line 1071 "HAL_S.y"
                      { (yyval.statement_) = make_AZstatement((yyvsp[0].inline_definition_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6157 "Parser.c"
    break;

  case 331: /* BASIC_STATEMENT: ASSIGNMENT _SYMB_16  */
#line 1073 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_ABbasicStatementAssignment((yyvsp[-1].assignment_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6163 "Parser.c"
    break;

  case 332: /* BASIC_STATEMENT: LABEL_DEFINITION BASIC_STATEMENT  */
#line 1074 "HAL_S.y"
                                     { (yyval.basic_statement_) = make_AAbasic_statement((yyvsp[-1].label_definition_), (yyvsp[0].basic_statement_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6169 "Parser.c"
    break;

  case 333: /* BASIC_STATEMENT: _SYMB_79 _SYMB_16  */
#line 1075 "HAL_S.y"
                      { (yyval.basic_statement_) = make_ACbasicStatementExit(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6175 "Parser.c"
    break;

  case 334: /* BASIC_STATEMENT: _SYMB_79 LABEL _SYMB_16  */
#line 1076 "HAL_S.y"
                            { (yyval.basic_statement_) = make_ADbasicStatementExit((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6181 "Parser.c"
    break;

  case 335: /* BASIC_STATEMENT: _SYMB_130 _SYMB_16  */
#line 1077 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AEbasicStatementRepeat(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6187 "Parser.c"
    break;

  case 336: /* BASIC_STATEMENT: _SYMB_130 LABEL _SYMB_16  */
#line 1078 "HAL_S.y"
                             { (yyval.basic_statement_) = make_AFbasicStatementRepeat((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6193 "Parser.c"
    break;

  case 337: /* BASIC_STATEMENT: _SYMB_87 _SYMB_165 LABEL _SYMB_16  */
#line 1079 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AGbasicStatementGoTo((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6199 "Parser.c"
    break;

  case 338: /* BASIC_STATEMENT: _SYMB_16  */
#line 1080 "HAL_S.y"
             { (yyval.basic_statement_) = make_AHbasicStatementEmpty(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6205 "Parser.c"
    break;

  case 339: /* BASIC_STATEMENT: CALL_KEY _SYMB_16  */
#line 1081 "HAL_S.y"
                      { (yyval.basic_statement_) = make_AIbasicStatementCall((yyvsp[-1].call_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6211 "Parser.c"
    break;

  case 340: /* BASIC_STATEMENT: CALL_KEY _SYMB_2 CALL_LIST _SYMB_1 _SYMB_16  */
#line 1082 "HAL_S.y"
                                                { (yyval.basic_statement_) = make_AJbasicStatementCall((yyvsp[-4].call_key_), (yyvsp[-2].call_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6217 "Parser.c"
    break;

  case 341: /* BASIC_STATEMENT: CALL_KEY ASSIGN _SYMB_2 CALL_ASSIGN_LIST _SYMB_1 _SYMB_16  */
#line 1083 "HAL_S.y"
                                                              { (yyval.basic_statement_) = make_AKbasicStatementCall((yyvsp[-5].call_key_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6223 "Parser.c"
    break;

  case 342: /* BASIC_STATEMENT: CALL_KEY _SYMB_2 CALL_LIST _SYMB_1 ASSIGN _SYMB_2 CALL_ASSIGN_LIST _SYMB_1 _SYMB_16  */
#line 1084 "HAL_S.y"
                                                                                        { (yyval.basic_statement_) = make_ALbasicStatementCall((yyvsp[-8].call_key_), (yyvsp[-6].call_list_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6229 "Parser.c"
    break;

  case 343: /* BASIC_STATEMENT: _SYMB_133 _SYMB_16  */
#line 1085 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AMbasicStatementReturn(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6235 "Parser.c"
    break;

  case 344: /* BASIC_STATEMENT: _SYMB_133 EXPRESSION _SYMB_16  */
#line 1086 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_ANbasicStatementReturn((yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6241 "Parser.c"
    break;

  case 345: /* BASIC_STATEMENT: DO_GROUP_HEAD ENDING _SYMB_16  */
#line 1087 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_AObasicStatementDo((yyvsp[-2].do_group_head_), (yyvsp[-1].ending_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6247 "Parser.c"
    break;

  case 346: /* BASIC_STATEMENT: READ_KEY _SYMB_16  */
#line 1088 "HAL_S.y"
                      { (yyval.basic_statement_) = make_APbasicStatementReadKey((yyvsp[-1].read_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6253 "Parser.c"
    break;

  case 347: /* BASIC_STATEMENT: READ_PHRASE _SYMB_16  */
#line 1089 "HAL_S.y"
                         { (yyval.basic_statement_) = make_AQbasicStatementReadPhrase((yyvsp[-1].read_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6259 "Parser.c"
    break;

  case 348: /* BASIC_STATEMENT: WRITE_KEY _SYMB_16  */
#line 1090 "HAL_S.y"
                       { (yyval.basic_statement_) = make_ARbasicStatementWriteKey((yyvsp[-1].write_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6265 "Parser.c"
    break;

  case 349: /* BASIC_STATEMENT: WRITE_PHRASE _SYMB_16  */
#line 1091 "HAL_S.y"
                          { (yyval.basic_statement_) = make_ASbasicStatementWritePhrase((yyvsp[-1].write_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6271 "Parser.c"
    break;

  case 350: /* BASIC_STATEMENT: FILE_EXP EQUALS EXPRESSION _SYMB_16  */
#line 1092 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_ATbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6277 "Parser.c"
    break;

  case 351: /* BASIC_STATEMENT: VARIABLE EQUALS FILE_EXP _SYMB_16  */
#line 1093 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AUbasicStatementFileExp((yyvsp[-3].variable_), (yyvsp[-2].equals_), (yyvsp[-1].file_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6283 "Parser.c"
    break;

  case 352: /* BASIC_STATEMENT: FILE_EXP EQUALS QUAL_STRUCT _SYMB_16  */
#line 1094 "HAL_S.y"
                                         { (yyval.basic_statement_) = make_AVbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].qual_struct_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6289 "Parser.c"
    break;

  case 353: /* BASIC_STATEMENT: WAIT_KEY _SYMB_85 _SYMB_65 _SYMB_16  */
#line 1095 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_AVbasicStatementWait((yyvsp[-3].wait_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6295 "Parser.c"
    break;

  case 354: /* BASIC_STATEMENT: WAIT_KEY ARITH_EXP _SYMB_16  */
#line 1096 "HAL_S.y"
                                { (yyval.basic_statement_) = make_AWbasicStatementWait((yyvsp[-2].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6301 "Parser.c"
    break;

  case 355: /* BASIC_STATEMENT: WAIT_KEY _SYMB_172 ARITH_EXP _SYMB_16  */
#line 1097 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_AXbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6307 "Parser.c"
    break;

  case 356: /* BASIC_STATEMENT: WAIT_KEY _SYMB_85 BIT_EXP _SYMB_16  */
#line 1098 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_AYbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].bit_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6313 "Parser.c"
    break;

  case 357: /* BASIC_STATEMENT: TERMINATOR _SYMB_16  */
#line 1099 "HAL_S.y"
                        { (yyval.basic_statement_) = make_AZbasicStatementTerminator((yyvsp[-1].terminator_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6319 "Parser.c"
    break;

  case 358: /* BASIC_STATEMENT: TERMINATOR TERMINATE_LIST _SYMB_16  */
#line 1100 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_BAbasicStatementTerminator((yyvsp[-2].terminator_), (yyvsp[-1].terminate_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6325 "Parser.c"
    break;

  case 359: /* BASIC_STATEMENT: _SYMB_173 _SYMB_119 _SYMB_165 ARITH_EXP _SYMB_16  */
#line 1101 "HAL_S.y"
                                                     { (yyval.basic_statement_) = make_BBbasicStatementUpdate((yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6331 "Parser.c"
    break;

  case 360: /* BASIC_STATEMENT: _SYMB_173 _SYMB_119 LABEL_VAR _SYMB_165 ARITH_EXP _SYMB_16  */
#line 1102 "HAL_S.y"
                                                               { (yyval.basic_statement_) = make_BCbasicStatementUpdate((yyvsp[-3].label_var_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6337 "Parser.c"
    break;

  case 361: /* BASIC_STATEMENT: SCHEDULE_PHRASE _SYMB_16  */
#line 1103 "HAL_S.y"
                             { (yyval.basic_statement_) = make_BDbasicStatementSchedule((yyvsp[-1].schedule_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6343 "Parser.c"
    break;

  case 362: /* BASIC_STATEMENT: SCHEDULE_PHRASE SCHEDULE_CONTROL _SYMB_16  */
#line 1104 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BEbasicStatementSchedule((yyvsp[-2].schedule_phrase_), (yyvsp[-1].schedule_control_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6349 "Parser.c"
    break;

  case 363: /* BASIC_STATEMENT: SIGNAL_CLAUSE _SYMB_16  */
#line 1105 "HAL_S.y"
                           { (yyval.basic_statement_) = make_BFbasicStatementSignal((yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6355 "Parser.c"
    break;

  case 364: /* BASIC_STATEMENT: _SYMB_140 _SYMB_75 SUBSCRIPT _SYMB_16  */
#line 1106 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BGbasicStatementSend((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6361 "Parser.c"
    break;

  case 365: /* BASIC_STATEMENT: _SYMB_140 _SYMB_75 _SYMB_16  */
#line 1107 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BHbasicStatementSend(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6367 "Parser.c"
    break;

  case 366: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_16  */
#line 1108 "HAL_S.y"
                       { (yyval.basic_statement_) = make_BHbasicStatementOn((yyvsp[-1].on_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6373 "Parser.c"
    break;

  case 367: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_31 SIGNAL_CLAUSE _SYMB_16  */
#line 1109 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BIbasicStatementOnAndSignal((yyvsp[-3].on_clause_), (yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6379 "Parser.c"
    break;

  case 368: /* BASIC_STATEMENT: _SYMB_114 _SYMB_75 SUBSCRIPT _SYMB_16  */
#line 1110 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BJbasicStatementOff((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6385 "Parser.c"
    break;

  case 369: /* BASIC_STATEMENT: _SYMB_114 _SYMB_75 _SYMB_16  */
#line 1111 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementOff(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6391 "Parser.c"
    break;

  case 370: /* BASIC_STATEMENT: PERCENT_MACRO_NAME _SYMB_16  */
#line 1112 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementPercentMacro((yyvsp[-1].percent_macro_name_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6397 "Parser.c"
    break;

  case 371: /* BASIC_STATEMENT: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_1 _SYMB_16  */
#line 1113 "HAL_S.y"
                                                          { (yyval.basic_statement_) = make_BLbasicStatementPercentMacro((yyvsp[-3].percent_macro_head_), (yyvsp[-2].percent_macro_arg_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6403 "Parser.c"
    break;

  case 372: /* OTHER_STATEMENT: IF_STATEMENT  */
#line 1115 "HAL_S.y"
                               { (yyval.other_statement_) = make_ABotherStatementIf((yyvsp[0].if_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6409 "Parser.c"
    break;

  case 373: /* OTHER_STATEMENT: ON_PHRASE STATEMENT  */
#line 1116 "HAL_S.y"
                        { (yyval.other_statement_) = make_AAotherStatementOn((yyvsp[-1].on_phrase_), (yyvsp[0].statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6415 "Parser.c"
    break;

  case 374: /* OTHER_STATEMENT: LABEL_DEFINITION OTHER_STATEMENT  */
#line 1117 "HAL_S.y"
                                     { (yyval.other_statement_) = make_ACother_statement((yyvsp[-1].label_definition_), (yyvsp[0].other_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6421 "Parser.c"
    break;

  case 375: /* ANY_STATEMENT: STATEMENT  */
#line 1119 "HAL_S.y"
                          { (yyval.any_statement_) = make_AAany_statement((yyvsp[0].statement_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6427 "Parser.c"
    break;

  case 376: /* ANY_STATEMENT: BLOCK_DEFINITION  */
#line 1120 "HAL_S.y"
                     { (yyval.any_statement_) = make_ABany_statement((yyvsp[0].block_definition_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6433 "Parser.c"
    break;

  case 377: /* ON_PHRASE: _SYMB_115 _SYMB_75 SUBSCRIPT  */
#line 1122 "HAL_S.y"
                                         { (yyval.on_phrase_) = make_AAon_phrase((yyvsp[0].subscript_)); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6439 "Parser.c"
    break;

  case 378: /* ON_PHRASE: _SYMB_115 _SYMB_75  */
#line 1123 "HAL_S.y"
                       { (yyval.on_phrase_) = make_ACon_phrase(); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6445 "Parser.c"
    break;

  case 379: /* ON_CLAUSE: _SYMB_115 _SYMB_75 SUBSCRIPT _SYMB_157  */
#line 1125 "HAL_S.y"
                                                   { (yyval.on_clause_) = make_AAon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6451 "Parser.c"
    break;

  case 380: /* ON_CLAUSE: _SYMB_115 _SYMB_75 SUBSCRIPT _SYMB_90  */
#line 1126 "HAL_S.y"
                                          { (yyval.on_clause_) = make_ABon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6457 "Parser.c"
    break;

  case 381: /* ON_CLAUSE: _SYMB_115 _SYMB_75 _SYMB_157  */
#line 1127 "HAL_S.y"
                                 { (yyval.on_clause_) = make_ADon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6463 "Parser.c"
    break;

  case 382: /* ON_CLAUSE: _SYMB_115 _SYMB_75 _SYMB_90  */
#line 1128 "HAL_S.y"
                                { (yyval.on_clause_) = make_AEon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6469 "Parser.c"
    break;

  case 383: /* LABEL_DEFINITION: LABEL _SYMB_17  */
#line 1130 "HAL_S.y"
                                  { (yyval.label_definition_) = make_AAlabel_definition((yyvsp[-1].label_)); (yyval.label_definition_)->line_number = (yyloc).first_line; (yyval.label_definition_)->char_number = (yyloc).first_column;  }
#line 6475 "Parser.c"
    break;

  case 384: /* CALL_KEY: _SYMB_47 LABEL_VAR  */
#line 1132 "HAL_S.y"
                              { (yyval.call_key_) = make_AAcall_key((yyvsp[0].label_var_)); (yyval.call_key_)->line_number = (yyloc).first_line; (yyval.call_key_)->char_number = (yyloc).first_column;  }
#line 6481 "Parser.c"
    break;

  case 385: /* ASSIGN: _SYMB_40  */
#line 1134 "HAL_S.y"
                  { (yyval.assign_) = make_AAassign(); (yyval.assign_)->line_number = (yyloc).first_line; (yyval.assign_)->char_number = (yyloc).first_column;  }
#line 6487 "Parser.c"
    break;

  case 386: /* CALL_ASSIGN_LIST: VARIABLE  */
#line 1136 "HAL_S.y"
                            { (yyval.call_assign_list_) = make_AAcall_assign_list((yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6493 "Parser.c"
    break;

  case 387: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_0 VARIABLE  */
#line 1137 "HAL_S.y"
                                      { (yyval.call_assign_list_) = make_ABcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6499 "Parser.c"
    break;

  case 388: /* CALL_ASSIGN_LIST: QUAL_STRUCT  */
#line 1138 "HAL_S.y"
                { (yyval.call_assign_list_) = make_ACcall_assign_list((yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6505 "Parser.c"
    break;

  case 389: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_0 QUAL_STRUCT  */
#line 1139 "HAL_S.y"
                                         { (yyval.call_assign_list_) = make_ADcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6511 "Parser.c"
    break;

  case 390: /* DO_GROUP_HEAD: _SYMB_68 _SYMB_16  */
#line 1141 "HAL_S.y"
                                  { (yyval.do_group_head_) = make_AAdoGroupHead(); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6517 "Parser.c"
    break;

  case 391: /* DO_GROUP_HEAD: _SYMB_68 FOR_LIST _SYMB_16  */
#line 1142 "HAL_S.y"
                               { (yyval.do_group_head_) = make_ABdoGroupHeadFor((yyvsp[-1].for_list_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6523 "Parser.c"
    break;

  case 392: /* DO_GROUP_HEAD: _SYMB_68 FOR_LIST WHILE_CLAUSE _SYMB_16  */
#line 1143 "HAL_S.y"
                                            { (yyval.do_group_head_) = make_ACdoGroupHeadForWhile((yyvsp[-2].for_list_), (yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6529 "Parser.c"
    break;

  case 393: /* DO_GROUP_HEAD: _SYMB_68 WHILE_CLAUSE _SYMB_16  */
#line 1144 "HAL_S.y"
                                   { (yyval.do_group_head_) = make_ADdoGroupHeadWhile((yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6535 "Parser.c"
    break;

  case 394: /* DO_GROUP_HEAD: _SYMB_68 _SYMB_49 ARITH_EXP _SYMB_16  */
#line 1145 "HAL_S.y"
                                         { (yyval.do_group_head_) = make_AEdoGroupHeadCase((yyvsp[-1].arith_exp_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6541 "Parser.c"
    break;

  case 395: /* DO_GROUP_HEAD: CASE_ELSE STATEMENT  */
#line 1146 "HAL_S.y"
                        { (yyval.do_group_head_) = make_AFdoGroupHeadCaseElse((yyvsp[-1].case_else_), (yyvsp[0].statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6547 "Parser.c"
    break;

  case 396: /* DO_GROUP_HEAD: DO_GROUP_HEAD ANY_STATEMENT  */
#line 1147 "HAL_S.y"
                                { (yyval.do_group_head_) = make_AGdoGroupHeadStatement((yyvsp[-1].do_group_head_), (yyvsp[0].any_statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6553 "Parser.c"
    break;

  case 397: /* DO_GROUP_HEAD: DO_GROUP_HEAD TEMPORARY_STMT  */
#line 1148 "HAL_S.y"
                                 { (yyval.do_group_head_) = make_AHdoGroupHeadTemporaryStatement((yyvsp[-1].do_group_head_), (yyvsp[0].temporary_stmt_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6559 "Parser.c"
    break;

  case 398: /* ENDING: _SYMB_71  */
#line 1150 "HAL_S.y"
                  { (yyval.ending_) = make_AAending(); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6565 "Parser.c"
    break;

  case 399: /* ENDING: _SYMB_71 LABEL  */
#line 1151 "HAL_S.y"
                   { (yyval.ending_) = make_ABending((yyvsp[0].label_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6571 "Parser.c"
    break;

  case 400: /* ENDING: LABEL_DEFINITION ENDING  */
#line 1152 "HAL_S.y"
                            { (yyval.ending_) = make_ACending((yyvsp[-1].label_definition_), (yyvsp[0].ending_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6577 "Parser.c"
    break;

  case 401: /* READ_KEY: _SYMB_125 _SYMB_2 NUMBER _SYMB_1  */
#line 1154 "HAL_S.y"
                                            { (yyval.read_key_) = make_AAread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 6583 "Parser.c"
    break;

  case 402: /* READ_KEY: _SYMB_126 _SYMB_2 NUMBER _SYMB_1  */
#line 1155 "HAL_S.y"
                                     { (yyval.read_key_) = make_ABread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 6589 "Parser.c"
    break;

  case 403: /* WRITE_KEY: _SYMB_177 _SYMB_2 NUMBER _SYMB_1  */
#line 1157 "HAL_S.y"
                                             { (yyval.write_key_) = make_AAwrite_key((yyvsp[-1].number_)); (yyval.write_key_)->line_number = (yyloc).first_line; (yyval.write_key_)->char_number = (yyloc).first_column;  }
#line 6595 "Parser.c"
    break;

  case 404: /* READ_PHRASE: READ_KEY READ_ARG  */
#line 1159 "HAL_S.y"
                                { (yyval.read_phrase_) = make_AAread_phrase((yyvsp[-1].read_key_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 6601 "Parser.c"
    break;

  case 405: /* READ_PHRASE: READ_PHRASE _SYMB_0 READ_ARG  */
#line 1160 "HAL_S.y"
                                 { (yyval.read_phrase_) = make_ABread_phrase((yyvsp[-2].read_phrase_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 6607 "Parser.c"
    break;

  case 406: /* WRITE_PHRASE: WRITE_KEY WRITE_ARG  */
#line 1162 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_AAwrite_phrase((yyvsp[-1].write_key_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 6613 "Parser.c"
    break;

  case 407: /* WRITE_PHRASE: WRITE_PHRASE _SYMB_0 WRITE_ARG  */
#line 1163 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_ABwrite_phrase((yyvsp[-2].write_phrase_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 6619 "Parser.c"
    break;

  case 408: /* READ_ARG: VARIABLE  */
#line 1165 "HAL_S.y"
                    { (yyval.read_arg_) = make_AAread_arg((yyvsp[0].variable_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 6625 "Parser.c"
    break;

  case 409: /* READ_ARG: IO_CONTROL  */
#line 1166 "HAL_S.y"
               { (yyval.read_arg_) = make_ABread_arg((yyvsp[0].io_control_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 6631 "Parser.c"
    break;

  case 410: /* WRITE_ARG: EXPRESSION  */
#line 1168 "HAL_S.y"
                       { (yyval.write_arg_) = make_AAwrite_arg((yyvsp[0].expression_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6637 "Parser.c"
    break;

  case 411: /* WRITE_ARG: IO_CONTROL  */
#line 1169 "HAL_S.y"
               { (yyval.write_arg_) = make_ABwrite_arg((yyvsp[0].io_control_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6643 "Parser.c"
    break;

  case 412: /* WRITE_ARG: _SYMB_186  */
#line 1170 "HAL_S.y"
              { (yyval.write_arg_) = make_ACwrite_arg((yyvsp[0].string_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6649 "Parser.c"
    break;

  case 413: /* FILE_EXP: FILE_HEAD _SYMB_0 ARITH_EXP _SYMB_1  */
#line 1172 "HAL_S.y"
                                               { (yyval.file_exp_) = make_AAfile_exp((yyvsp[-3].file_head_), (yyvsp[-1].arith_exp_)); (yyval.file_exp_)->line_number = (yyloc).first_line; (yyval.file_exp_)->char_number = (yyloc).first_column;  }
#line 6655 "Parser.c"
    break;

  case 414: /* FILE_HEAD: _SYMB_83 _SYMB_2 NUMBER  */
#line 1174 "HAL_S.y"
                                    { (yyval.file_head_) = make_AAfile_head((yyvsp[0].number_)); (yyval.file_head_)->line_number = (yyloc).first_line; (yyval.file_head_)->char_number = (yyloc).first_column;  }
#line 6661 "Parser.c"
    break;

  case 415: /* IO_CONTROL: _SYMB_151 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1176 "HAL_S.y"
                                                 { (yyval.io_control_) = make_AAioControlSkip((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6667 "Parser.c"
    break;

  case 416: /* IO_CONTROL: _SYMB_158 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1177 "HAL_S.y"
                                        { (yyval.io_control_) = make_ABioControlTab((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6673 "Parser.c"
    break;

  case 417: /* IO_CONTROL: _SYMB_56 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1178 "HAL_S.y"
                                       { (yyval.io_control_) = make_ACioControlColumn((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6679 "Parser.c"
    break;

  case 418: /* IO_CONTROL: _SYMB_98 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1179 "HAL_S.y"
                                       { (yyval.io_control_) = make_ADioControlLine((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6685 "Parser.c"
    break;

  case 419: /* IO_CONTROL: _SYMB_117 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1180 "HAL_S.y"
                                        { (yyval.io_control_) = make_AEioControlPage((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6691 "Parser.c"
    break;

  case 420: /* WAIT_KEY: _SYMB_175  */
#line 1182 "HAL_S.y"
                     { (yyval.wait_key_) = make_AAwait_key(); (yyval.wait_key_)->line_number = (yyloc).first_line; (yyval.wait_key_)->char_number = (yyloc).first_column;  }
#line 6697 "Parser.c"
    break;

  case 421: /* TERMINATOR: _SYMB_163  */
#line 1184 "HAL_S.y"
                       { (yyval.terminator_) = make_AAterminatorTerminate(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 6703 "Parser.c"
    break;

  case 422: /* TERMINATOR: _SYMB_48  */
#line 1185 "HAL_S.y"
             { (yyval.terminator_) = make_ABterminatorCancel(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 6709 "Parser.c"
    break;

  case 423: /* TERMINATE_LIST: LABEL_VAR  */
#line 1187 "HAL_S.y"
                           { (yyval.terminate_list_) = make_AAterminate_list((yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 6715 "Parser.c"
    break;

  case 424: /* TERMINATE_LIST: TERMINATE_LIST _SYMB_0 LABEL_VAR  */
#line 1188 "HAL_S.y"
                                     { (yyval.terminate_list_) = make_ABterminate_list((yyvsp[-2].terminate_list_), (yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 6721 "Parser.c"
    break;

  case 425: /* SCHEDULE_HEAD: _SYMB_139 LABEL_VAR  */
#line 1190 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_AAscheduleHeadLabel((yyvsp[0].label_var_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6727 "Parser.c"
    break;

  case 426: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_41 ARITH_EXP  */
#line 1191 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ABscheduleHeadAt((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6733 "Parser.c"
    break;

  case 427: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_91 ARITH_EXP  */
#line 1192 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ACscheduleHeadIn((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6739 "Parser.c"
    break;

  case 428: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_115 BIT_EXP  */
#line 1193 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_ADscheduleHeadOn((yyvsp[-2].schedule_head_), (yyvsp[0].bit_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6745 "Parser.c"
    break;

  case 429: /* SCHEDULE_PHRASE: SCHEDULE_HEAD  */
#line 1195 "HAL_S.y"
                                { (yyval.schedule_phrase_) = make_AAschedule_phrase((yyvsp[0].schedule_head_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6751 "Parser.c"
    break;

  case 430: /* SCHEDULE_PHRASE: SCHEDULE_HEAD _SYMB_119 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1196 "HAL_S.y"
                                                      { (yyval.schedule_phrase_) = make_ABschedule_phrase((yyvsp[-4].schedule_head_), (yyvsp[-1].arith_exp_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6757 "Parser.c"
    break;

  case 431: /* SCHEDULE_PHRASE: SCHEDULE_PHRASE _SYMB_65  */
#line 1197 "HAL_S.y"
                             { (yyval.schedule_phrase_) = make_ACschedule_phrase((yyvsp[-1].schedule_phrase_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6763 "Parser.c"
    break;

  case 432: /* SCHEDULE_CONTROL: STOPPING  */
#line 1199 "HAL_S.y"
                            { (yyval.schedule_control_) = make_AAschedule_control((yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6769 "Parser.c"
    break;

  case 433: /* SCHEDULE_CONTROL: TIMING  */
#line 1200 "HAL_S.y"
           { (yyval.schedule_control_) = make_ABschedule_control((yyvsp[0].timing_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6775 "Parser.c"
    break;

  case 434: /* SCHEDULE_CONTROL: TIMING STOPPING  */
#line 1201 "HAL_S.y"
                    { (yyval.schedule_control_) = make_ACschedule_control((yyvsp[-1].timing_), (yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6781 "Parser.c"
    break;

  case 435: /* TIMING: REPEAT _SYMB_77 ARITH_EXP  */
#line 1203 "HAL_S.y"
                                   { (yyval.timing_) = make_AAtimingEvery((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6787 "Parser.c"
    break;

  case 436: /* TIMING: REPEAT _SYMB_29 ARITH_EXP  */
#line 1204 "HAL_S.y"
                              { (yyval.timing_) = make_ABtimingAfter((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6793 "Parser.c"
    break;

  case 437: /* TIMING: REPEAT  */
#line 1205 "HAL_S.y"
           { (yyval.timing_) = make_ACtiming((yyvsp[0].repeat_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6799 "Parser.c"
    break;

  case 438: /* REPEAT: _SYMB_0 _SYMB_130  */
#line 1207 "HAL_S.y"
                           { (yyval.repeat_) = make_AArepeat(); (yyval.repeat_)->line_number = (yyloc).first_line; (yyval.repeat_)->char_number = (yyloc).first_column;  }
#line 6805 "Parser.c"
    break;

  case 439: /* STOPPING: WHILE_KEY ARITH_EXP  */
#line 1209 "HAL_S.y"
                               { (yyval.stopping_) = make_AAstopping((yyvsp[-1].while_key_), (yyvsp[0].arith_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 6811 "Parser.c"
    break;

  case 440: /* STOPPING: WHILE_KEY BIT_EXP  */
#line 1210 "HAL_S.y"
                      { (yyval.stopping_) = make_ABstopping((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 6817 "Parser.c"
    break;

  case 441: /* SIGNAL_CLAUSE: _SYMB_141 EVENT_VAR  */
#line 1212 "HAL_S.y"
                                    { (yyval.signal_clause_) = make_AAsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6823 "Parser.c"
    break;

  case 442: /* SIGNAL_CLAUSE: _SYMB_132 EVENT_VAR  */
#line 1213 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ABsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6829 "Parser.c"
    break;

  case 443: /* SIGNAL_CLAUSE: _SYMB_145 EVENT_VAR  */
#line 1214 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ACsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6835 "Parser.c"
    break;

  case 444: /* PERCENT_MACRO_NAME: _SYMB_25 IDENTIFIER  */
#line 1216 "HAL_S.y"
                                         { (yyval.percent_macro_name_) = make_FNpercent_macro_name((yyvsp[0].identifier_)); (yyval.percent_macro_name_)->line_number = (yyloc).first_line; (yyval.percent_macro_name_)->char_number = (yyloc).first_column;  }
#line 6841 "Parser.c"
    break;

  case 445: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_NAME _SYMB_2  */
#line 1218 "HAL_S.y"
                                                { (yyval.percent_macro_head_) = make_AApercent_macro_head((yyvsp[-1].percent_macro_name_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 6847 "Parser.c"
    break;

  case 446: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_0  */
#line 1219 "HAL_S.y"
                                                 { (yyval.percent_macro_head_) = make_ABpercent_macro_head((yyvsp[-2].percent_macro_head_), (yyvsp[-1].percent_macro_arg_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 6853 "Parser.c"
    break;

  case 447: /* PERCENT_MACRO_ARG: NAME_VAR  */
#line 1221 "HAL_S.y"
                             { (yyval.percent_macro_arg_) = make_AApercent_macro_arg((yyvsp[0].name_var_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 6859 "Parser.c"
    break;

  case 448: /* PERCENT_MACRO_ARG: CONSTANT  */
#line 1222 "HAL_S.y"
             { (yyval.percent_macro_arg_) = make_ABpercent_macro_arg((yyvsp[0].constant_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 6865 "Parser.c"
    break;

  case 449: /* CASE_ELSE: _SYMB_68 _SYMB_49 ARITH_EXP _SYMB_16 _SYMB_70  */
#line 1224 "HAL_S.y"
                                                          { (yyval.case_else_) = make_AAcase_else((yyvsp[-2].arith_exp_)); (yyval.case_else_)->line_number = (yyloc).first_line; (yyval.case_else_)->char_number = (yyloc).first_column;  }
#line 6871 "Parser.c"
    break;

  case 450: /* WHILE_KEY: _SYMB_176  */
#line 1226 "HAL_S.y"
                      { (yyval.while_key_) = make_AAwhileKeyWhile(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 6877 "Parser.c"
    break;

  case 451: /* WHILE_KEY: _SYMB_172  */
#line 1227 "HAL_S.y"
              { (yyval.while_key_) = make_ABwhileKeyUntil(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 6883 "Parser.c"
    break;

  case 452: /* WHILE_CLAUSE: WHILE_KEY BIT_EXP  */
#line 1229 "HAL_S.y"
                                 { (yyval.while_clause_) = make_AAwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 6889 "Parser.c"
    break;

  case 453: /* WHILE_CLAUSE: WHILE_KEY RELATIONAL_EXP  */
#line 1230 "HAL_S.y"
                             { (yyval.while_clause_) = make_ABwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].relational_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 6895 "Parser.c"
    break;

  case 454: /* FOR_LIST: FOR_KEY ARITH_EXP ITERATION_CONTROL  */
#line 1232 "HAL_S.y"
                                               { (yyval.for_list_) = make_AAfor_list((yyvsp[-2].for_key_), (yyvsp[-1].arith_exp_), (yyvsp[0].iteration_control_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 6901 "Parser.c"
    break;

  case 455: /* FOR_LIST: FOR_KEY ITERATION_BODY  */
#line 1233 "HAL_S.y"
                           { (yyval.for_list_) = make_ABfor_list((yyvsp[-1].for_key_), (yyvsp[0].iteration_body_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 6907 "Parser.c"
    break;

  case 456: /* ITERATION_BODY: ARITH_EXP  */
#line 1235 "HAL_S.y"
                           { (yyval.iteration_body_) = make_AAiteration_body((yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 6913 "Parser.c"
    break;

  case 457: /* ITERATION_BODY: ITERATION_BODY _SYMB_0 ARITH_EXP  */
#line 1236 "HAL_S.y"
                                     { (yyval.iteration_body_) = make_ABiteration_body((yyvsp[-2].iteration_body_), (yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 6919 "Parser.c"
    break;

  case 458: /* ITERATION_CONTROL: _SYMB_165 ARITH_EXP  */
#line 1238 "HAL_S.y"
                                        { (yyval.iteration_control_) = make_AAiteration_controlTo((yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 6925 "Parser.c"
    break;

  case 459: /* ITERATION_CONTROL: _SYMB_165 ARITH_EXP _SYMB_46 ARITH_EXP  */
#line 1239 "HAL_S.y"
                                           { (yyval.iteration_control_) = make_ABiteration_controlToBy((yyvsp[-2].arith_exp_), (yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 6931 "Parser.c"
    break;

  case 460: /* FOR_KEY: _SYMB_85 ARITH_VAR EQUALS  */
#line 1241 "HAL_S.y"
                                    { (yyval.for_key_) = make_AAforKey((yyvsp[-1].arith_var_), (yyvsp[0].equals_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 6937 "Parser.c"
    break;

  case 461: /* FOR_KEY: _SYMB_85 _SYMB_162 IDENTIFIER _SYMB_23  */
#line 1242 "HAL_S.y"
                                           { (yyval.for_key_) = make_ABforKeyTemporary((yyvsp[-1].identifier_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 6943 "Parser.c"
    break;

  case 462: /* TEMPORARY_STMT: _SYMB_162 DECLARE_BODY _SYMB_16  */
#line 1244 "HAL_S.y"
                                                 { (yyval.temporary_stmt_) = make_AAtemporary_stmt((yyvsp[-1].declare_body_)); (yyval.temporary_stmt_)->line_number = (yyloc).first_line; (yyval.temporary_stmt_)->char_number = (yyloc).first_column;  }
#line 6949 "Parser.c"
    break;

  case 463: /* CONSTANT: NUMBER  */
#line 1246 "HAL_S.y"
                  { (yyval.constant_) = make_AAconstant((yyvsp[0].number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6955 "Parser.c"
    break;

  case 464: /* CONSTANT: COMPOUND_NUMBER  */
#line 1247 "HAL_S.y"
                    { (yyval.constant_) = make_ABconstant((yyvsp[0].compound_number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6961 "Parser.c"
    break;

  case 465: /* CONSTANT: BIT_CONST  */
#line 1248 "HAL_S.y"
              { (yyval.constant_) = make_ACconstant((yyvsp[0].bit_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6967 "Parser.c"
    break;

  case 466: /* CONSTANT: CHAR_CONST  */
#line 1249 "HAL_S.y"
               { (yyval.constant_) = make_ADconstant((yyvsp[0].char_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6973 "Parser.c"
    break;

  case 467: /* ARRAY_HEAD: _SYMB_39 _SYMB_2  */
#line 1251 "HAL_S.y"
                              { (yyval.array_head_) = make_AAarray_head(); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 6979 "Parser.c"
    break;

  case 468: /* ARRAY_HEAD: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_0  */
#line 1252 "HAL_S.y"
                                           { (yyval.array_head_) = make_ABarray_head((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 6985 "Parser.c"
    break;

  case 469: /* MINOR_ATTR_LIST: MINOR_ATTRIBUTE  */
#line 1254 "HAL_S.y"
                                  { (yyval.minor_attr_list_) = make_AAminor_attr_list((yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 6991 "Parser.c"
    break;

  case 470: /* MINOR_ATTR_LIST: MINOR_ATTR_LIST MINOR_ATTRIBUTE  */
#line 1255 "HAL_S.y"
                                    { (yyval.minor_attr_list_) = make_ABminor_attr_list((yyvsp[-1].minor_attr_list_), (yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 6997 "Parser.c"
    break;

  case 471: /* MINOR_ATTRIBUTE: _SYMB_153  */
#line 1257 "HAL_S.y"
                            { (yyval.minor_attribute_) = make_AAminorAttributeStatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7003 "Parser.c"
    break;

  case 472: /* MINOR_ATTRIBUTE: _SYMB_42  */
#line 1258 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ABminorAttributeAutomatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7009 "Parser.c"
    break;

  case 473: /* MINOR_ATTRIBUTE: _SYMB_64  */
#line 1259 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ACminorAttributeDense(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7015 "Parser.c"
    break;

  case 474: /* MINOR_ATTRIBUTE: _SYMB_30  */
#line 1260 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ADminorAttributeAligned(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7021 "Parser.c"
    break;

  case 475: /* MINOR_ATTRIBUTE: _SYMB_28  */
#line 1261 "HAL_S.y"
             { (yyval.minor_attribute_) = make_AEminorAttributeAccess(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7027 "Parser.c"
    break;

  case 476: /* MINOR_ATTRIBUTE: _SYMB_100 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1262 "HAL_S.y"
                                                  { (yyval.minor_attribute_) = make_AFminorAttributeLock((yyvsp[-1].literal_exp_or_star_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7033 "Parser.c"
    break;

  case 477: /* MINOR_ATTRIBUTE: _SYMB_129  */
#line 1263 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AGminorAttributeRemote(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7039 "Parser.c"
    break;

  case 478: /* MINOR_ATTRIBUTE: _SYMB_134  */
#line 1264 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AHminorAttributeRigid(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7045 "Parser.c"
    break;

  case 479: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_1  */
#line 1265 "HAL_S.y"
                                                 { (yyval.minor_attribute_) = make_AIminorAttributeRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7051 "Parser.c"
    break;

  case 480: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD _SYMB_6 _SYMB_1  */
#line 1266 "HAL_S.y"
                                       { (yyval.minor_attribute_) = make_AJminorAttributeStar((yyvsp[-2].init_or_const_head_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7057 "Parser.c"
    break;

  case 481: /* MINOR_ATTRIBUTE: _SYMB_96  */
#line 1267 "HAL_S.y"
             { (yyval.minor_attribute_) = make_AKminorAttributeLatched(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7063 "Parser.c"
    break;

  case 482: /* MINOR_ATTRIBUTE: _SYMB_109 _SYMB_2 LEVEL _SYMB_1  */
#line 1268 "HAL_S.y"
                                    { (yyval.minor_attribute_) = make_ALminorAttributeNonHal((yyvsp[-1].level_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7069 "Parser.c"
    break;

  case 483: /* INIT_OR_CONST_HEAD: _SYMB_93 _SYMB_2  */
#line 1270 "HAL_S.y"
                                      { (yyval.init_or_const_head_) = make_AAinit_or_const_headInitial(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7075 "Parser.c"
    break;

  case 484: /* INIT_OR_CONST_HEAD: _SYMB_58 _SYMB_2  */
#line 1271 "HAL_S.y"
                     { (yyval.init_or_const_head_) = make_ABinit_or_const_headConstant(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7081 "Parser.c"
    break;

  case 485: /* INIT_OR_CONST_HEAD: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_0  */
#line 1272 "HAL_S.y"
                                                 { (yyval.init_or_const_head_) = make_ACinit_or_const_headRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7087 "Parser.c"
    break;

  case 486: /* REPEATED_CONSTANT: EXPRESSION  */
#line 1274 "HAL_S.y"
                               { (yyval.repeated_constant_) = make_AArepeated_constant((yyvsp[0].expression_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7093 "Parser.c"
    break;

  case 487: /* REPEATED_CONSTANT: REPEAT_HEAD VARIABLE  */
#line 1275 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ABrepeated_constant((yyvsp[-1].repeat_head_), (yyvsp[0].variable_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7099 "Parser.c"
    break;

  case 488: /* REPEATED_CONSTANT: REPEAT_HEAD CONSTANT  */
#line 1276 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ACrepeated_constant((yyvsp[-1].repeat_head_), (yyvsp[0].constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7105 "Parser.c"
    break;

  case 489: /* REPEATED_CONSTANT: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_1  */
#line 1277 "HAL_S.y"
                                                 { (yyval.repeated_constant_) = make_ADrepeated_constant((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7111 "Parser.c"
    break;

  case 490: /* REPEATED_CONSTANT: REPEAT_HEAD  */
#line 1278 "HAL_S.y"
                { (yyval.repeated_constant_) = make_AErepeated_constant((yyvsp[0].repeat_head_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7117 "Parser.c"
    break;

  case 491: /* REPEAT_HEAD: ARITH_EXP _SYMB_9 SIMPLE_NUMBER  */
#line 1280 "HAL_S.y"
                                              { (yyval.repeat_head_) = make_AArepeat_head((yyvsp[-2].arith_exp_), (yyvsp[0].simple_number_)); (yyval.repeat_head_)->line_number = (yyloc).first_line; (yyval.repeat_head_)->char_number = (yyloc).first_column;  }
#line 7123 "Parser.c"
    break;

  case 492: /* NESTED_REPEAT_HEAD: REPEAT_HEAD _SYMB_2  */
#line 1282 "HAL_S.y"
                                         { (yyval.nested_repeat_head_) = make_AAnested_repeat_head((yyvsp[-1].repeat_head_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 7129 "Parser.c"
    break;

  case 493: /* NESTED_REPEAT_HEAD: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_0  */
#line 1283 "HAL_S.y"
                                                 { (yyval.nested_repeat_head_) = make_ABnested_repeat_head((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 7135 "Parser.c"
    break;

  case 494: /* DCL_LIST_COMMA: DECLARATION_LIST _SYMB_0  */
#line 1285 "HAL_S.y"
                                          { (yyval.dcl_list_comma_) = make_AAdcl_list_comma((yyvsp[-1].declaration_list_)); (yyval.dcl_list_comma_)->line_number = (yyloc).first_line; (yyval.dcl_list_comma_)->char_number = (yyloc).first_column;  }
#line 7141 "Parser.c"
    break;

  case 495: /* LITERAL_EXP_OR_STAR: ARITH_EXP  */
#line 1287 "HAL_S.y"
                                { (yyval.literal_exp_or_star_) = make_AAliteralExp((yyvsp[0].arith_exp_)); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7147 "Parser.c"
    break;

  case 496: /* LITERAL_EXP_OR_STAR: _SYMB_6  */
#line 1288 "HAL_S.y"
            { (yyval.literal_exp_or_star_) = make_ABliteralStar(); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7153 "Parser.c"
    break;

  case 497: /* TYPE_SPEC: STRUCT_SPEC  */
#line 1290 "HAL_S.y"
                        { (yyval.type_spec_) = make_AAtypeSpecStruct((yyvsp[0].struct_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7159 "Parser.c"
    break;

  case 498: /* TYPE_SPEC: BIT_SPEC  */
#line 1291 "HAL_S.y"
             { (yyval.type_spec_) = make_ABtypeSpecBit((yyvsp[0].bit_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7165 "Parser.c"
    break;

  case 499: /* TYPE_SPEC: CHAR_SPEC  */
#line 1292 "HAL_S.y"
              { (yyval.type_spec_) = make_ACtypeSpecChar((yyvsp[0].char_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7171 "Parser.c"
    break;

  case 500: /* TYPE_SPEC: ARITH_SPEC  */
#line 1293 "HAL_S.y"
               { (yyval.type_spec_) = make_ADtypeSpecArith((yyvsp[0].arith_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7177 "Parser.c"
    break;

  case 501: /* TYPE_SPEC: _SYMB_76  */
#line 1294 "HAL_S.y"
             { (yyval.type_spec_) = make_AEtypeSpecEvent(); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7183 "Parser.c"
    break;

  case 502: /* BIT_SPEC: _SYMB_45  */
#line 1296 "HAL_S.y"
                    { (yyval.bit_spec_) = make_AAbitSpecBoolean(); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7189 "Parser.c"
    break;

  case 503: /* BIT_SPEC: _SYMB_44 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1297 "HAL_S.y"
                                                 { (yyval.bit_spec_) = make_ABbitSpecBoolean((yyvsp[-1].literal_exp_or_star_)); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7195 "Parser.c"
    break;

  case 504: /* CHAR_SPEC: _SYMB_53 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1299 "HAL_S.y"
                                                         { (yyval.char_spec_) = make_AAchar_spec((yyvsp[-1].literal_exp_or_star_)); (yyval.char_spec_)->line_number = (yyloc).first_line; (yyval.char_spec_)->char_number = (yyloc).first_column;  }
#line 7201 "Parser.c"
    break;

  case 505: /* STRUCT_SPEC: STRUCT_TEMPLATE STRUCT_SPEC_BODY  */
#line 1301 "HAL_S.y"
                                               { (yyval.struct_spec_) = make_AAstruct_spec((yyvsp[-1].struct_template_), (yyvsp[0].struct_spec_body_)); (yyval.struct_spec_)->line_number = (yyloc).first_line; (yyval.struct_spec_)->char_number = (yyloc).first_column;  }
#line 7207 "Parser.c"
    break;

  case 506: /* STRUCT_SPEC_BODY: _SYMB_5 _SYMB_154  */
#line 1303 "HAL_S.y"
                                     { (yyval.struct_spec_body_) = make_AAstruct_spec_body(); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7213 "Parser.c"
    break;

  case 507: /* STRUCT_SPEC_BODY: STRUCT_SPEC_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1304 "HAL_S.y"
                                                 { (yyval.struct_spec_body_) = make_ABstruct_spec_body((yyvsp[-2].struct_spec_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7219 "Parser.c"
    break;

  case 508: /* STRUCT_TEMPLATE: STRUCTURE_ID  */
#line 1306 "HAL_S.y"
                               { (yyval.struct_template_) = make_FMstruct_template((yyvsp[0].structure_id_)); (yyval.struct_template_)->line_number = (yyloc).first_line; (yyval.struct_template_)->char_number = (yyloc).first_column;  }
#line 7225 "Parser.c"
    break;

  case 509: /* STRUCT_SPEC_HEAD: _SYMB_5 _SYMB_154 _SYMB_2  */
#line 1308 "HAL_S.y"
                                             { (yyval.struct_spec_head_) = make_AAstruct_spec_head(); (yyval.struct_spec_head_)->line_number = (yyloc).first_line; (yyval.struct_spec_head_)->char_number = (yyloc).first_column;  }
#line 7231 "Parser.c"
    break;

  case 510: /* ARITH_SPEC: PREC_SPEC  */
#line 1310 "HAL_S.y"
                       { (yyval.arith_spec_) = make_AAarith_spec((yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7237 "Parser.c"
    break;

  case 511: /* ARITH_SPEC: SQ_DQ_NAME  */
#line 1311 "HAL_S.y"
               { (yyval.arith_spec_) = make_ABarith_spec((yyvsp[0].sq_dq_name_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7243 "Parser.c"
    break;

  case 512: /* ARITH_SPEC: SQ_DQ_NAME PREC_SPEC  */
#line 1312 "HAL_S.y"
                         { (yyval.arith_spec_) = make_ACarith_spec((yyvsp[-1].sq_dq_name_), (yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7249 "Parser.c"
    break;

  case 513: /* COMPILATION: ANY_STATEMENT  */
#line 1314 "HAL_S.y"
                            { (yyval.compilation_) = make_AAcompilation((yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7255 "Parser.c"
    break;

  case 514: /* COMPILATION: COMPILATION ANY_STATEMENT  */
#line 1315 "HAL_S.y"
                              { (yyval.compilation_) = make_ABcompilation((yyvsp[-1].compilation_), (yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7261 "Parser.c"
    break;

  case 515: /* COMPILATION: DECLARE_STATEMENT  */
#line 1316 "HAL_S.y"
                      { (yyval.compilation_) = make_ACcompilation((yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7267 "Parser.c"
    break;

  case 516: /* COMPILATION: COMPILATION DECLARE_STATEMENT  */
#line 1317 "HAL_S.y"
                                  { (yyval.compilation_) = make_ADcompilation((yyvsp[-1].compilation_), (yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7273 "Parser.c"
    break;

  case 517: /* COMPILATION: STRUCTURE_STMT  */
#line 1318 "HAL_S.y"
                   { (yyval.compilation_) = make_AEcompilation((yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7279 "Parser.c"
    break;

  case 518: /* COMPILATION: COMPILATION STRUCTURE_STMT  */
#line 1319 "HAL_S.y"
                               { (yyval.compilation_) = make_AFcompilation((yyvsp[-1].compilation_), (yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7285 "Parser.c"
    break;

  case 519: /* COMPILATION: REPLACE_STMT _SYMB_16  */
#line 1320 "HAL_S.y"
                          { (yyval.compilation_) = make_AGcompilation((yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7291 "Parser.c"
    break;

  case 520: /* COMPILATION: COMPILATION REPLACE_STMT _SYMB_16  */
#line 1321 "HAL_S.y"
                                      { (yyval.compilation_) = make_AHcompilation((yyvsp[-2].compilation_), (yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7297 "Parser.c"
    break;

  case 521: /* COMPILATION: INIT_OR_CONST_HEAD EXPRESSION _SYMB_1  */
#line 1322 "HAL_S.y"
                                          { (yyval.compilation_) = make_AZcompilationInitOrConst((yyvsp[-2].init_or_const_head_), (yyvsp[-1].expression_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7303 "Parser.c"
    break;

  case 522: /* BLOCK_DEFINITION: BLOCK_STMT CLOSING _SYMB_16  */
#line 1324 "HAL_S.y"
                                               { (yyval.block_definition_) = make_AAblock_definition((yyvsp[-2].block_stmt_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7309 "Parser.c"
    break;

  case 523: /* BLOCK_DEFINITION: BLOCK_STMT BLOCK_BODY CLOSING _SYMB_16  */
#line 1325 "HAL_S.y"
                                           { (yyval.block_definition_) = make_ABblock_definition((yyvsp[-3].block_stmt_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7315 "Parser.c"
    break;

  case 524: /* BLOCK_STMT: BLOCK_STMT_TOP _SYMB_16  */
#line 1327 "HAL_S.y"
                                     { (yyval.block_stmt_) = make_AAblock_stmt((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_)->line_number = (yyloc).first_line; (yyval.block_stmt_)->char_number = (yyloc).first_column;  }
#line 7321 "Parser.c"
    break;

  case 525: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_28  */
#line 1329 "HAL_S.y"
                                         { (yyval.block_stmt_top_) = make_AAblockTopAccess((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7327 "Parser.c"
    break;

  case 526: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_134  */
#line 1330 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ABblockTopRigid((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7333 "Parser.c"
    break;

  case 527: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD  */
#line 1331 "HAL_S.y"
                    { (yyval.block_stmt_top_) = make_ACblockTopHead((yyvsp[0].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7339 "Parser.c"
    break;

  case 528: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_78  */
#line 1332 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ADblockTopExclusive((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7345 "Parser.c"
    break;

  case 529: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_127  */
#line 1333 "HAL_S.y"
                              { (yyval.block_stmt_top_) = make_AEblockTopReentrant((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7351 "Parser.c"
    break;

  case 530: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_122  */
#line 1335 "HAL_S.y"
                                           { (yyval.block_stmt_head_) = make_AAblockHeadProgram((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7357 "Parser.c"
    break;

  case 531: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_57  */
#line 1336 "HAL_S.y"
                            { (yyval.block_stmt_head_) = make_ABblockHeadCompool((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7363 "Parser.c"
    break;

  case 532: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_161  */
#line 1337 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ACblockHeadTask((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7369 "Parser.c"
    break;

  case 533: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_173  */
#line 1338 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ADblockHeadUpdate((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7375 "Parser.c"
    break;

  case 534: /* BLOCK_STMT_HEAD: _SYMB_173  */
#line 1339 "HAL_S.y"
              { (yyval.block_stmt_head_) = make_AEblockHeadUpdate(); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7381 "Parser.c"
    break;

  case 535: /* BLOCK_STMT_HEAD: FUNCTION_NAME  */
#line 1340 "HAL_S.y"
                  { (yyval.block_stmt_head_) = make_AFblockHeadFunction((yyvsp[0].function_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7387 "Parser.c"
    break;

  case 536: /* BLOCK_STMT_HEAD: FUNCTION_NAME FUNC_STMT_BODY  */
#line 1341 "HAL_S.y"
                                 { (yyval.block_stmt_head_) = make_AGblockHeadFunction((yyvsp[-1].function_name_), (yyvsp[0].func_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7393 "Parser.c"
    break;

  case 537: /* BLOCK_STMT_HEAD: PROCEDURE_NAME  */
#line 1342 "HAL_S.y"
                   { (yyval.block_stmt_head_) = make_AHblockHeadProcedure((yyvsp[0].procedure_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7399 "Parser.c"
    break;

  case 538: /* BLOCK_STMT_HEAD: PROCEDURE_NAME PROC_STMT_BODY  */
#line 1343 "HAL_S.y"
                                  { (yyval.block_stmt_head_) = make_AIblockHeadProcedure((yyvsp[-1].procedure_name_), (yyvsp[0].proc_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7405 "Parser.c"
    break;

  case 539: /* LABEL_EXTERNAL: LABEL_DEFINITION  */
#line 1345 "HAL_S.y"
                                  { (yyval.label_external_) = make_AAlabel_external((yyvsp[0].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7411 "Parser.c"
    break;

  case 540: /* LABEL_EXTERNAL: LABEL_DEFINITION _SYMB_81  */
#line 1346 "HAL_S.y"
                              { (yyval.label_external_) = make_ABlabel_external((yyvsp[-1].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7417 "Parser.c"
    break;

  case 541: /* CLOSING: _SYMB_55  */
#line 1348 "HAL_S.y"
                   { (yyval.closing_) = make_AAclosing(); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7423 "Parser.c"
    break;

  case 542: /* CLOSING: _SYMB_55 LABEL  */
#line 1349 "HAL_S.y"
                   { (yyval.closing_) = make_ABclosing((yyvsp[0].label_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7429 "Parser.c"
    break;

  case 543: /* CLOSING: LABEL_DEFINITION CLOSING  */
#line 1350 "HAL_S.y"
                             { (yyval.closing_) = make_ACclosing((yyvsp[-1].label_definition_), (yyvsp[0].closing_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7435 "Parser.c"
    break;

  case 544: /* BLOCK_BODY: DECLARE_GROUP  */
#line 1352 "HAL_S.y"
                           { (yyval.block_body_) = make_ABblock_body((yyvsp[0].declare_group_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7441 "Parser.c"
    break;

  case 545: /* BLOCK_BODY: ANY_STATEMENT  */
#line 1353 "HAL_S.y"
                  { (yyval.block_body_) = make_ADblock_body((yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7447 "Parser.c"
    break;

  case 546: /* BLOCK_BODY: BLOCK_BODY ANY_STATEMENT  */
#line 1354 "HAL_S.y"
                             { (yyval.block_body_) = make_ACblock_body((yyvsp[-1].block_body_), (yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7453 "Parser.c"
    break;

  case 547: /* FUNCTION_NAME: LABEL_EXTERNAL _SYMB_86  */
#line 1356 "HAL_S.y"
                                        { (yyval.function_name_) = make_AAfunction_name((yyvsp[-1].label_external_)); (yyval.function_name_)->line_number = (yyloc).first_line; (yyval.function_name_)->char_number = (yyloc).first_column;  }
#line 7459 "Parser.c"
    break;

  case 548: /* PROCEDURE_NAME: LABEL_EXTERNAL _SYMB_120  */
#line 1358 "HAL_S.y"
                                          { (yyval.procedure_name_) = make_AAprocedure_name((yyvsp[-1].label_external_)); (yyval.procedure_name_)->line_number = (yyloc).first_line; (yyval.procedure_name_)->char_number = (yyloc).first_column;  }
#line 7465 "Parser.c"
    break;

  case 549: /* FUNC_STMT_BODY: PARAMETER_LIST  */
#line 1360 "HAL_S.y"
                                { (yyval.func_stmt_body_) = make_AAfunc_stmt_body((yyvsp[0].parameter_list_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7471 "Parser.c"
    break;

  case 550: /* FUNC_STMT_BODY: TYPE_SPEC  */
#line 1361 "HAL_S.y"
              { (yyval.func_stmt_body_) = make_ABfunc_stmt_body((yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7477 "Parser.c"
    break;

  case 551: /* FUNC_STMT_BODY: PARAMETER_LIST TYPE_SPEC  */
#line 1362 "HAL_S.y"
                             { (yyval.func_stmt_body_) = make_ACfunc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7483 "Parser.c"
    break;

  case 552: /* PROC_STMT_BODY: PARAMETER_LIST  */
#line 1364 "HAL_S.y"
                                { (yyval.proc_stmt_body_) = make_AAproc_stmt_body((yyvsp[0].parameter_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7489 "Parser.c"
    break;

  case 553: /* PROC_STMT_BODY: ASSIGN_LIST  */
#line 1365 "HAL_S.y"
                { (yyval.proc_stmt_body_) = make_ABproc_stmt_body((yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7495 "Parser.c"
    break;

  case 554: /* PROC_STMT_BODY: PARAMETER_LIST ASSIGN_LIST  */
#line 1366 "HAL_S.y"
                               { (yyval.proc_stmt_body_) = make_ACproc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7501 "Parser.c"
    break;

  case 555: /* DECLARE_GROUP: DECLARE_ELEMENT  */
#line 1368 "HAL_S.y"
                                { (yyval.declare_group_) = make_AAdeclare_group((yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7507 "Parser.c"
    break;

  case 556: /* DECLARE_GROUP: DECLARE_GROUP DECLARE_ELEMENT  */
#line 1369 "HAL_S.y"
                                  { (yyval.declare_group_) = make_ABdeclare_group((yyvsp[-1].declare_group_), (yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7513 "Parser.c"
    break;

  case 557: /* DECLARE_ELEMENT: DECLARE_STATEMENT  */
#line 1371 "HAL_S.y"
                                    { (yyval.declare_element_) = make_AAdeclareElementDeclare((yyvsp[0].declare_statement_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7519 "Parser.c"
    break;

  case 558: /* DECLARE_ELEMENT: REPLACE_STMT _SYMB_16  */
#line 1372 "HAL_S.y"
                          { (yyval.declare_element_) = make_ABdeclareElementReplace((yyvsp[-1].replace_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7525 "Parser.c"
    break;

  case 559: /* DECLARE_ELEMENT: STRUCTURE_STMT  */
#line 1373 "HAL_S.y"
                   { (yyval.declare_element_) = make_ACdeclareElementStructure((yyvsp[0].structure_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7531 "Parser.c"
    break;

  case 560: /* DECLARE_ELEMENT: _SYMB_72 _SYMB_81 IDENTIFIER _SYMB_165 VARIABLE _SYMB_16  */
#line 1374 "HAL_S.y"
                                                             { (yyval.declare_element_) = make_ADdeclareElementEquate((yyvsp[-3].identifier_), (yyvsp[-1].variable_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7537 "Parser.c"
    break;

  case 561: /* PARAMETER: _SYMB_191  */
#line 1376 "HAL_S.y"
                      { (yyval.parameter_) = make_AAparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7543 "Parser.c"
    break;

  case 562: /* PARAMETER: _SYMB_182  */
#line 1377 "HAL_S.y"
              { (yyval.parameter_) = make_ABparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7549 "Parser.c"
    break;

  case 563: /* PARAMETER: _SYMB_185  */
#line 1378 "HAL_S.y"
              { (yyval.parameter_) = make_ACparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7555 "Parser.c"
    break;

  case 564: /* PARAMETER: _SYMB_186  */
#line 1379 "HAL_S.y"
              { (yyval.parameter_) = make_ADparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7561 "Parser.c"
    break;

  case 565: /* PARAMETER: _SYMB_189  */
#line 1380 "HAL_S.y"
              { (yyval.parameter_) = make_AEparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7567 "Parser.c"
    break;

  case 566: /* PARAMETER: _SYMB_188  */
#line 1381 "HAL_S.y"
              { (yyval.parameter_) = make_AFparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7573 "Parser.c"
    break;

  case 567: /* PARAMETER_LIST: PARAMETER_HEAD PARAMETER _SYMB_1  */
#line 1383 "HAL_S.y"
                                                  { (yyval.parameter_list_) = make_AAparameter_list((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_list_)->line_number = (yyloc).first_line; (yyval.parameter_list_)->char_number = (yyloc).first_column;  }
#line 7579 "Parser.c"
    break;

  case 568: /* PARAMETER_HEAD: _SYMB_2  */
#line 1385 "HAL_S.y"
                         { (yyval.parameter_head_) = make_AAparameter_head(); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 7585 "Parser.c"
    break;

  case 569: /* PARAMETER_HEAD: PARAMETER_HEAD PARAMETER _SYMB_0  */
#line 1386 "HAL_S.y"
                                     { (yyval.parameter_head_) = make_ABparameter_head((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 7591 "Parser.c"
    break;

  case 570: /* DECLARE_STATEMENT: _SYMB_63 DECLARE_BODY _SYMB_16  */
#line 1388 "HAL_S.y"
                                                   { (yyval.declare_statement_) = make_AAdeclare_statement((yyvsp[-1].declare_body_)); (yyval.declare_statement_)->line_number = (yyloc).first_line; (yyval.declare_statement_)->char_number = (yyloc).first_column;  }
#line 7597 "Parser.c"
    break;

  case 571: /* ASSIGN_LIST: ASSIGN PARAMETER_LIST  */
#line 1390 "HAL_S.y"
                                    { (yyval.assign_list_) = make_AAassign_list((yyvsp[-1].assign_), (yyvsp[0].parameter_list_)); (yyval.assign_list_)->line_number = (yyloc).first_line; (yyval.assign_list_)->char_number = (yyloc).first_column;  }
#line 7603 "Parser.c"
    break;

  case 572: /* TEXT: _SYMB_193  */
#line 1392 "HAL_S.y"
                 { (yyval.text_) = make_FQtext((yyvsp[0].string_)); (yyval.text_)->line_number = (yyloc).first_line; (yyval.text_)->char_number = (yyloc).first_column;  }
#line 7609 "Parser.c"
    break;

  case 573: /* REPLACE_STMT: _SYMB_131 REPLACE_HEAD _SYMB_46 TEXT  */
#line 1394 "HAL_S.y"
                                                    { (yyval.replace_stmt_) = make_AAreplace_stmt((yyvsp[-2].replace_head_), (yyvsp[0].text_)); (yyval.replace_stmt_)->line_number = (yyloc).first_line; (yyval.replace_stmt_)->char_number = (yyloc).first_column;  }
#line 7615 "Parser.c"
    break;

  case 574: /* REPLACE_HEAD: IDENTIFIER  */
#line 1396 "HAL_S.y"
                          { (yyval.replace_head_) = make_AAreplace_head((yyvsp[0].identifier_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 7621 "Parser.c"
    break;

  case 575: /* REPLACE_HEAD: IDENTIFIER _SYMB_2 ARG_LIST _SYMB_1  */
#line 1397 "HAL_S.y"
                                        { (yyval.replace_head_) = make_ABreplace_head((yyvsp[-3].identifier_), (yyvsp[-1].arg_list_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 7627 "Parser.c"
    break;

  case 576: /* ARG_LIST: IDENTIFIER  */
#line 1399 "HAL_S.y"
                      { (yyval.arg_list_) = make_AAarg_list((yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 7633 "Parser.c"
    break;

  case 577: /* ARG_LIST: ARG_LIST _SYMB_0 IDENTIFIER  */
#line 1400 "HAL_S.y"
                                { (yyval.arg_list_) = make_ABarg_list((yyvsp[-2].arg_list_), (yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 7639 "Parser.c"
    break;

  case 578: /* STRUCTURE_STMT: _SYMB_154 STRUCT_STMT_HEAD STRUCT_STMT_TAIL  */
#line 1402 "HAL_S.y"
                                                             { (yyval.structure_stmt_) = make_AAstructure_stmt((yyvsp[-1].struct_stmt_head_), (yyvsp[0].struct_stmt_tail_)); (yyval.structure_stmt_)->line_number = (yyloc).first_line; (yyval.structure_stmt_)->char_number = (yyloc).first_column;  }
#line 7645 "Parser.c"
    break;

  case 579: /* STRUCT_STMT_HEAD: STRUCTURE_ID _SYMB_17 LEVEL  */
#line 1404 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_AAstruct_stmt_head((yyvsp[-2].structure_id_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7651 "Parser.c"
    break;

  case 580: /* STRUCT_STMT_HEAD: STRUCTURE_ID MINOR_ATTR_LIST _SYMB_17 LEVEL  */
#line 1405 "HAL_S.y"
                                                { (yyval.struct_stmt_head_) = make_ABstruct_stmt_head((yyvsp[-3].structure_id_), (yyvsp[-2].minor_attr_list_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7657 "Parser.c"
    break;

  case 581: /* STRUCT_STMT_HEAD: STRUCT_STMT_HEAD DECLARATION _SYMB_0 LEVEL  */
#line 1406 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_ACstruct_stmt_head((yyvsp[-3].struct_stmt_head_), (yyvsp[-2].declaration_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7663 "Parser.c"
    break;

  case 582: /* STRUCT_STMT_TAIL: DECLARATION _SYMB_16  */
#line 1408 "HAL_S.y"
                                        { (yyval.struct_stmt_tail_) = make_AAstruct_stmt_tail((yyvsp[-1].declaration_)); (yyval.struct_stmt_tail_)->line_number = (yyloc).first_line; (yyval.struct_stmt_tail_)->char_number = (yyloc).first_column;  }
#line 7669 "Parser.c"
    break;

  case 583: /* INLINE_DEFINITION: ARITH_INLINE  */
#line 1410 "HAL_S.y"
                                 { (yyval.inline_definition_) = make_AAinline_definition((yyvsp[0].arith_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7675 "Parser.c"
    break;

  case 584: /* INLINE_DEFINITION: BIT_INLINE  */
#line 1411 "HAL_S.y"
               { (yyval.inline_definition_) = make_ABinline_definition((yyvsp[0].bit_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7681 "Parser.c"
    break;

  case 585: /* INLINE_DEFINITION: CHAR_INLINE  */
#line 1412 "HAL_S.y"
                { (yyval.inline_definition_) = make_ACinline_definition((yyvsp[0].char_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7687 "Parser.c"
    break;

  case 586: /* INLINE_DEFINITION: STRUCTURE_EXP  */
#line 1413 "HAL_S.y"
                  { (yyval.inline_definition_) = make_ADinline_definition((yyvsp[0].structure_exp_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7693 "Parser.c"
    break;

  case 587: /* ARITH_INLINE: ARITH_INLINE_DEF CLOSING _SYMB_16  */
#line 1415 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_ACprimary((yyvsp[-2].arith_inline_def_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 7699 "Parser.c"
    break;

  case 588: /* ARITH_INLINE: ARITH_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1416 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_AZprimary((yyvsp[-3].arith_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 7705 "Parser.c"
    break;

  case 589: /* ARITH_INLINE_DEF: _SYMB_86 ARITH_SPEC _SYMB_16  */
#line 1418 "HAL_S.y"
                                                { (yyval.arith_inline_def_) = make_AAarith_inline_def((yyvsp[-1].arith_spec_)); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 7711 "Parser.c"
    break;

  case 590: /* ARITH_INLINE_DEF: _SYMB_86 _SYMB_16  */
#line 1419 "HAL_S.y"
                      { (yyval.arith_inline_def_) = make_ABarith_inline_def(); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 7717 "Parser.c"
    break;

  case 591: /* BIT_INLINE: BIT_INLINE_DEF CLOSING _SYMB_16  */
#line 1421 "HAL_S.y"
                                             { (yyval.bit_inline_) = make_AGbit_prim((yyvsp[-2].bit_inline_def_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 7723 "Parser.c"
    break;

  case 592: /* BIT_INLINE: BIT_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1422 "HAL_S.y"
                                               { (yyval.bit_inline_) = make_AZbit_prim((yyvsp[-3].bit_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 7729 "Parser.c"
    break;

  case 593: /* BIT_INLINE_DEF: _SYMB_86 BIT_SPEC _SYMB_16  */
#line 1424 "HAL_S.y"
                                            { (yyval.bit_inline_def_) = make_AAbit_inline_def((yyvsp[-1].bit_spec_)); (yyval.bit_inline_def_)->line_number = (yyloc).first_line; (yyval.bit_inline_def_)->char_number = (yyloc).first_column;  }
#line 7735 "Parser.c"
    break;

  case 594: /* CHAR_INLINE: CHAR_INLINE_DEF CLOSING _SYMB_16  */
#line 1426 "HAL_S.y"
                                               { (yyval.char_inline_) = make_ADchar_prim((yyvsp[-2].char_inline_def_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 7741 "Parser.c"
    break;

  case 595: /* CHAR_INLINE: CHAR_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1427 "HAL_S.y"
                                                { (yyval.char_inline_) = make_AZchar_prim((yyvsp[-3].char_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 7747 "Parser.c"
    break;

  case 596: /* CHAR_INLINE_DEF: _SYMB_86 CHAR_SPEC _SYMB_16  */
#line 1429 "HAL_S.y"
                                              { (yyval.char_inline_def_) = make_AAchar_inline_def((yyvsp[-1].char_spec_)); (yyval.char_inline_def_)->line_number = (yyloc).first_line; (yyval.char_inline_def_)->char_number = (yyloc).first_column;  }
#line 7753 "Parser.c"
    break;

  case 597: /* STRUC_INLINE_DEF: _SYMB_86 STRUCT_SPEC _SYMB_16  */
#line 1431 "HAL_S.y"
                                                 { (yyval.struc_inline_def_) = make_AAstruc_inline_def((yyvsp[-1].struct_spec_)); (yyval.struc_inline_def_)->line_number = (yyloc).first_line; (yyval.struc_inline_def_)->char_number = (yyloc).first_column;  }
#line 7759 "Parser.c"
    break;


#line 7763 "Parser.c"

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

