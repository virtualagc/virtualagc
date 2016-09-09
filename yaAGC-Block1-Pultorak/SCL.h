/****************************************************************************
 * SCL - SCALER subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: SCL.h
 *
 * VERSIONS:
 *
 * DESCRIPTION:
 * Scaler for the Block 1 Apollo Guidance Computer prototype (AGC4).
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
#ifndef SCL_H
#define SCL_H
#include "reg.h"
class regF17 : public reg
{
public:
  regF17() :
      reg(2, "%01o")
  {
  }
};
class regF13 : public reg
{
public:
  regF13() :
      reg(2, "%01o")
  {
  }
};
class regF10 : public reg
{
public:
  regF10() :
      reg(2, "%01o")
  {
  }
};
class regSCL : public reg
{
public:
  regSCL() :
      reg(32, "%06o")
  {
  }
};
class SCL
{
public:
  static void
  doexecWP_SCL();
  static void
  doexecWP_F17();
  static void
  doexecWP_F13();
  static void
  doexecWP_F10();
  static regSCL register_SCL;
  // Normally outputs '0'; outputs '1' for one
  // clock pulse at the indicated frequency.
  static unsigned
  F17x(); // 0.78125 Hz scaler output
  static unsigned
  F13x(); // 12.5 Hz scaler output
  static unsigned
  F10x(); // 100 Hz scaler output
  static regF17 register_F17;
  static regF13 register_F13;
  static regF10 register_F10;
};

#endif

