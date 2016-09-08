/****************************************************************************
 * CTR - INVOLUNTARY PRIORITY COUNTER subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 10/25/02
 * FILE: CTR.h
 *
 * VERSIONS:
 *
 * DESCRIPTION:
 * Involuntary Counters for the Block 1 Apollo Guidance Computer prototype (AGC4).
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
#ifndef CTR_H
#define CTR_H
#include "reg.h"
enum ctrNumber
{ // indexes for priority cells
  OVCTR = 0, TIME2 = 1, // Block II puts TIME2 first
  TIME1 = 2,
  TIME3 = 3,
  TIME4 = 4,
};
enum ctrAddr
{ // octal addresses of counters
  // Note: In Block 1, TIME1 preceeds TIME2. In Block II,
  // this is reversed: TIME2 preceeds TIME1. This reversal
  // was done so that the most significant time word occurs
  // at the lower address in the 2 word AGC clock. Therefore,
  // a common AGC software routine can be used to read the
  // time.
  OVCTR_ADDR = 0034, TIME2_ADDR = 0035, // Block II puts TIME2 first
  TIME1_ADDR = 0036,
  TIME3_ADDR = 0037,
  TIME4_ADDR = 0040,
  SPARE1_ADDR = 0041,
  SPARE2_ADDR = 0042,
  SPARE3_ADDR = 0043
};
enum pCntrType
{
  NOPSEL = 0, // NO COUNTER
  PINCSEL = 1, // PINC
  MINCSEL = 2 // MINC
};
class regUpCELL : public reg
{
public:
  // Bit synchronize the counter inputs.
  regUpCELL() :
      reg(8, "%03o")
  {
  }
};
class regDnCELL : public reg
{
public:
  // Bit synchronize the counter inputs.
  regDnCELL() :
      reg(8, "%03o")
  {
  }
};
class CTR
{
public:
  static void
  execWP_GENRST();
  static void
  execWP_WPCTR();
  static void
  execRP_RSCT();
  static void
  execWP_WOVR();
  static void
  execWP_WOVC();
  static unsigned
  getSubseq();
  static unsigned pcUp[];
  static unsigned pcDn[];
  static regUpCELL register_UpCELL; // latches the selected priority counter cell (0-7)
  static regDnCELL register_DnCELL; // latches the selected priority counter cell (0-7)
private:
  static void
  resetAllpc();
};
#endif
