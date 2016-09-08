/****************************************************************************
 * PAR - PARITY GENERATION AND TEST subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: PAR.h
 *
 * VERSIONS:
 *
 * DESCRIPTION:
 * Parity Generation and Test for the Block 1 Apollo Guidance Computer
 * prototype (AGC4).
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
#ifndef PAR_H
#define PAR_H
#include "reg.h"
class regG15 : public reg
{
public:
  // memory buffer register bit 15 (parity) only
  regG15() :
      reg(1, "%01o")
  {
  }
};
class regP : public reg
{
public:
  regP() :
      reg(16, "%06o")
  {
  }
};
class regP2 : public reg
{
public:
  regP2() :
      reg(1, "%01o")
  {
  }
};
class regPALM : public reg
{
public:
  // parity alarm FF (set on TP)
  regPALM() :
      reg(1, "%01o")
  {
  }
};
class PAR
{
public:
  static void
  execRP_WE();
  static void
  execWP_WP();
  static void
  execWP_WPx();
  static void
  execWP_WP2();
  static void
  execWP_RP2();
  static void
  execWP_GP();
  static void
  execWP_SBWG();
  static void
  execWP_WGx();
  static void
  execWP_CLG();
  static void
  execWP_GENRST();
  static void
  execWP_TP();
  static void
  CLR_PALM(); // asynchronous clear for PARITY ALARM
  // memory buffer register bit 15; the rest of the
  // memory buffer register is defined in MBF
  static regG15 register_G15;
  static regP2 register_P2;
  static regP register_P;
  static regPALM register_PALM;
  static unsigned
  gen1_15Parity(unsigned r);
  static unsigned
  genP_15Parity(unsigned r);
  static unsigned conv_WP[];
};
#endif
