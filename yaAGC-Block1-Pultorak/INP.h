/****************************************************************************
 * INP - INPUT REGISTER subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: INP.h
 *
 * VERSIONS:
 *
 * DESCRIPTION:
 * Input Registers for the Block 1 Apollo Guidance Computer prototype (AGC4).
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
#ifndef INP_H
#define INP_H
#include "reg.h"
class regIn0 : public reg
{
public:
  regIn0() :
      reg(16, "%06o")
  {
  }
  virtual
  ~regIn0()
  {
  }
};
class regIn1 : public reg
{
public:
  regIn1() :
      reg(16, "%06o")
  {
  }
  virtual
  ~regIn1()
  {
  }
};
class regIn2 : public reg
{
public:
  regIn2() :
      reg(16, "%06o")
  {
  }
  virtual
  ~regIn2()
  {
  }
};
class regIn3 : public reg
{
public:
  regIn3() :
      reg(16, "%06o")
  {
  }
  virtual
  ~regIn3()
  {
  }
};
class INP
{
public:
  static void
  execRP_RA4();
  static void
  execRP_RA5();
  static void
  execRP_RA6();
  static void
  execRP_RA7();
  static regIn0 register_IN0; // input register 0
  static regIn1 register_IN1; // input register 1
  static regIn2 register_IN2; // input register 2
  static regIn3 register_IN3; // input register 3
};
#endif
