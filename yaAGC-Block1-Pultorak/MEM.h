/****************************************************************************
 * MEM - ERASEABLE/FIXED MEMORY subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/26/02
 * FILE: MEM.h
 *
 * VERSIONS:
 *
 * DESCRIPTION:
 * Eraseable & Fixed Memory for the Block 1 Apollo Guidance Computer
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
#ifndef MEM_H
#define MEM_H
#include "reg.h"
// There are actually 034 (28D) fixed banks.  R393 is wrong in that respect.
#define NUMFBANK 034 // number of 1024 word fixed memory banks
#define LOGICALFBANK 040
class regEMEM : public reg
{
public:
  regEMEM() :
      reg(16, "%06o")
  {
  }
  virtual
  ~regEMEM()
  {
  }
  regEMEM&
  operator=(const unsigned& r)
  {
    write(r);
    return *this;
  }
};
class regFMEM : public reg
{
public:
  regFMEM() :
      reg(16, "%06o")
  {
  }
  virtual
  ~regFMEM()
  {
  }
  regFMEM&
  operator=(const unsigned& r)
  {
    write(r);
    return *this;
  }
};
class MEM
{
public:
  static void
  execWP_WE();
  static void
  execRP_SBWG();
  static regEMEM register_EMEM[]; // erasable memory
  static regFMEM register_FMEM[]; // fixed memory
  static unsigned MEM_DATA_BUS; // data lines: memory bits 15-1
  static unsigned MEM_PARITY_BUS; // parity line: memory bit 16
  static unsigned
  readMemory();
  static void
  writeMemory(unsigned data);
  // The following functions are used in the simulator,
  // but are implemented in the AGC design.
  static unsigned
  readMemory(unsigned address);
  static void
  writeMemory(unsigned address, unsigned data);
};
#endif
