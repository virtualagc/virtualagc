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
  IDENTIFIER identifier_;
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
  ARITH_CONV arith_conv_;
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
  DECLARE_BODY declare_body_;
  DECLARATION_LIST declaration_list_;
  CONSTANT constant_;
  ATTRIBUTES attributes_;
  ARRAY_SPEC array_spec_;
  ARRAY_HEAD array_head_;
  TYPE_AND_MINOR_ATTR type_and_minor_attr_;
  MINOR_ATTR_LIST minor_attr_list_;
  MINOR_ATTRIBUTE minor_attribute_;
  INIT_OR_CONST_HEAD init_or_const_head_;
  REPEATED_CONSTANT repeated_constant_;
  REPEAT_HEAD repeat_head_;
  NESTED_REPEAT_HEAD nested_repeat_head_;
  DECLARATION declaration_;
  NAME_ID name_id_;
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
  SQ_DQ_NAME sq_dq_name_;
  DOUBLY_QUAL_NAME_HEAD doubly_qual_name_head_;
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
  YYSYMBOL_ARITH_EXP = 201,                /* ARITH_EXP  */
  YYSYMBOL_TERM = 202,                     /* TERM  */
  YYSYMBOL_PLUS = 203,                     /* PLUS  */
  YYSYMBOL_MINUS = 204,                    /* MINUS  */
  YYSYMBOL_PRODUCT = 205,                  /* PRODUCT  */
  YYSYMBOL_FACTOR = 206,                   /* FACTOR  */
  YYSYMBOL_EXPONENTIATION = 207,           /* EXPONENTIATION  */
  YYSYMBOL_PRIMARY = 208,                  /* PRIMARY  */
  YYSYMBOL_ARITH_VAR = 209,                /* ARITH_VAR  */
  YYSYMBOL_PRE_PRIMARY = 210,              /* PRE_PRIMARY  */
  YYSYMBOL_NUMBER = 211,                   /* NUMBER  */
  YYSYMBOL_LEVEL = 212,                    /* LEVEL  */
  YYSYMBOL_COMPOUND_NUMBER = 213,          /* COMPOUND_NUMBER  */
  YYSYMBOL_SIMPLE_NUMBER = 214,            /* SIMPLE_NUMBER  */
  YYSYMBOL_MODIFIED_ARITH_FUNC = 215,      /* MODIFIED_ARITH_FUNC  */
  YYSYMBOL_ARITH_FUNC_HEAD = 216,          /* ARITH_FUNC_HEAD  */
  YYSYMBOL_CALL_LIST = 217,                /* CALL_LIST  */
  YYSYMBOL_LIST_EXP = 218,                 /* LIST_EXP  */
  YYSYMBOL_EXPRESSION = 219,               /* EXPRESSION  */
  YYSYMBOL_ARITH_ID = 220,                 /* ARITH_ID  */
  YYSYMBOL_IDENTIFIER = 221,               /* IDENTIFIER  */
  YYSYMBOL_NO_ARG_ARITH_FUNC = 222,        /* NO_ARG_ARITH_FUNC  */
  YYSYMBOL_ARITH_FUNC = 223,               /* ARITH_FUNC  */
  YYSYMBOL_SUBSCRIPT = 224,                /* SUBSCRIPT  */
  YYSYMBOL_QUALIFIER = 225,                /* QUALIFIER  */
  YYSYMBOL_SCALE_HEAD = 226,               /* SCALE_HEAD  */
  YYSYMBOL_PREC_SPEC = 227,                /* PREC_SPEC  */
  YYSYMBOL_SUB_START = 228,                /* SUB_START  */
  YYSYMBOL_SUB_HEAD = 229,                 /* SUB_HEAD  */
  YYSYMBOL_SUB = 230,                      /* SUB  */
  YYSYMBOL_SUB_RUN_HEAD = 231,             /* SUB_RUN_HEAD  */
  YYSYMBOL_SUB_EXP = 232,                  /* SUB_EXP  */
  YYSYMBOL_POUND_EXPRESSION = 233,         /* POUND_EXPRESSION  */
  YYSYMBOL_ARITH_CONV = 234,               /* ARITH_CONV  */
  YYSYMBOL_BIT_EXP = 235,                  /* BIT_EXP  */
  YYSYMBOL_BIT_FACTOR = 236,               /* BIT_FACTOR  */
  YYSYMBOL_BIT_CAT = 237,                  /* BIT_CAT  */
  YYSYMBOL_OR = 238,                       /* OR  */
  YYSYMBOL_CHAR_VERTICAL_BAR = 239,        /* CHAR_VERTICAL_BAR  */
  YYSYMBOL_AND = 240,                      /* AND  */
  YYSYMBOL_BIT_PRIM = 241,                 /* BIT_PRIM  */
  YYSYMBOL_CAT = 242,                      /* CAT  */
  YYSYMBOL_NOT = 243,                      /* NOT  */
  YYSYMBOL_BIT_VAR = 244,                  /* BIT_VAR  */
  YYSYMBOL_LABEL_VAR = 245,                /* LABEL_VAR  */
  YYSYMBOL_EVENT_VAR = 246,                /* EVENT_VAR  */
  YYSYMBOL_BIT_CONST_HEAD = 247,           /* BIT_CONST_HEAD  */
  YYSYMBOL_BIT_CONST = 248,                /* BIT_CONST  */
  YYSYMBOL_RADIX = 249,                    /* RADIX  */
  YYSYMBOL_CHAR_STRING = 250,              /* CHAR_STRING  */
  YYSYMBOL_SUBBIT_HEAD = 251,              /* SUBBIT_HEAD  */
  YYSYMBOL_SUBBIT_KEY = 252,               /* SUBBIT_KEY  */
  YYSYMBOL_BIT_FUNC_HEAD = 253,            /* BIT_FUNC_HEAD  */
  YYSYMBOL_BIT_ID = 254,                   /* BIT_ID  */
  YYSYMBOL_LABEL = 255,                    /* LABEL  */
  YYSYMBOL_BIT_FUNC = 256,                 /* BIT_FUNC  */
  YYSYMBOL_EVENT = 257,                    /* EVENT  */
  YYSYMBOL_SUB_OR_QUALIFIER = 258,         /* SUB_OR_QUALIFIER  */
  YYSYMBOL_BIT_QUALIFIER = 259,            /* BIT_QUALIFIER  */
  YYSYMBOL_CHAR_EXP = 260,                 /* CHAR_EXP  */
  YYSYMBOL_CHAR_PRIM = 261,                /* CHAR_PRIM  */
  YYSYMBOL_CHAR_FUNC_HEAD = 262,           /* CHAR_FUNC_HEAD  */
  YYSYMBOL_CHAR_VAR = 263,                 /* CHAR_VAR  */
  YYSYMBOL_CHAR_CONST = 264,               /* CHAR_CONST  */
  YYSYMBOL_CHAR_FUNC = 265,                /* CHAR_FUNC  */
  YYSYMBOL_CHAR_ID = 266,                  /* CHAR_ID  */
  YYSYMBOL_NAME_EXP = 267,                 /* NAME_EXP  */
  YYSYMBOL_NAME_KEY = 268,                 /* NAME_KEY  */
  YYSYMBOL_NAME_VAR = 269,                 /* NAME_VAR  */
  YYSYMBOL_VARIABLE = 270,                 /* VARIABLE  */
  YYSYMBOL_STRUCTURE_EXP = 271,            /* STRUCTURE_EXP  */
  YYSYMBOL_STRUCT_FUNC_HEAD = 272,         /* STRUCT_FUNC_HEAD  */
  YYSYMBOL_STRUCTURE_VAR = 273,            /* STRUCTURE_VAR  */
  YYSYMBOL_STRUCT_FUNC = 274,              /* STRUCT_FUNC  */
  YYSYMBOL_QUAL_STRUCT = 275,              /* QUAL_STRUCT  */
  YYSYMBOL_STRUCTURE_ID = 276,             /* STRUCTURE_ID  */
  YYSYMBOL_ASSIGNMENT = 277,               /* ASSIGNMENT  */
  YYSYMBOL_EQUALS = 278,                   /* EQUALS  */
  YYSYMBOL_IF_STATEMENT = 279,             /* IF_STATEMENT  */
  YYSYMBOL_IF_CLAUSE = 280,                /* IF_CLAUSE  */
  YYSYMBOL_TRUE_PART = 281,                /* TRUE_PART  */
  YYSYMBOL_IF = 282,                       /* IF  */
  YYSYMBOL_THEN = 283,                     /* THEN  */
  YYSYMBOL_RELATIONAL_EXP = 284,           /* RELATIONAL_EXP  */
  YYSYMBOL_RELATIONAL_FACTOR = 285,        /* RELATIONAL_FACTOR  */
  YYSYMBOL_REL_PRIM = 286,                 /* REL_PRIM  */
  YYSYMBOL_COMPARISON = 287,               /* COMPARISON  */
  YYSYMBOL_RELATIONAL_OP = 288,            /* RELATIONAL_OP  */
  YYSYMBOL_STATEMENT = 289,                /* STATEMENT  */
  YYSYMBOL_BASIC_STATEMENT = 290,          /* BASIC_STATEMENT  */
  YYSYMBOL_OTHER_STATEMENT = 291,          /* OTHER_STATEMENT  */
  YYSYMBOL_ANY_STATEMENT = 292,            /* ANY_STATEMENT  */
  YYSYMBOL_ON_PHRASE = 293,                /* ON_PHRASE  */
  YYSYMBOL_ON_CLAUSE = 294,                /* ON_CLAUSE  */
  YYSYMBOL_LABEL_DEFINITION = 295,         /* LABEL_DEFINITION  */
  YYSYMBOL_CALL_KEY = 296,                 /* CALL_KEY  */
  YYSYMBOL_ASSIGN = 297,                   /* ASSIGN  */
  YYSYMBOL_CALL_ASSIGN_LIST = 298,         /* CALL_ASSIGN_LIST  */
  YYSYMBOL_DO_GROUP_HEAD = 299,            /* DO_GROUP_HEAD  */
  YYSYMBOL_ENDING = 300,                   /* ENDING  */
  YYSYMBOL_READ_KEY = 301,                 /* READ_KEY  */
  YYSYMBOL_WRITE_KEY = 302,                /* WRITE_KEY  */
  YYSYMBOL_READ_PHRASE = 303,              /* READ_PHRASE  */
  YYSYMBOL_WRITE_PHRASE = 304,             /* WRITE_PHRASE  */
  YYSYMBOL_READ_ARG = 305,                 /* READ_ARG  */
  YYSYMBOL_WRITE_ARG = 306,                /* WRITE_ARG  */
  YYSYMBOL_FILE_EXP = 307,                 /* FILE_EXP  */
  YYSYMBOL_FILE_HEAD = 308,                /* FILE_HEAD  */
  YYSYMBOL_IO_CONTROL = 309,               /* IO_CONTROL  */
  YYSYMBOL_WAIT_KEY = 310,                 /* WAIT_KEY  */
  YYSYMBOL_TERMINATOR = 311,               /* TERMINATOR  */
  YYSYMBOL_TERMINATE_LIST = 312,           /* TERMINATE_LIST  */
  YYSYMBOL_SCHEDULE_HEAD = 313,            /* SCHEDULE_HEAD  */
  YYSYMBOL_SCHEDULE_PHRASE = 314,          /* SCHEDULE_PHRASE  */
  YYSYMBOL_SCHEDULE_CONTROL = 315,         /* SCHEDULE_CONTROL  */
  YYSYMBOL_TIMING = 316,                   /* TIMING  */
  YYSYMBOL_REPEAT = 317,                   /* REPEAT  */
  YYSYMBOL_STOPPING = 318,                 /* STOPPING  */
  YYSYMBOL_SIGNAL_CLAUSE = 319,            /* SIGNAL_CLAUSE  */
  YYSYMBOL_PERCENT_MACRO_NAME = 320,       /* PERCENT_MACRO_NAME  */
  YYSYMBOL_PERCENT_MACRO_HEAD = 321,       /* PERCENT_MACRO_HEAD  */
  YYSYMBOL_PERCENT_MACRO_ARG = 322,        /* PERCENT_MACRO_ARG  */
  YYSYMBOL_CASE_ELSE = 323,                /* CASE_ELSE  */
  YYSYMBOL_WHILE_KEY = 324,                /* WHILE_KEY  */
  YYSYMBOL_WHILE_CLAUSE = 325,             /* WHILE_CLAUSE  */
  YYSYMBOL_FOR_LIST = 326,                 /* FOR_LIST  */
  YYSYMBOL_ITERATION_BODY = 327,           /* ITERATION_BODY  */
  YYSYMBOL_ITERATION_CONTROL = 328,        /* ITERATION_CONTROL  */
  YYSYMBOL_FOR_KEY = 329,                  /* FOR_KEY  */
  YYSYMBOL_TEMPORARY_STMT = 330,           /* TEMPORARY_STMT  */
  YYSYMBOL_DECLARE_BODY = 331,             /* DECLARE_BODY  */
  YYSYMBOL_DECLARATION_LIST = 332,         /* DECLARATION_LIST  */
  YYSYMBOL_CONSTANT = 333,                 /* CONSTANT  */
  YYSYMBOL_ATTRIBUTES = 334,               /* ATTRIBUTES  */
  YYSYMBOL_ARRAY_SPEC = 335,               /* ARRAY_SPEC  */
  YYSYMBOL_ARRAY_HEAD = 336,               /* ARRAY_HEAD  */
  YYSYMBOL_TYPE_AND_MINOR_ATTR = 337,      /* TYPE_AND_MINOR_ATTR  */
  YYSYMBOL_MINOR_ATTR_LIST = 338,          /* MINOR_ATTR_LIST  */
  YYSYMBOL_MINOR_ATTRIBUTE = 339,          /* MINOR_ATTRIBUTE  */
  YYSYMBOL_INIT_OR_CONST_HEAD = 340,       /* INIT_OR_CONST_HEAD  */
  YYSYMBOL_REPEATED_CONSTANT = 341,        /* REPEATED_CONSTANT  */
  YYSYMBOL_REPEAT_HEAD = 342,              /* REPEAT_HEAD  */
  YYSYMBOL_NESTED_REPEAT_HEAD = 343,       /* NESTED_REPEAT_HEAD  */
  YYSYMBOL_DECLARATION = 344,              /* DECLARATION  */
  YYSYMBOL_NAME_ID = 345,                  /* NAME_ID  */
  YYSYMBOL_DCL_LIST_COMMA = 346,           /* DCL_LIST_COMMA  */
  YYSYMBOL_LITERAL_EXP_OR_STAR = 347,      /* LITERAL_EXP_OR_STAR  */
  YYSYMBOL_TYPE_SPEC = 348,                /* TYPE_SPEC  */
  YYSYMBOL_BIT_SPEC = 349,                 /* BIT_SPEC  */
  YYSYMBOL_CHAR_SPEC = 350,                /* CHAR_SPEC  */
  YYSYMBOL_STRUCT_SPEC = 351,              /* STRUCT_SPEC  */
  YYSYMBOL_STRUCT_SPEC_BODY = 352,         /* STRUCT_SPEC_BODY  */
  YYSYMBOL_STRUCT_TEMPLATE = 353,          /* STRUCT_TEMPLATE  */
  YYSYMBOL_STRUCT_SPEC_HEAD = 354,         /* STRUCT_SPEC_HEAD  */
  YYSYMBOL_ARITH_SPEC = 355,               /* ARITH_SPEC  */
  YYSYMBOL_SQ_DQ_NAME = 356,               /* SQ_DQ_NAME  */
  YYSYMBOL_DOUBLY_QUAL_NAME_HEAD = 357,    /* DOUBLY_QUAL_NAME_HEAD  */
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
#define YYLAST   7234

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
       0,   645,   645,   646,   647,   648,   649,   651,   652,   654,
     656,   658,   659,   660,   661,   663,   664,   666,   668,   669,
     670,   671,   673,   674,   675,   676,   677,   678,   679,   680,
     682,   683,   684,   685,   686,   688,   689,   691,   693,   695,
     697,   698,   699,   700,   702,   703,   705,   706,   708,   709,
     710,   712,   713,   714,   715,   716,   718,   719,   721,   723,
     724,   725,   726,   727,   728,   730,   731,   732,   733,   734,
     735,   736,   737,   738,   739,   740,   741,   742,   743,   744,
     745,   746,   747,   748,   749,   750,   751,   752,   753,   754,
     755,   756,   757,   758,   759,   760,   761,   762,   763,   764,
     765,   766,   767,   768,   769,   770,   771,   772,   773,   774,
     775,   776,   778,   779,   780,   781,   783,   784,   785,   786,
     788,   789,   791,   792,   794,   795,   796,   797,   798,   800,
     801,   803,   804,   805,   806,   808,   810,   811,   813,   814,
     815,   817,   818,   819,   820,   822,   823,   825,   826,   828,
     829,   830,   831,   833,   834,   836,   838,   839,   841,   842,
     843,   844,   845,   846,   847,   848,   849,   850,   851,   853,
     854,   856,   857,   858,   859,   861,   862,   863,   864,   866,
     867,   868,   869,   871,   872,   873,   874,   876,   877,   879,
     880,   881,   882,   883,   885,   886,   887,   888,   890,   892,
     893,   895,   897,   898,   899,   901,   903,   904,   905,   906,
     908,   909,   911,   913,   914,   916,   918,   919,   920,   921,
     922,   924,   925,   926,   927,   929,   930,   932,   933,   934,
     935,   937,   938,   940,   941,   942,   943,   944,   946,   948,
     949,   950,   952,   954,   955,   956,   958,   959,   960,   961,
     962,   963,   964,   966,   967,   968,   969,   971,   973,   975,
     977,   978,   980,   982,   983,   984,   985,   987,   989,   990,
     992,   993,   995,   997,   999,  1001,  1002,  1004,  1005,  1007,
    1008,  1009,  1011,  1012,  1013,  1014,  1015,  1017,  1018,  1019,
    1020,  1021,  1022,  1023,  1024,  1026,  1027,  1028,  1030,  1031,
    1032,  1033,  1034,  1035,  1036,  1037,  1038,  1039,  1040,  1041,
    1042,  1043,  1044,  1045,  1046,  1047,  1048,  1049,  1050,  1051,
    1052,  1053,  1054,  1055,  1056,  1057,  1058,  1059,  1060,  1061,
    1062,  1063,  1064,  1065,  1066,  1067,  1068,  1069,  1070,  1072,
    1073,  1074,  1076,  1077,  1079,  1080,  1082,  1083,  1084,  1085,
    1087,  1089,  1091,  1093,  1094,  1095,  1096,  1098,  1099,  1100,
    1101,  1102,  1103,  1104,  1105,  1107,  1108,  1109,  1111,  1112,
    1114,  1116,  1117,  1119,  1120,  1122,  1123,  1125,  1126,  1127,
    1129,  1131,  1133,  1134,  1135,  1136,  1137,  1139,  1141,  1142,
    1144,  1145,  1147,  1148,  1149,  1150,  1152,  1153,  1154,  1156,
    1157,  1158,  1160,  1161,  1162,  1164,  1166,  1167,  1169,  1170,
    1171,  1173,  1175,  1176,  1178,  1179,  1181,  1183,  1184,  1186,
    1187,  1189,  1190,  1192,  1193,  1195,  1196,  1198,  1199,  1201,
    1203,  1204,  1206,  1207,  1209,  1210,  1211,  1212,  1214,  1215,
    1216,  1218,  1219,  1220,  1221,  1222,  1224,  1225,  1227,  1228,
    1229,  1231,  1232,  1234,  1235,  1236,  1237,  1238,  1239,  1240,
    1241,  1242,  1243,  1244,  1245,  1247,  1248,  1249,  1251,  1252,
    1253,  1254,  1255,  1257,  1259,  1260,  1262,  1263,  1264,  1265,
    1266,  1267,  1268,  1269,  1271,  1272,  1273,  1274,  1275,  1276,
    1277,  1278,  1280,  1282,  1283,  1285,  1286,  1287,  1288,  1289,
    1291,  1292,  1294,  1296,  1298,  1299,  1301,  1303,  1305,  1306,
    1307,  1309,  1310,  1312,  1313,  1315,  1316,  1317,  1318,  1319,
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
  "ARITH_EXP", "TERM", "PLUS", "MINUS", "PRODUCT", "FACTOR",
  "EXPONENTIATION", "PRIMARY", "ARITH_VAR", "PRE_PRIMARY", "NUMBER",
  "LEVEL", "COMPOUND_NUMBER", "SIMPLE_NUMBER", "MODIFIED_ARITH_FUNC",
  "ARITH_FUNC_HEAD", "CALL_LIST", "LIST_EXP", "EXPRESSION", "ARITH_ID",
  "IDENTIFIER", "NO_ARG_ARITH_FUNC", "ARITH_FUNC", "SUBSCRIPT",
  "QUALIFIER", "SCALE_HEAD", "PREC_SPEC", "SUB_START", "SUB_HEAD", "SUB",
  "SUB_RUN_HEAD", "SUB_EXP", "POUND_EXPRESSION", "ARITH_CONV", "BIT_EXP",
  "BIT_FACTOR", "BIT_CAT", "OR", "CHAR_VERTICAL_BAR", "AND", "BIT_PRIM",
  "CAT", "NOT", "BIT_VAR", "LABEL_VAR", "EVENT_VAR", "BIT_CONST_HEAD",
  "BIT_CONST", "RADIX", "CHAR_STRING", "SUBBIT_HEAD", "SUBBIT_KEY",
  "BIT_FUNC_HEAD", "BIT_ID", "LABEL", "BIT_FUNC", "EVENT",
  "SUB_OR_QUALIFIER", "BIT_QUALIFIER", "CHAR_EXP", "CHAR_PRIM",
  "CHAR_FUNC_HEAD", "CHAR_VAR", "CHAR_CONST", "CHAR_FUNC", "CHAR_ID",
  "NAME_EXP", "NAME_KEY", "NAME_VAR", "VARIABLE", "STRUCTURE_EXP",
  "STRUCT_FUNC_HEAD", "STRUCTURE_VAR", "STRUCT_FUNC", "QUAL_STRUCT",
  "STRUCTURE_ID", "ASSIGNMENT", "EQUALS", "IF_STATEMENT", "IF_CLAUSE",
  "TRUE_PART", "IF", "THEN", "RELATIONAL_EXP", "RELATIONAL_FACTOR",
  "REL_PRIM", "COMPARISON", "RELATIONAL_OP", "STATEMENT",
  "BASIC_STATEMENT", "OTHER_STATEMENT", "ANY_STATEMENT", "ON_PHRASE",
  "ON_CLAUSE", "LABEL_DEFINITION", "CALL_KEY", "ASSIGN",
  "CALL_ASSIGN_LIST", "DO_GROUP_HEAD", "ENDING", "READ_KEY", "WRITE_KEY",
  "READ_PHRASE", "WRITE_PHRASE", "READ_ARG", "WRITE_ARG", "FILE_EXP",
  "FILE_HEAD", "IO_CONTROL", "WAIT_KEY", "TERMINATOR", "TERMINATE_LIST",
  "SCHEDULE_HEAD", "SCHEDULE_PHRASE", "SCHEDULE_CONTROL", "TIMING",
  "REPEAT", "STOPPING", "SIGNAL_CLAUSE", "PERCENT_MACRO_NAME",
  "PERCENT_MACRO_HEAD", "PERCENT_MACRO_ARG", "CASE_ELSE", "WHILE_KEY",
  "WHILE_CLAUSE", "FOR_LIST", "ITERATION_BODY", "ITERATION_CONTROL",
  "FOR_KEY", "TEMPORARY_STMT", "DECLARE_BODY", "DECLARATION_LIST",
  "CONSTANT", "ATTRIBUTES", "ARRAY_SPEC", "ARRAY_HEAD",
  "TYPE_AND_MINOR_ATTR", "MINOR_ATTR_LIST", "MINOR_ATTRIBUTE",
  "INIT_OR_CONST_HEAD", "REPEATED_CONSTANT", "REPEAT_HEAD",
  "NESTED_REPEAT_HEAD", "DECLARATION", "NAME_ID", "DCL_LIST_COMMA",
  "LITERAL_EXP_OR_STAR", "TYPE_SPEC", "BIT_SPEC", "CHAR_SPEC",
  "STRUCT_SPEC", "STRUCT_SPEC_BODY", "STRUCT_TEMPLATE", "STRUCT_SPEC_HEAD",
  "ARITH_SPEC", "SQ_DQ_NAME", "DOUBLY_QUAL_NAME_HEAD", "COMPILATION",
  "BLOCK_DEFINITION", "BLOCK_STMT", "BLOCK_STMT_TOP", "BLOCK_STMT_HEAD",
  "LABEL_EXTERNAL", "CLOSING", "BLOCK_BODY", "FUNCTION_NAME",
  "PROCEDURE_NAME", "FUNC_STMT_BODY", "PROC_STMT_BODY", "DECLARE_GROUP",
  "DECLARE_ELEMENT", "PARAMETER", "PARAMETER_LIST", "PARAMETER_HEAD",
  "DECLARE_STATEMENT", "ASSIGN_LIST", "TEXT", "REPLACE_STMT",
  "REPLACE_HEAD", "ARG_LIST", "STRUCTURE_STMT", "STRUCT_STMT_HEAD",
  "STRUCT_STMT_TAIL", "INLINE_DEFINITION", "ARITH_INLINE",
  "ARITH_INLINE_DEF", "BIT_INLINE", "BIT_INLINE_DEF", "CHAR_INLINE",
  "CHAR_INLINE_DEF", "STRUC_INLINE_DEF", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-760)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-380)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
    5651,  -106,   -48,  -760,   -32,   839,  -760,  6875,   515,   102,
     165,  1014,    29,  -760,  -760,   120,   203,   307,   327,   110,
     -32,    31,  2378,   839,   228,    31,    31,   -48,  -760,  -760,
     214,  -760,   375,  -760,  -760,  -760,  -760,  -760,   387,  -760,
    -760,  -760,  -760,  -760,   384,  -760,  -760,  -760,   759,    82,
     384,   396,   384,  -760,   384,   447,    98,  -760,   463,   170,
    -760,   290,  -760,   460,  -760,  6328,  6328,  2963,  -760,  -760,
    -760,  -760,  6328,   185,  6086,   406,  5793,  1478,  1988,   309,
     472,   471,   544,  3914,    61,   283,    44,   501,   205,  5231,
    6328,  4754,  -760,  5509,    78,     9,   271,   940,   129,  -760,
     541,  -760,  -760,  -760,  5509,  -760,  5509,  -760,  5509,  5509,
     578,   253,  -760,  -760,  -760,   384,   590,  -760,  -760,   593,
    -760,   599,  -760,   607,   610,  -760,  -760,  -760,  -760,   625,
    -760,  -760,   636,   638,   647,  -760,  -760,  -760,  -760,  -760,
    -760,  -760,  -760,   649,  -760,  -760,   637,  -760,   538,  4091,
     547,  -760,  -760,  -760,  -760,  -760,   653,   655,   657,  7045,
    4285,  -760,  4900,  -760,  2573,  -760,  6975,  1615,  4900,  -760,
    -760,  -760,   670,  -760,   -22,  4285,  -760,  4623,   300,  -760,
    -760,  2963,   660,    55,  4623,  -760,   665,    41,  -760,   674,
     686,   692,   696,   676,   440,   117,    41,    41,  -760,   699,
     717,   642,  -760,   723,  -760,  -760,  3353,   324,   379,  -760,
    -760,  -760,  -760,  -760,  -760,  -760,  -760,  -760,  -760,  -760,
    -760,  -760,  -760,   320,  -760,   725,   320,  -760,  -760,  -760,
    -760,  -760,  -760,  -760,  -760,  -760,  -760,  -760,   -48,  -760,
    -760,   719,  -760,  -760,  -760,  -760,   722,  -760,  -760,  -760,
    -760,  -760,  -760,  -760,  -760,  -760,  -760,  -760,  -760,  -760,
    -760,  -760,  -760,  -760,  -760,   728,  -760,  -760,  -760,  -760,
    -760,  -760,  -760,  -760,  -760,  -760,  -760,  -760,  -760,  -760,
    -760,  -760,  -760,  -760,  -760,   739,   741,   743,  -760,  -760,
    -760,  -760,   742,  -760,  5086,  5086,   755,  4918,   747,  -760,
     746,  -760,  -760,  -760,  -760,  -760,   762,   757,   384,  -760,
     384,    60,   190,   126,  -760,  5422,  -760,  -760,  -760,   585,
    -760,   773,  -760,  3158,   775,  -760,   126,  -760,   779,  -760,
    -760,  -760,  -760,   789,  -760,  -760,   381,  -760,   518,  -760,
    -760,  1588,  1615,   694,    41,   133,  -760,  -760,  4109,   920,
     790,  -760,   416,  -760,   793,  -760,  -760,  -760,  -760,  6716,
     759,  -760,  2768,  3158,   924,   759,  -760,  3158,  -760,   214,
    -760,   737,  6621,  -760,  2963,  1937,    74,  1947,  5435,  1947,
    1032,  1032,    74,   190,  -760,  -760,  -760,  -760,   195,  -760,
    -760,   214,  -760,  -760,  3158,  -760,  -760,   798,   676,  6875,
    -760,  5879,   810,  -760,  -760,   827,   838,   861,   866,   869,
    -760,  -760,  -760,  -760,   478,  -760,  -760,  -760,  1338,  -760,
    2183,  -760,  3158,  4623,  4623,  5278,  4623,   743,   408,   824,
    -760,  -760,   491,  4623,  4623,  5361,   872,   707,  -760,  -760,
     871,   402,    83,  -760,  3548,  -760,  -760,  -760,  -760,  -760,
    -760,  -760,  -760,  -760,  -760,  -760,   279,  -760,  -760,  -760,
    -760,  -760,   877,  -760,   676,   813,  -760,  6000,   879,  6207,
     224,  -760,  -760,   886,  -760,  -760,  -760,  -760,  -760,  -760,
    -760,  -760,  -760,  -760,  -760,  -760,  -760,  1295,   780,   899,
    -760,   867,  -760,  -760,   897,  6207,   901,  6207,   923,  6207,
     929,  6207,   384,   -48,   384,  -760,   839,  -760,  4285,  4285,
    -760,  -760,  4285,  4285,   794,  -760,  4900,  4900,  4900,  -760,
    -760,  -760,  1615,  -760,  -760,   621,   698,  -760,   959,   752,
    -760,   711,  1719,  3158,  -760,  -760,  -760,  4900,   778,  -760,
    4285,  -760,   983,   500,   -32,   471,   989,    60,    60,  -760,
    -760,   979,    97,  1007,  -760,  -760,  -760,  -760,  -760,  -760,
    1012,  -760,  1020,  -760,  -760,   -29,  1031,  1040,  -760,   -32,
     850,    31,   371,   143,   134,  1044,  1039,  1048,  1052,   535,
    1053,  -760,  -760,  -760,    41,  -760,  3158,  -760,  -760,  5086,
    5086,  3738,  -760,  -760,  5086,  5086,  5086,  -760,  -760,  5086,
    1060,  -760,  3158,  -760,  -760,  -760,  -760,  -760,  5361,  -760,
    -760,  -760,  5361,  5361,  5361,   379,   379,  -760,  1064,  -760,
      41,  1063,  3158,  3738,  3158,  6631,  1091,  -760,  1056,   794,
    1727,   503,  -760,  4623,   906,  1067,  1061,  -760,  -760,  -760,
    -760,   344,  -760,  4454,   911,   621,  -760,  -760,  -760,  -760,
    -760,  -760,  1075,    98,  -760,  -760,  1068,   811,   750,  -760,
    -760,   381,   384,   384,   384,   384,  -760,  -760,  -760,  -760,
     956,  4106,   146,  -760,  -760,  -760,  -760,   898,  -760,  4623,
    -760,  -760,  5361,  2963,  3738,   526,    22,  2963,  -760,  2963,
    1072,   834,   759,  -760,  1077,  6414,  -760,  -760,  4623,  4623,
    4623,  4623,  4623,  -760,  -760,  1080,   422,   571,   594,  1084,
      63,   520,  -760,  1438,   839,  -760,   621,   621,    60,  4623,
    -760,  -760,  -760,  4623,  4623,  3548,   621,    60,  1079,  1085,
    -760,  -760,  -760,   -32,  6535,  -760,  -760,  -760,  1088,  -760,
    -760,  -760,  -760,  -760,  -760,  -760,  -760,  -760,   841,  -760,
    -760,  -760,  1090,  -760,  1094,  -760,  1099,  -760,  1102,  -760,
    -760,   384,  1100,  1115,  1116,  1118,  1123,  4900,  4900,   655,
    -760,  -760,  -760,   938,  -760,  -760,  -760,  -760,  -760,   934,
    1127,  1128,  -760,  1062,  1109,  -760,   509,  -760,  4623,  -760,
    4623,  -760,  -760,  -760,  -760,  -760,  -760,  -760,   946,  -760,
    -760,  -760,  -760,  -760,   384,   379,   384,  1131,  1133,   964,
    -760,  -760,  3738,  -760,   621,  -760,  1134,  -760,  -760,  -760,
    -760,  1132,   967,   190,   126,  -760,  5422,  1103,  1139,  -760,
     978,   621,  -760,   993,  1143,  1144,   384,  -760,  -760,   794,
     794,  -760,   568,  4623,  -760,   534,  4623,  4454,   621,  -760,
    -760,  5086,  5086,  -760,  3158,  -760,  3158,  -760,  3158,  -760,
    -760,  -760,  -760,  -760,  -760,  -760,  -760,   621,   126,   149,
     742,   126,  -760,  -760,  -760,   468,  1947,   190,  -760,  -760,
     132,  -760,   416,   998,  -760,   787,   822,   882,   884,   902,
    -760,  -760,  -760,  -760,  -760,  -760,  -760,   918,   621,   621,
    1763,  -760,   985,  -760,  -760,  -760,  -760,  -760,  -760,  -760,
    -760,  -760,  -760,  -760,  -760,  -760,  -760,  -760,  -760,  -760,
    -760,  -760,  -760,   182,   621,  -760,   -32,  -760,  -760,  1138,
     585,  -760,  1386,   534,  -760,  -760,  -760,  -760,  -760,  -760,
    -760,  -760,  -760,  -760,  -760,   685,  -760,  1000,  1148,   949,
    -760,  -760,  -760,  -760,  -760,  -760,  -760,  1151,  1142,   759,
    -760,  -760,  -760,  -760,  -760,  -760,   759,  4623,  -760,   609,
    -760,  1033,  -760,  -760,  1146,  -760,  -760,   759,  -760,  -760,
     416,  1147,   621,  1152,  1146,  1150,  4623,  1036,  -760,  -760,
     997,  1154,  -760,  -760
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int16 yydefact[] =
{
       0,     0,     0,   305,     0,     0,   389,     0,     0,     0,
       0,     0,     0,   273,   242,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   201,   388,
     535,   387,     0,   205,   207,   208,   238,   262,   209,   206,
     212,    57,    58,   246,    22,    56,   247,   251,     0,     0,
     175,     0,   183,   249,   227,     0,     0,   587,     0,   253,
     257,     0,   260,     0,   339,     0,     0,     0,   342,   295,
     296,   515,     0,     0,   540,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   396,     0,     0,     0,     0,
       0,     0,   343,     0,     0,   528,     0,   536,   538,   517,
       0,   519,   297,   584,     0,   585,     0,   586,     0,     0,
       0,     0,   411,   209,   351,   179,     0,   457,   456,     0,
     454,     0,   500,     0,     0,   455,   123,   499,   442,     0,
     141,   463,     0,   144,     0,   443,   444,   459,   460,   142,
     122,   453,   445,   143,   488,   489,   490,   491,     0,   482,
     484,   508,   512,   486,   487,   506,     0,   430,     0,   439,
       0,   440,   450,   451,     0,   432,   476,     0,   448,   496,
     497,   495,     0,   498,   509,     0,   357,     0,     0,   418,
     417,     0,     0,     0,     0,   300,     0,     0,   591,     0,
       0,     0,     0,     0,     0,   345,     0,     0,   302,     0,
     575,     0,   409,     0,     9,    10,     0,     0,     0,   310,
     171,   173,   174,    66,    96,    78,    79,    80,    81,    83,
      82,    84,   196,   203,    67,     0,   237,    59,    85,    86,
      60,   197,    97,    68,    61,    87,   191,    69,     0,   194,
     101,   110,   103,   102,   233,    88,   100,   108,    70,   109,
      71,    65,   172,   240,   195,    72,   193,   192,    62,   105,
      63,    73,   234,    74,    64,   111,    94,    95,    75,    76,
      89,    90,   107,    91,   106,    92,    93,    98,   104,   235,
     190,    77,    99,   143,   210,   207,   208,   206,   198,    37,
      39,    38,    51,     2,     0,     0,     7,    11,    15,    18,
      19,    31,    36,    32,    35,    20,     0,     0,    40,    44,
       0,    52,   145,   147,   149,     0,   158,   159,   160,     0,
     161,   187,   231,     0,     0,   202,    53,   216,     0,   221,
     222,   225,    54,     0,    55,   253,     0,   392,     0,   408,
     410,     0,     0,     0,     0,     0,    23,   113,   129,     0,
       0,   252,     0,   199,     0,   176,   350,   184,   228,     0,
       0,   267,     0,     0,     0,     0,   258,     0,   298,     0,
     268,   295,     0,   269,     0,     0,     0,   147,     0,     0,
       0,     0,     0,   275,   277,   281,   340,   333,     0,   541,
     533,   534,   299,   341,     0,   306,   352,     0,   365,     0,
     363,   540,     0,   364,   313,     0,     0,     0,     0,     0,
     375,   371,   376,   315,   262,   377,   373,   378,     0,   314,
       0,   316,     0,     0,     0,     0,     0,     0,     0,     0,
     324,   390,     0,     0,     0,     0,     0,     0,   328,   398,
       0,   400,   404,   399,     0,   330,   412,   337,   434,   435,
     244,   245,   436,   437,   414,   243,     0,   415,   362,     1,
     516,   518,     0,   520,   542,     0,   546,   540,     0,     0,
     545,   556,   558,     0,   560,   525,   526,   527,   529,   530,
     532,   548,   549,   531,   569,   551,   537,   550,     0,     0,
     539,   553,   554,   521,     0,     0,     0,     0,     0,     0,
       0,     0,    24,     0,    26,   180,     0,   446,     0,     0,
     466,   465,     0,     0,     0,   513,   479,   480,   483,   485,
     571,   492,     0,   438,   494,   493,     0,   452,     0,    51,
     468,     0,   472,     0,   477,   490,   433,   449,     0,   503,
       0,   510,     0,     0,     0,     0,     0,   419,   420,   360,
     358,     0,   423,   422,   301,   381,   594,   597,   598,   590,
       0,   336,     0,   349,   348,   344,     0,     0,   303,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   213,   204,   214,     0,   226,     0,   169,   170,     0,
       0,     0,     3,     4,     0,     0,     0,    14,    17,     0,
       0,    21,     0,   311,    41,    45,   155,   154,     0,   153,
     156,   157,     0,     0,     0,     0,     0,   151,     0,   189,
       0,     0,     0,     0,     0,     0,     0,   332,     0,     0,
       0,     0,   579,     0,     0,     0,   124,   115,   114,   132,
     138,   136,   130,     0,   131,   137,   112,   128,   126,   127,
     248,   200,     0,     0,   264,   263,     0,    51,     0,    46,
      48,    50,    28,   177,   185,   229,   261,   266,   265,   272,
       0,     0,     0,   289,   290,   291,   292,     0,   287,     0,
     274,   271,     0,     0,     0,     0,     0,     0,   270,     0,
       0,     0,     0,   366,     0,     0,   367,   312,     0,     0,
       0,     0,     0,   372,   374,     0,     0,     0,     0,     0,
       0,     0,   321,     0,     0,   325,   393,   394,   395,     0,
     405,   329,   401,     0,     0,     0,   406,   407,     0,     0,
     413,   522,   543,     0,     0,   544,   523,   547,     0,   557,
     559,   552,   563,   564,   565,   567,   566,   562,     0,   572,
     555,   588,     0,   592,     0,   595,     0,   255,     0,    25,
      27,   181,     0,     0,     0,     0,     0,   478,   481,   431,
     441,   447,   462,     0,   461,   467,   474,   469,   470,     0,
     504,     0,   511,   361,     0,   427,     0,   359,     0,   421,
       0,   304,   335,   347,   346,   368,   369,   577,     0,   573,
     574,    30,   162,   224,   165,     0,   167,     0,     0,     0,
       5,     6,     0,   236,   219,   220,     0,     8,    12,    13,
      16,     0,     0,   146,   148,   150,     0,     0,     0,   163,
       0,   218,   217,     0,     0,     0,    42,   331,   580,     0,
       0,   583,     0,     0,   370,   120,     0,     0,   136,   133,
     135,     0,     0,   250,     0,   318,     0,   254,     0,    29,
     178,   186,   230,   279,   293,   294,   288,   282,   284,     0,
       0,   283,   286,   259,   285,     0,     0,   276,   278,   334,
       0,   353,   355,     0,   429,     0,     0,     0,     0,     0,
     317,   319,   380,   320,   323,   322,   391,     0,   403,   402,
       0,   338,     0,   524,   568,   570,   589,   593,   596,   256,
     182,   501,   502,   458,   514,   464,   473,   471,   475,   507,
     505,   416,   428,   425,   424,   576,     0,   166,   168,     0,
       0,    34,     0,   120,    33,   152,   188,   164,   223,   241,
     239,    43,   581,   582,   326,     0,   121,     0,     0,     0,
     134,   139,   140,    49,    47,   280,   307,     0,     0,     0,
     384,   385,   386,   382,   383,   397,     0,     0,   578,     0,
     232,     0,   327,   116,   125,   119,   117,     0,   308,   354,
     356,     0,   426,     0,     0,   120,     0,     0,   561,   215,
       0,     0,   118,   309
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -760,   758,  -255,   833,  1035,  -239,   572,  -760,  -760,   373,
    -760,    87,  -485,   -73,   397,   -80,  -760,  -315,   318,    21,
       2,    37,  -580,  -760,  1049,   878,  -496,  -170,  -760,  -760,
    -760,  -760,  -594,  -760,    62,   122,   575,   -50,  -347,  -760,
    -369,  -307,  -147,   641,    47,    27,   169,  -760,   -62,  -759,
    -312,   678,  -760,  -760,    73,  1124,  -760,  -340,   954,  -760,
     -33,  -494,  -760,   227,   -61,  -760,     5,   209,   633,  -314,
     -47,  1323,  -760,   730,  -760,     0,     4,  -167,   -43,  -760,
    -760,  -760,  -760,   803,  -171,   499,   498,  -760,  -318,   465,
     -14,   -21,    70,  -760,  -760,   191,  -760,   -69,   211,  -760,
    1117,  -760,  -760,  -760,  -760,   777,   781,   842,  -760,   -24,
    -760,  -760,  -760,  -760,  -760,  -760,  -760,  -760,   764,   818,
    -760,  -760,  -760,  -760,   -66,  1024,  -760,  -760,  -760,  -760,
    -760,   812,   687,   680,  1047,  -760,  -760,  1059,   -42,  -126,
    -760,   689,  -760,  -760,  -115,  -760,  -760,   -57,   -64,  1212,
    1213,    26,  -760,  -760,  -760,  1215,  -760,  -760,  -760,  -760,
    -760,  -760,  -760,  -760,   751,   927,  -760,  -760,  -760,  -760,
    -760,   766,  -760,   -79,  -760,   105,   748,  -760,   125,  -760,
    -760,   128,  -760,  -760,  -760,  -760,  -760,  -760,  -760,  -760,
    -760,  -760
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
       0,   292,   293,   294,   295,   296,   297,   599,   298,   299,
     300,   301,   302,   303,   304,   305,   306,   658,   659,   660,
      44,    45,   308,   309,   366,   347,   846,   151,   348,   349,
     642,   643,   644,   645,   310,   311,   312,   313,   608,   609,
     612,   314,   591,   315,   316,   317,   318,   319,   320,   321,
     322,   323,    49,   324,    50,   115,   325,    52,   582,   583,
     326,   327,   328,    53,   330,   331,    54,   332,    55,   454,
      56,   334,    58,   335,    60,   429,    62,    63,   678,    64,
      65,    66,    67,   681,   382,   383,   384,   385,   679,    68,
      69,    70,   466,    72,    73,   467,    75,   489,   883,    76,
     696,    77,    78,    79,    80,   411,   416,    81,    82,   412,
      83,    84,   432,    85,    86,   440,   441,   442,   443,    87,
      88,    89,   456,    90,   181,   182,   183,   553,   789,   184,
     403,   156,   157,   457,   158,   159,   160,   161,   162,   163,
     164,   531,   532,   533,   165,   166,   167,   526,   168,   169,
     170,   171,   539,   172,   540,   173,   174,   175,    91,    92,
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
      61,   350,   111,   110,   541,   116,   397,   619,   617,   450,
     548,   155,   154,   362,   689,   155,   449,   377,   367,   491,
     444,   203,   336,   116,   664,   203,   203,   452,   453,   766,
     410,   341,   114,   485,   379,   687,   527,   191,   422,   592,
     593,   112,   455,   307,   150,   652,   836,    46,   352,   849,
     337,   371,   536,   393,   417,   126,   437,   200,   597,   682,
     392,   684,   685,   686,   438,    61,    61,   336,   793,   152,
      71,   617,    61,   152,    61,   550,    61,   352,   336,   691,
     153,   430,   606,   894,   116,   606,   948,    41,    42,   336,
      61,    61,   353,    61,   478,    46,   606,   815,   475,   415,
     345,   155,   204,   205,    61,    99,    61,   518,    61,    61,
     360,   431,    46,    46,   476,   238,   451,   439,   542,    46,
     723,    46,   185,    46,    46,   100,   537,   361,   101,   832,
     198,   377,   140,   836,   794,   345,    46,    46,    46,   484,
      46,    37,   479,   636,   838,   803,   400,     1,   379,     2,
     587,    46,   956,    46,   802,    46,    46,   863,   587,   152,
     955,   460,    42,   155,   336,   606,   613,   724,   606,    47,
     155,   606,   154,   574,   948,   187,   448,   396,   546,   623,
     396,   336,  -252,   607,   588,   530,   607,   204,   205,   376,
     202,    74,   588,   654,   339,   340,   461,   607,   667,  -252,
     193,   687,   194,   672,   150,   387,   575,   577,   579,   110,
     983,    37,   873,   610,   563,   446,   462,    47,   477,   463,
      37,   152,   179,    40,   388,   447,   180,   631,   152,   611,
     613,   664,   623,   179,    47,    47,   967,   180,   289,   290,
     153,    47,   155,    47,   680,    47,    47,    34,    35,   329,
      37,   113,    39,   950,   576,   578,   372,   372,    47,    47,
      47,   503,    47,   372,   191,   372,   607,   401,   788,   607,
     504,   809,   607,    47,   555,    47,   380,    47,    47,   450,
     564,   372,    74,   566,   567,   195,   664,   822,    34,    35,
     729,   730,   113,    39,   329,     7,    34,    35,   364,   630,
     113,    39,   365,   547,   465,   329,   825,   830,   345,   833,
     338,   835,   455,   653,     1,   618,     2,   196,   653,   361,
     836,   418,    37,   336,   377,   687,    41,    42,   573,   419,
     289,   290,   433,    21,   810,   811,   480,   197,   345,   817,
     343,   671,    25,   116,   621,   546,    26,   154,   580,   204,
     205,   393,   836,   684,   942,   943,   818,   819,   392,   336,
      61,    20,   336,   661,   481,    61,   662,   336,   666,   665,
     634,   410,    61,    43,   336,   444,   204,   205,   618,   150,
     393,   434,   801,   655,    27,   344,   451,   392,   668,   626,
     380,   329,   527,   847,   661,   587,   417,  -259,   482,   345,
     483,    61,   345,   155,   154,   435,    46,    46,   329,   436,
     749,   527,    46,   204,   205,   153,   394,   356,   352,    46,
     336,    43,   706,   741,   364,   618,   395,   623,   712,   588,
     626,   635,   638,   329,   345,   618,   150,   663,    43,    43,
     345,   415,   891,   705,   728,    43,   393,    43,    46,    43,
      43,   762,   763,   392,   396,   764,   765,   359,   345,   449,
     561,   152,    43,    43,    43,    46,    43,    61,   544,    61,
     452,   453,   153,   363,   767,   768,   503,    43,   986,    43,
     368,    43,    43,   781,   420,   777,   345,   664,   986,    37,
    -379,   155,   421,    41,    42,    61,   573,    61,  -379,    61,
     361,    61,   785,   714,   527,   204,   205,   666,   689,    33,
     666,   715,   869,    37,    46,   840,    46,    41,    42,   935,
     783,   445,   687,   841,   623,   204,   205,   154,    47,    47,
     370,   373,   352,   336,    47,   176,   345,   386,   627,   737,
     895,    47,    46,   805,    46,   450,    46,   710,    46,   152,
     329,   545,   504,   946,   530,   458,   423,   718,   682,   150,
     664,   493,   824,   372,    33,   737,   727,   737,    37,   737,
      47,   737,   177,   204,   205,   666,   204,   205,   455,    46,
     179,   784,   892,   380,   180,   222,   661,    47,   944,   329,
     329,   816,   695,   502,   329,   153,   951,   952,   506,   204,
     205,   329,   661,   507,   231,   801,   797,   178,   618,   508,
     854,   126,   618,   618,   618,   577,   577,   509,   970,   448,
     510,   329,   661,   816,   661,   336,   204,   205,   662,   239,
     666,   665,   868,   377,   866,   511,    47,   876,    47,   876,
      14,   527,   527,  -262,   253,   881,   512,   329,   513,   329,
     379,   871,   451,   254,   379,   333,   379,   514,   734,   515,
     222,   519,   576,   578,    47,   516,    47,   521,    47,   522,
      47,   808,    46,   520,   393,   947,   538,   613,    48,   231,
     549,   392,   618,   336,   816,   554,   875,   336,   140,   336,
     204,   205,   882,   179,   556,    61,   570,   180,    37,   663,
     333,    47,    41,    42,   239,   972,   557,   828,   378,   770,
     771,   333,   558,   393,   116,   662,   559,   666,   637,   568,
     392,   613,   774,   775,   623,   728,    48,   569,   254,   613,
      59,   571,    43,    43,    61,   584,   573,  -141,    43,    46,
    -144,   896,    46,    48,    48,    43,  -142,   204,   205,  -211,
      48,  -236,    48,   586,    48,    48,   598,   204,   205,   594,
     329,   857,   858,   971,   600,   773,   587,    48,    48,    48,
     902,    48,   602,     1,    43,     2,   587,   603,   351,   574,
     288,    46,    48,   620,    48,   622,    48,    48,   662,   624,
     666,    43,   204,   205,    47,    59,    59,   333,   960,   625,
     588,   650,    59,   651,   351,   573,    59,   351,   692,   666,
     588,   957,   816,   329,   333,   669,   204,   205,   329,   351,
      59,    59,   378,    59,   856,   375,   618,   204,   205,   329,
     697,   666,   713,   961,    59,   587,    59,   698,    59,    59,
      43,   428,    43,   720,   468,   880,   858,   573,   699,   329,
     329,   329,   904,   905,   336,   494,   336,   496,   661,   498,
     500,    47,    34,    35,    47,   633,   113,    39,    43,   588,
      43,   700,    43,    14,    43,   655,   701,   953,   663,   702,
      34,    35,   719,    37,   113,    39,   695,   204,   205,   204,
     205,   721,   380,   962,   872,   963,   380,   731,   380,   736,
     663,   733,   662,    47,   666,    43,   740,   204,   205,   484,
     329,   329,   979,   964,   329,   396,   329,   751,   525,   981,
      28,   753,   529,   204,   205,   734,   864,   361,   865,   965,
     881,   646,   647,   525,   662,   543,   666,   665,   780,   375,
     648,   649,   552,   755,    33,   917,   918,    36,    37,   757,
     484,    40,    41,    42,   204,   205,   333,   925,   926,   980,
     976,   204,   205,   968,   572,   742,   352,   801,   743,   744,
     772,   745,   746,   663,   747,   931,   858,   882,   934,   858,
     587,   210,   211,   212,   673,   361,   674,   675,   676,   937,
     858,   289,   121,   122,   782,   333,   333,   786,    43,   787,
     333,   123,   204,   205,   938,   858,    46,   333,   992,   958,
     959,   973,   974,    46,   588,   378,   677,   126,   677,   790,
     677,   677,   677,   127,    46,    34,    35,   333,    37,   113,
      39,   495,   791,   497,   188,   499,   501,    48,    48,   329,
     792,   130,   795,    48,   973,   984,   799,   991,   959,   133,
      48,   796,   626,   333,   804,   333,   805,   210,   211,   212,
     673,   361,   674,   675,   676,    43,   121,   122,    43,   806,
     821,   807,   827,   252,   829,   123,   837,   843,   844,    48,
     845,   329,   850,   329,   139,   329,   853,   900,   855,   351,
     351,   126,   879,   346,   140,   351,    48,   884,   354,   355,
     890,   357,   351,   358,   893,   901,   641,    43,   903,    33,
     906,   911,    36,    37,   907,   130,    40,    41,    42,   908,
     143,   657,   909,   133,    51,   589,   912,   913,    47,    37,
     914,   351,   670,   186,   915,    47,   290,   919,   922,   920,
     921,   929,   932,   199,   930,    48,    47,    48,   351,   252,
     936,   933,   657,   227,   939,   940,   966,   969,   139,   975,
     230,   977,   978,   989,   505,   985,   333,   988,   140,   946,
     916,   820,   234,    48,   993,    48,   954,    48,   601,    48,
     585,   707,   708,   823,   711,   688,   877,   878,   987,    51,
      51,   716,   717,   402,   143,   703,    51,   351,    51,    59,
      51,   704,   726,    37,   656,   722,   690,   551,   589,   769,
      48,   694,   778,   534,    51,    51,   258,    51,   523,   333,
     738,   260,   779,   189,   190,    59,   192,    59,    51,    59,
      51,    59,    51,    51,   264,   333,   739,     0,     0,   750,
       0,     0,     0,   562,   565,     0,   752,     0,   754,     0,
     756,     0,   758,     0,   826,   333,     0,   333,     0,     0,
       0,   589,   351,     0,     0,     0,   525,   525,     0,     0,
     525,   525,   581,     0,     0,   581,    33,    34,    35,    36,
      37,   113,    39,    40,    41,    42,     0,     0,    33,    34,
      35,   529,    37,   113,    39,    40,     0,     0,   525,     0,
       0,     0,     0,    48,     0,     0,     0,     0,     0,     0,
       0,   677,   677,     0,     0,     0,   333,   560,   333,     0,
     333,     0,   333,    57,   378,     0,     0,   590,   378,     0,
     378,     0,    43,     0,     0,     0,     0,     0,     0,    43,
       0,     0,     0,     0,   657,     0,     0,   121,   122,   814,
      43,     0,     1,     0,     2,   351,   123,   604,   589,   605,
     657,     0,   589,     0,     0,     0,     0,     0,     0,     0,
      48,     0,   126,    48,     0,     0,   589,     0,   127,     0,
     657,   831,   657,     0,     0,   589,     0,   628,    57,    57,
     381,   842,     0,     0,     0,    57,   130,     0,     0,    57,
       0,   848,   405,     0,   133,   589,     0,     0,     0,     0,
     590,     0,    48,    57,    57,     0,    57,     0,     0,     0,
       0,     0,   351,     0,     0,   351,     0,    57,     0,    57,
       0,    57,    57,     0,     0,     0,     0,   867,     0,   139,
       0,   375,   870,   406,     0,   375,     0,   375,   227,   140,
       0,     0,    14,     0,     0,   230,   885,   886,   887,   888,
     889,     0,   407,   590,   351,     0,     0,   234,     0,     0,
       0,     0,     0,     0,   589,   143,     0,   897,   851,     0,
       0,   898,   899,   708,    37,     0,     0,   333,     0,   333,
     589,   333,     1,     0,     2,   408,    51,     0,   404,    28,
     227,     0,   409,   589,   381,     0,     0,   230,     0,     0,
       0,   258,     0,     0,     0,     0,   260,   677,     0,   234,
       0,     0,   693,    33,     0,    51,    36,    37,     0,   264,
      40,    41,    42,     0,     0,     0,     0,     0,     0,     0,
     589,   589,   405,     0,   589,     0,   923,     0,   924,   589,
     589,   759,     0,   760,     0,     0,     0,     0,     0,   589,
     590,     0,     0,   258,   590,     0,     0,     0,   260,     0,
     572,     0,     0,     0,    36,    37,     0,     0,   590,    41,
      42,   264,     0,   406,     0,     0,     0,   590,   732,     0,
       0,    51,    14,    51,     0,     0,     0,     0,     0,     0,
       0,   945,   407,     0,   949,   848,     0,   590,     0,   629,
       0,     0,     0,     0,     0,     0,   657,     0,     0,    51,
       0,    51,     0,    51,   117,    51,   118,    37,     0,     0,
     761,    41,    42,     0,     0,   408,     0,    48,   120,    28,
       0,     0,   409,     0,    48,     0,     0,   589,     0,     0,
       0,     0,     0,     0,   124,    48,     0,     0,     0,     0,
     125,     0,     0,    33,   589,     0,    36,    37,     0,     0,
      40,    41,    42,     0,     0,   589,   590,     0,     0,     0,
     852,   589,     0,     0,     0,     0,     0,     0,   129,   351,
       0,   131,   590,     0,     0,   132,   351,   381,     0,     0,
     589,     0,     0,   589,   134,   590,     0,   351,     0,     0,
       0,   859,   860,   861,   862,     0,     0,     0,   589,   589,
     589,   589,   589,   137,     0,   982,     0,     0,   138,   776,
     589,   589,   589,     1,     0,     2,     0,     0,     0,     0,
       0,     0,   590,   590,   990,     0,   590,   141,   839,     0,
     761,   590,   590,     0,     0,     0,   589,   589,     0,     0,
       0,   590,     0,   117,     0,   118,     0,     0,     0,     0,
     222,     0,     0,     0,     0,     0,     0,   120,   589,   225,
       0,     0,   589,     0,     0,     0,     0,     0,     0,   231,
       0,     0,    57,   124,     0,     0,     0,     0,     0,   125,
      33,   144,   145,    36,   535,   147,   148,   149,   236,    42,
     910,     0,     0,     0,   239,   589,     0,     0,    57,    51,
      57,     0,    57,   589,    57,   227,     0,   129,     0,     0,
     131,     0,   230,    14,   132,     0,     0,     0,   254,     0,
     256,   257,     0,   134,   234,     0,     0,     0,     0,   590,
       0,     0,     0,   927,     0,   928,     0,     0,    51,     0,
       0,     0,   137,     0,     0,     0,   590,   138,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   590,     0,     0,
      28,     0,     0,   590,     0,   941,   141,     0,   258,     0,
       0,     0,     0,   260,   280,     0,     0,     0,     0,     0,
       0,     0,   590,     0,    33,   590,   264,    36,    37,     0,
       0,    40,    41,    42,   288,     0,   289,   290,   291,     0,
     590,   590,   590,   590,   590,     0,     0,     0,     0,     0,
       0,     0,   590,   590,   590,     0,     0,     0,     0,     0,
       0,     0,   204,   205,     0,     0,     0,     0,    33,    34,
      35,   761,    37,   113,    39,    40,    41,    42,   590,   590,
       0,   587,   210,   211,   212,   673,   361,   674,   675,   676,
       0,   587,   210,   211,   212,   673,   361,   674,   675,   676,
     590,     0,     0,     0,   590,     0,     0,     0,     0,     0,
       0,     0,     0,   204,   205,   588,     0,     0,   206,     0,
       0,     0,   207,     0,   208,   588,   381,     0,   413,   874,
     381,     0,   381,   210,   211,   212,     0,   590,     0,     0,
       0,     0,   213,   214,   761,   590,     0,     0,   215,   216,
     217,   218,   219,   220,   221,     0,     0,     0,     0,   222,
     223,     0,     0,     0,     0,     0,     0,   224,   225,   226,
     227,     0,   405,     0,   252,   228,   229,   230,   231,     0,
       0,     0,   232,   233,   252,     0,     0,     0,     0,   234,
       0,     0,     0,     0,     0,   235,     0,   236,     0,   237,
       0,   238,     0,   239,     0,     0,     0,   240,     0,   241,
     242,     0,   243,   406,   244,     0,   245,   246,   247,   248,
     249,   250,    14,   251,     0,   252,   253,   254,   255,   256,
     257,     0,   407,   258,     0,     0,   259,     0,   260,     0,
       0,     0,   261,     0,     0,     0,     0,     0,     0,   262,
     263,   264,   265,     0,     0,     0,   266,   267,   268,     0,
     269,   270,     0,   271,   272,   408,   273,     0,     0,    28,
     274,     0,   409,   275,   276,     0,     0,     0,     0,     0,
     277,   278,   279,   280,   281,   282,     0,     0,   283,     0,
       0,     0,   284,    33,   285,   286,    36,   414,    38,   287,
      40,    41,    42,   288,     0,   289,   290,   291,   204,   205,
       0,     0,     0,   206,     0,     0,     0,   207,     0,   208,
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
     289,   290,   291,   204,   205,     0,     0,     0,   206,     0,
       0,     0,   207,     0,   208,     0,     0,     0,   209,     0,
       0,     0,     0,   210,   211,   212,     0,     0,     0,     0,
       0,     0,   213,   214,     0,     0,     0,     0,   215,   216,
     217,   218,   219,   220,   221,     0,     0,     0,     0,   222,
     223,     0,     0,     0,     0,     0,     0,   224,   225,   226,
     227,     0,     0,     0,     0,   228,   229,   230,   231,     0,
       0,     0,   232,   233,     0,     0,     0,     0,     0,   234,
       0,     0,     0,     0,     0,   235,     0,   236,     0,   237,
       0,   238,     0,   239,     0,     0,     0,   240,     0,   241,
     242,     0,   243,     0,   244,     0,   245,   246,   247,   248,
     249,   250,    14,   251,     0,   252,   253,   254,   255,   256,
     257,     0,     0,   258,     0,     0,   259,     0,   260,     0,
       0,     0,   261,     0,     0,     0,     0,     0,     0,   262,
     263,   264,   265,     0,     0,     0,   266,   267,   268,     0,
     269,   270,     0,   271,   272,     0,   273,     0,     0,    28,
     274,     0,     0,   275,   276,     0,     0,     0,     0,     0,
     277,   278,   279,   280,   281,   282,     0,     0,   283,     0,
       0,     0,   284,    33,   285,   286,    36,    37,    38,   287,
      40,    41,    42,   288,     0,   289,   290,   291,   204,   205,
     528,     0,     0,   206,     0,     0,     0,   207,     0,   208,
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
     289,   290,   291,   204,   205,     0,     0,     0,   206,     0,
       0,     0,   207,     0,   208,     0,     0,     0,     0,     0,
       0,     0,     0,   210,   211,   212,     0,     0,     0,     0,
       0,     0,   213,   214,     0,     0,     0,     0,   215,   216,
     217,   218,   219,   220,   221,     0,     0,     0,     0,   222,
     223,     0,     0,     0,     0,     0,     0,   224,   225,   226,
     227,     0,     0,     0,     0,   228,   229,   230,   231,     0,
       0,     0,   232,   233,     0,     0,     0,     0,     0,   234,
       0,     0,     0,     0,     0,   235,     0,   236,    10,   237,
       0,   238,     0,   239,     0,     0,     0,   240,     0,   241,
     242,     0,   243,     0,   244,     0,   245,   246,   247,   248,
     249,   250,    14,   251,     0,   252,   253,   254,   255,   256,
     257,     0,     0,   258,     0,     0,   259,     0,   260,     0,
       0,     0,   261,     0,     0,     0,     0,     0,     0,   262,
     263,   264,   265,     0,     0,     0,   266,   267,   268,     0,
     269,   270,     0,   271,   272,     0,   273,     0,     0,    28,
     274,     0,     0,   275,   276,     0,     0,     0,     0,     0,
     277,   278,   279,   280,   281,   282,     0,     0,   283,     0,
       0,     0,   284,    33,   285,   286,    36,    37,    38,   287,
      40,    41,    42,   288,     0,   289,   290,   291,   204,   205,
       0,     0,     0,   374,     0,     0,     0,   207,     0,   208,
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
     289,   290,   291,   204,   205,     0,     0,     0,   206,     0,
       0,     0,   207,     0,   208,     0,     0,     0,     0,     0,
       0,     0,     0,   210,   211,   212,     0,     0,     0,     0,
       0,     0,   213,   214,     0,     0,     0,     0,   215,   216,
     217,   218,   219,   220,   221,     0,     0,     0,     0,   222,
     223,     0,     0,     0,     0,     0,     0,   224,   225,   226,
     227,     0,     0,     0,     0,   228,   229,   230,   231,     0,
       0,     0,   232,   233,     0,     0,     0,     0,     0,   234,
       0,     0,     0,     0,     0,   235,     0,   236,     0,   237,
       0,   238,     0,   239,     0,     0,     0,   240,     0,   241,
     242,     0,   243,     0,   244,     0,   245,   246,   247,   248,
     249,   250,    14,   251,     0,   252,   253,   254,   255,   256,
     257,     0,     0,   258,     0,     0,   259,     0,   260,     0,
       0,     0,   261,     0,     0,     0,     0,     0,     0,   262,
     263,   264,   265,     0,     0,     0,   266,   267,   268,     0,
     269,   270,     0,   271,   272,     0,   273,     0,     0,    28,
     274,     0,     0,   275,   276,     0,     0,     0,     0,     0,
     277,   278,   279,   280,   281,   282,     0,     0,   283,     0,
       0,     0,   284,    33,   285,   286,    36,    37,    38,   287,
      40,    41,    42,   288,     0,   289,   290,   291,   204,   205,
       0,     0,     0,   206,     0,     0,     0,   207,     0,   208,
       0,     0,     0,     0,     0,     0,     0,     0,   210,   211,
     212,     0,     0,     0,     0,     0,     0,   213,   214,     0,
       0,     0,     0,   215,   216,   217,   218,   219,   220,   221,
       0,     0,     0,     0,   222,   223,     0,     0,     0,     0,
       0,     0,   224,   225,   226,   227,     0,     0,     0,     0,
     228,   229,   230,   231,     0,     0,     0,   232,   233,     0,
       0,     0,     0,     0,   234,     0,     0,     0,     0,     0,
     235,     0,   236,     0,   237,     0,     0,     0,   239,     0,
       0,     0,   240,     0,   241,   242,     0,   243,     0,   244,
       0,   245,   246,   247,   248,   249,   250,     0,   251,     0,
     252,     0,   254,   255,   256,   257,     0,     0,   258,     0,
       0,   259,     0,   260,     0,     0,     0,   261,     0,     0,
       0,     0,     0,     0,   262,   263,   264,   265,     0,     0,
       0,   266,   267,   268,     0,   269,   270,     0,   271,   272,
       0,   273,     0,     0,    28,   274,     0,     0,   275,   276,
       0,     0,     0,     0,     0,   277,   278,   279,   280,   281,
     282,     0,     0,   283,     0,     0,     0,   284,    33,   285,
     286,    36,    37,   113,   287,    40,    41,    42,   288,     0,
     289,   290,   291,   204,   205,     0,     0,     0,   725,     0,
       0,     0,   207,     0,   208,     0,     0,     0,     0,     0,
       0,     0,     0,   210,   211,   212,     0,     0,     0,     0,
       0,     0,   213,   214,     0,     0,     0,     0,   215,   216,
     217,   218,   219,   220,   221,     0,     0,     0,     0,   222,
     223,     0,     0,     0,     0,     0,     0,   224,     0,     0,
     227,     0,     0,     0,     0,   228,   229,   230,   231,     0,
       0,     0,   232,   233,     0,     0,     0,     0,     0,   234,
       0,     0,     0,     0,     0,   235,     0,   236,     0,   237,
       0,     0,     0,   239,     0,     0,     0,   240,     0,   241,
     242,     0,   243,     0,     0,     0,   245,   246,   247,   248,
     249,   250,     0,   251,     0,   252,     0,   254,   255,   256,
     257,     0,     0,   258,     0,     0,   259,     0,   260,     0,
       0,     0,   261,     0,     0,     0,     0,     0,     0,     0,
     263,   264,   265,     0,     0,     0,   266,   267,   268,     0,
     269,   270,     0,   271,   272,     0,   273,     0,     0,    28,
     274,     0,     0,   275,   276,     0,     0,     0,     0,     0,
     277,   278,     0,   280,   281,   282,     0,     0,   283,     0,
       0,     0,   284,    33,   285,    35,     0,    37,   113,   287,
      40,    41,    42,   204,   205,   289,   290,   291,   812,     0,
       0,     0,     1,     0,     2,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   213,   214,     0,     0,     0,     0,   215,   216,
     217,   218,   219,   220,   221,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   224,   225,   226,
     227,     0,     0,     0,     0,   228,   229,   230,     0,     0,
       0,     0,   232,   233,     0,     0,     0,     0,     0,   234,
       0,     0,     0,     0,     0,   235,     0,     0,     0,   237,
       0,     0,     0,     0,     0,     0,     0,   240,     0,   241,
     242,     0,   243,     0,   244,     0,   245,   246,   247,   248,
     249,   250,     0,   251,     0,     0,     0,     0,   255,     0,
       0,     0,     0,   258,     0,     0,   259,     0,   260,     0,
       0,     0,   261,     0,     0,     0,     0,     0,     0,   262,
     263,   264,   265,     0,     0,     0,   266,   267,   268,     0,
     269,   270,     0,   271,   272,     0,   273,     0,     0,     0,
     274,     0,     0,   275,   276,     0,     0,     0,     0,     0,
     277,   278,   279,     0,   281,   282,     0,     0,   283,   204,
     205,     0,     0,     0,   424,   813,    36,    37,     1,   427,
       2,    41,    42,   288,     0,   289,   290,   291,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   213,   214,
       0,     0,     0,     0,   215,   216,   217,   218,   219,   220,
     221,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   224,     0,     0,   227,     0,     0,     0,
       0,   228,   229,   230,     0,     0,     0,     0,   232,   233,
       0,     0,     0,     0,     0,   234,     0,     0,     0,     0,
       0,   235,     0,     0,     0,   237,   425,     0,     0,     0,
       0,     0,     0,   240,     0,   241,   242,     0,   243,     0,
       0,     0,   245,   246,   247,   248,   249,   250,     0,   251,
       0,     0,     0,     0,   255,     0,     0,     0,     0,   258,
       0,     0,   259,     0,   260,     0,     0,     0,   261,     0,
       0,     0,     0,     0,     0,     0,   263,   264,   265,     0,
       0,     0,   266,   267,   268,     0,   269,   270,     0,   271,
     272,     0,   273,     0,     0,     0,   274,     0,     0,   275,
     276,     0,     0,     0,     0,     0,   277,   278,     0,     0,
     281,   282,   426,     0,   283,     0,     0,     0,     0,     0,
       0,     0,     0,    37,     0,   427,     0,    41,    42,     0,
       0,   289,   290,   291,   204,   205,   639,   803,     0,   424,
       0,     0,   640,     1,     0,     2,     0,   117,     0,   118,
     587,   210,   211,   212,   673,   361,   674,   675,   676,     0,
       0,   120,     0,   213,   214,     0,     0,     0,     0,   215,
     216,   217,   218,   219,   220,   221,     0,   124,     0,     0,
       0,     0,     0,   125,   588,     0,     0,     0,   224,     0,
       0,   227,     0,     0,   517,     0,   228,   229,   230,     0,
       0,     0,     0,   232,   233,     0,     0,     0,     0,     0,
     234,   129,     0,     0,   131,     0,   235,     0,   132,     0,
     237,     0,     0,     0,     0,     0,     0,   134,   240,     0,
     241,   242,     0,   243,     0,     0,     0,   245,   246,   247,
     248,   249,   250,   252,   251,     0,   137,     0,     0,   255,
       0,   138,     0,     0,   258,     0,     0,   259,     0,   260,
       0,     0,     0,   261,     0,     0,     0,     0,     0,     0,
     141,   263,   264,   265,     0,     0,     0,   266,   267,   268,
       0,   269,   270,     0,   271,   272,     0,   273,     0,     0,
       0,   274,     0,     0,   275,   276,     0,     0,     0,     0,
       0,   277,   278,     0,     0,   281,   282,     0,     0,   283,
     204,   205,   524,     0,     0,   424,     0,     0,    37,     1,
     427,     2,    41,    42,     0,     0,   289,   290,   291,     0,
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
     275,   276,     0,     0,     0,     0,     0,   277,   278,   204,
     205,   281,   282,     0,   424,   283,     0,   640,     1,     0,
       2,     0,     0,     0,    37,     0,   427,     0,    41,    42,
       0,     0,   289,   290,   291,     0,     0,     0,   213,   214,
       0,     0,     0,     0,   215,   216,   217,   218,   219,   220,
     221,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   224,     0,     0,   227,     0,     0,     0,
       0,   228,   229,   230,     0,     0,     0,     0,   232,   233,
       0,     0,     0,     0,     0,   234,     0,     0,     0,     0,
       0,   235,     0,     0,     0,   237,     0,     0,     0,     0,
       0,     0,     0,   240,     0,   241,   242,     0,   243,     0,
       0,     0,   245,   246,   247,   248,   249,   250,     0,   251,
       0,     0,     0,     0,   255,     0,     0,     0,     0,   258,
       0,     0,   259,     0,   260,     0,     0,     0,   261,     0,
       0,     0,     0,     0,     0,     0,   263,   264,   265,     0,
       0,     0,   266,   267,   268,     0,   269,   270,     0,   271,
     272,     0,   273,     0,     0,     0,   274,     0,     0,   275,
     276,     0,     0,     0,     0,     0,   277,   278,   204,   205,
     281,   282,     0,   424,   283,     0,     0,     1,     0,     2,
       0,     0,     0,    37,     0,   427,     0,    41,    42,     0,
       0,   289,   290,   291,     0,     0,     0,   213,   214,     0,
       0,     0,     0,   215,   216,   217,   218,   219,   220,   221,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   224,     0,     0,   227,     0,     0,     0,     0,
     228,   229,   230,     0,     0,     0,     0,   232,   233,     0,
       0,     0,     0,     0,   234,     0,     0,     0,     0,     0,
     235,     0,     0,     0,   237,     0,     0,     0,     0,     0,
       0,     0,   240,     0,   241,   242,     0,   243,     0,     0,
       0,   245,   246,   247,   248,   249,   250,     0,   251,     0,
       0,     0,     0,   255,     0,     0,     0,     0,   258,     0,
       0,   259,     0,   260,   459,     0,     0,   261,     0,     0,
       0,     0,     0,     0,     0,   263,   264,   265,     1,     0,
       2,   266,   267,   268,     3,   269,   270,     0,   271,   272,
       0,   273,     0,     0,     0,   274,     0,     4,   275,   276,
       0,     0,     0,     0,     0,   277,   278,     0,     0,   281,
     282,     0,     0,   283,     0,     0,     0,     0,     0,     5,
       6,     0,    37,     0,   427,     0,    41,    42,     0,     0,
     289,   290,   291,     0,     0,     7,     0,     0,     0,     0,
       8,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       9,     0,     0,     0,    10,     0,     0,    11,    12,     0,
      13,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    14,     0,
       0,     0,     0,     0,     0,    15,    16,     0,     0,     0,
       0,     0,     0,     0,     0,    17,    18,     0,     0,     0,
      19,    20,    21,    22,     0,     0,     0,     0,     0,    23,
      24,    25,     0,     0,     0,    26,     0,     0,     0,     0,
       0,     0,     0,     0,    27,    28,     0,     0,     0,     0,
       0,     0,     0,    29,     0,   595,   596,     0,   424,     0,
       0,     0,     1,    30,     2,    31,   117,    32,   118,    33,
      34,    35,    36,    37,    38,    39,    40,    41,    42,     0,
     120,     0,   213,   214,     0,     0,     0,     0,   215,   216,
     217,   218,   219,   220,   221,     0,   124,     0,     0,     0,
       0,     0,   125,     0,     0,     0,     0,   224,     0,     0,
     227,     0,     0,     0,     0,   228,   229,   230,     0,     0,
       0,     0,   232,   233,     0,     0,     0,     0,     0,   234,
     129,     0,     0,   131,     0,   235,     0,   132,     0,   237,
       0,     0,     0,     0,     0,     0,   134,   240,     0,   241,
     242,     0,   243,     0,     0,     0,   245,   246,   247,   248,
     249,   250,     0,   251,     0,   137,     0,     0,   255,     0,
     138,     0,     0,   258,     0,     0,   259,     0,   260,     0,
       0,     0,   261,     0,     0,     0,     0,     0,     0,   141,
     263,   264,   265,     0,     0,     0,   266,   267,   268,     0,
     269,   270,     0,   271,   272,     0,   273,     0,     0,     0,
     274,     0,     0,   275,   276,     0,     0,     0,     0,     0,
     277,   278,     0,     0,   281,   282,   424,     0,   283,     0,
       1,     0,     2,     0,     0,     0,     0,    37,     0,   427,
       0,    41,    42,     0,     0,   289,   290,   291,     0,     0,
     213,   214,     0,     0,     0,     0,   215,   216,   217,   218,
     219,   220,   221,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   224,     0,     0,   227,     0,
       0,     0,     0,   228,   229,   230,     0,     0,     0,     0,
     232,   233,     0,     0,     0,     0,     0,   234,     0,     0,
       0,     0,     0,   235,     0,     0,     0,   237,     0,     0,
       0,     0,     0,     0,     0,   240,     0,   241,   242,     0,
     243,     0,     0,     0,   245,   246,   247,   248,   249,   250,
       0,   251,     0,     0,     0,     0,   255,     0,     0,     0,
       0,   258,     0,     0,   259,     0,   260,     0,     0,     0,
     261,     0,     0,     0,     0,     0,     0,     0,   263,   264,
     265,     0,     0,     0,   266,   267,   268,     0,   269,   270,
       0,   271,   272,     0,   273,     1,     0,     2,   274,     0,
       0,   275,   276,     0,     0,     0,     0,     0,   277,   278,
       0,     0,   281,   282,     0,     0,   283,     0,     0,     0,
       0,     0,     0,     0,     0,    37,     0,   427,     0,    41,
      42,     0,   222,   289,   290,   291,     0,     0,   614,     0,
       0,   225,   615,   227,   616,     0,     0,     0,     0,     0,
     230,   231,     0,   210,   211,   212,     0,     0,     0,     0,
       0,     0,   234,     0,     0,     0,     0,     0,     0,     0,
     236,     0,     0,     0,     0,     0,   239,     0,     0,   222,
     223,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    14,     0,     0,   231,     0,
     254,   709,   256,   257,     0,     0,   258,     0,     0,     0,
       0,   260,     0,     0,     0,     0,     0,   236,     0,     0,
       0,   614,     0,   239,   264,   615,     0,   616,     0,     0,
       0,     0,     0,     0,     0,     0,   210,   211,   212,     0,
       0,     0,    28,     0,     0,   252,     0,   254,     0,   256,
     257,     0,     0,     0,     0,     0,   280,     0,     0,     0,
       0,     0,   222,   223,     0,     0,    33,    34,    35,    36,
      37,   113,    39,    40,    41,    42,   288,     0,   289,   290,
     291,   231,   614,     0,     0,     0,   615,     0,   616,    28,
       0,     0,     0,     0,     0,   683,     0,     0,     0,   615,
     236,   616,     0,   280,     0,     0,   239,     0,     0,     0,
       0,     0,   284,    33,   285,    35,     0,    37,   113,    39,
      40,     0,     0,   222,   223,     0,     0,     0,   252,     0,
     254,     0,   256,   257,     0,     0,   222,   223,     0,     0,
       0,     0,   231,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   231,     0,     0,     0,     0,
       0,   236,     0,     0,     0,     0,     0,   239,     0,     0,
       0,     0,    28,     1,   236,     2,     0,     0,     0,     3,
     239,     0,     0,     0,     0,     0,   280,     0,     0,     0,
       0,   254,     4,   256,   257,   284,    33,   285,    35,     0,
      37,   113,    39,    40,   254,     0,   256,   257,     0,     0,
       0,     0,     0,     0,     5,     6,     0,     0,     0,     0,
       0,     0,   464,     0,     0,     0,     0,     0,     0,     0,
       7,     0,     0,    28,     0,     8,     0,     0,     0,   465,
       0,     0,     0,     0,     0,     9,    28,   280,     0,    10,
       0,     0,    11,    12,     0,    13,   284,    33,   285,    35,
     280,    37,   113,    39,    40,     0,     0,     0,     0,   284,
      33,   285,    35,    14,    37,   113,    39,    40,     0,     0,
      15,    16,     0,     0,     0,     0,     0,     0,     0,     0,
      17,    18,     0,     0,     0,    19,    20,    21,    22,     0,
       0,     0,     0,     0,    23,    24,    25,     0,     0,     0,
      26,     0,     0,     0,     0,     1,     0,     2,     0,    27,
      28,     3,     0,     0,     0,     0,     0,     0,    29,     0,
       0,     0,     0,     0,     4,     0,     0,     0,    30,     0,
      31,     0,    32,     0,    33,    34,    35,    36,    37,    38,
      39,    40,    41,    42,     0,     0,     5,     6,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     7,     0,     0,     0,     0,     8,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     9,     0,     0,
       0,    10,     0,     0,    11,    12,     0,    13,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    14,     0,     0,     0,     0,
       0,     0,    15,    16,     0,     0,     0,     0,     0,     0,
       0,     0,    17,    18,     0,     0,     0,    19,    20,    21,
      22,     0,     0,     0,     0,     0,    23,    24,    25,     0,
       0,     0,    26,     0,     0,     0,     0,     1,     0,     2,
       0,    27,    28,     3,     0,     0,     0,     0,     0,     0,
      29,     0,     0,     0,     0,     0,     4,     0,     0,     0,
      30,     0,    31,     0,    32,     0,    33,    34,    35,    36,
      37,    38,    39,    40,    41,    42,     0,     0,     5,     6,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     8,
       0,     0,   398,     0,     0,     0,     0,     0,     0,     9,
       0,     0,     0,    10,     0,     0,    11,    12,     0,    13,
       0,     0,     0,     1,     0,     2,     0,     0,     0,     3,
       0,     0,     0,     0,     0,     0,     0,    14,     0,     0,
       0,     0,     4,     0,    15,    16,     0,     0,     0,     0,
       0,     0,     0,     0,    17,    18,     0,     0,     0,    19,
       0,    21,    22,     0,     5,     6,     0,     0,    23,    24,
      25,     0,     0,     0,    26,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    28,     8,     0,     0,   398,     0,
       0,   399,    29,     0,     0,     9,     0,   389,     0,    10,
       0,     0,    30,    12,    31,    13,    32,     0,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,     0,     0,
       0,     0,     0,    14,     0,     0,     0,     0,     0,     0,
      15,    16,     0,     0,     0,     0,     0,     0,     0,     0,
      17,    18,     0,     0,     1,    19,     2,    21,    22,     0,
       3,     0,     0,     0,    23,    24,    25,     0,     0,     0,
      26,     0,     0,     4,     0,     0,     0,     0,     0,     0,
      28,     0,     0,     0,     0,     0,   390,     0,    29,     0,
       0,     0,     0,     0,     0,     5,     6,     0,   391,     0,
      31,     0,    32,   464,    33,    34,    35,    36,    37,   113,
      39,    40,    41,    42,     0,     0,     8,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     9,     0,   389,     0,
      10,     0,     0,     0,    12,     0,    13,     0,     0,     0,
       1,     0,     2,     0,     0,     0,     3,     0,     0,     0,
       0,     0,     0,     0,    14,     0,     0,     0,     0,     4,
       0,    15,    16,     0,     0,     0,     0,     0,     0,     0,
       0,    17,    18,     0,     0,     0,    19,     0,    21,    22,
       0,     5,     6,     0,     0,    23,    24,    25,     0,     0,
       0,    26,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    28,     8,     0,     0,     0,     0,   390,     0,    29,
       0,     0,     9,     0,   389,     0,    10,     0,     0,   391,
      12,    31,    13,    32,     0,    33,    34,    35,    36,    37,
     113,    39,    40,    41,    42,     0,     0,     0,     0,     0,
      14,     0,     0,     0,     0,     0,     0,    15,    16,     0,
       0,     0,     0,     0,     0,     0,     0,    17,    18,     0,
       0,     1,    19,     2,    21,    22,     0,     3,     0,     0,
       0,    23,    24,    25,     0,     0,     0,    26,     0,     0,
       4,     0,     0,     0,     0,     0,     0,    28,     0,     0,
       0,     0,     0,   390,     0,    29,     0,     0,     0,     0,
       0,     0,     5,     6,     0,   391,     0,    31,     0,    32,
     464,    33,    34,    35,    36,    37,   113,    39,    40,    41,
      42,     0,     0,     8,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     9,     0,     0,     0,    10,     0,     0,
      11,    12,     0,    13,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    14,     0,     0,     0,     0,     0,     0,    15,    16,
       0,     0,     0,     0,     0,     0,     0,     0,    17,    18,
       0,     0,     1,    19,     2,    21,    22,     0,     3,     0,
       0,     0,    23,    24,    25,     0,     0,     0,    26,     0,
       0,     4,     0,     0,     0,     0,     0,     0,    28,     0,
       0,     0,     0,     0,     0,     0,    29,     0,     0,     0,
       0,     0,     0,     5,     6,     0,    30,     0,    31,     0,
      32,     0,    33,    34,    35,    36,    37,    38,    39,    40,
      41,    42,     0,     0,     8,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     9,     0,     0,     0,    10,     0,
       0,    11,    12,     0,    13,     0,     0,     0,     1,     0,
       2,     0,     0,     0,     3,     0,     0,     0,     0,     0,
       0,     0,    14,     0,     0,     0,     0,     4,     0,    15,
      16,     0,     0,     0,     0,     0,     0,     0,     0,    17,
      18,     0,     0,     0,    19,     0,    21,    22,     0,     5,
       6,     0,     0,    23,    24,    25,     0,     0,     0,    26,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    28,
       8,     0,     0,   398,     0,     0,     0,    29,     0,     0,
       9,     0,     0,     0,    10,     0,     0,   369,    12,    31,
      13,    32,     0,    33,    34,    35,    36,    37,    38,    39,
      40,    41,    42,     0,     0,     0,     0,     0,    14,     0,
       0,     0,     0,     0,     0,    15,    16,     0,     0,     0,
       0,     0,     0,     0,     0,    17,    18,     0,     0,     1,
      19,     2,    21,    22,     0,     3,     0,     0,     0,    23,
      24,    25,     0,     0,     0,    26,     0,     0,     4,     0,
       0,     0,     0,     0,     0,    28,     0,     0,     0,     0,
       0,     0,     0,    29,     0,     0,     0,     0,     0,     0,
       5,     6,     0,   369,     0,    31,     0,    32,   464,    33,
      34,    35,    36,    37,   113,    39,    40,    41,    42,     0,
       0,     8,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     9,     0,     0,     0,    10,     0,     0,     0,    12,
       0,    13,     0,     0,     0,     1,     0,     2,     0,     0,
       0,     3,     0,     0,     0,     1,     0,     2,     0,    14,
       0,     0,     0,     0,     4,     0,    15,    16,     0,     0,
       0,     0,     0,     0,     0,     0,    17,    18,     0,     0,
       0,    19,     0,    21,    22,     0,     5,     6,     0,     0,
      23,    24,    25,     0,     0,     0,    26,     0,     0,     0,
       0,     0,     0,   227,     0,     0,    28,     8,     0,     0,
     230,     0,     0,     0,    29,     0,     0,     9,     0,     0,
       0,    10,   234,     0,   369,    12,    31,    13,    32,     0,
      33,    34,    35,    36,    37,   113,    39,    40,    41,    42,
       1,     0,     2,     0,     0,    14,     0,     0,     0,     0,
       0,     0,    15,    16,     0,    14,     0,     0,     0,   834,
       0,     0,    17,    18,     0,     0,   258,    19,     0,    21,
      22,   260,     0,     0,     0,     0,    23,    24,    25,     0,
       0,     0,    26,     0,   264,     0,     0,     0,   227,     0,
       0,     0,    28,     0,     0,   230,     0,     0,     0,     0,
      29,     0,    28,     0,     0,     0,     0,   234,     0,     0,
     369,     0,    31,     0,    32,     0,    33,    34,    35,    36,
      37,   113,    39,    40,    41,    42,    33,    34,    35,    36,
      37,   113,    39,    40,    41,    42,     0,     0,     0,     0,
      14,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   258,     0,     0,     0,     0,   260,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   264,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    28,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    33,    34,    35,    36,    37,   113,    39,    40,    41,
      42,   117,     0,   118,     0,     0,     0,     0,     0,     0,
       0,     0,   119,     0,     0,   120,     0,   121,   122,     0,
       0,     0,     0,     0,     0,     0,   123,     0,     0,     0,
       0,   124,     0,     0,     0,     0,     0,   125,     0,     0,
       0,     0,   126,     0,     0,     0,     0,     0,   127,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   128,     0,
       0,     0,     0,     0,     0,   129,   130,     0,   131,     0,
       0,     0,   132,     0,   133,     0,     0,     0,     0,     0,
       0,   134,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   135,     0,   136,     0,     0,     0,     0,     0,
     137,   117,     0,   118,     0,   138,     0,     0,     0,   139,
       0,     0,   119,     0,     0,   120,     0,   121,   122,   140,
       0,     0,     0,     0,   141,     0,   123,     0,     0,     0,
       0,   124,   142,     0,     0,     0,     0,   125,     0,     0,
       0,     0,   126,     0,     0,   143,     0,     0,   127,     0,
      33,   144,   145,    36,   146,   147,   148,   149,   128,    42,
       0,     0,     0,     0,     0,   129,   130,     0,   131,     0,
       0,   117,   132,   118,   133,     0,     0,     0,     0,     0,
       0,   134,     0,     0,     0,   120,     0,   121,   122,     0,
       0,     0,   135,     0,   136,     0,   123,     0,     0,     0,
     137,   124,     0,     0,     0,   138,     0,   125,     0,   139,
       0,     0,   126,     0,     0,     0,     0,     0,   127,   140,
       0,     0,     0,     0,   141,     0,     0,     0,     0,     0,
       0,     0,   142,     0,     0,   129,   130,     0,   131,     0,
       0,     0,   132,     0,   133,   143,     0,     0,     0,     0,
       0,   134,     0,     0,    37,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     137,     0,     0,     0,     0,   138,     0,     0,     0,   139,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   140,
       0,     0,     0,     0,   141,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   143,     0,     0,     0,     0,
       0,     0,     0,     0,    37
};

static const yytype_int16 yycheck[] =
{
       0,    48,     2,     1,   174,     5,    75,   319,   315,    89,
     181,     7,     7,    56,   383,    11,    89,    67,    61,    98,
      86,    21,    22,    23,   364,    25,    26,    89,    89,   514,
      77,    27,     5,    97,    67,   382,   162,    11,    81,   294,
     295,     4,    89,    22,     7,   359,   626,     0,    48,   643,
      23,    65,   167,    74,    78,    77,    12,    20,   297,   377,
      74,   379,   380,   381,    20,    65,    66,    67,    97,     7,
       0,   378,    72,    11,    74,    20,    76,    77,    78,   394,
       7,    20,    22,    20,    84,    22,   845,   193,   194,    89,
      90,    91,    10,    93,    85,    48,    22,   591,    20,    78,
      18,    97,     5,     6,   104,     0,   106,   149,   108,   109,
      12,    84,    65,    66,    36,    93,    89,    73,   175,    72,
      37,    74,    20,    76,    77,     0,   168,    29,     0,   623,
      20,   181,   154,   713,   163,    18,    89,    90,    91,    10,
      93,   189,   133,    10,   629,    11,    76,    14,   181,    16,
      24,   104,    20,   106,    11,   108,   109,    11,    24,    97,
      11,    91,   194,   159,   164,    22,   313,    84,    22,     0,
     166,    22,   167,   206,   933,    10,    89,    48,   178,   326,
      48,   181,    12,   123,    58,   164,   123,     5,     6,    67,
      21,     0,    58,   360,    25,    26,    91,   123,   365,    29,
     171,   548,    82,   374,   167,    20,   206,   207,   208,   207,
     969,   189,   190,    23,    97,    10,    91,    48,   140,    91,
     189,   159,   178,   192,    39,    20,   182,   342,   166,    39,
     377,   571,   379,   178,    65,    66,    54,   182,   197,   198,
     167,    72,   238,    74,   170,    76,    77,   186,   187,    22,
     189,   190,   191,   847,   207,   208,    65,    66,    89,    90,
      91,     8,    93,    72,   238,    74,   123,    76,   171,   123,
      17,   586,   123,   104,   187,   106,    67,   108,   109,   359,
     163,    90,    91,   196,   197,    82,   626,   602,   186,   187,
      11,    12,   190,   191,    67,    71,   186,   187,     8,   341,
     190,   191,    12,   181,    80,    78,   613,   622,    18,   624,
      82,   625,   359,   360,    14,   315,    16,    10,   365,    29,
     900,    12,   189,   323,   374,   672,   193,   194,   206,    20,
     197,   198,    49,   138,   589,   590,    65,    10,    18,   594,
     126,   374,   147,   343,   323,   345,   151,   342,    28,     5,
       6,   372,   932,   671,   839,   840,   595,   596,   372,   359,
     360,   137,   362,   363,    93,   365,   364,   367,   364,   364,
     343,   418,   372,     0,   374,   441,     5,     6,   378,   342,
     401,    98,    11,   362,   160,    10,   359,   401,   367,     8,
     181,   164,   518,    49,   394,    24,   420,    10,   127,    18,
     129,   401,    18,   399,   399,   122,   359,   360,   181,   126,
     489,   537,   365,     5,     6,   342,    10,    21,   418,   372,
     420,    48,   422,   487,     8,   425,    20,   574,    20,    58,
       8,   344,   345,   206,    18,   435,   399,   364,    65,    66,
      18,   420,    20,   422,   444,    72,   467,    74,   401,    76,
      77,   508,   509,   467,    48,   512,   513,    10,    18,   532,
      20,   399,    89,    90,    91,   418,    93,   467,   168,   469,
     532,   532,   399,    10,   516,   517,     8,   104,   974,   106,
      20,   108,   109,   540,    12,   532,    18,   827,   984,   189,
      12,   487,    20,   193,   194,   495,   374,   497,    20,   499,
      29,   501,   545,    12,   630,     5,     6,   503,   877,   185,
     506,    20,   683,   189,   467,    12,   469,   193,   194,   826,
      20,    20,   869,    20,   671,     5,     6,   522,   359,   360,
      65,    66,   532,   533,   365,    20,    18,    72,    20,   469,
      20,   372,   495,     8,   497,   625,   499,   425,   501,   487,
     323,   178,    17,    19,   533,    90,    12,   435,   876,   522,
     900,    20,   612,   372,   185,   495,   444,   497,   189,   499,
     401,   501,    57,     5,     6,   571,     5,     6,   625,   532,
     178,   544,    11,   374,   182,    51,   586,   418,    20,   362,
     363,   591,   401,    15,   367,   522,   851,   852,     8,     5,
       6,   374,   602,    10,    70,    11,   569,    92,   608,    10,
     653,    77,   612,   613,   614,   615,   616,    10,   930,   532,
      10,   394,   622,   623,   624,   625,     5,     6,   626,    95,
     626,   626,   682,   683,   677,    10,   467,   687,   469,   689,
     114,   767,   768,     6,   118,   692,    10,   420,    10,   422,
     683,   684,   625,   119,   687,    22,   689,    10,   467,    10,
      51,   114,   615,   616,   495,   127,   497,    12,   499,    12,
     501,   584,   625,    20,   695,   845,     6,   824,     0,    70,
      20,   695,   682,   683,   684,    20,   686,   687,   154,   689,
       5,     6,   692,   178,    20,   695,    54,   182,   189,   626,
      67,   532,   193,   194,    95,    20,    20,   620,    67,    11,
      12,    78,    20,   734,   714,   713,    20,   713,   345,    20,
     734,   868,    11,    12,   871,   725,    48,    10,   119,   876,
       0,     8,   359,   360,   734,    10,   614,    18,   365,   692,
      18,   714,   695,    65,    66,   372,    18,     5,     6,    10,
      72,    10,    74,    10,    76,    77,     9,     5,     6,     4,
     533,    11,    12,   933,    18,    13,    24,    89,    90,    91,
     733,    93,    10,    14,   401,    16,    24,    20,    48,   812,
     195,   734,   104,    10,   106,    10,   108,   109,   786,    10,
     786,   418,     5,     6,   625,    65,    66,   164,    11,    10,
      58,    11,    72,    10,    74,   683,    76,    77,    10,   805,
      58,   880,   812,   586,   181,    78,     5,     6,   591,    89,
      90,    91,   181,    93,    13,    67,   826,     5,     6,   602,
      20,   827,     8,    11,   104,    24,   106,    10,   108,   109,
     467,    83,   469,   136,    93,    11,    12,   725,    10,   622,
     623,   624,    11,    12,   854,   104,   856,   106,   858,   108,
     109,   692,   186,   187,   695,   171,   190,   191,   495,    58,
     497,    10,   499,   114,   501,   854,    10,   856,   805,    10,
     186,   187,    10,   189,   190,   191,   695,     5,     6,     5,
       6,    20,   683,    11,   685,    11,   687,    20,   689,    20,
     827,    88,   900,   734,   900,   532,    20,     5,     6,    10,
     683,   684,   959,    11,   687,    48,   689,    20,   160,   966,
     161,    20,   164,     5,     6,   734,    28,    29,    30,    11,
     977,    11,    12,   175,   932,   177,   932,   932,   160,   181,
      20,    21,   184,    20,   185,    11,    12,   188,   189,    20,
      10,   192,   193,   194,     5,     6,   323,    11,    12,   959,
      11,     5,     6,   926,   206,   185,   966,    11,   188,   189,
      11,   191,   192,   900,   194,    11,    12,   977,    11,    12,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    11,
      12,   197,    52,    53,    11,   362,   363,     8,   625,    20,
     367,    61,     5,     6,    11,    12,   959,   374,    11,    11,
      12,    11,    12,   966,    58,   374,   375,    77,   377,    12,
     379,   380,   381,    83,   977,   186,   187,   394,   189,   190,
     191,   104,    20,   106,    20,   108,   109,   359,   360,   812,
      20,   101,    11,   365,    11,    12,   196,    11,    12,   109,
     372,    11,     8,   420,    15,   422,     8,    25,    26,    27,
      28,    29,    30,    31,    32,   692,    52,    53,   695,    17,
      10,    18,     8,   117,    11,    61,    20,   171,    11,   401,
      19,   854,   171,   856,   144,   858,    11,     8,    20,   359,
     360,    77,    20,    44,   154,   365,   418,    20,    49,    50,
      20,    52,   372,    54,    20,    20,   348,   734,    20,   185,
      20,    11,   188,   189,    20,   101,   192,   193,   194,    20,
     180,   363,    20,   109,     0,   292,    11,    11,   959,   189,
      12,   401,   374,     9,    11,   966,   198,    10,    29,    11,
      78,    10,     8,    19,    11,   467,   977,   469,   418,   117,
      11,    19,   394,    62,    11,    11,   171,    19,   144,    11,
      69,    10,    20,    11,   115,    19,   533,    20,   154,    19,
     773,   599,    81,   495,    20,   497,   858,   499,   300,   501,
     226,   423,   424,   608,   426,   382,   687,   689,   977,    65,
      66,   433,   434,    76,   180,   418,    72,   467,    74,   469,
      76,   420,   444,   189,   362,   441,   388,   183,   375,   522,
     532,   399,   532,   166,    90,    91,   125,    93,   159,   586,
     469,   130,   533,    11,    11,   495,    11,   497,   104,   499,
     106,   501,   108,   109,   143,   602,   470,    -1,    -1,   491,
      -1,    -1,    -1,   194,   195,    -1,   495,    -1,   497,    -1,
     499,    -1,   501,    -1,   613,   622,    -1,   624,    -1,    -1,
      -1,   428,   532,    -1,    -1,    -1,   508,   509,    -1,    -1,
     512,   513,   223,    -1,    -1,   226,   185,   186,   187,   188,
     189,   190,   191,   192,   193,   194,    -1,    -1,   185,   186,
     187,   533,   189,   190,   191,   192,    -1,    -1,   540,    -1,
      -1,    -1,    -1,   625,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   670,   671,    -1,    -1,    -1,   683,   193,   685,    -1,
     687,    -1,   689,     0,   683,    -1,    -1,   292,   687,    -1,
     689,    -1,   959,    -1,    -1,    -1,    -1,    -1,    -1,   966,
      -1,    -1,    -1,    -1,   586,    -1,    -1,    52,    53,   591,
     977,    -1,    14,    -1,    16,   625,    61,   308,   525,   310,
     602,    -1,   529,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     692,    -1,    77,   695,    -1,    -1,   543,    -1,    83,    -1,
     622,   623,   624,    -1,    -1,   552,    -1,   338,    65,    66,
      67,   633,    -1,    -1,    -1,    72,   101,    -1,    -1,    76,
      -1,   643,    64,    -1,   109,   572,    -1,    -1,    -1,    -1,
     375,    -1,   734,    90,    91,    -1,    93,    -1,    -1,    -1,
      -1,    -1,   692,    -1,    -1,   695,    -1,   104,    -1,   106,
      -1,   108,   109,    -1,    -1,    -1,    -1,   679,    -1,   144,
      -1,   683,   684,   105,    -1,   687,    -1,   689,    62,   154,
      -1,    -1,   114,    -1,    -1,    69,   698,   699,   700,   701,
     702,    -1,   124,   428,   734,    -1,    -1,    81,    -1,    -1,
      -1,    -1,    -1,    -1,   641,   180,    -1,   719,   645,    -1,
      -1,   723,   724,   725,   189,    -1,    -1,   854,    -1,   856,
     657,   858,    14,    -1,    16,   157,   372,    -1,    20,   161,
      62,    -1,   164,   670,   181,    -1,    -1,    69,    -1,    -1,
      -1,   125,    -1,    -1,    -1,    -1,   130,   876,    -1,    81,
      -1,    -1,   398,   185,    -1,   401,   188,   189,    -1,   143,
     192,   193,   194,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     707,   708,    64,    -1,   711,    -1,   788,    -1,   790,   716,
     717,   502,    -1,   504,    -1,    -1,    -1,    -1,    -1,   726,
     525,    -1,    -1,   125,   529,    -1,    -1,    -1,   130,    -1,
     812,    -1,    -1,    -1,   188,   189,    -1,    -1,   543,   193,
     194,   143,    -1,   105,    -1,    -1,    -1,   552,   464,    -1,
      -1,   467,   114,   469,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   843,   124,    -1,   846,   847,    -1,   572,    -1,    21,
      -1,    -1,    -1,    -1,    -1,    -1,   858,    -1,    -1,   495,
      -1,   497,    -1,   499,    36,   501,    38,   189,    -1,    -1,
     506,   193,   194,    -1,    -1,   157,    -1,   959,    50,   161,
      -1,    -1,   164,    -1,   966,    -1,    -1,   814,    -1,    -1,
      -1,    -1,    -1,    -1,    66,   977,    -1,    -1,    -1,    -1,
      72,    -1,    -1,   185,   831,    -1,   188,   189,    -1,    -1,
     192,   193,   194,    -1,    -1,   842,   641,    -1,    -1,    -1,
     645,   848,    -1,    -1,    -1,    -1,    -1,    -1,   100,   959,
      -1,   103,   657,    -1,    -1,   107,   966,   374,    -1,    -1,
     867,    -1,    -1,   870,   116,   670,    -1,   977,    -1,    -1,
      -1,   662,   663,   664,   665,    -1,    -1,    -1,   885,   886,
     887,   888,   889,   135,    -1,   967,    -1,    -1,   140,    10,
     897,   898,   899,    14,    -1,    16,    -1,    -1,    -1,    -1,
      -1,    -1,   707,   708,   986,    -1,   711,   159,    21,    -1,
     626,   716,   717,    -1,    -1,    -1,   923,   924,    -1,    -1,
      -1,   726,    -1,    36,    -1,    38,    -1,    -1,    -1,    -1,
      51,    -1,    -1,    -1,    -1,    -1,    -1,    50,   945,    60,
      -1,    -1,   949,    -1,    -1,    -1,    -1,    -1,    -1,    70,
      -1,    -1,   469,    66,    -1,    -1,    -1,    -1,    -1,    72,
     185,   186,   187,   188,   189,   190,   191,   192,    89,   194,
     761,    -1,    -1,    -1,    95,   982,    -1,    -1,   495,   695,
     497,    -1,   499,   990,   501,    62,    -1,   100,    -1,    -1,
     103,    -1,    69,   114,   107,    -1,    -1,    -1,   119,    -1,
     121,   122,    -1,   116,    81,    -1,    -1,    -1,    -1,   814,
      -1,    -1,    -1,   804,    -1,   806,    -1,    -1,   734,    -1,
      -1,    -1,   135,    -1,    -1,    -1,   831,   140,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   842,    -1,    -1,
     161,    -1,    -1,   848,    -1,   836,   159,    -1,   125,    -1,
      -1,    -1,    -1,   130,   175,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   867,    -1,   185,   870,   143,   188,   189,    -1,
      -1,   192,   193,   194,   195,    -1,   197,   198,   199,    -1,
     885,   886,   887,   888,   889,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   897,   898,   899,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,     5,     6,    -1,    -1,    -1,    -1,   185,   186,
     187,   827,   189,   190,   191,   192,   193,   194,   923,   924,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
     945,    -1,    -1,    -1,   949,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,     5,     6,    58,    -1,    -1,    10,    -1,
      -1,    -1,    14,    -1,    16,    58,   683,    -1,    20,   686,
     687,    -1,   689,    25,    26,    27,    -1,   982,    -1,    -1,
      -1,    -1,    34,    35,   900,   990,    -1,    -1,    40,    41,
      42,    43,    44,    45,    46,    -1,    -1,    -1,    -1,    51,
      52,    -1,    -1,    -1,    -1,    -1,    -1,    59,    60,    61,
      62,    -1,    64,    -1,   117,    67,    68,    69,    70,    -1,
      -1,    -1,    74,    75,   117,    -1,    -1,    -1,    -1,    81,
      -1,    -1,    -1,    -1,    -1,    87,    -1,    89,    -1,    91,
      -1,    93,    -1,    95,    -1,    -1,    -1,    99,    -1,   101,
     102,    -1,   104,   105,   106,    -1,   108,   109,   110,   111,
     112,   113,   114,   115,    -1,   117,   118,   119,   120,   121,
     122,    -1,   124,   125,    -1,    -1,   128,    -1,   130,    -1,
      -1,    -1,   134,    -1,    -1,    -1,    -1,    -1,    -1,   141,
     142,   143,   144,    -1,    -1,    -1,   148,   149,   150,    -1,
     152,   153,    -1,   155,   156,   157,   158,    -1,    -1,   161,
     162,    -1,   164,   165,   166,    -1,    -1,    -1,    -1,    -1,
     172,   173,   174,   175,   176,   177,    -1,    -1,   180,    -1,
      -1,    -1,   184,   185,   186,   187,   188,   189,   190,   191,
     192,   193,   194,   195,    -1,   197,   198,   199,     5,     6,
      -1,    -1,    -1,    10,    -1,    -1,    -1,    14,    -1,    16,
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
     197,   198,   199,     5,     6,    -1,    -1,    -1,    10,    -1,
      -1,    -1,    14,    -1,    16,    -1,    -1,    -1,    20,    -1,
      -1,    -1,    -1,    25,    26,    27,    -1,    -1,    -1,    -1,
      -1,    -1,    34,    35,    -1,    -1,    -1,    -1,    40,    41,
      42,    43,    44,    45,    46,    -1,    -1,    -1,    -1,    51,
      52,    -1,    -1,    -1,    -1,    -1,    -1,    59,    60,    61,
      62,    -1,    -1,    -1,    -1,    67,    68,    69,    70,    -1,
      -1,    -1,    74,    75,    -1,    -1,    -1,    -1,    -1,    81,
      -1,    -1,    -1,    -1,    -1,    87,    -1,    89,    -1,    91,
      -1,    93,    -1,    95,    -1,    -1,    -1,    99,    -1,   101,
     102,    -1,   104,    -1,   106,    -1,   108,   109,   110,   111,
     112,   113,   114,   115,    -1,   117,   118,   119,   120,   121,
     122,    -1,    -1,   125,    -1,    -1,   128,    -1,   130,    -1,
      -1,    -1,   134,    -1,    -1,    -1,    -1,    -1,    -1,   141,
     142,   143,   144,    -1,    -1,    -1,   148,   149,   150,    -1,
     152,   153,    -1,   155,   156,    -1,   158,    -1,    -1,   161,
     162,    -1,    -1,   165,   166,    -1,    -1,    -1,    -1,    -1,
     172,   173,   174,   175,   176,   177,    -1,    -1,   180,    -1,
      -1,    -1,   184,   185,   186,   187,   188,   189,   190,   191,
     192,   193,   194,   195,    -1,   197,   198,   199,     5,     6,
       7,    -1,    -1,    10,    -1,    -1,    -1,    14,    -1,    16,
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
     197,   198,   199,     5,     6,    -1,    -1,    -1,    10,    -1,
      -1,    -1,    14,    -1,    16,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    25,    26,    27,    -1,    -1,    -1,    -1,
      -1,    -1,    34,    35,    -1,    -1,    -1,    -1,    40,    41,
      42,    43,    44,    45,    46,    -1,    -1,    -1,    -1,    51,
      52,    -1,    -1,    -1,    -1,    -1,    -1,    59,    60,    61,
      62,    -1,    -1,    -1,    -1,    67,    68,    69,    70,    -1,
      -1,    -1,    74,    75,    -1,    -1,    -1,    -1,    -1,    81,
      -1,    -1,    -1,    -1,    -1,    87,    -1,    89,    90,    91,
      -1,    93,    -1,    95,    -1,    -1,    -1,    99,    -1,   101,
     102,    -1,   104,    -1,   106,    -1,   108,   109,   110,   111,
     112,   113,   114,   115,    -1,   117,   118,   119,   120,   121,
     122,    -1,    -1,   125,    -1,    -1,   128,    -1,   130,    -1,
      -1,    -1,   134,    -1,    -1,    -1,    -1,    -1,    -1,   141,
     142,   143,   144,    -1,    -1,    -1,   148,   149,   150,    -1,
     152,   153,    -1,   155,   156,    -1,   158,    -1,    -1,   161,
     162,    -1,    -1,   165,   166,    -1,    -1,    -1,    -1,    -1,
     172,   173,   174,   175,   176,   177,    -1,    -1,   180,    -1,
      -1,    -1,   184,   185,   186,   187,   188,   189,   190,   191,
     192,   193,   194,   195,    -1,   197,   198,   199,     5,     6,
      -1,    -1,    -1,    10,    -1,    -1,    -1,    14,    -1,    16,
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
     197,   198,   199,     5,     6,    -1,    -1,    -1,    10,    -1,
      -1,    -1,    14,    -1,    16,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    25,    26,    27,    -1,    -1,    -1,    -1,
      -1,    -1,    34,    35,    -1,    -1,    -1,    -1,    40,    41,
      42,    43,    44,    45,    46,    -1,    -1,    -1,    -1,    51,
      52,    -1,    -1,    -1,    -1,    -1,    -1,    59,    60,    61,
      62,    -1,    -1,    -1,    -1,    67,    68,    69,    70,    -1,
      -1,    -1,    74,    75,    -1,    -1,    -1,    -1,    -1,    81,
      -1,    -1,    -1,    -1,    -1,    87,    -1,    89,    -1,    91,
      -1,    93,    -1,    95,    -1,    -1,    -1,    99,    -1,   101,
     102,    -1,   104,    -1,   106,    -1,   108,   109,   110,   111,
     112,   113,   114,   115,    -1,   117,   118,   119,   120,   121,
     122,    -1,    -1,   125,    -1,    -1,   128,    -1,   130,    -1,
      -1,    -1,   134,    -1,    -1,    -1,    -1,    -1,    -1,   141,
     142,   143,   144,    -1,    -1,    -1,   148,   149,   150,    -1,
     152,   153,    -1,   155,   156,    -1,   158,    -1,    -1,   161,
     162,    -1,    -1,   165,   166,    -1,    -1,    -1,    -1,    -1,
     172,   173,   174,   175,   176,   177,    -1,    -1,   180,    -1,
      -1,    -1,   184,   185,   186,   187,   188,   189,   190,   191,
     192,   193,   194,   195,    -1,   197,   198,   199,     5,     6,
      -1,    -1,    -1,    10,    -1,    -1,    -1,    14,    -1,    16,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    25,    26,
      27,    -1,    -1,    -1,    -1,    -1,    -1,    34,    35,    -1,
      -1,    -1,    -1,    40,    41,    42,    43,    44,    45,    46,
      -1,    -1,    -1,    -1,    51,    52,    -1,    -1,    -1,    -1,
      -1,    -1,    59,    60,    61,    62,    -1,    -1,    -1,    -1,
      67,    68,    69,    70,    -1,    -1,    -1,    74,    75,    -1,
      -1,    -1,    -1,    -1,    81,    -1,    -1,    -1,    -1,    -1,
      87,    -1,    89,    -1,    91,    -1,    -1,    -1,    95,    -1,
      -1,    -1,    99,    -1,   101,   102,    -1,   104,    -1,   106,
      -1,   108,   109,   110,   111,   112,   113,    -1,   115,    -1,
     117,    -1,   119,   120,   121,   122,    -1,    -1,   125,    -1,
      -1,   128,    -1,   130,    -1,    -1,    -1,   134,    -1,    -1,
      -1,    -1,    -1,    -1,   141,   142,   143,   144,    -1,    -1,
      -1,   148,   149,   150,    -1,   152,   153,    -1,   155,   156,
      -1,   158,    -1,    -1,   161,   162,    -1,    -1,   165,   166,
      -1,    -1,    -1,    -1,    -1,   172,   173,   174,   175,   176,
     177,    -1,    -1,   180,    -1,    -1,    -1,   184,   185,   186,
     187,   188,   189,   190,   191,   192,   193,   194,   195,    -1,
     197,   198,   199,     5,     6,    -1,    -1,    -1,    10,    -1,
      -1,    -1,    14,    -1,    16,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    25,    26,    27,    -1,    -1,    -1,    -1,
      -1,    -1,    34,    35,    -1,    -1,    -1,    -1,    40,    41,
      42,    43,    44,    45,    46,    -1,    -1,    -1,    -1,    51,
      52,    -1,    -1,    -1,    -1,    -1,    -1,    59,    -1,    -1,
      62,    -1,    -1,    -1,    -1,    67,    68,    69,    70,    -1,
      -1,    -1,    74,    75,    -1,    -1,    -1,    -1,    -1,    81,
      -1,    -1,    -1,    -1,    -1,    87,    -1,    89,    -1,    91,
      -1,    -1,    -1,    95,    -1,    -1,    -1,    99,    -1,   101,
     102,    -1,   104,    -1,    -1,    -1,   108,   109,   110,   111,
     112,   113,    -1,   115,    -1,   117,    -1,   119,   120,   121,
     122,    -1,    -1,   125,    -1,    -1,   128,    -1,   130,    -1,
      -1,    -1,   134,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     142,   143,   144,    -1,    -1,    -1,   148,   149,   150,    -1,
     152,   153,    -1,   155,   156,    -1,   158,    -1,    -1,   161,
     162,    -1,    -1,   165,   166,    -1,    -1,    -1,    -1,    -1,
     172,   173,    -1,   175,   176,   177,    -1,    -1,   180,    -1,
      -1,    -1,   184,   185,   186,   187,    -1,   189,   190,   191,
     192,   193,   194,     5,     6,   197,   198,   199,    10,    -1,
      -1,    -1,    14,    -1,    16,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    34,    35,    -1,    -1,    -1,    -1,    40,    41,
      42,    43,    44,    45,    46,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    59,    60,    61,
      62,    -1,    -1,    -1,    -1,    67,    68,    69,    -1,    -1,
      -1,    -1,    74,    75,    -1,    -1,    -1,    -1,    -1,    81,
      -1,    -1,    -1,    -1,    -1,    87,    -1,    -1,    -1,    91,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    99,    -1,   101,
     102,    -1,   104,    -1,   106,    -1,   108,   109,   110,   111,
     112,   113,    -1,   115,    -1,    -1,    -1,    -1,   120,    -1,
      -1,    -1,    -1,   125,    -1,    -1,   128,    -1,   130,    -1,
      -1,    -1,   134,    -1,    -1,    -1,    -1,    -1,    -1,   141,
     142,   143,   144,    -1,    -1,    -1,   148,   149,   150,    -1,
     152,   153,    -1,   155,   156,    -1,   158,    -1,    -1,    -1,
     162,    -1,    -1,   165,   166,    -1,    -1,    -1,    -1,    -1,
     172,   173,   174,    -1,   176,   177,    -1,    -1,   180,     5,
       6,    -1,    -1,    -1,    10,   187,   188,   189,    14,   191,
      16,   193,   194,   195,    -1,   197,   198,   199,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    34,    35,
      -1,    -1,    -1,    -1,    40,    41,    42,    43,    44,    45,
      46,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    59,    -1,    -1,    62,    -1,    -1,    -1,
      -1,    67,    68,    69,    -1,    -1,    -1,    -1,    74,    75,
      -1,    -1,    -1,    -1,    -1,    81,    -1,    -1,    -1,    -1,
      -1,    87,    -1,    -1,    -1,    91,    92,    -1,    -1,    -1,
      -1,    -1,    -1,    99,    -1,   101,   102,    -1,   104,    -1,
      -1,    -1,   108,   109,   110,   111,   112,   113,    -1,   115,
      -1,    -1,    -1,    -1,   120,    -1,    -1,    -1,    -1,   125,
      -1,    -1,   128,    -1,   130,    -1,    -1,    -1,   134,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   142,   143,   144,    -1,
      -1,    -1,   148,   149,   150,    -1,   152,   153,    -1,   155,
     156,    -1,   158,    -1,    -1,    -1,   162,    -1,    -1,   165,
     166,    -1,    -1,    -1,    -1,    -1,   172,   173,    -1,    -1,
     176,   177,   178,    -1,   180,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   189,    -1,   191,    -1,   193,   194,    -1,
      -1,   197,   198,   199,     5,     6,     7,    11,    -1,    10,
      -1,    -1,    13,    14,    -1,    16,    -1,    36,    -1,    38,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    -1,
      -1,    50,    -1,    34,    35,    -1,    -1,    -1,    -1,    40,
      41,    42,    43,    44,    45,    46,    -1,    66,    -1,    -1,
      -1,    -1,    -1,    72,    58,    -1,    -1,    -1,    59,    -1,
      -1,    62,    -1,    -1,    83,    -1,    67,    68,    69,    -1,
      -1,    -1,    -1,    74,    75,    -1,    -1,    -1,    -1,    -1,
      81,   100,    -1,    -1,   103,    -1,    87,    -1,   107,    -1,
      91,    -1,    -1,    -1,    -1,    -1,    -1,   116,    99,    -1,
     101,   102,    -1,   104,    -1,    -1,    -1,   108,   109,   110,
     111,   112,   113,   117,   115,    -1,   135,    -1,    -1,   120,
      -1,   140,    -1,    -1,   125,    -1,    -1,   128,    -1,   130,
      -1,    -1,    -1,   134,    -1,    -1,    -1,    -1,    -1,    -1,
     159,   142,   143,   144,    -1,    -1,    -1,   148,   149,   150,
      -1,   152,   153,    -1,   155,   156,    -1,   158,    -1,    -1,
      -1,   162,    -1,    -1,   165,   166,    -1,    -1,    -1,    -1,
      -1,   172,   173,    -1,    -1,   176,   177,    -1,    -1,   180,
       5,     6,     7,    -1,    -1,    10,    -1,    -1,   189,    14,
     191,    16,   193,   194,    -1,    -1,   197,   198,   199,    -1,
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
     165,   166,    -1,    -1,    -1,    -1,    -1,   172,   173,     5,
       6,   176,   177,    -1,    10,   180,    -1,    13,    14,    -1,
      16,    -1,    -1,    -1,   189,    -1,   191,    -1,   193,   194,
      -1,    -1,   197,   198,   199,    -1,    -1,    -1,    34,    35,
      -1,    -1,    -1,    -1,    40,    41,    42,    43,    44,    45,
      46,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    59,    -1,    -1,    62,    -1,    -1,    -1,
      -1,    67,    68,    69,    -1,    -1,    -1,    -1,    74,    75,
      -1,    -1,    -1,    -1,    -1,    81,    -1,    -1,    -1,    -1,
      -1,    87,    -1,    -1,    -1,    91,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    99,    -1,   101,   102,    -1,   104,    -1,
      -1,    -1,   108,   109,   110,   111,   112,   113,    -1,   115,
      -1,    -1,    -1,    -1,   120,    -1,    -1,    -1,    -1,   125,
      -1,    -1,   128,    -1,   130,    -1,    -1,    -1,   134,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   142,   143,   144,    -1,
      -1,    -1,   148,   149,   150,    -1,   152,   153,    -1,   155,
     156,    -1,   158,    -1,    -1,    -1,   162,    -1,    -1,   165,
     166,    -1,    -1,    -1,    -1,    -1,   172,   173,     5,     6,
     176,   177,    -1,    10,   180,    -1,    -1,    14,    -1,    16,
      -1,    -1,    -1,   189,    -1,   191,    -1,   193,   194,    -1,
      -1,   197,   198,   199,    -1,    -1,    -1,    34,    35,    -1,
      -1,    -1,    -1,    40,    41,    42,    43,    44,    45,    46,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    59,    -1,    -1,    62,    -1,    -1,    -1,    -1,
      67,    68,    69,    -1,    -1,    -1,    -1,    74,    75,    -1,
      -1,    -1,    -1,    -1,    81,    -1,    -1,    -1,    -1,    -1,
      87,    -1,    -1,    -1,    91,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    99,    -1,   101,   102,    -1,   104,    -1,    -1,
      -1,   108,   109,   110,   111,   112,   113,    -1,   115,    -1,
      -1,    -1,    -1,   120,    -1,    -1,    -1,    -1,   125,    -1,
      -1,   128,    -1,   130,     0,    -1,    -1,   134,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   142,   143,   144,    14,    -1,
      16,   148,   149,   150,    20,   152,   153,    -1,   155,   156,
      -1,   158,    -1,    -1,    -1,   162,    -1,    33,   165,   166,
      -1,    -1,    -1,    -1,    -1,   172,   173,    -1,    -1,   176,
     177,    -1,    -1,   180,    -1,    -1,    -1,    -1,    -1,    55,
      56,    -1,   189,    -1,   191,    -1,   193,   194,    -1,    -1,
     197,   198,   199,    -1,    -1,    71,    -1,    -1,    -1,    -1,
      76,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      86,    -1,    -1,    -1,    90,    -1,    -1,    93,    94,    -1,
      96,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,
      -1,    -1,    -1,    -1,    -1,   121,   122,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   131,   132,    -1,    -1,    -1,
     136,   137,   138,   139,    -1,    -1,    -1,    -1,    -1,   145,
     146,   147,    -1,    -1,    -1,   151,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   160,   161,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   169,    -1,     7,     8,    -1,    10,    -1,
      -1,    -1,    14,   179,    16,   181,    36,   183,    38,   185,
     186,   187,   188,   189,   190,   191,   192,   193,   194,    -1,
      50,    -1,    34,    35,    -1,    -1,    -1,    -1,    40,    41,
      42,    43,    44,    45,    46,    -1,    66,    -1,    -1,    -1,
      -1,    -1,    72,    -1,    -1,    -1,    -1,    59,    -1,    -1,
      62,    -1,    -1,    -1,    -1,    67,    68,    69,    -1,    -1,
      -1,    -1,    74,    75,    -1,    -1,    -1,    -1,    -1,    81,
     100,    -1,    -1,   103,    -1,    87,    -1,   107,    -1,    91,
      -1,    -1,    -1,    -1,    -1,    -1,   116,    99,    -1,   101,
     102,    -1,   104,    -1,    -1,    -1,   108,   109,   110,   111,
     112,   113,    -1,   115,    -1,   135,    -1,    -1,   120,    -1,
     140,    -1,    -1,   125,    -1,    -1,   128,    -1,   130,    -1,
      -1,    -1,   134,    -1,    -1,    -1,    -1,    -1,    -1,   159,
     142,   143,   144,    -1,    -1,    -1,   148,   149,   150,    -1,
     152,   153,    -1,   155,   156,    -1,   158,    -1,    -1,    -1,
     162,    -1,    -1,   165,   166,    -1,    -1,    -1,    -1,    -1,
     172,   173,    -1,    -1,   176,   177,    10,    -1,   180,    -1,
      14,    -1,    16,    -1,    -1,    -1,    -1,   189,    -1,   191,
      -1,   193,   194,    -1,    -1,   197,   198,   199,    -1,    -1,
      34,    35,    -1,    -1,    -1,    -1,    40,    41,    42,    43,
      44,    45,    46,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    59,    -1,    -1,    62,    -1,
      -1,    -1,    -1,    67,    68,    69,    -1,    -1,    -1,    -1,
      74,    75,    -1,    -1,    -1,    -1,    -1,    81,    -1,    -1,
      -1,    -1,    -1,    87,    -1,    -1,    -1,    91,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    99,    -1,   101,   102,    -1,
     104,    -1,    -1,    -1,   108,   109,   110,   111,   112,   113,
      -1,   115,    -1,    -1,    -1,    -1,   120,    -1,    -1,    -1,
      -1,   125,    -1,    -1,   128,    -1,   130,    -1,    -1,    -1,
     134,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   142,   143,
     144,    -1,    -1,    -1,   148,   149,   150,    -1,   152,   153,
      -1,   155,   156,    -1,   158,    14,    -1,    16,   162,    -1,
      -1,   165,   166,    -1,    -1,    -1,    -1,    -1,   172,   173,
      -1,    -1,   176,   177,    -1,    -1,   180,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   189,    -1,   191,    -1,   193,
     194,    -1,    51,   197,   198,   199,    -1,    -1,    10,    -1,
      -1,    60,    14,    62,    16,    -1,    -1,    -1,    -1,    -1,
      69,    70,    -1,    25,    26,    27,    -1,    -1,    -1,    -1,
      -1,    -1,    81,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      89,    -1,    -1,    -1,    -1,    -1,    95,    -1,    -1,    51,
      52,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   114,    -1,    -1,    70,    -1,
     119,    73,   121,   122,    -1,    -1,   125,    -1,    -1,    -1,
      -1,   130,    -1,    -1,    -1,    -1,    -1,    89,    -1,    -1,
      -1,    10,    -1,    95,   143,    14,    -1,    16,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    25,    26,    27,    -1,
      -1,    -1,   161,    -1,    -1,   117,    -1,   119,    -1,   121,
     122,    -1,    -1,    -1,    -1,    -1,   175,    -1,    -1,    -1,
      -1,    -1,    51,    52,    -1,    -1,   185,   186,   187,   188,
     189,   190,   191,   192,   193,   194,   195,    -1,   197,   198,
     199,    70,    10,    -1,    -1,    -1,    14,    -1,    16,   161,
      -1,    -1,    -1,    -1,    -1,    10,    -1,    -1,    -1,    14,
      89,    16,    -1,   175,    -1,    -1,    95,    -1,    -1,    -1,
      -1,    -1,   184,   185,   186,   187,    -1,   189,   190,   191,
     192,    -1,    -1,    51,    52,    -1,    -1,    -1,   117,    -1,
     119,    -1,   121,   122,    -1,    -1,    51,    52,    -1,    -1,
      -1,    -1,    70,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    70,    -1,    -1,    -1,    -1,
      -1,    89,    -1,    -1,    -1,    -1,    -1,    95,    -1,    -1,
      -1,    -1,   161,    14,    89,    16,    -1,    -1,    -1,    20,
      95,    -1,    -1,    -1,    -1,    -1,   175,    -1,    -1,    -1,
      -1,   119,    33,   121,   122,   184,   185,   186,   187,    -1,
     189,   190,   191,   192,   119,    -1,   121,   122,    -1,    -1,
      -1,    -1,    -1,    -1,    55,    56,    -1,    -1,    -1,    -1,
      -1,    -1,    63,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      71,    -1,    -1,   161,    -1,    76,    -1,    -1,    -1,    80,
      -1,    -1,    -1,    -1,    -1,    86,   161,   175,    -1,    90,
      -1,    -1,    93,    94,    -1,    96,   184,   185,   186,   187,
     175,   189,   190,   191,   192,    -1,    -1,    -1,    -1,   184,
     185,   186,   187,   114,   189,   190,   191,   192,    -1,    -1,
     121,   122,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     131,   132,    -1,    -1,    -1,   136,   137,   138,   139,    -1,
      -1,    -1,    -1,    -1,   145,   146,   147,    -1,    -1,    -1,
     151,    -1,    -1,    -1,    -1,    14,    -1,    16,    -1,   160,
     161,    20,    -1,    -1,    -1,    -1,    -1,    -1,   169,    -1,
      -1,    -1,    -1,    -1,    33,    -1,    -1,    -1,   179,    -1,
     181,    -1,   183,    -1,   185,   186,   187,   188,   189,   190,
     191,   192,   193,   194,    -1,    -1,    55,    56,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    71,    -1,    -1,    -1,    -1,    76,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    86,    -1,    -1,
      -1,    90,    -1,    -1,    93,    94,    -1,    96,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,    -1,
      -1,    -1,   121,   122,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   131,   132,    -1,    -1,    -1,   136,   137,   138,
     139,    -1,    -1,    -1,    -1,    -1,   145,   146,   147,    -1,
      -1,    -1,   151,    -1,    -1,    -1,    -1,    14,    -1,    16,
      -1,   160,   161,    20,    -1,    -1,    -1,    -1,    -1,    -1,
     169,    -1,    -1,    -1,    -1,    -1,    33,    -1,    -1,    -1,
     179,    -1,   181,    -1,   183,    -1,   185,   186,   187,   188,
     189,   190,   191,   192,   193,   194,    -1,    -1,    55,    56,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    76,
      -1,    -1,    79,    -1,    -1,    -1,    -1,    -1,    -1,    86,
      -1,    -1,    -1,    90,    -1,    -1,    93,    94,    -1,    96,
      -1,    -1,    -1,    14,    -1,    16,    -1,    -1,    -1,    20,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,    -1,
      -1,    -1,    33,    -1,   121,   122,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   131,   132,    -1,    -1,    -1,   136,
      -1,   138,   139,    -1,    55,    56,    -1,    -1,   145,   146,
     147,    -1,    -1,    -1,   151,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   161,    76,    -1,    -1,    79,    -1,
      -1,   168,   169,    -1,    -1,    86,    -1,    88,    -1,    90,
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
      -1,    -1,    -1,    -1,    -1,    -1,    86,    -1,    88,    -1,
      90,    -1,    -1,    -1,    94,    -1,    96,    -1,    -1,    -1,
      14,    -1,    16,    -1,    -1,    -1,    20,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,    -1,    33,
      -1,   121,   122,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   131,   132,    -1,    -1,    -1,   136,    -1,   138,   139,
      -1,    55,    56,    -1,    -1,   145,   146,   147,    -1,    -1,
      -1,   151,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   161,    76,    -1,    -1,    -1,    -1,   167,    -1,   169,
      -1,    -1,    86,    -1,    88,    -1,    90,    -1,    -1,   179,
      94,   181,    96,   183,    -1,   185,   186,   187,   188,   189,
     190,   191,   192,   193,   194,    -1,    -1,    -1,    -1,    -1,
     114,    -1,    -1,    -1,    -1,    -1,    -1,   121,   122,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   131,   132,    -1,
      -1,    14,   136,    16,   138,   139,    -1,    20,    -1,    -1,
      -1,   145,   146,   147,    -1,    -1,    -1,   151,    -1,    -1,
      33,    -1,    -1,    -1,    -1,    -1,    -1,   161,    -1,    -1,
      -1,    -1,    -1,   167,    -1,   169,    -1,    -1,    -1,    -1,
      -1,    -1,    55,    56,    -1,   179,    -1,   181,    -1,   183,
      63,   185,   186,   187,   188,   189,   190,   191,   192,   193,
     194,    -1,    -1,    76,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    86,    -1,    -1,    -1,    90,    -1,    -1,
      93,    94,    -1,    96,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   114,    -1,    -1,    -1,    -1,    -1,    -1,   121,   122,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   131,   132,
      -1,    -1,    14,   136,    16,   138,   139,    -1,    20,    -1,
      -1,    -1,   145,   146,   147,    -1,    -1,    -1,   151,    -1,
      -1,    33,    -1,    -1,    -1,    -1,    -1,    -1,   161,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   169,    -1,    -1,    -1,
      -1,    -1,    -1,    55,    56,    -1,   179,    -1,   181,    -1,
     183,    -1,   185,   186,   187,   188,   189,   190,   191,   192,
     193,   194,    -1,    -1,    76,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    86,    -1,    -1,    -1,    90,    -1,
      -1,    93,    94,    -1,    96,    -1,    -1,    -1,    14,    -1,
      16,    -1,    -1,    -1,    20,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   114,    -1,    -1,    -1,    -1,    33,    -1,   121,
     122,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   131,
     132,    -1,    -1,    -1,   136,    -1,   138,   139,    -1,    55,
      56,    -1,    -1,   145,   146,   147,    -1,    -1,    -1,   151,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   161,
      76,    -1,    -1,    79,    -1,    -1,    -1,   169,    -1,    -1,
      86,    -1,    -1,    -1,    90,    -1,    -1,   179,    94,   181,
      96,   183,    -1,   185,   186,   187,   188,   189,   190,   191,
     192,   193,   194,    -1,    -1,    -1,    -1,    -1,   114,    -1,
      -1,    -1,    -1,    -1,    -1,   121,   122,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   131,   132,    -1,    -1,    14,
     136,    16,   138,   139,    -1,    20,    -1,    -1,    -1,   145,
     146,   147,    -1,    -1,    -1,   151,    -1,    -1,    33,    -1,
      -1,    -1,    -1,    -1,    -1,   161,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   169,    -1,    -1,    -1,    -1,    -1,    -1,
      55,    56,    -1,   179,    -1,   181,    -1,   183,    63,   185,
     186,   187,   188,   189,   190,   191,   192,   193,   194,    -1,
      -1,    76,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    86,    -1,    -1,    -1,    90,    -1,    -1,    -1,    94,
      -1,    96,    -1,    -1,    -1,    14,    -1,    16,    -1,    -1,
      -1,    20,    -1,    -1,    -1,    14,    -1,    16,    -1,   114,
      -1,    -1,    -1,    -1,    33,    -1,   121,   122,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   131,   132,    -1,    -1,
      -1,   136,    -1,   138,   139,    -1,    55,    56,    -1,    -1,
     145,   146,   147,    -1,    -1,    -1,   151,    -1,    -1,    -1,
      -1,    -1,    -1,    62,    -1,    -1,   161,    76,    -1,    -1,
      69,    -1,    -1,    -1,   169,    -1,    -1,    86,    -1,    -1,
      -1,    90,    81,    -1,   179,    94,   181,    96,   183,    -1,
     185,   186,   187,   188,   189,   190,   191,   192,   193,   194,
      14,    -1,    16,    -1,    -1,   114,    -1,    -1,    -1,    -1,
      -1,    -1,   121,   122,    -1,   114,    -1,    -1,    -1,   118,
      -1,    -1,   131,   132,    -1,    -1,   125,   136,    -1,   138,
     139,   130,    -1,    -1,    -1,    -1,   145,   146,   147,    -1,
      -1,    -1,   151,    -1,   143,    -1,    -1,    -1,    62,    -1,
      -1,    -1,   161,    -1,    -1,    69,    -1,    -1,    -1,    -1,
     169,    -1,   161,    -1,    -1,    -1,    -1,    81,    -1,    -1,
     179,    -1,   181,    -1,   183,    -1,   185,   186,   187,   188,
     189,   190,   191,   192,   193,   194,   185,   186,   187,   188,
     189,   190,   191,   192,   193,   194,    -1,    -1,    -1,    -1,
     114,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   125,    -1,    -1,    -1,    -1,   130,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   143,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   161,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   185,   186,   187,   188,   189,   190,   191,   192,   193,
     194,    36,    -1,    38,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    47,    -1,    -1,    50,    -1,    52,    53,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    61,    -1,    -1,    -1,
      -1,    66,    -1,    -1,    -1,    -1,    -1,    72,    -1,    -1,
      -1,    -1,    77,    -1,    -1,    -1,    -1,    -1,    83,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    93,    -1,
      -1,    -1,    -1,    -1,    -1,   100,   101,    -1,   103,    -1,
      -1,    -1,   107,    -1,   109,    -1,    -1,    -1,    -1,    -1,
      -1,   116,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   127,    -1,   129,    -1,    -1,    -1,    -1,    -1,
     135,    36,    -1,    38,    -1,   140,    -1,    -1,    -1,   144,
      -1,    -1,    47,    -1,    -1,    50,    -1,    52,    53,   154,
      -1,    -1,    -1,    -1,   159,    -1,    61,    -1,    -1,    -1,
      -1,    66,   167,    -1,    -1,    -1,    -1,    72,    -1,    -1,
      -1,    -1,    77,    -1,    -1,   180,    -1,    -1,    83,    -1,
     185,   186,   187,   188,   189,   190,   191,   192,    93,   194,
      -1,    -1,    -1,    -1,    -1,   100,   101,    -1,   103,    -1,
      -1,    36,   107,    38,   109,    -1,    -1,    -1,    -1,    -1,
      -1,   116,    -1,    -1,    -1,    50,    -1,    52,    53,    -1,
      -1,    -1,   127,    -1,   129,    -1,    61,    -1,    -1,    -1,
     135,    66,    -1,    -1,    -1,   140,    -1,    72,    -1,   144,
      -1,    -1,    77,    -1,    -1,    -1,    -1,    -1,    83,   154,
      -1,    -1,    -1,    -1,   159,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   167,    -1,    -1,   100,   101,    -1,   103,    -1,
      -1,    -1,   107,    -1,   109,   180,    -1,    -1,    -1,    -1,
      -1,   116,    -1,    -1,   189,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     135,    -1,    -1,    -1,    -1,   140,    -1,    -1,    -1,   144,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   154,
      -1,    -1,    -1,    -1,   159,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   180,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   189
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int16 yystos[] =
{
       0,    14,    16,    20,    33,    55,    56,    71,    76,    86,
      90,    93,    94,    96,   114,   121,   122,   131,   132,   136,
     137,   138,   139,   145,   146,   147,   151,   160,   161,   169,
     179,   181,   183,   185,   186,   187,   188,   189,   190,   191,
     192,   193,   194,   209,   220,   221,   244,   246,   251,   252,
     254,   255,   257,   263,   266,   268,   270,   271,   272,   273,
     274,   275,   276,   277,   279,   280,   281,   282,   289,   290,
     291,   292,   293,   294,   295,   296,   299,   301,   302,   303,
     304,   307,   308,   310,   311,   313,   314,   319,   320,   321,
     323,   358,   359,   360,   361,   362,   363,   366,   367,   375,
     378,   381,   384,   385,   386,   387,   388,   389,   390,   391,
     220,   275,   221,   190,   245,   255,   275,    36,    38,    47,
      50,    52,    53,    61,    66,    72,    77,    83,    93,   100,
     101,   103,   107,   109,   116,   127,   129,   135,   140,   144,
     154,   159,   167,   180,   186,   187,   189,   190,   191,   192,
     221,   227,   234,   254,   266,   276,   331,   332,   334,   335,
     336,   337,   338,   339,   340,   344,   345,   346,   348,   349,
     350,   351,   353,   355,   356,   357,    20,    57,    92,   178,
     182,   324,   325,   326,   329,    20,   255,    10,    20,   349,
     350,   351,   355,   171,    82,    82,    10,    10,    20,   255,
     221,   379,   246,   275,     5,     6,    10,    14,    16,    20,
      25,    26,    27,    34,    35,    40,    41,    42,    43,    44,
      45,    46,    51,    52,    59,    60,    61,    62,    67,    68,
      69,    70,    74,    75,    81,    87,    89,    91,    93,    95,
      99,   101,   102,   104,   106,   108,   109,   110,   111,   112,
     113,   115,   117,   118,   119,   120,   121,   122,   125,   128,
     130,   134,   141,   142,   143,   144,   148,   149,   150,   152,
     153,   155,   156,   158,   162,   165,   166,   172,   173,   174,
     175,   176,   177,   180,   184,   186,   187,   191,   195,   197,
     198,   199,   201,   202,   203,   204,   205,   206,   208,   209,
     210,   211,   212,   213,   214,   215,   216,   219,   222,   223,
     234,   235,   236,   237,   241,   243,   244,   245,   246,   247,
     248,   249,   250,   251,   253,   256,   260,   261,   262,   263,
     264,   265,   267,   268,   271,   273,   275,   245,    82,   246,
     246,   276,   382,   126,    10,    18,   224,   225,   228,   229,
     270,   273,   275,    10,   224,   224,    21,   224,   224,    10,
      12,    29,   278,    10,     8,    12,   224,   278,    20,   179,
     289,   290,   295,   289,    10,   201,   235,   237,   243,   260,
     267,   271,   284,   285,   286,   287,   289,    20,    39,    88,
     167,   179,   290,   291,    10,    20,    48,   297,    79,   168,
     292,   295,   300,   330,    20,    64,   105,   124,   157,   164,
     270,   305,   309,    20,   189,   219,   306,   309,    12,    20,
      12,    20,   278,    12,    10,    92,   178,   191,   201,   275,
      20,   245,   312,    49,    98,   122,   126,    12,    20,    73,
     315,   316,   317,   318,   324,    20,    10,    20,   211,   213,
     215,   245,   248,   264,   269,   270,   322,   333,   289,     0,
     292,   375,   378,   381,    63,    80,   292,   295,   364,   365,
     370,   371,   375,   378,   381,    20,    36,   140,    85,   133,
      65,    93,   127,   129,    10,   348,   368,   373,   374,   297,
     369,   373,   376,    20,   364,   365,   364,   365,   364,   365,
     364,   365,    15,     8,    17,   224,     8,    10,    10,    10,
      10,    10,    10,    10,    10,    10,   127,    83,   338,   114,
      20,    12,    12,   337,     7,   201,   347,   339,     7,   201,
     219,   341,   342,   343,   334,   189,   344,   338,     6,   352,
     354,   227,   347,   201,   168,   209,   275,   235,   284,    20,
      20,   325,   201,   327,    20,   211,    20,    20,    20,    20,
     255,    20,   224,    97,   163,   224,   211,   211,    20,    10,
      54,     8,   201,   235,   260,   275,   244,   275,   244,   275,
      28,   224,   258,   259,    10,   258,    10,    24,    58,   203,
     204,   242,   202,   202,     4,     7,     8,   205,     9,   207,
      18,   225,    10,    20,   224,   224,    22,   123,   238,   239,
      23,    39,   240,   242,    10,    14,    16,   241,   275,   250,
      10,   219,    10,   242,    10,    10,     8,    20,   224,    21,
     338,   344,   383,   171,   245,   211,    10,   209,   211,     7,
      13,   201,   230,   231,   232,   233,    11,    12,    20,    21,
      11,    10,   269,   270,   277,   219,   307,   201,   217,   218,
     219,   275,   220,   254,   257,   266,   276,   277,   219,    78,
     201,   260,   284,    28,    30,    31,    32,   243,   278,   288,
     170,   283,   288,    10,   288,   288,   288,   238,   283,   240,
     319,   217,    10,   255,   331,   295,   300,    20,    10,    10,
      10,    10,    10,   305,   306,   219,   275,   201,   201,    73,
     235,   201,    20,     8,    12,    20,   201,   201,   235,    10,
     136,    20,   318,    37,    84,    10,   201,   235,   275,    11,
      12,    20,   255,    88,   295,   364,    20,   292,   364,   371,
      20,   348,   185,   188,   189,   191,   192,   194,   372,   373,
     376,    20,   364,    20,   364,    20,   364,    20,   364,   224,
     224,   255,   347,   347,   347,   347,   212,   338,   338,   332,
      11,    12,    11,    13,    11,    12,    10,   270,   333,   341,
     160,   347,    11,    20,   221,   278,     8,    20,   171,   328,
      12,    20,    20,    97,   163,    11,    11,   221,   380,   196,
     377,    11,    11,    11,    15,     8,    17,    18,   211,   217,
     202,   202,    10,   187,   201,   261,   275,   202,   205,   205,
     206,    10,   217,   236,   237,   241,   243,     8,   211,    11,
     217,   201,   261,   217,   118,   269,   222,    20,   212,    21,
      12,    20,   201,   171,    11,    19,   226,    49,   201,   232,
     171,   203,   204,    11,   278,    20,    13,    11,    12,   224,
     224,   224,   224,    11,    28,    30,   278,   201,   237,   284,
     201,   260,   267,   190,   271,   275,   237,   285,   286,    20,
      11,   270,   275,   298,    20,   201,   201,   201,   201,   201,
      20,    20,    11,    20,    20,    20,   245,   201,   201,   201,
       8,    20,   221,    20,    11,    12,    20,    20,    20,    20,
     224,    11,    11,    11,    12,    11,   214,    11,    12,    10,
      11,    78,    29,   201,   201,    11,    12,   224,   224,    10,
      11,    11,     8,    19,    11,   241,    11,    11,    11,    11,
      11,   224,   212,   212,    20,   201,    19,   227,   249,   201,
     232,   202,   202,   219,   218,    11,    20,   297,    11,    12,
      11,    11,    11,    11,    11,    11,   171,    54,   221,    19,
     250,   227,    20,    11,    12,    11,    11,    10,    20,   270,
     275,   270,   201,   249,    12,    19,   226,   298,    20,    11,
     201,    11,    11,    20
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int16 yyr1[] =
{
       0,   200,   201,   201,   201,   201,   201,   202,   202,   203,
     204,   205,   205,   205,   205,   206,   206,   207,   208,   208,
     208,   208,   209,   209,   209,   209,   209,   209,   209,   209,
     210,   210,   210,   210,   210,   211,   211,   212,   213,   214,
     215,   215,   215,   215,   216,   216,   217,   217,   218,   218,
     218,   219,   219,   219,   219,   219,   220,   220,   221,   222,
     222,   222,   222,   222,   222,   223,   223,   223,   223,   223,
     223,   223,   223,   223,   223,   223,   223,   223,   223,   223,
     223,   223,   223,   223,   223,   223,   223,   223,   223,   223,
     223,   223,   223,   223,   223,   223,   223,   223,   223,   223,
     223,   223,   223,   223,   223,   223,   223,   223,   223,   223,
     223,   223,   224,   224,   224,   224,   225,   225,   225,   225,
     226,   226,   227,   227,   228,   228,   228,   228,   228,   229,
     229,   230,   230,   230,   230,   231,   232,   232,   233,   233,
     233,   234,   234,   234,   234,   235,   235,   236,   236,   237,
     237,   237,   237,   238,   238,   239,   240,   240,   241,   241,
     241,   241,   241,   241,   241,   241,   241,   241,   241,   242,
     242,   243,   243,   243,   243,   244,   244,   244,   244,   245,
     245,   245,   245,   246,   246,   246,   246,   247,   247,   248,
     248,   248,   248,   248,   249,   249,   249,   249,   250,   251,
     251,   252,   253,   253,   253,   254,   255,   255,   255,   255,
     256,   256,   257,   258,   258,   259,   260,   260,   260,   260,
     260,   261,   261,   261,   261,   262,   262,   263,   263,   263,
     263,   264,   264,   265,   265,   265,   265,   265,   266,   267,
     267,   267,   268,   269,   269,   269,   270,   270,   270,   270,
     270,   270,   270,   271,   271,   271,   271,   272,   273,   274,
     275,   275,   276,   277,   277,   277,   277,   278,   279,   279,
     280,   280,   281,   282,   283,   284,   284,   285,   285,   286,
     286,   286,   287,   287,   287,   287,   287,   288,   288,   288,
     288,   288,   288,   288,   288,   289,   289,   289,   290,   290,
     290,   290,   290,   290,   290,   290,   290,   290,   290,   290,
     290,   290,   290,   290,   290,   290,   290,   290,   290,   290,
     290,   290,   290,   290,   290,   290,   290,   290,   290,   290,
     290,   290,   290,   290,   290,   290,   290,   290,   290,   291,
     291,   291,   292,   292,   293,   293,   294,   294,   294,   294,
     295,   296,   297,   298,   298,   298,   298,   299,   299,   299,
     299,   299,   299,   299,   299,   300,   300,   300,   301,   301,
     302,   303,   303,   304,   304,   305,   305,   306,   306,   306,
     307,   308,   309,   309,   309,   309,   309,   310,   311,   311,
     312,   312,   313,   313,   313,   313,   314,   314,   314,   315,
     315,   315,   316,   316,   316,   317,   318,   318,   319,   319,
     319,   320,   321,   321,   322,   322,   323,   324,   324,   325,
     325,   326,   326,   327,   327,   328,   328,   329,   329,   330,
     331,   331,   332,   332,   333,   333,   333,   333,   334,   334,
     334,   335,   335,   335,   335,   335,   336,   336,   337,   337,
     337,   338,   338,   339,   339,   339,   339,   339,   339,   339,
     339,   339,   339,   339,   339,   340,   340,   340,   341,   341,
     341,   341,   341,   342,   343,   343,   344,   344,   344,   344,
     344,   344,   344,   344,   345,   345,   345,   345,   345,   345,
     345,   345,   346,   347,   347,   348,   348,   348,   348,   348,
     349,   349,   350,   351,   352,   352,   353,   354,   355,   355,
     355,   356,   356,   357,   357,   358,   358,   358,   358,   358,
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
       0,     2,     1,     2,     2,     3,     3,     1,     3,     1,
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
       1,     1,     2,     1,     2,     2,     5,     5,     8,     5,
       1,     2,     1,     1,     2,     5,     2,     2,     2,     1,
       2,     1,     1,     2,     3,     2,     1,     1,     1,     3,
       3,     1,     1,     1,     1,     1,     3,     1,     3,     1,
       3,     2,     4,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     3,     3,     4,     3,     4,     3,     4,     1,
       1,     1,     1,     1,     1,     1,     2,     3,     4,     1,
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
       4,     1,     3,     3,     3,     3,     3,     1,     2,     1,
       1,     1,     1,     2,     2,     1,     1,     1,     2,     2,
       2,     3,     2,     3,     4,     1,     2,     5,     6,     9,
       2,     3,     3,     2,     2,     2,     2,     4,     4,     4,
       4,     3,     4,     4,     2,     3,     5,     6,     2,     3,
       2,     4,     3,     2,     4,     4,     3,     2,     4,     1,
       2,     2,     1,     1,     3,     2,     4,     4,     3,     3,
       2,     2,     1,     1,     3,     1,     3,     2,     3,     4,
       3,     4,     2,     2,     2,     1,     2,     2,     4,     4,
       4,     2,     3,     2,     3,     1,     1,     1,     1,     1,
       4,     3,     4,     4,     4,     4,     4,     1,     1,     1,
       1,     3,     2,     3,     3,     3,     1,     5,     2,     1,
       1,     2,     3,     3,     1,     2,     2,     2,     2,     2,
       2,     2,     2,     3,     1,     1,     5,     1,     1,     2,
       2,     3,     2,     1,     3,     2,     4,     3,     4,     3,
       1,     3,     1,     2,     1,     1,     1,     1,     2,     1,
       1,     3,     1,     1,     1,     1,     2,     3,     1,     2,
       1,     1,     2,     1,     1,     1,     1,     1,     4,     1,
       1,     3,     3,     1,     4,     2,     2,     3,     1,     2,
       2,     3,     1,     3,     2,     3,     1,     2,     3,     2,
       2,     3,     1,     2,     1,     2,     1,     1,     1,     1,
       1,     1,     2,     1,     1,     1,     1,     1,     1,     1,
       1,     4,     4,     2,     2,     3,     1,     3,     1,     1,
       2,     3,     1,     2,     4,     1,     2,     1,     2,     1,
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
  case 2: /* ARITH_EXP: TERM  */
#line 645 "HAL_S.y"
                 { (yyval.arith_exp_) = make_AAarithExpTerm((yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4116 "Parser.c"
    break;

  case 3: /* ARITH_EXP: PLUS TERM  */
#line 646 "HAL_S.y"
              { (yyval.arith_exp_) = make_ABarithExpPlusTerm((yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4122 "Parser.c"
    break;

  case 4: /* ARITH_EXP: MINUS TERM  */
#line 647 "HAL_S.y"
               { (yyval.arith_exp_) = make_ACarithMinusTerm((yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4128 "Parser.c"
    break;

  case 5: /* ARITH_EXP: ARITH_EXP PLUS TERM  */
#line 648 "HAL_S.y"
                        { (yyval.arith_exp_) = make_ADarithExpArithExpPlusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4134 "Parser.c"
    break;

  case 6: /* ARITH_EXP: ARITH_EXP MINUS TERM  */
#line 649 "HAL_S.y"
                         { (yyval.arith_exp_) = make_AEarithExpArithExpMinusTerm((yyvsp[-2].arith_exp_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.arith_exp_)->line_number = (yyloc).first_line; (yyval.arith_exp_)->char_number = (yyloc).first_column;  }
#line 4140 "Parser.c"
    break;

  case 7: /* TERM: PRODUCT  */
#line 651 "HAL_S.y"
               { (yyval.term_) = make_AAtermNoDivide((yyvsp[0].product_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4146 "Parser.c"
    break;

  case 8: /* TERM: PRODUCT _SYMB_0 TERM  */
#line 652 "HAL_S.y"
                         { (yyval.term_) = make_ABtermDivide((yyvsp[-2].product_), (yyvsp[0].term_)); (yyval.term_)->line_number = (yyloc).first_line; (yyval.term_)->char_number = (yyloc).first_column;  }
#line 4152 "Parser.c"
    break;

  case 9: /* PLUS: _SYMB_1  */
#line 654 "HAL_S.y"
               { (yyval.plus_) = make_AAplus(); (yyval.plus_)->line_number = (yyloc).first_line; (yyval.plus_)->char_number = (yyloc).first_column;  }
#line 4158 "Parser.c"
    break;

  case 10: /* MINUS: _SYMB_2  */
#line 656 "HAL_S.y"
                { (yyval.minus_) = make_AAminus(); (yyval.minus_)->line_number = (yyloc).first_line; (yyval.minus_)->char_number = (yyloc).first_column;  }
#line 4164 "Parser.c"
    break;

  case 11: /* PRODUCT: FACTOR  */
#line 658 "HAL_S.y"
                 { (yyval.product_) = make_AAproductSingle((yyvsp[0].factor_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4170 "Parser.c"
    break;

  case 12: /* PRODUCT: FACTOR _SYMB_3 PRODUCT  */
#line 659 "HAL_S.y"
                           { (yyval.product_) = make_ABproductCross((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4176 "Parser.c"
    break;

  case 13: /* PRODUCT: FACTOR _SYMB_4 PRODUCT  */
#line 660 "HAL_S.y"
                           { (yyval.product_) = make_ACproductDot((yyvsp[-2].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4182 "Parser.c"
    break;

  case 14: /* PRODUCT: FACTOR PRODUCT  */
#line 661 "HAL_S.y"
                   { (yyval.product_) = make_ADproductMultiplication((yyvsp[-1].factor_), (yyvsp[0].product_)); (yyval.product_)->line_number = (yyloc).first_line; (yyval.product_)->char_number = (yyloc).first_column;  }
#line 4188 "Parser.c"
    break;

  case 15: /* FACTOR: PRIMARY  */
#line 663 "HAL_S.y"
                 { (yyval.factor_) = make_AAfactor((yyvsp[0].primary_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4194 "Parser.c"
    break;

  case 16: /* FACTOR: PRIMARY EXPONENTIATION FACTOR  */
#line 664 "HAL_S.y"
                                  { (yyval.factor_) = make_ABfactorExponentiation((yyvsp[-2].primary_), (yyvsp[-1].exponentiation_), (yyvsp[0].factor_)); (yyval.factor_)->line_number = (yyloc).first_line; (yyval.factor_)->char_number = (yyloc).first_column;  }
#line 4200 "Parser.c"
    break;

  case 17: /* EXPONENTIATION: _SYMB_5  */
#line 666 "HAL_S.y"
                         { (yyval.exponentiation_) = make_AAexponentiation(); (yyval.exponentiation_)->line_number = (yyloc).first_line; (yyval.exponentiation_)->char_number = (yyloc).first_column;  }
#line 4206 "Parser.c"
    break;

  case 18: /* PRIMARY: ARITH_VAR  */
#line 668 "HAL_S.y"
                    { (yyval.primary_) = make_AAprimary((yyvsp[0].arith_var_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4212 "Parser.c"
    break;

  case 19: /* PRIMARY: PRE_PRIMARY  */
#line 669 "HAL_S.y"
                { (yyval.primary_) = make_ADprimary((yyvsp[0].pre_primary_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4218 "Parser.c"
    break;

  case 20: /* PRIMARY: MODIFIED_ARITH_FUNC  */
#line 670 "HAL_S.y"
                        { (yyval.primary_) = make_ABprimary((yyvsp[0].modified_arith_func_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4224 "Parser.c"
    break;

  case 21: /* PRIMARY: PRE_PRIMARY QUALIFIER  */
#line 671 "HAL_S.y"
                          { (yyval.primary_) = make_AEprimary((yyvsp[-1].pre_primary_), (yyvsp[0].qualifier_)); (yyval.primary_)->line_number = (yyloc).first_line; (yyval.primary_)->char_number = (yyloc).first_column;  }
#line 4230 "Parser.c"
    break;

  case 22: /* ARITH_VAR: ARITH_ID  */
#line 673 "HAL_S.y"
                     { (yyval.arith_var_) = make_AAarith_var((yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4236 "Parser.c"
    break;

  case 23: /* ARITH_VAR: ARITH_ID SUBSCRIPT  */
#line 674 "HAL_S.y"
                       { (yyval.arith_var_) = make_ACarith_var((yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4242 "Parser.c"
    break;

  case 24: /* ARITH_VAR: _SYMB_10 ARITH_ID _SYMB_11  */
#line 675 "HAL_S.y"
                               { (yyval.arith_var_) = make_AAarithVarBracketed((yyvsp[-1].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4248 "Parser.c"
    break;

  case 25: /* ARITH_VAR: _SYMB_10 ARITH_ID _SYMB_11 SUBSCRIPT  */
#line 676 "HAL_S.y"
                                         { (yyval.arith_var_) = make_ABarithVarBracketed((yyvsp[-2].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4254 "Parser.c"
    break;

  case 26: /* ARITH_VAR: _SYMB_12 QUAL_STRUCT _SYMB_13  */
#line 677 "HAL_S.y"
                                  { (yyval.arith_var_) = make_AAarithVarBraced((yyvsp[-1].qual_struct_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4260 "Parser.c"
    break;

  case 27: /* ARITH_VAR: _SYMB_12 QUAL_STRUCT _SYMB_13 SUBSCRIPT  */
#line 678 "HAL_S.y"
                                            { (yyval.arith_var_) = make_ABarithVarBraced((yyvsp[-2].qual_struct_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4266 "Parser.c"
    break;

  case 28: /* ARITH_VAR: QUAL_STRUCT _SYMB_4 ARITH_ID  */
#line 679 "HAL_S.y"
                                 { (yyval.arith_var_) = make_ABarith_var((yyvsp[-2].qual_struct_), (yyvsp[0].arith_id_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4272 "Parser.c"
    break;

  case 29: /* ARITH_VAR: QUAL_STRUCT _SYMB_4 ARITH_ID SUBSCRIPT  */
#line 680 "HAL_S.y"
                                           { (yyval.arith_var_) = make_ADarith_var((yyvsp[-3].qual_struct_), (yyvsp[-1].arith_id_), (yyvsp[0].subscript_)); (yyval.arith_var_)->line_number = (yyloc).first_line; (yyval.arith_var_)->char_number = (yyloc).first_column;  }
#line 4278 "Parser.c"
    break;

  case 30: /* PRE_PRIMARY: _SYMB_6 ARITH_EXP _SYMB_7  */
#line 682 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AApre_primary((yyvsp[-1].arith_exp_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4284 "Parser.c"
    break;

  case 31: /* PRE_PRIMARY: NUMBER  */
#line 683 "HAL_S.y"
           { (yyval.pre_primary_) = make_ABpre_primary((yyvsp[0].number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4290 "Parser.c"
    break;

  case 32: /* PRE_PRIMARY: COMPOUND_NUMBER  */
#line 684 "HAL_S.y"
                    { (yyval.pre_primary_) = make_ACpre_primary((yyvsp[0].compound_number_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4296 "Parser.c"
    break;

  case 33: /* PRE_PRIMARY: ARITH_FUNC_HEAD _SYMB_6 CALL_LIST _SYMB_7  */
#line 685 "HAL_S.y"
                                              { (yyval.pre_primary_) = make_ADprePrimaryRtlFunction((yyvsp[-3].arith_func_head_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4302 "Parser.c"
    break;

  case 34: /* PRE_PRIMARY: _SYMB_187 _SYMB_6 CALL_LIST _SYMB_7  */
#line 686 "HAL_S.y"
                                        { (yyval.pre_primary_) = make_AEprePrimaryFunction((yyvsp[-3].string_), (yyvsp[-1].call_list_)); (yyval.pre_primary_)->line_number = (yyloc).first_line; (yyval.pre_primary_)->char_number = (yyloc).first_column;  }
#line 4308 "Parser.c"
    break;

  case 35: /* NUMBER: SIMPLE_NUMBER  */
#line 688 "HAL_S.y"
                       { (yyval.number_) = make_AAnumber((yyvsp[0].simple_number_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4314 "Parser.c"
    break;

  case 36: /* NUMBER: LEVEL  */
#line 689 "HAL_S.y"
          { (yyval.number_) = make_ABnumber((yyvsp[0].level_)); (yyval.number_)->line_number = (yyloc).first_line; (yyval.number_)->char_number = (yyloc).first_column;  }
#line 4320 "Parser.c"
    break;

  case 37: /* LEVEL: _SYMB_193  */
#line 691 "HAL_S.y"
                  { (yyval.level_) = make_ZZlevel((yyvsp[0].string_)); (yyval.level_)->line_number = (yyloc).first_line; (yyval.level_)->char_number = (yyloc).first_column;  }
#line 4326 "Parser.c"
    break;

  case 38: /* COMPOUND_NUMBER: _SYMB_195  */
#line 693 "HAL_S.y"
                            { (yyval.compound_number_) = make_CLcompound_number((yyvsp[0].string_)); (yyval.compound_number_)->line_number = (yyloc).first_line; (yyval.compound_number_)->char_number = (yyloc).first_column;  }
#line 4332 "Parser.c"
    break;

  case 39: /* SIMPLE_NUMBER: _SYMB_194  */
#line 695 "HAL_S.y"
                          { (yyval.simple_number_) = make_CKsimple_number((yyvsp[0].string_)); (yyval.simple_number_)->line_number = (yyloc).first_line; (yyval.simple_number_)->char_number = (yyloc).first_column;  }
#line 4338 "Parser.c"
    break;

  case 40: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC  */
#line 697 "HAL_S.y"
                                        { (yyval.modified_arith_func_) = make_AAmodified_arith_func((yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4344 "Parser.c"
    break;

  case 41: /* MODIFIED_ARITH_FUNC: NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 698 "HAL_S.y"
                                { (yyval.modified_arith_func_) = make_ACmodified_arith_func((yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4350 "Parser.c"
    break;

  case 42: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_4 NO_ARG_ARITH_FUNC  */
#line 699 "HAL_S.y"
                                          { (yyval.modified_arith_func_) = make_ADmodified_arith_func((yyvsp[-2].qual_struct_), (yyvsp[0].no_arg_arith_func_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4356 "Parser.c"
    break;

  case 43: /* MODIFIED_ARITH_FUNC: QUAL_STRUCT _SYMB_4 NO_ARG_ARITH_FUNC SUBSCRIPT  */
#line 700 "HAL_S.y"
                                                    { (yyval.modified_arith_func_) = make_AEmodified_arith_func((yyvsp[-3].qual_struct_), (yyvsp[-1].no_arg_arith_func_), (yyvsp[0].subscript_)); (yyval.modified_arith_func_)->line_number = (yyloc).first_line; (yyval.modified_arith_func_)->char_number = (yyloc).first_column;  }
#line 4362 "Parser.c"
    break;

  case 44: /* ARITH_FUNC_HEAD: ARITH_FUNC  */
#line 702 "HAL_S.y"
                             { (yyval.arith_func_head_) = make_AAarith_func_head((yyvsp[0].arith_func_)); (yyval.arith_func_head_)->line_number = (yyloc).first_line; (yyval.arith_func_head_)->char_number = (yyloc).first_column;  }
#line 4368 "Parser.c"
    break;

  case 45: /* ARITH_FUNC_HEAD: ARITH_CONV SUBSCRIPT  */
#line 703 "HAL_S.y"
                         { (yyval.arith_func_head_) = make_ABarith_func_head((yyvsp[-1].arith_conv_), (yyvsp[0].subscript_)); (yyval.arith_func_head_)->line_number = (yyloc).first_line; (yyval.arith_func_head_)->char_number = (yyloc).first_column;  }
#line 4374 "Parser.c"
    break;

  case 46: /* CALL_LIST: LIST_EXP  */
#line 705 "HAL_S.y"
                     { (yyval.call_list_) = make_AAcall_list((yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 4380 "Parser.c"
    break;

  case 47: /* CALL_LIST: CALL_LIST _SYMB_8 LIST_EXP  */
#line 706 "HAL_S.y"
                               { (yyval.call_list_) = make_ABcall_list((yyvsp[-2].call_list_), (yyvsp[0].list_exp_)); (yyval.call_list_)->line_number = (yyloc).first_line; (yyval.call_list_)->char_number = (yyloc).first_column;  }
#line 4386 "Parser.c"
    break;

  case 48: /* LIST_EXP: EXPRESSION  */
#line 708 "HAL_S.y"
                      { (yyval.list_exp_) = make_AAlist_exp((yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4392 "Parser.c"
    break;

  case 49: /* LIST_EXP: ARITH_EXP _SYMB_9 EXPRESSION  */
#line 709 "HAL_S.y"
                                 { (yyval.list_exp_) = make_ABlist_exp((yyvsp[-2].arith_exp_), (yyvsp[0].expression_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4398 "Parser.c"
    break;

  case 50: /* LIST_EXP: QUAL_STRUCT  */
#line 710 "HAL_S.y"
                { (yyval.list_exp_) = make_ADlist_exp((yyvsp[0].qual_struct_)); (yyval.list_exp_)->line_number = (yyloc).first_line; (yyval.list_exp_)->char_number = (yyloc).first_column;  }
#line 4404 "Parser.c"
    break;

  case 51: /* EXPRESSION: ARITH_EXP  */
#line 712 "HAL_S.y"
                       { (yyval.expression_) = make_AAexpression((yyvsp[0].arith_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4410 "Parser.c"
    break;

  case 52: /* EXPRESSION: BIT_EXP  */
#line 713 "HAL_S.y"
            { (yyval.expression_) = make_ABexpression((yyvsp[0].bit_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4416 "Parser.c"
    break;

  case 53: /* EXPRESSION: CHAR_EXP  */
#line 714 "HAL_S.y"
             { (yyval.expression_) = make_ACexpression((yyvsp[0].char_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4422 "Parser.c"
    break;

  case 54: /* EXPRESSION: NAME_EXP  */
#line 715 "HAL_S.y"
             { (yyval.expression_) = make_AEexpression((yyvsp[0].name_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4428 "Parser.c"
    break;

  case 55: /* EXPRESSION: STRUCTURE_EXP  */
#line 716 "HAL_S.y"
                  { (yyval.expression_) = make_ADexpression((yyvsp[0].structure_exp_)); (yyval.expression_)->line_number = (yyloc).first_line; (yyval.expression_)->char_number = (yyloc).first_column;  }
#line 4434 "Parser.c"
    break;

  case 56: /* ARITH_ID: IDENTIFIER  */
#line 718 "HAL_S.y"
                      { (yyval.arith_id_) = make_FGarith_id((yyvsp[0].identifier_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 4440 "Parser.c"
    break;

  case 57: /* ARITH_ID: _SYMB_189  */
#line 719 "HAL_S.y"
              { (yyval.arith_id_) = make_FHarith_id((yyvsp[0].string_)); (yyval.arith_id_)->line_number = (yyloc).first_line; (yyval.arith_id_)->char_number = (yyloc).first_column;  }
#line 4446 "Parser.c"
    break;

  case 58: /* IDENTIFIER: _SYMB_190  */
#line 721 "HAL_S.y"
                       { (yyval.identifier_) = make_FFidentifier((yyvsp[0].string_)); (yyval.identifier_)->line_number = (yyloc).first_line; (yyval.identifier_)->char_number = (yyloc).first_column;  }
#line 4452 "Parser.c"
    break;

  case 59: /* NO_ARG_ARITH_FUNC: _SYMB_58  */
#line 723 "HAL_S.y"
                             { (yyval.no_arg_arith_func_) = make_ZZclocktime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4458 "Parser.c"
    break;

  case 60: /* NO_ARG_ARITH_FUNC: _SYMB_65  */
#line 724 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZdate(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4464 "Parser.c"
    break;

  case 61: /* NO_ARG_ARITH_FUNC: _SYMB_77  */
#line 725 "HAL_S.y"
             { (yyval.no_arg_arith_func_) = make_ZZerrgrp(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4470 "Parser.c"
    break;

  case 62: /* NO_ARG_ARITH_FUNC: _SYMB_121  */
#line 726 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZprio(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4476 "Parser.c"
    break;

  case 63: /* NO_ARG_ARITH_FUNC: _SYMB_126  */
#line 727 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZrandom(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4482 "Parser.c"
    break;

  case 64: /* NO_ARG_ARITH_FUNC: _SYMB_139  */
#line 728 "HAL_S.y"
              { (yyval.no_arg_arith_func_) = make_ZZruntime(); (yyval.no_arg_arith_func_)->line_number = (yyloc).first_line; (yyval.no_arg_arith_func_)->char_number = (yyloc).first_column;  }
#line 4488 "Parser.c"
    break;

  case 65: /* ARITH_FUNC: _SYMB_111  */
#line 730 "HAL_S.y"
                       { (yyval.arith_func_) = make_ZZnexttime(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4494 "Parser.c"
    break;

  case 66: /* ARITH_FUNC: _SYMB_30  */
#line 731 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabs(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4500 "Parser.c"
    break;

  case 67: /* ARITH_FUNC: _SYMB_55  */
#line 732 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZceiling(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4506 "Parser.c"
    break;

  case 68: /* ARITH_FUNC: _SYMB_71  */
#line 733 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdiv(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4512 "Parser.c"
    break;

  case 69: /* ARITH_FUNC: _SYMB_87  */
#line 734 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZfloor(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4518 "Parser.c"
    break;

  case 70: /* ARITH_FUNC: _SYMB_107  */
#line 735 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmidval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4524 "Parser.c"
    break;

  case 71: /* ARITH_FUNC: _SYMB_109  */
#line 736 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4530 "Parser.c"
    break;

  case 72: /* ARITH_FUNC: _SYMB_116  */
#line 737 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZodd(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4536 "Parser.c"
    break;

  case 73: /* ARITH_FUNC: _SYMB_130  */
#line 738 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZremainder(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4542 "Parser.c"
    break;

  case 74: /* ARITH_FUNC: _SYMB_138  */
#line 739 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZround(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4548 "Parser.c"
    break;

  case 75: /* ARITH_FUNC: _SYMB_146  */
#line 740 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsign(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4554 "Parser.c"
    break;

  case 76: /* ARITH_FUNC: _SYMB_148  */
#line 741 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsignum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4560 "Parser.c"
    break;

  case 77: /* ARITH_FUNC: _SYMB_172  */
#line 742 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtruncate(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4566 "Parser.c"
    break;

  case 78: /* ARITH_FUNC: _SYMB_36  */
#line 743 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4572 "Parser.c"
    break;

  case 79: /* ARITH_FUNC: _SYMB_37  */
#line 744 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarccosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4578 "Parser.c"
    break;

  case 80: /* ARITH_FUNC: _SYMB_38  */
#line 745 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4584 "Parser.c"
    break;

  case 81: /* ARITH_FUNC: _SYMB_39  */
#line 746 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarcsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4590 "Parser.c"
    break;

  case 82: /* ARITH_FUNC: _SYMB_41  */
#line 747 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan2(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4596 "Parser.c"
    break;

  case 83: /* ARITH_FUNC: _SYMB_40  */
#line 748 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4602 "Parser.c"
    break;

  case 84: /* ARITH_FUNC: _SYMB_42  */
#line 749 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZarctanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4608 "Parser.c"
    break;

  case 85: /* ARITH_FUNC: _SYMB_63  */
#line 750 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcos(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4614 "Parser.c"
    break;

  case 86: /* ARITH_FUNC: _SYMB_64  */
#line 751 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZcosh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4620 "Parser.c"
    break;

  case 87: /* ARITH_FUNC: _SYMB_83  */
#line 752 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZexp(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4626 "Parser.c"
    break;

  case 88: /* ARITH_FUNC: _SYMB_104  */
#line 753 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZlog(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4632 "Parser.c"
    break;

  case 89: /* ARITH_FUNC: _SYMB_149  */
#line 754 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4638 "Parser.c"
    break;

  case 90: /* ARITH_FUNC: _SYMB_151  */
#line 755 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsinh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4644 "Parser.c"
    break;

  case 91: /* ARITH_FUNC: _SYMB_154  */
#line 756 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsqrt(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4650 "Parser.c"
    break;

  case 92: /* ARITH_FUNC: _SYMB_161  */
#line 757 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtan(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4656 "Parser.c"
    break;

  case 93: /* ARITH_FUNC: _SYMB_162  */
#line 758 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtanh(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4662 "Parser.c"
    break;

  case 94: /* ARITH_FUNC: _SYMB_144  */
#line 759 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshl(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4668 "Parser.c"
    break;

  case 95: /* ARITH_FUNC: _SYMB_145  */
#line 760 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZshr(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4674 "Parser.c"
    break;

  case 96: /* ARITH_FUNC: _SYMB_31  */
#line 761 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZabval(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4680 "Parser.c"
    break;

  case 97: /* ARITH_FUNC: _SYMB_70  */
#line 762 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZdet(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4686 "Parser.c"
    break;

  case 98: /* ARITH_FUNC: _SYMB_168  */
#line 763 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtrace(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4692 "Parser.c"
    break;

  case 99: /* ARITH_FUNC: _SYMB_173  */
#line 764 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZunit(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4698 "Parser.c"
    break;

  case 100: /* ARITH_FUNC: _SYMB_105  */
#line 765 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmatrix(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4704 "Parser.c"
    break;

  case 101: /* ARITH_FUNC: _SYMB_95  */
#line 766 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZindex(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4710 "Parser.c"
    break;

  case 102: /* ARITH_FUNC: _SYMB_100  */
#line 767 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZlength(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4716 "Parser.c"
    break;

  case 103: /* ARITH_FUNC: _SYMB_98  */
#line 768 "HAL_S.y"
             { (yyval.arith_func_) = make_ZZinverse(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4722 "Parser.c"
    break;

  case 104: /* ARITH_FUNC: _SYMB_169  */
#line 769 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZtranspose(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4728 "Parser.c"
    break;

  case 105: /* ARITH_FUNC: _SYMB_124  */
#line 770 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZprod(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4734 "Parser.c"
    break;

  case 106: /* ARITH_FUNC: _SYMB_158  */
#line 771 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsum(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4740 "Parser.c"
    break;

  case 107: /* ARITH_FUNC: _SYMB_152  */
#line 772 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZsize(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4746 "Parser.c"
    break;

  case 108: /* ARITH_FUNC: _SYMB_106  */
#line 773 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmax(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4752 "Parser.c"
    break;

  case 109: /* ARITH_FUNC: _SYMB_108  */
#line 774 "HAL_S.y"
              { (yyval.arith_func_) = make_ZZmin(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4758 "Parser.c"
    break;

  case 110: /* ARITH_FUNC: _SYMB_97  */
#line 775 "HAL_S.y"
             { (yyval.arith_func_) = make_AAarithFuncInteger(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4764 "Parser.c"
    break;

  case 111: /* ARITH_FUNC: _SYMB_140  */
#line 776 "HAL_S.y"
              { (yyval.arith_func_) = make_AAarithFuncScalar(); (yyval.arith_func_)->line_number = (yyloc).first_line; (yyval.arith_func_)->char_number = (yyloc).first_column;  }
#line 4770 "Parser.c"
    break;

  case 112: /* SUBSCRIPT: SUB_HEAD _SYMB_7  */
#line 778 "HAL_S.y"
                             { (yyval.subscript_) = make_AAsubscript((yyvsp[-1].sub_head_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 4776 "Parser.c"
    break;

  case 113: /* SUBSCRIPT: QUALIFIER  */
#line 779 "HAL_S.y"
              { (yyval.subscript_) = make_ABsubscript((yyvsp[0].qualifier_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 4782 "Parser.c"
    break;

  case 114: /* SUBSCRIPT: _SYMB_14 NUMBER  */
#line 780 "HAL_S.y"
                    { (yyval.subscript_) = make_ACsubscript((yyvsp[0].number_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 4788 "Parser.c"
    break;

  case 115: /* SUBSCRIPT: _SYMB_14 ARITH_VAR  */
#line 781 "HAL_S.y"
                       { (yyval.subscript_) = make_ADsubscript((yyvsp[0].arith_var_)); (yyval.subscript_)->line_number = (yyloc).first_line; (yyval.subscript_)->char_number = (yyloc).first_column;  }
#line 4794 "Parser.c"
    break;

  case 116: /* QUALIFIER: _SYMB_14 _SYMB_6 _SYMB_15 PREC_SPEC _SYMB_7  */
#line 783 "HAL_S.y"
                                                        { (yyval.qualifier_) = make_AAqualifier((yyvsp[-1].prec_spec_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 4800 "Parser.c"
    break;

  case 117: /* QUALIFIER: _SYMB_14 _SYMB_6 SCALE_HEAD ARITH_EXP _SYMB_7  */
#line 784 "HAL_S.y"
                                                  { (yyval.qualifier_) = make_ABqualifier((yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 4806 "Parser.c"
    break;

  case 118: /* QUALIFIER: _SYMB_14 _SYMB_6 _SYMB_15 PREC_SPEC _SYMB_8 SCALE_HEAD ARITH_EXP _SYMB_7  */
#line 785 "HAL_S.y"
                                                                             { (yyval.qualifier_) = make_ACqualifier((yyvsp[-4].prec_spec_), (yyvsp[-2].scale_head_), (yyvsp[-1].arith_exp_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 4812 "Parser.c"
    break;

  case 119: /* QUALIFIER: _SYMB_14 _SYMB_6 _SYMB_15 RADIX _SYMB_7  */
#line 786 "HAL_S.y"
                                            { (yyval.qualifier_) = make_ADqualifier((yyvsp[-1].radix_)); (yyval.qualifier_)->line_number = (yyloc).first_line; (yyval.qualifier_)->char_number = (yyloc).first_column;  }
#line 4818 "Parser.c"
    break;

  case 120: /* SCALE_HEAD: _SYMB_15  */
#line 788 "HAL_S.y"
                      { (yyval.scale_head_) = make_AAscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 4824 "Parser.c"
    break;

  case 121: /* SCALE_HEAD: _SYMB_15 _SYMB_15  */
#line 789 "HAL_S.y"
                      { (yyval.scale_head_) = make_ABscale_head(); (yyval.scale_head_)->line_number = (yyloc).first_line; (yyval.scale_head_)->char_number = (yyloc).first_column;  }
#line 4830 "Parser.c"
    break;

  case 122: /* PREC_SPEC: _SYMB_150  */
#line 791 "HAL_S.y"
                      { (yyval.prec_spec_) = make_AAprecSpecSingle(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 4836 "Parser.c"
    break;

  case 123: /* PREC_SPEC: _SYMB_73  */
#line 792 "HAL_S.y"
             { (yyval.prec_spec_) = make_ABprecSpecDouble(); (yyval.prec_spec_)->line_number = (yyloc).first_line; (yyval.prec_spec_)->char_number = (yyloc).first_column;  }
#line 4842 "Parser.c"
    break;

  case 124: /* SUB_START: _SYMB_14 _SYMB_6  */
#line 794 "HAL_S.y"
                             { (yyval.sub_start_) = make_AAsubStartGroup(); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 4848 "Parser.c"
    break;

  case 125: /* SUB_START: _SYMB_14 _SYMB_6 _SYMB_15 PREC_SPEC _SYMB_8  */
#line 795 "HAL_S.y"
                                                { (yyval.sub_start_) = make_ABsubStartPrecSpec((yyvsp[-1].prec_spec_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 4854 "Parser.c"
    break;

  case 126: /* SUB_START: SUB_HEAD _SYMB_16  */
#line 796 "HAL_S.y"
                      { (yyval.sub_start_) = make_ACsubStartSemicolon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 4860 "Parser.c"
    break;

  case 127: /* SUB_START: SUB_HEAD _SYMB_17  */
#line 797 "HAL_S.y"
                      { (yyval.sub_start_) = make_ADsubStartColon((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 4866 "Parser.c"
    break;

  case 128: /* SUB_START: SUB_HEAD _SYMB_8  */
#line 798 "HAL_S.y"
                     { (yyval.sub_start_) = make_AEsubStartComma((yyvsp[-1].sub_head_)); (yyval.sub_start_)->line_number = (yyloc).first_line; (yyval.sub_start_)->char_number = (yyloc).first_column;  }
#line 4872 "Parser.c"
    break;

  case 129: /* SUB_HEAD: SUB_START  */
#line 800 "HAL_S.y"
                     { (yyval.sub_head_) = make_AAsub_head((yyvsp[0].sub_start_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 4878 "Parser.c"
    break;

  case 130: /* SUB_HEAD: SUB_START SUB  */
#line 801 "HAL_S.y"
                  { (yyval.sub_head_) = make_ABsub_head((yyvsp[-1].sub_start_), (yyvsp[0].sub_)); (yyval.sub_head_)->line_number = (yyloc).first_line; (yyval.sub_head_)->char_number = (yyloc).first_column;  }
#line 4884 "Parser.c"
    break;

  case 131: /* SUB: SUB_EXP  */
#line 803 "HAL_S.y"
              { (yyval.sub_) = make_AAsub((yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 4890 "Parser.c"
    break;

  case 132: /* SUB: _SYMB_3  */
#line 804 "HAL_S.y"
            { (yyval.sub_) = make_ABsubStar(); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 4896 "Parser.c"
    break;

  case 133: /* SUB: SUB_RUN_HEAD SUB_EXP  */
#line 805 "HAL_S.y"
                         { (yyval.sub_) = make_ACsubExp((yyvsp[-1].sub_run_head_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 4902 "Parser.c"
    break;

  case 134: /* SUB: ARITH_EXP _SYMB_45 SUB_EXP  */
#line 806 "HAL_S.y"
                               { (yyval.sub_) = make_ADsubAt((yyvsp[-2].arith_exp_), (yyvsp[0].sub_exp_)); (yyval.sub_)->line_number = (yyloc).first_line; (yyval.sub_)->char_number = (yyloc).first_column;  }
#line 4908 "Parser.c"
    break;

  case 135: /* SUB_RUN_HEAD: SUB_EXP _SYMB_167  */
#line 808 "HAL_S.y"
                                 { (yyval.sub_run_head_) = make_AAsubRunHeadTo((yyvsp[-1].sub_exp_)); (yyval.sub_run_head_)->line_number = (yyloc).first_line; (yyval.sub_run_head_)->char_number = (yyloc).first_column;  }
#line 4914 "Parser.c"
    break;

  case 136: /* SUB_EXP: ARITH_EXP  */
#line 810 "HAL_S.y"
                    { (yyval.sub_exp_) = make_AAsub_exp((yyvsp[0].arith_exp_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 4920 "Parser.c"
    break;

  case 137: /* SUB_EXP: POUND_EXPRESSION  */
#line 811 "HAL_S.y"
                     { (yyval.sub_exp_) = make_ABsub_exp((yyvsp[0].pound_expression_)); (yyval.sub_exp_)->line_number = (yyloc).first_line; (yyval.sub_exp_)->char_number = (yyloc).first_column;  }
#line 4926 "Parser.c"
    break;

  case 138: /* POUND_EXPRESSION: _SYMB_9  */
#line 813 "HAL_S.y"
                           { (yyval.pound_expression_) = make_AApound_expression(); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 4932 "Parser.c"
    break;

  case 139: /* POUND_EXPRESSION: POUND_EXPRESSION PLUS TERM  */
#line 814 "HAL_S.y"
                               { (yyval.pound_expression_) = make_ABpound_expression((yyvsp[-2].pound_expression_), (yyvsp[-1].plus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 4938 "Parser.c"
    break;

  case 140: /* POUND_EXPRESSION: POUND_EXPRESSION MINUS TERM  */
#line 815 "HAL_S.y"
                                { (yyval.pound_expression_) = make_ACpound_expression((yyvsp[-2].pound_expression_), (yyvsp[-1].minus_), (yyvsp[0].term_)); (yyval.pound_expression_)->line_number = (yyloc).first_line; (yyval.pound_expression_)->char_number = (yyloc).first_column;  }
#line 4944 "Parser.c"
    break;

  case 141: /* ARITH_CONV: _SYMB_97  */
#line 817 "HAL_S.y"
                      { (yyval.arith_conv_) = make_AAarithConvInteger(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4950 "Parser.c"
    break;

  case 142: /* ARITH_CONV: _SYMB_140  */
#line 818 "HAL_S.y"
              { (yyval.arith_conv_) = make_ABarithConvScalar(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4956 "Parser.c"
    break;

  case 143: /* ARITH_CONV: _SYMB_176  */
#line 819 "HAL_S.y"
              { (yyval.arith_conv_) = make_ACarithConvVector(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4962 "Parser.c"
    break;

  case 144: /* ARITH_CONV: _SYMB_105  */
#line 820 "HAL_S.y"
              { (yyval.arith_conv_) = make_ADarithConvMatrix(); (yyval.arith_conv_)->line_number = (yyloc).first_line; (yyval.arith_conv_)->char_number = (yyloc).first_column;  }
#line 4968 "Parser.c"
    break;

  case 145: /* BIT_EXP: BIT_FACTOR  */
#line 822 "HAL_S.y"
                     { (yyval.bit_exp_) = make_AAbit_exp((yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 4974 "Parser.c"
    break;

  case 146: /* BIT_EXP: BIT_EXP OR BIT_FACTOR  */
#line 823 "HAL_S.y"
                          { (yyval.bit_exp_) = make_ABbit_exp((yyvsp[-2].bit_exp_), (yyvsp[-1].or_), (yyvsp[0].bit_factor_)); (yyval.bit_exp_)->line_number = (yyloc).first_line; (yyval.bit_exp_)->char_number = (yyloc).first_column;  }
#line 4980 "Parser.c"
    break;

  case 147: /* BIT_FACTOR: BIT_CAT  */
#line 825 "HAL_S.y"
                     { (yyval.bit_factor_) = make_AAbit_factor((yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 4986 "Parser.c"
    break;

  case 148: /* BIT_FACTOR: BIT_FACTOR AND BIT_CAT  */
#line 826 "HAL_S.y"
                           { (yyval.bit_factor_) = make_ABbit_factor((yyvsp[-2].bit_factor_), (yyvsp[-1].and_), (yyvsp[0].bit_cat_)); (yyval.bit_factor_)->line_number = (yyloc).first_line; (yyval.bit_factor_)->char_number = (yyloc).first_column;  }
#line 4992 "Parser.c"
    break;

  case 149: /* BIT_CAT: BIT_PRIM  */
#line 828 "HAL_S.y"
                   { (yyval.bit_cat_) = make_AAbit_cat((yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 4998 "Parser.c"
    break;

  case 150: /* BIT_CAT: BIT_CAT CAT BIT_PRIM  */
#line 829 "HAL_S.y"
                         { (yyval.bit_cat_) = make_ABbit_cat((yyvsp[-2].bit_cat_), (yyvsp[-1].cat_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5004 "Parser.c"
    break;

  case 151: /* BIT_CAT: NOT BIT_PRIM  */
#line 830 "HAL_S.y"
                 { (yyval.bit_cat_) = make_ACbit_cat((yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5010 "Parser.c"
    break;

  case 152: /* BIT_CAT: BIT_CAT CAT NOT BIT_PRIM  */
#line 831 "HAL_S.y"
                             { (yyval.bit_cat_) = make_ADbit_cat((yyvsp[-3].bit_cat_), (yyvsp[-2].cat_), (yyvsp[-1].not_), (yyvsp[0].bit_prim_)); (yyval.bit_cat_)->line_number = (yyloc).first_line; (yyval.bit_cat_)->char_number = (yyloc).first_column;  }
#line 5016 "Parser.c"
    break;

  case 153: /* OR: CHAR_VERTICAL_BAR  */
#line 833 "HAL_S.y"
                       { (yyval.or_) = make_AAor((yyvsp[0].char_vertical_bar_)); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5022 "Parser.c"
    break;

  case 154: /* OR: _SYMB_119  */
#line 834 "HAL_S.y"
              { (yyval.or_) = make_ABor(); (yyval.or_)->line_number = (yyloc).first_line; (yyval.or_)->char_number = (yyloc).first_column;  }
#line 5028 "Parser.c"
    break;

  case 155: /* CHAR_VERTICAL_BAR: _SYMB_18  */
#line 836 "HAL_S.y"
                             { (yyval.char_vertical_bar_) = make_CFchar_vertical_bar(); (yyval.char_vertical_bar_)->line_number = (yyloc).first_line; (yyval.char_vertical_bar_)->char_number = (yyloc).first_column;  }
#line 5034 "Parser.c"
    break;

  case 156: /* AND: _SYMB_19  */
#line 838 "HAL_S.y"
               { (yyval.and_) = make_AAand(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5040 "Parser.c"
    break;

  case 157: /* AND: _SYMB_35  */
#line 839 "HAL_S.y"
             { (yyval.and_) = make_ABand(); (yyval.and_)->line_number = (yyloc).first_line; (yyval.and_)->char_number = (yyloc).first_column;  }
#line 5046 "Parser.c"
    break;

  case 158: /* BIT_PRIM: BIT_VAR  */
#line 841 "HAL_S.y"
                   { (yyval.bit_prim_) = make_AAbitPrimBitVar((yyvsp[0].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5052 "Parser.c"
    break;

  case 159: /* BIT_PRIM: LABEL_VAR  */
#line 842 "HAL_S.y"
              { (yyval.bit_prim_) = make_ABbitPrimLabelVar((yyvsp[0].label_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5058 "Parser.c"
    break;

  case 160: /* BIT_PRIM: EVENT_VAR  */
#line 843 "HAL_S.y"
              { (yyval.bit_prim_) = make_ACbitPrimEventVar((yyvsp[0].event_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5064 "Parser.c"
    break;

  case 161: /* BIT_PRIM: BIT_CONST  */
#line 844 "HAL_S.y"
              { (yyval.bit_prim_) = make_ADbitBitConst((yyvsp[0].bit_const_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5070 "Parser.c"
    break;

  case 162: /* BIT_PRIM: _SYMB_6 BIT_EXP _SYMB_7  */
#line 845 "HAL_S.y"
                            { (yyval.bit_prim_) = make_AEbitPrimBitExp((yyvsp[-1].bit_exp_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5076 "Parser.c"
    break;

  case 163: /* BIT_PRIM: SUBBIT_HEAD EXPRESSION _SYMB_7  */
#line 846 "HAL_S.y"
                                   { (yyval.bit_prim_) = make_AHbitPrimSubbit((yyvsp[-2].subbit_head_), (yyvsp[-1].expression_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5082 "Parser.c"
    break;

  case 164: /* BIT_PRIM: BIT_FUNC_HEAD _SYMB_6 CALL_LIST _SYMB_7  */
#line 847 "HAL_S.y"
                                            { (yyval.bit_prim_) = make_AIbitPrimFunc((yyvsp[-3].bit_func_head_), (yyvsp[-1].call_list_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5088 "Parser.c"
    break;

  case 165: /* BIT_PRIM: _SYMB_10 BIT_VAR _SYMB_11  */
#line 848 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBracketed((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5094 "Parser.c"
    break;

  case 166: /* BIT_PRIM: _SYMB_10 BIT_VAR _SYMB_11 SUBSCRIPT  */
#line 849 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBracketed((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5100 "Parser.c"
    break;

  case 167: /* BIT_PRIM: _SYMB_12 BIT_VAR _SYMB_13  */
#line 850 "HAL_S.y"
                              { (yyval.bit_prim_) = make_AAbitPrimBitVarBraced((yyvsp[-1].bit_var_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5106 "Parser.c"
    break;

  case 168: /* BIT_PRIM: _SYMB_12 BIT_VAR _SYMB_13 SUBSCRIPT  */
#line 851 "HAL_S.y"
                                        { (yyval.bit_prim_) = make_ABbitPrimBitVarBraced((yyvsp[-2].bit_var_), (yyvsp[0].subscript_)); (yyval.bit_prim_)->line_number = (yyloc).first_line; (yyval.bit_prim_)->char_number = (yyloc).first_column;  }
#line 5112 "Parser.c"
    break;

  case 169: /* CAT: _SYMB_20  */
#line 853 "HAL_S.y"
               { (yyval.cat_) = make_AAcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5118 "Parser.c"
    break;

  case 170: /* CAT: _SYMB_54  */
#line 854 "HAL_S.y"
             { (yyval.cat_) = make_ABcat(); (yyval.cat_)->line_number = (yyloc).first_line; (yyval.cat_)->char_number = (yyloc).first_column;  }
#line 5124 "Parser.c"
    break;

  case 171: /* NOT: _SYMB_21  */
#line 856 "HAL_S.y"
               { (yyval.not_) = make_AAnot(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5130 "Parser.c"
    break;

  case 172: /* NOT: _SYMB_113  */
#line 857 "HAL_S.y"
              { (yyval.not_) = make_ABnot(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5136 "Parser.c"
    break;

  case 173: /* NOT: _SYMB_22  */
#line 858 "HAL_S.y"
             { (yyval.not_) = make_ACnot(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5142 "Parser.c"
    break;

  case 174: /* NOT: _SYMB_23  */
#line 859 "HAL_S.y"
             { (yyval.not_) = make_ADnot(); (yyval.not_)->line_number = (yyloc).first_line; (yyval.not_)->char_number = (yyloc).first_column;  }
#line 5148 "Parser.c"
    break;

  case 175: /* BIT_VAR: BIT_ID  */
#line 861 "HAL_S.y"
                 { (yyval.bit_var_) = make_AAbit_var((yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5154 "Parser.c"
    break;

  case 176: /* BIT_VAR: BIT_ID SUBSCRIPT  */
#line 862 "HAL_S.y"
                     { (yyval.bit_var_) = make_ACbit_var((yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5160 "Parser.c"
    break;

  case 177: /* BIT_VAR: QUAL_STRUCT _SYMB_4 BIT_ID  */
#line 863 "HAL_S.y"
                               { (yyval.bit_var_) = make_ABbit_var((yyvsp[-2].qual_struct_), (yyvsp[0].bit_id_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5166 "Parser.c"
    break;

  case 178: /* BIT_VAR: QUAL_STRUCT _SYMB_4 BIT_ID SUBSCRIPT  */
#line 864 "HAL_S.y"
                                         { (yyval.bit_var_) = make_ADbit_var((yyvsp[-3].qual_struct_), (yyvsp[-1].bit_id_), (yyvsp[0].subscript_)); (yyval.bit_var_)->line_number = (yyloc).first_line; (yyval.bit_var_)->char_number = (yyloc).first_column;  }
#line 5172 "Parser.c"
    break;

  case 179: /* LABEL_VAR: LABEL  */
#line 866 "HAL_S.y"
                  { (yyval.label_var_) = make_AAlabel_var((yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5178 "Parser.c"
    break;

  case 180: /* LABEL_VAR: LABEL SUBSCRIPT  */
#line 867 "HAL_S.y"
                    { (yyval.label_var_) = make_ABlabel_var((yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5184 "Parser.c"
    break;

  case 181: /* LABEL_VAR: QUAL_STRUCT _SYMB_4 LABEL  */
#line 868 "HAL_S.y"
                              { (yyval.label_var_) = make_AClabel_var((yyvsp[-2].qual_struct_), (yyvsp[0].label_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5190 "Parser.c"
    break;

  case 182: /* LABEL_VAR: QUAL_STRUCT _SYMB_4 LABEL SUBSCRIPT  */
#line 869 "HAL_S.y"
                                        { (yyval.label_var_) = make_ADlabel_var((yyvsp[-3].qual_struct_), (yyvsp[-1].label_), (yyvsp[0].subscript_)); (yyval.label_var_)->line_number = (yyloc).first_line; (yyval.label_var_)->char_number = (yyloc).first_column;  }
#line 5196 "Parser.c"
    break;

  case 183: /* EVENT_VAR: EVENT  */
#line 871 "HAL_S.y"
                  { (yyval.event_var_) = make_AAevent_var((yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5202 "Parser.c"
    break;

  case 184: /* EVENT_VAR: EVENT SUBSCRIPT  */
#line 872 "HAL_S.y"
                    { (yyval.event_var_) = make_ACevent_var((yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5208 "Parser.c"
    break;

  case 185: /* EVENT_VAR: QUAL_STRUCT _SYMB_4 EVENT  */
#line 873 "HAL_S.y"
                              { (yyval.event_var_) = make_ABevent_var((yyvsp[-2].qual_struct_), (yyvsp[0].event_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5214 "Parser.c"
    break;

  case 186: /* EVENT_VAR: QUAL_STRUCT _SYMB_4 EVENT SUBSCRIPT  */
#line 874 "HAL_S.y"
                                        { (yyval.event_var_) = make_ADevent_var((yyvsp[-3].qual_struct_), (yyvsp[-1].event_), (yyvsp[0].subscript_)); (yyval.event_var_)->line_number = (yyloc).first_line; (yyval.event_var_)->char_number = (yyloc).first_column;  }
#line 5220 "Parser.c"
    break;

  case 187: /* BIT_CONST_HEAD: RADIX  */
#line 876 "HAL_S.y"
                       { (yyval.bit_const_head_) = make_AAbit_const_head((yyvsp[0].radix_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5226 "Parser.c"
    break;

  case 188: /* BIT_CONST_HEAD: RADIX _SYMB_6 NUMBER _SYMB_7  */
#line 877 "HAL_S.y"
                                 { (yyval.bit_const_head_) = make_ABbit_const_head((yyvsp[-3].radix_), (yyvsp[-1].number_)); (yyval.bit_const_head_)->line_number = (yyloc).first_line; (yyval.bit_const_head_)->char_number = (yyloc).first_column;  }
#line 5232 "Parser.c"
    break;

  case 189: /* BIT_CONST: BIT_CONST_HEAD CHAR_STRING  */
#line 879 "HAL_S.y"
                                       { (yyval.bit_const_) = make_AAbitConstString((yyvsp[-1].bit_const_head_), (yyvsp[0].char_string_)); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5238 "Parser.c"
    break;

  case 190: /* BIT_CONST: _SYMB_171  */
#line 880 "HAL_S.y"
              { (yyval.bit_const_) = make_ABbitConstTrue(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5244 "Parser.c"
    break;

  case 191: /* BIT_CONST: _SYMB_85  */
#line 881 "HAL_S.y"
             { (yyval.bit_const_) = make_ACbitConstFalse(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5250 "Parser.c"
    break;

  case 192: /* BIT_CONST: _SYMB_118  */
#line 882 "HAL_S.y"
              { (yyval.bit_const_) = make_ADbitConstOn(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5256 "Parser.c"
    break;

  case 193: /* BIT_CONST: _SYMB_117  */
#line 883 "HAL_S.y"
              { (yyval.bit_const_) = make_AEbitConstOff(); (yyval.bit_const_)->line_number = (yyloc).first_line; (yyval.bit_const_)->char_number = (yyloc).first_column;  }
#line 5262 "Parser.c"
    break;

  case 194: /* RADIX: _SYMB_91  */
#line 885 "HAL_S.y"
                 { (yyval.radix_) = make_AAradixHEX(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5268 "Parser.c"
    break;

  case 195: /* RADIX: _SYMB_115  */
#line 886 "HAL_S.y"
              { (yyval.radix_) = make_ABradixOCT(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5274 "Parser.c"
    break;

  case 196: /* RADIX: _SYMB_47  */
#line 887 "HAL_S.y"
             { (yyval.radix_) = make_ACradixBIN(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5280 "Parser.c"
    break;

  case 197: /* RADIX: _SYMB_66  */
#line 888 "HAL_S.y"
             { (yyval.radix_) = make_ADradixDEC(); (yyval.radix_)->line_number = (yyloc).first_line; (yyval.radix_)->char_number = (yyloc).first_column;  }
#line 5286 "Parser.c"
    break;

  case 198: /* CHAR_STRING: _SYMB_191  */
#line 890 "HAL_S.y"
                        { (yyval.char_string_) = make_FPchar_string((yyvsp[0].string_)); (yyval.char_string_)->line_number = (yyloc).first_line; (yyval.char_string_)->char_number = (yyloc).first_column;  }
#line 5292 "Parser.c"
    break;

  case 199: /* SUBBIT_HEAD: SUBBIT_KEY _SYMB_6  */
#line 892 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_AAsubbit_head((yyvsp[-1].subbit_key_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5298 "Parser.c"
    break;

  case 200: /* SUBBIT_HEAD: SUBBIT_KEY SUBSCRIPT _SYMB_6  */
#line 893 "HAL_S.y"
                                 { (yyval.subbit_head_) = make_ABsubbit_head((yyvsp[-2].subbit_key_), (yyvsp[-1].subscript_)); (yyval.subbit_head_)->line_number = (yyloc).first_line; (yyval.subbit_head_)->char_number = (yyloc).first_column;  }
#line 5304 "Parser.c"
    break;

  case 201: /* SUBBIT_KEY: _SYMB_157  */
#line 895 "HAL_S.y"
                       { (yyval.subbit_key_) = make_AAsubbit_key(); (yyval.subbit_key_)->line_number = (yyloc).first_line; (yyval.subbit_key_)->char_number = (yyloc).first_column;  }
#line 5310 "Parser.c"
    break;

  case 202: /* BIT_FUNC_HEAD: BIT_FUNC  */
#line 897 "HAL_S.y"
                         { (yyval.bit_func_head_) = make_AAbit_func_head((yyvsp[0].bit_func_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5316 "Parser.c"
    break;

  case 203: /* BIT_FUNC_HEAD: _SYMB_48  */
#line 898 "HAL_S.y"
             { (yyval.bit_func_head_) = make_ABbit_func_head(); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5322 "Parser.c"
    break;

  case 204: /* BIT_FUNC_HEAD: _SYMB_48 SUB_OR_QUALIFIER  */
#line 899 "HAL_S.y"
                              { (yyval.bit_func_head_) = make_ACbit_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.bit_func_head_)->line_number = (yyloc).first_line; (yyval.bit_func_head_)->char_number = (yyloc).first_column;  }
#line 5328 "Parser.c"
    break;

  case 205: /* BIT_ID: _SYMB_181  */
#line 901 "HAL_S.y"
                   { (yyval.bit_id_) = make_FHbit_id((yyvsp[0].string_)); (yyval.bit_id_)->line_number = (yyloc).first_line; (yyval.bit_id_)->char_number = (yyloc).first_column;  }
#line 5334 "Parser.c"
    break;

  case 206: /* LABEL: _SYMB_187  */
#line 903 "HAL_S.y"
                  { (yyval.label_) = make_FKlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5340 "Parser.c"
    break;

  case 207: /* LABEL: _SYMB_182  */
#line 904 "HAL_S.y"
              { (yyval.label_) = make_FLlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5346 "Parser.c"
    break;

  case 208: /* LABEL: _SYMB_183  */
#line 905 "HAL_S.y"
              { (yyval.label_) = make_FMlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5352 "Parser.c"
    break;

  case 209: /* LABEL: _SYMB_186  */
#line 906 "HAL_S.y"
              { (yyval.label_) = make_FNlabel((yyvsp[0].string_)); (yyval.label_)->line_number = (yyloc).first_line; (yyval.label_)->char_number = (yyloc).first_column;  }
#line 5358 "Parser.c"
    break;

  case 210: /* BIT_FUNC: _SYMB_180  */
#line 908 "HAL_S.y"
                     { (yyval.bit_func_) = make_ZZxor(); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5364 "Parser.c"
    break;

  case 211: /* BIT_FUNC: _SYMB_182  */
#line 909 "HAL_S.y"
              { (yyval.bit_func_) = make_ZZuserBitFunction((yyvsp[0].string_)); (yyval.bit_func_)->line_number = (yyloc).first_line; (yyval.bit_func_)->char_number = (yyloc).first_column;  }
#line 5370 "Parser.c"
    break;

  case 212: /* EVENT: _SYMB_188  */
#line 911 "HAL_S.y"
                  { (yyval.event_) = make_FLevent((yyvsp[0].string_)); (yyval.event_)->line_number = (yyloc).first_line; (yyval.event_)->char_number = (yyloc).first_column;  }
#line 5376 "Parser.c"
    break;

  case 213: /* SUB_OR_QUALIFIER: SUBSCRIPT  */
#line 913 "HAL_S.y"
                             { (yyval.sub_or_qualifier_) = make_AAsub_or_qualifier((yyvsp[0].subscript_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 5382 "Parser.c"
    break;

  case 214: /* SUB_OR_QUALIFIER: BIT_QUALIFIER  */
#line 914 "HAL_S.y"
                  { (yyval.sub_or_qualifier_) = make_ABsub_or_qualifier((yyvsp[0].bit_qualifier_)); (yyval.sub_or_qualifier_)->line_number = (yyloc).first_line; (yyval.sub_or_qualifier_)->char_number = (yyloc).first_column;  }
#line 5388 "Parser.c"
    break;

  case 215: /* BIT_QUALIFIER: _SYMB_24 _SYMB_14 _SYMB_6 _SYMB_15 RADIX _SYMB_7  */
#line 916 "HAL_S.y"
                                                                 { (yyval.bit_qualifier_) = make_AAbit_qualifier((yyvsp[-1].radix_)); (yyval.bit_qualifier_)->line_number = (yyloc).first_line; (yyval.bit_qualifier_)->char_number = (yyloc).first_column;  }
#line 5394 "Parser.c"
    break;

  case 216: /* CHAR_EXP: CHAR_PRIM  */
#line 918 "HAL_S.y"
                     { (yyval.char_exp_) = make_AAchar_exp((yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5400 "Parser.c"
    break;

  case 217: /* CHAR_EXP: CHAR_EXP CAT CHAR_PRIM  */
#line 919 "HAL_S.y"
                           { (yyval.char_exp_) = make_ABchar_exp((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5406 "Parser.c"
    break;

  case 218: /* CHAR_EXP: CHAR_EXP CAT ARITH_EXP  */
#line 920 "HAL_S.y"
                           { (yyval.char_exp_) = make_ACchar_exp((yyvsp[-2].char_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5412 "Parser.c"
    break;

  case 219: /* CHAR_EXP: ARITH_EXP CAT ARITH_EXP  */
#line 921 "HAL_S.y"
                            { (yyval.char_exp_) = make_ADchar_exp((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].arith_exp_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5418 "Parser.c"
    break;

  case 220: /* CHAR_EXP: ARITH_EXP CAT CHAR_PRIM  */
#line 922 "HAL_S.y"
                            { (yyval.char_exp_) = make_AEchar_exp((yyvsp[-2].arith_exp_), (yyvsp[-1].cat_), (yyvsp[0].char_prim_)); (yyval.char_exp_)->line_number = (yyloc).first_line; (yyval.char_exp_)->char_number = (yyloc).first_column;  }
#line 5424 "Parser.c"
    break;

  case 221: /* CHAR_PRIM: CHAR_VAR  */
#line 924 "HAL_S.y"
                     { (yyval.char_prim_) = make_AAchar_prim((yyvsp[0].char_var_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5430 "Parser.c"
    break;

  case 222: /* CHAR_PRIM: CHAR_CONST  */
#line 925 "HAL_S.y"
               { (yyval.char_prim_) = make_ABchar_prim((yyvsp[0].char_const_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5436 "Parser.c"
    break;

  case 223: /* CHAR_PRIM: CHAR_FUNC_HEAD _SYMB_6 CALL_LIST _SYMB_7  */
#line 926 "HAL_S.y"
                                             { (yyval.char_prim_) = make_AEchar_prim((yyvsp[-3].char_func_head_), (yyvsp[-1].call_list_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5442 "Parser.c"
    break;

  case 224: /* CHAR_PRIM: _SYMB_6 CHAR_EXP _SYMB_7  */
#line 927 "HAL_S.y"
                             { (yyval.char_prim_) = make_AFchar_prim((yyvsp[-1].char_exp_)); (yyval.char_prim_)->line_number = (yyloc).first_line; (yyval.char_prim_)->char_number = (yyloc).first_column;  }
#line 5448 "Parser.c"
    break;

  case 225: /* CHAR_FUNC_HEAD: CHAR_FUNC  */
#line 929 "HAL_S.y"
                           { (yyval.char_func_head_) = make_AAchar_func_head((yyvsp[0].char_func_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 5454 "Parser.c"
    break;

  case 226: /* CHAR_FUNC_HEAD: _SYMB_57 SUB_OR_QUALIFIER  */
#line 930 "HAL_S.y"
                              { (yyval.char_func_head_) = make_ABchar_func_head((yyvsp[0].sub_or_qualifier_)); (yyval.char_func_head_)->line_number = (yyloc).first_line; (yyval.char_func_head_)->char_number = (yyloc).first_column;  }
#line 5460 "Parser.c"
    break;

  case 227: /* CHAR_VAR: CHAR_ID  */
#line 932 "HAL_S.y"
                   { (yyval.char_var_) = make_AAchar_var((yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5466 "Parser.c"
    break;

  case 228: /* CHAR_VAR: CHAR_ID SUBSCRIPT  */
#line 933 "HAL_S.y"
                      { (yyval.char_var_) = make_ACchar_var((yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5472 "Parser.c"
    break;

  case 229: /* CHAR_VAR: QUAL_STRUCT _SYMB_4 CHAR_ID  */
#line 934 "HAL_S.y"
                                { (yyval.char_var_) = make_ABchar_var((yyvsp[-2].qual_struct_), (yyvsp[0].char_id_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5478 "Parser.c"
    break;

  case 230: /* CHAR_VAR: QUAL_STRUCT _SYMB_4 CHAR_ID SUBSCRIPT  */
#line 935 "HAL_S.y"
                                          { (yyval.char_var_) = make_ADchar_var((yyvsp[-3].qual_struct_), (yyvsp[-1].char_id_), (yyvsp[0].subscript_)); (yyval.char_var_)->line_number = (yyloc).first_line; (yyval.char_var_)->char_number = (yyloc).first_column;  }
#line 5484 "Parser.c"
    break;

  case 231: /* CHAR_CONST: CHAR_STRING  */
#line 937 "HAL_S.y"
                         { (yyval.char_const_) = make_AAchar_const((yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 5490 "Parser.c"
    break;

  case 232: /* CHAR_CONST: _SYMB_56 _SYMB_6 NUMBER _SYMB_7 CHAR_STRING  */
#line 938 "HAL_S.y"
                                                { (yyval.char_const_) = make_ABchar_const((yyvsp[-2].number_), (yyvsp[0].char_string_)); (yyval.char_const_)->line_number = (yyloc).first_line; (yyval.char_const_)->char_number = (yyloc).first_column;  }
#line 5496 "Parser.c"
    break;

  case 233: /* CHAR_FUNC: _SYMB_102  */
#line 940 "HAL_S.y"
                      { (yyval.char_func_) = make_ZZljust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5502 "Parser.c"
    break;

  case 234: /* CHAR_FUNC: _SYMB_137  */
#line 941 "HAL_S.y"
              { (yyval.char_func_) = make_ZZrjust(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5508 "Parser.c"
    break;

  case 235: /* CHAR_FUNC: _SYMB_170  */
#line 942 "HAL_S.y"
              { (yyval.char_func_) = make_ZZtrim(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5514 "Parser.c"
    break;

  case 236: /* CHAR_FUNC: _SYMB_183  */
#line 943 "HAL_S.y"
              { (yyval.char_func_) = make_ZZuserCharFunction((yyvsp[0].string_)); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5520 "Parser.c"
    break;

  case 237: /* CHAR_FUNC: _SYMB_57  */
#line 944 "HAL_S.y"
             { (yyval.char_func_) = make_AAcharFuncCharacter(); (yyval.char_func_)->line_number = (yyloc).first_line; (yyval.char_func_)->char_number = (yyloc).first_column;  }
#line 5526 "Parser.c"
    break;

  case 238: /* CHAR_ID: _SYMB_184  */
#line 946 "HAL_S.y"
                    { (yyval.char_id_) = make_FIchar_id((yyvsp[0].string_)); (yyval.char_id_)->line_number = (yyloc).first_line; (yyval.char_id_)->char_number = (yyloc).first_column;  }
#line 5532 "Parser.c"
    break;

  case 239: /* NAME_EXP: NAME_KEY _SYMB_6 NAME_VAR _SYMB_7  */
#line 948 "HAL_S.y"
                                             { (yyval.name_exp_) = make_AAnameExpKeyVar((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5538 "Parser.c"
    break;

  case 240: /* NAME_EXP: _SYMB_114  */
#line 949 "HAL_S.y"
              { (yyval.name_exp_) = make_ABnameExpNull(); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5544 "Parser.c"
    break;

  case 241: /* NAME_EXP: NAME_KEY _SYMB_6 _SYMB_114 _SYMB_7  */
#line 950 "HAL_S.y"
                                       { (yyval.name_exp_) = make_ACnameExpKeyNull((yyvsp[-3].name_key_)); (yyval.name_exp_)->line_number = (yyloc).first_line; (yyval.name_exp_)->char_number = (yyloc).first_column;  }
#line 5550 "Parser.c"
    break;

  case 242: /* NAME_KEY: _SYMB_110  */
#line 952 "HAL_S.y"
                     { (yyval.name_key_) = make_AAname_key(); (yyval.name_key_)->line_number = (yyloc).first_line; (yyval.name_key_)->char_number = (yyloc).first_column;  }
#line 5556 "Parser.c"
    break;

  case 243: /* NAME_VAR: VARIABLE  */
#line 954 "HAL_S.y"
                    { (yyval.name_var_) = make_AAname_var((yyvsp[0].variable_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5562 "Parser.c"
    break;

  case 244: /* NAME_VAR: MODIFIED_ARITH_FUNC  */
#line 955 "HAL_S.y"
                        { (yyval.name_var_) = make_ACname_var((yyvsp[0].modified_arith_func_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5568 "Parser.c"
    break;

  case 245: /* NAME_VAR: LABEL_VAR  */
#line 956 "HAL_S.y"
              { (yyval.name_var_) = make_ABname_var((yyvsp[0].label_var_)); (yyval.name_var_)->line_number = (yyloc).first_line; (yyval.name_var_)->char_number = (yyloc).first_column;  }
#line 5574 "Parser.c"
    break;

  case 246: /* VARIABLE: ARITH_VAR  */
#line 958 "HAL_S.y"
                     { (yyval.variable_) = make_AAvariable((yyvsp[0].arith_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5580 "Parser.c"
    break;

  case 247: /* VARIABLE: BIT_VAR  */
#line 959 "HAL_S.y"
            { (yyval.variable_) = make_ACvariable((yyvsp[0].bit_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5586 "Parser.c"
    break;

  case 248: /* VARIABLE: SUBBIT_HEAD VARIABLE _SYMB_7  */
#line 960 "HAL_S.y"
                                 { (yyval.variable_) = make_AEvariable((yyvsp[-2].subbit_head_), (yyvsp[-1].variable_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5592 "Parser.c"
    break;

  case 249: /* VARIABLE: CHAR_VAR  */
#line 961 "HAL_S.y"
             { (yyval.variable_) = make_AFvariable((yyvsp[0].char_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5598 "Parser.c"
    break;

  case 250: /* VARIABLE: NAME_KEY _SYMB_6 NAME_VAR _SYMB_7  */
#line 962 "HAL_S.y"
                                      { (yyval.variable_) = make_AGvariable((yyvsp[-3].name_key_), (yyvsp[-1].name_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5604 "Parser.c"
    break;

  case 251: /* VARIABLE: EVENT_VAR  */
#line 963 "HAL_S.y"
              { (yyval.variable_) = make_ADvariable((yyvsp[0].event_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5610 "Parser.c"
    break;

  case 252: /* VARIABLE: STRUCTURE_VAR  */
#line 964 "HAL_S.y"
                  { (yyval.variable_) = make_ABvariable((yyvsp[0].structure_var_)); (yyval.variable_)->line_number = (yyloc).first_line; (yyval.variable_)->char_number = (yyloc).first_column;  }
#line 5616 "Parser.c"
    break;

  case 253: /* STRUCTURE_EXP: STRUCTURE_VAR  */
#line 966 "HAL_S.y"
                              { (yyval.structure_exp_) = make_AAstructure_exp((yyvsp[0].structure_var_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5622 "Parser.c"
    break;

  case 254: /* STRUCTURE_EXP: STRUCT_FUNC_HEAD _SYMB_6 CALL_LIST _SYMB_7  */
#line 967 "HAL_S.y"
                                               { (yyval.structure_exp_) = make_ADstructure_exp((yyvsp[-3].struct_func_head_), (yyvsp[-1].call_list_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5628 "Parser.c"
    break;

  case 255: /* STRUCTURE_EXP: STRUC_INLINE_DEF CLOSING _SYMB_16  */
#line 968 "HAL_S.y"
                                      { (yyval.structure_exp_) = make_ACstructure_exp((yyvsp[-2].struc_inline_def_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5634 "Parser.c"
    break;

  case 256: /* STRUCTURE_EXP: STRUC_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 969 "HAL_S.y"
                                                 { (yyval.structure_exp_) = make_AEstructure_exp((yyvsp[-3].struc_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.structure_exp_)->line_number = (yyloc).first_line; (yyval.structure_exp_)->char_number = (yyloc).first_column;  }
#line 5640 "Parser.c"
    break;

  case 257: /* STRUCT_FUNC_HEAD: STRUCT_FUNC  */
#line 971 "HAL_S.y"
                               { (yyval.struct_func_head_) = make_AAstruct_func_head((yyvsp[0].struct_func_)); (yyval.struct_func_head_)->line_number = (yyloc).first_line; (yyval.struct_func_head_)->char_number = (yyloc).first_column;  }
#line 5646 "Parser.c"
    break;

  case 258: /* STRUCTURE_VAR: QUAL_STRUCT SUBSCRIPT  */
#line 973 "HAL_S.y"
                                      { (yyval.structure_var_) = make_AAstructure_var((yyvsp[-1].qual_struct_), (yyvsp[0].subscript_)); (yyval.structure_var_)->line_number = (yyloc).first_line; (yyval.structure_var_)->char_number = (yyloc).first_column;  }
#line 5652 "Parser.c"
    break;

  case 259: /* STRUCT_FUNC: _SYMB_186  */
#line 975 "HAL_S.y"
                        { (yyval.struct_func_) = make_ZZuserStructFunc((yyvsp[0].string_)); (yyval.struct_func_)->line_number = (yyloc).first_line; (yyval.struct_func_)->char_number = (yyloc).first_column;  }
#line 5658 "Parser.c"
    break;

  case 260: /* QUAL_STRUCT: STRUCTURE_ID  */
#line 977 "HAL_S.y"
                           { (yyval.qual_struct_) = make_AAqual_struct((yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 5664 "Parser.c"
    break;

  case 261: /* QUAL_STRUCT: QUAL_STRUCT _SYMB_4 STRUCTURE_ID  */
#line 978 "HAL_S.y"
                                     { (yyval.qual_struct_) = make_ABqual_struct((yyvsp[-2].qual_struct_), (yyvsp[0].structure_id_)); (yyval.qual_struct_)->line_number = (yyloc).first_line; (yyval.qual_struct_)->char_number = (yyloc).first_column;  }
#line 5670 "Parser.c"
    break;

  case 262: /* STRUCTURE_ID: _SYMB_185  */
#line 980 "HAL_S.y"
                         { (yyval.structure_id_) = make_FJstructure_id((yyvsp[0].string_)); (yyval.structure_id_)->line_number = (yyloc).first_line; (yyval.structure_id_)->char_number = (yyloc).first_column;  }
#line 5676 "Parser.c"
    break;

  case 263: /* ASSIGNMENT: VARIABLE EQUALS EXPRESSION  */
#line 982 "HAL_S.y"
                                        { (yyval.assignment_) = make_AAassignment((yyvsp[-2].variable_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5682 "Parser.c"
    break;

  case 264: /* ASSIGNMENT: VARIABLE _SYMB_8 ASSIGNMENT  */
#line 983 "HAL_S.y"
                                { (yyval.assignment_) = make_ABassignment((yyvsp[-2].variable_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5688 "Parser.c"
    break;

  case 265: /* ASSIGNMENT: QUAL_STRUCT EQUALS EXPRESSION  */
#line 984 "HAL_S.y"
                                  { (yyval.assignment_) = make_ACassignment((yyvsp[-2].qual_struct_), (yyvsp[-1].equals_), (yyvsp[0].expression_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5694 "Parser.c"
    break;

  case 266: /* ASSIGNMENT: QUAL_STRUCT _SYMB_8 ASSIGNMENT  */
#line 985 "HAL_S.y"
                                   { (yyval.assignment_) = make_ADassignment((yyvsp[-2].qual_struct_), (yyvsp[0].assignment_)); (yyval.assignment_)->line_number = (yyloc).first_line; (yyval.assignment_)->char_number = (yyloc).first_column;  }
#line 5700 "Parser.c"
    break;

  case 267: /* EQUALS: _SYMB_25  */
#line 987 "HAL_S.y"
                  { (yyval.equals_) = make_AAequals(); (yyval.equals_)->line_number = (yyloc).first_line; (yyval.equals_)->char_number = (yyloc).first_column;  }
#line 5706 "Parser.c"
    break;

  case 268: /* IF_STATEMENT: IF_CLAUSE STATEMENT  */
#line 989 "HAL_S.y"
                                   { (yyval.if_statement_) = make_AAifStatement((yyvsp[-1].if_clause_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 5712 "Parser.c"
    break;

  case 269: /* IF_STATEMENT: TRUE_PART STATEMENT  */
#line 990 "HAL_S.y"
                        { (yyval.if_statement_) = make_ABifThenElseStatement((yyvsp[-1].true_part_), (yyvsp[0].statement_)); (yyval.if_statement_)->line_number = (yyloc).first_line; (yyval.if_statement_)->char_number = (yyloc).first_column;  }
#line 5718 "Parser.c"
    break;

  case 270: /* IF_CLAUSE: IF RELATIONAL_EXP THEN  */
#line 992 "HAL_S.y"
                                   { (yyval.if_clause_) = make_AAif_clause((yyvsp[-2].if_), (yyvsp[-1].relational_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 5724 "Parser.c"
    break;

  case 271: /* IF_CLAUSE: IF BIT_EXP THEN  */
#line 993 "HAL_S.y"
                    { (yyval.if_clause_) = make_ABif_clause((yyvsp[-2].if_), (yyvsp[-1].bit_exp_), (yyvsp[0].then_)); (yyval.if_clause_)->line_number = (yyloc).first_line; (yyval.if_clause_)->char_number = (yyloc).first_column;  }
#line 5730 "Parser.c"
    break;

  case 272: /* TRUE_PART: IF_CLAUSE BASIC_STATEMENT _SYMB_74  */
#line 995 "HAL_S.y"
                                               { (yyval.true_part_) = make_AAtrue_part((yyvsp[-2].if_clause_), (yyvsp[-1].basic_statement_)); (yyval.true_part_)->line_number = (yyloc).first_line; (yyval.true_part_)->char_number = (yyloc).first_column;  }
#line 5736 "Parser.c"
    break;

  case 273: /* IF: _SYMB_92  */
#line 997 "HAL_S.y"
              { (yyval.if_) = make_AAif(); (yyval.if_)->line_number = (yyloc).first_line; (yyval.if_)->char_number = (yyloc).first_column;  }
#line 5742 "Parser.c"
    break;

  case 274: /* THEN: _SYMB_166  */
#line 999 "HAL_S.y"
                 { (yyval.then_) = make_AAthen(); (yyval.then_)->line_number = (yyloc).first_line; (yyval.then_)->char_number = (yyloc).first_column;  }
#line 5748 "Parser.c"
    break;

  case 275: /* RELATIONAL_EXP: RELATIONAL_FACTOR  */
#line 1001 "HAL_S.y"
                                   { (yyval.relational_exp_) = make_AArelational_exp((yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 5754 "Parser.c"
    break;

  case 276: /* RELATIONAL_EXP: RELATIONAL_EXP OR RELATIONAL_FACTOR  */
#line 1002 "HAL_S.y"
                                        { (yyval.relational_exp_) = make_ABrelational_exp((yyvsp[-2].relational_exp_), (yyvsp[-1].or_), (yyvsp[0].relational_factor_)); (yyval.relational_exp_)->line_number = (yyloc).first_line; (yyval.relational_exp_)->char_number = (yyloc).first_column;  }
#line 5760 "Parser.c"
    break;

  case 277: /* RELATIONAL_FACTOR: REL_PRIM  */
#line 1004 "HAL_S.y"
                             { (yyval.relational_factor_) = make_AArelational_factor((yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 5766 "Parser.c"
    break;

  case 278: /* RELATIONAL_FACTOR: RELATIONAL_FACTOR AND REL_PRIM  */
#line 1005 "HAL_S.y"
                                   { (yyval.relational_factor_) = make_ABrelational_factor((yyvsp[-2].relational_factor_), (yyvsp[-1].and_), (yyvsp[0].rel_prim_)); (yyval.relational_factor_)->line_number = (yyloc).first_line; (yyval.relational_factor_)->char_number = (yyloc).first_column;  }
#line 5772 "Parser.c"
    break;

  case 279: /* REL_PRIM: _SYMB_6 RELATIONAL_EXP _SYMB_7  */
#line 1007 "HAL_S.y"
                                          { (yyval.rel_prim_) = make_AArel_prim((yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 5778 "Parser.c"
    break;

  case 280: /* REL_PRIM: NOT _SYMB_6 RELATIONAL_EXP _SYMB_7  */
#line 1008 "HAL_S.y"
                                       { (yyval.rel_prim_) = make_ABrel_prim((yyvsp[-3].not_), (yyvsp[-1].relational_exp_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 5784 "Parser.c"
    break;

  case 281: /* REL_PRIM: COMPARISON  */
#line 1009 "HAL_S.y"
               { (yyval.rel_prim_) = make_ACrel_prim((yyvsp[0].comparison_)); (yyval.rel_prim_)->line_number = (yyloc).first_line; (yyval.rel_prim_)->char_number = (yyloc).first_column;  }
#line 5790 "Parser.c"
    break;

  case 282: /* COMPARISON: ARITH_EXP RELATIONAL_OP ARITH_EXP  */
#line 1011 "HAL_S.y"
                                               { (yyval.comparison_) = make_AAcomparison((yyvsp[-2].arith_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].arith_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 5796 "Parser.c"
    break;

  case 283: /* COMPARISON: CHAR_EXP RELATIONAL_OP CHAR_EXP  */
#line 1012 "HAL_S.y"
                                    { (yyval.comparison_) = make_ABcomparison((yyvsp[-2].char_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].char_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 5802 "Parser.c"
    break;

  case 284: /* COMPARISON: BIT_CAT RELATIONAL_OP BIT_CAT  */
#line 1013 "HAL_S.y"
                                  { (yyval.comparison_) = make_ACcomparison((yyvsp[-2].bit_cat_), (yyvsp[-1].relational_op_), (yyvsp[0].bit_cat_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 5808 "Parser.c"
    break;

  case 285: /* COMPARISON: STRUCTURE_EXP RELATIONAL_OP STRUCTURE_EXP  */
#line 1014 "HAL_S.y"
                                              { (yyval.comparison_) = make_ADcomparison((yyvsp[-2].structure_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].structure_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 5814 "Parser.c"
    break;

  case 286: /* COMPARISON: NAME_EXP RELATIONAL_OP NAME_EXP  */
#line 1015 "HAL_S.y"
                                    { (yyval.comparison_) = make_AEcomparison((yyvsp[-2].name_exp_), (yyvsp[-1].relational_op_), (yyvsp[0].name_exp_)); (yyval.comparison_)->line_number = (yyloc).first_line; (yyval.comparison_)->char_number = (yyloc).first_column;  }
#line 5820 "Parser.c"
    break;

  case 287: /* RELATIONAL_OP: EQUALS  */
#line 1017 "HAL_S.y"
                       { (yyval.relational_op_) = make_AArelationalOpEQ((yyvsp[0].equals_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 5826 "Parser.c"
    break;

  case 288: /* RELATIONAL_OP: NOT EQUALS  */
#line 1018 "HAL_S.y"
               { (yyval.relational_op_) = make_ABrelationalOpNEQ((yyvsp[-1].not_), (yyvsp[0].equals_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 5832 "Parser.c"
    break;

  case 289: /* RELATIONAL_OP: _SYMB_24  */
#line 1019 "HAL_S.y"
             { (yyval.relational_op_) = make_ACrelationalOpLT(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 5838 "Parser.c"
    break;

  case 290: /* RELATIONAL_OP: _SYMB_26  */
#line 1020 "HAL_S.y"
             { (yyval.relational_op_) = make_ADrelationalOpGT(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 5844 "Parser.c"
    break;

  case 291: /* RELATIONAL_OP: _SYMB_27  */
#line 1021 "HAL_S.y"
             { (yyval.relational_op_) = make_AErelationalOpLE(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 5850 "Parser.c"
    break;

  case 292: /* RELATIONAL_OP: _SYMB_28  */
#line 1022 "HAL_S.y"
             { (yyval.relational_op_) = make_AFrelationalOpGE(); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 5856 "Parser.c"
    break;

  case 293: /* RELATIONAL_OP: NOT _SYMB_24  */
#line 1023 "HAL_S.y"
                 { (yyval.relational_op_) = make_AGrelationalOpNLT((yyvsp[-1].not_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 5862 "Parser.c"
    break;

  case 294: /* RELATIONAL_OP: NOT _SYMB_26  */
#line 1024 "HAL_S.y"
                 { (yyval.relational_op_) = make_AHrelationalOpNGT((yyvsp[-1].not_)); (yyval.relational_op_)->line_number = (yyloc).first_line; (yyval.relational_op_)->char_number = (yyloc).first_column;  }
#line 5868 "Parser.c"
    break;

  case 295: /* STATEMENT: BASIC_STATEMENT  */
#line 1026 "HAL_S.y"
                            { (yyval.statement_) = make_AAstatement((yyvsp[0].basic_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 5874 "Parser.c"
    break;

  case 296: /* STATEMENT: OTHER_STATEMENT  */
#line 1027 "HAL_S.y"
                    { (yyval.statement_) = make_ABstatement((yyvsp[0].other_statement_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 5880 "Parser.c"
    break;

  case 297: /* STATEMENT: INLINE_DEFINITION  */
#line 1028 "HAL_S.y"
                      { (yyval.statement_) = make_AZstatement((yyvsp[0].inline_definition_)); (yyval.statement_)->line_number = (yyloc).first_line; (yyval.statement_)->char_number = (yyloc).first_column;  }
#line 5886 "Parser.c"
    break;

  case 298: /* BASIC_STATEMENT: ASSIGNMENT _SYMB_16  */
#line 1030 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_ABbasicStatementAssignment((yyvsp[-1].assignment_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 5892 "Parser.c"
    break;

  case 299: /* BASIC_STATEMENT: LABEL_DEFINITION BASIC_STATEMENT  */
#line 1031 "HAL_S.y"
                                     { (yyval.basic_statement_) = make_AAbasic_statement((yyvsp[-1].label_definition_), (yyvsp[0].basic_statement_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 5898 "Parser.c"
    break;

  case 300: /* BASIC_STATEMENT: _SYMB_82 _SYMB_16  */
#line 1032 "HAL_S.y"
                      { (yyval.basic_statement_) = make_ACbasicStatementExit(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 5904 "Parser.c"
    break;

  case 301: /* BASIC_STATEMENT: _SYMB_82 LABEL _SYMB_16  */
#line 1033 "HAL_S.y"
                            { (yyval.basic_statement_) = make_ADbasicStatementExit((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 5910 "Parser.c"
    break;

  case 302: /* BASIC_STATEMENT: _SYMB_132 _SYMB_16  */
#line 1034 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AEbasicStatementRepeat(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 5916 "Parser.c"
    break;

  case 303: /* BASIC_STATEMENT: _SYMB_132 LABEL _SYMB_16  */
#line 1035 "HAL_S.y"
                             { (yyval.basic_statement_) = make_AFbasicStatementRepeat((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 5922 "Parser.c"
    break;

  case 304: /* BASIC_STATEMENT: _SYMB_90 _SYMB_167 LABEL _SYMB_16  */
#line 1036 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AGbasicStatementGoTo((yyvsp[-1].label_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 5928 "Parser.c"
    break;

  case 305: /* BASIC_STATEMENT: _SYMB_16  */
#line 1037 "HAL_S.y"
             { (yyval.basic_statement_) = make_AHbasicStatementEmpty(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 5934 "Parser.c"
    break;

  case 306: /* BASIC_STATEMENT: CALL_KEY _SYMB_16  */
#line 1038 "HAL_S.y"
                      { (yyval.basic_statement_) = make_AIbasicStatementCall((yyvsp[-1].call_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 5940 "Parser.c"
    break;

  case 307: /* BASIC_STATEMENT: CALL_KEY _SYMB_6 CALL_LIST _SYMB_7 _SYMB_16  */
#line 1039 "HAL_S.y"
                                                { (yyval.basic_statement_) = make_AJbasicStatementCall((yyvsp[-4].call_key_), (yyvsp[-2].call_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 5946 "Parser.c"
    break;

  case 308: /* BASIC_STATEMENT: CALL_KEY ASSIGN _SYMB_6 CALL_ASSIGN_LIST _SYMB_7 _SYMB_16  */
#line 1040 "HAL_S.y"
                                                              { (yyval.basic_statement_) = make_AKbasicStatementCall((yyvsp[-5].call_key_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 5952 "Parser.c"
    break;

  case 309: /* BASIC_STATEMENT: CALL_KEY _SYMB_6 CALL_LIST _SYMB_7 ASSIGN _SYMB_6 CALL_ASSIGN_LIST _SYMB_7 _SYMB_16  */
#line 1041 "HAL_S.y"
                                                                                        { (yyval.basic_statement_) = make_ALbasicStatementCall((yyvsp[-8].call_key_), (yyvsp[-6].call_list_), (yyvsp[-4].assign_), (yyvsp[-2].call_assign_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 5958 "Parser.c"
    break;

  case 310: /* BASIC_STATEMENT: _SYMB_135 _SYMB_16  */
#line 1042 "HAL_S.y"
                       { (yyval.basic_statement_) = make_AMbasicStatementReturn(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 5964 "Parser.c"
    break;

  case 311: /* BASIC_STATEMENT: _SYMB_135 EXPRESSION _SYMB_16  */
#line 1043 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_ANbasicStatementReturn((yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 5970 "Parser.c"
    break;

  case 312: /* BASIC_STATEMENT: DO_GROUP_HEAD ENDING _SYMB_16  */
#line 1044 "HAL_S.y"
                                  { (yyval.basic_statement_) = make_AObasicStatementDo((yyvsp[-2].do_group_head_), (yyvsp[-1].ending_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 5976 "Parser.c"
    break;

  case 313: /* BASIC_STATEMENT: READ_KEY _SYMB_16  */
#line 1045 "HAL_S.y"
                      { (yyval.basic_statement_) = make_APbasicStatementReadKey((yyvsp[-1].read_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 5982 "Parser.c"
    break;

  case 314: /* BASIC_STATEMENT: READ_PHRASE _SYMB_16  */
#line 1046 "HAL_S.y"
                         { (yyval.basic_statement_) = make_AQbasicStatementReadPhrase((yyvsp[-1].read_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 5988 "Parser.c"
    break;

  case 315: /* BASIC_STATEMENT: WRITE_KEY _SYMB_16  */
#line 1047 "HAL_S.y"
                       { (yyval.basic_statement_) = make_ARbasicStatementWriteKey((yyvsp[-1].write_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 5994 "Parser.c"
    break;

  case 316: /* BASIC_STATEMENT: WRITE_PHRASE _SYMB_16  */
#line 1048 "HAL_S.y"
                          { (yyval.basic_statement_) = make_ASbasicStatementWritePhrase((yyvsp[-1].write_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6000 "Parser.c"
    break;

  case 317: /* BASIC_STATEMENT: FILE_EXP EQUALS EXPRESSION _SYMB_16  */
#line 1049 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_ATbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].expression_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6006 "Parser.c"
    break;

  case 318: /* BASIC_STATEMENT: VARIABLE EQUALS FILE_EXP _SYMB_16  */
#line 1050 "HAL_S.y"
                                      { (yyval.basic_statement_) = make_AUbasicStatementFileExp((yyvsp[-3].variable_), (yyvsp[-2].equals_), (yyvsp[-1].file_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6012 "Parser.c"
    break;

  case 319: /* BASIC_STATEMENT: FILE_EXP EQUALS QUAL_STRUCT _SYMB_16  */
#line 1051 "HAL_S.y"
                                         { (yyval.basic_statement_) = make_AVbasicStatementFileExp((yyvsp[-3].file_exp_), (yyvsp[-2].equals_), (yyvsp[-1].qual_struct_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6018 "Parser.c"
    break;

  case 320: /* BASIC_STATEMENT: WAIT_KEY _SYMB_88 _SYMB_69 _SYMB_16  */
#line 1052 "HAL_S.y"
                                        { (yyval.basic_statement_) = make_AVbasicStatementWait((yyvsp[-3].wait_key_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6024 "Parser.c"
    break;

  case 321: /* BASIC_STATEMENT: WAIT_KEY ARITH_EXP _SYMB_16  */
#line 1053 "HAL_S.y"
                                { (yyval.basic_statement_) = make_AWbasicStatementWait((yyvsp[-2].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6030 "Parser.c"
    break;

  case 322: /* BASIC_STATEMENT: WAIT_KEY _SYMB_174 ARITH_EXP _SYMB_16  */
#line 1054 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_AXbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6036 "Parser.c"
    break;

  case 323: /* BASIC_STATEMENT: WAIT_KEY _SYMB_88 BIT_EXP _SYMB_16  */
#line 1055 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_AYbasicStatementWait((yyvsp[-3].wait_key_), (yyvsp[-1].bit_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6042 "Parser.c"
    break;

  case 324: /* BASIC_STATEMENT: TERMINATOR _SYMB_16  */
#line 1056 "HAL_S.y"
                        { (yyval.basic_statement_) = make_AZbasicStatementTerminator((yyvsp[-1].terminator_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6048 "Parser.c"
    break;

  case 325: /* BASIC_STATEMENT: TERMINATOR TERMINATE_LIST _SYMB_16  */
#line 1057 "HAL_S.y"
                                       { (yyval.basic_statement_) = make_BAbasicStatementTerminator((yyvsp[-2].terminator_), (yyvsp[-1].terminate_list_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6054 "Parser.c"
    break;

  case 326: /* BASIC_STATEMENT: _SYMB_175 _SYMB_122 _SYMB_167 ARITH_EXP _SYMB_16  */
#line 1058 "HAL_S.y"
                                                     { (yyval.basic_statement_) = make_BBbasicStatementUpdate((yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6060 "Parser.c"
    break;

  case 327: /* BASIC_STATEMENT: _SYMB_175 _SYMB_122 LABEL_VAR _SYMB_167 ARITH_EXP _SYMB_16  */
#line 1059 "HAL_S.y"
                                                               { (yyval.basic_statement_) = make_BCbasicStatementUpdate((yyvsp[-3].label_var_), (yyvsp[-1].arith_exp_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6066 "Parser.c"
    break;

  case 328: /* BASIC_STATEMENT: SCHEDULE_PHRASE _SYMB_16  */
#line 1060 "HAL_S.y"
                             { (yyval.basic_statement_) = make_BDbasicStatementSchedule((yyvsp[-1].schedule_phrase_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6072 "Parser.c"
    break;

  case 329: /* BASIC_STATEMENT: SCHEDULE_PHRASE SCHEDULE_CONTROL _SYMB_16  */
#line 1061 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BEbasicStatementSchedule((yyvsp[-2].schedule_phrase_), (yyvsp[-1].schedule_control_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6078 "Parser.c"
    break;

  case 330: /* BASIC_STATEMENT: SIGNAL_CLAUSE _SYMB_16  */
#line 1062 "HAL_S.y"
                           { (yyval.basic_statement_) = make_BFbasicStatementSignal((yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6084 "Parser.c"
    break;

  case 331: /* BASIC_STATEMENT: _SYMB_142 _SYMB_78 SUBSCRIPT _SYMB_16  */
#line 1063 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BGbasicStatementSend((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6090 "Parser.c"
    break;

  case 332: /* BASIC_STATEMENT: _SYMB_142 _SYMB_78 _SYMB_16  */
#line 1064 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BHbasicStatementSend(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6096 "Parser.c"
    break;

  case 333: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_16  */
#line 1065 "HAL_S.y"
                       { (yyval.basic_statement_) = make_BHbasicStatementOn((yyvsp[-1].on_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6102 "Parser.c"
    break;

  case 334: /* BASIC_STATEMENT: ON_CLAUSE _SYMB_35 SIGNAL_CLAUSE _SYMB_16  */
#line 1066 "HAL_S.y"
                                              { (yyval.basic_statement_) = make_BIbasicStatementOnAndSignal((yyvsp[-3].on_clause_), (yyvsp[-1].signal_clause_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6108 "Parser.c"
    break;

  case 335: /* BASIC_STATEMENT: _SYMB_117 _SYMB_78 SUBSCRIPT _SYMB_16  */
#line 1067 "HAL_S.y"
                                          { (yyval.basic_statement_) = make_BJbasicStatementOff((yyvsp[-1].subscript_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6114 "Parser.c"
    break;

  case 336: /* BASIC_STATEMENT: _SYMB_117 _SYMB_78 _SYMB_16  */
#line 1068 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementOff(); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6120 "Parser.c"
    break;

  case 337: /* BASIC_STATEMENT: PERCENT_MACRO_NAME _SYMB_16  */
#line 1069 "HAL_S.y"
                                { (yyval.basic_statement_) = make_BKbasicStatementPercentMacro((yyvsp[-1].percent_macro_name_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6126 "Parser.c"
    break;

  case 338: /* BASIC_STATEMENT: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_7 _SYMB_16  */
#line 1070 "HAL_S.y"
                                                          { (yyval.basic_statement_) = make_BLbasicStatementPercentMacro((yyvsp[-3].percent_macro_head_), (yyvsp[-2].percent_macro_arg_)); (yyval.basic_statement_)->line_number = (yyloc).first_line; (yyval.basic_statement_)->char_number = (yyloc).first_column;  }
#line 6132 "Parser.c"
    break;

  case 339: /* OTHER_STATEMENT: IF_STATEMENT  */
#line 1072 "HAL_S.y"
                               { (yyval.other_statement_) = make_ABotherStatementIf((yyvsp[0].if_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6138 "Parser.c"
    break;

  case 340: /* OTHER_STATEMENT: ON_PHRASE STATEMENT  */
#line 1073 "HAL_S.y"
                        { (yyval.other_statement_) = make_AAotherStatementOn((yyvsp[-1].on_phrase_), (yyvsp[0].statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6144 "Parser.c"
    break;

  case 341: /* OTHER_STATEMENT: LABEL_DEFINITION OTHER_STATEMENT  */
#line 1074 "HAL_S.y"
                                     { (yyval.other_statement_) = make_ACother_statement((yyvsp[-1].label_definition_), (yyvsp[0].other_statement_)); (yyval.other_statement_)->line_number = (yyloc).first_line; (yyval.other_statement_)->char_number = (yyloc).first_column;  }
#line 6150 "Parser.c"
    break;

  case 342: /* ANY_STATEMENT: STATEMENT  */
#line 1076 "HAL_S.y"
                          { (yyval.any_statement_) = make_AAany_statement((yyvsp[0].statement_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6156 "Parser.c"
    break;

  case 343: /* ANY_STATEMENT: BLOCK_DEFINITION  */
#line 1077 "HAL_S.y"
                     { (yyval.any_statement_) = make_ABany_statement((yyvsp[0].block_definition_)); (yyval.any_statement_)->line_number = (yyloc).first_line; (yyval.any_statement_)->char_number = (yyloc).first_column;  }
#line 6162 "Parser.c"
    break;

  case 344: /* ON_PHRASE: _SYMB_118 _SYMB_78 SUBSCRIPT  */
#line 1079 "HAL_S.y"
                                         { (yyval.on_phrase_) = make_AAon_phrase((yyvsp[0].subscript_)); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6168 "Parser.c"
    break;

  case 345: /* ON_PHRASE: _SYMB_118 _SYMB_78  */
#line 1080 "HAL_S.y"
                       { (yyval.on_phrase_) = make_ACon_phrase(); (yyval.on_phrase_)->line_number = (yyloc).first_line; (yyval.on_phrase_)->char_number = (yyloc).first_column;  }
#line 6174 "Parser.c"
    break;

  case 346: /* ON_CLAUSE: _SYMB_118 _SYMB_78 SUBSCRIPT _SYMB_159  */
#line 1082 "HAL_S.y"
                                                   { (yyval.on_clause_) = make_AAon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6180 "Parser.c"
    break;

  case 347: /* ON_CLAUSE: _SYMB_118 _SYMB_78 SUBSCRIPT _SYMB_93  */
#line 1083 "HAL_S.y"
                                          { (yyval.on_clause_) = make_ABon_clause((yyvsp[-1].subscript_)); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6186 "Parser.c"
    break;

  case 348: /* ON_CLAUSE: _SYMB_118 _SYMB_78 _SYMB_159  */
#line 1084 "HAL_S.y"
                                 { (yyval.on_clause_) = make_ADon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6192 "Parser.c"
    break;

  case 349: /* ON_CLAUSE: _SYMB_118 _SYMB_78 _SYMB_93  */
#line 1085 "HAL_S.y"
                                { (yyval.on_clause_) = make_AEon_clause(); (yyval.on_clause_)->line_number = (yyloc).first_line; (yyval.on_clause_)->char_number = (yyloc).first_column;  }
#line 6198 "Parser.c"
    break;

  case 350: /* LABEL_DEFINITION: LABEL _SYMB_17  */
#line 1087 "HAL_S.y"
                                  { (yyval.label_definition_) = make_AAlabel_definition((yyvsp[-1].label_)); (yyval.label_definition_)->line_number = (yyloc).first_line; (yyval.label_definition_)->char_number = (yyloc).first_column;  }
#line 6204 "Parser.c"
    break;

  case 351: /* CALL_KEY: _SYMB_51 LABEL_VAR  */
#line 1089 "HAL_S.y"
                              { (yyval.call_key_) = make_AAcall_key((yyvsp[0].label_var_)); (yyval.call_key_)->line_number = (yyloc).first_line; (yyval.call_key_)->char_number = (yyloc).first_column;  }
#line 6210 "Parser.c"
    break;

  case 352: /* ASSIGN: _SYMB_44  */
#line 1091 "HAL_S.y"
                  { (yyval.assign_) = make_AAassign(); (yyval.assign_)->line_number = (yyloc).first_line; (yyval.assign_)->char_number = (yyloc).first_column;  }
#line 6216 "Parser.c"
    break;

  case 353: /* CALL_ASSIGN_LIST: VARIABLE  */
#line 1093 "HAL_S.y"
                            { (yyval.call_assign_list_) = make_AAcall_assign_list((yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6222 "Parser.c"
    break;

  case 354: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_8 VARIABLE  */
#line 1094 "HAL_S.y"
                                      { (yyval.call_assign_list_) = make_ABcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].variable_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6228 "Parser.c"
    break;

  case 355: /* CALL_ASSIGN_LIST: QUAL_STRUCT  */
#line 1095 "HAL_S.y"
                { (yyval.call_assign_list_) = make_ACcall_assign_list((yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6234 "Parser.c"
    break;

  case 356: /* CALL_ASSIGN_LIST: CALL_ASSIGN_LIST _SYMB_8 QUAL_STRUCT  */
#line 1096 "HAL_S.y"
                                         { (yyval.call_assign_list_) = make_ADcall_assign_list((yyvsp[-2].call_assign_list_), (yyvsp[0].qual_struct_)); (yyval.call_assign_list_)->line_number = (yyloc).first_line; (yyval.call_assign_list_)->char_number = (yyloc).first_column;  }
#line 6240 "Parser.c"
    break;

  case 357: /* DO_GROUP_HEAD: _SYMB_72 _SYMB_16  */
#line 1098 "HAL_S.y"
                                  { (yyval.do_group_head_) = make_AAdoGroupHead(); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6246 "Parser.c"
    break;

  case 358: /* DO_GROUP_HEAD: _SYMB_72 FOR_LIST _SYMB_16  */
#line 1099 "HAL_S.y"
                               { (yyval.do_group_head_) = make_ABdoGroupHeadFor((yyvsp[-1].for_list_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6252 "Parser.c"
    break;

  case 359: /* DO_GROUP_HEAD: _SYMB_72 FOR_LIST WHILE_CLAUSE _SYMB_16  */
#line 1100 "HAL_S.y"
                                            { (yyval.do_group_head_) = make_ACdoGroupHeadForWhile((yyvsp[-2].for_list_), (yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6258 "Parser.c"
    break;

  case 360: /* DO_GROUP_HEAD: _SYMB_72 WHILE_CLAUSE _SYMB_16  */
#line 1101 "HAL_S.y"
                                   { (yyval.do_group_head_) = make_ADdoGroupHeadWhile((yyvsp[-1].while_clause_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6264 "Parser.c"
    break;

  case 361: /* DO_GROUP_HEAD: _SYMB_72 _SYMB_53 ARITH_EXP _SYMB_16  */
#line 1102 "HAL_S.y"
                                         { (yyval.do_group_head_) = make_AEdoGroupHeadCase((yyvsp[-1].arith_exp_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6270 "Parser.c"
    break;

  case 362: /* DO_GROUP_HEAD: CASE_ELSE STATEMENT  */
#line 1103 "HAL_S.y"
                        { (yyval.do_group_head_) = make_AFdoGroupHeadCaseElse((yyvsp[-1].case_else_), (yyvsp[0].statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6276 "Parser.c"
    break;

  case 363: /* DO_GROUP_HEAD: DO_GROUP_HEAD ANY_STATEMENT  */
#line 1104 "HAL_S.y"
                                { (yyval.do_group_head_) = make_AGdoGroupHeadStatement((yyvsp[-1].do_group_head_), (yyvsp[0].any_statement_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6282 "Parser.c"
    break;

  case 364: /* DO_GROUP_HEAD: DO_GROUP_HEAD TEMPORARY_STMT  */
#line 1105 "HAL_S.y"
                                 { (yyval.do_group_head_) = make_AHdoGroupHeadTemporaryStatement((yyvsp[-1].do_group_head_), (yyvsp[0].temporary_stmt_)); (yyval.do_group_head_)->line_number = (yyloc).first_line; (yyval.do_group_head_)->char_number = (yyloc).first_column;  }
#line 6288 "Parser.c"
    break;

  case 365: /* ENDING: _SYMB_75  */
#line 1107 "HAL_S.y"
                  { (yyval.ending_) = make_AAending(); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6294 "Parser.c"
    break;

  case 366: /* ENDING: _SYMB_75 LABEL  */
#line 1108 "HAL_S.y"
                   { (yyval.ending_) = make_ABending((yyvsp[0].label_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6300 "Parser.c"
    break;

  case 367: /* ENDING: LABEL_DEFINITION ENDING  */
#line 1109 "HAL_S.y"
                            { (yyval.ending_) = make_ACending((yyvsp[-1].label_definition_), (yyvsp[0].ending_)); (yyval.ending_)->line_number = (yyloc).first_line; (yyval.ending_)->char_number = (yyloc).first_column;  }
#line 6306 "Parser.c"
    break;

  case 368: /* READ_KEY: _SYMB_127 _SYMB_6 NUMBER _SYMB_7  */
#line 1111 "HAL_S.y"
                                            { (yyval.read_key_) = make_AAread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 6312 "Parser.c"
    break;

  case 369: /* READ_KEY: _SYMB_128 _SYMB_6 NUMBER _SYMB_7  */
#line 1112 "HAL_S.y"
                                     { (yyval.read_key_) = make_ABread_key((yyvsp[-1].number_)); (yyval.read_key_)->line_number = (yyloc).first_line; (yyval.read_key_)->char_number = (yyloc).first_column;  }
#line 6318 "Parser.c"
    break;

  case 370: /* WRITE_KEY: _SYMB_179 _SYMB_6 NUMBER _SYMB_7  */
#line 1114 "HAL_S.y"
                                             { (yyval.write_key_) = make_AAwrite_key((yyvsp[-1].number_)); (yyval.write_key_)->line_number = (yyloc).first_line; (yyval.write_key_)->char_number = (yyloc).first_column;  }
#line 6324 "Parser.c"
    break;

  case 371: /* READ_PHRASE: READ_KEY READ_ARG  */
#line 1116 "HAL_S.y"
                                { (yyval.read_phrase_) = make_AAread_phrase((yyvsp[-1].read_key_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 6330 "Parser.c"
    break;

  case 372: /* READ_PHRASE: READ_PHRASE _SYMB_8 READ_ARG  */
#line 1117 "HAL_S.y"
                                 { (yyval.read_phrase_) = make_ABread_phrase((yyvsp[-2].read_phrase_), (yyvsp[0].read_arg_)); (yyval.read_phrase_)->line_number = (yyloc).first_line; (yyval.read_phrase_)->char_number = (yyloc).first_column;  }
#line 6336 "Parser.c"
    break;

  case 373: /* WRITE_PHRASE: WRITE_KEY WRITE_ARG  */
#line 1119 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_AAwrite_phrase((yyvsp[-1].write_key_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 6342 "Parser.c"
    break;

  case 374: /* WRITE_PHRASE: WRITE_PHRASE _SYMB_8 WRITE_ARG  */
#line 1120 "HAL_S.y"
                                   { (yyval.write_phrase_) = make_ABwrite_phrase((yyvsp[-2].write_phrase_), (yyvsp[0].write_arg_)); (yyval.write_phrase_)->line_number = (yyloc).first_line; (yyval.write_phrase_)->char_number = (yyloc).first_column;  }
#line 6348 "Parser.c"
    break;

  case 375: /* READ_ARG: VARIABLE  */
#line 1122 "HAL_S.y"
                    { (yyval.read_arg_) = make_AAread_arg((yyvsp[0].variable_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 6354 "Parser.c"
    break;

  case 376: /* READ_ARG: IO_CONTROL  */
#line 1123 "HAL_S.y"
               { (yyval.read_arg_) = make_ABread_arg((yyvsp[0].io_control_)); (yyval.read_arg_)->line_number = (yyloc).first_line; (yyval.read_arg_)->char_number = (yyloc).first_column;  }
#line 6360 "Parser.c"
    break;

  case 377: /* WRITE_ARG: EXPRESSION  */
#line 1125 "HAL_S.y"
                       { (yyval.write_arg_) = make_AAwrite_arg((yyvsp[0].expression_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6366 "Parser.c"
    break;

  case 378: /* WRITE_ARG: IO_CONTROL  */
#line 1126 "HAL_S.y"
               { (yyval.write_arg_) = make_ABwrite_arg((yyvsp[0].io_control_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6372 "Parser.c"
    break;

  case 379: /* WRITE_ARG: _SYMB_185  */
#line 1127 "HAL_S.y"
              { (yyval.write_arg_) = make_ACwrite_arg((yyvsp[0].string_)); (yyval.write_arg_)->line_number = (yyloc).first_line; (yyval.write_arg_)->char_number = (yyloc).first_column;  }
#line 6378 "Parser.c"
    break;

  case 380: /* FILE_EXP: FILE_HEAD _SYMB_8 ARITH_EXP _SYMB_7  */
#line 1129 "HAL_S.y"
                                               { (yyval.file_exp_) = make_AAfile_exp((yyvsp[-3].file_head_), (yyvsp[-1].arith_exp_)); (yyval.file_exp_)->line_number = (yyloc).first_line; (yyval.file_exp_)->char_number = (yyloc).first_column;  }
#line 6384 "Parser.c"
    break;

  case 381: /* FILE_HEAD: _SYMB_86 _SYMB_6 NUMBER  */
#line 1131 "HAL_S.y"
                                    { (yyval.file_head_) = make_AAfile_head((yyvsp[0].number_)); (yyval.file_head_)->line_number = (yyloc).first_line; (yyval.file_head_)->char_number = (yyloc).first_column;  }
#line 6390 "Parser.c"
    break;

  case 382: /* IO_CONTROL: _SYMB_153 _SYMB_6 ARITH_EXP _SYMB_7  */
#line 1133 "HAL_S.y"
                                                 { (yyval.io_control_) = make_AAioControlSkip((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6396 "Parser.c"
    break;

  case 383: /* IO_CONTROL: _SYMB_160 _SYMB_6 ARITH_EXP _SYMB_7  */
#line 1134 "HAL_S.y"
                                        { (yyval.io_control_) = make_ABioControlTab((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6402 "Parser.c"
    break;

  case 384: /* IO_CONTROL: _SYMB_60 _SYMB_6 ARITH_EXP _SYMB_7  */
#line 1135 "HAL_S.y"
                                       { (yyval.io_control_) = make_ACioControlColumn((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6408 "Parser.c"
    break;

  case 385: /* IO_CONTROL: _SYMB_101 _SYMB_6 ARITH_EXP _SYMB_7  */
#line 1136 "HAL_S.y"
                                        { (yyval.io_control_) = make_ADioControlLine((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6414 "Parser.c"
    break;

  case 386: /* IO_CONTROL: _SYMB_120 _SYMB_6 ARITH_EXP _SYMB_7  */
#line 1137 "HAL_S.y"
                                        { (yyval.io_control_) = make_AEioControlPage((yyvsp[-1].arith_exp_)); (yyval.io_control_)->line_number = (yyloc).first_line; (yyval.io_control_)->char_number = (yyloc).first_column;  }
#line 6420 "Parser.c"
    break;

  case 387: /* WAIT_KEY: _SYMB_177  */
#line 1139 "HAL_S.y"
                     { (yyval.wait_key_) = make_AAwait_key(); (yyval.wait_key_)->line_number = (yyloc).first_line; (yyval.wait_key_)->char_number = (yyloc).first_column;  }
#line 6426 "Parser.c"
    break;

  case 388: /* TERMINATOR: _SYMB_165  */
#line 1141 "HAL_S.y"
                       { (yyval.terminator_) = make_AAterminatorTerminate(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 6432 "Parser.c"
    break;

  case 389: /* TERMINATOR: _SYMB_52  */
#line 1142 "HAL_S.y"
             { (yyval.terminator_) = make_ABterminatorCancel(); (yyval.terminator_)->line_number = (yyloc).first_line; (yyval.terminator_)->char_number = (yyloc).first_column;  }
#line 6438 "Parser.c"
    break;

  case 390: /* TERMINATE_LIST: LABEL_VAR  */
#line 1144 "HAL_S.y"
                           { (yyval.terminate_list_) = make_AAterminate_list((yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 6444 "Parser.c"
    break;

  case 391: /* TERMINATE_LIST: TERMINATE_LIST _SYMB_8 LABEL_VAR  */
#line 1145 "HAL_S.y"
                                     { (yyval.terminate_list_) = make_ABterminate_list((yyvsp[-2].terminate_list_), (yyvsp[0].label_var_)); (yyval.terminate_list_)->line_number = (yyloc).first_line; (yyval.terminate_list_)->char_number = (yyloc).first_column;  }
#line 6450 "Parser.c"
    break;

  case 392: /* SCHEDULE_HEAD: _SYMB_141 LABEL_VAR  */
#line 1147 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_AAscheduleHeadLabel((yyvsp[0].label_var_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6456 "Parser.c"
    break;

  case 393: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_45 ARITH_EXP  */
#line 1148 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ABscheduleHeadAt((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6462 "Parser.c"
    break;

  case 394: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_94 ARITH_EXP  */
#line 1149 "HAL_S.y"
                                     { (yyval.schedule_head_) = make_ACscheduleHeadIn((yyvsp[-2].schedule_head_), (yyvsp[0].arith_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6468 "Parser.c"
    break;

  case 395: /* SCHEDULE_HEAD: SCHEDULE_HEAD _SYMB_118 BIT_EXP  */
#line 1150 "HAL_S.y"
                                    { (yyval.schedule_head_) = make_ADscheduleHeadOn((yyvsp[-2].schedule_head_), (yyvsp[0].bit_exp_)); (yyval.schedule_head_)->line_number = (yyloc).first_line; (yyval.schedule_head_)->char_number = (yyloc).first_column;  }
#line 6474 "Parser.c"
    break;

  case 396: /* SCHEDULE_PHRASE: SCHEDULE_HEAD  */
#line 1152 "HAL_S.y"
                                { (yyval.schedule_phrase_) = make_AAschedule_phrase((yyvsp[0].schedule_head_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6480 "Parser.c"
    break;

  case 397: /* SCHEDULE_PHRASE: SCHEDULE_HEAD _SYMB_122 _SYMB_6 ARITH_EXP _SYMB_7  */
#line 1153 "HAL_S.y"
                                                      { (yyval.schedule_phrase_) = make_ABschedule_phrase((yyvsp[-4].schedule_head_), (yyvsp[-1].arith_exp_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6486 "Parser.c"
    break;

  case 398: /* SCHEDULE_PHRASE: SCHEDULE_PHRASE _SYMB_69  */
#line 1154 "HAL_S.y"
                             { (yyval.schedule_phrase_) = make_ACschedule_phrase((yyvsp[-1].schedule_phrase_)); (yyval.schedule_phrase_)->line_number = (yyloc).first_line; (yyval.schedule_phrase_)->char_number = (yyloc).first_column;  }
#line 6492 "Parser.c"
    break;

  case 399: /* SCHEDULE_CONTROL: STOPPING  */
#line 1156 "HAL_S.y"
                            { (yyval.schedule_control_) = make_AAschedule_control((yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6498 "Parser.c"
    break;

  case 400: /* SCHEDULE_CONTROL: TIMING  */
#line 1157 "HAL_S.y"
           { (yyval.schedule_control_) = make_ABschedule_control((yyvsp[0].timing_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6504 "Parser.c"
    break;

  case 401: /* SCHEDULE_CONTROL: TIMING STOPPING  */
#line 1158 "HAL_S.y"
                    { (yyval.schedule_control_) = make_ACschedule_control((yyvsp[-1].timing_), (yyvsp[0].stopping_)); (yyval.schedule_control_)->line_number = (yyloc).first_line; (yyval.schedule_control_)->char_number = (yyloc).first_column;  }
#line 6510 "Parser.c"
    break;

  case 402: /* TIMING: REPEAT _SYMB_80 ARITH_EXP  */
#line 1160 "HAL_S.y"
                                   { (yyval.timing_) = make_AAtimingEvery((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6516 "Parser.c"
    break;

  case 403: /* TIMING: REPEAT _SYMB_33 ARITH_EXP  */
#line 1161 "HAL_S.y"
                              { (yyval.timing_) = make_ABtimingAfter((yyvsp[-2].repeat_), (yyvsp[0].arith_exp_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6522 "Parser.c"
    break;

  case 404: /* TIMING: REPEAT  */
#line 1162 "HAL_S.y"
           { (yyval.timing_) = make_ACtiming((yyvsp[0].repeat_)); (yyval.timing_)->line_number = (yyloc).first_line; (yyval.timing_)->char_number = (yyloc).first_column;  }
#line 6528 "Parser.c"
    break;

  case 405: /* REPEAT: _SYMB_8 _SYMB_132  */
#line 1164 "HAL_S.y"
                           { (yyval.repeat_) = make_AArepeat(); (yyval.repeat_)->line_number = (yyloc).first_line; (yyval.repeat_)->char_number = (yyloc).first_column;  }
#line 6534 "Parser.c"
    break;

  case 406: /* STOPPING: WHILE_KEY ARITH_EXP  */
#line 1166 "HAL_S.y"
                               { (yyval.stopping_) = make_AAstopping((yyvsp[-1].while_key_), (yyvsp[0].arith_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 6540 "Parser.c"
    break;

  case 407: /* STOPPING: WHILE_KEY BIT_EXP  */
#line 1167 "HAL_S.y"
                      { (yyval.stopping_) = make_ABstopping((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.stopping_)->line_number = (yyloc).first_line; (yyval.stopping_)->char_number = (yyloc).first_column;  }
#line 6546 "Parser.c"
    break;

  case 408: /* SIGNAL_CLAUSE: _SYMB_143 EVENT_VAR  */
#line 1169 "HAL_S.y"
                                    { (yyval.signal_clause_) = make_AAsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6552 "Parser.c"
    break;

  case 409: /* SIGNAL_CLAUSE: _SYMB_134 EVENT_VAR  */
#line 1170 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ABsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6558 "Parser.c"
    break;

  case 410: /* SIGNAL_CLAUSE: _SYMB_147 EVENT_VAR  */
#line 1171 "HAL_S.y"
                        { (yyval.signal_clause_) = make_ACsignal_clause((yyvsp[0].event_var_)); (yyval.signal_clause_)->line_number = (yyloc).first_line; (yyval.signal_clause_)->char_number = (yyloc).first_column;  }
#line 6564 "Parser.c"
    break;

  case 411: /* PERCENT_MACRO_NAME: _SYMB_29 IDENTIFIER  */
#line 1173 "HAL_S.y"
                                         { (yyval.percent_macro_name_) = make_FNpercent_macro_name((yyvsp[0].identifier_)); (yyval.percent_macro_name_)->line_number = (yyloc).first_line; (yyval.percent_macro_name_)->char_number = (yyloc).first_column;  }
#line 6570 "Parser.c"
    break;

  case 412: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_NAME _SYMB_6  */
#line 1175 "HAL_S.y"
                                                { (yyval.percent_macro_head_) = make_AApercent_macro_head((yyvsp[-1].percent_macro_name_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 6576 "Parser.c"
    break;

  case 413: /* PERCENT_MACRO_HEAD: PERCENT_MACRO_HEAD PERCENT_MACRO_ARG _SYMB_8  */
#line 1176 "HAL_S.y"
                                                 { (yyval.percent_macro_head_) = make_ABpercent_macro_head((yyvsp[-2].percent_macro_head_), (yyvsp[-1].percent_macro_arg_)); (yyval.percent_macro_head_)->line_number = (yyloc).first_line; (yyval.percent_macro_head_)->char_number = (yyloc).first_column;  }
#line 6582 "Parser.c"
    break;

  case 414: /* PERCENT_MACRO_ARG: NAME_VAR  */
#line 1178 "HAL_S.y"
                             { (yyval.percent_macro_arg_) = make_AApercent_macro_arg((yyvsp[0].name_var_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 6588 "Parser.c"
    break;

  case 415: /* PERCENT_MACRO_ARG: CONSTANT  */
#line 1179 "HAL_S.y"
             { (yyval.percent_macro_arg_) = make_ABpercent_macro_arg((yyvsp[0].constant_)); (yyval.percent_macro_arg_)->line_number = (yyloc).first_line; (yyval.percent_macro_arg_)->char_number = (yyloc).first_column;  }
#line 6594 "Parser.c"
    break;

  case 416: /* CASE_ELSE: _SYMB_72 _SYMB_53 ARITH_EXP _SYMB_16 _SYMB_74  */
#line 1181 "HAL_S.y"
                                                          { (yyval.case_else_) = make_AAcase_else((yyvsp[-2].arith_exp_)); (yyval.case_else_)->line_number = (yyloc).first_line; (yyval.case_else_)->char_number = (yyloc).first_column;  }
#line 6600 "Parser.c"
    break;

  case 417: /* WHILE_KEY: _SYMB_178  */
#line 1183 "HAL_S.y"
                      { (yyval.while_key_) = make_AAwhileKeyWhile(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 6606 "Parser.c"
    break;

  case 418: /* WHILE_KEY: _SYMB_174  */
#line 1184 "HAL_S.y"
              { (yyval.while_key_) = make_ABwhileKeyUntil(); (yyval.while_key_)->line_number = (yyloc).first_line; (yyval.while_key_)->char_number = (yyloc).first_column;  }
#line 6612 "Parser.c"
    break;

  case 419: /* WHILE_CLAUSE: WHILE_KEY BIT_EXP  */
#line 1186 "HAL_S.y"
                                 { (yyval.while_clause_) = make_AAwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].bit_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 6618 "Parser.c"
    break;

  case 420: /* WHILE_CLAUSE: WHILE_KEY RELATIONAL_EXP  */
#line 1187 "HAL_S.y"
                             { (yyval.while_clause_) = make_ABwhile_clause((yyvsp[-1].while_key_), (yyvsp[0].relational_exp_)); (yyval.while_clause_)->line_number = (yyloc).first_line; (yyval.while_clause_)->char_number = (yyloc).first_column;  }
#line 6624 "Parser.c"
    break;

  case 421: /* FOR_LIST: FOR_KEY ARITH_EXP ITERATION_CONTROL  */
#line 1189 "HAL_S.y"
                                               { (yyval.for_list_) = make_AAfor_list((yyvsp[-2].for_key_), (yyvsp[-1].arith_exp_), (yyvsp[0].iteration_control_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 6630 "Parser.c"
    break;

  case 422: /* FOR_LIST: FOR_KEY ITERATION_BODY  */
#line 1190 "HAL_S.y"
                           { (yyval.for_list_) = make_ABfor_list((yyvsp[-1].for_key_), (yyvsp[0].iteration_body_)); (yyval.for_list_)->line_number = (yyloc).first_line; (yyval.for_list_)->char_number = (yyloc).first_column;  }
#line 6636 "Parser.c"
    break;

  case 423: /* ITERATION_BODY: ARITH_EXP  */
#line 1192 "HAL_S.y"
                           { (yyval.iteration_body_) = make_AAiteration_body((yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 6642 "Parser.c"
    break;

  case 424: /* ITERATION_BODY: ITERATION_BODY _SYMB_8 ARITH_EXP  */
#line 1193 "HAL_S.y"
                                     { (yyval.iteration_body_) = make_ABiteration_body((yyvsp[-2].iteration_body_), (yyvsp[0].arith_exp_)); (yyval.iteration_body_)->line_number = (yyloc).first_line; (yyval.iteration_body_)->char_number = (yyloc).first_column;  }
#line 6648 "Parser.c"
    break;

  case 425: /* ITERATION_CONTROL: _SYMB_167 ARITH_EXP  */
#line 1195 "HAL_S.y"
                                        { (yyval.iteration_control_) = make_AAiteration_controlTo((yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 6654 "Parser.c"
    break;

  case 426: /* ITERATION_CONTROL: _SYMB_167 ARITH_EXP _SYMB_50 ARITH_EXP  */
#line 1196 "HAL_S.y"
                                           { (yyval.iteration_control_) = make_ABiteration_controlToBy((yyvsp[-2].arith_exp_), (yyvsp[0].arith_exp_)); (yyval.iteration_control_)->line_number = (yyloc).first_line; (yyval.iteration_control_)->char_number = (yyloc).first_column;  }
#line 6660 "Parser.c"
    break;

  case 427: /* FOR_KEY: _SYMB_88 ARITH_VAR EQUALS  */
#line 1198 "HAL_S.y"
                                    { (yyval.for_key_) = make_AAforKey((yyvsp[-1].arith_var_), (yyvsp[0].equals_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 6666 "Parser.c"
    break;

  case 428: /* FOR_KEY: _SYMB_88 _SYMB_164 IDENTIFIER _SYMB_25  */
#line 1199 "HAL_S.y"
                                           { (yyval.for_key_) = make_ABforKeyTemporary((yyvsp[-1].identifier_)); (yyval.for_key_)->line_number = (yyloc).first_line; (yyval.for_key_)->char_number = (yyloc).first_column;  }
#line 6672 "Parser.c"
    break;

  case 429: /* TEMPORARY_STMT: _SYMB_164 DECLARE_BODY _SYMB_16  */
#line 1201 "HAL_S.y"
                                                 { (yyval.temporary_stmt_) = make_AAtemporary_stmt((yyvsp[-1].declare_body_)); (yyval.temporary_stmt_)->line_number = (yyloc).first_line; (yyval.temporary_stmt_)->char_number = (yyloc).first_column;  }
#line 6678 "Parser.c"
    break;

  case 430: /* DECLARE_BODY: DECLARATION_LIST  */
#line 1203 "HAL_S.y"
                                { (yyval.declare_body_) = make_AAdeclare_body((yyvsp[0].declaration_list_)); (yyval.declare_body_)->line_number = (yyloc).first_line; (yyval.declare_body_)->char_number = (yyloc).first_column;  }
#line 6684 "Parser.c"
    break;

  case 431: /* DECLARE_BODY: ATTRIBUTES _SYMB_8 DECLARATION_LIST  */
#line 1204 "HAL_S.y"
                                        { (yyval.declare_body_) = make_ABdeclare_body((yyvsp[-2].attributes_), (yyvsp[0].declaration_list_)); (yyval.declare_body_)->line_number = (yyloc).first_line; (yyval.declare_body_)->char_number = (yyloc).first_column;  }
#line 6690 "Parser.c"
    break;

  case 432: /* DECLARATION_LIST: DECLARATION  */
#line 1206 "HAL_S.y"
                               { (yyval.declaration_list_) = make_AAdeclaration_list((yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 6696 "Parser.c"
    break;

  case 433: /* DECLARATION_LIST: DCL_LIST_COMMA DECLARATION  */
#line 1207 "HAL_S.y"
                               { (yyval.declaration_list_) = make_ABdeclaration_list((yyvsp[-1].dcl_list_comma_), (yyvsp[0].declaration_)); (yyval.declaration_list_)->line_number = (yyloc).first_line; (yyval.declaration_list_)->char_number = (yyloc).first_column;  }
#line 6702 "Parser.c"
    break;

  case 434: /* CONSTANT: NUMBER  */
#line 1209 "HAL_S.y"
                  { (yyval.constant_) = make_AAconstant((yyvsp[0].number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6708 "Parser.c"
    break;

  case 435: /* CONSTANT: COMPOUND_NUMBER  */
#line 1210 "HAL_S.y"
                    { (yyval.constant_) = make_ABconstant((yyvsp[0].compound_number_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6714 "Parser.c"
    break;

  case 436: /* CONSTANT: BIT_CONST  */
#line 1211 "HAL_S.y"
              { (yyval.constant_) = make_ACconstant((yyvsp[0].bit_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6720 "Parser.c"
    break;

  case 437: /* CONSTANT: CHAR_CONST  */
#line 1212 "HAL_S.y"
               { (yyval.constant_) = make_ADconstant((yyvsp[0].char_const_)); (yyval.constant_)->line_number = (yyloc).first_line; (yyval.constant_)->char_number = (yyloc).first_column;  }
#line 6726 "Parser.c"
    break;

  case 438: /* ATTRIBUTES: ARRAY_SPEC TYPE_AND_MINOR_ATTR  */
#line 1214 "HAL_S.y"
                                            { (yyval.attributes_) = make_AAattributes((yyvsp[-1].array_spec_), (yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 6732 "Parser.c"
    break;

  case 439: /* ATTRIBUTES: ARRAY_SPEC  */
#line 1215 "HAL_S.y"
               { (yyval.attributes_) = make_ABattributes((yyvsp[0].array_spec_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 6738 "Parser.c"
    break;

  case 440: /* ATTRIBUTES: TYPE_AND_MINOR_ATTR  */
#line 1216 "HAL_S.y"
                        { (yyval.attributes_) = make_ACattributes((yyvsp[0].type_and_minor_attr_)); (yyval.attributes_)->line_number = (yyloc).first_line; (yyval.attributes_)->char_number = (yyloc).first_column;  }
#line 6744 "Parser.c"
    break;

  case 441: /* ARRAY_SPEC: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_7  */
#line 1218 "HAL_S.y"
                                                    { (yyval.array_spec_) = make_AAarray_spec((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 6750 "Parser.c"
    break;

  case 442: /* ARRAY_SPEC: _SYMB_89  */
#line 1219 "HAL_S.y"
             { (yyval.array_spec_) = make_ABarraySpecFunction(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 6756 "Parser.c"
    break;

  case 443: /* ARRAY_SPEC: _SYMB_123  */
#line 1220 "HAL_S.y"
              { (yyval.array_spec_) = make_ACarraySpecProcedure(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 6762 "Parser.c"
    break;

  case 444: /* ARRAY_SPEC: _SYMB_125  */
#line 1221 "HAL_S.y"
              { (yyval.array_spec_) = make_ADarraySpecProgram(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 6768 "Parser.c"
    break;

  case 445: /* ARRAY_SPEC: _SYMB_163  */
#line 1222 "HAL_S.y"
              { (yyval.array_spec_) = make_AEarraySpecTask(); (yyval.array_spec_)->line_number = (yyloc).first_line; (yyval.array_spec_)->char_number = (yyloc).first_column;  }
#line 6774 "Parser.c"
    break;

  case 446: /* ARRAY_HEAD: _SYMB_43 _SYMB_6  */
#line 1224 "HAL_S.y"
                              { (yyval.array_head_) = make_AAarray_head(); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 6780 "Parser.c"
    break;

  case 447: /* ARRAY_HEAD: ARRAY_HEAD LITERAL_EXP_OR_STAR _SYMB_8  */
#line 1225 "HAL_S.y"
                                           { (yyval.array_head_) = make_ABarray_head((yyvsp[-2].array_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.array_head_)->line_number = (yyloc).first_line; (yyval.array_head_)->char_number = (yyloc).first_column;  }
#line 6786 "Parser.c"
    break;

  case 448: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC  */
#line 1227 "HAL_S.y"
                                { (yyval.type_and_minor_attr_) = make_AAtype_and_minor_attr((yyvsp[0].type_spec_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 6792 "Parser.c"
    break;

  case 449: /* TYPE_AND_MINOR_ATTR: TYPE_SPEC MINOR_ATTR_LIST  */
#line 1228 "HAL_S.y"
                              { (yyval.type_and_minor_attr_) = make_ABtype_and_minor_attr((yyvsp[-1].type_spec_), (yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 6798 "Parser.c"
    break;

  case 450: /* TYPE_AND_MINOR_ATTR: MINOR_ATTR_LIST  */
#line 1229 "HAL_S.y"
                    { (yyval.type_and_minor_attr_) = make_ACtype_and_minor_attr((yyvsp[0].minor_attr_list_)); (yyval.type_and_minor_attr_)->line_number = (yyloc).first_line; (yyval.type_and_minor_attr_)->char_number = (yyloc).first_column;  }
#line 6804 "Parser.c"
    break;

  case 451: /* MINOR_ATTR_LIST: MINOR_ATTRIBUTE  */
#line 1231 "HAL_S.y"
                                  { (yyval.minor_attr_list_) = make_AAminor_attr_list((yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 6810 "Parser.c"
    break;

  case 452: /* MINOR_ATTR_LIST: MINOR_ATTR_LIST MINOR_ATTRIBUTE  */
#line 1232 "HAL_S.y"
                                    { (yyval.minor_attr_list_) = make_ABminor_attr_list((yyvsp[-1].minor_attr_list_), (yyvsp[0].minor_attribute_)); (yyval.minor_attr_list_)->line_number = (yyloc).first_line; (yyval.minor_attr_list_)->char_number = (yyloc).first_column;  }
#line 6816 "Parser.c"
    break;

  case 453: /* MINOR_ATTRIBUTE: _SYMB_155  */
#line 1234 "HAL_S.y"
                            { (yyval.minor_attribute_) = make_AAminorAttributeStatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 6822 "Parser.c"
    break;

  case 454: /* MINOR_ATTRIBUTE: _SYMB_46  */
#line 1235 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ABminorAttributeAutomatic(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 6828 "Parser.c"
    break;

  case 455: /* MINOR_ATTRIBUTE: _SYMB_68  */
#line 1236 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ACminorAttributeDense(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 6834 "Parser.c"
    break;

  case 456: /* MINOR_ATTRIBUTE: _SYMB_34  */
#line 1237 "HAL_S.y"
             { (yyval.minor_attribute_) = make_ADminorAttributeAligned(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 6840 "Parser.c"
    break;

  case 457: /* MINOR_ATTRIBUTE: _SYMB_32  */
#line 1238 "HAL_S.y"
             { (yyval.minor_attribute_) = make_AEminorAttributeAccess(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 6846 "Parser.c"
    break;

  case 458: /* MINOR_ATTRIBUTE: _SYMB_103 _SYMB_6 LITERAL_EXP_OR_STAR _SYMB_7  */
#line 1239 "HAL_S.y"
                                                  { (yyval.minor_attribute_) = make_AFminorAttributeLock((yyvsp[-1].literal_exp_or_star_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 6852 "Parser.c"
    break;

  case 459: /* MINOR_ATTRIBUTE: _SYMB_131  */
#line 1240 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AGminorAttributeRemote(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 6858 "Parser.c"
    break;

  case 460: /* MINOR_ATTRIBUTE: _SYMB_136  */
#line 1241 "HAL_S.y"
              { (yyval.minor_attribute_) = make_AHminorAttributeRigid(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 6864 "Parser.c"
    break;

  case 461: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_7  */
#line 1242 "HAL_S.y"
                                                 { (yyval.minor_attribute_) = make_AIminorAttributeRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 6870 "Parser.c"
    break;

  case 462: /* MINOR_ATTRIBUTE: INIT_OR_CONST_HEAD _SYMB_3 _SYMB_7  */
#line 1243 "HAL_S.y"
                                       { (yyval.minor_attribute_) = make_AJminorAttributeStar((yyvsp[-2].init_or_const_head_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 6876 "Parser.c"
    break;

  case 463: /* MINOR_ATTRIBUTE: _SYMB_99  */
#line 1244 "HAL_S.y"
             { (yyval.minor_attribute_) = make_AKminorAttributeLatched(); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 6882 "Parser.c"
    break;

  case 464: /* MINOR_ATTRIBUTE: _SYMB_112 _SYMB_6 LEVEL _SYMB_7  */
#line 1245 "HAL_S.y"
                                    { (yyval.minor_attribute_) = make_ALminorAttributeNonHal((yyvsp[-1].level_)); (yyval.minor_attribute_)->line_number = (yyloc).first_line; (yyval.minor_attribute_)->char_number = (yyloc).first_column;  }
#line 6888 "Parser.c"
    break;

  case 465: /* INIT_OR_CONST_HEAD: _SYMB_96 _SYMB_6  */
#line 1247 "HAL_S.y"
                                      { (yyval.init_or_const_head_) = make_AAinit_or_const_headInitial(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 6894 "Parser.c"
    break;

  case 466: /* INIT_OR_CONST_HEAD: _SYMB_62 _SYMB_6  */
#line 1248 "HAL_S.y"
                     { (yyval.init_or_const_head_) = make_ABinit_or_const_headConstant(); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 6900 "Parser.c"
    break;

  case 467: /* INIT_OR_CONST_HEAD: INIT_OR_CONST_HEAD REPEATED_CONSTANT _SYMB_8  */
#line 1249 "HAL_S.y"
                                                 { (yyval.init_or_const_head_) = make_ACinit_or_const_headRepeatedConstant((yyvsp[-2].init_or_const_head_), (yyvsp[-1].repeated_constant_)); (yyval.init_or_const_head_)->line_number = (yyloc).first_line; (yyval.init_or_const_head_)->char_number = (yyloc).first_column;  }
#line 6906 "Parser.c"
    break;

  case 468: /* REPEATED_CONSTANT: EXPRESSION  */
#line 1251 "HAL_S.y"
                               { (yyval.repeated_constant_) = make_AArepeated_constant((yyvsp[0].expression_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 6912 "Parser.c"
    break;

  case 469: /* REPEATED_CONSTANT: REPEAT_HEAD VARIABLE  */
#line 1252 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ABrepeated_constant((yyvsp[-1].repeat_head_), (yyvsp[0].variable_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 6918 "Parser.c"
    break;

  case 470: /* REPEATED_CONSTANT: REPEAT_HEAD CONSTANT  */
#line 1253 "HAL_S.y"
                         { (yyval.repeated_constant_) = make_ACrepeated_constant((yyvsp[-1].repeat_head_), (yyvsp[0].constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 6924 "Parser.c"
    break;

  case 471: /* REPEATED_CONSTANT: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_7  */
#line 1254 "HAL_S.y"
                                                 { (yyval.repeated_constant_) = make_ADrepeated_constant((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 6930 "Parser.c"
    break;

  case 472: /* REPEATED_CONSTANT: REPEAT_HEAD  */
#line 1255 "HAL_S.y"
                { (yyval.repeated_constant_) = make_AErepeated_constant((yyvsp[0].repeat_head_)); (yyval.repeated_constant_)->line_number = (yyloc).first_line; (yyval.repeated_constant_)->char_number = (yyloc).first_column;  }
#line 6936 "Parser.c"
    break;

  case 473: /* REPEAT_HEAD: ARITH_EXP _SYMB_9 SIMPLE_NUMBER  */
#line 1257 "HAL_S.y"
                                              { (yyval.repeat_head_) = make_AArepeat_head((yyvsp[-2].arith_exp_), (yyvsp[0].simple_number_)); (yyval.repeat_head_)->line_number = (yyloc).first_line; (yyval.repeat_head_)->char_number = (yyloc).first_column;  }
#line 6942 "Parser.c"
    break;

  case 474: /* NESTED_REPEAT_HEAD: REPEAT_HEAD _SYMB_6  */
#line 1259 "HAL_S.y"
                                         { (yyval.nested_repeat_head_) = make_AAnested_repeat_head((yyvsp[-1].repeat_head_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 6948 "Parser.c"
    break;

  case 475: /* NESTED_REPEAT_HEAD: NESTED_REPEAT_HEAD REPEATED_CONSTANT _SYMB_8  */
#line 1260 "HAL_S.y"
                                                 { (yyval.nested_repeat_head_) = make_ABnested_repeat_head((yyvsp[-2].nested_repeat_head_), (yyvsp[-1].repeated_constant_)); (yyval.nested_repeat_head_)->line_number = (yyloc).first_line; (yyval.nested_repeat_head_)->char_number = (yyloc).first_column;  }
#line 6954 "Parser.c"
    break;

  case 476: /* DECLARATION: NAME_ID  */
#line 1262 "HAL_S.y"
                      { (yyval.declaration_) = make_AAdeclarationName((yyvsp[0].name_id_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 6960 "Parser.c"
    break;

  case 477: /* DECLARATION: NAME_ID ATTRIBUTES  */
#line 1263 "HAL_S.y"
                       { (yyval.declaration_) = make_ABdeclarationNameWithAttributes((yyvsp[-1].name_id_), (yyvsp[0].attributes_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 6966 "Parser.c"
    break;

  case 478: /* DECLARATION: _SYMB_187 _SYMB_123 MINOR_ATTR_LIST  */
#line 1264 "HAL_S.y"
                                        { (yyval.declaration_) = make_ACdeclarationProcedure((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 6972 "Parser.c"
    break;

  case 479: /* DECLARATION: _SYMB_187 _SYMB_123  */
#line 1265 "HAL_S.y"
                        { (yyval.declaration_) = make_ADdeclarationProcedure((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 6978 "Parser.c"
    break;

  case 480: /* DECLARATION: _SYMB_188 _SYMB_79  */
#line 1266 "HAL_S.y"
                       { (yyval.declaration_) = make_AEdeclarationEvent((yyvsp[-1].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 6984 "Parser.c"
    break;

  case 481: /* DECLARATION: _SYMB_188 _SYMB_79 MINOR_ATTR_LIST  */
#line 1267 "HAL_S.y"
                                       { (yyval.declaration_) = make_AFdeclarationEvent((yyvsp[-2].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 6990 "Parser.c"
    break;

  case 482: /* DECLARATION: _SYMB_188  */
#line 1268 "HAL_S.y"
              { (yyval.declaration_) = make_AGdeclarationEvent((yyvsp[0].string_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 6996 "Parser.c"
    break;

  case 483: /* DECLARATION: _SYMB_188 MINOR_ATTR_LIST  */
#line 1269 "HAL_S.y"
                              { (yyval.declaration_) = make_AHdeclarationEvent((yyvsp[-1].string_), (yyvsp[0].minor_attr_list_)); (yyval.declaration_)->line_number = (yyloc).first_line; (yyval.declaration_)->char_number = (yyloc).first_column;  }
#line 7002 "Parser.c"
    break;

  case 484: /* NAME_ID: IDENTIFIER  */
#line 1271 "HAL_S.y"
                     { (yyval.name_id_) = make_AAname_id((yyvsp[0].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 7008 "Parser.c"
    break;

  case 485: /* NAME_ID: IDENTIFIER _SYMB_110  */
#line 1272 "HAL_S.y"
                         { (yyval.name_id_) = make_ABnameIdName((yyvsp[-1].identifier_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 7014 "Parser.c"
    break;

  case 486: /* NAME_ID: BIT_ID  */
#line 1273 "HAL_S.y"
           { (yyval.name_id_) = make_ACnameIdBit((yyvsp[0].bit_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 7020 "Parser.c"
    break;

  case 487: /* NAME_ID: CHAR_ID  */
#line 1274 "HAL_S.y"
            { (yyval.name_id_) = make_ADnameIdChar((yyvsp[0].char_id_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 7026 "Parser.c"
    break;

  case 488: /* NAME_ID: _SYMB_182  */
#line 1275 "HAL_S.y"
              { (yyval.name_id_) = make_AEnameIdBitFunc((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 7032 "Parser.c"
    break;

  case 489: /* NAME_ID: _SYMB_183  */
#line 1276 "HAL_S.y"
              { (yyval.name_id_) = make_AFnameIdCharFunc((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 7038 "Parser.c"
    break;

  case 490: /* NAME_ID: _SYMB_185  */
#line 1277 "HAL_S.y"
              { (yyval.name_id_) = make_AGnameIdStruct((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 7044 "Parser.c"
    break;

  case 491: /* NAME_ID: _SYMB_186  */
#line 1278 "HAL_S.y"
              { (yyval.name_id_) = make_AHnameIdStructFunc((yyvsp[0].string_)); (yyval.name_id_)->line_number = (yyloc).first_line; (yyval.name_id_)->char_number = (yyloc).first_column;  }
#line 7050 "Parser.c"
    break;

  case 492: /* DCL_LIST_COMMA: DECLARATION_LIST _SYMB_8  */
#line 1280 "HAL_S.y"
                                          { (yyval.dcl_list_comma_) = make_AAdcl_list_comma((yyvsp[-1].declaration_list_)); (yyval.dcl_list_comma_)->line_number = (yyloc).first_line; (yyval.dcl_list_comma_)->char_number = (yyloc).first_column;  }
#line 7056 "Parser.c"
    break;

  case 493: /* LITERAL_EXP_OR_STAR: ARITH_EXP  */
#line 1282 "HAL_S.y"
                                { (yyval.literal_exp_or_star_) = make_AAliteralExp((yyvsp[0].arith_exp_)); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7062 "Parser.c"
    break;

  case 494: /* LITERAL_EXP_OR_STAR: _SYMB_3  */
#line 1283 "HAL_S.y"
            { (yyval.literal_exp_or_star_) = make_ABliteralStar(); (yyval.literal_exp_or_star_)->line_number = (yyloc).first_line; (yyval.literal_exp_or_star_)->char_number = (yyloc).first_column;  }
#line 7068 "Parser.c"
    break;

  case 495: /* TYPE_SPEC: STRUCT_SPEC  */
#line 1285 "HAL_S.y"
                        { (yyval.type_spec_) = make_AAtypeSpecStruct((yyvsp[0].struct_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7074 "Parser.c"
    break;

  case 496: /* TYPE_SPEC: BIT_SPEC  */
#line 1286 "HAL_S.y"
             { (yyval.type_spec_) = make_ABtypeSpecBit((yyvsp[0].bit_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7080 "Parser.c"
    break;

  case 497: /* TYPE_SPEC: CHAR_SPEC  */
#line 1287 "HAL_S.y"
              { (yyval.type_spec_) = make_ACtypeSpecChar((yyvsp[0].char_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7086 "Parser.c"
    break;

  case 498: /* TYPE_SPEC: ARITH_SPEC  */
#line 1288 "HAL_S.y"
               { (yyval.type_spec_) = make_ADtypeSpecArith((yyvsp[0].arith_spec_)); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7092 "Parser.c"
    break;

  case 499: /* TYPE_SPEC: _SYMB_79  */
#line 1289 "HAL_S.y"
             { (yyval.type_spec_) = make_AEtypeSpecEvent(); (yyval.type_spec_)->line_number = (yyloc).first_line; (yyval.type_spec_)->char_number = (yyloc).first_column;  }
#line 7098 "Parser.c"
    break;

  case 500: /* BIT_SPEC: _SYMB_49  */
#line 1291 "HAL_S.y"
                    { (yyval.bit_spec_) = make_AAbitSpecBoolean(); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7104 "Parser.c"
    break;

  case 501: /* BIT_SPEC: _SYMB_48 _SYMB_6 LITERAL_EXP_OR_STAR _SYMB_7  */
#line 1292 "HAL_S.y"
                                                 { (yyval.bit_spec_) = make_ABbitSpecBoolean((yyvsp[-1].literal_exp_or_star_)); (yyval.bit_spec_)->line_number = (yyloc).first_line; (yyval.bit_spec_)->char_number = (yyloc).first_column;  }
#line 7110 "Parser.c"
    break;

  case 502: /* CHAR_SPEC: _SYMB_57 _SYMB_6 LITERAL_EXP_OR_STAR _SYMB_7  */
#line 1294 "HAL_S.y"
                                                         { (yyval.char_spec_) = make_AAchar_spec((yyvsp[-1].literal_exp_or_star_)); (yyval.char_spec_)->line_number = (yyloc).first_line; (yyval.char_spec_)->char_number = (yyloc).first_column;  }
#line 7116 "Parser.c"
    break;

  case 503: /* STRUCT_SPEC: STRUCT_TEMPLATE STRUCT_SPEC_BODY  */
#line 1296 "HAL_S.y"
                                               { (yyval.struct_spec_) = make_AAstruct_spec((yyvsp[-1].struct_template_), (yyvsp[0].struct_spec_body_)); (yyval.struct_spec_)->line_number = (yyloc).first_line; (yyval.struct_spec_)->char_number = (yyloc).first_column;  }
#line 7122 "Parser.c"
    break;

  case 504: /* STRUCT_SPEC_BODY: _SYMB_2 _SYMB_156  */
#line 1298 "HAL_S.y"
                                     { (yyval.struct_spec_body_) = make_AAstruct_spec_body(); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7128 "Parser.c"
    break;

  case 505: /* STRUCT_SPEC_BODY: STRUCT_SPEC_HEAD LITERAL_EXP_OR_STAR _SYMB_7  */
#line 1299 "HAL_S.y"
                                                 { (yyval.struct_spec_body_) = make_ABstruct_spec_body((yyvsp[-2].struct_spec_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.struct_spec_body_)->line_number = (yyloc).first_line; (yyval.struct_spec_body_)->char_number = (yyloc).first_column;  }
#line 7134 "Parser.c"
    break;

  case 506: /* STRUCT_TEMPLATE: STRUCTURE_ID  */
#line 1301 "HAL_S.y"
                               { (yyval.struct_template_) = make_FMstruct_template((yyvsp[0].structure_id_)); (yyval.struct_template_)->line_number = (yyloc).first_line; (yyval.struct_template_)->char_number = (yyloc).first_column;  }
#line 7140 "Parser.c"
    break;

  case 507: /* STRUCT_SPEC_HEAD: _SYMB_2 _SYMB_156 _SYMB_6  */
#line 1303 "HAL_S.y"
                                             { (yyval.struct_spec_head_) = make_AAstruct_spec_head(); (yyval.struct_spec_head_)->line_number = (yyloc).first_line; (yyval.struct_spec_head_)->char_number = (yyloc).first_column;  }
#line 7146 "Parser.c"
    break;

  case 508: /* ARITH_SPEC: PREC_SPEC  */
#line 1305 "HAL_S.y"
                       { (yyval.arith_spec_) = make_AAarith_spec((yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7152 "Parser.c"
    break;

  case 509: /* ARITH_SPEC: SQ_DQ_NAME  */
#line 1306 "HAL_S.y"
               { (yyval.arith_spec_) = make_ABarith_spec((yyvsp[0].sq_dq_name_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7158 "Parser.c"
    break;

  case 510: /* ARITH_SPEC: SQ_DQ_NAME PREC_SPEC  */
#line 1307 "HAL_S.y"
                         { (yyval.arith_spec_) = make_ACarith_spec((yyvsp[-1].sq_dq_name_), (yyvsp[0].prec_spec_)); (yyval.arith_spec_)->line_number = (yyloc).first_line; (yyval.arith_spec_)->char_number = (yyloc).first_column;  }
#line 7164 "Parser.c"
    break;

  case 511: /* SQ_DQ_NAME: DOUBLY_QUAL_NAME_HEAD LITERAL_EXP_OR_STAR _SYMB_7  */
#line 1309 "HAL_S.y"
                                                               { (yyval.sq_dq_name_) = make_AAsq_dq_name((yyvsp[-2].doubly_qual_name_head_), (yyvsp[-1].literal_exp_or_star_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 7170 "Parser.c"
    break;

  case 512: /* SQ_DQ_NAME: ARITH_CONV  */
#line 1310 "HAL_S.y"
               { (yyval.sq_dq_name_) = make_ABsq_dq_name((yyvsp[0].arith_conv_)); (yyval.sq_dq_name_)->line_number = (yyloc).first_line; (yyval.sq_dq_name_)->char_number = (yyloc).first_column;  }
#line 7176 "Parser.c"
    break;

  case 513: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_176 _SYMB_6  */
#line 1312 "HAL_S.y"
                                          { (yyval.doubly_qual_name_head_) = make_AAdoublyQualNameHeadVector(); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 7182 "Parser.c"
    break;

  case 514: /* DOUBLY_QUAL_NAME_HEAD: _SYMB_105 _SYMB_6 LITERAL_EXP_OR_STAR _SYMB_8  */
#line 1313 "HAL_S.y"
                                                  { (yyval.doubly_qual_name_head_) = make_ABdoublyQualNameHeadMatrix((yyvsp[-1].literal_exp_or_star_)); (yyval.doubly_qual_name_head_)->line_number = (yyloc).first_line; (yyval.doubly_qual_name_head_)->char_number = (yyloc).first_column;  }
#line 7188 "Parser.c"
    break;

  case 515: /* COMPILATION: ANY_STATEMENT  */
#line 1315 "HAL_S.y"
                            { (yyval.compilation_) = make_AAcompilation((yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7194 "Parser.c"
    break;

  case 516: /* COMPILATION: COMPILATION ANY_STATEMENT  */
#line 1316 "HAL_S.y"
                              { (yyval.compilation_) = make_ABcompilation((yyvsp[-1].compilation_), (yyvsp[0].any_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7200 "Parser.c"
    break;

  case 517: /* COMPILATION: DECLARE_STATEMENT  */
#line 1317 "HAL_S.y"
                      { (yyval.compilation_) = make_ACcompilation((yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7206 "Parser.c"
    break;

  case 518: /* COMPILATION: COMPILATION DECLARE_STATEMENT  */
#line 1318 "HAL_S.y"
                                  { (yyval.compilation_) = make_ADcompilation((yyvsp[-1].compilation_), (yyvsp[0].declare_statement_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7212 "Parser.c"
    break;

  case 519: /* COMPILATION: STRUCTURE_STMT  */
#line 1319 "HAL_S.y"
                   { (yyval.compilation_) = make_AEcompilation((yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7218 "Parser.c"
    break;

  case 520: /* COMPILATION: COMPILATION STRUCTURE_STMT  */
#line 1320 "HAL_S.y"
                               { (yyval.compilation_) = make_AFcompilation((yyvsp[-1].compilation_), (yyvsp[0].structure_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7224 "Parser.c"
    break;

  case 521: /* COMPILATION: REPLACE_STMT _SYMB_16  */
#line 1321 "HAL_S.y"
                          { (yyval.compilation_) = make_AGcompilation((yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7230 "Parser.c"
    break;

  case 522: /* COMPILATION: COMPILATION REPLACE_STMT _SYMB_16  */
#line 1322 "HAL_S.y"
                                      { (yyval.compilation_) = make_AHcompilation((yyvsp[-2].compilation_), (yyvsp[-1].replace_stmt_)); (yyval.compilation_)->line_number = (yyloc).first_line; (yyval.compilation_)->char_number = (yyloc).first_column; YY_RESULT_COMPILATION_= (yyval.compilation_); }
#line 7236 "Parser.c"
    break;

  case 523: /* BLOCK_DEFINITION: BLOCK_STMT CLOSING _SYMB_16  */
#line 1324 "HAL_S.y"
                                               { (yyval.block_definition_) = make_AAblock_definition((yyvsp[-2].block_stmt_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7242 "Parser.c"
    break;

  case 524: /* BLOCK_DEFINITION: BLOCK_STMT BLOCK_BODY CLOSING _SYMB_16  */
#line 1325 "HAL_S.y"
                                           { (yyval.block_definition_) = make_ABblock_definition((yyvsp[-3].block_stmt_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.block_definition_)->line_number = (yyloc).first_line; (yyval.block_definition_)->char_number = (yyloc).first_column;  }
#line 7248 "Parser.c"
    break;

  case 525: /* BLOCK_STMT: BLOCK_STMT_TOP _SYMB_16  */
#line 1327 "HAL_S.y"
                                     { (yyval.block_stmt_) = make_AAblock_stmt((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_)->line_number = (yyloc).first_line; (yyval.block_stmt_)->char_number = (yyloc).first_column;  }
#line 7254 "Parser.c"
    break;

  case 526: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_32  */
#line 1329 "HAL_S.y"
                                         { (yyval.block_stmt_top_) = make_AAblockTopAccess((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7260 "Parser.c"
    break;

  case 527: /* BLOCK_STMT_TOP: BLOCK_STMT_TOP _SYMB_136  */
#line 1330 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ABblockTopRigid((yyvsp[-1].block_stmt_top_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7266 "Parser.c"
    break;

  case 528: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD  */
#line 1331 "HAL_S.y"
                    { (yyval.block_stmt_top_) = make_ACblockTopHead((yyvsp[0].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7272 "Parser.c"
    break;

  case 529: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_81  */
#line 1332 "HAL_S.y"
                             { (yyval.block_stmt_top_) = make_ADblockTopExclusive((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7278 "Parser.c"
    break;

  case 530: /* BLOCK_STMT_TOP: BLOCK_STMT_HEAD _SYMB_129  */
#line 1333 "HAL_S.y"
                              { (yyval.block_stmt_top_) = make_AEblockTopReentrant((yyvsp[-1].block_stmt_head_)); (yyval.block_stmt_top_)->line_number = (yyloc).first_line; (yyval.block_stmt_top_)->char_number = (yyloc).first_column;  }
#line 7284 "Parser.c"
    break;

  case 531: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_125  */
#line 1335 "HAL_S.y"
                                           { (yyval.block_stmt_head_) = make_AAblockHeadProgram((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7290 "Parser.c"
    break;

  case 532: /* BLOCK_STMT_HEAD: LABEL_EXTERNAL _SYMB_61  */
#line 1336 "HAL_S.y"
                            { (yyval.block_stmt_head_) = make_ABblockHeadCompool((yyvsp[-1].label_external_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7296 "Parser.c"
    break;

  case 533: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_163  */
#line 1337 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ACblockHeadTask((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7302 "Parser.c"
    break;

  case 534: /* BLOCK_STMT_HEAD: LABEL_DEFINITION _SYMB_175  */
#line 1338 "HAL_S.y"
                               { (yyval.block_stmt_head_) = make_ADblockHeadUpdate((yyvsp[-1].label_definition_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7308 "Parser.c"
    break;

  case 535: /* BLOCK_STMT_HEAD: _SYMB_175  */
#line 1339 "HAL_S.y"
              { (yyval.block_stmt_head_) = make_AEblockHeadUpdate(); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7314 "Parser.c"
    break;

  case 536: /* BLOCK_STMT_HEAD: FUNCTION_NAME  */
#line 1340 "HAL_S.y"
                  { (yyval.block_stmt_head_) = make_AFblockHeadFunction((yyvsp[0].function_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7320 "Parser.c"
    break;

  case 537: /* BLOCK_STMT_HEAD: FUNCTION_NAME FUNC_STMT_BODY  */
#line 1341 "HAL_S.y"
                                 { (yyval.block_stmt_head_) = make_AGblockHeadFunction((yyvsp[-1].function_name_), (yyvsp[0].func_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7326 "Parser.c"
    break;

  case 538: /* BLOCK_STMT_HEAD: PROCEDURE_NAME  */
#line 1342 "HAL_S.y"
                   { (yyval.block_stmt_head_) = make_AHblockHeadProcedure((yyvsp[0].procedure_name_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7332 "Parser.c"
    break;

  case 539: /* BLOCK_STMT_HEAD: PROCEDURE_NAME PROC_STMT_BODY  */
#line 1343 "HAL_S.y"
                                  { (yyval.block_stmt_head_) = make_AIblockHeadProcedure((yyvsp[-1].procedure_name_), (yyvsp[0].proc_stmt_body_)); (yyval.block_stmt_head_)->line_number = (yyloc).first_line; (yyval.block_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7338 "Parser.c"
    break;

  case 540: /* LABEL_EXTERNAL: LABEL_DEFINITION  */
#line 1345 "HAL_S.y"
                                  { (yyval.label_external_) = make_AAlabel_external((yyvsp[0].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7344 "Parser.c"
    break;

  case 541: /* LABEL_EXTERNAL: LABEL_DEFINITION _SYMB_84  */
#line 1346 "HAL_S.y"
                              { (yyval.label_external_) = make_ABlabel_external((yyvsp[-1].label_definition_)); (yyval.label_external_)->line_number = (yyloc).first_line; (yyval.label_external_)->char_number = (yyloc).first_column;  }
#line 7350 "Parser.c"
    break;

  case 542: /* CLOSING: _SYMB_59  */
#line 1348 "HAL_S.y"
                   { (yyval.closing_) = make_AAclosing(); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7356 "Parser.c"
    break;

  case 543: /* CLOSING: _SYMB_59 LABEL  */
#line 1349 "HAL_S.y"
                   { (yyval.closing_) = make_ABclosing((yyvsp[0].label_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7362 "Parser.c"
    break;

  case 544: /* CLOSING: LABEL_DEFINITION CLOSING  */
#line 1350 "HAL_S.y"
                             { (yyval.closing_) = make_ACclosing((yyvsp[-1].label_definition_), (yyvsp[0].closing_)); (yyval.closing_)->line_number = (yyloc).first_line; (yyval.closing_)->char_number = (yyloc).first_column;  }
#line 7368 "Parser.c"
    break;

  case 545: /* BLOCK_BODY: DECLARE_GROUP  */
#line 1352 "HAL_S.y"
                           { (yyval.block_body_) = make_ABblock_body((yyvsp[0].declare_group_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7374 "Parser.c"
    break;

  case 546: /* BLOCK_BODY: ANY_STATEMENT  */
#line 1353 "HAL_S.y"
                  { (yyval.block_body_) = make_ADblock_body((yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7380 "Parser.c"
    break;

  case 547: /* BLOCK_BODY: BLOCK_BODY ANY_STATEMENT  */
#line 1354 "HAL_S.y"
                             { (yyval.block_body_) = make_ACblock_body((yyvsp[-1].block_body_), (yyvsp[0].any_statement_)); (yyval.block_body_)->line_number = (yyloc).first_line; (yyval.block_body_)->char_number = (yyloc).first_column;  }
#line 7386 "Parser.c"
    break;

  case 548: /* FUNCTION_NAME: LABEL_EXTERNAL _SYMB_89  */
#line 1356 "HAL_S.y"
                                        { (yyval.function_name_) = make_AAfunction_name((yyvsp[-1].label_external_)); (yyval.function_name_)->line_number = (yyloc).first_line; (yyval.function_name_)->char_number = (yyloc).first_column;  }
#line 7392 "Parser.c"
    break;

  case 549: /* PROCEDURE_NAME: LABEL_EXTERNAL _SYMB_123  */
#line 1358 "HAL_S.y"
                                          { (yyval.procedure_name_) = make_AAprocedure_name((yyvsp[-1].label_external_)); (yyval.procedure_name_)->line_number = (yyloc).first_line; (yyval.procedure_name_)->char_number = (yyloc).first_column;  }
#line 7398 "Parser.c"
    break;

  case 550: /* FUNC_STMT_BODY: PARAMETER_LIST  */
#line 1360 "HAL_S.y"
                                { (yyval.func_stmt_body_) = make_AAfunc_stmt_body((yyvsp[0].parameter_list_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7404 "Parser.c"
    break;

  case 551: /* FUNC_STMT_BODY: TYPE_SPEC  */
#line 1361 "HAL_S.y"
              { (yyval.func_stmt_body_) = make_ABfunc_stmt_body((yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7410 "Parser.c"
    break;

  case 552: /* FUNC_STMT_BODY: PARAMETER_LIST TYPE_SPEC  */
#line 1362 "HAL_S.y"
                             { (yyval.func_stmt_body_) = make_ACfunc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].type_spec_)); (yyval.func_stmt_body_)->line_number = (yyloc).first_line; (yyval.func_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7416 "Parser.c"
    break;

  case 553: /* PROC_STMT_BODY: PARAMETER_LIST  */
#line 1364 "HAL_S.y"
                                { (yyval.proc_stmt_body_) = make_AAproc_stmt_body((yyvsp[0].parameter_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7422 "Parser.c"
    break;

  case 554: /* PROC_STMT_BODY: ASSIGN_LIST  */
#line 1365 "HAL_S.y"
                { (yyval.proc_stmt_body_) = make_ABproc_stmt_body((yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7428 "Parser.c"
    break;

  case 555: /* PROC_STMT_BODY: PARAMETER_LIST ASSIGN_LIST  */
#line 1366 "HAL_S.y"
                               { (yyval.proc_stmt_body_) = make_ACproc_stmt_body((yyvsp[-1].parameter_list_), (yyvsp[0].assign_list_)); (yyval.proc_stmt_body_)->line_number = (yyloc).first_line; (yyval.proc_stmt_body_)->char_number = (yyloc).first_column;  }
#line 7434 "Parser.c"
    break;

  case 556: /* DECLARE_GROUP: DECLARE_ELEMENT  */
#line 1368 "HAL_S.y"
                                { (yyval.declare_group_) = make_AAdeclare_group((yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7440 "Parser.c"
    break;

  case 557: /* DECLARE_GROUP: DECLARE_GROUP DECLARE_ELEMENT  */
#line 1369 "HAL_S.y"
                                  { (yyval.declare_group_) = make_ABdeclare_group((yyvsp[-1].declare_group_), (yyvsp[0].declare_element_)); (yyval.declare_group_)->line_number = (yyloc).first_line; (yyval.declare_group_)->char_number = (yyloc).first_column;  }
#line 7446 "Parser.c"
    break;

  case 558: /* DECLARE_ELEMENT: DECLARE_STATEMENT  */
#line 1371 "HAL_S.y"
                                    { (yyval.declare_element_) = make_AAdeclareElementDeclare((yyvsp[0].declare_statement_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7452 "Parser.c"
    break;

  case 559: /* DECLARE_ELEMENT: REPLACE_STMT _SYMB_16  */
#line 1372 "HAL_S.y"
                          { (yyval.declare_element_) = make_ABdeclareElementReplace((yyvsp[-1].replace_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7458 "Parser.c"
    break;

  case 560: /* DECLARE_ELEMENT: STRUCTURE_STMT  */
#line 1373 "HAL_S.y"
                   { (yyval.declare_element_) = make_ACdeclareElementStructure((yyvsp[0].structure_stmt_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7464 "Parser.c"
    break;

  case 561: /* DECLARE_ELEMENT: _SYMB_76 _SYMB_84 IDENTIFIER _SYMB_167 VARIABLE _SYMB_16  */
#line 1374 "HAL_S.y"
                                                             { (yyval.declare_element_) = make_ADdeclareElementEquate((yyvsp[-3].identifier_), (yyvsp[-1].variable_)); (yyval.declare_element_)->line_number = (yyloc).first_line; (yyval.declare_element_)->char_number = (yyloc).first_column;  }
#line 7470 "Parser.c"
    break;

  case 562: /* PARAMETER: _SYMB_190  */
#line 1376 "HAL_S.y"
                      { (yyval.parameter_) = make_AAparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7476 "Parser.c"
    break;

  case 563: /* PARAMETER: _SYMB_181  */
#line 1377 "HAL_S.y"
              { (yyval.parameter_) = make_ABparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7482 "Parser.c"
    break;

  case 564: /* PARAMETER: _SYMB_184  */
#line 1378 "HAL_S.y"
              { (yyval.parameter_) = make_ACparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7488 "Parser.c"
    break;

  case 565: /* PARAMETER: _SYMB_185  */
#line 1379 "HAL_S.y"
              { (yyval.parameter_) = make_ADparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7494 "Parser.c"
    break;

  case 566: /* PARAMETER: _SYMB_188  */
#line 1380 "HAL_S.y"
              { (yyval.parameter_) = make_AEparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7500 "Parser.c"
    break;

  case 567: /* PARAMETER: _SYMB_187  */
#line 1381 "HAL_S.y"
              { (yyval.parameter_) = make_AFparameter((yyvsp[0].string_)); (yyval.parameter_)->line_number = (yyloc).first_line; (yyval.parameter_)->char_number = (yyloc).first_column;  }
#line 7506 "Parser.c"
    break;

  case 568: /* PARAMETER_LIST: PARAMETER_HEAD PARAMETER _SYMB_7  */
#line 1383 "HAL_S.y"
                                                  { (yyval.parameter_list_) = make_AAparameter_list((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_list_)->line_number = (yyloc).first_line; (yyval.parameter_list_)->char_number = (yyloc).first_column;  }
#line 7512 "Parser.c"
    break;

  case 569: /* PARAMETER_HEAD: _SYMB_6  */
#line 1385 "HAL_S.y"
                         { (yyval.parameter_head_) = make_AAparameter_head(); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 7518 "Parser.c"
    break;

  case 570: /* PARAMETER_HEAD: PARAMETER_HEAD PARAMETER _SYMB_8  */
#line 1386 "HAL_S.y"
                                     { (yyval.parameter_head_) = make_ABparameter_head((yyvsp[-2].parameter_head_), (yyvsp[-1].parameter_)); (yyval.parameter_head_)->line_number = (yyloc).first_line; (yyval.parameter_head_)->char_number = (yyloc).first_column;  }
#line 7524 "Parser.c"
    break;

  case 571: /* DECLARE_STATEMENT: _SYMB_67 DECLARE_BODY _SYMB_16  */
#line 1388 "HAL_S.y"
                                                   { (yyval.declare_statement_) = make_AAdeclare_statement((yyvsp[-1].declare_body_)); (yyval.declare_statement_)->line_number = (yyloc).first_line; (yyval.declare_statement_)->char_number = (yyloc).first_column;  }
#line 7530 "Parser.c"
    break;

  case 572: /* ASSIGN_LIST: ASSIGN PARAMETER_LIST  */
#line 1390 "HAL_S.y"
                                    { (yyval.assign_list_) = make_AAassign_list((yyvsp[-1].assign_), (yyvsp[0].parameter_list_)); (yyval.assign_list_)->line_number = (yyloc).first_line; (yyval.assign_list_)->char_number = (yyloc).first_column;  }
#line 7536 "Parser.c"
    break;

  case 573: /* TEXT: _SYMB_192  */
#line 1392 "HAL_S.y"
                 { (yyval.text_) = make_FQtext((yyvsp[0].string_)); (yyval.text_)->line_number = (yyloc).first_line; (yyval.text_)->char_number = (yyloc).first_column;  }
#line 7542 "Parser.c"
    break;

  case 574: /* REPLACE_STMT: _SYMB_133 REPLACE_HEAD _SYMB_50 TEXT  */
#line 1394 "HAL_S.y"
                                                    { (yyval.replace_stmt_) = make_AAreplace_stmt((yyvsp[-2].replace_head_), (yyvsp[0].text_)); (yyval.replace_stmt_)->line_number = (yyloc).first_line; (yyval.replace_stmt_)->char_number = (yyloc).first_column;  }
#line 7548 "Parser.c"
    break;

  case 575: /* REPLACE_HEAD: IDENTIFIER  */
#line 1396 "HAL_S.y"
                          { (yyval.replace_head_) = make_AAreplace_head((yyvsp[0].identifier_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 7554 "Parser.c"
    break;

  case 576: /* REPLACE_HEAD: IDENTIFIER _SYMB_6 ARG_LIST _SYMB_7  */
#line 1397 "HAL_S.y"
                                        { (yyval.replace_head_) = make_ABreplace_head((yyvsp[-3].identifier_), (yyvsp[-1].arg_list_)); (yyval.replace_head_)->line_number = (yyloc).first_line; (yyval.replace_head_)->char_number = (yyloc).first_column;  }
#line 7560 "Parser.c"
    break;

  case 577: /* ARG_LIST: IDENTIFIER  */
#line 1399 "HAL_S.y"
                      { (yyval.arg_list_) = make_AAarg_list((yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 7566 "Parser.c"
    break;

  case 578: /* ARG_LIST: ARG_LIST _SYMB_8 IDENTIFIER  */
#line 1400 "HAL_S.y"
                                { (yyval.arg_list_) = make_ABarg_list((yyvsp[-2].arg_list_), (yyvsp[0].identifier_)); (yyval.arg_list_)->line_number = (yyloc).first_line; (yyval.arg_list_)->char_number = (yyloc).first_column;  }
#line 7572 "Parser.c"
    break;

  case 579: /* STRUCTURE_STMT: _SYMB_156 STRUCT_STMT_HEAD STRUCT_STMT_TAIL  */
#line 1402 "HAL_S.y"
                                                             { (yyval.structure_stmt_) = make_AAstructure_stmt((yyvsp[-1].struct_stmt_head_), (yyvsp[0].struct_stmt_tail_)); (yyval.structure_stmt_)->line_number = (yyloc).first_line; (yyval.structure_stmt_)->char_number = (yyloc).first_column;  }
#line 7578 "Parser.c"
    break;

  case 580: /* STRUCT_STMT_HEAD: STRUCTURE_ID _SYMB_17 LEVEL  */
#line 1404 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_AAstruct_stmt_head((yyvsp[-2].structure_id_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7584 "Parser.c"
    break;

  case 581: /* STRUCT_STMT_HEAD: STRUCTURE_ID MINOR_ATTR_LIST _SYMB_17 LEVEL  */
#line 1405 "HAL_S.y"
                                                { (yyval.struct_stmt_head_) = make_ABstruct_stmt_head((yyvsp[-3].structure_id_), (yyvsp[-2].minor_attr_list_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7590 "Parser.c"
    break;

  case 582: /* STRUCT_STMT_HEAD: STRUCT_STMT_HEAD DECLARATION _SYMB_8 LEVEL  */
#line 1406 "HAL_S.y"
                                               { (yyval.struct_stmt_head_) = make_ACstruct_stmt_head((yyvsp[-3].struct_stmt_head_), (yyvsp[-2].declaration_), (yyvsp[0].level_)); (yyval.struct_stmt_head_)->line_number = (yyloc).first_line; (yyval.struct_stmt_head_)->char_number = (yyloc).first_column;  }
#line 7596 "Parser.c"
    break;

  case 583: /* STRUCT_STMT_TAIL: DECLARATION _SYMB_16  */
#line 1408 "HAL_S.y"
                                        { (yyval.struct_stmt_tail_) = make_AAstruct_stmt_tail((yyvsp[-1].declaration_)); (yyval.struct_stmt_tail_)->line_number = (yyloc).first_line; (yyval.struct_stmt_tail_)->char_number = (yyloc).first_column;  }
#line 7602 "Parser.c"
    break;

  case 584: /* INLINE_DEFINITION: ARITH_INLINE  */
#line 1410 "HAL_S.y"
                                 { (yyval.inline_definition_) = make_AAinline_definition((yyvsp[0].arith_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7608 "Parser.c"
    break;

  case 585: /* INLINE_DEFINITION: BIT_INLINE  */
#line 1411 "HAL_S.y"
               { (yyval.inline_definition_) = make_ABinline_definition((yyvsp[0].bit_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7614 "Parser.c"
    break;

  case 586: /* INLINE_DEFINITION: CHAR_INLINE  */
#line 1412 "HAL_S.y"
                { (yyval.inline_definition_) = make_ACinline_definition((yyvsp[0].char_inline_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7620 "Parser.c"
    break;

  case 587: /* INLINE_DEFINITION: STRUCTURE_EXP  */
#line 1413 "HAL_S.y"
                  { (yyval.inline_definition_) = make_ADinline_definition((yyvsp[0].structure_exp_)); (yyval.inline_definition_)->line_number = (yyloc).first_line; (yyval.inline_definition_)->char_number = (yyloc).first_column;  }
#line 7626 "Parser.c"
    break;

  case 588: /* ARITH_INLINE: ARITH_INLINE_DEF CLOSING _SYMB_16  */
#line 1415 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_ACprimary((yyvsp[-2].arith_inline_def_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 7632 "Parser.c"
    break;

  case 589: /* ARITH_INLINE: ARITH_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1416 "HAL_S.y"
                                                 { (yyval.arith_inline_) = make_AZprimary((yyvsp[-3].arith_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.arith_inline_)->line_number = (yyloc).first_line; (yyval.arith_inline_)->char_number = (yyloc).first_column;  }
#line 7638 "Parser.c"
    break;

  case 590: /* ARITH_INLINE_DEF: _SYMB_89 ARITH_SPEC _SYMB_16  */
#line 1418 "HAL_S.y"
                                                { (yyval.arith_inline_def_) = make_AAarith_inline_def((yyvsp[-1].arith_spec_)); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 7644 "Parser.c"
    break;

  case 591: /* ARITH_INLINE_DEF: _SYMB_89 _SYMB_16  */
#line 1419 "HAL_S.y"
                      { (yyval.arith_inline_def_) = make_ABarith_inline_def(); (yyval.arith_inline_def_)->line_number = (yyloc).first_line; (yyval.arith_inline_def_)->char_number = (yyloc).first_column;  }
#line 7650 "Parser.c"
    break;

  case 592: /* BIT_INLINE: BIT_INLINE_DEF CLOSING _SYMB_16  */
#line 1421 "HAL_S.y"
                                             { (yyval.bit_inline_) = make_AGbit_prim((yyvsp[-2].bit_inline_def_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 7656 "Parser.c"
    break;

  case 593: /* BIT_INLINE: BIT_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1422 "HAL_S.y"
                                               { (yyval.bit_inline_) = make_AZbit_prim((yyvsp[-3].bit_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.bit_inline_)->line_number = (yyloc).first_line; (yyval.bit_inline_)->char_number = (yyloc).first_column;  }
#line 7662 "Parser.c"
    break;

  case 594: /* BIT_INLINE_DEF: _SYMB_89 BIT_SPEC _SYMB_16  */
#line 1424 "HAL_S.y"
                                            { (yyval.bit_inline_def_) = make_AAbit_inline_def((yyvsp[-1].bit_spec_)); (yyval.bit_inline_def_)->line_number = (yyloc).first_line; (yyval.bit_inline_def_)->char_number = (yyloc).first_column;  }
#line 7668 "Parser.c"
    break;

  case 595: /* CHAR_INLINE: CHAR_INLINE_DEF CLOSING _SYMB_16  */
#line 1426 "HAL_S.y"
                                               { (yyval.char_inline_) = make_ADchar_prim((yyvsp[-2].char_inline_def_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 7674 "Parser.c"
    break;

  case 596: /* CHAR_INLINE: CHAR_INLINE_DEF BLOCK_BODY CLOSING _SYMB_16  */
#line 1427 "HAL_S.y"
                                                { (yyval.char_inline_) = make_AZchar_prim((yyvsp[-3].char_inline_def_), (yyvsp[-2].block_body_), (yyvsp[-1].closing_)); (yyval.char_inline_)->line_number = (yyloc).first_line; (yyval.char_inline_)->char_number = (yyloc).first_column;  }
#line 7680 "Parser.c"
    break;

  case 597: /* CHAR_INLINE_DEF: _SYMB_89 CHAR_SPEC _SYMB_16  */
#line 1429 "HAL_S.y"
                                              { (yyval.char_inline_def_) = make_AAchar_inline_def((yyvsp[-1].char_spec_)); (yyval.char_inline_def_)->line_number = (yyloc).first_line; (yyval.char_inline_def_)->char_number = (yyloc).first_column;  }
#line 7686 "Parser.c"
    break;

  case 598: /* STRUC_INLINE_DEF: _SYMB_89 STRUCT_SPEC _SYMB_16  */
#line 1431 "HAL_S.y"
                                                 { (yyval.struc_inline_def_) = make_AAstruc_inline_def((yyvsp[-1].struct_spec_)); (yyval.struc_inline_def_)->line_number = (yyloc).first_line; (yyval.struc_inline_def_)->char_number = (yyloc).first_column;  }
#line 7692 "Parser.c"
    break;


#line 7696 "Parser.c"

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

