/****************************************************************************
 * MBF - MEMORY BUFFER REGISTER subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: MBF.h
 *
 * VERSIONS:
 *
 * DESCRIPTION:
 * Memory Buffer Register for the Block 1 Apollo Guidance Computer prototype (AGC4).
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
#ifndef MBF_H
#define MBF_H
#include "reg.h"
class regG : public reg
{
public:
// all memory bits except bit 15 (parity)
// bit 15 is not used, so ignore it.
  regG() :
      reg(16, "%06o")
  {
  }
  virtual
  ~regG()
  {
  }
};
class MBF
{
public:
  static void
  execWP_GENRST();
  static void
  execRP_RG();
  static void
  execRP_WE();
  static void
  execWP_WGn();
  static void
  execWP_WGx();
  static void
  execWP_W20();
  static void
  execWP_W21();
  static void
  execWP_W22();
  static void
  execWP_W23();
  static void
  execWP_SBWG();
// Bit 15 (parity) is kept in a separate register in PAR
// because it is independently loaded.
  static regG register_G; // memory buffer register (except for bit 15)
  static unsigned conv_RG[];
  static unsigned conv_WGn[];
  static unsigned conv_W20[];
  static unsigned conv_W21[];
  static unsigned conv_W22[];
  static unsigned conv_W23[];
  static unsigned conv_SBWG[];
  static unsigned conv_WE[];
};
#endif
