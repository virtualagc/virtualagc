/****************************************************************************
 * OUT - OUTPUT REGISTER subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: OUT.h
 *
 * VERSIONS:
 *
 * DESCRIPTION:
 * Output Registers for the Block 1 Apollo Guidance Computer prototype (AGC4).
 *
 * SOURCES:
 * Mostly based on information from "Logical Description for the Apollo
 * Guidance Computer (AGC4)", Albert Hopkins, Ramon Alonso, and Hugh
 * Blair-Smith, R-393, MIT Instrumentation Laboratory, 1963.
 *
 * NOTES:
 *
 *****************************************************************************
 */
#ifndef OUT_H
#define OUT_H
#include "reg.h"
class regOut1 : public reg
{
public:
  regOut1() :
      reg(16, "%06o")
  {
  }
};
class regOut2 : public reg
{
public:
  regOut2() :
      reg(16, "%06o")
  {
  }
};
class regOut3 : public reg
{
public:
  regOut3() :
      reg(16, "%06o")
  {
  }
};
class regOut4 : public reg
{
public:
  regOut4() :
      reg(16, "%06o")
  {
  }
};
class OUT
{
public:
  static void
  execWP_GENRST();
  static void
  execWP_WA10();
  static void
  execRP_RA11();
  static void
  execWP_WA11();
  static void
  execRP_RA12();
  static void
  execWP_WA12();
  static void
  execRP_RA13();
  static void
  execWP_WA13();
  static void
  execRP_RA14();
  static void
  execWP_WA14();
  static regOut1 register_OUT1; // output register 1
  static regOut2 register_OUT2; // output register 2
  static regOut3 register_OUT3; // output register 3
  static regOut4 register_OUT4; // output register 4
};
#endif
