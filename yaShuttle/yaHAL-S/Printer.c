/*** BNFC-Generated Pretty Printer and Abstract Syntax Viewer ***/

#include "Printer.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define INDENT_WIDTH 2

int _n_;
char *buf_;
int cur_;
int buf_size;

/* You may wish to change the renderC functions */
void renderC(Char c)
{
  if (c == '{')
  {
     bufAppendC('\n');
     indent();
     bufAppendC(c);
     _n_ = _n_ + INDENT_WIDTH;
     bufAppendC('\n');
     indent();
  }
  else if (c == '(' || c == '[')
     bufAppendC(c);
  else if (c == ')' || c == ']')
  {
     backup();
     bufAppendC(c);
  }
  else if (c == '}')
  {
     int t;
     _n_ = _n_ - INDENT_WIDTH;
     for(t=0; t<INDENT_WIDTH; t++) {
       backup();
     }
     bufAppendC(c);
     bufAppendC('\n');
     indent();
  }
  else if (c == ',')
  {
     backup();
     bufAppendC(c);
     bufAppendC(' ');
  }
  else if (c == ';')
  {
     backup();
     bufAppendC(c);
     bufAppendC('\n');
     indent();
  }
  else if (c == 0) return;
  else
  {
     bufAppendC(' ');
     bufAppendC(c);
     bufAppendC(' ');
  }
}
void renderS(String s)
{
  if(strlen(s) > 0)
  {
    bufAppendS(s);
    bufAppendC(' ');
  }
}
void indent(void)
{
  int n = _n_;
  while (n > 0)
  {
    bufAppendC(' ');
    n--;
  }
}
void backup(void)
{
  if (buf_[cur_ - 1] == ' ')
  {
    buf_[cur_ - 1] = 0;
    cur_--;
  }
}
char *printCOMPILATION(COMPILATION p)
{
  _n_ = 0;
  bufReset();
  ppCOMPILATION(p, 0);
  return buf_;
}
char *showCOMPILATION(COMPILATION p)
{
  _n_ = 0;
  bufReset();
  shCOMPILATION(p);
  return buf_;
}
void ppDECLARE_BODY(DECLARE_BODY p, int _i_)
{
  switch(p->kind)
  {
  case is_AAdeclareBody_declarationList:
    if (_i_ > 0) renderC(_L_PAREN);
    ppDECLARATION_LIST(p->u.aadeclarebody_declarationlist_.declaration_list_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABdeclareBody_attributes_declarationList:
    if (_i_ > 0) renderC(_L_PAREN);
    ppATTRIBUTES(p->u.abdeclarebody_attributes_declarationlist_.attributes_, 0);
    renderC(',');
    ppDECLARATION_LIST(p->u.abdeclarebody_attributes_declarationlist_.declaration_list_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing DECLARE_BODY!\n");
    exit(1);
  }
}

void ppATTRIBUTES(ATTRIBUTES p, int _i_)
{
  switch(p->kind)
  {
  case is_AAattributes_arraySpec_typeAndMinorAttr:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARRAY_SPEC(p->u.aaattributes_arrayspec_typeandminorattr_.array_spec_, 0);
    ppTYPE_AND_MINOR_ATTR(p->u.aaattributes_arrayspec_typeandminorattr_.type_and_minor_attr_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABattributes_arraySpec:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARRAY_SPEC(p->u.abattributes_arrayspec_.array_spec_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACattributes_typeAndMinorAttr:
    if (_i_ > 0) renderC(_L_PAREN);
    ppTYPE_AND_MINOR_ATTR(p->u.acattributes_typeandminorattr_.type_and_minor_attr_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ATTRIBUTES!\n");
    exit(1);
  }
}

void ppDECLARATION(DECLARATION p, int _i_)
{
  switch(p->kind)
  {
  case is_AAdeclaration_nameId:
    if (_i_ > 0) renderC(_L_PAREN);
    ppNAME_ID(p->u.aadeclaration_nameid_.name_id_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABdeclaration_nameId_attributes:
    if (_i_ > 0) renderC(_L_PAREN);
    ppNAME_ID(p->u.abdeclaration_nameid_attributes_.name_id_, 0);
    ppATTRIBUTES(p->u.abdeclaration_nameid_attributes_.attributes_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACdeclaration_labelToken_procedure_minorAttrList:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.acdeclaration_labeltoken_procedure_minorattrlist_.labeltoken_, 0);
    renderS("PROCEDURE");
    ppMINOR_ATTR_LIST(p->u.acdeclaration_labeltoken_procedure_minorattrlist_.minor_attr_list_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADdeclaration_labelToken_procedure:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.addeclaration_labeltoken_procedure_.labeltoken_, 0);
    renderS("PROCEDURE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEdeclaration_eventToken_event:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.aedeclaration_eventtoken_event_.eventtoken_, 0);
    renderS("EVENT");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AFdeclaration_eventToken_event_minorAttrList:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.afdeclaration_eventtoken_event_minorattrlist_.eventtoken_, 0);
    renderS("EVENT");
    ppMINOR_ATTR_LIST(p->u.afdeclaration_eventtoken_event_minorattrlist_.minor_attr_list_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AGdeclaration_eventToken:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.agdeclaration_eventtoken_.eventtoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AHdeclaration_eventToken_minorAttrList:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.ahdeclaration_eventtoken_minorattrlist_.eventtoken_, 0);
    ppMINOR_ATTR_LIST(p->u.ahdeclaration_eventtoken_minorattrlist_.minor_attr_list_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing DECLARATION!\n");
    exit(1);
  }
}

void ppARRAY_SPEC(ARRAY_SPEC p, int _i_)
{
  switch(p->kind)
  {
  case is_AAarraySpec_arrayHead_literalExpOrStar:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARRAY_HEAD(p->u.aaarrayspec_arrayhead_literalexporstar_.array_head_, 0);
    ppLITERAL_EXP_OR_STAR(p->u.aaarrayspec_arrayhead_literalexporstar_.literal_exp_or_star_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABarraySpec_function:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("FUNCTION");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACarraySpec_procedure:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("PROCEDURE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADarraySpec_program:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("PROGRAM");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEarraySpec_task:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("TASK");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ARRAY_SPEC!\n");
    exit(1);
  }
}

void ppTYPE_AND_MINOR_ATTR(TYPE_AND_MINOR_ATTR p, int _i_)
{
  switch(p->kind)
  {
  case is_AAtypeAndMinorAttr_typeSpec:
    if (_i_ > 0) renderC(_L_PAREN);
    ppTYPE_SPEC(p->u.aatypeandminorattr_typespec_.type_spec_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABtypeAndMinorAttr_typeSpec_minorAttrList:
    if (_i_ > 0) renderC(_L_PAREN);
    ppTYPE_SPEC(p->u.abtypeandminorattr_typespec_minorattrlist_.type_spec_, 0);
    ppMINOR_ATTR_LIST(p->u.abtypeandminorattr_typespec_minorattrlist_.minor_attr_list_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACtypeAndMinorAttr_minorAttrList:
    if (_i_ > 0) renderC(_L_PAREN);
    ppMINOR_ATTR_LIST(p->u.actypeandminorattr_minorattrlist_.minor_attr_list_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing TYPE_AND_MINOR_ATTR!\n");
    exit(1);
  }
}

void ppIDENTIFIER(IDENTIFIER p, int _i_)
{
  switch(p->kind)
  {
  case is_AAidentifier:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.aaidentifier_.identifiertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing IDENTIFIER!\n");
    exit(1);
  }
}

void ppSQ_DQ_NAME(SQ_DQ_NAME p, int _i_)
{
  switch(p->kind)
  {
  case is_AAsQdQName_doublyQualNameHead_literalExpOrStar:
    if (_i_ > 0) renderC(_L_PAREN);
    ppDOUBLY_QUAL_NAME_HEAD(p->u.aasqdqname_doublyqualnamehead_literalexporstar_.doubly_qual_name_head_, 0);
    ppLITERAL_EXP_OR_STAR(p->u.aasqdqname_doublyqualnamehead_literalexporstar_.literal_exp_or_star_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABsQdQName_arithConv:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_CONV(p->u.absqdqname_arithconv_.arith_conv_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing SQ_DQ_NAME!\n");
    exit(1);
  }
}

void ppDOUBLY_QUAL_NAME_HEAD(DOUBLY_QUAL_NAME_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAdoublyQualNameHead_vector:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("VECTOR");
    renderC('(');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABdoublyQualNameHead_matrix_literalExpOrStar:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("MATRIX");
    renderC('(');
    ppLITERAL_EXP_OR_STAR(p->u.abdoublyqualnamehead_matrix_literalexporstar_.literal_exp_or_star_, 0);
    renderC(',');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing DOUBLY_QUAL_NAME_HEAD!\n");
    exit(1);
  }
}

void ppARITH_CONV(ARITH_CONV p, int _i_)
{
  switch(p->kind)
  {
  case is_AAarithConv_integer:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("INTEGER");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABarithConv_scalar:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("SCALAR");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACarithConv_vector:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("VECTOR");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADarithConv_matrix:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("MATRIX");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ARITH_CONV!\n");
    exit(1);
  }
}

void ppDECLARATION_LIST(DECLARATION_LIST p, int _i_)
{
  switch(p->kind)
  {
  case is_AAdeclaration_list:
    if (_i_ > 0) renderC(_L_PAREN);
    ppDECLARATION(p->u.aadeclaration_list_.declaration_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABdeclaration_list:
    if (_i_ > 0) renderC(_L_PAREN);
    ppDCL_LIST_COMMA(p->u.abdeclaration_list_.dcl_list_comma_, 0);
    ppDECLARATION(p->u.abdeclaration_list_.declaration_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing DECLARATION_LIST!\n");
    exit(1);
  }
}

void ppNAME_ID(NAME_ID p, int _i_)
{
  switch(p->kind)
  {
  case is_AAnameId_identifier:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIDENTIFIER(p->u.aanameid_identifier_.identifier_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABnameId_identifier_name:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIDENTIFIER(p->u.abnameid_identifier_name_.identifier_, 0);
    renderS("NAME");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACnameId_bitId:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_ID(p->u.acnameid_bitid_.bit_id_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADnameId_charId:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_ID(p->u.adnameid_charid_.char_id_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEnameId_bitFunctionIdentifierToken:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.aenameid_bitfunctionidentifiertoken_.bitfunctionidentifiertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AFnameId_charFunctionIdentifierToken:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.afnameid_charfunctionidentifiertoken_.charfunctionidentifiertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AGnameId_structIdentifierToken:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.agnameid_structidentifiertoken_.structidentifiertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AHnameId_structFunctionIdentifierToken:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.ahnameid_structfunctionidentifiertoken_.structfunctionidentifiertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing NAME_ID!\n");
    exit(1);
  }
}

void ppARITH_EXP(ARITH_EXP p, int _i_)
{
  switch(p->kind)
  {
  case is_AAarithExpTerm:
    if (_i_ > 0) renderC(_L_PAREN);
    ppTERM(p->u.aaarithexpterm_.term_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABarithExpPlusTerm:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPLUS(p->u.abarithexpplusterm_.plus_, 0);
    ppTERM(p->u.abarithexpplusterm_.term_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACarithMinusTerm:
    if (_i_ > 0) renderC(_L_PAREN);
    ppMINUS(p->u.acarithminusterm_.minus_, 0);
    ppTERM(p->u.acarithminusterm_.term_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADarithExpArithExpPlusTerm:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_EXP(p->u.adarithexparithexpplusterm_.arith_exp_, 0);
    ppPLUS(p->u.adarithexparithexpplusterm_.plus_, 0);
    ppTERM(p->u.adarithexparithexpplusterm_.term_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEarithExpArithExpMinusTerm:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_EXP(p->u.aearithexparithexpminusterm_.arith_exp_, 0);
    ppMINUS(p->u.aearithexparithexpminusterm_.minus_, 0);
    ppTERM(p->u.aearithexparithexpminusterm_.term_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ARITH_EXP!\n");
    exit(1);
  }
}

void ppTERM(TERM p, int _i_)
{
  switch(p->kind)
  {
  case is_AAtermNoDivide:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPRODUCT(p->u.aatermnodivide_.product_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABtermDivide:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPRODUCT(p->u.abtermdivide_.product_, 0);
    renderC('/');
    ppTERM(p->u.abtermdivide_.term_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing TERM!\n");
    exit(1);
  }
}

void ppPLUS(PLUS p, int _i_)
{
  switch(p->kind)
  {
  case is_AAplus:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('+');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing PLUS!\n");
    exit(1);
  }
}

void ppMINUS(MINUS p, int _i_)
{
  switch(p->kind)
  {
  case is_AAminus:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('-');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing MINUS!\n");
    exit(1);
  }
}

void ppPRODUCT(PRODUCT p, int _i_)
{
  switch(p->kind)
  {
  case is_AAproductSingle:
    if (_i_ > 0) renderC(_L_PAREN);
    ppFACTOR(p->u.aaproductsingle_.factor_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABproductCross:
    if (_i_ > 0) renderC(_L_PAREN);
    ppFACTOR(p->u.abproductcross_.factor_, 0);
    renderC('*');
    ppPRODUCT(p->u.abproductcross_.product_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACproductDot:
    if (_i_ > 0) renderC(_L_PAREN);
    ppFACTOR(p->u.acproductdot_.factor_, 0);
    renderC('.');
    ppPRODUCT(p->u.acproductdot_.product_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADproductMultiplication:
    if (_i_ > 0) renderC(_L_PAREN);
    ppFACTOR(p->u.adproductmultiplication_.factor_, 0);
    ppPRODUCT(p->u.adproductmultiplication_.product_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing PRODUCT!\n");
    exit(1);
  }
}

void ppFACTOR(FACTOR p, int _i_)
{
  switch(p->kind)
  {
  case is_AAfactor:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPRIMARY(p->u.aafactor_.primary_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABfactorExponentiation:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPRIMARY(p->u.abfactorexponentiation_.primary_, 0);
    ppEXPONENTIATION(p->u.abfactorexponentiation_.exponentiation_, 0);
    ppFACTOR(p->u.abfactorexponentiation_.factor_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing FACTOR!\n");
    exit(1);
  }
}

void ppEXPONENTIATION(EXPONENTIATION p, int _i_)
{
  switch(p->kind)
  {
  case is_AAexponentiation:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("**");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing EXPONENTIATION!\n");
    exit(1);
  }
}

void ppPRIMARY(PRIMARY p, int _i_)
{
  switch(p->kind)
  {
  case is_AAprimary:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_VAR(p->u.aaprimary_.arith_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADprimary:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPRE_PRIMARY(p->u.adprimary_.pre_primary_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABprimary:
    if (_i_ > 0) renderC(_L_PAREN);
    ppMODIFIED_ARITH_FUNC(p->u.abprimary_.modified_arith_func_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEprimary:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPRE_PRIMARY(p->u.aeprimary_.pre_primary_, 0);
    ppQUALIFIER(p->u.aeprimary_.qualifier_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing PRIMARY!\n");
    exit(1);
  }
}

void ppARITH_VAR(ARITH_VAR p, int _i_)
{
  switch(p->kind)
  {
  case is_AAarith_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_ID(p->u.aaarith_var_.arith_id_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACarith_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_ID(p->u.acarith_var_.arith_id_, 0);
    ppSUBSCRIPT(p->u.acarith_var_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AAarithVarBracketed:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('[');
    ppARITH_ID(p->u.aaarithvarbracketed_.arith_id_, 0);
    renderC(']');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABarithVarBracketed:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('[');
    ppARITH_ID(p->u.abarithvarbracketed_.arith_id_, 0);
    renderC(']');
    ppSUBSCRIPT(p->u.abarithvarbracketed_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AAarithVarBraced:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('{');
    ppQUAL_STRUCT(p->u.aaarithvarbraced_.qual_struct_, 0);
    renderC('}');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABarithVarBraced:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('{');
    ppQUAL_STRUCT(p->u.abarithvarbraced_.qual_struct_, 0);
    renderC('}');
    ppSUBSCRIPT(p->u.abarithvarbraced_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABarith_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQUAL_STRUCT(p->u.abarith_var_.qual_struct_, 0);
    renderC('.');
    ppARITH_ID(p->u.abarith_var_.arith_id_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADarith_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQUAL_STRUCT(p->u.adarith_var_.qual_struct_, 0);
    renderC('.');
    ppARITH_ID(p->u.adarith_var_.arith_id_, 0);
    ppSUBSCRIPT(p->u.adarith_var_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ARITH_VAR!\n");
    exit(1);
  }
}

void ppPRE_PRIMARY(PRE_PRIMARY p, int _i_)
{
  switch(p->kind)
  {
  case is_AApre_primary:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('(');
    ppARITH_EXP(p->u.aapre_primary_.arith_exp_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABpre_primary:
    if (_i_ > 0) renderC(_L_PAREN);
    ppNUMBER(p->u.abpre_primary_.number_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACpre_primary:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCOMPOUND_NUMBER(p->u.acpre_primary_.compound_number_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADprePrimaryRtlFunction:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_FUNC_HEAD(p->u.adpreprimaryrtlfunction_.arith_func_head_, 0);
    renderC('(');
    ppCALL_LIST(p->u.adpreprimaryrtlfunction_.call_list_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEprePrimaryFunction:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.aepreprimaryfunction_.labeltoken_, 0);
    renderC('(');
    ppCALL_LIST(p->u.aepreprimaryfunction_.call_list_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing PRE_PRIMARY!\n");
    exit(1);
  }
}

void ppNUMBER(NUMBER p, int _i_)
{
  switch(p->kind)
  {
  case is_AAnumber:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSIMPLE_NUMBER(p->u.aanumber_.simple_number_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABnumber:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLEVEL(p->u.abnumber_.level_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing NUMBER!\n");
    exit(1);
  }
}

void ppLEVEL(LEVEL p, int _i_)
{
  switch(p->kind)
  {
  case is_ZZlevel:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.zzlevel_.leveltoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing LEVEL!\n");
    exit(1);
  }
}

void ppCOMPOUND_NUMBER(COMPOUND_NUMBER p, int _i_)
{
  switch(p->kind)
  {
  case is_CLcompound_number:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.clcompound_number_.compoundtoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing COMPOUND_NUMBER!\n");
    exit(1);
  }
}

void ppSIMPLE_NUMBER(SIMPLE_NUMBER p, int _i_)
{
  switch(p->kind)
  {
  case is_CKsimple_number:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.cksimple_number_.numbertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing SIMPLE_NUMBER!\n");
    exit(1);
  }
}

void ppMODIFIED_ARITH_FUNC(MODIFIED_ARITH_FUNC p, int _i_)
{
  switch(p->kind)
  {
  case is_AAmodified_arith_func:
    if (_i_ > 0) renderC(_L_PAREN);
    ppNO_ARG_ARITH_FUNC(p->u.aamodified_arith_func_.no_arg_arith_func_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACmodified_arith_func:
    if (_i_ > 0) renderC(_L_PAREN);
    ppNO_ARG_ARITH_FUNC(p->u.acmodified_arith_func_.no_arg_arith_func_, 0);
    ppSUBSCRIPT(p->u.acmodified_arith_func_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADmodified_arith_func:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQUAL_STRUCT(p->u.admodified_arith_func_.qual_struct_, 0);
    renderC('.');
    ppNO_ARG_ARITH_FUNC(p->u.admodified_arith_func_.no_arg_arith_func_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEmodified_arith_func:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQUAL_STRUCT(p->u.aemodified_arith_func_.qual_struct_, 0);
    renderC('.');
    ppNO_ARG_ARITH_FUNC(p->u.aemodified_arith_func_.no_arg_arith_func_, 0);
    ppSUBSCRIPT(p->u.aemodified_arith_func_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing MODIFIED_ARITH_FUNC!\n");
    exit(1);
  }
}

void ppARITH_FUNC_HEAD(ARITH_FUNC_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAarith_func_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_FUNC(p->u.aaarith_func_head_.arith_func_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABarith_func_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_CONV(p->u.abarith_func_head_.arith_conv_, 0);
    ppSUBSCRIPT(p->u.abarith_func_head_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ARITH_FUNC_HEAD!\n");
    exit(1);
  }
}

void ppCALL_LIST(CALL_LIST p, int _i_)
{
  switch(p->kind)
  {
  case is_AAcall_list:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLIST_EXP(p->u.aacall_list_.list_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABcall_list:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCALL_LIST(p->u.abcall_list_.call_list_, 0);
    renderC(',');
    ppLIST_EXP(p->u.abcall_list_.list_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing CALL_LIST!\n");
    exit(1);
  }
}

void ppLIST_EXP(LIST_EXP p, int _i_)
{
  switch(p->kind)
  {
  case is_AAlist_exp:
    if (_i_ > 0) renderC(_L_PAREN);
    ppEXPRESSION(p->u.aalist_exp_.expression_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABlist_exp:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_EXP(p->u.ablist_exp_.arith_exp_, 0);
    renderC('#');
    ppEXPRESSION(p->u.ablist_exp_.expression_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADlist_exp:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQUAL_STRUCT(p->u.adlist_exp_.qual_struct_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing LIST_EXP!\n");
    exit(1);
  }
}

void ppEXPRESSION(EXPRESSION p, int _i_)
{
  switch(p->kind)
  {
  case is_AAexpression:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_EXP(p->u.aaexpression_.arith_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABexpression:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_EXP(p->u.abexpression_.bit_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACexpression:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_EXP(p->u.acexpression_.char_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEexpression:
    if (_i_ > 0) renderC(_L_PAREN);
    ppNAME_EXP(p->u.aeexpression_.name_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADexpression:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTRUCTURE_EXP(p->u.adexpression_.structure_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing EXPRESSION!\n");
    exit(1);
  }
}

void ppARITH_ID(ARITH_ID p, int _i_)
{
  switch(p->kind)
  {
  case is_FGarith_id:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIDENTIFIER(p->u.fgarith_id_.identifier_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_FHarith_id:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.fharith_id_.arithfieldtoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ARITH_ID!\n");
    exit(1);
  }
}

void ppNO_ARG_ARITH_FUNC(NO_ARG_ARITH_FUNC p, int _i_)
{
  switch(p->kind)
  {
  case is_ZZclocktime:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("CLOCKTIME");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZdate:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("DATE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZerrgrp:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ERRGRP");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZprio:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("PRIO");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZrandom:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("RANDOM");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZruntime:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("RUNTIME");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing NO_ARG_ARITH_FUNC!\n");
    exit(1);
  }
}

void ppARITH_FUNC(ARITH_FUNC p, int _i_)
{
  switch(p->kind)
  {
  case is_ZZnexttime:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("NEXTTIME");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZabs:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ABS");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZceiling:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("CEILING");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZdiv:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("DIV");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZfloor:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("FLOOR");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZmidval:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("MIDVAL");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZmod:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("MOD");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZodd:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ODD");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZremainder:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("REMAINDER");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZround:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ROUND");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZsign:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("SIGN");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZsignum:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("SIGNUM");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZtruncate:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("TRUNCATE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZarccos:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ARCCOS");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZarccosh:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ARCCOSH");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZarcsin:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ARCSIN");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZarcsinh:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ARCSINH");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZarctan2:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ARCTAN2");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZarctan:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ARCTAN");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZarctanh:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ARCTANH");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZcos:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("COS");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZcosh:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("COSH");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZexp:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("EXP");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZlog:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("LOG");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZsin:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("SIN");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZsinh:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("SINH");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZsqrt:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("SQRT");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZtan:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("TAN");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZtanh:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("TANH");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZshl:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("SHL");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZshr:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("SHR");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZabval:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ABVAL");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZdet:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("DET");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZtrace:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("TRACE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZunit:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("UNIT");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZmatrix:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("MATRIX");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZindex:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("INDEX");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZlength:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("LENGTH");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZinverse:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("INVERSE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZtranspose:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("TRANSPOSE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZprod:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("PROD");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZsum:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("SUM");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZsize:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("SIZE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZmax:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("MAX");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZmin:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("MIN");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AAarithFuncInteger:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("INTEGER");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AAarithFuncScalar:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("SCALAR");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ARITH_FUNC!\n");
    exit(1);
  }
}

void ppSUBSCRIPT(SUBSCRIPT p, int _i_)
{
  switch(p->kind)
  {
  case is_AAsubscript:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSUB_HEAD(p->u.aasubscript_.sub_head_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABsubscript:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQUALIFIER(p->u.absubscript_.qualifier_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACsubscript:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('$');
    ppNUMBER(p->u.acsubscript_.number_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADsubscript:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('$');
    ppARITH_VAR(p->u.adsubscript_.arith_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing SUBSCRIPT!\n");
    exit(1);
  }
}

void ppQUALIFIER(QUALIFIER p, int _i_)
{
  switch(p->kind)
  {
  case is_AAqualifier:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('$');
    renderC('(');
    renderC('@');
    ppPREC_SPEC(p->u.aaqualifier_.prec_spec_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABqualifier:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('$');
    renderC('(');
    ppSCALE_HEAD(p->u.abqualifier_.scale_head_, 0);
    ppARITH_EXP(p->u.abqualifier_.arith_exp_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACqualifier:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('$');
    renderC('(');
    renderC('@');
    ppPREC_SPEC(p->u.acqualifier_.prec_spec_, 0);
    renderC(',');
    ppSCALE_HEAD(p->u.acqualifier_.scale_head_, 0);
    ppARITH_EXP(p->u.acqualifier_.arith_exp_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADqualifier:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('$');
    renderC('(');
    renderC('@');
    ppRADIX(p->u.adqualifier_.radix_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing QUALIFIER!\n");
    exit(1);
  }
}

void ppSCALE_HEAD(SCALE_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAscale_head:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('@');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABscale_head:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('@');
    renderC('@');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing SCALE_HEAD!\n");
    exit(1);
  }
}

void ppPREC_SPEC(PREC_SPEC p, int _i_)
{
  switch(p->kind)
  {
  case is_AAprecSpecSingle:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("SINGLE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABprecSpecDouble:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("DOUBLE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing PREC_SPEC!\n");
    exit(1);
  }
}

void ppSUB_START(SUB_START p, int _i_)
{
  switch(p->kind)
  {
  case is_AAsubStartGroup:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('$');
    renderC('(');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABsubStartPrecSpec:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('$');
    renderC('(');
    renderC('@');
    ppPREC_SPEC(p->u.absubstartprecspec_.prec_spec_, 0);
    renderC(',');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACsubStartSemicolon:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSUB_HEAD(p->u.acsubstartsemicolon_.sub_head_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADsubStartColon:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSUB_HEAD(p->u.adsubstartcolon_.sub_head_, 0);
    renderC(':');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEsubStartComma:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSUB_HEAD(p->u.aesubstartcomma_.sub_head_, 0);
    renderC(',');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing SUB_START!\n");
    exit(1);
  }
}

void ppSUB_HEAD(SUB_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAsub_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSUB_START(p->u.aasub_head_.sub_start_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABsub_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSUB_START(p->u.absub_head_.sub_start_, 0);
    ppSUB(p->u.absub_head_.sub_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing SUB_HEAD!\n");
    exit(1);
  }
}

void ppSUB(SUB p, int _i_)
{
  switch(p->kind)
  {
  case is_AAsub:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSUB_EXP(p->u.aasub_.sub_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABsubStar:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('*');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACsubExp:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSUB_RUN_HEAD(p->u.acsubexp_.sub_run_head_, 0);
    ppSUB_EXP(p->u.acsubexp_.sub_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADsubAt:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_EXP(p->u.adsubat_.arith_exp_, 0);
    renderS("AT");
    ppSUB_EXP(p->u.adsubat_.sub_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing SUB!\n");
    exit(1);
  }
}

void ppSUB_RUN_HEAD(SUB_RUN_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAsubRunHeadTo:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSUB_EXP(p->u.aasubrunheadto_.sub_exp_, 0);
    renderS("TO");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing SUB_RUN_HEAD!\n");
    exit(1);
  }
}

void ppSUB_EXP(SUB_EXP p, int _i_)
{
  switch(p->kind)
  {
  case is_AAsub_exp:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_EXP(p->u.aasub_exp_.arith_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABsub_exp:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPOUND_EXPRESSION(p->u.absub_exp_.pound_expression_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing SUB_EXP!\n");
    exit(1);
  }
}

void ppPOUND_EXPRESSION(POUND_EXPRESSION p, int _i_)
{
  switch(p->kind)
  {
  case is_AApound_expression:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('#');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABpound_expression:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPOUND_EXPRESSION(p->u.abpound_expression_.pound_expression_, 0);
    ppPLUS(p->u.abpound_expression_.plus_, 0);
    ppTERM(p->u.abpound_expression_.term_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACpound_expression:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPOUND_EXPRESSION(p->u.acpound_expression_.pound_expression_, 0);
    ppMINUS(p->u.acpound_expression_.minus_, 0);
    ppTERM(p->u.acpound_expression_.term_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing POUND_EXPRESSION!\n");
    exit(1);
  }
}

void ppBIT_EXP(BIT_EXP p, int _i_)
{
  switch(p->kind)
  {
  case is_AAbit_exp:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_FACTOR(p->u.aabit_exp_.bit_factor_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABbit_exp:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_EXP(p->u.abbit_exp_.bit_exp_, 0);
    ppOR(p->u.abbit_exp_.or_, 0);
    ppBIT_FACTOR(p->u.abbit_exp_.bit_factor_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BIT_EXP!\n");
    exit(1);
  }
}

void ppBIT_FACTOR(BIT_FACTOR p, int _i_)
{
  switch(p->kind)
  {
  case is_AAbit_factor:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_CAT(p->u.aabit_factor_.bit_cat_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABbit_factor:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_FACTOR(p->u.abbit_factor_.bit_factor_, 0);
    ppAND(p->u.abbit_factor_.and_, 0);
    ppBIT_CAT(p->u.abbit_factor_.bit_cat_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BIT_FACTOR!\n");
    exit(1);
  }
}

void ppBIT_CAT(BIT_CAT p, int _i_)
{
  switch(p->kind)
  {
  case is_AAbit_cat:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_PRIM(p->u.aabit_cat_.bit_prim_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABbit_cat:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_CAT(p->u.abbit_cat_.bit_cat_, 0);
    ppCAT(p->u.abbit_cat_.cat_, 0);
    ppBIT_PRIM(p->u.abbit_cat_.bit_prim_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACbit_cat:
    if (_i_ > 0) renderC(_L_PAREN);
    ppNOT(p->u.acbit_cat_.not_, 0);
    ppBIT_PRIM(p->u.acbit_cat_.bit_prim_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADbit_cat:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_CAT(p->u.adbit_cat_.bit_cat_, 0);
    ppCAT(p->u.adbit_cat_.cat_, 0);
    ppNOT(p->u.adbit_cat_.not_, 0);
    ppBIT_PRIM(p->u.adbit_cat_.bit_prim_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BIT_CAT!\n");
    exit(1);
  }
}

void ppOR(OR p, int _i_)
{
  switch(p->kind)
  {
  case is_AAor:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_VERTICAL_BAR(p->u.aaor_.char_vertical_bar_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABor:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("OR");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing OR!\n");
    exit(1);
  }
}

void ppCHAR_VERTICAL_BAR(CHAR_VERTICAL_BAR p, int _i_)
{
  switch(p->kind)
  {
  case is_CFchar_vertical_bar:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('|');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing CHAR_VERTICAL_BAR!\n");
    exit(1);
  }
}

void ppAND(AND p, int _i_)
{
  switch(p->kind)
  {
  case is_AAand:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('&');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABand:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("AND");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing AND!\n");
    exit(1);
  }
}

void ppBIT_PRIM(BIT_PRIM p, int _i_)
{
  switch(p->kind)
  {
  case is_AAbitPrimBitVar:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_VAR(p->u.aabitprimbitvar_.bit_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABbitPrimLabelVar:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLABEL_VAR(p->u.abbitprimlabelvar_.label_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACbitPrimEventVar:
    if (_i_ > 0) renderC(_L_PAREN);
    ppEVENT_VAR(p->u.acbitprimeventvar_.event_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADbitBitConst:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_CONST(p->u.adbitbitconst_.bit_const_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEbitPrimBitExp:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('(');
    ppBIT_EXP(p->u.aebitprimbitexp_.bit_exp_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AHbitPrimSubbit:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSUBBIT_HEAD(p->u.ahbitprimsubbit_.subbit_head_, 0);
    ppEXPRESSION(p->u.ahbitprimsubbit_.expression_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AIbitPrimFunc:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_FUNC_HEAD(p->u.aibitprimfunc_.bit_func_head_, 0);
    renderC('(');
    ppCALL_LIST(p->u.aibitprimfunc_.call_list_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AAbitPrimBitVarBracketed:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('[');
    ppBIT_VAR(p->u.aabitprimbitvarbracketed_.bit_var_, 0);
    renderC(']');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABbitPrimBitVarBracketed:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('[');
    ppBIT_VAR(p->u.abbitprimbitvarbracketed_.bit_var_, 0);
    renderC(']');
    ppSUBSCRIPT(p->u.abbitprimbitvarbracketed_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AAbitPrimBitVarBraced:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('{');
    ppBIT_VAR(p->u.aabitprimbitvarbraced_.bit_var_, 0);
    renderC('}');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABbitPrimBitVarBraced:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('{');
    ppBIT_VAR(p->u.abbitprimbitvarbraced_.bit_var_, 0);
    renderC('}');
    ppSUBSCRIPT(p->u.abbitprimbitvarbraced_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BIT_PRIM!\n");
    exit(1);
  }
}

void ppCAT(CAT p, int _i_)
{
  switch(p->kind)
  {
  case is_AAcat:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("||");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABcat:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("CAT");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing CAT!\n");
    exit(1);
  }
}

void ppNOT(NOT p, int _i_)
{
  switch(p->kind)
  {
  case is_AAnot:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('\172');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABnot:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("NOT");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACnot:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('^');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADnot:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('~');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing NOT!\n");
    exit(1);
  }
}

void ppBIT_VAR(BIT_VAR p, int _i_)
{
  switch(p->kind)
  {
  case is_AAbit_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_ID(p->u.aabit_var_.bit_id_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACbit_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_ID(p->u.acbit_var_.bit_id_, 0);
    ppSUBSCRIPT(p->u.acbit_var_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABbit_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQUAL_STRUCT(p->u.abbit_var_.qual_struct_, 0);
    renderC('.');
    ppBIT_ID(p->u.abbit_var_.bit_id_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADbit_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQUAL_STRUCT(p->u.adbit_var_.qual_struct_, 0);
    renderC('.');
    ppBIT_ID(p->u.adbit_var_.bit_id_, 0);
    ppSUBSCRIPT(p->u.adbit_var_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BIT_VAR!\n");
    exit(1);
  }
}

void ppLABEL_VAR(LABEL_VAR p, int _i_)
{
  switch(p->kind)
  {
  case is_AAlabel_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLABEL(p->u.aalabel_var_.label_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABlabel_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLABEL(p->u.ablabel_var_.label_, 0);
    ppSUBSCRIPT(p->u.ablabel_var_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AClabel_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQUAL_STRUCT(p->u.aclabel_var_.qual_struct_, 0);
    renderC('.');
    ppLABEL(p->u.aclabel_var_.label_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADlabel_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQUAL_STRUCT(p->u.adlabel_var_.qual_struct_, 0);
    renderC('.');
    ppLABEL(p->u.adlabel_var_.label_, 0);
    ppSUBSCRIPT(p->u.adlabel_var_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing LABEL_VAR!\n");
    exit(1);
  }
}

void ppEVENT_VAR(EVENT_VAR p, int _i_)
{
  switch(p->kind)
  {
  case is_AAevent_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppEVENT(p->u.aaevent_var_.event_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACevent_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppEVENT(p->u.acevent_var_.event_, 0);
    ppSUBSCRIPT(p->u.acevent_var_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABevent_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQUAL_STRUCT(p->u.abevent_var_.qual_struct_, 0);
    renderC('.');
    ppEVENT(p->u.abevent_var_.event_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADevent_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQUAL_STRUCT(p->u.adevent_var_.qual_struct_, 0);
    renderC('.');
    ppEVENT(p->u.adevent_var_.event_, 0);
    ppSUBSCRIPT(p->u.adevent_var_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing EVENT_VAR!\n");
    exit(1);
  }
}

void ppBIT_CONST_HEAD(BIT_CONST_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAbit_const_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppRADIX(p->u.aabit_const_head_.radix_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABbit_const_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppRADIX(p->u.abbit_const_head_.radix_, 0);
    renderC('(');
    ppNUMBER(p->u.abbit_const_head_.number_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BIT_CONST_HEAD!\n");
    exit(1);
  }
}

void ppBIT_CONST(BIT_CONST p, int _i_)
{
  switch(p->kind)
  {
  case is_AAbitConstString:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_CONST_HEAD(p->u.aabitconststring_.bit_const_head_, 0);
    ppCHAR_STRING(p->u.aabitconststring_.char_string_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABbitConstTrue:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("TRUE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACbitConstFalse:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("FALSE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADbitConstOn:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ON");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEbitConstOff:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("OFF");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BIT_CONST!\n");
    exit(1);
  }
}

void ppRADIX(RADIX p, int _i_)
{
  switch(p->kind)
  {
  case is_AAradixHEX:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("HEX");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABradixOCT:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("OCT");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACradixBIN:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("BIN");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADradixDEC:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("DEC");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing RADIX!\n");
    exit(1);
  }
}

void ppCHAR_STRING(CHAR_STRING p, int _i_)
{
  switch(p->kind)
  {
  case is_FPchar_string:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.fpchar_string_.stringtoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing CHAR_STRING!\n");
    exit(1);
  }
}

void ppSUBBIT_HEAD(SUBBIT_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAsubbit_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSUBBIT_KEY(p->u.aasubbit_head_.subbit_key_, 0);
    renderC('(');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABsubbit_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSUBBIT_KEY(p->u.absubbit_head_.subbit_key_, 0);
    ppSUBSCRIPT(p->u.absubbit_head_.subscript_, 0);
    renderC('(');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing SUBBIT_HEAD!\n");
    exit(1);
  }
}

void ppSUBBIT_KEY(SUBBIT_KEY p, int _i_)
{
  switch(p->kind)
  {
  case is_AAsubbit_key:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("SUBBIT");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing SUBBIT_KEY!\n");
    exit(1);
  }
}

void ppBIT_FUNC_HEAD(BIT_FUNC_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAbit_func_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_FUNC(p->u.aabit_func_head_.bit_func_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABbit_func_head:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("BIT");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACbit_func_head:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("BIT");
    ppSUB_OR_QUALIFIER(p->u.acbit_func_head_.sub_or_qualifier_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BIT_FUNC_HEAD!\n");
    exit(1);
  }
}

void ppBIT_ID(BIT_ID p, int _i_)
{
  switch(p->kind)
  {
  case is_FHbit_id:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.fhbit_id_.bitidentifiertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BIT_ID!\n");
    exit(1);
  }
}

void ppLABEL(LABEL p, int _i_)
{
  switch(p->kind)
  {
  case is_FKlabel:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.fklabel_.labeltoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_FLlabel:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.fllabel_.bitfunctionidentifiertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_FMlabel:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.fmlabel_.charfunctionidentifiertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_FNlabel:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.fnlabel_.structfunctionidentifiertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing LABEL!\n");
    exit(1);
  }
}

void ppBIT_FUNC(BIT_FUNC p, int _i_)
{
  switch(p->kind)
  {
  case is_ZZxor:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("XOR");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZuserBitFunction:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.zzuserbitfunction_.bitfunctionidentifiertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BIT_FUNC!\n");
    exit(1);
  }
}

void ppEVENT(EVENT p, int _i_)
{
  switch(p->kind)
  {
  case is_FLevent:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.flevent_.eventtoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing EVENT!\n");
    exit(1);
  }
}

void ppSUB_OR_QUALIFIER(SUB_OR_QUALIFIER p, int _i_)
{
  switch(p->kind)
  {
  case is_AAsub_or_qualifier:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSUBSCRIPT(p->u.aasub_or_qualifier_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABsub_or_qualifier:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_QUALIFIER(p->u.absub_or_qualifier_.bit_qualifier_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing SUB_OR_QUALIFIER!\n");
    exit(1);
  }
}

void ppBIT_QUALIFIER(BIT_QUALIFIER p, int _i_)
{
  switch(p->kind)
  {
  case is_AAbit_qualifier:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('<');
    renderC('$');
    renderC('(');
    renderC('@');
    ppRADIX(p->u.aabit_qualifier_.radix_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BIT_QUALIFIER!\n");
    exit(1);
  }
}

void ppCHAR_EXP(CHAR_EXP p, int _i_)
{
  switch(p->kind)
  {
  case is_AAcharExpPrim:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_PRIM(p->u.aacharexpprim_.char_prim_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABcharExpCat:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_EXP(p->u.abcharexpcat_.char_exp_, 0);
    ppCAT(p->u.abcharexpcat_.cat_, 0);
    ppCHAR_PRIM(p->u.abcharexpcat_.char_prim_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACcharExpCat:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_EXP(p->u.accharexpcat_.char_exp_, 0);
    ppCAT(p->u.accharexpcat_.cat_, 0);
    ppARITH_EXP(p->u.accharexpcat_.arith_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADcharExpCat:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_EXP(p->u.adcharexpcat_.arith_exp_1, 0);
    ppCAT(p->u.adcharexpcat_.cat_, 0);
    ppARITH_EXP(p->u.adcharexpcat_.arith_exp_2, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEcharExpCat:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_EXP(p->u.aecharexpcat_.arith_exp_, 0);
    ppCAT(p->u.aecharexpcat_.cat_, 0);
    ppCHAR_PRIM(p->u.aecharexpcat_.char_prim_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing CHAR_EXP!\n");
    exit(1);
  }
}

void ppCHAR_PRIM(CHAR_PRIM p, int _i_)
{
  switch(p->kind)
  {
  case is_AAchar_prim:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_VAR(p->u.aachar_prim_.char_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABchar_prim:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_CONST(p->u.abchar_prim_.char_const_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEchar_prim:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_FUNC_HEAD(p->u.aechar_prim_.char_func_head_, 0);
    renderC('(');
    ppCALL_LIST(p->u.aechar_prim_.call_list_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AFchar_prim:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('(');
    ppCHAR_EXP(p->u.afchar_prim_.char_exp_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing CHAR_PRIM!\n");
    exit(1);
  }
}

void ppCHAR_FUNC_HEAD(CHAR_FUNC_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAchar_func_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_FUNC(p->u.aachar_func_head_.char_func_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABchar_func_head:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("CHARACTER");
    ppSUB_OR_QUALIFIER(p->u.abchar_func_head_.sub_or_qualifier_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing CHAR_FUNC_HEAD!\n");
    exit(1);
  }
}

void ppCHAR_VAR(CHAR_VAR p, int _i_)
{
  switch(p->kind)
  {
  case is_AAchar_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_ID(p->u.aachar_var_.char_id_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACchar_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_ID(p->u.acchar_var_.char_id_, 0);
    ppSUBSCRIPT(p->u.acchar_var_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABchar_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQUAL_STRUCT(p->u.abchar_var_.qual_struct_, 0);
    renderC('.');
    ppCHAR_ID(p->u.abchar_var_.char_id_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADchar_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQUAL_STRUCT(p->u.adchar_var_.qual_struct_, 0);
    renderC('.');
    ppCHAR_ID(p->u.adchar_var_.char_id_, 0);
    ppSUBSCRIPT(p->u.adchar_var_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing CHAR_VAR!\n");
    exit(1);
  }
}

void ppCHAR_CONST(CHAR_CONST p, int _i_)
{
  switch(p->kind)
  {
  case is_AAchar_const:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_STRING(p->u.aachar_const_.char_string_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABchar_const:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("CHAR");
    renderC('(');
    ppNUMBER(p->u.abchar_const_.number_, 0);
    renderC(')');
    ppCHAR_STRING(p->u.abchar_const_.char_string_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing CHAR_CONST!\n");
    exit(1);
  }
}

void ppCHAR_FUNC(CHAR_FUNC p, int _i_)
{
  switch(p->kind)
  {
  case is_ZZljust:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("LJUST");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZrjust:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("RJUST");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZtrim:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("TRIM");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ZZuserCharFunction:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.zzusercharfunction_.charfunctionidentifiertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AAcharFuncCharacter:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("CHARACTER");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing CHAR_FUNC!\n");
    exit(1);
  }
}

void ppCHAR_ID(CHAR_ID p, int _i_)
{
  switch(p->kind)
  {
  case is_FIchar_id:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.fichar_id_.charidentifiertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing CHAR_ID!\n");
    exit(1);
  }
}

void ppNAME_EXP(NAME_EXP p, int _i_)
{
  switch(p->kind)
  {
  case is_AAnameExpKeyVar:
    if (_i_ > 0) renderC(_L_PAREN);
    ppNAME_KEY(p->u.aanameexpkeyvar_.name_key_, 0);
    renderC('(');
    ppNAME_VAR(p->u.aanameexpkeyvar_.name_var_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABnameExpNull:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("NULL");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACnameExpKeyNull:
    if (_i_ > 0) renderC(_L_PAREN);
    ppNAME_KEY(p->u.acnameexpkeynull_.name_key_, 0);
    renderC('(');
    renderS("NULL");
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing NAME_EXP!\n");
    exit(1);
  }
}

void ppNAME_KEY(NAME_KEY p, int _i_)
{
  switch(p->kind)
  {
  case is_AAname_key:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("NAME");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing NAME_KEY!\n");
    exit(1);
  }
}

void ppNAME_VAR(NAME_VAR p, int _i_)
{
  switch(p->kind)
  {
  case is_AAname_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppVARIABLE(p->u.aaname_var_.variable_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACname_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppMODIFIED_ARITH_FUNC(p->u.acname_var_.modified_arith_func_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABname_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLABEL_VAR(p->u.abname_var_.label_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing NAME_VAR!\n");
    exit(1);
  }
}

void ppVARIABLE(VARIABLE p, int _i_)
{
  switch(p->kind)
  {
  case is_AAvariable:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_VAR(p->u.aavariable_.arith_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACvariable:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_VAR(p->u.acvariable_.bit_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEvariable:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSUBBIT_HEAD(p->u.aevariable_.subbit_head_, 0);
    ppVARIABLE(p->u.aevariable_.variable_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AFvariable:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_VAR(p->u.afvariable_.char_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AGvariable:
    if (_i_ > 0) renderC(_L_PAREN);
    ppNAME_KEY(p->u.agvariable_.name_key_, 0);
    renderC('(');
    ppNAME_VAR(p->u.agvariable_.name_var_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADvariable:
    if (_i_ > 0) renderC(_L_PAREN);
    ppEVENT_VAR(p->u.advariable_.event_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABvariable:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTRUCTURE_VAR(p->u.abvariable_.structure_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing VARIABLE!\n");
    exit(1);
  }
}

void ppSTRUCTURE_EXP(STRUCTURE_EXP p, int _i_)
{
  switch(p->kind)
  {
  case is_AAstructure_exp:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTRUCTURE_VAR(p->u.aastructure_exp_.structure_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADstructure_exp:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTRUCT_FUNC_HEAD(p->u.adstructure_exp_.struct_func_head_, 0);
    renderC('(');
    ppCALL_LIST(p->u.adstructure_exp_.call_list_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACstructure_exp:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTRUC_INLINE_DEF(p->u.acstructure_exp_.struc_inline_def_, 0);
    ppCLOSING(p->u.acstructure_exp_.closing_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEstructure_exp:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTRUC_INLINE_DEF(p->u.aestructure_exp_.struc_inline_def_, 0);
    ppBLOCK_BODY(p->u.aestructure_exp_.block_body_, 0);
    ppCLOSING(p->u.aestructure_exp_.closing_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing STRUCTURE_EXP!\n");
    exit(1);
  }
}

void ppSTRUCT_FUNC_HEAD(STRUCT_FUNC_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAstruct_func_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTRUCT_FUNC(p->u.aastruct_func_head_.struct_func_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing STRUCT_FUNC_HEAD!\n");
    exit(1);
  }
}

void ppSTRUCTURE_VAR(STRUCTURE_VAR p, int _i_)
{
  switch(p->kind)
  {
  case is_AAstructure_var:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQUAL_STRUCT(p->u.aastructure_var_.qual_struct_, 0);
    ppSUBSCRIPT(p->u.aastructure_var_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing STRUCTURE_VAR!\n");
    exit(1);
  }
}

void ppSTRUCT_FUNC(STRUCT_FUNC p, int _i_)
{
  switch(p->kind)
  {
  case is_ZZuserStructFunc:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.zzuserstructfunc_.structfunctionidentifiertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing STRUCT_FUNC!\n");
    exit(1);
  }
}

void ppQUAL_STRUCT(QUAL_STRUCT p, int _i_)
{
  switch(p->kind)
  {
  case is_AAqual_struct:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTRUCTURE_ID(p->u.aaqual_struct_.structure_id_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABqual_struct:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQUAL_STRUCT(p->u.abqual_struct_.qual_struct_, 0);
    renderC('.');
    ppSTRUCTURE_ID(p->u.abqual_struct_.structure_id_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing QUAL_STRUCT!\n");
    exit(1);
  }
}

void ppSTRUCTURE_ID(STRUCTURE_ID p, int _i_)
{
  switch(p->kind)
  {
  case is_FJstructure_id:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.fjstructure_id_.structidentifiertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing STRUCTURE_ID!\n");
    exit(1);
  }
}

void ppASSIGNMENT(ASSIGNMENT p, int _i_)
{
  switch(p->kind)
  {
  case is_AAassignment:
    if (_i_ > 0) renderC(_L_PAREN);
    ppVARIABLE(p->u.aaassignment_.variable_, 0);
    ppEQUALS(p->u.aaassignment_.equals_, 0);
    ppEXPRESSION(p->u.aaassignment_.expression_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABassignment:
    if (_i_ > 0) renderC(_L_PAREN);
    ppVARIABLE(p->u.abassignment_.variable_, 0);
    renderC(',');
    ppASSIGNMENT(p->u.abassignment_.assignment_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACassignment:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQUAL_STRUCT(p->u.acassignment_.qual_struct_, 0);
    ppEQUALS(p->u.acassignment_.equals_, 0);
    ppEXPRESSION(p->u.acassignment_.expression_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADassignment:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQUAL_STRUCT(p->u.adassignment_.qual_struct_, 0);
    renderC(',');
    ppASSIGNMENT(p->u.adassignment_.assignment_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ASSIGNMENT!\n");
    exit(1);
  }
}

void ppEQUALS(EQUALS p, int _i_)
{
  switch(p->kind)
  {
  case is_AAequals:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('=');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing EQUALS!\n");
    exit(1);
  }
}

void ppIF_STATEMENT(IF_STATEMENT p, int _i_)
{
  switch(p->kind)
  {
  case is_AAifStatement:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIF_CLAUSE(p->u.aaifstatement_.if_clause_, 0);
    ppSTATEMENT(p->u.aaifstatement_.statement_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABifThenElseStatement:
    if (_i_ > 0) renderC(_L_PAREN);
    ppTRUE_PART(p->u.abifthenelsestatement_.true_part_, 0);
    ppSTATEMENT(p->u.abifthenelsestatement_.statement_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing IF_STATEMENT!\n");
    exit(1);
  }
}

void ppIF_CLAUSE(IF_CLAUSE p, int _i_)
{
  switch(p->kind)
  {
  case is_AAif_clause:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIF(p->u.aaif_clause_.if_, 0);
    ppRELATIONAL_EXP(p->u.aaif_clause_.relational_exp_, 0);
    ppTHEN(p->u.aaif_clause_.then_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABif_clause:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIF(p->u.abif_clause_.if_, 0);
    ppBIT_EXP(p->u.abif_clause_.bit_exp_, 0);
    ppTHEN(p->u.abif_clause_.then_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing IF_CLAUSE!\n");
    exit(1);
  }
}

void ppTRUE_PART(TRUE_PART p, int _i_)
{
  switch(p->kind)
  {
  case is_AAtrue_part:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIF_CLAUSE(p->u.aatrue_part_.if_clause_, 0);
    ppBASIC_STATEMENT(p->u.aatrue_part_.basic_statement_, 0);
    renderS("ELSE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing TRUE_PART!\n");
    exit(1);
  }
}

void ppIF(IF p, int _i_)
{
  switch(p->kind)
  {
  case is_AAif:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("IF");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing IF!\n");
    exit(1);
  }
}

void ppTHEN(THEN p, int _i_)
{
  switch(p->kind)
  {
  case is_AAthen:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("THEN");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing THEN!\n");
    exit(1);
  }
}

void ppRELATIONAL_EXP(RELATIONAL_EXP p, int _i_)
{
  switch(p->kind)
  {
  case is_AArelational_exp:
    if (_i_ > 0) renderC(_L_PAREN);
    ppRELATIONAL_FACTOR(p->u.aarelational_exp_.relational_factor_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABrelational_exp:
    if (_i_ > 0) renderC(_L_PAREN);
    ppRELATIONAL_EXP(p->u.abrelational_exp_.relational_exp_, 0);
    ppOR(p->u.abrelational_exp_.or_, 0);
    ppRELATIONAL_FACTOR(p->u.abrelational_exp_.relational_factor_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing RELATIONAL_EXP!\n");
    exit(1);
  }
}

void ppRELATIONAL_FACTOR(RELATIONAL_FACTOR p, int _i_)
{
  switch(p->kind)
  {
  case is_AArelational_factor:
    if (_i_ > 0) renderC(_L_PAREN);
    ppREL_PRIM(p->u.aarelational_factor_.rel_prim_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABrelational_factor:
    if (_i_ > 0) renderC(_L_PAREN);
    ppRELATIONAL_FACTOR(p->u.abrelational_factor_.relational_factor_, 0);
    ppAND(p->u.abrelational_factor_.and_, 0);
    ppREL_PRIM(p->u.abrelational_factor_.rel_prim_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing RELATIONAL_FACTOR!\n");
    exit(1);
  }
}

void ppREL_PRIM(REL_PRIM p, int _i_)
{
  switch(p->kind)
  {
  case is_AArel_prim:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('(');
    ppRELATIONAL_EXP(p->u.aarel_prim_.relational_exp_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABrel_prim:
    if (_i_ > 0) renderC(_L_PAREN);
    ppNOT(p->u.abrel_prim_.not_, 0);
    renderC('(');
    ppRELATIONAL_EXP(p->u.abrel_prim_.relational_exp_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACrel_prim:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCOMPARISON(p->u.acrel_prim_.comparison_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing REL_PRIM!\n");
    exit(1);
  }
}

void ppCOMPARISON(COMPARISON p, int _i_)
{
  switch(p->kind)
  {
  case is_AAcomparison:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_EXP(p->u.aacomparison_.arith_exp_1, 0);
    ppRELATIONAL_OP(p->u.aacomparison_.relational_op_, 0);
    ppARITH_EXP(p->u.aacomparison_.arith_exp_2, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABcomparison:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_EXP(p->u.abcomparison_.char_exp_1, 0);
    ppRELATIONAL_OP(p->u.abcomparison_.relational_op_, 0);
    ppCHAR_EXP(p->u.abcomparison_.char_exp_2, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACcomparison:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_CAT(p->u.accomparison_.bit_cat_1, 0);
    ppRELATIONAL_OP(p->u.accomparison_.relational_op_, 0);
    ppBIT_CAT(p->u.accomparison_.bit_cat_2, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADcomparison:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTRUCTURE_EXP(p->u.adcomparison_.structure_exp_1, 0);
    ppRELATIONAL_OP(p->u.adcomparison_.relational_op_, 0);
    ppSTRUCTURE_EXP(p->u.adcomparison_.structure_exp_2, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEcomparison:
    if (_i_ > 0) renderC(_L_PAREN);
    ppNAME_EXP(p->u.aecomparison_.name_exp_1, 0);
    ppRELATIONAL_OP(p->u.aecomparison_.relational_op_, 0);
    ppNAME_EXP(p->u.aecomparison_.name_exp_2, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing COMPARISON!\n");
    exit(1);
  }
}

void ppRELATIONAL_OP(RELATIONAL_OP p, int _i_)
{
  switch(p->kind)
  {
  case is_AArelationalOpEQ:
    if (_i_ > 0) renderC(_L_PAREN);
    ppEQUALS(p->u.aarelationalopeq_.equals_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABrelationalOpNEQ:
    if (_i_ > 0) renderC(_L_PAREN);
    ppNOT(p->u.abrelationalopneq_.not_, 0);
    ppEQUALS(p->u.abrelationalopneq_.equals_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACrelationalOpLT:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('<');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADrelationalOpGT:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('>');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AErelationalOpLE:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("<=");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AFrelationalOpGE:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS(">=");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AGrelationalOpNLT:
    if (_i_ > 0) renderC(_L_PAREN);
    ppNOT(p->u.agrelationalopnlt_.not_, 0);
    renderC('<');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AHrelationalOpNGT:
    if (_i_ > 0) renderC(_L_PAREN);
    ppNOT(p->u.ahrelationalopngt_.not_, 0);
    renderC('>');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing RELATIONAL_OP!\n");
    exit(1);
  }
}

void ppSTATEMENT(STATEMENT p, int _i_)
{
  switch(p->kind)
  {
  case is_AAstatement:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBASIC_STATEMENT(p->u.aastatement_.basic_statement_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABstatement:
    if (_i_ > 0) renderC(_L_PAREN);
    ppOTHER_STATEMENT(p->u.abstatement_.other_statement_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AZstatement:
    if (_i_ > 0) renderC(_L_PAREN);
    ppINLINE_DEFINITION(p->u.azstatement_.inline_definition_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing STATEMENT!\n");
    exit(1);
  }
}

void ppBASIC_STATEMENT(BASIC_STATEMENT p, int _i_)
{
  switch(p->kind)
  {
  case is_ABbasicStatementAssignment:
    if (_i_ > 0) renderC(_L_PAREN);
    ppASSIGNMENT(p->u.abbasicstatementassignment_.assignment_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AAbasic_statement:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLABEL_DEFINITION(p->u.aabasic_statement_.label_definition_, 0);
    ppBASIC_STATEMENT(p->u.aabasic_statement_.basic_statement_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACbasicStatementExit:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("EXIT");
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADbasicStatementExit:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("EXIT");
    ppLABEL(p->u.adbasicstatementexit_.label_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEbasicStatementRepeat:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("REPEAT");
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AFbasicStatementRepeat:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("REPEAT");
    ppLABEL(p->u.afbasicstatementrepeat_.label_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AGbasicStatementGoTo:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("GO");
    renderS("TO");
    ppLABEL(p->u.agbasicstatementgoto_.label_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AHbasicStatementEmpty:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AIbasicStatementCall:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCALL_KEY(p->u.aibasicstatementcall_.call_key_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AJbasicStatementCall:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCALL_KEY(p->u.ajbasicstatementcall_.call_key_, 0);
    renderC('(');
    ppCALL_LIST(p->u.ajbasicstatementcall_.call_list_, 0);
    renderC(')');
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AKbasicStatementCall:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCALL_KEY(p->u.akbasicstatementcall_.call_key_, 0);
    ppASSIGN(p->u.akbasicstatementcall_.assign_, 0);
    renderC('(');
    ppCALL_ASSIGN_LIST(p->u.akbasicstatementcall_.call_assign_list_, 0);
    renderC(')');
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ALbasicStatementCall:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCALL_KEY(p->u.albasicstatementcall_.call_key_, 0);
    renderC('(');
    ppCALL_LIST(p->u.albasicstatementcall_.call_list_, 0);
    renderC(')');
    ppASSIGN(p->u.albasicstatementcall_.assign_, 0);
    renderC('(');
    ppCALL_ASSIGN_LIST(p->u.albasicstatementcall_.call_assign_list_, 0);
    renderC(')');
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AMbasicStatementReturn:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("RETURN");
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ANbasicStatementReturn:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("RETURN");
    ppEXPRESSION(p->u.anbasicstatementreturn_.expression_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AObasicStatementDo:
    if (_i_ > 0) renderC(_L_PAREN);
    ppDO_GROUP_HEAD(p->u.aobasicstatementdo_.do_group_head_, 0);
    ppENDING(p->u.aobasicstatementdo_.ending_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_APbasicStatementReadKey:
    if (_i_ > 0) renderC(_L_PAREN);
    ppREAD_KEY(p->u.apbasicstatementreadkey_.read_key_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AQbasicStatementReadPhrase:
    if (_i_ > 0) renderC(_L_PAREN);
    ppREAD_PHRASE(p->u.aqbasicstatementreadphrase_.read_phrase_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ARbasicStatementWriteKey:
    if (_i_ > 0) renderC(_L_PAREN);
    ppWRITE_KEY(p->u.arbasicstatementwritekey_.write_key_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ASbasicStatementWritePhrase:
    if (_i_ > 0) renderC(_L_PAREN);
    ppWRITE_PHRASE(p->u.asbasicstatementwritephrase_.write_phrase_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ATbasicStatementFileExp:
    if (_i_ > 0) renderC(_L_PAREN);
    ppFILE_EXP(p->u.atbasicstatementfileexp_.file_exp_, 0);
    ppEQUALS(p->u.atbasicstatementfileexp_.equals_, 0);
    ppEXPRESSION(p->u.atbasicstatementfileexp_.expression_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AUbasicStatementFileExp:
    if (_i_ > 0) renderC(_L_PAREN);
    ppVARIABLE(p->u.aubasicstatementfileexp_.variable_, 0);
    ppEQUALS(p->u.aubasicstatementfileexp_.equals_, 0);
    ppFILE_EXP(p->u.aubasicstatementfileexp_.file_exp_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AVbasicStatementFileExp:
    if (_i_ > 0) renderC(_L_PAREN);
    ppFILE_EXP(p->u.avbasicstatementfileexp_.file_exp_, 0);
    ppEQUALS(p->u.avbasicstatementfileexp_.equals_, 0);
    ppQUAL_STRUCT(p->u.avbasicstatementfileexp_.qual_struct_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AVbasicStatementWait:
    if (_i_ > 0) renderC(_L_PAREN);
    ppWAIT_KEY(p->u.avbasicstatementwait_.wait_key_, 0);
    renderS("FOR");
    renderS("DEPENDENT");
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AWbasicStatementWait:
    if (_i_ > 0) renderC(_L_PAREN);
    ppWAIT_KEY(p->u.awbasicstatementwait_.wait_key_, 0);
    ppARITH_EXP(p->u.awbasicstatementwait_.arith_exp_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AXbasicStatementWait:
    if (_i_ > 0) renderC(_L_PAREN);
    ppWAIT_KEY(p->u.axbasicstatementwait_.wait_key_, 0);
    renderS("UNTIL");
    ppARITH_EXP(p->u.axbasicstatementwait_.arith_exp_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AYbasicStatementWait:
    if (_i_ > 0) renderC(_L_PAREN);
    ppWAIT_KEY(p->u.aybasicstatementwait_.wait_key_, 0);
    renderS("FOR");
    ppBIT_EXP(p->u.aybasicstatementwait_.bit_exp_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AZbasicStatementTerminator:
    if (_i_ > 0) renderC(_L_PAREN);
    ppTERMINATOR(p->u.azbasicstatementterminator_.terminator_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_BAbasicStatementTerminator:
    if (_i_ > 0) renderC(_L_PAREN);
    ppTERMINATOR(p->u.babasicstatementterminator_.terminator_, 0);
    ppTERMINATE_LIST(p->u.babasicstatementterminator_.terminate_list_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_BBbasicStatementUpdate:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("UPDATE");
    renderS("PRIORITY");
    renderS("TO");
    ppARITH_EXP(p->u.bbbasicstatementupdate_.arith_exp_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_BCbasicStatementUpdate:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("UPDATE");
    renderS("PRIORITY");
    ppLABEL_VAR(p->u.bcbasicstatementupdate_.label_var_, 0);
    renderS("TO");
    ppARITH_EXP(p->u.bcbasicstatementupdate_.arith_exp_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_BDbasicStatementSchedule:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSCHEDULE_PHRASE(p->u.bdbasicstatementschedule_.schedule_phrase_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_BEbasicStatementSchedule:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSCHEDULE_PHRASE(p->u.bebasicstatementschedule_.schedule_phrase_, 0);
    ppSCHEDULE_CONTROL(p->u.bebasicstatementschedule_.schedule_control_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_BFbasicStatementSignal:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSIGNAL_CLAUSE(p->u.bfbasicstatementsignal_.signal_clause_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_BGbasicStatementSend:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("SEND");
    renderS("ERROR");
    ppSUBSCRIPT(p->u.bgbasicstatementsend_.subscript_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_BHbasicStatementSend:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("SEND");
    renderS("ERROR");
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_BHbasicStatementOn:
    if (_i_ > 0) renderC(_L_PAREN);
    ppON_CLAUSE(p->u.bhbasicstatementon_.on_clause_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_BIbasicStatementOnAndSignal:
    if (_i_ > 0) renderC(_L_PAREN);
    ppON_CLAUSE(p->u.bibasicstatementonandsignal_.on_clause_, 0);
    renderS("AND");
    ppSIGNAL_CLAUSE(p->u.bibasicstatementonandsignal_.signal_clause_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_BJbasicStatementOff:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("OFF");
    renderS("ERROR");
    ppSUBSCRIPT(p->u.bjbasicstatementoff_.subscript_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_BKbasicStatementOff:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("OFF");
    renderS("ERROR");
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_BKbasicStatementPercentMacro:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPERCENT_MACRO_NAME(p->u.bkbasicstatementpercentmacro_.percent_macro_name_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_BLbasicStatementPercentMacro:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPERCENT_MACRO_HEAD(p->u.blbasicstatementpercentmacro_.percent_macro_head_, 0);
    ppPERCENT_MACRO_ARG(p->u.blbasicstatementpercentmacro_.percent_macro_arg_, 0);
    renderC(')');
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BASIC_STATEMENT!\n");
    exit(1);
  }
}

void ppOTHER_STATEMENT(OTHER_STATEMENT p, int _i_)
{
  switch(p->kind)
  {
  case is_ABotherStatementIf:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIF_STATEMENT(p->u.abotherstatementif_.if_statement_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AAotherStatementOn:
    if (_i_ > 0) renderC(_L_PAREN);
    ppON_PHRASE(p->u.aaotherstatementon_.on_phrase_, 0);
    ppSTATEMENT(p->u.aaotherstatementon_.statement_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACother_statement:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLABEL_DEFINITION(p->u.acother_statement_.label_definition_, 0);
    ppOTHER_STATEMENT(p->u.acother_statement_.other_statement_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing OTHER_STATEMENT!\n");
    exit(1);
  }
}

void ppANY_STATEMENT(ANY_STATEMENT p, int _i_)
{
  switch(p->kind)
  {
  case is_AAany_statement:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTATEMENT(p->u.aaany_statement_.statement_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABany_statement:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBLOCK_DEFINITION(p->u.abany_statement_.block_definition_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ANY_STATEMENT!\n");
    exit(1);
  }
}

void ppON_PHRASE(ON_PHRASE p, int _i_)
{
  switch(p->kind)
  {
  case is_AAon_phrase:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ON");
    renderS("ERROR");
    ppSUBSCRIPT(p->u.aaon_phrase_.subscript_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACon_phrase:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ON");
    renderS("ERROR");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ON_PHRASE!\n");
    exit(1);
  }
}

void ppON_CLAUSE(ON_CLAUSE p, int _i_)
{
  switch(p->kind)
  {
  case is_AAon_clause:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ON");
    renderS("ERROR");
    ppSUBSCRIPT(p->u.aaon_clause_.subscript_, 0);
    renderS("SYSTEM");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABon_clause:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ON");
    renderS("ERROR");
    ppSUBSCRIPT(p->u.abon_clause_.subscript_, 0);
    renderS("IGNORE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADon_clause:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ON");
    renderS("ERROR");
    renderS("SYSTEM");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEon_clause:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ON");
    renderS("ERROR");
    renderS("IGNORE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ON_CLAUSE!\n");
    exit(1);
  }
}

void ppLABEL_DEFINITION(LABEL_DEFINITION p, int _i_)
{
  switch(p->kind)
  {
  case is_AAlabel_definition:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLABEL(p->u.aalabel_definition_.label_, 0);
    renderC(':');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing LABEL_DEFINITION!\n");
    exit(1);
  }
}

void ppCALL_KEY(CALL_KEY p, int _i_)
{
  switch(p->kind)
  {
  case is_AAcall_key:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("CALL");
    ppLABEL_VAR(p->u.aacall_key_.label_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing CALL_KEY!\n");
    exit(1);
  }
}

void ppASSIGN(ASSIGN p, int _i_)
{
  switch(p->kind)
  {
  case is_AAassign:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ASSIGN");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ASSIGN!\n");
    exit(1);
  }
}

void ppCALL_ASSIGN_LIST(CALL_ASSIGN_LIST p, int _i_)
{
  switch(p->kind)
  {
  case is_AAcall_assign_list:
    if (_i_ > 0) renderC(_L_PAREN);
    ppVARIABLE(p->u.aacall_assign_list_.variable_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABcall_assign_list:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCALL_ASSIGN_LIST(p->u.abcall_assign_list_.call_assign_list_, 0);
    renderC(',');
    ppVARIABLE(p->u.abcall_assign_list_.variable_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACcall_assign_list:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQUAL_STRUCT(p->u.accall_assign_list_.qual_struct_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADcall_assign_list:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCALL_ASSIGN_LIST(p->u.adcall_assign_list_.call_assign_list_, 0);
    renderC(',');
    ppQUAL_STRUCT(p->u.adcall_assign_list_.qual_struct_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing CALL_ASSIGN_LIST!\n");
    exit(1);
  }
}

void ppDO_GROUP_HEAD(DO_GROUP_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAdoGroupHead:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("DO");
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABdoGroupHeadFor:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("DO");
    ppFOR_LIST(p->u.abdogroupheadfor_.for_list_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACdoGroupHeadForWhile:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("DO");
    ppFOR_LIST(p->u.acdogroupheadforwhile_.for_list_, 0);
    ppWHILE_CLAUSE(p->u.acdogroupheadforwhile_.while_clause_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADdoGroupHeadWhile:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("DO");
    ppWHILE_CLAUSE(p->u.addogroupheadwhile_.while_clause_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEdoGroupHeadCase:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("DO");
    renderS("CASE");
    ppARITH_EXP(p->u.aedogroupheadcase_.arith_exp_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AFdoGroupHeadCaseElse:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCASE_ELSE(p->u.afdogroupheadcaseelse_.case_else_, 0);
    ppSTATEMENT(p->u.afdogroupheadcaseelse_.statement_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AGdoGroupHeadStatement:
    if (_i_ > 0) renderC(_L_PAREN);
    ppDO_GROUP_HEAD(p->u.agdogroupheadstatement_.do_group_head_, 0);
    ppANY_STATEMENT(p->u.agdogroupheadstatement_.any_statement_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AHdoGroupHeadTemporaryStatement:
    if (_i_ > 0) renderC(_L_PAREN);
    ppDO_GROUP_HEAD(p->u.ahdogroupheadtemporarystatement_.do_group_head_, 0);
    ppTEMPORARY_STMT(p->u.ahdogroupheadtemporarystatement_.temporary_stmt_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing DO_GROUP_HEAD!\n");
    exit(1);
  }
}

void ppENDING(ENDING p, int _i_)
{
  switch(p->kind)
  {
  case is_AAending:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("END");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABending:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("END");
    ppLABEL(p->u.abending_.label_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACending:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLABEL_DEFINITION(p->u.acending_.label_definition_, 0);
    ppENDING(p->u.acending_.ending_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ENDING!\n");
    exit(1);
  }
}

void ppREAD_KEY(READ_KEY p, int _i_)
{
  switch(p->kind)
  {
  case is_AAread_key:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("READ");
    renderC('(');
    ppNUMBER(p->u.aaread_key_.number_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABread_key:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("READALL");
    renderC('(');
    ppNUMBER(p->u.abread_key_.number_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing READ_KEY!\n");
    exit(1);
  }
}

void ppWRITE_KEY(WRITE_KEY p, int _i_)
{
  switch(p->kind)
  {
  case is_AAwrite_key:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("WRITE");
    renderC('(');
    ppNUMBER(p->u.aawrite_key_.number_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing WRITE_KEY!\n");
    exit(1);
  }
}

void ppREAD_PHRASE(READ_PHRASE p, int _i_)
{
  switch(p->kind)
  {
  case is_AAread_phrase:
    if (_i_ > 0) renderC(_L_PAREN);
    ppREAD_KEY(p->u.aaread_phrase_.read_key_, 0);
    ppREAD_ARG(p->u.aaread_phrase_.read_arg_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABread_phrase:
    if (_i_ > 0) renderC(_L_PAREN);
    ppREAD_PHRASE(p->u.abread_phrase_.read_phrase_, 0);
    renderC(',');
    ppREAD_ARG(p->u.abread_phrase_.read_arg_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing READ_PHRASE!\n");
    exit(1);
  }
}

void ppWRITE_PHRASE(WRITE_PHRASE p, int _i_)
{
  switch(p->kind)
  {
  case is_AAwrite_phrase:
    if (_i_ > 0) renderC(_L_PAREN);
    ppWRITE_KEY(p->u.aawrite_phrase_.write_key_, 0);
    ppWRITE_ARG(p->u.aawrite_phrase_.write_arg_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABwrite_phrase:
    if (_i_ > 0) renderC(_L_PAREN);
    ppWRITE_PHRASE(p->u.abwrite_phrase_.write_phrase_, 0);
    renderC(',');
    ppWRITE_ARG(p->u.abwrite_phrase_.write_arg_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing WRITE_PHRASE!\n");
    exit(1);
  }
}

void ppREAD_ARG(READ_ARG p, int _i_)
{
  switch(p->kind)
  {
  case is_AAread_arg:
    if (_i_ > 0) renderC(_L_PAREN);
    ppVARIABLE(p->u.aaread_arg_.variable_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABread_arg:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIO_CONTROL(p->u.abread_arg_.io_control_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing READ_ARG!\n");
    exit(1);
  }
}

void ppWRITE_ARG(WRITE_ARG p, int _i_)
{
  switch(p->kind)
  {
  case is_AAwrite_arg:
    if (_i_ > 0) renderC(_L_PAREN);
    ppEXPRESSION(p->u.aawrite_arg_.expression_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABwrite_arg:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIO_CONTROL(p->u.abwrite_arg_.io_control_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACwrite_arg:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.acwrite_arg_.structidentifiertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing WRITE_ARG!\n");
    exit(1);
  }
}

void ppFILE_EXP(FILE_EXP p, int _i_)
{
  switch(p->kind)
  {
  case is_AAfile_exp:
    if (_i_ > 0) renderC(_L_PAREN);
    ppFILE_HEAD(p->u.aafile_exp_.file_head_, 0);
    renderC(',');
    ppARITH_EXP(p->u.aafile_exp_.arith_exp_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing FILE_EXP!\n");
    exit(1);
  }
}

void ppFILE_HEAD(FILE_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAfile_head:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("FILE");
    renderC('(');
    ppNUMBER(p->u.aafile_head_.number_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing FILE_HEAD!\n");
    exit(1);
  }
}

void ppIO_CONTROL(IO_CONTROL p, int _i_)
{
  switch(p->kind)
  {
  case is_AAioControlSkip:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("SKIP");
    renderC('(');
    ppARITH_EXP(p->u.aaiocontrolskip_.arith_exp_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABioControlTab:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("TAB");
    renderC('(');
    ppARITH_EXP(p->u.abiocontroltab_.arith_exp_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACioControlColumn:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("COLUMN");
    renderC('(');
    ppARITH_EXP(p->u.aciocontrolcolumn_.arith_exp_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADioControlLine:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("LINE");
    renderC('(');
    ppARITH_EXP(p->u.adiocontrolline_.arith_exp_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEioControlPage:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("PAGE");
    renderC('(');
    ppARITH_EXP(p->u.aeiocontrolpage_.arith_exp_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing IO_CONTROL!\n");
    exit(1);
  }
}

void ppWAIT_KEY(WAIT_KEY p, int _i_)
{
  switch(p->kind)
  {
  case is_AAwait_key:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("WAIT");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing WAIT_KEY!\n");
    exit(1);
  }
}

void ppTERMINATOR(TERMINATOR p, int _i_)
{
  switch(p->kind)
  {
  case is_AAterminatorTerminate:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("TERMINATE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABterminatorCancel:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("CANCEL");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing TERMINATOR!\n");
    exit(1);
  }
}

void ppTERMINATE_LIST(TERMINATE_LIST p, int _i_)
{
  switch(p->kind)
  {
  case is_AAterminate_list:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLABEL_VAR(p->u.aaterminate_list_.label_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABterminate_list:
    if (_i_ > 0) renderC(_L_PAREN);
    ppTERMINATE_LIST(p->u.abterminate_list_.terminate_list_, 0);
    renderC(',');
    ppLABEL_VAR(p->u.abterminate_list_.label_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing TERMINATE_LIST!\n");
    exit(1);
  }
}

void ppSCHEDULE_HEAD(SCHEDULE_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAscheduleHeadLabel:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("SCHEDULE");
    ppLABEL_VAR(p->u.aascheduleheadlabel_.label_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABscheduleHeadAt:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSCHEDULE_HEAD(p->u.abscheduleheadat_.schedule_head_, 0);
    renderS("AT");
    ppARITH_EXP(p->u.abscheduleheadat_.arith_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACscheduleHeadIn:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSCHEDULE_HEAD(p->u.acscheduleheadin_.schedule_head_, 0);
    renderS("IN");
    ppARITH_EXP(p->u.acscheduleheadin_.arith_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADscheduleHeadOn:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSCHEDULE_HEAD(p->u.adscheduleheadon_.schedule_head_, 0);
    renderS("ON");
    ppBIT_EXP(p->u.adscheduleheadon_.bit_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing SCHEDULE_HEAD!\n");
    exit(1);
  }
}

void ppSCHEDULE_PHRASE(SCHEDULE_PHRASE p, int _i_)
{
  switch(p->kind)
  {
  case is_AAschedule_phrase:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSCHEDULE_HEAD(p->u.aaschedule_phrase_.schedule_head_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABschedule_phrase:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSCHEDULE_HEAD(p->u.abschedule_phrase_.schedule_head_, 0);
    renderS("PRIORITY");
    renderC('(');
    ppARITH_EXP(p->u.abschedule_phrase_.arith_exp_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACschedule_phrase:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSCHEDULE_PHRASE(p->u.acschedule_phrase_.schedule_phrase_, 0);
    renderS("DEPENDENT");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing SCHEDULE_PHRASE!\n");
    exit(1);
  }
}

void ppSCHEDULE_CONTROL(SCHEDULE_CONTROL p, int _i_)
{
  switch(p->kind)
  {
  case is_AAschedule_control:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTOPPING(p->u.aaschedule_control_.stopping_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABschedule_control:
    if (_i_ > 0) renderC(_L_PAREN);
    ppTIMING(p->u.abschedule_control_.timing_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACschedule_control:
    if (_i_ > 0) renderC(_L_PAREN);
    ppTIMING(p->u.acschedule_control_.timing_, 0);
    ppSTOPPING(p->u.acschedule_control_.stopping_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing SCHEDULE_CONTROL!\n");
    exit(1);
  }
}

void ppTIMING(TIMING p, int _i_)
{
  switch(p->kind)
  {
  case is_AAtimingEvery:
    if (_i_ > 0) renderC(_L_PAREN);
    ppREPEAT(p->u.aatimingevery_.repeat_, 0);
    renderS("EVERY");
    ppARITH_EXP(p->u.aatimingevery_.arith_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABtimingAfter:
    if (_i_ > 0) renderC(_L_PAREN);
    ppREPEAT(p->u.abtimingafter_.repeat_, 0);
    renderS("AFTER");
    ppARITH_EXP(p->u.abtimingafter_.arith_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACtiming:
    if (_i_ > 0) renderC(_L_PAREN);
    ppREPEAT(p->u.actiming_.repeat_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing TIMING!\n");
    exit(1);
  }
}

void ppREPEAT(REPEAT p, int _i_)
{
  switch(p->kind)
  {
  case is_AArepeat:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC(',');
    renderS("REPEAT");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing REPEAT!\n");
    exit(1);
  }
}

void ppSTOPPING(STOPPING p, int _i_)
{
  switch(p->kind)
  {
  case is_AAstopping:
    if (_i_ > 0) renderC(_L_PAREN);
    ppWHILE_KEY(p->u.aastopping_.while_key_, 0);
    ppARITH_EXP(p->u.aastopping_.arith_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABstopping:
    if (_i_ > 0) renderC(_L_PAREN);
    ppWHILE_KEY(p->u.abstopping_.while_key_, 0);
    ppBIT_EXP(p->u.abstopping_.bit_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing STOPPING!\n");
    exit(1);
  }
}

void ppSIGNAL_CLAUSE(SIGNAL_CLAUSE p, int _i_)
{
  switch(p->kind)
  {
  case is_AAsignal_clause:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("SET");
    ppEVENT_VAR(p->u.aasignal_clause_.event_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABsignal_clause:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("RESET");
    ppEVENT_VAR(p->u.absignal_clause_.event_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACsignal_clause:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("SIGNAL");
    ppEVENT_VAR(p->u.acsignal_clause_.event_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing SIGNAL_CLAUSE!\n");
    exit(1);
  }
}

void ppPERCENT_MACRO_NAME(PERCENT_MACRO_NAME p, int _i_)
{
  switch(p->kind)
  {
  case is_FNpercent_macro_name:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('%');
    ppIDENTIFIER(p->u.fnpercent_macro_name_.identifier_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing PERCENT_MACRO_NAME!\n");
    exit(1);
  }
}

void ppPERCENT_MACRO_HEAD(PERCENT_MACRO_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AApercent_macro_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPERCENT_MACRO_NAME(p->u.aapercent_macro_head_.percent_macro_name_, 0);
    renderC('(');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABpercent_macro_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPERCENT_MACRO_HEAD(p->u.abpercent_macro_head_.percent_macro_head_, 0);
    ppPERCENT_MACRO_ARG(p->u.abpercent_macro_head_.percent_macro_arg_, 0);
    renderC(',');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing PERCENT_MACRO_HEAD!\n");
    exit(1);
  }
}

void ppPERCENT_MACRO_ARG(PERCENT_MACRO_ARG p, int _i_)
{
  switch(p->kind)
  {
  case is_AApercent_macro_arg:
    if (_i_ > 0) renderC(_L_PAREN);
    ppNAME_VAR(p->u.aapercent_macro_arg_.name_var_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABpercent_macro_arg:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCONSTANT(p->u.abpercent_macro_arg_.constant_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing PERCENT_MACRO_ARG!\n");
    exit(1);
  }
}

void ppCASE_ELSE(CASE_ELSE p, int _i_)
{
  switch(p->kind)
  {
  case is_AAcase_else:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("DO");
    renderS("CASE");
    ppARITH_EXP(p->u.aacase_else_.arith_exp_, 0);
    renderC(';');
    renderS("ELSE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing CASE_ELSE!\n");
    exit(1);
  }
}

void ppWHILE_KEY(WHILE_KEY p, int _i_)
{
  switch(p->kind)
  {
  case is_AAwhileKeyWhile:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("WHILE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABwhileKeyUntil:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("UNTIL");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing WHILE_KEY!\n");
    exit(1);
  }
}

void ppWHILE_CLAUSE(WHILE_CLAUSE p, int _i_)
{
  switch(p->kind)
  {
  case is_AAwhile_clause:
    if (_i_ > 0) renderC(_L_PAREN);
    ppWHILE_KEY(p->u.aawhile_clause_.while_key_, 0);
    ppBIT_EXP(p->u.aawhile_clause_.bit_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABwhile_clause:
    if (_i_ > 0) renderC(_L_PAREN);
    ppWHILE_KEY(p->u.abwhile_clause_.while_key_, 0);
    ppRELATIONAL_EXP(p->u.abwhile_clause_.relational_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing WHILE_CLAUSE!\n");
    exit(1);
  }
}

void ppFOR_LIST(FOR_LIST p, int _i_)
{
  switch(p->kind)
  {
  case is_AAfor_list:
    if (_i_ > 0) renderC(_L_PAREN);
    ppFOR_KEY(p->u.aafor_list_.for_key_, 0);
    ppARITH_EXP(p->u.aafor_list_.arith_exp_, 0);
    ppITERATION_CONTROL(p->u.aafor_list_.iteration_control_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABfor_list:
    if (_i_ > 0) renderC(_L_PAREN);
    ppFOR_KEY(p->u.abfor_list_.for_key_, 0);
    ppITERATION_BODY(p->u.abfor_list_.iteration_body_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing FOR_LIST!\n");
    exit(1);
  }
}

void ppITERATION_BODY(ITERATION_BODY p, int _i_)
{
  switch(p->kind)
  {
  case is_AAiteration_body:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_EXP(p->u.aaiteration_body_.arith_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABiteration_body:
    if (_i_ > 0) renderC(_L_PAREN);
    ppITERATION_BODY(p->u.abiteration_body_.iteration_body_, 0);
    renderC(',');
    ppARITH_EXP(p->u.abiteration_body_.arith_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ITERATION_BODY!\n");
    exit(1);
  }
}

void ppITERATION_CONTROL(ITERATION_CONTROL p, int _i_)
{
  switch(p->kind)
  {
  case is_AAiteration_controlTo:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("TO");
    ppARITH_EXP(p->u.aaiteration_controlto_.arith_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABiteration_controlToBy:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("TO");
    ppARITH_EXP(p->u.abiteration_controltoby_.arith_exp_1, 0);
    renderS("BY");
    ppARITH_EXP(p->u.abiteration_controltoby_.arith_exp_2, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ITERATION_CONTROL!\n");
    exit(1);
  }
}

void ppFOR_KEY(FOR_KEY p, int _i_)
{
  switch(p->kind)
  {
  case is_AAforKey:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("FOR");
    ppARITH_VAR(p->u.aaforkey_.arith_var_, 0);
    ppEQUALS(p->u.aaforkey_.equals_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABforKeyTemporary:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("FOR");
    renderS("TEMPORARY");
    ppIDENTIFIER(p->u.abforkeytemporary_.identifier_, 0);
    renderC('=');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing FOR_KEY!\n");
    exit(1);
  }
}

void ppTEMPORARY_STMT(TEMPORARY_STMT p, int _i_)
{
  switch(p->kind)
  {
  case is_AAtemporary_stmt:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("TEMPORARY");
    ppDECLARE_BODY(p->u.aatemporary_stmt_.declare_body_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing TEMPORARY_STMT!\n");
    exit(1);
  }
}

void ppCONSTANT(CONSTANT p, int _i_)
{
  switch(p->kind)
  {
  case is_AAconstant:
    if (_i_ > 0) renderC(_L_PAREN);
    ppNUMBER(p->u.aaconstant_.number_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABconstant:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCOMPOUND_NUMBER(p->u.abconstant_.compound_number_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACconstant:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_CONST(p->u.acconstant_.bit_const_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADconstant:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_CONST(p->u.adconstant_.char_const_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing CONSTANT!\n");
    exit(1);
  }
}

void ppARRAY_HEAD(ARRAY_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAarray_head:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ARRAY");
    renderC('(');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABarray_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARRAY_HEAD(p->u.abarray_head_.array_head_, 0);
    ppLITERAL_EXP_OR_STAR(p->u.abarray_head_.literal_exp_or_star_, 0);
    renderC(',');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ARRAY_HEAD!\n");
    exit(1);
  }
}

void ppMINOR_ATTR_LIST(MINOR_ATTR_LIST p, int _i_)
{
  switch(p->kind)
  {
  case is_AAminor_attr_list:
    if (_i_ > 0) renderC(_L_PAREN);
    ppMINOR_ATTRIBUTE(p->u.aaminor_attr_list_.minor_attribute_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABminor_attr_list:
    if (_i_ > 0) renderC(_L_PAREN);
    ppMINOR_ATTR_LIST(p->u.abminor_attr_list_.minor_attr_list_, 0);
    ppMINOR_ATTRIBUTE(p->u.abminor_attr_list_.minor_attribute_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing MINOR_ATTR_LIST!\n");
    exit(1);
  }
}

void ppMINOR_ATTRIBUTE(MINOR_ATTRIBUTE p, int _i_)
{
  switch(p->kind)
  {
  case is_AAminorAttributeStatic:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("STATIC");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABminorAttributeAutomatic:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("AUTOMATIC");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACminorAttributeDense:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("DENSE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADminorAttributeAligned:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ALIGNED");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEminorAttributeAccess:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("ACCESS");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AFminorAttributeLock:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("LOCK");
    renderC('(');
    ppLITERAL_EXP_OR_STAR(p->u.afminorattributelock_.literal_exp_or_star_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AGminorAttributeRemote:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("REMOTE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AHminorAttributeRigid:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("RIGID");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AIminorAttributeRepeatedConstant:
    if (_i_ > 0) renderC(_L_PAREN);
    ppINIT_OR_CONST_HEAD(p->u.aiminorattributerepeatedconstant_.init_or_const_head_, 0);
    ppREPEATED_CONSTANT(p->u.aiminorattributerepeatedconstant_.repeated_constant_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AJminorAttributeStar:
    if (_i_ > 0) renderC(_L_PAREN);
    ppINIT_OR_CONST_HEAD(p->u.ajminorattributestar_.init_or_const_head_, 0);
    renderC('*');
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AKminorAttributeLatched:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("LATCHED");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ALminorAttributeNonHal:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("NONHAL");
    renderC('(');
    ppLEVEL(p->u.alminorattributenonhal_.level_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing MINOR_ATTRIBUTE!\n");
    exit(1);
  }
}

void ppINIT_OR_CONST_HEAD(INIT_OR_CONST_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAinit_or_const_headInitial:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("INITIAL");
    renderC('(');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABinit_or_const_headConstant:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("CONSTANT");
    renderC('(');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACinit_or_const_headRepeatedConstant:
    if (_i_ > 0) renderC(_L_PAREN);
    ppINIT_OR_CONST_HEAD(p->u.acinit_or_const_headrepeatedconstant_.init_or_const_head_, 0);
    ppREPEATED_CONSTANT(p->u.acinit_or_const_headrepeatedconstant_.repeated_constant_, 0);
    renderC(',');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing INIT_OR_CONST_HEAD!\n");
    exit(1);
  }
}

void ppREPEATED_CONSTANT(REPEATED_CONSTANT p, int _i_)
{
  switch(p->kind)
  {
  case is_AArepeated_constant:
    if (_i_ > 0) renderC(_L_PAREN);
    ppEXPRESSION(p->u.aarepeated_constant_.expression_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABrepeated_constant:
    if (_i_ > 0) renderC(_L_PAREN);
    ppREPEAT_HEAD(p->u.abrepeated_constant_.repeat_head_, 0);
    ppVARIABLE(p->u.abrepeated_constant_.variable_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACrepeated_constant:
    if (_i_ > 0) renderC(_L_PAREN);
    ppREPEAT_HEAD(p->u.acrepeated_constant_.repeat_head_, 0);
    ppCONSTANT(p->u.acrepeated_constant_.constant_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADrepeated_constant:
    if (_i_ > 0) renderC(_L_PAREN);
    ppNESTED_REPEAT_HEAD(p->u.adrepeated_constant_.nested_repeat_head_, 0);
    ppREPEATED_CONSTANT(p->u.adrepeated_constant_.repeated_constant_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AErepeated_constant:
    if (_i_ > 0) renderC(_L_PAREN);
    ppREPEAT_HEAD(p->u.aerepeated_constant_.repeat_head_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing REPEATED_CONSTANT!\n");
    exit(1);
  }
}

void ppREPEAT_HEAD(REPEAT_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AArepeat_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_EXP(p->u.aarepeat_head_.arith_exp_, 0);
    renderC('#');
    ppSIMPLE_NUMBER(p->u.aarepeat_head_.simple_number_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing REPEAT_HEAD!\n");
    exit(1);
  }
}

void ppNESTED_REPEAT_HEAD(NESTED_REPEAT_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAnested_repeat_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppREPEAT_HEAD(p->u.aanested_repeat_head_.repeat_head_, 0);
    renderC('(');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABnested_repeat_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppNESTED_REPEAT_HEAD(p->u.abnested_repeat_head_.nested_repeat_head_, 0);
    ppREPEATED_CONSTANT(p->u.abnested_repeat_head_.repeated_constant_, 0);
    renderC(',');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing NESTED_REPEAT_HEAD!\n");
    exit(1);
  }
}

void ppDCL_LIST_COMMA(DCL_LIST_COMMA p, int _i_)
{
  switch(p->kind)
  {
  case is_AAdcl_list_comma:
    if (_i_ > 0) renderC(_L_PAREN);
    ppDECLARATION_LIST(p->u.aadcl_list_comma_.declaration_list_, 0);
    renderC(',');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing DCL_LIST_COMMA!\n");
    exit(1);
  }
}

void ppLITERAL_EXP_OR_STAR(LITERAL_EXP_OR_STAR p, int _i_)
{
  switch(p->kind)
  {
  case is_AAliteralExp:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_EXP(p->u.aaliteralexp_.arith_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABliteralStar:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('*');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing LITERAL_EXP_OR_STAR!\n");
    exit(1);
  }
}

void ppTYPE_SPEC(TYPE_SPEC p, int _i_)
{
  switch(p->kind)
  {
  case is_AAtypeSpecStruct:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTRUCT_SPEC(p->u.aatypespecstruct_.struct_spec_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABtypeSpecBit:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_SPEC(p->u.abtypespecbit_.bit_spec_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACtypeSpecChar:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_SPEC(p->u.actypespecchar_.char_spec_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADtypeSpecArith:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_SPEC(p->u.adtypespecarith_.arith_spec_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEtypeSpecEvent:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("EVENT");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing TYPE_SPEC!\n");
    exit(1);
  }
}

void ppBIT_SPEC(BIT_SPEC p, int _i_)
{
  switch(p->kind)
  {
  case is_AAbitSpecBoolean:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("BOOLEAN");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABbitSpecBoolean:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("BIT");
    renderC('(');
    ppLITERAL_EXP_OR_STAR(p->u.abbitspecboolean_.literal_exp_or_star_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BIT_SPEC!\n");
    exit(1);
  }
}

void ppCHAR_SPEC(CHAR_SPEC p, int _i_)
{
  switch(p->kind)
  {
  case is_AAchar_spec:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("CHARACTER");
    renderC('(');
    ppLITERAL_EXP_OR_STAR(p->u.aachar_spec_.literal_exp_or_star_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing CHAR_SPEC!\n");
    exit(1);
  }
}

void ppSTRUCT_SPEC(STRUCT_SPEC p, int _i_)
{
  switch(p->kind)
  {
  case is_AAstruct_spec:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTRUCT_TEMPLATE(p->u.aastruct_spec_.struct_template_, 0);
    ppSTRUCT_SPEC_BODY(p->u.aastruct_spec_.struct_spec_body_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing STRUCT_SPEC!\n");
    exit(1);
  }
}

void ppSTRUCT_SPEC_BODY(STRUCT_SPEC_BODY p, int _i_)
{
  switch(p->kind)
  {
  case is_AAstruct_spec_body:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('-');
    renderS("STRUCTURE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABstruct_spec_body:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTRUCT_SPEC_HEAD(p->u.abstruct_spec_body_.struct_spec_head_, 0);
    ppLITERAL_EXP_OR_STAR(p->u.abstruct_spec_body_.literal_exp_or_star_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing STRUCT_SPEC_BODY!\n");
    exit(1);
  }
}

void ppSTRUCT_TEMPLATE(STRUCT_TEMPLATE p, int _i_)
{
  switch(p->kind)
  {
  case is_FMstruct_template:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTRUCTURE_ID(p->u.fmstruct_template_.structure_id_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing STRUCT_TEMPLATE!\n");
    exit(1);
  }
}

void ppSTRUCT_SPEC_HEAD(STRUCT_SPEC_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAstruct_spec_head:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('-');
    renderS("STRUCTURE");
    renderC('(');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing STRUCT_SPEC_HEAD!\n");
    exit(1);
  }
}

void ppARITH_SPEC(ARITH_SPEC p, int _i_)
{
  switch(p->kind)
  {
  case is_AAarith_spec:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPREC_SPEC(p->u.aaarith_spec_.prec_spec_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABarith_spec:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSQ_DQ_NAME(p->u.abarith_spec_.sq_dq_name_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACarith_spec:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSQ_DQ_NAME(p->u.acarith_spec_.sq_dq_name_, 0);
    ppPREC_SPEC(p->u.acarith_spec_.prec_spec_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ARITH_SPEC!\n");
    exit(1);
  }
}

void ppCOMPILATION(COMPILATION p, int _i_)
{
  switch(p->kind)
  {
  case is_AAcompilation:
    if (_i_ > 0) renderC(_L_PAREN);
    ppANY_STATEMENT(p->u.aacompilation_.any_statement_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABcompilation:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCOMPILATION(p->u.abcompilation_.compilation_, 0);
    ppANY_STATEMENT(p->u.abcompilation_.any_statement_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACcompilation:
    if (_i_ > 0) renderC(_L_PAREN);
    ppDECLARE_STATEMENT(p->u.accompilation_.declare_statement_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADcompilation:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCOMPILATION(p->u.adcompilation_.compilation_, 0);
    ppDECLARE_STATEMENT(p->u.adcompilation_.declare_statement_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEcompilation:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTRUCTURE_STMT(p->u.aecompilation_.structure_stmt_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AFcompilation:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCOMPILATION(p->u.afcompilation_.compilation_, 0);
    ppSTRUCTURE_STMT(p->u.afcompilation_.structure_stmt_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AGcompilation:
    if (_i_ > 0) renderC(_L_PAREN);
    ppREPLACE_STMT(p->u.agcompilation_.replace_stmt_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AHcompilation:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCOMPILATION(p->u.ahcompilation_.compilation_, 0);
    ppREPLACE_STMT(p->u.ahcompilation_.replace_stmt_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing COMPILATION!\n");
    exit(1);
  }
}

void ppBLOCK_DEFINITION(BLOCK_DEFINITION p, int _i_)
{
  switch(p->kind)
  {
  case is_AAblock_definition:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBLOCK_STMT(p->u.aablock_definition_.block_stmt_, 0);
    ppCLOSING(p->u.aablock_definition_.closing_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABblock_definition:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBLOCK_STMT(p->u.abblock_definition_.block_stmt_, 0);
    ppBLOCK_BODY(p->u.abblock_definition_.block_body_, 0);
    ppCLOSING(p->u.abblock_definition_.closing_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BLOCK_DEFINITION!\n");
    exit(1);
  }
}

void ppBLOCK_STMT(BLOCK_STMT p, int _i_)
{
  switch(p->kind)
  {
  case is_AAblock_stmt:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBLOCK_STMT_TOP(p->u.aablock_stmt_.block_stmt_top_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BLOCK_STMT!\n");
    exit(1);
  }
}

void ppBLOCK_STMT_TOP(BLOCK_STMT_TOP p, int _i_)
{
  switch(p->kind)
  {
  case is_AAblockTopAccess:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBLOCK_STMT_TOP(p->u.aablocktopaccess_.block_stmt_top_, 0);
    renderS("ACCESS");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABblockTopRigid:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBLOCK_STMT_TOP(p->u.abblocktoprigid_.block_stmt_top_, 0);
    renderS("RIGID");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACblockTopHead:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBLOCK_STMT_HEAD(p->u.acblocktophead_.block_stmt_head_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADblockTopExclusive:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBLOCK_STMT_HEAD(p->u.adblocktopexclusive_.block_stmt_head_, 0);
    renderS("EXCLUSIVE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEblockTopReentrant:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBLOCK_STMT_HEAD(p->u.aeblocktopreentrant_.block_stmt_head_, 0);
    renderS("REENTRANT");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BLOCK_STMT_TOP!\n");
    exit(1);
  }
}

void ppBLOCK_STMT_HEAD(BLOCK_STMT_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAblockHeadProgram:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLABEL_EXTERNAL(p->u.aablockheadprogram_.label_external_, 0);
    renderS("PROGRAM");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABblockHeadCompool:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLABEL_EXTERNAL(p->u.abblockheadcompool_.label_external_, 0);
    renderS("COMPOOL");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACblockHeadTask:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLABEL_DEFINITION(p->u.acblockheadtask_.label_definition_, 0);
    renderS("TASK");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADblockHeadUpdate:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLABEL_DEFINITION(p->u.adblockheadupdate_.label_definition_, 0);
    renderS("UPDATE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEblockHeadUpdate:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("UPDATE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AFblockHeadFunction:
    if (_i_ > 0) renderC(_L_PAREN);
    ppFUNCTION_NAME(p->u.afblockheadfunction_.function_name_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AGblockHeadFunction:
    if (_i_ > 0) renderC(_L_PAREN);
    ppFUNCTION_NAME(p->u.agblockheadfunction_.function_name_, 0);
    ppFUNC_STMT_BODY(p->u.agblockheadfunction_.func_stmt_body_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AHblockHeadProcedure:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPROCEDURE_NAME(p->u.ahblockheadprocedure_.procedure_name_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AIblockHeadProcedure:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPROCEDURE_NAME(p->u.aiblockheadprocedure_.procedure_name_, 0);
    ppPROC_STMT_BODY(p->u.aiblockheadprocedure_.proc_stmt_body_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BLOCK_STMT_HEAD!\n");
    exit(1);
  }
}

void ppLABEL_EXTERNAL(LABEL_EXTERNAL p, int _i_)
{
  switch(p->kind)
  {
  case is_AAlabel_external:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLABEL_DEFINITION(p->u.aalabel_external_.label_definition_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABlabel_external:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLABEL_DEFINITION(p->u.ablabel_external_.label_definition_, 0);
    renderS("EXTERNAL");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing LABEL_EXTERNAL!\n");
    exit(1);
  }
}

void ppCLOSING(CLOSING p, int _i_)
{
  switch(p->kind)
  {
  case is_AAclosing:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("CLOSE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABclosing:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("CLOSE");
    ppLABEL(p->u.abclosing_.label_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACclosing:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLABEL_DEFINITION(p->u.acclosing_.label_definition_, 0);
    ppCLOSING(p->u.acclosing_.closing_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing CLOSING!\n");
    exit(1);
  }
}

void ppBLOCK_BODY(BLOCK_BODY p, int _i_)
{
  switch(p->kind)
  {
  case is_ABblock_body:
    if (_i_ > 0) renderC(_L_PAREN);
    ppDECLARE_GROUP(p->u.abblock_body_.declare_group_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADblock_body:
    if (_i_ > 0) renderC(_L_PAREN);
    ppANY_STATEMENT(p->u.adblock_body_.any_statement_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACblock_body:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBLOCK_BODY(p->u.acblock_body_.block_body_, 0);
    ppANY_STATEMENT(p->u.acblock_body_.any_statement_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BLOCK_BODY!\n");
    exit(1);
  }
}

void ppFUNCTION_NAME(FUNCTION_NAME p, int _i_)
{
  switch(p->kind)
  {
  case is_AAfunction_name:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLABEL_EXTERNAL(p->u.aafunction_name_.label_external_, 0);
    renderS("FUNCTION");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing FUNCTION_NAME!\n");
    exit(1);
  }
}

void ppPROCEDURE_NAME(PROCEDURE_NAME p, int _i_)
{
  switch(p->kind)
  {
  case is_AAprocedure_name:
    if (_i_ > 0) renderC(_L_PAREN);
    ppLABEL_EXTERNAL(p->u.aaprocedure_name_.label_external_, 0);
    renderS("PROCEDURE");

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing PROCEDURE_NAME!\n");
    exit(1);
  }
}

void ppFUNC_STMT_BODY(FUNC_STMT_BODY p, int _i_)
{
  switch(p->kind)
  {
  case is_AAfunc_stmt_body:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPARAMETER_LIST(p->u.aafunc_stmt_body_.parameter_list_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABfunc_stmt_body:
    if (_i_ > 0) renderC(_L_PAREN);
    ppTYPE_SPEC(p->u.abfunc_stmt_body_.type_spec_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACfunc_stmt_body:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPARAMETER_LIST(p->u.acfunc_stmt_body_.parameter_list_, 0);
    ppTYPE_SPEC(p->u.acfunc_stmt_body_.type_spec_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing FUNC_STMT_BODY!\n");
    exit(1);
  }
}

void ppPROC_STMT_BODY(PROC_STMT_BODY p, int _i_)
{
  switch(p->kind)
  {
  case is_AAproc_stmt_body:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPARAMETER_LIST(p->u.aaproc_stmt_body_.parameter_list_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABproc_stmt_body:
    if (_i_ > 0) renderC(_L_PAREN);
    ppASSIGN_LIST(p->u.abproc_stmt_body_.assign_list_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACproc_stmt_body:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPARAMETER_LIST(p->u.acproc_stmt_body_.parameter_list_, 0);
    ppASSIGN_LIST(p->u.acproc_stmt_body_.assign_list_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing PROC_STMT_BODY!\n");
    exit(1);
  }
}

void ppDECLARE_GROUP(DECLARE_GROUP p, int _i_)
{
  switch(p->kind)
  {
  case is_AAdeclare_group:
    if (_i_ > 0) renderC(_L_PAREN);
    ppDECLARE_ELEMENT(p->u.aadeclare_group_.declare_element_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABdeclare_group:
    if (_i_ > 0) renderC(_L_PAREN);
    ppDECLARE_GROUP(p->u.abdeclare_group_.declare_group_, 0);
    ppDECLARE_ELEMENT(p->u.abdeclare_group_.declare_element_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing DECLARE_GROUP!\n");
    exit(1);
  }
}

void ppDECLARE_ELEMENT(DECLARE_ELEMENT p, int _i_)
{
  switch(p->kind)
  {
  case is_AAdeclareElementDeclare:
    if (_i_ > 0) renderC(_L_PAREN);
    ppDECLARE_STATEMENT(p->u.aadeclareelementdeclare_.declare_statement_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABdeclareElementReplace:
    if (_i_ > 0) renderC(_L_PAREN);
    ppREPLACE_STMT(p->u.abdeclareelementreplace_.replace_stmt_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACdeclareElementStructure:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTRUCTURE_STMT(p->u.acdeclareelementstructure_.structure_stmt_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADdeclareElementEquate:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("EQUATE");
    renderS("EXTERNAL");
    ppIDENTIFIER(p->u.addeclareelementequate_.identifier_, 0);
    renderS("TO");
    ppVARIABLE(p->u.addeclareelementequate_.variable_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing DECLARE_ELEMENT!\n");
    exit(1);
  }
}

void ppPARAMETER(PARAMETER p, int _i_)
{
  switch(p->kind)
  {
  case is_AAparameter:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.aaparameter_.identifiertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABparameter:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.abparameter_.bitidentifiertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACparameter:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.acparameter_.charidentifiertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADparameter:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.adparameter_.structidentifiertoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AEparameter:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.aeparameter_.eventtoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AFparameter:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.afparameter_.labeltoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing PARAMETER!\n");
    exit(1);
  }
}

void ppPARAMETER_LIST(PARAMETER_LIST p, int _i_)
{
  switch(p->kind)
  {
  case is_AAparameter_list:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPARAMETER_HEAD(p->u.aaparameter_list_.parameter_head_, 0);
    ppPARAMETER(p->u.aaparameter_list_.parameter_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing PARAMETER_LIST!\n");
    exit(1);
  }
}

void ppPARAMETER_HEAD(PARAMETER_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAparameter_head:
    if (_i_ > 0) renderC(_L_PAREN);
    renderC('(');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABparameter_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppPARAMETER_HEAD(p->u.abparameter_head_.parameter_head_, 0);
    ppPARAMETER(p->u.abparameter_head_.parameter_, 0);
    renderC(',');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing PARAMETER_HEAD!\n");
    exit(1);
  }
}

void ppDECLARE_STATEMENT(DECLARE_STATEMENT p, int _i_)
{
  switch(p->kind)
  {
  case is_AAdeclare_statement:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("DECLARE");
    ppDECLARE_BODY(p->u.aadeclare_statement_.declare_body_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing DECLARE_STATEMENT!\n");
    exit(1);
  }
}

void ppASSIGN_LIST(ASSIGN_LIST p, int _i_)
{
  switch(p->kind)
  {
  case is_AAassign_list:
    if (_i_ > 0) renderC(_L_PAREN);
    ppASSIGN(p->u.aaassign_list_.assign_, 0);
    ppPARAMETER_LIST(p->u.aaassign_list_.parameter_list_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ASSIGN_LIST!\n");
    exit(1);
  }
}

void ppTEXT(TEXT p, int _i_)
{
  switch(p->kind)
  {
  case is_FQtext:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIdent(p->u.fqtext_.texttoken_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing TEXT!\n");
    exit(1);
  }
}

void ppREPLACE_STMT(REPLACE_STMT p, int _i_)
{
  switch(p->kind)
  {
  case is_AAreplace_stmt:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("REPLACE");
    ppREPLACE_HEAD(p->u.aareplace_stmt_.replace_head_, 0);
    renderS("BY");
    ppTEXT(p->u.aareplace_stmt_.text_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing REPLACE_STMT!\n");
    exit(1);
  }
}

void ppREPLACE_HEAD(REPLACE_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAreplace_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIDENTIFIER(p->u.aareplace_head_.identifier_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABreplace_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIDENTIFIER(p->u.abreplace_head_.identifier_, 0);
    renderC('(');
    ppARG_LIST(p->u.abreplace_head_.arg_list_, 0);
    renderC(')');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing REPLACE_HEAD!\n");
    exit(1);
  }
}

void ppARG_LIST(ARG_LIST p, int _i_)
{
  switch(p->kind)
  {
  case is_AAarg_list:
    if (_i_ > 0) renderC(_L_PAREN);
    ppIDENTIFIER(p->u.aaarg_list_.identifier_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABarg_list:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARG_LIST(p->u.abarg_list_.arg_list_, 0);
    renderC(',');
    ppIDENTIFIER(p->u.abarg_list_.identifier_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ARG_LIST!\n");
    exit(1);
  }
}

void ppSTRUCTURE_STMT(STRUCTURE_STMT p, int _i_)
{
  switch(p->kind)
  {
  case is_AAstructure_stmt:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("STRUCTURE");
    ppSTRUCT_STMT_HEAD(p->u.aastructure_stmt_.struct_stmt_head_, 0);
    ppSTRUCT_STMT_TAIL(p->u.aastructure_stmt_.struct_stmt_tail_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing STRUCTURE_STMT!\n");
    exit(1);
  }
}

void ppSTRUCT_STMT_HEAD(STRUCT_STMT_HEAD p, int _i_)
{
  switch(p->kind)
  {
  case is_AAstruct_stmt_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTRUCTURE_ID(p->u.aastruct_stmt_head_.structure_id_, 0);
    renderC(':');
    ppLEVEL(p->u.aastruct_stmt_head_.level_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABstruct_stmt_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTRUCTURE_ID(p->u.abstruct_stmt_head_.structure_id_, 0);
    ppMINOR_ATTR_LIST(p->u.abstruct_stmt_head_.minor_attr_list_, 0);
    renderC(':');
    ppLEVEL(p->u.abstruct_stmt_head_.level_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACstruct_stmt_head:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTRUCT_STMT_HEAD(p->u.acstruct_stmt_head_.struct_stmt_head_, 0);
    ppDECLARATION(p->u.acstruct_stmt_head_.declaration_, 0);
    renderC(',');
    ppLEVEL(p->u.acstruct_stmt_head_.level_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing STRUCT_STMT_HEAD!\n");
    exit(1);
  }
}

void ppSTRUCT_STMT_TAIL(STRUCT_STMT_TAIL p, int _i_)
{
  switch(p->kind)
  {
  case is_AAstruct_stmt_tail:
    if (_i_ > 0) renderC(_L_PAREN);
    ppDECLARATION(p->u.aastruct_stmt_tail_.declaration_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing STRUCT_STMT_TAIL!\n");
    exit(1);
  }
}

void ppINLINE_DEFINITION(INLINE_DEFINITION p, int _i_)
{
  switch(p->kind)
  {
  case is_AAinline_definition:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_INLINE(p->u.aainline_definition_.arith_inline_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABinline_definition:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_INLINE(p->u.abinline_definition_.bit_inline_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ACinline_definition:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_INLINE(p->u.acinline_definition_.char_inline_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ADinline_definition:
    if (_i_ > 0) renderC(_L_PAREN);
    ppSTRUCTURE_EXP(p->u.adinline_definition_.structure_exp_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing INLINE_DEFINITION!\n");
    exit(1);
  }
}

void ppARITH_INLINE(ARITH_INLINE p, int _i_)
{
  switch(p->kind)
  {
  case is_ACprimary:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_INLINE_DEF(p->u.acprimary_.arith_inline_def_, 0);
    ppCLOSING(p->u.acprimary_.closing_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AZprimary:
    if (_i_ > 0) renderC(_L_PAREN);
    ppARITH_INLINE_DEF(p->u.azprimary_.arith_inline_def_, 0);
    ppBLOCK_BODY(p->u.azprimary_.block_body_, 0);
    ppCLOSING(p->u.azprimary_.closing_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ARITH_INLINE!\n");
    exit(1);
  }
}

void ppARITH_INLINE_DEF(ARITH_INLINE_DEF p, int _i_)
{
  switch(p->kind)
  {
  case is_AAarith_inline_def:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("FUNCTION");
    ppARITH_SPEC(p->u.aaarith_inline_def_.arith_spec_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_ABarith_inline_def:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("FUNCTION");
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing ARITH_INLINE_DEF!\n");
    exit(1);
  }
}

void ppBIT_INLINE(BIT_INLINE p, int _i_)
{
  switch(p->kind)
  {
  case is_AGbit_prim:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_INLINE_DEF(p->u.agbit_prim_.bit_inline_def_, 0);
    ppCLOSING(p->u.agbit_prim_.closing_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AZbit_prim:
    if (_i_ > 0) renderC(_L_PAREN);
    ppBIT_INLINE_DEF(p->u.azbit_prim_.bit_inline_def_, 0);
    ppBLOCK_BODY(p->u.azbit_prim_.block_body_, 0);
    ppCLOSING(p->u.azbit_prim_.closing_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BIT_INLINE!\n");
    exit(1);
  }
}

void ppBIT_INLINE_DEF(BIT_INLINE_DEF p, int _i_)
{
  switch(p->kind)
  {
  case is_AAbit_inline_def:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("FUNCTION");
    ppBIT_SPEC(p->u.aabit_inline_def_.bit_spec_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing BIT_INLINE_DEF!\n");
    exit(1);
  }
}

void ppCHAR_INLINE(CHAR_INLINE p, int _i_)
{
  switch(p->kind)
  {
  case is_ADchar_prim:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_INLINE_DEF(p->u.adchar_prim_.char_inline_def_, 0);
    ppCLOSING(p->u.adchar_prim_.closing_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_AZchar_prim:
    if (_i_ > 0) renderC(_L_PAREN);
    ppCHAR_INLINE_DEF(p->u.azchar_prim_.char_inline_def_, 0);
    ppBLOCK_BODY(p->u.azchar_prim_.block_body_, 0);
    ppCLOSING(p->u.azchar_prim_.closing_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing CHAR_INLINE!\n");
    exit(1);
  }
}

void ppCHAR_INLINE_DEF(CHAR_INLINE_DEF p, int _i_)
{
  switch(p->kind)
  {
  case is_AAchar_inline_def:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("FUNCTION");
    ppCHAR_SPEC(p->u.aachar_inline_def_.char_spec_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing CHAR_INLINE_DEF!\n");
    exit(1);
  }
}

void ppSTRUC_INLINE_DEF(STRUC_INLINE_DEF p, int _i_)
{
  switch(p->kind)
  {
  case is_AAstruc_inline_def:
    if (_i_ > 0) renderC(_L_PAREN);
    renderS("FUNCTION");
    ppSTRUCT_SPEC(p->u.aastruc_inline_def_.struct_spec_, 0);
    renderC(';');

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when printing STRUC_INLINE_DEF!\n");
    exit(1);
  }
}

void ppInteger(Integer n, int i)
{
  char tmp[16];
  sprintf(tmp, "%d", n);
  bufAppendS(tmp);
}
void ppDouble(Double d, int i)
{
  char tmp[16];
  sprintf(tmp, "%g", d);
  bufAppendS(tmp);
}
void ppChar(Char c, int i)
{
  bufAppendC('\'');
  bufAppendC(c);
  bufAppendC('\'');
}
void ppString(String s, int i)
{
  bufAppendC('\"');
  bufAppendS(s);
  bufAppendC('\"');
}
void ppIdent(String s, int i)
{
  renderS(s);
}

void ppBitIdentifierToken(String s, int i)
{
  renderS(s);
}


void ppBitFunctionIdentifierToken(String s, int i)
{
  renderS(s);
}


void ppCharFunctionIdentifierToken(String s, int i)
{
  renderS(s);
}


void ppCharIdentifierToken(String s, int i)
{
  renderS(s);
}


void ppStructIdentifierToken(String s, int i)
{
  renderS(s);
}


void ppStructFunctionIdentifierToken(String s, int i)
{
  renderS(s);
}


void ppLabelToken(String s, int i)
{
  renderS(s);
}


void ppEventToken(String s, int i)
{
  renderS(s);
}


void ppArithFieldToken(String s, int i)
{
  renderS(s);
}


void ppIdentifierToken(String s, int i)
{
  renderS(s);
}


void ppStringToken(String s, int i)
{
  renderS(s);
}


void ppTextToken(String s, int i)
{
  renderS(s);
}


void ppLevelToken(String s, int i)
{
  renderS(s);
}


void ppNumberToken(String s, int i)
{
  renderS(s);
}


void ppCompoundToken(String s, int i)
{
  renderS(s);
}


void shDECLARE_BODY(DECLARE_BODY p)
{
  switch(p->kind)
  {
  case is_AAdeclareBody_declarationList:
    bufAppendC('(');

    bufAppendS("AAdeclareBody_declarationList");

    bufAppendC(' ');

    shDECLARATION_LIST(p->u.aadeclarebody_declarationlist_.declaration_list_);

    bufAppendC(')');

    break;
  case is_ABdeclareBody_attributes_declarationList:
    bufAppendC('(');

    bufAppendS("ABdeclareBody_attributes_declarationList");

    bufAppendC(' ');

    shATTRIBUTES(p->u.abdeclarebody_attributes_declarationlist_.attributes_);
  bufAppendC(' ');
    shDECLARATION_LIST(p->u.abdeclarebody_attributes_declarationlist_.declaration_list_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing DECLARE_BODY!\n");
    exit(1);
  }
}

void shATTRIBUTES(ATTRIBUTES p)
{
  switch(p->kind)
  {
  case is_AAattributes_arraySpec_typeAndMinorAttr:
    bufAppendC('(');

    bufAppendS("AAattributes_arraySpec_typeAndMinorAttr");

    bufAppendC(' ');

    shARRAY_SPEC(p->u.aaattributes_arrayspec_typeandminorattr_.array_spec_);
  bufAppendC(' ');
    shTYPE_AND_MINOR_ATTR(p->u.aaattributes_arrayspec_typeandminorattr_.type_and_minor_attr_);

    bufAppendC(')');

    break;
  case is_ABattributes_arraySpec:
    bufAppendC('(');

    bufAppendS("ABattributes_arraySpec");

    bufAppendC(' ');

    shARRAY_SPEC(p->u.abattributes_arrayspec_.array_spec_);

    bufAppendC(')');

    break;
  case is_ACattributes_typeAndMinorAttr:
    bufAppendC('(');

    bufAppendS("ACattributes_typeAndMinorAttr");

    bufAppendC(' ');

    shTYPE_AND_MINOR_ATTR(p->u.acattributes_typeandminorattr_.type_and_minor_attr_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ATTRIBUTES!\n");
    exit(1);
  }
}

void shDECLARATION(DECLARATION p)
{
  switch(p->kind)
  {
  case is_AAdeclaration_nameId:
    bufAppendC('(');

    bufAppendS("AAdeclaration_nameId");

    bufAppendC(' ');

    shNAME_ID(p->u.aadeclaration_nameid_.name_id_);

    bufAppendC(')');

    break;
  case is_ABdeclaration_nameId_attributes:
    bufAppendC('(');

    bufAppendS("ABdeclaration_nameId_attributes");

    bufAppendC(' ');

    shNAME_ID(p->u.abdeclaration_nameid_attributes_.name_id_);
  bufAppendC(' ');
    shATTRIBUTES(p->u.abdeclaration_nameid_attributes_.attributes_);

    bufAppendC(')');

    break;
  case is_ACdeclaration_labelToken_procedure_minorAttrList:
    bufAppendC('(');

    bufAppendS("ACdeclaration_labelToken_procedure_minorAttrList");

    bufAppendC(' ');

    shIdent(p->u.acdeclaration_labeltoken_procedure_minorattrlist_.labeltoken_);
  bufAppendC(' ');
    shMINOR_ATTR_LIST(p->u.acdeclaration_labeltoken_procedure_minorattrlist_.minor_attr_list_);

    bufAppendC(')');

    break;
  case is_ADdeclaration_labelToken_procedure:
    bufAppendC('(');

    bufAppendS("ADdeclaration_labelToken_procedure");

    bufAppendC(' ');

    shIdent(p->u.addeclaration_labeltoken_procedure_.labeltoken_);

    bufAppendC(')');

    break;
  case is_AEdeclaration_eventToken_event:
    bufAppendC('(');

    bufAppendS("AEdeclaration_eventToken_event");

    bufAppendC(' ');

    shIdent(p->u.aedeclaration_eventtoken_event_.eventtoken_);

    bufAppendC(')');

    break;
  case is_AFdeclaration_eventToken_event_minorAttrList:
    bufAppendC('(');

    bufAppendS("AFdeclaration_eventToken_event_minorAttrList");

    bufAppendC(' ');

    shIdent(p->u.afdeclaration_eventtoken_event_minorattrlist_.eventtoken_);
  bufAppendC(' ');
    shMINOR_ATTR_LIST(p->u.afdeclaration_eventtoken_event_minorattrlist_.minor_attr_list_);

    bufAppendC(')');

    break;
  case is_AGdeclaration_eventToken:
    bufAppendC('(');

    bufAppendS("AGdeclaration_eventToken");

    bufAppendC(' ');

    shIdent(p->u.agdeclaration_eventtoken_.eventtoken_);

    bufAppendC(')');

    break;
  case is_AHdeclaration_eventToken_minorAttrList:
    bufAppendC('(');

    bufAppendS("AHdeclaration_eventToken_minorAttrList");

    bufAppendC(' ');

    shIdent(p->u.ahdeclaration_eventtoken_minorattrlist_.eventtoken_);
  bufAppendC(' ');
    shMINOR_ATTR_LIST(p->u.ahdeclaration_eventtoken_minorattrlist_.minor_attr_list_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing DECLARATION!\n");
    exit(1);
  }
}

void shARRAY_SPEC(ARRAY_SPEC p)
{
  switch(p->kind)
  {
  case is_AAarraySpec_arrayHead_literalExpOrStar:
    bufAppendC('(');

    bufAppendS("AAarraySpec_arrayHead_literalExpOrStar");

    bufAppendC(' ');

    shARRAY_HEAD(p->u.aaarrayspec_arrayhead_literalexporstar_.array_head_);
  bufAppendC(' ');
    shLITERAL_EXP_OR_STAR(p->u.aaarrayspec_arrayhead_literalexporstar_.literal_exp_or_star_);

    bufAppendC(')');

    break;
  case is_ABarraySpec_function:

    bufAppendS("ABarraySpec_function");




    break;
  case is_ACarraySpec_procedure:

    bufAppendS("ACarraySpec_procedure");




    break;
  case is_ADarraySpec_program:

    bufAppendS("ADarraySpec_program");




    break;
  case is_AEarraySpec_task:

    bufAppendS("AEarraySpec_task");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ARRAY_SPEC!\n");
    exit(1);
  }
}

void shTYPE_AND_MINOR_ATTR(TYPE_AND_MINOR_ATTR p)
{
  switch(p->kind)
  {
  case is_AAtypeAndMinorAttr_typeSpec:
    bufAppendC('(');

    bufAppendS("AAtypeAndMinorAttr_typeSpec");

    bufAppendC(' ');

    shTYPE_SPEC(p->u.aatypeandminorattr_typespec_.type_spec_);

    bufAppendC(')');

    break;
  case is_ABtypeAndMinorAttr_typeSpec_minorAttrList:
    bufAppendC('(');

    bufAppendS("ABtypeAndMinorAttr_typeSpec_minorAttrList");

    bufAppendC(' ');

    shTYPE_SPEC(p->u.abtypeandminorattr_typespec_minorattrlist_.type_spec_);
  bufAppendC(' ');
    shMINOR_ATTR_LIST(p->u.abtypeandminorattr_typespec_minorattrlist_.minor_attr_list_);

    bufAppendC(')');

    break;
  case is_ACtypeAndMinorAttr_minorAttrList:
    bufAppendC('(');

    bufAppendS("ACtypeAndMinorAttr_minorAttrList");

    bufAppendC(' ');

    shMINOR_ATTR_LIST(p->u.actypeandminorattr_minorattrlist_.minor_attr_list_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing TYPE_AND_MINOR_ATTR!\n");
    exit(1);
  }
}

void shIDENTIFIER(IDENTIFIER p)
{
  switch(p->kind)
  {
  case is_AAidentifier:
    bufAppendC('(');

    bufAppendS("AAidentifier");

    bufAppendC(' ');

    shIdent(p->u.aaidentifier_.identifiertoken_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing IDENTIFIER!\n");
    exit(1);
  }
}

void shSQ_DQ_NAME(SQ_DQ_NAME p)
{
  switch(p->kind)
  {
  case is_AAsQdQName_doublyQualNameHead_literalExpOrStar:
    bufAppendC('(');

    bufAppendS("AAsQdQName_doublyQualNameHead_literalExpOrStar");

    bufAppendC(' ');

    shDOUBLY_QUAL_NAME_HEAD(p->u.aasqdqname_doublyqualnamehead_literalexporstar_.doubly_qual_name_head_);
  bufAppendC(' ');
    shLITERAL_EXP_OR_STAR(p->u.aasqdqname_doublyqualnamehead_literalexporstar_.literal_exp_or_star_);

    bufAppendC(')');

    break;
  case is_ABsQdQName_arithConv:
    bufAppendC('(');

    bufAppendS("ABsQdQName_arithConv");

    bufAppendC(' ');

    shARITH_CONV(p->u.absqdqname_arithconv_.arith_conv_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing SQ_DQ_NAME!\n");
    exit(1);
  }
}

void shDOUBLY_QUAL_NAME_HEAD(DOUBLY_QUAL_NAME_HEAD p)
{
  switch(p->kind)
  {
  case is_AAdoublyQualNameHead_vector:

    bufAppendS("AAdoublyQualNameHead_vector");




    break;
  case is_ABdoublyQualNameHead_matrix_literalExpOrStar:
    bufAppendC('(');

    bufAppendS("ABdoublyQualNameHead_matrix_literalExpOrStar");

    bufAppendC(' ');

    shLITERAL_EXP_OR_STAR(p->u.abdoublyqualnamehead_matrix_literalexporstar_.literal_exp_or_star_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing DOUBLY_QUAL_NAME_HEAD!\n");
    exit(1);
  }
}

void shARITH_CONV(ARITH_CONV p)
{
  switch(p->kind)
  {
  case is_AAarithConv_integer:

    bufAppendS("AAarithConv_integer");




    break;
  case is_ABarithConv_scalar:

    bufAppendS("ABarithConv_scalar");




    break;
  case is_ACarithConv_vector:

    bufAppendS("ACarithConv_vector");




    break;
  case is_ADarithConv_matrix:

    bufAppendS("ADarithConv_matrix");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ARITH_CONV!\n");
    exit(1);
  }
}

void shDECLARATION_LIST(DECLARATION_LIST p)
{
  switch(p->kind)
  {
  case is_AAdeclaration_list:
    bufAppendC('(');

    bufAppendS("AAdeclaration_list");

    bufAppendC(' ');

    shDECLARATION(p->u.aadeclaration_list_.declaration_);

    bufAppendC(')');

    break;
  case is_ABdeclaration_list:
    bufAppendC('(');

    bufAppendS("ABdeclaration_list");

    bufAppendC(' ');

    shDCL_LIST_COMMA(p->u.abdeclaration_list_.dcl_list_comma_);
  bufAppendC(' ');
    shDECLARATION(p->u.abdeclaration_list_.declaration_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing DECLARATION_LIST!\n");
    exit(1);
  }
}

void shNAME_ID(NAME_ID p)
{
  switch(p->kind)
  {
  case is_AAnameId_identifier:
    bufAppendC('(');

    bufAppendS("AAnameId_identifier");

    bufAppendC(' ');

    shIDENTIFIER(p->u.aanameid_identifier_.identifier_);

    bufAppendC(')');

    break;
  case is_ABnameId_identifier_name:
    bufAppendC('(');

    bufAppendS("ABnameId_identifier_name");

    bufAppendC(' ');

    shIDENTIFIER(p->u.abnameid_identifier_name_.identifier_);

    bufAppendC(')');

    break;
  case is_ACnameId_bitId:
    bufAppendC('(');

    bufAppendS("ACnameId_bitId");

    bufAppendC(' ');

    shBIT_ID(p->u.acnameid_bitid_.bit_id_);

    bufAppendC(')');

    break;
  case is_ADnameId_charId:
    bufAppendC('(');

    bufAppendS("ADnameId_charId");

    bufAppendC(' ');

    shCHAR_ID(p->u.adnameid_charid_.char_id_);

    bufAppendC(')');

    break;
  case is_AEnameId_bitFunctionIdentifierToken:
    bufAppendC('(');

    bufAppendS("AEnameId_bitFunctionIdentifierToken");

    bufAppendC(' ');

    shIdent(p->u.aenameid_bitfunctionidentifiertoken_.bitfunctionidentifiertoken_);

    bufAppendC(')');

    break;
  case is_AFnameId_charFunctionIdentifierToken:
    bufAppendC('(');

    bufAppendS("AFnameId_charFunctionIdentifierToken");

    bufAppendC(' ');

    shIdent(p->u.afnameid_charfunctionidentifiertoken_.charfunctionidentifiertoken_);

    bufAppendC(')');

    break;
  case is_AGnameId_structIdentifierToken:
    bufAppendC('(');

    bufAppendS("AGnameId_structIdentifierToken");

    bufAppendC(' ');

    shIdent(p->u.agnameid_structidentifiertoken_.structidentifiertoken_);

    bufAppendC(')');

    break;
  case is_AHnameId_structFunctionIdentifierToken:
    bufAppendC('(');

    bufAppendS("AHnameId_structFunctionIdentifierToken");

    bufAppendC(' ');

    shIdent(p->u.ahnameid_structfunctionidentifiertoken_.structfunctionidentifiertoken_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing NAME_ID!\n");
    exit(1);
  }
}

void shARITH_EXP(ARITH_EXP p)
{
  switch(p->kind)
  {
  case is_AAarithExpTerm:
    bufAppendC('(');

    bufAppendS("AAarithExpTerm");

    bufAppendC(' ');

    shTERM(p->u.aaarithexpterm_.term_);

    bufAppendC(')');

    break;
  case is_ABarithExpPlusTerm:
    bufAppendC('(');

    bufAppendS("ABarithExpPlusTerm");

    bufAppendC(' ');

    shPLUS(p->u.abarithexpplusterm_.plus_);
  bufAppendC(' ');
    shTERM(p->u.abarithexpplusterm_.term_);

    bufAppendC(')');

    break;
  case is_ACarithMinusTerm:
    bufAppendC('(');

    bufAppendS("ACarithMinusTerm");

    bufAppendC(' ');

    shMINUS(p->u.acarithminusterm_.minus_);
  bufAppendC(' ');
    shTERM(p->u.acarithminusterm_.term_);

    bufAppendC(')');

    break;
  case is_ADarithExpArithExpPlusTerm:
    bufAppendC('(');

    bufAppendS("ADarithExpArithExpPlusTerm");

    bufAppendC(' ');

    shARITH_EXP(p->u.adarithexparithexpplusterm_.arith_exp_);
  bufAppendC(' ');
    shPLUS(p->u.adarithexparithexpplusterm_.plus_);
  bufAppendC(' ');
    shTERM(p->u.adarithexparithexpplusterm_.term_);

    bufAppendC(')');

    break;
  case is_AEarithExpArithExpMinusTerm:
    bufAppendC('(');

    bufAppendS("AEarithExpArithExpMinusTerm");

    bufAppendC(' ');

    shARITH_EXP(p->u.aearithexparithexpminusterm_.arith_exp_);
  bufAppendC(' ');
    shMINUS(p->u.aearithexparithexpminusterm_.minus_);
  bufAppendC(' ');
    shTERM(p->u.aearithexparithexpminusterm_.term_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ARITH_EXP!\n");
    exit(1);
  }
}

void shTERM(TERM p)
{
  switch(p->kind)
  {
  case is_AAtermNoDivide:
    bufAppendC('(');

    bufAppendS("AAtermNoDivide");

    bufAppendC(' ');

    shPRODUCT(p->u.aatermnodivide_.product_);

    bufAppendC(')');

    break;
  case is_ABtermDivide:
    bufAppendC('(');

    bufAppendS("ABtermDivide");

    bufAppendC(' ');

    shPRODUCT(p->u.abtermdivide_.product_);
  bufAppendC(' ');
    shTERM(p->u.abtermdivide_.term_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing TERM!\n");
    exit(1);
  }
}

void shPLUS(PLUS p)
{
  switch(p->kind)
  {
  case is_AAplus:

    bufAppendS("AAplus");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing PLUS!\n");
    exit(1);
  }
}

void shMINUS(MINUS p)
{
  switch(p->kind)
  {
  case is_AAminus:

    bufAppendS("AAminus");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing MINUS!\n");
    exit(1);
  }
}

void shPRODUCT(PRODUCT p)
{
  switch(p->kind)
  {
  case is_AAproductSingle:
    bufAppendC('(');

    bufAppendS("AAproductSingle");

    bufAppendC(' ');

    shFACTOR(p->u.aaproductsingle_.factor_);

    bufAppendC(')');

    break;
  case is_ABproductCross:
    bufAppendC('(');

    bufAppendS("ABproductCross");

    bufAppendC(' ');

    shFACTOR(p->u.abproductcross_.factor_);
  bufAppendC(' ');
    shPRODUCT(p->u.abproductcross_.product_);

    bufAppendC(')');

    break;
  case is_ACproductDot:
    bufAppendC('(');

    bufAppendS("ACproductDot");

    bufAppendC(' ');

    shFACTOR(p->u.acproductdot_.factor_);
  bufAppendC(' ');
    shPRODUCT(p->u.acproductdot_.product_);

    bufAppendC(')');

    break;
  case is_ADproductMultiplication:
    bufAppendC('(');

    bufAppendS("ADproductMultiplication");

    bufAppendC(' ');

    shFACTOR(p->u.adproductmultiplication_.factor_);
  bufAppendC(' ');
    shPRODUCT(p->u.adproductmultiplication_.product_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing PRODUCT!\n");
    exit(1);
  }
}

void shFACTOR(FACTOR p)
{
  switch(p->kind)
  {
  case is_AAfactor:
    bufAppendC('(');

    bufAppendS("AAfactor");

    bufAppendC(' ');

    shPRIMARY(p->u.aafactor_.primary_);

    bufAppendC(')');

    break;
  case is_ABfactorExponentiation:
    bufAppendC('(');

    bufAppendS("ABfactorExponentiation");

    bufAppendC(' ');

    shPRIMARY(p->u.abfactorexponentiation_.primary_);
  bufAppendC(' ');
    shEXPONENTIATION(p->u.abfactorexponentiation_.exponentiation_);
  bufAppendC(' ');
    shFACTOR(p->u.abfactorexponentiation_.factor_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing FACTOR!\n");
    exit(1);
  }
}

void shEXPONENTIATION(EXPONENTIATION p)
{
  switch(p->kind)
  {
  case is_AAexponentiation:

    bufAppendS("AAexponentiation");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing EXPONENTIATION!\n");
    exit(1);
  }
}

void shPRIMARY(PRIMARY p)
{
  switch(p->kind)
  {
  case is_AAprimary:
    bufAppendC('(');

    bufAppendS("AAprimary");

    bufAppendC(' ');

    shARITH_VAR(p->u.aaprimary_.arith_var_);

    bufAppendC(')');

    break;
  case is_ADprimary:
    bufAppendC('(');

    bufAppendS("ADprimary");

    bufAppendC(' ');

    shPRE_PRIMARY(p->u.adprimary_.pre_primary_);

    bufAppendC(')');

    break;
  case is_ABprimary:
    bufAppendC('(');

    bufAppendS("ABprimary");

    bufAppendC(' ');

    shMODIFIED_ARITH_FUNC(p->u.abprimary_.modified_arith_func_);

    bufAppendC(')');

    break;
  case is_AEprimary:
    bufAppendC('(');

    bufAppendS("AEprimary");

    bufAppendC(' ');

    shPRE_PRIMARY(p->u.aeprimary_.pre_primary_);
  bufAppendC(' ');
    shQUALIFIER(p->u.aeprimary_.qualifier_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing PRIMARY!\n");
    exit(1);
  }
}

void shARITH_VAR(ARITH_VAR p)
{
  switch(p->kind)
  {
  case is_AAarith_var:
    bufAppendC('(');

    bufAppendS("AAarith_var");

    bufAppendC(' ');

    shARITH_ID(p->u.aaarith_var_.arith_id_);

    bufAppendC(')');

    break;
  case is_ACarith_var:
    bufAppendC('(');

    bufAppendS("ACarith_var");

    bufAppendC(' ');

    shARITH_ID(p->u.acarith_var_.arith_id_);
  bufAppendC(' ');
    shSUBSCRIPT(p->u.acarith_var_.subscript_);

    bufAppendC(')');

    break;
  case is_AAarithVarBracketed:
    bufAppendC('(');

    bufAppendS("AAarithVarBracketed");

    bufAppendC(' ');

    shARITH_ID(p->u.aaarithvarbracketed_.arith_id_);

    bufAppendC(')');

    break;
  case is_ABarithVarBracketed:
    bufAppendC('(');

    bufAppendS("ABarithVarBracketed");

    bufAppendC(' ');

    shARITH_ID(p->u.abarithvarbracketed_.arith_id_);
  bufAppendC(' ');
    shSUBSCRIPT(p->u.abarithvarbracketed_.subscript_);

    bufAppendC(')');

    break;
  case is_AAarithVarBraced:
    bufAppendC('(');

    bufAppendS("AAarithVarBraced");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.aaarithvarbraced_.qual_struct_);

    bufAppendC(')');

    break;
  case is_ABarithVarBraced:
    bufAppendC('(');

    bufAppendS("ABarithVarBraced");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.abarithvarbraced_.qual_struct_);
  bufAppendC(' ');
    shSUBSCRIPT(p->u.abarithvarbraced_.subscript_);

    bufAppendC(')');

    break;
  case is_ABarith_var:
    bufAppendC('(');

    bufAppendS("ABarith_var");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.abarith_var_.qual_struct_);
  bufAppendC(' ');
    shARITH_ID(p->u.abarith_var_.arith_id_);

    bufAppendC(')');

    break;
  case is_ADarith_var:
    bufAppendC('(');

    bufAppendS("ADarith_var");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.adarith_var_.qual_struct_);
  bufAppendC(' ');
    shARITH_ID(p->u.adarith_var_.arith_id_);
  bufAppendC(' ');
    shSUBSCRIPT(p->u.adarith_var_.subscript_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ARITH_VAR!\n");
    exit(1);
  }
}

void shPRE_PRIMARY(PRE_PRIMARY p)
{
  switch(p->kind)
  {
  case is_AApre_primary:
    bufAppendC('(');

    bufAppendS("AApre_primary");

    bufAppendC(' ');

    shARITH_EXP(p->u.aapre_primary_.arith_exp_);

    bufAppendC(')');

    break;
  case is_ABpre_primary:
    bufAppendC('(');

    bufAppendS("ABpre_primary");

    bufAppendC(' ');

    shNUMBER(p->u.abpre_primary_.number_);

    bufAppendC(')');

    break;
  case is_ACpre_primary:
    bufAppendC('(');

    bufAppendS("ACpre_primary");

    bufAppendC(' ');

    shCOMPOUND_NUMBER(p->u.acpre_primary_.compound_number_);

    bufAppendC(')');

    break;
  case is_ADprePrimaryRtlFunction:
    bufAppendC('(');

    bufAppendS("ADprePrimaryRtlFunction");

    bufAppendC(' ');

    shARITH_FUNC_HEAD(p->u.adpreprimaryrtlfunction_.arith_func_head_);
  bufAppendC(' ');
    shCALL_LIST(p->u.adpreprimaryrtlfunction_.call_list_);

    bufAppendC(')');

    break;
  case is_AEprePrimaryFunction:
    bufAppendC('(');

    bufAppendS("AEprePrimaryFunction");

    bufAppendC(' ');

    shIdent(p->u.aepreprimaryfunction_.labeltoken_);
  bufAppendC(' ');
    shCALL_LIST(p->u.aepreprimaryfunction_.call_list_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing PRE_PRIMARY!\n");
    exit(1);
  }
}

void shNUMBER(NUMBER p)
{
  switch(p->kind)
  {
  case is_AAnumber:
    bufAppendC('(');

    bufAppendS("AAnumber");

    bufAppendC(' ');

    shSIMPLE_NUMBER(p->u.aanumber_.simple_number_);

    bufAppendC(')');

    break;
  case is_ABnumber:
    bufAppendC('(');

    bufAppendS("ABnumber");

    bufAppendC(' ');

    shLEVEL(p->u.abnumber_.level_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing NUMBER!\n");
    exit(1);
  }
}

void shLEVEL(LEVEL p)
{
  switch(p->kind)
  {
  case is_ZZlevel:
    bufAppendC('(');

    bufAppendS("ZZlevel");

    bufAppendC(' ');

    shIdent(p->u.zzlevel_.leveltoken_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing LEVEL!\n");
    exit(1);
  }
}

void shCOMPOUND_NUMBER(COMPOUND_NUMBER p)
{
  switch(p->kind)
  {
  case is_CLcompound_number:
    bufAppendC('(');

    bufAppendS("CLcompound_number");

    bufAppendC(' ');

    shIdent(p->u.clcompound_number_.compoundtoken_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing COMPOUND_NUMBER!\n");
    exit(1);
  }
}

void shSIMPLE_NUMBER(SIMPLE_NUMBER p)
{
  switch(p->kind)
  {
  case is_CKsimple_number:
    bufAppendC('(');

    bufAppendS("CKsimple_number");

    bufAppendC(' ');

    shIdent(p->u.cksimple_number_.numbertoken_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing SIMPLE_NUMBER!\n");
    exit(1);
  }
}

void shMODIFIED_ARITH_FUNC(MODIFIED_ARITH_FUNC p)
{
  switch(p->kind)
  {
  case is_AAmodified_arith_func:
    bufAppendC('(');

    bufAppendS("AAmodified_arith_func");

    bufAppendC(' ');

    shNO_ARG_ARITH_FUNC(p->u.aamodified_arith_func_.no_arg_arith_func_);

    bufAppendC(')');

    break;
  case is_ACmodified_arith_func:
    bufAppendC('(');

    bufAppendS("ACmodified_arith_func");

    bufAppendC(' ');

    shNO_ARG_ARITH_FUNC(p->u.acmodified_arith_func_.no_arg_arith_func_);
  bufAppendC(' ');
    shSUBSCRIPT(p->u.acmodified_arith_func_.subscript_);

    bufAppendC(')');

    break;
  case is_ADmodified_arith_func:
    bufAppendC('(');

    bufAppendS("ADmodified_arith_func");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.admodified_arith_func_.qual_struct_);
  bufAppendC(' ');
    shNO_ARG_ARITH_FUNC(p->u.admodified_arith_func_.no_arg_arith_func_);

    bufAppendC(')');

    break;
  case is_AEmodified_arith_func:
    bufAppendC('(');

    bufAppendS("AEmodified_arith_func");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.aemodified_arith_func_.qual_struct_);
  bufAppendC(' ');
    shNO_ARG_ARITH_FUNC(p->u.aemodified_arith_func_.no_arg_arith_func_);
  bufAppendC(' ');
    shSUBSCRIPT(p->u.aemodified_arith_func_.subscript_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing MODIFIED_ARITH_FUNC!\n");
    exit(1);
  }
}

void shARITH_FUNC_HEAD(ARITH_FUNC_HEAD p)
{
  switch(p->kind)
  {
  case is_AAarith_func_head:
    bufAppendC('(');

    bufAppendS("AAarith_func_head");

    bufAppendC(' ');

    shARITH_FUNC(p->u.aaarith_func_head_.arith_func_);

    bufAppendC(')');

    break;
  case is_ABarith_func_head:
    bufAppendC('(');

    bufAppendS("ABarith_func_head");

    bufAppendC(' ');

    shARITH_CONV(p->u.abarith_func_head_.arith_conv_);
  bufAppendC(' ');
    shSUBSCRIPT(p->u.abarith_func_head_.subscript_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ARITH_FUNC_HEAD!\n");
    exit(1);
  }
}

void shCALL_LIST(CALL_LIST p)
{
  switch(p->kind)
  {
  case is_AAcall_list:
    bufAppendC('(');

    bufAppendS("AAcall_list");

    bufAppendC(' ');

    shLIST_EXP(p->u.aacall_list_.list_exp_);

    bufAppendC(')');

    break;
  case is_ABcall_list:
    bufAppendC('(');

    bufAppendS("ABcall_list");

    bufAppendC(' ');

    shCALL_LIST(p->u.abcall_list_.call_list_);
  bufAppendC(' ');
    shLIST_EXP(p->u.abcall_list_.list_exp_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing CALL_LIST!\n");
    exit(1);
  }
}

void shLIST_EXP(LIST_EXP p)
{
  switch(p->kind)
  {
  case is_AAlist_exp:
    bufAppendC('(');

    bufAppendS("AAlist_exp");

    bufAppendC(' ');

    shEXPRESSION(p->u.aalist_exp_.expression_);

    bufAppendC(')');

    break;
  case is_ABlist_exp:
    bufAppendC('(');

    bufAppendS("ABlist_exp");

    bufAppendC(' ');

    shARITH_EXP(p->u.ablist_exp_.arith_exp_);
  bufAppendC(' ');
    shEXPRESSION(p->u.ablist_exp_.expression_);

    bufAppendC(')');

    break;
  case is_ADlist_exp:
    bufAppendC('(');

    bufAppendS("ADlist_exp");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.adlist_exp_.qual_struct_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing LIST_EXP!\n");
    exit(1);
  }
}

void shEXPRESSION(EXPRESSION p)
{
  switch(p->kind)
  {
  case is_AAexpression:
    bufAppendC('(');

    bufAppendS("AAexpression");

    bufAppendC(' ');

    shARITH_EXP(p->u.aaexpression_.arith_exp_);

    bufAppendC(')');

    break;
  case is_ABexpression:
    bufAppendC('(');

    bufAppendS("ABexpression");

    bufAppendC(' ');

    shBIT_EXP(p->u.abexpression_.bit_exp_);

    bufAppendC(')');

    break;
  case is_ACexpression:
    bufAppendC('(');

    bufAppendS("ACexpression");

    bufAppendC(' ');

    shCHAR_EXP(p->u.acexpression_.char_exp_);

    bufAppendC(')');

    break;
  case is_AEexpression:
    bufAppendC('(');

    bufAppendS("AEexpression");

    bufAppendC(' ');

    shNAME_EXP(p->u.aeexpression_.name_exp_);

    bufAppendC(')');

    break;
  case is_ADexpression:
    bufAppendC('(');

    bufAppendS("ADexpression");

    bufAppendC(' ');

    shSTRUCTURE_EXP(p->u.adexpression_.structure_exp_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing EXPRESSION!\n");
    exit(1);
  }
}

void shARITH_ID(ARITH_ID p)
{
  switch(p->kind)
  {
  case is_FGarith_id:
    bufAppendC('(');

    bufAppendS("FGarith_id");

    bufAppendC(' ');

    shIDENTIFIER(p->u.fgarith_id_.identifier_);

    bufAppendC(')');

    break;
  case is_FHarith_id:
    bufAppendC('(');

    bufAppendS("FHarith_id");

    bufAppendC(' ');

    shIdent(p->u.fharith_id_.arithfieldtoken_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ARITH_ID!\n");
    exit(1);
  }
}

void shNO_ARG_ARITH_FUNC(NO_ARG_ARITH_FUNC p)
{
  switch(p->kind)
  {
  case is_ZZclocktime:

    bufAppendS("ZZclocktime");




    break;
  case is_ZZdate:

    bufAppendS("ZZdate");




    break;
  case is_ZZerrgrp:

    bufAppendS("ZZerrgrp");




    break;
  case is_ZZprio:

    bufAppendS("ZZprio");




    break;
  case is_ZZrandom:

    bufAppendS("ZZrandom");




    break;
  case is_ZZruntime:

    bufAppendS("ZZruntime");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing NO_ARG_ARITH_FUNC!\n");
    exit(1);
  }
}

void shARITH_FUNC(ARITH_FUNC p)
{
  switch(p->kind)
  {
  case is_ZZnexttime:

    bufAppendS("ZZnexttime");




    break;
  case is_ZZabs:

    bufAppendS("ZZabs");




    break;
  case is_ZZceiling:

    bufAppendS("ZZceiling");




    break;
  case is_ZZdiv:

    bufAppendS("ZZdiv");




    break;
  case is_ZZfloor:

    bufAppendS("ZZfloor");




    break;
  case is_ZZmidval:

    bufAppendS("ZZmidval");




    break;
  case is_ZZmod:

    bufAppendS("ZZmod");




    break;
  case is_ZZodd:

    bufAppendS("ZZodd");




    break;
  case is_ZZremainder:

    bufAppendS("ZZremainder");




    break;
  case is_ZZround:

    bufAppendS("ZZround");




    break;
  case is_ZZsign:

    bufAppendS("ZZsign");




    break;
  case is_ZZsignum:

    bufAppendS("ZZsignum");




    break;
  case is_ZZtruncate:

    bufAppendS("ZZtruncate");




    break;
  case is_ZZarccos:

    bufAppendS("ZZarccos");




    break;
  case is_ZZarccosh:

    bufAppendS("ZZarccosh");




    break;
  case is_ZZarcsin:

    bufAppendS("ZZarcsin");




    break;
  case is_ZZarcsinh:

    bufAppendS("ZZarcsinh");




    break;
  case is_ZZarctan2:

    bufAppendS("ZZarctan2");




    break;
  case is_ZZarctan:

    bufAppendS("ZZarctan");




    break;
  case is_ZZarctanh:

    bufAppendS("ZZarctanh");




    break;
  case is_ZZcos:

    bufAppendS("ZZcos");




    break;
  case is_ZZcosh:

    bufAppendS("ZZcosh");




    break;
  case is_ZZexp:

    bufAppendS("ZZexp");




    break;
  case is_ZZlog:

    bufAppendS("ZZlog");




    break;
  case is_ZZsin:

    bufAppendS("ZZsin");




    break;
  case is_ZZsinh:

    bufAppendS("ZZsinh");




    break;
  case is_ZZsqrt:

    bufAppendS("ZZsqrt");




    break;
  case is_ZZtan:

    bufAppendS("ZZtan");




    break;
  case is_ZZtanh:

    bufAppendS("ZZtanh");




    break;
  case is_ZZshl:

    bufAppendS("ZZshl");




    break;
  case is_ZZshr:

    bufAppendS("ZZshr");




    break;
  case is_ZZabval:

    bufAppendS("ZZabval");




    break;
  case is_ZZdet:

    bufAppendS("ZZdet");




    break;
  case is_ZZtrace:

    bufAppendS("ZZtrace");




    break;
  case is_ZZunit:

    bufAppendS("ZZunit");




    break;
  case is_ZZmatrix:

    bufAppendS("ZZmatrix");




    break;
  case is_ZZindex:

    bufAppendS("ZZindex");




    break;
  case is_ZZlength:

    bufAppendS("ZZlength");




    break;
  case is_ZZinverse:

    bufAppendS("ZZinverse");




    break;
  case is_ZZtranspose:

    bufAppendS("ZZtranspose");




    break;
  case is_ZZprod:

    bufAppendS("ZZprod");




    break;
  case is_ZZsum:

    bufAppendS("ZZsum");




    break;
  case is_ZZsize:

    bufAppendS("ZZsize");




    break;
  case is_ZZmax:

    bufAppendS("ZZmax");




    break;
  case is_ZZmin:

    bufAppendS("ZZmin");




    break;
  case is_AAarithFuncInteger:

    bufAppendS("AAarithFuncInteger");




    break;
  case is_AAarithFuncScalar:

    bufAppendS("AAarithFuncScalar");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ARITH_FUNC!\n");
    exit(1);
  }
}

void shSUBSCRIPT(SUBSCRIPT p)
{
  switch(p->kind)
  {
  case is_AAsubscript:
    bufAppendC('(');

    bufAppendS("AAsubscript");

    bufAppendC(' ');

    shSUB_HEAD(p->u.aasubscript_.sub_head_);

    bufAppendC(')');

    break;
  case is_ABsubscript:
    bufAppendC('(');

    bufAppendS("ABsubscript");

    bufAppendC(' ');

    shQUALIFIER(p->u.absubscript_.qualifier_);

    bufAppendC(')');

    break;
  case is_ACsubscript:
    bufAppendC('(');

    bufAppendS("ACsubscript");

    bufAppendC(' ');

    shNUMBER(p->u.acsubscript_.number_);

    bufAppendC(')');

    break;
  case is_ADsubscript:
    bufAppendC('(');

    bufAppendS("ADsubscript");

    bufAppendC(' ');

    shARITH_VAR(p->u.adsubscript_.arith_var_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing SUBSCRIPT!\n");
    exit(1);
  }
}

void shQUALIFIER(QUALIFIER p)
{
  switch(p->kind)
  {
  case is_AAqualifier:
    bufAppendC('(');

    bufAppendS("AAqualifier");

    bufAppendC(' ');

    shPREC_SPEC(p->u.aaqualifier_.prec_spec_);

    bufAppendC(')');

    break;
  case is_ABqualifier:
    bufAppendC('(');

    bufAppendS("ABqualifier");

    bufAppendC(' ');

    shSCALE_HEAD(p->u.abqualifier_.scale_head_);
  bufAppendC(' ');
    shARITH_EXP(p->u.abqualifier_.arith_exp_);

    bufAppendC(')');

    break;
  case is_ACqualifier:
    bufAppendC('(');

    bufAppendS("ACqualifier");

    bufAppendC(' ');

    shPREC_SPEC(p->u.acqualifier_.prec_spec_);
  bufAppendC(' ');
    shSCALE_HEAD(p->u.acqualifier_.scale_head_);
  bufAppendC(' ');
    shARITH_EXP(p->u.acqualifier_.arith_exp_);

    bufAppendC(')');

    break;
  case is_ADqualifier:
    bufAppendC('(');

    bufAppendS("ADqualifier");

    bufAppendC(' ');

    shRADIX(p->u.adqualifier_.radix_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing QUALIFIER!\n");
    exit(1);
  }
}

void shSCALE_HEAD(SCALE_HEAD p)
{
  switch(p->kind)
  {
  case is_AAscale_head:

    bufAppendS("AAscale_head");




    break;
  case is_ABscale_head:

    bufAppendS("ABscale_head");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing SCALE_HEAD!\n");
    exit(1);
  }
}

void shPREC_SPEC(PREC_SPEC p)
{
  switch(p->kind)
  {
  case is_AAprecSpecSingle:

    bufAppendS("AAprecSpecSingle");




    break;
  case is_ABprecSpecDouble:

    bufAppendS("ABprecSpecDouble");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing PREC_SPEC!\n");
    exit(1);
  }
}

void shSUB_START(SUB_START p)
{
  switch(p->kind)
  {
  case is_AAsubStartGroup:

    bufAppendS("AAsubStartGroup");




    break;
  case is_ABsubStartPrecSpec:
    bufAppendC('(');

    bufAppendS("ABsubStartPrecSpec");

    bufAppendC(' ');

    shPREC_SPEC(p->u.absubstartprecspec_.prec_spec_);

    bufAppendC(')');

    break;
  case is_ACsubStartSemicolon:
    bufAppendC('(');

    bufAppendS("ACsubStartSemicolon");

    bufAppendC(' ');

    shSUB_HEAD(p->u.acsubstartsemicolon_.sub_head_);

    bufAppendC(')');

    break;
  case is_ADsubStartColon:
    bufAppendC('(');

    bufAppendS("ADsubStartColon");

    bufAppendC(' ');

    shSUB_HEAD(p->u.adsubstartcolon_.sub_head_);

    bufAppendC(')');

    break;
  case is_AEsubStartComma:
    bufAppendC('(');

    bufAppendS("AEsubStartComma");

    bufAppendC(' ');

    shSUB_HEAD(p->u.aesubstartcomma_.sub_head_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing SUB_START!\n");
    exit(1);
  }
}

void shSUB_HEAD(SUB_HEAD p)
{
  switch(p->kind)
  {
  case is_AAsub_head:
    bufAppendC('(');

    bufAppendS("AAsub_head");

    bufAppendC(' ');

    shSUB_START(p->u.aasub_head_.sub_start_);

    bufAppendC(')');

    break;
  case is_ABsub_head:
    bufAppendC('(');

    bufAppendS("ABsub_head");

    bufAppendC(' ');

    shSUB_START(p->u.absub_head_.sub_start_);
  bufAppendC(' ');
    shSUB(p->u.absub_head_.sub_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing SUB_HEAD!\n");
    exit(1);
  }
}

void shSUB(SUB p)
{
  switch(p->kind)
  {
  case is_AAsub:
    bufAppendC('(');

    bufAppendS("AAsub");

    bufAppendC(' ');

    shSUB_EXP(p->u.aasub_.sub_exp_);

    bufAppendC(')');

    break;
  case is_ABsubStar:

    bufAppendS("ABsubStar");




    break;
  case is_ACsubExp:
    bufAppendC('(');

    bufAppendS("ACsubExp");

    bufAppendC(' ');

    shSUB_RUN_HEAD(p->u.acsubexp_.sub_run_head_);
  bufAppendC(' ');
    shSUB_EXP(p->u.acsubexp_.sub_exp_);

    bufAppendC(')');

    break;
  case is_ADsubAt:
    bufAppendC('(');

    bufAppendS("ADsubAt");

    bufAppendC(' ');

    shARITH_EXP(p->u.adsubat_.arith_exp_);
  bufAppendC(' ');
    shSUB_EXP(p->u.adsubat_.sub_exp_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing SUB!\n");
    exit(1);
  }
}

void shSUB_RUN_HEAD(SUB_RUN_HEAD p)
{
  switch(p->kind)
  {
  case is_AAsubRunHeadTo:
    bufAppendC('(');

    bufAppendS("AAsubRunHeadTo");

    bufAppendC(' ');

    shSUB_EXP(p->u.aasubrunheadto_.sub_exp_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing SUB_RUN_HEAD!\n");
    exit(1);
  }
}

void shSUB_EXP(SUB_EXP p)
{
  switch(p->kind)
  {
  case is_AAsub_exp:
    bufAppendC('(');

    bufAppendS("AAsub_exp");

    bufAppendC(' ');

    shARITH_EXP(p->u.aasub_exp_.arith_exp_);

    bufAppendC(')');

    break;
  case is_ABsub_exp:
    bufAppendC('(');

    bufAppendS("ABsub_exp");

    bufAppendC(' ');

    shPOUND_EXPRESSION(p->u.absub_exp_.pound_expression_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing SUB_EXP!\n");
    exit(1);
  }
}

void shPOUND_EXPRESSION(POUND_EXPRESSION p)
{
  switch(p->kind)
  {
  case is_AApound_expression:

    bufAppendS("AApound_expression");




    break;
  case is_ABpound_expression:
    bufAppendC('(');

    bufAppendS("ABpound_expression");

    bufAppendC(' ');

    shPOUND_EXPRESSION(p->u.abpound_expression_.pound_expression_);
  bufAppendC(' ');
    shPLUS(p->u.abpound_expression_.plus_);
  bufAppendC(' ');
    shTERM(p->u.abpound_expression_.term_);

    bufAppendC(')');

    break;
  case is_ACpound_expression:
    bufAppendC('(');

    bufAppendS("ACpound_expression");

    bufAppendC(' ');

    shPOUND_EXPRESSION(p->u.acpound_expression_.pound_expression_);
  bufAppendC(' ');
    shMINUS(p->u.acpound_expression_.minus_);
  bufAppendC(' ');
    shTERM(p->u.acpound_expression_.term_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing POUND_EXPRESSION!\n");
    exit(1);
  }
}

void shBIT_EXP(BIT_EXP p)
{
  switch(p->kind)
  {
  case is_AAbit_exp:
    bufAppendC('(');

    bufAppendS("AAbit_exp");

    bufAppendC(' ');

    shBIT_FACTOR(p->u.aabit_exp_.bit_factor_);

    bufAppendC(')');

    break;
  case is_ABbit_exp:
    bufAppendC('(');

    bufAppendS("ABbit_exp");

    bufAppendC(' ');

    shBIT_EXP(p->u.abbit_exp_.bit_exp_);
  bufAppendC(' ');
    shOR(p->u.abbit_exp_.or_);
  bufAppendC(' ');
    shBIT_FACTOR(p->u.abbit_exp_.bit_factor_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BIT_EXP!\n");
    exit(1);
  }
}

void shBIT_FACTOR(BIT_FACTOR p)
{
  switch(p->kind)
  {
  case is_AAbit_factor:
    bufAppendC('(');

    bufAppendS("AAbit_factor");

    bufAppendC(' ');

    shBIT_CAT(p->u.aabit_factor_.bit_cat_);

    bufAppendC(')');

    break;
  case is_ABbit_factor:
    bufAppendC('(');

    bufAppendS("ABbit_factor");

    bufAppendC(' ');

    shBIT_FACTOR(p->u.abbit_factor_.bit_factor_);
  bufAppendC(' ');
    shAND(p->u.abbit_factor_.and_);
  bufAppendC(' ');
    shBIT_CAT(p->u.abbit_factor_.bit_cat_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BIT_FACTOR!\n");
    exit(1);
  }
}

void shBIT_CAT(BIT_CAT p)
{
  switch(p->kind)
  {
  case is_AAbit_cat:
    bufAppendC('(');

    bufAppendS("AAbit_cat");

    bufAppendC(' ');

    shBIT_PRIM(p->u.aabit_cat_.bit_prim_);

    bufAppendC(')');

    break;
  case is_ABbit_cat:
    bufAppendC('(');

    bufAppendS("ABbit_cat");

    bufAppendC(' ');

    shBIT_CAT(p->u.abbit_cat_.bit_cat_);
  bufAppendC(' ');
    shCAT(p->u.abbit_cat_.cat_);
  bufAppendC(' ');
    shBIT_PRIM(p->u.abbit_cat_.bit_prim_);

    bufAppendC(')');

    break;
  case is_ACbit_cat:
    bufAppendC('(');

    bufAppendS("ACbit_cat");

    bufAppendC(' ');

    shNOT(p->u.acbit_cat_.not_);
  bufAppendC(' ');
    shBIT_PRIM(p->u.acbit_cat_.bit_prim_);

    bufAppendC(')');

    break;
  case is_ADbit_cat:
    bufAppendC('(');

    bufAppendS("ADbit_cat");

    bufAppendC(' ');

    shBIT_CAT(p->u.adbit_cat_.bit_cat_);
  bufAppendC(' ');
    shCAT(p->u.adbit_cat_.cat_);
  bufAppendC(' ');
    shNOT(p->u.adbit_cat_.not_);
  bufAppendC(' ');
    shBIT_PRIM(p->u.adbit_cat_.bit_prim_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BIT_CAT!\n");
    exit(1);
  }
}

void shOR(OR p)
{
  switch(p->kind)
  {
  case is_AAor:
    bufAppendC('(');

    bufAppendS("AAor");

    bufAppendC(' ');

    shCHAR_VERTICAL_BAR(p->u.aaor_.char_vertical_bar_);

    bufAppendC(')');

    break;
  case is_ABor:

    bufAppendS("ABor");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing OR!\n");
    exit(1);
  }
}

void shCHAR_VERTICAL_BAR(CHAR_VERTICAL_BAR p)
{
  switch(p->kind)
  {
  case is_CFchar_vertical_bar:

    bufAppendS("CFchar_vertical_bar");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing CHAR_VERTICAL_BAR!\n");
    exit(1);
  }
}

void shAND(AND p)
{
  switch(p->kind)
  {
  case is_AAand:

    bufAppendS("AAand");




    break;
  case is_ABand:

    bufAppendS("ABand");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing AND!\n");
    exit(1);
  }
}

void shBIT_PRIM(BIT_PRIM p)
{
  switch(p->kind)
  {
  case is_AAbitPrimBitVar:
    bufAppendC('(');

    bufAppendS("AAbitPrimBitVar");

    bufAppendC(' ');

    shBIT_VAR(p->u.aabitprimbitvar_.bit_var_);

    bufAppendC(')');

    break;
  case is_ABbitPrimLabelVar:
    bufAppendC('(');

    bufAppendS("ABbitPrimLabelVar");

    bufAppendC(' ');

    shLABEL_VAR(p->u.abbitprimlabelvar_.label_var_);

    bufAppendC(')');

    break;
  case is_ACbitPrimEventVar:
    bufAppendC('(');

    bufAppendS("ACbitPrimEventVar");

    bufAppendC(' ');

    shEVENT_VAR(p->u.acbitprimeventvar_.event_var_);

    bufAppendC(')');

    break;
  case is_ADbitBitConst:
    bufAppendC('(');

    bufAppendS("ADbitBitConst");

    bufAppendC(' ');

    shBIT_CONST(p->u.adbitbitconst_.bit_const_);

    bufAppendC(')');

    break;
  case is_AEbitPrimBitExp:
    bufAppendC('(');

    bufAppendS("AEbitPrimBitExp");

    bufAppendC(' ');

    shBIT_EXP(p->u.aebitprimbitexp_.bit_exp_);

    bufAppendC(')');

    break;
  case is_AHbitPrimSubbit:
    bufAppendC('(');

    bufAppendS("AHbitPrimSubbit");

    bufAppendC(' ');

    shSUBBIT_HEAD(p->u.ahbitprimsubbit_.subbit_head_);
  bufAppendC(' ');
    shEXPRESSION(p->u.ahbitprimsubbit_.expression_);

    bufAppendC(')');

    break;
  case is_AIbitPrimFunc:
    bufAppendC('(');

    bufAppendS("AIbitPrimFunc");

    bufAppendC(' ');

    shBIT_FUNC_HEAD(p->u.aibitprimfunc_.bit_func_head_);
  bufAppendC(' ');
    shCALL_LIST(p->u.aibitprimfunc_.call_list_);

    bufAppendC(')');

    break;
  case is_AAbitPrimBitVarBracketed:
    bufAppendC('(');

    bufAppendS("AAbitPrimBitVarBracketed");

    bufAppendC(' ');

    shBIT_VAR(p->u.aabitprimbitvarbracketed_.bit_var_);

    bufAppendC(')');

    break;
  case is_ABbitPrimBitVarBracketed:
    bufAppendC('(');

    bufAppendS("ABbitPrimBitVarBracketed");

    bufAppendC(' ');

    shBIT_VAR(p->u.abbitprimbitvarbracketed_.bit_var_);
  bufAppendC(' ');
    shSUBSCRIPT(p->u.abbitprimbitvarbracketed_.subscript_);

    bufAppendC(')');

    break;
  case is_AAbitPrimBitVarBraced:
    bufAppendC('(');

    bufAppendS("AAbitPrimBitVarBraced");

    bufAppendC(' ');

    shBIT_VAR(p->u.aabitprimbitvarbraced_.bit_var_);

    bufAppendC(')');

    break;
  case is_ABbitPrimBitVarBraced:
    bufAppendC('(');

    bufAppendS("ABbitPrimBitVarBraced");

    bufAppendC(' ');

    shBIT_VAR(p->u.abbitprimbitvarbraced_.bit_var_);
  bufAppendC(' ');
    shSUBSCRIPT(p->u.abbitprimbitvarbraced_.subscript_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BIT_PRIM!\n");
    exit(1);
  }
}

void shCAT(CAT p)
{
  switch(p->kind)
  {
  case is_AAcat:

    bufAppendS("AAcat");




    break;
  case is_ABcat:

    bufAppendS("ABcat");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing CAT!\n");
    exit(1);
  }
}

void shNOT(NOT p)
{
  switch(p->kind)
  {
  case is_AAnot:

    bufAppendS("AAnot");




    break;
  case is_ABnot:

    bufAppendS("ABnot");




    break;
  case is_ACnot:

    bufAppendS("ACnot");




    break;
  case is_ADnot:

    bufAppendS("ADnot");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing NOT!\n");
    exit(1);
  }
}

void shBIT_VAR(BIT_VAR p)
{
  switch(p->kind)
  {
  case is_AAbit_var:
    bufAppendC('(');

    bufAppendS("AAbit_var");

    bufAppendC(' ');

    shBIT_ID(p->u.aabit_var_.bit_id_);

    bufAppendC(')');

    break;
  case is_ACbit_var:
    bufAppendC('(');

    bufAppendS("ACbit_var");

    bufAppendC(' ');

    shBIT_ID(p->u.acbit_var_.bit_id_);
  bufAppendC(' ');
    shSUBSCRIPT(p->u.acbit_var_.subscript_);

    bufAppendC(')');

    break;
  case is_ABbit_var:
    bufAppendC('(');

    bufAppendS("ABbit_var");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.abbit_var_.qual_struct_);
  bufAppendC(' ');
    shBIT_ID(p->u.abbit_var_.bit_id_);

    bufAppendC(')');

    break;
  case is_ADbit_var:
    bufAppendC('(');

    bufAppendS("ADbit_var");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.adbit_var_.qual_struct_);
  bufAppendC(' ');
    shBIT_ID(p->u.adbit_var_.bit_id_);
  bufAppendC(' ');
    shSUBSCRIPT(p->u.adbit_var_.subscript_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BIT_VAR!\n");
    exit(1);
  }
}

void shLABEL_VAR(LABEL_VAR p)
{
  switch(p->kind)
  {
  case is_AAlabel_var:
    bufAppendC('(');

    bufAppendS("AAlabel_var");

    bufAppendC(' ');

    shLABEL(p->u.aalabel_var_.label_);

    bufAppendC(')');

    break;
  case is_ABlabel_var:
    bufAppendC('(');

    bufAppendS("ABlabel_var");

    bufAppendC(' ');

    shLABEL(p->u.ablabel_var_.label_);
  bufAppendC(' ');
    shSUBSCRIPT(p->u.ablabel_var_.subscript_);

    bufAppendC(')');

    break;
  case is_AClabel_var:
    bufAppendC('(');

    bufAppendS("AClabel_var");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.aclabel_var_.qual_struct_);
  bufAppendC(' ');
    shLABEL(p->u.aclabel_var_.label_);

    bufAppendC(')');

    break;
  case is_ADlabel_var:
    bufAppendC('(');

    bufAppendS("ADlabel_var");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.adlabel_var_.qual_struct_);
  bufAppendC(' ');
    shLABEL(p->u.adlabel_var_.label_);
  bufAppendC(' ');
    shSUBSCRIPT(p->u.adlabel_var_.subscript_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing LABEL_VAR!\n");
    exit(1);
  }
}

void shEVENT_VAR(EVENT_VAR p)
{
  switch(p->kind)
  {
  case is_AAevent_var:
    bufAppendC('(');

    bufAppendS("AAevent_var");

    bufAppendC(' ');

    shEVENT(p->u.aaevent_var_.event_);

    bufAppendC(')');

    break;
  case is_ACevent_var:
    bufAppendC('(');

    bufAppendS("ACevent_var");

    bufAppendC(' ');

    shEVENT(p->u.acevent_var_.event_);
  bufAppendC(' ');
    shSUBSCRIPT(p->u.acevent_var_.subscript_);

    bufAppendC(')');

    break;
  case is_ABevent_var:
    bufAppendC('(');

    bufAppendS("ABevent_var");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.abevent_var_.qual_struct_);
  bufAppendC(' ');
    shEVENT(p->u.abevent_var_.event_);

    bufAppendC(')');

    break;
  case is_ADevent_var:
    bufAppendC('(');

    bufAppendS("ADevent_var");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.adevent_var_.qual_struct_);
  bufAppendC(' ');
    shEVENT(p->u.adevent_var_.event_);
  bufAppendC(' ');
    shSUBSCRIPT(p->u.adevent_var_.subscript_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing EVENT_VAR!\n");
    exit(1);
  }
}

void shBIT_CONST_HEAD(BIT_CONST_HEAD p)
{
  switch(p->kind)
  {
  case is_AAbit_const_head:
    bufAppendC('(');

    bufAppendS("AAbit_const_head");

    bufAppendC(' ');

    shRADIX(p->u.aabit_const_head_.radix_);

    bufAppendC(')');

    break;
  case is_ABbit_const_head:
    bufAppendC('(');

    bufAppendS("ABbit_const_head");

    bufAppendC(' ');

    shRADIX(p->u.abbit_const_head_.radix_);
  bufAppendC(' ');
    shNUMBER(p->u.abbit_const_head_.number_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BIT_CONST_HEAD!\n");
    exit(1);
  }
}

void shBIT_CONST(BIT_CONST p)
{
  switch(p->kind)
  {
  case is_AAbitConstString:
    bufAppendC('(');

    bufAppendS("AAbitConstString");

    bufAppendC(' ');

    shBIT_CONST_HEAD(p->u.aabitconststring_.bit_const_head_);
  bufAppendC(' ');
    shCHAR_STRING(p->u.aabitconststring_.char_string_);

    bufAppendC(')');

    break;
  case is_ABbitConstTrue:

    bufAppendS("ABbitConstTrue");




    break;
  case is_ACbitConstFalse:

    bufAppendS("ACbitConstFalse");




    break;
  case is_ADbitConstOn:

    bufAppendS("ADbitConstOn");




    break;
  case is_AEbitConstOff:

    bufAppendS("AEbitConstOff");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BIT_CONST!\n");
    exit(1);
  }
}

void shRADIX(RADIX p)
{
  switch(p->kind)
  {
  case is_AAradixHEX:

    bufAppendS("AAradixHEX");




    break;
  case is_ABradixOCT:

    bufAppendS("ABradixOCT");




    break;
  case is_ACradixBIN:

    bufAppendS("ACradixBIN");




    break;
  case is_ADradixDEC:

    bufAppendS("ADradixDEC");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing RADIX!\n");
    exit(1);
  }
}

void shCHAR_STRING(CHAR_STRING p)
{
  switch(p->kind)
  {
  case is_FPchar_string:
    bufAppendC('(');

    bufAppendS("FPchar_string");

    bufAppendC(' ');

    shIdent(p->u.fpchar_string_.stringtoken_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing CHAR_STRING!\n");
    exit(1);
  }
}

void shSUBBIT_HEAD(SUBBIT_HEAD p)
{
  switch(p->kind)
  {
  case is_AAsubbit_head:
    bufAppendC('(');

    bufAppendS("AAsubbit_head");

    bufAppendC(' ');

    shSUBBIT_KEY(p->u.aasubbit_head_.subbit_key_);

    bufAppendC(')');

    break;
  case is_ABsubbit_head:
    bufAppendC('(');

    bufAppendS("ABsubbit_head");

    bufAppendC(' ');

    shSUBBIT_KEY(p->u.absubbit_head_.subbit_key_);
  bufAppendC(' ');
    shSUBSCRIPT(p->u.absubbit_head_.subscript_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing SUBBIT_HEAD!\n");
    exit(1);
  }
}

void shSUBBIT_KEY(SUBBIT_KEY p)
{
  switch(p->kind)
  {
  case is_AAsubbit_key:

    bufAppendS("AAsubbit_key");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing SUBBIT_KEY!\n");
    exit(1);
  }
}

void shBIT_FUNC_HEAD(BIT_FUNC_HEAD p)
{
  switch(p->kind)
  {
  case is_AAbit_func_head:
    bufAppendC('(');

    bufAppendS("AAbit_func_head");

    bufAppendC(' ');

    shBIT_FUNC(p->u.aabit_func_head_.bit_func_);

    bufAppendC(')');

    break;
  case is_ABbit_func_head:

    bufAppendS("ABbit_func_head");




    break;
  case is_ACbit_func_head:
    bufAppendC('(');

    bufAppendS("ACbit_func_head");

    bufAppendC(' ');

    shSUB_OR_QUALIFIER(p->u.acbit_func_head_.sub_or_qualifier_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BIT_FUNC_HEAD!\n");
    exit(1);
  }
}

void shBIT_ID(BIT_ID p)
{
  switch(p->kind)
  {
  case is_FHbit_id:
    bufAppendC('(');

    bufAppendS("FHbit_id");

    bufAppendC(' ');

    shIdent(p->u.fhbit_id_.bitidentifiertoken_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BIT_ID!\n");
    exit(1);
  }
}

void shLABEL(LABEL p)
{
  switch(p->kind)
  {
  case is_FKlabel:
    bufAppendC('(');

    bufAppendS("FKlabel");

    bufAppendC(' ');

    shIdent(p->u.fklabel_.labeltoken_);

    bufAppendC(')');

    break;
  case is_FLlabel:
    bufAppendC('(');

    bufAppendS("FLlabel");

    bufAppendC(' ');

    shIdent(p->u.fllabel_.bitfunctionidentifiertoken_);

    bufAppendC(')');

    break;
  case is_FMlabel:
    bufAppendC('(');

    bufAppendS("FMlabel");

    bufAppendC(' ');

    shIdent(p->u.fmlabel_.charfunctionidentifiertoken_);

    bufAppendC(')');

    break;
  case is_FNlabel:
    bufAppendC('(');

    bufAppendS("FNlabel");

    bufAppendC(' ');

    shIdent(p->u.fnlabel_.structfunctionidentifiertoken_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing LABEL!\n");
    exit(1);
  }
}

void shBIT_FUNC(BIT_FUNC p)
{
  switch(p->kind)
  {
  case is_ZZxor:

    bufAppendS("ZZxor");




    break;
  case is_ZZuserBitFunction:
    bufAppendC('(');

    bufAppendS("ZZuserBitFunction");

    bufAppendC(' ');

    shIdent(p->u.zzuserbitfunction_.bitfunctionidentifiertoken_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BIT_FUNC!\n");
    exit(1);
  }
}

void shEVENT(EVENT p)
{
  switch(p->kind)
  {
  case is_FLevent:
    bufAppendC('(');

    bufAppendS("FLevent");

    bufAppendC(' ');

    shIdent(p->u.flevent_.eventtoken_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing EVENT!\n");
    exit(1);
  }
}

void shSUB_OR_QUALIFIER(SUB_OR_QUALIFIER p)
{
  switch(p->kind)
  {
  case is_AAsub_or_qualifier:
    bufAppendC('(');

    bufAppendS("AAsub_or_qualifier");

    bufAppendC(' ');

    shSUBSCRIPT(p->u.aasub_or_qualifier_.subscript_);

    bufAppendC(')');

    break;
  case is_ABsub_or_qualifier:
    bufAppendC('(');

    bufAppendS("ABsub_or_qualifier");

    bufAppendC(' ');

    shBIT_QUALIFIER(p->u.absub_or_qualifier_.bit_qualifier_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing SUB_OR_QUALIFIER!\n");
    exit(1);
  }
}

void shBIT_QUALIFIER(BIT_QUALIFIER p)
{
  switch(p->kind)
  {
  case is_AAbit_qualifier:
    bufAppendC('(');

    bufAppendS("AAbit_qualifier");

    bufAppendC(' ');

    shRADIX(p->u.aabit_qualifier_.radix_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BIT_QUALIFIER!\n");
    exit(1);
  }
}

void shCHAR_EXP(CHAR_EXP p)
{
  switch(p->kind)
  {
  case is_AAcharExpPrim:
    bufAppendC('(');

    bufAppendS("AAcharExpPrim");

    bufAppendC(' ');

    shCHAR_PRIM(p->u.aacharexpprim_.char_prim_);

    bufAppendC(')');

    break;
  case is_ABcharExpCat:
    bufAppendC('(');

    bufAppendS("ABcharExpCat");

    bufAppendC(' ');

    shCHAR_EXP(p->u.abcharexpcat_.char_exp_);
  bufAppendC(' ');
    shCAT(p->u.abcharexpcat_.cat_);
  bufAppendC(' ');
    shCHAR_PRIM(p->u.abcharexpcat_.char_prim_);

    bufAppendC(')');

    break;
  case is_ACcharExpCat:
    bufAppendC('(');

    bufAppendS("ACcharExpCat");

    bufAppendC(' ');

    shCHAR_EXP(p->u.accharexpcat_.char_exp_);
  bufAppendC(' ');
    shCAT(p->u.accharexpcat_.cat_);
  bufAppendC(' ');
    shARITH_EXP(p->u.accharexpcat_.arith_exp_);

    bufAppendC(')');

    break;
  case is_ADcharExpCat:
    bufAppendC('(');

    bufAppendS("ADcharExpCat");

    bufAppendC(' ');

    shARITH_EXP(p->u.adcharexpcat_.arith_exp_1);
  bufAppendC(' ');
    shCAT(p->u.adcharexpcat_.cat_);
  bufAppendC(' ');
    shARITH_EXP(p->u.adcharexpcat_.arith_exp_2);

    bufAppendC(')');

    break;
  case is_AEcharExpCat:
    bufAppendC('(');

    bufAppendS("AEcharExpCat");

    bufAppendC(' ');

    shARITH_EXP(p->u.aecharexpcat_.arith_exp_);
  bufAppendC(' ');
    shCAT(p->u.aecharexpcat_.cat_);
  bufAppendC(' ');
    shCHAR_PRIM(p->u.aecharexpcat_.char_prim_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing CHAR_EXP!\n");
    exit(1);
  }
}

void shCHAR_PRIM(CHAR_PRIM p)
{
  switch(p->kind)
  {
  case is_AAchar_prim:
    bufAppendC('(');

    bufAppendS("AAchar_prim");

    bufAppendC(' ');

    shCHAR_VAR(p->u.aachar_prim_.char_var_);

    bufAppendC(')');

    break;
  case is_ABchar_prim:
    bufAppendC('(');

    bufAppendS("ABchar_prim");

    bufAppendC(' ');

    shCHAR_CONST(p->u.abchar_prim_.char_const_);

    bufAppendC(')');

    break;
  case is_AEchar_prim:
    bufAppendC('(');

    bufAppendS("AEchar_prim");

    bufAppendC(' ');

    shCHAR_FUNC_HEAD(p->u.aechar_prim_.char_func_head_);
  bufAppendC(' ');
    shCALL_LIST(p->u.aechar_prim_.call_list_);

    bufAppendC(')');

    break;
  case is_AFchar_prim:
    bufAppendC('(');

    bufAppendS("AFchar_prim");

    bufAppendC(' ');

    shCHAR_EXP(p->u.afchar_prim_.char_exp_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing CHAR_PRIM!\n");
    exit(1);
  }
}

void shCHAR_FUNC_HEAD(CHAR_FUNC_HEAD p)
{
  switch(p->kind)
  {
  case is_AAchar_func_head:
    bufAppendC('(');

    bufAppendS("AAchar_func_head");

    bufAppendC(' ');

    shCHAR_FUNC(p->u.aachar_func_head_.char_func_);

    bufAppendC(')');

    break;
  case is_ABchar_func_head:
    bufAppendC('(');

    bufAppendS("ABchar_func_head");

    bufAppendC(' ');

    shSUB_OR_QUALIFIER(p->u.abchar_func_head_.sub_or_qualifier_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing CHAR_FUNC_HEAD!\n");
    exit(1);
  }
}

void shCHAR_VAR(CHAR_VAR p)
{
  switch(p->kind)
  {
  case is_AAchar_var:
    bufAppendC('(');

    bufAppendS("AAchar_var");

    bufAppendC(' ');

    shCHAR_ID(p->u.aachar_var_.char_id_);

    bufAppendC(')');

    break;
  case is_ACchar_var:
    bufAppendC('(');

    bufAppendS("ACchar_var");

    bufAppendC(' ');

    shCHAR_ID(p->u.acchar_var_.char_id_);
  bufAppendC(' ');
    shSUBSCRIPT(p->u.acchar_var_.subscript_);

    bufAppendC(')');

    break;
  case is_ABchar_var:
    bufAppendC('(');

    bufAppendS("ABchar_var");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.abchar_var_.qual_struct_);
  bufAppendC(' ');
    shCHAR_ID(p->u.abchar_var_.char_id_);

    bufAppendC(')');

    break;
  case is_ADchar_var:
    bufAppendC('(');

    bufAppendS("ADchar_var");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.adchar_var_.qual_struct_);
  bufAppendC(' ');
    shCHAR_ID(p->u.adchar_var_.char_id_);
  bufAppendC(' ');
    shSUBSCRIPT(p->u.adchar_var_.subscript_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing CHAR_VAR!\n");
    exit(1);
  }
}

void shCHAR_CONST(CHAR_CONST p)
{
  switch(p->kind)
  {
  case is_AAchar_const:
    bufAppendC('(');

    bufAppendS("AAchar_const");

    bufAppendC(' ');

    shCHAR_STRING(p->u.aachar_const_.char_string_);

    bufAppendC(')');

    break;
  case is_ABchar_const:
    bufAppendC('(');

    bufAppendS("ABchar_const");

    bufAppendC(' ');

    shNUMBER(p->u.abchar_const_.number_);
  bufAppendC(' ');
    shCHAR_STRING(p->u.abchar_const_.char_string_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing CHAR_CONST!\n");
    exit(1);
  }
}

void shCHAR_FUNC(CHAR_FUNC p)
{
  switch(p->kind)
  {
  case is_ZZljust:

    bufAppendS("ZZljust");




    break;
  case is_ZZrjust:

    bufAppendS("ZZrjust");




    break;
  case is_ZZtrim:

    bufAppendS("ZZtrim");




    break;
  case is_ZZuserCharFunction:
    bufAppendC('(');

    bufAppendS("ZZuserCharFunction");

    bufAppendC(' ');

    shIdent(p->u.zzusercharfunction_.charfunctionidentifiertoken_);

    bufAppendC(')');

    break;
  case is_AAcharFuncCharacter:

    bufAppendS("AAcharFuncCharacter");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing CHAR_FUNC!\n");
    exit(1);
  }
}

void shCHAR_ID(CHAR_ID p)
{
  switch(p->kind)
  {
  case is_FIchar_id:
    bufAppendC('(');

    bufAppendS("FIchar_id");

    bufAppendC(' ');

    shIdent(p->u.fichar_id_.charidentifiertoken_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing CHAR_ID!\n");
    exit(1);
  }
}

void shNAME_EXP(NAME_EXP p)
{
  switch(p->kind)
  {
  case is_AAnameExpKeyVar:
    bufAppendC('(');

    bufAppendS("AAnameExpKeyVar");

    bufAppendC(' ');

    shNAME_KEY(p->u.aanameexpkeyvar_.name_key_);
  bufAppendC(' ');
    shNAME_VAR(p->u.aanameexpkeyvar_.name_var_);

    bufAppendC(')');

    break;
  case is_ABnameExpNull:

    bufAppendS("ABnameExpNull");




    break;
  case is_ACnameExpKeyNull:
    bufAppendC('(');

    bufAppendS("ACnameExpKeyNull");

    bufAppendC(' ');

    shNAME_KEY(p->u.acnameexpkeynull_.name_key_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing NAME_EXP!\n");
    exit(1);
  }
}

void shNAME_KEY(NAME_KEY p)
{
  switch(p->kind)
  {
  case is_AAname_key:

    bufAppendS("AAname_key");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing NAME_KEY!\n");
    exit(1);
  }
}

void shNAME_VAR(NAME_VAR p)
{
  switch(p->kind)
  {
  case is_AAname_var:
    bufAppendC('(');

    bufAppendS("AAname_var");

    bufAppendC(' ');

    shVARIABLE(p->u.aaname_var_.variable_);

    bufAppendC(')');

    break;
  case is_ACname_var:
    bufAppendC('(');

    bufAppendS("ACname_var");

    bufAppendC(' ');

    shMODIFIED_ARITH_FUNC(p->u.acname_var_.modified_arith_func_);

    bufAppendC(')');

    break;
  case is_ABname_var:
    bufAppendC('(');

    bufAppendS("ABname_var");

    bufAppendC(' ');

    shLABEL_VAR(p->u.abname_var_.label_var_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing NAME_VAR!\n");
    exit(1);
  }
}

void shVARIABLE(VARIABLE p)
{
  switch(p->kind)
  {
  case is_AAvariable:
    bufAppendC('(');

    bufAppendS("AAvariable");

    bufAppendC(' ');

    shARITH_VAR(p->u.aavariable_.arith_var_);

    bufAppendC(')');

    break;
  case is_ACvariable:
    bufAppendC('(');

    bufAppendS("ACvariable");

    bufAppendC(' ');

    shBIT_VAR(p->u.acvariable_.bit_var_);

    bufAppendC(')');

    break;
  case is_AEvariable:
    bufAppendC('(');

    bufAppendS("AEvariable");

    bufAppendC(' ');

    shSUBBIT_HEAD(p->u.aevariable_.subbit_head_);
  bufAppendC(' ');
    shVARIABLE(p->u.aevariable_.variable_);

    bufAppendC(')');

    break;
  case is_AFvariable:
    bufAppendC('(');

    bufAppendS("AFvariable");

    bufAppendC(' ');

    shCHAR_VAR(p->u.afvariable_.char_var_);

    bufAppendC(')');

    break;
  case is_AGvariable:
    bufAppendC('(');

    bufAppendS("AGvariable");

    bufAppendC(' ');

    shNAME_KEY(p->u.agvariable_.name_key_);
  bufAppendC(' ');
    shNAME_VAR(p->u.agvariable_.name_var_);

    bufAppendC(')');

    break;
  case is_ADvariable:
    bufAppendC('(');

    bufAppendS("ADvariable");

    bufAppendC(' ');

    shEVENT_VAR(p->u.advariable_.event_var_);

    bufAppendC(')');

    break;
  case is_ABvariable:
    bufAppendC('(');

    bufAppendS("ABvariable");

    bufAppendC(' ');

    shSTRUCTURE_VAR(p->u.abvariable_.structure_var_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing VARIABLE!\n");
    exit(1);
  }
}

void shSTRUCTURE_EXP(STRUCTURE_EXP p)
{
  switch(p->kind)
  {
  case is_AAstructure_exp:
    bufAppendC('(');

    bufAppendS("AAstructure_exp");

    bufAppendC(' ');

    shSTRUCTURE_VAR(p->u.aastructure_exp_.structure_var_);

    bufAppendC(')');

    break;
  case is_ADstructure_exp:
    bufAppendC('(');

    bufAppendS("ADstructure_exp");

    bufAppendC(' ');

    shSTRUCT_FUNC_HEAD(p->u.adstructure_exp_.struct_func_head_);
  bufAppendC(' ');
    shCALL_LIST(p->u.adstructure_exp_.call_list_);

    bufAppendC(')');

    break;
  case is_ACstructure_exp:
    bufAppendC('(');

    bufAppendS("ACstructure_exp");

    bufAppendC(' ');

    shSTRUC_INLINE_DEF(p->u.acstructure_exp_.struc_inline_def_);
  bufAppendC(' ');
    shCLOSING(p->u.acstructure_exp_.closing_);

    bufAppendC(')');

    break;
  case is_AEstructure_exp:
    bufAppendC('(');

    bufAppendS("AEstructure_exp");

    bufAppendC(' ');

    shSTRUC_INLINE_DEF(p->u.aestructure_exp_.struc_inline_def_);
  bufAppendC(' ');
    shBLOCK_BODY(p->u.aestructure_exp_.block_body_);
  bufAppendC(' ');
    shCLOSING(p->u.aestructure_exp_.closing_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing STRUCTURE_EXP!\n");
    exit(1);
  }
}

void shSTRUCT_FUNC_HEAD(STRUCT_FUNC_HEAD p)
{
  switch(p->kind)
  {
  case is_AAstruct_func_head:
    bufAppendC('(');

    bufAppendS("AAstruct_func_head");

    bufAppendC(' ');

    shSTRUCT_FUNC(p->u.aastruct_func_head_.struct_func_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing STRUCT_FUNC_HEAD!\n");
    exit(1);
  }
}

void shSTRUCTURE_VAR(STRUCTURE_VAR p)
{
  switch(p->kind)
  {
  case is_AAstructure_var:
    bufAppendC('(');

    bufAppendS("AAstructure_var");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.aastructure_var_.qual_struct_);
  bufAppendC(' ');
    shSUBSCRIPT(p->u.aastructure_var_.subscript_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing STRUCTURE_VAR!\n");
    exit(1);
  }
}

void shSTRUCT_FUNC(STRUCT_FUNC p)
{
  switch(p->kind)
  {
  case is_ZZuserStructFunc:
    bufAppendC('(');

    bufAppendS("ZZuserStructFunc");

    bufAppendC(' ');

    shIdent(p->u.zzuserstructfunc_.structfunctionidentifiertoken_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing STRUCT_FUNC!\n");
    exit(1);
  }
}

void shQUAL_STRUCT(QUAL_STRUCT p)
{
  switch(p->kind)
  {
  case is_AAqual_struct:
    bufAppendC('(');

    bufAppendS("AAqual_struct");

    bufAppendC(' ');

    shSTRUCTURE_ID(p->u.aaqual_struct_.structure_id_);

    bufAppendC(')');

    break;
  case is_ABqual_struct:
    bufAppendC('(');

    bufAppendS("ABqual_struct");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.abqual_struct_.qual_struct_);
  bufAppendC(' ');
    shSTRUCTURE_ID(p->u.abqual_struct_.structure_id_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing QUAL_STRUCT!\n");
    exit(1);
  }
}

void shSTRUCTURE_ID(STRUCTURE_ID p)
{
  switch(p->kind)
  {
  case is_FJstructure_id:
    bufAppendC('(');

    bufAppendS("FJstructure_id");

    bufAppendC(' ');

    shIdent(p->u.fjstructure_id_.structidentifiertoken_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing STRUCTURE_ID!\n");
    exit(1);
  }
}

void shASSIGNMENT(ASSIGNMENT p)
{
  switch(p->kind)
  {
  case is_AAassignment:
    bufAppendC('(');

    bufAppendS("AAassignment");

    bufAppendC(' ');

    shVARIABLE(p->u.aaassignment_.variable_);
  bufAppendC(' ');
    shEQUALS(p->u.aaassignment_.equals_);
  bufAppendC(' ');
    shEXPRESSION(p->u.aaassignment_.expression_);

    bufAppendC(')');

    break;
  case is_ABassignment:
    bufAppendC('(');

    bufAppendS("ABassignment");

    bufAppendC(' ');

    shVARIABLE(p->u.abassignment_.variable_);
  bufAppendC(' ');
    shASSIGNMENT(p->u.abassignment_.assignment_);

    bufAppendC(')');

    break;
  case is_ACassignment:
    bufAppendC('(');

    bufAppendS("ACassignment");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.acassignment_.qual_struct_);
  bufAppendC(' ');
    shEQUALS(p->u.acassignment_.equals_);
  bufAppendC(' ');
    shEXPRESSION(p->u.acassignment_.expression_);

    bufAppendC(')');

    break;
  case is_ADassignment:
    bufAppendC('(');

    bufAppendS("ADassignment");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.adassignment_.qual_struct_);
  bufAppendC(' ');
    shASSIGNMENT(p->u.adassignment_.assignment_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ASSIGNMENT!\n");
    exit(1);
  }
}

void shEQUALS(EQUALS p)
{
  switch(p->kind)
  {
  case is_AAequals:

    bufAppendS("AAequals");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing EQUALS!\n");
    exit(1);
  }
}

void shIF_STATEMENT(IF_STATEMENT p)
{
  switch(p->kind)
  {
  case is_AAifStatement:
    bufAppendC('(');

    bufAppendS("AAifStatement");

    bufAppendC(' ');

    shIF_CLAUSE(p->u.aaifstatement_.if_clause_);
  bufAppendC(' ');
    shSTATEMENT(p->u.aaifstatement_.statement_);

    bufAppendC(')');

    break;
  case is_ABifThenElseStatement:
    bufAppendC('(');

    bufAppendS("ABifThenElseStatement");

    bufAppendC(' ');

    shTRUE_PART(p->u.abifthenelsestatement_.true_part_);
  bufAppendC(' ');
    shSTATEMENT(p->u.abifthenelsestatement_.statement_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing IF_STATEMENT!\n");
    exit(1);
  }
}

void shIF_CLAUSE(IF_CLAUSE p)
{
  switch(p->kind)
  {
  case is_AAif_clause:
    bufAppendC('(');

    bufAppendS("AAif_clause");

    bufAppendC(' ');

    shIF(p->u.aaif_clause_.if_);
  bufAppendC(' ');
    shRELATIONAL_EXP(p->u.aaif_clause_.relational_exp_);
  bufAppendC(' ');
    shTHEN(p->u.aaif_clause_.then_);

    bufAppendC(')');

    break;
  case is_ABif_clause:
    bufAppendC('(');

    bufAppendS("ABif_clause");

    bufAppendC(' ');

    shIF(p->u.abif_clause_.if_);
  bufAppendC(' ');
    shBIT_EXP(p->u.abif_clause_.bit_exp_);
  bufAppendC(' ');
    shTHEN(p->u.abif_clause_.then_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing IF_CLAUSE!\n");
    exit(1);
  }
}

void shTRUE_PART(TRUE_PART p)
{
  switch(p->kind)
  {
  case is_AAtrue_part:
    bufAppendC('(');

    bufAppendS("AAtrue_part");

    bufAppendC(' ');

    shIF_CLAUSE(p->u.aatrue_part_.if_clause_);
  bufAppendC(' ');
    shBASIC_STATEMENT(p->u.aatrue_part_.basic_statement_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing TRUE_PART!\n");
    exit(1);
  }
}

void shIF(IF p)
{
  switch(p->kind)
  {
  case is_AAif:

    bufAppendS("AAif");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing IF!\n");
    exit(1);
  }
}

void shTHEN(THEN p)
{
  switch(p->kind)
  {
  case is_AAthen:

    bufAppendS("AAthen");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing THEN!\n");
    exit(1);
  }
}

void shRELATIONAL_EXP(RELATIONAL_EXP p)
{
  switch(p->kind)
  {
  case is_AArelational_exp:
    bufAppendC('(');

    bufAppendS("AArelational_exp");

    bufAppendC(' ');

    shRELATIONAL_FACTOR(p->u.aarelational_exp_.relational_factor_);

    bufAppendC(')');

    break;
  case is_ABrelational_exp:
    bufAppendC('(');

    bufAppendS("ABrelational_exp");

    bufAppendC(' ');

    shRELATIONAL_EXP(p->u.abrelational_exp_.relational_exp_);
  bufAppendC(' ');
    shOR(p->u.abrelational_exp_.or_);
  bufAppendC(' ');
    shRELATIONAL_FACTOR(p->u.abrelational_exp_.relational_factor_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing RELATIONAL_EXP!\n");
    exit(1);
  }
}

void shRELATIONAL_FACTOR(RELATIONAL_FACTOR p)
{
  switch(p->kind)
  {
  case is_AArelational_factor:
    bufAppendC('(');

    bufAppendS("AArelational_factor");

    bufAppendC(' ');

    shREL_PRIM(p->u.aarelational_factor_.rel_prim_);

    bufAppendC(')');

    break;
  case is_ABrelational_factor:
    bufAppendC('(');

    bufAppendS("ABrelational_factor");

    bufAppendC(' ');

    shRELATIONAL_FACTOR(p->u.abrelational_factor_.relational_factor_);
  bufAppendC(' ');
    shAND(p->u.abrelational_factor_.and_);
  bufAppendC(' ');
    shREL_PRIM(p->u.abrelational_factor_.rel_prim_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing RELATIONAL_FACTOR!\n");
    exit(1);
  }
}

void shREL_PRIM(REL_PRIM p)
{
  switch(p->kind)
  {
  case is_AArel_prim:
    bufAppendC('(');

    bufAppendS("AArel_prim");

    bufAppendC(' ');

    shRELATIONAL_EXP(p->u.aarel_prim_.relational_exp_);

    bufAppendC(')');

    break;
  case is_ABrel_prim:
    bufAppendC('(');

    bufAppendS("ABrel_prim");

    bufAppendC(' ');

    shNOT(p->u.abrel_prim_.not_);
  bufAppendC(' ');
    shRELATIONAL_EXP(p->u.abrel_prim_.relational_exp_);

    bufAppendC(')');

    break;
  case is_ACrel_prim:
    bufAppendC('(');

    bufAppendS("ACrel_prim");

    bufAppendC(' ');

    shCOMPARISON(p->u.acrel_prim_.comparison_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing REL_PRIM!\n");
    exit(1);
  }
}

void shCOMPARISON(COMPARISON p)
{
  switch(p->kind)
  {
  case is_AAcomparison:
    bufAppendC('(');

    bufAppendS("AAcomparison");

    bufAppendC(' ');

    shARITH_EXP(p->u.aacomparison_.arith_exp_1);
  bufAppendC(' ');
    shRELATIONAL_OP(p->u.aacomparison_.relational_op_);
  bufAppendC(' ');
    shARITH_EXP(p->u.aacomparison_.arith_exp_2);

    bufAppendC(')');

    break;
  case is_ABcomparison:
    bufAppendC('(');

    bufAppendS("ABcomparison");

    bufAppendC(' ');

    shCHAR_EXP(p->u.abcomparison_.char_exp_1);
  bufAppendC(' ');
    shRELATIONAL_OP(p->u.abcomparison_.relational_op_);
  bufAppendC(' ');
    shCHAR_EXP(p->u.abcomparison_.char_exp_2);

    bufAppendC(')');

    break;
  case is_ACcomparison:
    bufAppendC('(');

    bufAppendS("ACcomparison");

    bufAppendC(' ');

    shBIT_CAT(p->u.accomparison_.bit_cat_1);
  bufAppendC(' ');
    shRELATIONAL_OP(p->u.accomparison_.relational_op_);
  bufAppendC(' ');
    shBIT_CAT(p->u.accomparison_.bit_cat_2);

    bufAppendC(')');

    break;
  case is_ADcomparison:
    bufAppendC('(');

    bufAppendS("ADcomparison");

    bufAppendC(' ');

    shSTRUCTURE_EXP(p->u.adcomparison_.structure_exp_1);
  bufAppendC(' ');
    shRELATIONAL_OP(p->u.adcomparison_.relational_op_);
  bufAppendC(' ');
    shSTRUCTURE_EXP(p->u.adcomparison_.structure_exp_2);

    bufAppendC(')');

    break;
  case is_AEcomparison:
    bufAppendC('(');

    bufAppendS("AEcomparison");

    bufAppendC(' ');

    shNAME_EXP(p->u.aecomparison_.name_exp_1);
  bufAppendC(' ');
    shRELATIONAL_OP(p->u.aecomparison_.relational_op_);
  bufAppendC(' ');
    shNAME_EXP(p->u.aecomparison_.name_exp_2);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing COMPARISON!\n");
    exit(1);
  }
}

void shRELATIONAL_OP(RELATIONAL_OP p)
{
  switch(p->kind)
  {
  case is_AArelationalOpEQ:
    bufAppendC('(');

    bufAppendS("AArelationalOpEQ");

    bufAppendC(' ');

    shEQUALS(p->u.aarelationalopeq_.equals_);

    bufAppendC(')');

    break;
  case is_ABrelationalOpNEQ:
    bufAppendC('(');

    bufAppendS("ABrelationalOpNEQ");

    bufAppendC(' ');

    shNOT(p->u.abrelationalopneq_.not_);
  bufAppendC(' ');
    shEQUALS(p->u.abrelationalopneq_.equals_);

    bufAppendC(')');

    break;
  case is_ACrelationalOpLT:

    bufAppendS("ACrelationalOpLT");




    break;
  case is_ADrelationalOpGT:

    bufAppendS("ADrelationalOpGT");




    break;
  case is_AErelationalOpLE:

    bufAppendS("AErelationalOpLE");




    break;
  case is_AFrelationalOpGE:

    bufAppendS("AFrelationalOpGE");




    break;
  case is_AGrelationalOpNLT:
    bufAppendC('(');

    bufAppendS("AGrelationalOpNLT");

    bufAppendC(' ');

    shNOT(p->u.agrelationalopnlt_.not_);

    bufAppendC(')');

    break;
  case is_AHrelationalOpNGT:
    bufAppendC('(');

    bufAppendS("AHrelationalOpNGT");

    bufAppendC(' ');

    shNOT(p->u.ahrelationalopngt_.not_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing RELATIONAL_OP!\n");
    exit(1);
  }
}

void shSTATEMENT(STATEMENT p)
{
  switch(p->kind)
  {
  case is_AAstatement:
    bufAppendC('(');

    bufAppendS("AAstatement");

    bufAppendC(' ');

    shBASIC_STATEMENT(p->u.aastatement_.basic_statement_);

    bufAppendC(')');

    break;
  case is_ABstatement:
    bufAppendC('(');

    bufAppendS("ABstatement");

    bufAppendC(' ');

    shOTHER_STATEMENT(p->u.abstatement_.other_statement_);

    bufAppendC(')');

    break;
  case is_AZstatement:
    bufAppendC('(');

    bufAppendS("AZstatement");

    bufAppendC(' ');

    shINLINE_DEFINITION(p->u.azstatement_.inline_definition_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing STATEMENT!\n");
    exit(1);
  }
}

void shBASIC_STATEMENT(BASIC_STATEMENT p)
{
  switch(p->kind)
  {
  case is_ABbasicStatementAssignment:
    bufAppendC('(');

    bufAppendS("ABbasicStatementAssignment");

    bufAppendC(' ');

    shASSIGNMENT(p->u.abbasicstatementassignment_.assignment_);

    bufAppendC(')');

    break;
  case is_AAbasic_statement:
    bufAppendC('(');

    bufAppendS("AAbasic_statement");

    bufAppendC(' ');

    shLABEL_DEFINITION(p->u.aabasic_statement_.label_definition_);
  bufAppendC(' ');
    shBASIC_STATEMENT(p->u.aabasic_statement_.basic_statement_);

    bufAppendC(')');

    break;
  case is_ACbasicStatementExit:

    bufAppendS("ACbasicStatementExit");




    break;
  case is_ADbasicStatementExit:
    bufAppendC('(');

    bufAppendS("ADbasicStatementExit");

    bufAppendC(' ');

    shLABEL(p->u.adbasicstatementexit_.label_);

    bufAppendC(')');

    break;
  case is_AEbasicStatementRepeat:

    bufAppendS("AEbasicStatementRepeat");




    break;
  case is_AFbasicStatementRepeat:
    bufAppendC('(');

    bufAppendS("AFbasicStatementRepeat");

    bufAppendC(' ');

    shLABEL(p->u.afbasicstatementrepeat_.label_);

    bufAppendC(')');

    break;
  case is_AGbasicStatementGoTo:
    bufAppendC('(');

    bufAppendS("AGbasicStatementGoTo");

    bufAppendC(' ');

    shLABEL(p->u.agbasicstatementgoto_.label_);

    bufAppendC(')');

    break;
  case is_AHbasicStatementEmpty:

    bufAppendS("AHbasicStatementEmpty");




    break;
  case is_AIbasicStatementCall:
    bufAppendC('(');

    bufAppendS("AIbasicStatementCall");

    bufAppendC(' ');

    shCALL_KEY(p->u.aibasicstatementcall_.call_key_);

    bufAppendC(')');

    break;
  case is_AJbasicStatementCall:
    bufAppendC('(');

    bufAppendS("AJbasicStatementCall");

    bufAppendC(' ');

    shCALL_KEY(p->u.ajbasicstatementcall_.call_key_);
  bufAppendC(' ');
    shCALL_LIST(p->u.ajbasicstatementcall_.call_list_);

    bufAppendC(')');

    break;
  case is_AKbasicStatementCall:
    bufAppendC('(');

    bufAppendS("AKbasicStatementCall");

    bufAppendC(' ');

    shCALL_KEY(p->u.akbasicstatementcall_.call_key_);
  bufAppendC(' ');
    shASSIGN(p->u.akbasicstatementcall_.assign_);
  bufAppendC(' ');
    shCALL_ASSIGN_LIST(p->u.akbasicstatementcall_.call_assign_list_);

    bufAppendC(')');

    break;
  case is_ALbasicStatementCall:
    bufAppendC('(');

    bufAppendS("ALbasicStatementCall");

    bufAppendC(' ');

    shCALL_KEY(p->u.albasicstatementcall_.call_key_);
  bufAppendC(' ');
    shCALL_LIST(p->u.albasicstatementcall_.call_list_);
  bufAppendC(' ');
    shASSIGN(p->u.albasicstatementcall_.assign_);
  bufAppendC(' ');
    shCALL_ASSIGN_LIST(p->u.albasicstatementcall_.call_assign_list_);

    bufAppendC(')');

    break;
  case is_AMbasicStatementReturn:

    bufAppendS("AMbasicStatementReturn");




    break;
  case is_ANbasicStatementReturn:
    bufAppendC('(');

    bufAppendS("ANbasicStatementReturn");

    bufAppendC(' ');

    shEXPRESSION(p->u.anbasicstatementreturn_.expression_);

    bufAppendC(')');

    break;
  case is_AObasicStatementDo:
    bufAppendC('(');

    bufAppendS("AObasicStatementDo");

    bufAppendC(' ');

    shDO_GROUP_HEAD(p->u.aobasicstatementdo_.do_group_head_);
  bufAppendC(' ');
    shENDING(p->u.aobasicstatementdo_.ending_);

    bufAppendC(')');

    break;
  case is_APbasicStatementReadKey:
    bufAppendC('(');

    bufAppendS("APbasicStatementReadKey");

    bufAppendC(' ');

    shREAD_KEY(p->u.apbasicstatementreadkey_.read_key_);

    bufAppendC(')');

    break;
  case is_AQbasicStatementReadPhrase:
    bufAppendC('(');

    bufAppendS("AQbasicStatementReadPhrase");

    bufAppendC(' ');

    shREAD_PHRASE(p->u.aqbasicstatementreadphrase_.read_phrase_);

    bufAppendC(')');

    break;
  case is_ARbasicStatementWriteKey:
    bufAppendC('(');

    bufAppendS("ARbasicStatementWriteKey");

    bufAppendC(' ');

    shWRITE_KEY(p->u.arbasicstatementwritekey_.write_key_);

    bufAppendC(')');

    break;
  case is_ASbasicStatementWritePhrase:
    bufAppendC('(');

    bufAppendS("ASbasicStatementWritePhrase");

    bufAppendC(' ');

    shWRITE_PHRASE(p->u.asbasicstatementwritephrase_.write_phrase_);

    bufAppendC(')');

    break;
  case is_ATbasicStatementFileExp:
    bufAppendC('(');

    bufAppendS("ATbasicStatementFileExp");

    bufAppendC(' ');

    shFILE_EXP(p->u.atbasicstatementfileexp_.file_exp_);
  bufAppendC(' ');
    shEQUALS(p->u.atbasicstatementfileexp_.equals_);
  bufAppendC(' ');
    shEXPRESSION(p->u.atbasicstatementfileexp_.expression_);

    bufAppendC(')');

    break;
  case is_AUbasicStatementFileExp:
    bufAppendC('(');

    bufAppendS("AUbasicStatementFileExp");

    bufAppendC(' ');

    shVARIABLE(p->u.aubasicstatementfileexp_.variable_);
  bufAppendC(' ');
    shEQUALS(p->u.aubasicstatementfileexp_.equals_);
  bufAppendC(' ');
    shFILE_EXP(p->u.aubasicstatementfileexp_.file_exp_);

    bufAppendC(')');

    break;
  case is_AVbasicStatementFileExp:
    bufAppendC('(');

    bufAppendS("AVbasicStatementFileExp");

    bufAppendC(' ');

    shFILE_EXP(p->u.avbasicstatementfileexp_.file_exp_);
  bufAppendC(' ');
    shEQUALS(p->u.avbasicstatementfileexp_.equals_);
  bufAppendC(' ');
    shQUAL_STRUCT(p->u.avbasicstatementfileexp_.qual_struct_);

    bufAppendC(')');

    break;
  case is_AVbasicStatementWait:
    bufAppendC('(');

    bufAppendS("AVbasicStatementWait");

    bufAppendC(' ');

    shWAIT_KEY(p->u.avbasicstatementwait_.wait_key_);

    bufAppendC(')');

    break;
  case is_AWbasicStatementWait:
    bufAppendC('(');

    bufAppendS("AWbasicStatementWait");

    bufAppendC(' ');

    shWAIT_KEY(p->u.awbasicstatementwait_.wait_key_);
  bufAppendC(' ');
    shARITH_EXP(p->u.awbasicstatementwait_.arith_exp_);

    bufAppendC(')');

    break;
  case is_AXbasicStatementWait:
    bufAppendC('(');

    bufAppendS("AXbasicStatementWait");

    bufAppendC(' ');

    shWAIT_KEY(p->u.axbasicstatementwait_.wait_key_);
  bufAppendC(' ');
    shARITH_EXP(p->u.axbasicstatementwait_.arith_exp_);

    bufAppendC(')');

    break;
  case is_AYbasicStatementWait:
    bufAppendC('(');

    bufAppendS("AYbasicStatementWait");

    bufAppendC(' ');

    shWAIT_KEY(p->u.aybasicstatementwait_.wait_key_);
  bufAppendC(' ');
    shBIT_EXP(p->u.aybasicstatementwait_.bit_exp_);

    bufAppendC(')');

    break;
  case is_AZbasicStatementTerminator:
    bufAppendC('(');

    bufAppendS("AZbasicStatementTerminator");

    bufAppendC(' ');

    shTERMINATOR(p->u.azbasicstatementterminator_.terminator_);

    bufAppendC(')');

    break;
  case is_BAbasicStatementTerminator:
    bufAppendC('(');

    bufAppendS("BAbasicStatementTerminator");

    bufAppendC(' ');

    shTERMINATOR(p->u.babasicstatementterminator_.terminator_);
  bufAppendC(' ');
    shTERMINATE_LIST(p->u.babasicstatementterminator_.terminate_list_);

    bufAppendC(')');

    break;
  case is_BBbasicStatementUpdate:
    bufAppendC('(');

    bufAppendS("BBbasicStatementUpdate");

    bufAppendC(' ');

    shARITH_EXP(p->u.bbbasicstatementupdate_.arith_exp_);

    bufAppendC(')');

    break;
  case is_BCbasicStatementUpdate:
    bufAppendC('(');

    bufAppendS("BCbasicStatementUpdate");

    bufAppendC(' ');

    shLABEL_VAR(p->u.bcbasicstatementupdate_.label_var_);
  bufAppendC(' ');
    shARITH_EXP(p->u.bcbasicstatementupdate_.arith_exp_);

    bufAppendC(')');

    break;
  case is_BDbasicStatementSchedule:
    bufAppendC('(');

    bufAppendS("BDbasicStatementSchedule");

    bufAppendC(' ');

    shSCHEDULE_PHRASE(p->u.bdbasicstatementschedule_.schedule_phrase_);

    bufAppendC(')');

    break;
  case is_BEbasicStatementSchedule:
    bufAppendC('(');

    bufAppendS("BEbasicStatementSchedule");

    bufAppendC(' ');

    shSCHEDULE_PHRASE(p->u.bebasicstatementschedule_.schedule_phrase_);
  bufAppendC(' ');
    shSCHEDULE_CONTROL(p->u.bebasicstatementschedule_.schedule_control_);

    bufAppendC(')');

    break;
  case is_BFbasicStatementSignal:
    bufAppendC('(');

    bufAppendS("BFbasicStatementSignal");

    bufAppendC(' ');

    shSIGNAL_CLAUSE(p->u.bfbasicstatementsignal_.signal_clause_);

    bufAppendC(')');

    break;
  case is_BGbasicStatementSend:
    bufAppendC('(');

    bufAppendS("BGbasicStatementSend");

    bufAppendC(' ');

    shSUBSCRIPT(p->u.bgbasicstatementsend_.subscript_);

    bufAppendC(')');

    break;
  case is_BHbasicStatementSend:

    bufAppendS("BHbasicStatementSend");




    break;
  case is_BHbasicStatementOn:
    bufAppendC('(');

    bufAppendS("BHbasicStatementOn");

    bufAppendC(' ');

    shON_CLAUSE(p->u.bhbasicstatementon_.on_clause_);

    bufAppendC(')');

    break;
  case is_BIbasicStatementOnAndSignal:
    bufAppendC('(');

    bufAppendS("BIbasicStatementOnAndSignal");

    bufAppendC(' ');

    shON_CLAUSE(p->u.bibasicstatementonandsignal_.on_clause_);
  bufAppendC(' ');
    shSIGNAL_CLAUSE(p->u.bibasicstatementonandsignal_.signal_clause_);

    bufAppendC(')');

    break;
  case is_BJbasicStatementOff:
    bufAppendC('(');

    bufAppendS("BJbasicStatementOff");

    bufAppendC(' ');

    shSUBSCRIPT(p->u.bjbasicstatementoff_.subscript_);

    bufAppendC(')');

    break;
  case is_BKbasicStatementOff:

    bufAppendS("BKbasicStatementOff");




    break;
  case is_BKbasicStatementPercentMacro:
    bufAppendC('(');

    bufAppendS("BKbasicStatementPercentMacro");

    bufAppendC(' ');

    shPERCENT_MACRO_NAME(p->u.bkbasicstatementpercentmacro_.percent_macro_name_);

    bufAppendC(')');

    break;
  case is_BLbasicStatementPercentMacro:
    bufAppendC('(');

    bufAppendS("BLbasicStatementPercentMacro");

    bufAppendC(' ');

    shPERCENT_MACRO_HEAD(p->u.blbasicstatementpercentmacro_.percent_macro_head_);
  bufAppendC(' ');
    shPERCENT_MACRO_ARG(p->u.blbasicstatementpercentmacro_.percent_macro_arg_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BASIC_STATEMENT!\n");
    exit(1);
  }
}

void shOTHER_STATEMENT(OTHER_STATEMENT p)
{
  switch(p->kind)
  {
  case is_ABotherStatementIf:
    bufAppendC('(');

    bufAppendS("ABotherStatementIf");

    bufAppendC(' ');

    shIF_STATEMENT(p->u.abotherstatementif_.if_statement_);

    bufAppendC(')');

    break;
  case is_AAotherStatementOn:
    bufAppendC('(');

    bufAppendS("AAotherStatementOn");

    bufAppendC(' ');

    shON_PHRASE(p->u.aaotherstatementon_.on_phrase_);
  bufAppendC(' ');
    shSTATEMENT(p->u.aaotherstatementon_.statement_);

    bufAppendC(')');

    break;
  case is_ACother_statement:
    bufAppendC('(');

    bufAppendS("ACother_statement");

    bufAppendC(' ');

    shLABEL_DEFINITION(p->u.acother_statement_.label_definition_);
  bufAppendC(' ');
    shOTHER_STATEMENT(p->u.acother_statement_.other_statement_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing OTHER_STATEMENT!\n");
    exit(1);
  }
}

void shANY_STATEMENT(ANY_STATEMENT p)
{
  switch(p->kind)
  {
  case is_AAany_statement:
    bufAppendC('(');

    bufAppendS("AAany_statement");

    bufAppendC(' ');

    shSTATEMENT(p->u.aaany_statement_.statement_);

    bufAppendC(')');

    break;
  case is_ABany_statement:
    bufAppendC('(');

    bufAppendS("ABany_statement");

    bufAppendC(' ');

    shBLOCK_DEFINITION(p->u.abany_statement_.block_definition_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ANY_STATEMENT!\n");
    exit(1);
  }
}

void shON_PHRASE(ON_PHRASE p)
{
  switch(p->kind)
  {
  case is_AAon_phrase:
    bufAppendC('(');

    bufAppendS("AAon_phrase");

    bufAppendC(' ');

    shSUBSCRIPT(p->u.aaon_phrase_.subscript_);

    bufAppendC(')');

    break;
  case is_ACon_phrase:

    bufAppendS("ACon_phrase");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ON_PHRASE!\n");
    exit(1);
  }
}

void shON_CLAUSE(ON_CLAUSE p)
{
  switch(p->kind)
  {
  case is_AAon_clause:
    bufAppendC('(');

    bufAppendS("AAon_clause");

    bufAppendC(' ');

    shSUBSCRIPT(p->u.aaon_clause_.subscript_);

    bufAppendC(')');

    break;
  case is_ABon_clause:
    bufAppendC('(');

    bufAppendS("ABon_clause");

    bufAppendC(' ');

    shSUBSCRIPT(p->u.abon_clause_.subscript_);

    bufAppendC(')');

    break;
  case is_ADon_clause:

    bufAppendS("ADon_clause");




    break;
  case is_AEon_clause:

    bufAppendS("AEon_clause");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ON_CLAUSE!\n");
    exit(1);
  }
}

void shLABEL_DEFINITION(LABEL_DEFINITION p)
{
  switch(p->kind)
  {
  case is_AAlabel_definition:
    bufAppendC('(');

    bufAppendS("AAlabel_definition");

    bufAppendC(' ');

    shLABEL(p->u.aalabel_definition_.label_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing LABEL_DEFINITION!\n");
    exit(1);
  }
}

void shCALL_KEY(CALL_KEY p)
{
  switch(p->kind)
  {
  case is_AAcall_key:
    bufAppendC('(');

    bufAppendS("AAcall_key");

    bufAppendC(' ');

    shLABEL_VAR(p->u.aacall_key_.label_var_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing CALL_KEY!\n");
    exit(1);
  }
}

void shASSIGN(ASSIGN p)
{
  switch(p->kind)
  {
  case is_AAassign:

    bufAppendS("AAassign");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ASSIGN!\n");
    exit(1);
  }
}

void shCALL_ASSIGN_LIST(CALL_ASSIGN_LIST p)
{
  switch(p->kind)
  {
  case is_AAcall_assign_list:
    bufAppendC('(');

    bufAppendS("AAcall_assign_list");

    bufAppendC(' ');

    shVARIABLE(p->u.aacall_assign_list_.variable_);

    bufAppendC(')');

    break;
  case is_ABcall_assign_list:
    bufAppendC('(');

    bufAppendS("ABcall_assign_list");

    bufAppendC(' ');

    shCALL_ASSIGN_LIST(p->u.abcall_assign_list_.call_assign_list_);
  bufAppendC(' ');
    shVARIABLE(p->u.abcall_assign_list_.variable_);

    bufAppendC(')');

    break;
  case is_ACcall_assign_list:
    bufAppendC('(');

    bufAppendS("ACcall_assign_list");

    bufAppendC(' ');

    shQUAL_STRUCT(p->u.accall_assign_list_.qual_struct_);

    bufAppendC(')');

    break;
  case is_ADcall_assign_list:
    bufAppendC('(');

    bufAppendS("ADcall_assign_list");

    bufAppendC(' ');

    shCALL_ASSIGN_LIST(p->u.adcall_assign_list_.call_assign_list_);
  bufAppendC(' ');
    shQUAL_STRUCT(p->u.adcall_assign_list_.qual_struct_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing CALL_ASSIGN_LIST!\n");
    exit(1);
  }
}

void shDO_GROUP_HEAD(DO_GROUP_HEAD p)
{
  switch(p->kind)
  {
  case is_AAdoGroupHead:

    bufAppendS("AAdoGroupHead");




    break;
  case is_ABdoGroupHeadFor:
    bufAppendC('(');

    bufAppendS("ABdoGroupHeadFor");

    bufAppendC(' ');

    shFOR_LIST(p->u.abdogroupheadfor_.for_list_);

    bufAppendC(')');

    break;
  case is_ACdoGroupHeadForWhile:
    bufAppendC('(');

    bufAppendS("ACdoGroupHeadForWhile");

    bufAppendC(' ');

    shFOR_LIST(p->u.acdogroupheadforwhile_.for_list_);
  bufAppendC(' ');
    shWHILE_CLAUSE(p->u.acdogroupheadforwhile_.while_clause_);

    bufAppendC(')');

    break;
  case is_ADdoGroupHeadWhile:
    bufAppendC('(');

    bufAppendS("ADdoGroupHeadWhile");

    bufAppendC(' ');

    shWHILE_CLAUSE(p->u.addogroupheadwhile_.while_clause_);

    bufAppendC(')');

    break;
  case is_AEdoGroupHeadCase:
    bufAppendC('(');

    bufAppendS("AEdoGroupHeadCase");

    bufAppendC(' ');

    shARITH_EXP(p->u.aedogroupheadcase_.arith_exp_);

    bufAppendC(')');

    break;
  case is_AFdoGroupHeadCaseElse:
    bufAppendC('(');

    bufAppendS("AFdoGroupHeadCaseElse");

    bufAppendC(' ');

    shCASE_ELSE(p->u.afdogroupheadcaseelse_.case_else_);
  bufAppendC(' ');
    shSTATEMENT(p->u.afdogroupheadcaseelse_.statement_);

    bufAppendC(')');

    break;
  case is_AGdoGroupHeadStatement:
    bufAppendC('(');

    bufAppendS("AGdoGroupHeadStatement");

    bufAppendC(' ');

    shDO_GROUP_HEAD(p->u.agdogroupheadstatement_.do_group_head_);
  bufAppendC(' ');
    shANY_STATEMENT(p->u.agdogroupheadstatement_.any_statement_);

    bufAppendC(')');

    break;
  case is_AHdoGroupHeadTemporaryStatement:
    bufAppendC('(');

    bufAppendS("AHdoGroupHeadTemporaryStatement");

    bufAppendC(' ');

    shDO_GROUP_HEAD(p->u.ahdogroupheadtemporarystatement_.do_group_head_);
  bufAppendC(' ');
    shTEMPORARY_STMT(p->u.ahdogroupheadtemporarystatement_.temporary_stmt_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing DO_GROUP_HEAD!\n");
    exit(1);
  }
}

void shENDING(ENDING p)
{
  switch(p->kind)
  {
  case is_AAending:

    bufAppendS("AAending");




    break;
  case is_ABending:
    bufAppendC('(');

    bufAppendS("ABending");

    bufAppendC(' ');

    shLABEL(p->u.abending_.label_);

    bufAppendC(')');

    break;
  case is_ACending:
    bufAppendC('(');

    bufAppendS("ACending");

    bufAppendC(' ');

    shLABEL_DEFINITION(p->u.acending_.label_definition_);
  bufAppendC(' ');
    shENDING(p->u.acending_.ending_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ENDING!\n");
    exit(1);
  }
}

void shREAD_KEY(READ_KEY p)
{
  switch(p->kind)
  {
  case is_AAread_key:
    bufAppendC('(');

    bufAppendS("AAread_key");

    bufAppendC(' ');

    shNUMBER(p->u.aaread_key_.number_);

    bufAppendC(')');

    break;
  case is_ABread_key:
    bufAppendC('(');

    bufAppendS("ABread_key");

    bufAppendC(' ');

    shNUMBER(p->u.abread_key_.number_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing READ_KEY!\n");
    exit(1);
  }
}

void shWRITE_KEY(WRITE_KEY p)
{
  switch(p->kind)
  {
  case is_AAwrite_key:
    bufAppendC('(');

    bufAppendS("AAwrite_key");

    bufAppendC(' ');

    shNUMBER(p->u.aawrite_key_.number_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing WRITE_KEY!\n");
    exit(1);
  }
}

void shREAD_PHRASE(READ_PHRASE p)
{
  switch(p->kind)
  {
  case is_AAread_phrase:
    bufAppendC('(');

    bufAppendS("AAread_phrase");

    bufAppendC(' ');

    shREAD_KEY(p->u.aaread_phrase_.read_key_);
  bufAppendC(' ');
    shREAD_ARG(p->u.aaread_phrase_.read_arg_);

    bufAppendC(')');

    break;
  case is_ABread_phrase:
    bufAppendC('(');

    bufAppendS("ABread_phrase");

    bufAppendC(' ');

    shREAD_PHRASE(p->u.abread_phrase_.read_phrase_);
  bufAppendC(' ');
    shREAD_ARG(p->u.abread_phrase_.read_arg_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing READ_PHRASE!\n");
    exit(1);
  }
}

void shWRITE_PHRASE(WRITE_PHRASE p)
{
  switch(p->kind)
  {
  case is_AAwrite_phrase:
    bufAppendC('(');

    bufAppendS("AAwrite_phrase");

    bufAppendC(' ');

    shWRITE_KEY(p->u.aawrite_phrase_.write_key_);
  bufAppendC(' ');
    shWRITE_ARG(p->u.aawrite_phrase_.write_arg_);

    bufAppendC(')');

    break;
  case is_ABwrite_phrase:
    bufAppendC('(');

    bufAppendS("ABwrite_phrase");

    bufAppendC(' ');

    shWRITE_PHRASE(p->u.abwrite_phrase_.write_phrase_);
  bufAppendC(' ');
    shWRITE_ARG(p->u.abwrite_phrase_.write_arg_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing WRITE_PHRASE!\n");
    exit(1);
  }
}

void shREAD_ARG(READ_ARG p)
{
  switch(p->kind)
  {
  case is_AAread_arg:
    bufAppendC('(');

    bufAppendS("AAread_arg");

    bufAppendC(' ');

    shVARIABLE(p->u.aaread_arg_.variable_);

    bufAppendC(')');

    break;
  case is_ABread_arg:
    bufAppendC('(');

    bufAppendS("ABread_arg");

    bufAppendC(' ');

    shIO_CONTROL(p->u.abread_arg_.io_control_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing READ_ARG!\n");
    exit(1);
  }
}

void shWRITE_ARG(WRITE_ARG p)
{
  switch(p->kind)
  {
  case is_AAwrite_arg:
    bufAppendC('(');

    bufAppendS("AAwrite_arg");

    bufAppendC(' ');

    shEXPRESSION(p->u.aawrite_arg_.expression_);

    bufAppendC(')');

    break;
  case is_ABwrite_arg:
    bufAppendC('(');

    bufAppendS("ABwrite_arg");

    bufAppendC(' ');

    shIO_CONTROL(p->u.abwrite_arg_.io_control_);

    bufAppendC(')');

    break;
  case is_ACwrite_arg:
    bufAppendC('(');

    bufAppendS("ACwrite_arg");

    bufAppendC(' ');

    shIdent(p->u.acwrite_arg_.structidentifiertoken_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing WRITE_ARG!\n");
    exit(1);
  }
}

void shFILE_EXP(FILE_EXP p)
{
  switch(p->kind)
  {
  case is_AAfile_exp:
    bufAppendC('(');

    bufAppendS("AAfile_exp");

    bufAppendC(' ');

    shFILE_HEAD(p->u.aafile_exp_.file_head_);
  bufAppendC(' ');
    shARITH_EXP(p->u.aafile_exp_.arith_exp_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing FILE_EXP!\n");
    exit(1);
  }
}

void shFILE_HEAD(FILE_HEAD p)
{
  switch(p->kind)
  {
  case is_AAfile_head:
    bufAppendC('(');

    bufAppendS("AAfile_head");

    bufAppendC(' ');

    shNUMBER(p->u.aafile_head_.number_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing FILE_HEAD!\n");
    exit(1);
  }
}

void shIO_CONTROL(IO_CONTROL p)
{
  switch(p->kind)
  {
  case is_AAioControlSkip:
    bufAppendC('(');

    bufAppendS("AAioControlSkip");

    bufAppendC(' ');

    shARITH_EXP(p->u.aaiocontrolskip_.arith_exp_);

    bufAppendC(')');

    break;
  case is_ABioControlTab:
    bufAppendC('(');

    bufAppendS("ABioControlTab");

    bufAppendC(' ');

    shARITH_EXP(p->u.abiocontroltab_.arith_exp_);

    bufAppendC(')');

    break;
  case is_ACioControlColumn:
    bufAppendC('(');

    bufAppendS("ACioControlColumn");

    bufAppendC(' ');

    shARITH_EXP(p->u.aciocontrolcolumn_.arith_exp_);

    bufAppendC(')');

    break;
  case is_ADioControlLine:
    bufAppendC('(');

    bufAppendS("ADioControlLine");

    bufAppendC(' ');

    shARITH_EXP(p->u.adiocontrolline_.arith_exp_);

    bufAppendC(')');

    break;
  case is_AEioControlPage:
    bufAppendC('(');

    bufAppendS("AEioControlPage");

    bufAppendC(' ');

    shARITH_EXP(p->u.aeiocontrolpage_.arith_exp_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing IO_CONTROL!\n");
    exit(1);
  }
}

void shWAIT_KEY(WAIT_KEY p)
{
  switch(p->kind)
  {
  case is_AAwait_key:

    bufAppendS("AAwait_key");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing WAIT_KEY!\n");
    exit(1);
  }
}

void shTERMINATOR(TERMINATOR p)
{
  switch(p->kind)
  {
  case is_AAterminatorTerminate:

    bufAppendS("AAterminatorTerminate");




    break;
  case is_ABterminatorCancel:

    bufAppendS("ABterminatorCancel");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing TERMINATOR!\n");
    exit(1);
  }
}

void shTERMINATE_LIST(TERMINATE_LIST p)
{
  switch(p->kind)
  {
  case is_AAterminate_list:
    bufAppendC('(');

    bufAppendS("AAterminate_list");

    bufAppendC(' ');

    shLABEL_VAR(p->u.aaterminate_list_.label_var_);

    bufAppendC(')');

    break;
  case is_ABterminate_list:
    bufAppendC('(');

    bufAppendS("ABterminate_list");

    bufAppendC(' ');

    shTERMINATE_LIST(p->u.abterminate_list_.terminate_list_);
  bufAppendC(' ');
    shLABEL_VAR(p->u.abterminate_list_.label_var_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing TERMINATE_LIST!\n");
    exit(1);
  }
}

void shSCHEDULE_HEAD(SCHEDULE_HEAD p)
{
  switch(p->kind)
  {
  case is_AAscheduleHeadLabel:
    bufAppendC('(');

    bufAppendS("AAscheduleHeadLabel");

    bufAppendC(' ');

    shLABEL_VAR(p->u.aascheduleheadlabel_.label_var_);

    bufAppendC(')');

    break;
  case is_ABscheduleHeadAt:
    bufAppendC('(');

    bufAppendS("ABscheduleHeadAt");

    bufAppendC(' ');

    shSCHEDULE_HEAD(p->u.abscheduleheadat_.schedule_head_);
  bufAppendC(' ');
    shARITH_EXP(p->u.abscheduleheadat_.arith_exp_);

    bufAppendC(')');

    break;
  case is_ACscheduleHeadIn:
    bufAppendC('(');

    bufAppendS("ACscheduleHeadIn");

    bufAppendC(' ');

    shSCHEDULE_HEAD(p->u.acscheduleheadin_.schedule_head_);
  bufAppendC(' ');
    shARITH_EXP(p->u.acscheduleheadin_.arith_exp_);

    bufAppendC(')');

    break;
  case is_ADscheduleHeadOn:
    bufAppendC('(');

    bufAppendS("ADscheduleHeadOn");

    bufAppendC(' ');

    shSCHEDULE_HEAD(p->u.adscheduleheadon_.schedule_head_);
  bufAppendC(' ');
    shBIT_EXP(p->u.adscheduleheadon_.bit_exp_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing SCHEDULE_HEAD!\n");
    exit(1);
  }
}

void shSCHEDULE_PHRASE(SCHEDULE_PHRASE p)
{
  switch(p->kind)
  {
  case is_AAschedule_phrase:
    bufAppendC('(');

    bufAppendS("AAschedule_phrase");

    bufAppendC(' ');

    shSCHEDULE_HEAD(p->u.aaschedule_phrase_.schedule_head_);

    bufAppendC(')');

    break;
  case is_ABschedule_phrase:
    bufAppendC('(');

    bufAppendS("ABschedule_phrase");

    bufAppendC(' ');

    shSCHEDULE_HEAD(p->u.abschedule_phrase_.schedule_head_);
  bufAppendC(' ');
    shARITH_EXP(p->u.abschedule_phrase_.arith_exp_);

    bufAppendC(')');

    break;
  case is_ACschedule_phrase:
    bufAppendC('(');

    bufAppendS("ACschedule_phrase");

    bufAppendC(' ');

    shSCHEDULE_PHRASE(p->u.acschedule_phrase_.schedule_phrase_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing SCHEDULE_PHRASE!\n");
    exit(1);
  }
}

void shSCHEDULE_CONTROL(SCHEDULE_CONTROL p)
{
  switch(p->kind)
  {
  case is_AAschedule_control:
    bufAppendC('(');

    bufAppendS("AAschedule_control");

    bufAppendC(' ');

    shSTOPPING(p->u.aaschedule_control_.stopping_);

    bufAppendC(')');

    break;
  case is_ABschedule_control:
    bufAppendC('(');

    bufAppendS("ABschedule_control");

    bufAppendC(' ');

    shTIMING(p->u.abschedule_control_.timing_);

    bufAppendC(')');

    break;
  case is_ACschedule_control:
    bufAppendC('(');

    bufAppendS("ACschedule_control");

    bufAppendC(' ');

    shTIMING(p->u.acschedule_control_.timing_);
  bufAppendC(' ');
    shSTOPPING(p->u.acschedule_control_.stopping_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing SCHEDULE_CONTROL!\n");
    exit(1);
  }
}

void shTIMING(TIMING p)
{
  switch(p->kind)
  {
  case is_AAtimingEvery:
    bufAppendC('(');

    bufAppendS("AAtimingEvery");

    bufAppendC(' ');

    shREPEAT(p->u.aatimingevery_.repeat_);
  bufAppendC(' ');
    shARITH_EXP(p->u.aatimingevery_.arith_exp_);

    bufAppendC(')');

    break;
  case is_ABtimingAfter:
    bufAppendC('(');

    bufAppendS("ABtimingAfter");

    bufAppendC(' ');

    shREPEAT(p->u.abtimingafter_.repeat_);
  bufAppendC(' ');
    shARITH_EXP(p->u.abtimingafter_.arith_exp_);

    bufAppendC(')');

    break;
  case is_ACtiming:
    bufAppendC('(');

    bufAppendS("ACtiming");

    bufAppendC(' ');

    shREPEAT(p->u.actiming_.repeat_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing TIMING!\n");
    exit(1);
  }
}

void shREPEAT(REPEAT p)
{
  switch(p->kind)
  {
  case is_AArepeat:

    bufAppendS("AArepeat");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing REPEAT!\n");
    exit(1);
  }
}

void shSTOPPING(STOPPING p)
{
  switch(p->kind)
  {
  case is_AAstopping:
    bufAppendC('(');

    bufAppendS("AAstopping");

    bufAppendC(' ');

    shWHILE_KEY(p->u.aastopping_.while_key_);
  bufAppendC(' ');
    shARITH_EXP(p->u.aastopping_.arith_exp_);

    bufAppendC(')');

    break;
  case is_ABstopping:
    bufAppendC('(');

    bufAppendS("ABstopping");

    bufAppendC(' ');

    shWHILE_KEY(p->u.abstopping_.while_key_);
  bufAppendC(' ');
    shBIT_EXP(p->u.abstopping_.bit_exp_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing STOPPING!\n");
    exit(1);
  }
}

void shSIGNAL_CLAUSE(SIGNAL_CLAUSE p)
{
  switch(p->kind)
  {
  case is_AAsignal_clause:
    bufAppendC('(');

    bufAppendS("AAsignal_clause");

    bufAppendC(' ');

    shEVENT_VAR(p->u.aasignal_clause_.event_var_);

    bufAppendC(')');

    break;
  case is_ABsignal_clause:
    bufAppendC('(');

    bufAppendS("ABsignal_clause");

    bufAppendC(' ');

    shEVENT_VAR(p->u.absignal_clause_.event_var_);

    bufAppendC(')');

    break;
  case is_ACsignal_clause:
    bufAppendC('(');

    bufAppendS("ACsignal_clause");

    bufAppendC(' ');

    shEVENT_VAR(p->u.acsignal_clause_.event_var_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing SIGNAL_CLAUSE!\n");
    exit(1);
  }
}

void shPERCENT_MACRO_NAME(PERCENT_MACRO_NAME p)
{
  switch(p->kind)
  {
  case is_FNpercent_macro_name:
    bufAppendC('(');

    bufAppendS("FNpercent_macro_name");

    bufAppendC(' ');

    shIDENTIFIER(p->u.fnpercent_macro_name_.identifier_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing PERCENT_MACRO_NAME!\n");
    exit(1);
  }
}

void shPERCENT_MACRO_HEAD(PERCENT_MACRO_HEAD p)
{
  switch(p->kind)
  {
  case is_AApercent_macro_head:
    bufAppendC('(');

    bufAppendS("AApercent_macro_head");

    bufAppendC(' ');

    shPERCENT_MACRO_NAME(p->u.aapercent_macro_head_.percent_macro_name_);

    bufAppendC(')');

    break;
  case is_ABpercent_macro_head:
    bufAppendC('(');

    bufAppendS("ABpercent_macro_head");

    bufAppendC(' ');

    shPERCENT_MACRO_HEAD(p->u.abpercent_macro_head_.percent_macro_head_);
  bufAppendC(' ');
    shPERCENT_MACRO_ARG(p->u.abpercent_macro_head_.percent_macro_arg_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing PERCENT_MACRO_HEAD!\n");
    exit(1);
  }
}

void shPERCENT_MACRO_ARG(PERCENT_MACRO_ARG p)
{
  switch(p->kind)
  {
  case is_AApercent_macro_arg:
    bufAppendC('(');

    bufAppendS("AApercent_macro_arg");

    bufAppendC(' ');

    shNAME_VAR(p->u.aapercent_macro_arg_.name_var_);

    bufAppendC(')');

    break;
  case is_ABpercent_macro_arg:
    bufAppendC('(');

    bufAppendS("ABpercent_macro_arg");

    bufAppendC(' ');

    shCONSTANT(p->u.abpercent_macro_arg_.constant_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing PERCENT_MACRO_ARG!\n");
    exit(1);
  }
}

void shCASE_ELSE(CASE_ELSE p)
{
  switch(p->kind)
  {
  case is_AAcase_else:
    bufAppendC('(');

    bufAppendS("AAcase_else");

    bufAppendC(' ');

    shARITH_EXP(p->u.aacase_else_.arith_exp_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing CASE_ELSE!\n");
    exit(1);
  }
}

void shWHILE_KEY(WHILE_KEY p)
{
  switch(p->kind)
  {
  case is_AAwhileKeyWhile:

    bufAppendS("AAwhileKeyWhile");




    break;
  case is_ABwhileKeyUntil:

    bufAppendS("ABwhileKeyUntil");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing WHILE_KEY!\n");
    exit(1);
  }
}

void shWHILE_CLAUSE(WHILE_CLAUSE p)
{
  switch(p->kind)
  {
  case is_AAwhile_clause:
    bufAppendC('(');

    bufAppendS("AAwhile_clause");

    bufAppendC(' ');

    shWHILE_KEY(p->u.aawhile_clause_.while_key_);
  bufAppendC(' ');
    shBIT_EXP(p->u.aawhile_clause_.bit_exp_);

    bufAppendC(')');

    break;
  case is_ABwhile_clause:
    bufAppendC('(');

    bufAppendS("ABwhile_clause");

    bufAppendC(' ');

    shWHILE_KEY(p->u.abwhile_clause_.while_key_);
  bufAppendC(' ');
    shRELATIONAL_EXP(p->u.abwhile_clause_.relational_exp_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing WHILE_CLAUSE!\n");
    exit(1);
  }
}

void shFOR_LIST(FOR_LIST p)
{
  switch(p->kind)
  {
  case is_AAfor_list:
    bufAppendC('(');

    bufAppendS("AAfor_list");

    bufAppendC(' ');

    shFOR_KEY(p->u.aafor_list_.for_key_);
  bufAppendC(' ');
    shARITH_EXP(p->u.aafor_list_.arith_exp_);
  bufAppendC(' ');
    shITERATION_CONTROL(p->u.aafor_list_.iteration_control_);

    bufAppendC(')');

    break;
  case is_ABfor_list:
    bufAppendC('(');

    bufAppendS("ABfor_list");

    bufAppendC(' ');

    shFOR_KEY(p->u.abfor_list_.for_key_);
  bufAppendC(' ');
    shITERATION_BODY(p->u.abfor_list_.iteration_body_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing FOR_LIST!\n");
    exit(1);
  }
}

void shITERATION_BODY(ITERATION_BODY p)
{
  switch(p->kind)
  {
  case is_AAiteration_body:
    bufAppendC('(');

    bufAppendS("AAiteration_body");

    bufAppendC(' ');

    shARITH_EXP(p->u.aaiteration_body_.arith_exp_);

    bufAppendC(')');

    break;
  case is_ABiteration_body:
    bufAppendC('(');

    bufAppendS("ABiteration_body");

    bufAppendC(' ');

    shITERATION_BODY(p->u.abiteration_body_.iteration_body_);
  bufAppendC(' ');
    shARITH_EXP(p->u.abiteration_body_.arith_exp_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ITERATION_BODY!\n");
    exit(1);
  }
}

void shITERATION_CONTROL(ITERATION_CONTROL p)
{
  switch(p->kind)
  {
  case is_AAiteration_controlTo:
    bufAppendC('(');

    bufAppendS("AAiteration_controlTo");

    bufAppendC(' ');

    shARITH_EXP(p->u.aaiteration_controlto_.arith_exp_);

    bufAppendC(')');

    break;
  case is_ABiteration_controlToBy:
    bufAppendC('(');

    bufAppendS("ABiteration_controlToBy");

    bufAppendC(' ');

    shARITH_EXP(p->u.abiteration_controltoby_.arith_exp_1);
  bufAppendC(' ');
    shARITH_EXP(p->u.abiteration_controltoby_.arith_exp_2);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ITERATION_CONTROL!\n");
    exit(1);
  }
}

void shFOR_KEY(FOR_KEY p)
{
  switch(p->kind)
  {
  case is_AAforKey:
    bufAppendC('(');

    bufAppendS("AAforKey");

    bufAppendC(' ');

    shARITH_VAR(p->u.aaforkey_.arith_var_);
  bufAppendC(' ');
    shEQUALS(p->u.aaforkey_.equals_);

    bufAppendC(')');

    break;
  case is_ABforKeyTemporary:
    bufAppendC('(');

    bufAppendS("ABforKeyTemporary");

    bufAppendC(' ');

    shIDENTIFIER(p->u.abforkeytemporary_.identifier_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing FOR_KEY!\n");
    exit(1);
  }
}

void shTEMPORARY_STMT(TEMPORARY_STMT p)
{
  switch(p->kind)
  {
  case is_AAtemporary_stmt:
    bufAppendC('(');

    bufAppendS("AAtemporary_stmt");

    bufAppendC(' ');

    shDECLARE_BODY(p->u.aatemporary_stmt_.declare_body_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing TEMPORARY_STMT!\n");
    exit(1);
  }
}

void shCONSTANT(CONSTANT p)
{
  switch(p->kind)
  {
  case is_AAconstant:
    bufAppendC('(');

    bufAppendS("AAconstant");

    bufAppendC(' ');

    shNUMBER(p->u.aaconstant_.number_);

    bufAppendC(')');

    break;
  case is_ABconstant:
    bufAppendC('(');

    bufAppendS("ABconstant");

    bufAppendC(' ');

    shCOMPOUND_NUMBER(p->u.abconstant_.compound_number_);

    bufAppendC(')');

    break;
  case is_ACconstant:
    bufAppendC('(');

    bufAppendS("ACconstant");

    bufAppendC(' ');

    shBIT_CONST(p->u.acconstant_.bit_const_);

    bufAppendC(')');

    break;
  case is_ADconstant:
    bufAppendC('(');

    bufAppendS("ADconstant");

    bufAppendC(' ');

    shCHAR_CONST(p->u.adconstant_.char_const_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing CONSTANT!\n");
    exit(1);
  }
}

void shARRAY_HEAD(ARRAY_HEAD p)
{
  switch(p->kind)
  {
  case is_AAarray_head:

    bufAppendS("AAarray_head");




    break;
  case is_ABarray_head:
    bufAppendC('(');

    bufAppendS("ABarray_head");

    bufAppendC(' ');

    shARRAY_HEAD(p->u.abarray_head_.array_head_);
  bufAppendC(' ');
    shLITERAL_EXP_OR_STAR(p->u.abarray_head_.literal_exp_or_star_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ARRAY_HEAD!\n");
    exit(1);
  }
}

void shMINOR_ATTR_LIST(MINOR_ATTR_LIST p)
{
  switch(p->kind)
  {
  case is_AAminor_attr_list:
    bufAppendC('(');

    bufAppendS("AAminor_attr_list");

    bufAppendC(' ');

    shMINOR_ATTRIBUTE(p->u.aaminor_attr_list_.minor_attribute_);

    bufAppendC(')');

    break;
  case is_ABminor_attr_list:
    bufAppendC('(');

    bufAppendS("ABminor_attr_list");

    bufAppendC(' ');

    shMINOR_ATTR_LIST(p->u.abminor_attr_list_.minor_attr_list_);
  bufAppendC(' ');
    shMINOR_ATTRIBUTE(p->u.abminor_attr_list_.minor_attribute_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing MINOR_ATTR_LIST!\n");
    exit(1);
  }
}

void shMINOR_ATTRIBUTE(MINOR_ATTRIBUTE p)
{
  switch(p->kind)
  {
  case is_AAminorAttributeStatic:

    bufAppendS("AAminorAttributeStatic");




    break;
  case is_ABminorAttributeAutomatic:

    bufAppendS("ABminorAttributeAutomatic");




    break;
  case is_ACminorAttributeDense:

    bufAppendS("ACminorAttributeDense");




    break;
  case is_ADminorAttributeAligned:

    bufAppendS("ADminorAttributeAligned");




    break;
  case is_AEminorAttributeAccess:

    bufAppendS("AEminorAttributeAccess");




    break;
  case is_AFminorAttributeLock:
    bufAppendC('(');

    bufAppendS("AFminorAttributeLock");

    bufAppendC(' ');

    shLITERAL_EXP_OR_STAR(p->u.afminorattributelock_.literal_exp_or_star_);

    bufAppendC(')');

    break;
  case is_AGminorAttributeRemote:

    bufAppendS("AGminorAttributeRemote");




    break;
  case is_AHminorAttributeRigid:

    bufAppendS("AHminorAttributeRigid");




    break;
  case is_AIminorAttributeRepeatedConstant:
    bufAppendC('(');

    bufAppendS("AIminorAttributeRepeatedConstant");

    bufAppendC(' ');

    shINIT_OR_CONST_HEAD(p->u.aiminorattributerepeatedconstant_.init_or_const_head_);
  bufAppendC(' ');
    shREPEATED_CONSTANT(p->u.aiminorattributerepeatedconstant_.repeated_constant_);

    bufAppendC(')');

    break;
  case is_AJminorAttributeStar:
    bufAppendC('(');

    bufAppendS("AJminorAttributeStar");

    bufAppendC(' ');

    shINIT_OR_CONST_HEAD(p->u.ajminorattributestar_.init_or_const_head_);

    bufAppendC(')');

    break;
  case is_AKminorAttributeLatched:

    bufAppendS("AKminorAttributeLatched");




    break;
  case is_ALminorAttributeNonHal:
    bufAppendC('(');

    bufAppendS("ALminorAttributeNonHal");

    bufAppendC(' ');

    shLEVEL(p->u.alminorattributenonhal_.level_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing MINOR_ATTRIBUTE!\n");
    exit(1);
  }
}

void shINIT_OR_CONST_HEAD(INIT_OR_CONST_HEAD p)
{
  switch(p->kind)
  {
  case is_AAinit_or_const_headInitial:

    bufAppendS("AAinit_or_const_headInitial");




    break;
  case is_ABinit_or_const_headConstant:

    bufAppendS("ABinit_or_const_headConstant");




    break;
  case is_ACinit_or_const_headRepeatedConstant:
    bufAppendC('(');

    bufAppendS("ACinit_or_const_headRepeatedConstant");

    bufAppendC(' ');

    shINIT_OR_CONST_HEAD(p->u.acinit_or_const_headrepeatedconstant_.init_or_const_head_);
  bufAppendC(' ');
    shREPEATED_CONSTANT(p->u.acinit_or_const_headrepeatedconstant_.repeated_constant_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing INIT_OR_CONST_HEAD!\n");
    exit(1);
  }
}

void shREPEATED_CONSTANT(REPEATED_CONSTANT p)
{
  switch(p->kind)
  {
  case is_AArepeated_constant:
    bufAppendC('(');

    bufAppendS("AArepeated_constant");

    bufAppendC(' ');

    shEXPRESSION(p->u.aarepeated_constant_.expression_);

    bufAppendC(')');

    break;
  case is_ABrepeated_constant:
    bufAppendC('(');

    bufAppendS("ABrepeated_constant");

    bufAppendC(' ');

    shREPEAT_HEAD(p->u.abrepeated_constant_.repeat_head_);
  bufAppendC(' ');
    shVARIABLE(p->u.abrepeated_constant_.variable_);

    bufAppendC(')');

    break;
  case is_ACrepeated_constant:
    bufAppendC('(');

    bufAppendS("ACrepeated_constant");

    bufAppendC(' ');

    shREPEAT_HEAD(p->u.acrepeated_constant_.repeat_head_);
  bufAppendC(' ');
    shCONSTANT(p->u.acrepeated_constant_.constant_);

    bufAppendC(')');

    break;
  case is_ADrepeated_constant:
    bufAppendC('(');

    bufAppendS("ADrepeated_constant");

    bufAppendC(' ');

    shNESTED_REPEAT_HEAD(p->u.adrepeated_constant_.nested_repeat_head_);
  bufAppendC(' ');
    shREPEATED_CONSTANT(p->u.adrepeated_constant_.repeated_constant_);

    bufAppendC(')');

    break;
  case is_AErepeated_constant:
    bufAppendC('(');

    bufAppendS("AErepeated_constant");

    bufAppendC(' ');

    shREPEAT_HEAD(p->u.aerepeated_constant_.repeat_head_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing REPEATED_CONSTANT!\n");
    exit(1);
  }
}

void shREPEAT_HEAD(REPEAT_HEAD p)
{
  switch(p->kind)
  {
  case is_AArepeat_head:
    bufAppendC('(');

    bufAppendS("AArepeat_head");

    bufAppendC(' ');

    shARITH_EXP(p->u.aarepeat_head_.arith_exp_);
  bufAppendC(' ');
    shSIMPLE_NUMBER(p->u.aarepeat_head_.simple_number_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing REPEAT_HEAD!\n");
    exit(1);
  }
}

void shNESTED_REPEAT_HEAD(NESTED_REPEAT_HEAD p)
{
  switch(p->kind)
  {
  case is_AAnested_repeat_head:
    bufAppendC('(');

    bufAppendS("AAnested_repeat_head");

    bufAppendC(' ');

    shREPEAT_HEAD(p->u.aanested_repeat_head_.repeat_head_);

    bufAppendC(')');

    break;
  case is_ABnested_repeat_head:
    bufAppendC('(');

    bufAppendS("ABnested_repeat_head");

    bufAppendC(' ');

    shNESTED_REPEAT_HEAD(p->u.abnested_repeat_head_.nested_repeat_head_);
  bufAppendC(' ');
    shREPEATED_CONSTANT(p->u.abnested_repeat_head_.repeated_constant_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing NESTED_REPEAT_HEAD!\n");
    exit(1);
  }
}

void shDCL_LIST_COMMA(DCL_LIST_COMMA p)
{
  switch(p->kind)
  {
  case is_AAdcl_list_comma:
    bufAppendC('(');

    bufAppendS("AAdcl_list_comma");

    bufAppendC(' ');

    shDECLARATION_LIST(p->u.aadcl_list_comma_.declaration_list_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing DCL_LIST_COMMA!\n");
    exit(1);
  }
}

void shLITERAL_EXP_OR_STAR(LITERAL_EXP_OR_STAR p)
{
  switch(p->kind)
  {
  case is_AAliteralExp:
    bufAppendC('(');

    bufAppendS("AAliteralExp");

    bufAppendC(' ');

    shARITH_EXP(p->u.aaliteralexp_.arith_exp_);

    bufAppendC(')');

    break;
  case is_ABliteralStar:

    bufAppendS("ABliteralStar");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing LITERAL_EXP_OR_STAR!\n");
    exit(1);
  }
}

void shTYPE_SPEC(TYPE_SPEC p)
{
  switch(p->kind)
  {
  case is_AAtypeSpecStruct:
    bufAppendC('(');

    bufAppendS("AAtypeSpecStruct");

    bufAppendC(' ');

    shSTRUCT_SPEC(p->u.aatypespecstruct_.struct_spec_);

    bufAppendC(')');

    break;
  case is_ABtypeSpecBit:
    bufAppendC('(');

    bufAppendS("ABtypeSpecBit");

    bufAppendC(' ');

    shBIT_SPEC(p->u.abtypespecbit_.bit_spec_);

    bufAppendC(')');

    break;
  case is_ACtypeSpecChar:
    bufAppendC('(');

    bufAppendS("ACtypeSpecChar");

    bufAppendC(' ');

    shCHAR_SPEC(p->u.actypespecchar_.char_spec_);

    bufAppendC(')');

    break;
  case is_ADtypeSpecArith:
    bufAppendC('(');

    bufAppendS("ADtypeSpecArith");

    bufAppendC(' ');

    shARITH_SPEC(p->u.adtypespecarith_.arith_spec_);

    bufAppendC(')');

    break;
  case is_AEtypeSpecEvent:

    bufAppendS("AEtypeSpecEvent");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing TYPE_SPEC!\n");
    exit(1);
  }
}

void shBIT_SPEC(BIT_SPEC p)
{
  switch(p->kind)
  {
  case is_AAbitSpecBoolean:

    bufAppendS("AAbitSpecBoolean");




    break;
  case is_ABbitSpecBoolean:
    bufAppendC('(');

    bufAppendS("ABbitSpecBoolean");

    bufAppendC(' ');

    shLITERAL_EXP_OR_STAR(p->u.abbitspecboolean_.literal_exp_or_star_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BIT_SPEC!\n");
    exit(1);
  }
}

void shCHAR_SPEC(CHAR_SPEC p)
{
  switch(p->kind)
  {
  case is_AAchar_spec:
    bufAppendC('(');

    bufAppendS("AAchar_spec");

    bufAppendC(' ');

    shLITERAL_EXP_OR_STAR(p->u.aachar_spec_.literal_exp_or_star_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing CHAR_SPEC!\n");
    exit(1);
  }
}

void shSTRUCT_SPEC(STRUCT_SPEC p)
{
  switch(p->kind)
  {
  case is_AAstruct_spec:
    bufAppendC('(');

    bufAppendS("AAstruct_spec");

    bufAppendC(' ');

    shSTRUCT_TEMPLATE(p->u.aastruct_spec_.struct_template_);
  bufAppendC(' ');
    shSTRUCT_SPEC_BODY(p->u.aastruct_spec_.struct_spec_body_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing STRUCT_SPEC!\n");
    exit(1);
  }
}

void shSTRUCT_SPEC_BODY(STRUCT_SPEC_BODY p)
{
  switch(p->kind)
  {
  case is_AAstruct_spec_body:

    bufAppendS("AAstruct_spec_body");




    break;
  case is_ABstruct_spec_body:
    bufAppendC('(');

    bufAppendS("ABstruct_spec_body");

    bufAppendC(' ');

    shSTRUCT_SPEC_HEAD(p->u.abstruct_spec_body_.struct_spec_head_);
  bufAppendC(' ');
    shLITERAL_EXP_OR_STAR(p->u.abstruct_spec_body_.literal_exp_or_star_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing STRUCT_SPEC_BODY!\n");
    exit(1);
  }
}

void shSTRUCT_TEMPLATE(STRUCT_TEMPLATE p)
{
  switch(p->kind)
  {
  case is_FMstruct_template:
    bufAppendC('(');

    bufAppendS("FMstruct_template");

    bufAppendC(' ');

    shSTRUCTURE_ID(p->u.fmstruct_template_.structure_id_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing STRUCT_TEMPLATE!\n");
    exit(1);
  }
}

void shSTRUCT_SPEC_HEAD(STRUCT_SPEC_HEAD p)
{
  switch(p->kind)
  {
  case is_AAstruct_spec_head:

    bufAppendS("AAstruct_spec_head");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing STRUCT_SPEC_HEAD!\n");
    exit(1);
  }
}

void shARITH_SPEC(ARITH_SPEC p)
{
  switch(p->kind)
  {
  case is_AAarith_spec:
    bufAppendC('(');

    bufAppendS("AAarith_spec");

    bufAppendC(' ');

    shPREC_SPEC(p->u.aaarith_spec_.prec_spec_);

    bufAppendC(')');

    break;
  case is_ABarith_spec:
    bufAppendC('(');

    bufAppendS("ABarith_spec");

    bufAppendC(' ');

    shSQ_DQ_NAME(p->u.abarith_spec_.sq_dq_name_);

    bufAppendC(')');

    break;
  case is_ACarith_spec:
    bufAppendC('(');

    bufAppendS("ACarith_spec");

    bufAppendC(' ');

    shSQ_DQ_NAME(p->u.acarith_spec_.sq_dq_name_);
  bufAppendC(' ');
    shPREC_SPEC(p->u.acarith_spec_.prec_spec_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ARITH_SPEC!\n");
    exit(1);
  }
}

void shCOMPILATION(COMPILATION p)
{
  switch(p->kind)
  {
  case is_AAcompilation:
    bufAppendC('(');

    bufAppendS("AAcompilation");

    bufAppendC(' ');

    shANY_STATEMENT(p->u.aacompilation_.any_statement_);

    bufAppendC(')');

    break;
  case is_ABcompilation:
    bufAppendC('(');

    bufAppendS("ABcompilation");

    bufAppendC(' ');

    shCOMPILATION(p->u.abcompilation_.compilation_);
  bufAppendC(' ');
    shANY_STATEMENT(p->u.abcompilation_.any_statement_);

    bufAppendC(')');

    break;
  case is_ACcompilation:
    bufAppendC('(');

    bufAppendS("ACcompilation");

    bufAppendC(' ');

    shDECLARE_STATEMENT(p->u.accompilation_.declare_statement_);

    bufAppendC(')');

    break;
  case is_ADcompilation:
    bufAppendC('(');

    bufAppendS("ADcompilation");

    bufAppendC(' ');

    shCOMPILATION(p->u.adcompilation_.compilation_);
  bufAppendC(' ');
    shDECLARE_STATEMENT(p->u.adcompilation_.declare_statement_);

    bufAppendC(')');

    break;
  case is_AEcompilation:
    bufAppendC('(');

    bufAppendS("AEcompilation");

    bufAppendC(' ');

    shSTRUCTURE_STMT(p->u.aecompilation_.structure_stmt_);

    bufAppendC(')');

    break;
  case is_AFcompilation:
    bufAppendC('(');

    bufAppendS("AFcompilation");

    bufAppendC(' ');

    shCOMPILATION(p->u.afcompilation_.compilation_);
  bufAppendC(' ');
    shSTRUCTURE_STMT(p->u.afcompilation_.structure_stmt_);

    bufAppendC(')');

    break;
  case is_AGcompilation:
    bufAppendC('(');

    bufAppendS("AGcompilation");

    bufAppendC(' ');

    shREPLACE_STMT(p->u.agcompilation_.replace_stmt_);

    bufAppendC(')');

    break;
  case is_AHcompilation:
    bufAppendC('(');

    bufAppendS("AHcompilation");

    bufAppendC(' ');

    shCOMPILATION(p->u.ahcompilation_.compilation_);
  bufAppendC(' ');
    shREPLACE_STMT(p->u.ahcompilation_.replace_stmt_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing COMPILATION!\n");
    exit(1);
  }
}

void shBLOCK_DEFINITION(BLOCK_DEFINITION p)
{
  switch(p->kind)
  {
  case is_AAblock_definition:
    bufAppendC('(');

    bufAppendS("AAblock_definition");

    bufAppendC(' ');

    shBLOCK_STMT(p->u.aablock_definition_.block_stmt_);
  bufAppendC(' ');
    shCLOSING(p->u.aablock_definition_.closing_);

    bufAppendC(')');

    break;
  case is_ABblock_definition:
    bufAppendC('(');

    bufAppendS("ABblock_definition");

    bufAppendC(' ');

    shBLOCK_STMT(p->u.abblock_definition_.block_stmt_);
  bufAppendC(' ');
    shBLOCK_BODY(p->u.abblock_definition_.block_body_);
  bufAppendC(' ');
    shCLOSING(p->u.abblock_definition_.closing_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BLOCK_DEFINITION!\n");
    exit(1);
  }
}

void shBLOCK_STMT(BLOCK_STMT p)
{
  switch(p->kind)
  {
  case is_AAblock_stmt:
    bufAppendC('(');

    bufAppendS("AAblock_stmt");

    bufAppendC(' ');

    shBLOCK_STMT_TOP(p->u.aablock_stmt_.block_stmt_top_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BLOCK_STMT!\n");
    exit(1);
  }
}

void shBLOCK_STMT_TOP(BLOCK_STMT_TOP p)
{
  switch(p->kind)
  {
  case is_AAblockTopAccess:
    bufAppendC('(');

    bufAppendS("AAblockTopAccess");

    bufAppendC(' ');

    shBLOCK_STMT_TOP(p->u.aablocktopaccess_.block_stmt_top_);

    bufAppendC(')');

    break;
  case is_ABblockTopRigid:
    bufAppendC('(');

    bufAppendS("ABblockTopRigid");

    bufAppendC(' ');

    shBLOCK_STMT_TOP(p->u.abblocktoprigid_.block_stmt_top_);

    bufAppendC(')');

    break;
  case is_ACblockTopHead:
    bufAppendC('(');

    bufAppendS("ACblockTopHead");

    bufAppendC(' ');

    shBLOCK_STMT_HEAD(p->u.acblocktophead_.block_stmt_head_);

    bufAppendC(')');

    break;
  case is_ADblockTopExclusive:
    bufAppendC('(');

    bufAppendS("ADblockTopExclusive");

    bufAppendC(' ');

    shBLOCK_STMT_HEAD(p->u.adblocktopexclusive_.block_stmt_head_);

    bufAppendC(')');

    break;
  case is_AEblockTopReentrant:
    bufAppendC('(');

    bufAppendS("AEblockTopReentrant");

    bufAppendC(' ');

    shBLOCK_STMT_HEAD(p->u.aeblocktopreentrant_.block_stmt_head_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BLOCK_STMT_TOP!\n");
    exit(1);
  }
}

void shBLOCK_STMT_HEAD(BLOCK_STMT_HEAD p)
{
  switch(p->kind)
  {
  case is_AAblockHeadProgram:
    bufAppendC('(');

    bufAppendS("AAblockHeadProgram");

    bufAppendC(' ');

    shLABEL_EXTERNAL(p->u.aablockheadprogram_.label_external_);

    bufAppendC(')');

    break;
  case is_ABblockHeadCompool:
    bufAppendC('(');

    bufAppendS("ABblockHeadCompool");

    bufAppendC(' ');

    shLABEL_EXTERNAL(p->u.abblockheadcompool_.label_external_);

    bufAppendC(')');

    break;
  case is_ACblockHeadTask:
    bufAppendC('(');

    bufAppendS("ACblockHeadTask");

    bufAppendC(' ');

    shLABEL_DEFINITION(p->u.acblockheadtask_.label_definition_);

    bufAppendC(')');

    break;
  case is_ADblockHeadUpdate:
    bufAppendC('(');

    bufAppendS("ADblockHeadUpdate");

    bufAppendC(' ');

    shLABEL_DEFINITION(p->u.adblockheadupdate_.label_definition_);

    bufAppendC(')');

    break;
  case is_AEblockHeadUpdate:

    bufAppendS("AEblockHeadUpdate");




    break;
  case is_AFblockHeadFunction:
    bufAppendC('(');

    bufAppendS("AFblockHeadFunction");

    bufAppendC(' ');

    shFUNCTION_NAME(p->u.afblockheadfunction_.function_name_);

    bufAppendC(')');

    break;
  case is_AGblockHeadFunction:
    bufAppendC('(');

    bufAppendS("AGblockHeadFunction");

    bufAppendC(' ');

    shFUNCTION_NAME(p->u.agblockheadfunction_.function_name_);
  bufAppendC(' ');
    shFUNC_STMT_BODY(p->u.agblockheadfunction_.func_stmt_body_);

    bufAppendC(')');

    break;
  case is_AHblockHeadProcedure:
    bufAppendC('(');

    bufAppendS("AHblockHeadProcedure");

    bufAppendC(' ');

    shPROCEDURE_NAME(p->u.ahblockheadprocedure_.procedure_name_);

    bufAppendC(')');

    break;
  case is_AIblockHeadProcedure:
    bufAppendC('(');

    bufAppendS("AIblockHeadProcedure");

    bufAppendC(' ');

    shPROCEDURE_NAME(p->u.aiblockheadprocedure_.procedure_name_);
  bufAppendC(' ');
    shPROC_STMT_BODY(p->u.aiblockheadprocedure_.proc_stmt_body_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BLOCK_STMT_HEAD!\n");
    exit(1);
  }
}

void shLABEL_EXTERNAL(LABEL_EXTERNAL p)
{
  switch(p->kind)
  {
  case is_AAlabel_external:
    bufAppendC('(');

    bufAppendS("AAlabel_external");

    bufAppendC(' ');

    shLABEL_DEFINITION(p->u.aalabel_external_.label_definition_);

    bufAppendC(')');

    break;
  case is_ABlabel_external:
    bufAppendC('(');

    bufAppendS("ABlabel_external");

    bufAppendC(' ');

    shLABEL_DEFINITION(p->u.ablabel_external_.label_definition_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing LABEL_EXTERNAL!\n");
    exit(1);
  }
}

void shCLOSING(CLOSING p)
{
  switch(p->kind)
  {
  case is_AAclosing:

    bufAppendS("AAclosing");




    break;
  case is_ABclosing:
    bufAppendC('(');

    bufAppendS("ABclosing");

    bufAppendC(' ');

    shLABEL(p->u.abclosing_.label_);

    bufAppendC(')');

    break;
  case is_ACclosing:
    bufAppendC('(');

    bufAppendS("ACclosing");

    bufAppendC(' ');

    shLABEL_DEFINITION(p->u.acclosing_.label_definition_);
  bufAppendC(' ');
    shCLOSING(p->u.acclosing_.closing_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing CLOSING!\n");
    exit(1);
  }
}

void shBLOCK_BODY(BLOCK_BODY p)
{
  switch(p->kind)
  {
  case is_ABblock_body:
    bufAppendC('(');

    bufAppendS("ABblock_body");

    bufAppendC(' ');

    shDECLARE_GROUP(p->u.abblock_body_.declare_group_);

    bufAppendC(')');

    break;
  case is_ADblock_body:
    bufAppendC('(');

    bufAppendS("ADblock_body");

    bufAppendC(' ');

    shANY_STATEMENT(p->u.adblock_body_.any_statement_);

    bufAppendC(')');

    break;
  case is_ACblock_body:
    bufAppendC('(');

    bufAppendS("ACblock_body");

    bufAppendC(' ');

    shBLOCK_BODY(p->u.acblock_body_.block_body_);
  bufAppendC(' ');
    shANY_STATEMENT(p->u.acblock_body_.any_statement_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BLOCK_BODY!\n");
    exit(1);
  }
}

void shFUNCTION_NAME(FUNCTION_NAME p)
{
  switch(p->kind)
  {
  case is_AAfunction_name:
    bufAppendC('(');

    bufAppendS("AAfunction_name");

    bufAppendC(' ');

    shLABEL_EXTERNAL(p->u.aafunction_name_.label_external_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing FUNCTION_NAME!\n");
    exit(1);
  }
}

void shPROCEDURE_NAME(PROCEDURE_NAME p)
{
  switch(p->kind)
  {
  case is_AAprocedure_name:
    bufAppendC('(');

    bufAppendS("AAprocedure_name");

    bufAppendC(' ');

    shLABEL_EXTERNAL(p->u.aaprocedure_name_.label_external_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing PROCEDURE_NAME!\n");
    exit(1);
  }
}

void shFUNC_STMT_BODY(FUNC_STMT_BODY p)
{
  switch(p->kind)
  {
  case is_AAfunc_stmt_body:
    bufAppendC('(');

    bufAppendS("AAfunc_stmt_body");

    bufAppendC(' ');

    shPARAMETER_LIST(p->u.aafunc_stmt_body_.parameter_list_);

    bufAppendC(')');

    break;
  case is_ABfunc_stmt_body:
    bufAppendC('(');

    bufAppendS("ABfunc_stmt_body");

    bufAppendC(' ');

    shTYPE_SPEC(p->u.abfunc_stmt_body_.type_spec_);

    bufAppendC(')');

    break;
  case is_ACfunc_stmt_body:
    bufAppendC('(');

    bufAppendS("ACfunc_stmt_body");

    bufAppendC(' ');

    shPARAMETER_LIST(p->u.acfunc_stmt_body_.parameter_list_);
  bufAppendC(' ');
    shTYPE_SPEC(p->u.acfunc_stmt_body_.type_spec_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing FUNC_STMT_BODY!\n");
    exit(1);
  }
}

void shPROC_STMT_BODY(PROC_STMT_BODY p)
{
  switch(p->kind)
  {
  case is_AAproc_stmt_body:
    bufAppendC('(');

    bufAppendS("AAproc_stmt_body");

    bufAppendC(' ');

    shPARAMETER_LIST(p->u.aaproc_stmt_body_.parameter_list_);

    bufAppendC(')');

    break;
  case is_ABproc_stmt_body:
    bufAppendC('(');

    bufAppendS("ABproc_stmt_body");

    bufAppendC(' ');

    shASSIGN_LIST(p->u.abproc_stmt_body_.assign_list_);

    bufAppendC(')');

    break;
  case is_ACproc_stmt_body:
    bufAppendC('(');

    bufAppendS("ACproc_stmt_body");

    bufAppendC(' ');

    shPARAMETER_LIST(p->u.acproc_stmt_body_.parameter_list_);
  bufAppendC(' ');
    shASSIGN_LIST(p->u.acproc_stmt_body_.assign_list_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing PROC_STMT_BODY!\n");
    exit(1);
  }
}

void shDECLARE_GROUP(DECLARE_GROUP p)
{
  switch(p->kind)
  {
  case is_AAdeclare_group:
    bufAppendC('(');

    bufAppendS("AAdeclare_group");

    bufAppendC(' ');

    shDECLARE_ELEMENT(p->u.aadeclare_group_.declare_element_);

    bufAppendC(')');

    break;
  case is_ABdeclare_group:
    bufAppendC('(');

    bufAppendS("ABdeclare_group");

    bufAppendC(' ');

    shDECLARE_GROUP(p->u.abdeclare_group_.declare_group_);
  bufAppendC(' ');
    shDECLARE_ELEMENT(p->u.abdeclare_group_.declare_element_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing DECLARE_GROUP!\n");
    exit(1);
  }
}

void shDECLARE_ELEMENT(DECLARE_ELEMENT p)
{
  switch(p->kind)
  {
  case is_AAdeclareElementDeclare:
    bufAppendC('(');

    bufAppendS("AAdeclareElementDeclare");

    bufAppendC(' ');

    shDECLARE_STATEMENT(p->u.aadeclareelementdeclare_.declare_statement_);

    bufAppendC(')');

    break;
  case is_ABdeclareElementReplace:
    bufAppendC('(');

    bufAppendS("ABdeclareElementReplace");

    bufAppendC(' ');

    shREPLACE_STMT(p->u.abdeclareelementreplace_.replace_stmt_);

    bufAppendC(')');

    break;
  case is_ACdeclareElementStructure:
    bufAppendC('(');

    bufAppendS("ACdeclareElementStructure");

    bufAppendC(' ');

    shSTRUCTURE_STMT(p->u.acdeclareelementstructure_.structure_stmt_);

    bufAppendC(')');

    break;
  case is_ADdeclareElementEquate:
    bufAppendC('(');

    bufAppendS("ADdeclareElementEquate");

    bufAppendC(' ');

    shIDENTIFIER(p->u.addeclareelementequate_.identifier_);
  bufAppendC(' ');
    shVARIABLE(p->u.addeclareelementequate_.variable_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing DECLARE_ELEMENT!\n");
    exit(1);
  }
}

void shPARAMETER(PARAMETER p)
{
  switch(p->kind)
  {
  case is_AAparameter:
    bufAppendC('(');

    bufAppendS("AAparameter");

    bufAppendC(' ');

    shIdent(p->u.aaparameter_.identifiertoken_);

    bufAppendC(')');

    break;
  case is_ABparameter:
    bufAppendC('(');

    bufAppendS("ABparameter");

    bufAppendC(' ');

    shIdent(p->u.abparameter_.bitidentifiertoken_);

    bufAppendC(')');

    break;
  case is_ACparameter:
    bufAppendC('(');

    bufAppendS("ACparameter");

    bufAppendC(' ');

    shIdent(p->u.acparameter_.charidentifiertoken_);

    bufAppendC(')');

    break;
  case is_ADparameter:
    bufAppendC('(');

    bufAppendS("ADparameter");

    bufAppendC(' ');

    shIdent(p->u.adparameter_.structidentifiertoken_);

    bufAppendC(')');

    break;
  case is_AEparameter:
    bufAppendC('(');

    bufAppendS("AEparameter");

    bufAppendC(' ');

    shIdent(p->u.aeparameter_.eventtoken_);

    bufAppendC(')');

    break;
  case is_AFparameter:
    bufAppendC('(');

    bufAppendS("AFparameter");

    bufAppendC(' ');

    shIdent(p->u.afparameter_.labeltoken_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing PARAMETER!\n");
    exit(1);
  }
}

void shPARAMETER_LIST(PARAMETER_LIST p)
{
  switch(p->kind)
  {
  case is_AAparameter_list:
    bufAppendC('(');

    bufAppendS("AAparameter_list");

    bufAppendC(' ');

    shPARAMETER_HEAD(p->u.aaparameter_list_.parameter_head_);
  bufAppendC(' ');
    shPARAMETER(p->u.aaparameter_list_.parameter_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing PARAMETER_LIST!\n");
    exit(1);
  }
}

void shPARAMETER_HEAD(PARAMETER_HEAD p)
{
  switch(p->kind)
  {
  case is_AAparameter_head:

    bufAppendS("AAparameter_head");




    break;
  case is_ABparameter_head:
    bufAppendC('(');

    bufAppendS("ABparameter_head");

    bufAppendC(' ');

    shPARAMETER_HEAD(p->u.abparameter_head_.parameter_head_);
  bufAppendC(' ');
    shPARAMETER(p->u.abparameter_head_.parameter_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing PARAMETER_HEAD!\n");
    exit(1);
  }
}

void shDECLARE_STATEMENT(DECLARE_STATEMENT p)
{
  switch(p->kind)
  {
  case is_AAdeclare_statement:
    bufAppendC('(');

    bufAppendS("AAdeclare_statement");

    bufAppendC(' ');

    shDECLARE_BODY(p->u.aadeclare_statement_.declare_body_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing DECLARE_STATEMENT!\n");
    exit(1);
  }
}

void shASSIGN_LIST(ASSIGN_LIST p)
{
  switch(p->kind)
  {
  case is_AAassign_list:
    bufAppendC('(');

    bufAppendS("AAassign_list");

    bufAppendC(' ');

    shASSIGN(p->u.aaassign_list_.assign_);
  bufAppendC(' ');
    shPARAMETER_LIST(p->u.aaassign_list_.parameter_list_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ASSIGN_LIST!\n");
    exit(1);
  }
}

void shTEXT(TEXT p)
{
  switch(p->kind)
  {
  case is_FQtext:
    bufAppendC('(');

    bufAppendS("FQtext");

    bufAppendC(' ');

    shIdent(p->u.fqtext_.texttoken_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing TEXT!\n");
    exit(1);
  }
}

void shREPLACE_STMT(REPLACE_STMT p)
{
  switch(p->kind)
  {
  case is_AAreplace_stmt:
    bufAppendC('(');

    bufAppendS("AAreplace_stmt");

    bufAppendC(' ');

    shREPLACE_HEAD(p->u.aareplace_stmt_.replace_head_);
  bufAppendC(' ');
    shTEXT(p->u.aareplace_stmt_.text_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing REPLACE_STMT!\n");
    exit(1);
  }
}

void shREPLACE_HEAD(REPLACE_HEAD p)
{
  switch(p->kind)
  {
  case is_AAreplace_head:
    bufAppendC('(');

    bufAppendS("AAreplace_head");

    bufAppendC(' ');

    shIDENTIFIER(p->u.aareplace_head_.identifier_);

    bufAppendC(')');

    break;
  case is_ABreplace_head:
    bufAppendC('(');

    bufAppendS("ABreplace_head");

    bufAppendC(' ');

    shIDENTIFIER(p->u.abreplace_head_.identifier_);
  bufAppendC(' ');
    shARG_LIST(p->u.abreplace_head_.arg_list_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing REPLACE_HEAD!\n");
    exit(1);
  }
}

void shARG_LIST(ARG_LIST p)
{
  switch(p->kind)
  {
  case is_AAarg_list:
    bufAppendC('(');

    bufAppendS("AAarg_list");

    bufAppendC(' ');

    shIDENTIFIER(p->u.aaarg_list_.identifier_);

    bufAppendC(')');

    break;
  case is_ABarg_list:
    bufAppendC('(');

    bufAppendS("ABarg_list");

    bufAppendC(' ');

    shARG_LIST(p->u.abarg_list_.arg_list_);
  bufAppendC(' ');
    shIDENTIFIER(p->u.abarg_list_.identifier_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ARG_LIST!\n");
    exit(1);
  }
}

void shSTRUCTURE_STMT(STRUCTURE_STMT p)
{
  switch(p->kind)
  {
  case is_AAstructure_stmt:
    bufAppendC('(');

    bufAppendS("AAstructure_stmt");

    bufAppendC(' ');

    shSTRUCT_STMT_HEAD(p->u.aastructure_stmt_.struct_stmt_head_);
  bufAppendC(' ');
    shSTRUCT_STMT_TAIL(p->u.aastructure_stmt_.struct_stmt_tail_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing STRUCTURE_STMT!\n");
    exit(1);
  }
}

void shSTRUCT_STMT_HEAD(STRUCT_STMT_HEAD p)
{
  switch(p->kind)
  {
  case is_AAstruct_stmt_head:
    bufAppendC('(');

    bufAppendS("AAstruct_stmt_head");

    bufAppendC(' ');

    shSTRUCTURE_ID(p->u.aastruct_stmt_head_.structure_id_);
  bufAppendC(' ');
    shLEVEL(p->u.aastruct_stmt_head_.level_);

    bufAppendC(')');

    break;
  case is_ABstruct_stmt_head:
    bufAppendC('(');

    bufAppendS("ABstruct_stmt_head");

    bufAppendC(' ');

    shSTRUCTURE_ID(p->u.abstruct_stmt_head_.structure_id_);
  bufAppendC(' ');
    shMINOR_ATTR_LIST(p->u.abstruct_stmt_head_.minor_attr_list_);
  bufAppendC(' ');
    shLEVEL(p->u.abstruct_stmt_head_.level_);

    bufAppendC(')');

    break;
  case is_ACstruct_stmt_head:
    bufAppendC('(');

    bufAppendS("ACstruct_stmt_head");

    bufAppendC(' ');

    shSTRUCT_STMT_HEAD(p->u.acstruct_stmt_head_.struct_stmt_head_);
  bufAppendC(' ');
    shDECLARATION(p->u.acstruct_stmt_head_.declaration_);
  bufAppendC(' ');
    shLEVEL(p->u.acstruct_stmt_head_.level_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing STRUCT_STMT_HEAD!\n");
    exit(1);
  }
}

void shSTRUCT_STMT_TAIL(STRUCT_STMT_TAIL p)
{
  switch(p->kind)
  {
  case is_AAstruct_stmt_tail:
    bufAppendC('(');

    bufAppendS("AAstruct_stmt_tail");

    bufAppendC(' ');

    shDECLARATION(p->u.aastruct_stmt_tail_.declaration_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing STRUCT_STMT_TAIL!\n");
    exit(1);
  }
}

void shINLINE_DEFINITION(INLINE_DEFINITION p)
{
  switch(p->kind)
  {
  case is_AAinline_definition:
    bufAppendC('(');

    bufAppendS("AAinline_definition");

    bufAppendC(' ');

    shARITH_INLINE(p->u.aainline_definition_.arith_inline_);

    bufAppendC(')');

    break;
  case is_ABinline_definition:
    bufAppendC('(');

    bufAppendS("ABinline_definition");

    bufAppendC(' ');

    shBIT_INLINE(p->u.abinline_definition_.bit_inline_);

    bufAppendC(')');

    break;
  case is_ACinline_definition:
    bufAppendC('(');

    bufAppendS("ACinline_definition");

    bufAppendC(' ');

    shCHAR_INLINE(p->u.acinline_definition_.char_inline_);

    bufAppendC(')');

    break;
  case is_ADinline_definition:
    bufAppendC('(');

    bufAppendS("ADinline_definition");

    bufAppendC(' ');

    shSTRUCTURE_EXP(p->u.adinline_definition_.structure_exp_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing INLINE_DEFINITION!\n");
    exit(1);
  }
}

void shARITH_INLINE(ARITH_INLINE p)
{
  switch(p->kind)
  {
  case is_ACprimary:
    bufAppendC('(');

    bufAppendS("ACprimary");

    bufAppendC(' ');

    shARITH_INLINE_DEF(p->u.acprimary_.arith_inline_def_);
  bufAppendC(' ');
    shCLOSING(p->u.acprimary_.closing_);

    bufAppendC(')');

    break;
  case is_AZprimary:
    bufAppendC('(');

    bufAppendS("AZprimary");

    bufAppendC(' ');

    shARITH_INLINE_DEF(p->u.azprimary_.arith_inline_def_);
  bufAppendC(' ');
    shBLOCK_BODY(p->u.azprimary_.block_body_);
  bufAppendC(' ');
    shCLOSING(p->u.azprimary_.closing_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ARITH_INLINE!\n");
    exit(1);
  }
}

void shARITH_INLINE_DEF(ARITH_INLINE_DEF p)
{
  switch(p->kind)
  {
  case is_AAarith_inline_def:
    bufAppendC('(');

    bufAppendS("AAarith_inline_def");

    bufAppendC(' ');

    shARITH_SPEC(p->u.aaarith_inline_def_.arith_spec_);

    bufAppendC(')');

    break;
  case is_ABarith_inline_def:

    bufAppendS("ABarith_inline_def");




    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing ARITH_INLINE_DEF!\n");
    exit(1);
  }
}

void shBIT_INLINE(BIT_INLINE p)
{
  switch(p->kind)
  {
  case is_AGbit_prim:
    bufAppendC('(');

    bufAppendS("AGbit_prim");

    bufAppendC(' ');

    shBIT_INLINE_DEF(p->u.agbit_prim_.bit_inline_def_);
  bufAppendC(' ');
    shCLOSING(p->u.agbit_prim_.closing_);

    bufAppendC(')');

    break;
  case is_AZbit_prim:
    bufAppendC('(');

    bufAppendS("AZbit_prim");

    bufAppendC(' ');

    shBIT_INLINE_DEF(p->u.azbit_prim_.bit_inline_def_);
  bufAppendC(' ');
    shBLOCK_BODY(p->u.azbit_prim_.block_body_);
  bufAppendC(' ');
    shCLOSING(p->u.azbit_prim_.closing_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BIT_INLINE!\n");
    exit(1);
  }
}

void shBIT_INLINE_DEF(BIT_INLINE_DEF p)
{
  switch(p->kind)
  {
  case is_AAbit_inline_def:
    bufAppendC('(');

    bufAppendS("AAbit_inline_def");

    bufAppendC(' ');

    shBIT_SPEC(p->u.aabit_inline_def_.bit_spec_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing BIT_INLINE_DEF!\n");
    exit(1);
  }
}

void shCHAR_INLINE(CHAR_INLINE p)
{
  switch(p->kind)
  {
  case is_ADchar_prim:
    bufAppendC('(');

    bufAppendS("ADchar_prim");

    bufAppendC(' ');

    shCHAR_INLINE_DEF(p->u.adchar_prim_.char_inline_def_);
  bufAppendC(' ');
    shCLOSING(p->u.adchar_prim_.closing_);

    bufAppendC(')');

    break;
  case is_AZchar_prim:
    bufAppendC('(');

    bufAppendS("AZchar_prim");

    bufAppendC(' ');

    shCHAR_INLINE_DEF(p->u.azchar_prim_.char_inline_def_);
  bufAppendC(' ');
    shBLOCK_BODY(p->u.azchar_prim_.block_body_);
  bufAppendC(' ');
    shCLOSING(p->u.azchar_prim_.closing_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing CHAR_INLINE!\n");
    exit(1);
  }
}

void shCHAR_INLINE_DEF(CHAR_INLINE_DEF p)
{
  switch(p->kind)
  {
  case is_AAchar_inline_def:
    bufAppendC('(');

    bufAppendS("AAchar_inline_def");

    bufAppendC(' ');

    shCHAR_SPEC(p->u.aachar_inline_def_.char_spec_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing CHAR_INLINE_DEF!\n");
    exit(1);
  }
}

void shSTRUC_INLINE_DEF(STRUC_INLINE_DEF p)
{
  switch(p->kind)
  {
  case is_AAstruc_inline_def:
    bufAppendC('(');

    bufAppendS("AAstruc_inline_def");

    bufAppendC(' ');

    shSTRUCT_SPEC(p->u.aastruc_inline_def_.struct_spec_);

    bufAppendC(')');

    break;

  default:
    fprintf(stderr, "Error: bad kind field when showing STRUC_INLINE_DEF!\n");
    exit(1);
  }
}

void shInteger(Integer i)
{
  char tmp[16];
  sprintf(tmp, "%d", i);
  bufAppendS(tmp);
}
void shDouble(Double d)
{
  char tmp[16];
  sprintf(tmp, "%g", d);
  bufAppendS(tmp);
}
void shChar(Char c)
{
  bufAppendC('\'');
  bufAppendC(c);
  bufAppendC('\'');
}
void shString(String s)
{
  bufAppendC('\"');
  bufAppendS(s);
  bufAppendC('\"');
}
void shIdent(String s)
{
  bufAppendC('\"');
  bufAppendS(s);
  bufAppendC('\"');
}

void shBitIdentifierToken(String s)
{
  bufAppendC('\"');
  bufAppendS(s);
  bufAppendC('\"');
}


void shBitFunctionIdentifierToken(String s)
{
  bufAppendC('\"');
  bufAppendS(s);
  bufAppendC('\"');
}


void shCharFunctionIdentifierToken(String s)
{
  bufAppendC('\"');
  bufAppendS(s);
  bufAppendC('\"');
}


void shCharIdentifierToken(String s)
{
  bufAppendC('\"');
  bufAppendS(s);
  bufAppendC('\"');
}


void shStructIdentifierToken(String s)
{
  bufAppendC('\"');
  bufAppendS(s);
  bufAppendC('\"');
}


void shStructFunctionIdentifierToken(String s)
{
  bufAppendC('\"');
  bufAppendS(s);
  bufAppendC('\"');
}


void shLabelToken(String s)
{
  bufAppendC('\"');
  bufAppendS(s);
  bufAppendC('\"');
}


void shEventToken(String s)
{
  bufAppendC('\"');
  bufAppendS(s);
  bufAppendC('\"');
}


void shArithFieldToken(String s)
{
  bufAppendC('\"');
  bufAppendS(s);
  bufAppendC('\"');
}


void shIdentifierToken(String s)
{
  bufAppendC('\"');
  bufAppendS(s);
  bufAppendC('\"');
}


void shStringToken(String s)
{
  bufAppendC('\"');
  bufAppendS(s);
  bufAppendC('\"');
}


void shTextToken(String s)
{
  bufAppendC('\"');
  bufAppendS(s);
  bufAppendC('\"');
}


void shLevelToken(String s)
{
  bufAppendC('\"');
  bufAppendS(s);
  bufAppendC('\"');
}


void shNumberToken(String s)
{
  bufAppendC('\"');
  bufAppendS(s);
  bufAppendC('\"');
}


void shCompoundToken(String s)
{
  bufAppendC('\"');
  bufAppendS(s);
  bufAppendC('\"');
}


void bufAppendS(const char *s)
{
  int len = strlen(s);
  int n;
  while (cur_ + len > buf_size)
  {
    buf_size *= 2; /* Double the buffer size */
    resizeBuffer();
  }
  for(n = 0; n < len; n++)
  {
    buf_[cur_ + n] = s[n];
  }
  cur_ += len;
  buf_[cur_] = 0;
}
void bufAppendC(const char c)
{
#include "fixPrinter.c"

  if (cur_ == buf_size)
  {
    buf_size *= 2; /* Double the buffer size */
    resizeBuffer();
  }
  buf_[cur_] = c;
  cur_++;
  buf_[cur_] = 0;
}
void bufReset(void)
{
  cur_ = 0;
  buf_size = BUFFER_INITIAL;
  resizeBuffer();
  memset(buf_, 0, buf_size);
}
void resizeBuffer(void)
{
  char *temp = (char *) malloc(buf_size);
  if (!temp)
  {
    fprintf(stderr, "Error: Out of memory while attempting to grow buffer!\n");
    exit(1);
  }
  if (buf_)
  {
    strncpy(temp, buf_, buf_size); /* peteg: strlcpy is safer, but not POSIX/ISO C. */
    free(buf_);
  }
  buf_ = temp;
}
char *buf_;
int cur_, buf_size;

