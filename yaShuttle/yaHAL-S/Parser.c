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
#define YYLAST   7539

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  201
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  192
/* YYNRULES -- Number of rules.  */
#define YYNRULES  601
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  998

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
     656,   657,   658,   659,   660,   661,   662,   663,   664,   666,
     667,   668,   669,   670,   672,   673,   674,   676,   678,   679,
     681,   682,   684,   685,   686,   687,   689,   690,   692,   693,
     694,   695,   696,   697,   698,   699,   701,   702,   703,   704,
     705,   707,   708,   710,   712,   714,   715,   716,   717,   719,
     720,   722,   724,   725,   726,   727,   729,   730,   731,   732,
     733,   734,   735,   736,   738,   739,   740,   741,   742,   744,
     745,   747,   749,   751,   753,   754,   755,   756,   758,   759,
     761,   762,   764,   765,   766,   768,   769,   770,   771,   772,
     774,   775,   777,   778,   779,   780,   781,   782,   783,   784,
     786,   787,   788,   789,   790,   791,   792,   793,   794,   795,
     796,   797,   798,   799,   800,   801,   802,   803,   804,   805,
     806,   807,   808,   809,   810,   811,   812,   813,   814,   815,
     816,   817,   818,   819,   820,   821,   822,   823,   824,   825,
     826,   827,   828,   829,   830,   831,   832,   834,   835,   836,
     837,   839,   840,   841,   842,   844,   845,   847,   848,   850,
     851,   852,   853,   854,   856,   857,   859,   860,   861,   862,
     864,   866,   867,   869,   870,   871,   873,   874,   876,   877,
     879,   880,   881,   882,   884,   885,   887,   889,   890,   892,
     893,   894,   895,   896,   897,   898,   899,   900,   901,   902,
     904,   905,   907,   908,   910,   911,   912,   913,   915,   916,
     917,   918,   920,   921,   922,   923,   925,   926,   928,   929,
     930,   931,   932,   934,   935,   936,   937,   939,   941,   942,
     944,   946,   947,   948,   950,   952,   953,   954,   955,   957,
     958,   960,   962,   963,   965,   967,   968,   969,   970,   971,
     973,   974,   975,   976,   978,   979,   981,   982,   983,   984,
     986,   987,   989,   990,   991,   992,   993,   995,   997,   998,
     999,  1001,  1003,  1004,  1005,  1007,  1008,  1009,  1010,  1011,
    1012,  1013,  1015,  1016,  1017,  1018,  1020,  1022,  1024,  1026,
    1027,  1029,  1031,  1032,  1033,  1034,  1036,  1038,  1039,  1041,
    1042,  1044,  1046,  1048,  1050,  1051,  1053,  1054,  1056,  1057,
    1058,  1060,  1061,  1062,  1063,  1064,  1066,  1067,  1068,  1069,
    1070,  1071,  1073,  1074,  1075,  1077,  1078,  1079,  1080,  1081,
    1082,  1083,  1084,  1085,  1086,  1087,  1088,  1089,  1090,  1091,
    1092,  1093,  1094,  1095,  1096,  1097,  1098,  1099,  1100,  1101,
    1102,  1103,  1104,  1105,  1106,  1107,  1108,  1109,  1110,  1111,
    1112,  1113,  1114,  1115,  1116,  1117,  1119,  1120,  1121,  1123,
    1124,  1126,  1127,  1129,  1130,  1131,  1132,  1134,  1136,  1138,
    1140,  1141,  1142,  1143,  1145,  1146,  1147,  1148,  1149,  1150,
    1151,  1152,  1154,  1155,  1156,  1158,  1159,  1161,  1163,  1164,
    1166,  1167,  1169,  1170,  1172,  1173,  1174,  1176,  1178,  1180,
    1181,  1182,  1183,  1184,  1186,  1188,  1189,  1191,  1192,  1194,
    1195,  1196,  1197,  1199,  1200,  1201,  1203,  1204,  1205,  1207,
    1208,  1209,  1211,  1213,  1214,  1216,  1217,  1218,  1220,  1222,
    1223,  1225,  1226,  1228,  1230,  1231,  1233,  1234,  1236,  1237,
    1239,  1240,  1242,  1243,  1245,  1246,  1248,  1250,  1251,  1252,
    1253,  1255,  1256,  1258,  1259,  1261,  1262,  1263,  1264,  1265,
    1266,  1267,  1268,  1269,  1270,  1271,  1272,  1274,  1275,  1276,
    1278,  1279,  1280,  1281,  1282,  1284,  1286,  1287,  1289,  1291,
    1292,  1294,  1295,  1296,  1297,  1298,  1300,  1301,  1303,  1305,
    1307,  1308,  1310,  1312,  1314,  1315,  1316,  1318,  1319,  1320,
    1321,  1322,  1323,  1324,  1325,  1326,  1328,  1329,  1331,  1333,
    1334,  1335,  1336,  1337,  1339,  1340,  1341,  1342,  1343,  1344,
    1345,  1346,  1347,  1349,  1350,  1352,  1353,  1354,  1356,  1357,
    1358,  1360,  1362,  1364,  1365,  1366,  1368,  1369,  1370,  1372,
    1373,  1375,  1376,  1377,  1378,  1380,  1381,  1382,  1383,  1384,
    1385,  1387,  1389,  1390,  1392,  1394,  1396,  1398,  1400,  1401,
    1403,  1404,  1406,  1408,  1409,  1410,  1412,  1414,  1415,  1416,
    1417,  1419,  1420,  1422,  1423,  1425,  1426,  1428,  1430,  1431,
    1433,  1435
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

#define YYPACT_NINF (-783)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-417)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
    5524,   343,   -91,  -783,   -42,   721,  -783,   157,  7064,   114,
      42,   162,  1542,    70,  -783,   326,  -783,   285,   290,   331,
     377,   252,   -42,   330,  2621,   721,   340,   330,   330,   -91,
    -783,  -783,   360,  -783,   491,  -783,  -783,  -783,  -783,  -783,
     515,  -783,  -783,  -783,  -783,  -783,  -783,   444,  -783,  -783,
     821,   279,   444,   509,   444,  -783,   444,   537,   246,  -783,
     540,   284,  -783,   374,  -783,   539,  -783,  6490,  6490,  3206,
    -783,  -783,  -783,  -783,  6490,   129,  6212,   294,  5802,  5585,
    2231,   266,   391,   545,   581,  4157,    25,   335,    51,   579,
     271,  5374,  6490,  3401,  2016,  -783,  5670,    52,    35,   223,
    1433,   113,  -783,   586,  -783,  -783,  -783,  5670,  -783,  5670,
    -783,  5670,  5670,   594,   235,  -783,  -783,  -783,   444,   612,
    -783,  -783,  -783,   627,  -783,   629,  -783,   653,  -783,  -783,
    -783,  -783,  -783,  -783,   667,   669,   676,  -783,  -783,  -783,
    -783,  -783,  -783,  -783,  -783,   684,  -783,  -783,   656,  -783,
    7252,  6942,   673,   691,  -783,  7349,  -783,   591,    49,  4499,
    -783,   702,  7215,  -783,  -783,  -783,  -783,  4499,  3747,  -783,
    2816,   796,  3747,  -783,  -783,  -783,   707,  -783,  -783,  4841,
     305,  -783,  -783,  3206,   735,    45,  4841,  -783,   756,   522,
    -783,   758,   769,   781,   786,   660,  -783,   486,    43,   522,
     522,  -783,   789,   705,   753,  -783,   730,  3596,  -783,  -783,
     466,   259,  -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,
    -783,  -783,  -783,  -783,    77,  -783,   822,    77,  -783,  -783,
    -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,
     -91,  -783,  -783,   828,  -783,  -783,  -783,  -783,   848,  -783,
    -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,
    -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,   850,  -783,
    -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,
    -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,   852,   856,
     869,  -783,  -783,  -783,  -783,   444,   560,  -783,  5173,  5173,
     861,  5007,   871,  -783,   876,  -783,  -783,  -783,  -783,  -783,
     892,   880,   444,  -783,    53,   336,   202,  -783,  1864,  -783,
    -783,  -783,   708,  -783,   910,  -783,  3401,   921,  -783,   202,
    -783,   937,  -783,  -783,  -783,  -783,   938,  -783,  -783,   287,
    -783,   563,  -783,  -783,  5349,   796,   686,   522,   843,  -783,
    -783,  4328,   659,   909,  -783,   406,  -783,   942,  -783,  -783,
    -783,  -783,  1776,   821,  -783,  3011,  3401,   821,   736,  -783,
    3401,  -783,   360,  -783,   878,  6900,  -783,  3206,   893,    55,
     879,  5339,   879,   458,   458,    55,   336,  -783,  -783,  -783,
    -783,   353,  -783,  -783,   360,  -783,  -783,  3401,  -783,  -783,
     948,   660,  7064,  -783,  5934,   940,  -783,  -783,   960,   966,
     970,   972,   984,  -783,  -783,  -783,  -783,   428,  -783,  -783,
    -783,  1055,  -783,  2426,  -783,  3401,  4841,  4841,  5283,  4841,
     869,   507,   981,  -783,  -783,   430,  4841,  4841,  1271,  1007,
     884,  -783,  -783,  1009,   -52,   151,  -783,  3791,  -783,  -783,
    -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,   680,
    -783,  -783,   344,  1015,  1030,  1733,  3401,  -783,  -783,  -783,
    1029,  -783,   660,   971,  -783,  6080,  1035,  6358,    37,  -783,
    -783,  1041,  -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,
    -783,  -783,  -783,  -783,  -783,  1581,   908,  1045,  -783,  1021,
    -783,  -783,  1046,  6358,  1047,  6358,  1048,  6358,  1050,  6358,
     444,   -91,   444,  -783,   721,  -783,  4499,  4499,  4499,  4499,
     881,  -783,  7349,  3747,  -783,  3747,  3747,  -783,   796,  -783,
    -783,  -783,  -783,   726,  1054,  -783,  -783,   732,  -783,  1069,
    -783,   778,  -783,  -783,  3747,   922,  -783,  4499,   520,   -42,
     545,  1070,    53,    53,  -783,  -783,  1064,    73,  1081,  -783,
    -783,  -783,  -783,  -783,  -783,  1066,  -783,  1068,  -783,  -783,
     -11,  1084,  1085,  -783,   -42,   895,   330,   776,    68,   111,
    1088,  1080,  1091,  1090,   497,  1087,  -783,  -783,  -783,   522,
    -783,  3401,  -783,  -783,  -783,  5173,  5173,  3986,  -783,  -783,
    5173,  5173,  5173,  -783,  -783,  5173,  1104,  -783,  3401,  -783,
    -783,  -783,  -783,  1271,  -783,  -783,  -783,  1271,  1271,  1271,
     259,   259,  -783,  1102,  -783,   522,  1109,  3401,  3986,  3401,
    1281,  6124,  -783,  1096,   881,  5490,   453,  -783,  4841,   949,
    1112,  1100,  -783,  -783,  -783,  -783,   258,  -783,  4670,   951,
     726,  -783,  -783,  -783,  -783,  -783,  -783,  1118,   246,  -783,
    -783,  1105,   642,   783,  -783,  -783,   287,  -783,   444,   444,
     444,   444,  -783,  -783,  -783,   818,   464,   124,  -783,  -783,
    -783,  -783,  -783,  -783,  4841,  -783,  -783,  1271,  3206,  3986,
     447,    18,  3206,  -783,  3206,  1106,   792,   821,  -783,  1107,
    6622,  -783,  -783,  4841,  4841,  4841,  4841,  4841,  -783,  -783,
    1110,   456,   587,   617,  1115,    65,   580,  -783,  1480,   721,
    -783,   726,   726,    53,  4841,  -783,  -783,  -783,  4841,  4841,
    3791,   726,    53,  1113,  -783,  1117,   930,  -783,  -783,  -783,
    -783,  -783,   810,  -783,  -783,   -42,  6768,  -783,  -783,  -783,
    1121,  -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,
     816,  -783,  -783,  -783,  1122,  -783,  1123,  -783,  1124,  -783,
    1127,  -783,  -783,   444,  1144,  1146,  1148,  1150,  1151,  -783,
    3747,  3747,   702,  -783,  -783,  -783,  -783,  -783,  1149,  1154,
    1093,  1134,  -783,   518,  -783,  4841,  -783,  4841,  -783,  -783,
    -783,  -783,  -783,  -783,  -783,   834,  -783,  -783,  -783,  -783,
    -783,   444,   259,   444,  1162,  1164,   877,  -783,  -783,  3986,
    -783,   726,  -783,  1159,  -783,  -783,  -783,  -783,  1152,   919,
     336,   202,  -783,  1864,  1008,  1167,  -783,   933,   726,  -783,
     954,  1168,  1170,   444,  -783,  -783,   881,   881,  -783,   585,
    4841,  -783,   744,  4841,  4670,   726,  -783,  -783,  5173,  5173,
    -783,  3401,  -783,  3401,  3401,  -783,  -783,  -783,  -783,  -783,
    -783,   726,   202,   213,   560,   202,  -783,  -783,  -783,   483,
     879,   336,  -783,  -783,   194,  -783,   406,   964,  -783,   649,
     862,   931,   956,   991,  -783,  -783,  -783,  -783,  -783,  -783,
    -783,  1016,   726,   726,  6402,  -783,  -783,  -783,  -783,  1011,
    -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,
    -783,  -783,  -783,  -783,  -783,  -783,  -783,   346,   726,   -42,
    -783,  -783,  -783,  1158,   708,  -783,  1290,   744,  -783,  -783,
    -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,   709,
    -783,  1000,  1176,  1031,  -783,  -783,  -783,  -783,  -783,  -783,
    -783,  1177,   821,  1171,  -783,  -783,  -783,  -783,  -783,  -783,
     821,  4841,  -783,   339,  -783,  1022,  -783,  1163,  -783,  -783,
    -783,   821,  -783,   406,  -783,  1182,   726,  1179,  1163,  1185,
    4841,  1049,  -783,  -783,  1039,  1186,  -783,  -783
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int16 yydefact[] =
{
       0,     0,     0,   342,     0,     0,   426,     0,     0,     0,
       0,     0,     0,     0,   312,     0,   281,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     240,   425,   538,   424,     0,   244,   246,   247,   277,   301,
     248,   245,   251,   101,    27,   100,   285,    66,   286,   290,
       0,     0,   214,     0,   222,   288,   266,     0,     0,   590,
       0,   292,   296,     0,   299,     0,   376,     0,     0,     0,
     379,   332,   333,   517,     0,     0,   543,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   433,     0,     0,
       0,     0,     0,     0,     0,   380,     0,     0,   531,     0,
     539,   541,   519,     0,   521,   334,   587,     0,   588,     0,
     589,     0,     0,     0,     0,   448,   248,   388,   218,     0,
     488,   479,   478,     0,   476,     0,   506,     0,   477,   168,
     505,    20,    32,   485,     0,    35,     0,    21,    22,   481,
     482,    33,   167,   475,    23,    34,    42,    43,    44,    45,
       9,    17,     0,     0,    36,     5,     6,    38,   515,     0,
      29,     2,     7,   514,    40,    41,   512,     0,    26,   473,
       0,     0,    24,   502,   503,   501,     0,   504,   394,     0,
       0,   455,   454,     0,     0,     0,     0,   337,     0,     0,
     594,     0,     0,     0,     0,     0,   487,     0,   382,     0,
       0,   339,     0,   578,     0,   446,     0,     0,    53,    54,
       0,     0,   347,   213,   111,   141,   123,   124,   125,   126,
     128,   127,   129,   235,   242,   112,     0,   276,   102,   130,
     131,   103,   236,   142,   113,   104,   105,   132,   230,   114,
       0,   233,   146,    32,   148,   147,   272,   133,    35,   153,
     115,   154,   116,   110,   212,   279,   234,   117,   232,   231,
     106,   150,   107,   108,   118,   273,   119,   109,    33,   139,
     140,   120,   121,   134,   135,   152,   136,   151,   137,   138,
     143,   149,   274,   229,   122,   144,    34,   249,   246,   247,
     245,   237,    81,    83,    82,     0,    95,    46,     0,     0,
      51,    55,    59,    62,    63,    75,    80,    76,    79,    64,
       0,     0,    84,    88,    96,   186,   188,   190,     0,   199,
     200,   201,     0,   202,   226,   270,     0,     0,   241,    97,
     255,     0,   260,   261,   264,    98,     0,    99,   292,     0,
     429,     0,   445,   447,     0,     0,     0,     0,     0,    67,
     158,   174,     0,     0,   291,     0,   238,     0,   215,   387,
     223,   267,     0,     0,   306,     0,     0,     0,     0,   297,
       0,   335,     0,   307,   332,     0,   308,     0,     0,     0,
     188,     0,     0,     0,     0,     0,   314,   316,   320,   377,
     370,     0,   544,   536,   537,   336,   378,     0,   343,   389,
       0,   402,     0,   400,   543,     0,   401,   350,     0,     0,
       0,     0,     0,   412,   408,   413,   352,   301,   414,   410,
     415,     0,   351,     0,   353,     0,     0,     0,     0,     0,
       0,     0,     0,   361,   427,     0,     0,     0,     0,     0,
       0,   365,   435,     0,   437,   441,   436,     0,   367,   449,
     374,   467,   468,   283,   284,   469,   470,   451,   282,     0,
     452,   399,    95,   490,     0,   494,     0,     1,   518,   520,
       0,   522,   545,     0,   549,   543,     0,     0,   548,   559,
     561,     0,   563,   528,   529,   530,   532,   533,   535,   551,
     552,   534,   572,   554,   540,   553,     0,     0,   542,   556,
     557,   523,     0,     0,     0,     0,     0,     0,     0,     0,
      68,     0,    70,   219,     0,   471,     0,     0,     0,     0,
       0,    30,    14,    12,    10,    15,    18,   574,     0,     4,
      39,   516,   500,   499,     0,   498,     8,     0,   474,     0,
     490,     0,    44,    37,    25,     0,   509,     0,     0,     0,
       0,     0,   456,   457,   397,   395,     0,   460,   459,   338,
     418,   597,   600,   601,   593,     0,   373,     0,   386,   385,
     381,     0,     0,   340,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   252,   243,   253,     0,
     265,     0,    89,   210,   211,     0,     0,     0,    47,    48,
       0,     0,     0,    58,    61,     0,     0,    65,     0,   348,
      85,   196,   195,     0,   194,   197,   198,     0,     0,     0,
       0,     0,   192,     0,   228,     0,     0,     0,     0,     0,
       0,     0,   369,     0,     0,     0,     0,   582,     0,     0,
       0,   169,   160,   159,   177,   183,   181,   175,     0,   176,
     182,   173,   157,   171,   172,   287,   239,     0,     0,   303,
     302,     0,    95,     0,    90,    92,    94,   305,    72,   216,
     224,   268,   300,   304,   311,     0,     0,     0,   328,   329,
     327,   330,   331,   326,     0,   313,   310,     0,     0,     0,
       0,     0,     0,   309,     0,     0,     0,     0,   403,     0,
       0,   404,   349,     0,     0,     0,     0,     0,   409,   411,
       0,     0,     0,     0,     0,     0,     0,   358,     0,     0,
     362,   430,   431,   432,     0,   442,   366,   438,     0,     0,
       0,   443,   444,     0,   450,     0,     0,   525,   489,   496,
     491,   492,     0,   524,   546,     0,     0,   547,   526,   550,
       0,   560,   562,   555,   566,   567,   568,   570,   569,   565,
       0,   575,   558,   591,     0,   595,     0,   598,     0,   294,
       0,    69,    71,   220,     0,     0,     0,     0,     0,    13,
      11,    16,     3,    28,   472,    19,   484,   483,   510,     0,
     398,     0,   464,     0,   396,     0,   458,     0,   341,   372,
     384,   383,   405,   406,   580,     0,   576,   577,    74,   203,
     263,   206,     0,   208,     0,     0,     0,    49,    50,     0,
     275,   258,   259,     0,    52,    56,    57,    60,     0,     0,
     187,   189,   191,     0,     0,     0,   204,     0,   257,   256,
       0,     0,     0,    86,   368,   583,     0,     0,   586,     0,
       0,   407,   165,     0,     0,   181,   178,   180,     0,     0,
     289,     0,   355,     0,     0,   293,    73,   217,   225,   269,
     318,   321,   323,     0,     0,   322,   325,   298,   324,     0,
       0,   315,   317,   371,     0,   390,   392,     0,   466,     0,
       0,     0,     0,     0,   354,   356,   417,   357,   360,   359,
     428,     0,   440,   439,     0,   375,   495,   497,   493,     0,
     527,   573,   571,   592,   596,   599,   295,   221,   507,   508,
     480,    31,   486,   513,   511,   453,   465,   462,   461,     0,
     579,   207,   209,     0,     0,    78,     0,   165,    77,   193,
     227,   205,   262,   280,   278,    87,   584,   585,   363,     0,
     166,     0,     0,     0,   179,   184,   185,    93,    91,   319,
     344,     0,     0,     0,   421,   422,   423,   419,   420,   434,
       0,     0,   581,     0,   271,     0,   364,   170,   161,   164,
     162,     0,   391,   393,   345,     0,   463,     0,     0,   165,
       0,     0,   564,   254,     0,     0,   163,   346
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -783,   807,  1051,  -123,  -783,   -96,    27,  -783,  -783,    44,
     687,  -783,   646,  -288,   993,  1227,  -271,   607,  -783,  -783,
     631,  -783,   -38,  -456,   -59,   480,   -83,  -783,  -340,   361,
      94,    14,  -612,  -783,   833,   920,  -588,  -151,  -783,  -783,
    -783,  -783,  -614,  -783,   403,   613,   205,  -348,  -783,  -368,
    -276,  -127,   110,    47,    41,   169,  -783,   -53,  -782,  -319,
     249,  -783,  -783,     6,  1111,  -783,  -356,  1001,  -783,    76,
    -457,  -783,   939,   -47,  -783,     5,    79,  1128,  -329,   -28,
    1634,  -783,   683,  -783,     0,    31,   211,   -54,  -783,  -783,
    -783,  -783,   842,  -177,   541,   535,  -783,  -282,   368,    66,
     -60,    58,  -783,  -783,   228,  -783,   -76,   250,  -783,  1156,
    -783,  -783,  -783,  -783,   811,   812,   873,  -783,   -44,  -783,
    -783,  -783,  -783,  -783,  -783,  -783,  -783,   795,   845,  -783,
    -783,  -783,  -783,   -68,  1057,  -783,  -783,  -783,  -783,  -783,
     775,  -783,   -62,  -142,  1246,  -130,  -783,  -783,  -783,   -37,
     -79,  1235,  1239,    29,  -783,  -783,  -783,  1240,  -783,  -783,
    -783,  -783,  -783,  -783,   468,   779,  -783,  -783,  -783,  -783,
    -783,   777,  -783,   -84,  -783,    88,   754,  -783,   147,  -783,
    -783,   160,  -783,  -783,  -783,  -783,  -783,  -783,  -783,  -783,
    -783,  -783
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
       0,   152,   153,   154,   155,   156,    45,   158,   159,   295,
     161,   162,   296,   297,   298,   299,   300,   301,   605,   302,
     303,   304,   305,   306,   307,   308,   309,   310,   663,   664,
     665,    47,   312,   313,   369,   350,   853,   163,   351,   352,
     647,   648,   649,   650,   314,   315,   316,   613,   614,   617,
     317,   597,   318,   319,   320,   321,   322,   323,   324,   325,
     326,    51,   327,    52,   118,   328,    54,   587,   588,   329,
     330,   331,    55,   333,   334,    56,   335,    57,   457,    58,
     337,    60,   338,    62,   432,    64,    65,   683,    66,    67,
      68,    69,   686,   385,   386,   387,   388,   684,    70,    71,
      72,   474,    74,    75,   475,    77,   497,   887,    78,   701,
      79,    80,    81,    82,   414,   419,    83,    84,   415,    85,
      86,   435,    87,    88,   443,   444,   445,   446,    89,    90,
      91,   459,    92,   183,   184,   185,   558,   796,   186,   406,
     460,   167,   168,   169,   170,   464,   465,   466,   171,   534,
     172,   173,   174,   175,   546,   176,   547,   177,    94,    95,
      96,    97,    98,    99,   747,   477,   100,   101,   494,   498,
     478,   479,   760,   495,   496,   480,   500,   807,   481,   204,
     805,   482,   345,   637,   105,   106,   107,   108,   109,   110,
     111,   112
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      63,   400,   114,   624,   365,   119,   553,   531,   453,   370,
     598,   599,   670,   165,   164,   113,   396,   499,   694,   843,
     447,   493,   353,   206,   339,   119,   538,   206,   206,   425,
     603,   115,   452,   657,   856,   157,   420,   692,   455,   166,
     541,   193,   622,   166,   456,   433,   117,    48,   543,   203,
     355,   413,   160,   451,   524,   440,   160,   696,    73,   529,
     344,   348,   187,   458,   778,   555,   340,    63,    63,   339,
     952,   441,   483,   809,    63,   611,    63,   611,    63,   355,
     339,   208,   209,   800,   484,   898,   119,   611,   102,   526,
     611,   339,    63,   339,    63,   348,    63,    48,   687,    39,
     689,   690,   691,   585,     8,   622,   843,    63,   240,    63,
     544,    63,    63,   473,    48,    48,   810,   486,   311,   492,
     442,    48,   129,    48,   181,    48,    48,   434,   182,   870,
     537,   166,   454,   374,   178,   593,   403,   568,    48,    48,
     822,    48,   395,    48,   160,   382,   611,   103,   383,   390,
     801,   560,   468,    44,    48,   952,    48,   399,    48,    48,
     104,   571,   572,   120,   391,   594,   487,   179,   189,    49,
     339,   839,    22,   612,   418,   612,   165,   164,   845,   381,
     551,   166,   469,   339,   728,   612,   166,   463,   612,   618,
     485,   987,   205,   166,   160,    29,   342,   343,   157,   160,
     677,   142,   628,   180,   569,   692,   160,   580,    39,   877,
     582,   584,    36,    37,   960,    39,   116,    41,   959,    49,
     670,   181,   636,   685,   113,   182,   593,   181,    76,    36,
      37,   182,   729,   116,    41,   611,    49,    49,   399,   195,
     954,   470,   795,    49,   612,    49,   511,    49,    49,    50,
     363,   816,   512,   618,   471,   628,   594,   581,   583,   382,
      49,    49,   383,    49,   540,    49,   208,   209,   829,   193,
     421,   166,   201,   364,   380,   670,    49,   449,    49,   453,
      49,    49,   635,   579,   488,   356,   422,   837,  -291,   840,
     181,   450,   843,   381,   182,   375,   375,   348,   631,    50,
     397,   842,   375,   854,   375,   348,   404,   817,   818,   640,
     643,  -291,   824,   489,   398,   396,    50,    50,   623,     1,
     375,     2,    76,    50,   843,    50,   339,    50,    50,   692,
     825,   826,   196,   612,   458,   658,   742,   199,   399,   658,
      50,    50,   832,    50,   396,    50,   119,   490,   551,   491,
     165,   164,   208,   209,   208,   209,    50,   736,    50,   615,
      50,    50,   339,    63,   197,   339,   666,    63,   593,   198,
     339,   616,   157,   671,   669,    63,   447,   339,   367,   420,
     436,   623,   668,   200,   538,   368,   223,   639,   380,   990,
     946,   947,   348,   413,   689,   423,   971,   666,   594,   672,
     990,   364,   538,   454,    63,   232,   452,   165,   164,    48,
      48,   424,   455,   761,    48,   396,   753,   368,   456,   341,
     626,   355,    48,   339,   348,   711,   779,   451,   623,   157,
     437,   241,  -416,   166,   719,   373,   376,   740,   623,    36,
      37,   395,   389,   116,    41,    35,   160,   733,  -416,    39,
     720,    48,   628,   676,   438,   256,   383,   847,   439,   660,
     461,   780,   348,   781,   673,   355,   339,   631,    48,   810,
     395,   549,   379,   848,   348,    63,   895,    63,   670,   774,
     775,   776,   777,   346,   678,   364,   679,   381,   593,    23,
     678,   364,   679,   538,   511,    39,   792,   347,    27,    43,
      44,   348,    28,    63,   348,    63,   566,    63,   812,    63,
     789,   873,    48,   694,   512,   208,   209,   418,   594,   710,
      39,  -298,    48,    42,    48,   692,   166,   717,   208,   209,
     359,    49,    49,   165,   164,   749,    49,    43,    44,   160,
     790,   395,   672,   362,    49,   672,   366,   453,   670,   628,
      48,   815,    48,   166,    48,   157,    48,   939,    16,   371,
     540,   749,   255,   749,   476,   749,   160,   749,   208,   209,
     955,   956,   364,    49,   659,   502,   791,   504,   667,   506,
     508,   348,   380,   632,   593,   426,   552,   835,   208,   209,
      49,   666,   896,   208,   209,   208,   209,   823,   687,   448,
     899,   804,   458,   375,   861,   948,   501,   672,   666,   510,
     578,    50,    50,   623,   594,   974,    50,   623,   623,   623,
     582,   582,   808,   514,    50,   208,   209,   666,   823,   666,
     339,    46,   700,   515,    49,   516,   671,   669,   538,   538,
     396,   680,   681,   682,    49,   668,    49,   680,   681,   682,
     208,   209,    35,    50,   964,   863,    39,   208,   209,   517,
      43,    44,   672,   651,   652,  -301,   593,   581,   583,   885,
      50,   454,    49,   518,    49,   519,    49,    48,    49,   653,
     654,    46,   520,    61,   734,   735,   396,   623,   339,   823,
     521,   879,   339,   527,   339,   528,   594,   886,    46,    46,
      63,   951,   530,   746,   618,    46,   535,    46,    39,    46,
      46,   574,    43,    44,    50,   378,   545,   208,   209,   119,
     292,   293,    46,    46,    50,    46,    50,    46,   833,   976,
     733,   431,   668,   354,   208,   209,   784,   785,    46,   462,
      46,   576,    46,    46,    48,   618,    63,    48,   628,   672,
      61,    61,    50,   618,    50,   554,    50,    61,    50,   354,
     900,    61,   354,   950,   382,   875,   395,   383,   382,   876,
     382,   383,   909,   383,   354,    61,   559,    61,   561,    61,
     578,   808,   738,   787,   208,   209,   975,   864,   865,   562,
      61,   223,    61,    48,    61,    61,   864,   884,   381,    49,
     593,   563,   381,   575,   381,   533,   564,   668,   961,   573,
     232,   550,   395,   533,   907,   908,   462,   129,   669,   823,
     911,   912,   831,   808,   672,   548,   208,   209,   589,   378,
     594,   715,   557,   623,  -155,     1,   241,     2,   929,   930,
     669,   723,   593,   672,   678,   364,   679,    36,    37,   641,
     732,   116,    41,   577,  -145,   638,  -156,     1,  -250,     2,
     256,   339,  -275,   339,   666,   672,    49,   965,   600,    49,
     208,   209,   594,    36,    37,   591,    39,   116,    41,    50,
     349,   864,   935,   604,   357,   358,   503,   360,   505,   361,
     507,   509,   872,   380,   606,   579,   142,   880,   608,   880,
     609,   208,   209,   593,   291,   678,   364,   679,    36,    37,
     669,    39,   116,    41,   655,    49,   625,   593,   668,   678,
     364,   679,    35,   864,   938,    38,    39,   627,   700,    42,
      43,    44,    16,   594,   982,   672,   966,   864,   941,   208,
     209,   671,   985,   629,   630,   750,    50,   594,   656,    50,
     668,   513,   674,   885,   697,   660,   972,   957,   864,   942,
     702,   967,   983,   332,   208,   209,   703,   672,   962,   963,
     355,   764,   704,   766,   746,   768,   705,   770,   706,   642,
      30,   886,    35,   146,   147,    38,   542,   149,   150,   151,
     707,    44,   718,    46,    46,    50,   968,   646,    46,   208,
     209,   680,   681,   682,   977,   978,    46,    35,   332,    48,
      38,    39,   662,   724,    42,    43,    44,    48,   725,   332,
     737,   969,   578,   675,   208,   209,   988,   978,    48,   726,
     567,   570,   332,    39,   738,    46,   980,    43,    44,   208,
     209,   292,   293,   662,   996,   354,   354,   208,   209,   743,
     354,   492,    46,   962,   995,   748,   745,   586,   354,   783,
     586,   752,   680,   681,   682,   399,   763,   765,   767,     1,
     769,     2,   712,   713,   786,   716,   680,   681,   682,   292,
     788,   793,   721,   722,   794,   797,   798,   354,   799,   802,
     803,   578,   806,   731,   754,   811,    46,   755,   756,   631,
     757,   758,   812,   759,   354,   814,    46,   813,    46,   332,
     828,    53,   462,   834,   836,   408,   844,   851,   850,   852,
     857,   188,   332,   860,   904,   862,   883,   888,   592,   293,
     894,    49,   202,   578,    46,   897,    46,   905,    46,    49,
      46,   910,   913,   914,   915,   610,   332,   916,   354,   918,
      49,   919,   336,   920,   921,   923,   922,   409,   354,   924,
      61,   926,   533,   533,   533,   533,    16,   925,   933,   934,
     936,   937,   940,   943,   633,   944,   410,   973,    53,    53,
     970,   979,   989,   981,   993,    53,    61,    53,    61,    53,
      61,   984,    61,   533,    35,    36,    37,   336,    39,   116,
      41,    42,   992,    53,   950,    53,   997,    53,   336,   699,
     411,    50,   827,   536,    30,   782,   906,   412,    53,    50,
      53,   336,    53,    53,   607,   958,   830,   693,   590,   882,
      50,   991,   708,   881,   405,   709,   695,   662,   661,   727,
     741,    35,   556,   821,    38,    39,    93,   191,    42,    43,
      44,   192,   194,   762,   662,   751,     0,     0,     0,     0,
       0,    46,     0,     0,     0,   332,     0,     0,     0,     0,
       0,     0,     0,   662,   838,   662,     0,   619,     0,     0,
       0,     0,     0,     0,   849,   620,     0,   621,     0,   595,
       0,     0,     0,     0,   855,     1,   213,     2,   336,     0,
       0,     0,     0,     0,   332,   332,   565,     0,     0,   332,
       0,   336,     0,   354,     0,     0,   332,     0,   223,   224,
       0,     0,     0,     0,     0,     0,     0,     0,    46,     0,
     871,    46,     0,     0,   378,   874,   332,   232,   378,   228,
     378,     0,     0,   771,     0,   772,   231,     0,   228,   889,
     890,   891,   892,   893,     0,   231,     0,   238,   235,   236,
       0,     0,   332,   241,   332,     0,     0,   235,   236,     0,
     901,   595,     0,     0,   902,   903,   713,    46,     0,     0,
     354,     0,     0,   354,     0,   254,     0,   256,     0,   258,
     259,     0,    16,     0,     0,     0,   841,     0,     0,     0,
       0,     0,     0,   260,     0,   332,     0,     0,   262,   263,
       0,     0,   260,     0,     0,     0,     0,   262,   263,     0,
       0,     0,   267,     0,   595,     0,     0,     0,     0,   354,
      30,   267,     0,     0,     0,     0,     0,     0,     0,   492,
      30,   927,     0,   928,   283,     0,     0,     0,     0,     0,
       0,     0,     0,   287,   336,   595,     0,    35,   288,    37,
       0,    39,   116,    41,    42,   577,     0,    35,    36,    37,
      38,    39,   116,    41,    42,    43,    44,     0,     0,    38,
      39,   125,   126,     0,    43,    44,    53,     0,     0,     0,
     127,     0,     0,   336,   336,     0,   949,     0,   336,   953,
     855,   866,   867,   868,   869,   336,   129,     0,     0,     0,
     662,     0,   698,   130,     0,    53,     0,     0,     0,     0,
       0,     0,     0,   596,     0,   336,   595,     0,     0,     0,
     332,   132,     0,     0,     0,     0,   332,     0,   228,   135,
       0,   595,     0,     0,     0,   231,     0,   332,     0,     0,
     595,   336,     0,   336,     0,     0,     0,   235,   236,     0,
       0,     0,   190,     0,     0,     0,   332,   332,   332,     0,
     595,     0,     0,     0,     0,   141,     0,     0,     0,     0,
       0,     0,     0,   744,     0,   142,    53,     0,    53,     0,
     125,   126,     0,    46,   336,     0,     0,     0,     0,   127,
       0,    46,   260,     0,     0,   596,   917,   262,   263,     0,
       0,   145,    46,     0,    53,   129,    53,   986,    53,     0,
      53,   267,     0,    39,     0,   773,     0,   332,   332,   125,
     126,   332,     0,   332,    59,     0,   994,     0,   127,   595,
     132,     0,     0,   858,   931,   354,   932,     0,   135,     0,
       0,     0,     0,   354,   129,   595,     0,     0,   596,     0,
       0,   130,     0,     0,   354,     0,     0,     0,   595,     0,
      39,     0,     0,     0,    43,    44,   945,     0,     0,   132,
       0,     0,     0,     0,   141,     0,     0,   135,     0,   596,
       0,     0,     0,     0,   142,     0,     0,     0,     0,     0,
       0,    59,    59,   384,     0,   595,   595,     0,    59,   595,
       0,     0,    59,     0,   595,   595,     0,     0,     0,   336,
     145,     0,     0,   141,   595,     0,    59,     0,    59,     0,
      59,     0,    39,   142,     0,     0,   336,     0,     0,   739,
       0,    59,   773,    59,     0,    59,    59,     1,     0,     2,
       0,     0,     0,     0,     0,   336,     0,   336,   332,   145,
     596,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    39,     0,     0,     0,   596,     0,     0,     0,     0,
     223,     0,     0,     0,   596,     0,     0,     0,     0,   226,
       1,     0,     2,     0,     0,     0,     0,     0,     0,   232,
     332,     0,   332,   332,   596,     0,     0,     0,     0,     0,
       0,    53,     0,     0,   595,     0,   336,   384,   336,   238,
     336,     0,   336,     0,     0,   241,     0,     0,     0,     0,
       0,   595,     0,     0,   228,     0,     0,     0,     0,     0,
       0,   231,   595,     0,    16,     0,     0,     0,   595,   256,
       0,   258,   259,   235,   236,     0,     0,    53,     0,     0,
       0,     0,     0,     0,   595,     0,     0,   595,     0,     0,
     619,     0,     0,   596,     0,     0,     0,   859,   620,     0,
     621,     0,   595,   595,   595,   595,   595,    16,     0,   596,
       0,     0,    30,     0,   595,   595,   595,     0,   260,     0,
       0,     0,   596,   262,   263,     0,   283,     0,     0,     0,
       0,   223,   224,     0,     0,     0,     0,   267,     0,    35,
     595,   595,    38,    39,     0,     0,    42,    43,    44,   291,
     232,   292,   293,   294,     0,    30,     0,     0,     0,   596,
     596,     0,   595,   596,     0,   773,   595,     0,   596,   596,
     238,     0,     0,     0,     0,     0,   241,     0,   596,     0,
       0,     0,    35,    36,    37,    38,    39,   116,    41,    42,
      43,    44,     0,     0,     0,     0,     0,     0,     0,   595,
     256,     0,   258,   259,     0,     0,     0,   595,     0,   336,
       0,   336,   336,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   384,     0,     0,     0,   773,   467,     0,     0,     0,
       0,     0,     0,    30,     0,     0,     0,     0,     0,     0,
       1,     0,     2,     0,     0,     0,     3,   283,     0,     0,
       0,     0,     0,     0,     0,     4,   287,     0,   596,     0,
      35,   288,    37,     0,    39,   116,    41,    42,     0,     0,
       0,     0,     0,     0,     0,   596,     0,     5,     6,     0,
       0,     0,     0,     0,     0,     0,   596,     0,     0,     0,
       0,     0,   596,     8,     0,     0,     0,     0,     9,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   596,    10,
       0,   596,     0,    11,     0,     0,    12,    13,     0,    14,
       0,    59,     0,     0,     0,     0,   596,   596,   596,   596,
     596,     0,     0,     0,     0,     0,     0,    16,   596,   596,
     596,     0,     0,     0,    17,    18,     0,    59,     0,    59,
       0,    59,     0,    59,     0,    19,    20,     0,     0,     0,
      21,    22,    23,    24,   596,   596,     0,     0,     0,    25,
      26,    27,     0,     0,     0,    28,     0,     0,     0,     0,
       0,     0,     0,     0,    29,    30,   596,     0,     0,     0,
     596,     0,     0,    31,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    32,     0,    33,     0,    34,     0,     0,
       0,     0,    35,    36,    37,    38,    39,    40,    41,    42,
      43,    44,     0,   596,     0,     0,     0,     0,     0,     0,
       0,   596,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   207,     0,   208,
     209,     0,     0,     0,     0,   210,     0,   211,     0,     0,
       0,   416,     0,     0,     0,     0,   213,     0,     0,     0,
       0,   214,   215,     0,     0,     0,     0,   216,   217,   218,
     219,   220,   221,   222,     0,     0,     0,     0,   223,   224,
       0,     0,     0,     0,     0,     0,   225,   226,   227,   228,
       0,   408,     0,     0,   229,   230,   231,   232,     0,     0,
       0,   233,   234,     0,     0,     0,     0,     0,   235,   236,
       0,     0,     0,     0,     0,   237,     0,   238,     0,   239,
       0,   240,   384,   241,     0,   878,   384,   242,   384,   243,
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
     293,   294,   207,     0,   208,   209,   539,     0,     0,     0,
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
     284,   285,     0,     0,   286,     0,     0,     0,   287,   121,
       0,   122,    35,   288,   289,    38,    39,   116,   290,    42,
      43,    44,   291,   124,   292,   293,   294,   730,     0,   208,
     209,     0,     0,     0,     0,   210,     0,   211,     0,     7,
       0,     0,     0,     0,     0,   128,   213,     0,     0,     0,
       0,   214,   215,     0,     0,     0,     0,   216,   217,   218,
     219,   220,   221,   222,     0,     0,     0,     0,   223,   224,
       0,     0,     0,     0,    15,     0,   225,   133,     0,   228,
       0,   134,     0,     0,   229,   230,   231,   232,     0,     0,
     136,   233,   234,     0,     0,     0,     0,     0,   235,   236,
       0,     0,     0,     0,     0,   237,     0,   238,     0,   239,
     139,     0,     0,   241,     0,   140,     0,   242,     0,   243,
     244,     0,   245,     0,     0,     0,   247,   248,   249,   250,
     251,   252,     0,   253,   143,   254,     0,   256,   257,   258,
     259,     0,     0,   260,     0,     0,   261,     0,   262,   263,
       0,     0,     0,   264,     0,     0,     0,     0,     0,     0,
       0,   266,   267,   268,     0,     0,     0,   269,   270,   271,
       0,   272,   273,     0,   274,   275,     0,   276,     0,     0,
      30,   277,     0,     0,   278,   279,     0,     0,     0,     0,
       0,   280,   281,     0,   283,   284,   285,     0,     0,   286,
       0,     0,     0,   287,     0,     0,     0,    35,   288,    37,
       0,    39,   116,   290,    42,    43,    44,     0,     0,   292,
     293,   294,   819,     0,   208,   209,     0,     0,     0,     0,
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
       0,     1,     0,     2,   820,    38,    39,     0,   430,     0,
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
       0,   284,   285,   429,   427,   286,   208,   209,   644,     0,
       0,   645,     1,     0,     2,     0,     0,    39,     0,   430,
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
       0,     0,   284,   285,     0,   427,   286,   208,   209,   532,
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
       0,     0,     0,   645,     1,     0,     2,     0,     0,    39,
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
       0,   280,   281,   427,     0,   284,   285,   601,   602,   286,
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
     249,   250,   251,   252,     0,   253,     0,     0,     0,   619,
     257,     0,     0,     0,     0,   260,     0,   620,   261,   621,
     262,   263,     0,     0,     0,   264,     0,     0,   213,     0,
       0,     0,     0,   266,   267,   268,     0,     0,     0,   269,
     270,   271,     0,   272,   273,     0,   274,   275,     0,   276,
     223,   224,     0,   277,     0,     0,   278,   279,     0,     0,
       0,     0,     0,   280,   281,   688,     0,   284,   285,   232,
       0,   286,   714,   620,     0,   621,     0,     0,     0,     0,
       0,     0,     0,    39,     0,   430,     0,    43,    44,   238,
     634,   292,   293,   294,     0,   241,     0,     0,     0,     0,
       0,   121,     0,   122,     0,     0,   223,   224,     1,     0,
       2,     0,     0,     0,     0,   124,     0,   254,     0,   256,
       0,   258,   259,     0,     0,   232,     0,     0,     0,     0,
       0,     7,     0,     0,     0,     0,     0,   128,     0,     0,
       0,   223,     0,     0,     0,   238,     0,     0,     0,     0,
     226,   241,   228,     0,     0,     0,     0,     0,     0,   231,
     232,     0,    30,     0,     0,     0,    15,     0,     0,   133,
       0,   235,   236,   134,     0,   256,   283,   258,   259,     0,
     238,     0,   136,     0,     0,   287,   241,     0,     0,    35,
     288,    37,     0,    39,   116,    41,    42,     0,     0,     0,
       0,     0,   139,     0,     0,    16,     0,   140,     0,     0,
     256,     0,   258,   259,     0,     0,   260,     0,    30,     0,
       0,   262,   263,     0,     0,     0,   143,     0,     0,     0,
       0,   846,   283,     0,     0,   267,     0,     0,     0,     0,
       0,   287,   121,     0,   122,    35,   288,    37,     0,    39,
     116,    41,    42,    30,     0,     0,   124,     0,     1,     0,
       2,     0,     0,     0,     3,     0,     0,   283,     0,     0,
       0,     0,     7,     4,     0,     0,     0,     0,   128,     0,
      35,    36,    37,    38,    39,   116,    41,    42,    43,    44,
     291,     0,   292,   293,   294,     5,     6,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     7,    15,     0,     0,
     133,     8,     0,     0,   134,     0,     9,     0,     0,     1,
       0,     2,     0,   136,     0,   407,     0,    10,     0,     0,
       0,    11,     0,     0,    12,    13,     0,    14,     0,     0,
       0,    15,     0,   139,     0,     0,     0,     0,   140,     0,
       0,     0,     0,     0,     0,    16,     0,     0,     0,     0,
       0,     0,    17,    18,     0,   408,     0,   143,     0,     0,
       0,     0,     0,    19,    20,     0,     0,     0,    21,    22,
      23,    24,     0,     0,     0,     0,     0,    25,    26,    27,
       0,     0,     0,    28,     0,     0,     0,     0,     0,     0,
       0,     0,    29,    30,     1,     0,     2,   409,     0,     0,
       3,    31,     0,     0,     0,     0,    16,     0,     0,     4,
       0,    32,     0,    33,     0,    34,   410,     0,     0,     0,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
       0,     5,     6,     0,     0,     0,     0,     0,     0,   472,
       0,     0,     0,     0,     0,     0,     0,     8,     0,     0,
     411,     0,     9,     0,    30,     0,   473,   412,     0,     0,
       0,     0,     0,    10,     0,     0,     0,    11,     0,     0,
      12,    13,     0,    14,     0,     0,     0,     0,     0,     0,
       0,    35,     0,     0,    38,    39,     0,     0,    42,    43,
      44,    16,     0,     0,     0,     0,     0,     0,    17,    18,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    19,
      20,     0,     0,     0,    21,    22,    23,    24,     0,     0,
       0,     0,     0,    25,    26,    27,     1,     0,     2,    28,
       0,     0,     3,     0,     0,     0,     0,     0,    29,    30,
       0,     4,     0,     0,     0,     0,     0,    31,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    32,     0,    33,
       0,    34,     0,     5,     6,     0,    35,    36,    37,    38,
      39,    40,    41,    42,    43,    44,     0,     0,     0,     0,
       0,     0,     0,     0,     9,     0,     0,   401,     0,     0,
       0,     0,     0,     0,     0,    10,     0,     0,     0,    11,
       0,     0,    12,    13,     0,    14,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    16,     0,     0,     0,     0,     0,     0,
      17,    18,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    19,    20,     0,     0,     0,    21,     0,    23,    24,
       0,     0,     0,     0,     0,    25,    26,    27,     1,     0,
       2,    28,     0,     0,     3,     0,     0,     0,     0,     0,
       0,    30,     0,     4,     0,     0,     0,     0,   402,    31,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    32,
       0,    33,     0,    34,     0,     5,     6,     0,    35,    36,
      37,    38,    39,    40,    41,    42,    43,    44,     0,     0,
       0,     0,     0,     0,     0,     0,     9,     0,     0,   401,
       0,     0,     0,     0,     0,     0,     0,    10,     0,   392,
       0,    11,     0,     0,     0,    13,     0,    14,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    16,     0,     0,     0,     0,
       0,     0,    17,    18,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    19,    20,     0,     0,     0,    21,     0,
      23,    24,     0,     0,     0,     0,     0,    25,    26,    27,
       0,     0,     0,    28,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    30,     1,     0,     2,     0,     0,   393,
       3,    31,     0,     0,     0,     0,     0,     0,     0,     4,
       0,   394,     0,    33,     0,    34,     0,     0,     0,     0,
      35,    36,    37,    38,    39,   116,    41,    42,    43,    44,
       0,     5,     6,     0,     0,     0,     0,     0,     0,   472,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     9,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    10,     0,   392,     0,    11,     0,     0,
       0,    13,     0,    14,     0,     0,     0,     0,     0,     0,
       0,     0,   228,     0,     0,     0,     0,     0,     0,   231,
       0,    16,     0,     0,     0,     0,     0,     0,    17,    18,
       0,   235,   236,     0,     0,     0,     0,     0,     0,    19,
      20,     0,     0,     0,    21,     0,    23,    24,     0,     0,
       0,     0,     0,    25,    26,    27,     1,     0,     2,    28,
       0,     0,     3,     0,     0,     0,     0,     0,     0,    30,
       0,     4,     0,     0,     0,   393,   260,    31,     0,     0,
       0,   262,   263,     0,     0,     0,     0,   394,     0,    33,
       0,    34,     0,     5,     6,   267,    35,    36,    37,    38,
      39,   116,    41,    42,    43,    44,     0,     0,     0,     0,
       0,     0,     0,     0,     9,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    10,     0,   392,     0,    11,
       0,     0,     0,    13,     0,    14,     0,     0,     0,     0,
      35,    36,    37,    38,    39,   116,    41,    42,    43,    44,
       0,     0,     0,    16,     0,     0,     0,     0,     0,     0,
      17,    18,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    19,    20,     0,     0,     0,    21,     0,    23,    24,
       0,     0,     0,     0,     0,    25,    26,    27,     0,     0,
       0,    28,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    30,     1,     0,     2,     0,     0,   393,     3,    31,
       0,     0,     0,     0,     0,     0,     0,     4,     0,   394,
       0,    33,     0,    34,     0,     0,     0,     0,    35,    36,
      37,    38,    39,   116,    41,    42,    43,    44,     0,     5,
       6,     0,     0,     0,     0,     0,     0,   472,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       9,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    10,     0,     0,     0,    11,     0,     0,    12,    13,
       0,    14,     0,     0,     0,     0,     0,     0,     0,     0,
     228,     0,     0,     0,     0,     0,     0,   231,     0,    16,
       0,     0,     0,     0,     0,     0,    17,    18,     0,   235,
     236,     0,     0,     0,     0,     0,     0,    19,    20,     0,
       0,     0,    21,     0,    23,    24,     0,     0,     0,     0,
       0,    25,    26,    27,     1,     0,     2,    28,     0,     0,
       3,     0,     0,     0,     0,     0,     0,    30,     0,     4,
       0,     0,     0,     0,   260,    31,     0,     0,     0,   262,
     263,     0,     0,     0,     0,    32,     0,    33,     0,    34,
       0,     5,     6,   267,    35,    36,    37,    38,    39,    40,
      41,    42,    43,    44,     0,     0,     0,     0,     0,     0,
       0,     0,     9,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    10,     0,     0,     0,    11,     0,     0,
      12,    13,     0,    14,     0,     0,     0,     0,    35,    36,
      37,     0,    39,   116,    41,    42,    43,    44,     0,     0,
       0,    16,     0,     0,     0,     0,     0,     0,    17,    18,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    19,
      20,     0,     0,     0,    21,     0,    23,    24,     0,     0,
       0,     0,     0,    25,    26,    27,     1,     0,     2,    28,
       0,     0,     3,     0,     0,     0,     0,     0,     0,    30,
       0,     4,     0,     0,     0,     0,     0,    31,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   372,     0,    33,
       0,    34,     0,     5,     6,     0,    35,    36,    37,    38,
      39,    40,    41,    42,    43,    44,     0,     0,     0,     0,
       0,     0,     0,     0,     9,     0,     0,   401,     0,     0,
       0,     0,     0,     0,     0,    10,     0,     0,     0,    11,
       0,     0,     0,    13,     0,    14,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    16,     0,     0,     0,     0,     0,     0,
      17,    18,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    19,    20,     0,     0,     0,    21,     0,    23,    24,
       0,     0,     0,     0,     0,    25,    26,    27,     0,     0,
       0,    28,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    30,     1,     0,     2,     0,     0,     0,     3,    31,
       0,     0,     0,     0,     0,     0,     0,     4,     0,   372,
       0,    33,     0,    34,     0,     0,     0,     0,    35,    36,
      37,    38,    39,   116,    41,    42,    43,    44,     0,     5,
       6,     0,     0,     0,     0,     0,     0,   472,     0,     0,
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
       0,     0,     0,     0,     0,   372,     0,    33,     0,    34,
       0,     5,     6,     0,    35,    36,    37,    38,    39,   116,
      41,    42,    43,    44,     0,     0,     0,     0,     0,     0,
       0,     0,     9,     0,   121,     0,   122,     0,     0,     0,
       0,     0,     0,    10,     0,     0,     0,    11,   124,     0,
       0,    13,     0,    14,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     7,     0,     0,     0,     0,     0,
     128,    16,     0,     0,     0,     0,     0,     0,    17,    18,
       0,     0,   525,     0,     0,     0,     0,     0,     0,    19,
      20,     0,     0,     0,    21,     0,    23,    24,     0,    15,
       0,     0,   133,    25,    26,    27,   134,     0,     0,    28,
       0,     0,     0,     0,     0,   136,     0,     0,     0,    30,
       0,     0,     0,     0,     0,     0,     0,    31,     0,     0,
       0,     0,     0,     0,     0,   139,     0,   372,     0,    33,
     140,    34,     0,     0,     0,     0,    35,    36,    37,    38,
      39,   116,    41,    42,    43,    44,   121,     0,   122,   143,
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
       0,    77,     2,   322,    58,     5,   183,   158,    91,    63,
     298,   299,   368,     8,     8,     1,    76,   101,   386,   631,
      88,   100,    50,    23,    24,    25,   168,    27,    28,    83,
     301,     4,    91,   362,   648,     8,    80,   385,    91,     8,
     170,    12,   318,    12,    91,    20,     5,     0,   171,    22,
      50,    79,     8,    91,   150,     4,    12,   397,     0,   155,
      29,    18,    20,    91,   520,    20,    25,    67,    68,    69,
     852,    20,    20,     5,    74,    22,    76,    22,    78,    79,
      80,     8,     9,    94,    32,    20,    86,    22,     0,   151,
      22,    91,    92,    93,    94,    18,    96,    50,   380,   190,
     382,   383,   384,    26,    67,   381,   718,   107,    90,   109,
     172,   111,   112,    76,    67,    68,     5,    82,    24,     6,
      69,    74,    73,    76,   176,    78,    79,    86,   180,     5,
     167,   100,    91,    67,    20,    24,    78,    94,    91,    92,
     597,    94,    76,    96,   100,    69,    22,     0,    69,    20,
     161,   189,    94,   195,   107,   937,   109,    44,   111,   112,
       0,   199,   200,     6,    35,    54,   131,    53,     6,     0,
     170,   628,   135,   120,    80,   120,   171,   171,   634,    69,
     180,   150,    94,   183,    33,   120,   155,    93,   120,   316,
     138,   973,    23,   162,   150,   158,    27,    28,   171,   155,
     377,   152,   329,    89,   161,   553,   162,   207,   190,   191,
     210,   211,   187,   188,    20,   190,   191,   192,     5,    50,
     576,   176,   345,   168,   210,   180,    24,   176,     0,   187,
     188,   180,    81,   191,   192,    22,    67,    68,    44,   169,
     854,    94,   169,    74,   120,    76,    11,    78,    79,     0,
       4,   591,    17,   380,    94,   382,    54,   210,   211,   183,
      91,    92,   183,    94,   170,    96,     8,     9,   608,   240,
       4,   240,    20,    27,    69,   631,   107,     6,   109,   362,
     111,   112,   344,   207,    61,     6,    20,   627,     4,   629,
     176,    20,   904,   183,   180,    67,    68,    18,    11,    50,
       6,   630,    74,    45,    76,    18,    78,   595,   596,   347,
     348,    27,   600,    90,    20,   375,    67,    68,   318,    14,
      92,    16,    94,    74,   936,    76,   326,    78,    79,   677,
     601,   602,     6,   120,   362,   363,   466,     6,    44,   367,
      91,    92,   618,    94,   404,    96,   346,   124,   348,   126,
     345,   345,     8,     9,     8,     9,   107,    13,   109,    23,
     111,   112,   362,   363,    79,   365,   366,   367,    24,    79,
     370,    35,   345,   368,   368,   375,   444,   377,     4,   423,
      45,   381,   368,     6,   526,    11,    47,   346,   183,   977,
     846,   847,    18,   421,   676,     4,    50,   397,    54,   368,
     988,    27,   544,   362,   404,    66,   465,   402,   402,   362,
     363,    20,   465,   497,   367,   475,   495,    11,   465,    79,
     326,   421,   375,   423,    18,   425,   522,   465,   428,   402,
      95,    92,     4,   402,     4,    67,    68,   465,   438,   187,
     188,   375,    74,   191,   192,   186,   402,   447,    20,   190,
      20,   404,   579,   377,   119,   116,   377,     4,   123,   365,
      92,   523,    18,   525,   370,   465,   466,    11,   421,     5,
     404,   166,    69,    20,    18,   475,    20,   477,   834,   516,
     517,   518,   519,   123,    26,    27,    28,   377,    24,   136,
      26,    27,    28,   635,    11,   190,   550,     6,   145,   194,
     195,    18,   149,   503,    18,   505,    20,   507,    11,   509,
     547,   688,   465,   881,    17,     8,     9,   423,    54,   425,
     190,     6,   475,   193,   477,   873,   495,    20,     8,     9,
      21,   362,   363,   528,   528,   477,   367,   194,   195,   495,
      20,   475,   511,     6,   375,   514,     6,   630,   904,   676,
     503,   589,   505,   522,   507,   528,   509,   833,   111,    20,
     466,   503,   115,   505,    96,   507,   522,   509,     8,     9,
     858,   859,    27,   404,   363,   107,   549,   109,   367,   111,
     112,    18,   377,    20,    24,     4,   183,   625,     8,     9,
     421,   591,     5,     8,     9,     8,     9,   597,   880,    20,
      20,   574,   630,   375,   658,    20,    20,   576,   608,    15,
     207,   362,   363,   613,    54,   934,   367,   617,   618,   619,
     620,   621,     5,    11,   375,     8,     9,   627,   628,   629,
     630,     0,   404,     6,   465,     6,   631,   631,   780,   781,
     700,   183,   184,   185,   475,   631,   477,   183,   184,   185,
       8,     9,   186,   404,     5,    13,   190,     8,     9,     6,
     194,   195,   631,     4,     5,     9,    24,   620,   621,   697,
     421,   630,   503,     6,   505,     6,   507,   630,   509,    20,
      21,    50,     6,     0,     4,     5,   746,   687,   688,   689,
       6,   691,   692,    20,   694,     4,    54,   697,    67,    68,
     700,   852,   111,   475,   831,    74,     4,    76,   190,    78,
      79,     6,   194,   195,   465,    69,     9,     8,     9,   719,
     198,   199,    91,    92,   475,    94,   477,    96,   618,    20,
     730,    85,   718,    50,     8,     9,     4,     5,   107,    93,
     109,    11,   111,   112,   697,   872,   746,   700,   875,   718,
      67,    68,   503,   880,   505,    20,   507,    74,   509,    76,
     719,    78,    79,    19,   688,   689,   700,   688,   692,   690,
     694,   692,   745,   694,    91,    92,    20,    94,    20,    96,
     377,     5,     4,     5,     8,     9,   937,     4,     5,    20,
     107,    47,   109,   746,   111,   112,     4,     5,   688,   630,
      24,    20,   692,    50,   694,   159,    20,   793,   884,    20,
      66,   180,   746,   167,     4,     5,   170,    73,   812,   819,
       4,     5,   617,     5,   793,   179,     8,     9,     6,   183,
      54,   428,   186,   833,     6,    14,    92,    16,     4,     5,
     834,   438,    24,   812,    26,    27,    28,   187,   188,     6,
     447,   191,   192,   207,     6,   169,     6,    14,     6,    16,
     116,   861,     6,   863,   864,   834,   697,     5,     7,   700,
       8,     9,    54,   187,   188,     6,   190,   191,   192,   630,
      47,     4,     5,    12,    51,    52,   107,    54,   109,    56,
     111,   112,   687,   688,    18,   819,   152,   692,     6,   694,
      20,     8,     9,    24,   196,    26,    27,    28,   187,   188,
     904,   190,   191,   192,     5,   746,     6,    24,   904,    26,
      27,    28,   186,     4,     5,   189,   190,     6,   700,   193,
     194,   195,   111,    54,   962,   904,     5,     4,     5,     8,
       9,   936,   970,     6,     6,   477,   697,    54,     6,   700,
     936,   118,    74,   981,     6,   861,   929,   863,     4,     5,
      20,     5,   962,    24,     8,     9,     6,   936,     4,     5,
     970,   503,     6,   505,   746,   507,     6,   509,     6,   348,
     159,   981,   186,   187,   188,   189,   190,   191,   192,   193,
       6,   195,    11,   362,   363,   746,     5,   351,   367,     8,
       9,   183,   184,   185,     4,     5,   375,   186,    69,   962,
     189,   190,   366,     6,   193,   194,   195,   970,   134,    80,
       5,     5,   619,   377,     8,     9,     4,     5,   981,    20,
     197,   198,    93,   190,     4,   404,     5,   194,   195,     8,
       9,   198,   199,   397,     5,   362,   363,     8,     9,    20,
     367,     6,   421,     4,     5,    20,    85,   224,   375,     5,
     227,    20,   183,   184,   185,    44,    20,    20,    20,    14,
      20,    16,   426,   427,     5,   429,   183,   184,   185,   198,
     158,    11,   436,   437,    20,     4,    20,   404,    20,     5,
       5,   688,   197,   447,   186,    15,   465,   189,   190,    11,
     192,   193,    11,   195,   421,    18,   475,    17,   477,   170,
       6,     0,   466,    11,     5,    60,    20,     5,   169,    19,
     169,    10,   183,     5,    11,    20,    20,    20,   295,   199,
      20,   962,    21,   730,   503,    20,   505,    20,   507,   970,
     509,    20,    20,    20,    20,   312,   207,    20,   465,     5,
     981,     5,    24,     5,     4,     6,     5,   102,   475,     5,
     477,    27,   516,   517,   518,   519,   111,    74,     6,     5,
      11,    19,     5,     5,   341,     5,   121,    19,    67,    68,
     169,     5,    19,     6,     5,    74,   503,    76,   505,    78,
     507,    20,   509,   547,   186,   187,   188,    69,   190,   191,
     192,   193,    20,    92,    19,    94,    20,    96,    80,   402,
     155,   962,   605,   162,   159,   528,   736,   162,   107,   970,
     109,    93,   111,   112,   304,   864,   613,   385,   227,   694,
     981,   981,   421,   692,    78,   423,   391,   591,   365,   444,
     465,   186,   185,   597,   189,   190,     0,    12,   193,   194,
     195,    12,    12,   499,   608,   478,    -1,    -1,    -1,    -1,
      -1,   630,    -1,    -1,    -1,   326,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   627,   628,   629,    -1,     6,    -1,    -1,
      -1,    -1,    -1,    -1,   638,    14,    -1,    16,    -1,   296,
      -1,    -1,    -1,    -1,   648,    14,    25,    16,   170,    -1,
      -1,    -1,    -1,    -1,   365,   366,   195,    -1,    -1,   370,
      -1,   183,    -1,   630,    -1,    -1,   377,    -1,    47,    48,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   697,    -1,
     684,   700,    -1,    -1,   688,   689,   397,    66,   692,    58,
     694,    -1,    -1,   510,    -1,   512,    65,    -1,    58,   703,
     704,   705,   706,   707,    -1,    65,    -1,    86,    77,    78,
      -1,    -1,   423,    92,   425,    -1,    -1,    77,    78,    -1,
     724,   378,    -1,    -1,   728,   729,   730,   746,    -1,    -1,
     697,    -1,    -1,   700,    -1,   114,    -1,   116,    -1,   118,
     119,    -1,   111,    -1,    -1,    -1,   115,    -1,    -1,    -1,
      -1,    -1,    -1,   122,    -1,   466,    -1,    -1,   127,   128,
      -1,    -1,   122,    -1,    -1,    -1,    -1,   127,   128,    -1,
      -1,    -1,   141,    -1,   431,    -1,    -1,    -1,    -1,   746,
     159,   141,    -1,    -1,    -1,    -1,    -1,    -1,    -1,     6,
     159,   795,    -1,   797,   173,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   182,   326,   462,    -1,   186,   187,   188,
      -1,   190,   191,   192,   193,   819,    -1,   186,   187,   188,
     189,   190,   191,   192,   193,   194,   195,    -1,    -1,   189,
     190,    48,    49,    -1,   194,   195,   375,    -1,    -1,    -1,
      57,    -1,    -1,   365,   366,    -1,   850,    -1,   370,   853,
     854,   668,   669,   670,   671,   377,    73,    -1,    -1,    -1,
     864,    -1,   401,    80,    -1,   404,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   296,    -1,   397,   533,    -1,    -1,    -1,
     591,    98,    -1,    -1,    -1,    -1,   597,    -1,    58,   106,
      -1,   548,    -1,    -1,    -1,    65,    -1,   608,    -1,    -1,
     557,   423,    -1,   425,    -1,    -1,    -1,    77,    78,    -1,
      -1,    -1,    20,    -1,    -1,    -1,   627,   628,   629,    -1,
     577,    -1,    -1,    -1,    -1,   142,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   472,    -1,   152,   475,    -1,   477,    -1,
      48,    49,    -1,   962,   466,    -1,    -1,    -1,    -1,    57,
      -1,   970,   122,    -1,    -1,   378,   773,   127,   128,    -1,
      -1,   178,   981,    -1,   503,    73,   505,   971,   507,    -1,
     509,   141,    -1,   190,    -1,   514,    -1,   688,   689,    48,
      49,   692,    -1,   694,     0,    -1,   990,    -1,    57,   646,
      98,    -1,    -1,   650,   811,   962,   813,    -1,   106,    -1,
      -1,    -1,    -1,   970,    73,   662,    -1,    -1,   431,    -1,
      -1,    80,    -1,    -1,   981,    -1,    -1,    -1,   675,    -1,
     190,    -1,    -1,    -1,   194,   195,   843,    -1,    -1,    98,
      -1,    -1,    -1,    -1,   142,    -1,    -1,   106,    -1,   462,
      -1,    -1,    -1,    -1,   152,    -1,    -1,    -1,    -1,    -1,
      -1,    67,    68,    69,    -1,   712,   713,    -1,    74,   716,
      -1,    -1,    78,    -1,   721,   722,    -1,    -1,    -1,   591,
     178,    -1,    -1,   142,   731,    -1,    92,    -1,    94,    -1,
      96,    -1,   190,   152,    -1,    -1,   608,    -1,    -1,     6,
      -1,   107,   631,   109,    -1,   111,   112,    14,    -1,    16,
      -1,    -1,    -1,    -1,    -1,   627,    -1,   629,   819,   178,
     533,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   190,    -1,    -1,    -1,   548,    -1,    -1,    -1,    -1,
      47,    -1,    -1,    -1,   557,    -1,    -1,    -1,    -1,    56,
      14,    -1,    16,    -1,    -1,    -1,    -1,    -1,    -1,    66,
     861,    -1,   863,   864,   577,    -1,    -1,    -1,    -1,    -1,
      -1,   700,    -1,    -1,   821,    -1,   688,   183,   690,    86,
     692,    -1,   694,    -1,    -1,    92,    -1,    -1,    -1,    -1,
      -1,   838,    -1,    -1,    58,    -1,    -1,    -1,    -1,    -1,
      -1,    65,   849,    -1,   111,    -1,    -1,    -1,   855,   116,
      -1,   118,   119,    77,    78,    -1,    -1,   746,    -1,    -1,
      -1,    -1,    -1,    -1,   871,    -1,    -1,   874,    -1,    -1,
       6,    -1,    -1,   646,    -1,    -1,    -1,   650,    14,    -1,
      16,    -1,   889,   890,   891,   892,   893,   111,    -1,   662,
      -1,    -1,   159,    -1,   901,   902,   903,    -1,   122,    -1,
      -1,    -1,   675,   127,   128,    -1,   173,    -1,    -1,    -1,
      -1,    47,    48,    -1,    -1,    -1,    -1,   141,    -1,   186,
     927,   928,   189,   190,    -1,    -1,   193,   194,   195,   196,
      66,   198,   199,   200,    -1,   159,    -1,    -1,    -1,   712,
     713,    -1,   949,   716,    -1,   834,   953,    -1,   721,   722,
      86,    -1,    -1,    -1,    -1,    -1,    92,    -1,   731,    -1,
      -1,    -1,   186,   187,   188,   189,   190,   191,   192,   193,
     194,   195,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   986,
     116,    -1,   118,   119,    -1,    -1,    -1,   994,    -1,   861,
      -1,   863,   864,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   377,    -1,    -1,    -1,   904,     0,    -1,    -1,    -1,
      -1,    -1,    -1,   159,    -1,    -1,    -1,    -1,    -1,    -1,
      14,    -1,    16,    -1,    -1,    -1,    20,   173,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    29,   182,    -1,   821,    -1,
     186,   187,   188,    -1,   190,   191,   192,   193,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   838,    -1,    51,    52,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   849,    -1,    -1,    -1,
      -1,    -1,   855,    67,    -1,    -1,    -1,    -1,    72,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   871,    83,
      -1,   874,    -1,    87,    -1,    -1,    90,    91,    -1,    93,
      -1,   477,    -1,    -1,    -1,    -1,   889,   890,   891,   892,
     893,    -1,    -1,    -1,    -1,    -1,    -1,   111,   901,   902,
     903,    -1,    -1,    -1,   118,   119,    -1,   503,    -1,   505,
      -1,   507,    -1,   509,    -1,   129,   130,    -1,    -1,    -1,
     134,   135,   136,   137,   927,   928,    -1,    -1,    -1,   143,
     144,   145,    -1,    -1,    -1,   149,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   158,   159,   949,    -1,    -1,    -1,
     953,    -1,    -1,   167,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   177,    -1,   179,    -1,   181,    -1,    -1,
      -1,    -1,   186,   187,   188,   189,   190,   191,   192,   193,
     194,   195,    -1,   986,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   994,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,     6,    -1,     8,
       9,    -1,    -1,    -1,    -1,    14,    -1,    16,    -1,    -1,
      -1,    20,    -1,    -1,    -1,    -1,    25,    -1,    -1,    -1,
      -1,    30,    31,    -1,    -1,    -1,    -1,    36,    37,    38,
      39,    40,    41,    42,    -1,    -1,    -1,    -1,    47,    48,
      -1,    -1,    -1,    -1,    -1,    -1,    55,    56,    57,    58,
      -1,    60,    -1,    -1,    63,    64,    65,    66,    -1,    -1,
      -1,    70,    71,    -1,    -1,    -1,    -1,    -1,    77,    78,
      -1,    -1,    -1,    -1,    -1,    84,    -1,    86,    -1,    88,
      -1,    90,   688,    92,    -1,   691,   692,    96,   694,    98,
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
     174,   175,    -1,    -1,   178,    -1,    -1,    -1,   182,    32,
      -1,    34,   186,   187,   188,   189,   190,   191,   192,   193,
     194,   195,   196,    46,   198,   199,   200,     6,    -1,     8,
       9,    -1,    -1,    -1,    -1,    14,    -1,    16,    -1,    62,
      -1,    -1,    -1,    -1,    -1,    68,    25,    -1,    -1,    -1,
      -1,    30,    31,    -1,    -1,    -1,    -1,    36,    37,    38,
      39,    40,    41,    42,    -1,    -1,    -1,    -1,    47,    48,
      -1,    -1,    -1,    -1,    97,    -1,    55,   100,    -1,    58,
      -1,   104,    -1,    -1,    63,    64,    65,    66,    -1,    -1,
     113,    70,    71,    -1,    -1,    -1,    -1,    -1,    77,    78,
      -1,    -1,    -1,    -1,    -1,    84,    -1,    86,    -1,    88,
     133,    -1,    -1,    92,    -1,   138,    -1,    96,    -1,    98,
      99,    -1,   101,    -1,    -1,    -1,   105,   106,   107,   108,
     109,   110,    -1,   112,   157,   114,    -1,   116,   117,   118,
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
     127,   128,    -1,    -1,    -1,   132,    -1,    -1,    25,    -1,
      -1,    -1,    -1,   140,   141,   142,    -1,    -1,    -1,   146,
     147,   148,    -1,   150,   151,    -1,   153,   154,    -1,   156,
      47,    48,    -1,   160,    -1,    -1,   163,   164,    -1,    -1,
      -1,    -1,    -1,   170,   171,     6,    -1,   174,   175,    66,
      -1,   178,    69,    14,    -1,    16,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   190,    -1,   192,    -1,   194,   195,    86,
      21,   198,   199,   200,    -1,    92,    -1,    -1,    -1,    -1,
      -1,    32,    -1,    34,    -1,    -1,    47,    48,    14,    -1,
      16,    -1,    -1,    -1,    -1,    46,    -1,   114,    -1,   116,
      -1,   118,   119,    -1,    -1,    66,    -1,    -1,    -1,    -1,
      -1,    62,    -1,    -1,    -1,    -1,    -1,    68,    -1,    -1,
      -1,    47,    -1,    -1,    -1,    86,    -1,    -1,    -1,    -1,
      56,    92,    58,    -1,    -1,    -1,    -1,    -1,    -1,    65,
      66,    -1,   159,    -1,    -1,    -1,    97,    -1,    -1,   100,
      -1,    77,    78,   104,    -1,   116,   173,   118,   119,    -1,
      86,    -1,   113,    -1,    -1,   182,    92,    -1,    -1,   186,
     187,   188,    -1,   190,   191,   192,   193,    -1,    -1,    -1,
      -1,    -1,   133,    -1,    -1,   111,    -1,   138,    -1,    -1,
     116,    -1,   118,   119,    -1,    -1,   122,    -1,   159,    -1,
      -1,   127,   128,    -1,    -1,    -1,   157,    -1,    -1,    -1,
      -1,    21,   173,    -1,    -1,   141,    -1,    -1,    -1,    -1,
      -1,   182,    32,    -1,    34,   186,   187,   188,    -1,   190,
     191,   192,   193,   159,    -1,    -1,    46,    -1,    14,    -1,
      16,    -1,    -1,    -1,    20,    -1,    -1,   173,    -1,    -1,
      -1,    -1,    62,    29,    -1,    -1,    -1,    -1,    68,    -1,
     186,   187,   188,   189,   190,   191,   192,   193,   194,   195,
     196,    -1,   198,   199,   200,    51,    52,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    62,    97,    -1,    -1,
     100,    67,    -1,    -1,   104,    -1,    72,    -1,    -1,    14,
      -1,    16,    -1,   113,    -1,    20,    -1,    83,    -1,    -1,
      -1,    87,    -1,    -1,    90,    91,    -1,    93,    -1,    -1,
      -1,    97,    -1,   133,    -1,    -1,    -1,    -1,   138,    -1,
      -1,    -1,    -1,    -1,    -1,   111,    -1,    -1,    -1,    -1,
      -1,    -1,   118,   119,    -1,    60,    -1,   157,    -1,    -1,
      -1,    -1,    -1,   129,   130,    -1,    -1,    -1,   134,   135,
     136,   137,    -1,    -1,    -1,    -1,    -1,   143,   144,   145,
      -1,    -1,    -1,   149,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   158,   159,    14,    -1,    16,   102,    -1,    -1,
      20,   167,    -1,    -1,    -1,    -1,   111,    -1,    -1,    29,
      -1,   177,    -1,   179,    -1,   181,   121,    -1,    -1,    -1,
     186,   187,   188,   189,   190,   191,   192,   193,   194,   195,
      -1,    51,    52,    -1,    -1,    -1,    -1,    -1,    -1,    59,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    67,    -1,    -1,
     155,    -1,    72,    -1,   159,    -1,    76,   162,    -1,    -1,
      -1,    -1,    -1,    83,    -1,    -1,    -1,    87,    -1,    -1,
      90,    91,    -1,    93,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   186,    -1,    -1,   189,   190,    -1,    -1,   193,   194,
     195,   111,    -1,    -1,    -1,    -1,    -1,    -1,   118,   119,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   129,
     130,    -1,    -1,    -1,   134,   135,   136,   137,    -1,    -1,
      -1,    -1,    -1,   143,   144,   145,    14,    -1,    16,   149,
      -1,    -1,    20,    -1,    -1,    -1,    -1,    -1,   158,   159,
      -1,    29,    -1,    -1,    -1,    -1,    -1,   167,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   177,    -1,   179,
      -1,   181,    -1,    51,    52,    -1,   186,   187,   188,   189,
     190,   191,   192,   193,   194,   195,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    72,    -1,    -1,    75,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    83,    -1,    -1,    -1,    87,
      -1,    -1,    90,    91,    -1,    93,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   111,    -1,    -1,    -1,    -1,    -1,    -1,
     118,   119,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   129,   130,    -1,    -1,    -1,   134,    -1,   136,   137,
      -1,    -1,    -1,    -1,    -1,   143,   144,   145,    14,    -1,
      16,   149,    -1,    -1,    20,    -1,    -1,    -1,    -1,    -1,
      -1,   159,    -1,    29,    -1,    -1,    -1,    -1,   166,   167,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   177,
      -1,   179,    -1,   181,    -1,    51,    52,    -1,   186,   187,
     188,   189,   190,   191,   192,   193,   194,   195,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    72,    -1,    -1,    75,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    83,    -1,    85,
      -1,    87,    -1,    -1,    -1,    91,    -1,    93,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   111,    -1,    -1,    -1,    -1,
      -1,    -1,   118,   119,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   129,   130,    -1,    -1,    -1,   134,    -1,
     136,   137,    -1,    -1,    -1,    -1,    -1,   143,   144,   145,
      -1,    -1,    -1,   149,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   159,    14,    -1,    16,    -1,    -1,   165,
      20,   167,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    29,
      -1,   177,    -1,   179,    -1,   181,    -1,    -1,    -1,    -1,
     186,   187,   188,   189,   190,   191,   192,   193,   194,   195,
      -1,    51,    52,    -1,    -1,    -1,    -1,    -1,    -1,    59,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    72,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    83,    -1,    85,    -1,    87,    -1,    -1,
      -1,    91,    -1,    93,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    58,    -1,    -1,    -1,    -1,    -1,    -1,    65,
      -1,   111,    -1,    -1,    -1,    -1,    -1,    -1,   118,   119,
      -1,    77,    78,    -1,    -1,    -1,    -1,    -1,    -1,   129,
     130,    -1,    -1,    -1,   134,    -1,   136,   137,    -1,    -1,
      -1,    -1,    -1,   143,   144,   145,    14,    -1,    16,   149,
      -1,    -1,    20,    -1,    -1,    -1,    -1,    -1,    -1,   159,
      -1,    29,    -1,    -1,    -1,   165,   122,   167,    -1,    -1,
      -1,   127,   128,    -1,    -1,    -1,    -1,   177,    -1,   179,
      -1,   181,    -1,    51,    52,   141,   186,   187,   188,   189,
     190,   191,   192,   193,   194,   195,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    72,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    83,    -1,    85,    -1,    87,
      -1,    -1,    -1,    91,    -1,    93,    -1,    -1,    -1,    -1,
     186,   187,   188,   189,   190,   191,   192,   193,   194,   195,
      -1,    -1,    -1,   111,    -1,    -1,    -1,    -1,    -1,    -1,
     118,   119,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   129,   130,    -1,    -1,    -1,   134,    -1,   136,   137,
      -1,    -1,    -1,    -1,    -1,   143,   144,   145,    -1,    -1,
      -1,   149,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   159,    14,    -1,    16,    -1,    -1,   165,    20,   167,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    29,    -1,   177,
      -1,   179,    -1,   181,    -1,    -1,    -1,    -1,   186,   187,
     188,   189,   190,   191,   192,   193,   194,   195,    -1,    51,
      52,    -1,    -1,    -1,    -1,    -1,    -1,    59,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      72,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    83,    -1,    -1,    -1,    87,    -1,    -1,    90,    91,
      -1,    93,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      58,    -1,    -1,    -1,    -1,    -1,    -1,    65,    -1,   111,
      -1,    -1,    -1,    -1,    -1,    -1,   118,   119,    -1,    77,
      78,    -1,    -1,    -1,    -1,    -1,    -1,   129,   130,    -1,
      -1,    -1,   134,    -1,   136,   137,    -1,    -1,    -1,    -1,
      -1,   143,   144,   145,    14,    -1,    16,   149,    -1,    -1,
      20,    -1,    -1,    -1,    -1,    -1,    -1,   159,    -1,    29,
      -1,    -1,    -1,    -1,   122,   167,    -1,    -1,    -1,   127,
     128,    -1,    -1,    -1,    -1,   177,    -1,   179,    -1,   181,
      -1,    51,    52,   141,   186,   187,   188,   189,   190,   191,
     192,   193,   194,   195,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    72,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    83,    -1,    -1,    -1,    87,    -1,    -1,
      90,    91,    -1,    93,    -1,    -1,    -1,    -1,   186,   187,
     188,    -1,   190,   191,   192,   193,   194,   195,    -1,    -1,
      -1,   111,    -1,    -1,    -1,    -1,    -1,    -1,   118,   119,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   129,
     130,    -1,    -1,    -1,   134,    -1,   136,   137,    -1,    -1,
      -1,    -1,    -1,   143,   144,   145,    14,    -1,    16,   149,
      -1,    -1,    20,    -1,    -1,    -1,    -1,    -1,    -1,   159,
      -1,    29,    -1,    -1,    -1,    -1,    -1,   167,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   177,    -1,   179,
      -1,   181,    -1,    51,    52,    -1,   186,   187,   188,   189,
     190,   191,   192,   193,   194,   195,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    72,    -1,    -1,    75,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    83,    -1,    -1,    -1,    87,
      -1,    -1,    -1,    91,    -1,    93,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   111,    -1,    -1,    -1,    -1,    -1,    -1,
     118,   119,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   129,   130,    -1,    -1,    -1,   134,    -1,   136,   137,
      -1,    -1,    -1,    -1,    -1,   143,   144,   145,    -1,    -1,
      -1,   149,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   159,    14,    -1,    16,    -1,    -1,    -1,    20,   167,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    29,    -1,   177,
      -1,   179,    -1,   181,    -1,    -1,    -1,    -1,   186,   187,
     188,   189,   190,   191,   192,   193,   194,   195,    -1,    51,
      52,    -1,    -1,    -1,    -1,    -1,    -1,    59,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      72,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    83,    -1,    -1,    -1,    87,    -1,    -1,    -1,    91,
      -1,    93,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   111,
      -1,    -1,    -1,    -1,    -1,    -1,   118,   119,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   129,   130,    -1,
      -1,    -1,   134,    -1,   136,   137,    -1,    -1,    -1,    -1,
      -1,   143,   144,   145,    14,    -1,    16,   149,    -1,    -1,
      20,    -1,    -1,    -1,    -1,    -1,    -1,   159,    -1,    29,
      -1,    -1,    -1,    -1,    -1,   167,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   177,    -1,   179,    -1,   181,
      -1,    51,    52,    -1,   186,   187,   188,   189,   190,   191,
     192,   193,   194,   195,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    72,    -1,    32,    -1,    34,    -1,    -1,    -1,
      -1,    -1,    -1,    83,    -1,    -1,    -1,    87,    46,    -1,
      -1,    91,    -1,    93,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    62,    -1,    -1,    -1,    -1,    -1,
      68,   111,    -1,    -1,    -1,    -1,    -1,    -1,   118,   119,
      -1,    -1,    80,    -1,    -1,    -1,    -1,    -1,    -1,   129,
     130,    -1,    -1,    -1,   134,    -1,   136,   137,    -1,    97,
      -1,    -1,   100,   143,   144,   145,   104,    -1,    -1,   149,
      -1,    -1,    -1,    -1,    -1,   113,    -1,    -1,    -1,   159,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   167,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   133,    -1,   177,    -1,   179,
     138,   181,    -1,    -1,    -1,    -1,   186,   187,   188,   189,
     190,   191,   192,   193,   194,   195,    32,    -1,    34,   157,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    43,    -1,    -1,
      46,    -1,    48,    49,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    57,    -1,    -1,    -1,    -1,    62,    -1,    -1,    -1,
      -1,    -1,    68,    -1,    -1,    -1,    -1,    73,    -1,    -1,
      -1,    -1,    -1,    -1,    80,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    90,    -1,    -1,    -1,    -1,    -1,
      -1,    97,    98,    -1,   100,    -1,    -1,    -1,   104,    -1,
     106,    -1,    -1,    -1,    -1,    -1,    -1,   113,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   124,    -1,
     126,    -1,    -1,    -1,    -1,    -1,    -1,   133,    -1,    -1,
      -1,    -1,   138,    -1,    -1,    -1,   142,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   152,    -1,    -1,    -1,
      -1,   157,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   165,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   178,    -1,    -1,    -1,    -1,    32,    -1,    34,
     186,   187,   188,   189,   190,   191,   192,   193,    43,   195,
      -1,    46,    -1,    48,    49,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    57,    -1,    -1,    -1,    -1,    62,    -1,    -1,
      -1,    -1,    -1,    68,    32,    -1,    34,    -1,    73,    -1,
      -1,    -1,    -1,    -1,    -1,    80,    -1,    -1,    46,    -1,
      48,    49,    -1,    -1,    -1,    90,    -1,    -1,    -1,    57,
      -1,    -1,    97,    98,    62,   100,    -1,    -1,    -1,   104,
      68,   106,    -1,    -1,    -1,    73,    -1,    -1,   113,    -1,
      -1,    -1,    80,    -1,    -1,    -1,    -1,    -1,    -1,   124,
      -1,   126,    90,    -1,    -1,    -1,    -1,    -1,   133,    97,
      98,    -1,   100,   138,    -1,    -1,   104,   142,   106,    -1,
      -1,    -1,    -1,    -1,    -1,   113,    -1,   152,    -1,    -1,
      -1,    -1,   157,    -1,    -1,    -1,   124,    -1,    -1,    -1,
     165,    32,    -1,    34,    -1,   133,    -1,    -1,    -1,    -1,
     138,    -1,    -1,   178,   142,    46,    -1,    48,    49,    -1,
      -1,    -1,    -1,    -1,   152,   190,    57,    -1,    -1,   157,
      -1,    62,    -1,    -1,    -1,    -1,    -1,    68,    -1,    -1,
      -1,    -1,    73,    -1,    -1,    -1,    -1,    -1,    -1,    80,
     178,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   190,    -1,    -1,    -1,    97,    98,    -1,   100,
      -1,    -1,    -1,   104,    -1,   106,    -1,    -1,    -1,    -1,
      -1,    -1,   113,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   133,    -1,    -1,    -1,    -1,   138,    -1,    -1,
      -1,   142,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   152,    -1,    -1,    -1,    -1,   157,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   178,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   190
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
       6,     6,    90,   124,   206,    80,   343,    20,     4,   206,
     111,   238,    10,   213,   350,     4,   203,   350,   344,    10,
     231,   346,   190,   204,   343,     9,   355,   357,   213,   166,
     221,   285,   245,   294,    20,    20,   335,   213,   337,    20,
     223,    20,    20,    20,    20,   265,    20,   235,    94,   161,
     235,   223,   223,    20,     6,    50,    11,   213,   245,   270,
     285,   254,   285,   254,   285,    26,   235,   268,   269,     6,
     268,     6,   235,    24,    54,   215,   216,   252,   214,   214,
       7,    10,    11,   217,    12,   219,    18,   236,     6,    20,
     235,    22,   120,   248,   249,    23,    35,   250,   252,     6,
      14,    16,   251,   285,   260,     6,   231,     6,   252,     6,
       6,    11,    20,   235,    21,   343,   204,   384,   169,   255,
     223,     6,   221,   223,    10,    13,   213,   241,   242,   243,
     244,     4,     5,    20,    21,     5,     6,   279,   280,   287,
     231,   317,   213,   229,   230,   231,   285,   287,   232,   264,
     267,   276,   286,   231,    74,   213,   270,   294,    26,    28,
     183,   184,   185,   288,   298,   168,   293,   298,     6,   298,
     298,   298,   248,   293,   250,   329,   229,     6,   265,   202,
     305,   310,    20,     6,     6,     6,     6,     6,   315,   316,
     231,   285,   213,   213,    69,   245,   213,    20,    11,     4,
      20,   213,   213,   245,     6,   134,    20,   328,    33,    81,
       6,   213,   245,   285,     4,     5,    13,     5,     4,     6,
     280,   341,   346,    20,   265,    85,   305,   365,    20,   302,
     365,   372,    20,   351,   186,   189,   190,   192,   193,   195,
     373,   374,   377,    20,   365,    20,   365,    20,   365,    20,
     365,   235,   235,   265,   350,   350,   350,   350,   224,   206,
     343,   343,   211,     5,     4,     5,     5,     5,   158,   350,
      20,   207,   288,    11,    20,   169,   338,     4,    20,    20,
      94,   161,     5,     5,   207,   381,   197,   378,     5,     5,
       5,    15,    11,    17,    18,   223,   229,   214,   214,     6,
     188,   213,   271,   285,   214,   217,   217,   218,     6,   229,
     246,   247,   251,   253,    11,   223,     5,   229,   213,   271,
     229,   115,   279,   233,    20,   224,    21,     4,    20,   213,
     169,     5,    19,   237,    45,   213,   243,   169,   215,   216,
       5,   288,    20,    13,     4,     5,   235,   235,   235,   235,
       5,   213,   247,   294,   213,   270,   277,   191,   281,   285,
     247,   295,   296,    20,     5,   280,   285,   308,    20,   213,
     213,   213,   213,   213,    20,    20,     5,    20,    20,    20,
     255,   213,   213,   213,    11,    20,   226,     4,     5,   207,
      20,     4,     5,    20,    20,    20,    20,   235,     5,     5,
       5,     4,     5,     6,     5,    74,    27,   213,   213,     4,
       5,   235,   235,     6,     5,     5,    11,    19,     5,   251,
       5,     5,     5,     5,     5,   235,   224,   224,    20,   213,
      19,   238,   259,   213,   243,   214,   214,   231,   230,     5,
      20,   307,     4,     5,     5,     5,     5,     5,     5,     5,
     169,    50,   207,    19,   260,   238,    20,     4,     5,     5,
       5,     6,   280,   285,    20,   280,   213,   259,     4,    19,
     237,   308,    20,     5,   213,     5,     5,    20
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int16 yyr1[] =
{
       0,   201,   202,   202,   203,   203,   203,   204,   204,   204,
     204,   204,   204,   204,   204,   204,   204,   204,   204,   205,
     205,   205,   205,   205,   206,   206,   206,   207,   208,   208,
     209,   209,   210,   210,   210,   210,   211,   211,   212,   212,
     212,   212,   212,   212,   212,   212,   213,   213,   213,   213,
     213,   214,   214,   215,   216,   217,   217,   217,   217,   218,
     218,   219,   220,   220,   220,   220,   221,   221,   221,   221,
     221,   221,   221,   221,   222,   222,   222,   222,   222,   223,
     223,   224,   225,   226,   227,   227,   227,   227,   228,   228,
     229,   229,   230,   230,   230,   231,   231,   231,   231,   231,
     232,   232,   233,   233,   233,   233,   233,   233,   233,   233,
     234,   234,   234,   234,   234,   234,   234,   234,   234,   234,
     234,   234,   234,   234,   234,   234,   234,   234,   234,   234,
     234,   234,   234,   234,   234,   234,   234,   234,   234,   234,
     234,   234,   234,   234,   234,   234,   234,   234,   234,   234,
     234,   234,   234,   234,   234,   234,   234,   235,   235,   235,
     235,   236,   236,   236,   236,   237,   237,   238,   238,   239,
     239,   239,   239,   239,   240,   240,   241,   241,   241,   241,
     242,   243,   243,   244,   244,   244,   245,   245,   246,   246,
     247,   247,   247,   247,   248,   248,   249,   250,   250,   251,
     251,   251,   251,   251,   251,   251,   251,   251,   251,   251,
     252,   252,   253,   253,   254,   254,   254,   254,   255,   255,
     255,   255,   256,   256,   256,   256,   257,   257,   258,   258,
     258,   258,   258,   259,   259,   259,   259,   260,   261,   261,
     262,   263,   263,   263,   264,   265,   265,   265,   265,   266,
     266,   267,   268,   268,   269,   270,   270,   270,   270,   270,
     271,   271,   271,   271,   272,   272,   273,   273,   273,   273,
     274,   274,   275,   275,   275,   275,   275,   276,   277,   277,
     277,   278,   279,   279,   279,   280,   280,   280,   280,   280,
     280,   280,   281,   281,   281,   281,   282,   283,   284,   285,
     285,   286,   287,   287,   287,   287,   288,   289,   289,   290,
     290,   291,   292,   293,   294,   294,   295,   295,   296,   296,
     296,   297,   297,   297,   297,   297,   298,   298,   298,   298,
     298,   298,   299,   299,   299,   300,   300,   300,   300,   300,
     300,   300,   300,   300,   300,   300,   300,   300,   300,   300,
     300,   300,   300,   300,   300,   300,   300,   300,   300,   300,
     300,   300,   300,   300,   300,   300,   300,   300,   300,   300,
     300,   300,   300,   300,   300,   300,   301,   301,   301,   302,
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
       3,     1,     1,     1,     1,     2,     1,     2,     3,     4,
       3,     4,     3,     4,     3,     1,     1,     4,     4,     1,
       1,     1,     1,     1,     1,     2,     3,     4,     1,     2,
       1,     3,     1,     3,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     2,     1,     2,
       2,     5,     5,     8,     5,     1,     2,     1,     1,     2,
       5,     2,     2,     2,     1,     2,     1,     1,     2,     3,
       2,     1,     1,     1,     3,     3,     1,     3,     1,     3,
       1,     3,     2,     4,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     3,     3,     4,     3,     4,     3,     4,
       1,     1,     1,     1,     1,     2,     3,     4,     1,     2,
       3,     4,     1,     2,     3,     4,     1,     4,     2,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     2,     3,
       1,     1,     1,     2,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     6,     1,     3,     3,     3,     3,
       1,     1,     4,     3,     1,     2,     1,     2,     3,     4,
       1,     5,     1,     1,     1,     1,     1,     1,     4,     1,
       4,     1,     1,     1,     1,     1,     1,     3,     1,     4,
       1,     1,     1,     4,     3,     4,     1,     2,     1,     1,
       3,     1,     3,     3,     3,     3,     1,     2,     2,     3,
       3,     3,     1,     1,     1,     3,     1,     3,     3,     4,
       1,     3,     3,     3,     3,     3,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     2,     2,     2,     3,     2,
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
#line 646 "HAL_S.y"
                                { (yyval.declare_body_) = make_AAdeclareBody_declarationList((yyvsp[0].declaration_list_)); (yyval.declare_body_)->line_number = (yyloc).first_line; (yyval.declare_body_)->char_number = (yyloc).first_column;  }
#line 4180 "Parser.c"
    break;

  case 3: /* DECLARE_BODY: ATTRIBUTES _SYMB_0 DECLARATION_LIST  */
#line 647 "HAL_S.y"
                                        { (yyval.declare_body_) = make_ABdeclareBody_attributes_declarationList((yyvsp[-2].attributes_), (yyvsp[0].declaration_list_)); (yyval.declare_body_)->line_number = (yyloc).first_line; (yyval.declare_body_)->char_number = (yyloc).first_column;  }
#line 4186 "Parser.c"
    break;

  case 4: /* ATTRIBUTES: ARRAY_SPEC TYPE_AND_MINOR_ATTR  */
#line 649 "HAL_S.y"
                                            { (yyval.attributes_) = make_AAattributes_arraySpec_typeAndMinorAttr((yyvsp[-1].array_spec_), (yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4192 "Parser.c"
    break;

  case 5: /* ATTRIBUTES: ARRAY_SPEC  */
#line 650 "HAL_S.y"
               { (yyval.attributes_) = make_ABattributes_arraySpec((yyvsp[0].array_spec_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4198 "Parser.c"
    break;

  case 6: /* ATTRIBUTES: TYPE_AND_MINOR_ATTR  */
#line 651 "HAL_S.y"
                        { (yyval.attributes_) = make_ACattributes_typeAndMinorAttr((yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 4204 "Parser.c"
    break;

  case 7: /* DECLARATION: NAME_ID  */
#line 653 "HAL_S.y"
                      { (yyval.declaration_) = make_AAdeclaration_nameId((yyvsp[0].name_id_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4210 "Parser.c"
    break;

  case 8: /* DECLARATION: NAME_ID ATTRIBUTES  */
#line 654 "HAL_S.y"
                       { (yyval.declaration_) = make_ABdeclaration_nameId_attributes((yyvsp[-1].name_id_), (yyvsp[0].attributes_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4216 "Parser.c"
    break;

  case 9: /* DECLARATION: _SYMB_188  */
#line 655 "HAL_S.y"
              { (yyval.declaration_) = make_ACdeclaration_labelToken((yyvsp[0].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4222 "Parser.c"
    break;

  case 10: /* DECLARATION: _SYMB_188 TYPE_AND_MINOR_ATTR  */
#line 656 "HAL_S.y"
                                  { (yyval.declaration_) = make_ACdeclaration_labelToken_type_minorAttrList((yyvsp[-1].string_), (yyvsp[0].type_and_minor_attr_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4228 "Parser.c"
    break;

  case 11: /* DECLARATION: _SYMB_188 _SYMB_120 MINOR_ATTR_LIST  */
#line 657 "HAL_S.y"
                                        { (yyval.declaration_) = make_ACdeclaration_labelToken_procedure_minorAttrList((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4234 "Parser.c"
    break;

  case 12: /* DECLARATION: _SYMB_188 _SYMB_120  */
#line 658 "HAL_S.y"
                        { (yyval.declaration_) = make_ADdeclaration_labelToken_procedure((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4240 "Parser.c"
    break;

  case 13: /* DECLARATION: _SYMB_188 _SYMB_86 TYPE_AND_MINOR_ATTR  */
#line 659 "HAL_S.y"
                                           { (yyval.declaration_) = make_ACdeclaration_labelToken_function_minorAttrList((yyvsp[-2].string_), (yyvsp[0].type_and_minor_attr_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4246 "Parser.c"
    break;

  case 14: /* DECLARATION: _SYMB_188 _SYMB_86  */
#line 660 "HAL_S.y"
                       { (yyval.declaration_) = make_ADdeclaration_labelToken_function((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4252 "Parser.c"
    break;

  case 15: /* DECLARATION: _SYMB_189 _SYMB_76  */
#line 661 "HAL_S.y"
                       { (yyval.declaration_) = make_AEdeclaration_eventToken_event((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4258 "Parser.c"
    break;

  case 16: /* DECLARATION: _SYMB_189 _SYMB_76 MINOR_ATTR_LIST  */
#line 662 "HAL_S.y"
                                       { (yyval.declaration_) = make_AFdeclaration_eventToken_event_minorAttrList((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4264 "Parser.c"
    break;

  case 17: /* DECLARATION: _SYMB_189  */
#line 663 "HAL_S.y"
              { (yyval.declaration_) = make_AGdeclaration_eventToken((yyvsp[0].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4270 "Parser.c"
    break;

  case 18: /* DECLARATION: _SYMB_189 MINOR_ATTR_LIST  */
#line 664 "HAL_S.y"
                              { (yyval.declaration_) = make_AHdeclaration_eventToken_minorAttrList((yyvsp[-1].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 4276 "Parser.c"
    break;

  case 19: /* ARRAY_SPEC: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 666 "HAL_S.y"
                                                    { (yyval.array_spec_) = make_AAarraySpec_arrayHead_literalExpOrStar((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4282 "Parser.c"
    break;

  case 20: /* ARRAY_SPEC: _SYMB_86  */
#line 667 "HAL_S.y"
             { (yyval.array_spec_) = make_ABarraySpec_function(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4288 "Parser.c"
    break;

  case 21: /* ARRAY_SPEC: _SYMB_120  */
#line 668 "HAL_S.y"
              { (yyval.array_spec_) = make_ACarraySpec_procedure(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4294 "Parser.c"
    break;

  case 22: /* ARRAY_SPEC: _SYMB_122  */
#line 669 "HAL_S.y"
              { (yyval.array_spec_) = make_ADarraySpec_program(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4300 "Parser.c"
    break;

  case 23: /* ARRAY_SPEC: _SYMB_161  */
#line 670 "HAL_S.y"
              { (yyval.array_spec_) = make_AEarraySpec_task(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 4306 "Parser.c"
    break;

  case 24: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC  */
#line 672 "HAL_S.y"
                                { (yyval.type_and_minor_attr_) = make_AAtypeAndMinorAttr_typeSpec((yyvsp[0].type_spec_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4312 "Parser.c"
    break;

  case 25: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC MINOR_ATTR_LIST  */
#line 673 "HAL_S.y"
                              { (yyval.type_and_minor_attr_) = make_ABtypeAndMinorAttr_typeSpec_minorAttrList((yyvsp[-1].type_spec_), (yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4318 "Parser.c"
    break;

  case 26: /* TYPE_AND_MINOR_ATTR: MINOR_ATTR_LIST  */
#line 674 "HAL_S.y"
                    { (yyval.type_and_minor_attr_) = make_ACtypeAndMinorAttr_minorAttrList((yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 4324 "Parser.c"
    break;

  case 27: /* IDENTIFIER: _SYMB_191  */
#line 676 "HAL_S.y"
                       { (yyval.identifier_) = make_AAidentifier((yyvsp[0].string_)); (yyval.identifier_)->line_number = (yyloc).first_line; (yyval.identifier_)->char_number = (yyloc).first_column;  }
#line 4330 "Parser.c"
    break;

  case 28: /* SQ_DQ_NAME: DOUBLY_QUAL_NAME_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 678 "HAL_S.y"
                                                               { (yyval.sq_dq_name_) = make_AAsQdQName_doublyQualNameHead_literalExpOrStar((yyvsp[-2].doubly_qual_name_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 4336 "Parser.c"
    break;

  case 29: /* SQ_DQ_NAME: ARITH_CONV  */
#line 679 "HAL_S.y"
               { (yyval.sq_dq_name_) = make_ABsQdQName_arithConv((yyvsp[0].arith_conv_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 4342 "Parser.c"
    break;

  case 30: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_174 _SYMB_2  */
#line 681 "HAL_S.y"
                                          { (yyval.doubly_qual_name_head_) = make_AAdoublyQualNameHead_vector(); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 4348 "Parser.c"
    break;

  case 31: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_102 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_0  */
#line 682 "HAL_S.y"
                                                  { (yyval.doubly_qual_name_head_) = make_ABdoublyQualNameHead_matrix_literalExpOrStar((yyvsp[-1].literal_exp_or_star_)); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 4354 "Parser.c"
    break;

  case 32: /* ARITH_CONV: _SYMB_94  */
#line 684 "HAL_S.y"
                      { (yyval.arith_conv_) = make_AAarithConv_integer(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4360 "Parser.c"
    break;

  case 33: /* ARITH_CONV: _SYMB_138  */
#line 685 "HAL_S.y"
              { (yyval.arith_conv_) = make_ABarithConv_scalar(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4366 "Parser.c"
    break;

  case 34: /* ARITH_CONV: _SYMB_174  */
#line 686 "HAL_S.y"
              { (yyval.arith_conv_) = make_ACarithConv_vector(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4372 "Parser.c"
    break;

  case 35: /* ARITH_CONV: _SYMB_102  */
#line 687 "HAL_S.y"
              { (yyval.arith_conv_) = make_ADarithConv_matrix(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4378 "Parser.c"
    break;

  case 36: /* DECLARATION_LIST: DECLARATION  */
#line 689 "HAL_S.y"
                               { (yyval.declaration_list_) = make_AAdeclaration_list((yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 4384 "Parser.c"
    break;

  case 37: /* DECLARATION_LIST: DCL_LIST_COMMA DECLARATION  */
#line 690 "HAL_S.y"
                               { (yyval.declaration_list_) = make_ABdeclaration_list((yyvsp[-1].dcl_list_comma_), (yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 4390 "Parser.c"
    break;

  case 38: /* NAME_ID: IDENTIFIER  */
#line 692 "HAL_S.y"
                     { (yyval.name_id_) = make_AAnameId_identifier((yyvsp[0].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4396 "Parser.c"
    break;

  case 39: /* NAME_ID: IDENTIFIER _SYMB_107  */
#line 693 "HAL_S.y"
                         { (yyval.name_id_) = make_ABnameId_identifier_name((yyvsp[-1].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4402 "Parser.c"
    break;

  case 40: /* NAME_ID: BIT_ID  */
#line 694 "HAL_S.y"
           { (yyval.name_id_) = make_ACnameId_bitId((yyvsp[0].bit_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4408 "Parser.c"
    break;

  case 41: /* NAME_ID: CHAR_ID  */
#line 695 "HAL_S.y"
            { (yyval.name_id_) = make_ADnameId_charId((yyvsp[0].char_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4414 "Parser.c"
    break;

  case 42: /* NAME_ID: _SYMB_183  */
#line 696 "HAL_S.y"
              { (yyval.name_id_) = make_AEnameId_bitFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4420 "Parser.c"
    break;

  case 43: /* NAME_ID: _SYMB_184  */
#line 697 "HAL_S.y"
              { (yyval.name_id_) = make_AFnameId_charFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4426 "Parser.c"
    break;

  case 44: /* NAME_ID: _SYMB_186  */
#line 698 "HAL_S.y"
              { (yyval.name_id_) = make_AGnameId_structIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4432 "Parser.c"
    break;

  case 45: /* NAME_ID: _SYMB_187  */
#line 699 "HAL_S.y"
              { (yyval.name_id_) = make_AHnameId_structFunctionIdentifierToken((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 4438 "Parser.c"
    break;

  case 46: /* ARITH_EXP: TERM  */
#line 701 "HAL_S.y"
                 { (yyval.arith_exp_) = make_AAarithExpTerm((yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4444 "Parser.c"
    break;

  case 47: /* ARITH_EXP: PLUS TERM  */
#line 702 "HAL_S.y"
              { (yyval.arith_exp_) = make_ABarithExpPlusTerm((yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4450 "Parser.c"
    break;

  case 48: /* ARITH_EXP: MINUS TERM  */
#line 703 "HAL_S.y"
               { (yyval.arith_exp_) = make_ACarithMinusTerm((yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4456 "Parser.c"
    break;

  case 49: /* ARITH_EXP: ARITH_EXP PLUS TERM  */
#line 704 "HAL_S.y"
                        { (yyval.arith_exp_) = make_ADarithExpArithExpPlusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4462 "Parser.c"
    break;

  case 50: /* ARITH_EXP: ARITH_EXP MINUS TERM  */
#line 705 "HAL_S.y"
                         { (yyval.arith_exp_) = make_AEarithExpArithExpMinusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4468 "Parser.c"
    break;

  case 51: /* TERM: PRODUCT  */
#line 707 "HAL_S.y"
               { (yyval.term_) = make_AAtermNoDivide((yyvsp[0].product_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4474 "Parser.c"
    break;

  case 52: /* TERM: PRODUCT _SYMB_3 TERM  */
#line 708 "HAL_S.y"
                         { (yyval.term_) = make_ABtermDivide((yyvsp[-2].product_), (yyvsp[0].term_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4480 "Parser.c"
    break;

  case 53: /* PLUS: _SYMB_4  */
#line 710 "HAL_S.y"
               { (yyval.plus_) = make_AAplus(); (yyval.plus_)->line_number = (yyloc).first_line; (yyval.plus_)->char_number = (yyloc).first_column;  }
#line 4486 "Parser.c"
    break;

  case 54: /* MINUS: _SYMB_5  */
#line 712 "HAL_S.y"
                { (yyval.minus_) = make_AAminus(); (yyval.minus_)->line_number = (yyloc).first_line; (yyval.minus_)->char_number = (yyloc).first_column;  }
#line 4492 "Parser.c"
    break;

  case 55: /* PRODUCT: FACTOR  */
#line 714 "HAL_S.y"
                 { (yyval.product_) = make_AAproductSingle((yyvsp[0].factor_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4498 "Parser.c"
    break;

  case 56: /* PRODUCT: FACTOR _SYMB_6 PRODUCT  */
#line 715 "HAL_S.y"
                           { (yyval.product_) = make_ABproductCross((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4504 "Parser.c"
    break;

  case 57: /* PRODUCT: FACTOR _SYMB_7 PRODUCT  */
#line 716 "HAL_S.y"
                           { (yyval.product_) = make_ACproductDot((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4510 "Parser.c"
    break;

  case 58: /* PRODUCT: FACTOR PRODUCT  */
#line 717 "HAL_S.y"
                   { (yyval.product_) = make_ADproductMultiplication((yyvsp[-1].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4516 "Parser.c"
    break;

  case 59: /* FACTOR: PRIMARY  */
#line 719 "HAL_S.y"
                 { (yyval.factor_) = make_AAfactor((yyvsp[0].primary_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4522 "Parser.c"
    break;

  case 60: /* FACTOR: PRIMARY EXPONENTIATION FACTOR  */
#line 720 "HAL_S.y"
                                  { (yyval.factor_) = make_ABfactorExponentiation((yyvsp[-2].primary_), (yyvsp[-1].exponentiation_), (yyvsp[0].factor_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4528 "Parser.c"
    break;

  case 61: /* EXPONENTIATION: _SYMB_8  */
#line 722 "HAL_S.y"
                         { (yyval.exponentiation_) = make_AAexponentiation(); (yyval.exponentiation_)->line_number = (yyloc).first_line; (yyval.exponentiation_)->char_number = (yyloc).first_column;  }
#line 4534 "Parser.c"
    break;

  case 62: /* PRIMARY: ARITH_VAR  */
#line 724 "HAL_S.y"
                    { (yyval.primary_) = make_AAprimary((yyvsp[0].arith_var_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4540 "Parser.c"
    break;

  case 63: /* PRIMARY: PRE_PRIMARY  */
#line 725 "HAL_S.y"
                { (yyval.primary_) = make_ADprimary((yyvsp[0].pre_primary_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4546 "Parser.c"
    break;

  case 64: /* PRIMARY: MODIFIED_ARITH_FUNC  */
#line 726 "HAL_S.y"
                        { (yyval.primary_) = make_ABprimary((yyvsp[0].modified_arith_func_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4552 "Parser.c"
    break;

  case 65: /* PRIMARY: PRE_PRIMARY QUALIFIER  */
#line 727 "HAL_S.y"
                          { (yyval.primary_) = make_AEprimary((yyvsp[-1].pre_primary_), (yyvsp[0].qualifier_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4558 "Parser.c"
    break;

  case 66: /* ARITH_VAR: ARITH_ID  */
#line 729 "HAL_S.y"
                     { (yyval.arith_var_) = make_AAarith_var((yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4564 "Parser.c"
    break;

  case 67: /* ARITH_VAR: ARITH_ID SUBSCRIPT  */
#line 730 "HAL_S.y"
                       { (yyval.arith_var_) = make_ACarith_var((yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4570 "Parser.c"
    break;

  case 68: /* ARITH_VAR: _SYMB_10 ARITH_ID _SYMB_11  */
#line 731 "HAL_S.y"
                               { (yyval.arith_var_) = make_AAarithVarBracketed((yyvsp[-1].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4576 "Parser.c"
    break;

  case 69: /* ARITH_VAR: _SYMB_10 ARITH_ID _SYMB_11 SUBSCRIPT  */
#line 732 "HAL_S.y"
                                         { (yyval.arith_var_) = make_ABarithVarBracketed((yyvsp[-2].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4582 "Parser.c"
    break;

  case 70: /* ARITH_VAR: _SYMB_12 QUAL_STRUCT _SYMB_13  */
#line 733 "HAL_S.y"
                                  { (yyval.arith_var_) = make_AAarithVarBraced((yyvsp[-1].qual_struct_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4588 "Parser.c"
    break;

  case 71: /* ARITH_VAR: _SYMB_12 QUAL_STRUCT _SYMB_13 SUBSCRIPT  */
#line 734 "HAL_S.y"
                                            { (yyval.arith_var_) = make_ABarithVarBraced((yyvsp[-2].qual_struct_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4594 "Parser.c"
    break;

  case 72: /* ARITH_VAR: QUAL_STRUCT _SYMB_7 ARITH_ID  */
#line 735 "HAL_S.y"
                                 { (yyval.arith_var_) = make_ABarith_var((yyvsp[-2].qual_struct_), (yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4600 "Parser.c"
    break;

  case 73: /* ARITH_VAR: QUAL_STRUCT _SYMB_7 ARITH_ID SUBSCRIPT  */
#line 736 "HAL_S.y"
                                           { (yyval.arith_var_) = make_ADarith_var((yyvsp[-3].qual_struct_), (yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4606 "Parser.c"
    break;

  case 74: /* PRE_PRIMARY: _SYMB_2 ARITH_EXP _SYMB_1  */
#line 738 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AApre_primary((yyvsp[-1].arith_exp_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4612 "Parser.c"
    break;

  case 75: /* PRE_PRIMARY: NUMBER  */
#line 739 "HAL_S.y"
           { (yyval.pre_primary_) = make_ABpre_primary((yyvsp[0].number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4618 "Parser.c"
    break;

  case 76: /* PRE_PRIMARY: COMPOUND_NUMBER  */
#line 740 "HAL_S.y"
                    { (yyval.pre_primary_) = make_ACpre_primary((yyvsp[0].compound_number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4624 "Parser.c"
    break;

  case 77: /* PRE_PRIMARY: ARITH_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 741 "HAL_S.y"
                                              { (yyval.pre_primary_) = make_ADprePrimaryRtlFunction((yyvsp[-3].arith_func_head_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4630 "Parser.c"
    break;

  case 78: /* PRE_PRIMARY: _SYMB_188 _SYMB_2 CALL_LIST _SYMB_1  */
#line 742 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AEprePrimaryFunction((yyvsp[-3].string_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4636 "Parser.c"
    break;

  case 79: /* NUMBER: SIMPLE_NUMBER  */
#line 744 "HAL_S.y"
                       { (yyval.number_) = make_AAnumber((yyvsp[0].simple_number_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4642 "Parser.c"
    break;

  case 80: /* NUMBER: LEVEL  */
#line 745 "HAL_S.y"
          { (yyval.number_) = make_ABnumber((yyvsp[0].level_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4648 "Parser.c"
    break;

  case 81: /* LEVEL: _SYMB_194  */
#line 747 "HAL_S.y"
                  { (yyval.level_) = make_ZZlevel((yyvsp[0].string_)); (yyval.level_)->line_number = (yyloc).first_line; (yyval.level_)->char_number = (yyloc).first_column;  }
#line 4654 "Parser.c"
    break;

  case 82: /* COMPOUND_NUMBER: _SYMB_196  */
#line 749 "HAL_S.y"
                            { (yyval.compound_number_) = make_CLcompound_number((yyvsp[0].string_)); (yyval.compound_number_)->line_number = (yyloc).first_line; (yyval.compound_number_)->char_number = (yyloc).first_column;  }
#line 4660 "Parser.c"
    break;

  case 83: /* SIMPLE_NUMBER: _SYMB_195  */
#line 751 "HAL_S.y"
                          { (yyval.simple_number_) = make_CKsimple_number((yyvsp[0].string_)); (yyval.simple_number_)->line_number = (yyloc).first_line; (yyval.simple_number_)->char_number = (yyloc).first_column;  }
#line 4666 "Parser.c"
    break;

  case 84: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC  */
#line 753 "HAL_S.y"
                                        { (yyval.modified_arith_func_) = make_AAmodified_arith_func((yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4672 "Parser.c"
    break;

  case 85: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 754 "HAL_S.y"
                                { (yyval.modified_arith_func_) = make_ACmodified_arith_func((yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4678 "Parser.c"
    break;

  case 86: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_7 NO_ARG_ARITH_FUNC  */
#line 755 "HAL_S.y"
                                          { (yyval.modified_arith_func_) = make_ADmodified_arith_func((yyvsp[-2].qual_struct_), (yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4684 "Parser.c"
    break;

  case 87: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_7 NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 756 "HAL_S.y"
                                                    { (yyval.modified_arith_func_) = make_AEmodified_arith_func((yyvsp[-3].qual_struct_), (yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4690 "Parser.c"
    break;

  case 88: /* ARITH_FUNC_HEAD: ARITH_FUNC  */
#line 758 "HAL_S.y"
                             { (yyval.arith_func_head_) = make_AAarith_func_head((yyvsp[0].arith_func_)); (yyval.arith_func_head_)->line_number = (yyloc).first_line; (yyval.arith_func_head_)->char_number = (yyloc).first_column;  }
#line 4696 "Parser.c"
    break;

  case 89: /* ARITH_FUNC_HEAD: ARITH_CONV SUBSCRIPT  */
#line 759 "HAL_S.y"
                         { (yyval.arith_func_head_) = make_ABarith_func_head((yyvsp[-1].arith_conv_), (yyvsp[0].subscript_)); (yyval.arith_func_head_)->line_number = (yyloc).first_line; (yyval.arith_func_head_)->char_number = (yyloc).first_column;  }
#line 4702 "Parser.c"
    break;

  case 90: /* CALL_LIST: LIST_EXP  */
#line 761 "HAL_S.y"
                     { (yyval.call_list_) = make_AAcall_list((yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 4708 "Parser.c"
    break;

  case 91: /* CALL_LIST: CALL_LIST _SYMB_0 LIST_EXP  */
#line 762 "HAL_S.y"
                               { (yyval.call_list_) = make_ABcall_list((yyvsp[-2].call_list_), (yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 4714 "Parser.c"
    break;

  case 92: /* LIST_EXP: EXPRESSION  */
#line 764 "HAL_S.y"
                      { (yyval.list_exp_) = make_AAlist_exp((yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4720 "Parser.c"
    break;

  case 93: /* LIST_EXP: ARITH_EXP _SYMB_9 EXPRESSION  */
#line 765 "HAL_S.y"
                                 { (yyval.list_exp_) = make_ABlist_exp((yyvsp[-2].arith_exp_), (yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4726 "Parser.c"
    break;

  case 94: /* LIST_EXP: QUAL_STRUCT  */
#line 766 "HAL_S.y"
                { (yyval.list_exp_) = make_ADlist_exp((yyvsp[0].qual_struct_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4732 "Parser.c"
    break;

  case 95: /* EXPRESSION: ARITH_EXP  */
#line 768 "HAL_S.y"
                       { (yyval.expression_) = make_AAexpression((yyvsp[0].arith_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4738 "Parser.c"
    break;

  case 96: /* EXPRESSION: BIT_EXP  */
#line 769 "HAL_S.y"
            { (yyval.expression_) = make_ABexpression((yyvsp[0].bit_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4744 "Parser.c"
    break;

  case 97: /* EXPRESSION: CHAR_EXP  */
#line 770 "HAL_S.y"
             { (yyval.expression_) = make_ACexpression((yyvsp[0].char_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4750 "Parser.c"
    break;

  case 98: /* EXPRESSION: NAME_EXP  */
#line 771 "HAL_S.y"
             { (yyval.expression_) = make_AEexpression((yyvsp[0].name_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4756 "Parser.c"
    break;

  case 99: /* EXPRESSION: STRUCTURE_EXP  */
#line 772 "HAL_S.y"
                  { (yyval.expression_) = make_ADexpression((yyvsp[0].structure_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4762 "Parser.c"
    break;

  case 100: /* ARITH_ID: IDENTIFIER  */
#line 774 "HAL_S.y"
                      { (yyval.arith_id_) = make_FGarith_id((yyvsp[0].identifier_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 4768 "Parser.c"
    break;

  case 101: /* ARITH_ID: _SYMB_190  */
#line 775 "HAL_S.y"
              { (yyval.arith_id_) = make_FHarith_id((yyvsp[0].string_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 4774 "Parser.c"
    break;

  case 102: /* NO_ARG_ARITH_FUNC: _SYMB_54  */
#line 777 "HAL_S.y"
                             { (yyval.no_arg_arith_func_) = make_ZZclocktime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4780 "Parser.c"
    break;

  case 103: /* NO_ARG_ARITH_FUNC: _SYMB_61  */
#line 778 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZdate(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4786 "Parser.c"
    break;

  case 104: /* NO_ARG_ARITH_FUNC: _SYMB_73  */
#line 779 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZerrgrp(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4792 "Parser.c"
    break;

  case 105: /* NO_ARG_ARITH_FUNC: _SYMB_74  */
#line 780 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZerrnum(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4798 "Parser.c"
    break;

  case 106: /* NO_ARG_ARITH_FUNC: _SYMB_118  */
#line 781 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZprio(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4804 "Parser.c"
    break;

  case 107: /* NO_ARG_ARITH_FUNC: _SYMB_123  */
#line 782 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZrandom(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4810 "Parser.c"
    break;

  case 108: /* NO_ARG_ARITH_FUNC: _SYMB_124  */
#line 783 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZrandomg(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4816 "Parser.c"
    break;

  case 109: /* NO_ARG_ARITH_FUNC: _SYMB_137  */
#line 784 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZruntime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4822 "Parser.c"
    break;

  case 110: /* ARITH_FUNC: _SYMB_108  */
#line 786 "HAL_S.y"
                       { (yyval.arith_func_) = make_ZZnextime(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4828 "Parser.c"
    break;

  case 111: /* ARITH_FUNC: _SYMB_26  */
#line 787 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabs(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4834 "Parser.c"
    break;

  case 112: /* ARITH_FUNC: _SYMB_51  */
#line 788 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZceiling(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4840 "Parser.c"
    break;

  case 113: /* ARITH_FUNC: _SYMB_67  */
#line 789 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdiv(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4846 "Parser.c"
    break;

  case 114: /* ARITH_FUNC: _SYMB_84  */
#line 790 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZfloor(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4852 "Parser.c"
    break;

  case 115: /* ARITH_FUNC: _SYMB_104  */
#line 791 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmidval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4858 "Parser.c"
    break;

  case 116: /* ARITH_FUNC: _SYMB_106  */
#line 792 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4864 "Parser.c"
    break;

  case 117: /* ARITH_FUNC: _SYMB_113  */
#line 793 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZodd(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4870 "Parser.c"
    break;

  case 118: /* ARITH_FUNC: _SYMB_128  */
#line 794 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZremainder(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4876 "Parser.c"
    break;

  case 119: /* ARITH_FUNC: _SYMB_136  */
#line 795 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZround(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4882 "Parser.c"
    break;

  case 120: /* ARITH_FUNC: _SYMB_144  */
#line 796 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsign(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4888 "Parser.c"
    break;

  case 121: /* ARITH_FUNC: _SYMB_146  */
#line 797 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsignum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4894 "Parser.c"
    break;

  case 122: /* ARITH_FUNC: _SYMB_170  */
#line 798 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtruncate(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4900 "Parser.c"
    break;

  case 123: /* ARITH_FUNC: _SYMB_32  */
#line 799 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4906 "Parser.c"
    break;

  case 124: /* ARITH_FUNC: _SYMB_33  */
#line 800 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4912 "Parser.c"
    break;

  case 125: /* ARITH_FUNC: _SYMB_34  */
#line 801 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4918 "Parser.c"
    break;

  case 126: /* ARITH_FUNC: _SYMB_35  */
#line 802 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4924 "Parser.c"
    break;

  case 127: /* ARITH_FUNC: _SYMB_37  */
#line 803 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan2(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4930 "Parser.c"
    break;

  case 128: /* ARITH_FUNC: _SYMB_36  */
#line 804 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4936 "Parser.c"
    break;

  case 129: /* ARITH_FUNC: _SYMB_38  */
#line 805 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4942 "Parser.c"
    break;

  case 130: /* ARITH_FUNC: _SYMB_59  */
#line 806 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4948 "Parser.c"
    break;

  case 131: /* ARITH_FUNC: _SYMB_60  */
#line 807 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4954 "Parser.c"
    break;

  case 132: /* ARITH_FUNC: _SYMB_80  */
#line 808 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZexp(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4960 "Parser.c"
    break;

  case 133: /* ARITH_FUNC: _SYMB_101  */
#line 809 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZlog(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4966 "Parser.c"
    break;

  case 134: /* ARITH_FUNC: _SYMB_147  */
#line 810 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4972 "Parser.c"
    break;

  case 135: /* ARITH_FUNC: _SYMB_149  */
#line 811 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4978 "Parser.c"
    break;

  case 136: /* ARITH_FUNC: _SYMB_152  */
#line 812 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsqrt(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4984 "Parser.c"
    break;

  case 137: /* ARITH_FUNC: _SYMB_159  */
#line 813 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4990 "Parser.c"
    break;

  case 138: /* ARITH_FUNC: _SYMB_160  */
#line 814 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4996 "Parser.c"
    break;

  case 139: /* ARITH_FUNC: _SYMB_142  */
#line 815 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshl(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5002 "Parser.c"
    break;

  case 140: /* ARITH_FUNC: _SYMB_143  */
#line 816 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshr(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5008 "Parser.c"
    break;

  case 141: /* ARITH_FUNC: _SYMB_27  */
#line 817 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5014 "Parser.c"
    break;

  case 142: /* ARITH_FUNC: _SYMB_66  */
#line 818 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdet(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5020 "Parser.c"
    break;

  case 143: /* ARITH_FUNC: _SYMB_166  */
#line 819 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtrace(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5026 "Parser.c"
    break;

  case 144: /* ARITH_FUNC: _SYMB_171  */
#line 820 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZunit(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5032 "Parser.c"
    break;

  case 145: /* ARITH_FUNC: _SYMB_102  */
#line 821 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmatrix(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5038 "Parser.c"
    break;

  case 146: /* ARITH_FUNC: _SYMB_92  */
#line 822 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZindex(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5044 "Parser.c"
    break;

  case 147: /* ARITH_FUNC: _SYMB_97  */
#line 823 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZlength(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5050 "Parser.c"
    break;

  case 148: /* ARITH_FUNC: _SYMB_95  */
#line 824 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZinverse(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5056 "Parser.c"
    break;

  case 149: /* ARITH_FUNC: _SYMB_167  */
#line 825 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtranspose(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5062 "Parser.c"
    break;

  case 150: /* ARITH_FUNC: _SYMB_121  */
#line 826 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZprod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5068 "Parser.c"
    break;

  case 151: /* ARITH_FUNC: _SYMB_156  */
#line 827 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5074 "Parser.c"
    break;

  case 152: /* ARITH_FUNC: _SYMB_150  */
#line 828 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsize(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5080 "Parser.c"
    break;

  case 153: /* ARITH_FUNC: _SYMB_103  */
#line 829 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmax(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5086 "Parser.c"
    break;

  case 154: /* ARITH_FUNC: _SYMB_105  */
#line 830 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5092 "Parser.c"
    break;

  case 155: /* ARITH_FUNC: _SYMB_94  */
#line 831 "HAL_S.y"
             { (yyval.arith_func_) = make_AAarithFuncInteger(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5098 "Parser.c"
    break;

  case 156: /* ARITH_FUNC: _SYMB_138  */
#line 832 "HAL_S.y"
              { (yyval.arith_func_) = make_AAarithFuncScalar(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 5104 "Parser.c"
    break;

  case 157: /* SUBSCRIPT: SUB_HEAD _SYMB_1  */
#line 834 "HAL_S.y"
                             { (yyval.subscript_) = make_AAsubscript((yyvsp[-1].sub_head_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5110 "Parser.c"
    break;

  case 158: /* SUBSCRIPT: QUALIFIER  */
#line 835 "HAL_S.y"
              { (yyval.subscript_) = make_ABsubscript((yyvsp[0].qualifier_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5116 "Parser.c"
    break;

  case 159: /* SUBSCRIPT: _SYMB_14 NUMBER  */
#line 836 "HAL_S.y"
                    { (yyval.subscript_) = make_ACsubscript((yyvsp[0].number_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5122 "Parser.c"
    break;

  case 160: /* SUBSCRIPT: _SYMB_14 ARITH_VAR  */
#line 837 "HAL_S.y"
                       { (yyval.subscript_) = make_ADsubscript((yyvsp[0].arith_var_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 5128 "Parser.c"
    break;

  case 161: /* QUALIFIER: _SYMB_14 _SYMB_2 _SYMB_15 PREC_SPEC _SYMB_1  */
#line 839 "HAL_S.y"
                                                        { (yyval.qualifier_) = make_AAqualifier((yyvsp[-1].prec_spec_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5134 "Parser.c"
    break;

  case 162: /* QUALIFIER: _SYMB_14 _SYMB_2 SCALE_HEAD ARITH_EXP _SYMB_1  */
#line 840 "HAL_S.y"
                                                  { (yyval.qualifier_) = make_ABqualifier((yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5140 "Parser.c"
    break;

  case 163: /* QUALIFIER: _SYMB_14 _SYMB_2 _SYMB_15 PREC_SPEC _SYMB_0 SCALE_HEAD ARITH_EXP _SYMB_1  */
#line 841 "HAL_S.y"
                                                                             { (yyval.qualifier_) = make_ACqualifier((yyvsp[-4].prec_spec_), (yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5146 "Parser.c"
    break;

  case 164: /* QUALIFIER: _SYMB_14 _SYMB_2 _SYMB_15 RADIX _SYMB_1  */
#line 842 "HAL_S.y"
                                            { (yyval.qualifier_) = make_ADqualifier((yyvsp[-1].radix_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 5152 "Parser.c"
    break;

  case 165: /* SCALE_HEAD: _SYMB_15  */
#line 844 "HAL_S.y"
                      { (yyval.scale_head_) = make_AAscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 5158 "Parser.c"
    break;

  case 166: /* SCALE_HEAD: _SYMB_15 _SYMB_15  */
#line 845 "HAL_S.y"
                      { (yyval.scale_head_) = make_ABscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 5164 "Parser.c"
    break;

  case 167: /* PREC_SPEC: _SYMB_148  */
#line 847 "HAL_S.y"
                      { (yyval.prec_spec_) = make_AAprecSpecSingle(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 5170 "Parser.c"
    break;

  case 168: /* PREC_SPEC: _SYMB_69  */
#line 848 "HAL_S.y"
             { (yyval.prec_spec_) = make_ABprecSpecDouble(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 5176 "Parser.c"
    break;

  case 169: /* SUB_START: _SYMB_14 _SYMB_2  */
#line 850 "HAL_S.y"
                             { (yyval.sub_start_) = make_AAsubStartGroup(); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5182 "Parser.c"
    break;

  case 170: /* SUB_START: _SYMB_14 _SYMB_2 _SYMB_15 PREC_SPEC _SYMB_0  */
#line 851 "HAL_S.y"
                                                { (yyval.sub_start_) = make_ABsubStartPrecSpec((yyvsp[-1].prec_spec_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5188 "Parser.c"
    break;

  case 171: /* SUB_START: SUB_HEAD _SYMB_16  */
#line 852 "HAL_S.y"
                      { (yyval.sub_start_) = make_ACsubStartSemicolon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5194 "Parser.c"
    break;

  case 172: /* SUB_START: SUB_HEAD _SYMB_17  */
#line 853 "HAL_S.y"
                      { (yyval.sub_start_) = make_ADsubStartColon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5200 "Parser.c"
    break;

  case 173: /* SUB_START: SUB_HEAD _SYMB_0  */
#line 854 "HAL_S.y"
                     { (yyval.sub_start_) = make_AEsubStartComma((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 5206 "Parser.c"
    break;

  case 174: /* SUB_HEAD: SUB_START  */
#line 856 "HAL_S.y"
                     { (yyval.sub_head_) = make_AAsub_head((yyvsp[0].sub_start_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 5212 "Parser.c"
    break;

  case 175: /* SUB_HEAD: SUB_START SUB  */
#line 857 "HAL_S.y"
                  { (yyval.sub_head_) = make_ABsub_head((yyvsp[-1].sub_start_), (yyvsp[0].sub_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 5218 "Parser.c"
    break;

  case 176: /* SUB: SUB_EXP  */
#line 859 "HAL_S.y"
              { (yyval.sub_) = make_AAsub((yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5224 "Parser.c"
    break;

  case 177: /* SUB: _SYMB_6  */
#line 860 "HAL_S.y"
            { (yyval.sub_) = make_ABsubStar(); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5230 "Parser.c"
    break;

  case 178: /* SUB: SUB_RUN_HEAD SUB_EXP  */
#line 861 "HAL_S.y"
                         { (yyval.sub_) = make_ACsubExp((yyvsp[-1].sub_run_head_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5236 "Parser.c"
    break;

  case 179: /* SUB: ARITH_EXP _SYMB_41 SUB_EXP  */
#line 862 "HAL_S.y"
                               { (yyval.sub_) = make_ADsubAt((yyvsp[-2].arith_exp_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 5242 "Parser.c"
    break;

  case 180: /* SUB_RUN_HEAD: SUB_EXP _SYMB_165  */
#line 864 "HAL_S.y"
                                 { (yyval.sub_run_head_) = make_AAsubRunHeadTo((yyvsp[-1].sub_exp_)); (yyval.sub_run_head_)->line_number = (yyloc).first_line; (yyval.sub_run_head_)->char_number = (yyloc).first_column;  }
#line 5248 "Parser.c"
    break;

  case 181: /* SUB_EXP: ARITH_EXP  */
#line 866 "HAL_S.y"
                    { (yyval.sub_exp_) = make_AAsub_exp((yyvsp[0].arith_exp_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 5254 "Parser.c"
    break;

  case 182: /* SUB_EXP: POUND_EXPRESSION  */
#line 867 "HAL_S.y"
                     { (yyval.sub_exp_) = make_ABsub_exp((yyvsp[0].pound_expression_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 5260 "Parser.c"
    break;

  case 183: /* POUND_EXPRESSION: _SYMB_9  */
#line 869 "HAL_S.y"
                           { (yyval.pound_expression_) = make_AApound_expression(); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5266 "Parser.c"
    break;

  case 184: /* POUND_EXPRESSION: POUND_EXPRESSION PLUS TERM  */
#line 870 "HAL_S.y"
                               { (yyval.pound_expression_) = make_ABpound_expression((yyvsp[-2].pound_expression_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5272 "Parser.c"
    break;

  case 185: /* POUND_EXPRESSION: POUND_EXPRESSION MINUS TERM  */
#line 871 "HAL_S.y"
                                { (yyval.pound_expression_) = make_ACpound_expression((yyvsp[-2].pound_expression_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 5278 "Parser.c"
    break;

  case 186: /* BIT_EXP: BIT_FACTOR  */
#line 873 "HAL_S.y"
                     { (yyval.bit_exp_) = make_AAbitExpFactor((yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 5284 "Parser.c"
    break;

  case 187: /* BIT_EXP: BIT_EXP OR BIT_FACTOR  */
#line 874 "HAL_S.y"
                          { (yyval.bit_exp_) = make_ABbitExpOR((yyvsp[-2].bit_exp_), (yyvsp[-1].or_), (yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 5290 "Parser.c"
    break;

  case 188: /* BIT_FACTOR: BIT_CAT  */
#line 876 "HAL_S.y"
                     { (yyval.bit_factor_) = make_AAbitFactor((yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 5296 "Parser.c"
    break;

  case 189: /* BIT_FACTOR: BIT_FACTOR AND BIT_CAT  */
#line 877 "HAL_S.y"
                           { (yyval.bit_factor_) = make_ABbitFactorAnd((yyvsp[-2].bit_factor_), (yyvsp[-1].and_), (yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 5302 "Parser.c"
    break;

  case 190: /* BIT_CAT: BIT_PRIM  */
#line 879 "HAL_S.y"
                   { (yyval.bit_cat_) = make_AAbitCatPrim((yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5308 "Parser.c"
    break;

  case 191: /* BIT_CAT: BIT_CAT CAT BIT_PRIM  */
#line 880 "HAL_S.y"
                         { (yyval.bit_cat_) = make_ABbitCatCat((yyvsp[-2].bit_cat_), (yyvsp[-1].cat_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5314 "Parser.c"
    break;

  case 192: /* BIT_CAT: NOT BIT_PRIM  */
#line 881 "HAL_S.y"
                 { (yyval.bit_cat_) = make_ACbitCatNotPrim((yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5320 "Parser.c"
    break;

  case 193: /* BIT_CAT: BIT_CAT CAT NOT BIT_PRIM  */
#line 882 "HAL_S.y"
                             { (yyval.bit_cat_) = make_ADbitCatNotCat((yyvsp[-3].bit_cat_), (yyvsp[-2].cat_), (yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5326 "Parser.c"
    break;

  case 194: /* OR: CHAR_VERTICAL_BAR  */
#line 884 "HAL_S.y"
                       { (yyval.or_) = make_AAOR((yyvsp[0].char_vertical_bar_)); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5332 "Parser.c"
    break;

  case 195: /* OR: _SYMB_116  */
#line 885 "HAL_S.y"
              { (yyval.or_) = make_ABOR(); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5338 "Parser.c"
    break;

  case 196: /* CHAR_VERTICAL_BAR: _SYMB_18  */
#line 887 "HAL_S.y"
                             { (yyval.char_vertical_bar_) = make_CFchar_vertical_bar(); (yyval.char_vertical_bar_)->line_number = (yyloc).first_line; (yyval.char_vertical_bar_)->char_number = (yyloc).first_column;  }
#line 5344 "Parser.c"
    break;

  case 197: /* AND: _SYMB_19  */
#line 889 "HAL_S.y"
               { (yyval.and_) = make_AAAND(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5350 "Parser.c"
    break;

  case 198: /* AND: _SYMB_31  */
#line 890 "HAL_S.y"
             { (yyval.and_) = make_ABAND(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5356 "Parser.c"
    break;

  case 199: /* BIT_PRIM: BIT_VAR  */
#line 892 "HAL_S.y"
                   { (yyval.bit_prim_) = make_AAbitPrimBitVar((yyvsp[0].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5362 "Parser.c"
    break;

  case 200: /* BIT_PRIM: LABEL_VAR  */
#line 893 "HAL_S.y"
              { (yyval.bit_prim_) = make_ABbitPrimLabelVar((yyvsp[0].label_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5368 "Parser.c"
    break;

  case 201: /* BIT_PRIM: EVENT_VAR  */
#line 894 "HAL_S.y"
              { (yyval.bit_prim_) = make_ACbitPrimEventVar((yyvsp[0].event_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5374 "Parser.c"
    break;

  case 202: /* BIT_PRIM: BIT_CONST  */
#line 895 "HAL_S.y"
              { (yyval.bit_prim_) = make_ADbitBitConst((yyvsp[0].bit_const_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5380 "Parser.c"
    break;

  case 203: /* BIT_PRIM: _SYMB_2 BIT_EXP _SYMB_1  */
#line 896 "HAL_S.y"
                            { (yyval.bit_prim_) = make_AEbitPrimBitExp((yyvsp[-1].bit_exp_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5386 "Parser.c"
    break;

  case 204: /* BIT_PRIM: SUBBIT_HEAD EXPRESSION _SYMB_1  */
#line 897 "HAL_S.y"
                                   { (yyval.bit_prim_) = make_AHbitPrimSubbit((yyvsp[-2].subbit_head_), (yyvsp[-1].expression_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5392 "Parser.c"
    break;

  case 205: /* BIT_PRIM: BIT_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 898 "HAL_S.y"
                                            { (yyval.bit_prim_) = make_AIbitPrimFunc((yyvsp[-3].bit_func_head_), (yyvsp[-1].call_list_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5398 "Parser.c"
    break;

  case 206: /* BIT_PRIM: _SYMB_10 BIT_VAR _SYMB_11  */
#line 899 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBracketed((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5404 "Parser.c"
    break;

  case 207: /* BIT_PRIM: _SYMB_10 BIT_VAR _SYMB_11 SUBSCRIPT  */
#line 900 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBracketed((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5410 "Parser.c"
    break;

  case 208: /* BIT_PRIM: _SYMB_12 BIT_VAR _SYMB_13  */
#line 901 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBraced((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5416 "Parser.c"
    break;

  case 209: /* BIT_PRIM: _SYMB_12 BIT_VAR _SYMB_13 SUBSCRIPT  */
#line 902 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBraced((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5422 "Parser.c"
    break;

  case 210: /* CAT: _SYMB_20  */
#line 904 "HAL_S.y"
               { (yyval.cat_) = make_AAcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5428 "Parser.c"
    break;

  case 211: /* CAT: _SYMB_50  */
#line 905 "HAL_S.y"
             { (yyval.cat_) = make_ABcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5434 "Parser.c"
    break;

  case 212: /* NOT: _SYMB_110  */
#line 907 "HAL_S.y"
                { (yyval.not_) = make_ABNOT(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5440 "Parser.c"
    break;

  case 213: /* NOT: _SYMB_21  */
#line 908 "HAL_S.y"
             { (yyval.not_) = make_ADNOT(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5446 "Parser.c"
    break;

  case 214: /* BIT_VAR: BIT_ID  */
#line 910 "HAL_S.y"
                 { (yyval.bit_var_) = make_AAbit_var((yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5452 "Parser.c"
    break;

  case 215: /* BIT_VAR: BIT_ID SUBSCRIPT  */
#line 911 "HAL_S.y"
                     { (yyval.bit_var_) = make_ACbit_var((yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5458 "Parser.c"
    break;

  case 216: /* BIT_VAR: QUAL_STRUCT _SYMB_7 BIT_ID  */
#line 912 "HAL_S.y"
                               { (yyval.bit_var_) = make_ABbit_var((yyvsp[-2].qual_struct_), (yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5464 "Parser.c"
    break;

  case 217: /* BIT_VAR: QUAL_STRUCT _SYMB_7 BIT_ID SUBSCRIPT  */
#line 913 "HAL_S.y"
                                         { (yyval.bit_var_) = make_ADbit_var((yyvsp[-3].qual_struct_), (yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5470 "Parser.c"
    break;

  case 218: /* LABEL_VAR: LABEL  */
#line 915 "HAL_S.y"
                  { (yyval.label_var_) = make_AAlabel_var((yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5476 "Parser.c"
    break;

  case 219: /* LABEL_VAR: LABEL SUBSCRIPT  */
#line 916 "HAL_S.y"
                    { (yyval.label_var_) = make_ABlabel_var((yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5482 "Parser.c"
    break;

  case 220: /* LABEL_VAR: QUAL_STRUCT _SYMB_7 LABEL  */
#line 917 "HAL_S.y"
                              { (yyval.label_var_) = make_AClabel_var((yyvsp[-2].qual_struct_), (yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5488 "Parser.c"
    break;

  case 221: /* LABEL_VAR: QUAL_STRUCT _SYMB_7 LABEL SUBSCRIPT  */
#line 918 "HAL_S.y"
                                        { (yyval.label_var_) = make_ADlabel_var((yyvsp[-3].qual_struct_), (yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5494 "Parser.c"
    break;

  case 222: /* EVENT_VAR: EVENT  */
#line 920 "HAL_S.y"
                  { (yyval.event_var_) = make_AAevent_var((yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5500 "Parser.c"
    break;

  case 223: /* EVENT_VAR: EVENT SUBSCRIPT  */
#line 921 "HAL_S.y"
                    { (yyval.event_var_) = make_ACevent_var((yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5506 "Parser.c"
    break;

  case 224: /* EVENT_VAR: QUAL_STRUCT _SYMB_7 EVENT  */
#line 922 "HAL_S.y"
                              { (yyval.event_var_) = make_ABevent_var((yyvsp[-2].qual_struct_), (yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5512 "Parser.c"
    break;

  case 225: /* EVENT_VAR: QUAL_STRUCT _SYMB_7 EVENT SUBSCRIPT  */
#line 923 "HAL_S.y"
                                        { (yyval.event_var_) = make_ADevent_var((yyvsp[-3].qual_struct_), (yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5518 "Parser.c"
    break;

  case 226: /* BIT_CONST_HEAD: RADIX  */
#line 925 "HAL_S.y"
                       { (yyval.bit_const_head_) = make_AAbit_const_head((yyvsp[0].radix_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5524 "Parser.c"
    break;

  case 227: /* BIT_CONST_HEAD: RADIX _SYMB_2 NUMBER _SYMB_1  */
#line 926 "HAL_S.y"
                                 { (yyval.bit_const_head_) = make_ABbit_const_head((yyvsp[-3].radix_), (yyvsp[-1].number_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5530 "Parser.c"
    break;

  case 228: /* BIT_CONST: BIT_CONST_HEAD CHAR_STRING  */
#line 928 "HAL_S.y"
                                       { (yyval.bit_const_) = make_AAbitConstString((yyvsp[-1].bit_const_head_), (yyvsp[0].char_string_)); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5536 "Parser.c"
    break;

  case 229: /* BIT_CONST: _SYMB_169  */
#line 929 "HAL_S.y"
              { (yyval.bit_const_) = make_ABbitConstTrue(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5542 "Parser.c"
    break;

  case 230: /* BIT_CONST: _SYMB_82  */
#line 930 "HAL_S.y"
             { (yyval.bit_const_) = make_ACbitConstFalse(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5548 "Parser.c"
    break;

  case 231: /* BIT_CONST: _SYMB_115  */
#line 931 "HAL_S.y"
              { (yyval.bit_const_) = make_ADbitConstOn(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5554 "Parser.c"
    break;

  case 232: /* BIT_CONST: _SYMB_114  */
#line 932 "HAL_S.y"
              { (yyval.bit_const_) = make_AEbitConstOff(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5560 "Parser.c"
    break;

  case 233: /* RADIX: _SYMB_88  */
#line 934 "HAL_S.y"
                 { (yyval.radix_) = make_AAradixHEX(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5566 "Parser.c"
    break;

  case 234: /* RADIX: _SYMB_112  */
#line 935 "HAL_S.y"
              { (yyval.radix_) = make_ABradixOCT(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5572 "Parser.c"
    break;

  case 235: /* RADIX: _SYMB_43  */
#line 936 "HAL_S.y"
             { (yyval.radix_) = make_ACradixBIN(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5578 "Parser.c"
    break;

  case 236: /* RADIX: _SYMB_62  */
#line 937 "HAL_S.y"
             { (yyval.radix_) = make_ADradixDEC(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5584 "Parser.c"
    break;

  case 237: /* CHAR_STRING: _SYMB_192  */
#line 939 "HAL_S.y"
                        { (yyval.char_string_) = make_FPchar_string((yyvsp[0].string_)); (yyval.char_string_)->line_number = (yyloc).first_line; (yyval.char_string_)->char_number = (yyloc).first_column;  }
#line 5590 "Parser.c"
    break;

  case 238: /* SUBBIT_HEAD: SUBBIT_KEY _SYMB_2  */
#line 941 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_AAsubbit_head((yyvsp[-1].subbit_key_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5596 "Parser.c"
    break;

  case 239: /* SUBBIT_HEAD: SUBBIT_KEY SUBSCRIPT _SYMB_2  */
#line 942 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_ABsubbit_head((yyvsp[-2].subbit_key_), (yyvsp[-1].subscript_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5602 "Parser.c"
    break;

  case 240: /* SUBBIT_KEY: _SYMB_155  */
#line 944 "HAL_S.y"
                       { (yyval.subbit_key_) = make_AAsubbit_key(); (yyval.subbit_key_)->line_number = (yyloc).first_line; (yyval.subbit_key_)->char_number = (yyloc).first_column;  }
#line 5608 "Parser.c"
    break;

  case 241: /* BIT_FUNC_HEAD: BIT_FUNC  */
#line 946 "HAL_S.y"
                         { (yyval.bit_func_head_) = make_AAbit_func_head((yyvsp[0].bit_func_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5614 "Parser.c"
    break;

  case 242: /* BIT_FUNC_HEAD: _SYMB_44  */
#line 947 "HAL_S.y"
             { (yyval.bit_func_head_) = make_ABbit_func_head(); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5620 "Parser.c"
    break;

  case 243: /* BIT_FUNC_HEAD: _SYMB_44 SUB_OR_QUALIFIER  */
#line 948 "HAL_S.y"
                              { (yyval.bit_func_head_) = make_ACbit_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5626 "Parser.c"
    break;

  case 244: /* BIT_ID: _SYMB_182  */
#line 950 "HAL_S.y"
                   { (yyval.bit_id_) = make_FHbit_id((yyvsp[0].string_)); (yyval.bit_id_)->line_number = (yyloc).first_line; (yyval.bit_id_)->char_number = (yyloc).first_column;  }
#line 5632 "Parser.c"
    break;

  case 245: /* LABEL: _SYMB_188  */
#line 952 "HAL_S.y"
                  { (yyval.label_) = make_FKlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5638 "Parser.c"
    break;

  case 246: /* LABEL: _SYMB_183  */
#line 953 "HAL_S.y"
              { (yyval.label_) = make_FLlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5644 "Parser.c"
    break;

  case 247: /* LABEL: _SYMB_184  */
#line 954 "HAL_S.y"
              { (yyval.label_) = make_FMlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5650 "Parser.c"
    break;

  case 248: /* LABEL: _SYMB_187  */
#line 955 "HAL_S.y"
              { (yyval.label_) = make_FNlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5656 "Parser.c"
    break;

  case 249: /* BIT_FUNC: _SYMB_178  */
#line 957 "HAL_S.y"
                     { (yyval.bit_func_) = make_ZZxor(); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5662 "Parser.c"
    break;

  case 250: /* BIT_FUNC: _SYMB_183  */
#line 958 "HAL_S.y"
              { (yyval.bit_func_) = make_ZZuserBitFunction((yyvsp[0].string_)); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5668 "Parser.c"
    break;

  case 251: /* EVENT: _SYMB_189  */
#line 960 "HAL_S.y"
                  { (yyval.event_) = make_FLevent((yyvsp[0].string_)); (yyval.event_)->line_number = (yyloc).first_line; (yyval.event_)->char_number = (yyloc).first_column;  }
#line 5674 "Parser.c"
    break;

  case 252: /* SUB_OR_QUALIFIER: SUBSCRIPT  */
#line 962 "HAL_S.y"
                             { (yyval.sub_or_qualifier_) = make_AAsub_or_qualifier((yyvsp[0].subscript_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 5680 "Parser.c"
    break;

  case 253: /* SUB_OR_QUALIFIER: BIT_QUALIFIER  */
#line 963 "HAL_S.y"
                  { (yyval.sub_or_qualifier_) = make_ABsub_or_qualifier((yyvsp[0].bit_qualifier_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 5686 "Parser.c"
    break;

  case 254: /* BIT_QUALIFIER: _SYMB_22 _SYMB_14 _SYMB_2 _SYMB_15 RADIX _SYMB_1  */
#line 965 "HAL_S.y"
                                                                 { (yyval.bit_qualifier_) = make_AAbit_qualifier((yyvsp[-1].radix_)); (yyval.bit_qualifier_)->line_number = (yyloc).first_line; (yyval.bit_qualifier_)->char_number = (yyloc).first_column;  }
#line 5692 "Parser.c"
    break;

  case 255: /* CHAR_EXP: CHAR_PRIM  */
#line 967 "HAL_S.y"
                     { (yyval.char_exp_) = make_AAcharExpPrim((yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5698 "Parser.c"
    break;

  case 256: /* CHAR_EXP: CHAR_EXP CAT CHAR_PRIM  */
#line 968 "HAL_S.y"
                           { (yyval.char_exp_) = make_ABcharExpCat((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5704 "Parser.c"
    break;

  case 257: /* CHAR_EXP: CHAR_EXP CAT ARITH_EXP  */
#line 969 "HAL_S.y"
                           { (yyval.char_exp_) = make_ACcharExpCat((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5710 "Parser.c"
    break;

  case 258: /* CHAR_EXP: ARITH_EXP CAT ARITH_EXP  */
#line 970 "HAL_S.y"
                            { (yyval.char_exp_) = make_ADcharExpCat((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5716 "Parser.c"
    break;

  case 259: /* CHAR_EXP: ARITH_EXP CAT CHAR_PRIM  */
#line 971 "HAL_S.y"
                            { (yyval.char_exp_) = make_AEcharExpCat((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5722 "Parser.c"
    break;

  case 260: /* CHAR_PRIM: CHAR_VAR  */
#line 973 "HAL_S.y"
                     { (yyval.char_prim_) = make_AAchar_prim((yyvsp[0].char_var_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5728 "Parser.c"
    break;

  case 261: /* CHAR_PRIM: CHAR_CONST  */
#line 974 "HAL_S.y"
               { (yyval.char_prim_) = make_ABchar_prim((yyvsp[0].char_const_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5734 "Parser.c"
    break;

  case 262: /* CHAR_PRIM: CHAR_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 975 "HAL_S.y"
                                             { (yyval.char_prim_) = make_AEchar_prim((yyvsp[-3].char_func_head_), (yyvsp[-1].call_list_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5740 "Parser.c"
    break;

  case 263: /* CHAR_PRIM: _SYMB_2 CHAR_EXP _SYMB_1  */
#line 976 "HAL_S.y"
                             { (yyval.char_prim_) = make_AFchar_prim((yyvsp[-1].char_exp_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5746 "Parser.c"
    break;

  case 264: /* CHAR_FUNC_HEAD: CHAR_FUNC  */
#line 978 "HAL_S.y"
                           { (yyval.char_func_head_) = make_AAchar_func_head((yyvsp[0].char_func_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 5752 "Parser.c"
    break;

  case 265: /* CHAR_FUNC_HEAD: _SYMB_53 SUB_OR_QUALIFIER  */
#line 979 "HAL_S.y"
                              { (yyval.char_func_head_) = make_ABchar_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 5758 "Parser.c"
    break;

  case 266: /* CHAR_VAR: CHAR_ID  */
#line 981 "HAL_S.y"
                   { (yyval.char_var_) = make_AAchar_var((yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5764 "Parser.c"
    break;

  case 267: /* CHAR_VAR: CHAR_ID SUBSCRIPT  */
#line 982 "HAL_S.y"
                      { (yyval.char_var_) = make_ACchar_var((yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5770 "Parser.c"
    break;

  case 268: /* CHAR_VAR: QUAL_STRUCT _SYMB_7 CHAR_ID  */
#line 983 "HAL_S.y"
                                { (yyval.char_var_) = make_ABchar_var((yyvsp[-2].qual_struct_), (yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5776 "Parser.c"
    break;

  case 269: /* CHAR_VAR: QUAL_STRUCT _SYMB_7 CHAR_ID SUBSCRIPT  */
#line 984 "HAL_S.y"
                                          { (yyval.char_var_) = make_ADchar_var((yyvsp[-3].qual_struct_), (yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5782 "Parser.c"
    break;

  case 270: /* CHAR_CONST: CHAR_STRING  */
#line 986 "HAL_S.y"
                         { (yyval.char_const_) = make_AAchar_const((yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 5788 "Parser.c"
    break;

  case 271: /* CHAR_CONST: _SYMB_52 _SYMB_2 NUMBER _SYMB_1 CHAR_STRING  */
#line 987 "HAL_S.y"
                                                { (yyval.char_const_) = make_ABchar_const((yyvsp[-2].number_), (yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 5794 "Parser.c"
    break;

  case 272: /* CHAR_FUNC: _SYMB_99  */
#line 989 "HAL_S.y"
                     { (yyval.char_func_) = make_ZZljust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5800 "Parser.c"
    break;

  case 273: /* CHAR_FUNC: _SYMB_135  */
#line 990 "HAL_S.y"
              { (yyval.char_func_) = make_ZZrjust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5806 "Parser.c"
    break;

  case 274: /* CHAR_FUNC: _SYMB_168  */
#line 991 "HAL_S.y"
              { (yyval.char_func_) = make_ZZtrim(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5812 "Parser.c"
    break;

  case 275: /* CHAR_FUNC: _SYMB_184  */
#line 992 "HAL_S.y"
              { (yyval.char_func_) = make_ZZuserCharFunction((yyvsp[0].string_)); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5818 "Parser.c"
    break;

  case 276: /* CHAR_FUNC: _SYMB_53  */
#line 993 "HAL_S.y"
             { (yyval.char_func_) = make_AAcharFuncCharacter(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5824 "Parser.c"
    break;

  case 277: /* CHAR_ID: _SYMB_185  */
#line 995 "HAL_S.y"
                    { (yyval.char_id_) = make_FIchar_id((yyvsp[0].string_)); (yyval.char_id_)->line_number = (yyloc).first_line; (yyval.char_id_)->char_number = (yyloc).first_column;  }
#line 5830 "Parser.c"
    break;

  case 278: /* NAME_EXP: NAME_KEY _SYMB_2 NAME_VAR _SYMB_1  */
#line 997 "HAL_S.y"
                                             { (yyval.name_exp_) = make_AAnameExpKeyVar((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5836 "Parser.c"
    break;

  case 279: /* NAME_EXP: _SYMB_111  */
#line 998 "HAL_S.y"
              { (yyval.name_exp_) = make_ABnameExpNull(); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5842 "Parser.c"
    break;

  case 280: /* NAME_EXP: NAME_KEY _SYMB_2 _SYMB_111 _SYMB_1  */
#line 999 "HAL_S.y"
                                       { (yyval.name_exp_) = make_ACnameExpKeyNull((yyvsp[-3].name_key_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5848 "Parser.c"
    break;

  case 281: /* NAME_KEY: _SYMB_107  */
#line 1001 "HAL_S.y"
                     { (yyval.name_key_) = make_AAname_key(); (yyval.name_key_)->line_number = (yyloc).first_line; (yyval.name_key_)->char_number = (yyloc).first_column;  }
#line 5854 "Parser.c"
    break;

  case 282: /* NAME_VAR: VARIABLE  */
#line 1003 "HAL_S.y"
                    { (yyval.name_var_) = make_AAname_var((yyvsp[0].variable_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5860 "Parser.c"
    break;

  case 283: /* NAME_VAR: MODIFIED_ARITH_FUNC  */
#line 1004 "HAL_S.y"
                        { (yyval.name_var_) = make_ACname_var((yyvsp[0].modified_arith_func_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5866 "Parser.c"
    break;

  case 284: /* NAME_VAR: LABEL_VAR  */
#line 1005 "HAL_S.y"
              { (yyval.name_var_) = make_ABname_var((yyvsp[0].label_var_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5872 "Parser.c"
    break;

  case 285: /* VARIABLE: ARITH_VAR  */
#line 1007 "HAL_S.y"
                     { (yyval.variable_) = make_AAvariable((yyvsp[0].arith_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5878 "Parser.c"
    break;

  case 286: /* VARIABLE: BIT_VAR  */
#line 1008 "HAL_S.y"
            { (yyval.variable_) = make_ACvariable((yyvsp[0].bit_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5884 "Parser.c"
    break;

  case 287: /* VARIABLE: SUBBIT_HEAD VARIABLE _SYMB_1  */
#line 1009 "HAL_S.y"
                                 { (yyval.variable_) = make_AEvariable((yyvsp[-2].subbit_head_), (yyvsp[-1].variable_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5890 "Parser.c"
    break;

  case 288: /* VARIABLE: CHAR_VAR  */
#line 1010 "HAL_S.y"
             { (yyval.variable_) = make_AFvariable((yyvsp[0].char_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5896 "Parser.c"
    break;

  case 289: /* VARIABLE: NAME_KEY _SYMB_2 NAME_VAR _SYMB_1  */
#line 1011 "HAL_S.y"
                                      { (yyval.variable_) = make_AGvariable((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5902 "Parser.c"
    break;

  case 290: /* VARIABLE: EVENT_VAR  */
#line 1012 "HAL_S.y"
              { (yyval.variable_) = make_ADvariable((yyvsp[0].event_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5908 "Parser.c"
    break;

  case 291: /* VARIABLE: STRUCTURE_VAR  */
#line 1013 "HAL_S.y"
                  { (yyval.variable_) = make_ABvariable((yyvsp[0].structure_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5914 "Parser.c"
    break;

  case 292: /* STRUCTURE_EXP: STRUCTURE_VAR  */
#line 1015 "HAL_S.y"
                              { (yyval.structure_exp_) = make_AAstructure_exp((yyvsp[0].structure_var_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5920 "Parser.c"
    break;

  case 293: /* STRUCTURE_EXP: STRUCT_FUNC_HEAD _SYMB_2 CALL_LIST _SYMB_1  */
#line 1016 "HAL_S.y"
                                               { (yyval.structure_exp_) = make_ADstructure_exp((yyvsp[-3].struct_func_head_), (yyvsp[-1].call_list_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5926 "Parser.c"
    break;

  case 294: /* STRUCTURE_EXP: STRUC_INLINE_DEF CLOSING _SYMB_16  */
#line 1017 "HAL_S.y"
                                      { (yyval.structure_exp_) = make_ACstructure_exp((yyvsp[-2].struc_inline_def_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5932 "Parser.c"
    break;

  case 295: /* STRUCTURE_EXP: STRUC_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1018 "HAL_S.y"
                                                 { (yyval.structure_exp_) = make_AEstructure_exp((yyvsp[-3].struc_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5938 "Parser.c"
    break;

  case 296: /* STRUCT_FUNC_HEAD: STRUCT_FUNC  */
#line 1020 "HAL_S.y"
                               { (yyval.struct_func_head_) = make_AAstruct_func_head((yyvsp[0].struct_func_)); (yyval.struct_func_head_)->line_number = (yyloc).first_line; (yyval.struct_func_head_)->char_number = (yyloc).first_column;  }
#line 5944 "Parser.c"
    break;

  case 297: /* STRUCTURE_VAR: QUAL_STRUCT SUBSCRIPT  */
#line 1022 "HAL_S.y"
                                      { (yyval.structure_var_) = make_AAstructure_var((yyvsp[-1].qual_struct_), (yyvsp[0].subscript_)); (yyval.structure_var_)->line_number = (yyloc).first_line; (yyval.structure_var_)->char_number = (yyloc).first_column;  }
#line 5950 "Parser.c"
    break;

  case 298: /* STRUCT_FUNC: _SYMB_187  */
#line 1024 "HAL_S.y"
                        { (yyval.struct_func_) = make_ZZuserStructFunc((yyvsp[0].string_)); (yyval.struct_func_)->line_number = (yyloc).first_line; (yyval.struct_func_)->char_number = (yyloc).first_column;  }
#line 5956 "Parser.c"
    break;

  case 299: /* QUAL_STRUCT: STRUCTURE_ID  */
#line 1026 "HAL_S.y"
                           { (yyval.qual_struct_) = make_AAqual_struct((yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 5962 "Parser.c"
    break;

  case 300: /* QUAL_STRUCT: QUAL_STRUCT _SYMB_7 STRUCTURE_ID  */
#line 1027 "HAL_S.y"
                                     { (yyval.qual_struct_) = make_ABqual_struct((yyvsp[-2].qual_struct_), (yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 5968 "Parser.c"
    break;

  case 301: /* STRUCTURE_ID: _SYMB_186  */
#line 1029 "HAL_S.y"
                         { (yyval.structure_id_) = make_FJstructure_id((yyvsp[0].string_)); (yyval.structure_id_)->line_number = (yyloc).first_line; (yyval.structure_id_)->char_number = (yyloc).first_column;  }
#line 5974 "Parser.c"
    break;

  case 302: /* ASSIGNMENT: VARIABLE EQUALS EXPRESSION  */
#line 1031 "HAL_S.y"
                                        { (yyval.assignment_) = make_AAassignment((yyvsp[-2].variable_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5980 "Parser.c"
    break;

  case 303: /* ASSIGNMENT: VARIABLE _SYMB_0 ASSIGNMENT  */
#line 1032 "HAL_S.y"
                                { (yyval.assignment_) = make_ABassignment((yyvsp[-2].variable_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5986 "Parser.c"
    break;

  case 304: /* ASSIGNMENT: QUAL_STRUCT EQUALS EXPRESSION  */
#line 1033 "HAL_S.y"
                                  { (yyval.assignment_) = make_ACassignment((yyvsp[-2].qual_struct_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5992 "Parser.c"
    break;

  case 305: /* ASSIGNMENT: QUAL_STRUCT _SYMB_0 ASSIGNMENT  */
#line 1034 "HAL_S.y"
                                   { (yyval.assignment_) = make_ADassignment((yyvsp[-2].qual_struct_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5998 "Parser.c"
    break;

  case 306: /* EQUALS: _SYMB_23  */
#line 1036 "HAL_S.y"
                  { (yyval.equals_) = make_AAequals(); (yyval.equals_)->line_number = (yyloc).first_line; (yyval.equals_)->char_number = (yyloc).first_column;  }
#line 6004 "Parser.c"
    break;

  case 307: /* IF_STATEMENT: IF_CLAUSE STATEMENT  */
#line 1038 "HAL_S.y"
                                   { (yyval.if_statement_) = make_AAifStatement((yyvsp[-1].if_clause_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 6010 "Parser.c"
    break;

  case 308: /* IF_STATEMENT: TRUE_PART STATEMENT  */
#line 1039 "HAL_S.y"
                        { (yyval.if_statement_) = make_ABifThenElseStatement((yyvsp[-1].true_part_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 6016 "Parser.c"
    break;

  case 309: /* IF_CLAUSE: IF RELATIONAL_EXP THEN  */
#line 1041 "HAL_S.y"
                                   { (yyval.if_clause_) = make_AAifClauseRelationalExp((yyvsp[-2].if_), (yyvsp[-1].relational_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 6022 "Parser.c"
    break;

  case 310: /* IF_CLAUSE: IF BIT_EXP THEN  */
#line 1042 "HAL_S.y"
                    { (yyval.if_clause_) = make_ABifClauseBitExp((yyvsp[-2].if_), (yyvsp[-1].bit_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 6028 "Parser.c"
    break;

  case 311: /* TRUE_PART: IF_CLAUSE BASIC_STATEMENT _SYMB_70  */
#line 1044 "HAL_S.y"
                                               { (yyval.true_part_) = make_AAtrue_part((yyvsp[-2].if_clause_), (yyvsp[-1].basic_statement_)); (yyval.true_part_)->line_number = (yyloc).first_line; (yyval.true_part_)->char_number = (yyloc).first_column;  }
#line 6034 "Parser.c"
    break;

  case 312: /* IF: _SYMB_89  */
#line 1046 "HAL_S.y"
              { (yyval.if_) = make_AAif(); (yyval.if_)->line_number = (yyloc).first_line; (yyval.if_)->char_number = (yyloc).first_column;  }
#line 6040 "Parser.c"
    break;

  case 313: /* THEN: _SYMB_164  */
#line 1048 "HAL_S.y"
                 { (yyval.then_) = make_AAthen(); (yyval.then_)->line_number = (yyloc).first_line; (yyval.then_)->char_number = (yyloc).first_column;  }
#line 6046 "Parser.c"
    break;

  case 314: /* RELATIONAL_EXP: RELATIONAL_FACTOR  */
#line 1050 "HAL_S.y"
                                   { (yyval.relational_exp_) = make_AArelational_exp((yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 6052 "Parser.c"
    break;

  case 315: /* RELATIONAL_EXP: RELATIONAL_EXP OR RELATIONAL_FACTOR  */
#line 1051 "HAL_S.y"
                                        { (yyval.relational_exp_) = make_ABrelational_exp((yyvsp[-2].relational_exp_), (yyvsp[-1].or_), (yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 6058 "Parser.c"
    break;

  case 316: /* RELATIONAL_FACTOR: REL_PRIM  */
#line 1053 "HAL_S.y"
                             { (yyval.relational_factor_) = make_AArelational_factor((yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 6064 "Parser.c"
    break;

  case 317: /* RELATIONAL_FACTOR: RELATIONAL_FACTOR AND REL_PRIM  */
#line 1054 "HAL_S.y"
                                   { (yyval.relational_factor_) = make_ABrelational_factor((yyvsp[-2].relational_factor_), (yyvsp[-1].and_), (yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 6070 "Parser.c"
    break;

  case 318: /* REL_PRIM: _SYMB_2 RELATIONAL_EXP _SYMB_1  */
#line 1056 "HAL_S.y"
                                          { (yyval.rel_prim_) = make_AArel_prim((yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6076 "Parser.c"
    break;

  case 319: /* REL_PRIM: NOT _SYMB_2 RELATIONAL_EXP _SYMB_1  */
#line 1057 "HAL_S.y"
                                       { (yyval.rel_prim_) = make_ABrel_prim((yyvsp[-3].not_), (yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6082 "Parser.c"
    break;

  case 320: /* REL_PRIM: COMPARISON  */
#line 1058 "HAL_S.y"
               { (yyval.rel_prim_) = make_ACrel_prim((yyvsp[0].comparison_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 6088 "Parser.c"
    break;

  case 321: /* COMPARISON: ARITH_EXP RELATIONAL_OP ARITH_EXP  */
#line 1060 "HAL_S.y"
                                               { (yyval.comparison_) = make_AAcomparison((yyvsp[-2].arith_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6094 "Parser.c"
    break;

  case 322: /* COMPARISON: CHAR_EXP RELATIONAL_OP CHAR_EXP  */
#line 1061 "HAL_S.y"
                                    { (yyval.comparison_) = make_ABcomparison((yyvsp[-2].char_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6100 "Parser.c"
    break;

  case 323: /* COMPARISON: BIT_CAT RELATIONAL_OP BIT_CAT  */
#line 1062 "HAL_S.y"
                                  { (yyval.comparison_) = make_ACcomparison((yyvsp[-2].bit_cat_), (yyvsp[-1].relational_op_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6106 "Parser.c"
    break;

  case 324: /* COMPARISON: STRUCTURE_EXP RELATIONAL_OP STRUCTURE_EXP  */
#line 1063 "HAL_S.y"
                                              { (yyval.comparison_) = make_ADcomparison((yyvsp[-2].structure_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6112 "Parser.c"
    break;

  case 325: /* COMPARISON: NAME_EXP RELATIONAL_OP NAME_EXP  */
#line 1064 "HAL_S.y"
                                    { (yyval.comparison_) = make_AEcomparison((yyvsp[-2].name_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 6118 "Parser.c"
    break;

  case 326: /* RELATIONAL_OP: EQUALS  */
#line 1066 "HAL_S.y"
                       { (yyval.relational_op_) = make_AArelationalOpEQ((yyvsp[0].equals_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6124 "Parser.c"
    break;

  case 327: /* RELATIONAL_OP: _SYMB_179  */
#line 1067 "HAL_S.y"
              { (yyval.relational_op_) = make_ABrelationalOpNEQ((yyvsp[0].string_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6130 "Parser.c"
    break;

  case 328: /* RELATIONAL_OP: _SYMB_22  */
#line 1068 "HAL_S.y"
             { (yyval.relational_op_) = make_ACrelationalOpLT(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6136 "Parser.c"
    break;

  case 329: /* RELATIONAL_OP: _SYMB_24  */
#line 1069 "HAL_S.y"
             { (yyval.relational_op_) = make_ADrelationalOpGT(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6142 "Parser.c"
    break;

  case 330: /* RELATIONAL_OP: _SYMB_180  */
#line 1070 "HAL_S.y"
              { (yyval.relational_op_) = make_AErelationalOpLE((yyvsp[0].string_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6148 "Parser.c"
    break;

  case 331: /* RELATIONAL_OP: _SYMB_181  */
#line 1071 "HAL_S.y"
              { (yyval.relational_op_) = make_AFrelationalOpGE((yyvsp[0].string_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 6154 "Parser.c"
    break;

  case 332: /* STATEMENT: BASIC_STATEMENT  */
#line 1073 "HAL_S.y"
                            { (yyval.statement_) = make_AAstatement((yyvsp[0].basic_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6160 "Parser.c"
    break;

  case 333: /* STATEMENT: OTHER_STATEMENT  */
#line 1074 "HAL_S.y"
                    { (yyval.statement_) = make_ABstatement((yyvsp[0].other_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6166 "Parser.c"
    break;

  case 334: /* STATEMENT: INLINE_DEFINITION  */
#line 1075 "HAL_S.y"
                      { (yyval.statement_) = make_AZstatement((yyvsp[0].inline_definition_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 6172 "Parser.c"
    break;

  case 335: /* BASIC_STATEMENT: ASSIGNMENT _SYMB_16  */
#line 1077 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_ABbasicStatementAssignment((yyvsp[-1].assignment_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6178 "Parser.c"
    break;

  case 336: /* BASIC_STATEMENT: LABEL_DEFINITION BASIC_STATEMENT  */
#line 1078 "HAL_S.y"
                                     { (yyval.basic_statement_) = make_AAbasic_statement((yyvsp[-1].label_definition_), (yyvsp[0].basic_statement_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6184 "Parser.c"
    break;

  case 337: /* BASIC_STATEMENT: _SYMB_79 _SYMB_16  */
#line 1079 "HAL_S.y"
                      { (yyval.basic_statement_) = make_ACbasicStatementExit(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6190 "Parser.c"
    break;

  case 338: /* BASIC_STATEMENT: _SYMB_79 LABEL _SYMB_16  */
#line 1080 "HAL_S.y"
                            { (yyval.basic_statement_) = make_ADbasicStatementExit((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6196 "Parser.c"
    break;

  case 339: /* BASIC_STATEMENT: _SYMB_130 _SYMB_16  */
#line 1081 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AEbasicStatementRepeat(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6202 "Parser.c"
    break;

  case 340: /* BASIC_STATEMENT: _SYMB_130 LABEL _SYMB_16  */
#line 1082 "HAL_S.y"
                             { (yyval.basic_statement_) = make_AFbasicStatementRepeat((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6208 "Parser.c"
    break;

  case 341: /* BASIC_STATEMENT: _SYMB_87 _SYMB_165 LABEL _SYMB_16  */
#line 1083 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AGbasicStatementGoTo((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6214 "Parser.c"
    break;

  case 342: /* BASIC_STATEMENT: _SYMB_16  */
#line 1084 "HAL_S.y"
             { (yyval.basic_statement_) = make_AHbasicStatementEmpty(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6220 "Parser.c"
    break;

  case 343: /* BASIC_STATEMENT: CALL_KEY _SYMB_16  */
#line 1085 "HAL_S.y"
                      { (yyval.basic_statement_) = make_AIbasicStatementCall((yyvsp[-1].call_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6226 "Parser.c"
    break;

  case 344: /* BASIC_STATEMENT: CALL_KEY _SYMB_2 CALL_LIST _SYMB_1 _SYMB_16  */
#line 1086 "HAL_S.y"
                                                { (yyval.basic_statement_) = make_AJbasicStatementCall((yyvsp[-4].call_key_), (yyvsp[-2].call_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6232 "Parser.c"
    break;

  case 345: /* BASIC_STATEMENT: CALL_KEY ASSIGN _SYMB_2 CALL_ASSIGN_LIST _SYMB_1 _SYMB_16  */
#line 1087 "HAL_S.y"
                                                              { (yyval.basic_statement_) = make_AKbasicStatementCall((yyvsp[-5].call_key_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6238 "Parser.c"
    break;

  case 346: /* BASIC_STATEMENT: CALL_KEY _SYMB_2 CALL_LIST _SYMB_1 ASSIGN _SYMB_2 CALL_ASSIGN_LIST _SYMB_1 _SYMB_16  */
#line 1088 "HAL_S.y"
                                                                                        { (yyval.basic_statement_) = make_ALbasicStatementCall((yyvsp[-8].call_key_), (yyvsp[-6].call_list_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6244 "Parser.c"
    break;

  case 347: /* BASIC_STATEMENT: _SYMB_133 _SYMB_16  */
#line 1089 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AMbasicStatementReturn(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6250 "Parser.c"
    break;

  case 348: /* BASIC_STATEMENT: _SYMB_133 EXPRESSION _SYMB_16  */
#line 1090 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_ANbasicStatementReturn((yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6256 "Parser.c"
    break;

  case 349: /* BASIC_STATEMENT: DO_GROUP_HEAD ENDING _SYMB_16  */
#line 1091 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_AObasicStatementDo((yyvsp[-2].do_group_head_), (yyvsp[-1].ending_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6262 "Parser.c"
    break;

  case 350: /* BASIC_STATEMENT: READ_KEY _SYMB_16  */
#line 1092 "HAL_S.y"
                      { (yyval.basic_statement_) = make_APbasicStatementReadKey((yyvsp[-1].read_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6268 "Parser.c"
    break;

  case 351: /* BASIC_STATEMENT: READ_PHRASE _SYMB_16  */
#line 1093 "HAL_S.y"
                         { (yyval.basic_statement_) = make_AQbasicStatementReadPhrase((yyvsp[-1].read_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6274 "Parser.c"
    break;

  case 352: /* BASIC_STATEMENT: WRITE_KEY _SYMB_16  */
#line 1094 "HAL_S.y"
                       { (yyval.basic_statement_) = make_ARbasicStatementWriteKey((yyvsp[-1].write_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6280 "Parser.c"
    break;

  case 353: /* BASIC_STATEMENT: WRITE_PHRASE _SYMB_16  */
#line 1095 "HAL_S.y"
                          { (yyval.basic_statement_) = make_ASbasicStatementWritePhrase((yyvsp[-1].write_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6286 "Parser.c"
    break;

  case 354: /* BASIC_STATEMENT: FILE_EXP EQUALS EXPRESSION _SYMB_16  */
#line 1096 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_ATbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6292 "Parser.c"
    break;

  case 355: /* BASIC_STATEMENT: VARIABLE EQUALS FILE_EXP _SYMB_16  */
#line 1097 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AUbasicStatementFileExp((yyvsp[-3].variable_), (yyvsp[-2].equals_), (yyvsp[-1].file_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6298 "Parser.c"
    break;

  case 356: /* BASIC_STATEMENT: FILE_EXP EQUALS QUAL_STRUCT _SYMB_16  */
#line 1098 "HAL_S.y"
                                         { (yyval.basic_statement_) = make_AVbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].qual_struct_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6304 "Parser.c"
    break;

  case 357: /* BASIC_STATEMENT: WAIT_KEY _SYMB_85 _SYMB_65 _SYMB_16  */
#line 1099 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_AVbasicStatementWait((yyvsp[-3].wait_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6310 "Parser.c"
    break;

  case 358: /* BASIC_STATEMENT: WAIT_KEY ARITH_EXP _SYMB_16  */
#line 1100 "HAL_S.y"
                                { (yyval.basic_statement_) = make_AWbasicStatementWait((yyvsp[-2].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6316 "Parser.c"
    break;

  case 359: /* BASIC_STATEMENT: WAIT_KEY _SYMB_172 ARITH_EXP _SYMB_16  */
#line 1101 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_AXbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6322 "Parser.c"
    break;

  case 360: /* BASIC_STATEMENT: WAIT_KEY _SYMB_85 BIT_EXP _SYMB_16  */
#line 1102 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_AYbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].bit_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6328 "Parser.c"
    break;

  case 361: /* BASIC_STATEMENT: TERMINATOR _SYMB_16  */
#line 1103 "HAL_S.y"
                        { (yyval.basic_statement_) = make_AZbasicStatementTerminator((yyvsp[-1].terminator_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6334 "Parser.c"
    break;

  case 362: /* BASIC_STATEMENT: TERMINATOR TERMINATE_LIST _SYMB_16  */
#line 1104 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_BAbasicStatementTerminator((yyvsp[-2].terminator_), (yyvsp[-1].terminate_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6340 "Parser.c"
    break;

  case 363: /* BASIC_STATEMENT: _SYMB_173 _SYMB_119 _SYMB_165 ARITH_EXP _SYMB_16  */
#line 1105 "HAL_S.y"
                                                     { (yyval.basic_statement_) = make_BBbasicStatementUpdate((yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6346 "Parser.c"
    break;

  case 364: /* BASIC_STATEMENT: _SYMB_173 _SYMB_119 LABEL_VAR _SYMB_165 ARITH_EXP _SYMB_16  */
#line 1106 "HAL_S.y"
                                                               { (yyval.basic_statement_) = make_BCbasicStatementUpdate((yyvsp[-3].label_var_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6352 "Parser.c"
    break;

  case 365: /* BASIC_STATEMENT: SCHEDULE_PHRASE _SYMB_16  */
#line 1107 "HAL_S.y"
                             { (yyval.basic_statement_) = make_BDbasicStatementSchedule((yyvsp[-1].schedule_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6358 "Parser.c"
    break;

  case 366: /* BASIC_STATEMENT: SCHEDULE_PHRASE SCHEDULE_CONTROL _SYMB_16  */
#line 1108 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BEbasicStatementSchedule((yyvsp[-2].schedule_phrase_), (yyvsp[-1].schedule_control_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6364 "Parser.c"
    break;

  case 367: /* BASIC_STATEMENT: SIGNAL_CLAUSE _SYMB_16  */
#line 1109 "HAL_S.y"
                           { (yyval.basic_statement_) = make_BFbasicStatementSignal((yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6370 "Parser.c"
    break;

  case 368: /* BASIC_STATEMENT: _SYMB_140 _SYMB_75 SUBSCRIPT _SYMB_16  */
#line 1110 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BGbasicStatementSend((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6376 "Parser.c"
    break;

  case 369: /* BASIC_STATEMENT: _SYMB_140 _SYMB_75 _SYMB_16  */
#line 1111 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BHbasicStatementSend(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6382 "Parser.c"
    break;

  case 370: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_16  */
#line 1112 "HAL_S.y"
                       { (yyval.basic_statement_) = make_BHbasicStatementOn((yyvsp[-1].on_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6388 "Parser.c"
    break;

  case 371: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_31 SIGNAL_CLAUSE _SYMB_16  */
#line 1113 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BIbasicStatementOnAndSignal((yyvsp[-3].on_clause_), (yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6394 "Parser.c"
    break;

  case 372: /* BASIC_STATEMENT: _SYMB_114 _SYMB_75 SUBSCRIPT _SYMB_16  */
#line 1114 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BJbasicStatementOff((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6400 "Parser.c"
    break;

  case 373: /* BASIC_STATEMENT: _SYMB_114 _SYMB_75 _SYMB_16  */
#line 1115 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementOff(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6406 "Parser.c"
    break;

  case 374: /* BASIC_STATEMENT: PERCENT_MACRO_NAME _SYMB_16  */
#line 1116 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementPercentMacro((yyvsp[-1].percent_macro_name_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6412 "Parser.c"
    break;

  case 375: /* BASIC_STATEMENT: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_1 _SYMB_16  */
#line 1117 "HAL_S.y"
                                                          { (yyval.basic_statement_) = make_BLbasicStatementPercentMacro((yyvsp[-3].percent_macro_head_), (yyvsp[-2].percent_macro_arg_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6418 "Parser.c"
    break;

  case 376: /* OTHER_STATEMENT: IF_STATEMENT  */
#line 1119 "HAL_S.y"
                               { (yyval.other_statement_) = make_ABotherStatementIf((yyvsp[0].if_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6424 "Parser.c"
    break;

  case 377: /* OTHER_STATEMENT: ON_PHRASE STATEMENT  */
#line 1120 "HAL_S.y"
                        { (yyval.other_statement_) = make_AAotherStatementOn((yyvsp[-1].on_phrase_), (yyvsp[0].statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6430 "Parser.c"
    break;

  case 378: /* OTHER_STATEMENT: LABEL_DEFINITION OTHER_STATEMENT  */
#line 1121 "HAL_S.y"
                                     { (yyval.other_statement_) = make_ACother_statement((yyvsp[-1].label_definition_), (yyvsp[0].other_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6436 "Parser.c"
    break;

  case 379: /* ANY_STATEMENT: STATEMENT  */
#line 1123 "HAL_S.y"
                          { (yyval.any_statement_) = make_AAany_statement((yyvsp[0].statement_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6442 "Parser.c"
    break;

  case 380: /* ANY_STATEMENT: BLOCK_DEFINITION  */
#line 1124 "HAL_S.y"
                     { (yyval.any_statement_) = make_ABany_statement((yyvsp[0].block_definition_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6448 "Parser.c"
    break;

  case 381: /* ON_PHRASE: _SYMB_115 _SYMB_75 SUBSCRIPT  */
#line 1126 "HAL_S.y"
                                         { (yyval.on_phrase_) = make_AAon_phrase((yyvsp[0].subscript_)); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6454 "Parser.c"
    break;

  case 382: /* ON_PHRASE: _SYMB_115 _SYMB_75  */
#line 1127 "HAL_S.y"
                       { (yyval.on_phrase_) = make_ACon_phrase(); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6460 "Parser.c"
    break;

  case 383: /* ON_CLAUSE: _SYMB_115 _SYMB_75 SUBSCRIPT _SYMB_157  */
#line 1129 "HAL_S.y"
                                                   { (yyval.on_clause_) = make_AAon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6466 "Parser.c"
    break;

  case 384: /* ON_CLAUSE: _SYMB_115 _SYMB_75 SUBSCRIPT _SYMB_90  */
#line 1130 "HAL_S.y"
                                          { (yyval.on_clause_) = make_ABon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6472 "Parser.c"
    break;

  case 385: /* ON_CLAUSE: _SYMB_115 _SYMB_75 _SYMB_157  */
#line 1131 "HAL_S.y"
                                 { (yyval.on_clause_) = make_ADon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6478 "Parser.c"
    break;

  case 386: /* ON_CLAUSE: _SYMB_115 _SYMB_75 _SYMB_90  */
#line 1132 "HAL_S.y"
                                { (yyval.on_clause_) = make_AEon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6484 "Parser.c"
    break;

  case 387: /* LABEL_DEFINITION: LABEL _SYMB_17  */
#line 1134 "HAL_S.y"
                                  { (yyval.label_definition_) = make_AAlabel_definition((yyvsp[-1].label_)); (yyval.label_definition_)->line_number = (yyloc).first_line; (yyval.label_definition_)->char_number = (yyloc).first_column;  }
#line 6490 "Parser.c"
    break;

  case 388: /* CALL_KEY: _SYMB_47 LABEL_VAR  */
#line 1136 "HAL_S.y"
                              { (yyval.call_key_) = make_AAcall_key((yyvsp[0].label_var_)); (yyval.call_key_)->line_number = (yyloc).first_line; (yyval.call_key_)->char_number = (yyloc).first_column;  }
#line 6496 "Parser.c"
    break;

  case 389: /* ASSIGN: _SYMB_40  */
#line 1138 "HAL_S.y"
                  { (yyval.assign_) = make_AAassign(); (yyval.assign_)->line_number = (yyloc).first_line; (yyval.assign_)->char_number = (yyloc).first_column;  }
#line 6502 "Parser.c"
    break;

  case 390: /* CALL_ASSIGN_LIST: VARIABLE  */
#line 1140 "HAL_S.y"
                            { (yyval.call_assign_list_) = make_AAcall_assign_list((yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6508 "Parser.c"
    break;

  case 391: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_0 VARIABLE  */
#line 1141 "HAL_S.y"
                                      { (yyval.call_assign_list_) = make_ABcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6514 "Parser.c"
    break;

  case 392: /* CALL_ASSIGN_LIST: QUAL_STRUCT  */
#line 1142 "HAL_S.y"
                { (yyval.call_assign_list_) = make_ACcall_assign_list((yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6520 "Parser.c"
    break;

  case 393: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_0 QUAL_STRUCT  */
#line 1143 "HAL_S.y"
                                         { (yyval.call_assign_list_) = make_ADcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6526 "Parser.c"
    break;

  case 394: /* DO_GROUP_HEAD: _SYMB_68 _SYMB_16  */
#line 1145 "HAL_S.y"
                                  { (yyval.do_group_head_) = make_AAdoGroupHead(); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6532 "Parser.c"
    break;

  case 395: /* DO_GROUP_HEAD: _SYMB_68 FOR_LIST _SYMB_16  */
#line 1146 "HAL_S.y"
                               { (yyval.do_group_head_) = make_ABdoGroupHeadFor((yyvsp[-1].for_list_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6538 "Parser.c"
    break;

  case 396: /* DO_GROUP_HEAD: _SYMB_68 FOR_LIST WHILE_CLAUSE _SYMB_16  */
#line 1147 "HAL_S.y"
                                            { (yyval.do_group_head_) = make_ACdoGroupHeadForWhile((yyvsp[-2].for_list_), (yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6544 "Parser.c"
    break;

  case 397: /* DO_GROUP_HEAD: _SYMB_68 WHILE_CLAUSE _SYMB_16  */
#line 1148 "HAL_S.y"
                                   { (yyval.do_group_head_) = make_ADdoGroupHeadWhile((yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6550 "Parser.c"
    break;

  case 398: /* DO_GROUP_HEAD: _SYMB_68 _SYMB_49 ARITH_EXP _SYMB_16  */
#line 1149 "HAL_S.y"
                                         { (yyval.do_group_head_) = make_AEdoGroupHeadCase((yyvsp[-1].arith_exp_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6556 "Parser.c"
    break;

  case 399: /* DO_GROUP_HEAD: CASE_ELSE STATEMENT  */
#line 1150 "HAL_S.y"
                        { (yyval.do_group_head_) = make_AFdoGroupHeadCaseElse((yyvsp[-1].case_else_), (yyvsp[0].statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6562 "Parser.c"
    break;

  case 400: /* DO_GROUP_HEAD: DO_GROUP_HEAD ANY_STATEMENT  */
#line 1151 "HAL_S.y"
                                { (yyval.do_group_head_) = make_AGdoGroupHeadStatement((yyvsp[-1].do_group_head_), (yyvsp[0].any_statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6568 "Parser.c"
    break;

  case 401: /* DO_GROUP_HEAD: DO_GROUP_HEAD TEMPORARY_STMT  */
#line 1152 "HAL_S.y"
                                 { (yyval.do_group_head_) = make_AHdoGroupHeadTemporaryStatement((yyvsp[-1].do_group_head_), (yyvsp[0].temporary_stmt_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6574 "Parser.c"
    break;

  case 402: /* ENDING: _SYMB_71  */
#line 1154 "HAL_S.y"
                  { (yyval.ending_) = make_AAending(); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6580 "Parser.c"
    break;

  case 403: /* ENDING: _SYMB_71 LABEL  */
#line 1155 "HAL_S.y"
                   { (yyval.ending_) = make_ABending((yyvsp[0].label_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6586 "Parser.c"
    break;

  case 404: /* ENDING: LABEL_DEFINITION ENDING  */
#line 1156 "HAL_S.y"
                            { (yyval.ending_) = make_ACending((yyvsp[-1].label_definition_), (yyvsp[0].ending_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6592 "Parser.c"
    break;

  case 405: /* READ_KEY: _SYMB_125 _SYMB_2 NUMBER _SYMB_1  */
#line 1158 "HAL_S.y"
                                            { (yyval.read_key_) = make_AAread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 6598 "Parser.c"
    break;

  case 406: /* READ_KEY: _SYMB_126 _SYMB_2 NUMBER _SYMB_1  */
#line 1159 "HAL_S.y"
                                     { (yyval.read_key_) = make_ABread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 6604 "Parser.c"
    break;

  case 407: /* WRITE_KEY: _SYMB_177 _SYMB_2 NUMBER _SYMB_1  */
#line 1161 "HAL_S.y"
                                             { (yyval.write_key_) = make_AAwrite_key((yyvsp[-1].number_)); (yyval.write_key_)->line_number = (yyloc).first_line; (yyval.write_key_)->char_number = (yyloc).first_column;  }
#line 6610 "Parser.c"
    break;

  case 408: /* READ_PHRASE: READ_KEY READ_ARG  */
#line 1163 "HAL_S.y"
                                { (yyval.read_phrase_) = make_AAread_phrase((yyvsp[-1].read_key_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 6616 "Parser.c"
    break;

  case 409: /* READ_PHRASE: READ_PHRASE _SYMB_0 READ_ARG  */
#line 1164 "HAL_S.y"
                                 { (yyval.read_phrase_) = make_ABread_phrase((yyvsp[-2].read_phrase_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 6622 "Parser.c"
    break;

  case 410: /* WRITE_PHRASE: WRITE_KEY WRITE_ARG  */
#line 1166 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_AAwrite_phrase((yyvsp[-1].write_key_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 6628 "Parser.c"
    break;

  case 411: /* WRITE_PHRASE: WRITE_PHRASE _SYMB_0 WRITE_ARG  */
#line 1167 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_ABwrite_phrase((yyvsp[-2].write_phrase_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 6634 "Parser.c"
    break;

  case 412: /* READ_ARG: VARIABLE  */
#line 1169 "HAL_S.y"
                    { (yyval.read_arg_) = make_AAread_arg((yyvsp[0].variable_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 6640 "Parser.c"
    break;

  case 413: /* READ_ARG: IO_CONTROL  */
#line 1170 "HAL_S.y"
               { (yyval.read_arg_) = make_ABread_arg((yyvsp[0].io_control_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 6646 "Parser.c"
    break;

  case 414: /* WRITE_ARG: EXPRESSION  */
#line 1172 "HAL_S.y"
                       { (yyval.write_arg_) = make_AAwrite_arg((yyvsp[0].expression_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6652 "Parser.c"
    break;

  case 415: /* WRITE_ARG: IO_CONTROL  */
#line 1173 "HAL_S.y"
               { (yyval.write_arg_) = make_ABwrite_arg((yyvsp[0].io_control_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6658 "Parser.c"
    break;

  case 416: /* WRITE_ARG: _SYMB_186  */
#line 1174 "HAL_S.y"
              { (yyval.write_arg_) = make_ACwrite_arg((yyvsp[0].string_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6664 "Parser.c"
    break;

  case 417: /* FILE_EXP: FILE_HEAD _SYMB_0 ARITH_EXP _SYMB_1  */
#line 1176 "HAL_S.y"
                                               { (yyval.file_exp_) = make_AAfile_exp((yyvsp[-3].file_head_), (yyvsp[-1].arith_exp_)); (yyval.file_exp_)->line_number = (yyloc).first_line; (yyval.file_exp_)->char_number = (yyloc).first_column;  }
#line 6670 "Parser.c"
    break;

  case 418: /* FILE_HEAD: _SYMB_83 _SYMB_2 NUMBER  */
#line 1178 "HAL_S.y"
                                    { (yyval.file_head_) = make_AAfile_head((yyvsp[0].number_)); (yyval.file_head_)->line_number = (yyloc).first_line; (yyval.file_head_)->char_number = (yyloc).first_column;  }
#line 6676 "Parser.c"
    break;

  case 419: /* IO_CONTROL: _SYMB_151 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1180 "HAL_S.y"
                                                 { (yyval.io_control_) = make_AAioControlSkip((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6682 "Parser.c"
    break;

  case 420: /* IO_CONTROL: _SYMB_158 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1181 "HAL_S.y"
                                        { (yyval.io_control_) = make_ABioControlTab((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6688 "Parser.c"
    break;

  case 421: /* IO_CONTROL: _SYMB_56 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1182 "HAL_S.y"
                                       { (yyval.io_control_) = make_ACioControlColumn((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6694 "Parser.c"
    break;

  case 422: /* IO_CONTROL: _SYMB_98 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1183 "HAL_S.y"
                                       { (yyval.io_control_) = make_ADioControlLine((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6700 "Parser.c"
    break;

  case 423: /* IO_CONTROL: _SYMB_117 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1184 "HAL_S.y"
                                        { (yyval.io_control_) = make_AEioControlPage((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6706 "Parser.c"
    break;

  case 424: /* WAIT_KEY: _SYMB_175  */
#line 1186 "HAL_S.y"
                     { (yyval.wait_key_) = make_AAwait_key(); (yyval.wait_key_)->line_number = (yyloc).first_line; (yyval.wait_key_)->char_number = (yyloc).first_column;  }
#line 6712 "Parser.c"
    break;

  case 425: /* TERMINATOR: _SYMB_163  */
#line 1188 "HAL_S.y"
                       { (yyval.terminator_) = make_AAterminatorTerminate(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 6718 "Parser.c"
    break;

  case 426: /* TERMINATOR: _SYMB_48  */
#line 1189 "HAL_S.y"
             { (yyval.terminator_) = make_ABterminatorCancel(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 6724 "Parser.c"
    break;

  case 427: /* TERMINATE_LIST: LABEL_VAR  */
#line 1191 "HAL_S.y"
                           { (yyval.terminate_list_) = make_AAterminate_list((yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 6730 "Parser.c"
    break;

  case 428: /* TERMINATE_LIST: TERMINATE_LIST _SYMB_0 LABEL_VAR  */
#line 1192 "HAL_S.y"
                                     { (yyval.terminate_list_) = make_ABterminate_list((yyvsp[-2].terminate_list_), (yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 6736 "Parser.c"
    break;

  case 429: /* SCHEDULE_HEAD: _SYMB_139 LABEL_VAR  */
#line 1194 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_AAscheduleHeadLabel((yyvsp[0].label_var_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6742 "Parser.c"
    break;

  case 430: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_41 ARITH_EXP  */
#line 1195 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ABscheduleHeadAt((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6748 "Parser.c"
    break;

  case 431: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_91 ARITH_EXP  */
#line 1196 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ACscheduleHeadIn((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6754 "Parser.c"
    break;

  case 432: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_115 BIT_EXP  */
#line 1197 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_ADscheduleHeadOn((yyvsp[-2].schedule_head_), (yyvsp[0].bit_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6760 "Parser.c"
    break;

  case 433: /* SCHEDULE_PHRASE: SCHEDULE_HEAD  */
#line 1199 "HAL_S.y"
                                { (yyval.schedule_phrase_) = make_AAschedule_phrase((yyvsp[0].schedule_head_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6766 "Parser.c"
    break;

  case 434: /* SCHEDULE_PHRASE: SCHEDULE_HEAD _SYMB_119 _SYMB_2 ARITH_EXP _SYMB_1  */
#line 1200 "HAL_S.y"
                                                      { (yyval.schedule_phrase_) = make_ABschedule_phrase((yyvsp[-4].schedule_head_), (yyvsp[-1].arith_exp_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6772 "Parser.c"
    break;

  case 435: /* SCHEDULE_PHRASE: SCHEDULE_PHRASE _SYMB_65  */
#line 1201 "HAL_S.y"
                             { (yyval.schedule_phrase_) = make_ACschedule_phrase((yyvsp[-1].schedule_phrase_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6778 "Parser.c"
    break;

  case 436: /* SCHEDULE_CONTROL: STOPPING  */
#line 1203 "HAL_S.y"
                            { (yyval.schedule_control_) = make_AAschedule_control((yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6784 "Parser.c"
    break;

  case 437: /* SCHEDULE_CONTROL: TIMING  */
#line 1204 "HAL_S.y"
           { (yyval.schedule_control_) = make_ABschedule_control((yyvsp[0].timing_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6790 "Parser.c"
    break;

  case 438: /* SCHEDULE_CONTROL: TIMING STOPPING  */
#line 1205 "HAL_S.y"
                    { (yyval.schedule_control_) = make_ACschedule_control((yyvsp[-1].timing_), (yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6796 "Parser.c"
    break;

  case 439: /* TIMING: REPEAT _SYMB_77 ARITH_EXP  */
#line 1207 "HAL_S.y"
                                   { (yyval.timing_) = make_AAtimingEvery((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6802 "Parser.c"
    break;

  case 440: /* TIMING: REPEAT _SYMB_29 ARITH_EXP  */
#line 1208 "HAL_S.y"
                              { (yyval.timing_) = make_ABtimingAfter((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6808 "Parser.c"
    break;

  case 441: /* TIMING: REPEAT  */
#line 1209 "HAL_S.y"
           { (yyval.timing_) = make_ACtiming((yyvsp[0].repeat_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6814 "Parser.c"
    break;

  case 442: /* REPEAT: _SYMB_0 _SYMB_130  */
#line 1211 "HAL_S.y"
                           { (yyval.repeat_) = make_AArepeat(); (yyval.repeat_)->line_number = (yyloc).first_line; (yyval.repeat_)->char_number = (yyloc).first_column;  }
#line 6820 "Parser.c"
    break;

  case 443: /* STOPPING: WHILE_KEY ARITH_EXP  */
#line 1213 "HAL_S.y"
                               { (yyval.stopping_) = make_AAstopping((yyvsp[-1].while_key_), (yyvsp[0].arith_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 6826 "Parser.c"
    break;

  case 444: /* STOPPING: WHILE_KEY BIT_EXP  */
#line 1214 "HAL_S.y"
                      { (yyval.stopping_) = make_ABstopping((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 6832 "Parser.c"
    break;

  case 445: /* SIGNAL_CLAUSE: _SYMB_141 EVENT_VAR  */
#line 1216 "HAL_S.y"
                                    { (yyval.signal_clause_) = make_AAsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6838 "Parser.c"
    break;

  case 446: /* SIGNAL_CLAUSE: _SYMB_132 EVENT_VAR  */
#line 1217 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ABsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6844 "Parser.c"
    break;

  case 447: /* SIGNAL_CLAUSE: _SYMB_145 EVENT_VAR  */
#line 1218 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ACsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6850 "Parser.c"
    break;

  case 448: /* PERCENT_MACRO_NAME: _SYMB_25 IDENTIFIER  */
#line 1220 "HAL_S.y"
                                         { (yyval.percent_macro_name_) = make_FNpercent_macro_name((yyvsp[0].identifier_)); (yyval.percent_macro_name_)->line_number = (yyloc).first_line; (yyval.percent_macro_name_)->char_number = (yyloc).first_column;  }
#line 6856 "Parser.c"
    break;

  case 449: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_NAME _SYMB_2  */
#line 1222 "HAL_S.y"
                                                { (yyval.percent_macro_head_) = make_AApercent_macro_head((yyvsp[-1].percent_macro_name_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 6862 "Parser.c"
    break;

  case 450: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_0  */
#line 1223 "HAL_S.y"
                                                 { (yyval.percent_macro_head_) = make_ABpercent_macro_head((yyvsp[-2].percent_macro_head_), (yyvsp[-1].percent_macro_arg_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 6868 "Parser.c"
    break;

  case 451: /* PERCENT_MACRO_ARG: NAME_VAR  */
#line 1225 "HAL_S.y"
                             { (yyval.percent_macro_arg_) = make_AApercent_macro_arg((yyvsp[0].name_var_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 6874 "Parser.c"
    break;

  case 452: /* PERCENT_MACRO_ARG: CONSTANT  */
#line 1226 "HAL_S.y"
             { (yyval.percent_macro_arg_) = make_ABpercent_macro_arg((yyvsp[0].constant_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 6880 "Parser.c"
    break;

  case 453: /* CASE_ELSE: _SYMB_68 _SYMB_49 ARITH_EXP _SYMB_16 _SYMB_70  */
#line 1228 "HAL_S.y"
                                                          { (yyval.case_else_) = make_AAcase_else((yyvsp[-2].arith_exp_)); (yyval.case_else_)->line_number = (yyloc).first_line; (yyval.case_else_)->char_number = (yyloc).first_column;  }
#line 6886 "Parser.c"
    break;

  case 454: /* WHILE_KEY: _SYMB_176  */
#line 1230 "HAL_S.y"
                      { (yyval.while_key_) = make_AAwhileKeyWhile(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 6892 "Parser.c"
    break;

  case 455: /* WHILE_KEY: _SYMB_172  */
#line 1231 "HAL_S.y"
              { (yyval.while_key_) = make_ABwhileKeyUntil(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 6898 "Parser.c"
    break;

  case 456: /* WHILE_CLAUSE: WHILE_KEY BIT_EXP  */
#line 1233 "HAL_S.y"
                                 { (yyval.while_clause_) = make_AAwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 6904 "Parser.c"
    break;

  case 457: /* WHILE_CLAUSE: WHILE_KEY RELATIONAL_EXP  */
#line 1234 "HAL_S.y"
                             { (yyval.while_clause_) = make_ABwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].relational_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 6910 "Parser.c"
    break;

  case 458: /* FOR_LIST: FOR_KEY ARITH_EXP ITERATION_CONTROL  */
#line 1236 "HAL_S.y"
                                               { (yyval.for_list_) = make_AAfor_list((yyvsp[-2].for_key_), (yyvsp[-1].arith_exp_), (yyvsp[0].iteration_control_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 6916 "Parser.c"
    break;

  case 459: /* FOR_LIST: FOR_KEY ITERATION_BODY  */
#line 1237 "HAL_S.y"
                           { (yyval.for_list_) = make_ABfor_list((yyvsp[-1].for_key_), (yyvsp[0].iteration_body_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 6922 "Parser.c"
    break;

  case 460: /* ITERATION_BODY: ARITH_EXP  */
#line 1239 "HAL_S.y"
                           { (yyval.iteration_body_) = make_AAiteration_body((yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 6928 "Parser.c"
    break;

  case 461: /* ITERATION_BODY: ITERATION_BODY _SYMB_0 ARITH_EXP  */
#line 1240 "HAL_S.y"
                                     { (yyval.iteration_body_) = make_ABiteration_body((yyvsp[-2].iteration_body_), (yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 6934 "Parser.c"
    break;

  case 462: /* ITERATION_CONTROL: _SYMB_165 ARITH_EXP  */
#line 1242 "HAL_S.y"
                                        { (yyval.iteration_control_) = make_AAiteration_controlTo((yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 6940 "Parser.c"
    break;

  case 463: /* ITERATION_CONTROL: _SYMB_165 ARITH_EXP _SYMB_46 ARITH_EXP  */
#line 1243 "HAL_S.y"
                                           { (yyval.iteration_control_) = make_ABiteration_controlToBy((yyvsp[-2].arith_exp_), (yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 6946 "Parser.c"
    break;

  case 464: /* FOR_KEY: _SYMB_85 ARITH_VAR EQUALS  */
#line 1245 "HAL_S.y"
                                    { (yyval.for_key_) = make_AAforKey((yyvsp[-1].arith_var_), (yyvsp[0].equals_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 6952 "Parser.c"
    break;

  case 465: /* FOR_KEY: _SYMB_85 _SYMB_162 IDENTIFIER _SYMB_23  */
#line 1246 "HAL_S.y"
                                           { (yyval.for_key_) = make_ABforKeyTemporary((yyvsp[-1].identifier_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 6958 "Parser.c"
    break;

  case 466: /* TEMPORARY_STMT: _SYMB_162 DECLARE_BODY _SYMB_16  */
#line 1248 "HAL_S.y"
                                                 { (yyval.temporary_stmt_) = make_AAtemporary_stmt((yyvsp[-1].declare_body_)); (yyval.temporary_stmt_)->line_number = (yyloc).first_line; (yyval.temporary_stmt_)->char_number = (yyloc).first_column;  }
#line 6964 "Parser.c"
    break;

  case 467: /* CONSTANT: NUMBER  */
#line 1250 "HAL_S.y"
                  { (yyval.constant_) = make_AAconstant((yyvsp[0].number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6970 "Parser.c"
    break;

  case 468: /* CONSTANT: COMPOUND_NUMBER  */
#line 1251 "HAL_S.y"
                    { (yyval.constant_) = make_ABconstant((yyvsp[0].compound_number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6976 "Parser.c"
    break;

  case 469: /* CONSTANT: BIT_CONST  */
#line 1252 "HAL_S.y"
              { (yyval.constant_) = make_ACconstant((yyvsp[0].bit_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6982 "Parser.c"
    break;

  case 470: /* CONSTANT: CHAR_CONST  */
#line 1253 "HAL_S.y"
               { (yyval.constant_) = make_ADconstant((yyvsp[0].char_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6988 "Parser.c"
    break;

  case 471: /* ARRAY_HEAD: _SYMB_39 _SYMB_2  */
#line 1255 "HAL_S.y"
                              { (yyval.array_head_) = make_AAarray_head(); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 6994 "Parser.c"
    break;

  case 472: /* ARRAY_HEAD: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_0  */
#line 1256 "HAL_S.y"
                                           { (yyval.array_head_) = make_ABarray_head((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 7000 "Parser.c"
    break;

  case 473: /* MINOR_ATTR_LIST: MINOR_ATTRIBUTE  */
#line 1258 "HAL_S.y"
                                  { (yyval.minor_attr_list_) = make_AAminor_attr_list((yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 7006 "Parser.c"
    break;

  case 474: /* MINOR_ATTR_LIST: MINOR_ATTR_LIST MINOR_ATTRIBUTE  */
#line 1259 "HAL_S.y"
                                    { (yyval.minor_attr_list_) = make_ABminor_attr_list((yyvsp[-1].minor_attr_list_), (yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 7012 "Parser.c"
    break;

  case 475: /* MINOR_ATTRIBUTE: _SYMB_153  */
#line 1261 "HAL_S.y"
                            { (yyval.minor_attribute_) = make_AAminorAttributeStatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7018 "Parser.c"
    break;

  case 476: /* MINOR_ATTRIBUTE: _SYMB_42  */
#line 1262 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ABminorAttributeAutomatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7024 "Parser.c"
    break;

  case 477: /* MINOR_ATTRIBUTE: _SYMB_64  */
#line 1263 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ACminorAttributeDense(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7030 "Parser.c"
    break;

  case 478: /* MINOR_ATTRIBUTE: _SYMB_30  */
#line 1264 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ADminorAttributeAligned(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7036 "Parser.c"
    break;

  case 479: /* MINOR_ATTRIBUTE: _SYMB_28  */
#line 1265 "HAL_S.y"
             { (yyval.minor_attribute_) = make_AEminorAttributeAccess(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7042 "Parser.c"
    break;

  case 480: /* MINOR_ATTRIBUTE: _SYMB_100 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1266 "HAL_S.y"
                                                  { (yyval.minor_attribute_) = make_AFminorAttributeLock((yyvsp[-1].literal_exp_or_star_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7048 "Parser.c"
    break;

  case 481: /* MINOR_ATTRIBUTE: _SYMB_129  */
#line 1267 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AGminorAttributeRemote(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7054 "Parser.c"
    break;

  case 482: /* MINOR_ATTRIBUTE: _SYMB_134  */
#line 1268 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AHminorAttributeRigid(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7060 "Parser.c"
    break;

  case 483: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_1  */
#line 1269 "HAL_S.y"
                                                 { (yyval.minor_attribute_) = make_AIminorAttributeRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7066 "Parser.c"
    break;

  case 484: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD _SYMB_6 _SYMB_1  */
#line 1270 "HAL_S.y"
                                       { (yyval.minor_attribute_) = make_AJminorAttributeStar((yyvsp[-2].init_or_const_head_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7072 "Parser.c"
    break;

  case 485: /* MINOR_ATTRIBUTE: _SYMB_96  */
#line 1271 "HAL_S.y"
             { (yyval.minor_attribute_) = make_AKminorAttributeLatched(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7078 "Parser.c"
    break;

  case 486: /* MINOR_ATTRIBUTE: _SYMB_109 _SYMB_2 LEVEL _SYMB_1  */
#line 1272 "HAL_S.y"
                                    { (yyval.minor_attribute_) = make_ALminorAttributeNonHal((yyvsp[-1].level_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 7084 "Parser.c"
    break;

  case 487: /* INIT_OR_CONST_HEAD: _SYMB_93 _SYMB_2  */
#line 1274 "HAL_S.y"
                                      { (yyval.init_or_const_head_) = make_AAinit_or_const_headInitial(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7090 "Parser.c"
    break;

  case 488: /* INIT_OR_CONST_HEAD: _SYMB_58 _SYMB_2  */
#line 1275 "HAL_S.y"
                     { (yyval.init_or_const_head_) = make_ABinit_or_const_headConstant(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7096 "Parser.c"
    break;

  case 489: /* INIT_OR_CONST_HEAD: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_0  */
#line 1276 "HAL_S.y"
                                                 { (yyval.init_or_const_head_) = make_ACinit_or_const_headRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 7102 "Parser.c"
    break;

  case 490: /* REPEATED_CONSTANT: EXPRESSION  */
#line 1278 "HAL_S.y"
                               { (yyval.repeated_constant_) = make_AArepeated_constant((yyvsp[0].expression_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7108 "Parser.c"
    break;

  case 491: /* REPEATED_CONSTANT: REPEAT_HEAD VARIABLE  */
#line 1279 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ABrepeated_constant((yyvsp[-1].repeat_head_), (yyvsp[0].variable_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7114 "Parser.c"
    break;

  case 492: /* REPEATED_CONSTANT: REPEAT_HEAD CONSTANT  */
#line 1280 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ACrepeated_constant((yyvsp[-1].repeat_head_), (yyvsp[0].constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7120 "Parser.c"
    break;

  case 493: /* REPEATED_CONSTANT: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_1  */
#line 1281 "HAL_S.y"
                                                 { (yyval.repeated_constant_) = make_ADrepeated_constant((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7126 "Parser.c"
    break;

  case 494: /* REPEATED_CONSTANT: REPEAT_HEAD  */
#line 1282 "HAL_S.y"
                { (yyval.repeated_constant_) = make_AErepeated_constant((yyvsp[0].repeat_head_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 7132 "Parser.c"
    break;

  case 495: /* REPEAT_HEAD: ARITH_EXP _SYMB_9 SIMPLE_NUMBER  */
#line 1284 "HAL_S.y"
                                              { (yyval.repeat_head_) = make_AArepeat_head((yyvsp[-2].arith_exp_), (yyvsp[0].simple_number_)); (yyval.repeat_head_)->line_number = (yyloc).first_line; (yyval.repeat_head_)->char_number = (yyloc).first_column;  }
#line 7138 "Parser.c"
    break;

  case 496: /* NESTED_REPEAT_HEAD: REPEAT_HEAD _SYMB_2  */
#line 1286 "HAL_S.y"
                                         { (yyval.nested_repeat_head_) = make_AAnested_repeat_head((yyvsp[-1].repeat_head_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 7144 "Parser.c"
    break;

  case 497: /* NESTED_REPEAT_HEAD: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_0  */
#line 1287 "HAL_S.y"
                                                 { (yyval.nested_repeat_head_) = make_ABnested_repeat_head((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 7150 "Parser.c"
    break;

  case 498: /* DCL_LIST_COMMA: DECLARATION_LIST _SYMB_0  */
#line 1289 "HAL_S.y"
                                          { (yyval.dcl_list_comma_) = make_AAdcl_list_comma((yyvsp[-1].declaration_list_)); (yyval.dcl_list_comma_)->line_number = (yyloc).first_line; (yyval.dcl_list_comma_)->char_number = (yyloc).first_column;  }
#line 7156 "Parser.c"
    break;

  case 499: /* LITERAL_EXP_OR_STAR: ARITH_EXP  */
#line 1291 "HAL_S.y"
                                { (yyval.literal_exp_or_star_) = make_AAliteralExp((yyvsp[0].arith_exp_)); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7162 "Parser.c"
    break;

  case 500: /* LITERAL_EXP_OR_STAR: _SYMB_6  */
#line 1292 "HAL_S.y"
            { (yyval.literal_exp_or_star_) = make_ABliteralStar(); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7168 "Parser.c"
    break;

  case 501: /* TYPE_SPEC: STRUCT_SPEC  */
#line 1294 "HAL_S.y"
                        { (yyval.type_spec_) = make_AAtypeSpecStruct((yyvsp[0].struct_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7174 "Parser.c"
    break;

  case 502: /* TYPE_SPEC: BIT_SPEC  */
#line 1295 "HAL_S.y"
             { (yyval.type_spec_) = make_ABtypeSpecBit((yyvsp[0].bit_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7180 "Parser.c"
    break;

  case 503: /* TYPE_SPEC: CHAR_SPEC  */
#line 1296 "HAL_S.y"
              { (yyval.type_spec_) = make_ACtypeSpecChar((yyvsp[0].char_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7186 "Parser.c"
    break;

  case 504: /* TYPE_SPEC: ARITH_SPEC  */
#line 1297 "HAL_S.y"
               { (yyval.type_spec_) = make_ADtypeSpecArith((yyvsp[0].arith_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7192 "Parser.c"
    break;

  case 505: /* TYPE_SPEC: _SYMB_76  */
#line 1298 "HAL_S.y"
             { (yyval.type_spec_) = make_AEtypeSpecEvent(); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7198 "Parser.c"
    break;

  case 506: /* BIT_SPEC: _SYMB_45  */
#line 1300 "HAL_S.y"
                    { (yyval.bit_spec_) = make_AAbitSpecBoolean(); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7204 "Parser.c"
    break;

  case 507: /* BIT_SPEC: _SYMB_44 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1301 "HAL_S.y"
                                                 { (yyval.bit_spec_) = make_ABbitSpecBoolean((yyvsp[-1].literal_exp_or_star_)); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7210 "Parser.c"
    break;

  case 508: /* CHAR_SPEC: _SYMB_53 _SYMB_2 LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1303 "HAL_S.y"
                                                         { (yyval.char_spec_) = make_AAchar_spec((yyvsp[-1].literal_exp_or_star_)); (yyval.char_spec_)->line_number = (yyloc).first_line; (yyval.char_spec_)->char_number = (yyloc).first_column;  }
#line 7216 "Parser.c"
    break;

  case 509: /* STRUCT_SPEC: STRUCT_TEMPLATE STRUCT_SPEC_BODY  */
#line 1305 "HAL_S.y"
                                               { (yyval.struct_spec_) = make_AAstruct_spec((yyvsp[-1].struct_template_), (yyvsp[0].struct_spec_body_)); (yyval.struct_spec_)->line_number = (yyloc).first_line; (yyval.struct_spec_)->char_number = (yyloc).first_column;  }
#line 7222 "Parser.c"
    break;

  case 510: /* STRUCT_SPEC_BODY: _SYMB_5 _SYMB_154  */
#line 1307 "HAL_S.y"
                                     { (yyval.struct_spec_body_) = make_AAstruct_spec_body(); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7228 "Parser.c"
    break;

  case 511: /* STRUCT_SPEC_BODY: STRUCT_SPEC_HEAD LITERAL_EXP_OR_STAR _SYMB_1  */
#line 1308 "HAL_S.y"
                                                 { (yyval.struct_spec_body_) = make_ABstruct_spec_body((yyvsp[-2].struct_spec_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7234 "Parser.c"
    break;

  case 512: /* STRUCT_TEMPLATE: STRUCTURE_ID  */
#line 1310 "HAL_S.y"
                               { (yyval.struct_template_) = make_FMstruct_template((yyvsp[0].structure_id_)); (yyval.struct_template_)->line_number = (yyloc).first_line; (yyval.struct_template_)->char_number = (yyloc).first_column;  }
#line 7240 "Parser.c"
    break;

  case 513: /* STRUCT_SPEC_HEAD: _SYMB_5 _SYMB_154 _SYMB_2  */
#line 1312 "HAL_S.y"
                                             { (yyval.struct_spec_head_) = make_AAstruct_spec_head(); (yyval.struct_spec_head_)->line_number = (yyloc).first_line; (yyval.struct_spec_head_)->char_number = (yyloc).first_column;  }
#line 7246 "Parser.c"
    break;

  case 514: /* ARITH_SPEC: PREC_SPEC  */
#line 1314 "HAL_S.y"
                       { (yyval.arith_spec_) = make_AAarith_spec((yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7252 "Parser.c"
    break;

  case 515: /* ARITH_SPEC: SQ_DQ_NAME  */
#line 1315 "HAL_S.y"
               { (yyval.arith_spec_) = make_ABarith_spec((yyvsp[0].sq_dq_name_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7258 "Parser.c"
    break;

  case 516: /* ARITH_SPEC: SQ_DQ_NAME PREC_SPEC  */
#line 1316 "HAL_S.y"
                         { (yyval.arith_spec_) = make_ACarith_spec((yyvsp[-1].sq_dq_name_), (yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7264 "Parser.c"
    break;

  case 517: /* COMPILATION: ANY_STATEMENT  */
#line 1318 "HAL_S.y"
                            { (yyval.compilation_) = make_AAcompilation((yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7270 "Parser.c"
    break;

  case 518: /* COMPILATION: COMPILATION ANY_STATEMENT  */
#line 1319 "HAL_S.y"
                              { (yyval.compilation_) = make_ABcompilation((yyvsp[-1].compilation_), (yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7276 "Parser.c"
    break;

  case 519: /* COMPILATION: DECLARE_STATEMENT  */
#line 1320 "HAL_S.y"
                      { (yyval.compilation_) = make_ACcompilation((yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7282 "Parser.c"
    break;

  case 520: /* COMPILATION: COMPILATION DECLARE_STATEMENT  */
#line 1321 "HAL_S.y"
                                  { (yyval.compilation_) = make_ADcompilation((yyvsp[-1].compilation_), (yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7288 "Parser.c"
    break;

  case 521: /* COMPILATION: STRUCTURE_STMT  */
#line 1322 "HAL_S.y"
                   { (yyval.compilation_) = make_AEcompilation((yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7294 "Parser.c"
    break;

  case 522: /* COMPILATION: COMPILATION STRUCTURE_STMT  */
#line 1323 "HAL_S.y"
                               { (yyval.compilation_) = make_AFcompilation((yyvsp[-1].compilation_), (yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7300 "Parser.c"
    break;

  case 523: /* COMPILATION: REPLACE_STMT _SYMB_16  */
#line 1324 "HAL_S.y"
                          { (yyval.compilation_) = make_AGcompilation((yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7306 "Parser.c"
    break;

  case 524: /* COMPILATION: COMPILATION REPLACE_STMT _SYMB_16  */
#line 1325 "HAL_S.y"
                                      { (yyval.compilation_) = make_AHcompilation((yyvsp[-2].compilation_), (yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7312 "Parser.c"
    break;

  case 525: /* COMPILATION: INIT_OR_CONST_HEAD EXPRESSION _SYMB_1  */
#line 1326 "HAL_S.y"
                                          { (yyval.compilation_) = make_AZcompilationInitOrConst((yyvsp[-2].init_or_const_head_), (yyvsp[-1].expression_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7318 "Parser.c"
    break;

  case 526: /* BLOCK_DEFINITION: BLOCK_STMT CLOSING _SYMB_16  */
#line 1328 "HAL_S.y"
                                               { (yyval.block_definition_) = make_AAblock_definition((yyvsp[-2].block_stmt_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7324 "Parser.c"
    break;

  case 527: /* BLOCK_DEFINITION: BLOCK_STMT BLOCK_BODY CLOSING _SYMB_16  */
#line 1329 "HAL_S.y"
                                           { (yyval.block_definition_) = make_ABblock_definition((yyvsp[-3].block_stmt_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7330 "Parser.c"
    break;

  case 528: /* BLOCK_STMT: BLOCK_STMT_TOP _SYMB_16  */
#line 1331 "HAL_S.y"
                                     { (yyval.block_stmt_) = make_AAblock_stmt((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_)->line_number = (yyloc).first_line; (yyval.block_stmt_)->char_number = (yyloc).first_column;  }
#line 7336 "Parser.c"
    break;

  case 529: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_28  */
#line 1333 "HAL_S.y"
                                         { (yyval.block_stmt_top_) = make_AAblockTopAccess((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7342 "Parser.c"
    break;

  case 530: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_134  */
#line 1334 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ABblockTopRigid((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7348 "Parser.c"
    break;

  case 531: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD  */
#line 1335 "HAL_S.y"
                    { (yyval.block_stmt_top_) = make_ACblockTopHead((yyvsp[0].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7354 "Parser.c"
    break;

  case 532: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_78  */
#line 1336 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ADblockTopExclusive((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7360 "Parser.c"
    break;

  case 533: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_127  */
#line 1337 "HAL_S.y"
                              { (yyval.block_stmt_top_) = make_AEblockTopReentrant((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7366 "Parser.c"
    break;

  case 534: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_122  */
#line 1339 "HAL_S.y"
                                           { (yyval.block_stmt_head_) = make_AAblockHeadProgram((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7372 "Parser.c"
    break;

  case 535: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_57  */
#line 1340 "HAL_S.y"
                            { (yyval.block_stmt_head_) = make_ABblockHeadCompool((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7378 "Parser.c"
    break;

  case 536: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_161  */
#line 1341 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ACblockHeadTask((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7384 "Parser.c"
    break;

  case 537: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_173  */
#line 1342 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ADblockHeadUpdate((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7390 "Parser.c"
    break;

  case 538: /* BLOCK_STMT_HEAD: _SYMB_173  */
#line 1343 "HAL_S.y"
              { (yyval.block_stmt_head_) = make_AEblockHeadUpdate(); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7396 "Parser.c"
    break;

  case 539: /* BLOCK_STMT_HEAD: FUNCTION_NAME  */
#line 1344 "HAL_S.y"
                  { (yyval.block_stmt_head_) = make_AFblockHeadFunction((yyvsp[0].function_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7402 "Parser.c"
    break;

  case 540: /* BLOCK_STMT_HEAD: FUNCTION_NAME FUNC_STMT_BODY  */
#line 1345 "HAL_S.y"
                                 { (yyval.block_stmt_head_) = make_AGblockHeadFunction((yyvsp[-1].function_name_), (yyvsp[0].func_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7408 "Parser.c"
    break;

  case 541: /* BLOCK_STMT_HEAD: PROCEDURE_NAME  */
#line 1346 "HAL_S.y"
                   { (yyval.block_stmt_head_) = make_AHblockHeadProcedure((yyvsp[0].procedure_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7414 "Parser.c"
    break;

  case 542: /* BLOCK_STMT_HEAD: PROCEDURE_NAME PROC_STMT_BODY  */
#line 1347 "HAL_S.y"
                                  { (yyval.block_stmt_head_) = make_AIblockHeadProcedure((yyvsp[-1].procedure_name_), (yyvsp[0].proc_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7420 "Parser.c"
    break;

  case 543: /* LABEL_EXTERNAL: LABEL_DEFINITION  */
#line 1349 "HAL_S.y"
                                  { (yyval.label_external_) = make_AAlabel_external((yyvsp[0].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7426 "Parser.c"
    break;

  case 544: /* LABEL_EXTERNAL: LABEL_DEFINITION _SYMB_81  */
#line 1350 "HAL_S.y"
                              { (yyval.label_external_) = make_ABlabel_external((yyvsp[-1].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7432 "Parser.c"
    break;

  case 545: /* CLOSING: _SYMB_55  */
#line 1352 "HAL_S.y"
                   { (yyval.closing_) = make_AAclosing(); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7438 "Parser.c"
    break;

  case 546: /* CLOSING: _SYMB_55 LABEL  */
#line 1353 "HAL_S.y"
                   { (yyval.closing_) = make_ABclosing((yyvsp[0].label_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7444 "Parser.c"
    break;

  case 547: /* CLOSING: LABEL_DEFINITION CLOSING  */
#line 1354 "HAL_S.y"
                             { (yyval.closing_) = make_ACclosing((yyvsp[-1].label_definition_), (yyvsp[0].closing_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7450 "Parser.c"
    break;

  case 548: /* BLOCK_BODY: DECLARE_GROUP  */
#line 1356 "HAL_S.y"
                           { (yyval.block_body_) = make_ABblock_body((yyvsp[0].declare_group_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7456 "Parser.c"
    break;

  case 549: /* BLOCK_BODY: ANY_STATEMENT  */
#line 1357 "HAL_S.y"
                  { (yyval.block_body_) = make_ADblock_body((yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7462 "Parser.c"
    break;

  case 550: /* BLOCK_BODY: BLOCK_BODY ANY_STATEMENT  */
#line 1358 "HAL_S.y"
                             { (yyval.block_body_) = make_ACblock_body((yyvsp[-1].block_body_), (yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7468 "Parser.c"
    break;

  case 551: /* FUNCTION_NAME: LABEL_EXTERNAL _SYMB_86  */
#line 1360 "HAL_S.y"
                                        { (yyval.function_name_) = make_AAfunction_name((yyvsp[-1].label_external_)); (yyval.function_name_)->line_number = (yyloc).first_line; (yyval.function_name_)->char_number = (yyloc).first_column;  }
#line 7474 "Parser.c"
    break;

  case 552: /* PROCEDURE_NAME: LABEL_EXTERNAL _SYMB_120  */
#line 1362 "HAL_S.y"
                                          { (yyval.procedure_name_) = make_AAprocedure_name((yyvsp[-1].label_external_)); (yyval.procedure_name_)->line_number = (yyloc).first_line; (yyval.procedure_name_)->char_number = (yyloc).first_column;  }
#line 7480 "Parser.c"
    break;

  case 553: /* FUNC_STMT_BODY: PARAMETER_LIST  */
#line 1364 "HAL_S.y"
                                { (yyval.func_stmt_body_) = make_AAfunc_stmt_body((yyvsp[0].parameter_list_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7486 "Parser.c"
    break;

  case 554: /* FUNC_STMT_BODY: TYPE_SPEC  */
#line 1365 "HAL_S.y"
              { (yyval.func_stmt_body_) = make_ABfunc_stmt_body((yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7492 "Parser.c"
    break;

  case 555: /* FUNC_STMT_BODY: PARAMETER_LIST TYPE_SPEC  */
#line 1366 "HAL_S.y"
                             { (yyval.func_stmt_body_) = make_ACfunc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7498 "Parser.c"
    break;

  case 556: /* PROC_STMT_BODY: PARAMETER_LIST  */
#line 1368 "HAL_S.y"
                                { (yyval.proc_stmt_body_) = make_AAproc_stmt_body((yyvsp[0].parameter_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7504 "Parser.c"
    break;

  case 557: /* PROC_STMT_BODY: ASSIGN_LIST  */
#line 1369 "HAL_S.y"
                { (yyval.proc_stmt_body_) = make_ABproc_stmt_body((yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7510 "Parser.c"
    break;

  case 558: /* PROC_STMT_BODY: PARAMETER_LIST ASSIGN_LIST  */
#line 1370 "HAL_S.y"
                               { (yyval.proc_stmt_body_) = make_ACproc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7516 "Parser.c"
    break;

  case 559: /* DECLARE_GROUP: DECLARE_ELEMENT  */
#line 1372 "HAL_S.y"
                                { (yyval.declare_group_) = make_AAdeclare_group((yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7522 "Parser.c"
    break;

  case 560: /* DECLARE_GROUP: DECLARE_GROUP DECLARE_ELEMENT  */
#line 1373 "HAL_S.y"
                                  { (yyval.declare_group_) = make_ABdeclare_group((yyvsp[-1].declare_group_), (yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7528 "Parser.c"
    break;

  case 561: /* DECLARE_ELEMENT: DECLARE_STATEMENT  */
#line 1375 "HAL_S.y"
                                    { (yyval.declare_element_) = make_AAdeclareElementDeclare((yyvsp[0].declare_statement_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7534 "Parser.c"
    break;

  case 562: /* DECLARE_ELEMENT: REPLACE_STMT _SYMB_16  */
#line 1376 "HAL_S.y"
                          { (yyval.declare_element_) = make_ABdeclareElementReplace((yyvsp[-1].replace_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7540 "Parser.c"
    break;

  case 563: /* DECLARE_ELEMENT: STRUCTURE_STMT  */
#line 1377 "HAL_S.y"
                   { (yyval.declare_element_) = make_ACdeclareElementStructure((yyvsp[0].structure_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7546 "Parser.c"
    break;

  case 564: /* DECLARE_ELEMENT: _SYMB_72 _SYMB_81 IDENTIFIER _SYMB_165 VARIABLE _SYMB_16  */
#line 1378 "HAL_S.y"
                                                             { (yyval.declare_element_) = make_ADdeclareElementEquate((yyvsp[-3].identifier_), (yyvsp[-1].variable_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7552 "Parser.c"
    break;

  case 565: /* PARAMETER: _SYMB_191  */
#line 1380 "HAL_S.y"
                      { (yyval.parameter_) = make_AAparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7558 "Parser.c"
    break;

  case 566: /* PARAMETER: _SYMB_182  */
#line 1381 "HAL_S.y"
              { (yyval.parameter_) = make_ABparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7564 "Parser.c"
    break;

  case 567: /* PARAMETER: _SYMB_185  */
#line 1382 "HAL_S.y"
              { (yyval.parameter_) = make_ACparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7570 "Parser.c"
    break;

  case 568: /* PARAMETER: _SYMB_186  */
#line 1383 "HAL_S.y"
              { (yyval.parameter_) = make_ADparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7576 "Parser.c"
    break;

  case 569: /* PARAMETER: _SYMB_189  */
#line 1384 "HAL_S.y"
              { (yyval.parameter_) = make_AEparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7582 "Parser.c"
    break;

  case 570: /* PARAMETER: _SYMB_188  */
#line 1385 "HAL_S.y"
              { (yyval.parameter_) = make_AFparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7588 "Parser.c"
    break;

  case 571: /* PARAMETER_LIST: PARAMETER_HEAD PARAMETER _SYMB_1  */
#line 1387 "HAL_S.y"
                                                  { (yyval.parameter_list_) = make_AAparameter_list((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_list_)->line_number = (yyloc).first_line; (yyval.parameter_list_)->char_number = (yyloc).first_column;  }
#line 7594 "Parser.c"
    break;

  case 572: /* PARAMETER_HEAD: _SYMB_2  */
#line 1389 "HAL_S.y"
                         { (yyval.parameter_head_) = make_AAparameter_head(); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 7600 "Parser.c"
    break;

  case 573: /* PARAMETER_HEAD: PARAMETER_HEAD PARAMETER _SYMB_0  */
#line 1390 "HAL_S.y"
                                     { (yyval.parameter_head_) = make_ABparameter_head((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 7606 "Parser.c"
    break;

  case 574: /* DECLARE_STATEMENT: _SYMB_63 DECLARE_BODY _SYMB_16  */
#line 1392 "HAL_S.y"
                                                   { (yyval.declare_statement_) = make_AAdeclare_statement((yyvsp[-1].declare_body_)); (yyval.declare_statement_)->line_number = (yyloc).first_line; (yyval.declare_statement_)->char_number = (yyloc).first_column;  }
#line 7612 "Parser.c"
    break;

  case 575: /* ASSIGN_LIST: ASSIGN PARAMETER_LIST  */
#line 1394 "HAL_S.y"
                                    { (yyval.assign_list_) = make_AAassign_list((yyvsp[-1].assign_), (yyvsp[0].parameter_list_)); (yyval.assign_list_)->line_number = (yyloc).first_line; (yyval.assign_list_)->char_number = (yyloc).first_column;  }
#line 7618 "Parser.c"
    break;

  case 576: /* TEXT: _SYMB_193  */
#line 1396 "HAL_S.y"
                 { (yyval.text_) = make_FQtext((yyvsp[0].string_)); (yyval.text_)->line_number = (yyloc).first_line; (yyval.text_)->char_number = (yyloc).first_column;  }
#line 7624 "Parser.c"
    break;

  case 577: /* REPLACE_STMT: _SYMB_131 REPLACE_HEAD _SYMB_46 TEXT  */
#line 1398 "HAL_S.y"
                                                    { (yyval.replace_stmt_) = make_AAreplace_stmt((yyvsp[-2].replace_head_), (yyvsp[0].text_)); (yyval.replace_stmt_)->line_number = (yyloc).first_line; (yyval.replace_stmt_)->char_number = (yyloc).first_column;  }
#line 7630 "Parser.c"
    break;

  case 578: /* REPLACE_HEAD: IDENTIFIER  */
#line 1400 "HAL_S.y"
                          { (yyval.replace_head_) = make_AAreplace_head((yyvsp[0].identifier_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 7636 "Parser.c"
    break;

  case 579: /* REPLACE_HEAD: IDENTIFIER _SYMB_2 ARG_LIST _SYMB_1  */
#line 1401 "HAL_S.y"
                                        { (yyval.replace_head_) = make_ABreplace_head((yyvsp[-3].identifier_), (yyvsp[-1].arg_list_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 7642 "Parser.c"
    break;

  case 580: /* ARG_LIST: IDENTIFIER  */
#line 1403 "HAL_S.y"
                      { (yyval.arg_list_) = make_AAarg_list((yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 7648 "Parser.c"
    break;

  case 581: /* ARG_LIST: ARG_LIST _SYMB_0 IDENTIFIER  */
#line 1404 "HAL_S.y"
                                { (yyval.arg_list_) = make_ABarg_list((yyvsp[-2].arg_list_), (yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 7654 "Parser.c"
    break;

  case 582: /* STRUCTURE_STMT: _SYMB_154 STRUCT_STMT_HEAD STRUCT_STMT_TAIL  */
#line 1406 "HAL_S.y"
                                                             { (yyval.structure_stmt_) = make_AAstructure_stmt((yyvsp[-1].struct_stmt_head_), (yyvsp[0].struct_stmt_tail_)); (yyval.structure_stmt_)->line_number = (yyloc).first_line; (yyval.structure_stmt_)->char_number = (yyloc).first_column;  }
#line 7660 "Parser.c"
    break;

  case 583: /* STRUCT_STMT_HEAD: STRUCTURE_ID _SYMB_17 LEVEL  */
#line 1408 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_AAstruct_stmt_head((yyvsp[-2].structure_id_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7666 "Parser.c"
    break;

  case 584: /* STRUCT_STMT_HEAD: STRUCTURE_ID MINOR_ATTR_LIST _SYMB_17 LEVEL  */
#line 1409 "HAL_S.y"
                                                { (yyval.struct_stmt_head_) = make_ABstruct_stmt_head((yyvsp[-3].structure_id_), (yyvsp[-2].minor_attr_list_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7672 "Parser.c"
    break;

  case 585: /* STRUCT_STMT_HEAD: STRUCT_STMT_HEAD DECLARATION _SYMB_0 LEVEL  */
#line 1410 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_ACstruct_stmt_head((yyvsp[-3].struct_stmt_head_), (yyvsp[-2].declaration_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7678 "Parser.c"
    break;

  case 586: /* STRUCT_STMT_TAIL: DECLARATION _SYMB_16  */
#line 1412 "HAL_S.y"
                                        { (yyval.struct_stmt_tail_) = make_AAstruct_stmt_tail((yyvsp[-1].declaration_)); (yyval.struct_stmt_tail_)->line_number = (yyloc).first_line; (yyval.struct_stmt_tail_)->char_number = (yyloc).first_column;  }
#line 7684 "Parser.c"
    break;

  case 587: /* INLINE_DEFINITION: ARITH_INLINE  */
#line 1414 "HAL_S.y"
                                 { (yyval.inline_definition_) = make_AAinline_definition((yyvsp[0].arith_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7690 "Parser.c"
    break;

  case 588: /* INLINE_DEFINITION: BIT_INLINE  */
#line 1415 "HAL_S.y"
               { (yyval.inline_definition_) = make_ABinline_definition((yyvsp[0].bit_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7696 "Parser.c"
    break;

  case 589: /* INLINE_DEFINITION: CHAR_INLINE  */
#line 1416 "HAL_S.y"
                { (yyval.inline_definition_) = make_ACinline_definition((yyvsp[0].char_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7702 "Parser.c"
    break;

  case 590: /* INLINE_DEFINITION: STRUCTURE_EXP  */
#line 1417 "HAL_S.y"
                  { (yyval.inline_definition_) = make_ADinline_definition((yyvsp[0].structure_exp_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7708 "Parser.c"
    break;

  case 591: /* ARITH_INLINE: ARITH_INLINE_DEF CLOSING _SYMB_16  */
#line 1419 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_ACprimary((yyvsp[-2].arith_inline_def_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 7714 "Parser.c"
    break;

  case 592: /* ARITH_INLINE: ARITH_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1420 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_AZprimary((yyvsp[-3].arith_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 7720 "Parser.c"
    break;

  case 593: /* ARITH_INLINE_DEF: _SYMB_86 ARITH_SPEC _SYMB_16  */
#line 1422 "HAL_S.y"
                                                { (yyval.arith_inline_def_) = make_AAarith_inline_def((yyvsp[-1].arith_spec_)); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 7726 "Parser.c"
    break;

  case 594: /* ARITH_INLINE_DEF: _SYMB_86 _SYMB_16  */
#line 1423 "HAL_S.y"
                      { (yyval.arith_inline_def_) = make_ABarith_inline_def(); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 7732 "Parser.c"
    break;

  case 595: /* BIT_INLINE: BIT_INLINE_DEF CLOSING _SYMB_16  */
#line 1425 "HAL_S.y"
                                             { (yyval.bit_inline_) = make_AGbit_prim((yyvsp[-2].bit_inline_def_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 7738 "Parser.c"
    break;

  case 596: /* BIT_INLINE: BIT_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1426 "HAL_S.y"
                                               { (yyval.bit_inline_) = make_AZbit_prim((yyvsp[-3].bit_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 7744 "Parser.c"
    break;

  case 597: /* BIT_INLINE_DEF: _SYMB_86 BIT_SPEC _SYMB_16  */
#line 1428 "HAL_S.y"
                                            { (yyval.bit_inline_def_) = make_AAbit_inline_def((yyvsp[-1].bit_spec_)); (yyval.bit_inline_def_)->line_number = (yyloc).first_line; (yyval.bit_inline_def_)->char_number = (yyloc).first_column;  }
#line 7750 "Parser.c"
    break;

  case 598: /* CHAR_INLINE: CHAR_INLINE_DEF CLOSING _SYMB_16  */
#line 1430 "HAL_S.y"
                                               { (yyval.char_inline_) = make_ADchar_prim((yyvsp[-2].char_inline_def_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 7756 "Parser.c"
    break;

  case 599: /* CHAR_INLINE: CHAR_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1431 "HAL_S.y"
                                                { (yyval.char_inline_) = make_AZchar_prim((yyvsp[-3].char_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 7762 "Parser.c"
    break;

  case 600: /* CHAR_INLINE_DEF: _SYMB_86 CHAR_SPEC _SYMB_16  */
#line 1433 "HAL_S.y"
                                              { (yyval.char_inline_def_) = make_AAchar_inline_def((yyvsp[-1].char_spec_)); (yyval.char_inline_def_)->line_number = (yyloc).first_line; (yyval.char_inline_def_)->char_number = (yyloc).first_column;  }
#line 7768 "Parser.c"
    break;

  case 601: /* STRUC_INLINE_DEF: _SYMB_86 STRUCT_SPEC _SYMB_16  */
#line 1435 "HAL_S.y"
                                                 { (yyval.struc_inline_def_) = make_AAstruc_inline_def((yyvsp[-1].struct_spec_)); (yyval.struc_inline_def_)->line_number = (yyloc).first_line; (yyval.struc_inline_def_)->char_number = (yyloc).first_column;  }
#line 7774 "Parser.c"
    break;


#line 7778 "Parser.c"

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

