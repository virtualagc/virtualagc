/****************************************************************************
 * CRG - ADDRESSABLE CENTRAL REGISTER subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: CRG.h
 *
 * VERSIONS:
 *
 * DESCRIPTION:
 * Addressable Central Registers for the Block 1 Apollo Guidance Computer
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
#ifndef CRG_H
#define CRG_H
#include "reg.h"
class regQ : public reg
{
public:
  regQ() :
      reg(16, "%06o")
  {
  }
};
class regZ : public reg
{
public:
  regZ() :
      reg(16, "%06o")
  {
  }
};
class regLP : public reg
{
public:
  regLP() :
      reg(16, "%06o")
  {
  }
};
class regA : public reg
{
public:
  regA() :
      reg(16, "%06o")
  {
  }
};
class CRG
{
public:
  static void
  execWP_GENRST();
  static void
  execRP_RQ();
  static void
  execRP_RA1();
  static void
  execWP_WQ();
  static void
  execWP_WA1();
  static void
  execRP_RZ();
  static void
  execRP_RA2();
  static void
  execWP_WZ();
  static void
  execWP_WA2();
  static void
  execRP_RLP();
  static void
  execRP_RA3();
  static void
  execRP_RA();
  static void
  execRP_RA0();
  static void
  execWP_WA();
  static void
  execWP_WA0();
  static void
  execWP_WALP();
  static void
  execWP_WLP();
  static void
  execWP_WA3();
  static regQ register_Q; // return address
  static regZ register_Z; // program counter
  static regLP register_LP; // lower accumulator
  static regA register_A; // accumulator
  static unsigned conv_WALP_LP[];
  static unsigned conv_WALP_A[];
  static unsigned conv_WLP[];
};
#endif
